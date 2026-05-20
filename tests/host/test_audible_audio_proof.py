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
        "audioirq": "00000006",
        "ack8": "00000006",
        "ack16": "00000000",
        "refill": "00000006",
        "sfxmix": "00000008",
        "musicmix": "00000006",
        "musicloop": "00000001",
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


class AudibleAudioProofTests(unittest.TestCase):
    def test_analyzes_temporary_wav_into_aggregate_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            status_path = tmpdir / "status.txt"
            write_tone_wav(wav_path)
            status_path.write_text(status_line())

            manifest = check_audible_audio_proof.analyze_wav(wav_path, status_path)
            check_audible_audio_proof.validate_manifest(manifest)

        self.assertEqual(manifest["schema"], check_audible_audio_proof.SCHEMA)
        self.assertEqual(manifest["status"]["audio"], "SB16")
        self.assertGreaterEqual(manifest["analysis"]["active_windows"], 3)
        self.assertFalse(manifest["artifact_policy"]["contains_raw_audio"])
        serialized = json.dumps(manifest)
        self.assertNotIn("audio_bytes", serialized)
        self.assertNotIn("base64", serialized)

    def test_rejects_silence_and_failed_guest_audio_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            status_path = tmpdir / "status.txt"
            write_silence_wav(wav_path)
            status_path.write_text(status_line())

            manifest = check_audible_audio_proof.analyze_wav(wav_path, status_path)
            with self.assertRaisesRegex(AssertionError, "not enough active"):
                check_audible_audio_proof.validate_manifest(manifest)

            status_path.write_text(status_line(audio="NONE"))
            with self.assertRaisesRegex(AssertionError, "audio=SB16"):
                check_audible_audio_proof.analyze_wav(wav_path, status_path)

    def test_cli_writes_and_validates_manifest_without_uploading_wav(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wav_path = tmpdir / "doom-audio.wav"
            status_path = tmpdir / "status.txt"
            manifest_path = tmpdir / "audio-proof.json"
            write_tone_wav(wav_path)
            status_path.write_text(status_line())

            analyze = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--analyze-wav",
                    str(wav_path),
                    "--status",
                    str(status_path),
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
                "audioirq": "00000001",
                "refill": "00000001",
                "sfxmix": "00000001",
                "musicmix": "00000001",
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
