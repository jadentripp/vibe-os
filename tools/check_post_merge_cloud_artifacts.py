#!/usr/bin/env python3
"""Validate status-only post-merge cloud proof artifacts.

This checker is intentionally host-only. It reads downloaded GitHub Actions
artifacts and never launches QEMU, rebuilds images, fetches WADs, or inspects
screenshots/raw audio.
"""

from __future__ import annotations

import argparse
import fnmatch
import gzip
import io
import json
import sys
import zipfile
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

import check_audio_continuity_proof  # noqa: E402
import check_audible_audio_proof  # noqa: E402
import check_real_wad_proof  # noqa: E402
import check_scripted_gameplay_proof  # noqa: E402
import check_vm_status_proof  # noqa: E402
import triage_persistence_artifacts  # noqa: E402

RUN_IDENTITY = "cloud-proof-run.json"
RUN_IDENTITY_SCHEMA = "cloud-proof-run-v1"
OS_WORKFLOW = "os-smoke.yml"
OS_ARTIFACT = "aurora-os-smoke-proof-status"
REAL_WAD_WORKFLOW = "real-wad-smoke.yml"
REAL_WAD_ARTIFACT = "real-wad-smoke-proof-status"
UEFI_WORKFLOW = "uefi-ovmf-proof.yml"
UEFI_ARTIFACT = "uefi-ovmf-proof-manifests"

STATUS_ONLY_SUFFIXES = (".txt", ".json")
FORBIDDEN_PATTERNS = (
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
    "*.fd",
    "*.efi",
    "*.EFI",
    "*.elf",
    "*.symbols",
    "*.bin",
    "*.log",
    "gfx*.txt",
    "vga*.txt",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.webp",
    "*.bmp",
    "*.ppm",
    "*.pgm",
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
FORBIDDEN_ARCHIVE_SUFFIXES = (
    ".wad",
    ".iwad",
    ".pwad",
    ".img",
    ".iso",
    ".raw",
    ".qcow2",
    ".fd",
    ".efi",
    ".elf",
    ".symbols",
    ".bin",
    ".log",
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
CONTENT_SIGNATURES = (
    (b"\x7fELF", "ELF binary"),
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


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _load_json(path: Path) -> dict[str, object]:
    try:
        loaded = json.loads(_read_text(path))
    except json.JSONDecodeError as exc:
        raise AssertionError(f"{path.name} is not valid JSON: {exc}") from exc
    if not isinstance(loaded, dict):
        raise AssertionError(f"{path.name} must contain a JSON object")
    return loaded


def _commit_matches(actual: str, expected: str) -> bool:
    return actual == expected or actual.startswith(expected) or expected.startswith(actual)


def _relative_names(root: Path) -> list[str]:
    return [
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file()
    ]


def _find_one(root: Path, basename: str) -> Path:
    matches = sorted(path for path in root.rglob(basename) if path.is_file())
    if not matches:
        raise AssertionError(f"{root} is missing {basename}")
    if len(matches) > 1:
        rendered = ", ".join(str(path.relative_to(root)) for path in matches)
        raise AssertionError(f"{root} contains duplicate {basename}: {rendered}")
    return matches[0]


def _optional_one(root: Path, basename: str) -> Path | None:
    matches = sorted(path for path in root.rglob(basename) if path.is_file())
    if len(matches) > 1:
        rendered = ", ".join(str(path.relative_to(root)) for path in matches)
        raise AssertionError(f"{root} contains duplicate {basename}: {rendered}")
    return matches[0] if matches else None


def _forbidden_content_reason(path: Path, data: bytes) -> str | None:
    for signature, label in CONTENT_SIGNATURES:
        if data.startswith(signature):
            return label
    if data.startswith(b"\x1f\x8b"):
        try:
            inflated = gzip.decompress(data)
        except OSError:
            inflated = b""
        for signature, label in CONTENT_SIGNATURES:
            if inflated.startswith(signature):
                return f"gzip-compressed {label}"
        if len(inflated) >= 0x8006 and inflated[0x8001:0x8006] == b"CD001":
            return "gzip-compressed ISO image"
        if (
            len(inflated) >= 512
            and inflated[510:512] == b"\x55\xaa"
            and b"FAT" in inflated[:512]
        ):
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


def validate_status_only_artifact_dir(artifact_dir: Path) -> None:
    if not artifact_dir.exists():
        raise AssertionError(f"artifact directory does not exist: {artifact_dir}")
    names = _relative_names(artifact_dir)
    if not names:
        raise AssertionError(f"artifact directory is empty: {artifact_dir}")
    for name in names:
        path = artifact_dir / name
        basename = path.name
        if not basename.endswith(STATUS_ONLY_SUFFIXES):
            raise AssertionError(f"forbidden non-text/json file in status-only artifact: {name}")
        for pattern in FORBIDDEN_PATTERNS:
            if fnmatch.fnmatchcase(basename, pattern):
                raise AssertionError(f"forbidden payload in status-only artifact: {name}")
        reason = _forbidden_content_reason(path, path.read_bytes())
        if reason is not None:
            raise AssertionError(f"forbidden artifact content in {name}: {reason}")


def validate_run_identity(
    artifact_dir: Path,
    *,
    workflow: str,
    artifact: str,
    expected_commit: str | None,
) -> dict[str, object]:
    identity = _load_json(_find_one(artifact_dir, RUN_IDENTITY))
    if identity.get("schema") != RUN_IDENTITY_SCHEMA:
        raise AssertionError(f"{RUN_IDENTITY} schema must be {RUN_IDENTITY_SCHEMA}")
    if identity.get("workflow") != workflow:
        raise AssertionError(f"{RUN_IDENTITY} workflow must be {workflow}")
    if identity.get("artifact") != artifact:
        raise AssertionError(f"{RUN_IDENTITY} artifact must be {artifact}")
    sha = identity.get("sha")
    if not isinstance(sha, str) or not sha:
        raise AssertionError(f"{RUN_IDENTITY} must record sha")
    if expected_commit and not _commit_matches(sha, expected_commit):
        raise AssertionError(f"{RUN_IDENTITY} sha {sha} does not match {expected_commit}")
    if identity.get("local_qemu_required") is not False:
        raise AssertionError(f"{RUN_IDENTITY} must record local_qemu_required=false")
    policy = identity.get("artifact_policy")
    if not isinstance(policy, dict):
        raise AssertionError(f"{RUN_IDENTITY} must include artifact_policy")
    for key in (
        "contains_wad_data",
        "contains_disk_image",
        "contains_screenshots",
        "contains_pixels",
        "contains_raw_audio",
    ):
        if policy.get(key) is not False:
            raise AssertionError(f"{RUN_IDENTITY} artifact_policy.{key} must be false")
    if policy.get("status_only") is not True:
        raise AssertionError(f"{RUN_IDENTITY} artifact_policy.status_only must be true")
    return identity


def validate_os_smoke_artifact(
    artifact_dir: Path,
    *,
    expected_commit: str | None = None,
) -> None:
    validate_status_only_artifact_dir(artifact_dir)
    validate_run_identity(
        artifact_dir,
        workflow=OS_WORKFLOW,
        artifact=OS_ARTIFACT,
        expected_commit=expected_commit,
    )
    status = _read_text(_find_one(artifact_dir, "status.txt"))
    try:
        check_vm_status_proof.validate_status(status, require_exec=True)
    except AssertionError as exc:
        raise AssertionError(f"OS smoke VM status proof failed: {exc}") from exc


def _real_wad_snapshots(artifact_dir: Path) -> tuple[dict[str, str], dict[str, Path]]:
    files = {
        "start": "status.after-start.txt",
        "fire": "status.after-fire.txt",
        "movement": "status.after-move.txt",
        "use": "status.after-use.txt",
        "mouse": "status.after-mouse.txt",
        "menu": "status.after-menu.txt",
        "final": "status.txt",
    }
    paths = {phase: _find_one(artifact_dir, name) for phase, name in files.items()}
    snapshots = {phase: _read_text(path) for phase, path in paths.items()}
    return snapshots, paths


def validate_real_wad_smoke_artifact(
    artifact_dir: Path,
    *,
    expected_commit: str | None = None,
    require_gameplay_proof: bool = False,
    require_audible_proof: bool = False,
    require_persistence_proof: bool = False,
) -> None:
    validate_status_only_artifact_dir(artifact_dir)
    validate_run_identity(
        artifact_dir,
        workflow=REAL_WAD_WORKFLOW,
        artifact=REAL_WAD_ARTIFACT,
        expected_commit=expected_commit,
    )
    snapshots, paths = _real_wad_snapshots(artifact_dir)
    status = snapshots["final"]
    try:
        check_real_wad_proof.validate_status(
            status,
            baseline_status=snapshots["start"],
            start_status=snapshots["start"],
            fire_status=snapshots["fire"],
            movement_status=snapshots["movement"],
            use_status=snapshots["use"],
            mouse_status=snapshots["mouse"],
            menu_status=snapshots["menu"],
        )
    except AssertionError as exc:
        raise AssertionError(f"real-WAD status proof failed: {exc}") from exc
    try:
        check_vm_status_proof.validate_status(status, require_exec=True, require_preempt=True)
    except AssertionError as exc:
        raise AssertionError(f"real-WAD VM status proof failed: {exc}") from exc
    try:
        check_audio_continuity_proof.validate_status(
            status,
            baseline_status=snapshots["start"],
            fire_status=snapshots["fire"],
            movement_status=snapshots["movement"],
            use_status=snapshots["use"],
            menu_status=snapshots["menu"],
            require_pull_stream=True,
        )
    except AssertionError as exc:
        raise AssertionError(f"real-WAD audio continuity proof failed: {exc}") from exc

    gameplay_path = _optional_one(artifact_dir, "gameplay-proof.json")
    if require_gameplay_proof and gameplay_path is None:
        raise AssertionError("real-WAD status artifact requires gameplay-proof.json")
    if gameplay_path is not None:
        try:
            check_scripted_gameplay_proof.validate_statuses(snapshots)
            check_scripted_gameplay_proof.validate_manifest(
                _load_json(gameplay_path),
                snapshots=snapshots,
                paths=paths,
            )
        except AssertionError as exc:
            raise AssertionError(f"scripted gameplay proof failed: {exc}") from exc

    audio_path = _optional_one(artifact_dir, "audio-proof.json")
    if require_audible_proof and audio_path is None:
        raise AssertionError("real-WAD status artifact requires audio-proof.json")
    if audio_path is not None:
        try:
            check_audible_audio_proof.validate_manifest(
                check_audible_audio_proof._load_manifest(audio_path)
            )
        except AssertionError as exc:
            raise AssertionError(f"audible audio proof failed: {exc}") from exc

    if require_persistence_proof:
        triage = triage_persistence_artifacts.triage_artifact_dir(artifact_dir)
        if triage.overall != "persistence-proof-green":
            raise AssertionError(
                "persistence proof triage was "
                f"{triage.overall}, expected persistence-proof-green"
            )


def validate_uefi_loader_artifact(
    artifact_dir: Path,
    *,
    expected_commit: str | None = None,
    require_exit_boot_services: bool = False,
) -> None:
    validate_status_only_artifact_dir(artifact_dir)
    validate_run_identity(
        artifact_dir,
        workflow=UEFI_WORKFLOW,
        artifact=UEFI_ARTIFACT,
        expected_commit=expected_commit,
    )
    manifest = _load_json(_find_one(artifact_dir, "ovmf-proof-manifest.json"))
    if manifest.get("schema") != "uefi-ovmf-cloud-proof-v1":
        raise AssertionError("UEFI manifest schema must be uefi-ovmf-cloud-proof-v1")
    if manifest.get("support_claim") != "unclaimed":
        raise AssertionError("UEFI manifest must keep support_claim=unclaimed")
    if manifest.get("support_row") != "SUPPORT[UEFI]":
        raise AssertionError("UEFI manifest must keep support_row=SUPPORT[UEFI]")
    if manifest.get("local_qemu_required") is not False:
        raise AssertionError("UEFI manifest must keep local_qemu_required=false")
    policy = manifest.get("artifact_policy")
    if not isinstance(policy, dict):
        raise AssertionError("UEFI manifest missing artifact_policy")
    for key in (
        "uploads_esp_image",
        "uploads_efi_binary",
        "uploads_pflash_vars",
        "uploads_pixel_dump",
        "uploads_raw_audio",
        "uploads_vm_logs",
    ):
        if policy.get(key) is not False:
            raise AssertionError(f"UEFI artifact_policy.{key} must be false")
    if policy.get("uploads_json_manifests_only") is not True:
        raise AssertionError("UEFI artifact policy must upload JSON manifests only")
    ovmf = manifest.get("ovmf")
    if not isinstance(ovmf, dict):
        raise AssertionError("UEFI manifest missing ovmf object")
    if ovmf.get("kernel_booted") is not False:
        raise AssertionError("UEFI loader proof must not claim kernel_booted=true")
    if require_exit_boot_services:
        if manifest.get("mode") != "prove":
            raise AssertionError("UEFI loader proof artifact must come from mode=prove")
        if ovmf.get("exit_boot_services") is not True:
            raise AssertionError("UEFI loader proof did not reach ExitBootServices")
        if ovmf.get("proof") != "exit-boot-services":
            raise AssertionError("UEFI loader proof must record proof=exit-boot-services")
        if ovmf.get("debugcon_uploaded") is not False:
            raise AssertionError("UEFI loader proof must not upload raw debugcon logs")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate post-merge status-only cloud proof artifacts."
    )
    parser.add_argument("--expected-commit", help="expected workflow commit SHA or prefix")
    parser.add_argument("--os", type=Path, help="downloaded aurora-os-smoke-proof-status dir")
    parser.add_argument("--real-wad", type=Path, help="downloaded real-wad-smoke-proof-status dir")
    parser.add_argument("--uefi", type=Path, help="downloaded uefi-ovmf-proof-manifests dir")
    parser.add_argument(
        "--require-real-wad-gameplay-proof",
        action="store_true",
        help="require and validate gameplay-proof.json in the real-WAD artifact",
    )
    parser.add_argument(
        "--require-audible-proof",
        action="store_true",
        help="require and validate audio-proof.json in the real-WAD artifact",
    )
    parser.add_argument(
        "--require-persistence-proof",
        action="store_true",
        help="require persistence status files to triage as persistence-proof-green",
    )
    parser.add_argument(
        "--require-uefi-exit-boot-services",
        action="store_true",
        help="require the UEFI proof manifest to be mode=prove and reach ExitBootServices",
    )
    args = parser.parse_args(argv)

    try:
        checked: list[str] = []
        if args.os is not None:
            validate_os_smoke_artifact(args.os, expected_commit=args.expected_commit)
            checked.append("os-smoke")
        if args.real_wad is not None:
            validate_real_wad_smoke_artifact(
                args.real_wad,
                expected_commit=args.expected_commit,
                require_gameplay_proof=args.require_real_wad_gameplay_proof,
                require_audible_proof=args.require_audible_proof,
                require_persistence_proof=args.require_persistence_proof,
            )
            checked.append("real-wad-smoke")
        if args.uefi is not None:
            validate_uefi_loader_artifact(
                args.uefi,
                expected_commit=args.expected_commit,
                require_exit_boot_services=args.require_uefi_exit_boot_services,
            )
            checked.append("uefi-ovmf-proof")
        if not checked:
            raise AssertionError("pass at least one artifact directory to check")
    except (OSError, AssertionError) as exc:
        print(f"post-merge cloud artifact check failed: {exc}", file=sys.stderr)
        return 1

    print("post-merge cloud artifact check OK: " + ", ".join(checked))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
