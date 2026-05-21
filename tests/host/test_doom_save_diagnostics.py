import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DoomSaveDiagnosticsTests(unittest.TestCase):
    def read(self, relpath):
        return (ROOT / relpath).read_text()

    def test_save_stream_error_diagnostic_samples_original_unarchive_class(self):
        save_debug = self.read("doom_port/save_debug.c")
        platform = self.read("doom_port/platform.c")

        self.assertIn("static unsigned long active_save_stream_stage;", save_debug)
        self.assertIn("void vibe_doom_save_stream_note_error(void)", save_debug)
        self.assertIn("save_stage_reads_class_byte(active_save_stream_stage)", save_debug)
        self.assertIn("stream_p = save_p - 1;", save_debug)
        self.assertIn("report_save_stream_pointer(active_save_stream_stage, stream_p);", save_debug)
        self.assertIn("void vibe_doom_save_stream_note_error(void);", platform)
        self.assertIn("savegameslot = load_checkpoint_slot;", platform)
        self.assertLess(
            platform.index("vibe_doom_save_stream_note_error();"),
            platform.index('fprintf(stderr, "doom error: %s\\n", buffer);'),
        )

    def test_save_stream_diagnostics_are_status_only(self):
        save_debug = self.read("doom_port/save_debug.c")

        self.assertIn("VIBE_SYS_GAMEPLAY_STATUS", save_debug)
        self.assertIn("VIBE_DOOM_SAVEACTION_STREAM", save_debug)
        self.assertNotIn("repair_missing_mobj_classes", save_debug)
        self.assertNotIn("*class_p =", save_debug)
        self.assertNotIn("VIBE_SAVE_TCLASS_MOBJ", save_debug)

    def test_original_doom_tree_has_no_port_diagnostic_hooks(self):
        third_party = ROOT / "third_party" / "doom"
        forbidden = (
            "vibe_doom_save_stream_note_error",
            "active_save_stream_stage",
            "VIBE_SYS_GAMEPLAY_STATUS",
            "VIBE_DOOM_SAVEACTION_STREAM",
        )

        for path in third_party.rglob("*"):
            if not path.is_file():
                continue
            text = path.read_text(errors="ignore")
            for token in forbidden:
                with self.subTest(path=path.relative_to(ROOT), token=token):
                    self.assertNotIn(token, text)


if __name__ == "__main__":
    unittest.main()
