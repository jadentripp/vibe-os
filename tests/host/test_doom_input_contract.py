import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DoomInputContractTests(unittest.TestCase):
    def test_doom_port_input_translation_helper(self):
        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "doom_input_test"
            result = subprocess.run(
                [
                    "clang",
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-I",
                    str(ROOT / "doom_port"),
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    str(ROOT / "doom_port" / "input.c"),
                    str(ROOT / "tests" / "host" / "doom_input_test.c"),
                    "-o",
                    str(binary),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)

            run = subprocess.run([str(binary)], cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(run.returncode, 0, run.stdout + run.stderr)

    def test_kernel_keyboard_mapping_covers_doom_play_keys(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "DOOM_KEY_UPARROW equ 0xad",
            "DOOM_KEY_DOWNARROW equ 0xaf",
            "DOOM_KEY_LEFTARROW equ 0xac",
            "DOOM_KEY_RIGHTARROW equ 0xae",
            "DOOM_KEY_ESCAPE equ 27",
            "DOOM_KEY_ENTER equ 13",
            "DOOM_KEY_TAB equ 9",
            "DOOM_KEY_RSHIFT equ 0xb6",
            "DOOM_KEY_RCTRL equ 0x9d",
            "DOOM_KEY_RALT equ 0xb8",
            "DOOM_KEY_F1 equ 0xbb",
            "DOOM_KEY_F12 equ 0xd8",
            "KEY_EVENT_DOWN equ 0x00000100",
            "KEY_EVENT_VALID equ 0x00010000",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for source in (
            "cmp al, 0xe0",
            "cmp bl, 0x48",
            "je .ext_up",
            "cmp bl, 0x50",
            "je .ext_down",
            "cmp bl, 0x4b",
            "je .ext_left",
            "cmp bl, 0x4d",
            "je .ext_right",
            "cmp bl, 0x1c",
            "je .ext_enter",
            "cmp bl, 0x1d",
            "je .ext_ctrl",
            "cmp bl, 0x38",
            "je .ext_alt",
            "test bl, 0x80",
            "xor dl, dl",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        scancode_map = kernel.split("doom_scancode_map:", 1)[1].split("cursor_row", 1)[0]
        for source in (
            "db '1','2','3','4','5','6','7','8','9','0'",
            "db 'q','w','e','r','t','y','u','i','o','p'",
            "db 'a','s','d','f','g','h','j','k','l'",
            "db 'z','x','c','v','b','n','m'",
            "db DOOM_KEY_F1,DOOM_KEY_F2,DOOM_KEY_F3,DOOM_KEY_F4,DOOM_KEY_F5",
            "db DOOM_KEY_F6,DOOM_KEY_F7,DOOM_KEY_F8,DOOM_KEY_F9,DOOM_KEY_F10",
            "db DOOM_KEY_UPARROW",
            "db DOOM_KEY_MINUS,DOOM_KEY_LEFTARROW,0,DOOM_KEY_RIGHTARROW,DOOM_KEY_EQUALS,0,DOOM_KEY_DOWNARROW",
            "db DOOM_KEY_F11,DOOM_KEY_F12",
        ):
            with self.subTest(source=source):
                self.assertIn(source, scancode_map)

    def test_platform_drains_keyboard_and_mouse_through_translation_helpers(self):
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        makefile = (ROOT / "Makefile").read_text()

        for source in (
            '#include "input.h"',
            "vibe_doom_input_event_t translated",
            "vibe_doom_translate_key_event",
            "checkpoint_default_config_if_needed();",
            "checkpoint_save_slot_if_needed();",
            "checkpoint_load_slot_if_needed();",
            "persistence_checkpoint_requested()",
            'fopen("PERSIST.CHK", "r")',
            '"SAVEREQ.CHK"',
            '"LOADREQ.CHK"',
            "default_config_checkpoint_ready()",
            "gamestate == GS_LEVEL",
            "gameepisode > 0",
            "gametic > 0",
            "default_config_needs_checkpoint()",
            'default_config_contains_marker(length, "chatmacro0")',
            "M_SaveDefaults();",
            "gameaction = ga_savegame;",
            "G_DoSaveGame();",
            "G_LoadGame(path);",
            "VIBE_DOOM_INPUT_KEYDOWN",
            "ev_keydown",
            "ev_keyup",
            "vibe_doom_translate_mouse_event",
            "event.type = ev_mouse",
        ):
            with self.subTest(source=source):
                self.assertIn(source, platform)

        self.assertIn("doom_port/input.c", makefile)

    def test_raw_player_detail_status_exports_gameplay_state(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()

        for source in (
            "VIBE_SYS_PLAYER_DETAIL_STATUS = 26",
            "static void report_player_detail_status(void)",
            "player->cmd.forwardmove",
            "player->cmd.sidemove",
            "player->ammo[am_clip]",
            "player->refire",
            "player->readyweapon",
            "player->mo->angle",
            "report_player_detail_status();",
        ):
            with self.subTest(source=source):
                self.assertIn(source, header + platform)

        for source in (
            "SYS_PLAYER_DETAIL_STATUS equ 26",
            "cmp eax, SYS_PLAYER_DETAIL_STATUS",
            ".player_detail_status:",
            "doom_player_cmd",
            "doom_player_angle",
            "doom_player_angle_delta",
            "doom_player_ammo",
            "doom_player_refire",
            "doom_player_weapon",
            'smoke_pcmd_text db " pcmd="',
            'smoke_pangle_text db " pangle="',
            'smoke_pangledelta_text db " pangledelta="',
            'smoke_pammo_text db " pammo="',
            'smoke_prefire_text db " prefire="',
            'smoke_pweapon_text db " pweapon="',
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for source in (
            'grep -q "pcmd="',
            'grep -q "pangle="',
            'grep -q "pangledelta="',
            'grep -q "pammo="',
            'grep -q "prefire="',
            'grep -q "pweapon="',
        ):
            with self.subTest(source=source):
                self.assertIn(source, makefile)


if __name__ == "__main__":
    unittest.main()
