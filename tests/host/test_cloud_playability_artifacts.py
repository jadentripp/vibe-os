import json
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
try:
    from test_remote_playability_runbook import (
        check_cloud_playability_artifacts,
        write_human_manifest,
        write_human_notes,
        write_human_session,
        write_valid_artifact,
    )
finally:
    sys.path.pop(0)


class CloudPlayabilityArtifactHumanBundleTests(unittest.TestCase):
    def write_bundle(self, artifact: Path) -> None:
        write_valid_artifact(artifact)
        write_human_notes(artifact)
        write_human_session(artifact)
        write_human_manifest(artifact)

    def test_human_bundle_requires_action_notes_and_explicit_forbidden_policy(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            self.write_bundle(artifact)

            check_cloud_playability_artifacts.validate_artifact_dir(
                artifact,
                require_human_notes=True,
            )

            notes = (artifact / "human-playtest-notes.txt").read_text()
            self.assertIn("action_note_start=E1M1 visible in noVNC", notes)
            self.assertIn("action_note_final=Final capture kept the manual session alive", notes)
            self.assertIn("no_screenshot_upload=yes", notes)
            self.assertIn("no_raw_audio_upload=yes", notes)

            manifest = json.loads((artifact / "human-playtest-manifest.json").read_text())
            self.assertEqual(manifest["schema"], "human-playtest-manifest-v2")
            self.assertEqual(manifest["identity"]["ref"], "main")
            self.assertEqual(manifest["identity"]["scripted_proof_run_id"], "26156172979")
            self.assertEqual(manifest["minimums"]["duration_gtic"], 350)
            self.assertGreaterEqual(manifest["counter_deltas"]["keyirq_delta"], 4)
            self.assertFalse(manifest["artifact_policy"]["contains_screenshots"])
            self.assertFalse(manifest["artifact_policy"]["contains_forbidden_artifacts"])
            self.assertEqual(
                manifest["phase_action_notes"]["after-use"],
                "Space use was accepted by Doom",
            )

            checklist = (artifact / "human-playtest-checklist.txt").read_text()
            self.assertIn("Reviewer runnable checklist", checklist)
            self.assertIn("note=Ctrl fire changed weapon state", checklist)
            self.assertIn("no_raw_audio_upload=yes", checklist)

    def test_human_review_action_notes_must_match_canonical_notes(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            self.write_bundle(artifact)

            review_path = artifact / "human-playtest-review.json"
            review = json.loads(review_path.read_text())
            review["phase_reviews"][1]["note"] = "Different fire note"
            review_path.write_text(json.dumps(review, indent=2, sort_keys=True) + "\n")

            with self.assertRaisesRegex(AssertionError, "human playtest review failed"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_human_notes_reject_missing_action_note(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            self.write_bundle(artifact)

            notes_path = artifact / "human-playtest-notes.txt"
            notes_path.write_text(
                "\n".join(
                    line
                    for line in notes_path.read_text().splitlines()
                    if not line.startswith("action_note_mouse=")
                )
                + "\n"
            )

            with self.assertRaisesRegex(AssertionError, "action_note_mouse"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )


if __name__ == "__main__":
    unittest.main()
