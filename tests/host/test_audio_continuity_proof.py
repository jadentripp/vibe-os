import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "tools" / "check_audio_continuity_proof.py"

spec = importlib.util.spec_from_file_location("check_audio_continuity_proof", CHECKER)
check_audio_continuity_proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check_audio_continuity_proof)


def status_line(**overrides):
    fields = {
        "audio": "SB16",
        "doomsound": "00000001",
        "sfxmix": "00000001",
        "voices": "00000002",
        "sfxvoices": "00000001",
        "audioirq": "00000001",
        "ack8": "00000001",
        "ack16": "00000000",
        "refill": "00000001",
        "half": "00000001",
        "mixwrap": "00000000",
        "mixover": "00000000",
        "mixunder": "00000000",
        "mixclip": "00000000",
        "steal": "00000000",
        "pitchclamp": "00000000",
        "panclamp": "00000000",
        "musicvoices": "00000001",
        "musicmix": "00000001",
        "musicloop": "00000000",
        "musicpos": "00000001",
        "musicbuf": "00002000",
        "musicunder": "00000000",
        "musicdrops": "00000000",
        "sb16": "00000004:00000005",
        "dma": "00000001",
        "play": "00000001:00000000",
        "voiceq": "00000001:00000000:00000000",
        "musicq": "00000001:00000000",
        "doomrun": "RUN",
        "doomopen": "OK",
        "doomread": "OK",
        "gameplay": "OK",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{key}={value}" for key, value in fields.items())


def snapshot_statuses():
    return {
        "baseline": status_line(),
        "fire": status_line(
            doomsound="00000002",
            sfxmix="00000003",
            audioirq="00000002",
            ack8="00000002",
            refill="00000002",
            musicmix="00000002",
            musicpos="00000400",
            musicbuf="00001C00",
            voiceq="00000001:00000000:00000001",
        ),
        "movement": status_line(
            doomsound="00000002",
            sfxmix="00000004",
            audioirq="00000003",
            ack8="00000003",
            refill="00000003",
            musicmix="00000003",
            musicpos="00000800",
            musicbuf="00001800",
            voiceq="00000001:00000000:00000002",
        ),
        "use": status_line(
            doomsound="00000003",
            sfxmix="00000005",
            audioirq="00000004",
            ack8="00000004",
            refill="00000004",
            musicmix="00000004",
            musicpos="00000C00",
            musicbuf="00001400",
            voiceq="00000001:00000000:00000003",
        ),
        "menu": status_line(
            doomsound="00000004",
            sfxmix="00000006",
            audioirq="00000005",
            ack8="00000005",
            refill="00000005",
            musicmix="00000005",
            musicloop="00000001",
            musicpos="00001000",
            musicbuf="00001000",
            voiceq="00000001:00000000:00000004",
        ),
        "final": status_line(
            doomsound="00000004",
            sfxmix="00000008",
            audioirq="00000006",
            ack8="00000006",
            refill="00000006",
            musicmix="00000006",
            musicloop="00000001",
            musicpos="00001400",
            musicbuf="00000C00",
            voiceq="00000001:00000000:00000005",
        ),
    }


class AudioContinuityProofTests(unittest.TestCase):
    def test_accepts_sb16_counter_progression_across_snapshots(self):
        snapshots = snapshot_statuses()
        check_audio_continuity_proof.validate_status(
            snapshots["final"],
            baseline_status=snapshots["baseline"],
            fire_status=snapshots["fire"],
            movement_status=snapshots["movement"],
            use_status=snapshots["use"],
            menu_status=snapshots["menu"],
        )

    def test_accepts_final_snapshot_after_stream_voice_drained(self):
        snapshots = snapshot_statuses()
        snapshots["final"] = snapshots["final"].replace("musicvoices=00000001", "musicvoices=00000000")
        snapshots["final"] = snapshots["final"].replace("voices=00000002", "voices=00000001")
        snapshots["final"] = snapshots["final"].replace("musicbuf=00000C00", "musicbuf=00000000")

        check_audio_continuity_proof.validate_status(
            snapshots["final"],
            baseline_status=snapshots["baseline"],
            fire_status=snapshots["fire"],
            movement_status=snapshots["movement"],
            use_status=snapshots["use"],
            menu_status=snapshots["menu"],
        )

    def test_rejects_audio_none_for_audible_proof(self):
        snapshots = snapshot_statuses()
        snapshots["final"] = status_line(audio="NONE")

        with self.assertRaisesRegex(AssertionError, "audio=SB16 is required"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_non_monotonic_or_non_progressing_audio_counters(self):
        snapshots = snapshot_statuses()
        snapshots["movement"] = status_line(
            doomsound="00000002",
            sfxmix="00000001",
            audioirq="00000003",
            ack8="00000003",
            refill="00000003",
            musicmix="00000003",
        )

        with self.assertRaisesRegex(AssertionError, "sfxmix=.*monotonic"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

        flat = snapshot_statuses()
        flat["final"] = status_line(musicloop="00000001")
        with self.assertRaisesRegex(AssertionError, "audioirq=.*increase"):
            check_audio_continuity_proof.validate_status(
                flat["final"],
                baseline_status=flat["baseline"],
                fire_status=flat["baseline"],
                movement_status=flat["baseline"],
                use_status=flat["baseline"],
                menu_status=flat["baseline"],
            )

    def test_rejects_mixing_without_sb16_dma_playback_or_queued_voices(self):
        snapshots = snapshot_statuses()
        snapshots["final"] = status_line(dma="00000000", musicloop="00000001")
        with self.assertRaisesRegex(AssertionError, "final dma="):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

        snapshots = snapshot_statuses()
        snapshots["final"] = status_line(play="00000000:00000000", musicloop="00000001")
        with self.assertRaisesRegex(AssertionError, "final play="):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

        snapshots = snapshot_statuses()
        snapshots["final"] = status_line(voiceq="00000000:00000000:00000000", musicloop="00000001")
        with self.assertRaisesRegex(AssertionError, "final voiceq="):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_music_carrier_without_independent_sfx_progress(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("sfxmix=00000003", "sfxmix=00000001")
            snapshots[label] = snapshots[label].replace("sfxmix=00000004", "sfxmix=00000001")
            snapshots[label] = snapshots[label].replace("sfxmix=00000005", "sfxmix=00000001")
            snapshots[label] = snapshots[label].replace("sfxmix=00000006", "sfxmix=00000001")
            snapshots[label] = snapshots[label].replace("sfxmix=00000008", "sfxmix=00000001")

        with self.assertRaisesRegex(AssertionError, "sfxmix=.*increase"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_music_without_stream_chunk_updates(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("voiceq=00000001:00000000:00000001", "voiceq=00000001:00000000:00000000")
            snapshots[label] = snapshots[label].replace("voiceq=00000001:00000000:00000002", "voiceq=00000001:00000000:00000000")
            snapshots[label] = snapshots[label].replace("voiceq=00000001:00000000:00000003", "voiceq=00000001:00000000:00000000")
            snapshots[label] = snapshots[label].replace("voiceq=00000001:00000000:00000004", "voiceq=00000001:00000000:00000000")
            snapshots[label] = snapshots[label].replace("voiceq=00000001:00000000:00000005", "voiceq=00000001:00000000:00000000")

        with self.assertRaisesRegex(AssertionError, "voiceq=.*stream update"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_never_active_music_voice(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("musicvoices=00000001", "musicvoices=00000000")

        with self.assertRaisesRegex(AssertionError, "musicvoices=.*at least one snapshot"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_missing_sfx_voice_lane_or_incoherent_voice_total(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("sfxvoices=00000001", "sfxvoices=00000000")
            snapshots[label] = snapshots[label].replace("voices=00000002", "voices=00000001")

        with self.assertRaisesRegex(AssertionError, "sfxvoices=.*at least one snapshot"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

        snapshots = snapshot_statuses()
        snapshots["fire"] = snapshots["fire"].replace("voices=00000002", "voices=00000001")
        with self.assertRaisesRegex(AssertionError, "voices=.*sfxvoices=.*musicvoices"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_music_stream_without_buffered_window_evidence(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("musicbuf=00002000", "musicbuf=00000000")
            snapshots[label] = snapshots[label].replace("musicbuf=00001C00", "musicbuf=00000000")
            snapshots[label] = snapshots[label].replace("musicbuf=00001800", "musicbuf=00000000")
            snapshots[label] = snapshots[label].replace("musicbuf=00001400", "musicbuf=00000000")
            snapshots[label] = snapshots[label].replace("musicbuf=00001000", "musicbuf=00000000")
            snapshots[label] = snapshots[label].replace("musicbuf=00000C00", "musicbuf=00000000")

        with self.assertRaisesRegex(AssertionError, "musicbuf=.*at least one snapshot"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_stream_updates_without_kernel_music_position_progress(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("musicpos=00000400", "musicpos=00000001")
            snapshots[label] = snapshots[label].replace("musicpos=00000800", "musicpos=00000001")
            snapshots[label] = snapshots[label].replace("musicpos=00000C00", "musicpos=00000001")
            snapshots[label] = snapshots[label].replace("musicpos=00001000", "musicpos=00000001")
            snapshots[label] = snapshots[label].replace("musicpos=00001400", "musicpos=00000001")

        with self.assertRaisesRegex(AssertionError, "musicpos=.*increase"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_cli_auto_discovers_phase_status_files(self):
        snapshots = snapshot_statuses()
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            final = tmpdir / "status.txt"
            final.write_text(snapshots["final"])
            (tmpdir / "status.after-start.txt").write_text(snapshots["baseline"])
            (tmpdir / "status.after-fire.txt").write_text(snapshots["fire"])
            (tmpdir / "status.after-move.txt").write_text(snapshots["movement"])
            (tmpdir / "status.after-use.txt").write_text(snapshots["use"])
            (tmpdir / "status.after-menu.txt").write_text(snapshots["menu"])

            result = subprocess.run(
                [sys.executable, str(CHECKER), str(final)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("audio continuity proof OK", result.stdout)

    def test_repo_contract_is_wired_without_local_qemu(self):
        check_audio_continuity_proof.validate_repo_contract()

        source = CHECKER.read_text()
        self.assertNotIn("qemu" + "-system", source)
        self.assertNotIn("pmemsave", source)


if __name__ == "__main__":
    unittest.main()
