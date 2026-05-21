import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import check_vm_safety_contract
finally:
    sys.path.pop(0)


class VmSafetyContractTests(unittest.TestCase):
    def test_repo_contract_is_machine_checked(self):
        check_vm_safety_contract.validate_repo_contract(ROOT)

    def test_cli_reports_contract_success(self):
        result = subprocess.run(
            [sys.executable, str(TOOLS / "check_vm_safety_contract.py")],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("VM safety contract OK", result.stdout)

    def test_cloud_interactive_runbooks_are_machine_checked(self):
        check_vm_safety_contract.validate_cloud_interactive_runbooks(ROOT)
        cloud = (ROOT / "docs" / "play.md").read_text()

        for needle in (
            "CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC",
            "CLOUD_PLAYTEST_REMOTE_QEMU_ONLY",
            "CLOUD_PLAYTEST_FORBIDDEN_UPLOADS",
            "CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST",
            "./tools/play_now_remote.sh",
            "http://127.0.0.1:6080/vnc.html?autoconnect=1",
            "Never transfer these from the remote host",
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, cloud)

        script = (ROOT / "tools" / "play_now_remote.sh").read_text()
        for needle in (
            "Refusing to run QEMU on macOS",
            'ALLOW_LOCAL_VM:-0',
            "qemu-system-x86_64",
            'NOVNC_WEB_ROOTS=(',
            'resolve_novnc_web_root',
            'websockify --web="$NOVNC_WEB_ROOT_RESOLVED"',
            'VNC_DISPLAY="${VNC_DISPLAY:-1}"',
            'NOVNC_PORT="${NOVNC_PORT:-6080}"',
            '-display "vnc=127.0.0.1:$VNC_DISPLAY"',
            '127.0.0.1:$((5900 + VNC_DISPLAY))',
            '/vnc.html?autoconnect=1',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, script)

    def test_cloud_play_now_workflow_is_dry_run_only(self):
        check_vm_safety_contract.validate_repo_contract(ROOT)
        workflow = (ROOT / ".github" / "workflows" / "cloud-play-now-preflight.yml").read_text()

        for needle in (
            "workflow_dispatch:",
            "NOVNC_PORT: ${{ inputs.novnc_port }}",
            "./tools/play_now_remote.sh \"${args[@]}\"",
            "dry-run: QEMU was not launched",
            "python3 tools/check_vm_safety_contract.py",
            "VIBE_REPO=${{ github.repository }} VIBE_REF=${{ github.ref_name }} ./tools/play_now_codespaces.sh",
            "VIBE_REPO=${{ github.repository }} VIBE_REF=${{ github.ref_name }} ./tools/play_now_codespaces.sh --web-url",
            "tools/play_now_cloud_shell.sh",
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, workflow)

        for forbidden in (
            "actions/upload-artifact",
            "make DOOM_WAD",
            "DOOM1.WAD",
            "build/disk.img",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, workflow)

    def test_cloud_runbook_rejects_unmarked_qemu_commands(self):
        bad = """
CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC
CLOUD_PLAYTEST_REMOTE_QEMU_ONLY
CLOUD_PLAYTEST_FORBIDDEN_UPLOADS
CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST

```sh
qemu-system-x86_64 -drive file=build/disk.img
```
"""
        with self.assertRaisesRegex(AssertionError, "remote-only sentinel"):
            check_vm_safety_contract.validate_cloud_runbook_text(bad, "bad runbook")

    def test_cloud_runbook_rejects_local_mac_qemu_opt_in_commands(self):
        bad = """
CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC
CLOUD_PLAYTEST_REMOTE_QEMU_ONLY
CLOUD_PLAYTEST_FORBIDDEN_UPLOADS
CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST

```sh
make ALLOW_LOCAL_VM=1 smoke
```
"""
        with self.assertRaisesRegex(AssertionError, "local Mac QEMU"):
            check_vm_safety_contract.validate_cloud_runbook_text(bad, "bad runbook")

    def test_cloud_runbook_rejects_forbidden_payload_transfers(self):
        bad = """
CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC
CLOUD_PLAYTEST_REMOTE_QEMU_ONLY
CLOUD_PLAYTEST_FORBIDDEN_UPLOADS
CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST

```sh
scp "$VIBE_CLOUD_HOST:/tmp/DOOM1.WAD" ./DOOM1.WAD
rsync -av "$VIBE_CLOUD_HOST:~/vibe-os-cloud-playtest/build/disk.img" .
```
"""
        with self.assertRaisesRegex(AssertionError, "forbidden WAD/disk/pixel/raw-audio"):
            check_vm_safety_contract.validate_cloud_runbook_text(bad, "bad runbook")

    def test_kernel_writes_panic_and_shutdown_status_before_stopping(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        panic_path = kernel.split(".not_expected_user_fault:", 1)[1].split("doom_user_fault:", 1)[0]
        reboot_path = kernel.split(".reboot:", 1)[1].split(".halt:", 1)[0]
        halt_path = kernel.split(".halt:", 1)[1].split(".halt_loop:", 1)[0]
        status_writer = kernel.split("write_smoke_status:", 1)[1].split("smoke_copy_string:", 1)[0]

        self.assertIn("mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION", panic_path)
        self.assertIn("call write_smoke_status", panic_path)
        self.assertLess(
            panic_path.index("mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION"),
            panic_path.index("call write_smoke_status"),
        )
        self.assertIn("mov dword [shutdown_state], SHUTDOWN_REBOOT", reboot_path)
        self.assertIn("call write_smoke_status", reboot_path)
        self.assertIn("mov dword [shutdown_state], SHUTDOWN_HALT", halt_path)
        self.assertIn("call write_smoke_status", halt_path)
        self.assertIn("mov dword [shutdown_state], SHUTDOWN_POWEROFF", kernel)
        self.assertIn("acpi_poweroff:", kernel)
        self.assertIn('smoke_panic_text db " panic="', kernel)
        self.assertIn('smoke_shutdown_text db " shutdown="', kernel)
        self.assertIn("mov edx, [fault_eip]", status_writer)
        self.assertIn("mov edx, [fault_cr2]", status_writer)

    def test_make_test_stays_host_only_and_vm_targets_require_opt_in(self):
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("ALLOW_LOCAL_VM ?= 0", makefile)
        self.assertIn("KERNEL_EXTRA_NASMFLAGS ?=", makefile)
        self.assertIn("shutdown-panic-proof-check:", makefile)
        self.assertIn("tools/check_shutdown_panic_proof.py --repo-contract", makefile)
        for needle in (
            'grep -q "kreloc=LOW"',
            'grep -q "kerneip="',
            'grep -q "kernesp="',
            'grep -q "kerncr3=00090000"',
            'grep -q "kernvirt=00010000"',
            'grep -q "kernphys=00010000"',
            'grep -q "vmmhi=OK"',
            'grep -q "vmmhva=C0000000"',
            'grep -q "vmmhpa="',
            'grep -q "vmmhpt="',
            'grep -q "vmmhfree="',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, makefile)
        for target in ("run", "run-headless", "smoke"):
            with self.subTest(target=target):
                line = next(line for line in makefile.splitlines() if line.startswith(f"{target}:"))
                self.assertIn("vm-consent", line)

        test_block = makefile.split("test:", 1)[1].split("doom-compile:", 1)[0].lower()
        self.assertNotIn("qemu", test_block)

    def test_cloud_artifacts_are_diagnostics_not_raw_vm_payloads(self):
        for workflow_name in ("os-smoke.yml", "real-wad-smoke.yml"):
            workflow = (ROOT / ".github" / "workflows" / workflow_name).read_text()
            upload = workflow.split("uses: actions/upload-artifact@v4", 1)[1]
            with self.subTest(workflow=workflow_name):
                self.assertIn("build/status*.txt", upload)
                self.assertIn("build/status*.bin", upload)
                self.assertIn("build/*.log", upload)
                self.assertNotIn("build/disk.img", upload)
                self.assertNotIn("build/gfx.bin", upload)
                self.assertNotIn("build/vga.txt", upload)
                self.assertNotIn("DOOM1.WAD", upload)

    def test_os_smoke_has_opt_in_shutdown_panic_proof_mode(self):
        workflow = (ROOT / ".github" / "workflows" / "os-smoke.yml").read_text()
        for needle in (
            "shutdown_panic_proof:",
            "KERNEL_EXTRA_NASMFLAGS=\"-D ${define}\"",
            "run_phase panic SHUTDOWN_PANIC_PROOF_PANIC status.panic.txt",
            "run_phase shutdown-halt SHUTDOWN_PANIC_PROOF_HALT status.shutdown-halt.txt",
            "run_phase shutdown-reboot SHUTDOWN_PANIC_PROOF_REBOOT status.shutdown-reboot.txt status-before-reset",
            "run_phase shutdown-poweroff SHUTDOWN_PANIC_PROOF_POWEROFF status.shutdown-poweroff.txt status-before-poweroff",
            "SMOKE_EXPECT_GUEST_EXIT=\"$expect_guest_exit\"",
            "shutdown-panic-proof.json",
            "--manifest build/shutdown-panic-proof/shutdown-panic-proof.json",
            "build/shutdown-panic-proof",
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, workflow)


if __name__ == "__main__":
    unittest.main()
