#!/usr/bin/env python3
"""Validate the machine-readable Doom playability gap ledger."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs" / "post-checkpoint-gaps.md"

REQUIRED_GAPS = {
    "CLOUD_BOOT": {
        "category": "cloud-boot",
        "phrases": (
            "manual real-WAD cloud workflow",
            "exact commit",
        ),
    },
    "REAL_GAMEPLAY": {
        "category": "real-gameplay",
        "phrases": (
            "check_real_wad_proof.py",
            "GS_LEVEL",
        ),
    },
    "HUMAN_PLAYTEST": {
        "category": "human-playtest",
        "phrases": (
            "remote VNC playtest",
            "keyboard actions visibly affect",
        ),
    },
    "PERSISTENCE": {
        "category": "persistence",
        "phrases": (
            "cloud reboot proof",
            "same disk image is booted again",
        ),
    },
    "AUDIO": {
        "category": "audio",
        "phrases": (
            "audible output",
            "streamed music chunks",
        ),
    },
    "VM_POSIX": {
        "category": "vm-posix",
        "phrases": (
            "This is not a full POSIX environment",
            "arbitrary root-level FAT16 `.ELF` paths",
            "generic probe-class exec fallback",
            "identity-mapped",
        ),
    },
    "SHUTDOWN_PANIC": {
        "category": "shutdown-panic",
        "phrases": (
            "26157926297",
            "guest_exit_observed=true",
            "panic=KEXC",
            "shutdown=HALT",
            "shutdown=REBOOT",
            "shutdown=POWEROFF",
        ),
    },
    "HARDWARE_LIMITS": {
        "category": "hardware-limits",
        "phrases": (
            "QEMU BIOS/IDE/PS2/VBE/SB16",
            "docs/hardware-support.md",
            "SUPPORT[...]",
            "check_hardware_support_matrix.py",
            "physical hardware",
        ),
    },
}

LATEST_RUN_PHRASES = (
    "Latest Cloud Evidence",
    "last published scripted cloud truth-serum run",
    "Current-head cloud proof state: pending",
    "26165681561",
    "c525952",
    "real-WAD, human-playability",
    "scripted gameplay transition",
    "audible-audio manifest",
    "artifact hygiene",
    "26165678183",
    "Persistence is not current-head proven",
    "26156172979",
    "eabd307",
    "DOOMSAV0.DSG bytes=512 changed-from-baseline",
    "survived-reboot description='VIBESAVE'",
    "reboot status runtime=OK",
    "26150621804",
    "1db3a7a",
    "usr=FAIL",
    "failed the proof gate",
    "26149350434",
    "da9c136",
    "then-current scripted checker",
    "playability-status-green",
    "doomrun=RUN",
    "doomopen=OK",
    "doomread=OK",
    "IWAD",
    "Frame/gameplay counters are active",
    "SB16/audio counters",
    "preemption counters are active",
    "workflow, or proof-checker change",
    "usr=OK",
    "scripted `use`",
    "mouse effect",
    "audio-continuity",
    "check_audio_continuity_proof.py",
    "26149570191",
    "memset+0x20",
    "doomfaultip=01029F20",
    "audio-proof.json",
    "26146035600",
    "269dbb8",
    "FindResponseFile+0x34",
    "doomfaultip=01003224",
    "26146488906",
    "34eb98d",
    "W_AddFile+0x246",
    "doomfaultip=01024D06",
    "human-facing Doom-capable proof",
)

FORBIDDEN_STALE_CURRENT_PROOF_PHRASES = (
    "is the current scripted cloud truth-serum run for the current runtime code",
    "is the current scripted cloud proof that passes the serious real-WAD gates for the current runtime code",
    "Nothing is missing for this exact commit's scripted cloud-boot gate: `c525952`",
    "Nothing is missing for this exact commit's scripted real-gameplay gate",
)

PROVEN_GAPS = {"CLOUD_BOOT", "REAL_GAMEPLAY", "SHUTDOWN_PANIC"}

GAP_RE = re.compile(
    r"^- `GAP\[(?P<id>[A-Z0-9_]+)\] "
    r"status=(?P<status>[a-z-]+) "
    r"category=(?P<category>[a-z0-9-]+) "
    r"gate=(?P<gate>[a-zA-Z0-9_.:-]+) "
    r"evidence=(?P<evidence>[a-zA-Z0-9_.:-]+)`",
    re.MULTILINE,
)


def _gap_blocks(text: str):
    matches = list(GAP_RE.finditer(text))
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        yield match, text[match.start() : end]


def _contains_phrase(text: str, phrase: str) -> bool:
    return " ".join(phrase.split()) in " ".join(text.split())


def validate_ledger(root: Path = ROOT) -> dict[str, dict[str, str]]:
    text = (root / "docs" / "post-checkpoint-gaps.md").read_text()
    matches_and_blocks = list(_gap_blocks(text))
    gaps: dict[str, dict[str, str]] = {}

    for match, block in matches_and_blocks:
        gap_id = match.group("id")
        if gap_id in gaps:
            raise AssertionError(f"duplicate gap id: {gap_id}")
        gaps[gap_id] = match.groupdict()
        status = match.group("status")
        if gap_id in PROVEN_GAPS:
            if status != "proven":
                raise AssertionError(f"{gap_id} must be status=proven after its gate is proven")
        elif status != "open":
            raise AssertionError(f"{gap_id} must stay status=open until its gate is proven")
        for heading in ("Current state:", "Still missing:", "Executable gate:"):
            if heading not in block:
                raise AssertionError(f"{gap_id} missing section heading: {heading}")

    missing = sorted(set(REQUIRED_GAPS) - set(gaps))
    if missing:
        raise AssertionError(f"missing required gap ids: {', '.join(missing)}")

    extras = sorted(set(gaps) - set(REQUIRED_GAPS))
    if extras:
        raise AssertionError(f"unexpected gap ids: {', '.join(extras)}")

    for gap_id, contract in REQUIRED_GAPS.items():
        if gaps[gap_id]["category"] != contract["category"]:
            raise AssertionError(
                f"{gap_id} category {gaps[gap_id]['category']} != {contract['category']}"
            )
        block = next(block for match, block in matches_and_blocks if match.group("id") == gap_id)
        for phrase in contract["phrases"]:
            if not _contains_phrase(block, phrase):
                raise AssertionError(f"{gap_id} missing phrase: {phrase}")

    readme = (root / "README.md").read_text()
    tests_readme = (root / "tests" / "README.md").read_text()
    playable_cloud_proof = (root / "docs" / "playable-cloud-proof.md").read_text()
    hardware_support = (root / "docs" / "hardware-support.md").read_text()
    makefile = (root / "Makefile").read_text()
    for phrase in LATEST_RUN_PHRASES:
        if not _contains_phrase(text, phrase):
            raise AssertionError(f"gap ledger missing latest-run phrase: {phrase}")
    combined_claim_surface = "\n".join((text, readme, playable_cloud_proof))
    for phrase in FORBIDDEN_STALE_CURRENT_PROOF_PHRASES:
        if _contains_phrase(combined_claim_surface, phrase):
            raise AssertionError(f"claim surface still uses stale current-proof phrase: {phrase}")
    for phrase in (
        "scripted cloud evidence",
        "26165681561",
        "c525952",
        "26165678183",
        "playability-status-green",
        "Persistence/save-load should only be claimed",
        "Current-head cloud proof state: pending",
        "gh workflow run os-smoke.yml",
        "gh workflow run real-wad-smoke.yml",
    ):
        if not _contains_phrase(readme, phrase):
            raise AssertionError(f"README missing claim-boundary phrase: {phrase}")
    if "not by itself a claim that the current branch is human-playable" not in playable_cloud_proof:
        raise AssertionError("playable cloud proof doc must keep the human-playability claim boundary")
    if "docs/post-checkpoint-gaps.md" not in readme:
        raise AssertionError("README must point to the gap ledger")
    if "Still required before this is actually Doom-capable" not in readme:
        raise AssertionError("README must keep the Doom-capable claim boundary visible")
    if "tools/check_playability_gap_ledger.py" not in tests_readme:
        raise AssertionError("tests README must document the gap-ledger checker")
    if "make playability-host-check" not in tests_readme:
        raise AssertionError("tests README must document the host-only playability gate")
    if "make playability-host-check" not in playable_cloud_proof:
        raise AssertionError("playable cloud proof doc must prefer the host-only playability gate")
    host_target = re.search(
        r"^playability-host-check:.*?(?=^[a-zA-Z0-9_.-]+:|\Z)",
        makefile,
        re.MULTILINE | re.DOTALL,
    )
    if host_target is None:
        raise AssertionError("Makefile must expose playability-host-check")
    for phrase in (
        "ALLOW_LOCAL_VM=0",
        "DOOM_WAD=",
        "build-only",
        "test",
        "tools/check_repo_hygiene.py",
        "cloud-playability-check",
        "PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF=1",
        "persistence-image-check",
        "git diff --check",
    ):
        if phrase not in host_target.group(0):
            raise AssertionError(f"playability-host-check missing host-only gate phrase: {phrase}")
    for phrase in (
        "SUPPORT[UEFI] status=unclaimed",
        "SUPPORT[PCI_ENUMERATION] status=unclaimed",
        "SUPPORT[AHCI] status=unclaimed",
        "SUPPORT[USB] status=unclaimed",
        "SUPPORT[SMP] status=unclaimed",
        "SUPPORT[APIC] status=unclaimed",
        "SUPPORT[HPET] status=unclaimed",
        "SUPPORT[PHYSICAL_HARDWARE] status=unclaimed",
        "QEMU evidence alone can only claim the matching QEMU device model",
    ):
        if not _contains_phrase(hardware_support, phrase):
            raise AssertionError(f"hardware support matrix missing gap-ledger phrase: {phrase}")

    return gaps


def main() -> int:
    try:
        gaps = validate_ledger()
    except AssertionError as exc:
        print(f"playability gap ledger failed: {exc}", file=sys.stderr)
        return 1

    open_count = sum(1 for gap in gaps.values() if gap["status"] == "open")
    proven_count = sum(1 for gap in gaps.values() if gap["status"] == "proven")
    print(
        "playability gap ledger OK: "
        f"{open_count} open and {proven_count} proven Doom-capability gates tracked"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
