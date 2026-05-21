#!/usr/bin/env python3
"""Validate VM, exec, and preemption status evidence from cloud smoke runs."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from status_fields import (
    hex8_field,
    parse_status_fields,
    require_hex8_field,
    require_hex_tuple_field,
    require_status_field,
)

ROOT = Path(__file__).resolve().parents[1]

KERNEL_HIGHER_HALF_BASE = 0xC0000000
KERNEL_LOW_LINK_BASE = 0x00010000
KERNEL_ELF_MAX_BYTES = 0x00018000
KERNEL_STACK_LOW = 0x00060000
KERNEL_STACK_TOP = 0x00070000
PAGING_DIR_ADDR = 0x00090000
PMM_MANAGED_START = 0x00100000
PMM_MANAGED_END = 0x02000000
DOOM_USER_BASE = 0x01000000
DOOM_USER_HEAP_START = 0x01900000
DOOM_USER_STACK_BOTTOM = 0x01F00000
DOOM_USER_STACK_TOP = 0x02000000
PROBE_USER_BASE = 0x00E80000
PROBE_USER_END = 0x00F00000
PREEMPT_PROBE_MAGIC = 0x50524545
SCHEDULER_QUANTUM_TICKS = 5
SYS_EXEC_ARGV_SOURCE_USER = 2
PROCESS_SLOT_COUNT = 6
PROCESS_GENERIC_SLOT_COUNT = 2
WAIT_PROOF_EXIT_STATUS = 0x2A
ABI_PROBE_EXPECTED_FLAGS = 0xF
USER_PROBE_DUP_FLAG = 0x00020000
USER_PROBE_FCNTL_FLAG = 0x00040000
USER_KIND_DOOM = 2
USER_KIND_PREEMPT_PROBE = 3
USER_CODE_SEG = 0x1B
USER_DATA_SEG = 0x23
PROC_DOOM_PAGE_DIR_ADDR = 0x00082000
PROC_PREEMPT_PAGE_DIR_ADDR = 0x00083000
PROC_DOOM_KERNEL_STACK_TOP = 0x00073000
PROC_PREEMPT_PROBE_KERNEL_STACK_TOP = 0x00072000
PROCESS_KIND_EIP_RANGES = {
    USER_KIND_DOOM: ((DOOM_USER_BASE, DOOM_USER_STACK_TOP),),
    USER_KIND_PREEMPT_PROBE: ((PROBE_USER_BASE, PROBE_USER_END),),
}
PROCESS_KIND_PAGE_DIRS = {
    USER_KIND_DOOM: {PROC_DOOM_PAGE_DIR_ADDR},
    USER_KIND_PREEMPT_PROBE: {PROC_PREEMPT_PAGE_DIR_ADDR},
}
PROCESS_KIND_KERNEL_STACKS = {
    USER_KIND_DOOM: {PROC_DOOM_KERNEL_STACK_TOP},
    USER_KIND_PREEMPT_PROBE: {PROC_PREEMPT_PROBE_KERNEL_STACK_TOP},
}
PREEMPTION_REQUIRED_KIND_PAIR = {USER_KIND_DOOM, USER_KIND_PREEMPT_PROBE}


def parse_status(text: str) -> dict[str, str]:
    return parse_status_fields(text, error_type=AssertionError)


def _read(root: Path, relative: str) -> str:
    return (root / relative).read_text()


def _require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label} missing {needle!r}")


def _forbid(text: str, needle: str, label: str) -> None:
    if needle in text:
        raise AssertionError(f"{label} must not contain {needle!r}")


def _field(fields: dict[str, str], name: str) -> str:
    return require_status_field(fields, name)


def _exact(fields: dict[str, str], name: str, expected: str) -> None:
    actual = _field(fields, name)
    if actual != expected:
        raise AssertionError(f"{name}= must be {expected}, got {actual}")


def _hex(fields: dict[str, str], name: str) -> int:
    return require_hex8_field(fields, name)


def _hex_gt(fields: dict[str, str], name: str, minimum: int = 0) -> int:
    value = _hex(fields, name)
    if value <= minimum:
        raise AssertionError(f"{name}= must be greater than {minimum:#x}, got {value:#x}")
    return value


def _hex_tuple(fields: dict[str, str], name: str, count: int, sep: str) -> tuple[int, ...]:
    return require_hex_tuple_field(fields, name, count, sep)


def _field_or_missing(fields: dict[str, str], name: str) -> str:
    return fields.get(name, "<missing>")


def _preemption_context(fields: dict[str, str]) -> str:
    names = (
        "doomrun",
        "gameplay",
        "preempt",
        "pirq",
        "pattempt",
        "pskip",
        "puser",
        "pround",
        "pctx",
        "pmask",
        "pfrom",
        "pto",
        "pkind",
        "peip",
        "pcr3",
        "pkstk",
        "pframe",
        "pspin",
        "pself",
        "ticks",
        "dtick",
    )
    return " ".join(f"{name}={_field_or_missing(fields, name)}" for name in names)


def _preemption_not_eligible_hint(fields: dict[str, str]) -> str:
    if fields.get("pself") != "OK":
        return ""

    preempt = hex8_field(fields, "preempt")
    attempts = hex8_field(fields, "pattempt")
    user_ticks = hex8_field(fields, "puser")
    spin = hex8_field(fields, "pspin")
    doomrun = fields.get("doomrun")
    gameplay = fields.get("gameplay")

    if (
        preempt == 0
        and attempts == 0
        and user_ticks is not None
        and user_ticks < SCHEDULER_QUANTUM_TICKS
        and spin == PREEMPT_PROBE_MAGIC
        and doomrun not in (None, "RUN")
        and gameplay != "OK"
    ):
        return (
            "; live preemption was not eligible before this status snapshot: "
            f"doomrun={doomrun} gameplay={gameplay} puser={user_ticks:#x} "
            f"is below the scheduler quantum {SCHEDULER_QUANTUM_TICKS:#x}, and "
            "pspin is still the seeded preempt-probe magic. This usually means "
            "the generated-WAD OS smoke exited Doom before a Doom/preempt-probe "
            "timer quantum; prove preemption with a real-WAD gameplay status or "
            "a long-lived user workload."
        )

    return ""


def _raise_preemption_failure(fields: dict[str, str], message: str) -> None:
    raise AssertionError(
        f"{message}{_preemption_not_eligible_hint(fields)}; context: "
        f"{_preemption_context(fields)}"
    )


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


def _addr_matches_kind(kind: int, value: int) -> bool:
    return any(
        start <= value < end for start, end in PROCESS_KIND_EIP_RANGES.get(kind, ())
    )


def _preemption_expected_pids(fields: dict[str, str]) -> tuple[int, int]:
    doom_pid = _hex_gt(fields, "target")
    (
        _wait_attempts,
        _wait_reaps,
        _wait_failures,
        _wait_nohang,
        wait_seeded,
        wait_last_pid,
        _wait_last_status,
    ) = _hex_tuple(fields, "wait", 7, "/")
    if wait_seeded == 0:
        _raise_preemption_failure(
            fields, "wait= must prove the preempt-probe child was seeded before scheduler proof"
        )
    if wait_last_pid == 0 or wait_last_pid == 0xFFFFFFFF:
        _raise_preemption_failure(
            fields, "wait= must record the reaped preempt-probe child PID before scheduler proof"
        )
    return doom_pid, wait_last_pid


def validate_vm_mapping(fields: dict[str, str]) -> None:
    _exact(fields, "pg", "ON")
    _exact(fields, "pmm", "OK")
    _exact(fields, "vmm", "OK")
    validate_kernel_relocation_scaffold(fields)
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


def validate_kernel_relocation_scaffold(fields: dict[str, str]) -> None:
    status = _field(fields, "kreloc")
    if status == "OK":
        raise AssertionError("kreloc=OK is reserved for running-kernel non-identity execution")
    if status != "LOW":
        raise AssertionError(f"kreloc= must be LOW until the running kernel is relocated, got {status}")

    eip = _hex(fields, "kerneip")
    esp = _hex(fields, "kernesp")
    cr3 = _hex(fields, "kerncr3")
    virt = _hex(fields, "kernvirt")
    phys = _hex(fields, "kernphys")

    _in_range(
        eip,
        KERNEL_LOW_LINK_BASE,
        KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES,
        "kerneip",
    )
    _in_range(esp, KERNEL_STACK_LOW, KERNEL_STACK_TOP, "kernesp")
    if cr3 != PAGING_DIR_ADDR:
        raise AssertionError(f"kerncr3= must be the low kernel page directory, got {cr3:#x}")
    if virt != KERNEL_LOW_LINK_BASE:
        raise AssertionError(f"kernvirt= must be the low linked kernel entry, got {virt:#x}")
    if phys != virt:
        raise AssertionError("kernphys= must match kernvirt= while kreloc=LOW")
    if eip >= KERNEL_HIGHER_HALF_BASE or esp >= KERNEL_HIGHER_HALF_BASE:
        raise AssertionError("kreloc=LOW cannot report higher-half kernel EIP or ESP")


def validate_exec(fields: dict[str, str]) -> None:
    _exact(fields, "exec", "OK")
    _exact(fields, "path", "DOOM.ELF")
    _exact(fields, "uexec", "OK")
    _exact(fields, "upath", "USERPROB.ELF")
    _exact(fields, "abiexec", "OK")
    _exact(fields, "abipath", "ABIPROBE.ELF")
    _exact(fields, "abiprobe", "OK")
    _exact(fields, "doom", "OK")

    attempts, successes, failures, handoffs, scheduled, rollbacks = _hex_tuple(
        fields, "execsys", 6, "/"
    )
    if attempts < 2 or successes < 2 or handoffs < 2 or scheduled < 2:
        raise AssertionError("execsys= must prove ABI-probe and Doom syscall exec handoffs")
    if failures != 0 or rollbacks != 0:
        raise AssertionError("execsys= must prove no exec failures or rollbacks")
    if _hex(fields, "execerr") != 0:
        raise AssertionError("execerr= must be zero after a successful exec")
    if _hex(fields, "execres") != 0:
        raise AssertionError("execres= must be zero after a successful exec")

    target = _hex_gt(fields, "target")
    parent = _hex_gt(fields, "ppid")
    boot_user_pid = _hex_gt(fields, "upid")
    boot_user_entry = _hex_gt(fields, "uentry")
    boot_user_flags = _hex(fields, "uflags")
    _in_range(boot_user_entry, PROBE_USER_BASE, PROBE_USER_END, "uentry")
    if (boot_user_flags & USER_PROBE_DUP_FLAG) != USER_PROBE_DUP_FLAG:
        raise AssertionError("uflags= must prove the user probe dup shared-offset checks ran")
    if (boot_user_flags & USER_PROBE_FCNTL_FLAG) != USER_PROBE_FCNTL_FLAG:
        raise AssertionError("uflags= must prove the user probe fcntl FD_CLOEXEC checks ran")
    abi_pid = _hex_gt(fields, "abipid")
    abi_parent = _hex_gt(fields, "abippid")
    abi_entry = _hex_gt(fields, "abientry")
    abi_argc = _hex(fields, "abiargc")
    abi_argv_source = _hex(fields, "abiargvsrc")
    abi_flags = _hex(fields, "abiflags")
    _in_range(abi_entry, PROBE_USER_BASE, PROBE_USER_END, "abientry")
    if abi_parent != boot_user_pid:
        raise AssertionError("abippid= must match upid= to prove USERPROB execed ABIPROBE")
    if abi_argc != 1:
        raise AssertionError(f"abiargc= must prove the one-argument ABI probe exec stack, got {abi_argc:#x}")
    if abi_argv_source != SYS_EXEC_ARGV_SOURCE_USER:
        raise AssertionError("abiargvsrc= must be 2 to prove ABIPROBE used the user argv-vector copy path")
    if abi_flags != ABI_PROBE_EXPECTED_FLAGS:
        raise AssertionError(
            f"abiflags= must record ABI probe success flags {ABI_PROBE_EXPECTED_FLAGS:#x}"
        )
    if target == parent:
        raise AssertionError("target= and ppid= must prove exec entered a new process")
    if parent != abi_pid:
        raise AssertionError("ppid= must match abipid= to prove Doom was execed after ABIPROBE")

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

    process_slots, generic_slots, slot_reuses, generic_allocs, generic_failures = _hex_tuple(
        fields, "procpool", 5, "/"
    )
    if process_slots != PROCESS_SLOT_COUNT:
        raise AssertionError(
            f"procpool= must report {PROCESS_SLOT_COUNT} bounded process records"
        )
    if generic_slots != PROCESS_GENERIC_SLOT_COUNT:
        raise AssertionError(
            f"procpool= must report {PROCESS_GENERIC_SLOT_COUNT} generic exec slots"
        )
    if slot_reuses == 0:
        raise AssertionError("procpool= must prove exec reused a target process slot")
    if generic_allocs == 0:
        raise AssertionError("procpool= must prove a generic exec slot was allocated")
    if generic_failures != 0:
        raise AssertionError("procpool= must prove the bounded generic pool did not overflow")

    next_pid, last_reused_pid, last_generation = _hex_tuple(fields, "pidseq", 3, "/")
    if next_pid <= target:
        raise AssertionError("pidseq= must show the PID allocator advanced past the target")
    if last_reused_pid != target:
        raise AssertionError("pidseq= must tie the last reused slot to the exec target PID")
    if last_generation == 0:
        raise AssertionError("pidseq= must prove the target slot generation advanced")

    fd_handoffs, fd_inherited, fd_closed, _owner_closes = _hex_tuple(
        fields, "fdexec", 4, "/"
    )
    if fd_handoffs == 0:
        raise AssertionError("fdexec= must prove exec performed an fd ownership handoff")
    if fd_inherited == 0:
        raise AssertionError("fdexec= must prove at least one fd inherited across exec")
    if fd_closed == 0:
        raise AssertionError("fdexec= must prove a close-on-exec duplicated fd was closed")

    fd_dup, fd_dup2, fd_dup3, fd_shared, fd_cloexec = _hex_tuple(fields, "fdup", 5, "/")
    if fd_dup == 0 or fd_dup2 == 0 or fd_dup3 == 0:
        raise AssertionError("fdup= must prove dup, dup2, and dup3 were exercised")
    if fd_shared < 3:
        raise AssertionError("fdup= must prove duplicated descriptors shared open-file descriptions")
    if fd_cloexec == 0:
        raise AssertionError("fdup= must prove dup3 created an O_CLOEXEC descriptor")

    (
        wait_attempts,
        wait_reaps,
        wait_failures,
        _wait_nohang,
        wait_seeded,
        wait_last_pid,
        wait_last_status,
    ) = _hex_tuple(fields, "wait", 7, "/")
    if wait_seeded == 0:
        raise AssertionError("wait= must prove the bounded wait/reap child was seeded")
    if wait_attempts == 0 or wait_reaps == 0:
        raise AssertionError("wait= must prove a userland waitpid reaped an exited child")
    if wait_failures == 0:
        raise AssertionError("wait= must also prove classified waitpid failure paths")
    if wait_last_pid == 0 or wait_last_pid == 0xFFFFFFFF:
        raise AssertionError("wait= must record a real reaped child PID")
    if wait_last_status != WAIT_PROOF_EXIT_STATUS:
        raise AssertionError(
            f"wait= must record seeded child exit status {WAIT_PROOF_EXIT_STATUS:#x}"
        )

    (
        vm_teardowns,
        vm_pages_cleared,
        wait_vm_reaps,
        wait_vm_pages,
        wait_last_vm_pages,
    ) = _hex_tuple(fields, "vmreap", 5, "/")
    if vm_teardowns == 0:
        raise AssertionError("vmreap= must prove process VM teardown ran")
    if vm_pages_cleared == 0:
        raise AssertionError("vmreap= must prove process user pages were cleared")
    if wait_vm_reaps == 0:
        raise AssertionError("vmreap= must prove waitpid reaping invoked VM teardown")
    if wait_vm_pages == 0 or wait_last_vm_pages == 0:
        raise AssertionError("vmreap= must prove waitpid reclaimed child user pages")


def validate_preemption(fields: dict[str, str]) -> None:
    _exact(fields, "pself", "OK")

    preempt = _hex(fields, "preempt")
    if preempt == 0:
        _raise_preemption_failure(fields, "preempt= must be greater than 0x0")
    irq_switches = _hex(fields, "pirq")
    if irq_switches == 0:
        _raise_preemption_failure(fields, "pirq= must be greater than 0x0")
    if irq_switches != preempt:
        _raise_preemption_failure(
            fields, "pirq= must match preempt= to prove timer IRQ context switches"
        )
    if _hex(fields, "pattempt") == 0:
        _raise_preemption_failure(fields, "pattempt= must be greater than 0x0")
    user_irq_ticks = _hex(fields, "puser")
    if user_irq_ticks == 0:
        _raise_preemption_failure(fields, "puser= must be greater than 0x0")
    if user_irq_ticks < preempt:
        _raise_preemption_failure(fields, "puser= must cover every timer-driven preempt switch")
    if _hex(fields, "pround") == 0:
        _raise_preemption_failure(fields, "pround= must be greater than 0x0")
    context_switches = _hex(fields, "pctx")
    if context_switches == 0:
        _raise_preemption_failure(fields, "pctx= must be greater than 0x0")
    if context_switches < preempt:
        _raise_preemption_failure(fields, "pctx= must be at least the preempt switch count")
    pair_mask = _hex(fields, "pmask")
    if (pair_mask & 0x3) != 0x3:
        _raise_preemption_failure(
            fields, "pmask= must prove Doom/preempt-probe switches in both directions"
        )

    source_pid = _hex(fields, "pfrom")
    target_pid = _hex(fields, "pto")
    if source_pid == 0:
        _raise_preemption_failure(fields, "pfrom= must be greater than 0x0")
    if target_pid == 0:
        _raise_preemption_failure(fields, "pto= must be greater than 0x0")
    if source_pid == 0xFFFFFFFF or target_pid == 0xFFFFFFFF:
        _raise_preemption_failure(fields, "pfrom=/pto= must not be the no-process sentinel")
    if source_pid == target_pid:
        _raise_preemption_failure(fields, "pfrom= and pto= must prove a switch between processes")

    from_kind, to_kind = _hex_tuple(fields, "pkind", 2, ":")
    if {from_kind, to_kind} != PREEMPTION_REQUIRED_KIND_PAIR:
        _raise_preemption_failure(
            fields, "pkind= must prove switching between Doom and the preempt probe"
        )

    from_eip, to_eip = _hex_tuple(fields, "peip", 2, ":")
    if from_eip == 0 or to_eip == 0:
        _raise_preemption_failure(fields, "peip= must record nonzero source and target EIPs")
    if not _addr_matches_kind(from_kind, from_eip) or not _addr_matches_kind(
        to_kind, to_eip
    ):
        _raise_preemption_failure(
            fields,
            "peip= must match the recorded source and target process kinds",
        )

    from_cr3, to_cr3 = _hex_tuple(fields, "pcr3", 2, ":")
    if (
        from_cr3 not in PROCESS_KIND_PAGE_DIRS.get(from_kind, set())
        or to_cr3 not in PROCESS_KIND_PAGE_DIRS.get(to_kind, set())
    ):
        _raise_preemption_failure(
            fields,
            "pcr3= must match the recorded source and target process address spaces",
        )
    if from_cr3 == to_cr3:
        _raise_preemption_failure(fields, "pcr3= must contain distinct process page directories")

    from_kstack, to_kstack = _hex_tuple(fields, "pkstk", 2, ":")
    if (
        from_kstack not in PROCESS_KIND_KERNEL_STACKS.get(from_kind, set())
        or to_kstack not in PROCESS_KIND_KERNEL_STACKS.get(to_kind, set())
    ):
        _raise_preemption_failure(
            fields,
            "pkstk= must match the recorded source and target process kernel stacks",
        )
    if from_kstack == to_kstack:
        _raise_preemption_failure(fields, "pkstk= must contain distinct kernel stacks")

    doom_pid, preempt_probe_pid = _preemption_expected_pids(fields)
    expected_from_pid = doom_pid if from_kind == USER_KIND_DOOM else preempt_probe_pid
    expected_to_pid = doom_pid if to_kind == USER_KIND_DOOM else preempt_probe_pid
    if source_pid != expected_from_pid or target_pid != expected_to_pid:
        _raise_preemption_failure(
            fields,
            "pfrom=/pto= must match the exec target PID and reaped preempt-probe PID",
        )

    spin = _hex(fields, "pspin")
    if spin in (0, PREEMPT_PROBE_MAGIC):
        _raise_preemption_failure(fields, "pspin= must prove the Ring 3 preempt probe executed")

    frame_count, frame_eip, frame_cs, frame_esp, frame_ss = _hex_tuple(fields, "pframe", 5, "/")
    if frame_count != irq_switches:
        _raise_preemption_failure(
            fields, "pframe= rewrite count must match timer IRQ context switches"
        )
    if frame_eip != to_eip:
        _raise_preemption_failure(fields, "pframe= EIP must match the selected target context")
    if frame_cs != USER_CODE_SEG or (frame_cs & 0x3) != 0x3:
        _raise_preemption_failure(fields, "pframe= CS must be the Ring 3 user code selector")
    if frame_esp == 0:
        _raise_preemption_failure(fields, "pframe= ESP must record a nonzero Ring 3 stack")
    if frame_ss != USER_DATA_SEG or (frame_ss & 0x3) != 0x3:
        _raise_preemption_failure(fields, "pframe= SS must be the Ring 3 user data selector")


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
    real_wad_soak_workflow = _read(root, ".github/workflows/real-wad-soak.yml")
    os_workflow = _read(root, ".github/workflows/os-smoke.yml")
    makefile = _read(root, "Makefile")
    process_vm = _read(root, "docs/architecture.md")
    boot_vm = _read(root, "docs/architecture.md")
    gaps = _read(root, "docs/proof.md")
    playable = _read(root, "docs/proof.md")
    tests_readme = _read(root, "tests/README.md")
    cloud_artifacts = _read(root, "tools/check_cloud_playability_artifacts.py")

    _require(os_workflow, "Assert generated-WAD VM/process exec gates", "OS smoke workflow")
    _require(os_workflow, "python3 tools/check_vm_status_proof.py", "OS smoke workflow")
    _require(os_workflow, "--require-exec", "OS smoke workflow")
    _forbid(os_workflow, "--require-preempt", "generated-WAD OS smoke workflow")

    _require(real_wad_workflow, "Assert VM/process legitimacy gates", "real-WAD smoke workflow")

    for workflow, label in (
        (real_wad_workflow, "real-WAD smoke workflow"),
        (real_wad_soak_workflow, "real-WAD soak workflow"),
    ):
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
        _require(text, "kreloc=LOW", label)
        _require(text, "kerneip=", label)
        _require(text, "kernesp=", label)
        _require(text, "kerncr3=", label)
        _require(text, "kernvirt=", label)
        _require(text, "kernphys=", label)
        _require(text, "vmmhfree", label)
        _require(text, "uexec=OK", label)
        _require(text, "upath=USERPROB.ELF", label)
        _require(text, "abiexec=OK", label)
        _require(text, "abipath=ABIPROBE.ELF", label)
        _require(text, "abiprobe=OK", label)
        _require(text, "argvsrc=2", label)
        _require(text, "procpool=", label)
        _require(text, "fdexec=", label)
        _require(text, "fdup=", label)
        _require(text, "wait=", label)
        _require(text, "vmreap=", label)
        _require(text, "peip", label)
        _require(text, "pkind", label)
        _require(text, "pmask", label)
        _require(text, "pcr3", label)
        _require(text, "pkstk", label)

    for text, label in (
        (process_vm, "process VM doc"),
        (boot_vm, "boot loader VM doc"),
        (gaps, "gap ledger"),
    ):
        _require(text, "pframe", label)

    process_exec = _read(root, "docs/architecture.md")
    doom_runtime = _read(root, "docs/architecture.md")
    for text, label in (
        (process_vm, "process VM doc"),
        (process_exec, "process exec doc"),
    ):
        _require(text, "exec target PID", label)
        _require(text, "pfrom", label)
        _require(text, "pto", label)
        _require(text, "preempt", label)

    for text, label in (
        (process_exec, "process exec doc"),
        (doom_runtime, "Doom libc runtime doc"),
    ):
        _require(text, "fork", label)
        _require(text, "fd duplication", label)
        _require(text, "file-backed", label)
        _require(text, "signals", label)
        _require(text, "terminal", label)
        _require(text, "dynamic process", label)
        _require(text, "ENOSYS", label)
        _require(text, "ENOTTY", label)


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
