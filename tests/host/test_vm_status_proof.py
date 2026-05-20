import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import check_vm_status_proof
finally:
    sys.path.pop(0)


def status_line(**overrides):
    fields = {
        "pg": "ON",
        "pmm": "OK",
        "vmm": "OK",
        "vmmhi": "OK",
        "vmmhva": "C0000000",
        "vmmhpa": "00123000",
        "vmmhpt": "00124000",
        "vmmhfree": "00124000",
        "exec": "OK",
        "path": "DOOM.ELF",
        "doom": "OK",
        "execsys": "00000001/00000001/00000000/00000001/00000001/00000000",
        "execerr": "00000000",
        "execres": "00000000",
        "target": "00000002",
        "ppid": "00000001",
        "entry": "01000000",
        "stack": "01FFFFE0",
        "argc": "00000001",
        "argv": "01FFFFE4",
        "envp": "01FFFFEC",
        "argv0": "01FFFFF0",
        "envp0": "00000000",
        "argvsrc": "00000002",
        "pself": "OK",
        "preempt": "00000001",
        "pirq": "00000001",
        "pattempt": "00000001",
        "puser": "00000004",
        "pround": "00000001",
        "pctx": "00000004",
        "pfrom": "00000002",
        "pto": "00000003",
        "pkind": "00000002:00000003",
        "peip": "01002000:00E80000",
        "pcr3": "00082000:00083000",
        "pkstk": "00073000:00072000",
        "pspin": "50524546",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{key}={value}" for key, value in fields.items())


class VmStatusProofTests(unittest.TestCase):
    def test_valid_status_proves_vm_exec_and_timer_preemption(self):
        check_vm_status_proof.validate_status(
            status_line(),
            require_exec=True,
            require_preempt=True,
        )
        check_vm_status_proof.validate_status(
            status_line(pspin="4258E795"),
            require_exec=True,
            require_preempt=True,
        )

    def test_rejects_identity_or_unreclaimed_high_mapping(self):
        for overrides, message in (
            ({"vmmhva": "00000000"}, "vmmhva"),
            ({"vmmhpa": "00023000"}, "PMM-managed"),
            ({"vmmhpa": "00124000"}, "different frames"),
            ({"vmmhfree": "00125000"}, "match vmmhpt"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

    def test_rejects_kernel_default_or_same_process_exec_evidence(self):
        for overrides, message in (
            ({"argvsrc": "00000001"}, "user argv-vector"),
            ({"target": "00000001"}, "new process"),
            ({"entry": "00E80000"}, "entry"),
            ({"stack": "00E9FFE0"}, "stack"),
            ({"envp0": "00000001"}, "envp0"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(
                        status_line(**overrides),
                        require_exec=True,
                    )

    def test_rejects_counter_only_preemption(self):
        for overrides, message in (
            ({"pself": "FAIL"}, "pself"),
            ({"pirq": "00000002"}, "pirq"),
            ({"puser": "00000000"}, "puser"),
            ({"pto": "00000002"}, "switch between processes"),
            ({"pkind": "00000002:00000002"}, "Doom and the preempt probe"),
            ({"peip": "01002000:01003000"}, "Doom and the preempt probe"),
            ({"pcr3": "00082000:00082000"}, "address spaces"),
            ({"pkstk": "00073000:00073000"}, "kernel stacks"),
            ({"pspin": "50524545"}, "preempt probe executed"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(
                        status_line(**overrides),
                        require_preempt=True,
                    )

    def test_cli_validates_status_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "status.txt"
            path.write_text(status_line())
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOLS / "check_vm_status_proof.py"),
                    "--require-exec",
                    "--require-preempt",
                    str(path),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("VM status proof OK", result.stdout)

    def test_repo_contract_is_machine_checked(self):
        check_vm_status_proof.validate_repo_contract(ROOT)

    def test_cli_reports_repo_contract_success(self):
        result = subprocess.run(
            [sys.executable, str(TOOLS / "check_vm_status_proof.py"), "--repo-contract"],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("VM status proof contract OK", result.stdout)


if __name__ == "__main__":
    unittest.main()
