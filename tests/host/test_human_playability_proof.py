import hashlib
import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "check_human_playability_proof.py"
sys.path.insert(0, str(ROOT / "tools"))
spec = importlib.util.spec_from_file_location("check_human_playability_proof", TOOL)
check_human_playability_proof = importlib.util.module_from_spec(spec)
try:
    spec.loader.exec_module(check_human_playability_proof)
finally:
    sys.path.pop(0)


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
        "pflags": "000001FF",
        "pbuttons": "00000000",
        "ppos": "00010000:00020000",
        "pdelta": "00000100",
        "keyirq": "00000002",
        "keyqueue": "00000002",
        "keypoll": "00000002",
        "keyseen": "00000071",
        "keylast": "0001001B",
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


def write_human_session_bundle(tmpdir, *, final_tick="000001B0", commit="abcdef123456"):
    tmpdir = Path(tmpdir)
    statuses = {
        "status.early.txt": make_status(
            gtic="00000010",
            leveltime="00000010",
            keyirq="00000000",
            keyqueue="00000000",
            keypoll="00000000",
            keyseen="00000000",
            keylast="00000000",
            mouseirq="00000000",
            mousepkt="00000000",
            mousepoll="00000000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
            pflags="00000001",
            gflags="00000000",
            pdelta="00000000",
        ),
        "status.after-start.txt": make_status(
            gtic="00000020",
            leveltime="00000020",
            keyirq="00000000",
            keyqueue="00000000",
            keypoll="00000000",
            keyseen="00000000",
            keylast="00000000",
            mouseirq="00000000",
            mousepkt="00000000",
            mousepoll="00000000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
            pflags="00000001",
            gflags="00000000",
            pdelta="00000000",
        ),
        "status.after-fire.txt": make_status(
            gtic="00000060",
            leveltime="00000060",
            keyirq="00000001",
            keyqueue="00000001",
            keypoll="00000001",
            keyseen="00000010",
            keylast="0001019D",
            pflags="000000C5",
        ),
        "status.after-move.txt": make_status(
            gtic="00000090",
            leveltime="00000090",
            keyirq="00000002",
            keyqueue="00000002",
            keypoll="00000002",
            keyseen="00000011",
            keylast="000101AD",
            pflags="00000023",
            ppos="00010020:00020000",
        ),
        "status.after-use.txt": make_status(
            gtic="000000C0",
            leveltime="000000C0",
            keyirq="00000003",
            keyqueue="00000003",
            keypoll="00000003",
            keyseen="00000031",
            keylast="00010020",
            pflags="00000009",
        ),
        "status.after-mouse.txt": make_status(
            gtic="00000100",
            leveltime="00000100",
            keyirq="00000003",
            keyqueue="00000003",
            keypoll="00000003",
            keyseen="00000031",
            mouseirq="00000001",
            mousepkt="00000001",
            mousepoll="00000001",
            mousebtn="00000001",
            mousedelta="00000018:0000000C",
            pflags="00000109",
        ),
        "status.after-menu.txt": make_status(
            gtic="00000180",
            leveltime="00000180",
            keyirq="00000004",
            keyqueue="00000004",
            keypoll="00000004",
            keyseen="00000071",
            keylast="0001001B",
            pflags="00000011",
            gflags="00000001",
            mouseirq="00000001",
            mousepkt="00000001",
            mousepoll="00000001",
            mousebtn="00000001",
        ),
        "status.txt": make_status(
            gtic=final_tick,
            leveltime=final_tick,
            keyirq="00000004",
            keyqueue="00000004",
            keypoll="00000004",
            keyseen="00000071",
            keylast="0001001B",
            pflags="000001F7",
            gflags="00000001",
            mouseirq="00000001",
            mousepkt="00000001",
            mousepoll="00000001",
            mousebtn="00000001",
        ),
    }
    for name, status in statuses.items():
        (tmpdir / name).write_text(status)

    def digest(name):
        return hashlib.sha256((tmpdir / name).read_bytes()).hexdigest()

    notes = {
        "schema": "human-playtest-notes-v2",
        "commit": commit,
        "ref": "main",
        "scripted_proof": "real-wad-smoke-pass",
        "scripted_proof_run_id": "1234567890",
        "scripted_proof_url": "https://github.com/jadentripp/vibe-os/actions/runs/1234567890",
        "scripted_proof_checked": "green-before-human-session",
        "proof_basis": "scripted-green-plus-remote-vnc-human",
        "playtester": "jt",
        "remote_host": "disposable",
        "qemu_location": "remote",
        "qemu_display": "127.0.0.1:1",
        "monitor_socket": "unix-monitor-socket",
        "vnc_tunnel": "loopback-only",
        "vnc_endpoint": "127.0.0.1:5901",
        "wad": "shareware-v1.9-validated-remote-only",
        "display": "pass",
        "keyboard": "pass",
        "mouse": "pass",
        "audio": "status-only",
        "visual_evidence": "e1m1-visible-via-remote-vnc",
        "keyboard_evidence": "fire-move-use-menu-visible",
        "mouse_evidence": "motion-click-visible",
        "menu_evidence": "escape-menu-visible",
        "audio_evidence": "status-only-sb16-continuity",
        "audio_notes": "vnc-display-input-only-sb16-status",
        "slowdown": "not-observed",
        "slowdown_notes": "not-observed-during-capture",
        "novnc_focus": "canvas-focused-before-actions",
        "novnc_focus_notes": "canvas-clicked-before-each-manual-action",
        "status_capture": "monitor-pmemsave-0x9d000",
        "session_phases": (
            "early,after-start,after-fire,after-move,after-use,after-mouse,"
            "after-menu,final"
        ),
        "phase_hash_early": digest("status.early.txt"),
        "phase_hash_after_start": digest("status.after-start.txt"),
        "phase_hash_after_fire": digest("status.after-fire.txt"),
        "phase_hash_after_move": digest("status.after-move.txt"),
        "phase_hash_after_use": digest("status.after-use.txt"),
        "phase_hash_after_mouse": digest("status.after-mouse.txt"),
        "phase_hash_after_menu": digest("status.after-menu.txt"),
        "phase_hash_final": digest("status.txt"),
        "diagnostics": "non-wad-status-only",
        "proof_bundle": "allowlisted-status-only",
        "no_local_qemu": "yes",
        "no_wad_upload": "yes",
        "no_disk_upload": "yes",
        "no_pixel_upload": "yes",
        "no_screenshot_upload": "yes",
        "no_raw_audio_upload": "yes",
        "operator_scripted_proof_green": "confirmed",
        "operator_remote_vnc": "confirmed",
        "operator_e1m1_visible": "confirmed",
        "operator_keyboard_fire": "confirmed",
        "operator_keyboard_move": "confirmed",
        "operator_keyboard_use": "confirmed",
        "operator_mouse_action": "confirmed",
        "operator_menu_escape": "confirmed",
        "operator_audio_observation": "recorded",
        "operator_slowdown_notes": "recorded",
        "operator_novnc_focus_observation": "recorded",
        "operator_phase_actions": "confirmed",
        "operator_phase_status_hashes": "confirmed",
        "operator_no_forbidden_artifacts": "confirmed",
        "operator_post_download_verification": "required",
    }
    notes_path = tmpdir / "human-playtest-notes.txt"
    notes_path.write_text("\n".join(f"{key}={value}" for key, value in notes.items()) + "\n")
    return notes_path


class HumanPlayabilityProofTests(unittest.TestCase):
    def test_accepts_final_status_with_keyboard_counters(self):
        check_human_playability_proof.validate_status(make_status())

    def test_rejects_duplicate_human_phase_status_field(self):
        with self.assertRaisesRegex(AssertionError, "fire snapshot: duplicate keyseen= field"):
            check_human_playability_proof.validate_status(
                make_status(),
                start_status=make_status(gtic="00000010", leveltime="00000010"),
                fire_status=make_status(
                    gtic="00000020",
                    leveltime="00000020",
                    keyseen="00000010",
                )
                + " keyseen=00000011",
            )

    def test_requires_keyboard_and_runtime_deltas_from_baseline(self):
        baseline = make_status(
            gtic="00000010",
            leveltime="00000010",
            keyirq="00000001",
            keyqueue="00000001",
            keypoll="00000001",
            keyseen="00000000",
            keylast="00000000",
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
            make_status(keyseen="00000031"),
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
                    keyseen="00000000",
                    keylast="00000000",
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
                    keyseen="00000010",
                    keylast="0001019D",
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
                    keyseen="00000000",
                    keylast="00000000",
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
                    keyseen="00000011",
                    keylast="000101AD",
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
                    keyseen="00000031",
                    keylast="00010020",
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
                    keyseen="00000031",
                    mouseirq="00000002",
                    mousepkt="00000002",
                    mousepoll="00000002",
                    mousebtn="00000001",
                    mousedelta="00000018:0000000C",
                    pflags="00000109",
                )
            )
            menu.write_text(
                make_status(
                    gtic="00000060",
                    leveltime="00000060",
                    keyirq="00000005",
                    keyqueue="00000005",
                    keypoll="00000005",
                    keyseen="00000071",
                    keylast="0001001B",
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
                    keyseen="00000071",
                    keylast="0001001B",
                    pflags="000001F7",
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
            auto_result = subprocess.run(
                [sys.executable, str(TOOL), str(final)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("human-playability proof OK", result.stdout)
        self.assertEqual(auto_result.returncode, 0, auto_result.stderr)
        self.assertIn("human-playability proof OK", auto_result.stdout)

    def test_cli_requires_full_manual_human_session_contract(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            notes = write_human_session_bundle(tmpdir)
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--require-human-session",
                    "--human-notes",
                    str(notes),
                    "--expected-commit",
                    "abcdef123456",
                    "--expected-scripted-proof-run-id",
                    "1234567890",
                    str(tmpdir / "status.txt"),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("manual remote VNC session", result.stdout)
        self.assertIn("human-session evidence:", result.stdout)
        self.assertIn("duration_gtic=", result.stdout)
        self.assertIn("required_ticks=350", result.stdout)
        self.assertIn("phases=early->after-start->after-fire", result.stdout)
        self.assertIn("mouse_delta=00000018:0000000C", result.stdout)
        self.assertIn("audio_evidence=status-only-sb16-continuity", result.stdout)
        self.assertIn("novnc_focus=canvas-focused-before-actions", result.stdout)

    def test_manual_human_session_rejects_short_duration(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            notes = write_human_session_bundle(tmpdir, final_tick="00000080")
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--require-human-session",
                    "--human-notes",
                    str(notes),
                    str(tmpdir / "status.txt"),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("at least 350", result.stderr)

    def test_manual_human_session_rejects_dirty_baseline_actions(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            notes = write_human_session_bundle(tmpdir)
            (tmpdir / "status.early.txt").write_text(
                (tmpdir / "status.early.txt").read_text().replace(
                    "keyseen=00000000",
                    "keyseen=00000010",
                )
            )
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--require-human-session",
                    "--human-notes",
                    str(notes),
                    str(tmpdir / "status.txt"),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("early snapshot keyseen=", result.stderr)

    def test_manual_human_session_rejects_identity_mismatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            notes = write_human_session_bundle(tmpdir)
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--require-human-session",
                    "--human-notes",
                    str(notes),
                    "--expected-commit",
                    "deadbeef1234",
                    str(tmpdir / "status.txt"),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("commit= must match expected commit", result.stderr)

    def test_manual_human_session_rejects_phase_hash_tampering(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            notes = write_human_session_bundle(tmpdir)
            with (tmpdir / "status.after-fire.txt").open("a") as handle:
                handle.write(" ")
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--require-human-session",
                    "--human-notes",
                    str(notes),
                    str(tmpdir / "status.txt"),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("phase_hash_after_fire", result.stderr)

    def test_manual_human_session_rejects_unknown_note_field(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            notes = write_human_session_bundle(tmpdir)
            with notes.open("a") as handle:
                handle.write("screenshot_path=not-allowed\n")
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--require-human-session",
                    "--human-notes",
                    str(notes),
                    str(tmpdir / "status.txt"),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unsupported field", result.stderr)

    def test_manual_human_session_rejects_forbidden_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            notes = write_human_session_bundle(tmpdir)
            (tmpdir / "DOOM1.WAD").write_bytes(b"IWAD")
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--require-human-session",
                    "--human-notes",
                    str(notes),
                    str(tmpdir / "status.txt"),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("forbidden human proof artifact", result.stderr)

    def test_mouse_phase_requires_mouse_counters_to_reach_doom(self):
        baseline = make_status(
            gtic="00000010",
            leveltime="00000010",
            mouseirq="00000000",
            mousepkt="00000000",
            mousepoll="00000000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
            keyseen="00000031",
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
            keyseen="00000031",
            pflags="00000109",
        )
        check_human_playability_proof.validate_status(
            make_status(
                gtic="00000030",
                leveltime="00000030",
                keyirq="00000003",
                keyqueue="00000003",
                keypoll="00000003",
                keyseen="00000071",
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
                            keyseen="00000071",
                        ),
                        baseline,
                        mouse_status=bad_mouse,
                    )

        for field, value in (
            ("mousebtn", "00000000"),
            ("mousedelta", "00000000:00000000"),
            ("pflags", "00000009"),
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
        for forbidden in ("qemu-system", "subprocess.run", "pmemsave 0xa0000", "0xa0000"):
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
            "VIBE_PLAYABLE_SEEN_TURN_CMD",
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
            "VIBE_PLAYABLE_SEEN_TURN_CMD",
        ):
            with self.subTest(source=source):
                self.assertIn(source, platform)

        for source in (
            "static void report_playability_status(void)",
            "players[consoleplayer]",
            "player->cmd.forwardmove",
            "player->cmd.angleturn",
            "player->cmd.buttons & BT_ATTACK",
            "player->cmd.buttons & BT_USE",
            "player->mo->x",
            "player->mo->y",
            "player->mo->angle",
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
            'smoke_keyseen_text db " keyseen="',
            'smoke_keylast_text db " keylast="',
            'smoke_mousebtn_text db " mousebtn="',
            'smoke_mousedelta_text db " mousedelta="',
        ):
            self.assertIn(source, kernel)

        for source in (
            "SMOKE_INPUT_SCRIPT ?=",
            "SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF ?= 0",
            'grep -q "pflags="',
            'human_args="--baseline $(BUILD_DIR)/status.after-start.txt --start $(BUILD_DIR)/status.after-start.txt"',
            "tools/check_human_playability_proof.py $$human_args $(BUILD_DIR)/status.txt",
        ):
            self.assertIn(source, makefile)

        for source in (
            "SMOKE_INPUT_SCRIPT",
            "run_input_script",
            "hold=KEY:MILLISECONDS",
            "pmemsave 0x9d000 8192",
        ):
            self.assertIn(source, smoke_runner)

        for source in (
            "after-fire:hold=ctrl:800",
            "after-start:wait=2",
            "after-move:hold=up:1200",
            "after-use:hold=spc:3000,snapshot,wait=2",
            "after-mouse:mousebtn=1,wait=1,mouse=4:0,wait=1,mousebtn=0,wait=1,mouse=64:0",
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
