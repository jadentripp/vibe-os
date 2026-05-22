import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / "tools" / "run_post_merge_cloud_proof.py"
CHECKER = ROOT / "tools" / "check_post_merge_cloud_artifacts.py"

sys.path.insert(0, str(Path(__file__).resolve().parent))
try:
    from test_remote_playability_runbook import (
        audio_phase_statuses,
        valid_audio_proof_manifest,
        valid_status,
        write_gameplay_proof,
    )
finally:
    sys.path.pop(0)


TEST_SHA = "0123456789abcdef0123456789abcdef01234567"
FULL_DOOM_SOURCE_DIRTY_RECT = "00000000:00000000:00000140:000000C8:0000FA00"


def run_identity(workflow: str, artifact: str, sha: str = TEST_SHA) -> dict:
    return {
        "schema": "cloud-proof-run-v1",
        "workflow": workflow,
        "artifact": artifact,
        "ref": "main",
        "sha": sha,
        "run_id": "123456789",
        "run_attempt": "1",
        "runner": "github-actions-ubuntu",
        "local_qemu_required": False,
        "artifact_policy": {
            "status_only": True,
            "contains_wad_data": False,
            "contains_disk_image": False,
            "contains_screenshots": False,
            "contains_pixels": False,
            "contains_raw_audio": False,
        },
    }


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def status_for_post_merge_fixture(status: str) -> str:
    fixed = status.replace(
        "fbdirty=00000000:00000000:00000140:000000C8:00010000",
        f"fbdirty={FULL_DOOM_SOURCE_DIRTY_RECT}",
    )
    fields = {
        key: value
        for token in fixed.split()
        if "=" in token
        for key, value in [token.split("=", 1)]
    }
    if "pcmqueue" not in fields:
        musicbuf = fields.get("musicbuf", "00000000")
        fixed += f" pcmqueue=00002000:{musicbuf}:00000000:00000000:00000000:{musicbuf}"
    return fixed


def remove_status_field(status: str, field: str) -> str:
    return " ".join(
        token
        for token in status.split()
        if not token.startswith(f"{field}=")
    )


def parse_uefi_debugcon(text: str) -> dict:
    sys.path.insert(0, str(ROOT / "boot" / "uefi"))
    try:
        import ovmf_cloud_proof

        return ovmf_cloud_proof._parse_debugcon_markers(text)
    finally:
        sys.path.pop(0)


def valid_post_merge_audio_proof_manifest() -> dict:
    manifest = valid_audio_proof_manifest()
    status = manifest["status"]
    musicbuf = status.get("musicbuf", "00000000")
    status["pcmqueue"] = f"00002000:{musicbuf}:00000000:00000000:00000000:{musicbuf}"
    os_audio_contract = manifest["continuity"]["os_audio_contract"]
    os_audio_contract["status_fields"]["queue"] = "pcmqueue"
    os_audio_contract["pcm_queue"] = {
        "bounded": True,
        "capacity_bytes": "00002000",
        "covers_ring": True,
        "drop_bytes": "00000000",
        "high_water_bytes": musicbuf,
        "high_water_in_bounds": True,
        "overflow_count": "00000000",
        "queued_bytes": musicbuf,
        "trim_count": "00000000",
    }
    return manifest


def write_os_artifact(path: Path) -> None:
    path.mkdir(parents=True)
    write_json(
        path / "cloud-proof-run.json",
        run_identity("os-smoke.yml", "aurora-os-smoke-proof-status"),
    )
    (path / "status.txt").write_text(status_for_post_merge_fixture(valid_status()))


def write_real_wad_artifact(path: Path) -> None:
    path.mkdir(parents=True)
    write_json(
        path / "cloud-proof-run.json",
        run_identity("real-wad-smoke.yml", "real-wad-smoke-proof-status"),
    )
    for name, status in audio_phase_statuses().items():
        (path / name).write_text(status_for_post_merge_fixture(status))
    write_gameplay_proof(path)
    write_json(path / "audio-proof.json", valid_post_merge_audio_proof_manifest())


def write_uefi_artifact(path: Path) -> None:
    path.mkdir(parents=True)
    write_json(
        path / "cloud-proof-run.json",
        run_identity("uefi-ovmf-proof.yml", "uefi-ovmf-proof-manifests"),
    )
    write_json(
        path / "ovmf-proof-manifest.json",
        {
            "schema": "uefi-ovmf-cloud-proof-v1",
            "mode": "prove",
            "support_claim": "unclaimed",
            "support_row": "SUPPORT[UEFI]",
            "local_qemu_required": False,
            "artifact_policy": {
                "uploads_json_manifests_only": True,
                "uploads_esp_image": False,
                "uploads_efi_binary": False,
                "uploads_pflash_vars": False,
                "uploads_pixel_dump": False,
                "uploads_raw_audio": False,
                "uploads_vm_logs": False,
            },
            "ovmf": {
                "execution": "run",
                "proof": "kernel-entry-marker",
                "exit_boot_services": True,
                "kernel_booted": True,
                "kernel_entry_after_exit_boot_services": True,
                "kernel_status_evidence_required": True,
                "loader_handoff_evidence_required": True,
                "kernel_handoff_after_exit_boot_services": True,
                "loader_handoff_valid": True,
                "loader_handoff_required_flag_mask": "0x0000007F",
                "loader_handoff_evidence": {
                    "step": "kernel-handoff",
                    "status": "attempting",
                    "entry32": "0x00010000",
                    "handoff": "0x00009000",
                    "bootinfo": "0x00007000",
                    "e820": "0x00007100",
                    "tramp32": "0x00008000",
                    "transition64": "0x0000A000",
                    "flags": "0x0000007F",
                    "segments": "0x00000003",
                },
                "kernel_entry_status": "OK",
                "kernel_entry_required_flag_mask": "0x0000007F",
                "kernel_entry_evidence": {
                    "step": "uefi-entry",
                    "status": "OK",
                    "handoff": "0x00009000",
                    "bootinfo": "0x00007000",
                    "e820": "0x00007100",
                    "entry": "0x00010000",
                    "flags": "0x0000007F",
                    "segments": "0x00000003",
                },
                "kernel_handoff": "attempting",
                "debugcon_uploaded": False,
            },
        },
    )


class PostMergeCloudProofTests(unittest.TestCase):
    def run_helper(self, *args, env=None):
        effective_env = os.environ.copy()
        if env:
            effective_env.update(env)
        return subprocess.run(
            [sys.executable, str(HELPER), *args],
            cwd=ROOT,
            env=effective_env,
            capture_output=True,
            text=True,
        )

    def test_dry_run_dispatches_three_sha_pinned_status_only_workflows(self):
        result = self.run_helper(
            "--dry-run",
            "--repo",
            "jadentripp/vibe-os",
            "--ref",
            "main",
            "--commit",
            TEST_SHA,
            "--real-wad-lane",
            "full",
            "--save-slot",
            "0",
            "--download-dir",
            "build/post-merge-main",
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("vibe-os post-merge cloud proof", result.stdout)
        self.assertIn(f"commit: {TEST_SHA}", result.stdout)
        self.assertIn("local VM: refused", result.stdout)
        self.assertIn("status-only downloads; no WADs", result.stdout)
        self.assertIn("biosboot/biosflags/biosentry", result.stdout)
        self.assertIn("faultsrc/faultmode/faultcontain", result.stdout)
        self.assertIn("kblock/ksleep", result.stdout)
        self.assertIn(
            "gh workflow run os-smoke.yml --repo jadentripp/vibe-os --ref main",
            result.stdout,
        )
        self.assertIn(f"-f expected_sha={TEST_SHA}", result.stdout)
        self.assertIn("-f expected_ref=main", result.stdout)
        self.assertIn("gh workflow run real-wad-smoke.yml", result.stdout)
        self.assertIn("-f audible_audio_proof=true", result.stdout)
        self.assertIn("-f persistence_proof=true", result.stdout)
        self.assertIn("-f persistence_save_slot=0", result.stdout)
        self.assertIn("gh workflow run uefi-ovmf-proof.yml", result.stdout)
        self.assertIn("-f proof_mode=prove", result.stdout)
        self.assertIn("--name aurora-os-smoke-proof-status", result.stdout)
        self.assertIn("--name real-wad-smoke-proof-status", result.stdout)
        self.assertIn("--name uefi-ovmf-proof-manifests", result.stdout)
        self.assertIn("tools/check_post_merge_cloud_artifacts.py", result.stdout)
        self.assertIn("--require-real-wad-gameplay-proof", result.stdout)
        self.assertIn("--require-audible-proof", result.stdout)
        self.assertIn("--require-persistence-proof", result.stdout)
        self.assertIn("--require-uefi-kernel-entry", result.stdout)
        self.assertIn("dry-run: artifacts were not downloaded or checked", result.stdout)
        self.assertEqual(result.stderr, "")
        for forbidden in (
            "qemu-system",
            "tests/run_smoke_qemu.sh",
            "make DOOM_WAD",
            "build/disk.img",
        ):
            self.assertNotIn(forbidden, HELPER.read_text())

    def test_default_post_merge_lane_requires_full_real_wad_evidence(self):
        result = self.run_helper(
            "--dry-run",
            "--repo",
            "jadentripp/vibe-os",
            "--ref",
            "main",
            "--commit",
            TEST_SHA,
            "--download-dir",
            "build/post-merge-main",
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Real WAD lane: full", result.stdout)
        self.assertIn("-f audible_audio_proof=true", result.stdout)
        self.assertIn("-f persistence_proof=true", result.stdout)
        self.assertIn("-f persistence_save_slot=0", result.stdout)
        self.assertIn("--require-real-wad-gameplay-proof", result.stdout)
        self.assertIn("--require-audible-proof", result.stdout)
        self.assertIn("--require-persistence-proof", result.stdout)
        self.assertIn("--require-uefi-kernel-entry", result.stdout)

    def test_refuses_local_vm_execution(self):
        result = self.run_helper(
            "--dry-run",
            "--commit",
            TEST_SHA,
            env={"ALLOW_LOCAL_VM": "1"},
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("refuses local VM execution", result.stderr)
        self.assertNotIn("dispatch:", result.stdout)

    def test_refuses_abbreviated_post_push_commit(self):
        result = self.run_helper(
            "--dry-run",
            "--repo",
            "jadentripp/vibe-os",
            "--ref",
            "main",
            "--commit",
            TEST_SHA[:12],
            "--download-dir",
            "build/post-merge-main",
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("full 40-character pushed Git SHA", result.stderr)
        self.assertNotIn("dispatch:", result.stdout)

    def test_status_only_checker_validates_three_downloaded_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_os_artifact(root / "os-smoke")
            write_real_wad_artifact(root / "real-wad-smoke")
            write_uefi_artifact(root / "uefi-ovmf-proof")

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--os",
                    str(root / "os-smoke"),
                    "--real-wad",
                    str(root / "real-wad-smoke"),
                    "--uefi",
                    str(root / "uefi-ovmf-proof"),
                    "--require-real-wad-gameplay-proof",
                    "--require-audible-proof",
                    "--require-uefi-kernel-entry",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("post-merge cloud artifact check OK", result.stdout)

    def test_status_only_checker_rejects_expected_commit_prefix(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp) / "os-smoke"
            write_os_artifact(artifact)

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA[:12],
                    "--os",
                    str(artifact),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("full 40-character Git SHA", result.stderr)

    def test_status_only_checker_rejects_exitbootservices_without_kernel_marker(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_uefi_artifact(root / "uefi-ovmf-proof")
            manifest_path = root / "uefi-ovmf-proof" / "ovmf-proof-manifest.json"
            manifest = json.loads(manifest_path.read_text())
            manifest["ovmf"]["proof"] = "exit-boot-services"
            manifest["ovmf"]["kernel_booted"] = False
            manifest["ovmf"]["kernel_entry_status"] = "missing"
            manifest["ovmf"]["kernel_entry_evidence"] = {}
            write_json(manifest_path, manifest)

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--uefi",
                    str(root / "uefi-ovmf-proof"),
                    "--require-uefi-kernel-entry",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("kernel-owned VIBEKERN entry/status marker", result.stderr)

    def test_status_only_checker_rejects_kernel_marker_without_exitbootservices_order(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_uefi_artifact(root / "uefi-ovmf-proof")
            manifest_path = root / "uefi-ovmf-proof" / "ovmf-proof-manifest.json"
            manifest = json.loads(manifest_path.read_text())
            manifest["ovmf"]["exit_boot_services"] = False
            manifest["ovmf"]["kernel_entry_after_exit_boot_services"] = False
            write_json(manifest_path, manifest)

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--uefi",
                    str(root / "uefi-ovmf-proof"),
                    "--require-uefi-kernel-entry",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("kernel marker after ExitBootServices", result.stderr)

    def test_status_only_checker_rejects_kernel_marker_without_loader_handoff_attempt(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_uefi_artifact(root / "uefi-ovmf-proof")
            manifest_path = root / "uefi-ovmf-proof" / "ovmf-proof-manifest.json"
            manifest = json.loads(manifest_path.read_text())
            manifest["ovmf"]["kernel_handoff_after_exit_boot_services"] = False
            write_json(manifest_path, manifest)

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--uefi",
                    str(root / "uefi-ovmf-proof"),
                    "--require-uefi-kernel-entry",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("loader handoff attempt after ExitBootServices", result.stderr)

    def test_status_only_checker_rejects_loader_handoff_without_bounded_evidence(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_uefi_artifact(root / "uefi-ovmf-proof")
            manifest_path = root / "uefi-ovmf-proof" / "ovmf-proof-manifest.json"
            manifest = json.loads(manifest_path.read_text())
            manifest["ovmf"]["loader_handoff_valid"] = False
            manifest["ovmf"]["loader_handoff_evidence"] = {
                "step": "kernel-handoff",
                "status": "attempting",
            }
            write_json(manifest_path, manifest)

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--uefi",
                    str(root / "uefi-ovmf-proof"),
                    "--require-uefi-kernel-entry",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("bounded loader handoff evidence", result.stderr)

    def test_status_only_checker_rejects_kernel_marker_missing_handoff_flags(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_uefi_artifact(root / "uefi-ovmf-proof")
            manifest_path = root / "uefi-ovmf-proof" / "ovmf-proof-manifest.json"
            manifest = json.loads(manifest_path.read_text())
            manifest["ovmf"]["kernel_entry_evidence"]["flags"] = "0x0000003F"
            write_json(manifest_path, manifest)

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--uefi",
                    str(root / "uefi-ovmf-proof"),
                    "--require-uefi-kernel-entry",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("kernel-owned VIBEKERN entry/status marker", result.stderr)

    def test_status_only_checker_rejects_forbidden_payloads(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp) / "os-smoke"
            write_os_artifact(artifact)
            (artifact / "build.elf").write_bytes(b"\x7fELF")

            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--os",
                    str(artifact),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("forbidden", result.stderr)
        self.assertIn("build.elf", result.stderr)

    def test_status_only_checker_rejects_secret_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp) / "os-smoke"
            write_os_artifact(artifact)
            (artifact / "status-token.txt").write_text("proof=OK\n")

            filename_result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--os",
                    str(artifact),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(filename_result.returncode, 1)
        self.assertIn("forbidden", filename_result.stderr)
        self.assertIn("status-token.txt", filename_result.stderr)

        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp) / "os-smoke"
            write_os_artifact(artifact)
            status_path = artifact / "status.txt"
            secret_key = "GITHUB" + "_TOKEN"
            secret_value = "ghu_" + "0123456789abcdefghijklmnopqrstuvwxyzABCD"
            status_path.write_text(
                status_path.read_text()
                + f"\n{secret_key}={secret_value}\n"
            )

            content_result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--expected-commit",
                    TEST_SHA,
                    "--os",
                    str(artifact),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(content_result.returncode, 1)
        self.assertIn("secret-like artifact content", content_result.stderr)
        self.assertIn("GitHub token-shaped string", content_result.stderr)

    def test_status_only_checker_rejects_missing_new_runtime_legitimacy_fields(self):
        for field in ("biosboot", "faultsrc", "faultmode", "faultcontain", "kblock", "ksleep"):
            with self.subTest(field=field), tempfile.TemporaryDirectory() as tmp:
                artifact = Path(tmp) / "os-smoke"
                write_os_artifact(artifact)
                status_path = artifact / "status.txt"
                status_path.write_text(remove_status_field(status_path.read_text(), field))

                result = subprocess.run(
                    [
                        sys.executable,
                        str(CHECKER),
                        "--expected-commit",
                        TEST_SHA,
                        "--os",
                        str(artifact),
                    ],
                    cwd=ROOT,
                    capture_output=True,
                    text=True,
                )

                self.assertEqual(result.returncode, 1)
                self.assertIn(field, result.stderr)

    def test_ovmf_parser_requires_kernel_marker_after_exitbootservices_and_full_flags(self):
        loader_handoff_marker = (
            "VIBEUEFI step=kernel-handoff status=attempting proof=pending-kernel-entry-marker "
            "entry32=0x00010000 handoff=0x00009000 bootinfo=0x00007000 "
            "e820=0x00007100 tramp32=0x00008000 transition64=0x0000A000 "
            "flags=0x0000007F segments=0x00000003\n"
        )
        kernel_marker = (
            "VIBEKERN step=uefi-entry status=OK handoff=0x00009000 "
            "bootinfo=0x00007000 e820=0x00007100 entry=0x00010000 "
            "flags=0x0000007F segments=0x00000003\n"
        )

        without_exit = parse_uefi_debugcon(kernel_marker)
        self.assertFalse(without_exit["kernel_booted"])
        self.assertFalse(without_exit["kernel_entry_after_exit_boot_services"])

        with_exit_no_handoff = parse_uefi_debugcon(
            "VIBEUEFI step=exit-boot-services status=success\n" + kernel_marker
        )
        self.assertFalse(with_exit_no_handoff["kernel_booted"])
        self.assertFalse(with_exit_no_handoff["kernel_entry_after_exit_boot_services"])

        with_exit_bare_handoff = parse_uefi_debugcon(
            "VIBEUEFI step=exit-boot-services status=success\n"
            "VIBEUEFI step=kernel-handoff status=attempting proof=pending-kernel-entry-marker\n"
            + kernel_marker
        )
        self.assertFalse(with_exit_bare_handoff["kernel_booted"])
        self.assertFalse(with_exit_bare_handoff["kernel_handoff_after_exit_boot_services"])

        with_exit = parse_uefi_debugcon(
            "VIBEUEFI step=exit-boot-services status=success\n"
            + loader_handoff_marker
            + kernel_marker
        )
        self.assertTrue(with_exit["kernel_booted"])
        self.assertTrue(with_exit["kernel_entry_after_exit_boot_services"])
        self.assertTrue(with_exit["kernel_handoff_after_exit_boot_services"])
        self.assertTrue(with_exit["loader_handoff_valid"])

        missing_final_jump_flag = parse_uefi_debugcon(
            "VIBEUEFI step=exit-boot-services status=success\n"
            + loader_handoff_marker
            + "VIBEKERN step=uefi-entry status=OK handoff=0x00009000 "
            "bootinfo=0x00007000 e820=0x00007100 entry=0x00010000 "
            "flags=0x0000003F segments=0x00000003\n"
        )
        self.assertFalse(missing_final_jump_flag["kernel_booted"])

        missing_loader_final_jump_flag = parse_uefi_debugcon(
            "VIBEUEFI step=exit-boot-services status=success\n"
            "VIBEUEFI step=kernel-handoff status=attempting proof=pending-kernel-entry-marker "
            "entry32=0x00010000 handoff=0x00009000 bootinfo=0x00007000 "
            "e820=0x00007100 tramp32=0x00008000 transition64=0x0000A000 "
            "flags=0x0000003F segments=0x00000003\n"
            + kernel_marker
        )
        self.assertFalse(missing_loader_final_jump_flag["kernel_booted"])
        self.assertFalse(missing_loader_final_jump_flag["kernel_handoff_after_exit_boot_services"])

    def test_workflows_and_docs_expose_post_merge_lane(self):
        os_workflow = (ROOT / ".github" / "workflows" / "os-smoke.yml").read_text()
        real_wad_workflow = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        uefi_workflow = (ROOT / ".github" / "workflows" / "uefi-ovmf-proof.yml").read_text()
        readme = (ROOT / "README.md").read_text()
        proof = (ROOT / "docs" / "proof.txt").read_text()

        for workflow in (os_workflow, real_wad_workflow, uefi_workflow):
            self.assertIn("expected_sha:", workflow)
            self.assertIn("cloud-proof-run.json", workflow)
            self.assertIn("contains_disk_image", workflow)
            self.assertIn("contains_raw_audio", workflow)

        self.assertIn("aurora-os-smoke-proof-status", os_workflow)
        self.assertIn("real-wad-smoke-proof-status", real_wad_workflow)
        self.assertIn("uefi-ovmf-proof-manifests", uefi_workflow)
        self.assertIn("tools/run_post_merge_cloud_proof.py", readme)
        self.assertIn("defaults to the full Real WAD lane", readme)
        self.assertIn("tools/check_post_merge_cloud_artifacts.py", proof)
        self.assertIn("--require-audible-proof", proof)
        self.assertIn("--require-persistence-proof", proof)


if __name__ == "__main__":
    unittest.main()
