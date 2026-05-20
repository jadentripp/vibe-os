import importlib.util
import subprocess
import sys
import tempfile
import struct
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"


def load_tool(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


make_wad_image = load_tool("make_wad_image", ROOT / "tools" / "make_wad_image.py")
check_persistence = load_tool(
    "check_doom_persistence_image",
    ROOT / "tools" / "check_doom_persistence_image.py",
)


def doom_save_payload(description="VIBE SAVE", version="version 110", tail_size=128):
    payload = bytearray()
    payload.extend(description.encode("ascii")[:23].ljust(24, b"\0"))
    payload.extend(version.encode("ascii")[:15].ljust(16, b"\0"))
    payload.extend(b"\x03\x01\x01\x01")
    payload.extend(bytes((index & 0xFF for index in range(tail_size))))
    return bytes(payload)


class DoomPersistenceImageTests(unittest.TestCase):
    def write_temp_image(self, image):
        tmp = tempfile.NamedTemporaryFile(prefix="vibe-os-persist-", suffix=".img", delete=False)
        self.addCleanup(lambda: Path(tmp.name).unlink(missing_ok=True))
        tmp.write(image)
        tmp.close()
        return Path(tmp.name)

    def test_checker_accepts_fresh_image_entries_without_claiming_written_state(self):
        summary = check_persistence.validate_image(BUILD / "disk.img")
        self.assertEqual(summary, ["persistence entries present"])

    def test_checker_accepts_doom_shaped_defaults_and_save_slot(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"use_mouse\t\t1\nscreenblocks\t\t9\nchatmacro0\t\t\"HELLO\"\n",
        )
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[2], doom_save_payload())

        path = self.write_temp_image(image)
        summary = check_persistence.validate_image(
            path,
            require_default=True,
            require_save_slots=[2],
        )

        self.assertIn("DEFAULT.CFG bytes=", summary[0])
        self.assertIn("DOOMSAV2.DSG bytes=", summary[1])
        self.assertIn("description='VIBE SAVE'", summary[1])
        self.assertIn("version='version 110'", summary[1])

    def test_checker_proves_requested_entries_changed_from_baseline_image(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"use_mouse\t\t1\nscreenblocks\t\t9\nchatmacro0\t\t\"HELLO\"\n",
        )
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], doom_save_payload("REBOOT PROOF"))

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)
        summary = check_persistence.validate_image(
            image_path,
            baseline_image=baseline_path,
            require_default=True,
            require_save_slots=[0],
        )

        self.assertIn("DEFAULT.CFG bytes=", summary[0])
        self.assertIn("changed-from-baseline", summary[0])
        self.assertIn("DOOMSAV0.DSG bytes=", summary[1])
        self.assertIn("changed-from-baseline", summary[1])
        self.assertIn("REBOOT PROOF", summary[1])

    def test_checker_proves_requested_entries_survived_reboot_image(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"use_mouse\t\t1\nscreenblocks\t\t9\nchatmacro0\t\t\"HELLO\"\n",
        )
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[3], doom_save_payload("STILL HERE"))

        after_reboot = bytearray(after_write)
        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)

        summary = check_persistence.validate_image(
            reboot_path,
            baseline_image=baseline_path,
            reboot_baseline_image=write_path,
            require_default=True,
            require_save_slots=[3],
        )

        self.assertIn("changed-from-baseline", summary[0])
        self.assertIn("survived-reboot", summary[0])
        self.assertIn("DOOMSAV3.DSG bytes=", summary[1])
        self.assertIn("survived-reboot", summary[1])
        self.assertIn("STILL HERE", summary[1])

    def test_checker_rejects_requested_entry_that_changed_during_reboot(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"use_mouse\t\t1\nscreenblocks\t\t9\n",
        )

        after_reboot = bytearray(after_write)
        reboot_fs = make_wad_image.Fat16Image(after_reboot)
        reboot_fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"use_mouse\t\t1\nscreenblocks\t\t10\n",
        )

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "did not survive reboot"):
            check_persistence.validate_image(
                reboot_path,
                baseline_image=baseline_path,
                reboot_baseline_image=write_path,
                require_default=True,
            )

    def test_checker_rejects_protected_wad_or_elf_mutation_from_baseline(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        wad_meta = fs.root_file_metadata(make_wad_image.PROTECTED_ROOT_NAMES[0])
        image[fs.cluster_offset(wad_meta["cluster"])] ^= 0x01
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"use_mouse\t\t1\nscreenblocks\t\t9\n",
        )

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "protected entry DOOM1"):
            check_persistence.validate_image(
                image_path,
                baseline_image=baseline_path,
                require_default=True,
            )

    def test_checker_rejects_divergent_fat_copies(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        second_fat = (fs.partition_lba + fs.reserved + fs.sectors_per_fat) * make_wad_image.SECTOR_SIZE
        struct.pack_into("<H", image, second_fat + 2 * 2, fs.fat_entry(2) ^ 0x0001)
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "FAT copy 1 differs"):
            check_persistence.validate_image(path)

    def test_fat_image_detects_corrupt_dynamic_chains(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"RUNTIME TXT"

        chain = fs.write_root_file(name, b"A" * 700)
        fs.set_fat_entry(chain[-1], chain[0])
        with self.assertRaisesRegex(ValueError, "contains a loop"):
            fs.read_root_file(name)

        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        chain = fs.write_root_file(name, b"B" * 700)
        fs.set_fat_entry(chain[0], 0)
        with self.assertRaisesRegex(ValueError, "free cluster"):
            fs.read_root_file(name)

    def test_delete_reuses_root_slot_and_restores_free_cluster_budget(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"RUNTIME TXT"
        before_free = fs.free_data_clusters()

        chain = fs.write_root_file(name, b"A" * 700)
        self.assertEqual(fs.free_data_clusters(), before_free - len(chain))

        freed = fs.delete_root_file(name)
        self.assertEqual(freed, chain)
        self.assertIsNone(fs.root_file_metadata(name))
        self.assertEqual(fs.free_data_clusters(), before_free)

        new_chain = fs.write_root_file(name, b"new runtime bytes")
        self.assertEqual(fs.read_root_file(name), b"new runtime bytes")
        self.assertEqual(fs.free_data_clusters(), before_free - len(new_chain))

    def test_dynamic_file_growth_sparse_write_and_resize_preserve_fat_copies(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"GROWTH  BIN"
        before_free = fs.free_data_clusters()

        first_chain = fs.write_root_file(name, b"A" * 600)
        self.assertEqual(len(first_chain), 2)

        grown_chain = fs.write_root_file_at(name, 1500, b"END")
        grown = fs.read_root_file(name)
        self.assertEqual(len(grown), 1503)
        self.assertEqual(grown[:600], b"A" * 600)
        self.assertEqual(grown[600:1500], b"\0" * 900)
        self.assertEqual(grown[1500:], b"END")
        self.assertEqual(fs.free_data_clusters(), before_free - len(grown_chain))

        shrunk_chain = fs.resize_root_file(name, 513)
        shrunk = fs.read_root_file(name)
        self.assertEqual(len(shrunk), 513)
        self.assertEqual(shrunk, b"A" * 513)
        self.assertEqual(fs.free_data_clusters(), before_free - len(shrunk_chain))
        self.assertLess(len(shrunk_chain), len(grown_chain))

        emptied_chain = fs.resize_root_file(name, 0)
        self.assertEqual(emptied_chain, ())
        self.assertEqual(fs.read_root_file(name), b"")
        self.assertEqual(fs.free_data_clusters(), before_free)
        fs.validate_fat_copies_match()

    def test_dynamic_truncate_rejects_corrupt_chain_without_partial_free(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"CORRUPT BIN"
        chain = fs.write_root_file(name, b"C" * 900)
        fs.set_fat_entry(chain[-1], chain[0])
        corrupt_entries = {cluster: fs.fat_entry(cluster) for cluster in chain}

        with self.assertRaisesRegex(ValueError, "contains a loop"):
            fs.truncate_root_file(name)

        for cluster, value in corrupt_entries.items():
            self.assertEqual(fs.fat_entry(cluster), value)
        self.assertEqual(fs.root_file_metadata(name)["size"], 900)

    def test_host_image_mutator_refuses_writes_to_protected_entries(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)

        for name in make_wad_image.PROTECTED_ROOT_NAMES:
            with self.subTest(name=name):
                with self.assertRaisesRegex(ValueError, "protected WAD/ELF"):
                    fs.write_root_file(name, b"mutated")
                with self.assertRaisesRegex(ValueError, "protected WAD/ELF"):
                    fs.truncate_root_file(name)
                with self.assertRaisesRegex(ValueError, "protected WAD/ELF"):
                    fs.delete_root_file(name)

    def test_checker_rejects_baseline_comparison_without_requested_entries(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "requires --require-default"):
            check_persistence.validate_image(path, baseline_image=path)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "requires --require-default"):
            check_persistence.validate_image(path, reboot_baseline_image=path)

    def test_checker_rejects_requested_entry_unchanged_from_baseline(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"use_mouse\t\t1\nscreenblocks\t\t9\n",
        )
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "DEFAULT.CFG did not change"):
            check_persistence.validate_image(path, baseline_image=path, require_default=True)

    def test_checker_rejects_empty_default_or_non_doom_save(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], b"not a doom save")
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "DEFAULT.CFG is still empty"):
            check_persistence.validate_image(path, require_default=True)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "too small"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_cli_reports_written_state_without_exporting_image_data(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, b"screenblocks\t\t10\n")
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[1], doom_save_payload("REMOTE PROOF"))
        path = self.write_temp_image(image)

        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "tools" / "check_doom_persistence_image.py"),
                "--require-default",
                "--require-save-slot",
                "1",
                "--reboot-baseline-image",
                str(path),
                str(path),
            ],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )

        self.assertIn("DEFAULT.CFG bytes=", result.stdout)
        self.assertIn("DOOMSAV1.DSG bytes=", result.stdout)
        self.assertIn("survived-reboot", result.stdout)
        self.assertIn("REMOTE PROOF", result.stdout)
        self.assertNotIn("IWAD", result.stdout)
        self.assertEqual(result.stderr, "")

    def test_persistence_doc_keeps_dynamic_fs_and_storage_boot_gaps_explicit(self):
        persistent_doc = (ROOT / "docs" / "persistent-fat16.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()

        for phrase in (
            "Writable semantics are still deliberately narrow",
            "root-level 8.3 files",
            "no subdirectories",
            "no rename",
            "no long filenames",
            "no POSIX delete-while-open behavior",
            "broader storage boot",
            "archived",
            "real-WAD cloud",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, persistent_doc)
        self.assertIn("dynamic writable FS", gap_doc)
        self.assertIn("storage boot path", gap_doc)


if __name__ == "__main__":
    unittest.main()
