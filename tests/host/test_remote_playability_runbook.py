import gzip
import hashlib
import importlib.util
import json
import socket
import subprocess
import sys
import tempfile
import threading
import unittest
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "tools" / "check_cloud_playability_artifacts.py"
COLLECTOR = ROOT / "tools" / "collect_human_playtest_bundle.py"
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
        "voices": "00000002",
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
        "musicpos": "00001400",
        "musicbuf": "00000C00",
        "musicunder": "00000000",
        "musicdrops": "00000000",
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
        "fbpolicy": "ASP",
        "fbgeom": "00000000:00000000:00000280:000001E0:00000002",
        "fbdirty": "00000000:00000000:00000140:000000C8:00010000",
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
            musicpos="00000001",
            musicbuf="00000100",
            voiceq="00000001:00000000:00000000",
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
            musicpos="00000001",
            musicbuf="00000100",
            voiceq="00000001:00000000:00000000",
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
            musicpos="00000400",
            musicbuf="00000400",
            voiceq="00000001:00000000:00000001",
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
            musicpos="00000800",
            musicbuf="00000800",
            voiceq="00000001:00000000:00000002",
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
            musicpos="00000C00",
            musicbuf="00000C00",
            voiceq="00000001:00000000:00000003",
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
            musicpos="00000C00",
            musicbuf="00000C00",
            voiceq="00000001:00000000:00000003",
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
            musicpos="00001000",
            musicbuf="00001000",
            voiceq="00000001:00000000:00000004",
        ),
        "status.txt": valid_status(
            doompresent="00000080",
            doomframe="88888888",
            gtic="00000180",
            leveltime="00000180",
            doomsound="00000004",
            sfxmix="00000008",
            audioirq="00000006",
            ack8="00000006",
            refill="00000006",
            musicmix="00000006",
            musicloop="00000001",
            musicpos="00001400",
            musicbuf="00001400",
            voiceq="00000001:00000000:00000005",
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
    phase_hashes = {}
    for phase, status_file, _human_action in check_cloud_playability_artifacts.HUMAN_SESSION_PHASES:
        phase_hashes[
            check_cloud_playability_artifacts.HUMAN_PHASE_HASH_NOTE_KEYS[phase]
        ] = check_cloud_playability_artifacts._sha256_file(artifact / status_file)

    fields = {
        "schema": "human-playtest-notes-v2",
        "commit": "abcdef0",
        "scripted_proof": "real-wad-smoke-pass",
        "scripted_proof_run_id": "26156172979",
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
        "status_capture": "monitor-pmemsave-0x9d000",
        "session_phases": (
            "early,after-start,after-fire,after-move,after-use,after-mouse,after-menu,final"
        ),
        "diagnostics": "non-wad-status-only",
        "proof_bundle": "allowlisted-status-only",
        "no_local_qemu": "yes",
        "no_wad_upload": "yes",
        "no_disk_upload": "yes",
        "no_pixel_upload": "yes",
        "operator_remote_vnc": "confirmed",
        "operator_phase_actions": "confirmed",
        "operator_phase_status_hashes": "confirmed",
        "operator_no_forbidden_artifacts": "confirmed",
        "operator_post_download_verification": "required",
    }
    fields.update(phase_hashes)
    fields.update(overrides)
    (artifact / "human-playtest-notes.txt").write_text(
        "\n".join(f"{key}={value}" for key, value in fields.items()) + "\n"
    )


def write_human_session(artifact):
    (artifact / "human-playtest-session.json").write_text(
        json.dumps(
            check_cloud_playability_artifacts.build_human_session(
                artifact,
                collected_at_utc="2026-05-20T00:00:00Z",
            ),
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )


def write_human_manifest(artifact):
    if not (artifact / "human-playtest-session.json").exists():
        write_human_session(artifact)
    (artifact / "human-playtest-manifest.json").write_text(
        json.dumps(
            check_cloud_playability_artifacts.build_human_manifest(artifact),
            indent=2,
            sort_keys=True,
        )
        + "\n"
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
        "quality": {
            "active_span_ms": 3200,
            "active_span_windows": 32,
            "leading_inactive_windows": 3,
            "trailing_inactive_windows": 5,
            "clipped_sample_ratio": 0.0,
            "crest_factor_peak_over_mean_rms": 2.5,
            "zero_crossing_rate_per_sec": 50.0,
        },
        "listener_quality": {
            "mode": "aggregate-metrics-no-human-listener",
            "quality_floor": "machine-audible",
            "subjective_listener_approved": False,
            "requires_remote_listener_notes": True,
            "machine_audible": True,
            "thresholds": {
                "min_duration_ms": check_cloud_playability_artifacts.check_audible_audio_proof.DEFAULT_MIN_DURATION_MS,
                "min_active_windows": check_cloud_playability_artifacts.check_audible_audio_proof.DEFAULT_MIN_ACTIVE_WINDOWS,
                "min_active_ratio": check_cloud_playability_artifacts.check_audible_audio_proof.DEFAULT_MIN_ACTIVE_RATIO,
                "min_peak_abs_norm": check_cloud_playability_artifacts.check_audible_audio_proof.DEFAULT_MIN_PEAK,
                "max_clipped_sample_ratio": check_cloud_playability_artifacts.check_audible_audio_proof.DEFAULT_MAX_CLIPPED_SAMPLE_RATIO,
                "max_mixclip_delta": check_cloud_playability_artifacts.check_audible_audio_proof.MAX_MIX_CLIP_DELTA,
                "max_musicunder_delta": check_cloud_playability_artifacts.check_audible_audio_proof.MAX_MUSIC_UNDERRUN_DELTA,
                "max_musicdrop_delta": check_cloud_playability_artifacts.check_audible_audio_proof.MAX_MUSIC_DROP_DELTA,
            },
            "notes": "aggregate metrics only; not a human listening pass",
        },
        "status": {
            "audio": "SB16",
            "doomrun": "RUN",
            "gameplay": "OK",
            "sb16": "00000004:00000005",
            "dma": "00000001",
            "play": "00000001:00000000",
            "voiceq": "00000001:00000000:00000005",
            "musicq": "00000001:00000000",
            "audioirq": "00000006",
            "ack8": "00000006",
            "ack16": "00000000",
            "refill": "00000006",
            "doomsound": "00000008",
            "sfxmix": "00000008",
            "sfxvoices": "00000001",
            "musicmix": "00000006",
            "musicloop": "00000001",
            "musicpos": "00001400",
            "musicbuf": "00000C00",
            "musicunder": "00000000",
            "musicdrops": "00000000",
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
                "doomsound": {"start": "00000001", "final": "00000008", "delta": "00000007"},
                "audioirq": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                "refill": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                "sfxmix": {"start": "00000001", "final": "00000008", "delta": "00000007"},
                "musicmix": {"start": "00000001", "final": "00000006", "delta": "00000005"},
                "musicpos": {"start": "00000001", "final": "00001400", "delta": "000013FF"},
                "voiceq_update": {"start": "00000000", "final": "00000005", "delta": "00000005"},
            },
            "mix_lanes": {
                "non_music_sfx": {
                    "counter": "sfxmix",
                    "delta": "00000007",
                    "active_voice_snapshots": 5,
                },
                "music": {
                    "counter": "musicmix",
                    "delta": "00000005",
                    "stream_update_delta": "00000005",
                    "position_delta": "000013FF",
                    "active_voice_snapshots": 5,
                    "buffered_window_snapshots": 5,
                },
                "shared_sb16_refill": {
                    "irq_delta": "00000005",
                    "refill_delta": "00000005",
                },
            },
            "stream_health": {
                "buffered_window_snapshots": 5,
                "distinct_buffer_windows": 4,
                "buffer_floor": "00000100",
                "buffer_peak": "00001400",
                "buffer_final": "00001400",
                "under_delta": "00000000",
                "drop_delta": "00000000",
                "stream_update_delta": "00000005",
                "position_delta": "000013FF",
                "position_delta_per_update_floor": "00000300",
            },
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
            "claim": "non-silent remote QEMU output plus status-only SB16 continuity with streamed music chunks",
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
            write_human_session(artifact)
            write_human_manifest(artifact)
            check_cloud_playability_artifacts.validate_artifact_dir(
                artifact,
                require_human_notes=True,
            )

            write_human_notes(artifact, no_local_qemu="no")
            write_human_session(artifact)
            write_human_manifest(artifact)
            with self.assertRaisesRegex(AssertionError, "human playtest notes failed"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

            write_human_notes(artifact, operator_remote_vnc="unchecked")
            write_human_session(artifact)
            write_human_manifest(artifact)
            with self.assertRaisesRegex(AssertionError, "operator_remote_vnc"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_downloaded_human_session_requires_session_transcript(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact)

            with self.assertRaisesRegex(AssertionError, "human session file"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_downloaded_human_session_requires_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact)
            write_human_session(artifact)

            with self.assertRaisesRegex(AssertionError, "human manifest file"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_downloaded_human_session_rejects_manifest_tampering(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact)
            write_human_session(artifact)
            write_human_manifest(artifact)

            (artifact / "serial.remote.log").write_text("late extra diagnostic\n")
            with self.assertRaisesRegex(AssertionError, "file inventory does not match"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

            write_human_manifest(artifact)
            (artifact / "human-playtest-notes.txt").write_text(
                (artifact / "human-playtest-notes.txt").read_text().replace(
                    "playtester=jt",
                    "playtester=someone-else",
                )
            )
            with self.assertRaisesRegex(
                AssertionError,
                "human playtest session failed|byte count mismatch|sha256 mismatch",
            ):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_downloaded_human_session_rejects_session_tampering(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact)
            write_human_session(artifact)
            write_human_manifest(artifact)

            session_path = artifact / "human-playtest-session.json"
            session = json.loads(session_path.read_text())
            session["phases"][1]["sha256"] = "0" * 64
            session_path.write_text(json.dumps(session, indent=2, sort_keys=True) + "\n")

            with self.assertRaisesRegex(AssertionError, "human playtest session failed"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_downloaded_human_session_rejects_note_phase_hash_tampering(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact, phase_hash_after_fire="0" * 64)
            write_human_session(artifact)
            write_human_manifest(artifact)

            with self.assertRaisesRegex(AssertionError, "phase_hash_after_fire"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_downloaded_human_session_rejects_non_allowlisted_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact)
            write_human_session(artifact)
            write_human_manifest(artifact)

            (artifact / "freeform-extra.txt").write_text("not part of the proof contract\n")
            with self.assertRaisesRegex(AssertionError, "unexpected human session artifact"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            nested = artifact / "nested"
            nested.mkdir()
            write_valid_artifact(artifact)
            write_human_notes(artifact)
            write_human_session(artifact)
            write_human_manifest(artifact)

            (nested / "serial.remote.log").write_text("nested logs are not accepted\n")
            with self.assertRaisesRegex(AssertionError, "must be flat"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

    def test_cli_human_session_mode_validates_notes(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            write_human_notes(artifact)
            write_human_session(artifact)
            write_human_manifest(artifact)

            result = subprocess.run(
                [sys.executable, str(CHECKER), "--human-session", str(artifact)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("cloud playability artifact check OK", result.stdout)
        self.assertIn("post-download human verification OK", result.stdout)
        self.assertIn("phase status hashes:", result.stdout)

    def test_collector_builds_allowlisted_manual_human_bundle(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            build = tmpdir / "build"
            output = tmpdir / "human-proof"
            build.mkdir()
            write_valid_artifact(build)
            (build / "serial.remote.log").write_text("serial diagnostics\n")
            (build / "status.persistence-write.txt").write_text(valid_status())
            (build / "status.after-fire.bin").write_bytes(b"binary status page")
            (build / "disk.img").write_bytes(b"\x55\xaa" + b"disk" * 32)
            (build / "gfx.bin").write_bytes(b"pixels")
            (build / "DOOM1.WAD").write_bytes(b"IWAD" + b"\0" * 64)

            result = subprocess.run(
                [
                    sys.executable,
                    str(COLLECTOR),
                    "--build-dir",
                    str(build),
                    "--output-dir",
                    str(output),
                    "--playtester",
                    "jt",
                    "--scripted-proof-run-id",
                    "26156172979",
                    "--commit",
                    "abcdef0",
                    "--confirm-remote-vnc",
                    "--confirm-phase-actions",
                    "--confirm-phase-status-hashes",
                    "--confirm-no-forbidden-artifacts",
                    "--confirm-post-download-verification",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("human playtest bundle OK", result.stdout)
            self.assertIn("pre-download human verification OK", result.stdout)
            self.assertTrue((output / "human-playtest-notes.txt").exists())
            self.assertTrue((output / "human-playtest-session.json").exists())
            self.assertTrue((output / "human-playtest-manifest.json").exists())
            self.assertTrue((output / "serial.remote.log").exists())
            self.assertFalse((output / "status.persistence-write.txt").exists())
            self.assertFalse((output / "status.after-fire.bin").exists())
            self.assertFalse((output / "disk.img").exists())
            self.assertFalse((output / "gfx.bin").exists())
            self.assertFalse((output / "DOOM1.WAD").exists())
            check_cloud_playability_artifacts.validate_artifact_dir(
                output,
                require_human_notes=True,
            )

    def test_collector_requires_operator_confirmations(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            build = tmpdir / "build"
            output = tmpdir / "human-proof"
            build.mkdir()
            write_valid_artifact(build)

            result = subprocess.run(
                [
                    sys.executable,
                    str(COLLECTOR),
                    "--build-dir",
                    str(build),
                    "--output-dir",
                    str(output),
                    "--playtester",
                    "jt",
                    "--scripted-proof-run-id",
                    "26156172979",
                    "--commit",
                    "abcdef0",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--confirm-remote-vnc is required", result.stderr)

    def test_collector_rejects_repo_output_directory(self):
        result = subprocess.run(
            [
                sys.executable,
                str(COLLECTOR),
                "--build-dir",
                str(ROOT / "build"),
                "--output-dir",
                str(ROOT / "build" / "human-proof"),
                "--playtester",
                "jt",
                "--scripted-proof-run-id",
                "26156172979",
                "--confirm-remote-vnc",
                "--confirm-phase-actions",
                "--confirm-phase-status-hashes",
                "--confirm-no-forbidden-artifacts",
                "--confirm-post-download-verification",
            ],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("outside the repository", result.stderr)

    def test_collector_capture_phase_uses_remote_monitor_socket(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            build = tmpdir / "build"
            build.mkdir()
            sock_path = tmpdir / "monitor.sock"
            ready = threading.Event()
            commands = []

            def serve_once():
                with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as server:
                    server.bind(str(sock_path))
                    server.listen(1)
                    ready.set()
                    conn, _addr = server.accept()
                    with conn:
                        command = b""
                        while True:
                            chunk = conn.recv(4096)
                            if not chunk:
                                break
                            command += chunk
                        text = command.decode("ascii").strip()
                        commands.append(text)
                        output = Path(text.split()[-1])
                        output.write_bytes(b"Aurora\0OS gtic=00000180 leveltime=00000180")
                        conn.sendall(b"OK\r\n")

            thread = threading.Thread(target=serve_once)
            thread.start()
            self.assertTrue(ready.wait(2))

            result = subprocess.run(
                [
                    sys.executable,
                    str(COLLECTOR),
                    "--build-dir",
                    str(build),
                    "--monitor-socket",
                    str(sock_path),
                    "--capture-phase",
                    "after-fire",
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )
            thread.join(timeout=2)

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("human status capture OK", result.stdout)
            self.assertEqual(len(commands), 1)
            self.assertTrue(commands[0].startswith("pmemsave 0x9d000 4096 "))
            self.assertEqual(
                (build / "status.after-fire.txt").read_text(),
                "Aurora OS gtic=00000180 leveltime=00000180",
            )
            self.assertEqual(list(build.glob("status.after-fire.*.bin")), [])

    def test_human_session_artifact_checker_rejects_short_manual_duration(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_valid_artifact(artifact)
            (artifact / "status.txt").write_text(
                audio_phase_statuses()["status.txt"].replace(
                    "gtic=00000180 leveltime=00000180",
                    "gtic=00000080 leveltime=00000080",
                )
            )
            write_human_notes(artifact)
            write_human_session(artifact)
            write_human_manifest(artifact)

            with self.assertRaisesRegex(AssertionError, "manual human playability failed"):
                check_cloud_playability_artifacts.validate_artifact_dir(
                    artifact,
                    require_human_notes=True,
                )

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
