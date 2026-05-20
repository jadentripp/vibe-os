#!/usr/bin/env python3
"""Validate the cloud human-playability runbook and downloaded diagnostics."""

from __future__ import annotations

import argparse
import fnmatch
import gzip
import hashlib
import io
import json
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


RUNBOOK = ROOT / "docs" / "runbooks" / "remote-doom-playtest.md"
PLAYABLE_DOC = ROOT / "docs" / "playable-cloud-proof.md"
WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
README = ROOT / "README.md"
TESTS_README = ROOT / "tests" / "README.md"
MAKEFILE = ROOT / "Makefile"

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
HUMAN_NOTES_FILE = "human-playtest-notes.txt"
HUMAN_NOTES_SCHEMA = "human-playtest-notes-v1"
HUMAN_MANIFEST_FILE = "human-playtest-manifest.json"
HUMAN_MANIFEST_SCHEMA = "human-playtest-manifest-v1"
HUMAN_SESSION_FILE = "human-playtest-session.json"
HUMAN_SESSION_SCHEMA = "human-playtest-session-v1"
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
}
REQUIRED_FREEFORM_HUMAN_NOTE_FIELDS = (
    "commit",
    "playtester",
    "scripted_proof_run_id",
)
OPTIONAL_HUMAN_NOTE_FIELDS = {
    "audio": ("status-only", "listener-pass", "audio-proof-json-pass", "not-tested"),
}
HUMAN_NOTE_FIELD_PATTERNS = {
    "commit": r"(?:[0-9A-Fa-f]{7,40}|unknown)",
    "playtester": r"[A-Za-z0-9._-]{2,64}",
    "scripted_proof_run_id": r"[0-9]{6,32}",
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
    "doomsound",
    "sfxmix",
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

FORBIDDEN_ARCHIVE_SUFFIXES = (
    ".wad",
    ".iwad",
    ".pwad",
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


def validate_repo_contract() -> None:
    runbook = _read(RUNBOOK)
    playable = _read(PLAYABLE_DOC)
    workflow = _read(WORKFLOW)
    readme = _read(README)
    tests_readme = _read(TESTS_README)
    makefile = _read(MAKEFILE)

    for needle in (
        "qemu-system-x86_64",
        "-display vnc=127.0.0.1:1",
        "ssh -L 5901:127.0.0.1:5901",
        "tools/prepare_shareware_wad.py",
        "tools/check_cloud_playability_artifacts.py",
        "tools/collect_human_playtest_bundle.py",
        "tools/check_real_wad_proof.py",
        "tools/check_human_playability_proof.py",
        "tools/check_audio_continuity_proof.py",
        "tools/check_audible_audio_proof.py",
        "tools/triage_cloud_status.py",
        "human-playtest-notes.txt",
        "human-playtest-session.json",
        "human-playtest-manifest.json",
        "scripted_proof=real-wad-smoke-pass",
        "scripted_proof_run_id=",
        "--scripted-proof-run-id",
        "proof_bundle=allowlisted-status-only",
        "qemu_display=127.0.0.1:1",
        "vnc_endpoint=127.0.0.1:5901",
        "visual_evidence=e1m1-visible-via-remote-vnc",
        "keyboard_evidence=fire-move-use-menu-visible",
        "mouse_evidence=motion-click-visible",
        "status_capture=monitor-pmemsave-0x9d000",
        "session_phases=early,after-start,after-fire,after-move,after-use,after-mouse,after-menu,final",
        "--human-session",
        "capture_status",
        "no_local_qemu=yes",
        "doom.symbols",
        "audio-proof.json",
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

    for forbidden in (
        "make ALLOW_LOCAL_VM=1 run",
        "make ALLOW_LOCAL_VM=1 smoke",
        "build/gfx.bin",
        "build/vga.txt",
    ):
        if forbidden in runbook:
            raise AssertionError(f"runbook should not instruct local/pixel artifact path {forbidden!r}")

    _require(playable, "Remote Doom Playtest Runbook", "playable cloud proof doc")
    _require(playable, "tools/collect_human_playtest_bundle.py", "playable cloud proof doc")
    _require(playable, "human-playtest-session.json", "playable cloud proof doc")
    _require(playable, "human-playtest-manifest.json", "playable cloud proof doc")
    _require(playable, "puser", "playable cloud proof doc")
    _require(playable, "pspin", "playable cloud proof doc")
    _require(readme, "docs/runbooks/remote-doom-playtest.md", "README")
    _require(readme, "tools/collect_human_playtest_bundle.py", "README")
    _require(readme, "human-playtest-session.json", "README")
    _require(tests_readme, "check_cloud_playability_artifacts.py", "tests README")
    _require(tests_readme, "collect_human_playtest_bundle.py", "tests README")
    _require(tests_readme, "human-playtest-session.json", "tests README")
    _require(makefile, "cloud-playability-check", "Makefile")
    _require(makefile, "persistence-image-check", "Makefile")
    _require(makefile, "PERSISTENCE_BASELINE_IMAGE", "Makefile")
    _require(makefile, "PERSISTENCE_REBOOT_BASELINE_IMAGE", "Makefile")
    _require(makefile, "tools/check_cloud_playability_artifacts.py --repo-contract", "Makefile")

    for needle in (
        "workflow_dispatch:",
        "SMOKE_CAPTURE_GFX=0",
        "SMOKE_SKIP_ASSERTIONS=1",
        "if: always()",
        "QEMU_EXTRA_ARGS=\"-audiodev none,id=snd0 -device sb16,audiodev=snd0\"",
        "SMOKE_INPUT_SCRIPT=\"after-start:wait=2,snapshot after-fire:hold=ctrl:800",
        "after-start:wait=2,snapshot",
        "persistence_proof:",
        "persistence_input_script:",
        "persistence_save_slot:",
        "Use text=NAME",
        "Capture fresh persistence baseline",
        "if: ${{ always() && inputs.persistence_proof }}",
        "cp build/disk.img \"$RUNNER_TEMP/disk.before-persistence.img\"",
        "check_args=(--baseline-image \"$baseline\")",
        "check_args+=(--require-default)",
        "check_args+=(--require-save-slot \"$PERSISTENCE_SAVE_SLOT\")",
        "cp \"$baseline\" build/disk.img",
        "build/status.persistence-write.txt",
        "build/status.persistence-reboot.txt",
        "build/status.persistence-write-proof.txt",
        "build/status.persistence-reboot-proof.txt",
        "tools/check_doom_persistence_image.py",
        "--baseline-image \"$baseline\"",
        "--reboot-baseline-image \"$after_write\"",
        "python3 tools/check_real_wad_proof.py \\",
        "--baseline build/status.after-start.txt",
        "--start build/status.after-start.txt",
        "--fire build/status.after-fire.txt",
        "--movement build/status.after-move.txt",
        "--use build/status.after-use.txt",
        "--mouse build/status.after-mouse.txt",
        "--menu build/status.after-menu.txt",
        "python3 tools/check_human_playability_proof.py",
        "python3 tools/check_audio_continuity_proof.py",
        "python3 tools/check_audible_audio_proof.py",
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
    ):
        _require(workflow, needle, "real-WAD workflow")
    _assert_no_forbidden_uploads(workflow)


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
        "validation_gates": [
            "tools/check_real_wad_proof.py",
            "tools/check_human_playability_proof.py",
            "tools/check_audio_continuity_proof.py",
            "tools/check_cloud_playability_artifacts.py --human-session",
        ],
        "phases": phases,
    }
    session["session_id"] = _human_session_id(notes, phases)
    return session


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
        },
        "required_files": sorted(
            REQUIRED_STATUS_FILES
            + REQUIRED_DIAGNOSTIC_FILES
            + REQUIRED_SYMBOL_FILES
            + (HUMAN_NOTES_FILE, HUMAN_SESSION_FILE)
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
    }
    for key, expected in expected_policy.items():
        if policy.get(key) is not expected:
            raise AssertionError(f"{HUMAN_MANIFEST_FILE} artifact_policy.{key} must be {expected}")

    required_files = manifest.get("required_files")
    expected_required = sorted(
        REQUIRED_STATUS_FILES
        + REQUIRED_DIAGNOSTIC_FILES
        + REQUIRED_SYMBOL_FILES
        + (HUMAN_NOTES_FILE, HUMAN_SESSION_FILE)
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


def validate_human_notes(path: Path) -> None:
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


def validate_artifact_dir(artifact_dir: Path, require_human_notes: bool = False) -> None:
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
    try:
        check_real_wad_proof.validate_status(
            status,
            baseline_status=(artifact_dir / _find_one(names, "status.after-start.txt")).read_text(),
            start_status=(artifact_dir / _find_one(names, "status.after-start.txt")).read_text(),
            fire_status=(artifact_dir / _find_one(names, "status.after-fire.txt")).read_text(),
            movement_status=(artifact_dir / _find_one(names, "status.after-move.txt")).read_text(),
            use_status=(artifact_dir / _find_one(names, "status.after-use.txt")).read_text(),
            mouse_status=(artifact_dir / _find_one(names, "status.after-mouse.txt")).read_text(),
            menu_status=(artifact_dir / _find_one(names, "status.after-menu.txt")).read_text(),
        )
    except AssertionError as exc:
        raise AssertionError(
            f"{exc}; final status summary: {check_real_wad_proof.summarize_status(status)}"
        ) from exc
    try:
        check_audio_continuity_proof.validate_status(
            status,
            baseline_status=(artifact_dir / _find_one(names, "status.after-start.txt")).read_text(),
            fire_status=(artifact_dir / _find_one(names, "status.after-fire.txt")).read_text(),
            movement_status=(artifact_dir / _find_one(names, "status.after-move.txt")).read_text(),
            use_status=(artifact_dir / _find_one(names, "status.after-use.txt")).read_text(),
            menu_status=(artifact_dir / _find_one(names, "status.after-menu.txt")).read_text(),
        )
    except AssertionError as exc:
        raise AssertionError(
            f"{exc}; final audio summary: {check_audio_continuity_proof.summarize_status(status)}"
        ) from exc

    audio_proof = _find_one(names, OPTIONAL_AUDIO_PROOF_FILE)
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
            validate_human_notes(artifact_dir / human_notes)
        except AssertionError as exc:
            raise AssertionError(f"human playtest notes failed: {exc}") from exc

    human_session = _find_one(names, HUMAN_SESSION_FILE)
    if require_human_notes and human_session is None:
        raise AssertionError(f"missing expected human session file: {HUMAN_SESSION_FILE}")
    if human_session is not None:
        try:
            validate_human_session(artifact_dir, artifact_dir / human_session)
        except AssertionError as exc:
            raise AssertionError(f"human playtest session failed: {exc}") from exc

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
    args = parser.parse_args(argv)

    try:
        if args.repo_contract or args.artifact_dir is None:
            validate_repo_contract()
        if args.artifact_dir is not None:
            validate_artifact_dir(args.artifact_dir, require_human_notes=args.human_session)
    except (OSError, AssertionError) as exc:
        print(f"cloud playability artifact check failed: {exc}", file=sys.stderr)
        return 1

    print("cloud playability artifact check OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
