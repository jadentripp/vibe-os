import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MAKE_WAD_IMAGE = ROOT / "tools" / "make_wad_image.py"
spec = importlib.util.spec_from_file_location("make_wad_image", MAKE_WAD_IMAGE)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)


class FatContractTests(unittest.TestCase):
    def test_public_fat_header_exposes_reusable_root_listing_contract(self):
        abi_source = r"""
            #include "vibe_os.h"
            #include "errno.h"

            #define CHECK(name, expr) typedef char check_##name[(expr) ? 1 : -1]

            CHECK(dirent_name_bytes, VIBE_DIRENT_NAME_BYTES == 16);
            CHECK(dirent_size_bytes, sizeof(vibe_dirent_t) == VIBE_DIRENT_BYTES);
            CHECK(dirent_name, __builtin_offsetof(vibe_dirent_t, name) == 0);
            CHECK(dirent_size, __builtin_offsetof(vibe_dirent_t, size) == 16);
            CHECK(dirent_mode, __builtin_offsetof(vibe_dirent_t, mode) == 20);
            CHECK(dirent_first_cluster, __builtin_offsetof(vibe_dirent_t, first_cluster) == 24);
            CHECK(dirent_attributes, __builtin_offsetof(vibe_dirent_t, attributes) == 28);
            CHECK(dirent_directory_attr, VIBE_DIRENT_ATTR_DIRECTORY == 0x10u);
            CHECK(dirent_archive_attr, VIBE_DIRENT_ATTR_ARCHIVE == 0x20u);
            CHECK(listdir_syscall, VIBE_SYS_LISTDIR == 30);
            CHECK(enotdir_errno, ENOTDIR == 20);
            CHECK(eisdir_errno, EISDIR == 21);
        """
        abi = subprocess.run(
            [
                "clang",
                "-target",
                "i386-unknown-none-elf",
                "-std=gnu89",
                "-ffreestanding",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-I",
                str(ROOT / "doom_port" / "include"),
                "-x",
                "c",
                "-fsyntax-only",
                "-",
            ],
            cwd=ROOT,
            input=abi_source,
            capture_output=True,
            text=True,
        )
        self.assertEqual(abi.returncode, 0, abi.stderr)

        runtime_source = r"""
            #include "vibe_os.h"

            int main(void)
            {
                vibe_dirent_t entry = { { 0 }, 0, 0, 0, 0 };

                entry.name[0] = 'S';
                entry.name[1] = 'A';
                entry.name[2] = 'V';
                entry.attributes = VIBE_DIRENT_ATTR_ARCHIVE;
                if (!vibe_dirent_is_regular_file(&entry))
                    return 1;
                if (vibe_dirent_is_directory(&entry))
                    return 2;

                entry.attributes = VIBE_DIRENT_ATTR_DIRECTORY;
                if (!vibe_dirent_is_directory(&entry))
                    return 3;
                if (vibe_dirent_is_regular_file(&entry))
                    return 4;

                entry.name[0] = 0;
                entry.attributes = VIBE_DIRENT_ATTR_ARCHIVE;
                if (vibe_dirent_is_regular_file(&entry))
                    return 5;

                if (vibe_dirent_is_directory(0) || vibe_dirent_is_regular_file(0))
                    return 6;

                return 0;
            }
        """
        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "vibe_fat_contract"
            build = subprocess.run(
                [
                    "clang",
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-Werror",
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    "-x",
                    "c",
                    "-",
                    "-o",
                    str(binary),
                ],
                cwd=ROOT,
                input=runtime_source,
                capture_output=True,
                text=True,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            run = subprocess.run([str(binary)], cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(run.returncode, 0, run.stdout + run.stderr)

    def test_fat_docs_name_generic_scope_without_wad_or_disk_artifacts(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        docs = (ROOT / "docs" / "persistent-fat16.md").read_text()
        normalized_docs = " ".join(docs.split())

        for source in (
            "VIBE_DIRENT_NAME_BYTES",
            "VIBE_DIRENT_BYTES",
            "VIBE_DIRENT_ATTR_DIRECTORY",
            "vibe_dirent_is_directory",
            "vibe_dirent_is_regular_file",
            "EISDIR",
            "ENOTDIR",
        ):
            with self.subTest(source=source):
                self.assertIn(source, header)

        for source in (
            "Reusable FAT16 syscall surface",
            "root-level 8.3",
            "vibe_listdir",
            "one root-level subdirectory",
            "open`/`read`/`lseek`/`stat`/`fstat`",
            "/ASSETS/README.TXT",
            "vibe_dirent_is_regular_file",
            "future games and tools",
            "EISDIR",
            "ENOTDIR",
        ):
            with self.subTest(source=source):
                self.assertIn(source, normalized_docs)

        for forbidden in ("DOOM1.WAD bytes", "disk.img artifact", "raw sector dump"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, docs)

    def test_generated_fat_geometry_keeps_partition_and_data_boundaries_explicit(self):
        with tempfile.TemporaryDirectory() as tmp:
            image_path = Path(tmp) / "disk.img"
            subprocess.run(
                [sys.executable, str(MAKE_WAD_IMAGE), str(image_path)],
                check=True,
                cwd=ROOT,
                stdout=subprocess.DEVNULL,
            )
            image = bytearray(image_path.read_bytes())

        fs = make_wad_image.Fat16Image(image)
        self.assertEqual(fs.partition_lba, make_wad_image.PARTITION_START)
        self.assertEqual(fs.root_lba, 2561)
        self.assertEqual(fs.data_lba, 2593)
        self.assertLess(
            make_wad_image.KERNEL_LBA + make_wad_image.KERNEL_SECTORS,
            fs.partition_lba,
        )

        partition_end = make_wad_image.PARTITION_START + make_wad_image.PARTITION_SECTORS
        data_sectors = partition_end - fs.data_lba
        usable_data_sectors = make_wad_image.data_cluster_count() * make_wad_image.SECTORS_PER_CLUSTER
        self.assertGreaterEqual(data_sectors, usable_data_sectors)
        self.assertLess(
            data_sectors - usable_data_sectors,
            make_wad_image.SECTORS_PER_CLUSTER,
        )
        self.assertGreater(
            make_wad_image.SECTORS_PER_FAT * make_wad_image.SECTOR_SIZE // 2,
            make_wad_image.last_data_cluster(),
        )

    def test_fat_reader_rejects_cluster_indexes_outside_data_and_fat_bounds(self):
        with tempfile.TemporaryDirectory() as tmp:
            image_path = Path(tmp) / "disk.img"
            subprocess.run(
                [sys.executable, str(MAKE_WAD_IMAGE), str(image_path)],
                check=True,
                cwd=ROOT,
                stdout=subprocess.DEVNULL,
            )
            fs = make_wad_image.Fat16Image(bytearray(image_path.read_bytes()))

        last_cluster = make_wad_image.last_data_cluster()
        self.assertGreaterEqual(fs.fat_entry(last_cluster), 0)
        self.assertEqual(
            fs.cluster_offset(last_cluster),
            make_wad_image.sector_offset(
                fs.data_lba + (last_cluster - 2) * make_wad_image.SECTORS_PER_CLUSTER
            ),
        )
        with self.assertRaisesRegex(ValueError, "outside the data area"):
            fs.cluster_offset(last_cluster + 1)
        with self.assertRaisesRegex(ValueError, "outside the FAT"):
            fs.fat_entry(make_wad_image.SECTORS_PER_FAT * make_wad_image.SECTOR_SIZE // 2)

    def test_kernel_fat_vfs_exposes_readonly_one_level_directory_listing(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "fat_find_root_entry_any:",
            "fat_parse_user_subdir_file83:",
            "fat_find_subdir_entry:",
            "readonly_file_read:",
            "readonly_file_lseek:",
            "fat_list_user_dir:",
            "fat_list_subdir_cluster:",
            "call fat_find_root_entry_any",
            "test byte [fat_found_attributes], FAT_ATTR_DIRECTORY",
            "jnz .bad_syscall_eisdir",
            "call fat_list_user_dir",
            "FD_KIND_READONLY_FILE equ 3",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        stat_section = kernel.split(".stat:", 1)[1].split(".fstat:", 1)[0]
        self.assertIn("call fat_parse_user_subdir_file83", stat_section)
        self.assertIn("call fat_find_subdir_entry", stat_section)
        self.assertIn("call fat_find_root_entry_any", stat_section)
        self.assertIn("STAT_MODE_READONLY_DIR", stat_section)

        open_section = kernel.split(".open_generic_root83:", 1)[1].split(".read:", 1)[0]
        self.assertIn("call fat_parse_user_subdir_file83", open_section)
        self.assertIn(
            "test dword [syscall_open_flags], O_WRONLY | O_RDWR | O_CREAT | O_TRUNC | O_APPEND\n"
            "    jz .open_generic_try_subdir_readonly\n"
            "    call fat_parse_user_subdir_file83\n"
            "    jnc .bad_syscall_eacces",
            open_section,
        )
        self.assertIn("mov byte [fd_kinds + eax], FD_KIND_READONLY_FILE", open_section)
        self.assertIn("mov [fd_file_sizes + eax * 4], edx", open_section)

        listdir_section = kernel.split("fat_list_user_dir:", 1)[1].split("fat_list_root_dir:", 1)[0]
        self.assertIn("call fat_parse_user_root83", listdir_section)
        self.assertIn("call fat_list_subdir_cluster", listdir_section)
        self.assertIn("cmp byte [esi], '.'", listdir_section)

    def test_kernel_classifies_directory_file_mismatches(self):
        errno_h = (ROOT / "doom_port" / "include" / "errno.h").read_text()
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "#define ENOTDIR 20",
            "#define EISDIR 21",
        ):
            with self.subTest(source=source):
                self.assertIn(source, errno_h)

        for source in (
            "ERRNO_ENOTDIR equ 20",
            "ERRNO_EISDIR equ 21",
            ".bad_syscall_enotdir:",
            ".bad_syscall_eisdir:",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        open_section = kernel.split(".open_generic_found:", 1)[1].split(".read:", 1)[0]
        self.assertIn("jnz .bad_syscall_eisdir", open_section)

        unlink_section = kernel.split(".unlink:", 1)[1].split(".stat:", 1)[0]
        self.assertIn("call fat_parse_user_root83", unlink_section)
        self.assertIn("jc .bad_syscall_einval", unlink_section)
        self.assertIn("call fat_find_root_entry_any", unlink_section)
        self.assertIn("test byte [fat_found_attributes], FAT_ATTR_DIRECTORY", unlink_section)
        self.assertIn("jnz .bad_syscall_eisdir", unlink_section)

        listdir_section = kernel.split("fat_list_user_dir:", 1)[1].split("fat_list_subdir_cluster:", 1)[0]
        self.assertIn("jz .fail_enotdir", listdir_section)
        self.assertIn("mov eax, -ERRNO_ENOTDIR", listdir_section)

        ftruncate_section = kernel.split(".ftruncate:", 1)[1].split(".mmap:", 1)[0]
        self.assertIn("cmp byte [fd_kinds + eax], FD_KIND_WRITABLE", ftruncate_section)
        self.assertIn("jne .bad_syscall_ebadf", ftruncate_section)

    def test_kernel_root_listdir_validates_user_buffer_by_entry_count(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        root_listdir = kernel.split("fat_list_root_dir:", 1)[1].split("user_file_read:", 1)[0]

        self.assertIn(
            "mov eax, [syscall_dirent_max]\n"
            "    shl eax, 5\n"
            "    mov ebx, eax\n"
            "    mov eax, [fat_list_user_ptr]\n"
            "    call user_range_validate",
            root_listdir,
        )
        self.assertNotIn(
            "mov eax, [fat_list_user_ptr]\n"
            "    shl eax, 5\n"
            "    mov ebx, eax\n"
            "    mov eax, [fat_list_user_ptr]\n"
            "    call user_range_validate",
            root_listdir,
        )

    def test_host_fat_image_subdirectory_round_trip_matches_kernel_contract(self):
        with tempfile.TemporaryDirectory() as tmp:
            image_path = Path(tmp) / "disk.img"
            subprocess.run(
                [sys.executable, str(MAKE_WAD_IMAGE), str(image_path)],
                check=True,
                cwd=ROOT,
                stdout=subprocess.DEVNULL,
            )
            image = bytearray(image_path.read_bytes())

        fs = make_wad_image.Fat16Image(image)

        fs.create_subdirectory(b"ASSETS     ")
        fs.write_directory_file(b"ASSETS     ", b"SPRITE  BIN", b"sprite-bytes")
        fs.write_directory_file(b"ASSETS     ", b"LEVEL   DAT", b"level-bytes")
        fs.validate_allocated_clusters_reachable()

        root_entries = fs.list_root_directory()
        asset_entry = next(entry for entry in root_entries if entry["name"] == b"ASSETS     ")
        self.assertTrue(asset_entry["is_directory"])
        self.assertEqual(asset_entry["size"], 0)

        names = {entry["name"] for entry in fs.list_directory((b"ASSETS     ",))}
        self.assertIn(b"SPRITE  BIN", names)
        self.assertIn(b"LEVEL   DAT", names)
        self.assertEqual(
            fs.read_file_at_path((b"ASSETS     ", b"SPRITE  BIN")),
            b"sprite-bytes",
        )

        with self.assertRaises(IsADirectoryError):
            fs.write_root_file(b"ASSETS     ", b"not-a-file")

    def test_host_fat_image_packages_nested_display_paths_with_83_normalization(self):
        with tempfile.TemporaryDirectory() as tmp:
            image_path = Path(tmp) / "disk.img"
            subprocess.run(
                [sys.executable, str(MAKE_WAD_IMAGE), str(image_path)],
                check=True,
                cwd=ROOT,
                stdout=subprocess.DEVNULL,
            )
            fs = make_wad_image.Fat16Image(bytearray(image_path.read_bytes()))

        normalized = make_wad_image.fat83_path_from_display_path(
            r".\assets\maps/e1m1.map"
        )
        self.assertEqual(
            normalized,
            (b"ASSETS     ", b"MAPS       ", b"E1M1    MAP"),
        )

        payload = b"spawn=player1\nsky=1\n"
        chain = fs.write_packaged_file_at_display_path(
            r".\assets\maps/e1m1.map",
            payload,
        )
        self.assertGreaterEqual(len(chain), 1)
        self.assertEqual(fs.read_file_at_display_path("/ASSETS/MAPS/E1M1.MAP"), payload)
        self.assertTrue(
            fs.entry_metadata_at_path((b"ASSETS     ", b"MAPS       "))["is_directory"]
        )
        self.assertEqual(
            fs.entry_metadata_at_path(normalized)["cluster"],
            chain[0],
        )
        fs.validate_allocated_clusters_reachable()

        fs.write_packaged_file_at_display_path("/assets/maps/e1m1.map", b"short\n")
        self.assertEqual(fs.read_file_at_path(normalized), b"short\n")
        fs.validate_allocated_clusters_reachable()

        for bad in (
            "",
            "/",
            "/assets/../save.dat",
            "/asset-name-that-is-too-long/readme.txt",
            "/assets/name.longext",
            "/assets/bad+name.txt",
        ):
            with self.subTest(bad=bad):
                with self.assertRaises(ValueError):
                    make_wad_image.fat83_path_from_display_path(bad)

    def test_host_fat_image_mutates_root_83_files_but_rejects_subdirectory_writes(self):
        with tempfile.TemporaryDirectory() as tmp:
            image_path = Path(tmp) / "disk.img"
            subprocess.run(
                [sys.executable, str(MAKE_WAD_IMAGE), str(image_path)],
                check=True,
                cwd=ROOT,
                stdout=subprocess.DEVNULL,
            )
            fs = make_wad_image.Fat16Image(bytearray(image_path.read_bytes()))

        root_path = (b"NOTES   TXT",)
        fs.create_file_at_path(root_path)
        fs.write_file_at_path(root_path, b"hello")
        fs.write_file_at_path(root_path, b"hello world")
        self.assertEqual(fs.read_file_at_path(root_path), b"hello world")
        fs.truncate_file_at_path(root_path)
        self.assertEqual(fs.read_file_at_path(root_path), b"")
        fs.write_file_at_path(root_path, b"again")
        self.assertGreater(len(fs.delete_file_at_path(root_path)), 0)
        self.assertIsNone(fs.entry_metadata_at_path(root_path))
        fs.validate_allocated_clusters_reachable()

        fs.create_subdirectory(b"ASSETS2    ")
        fs.write_directory_file(b"ASSETS2    ", b"README  TXT", b"readonly")
        readonly_path = (b"ASSETS2    ", b"README  TXT")
        self.assertEqual(fs.read_file_at_path(readonly_path), b"readonly")

        for operation, mutate in (
            ("write", lambda: fs.write_file_at_path(readonly_path, b"nope")),
            ("create", lambda: fs.create_file_at_path(readonly_path)),
            ("truncate", lambda: fs.truncate_file_at_path(readonly_path)),
            ("unlink", lambda: fs.delete_file_at_path(readonly_path)),
            ("create-missing", lambda: fs.create_file_at_path((b"ASSETS2    ", b"NEWFILE TXT"))),
        ):
            with self.subTest(operation=operation):
                with self.assertRaises(PermissionError):
                    mutate()

        self.assertEqual(fs.read_file_at_path(readonly_path), b"readonly")
        fs.validate_allocated_clusters_reachable()

    def test_generated_image_seeds_readonly_one_level_asset_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            image_path = Path(tmp) / "disk.img"
            subprocess.run(
                [sys.executable, str(MAKE_WAD_IMAGE), str(image_path)],
                check=True,
                cwd=ROOT,
                stdout=subprocess.DEVNULL,
            )
            fs = make_wad_image.Fat16Image(bytearray(image_path.read_bytes()))

        root_names = {entry["name"] for entry in fs.list_root_directory()}
        self.assertIn(make_wad_image.ASSET_DIR_NAME, root_names)
        asset_names = {entry["name"] for entry in fs.list_directory((make_wad_image.ASSET_DIR_NAME,))}
        self.assertIn(make_wad_image.ASSET_README_NAME, asset_names)
        readme_meta = make_wad_image.validate_generated_asset_readme(fs)
        self.assertEqual(readme_meta["size"], len(make_wad_image.ASSET_README_BYTES))
        self.assertEqual(
            fs.read_file_at_path(make_wad_image.ASSET_README_PATH),
            make_wad_image.ASSET_README_BYTES,
        )
        manifest = make_wad_image.validate_generated_packaged_assets(fs)
        self.assertEqual(
            {entry["path"] for entry in manifest},
            {
                "/ASSETS/README.TXT",
                "/ASSETS/MAPS/E1M1.MAP",
                "/ASSETS/TEXTURES/PAL0.BIN",
            },
        )
        self.assertEqual(
            fs.read_file_at_display_path("/assets/maps/e1m1.map"),
            b"name=E1M1\nmusic=D_E1M1\n",
        )


if __name__ == "__main__":
    unittest.main()
