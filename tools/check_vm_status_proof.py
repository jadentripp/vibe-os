#!/usr/bin/env python3
"""Validate VM, exec, and preemption status evidence from cloud smoke runs."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")

KERNEL_HIGHER_HALF_BASE = 0xC0000000
PMM_MANAGED_START = 0x00100000
PMM_MANAGED_END = 0x02000000
DOOM_USER_BASE = 0x01000000
DOOM_USER_HEAP_START = 0x01900000
DOOM_USER_STACK_BOTTOM = 0x01F00000
DOOM_USER_STACK_TOP = 0x02000000
PROBE_USER_BASE = 0x00E80000
PROBE_USER_END = 0x00F00000
PREEMPT_PROBE_MAGIC = 0x50524545
SYS_EXEC_ARGV_SOURCE_USER = 2
USER_KIND_DOOM = 2
USER_KIND_PREEMPT_PROBE = 3
PROC_DOOM_PAGE_DIR_ADDR = 0x00082000
PROC_PREEMPT_PAGE_DIR_ADDR = 0x00083000
PROC_DOOM_KERNEL_STACK_TOP = 0x00073000
PROC_PREEMPT_PROBE_KERNEL_STACK_TOP = 0x00072000


def parse_status(text: str) -> dict[str, str]:
    return {match.group(1): match.group(2) for match in FIELD_PATTERN.finditer(text)}


def _read(root: Path, relative: str) -> str:
    return (root / relative).read_text()


def _require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label} missing {needle!r}")


def _field(fields: dict[str, str], name: str) -> str:
    try:
        return fields[name]
    except KeyError as exc:
        raise AssertionError(f"status missing {name}=") from exc


def _exact(fields: dict[str, str], name: str, expected: str) -> None:
    actual = _field(fields, name)
    if actual != expected:
        raise AssertionError(f"{name}= must be {expected}, got {actual}")


def _hex(fields: dict[str, str], name: str) -> int:
    value = _field(fields, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be an 8-digit hexadecimal value, got {value!r}")
    return int(value, 16)


def _hex_gt(fields: dict[str, str], name: str, minimum: int = 0) -> int:
    value = _hex(fields, name)
    if value <= minimum:
        raise AssertionError(f"{name}= must be greater than {minimum:#x}, got {value:#x}")
    return value


def _hex_tuple(fields: dict[str, str], name: str, count: int, sep: str) -> tuple[int, ...]:
    value = _field(fields, name)
    parts = value.split(sep)
    if len(parts) != count:
        raise AssertionError(f"{name}= must contain {count} hex fields separated by {sep!r}")
    parsed: list[int] = []
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            raise AssertionError(f"{name}= contains non-hex component {part!r}")
        parsed.append(int(part, 16))
    return tuple(parsed)


def _page_aligned(value: int, name: str) -> None:
    if value & 0xFFF:
        raise AssertionError(f"{name}= must be page-aligned, got {value:#x}")


def _managed_frame(value: int, name: str) -> None:
    _page_aligned(value, name)
    if not (PMM_MANAGED_START <= value < PMM_MANAGED_END):
        raise AssertionError(
            f"{name}= must be a PMM-managed frame in "
            f"{PMM_MANAGED_START:#x}..{PMM_MANAGED_END:#x}, got {value:#x}"
        )


def _in_range(value: int, start: int, end: int, name: str) -> None:
    if not (start <= value < end):
        raise AssertionError(f"{name}= {value:#x} outside expected range {start:#x}..{end:#x}")


def _is_doom_addr(value: int) -> bool:
    return DOOM_USER_BASE <= value < DOOM_USER_STACK_TOP


def _is_probe_addr(value: int) -> bool:
    return PROBE_USER_BASE <= value < PROBE_USER_END


def validate_vm_mapping(fields: dict[str, str]) -> None:
    _exact(fields, "pg", "ON")
    _exact(fields, "pmm", "OK")
    _exact(fields, "vmm", "OK")
    _exact(fields, "vmmhi", "OK")

    vaddr = _hex(fields, "vmmhva")
    if vaddr != KERNEL_HIGHER_HALF_BASE:
        raise AssertionError(f"vmmhva= must be C0000000, got {vaddr:08X}")

    phys = _hex(fields, "vmmhpa")
    table = _hex(fields, "vmmhpt")
    reclaimed = _hex(fields, "vmmhfree")

    _managed_frame(phys, "vmmhpa")
    _managed_frame(table, "vmmhpt")
    _managed_frame(reclaimed, "vmmhfree")
    if phys == vaddr:
        raise AssertionError("vmmhpa= must prove a non-identity high mapping")
    if phys == table:
        raise AssertionError("vmmhpa= and vmmhpt= must describe different frames")
    if reclaimed != table:
        raise AssertionError("vmmhfree= must match vmmhpt= to prove page-table reclaim")


def validate_exec(fields: dict[str, str]) -> None:
    _exact(fields, "exec", "OK")
    _exact(fields, "path", "DOOM.ELF")
    _exact(fields, "doom", "OK")

    attempts, successes, failures, handoffs, scheduled, rollbacks = _hex_tuple(
        fields, "execsys", 6, "/"
    )
    if attempts == 0 or successes == 0 or handoffs == 0 or scheduled == 0:
        raise AssertionError("execsys= must prove a successful syscall exec handoff")
    if failures != 0 or rollbacks != 0:
        raise AssertionError("execsys= must prove no exec failures or rollbacks")
    if _hex(fields, "execerr") != 0:
        raise AssertionError("execerr= must be zero after a successful exec")
    if _hex(fields, "execres") != 0:
        raise AssertionError("execres= must be zero after a successful exec")

    target = _hex_gt(fields, "target")
    parent = _hex_gt(fields, "ppid")
    if target == parent:
        raise AssertionError("target= and ppid= must prove exec entered a new process")

    entry = _hex_gt(fields, "entry")
    stack = _hex_gt(fields, "stack")
    argc = _hex(fields, "argc")
    argv = _hex_gt(fields, "argv")
    envp = _hex_gt(fields, "envp")
    argv0 = _hex_gt(fields, "argv0")
    envp0 = _hex(fields, "envp0")
    argv_source = _hex(fields, "argvsrc")

    _in_range(entry, DOOM_USER_BASE, DOOM_USER_HEAP_START, "entry")
    _in_range(stack, DOOM_USER_STACK_BOTTOM, DOOM_USER_STACK_TOP, "stack")
    _in_range(argv, DOOM_USER_STACK_BOTTOM, DOOM_USER_STACK_TOP, "argv")
    _in_range(envp, DOOM_USER_STACK_BOTTOM, DOOM_USER_STACK_TOP, "envp")
    _in_range(argv0, DOOM_USER_STACK_BOTTOM, DOOM_USER_STACK_TOP, "argv0")
    if argc != 1:
        raise AssertionError(f"argc= must prove the one-argument Doom exec stack, got {argc:#x}")
    if envp0 != 0:
        raise AssertionError("envp0= must prove an empty envp terminator")
    if argv_source != SYS_EXEC_ARGV_SOURCE_USER:
        raise AssertionError("argvsrc= must be 2 to prove the user argv-vector copy path")


def validate_preemption(fields: dict[str, str]) -> None:
    _exact(fields, "pself", "OK")

    preempt = _hex_gt(fields, "preempt")
    irq_switches = _hex_gt(fields, "pirq")
    if irq_switches != preempt:
        raise AssertionError("pirq= must match preempt= to prove timer IRQ context switches")
    _hex_gt(fields, "pattempt")
    _hex_gt(fields, "puser")
    _hex_gt(fields, "pround")
    context_switches = _hex_gt(fields, "pctx")
    if context_switches < preempt:
        raise AssertionError("pctx= must be at least the preempt switch count")
    pair_mask = _hex(fields, "pmask")
    if (pair_mask & 0x3) != 0x3:
        raise AssertionError("pmask= must prove Doom/preempt-probe switches in both directions")

    source_pid = _hex_gt(fields, "pfrom")
    target_pid = _hex_gt(fields, "pto")
    if source_pid == 0xFFFFFFFF or target_pid == 0xFFFFFFFF:
        raise AssertionError("pfrom=/pto= must not be the no-process sentinel")
    if source_pid == target_pid:
        raise AssertionError("pfrom= and pto= must prove a switch between processes")

    from_kind, to_kind = _hex_tuple(fields, "pkind", 2, ":")
    if {from_kind, to_kind} != {USER_KIND_DOOM, USER_KIND_PREEMPT_PROBE}:
        raise AssertionError("pkind= must prove switching between Doom and the preempt probe")

    from_eip, to_eip = _hex_tuple(fields, "peip", 2, ":")
    if from_eip == 0 or to_eip == 0:
        raise AssertionError("peip= must record nonzero source and target EIPs")
    if not (
        (_is_doom_addr(from_eip) and _is_probe_addr(to_eip))
        or (_is_probe_addr(from_eip) and _is_doom_addr(to_eip))
    ):
        raise AssertionError("peip= must prove switching between Doom and the preempt probe")

    from_cr3, to_cr3 = _hex_tuple(fields, "pcr3", 2, ":")
    if {from_cr3, to_cr3} != {PROC_DOOM_PAGE_DIR_ADDR, PROC_PREEMPT_PAGE_DIR_ADDR}:
        raise AssertionError("pcr3= must prove switching between Doom and preempt probe address spaces")
    if from_cr3 == to_cr3:
        raise AssertionError("pcr3= must contain distinct process page directories")

    from_kstack, to_kstack = _hex_tuple(fields, "pkstk", 2, ":")
    if {from_kstack, to_kstack} != {
        PROC_DOOM_KERNEL_STACK_TOP,
        PROC_PREEMPT_PROBE_KERNEL_STACK_TOP,
    }:
        raise AssertionError("pkstk= must prove switching TSS kernel stacks for Doom and preempt probe")
    if from_kstack == to_kstack:
        raise AssertionError("pkstk= must contain distinct kernel stacks")

    spin = _hex(fields, "pspin")
    if spin in (0, PREEMPT_PROBE_MAGIC):
        raise AssertionError("pspin= must prove the Ring 3 preempt probe executed")


def validate_status(
    text: str,
    *,
    require_exec: bool = False,
    require_preempt: bool = False,
) -> None:
    fields = parse_status(text)
    validate_vm_mapping(fields)
    if require_exec:
        validate_exec(fields)
    if require_preempt:
        validate_preemption(fields)


def validate_repo_contract(root: Path = ROOT) -> None:
    real_wad_workflow = _read(root, ".github/workflows/real-wad-smoke.yml")
    os_workflow = _read(root, ".github/workflows/os-smoke.yml")
    makefile = _read(root, "Makefile")
    process_vm = _read(root, "docs/process-vm.md")
    boot_vm = _read(root, "docs/boot-loader-vm.md")
    gaps = _read(root, "docs/post-checkpoint-gaps.md")
    playable = _read(root, "docs/playable-cloud-proof.md")
    tests_readme = _read(root, "tests/README.md")
    cloud_artifacts = _read(root, "tools/check_cloud_playability_artifacts.py")

    for workflow, label in (
        (real_wad_workflow, "real-WAD workflow"),
        (os_workflow, "OS smoke workflow"),
    ):
        _require(workflow, "Assert VM/process legitimacy gates", label)
        _require(workflow, "python3 tools/check_vm_status_proof.py", label)
        _require(workflow, "--require-exec", label)
        _require(workflow, "--require-preempt", label)

    _require(makefile, "vm-status-proof-check:", "Makefile")
    _require(makefile, "tools/check_vm_status_proof.py --repo-contract", "Makefile")
    _require(makefile, "vm-status-proof-check", "Makefile cloud gate")
    _require(cloud_artifacts, "import check_vm_status_proof", "cloud artifact checker")
    _require(cloud_artifacts, "check_vm_status_proof.validate_status", "cloud artifact checker")

    for text, label in (
        (process_vm, "process VM doc"),
        (boot_vm, "boot loader VM doc"),
        (gaps, "gap ledger"),
        (playable, "playable proof doc"),
        (tests_readme, "tests README"),
    ):
        _require(text, "tools/check_vm_status_proof.py", label)
        _require(text, "vmmhfree", label)
        _require(text, "argvsrc=2", label)
        _require(text, "peip", label)
        _require(text, "pkind", label)
        _require(text, "pmask", label)
        _require(text, "pcr3", label)
        _require(text, "pkstk", label)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate VM/process/preemption evidence in cloud status text."
    )
    parser.add_argument("status", nargs="*", type=Path, help="status.txt files to validate")
    parser.add_argument("--require-exec", action="store_true", help="require Doom SYS_EXEC proof")
    parser.add_argument(
        "--require-preempt",
        action="store_true",
        help="require timer IRQ context-switch proof",
    )
    parser.add_argument(
        "--repo-contract",
        action="store_true",
        help="validate workflow/docs/checker wiring instead of status files",
    )
    args = parser.parse_args(argv)

    try:
        if args.repo_contract:
            validate_repo_contract()
            print("VM status proof contract OK")
            return 0
        if not args.status:
            raise AssertionError("at least one status file is required")
        for path in args.status:
            validate_status(
                path.read_text(),
                require_exec=args.require_exec,
                require_preempt=args.require_preempt,
            )
    except AssertionError as exc:
        print(f"VM status proof failed: {exc}", file=sys.stderr)
        return 1

    print(f"VM status proof OK: validated {len(args.status)} status file(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
