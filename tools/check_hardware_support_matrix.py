#!/usr/bin/env python3
"""Validate the bounded hardware support matrix and claim wording."""

from __future__ import annotations

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
        "QEMU BIOS/IDE/PS2/VBE/SB16",
        "not broad PC or physical hardware compatibility",
    ),
    "docs/post-checkpoint-gaps.md": (
        "docs/hardware-support.md",
        "SUPPORT[...]",
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
        "QEMU BIOS/IDE/PS2/VBE/SB16",
    ),
}

SUPPORT_RE = re.compile(
    r"^- `SUPPORT\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"scope=(?P<scope>[a-z0-9-]+) "
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

    return rows


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


def validate_repo_contract(root: Path = ROOT) -> dict[str, dict[str, str]]:
    matrix_text = _read(root / "docs" / "hardware-support.md")

    for phrase in REQUIRED_MATRIX_PHRASES:
        if not _contains_phrase(matrix_text, phrase):
            raise AssertionError(f"hardware support matrix missing phrase: {phrase}")

    rows = _validate_support_rows(matrix_text)

    for relative_path, phrases in REQUIRED_CROSS_DOC_LINKS.items():
        text = _read(root / relative_path)
        for phrase in phrases:
            if not _contains_phrase(text, phrase):
                raise AssertionError(f"{relative_path} missing hardware-boundary phrase: {phrase}")

    _validate_claim_wording(root)
    return rows


def main() -> int:
    try:
        rows = validate_repo_contract()
    except AssertionError as exc:
        print(f"hardware support matrix failed: {exc}", file=sys.stderr)
        return 1

    claimed = sum(1 for row in rows.values() if row["status"] == "claimed")
    unclaimed = sum(1 for row in rows.values() if row["status"] == "unclaimed")
    print(
        "hardware support matrix OK: "
        f"{claimed} bounded claimed classes, {unclaimed} unclaimed classes"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
