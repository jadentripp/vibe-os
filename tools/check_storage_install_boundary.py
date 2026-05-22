#!/usr/bin/env python3
"""Validate vibe-os storage install/recovery claim boundaries.

The current proof can mutate and reboot the repo-generated FAT16 image in
cloud QEMU. This checker keeps that claim separate from a future installer for
arbitrary disks, and can also inspect a generated image layout without running
QEMU.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILD = Path(os.environ.get("VIBE_HOST_TEST_BUILD_DIR") or ROOT / "build")
DOC = ROOT / "docs" / "architecture.txt"
MAKE_WAD_IMAGE = ROOT / "tools" / "make_wad_image.py"
SECTOR_SIZE = 512


def _configured_build_dir(root: Path = ROOT) -> Path:
    if root == ROOT and os.environ.get("VIBE_HOST_TEST_BUILD_DIR"):
        return BUILD
    return root / "build"


def sector_offset(lba: int) -> int:
    return lba * SECTOR_SIZE

EXPECTED_BOUNDARIES = {
    "GENERATED_FAT16_IMAGE": {
        "status": "claimed",
        "scope": "repo-built-raw-image",
        "gate": "layout-manifest-plus-fat-checkers",
        "evidence": "disk-img-status",
    },
    "CLOUD_MUTATE_REBOOT": {
        "status": "proven",
        "scope": "disposable-qemu-disk-image",
        "gate": "reboot-persistence-proof",
        "evidence": "real-wad-smoke-26203744974",
    },
    "HOST_RECOVERY_INSPECTION": {
        "status": "claimed",
        "scope": "host-generated-image-inspection",
        "gate": "install-image-manifest",
        "evidence": "check_storage_install_boundary.py",
    },
    "BLANK_IMAGE_HOST_INSTALL": {
        "status": "proven",
        "scope": "in-memory-blank-disk-image",
        "gate": "blank-disk-installer-manifest",
        "evidence": "check_storage_install_boundary.py",
    },
    "DAMAGED_IMAGE_REFUSAL": {
        "status": "proven",
        "scope": "repo-layout-damaged-fixtures",
        "gate": "damaged-image-refusal-report",
        "evidence": "check_storage_install_boundary.py",
    },
    "ARBITRARY_DISK_INSTALL": {
        "status": "unclaimed",
        "scope": "none",
        "gate": "future-installer-proof",
        "evidence": "none",
    },
    "ARBITRARY_DISK_RECOVERY": {
        "status": "unclaimed",
        "scope": "none",
        "gate": "future-recovery-proof",
        "evidence": "none",
    },
}

EXPECTED_REQUIREMENTS = {
    "INSTALLER": {
        "status": "future",
        "artifact": "installer-cloud-disk",
        "requires": "blank-disk-to-bootable-vibe-os",
        "evidence": "none",
    },
    "RECOVERY": {
        "status": "future",
        "artifact": "damaged-image-recovery-report",
        "requires": "detect-and-repair-or-refuse",
        "evidence": "none",
    },
    "ARBITRARY_MEDIA": {
        "status": "future",
        "artifact": "media-matrix-proof",
        "requires": "explicit-device-and-layout-rows",
        "evidence": "none",
    },
}

EXPECTED_SUBSYSTEM_ROWS = {
    "PATH_NORMALIZATION": {
        "status": "host-proven",
        "scope": "root-current-dir-8.3-and-one-level-subdirectory",
        "gate": "fat-vfs-boundary",
        "evidence": "install-image-manifest",
    },
    "DIRECTORY_READ_BOUNDARY": {
        "status": "host-proven",
        "scope": "root-plus-one-level-list-read",
        "gate": "filesystem-tree-manifest",
        "evidence": "check_storage_install_boundary.py",
    },
    "ROOT_WRITE_TRUNCATE_DELETE": {
        "status": "host-proven",
        "scope": "dynamic-root-8.3-files",
        "gate": "dynamic-root-lifecycle",
        "evidence": "check_doom_persistence_image.py",
    },
    "SUBDIRECTORY_WRITE_TRUNCATE_DELETE": {
        "status": "host-proven",
        "scope": "one-level-writable-state-dir-8.3-files",
        "gate": "dynamic-subdirectory-lifecycle",
        "evidence": "check_storage_install_boundary.py",
    },
    "FREE_SPACE_ACCOUNTING": {
        "status": "host-proven",
        "scope": "fat16-data-clusters",
        "gate": "cluster-accounting-manifest",
        "evidence": "install-image-manifest",
    },
    "FAILURE_ATOMICITY": {
        "status": "host-proven",
        "scope": "no-space-allocation-refusal",
        "gate": "dynamic-root-lifecycle",
        "evidence": "make_wad_image.py",
    },
    "READONLY_ASSET_MUTATION_REFUSAL": {
        "status": "host-proven",
        "scope": "packaged-subdirectory-assets",
        "gate": "fat-vfs-boundary",
        "evidence": "install-image-manifest",
    },
}

REQUIRED_PHRASES = (
    "not an installable general OS on arbitrary disks",
    "mutates and reboots the repo-generated FAT16 image",
    "does not partition a blank disk",
    "does not discover arbitrary existing partitions",
    "does not repair corrupted user disks",
    "LBA 0 is the repo MBR",
    "LBA 2048 is the FAT16 partition",
    "install-image-manifest",
    "artifact-integrity manifest",
    "bootable-image-construction manifest",
    "fat-vfs-boundary manifest",
    "dynamic-root-lifecycle manifest",
    "STORAGE_SUBSYSTEM[PATH_NORMALIZATION] status=host-proven",
    "STORAGE_SUBSYSTEM[FAILURE_ATOMICITY] status=host-proven",
    "root 8.3 plus read-only assets and writable one-level state directory",
    "dynamic-subdirectory-lifecycle manifest",
    "live FAT accounting status",
    "ABIPROBE.ELF exercises that path",
    "USER_RUNTIME_CONTRACT[GENERIC_STATE_FILE]",
    "host image inventory may walk deeper packaged trees than the kernel syscall surface",
    "blank-disk-installer-manifest",
    "blank-image-file materialization manifest",
    "damaged-image-refusal-report",
    "structural boot proof without running QEMU locally",
    "all-zero image",
    "blank-disk-to-bootable-vibe-os",
    "detect-and-repair-or-refuse",
)

REQUIRED_CROSS_DOC_LINKS = {
    "README.md": (
        "not an installable OS for arbitrary disks",
        "does not partition blank media",
        "docs/architecture.txt",
    ),
    "docs/architecture.txt": (
        "not an arbitrary-disk install or recovery proof",
        "install-image-manifest",
    ),
    "docs/proof.txt": (
        "STORAGE_BOUNDARY[ARBITRARY_DISK_INSTALL] status=unclaimed",
        "blank-disk-to-bootable-vibe-os",
    ),
    "tests/strategy.txt": (
        "tools/check_storage_install_boundary.py",
        "install-image-manifest",
    ),
}

OVERCLAIM_PATTERNS = (
    re.compile(r"\binstallable\s+(?:general\s+)?OS\b", re.IGNORECASE),
    re.compile(
        r"\binstalls?\s+(?:to|onto)\s+(?:an?\s+)?"
        r"(?:arbitrary|blank|physical|real|user|external)\s+(?:disk|drive|media)\b",
        re.IGNORECASE,
    ),
    re.compile(r"\barbitrary[- ]disk\s+install\b", re.IGNORECASE),
    re.compile(r"\binstall[- ]to[- ]arbitrary[- ]disk\b", re.IGNORECASE),
    re.compile(
        r"\brecovers?\s+(?:damaged|corrupted|unknown|user)\s+"
        r"(?:disk|drive|media|filesystem|file system)s?\b",
        re.IGNORECASE,
    ),
    re.compile(r"\barbitrary[- ]disk\s+recovery\b", re.IGNORECASE),
    re.compile(r"\brecovery\s+support\b", re.IGNORECASE),
)

NEGATIVE_CONTEXT = (
    "not ",
    "no ",
    "without ",
    "outside ",
    "unclaimed",
    "unsupported",
    "future ",
    "do not ",
    "does not ",
    "cannot ",
    "before ",
    "until ",
    "rather than ",
    "separate from ",
)

ROW_RE = re.compile(r"^- `(?P<kind>[A-Z_]+)\[(?P<name>[A-Z0-9_]+)\] (?P<fields>.+)`$", re.MULTILINE)


class StorageBoundaryError(AssertionError):
    pass


def load_make_wad_image():
    spec = importlib.util.spec_from_file_location("make_wad_image", MAKE_WAD_IMAGE)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def parse_key_values(raw: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for part in raw.split():
        if "=" not in part:
            raise StorageBoundaryError(f"malformed field {part!r}")
        key, value = part.split("=", 1)
        fields[key] = value
    return fields


def parse_rows(text: str, kind: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in ROW_RE.finditer(text):
        if match.group("kind") != kind:
            continue
        name = match.group("name")
        if name in rows:
            raise StorageBoundaryError(f"duplicate {kind}[{name}] row")
        rows[name] = parse_key_values(match.group("fields"))
    return rows


def require_expected_rows(rows: dict[str, dict[str, str]], expected: dict[str, dict[str, str]], kind: str) -> None:
    missing = sorted(set(expected) - set(rows))
    extra = sorted(set(rows) - set(expected))
    if missing:
        raise StorageBoundaryError(f"missing {kind} rows: {', '.join(missing)}")
    if extra:
        raise StorageBoundaryError(f"unexpected {kind} rows: {', '.join(extra)}")
    for name, expected_fields in expected.items():
        for key, value in expected_fields.items():
            actual = rows[name].get(key)
            if actual != value:
                raise StorageBoundaryError(
                    f"{kind}[{name}] {key}= expected {value!r}, got {actual!r}"
                )


def contains_phrase(text: str, phrase: str) -> bool:
    return " ".join(phrase.split()) in " ".join(text.split())


def repo_text_files(root: Path) -> list[Path]:
    files = [root / "README.md", root / "tests" / "strategy.txt"]
    docs = set((root / "docs").rglob("*.md"))
    docs.update((root / "docs").rglob("*.txt"))
    files.extend(sorted(docs))
    files.extend(sorted((root / "tests").rglob("test_*.py")))
    files.append(root / "tools" / "check_storage_install_boundary.py")
    return [path for path in files if path.exists()]


def has_negative_context(line: str) -> bool:
    lower = line.lower()
    return any(token in lower for token in NEGATIVE_CONTEXT)


def validate_cross_doc_links(root: Path) -> None:
    for relative_path, phrases in REQUIRED_CROSS_DOC_LINKS.items():
        text = (root / relative_path).read_text(encoding="utf-8")
        for phrase in phrases:
            if not contains_phrase(text, phrase):
                raise StorageBoundaryError(f"{relative_path} missing storage-boundary phrase: {phrase}")


def validate_claim_wording(root: Path) -> None:
    for path in repo_text_files(root):
        rel = path.relative_to(root)
        lines = path.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            line_number = index + 1
            context = " ".join(lines[max(0, index - 1) : min(len(lines), index + 2)])
            for pattern in OVERCLAIM_PATTERNS:
                if pattern.search(line) and not has_negative_context(context):
                    raise StorageBoundaryError(
                        f"{rel}:{line_number}: possible unbounded storage install/recovery claim: {line.strip()}"
                    )


def validate_repo_contract(root: Path = ROOT) -> dict[str, dict[str, str]]:
    doc = root / "docs" / "architecture.txt"
    text = doc.read_text()
    normalized = " ".join(text.split())
    for phrase in REQUIRED_PHRASES:
        if " ".join(phrase.split()) not in normalized:
            raise StorageBoundaryError(f"missing required storage boundary phrase: {phrase}")

    boundaries = parse_rows(text, "STORAGE_BOUNDARY")
    requirements = parse_rows(text, "STORAGE_PROOF_REQUIREMENT")
    subsystems = parse_rows(text, "STORAGE_SUBSYSTEM")
    require_expected_rows(boundaries, EXPECTED_BOUNDARIES, "STORAGE_BOUNDARY")
    require_expected_rows(requirements, EXPECTED_REQUIREMENTS, "STORAGE_PROOF_REQUIREMENT")
    require_expected_rows(subsystems, EXPECTED_SUBSYSTEM_ROWS, "STORAGE_SUBSYSTEM")
    validate_cross_doc_links(root)
    validate_claim_wording(root)
    return boundaries


def _u16(raw: bytes | bytearray, offset: int) -> int:
    return int.from_bytes(raw[offset:offset + 2], "little")


def _u32(raw: bytes | bytearray, offset: int) -> int:
    return int.from_bytes(raw[offset:offset + 4], "little")


def _require_zero_region(raw: bytes | bytearray, start: int, end: int, label: str) -> None:
    if any(raw[start:end]):
        raise StorageBoundaryError(f"{label} must be zero-filled")


def _sha256(raw: bytes | bytearray) -> str:
    return hashlib.sha256(bytes(raw)).hexdigest()


def _fat_file_cluster_count(fs, meta: dict[str, object]) -> int:
    if int(meta["size"]) == 0:
        return 0
    return len(fs.cluster_chain(int(meta["cluster"])))


def _filesystem_tree_manifest(fs, make_wad_image) -> tuple[list[dict[str, object]], dict[str, object]]:
    entries: list[dict[str, object]] = []
    file_count = 0
    directory_count = 0
    total_file_bytes = 0
    file_clusters = 0

    def walk(path: tuple[bytes, ...]) -> None:
        nonlocal file_count, directory_count, total_file_bytes, file_clusters
        for meta in fs.list_directory(path):
            name = meta["name"]
            if name in (b".          ", b"..         "):
                continue
            child_path = path + (name,)
            entry = {
                "path": make_wad_image.Fat16Image._path_label(child_path),
                "name": make_wad_image.Fat16Image._entry_label(name),
                "attr": f"0x{meta['attr']:02x}",
                "cluster": meta["cluster"],
                "size": meta["size"],
                "directory": bool(meta["is_directory"]),
                "depth": len(child_path),
            }
            if meta["is_directory"]:
                directory_count += 1
                entries.append(entry)
                walk(child_path)
                continue

            data = fs.read_file_at_path(child_path)
            clusters = _fat_file_cluster_count(fs, meta)
            file_count += 1
            total_file_bytes += int(meta["size"])
            file_clusters += clusters
            entry.update(
                {
                    "clusters": clusters,
                    "sha256": _sha256(data),
                }
            )
            entries.append(entry)

    walk(())
    return entries, {
        "files": file_count,
        "directories": directory_count,
        "file_bytes": total_file_bytes,
        "file_clusters": file_clusters,
    }


def _normalize_path_samples(make_wad_image, samples: tuple[str, ...]) -> dict[str, object]:
    normalized = [
        make_wad_image.Fat16Image._path_label(
            make_wad_image.fat83_path_from_display_path(sample)
        )
        for sample in samples
    ]
    if len(set(normalized)) != 1:
        raise StorageBoundaryError(
            "FAT16 path normalization samples did not resolve to one 8.3 path: "
            + ", ".join(normalized)
        )
    return {
        "samples": list(samples),
        "normalized_path": normalized[0],
        "all_samples_match": True,
    }


def _rejected_path_samples(make_wad_image, samples: tuple[str, ...]) -> list[dict[str, str]]:
    rejected = []
    for sample in samples:
        try:
            make_wad_image.fat83_path_from_display_path(sample)
        except ValueError as exc:
            rejected.append({"sample": sample, "reason": str(exc)})
        else:
            raise StorageBoundaryError(f"unsupported FAT16 path sample was accepted: {sample}")
    return rejected


def _fat_vfs_boundary_manifest(fs, make_wad_image, packaged_assets: list[dict[str, object]]) -> dict[str, object]:
    kernel_source = (ROOT / "kernel" / "kernel.asm").read_text(encoding="utf-8")
    abi_probe_source = (ROOT / "user" / "abi_probe.c").read_text(encoding="utf-8")
    try:
        open_wad_section = kernel_source.split(".open_flags_ok:", 1)[1].split(".open_writable:", 1)[0]
        resize_section = kernel_source.split("fat_resize_writable_file:", 1)[1].split("fat_clip_writable_chain_to_size:", 1)[0]
        truncate_section = kernel_source.split("fat_truncate_writable_file:", 1)[1].split("fat_zero_writable_range:", 1)[0]
        delete_section = kernel_source.split("fat_delete_found_file:", 1)[1].split("stat_fill_user:", 1)[0]
        ftruncate_section = kernel_source.split(".ftruncate:", 1)[1].split(".mmap:", 1)[0]
        fat_accounting_section = kernel_source.split("fat_refresh_cluster_accounting:", 1)[1].split("fat_build_alloc_map:", 1)[0]
    except IndexError as exc:
        raise StorageBoundaryError("kernel FAT/VFS lifecycle sections were not found") from exc

    readonly_wad_uses_generic_descriptor = (
        "jmp .open_generic_parse_root83" in open_wad_section
        and "mov byte [fd_kinds + eax], FD_KIND_WAD" not in open_wad_section
        and "readonly_fd_is_wad_file:" in kernel_source
    )
    truncate_metadata_before_free = (
        "call fat_update_writable_size" in truncate_section
        and "call fat_free_chain" in truncate_section
        and truncate_section.index("call fat_update_writable_size") < truncate_section.index("call fat_free_chain")
    )
    delete_entry_before_free = (
        "call block_selected_write_sector" in delete_section
        and "call fat_free_chain" in delete_section
        and delete_section.index("call block_selected_write_sector") < delete_section.index("call fat_free_chain")
    )
    shrink_metadata_before_free = (
        "call fat_update_writable_size" in resize_section
        and "call fat_clip_writable_chain_to_size" in resize_section
        and "call fat_zero_writable_tail_after_size" in resize_section
        and resize_section.index("call fat_update_writable_size") < resize_section.index("call fat_clip_writable_chain_to_size")
        and resize_section.index("call fat_clip_writable_chain_to_size") < resize_section.index("call fat_zero_writable_tail_after_size")
    )
    write_no_progress_rollback = (
        "fat_rollback_file_write_no_progress:" in kernel_source
        and ".fail_io_no_progress:\n    call fat_rollback_file_write_no_progress" in kernel_source
    )
    ftruncate_reports_enospc = (
        "ERRNO_ENOSPC equ 28" in kernel_source
        and ".bad_syscall_enospc:" in kernel_source
        and "ja .bad_syscall_enospc" in ftruncate_section
    )
    live_fat_accounting_tokens = (
        "mov dword [fat_account_free_clusters], 0",
        "mov dword [fat_account_used_clusters], 0",
        "mov dword [fat_accounted_clusters], 0",
        "mov dword [fat_account_status], 0xffffffff",
        "cmp byte [fat_status], 1",
        "call fat_next_cluster",
        "cmp ax, 0",
        "inc dword [fat_account_free_clusters]",
        "inc dword [fat_account_used_clusters]",
        "inc dword [fat_accounted_clusters]",
        "mov dword [fat_account_status], 0",
    )
    missing_accounting_tokens = [
        token for token in live_fat_accounting_tokens
        if token not in fat_accounting_section
    ]
    if missing_accounting_tokens:
        raise StorageBoundaryError(
            "kernel FAT live accounting status no longer rescans the FAT cache: "
            + ", ".join(missing_accounting_tokens)
        )
    if kernel_source.count("call fat_refresh_cluster_accounting") < 2:
        raise StorageBoundaryError("kernel FAT live accounting is not refreshed at init and status time")
    if "smoke_fatacct_text db \" fatacct=\", 0" not in kernel_source:
        raise StorageBoundaryError("kernel status is missing fatacct= live FAT accounting field")
    abi_generic_file_probe_tokens = (
        "prove_generic_file_services",
        'const char asset_file[] = "./assets/readme.txt";',
        'const char state_file[] = "./state/session.dat";',
        "vibe_user_listdir(asset_dir, entries, 16)",
        "vibe_user_file_read_all(asset_file, buffer, sizeof(buffer), &bytes_read)",
        "vibe_user_file_read_at(asset_file, 8, buffer, 5, &bytes_read)",
        "VIBE_USER_O_CREAT | VIBE_USER_O_RDWR | VIBE_USER_O_TRUNC",
        "vibe_user_ftruncate(fd, 4)",
        "vibe_user_unlink(state_file)",
        "flags |= ABI_PROBE_FLAG_FILES;",
    )
    missing_abi_tokens = [
        token for token in abi_generic_file_probe_tokens
        if token not in abi_probe_source
    ]
    if missing_abi_tokens:
        raise StorageBoundaryError(
            "ABI probe no longer proves generic FAT/VFS file behavior: "
            + ", ".join(missing_abi_tokens)
        )

    readme_path = make_wad_image.ASSET_README_PATH
    readme_label = make_wad_image.Fat16Image._path_label(readme_path)
    readme_meta = fs.entry_metadata_at_path(readme_path)
    if readme_meta is None:
        raise StorageBoundaryError(f"generated FAT16 image is missing {readme_label}")
    if readme_meta["is_directory"]:
        raise StorageBoundaryError(f"generated FAT16 {readme_label} is a directory")
    readme_bytes = fs.read_file_at_path(readme_path)
    if readme_bytes != make_wad_image.ASSET_README_BYTES:
        raise StorageBoundaryError(f"generated FAT16 {readme_label} bytes did not round-trip")

    mutation_refusals = []
    for operation, mutate in (
        ("write", lambda: fs.write_file_at_path(readme_path, b"mutate")),
        ("create", lambda: fs.create_file_at_path(readme_path)),
        ("truncate", lambda: fs.truncate_file_at_path(readme_path)),
        ("unlink", lambda: fs.delete_file_at_path(readme_path)),
    ):
        try:
            mutate()
        except PermissionError as exc:
            mutation_refusals.append({"operation": operation, "result": "refused", "reason": str(exc)})
        except Exception as exc:
            raise StorageBoundaryError(
                f"generated FAT16 {readme_label} readonly {operation} returned {type(exc).__name__}: {exc}"
            ) from exc
        else:
            raise StorageBoundaryError(f"generated FAT16 {readme_label} allowed readonly {operation}")
    if fs.read_file_at_path(readme_path) != readme_bytes:
        raise StorageBoundaryError(f"generated FAT16 {readme_label} changed during mutation refusal")

    nested_host_inventory = [
        {
            "path": entry["path"],
            "depth": entry["depth"],
            "kernel_syscall_claim": "unsupported-nested-traversal",
        }
        for entry in packaged_assets
        if int(entry["depth"]) > 2
    ]
    dynamic_root_lifecycle = {
        "schema": "vibe-os-dynamic-root-lifecycle-v1",
        **make_wad_image.prove_dynamic_fat16_mutation(
            make_wad_image.Fat16Image(bytearray(fs.image))
        ),
    }
    dynamic_subdirectory_lifecycle = {
        "schema": "vibe-os-dynamic-subdirectory-lifecycle-v1",
        **make_wad_image.prove_subdirectory_file_mutation(
            make_wad_image.Fat16Image(bytearray(fs.image))
        ),
    }

    return {
        "schema": "vibe-os-fat-vfs-boundary-v1",
        "host_checked": True,
        "proof_rows": [
            "STORAGE_SUBSYSTEM[PATH_NORMALIZATION]",
            "STORAGE_SUBSYSTEM[DIRECTORY_READ_BOUNDARY]",
            "STORAGE_SUBSYSTEM[ROOT_WRITE_TRUNCATE_DELETE]",
            "STORAGE_SUBSYSTEM[SUBDIRECTORY_WRITE_TRUNCATE_DELETE]",
            "STORAGE_SUBSYSTEM[FREE_SPACE_ACCOUNTING]",
            "STORAGE_SUBSYSTEM[FAILURE_ATOMICITY]",
            "STORAGE_SUBSYSTEM[READONLY_ASSET_MUTATION_REFUSAL]",
        ],
        "kernel_syscall_surface": {
            "supported_path_contract": "root 8.3 plus read-only assets and writable one-level state directory",
            "root_normalization": _normalize_path_samples(
                make_wad_image,
                ("README.TXT", "/README.TXT", "\\README.TXT", "./README.TXT"),
            ),
            "one_level_subdirectory_normalization": _normalize_path_samples(
                make_wad_image,
                (
                    "ASSETS/README.TXT",
                    "/ASSETS/README.TXT",
                    "\\ASSETS\\README.TXT",
                    "./assets/readme.txt",
                ),
            ),
            "writable_subdirectory_normalization": _normalize_path_samples(
                make_wad_image,
                (
                    "STATE/SESSION.DAT",
                    "/STATE/SESSION.DAT",
                    "\\STATE\\SESSION.DAT",
                    "./state/session.dat",
                ),
            ),
            "unsupported_path_samples": _rejected_path_samples(
                make_wad_image,
                (
                    "",
                    "/",
                    "/ASSETS/../README.TXT",
                    "/ASSETS/README.LONG",
                    "/TOOLONGNAME.TXT",
                    "/BAD+NAME.TXT",
                ),
            ),
            "nested_traversal_supported": False,
            "writable_subdirectories_supported": True,
            "writable_subdirectory_scope": "pre-existing non-read-only one-level directories",
            "long_filenames_supported": False,
            "readonly_wad_uses_generic_descriptor": readonly_wad_uses_generic_descriptor,
        },
        "error_classification": {
            "directory_open_or_unlink_as_file": "EISDIR",
            "list_regular_file_as_directory": "ENOTDIR",
            "capacity_exhaustion": "ENOSPC",
            "ftruncate_reports_enospc": ftruncate_reports_enospc,
        },
        "directory_entry_lifecycle": {
            "schema": "vibe-os-fat16-directory-entry-lifecycle-v1",
            "truncate_metadata_before_free": truncate_metadata_before_free,
            "shrink_metadata_before_tail_free": shrink_metadata_before_free,
            "shrink_tail_zero_after_metadata_commit": shrink_metadata_before_free,
            "delete_entry_before_free": delete_entry_before_free,
            "write_no_progress_rollback": write_no_progress_rollback,
            "late_free_failure_residual_risk": "cluster-leak-not-live-entry-to-freed-chain",
        },
        "live_fat_accounting_status": {
            "schema": "vibe-os-fat16-live-accounting-status-v1",
            "field": "fatacct",
            "source": "kernel-fat-cache-rescan",
            "counts": ["free_clusters", "used_clusters", "accounted_clusters", "last_data_cluster", "status"],
            "refreshed_at_init": True,
            "refreshed_at_status": True,
            "not_fixed_slot_accounting": True,
        },
        "user_abi_probe": {
            "schema": "vibe-os-user-abi-generic-file-proof-v1",
            "program": "ABIPROBE.ELF",
            "asset_read_path": "/ASSETS/README.TXT",
            "state_mutation_path": "/STATE/SESSION.DAT",
            "uses_common_syscalls": [
                "listdir",
                "open",
                "read",
                "write",
                "fstat",
                "ftruncate",
                "unlink",
            ],
            "host_checked_source_tokens": True,
            "not_doom_specific": True,
        },
        "dynamic_root_lifecycle": dynamic_root_lifecycle,
        "dynamic_subdirectory_lifecycle": dynamic_subdirectory_lifecycle,
        "read_only_one_level_subdirectory": {
            "path": readme_label,
            "size": readme_meta["size"],
            "cluster": readme_meta["cluster"],
            "sha256": _sha256(readme_bytes),
            "mutation_refusals": mutation_refusals,
        },
        "host_image_inventory": {
            "recursive_tree_walk_supported": True,
            "nested_packaged_entries": nested_host_inventory,
            "claim_boundary": (
                "host image inventory may walk deeper packaged trees than the "
                "kernel syscall surface"
            ),
        },
        "claim_boundary": "fat-vfs-boundary-host-proof; not full-posix-filesystem-proof",
    }


def _read_artifact(path: Path, label: str) -> bytes:
    if not path.is_file():
        raise StorageBoundaryError(f"missing {label} artifact: {path}")
    return path.read_bytes()


def _require_artifact_region(
    image: bytes | bytearray,
    *,
    lba: int,
    sectors: int,
    path: Path,
    label: str,
) -> dict[str, object]:
    data = _read_artifact(path, label)
    capacity = sectors * SECTOR_SIZE
    if len(data) > capacity:
        raise StorageBoundaryError(f"{label} artifact is {len(data)} bytes, exceeds {capacity}")
    start = sector_offset(lba)
    region = image[start:start + capacity]
    if region[:len(data)] != data:
        raise StorageBoundaryError(f"{label} installed bytes do not match artifact {path}")
    _require_zero_region(region, len(data), len(region), f"{label} padding")
    return {
        "label": label,
        "path": str(path),
        "sha256": _sha256(data),
        "bytes": len(data),
        "lba": lba,
        "sectors": sectors,
        "capacity": capacity,
        "padded_zero_bytes": capacity - len(data),
        "matches_installed_region": True,
    }


def _expected_installed_mbr(stage1_path: Path) -> bytes:
    make_wad_image = load_make_wad_image()
    mbr = bytearray(_read_artifact(stage1_path, "stage1"))
    if len(mbr) != make_wad_image.SECTOR_SIZE:
        raise StorageBoundaryError(
            f"stage1 artifact is {len(mbr)} bytes, expected {make_wad_image.SECTOR_SIZE}"
        )
    mbr[440:444] = b"AOSD"
    entry = 446
    mbr[entry + 0] = 0x00
    mbr[entry + 1:entry + 4] = b"\x01\x01\x00"
    mbr[entry + 4] = 0x06
    mbr[entry + 5:entry + 8] = b"\xfe\xff\xff"
    write_le32 = make_wad_image.write_le32
    write_le16 = make_wad_image.write_le16
    write_le32(mbr, entry + 8, make_wad_image.PARTITION_START)
    write_le32(mbr, entry + 12, make_wad_image.PARTITION_SECTORS)
    write_le16(mbr, 510, 0xAA55)
    return bytes(mbr)


def _default_boot_artifact_inputs(root: Path = ROOT) -> dict[str, Path]:
    build = _configured_build_dir(root)
    inputs = {
        "stage1_path": build / "stage1.bin",
        "stage2_path": build / "stage2.bin",
        "kernel_path": build / "kernel.elf",
    }
    for label, path in (
        ("stage1", inputs["stage1_path"]),
        ("stage2", inputs["stage2_path"]),
        ("kernel", inputs["kernel_path"]),
    ):
        _read_artifact(path, label)
    return inputs


def _artifact_integrity_manifest(
    image: bytes | bytearray,
    artifact_inputs: dict[str, object],
) -> dict[str, object]:
    make_wad_image = load_make_wad_image()
    stage1_path = artifact_inputs["stage1_path"]
    expected_mbr = _expected_installed_mbr(stage1_path)
    installed_mbr = bytes(image[:make_wad_image.SECTOR_SIZE])
    if installed_mbr != expected_mbr:
        raise StorageBoundaryError("MBR/stage1 installed bytes do not match patched stage1 artifact")

    raw_regions = [
        _require_artifact_region(
            image,
            lba=make_wad_image.STAGE2_LBA,
            sectors=make_wad_image.STAGE2_SECTORS,
            path=artifact_inputs["stage2_path"],
            label="stage2",
        ),
        _require_artifact_region(
            image,
            lba=make_wad_image.KERNEL_LBA,
            sectors=make_wad_image.KERNEL_SECTORS,
            path=artifact_inputs["kernel_path"],
            label="kernel",
        ),
    ]
    return {
        "schema": "vibe-os-image-artifact-integrity-v1",
        "image_sha256": _sha256(image),
        "all_match": True,
        "stage1_mbr": {
            "label": "mbr-stage1-partition-table",
            "path": str(stage1_path),
            "artifact_sha256": _sha256(_read_artifact(stage1_path, "stage1")),
            "installed_sha256": _sha256(installed_mbr),
            "bytes": make_wad_image.SECTOR_SIZE,
            "lba": 0,
            "sectors": 1,
            "matches_patched_artifact": True,
        },
        "raw_regions": raw_regions,
        "declared_write_ranges": list(_declared_install_write_ranges(make_wad_image)),
        "claim_boundary": "repo-build-artifact-identity-only; not arbitrary-media-proof",
    }


def _artifact_input_roles(artifact_inputs: dict[str, object]) -> list[dict[str, object]]:
    role_specs = (
        ("stage1", "stage1_path"),
        ("stage2", "stage2_path"),
        ("kernel", "kernel_path"),
        ("user-probe-elf", "user_elf_path"),
        ("doom-elf", "doom_elf_path"),
    )
    roles = []
    for role, key in role_specs:
        path = artifact_inputs.get(key)
        if path is None:
            continue
        roles.append({"role": role, "path": str(path)})
    for name, path in artifact_inputs.get("extra_root_elves", ()):
        roles.append(
            {
                "role": "extra-root-elf",
                "fat83_name": load_make_wad_image().Fat16Image._entry_label(name),
                "path": str(path),
            }
        )
    return roles


def _bootable_image_construction_manifest(
    make_wad_image,
    image_label: str,
    artifact_inputs: dict[str, object],
) -> dict[str, object]:
    return {
        "schema": "vibe-os-bootable-image-construction-v1",
        "image": image_label,
        "output_kind": "fixed-size raw BIOS MBR disk image with FAT16 partition",
        "image_size": make_wad_image.IMAGE_SECTORS * make_wad_image.SECTOR_SIZE,
        "qemu_executed_by_checker": False,
        "source_artifact_roles": _artifact_input_roles(artifact_inputs),
        "boot_flow": [
            {
                "component": "stage1-mbr",
                "lba": 0,
                "sectors": 1,
                "construction": "stage1 artifact patched with repo disk id and fixed FAT16 partition entry",
            },
            {
                "component": "stage2",
                "lba": make_wad_image.STAGE2_LBA,
                "sectors": make_wad_image.STAGE2_SECTORS,
                "construction": "raw artifact copied into a zero-padded reserved boot region",
            },
            {
                "component": "kernel",
                "lba": make_wad_image.KERNEL_LBA,
                "sectors": make_wad_image.KERNEL_SECTORS,
                "construction": "raw kernel ELF copied into a zero-padded staging region",
            },
            {
                "component": "fat16-payload",
                "lba": make_wad_image.PARTITION_START,
                "sectors": make_wad_image.PARTITION_SECTORS,
                "construction": "FAT16 partition containing root ELF entries, writable root 8.3 state, writable one-level game state, and packaged read-only assets",
            },
        ],
        "declared_write_ranges": list(_declared_install_write_ranges(make_wad_image)),
        "unsupported_targets": [
            "arbitrary existing disks",
            "unknown partition tables",
            "partial-device installs",
            "in-place user-data preservation",
            "damaged-media repair",
        ],
        "claim_boundary": "fixed-raw-bootable-image-construction-only; not arbitrary-device-installer",
    }


def _inspect_image_bytes(
    image: bytes | bytearray,
    image_label: str,
    *,
    artifact_inputs: dict[str, object] | None = None,
) -> dict[str, object]:
    make_wad_image = load_make_wad_image()
    image = bytearray(image)
    expected_size = make_wad_image.IMAGE_SECTORS * make_wad_image.SECTOR_SIZE
    if len(image) != expected_size:
        raise StorageBoundaryError(f"{image_label} size {len(image)} != expected {expected_size}")
    if image[510:512] != b"\x55\xaa":
        raise StorageBoundaryError("missing MBR boot signature")

    entry = 446
    for other_entry in range(entry + 16, entry + 64, 16):
        _require_zero_region(image, other_entry, other_entry + 16, "unused MBR partition entry")
    if image[entry + 4] != 0x06:
        raise StorageBoundaryError("MBR partition type is not FAT16 type 0x06")
    partition_lba = _u32(image, entry + 8)
    partition_sectors = _u32(image, entry + 12)
    if partition_lba != make_wad_image.PARTITION_START:
        raise StorageBoundaryError(f"partition starts at LBA {partition_lba}, expected {make_wad_image.PARTITION_START}")
    if partition_sectors != make_wad_image.PARTITION_SECTORS:
        raise StorageBoundaryError(
            f"partition sectors {partition_sectors}, expected {make_wad_image.PARTITION_SECTORS}"
        )
    partition_end_lba = partition_lba + partition_sectors
    if partition_end_lba != make_wad_image.IMAGE_SECTORS:
        raise StorageBoundaryError(
            f"partition ends at LBA {partition_end_lba}, expected {make_wad_image.IMAGE_SECTORS}"
        )
    raw_kernel_end = make_wad_image.KERNEL_LBA + make_wad_image.KERNEL_SECTORS
    if raw_kernel_end > partition_lba:
        raise StorageBoundaryError("raw kernel staging region overlaps the FAT16 partition")

    boot = partition_lba * make_wad_image.SECTOR_SIZE
    if image[boot + 510:boot + 512] != b"\x55\xaa":
        raise StorageBoundaryError("missing FAT16 boot-sector signature")
    if image[boot + 54:boot + 62] != b"FAT16   ":
        raise StorageBoundaryError("FAT type label is not FAT16")
    if _u16(image, boot + 11) != make_wad_image.SECTOR_SIZE:
        raise StorageBoundaryError("FAT bytes-per-sector does not match image contract")
    if image[boot + 13] != make_wad_image.SECTORS_PER_CLUSTER:
        raise StorageBoundaryError("FAT sectors-per-cluster does not match image contract")
    if _u16(image, boot + 14) != make_wad_image.RESERVED_SECTORS:
        raise StorageBoundaryError("FAT reserved-sector count does not match image contract")
    if image[boot + 16] != make_wad_image.FAT_COUNT:
        raise StorageBoundaryError("FAT copy count does not match image contract")
    if _u16(image, boot + 17) != make_wad_image.ROOT_ENTRIES:
        raise StorageBoundaryError("FAT root-entry count does not match image contract")
    if _u16(image, boot + 22) != make_wad_image.SECTORS_PER_FAT:
        raise StorageBoundaryError("FAT sectors-per-FAT does not match image contract")
    if _u32(image, boot + 28) != make_wad_image.PARTITION_START:
        raise StorageBoundaryError("FAT hidden-sector count does not match partition start")
    if _u16(image, boot + 19) != 0:
        raise StorageBoundaryError("FAT 16-bit total-sector field must be zero for this image size")
    if _u32(image, boot + 32) != make_wad_image.PARTITION_SECTORS:
        raise StorageBoundaryError("FAT 32-bit total-sector field does not match partition size")
    if image[boot + 21] != 0xF8:
        raise StorageBoundaryError("FAT media descriptor does not match fixed-disk contract")
    if image[boot + 36] != 0x80:
        raise StorageBoundaryError("FAT drive number does not match BIOS hard-disk contract")

    fat_lba = partition_lba + make_wad_image.RESERVED_SECTORS
    root_lba = fat_lba + make_wad_image.FAT_COUNT * make_wad_image.SECTORS_PER_FAT
    data_lba = root_lba + make_wad_image.ROOT_DIR_SECTORS
    fat_bytes = make_wad_image.SECTORS_PER_FAT * make_wad_image.SECTOR_SIZE
    fat_entry_capacity = fat_bytes // 2
    last_data_cluster = make_wad_image.last_data_cluster()
    if fat_entry_capacity <= last_data_cluster:
        raise StorageBoundaryError("FAT table is too small for the advertised data area")
    if data_lba >= partition_end_lba:
        raise StorageBoundaryError("FAT metadata consumes the entire partition")
    data_sectors = partition_end_lba - data_lba
    usable_data_sectors = make_wad_image.data_cluster_count() * make_wad_image.SECTORS_PER_CLUSTER
    if data_sectors < usable_data_sectors:
        raise StorageBoundaryError("FAT data area is smaller than the advertised cluster count")
    if data_sectors - usable_data_sectors >= make_wad_image.SECTORS_PER_CLUSTER:
        raise StorageBoundaryError("FAT data area leaves more than one partial cluster unused")
    first_fat = boot + make_wad_image.RESERVED_SECTORS * make_wad_image.SECTOR_SIZE
    if _u16(image, first_fat) != 0xFFF8 or _u16(image, first_fat + 2) != make_wad_image.FAT16_EOC_VALUE:
        raise StorageBoundaryError("FAT reserved entries do not match FAT16 fixed-disk contract")

    fs = make_wad_image.Fat16Image(image)
    try:
        fs.validate_fat_copies_match()
        fs.validate_allocated_clusters_reachable()
    except ValueError as exc:
        raise StorageBoundaryError(str(exc)) from exc

    data_clusters = make_wad_image.data_cluster_count()
    free_clusters = fs.free_data_clusters()
    used_clusters = sum(
        1 for cluster in range(2, make_wad_image.last_data_cluster() + 1)
        if fs.fat_entry(cluster) != 0
    )
    if free_clusters + used_clusters != data_clusters:
        raise StorageBoundaryError("FAT free/used cluster accounting does not cover the data area")
    try:
        make_wad_image.assert_free_cluster_budget_count(free_clusters)
    except ValueError as exc:
        raise StorageBoundaryError(str(exc)) from exc
    try:
        cluster_accounting = make_wad_image.fat16_allocation_accounting(fs)
    except ValueError as exc:
        raise StorageBoundaryError(str(exc)) from exc

    root_entries = []
    for meta in fs.live_root_entries():
        root_entries.append(
            {
                "name": make_wad_image.Fat16Image._entry_label(meta["name"]),
                "attr": f"0x{meta['attr']:02x}",
                "cluster": meta["cluster"],
                "size": meta["size"],
                "directory": bool(meta["is_directory"]),
                "protected": bool(meta["protected"]),
            }
        )

    protected_names = {entry["name"] for entry in root_entries if entry["protected"]}
    for required in ("DOOM1.WAD", "USERPROB.ELF", "DOOM.ELF"):
        if required not in protected_names:
            raise StorageBoundaryError(f"missing protected root entry {required}")
    root_names = {entry["name"] for entry in root_entries}
    required_writable = tuple(
        make_wad_image.Fat16Image._entry_label(name)
        for name, _byte_capacity in make_wad_image.WRITABLE_DYNAMIC_FILES
    )
    for required in required_writable:
        if required not in root_names:
            raise StorageBoundaryError(f"missing writable root placeholder {required}")
    try:
        packaged_assets = []
        for asset in make_wad_image.validate_generated_packaged_assets(fs):
            path = make_wad_image.fat83_path_from_display_path(asset["path"])
            packaged_assets.append(
                {
                    **asset,
                    "sha256": _sha256(fs.read_file_at_path(path)),
                }
            )
    except ValueError as exc:
        raise StorageBoundaryError(str(exc)) from exc
    filesystem_entries, filesystem_summary = _filesystem_tree_manifest(fs, make_wad_image)
    packaged_asset_bytes = sum(int(entry["size"]) for entry in packaged_assets)
    packaged_asset_clusters = sum(int(entry["clusters"]) for entry in packaged_assets)
    effective_artifact_inputs = artifact_inputs or _default_boot_artifact_inputs(ROOT)
    artifact_integrity = _artifact_integrity_manifest(
        image,
        effective_artifact_inputs,
    )
    bootable_image_construction = _bootable_image_construction_manifest(
        make_wad_image,
        image_label,
        effective_artifact_inputs,
    )
    fat_vfs_boundary = _fat_vfs_boundary_manifest(fs, make_wad_image, packaged_assets)

    return {
        "schema": "vibe-os-install-image-manifest-v1",
        "image": image_label,
        "image_size": len(image),
        "mbr": {
            "signature": "55aa",
            "disk_id": image[440:444].decode("ascii", "replace"),
            "partition_type": "0x06",
            "partition_lba": partition_lba,
            "partition_sectors": partition_sectors,
        },
        "raw_regions": {
            "stage1_lba": 0,
            "stage2_lba": make_wad_image.STAGE2_LBA,
            "stage2_sectors": make_wad_image.STAGE2_SECTORS,
            "kernel_lba": make_wad_image.KERNEL_LBA,
            "kernel_sectors": make_wad_image.KERNEL_SECTORS,
            "kernel_end_lba": raw_kernel_end,
        },
        "fat16": {
            "lba": partition_lba,
            "end_lba": partition_end_lba,
            "fat_lba": fat_lba,
            "root_lba": root_lba,
            "data_lba": data_lba,
            "data_sectors": data_sectors,
            "usable_data_sectors": usable_data_sectors,
            "data_clusters": data_clusters,
            "last_data_cluster": last_data_cluster,
            "fat_entry_capacity": fat_entry_capacity,
            "bytes_per_sector": _u16(image, boot + 11),
            "sectors_per_cluster": image[boot + 13],
            "reserved_sectors": _u16(image, boot + 14),
            "fat_count": image[boot + 16],
            "root_entries": _u16(image, boot + 17),
            "sectors_per_fat": _u16(image, boot + 22),
            "total_sectors": _u32(image, boot + 32),
            "media_descriptor": f"0x{image[boot + 21]:02x}",
            "root_entry_count": len(root_entries),
            "free_clusters": free_clusters,
            "used_clusters": used_clusters,
            "accounted_clusters": free_clusters + used_clusters,
            "minimum_os_created_file_clusters": make_wad_image.MIN_OS_CREATED_FILE_CLUSTERS,
            "packaged_asset_count": len(packaged_assets),
            "packaged_asset_bytes": packaged_asset_bytes,
            "packaged_asset_clusters": packaged_asset_clusters,
            "filesystem_file_count": filesystem_summary["files"],
            "filesystem_directory_count": filesystem_summary["directories"],
            "filesystem_file_bytes": filesystem_summary["file_bytes"],
            "filesystem_file_clusters": filesystem_summary["file_clusters"],
            "filesystem_max_depth": max(
                (int(entry["depth"]) for entry in filesystem_entries),
                default=0,
            ),
            "kernel_syscall_max_file_depth": 2,
        },
        "cluster_accounting": cluster_accounting,
        "required_writable_root_entries": list(required_writable),
        "packaged_assets": packaged_assets,
        "filesystem_entries": filesystem_entries,
        "root_entries": root_entries,
        "bootable_image_construction": bootable_image_construction,
        "artifact_integrity": artifact_integrity,
        "fat_vfs_boundary": fat_vfs_boundary,
        "claim_boundary": "generated-image-layout-only; not arbitrary-disk-install-proof",
    }


def inspect_image(image_path: Path) -> dict[str, object]:
    return _inspect_image_bytes(image_path.read_bytes(), str(image_path))


def _default_install_inputs(root: Path = ROOT) -> dict[str, object]:
    make_wad_image = load_make_wad_image()
    build = _configured_build_dir(root)
    inputs = {
        "stage1_path": build / "stage1.bin",
        "stage2_path": build / "stage2.bin",
        "kernel_path": build / "kernel.elf",
        "user_elf_path": build / "user_probe.elf",
        "doom_elf_path": build / "doom.elf",
        "extra_root_elves": (
            (
                make_wad_image.root83_from_display_name(
                    "ABIPROBE.ELF",
                    required_ext="ELF",
                ),
                build / "abi_probe.elf",
            ),
        ),
    }
    for label, path in (
        ("stage1", inputs["stage1_path"]),
        ("stage2", inputs["stage2_path"]),
        ("kernel", inputs["kernel_path"]),
        ("user probe ELF", inputs["user_elf_path"]),
        ("Doom ELF", inputs["doom_elf_path"]),
        ("ABI probe ELF", inputs["extra_root_elves"][0][1]),
    ):
        _read_artifact(path, label)
    return inputs


def _declared_install_write_ranges(make_wad_image) -> tuple[dict[str, int | str], ...]:
    return (
        {"name": "mbr-stage1-partition-table", "lba": 0, "sectors": 1},
        {
            "name": "stage2",
            "lba": make_wad_image.STAGE2_LBA,
            "sectors": make_wad_image.STAGE2_SECTORS,
        },
        {
            "name": "kernel",
            "lba": make_wad_image.KERNEL_LBA,
            "sectors": make_wad_image.KERNEL_SECTORS,
        },
        {
            "name": "fat16-partition",
            "lba": make_wad_image.PARTITION_START,
            "sectors": make_wad_image.PARTITION_SECTORS,
        },
    )


def _lba_in_ranges(lba: int, ranges: tuple[dict[str, int | str], ...]) -> bool:
    for entry in ranges:
        start = int(entry["lba"])
        end = start + int(entry["sectors"])
        if start <= lba < end:
            return True
    return False


def _nonzero_sector_audit(
    image: bytes | bytearray,
    ranges: tuple[dict[str, int | str], ...],
    *,
    sector_size: int,
) -> dict[str, object]:
    nonzero_count = 0
    outside = []
    for lba in range(0, len(image) // sector_size):
        start = lba * sector_size
        if not any(image[start:start + sector_size]):
            continue
        nonzero_count += 1
        if not _lba_in_ranges(lba, ranges):
            outside.append(lba)
    return {
        "nonzero_sector_count": nonzero_count,
        "outside_declared_ranges": outside,
        "writes_only_declared_ranges": not outside,
    }


def prove_blank_disk_install(root: Path = ROOT) -> dict[str, object]:
    make_wad_image = load_make_wad_image()
    inputs = _default_install_inputs(root)
    image_size = make_wad_image.IMAGE_SECTORS * make_wad_image.SECTOR_SIZE
    blank = bytearray(image_size)
    if any(blank):
        raise StorageBoundaryError("blank install proof did not start from an all-zero image")

    dirty = bytearray(image_size)
    dirty[0] = 0xA5
    try:
        make_wad_image.install_bootable_layout(dirty, **inputs)
    except ValueError as exc:
        nonblank_refusal = str(exc)
    else:
        raise StorageBoundaryError("blank installer accepted a non-empty target")

    installed = make_wad_image.install_bootable_layout(blank, **inputs)
    manifest = _inspect_image_bytes(
        installed,
        "blank-install://in-memory",
        artifact_inputs=inputs,
    )

    expected_mbr = _expected_installed_mbr(inputs["stage1_path"])
    if installed[:make_wad_image.SECTOR_SIZE] != expected_mbr:
        raise StorageBoundaryError("installed MBR does not match patched stage1 artifact")

    artifact_regions = [
        _require_artifact_region(
            installed,
            lba=make_wad_image.STAGE2_LBA,
            sectors=make_wad_image.STAGE2_SECTORS,
            path=inputs["stage2_path"],
            label="stage2",
        ),
        _require_artifact_region(
            installed,
            lba=make_wad_image.KERNEL_LBA,
            sectors=make_wad_image.KERNEL_SECTORS,
            path=inputs["kernel_path"],
            label="kernel",
        ),
    ]
    declared_ranges = _declared_install_write_ranges(make_wad_image)
    sector_audit = _nonzero_sector_audit(
        installed,
        declared_ranges,
        sector_size=make_wad_image.SECTOR_SIZE,
    )
    if not sector_audit["writes_only_declared_ranges"]:
        raise StorageBoundaryError(
            "blank install wrote outside declared ranges: "
            + ", ".join(str(lba) for lba in sector_audit["outside_declared_ranges"])
        )

    root_names = {entry["name"] for entry in manifest["root_entries"]}
    for required in ("DOOM1.WAD", "USERPROB.ELF", "DOOM.ELF", "ABIPROBE.ELF"):
        if required not in root_names:
            raise StorageBoundaryError(f"blank install image missing root entry {required}")

    return {
        "schema": "vibe-os-blank-disk-installer-manifest-v1",
        "source": {
            "kind": "in-memory-all-zero-image",
            "image_size": image_size,
            "all_zero_before_install": True,
            "nonblank_target_refusal": nonblank_refusal,
        },
        "declared_write_ranges": list(declared_ranges),
        "bootable_image_construction": _bootable_image_construction_manifest(
            make_wad_image,
            "blank-install://in-memory",
            inputs,
        ),
        "write_audit": sector_audit,
        "structural_boot_proof": {
            "qemu_executed": False,
            "stage1_mbr_matches_patched_artifact": True,
            "stage1_sha256": _sha256(_read_artifact(inputs["stage1_path"], "stage1")),
            "stage2_matches_artifact": True,
            "kernel_matches_artifact": True,
            "artifact_regions": artifact_regions,
            "mbr_signature": manifest["mbr"]["signature"],
            "fat16_boot_signature": "55aa",
            "stage2_lba": make_wad_image.STAGE2_LBA,
            "stage2_sectors": make_wad_image.STAGE2_SECTORS,
            "kernel_lba": make_wad_image.KERNEL_LBA,
            "kernel_sectors": make_wad_image.KERNEL_SECTORS,
            "fat16_lba": make_wad_image.PARTITION_START,
        },
        "installed_image_manifest": manifest,
        "claim_boundary": "blank-image-host-install-only; not arbitrary-disk-install-proof",
    }


def materialize_blank_install_image(output_path: Path, root: Path = ROOT) -> dict[str, object]:
    """Create a new bootable raw image file from the blank-image install path.

    This is deliberately narrower than an arbitrary-device installer: the
    output path must not already exist, so the tool cannot overwrite a disk,
    partition, or user file by accident.
    """

    make_wad_image = load_make_wad_image()
    inputs = _default_install_inputs(root)
    if output_path.exists() or output_path.is_symlink():
        raise StorageBoundaryError(f"refusing to overwrite existing output path: {output_path}")
    output_path = output_path.resolve()
    if not output_path.parent.is_dir():
        raise StorageBoundaryError(f"output directory does not exist: {output_path.parent}")

    image_size = make_wad_image.IMAGE_SECTORS * make_wad_image.SECTOR_SIZE
    installed = make_wad_image.install_bootable_layout(bytearray(image_size), **inputs)
    try:
        with output_path.open("xb") as handle:
            handle.write(installed)
    except FileExistsError as exc:
        raise StorageBoundaryError(f"refusing to overwrite existing output path: {output_path}") from exc
    except OSError as exc:
        raise StorageBoundaryError(f"failed to write blank install image {output_path}: {exc}") from exc

    written = output_path.read_bytes()
    if written != bytes(installed):
        raise StorageBoundaryError(f"written blank install image did not round-trip: {output_path}")
    manifest = _inspect_image_bytes(
        written,
        str(output_path),
        artifact_inputs=inputs,
    )
    return {
        "schema": "vibe-os-blank-image-file-materialization-v1",
        "output": str(output_path),
        "bytes_written": len(written),
        "sha256": _sha256(written),
        "write_safety": {
            "output_must_not_exist": True,
            "existing_path_refused": True,
            "block_device_write_supported": False,
            "arbitrary_device_install_supported": False,
        },
        "installed_image_manifest": manifest,
        "claim_boundary": "new-regular-image-file-only; not arbitrary-device-installer",
    }


def inspect_recovery_candidate_bytes(
    image: bytes | bytearray,
    *,
    label: str,
) -> dict[str, object]:
    try:
        manifest = _inspect_image_bytes(image, label)
    except StorageBoundaryError as exc:
        return {
            "schema": "vibe-os-damaged-image-refusal-report-v1",
            "candidate": label,
            "decision": "refuse",
            "reason": str(exc),
            "repair_attempted": False,
            "repair_supported": False,
            "claim_boundary": "detect-and-refuse-only; not arbitrary-disk-recovery-proof",
        }
    return {
        "schema": "vibe-os-damaged-image-refusal-report-v1",
        "candidate": label,
        "decision": "inspect-only",
        "manifest_schema": manifest["schema"],
        "repair_attempted": False,
        "repair_supported": False,
        "claim_boundary": "known-layout-inspection-only; not arbitrary-disk-recovery-proof",
    }


def inspect_recovery_candidate(image_path: Path) -> dict[str, object]:
    return inspect_recovery_candidate_bytes(image_path.read_bytes(), label=str(image_path))


def _damage_missing_mbr_signature(image: bytearray, make_wad_image) -> None:
    image[510:512] = b"\0\0"


def _damage_extra_partition_entry(image: bytearray, make_wad_image) -> None:
    image[446 + 16 + 4] = 0x06


def _damage_fat_copy_divergence(image: bytearray, make_wad_image) -> None:
    fs = make_wad_image.Fat16Image(image)
    second_fat = (
        fs.partition_lba
        + fs.reserved
        + fs.sectors_per_fat
    ) * make_wad_image.SECTOR_SIZE
    image[second_fat + 2 * make_wad_image.DOOM_WAD_CLUSTER] ^= 0x01


def _damage_missing_protected_entry(image: bytearray, make_wad_image) -> None:
    fs = make_wad_image.Fat16Image(image)
    entry = fs.root_entry_offset(b"DOOM1   WAD")
    if entry is None:
        raise StorageBoundaryError("base image is missing DOOM1.WAD before fixture damage")
    image[entry:entry + 11] = b"BADWAD  BIN"


def _damage_crosslinked_root_entry(image: bytearray, make_wad_image) -> None:
    fs = make_wad_image.Fat16Image(image)
    chain = fs.write_root_file(b"ALPHA   TXT", b"A" * 700)
    fs.write_root_file(b"BETA    TXT", b"B" * 700)
    beta_entry = fs.root_entry_offset(b"BETA    TXT")
    make_wad_image.write_le16(image, beta_entry + 26, chain[0])


def _damage_stage2_artifact_mismatch(image: bytearray, make_wad_image) -> None:
    image[sector_offset(make_wad_image.STAGE2_LBA)] ^= 0x01


def _damage_kernel_artifact_mismatch(image: bytearray, make_wad_image) -> None:
    image[sector_offset(make_wad_image.KERNEL_LBA)] ^= 0x01


DAMAGED_FIXTURES = (
    ("missing-mbr-signature", _damage_missing_mbr_signature),
    ("extra-mbr-partition-entry", _damage_extra_partition_entry),
    ("fat-copy-divergence", _damage_fat_copy_divergence),
    ("missing-protected-wad-entry", _damage_missing_protected_entry),
    ("crosslinked-root-entry", _damage_crosslinked_root_entry),
    ("stage2-artifact-mismatch", _damage_stage2_artifact_mismatch),
    ("kernel-artifact-mismatch", _damage_kernel_artifact_mismatch),
)


def damaged_recovery_fixture_reports(base_image_path: Path) -> dict[str, object]:
    make_wad_image = load_make_wad_image()
    base = bytearray(base_image_path.read_bytes())
    _inspect_image_bytes(base, str(base_image_path))

    reports = []
    for name, mutate in DAMAGED_FIXTURES:
        damaged = bytearray(base)
        mutate(damaged, make_wad_image)
        report = inspect_recovery_candidate_bytes(damaged, label=f"fixture:{name}")
        if report["decision"] != "refuse":
            raise StorageBoundaryError(f"damaged fixture {name} did not produce a refusal")
        reports.append(report)

    return {
        "schema": "vibe-os-damaged-image-refusal-suite-v1",
        "base_image": str(base_image_path),
        "repair_attempted": False,
        "all_refused": True,
        "fixtures": reports,
        "claim_boundary": "damaged-repo-image-detect-and-refuse-only; not arbitrary-disk-recovery-proof",
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-contract", action="store_true", help="validate docs and rows")
    parser.add_argument("--image", type=Path, help="inspect a generated disk image")
    parser.add_argument(
        "--blank-install-proof",
        action="store_true",
        help="build an in-memory image from an all-zero disk and verify the install manifest",
    )
    parser.add_argument(
        "--write-blank-image",
        type=Path,
        help="write a new regular raw image file from the blank-image install path; refuses existing paths",
    )
    parser.add_argument(
        "--recovery-candidate",
        type=Path,
        help="inspect one image as a recovery candidate and report accept/refuse",
    )
    parser.add_argument(
        "--recovery-fixtures",
        type=Path,
        help="run damaged-image refusal fixtures derived from a known-good image",
    )
    parser.add_argument("--json", action="store_true", help="print image manifest as JSON")
    args = parser.parse_args(argv)

    if (
        not args.repo_contract
        and args.image is None
        and not args.blank_install_proof
        and args.recovery_candidate is None
        and args.recovery_fixtures is None
    ):
        args.repo_contract = True

    try:
        if args.repo_contract:
            validate_repo_contract(ROOT)
        results = {}
        manifest = inspect_image(args.image) if args.image is not None else None
        if manifest is not None:
            results["image_manifest"] = manifest
        if args.blank_install_proof:
            results["blank_install_proof"] = prove_blank_disk_install(ROOT)
        if args.write_blank_image is not None:
            results["blank_image_file"] = materialize_blank_install_image(
                args.write_blank_image,
                ROOT,
            )
        if args.recovery_candidate is not None:
            results["recovery_candidate"] = inspect_recovery_candidate(args.recovery_candidate)
        if args.recovery_fixtures is not None:
            results["recovery_fixtures"] = damaged_recovery_fixture_reports(args.recovery_fixtures)
    except StorageBoundaryError as exc:
        print(f"storage install boundary check failed: {exc}", file=sys.stderr)
        return 1

    if args.json:
        if args.repo_contract and not results:
            print(json.dumps({"repo_contract": "OK"}, indent=2, sort_keys=True))
        elif set(results) == {"image_manifest"}:
            print(json.dumps(results["image_manifest"], indent=2, sort_keys=True))
        else:
            print(json.dumps(results, indent=2, sort_keys=True))
    else:
        if manifest is not None:
            print(
                "install-image manifest OK: "
                f"{manifest['image_size']} bytes, FAT16 LBA {manifest['fat16']['lba']}, "
                f"{manifest['fat16']['root_entry_count']} root entries"
            )
        if "blank_install_proof" in results:
            proof = results["blank_install_proof"]
            print(
                "blank install manifest OK: "
                f"{proof['source']['image_size']} bytes, "
                f"{proof['installed_image_manifest']['fat16']['root_entry_count']} root entries, "
                "structural boot proof without local QEMU"
            )
        if "blank_image_file" in results:
            image_file = results["blank_image_file"]
            print(
                "blank image file materialization OK: "
                f"{image_file['bytes_written']} bytes written to {image_file['output']}"
            )
        if "recovery_candidate" in results:
            report = results["recovery_candidate"]
            print(f"recovery candidate {report['decision']}: {report['candidate']}")
        if "recovery_fixtures" in results:
            suite = results["recovery_fixtures"]
            print(
                "damaged image refusal fixtures OK: "
                f"{len(suite['fixtures'])} refused"
            )
        if args.repo_contract and not results:
            print("storage install boundary repo contract OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
