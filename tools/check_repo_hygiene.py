#!/usr/bin/env python3
"""Reject tracked files that would make Doom provenance or proof evidence murky."""

from __future__ import annotations

import fnmatch
import gzip
import hashlib
import re
import subprocess
import sys
import tarfile
import zipfile
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOOM_VENDOR_ROOT = ROOT / "third_party" / "doom"
DOOM_SOURCE_ROOT = DOOM_VENDOR_ROOT / "linuxdoom-1.10"
UPSTREAM_COMMIT = "a77dfb96cb91780ca334d0d4cfd86957558007e0"
UPSTREAM_TREE_FILE_COUNT = 126
UPSTREAM_TREE_SHA256 = "38ef8b80b6848e934c72d27cbbfa013c1e184544e9ddb6f100c4a15e565e3b83"
UPSTREAM_IMPORTED_TREE_FILE_COUNT = 165
UPSTREAM_IMPORTED_TREE_SHA256 = "7778ac7309e54a25199338402f488c806f625f57b7d774359bf2ff5440aa6e66"

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
    "screenshots/*",
    "*/screenshots/*",
    "pixels/*",
    "*/pixels/*",
    "*.wad",
    "*.WAD",
    "*.iwad",
    "*.IWAD",
    "*.pwad",
    "*.PWAD",
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
    "*.img",
    "*.iso",
    "*.raw",
    "*.wav",
    "*.wave",
    "*.mp3",
    "*.ogg",
    "*.oga",
    "*.opus",
    "*.m4a",
    "*.aac",
    "*.wma",
    "*.flac",
    "*.aiff",
    "*.aif",
    "*.au",
    "*.mid",
    "*.midi",
    "*.mus",
    "*.sf2",
    "*.sf3",
    "*.voc",
    "*.mod",
    "*.s3m",
    "*.xm",
    "*.it",
    "*.qcow2",
    "*.bin",
    "*.ppm",
    "*.pgm",
    "*.bmp",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.webp",
    "*.gif",
    "*.log",
    "screenshot*.txt",
    "pixel*.txt",
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

FORBIDDEN_TRACKED_MAGIC = (
    (b"IWAD", "WAD/IWAD payload"),
    (b"PWAD", "WAD/PWAD payload"),
)

WAD_ARCHIVE_MEMBER_PATTERNS = (
    "*.wad",
    "*.WAD",
    "*.iwad",
    "*.IWAD",
    "*.pwad",
    "*.PWAD",
)

ARCHIVE_PREFIX_BYTES = 512
MAX_ARCHIVE_MEMBERS_TO_SNIFF = 64

FORBIDDEN_VENDOR_PORT_TOKENS = (
    "VIBE_SYS_",
    "vibe_syscall",
    "vibe_os.h",
    "doom_port",
)

FORBIDDEN_UPLOAD_PATTERNS = (
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
    "*.img",
    "*.iso",
    "*.qcow2",
    "*.raw",
    "*.wav",
    "*.wave",
    "*.mp3",
    "*.ogg",
    "*.oga",
    "*.opus",
    "*.m4a",
    "*.aac",
    "*.wma",
    "*.flac",
    "*.aiff",
    "*.aif",
    "*.au",
    "*.mid",
    "*.midi",
    "*.mus",
    "*.sf2",
    "*.sf3",
    "*.voc",
    "*.mod",
    "*.s3m",
    "*.xm",
    "*.it",
)

FORBIDDEN_REAL_WAD_UPLOAD_PATTERNS = (
    "gfx.bin",
    "gfx*.txt",
    "vga*.bin",
    "vga*.txt",
    "*.ppm",
    "*.pgm",
    "*.bmp",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.webp",
    "*.gif",
    "screenshots/*",
    "*/screenshots/*",
    "pixels/*",
    "*/pixels/*",
)

REAL_WAD_ALLOWED_UPLOAD_PATTERNS = (
    "build/kernel.elf",
    "build/user_probe.elf",
    "build/doom.elf",
    "build/doom.symbols",
    "build/audio-proof.json",
    "build/gameplay-proof.json",
    "real-wad-soak/*.json",
    "*/real-wad-soak/*.json",
    "${{ runner.temp }}/real-wad-soak/*.json",
    "build/status*.bin",
    "build/status*.txt",
    "build/*.log",
    "build/persistence-*/*.json",
    "build/persistence-*/*.log",
)

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

README_MAX_LINES = 160
README_FORBIDDEN_PATTERNS = (
    ("commit hash", r"\b[0-9a-f]{7,40}\b"),
    ("run ID", r"\brun[-_ ]?id\b|\bworkflow[-_ ]?run\b|\bscripted[_ -]proof[_ -]run[_ -]id\b"),
    ("long decimal run identifier", r"\b\d{9,}\b"),
    ("task-list checkbox", r"^\s*-\s*\[[ xX]\]"),
    ("TODO marker", r"\b(?:TODO|FIXME)\b"),
    ("gap ledger row", r"\bGAP\["),
    ("proof transcript field", r"\b(?:commit=|scripted_proof_run_id=|phase_hash_|verification_id=)\b"),
)


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


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def upstream_manifest_paths() -> list[Path]:
    paths = [Path("README.TXT"), Path("LICENSE.TXT")]
    paths.extend(
        sorted(
            Path("linuxdoom-1.10") / path.name
            for path in DOOM_SOURCE_ROOT.glob("*.[ch]")
        )
    )
    return paths


def upstream_tree_sha256() -> str:
    digest = hashlib.sha256()
    for relpath in upstream_manifest_paths():
        digest.update(relpath.as_posix().encode("utf-8"))
        digest.update(b"\0")
        digest.update(sha256(DOOM_VENDOR_ROOT / relpath).encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest()


def upstream_imported_manifest_paths(paths: list[str] | None = None) -> list[Path]:
    if paths is None:
        paths = tracked_files()
    vendor_prefix = "third_party/doom/"
    manifest_paths = []
    for path in paths:
        if not path.startswith(vendor_prefix):
            continue
        relpath = Path(path).relative_to(DOOM_VENDOR_ROOT.relative_to(ROOT))
        if relpath.as_posix() == "ORIGIN.md":
            continue
        manifest_paths.append(relpath)
    return sorted(manifest_paths)


def upstream_imported_tree_sha256(paths: list[str] | None = None) -> str:
    digest = hashlib.sha256()
    for relpath in upstream_imported_manifest_paths(paths):
        digest.update(relpath.as_posix().encode("utf-8"))
        digest.update(b"\0")
        full_path = DOOM_VENDOR_ROOT / relpath
        digest.update(sha256(full_path).encode("ascii") if full_path.exists() else b"MISSING")
        digest.update(b"\n")
    return digest.hexdigest()


def path_matches(path: str, patterns: tuple[str, ...]) -> bool:
    lowered = path.lower()
    basename = Path(path).name.lower()
    return any(
        fnmatch.fnmatchcase(lowered, pattern.lower())
        or fnmatch.fnmatchcase(basename, pattern.lower())
        for pattern in patterns
    )


def read_file_prefix(path: str, size: int = 16) -> bytes:
    with (ROOT / path).open("rb") as handle:
        return handle.read(size)


def forbidden_magic_label(prefix: bytes) -> str | None:
    for magic, label in FORBIDDEN_TRACKED_MAGIC:
        if prefix.startswith(magic):
            return label
    return None


def _archive_member_violation(container_path: str, member_name: str, member_prefix: bytes) -> str | None:
    normalized_name = member_name.replace("\\", "/")
    if path_matches(normalized_name, WAD_ARCHIVE_MEMBER_PATTERNS):
        return f"{container_path}: archive member {normalized_name!r} is a WAD path"
    label = forbidden_magic_label(member_prefix)
    if label:
        return f"{container_path}: archive member {normalized_name!r} contains {label}"
    return None


def _gzip_wad_violation(path: str) -> str | None:
    try:
        with gzip.open(ROOT / path, "rb") as handle:
            label = forbidden_magic_label(handle.read(16))
    except (EOFError, OSError, zlib.error):
        return None
    if label:
        return f"{path}: gzip-compressed {label} is tracked under a non-WAD extension"
    return None


def _zip_wad_violation(path: str) -> str | None:
    try:
        with zipfile.ZipFile(ROOT / path) as archive:
            for index, info in enumerate(archive.infolist()):
                if index >= MAX_ARCHIVE_MEMBERS_TO_SNIFF:
                    break
                if info.is_dir():
                    continue
                if path_matches(info.filename, WAD_ARCHIVE_MEMBER_PATTERNS):
                    return f"{path}: ZIP archive member {info.filename!r} is a WAD path"
                with archive.open(info, "r") as handle:
                    violation = _archive_member_violation(path, info.filename, handle.read(16))
                if violation:
                    return violation
    except (EOFError, OSError, RuntimeError, zipfile.BadZipFile, zlib.error):
        return None
    return None


def _tar_wad_violation(path: str) -> str | None:
    try:
        with tarfile.open(ROOT / path, "r:*") as archive:
            for index, member in enumerate(archive):
                if index >= MAX_ARCHIVE_MEMBERS_TO_SNIFF:
                    break
                if not member.isfile():
                    continue
                if path_matches(member.name, WAD_ARCHIVE_MEMBER_PATTERNS):
                    return f"{path}: tar archive member {member.name!r} is a WAD path"
                extracted = archive.extractfile(member)
                if extracted is None:
                    continue
                with extracted:
                    violation = _archive_member_violation(path, member.name, extracted.read(16))
                if violation:
                    return violation
    except (EOFError, OSError, tarfile.TarError, zlib.error):
        return None
    return None


def archive_wad_violation(path: str, prefix: bytes) -> str | None:
    if prefix.startswith(b"\x1f\x8b"):
        violation = _gzip_wad_violation(path)
        if violation:
            return violation
        return _tar_wad_violation(path)
    if prefix.startswith((b"PK\x03\x04", b"PK\x05\x06", b"PK\x07\x08")):
        return _zip_wad_violation(path)
    if len(prefix) >= 262 and prefix[257:262] == b"ustar":
        return _tar_wad_violation(path)
    return None


def upload_path_lines(workflow_text: str) -> list[str]:
    lines = workflow_text.splitlines()
    uploads: list[str] = []
    for index, line in enumerate(lines):
        if "uses: actions/upload-artifact@v4" not in line:
            continue
        for path_index in range(index + 1, len(lines)):
            stripped = lines[path_index].strip()
            if path_index > index + 1 and stripped.startswith("uses: "):
                break
            if not stripped.startswith("path:"):
                continue
            path_value = stripped[len("path:") :].strip()
            if path_value and path_value not in {"|", ">", "|-", ">-"}:
                uploads.append(path_value.strip("'\""))
                continue
            path_indent = len(lines[path_index]) - len(lines[path_index].lstrip())
            for item_line in lines[path_index + 1 :]:
                if not item_line.strip():
                    continue
                item_indent = len(item_line) - len(item_line.lstrip())
                if item_indent <= path_indent:
                    break
                item = item_line.strip()
                if not item.startswith("#"):
                    uploads.append(item)
            break
    return uploads


def is_real_wad_workflow(path: str, text: str) -> bool:
    return "real-wad" in path or "WAD_PATH" in text or "EXPECTED_WAD_SHA1" in text


def workflow_upload_violations(paths: list[str]) -> list[str]:
    violations: list[str] = []
    workflow_paths = [
        path
        for path in paths
        if path.startswith(".github/workflows/")
        and path.endswith((".yml", ".yaml"))
    ]
    for path in workflow_paths:
        text = (ROOT / path).read_text(errors="ignore")
        upload_paths = upload_path_lines(text)
        forbidden_patterns = FORBIDDEN_UPLOAD_PATTERNS
        real_wad_workflow = is_real_wad_workflow(path, text)
        if real_wad_workflow:
            forbidden_patterns = forbidden_patterns + FORBIDDEN_REAL_WAD_UPLOAD_PATTERNS
        for upload_path in upload_paths:
            if path_matches(upload_path, forbidden_patterns):
                violations.append(
                    f"{path}: upload-artifact path {upload_path!r} may upload "
                    "WADs, disk images, raw audio, screenshots, or rendered pixels"
                )
                continue
            if real_wad_workflow and not path_matches(upload_path, REAL_WAD_ALLOWED_UPLOAD_PATTERNS):
                violations.append(
                    f"{path}: real-WAD upload path {upload_path!r} is not in the "
                    "status/log/ELF/symbol/JSON diagnostic allowlist"
                )
    return violations


def vendor_policy_violations() -> list[str]:
    violations: list[str] = []
    origin = (DOOM_VENDOR_ROOT / "ORIGIN.md").read_text(errors="ignore")
    for token in (
        "https://github.com/id-Software/DOOM",
        UPSTREAM_COMMIT,
        "keep this vendor tree pristine",
    ):
        if token not in origin:
            violations.append(f"third_party/doom/ORIGIN.md: missing pristine policy token {token!r}")

    manifest_paths = upstream_manifest_paths()
    if len(manifest_paths) != UPSTREAM_TREE_FILE_COUNT:
        violations.append(
            "third_party/doom/linuxdoom-1.10: upstream source manifest "
            f"has {len(manifest_paths)} files, expected {UPSTREAM_TREE_FILE_COUNT}"
        )
    actual_tree_hash = upstream_tree_sha256()
    if actual_tree_hash != UPSTREAM_TREE_SHA256:
        violations.append(
            "third_party/doom/linuxdoom-1.10: upstream source manifest "
            f"hash {actual_tree_hash} != {UPSTREAM_TREE_SHA256}"
        )

    imported_manifest_paths = upstream_imported_manifest_paths()
    if len(imported_manifest_paths) != UPSTREAM_IMPORTED_TREE_FILE_COUNT:
        violations.append(
            "third_party/doom: imported upstream tree has "
            f"{len(imported_manifest_paths)} tracked files, expected "
            f"{UPSTREAM_IMPORTED_TREE_FILE_COUNT}"
        )
    actual_imported_tree_hash = upstream_imported_tree_sha256()
    if actual_imported_tree_hash != UPSTREAM_IMPORTED_TREE_SHA256:
        violations.append(
            "third_party/doom: imported upstream tree hash "
            f"{actual_imported_tree_hash} != {UPSTREAM_IMPORTED_TREE_SHA256}"
        )

    for path in DOOM_VENDOR_ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in {".c", ".h"}:
            continue
        text = path.read_text(errors="ignore")
        relpath = path.relative_to(ROOT).as_posix()
        for token in FORBIDDEN_VENDOR_PORT_TOKENS:
            if token in text:
                violations.append(
                    f"{relpath}: pristine vendor source references port-owned token {token!r}"
                )
                break
    return violations


def is_runtime_or_build_source(path: str) -> bool:
    return path in RUNTIME_BUILD_FILES or path.startswith(RUNTIME_SOURCE_PREFIXES)


def readme_policy_violations(root: Path = ROOT) -> list[str]:
    readme = root / "README.md"
    text = readme.read_text(errors="ignore")
    lines = text.splitlines()
    violations: list[str] = []
    if len(lines) > README_MAX_LINES:
        violations.append(
            f"README.md: top-level README has {len(lines)} lines, max {README_MAX_LINES}; "
            "move proof history, task lists, and command transcripts into docs/"
        )

    for label, pattern in README_FORBIDDEN_PATTERNS:
        regex = re.compile(pattern, re.IGNORECASE | re.MULTILINE)
        if regex.search(text):
            violations.append(
                f"README.md: top-level README must stay concise and not advertise {label}; "
                "move detailed proof evidence into docs/"
            )
    return violations


def find_violations(paths: list[str]) -> list[str]:
    violations: list[str] = []
    for path in paths:
        if path in ALLOWED_EXACT_PATHS:
            continue
        lower = path.lower()
        if any(fragment in lower for fragment in FORBIDDEN_PATH_FRAGMENTS):
            violations.append(f"{path}: wrapper/source-port path is tracked")
            continue
        if path_matches(path, FORBIDDEN_PATH_PATTERNS):
            violations.append(
                f"{path}: generated game data, VM evidence, raw audio, "
                "screenshot, or pixel artifact is tracked"
            )
            continue
        prefix = read_file_prefix(path, ARCHIVE_PREFIX_BYTES)
        label = forbidden_magic_label(prefix)
        if label:
            violations.append(f"{path}: {label} is tracked under a non-WAD extension")
            continue
        archive_violation = archive_wad_violation(path, prefix)
        if archive_violation:
            violations.append(archive_violation)
            continue
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
    paths = tracked_files()
    violations = find_violations(paths)
    violations.extend(vendor_policy_violations())
    violations.extend(workflow_upload_violations(paths))
    violations.extend(readme_policy_violations())
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
        "renamed WAD/archive payloads, disk images, standalone music/audio assets, "
        "pixel dumps, logs, wrapper engine paths, "
        "forbidden uploads, or runtime shortcut APIs"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
