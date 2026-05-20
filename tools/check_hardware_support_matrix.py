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
    "bounded PCI config-space status probe",
    "PCI_STATUS[QEMU_BUS0_CONFIG]",
    "General PCI bus/device/function enumeration is not implemented",
    "AHCI/SATA native storage is not implemented",
    "USB input and storage are not implemented",
    "Multiprocessor startup and scheduling are not implemented",
    "Local APIC, IOAPIC, and APIC timer support are not implemented",
    "HPET timer support is not implemented",
    "No real PC or broad hardware compatibility claim",
    "QEMU evidence alone can only claim the matching QEMU device model",
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

PCI_STATUS_FIELDS = {
    "pci",
    "pciprobe",
    "pcicount",
    "pcifirst",
    "pciid",
    "pciclass",
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
        "PCI_SCAN_DEVICE_COUNT equ 32",
        "PCI_SCAN_FUNCTION_COUNT equ 8",
        "PCI_SCAN_FUNCTION_PROBES equ PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT",
        "call pci_scan_qemu",
        "pci_scan_qemu:",
        "cmp esi, PCI_SCAN_DEVICE_COUNT",
        "cmp edi, PCI_SCAN_FUNCTION_COUNT",
        "out dx, eax",
        "in eax, dx",
        'smoke_pci_text db " pci="',
        'smoke_pciprobe_text db " pciprobe="',
        'smoke_pcicount_text db " pcicount="',
        'smoke_pcifirst_text db " pcifirst="',
        'smoke_pciid_text db " pciid="',
        'smoke_pciclass_text db " pciclass="',
        "pci_probe_count dd 0",
        "pci_function_count dd 0",
        "pci_first_bdf dd 0",
        "pci_first_id dd 0",
        "pci_first_class dd 0",
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

    if pci_state == "NONE":
        if any((count, first_bdf, first_id, first_class)):
            raise AssertionError("pci=NONE must keep pcicount, pcifirst, pciid, and pciclass at zero")
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

    return fields


def validate_repo_contract(root: Path = ROOT) -> dict[str, dict[str, str]]:
    matrix_text = _read(root / "docs" / "hardware-support.md")

    for phrase in REQUIRED_MATRIX_PHRASES:
        if not _contains_phrase(matrix_text, phrase):
            raise AssertionError(f"hardware support matrix missing phrase: {phrase}")

    rows = _validate_support_rows(matrix_text)
    _validate_pci_status_rows(matrix_text)
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
