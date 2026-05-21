#!/usr/bin/env python3
"""Validate vibe-os storage install/recovery claim boundaries.

The current proof can mutate and reboot the repo-generated FAT16 image in
cloud QEMU. This checker keeps that claim separate from a future installer for
arbitrary disks, and can also inspect a generated image layout without running
QEMU.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "storage-install-boundary.md"
MAKE_WAD_IMAGE = ROOT / "tools" / "make_wad_image.py"

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
    "blank-disk-to-bootable-vibe-os",
    "detect-and-repair-or-refuse",
)

REQUIRED_CROSS_DOC_LINKS = {
    "README.md": (
        "not an installable general OS on arbitrary disks",
        "does not partition blank media",
        "docs/storage-install-boundary.md",
        "tools/check_storage_install_boundary.py --image build/disk.img",
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


def inspect_image(image_path: Path) -> dict[str, object]:
    make_wad_image = load_make_wad_image()
    image = bytearray(image_path.read_bytes())
    expected_size = make_wad_image.IMAGE_SECTORS * make_wad_image.SECTOR_SIZE
    if len(image) != expected_size:
        raise StorageBoundaryError(f"{image_path} size {len(image)} != expected {expected_size}")
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

    return {
        "schema": "vibe-os-install-image-manifest-v1",
        "image": str(image_path),
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
        },
        "required_writable_root_entries": list(required_writable),
        "root_entries": root_entries,
        "claim_boundary": "generated-image-layout-only; not arbitrary-disk-install-proof",
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-contract", action="store_true", help="validate docs and rows")
    parser.add_argument("--image", type=Path, help="inspect a generated disk image")
    parser.add_argument("--json", action="store_true", help="print image manifest as JSON")
    args = parser.parse_args(argv)

    if not args.repo_contract and args.image is None:
        args.repo_contract = True

    try:
        if args.repo_contract:
            validate_repo_contract(ROOT)
        manifest = inspect_image(args.image) if args.image is not None else None
    except StorageBoundaryError as exc:
        print(f"storage install boundary check failed: {exc}", file=sys.stderr)
        return 1

    if args.json and manifest is not None:
        print(json.dumps(manifest, indent=2, sort_keys=True))
    elif manifest is not None:
        print(
            "install-image manifest OK: "
            f"{manifest['image_size']} bytes, FAT16 LBA {manifest['fat16']['lba']}, "
            f"{manifest['fat16']['root_entry_count']} root entries"
        )
    elif args.repo_contract:
        print("storage install boundary repo contract OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
