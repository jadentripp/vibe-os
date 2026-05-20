#!/usr/bin/env python3
"""Validate the cloud human-playability runbook and downloaded diagnostics."""

from __future__ import annotations

import argparse
import fnmatch
import gzip
import io
import sys
import zipfile
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
REQUIRED_HUMAN_NOTE_FIELDS = {
    "schema": (HUMAN_NOTES_SCHEMA,),
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
)
OPTIONAL_HUMAN_NOTE_FIELDS = {
    "audio": ("status-only", "listener-pass", "audio-proof-json-pass", "not-tested"),
}

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
        "proof_bundle=allowlisted-status-only",
        "qemu_display=127.0.0.1:1",
        "vnc_endpoint=127.0.0.1:5901",
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
    _require(playable, "puser", "playable cloud proof doc")
    _require(playable, "pspin", "playable cloud proof doc")
    _require(readme, "docs/runbooks/remote-doom-playtest.md", "README")
    _require(readme, "tools/collect_human_playtest_bundle.py", "README")
    _require(tests_readme, "check_cloud_playability_artifacts.py", "tests README")
    _require(tests_readme, "collect_human_playtest_bundle.py", "tests README")
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
