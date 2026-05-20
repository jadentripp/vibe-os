#!/usr/bin/env python3
"""Reject tracked files that would make Doom provenance or proof evidence murky."""

from __future__ import annotations

import fnmatch
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

FORBIDDEN_PATH_FRAGMENTS = (
    "doomgeneric",
    "chocolate-doom",
    "chocolate_doom",
    "crispy-doom",
    "crispy_doom",
    "prboom",
)

FORBIDDEN_RUNTIME_CONTENT = (
    "doomgeneric",
    "chocolate doom",
    "chocolate-doom",
    "chocolate_doom",
    "crispy doom",
    "crispy-doom",
    "crispy_doom",
    "prboom",
    "source port",
    "sourceport",
    "xopendisplay",
    "/dev/fb0",
    "/dev/dsp",
    "sdl_init",
    "#include <sdl",
)

FORBIDDEN_PATH_PATTERNS = (
    "build/*",
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
    "*.bin",
    "*.ppm",
    "*.pgm",
    "*.bmp",
    "*.png",
    "*.log",
    "status*.txt",
    "vga*.txt",
    "gfx*.txt",
    "serial*.txt",
    "monitor*.txt",
    "smoke*.txt",
)

ALLOWED_EXACT_PATHS = {
    "boot/stage1.asm",
    "boot/stage2.asm",
}

RUNTIME_SOURCE_PREFIXES = (
    "boot/",
    "kernel/",
    "user/",
    "doom_port/",
)

RUNTIME_BUILD_FILES = {
    "Makefile",
    ".github/workflows/os-smoke.yml",
    ".github/workflows/real-wad-smoke.yml",
}


def tracked_files() -> list[str]:
    result = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return [
        entry.decode("utf-8")
        for entry in result.stdout.split(b"\0")
        if entry
    ]


def vendor_tree_status() -> list[str]:
    result = subprocess.run(
        [
            "git",
            "status",
            "--porcelain=v1",
            "--untracked-files=all",
            "--",
            "third_party/doom",
        ],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return [
        entry.decode("utf-8")
        for entry in result.stdout.splitlines()
        if entry
    ]


def is_runtime_or_build_source(path: str) -> bool:
    return path in RUNTIME_BUILD_FILES or path.startswith(RUNTIME_SOURCE_PREFIXES)


def find_violations(paths: list[str]) -> list[str]:
    violations: list[str] = []
    for path in paths:
        if path in ALLOWED_EXACT_PATHS:
            continue
        lower = path.lower()
        if any(fragment in lower for fragment in FORBIDDEN_PATH_FRAGMENTS):
            violations.append(f"{path}: wrapper/source-port path is tracked")
            continue
        for pattern in FORBIDDEN_PATH_PATTERNS:
            if fnmatch.fnmatchcase(path, pattern):
                violations.append(f"{path}: generated game data, VM evidence, or pixel artifact is tracked")
                break
        if is_runtime_or_build_source(path):
            text = (ROOT / path).read_text(errors="ignore").lower()
            for token in FORBIDDEN_RUNTIME_CONTENT:
                if token in text:
                    violations.append(
                        f"{path}: runtime/build source references "
                        f"shortcut Doom engine or host API token {token!r}"
                    )
                    break
    return violations


def main() -> int:
    violations = find_violations(tracked_files())
    violations.extend(
        f"{entry}: third_party/doom must remain a pristine vendor tree"
        for entry in vendor_tree_status()
    )
    if violations:
        print("repo hygiene check failed:", file=sys.stderr)
        for violation in violations:
            print(f"- {violation}", file=sys.stderr)
        return 1
    print(
        "repo hygiene OK: pristine Doom vendor tree, no tracked WADs, "
        "disk images, pixel dumps, logs, wrapper engine paths, or runtime "
        "shortcut APIs"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
