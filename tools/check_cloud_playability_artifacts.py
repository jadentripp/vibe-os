#!/usr/bin/env python3
"""Validate the cloud human-playability runbook and downloaded diagnostics."""

from __future__ import annotations

import argparse
import fnmatch
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
sys.path.insert(0, str(SCRIPT_DIR))

import check_real_wad_proof  # noqa: E402
import check_audio_continuity_proof  # noqa: E402


RUNBOOK = ROOT / "docs" / "runbooks" / "remote-doom-playtest.md"
PLAYABLE_DOC = ROOT / "docs" / "playable-cloud-proof.md"
WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
README = ROOT / "README.md"
TESTS_README = ROOT / "tests" / "README.md"
MAKEFILE = ROOT / "Makefile"

REQUIRED_STATUS_FILES = (
    "status.early.txt",
    "status.after-fire.txt",
    "status.after-move.txt",
    "status.after-use.txt",
    "status.after-menu.txt",
    "status.txt",
)

REQUIRED_DIAGNOSTIC_FILES = (
    "kernel.elf",
    "user_probe.elf",
    "doom.elf",
)

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
)

CONTENT_SIGNATURES = (
    (b"IWAD", "WAD/IWAD payload"),
    (b"PWAD", "WAD/PWAD payload"),
    (b"\x89PNG\r\n\x1a\n", "PNG image"),
    (b"BM", "BMP image"),
    (b"P6", "PPM image"),
    (b"P5", "PGM image"),
    (b"QFI\xfb", "QCOW2 disk image"),
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
        "tools/check_real_wad_proof.py",
        "tools/check_human_playability_proof.py",
        "tools/check_audio_continuity_proof.py",
        "status.after-fire.txt",
        "status.after-move.txt",
        "status.after-use.txt",
        "status.after-menu.txt",
        "Arrow keys",
        "Ctrl: fire",
        "Space: use",
        "Escape",
        "audio=SB16",
        "audio=NONE",
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
    _require(readme, "docs/runbooks/remote-doom-playtest.md", "README")
    _require(tests_readme, "check_cloud_playability_artifacts.py", "tests README")
    _require(makefile, "cloud-playability-check", "Makefile")
    _require(makefile, "persistence-image-check", "Makefile")
    _require(makefile, "PERSISTENCE_BASELINE_IMAGE", "Makefile")
    _require(makefile, "tools/check_cloud_playability_artifacts.py --repo-contract", "Makefile")

    for needle in (
        "workflow_dispatch:",
        "SMOKE_CAPTURE_GFX=0",
        "SMOKE_SKIP_ASSERTIONS=1",
        "if: always()",
        "QEMU_EXTRA_ARGS=\"-audiodev none,id=snd0 -device sb16,audiodev=snd0\"",
        "SMOKE_INPUT_SCRIPT=\"after-fire:hold=ctrl:800",
        "persistence_proof:",
        "persistence_input_script:",
        "persistence_save_slot:",
        "build/status.persistence-write.txt",
        "build/status.persistence-reboot.txt",
        "tools/check_doom_persistence_image.py",
        "--baseline-image \"$baseline\"",
        "python3 tools/check_real_wad_proof.py \\",
        "--baseline build/status.early.txt",
        "--fire build/status.after-fire.txt",
        "--movement build/status.after-move.txt",
        "--use build/status.after-use.txt",
        "--menu build/status.after-menu.txt",
        "python3 tools/check_human_playability_proof.py",
        "python3 tools/check_audio_continuity_proof.py",
        'rm -f "$WAD_PATH"',
        "build/status*.bin",
        "build/status*.txt",
        "build/*.log",
        "build/persistence-*/*.log",
        "build/kernel.elf",
        "build/user_probe.elf",
        "build/doom.elf",
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


def validate_artifact_dir(artifact_dir: Path) -> None:
    if not artifact_dir.exists():
        raise AssertionError(f"artifact directory does not exist: {artifact_dir}")
    names = _relative_names(artifact_dir)
    for name in names:
        basename = Path(name).name
        for pattern in FORBIDDEN_ARTIFACT_PATTERNS:
            if fnmatch.fnmatchcase(basename, pattern):
                raise AssertionError(f"forbidden WAD/image/pixel artifact present: {name}")
    _assert_no_forbidden_contents(artifact_dir, names)

    missing = [
        required for required in REQUIRED_STATUS_FILES + REQUIRED_DIAGNOSTIC_FILES
        if _find_one(names, required) is None
    ]
    if missing:
        raise AssertionError(f"missing expected diagnostic files: {', '.join(missing)}")

    status_path = artifact_dir / _find_one(names, "status.txt")
    status = status_path.read_text()
    try:
        check_real_wad_proof.validate_status(
            status,
            baseline_status=(artifact_dir / _find_one(names, "status.early.txt")).read_text(),
            fire_status=(artifact_dir / _find_one(names, "status.after-fire.txt")).read_text(),
            movement_status=(artifact_dir / _find_one(names, "status.after-move.txt")).read_text(),
            use_status=(artifact_dir / _find_one(names, "status.after-use.txt")).read_text(),
            menu_status=(artifact_dir / _find_one(names, "status.after-menu.txt")).read_text(),
        )
    except AssertionError as exc:
        raise AssertionError(
            f"{exc}; final status summary: {check_real_wad_proof.summarize_status(status)}"
        ) from exc
    try:
        check_audio_continuity_proof.validate_status(
            status,
            baseline_status=(artifact_dir / _find_one(names, "status.early.txt")).read_text(),
            fire_status=(artifact_dir / _find_one(names, "status.after-fire.txt")).read_text(),
            movement_status=(artifact_dir / _find_one(names, "status.after-move.txt")).read_text(),
            use_status=(artifact_dir / _find_one(names, "status.after-use.txt")).read_text(),
            menu_status=(artifact_dir / _find_one(names, "status.after-menu.txt")).read_text(),
        )
    except AssertionError as exc:
        raise AssertionError(
            f"{exc}; final audio summary: {check_audio_continuity_proof.summarize_status(status)}"
        ) from exc


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
    args = parser.parse_args(argv)

    try:
        if args.repo_contract or args.artifact_dir is None:
            validate_repo_contract()
        if args.artifact_dir is not None:
            validate_artifact_dir(args.artifact_dir)
    except (OSError, AssertionError) as exc:
        print(f"cloud playability artifact check failed: {exc}", file=sys.stderr)
        return 1

    print("cloud playability artifact check OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
