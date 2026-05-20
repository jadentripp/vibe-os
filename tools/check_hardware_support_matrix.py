#!/usr/bin/env python3
"""Validate the bounded hardware support matrix and claim wording."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MATRIX = ROOT / "docs" / "hardware-support.md"

CLAIMED_CLASSES = {
    "BIOS_BOOT",
    "IDE_ATA_PIO",
    "FAT16",
    "PS2_KEYBOARD",
    "PS2_MOUSE",
    "PIT",
    "VBE_VGA",
    "SB16",
}

CLAIMED_BOUNDARIES = {
    "BIOS_BOOT": {"scope": "qemu-bios", "proof": "cloud-smoke"},
    "IDE_ATA_PIO": {"scope": "qemu-ide", "proof": "cloud-smoke"},
    "FAT16": {"scope": "generated-disk-image", "proof": "host-and-cloud"},
    "PS2_KEYBOARD": {"scope": "qemu-ps2", "proof": "scripted-cloud-input"},
    "PS2_MOUSE": {"scope": "qemu-ps2", "proof": "scripted-cloud-input"},
    "PIT": {"scope": "qemu-pit", "proof": "cloud-smoke"},
    "VBE_VGA": {"scope": "qemu-vbe-vga", "proof": "host-and-cloud"},
    "SB16": {"scope": "qemu-sb16", "proof": "status-continuity"},
}

UNCLAIMED_CLASSES = {
    "UEFI",
    "PCI_ENUMERATION",
    "AHCI",
    "USB",
    "SMP",
    "APIC",
    "HPET",
    "PHYSICAL_HARDWARE",
}

PROOF_REQUIREMENTS = {
    "UEFI": {
        "artifact": "ovmf-cloud-boot",
        "requires": "pe32-esp-gop-mmap-exitbs",
    },
    "PCI_ENUMERATION": {
        "artifact": "pci-cloud-class-table",
        "requires": "all-bdfs-class-table",
    },
    "AHCI": {
        "artifact": "ahci-cloud-wad-read",
        "requires": "pci-ahci-bar-identify-read",
    },
    "USB": {
        "artifact": "usb-cloud-input-storage",
        "requires": "host-controller-hid-storage",
    },
    "SMP": {
        "artifact": "smp-cloud-run",
        "requires": "ap-startup-percpu-progress",
    },
    "APIC": {
        "artifact": "apic-cloud-irq",
        "requires": "lapic-ioapic-pic-masked",
    },
    "HPET": {
        "artifact": "hpet-cloud-timer",
        "requires": "acpi-hpet-mmio-comparator",
    },
    "PHYSICAL_HARDWARE": {
        "artifact": "disposable-hardware-run",
        "requires": "machine-inventory-status-capture",
    },
}

NEGATIVE_CLAIMS = {
    "UEFI": {
        "scope": "boot",
        "claim": "no-uefi-boot",
        "evidence": "boot-uefi-contract",
    },
    "PCI_ENUMERATION": {
        "scope": "kernel",
        "claim": "no-general-pci-enumeration",
        "evidence": "status-only-qemu-bus0",
    },
    "AHCI": {
        "scope": "storage",
        "claim": "no-ahci-driver",
        "evidence": "ide-only-storage",
    },
    "USB": {
        "scope": "input-storage",
        "claim": "no-usb-stack",
        "evidence": "ps2-ide-only",
    },
    "SMP": {
        "scope": "cpu",
        "claim": "no-multiprocessor-runtime",
        "evidence": "single-cpu-kernel",
    },
    "APIC": {
        "scope": "interrupts",
        "claim": "no-apic-routing",
        "evidence": "pic-pit-only",
    },
    "HPET": {
        "scope": "timer",
        "claim": "no-hpet-timer",
        "evidence": "pit-only",
    },
    "PHYSICAL_HARDWARE": {
        "scope": "hardware",
        "claim": "no-physical-machine-proof",
        "evidence": "qemu-only",
    },
}

NEXT_UNLOCK = {
    "PCI_ENUMERATION": {
        "priority": "first",
        "scope": "qemu-pci",
        "proof": "cloud-class-table",
        "evidence": "none",
    },
}

REQUIRED_MATRIX_PHRASES = (
    "QEMU's legacy PC machine model",
    "BIOS boot",
    "IDE/ATA PIO",
    "FAT16",
    "PS/2 keyboard",
    "PS/2 mouse",
    "PIT",
    "VBE/VGA",
    "SB16",
    "UEFI boot is not implemented",
    "contract-only scaffold",
    "bounded PCI config-space table builder",
    "PCI_STATUS[QEMU_BUS0_CONFIG]",
    "General PCI bus/device/function enumeration is not implemented",
    "AHCI/SATA native storage is not implemented",
    "USB input and storage are not implemented",
    "Multiprocessor startup and scheduling are not implemented",
    "Local APIC, IOAPIC, and APIC timer support are not implemented",
    "HPET timer support is not implemented",
    "No real PC or broad hardware compatibility claim",
    "QEMU evidence alone can only claim the matching QEMU device model",
    "Claimed rows prove only the named QEMU device-model path",
    "Status-only rows are diagnostics, not driver support",
    "PCI_TABLE[QEMU_BUS0_CLASS_TABLE]",
    "bdf-id-class-header",
    "pcitabcap=",
    "pcitabuse=",
    "pciclassh=",
    "PROOF_REQUIREMENT[UEFI]",
    "PROOF_REQUIREMENT[AHCI]",
    "PROOF_REQUIREMENT[USB]",
    "PROOF_REQUIREMENT[APIC]",
    "PROOF_REQUIREMENT[SMP]",
    "PROOF_REQUIREMENT[HPET]",
    "PROOF_REQUIREMENT[PHYSICAL_HARDWARE]",
    "NEGATIVE_CLAIM[UEFI]",
    "NEGATIVE_CLAIM[PCI_ENUMERATION]",
    "NEGATIVE_CLAIM[AHCI]",
    "NEGATIVE_CLAIM[USB]",
    "NEGATIVE_CLAIM[SMP]",
    "NEGATIVE_CLAIM[APIC]",
    "NEGATIVE_CLAIM[HPET]",
    "NEGATIVE_CLAIM[PHYSICAL_HARDWARE]",
    "NEXT_UNLOCK[PCI_ENUMERATION]",
    "PCI enumeration is the next implementable hardware-class unlock",
)

REQUIRED_CROSS_DOC_LINKS = {
    "README.md": (
        "docs/hardware-support.md",
        "boot/uefi/README.md",
        "QEMU BIOS/IDE/PS2/VBE/SB16",
        "not broad PC or physical hardware compatibility",
        "SUPPORT[UEFI] remains unclaimed",
        "pci=",
    ),
    "docs/boot-loader-vm.md": (
        "boot/uefi/README.md",
        "contract-only UEFI scaffold",
        "UEFI_BOOT[...]",
        "SUPPORT[UEFI] remains unclaimed",
        "PCI_STATUS[QEMU_BUS0_CONFIG]",
    ),
    "docs/post-checkpoint-gaps.md": (
        "docs/hardware-support.md",
        "boot/uefi/README.md",
        "UEFI_BOOT[...]",
        "SUPPORT[...]",
        "PCI_STATUS[...]",
        "check_hardware_support_matrix.py",
    ),
    "docs/doom-provenance.md": (
        "docs/hardware-support.md",
        "broad PC",
    ),
    "docs/runbooks/remote-doom-playtest.md": (
        "docs/hardware-support.md",
        "does not prove vibe-os boots directly on physical hardware",
    ),
    "tests/README.md": (
        "tools/check_hardware_support_matrix.py",
        "boot/uefi/README.md",
        "UEFI_BOOT[...]",
        "QEMU BIOS/IDE/PS2/VBE/SB16",
        "pciprobe=",
    ),
}

UEFI_BOOT_REQUIREMENTS = {
    "ENTRY": {"requires": "pe32-efi-application", "proof": "future-host-build"},
    "ESP_STORAGE": {"requires": "fat-esp-kernel-read", "proof": "future-host-build"},
    "FRAMEBUFFER": {"requires": "gop-boot-info", "proof": "future-host-build"},
    "MEMORY_MAP": {"requires": "uefi-memory-map", "proof": "future-host-build"},
    "EXIT_BOOT_SERVICES": {"requires": "exit-before-kernel-handoff", "proof": "future-boot-run"},
    "KERNEL_HANDOFF": {"requires": "elf32-entry-compatible", "proof": "future-boot-run"},
    "BUILD_INTEGRATION": {"requires": "separate-opt-in-target", "proof": "future-host-build"},
}

PCI_STATUS_REQUIREMENTS = {
    "QEMU_BUS0_CONFIG": {
        "status": "status-only",
        "scope": "qemu-pci-bus0",
        "proof": "cloud-smoke-status",
        "evidence": "pci-status-fields",
    },
}

PCI_TABLE_REQUIREMENTS = {
    "QEMU_BUS0_CLASS_TABLE": {
        "status": "status-only",
        "scope": "qemu-pci-bus0",
        "layout": "bdf-id-class-header",
        "capacity": "256",
        "evidence": "pci-table-status-fields",
    },
}

PCI_STATUS_FIELDS = {
    "pci",
    "pciprobe",
    "pcicount",
    "pcifirst",
    "pciid",
    "pciclass",
    "pcitable",
    "pcitabcap",
    "pcitabuse",
    "pcilast",
    "pciclassh",
    "pcimulti",
    "pciclsms",
    "pciclsbr",
}
PCI_QEMU_BUS0_PROBES = 32 * 8

SUPPORT_RE = re.compile(
    r"^- `SUPPORT\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

PCI_STATUS_RE = re.compile(
    r"^- `PCI_STATUS\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

PCI_TABLE_RE = re.compile(
    r"^- `PCI_TABLE\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"layout=(?P<layout>[a-z0-9-]+) "
    r"capacity=(?P<capacity>[0-9]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

PROOF_REQUIREMENT_RE = re.compile(
    r"^- `PROOF_REQUIREMENT\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"artifact=(?P<artifact>[a-z0-9-]+) "
    r"requires=(?P<requires>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

NEGATIVE_CLAIM_RE = re.compile(
    r"^- `NEGATIVE_CLAIM\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"claim=(?P<claim>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

NEXT_UNLOCK_RE = re.compile(
    r"^- `NEXT_UNLOCK\[(?P<id>[A-Z0-9_]+)\] "
    r"priority=(?P<priority>[a-z0-9-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

STATUS_FIELD_RE = re.compile(r"\b([a-z0-9]+)=([^ \r\n]+)")
HEX8_RE = re.compile(r"[0-9A-Fa-f]{8}")

UEFI_BOOT_RE = re.compile(
    r"^- `UEFI_BOOT\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"requires=(?P<requires>[a-z0-9+-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

OVERCLAIM_PATTERNS = (
    re.compile(r"\bsupports?\s+UEFI\b", re.IGNORECASE),
    re.compile(r"\bUEFI\s+support\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+PCI\b", re.IGNORECASE),
    re.compile(r"\bPCI\s+support\b", re.IGNORECASE),
    re.compile(r"\bPCI\s+device\s+enumeration\b", re.IGNORECASE),
    re.compile(r"\bPCI\s+enumeration\s+support\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+AHCI\b", re.IGNORECASE),
    re.compile(r"\bAHCI\s+support\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+USB\b", re.IGNORECASE),
    re.compile(r"\bUSB\s+support\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+SMP\b", re.IGNORECASE),
    re.compile(r"\bSMP\s+support\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+APIC\b", re.IGNORECASE),
    re.compile(r"\bAPIC\s+support\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+HPET\b", re.IGNORECASE),
    re.compile(r"\bHPET\s+support\b", re.IGNORECASE),
    re.compile(r"\bruns?\s+on\s+physical\s+hardware\b", re.IGNORECASE),
    re.compile(r"\bboots?\s+directly\s+on\s+physical\s+hardware\b", re.IGNORECASE),
    re.compile(r"\bphysical[- ]hardware\s+support\b", re.IGNORECASE),
    re.compile(r"\breal\s+hardware\s+support\b", re.IGNORECASE),
    re.compile(r"\bbroad\s+PC\s+hardware\s+support\b", re.IGNORECASE),
    re.compile(r"\bgeneral\s+PC\s+hardware\s+support\b", re.IGNORECASE),
    re.compile(r"\bbroad\s+PC\s+compatibility\b", re.IGNORECASE),
)

NEGATIVE_CONTEXT = (
    "not ",
    "no ",
    "without ",
    "outside ",
    "unclaimed",
    "unsupported",
    "future ",
    "remain",
    "do not ",
    "does not ",
    "cannot ",
    "before ",
    "until ",
    "rather than ",
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _contains_phrase(text: str, phrase: str) -> bool:
    return " ".join(phrase.split()) in " ".join(text.split())


def _repo_text_files(root: Path) -> list[Path]:
    files = [root / "README.md", root / "tests" / "README.md"]
    files.extend(sorted((root / "boot").rglob("*.md")))
    files.extend(sorted((root / "docs").rglob("*.md")))
    files.extend(sorted((root / "tests").rglob("test_*.py")))
    return [path for path in files if path.exists()]


def _has_negative_context(line: str) -> bool:
    lower = line.lower()
    return any(token in lower for token in NEGATIVE_CONTEXT)


def _validate_support_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in SUPPORT_RE.finditer(text):
        support_id = match.group("id")
        if support_id in rows:
            raise AssertionError(f"duplicate SUPPORT row: {support_id}")
        rows[support_id] = match.groupdict()

    required = CLAIMED_CLASSES | UNCLAIMED_CLASSES
    missing = sorted(required - set(rows))
    if missing:
        raise AssertionError(f"missing SUPPORT rows: {', '.join(missing)}")
    extras = sorted(set(rows) - required)
    if extras:
        raise AssertionError(f"unexpected SUPPORT rows: {', '.join(extras)}")

    for support_id in CLAIMED_CLASSES:
        row = rows[support_id]
        if row["status"] != "claimed":
            raise AssertionError(f"{support_id} must be status=claimed")
        boundary = CLAIMED_BOUNDARIES[support_id]
        if row["scope"] != boundary["scope"]:
            raise AssertionError(
                f"{support_id} scope must stay {boundary['scope']} until a new proof boundary exists"
            )
        if row["proof"] != boundary["proof"]:
            raise AssertionError(
                f"{support_id} proof must stay {boundary['proof']} until the matrix changes"
            )
        if row["evidence"] == "none":
            raise AssertionError(f"{support_id} needs evidence")

    for support_id in UNCLAIMED_CLASSES:
        row = rows[support_id]
        if row["status"] != "unclaimed":
            raise AssertionError(f"{support_id} must be status=unclaimed")
        if row["scope"] != "none":
            raise AssertionError(f"{support_id} must keep scope=none until implemented")
        if not (row["proof"].startswith("future") or row["proof"].endswith("hardware-proof")):
            raise AssertionError(f"{support_id} must keep a future/dedicated proof boundary")
        if row["evidence"] != "none":
            raise AssertionError(f"{support_id} must keep evidence=none until implemented")

    if rows["UEFI"]["proof"] != "future-boot-path-proof":
        raise AssertionError("UEFI must keep proof=future-boot-path-proof until a loader exists")

    return rows


def _validate_uefi_boot_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in UEFI_BOOT_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate UEFI_BOOT row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(UEFI_BOOT_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing UEFI_BOOT rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(UEFI_BOOT_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected UEFI_BOOT rows: {', '.join(extras)}")

    for row_id, expected in UEFI_BOOT_REQUIREMENTS.items():
        row = rows[row_id]
        if row["status"] != "unimplemented":
            raise AssertionError(f"UEFI_BOOT[{row_id}] must stay status=unimplemented")
        if row["requires"] != expected["requires"]:
            raise AssertionError(f"UEFI_BOOT[{row_id}] requires must stay {expected['requires']}")
        if row["proof"] != expected["proof"]:
            raise AssertionError(f"UEFI_BOOT[{row_id}] proof must stay {expected['proof']}")
        if row["evidence"] != "none":
            raise AssertionError(f"UEFI_BOOT[{row_id}] must keep evidence=none until implemented")

    return rows


def _validate_pci_status_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in PCI_STATUS_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate PCI_STATUS row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(PCI_STATUS_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing PCI_STATUS rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(PCI_STATUS_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected PCI_STATUS rows: {', '.join(extras)}")

    for row_id, expected in PCI_STATUS_REQUIREMENTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"PCI_STATUS[{row_id}] {key} must stay {value}")

    return rows


def _validate_pci_table_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in PCI_TABLE_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate PCI_TABLE row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(PCI_TABLE_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing PCI_TABLE rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(PCI_TABLE_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected PCI_TABLE rows: {', '.join(extras)}")

    for row_id, expected in PCI_TABLE_REQUIREMENTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"PCI_TABLE[{row_id}] {key} must stay {value}")

    return rows


def _validate_proof_requirement_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in PROOF_REQUIREMENT_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate PROOF_REQUIREMENT row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(PROOF_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing PROOF_REQUIREMENT rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(PROOF_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected PROOF_REQUIREMENT rows: {', '.join(extras)}")

    for row_id, expected in PROOF_REQUIREMENTS.items():
        row = rows[row_id]
        if row["status"] != "future":
            raise AssertionError(f"PROOF_REQUIREMENT[{row_id}] must stay status=future")
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"PROOF_REQUIREMENT[{row_id}] {key} must stay {value}")
        if row["evidence"] != "none":
            raise AssertionError(f"PROOF_REQUIREMENT[{row_id}] must keep evidence=none until proved")

    return rows


def _validate_negative_claim_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in NEGATIVE_CLAIM_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate NEGATIVE_CLAIM row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(NEGATIVE_CLAIMS) - set(rows))
    if missing:
        raise AssertionError(f"missing NEGATIVE_CLAIM rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(NEGATIVE_CLAIMS))
    if extras:
        raise AssertionError(f"unexpected NEGATIVE_CLAIM rows: {', '.join(extras)}")

    for row_id, expected in NEGATIVE_CLAIMS.items():
        row = rows[row_id]
        if row["status"] != "active":
            raise AssertionError(f"NEGATIVE_CLAIM[{row_id}] must stay status=active until proved")
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"NEGATIVE_CLAIM[{row_id}] {key} must stay {value}")

    return rows


def _validate_next_unlock_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in NEXT_UNLOCK_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate NEXT_UNLOCK row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(NEXT_UNLOCK) - set(rows))
    if missing:
        raise AssertionError(f"missing NEXT_UNLOCK rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(NEXT_UNLOCK))
    if extras:
        raise AssertionError(f"unexpected NEXT_UNLOCK rows: {', '.join(extras)}")

    for row_id, expected in NEXT_UNLOCK.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"NEXT_UNLOCK[{row_id}] {key} must stay {value}")

    return rows


def _validate_uefi_scaffold(root: Path) -> dict[str, dict[str, str]]:
    text = _read(root / "boot" / "uefi" / "README.md")
    rows = _validate_uefi_boot_rows(text)

    for phrase in (
        "contract-only placeholder",
        "does not contain a UEFI binary",
        "does not contain a UEFI binary, a PE/COFF image",
        "SUPPORT[UEFI] remains unclaimed",
        "must not describe vibe-os as UEFI-bootable",
        "ExitBootServices",
        "keep local VM execution behind the existing opt-in safety rail",
    ):
        if not _contains_phrase(text, phrase):
            raise AssertionError(f"boot/uefi/README.md missing UEFI scaffold phrase: {phrase}")

    makefile = _read(root / "Makefile")
    if "boot/uefi" in makefile:
        raise AssertionError("boot/uefi must not be wired into the current Makefile image path")

    return rows


def _validate_pci_source_contract(root: Path) -> None:
    kernel = _read(root / "kernel" / "kernel.asm")

    for phrase in (
        "PCI_CONFIG_ADDRESS equ 0x0cf8",
        "PCI_CONFIG_DATA equ 0x0cfc",
        "PCI_CONFIG_ENABLE equ 0x80000000",
        "PCI_CONFIG_HEADER_REG equ 0x0c",
        "PCI_HEADER_MULTIFUNCTION_FLAG equ 0x00800000",
        "PCI_CLASS_MASS_STORAGE equ 0x01",
        "PCI_CLASS_BRIDGE equ 0x06",
        "PCI_SCAN_DEVICE_COUNT equ 32",
        "PCI_SCAN_FUNCTION_COUNT equ 8",
        "PCI_SCAN_FUNCTION_PROBES equ PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT",
        "PCI_TABLE_ENTRY_DWORDS equ 4",
        "PCI_TABLE_ENTRY_SIZE equ PCI_TABLE_ENTRY_DWORDS * 4",
        "PCI_TABLE_BDF_OFFSET equ 0",
        "PCI_TABLE_ID_OFFSET equ 4",
        "PCI_TABLE_CLASS_OFFSET equ 8",
        "PCI_TABLE_HEADER_OFFSET equ 12",
        "PCI_TABLE_MAX_ENTRIES equ PCI_SCAN_FUNCTION_PROBES",
        "call pci_scan_qemu",
        "pci_scan_qemu:",
        "cmp esi, PCI_SCAN_DEVICE_COUNT",
        "cmp edi, PCI_SCAN_FUNCTION_COUNT",
        "mov edi, pci_device_table",
        "rep stosd",
        "PCI_TABLE_BDF_OFFSET",
        "PCI_TABLE_ID_OFFSET",
        "PCI_TABLE_CLASS_OFFSET",
        "PCI_TABLE_HEADER_OFFSET",
        "pci_device_table times PCI_TABLE_MAX_ENTRIES * PCI_TABLE_ENTRY_DWORDS dd 0",
        "out dx, eax",
        "in eax, dx",
        'smoke_pci_text db " pci="',
        'smoke_pciprobe_text db " pciprobe="',
        'smoke_pcicount_text db " pcicount="',
        'smoke_pcifirst_text db " pcifirst="',
        'smoke_pciid_text db " pciid="',
        'smoke_pciclass_text db " pciclass="',
        'smoke_pcitable_text db " pcitable="',
        'smoke_pcitabcap_text db " pcitabcap="',
        'smoke_pcitabuse_text db " pcitabuse="',
        'smoke_pcilast_text db " pcilast="',
        'smoke_pciclassh_text db " pciclassh="',
        'smoke_pcimulti_text db " pcimulti="',
        'smoke_pciclsms_text db " pciclsms="',
        'smoke_pciclsbr_text db " pciclsbr="',
        "pci_probe_count dd 0",
        "pci_function_count dd 0",
        "pci_first_bdf dd 0",
        "pci_first_id dd 0",
        "pci_first_class dd 0",
        "pci_last_bdf dd 0",
        "pci_class_table_hash dd 0",
        "pci_multifunction_device_count dd 0",
        "pci_mass_storage_class_count dd 0",
        "pci_bridge_class_count dd 0",
    ):
        if phrase not in kernel:
            raise AssertionError(f"kernel missing bounded PCI status contract phrase: {phrase}")


def _validate_claim_wording(root: Path) -> None:
    for path in _repo_text_files(root):
        if path == MATRIX:
            continue
        rel = path.relative_to(root)
        lines = _read(path).splitlines()
        for index, line in enumerate(lines):
            line_number = index + 1
            context = " ".join(lines[max(0, index - 1) : min(len(lines), index + 2)])
            for pattern in OVERCLAIM_PATTERNS:
                if pattern.search(line) and not _has_negative_context(context):
                    raise AssertionError(
                        f"{rel}:{line_number}: possible unbounded hardware claim: {line.strip()}"
                    )


def _parse_status_fields(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in STATUS_FIELD_RE.finditer(status):
        name, value = match.group(1), match.group(2)
        if name in fields:
            raise AssertionError(f"duplicate status field: {name}")
        fields[name] = value
    return fields


def _hex8_field(fields: dict[str, str], name: str) -> int:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"status missing {name}= field")
    if not HEX8_RE.fullmatch(value):
        raise AssertionError(f"{name}= must be 8 uppercase/lowercase hex digits")
    return int(value, 16)


def validate_pci_status_text(status: str) -> dict[str, str]:
    fields = _parse_status_fields(status)
    missing = sorted(PCI_STATUS_FIELDS - set(fields))
    if missing:
        raise AssertionError(f"status missing PCI fields: {', '.join(missing)}")

    pci_state = fields["pci"]
    if pci_state not in {"OK", "NONE"}:
        raise AssertionError("pci= must be OK or NONE")

    probes = _hex8_field(fields, "pciprobe")
    if probes != PCI_QEMU_BUS0_PROBES:
        raise AssertionError(f"pciprobe= must be {PCI_QEMU_BUS0_PROBES:08X} for the bounded QEMU bus-0 scan")

    count = _hex8_field(fields, "pcicount")
    first_bdf = _hex8_field(fields, "pcifirst")
    first_id = _hex8_field(fields, "pciid")
    first_class = _hex8_field(fields, "pciclass")
    table_capacity = _hex8_field(fields, "pcitabcap")
    table_used = _hex8_field(fields, "pcitabuse")
    last_bdf = _hex8_field(fields, "pcilast")
    class_hash = _hex8_field(fields, "pciclassh")
    multifunction_count = _hex8_field(fields, "pcimulti")
    mass_storage_count = _hex8_field(fields, "pciclsms")
    bridge_count = _hex8_field(fields, "pciclsbr")

    if fields["pcitable"] != "OK":
        raise AssertionError("pcitable= must be OK for the bounded table builder")
    if table_capacity != PCI_QEMU_BUS0_PROBES:
        raise AssertionError(f"pcitabcap= must be {PCI_QEMU_BUS0_PROBES:08X}")
    if table_used != count:
        raise AssertionError("pcitabuse= must match pcicount=")
    if table_used > table_capacity:
        raise AssertionError("pcitabuse= must not exceed pcitabcap=")

    if pci_state == "NONE":
        if any(
            (
                count,
                first_bdf,
                first_id,
                first_class,
                table_used,
                last_bdf,
                class_hash,
                multifunction_count,
                mass_storage_count,
                bridge_count,
            )
        ):
            raise AssertionError("pci=NONE must keep PCI table counters and summaries at zero")
        return fields

    if count == 0:
        raise AssertionError("pci=OK requires pcicount= to be nonzero")
    if first_bdf >> 16:
        raise AssertionError("pcifirst= must encode a bus-0 device/function, not a broader bus scan")
    device = (first_bdf >> 8) & 0xff
    function = first_bdf & 0xff
    if device >= 32 or function >= 8:
        raise AssertionError("pcifirst= device/function is outside the bounded QEMU bus-0 scan")
    if first_id in (0, 0xffffffff) or (first_id & 0xffff) == 0xffff:
        raise AssertionError("pciid= must record a present config-space vendor/device dword")
    if first_class == 0xffffffff:
        raise AssertionError("pciclass= must record a present config-space class dword")
    if last_bdf >> 16:
        raise AssertionError("pcilast= must encode a bus-0 device/function, not a broader bus scan")
    last_device = (last_bdf >> 8) & 0xff
    last_function = last_bdf & 0xff
    if last_device >= 32 or last_function >= 8:
        raise AssertionError("pcilast= device/function is outside the bounded QEMU bus-0 scan")
    if class_hash == 0:
        raise AssertionError("pciclassh= must summarize the populated PCI class table")
    if any(value > count for value in (multifunction_count, mass_storage_count, bridge_count)):
        raise AssertionError("PCI class-table counters must not exceed pcicount=")

    return fields


def validate_repo_contract(root: Path = ROOT) -> dict[str, dict[str, str]]:
    matrix_text = _read(root / "docs" / "hardware-support.md")

    for phrase in REQUIRED_MATRIX_PHRASES:
        if not _contains_phrase(matrix_text, phrase):
            raise AssertionError(f"hardware support matrix missing phrase: {phrase}")

    rows = _validate_support_rows(matrix_text)
    _validate_pci_status_rows(matrix_text)
    _validate_pci_table_rows(matrix_text)
    _validate_proof_requirement_rows(matrix_text)
    _validate_negative_claim_rows(matrix_text)
    _validate_next_unlock_rows(matrix_text)
    _validate_uefi_scaffold(root)
    _validate_pci_source_contract(root)

    for relative_path, phrases in REQUIRED_CROSS_DOC_LINKS.items():
        text = _read(root / relative_path)
        for phrase in phrases:
            if not _contains_phrase(text, phrase):
                raise AssertionError(f"{relative_path} missing hardware-boundary phrase: {phrase}")

    _validate_claim_wording(root)
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--status", type=Path, help="optional QEMU status.txt to validate for bounded PCI fields")
    args = parser.parse_args()

    try:
        rows = validate_repo_contract()
        if args.status is not None:
            validate_pci_status_text(args.status.read_text(encoding="utf-8"))
    except AssertionError as exc:
        print(f"hardware support matrix failed: {exc}", file=sys.stderr)
        return 1

    claimed = sum(1 for row in rows.values() if row["status"] == "claimed")
    unclaimed = sum(1 for row in rows.values() if row["status"] == "unclaimed")
    status_suffix = "; PCI status OK" if args.status is not None else ""
    print(
        "hardware support matrix OK: "
        f"{claimed} bounded claimed classes, {unclaimed} unclaimed classes"
        f"{status_suffix}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
