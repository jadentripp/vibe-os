import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DoomInputContractTests(unittest.TestCase):
    def test_public_input_header_exposes_game_agnostic_event_contract(self):
        abi_source = r"""
            #include "vibe_os.h"

            #define CHECK(name, expr) typedef char check_##name[(expr) ? 1 : -1]

            CHECK(input_event_size, sizeof(vibe_input_event_t) == VIBE_INPUT_EVENT_BYTES);
            CHECK(input_event_timestamp, __builtin_offsetof(vibe_input_event_t, timestamp) == 0);
            CHECK(input_event_device_id, __builtin_offsetof(vibe_input_event_t, device_id) == 4);
            CHECK(input_event_type, __builtin_offsetof(vibe_input_event_t, type) == 8);
            CHECK(input_event_code, __builtin_offsetof(vibe_input_event_t, code) == 12);
            CHECK(input_event_value0, __builtin_offsetof(vibe_input_event_t, value0) == 16);
            CHECK(input_event_value1, __builtin_offsetof(vibe_input_event_t, value1) == 20);
            CHECK(input_event_value2, __builtin_offsetof(vibe_input_event_t, value2) == 24);
            CHECK(input_key_pressed, VIBE_INPUT_KEY_PRESSED == 1);
            CHECK(input_key_released, VIBE_INPUT_KEY_RELEASED == 0);
            CHECK(input_mouse_buttons,
                (VIBE_INPUT_MOUSE_BUTTON_LEFT
                | VIBE_INPUT_MOUSE_BUTTON_RIGHT
                | VIBE_INPUT_MOUSE_BUTTON_MIDDLE) == 7);
            CHECK(input_status_size, sizeof(vibe_input_status_t) == VIBE_INPUT_STATUS_BYTES);
            CHECK(input_status_abi_version, __builtin_offsetof(vibe_input_status_t, abi_version) == 0);
            CHECK(input_status_event_bytes, __builtin_offsetof(vibe_input_status_t, event_bytes) == 4);
            CHECK(input_status_queue_capacity, __builtin_offsetof(vibe_input_status_t, queue_capacity) == 8);
            CHECK(input_status_queued_events, __builtin_offsetof(vibe_input_status_t, queued_events) == 12);
            CHECK(input_status_total_events, __builtin_offsetof(vibe_input_status_t, total_events) == 16);
            CHECK(input_status_polled_events, __builtin_offsetof(vibe_input_status_t, polled_events) == 20);
            CHECK(input_status_dropped_events, __builtin_offsetof(vibe_input_status_t, dropped_events) == 24);
            CHECK(input_status_capabilities, __builtin_offsetof(vibe_input_status_t, capabilities) == 28);
            CHECK(input_status_keyboard_irq_count,
                __builtin_offsetof(vibe_input_status_t, keyboard_irq_count) == 32);
            CHECK(input_status_keyboard_event_count,
                __builtin_offsetof(vibe_input_status_t, keyboard_event_count) == 36);
            CHECK(input_status_keyboard_down_count,
                __builtin_offsetof(vibe_input_status_t, keyboard_down_count) == 40);
            CHECK(input_status_keyboard_last_code,
                __builtin_offsetof(vibe_input_status_t, keyboard_last_code) == 44);
            CHECK(input_status_keyboard_state,
                __builtin_offsetof(vibe_input_status_t, keyboard_state) == 48);
            CHECK(input_status_mouse_irq_count,
                __builtin_offsetof(vibe_input_status_t, mouse_irq_count) == 80);
            CHECK(input_status_mouse_packet_count,
                __builtin_offsetof(vibe_input_status_t, mouse_packet_count) == 84);
            CHECK(input_status_mouse_sync_loss_count,
                __builtin_offsetof(vibe_input_status_t, mouse_sync_loss_count) == 88);
            CHECK(input_status_mouse_buttons,
                __builtin_offsetof(vibe_input_status_t, mouse_buttons) == 92);
            CHECK(input_status_mouse_delta_x_total,
                __builtin_offsetof(vibe_input_status_t, mouse_delta_x_total) == 96);
            CHECK(input_status_mouse_delta_y_total,
                __builtin_offsetof(vibe_input_status_t, mouse_delta_y_total) == 100);
            CHECK(input_status_last_event_device_id,
                __builtin_offsetof(vibe_input_status_t, last_event_device_id) == 104);
            CHECK(input_status_last_event_type,
                __builtin_offsetof(vibe_input_status_t, last_event_type) == 108);
            CHECK(input_status_bytes, VIBE_INPUT_STATUS_BYTES == 112);
            CHECK(input_abi_version, VIBE_INPUT_ABI_VERSION == 1);
            CHECK(input_queue_capacity, VIBE_INPUT_EVENT_QUEUE_CAPACITY == 64);
            CHECK(input_status_syscall, VIBE_SYS_INPUT_STATUS == 31);
        """
        abi = subprocess.run(
            [
                "clang",
                "-target",
                "i386-unknown-none-elf",
                "-std=gnu89",
                "-ffreestanding",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-I",
                str(ROOT / "doom_port" / "include"),
                "-x",
                "c",
                "-fsyntax-only",
                "-",
            ],
            cwd=ROOT,
            input=abi_source,
            capture_output=True,
            text=True,
        )
        self.assertEqual(abi.returncode, 0, abi.stderr)

        runtime_source = r"""
            #include "vibe_os.h"

            int main(void)
            {
                vibe_input_event_t event;

                vibe_input_make_key_event(&event, 44, 'w', 1);
                if (event.timestamp != 44
                    || event.device_id != VIBE_INPUT_DEVICE_KEYBOARD
                    || event.type != VIBE_INPUT_EVENT_KEY
                    || event.code != 'w'
                    || event.value0 != VIBE_INPUT_KEY_PRESSED
                    || event.value1 != 0
                    || event.value2 != 0)
                    return 1;

                vibe_input_make_key_event(&event, 45, 'w', 0);
                if (event.value0 != VIBE_INPUT_KEY_RELEASED)
                    return 2;

                vibe_input_make_mouse_packet_event(
                    &event,
                    46,
                    VIBE_INPUT_MOUSE_BUTTON_LEFT | VIBE_INPUT_MOUSE_BUTTON_MIDDLE | 0xf0u,
                    -3,
                    5);
                if (event.timestamp != 46
                    || event.device_id != VIBE_INPUT_DEVICE_MOUSE
                    || event.type != VIBE_INPUT_EVENT_MOUSE_PACKET
                    || event.code != (VIBE_INPUT_MOUSE_BUTTON_LEFT | VIBE_INPUT_MOUSE_BUTTON_MIDDLE)
                    || event.value0 != -3
                    || event.value1 != 5
                    || event.value2 != 0)
                    return 3;

                if (!vibe_input_event_is_mouse_packet(&event) || vibe_input_event_is_key(&event))
                    return 4;

                vibe_input_make_key_event(&event, 47, 'a', 1);
                if (!vibe_input_event_is_key(&event) || vibe_input_event_is_mouse_packet(&event))
                    return 5;

                {
                    vibe_input_status_t status;
                    status.dropped_events = 0;
                    status.keyboard_state[0] = 0;
                    status.keyboard_state[3] = 0;
                    if (vibe_input_status_has_overflow(&status))
                        return 6;
                    status.dropped_events = 1;
                    if (!vibe_input_status_has_overflow(&status))
                        return 7;
                    status.keyboard_state['a' >> 5] = 1ul << ('a' & 31);
                    if (!vibe_input_status_key_is_down(&status, 'a'))
                        return 8;
                    if (vibe_input_status_key_is_down(&status, 'b'))
                        return 9;
                    if (vibe_input_status_key_is_down(&status, 256))
                        return 10;
                }

                vibe_input_make_key_event(0, 0, 0, 0);
                vibe_input_make_mouse_packet_event(0, 0, 0, 0, 0);
                return 0;
            }
        """
        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "vibe_input_contract"
            build = subprocess.run(
                [
                    "clang",
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-Werror",
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    "-x",
                    "c",
                    "-",
                    "-o",
                    str(binary),
                ],
                cwd=ROOT,
                input=runtime_source,
                capture_output=True,
                text=True,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            run = subprocess.run([str(binary)], cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(run.returncode, 0, run.stdout + run.stderr)

    def test_input_docs_name_generic_queue_not_doom_only_helper(self):
        docs = (ROOT / "docs" / "input.md").read_text()

        for source in (
            "the queue contract is\n  not Doom-specific",
            "VIBE_INPUT_EVENT_BYTES == 28",
            "VIBE_INPUT_STATUS_BYTES == 112",
            "VIBE_SYS_INPUT_STATUS",
            "vibe_input_make_key_event()",
            "vibe_input_make_mouse_packet_event()",
            "vibe_input_status_t",
            "dropped_events",
            "keyboard_down_count",
            "keyboard_state",
            "mouse_buttons",
            "future games",
            "Game-specific\n  button remapping belongs in the consuming port",
        ):
            with self.subTest(source=source):
                self.assertIn(source, docs)

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
            "SYS_POLL_INPUT equ 28",
            "VIBE_INPUT_EVENT_BYTES equ 28",
            "VIBE_INPUT_STATUS_BYTES equ 112",
            "SYS_INPUT_STATUS equ 31",
            "VIBE_INPUT_DEVICE_KEYBOARD equ 1",
            "VIBE_INPUT_DEVICE_MOUSE equ 2",
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
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()

        for source in (
            '#include "input.h"',
            "vibe_input_event_t input",
            "vibe_doom_input_event_t translated",
            "vibe_syscall3(VIBE_SYS_POLL_INPUT",
            "sizeof(input)",
            "vibe_doom_translate_input_event",
            "checkpoint_default_config_if_needed();",
            "checkpoint_save_slot_if_needed();",
            "checkpoint_load_slot_if_needed();",
            "cache_persistence_requests();",
            "persistence_checkpoint_requested()",
            '"PERSIST.CHK"',
            'stat("PERSIST.CHK", &info) == 0',
            '"SAVEREQ.CHK"',
            '"LOADREQ.CHK"',
            "stat(path, &info)",
            "*slot = (int)info.st_size - 1;",
            "if (default_config_checkpoint_request_checked)",
            "if (save_checkpoint_request_checked)",
            "if (load_checkpoint_request_checked)",
            "default_config_checkpoint_ready()",
            "#define VIBE_PERSISTENCE_MIN_LEVELTIME 32",
            "gamestate == GS_LEVEL",
            "gameepisode > 0",
            "gametic > 0",
            "VIBE_PERSISTENCE_MIN_LEVELTIME",
            "leveltime >= VIBE_PERSISTENCE_MIN_LEVELTIME",
            "if (save_checkpoint_requested)",
            "if (load_checkpoint_requested)",
            "if (!default_config_checkpoint_ready() || !persistence_checkpoint_requested())",
            "if (!save_checkpoint_requested_once())",
            "if (!load_checkpoint_requested_once())",
            "default_config_needs_checkpoint()",
            'default_config_contains_marker(length, "chatmacro0")',
            "M_SaveDefaults();",
            'static char description[] = "VIBE SAVE";',
            "G_SaveGame(save_checkpoint_slot, description);",
            "G_SaveGame(save_checkpoint_slot, description);\n    save_checkpoint_started = 1;",
            "save_checkpoint_desc_hash = hash_save_description(&save_checkpoint_desc_len);",
            "if (save_checkpoint_started",
            "&& !save_checkpoint_promoted",
            "&& !save_checkpoint_done",
            "&& gameaction == ga_savegame",
            "&& savedescription[0]",
            "clear_consumed_save_ticcmd();",
            "save_checkpoint_promoted = 1;",
            "if (save_checkpoint_promoted",
            "&& !sendsave",
            "&& !savedescription[0]",
            "&& gameaction == ga_nothing",
            "save_checkpoint_done = 1;",
            "G_LoadGame(path);",
            "load_checkpoint_started = 1;",
            "VIBE_DOOM_INPUT_KEYDOWN",
            "VIBE_DOOM_INPUT_MOUSE",
            "ev_keydown",
            "ev_keyup",
            "event.type = ev_mouse",
        ):
            with self.subTest(source=source):
                self.assertIn(source, platform)

        slot_request = platform.split("static int read_persistence_slot_request", 1)[1].split(
            "static int save_checkpoint_requested_once", 1
        )[0]
        self.assertIn("stat(path, &info)", slot_request)
        self.assertNotIn("fread", slot_request)

        self.assertIn("doom_port/input.c", makefile)
        for source in (
            "VIBE_SYS_POLL_INPUT = 28",
            "typedef struct vibe_input_event",
            "VIBE_INPUT_EVENT_KEY",
            "VIBE_INPUT_EVENT_MOUSE_PACKET",
        ):
            with self.subTest(source=source):
                self.assertIn(source, header)

    def test_kernel_generic_input_queue_records_typed_events(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()

        for source in (
            "input_event_queue times INPUT_EVENT_QUEUE_SIZE * VIBE_INPUT_EVENT_DWORDS dd 0",
            "input_event_drop_count dd 0",
            "input_keyboard_down_count dd 0",
            "input_keyboard_state times 8 dd 0",
            "input_mouse_buttons dd 0",
            "input_mouse_delta_x_total dd 0",
            "input_mouse_delta_y_total dd 0",
            "input_queue_key_event:",
            "input_queue_mouse_packet_event:",
            "call input_queue_key_event",
            "call input_queue_mouse_packet_event",
            ".poll_input:",
            "cmp eax, SYS_INPUT_STATUS",
            ".input_status:",
            "VIBE_INPUT_STATUS_DROPPED_EVENTS",
            "VIBE_INPUT_STATUS_KEYBOARD_DOWN_COUNT",
            "VIBE_INPUT_STATUS_KEYBOARD_STATE",
            "VIBE_INPUT_STATUS_MOUSE_BUTTONS",
            "call doom_record_input_event",
            "doom_input_event_count dd 0",
            "doom_input_last_timestamp dd 0",
            "doom_input_last_device dd 0",
            "doom_input_last_type dd 0",
            'smoke_inputqueue_text db " inputqueue="',
            'smoke_inputpoll_text db " inputpoll="',
            'smoke_inputlast_text db " inputlast="',
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for source in (
            'grep -q "inputqueue="',
            'grep -q "inputpoll="',
            'grep -Eq "inputlast=([0-9A-F]{8}:){2}[0-9A-F]{8}"',
        ):
            with self.subTest(source=source):
                self.assertIn(source, makefile)

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
