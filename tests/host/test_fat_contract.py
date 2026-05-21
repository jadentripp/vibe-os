import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


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
            "vibe_dirent_is_regular_file",
            "future games and tools",
        ):
            with self.subTest(source=source):
                self.assertIn(source, normalized_docs)

        for forbidden in ("DOOM1.WAD bytes", "disk.img artifact", "raw sector dump"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, docs)


if __name__ == "__main__":
    unittest.main()
