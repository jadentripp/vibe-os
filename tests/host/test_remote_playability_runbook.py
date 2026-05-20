import gzip
import hashlib
import importlib.util
import json
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
        "doomwad": "00000001/00000002/00000003/44415749",
        "doominit": "000001FF/00000009",
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
        "ppid": "00000001",
        "entry": "01000000",
        "stack": "0100EFE0",
        "argc": "00000001",
        "argv": "0100EFE4",
        "envp": "0100EFEC",
        "argv0": "00F00000",
        "envp0": "00000000",
        "execerr": "00000000",
        "execres": "00000000",
        "doomwrite": "00000001",
        "doomseek": "00000001",
        "doomclose": "00000001",
        "doomsbrk": "00001000",
        "doomerr": "00000000",
        "doomerrno": "00000000",
        "doomexit": "00000000",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "panic": "NONE",
        "shutdown": "NONE",
        "doompresent": "00000080",
        "doompal": "89ABCDEF",
        "doomframe": "88888888",
        "doomnonzero": "00002000",
        "doomcolors": "00000080",
        "gtic": "00000020",
        "leveltime": "00000020",
        "dtick": "0000000B",
        "gflags": "00000001",
        "gaction": "00000000",
        "pflags": "000000FF",
        "pbuttons": "00000000",
        "pdelta": "00000100",
        "doomsound": "00000001",
        "sfxmix": "00000001",
        "voices": "00000001",
        "sfxvoices": "00000001",
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
        "sb16": "00000004:00000005",
        "dma": "00000001",
        "play": "00000001:00000000",
        "voiceq": "00000001:00000000:00000000",
        "musicq": "00000001:00000000",
        "keyirq": "00000005",
        "keyqueue": "00000005",
        "keypoll": "00000005",
        "keyseen": "00000071",
        "keylast": "0001001B",
        "mouseirq": "00000002",
        "mousepkt": "00000002",
        "mousepoll": "00000002",
        "mousebtn": "00000001",
        "mousedelta": "00000018:0000000C",
        "preempt": "00000001",
        "pirq": "00000001",
        "pattempt": "00000001",
        "pskip": "00000000",
        "puser": "00000020",
        "pround": "00000004",
        "pctx": "00000008",
        "pfrom": "00000002",
        "pto": "00000003",
        "peip": "01002000:00E80000",
        "pspin": "50524590",
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


def audio_phase_statuses():
    return {
        "status.early.txt": valid_status(
            doompresent="00000010",
            doomframe="11111111",
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
            doomsound="00000001",
            sfxmix="00000001",
            audioirq="00000001",
            ack8="00000001",
            refill="00000001",
            musicmix="00000001",
            musicloop="00000000",
            pflags="00000001",
            gflags="00000000",
            pdelta="00000000",
        ),
        "status.after-start.txt": valid_status(
            doompresent="00000020",
            doomframe="22222222",
            gtic="00000018",
            leveltime="00000018",
            keyirq="00000001",
            keyqueue="00000001",
            keypoll="00000001",
            keyseen="00000000",
            keylast="00000000",
            mouseirq="00000000",
            mousepkt="00000000",
            mousepoll="00000000",
            doomsound="00000001",
            sfxmix="00000001",
            audioirq="00000001",
            ack8="00000001",
            refill="00000001",
            musicmix="00000001",
            musicloop="00000000",
            pflags="00000001",
            gflags="00000000",
            pdelta="00000000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
        ),
        "status.after-fire.txt": valid_status(
            doompresent="00000030",
            doomframe="33333333",
            gtic="00000020",
            leveltime="00000020",
            keyirq="00000002",
            keyqueue="00000002",
            keypoll="00000002",
            keyseen="00000010",
            keylast="0001019D",
            pflags="000000C5",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
            doomsound="00000002",
            sfxmix="00000003",
            audioirq="00000002",
            ack8="00000002",
            refill="00000002",
            musicmix="00000002",
            musicloop="00000000",
        ),
        "status.after-move.txt": valid_status(
            doompresent="00000040",
            doomframe="44444444",
            gtic="00000030",
            leveltime="00000030",
            keyirq="00000003",
            keyqueue="00000003",
            keypoll="00000003",
            keyseen="00000011",
            keylast="000101AD",
            pflags="00000023",
            ppos="00010020:00020000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
            doomsound="00000002",
            sfxmix="00000004",
            audioirq="00000003",
            ack8="00000003",
            refill="00000003",
            musicmix="00000003",
            musicloop="00000000",
        ),
        "status.after-use.txt": valid_status(
            doompresent="00000050",
            doomframe="55555555",
            gtic="00000040",
            leveltime="00000040",
            keyirq="00000004",
            keyqueue="00000004",
            keypoll="00000004",
            keyseen="00000031",
            keylast="00010020",
            pflags="00000009",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
            doomsound="00000003",
            sfxmix="00000005",
            audioirq="00000004",
            ack8="00000004",
            refill="00000004",
            musicmix="00000004",
            musicloop="00000000",
        ),
        "status.after-mouse.txt": valid_status(
            doompresent="00000060",
            doomframe="66666666",
            gtic="00000050",
            leveltime="00000050",
            keyirq="00000004",
            keyqueue="00000004",
            keypoll="00000004",
            keyseen="00000031",
            keylast="00010020",
            mouseirq="00000002",
            mousepkt="00000002",
            mousepoll="00000002",
            mousebtn="00000001",
            mousedelta="00000018:0000000C",
            doomsound="00000003",
            sfxmix="00000005",
            audioirq="00000004",
            ack8="00000004",
            refill="00000004",
            musicmix="00000004",
            musicloop="00000000",
        ),
        "status.after-menu.txt": valid_status(
            doompresent="00000070",
            doomframe="77777777",
            gtic="00000060",
            leveltime="00000060",
            keyirq="00000005",
            keyqueue="00000005",
            keypoll="00000005",
            keyseen="00000071",
            keylast="0001001B",
            pflags="00000011",
            doomsound="00000004",
            sfxmix="00000006",
            audioirq="00000005",
            ack8="00000005",
            refill="00000005",
            musicmix="00000005",
            musicloop="00000001",
        ),
        "status.txt": valid_status(
            doompresent="00000080",
            doomframe="88888888",
            doomsound="00000004",
            sfxmix="00000008",
            audioirq="00000006",
            ack8="00000006",
            refill="00000006",
            musicmix="00000006",
            musicloop="00000001",
        ),
    }


def write_valid_artifact(artifact):
    for name, status in audio_phase_statuses().items():
        (artifact / name).write_text(status)
    for name in check_cloud_playability_artifacts.REQUIRED_DIAGNOSTIC_FILES:
        (artifact / name).write_bytes(b"\x7fELF")
    for name in check_cloud_playability_artifacts.REQUIRED_SYMBOL_FILES:
        (artifact / name).write_text(
            "# vibe-os-symbol-map-v1\n"
            "# address\tsize\ttype\tbind\tsection\tobject\tsymbol\n"
            "01000000\t00000010\tFUNC\tGLOBAL\t.text\tbuild/doom/port_start.o\tstart\n"
        )


def write_human_notes(artifact, **overrides):
    fields = {
        "schema": "human-playtest-notes-v1",
        "commit": "abcdef0",
        "playtester": "jt",
        "remote_host": "disposable",
        "qemu_location": "remote",
        "vnc_tunnel": "loopback-only",
        "wad": "shareware-v1.9-validated-remote-only",
        "display": "pass",
        "keyboard": "pass",
        "mouse": "pass",
        "audio": "status-only",
        "diagnostics": "non-wad-status-only",
        "no_local_qemu": "yes",
        "no_wad_upload": "yes",
        "no_disk_upload": "yes",
        "no_pixel_upload": "yes",
    }
    fields.update(overrides)
    (artifact / "human-playtest-notes.txt").write_text(
        "\n".join(f"{key}={value}" for key, value in fields.items()) + "\n"
    )


def valid_audio_proof_manifest():
    return {
        "schema": check_cloud_playability_artifacts.check_audible_audio_proof.SCHEMA,
        "source": "qemu-wav-temporary",
        "format": {
            "sample_rate": 11025,
            "channels": 2,
            "sample_width_bytes": 2,
            "frames": 44100,
            "duration_ms": 4000,
            "window_ms": 100,
        },
        "analysis": {
            "total_windows": 40,
            "active_windows": 12,
            "active_window_ratio": 0.3,
            "first_active_window": 3,
            "last_active_window": 35,
            "max_window_rms_norm": 0.15,
            "mean_window_rms_norm": 0.05,
            "mean_active_rms_norm": 0.1,
            "peak_abs_norm": 0.25,
            "zero_crossings": 200,
            "active_rms_threshold_norm": 0.0015,
        },
        "status": {
            "audio": "SB16",
            "doomrun": "RUN",
            "gameplay": "OK",
            "sb16": "00000004:00000005",
            "dma": "00000001",
            "play": "00000001:00000000",
            "voiceq": "00000001:00000000:00000000",
            "musicq": "00000001:00000000",
            "audioirq": "00000006",
            "ack8": "00000006",
            "ack16": "00000000",
            "refill": "00000006",
            "sfxmix": "00000008",
            "sfxvoices": "00000001",
            "musicmix": "00000006",
            "musicloop": "00000001",
        },
        "continuity": {
            "gate": "tools/check_audio_continuity_proof.py",
            "snapshots": ["baseline", "fire", "movement", "use", "menu", "final"],
            "sb16_continuity": True,
            "non_music_sfx_progress": True,
            "music_carrier_progress": True,
            "irq_refill_progress": True,
            "progress": {
                "audioirq": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                "refill": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                "sfxmix": {"start": "00000001", "final": "00000008", "delta": "00000007"},
                "musicmix": {"start": "00000001", "final": "00000006", "delta": "00000005"},
            },
            "claim": "non-silent remote QEMU output plus status-only SB16 continuity",
        },
        "artifact_policy": {
            "contains_raw_audio": False,
            "contains_wad_data": False,
            "contains_pixels": False,
            "upload_only_aggregate_json": True,
        },
    }


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
            write_valid_artifact(artifact)

            check_cloud_playability_artifacts.validate_artifact_dir(artifact)

            (artifact / "gfx.bin").write_bytes(b"pixels")
            with self.assertRaisesRegex(AssertionError, "forbidden"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_directory_rejects_renamed_game_or_image_payloads(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)

            (artifact / "harmless.log").write_bytes(b"IWAD" + b"\0" * 64)
            with self.assertRaisesRegex(AssertionError, "forbidden artifact content"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

            (artifact / "harmless.log").write_bytes(b"\x89PNG\r\n\x1a\n" + b"\0" * 64)
            with self.assertRaisesRegex(AssertionError, "forbidden artifact content"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

            (artifact / "harmless.log").write_bytes(b"RIFF" + b"\0" * 64)
            with self.assertRaisesRegex(AssertionError, "forbidden artifact content"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_directory_rejects_compressed_or_archived_wad_payloads(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)

            (artifact / "harmless.log").write_bytes(gzip.compress(b"IWAD" + b"\0" * 64))
            with self.assertRaisesRegex(AssertionError, "gzip-compressed WAD"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)

            archive_path = artifact / "diagnostics.log"
            with zipfile.ZipFile(archive_path, "w") as archive:
                archive.writestr("nested/DOOM1.WAD", b"IWAD" + b"\0" * 64)
            with self.assertRaisesRegex(AssertionError, "zip archive containing forbidden payload"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_directory_rejects_raw_audio_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)

            (artifact / "doom-audio.wav").write_bytes(b"RIFF" + b"\0" * 64)
            with self.assertRaisesRegex(AssertionError, "forbidden WAD/image/pixel/audio artifact"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_directory_accepts_aggregate_audio_proof_json(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "audio-proof.json").write_text(
                json.dumps(valid_audio_proof_manifest(), sort_keys=True)
            )

            check_cloud_playability_artifacts.validate_artifact_dir(artifact)

            manifest = valid_audio_proof_manifest()
            manifest["analysis"]["active_windows"] = 0
            (artifact / "audio-proof.json").write_text(json.dumps(manifest, sort_keys=True))
            with self.assertRaisesRegex(AssertionError, "audible audio proof manifest failed"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_human_session_requires_structured_notes(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)

            with self.assertRaisesRegex(AssertionError, "human review file"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

            write_human_notes(artifact)
            check_cloud_playability_artifacts.validate_artifact_dir(
                artifact,
                require_human_notes=True,
            )

            write_human_notes(artifact, no_local_qemu="no")
            with self.assertRaisesRegex(AssertionError, "human playtest notes failed"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_cli_human_session_mode_validates_notes(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact)

            result = subprocess.run(
                [sys.executable, str(CHECKER), "--human-session", str(artifact)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("cloud playability artifact check OK", result.stdout)

    def test_downloaded_artifact_directory_rejects_duplicate_required_basenames(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            nested = artifact / "nested"
            nested.mkdir()
            write_valid_artifact(artifact)

            (nested / "status.txt").write_text(valid_status(gameplay="WAIT"))
            with self.assertRaisesRegex(AssertionError, "duplicate diagnostic file basename"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_failure_reports_final_status_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
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

            with self.assertRaisesRegex(AssertionError, "final status summary: .*doomrun=FAULT"):
                check_cloud_playability_artifacts.validate_artifact_dir(artifact)

    def test_downloaded_artifact_failure_reports_audio_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "status.txt").write_text(
                valid_status(
                    doomsound="00000001",
                    sfxmix="00000001",
                    audioirq="00000001",
                    ack8="00000001",
                    refill="00000001",
                    musicmix="00000001",
                    musicloop="00000000",
                )
            )

            with self.assertRaisesRegex(AssertionError, "final audio summary: .*audio=SB16"):
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
