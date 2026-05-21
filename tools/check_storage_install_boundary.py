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
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "build"
DOC = ROOT / "docs" / "storage-install-boundary.md"
MAKE_WAD_IMAGE = ROOT / "tools" / "make_wad_image.py"
SECTOR_SIZE = 512


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

REQUIRED_PHRASES = (
    "not an installable general OS on arbitrary disks",
    "mutates and reboots the repo-generated FAT16 image",
    "does not partition a blank disk",
    "does not discover arbitrary existing partitions",
    "does not repair corrupted user disks",
    "LBA 0 is the repo MBR",
    "LBA 2048 is the FAT16 partition",
    "install-image-manifest",
    "blank-disk-installer-manifest",
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
        "docs/storage-install-boundary.md",
    ),
    "docs/persistent-fat16.md": (
        "not an arbitrary-disk install or recovery proof",
        "install-image-manifest",
    ),
    "docs/post-checkpoint-gaps.md": (
        "STORAGE_BOUNDARY[ARBITRARY_DISK_INSTALL] status=unclaimed",
        "blank-disk-to-bootable-vibe-os",
    ),
    "tests/README.md": (
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
    files = [root / "README.md", root / "tests" / "README.md"]
    files.extend(sorted((root / "docs").rglob("*.md")))
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
    doc = root / "docs" / "storage-install-boundary.md"
    text = doc.read_text()
    normalized = " ".join(text.split())
    for phrase in REQUIRED_PHRASES:
        if " ".join(phrase.split()) not in normalized:
            raise StorageBoundaryError(f"missing required storage boundary phrase: {phrase}")

    boundaries = parse_rows(text, "STORAGE_BOUNDARY")
    requirements = parse_rows(text, "STORAGE_PROOF_REQUIREMENT")
    require_expected_rows(boundaries, EXPECTED_BOUNDARIES, "STORAGE_BOUNDARY")
    require_expected_rows(requirements, EXPECTED_REQUIREMENTS, "STORAGE_PROOF_REQUIREMENT")
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


def _inspect_image_bytes(image: bytes | bytearray, image_label: str) -> dict[str, object]:
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
            "data_clusters": make_wad_image.data_cluster_count(),
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
            "free_clusters": fs.free_data_clusters(),
            "packaged_asset_count": len(packaged_assets),
        },
        "required_writable_root_entries": list(required_writable),
        "packaged_assets": packaged_assets,
        "root_entries": root_entries,
        "claim_boundary": "generated-image-layout-only; not arbitrary-disk-install-proof",
    }


def inspect_image(image_path: Path) -> dict[str, object]:
    return _inspect_image_bytes(image_path.read_bytes(), str(image_path))


def _default_install_inputs(root: Path = ROOT) -> dict[str, object]:
    make_wad_image = load_make_wad_image()
    build = root / "build"
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
    manifest = _inspect_image_bytes(installed, "blank-install://in-memory")

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


DAMAGED_FIXTURES = (
    ("missing-mbr-signature", _damage_missing_mbr_signature),
    ("extra-mbr-partition-entry", _damage_extra_partition_entry),
    ("fat-copy-divergence", _damage_fat_copy_divergence),
    ("missing-protected-wad-entry", _damage_missing_protected_entry),
    ("crosslinked-root-entry", _damage_crosslinked_root_entry),
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
