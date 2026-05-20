import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"

sys.path.insert(0, str(TOOLS))
try:
    import check_real_wad_proof
finally:
    sys.path.pop(0)

HUMAN_TOOL = TOOLS / "check_human_playability_proof.py"
human_spec = importlib.util.spec_from_file_location("check_human_playability_proof", HUMAN_TOOL)
check_human_playability_proof = importlib.util.module_from_spec(human_spec)
human_spec.loader.exec_module(check_human_playability_proof)


def status_line(**overrides):
    fields = {
        "exec": "OK",
        "path": "DOOM.ELF",
        "execsys": "00000001/00000001/00000000/00000001/00000001/00000000",
        "target": "00000003",
        "argv0": "0100F000",
        "doom": "OK",
        "doomrun": "RUN",
        "doomopen": "OK",
        "doomread": "OK",
        "doomwrite": "00000000",
        "doomseek": "00000020",
        "doomclose": "00000001",
        "doomsbrk": "00000010",
        "doomerr": "00000000",
        "doomexit": "00000000",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "panic": "NONE",
        "shutdown": "NONE",
        "doommode": "00000000:00000000",
        "doomlog": "ready",
        "doompresent": "00000308",
        "doompal": "89ABCDEF",
        "doomframe": "13572468",
        "doomnonzero": "00002000",
        "doomcolors": "00000080",
        "doomsamp": "00000001:00000002:00000003",
        "gameplay": "OK",
        "gstate": "00000000",
        "gmap": "00000101",
        "gtic": "000002E5",
        "leveltime": "000002E5",
        "gflags": "00000001",
        "gaction": "00000000",
        "pflags": "0000003F",
        "pbuttons": "00000000",
        "ppos": "00010000:00020000",
        "pdelta": "00000100",
        "doomsound": "00000000",
        "sfxmix": "00000000",
        "voices": "00000000",
        "audioirq": "00000000",
        "ack8": "00000000",
        "ack16": "00000000",
        "refill": "00000000",
        "half": "00000000",
        "mixwrap": "00000000",
        "mixover": "00000000",
        "mixunder": "00000000",
        "mixclip": "00000000",
        "steal": "00000000",
        "pitchclamp": "00000000",
        "panclamp": "00000000",
        "musicvoices": "00000000",
        "musicmix": "00000000",
        "musicloop": "00000000",
        "audio": "NONE",
        "keyirq": "00000004",
        "keyqueue": "00000004",
        "keypoll": "00000004",
        "mouse": "NONE",
        "mouseirq": "00000000",
        "mousepkt": "00000000",
        "mousepoll": "00000000",
        "gfx": "OK",
        "fb": "M13",
        "preempt": "00000000",
        "pattempt": "00000010",
        "pskip": "00000010",
        "pself": "OK",
        "pg": "ON",
        "pmm": "OK",
        "vmm": "OK",
        "libc": "OK",
        "c": "OK",
        "usr": "OK",
        "wad": "OK",
        "lmp": "OK",
        "heap": "OK",
        "free": "00780000",
        "ticks": "00000300",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(
        f"{name}={value}" for name, value in fields.items()
    )


def baseline_status():
    return status_line(
        gtic="00000010",
        leveltime="00000010",
        keyirq="00000001",
        keyqueue="00000001",
        keypoll="00000001",
        pflags="00000001",
        pdelta="00000001",
        gflags="00000001",
    )


def validate_real_wad_status(status):
    check_real_wad_proof.validate_status(
        status,
        baseline_status=baseline_status(),
        fire_status=status_line(pflags="00000005"),
        movement_status=status_line(pflags="00000023"),
        use_status=status_line(pflags="00000009"),
        menu_status=status_line(pflags="00000011", gflags="00000001"),
    )


class ProofStatusContractTests(unittest.TestCase):
    def test_real_wad_checker_accepts_realistic_phase_snapshots(self):
        baseline = status_line(
            gtic="00000010",
            leveltime="00000010",
            keyirq="00000001",
            keyqueue="00000001",
            keypoll="00000001",
            pflags="00000001",
            pdelta="00000001",
            gflags="00000001",
        )
        check_real_wad_proof.validate_status(
            status_line(),
            baseline_status=baseline,
            fire_status=status_line(pflags="00000005"),
            movement_status=status_line(pflags="00000023"),
            use_status=status_line(pflags="00000009"),
            menu_status=status_line(pflags="00000011", gflags="00000001"),
        )

    def test_real_wad_checker_rejects_weak_system_or_fake_debug_status(self):
        invalid = (
            status_line(execsys="00000001/00000000/00000000/00000000/00000000/00000000"),
            status_line(doomrun="WAIT"),
            status_line(doomerr="00000001"),
            status_line(vmm="FAIL"),
            status_line(pself="FAIL"),
            status_line(audio="EMU"),
            status_line(pattempt="00000000"),
            status_line(doomfaultip="0102F190"),
            status_line(doomfaultv="0000000D"),
            status_line(doomfaulterr="00000004"),
            status_line(fault="0000000E/00000004/0102F190/0000001B/0100FFE0/00000023/018F0000/00000002/00000002/00000001/00000003"),
            status_line(panic="KEXC"),
            status_line(shutdown="HALT"),
            status_line() + " keyirq=00000005",
        )
        for status in invalid:
            with self.subTest(status=status):
                with self.assertRaises(AssertionError):
                    validate_real_wad_status(status)

    def test_real_wad_checker_requires_all_scripted_phase_snapshots(self):
        with self.assertRaisesRegex(AssertionError, "missing required scripted status"):
            check_real_wad_proof.validate_status(
                status_line(),
                baseline_status=baseline_status(),
                fire_status=status_line(pflags="00000005"),
                movement_status=status_line(pflags="00000023"),
                use_status=status_line(pflags="00000009"),
            )

    def test_real_wad_cli_auto_discovers_phase_status_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            final = tmpdir / "status.txt"
            final.write_text(status_line())
            (tmpdir / "status.early.txt").write_text(
                status_line(
                    gtic="00000010",
                    leveltime="00000010",
                    keyirq="00000001",
                    keyqueue="00000001",
                    keypoll="00000001",
                )
            )
            (tmpdir / "status.after-fire.txt").write_text(status_line(pflags="00000005"))
            (tmpdir / "status.after-move.txt").write_text(status_line(pflags="00000023"))
            (tmpdir / "status.after-use.txt").write_text(status_line(pflags="00000009"))
            (tmpdir / "status.after-menu.txt").write_text(
                status_line(pflags="00000011", gflags="00000001")
            )

            result = subprocess.run(
                [sys.executable, str(TOOLS / "check_real_wad_proof.py"), str(final)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("real-WAD proof OK", result.stdout)

    def test_real_wad_cli_rejects_final_only_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            final = Path(tmp) / "status.txt"
            final.write_text(status_line())

            result = subprocess.run(
                [sys.executable, str(TOOLS / "check_real_wad_proof.py"), str(final)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required scripted status snapshot", result.stderr)

    def test_real_wad_cli_summarizes_failed_cloud_boot_fields(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            final = tmpdir / "status.txt"
            final.write_text(
                status_line(
                    target="FFFFFFFF",
                    doomrun="FAULT",
                    doomfault="018F0000",
                    doomfaultip="0102F190",
                    doomfaultv="0000000E",
                    doomfaulterr="00000004",
                    fault="0000000E/00000004/0102F190/0000001B/0100FFE0/00000023/018F0000/00000002/00000002/00000001/00000003",
                    doomopen="FAIL",
                    doomread="FAIL",
                    gameplay="WAIT",
                    gfx="FAIL",
                    usr="FAIL",
                )
            )
            (tmpdir / "status.early.txt").write_text(baseline_status())
            (tmpdir / "status.after-fire.txt").write_text(status_line(pflags="00000005"))
            (tmpdir / "status.after-move.txt").write_text(status_line(pflags="00000023"))
            (tmpdir / "status.after-use.txt").write_text(status_line(pflags="00000009"))
            (tmpdir / "status.after-menu.txt").write_text(
                status_line(pflags="00000011", gflags="00000001")
            )

            result = subprocess.run(
                [sys.executable, str(TOOLS / "check_real_wad_proof.py"), str(final)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("doomrun= must be RUN, got 'FAULT'", result.stderr)
        self.assertIn("status summary:", result.stderr)
        self.assertIn("target=FFFFFFFF", result.stderr)
        self.assertIn("doomrun=FAULT", result.stderr)
        self.assertIn("doomfault=018F0000", result.stderr)
        self.assertIn("doomfaultip=0102F190", result.stderr)
        self.assertIn("doomfaultv=0000000E", result.stderr)
        self.assertIn("doomfaulterr=00000004", result.stderr)
        self.assertIn("fault=0000000E/00000004/0102F190", result.stderr)
        self.assertIn("doomopen=FAIL", result.stderr)
        self.assertIn("usr=FAIL", result.stderr)

    def test_human_checker_rejects_duplicate_status_fields(self):
        with self.assertRaisesRegex(AssertionError, "duplicate keyirq"):
            check_human_playability_proof.validate_status(
                status_line(keyirq="00000002") + " keyirq=00000003"
            )

    def test_workflow_artifacts_are_status_only_for_real_wad_proof(self):
        workflow = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        self.assertIn("--baseline build/status.early.txt", workflow)
        self.assertIn("--fire build/status.after-fire.txt", workflow)
        self.assertIn("--movement build/status.after-move.txt", workflow)
        self.assertIn("--use build/status.after-use.txt", workflow)
        self.assertIn("--menu build/status.after-menu.txt", workflow)
        upload_block = workflow.split("Upload non-copyright diagnostic artifacts", 1)[1]
        for forbidden in ("build/disk.img", "build/gfx.bin", "build/vga*.txt", "DOOM1.WAD"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, upload_block)


if __name__ == "__main__":
    unittest.main()
