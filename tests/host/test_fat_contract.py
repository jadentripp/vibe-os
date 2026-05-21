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
        ):
            with self.subTest(source=source):
                self.assertIn(source, header)

        for source in (
            "Reusable FAT16 syscall surface",
            "root-level 8.3",
            "vibe_listdir",
            "one root-level subdirectory",
            "vibe_dirent_is_regular_file",
            "future games and tools",
        ):
            with self.subTest(source=source):
                self.assertIn(source, normalized_docs)

        for forbidden in ("DOOM1.WAD bytes", "disk.img artifact", "raw sector dump"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, docs)

    def test_kernel_fat_vfs_exposes_readonly_one_level_directory_listing(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "fat_find_root_entry_any:",
            "fat_list_user_dir:",
            "fat_list_subdir_cluster:",
            "call fat_find_root_entry_any",
            "test byte [fat_found_attributes], FAT_ATTR_DIRECTORY",
            "jnz .bad_syscall_eacces",
            "call fat_list_user_dir",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        stat_section = kernel.split(".stat:", 1)[1].split(".fstat:", 1)[0]
        self.assertIn("call fat_find_root_entry_any", stat_section)
        self.assertIn("STAT_MODE_READONLY_DIR", stat_section)

        listdir_section = kernel.split("fat_list_user_dir:", 1)[1].split("fat_list_root_dir:", 1)[0]
        self.assertIn("call fat_parse_user_root83", listdir_section)
        self.assertIn("call fat_list_subdir_cluster", listdir_section)
        self.assertIn("cmp byte [esi], '.'", listdir_section)

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


if __name__ == "__main__":
    unittest.main()
