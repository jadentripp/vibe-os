import importlib.util
import json
import math
import struct
import subprocess
import sys
import tempfile
import unittest
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "tools" / "check_audible_audio_proof.py"

spec = importlib.util.spec_from_file_location("check_audible_audio_proof", CHECKER)
check_audible_audio_proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check_audible_audio_proof)


def status_line(**overrides):
    fields = {
        "audio": "SB16",
        "doomrun": "RUN",
        "gameplay": "OK",
        "doomsound": "00000001",
        "audioirq": "00000006",
        "ack8": "00000006",
        "ack16": "00000000",
        "refill": "00000006",
        "half": "00000001",
        "voices": "00000002",
        "sfxmix": "00000008",
        "sfxq": "00000004:00000000:00000001:00000001",
        "sfxbytes": "00001000:00002000",
        "sfxdma": "00000008:00002000",
        "sfxsrc": "00000004",
        "sfxlast": "0000003E:00002B11:00000400",
        "sfxvoices": "00000001",
        "musicmix": "00000006",
        "musicloop": "00000001",
        "mixwrap": "00000000",
        "mixover": "00000000",
        "mixunder": "00000000",
        "mixclip": "00000000",
        "steal": "00000000",
        "pitchclamp": "00000000",
        "panclamp": "00000000",
        "musicvoices": "00000001",
        "sb16": "00000004:00000005",
        "musicpos": "00001400",
        "musicbuf": "00000C00",
        "musicunder": "00000000",
        "musicdrops": "00000000",
        "musicstream": "PULL",
        "musicpull": "00000000:00000000",
        "musicrend": "00000001:00000006:0000000C:00000012:00000001:00030000",
        "adev": "00000001:00000001:0000000F",
        "pcm": "00000001:00000002:00002B11",
        "pcmbuf": "00001000:00000800:00000000:00000001",
        "dma": "00000001",
        "play": "00000001:00000000",
        "voiceq": "00000002:00000000:00000001",
        "musicq": "00000001:00000000",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{key}={value}" for key, value in fields.items())


def write_tone_wav(path, *, seconds=4, sample_rate=11025, channels=2, amplitude=9000):
    total_frames = seconds * sample_rate
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(channels)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        frames = bytearray()
        for index in range(total_frames):
            sample = int(amplitude * math.sin(2 * math.pi * 440 * index / sample_rate))
            for _ in range(channels):
                frames += struct.pack("<h", sample)
        wav.writeframes(bytes(frames))


def write_silence_wav(path, *, seconds=4, sample_rate=11025, channels=2):
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(channels)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        wav.writeframes(b"\0" * seconds * sample_rate * channels * 2)


def phase_statuses(*, carrier_only=False):
    sfx_final = "00000001" if carrier_only else "00000008"
    sfx_src_final = "00000001" if carrier_only else "00000004"
    sfx_bytes_final = "00000400:00000400" if carrier_only else "00001000:00002000"
    sfx_dma_final = "00000001:00000400" if carrier_only else "00000008:00002000"
    return {
        "baseline": status_line(
            doomsound="00000001",
            sfxmix="00000001",
            sfxq="00000001:00000000:00000000:00000000",
            sfxbytes="00000400:00000400",
            sfxdma="00000001:00000400",
            sfxsrc="00000001",
            sfxlast="00000001:00002B11:00000400",
            audioirq="00000001",
            ack8="00000001",
            refill="00000001",
            musicmix="00000001",
            musicloop="00000000",
            musicpos="00000001",
            musicbuf="00002000",
            musicrend="00000001:00000001:00000002:00000003:00000001:00008000",
        ),
        "fire": status_line(
            doomsound="00000002",
            sfxmix="00000001" if carrier_only else "00000003",
            sfxq="00000001:00000000:00000000:00000000"
            if carrier_only
            else "00000002:00000000:00000000:00000000",
            sfxbytes="00000400:00000400" if carrier_only else "00000800:00000C00",
            sfxdma="00000001:00000400" if carrier_only else "00000003:00000C00",
            sfxsrc="00000001" if carrier_only else "00000002",
            audioirq="00000002",
            ack8="00000002",
            refill="00000002",
            musicmix="00000002",
            musicloop="00000000",
            musicpos="00000400",
            musicbuf="00001C00",
            musicpull="00000001:00000001",
            musicrend="00000001:00000002:00000004:00000006:00000001:00010000",
            voiceq="00000002:00000000:00000002",
        ),
        "movement": status_line(
            doomsound="00000002",
            sfxmix="00000001" if carrier_only else "00000004",
            sfxq="00000001:00000000:00000000:00000000"
            if carrier_only
            else "00000002:00000000:00000000:00000000",
            sfxbytes="00000400:00000400" if carrier_only else "00000800:00001000",
            sfxdma="00000001:00000400" if carrier_only else "00000004:00001000",
            sfxsrc="00000001" if carrier_only else "00000002",
            audioirq="00000003",
            ack8="00000003",
            refill="00000003",
            musicmix="00000003",
            musicloop="00000000",
            musicpos="00000800",
            musicbuf="00001800",
            musicpull="00000002:00000002",
            musicrend="00000001:00000003:00000006:00000009:00000001:00018000",
            voiceq="00000002:00000000:00000003",
        ),
        "use": status_line(
            doomsound="00000003",
            sfxmix="00000001" if carrier_only else "00000005",
            sfxq="00000001:00000000:00000000:00000000"
            if carrier_only
            else "00000003:00000000:00000001:00000000",
            sfxbytes="00000400:00000400" if carrier_only else "00000C00:00001400",
            sfxdma="00000001:00000400" if carrier_only else "00000005:00001400",
            sfxsrc="00000001" if carrier_only else "00000003",
            audioirq="00000004",
            ack8="00000004",
            refill="00000004",
            musicmix="00000004",
            musicloop="00000000",
            musicpos="00000C00",
            musicbuf="00001400",
            musicpull="00000003:00000003",
            musicrend="00000001:00000004:00000008:0000000C:00000001:00020000",
            voiceq="00000002:00000000:00000004",
        ),
        "menu": status_line(
            doomsound="00000004",
            sfxmix="00000001" if carrier_only else "00000006",
            sfxq="00000001:00000000:00000000:00000000"
            if carrier_only
            else "00000004:00000000:00000001:00000000",
            sfxbytes="00000400:00000400" if carrier_only else "00001000:00001800",
            sfxdma="00000001:00000400" if carrier_only else "00000006:00001800",
            sfxsrc="00000001" if carrier_only else "00000004",
            audioirq="00000005",
            ack8="00000005",
            refill="00000005",
            musicmix="00000005",
            musicloop="00000001",
            musicpos="00001000",
            musicbuf="00001000",
            musicpull="00000004:00000004",
            musicrend="00000001:00000005:0000000A:0000000F:00000001:00028000",
            voiceq="00000002:00000000:00000005",
        ),
        "final": status_line(
            doomsound="00000004",
            sfxmix=sfx_final,
            sfxq="00000001:00000000:00000000:00000000"
            if carrier_only
            else "00000004:00000000:00000001:00000001",
            sfxbytes=sfx_bytes_final,
            sfxdma=sfx_dma_final,
            sfxsrc=sfx_src_final,
            audioirq="00000006",
            ack8="00000006",
            refill="00000006",
            musicmix="00000006",
            musicloop="00000001",
            musicpos="00001400",
            musicpull="00000005:00000005",
            musicrend="00000001:00000006:0000000C:00000012:00000001:00030000",
            voiceq="00000002:00000000:00000006",
        ),
    }


def write_status_files(tmpdir, *, carrier_only=False):
    snapshots = phase_statuses(carrier_only=carrier_only)
    paths = {
        "baseline": tmpdir / "status.after-start.txt",
        "fire": tmpdir / "status.after-fire.txt",
        "movement": tmpdir / "status.after-move.txt",
        "use": tmpdir / "status.after-use.txt",
        "menu": tmpdir / "status.after-menu.txt",
        "final": tmpdir / "status.txt",
    }
    for label, path in paths.items():
        path.write_text(snapshots[label])
    return paths


def analyze_args(paths):
    return {
        "baseline_status_path": paths["baseline"],
        "fire_status_path": paths["fire"],
        "movement_status_path": paths["movement"],
        "use_status_path": paths["use"],
        "menu_status_path": paths["menu"],
    }


def os_audio_contract(
    *,
    request_delta="00000005",
    refill_delta="00000005",
    sfx_delta="00000001",
    music_delta="00000001",
    position_delta="000003FF",
):
    return {
        "lane": check_audible_audio_proof.STATUS_ONLY_OS_AUDIO_SUBSYSTEM_LANE,
        "status_fields": {
            "device": "adev",
            "sample_format": "pcm",
            "ring": "pcmbuf",
            "irq_phase": "half",
            "stream": "musicstream/musicpull/musicbuf/musicpos",
            "mixer_lanes": "voices/sfxvoices/musicvoices/sfxmix/musicmix",
        },
        "device": {
            "kind": "SB16",
            "ready": True,
            "capabilities": ["pcm-ring", "mixer-voices", "pull-stream", "sb16-dma"],
            "required_capabilities_present": True,
            "playback_start_count": "00000001",
        },
        "pcm_ring": {
            "format": "u8-stereo",
            "channels": 2,
            "sample_rate": 11025,
            "ring_bytes": "00001000",
            "period_bytes": "00000800",
            "write_offset": "00000000",
            "active_half": "00000001",
            "two_period_ring": True,
            "active_half_matches_half": True,
            "irq_delta": "00000005",
            "refill_delta": "00000005",
        },
        "stream": {
            "mode": "PULL",
            "request_delta": request_delta,
            "refill_delta": refill_delta,
            "ordered_refills": True,
            "bounded_pending_requests": True,
            "pending_peak": "00000000",
            "buffer_initial": "00002000",
            "buffer_final": "00002000",
            "position_delta": position_delta,
            "payload_owner": "doom_port/music.c",
            "service_command": "VIBE_AUDIO_MIXER_UPDATE",
        },
        "mixer_lanes": {
            "voice_total_matches_lanes": True,
            "sfx_lane_counter": "sfxmix",
            "music_lane_counter": "musicmix",
            "sfx_delta": sfx_delta,
            "music_delta": music_delta,
            "human_listener_lane": "not-proven-by-status",
        },
        "claim": (
            "status-only generic device/ring/stream/mixer contract; Doom SFX, "
            "parser-backed music, and human-listened quality remain separate lanes"
        ),
    }


class AudibleAudioProofTests(unittest.TestCase):
    def test_analyzes_temporary_wav_into_aggregate_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir)

            manifest = check_audible_audio_proof.analyze_wav(
                wav_path,
                paths["final"],
                **analyze_args(paths),
            )
            check_audible_audio_proof.validate_manifest(manifest)

        self.assertEqual(manifest["schema"], check_audible_audio_proof.SCHEMA)
        self.assertEqual(manifest["status"]["audio"], "SB16")
        self.assertEqual(manifest["status"]["adev"], "00000001:00000001:0000000F")
        self.assertEqual(manifest["status"]["pcm"], "00000001:00000002:00002B11")
        self.assertEqual(manifest["status"]["pcmbuf"], "00001000:00000800:00000000:00000001")
        self.assertEqual(manifest["status"]["half"], "00000001")
        self.assertEqual(
            manifest["proof_contracts"]["os_audio_subsystem"]["lane"],
            "status-only-os-audio-subsystem",
        )
        self.assertTrue(manifest["continuity"]["os_audio_contract"]["device"]["ready"])
        self.assertEqual(
            manifest["continuity"]["os_audio_contract"]["device"]["capabilities"],
            ["pcm-ring", "mixer-voices", "pull-stream", "sb16-dma"],
        )
        self.assertTrue(
            manifest["continuity"]["os_audio_contract"]["pcm_ring"]["active_half_matches_half"]
        )
        self.assertEqual(manifest["continuity"]["os_audio_contract"]["stream"]["mode"], "PULL")
        self.assertEqual(
            manifest["continuity"]["os_audio_contract"]["mixer_lanes"]["human_listener_lane"],
            "not-proven-by-status",
        )
        self.assertTrue(manifest["continuity"]["non_music_sfx_progress"])
        self.assertGreater(int(manifest["continuity"]["mix_lanes"]["non_music_sfx"]["dma_bytes_delta"], 16), 0)
        self.assertGreaterEqual(manifest["continuity"]["mix_lanes"]["non_music_sfx"]["active_voice_snapshots"], 0)
        self.assertGreater(manifest["continuity"]["mix_lanes"]["music"]["buffered_window_snapshots"], 0)
        self.assertGreaterEqual(manifest["continuity"]["stream_health"]["distinct_buffer_windows"], 2)
        self.assertTrue(manifest["continuity"]["stream_health"]["rendered_sample_covers_position"])
        self.assertTrue(manifest["continuity"]["stream_health"]["sequenced_refill_service"])
        self.assertGreaterEqual(manifest["analysis"]["active_windows"], 3)
        self.assertGreater(manifest["quality"]["active_span_ms"], 0)
        self.assertGreater(manifest["quality"]["zero_crossing_rate_per_sec"], 0)
        self.assertTrue(manifest["listener_quality"]["machine_audible"])
        self.assertFalse(manifest["listener_quality"]["subjective_listener_approved"])
        self.assertIn("VNC does not carry audio by default", manifest["listener_quality"]["notes"])
        self.assertEqual(manifest["asset_provenance"]["sfx_source"], "runtime-wad-ds-lumps")
        self.assertEqual(manifest["asset_provenance"]["music_source"], "runtime-wad-mus-or-midi-lumps")
        self.assertFalse(manifest["asset_provenance"]["repo_shipped_audio_assets"])
        self.assertFalse(manifest["asset_provenance"]["repo_shipped_wad_assets"])
        self.assertFalse(manifest["asset_provenance"]["manifest_contains_asset_bytes"])
        self.assertFalse(manifest["asset_provenance"]["raw_audio_uploaded"])
        self.assertTrue(manifest["continuity"]["mixer_safety"]["clip_free"])
        self.assertTrue(manifest["continuity"]["mixer_safety"]["underrun_free"])
        self.assertTrue(manifest["continuity"]["mixer_safety"]["drop_free"])
        self.assertEqual(manifest["continuity"]["stream_contract"]["mode"], "PULL")
        self.assertTrue(manifest["continuity"]["stream_contract"]["hardware_paced"])
        self.assertTrue(
            manifest["continuity"]["stream_contract"]["service_sequence"]["voice_update_matches_refill"]
        )
        self.assertEqual(manifest["continuity"]["renderer_contract"]["status_counter"], "musicrend")
        self.assertEqual(manifest["continuity"]["renderer_contract"]["parser_owner"], "doom_port/music.c")
        self.assertEqual(manifest["continuity"]["renderer_contract"]["mus_score_end_event_type"], 6)
        self.assertEqual(manifest["continuity"]["renderer_contract"]["mus_reserved_event_type_rejected"], 5)
        self.assertEqual(manifest["continuity"]["renderer_contract"]["mus_max_variable_delay_bytes"], 4)
        self.assertTrue(
            manifest["continuity"]["renderer_contract"]["mus_variable_delay_requires_terminator"]
        )
        self.assertTrue(manifest["continuity"]["renderer_contract"]["mus_grouped_event_fixture"])
        self.assertEqual(manifest["continuity"]["scripted_phase_proof"]["baseline_snapshot"], "baseline")
        self.assertEqual(manifest["continuity"]["scripted_phase_proof"]["fire_snapshot"], "fire")
        self.assertTrue(manifest["continuity"]["scripted_phase_proof"]["requires_scripted_fire_sfx"])
        self.assertGreater(int(manifest["continuity"]["scripted_phase_proof"]["doomsound_delta"], 16), 0)
        self.assertGreater(int(manifest["continuity"]["scripted_phase_proof"]["sfxmix_delta"], 16), 0)
        self.assertGreater(int(manifest["continuity"]["scripted_phase_proof"]["sfxdma_delta"], 16), 0)
        self.assertFalse(manifest["artifact_policy"]["contains_raw_audio"])
        self.assertFalse(manifest["artifact_policy"]["raw_audio_upload_allowed"])
        self.assertFalse(manifest["artifact_policy"]["vnc_carries_audio_by_default"])
        self.assertTrue(manifest["artifact_policy"]["temporary_wav_deleted_before_upload"])
        self.assertEqual(manifest["artifact_policy"]["audible_evidence"], "aggregate-cloud-output-status")
        serialized = json.dumps(manifest)
        self.assertNotIn("audio_bytes", serialized)
        self.assertNotIn("base64", serialized)

    def test_rejects_silence_and_failed_guest_audio_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_silence_wav(wav_path)
            paths = write_status_files(tmpdir)

            manifest = check_audible_audio_proof.analyze_wav(
                wav_path,
                paths["final"],
                **analyze_args(paths),
            )
            with self.assertRaisesRegex(AssertionError, "not enough active"):
                check_audible_audio_proof.validate_manifest(manifest)

            paths["final"].write_text(status_line(audio="NONE"))
            with self.assertRaisesRegex(AssertionError, "audio=SB16"):
                check_audible_audio_proof.analyze_wav(
                    wav_path,
                    paths["final"],
                    **analyze_args(paths),
                )

    def test_rejects_duplicate_status_fields(self):
        with tempfile.TemporaryDirectory() as tmp:
            status_path = Path(tmp) / "status.txt"
            status_path.write_text(status_line() + " audio=NONE")

            with self.assertRaisesRegex(AssertionError, "duplicate audio= field"):
                check_audible_audio_proof._status_summary(status_path)

    def test_rejects_incoherent_generic_pcm_ring_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir)
            paths["final"].write_text(
                paths["final"].read_text().replace(
                    "pcmbuf=00001000:00000800:00000000:00000001",
                    "pcmbuf=00001000:00000800:00000000:00000000",
                )
            )

            with self.assertRaisesRegex(AssertionError, "pcmbuf=.*active half.*half="):
                check_audible_audio_proof.analyze_wav(
                    wav_path,
                    paths["final"],
                    **analyze_args(paths),
                )

    def test_rejects_non_silent_carrier_when_sfx_counters_do_not_progress(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir, carrier_only=True)

            with self.assertRaisesRegex(AssertionError, "sfxmix=.*increase"):
                check_audible_audio_proof.analyze_wav(
                    wav_path,
                    paths["final"],
                    **analyze_args(paths),
                )

    def test_manifest_rejects_missing_or_false_asset_provenance(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir)

            manifest = check_audible_audio_proof.analyze_wav(
                wav_path,
                paths["final"],
                **analyze_args(paths),
            )

        missing = dict(manifest)
        del missing["asset_provenance"]
        with self.assertRaisesRegex(AssertionError, "asset_provenance"):
            check_audible_audio_proof.validate_manifest(missing)

        wrong_source = json.loads(json.dumps(manifest))
        wrong_source["asset_provenance"]["sfx_source"] = "repo-shipped-audio"
        with self.assertRaisesRegex(AssertionError, "asset_provenance.sfx_source"):
            check_audible_audio_proof.validate_manifest(wrong_source)

        repo_assets = json.loads(json.dumps(manifest))
        repo_assets["asset_provenance"]["repo_shipped_audio_assets"] = True
        with self.assertRaisesRegex(AssertionError, "asset_provenance.repo_shipped_audio_assets"):
            check_audible_audio_proof.validate_manifest(repo_assets)

    def test_manifest_rejects_missing_scripted_fire_phase_proof(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir)

            manifest = check_audible_audio_proof.analyze_wav(
                wav_path,
                paths["final"],
                **analyze_args(paths),
            )

        missing = json.loads(json.dumps(manifest))
        del missing["continuity"]["scripted_phase_proof"]
        with self.assertRaisesRegex(AssertionError, "scripted_phase_proof"):
            check_audible_audio_proof.validate_manifest(missing)

        music_only_fire = json.loads(json.dumps(manifest))
        music_only_fire["continuity"]["scripted_phase_proof"]["sfxmix_delta"] = "00000000"
        with self.assertRaisesRegex(AssertionError, "scripted fire SFX"):
            check_audible_audio_proof.validate_manifest(music_only_fire)

    def test_manifest_rejects_wrong_renderer_contract_when_present(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir)

            manifest = check_audible_audio_proof.analyze_wav(
                wav_path,
                paths["final"],
                **analyze_args(paths),
            )

        wrong_score_end = json.loads(json.dumps(manifest))
        wrong_score_end["continuity"]["renderer_contract"]["mus_score_end_event_type"] = 5
        with self.assertRaisesRegex(AssertionError, "event type 6"):
            check_audible_audio_proof.validate_manifest(wrong_score_end)

        wrong_reserved = json.loads(json.dumps(manifest))
        wrong_reserved["continuity"]["renderer_contract"]["mus_reserved_event_type_rejected"] = 6
        with self.assertRaisesRegex(AssertionError, "event type 5"):
            check_audible_audio_proof.validate_manifest(wrong_reserved)

        wrong_delay = json.loads(json.dumps(manifest))
        wrong_delay["continuity"]["renderer_contract"]["mus_variable_delay_requires_terminator"] = False
        with self.assertRaisesRegex(AssertionError, "terminated MUS delay"):
            check_audible_audio_proof.validate_manifest(wrong_delay)

        wrong_group = json.loads(json.dumps(manifest))
        wrong_group["continuity"]["renderer_contract"]["mus_grouped_event_fixture"] = False
        with self.assertRaisesRegex(AssertionError, "grouped MUS event"):
            check_audible_audio_proof.validate_manifest(wrong_group)

    def test_manifest_rejects_collapsed_os_audio_lanes(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir)

            manifest = check_audible_audio_proof.analyze_wav(
                wav_path,
                paths["final"],
                **analyze_args(paths),
            )

        missing = json.loads(json.dumps(manifest))
        del missing["continuity"]["os_audio_contract"]
        with self.assertRaisesRegex(AssertionError, "os_audio_contract"):
            check_audible_audio_proof.validate_manifest(missing)

        collapsed_listener = json.loads(json.dumps(manifest))
        collapsed_listener["continuity"]["os_audio_contract"]["mixer_lanes"][
            "human_listener_lane"
        ] = "proven-by-status"
        with self.assertRaisesRegex(AssertionError, "human listener lane"):
            check_audible_audio_proof.validate_manifest(collapsed_listener)

        collapsed_ring = json.loads(json.dumps(manifest))
        collapsed_ring["continuity"]["os_audio_contract"]["pcm_ring"][
            "active_half_matches_half"
        ] = False
        with self.assertRaisesRegex(AssertionError, "active half"):
            check_audible_audio_proof.validate_manifest(collapsed_ring)

    def test_cli_writes_and_validates_manifest_without_uploading_wav(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            manifest_path = tmpdir / "audio-proof.json"
            write_tone_wav(wav_path)
            paths = write_status_files(tmpdir)

            analyze = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--analyze-wav",
                    str(wav_path),
                    "--status",
                    str(paths["final"]),
                    "--baseline",
                    str(paths["baseline"]),
                    "--fire",
                    str(paths["fire"]),
                    "--movement",
                    str(paths["movement"]),
                    "--use",
                    str(paths["use"]),
                    "--menu",
                    str(paths["menu"]),
                    "--output",
                    str(manifest_path),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )
            validate = subprocess.run(
                [sys.executable, str(CHECKER), str(manifest_path)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(analyze.returncode, 0, analyze.stderr)
        self.assertEqual(validate.returncode, 0, validate.stderr)
        self.assertIn("audible audio proof OK", validate.stdout)

    def test_manifest_rejects_raw_payload_shapes(self):
        manifest = {
            "schema": check_audible_audio_proof.SCHEMA,
            "source": "qemu-wav-temporary",
            "format": {"duration_ms": 4000},
            "analysis": {
                "active_windows": 4,
                "active_window_ratio": 0.5,
                "peak_abs_norm": 0.2,
                "max_window_rms_norm": 0.1,
                "zero_crossings": 20,
            },
            "quality": {
                "active_span_ms": 400,
                "active_span_windows": 4,
                "leading_inactive_windows": 0,
                "trailing_inactive_windows": 0,
                "clipped_sample_ratio": 0.0,
                "crest_factor_peak_over_mean_rms": 2.0,
                "zero_crossing_rate_per_sec": 5.0,
            },
            "status": {
                "audio": "SB16",
                "gameplay": "OK",
                "doomrun": "RUN",
                "sb16": "00000004:00000005",
                "dma": "00000001",
                "play": "00000001:00000000",
                "voiceq": "00000001:00000000:00000000",
                "musicq": "00000001:00000000",
                "audioirq": "00000001",
                "refill": "00000001",
                "sfxmix": "00000001",
                "sfxvoices": "00000001",
                "musicmix": "00000001",
                "musicpos": "00000001",
                "musicbuf": "00002000",
                "musicunder": "00000000",
                "musicdrops": "00000000",
                "musicstream": "PULL",
                "musicpull": "00000005:00000005",
                "musicrend": "00000001:00000002:00000004:00000006:00000001:00010000",
            },
            "continuity": {
                "gate": "tools/check_audio_continuity_proof.py",
                "snapshots": ["baseline", "fire", "movement", "use", "menu", "final"],
                "sb16_continuity": True,
                "non_music_sfx_progress": True,
                "music_stream_progress": True,
                "music_position_progress": True,
                "music_stream_update_progress": True,
                "irq_refill_progress": True,
                "progress": {
                    "audioirq": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "refill": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "sfxmix": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "musicmix": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "musicpos": {"start": "00000001", "final": "00000400", "delta": "000003FF"},
                    "voiceq_update": {"start": "00000000", "final": "00000001", "delta": "00000001"},
                    "musicpull_request": {"start": "00000000", "final": "00000005", "delta": "00000005"},
                    "musicpull_refill": {"start": "00000000", "final": "00000005", "delta": "00000005"},
                    "musicrend_chunk": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "musicrend_note": {"start": "00000002", "final": "00000004", "delta": "00000002"},
                    "musicrend_event": {"start": "00000003", "final": "00000006", "delta": "00000003"},
                    "musicrend_sample": {"start": "00008000", "final": "00010000", "delta": "00008000"},
                },
                "mix_lanes": {
                    "non_music_sfx": {
                        "counter": "sfxmix",
                        "delta": "00000001",
                        "active_voice_snapshots": 1,
                    },
                    "music": {
                        "counter": "musicmix",
                        "delta": "00000001",
                        "active_voice_snapshots": 1,
                        "buffered_window_snapshots": 1,
                        "stream_update_delta": "00000001",
                        "position_delta": "000003FF",
                        "renderer_counter": "musicrend",
                        "renderer_chunk_delta": "00000001",
                        "renderer_note_delta": "00000002",
                        "renderer_event_delta": "00000003",
                        "renderer_sample_delta": "00008000",
                        "renderer_final": "00000001:00000002:00000004:00000006:00000001:00010000",
                    },
                    "shared_sb16_refill": {
                        "irq_delta": "00000001",
                        "refill_delta": "00000001",
                    },
                },
                "stream_health": {
                    "buffer_floor": "00001000",
                    "buffer_peak": "00002000",
                    "buffer_final": "00002000",
                    "buffered_window_snapshots": 2,
                    "distinct_buffer_windows": 2,
                    "under_delta": "00000000",
                    "drop_delta": "00000000",
                    "stream_update_counter": "musicpull_refill",
                    "stream_update_delta": "00000001",
                    "voiceq_update_delta": "00000001",
                    "pull_request_delta": "00000001",
                    "pull_refill_delta": "00000001",
                    "position_delta": "000003FF",
                    "position_delta_per_update_floor": "000003FF",
                    "rendered_sample_delta": "00008000",
                    "rendered_sample_covers_position": True,
                },
                "stream_contract": {
                    "mode": "PULL",
                    "status_field": "musicstream",
                    "pull_counters": "00000001:00000001",
                    "hardware_paced": True,
                    "current_push_proof": False,
                    "claim": "musicstream=PULL proves SB16 refill requested chunk service",
                },
                "claim": "non-silent remote QEMU output plus status-only SB16 continuity",
            },
            "artifact_policy": {
                "contains_raw_audio": False,
                "contains_wad_data": False,
                "contains_pixels": False,
                "upload_only_aggregate_json": True,
            },
            "samples": [1, 2, 3],
        }

        with self.assertRaisesRegex(AssertionError, "forbidden raw-audio key"):
            check_audible_audio_proof.validate_manifest(manifest)

    def test_manifest_accepts_sfx_progress_after_voice_snapshot_drained(self):
        manifest = {
            "schema": check_audible_audio_proof.SCHEMA,
            "source": "qemu-wav-temporary",
            "format": {"duration_ms": 4000},
            "analysis": {
                "active_windows": 4,
                "active_window_ratio": 0.5,
                "peak_abs_norm": 0.2,
                "max_window_rms_norm": 0.1,
                "zero_crossings": 20,
            },
            "quality": {
                "active_span_ms": 400,
                "active_span_windows": 4,
                "leading_inactive_windows": 0,
                "trailing_inactive_windows": 0,
                "clipped_sample_ratio": 0.0,
                "crest_factor_peak_over_mean_rms": 2.0,
                "zero_crossing_rate_per_sec": 5.0,
            },
            "status": {
                "audio": "SB16",
                "gameplay": "OK",
                "doomrun": "RUN",
                "doomsound": "00000006",
                "sb16": "00000004:00000005",
                "dma": "00000001",
                "play": "00000001:00000000",
                "voiceq": "00000001:00000000:00000005",
                "musicq": "00000001:00000000",
                "audioirq": "00000006",
                "refill": "00000006",
                "half": "00000001",
                "sfxmix": "00000002",
                "sfxq": "00000002:00000000:00000000:00000002",
                "sfxbytes": "00000800:00001000",
                "sfxdma": "00000002:00001000",
                "sfxsrc": "00000002",
                "sfxlast": "00000001:00002B11:00000400",
                "sfxvoices": "00000000",
                "musicmix": "00000002",
                "musicpos": "00000400",
                "musicbuf": "00002000",
                "musicunder": "00000000",
                "musicdrops": "00000000",
                "musicstream": "PULL",
                "musicpull": "00000005:00000005",
                "musicrend": "00000001:00000006:0000000C:00000012:00000001:00030000",
                "adev": "00000001:00000001:0000000F",
                "pcm": "00000001:00000002:00002B11",
                "pcmbuf": "00001000:00000800:00000000:00000001",
            },
            "continuity": {
                "gate": "tools/check_audio_continuity_proof.py",
                "snapshots": ["baseline", "fire", "movement", "use", "menu", "final"],
                "sb16_continuity": True,
                "doomsound_progress": True,
                "non_music_sfx_progress": True,
                "music_stream_progress": True,
                "music_position_progress": True,
                "music_stream_update_progress": True,
                "irq_refill_progress": True,
                "progress": {
                    "doomsound": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                    "audioirq": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                    "refill": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                    "sfxmix": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "sfxsrc": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "sfxq_submit": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "sfxbytes_submit": {"start": "00000400", "final": "00000800", "delta": "00000400"},
                    "sfxbytes_output": {"start": "00000400", "final": "00001000", "delta": "00000C00"},
                    "sfxdma_mix": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "sfxdma_bytes": {"start": "00000400", "final": "00001000", "delta": "00000C00"},
                    "musicmix": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "musicpos": {"start": "00000001", "final": "00000400", "delta": "000003FF"},
                    "voiceq_update": {"start": "00000000", "final": "00000005", "delta": "00000005"},
                    "musicpull_request": {"start": "00000000", "final": "00000005", "delta": "00000005"},
                    "musicpull_refill": {"start": "00000000", "final": "00000005", "delta": "00000005"},
                    "musicrend_chunk": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                    "musicrend_note": {"start": "00000002", "final": "0000000C", "delta": "0000000A"},
                    "musicrend_event": {"start": "00000003", "final": "00000012", "delta": "0000000F"},
                    "musicrend_sample": {"start": "00008000", "final": "00030000", "delta": "00028000"},
                },
                "mix_lanes": {
                    "non_music_sfx": {
                        "counter": "sfxmix",
                        "delta": "00000001",
                        "source_counter": "sfxsrc",
                        "source_delta": "00000001",
                        "submit_counter": "sfxq[0]",
                        "submit_delta": "00000001",
                        "submit_bytes_delta": "00000400",
                        "output_bytes_delta": "00000C00",
                        "dma_counter": "sfxdma",
                        "dma_mix_delta": "00000001",
                        "dma_bytes_delta": "00000C00",
                        "active_voice_snapshots": 0,
                    },
                    "music": {
                        "counter": "musicmix",
                        "delta": "00000001",
                        "active_voice_snapshots": 1,
                        "buffered_window_snapshots": 1,
                        "stream_update_delta": "00000005",
                        "position_delta": "000003FF",
                        "renderer_counter": "musicrend",
                        "renderer_chunk_delta": "00000005",
                        "renderer_note_delta": "0000000A",
                        "renderer_event_delta": "0000000F",
                        "renderer_sample_delta": "00028000",
                        "renderer_final": "00000001:00000006:0000000C:00000012:00000001:00030000",
                    },
                    "shared_sb16_refill": {
                        "irq_delta": "00000005",
                        "refill_delta": "00000005",
                    },
                },
                "stream_health": {
                    "buffer_floor": "00001000",
                    "buffer_peak": "00002000",
                    "buffer_final": "00002000",
                    "buffered_window_snapshots": 2,
                    "distinct_buffer_windows": 2,
                    "under_delta": "00000000",
                    "drop_delta": "00000000",
                    "stream_update_counter": "musicpull_refill",
                    "stream_update_delta": "00000005",
                    "voiceq_update_delta": "00000005",
                    "pull_request_delta": "00000005",
                    "pull_refill_delta": "00000005",
                    "pull_pending_peak": "00000000",
                    "pull_pending_final": "00000000",
                    "position_delta": "000003FF",
                    "position_delta_per_update_floor": "000003FF",
                    "rendered_sample_delta": "00028000",
                    "rendered_sample_covers_position": True,
                    "sequenced_refill_service": True,
                },
                "stream_contract": {
                    "mode": "PULL",
                    "status_field": "musicstream",
                    "pull_counters": "00000005:00000005",
                    "hardware_paced": True,
                    "current_push_proof": False,
                    "service_sequence": {
                        "refill_counter": "musicpull_refill",
                        "request_delta": "00000005",
                        "refill_delta": "00000005",
                        "voiceq_update_delta": "00000005",
                        "renderer_chunk_delta": "00000005",
                        "max_pending_pull_requests": "00000001",
                        "pull_pending_peak": "00000000",
                        "pull_pending_final": "00000000",
                        "refill_matches_request": True,
                        "voice_update_matches_refill": True,
                        "render_chunk_matches_refill": True,
                    },
                    "claim": "musicstream=PULL proves SB16 refill requested chunk service",
                },
                "os_audio_contract": os_audio_contract(),
                "mixer_safety": {
                    "mixclip_delta": "00000000",
                    "musicunder_delta": "00000000",
                    "musicdrop_delta": "00000000",
                    "max_mixclip_delta": "00000000",
                    "max_musicunder_delta": "00000000",
                    "max_musicdrop_delta": "00000000",
                    "clip_free": True,
                    "underrun_free": True,
                    "drop_free": True,
                },
                "scripted_phase_proof": {
                    "baseline_snapshot": "baseline",
                    "fire_snapshot": "fire",
                    "requires_scripted_fire_sfx": True,
                    "doomsound_delta": "00000001",
                    "sfxmix_delta": "00000001",
                    "sfxsrc_delta": "00000001",
                    "sfxsubmit_delta": "00000001",
                    "sfxoutput_delta": "00000400",
                    "sfxdma_delta": "00000400",
                    "musicmix_delta": "00000001",
                    "claim": (
                        "scripted fire must advance Doom sound calls and "
                        "non-music SFX mixing, not music alone"
                    ),
                },
                "claim": "non-silent remote QEMU output plus status-only SB16 continuity",
            },
            "listener_quality": {
                "mode": "aggregate-metrics-no-human-listener",
                "quality_floor": "machine-audible",
                "subjective_listener_approved": False,
                "requires_remote_listener_notes": True,
                "machine_audible": True,
                "thresholds": {
                    "min_duration_ms": check_audible_audio_proof.DEFAULT_MIN_DURATION_MS,
                    "min_active_windows": check_audible_audio_proof.DEFAULT_MIN_ACTIVE_WINDOWS,
                    "min_active_ratio": check_audible_audio_proof.DEFAULT_MIN_ACTIVE_RATIO,
                    "min_peak_abs_norm": check_audible_audio_proof.DEFAULT_MIN_PEAK,
                    "max_clipped_sample_ratio": check_audible_audio_proof.DEFAULT_MAX_CLIPPED_SAMPLE_RATIO,
                    "max_mixclip_delta": check_audible_audio_proof.MAX_MIX_CLIP_DELTA,
                    "max_musicunder_delta": check_audible_audio_proof.MAX_MUSIC_UNDERRUN_DELTA,
                    "max_musicdrop_delta": check_audible_audio_proof.MAX_MUSIC_DROP_DELTA,
                },
                "notes": (
                    "aggregate metrics only; VNC does not carry audio by default, "
                    "not a human listening pass"
                ),
            },
            "asset_provenance": check_audible_audio_proof._asset_provenance(),
            "artifact_policy": {
                "contains_raw_audio": False,
                "contains_wad_data": False,
                "contains_pixels": False,
                "upload_only_aggregate_json": True,
                "raw_audio_upload_allowed": False,
                "temporary_wav_deleted_before_upload": True,
                "vnc_carries_audio_by_default": False,
                "audible_evidence": "aggregate-cloud-output-status",
            },
        }

        check_audible_audio_proof.validate_manifest(manifest)

    def test_repo_contract_is_wired_without_local_qemu(self):
        check_audible_audio_proof.validate_repo_contract()

        source = CHECKER.read_text()
        self.assertNotIn("qemu" + "-system", source)
        self.assertNotIn("pmemsave", source)


if __name__ == "__main__":
    unittest.main()
