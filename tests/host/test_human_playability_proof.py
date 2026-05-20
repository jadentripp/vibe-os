import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "check_human_playability_proof.py"
spec = importlib.util.spec_from_file_location("check_human_playability_proof", TOOL)
check_human_playability_proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check_human_playability_proof)


def make_status(**overrides):
    fields = {
        "gameplay": "OK",
        "gstate": "00000000",
        "gmap": "00000101",
        "gtic": "00000020",
        "leveltime": "00000020",
        "doompresent": "00000004",
        "gflags": "00000001",
        "gaction": "00000000",
        "pflags": "000000FF",
        "pbuttons": "00000000",
        "ppos": "00010000:00020000",
        "pdelta": "00000100",
        "keyirq": "00000002",
        "keyqueue": "00000002",
        "keypoll": "00000002",
        "mouse": "OK",
        "mouseirq": "00000002",
        "mousepkt": "00000002",
        "mousepoll": "00000002",
        "mousebtn": "00000001",
        "mousedelta": "00000018:0000000C",
        "doomlog": "ready",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(
        f"{name}={value}" for name, value in fields.items()
    )


class HumanPlayabilityProofTests(unittest.TestCase):
    def test_accepts_final_status_with_keyboard_counters(self):
        check_human_playability_proof.validate_status(make_status())

    def test_requires_keyboard_and_runtime_deltas_from_baseline(self):
        baseline = make_status(
            gtic="00000010",
            leveltime="00000010",
            keyirq="00000001",
            keyqueue="00000001",
            keypoll="00000001",
        )
        final = make_status(
            gtic="00000020",
            leveltime="00000020",
            keyirq="00000002",
            keyqueue="00000002",
            keypoll="00000002",
        )
        check_human_playability_proof.validate_status(final, baseline)

        for field in ("keyirq", "keyqueue", "keypoll", "gtic", "leveltime"):
            with self.subTest(field=field):
                bad_final = make_status(**{field: "00000001"})
                with self.assertRaisesRegex(AssertionError, field):
                    check_human_playability_proof.validate_status(bad_final, baseline)

    def test_rejects_non_playable_final_status(self):
        invalid_cases = (
            make_status(gameplay="NO"),
            make_status(gstate="00000001"),
            make_status(gmap="00000102"),
            make_status(gtic="00000000"),
            make_status(leveltime="00000000"),
            make_status(doompresent="00000000"),
            make_status(gflags="00000000"),
            make_status(pflags="0000003D"),
            make_status(pflags="00000037"),
            make_status(pflags="0000003F"),
            make_status(pdelta="00000000"),
            make_status(ppos="00000000"),
            make_status(keyirq="00000000"),
            make_status(keyqueue="00000000"),
            make_status(keypoll="00000000"),
            make_status(doomlog="W_GetNumForName"),
        )
        for status in invalid_cases:
            with self.subTest(status=status):
                with self.assertRaises(AssertionError):
                    check_human_playability_proof.validate_status(status)

    def test_cli_compares_status_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            baseline = tmpdir / "status.early.txt"
            final = tmpdir / "status.txt"
            baseline.write_text(
                make_status(
                    gtic="00000010",
                    leveltime="00000010",
                    keyirq="00000001",
                    keyqueue="00000001",
                    keypoll="00000001",
                    mouseirq="00000000",
                    mousepkt="00000000",
                    mousepoll="00000000",
                    mousebtn="00000000",
                    mousedelta="00000000:00000000",
                )
            )
            fire = tmpdir / "status.after-fire.txt"
            start = tmpdir / "status.after-start.txt"
            movement = tmpdir / "status.after-move.txt"
            use = tmpdir / "status.after-use.txt"
            mouse = tmpdir / "status.after-mouse.txt"
            menu = tmpdir / "status.after-menu.txt"
            fire.write_text(
                make_status(
                    gtic="00000020",
                    leveltime="00000020",
                    keyirq="00000002",
                    keyqueue="00000002",
                    keypoll="00000002",
                    pflags="000000C5",
                )
            )
            start.write_text(
                make_status(
                    gtic="00000015",
                    leveltime="00000015",
                    keyirq="00000001",
                    keyqueue="00000001",
                    keypoll="00000001",
                    pflags="00000001",
                    gflags="00000000",
                    pdelta="00000000",
                )
            )
            movement.write_text(
                make_status(
                    gtic="00000030",
                    leveltime="00000030",
                    keyirq="00000003",
                    keyqueue="00000003",
                    keypoll="00000003",
                    pflags="00000023",
                    ppos="00010020:00020000",
                )
            )
            use.write_text(
                make_status(
                    gtic="00000040",
                    leveltime="00000040",
                    keyirq="00000004",
                    keyqueue="00000004",
                    keypoll="00000004",
                    pflags="00000009",
                )
            )
            mouse.write_text(
                make_status(
                    gtic="00000050",
                    leveltime="00000050",
                    keyirq="00000004",
                    keyqueue="00000004",
                    keypoll="00000004",
                    mouseirq="00000002",
                    mousepkt="00000002",
                    mousepoll="00000002",
                    mousebtn="00000001",
                    mousedelta="00000018:0000000C",
                )
            )
            menu.write_text(
                make_status(
                    gtic="00000060",
                    leveltime="00000060",
                    keyirq="00000005",
                    keyqueue="00000005",
                    keypoll="00000005",
                    pflags="00000011",
                    gflags="00000001",
                )
            )
            final.write_text(
                make_status(
                    gtic="00000070",
                    leveltime="00000070",
                    keyirq="00000005",
                    keyqueue="00000005",
                    keypoll="00000005",
                    pflags="000000FF",
                )
            )

            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--baseline",
                    str(baseline),
                    "--start",
                    str(start),
                    "--fire",
                    str(fire),
                    "--movement",
                    str(movement),
                    "--use",
                    str(use),
                    "--mouse",
                    str(mouse),
                    "--menu",
                    str(menu),
                    str(final),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("human-playability proof OK", result.stdout)

    def test_mouse_phase_requires_mouse_counters_to_reach_doom(self):
        baseline = make_status(
            gtic="00000010",
            leveltime="00000010",
            mouseirq="00000000",
            mousepkt="00000000",
            mousepoll="00000000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
        )
        mouse = make_status(
            gtic="00000020",
            leveltime="00000020",
            mouse="OK",
            mouseirq="00000001",
            mousepkt="00000001",
            mousepoll="00000001",
            mousebtn="00000001",
            mousedelta="00000018:0000000C",
        )
        check_human_playability_proof.validate_status(
            make_status(
                gtic="00000030",
                leveltime="00000030",
                keyirq="00000003",
                keyqueue="00000003",
                keypoll="00000003",
            ),
            baseline,
            mouse_status=mouse,
        )

        for field in ("mouseirq", "mousepkt", "mousepoll"):
            with self.subTest(field=field):
                bad_mouse = make_status(**{field: "00000000"})
                with self.assertRaisesRegex(AssertionError, field):
                    check_human_playability_proof.validate_status(
                        make_status(
                            gtic="00000030",
                            leveltime="00000030",
                            keyirq="00000003",
                            keyqueue="00000003",
                            keypoll="00000003",
                        ),
                        baseline,
                        mouse_status=bad_mouse,
                    )

        for field, value in (
            ("mousebtn", "00000000"),
            ("mousedelta", "00000000:0000000C"),
            ("mousedelta", "00000018:00000000"),
        ):
            with self.subTest(field=field, value=value):
                bad_mouse = make_status(**{field: value})
                with self.assertRaisesRegex(AssertionError, field):
                    check_human_playability_proof.validate_status(
                        make_status(
                            gtic="00000030",
                            leveltime="00000030",
                            keyirq="00000003",
                            keyqueue="00000003",
                            keypoll="00000003",
                        ),
                        baseline,
                        mouse_status=bad_mouse,
                    )

    def test_tool_reads_status_only(self):
        source = TOOL.read_text()
        for forbidden in ("gfx.bin", "vga.bin", "pmemsave", "0xa0000", "disk.img"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)

    def test_playable_cloud_proof_sources_are_wired(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        smoke_runner = (ROOT / "tests" / "run_smoke_qemu.sh").read_text()
        workflow = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        real_checker = (ROOT / "tools" / "check_real_wad_proof.py").read_text()

        self.assertIn("VIBE_PLAYABLE_STATUS = 0x80000000u", header)
        for source in (
            "VIBE_PLAYABLE_STATUS = 0x80000000u",
            "VIBE_PLAYABLE_SEEN_MOVE_CMD",
            "VIBE_PLAYABLE_SEEN_ATTACK_CMD",
            "VIBE_PLAYABLE_SEEN_USE_CMD",
            "VIBE_PLAYABLE_SEEN_MENU",
            "VIBE_PLAYABLE_SEEN_POS_DELTA",
            "VIBE_PLAYABLE_SEEN_AMMO_DELTA",
            "VIBE_PLAYABLE_SEEN_REFIRE",
        ):
            with self.subTest(source=source):
                self.assertIn(source, header)
        for source in (
            "VIBE_PLAYABLE_STATUS",
            "VIBE_PLAYABLE_SEEN_MOVE_CMD",
            "VIBE_PLAYABLE_SEEN_ATTACK_CMD",
            "VIBE_PLAYABLE_SEEN_USE_CMD",
            "VIBE_PLAYABLE_SEEN_MENU",
            "VIBE_PLAYABLE_SEEN_POS_DELTA",
            "VIBE_PLAYABLE_SEEN_AMMO_DELTA",
            "VIBE_PLAYABLE_SEEN_REFIRE",
        ):
            with self.subTest(source=source):
                self.assertIn(source, platform)

        for source in (
            "static void report_playability_status(void)",
            "players[consoleplayer]",
            "player->cmd.forwardmove",
            "player->cmd.buttons & BT_ATTACK",
            "player->cmd.buttons & BT_USE",
            "player->mo->x",
            "player->mo->y",
            "report_playability_status();",
        ):
            self.assertIn(source, platform)

        for source in (
            "PLAYABLE_STATUS_FLAG equ 0x80000000",
            "test ebx, PLAYABLE_STATUS_FLAG",
            "doom_player_flags",
            "doom_player_buttons",
            "doom_game_action",
            "doom_player_delta",
            'smoke_gflags_text db " gflags="',
            'smoke_pflags_text db " pflags="',
            'smoke_ppos_text db " ppos="',
            'smoke_pdelta_text db " pdelta="',
            'smoke_mousebtn_text db " mousebtn="',
            'smoke_mousedelta_text db " mousedelta="',
        ):
            self.assertIn(source, kernel)

        for source in (
            "SMOKE_INPUT_SCRIPT ?=",
            "SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF ?= 0",
            'grep -q "pflags="',
            'human_args="--baseline $(BUILD_DIR)/status.early.txt"',
            "tools/check_human_playability_proof.py $$human_args $(BUILD_DIR)/status.txt",
        ):
            self.assertIn(source, makefile)

        for source in (
            "SMOKE_INPUT_SCRIPT",
            "run_input_script",
            "hold=KEY:MILLISECONDS",
            "pmemsave 0x9d000 2048",
        ):
            self.assertIn(source, smoke_runner)

        for source in (
            "after-fire:hold=ctrl:800",
            "after-start:wait=2",
            "after-move:hold=up:1200",
            "after-use:spc",
            "after-mouse:mouse=24:-12",
            "mousebtn=1",
            "after-menu:esc",
            "Assert scripted human-playability gates",
            "build/status.after-start.txt",
            "build/status.after-fire.txt",
            "build/status.after-move.txt",
            "build/status.after-use.txt",
            "build/status.after-mouse.txt",
            "build/status.after-menu.txt",
            'rm -f "$WAD_PATH"',
        ):
            self.assertIn(source, workflow)

        self.assertIn("check_human_playability_proof.validate_status", real_checker)


if __name__ == "__main__":
    unittest.main()
