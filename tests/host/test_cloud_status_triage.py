import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import triage_cloud_status
finally:
    sys.path.pop(0)


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
        "doompresent": "00000008",
        "doompal": "00000001",
        "doomframe": "00000002",
        "gameplay": "OK",
        "gstate": "00000000",
        "gmap": "00000101",
        "gtic": "00000020",
        "leveltime": "00000020",
        "gflags": "00000001",
        "pflags": "0000003F",
        "pdelta": "00000100",
        "keyirq": "00000002",
        "keyqueue": "00000002",
        "keypoll": "00000002",
        "gfx": "OK",
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


class CloudStatusTriageTests(unittest.TestCase):
    def classify(self, **overrides):
        fields = triage_cloud_status.parse_status(status_line(**overrides))
        return triage_cloud_status.classify(fields)

    def test_triage_rules_cover_next_cloud_failure_classes(self):
        names = {rule.name for rule in triage_cloud_status.TRIAGE_RULES}
        for expected in (
            "exec-not-attempted",
            "exec-failed",
            "doom-user-fault",
            "missing-wad-open-read",
            "frames-no-gameplay",
            "input-no-effect",
            "artifact-proof-failure",
            "kernel-panic",
            "os-shutdown-requested",
            "playability-status-green",
        ):
            with self.subTest(expected=expected):
                self.assertIn(expected, names)

        doc = (ROOT / "docs" / "cloud-status-triage.md").read_text()
        for expected in names:
            with self.subTest(doc=expected):
                self.assertIn(f"`{expected}`", doc)

    def test_classifies_exec_not_attempted(self):
        primary, notes = self.classify(
            execsys="00000000/00000000/00000000/00000000/00000000/00000000",
            target="FFFFFFFF",
            argv0="00000000",
            doomrun="WAIT",
        )

        self.assertEqual(primary, "exec-not-attempted")
        self.assertIn("target=FFFFFFFF", notes[0])

    def test_classifies_failed_exec_handoff(self):
        primary, notes = self.classify(
            execsys="00000001/00000000/00000001/00000000/00000000/00000000",
            target="FFFFFFFF",
            argv0="00000000",
        )

        self.assertEqual(primary, "exec-failed")
        self.assertIn("failures=0x1", notes[0])

    def test_classifies_doom_fault_before_wad_io(self):
        primary, notes = self.classify(
            doomrun="FAULT",
            doomfault="018F0000",
            doomfaultip="0102F190",
            doomfaultv="0000000E",
            doomfaulterr="00000004",
            fault="0000000E/00000004/0102F190/0000001B/0100FFE0/00000023/018F0000/00000002/00000002/00000001/00000003",
            doomopen="FAIL",
            doomread="FAIL",
        )

        self.assertEqual(primary, "doom-user-fault")
        rendered = "\n".join(notes)
        self.assertIn("doomfaultip(EIP)=0102F190", rendered)
        self.assertIn("missing-wad-open-read", rendered)

    def test_classifies_kernel_panic_before_other_lanes(self):
        primary, notes = self.classify(
            panic="KEXC",
            fault="0000000D/00000000/00010500/00000008/0006FFE0/00000010/00000000/FFFFFFFF/00000000/00000000/FFFFFFFF",
            execsys="00000000/00000000/00000000/00000000/00000000/00000000",
        )

        self.assertEqual(primary, "kernel-panic")
        self.assertIn("panic=KEXC", notes[0])

    def test_classifies_os_shutdown_request(self):
        primary, notes = self.classify(shutdown="HALT")

        self.assertEqual(primary, "os-shutdown-requested")
        self.assertIn("shutdown=HALT", notes[0])

    def test_classifies_wad_open_read_failure_after_doom_is_running(self):
        primary, notes = self.classify(
            doomopen="FAIL",
            doomread="FAIL",
            doomerr="00000002",
            doomlog="W_GetNumForName",
        )

        self.assertEqual(primary, "missing-wad-open-read")
        self.assertIn("doomerr=00000002", notes[0])

    def test_classifies_frames_without_gameplay(self):
        primary, notes = self.classify(gameplay="WAIT", leveltime="00000000")

        self.assertEqual(primary, "frames-no-gameplay")
        self.assertIn("doompresent=00000008", notes[0])

    def test_classifies_input_without_game_state_effect(self):
        primary, notes = self.classify(pdelta="00000000")

        self.assertEqual(primary, "input-no-effect")
        self.assertIn("keyirq=00000002", notes[0])

    def test_classifies_green_status_as_needing_full_proof_gates(self):
        primary, notes = self.classify()

        self.assertEqual(primary, "playability-status-green")
        self.assertIn("no obvious first-failure", notes[0])

    def test_cli_prints_primary_and_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            status_path = Path(tmp) / "status.txt"
            status_path.write_text(
                status_line(
                    doomrun="FAULT",
                    doomfault="018F0000",
                    doomfaultip="0102F190",
                    doomfaultv="0000000E",
                    doomfaulterr="00000004",
                )
            )
            result = subprocess.run(
                [sys.executable, str(TOOLS / "triage_cloud_status.py"), str(status_path)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("primary: doom-user-fault", result.stdout)
        self.assertIn("summary:", result.stdout)
        self.assertIn("next: Symbolize doomfaultip", result.stdout)


if __name__ == "__main__":
    unittest.main()
