import os
import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / "tools" / "run_cloud_playability.py"


class CloudPlayabilityDispatchTests(unittest.TestCase):
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

    def test_gameplay_lane_dry_run_dispatches_cloud_only_workflow(self):
        result = self.run_helper(
            "--dry-run",
            "--lane",
            "gameplay",
            "--repo",
            "jadentripp/vibe-os",
            "--ref",
            "main",
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("vibe-os cloud playability", result.stdout)
        self.assertIn("lane: gameplay", result.stdout)
        self.assertIn("local VM: refused", result.stdout)
        self.assertIn("artifact policy: no WADs", result.stdout)
        self.assertIn(
            "gh workflow run real-wad-smoke.yml --repo jadentripp/vibe-os --ref main",
            result.stdout,
        )
        self.assertIn("-f expected_ref=main", result.stdout)
        self.assertIn("-f audible_audio_proof=false", result.stdout)
        self.assertIn("-f persistence_proof=false", result.stdout)
        self.assertNotIn("persistence_save_slot", result.stdout)
        self.assertIn("dry-run: workflow was not dispatched", result.stdout)
        self.assertEqual(result.stderr, "")

    def test_audio_and_persistence_lanes_are_isolated(self):
        audio = self.run_helper(
            "--dry-run",
            "--lane",
            "audio",
            "--repo",
            "jadentripp/vibe-os",
            "--ref",
            "main",
        )
        self.assertEqual(audio.returncode, 0, audio.stdout + audio.stderr)
        self.assertIn("lane: audio", audio.stdout)
        self.assertIn("-f audible_audio_proof=true", audio.stdout)
        self.assertNotIn("persistence_save_slot", audio.stdout)

        persistence = self.run_helper(
            "--dry-run",
            "--lane",
            "persistence",
            "--repo",
            "jadentripp/vibe-os",
            "--ref",
            "main",
            "--save-slot",
            "0",
        )
        self.assertEqual(persistence.returncode, 0, persistence.stdout + persistence.stderr)
        self.assertIn("lane: persistence", persistence.stdout)
        self.assertIn("-f audible_audio_proof=false", persistence.stdout)
        self.assertIn("-f persistence_save_slot=0", persistence.stdout)
        self.assertIn("isolated from audio flakes", persistence.stdout)

    def test_artifact_download_commands_match_lane_requirements(self):
        audio = self.run_helper(
            "--dry-run",
            "--lane",
            "audio",
            "--run-id",
            "12345",
            "--download-artifacts",
            "build/cloud-run-12345",
        )

        self.assertEqual(audio.returncode, 0, audio.stdout + audio.stderr)
        self.assertIn(
            "gh run download 12345 --repo jadentripp/vibe-os --name real-wad-smoke-status --dir build/cloud-run-12345",
            audio.stdout,
        )
        self.assertIn(
            "tools/check_cloud_playability_artifacts.py build/cloud-run-12345 --require-gameplay-proof --require-audible-proof",
            audio.stdout,
        )
        self.assertIn("failure lanes:", audio.stdout)
        self.assertIn("gameplay/input:", audio.stdout)
        self.assertIn("SB16 continuity:", audio.stdout)
        self.assertIn("audible audio aggregate:", audio.stdout)
        self.assertIn("build/cloud-run-12345/audio-proof.json", audio.stdout)
        self.assertIn("persistence/save-load: not requested for this lane", audio.stdout)
        self.assertIn("tools/triage_cloud_status.py build/cloud-run-12345/status.txt", audio.stdout)
        self.assertIn("dry-run: artifact was not downloaded", audio.stdout)

        persistence = self.run_helper(
            "--dry-run",
            "--lane",
            "persistence",
            "--run-id",
            "12345",
            "--download-artifacts",
            "build/cloud-run-12345",
        )
        self.assertEqual(persistence.returncode, 0, persistence.stdout + persistence.stderr)
        self.assertIn("--require-gameplay-proof", persistence.stdout)
        self.assertNotIn("--require-audible-proof", persistence.stdout)
        self.assertIn("audible audio aggregate: not requested for this lane", persistence.stdout)
        self.assertIn("persistence/save-load:", persistence.stdout)
        self.assertIn("status.persistence-load.txt", persistence.stdout)
        self.assertIn("tools/triage_cloud_status.py build/cloud-run-12345/status.persistence-load.txt", persistence.stdout)

    def test_soak_mode_dispatches_repeated_json_metadata_workflow(self):
        result = self.run_helper(
            "--dry-run",
            "--lane",
            "audio",
            "--repo",
            "jadentripp/vibe-os",
            "--ref",
            "main",
            "--soak-attempts",
            "3",
            "--soak-min-passes",
            "2",
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("mode: repeated soak (real-wad-soak.yml, attempts=3, min_passes=2)", result.stdout)
        self.assertIn(
            "gh workflow run real-wad-soak.yml --repo jadentripp/vibe-os --ref main",
            result.stdout,
        )
        self.assertIn("-f expected_ref=main", result.stdout)
        self.assertIn("-f attempts=3", result.stdout)
        self.assertIn("-f min_passes=2", result.stdout)
        self.assertIn("-f audible_audio_proof=true", result.stdout)
        self.assertNotIn("persistence_save_slot", result.stdout)
        self.assertIn("dry-run: workflow was not dispatched", result.stdout)

    def test_soak_artifact_download_uses_json_summary_checker(self):
        result = self.run_helper(
            "--dry-run",
            "--lane",
            "audio",
            "--run-id",
            "67890",
            "--soak",
            "--download-artifacts",
            "build/cloud-soak-67890",
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("mode: repeated soak (real-wad-soak.yml, existing run)", result.stdout)
        self.assertIn(
            "gh run download 67890 --repo jadentripp/vibe-os --name real-wad-soak-metadata --dir build/cloud-soak-67890",
            result.stdout,
        )
        self.assertIn(
            "tools/check_cloud_playability_artifacts.py --soak-summary build/cloud-soak-67890",
            result.stdout,
        )
        self.assertIn("failure lanes:", result.stdout)
        self.assertIn("gameplay/audio soak:", result.stdout)
        self.assertIn("persistence: not requested by real-wad-soak.yml", result.stdout)
        self.assertIn("soak metadata has no raw status text", result.stdout)
        self.assertIn("dry-run: artifact was not downloaded", result.stdout)

    def test_soak_mode_refuses_persistence_lanes_and_bad_thresholds(self):
        persistence = self.run_helper(
            "--dry-run",
            "--lane",
            "persistence",
            "--soak-attempts",
            "3",
        )
        self.assertEqual(persistence.returncode, 1)
        self.assertIn("real-wad-soak.yml repeats the gameplay/audio proof only", persistence.stderr)
        self.assertNotIn("dispatch:", persistence.stdout)

        threshold = self.run_helper(
            "--dry-run",
            "--lane",
            "audio",
            "--soak-attempts",
            "2",
            "--soak-min-passes",
            "3",
        )
        self.assertEqual(threshold.returncode, 1)
        self.assertIn("--soak-min-passes cannot exceed --soak-attempts", threshold.stderr)
        self.assertNotIn("dispatch:", threshold.stdout)

        missing_attempts = self.run_helper("--dry-run", "--lane", "audio", "--soak")
        self.assertEqual(missing_attempts.returncode, 1)
        self.assertIn("--soak dispatch requires --soak-attempts", missing_attempts.stderr)
        self.assertNotIn("dispatch:", missing_attempts.stdout)

    def test_refuses_local_vm_execution_and_local_wad_paths(self):
        local_env = self.run_helper("--dry-run", "--lane", "gameplay", env={"ALLOW_LOCAL_VM": "1"})
        self.assertEqual(local_env.returncode, 1)
        self.assertIn("cloud-only helper refuses local VM execution", local_env.stderr)
        self.assertNotIn("dispatch:", local_env.stdout)

        local_flag = self.run_helper("--dry-run", "--lane", "gameplay", "--local")
        self.assertEqual(local_flag.returncode, 1)
        self.assertIn("cloud-only helper refuses local VM execution", local_flag.stderr)
        self.assertNotIn("dispatch:", local_flag.stdout)

        wad_path = self.run_helper(
            "--dry-run",
            "--lane",
            "gameplay",
            "--wad-url",
            "/tmp/DOOM1.WAD",
        )
        self.assertEqual(wad_path.returncode, 1)
        self.assertIn("--wad-url must be an http(s) URL", wad_path.stderr)
        self.assertIn("WAD must stay outside git", wad_path.stderr)

        early_download = self.run_helper(
            "--dry-run",
            "--lane",
            "gameplay",
            "--download-artifacts",
            "build/cloud-run-new",
        )
        self.assertEqual(early_download.returncode, 1)
        self.assertIn("--download-artifacts with a new dispatch requires --wait", early_download.stderr)
        self.assertNotIn("dispatch:", early_download.stdout)

    def test_script_workflow_and_docs_capture_cloud_only_contract(self):
        script = HELPER.read_text()
        workflow = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        soak_workflow = (ROOT / ".github" / "workflows" / "real-wad-soak.yml").read_text()
        playable_doc = (ROOT / "docs" / "playable-cloud-proof.md").read_text()
        triage_doc = (ROOT / "docs" / "cloud-status-triage.md").read_text()

        self.assertTrue(HELPER.stat().st_mode & 0o111)
        for forbidden in (
            "qemu-system",
            "tests/run_smoke_qemu.sh",
            "make DOOM_WAD",
            "build/disk.img",
            "actions/upload-artifact",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, script)

        for needle in (
            "Summarize cloud proof lane",
            "Failure lanes: gameplay/input, SB16 continuity, audible audio aggregate, and persistence/save-load",
            "Persistence isolation",
            "gh run download $GITHUB_RUN_ID",
            "python3 tools/triage_cloud_status.py build/cloud-run-$GITHUB_RUN_ID/status.txt",
            "leave audible_audio_proof false when isolating persistence",
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, workflow)

        for doc in (playable_doc, triage_doc):
            with self.subTest(doc=doc[:20]):
                self.assertIn("tools/run_cloud_playability.py", doc)
                self.assertIn("--lane gameplay", doc)
                self.assertIn("--lane audio", doc)
                self.assertIn("--lane persistence", doc)
                self.assertIn("audible_audio_proof=false", doc)
                self.assertIn("--soak-attempts", doc)
                self.assertIn("failure lanes", doc.lower())

        for needle in (
            "Summarize soak proof lane",
            "gh run download $GITHUB_RUN_ID",
            "real-wad-soak-metadata",
            "tools/check_cloud_playability_artifacts.py --soak-summary",
            "JSON soak metadata only",
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, soak_workflow)


if __name__ == "__main__":
    unittest.main()
