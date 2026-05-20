import importlib.util
import subprocess
import sys
import tempfile
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

    def test_checker_rejects_baseline_comparison_without_requested_entries(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "requires --require-default"):
            check_persistence.validate_image(path, baseline_image=path)

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
        self.assertIn("REMOTE PROOF", result.stdout)
        self.assertNotIn("IWAD", result.stdout)
        self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
