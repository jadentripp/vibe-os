#!/usr/bin/env python3
"""Guard the vendored Doom source boundary without launching a VM."""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[1]
DOOM_VENDOR_PREFIX = "third_party/doom"

VENDOR_SCAN_SUFFIXES = {
    ".asm",
    ".c",
    ".cc",
    ".cpp",
    ".h",
    ".hpp",
    ".inc",
    ".ld",
    ".lds",
    ".mk",
    ".s",
}
VENDOR_SCAN_FILENAMES = {"makefile"}

PORT_TOKEN_RULES = (
    (
        "vibe_os include",
        re.compile(r"#\s*include\s*[<\"][^>\"]*vibe_os\.h[>\"]"),
    ),
    ("doom_port reference", re.compile(r"\bdoom_port\b")),
    ("Vibe syscall constant", re.compile(r"\bVIBE_SYS_[A-Z0-9_]+\b")),
    ("Vibe syscall helper", re.compile(r"\bvibe_syscall\d*\b")),
    (
        "Vibe OS helper",
        re.compile(
            r"\bvibe_(?:audio|clock|drain|fb|file|heap|input|listdir|mmap|"
            r"music|poll|present|syscall|vm)[A-Za-z0-9_]*\b"
        ),
    ),
)

ASSET_PATH_RULES = (
    (
        "WAD/game-data",
        (
            "*.wad",
            "*.iwad",
            "*.pwad",
            "*.wad.gz",
            "*.iwad.gz",
            "*.pwad.gz",
            "*.wad.zip",
            "*.iwad.zip",
            "*.pwad.zip",
            "*.wad.tar",
            "*.iwad.tar",
            "*.pwad.tar",
            "*.wad.tar.gz",
            "*.iwad.tar.gz",
            "*.pwad.tar.gz",
            "*.wad.tgz",
            "*.iwad.tgz",
            "*.pwad.tgz",
            "*.wad.7z",
            "*.iwad.7z",
            "*.pwad.7z",
            "*.wad.rar",
            "*.iwad.rar",
            "*.pwad.rar",
        ),
    ),
    (
        "disk image",
        (
            "*.img",
            "*.iso",
            "*.qcow2",
            "*.raw",
            "*.vdi",
            "*.vmdk",
        ),
    ),
    (
        "framebuffer/pixel artifact",
        (
            "*.ppm",
            "*.pgm",
            "*.bmp",
            "screenshots/*",
            "*/screenshots/*",
            "pixels/*",
            "*/pixels/*",
            "framebuffer*.bin",
            "framebuffer*.bmp",
            "framebuffer*.pgm",
            "framebuffer*.png",
            "framebuffer*.ppm",
            "framebuffer*.txt",
            "gfx*.bin",
            "gfx*.txt",
            "vga*.bin",
            "vga*.txt",
            "screen*.png",
            "screenshot*.png",
            "screenshot*.txt",
            "pixel*.png",
            "pixel*.txt",
        ),
    ),
    (
        "audio/music artifact",
        (
            "*.aac",
            "*.aif",
            "*.aiff",
            "*.au",
            "*.flac",
            "*.it",
            "*.m4a",
            "*.mid",
            "*.midi",
            "*.mod",
            "*.mp3",
            "*.mus",
            "*.oga",
            "*.ogg",
            "*.opus",
            "*.s3m",
            "*.sf2",
            "*.sf3",
            "*.voc",
            "*.wav",
            "*.wave",
            "*.wma",
            "*.xm",
        ),
    ),
)

WAD_MAGICS = ((b"IWAD", "IWAD"), (b"PWAD", "PWAD"))


class BoundaryError(RuntimeError):
    pass


@dataclass(frozen=True)
class IndexEntry:
    path: str
    oid: str
    mode: str
    stage: str


def git_text(root: Path, args: list[str], *, check: bool = True) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=root,
        capture_output=True,
        text=True,
        check=False,
    )
    if check and result.returncode:
        message = result.stderr.strip() or f"git {' '.join(args)} failed"
        raise BoundaryError(message)
    return result.stdout


def git_bytes(root: Path, args: list[str], *, check: bool = True) -> bytes:
    result = subprocess.run(
        ["git", *args],
        cwd=root,
        capture_output=True,
        check=False,
    )
    if check and result.returncode:
        message = result.stderr.decode("utf-8", "replace").strip()
        raise BoundaryError(message or f"git {' '.join(args)} failed")
    return result.stdout


def normalize_repo_root(root: Path) -> Path:
    requested = root.resolve()
    top = git_text(requested, ["rev-parse", "--show-toplevel"]).strip()
    return Path(top).resolve()


def zsplit_paths(raw: bytes) -> list[str]:
    return [
        entry.decode("utf-8", "surrogateescape")
        for entry in raw.split(b"\0")
        if entry
    ]


def path_matches(path: str, patterns: tuple[str, ...]) -> bool:
    lowered = path.lower()
    basename = Path(path).name.lower()
    for pattern in patterns:
        pattern = pattern.lower()
        if fnmatch.fnmatchcase(lowered, pattern):
            return True
        if "/" not in pattern and fnmatch.fnmatchcase(basename, pattern):
            return True
    return False


def asset_path_label(path: str) -> str | None:
    for label, patterns in ASSET_PATH_RULES:
        if path_matches(path, patterns):
            return label
    return None


def vendor_diff_violations(root: Path) -> tuple[list[str], list[dict[str, object]]]:
    if subprocess.run(
        ["git", "rev-parse", "--verify", "HEAD"],
        cwd=root,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    ).returncode:
        raise BoundaryError("git HEAD is required to check third_party/doom provenance")

    output = git_text(
        root,
        [
            "diff",
            "--name-status",
            "--diff-filter=ACMRTDU",
            "HEAD",
            "--",
            DOOM_VENDOR_PREFIX,
        ],
    )
    violations: list[str] = []
    changes: list[dict[str, object]] = []
    for line in output.splitlines():
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        status = parts[0]
        paths = parts[1:]
        display_path = " -> ".join(paths)
        changes.append({"status": status, "paths": paths})
        violations.append(
            f"{display_path}: tracked third_party/doom content differs from HEAD ({status})"
        )
    return violations, changes


def vendor_candidate_paths(root: Path) -> list[str]:
    tracked = zsplit_paths(
        git_bytes(root, ["ls-files", "-z", "--", DOOM_VENDOR_PREFIX])
    )
    untracked = zsplit_paths(
        git_bytes(
            root,
            ["ls-files", "-z", "--others", "--exclude-standard", "--", DOOM_VENDOR_PREFIX],
        )
    )
    return sorted(set(tracked + untracked))


def should_scan_vendor_path(path: str) -> bool:
    rel = Path(path)
    suffix = rel.suffix.lower()
    return suffix in VENDOR_SCAN_SUFFIXES or rel.name.lower() in VENDOR_SCAN_FILENAMES


def vendor_port_token_violations(root: Path) -> tuple[list[str], int]:
    violations: list[str] = []
    scanned_files = 0
    for path in vendor_candidate_paths(root):
        if not should_scan_vendor_path(path):
            continue
        full_path = root / path
        if not full_path.is_file():
            continue
        scanned_files += 1
        try:
            lines = full_path.read_text(errors="ignore").splitlines()
        except OSError as exc:
            violations.append(f"{path}: could not read vendor source for boundary scan: {exc}")
            continue
        for line_number, line in enumerate(lines, start=1):
            for label, pattern in PORT_TOKEN_RULES:
                if pattern.search(line):
                    violations.append(
                        f"{path}:{line_number}: OS-facing port token ({label}) "
                        "is inside third_party/doom"
                    )
                    break
    return violations, scanned_files


def indexed_entries(root: Path) -> list[IndexEntry]:
    raw = git_bytes(root, ["ls-files", "-s", "-z"])
    entries: list[IndexEntry] = []
    for record in raw.split(b"\0"):
        if not record:
            continue
        try:
            header, raw_path = record.split(b"\t", 1)
            mode, oid, stage = header.decode("ascii").split()
        except ValueError as exc:
            raise BoundaryError(f"could not parse git index entry {record!r}: {exc}") from exc
        entries.append(
            IndexEntry(
                path=raw_path.decode("utf-8", "surrogateescape"),
                oid=oid,
                mode=mode,
                stage=stage,
            )
        )
    return entries


def read_exact(stream, size: int) -> bytes:
    chunks: list[bytes] = []
    remaining = size
    while remaining:
        chunk = stream.read(remaining)
        if not chunk:
            raise BoundaryError("git cat-file ended while reading an index blob")
        chunks.append(chunk)
        remaining -= len(chunk)
    return b"".join(chunks)


def discard_exact(stream, size: int) -> None:
    remaining = size
    while remaining:
        chunk = stream.read(min(65536, remaining))
        if not chunk:
            raise BoundaryError("git cat-file ended while discarding an index blob")
        remaining -= len(chunk)


def index_blob_prefixes(root: Path, oids: list[str], size: int = 16) -> dict[str, bytes]:
    unique_oids = list(dict.fromkeys(oids))
    if not unique_oids:
        return {}

    process = subprocess.Popen(
        ["git", "cat-file", "--batch"],
        cwd=root,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    assert process.stdin is not None
    assert process.stdout is not None
    assert process.stderr is not None

    process.stdin.write(("\n".join(unique_oids) + "\n").encode("ascii"))
    process.stdin.close()

    prefixes: dict[str, bytes] = {}
    for oid in unique_oids:
        header = process.stdout.readline()
        if not header:
            raise BoundaryError(f"git cat-file did not return object {oid}")
        parts = header.strip().split()
        if len(parts) != 3:
            raise BoundaryError(f"could not parse git cat-file header: {header!r}")
        object_type = parts[1]
        object_size = int(parts[2])
        prefix_size = min(size, object_size)
        prefix = read_exact(process.stdout, prefix_size)
        discard_exact(process.stdout, object_size - prefix_size)
        read_exact(process.stdout, 1)
        prefixes[oid] = prefix if object_type == b"blob" else b""

    stderr = process.stderr.read().decode("utf-8", "replace").strip()
    returncode = process.wait(timeout=5)
    if returncode:
        raise BoundaryError(stderr or "git cat-file --batch failed")
    return prefixes


def wad_magic_label(prefix: bytes) -> str | None:
    for magic, label in WAD_MAGICS:
        if prefix.startswith(magic):
            return label
    return None


def git_asset_violations(root: Path) -> tuple[list[str], int]:
    violations: list[str] = []
    entries = indexed_entries(root)
    seen_paths: set[str] = set()
    sniff_entries: list[IndexEntry] = []
    for entry in entries:
        if entry.path in seen_paths:
            continue
        seen_paths.add(entry.path)

        label = asset_path_label(entry.path)
        if label:
            violations.append(
                f"{entry.path}: forbidden {label} path is staged or committed"
            )
            continue

        sniff_entries.append(entry)

    prefixes = index_blob_prefixes(root, [entry.oid for entry in sniff_entries])
    for entry in sniff_entries:
        magic = wad_magic_label(prefixes.get(entry.oid, b""))
        if magic:
            violations.append(
                f"{entry.path}: indexed blob starts with {magic} magic; "
                "renamed WAD data is staged or committed"
            )
    return violations, len(seen_paths)


def build_report(root: Path) -> dict[str, object]:
    root = normalize_repo_root(root)
    vendor_diff, vendor_changes = vendor_diff_violations(root)
    port_tokens, scanned_vendor_files = vendor_port_token_violations(root)
    git_assets, indexed_path_count = git_asset_violations(root)

    violations = vendor_diff + port_tokens + git_assets
    return {
        "ok": not violations,
        "root": root.as_posix(),
        "violations": violations,
        "vendor_head": {
            "status": "clean" if not vendor_diff else "dirty",
            "changes": vendor_changes,
        },
        "vendor_platform_code": {
            "status": "clean" if not port_tokens else "dirty",
            "scanned_files": scanned_vendor_files,
            "violations": port_tokens,
        },
        "git_assets": {
            "status": "clean" if not git_assets else "dirty",
            "indexed_paths": indexed_path_count,
            "violations": git_assets,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=DEFAULT_ROOT,
        help="repository root to inspect (defaults to this checkout)",
    )
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    args = parser.parse_args()

    try:
        report = build_report(args.root)
    except BoundaryError as exc:
        report = {"ok": False, "violations": [str(exc)]}

    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
    elif report["ok"]:
        print("Doom source boundary OK")
        print("- tracked third_party/doom content matches HEAD")
        print(
            "- scanned "
            f"{report['vendor_platform_code']['scanned_files']} vendor source/build "
            "files for OS-facing port tokens"
        )
        print(
            "- checked "
            f"{report['git_assets']['indexed_paths']} staged/tracked paths for "
            "WAD, disk image, framebuffer, and audio artifacts"
        )
    else:
        print("doom source boundary check failed:", file=sys.stderr)
        for violation in report["violations"]:
            print(f"- {violation}", file=sys.stderr)

    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
