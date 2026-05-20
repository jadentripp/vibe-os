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
        "sfxq": "00000001:00000000:00000000:00000000",
        "sfxbytes": "00000400:00000400",
        "sfxdma": "00000001:00000400",
        "sfxsrc": "00000001",
        "sfxlast": "00000001:00002B11:00000400",
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
        "musicstream": "PULL",
        "musicpull": "00000000:00000000",
        "musicrend": "00000001:00000001:00000002:00000003:00000001:00008000",
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
            sfxq="00000002:00000000:00000000:00000000",
            sfxbytes="00000800:00000C00",
            sfxdma="00000003:00000C00",
            sfxsrc="00000002",
            sfxlast="00000001:00002B11:00000400",
            audioirq="00000002",
            ack8="00000002",
            refill="00000002",
            musicmix="00000002",
            musicpos="00000400",
            musicbuf="00001C00",
            musicpull="00000001:00000001",
            musicrend="00000001:00000002:00000004:00000006:00000001:00010000",
            voiceq="00000001:00000000:00000001",
        ),
        "movement": status_line(
            doomsound="00000002",
            sfxmix="00000004",
            sfxq="00000002:00000000:00000000:00000000",
            sfxbytes="00000800:00001000",
            sfxdma="00000004:00001000",
            sfxsrc="00000002",
            audioirq="00000003",
            ack8="00000003",
            refill="00000003",
            musicmix="00000003",
            musicpos="00000800",
            musicbuf="00001800",
            musicpull="00000002:00000002",
            musicrend="00000001:00000003:00000006:00000009:00000001:00018000",
            voiceq="00000001:00000000:00000002",
        ),
        "use": status_line(
            doomsound="00000003",
            sfxmix="00000005",
            sfxq="00000003:00000000:00000001:00000000",
            sfxbytes="00000C00:00001400",
            sfxdma="00000005:00001400",
            sfxsrc="00000003",
            sfxlast="00000020:00002B11:00000400",
            audioirq="00000004",
            ack8="00000004",
            refill="00000004",
            musicmix="00000004",
            musicpos="00000C00",
            musicbuf="00001400",
            musicpull="00000003:00000003",
            musicrend="00000001:00000004:00000008:0000000C:00000001:00020000",
            voiceq="00000001:00000000:00000003",
        ),
        "menu": status_line(
            doomsound="00000004",
            sfxmix="00000006",
            sfxq="00000004:00000000:00000001:00000000",
            sfxbytes="00001000:00001800",
            sfxdma="00000006:00001800",
            sfxsrc="00000004",
            sfxlast="0000003E:00002B11:00000400",
            audioirq="00000005",
            ack8="00000005",
            refill="00000005",
            musicmix="00000005",
            musicloop="00000001",
            musicpos="00001000",
            musicbuf="00001000",
            musicpull="00000004:00000004",
            musicrend="00000001:00000005:0000000A:0000000F:00000001:00028000",
            voiceq="00000001:00000000:00000004",
        ),
        "final": status_line(
            doomsound="00000004",
            sfxmix="00000008",
            sfxq="00000004:00000000:00000001:00000001",
            sfxbytes="00001000:00002000",
            sfxdma="00000008:00002000",
            sfxsrc="00000004",
            sfxlast="0000003E:00002B11:00000400",
            audioirq="00000006",
            ack8="00000006",
            refill="00000006",
            musicmix="00000006",
            musicloop="00000001",
            musicpos="00001400",
            musicbuf="00000C00",
            musicpull="00000005:00000005",
            musicrend="00000001:00000006:0000000C:00000012:00000001:00030000",
            voiceq="00000001:00000000:00000005",
        ),
    }


def pull_snapshot_statuses():
    return snapshot_statuses()


def push_snapshot_statuses():
    snapshots = snapshot_statuses()
    for label, status in list(snapshots.items()):
        current_pull = status.split("musicpull=")[1].split()[0]
        snapshots[label] = status.replace("musicstream=PULL", "musicstream=PUSH")
        snapshots[label] = snapshots[label].replace(
            f"musicpull={current_pull}",
            "musicpull=00000000:00000000",
        )
    return snapshots


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
        with self.assertRaisesRegex(AssertionError, "doomsound=.*increase"):
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

        with self.assertRaisesRegex(AssertionError, "voiceq=.*stream update service"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_future_pull_stream_contract_requires_mode_and_pull_counters(self):
        snapshots = push_snapshot_statuses()
        with self.assertRaisesRegex(AssertionError, "musicstream=PULL is required"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
                require_pull_stream=True,
            )

        pull_snapshots = pull_snapshot_statuses()
        check_audio_continuity_proof.validate_status(
            pull_snapshots["final"],
            baseline_status=pull_snapshots["baseline"],
            fire_status=pull_snapshots["fire"],
            movement_status=pull_snapshots["movement"],
            use_status=pull_snapshots["use"],
            menu_status=pull_snapshots["menu"],
            require_pull_stream=True,
        )

    def test_rejects_pull_mode_without_hardware_paced_counters(self):
        snapshots = pull_snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace(
                f"musicpull={status.split('musicpull=')[1].split()[0]}",
                "musicpull=00000000:00000000",
            )

        with self.assertRaisesRegex(AssertionError, "musicpull=.*pull request"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
                require_pull_stream=True,
            )

    def test_rejects_missing_music_stream_mode_for_music_proof(self):
        snapshots = snapshot_statuses()
        snapshots["final"] = snapshots["final"].replace("musicstream=PULL", "musicstream=NONE")

        with self.assertRaisesRegex(AssertionError, "musicstream=.*PUSH or PULL"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_single_stream_update_as_too_little_long_playback_health(self):
        snapshots = snapshot_statuses()
        snapshots["fire"] = snapshots["fire"].replace("musicpull=00000001:00000001", "musicpull=00000001:00000000")
        snapshots["movement"] = snapshots["movement"].replace("musicpull=00000002:00000002", "musicpull=00000002:00000000")
        snapshots["use"] = snapshots["use"].replace("musicpull=00000003:00000003", "musicpull=00000003:00000000")
        snapshots["menu"] = snapshots["menu"].replace("musicpull=00000004:00000004", "musicpull=00000004:00000001")
        snapshots["final"] = snapshots["final"].replace("musicpull=00000005:00000005", "musicpull=00000005:00000001")

        with self.assertRaisesRegex(AssertionError, "at least 2"):
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

    def test_accepts_drained_sfx_voice_lane_but_rejects_incoherent_voice_total(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("sfxvoices=00000001", "sfxvoices=00000000")
            snapshots[label] = snapshots[label].replace("voices=00000002", "voices=00000001")

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

    def test_rejects_static_music_buffer_health(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("musicbuf=00002000", "musicbuf=00001000")
            snapshots[label] = snapshots[label].replace("musicbuf=00001C00", "musicbuf=00001000")
            snapshots[label] = snapshots[label].replace("musicbuf=00001800", "musicbuf=00001000")
            snapshots[label] = snapshots[label].replace("musicbuf=00001400", "musicbuf=00001000")
            snapshots[label] = snapshots[label].replace("musicbuf=00000C00", "musicbuf=00001000")

        with self.assertRaisesRegex(AssertionError, "changing stream-window health"):
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

    def test_rejects_music_flagged_carrier_without_renderer_evidence(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace(
                status.split("musicrend=")[1].split()[0],
                "00000000:00000000:00000000:00000000:00000000:00000000",
            )

        with self.assertRaisesRegex(AssertionError, "musicrend=.*MUS or MIDI"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace(
                status.split("musicrend=")[1].split()[0],
                "00000001:00000006:00000000:00000012:00000001:00030000",
            )

        with self.assertRaisesRegex(AssertionError, "note event evidence"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_too_little_irq_refill_continuity_for_phase_proof(self):
        snapshots = snapshot_statuses()
        snapshots["use"] = snapshots["use"].replace("audioirq=00000004", "audioirq=00000003")
        snapshots["use"] = snapshots["use"].replace("refill=00000004", "refill=00000003")
        snapshots["menu"] = snapshots["menu"].replace("audioirq=00000005", "audioirq=00000003")
        snapshots["menu"] = snapshots["menu"].replace("refill=00000005", "refill=00000003")
        snapshots["final"] = snapshots["final"].replace("audioirq=00000006", "audioirq=00000003")
        snapshots["final"] = snapshots["final"].replace("refill=00000006", "refill=00000003")

        with self.assertRaisesRegex(AssertionError, "audioirq=.*at least"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_fire_phase_without_doom_sfx_progress(self):
        snapshots = snapshot_statuses()
        snapshots["fire"] = snapshots["fire"].replace("doomsound=00000002", "doomsound=00000001")
        snapshots["fire"] = snapshots["fire"].replace("sfxmix=00000003", "sfxmix=00000001")

        with self.assertRaisesRegex(AssertionError, "doomsound=.*scripted fire SFX"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

        snapshots = snapshot_statuses()
        snapshots["fire"] = snapshots["fire"].replace("sfxmix=00000003", "sfxmix=00000001")
        with self.assertRaisesRegex(AssertionError, "sfxmix=.*scripted fire SFX"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_sfx_submit_without_dma_refill_mix(self):
        snapshots = snapshot_statuses()
        for label, status in list(snapshots.items()):
            snapshots[label] = status.replace("sfxdma=00000003:00000C00", "sfxdma=00000001:00000400")
            snapshots[label] = snapshots[label].replace("sfxdma=00000004:00001000", "sfxdma=00000001:00000400")
            snapshots[label] = snapshots[label].replace("sfxdma=00000005:00001400", "sfxdma=00000001:00000400")
            snapshots[label] = snapshots[label].replace("sfxdma=00000006:00001800", "sfxdma=00000001:00000400")
            snapshots[label] = snapshots[label].replace("sfxdma=00000008:00002000", "sfxdma=00000001:00000400")

        with self.assertRaisesRegex(AssertionError, "sfxdma=.*SB16 DMA SFX refill"):
            check_audio_continuity_proof.validate_status(
                snapshots["final"],
                baseline_status=snapshots["baseline"],
                fire_status=snapshots["fire"],
                movement_status=snapshots["movement"],
                use_status=snapshots["use"],
                menu_status=snapshots["menu"],
            )

    def test_rejects_new_clip_underrun_or_drop_counters(self):
        for field, message in (
            ("mixclip", "mixclip=.*audio safety"),
            ("musicunder", "musicunder=.*audio safety"),
            ("musicdrops", "musicdrops=.*audio safety"),
        ):
            with self.subTest(field=field):
                snapshots = snapshot_statuses()
                snapshots["final"] = snapshots["final"].replace(
                    f"{field}=00000000",
                    f"{field}=00000001",
                )
                with self.assertRaisesRegex(AssertionError, message):
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
