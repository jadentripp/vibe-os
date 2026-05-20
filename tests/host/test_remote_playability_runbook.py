import gzip
import hashlib
import importlib.util
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "tools" / "check_cloud_playability_artifacts.py"
PREPARE = ROOT / "tools" / "prepare_shareware_wad.py"

checker_spec = importlib.util.spec_from_file_location("check_cloud_playability_artifacts", CHECKER)
check_cloud_playability_artifacts = importlib.util.module_from_spec(checker_spec)
checker_spec.loader.exec_module(check_cloud_playability_artifacts)

prepare_spec = importlib.util.spec_from_file_location("prepare_shareware_wad", PREPARE)
prepare_shareware_wad = importlib.util.module_from_spec(prepare_spec)
prepare_spec.loader.exec_module(prepare_shareware_wad)


def valid_status(**overrides):
    fields = {
        "exec": "OK",
        "path": "DOOM.ELF",
        "doom": "OK",
        "doomrun": "RUN",
        "doomopen": "OK",
        "doomread": "OK",
        "gameplay": "OK",
        "gstate": "00000000",
        "gmap": "00000101",
        "gfx": "OK",
        "pself": "OK",
        "pg": "ON",
        "pmm": "OK",
        "vmm": "OK",
        "libc": "OK",
        "c": "OK",
        "usr": "OK",
        "wad": "OK",
        "lmp": "OK",
        "heap": "OK",
        "target": "01000000",
        "argv0": "00F00000",
        "doomwrite": "00000001",
        "doomseek": "00000001",
        "doomclose": "00000001",
        "doomsbrk": "00001000",
        "doomerr": "00000000",
        "doomexit": "00000000",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "doompresent": "00000004",
        "doompal": "89ABCDEF",
        "doomframe": "13572468",
        "doomnonzero": "00002000",
        "doomcolors": "00000080",
        "gtic": "00000020",
        "leveltime": "00000020",
        "gflags": "00000001",
        "gaction": "00000000",
        "pflags": "0000003F",
        "pbuttons": "00000000",
        "pdelta": "00000100",
        "doomsound": "00000001",
        "sfxmix": "00000001",
        "voices": "00000001",
        "audioirq": "00000001",
        "ack8": "00000001",
        "ack16": "00000000",
        "refill": "00000001",
        "half": "00000001",
        "mixwrap": "00000001",
        "mixover": "00000000",
        "mixunder": "00000000",
        "mixclip": "00000000",
        "steal": "00000000",
        "pitchclamp": "00000000",
        "panclamp": "00000000",
        "musicvoices": "00000001",
        "musicmix": "00000001",
        "musicloop": "00000001",
        "keyirq": "00000002",
        "keyqueue": "00000002",
        "keypoll": "00000002",
        "mouseirq": "00000000",
        "mousepkt": "00000000",
        "mousepoll": "00000000",
        "preempt": "00000001",
        "pattempt": "00000001",
        "pskip": "00000000",
        "free": "00800000",
        "ticks": "00000020",
        "fb": "LFB",
        "audio": "SB16",
        "mouse": "OK",
        "doommode": "00000000:00000000",
        "ppos": "00010000:00020000",
        "execsys": "00000001/00000001/00000000/00000001/00000001/00000000",
        "doomsamp": "00000001:00000002:00000003",
        "doomlog": "ready",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(
        f"{key}={value}" for key, value in fields.items()
    )


class RemotePlayabilityRunbookTests(unittest.TestCase):
    def test_repo_contract_is_wired_for_remote_human_play(self):
        check_cloud_playability_artifacts.validate_repo_contract()

    def test_cli_repo_contract_is_host_only(self):
        result = subprocess.run(
            [sys.executable, str(CHECKER), "--repo-contract"],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("cloud playability artifact check OK", result.stdout)

    def test_downloaded_artifact_directory_rejects_wad_and_pixel_outputs(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            for name in check_cloud_playability_artifacts.REQUIRED_STATUS_FILES:
                (artifact / name).write_text(valid_status())
            (artifact / "status.early.txt").write_text(
                valid_status(gtic="00000010", leveltime="00000010", keyirq="00000001",
                             keyqueue="00000001", keypoll="00000001")
            )
            for name in check_cloud_playability_artifacts.REQUIRED_DIAGNOSTIC_FILES:
                (artifact / name).write_bytes(b"\x7fELF")

            check_cloud_playability_artifacts.validate_artifact_dir(artifact)

            (artifact / "gfx.bin").write_bytes(b"pixels")
            with self.assertRaisesRegex(AssertionError, "forbidden"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_directory_rejects_renamed_game_or_image_payloads(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            for name in check_cloud_playability_artifacts.REQUIRED_STATUS_FILES:
                (artifact / name).write_text(valid_status())
            (artifact / "status.early.txt").write_text(
                valid_status(gtic="00000010", leveltime="00000010", keyirq="00000001",
                             keyqueue="00000001", keypoll="00000001")
            )
            for name in check_cloud_playability_artifacts.REQUIRED_DIAGNOSTIC_FILES:
                (artifact / name).write_bytes(b"\x7fELF")

            (artifact / "harmless.log").write_bytes(b"IWAD" + b"\0" * 64)
            with self.assertRaisesRegex(AssertionError, "forbidden artifact content"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

            (artifact / "harmless.log").write_bytes(b"\x89PNG\r\n\x1a\n" + b"\0" * 64)
            with self.assertRaisesRegex(AssertionError, "forbidden artifact content"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_directory_rejects_duplicate_required_basenames(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            nested = artifact / "nested"
            nested.mkdir()
            for name in check_cloud_playability_artifacts.REQUIRED_STATUS_FILES:
                (artifact / name).write_text(valid_status())
            (artifact / "status.early.txt").write_text(
                valid_status(gtic="00000010", leveltime="00000010", keyirq="00000001",
                             keyqueue="00000001", keypoll="00000001")
            )
            for name in check_cloud_playability_artifacts.REQUIRED_DIAGNOSTIC_FILES:
                (artifact / name).write_bytes(b"\x7fELF")

            (nested / "status.txt").write_text(valid_status(gameplay="WAIT"))
            with self.assertRaisesRegex(AssertionError, "duplicate diagnostic file basename"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_failure_reports_final_status_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            for name in check_cloud_playability_artifacts.REQUIRED_STATUS_FILES:
                (artifact / name).write_text(valid_status())
            (artifact / "status.txt").write_text(
                valid_status(
                    target="FFFFFFFF",
                    doomrun="FAULT",
                    doomopen="FAIL",
                    doomread="FAIL",
                    gameplay="WAIT",
                    gfx="FAIL",
                    usr="FAIL",
                )
            )
            for name in check_cloud_playability_artifacts.REQUIRED_DIAGNOSTIC_FILES:
                (artifact / name).write_bytes(b"\x7fELF")

            with self.assertRaisesRegex(AssertionError, "final status summary: .*doomrun=FAULT"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_prepare_shareware_wad_accepts_raw_gzip_and_zip_sources(self):
        wad = b"IWAD" + bytes(range(64))
        expected_sha1 = hashlib.sha1(wad).hexdigest()
        expected_bytes = len(wad)

        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            raw = tmpdir / "DOOM1.WAD"
            gz = tmpdir / "DOOM1.WAD.gz"
            zipped = tmpdir / "doom.zip"
            raw.write_bytes(wad)
            gz.write_bytes(gzip.compress(wad))
            with zipfile.ZipFile(zipped, "w") as archive:
                archive.writestr("nested/DOOM1.WAD", wad)

            for source in (raw, gz, zipped):
                with self.subTest(source=source.name):
                    output = tmpdir / f"{source.name}.out"
                    prepare_shareware_wad.prepare_wad(
                        output,
                        source,
                        None,
                        expected_sha1,
                        expected_bytes,
                    )
                    self.assertEqual(output.read_bytes(), wad)

    def test_prepare_shareware_wad_cli_rejects_wrong_hash(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "DOOM1.WAD"
            output = Path(tmp) / "out.WAD"
            source.write_bytes(b"IWAD" + b"x" * 16)

            result = subprocess.run(
                [
                    sys.executable,
                    str(PREPARE),
                    "--source",
                    str(source),
                    "--output",
                    str(output),
                    "--expected-sha1",
                    "0" * 40,
                    "--expected-bytes",
                    str(source.stat().st_size),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("SHA-1 mismatch", result.stderr)


if __name__ == "__main__":
    unittest.main()
