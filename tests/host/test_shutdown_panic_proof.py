import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import check_shutdown_panic_proof
finally:
    sys.path.pop(0)


CHECKER = TOOLS / "check_shutdown_panic_proof.py"


def status_line(**overrides):
    fields = {
        "panic": "NONE",
        "shutdown": "NONE",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(
        f"{name}={value}" for name, value in fields.items()
    )


def valid_manifest(**phase_overrides):
    phases = {
        "panic": {
            "status": "status.panic.txt",
            "trigger": "kernel-proof-invalid-opcode",
            "evidence": "status-before-cleanup",
            "monitor_quit_evidence": False,
            "cleanup": "monitor-quit-after-evidence",
        },
        "shutdown-halt": {
            "status": "status.shutdown-halt.txt",
            "trigger": "kernel-proof-halt",
            "evidence": "status-before-cleanup",
            "monitor_quit_evidence": False,
            "cleanup": "monitor-quit-after-evidence",
        },
        "shutdown-reboot": {
            "status": "status.shutdown-reboot.txt",
            "trigger": "kernel-proof-reboot-request",
            "evidence": "status-before-reset",
            "monitor_quit_evidence": False,
            "cleanup": "guest-reset-or-exit-after-evidence",
            "guest_exit_expected": True,
            "guest_exit_observed": True,
        },
        "shutdown-poweroff": {
            "status": "status.shutdown-poweroff.txt",
            "trigger": "kernel-proof-acpi-poweroff",
            "evidence": "status-before-poweroff",
            "monitor_quit_evidence": False,
            "cleanup": "guest-reset-or-exit-after-evidence",
            "guest_exit_expected": True,
            "guest_exit_observed": True,
        },
    }
    for phase, overrides in phase_overrides.items():
        phases[phase].update(overrides)
    return {
        "schema": check_shutdown_panic_proof.SCHEMA,
        "source": "github-actions-disposable-vm",
        "no_local_qemu": True,
        "artifact_policy": {
            "contains_wad_data": False,
            "contains_disk_image": False,
            "contains_pixel_dump": False,
            "contains_raw_audio": False,
        },
        "phases": phases,
    }


def write_valid_artifact(path):
    (path / "status.panic.txt").write_text(
        status_line(
            panic="KEXC",
            shutdown="NONE",
            fault="00000006/FFFFFFFF/00012345/00000008/0009FFF0/00000010/00000000/00000000/00000000/00000000/00000000",
        )
    )
    (path / "status.shutdown-halt.txt").write_text(
        status_line(panic="NONE", shutdown="HALT")
    )
    (path / "status.shutdown-reboot.txt").write_text(
        status_line(panic="NONE", shutdown="REBOOT")
    )
    (path / "status.shutdown-poweroff.txt").write_text(
        status_line(panic="NONE", shutdown="POWEROFF")
    )
    (path / "shutdown-panic-proof.json").write_text(
        json.dumps(valid_manifest(), indent=2) + "\n"
    )


class ShutdownPanicProofTests(unittest.TestCase):
    def test_repo_contract_is_machine_checked(self):
        check_shutdown_panic_proof.validate_repo_contract(ROOT)

    def test_valid_artifact_dir_passes(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)

            check_shutdown_panic_proof.validate_artifact_dir(artifact)

    def test_cli_validates_artifact_dir(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)

            result = subprocess.run(
                [sys.executable, str(CHECKER), str(artifact)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("shutdown/panic proof check OK", result.stdout)

    def test_rejects_missing_status_artifact(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "status.panic.txt").unlink()

            with self.assertRaisesRegex(AssertionError, "missing expected panic"):
                check_shutdown_panic_proof.validate_artifact_dir(artifact)

    def test_rejects_monitor_quit_as_evidence(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "shutdown-panic-proof.json").write_text(
                json.dumps(
                    valid_manifest(
                        panic={
                            "trigger": "kernel-proof-invalid-opcode",
                            "evidence": "monitor-quit",
                            "monitor_quit_evidence": True,
                        }
                    ),
                    indent=2,
                )
                + "\n"
            )

            with self.assertRaisesRegex(AssertionError, "panic evidence"):
                check_shutdown_panic_proof.validate_artifact_dir(artifact)

    def test_rejects_final_only_monitor_quit_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "status.shutdown-halt.txt").write_text(
                status_line(panic="NONE", shutdown="NONE")
            )

            with self.assertRaisesRegex(AssertionError, "shutdown-halt shutdown="):
                check_shutdown_panic_proof.validate_artifact_dir(artifact)

    def test_rejects_panic_without_fault_frame(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "status.panic.txt").write_text(
                status_line(panic="KEXC", shutdown="NONE")
            )

            with self.assertRaisesRegex(AssertionError, "nonzero fault"):
                check_shutdown_panic_proof.validate_artifact_dir(artifact)

    def test_rejects_reboot_without_guest_exit_observed(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "shutdown-panic-proof.json").write_text(
                json.dumps(
                    valid_manifest(
                        **{
                            "shutdown-reboot": {
                                "guest_exit_observed": False,
                            }
                        }
                    ),
                    indent=2,
                )
                + "\n"
            )

            with self.assertRaisesRegex(AssertionError, "guest_exit_observed"):
                check_shutdown_panic_proof.validate_artifact_dir(artifact)

    def test_rejects_forbidden_payload_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "renamed-disk.log").write_bytes(
                b"FAT16" + b"\0" * 505 + b"\x55\xaa"
            )

            with self.assertRaisesRegex(AssertionError, "forbidden raw FAT"):
                check_shutdown_panic_proof.validate_artifact_dir(artifact)


if __name__ == "__main__":
    unittest.main()
