#!/usr/bin/env python3
"""Validate the bounded hardware support matrix and claim wording."""

from __future__ import annotations

import argparse
import json
import re
import struct
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def _doc_contract_path(root: Path, name: str) -> Path:
    txt_path = root / "docs" / f"{name}.txt"
    if txt_path.exists():
        return txt_path
    return root / "docs" / f"{name}.md"


MATRIX = _doc_contract_path(ROOT, "architecture")

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
    "ACPI_TABLES": {"proof": "future-acpi-table-discovery-proof"},
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
    "ACPI_TABLES",
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
    "ACPI_TABLES": {
        "artifact": "acpi-cloud-table-walk",
        "requires": "rsdp-rsdt-xsdt-madt-hpet-checksum",
    },
    "PCI_ENUMERATION": {
        "artifact": "pci-cloud-class-table",
        "requires": "all-bdfs-class-subclass-progif-table",
    },
    "AHCI": {
        "artifact": "ahci-cloud-wad-read",
        "requires": "pci-ahci-bar5-hba-identify-sector-read-no-ide-fallback",
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
        "requires": "madt-lapic-ioapic-pic-masked",
    },
    "HPET": {
        "artifact": "hpet-cloud-timer",
        "requires": "acpi-hpet-mmio-counter-comparator",
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
    "ACPI_TABLES": {
        "scope": "firmware",
        "claim": "no-acpi-table-parser",
        "evidence": "hardcoded-poweroff-only",
    },
    "PCI_ENUMERATION": {
        "scope": "kernel",
        "claim": "no-general-pci-enumeration",
        "evidence": "status-only-qemu-pci-config",
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
        "requires": "read-only-index-id-class-progif-lookup",
        "proof": "host-check-plus-cloud-status",
        "unlocks": "ahci-sata,usb,hda-audio",
        "evidence": "pciapi-pcilookid-status-fields",
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
    "PCI_CONFIG_STATUS": {
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
    "PIT": {
        "scope": "qemu-pit",
        "fields": (
            "clocksrc",
            "clockirq",
            "clocktick",
            "clockhz",
            "clockms",
            "clockdoom",
            "clocksch",
            "clockpirq",
            "irqctl",
            "apic",
            "hpet",
        ),
        "evidence": "clock-status",
    },
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
            "inputdepth",
            "inputstat",
            "inputpolicy",
            "inputdev",
            "inputdevices",
            "inputmods",
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
            "inputqueue",
            "inputdepth",
            "inputstat",
            "inputpolicy",
            "inputdev",
            "inputdevices",
            "inputmods",
            "inputpoll",
            "inputlast",
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
            "fbdev",
            "fbmmio",
            "fbinfo",
            "fbcap",
            "fbsrc",
            "fbacct",
            "fbpresent",
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

INTERRUPT_TIMER_BOUNDARIES = {
    "LEGACY_PIC_PIT": {
        "status": "active",
        "route": "pic",
        "clock": "pit",
        "requires": "pic-unmasked-irq0-eoi",
        "proof": "clock-status",
        "evidence": "irqctl-clocksrc-clockirq",
    },
    "ACPI_TABLES": {
        "status": "future",
        "route": "firmware",
        "clock": "madt-hpet",
        "requires": "rsdp-rsdt-xsdt-madt-hpet-checksum",
        "proof": "acpi-table-walk",
        "evidence": "none",
    },
    "LOCAL_APIC": {
        "status": "future",
        "route": "lapic",
        "clock": "apic-timer",
        "requires": "lapic-mmio-or-msr-spurious-eoi-timer",
        "proof": "lapic-status-counters",
        "evidence": "none",
    },
    "IOAPIC": {
        "status": "future",
        "route": "ioapic",
        "clock": "external-irqs",
        "requires": "madt-ioapic-redirection-pic-masked",
        "proof": "ioapic-routed-irqs",
        "evidence": "none",
    },
    "HPET": {
        "status": "future",
        "route": "hpet",
        "clock": "hpet-comparator",
        "requires": "hpet-table-mmio-counter-comparator",
        "proof": "hpet-status-counters",
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
    "PCI_STATUS[QEMU_PCI_CONFIG]",
    "General PCI discovery is status-only",
    "ACPI table discovery is not implemented",
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
    "UEFI_HOST_ARTIFACT[PE_COFF_LOADER]",
    "host-buildable PE/COFF loader and FAT16 ESP artifacts",
    "host-built-uefi-loader-no-kernel-entry-proof",
    "UEFI_CLOUD_PROOF[WORKFLOW_DISPATCH]",
    "manual GitHub Actions OVMF loader proof",
    "contract mode is QEMU-free",
    "QEMU_DEVICE_MODEL[BIOS_BOOT]",
    "QEMU_DEVICE_MODEL[PCI_CONFIG_STATUS]",
    "These rows are the machine-readable reason the current claim is QEMU-only",
    "BOOT_DEVICE_BOUNDARY[BIOS_IDE_RAW_LBA]",
    "BOOT_DEVICE_BOUNDARY[UEFI_ESP_KERNEL_FILE]",
    "BOOT_DEVICE_BOUNDARY[AHCI_SATA_DISK]",
    "BOOT_DEVICE_BOUNDARY[USB_MASS_STORAGE]",
    "BOOT_DEVICE_BOUNDARY[PHYSICAL_MACHINE]",
    "The boot-device boundary is intentionally separate",
    "PCI_TABLE[QEMU_PCI_CLASS_TABLE]",
    "PCI_TABLE_API[READ_ONLY_LOOKUP]",
    "PCI_TABLE_CONSUMER[STORAGE_CLASS_PROBE]",
    "PCI_TABLE_CONSUMER[AUDIO_CLASS_PROBE]",
    "PCI_TABLE_CONTRACT[QEMU_PCI_SCAN]",
    "PCI_TABLE_CONTRACT[ENTRY_LAYOUT]",
    "PCI_TABLE_CONTRACT[NO_DRIVER_BINDING]",
    "BLOCK_DRIVER_BOUNDARY[OPS_TABLE]",
    "BLOCK_DRIVER_BOUNDARY[PCI_STORAGE_PROBE]",
    "BLOCK_DRIVER_BOUNDARY[UNSUPPORTED_CONTROLLER_REJECTION]",
    "BLOCK_DRIVER_BOUNDARY[AHCI_BAR_HBA_PROOF]",
    "STATUS_PROOF[IDE_ATA_PIO]",
    "STATUS_PROOF[PS2_KEYBOARD]",
    "STATUS_PROOF[PS2_MOUSE]",
    "STATUS_PROOF[PIT]",
    "STATUS_PROOF[VBE_VGA]",
    "STATUS_PROOF[SB16]",
    "minimum aggregate status fields",
    "IRQ/timer controller transition boundary",
    "INTERRUPT_TIMER_BOUNDARY[LEGACY_PIC_PIT]",
    "INTERRUPT_TIMER_BOUNDARY[ACPI_TABLES]",
    "INTERRUPT_TIMER_BOUNDARY[LOCAL_APIC]",
    "INTERRUPT_TIMER_BOUNDARY[IOAPIC]",
    "INTERRUPT_TIMER_BOUNDARY[HPET]",
    "irqctl=PIC",
    "apic=NONE",
    "hpet=NONE",
    "packed-bdf-vendor-device-class-progif-header",
    "pcitabcap=",
    "pcitabuse=",
    "pciover=",
    "pcimiss=",
    "pcihbus=",
    "pciclspb=",
    "pcibrbus=",
    "pcidiag=",
    "pciapi=",
    "pcilookid=",
    "pcilookmiss=",
    "pcicons=",
    "pcilookide=",
    "pcilookahci=",
    "pcilookaud=",
    "pcilookhda=",
    "blkctrl=",
    "blkrej=",
    "ahcibar=",
    "ahcireq=",
    "pciclassh=",
    "PROOF_REQUIREMENT[UEFI]",
    "PROOF_REQUIREMENT[ACPI_TABLES]",
    "PROOF_REQUIREMENT[AHCI]",
    "PROOF_REQUIREMENT[USB]",
    "PROOF_REQUIREMENT[APIC]",
    "PROOF_REQUIREMENT[SMP]",
    "PROOF_REQUIREMENT[HPET]",
    "PROOF_REQUIREMENT[PHYSICAL_HARDWARE]",
    "NEGATIVE_CLAIM[UEFI]",
    "NEGATIVE_CLAIM[ACPI_TABLES]",
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
        "docs/architecture.txt",
        "boot/uefi/CONTRACT.txt",
        "QEMU BIOS/IDE/PS2/VBE/SB16",
        "That evidence is limited to the emulated device model",
        "SUPPORT[UEFI] remains unclaimed",
        "pci=",
    ),
    "docs/architecture.txt": (
        "boot/uefi/CONTRACT.txt",
        "UEFI loader/proof boundary",
        "UEFI_BOOT[...]",
        "SUPPORT[UEFI] remains unclaimed",
        "PCI_STATUS[QEMU_PCI_CONFIG]",
    ),
    "docs/proof.txt": (
        "docs/architecture.txt",
        "boot/uefi/CONTRACT.txt",
        "UEFI_BOOT[...]",
        "SUPPORT[...]",
        "PCI_STATUS[...]",
        "check_hardware_support_matrix.py",
    ),
    "docs/doom-provenance.txt": (
        "docs/architecture.txt",
        "broad PC",
    ),
    "docs/play.txt": (
        "docs/architecture.txt",
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
    "ENTRY": {
        "status": "host-built",
        "requires": "pe32-efi-loader",
        "proof": "host-pe-coff-loader-check",
        "evidence": "build-host-artifacts",
    },
    "ESP_STORAGE": {
        "status": "loader-implemented",
        "requires": "fat-esp-kernel-read",
        "proof": "source-and-host-build",
        "evidence": "loader.asm",
    },
    "FRAMEBUFFER": {
        "status": "loader-implemented",
        "requires": "gop-info-collection",
        "proof": "source-and-host-build",
        "evidence": "loader.asm",
    },
    "MEMORY_MAP": {
        "status": "loader-implemented",
        "requires": "uefi-memory-map",
        "proof": "source-and-host-build",
        "evidence": "loader.asm",
    },
    "EXIT_BOOT_SERVICES": {
        "status": "cloud-proof-target",
        "requires": "exit-before-kernel-handoff",
        "proof": "ovmf-debugcon-marker",
        "evidence": "uefi-ovmf-proof.yml",
    },
    "KERNEL_HANDOFF": {
        "status": "source-implemented",
        "requires": "ovmf-kernel-entry-marker",
        "proof": "future-cloud-kernel-entry",
        "evidence": "loader.asm",
    },
    "BUILD_INTEGRATION": {
        "status": "host-built",
        "requires": "separate-opt-in-target",
        "proof": "host-artifact-build",
        "evidence": "build-host-artifacts",
    },
}

UEFI_BOOT_DEVICE_REQUIREMENTS = {
    "ESP_IMAGE": {
        "status": "host-built",
        "requires": "fat-esp-kernel-file",
        "proof": "host-fat-directory-check",
        "evidence": "build-host-artifacts",
    },
    "OVMF_BOOT": {
        "status": "cloud-proof-target",
        "requires": "ovmf-loads-efi-from-esp",
        "proof": "github-actions-ovmf",
        "evidence": "uefi-ovmf-proof.yml",
    },
    "NO_RAW_LBA_FALLBACK": {
        "status": "host-checked",
        "requires": "no-stage2-raw-lba-dependency",
        "proof": "source-contract-check",
        "evidence": "loader.asm",
    },
    "PHYSICAL_MEDIA": {
        "status": "unimplemented",
        "requires": "machine-inventory-disposable-media",
        "proof": "future-lab-run",
        "evidence": "none",
    },
}

UEFI_HOST_ARTIFACT_REQUIREMENTS = {
    "PE_COFF_LOADER": {
        "status": "host-buildable",
        "kind": "pe32plus-efi-loader-proof-application",
        "proof": "host-pe-coff-loader-check",
        "evidence": "build-host-artifacts",
    },
    "ESP_FAT_IMAGE": {
        "status": "host-buildable",
        "kind": "fat16-esp-file-layout",
        "proof": "host-fat-directory-check",
        "evidence": "build-host-artifacts",
    },
    "NO_VM_BOOT": {
        "status": "host-checked",
        "kind": "no-ovmf-or-qemu-execution",
        "proof": "source-contract-check",
        "evidence": "check-hardware-support-matrix",
    },
}

UEFI_CLOUD_PROOF_REQUIREMENTS = {
    "WORKFLOW_DISPATCH": {
        "status": "scaffolded",
        "runner": "github-actions-ubuntu",
        "mode": "contract-attempt-prove-kernel-entry",
        "evidence": "uefi-ovmf-proof.yml",
    },
    "OVMF_ATTEMPT": {
        "status": "scaffolded",
        "runner": "github-actions-ubuntu",
        "mode": "manual-qemu-ovmf-debugcon",
        "evidence": "ovmf-cloud-proof-script",
    },
    "SUPPORT_GUARD": {
        "status": "guardrail",
        "runner": "host-check",
        "mode": "support-uefi-unclaimed",
        "evidence": "check-hardware-support-matrix",
    },
    "ARTIFACT_POLICY": {
        "status": "guardrail",
        "runner": "github-actions-ubuntu",
        "mode": "json-manifests-only",
        "evidence": "workflow-artifact-policy",
    },
}

PCI_STATUS_REQUIREMENTS = {
    "QEMU_PCI_CONFIG": {
        "status": "status-only",
        "scope": "qemu-pci-config",
        "proof": "cloud-smoke-status",
        "evidence": "pci-status-fields",
    },
}

PCI_TABLE_REQUIREMENTS = {
    "QEMU_PCI_CLASS_TABLE": {
        "status": "status-only",
        "scope": "qemu-pci-config",
        "layout": "packed-bdf-vendor-device-class-progif-header",
        "capacity": "256",
        "evidence": "pci-table-status-fields",
    },
}

PCI_TABLE_API_REQUIREMENTS = {
    "READ_ONLY_LOOKUP": {
        "status": "status-only",
        "scope": "qemu-pci-config",
        "contract": "kernel-maintained-read-only-table",
        "lookup": "index-vendor-device-class-subclass-progif",
        "consumers": "future-drivers",
        "evidence": "pciapi-pcilookid-status-fields",
    },
}

PCI_TABLE_CONSUMER_REQUIREMENTS = {
    "STORAGE_CLASS_PROBE": {
        "status": "status-only",
        "scope": "qemu-pci-config",
        "consumes": "read-only-lookup",
        "lookup": "ide-ahci-class",
        "drivers": "none",
        "evidence": "pcicons-pcilookide-pcilookahci-status-fields",
    },
    "AUDIO_CLASS_PROBE": {
        "status": "status-only",
        "scope": "qemu-pci-config",
        "consumes": "read-only-lookup",
        "lookup": "multimedia-audio-hda-class",
        "drivers": "none",
        "evidence": "pcicons-pcilookaud-pcilookhda-status-fields",
    },
}

PCI_TABLE_CONTRACT_REQUIREMENTS = {
    "QEMU_PCI_SCAN": {
        "status": "status-only",
        "buses": "256",
        "devices": "32",
        "functions": "8",
        "table_capacity": "256",
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

BLOCK_DRIVER_BOUNDARIES = {
    "OPS_TABLE": {
        "status": "host-checked",
        "scope": "block-device",
        "contract": "sector-read-write-flush-ops",
        "active": "ata-pio",
        "future": "ahci-nvme-usb",
        "evidence": "kernel-source",
    },
    "PCI_STORAGE_PROBE": {
        "status": "status-only",
        "scope": "qemu-pci-config",
        "contract": "ide-ahci-class-consumer",
        "active": "ata-pio",
        "future": "ahci-driver",
        "evidence": "blkctrl-blkrej-status-fields",
    },
    "UNSUPPORTED_CONTROLLER_REJECTION": {
        "status": "guardrail",
        "scope": "storage-controller",
        "contract": "no-silent-ahci-bind",
        "active": "none",
        "future": "ahci-driver",
        "evidence": "blkrej-status-fields",
    },
    "AHCI_BAR_HBA_PROOF": {
        "status": "guardrail",
        "scope": "qemu-pci-config",
        "contract": "bar5-mmio-hba-identify-sector-read-required",
        "active": "none",
        "future": "ahci-driver",
        "evidence": "ahcibar-ahcireq-status-fields",
    },
}

PCI_STATUS_FIELDS = {
    "pci",
    "pciprobe",
    "pcimiss",
    "pcicount",
    "pcihbus",
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
    "pciclspb",
    "pcibrbus",
    "pciclsmm",
    "pcidiag",
    "pciapi",
    "pcilookms",
    "pcilookbr",
    "pcilookid",
    "pcilookmiss",
    "pcicons",
    "pcilookide",
    "pcilookahci",
    "pcilookaud",
    "pcilookhda",
    "blkctrl",
    "blkrej",
    "ahcibar",
    "ahcireq",
}
PCI_SCAN_BUS_COUNT = 256
PCI_SCAN_DEVICE_COUNT = 32
PCI_SCAN_FUNCTION_COUNT = 8
PCI_QEMU_CONFIG_PROBES = PCI_SCAN_BUS_COUNT * PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT
PCI_TABLE_CAPACITY = PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT
BLOCK_DEVICE_ATA_PIO = 1
BLOCK_DEVICE_AHCI = 2
AHCI_BAR_STATE_NONE = 0
AHCI_BAR_STATE_MMIO = 1
AHCI_BAR_STATE_INVALID = 2
AHCI_PROOF_REQ_PCI_CLASS = 0x00000001
AHCI_PROOF_REQ_BAR5_MMIO = 0x00000002
AHCI_PROOF_DISCOVERY_MASK = AHCI_PROOF_REQ_PCI_CLASS | AHCI_PROOF_REQ_BAR5_MMIO
AHCI_PROOF_REQUIRED_MASK = 0x0000007F
AHCI_GUARD_NO_SILENT_BIND = 0x00000001
AHCI_GUARD_UNSUPPORTED_REJECTED = 0x00000002
AHCI_GUARD_ATA_ONLY_OPS = 0x00000004
PCI_DIAG_SCAN_COMPLETE = 0x00000001
PCI_DIAG_TABLE_BOUNDED = 0x00000002
PCI_DIAG_ABSENT_COUNTED = 0x00000004
PCI_DIAG_CONFIG_DISABLED = 0x00000008
PCI_DIAG_INDEX_GUARD = 0x00000010
PCI_DIAG_ID_LOOKUP = 0x00000020
PCI_DIAG_CLASS_LOOKUP = 0x00000040
PCI_DIAG_STATUS_ONLY_CONSUMER = 0x00000080
PCI_DIAG_REQUIRED_MASK = (
    PCI_DIAG_SCAN_COMPLETE
    | PCI_DIAG_TABLE_BOUNDED
    | PCI_DIAG_ABSENT_COUNTED
    | PCI_DIAG_CONFIG_DISABLED
    | PCI_DIAG_INDEX_GUARD
    | PCI_DIAG_CLASS_LOOKUP
    | PCI_DIAG_STATUS_ONLY_CONSUMER
)

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

PCI_TABLE_CONSUMER_RE = re.compile(
    r"^- `PCI_TABLE_CONSUMER\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"consumes=(?P<consumes>[a-z0-9-]+) "
    r"lookup=(?P<lookup>[a-z0-9-]+) "
    r"drivers=(?P<drivers>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

PCI_TABLE_SCAN_CONTRACT_RE = re.compile(
    r"^- `PCI_TABLE_CONTRACT\[(?P<id>QEMU_PCI_SCAN)\] "
    r"status=(?P<status>[a-z-]+) "
    r"buses=(?P<buses>[0-9]+) "
    r"devices=(?P<devices>[0-9]+) "
    r"functions=(?P<functions>[0-9]+) "
    r"table-capacity=(?P<table_capacity>[0-9]+) "
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

BLOCK_DRIVER_BOUNDARY_RE = re.compile(
    r"^- `BLOCK_DRIVER_BOUNDARY\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
    r"contract=(?P<contract>[a-z0-9-]+) "
    r"active=(?P<active>[a-z0-9-]+) "
    r"future=(?P<future>[a-z0-9-]+) "
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

INTERRUPT_TIMER_BOUNDARY_RE = re.compile(
    r"^- `INTERRUPT_TIMER_BOUNDARY\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"route=(?P<route>[a-z0-9-]+) "
    r"clock=(?P<clock>[a-z0-9-]+) "
    r"requires=(?P<requires>[a-z0-9-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
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

UEFI_HOST_ARTIFACT_RE = re.compile(
    r"^- `UEFI_HOST_ARTIFACT\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"kind=(?P<kind>[a-z0-9+-]+) "
    r"proof=(?P<proof>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

UEFI_CLOUD_PROOF_RE = re.compile(
    r"^- `UEFI_CLOUD_PROOF\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"runner=(?P<runner>[a-z0-9-]+) "
    r"mode=(?P<mode>[a-z0-9-]+) "
    r"evidence=(?P<evidence>[a-z0-9_.-]+)`$",
    re.MULTILINE,
)

OVERCLAIM_PATTERNS = (
    re.compile(r"\bsupports?\s+UEFI\b", re.IGNORECASE),
    re.compile(r"\bUEFI\s+support\b", re.IGNORECASE),
    re.compile(r"\bUEFI[- ]bootable\b", re.IGNORECASE),
    re.compile(r"\bUEFI\s+boot\s+(?:works|is\s+implemented|is\s+available|is\s+wired)\b", re.IGNORECASE),
    re.compile(r"\bACPI\s+table\s+(?:support|parser|discovery)\b", re.IGNORECASE),
    re.compile(r"\bACPI\s+tables?\s+(?:work|works|are\s+implemented|is\s+implemented|are\s+available|is\s+available|are\s+wired|is\s+wired)\b", re.IGNORECASE),
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
    for suffix in ("*.md", "*.txt"):
        files.extend(sorted((root / "boot").rglob(suffix)))
        files.extend(sorted((root / "docs").rglob(suffix)))
    files.extend(sorted((root / "tests").rglob("test_*.py")))
    return sorted({path for path in files if path.exists()})


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
        "acpi-tables",
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
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"UEFI_BOOT[{row_id}] {key} must stay {value}")

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
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"UEFI_BOOT_DEVICE[{row_id}] {key} must stay {value}")

    return rows


def _validate_uefi_host_artifact_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in UEFI_HOST_ARTIFACT_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate UEFI_HOST_ARTIFACT row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(UEFI_HOST_ARTIFACT_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing UEFI_HOST_ARTIFACT rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(UEFI_HOST_ARTIFACT_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected UEFI_HOST_ARTIFACT rows: {', '.join(extras)}")

    for row_id, expected in UEFI_HOST_ARTIFACT_REQUIREMENTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"UEFI_HOST_ARTIFACT[{row_id}] {key} must stay {value}")

    return rows


def _validate_uefi_cloud_proof_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in UEFI_CLOUD_PROOF_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate UEFI_CLOUD_PROOF row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(UEFI_CLOUD_PROOF_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing UEFI_CLOUD_PROOF rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(UEFI_CLOUD_PROOF_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected UEFI_CLOUD_PROOF rows: {', '.join(extras)}")

    for row_id, expected in UEFI_CLOUD_PROOF_REQUIREMENTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"UEFI_CLOUD_PROOF[{row_id}] {key} must stay {value}")
        if row["status"] not in {"scaffolded", "guardrail"}:
            raise AssertionError(f"UEFI_CLOUD_PROOF[{row_id}] must not become boot evidence")

    return rows


def _read_fat16_name(entries: bytes, name: bytes) -> dict[str, int | bytes]:
    for offset in range(0, len(entries), 32):
        entry = entries[offset : offset + 32]
        if not entry or entry[0] == 0:
            break
        if entry[0] == 0xE5 or entry[11] == 0x0F:
            continue
        if entry[0:11] == name:
            return {
                "name": entry[0:11],
                "attr": entry[11],
                "cluster": struct.unpack_from("<H", entry, 26)[0],
                "size": struct.unpack_from("<I", entry, 28)[0],
            }
    raise AssertionError(f"ESP image missing FAT entry {name!r}")


def _validate_pe32plus_efi_application(data: bytes) -> dict[str, int | str]:
    if data[0:2] != b"MZ":
        raise AssertionError("BOOTX64.EFI missing MZ DOS header")
    pe_offset = struct.unpack_from("<I", data, 0x3C)[0]
    if data[pe_offset : pe_offset + 4] != b"PE\0\0":
        raise AssertionError("BOOTX64.EFI missing PE/COFF signature")

    file_header = pe_offset + 4
    machine, section_count, _timestamp, _symbols, _symbol_count, optional_size, _chars = (
        struct.unpack_from("<HHIIIHH", data, file_header)
    )
    if machine != 0x8664:
        raise AssertionError("BOOTX64.EFI must be an x86_64 PE/COFF image")
    if section_count != 1:
        raise AssertionError("BOOTX64.EFI must keep one .text section in the host loader")
    if optional_size != 0xF0:
        raise AssertionError("BOOTX64.EFI must use a PE32+ optional header")

    optional = file_header + 20
    if struct.unpack_from("<H", data, optional)[0] != 0x20B:
        raise AssertionError("BOOTX64.EFI optional header must be PE32+")
    entry_rva = struct.unpack_from("<I", data, optional + 16)[0]
    image_base = struct.unpack_from("<Q", data, optional + 24)[0]
    section_alignment = struct.unpack_from("<I", data, optional + 32)[0]
    file_alignment = struct.unpack_from("<I", data, optional + 36)[0]
    size_of_headers = struct.unpack_from("<I", data, optional + 60)[0]
    subsystem = struct.unpack_from("<H", data, optional + 68)[0]
    if subsystem != 10:
        raise AssertionError("BOOTX64.EFI must declare IMAGE_SUBSYSTEM_EFI_APPLICATION")
    if section_alignment != 0x1000 or file_alignment != 0x200:
        raise AssertionError("BOOTX64.EFI must keep stable section/file alignment")
    if size_of_headers != 0x200:
        raise AssertionError("BOOTX64.EFI must keep a 512-byte header block")

    section = optional + optional_size
    name, virtual_size, virtual_address, raw_size, raw_pointer, _reloc, _lines, _reloc_count, _line_count, characteristics = (
        struct.unpack_from("<8sIIIIIIHHI", data, section)
    )
    if name.rstrip(b"\0") != b".text":
        raise AssertionError("BOOTX64.EFI host loader must contain a .text section")
    if entry_rva < virtual_address or entry_rva >= virtual_address + virtual_size:
        raise AssertionError("BOOTX64.EFI entry point must land inside .text")
    if raw_pointer != 0x200 or raw_size < virtual_size:
        raise AssertionError("BOOTX64.EFI .text raw layout changed unexpectedly")
    if characteristics & 0xE0000020 != 0xE0000020:
        raise AssertionError("BOOTX64.EFI .text must be code, execute, read, and write")

    entry_offset = raw_pointer + (entry_rva - virtual_address)
    expected_entry = b"\x48\xb8" + struct.pack("<Q", 0x8000000000000003) + b"\xc3"
    if data[entry_offset : entry_offset + len(expected_entry)] == expected_entry:
        raise AssertionError("BOOTX64.EFI must not be the old EFI_UNSUPPORTED stub")
    text = data[raw_pointer : raw_pointer + raw_size]
    for marker in (
        b"VIBEUEFI step=entry",
        b"VIBEUEFI step=esp-kernel-read",
        b"VIBEUEFI step=low-memory-reserve status=success",
        b"VIBEUEFI step=elf32-load status=success",
        b"VIBEUEFI step=gop",
        b"VIBEUEFI step=memory-map",
        b"VIBEUEFI step=boot-info status=success",
        b"VIBEUEFI step=exit-boot-services status=success",
        b"VIBEUEFI step=kernel-handoff status=attempting",
    ):
        if marker not in text:
            raise AssertionError(f"BOOTX64.EFI loader missing proof marker {marker!r}")

    return {
        "machine": "x86_64",
        "subsystem": subsystem,
        "entry_rva": entry_rva,
        "image_base": image_base,
        "section_count": section_count,
        "loader_kind": "uefi-loader-proof-application",
    }


def _validate_fat16_esp_image(data: bytes, efi_application: bytes, kernel: bytes) -> dict[str, int | str]:
    if len(data) < 512 or data[510:512] != b"\x55\xAA":
        raise AssertionError("esp.img missing FAT boot-sector signature")
    bytes_per_sector = struct.unpack_from("<H", data, 11)[0]
    sectors_per_cluster = data[13]
    reserved_sectors = struct.unpack_from("<H", data, 14)[0]
    fat_count = data[16]
    root_entries = struct.unpack_from("<H", data, 17)[0]
    total_sectors = struct.unpack_from("<H", data, 19)[0]
    sectors_per_fat = struct.unpack_from("<H", data, 22)[0]
    filesystem = data[54:62]
    if bytes_per_sector != 512 or sectors_per_cluster != 1:
        raise AssertionError("esp.img must use 512-byte sectors and one-sector clusters")
    if fat_count != 2 or filesystem != b"FAT16   ":
        raise AssertionError("esp.img must be a two-FAT FAT16 image")
    if total_sectors * bytes_per_sector != len(data):
        raise AssertionError("esp.img byte length must match the FAT16 boot sector")

    root_dir_sectors = ((root_entries * 32) + bytes_per_sector - 1) // bytes_per_sector
    first_root_sector = reserved_sectors + fat_count * sectors_per_fat
    first_data_sector = first_root_sector + root_dir_sectors
    cluster_size = bytes_per_sector * sectors_per_cluster
    fat = data[reserved_sectors * bytes_per_sector : (reserved_sectors + sectors_per_fat) * bytes_per_sector]
    root = data[
        first_root_sector * bytes_per_sector : (first_root_sector + root_dir_sectors) * bytes_per_sector
    ]

    def cluster_offset(cluster: int) -> int:
        if cluster < 2:
            raise AssertionError("FAT chain pointed at an invalid cluster")
        return (first_data_sector + (cluster - 2) * sectors_per_cluster) * bytes_per_sector

    def read_chain(cluster: int) -> bytes:
        chunks: list[bytes] = []
        seen: set[int] = set()
        current = cluster
        while 2 <= current < 0xFFF8:
            if current in seen:
                raise AssertionError("FAT chain loop detected in esp.img")
            seen.add(current)
            offset = cluster_offset(current)
            chunks.append(data[offset : offset + cluster_size])
            current = struct.unpack_from("<H", fat, current * 2)[0]
        if current < 0xFFF8:
            raise AssertionError("FAT chain did not end with an EOC marker")
        return b"".join(chunks)

    efi_dir = _read_fat16_name(root, b"EFI        ")
    vibeos_dir = _read_fat16_name(root, b"VIBEOS     ")
    if efi_dir["attr"] & 0x10 != 0x10 or vibeos_dir["attr"] & 0x10 != 0x10:
        raise AssertionError("ESP root must contain EFI and VIBEOS directories")

    efi_dir_data = read_chain(int(efi_dir["cluster"]))
    boot_dir = _read_fat16_name(efi_dir_data, b"BOOT       ")
    if boot_dir["attr"] & 0x10 != 0x10:
        raise AssertionError("ESP image must contain EFI/BOOT directory")
    boot_dir_data = read_chain(int(boot_dir["cluster"]))
    boot_file = _read_fat16_name(boot_dir_data, b"BOOTX64 EFI")
    boot_payload = read_chain(int(boot_file["cluster"]))[: int(boot_file["size"])]
    if boot_payload != efi_application:
        raise AssertionError("EFI/BOOT/BOOTX64.EFI bytes in esp.img must match BOOTX64.EFI")

    vibeos_dir_data = read_chain(int(vibeos_dir["cluster"]))
    kernel_file = _read_fat16_name(vibeos_dir_data, b"KERNEL  ELF")
    kernel_payload = read_chain(int(kernel_file["cluster"]))[: int(kernel_file["size"])]
    if kernel_payload != kernel:
        raise AssertionError("VIBEOS/KERNEL.ELF bytes in esp.img must match the input kernel")

    return {
        "filesystem": "FAT16",
        "total_sectors": total_sectors,
        "bootx64_size": int(boot_file["size"]),
        "kernel_size": int(kernel_file["size"]),
    }


def validate_uefi_host_artifact_build(root: Path = ROOT) -> dict[str, object]:
    script = root / "boot" / "uefi" / "build_host_artifacts.py"
    if not script.exists():
        raise AssertionError("missing boot/uefi/build_host_artifacts.py")
    script_text = _read(script)
    for forbidden in ("qemu-system", "OVMF_CODE", "OVMF_VARS", "ALLOW_LOCAL_VM"):
        if forbidden in script_text:
            raise AssertionError(
                "boot/uefi/build_host_artifacts.py must stay host-only and must not run firmware"
            )

    kernel = b"\x7fELFhost-uefi-artifact-check\n" + bytes(range(32))
    with tempfile.TemporaryDirectory(prefix="vibe-uefi-host-") as tmp:
        tmp_path = Path(tmp)
        kernel_path = tmp_path / "kernel.elf"
        out_dir = tmp_path / "out"
        kernel_path.write_bytes(kernel)
        result = subprocess.run(
            [
                sys.executable,
                str(script),
                "--kernel",
                str(kernel_path),
                "--out-dir",
                str(out_dir),
                "--quiet",
            ],
            cwd=root,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise AssertionError(
                "boot/uefi/build_host_artifacts.py failed: "
                + (result.stderr.strip() or result.stdout.strip())
            )

        efi_application = (out_dir / "BOOTX64.EFI").read_bytes()
        esp_image = (out_dir / "esp.img").read_bytes()
        manifest = json.loads((out_dir / "manifest.json").read_text(encoding="utf-8"))

    if manifest["claim"] != "host-built-uefi-loader-no-kernel-entry-proof":
        raise AssertionError("UEFI host manifest must keep the no-kernel-entry-proof claim")
    if manifest["vm_execution"] != "not-run":
        raise AssertionError("UEFI host manifest must keep VM execution disabled")
    if manifest["esp_paths"] != ["EFI/BOOT/BOOTX64.EFI", "VIBEOS/KERNEL.ELF"]:
        raise AssertionError("UEFI host manifest must keep the checked ESP paths")
    if manifest["efi_loader_kind"] != "loader-proof-application":
        raise AssertionError("UEFI host manifest must identify the real loader application")
    pe_manifest = manifest.get("pe_coff_validation")
    if not isinstance(pe_manifest, dict):
        raise AssertionError("UEFI host manifest must include PE/COFF validation facts")
    if pe_manifest.get("format") != "PE32+" or pe_manifest.get("subsystem") != "efi-application":
        raise AssertionError("UEFI host manifest must record PE32+ EFI application validation")
    if pe_manifest.get("required_marker_count", 0) < 9:
        raise AssertionError("UEFI host manifest must validate the loader proof markers")
    for feature in (
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
    ):
        if feature not in manifest["efi_loader_features"]:
            raise AssertionError(f"UEFI host manifest missing loader feature {feature}")
    if manifest["kernel_handoff"] != "source-implemented-pending-ovmf-kernel-entry-marker":
        raise AssertionError("UEFI host manifest must keep the kernel-entry proof blocker explicit")

    pe_info = _validate_pe32plus_efi_application(efi_application)
    esp_info = _validate_fat16_esp_image(esp_image, efi_application, kernel)
    return {"pe": pe_info, "esp": esp_info, "manifest": manifest}


def validate_uefi_ovmf_cloud_scaffold(root: Path = ROOT) -> dict[str, object]:
    script = root / "boot" / "uefi" / "ovmf_cloud_proof.py"
    workflow = root / ".github" / "workflows" / "uefi-ovmf-proof.yml"
    if not script.exists():
        raise AssertionError("missing boot/uefi/ovmf_cloud_proof.py")
    if not workflow.exists():
        raise AssertionError("missing .github/workflows/uefi-ovmf-proof.yml")

    script_text = _read(script)
    for phrase in (
        "GITHUB_ACTIONS",
        "RUNNER_OS",
        "platform.system() == \"Darwin\"",
        "_parse_debugcon_markers",
        "debugcon_markers",
        "exit_boot_services",
        "support_claim",
        "unclaimed",
        "uefi_boot_rows_moved",
        "local_mac_qemu_required",
        "ExitBootServices",
        "uploads_json_manifests_only",
        "uploads_vm_logs",
        "mode == \"prove\"",
        "kernel_booted",
        "kernel_status_evidence_required",
        "kernel_entry_after_exit_boot_services",
        "KERNEL_ENTRY_REQUIRED_FLAG_MASK",
    ):
        if phrase not in script_text:
            raise AssertionError(f"boot/uefi/ovmf_cloud_proof.py missing scaffold phrase: {phrase}")

    for forbidden in ("boot/stage1.asm", "boot/stage2.asm", "kernel/kernel.asm"):
        if forbidden in script_text:
            raise AssertionError("UEFI OVMF proof scaffold must not depend on BIOS boot sources")

    kernel = b"\x7fELFovmf-cloud-contract-check\n" + bytes(range(32))
    with tempfile.TemporaryDirectory(prefix="vibe-uefi-ovmf-contract-") as tmp:
        tmp_path = Path(tmp)
        kernel_path = tmp_path / "kernel.elf"
        out_dir = tmp_path / "out"
        kernel_path.write_bytes(kernel)
        result = subprocess.run(
            [
                sys.executable,
                str(script),
                "--kernel",
                str(kernel_path),
                "--out-dir",
                str(out_dir),
                "--mode",
                "contract",
            ],
            cwd=root,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise AssertionError(
                "boot/uefi/ovmf_cloud_proof.py contract mode failed: "
                + (result.stderr.strip() or result.stdout.strip())
            )
        manifest = json.loads((out_dir / "ovmf-proof-manifest.json").read_text(encoding="utf-8"))

    if manifest["mode"] != "contract":
        raise AssertionError("UEFI OVMF contract manifest must record mode=contract")
    if manifest["support_claim"] != "unclaimed":
        raise AssertionError("UEFI OVMF contract manifest must keep support_claim=unclaimed")
    if manifest["uefi_boot_rows_moved"] is not True:
        raise AssertionError("UEFI OVMF contract manifest must record the intermediate UEFI_BOOT rows")
    if manifest["local_mac_qemu_required"] is not False:
        raise AssertionError("UEFI OVMF contract mode must not require local Mac QEMU")
    if manifest["ovmf"]["execution"] != "not-run":
        raise AssertionError("UEFI OVMF contract mode must not run firmware")
    if manifest["ovmf"]["proof_target"] != "kernel-entry-debugcon-marker":
        raise AssertionError("UEFI OVMF contract manifest must name the kernel-entry proof target")
    if manifest["ovmf"].get("kernel_status_evidence_required") is not True:
        raise AssertionError("UEFI OVMF contract manifest must require kernel-owned status evidence")
    if manifest["ovmf"].get("kernel_entry_after_exit_boot_services") is not False:
        raise AssertionError("UEFI OVMF contract must require post-ExitBootServices kernel entry")
    if manifest["ovmf"].get("kernel_entry_required_flag_mask") != "0x0000007F":
        raise AssertionError("UEFI OVMF contract must publish the required kernel handoff flags")
    if "the source-level kernel-owned UEFI entry marker and status fields still need disposable OVMF proof" not in manifest["remaining_blockers"]:
        raise AssertionError("UEFI OVMF manifest must keep the kernel-entry proof blocker")
    artifact_policy = manifest["artifact_policy"]
    for key in ("uploads_esp_image", "uploads_efi_binary", "uploads_pflash_vars", "uploads_vm_logs"):
        if artifact_policy[key] is not False:
            raise AssertionError(f"UEFI OVMF artifact policy must keep {key}=false")
    if artifact_policy["uploads_parsed_debugcon_markers"] is not True:
        raise AssertionError("UEFI OVMF artifact policy must allow parsed debugcon markers in JSON")

    workflow_text = _read(workflow)
    for phrase in (
        "workflow_dispatch:",
        "proof_mode:",
        "contract",
        "attempt",
        "prove",
        "runs-on: ubuntu-latest",
        "qemu-system-x86 ovmf",
        "inputs.proof_mode != 'contract'",
        "make DOOM_WAD= build/kernel.elf",
        "boot/uefi/ovmf_cloud_proof.py",
        "--mode \"${{ inputs.proof_mode }}\"",
        "tools/check_hardware_support_matrix.py",
        "build/uefi-ovmf-proof/**/*.json",
    ):
        if phrase not in workflow_text:
            raise AssertionError(f"UEFI OVMF workflow missing phrase: {phrase}")

    for forbidden in (
        "\n  push:",
        "\n  pull_request:",
        "ALLOW_LOCAL_VM=1",
        "esp.img",
        "BOOTX64.EFI",
        "OVMF_VARS.fd",
        "*.img",
        "*.fd",
        "*.log",
        "serial*.txt",
    ):
        if forbidden in workflow_text:
            raise AssertionError(f"UEFI OVMF workflow must not contain {forbidden.strip()}")

    return {"manifest": manifest, "workflow": str(workflow.relative_to(root))}


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


def _validate_pci_table_consumer_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in PCI_TABLE_CONSUMER_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate PCI_TABLE_CONSUMER row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(PCI_TABLE_CONSUMER_REQUIREMENTS) - set(rows))
    if missing:
        raise AssertionError(f"missing PCI_TABLE_CONSUMER rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(PCI_TABLE_CONSUMER_REQUIREMENTS))
    if extras:
        raise AssertionError(f"unexpected PCI_TABLE_CONSUMER rows: {', '.join(extras)}")

    for row_id, expected in PCI_TABLE_CONSUMER_REQUIREMENTS.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"PCI_TABLE_CONSUMER[{row_id}] {key} must stay {value}")
        if row["drivers"] != "none":
            raise AssertionError(f"PCI_TABLE_CONSUMER[{row_id}] must not claim driver binding")

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

    scan = rows["QEMU_PCI_SCAN"]
    layout = rows["ENTRY_LAYOUT"]
    capacity = int(PCI_TABLE_REQUIREMENTS["QEMU_PCI_CLASS_TABLE"]["capacity"])
    if int(scan["table_capacity"]) != capacity:
        raise AssertionError("PCI_TABLE_CONTRACT[QEMU_PCI_SCAN] table-capacity must match PCI_TABLE capacity")
    if int(scan["buses"]) * int(scan["devices"]) * int(scan["functions"]) != PCI_QEMU_CONFIG_PROBES:
        raise AssertionError("PCI_TABLE_CONTRACT[QEMU_PCI_SCAN] bounds must match the all-bus probe count")
    if int(layout["dwords"]) != 4:
        raise AssertionError("PCI_TABLE_CONTRACT[ENTRY_LAYOUT] dwords must stay 4")
    fields = set(layout["fields"].split(","))
    required_fields = set(PCI_TABLE_CONTRACT_REQUIREMENTS["ENTRY_LAYOUT"]["fields"].split(","))
    if fields != required_fields:
        raise AssertionError("PCI_TABLE_CONTRACT[ENTRY_LAYOUT] fields must name the packed API fields")

    return rows


def _validate_block_driver_boundary_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in BLOCK_DRIVER_BOUNDARY_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate BLOCK_DRIVER_BOUNDARY row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(BLOCK_DRIVER_BOUNDARIES) - set(rows))
    if missing:
        raise AssertionError(f"missing BLOCK_DRIVER_BOUNDARY rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(BLOCK_DRIVER_BOUNDARIES))
    if extras:
        raise AssertionError(f"unexpected BLOCK_DRIVER_BOUNDARY rows: {', '.join(extras)}")

    for row_id, expected in BLOCK_DRIVER_BOUNDARIES.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"BLOCK_DRIVER_BOUNDARY[{row_id}] {key} must stay {value}")
        if row_id != "OPS_TABLE" and row["active"] != "none" and "ahci" in row["active"]:
            raise AssertionError(f"BLOCK_DRIVER_BOUNDARY[{row_id}] must not claim AHCI as active")

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
        if not {"ahci-sata", "usb", "hda-audio"}.issubset(unlocks):
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


def _validate_interrupt_timer_boundary_rows(text: str) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    for match in INTERRUPT_TIMER_BOUNDARY_RE.finditer(text):
        row_id = match.group("id")
        if row_id in rows:
            raise AssertionError(f"duplicate INTERRUPT_TIMER_BOUNDARY row: {row_id}")
        rows[row_id] = match.groupdict()

    missing = sorted(set(INTERRUPT_TIMER_BOUNDARIES) - set(rows))
    if missing:
        raise AssertionError(f"missing INTERRUPT_TIMER_BOUNDARY rows: {', '.join(missing)}")
    extras = sorted(set(rows) - set(INTERRUPT_TIMER_BOUNDARIES))
    if extras:
        raise AssertionError(f"unexpected INTERRUPT_TIMER_BOUNDARY rows: {', '.join(extras)}")

    for row_id, expected in INTERRUPT_TIMER_BOUNDARIES.items():
        row = rows[row_id]
        for key, value in expected.items():
            if row[key] != value:
                raise AssertionError(f"INTERRUPT_TIMER_BOUNDARY[{row_id}] {key} must stay {value}")
        if row_id != "LEGACY_PIC_PIT" and row["evidence"] != "none":
            raise AssertionError(f"INTERRUPT_TIMER_BOUNDARY[{row_id}] must keep evidence=none")

    return rows


def _validate_uefi_scaffold(root: Path) -> dict[str, dict[str, str]]:
    text = _read(root / "boot" / "uefi" / "CONTRACT.txt")
    rows = _validate_uefi_boot_rows(text)
    _validate_uefi_boot_device_rows(text)
    _validate_uefi_host_artifact_rows(text)
    _validate_uefi_cloud_proof_rows(text)

    for phrase in (
        "real loader/proof application",
        "kernel-owned `VIBEKERN` entry/status marker",
        "ELF32 `PT_LOAD` placement",
        "source-built handoff path",
        "opt-in host artifact builder",
        "BOOTX64.EFI",
        "VIBEOS/KERNEL.ELF",
        "host-built-uefi-loader-no-kernel-entry-proof",
        "UEFI_HOST_ARTIFACT[PE_COFF_LOADER]",
        "does not run OVMF",
        "SUPPORT[UEFI] remains unclaimed",
        "UEFI_BOOT_DEVICE[ESP_IMAGE]",
        "future boot-device proof boundary",
        "NO_RAW_LBA_FALLBACK",
        "must not describe vibe-os as UEFI-bootable",
        "ExitBootServices",
        "64-bit UEFI to 32-bit protected-mode transition",
        "UEFI_CLOUD_PROOF[WORKFLOW_DISPATCH]",
        "Contract mode is host-only and QEMU-free",
        "GitHub Actions Ubuntu runners",
        "contract checks must not require local Mac QEMU",
        "exact machine inventory and disposable media details",
    ):
        if not _contains_phrase(text, phrase):
            raise AssertionError(f"boot/uefi/CONTRACT.txt missing UEFI scaffold phrase: {phrase}")

    makefile = _read(root / "Makefile")
    if "boot/uefi" in makefile:
        raise AssertionError("boot/uefi must not be wired into the current Makefile image path")

    validate_uefi_host_artifact_build(root)
    validate_uefi_ovmf_cloud_scaffold(root)
    return rows


def _validate_pci_source_contract(root: Path) -> None:
    kernel = _read(root / "kernel" / "kernel.asm")

    for phrase in (
        "PCI_CONFIG_ADDRESS equ 0x0cf8",
        "PCI_CONFIG_DATA equ 0x0cfc",
        "PCI_CONFIG_ENABLE equ 0x80000000",
        "PCI_CONFIG_HEADER_REG equ 0x0c",
        "PCI_CONFIG_BRIDGE_BUS_REG equ 0x18",
        "PCI_CONFIG_BAR5_REG equ 0x24",
        "PCI_HEADER_MULTIFUNCTION_FLAG equ 0x00800000",
        "PCI_CLASS_MASS_STORAGE equ 0x01",
        "PCI_CLASS_MULTIMEDIA equ 0x04",
        "PCI_CLASS_BRIDGE equ 0x06",
        "PCI_SUBCLASS_IDE equ 0x01",
        "PCI_SUBCLASS_AHCI equ 0x06",
        "PCI_SUBCLASS_AUDIO equ 0x01",
        "PCI_SUBCLASS_HDA equ 0x03",
        "PCI_SUBCLASS_PCI_BRIDGE equ 0x04",
        "PCI_PROGIF_AHCI equ 0x01",
        "PCI_LOOKUP_ANY equ 0xff",
        "PCI_LOOKUP_ID_ANY equ 0xffff",
        "PCI_LOOKUP_NOT_FOUND equ 0xffffffff",
        "PCI_DIAG_SCAN_COMPLETE equ 0x00000001",
        "PCI_DIAG_TABLE_BOUNDED equ 0x00000002",
        "PCI_DIAG_ABSENT_COUNTED equ 0x00000004",
        "PCI_DIAG_CONFIG_DISABLED equ 0x00000008",
        "PCI_DIAG_INDEX_GUARD equ 0x00000010",
        "PCI_DIAG_ID_LOOKUP equ 0x00000020",
        "PCI_DIAG_CLASS_LOOKUP equ 0x00000040",
        "PCI_DIAG_STATUS_ONLY_CONSUMER equ 0x00000080",
        "PCI_SCAN_BUS_COUNT equ 256",
        "PCI_SCAN_DEVICE_COUNT equ 32",
        "PCI_SCAN_FUNCTION_COUNT equ 8",
        "PCI_SCAN_BUS_PROBES equ PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT",
        "PCI_SCAN_FUNCTION_PROBES equ PCI_SCAN_BUS_COUNT * PCI_SCAN_BUS_PROBES",
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
        "PCI_TABLE_MAX_ENTRIES equ PCI_SCAN_BUS_PROBES",
        "BLOCK_DEVICE_AHCI equ 2",
        "AHCI_BAR_STATE_NONE equ 0",
        "AHCI_BAR_STATE_MMIO equ 1",
        "AHCI_BAR_STATE_INVALID equ 2",
        "AHCI_PROOF_REQ_PCI_CLASS equ 0x00000001",
        "AHCI_PROOF_REQ_BAR5_MMIO equ 0x00000002",
        "AHCI_PROOF_REQ_HBA_RESET equ 0x00000004",
        "AHCI_PROOF_REQ_PORT_DETECT equ 0x00000008",
        "AHCI_PROOF_REQ_IDENTIFY equ 0x00000010",
        "AHCI_PROOF_REQ_SECTOR_IO equ 0x00000020",
        "AHCI_PROOF_REQ_NO_IDE_FALLBACK equ 0x00000040",
        "AHCI_PROOF_REQUIRED_MASK equ 0x0000007f",
        "AHCI_GUARD_NO_SILENT_BIND equ 0x00000001",
        "AHCI_GUARD_UNSUPPORTED_REJECTED equ 0x00000002",
        "AHCI_GUARD_ATA_ONLY_OPS equ 0x00000004",
        "BLOCK_OPS_READ_OFFSET equ 0",
        "BLOCK_OPS_WRITE_OFFSET equ 4",
        "BLOCK_OPS_FLUSH_OFFSET equ 8",
        "BLOCK_OPS_DWORDS equ 3",
        "BLOCK_ERROR_UNSUPPORTED_CONTROLLER equ 7",
        "call pci_scan_qemu",
        "call block_driver_probe_storage_classes",
        "pci_scan_qemu:",
        "mov byte [pci_table_api_status], 0",
        "cmp dword [pci_scan_bus_index], PCI_SCAN_BUS_COUNT",
        "cmp esi, PCI_SCAN_DEVICE_COUNT",
        "cmp edi, PCI_SCAN_FUNCTION_COUNT",
        "inc dword [pci_absent_count]",
        "mov [pci_highest_bus], eax",
        "PCI_CONFIG_BRIDGE_BUS_REG",
        "mov [pci_bridge_bus_info], eax",
        "mov edi, pci_device_table",
        "rep stosd",
        "PCI_TABLE_LOCATION_OFFSET",
        "PCI_TABLE_VENDOR_DEVICE_OFFSET",
        "PCI_TABLE_CLASS_OFFSET",
        "PCI_TABLE_HEADER_OFFSET",
        "pci_table_entry_by_index:",
        "pci_table_find_first_by_class:",
        "pci_table_find_first_by_id:",
        "pci_config_read_dword_by_bdf:",
        "pci_table_probe_lookup_contract:",
        "block_driver_install_ata_pio_ops:",
        "block_driver_probe_storage_classes:",
        "block_driver_record_ahci_probe:",
        "block_ata_pio_ops:",
        "call dword [block_driver_read_op]",
        "call dword [block_driver_write_op]",
        "call dword [block_driver_flush_op]",
        "call pci_table_probe_lookup_contract",
        "or dword [pci_diag_flags], PCI_DIAG_SCAN_COMPLETE",
        "or dword [pci_diag_flags], PCI_DIAG_TABLE_BOUNDED",
        "or dword [pci_diag_flags], PCI_DIAG_ABSENT_COUNTED",
        "or dword [pci_diag_flags], PCI_DIAG_CONFIG_DISABLED",
        "or dword [pci_diag_flags], PCI_DIAG_INDEX_GUARD",
        "or dword [pci_diag_flags], PCI_DIAG_ID_LOOKUP",
        "or dword [pci_diag_flags], PCI_DIAG_CLASS_LOOKUP",
        "or dword [pci_diag_flags], PCI_DIAG_STATUS_ONLY_CONSUMER",
        "mov byte [pci_table_consumer_status], 1",
        "pci_device_table times PCI_TABLE_MAX_ENTRIES * PCI_TABLE_ENTRY_DWORDS dd 0",
        "out dx, eax",
        "in eax, dx",
        'smoke_pci_text db " pci="',
        'smoke_pciprobe_text db " pciprobe="',
        'smoke_pcimiss_text db " pcimiss="',
        'smoke_pcicount_text db " pcicount="',
        'smoke_pcihbus_text db " pcihbus="',
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
        'smoke_pciclspb_text db " pciclspb="',
        'smoke_pcibrbus_text db " pcibrbus="',
        'smoke_pciclsmm_text db " pciclsmm="',
        'smoke_pcidiag_text db " pcidiag="',
        'smoke_pciapi_text db " pciapi="',
        'smoke_pcilookms_text db " pcilookms="',
        'smoke_pcilookbr_text db " pcilookbr="',
        'smoke_pcilookid_text db " pcilookid="',
        'smoke_pcilookmiss_text db " pcilookmiss="',
        'smoke_pcicons_text db " pcicons="',
        'smoke_pcilookide_text db " pcilookide="',
        'smoke_pcilookahci_text db " pcilookahci="',
        'smoke_pcilookaud_text db " pcilookaud="',
        'smoke_pcilookhda_text db " pcilookhda="',
        'smoke_blkctrl_text db " blkctrl="',
        'smoke_blkrej_text db " blkrej="',
        'smoke_ahcibar_text db " ahcibar="',
        'smoke_ahcireq_text db " ahcireq="',
        "pci_scan_bus_index dd 0",
        "pci_probe_count dd 0",
        "pci_absent_count dd 0",
        "pci_function_count dd 0",
        "pci_table_count dd 0",
        "pci_table_overflow_count dd 0",
        "pci_highest_bus dd 0",
        "pci_first_bdf dd 0",
        "pci_first_id dd 0",
        "pci_first_class dd 0",
        "pci_last_bdf dd 0",
        "pci_class_table_hash dd 0",
        "pci_multifunction_device_count dd 0",
        "pci_mass_storage_class_count dd 0",
        "pci_bridge_class_count dd 0",
        "pci_pci_bridge_class_count dd 0",
        "pci_multimedia_class_count dd 0",
        "pci_bridge_bus_info dd PCI_LOOKUP_NOT_FOUND",
        "pci_diag_flags dd 0",
        "pci_lookup_mass_storage_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_bridge_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_ide_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_ahci_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_audio_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_hda_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_first_id_bdf dd PCI_LOOKUP_NOT_FOUND",
        "pci_lookup_miss_bdf dd PCI_LOOKUP_NOT_FOUND",
        "block_driver_read_op dd 0",
        "block_driver_write_op dd 0",
        "block_driver_flush_op dd 0",
        "block_driver_supported_bdf dd PCI_LOOKUP_NOT_FOUND",
        "block_driver_ahci_bdf dd PCI_LOOKUP_NOT_FOUND",
        "ahci_probe_bdf dd PCI_LOOKUP_NOT_FOUND",
        "ahci_required_mask dd AHCI_PROOF_REQUIRED_MASK",
        "pci_table_api_status db 0",
        "pci_table_consumer_status db 0",
    ):
        if phrase not in kernel:
            raise AssertionError(f"kernel missing bounded PCI status contract phrase: {phrase}")


def _validate_interrupt_timer_source_contract(root: Path) -> None:
    kernel = _read(root / "kernel" / "kernel.asm")
    for phrase in (
        "PIT_IRQ_HZ equ 100",
        "CLOCK_MONOTONIC_HZ equ PIT_IRQ_HZ",
        "pic_unmask_timer_keyboard:",
        "pit_init_100hz:",
        'smoke_clocksrc_text db " clocksrc=PIT"',
        'smoke_irqctl_text db " irqctl=PIC"',
        'smoke_apic_text db " apic=NONE"',
        'smoke_hpet_text db " hpet=NONE"',
        "mov esi, smoke_irqctl_text",
        "mov esi, smoke_apic_text",
        "mov esi, smoke_hpet_text",
    ):
        if phrase not in kernel:
            raise AssertionError(f"kernel missing interrupt/timer status contract phrase: {phrase}")


def _validate_claim_wording(root: Path) -> None:
    matrix_path = _doc_contract_path(root, "architecture")
    for path in _repo_text_files(root):
        if path == matrix_path:
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


def _validate_block_driver_status_fields(
    fields: dict[str, str],
    *,
    lookup_ide: int,
    lookup_ahci: int,
) -> None:
    device_kind, ide_bdf, ahci_bdf = _hex_tuple_field(fields, "blkctrl", 3)
    rejected_count, last_rejected_kind = _hex_tuple_field(fields, "blkrej", 2)
    ahci_bar_bdf, ahci_bar_raw, ahci_bar_base, ahci_bar_state = _hex_tuple_field(fields, "ahcibar", 4)
    ahci_required, ahci_observed, ahci_guard = _hex_tuple_field(fields, "ahcireq", 3)

    if device_kind not in {0, BLOCK_DEVICE_ATA_PIO}:
        raise AssertionError("blkctrl= must not claim a non-ATA active block controller yet")
    if ide_bdf != lookup_ide:
        raise AssertionError("blkctrl= IDE BDF must mirror the PCI storage-class lookup result")
    if ahci_bdf != lookup_ahci:
        raise AssertionError("blkctrl= AHCI BDF must mirror the PCI AHCI class lookup result")
    if ahci_bdf == 0xFFFFFFFF:
        if rejected_count != 0 or last_rejected_kind != 0:
            raise AssertionError("blkrej= must stay zero when no AHCI storage class is present")
        if (ahci_bar_bdf, ahci_bar_raw, ahci_bar_base, ahci_bar_state) != (
            0xFFFFFFFF,
            0xFFFFFFFF,
            0,
            AHCI_BAR_STATE_NONE,
        ):
            raise AssertionError("ahcibar= must stay absent when no AHCI storage class is present")
        if ahci_observed != 0:
            raise AssertionError("ahcireq= observed mask must stay zero when AHCI is absent")
    elif rejected_count == 0 or last_rejected_kind != BLOCK_DEVICE_AHCI:
        raise AssertionError("blkrej= must record AHCI as explicitly unsupported when an AHCI class is seen")
    else:
        if ahci_bar_bdf != ahci_bdf:
            raise AssertionError("ahcibar= BDF must mirror the PCI AHCI class lookup result")
        if ahci_bar_state not in {AHCI_BAR_STATE_MMIO, AHCI_BAR_STATE_INVALID}:
            raise AssertionError("ahcibar= must classify a present AHCI BAR5 as MMIO or invalid")
        if (ahci_observed & AHCI_PROOF_REQ_PCI_CLASS) == 0:
            raise AssertionError("ahcireq= observed mask must record the AHCI PCI class when present")
        if ahci_bar_state == AHCI_BAR_STATE_MMIO:
            if ahci_bar_raw == 0xFFFFFFFF or (ahci_bar_raw & 1) or ahci_bar_base == 0:
                raise AssertionError("ahcibar= MMIO BAR5 must have an MMIO raw value and nonzero base")
            if (ahci_observed & AHCI_PROOF_REQ_BAR5_MMIO) == 0:
                raise AssertionError("ahcireq= observed mask must record BAR5 MMIO when ahcibar= is MMIO")
        elif ahci_observed & AHCI_PROOF_REQ_BAR5_MMIO:
            raise AssertionError("ahcireq= BAR5 MMIO bit requires ahcibar= MMIO state")
        if (ahci_guard & AHCI_GUARD_UNSUPPORTED_REJECTED) == 0:
            raise AssertionError("ahcireq= guard mask must record unsupported AHCI rejection when AHCI is present")
    if ahci_required != AHCI_PROOF_REQUIRED_MASK:
        raise AssertionError("ahcireq= required mask must name the full future AHCI proof contract")
    if ahci_observed & ~AHCI_PROOF_DISCOVERY_MASK:
        raise AssertionError("ahcireq= observed mask must not claim HBA reset, identify, sector I/O, or no-IDE fallback")
    if (ahci_guard & AHCI_GUARD_NO_SILENT_BIND) == 0:
        raise AssertionError("ahcireq= guard mask must record no-silent-AHCI-bind policy")
    if device_kind == BLOCK_DEVICE_ATA_PIO and (ahci_guard & AHCI_GUARD_ATA_ONLY_OPS) == 0:
        raise AssertionError("ahcireq= guard mask must record that only ATA ops are installed today")


def validate_pci_status_text(status: str) -> dict[str, str]:
    fields = _parse_status_fields(status)
    missing = sorted(PCI_STATUS_FIELDS - set(fields))
    if missing:
        raise AssertionError(f"status missing PCI fields: {', '.join(missing)}")

    pci_state = fields["pci"]
    if pci_state not in {"OK", "NONE"}:
        raise AssertionError("pci= must be OK or NONE")

    probes = _hex8_field(fields, "pciprobe")
    if probes != PCI_QEMU_CONFIG_PROBES:
        raise AssertionError(f"pciprobe= must be {PCI_QEMU_CONFIG_PROBES:08X} for the bounded PCI config scan")

    absent = _hex8_field(fields, "pcimiss")
    count = _hex8_field(fields, "pcicount")
    highest_bus = _hex8_field(fields, "pcihbus")
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
    pci_bridge_count = _hex8_field(fields, "pciclspb")
    bridge_bus_info = _hex8_field(fields, "pcibrbus")
    multimedia_count = _hex8_field(fields, "pciclsmm")
    diag_flags = _hex8_field(fields, "pcidiag")
    lookup_mass_storage = _hex8_field(fields, "pcilookms")
    lookup_bridge = _hex8_field(fields, "pcilookbr")
    lookup_id = _hex8_field(fields, "pcilookid")
    lookup_miss = _hex8_field(fields, "pcilookmiss")
    lookup_ide = _hex8_field(fields, "pcilookide")
    lookup_ahci = _hex8_field(fields, "pcilookahci")
    lookup_audio = _hex8_field(fields, "pcilookaud")
    lookup_hda = _hex8_field(fields, "pcilookhda")
    _validate_block_driver_status_fields(
        fields,
        lookup_ide=lookup_ide,
        lookup_ahci=lookup_ahci,
    )

    if fields["pcitable"] != "OK":
        raise AssertionError("pcitable= must be OK for the bounded table builder")
    if fields["pciapi"] != "OK":
        raise AssertionError("pciapi= must be OK for the read-only PCI table lookup API")
    if fields["pcicons"] != "OK":
        raise AssertionError("pcicons= must be OK for the read-only PCI table consumer proof")
    if table_capacity != PCI_TABLE_CAPACITY:
        raise AssertionError(f"pcitabcap= must be {PCI_TABLE_CAPACITY:08X}")
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
    if absent + count != probes:
        raise AssertionError("pcimiss= plus pcicount= must equal the bounded PCI probe count")
    if highest_bus >= PCI_SCAN_BUS_COUNT:
        raise AssertionError("pcihbus= must stay inside the bounded PCI bus scan")
    if diag_flags & PCI_DIAG_REQUIRED_MASK != PCI_DIAG_REQUIRED_MASK:
        raise AssertionError("pcidiag= must prove scan, table, lookup, and status-only consumer diagnostics")

    if pci_state == "NONE":
        if any(
            (
                count,
                highest_bus,
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
                pci_bridge_count,
                multimedia_count,
            )
        ):
            raise AssertionError("pci=NONE must keep PCI table counters and summaries at zero")
        if bridge_bus_info != 0xFFFFFFFF:
            raise AssertionError("pci=NONE must keep pcibrbus= at the miss sentinel")
        if any(
            value != 0xFFFFFFFF
            for value in (lookup_mass_storage, lookup_bridge, lookup_id, lookup_ide, lookup_ahci, lookup_audio, lookup_hda)
        ):
            raise AssertionError("pci=NONE must keep PCI lookup fields at the miss sentinel")
        return fields

    if count == 0:
        raise AssertionError("pci=OK requires pcicount= to be nonzero")
    first_bus = (first_bdf >> 16) & 0xff
    device = (first_bdf >> 8) & 0xff
    function = first_bdf & 0xff
    if first_bus >= PCI_SCAN_BUS_COUNT or device >= PCI_SCAN_DEVICE_COUNT or function >= PCI_SCAN_FUNCTION_COUNT:
        raise AssertionError("pcifirst= bus/device/function is outside the bounded PCI config scan")
    if first_id in (0, 0xffffffff) or (first_id & 0xffff) == 0xffff:
        raise AssertionError("pciid= must record a present config-space vendor/device dword")
    if first_class == 0xffffffff:
        raise AssertionError("pciclass= must record a present config-space class dword")
    last_bus = (last_bdf >> 16) & 0xff
    last_device = (last_bdf >> 8) & 0xff
    last_function = last_bdf & 0xff
    if last_bus >= PCI_SCAN_BUS_COUNT or last_device >= PCI_SCAN_DEVICE_COUNT or last_function >= PCI_SCAN_FUNCTION_COUNT:
        raise AssertionError("pcilast= bus/device/function is outside the bounded PCI config scan")
    if first_bus > highest_bus or last_bus > highest_bus:
        raise AssertionError("pcihbus= must cover first and last present PCI functions")
    if class_hash == 0:
        raise AssertionError("pciclassh= must summarize the populated PCI class table")
    if any(value > count for value in (multifunction_count, mass_storage_count, bridge_count, pci_bridge_count, multimedia_count)):
        raise AssertionError("PCI class-table counters must not exceed pcicount=")
    if pci_bridge_count > bridge_count:
        raise AssertionError("pciclspb= must not exceed the broader bridge-class count")
    if pci_bridge_count == 0:
        if bridge_bus_info != 0xFFFFFFFF:
            raise AssertionError("pcibrbus= must stay at the miss sentinel when no PCI-to-PCI bridge is seen")
    else:
        if bridge_bus_info == 0xFFFFFFFF:
            raise AssertionError("pcibrbus= must expose the first PCI-to-PCI bridge bus register")
        primary = bridge_bus_info & 0xff
        secondary = (bridge_bus_info >> 8) & 0xff
        subordinate = (bridge_bus_info >> 16) & 0xff
        if primary >= PCI_SCAN_BUS_COUNT or secondary >= PCI_SCAN_BUS_COUNT or subordinate >= PCI_SCAN_BUS_COUNT:
            raise AssertionError("pcibrbus= bridge bus numbers must stay inside the bounded PCI bus scan")
    for field_name, bdf in (
        ("pcilookms", lookup_mass_storage),
        ("pcilookbr", lookup_bridge),
        ("pcilookid", lookup_id),
        ("pcilookide", lookup_ide),
        ("pcilookahci", lookup_ahci),
        ("pcilookaud", lookup_audio),
        ("pcilookhda", lookup_hda),
    ):
        if bdf == 0xFFFFFFFF:
            continue
        lookup_bus = (bdf >> 16) & 0xff
        lookup_device = (bdf >> 8) & 0xff
        lookup_function = bdf & 0xff
        if lookup_bus >= PCI_SCAN_BUS_COUNT or lookup_device >= PCI_SCAN_DEVICE_COUNT or lookup_function >= PCI_SCAN_FUNCTION_COUNT:
            raise AssertionError(f"{field_name}= bus/device/function is outside the bounded PCI config scan")
    if mass_storage_count and lookup_mass_storage == 0xFFFFFFFF:
        raise AssertionError("pcilookms= must find the first mass-storage class entry when pciclsms= is nonzero")
    if bridge_count and lookup_bridge == 0xFFFFFFFF:
        raise AssertionError("pcilookbr= must find the first bridge class entry when pciclsbr= is nonzero")
    if lookup_id != first_bdf:
        raise AssertionError("pcilookid= must find the first table entry by exact vendor/device id")
    if diag_flags & PCI_DIAG_ID_LOOKUP == 0:
        raise AssertionError("pcidiag= must prove the exact vendor/device lookup path on nonempty PCI tables")
    if multimedia_count and lookup_audio == 0xFFFFFFFF and lookup_hda == 0xFFFFFFFF:
        raise AssertionError("multimedia PCI classes must expose an audio or HDA lookup boundary")

    return fields


def validate_claimed_hardware_status_text(status: str) -> dict[str, str]:
    fields = _parse_status_fields(status)
    for proof_id, proof in STATUS_PROOFS.items():
        _require_fields(fields, proof["fields"], proof_id)

    if fields["clocksrc"] != "PIT":
        raise AssertionError("clocksrc= must remain PIT until APIC/HPET has its own proof row")
    if fields["irqctl"] != "PIC":
        raise AssertionError("irqctl= must remain PIC until APIC/IOAPIC routing is proved")
    if fields["apic"] != "NONE":
        raise AssertionError("apic= must remain NONE until Local APIC/IOAPIC support is proved")
    if fields["hpet"] != "NONE":
        raise AssertionError("hpet= must remain NONE until HPET support is proved")
    clock_irq = _hex8_field(fields, "clockirq")
    clock_tick = _hex8_field(fields, "clocktick")
    clock_hz = _hex8_field(fields, "clockhz")
    clock_ms = _hex8_field(fields, "clockms")
    _hex8_field(fields, "clockdoom")
    _hex8_field(fields, "clocksch")
    _hex8_field(fields, "clockpirq")
    if clock_irq == 0 or clock_tick == 0:
        raise AssertionError("clockirq= and clocktick= must be nonzero for claimed PIT proof")
    if clock_irq != clock_tick:
        raise AssertionError("clockirq= must match clocktick= for the current PIC/PIT path")
    if clock_hz != 100:
        raise AssertionError("clockhz= must prove the generic PIT clock is 100 Hz")
    if clock_ms != clock_tick * 10:
        raise AssertionError("clockms= must match the PIT 100 Hz tick accounting")

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

    input_depth = _hex_tuple_field(fields, "inputdepth", 2)
    input_stat = _hex_tuple_field(fields, "inputstat", 4)
    input_policy = _hex_tuple_field(fields, "inputpolicy", 2)
    input_dev = _hex_tuple_field(fields, "inputdev", 2)
    input_devices = _hex_tuple_field(fields, "inputdevices", 5)
    input_mods = _hex8_field(fields, "inputmods")
    if input_policy[0] != 1:
        raise AssertionError("inputpolicy= must prove overwrite-oldest overflow handling")
    if input_policy[1] == 0 or input_policy[1] != input_stat[3]:
        raise AssertionError("inputpolicy= usable capacity must match inputstat=")
    if input_depth[0] > input_stat[3]:
        raise AssertionError("inputdepth= queued depth must fit the usable capacity")
    if input_depth[1] != input_stat[2]:
        raise AssertionError("inputdepth= dropped counter must match inputstat=")
    if input_stat[0] != input_depth[0] + input_stat[1] + input_stat[2]:
        raise AssertionError("inputstat= total must equal queued + polled + dropped")
    if input_dev[0] != 1:
        raise AssertionError("inputdev= must report a ready keyboard for PS/2 input proof")
    if input_dev[1] not in {0, 1, 2}:
        raise AssertionError("inputdev= mouse status must be a bounded device-status value")
    device_count, ready_mask, cap_mask, keyboard_polls, mouse_polls = input_devices
    if device_count != 2:
        raise AssertionError("inputdevices= must report keyboard and mouse device slots")
    if ready_mask & ~0x3:
        raise AssertionError("inputdevices= ready mask must stay bounded to keyboard/mouse")
    if (cap_mask & 0x1F) != 0x1F:
        raise AssertionError("inputdevices= must expose keyboard, mouse, poll, status, and device-status capabilities")
    if keyboard_polls + mouse_polls > input_stat[1]:
        raise AssertionError("inputdevices= per-device poll counters must not exceed inputstat= polled events")
    if input_mods & ~0x7:
        raise AssertionError("inputmods= must stay within shift/ctrl/alt modifier bits")

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
    _hex_tuple_field(fields, "fbdev", 4)
    _hex_tuple_field(fields, "fbmmio", 4)
    _hex_tuple_field(fields, "fbinfo", 3)
    _hex_tuple_field(fields, "fbpresent", 9)
    fbsrc = _hex_tuple_field(fields, "fbsrc", 7)
    fbacct = _hex_tuple_field(fields, "fbacct", 9)
    _hex_tuple_field(fields, "fbgeom", 5)
    _hex_tuple_field(fields, "fbdirty", 5)
    if fbsrc != (1, 320, 200, 320, 240, 256, 3):
        raise AssertionError("fbsrc= must report the claimed indexed source format")
    if fbacct[0] != 1 or fbacct[1] != 1:
        raise AssertionError("fbacct= must report ABI version 1 and indexed-source present semantics")
    if any(value != 0 for value in fbacct[2:5]):
        raise AssertionError("fbacct= must not report rejected present descriptors in a green proof")
    if fbacct[7] != 320 * 200 or fbacct[8] != 256 * 3:
        raise AssertionError("fbacct= must account the source frame and palette byte sizes")
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
    matrix_text = _read(_doc_contract_path(root, "architecture"))

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
    _validate_pci_table_consumer_rows(matrix_text)
    _validate_pci_table_contract_rows(matrix_text)
    _validate_block_driver_boundary_rows(matrix_text)
    _validate_proof_requirement_rows(matrix_text)
    _validate_negative_claim_rows(matrix_text)
    _validate_next_unlock_rows(matrix_text)
    _validate_next_implementation_contract_rows(matrix_text)
    _validate_status_proof_rows(matrix_text)
    _validate_interrupt_timer_boundary_rows(matrix_text)
    _validate_uefi_scaffold(root)
    _validate_pci_source_contract(root)
    _validate_interrupt_timer_source_contract(root)

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
