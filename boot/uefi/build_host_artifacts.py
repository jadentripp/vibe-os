#!/usr/bin/env python3
"""Build opt-in host-only UEFI packaging artifacts.

This script deliberately stops at artifact construction. It does not run OVMF,
does not call QEMU, and does not prove UEFI boot support. The generated EFI
application is a PE32+ x86_64 loader/proof application assembled from
loader.asm. It can read VIBEOS/KERNEL.ELF, collect GOP and UEFI memory-map
facts, load ELF32 PT_LOAD segments into low physical memory, synthesize the
legacy boot-info/E820 block, validate that the BIOS-compatible handoff is
complete, and attempt the 64-bit UEFI to 32-bit protected-mode handoff after
ExitBootServices. Kernel entry still needs cloud OVMF proof.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import struct
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SECTOR_SIZE = 512
TOTAL_SECTORS = 8192
SECTORS_PER_CLUSTER = 1
RESERVED_SECTORS = 1
FAT_COUNT = 2
ROOT_ENTRY_COUNT = 512

PE_FILE_ALIGNMENT = 0x200
PE_SECTION_ALIGNMENT = 0x1000
PE_HEADERS_SIZE = 0x200
PE_TEXT_RVA = 0x1000
PE_TEXT_RAW_POINTER = 0x200
PE_MACHINE_AMD64 = 0x8664
PE_OPTIONAL_MAGIC_PE32_PLUS = 0x20B
PE_SUBSYSTEM_EFI_APPLICATION = 10

REQUIRED_LOADER_MARKERS = (
    b"VIBEUEFI step=entry",
    b"VIBEUEFI step=esp-kernel-read",
    b"VIBEUEFI step=low-memory-reserve status=success",
    b"VIBEUEFI step=elf32-load status=success",
    b"VIBEUEFI step=gop",
    b"VIBEUEFI step=memory-map",
    b"VIBEUEFI step=boot-info status=success",
    b"VIBEUEFI step=low-handoff-copy status=success",
    b"VIBEUEFI step=exit-boot-services status=success",
    b"VIBEUEFI step=kernel-handoff status=attempting",
)


def align_up(value: int, alignment: int) -> int:
    return (value + alignment - 1) // alignment * alignment


def assemble_loader(loader_source: Path, nasm: str) -> bytes:
    """Assemble the flat x86_64 UEFI loader payload."""
    if not loader_source.exists():
        raise FileNotFoundError(f"missing UEFI loader source: {loader_source}")

    with tempfile.TemporaryDirectory(prefix="vibe-uefi-loader-") as tmp:
        out_path = Path(tmp) / "loader.bin"
        completed = subprocess.run(
            [nasm, "-f", "bin", str(loader_source), "-o", str(out_path)],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        if completed.returncode != 0:
            detail = completed.stderr.strip() or completed.stdout.strip()
            raise RuntimeError(f"failed to assemble UEFI loader with {nasm}: {detail}")
        return out_path.read_bytes()


def build_pe32plus_efi_application(text: bytes) -> bytes:
    """Wrap a flat x86_64 payload as a PE32+ EFI application."""
    text_raw_size = align_up(len(text), PE_FILE_ALIGNMENT)
    size_of_image = align_up(PE_TEXT_RVA + len(text), PE_SECTION_ALIGNMENT)

    dos = bytearray(0x80)
    dos[0:2] = b"MZ"
    struct.pack_into("<I", dos, 0x3C, 0x80)

    file_header = struct.pack(
        "<HHIIIHH",
        0x8664,  # IMAGE_FILE_MACHINE_AMD64
        1,
        0,
        0,
        0,
        0xF0,
        0x0022,  # executable, large-address-aware
    )
    optional_header = bytearray()
    optional_header.extend(
        struct.pack(
            "<HBBIIIIIQIIHHHHHHIIIIHHQQQQII",
            0x20B,  # PE32+
            0,
            0,
            text_raw_size,
            0,
            0,
            PE_TEXT_RVA,
            PE_TEXT_RVA,
            0x100000,
            PE_SECTION_ALIGNMENT,
            PE_FILE_ALIGNMENT,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            size_of_image,
            PE_HEADERS_SIZE,
            0,
            10,  # IMAGE_SUBSYSTEM_EFI_APPLICATION
            0,
            0x100000,
            0x1000,
            0x100000,
            0x1000,
            0,
            16,
        )
    )
    optional_header.extend(b"\0" * (16 * 8))
    if len(optional_header) != 0xF0:
        raise AssertionError(f"unexpected PE optional-header size: {len(optional_header)}")

    section_header = struct.pack(
        "<8sIIIIIIHHI",
        b".text\0\0\0",
        len(text),
        PE_TEXT_RVA,
        text_raw_size,
        PE_TEXT_RAW_POINTER,
        0,
        0,
        0,
        0,
        0xE0000020,  # code, execute, read, write
    )

    headers = dos + b"PE\0\0" + file_header + optional_header + section_header
    headers = headers.ljust(PE_HEADERS_SIZE, b"\0")
    return headers + text.ljust(text_raw_size, b"\0")


def validate_pe32plus_efi_application(data: bytes, *, text_size: int) -> dict[str, object]:
    """Validate the PE/COFF boundary that host checks rely on."""
    if len(data) < PE_HEADERS_SIZE:
        raise ValueError("BOOTX64.EFI is too small for PE/COFF headers")
    if data[0:2] != b"MZ":
        raise ValueError("BOOTX64.EFI missing MZ DOS header")
    pe_offset = struct.unpack_from("<I", data, 0x3C)[0]
    if pe_offset + 24 > len(data):
        raise ValueError("BOOTX64.EFI PE header offset is out of range")
    if data[pe_offset : pe_offset + 4] != b"PE\0\0":
        raise ValueError("BOOTX64.EFI missing PE/COFF signature")

    file_header = pe_offset + 4
    machine, section_count, _timestamp, _symbols, _symbol_count, optional_size, _chars = (
        struct.unpack_from("<HHIIIHH", data, file_header)
    )
    if machine != PE_MACHINE_AMD64:
        raise ValueError("BOOTX64.EFI is not an x86_64 PE/COFF image")
    if section_count != 1:
        raise ValueError("BOOTX64.EFI must keep one .text section")
    if optional_size != 0xF0:
        raise ValueError("BOOTX64.EFI must use a PE32+ optional header")

    optional = file_header + 20
    if optional + optional_size > len(data):
        raise ValueError("BOOTX64.EFI optional header is out of range")
    if struct.unpack_from("<H", data, optional)[0] != PE_OPTIONAL_MAGIC_PE32_PLUS:
        raise ValueError("BOOTX64.EFI optional header is not PE32+")
    entry_rva = struct.unpack_from("<I", data, optional + 16)[0]
    image_base = struct.unpack_from("<Q", data, optional + 24)[0]
    section_alignment = struct.unpack_from("<I", data, optional + 32)[0]
    file_alignment = struct.unpack_from("<I", data, optional + 36)[0]
    size_of_image = struct.unpack_from("<I", data, optional + 56)[0]
    size_of_headers = struct.unpack_from("<I", data, optional + 60)[0]
    subsystem = struct.unpack_from("<H", data, optional + 68)[0]
    data_directory_count = struct.unpack_from("<I", data, optional + 108)[0]
    if entry_rva != PE_TEXT_RVA:
        raise ValueError("BOOTX64.EFI entry point must start at .text")
    if section_alignment != PE_SECTION_ALIGNMENT or file_alignment != PE_FILE_ALIGNMENT:
        raise ValueError("BOOTX64.EFI section/file alignment changed")
    if size_of_headers != PE_HEADERS_SIZE:
        raise ValueError("BOOTX64.EFI header size changed")
    if subsystem != PE_SUBSYSTEM_EFI_APPLICATION:
        raise ValueError("BOOTX64.EFI must declare IMAGE_SUBSYSTEM_EFI_APPLICATION")
    if data_directory_count != 16:
        raise ValueError("BOOTX64.EFI must keep 16 PE data directory slots")

    section = optional + optional_size
    if section + 40 > len(data):
        raise ValueError("BOOTX64.EFI section header is out of range")
    name, virtual_size, virtual_address, raw_size, raw_pointer, _reloc, _lines, _reloc_count, _line_count, characteristics = (
        struct.unpack_from("<8sIIIIIIHHI", data, section)
    )
    expected_raw_size = align_up(text_size, PE_FILE_ALIGNMENT)
    expected_image_size = align_up(PE_TEXT_RVA + text_size, PE_SECTION_ALIGNMENT)
    if name.rstrip(b"\0") != b".text":
        raise ValueError("BOOTX64.EFI must contain a .text section")
    if virtual_address != PE_TEXT_RVA or virtual_size != text_size:
        raise ValueError("BOOTX64.EFI .text virtual layout changed")
    if raw_pointer != PE_TEXT_RAW_POINTER or raw_size != expected_raw_size:
        raise ValueError("BOOTX64.EFI .text raw layout changed")
    if size_of_image != expected_image_size:
        raise ValueError("BOOTX64.EFI SizeOfImage does not match .text")
    if characteristics & 0xE0000020 != 0xE0000020:
        raise ValueError("BOOTX64.EFI .text must be code, execute, read, and write")
    if raw_pointer + raw_size > len(data):
        raise ValueError("BOOTX64.EFI .text points past end of file")

    text = data[raw_pointer : raw_pointer + raw_size]
    missing_markers = [marker.decode("ascii") for marker in REQUIRED_LOADER_MARKERS if marker not in text]
    if missing_markers:
        raise ValueError("BOOTX64.EFI loader is missing proof markers: " + ", ".join(missing_markers))

    return {
        "format": "PE32+",
        "machine": "x86_64",
        "subsystem": "efi-application",
        "entry_rva": entry_rva,
        "image_base": image_base,
        "section_count": section_count,
        "text_size": text_size,
        "required_marker_count": len(REQUIRED_LOADER_MARKERS),
    }


def _fat_name(name: str, extension: str = "") -> bytes:
    if len(name) > 8 or len(extension) > 3:
        raise ValueError(f"not an 8.3 name: {name}.{extension}")
    return name.upper().ljust(8).encode("ascii") + extension.upper().ljust(3).encode("ascii")


def _dir_entry(name: bytes, attr: int, first_cluster: int, size: int = 0) -> bytes:
    entry = bytearray(32)
    entry[0:11] = name
    entry[11] = attr
    struct.pack_into("<H", entry, 26, first_cluster)
    struct.pack_into("<I", entry, 28, size)
    return bytes(entry)


def _directory_cluster(entries: list[bytes], self_cluster: int, parent_cluster: int) -> bytes:
    dot_entries = [
        _dir_entry(_fat_name("."), 0x10, self_cluster),
        _dir_entry(_fat_name(".."), 0x10, parent_cluster),
    ]
    content = b"".join(dot_entries + entries)
    return content.ljust(SECTOR_SIZE * SECTORS_PER_CLUSTER, b"\0")


def _fat16_layout() -> tuple[int, int, int]:
    root_dir_sectors = align_up(ROOT_ENTRY_COUNT * 32, SECTOR_SIZE) // SECTOR_SIZE
    sectors_per_fat = 1
    while True:
        data_sectors = (
            TOTAL_SECTORS
            - RESERVED_SECTORS
            - root_dir_sectors
            - FAT_COUNT * sectors_per_fat
        )
        cluster_count = data_sectors // SECTORS_PER_CLUSTER
        required_fat_sectors = align_up((cluster_count + 2) * 2, SECTOR_SIZE) // SECTOR_SIZE
        if required_fat_sectors == sectors_per_fat:
            break
        sectors_per_fat = required_fat_sectors
    if not 4085 <= cluster_count < 65525:
        raise AssertionError(f"FAT16 cluster count out of range: {cluster_count}")
    return root_dir_sectors, sectors_per_fat, cluster_count


def build_fat16_esp_image(efi_application: bytes, kernel: bytes) -> bytes:
    root_dir_sectors, sectors_per_fat, cluster_count = _fat16_layout()
    first_root_sector = RESERVED_SECTORS + FAT_COUNT * sectors_per_fat
    first_data_sector = first_root_sector + root_dir_sectors
    cluster_size = SECTOR_SIZE * SECTORS_PER_CLUSTER

    image = bytearray(TOTAL_SECTORS * SECTOR_SIZE)

    boot = bytearray(SECTOR_SIZE)
    boot[0:3] = b"\xEB\x3C\x90"
    boot[3:11] = b"VIBEUEFI"
    struct.pack_into("<H", boot, 11, SECTOR_SIZE)
    boot[13] = SECTORS_PER_CLUSTER
    struct.pack_into("<H", boot, 14, RESERVED_SECTORS)
    boot[16] = FAT_COUNT
    struct.pack_into("<H", boot, 17, ROOT_ENTRY_COUNT)
    struct.pack_into("<H", boot, 19, TOTAL_SECTORS)
    boot[21] = 0xF8
    struct.pack_into("<H", boot, 22, sectors_per_fat)
    struct.pack_into("<H", boot, 24, 32)
    struct.pack_into("<H", boot, 26, 64)
    boot[36] = 0x80
    boot[38] = 0x29
    struct.pack_into("<I", boot, 39, 0x56424546)
    boot[43:54] = b"VIBE UEFI  "
    boot[54:62] = b"FAT16   "
    boot[510:512] = b"\x55\xAA"
    image[0:SECTOR_SIZE] = boot

    fat = [0] * (cluster_count + 2)
    fat[0] = 0xFFF8
    fat[1] = 0xFFFF
    next_cluster = 2

    def allocate(byte_count: int) -> list[int]:
        nonlocal next_cluster
        clusters_needed = max(1, align_up(byte_count, cluster_size) // cluster_size)
        chain = list(range(next_cluster, next_cluster + clusters_needed))
        if chain[-1] >= len(fat):
            raise AssertionError("ESP image is too small for requested artifacts")
        for current, following in zip(chain, chain[1:]):
            fat[current] = following
        fat[chain[-1]] = 0xFFFF
        next_cluster += clusters_needed
        return chain

    efi_dir = allocate(cluster_size)[0]
    vibeos_dir = allocate(cluster_size)[0]
    boot_dir = allocate(cluster_size)[0]
    efi_chain = allocate(len(efi_application))
    kernel_chain = allocate(len(kernel))

    def cluster_offset(cluster: int) -> int:
        sector = first_data_sector + (cluster - 2) * SECTORS_PER_CLUSTER
        return sector * SECTOR_SIZE

    root_entries = [
        _dir_entry(_fat_name("EFI"), 0x10, efi_dir),
        _dir_entry(_fat_name("VIBEOS"), 0x10, vibeos_dir),
    ]
    root_offset = first_root_sector * SECTOR_SIZE
    image[root_offset : root_offset + len(root_entries) * 32] = b"".join(root_entries)

    efi_entries = [_dir_entry(_fat_name("BOOT"), 0x10, boot_dir)]
    image[cluster_offset(efi_dir) : cluster_offset(efi_dir) + cluster_size] = _directory_cluster(
        efi_entries,
        efi_dir,
        0,
    )

    boot_entries = [_dir_entry(_fat_name("BOOTX64", "EFI"), 0x20, efi_chain[0], len(efi_application))]
    image[cluster_offset(boot_dir) : cluster_offset(boot_dir) + cluster_size] = _directory_cluster(
        boot_entries,
        boot_dir,
        efi_dir,
    )

    vibeos_entries = [_dir_entry(_fat_name("KERNEL", "ELF"), 0x20, kernel_chain[0], len(kernel))]
    image[cluster_offset(vibeos_dir) : cluster_offset(vibeos_dir) + cluster_size] = _directory_cluster(
        vibeos_entries,
        vibeos_dir,
        0,
    )

    def write_chain(chain: list[int], payload: bytes) -> None:
        for index, cluster in enumerate(chain):
            chunk = payload[index * cluster_size : (index + 1) * cluster_size]
            offset = cluster_offset(cluster)
            image[offset : offset + len(chunk)] = chunk

    write_chain(efi_chain, efi_application)
    write_chain(kernel_chain, kernel)

    fat_bytes = bytearray(sectors_per_fat * SECTOR_SIZE)
    for index, value in enumerate(fat):
        struct.pack_into("<H", fat_bytes, index * 2, value)
    for fat_index in range(FAT_COUNT):
        start = (RESERVED_SECTORS + fat_index * sectors_per_fat) * SECTOR_SIZE
        image[start : start + len(fat_bytes)] = fat_bytes

    return bytes(image)


def build_artifacts(
    kernel_path: Path,
    out_dir: Path,
    *,
    loader_source: Path | None = None,
    nasm: str = "nasm",
) -> dict[str, object]:
    kernel = kernel_path.read_bytes()
    if not kernel:
        raise ValueError("kernel input must not be empty")

    out_dir.mkdir(parents=True, exist_ok=True)
    loader_source = loader_source or Path(__file__).with_name("loader.asm")
    loader_payload = assemble_loader(loader_source, nasm)
    efi_application = build_pe32plus_efi_application(loader_payload)
    pe_coff_validation = validate_pe32plus_efi_application(
        efi_application,
        text_size=len(loader_payload),
    )
    esp_image = build_fat16_esp_image(efi_application, kernel)

    efi_path = out_dir / "BOOTX64.EFI"
    esp_path = out_dir / "esp.img"
    manifest_path = out_dir / "manifest.json"
    efi_path.write_bytes(efi_application)
    esp_path.write_bytes(esp_image)

    manifest = {
        "claim": "host-built-uefi-loader-no-kernel-entry-proof",
        "efi_application": efi_path.name,
        "efi_subsystem": "efi-application",
        "efi_machine": "x86_64",
        "efi_loader_source": str(loader_source),
        "efi_loader_kind": "loader-proof-application",
        "pe_coff_validation": pe_coff_validation,
        "efi_loader_features": [
            "esp-kernel-read",
            "gop-framebuffer-info",
            "uefi-memory-map",
            "elf32-pt-load-placement",
            "bios-compatible-elf32-contract",
            "legacy-boot-info-e820-handoff",
            "pre-exit-boot-info-validation",
            "uefi64-to-protected32-transition",
            "exit-boot-services",
            "debugcon-proof-markers",
        ],
        "esp_image": esp_path.name,
        "esp_format": "fat16-superfloppy",
        "esp_paths": ["EFI/BOOT/BOOTX64.EFI", "VIBEOS/KERNEL.ELF"],
        "kernel_handoff": "source-implemented-pending-ovmf-kernel-entry-marker",
        "kernel_source": str(kernel_path),
        "vm_execution": "not-run",
    }
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kernel", type=Path, required=True, help="kernel ELF bytes to package at VIBEOS/KERNEL.ELF")
    parser.add_argument("--out-dir", type=Path, required=True, help="directory for BOOTX64.EFI, esp.img, manifest.json")
    parser.add_argument("--loader-source", type=Path, default=Path(__file__).with_name("loader.asm"), help="NASM source for the EFI loader payload")
    parser.add_argument("--nasm", default="nasm", help="NASM executable used to assemble loader.asm")
    parser.add_argument("--quiet", action="store_true", help="suppress the manifest summary")
    args = parser.parse_args()

    manifest = build_artifacts(args.kernel, args.out_dir, loader_source=args.loader_source, nasm=args.nasm)
    if not args.quiet:
        print(json.dumps(manifest, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
