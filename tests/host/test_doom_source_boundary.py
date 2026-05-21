import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "check_doom_source_boundary.py"


class DoomSourceBoundaryCheckerTests(unittest.TestCase):
    def run_checker(self, root, *args, expected_returncode=0):
        result = subprocess.run(
            ["python3", str(TOOL), "--root", str(root), *args],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(
            result.returncode,
            expected_returncode,
            result.stdout + result.stderr,
        )
        return result

    def run_git(self, root, *args):
        return subprocess.run(
            ["git", *args],
            cwd=root,
            capture_output=True,
            text=True,
            check=True,
        )

    def make_minimal_repo(self, tmpdir):
        root = Path(tmpdir)
        doom_src = root / "third_party" / "doom" / "linuxdoom-1.10"
        doom_src.mkdir(parents=True)
        (root / "third_party" / "doom" / "ORIGIN.md").write_text(
            "# id Software Doom Source\n"
        )
        (doom_src / "d_main.c").write_text("void D_DoomMain(void) {}\n")
        (root / "doom_port").mkdir()
        (root / "doom_port" / "platform.c").write_text("void I_Init(void) {}\n")

        self.run_git(root, "init", "-q")
        self.run_git(root, "add", ".")
        self.run_git(
            root,
            "-c",
            "user.name=Doom Boundary Test",
            "-c",
            "user.email=doom-boundary@example.invalid",
            "-c",
            "commit.gpgsign=false",
            "commit",
            "-qm",
            "import doom",
        )
        return root

    def test_current_repo_boundary_is_clean(self):
        result = self.run_checker(ROOT, "--json")
        report = json.loads(result.stdout)

        self.assertTrue(report["ok"], report["violations"])
        self.assertEqual(report["vendor_head"]["status"], "clean")
        self.assertEqual(report["vendor_platform_code"]["status"], "clean")
        self.assertEqual(report["git_assets"]["status"], "clean")
        self.assertGreaterEqual(report["vendor_platform_code"]["scanned_files"], 120)
        self.assertGreaterEqual(report["git_assets"]["indexed_paths"], 100)

    def test_checker_catches_synthetic_tracked_vendor_modification(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = self.make_minimal_repo(tmpdir)
            vendor_file = root / "third_party" / "doom" / "linuxdoom-1.10" / "d_main.c"
            vendor_file.write_text("void D_DoomMain(void) { /* patched */ }\n")

            result = self.run_checker(root, expected_returncode=1)

        self.assertIn(
            "third_party/doom/linuxdoom-1.10/d_main.c",
            result.stderr,
        )
        self.assertIn("differs from HEAD", result.stderr)

    def test_checker_catches_os_port_code_inside_vendor_tree(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = self.make_minimal_repo(tmpdir)
            port_file = root / "third_party" / "doom" / "linuxdoom-1.10" / "vibe_os_port.c"
            port_file.write_text('#include "vibe_os.h"\nvoid bridge(void) { vibe_syscall0(1); }\n')

            result = self.run_checker(root, expected_returncode=1)

        self.assertIn("vibe_os_port.c:1", result.stderr)
        self.assertIn("OS-facing port token", result.stderr)

    def test_checker_catches_staged_forbidden_asset_paths(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = self.make_minimal_repo(tmpdir)
            wad_path = root / "proof" / "DOOM1.WAD"
            wad_path.parent.mkdir()
            wad_path.write_bytes(b"IWAD synthetic test payload")
            self.run_git(root, "add", str(wad_path.relative_to(root)))

            result = self.run_checker(root, expected_returncode=1)

        self.assertIn("proof/DOOM1.WAD", result.stderr)
        self.assertIn("forbidden WAD/game-data path", result.stderr)

    def test_checker_catches_renamed_staged_wad_magic(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = self.make_minimal_repo(tmpdir)
            payload = root / "proof" / "renamed.payload"
            payload.parent.mkdir()
            payload.write_bytes(b"PWAD synthetic test payload")
            self.run_git(root, "add", str(payload.relative_to(root)))

            result = self.run_checker(root, expected_returncode=1)

        self.assertIn("proof/renamed.payload", result.stderr)
        self.assertIn("renamed WAD data is staged or committed", result.stderr)


if __name__ == "__main__":
    unittest.main()
