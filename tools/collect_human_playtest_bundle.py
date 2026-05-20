#!/usr/bin/env python3
"""Collect a status-only manual remote VNC Doom playtest proof bundle.

This helper is intended to run on a disposable remote host after a human VNC
session. It does not launch QEMU. It copies only allowlisted diagnostics out of
the remote build directory, writes the structured human notes file, and then
runs the same status-only artifact validator used for downloaded cloud proofs.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
sys.path.insert(0, str(SCRIPT_DIR))

import check_cloud_playability_artifacts  # noqa: E402


REQUIRED_EXACT_FILES = (
    "kernel.elf",
    "user_probe.elf",
    "doom.elf",
    "doom.symbols",
)

OPTIONAL_EXACT_FILES = (
    "audio-proof.json",
)

ALLOWLIST_PATTERNS = (
    "status*.txt",
    "*.log",
)

NOTE_FIELD_ORDER = (
    "schema",
    "commit",
    "playtester",
    "remote_host",
    "qemu_location",
    "qemu_display",
    "monitor_socket",
    "vnc_tunnel",
    "vnc_endpoint",
    "wad",
    "display",
    "keyboard",
    "mouse",
    "audio",
    "diagnostics",
    "proof_bundle",
    "no_local_qemu",
    "no_wad_upload",
    "no_disk_upload",
    "no_pixel_upload",
)


def _path_is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def _git_head() -> str:
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "--short=12", "HEAD"],
            cwd=ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"


def _assert_output_location(output_dir: Path) -> None:
    resolved_output = output_dir.resolve()
    resolved_root = ROOT.resolve()
    if _path_is_relative_to(resolved_output, resolved_root):
        raise AssertionError(
            "proof output must live outside the repository; use /tmp or another "
            "remote scratch directory so diagnostics cannot be accidentally committed"
        )


def _assert_empty_or_missing(output_dir: Path) -> None:
    if output_dir.exists() and any(output_dir.iterdir()):
        raise AssertionError(
            f"output directory must be empty or absent before collection: {output_dir}"
        )


def _copy_exact(build_dir: Path, output_dir: Path, name: str, required: bool) -> bool:
    src = build_dir / name
    if not src.exists():
        if required:
            raise AssertionError(f"missing required diagnostic in build dir: {name}")
        return False
    if not src.is_file():
        raise AssertionError(f"diagnostic path is not a file: {src}")
    shutil.copy2(src, output_dir / name)
    return True


def _copy_patterns(build_dir: Path, output_dir: Path) -> list[str]:
    copied: list[str] = []
    for pattern in ALLOWLIST_PATTERNS:
        for src in sorted(build_dir.glob(pattern)):
            if not src.is_file():
                continue
            dst = output_dir / src.name
            if dst.exists():
                raise AssertionError(f"duplicate output diagnostic basename: {src.name}")
            shutil.copy2(src, dst)
            copied.append(src.name)
    return copied


def _write_human_notes(args: argparse.Namespace, output_dir: Path) -> None:
    fields = {
        "schema": check_cloud_playability_artifacts.HUMAN_NOTES_SCHEMA,
        "commit": args.commit or _git_head(),
        "playtester": args.playtester,
        "remote_host": args.remote_host,
        "qemu_location": "remote",
        "qemu_display": "127.0.0.1:1",
        "monitor_socket": "unix-monitor-socket",
        "vnc_tunnel": "loopback-only",
        "vnc_endpoint": "127.0.0.1:5901",
        "wad": "shareware-v1.9-validated-remote-only",
        "display": args.display,
        "keyboard": args.keyboard,
        "mouse": args.mouse,
        "audio": args.audio,
        "diagnostics": "non-wad-status-only",
        "proof_bundle": "allowlisted-status-only",
        "no_local_qemu": "yes",
        "no_wad_upload": "yes",
        "no_disk_upload": "yes",
        "no_pixel_upload": "yes",
    }
    notes = "\n".join(f"{key}={fields[key]}" for key in NOTE_FIELD_ORDER) + "\n"
    (output_dir / check_cloud_playability_artifacts.HUMAN_NOTES_FILE).write_text(notes)


def collect(args: argparse.Namespace) -> list[str]:
    build_dir = args.build_dir.resolve()
    output_dir = args.output_dir
    _assert_output_location(output_dir)
    if not build_dir.exists():
        raise AssertionError(f"build directory does not exist: {build_dir}")
    if not build_dir.is_dir():
        raise AssertionError(f"build directory is not a directory: {build_dir}")
    _assert_empty_or_missing(output_dir)

    output_dir.mkdir(parents=True, exist_ok=True)
    copied = _copy_patterns(build_dir, output_dir)
    for name in REQUIRED_EXACT_FILES:
        _copy_exact(build_dir, output_dir, name, required=True)
        copied.append(name)
    for name in OPTIONAL_EXACT_FILES:
        if _copy_exact(build_dir, output_dir, name, required=False):
            copied.append(name)
    _write_human_notes(args, output_dir)
    copied.append(check_cloud_playability_artifacts.HUMAN_NOTES_FILE)

    if args.audio == "audio-proof-json-pass" and not (output_dir / "audio-proof.json").exists():
        raise AssertionError("audio=audio-proof-json-pass requires audio-proof.json")

    check_cloud_playability_artifacts.validate_artifact_dir(
        output_dir,
        require_human_notes=True,
    )
    return sorted(copied)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Collect a non-WAD, non-pixel, non-audio manual remote Doom "
            "playtest proof bundle and validate it."
        )
    )
    parser.add_argument(
        "--build-dir",
        type=Path,
        default=ROOT / "build",
        help="remote build directory containing status text, logs, and ELF diagnostics",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        required=True,
        help="empty scratch directory outside the repo, for example /tmp/vibe-os-human-proof",
    )
    parser.add_argument("--playtester", required=True, help="human initials or handle")
    parser.add_argument("--commit", help="commit under test; defaults to git rev-parse HEAD")
    parser.add_argument(
        "--remote-host",
        default="disposable",
        choices=("disposable",),
        help="remote host class attested by the human notes",
    )
    parser.add_argument("--display", default="pass", choices=("pass",))
    parser.add_argument("--keyboard", default="pass", choices=("pass",))
    parser.add_argument("--mouse", default="pass", choices=("pass",))
    parser.add_argument(
        "--audio",
        default="status-only",
        choices=("status-only", "listener-pass", "audio-proof-json-pass", "not-tested"),
    )
    args = parser.parse_args(argv)

    try:
        copied = collect(args)
    except (OSError, AssertionError) as exc:
        print(f"human playtest bundle collection failed: {exc}", file=sys.stderr)
        return 1

    print(f"human playtest bundle OK: {args.output_dir}")
    for name in copied:
        print(f"  {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
