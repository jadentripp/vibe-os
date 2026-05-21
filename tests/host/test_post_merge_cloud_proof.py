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


def write_os_artifact(path: Path) -> None:
    path.mkdir(parents=True)
    write_json(
        path / "cloud-proof-run.json",
        run_identity("os-smoke.yml", "aurora-os-smoke-proof-status"),
    )
    (path / "status.txt").write_text(valid_status())


def write_real_wad_artifact(path: Path) -> None:
    path.mkdir(parents=True)
    write_json(
        path / "cloud-proof-run.json",
        run_identity("real-wad-smoke.yml", "real-wad-smoke-proof-status"),
    )
    for name, status in audio_phase_statuses().items():
        (path / name).write_text(status)
    write_gameplay_proof(path)
    write_json(path / "audio-proof.json", valid_audio_proof_manifest())


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
                "proof": "exit-boot-services",
                "exit_boot_services": True,
                "kernel_booted": False,
                "kernel_handoff": "blocked",
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
        self.assertIn("--require-uefi-exit-boot-services", result.stdout)
        self.assertIn("dry-run: artifacts were not downloaded or checked", result.stdout)
        self.assertEqual(result.stderr, "")
        for forbidden in (
            "qemu-system",
            "tests/run_smoke_qemu.sh",
            "make DOOM_WAD",
            "build/disk.img",
        ):
            self.assertNotIn(forbidden, HELPER.read_text())

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
                    "--require-uefi-exit-boot-services",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("post-merge cloud artifact check OK", result.stdout)

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
        self.assertIn("tools/check_post_merge_cloud_artifacts.py", proof)


if __name__ == "__main__":
    unittest.main()
