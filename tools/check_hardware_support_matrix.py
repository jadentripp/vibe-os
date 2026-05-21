#!/usr/bin/env python3
"""Validate the bounded hardware support matrix and claim wording."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MATRIX = ROOT / "docs" / "architecture.md"

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

UNCLAIMED_BOUNDARIES = {
    "UEFI": {"proof": "future-boot-path-proof"},
    "PCI_ENUMERATION": {"proof": "future-pci-enumeration-table-proof"},
    "AHCI": {"proof": "future-ahci-sata-storage-proof"},
    "USB": {"proof": "future-usb-input-storage-proof"},
    "SMP": {"proof": "future-multiprocessor-runtime-proof"},
    "APIC": {"proof": "future-apic-interrupt-proof"},
    "HPET": {"proof": "future-hpet-timer-proof"},
    "PHYSICAL_HARDWARE": {"proof": "dedicated-hardware-proof"},
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
        "requires": "pe32-esp-gop-mmap-exitbs-boot",
    },
    "PCI_ENUMERATION": {
        "artifact": "pci-cloud-class-table",
        "requires": "all-bdfs-class-subclass-progif-table",
    },
    "AHCI": {
        "artifact": "ahci-cloud-wad-read",
        "requires": "pci-ahci-bar-identify-sata-read",
    },
    "USB": {
        "artifact": "usb-cloud-input-storage",
        "requires": "host-controller-hid-mass-storage",
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
        "requires": "machine-inventory-status-reboot-capture",
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
        "claim": "no-ahci-sata-driver",
        "evidence": "ide-only-storage",
    },
    "USB": {
        "scope": "input-storage",
        "claim": "no-usb-input-or-storage-stack",
        "evidence": "ps2-ide-only",
    },
    "SMP": {
        "scope": "cpu",
        "claim": "no-multiprocessor-runtime",
        "evidence": "single-cpu-kernel",
    },
    "APIC": {
        "scope": "interrupts",
        "claim": "no-apic-ioapic-routing",
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

NEXT_IMPLEMENTATION_CONTRACTS = {
    "PCI_DRIVER_TABLE_API": {
        "status": "host-checked",
        "scope": "qemu-pci",
        "requires": "read-only-index-class-progif-lookup",
        "proof": "host-check-plus-cloud-status",
        "unlocks": "ahci-sata,usb,apic",
        "evidence": "pciapi-status-fields",
    },
}

QEMU_DEVICE_MODELS = {
    "BIOS_BOOT": {
        "status": "claimed",
        "machine": "qemu-legacy-pc",
        "device": "legacy-bios",
        "proof": "cloud-smoke",
        "evidence": "status.txt",
    },
    "IDE_ATA_PIO": {
        "status": "claimed",
        "machine": "qemu-legacy-pc",
        "device": "piix-ide",
        "proof": "cloud-smoke",
        "evidence": "status.txt",
    },
    "PS2_KEYBOARD": {
        "status": "claimed",
        "machine": "qemu-legacy-pc",
        "device": "i8042-keyboard",
        "proof": "scripted-cloud-input",
        "evidence": "status-after-key-phases",
    },
    "PS2_MOUSE": {
        "status": "claimed",
        "machine": "qemu-legacy-pc",
        "device": "i8042-mouse",
        "proof": "scripted-cloud-input",
        "evidence": "status-after-mouse",
    },
    "PIT": {
        "status": "claimed",
        "machine": "qemu-legacy-pc",
        "device": "i8254-pit",
        "proof": "cloud-smoke",
        "evidence": "ticks-dtick",
    },
    "VBE_VGA": {
        "status": "claimed",
        "machine": "qemu-legacy-pc",
        "device": "bochs-vbe-vga",
        "proof": "host-and-cloud",
        "evidence": "framebuffer-status",
    },
    "SB16": {
        "status": "claimed",
        "machine": "qemu-legacy-pc",
        "device": "isa-sb16",
        "proof": "status-continuity",
        "evidence": "audio-status",
    },
    "PCI_BUS0_STATUS": {
        "status": "status-only",
        "machine": "qemu-legacy-pc",
        "device": "pci-config-ports",
        "proof": "cloud-smoke-status",
        "evidence": "pci-status-fields",
    },
}

BOOT_DEVICE_BOUNDARIES = {
    "BIOS_IDE_RAW_LBA": {
        "status": "claimed",
        "firmware": "bios",
        "device": "qemu-ide",
        "layout": "mbr-stage2-raw-lba",
        "proof": "cloud-smoke",
        "evidence": "status.txt",
    },
    "UEFI_ESP_KERNEL_FILE": {
        "status": "future",
        "firmware": "uefi",
        "device": "esp-fat",
        "layout": "pe32-loader-kernel-file",
        "proof": "ovmf-cloud-boot",
        "evidence": "none",
    },
    "AHCI_SATA_DISK": {
        "status": "future",
        "firmware": "bios-or-uefi",
        "device": "ahci-sata",
        "layout": "driver-sector-read",
        "proof": "ahci-cloud-wad-read",
        "evidence": "none",
    },
    "USB_MASS_STORAGE": {
        "status": "future",
        "firmware": "bios-or-uefi",
        "device": "usb-storage",
        "layout": "controller-enumeration-file-read",
        "proof": "usb-cloud-input-storage",
        "evidence": "none",
    },
    "PHYSICAL_MACHINE": {
        "status": "future",
        "firmware": "machine-specific",
        "device": "disposable-pc",
        "layout": "documented-media",
        "proof": "hardware-inventory-boot",
        "evidence": "none",
    },
}

STATUS_PROOFS = {
    "IDE_ATA_PIO": {
        "scope": "qemu-ide",
        "fields": (
            "ata",
            "ataop",
            "atawait",
            "atalba",
            "atastat",
            "ataerr",
            "atafail",
            "atatmo",
        ),
        "evidence": "status.txt",
    },
    "PS2_KEYBOARD": {
        "scope": "qemu-ps2",
        "fields": (
            "inputqueue",
            "inputpoll",
            "inputlast",
            "keyirq",
            "keyqueue",
            "keypoll",
            "keyseen",
            "keylast",
        ),
        "evidence": "status-after-key-phases",
    },
    "PS2_MOUSE": {
        "scope": "qemu-ps2",
        "fields": (
            "mouse",
            "mouseirq",
            "mousepkt",
            "mousepoll",
            "mousebtn",
            "mousedelta",
        ),
        "evidence": "status-after-mouse",
    },
    "VBE_VGA": {
        "scope": "qemu-vbe-vga",
        "fields": (
            "gfx",
            "fb",
            "fbpolicy",
            "fbgeom",
            "fbdirty",
            "doompresent",
            "doompal",
            "doomframe",
            "doomnonzero",
            "doomcolors",
        ),
        "evidence": "framebuffer-status",
    },
    "SB16": {
        "scope": "qemu-sb16",
        "fields": (
            "audio",
            "sb16",
            "dma",
            "play",
            "audioirq",
            "ack8",
            "refill",
            "sfxdma",
            "musicpull",
            "pcmbuf",
        ),
        "evidence": "audio-status",
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
    "CURRENT_TARGET[QEMU_LEGACY_PC]",
    "QEMU BIOS/IDE/PS2/VBE/SB16 is the supported target",
    "AHCI/SATA, USB input/storage, APIC/IOAPIC, HPET, SMP",
    "installation to arbitrary disks are outside the claim",
    "QEMU_DEVICE_MODEL[BIOS_BOOT]",
    "QEMU_DEVICE_MODEL[PCI_BUS0_STATUS]",
    "These rows are the machine-readable reason the current claim is QEMU-only",
    "BOOT_DEVICE_BOUNDARY[BIOS_IDE_RAW_LBA]",
    "BOOT_DEVICE_BOUNDARY[UEFI_ESP_KERNEL_FILE]",
    "BOOT_DEVICE_BOUNDARY[AHCI_SATA_DISK]",
    "BOOT_DEVICE_BOUNDARY[USB_MASS_STORAGE]",
    "BOOT_DEVICE_BOUNDARY[PHYSICAL_MACHINE]",
    "The boot-device boundary is intentionally separate",
    "PCI_TABLE[QEMU_BUS0_CLASS_TABLE]",
    "PCI_TABLE_API[READ_ONLY_LOOKUP]",
    "PCI_TABLE_CONTRACT[QEMU_BUS0_SCAN]",
    "PCI_TABLE_CONTRACT[ENTRY_LAYOUT]",
    "PCI_TABLE_CONTRACT[NO_DRIVER_BINDING]",
    "STATUS_PROOF[IDE_ATA_PIO]",
    "STATUS_PROOF[PS2_KEYBOARD]",
    "STATUS_PROOF[PS2_MOUSE]",
    "STATUS_PROOF[VBE_VGA]",
    "STATUS_PROOF[SB16]",
    "minimum aggregate status fields",
    "packed-bdf-vendor-device-class-progif-header",
    "pcitabcap=",
    "pcitabuse=",
    "pciover=",
    "pciapi=",
    "pcilookmiss=",
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
    "NEXT_IMPLEMENTATION_CONTRACT[PCI_DRIVER_TABLE_API]",
    "PCI enumeration is the next implementable hardware-class unlock",
)

REQUIRED_CROSS_DOC_LINKS = {
    "README.md": (
        "docs/architecture.md",
        "boot/uefi/CONTRACT.txt",
        "QEMU BIOS/IDE/PS2/VBE/SB16",
        "That evidence is limited to the emulated device model",
        "SUPPORT[UEFI] remains unclaimed",
        "pci=",
    ),
    "docs/architecture.md": (
        "boot/uefi/CONTRACT.txt",
        "contract-only UEFI scaffold",
        "UEFI_BOOT[...]",
        "SUPPORT[UEFI] remains unclaimed",
        "PCI_STATUS[QEMU_BUS0_CONFIG]",
    ),
    "docs/proof.md": (
        "docs/architecture.md",
        "boot/uefi/CONTRACT.txt",
        "UEFI_BOOT[...]",
        "SUPPORT[...]",
        "PCI_STATUS[...]",
        "check_hardware_support_matrix.py",
    ),
    "docs/doom-provenance.txt": (
        "docs/architecture.md",
        "broad PC",
    ),
    "docs/play.md": (
        "docs/architecture.md",
        "does not prove vibe-os boots directly on physical hardware",
    ),
    "tests/strategy.txt": (
        "tools/check_hardware_support_matrix.py",
        "boot/uefi/CONTRACT.txt",
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

UEFI_BOOT_DEVICE_REQUIREMENTS = {
    "ESP_IMAGE": {"requires": "fat-esp-kernel-file", "proof": "future-host-build"},
    "OVMF_BOOT": {"requires": "ovmf-loads-efi-from-esp", "proof": "future-boot-run"},
    "NO_RAW_LBA_FALLBACK": {
        "requires": "no-stage2-raw-lba-dependency",
        "proof": "future-contract-check",
    },
    "PHYSICAL_MEDIA": {
        "requires": "machine-inventory-disposable-media",
        "proof": "future-lab-run",
    },
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
        "layout": "packed-bdf-vendor-device-class-progif-header",
        "capacity": "256",
        "evidence": "pci-table-status-fields",
    },
}

PCI_TABLE_API_REQUIREMENTS = {
    "READ_ONLY_LOOKUP": {
        "status": "status-only",
        "scope": "qemu-pci-bus0",
        "contract": "kernel-maintained-read-only-table",
        "lookup": "index-class-subclass-progif",
        "consumers": "future-drivers",
        "evidence": "pciapi-status-fields",
    },
}

PCI_TABLE_CONTRACT_REQUIREMENTS = {
    "QEMU_BUS0_SCAN": {
        "status": "status-only",
        "bus": "0",
        "devices": "32",
        "functions": "8",
        "evidence": "pci-status-fields",
    },
    "ENTRY_LAYOUT": {
        "status": "status-only",
        "dwords": "4",
        "fields": "bus,device,function,vendor-id,device-id,base-class,subclass,prog-if,header",
        "evidence": "pci-table-status-fields",
    },
    "NO_DRIVER_BINDING": {
        "status": "guardrail",
        "consumers": "status-only",
        "drivers": "none",
        "evidence": "negative-claims",
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
    "pciover",
    "pcilast",
    "pciclassh",
    "pcimulti",
    "pciclsms",
    "pciclsbr",
    "pciapi",
    "pcilookms",
    "pcilookbr",
    "pcilookmiss",
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

PCI_TABLE_API_RE = re.compile(
    r"^- `PCI_TABLE_API\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"contract=(?P<contract>[a-z0-9-]+) "
    r"lookup=(?P<lookup>[a-z0-9-]+) "
    r"consumers=(?P<consumers>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

PCI_TABLE_SCAN_CONTRACT_RE = re.compile(
    r"^- `PCI_TABLE_CONTRACT\[(?P<id>QEMU_BUS0_SCAN)\] "
    r"status=(?P<status>[a-z-]+) "
    r"bus=(?P<bus>[0-9]+) "
    r"devices=(?P<devices>[0-9]+) "
    r"functions=(?P<functions>[0-9]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

PCI_TABLE_LAYOUT_CONTRACT_RE = re.compile(
    r"^- `PCI_TABLE_CONTRACT\[(?P<id>ENTRY_LAYOUT)\] "
    r"status=(?P<status>[a-z-]+) "
    r"dwords=(?P<dwords>[0-9]+) "
    r"fields=(?P<fields>[a-z0-9_,-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

PCI_TABLE_GUARDRAIL_CONTRACT_RE = re.compile(
    r"^- `PCI_TABLE_CONTRACT\[(?P<id>NO_DRIVER_BINDING)\] "
    r"status=(?P<status>[a-z-]+) "
    r"consumers=(?P<consumers>[a-z0-9-]+) "
    r"drivers=(?P<drivers>[a-z0-9-]+) "
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

NEXT_IMPLEMENTATION_CONTRACT_RE = re.compile(
    r"^- `NEXT_IMPLEMENTATION_CONTRACT\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"requires=(?P<requires>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"unlocks=(?P<unlocks>[a-z0-9_,-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

QEMU_DEVICE_MODEL_RE = re.compile(
    r"^- `QEMU_DEVICE_MODEL\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"machine=(?P<machine>[a-z0-9-]+) "
    r"device=(?P<device>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

BOOT_DEVICE_BOUNDARY_RE = re.compile(
    r"^- `BOOT_DEVICE_BOUNDARY\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"firmware=(?P<firmware>[a-z0-9-]+) "
    r"device=(?P<device>[a-z0-9-]+) "
    r"layout=(?P<layout>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

STATUS_PROOF_RE = re.compile(
    r"^- `STATUS_PROOF\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"fields=(?P<fields>[a-z0-9_,]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

CURRENT_TARGET_RE = re.compile(
    r"^- `CURRENT_TARGET\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"machine=(?P<machine>[a-z0-9-]+) "
    r"includes=(?P<includes>[a-z0-9_,-]+) "
    r"excludes=(?P<excludes>[a-z0-9_,-]+) "
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

UEFI_BOOT_DEVICE_RE = re.compile(
    r"^- `UEFI_BOOT_DEVICE\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"requires=(?P<requires>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

OVERCLAIM_PATTERNS = (
    re.compile(r"\bsupports?\s+UEFI\b", re.IGNORECASE),
    re.compile(r"\bUEFI\s+support\b", re.IGNORECASE),
    re.compile(r"\bUEFI[- ]bootable\b", re.IGNORECASE),
    re.compile(r"\bUEFI\s+boot\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+PCI\b", re.IGNORECASE),
    re.compile(r"\bPCI\s+support\b", re.IGNORECASE),
    re.compile(r"\bPCI\s+device\s+enumeration\b", re.IGNORECASE),
    re.compile(r"\bPCI\s+enumeration\s+support\b", re.IGNORECASE),
    re.compile(r"\bPCI\s+enumeration\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+AHCI\b", re.IGNORECASE),
    re.compile(r"\bAHCI\s+support\b", re.IGNORECASE),
    re.compile(r"\bAHCI(?:/SATA)?\s+(?:driver|storage|disk)\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+USB\b", re.IGNORECASE),
    re.compile(r"\bUSB\s+support\b", re.IGNORECASE),
    re.compile(r"\bUSB\s+(?:stack|HID|input|storage|mass-storage)\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+SMP\b", re.IGNORECASE),
    re.compile(r"\bSMP\s+support\b", re.IGNORECASE),
    re.compile(r"\b(?:SMP|multiprocessor\s+runtime)\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+APIC\b", re.IGNORECASE),
    re.compile(r"\bAPIC\s+support\b", re.IGNORECASE),
    re.compile(r"\bAPIC(?:/IOAPIC)?\s+(?:routing|interrupts?|timer)\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
    re.compile(r"\bsupports?\s+HPET\b", re.IGNORECASE),
    re.compile(r"\bHPET\s+support\b", re.IGNORECASE),
    re.compile(r"\bHPET\s+timer\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
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
    "narrower",
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _contains_phrase(text: str, phrase: str) -> bool:
    return " ".join(phrase.split()) in " ".join(text.split())


def _repo_text_files(root: Path) -> list[Path]:
    files = [root / "README.md", root / "tests" / "strategy.txt"]
    files.extend(sorted((root / "boot").rglob("*.md")))
    files.extend(sorted((root / "docs").rglob("*.md")))
    files.extend(sorted((root / "tests").rglob("test_*.py")))
    return [path for path in files if path.exists()]


def _has_negative_context(line: str) -> bool:
    lower = line.lower()
    return any(token in lower for token in NEGATIVE_CONTEXT)


def _validate_no_unbounded_claims(label: str, text: str) -> None:
    lines = text.splitlines()
    for index, line in enumerate(lines):
        line_number = index + 1
        context = " ".join(lines[max(0, index - 1) : min(len(lines), index + 2)])
        for pattern in OVERCLAIM_PATTERNS:
            if pattern.search(line) and not _has_negative_context(context):
                raise AssertionError(
                    f"{label}:{line_number}: possible unbounded hardware claim: {line.strip()}"
                )


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
        expected_proof = UNCLAIMED_BOUNDARIES[support_id]["proof"]
        if row["proof"] != expected_proof:
            raise AssertionError(f"{support_id} proof must stay {expected_proof} until implemented")
        if row["evidence"] != "none":
            raise AssertionError(f"{support_id} must keep evidence=none until implemented")

    return rows


def _validate_current_target_row(text: str) -> dict[str, str]:
    matches = list(CURRENT_TARGET_RE.finditer(text))
    if len(matches) != 1:
        raise AssertionError("hardware matrix must contain exactly one CURRENT_TARGET row")
    row = matches[0].groupdict()
    if row["id"] != "QEMU_LEGACY_PC":
        raise AssertionError("CURRENT_TARGET row must be QEMU_LEGACY_PC")
    if row["status"] != "claimed":
        raise AssertionError("CURRENT_TARGET[QEMU_LEGACY_PC] must stay status=claimed")
    if row["machine"] != "qemu-legacy-pc":
        raise AssertionError("CURRENT_TARGET[QEMU_LEGACY_PC] must stay machine=qemu-legacy-pc")

    includes = set(row["includes"].split(","))
    excludes = set(row["excludes"].split(","))
    expected_includes = {
        "bios",
        "ide-ata-pio",
        "ps2-keyboard",
        "ps2-mouse",
        "pit",
        "vbe-vga",
        "sb16",
    }
    expected_excludes = {
        "uefi",
        "physical-hardware",
        "general-pci",
        "ahci-sata",
        "usb-input-storage",
        "apic-ioapic",
        "hpet",
        "smp",
        "arbitrary-disk-install",
    }
    if includes != expected_includes:
        raise AssertionError(
            "CURRENT_TARGET[QEMU_LEGACY_PC] includes must stay "
            + ",".join(sorted(expected_includes))
        )
    if excludes != expected_excludes:
        raise AssertionError(
            "CURRENT_TARGET[QEMU_LEGACY_PC] excludes must stay "
            + ",".join(sorted(expected_excludes))
        )
    if row["evidence"] != "support-rows":
        raise AssertionError("CURRENT_TARGET[QEMU_LEGACY_PC] evidence must stay support-rows")
    return row


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


def _validate_uefi_boot_device_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in UEFI_BOOT_DEVICE_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate UEFI_BOOT_DEVICE row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(UEFI_BOOT_DEVICE_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing UEFI_BOOT_DEVICE rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(UEFI_BOOT_DEVICE_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected UEFI_BOOT_DEVICE rows: {', '.join(extras)}")

    for row_id, expected in UEFI_BOOT_DEVICE_REQUIREMENTS.items():
        row = rows[row_id]
        if row["status"] != "unimplemented":
            raise AssertionError(f"UEFI_BOOT_DEVICE[{row_id}] must stay status=unimplemented")
        if row["requires"] != expected["requires"]:
            raise AssertionError(
                f"UEFI_BOOT_DEVICE[{row_id}] requires must stay {expected['requires']}"
            )
        if row["proof"] != expected["proof"]:
            raise AssertionError(f"UEFI_BOOT_DEVICE[{row_id}] proof must stay {expected['proof']}")
        if row["evidence"] != "none":
            raise AssertionError(
                f"UEFI_BOOT_DEVICE[{row_id}] must keep evidence=none until implemented"
            )

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


def _validate_pci_table_api_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in PCI_TABLE_API_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate PCI_TABLE_API row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(PCI_TABLE_API_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing PCI_TABLE_API rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(PCI_TABLE_API_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected PCI_TABLE_API rows: {', '.join(extras)}")

    for row_id, expected in PCI_TABLE_API_REQUIREMENTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"PCI_TABLE_API[{row_id}] {key} must stay {value}")
        if "ahci" in row["consumers"] or "usb" in row["consumers"]:
            raise AssertionError(
                f"PCI_TABLE_API[{row_id}] must not name AHCI or USB as current consumers"
            )

    return rows


def _validate_pci_table_contract_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for pattern in (
        PCI_TABLE_SCAN_CONTRACT_RE,
        PCI_TABLE_LAYOUT_CONTRACT_RE,
        PCI_TABLE_GUARDRAIL_CONTRACT_RE,
    ):
        for match in pattern.finditer(text):
            row_id = match.group("id")
            if row_id in rows:
                raise AssertionError(f"duplicate PCI_TABLE_CONTRACT row: {row_id}")
            rows[row_id] = match.groupdict()

    missing = sorted(set(PCI_TABLE_CONTRACT_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing PCI_TABLE_CONTRACT rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(PCI_TABLE_CONTRACT_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected PCI_TABLE_CONTRACT rows: {', '.join(extras)}")

    for row_id, expected in PCI_TABLE_CONTRACT_REQUIREMENTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"PCI_TABLE_CONTRACT[{row_id}] {key} must stay {value}")

    scan = rows["QEMU_BUS0_SCAN"]
    layout = rows["ENTRY_LAYOUT"]
    capacity = int(PCI_TABLE_REQUIREMENTS["QEMU_BUS0_CLASS_TABLE"]["capacity"])
    if int(scan["devices"]) * int(scan["functions"]) != capacity:
        raise AssertionError("PCI_TABLE_CONTRACT[QEMU_BUS0_SCAN] bounds must match table capacity")
    if int(layout["dwords"]) != 4:
        raise AssertionError("PCI_TABLE_CONTRACT[ENTRY_LAYOUT] dwords must stay 4")
    fields = set(layout["fields"].split(","))
    required_fields = set(PCI_TABLE_CONTRACT_REQUIREMENTS["ENTRY_LAYOUT"]["fields"].split(","))
    if fields != required_fields:
        raise AssertionError("PCI_TABLE_CONTRACT[ENTRY_LAYOUT] fields must name the packed API fields")

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


def _validate_next_implementation_contract_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in NEXT_IMPLEMENTATION_CONTRACT_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate NEXT_IMPLEMENTATION_CONTRACT row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(NEXT_IMPLEMENTATION_CONTRACTS) - set(rows))
    if missing:
        raise AssertionError(f"missing NEXT_IMPLEMENTATION_CONTRACT rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(NEXT_IMPLEMENTATION_CONTRACTS))
    if extras:
        raise AssertionError(f"unexpected NEXT_IMPLEMENTATION_CONTRACT rows: {', '.join(extras)}")

    for row_id, expected in NEXT_IMPLEMENTATION_CONTRACTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"NEXT_IMPLEMENTATION_CONTRACT[{row_id}] {key} must stay {value}")
        unlocks = set(row["unlocks"].split(","))
        if not {"ahci-sata", "usb", "apic"}.issubset(unlocks):
            raise AssertionError(
                f"NEXT_IMPLEMENTATION_CONTRACT[{row_id}] must keep future driver unlocks explicit"
            )

    return rows


def _validate_qemu_device_model_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in QEMU_DEVICE_MODEL_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate QEMU_DEVICE_MODEL row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(QEMU_DEVICE_MODELS) - set(rows))
    if missing:
        raise AssertionError(f"missing QEMU_DEVICE_MODEL rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(QEMU_DEVICE_MODELS))
    if extras:
        raise AssertionError(f"unexpected QEMU_DEVICE_MODEL rows: {', '.join(extras)}")

    for row_id, expected in QEMU_DEVICE_MODELS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"QEMU_DEVICE_MODEL[{row_id}] {key} must stay {value}")
        if row["machine"] != "qemu-legacy-pc":
            raise AssertionError(f"QEMU_DEVICE_MODEL[{row_id}] must stay QEMU-only")
        if row["status"] == "claimed" and row_id not in CLAIMED_CLASSES:
            raise AssertionError(f"QEMU_DEVICE_MODEL[{row_id}] cannot claim an unsupported class")

    return rows


def _validate_boot_device_boundary_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in BOOT_DEVICE_BOUNDARY_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate BOOT_DEVICE_BOUNDARY row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(BOOT_DEVICE_BOUNDARIES) - set(rows))
    if missing:
        raise AssertionError(f"missing BOOT_DEVICE_BOUNDARY rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(BOOT_DEVICE_BOUNDARIES))
    if extras:
        raise AssertionError(f"unexpected BOOT_DEVICE_BOUNDARY rows: {', '.join(extras)}")

    for row_id, expected in BOOT_DEVICE_BOUNDARIES.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"BOOT_DEVICE_BOUNDARY[{row_id}] {key} must stay {value}")
        if row["status"] == "future" and row["evidence"] != "none":
            raise AssertionError(f"BOOT_DEVICE_BOUNDARY[{row_id}] must keep evidence=none until proved")
        if row["status"] == "claimed" and row["device"] != "qemu-ide":
            raise AssertionError("only the QEMU IDE raw-LBA boot device is claimed today")

    return rows


def _validate_status_proof_rows(text: str) -> dict[str, dict[str, object]]:
    rows: dict[str, dict[str, object]] = {}
    for match in STATUS_PROOF_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate STATUS_PROOF row: {row_id}")
        row = match.groupdict()
        row["fields"] = tuple(row["fields"].split(","))
        rows[row_id] = row

    missing = sorted(set(STATUS_PROOFS) - set(rows))
    if missing:
        raise AssertionError(f"missing STATUS_PROOF rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(STATUS_PROOFS))
    if extras:
        raise AssertionError(f"unexpected STATUS_PROOF rows: {', '.join(extras)}")

    for row_id, expected in STATUS_PROOFS.items():
        row = rows[row_id]
        if row["status"] != "required":
            raise AssertionError(f"STATUS_PROOF[{row_id}] must stay status=required")
        if row["scope"] != expected["scope"]:
            raise AssertionError(f"STATUS_PROOF[{row_id}] scope must stay {expected['scope']}")
        if row["fields"] != expected["fields"]:
            expected_fields = ",".join(expected["fields"])
            raise AssertionError(f"STATUS_PROOF[{row_id}] fields must stay {expected_fields}")
        if row["evidence"] != expected["evidence"]:
            raise AssertionError(f"STATUS_PROOF[{row_id}] evidence must stay {expected['evidence']}")

    return rows


def _validate_uefi_scaffold(root: Path) -> dict[str, dict[str, str]]:
    text = _read(root / "boot" / "uefi" / "CONTRACT.txt")
    rows = _validate_uefi_boot_rows(text)
    _validate_uefi_boot_device_rows(text)

    for phrase in (
        "contract-only placeholder",
        "does not contain a UEFI binary",
        "does not contain a UEFI binary, a PE/COFF image",
        "SUPPORT[UEFI] remains unclaimed",
        "UEFI_BOOT_DEVICE[ESP_IMAGE]",
        "future boot-device proof boundary",
        "NO_RAW_LBA_FALLBACK",
        "must not describe vibe-os as UEFI-bootable",
        "ExitBootServices",
        "keep local VM execution behind the existing opt-in safety rail",
        "exact machine inventory and disposable media details",
    ):
        if not _contains_phrase(text, phrase):
            raise AssertionError(f"boot/uefi/CONTRACT.txt missing UEFI scaffold phrase: {phrase}")

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
        "PCI_LOOKUP_ANY equ 0xff",
        "PCI_LOOKUP_NOT_FOUND equ 0xffffffff",
        "PCI_SCAN_DEVICE_COUNT equ 32",
        "PCI_SCAN_FUNCTION_COUNT equ 8",
        "PCI_SCAN_FUNCTION_PROBES equ PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT",
        "PCI_TABLE_ENTRY_DWORDS equ 4",
        "PCI_TABLE_ENTRY_SHIFT equ 4",
        "PCI_TABLE_ENTRY_SIZE equ PCI_TABLE_ENTRY_DWORDS * 4",
        "PCI table entry dword 0: bus[23:16], device[15:8], function[7:0]",
        "device-id[31:16] and vendor-id[15:0]",
        "class[31:24], subclass[23:16], prog-if[15:8]",
        "PCI_TABLE_LOCATION_OFFSET equ 0",
        "PCI_TABLE_VENDOR_DEVICE_OFFSET equ 4",
        "PCI_TABLE_CLASS_OFFSET equ 8",
        "PCI_TABLE_HEADER_OFFSET equ 12",
        "PCI_TABLE_MAX_ENTRIES equ PCI_SCAN_FUNCTION_PROBES",
        "call pci_scan_qemu",
        "pci_scan_qemu:",
        "mov byte [pci_table_api_status], 0",
        "cmp esi, PCI_SCAN_DEVICE_COUNT",
        "cmp edi, PCI_SCAN_FUNCTION_COUNT",
        "mov edi, pci_device_table",
        "rep stosd",
        "PCI_TABLE_LOCATION_OFFSET",
        "PCI_TABLE_VENDOR_DEVICE_OFFSET",
        "PCI_TABLE_CLASS_OFFSET",
        "PCI_TABLE_HEADER_OFFSET",
        "pci_table_entry_by_index:",
        "pci_table_find_first_by_class:",
        "pci_table_probe_lookup_contract:",
        "call pci_table_probe_lookup_contract",
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
        'smoke_pciover_text db " pciover="',
        'smoke_pcilast_text db " pcilast="',
        'smoke_pciclassh_text db " pciclassh="',
        'smoke_pcimulti_text db " pcimulti="',
        'smoke_pciclsms_text db " pciclsms="',
        'smoke_pciclsbr_text db " pciclsbr="',
        'smoke_pciapi_text db " pciapi="',
        'smoke_pcilookms_text db " pcilookms="',
        'smoke_pcilookbr_text db " pcilookbr="',
        'smoke_pcilookmiss_text db " pcilookmiss="',
        "pci_probe_count dd 0",
        "pci_function_count dd 0",
        "pci_table_count dd 0",
        "pci_table_overflow_count dd 0",
        "pci_first_bdf dd 0",
        "pci_first_id dd 0",
        "pci_first_class dd 0",
        "pci_last_bdf dd 0",
        "pci_class_table_hash dd 0",
        "pci_multifunction_device_count dd 0",
        "pci_mass_storage_class_count dd 0",
        "pci_bridge_class_count dd 0",
        "pci_lookup_mass_storage_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_bridge_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_miss_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_table_api_status db 0",
    ):
        if phrase not in kernel:
            raise AssertionError(f"kernel missing bounded PCI status contract phrase: {phrase}")


def _validate_claim_wording(root: Path) -> None:
    for path in _repo_text_files(root):
        if path == MATRIX:
            continue
        rel = path.relative_to(root)
        _validate_no_unbounded_claims(str(rel), _read(path))


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


def _hex_tuple_field(fields: dict[str, str], name: str, count: int, sep: str = ":") -> tuple[int, ...]:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"status missing {name}= field")
    parts = value.split(sep)
    if len(parts) != count or any(HEX8_RE.fullmatch(part) is None for part in parts):
        raise AssertionError(f"{name}= must contain {count} 8-digit hex fields separated by {sep!r}")
    return tuple(int(part, 16) for part in parts)


def _require_fields(fields: dict[str, str], names: tuple[str, ...], label: str) -> None:
    missing = sorted(set(names) - set(fields))
    if missing:
        raise AssertionError(f"status missing {label} fields: {', '.join(missing)}")


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
    table_overflow = _hex8_field(fields, "pciover")
    last_bdf = _hex8_field(fields, "pcilast")
    class_hash = _hex8_field(fields, "pciclassh")
    multifunction_count = _hex8_field(fields, "pcimulti")
    mass_storage_count = _hex8_field(fields, "pciclsms")
    bridge_count = _hex8_field(fields, "pciclsbr")
    lookup_mass_storage = _hex8_field(fields, "pcilookms")
    lookup_bridge = _hex8_field(fields, "pcilookbr")
    lookup_miss = _hex8_field(fields, "pcilookmiss")

    if fields["pcitable"] != "OK":
        raise AssertionError("pcitable= must be OK for the bounded table builder")
    if fields["pciapi"] != "OK":
        raise AssertionError("pciapi= must be OK for the read-only PCI table lookup API")
    if table_capacity != PCI_QEMU_BUS0_PROBES:
        raise AssertionError(f"pcitabcap= must be {PCI_QEMU_BUS0_PROBES:08X}")
    if table_overflow == 0 and table_used != count:
        raise AssertionError("pcitabuse= must match pcicount= when pciover= is zero")
    if table_overflow != 0 and table_used != table_capacity:
        raise AssertionError("pcitabuse= must equal pcitabcap= when pciover= is nonzero")
    if table_used > count:
        raise AssertionError("pcitabuse= must not exceed pcicount=")
    if table_used > table_capacity:
        raise AssertionError("pcitabuse= must not exceed pcitabcap=")
    if lookup_miss != 0xFFFFFFFF:
        raise AssertionError("pcilookmiss= must expose the PCI lookup miss sentinel")

    if pci_state == "NONE":
        if any(
            (
                count,
                first_bdf,
                first_id,
                first_class,
                table_used,
                table_overflow,
                last_bdf,
                class_hash,
                multifunction_count,
                mass_storage_count,
                bridge_count,
            )
        ):
            raise AssertionError("pci=NONE must keep PCI table counters and summaries at zero")
        if lookup_mass_storage != 0xFFFFFFFF or lookup_bridge != 0xFFFFFFFF:
            raise AssertionError("pci=NONE must keep PCI class lookups at the miss sentinel")
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
    for field_name, bdf in (
        ("pcilookms", lookup_mass_storage),
        ("pcilookbr", lookup_bridge),
    ):
        if bdf == 0xFFFFFFFF:
            continue
        if bdf >> 16:
            raise AssertionError(f"{field_name}= must encode a bus-0 device/function")
        lookup_device = (bdf >> 8) & 0xff
        lookup_function = bdf & 0xff
        if lookup_device >= 32 or lookup_function >= 8:
            raise AssertionError(f"{field_name}= device/function is outside the bounded QEMU bus-0 scan")
    if mass_storage_count and lookup_mass_storage == 0xFFFFFFFF:
        raise AssertionError("pcilookms= must find the first mass-storage class entry when pciclsms= is nonzero")
    if bridge_count and lookup_bridge == 0xFFFFFFFF:
        raise AssertionError("pcilookbr= must find the first bridge class entry when pciclsbr= is nonzero")

    return fields


def validate_claimed_hardware_status_text(status: str) -> dict[str, str]:
    fields = _parse_status_fields(status)
    for proof_id, proof in STATUS_PROOFS.items():
        _require_fields(fields, proof["fields"], proof_id)

    if fields["ata"] != "OK":
        raise AssertionError("ata= must be OK for claimed IDE/ATA PIO proof")
    if fields["ataop"] not in {"READ", "WRITE"}:
        raise AssertionError("ataop= must prove a completed ATA READ or WRITE")
    if fields["atawait"] != "IDLE":
        raise AssertionError("atawait= must return to IDLE after the ATA proof transfer")
    _hex8_field(fields, "atalba")
    _hex8_field(fields, "atastat")
    if _hex8_field(fields, "ataerr") != 0:
        raise AssertionError("ataerr= must be zero for claimed IDE/ATA PIO proof")
    if _hex8_field(fields, "atafail") != 0:
        raise AssertionError("atafail= must be zero for claimed IDE/ATA PIO proof")
    if _hex8_field(fields, "atatmo") != 0:
        raise AssertionError("atatmo= must be zero for claimed IDE/ATA PIO proof")

    for name in ("inputqueue", "inputpoll", "keyirq", "keyqueue", "keypoll", "keyseen"):
        if _hex8_field(fields, name) == 0:
            raise AssertionError(f"{name}= must be nonzero for claimed PS/2 keyboard proof")
    input_last = _hex_tuple_field(fields, "inputlast", 3)
    if input_last[1] == 0 or input_last[2] == 0:
        raise AssertionError("inputlast= must record a keyboard or mouse device/type proof")
    _hex8_field(fields, "keylast")

    if fields["mouse"] != "OK":
        raise AssertionError("mouse= must be OK for claimed PS/2 mouse proof")
    for name in ("mouseirq", "mousepkt", "mousepoll", "mousebtn"):
        if _hex8_field(fields, name) == 0:
            raise AssertionError(f"{name}= must be nonzero for claimed PS/2 mouse proof")
    mouse_dx, mouse_dy = _hex_tuple_field(fields, "mousedelta", 2)
    if mouse_dx == 0 and mouse_dy == 0:
        raise AssertionError("mousedelta= must record scripted mouse movement")

    if fields["gfx"] != "OK":
        raise AssertionError("gfx= must be OK for claimed VBE/VGA proof")
    if fields["fb"] not in {"LFB", "M13"}:
        raise AssertionError("fb= must be LFB or M13 for claimed VBE/VGA proof")
    if fields["fbpolicy"] not in {"ASP", "SQ", "M13"}:
        raise AssertionError("fbpolicy= must be ASP, SQ, or M13 for claimed VBE/VGA proof")
    _hex_tuple_field(fields, "fbgeom", 5)
    _hex_tuple_field(fields, "fbdirty", 5)
    for name in ("doompresent", "doompal", "doomframe", "doomnonzero", "doomcolors"):
        if _hex8_field(fields, name) == 0:
            raise AssertionError(f"{name}= must be nonzero for claimed VBE/VGA proof")

    if fields["audio"] != "SB16":
        raise AssertionError("audio= must be SB16 for claimed SB16 proof")
    sb16_major, _sb16_minor = _hex_tuple_field(fields, "sb16", 2)
    if sb16_major == 0:
        raise AssertionError("sb16= must expose a nonzero DSP major version")
    for name in ("dma", "audioirq", "ack8", "refill"):
        if _hex8_field(fields, name) == 0:
            raise AssertionError(f"{name}= must be nonzero for claimed SB16 proof")
    play_start, _play_stop = _hex_tuple_field(fields, "play", 2)
    if play_start == 0:
        raise AssertionError("play= must record a playback start for claimed SB16 proof")
    sfx_dma_count, sfx_dma_bytes = _hex_tuple_field(fields, "sfxdma", 2)
    if sfx_dma_count == 0 or sfx_dma_bytes == 0:
        raise AssertionError("sfxdma= must record DMA SFX refill work for claimed SB16 proof")
    pull_requests, pull_refills = _hex_tuple_field(fields, "musicpull", 2)
    if pull_requests == 0 or pull_refills == 0:
        raise AssertionError("musicpull= must record hardware-paced pull-stream work")
    pcm_buffer_size, pcm_block_size, _pcm_write_pos, _pcm_half = _hex_tuple_field(fields, "pcmbuf", 4)
    if pcm_buffer_size == 0 or pcm_block_size == 0:
        raise AssertionError("pcmbuf= must expose nonzero SB16 PCM buffer geometry")

    validate_pci_status_text(status)
    return fields


def validate_repo_contract(root: Path = ROOT) -> dict[str, dict[str, str]]:
    matrix_text = _read(root / "docs" / "architecture.md")

    for phrase in REQUIRED_MATRIX_PHRASES:
        if not _contains_phrase(matrix_text, phrase):
            raise AssertionError(f"hardware support matrix missing phrase: {phrase}")

    rows = _validate_support_rows(matrix_text)
    _validate_current_target_row(matrix_text)
    _validate_qemu_device_model_rows(matrix_text)
    _validate_boot_device_boundary_rows(matrix_text)
    _validate_pci_status_rows(matrix_text)
    _validate_pci_table_rows(matrix_text)
    _validate_pci_table_api_rows(matrix_text)
    _validate_pci_table_contract_rows(matrix_text)
    _validate_proof_requirement_rows(matrix_text)
    _validate_negative_claim_rows(matrix_text)
    _validate_next_unlock_rows(matrix_text)
    _validate_next_implementation_contract_rows(matrix_text)
    _validate_status_proof_rows(matrix_text)
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
    parser.add_argument(
        "--claimed-hardware-status",
        type=Path,
        help="optional QEMU status.txt to validate against claimed hardware proof counters",
    )
    args = parser.parse_args()

    try:
        rows = validate_repo_contract()
        if args.status is not None:
            validate_pci_status_text(args.status.read_text(encoding="utf-8"))
        if args.claimed_hardware_status is not None:
            validate_claimed_hardware_status_text(
                args.claimed_hardware_status.read_text(encoding="utf-8")
            )
    except AssertionError as exc:
        print(f"hardware support matrix failed: {exc}", file=sys.stderr)
        return 1

    claimed = sum(1 for row in rows.values() if row["status"] == "claimed")
    unclaimed = sum(1 for row in rows.values() if row["status"] == "unclaimed")
    status_checks = []
    if args.status is not None:
        status_checks.append("PCI status OK")
    if args.claimed_hardware_status is not None:
        status_checks.append("claimed hardware status OK")
    status_suffix = f"; {', '.join(status_checks)}" if status_checks else ""
    print(
        "hardware support matrix OK: "
        f"{claimed} bounded claimed classes, {unclaimed} unclaimed classes"
        f"{status_suffix}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
