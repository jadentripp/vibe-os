#!/usr/bin/env python3
"""Validate the cloud human-playability runbook and downloaded diagnostics."""

from __future__ import annotations

import argparse
import fnmatch
import gzip
import hashlib
import io
import json
import os
import re
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
sys.path.insert(0, str(SCRIPT_DIR))

import check_real_wad_proof  # noqa: E402
import check_audio_continuity_proof  # noqa: E402
import check_audible_audio_proof  # noqa: E402
import check_human_playability_proof  # noqa: E402
import check_scripted_gameplay_proof  # noqa: E402
import check_vm_status_proof  # noqa: E402


RUNBOOK = ROOT / "docs" / "runbooks" / "remote-doom-playtest.md"
INTERACTIVE_RUNBOOK = ROOT / "docs" / "runbooks" / "cloud-interactive-playtest.md"
PLAY_NOW_RUNBOOK = ROOT / "docs" / "runbooks" / "play-now-cloud.md"
CODESPACES_RUNBOOK = ROOT / "docs" / "runbooks" / "codespaces-play-now.md"
PLAYABLE_DOC = ROOT / "docs" / "playable-cloud-proof.md"
OS_WORKFLOW = ROOT / ".github" / "workflows" / "os-smoke.yml"
WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
SOAK_WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-soak.yml"
README = ROOT / "README.md"
TESTS_README = ROOT / "tests" / "README.md"
MAKEFILE = ROOT / "Makefile"
HUMAN_PLAYTEST_SCRIPT = ROOT / "tools" / "run_remote_human_playtest.sh"
CODESPACES_PLAY_SCRIPT = ROOT / "tools" / "play_now_codespaces.sh"

REQUIRED_STATUS_FILES = (
    "status.early.txt",
    "status.after-start.txt",
    "status.after-fire.txt",
    "status.after-move.txt",
    "status.after-use.txt",
    "status.after-mouse.txt",
    "status.after-menu.txt",
    "status.txt",
)

REQUIRED_DIAGNOSTIC_FILES = (
    "kernel.elf",
    "user_probe.elf",
    "doom.elf",
)

REQUIRED_SYMBOL_FILES = (
    "doom.symbols",
)

OPTIONAL_AUDIO_PROOF_FILE = "audio-proof.json"
OPTIONAL_GAMEPLAY_PROOF_FILE = "gameplay-proof.json"
SOAK_SUMMARY_FILE = "real-wad-soak-summary.json"
SOAK_SUMMARY_SCHEMA = "real-wad-soak-summary-v1"
SOAK_ATTEMPT_SCHEMA = "real-wad-soak-attempt-v1"
HUMAN_NOTES_FILE = "human-playtest-notes.txt"
HUMAN_NOTES_SCHEMA = "human-playtest-notes-v2"
HUMAN_MANIFEST_FILE = "human-playtest-manifest.json"
HUMAN_MANIFEST_SCHEMA = "human-playtest-manifest-v1"
HUMAN_SESSION_FILE = "human-playtest-session.json"
HUMAN_SESSION_SCHEMA = "human-playtest-session-v1"
HUMAN_CHECKLIST_FILE = "human-playtest-checklist.txt"
HUMAN_CHECKLIST_SCHEMA = "human-playtest-checklist-v1"
HUMAN_POST_DOWNLOAD_VERIFICATION_SCHEMA = "human-playtest-post-download-verification-v1"
HUMAN_PHASE_HASH_NOTE_KEYS = {
    "early": "phase_hash_early",
    "after-start": "phase_hash_after_start",
    "after-fire": "phase_hash_after_fire",
    "after-move": "phase_hash_after_move",
    "after-use": "phase_hash_after_use",
    "after-mouse": "phase_hash_after_mouse",
    "after-menu": "phase_hash_after_menu",
    "final": "phase_hash_final",
}
HUMAN_OPERATOR_CONFIRMATION_FIELDS = {
    "remote_vnc": "operator_remote_vnc",
    "phase_actions": "operator_phase_actions",
    "phase_status_hashes": "operator_phase_status_hashes",
    "no_forbidden_artifacts": "operator_no_forbidden_artifacts",
    "post_download_verification": "operator_post_download_verification",
}
REQUIRED_HUMAN_NOTE_FIELDS = {
    "schema": (HUMAN_NOTES_SCHEMA,),
    "scripted_proof": ("real-wad-smoke-pass",),
    "remote_host": ("disposable",),
    "qemu_location": ("remote",),
    "qemu_display": ("127.0.0.1:1",),
    "monitor_socket": ("unix-monitor-socket",),
    "vnc_tunnel": ("loopback-only",),
    "vnc_endpoint": ("127.0.0.1:5901",),
    "wad": ("shareware-v1.9-validated-remote-only",),
    "display": ("pass",),
    "keyboard": ("pass",),
    "mouse": ("pass",),
    "visual_evidence": ("e1m1-visible-via-remote-vnc",),
    "keyboard_evidence": ("fire-move-use-menu-visible",),
    "mouse_evidence": ("motion-click-visible",),
    "status_capture": ("monitor-pmemsave-0x9d000",),
    "session_phases": (
        "early,after-start,after-fire,after-move,after-use,after-mouse,after-menu,final",
    ),
    "diagnostics": ("non-wad-status-only",),
    "proof_bundle": ("allowlisted-status-only",),
    "no_local_qemu": ("yes",),
    "no_wad_upload": ("yes",),
    "no_disk_upload": ("yes",),
    "no_pixel_upload": ("yes",),
    "operator_remote_vnc": ("confirmed",),
    "operator_phase_actions": ("confirmed",),
    "operator_phase_status_hashes": ("confirmed",),
    "operator_no_forbidden_artifacts": ("confirmed",),
    "operator_post_download_verification": ("required",),
}
REQUIRED_FREEFORM_HUMAN_NOTE_FIELDS = (
    "commit",
    "playtester",
    "scripted_proof_run_id",
) + tuple(HUMAN_PHASE_HASH_NOTE_KEYS.values())
OPTIONAL_HUMAN_NOTE_FIELDS = {
    "audio": ("status-only", "listener-pass", "audio-proof-json-pass", "not-tested"),
}
HUMAN_NOTE_FIELD_PATTERNS = {
    "commit": r"(?:[0-9A-Fa-f]{7,40}|unknown)",
    "playtester": r"[A-Za-z0-9._-]{2,64}",
    "scripted_proof_run_id": r"[0-9]{6,32}",
    **{
        note_key: r"[0-9A-Fa-f]{64}"
        for note_key in HUMAN_PHASE_HASH_NOTE_KEYS.values()
    },
}

HUMAN_SESSION_PHASES = (
    ("early", "status.early.txt", "pre-input status baseline"),
    ("after-start", "status.after-start.txt", "human confirmed E1M1 visible over remote VNC"),
    ("after-fire", "status.after-fire.txt", "human pressed Ctrl/fire and saw Doom respond"),
    ("after-move", "status.after-move.txt", "human held an arrow key and saw movement or turning"),
    ("after-use", "status.after-use.txt", "human pressed Space/use and saw Doom accept it"),
    ("after-mouse", "status.after-mouse.txt", "human moved/clicked the mouse and saw Doom respond"),
    ("after-menu", "status.after-menu.txt", "human pressed Escape and saw the Doom menu"),
    ("final", "status.txt", "final status captured after the manual session"),
)
HUMAN_SESSION_STATUS_FIELDS = (
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "gflags",
    "gaction",
    "pflags",
    "pbuttons",
    "ppos",
    "pdelta",
    "pangle",
    "pangledelta",
    "pammo",
    "prefire",
    "keyirq",
    "keyqueue",
    "keypoll",
    "keyseen",
    "keylast",
    "mouse",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "mousebtn",
    "mousedelta",
    "audio",
    "vmmhi",
    "vmmhva",
    "vmmhpa",
    "vmmhpt",
    "vmmhfree",
    "doomsound",
    "sfxmix",
    "sfxdma",
    "musicstream",
    "musicpull",
    "musicpos",
    "doomrun",
    "doomopen",
    "doomread",
    "doomerr",
    "doomfault",
    "panic",
    "shutdown",
)
HUMAN_SESSION_ALLOWED_EXACT_FILES = set(
    REQUIRED_STATUS_FILES
    + REQUIRED_DIAGNOSTIC_FILES
    + REQUIRED_SYMBOL_FILES
    + (
        OPTIONAL_AUDIO_PROOF_FILE,
        HUMAN_NOTES_FILE,
        HUMAN_CHECKLIST_FILE,
        HUMAN_MANIFEST_FILE,
        HUMAN_SESSION_FILE,
    )
)
HUMAN_SESSION_ALLOWED_PATTERNS = ("*.log",)

FORBIDDEN_ARTIFACT_PATTERNS = (
    "*.wad",
    "*.WAD",
    "*.iwad",
    "*.IWAD",
    "*.pwad",
    "*.PWAD",
    "*.img",
    "*.iso",
    "*.raw",
    "*.qcow2",
    "gfx.bin",
    "gfx*.txt",
    "vga*.bin",
    "vga*.txt",
    "*.png",
    "*.ppm",
    "*.pgm",
    "*.bmp",
    "*.wav",
    "*.wave",
    "*.mp3",
    "*.ogg",
    "*.oga",
    "*.flac",
    "*.aiff",
    "*.aif",
    "*.au",
)

CONTENT_SIGNATURES = (
    (b"IWAD", "WAD/IWAD payload"),
    (b"PWAD", "WAD/PWAD payload"),
    (b"\x89PNG\r\n\x1a\n", "PNG image"),
    (b"BM", "BMP image"),
    (b"P6", "PPM image"),
    (b"P5", "PGM image"),
    (b"QFI\xfb", "QCOW2 disk image"),
    (b"RIFF", "RIFF/WAV audio"),
    (b"ID3", "MP3 audio"),
    (b"OggS", "Ogg audio"),
    (b"fLaC", "FLAC audio"),
    (b"FORM", "AIFF audio"),
)

SOAK_ARTIFACT_POLICY = {
    "aggregate_status_json_only": True,
    "contains_wad_data": False,
    "contains_disk_image": False,
    "contains_pixels": False,
    "contains_raw_audio": False,
    "contains_raw_status_text": False,
    "contains_qemu_logs": False,
    "upload_only_json": True,
}

SOAK_PASS_CRITERIA = {
    "playability": {
        "real_wad_proof_passed": True,
        "doomrun_run": True,
        "gameplay_ok": True,
        "e1m1": True,
        "gtic_and_leveltime_progress": True,
    },
    "input_state_changes": {
        "scripted_human_playability_passed": True,
        "scripted_gameplay_transition_passed": True,
        "key_counters_progress": True,
        "fire_ammo_or_refire_changed": True,
        "movement_position_changed": True,
        "use_action_seen": True,
        "mouse_state_changed": True,
        "menu_toggled": True,
    },
    "sb16_continuity": {
        "audio_sb16": True,
        "dma_programmed": True,
        "playback_started": True,
        "irq_refill_progress": True,
        "sfxmix_progress": True,
        "sfxdma_progress": True,
        "music_stream_progress": True,
    },
    "audible_aggregate_proof": {
        "aggregate_json_only": True,
        "no_raw_audio_uploaded": True,
        "same_sb16_continuity_snapshots": True,
    },
}

SOAK_PHASE_FILES = (
    ("early", "status.early.txt"),
    ("after-start", "status.after-start.txt"),
    ("after-fire", "status.after-fire.txt"),
    ("after-move", "status.after-move.txt"),
    ("after-use", "status.after-use.txt"),
    ("after-mouse", "status.after-mouse.txt"),
    ("after-menu", "status.after-menu.txt"),
    ("final", "status.txt"),
)

SOAK_STATUS_SUMMARY_FIELDS = (
    "doomrun",
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "gflags",
    "pflags",
    "pbuttons",
    "ppos",
    "pdelta",
    "pangle",
    "pangledelta",
    "pammo",
    "prefire",
    "keyirq",
    "keyqueue",
    "keypoll",
    "keyseen",
    "keylast",
    "mouse",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "mousebtn",
    "mousedelta",
    "audio",
    "vmmhi",
    "vmmhva",
    "vmmhpa",
    "vmmhpt",
    "vmmhfree",
    "doomsound",
    "sfxmix",
    "sfxdma",
    "musicmix",
    "musicpos",
    "musicbuf",
    "musicstream",
    "musicpull",
    "audioirq",
    "ack8",
    "ack16",
    "refill",
    "sb16",
    "dma",
    "play",
    "voiceq",
    "musicq",
    "doomopen",
    "doomread",
    "doomerr",
    "doomfault",
    "panic",
    "shutdown",
)

SOAK_SUCCESS_GATES = (
    "real_wad_proof",
    "scripted_human_playability",
    "scripted_gameplay_transition",
    "playability",
    "input_state_changes",
    "sb16_continuity",
)

FORBIDDEN_ARCHIVE_SUFFIXES = (
    ".wad",
    ".iwad",
    ".pwad",
    ".img",
    ".iso",
    ".raw",
    ".qcow2",
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".bmp",
    ".ppm",
    ".pgm",
    ".wav",
    ".wave",
    ".mp3",
    ".ogg",
    ".oga",
    ".flac",
    ".aiff",
    ".aif",
    ".au",
)


def _read(path: Path) -> str:
    return path.read_text()


def _require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label} missing {needle!r}")


def _assert_no_forbidden_uploads(workflow: str) -> None:
    if "uses: actions/upload-artifact@v4" not in workflow:
        raise AssertionError("real-WAD workflow must upload diagnostic artifacts")
    upload_block = workflow.split("uses: actions/upload-artifact@v4", 1)[1]
    for forbidden in (
        "build/disk.img",
        "build/gfx.bin",
        "build/vga*.txt",
        "build/vga*.bin",
        "build/doom-audio.wav",
        "*.wav",
        "*.mp3",
        "*.ogg",
        "*.flac",
        "DOOM1.WAD",
        "*.WAD",
        "*.wad",
    ):
        if forbidden in upload_block:
            raise AssertionError(f"workflow upload block includes forbidden artifact {forbidden}")


def _assert_soak_uploads_only_json(workflow: str) -> None:
    if "uses: actions/upload-artifact@v4" not in workflow:
        raise AssertionError("real-WAD soak workflow must upload metadata artifacts")
    upload_block = workflow.split("uses: actions/upload-artifact@v4", 1)[1]
    _require(upload_block, "real-wad-soak-metadata", "real-WAD soak upload block")
    _require(upload_block, "real-wad-soak/*.json", "real-WAD soak upload block")
    for forbidden in (
        "build/",
        "status*.txt",
        "*.log",
        "*.bin",
        "*.elf",
        "*.symbols",
        "audio-proof.json",
        "doom-audio.wav",
        "disk.img",
        "DOOM1.WAD",
        "*.WAD",
        "*.wad",
        "*.wav",
        "*.png",
    ):
        if forbidden in upload_block:
            raise AssertionError(
                f"real-WAD soak upload block includes non-JSON/raw artifact {forbidden}"
            )


def validate_repo_contract() -> None:
    runbook = _read(RUNBOOK)
    interactive_runbook = _read(INTERACTIVE_RUNBOOK)
    play_now_runbook = _read(PLAY_NOW_RUNBOOK)
    codespaces_runbook = _read(CODESPACES_RUNBOOK)
    playable = _read(PLAYABLE_DOC)
    os_workflow = _read(OS_WORKFLOW)
    workflow = _read(WORKFLOW)
    soak_workflow = _read(SOAK_WORKFLOW)
    readme = _read(README)
    tests_readme = _read(TESTS_README)
    makefile = _read(MAKEFILE)
    human_script = _read(HUMAN_PLAYTEST_SCRIPT)
    codespaces_script = _read(CODESPACES_PLAY_SCRIPT)

    for needle in (
        "qemu-system-x86_64",
        "-display vnc=127.0.0.1:1",
        "ssh -L 5901:127.0.0.1:5901",
        "tools/prepare_shareware_wad.py",
        "tools/check_cloud_playability_artifacts.py",
        "real-wad-soak-summary.json",
        "tools/collect_human_playtest_bundle.py",
        "tools/run_remote_human_playtest.sh",
        "tools/check_real_wad_proof.py",
        "tools/check_human_playability_proof.py",
        "tools/check_audio_continuity_proof.py",
        "tools/check_audible_audio_proof.py",
        "tools/check_vm_status_proof.py",
        "tools/triage_cloud_status.py",
        "human-playtest-notes.txt",
        "human-playtest-checklist.txt",
        "schema=human-playtest-checklist-v1",
        "schema=human-playtest-notes-v2",
        "human-playtest-session.json",
        "human-playtest-manifest.json",
        "scripted_proof=real-wad-smoke-pass",
        "scripted_proof_run_id=",
        "--scripted-proof-run-id",
        "--capture-phase",
        "human status capture OK",
        "--confirm-remote-vnc",
        "--confirm-phase-actions",
        "--confirm-phase-status-hashes",
        "--confirm-no-forbidden-artifacts",
        "--confirm-post-download-verification",
        "proof_bundle=allowlisted-status-only",
        "qemu_display=127.0.0.1:1",
        "vnc_endpoint=127.0.0.1:5901",
        "visual_evidence=e1m1-visible-via-remote-vnc",
        "keyboard_evidence=fire-move-use-menu-visible",
        "mouse_evidence=motion-click-visible",
        "status_capture=monitor-pmemsave-0x9d000",
        "session_phases=early,after-start,after-fire,after-move,after-use,after-mouse,after-menu,final",
        "phase_hash_early=",
        "phase_hash_after_start=",
        "phase_hash_after_fire=",
        "phase_hash_after_move=",
        "phase_hash_after_use=",
        "phase_hash_after_mouse=",
        "phase_hash_after_menu=",
        "phase_hash_final=",
        "operator_remote_vnc=confirmed",
        "operator_phase_actions=confirmed",
        "operator_phase_status_hashes=confirmed",
        "operator_no_forbidden_artifacts=confirmed",
        "operator_post_download_verification=required",
        "pre-download human verification OK",
        "post-download human verification OK",
        "bundle_sha256=",
        "manifest_sha256=",
        "--human-session",
        "capture_status",
        "no_local_qemu=yes",
        "doom.symbols",
        "audio-proof.json",
        "Real WAD soak",
        "soak summary",
        "gh workflow run real-wad-soak.yml",
        "-f expected_ref=\"$branch\"",
        "Run workflow branch selector",
        "default branch",
        "playability, input state changes, SB16 continuity, and optional audible aggregate proof",
        "status.after-fire.txt",
        "status.after-start.txt",
        "status.after-move.txt",
        "status.after-use.txt",
        "status.after-mouse.txt",
        "status.after-menu.txt",
        "Arrow keys",
        "Ctrl: fire",
        "Space: use",
        "Escape",
        "audio=SB16",
        "audio=NONE",
        "audible remote proof",
        "Save/config persistence",
        "Doom exit/reboot behavior",
        "destroy the disposable remote host",
    ):
        _require(runbook, needle, "remote playtest runbook")

    for text, label in (
        (interactive_runbook, "cloud interactive playtest runbook"),
        (play_now_runbook, "play-now cloud runbook"),
        (readme, "README"),
        (tests_readme, "tests README"),
    ):
        _require(text, "tools/run_remote_human_playtest.sh", label)
        _require(text, "--scripted-proof-run-id", label)
        _require(text, "--playtester", label)

    for text, label in (
        (play_now_runbook, "play-now cloud runbook"),
        (codespaces_runbook, "Codespaces play-now runbook"),
        (readme, "README"),
    ):
        _require(text, "./tools/play_now_codespaces.sh", label)
        _require(text, "disposable", label)
        _require(text, "Codespace", label)

    for needle in (
        "Usage: tools/run_remote_human_playtest.sh --playtester NAME --scripted-proof-run-id RUN_ID",
        "Refusing to run the remote human playtest helper on macOS",
        "tools/collect_human_playtest_bundle.py",
        "--capture-phase \"$phase\"",
        "--confirm-remote-vnc",
        "--confirm-phase-actions",
        "--confirm-phase-status-hashes",
        "--confirm-no-forbidden-artifacts",
        "--confirm-post-download-verification",
        "tar -C \"$output_parent\" -czf \"$TARBALL\" \"$output_base\"",
        "python3 tools/check_cloud_playability_artifacts.py --human-session ./vibe-os-human-proof",
        "--expected-commit",
        "--expected-scripted-proof-run-id",
        "pre-download human verification OK",
        "post-download human verification OK",
    ):
        _require(human_script, needle, "remote human playtest helper")

    for forbidden in (
        "qemu-system",
        "DOOM1.WAD",
        "disk.img",
        "gfx.bin",
        "doom-audio.wav",
        "git add",
        "actions/upload-artifact",
    ):
        if forbidden in human_script:
            raise AssertionError(
                f"remote human playtest helper should not mention forbidden operation/artifact {forbidden!r}"
            )

    for needle in (
        "Usage: tools/play_now_codespaces.sh [options]",
        "codespace create",
        "gh \"${create_args[@]}\"",
        "--devcontainer-path \".devcontainer/devcontainer.json\"",
        "--preflight, --dry-run",
        "require_clean_pushed_git_state",
        "local git working tree is dirty",
        "differs from upstream",
        "play-now Codespaces preflight OK",
        "local artifact transfer: none",
        "dry-run: Codespace was not created or modified",
        "novnc_url_from_browse_url",
        "gh codespace ssh -c \"$CODESPACE_NAME\" -- env VIBE_PLAY_REF=\"$REF\" NOVNC_PORT=\"$NOVNC_PORT\" bash -lc \"$payload\"",
        "./tools/play_now_remote.sh --preflight",
        "NOVNC_PORT=$NOVNC_PORT nohup ./tools/play_now_remote.sh",
        "gh codespace ports visibility \"$NOVNC_PORT:private\"",
        "noVNC port $NOVNC_PORT is private",
        "vnc.html?autoconnect=1",
        "Makefile",
        "tools/prepare_shareware_wad.py",
        "tools/make_wad_image.py",
        "Delete when done: gh codespace delete -c \\\"$CODESPACE_NAME\\\" --force",
    ):
        _require(codespaces_script, needle, "Codespaces play-now launcher")

    for forbidden in (
        "qemu-system-x86_64",
        "make DOOM_WAD",
        "python3 tools/prepare_shareware_wad.py",
        "gh codespace cp",
        "scp ",
        "build/disk.img",
        "DOOM1.WAD",
        "doom-audio.wav",
        "git add",
    ):
        if forbidden in codespaces_script:
            raise AssertionError(
                f"Codespaces launcher should not run/copy forbidden payload {forbidden!r}"
            )

    for forbidden in (
        "make ALLOW_LOCAL_VM=1 run",
        "make ALLOW_LOCAL_VM=1 smoke",
        "build/gfx.bin",
        "build/vga.txt",
    ):
        if forbidden in runbook:
            raise AssertionError(f"runbook should not instruct local/pixel artifact path {forbidden!r}")

    _require(playable, "Remote Doom Playtest Runbook", "playable cloud proof doc")
    _require(playable, "Current-head cloud proof state: pending", "playable cloud proof doc")
    _require(playable, "gh workflow run os-smoke.yml", "playable cloud proof doc")
    _require(playable, "gh workflow run real-wad-smoke.yml", "playable cloud proof doc")
    _require(playable, "tools/collect_human_playtest_bundle.py", "playable cloud proof doc")
    _require(playable, "human-playtest-notes-v2", "playable cloud proof doc")
    _require(playable, "human-playtest-checklist.txt", "playable cloud proof doc")
    _require(playable, "human-playtest-session.json", "playable cloud proof doc")
    _require(playable, "human-playtest-manifest.json", "playable cloud proof doc")
    _require(playable, "post-download human verification OK", "playable cloud proof doc")
    _require(playable, "-f expected_ref=\"$branch\"", "playable cloud proof doc")
    _require(playable, "default branch", "playable cloud proof doc")
    _require(playable, "puser", "playable cloud proof doc")
    _require(playable, "pspin", "playable cloud proof doc")
    _require(readme, "docs/runbooks/remote-doom-playtest.md", "README")
    _require(readme, "Current-head cloud proof state: pending", "README")
    _require(readme, "gh workflow run os-smoke.yml", "README")
    _require(readme, "gh workflow run real-wad-smoke.yml", "README")
    _require(readme, "gh workflow run real-wad-soak.yml", "README")
    _require(readme, "tools/collect_human_playtest_bundle.py", "README")
    _require(readme, "human-playtest-notes-v2", "README")
    _require(readme, "human-playtest-checklist.txt", "README")
    _require(readme, "human-playtest-session.json", "README")
    _require(readme, "post-download human verification OK", "README")
    _require(tests_readme, "check_cloud_playability_artifacts.py", "tests README")
    _require(tests_readme, "expected_ref", "tests README")
    _require(tests_readme, "Current-head cloud proof state", "tests README")
    _require(tests_readme, "collect_human_playtest_bundle.py", "tests README")
    _require(tests_readme, "phase_hash_*", "tests README")
    _require(tests_readme, "human-playtest-checklist.txt", "tests README")
    _require(tests_readme, "human-playtest-session.json", "tests README")
    _require(makefile, "cloud-playability-check", "Makefile")
    _require(makefile, "persistence-image-check", "Makefile")
    _require(makefile, "PERSISTENCE_BASELINE_IMAGE", "Makefile")
    _require(makefile, "PERSISTENCE_REBOOT_BASELINE_IMAGE", "Makefile")
    _require(makefile, "PERSISTENCE_REBOOT_STATUS", "Makefile")
    _require(makefile, "PERSISTENCE_WRITE_STATUS", "Makefile")
    _require(makefile, "PERSISTENCE_SAVE_WRITE_STATUS", "Makefile")
    _require(makefile, "PERSISTENCE_LOAD_STATUS", "Makefile")
    _require(makefile, "tools/check_cloud_playability_artifacts.py --repo-contract", "Makefile")

    for needle in (
        "workflow_dispatch:",
        "expected_ref:",
        "INPUT_EXPECTED_REF",
        "Confirm selected proof ref",
        "GITHUB_REF_NAME",
        "gh workflow run os-smoke.yml --ref",
        "Running OS smoke proof on ref",
        "make test",
        "make ALLOW_LOCAL_VM=1 smoke",
    ):
        _require(os_workflow, needle, "OS smoke workflow")

    for needle in (
        "workflow_dispatch:",
        "expected_ref:",
        "INPUT_EXPECTED_REF",
        "Confirm selected proof ref",
        "GITHUB_REF_NAME",
        "gh workflow run real-wad-smoke.yml --ref",
        "Running real-WAD smoke proof on ref",
        "SMOKE_CAPTURE_GFX=0",
        "SMOKE_SKIP_ASSERTIONS=1",
        "if: always()",
        "QEMU_EXTRA_ARGS=\"-audiodev wav,id=snd0,path=$RUNNER_TEMP/persistence-write-audio.wav -device sb16,audiodev=snd0\"",
        "QEMU_EXTRA_ARGS=\"-audiodev wav,id=snd0,path=$RUNNER_TEMP/persistence-load-audio.wav -device sb16,audiodev=snd0\"",
        "QEMU_EXTRA_ARGS=\"-audiodev wav,id=snd0,path=$RUNNER_TEMP/persistence-reboot-audio.wav -device sb16,audiodev=snd0\"",
        "SMOKE_INPUT_SCRIPT=\"after-start:wait=2,snapshot after-fire:hold=ctrl:800",
        "after-mouse:mousebtn=1,wait=1,mouse=4:0,wait=1,mousebtn=0,wait=1,mouse=64:0",
        "after-start:wait=2,snapshot",
        "persistence_proof:",
        "persistence_input_script:",
        "persistence_load_input_script:",
        "persistence_save_slot:",
        "default: \"auto\"",
        "Persistence write script:",
        "Persistence load script:",
        "save-slot-${PERSISTENCE_SAVE_SLOT}",
        "load-slot-${PERSISTENCE_SAVE_SLOT}",
        "Capture fresh persistence baseline",
        "if: ${{ always() && (inputs.persistence_proof || inputs.persistence_save_slot != '') }}",
        "cp build/disk.img \"$RUNNER_TEMP/disk.before-persistence.img\"",
        "check_args=(--baseline-image \"$baseline\")",
        "check_args+=(--require-default)",
        "check_args+=(--write-status build/status.persistence-write.txt)",
        "check_args+=(--require-save-slot \"$PERSISTENCE_SAVE_SLOT\")",
        "check_args+=(--save-write-status build/status.persistence-write.txt)",
        "slot_marker_payload=\"$(printf",
        "cp \"$baseline\" build/disk.img",
        "if [ -z \"${PERSISTENCE_SAVE_SLOT:-}\" ]; then",
        "write_marker PERSISTENCE_CHECKPOINT_NAME \"\"",
        "write_marker SAVE_REQUEST_NAME \"$slot_marker_payload\"",
        "name = getattr(make_wad_image, os.environ[\"PERSISTENCE_MARKER_NAME\"])",
        "data = os.environ[\"PERSISTENCE_MARKER_PAYLOAD\"].encode(\"ascii\")",
        "delete_marker SAVE_REQUEST_NAME",
        "write_marker LOAD_REQUEST_NAME \"$slot_marker_payload\"",
        "write_status=\"build/persistence-write/status.save-slot-${PERSISTENCE_SAVE_SLOT}.txt\"",
        "write_status=\"build/persistence-write/status.txt\"",
        "test -f \"$write_status\"",
        "cp \"$write_status\" build/status.persistence-write.txt",
        "build/status.persistence-write.txt",
        "build/status.persistence-load.txt",
        "build/status.persistence-reboot.txt",
        "build/status.persistence-write-proof.txt",
        "build/status.persistence-load-proof.txt",
        "build/status.persistence-reboot-proof.txt",
        "tools/check_doom_persistence_image.py",
        "--baseline-image \"$baseline\"",
        "--reboot-baseline-image \"$after_write\"",
        "--save-write-status",
        "--load-status build/status.persistence-load.txt",
        "python3 tools/check_real_wad_proof.py \\",
        "--baseline build/status.after-start.txt",
        "--start build/status.after-start.txt",
        "--fire build/status.after-fire.txt",
        "--movement build/status.after-move.txt",
        "--use build/status.after-use.txt",
        "--mouse build/status.after-mouse.txt",
        "--menu build/status.after-menu.txt",
        "python3 tools/check_human_playability_proof.py",
        "python3 tools/check_scripted_gameplay_proof.py",
        "--write-json build/gameplay-proof.json",
        "python3 tools/check_vm_status_proof.py",
        "--require-exec",
        "--require-preempt",
        "python3 tools/check_audio_continuity_proof.py",
        "python3 tools/check_audible_audio_proof.py",
        "Assert gameplay/audio proof bundle",
        "proof_dir=\"$RUNNER_TEMP/gameplay-audio-proof\"",
        "cp build/gameplay-proof.json \"$proof_dir\"/",
        "python3 tools/check_cloud_playability_artifacts.py \"$proof_dir\"",
        "--require-gameplay-proof",
        "Triage cloud status",
        "python3 tools/triage_cloud_status.py build/status.txt",
        'rm -f "$WAD_PATH"',
        "build/status*.bin",
        "build/status*.txt",
        "build/*.log",
        "build/persistence-*/*.log",
        "build/kernel.elf",
        "build/user_probe.elf",
        "build/doom.elf",
        "build/doom.symbols",
        "build/audio-proof.json",
        "build/gameplay-proof.json",
    ):
        _require(workflow, needle, "real-WAD workflow")
    _assert_no_forbidden_uploads(workflow)

    for needle in (
        "workflow_dispatch:",
        "attempts:",
        "min_passes:",
        "audible_audio_proof:",
        "expected_ref:",
        "INPUT_EXPECTED_REF",
        "Confirm selected proof ref",
        "GITHUB_REF_NAME",
        "gh workflow run real-wad-soak.yml --ref",
        "tools/prepare_shareware_wad.py",
        "SOAK_ATTEMPTS",
        "SOAK_MIN_PASSES",
        "SMOKE_CAPTURE_GFX=0",
        "SMOKE_SKIP_ASSERTIONS=1",
        "SMOKE_INPUT_SCRIPT=\"after-start:wait=2,snapshot after-fire:hold=ctrl:800",
        "python3 tools/check_real_wad_proof.py",
        "python3 tools/check_human_playability_proof.py",
        "python3 tools/check_scripted_gameplay_proof.py",
        "scripted_gameplay_transition",
        "python3 tools/check_vm_status_proof.py",
        "python3 tools/check_audio_continuity_proof.py",
        "python3 tools/check_audible_audio_proof.py",
        "proof_dir=\"$RUNNER_TEMP/real-wad-soak-proof-$attempt\"",
        "cp build/gameplay-proof.json \"$proof_dir\"/",
        "python3 tools/check_cloud_playability_artifacts.py \\",
        "\"$proof_dir\"",
        "--require-gameplay-proof",
        "--write-soak-attempt",
        "--write-soak-summary",
        "--soak-summary",
        "real-wad-soak-summary.json",
        "real-wad-soak-metadata",
        "rm -f \"$WAD_PATH\"",
    ):
        _require(soak_workflow, needle, "real-WAD soak workflow")
    _assert_soak_uploads_only_json(soak_workflow)


def _relative_names(root: Path) -> list[str]:
    return [
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file()
    ]


def _find_one(names: list[str], basename: str) -> str | None:
    matches = [name for name in names if Path(name).name == basename]
    if len(matches) > 1:
        joined = ", ".join(matches)
        raise AssertionError(f"duplicate diagnostic file basename {basename}: {joined}")
    return matches[0] if matches else None


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


STATUS_FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")


def _status_fields(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in STATUS_FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise AssertionError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    return fields


def _human_status_summary(path: Path) -> dict[str, str]:
    fields = _status_fields(path.read_text())
    return {
        name: fields.get(name, "<missing>")
        for name in HUMAN_SESSION_STATUS_FIELDS
    }


def _utc_now_text() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _assert_utc_timestamp(value: object, label: str) -> None:
    if not isinstance(value, str):
        raise AssertionError(f"{label} must be an ISO-8601 UTC string")
    if not value.endswith("Z"):
        raise AssertionError(f"{label} must end with Z")
    try:
        datetime.fromisoformat(value[:-1] + "+00:00")
    except ValueError as exc:
        raise AssertionError(f"{label} must be an ISO-8601 UTC string") from exc


def _human_session_id(notes: dict[str, str], phases: list[dict]) -> str:
    identity = {
        "schema": HUMAN_SESSION_SCHEMA,
        "commit": notes.get("commit", ""),
        "playtester": notes.get("playtester", ""),
        "scripted_proof_run_id": notes.get("scripted_proof_run_id", ""),
        "operator_confirmations": _operator_confirmations_from_notes(notes),
        "phase_status_hashes": _phase_status_hashes_from_notes(notes),
        "phases": [
            {
                "phase": phase["phase"],
                "status_file": phase["status_file"],
                "sha256": phase["sha256"],
            }
            for phase in phases
        ],
    }
    return hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest()


def _phase_status_hashes_from_notes(notes: dict[str, str]) -> dict[str, str]:
    return {
        phase: notes.get(note_key, "")
        for phase, note_key in HUMAN_PHASE_HASH_NOTE_KEYS.items()
    }


def _operator_confirmations_from_notes(notes: dict[str, str]) -> dict[str, str]:
    return {
        label: notes.get(note_key, "")
        for label, note_key in HUMAN_OPERATOR_CONFIRMATION_FIELDS.items()
    }


def build_human_session(
    artifact_dir: Path,
    collected_at_utc: str | None = None,
) -> dict:
    names = _relative_names(artifact_dir)
    notes_name = _find_one(names, HUMAN_NOTES_FILE)
    if notes_name is None:
        raise AssertionError(f"missing expected human review file: {HUMAN_NOTES_FILE}")
    notes = _load_human_notes(artifact_dir / notes_name)

    phases: list[dict] = []
    for phase_name, status_file, human_action in HUMAN_SESSION_PHASES:
        status_name = _find_one(names, status_file)
        if status_name is None:
            raise AssertionError(f"missing expected human status file: {status_file}")
        status_path = artifact_dir / status_name
        phases.append(
            {
                "phase": phase_name,
                "status_file": status_file,
                "human_action": human_action,
                "bytes": status_path.stat().st_size,
                "sha256": _sha256_file(status_path),
                "summary": _human_status_summary(status_path),
            }
        )

    session = {
        "schema": HUMAN_SESSION_SCHEMA,
        "source": "remote-vnc-human-session",
        "generated_by": "tools/collect_human_playtest_bundle.py",
        "collected_at_utc": collected_at_utc or _utc_now_text(),
        "commit": notes.get("commit", ""),
        "playtester": notes.get("playtester", ""),
        "scripted_proof": notes.get("scripted_proof", ""),
        "scripted_proof_run_id": notes.get("scripted_proof_run_id", ""),
        "phase_order": [phase for phase, _, _ in HUMAN_SESSION_PHASES],
        "phase_status_hashes": _phase_status_hashes_from_notes(notes),
        "status_capture": notes.get("status_capture", ""),
        "remote_endpoint": {
            "qemu_location": notes.get("qemu_location", ""),
            "qemu_display": notes.get("qemu_display", ""),
            "vnc_tunnel": notes.get("vnc_tunnel", ""),
            "vnc_endpoint": notes.get("vnc_endpoint", ""),
            "monitor_socket": notes.get("monitor_socket", ""),
        },
        "human_attestation": {
            "remote_host": notes.get("remote_host", ""),
            "wad": notes.get("wad", ""),
            "display": notes.get("display", ""),
            "keyboard": notes.get("keyboard", ""),
            "mouse": notes.get("mouse", ""),
            "audio": notes.get("audio", ""),
            "visual_evidence": notes.get("visual_evidence", ""),
            "keyboard_evidence": notes.get("keyboard_evidence", ""),
            "mouse_evidence": notes.get("mouse_evidence", ""),
            "no_local_qemu": notes.get("no_local_qemu", ""),
            "no_wad_upload": notes.get("no_wad_upload", ""),
            "no_disk_upload": notes.get("no_disk_upload", ""),
            "no_pixel_upload": notes.get("no_pixel_upload", ""),
        },
        "operator_confirmations": _operator_confirmations_from_notes(notes),
        "validation_gates": [
            "tools/check_real_wad_proof.py",
            "tools/check_human_playability_proof.py",
            "tools/check_vm_status_proof.py",
            "tools/check_audio_continuity_proof.py",
            "tools/check_cloud_playability_artifacts.py --human-session",
        ],
        "phases": phases,
    }
    session["session_id"] = _human_session_id(notes, phases)
    return session


def build_human_checklist(artifact_dir: Path) -> str:
    names = _relative_names(artifact_dir)
    notes_name = _find_one(names, HUMAN_NOTES_FILE)
    if notes_name is None:
        raise AssertionError(f"missing expected human review file: {HUMAN_NOTES_FILE}")
    notes = _load_human_notes(artifact_dir / notes_name)
    session = build_human_session(artifact_dir)

    phase_lines: list[str] = []
    for phase_name, status_file, human_action in HUMAN_SESSION_PHASES:
        status_name = _find_one(names, status_file)
        if status_name is None:
            raise AssertionError(f"missing expected human status file: {status_file}")
        digest = _sha256_file(artifact_dir / status_name)
        phase_lines.append(
            f"- {phase_name}: {status_file} sha256={digest} action={human_action}"
        )

    commit = notes.get("commit", "")
    scripted_run_id = notes.get("scripted_proof_run_id", "")
    lines = [
        f"schema={HUMAN_CHECKLIST_SCHEMA}",
        "source=remote-vnc-human-session",
        "generated_by=tools/collect_human_playtest_bundle.py",
        f"session_id={session['session_id']}",
        f"commit={commit}",
        f"scripted_proof_run_id={scripted_run_id}",
        f"playtester={notes.get('playtester', '')}",
        "",
        "Post-download checklist",
        "- Compare the local post-download human verification OK line with the saved remote pre-download human verification OK line.",
        (
            "- Run: python3 tools/check_cloud_playability_artifacts.py "
            "--human-session path/to/vibe-os-human-proof "
            f"--expected-commit {commit} "
            f"--expected-scripted-proof-run-id {scripted_run_id}"
        ),
        (
            "- Run: python3 tools/check_human_playability_proof.py "
            "--require-human-session "
            "--human-notes path/to/vibe-os-human-proof/human-playtest-notes.txt "
            f"--expected-commit {commit} "
            f"--expected-scripted-proof-run-id {scripted_run_id} "
            "path/to/vibe-os-human-proof/status.txt"
        ),
        "- Confirm no WAD, disk image, status binary, pixel, screenshot, or raw-audio file was downloaded.",
        "- Keep the bundle tied to the passing Real WAD smoke run ID before claiming human playability.",
        "",
        "Phase hashes",
        *phase_lines,
        "",
    ]
    return "\n".join(lines)


def validate_human_checklist(artifact_dir: Path, checklist_path: Path) -> None:
    actual = checklist_path.read_text()
    expected = build_human_checklist(artifact_dir)
    if actual != expected:
        raise AssertionError(f"{HUMAN_CHECKLIST_FILE} does not match notes and status files")


def _load_human_session(path: Path) -> dict:
    try:
        session = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise AssertionError(f"{HUMAN_SESSION_FILE} must be valid JSON: {exc}") from exc
    if not isinstance(session, dict):
        raise AssertionError(f"{HUMAN_SESSION_FILE} must be a JSON object")
    return session


def validate_human_session(artifact_dir: Path, session_path: Path) -> None:
    session = _load_human_session(session_path)
    if session.get("schema") != HUMAN_SESSION_SCHEMA:
        raise AssertionError(f"{HUMAN_SESSION_FILE} schema must be {HUMAN_SESSION_SCHEMA}")
    if session.get("source") != "remote-vnc-human-session":
        raise AssertionError(f"{HUMAN_SESSION_FILE} source must be remote-vnc-human-session")
    if session.get("generated_by") != "tools/collect_human_playtest_bundle.py":
        raise AssertionError(f"{HUMAN_SESSION_FILE} generated_by must name the collector")
    _assert_utc_timestamp(session.get("collected_at_utc"), f"{HUMAN_SESSION_FILE} collected_at_utc")

    expected = build_human_session(
        artifact_dir,
        collected_at_utc=session["collected_at_utc"],
    )
    if session != expected:
        raise AssertionError(f"{HUMAN_SESSION_FILE} does not match notes and status file hashes")
    for phase in session.get("phases", []):
        summary = phase.get("summary", {}) if isinstance(phase, dict) else {}
        phase_name = phase.get("phase", "<unknown>") if isinstance(phase, dict) else "<unknown>"
        for field in HUMAN_SESSION_STATUS_FIELDS:
            if summary.get(field) == "<missing>":
                raise AssertionError(
                    f"{HUMAN_SESSION_FILE} phase {phase_name} summary missing {field}"
                )


def build_human_manifest(artifact_dir: Path) -> dict:
    names = [
        name
        for name in _relative_names(artifact_dir)
        if Path(name).name != HUMAN_MANIFEST_FILE
    ]
    notes_name = _find_one(names, HUMAN_NOTES_FILE)
    if notes_name is None:
        raise AssertionError(f"missing expected human review file: {HUMAN_NOTES_FILE}")
    session_name = _find_one(names, HUMAN_SESSION_FILE)
    if session_name is None:
        raise AssertionError(f"missing expected human session file: {HUMAN_SESSION_FILE}")
    checklist_name = _find_one(names, HUMAN_CHECKLIST_FILE)
    if checklist_name is None:
        raise AssertionError(f"missing expected human checklist file: {HUMAN_CHECKLIST_FILE}")
    notes_path = artifact_dir / notes_name
    notes = _load_human_notes(notes_path)
    files = [
        {
            "path": name,
            "bytes": (artifact_dir / name).stat().st_size,
            "sha256": _sha256_file(artifact_dir / name),
        }
        for name in sorted(names)
    ]
    return {
        "schema": HUMAN_MANIFEST_SCHEMA,
        "generated_by": "tools/collect_human_playtest_bundle.py",
        "human_notes_schema": HUMAN_NOTES_SCHEMA,
        "notes_file": HUMAN_NOTES_FILE,
        "commit": notes.get("commit", ""),
        "playtester": notes.get("playtester", ""),
        "artifact_policy": {
            "allowlisted_status_only": True,
            "contains_wad_data": False,
            "contains_disk_image": False,
            "contains_pixels": False,
            "contains_raw_audio": False,
            "requires_remote_qemu": True,
            "permits_local_qemu": False,
            "requires_post_download_verification": True,
        },
        "required_files": sorted(
            REQUIRED_STATUS_FILES
            + REQUIRED_DIAGNOSTIC_FILES
            + REQUIRED_SYMBOL_FILES
            + (HUMAN_NOTES_FILE, HUMAN_CHECKLIST_FILE, HUMAN_SESSION_FILE)
        ),
        "files": files,
    }


def _load_human_manifest(path: Path) -> dict:
    try:
        manifest = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} must be valid JSON: {exc}") from exc
    if not isinstance(manifest, dict):
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} must be a JSON object")
    return manifest


def validate_human_manifest(artifact_dir: Path, manifest_path: Path) -> None:
    manifest = _load_human_manifest(manifest_path)
    if manifest.get("schema") != HUMAN_MANIFEST_SCHEMA:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} schema must be {HUMAN_MANIFEST_SCHEMA}")
    if manifest.get("generated_by") != "tools/collect_human_playtest_bundle.py":
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} generated_by must name the collector")
    if manifest.get("human_notes_schema") != HUMAN_NOTES_SCHEMA:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} human_notes_schema must be {HUMAN_NOTES_SCHEMA}")
    if manifest.get("notes_file") != HUMAN_NOTES_FILE:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} notes_file must be {HUMAN_NOTES_FILE}")

    policy = manifest.get("artifact_policy")
    if not isinstance(policy, dict):
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} artifact_policy must be an object")
    expected_policy = {
        "allowlisted_status_only": True,
        "contains_wad_data": False,
        "contains_disk_image": False,
        "contains_pixels": False,
        "contains_raw_audio": False,
        "requires_remote_qemu": True,
        "permits_local_qemu": False,
        "requires_post_download_verification": True,
    }
    for key, expected in expected_policy.items():
        if policy.get(key) is not expected:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} artifact_policy.{key} must be {expected}")

    required_files = manifest.get("required_files")
    expected_required = sorted(
        REQUIRED_STATUS_FILES
        + REQUIRED_DIAGNOSTIC_FILES
        + REQUIRED_SYMBOL_FILES
        + (HUMAN_NOTES_FILE, HUMAN_CHECKLIST_FILE, HUMAN_SESSION_FILE)
    )
    if required_files != expected_required:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} required_files does not match checker contract")

    entries = manifest.get("files")
    if not isinstance(entries, list) or not entries:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} files must be a non-empty list")
    actual_names = sorted(
        name
        for name in _relative_names(artifact_dir)
        if Path(name).name != HUMAN_MANIFEST_FILE
    )
    seen: dict[str, dict] = {}
    for entry in entries:
        if not isinstance(entry, dict):
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} files entries must be objects")
        name = entry.get("path")
        if not isinstance(name, str) or not name:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} file path must be a non-empty string")
        path = Path(name)
        if path.is_absolute() or ".." in path.parts:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} file path must stay inside bundle: {name}")
        if Path(name).name == HUMAN_MANIFEST_FILE:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} must not hash itself")
        if name in seen:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} duplicates file entry: {name}")
        seen[name] = entry

    if sorted(seen) != actual_names:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} file inventory does not match bundle contents")

    for name, entry in seen.items():
        path = artifact_dir / name
        expected_bytes = entry.get("bytes")
        expected_hash = entry.get("sha256")
        if not isinstance(expected_bytes, int) or expected_bytes < 0:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} bytes must be a non-negative integer for {name}")
        if path.stat().st_size != expected_bytes:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} byte count mismatch for {name}")
        if not isinstance(expected_hash, str) or len(expected_hash) != 64:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} sha256 must be 64 hex chars for {name}")
        try:
            int(expected_hash, 16)
        except ValueError as exc:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} sha256 must be hex for {name}") from exc
        if _sha256_file(path) != expected_hash:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} sha256 mismatch for {name}")

    notes_name = _find_one(actual_names, HUMAN_NOTES_FILE)
    if notes_name is None:
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} missing notes inventory entry")
    notes = _load_human_notes(artifact_dir / notes_name)
    if manifest.get("commit") != notes.get("commit"):
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} commit must match {HUMAN_NOTES_FILE}")
    if manifest.get("playtester") != notes.get("playtester"):
        raise AssertionError(f"{HUMAN_MANIFEST_FILE} playtester must match {HUMAN_NOTES_FILE}")


def build_human_post_download_verification(artifact_dir: Path) -> dict:
    names = _relative_names(artifact_dir)
    manifest_name = _find_one(names, HUMAN_MANIFEST_FILE)
    if manifest_name is None:
        raise AssertionError(f"missing expected human manifest file: {HUMAN_MANIFEST_FILE}")
    session_name = _find_one(names, HUMAN_SESSION_FILE)
    if session_name is None:
        raise AssertionError(f"missing expected human session file: {HUMAN_SESSION_FILE}")

    manifest_path = artifact_dir / manifest_name
    session_path = artifact_dir / session_name
    manifest = _load_human_manifest(manifest_path)
    session = _load_human_session(session_path)
    manifest_entry = {
        "path": HUMAN_MANIFEST_FILE,
        "bytes": manifest_path.stat().st_size,
        "sha256": _sha256_file(manifest_path),
    }
    files = sorted(
        list(manifest.get("files", [])) + [manifest_entry],
        key=lambda entry: entry["path"],
    )
    phase_hashes = {
        phase["phase"]: phase["sha256"]
        for phase in session.get("phases", [])
        if isinstance(phase, dict) and "phase" in phase and "sha256" in phase
    }
    verification = {
        "schema": HUMAN_POST_DOWNLOAD_VERIFICATION_SCHEMA,
        "source": "remote-vnc-human-session-post-download",
        "session_id": session.get("session_id", ""),
        "commit": session.get("commit", ""),
        "playtester": session.get("playtester", ""),
        "scripted_proof_run_id": session.get("scripted_proof_run_id", ""),
        "manifest_sha256": manifest_entry["sha256"],
        "session_sha256": _sha256_file(session_path),
        "files": files,
        "phase_status_hashes": phase_hashes,
    }
    verification["bundle_sha256"] = hashlib.sha256(
        json.dumps(verification, sort_keys=True).encode()
    ).hexdigest()
    return verification


def format_human_post_download_verification(
    verification: dict,
    label: str = "post-download human verification OK",
) -> str:
    phase_hashes = verification.get("phase_status_hashes", {})
    phase_text = " ".join(
        f"{phase}={phase_hashes[phase][:12]}"
        for phase, _, _ in HUMAN_SESSION_PHASES
        if phase in phase_hashes
    )
    return (
        f"{label}: session_id={verification.get('session_id', '')} "
        f"commit={verification.get('commit', '')} "
        f"scripted_proof_run_id={verification.get('scripted_proof_run_id', '')} "
        f"bundle_sha256={verification.get('bundle_sha256', '')} "
        f"manifest_sha256={verification.get('manifest_sha256', '')} "
        f"files={len(verification.get('files', []))}\n"
        f"phase status hashes: {phase_text}"
    )


def _forbidden_content_reason(path: Path, data: bytes) -> str | None:
    basename = path.name
    if basename in REQUIRED_DIAGNOSTIC_FILES:
        if not data.startswith(b"\x7fELF"):
            return f"expected ELF diagnostic {basename} does not start with ELF magic"
        return None

    if data.startswith(b"\x7fELF"):
        return f"unexpected ELF binary artifact outside required diagnostics: {path}"

    for signature, label in CONTENT_SIGNATURES:
        if data.startswith(signature):
            return label
    if data.startswith(b"\x1f\x8b"):
        try:
            inflated = gzip.decompress(data)
        except OSError:
            inflated = b""
        if inflated.startswith((b"IWAD", b"PWAD")):
            return "gzip-compressed WAD payload"
        for signature, label in CONTENT_SIGNATURES:
            if inflated.startswith(signature):
                return f"gzip-compressed {label}"
        if len(inflated) >= 0x8006 and inflated[0x8001:0x8006] == b"CD001":
            return "gzip-compressed ISO image"
        if len(inflated) >= 512 and inflated[510:512] == b"\x55\xaa" and b"FAT" in inflated[:512]:
            return "gzip-compressed raw FAT disk image"
    if data.startswith(b"PK\x03\x04"):
        try:
            with zipfile.ZipFile(io.BytesIO(data)) as archive:
                for info in archive.infolist():
                    inner_name = Path(info.filename).name.lower()
                    if inner_name.endswith(FORBIDDEN_ARCHIVE_SUFFIXES):
                        return f"zip archive containing forbidden payload: {info.filename}"
                    if info.file_size > 0:
                        with archive.open(info) as member:
                            prefix = member.read(16)
                        for signature, label in CONTENT_SIGNATURES:
                            if prefix.startswith(signature):
                                return f"zip archive containing {label}: {info.filename}"
        except zipfile.BadZipFile:
            pass
    if len(data) >= 0x8006 and data[0x8001:0x8006] == b"CD001":
        return "ISO image"
    if len(data) >= 512 and data[510:512] == b"\x55\xaa" and b"FAT" in data[:512]:
        return "raw FAT disk image"
    return None


def _assert_no_forbidden_contents(artifact_dir: Path, names: list[str]) -> None:
    for name in names:
        path = artifact_dir / name
        data = path.read_bytes()
        reason = _forbidden_content_reason(path, data)
        if reason is not None:
            raise AssertionError(f"forbidden artifact content in {name}: {reason}")


def _load_human_notes(path: Path) -> dict[str, str]:
    notes: dict[str, str] = {}
    for line_number, line in enumerate(path.read_text().splitlines(), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if "=" not in stripped:
            raise AssertionError(f"{HUMAN_NOTES_FILE}:{line_number} must be key=value")
        key, value = stripped.split("=", 1)
        key = key.strip()
        value = value.strip()
        if not key or not value:
            raise AssertionError(f"{HUMAN_NOTES_FILE}:{line_number} must have non-empty key and value")
        if key in notes:
            raise AssertionError(f"{HUMAN_NOTES_FILE} duplicates {key}=")
        notes[key] = value
    return notes


def _commit_matches(actual: str, expected: str) -> bool:
    return actual == expected or actual.startswith(expected) or expected.startswith(actual)


def validate_human_notes(
    path: Path,
    artifact_dir: Path | None = None,
    expected_commit: str | None = None,
    expected_scripted_proof_run_id: str | None = None,
) -> None:
    notes = _load_human_notes(path)
    for key in REQUIRED_FREEFORM_HUMAN_NOTE_FIELDS:
        if key not in notes:
            raise AssertionError(f"{HUMAN_NOTES_FILE} missing {key}=")
        pattern = HUMAN_NOTE_FIELD_PATTERNS[key]
        if not re.fullmatch(pattern, notes[key]):
            raise AssertionError(f"{HUMAN_NOTES_FILE} {key}= has invalid format")
    for key, allowed_values in REQUIRED_HUMAN_NOTE_FIELDS.items():
        value = notes.get(key)
        if value is None:
            raise AssertionError(f"{HUMAN_NOTES_FILE} missing {key}=")
        if value not in allowed_values:
            allowed = ", ".join(allowed_values)
            raise AssertionError(f"{HUMAN_NOTES_FILE} {key}= must be {allowed}, got {value!r}")
    for key, allowed_values in OPTIONAL_HUMAN_NOTE_FIELDS.items():
        value = notes.get(key)
        if value is not None and value not in allowed_values:
            allowed = ", ".join(allowed_values)
            raise AssertionError(f"{HUMAN_NOTES_FILE} {key}= must be one of {allowed}, got {value!r}")
    if expected_commit and not _commit_matches(notes["commit"], expected_commit):
        raise AssertionError(
            f"{HUMAN_NOTES_FILE} commit= must match expected commit "
            f"{expected_commit}, got {notes['commit']}"
        )
    if (
        expected_scripted_proof_run_id
        and notes["scripted_proof_run_id"] != expected_scripted_proof_run_id
    ):
        raise AssertionError(
            f"{HUMAN_NOTES_FILE} scripted_proof_run_id= must match "
            f"{expected_scripted_proof_run_id}, got {notes['scripted_proof_run_id']}"
        )
    if artifact_dir is not None:
        names = _relative_names(artifact_dir)
        for phase, status_file, _human_action in HUMAN_SESSION_PHASES:
            note_key = HUMAN_PHASE_HASH_NOTE_KEYS[phase]
            status_name = _find_one(names, status_file)
            if status_name is None:
                continue
            actual_hash = _sha256_file(artifact_dir / status_name)
            if notes.get(note_key) != actual_hash:
                raise AssertionError(
                    f"{HUMAN_NOTES_FILE} {note_key}= must match sha256({status_file})"
                )


def validate_manual_human_playability(
    artifact_dir: Path,
    names: list[str],
    expected_commit: str | None = None,
    expected_scripted_proof_run_id: str | None = None,
) -> None:
    snapshots: dict[str, str] = {}
    phase_paths: dict[str, Path] = {}
    for phase, status_file, _human_action in HUMAN_SESSION_PHASES:
        status_name = _find_one(names, status_file)
        if status_name is None:
            raise AssertionError(f"missing expected human status file: {status_file}")
        status_path = artifact_dir / status_name
        phase_paths[phase] = status_path
        snapshots[phase] = status_path.read_text()

    check_human_playability_proof.validate_human_session_status(snapshots)

    notes_name = _find_one(names, HUMAN_NOTES_FILE)
    if notes_name is None:
        raise AssertionError(f"missing expected human review file: {HUMAN_NOTES_FILE}")
    notes_path = artifact_dir / notes_name
    check_human_playability_proof.validate_human_notes(
        notes_path,
        {
            "early": phase_paths["early"],
            "after-start": phase_paths["after-start"],
            "after-fire": phase_paths["after-fire"],
            "after-move": phase_paths["after-move"],
            "after-use": phase_paths["after-use"],
            "after-mouse": phase_paths["after-mouse"],
            "after-menu": phase_paths["after-menu"],
            "final": phase_paths["final"],
        },
        expected_commit=expected_commit,
        expected_scripted_proof_run_id=expected_scripted_proof_run_id,
    )


def _assert_human_session_allowlist(names: list[str]) -> None:
    for name in names:
        basename = Path(name).name
        if name != basename:
            raise AssertionError(f"human session bundles must be flat; nested path found: {name}")
        if basename in HUMAN_SESSION_ALLOWED_EXACT_FILES:
            continue
        if any(fnmatch.fnmatchcase(basename, pattern) for pattern in HUMAN_SESSION_ALLOWED_PATTERNS):
            continue
        raise AssertionError(f"unexpected human session artifact: {name}")


def _load_json_object(path: Path, label: str) -> dict:
    try:
        parsed = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise AssertionError(f"{label} must be valid JSON: {exc}") from exc
    if not isinstance(parsed, dict):
        raise AssertionError(f"{label} must be a JSON object")
    return parsed


def _assert_soak_metadata_dir_json_only(path: Path) -> None:
    names = _relative_names(path)
    if not names:
        raise AssertionError("real-WAD soak metadata directory is empty")
    for name in names:
        basename = Path(name).name
        if name != basename:
            raise AssertionError(f"real-WAD soak metadata must be flat JSON; nested path found: {name}")
        if not basename.endswith(".json"):
            raise AssertionError(f"real-WAD soak metadata must contain only JSON files: {name}")
    _assert_no_forbidden_contents(path, names)


def _assert_soak_policy(policy: object, label: str) -> None:
    if not isinstance(policy, dict):
        raise AssertionError(f"{label} artifact_policy must be an object")
    for key, expected in SOAK_ARTIFACT_POLICY.items():
        if policy.get(key) is not expected:
            raise AssertionError(f"{label} artifact_policy.{key} must be {expected}")


def _assert_soak_pass_criteria(criteria: object, audible_required: bool) -> None:
    if not isinstance(criteria, dict):
        raise AssertionError("real-WAD soak pass_criteria must be an object")
    for group, required_fields in SOAK_PASS_CRITERIA.items():
        values = criteria.get(group)
        if not isinstance(values, dict):
            raise AssertionError(f"real-WAD soak pass_criteria.{group} must be an object")
        for key, expected in required_fields.items():
            if values.get(key) is not expected:
                raise AssertionError(
                    f"real-WAD soak pass_criteria.{group}.{key} must be {expected}"
                )
    audible = criteria["audible_aggregate_proof"]
    if audible.get("required") is not audible_required:
        raise AssertionError(
            "real-WAD soak pass_criteria.audible_aggregate_proof.required "
            f"must be {audible_required}"
        )


def _status_summary_from_path(path: Path) -> dict[str, str]:
    fields = _status_fields(path.read_text())
    return {name: fields.get(name, "<missing>") for name in SOAK_STATUS_SUMMARY_FIELDS}


def _soak_audio_proof_summary(path: Path) -> dict:
    manifest = check_audible_audio_proof._load_manifest(path)
    check_audible_audio_proof.validate_manifest(manifest)
    listener = manifest.get("listener_quality", {})
    analysis = manifest.get("analysis", {})
    policy = manifest.get("artifact_policy", {})
    continuity = manifest.get("continuity", {})
    return {
        "schema": manifest.get("schema", ""),
        "source": manifest.get("source", ""),
        "machine_audible": bool(listener.get("machine_audible")),
        "active_windows": analysis.get("active_windows"),
        "active_window_ratio": analysis.get("active_window_ratio"),
        "peak_abs_norm": analysis.get("peak_abs_norm"),
        "upload_only_aggregate_json": policy.get("upload_only_aggregate_json") is True,
        "contains_raw_audio": policy.get("contains_raw_audio") is True,
        "sb16_continuity": continuity.get("sb16_continuity") is True,
        "non_music_sfx_progress": continuity.get("non_music_sfx_progress") is True,
        "music_stream_progress": continuity.get("music_stream_progress") is True,
    }


def _soak_run_identity() -> dict[str, str]:
    return {
        "workflow": "real-wad-soak.yml",
        "run_id": os.environ.get("GITHUB_RUN_ID", ""),
        "run_attempt": os.environ.get("GITHUB_RUN_ATTEMPT", ""),
        "commit": os.environ.get("GITHUB_SHA", ""),
    }


def build_soak_attempt_metadata(
    artifact_dir: Path,
    attempt_index: int,
    audible_required: bool = False,
    gameplay_required: bool = False,
) -> dict:
    if attempt_index < 1:
        raise AssertionError("soak attempt index must be positive")
    validate_artifact_dir(
        artifact_dir,
        require_gameplay_proof=gameplay_required,
        require_audible_proof=audible_required,
    )
    names = _relative_names(artifact_dir)

    phase_hashes: dict[str, str] = {}
    phase_summaries: dict[str, dict[str, str]] = {}
    for phase, status_file in SOAK_PHASE_FILES:
        status_name = _find_one(names, status_file)
        if status_name is None:
            raise AssertionError(f"missing expected soak status file: {status_file}")
        status_path = artifact_dir / status_name
        phase_hashes[phase] = _sha256_file(status_path)
        phase_summaries[phase] = _status_summary_from_path(status_path)

    audio_proof_name = _find_one(names, OPTIONAL_AUDIO_PROOF_FILE)
    if audible_required and audio_proof_name is None:
        raise AssertionError(f"audible soak attempt requires {OPTIONAL_AUDIO_PROOF_FILE}")
    audio_summary = (
        _soak_audio_proof_summary(artifact_dir / audio_proof_name)
        if audio_proof_name is not None
        else None
    )

    gates = {
        "real_wad_proof": "pass",
        "scripted_human_playability": "pass",
        "scripted_gameplay_transition": "pass",
        "playability": "pass",
        "input_state_changes": "pass",
        "sb16_continuity": "pass",
        "audible_aggregate_proof": "pass" if audible_required else "not-requested",
    }
    return {
        "schema": SOAK_ATTEMPT_SCHEMA,
        "source": "real-wad-cloud-proof-attempt",
        "attempt_index": attempt_index,
        "conclusion": "success",
        "run": _soak_run_identity(),
        "artifact_policy": dict(SOAK_ARTIFACT_POLICY),
        "status_source": "required-status-snapshot-summaries",
        "phase_hashes": phase_hashes,
        "phase_summaries": phase_summaries,
        "gates": gates,
        "audio_proof": audio_summary,
    }


def _validate_soak_attempt(attempt: object, audible_required: bool) -> bool:
    if not isinstance(attempt, dict):
        raise AssertionError("real-WAD soak attempt must be an object")
    if attempt.get("schema") != SOAK_ATTEMPT_SCHEMA:
        raise AssertionError(f"real-WAD soak attempt schema must be {SOAK_ATTEMPT_SCHEMA}")
    index = attempt.get("attempt_index")
    if not isinstance(index, int) or index < 1:
        raise AssertionError("real-WAD soak attempt_index must be a positive integer")
    _assert_soak_policy(attempt.get("artifact_policy"), f"real-WAD soak attempt {index}")

    conclusion = attempt.get("conclusion")
    if conclusion == "failure":
        if not attempt.get("failure_stage"):
            raise AssertionError(f"real-WAD soak attempt {index} failure_stage is required")
        return False
    if conclusion != "success":
        raise AssertionError(f"real-WAD soak attempt {index} conclusion must be success or failure")

    gates = attempt.get("gates")
    if not isinstance(gates, dict):
        raise AssertionError(f"real-WAD soak attempt {index} gates must be an object")
    for gate in SOAK_SUCCESS_GATES:
        if gates.get(gate) != "pass":
            raise AssertionError(f"real-WAD soak attempt {index} gate {gate} must be pass")
    expected_audible_gate = "pass" if audible_required else "not-requested"
    if gates.get("audible_aggregate_proof") != expected_audible_gate:
        raise AssertionError(
            f"real-WAD soak attempt {index} audible_aggregate_proof gate must be "
            f"{expected_audible_gate}"
        )

    phase_hashes = attempt.get("phase_hashes")
    summaries = attempt.get("phase_summaries")
    if not isinstance(phase_hashes, dict) or not isinstance(summaries, dict):
        raise AssertionError(f"real-WAD soak attempt {index} must include phase hashes and summaries")
    for phase, _status_file in SOAK_PHASE_FILES:
        digest = phase_hashes.get(phase)
        if not isinstance(digest, str) or not re.fullmatch(r"[0-9A-Fa-f]{64}", digest):
            raise AssertionError(f"real-WAD soak attempt {index} phase {phase} needs a sha256")
        summary = summaries.get(phase)
        if not isinstance(summary, dict):
            raise AssertionError(f"real-WAD soak attempt {index} phase {phase} summary is required")
        for field in SOAK_STATUS_SUMMARY_FIELDS:
            if field not in summary or summary[field] == "<missing>":
                raise AssertionError(
                    f"real-WAD soak attempt {index} phase {phase} summary missing {field}"
                )
    final = summaries["final"]
    for field, expected in (
        ("doomrun", "RUN"),
        ("gameplay", "OK"),
        ("gstate", "00000000"),
        ("gmap", "00000101"),
        ("audio", "SB16"),
        ("panic", "NONE"),
        ("shutdown", "NONE"),
    ):
        if final.get(field) != expected:
            raise AssertionError(
                f"real-WAD soak attempt {index} final {field}= must be {expected}"
            )

    audio_proof = attempt.get("audio_proof")
    if audible_required:
        if not isinstance(audio_proof, dict):
            raise AssertionError(f"real-WAD soak attempt {index} needs audio_proof metadata")
        for key in (
            "machine_audible",
            "upload_only_aggregate_json",
            "sb16_continuity",
            "non_music_sfx_progress",
            "music_stream_progress",
        ):
            if audio_proof.get(key) is not True:
                raise AssertionError(f"real-WAD soak attempt {index} audio_proof.{key} must be true")
        if audio_proof.get("contains_raw_audio") is not False:
            raise AssertionError(
                f"real-WAD soak attempt {index} audio_proof.contains_raw_audio must be false"
            )
    elif audio_proof is not None:
        raise AssertionError(
            f"real-WAD soak attempt {index} must not include audio_proof unless audible proof is required"
        )
    return True


def build_soak_summary(
    attempt_dir: Path,
    requested_attempts: int,
    required_successes: int,
    audible_required: bool = False,
) -> dict:
    if requested_attempts < 1:
        raise AssertionError("soak requested attempts must be positive")
    if required_successes < 1 or required_successes > requested_attempts:
        raise AssertionError("soak required successes must be between 1 and requested attempts")
    attempt_paths = sorted(
        path for path in attempt_dir.glob("attempt-*.json") if path.name != SOAK_SUMMARY_FILE
    )
    attempts = [
        _load_json_object(path, f"real-WAD soak attempt {path.name}")
        for path in attempt_paths
    ]
    pass_count = sum(1 for attempt in attempts if attempt.get("conclusion") == "success")
    criteria = json.loads(json.dumps(SOAK_PASS_CRITERIA))
    criteria["audible_aggregate_proof"]["required"] = audible_required
    return {
        "schema": SOAK_SUMMARY_SCHEMA,
        "generated_by": ".github/workflows/real-wad-soak.yml",
        "source": "repeated-real-wad-cloud-proof",
        "run": _soak_run_identity(),
        "requested_attempts": requested_attempts,
        "required_successes": required_successes,
        "pass_count": pass_count,
        "flake_count": requested_attempts - pass_count,
        "audible_audio_proof": audible_required,
        "artifact_policy": dict(SOAK_ARTIFACT_POLICY),
        "pass_criteria": criteria,
        "attempts": attempts,
    }


def validate_soak_summary(summary: dict) -> None:
    if summary.get("schema") != SOAK_SUMMARY_SCHEMA:
        raise AssertionError(f"real-WAD soak summary schema must be {SOAK_SUMMARY_SCHEMA}")
    if summary.get("generated_by") != ".github/workflows/real-wad-soak.yml":
        raise AssertionError("real-WAD soak summary generated_by must name the soak workflow")
    _assert_soak_policy(summary.get("artifact_policy"), "real-WAD soak summary")

    audible_required = summary.get("audible_audio_proof")
    if not isinstance(audible_required, bool):
        raise AssertionError("real-WAD soak summary audible_audio_proof must be a boolean")
    _assert_soak_pass_criteria(summary.get("pass_criteria"), audible_required)

    requested_attempts = summary.get("requested_attempts")
    required_successes = summary.get("required_successes")
    pass_count = summary.get("pass_count")
    flake_count = summary.get("flake_count")
    attempts = summary.get("attempts")
    if not isinstance(requested_attempts, int) or requested_attempts < 1:
        raise AssertionError("real-WAD soak summary requested_attempts must be positive")
    if not isinstance(required_successes, int) or not (1 <= required_successes <= requested_attempts):
        raise AssertionError("real-WAD soak summary required_successes is out of range")
    if not isinstance(attempts, list):
        raise AssertionError("real-WAD soak summary attempts must be a list")
    if len(attempts) != requested_attempts:
        raise AssertionError(
            f"real-WAD soak summary expected {requested_attempts} attempts, got {len(attempts)}"
        )
    seen_indices: set[int] = set()
    computed_pass_count = 0
    for attempt in attempts:
        if _validate_soak_attempt(attempt, audible_required):
            computed_pass_count += 1
        index = attempt["attempt_index"]
        if index in seen_indices:
            raise AssertionError(f"real-WAD soak summary duplicates attempt_index {index}")
        seen_indices.add(index)
    if seen_indices != set(range(1, requested_attempts + 1)):
        raise AssertionError("real-WAD soak summary attempt indexes must be contiguous from 1")
    if pass_count != computed_pass_count:
        raise AssertionError("real-WAD soak summary pass_count does not match attempts")
    if flake_count != requested_attempts - computed_pass_count:
        raise AssertionError("real-WAD soak summary flake_count does not match attempts")
    if computed_pass_count < required_successes:
        raise AssertionError(
            f"real-WAD soak failed repeated pass threshold: "
            f"{computed_pass_count}/{requested_attempts} passed, required {required_successes}"
        )


def validate_soak_summary_path(path: Path) -> None:
    if path.is_dir():
        _assert_soak_metadata_dir_json_only(path)
        summary_path = path / SOAK_SUMMARY_FILE
        if not summary_path.exists():
            raise AssertionError(f"missing expected soak summary file: {SOAK_SUMMARY_FILE}")
        names = sorted(_relative_names(path))
        for name in names:
            if name == SOAK_SUMMARY_FILE:
                continue
            if not re.fullmatch(r"attempt-[0-9]+\.json", name):
                raise AssertionError(f"unexpected real-WAD soak metadata JSON file: {name}")
        summary = _load_json_object(summary_path, SOAK_SUMMARY_FILE)
        validate_soak_summary(summary)
        attempts_by_file = {
            f"attempt-{attempt['attempt_index']:03d}.json": attempt
            for attempt in summary["attempts"]
        }
        expected_names = sorted([SOAK_SUMMARY_FILE, *attempts_by_file])
        if names != expected_names:
            raise AssertionError("real-WAD soak metadata file inventory does not match summary")
        for name in names:
            if name == SOAK_SUMMARY_FILE:
                continue
            attempt = _load_json_object(path / name, f"real-WAD soak attempt {name}")
            expected = attempts_by_file.get(name)
            if expected is None or attempt != expected:
                raise AssertionError(f"real-WAD soak attempt file does not match summary: {name}")
    else:
        summary_path = path
        validate_soak_summary(_load_json_object(summary_path, SOAK_SUMMARY_FILE))


def validate_artifact_dir(
    artifact_dir: Path,
    require_human_notes: bool = False,
    expected_commit: str | None = None,
    expected_scripted_proof_run_id: str | None = None,
    require_gameplay_proof: bool = False,
    require_audible_proof: bool = False,
) -> None:
    if not artifact_dir.exists():
        raise AssertionError(f"artifact directory does not exist: {artifact_dir}")
    names = _relative_names(artifact_dir)
    for name in names:
        basename = Path(name).name
        for pattern in FORBIDDEN_ARTIFACT_PATTERNS:
            if fnmatch.fnmatchcase(basename, pattern):
                raise AssertionError(f"forbidden WAD/image/pixel/audio artifact present: {name}")
    _assert_no_forbidden_contents(artifact_dir, names)
    if require_human_notes:
        _assert_human_session_allowlist(names)

    missing = [
        required
        for required in REQUIRED_STATUS_FILES + REQUIRED_DIAGNOSTIC_FILES + REQUIRED_SYMBOL_FILES
        if _find_one(names, required) is None
    ]
    if missing:
        raise AssertionError(f"missing expected diagnostic files: {', '.join(missing)}")

    status_path = artifact_dir / _find_one(names, "status.txt")
    status = status_path.read_text()
    scripted_snapshots = {
        "start": (artifact_dir / _find_one(names, "status.after-start.txt")).read_text(),
        "fire": (artifact_dir / _find_one(names, "status.after-fire.txt")).read_text(),
        "movement": (artifact_dir / _find_one(names, "status.after-move.txt")).read_text(),
        "use": (artifact_dir / _find_one(names, "status.after-use.txt")).read_text(),
        "mouse": (artifact_dir / _find_one(names, "status.after-mouse.txt")).read_text(),
        "menu": (artifact_dir / _find_one(names, "status.after-menu.txt")).read_text(),
        "final": status,
    }
    scripted_paths = {
        "start": artifact_dir / _find_one(names, "status.after-start.txt"),
        "fire": artifact_dir / _find_one(names, "status.after-fire.txt"),
        "movement": artifact_dir / _find_one(names, "status.after-move.txt"),
        "use": artifact_dir / _find_one(names, "status.after-use.txt"),
        "mouse": artifact_dir / _find_one(names, "status.after-mouse.txt"),
        "menu": artifact_dir / _find_one(names, "status.after-menu.txt"),
        "final": status_path,
    }
    try:
        check_real_wad_proof.validate_status(
            status,
            baseline_status=scripted_snapshots["start"],
            start_status=scripted_snapshots["start"],
            fire_status=scripted_snapshots["fire"],
            movement_status=scripted_snapshots["movement"],
            use_status=scripted_snapshots["use"],
            mouse_status=scripted_snapshots["mouse"],
            menu_status=scripted_snapshots["menu"],
        )
    except AssertionError as exc:
        raise AssertionError(
            f"{exc}; final status summary: {check_real_wad_proof.summarize_status(status)}"
        ) from exc
    try:
        check_vm_status_proof.validate_status(
            status,
            require_exec=True,
            require_preempt=True,
        )
    except AssertionError as exc:
        raise AssertionError(f"VM status proof failed: {exc}") from exc
    gameplay_proof = _find_one(names, OPTIONAL_GAMEPLAY_PROOF_FILE)
    if require_gameplay_proof or gameplay_proof is not None:
        try:
            check_scripted_gameplay_proof.validate_statuses(scripted_snapshots)
        except AssertionError as exc:
            raise AssertionError(f"scripted gameplay transition proof failed: {exc}") from exc
    if require_gameplay_proof and gameplay_proof is None:
        raise AssertionError(f"gameplay proof manifest requires {OPTIONAL_GAMEPLAY_PROOF_FILE}")
    if gameplay_proof is not None:
        try:
            check_scripted_gameplay_proof.validate_manifest(
                _load_json_object(artifact_dir / gameplay_proof, OPTIONAL_GAMEPLAY_PROOF_FILE),
                snapshots=scripted_snapshots,
                paths=scripted_paths,
            )
        except AssertionError as exc:
            raise AssertionError(f"scripted gameplay proof manifest failed: {exc}") from exc
    try:
        check_audio_continuity_proof.validate_status(
            status,
            baseline_status=scripted_snapshots["start"],
            fire_status=scripted_snapshots["fire"],
            movement_status=scripted_snapshots["movement"],
            use_status=scripted_snapshots["use"],
            menu_status=scripted_snapshots["menu"],
        )
    except AssertionError as exc:
        raise AssertionError(
            f"{exc}; final audio summary: {check_audio_continuity_proof.summarize_status(status)}"
        ) from exc

    audio_proof = _find_one(names, OPTIONAL_AUDIO_PROOF_FILE)
    if require_audible_proof and audio_proof is None:
        raise AssertionError(f"audible audio proof manifest requires {OPTIONAL_AUDIO_PROOF_FILE}")
    if audio_proof is not None:
        try:
            check_audible_audio_proof.validate_manifest(
                check_audible_audio_proof._load_manifest(artifact_dir / audio_proof)
            )
        except AssertionError as exc:
            raise AssertionError(f"audible audio proof manifest failed: {exc}") from exc

    human_notes = _find_one(names, HUMAN_NOTES_FILE)
    if require_human_notes and human_notes is None:
        raise AssertionError(f"missing expected human review file: {HUMAN_NOTES_FILE}")
    if human_notes is not None:
        try:
            validate_human_notes(
                artifact_dir / human_notes,
                artifact_dir=artifact_dir,
                expected_commit=expected_commit,
                expected_scripted_proof_run_id=expected_scripted_proof_run_id,
            )
        except AssertionError as exc:
            raise AssertionError(f"human playtest notes failed: {exc}") from exc

    if require_human_notes:
        try:
            validate_manual_human_playability(
                artifact_dir,
                names,
                expected_commit=expected_commit,
                expected_scripted_proof_run_id=expected_scripted_proof_run_id,
            )
        except AssertionError as exc:
            raise AssertionError(f"manual human playability failed: {exc}") from exc

    human_session = _find_one(names, HUMAN_SESSION_FILE)
    if require_human_notes and human_session is None:
        raise AssertionError(f"missing expected human session file: {HUMAN_SESSION_FILE}")
    if human_session is not None:
        try:
            validate_human_session(artifact_dir, artifact_dir / human_session)
        except AssertionError as exc:
            raise AssertionError(f"human playtest session failed: {exc}") from exc

    human_checklist = _find_one(names, HUMAN_CHECKLIST_FILE)
    if require_human_notes and human_checklist is None:
        raise AssertionError(f"missing expected human checklist file: {HUMAN_CHECKLIST_FILE}")
    if human_checklist is not None:
        try:
            validate_human_checklist(artifact_dir, artifact_dir / human_checklist)
        except AssertionError as exc:
            raise AssertionError(f"human playtest checklist failed: {exc}") from exc

    human_manifest = _find_one(names, HUMAN_MANIFEST_FILE)
    if require_human_notes and human_manifest is None:
        raise AssertionError(f"missing expected human manifest file: {HUMAN_MANIFEST_FILE}")
    if human_manifest is not None:
        try:
            validate_human_manifest(artifact_dir, artifact_dir / human_manifest)
        except AssertionError as exc:
            raise AssertionError(f"human playtest manifest failed: {exc}") from exc


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "artifact_dir",
        nargs="?",
        type=Path,
        help="downloaded real-wad-smoke-status artifact directory",
    )
    parser.add_argument(
        "--repo-contract",
        action="store_true",
        help="validate docs/workflow/Makefile runbook wiring",
    )
    parser.add_argument(
        "--human-session",
        action="store_true",
        help=f"require and validate {HUMAN_NOTES_FILE} for a manual remote playtest",
    )
    parser.add_argument(
        "--expected-commit",
        help=(
            "when used with --human-session, require human-playtest-notes.txt "
            "to match this commit hash or prefix"
        ),
    )
    parser.add_argument(
        "--expected-scripted-proof-run-id",
        help=(
            "when used with --human-session, require human-playtest-notes.txt "
            "to match this passing Real WAD smoke run ID"
        ),
    )
    parser.add_argument(
        "--soak-summary",
        type=Path,
        help="validate a real-wad-soak metadata directory or real-wad-soak-summary.json",
    )
    parser.add_argument(
        "--write-soak-attempt",
        type=Path,
        help="write status-summary JSON for one already-validated real-WAD proof attempt",
    )
    parser.add_argument(
        "--soak-attempt-index",
        type=int,
        default=1,
        help="positive attempt number used with --write-soak-attempt",
    )
    parser.add_argument(
        "--require-audible-proof",
        action="store_true",
        help="require aggregate audio-proof.json metadata for soak attempt/summary validation",
    )
    parser.add_argument(
        "--require-gameplay-proof",
        action="store_true",
        help="require gameplay-proof.json and the stricter scripted gameplay transition gate",
    )
    parser.add_argument(
        "--write-soak-summary",
        type=Path,
        help="write and validate real-wad-soak-summary.json from attempt-*.json files",
    )
    parser.add_argument(
        "--soak-attempt-dir",
        type=Path,
        help="directory containing attempt-*.json files for --write-soak-summary",
    )
    parser.add_argument(
        "--soak-attempts",
        type=int,
        help="requested attempt count for --write-soak-summary",
    )
    parser.add_argument(
        "--soak-required-passes",
        type=int,
        help="required successful attempts for --write-soak-summary",
    )
    args = parser.parse_args(argv)

    try:
        verification = None
        if (args.expected_commit or args.expected_scripted_proof_run_id) and not args.human_session:
            raise AssertionError(
                "--expected-commit and --expected-scripted-proof-run-id require --human-session"
            )
        if args.soak_summary is not None:
            validate_soak_summary_path(args.soak_summary)
        if args.write_soak_attempt is not None:
            if args.artifact_dir is None:
                raise AssertionError("--write-soak-attempt requires artifact_dir")
            attempt = build_soak_attempt_metadata(
                args.artifact_dir,
                args.soak_attempt_index,
                audible_required=args.require_audible_proof,
                gameplay_required=args.require_gameplay_proof,
            )
            args.write_soak_attempt.parent.mkdir(parents=True, exist_ok=True)
            args.write_soak_attempt.write_text(json.dumps(attempt, indent=2, sort_keys=True) + "\n")
        if args.write_soak_summary is not None:
            if args.soak_attempt_dir is None:
                raise AssertionError("--write-soak-summary requires --soak-attempt-dir")
            if args.soak_attempts is None:
                raise AssertionError("--write-soak-summary requires --soak-attempts")
            if args.soak_required_passes is None:
                raise AssertionError("--write-soak-summary requires --soak-required-passes")
            summary = build_soak_summary(
                args.soak_attempt_dir,
                args.soak_attempts,
                args.soak_required_passes,
                audible_required=args.require_audible_proof,
            )
            args.write_soak_summary.parent.mkdir(parents=True, exist_ok=True)
            args.write_soak_summary.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
            validate_soak_summary(summary)
        default_repo_contract = (
            args.artifact_dir is None
            and args.soak_summary is None
            and args.write_soak_attempt is None
            and args.write_soak_summary is None
        )
        if args.repo_contract or default_repo_contract:
            validate_repo_contract()
        if args.artifact_dir is not None:
            validate_artifact_dir(
                args.artifact_dir,
                require_human_notes=args.human_session,
                expected_commit=args.expected_commit if args.human_session else None,
                expected_scripted_proof_run_id=(
                    args.expected_scripted_proof_run_id if args.human_session else None
                ),
                require_gameplay_proof=args.require_gameplay_proof,
                require_audible_proof=args.require_audible_proof,
            )
            if args.human_session:
                verification = build_human_post_download_verification(args.artifact_dir)
    except (OSError, AssertionError) as exc:
        print(f"cloud playability artifact check failed: {exc}", file=sys.stderr)
        return 1

    print("cloud playability artifact check OK")
    if verification is not None:
        print(format_human_post_download_verification(verification))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
