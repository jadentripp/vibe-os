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
    return {
        "baseline": status_line(
            doomsound="00000001",
            sfxmix="00000001",
            audioirq="00000001",
            ack8="00000001",
            refill="00000001",
            musicmix="00000001",
            musicloop="00000000",
        ),
        "fire": status_line(
            doomsound="00000002",
            sfxmix="00000001" if carrier_only else "00000003",
            audioirq="00000002",
            ack8="00000002",
            refill="00000002",
            musicmix="00000002",
            musicloop="00000000",
        ),
        "movement": status_line(
            doomsound="00000002",
            sfxmix="00000001" if carrier_only else "00000004",
            audioirq="00000003",
            ack8="00000003",
            refill="00000003",
            musicmix="00000003",
            musicloop="00000000",
        ),
        "use": status_line(
            doomsound="00000003",
            sfxmix="00000001" if carrier_only else "00000005",
            audioirq="00000004",
            ack8="00000004",
            refill="00000004",
            musicmix="00000004",
            musicloop="00000000",
        ),
        "menu": status_line(
            doomsound="00000004",
            sfxmix="00000001" if carrier_only else "00000006",
            audioirq="00000005",
            ack8="00000005",
            refill="00000005",
            musicmix="00000005",
            musicloop="00000001",
        ),
        "final": status_line(
            doomsound="00000004",
            sfxmix=sfx_final,
            audioirq="00000006",
            ack8="00000006",
            refill="00000006",
            musicmix="00000006",
            musicloop="00000001",
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
        self.assertTrue(manifest["continuity"]["non_music_sfx_progress"])
        self.assertGreaterEqual(manifest["analysis"]["active_windows"], 3)
        self.assertFalse(manifest["artifact_policy"]["contains_raw_audio"])
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
            },
            "continuity": {
                "gate": "tools/check_audio_continuity_proof.py",
                "snapshots": ["baseline", "fire", "movement", "use", "menu", "final"],
                "sb16_continuity": True,
                "non_music_sfx_progress": True,
                "music_carrier_progress": True,
                "irq_refill_progress": True,
                "progress": {
                    "audioirq": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "refill": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "sfxmix": {"start": "00000001", "final": "00000002", "delta": "00000001"},
                    "musicmix": {"start": "00000001", "final": "00000002", "delta": "00000001"},
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

    def test_repo_contract_is_wired_without_local_qemu(self):
        check_audible_audio_proof.validate_repo_contract()

        source = CHECKER.read_text()
        self.assertNotIn("qemu" + "-system", source)
        self.assertNotIn("pmemsave", source)


if __name__ == "__main__":
    unittest.main()
