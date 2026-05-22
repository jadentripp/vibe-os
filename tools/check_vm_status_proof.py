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
KERNEL_HIGH_LINK_BASE = KERNEL_HIGHER_HALF_BASE + KERNEL_LOW_LINK_BASE
KERNEL_ELF_MAX_BYTES = 0x00020000
PAGE_SIZE = 0x1000
KERNEL_STACK_LOW = 0x00060000
KERNEL_STACK_TOP = 0x00070000
KERNEL_HIGH_STACK_LOW = KERNEL_HIGHER_HALF_BASE + KERNEL_STACK_LOW
KERNEL_HIGH_STACK_TOP = KERNEL_HIGHER_HALF_BASE + KERNEL_STACK_TOP
KERNEL_PERSISTENT_ALIAS_PAGES = KERNEL_ELF_MAX_BYTES // PAGE_SIZE
KERNEL_STACK_ALIAS_PAGES = (KERNEL_STACK_TOP - KERNEL_STACK_LOW) // PAGE_SIZE
KERNEL_PERSISTENT_DIR_MASK = 0x3F
KERNEL_HIGH_EXEC_STACK_MAGIC = 0x48485354
KERNEL_PERSISTENT_EXEC_STACK_MAGIC = 0x4B504558
KERNEL_RELOCATION_LIVE_MAGIC = 0x4B524C56
KERNEL_HIGH_MAINLINE_MIN_CHECKPOINTS = 2
PAGING_DIR_ADDR = 0x00090000
PROC_PROBE_PAGE_DIR_ADDR = 0x00080000
PROC_DOOM_PAGE_DIR_ADDR = 0x00082000
PROC_PREEMPT_PAGE_DIR_ADDR = 0x00083000
PROC_GENERIC0_PAGE_DIR_ADDR = 0x00089000
PROC_GENERIC1_PAGE_DIR_ADDR = 0x0008B000
FIXED_BOOTSTRAP_PAGE_DIRS = {
    PAGING_DIR_ADDR,
    PROC_PROBE_PAGE_DIR_ADDR,
    PROC_DOOM_PAGE_DIR_ADDR,
    PROC_PREEMPT_PAGE_DIR_ADDR,
    PROC_GENERIC0_PAGE_DIR_ADDR,
    PROC_GENERIC1_PAGE_DIR_ADDR,
}
PTE_PRESENT = 0x001
PTE_WRITE = 0x002
PTE_KERNEL_FLAGS = PTE_PRESENT | PTE_WRITE
LOW_IDENTITY_PRESENT = 0x00000001
LOW_IDENTITY_TRAPPED = 0x00000002
MISSING_TRANSLATION = 0xFFFFFFFF
PMM_MANAGED_START = 0x00100000
PMM_MANAGED_END = 0x02000000
E820_MAP_ADDR = 0x00007100
E820_ENTRY_SIZE = 24
E820_MAX_ENTRIES = 32
E820_MAP_END = E820_MAP_ADDR + (E820_ENTRY_SIZE * E820_MAX_ENTRIES)
DOOM_USER_BASE = 0x01000000
DOOM_USER_HEAP_START = 0x01900000
DOOM_USER_STACK_BOTTOM = 0x01F00000
DOOM_USER_STACK_TOP = 0x02000000
PROBE_USER_BASE = 0x00E80000
PROBE_USER_END = 0x00F00000
PREEMPT_PROBE_MAGIC = 0x50524545
SCHEDULER_QUANTUM_TICKS = 5
SANITIZED_USER_EFLAGS = 0x00000202
SYS_EXEC_ARGV_SOURCE_USER = 2
SYS_EXEC_RESOLVE_TABLE = 1
SYS_EXEC_RESOLVE_GENERIC_ROOT83 = 2
PROCESS_SLOT_COUNT = 6
PROCESS_GENERIC_SLOT_COUNT = 2
WAIT_PROOF_EXIT_STATUS = 0x2A
PROC_BLOCK_WAITPID = 2
ABI_PROBE_EXPECTED_FLAGS = 0x3FF
USER_PROBE_DUP_FLAG = 0x00020000
USER_PROBE_FCNTL_FLAG = 0x00040000
KERNEL_ENTRY = 0x00010000
BOOT_LOADER_FLAG_STAGE2_REACHED = 0x00000001
BOOT_LOADER_FLAG_EDD_PRESENT = 0x00000002
BOOT_LOADER_FLAG_KERNEL_EDD_READ = 0x00000004
BOOT_LOADER_FLAG_KERNEL_CHS_READ = 0x00000008
BOOT_LOADER_FLAG_E820 = 0x00000010
BOOT_LOADER_FLAG_VBE_LFB = 0x00000020
BOOT_LOADER_FLAG_MODE13 = 0x00000040
BOOT_LOADER_FLAG_A20 = 0x00000080
BOOT_LOADER_FLAG_GDT_LOADED = 0x00000100
BOOT_LOADER_FLAG_PROTECTED_MODE = 0x00000200
BOOT_LOADER_FLAG_ELF_VALID = 0x00000400
BOOT_LOADER_FLAG_ENTRY_COVERED = 0x00000800
BOOT_LOADER_FLAG_E820_BOUNDED = 0x00001000
BOOT_LOADER_FLAG_VIDEO_VALID = 0x00002000
BOOT_LOADER_FLAG_ELF_PHDR_VALID = 0x00004000
BOOT_LOADER_FLAG_CHS_GEOMETRY = 0x00008000
BIOS_BOOT_REQUIRED_FLAGS = (
    BOOT_LOADER_FLAG_STAGE2_REACHED
    | BOOT_LOADER_FLAG_E820
    | BOOT_LOADER_FLAG_E820_BOUNDED
    | BOOT_LOADER_FLAG_VIDEO_VALID
    | BOOT_LOADER_FLAG_A20
    | BOOT_LOADER_FLAG_GDT_LOADED
    | BOOT_LOADER_FLAG_PROTECTED_MODE
    | BOOT_LOADER_FLAG_ELF_VALID
    | BOOT_LOADER_FLAG_ENTRY_COVERED
    | BOOT_LOADER_FLAG_ELF_PHDR_VALID
)
BIOS_BOOT_DISK_FLAGS = BOOT_LOADER_FLAG_KERNEL_EDD_READ | BOOT_LOADER_FLAG_KERNEL_CHS_READ
BIOS_BOOT_VIDEO_FLAGS = BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_MODE13
BIOS_BOOT_EXPECTED_STAGE2_SECTORS = 16
BIOS_BOOT_EXPECTED_KERNEL_SECTORS = 320
BOOT_LOADER_STATUS_OK = 2
USER_KIND_DOOM = 2
USER_KIND_PREEMPT_PROBE = 3
USER_KIND_GENERIC = 4
USER_CODE_SEG = 0x1B
USER_DATA_SEG = 0x23
FAULT_SOURCE_NONE = "NONE"
FAULT_SOURCE_EXPECTED = "EXPECT"
FAULT_SOURCE_USER = "USER"
FAULT_SOURCE_DOOM = "DOOM"
FAULT_SOURCE_KERNEL = "KERNEL"
FAULT_MODE_NONE = "NONE"
FAULT_MODE_USER = "USER"
FAULT_MODE_KERNEL = "KERNEL"
PF_ACCESS_NONE = 0
PF_ACCESS_READ = 1
PF_ACCESS_WRITE = 2
PF_ACCESS_INSTRUCTION_FETCH = 3
PF_REASON_NONE = 0x00000000
PF_REASON_NOT_PRESENT = 0x00000001
PF_REASON_PROTECTION = 0x00000002
PF_REASON_RESERVED_BIT = 0x00000004
PF_REASON_INSTRUCTION_FETCH = 0x00000008
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
        "psegs",
        "peflags",
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


def _page_fault_access(error: int) -> int:
    if error & 0x10:
        return PF_ACCESS_INSTRUCTION_FETCH
    if error & 0x02:
        return PF_ACCESS_WRITE
    return PF_ACCESS_READ


def _page_fault_reason(error: int) -> int:
    reason = PF_REASON_PROTECTION if error & 0x01 else PF_REASON_NOT_PRESENT
    if error & 0x08:
        reason |= PF_REASON_RESERVED_BIT
    if error & 0x10:
        reason |= PF_REASON_INSTRUCTION_FETCH
    return reason


def _fault_mode_id(mode: str) -> int:
    if mode == FAULT_MODE_USER:
        return 1
    if mode == FAULT_MODE_KERNEL:
        return 2
    return 0


def _page_aligned(value: int, name: str) -> None:
    if value & 0xFFF:
        raise AssertionError(f"{name}= must be page-aligned, got {value:#x}")


def _managed_frame(value: int, name: str) -> None:
    _page_aligned(value, name)
    if not (PMM_MANAGED_START <= value < PMM_MANAGED_END):
        frame_kind = "dedicated PMM-managed" if name == "kreldirx directory" else "PMM-managed"
        raise AssertionError(
            f"{name}= must be a {frame_kind} frame in "
            f"{PMM_MANAGED_START:#x}..{PMM_MANAGED_END:#x}, got {value:#x}"
        )


def validate_pmm_boot_proof(fields: dict[str, str]) -> None:
    _exact(fields, "e820", "OK")

    entry_count = _hex_gt(fields, "e820cnt")
    entry_size = _hex(fields, "e820sz")
    if not (20 <= entry_size <= 24):
        raise AssertionError(f"e820sz= must be an E820 entry size in 20..24 bytes, got {entry_size:#x}")

    map_ptr, map_end, map_status = _hex_tuple(fields, "e820map", 3, "/")
    if map_status != 1:
        raise AssertionError("e820map= must prove the kernel validated the firmware map handoff bounds")
    if map_ptr != E820_MAP_ADDR:
        raise AssertionError(f"e820map= must point at the Stage 2 E820 buffer {E820_MAP_ADDR:#x}")
    expected_map_end = map_ptr + entry_count * entry_size
    if map_end != expected_map_end:
        raise AssertionError("e820map= end must match e820cnt= times e820sz=")
    if map_end > E820_MAP_END:
        raise AssertionError("e820map= must stay inside the bounded Stage 2 E820 buffer")

    usable_entries, usable_pages = _hex_tuple(fields, "e820use", 2, "/")
    if usable_entries == 0 or usable_entries > entry_count:
        raise AssertionError("e820use= must report at least one usable entry from the E820 map")
    if usable_pages == 0:
        raise AssertionError("e820use= must report nonzero usable PMM pages")

    e820_free = _hex(fields, "e820free")
    if e820_free != usable_pages:
        raise AssertionError("e820free= must match the usable page count in e820use=")

    _hex_tuple(fields, "e820res", 3, "/")

    managed_start, managed_end = _hex_tuple(fields, "pmmwin", 2, "/")
    if managed_start != PMM_MANAGED_START:
        raise AssertionError(f"pmmwin= must start at {PMM_MANAGED_START:#x}, got {managed_start:#x}")
    _page_aligned(managed_end, "pmmwin end")
    if not (PMM_MANAGED_START < managed_end <= PMM_MANAGED_END):
        raise AssertionError(
            f"pmmwin= end must be inside {PMM_MANAGED_START:#x}..{PMM_MANAGED_END:#x}, got {managed_end:#x}"
        )

    frame_map, frame_map_pages = _hex_tuple(fields, "pmmmap", 2, "/")
    if frame_map != 0x00099000:
        raise AssertionError(f"pmmmap= must point at the low PMM frame bitmap, got {frame_map:#x}")
    if frame_map_pages != (PMM_MANAGED_END - PMM_MANAGED_START) // PAGE_SIZE:
        raise AssertionError("pmmmap= must expose the full managed bitmap ceiling")

    low_guard_pages, reserved_pages = _hex_tuple(fields, "pmmguard", 2, "/")
    if low_guard_pages != PMM_MANAGED_START // PAGE_SIZE:
        raise AssertionError("pmmguard= must account for the low-memory guard below PMM_MANAGED_START")
    if reserved_pages == 0:
        raise AssertionError("pmmguard= must report reserved kernel/user/MMIO/DMA pages")

    pmm_free, pmm_used, pmm_total = _hex_tuple(fields, "pmmuse", 3, "/")
    expected_total = (managed_end - managed_start) // PAGE_SIZE
    if pmm_total != expected_total:
        raise AssertionError("pmmuse= total must match the E820-clipped managed window")
    if pmm_free + pmm_used != pmm_total:
        raise AssertionError("pmmuse= free + used must equal total managed pages")
    if pmm_free == 0 or pmm_used == 0:
        raise AssertionError("pmmuse= must prove both free and reserved/used PMM pages")
    if pmm_free > usable_pages:
        raise AssertionError("pmmuse= free pages cannot exceed the E820 usable page count")

    scan_free, scan_used, scan_reserved, scan_status = _hex_tuple(fields, "pmmtype", 4, "/")
    if scan_status != 1:
        raise AssertionError("pmmtype= must prove the frame bitmap was rescanned successfully")
    if scan_free != pmm_free:
        raise AssertionError("pmmtype= free count must match pmmuse= free pages")
    if scan_used + scan_reserved != pmm_used:
        raise AssertionError("pmmtype= used plus reserved counts must match pmmuse= used pages")
    if scan_free + scan_used + scan_reserved != pmm_total:
        raise AssertionError("pmmtype= bitmap states must cover every managed frame")
    if scan_reserved == 0:
        raise AssertionError("pmmtype= must expose reserved frame-map entries, not only counters")
    _exact(fields, "pmmchk", "OK")

    pmm_alloc, free_before, free_after = _hex_tuple(fields, "pmmalloc", 3, "/")
    _managed_frame(pmm_alloc, "pmmalloc allocation")
    if not (free_before > 0 and free_after > 0):
        raise AssertionError("pmmalloc= must record nonzero allocator free counts")
    if free_before != free_after:
        raise AssertionError("pmmalloc= must prove the PMM self-test returned its allocated page")

    deny_low, deny_kernel, deny_user, deny_dma, deny_mmio = _hex_tuple(fields, "pmmdeny", 5, "/")
    if (deny_low, deny_kernel, deny_user, deny_dma) != (1, 1, 1, 1):
        raise AssertionError("pmmdeny= must prove low guard, kernel, user, and DMA reserved pages are not allocatable")

    dma_base, dma_end, dma_pages = _hex_tuple(fields, "pmmdma", 3, "/")
    _page_aligned(dma_base, "pmmdma base")
    _page_aligned(dma_end, "pmmdma end")
    if dma_pages == 0 or dma_end <= dma_base:
        raise AssertionError("pmmdma= must expose a nonempty DMA-safe reserved window")
    if (dma_end - dma_base) // PAGE_SIZE != dma_pages:
        raise AssertionError("pmmdma= pages must match the DMA window span")

    mmio_base, mmio_pages = _hex_tuple(fields, "pmmio", 2, "/")
    if mmio_pages:
        _page_aligned(mmio_base, "pmmio base")
        if mmio_base == 0:
            raise AssertionError("pmmio= must include a nonzero MMIO base when pages are nonzero")
        if deny_mmio != 1:
            raise AssertionError("pmmdeny= must prove framebuffer/MMIO pages are reserved when pmmio= is nonempty")
    elif deny_mmio != 0:
        raise AssertionError("pmmdeny= MMIO slot must be zero when no framebuffer/MMIO pages are tracked")


def validate_firmware_boot_handoff(fields: dict[str, str]) -> None:
    if fields.get("uefi") == "OK":
        return

    _exact(fields, "biosboot", "OK")
    flags = _hex(fields, "biosflags")
    entry, load_count = _hex_tuple(fields, "biosentry", 2, "/")
    stage2_sectors, kernel_sectors, loader_status = _hex_tuple(fields, "biosspan", 3, "/")

    if flags & BIOS_BOOT_REQUIRED_FLAGS != BIOS_BOOT_REQUIRED_FLAGS:
        raise AssertionError("biosflags= must prove Stage 2, bounded E820, validated video, A20, GDT, protected mode, ELF PHDR validation, and entry coverage")
    if flags & BIOS_BOOT_DISK_FLAGS == 0:
        raise AssertionError("biosflags= must prove the kernel was read through the BIOS disk path")
    if flags & BOOT_LOADER_FLAG_KERNEL_EDD_READ and not (flags & BOOT_LOADER_FLAG_EDD_PRESENT):
        raise AssertionError("biosflags= cannot claim an EDD kernel read without EDD-present proof")
    if flags & BOOT_LOADER_FLAG_KERNEL_CHS_READ and not (flags & BOOT_LOADER_FLAG_CHS_GEOMETRY):
        raise AssertionError("biosflags= cannot claim a CHS kernel read without CHS geometry proof")
    video_flags = flags & BIOS_BOOT_VIDEO_FLAGS
    if video_flags not in (BOOT_LOADER_FLAG_VBE_LFB, BOOT_LOADER_FLAG_MODE13):
        raise AssertionError("biosflags= must prove exactly one BIOS video handoff")
    if entry != KERNEL_ENTRY:
        raise AssertionError(f"biosentry= must match the linked kernel entry {KERNEL_ENTRY:#x}")
    if load_count == 0:
        raise AssertionError("biosentry= must report at least one loaded ELF segment")
    if stage2_sectors != BIOS_BOOT_EXPECTED_STAGE2_SECTORS:
        raise AssertionError(
            f"biosspan= must report Stage 2 span {BIOS_BOOT_EXPECTED_STAGE2_SECTORS} sectors"
        )
    if kernel_sectors != BIOS_BOOT_EXPECTED_KERNEL_SECTORS:
        raise AssertionError(
            f"biosspan= must report kernel staging span {BIOS_BOOT_EXPECTED_KERNEL_SECTORS} sectors"
        )
    if loader_status != BOOT_LOADER_STATUS_OK:
        raise AssertionError("biosspan= must report final Stage 2 loader status OK")


def validate_kernel_clock_proof(fields: dict[str, str]) -> None:
    _exact(fields, "clocksrc", "PIT")
    ticks = _hex_gt(fields, "ticks")
    dtick = _hex(fields, "dtick")
    clock_irq = _hex(fields, "clockirq")
    clock_tick = _hex(fields, "clocktick")
    clock_hz = _hex(fields, "clockhz")
    clock_ms = _hex(fields, "clockms")
    clock_doom = _hex(fields, "clockdoom")
    clock_scheduler_ticks = _hex(fields, "clocksch")

    if clock_hz != 100:
        raise AssertionError(f"clockhz= must prove the generic PIT clock is 100 Hz, got {clock_hz:#x}")
    if clock_tick != ticks:
        raise AssertionError("clocktick= must match legacy ticks= to prove one kernel-owned clock counter")
    if clock_irq != ticks:
        raise AssertionError("clockirq= must match ticks= to prove PIT IRQ-owned accounting")
    if clock_ms != ticks * 10:
        raise AssertionError("clockms= must equal ticks * 10 milliseconds for the 100 Hz clock")
    if dtick != (ticks * 35) // 100:
        raise AssertionError("dtick= must derive Doom 35 Hz time from the generic 100 Hz clock")
    if clock_doom != dtick:
        raise AssertionError("clockdoom= must match dtick= as the generic-clock-derived Doom tick")
    if clock_scheduler_ticks != clock_irq:
        raise AssertionError("clocksch= must match clockirq= to prove scheduler_tick ran from the timer IRQ path")


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
        _wait_last_pid,
        _wait_last_status,
        _wait_blocks,
        _wait_block_wakeups,
    ) = _hex_tuple(fields, "wait", 9, "/")
    if wait_seeded == 0:
        _raise_preemption_failure(
            fields, "wait= must prove the preempt-probe child was seeded before scheduler proof"
        )
    wait_seed_pid = _hex(fields, "waitseed")
    if wait_seed_pid == 0 or wait_seed_pid == 0xFFFFFFFF:
        _raise_preemption_failure(
            fields, "waitseed= must record the reaped preempt-probe child PID before scheduler proof"
        )
    return doom_pid, wait_seed_pid


def validate_vm_mapping(fields: dict[str, str]) -> None:
    _exact(fields, "pg", "ON")
    _exact(fields, "pmm", "OK")
    _exact(fields, "vmm", "OK")
    user_guard_pages = _hex(fields, "uguard")
    if user_guard_pages < 0x0F:
        raise AssertionError("uguard= must account for explicit code, heap, stack, and Doom guard pages")
    guard_probe_count, guard_probe_failures = _hex_tuple(fields, "vmmguard", 2, "/")
    if guard_probe_count != user_guard_pages:
        raise AssertionError("vmmguard= must probe every explicit user guard page")
    if guard_probe_failures != 0:
        raise AssertionError("vmmguard= must prove guard pages are not present in user page tables")
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
    step = _field(fields, "krelocstep")
    eip = _hex(fields, "kerneip")
    esp = _hex(fields, "kernesp")
    cr3 = _hex(fields, "kerncr3")
    virt = _hex(fields, "kernvirt")
    phys = _hex(fields, "kernphys")

    if status == "LOW":
        if step not in {"HIEXEC_TMP", "KPEXEC_PERSIST"}:
            raise AssertionError(
                f"krelocstep= must be HIEXEC_TMP or KPEXEC_PERSIST while kreloc=LOW, got {step}"
            )
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
        if fields.get("khmain") == "OK":
            raise AssertionError("khmain=OK cannot be claimed while kreloc=LOW")
        validate_low_identity_probe(fields, relocated=False)
        validate_kernel_high_alias(fields, expected_vaddr=KERNEL_HIGHER_HALF_BASE + virt, expected_phys=phys)
        validate_kernel_high_exec(fields, relocated=False)
        validate_kernel_persistent_alias(
            fields,
            expected_vaddr=KERNEL_HIGHER_HALF_BASE + virt,
            expected_phys=phys,
            expected_cr3=cr3,
        )
        if step == "KPEXEC_PERSIST":
            validate_kernel_persistent_exec(fields, expected_cr3=cr3, relocated=False)
        return

    if status == "HIGH":
        if step != "KPMAIN_HIGH":
            raise AssertionError(f"krelocstep= must be KPMAIN_HIGH while kreloc=HIGH, got {step}")
        _in_range(
            eip,
            KERNEL_HIGH_LINK_BASE,
            KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES,
            "kerneip",
        )
        _in_range(esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "kernesp")
        if cr3 != PAGING_DIR_ADDR:
            raise AssertionError("kerncr3= must still be the low bootstrap page directory while kreloc=HIGH")
        if virt != KERNEL_HIGH_LINK_BASE:
            raise AssertionError(f"kernvirt= must be the persistent higher-half kernel entry, got {virt:#x}")
        _page_aligned(phys, "kernphys")
        if not (KERNEL_LOW_LINK_BASE <= phys < KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES):
            raise AssertionError("kernphys= must remain the low physical kernel text frame while kreloc=HIGH")
        if phys == virt:
            raise AssertionError("kernphys= must be non-identity when kreloc=HIGH")
        validate_low_identity_probe(fields, relocated=False)
        validate_kernel_high_mainline(fields, expected_cr3=cr3)
        validate_kernel_high_alias(fields, expected_vaddr=virt, expected_phys=phys)
        validate_kernel_high_exec(fields, relocated=False)
        validate_kernel_persistent_alias(
            fields,
            expected_vaddr=virt,
            expected_phys=phys,
            expected_cr3=cr3,
        )
        validate_kernel_persistent_exec(fields, expected_cr3=cr3, relocated=False)
        validate_kernel_relocation_dir_candidate(
            fields,
            expected_vaddr=virt,
            expected_phys=phys,
        )
        validate_kernel_relocation_live_switch(fields)
        return

    if status == "OK":
        if step != "FULL":
            raise AssertionError(f"krelocstep= must be FULL once kreloc=OK, got {step}")
        _in_range(
            eip,
            KERNEL_HIGH_LINK_BASE,
            KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES,
            "kerneip",
        )
        _in_range(esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "kernesp")
        if cr3 == PAGING_DIR_ADDR:
            raise AssertionError("kerncr3= must not be the low bootstrap page directory for kreloc=OK")
        if cr3 in FIXED_BOOTSTRAP_PAGE_DIRS:
            raise AssertionError("kerncr3= must be a dedicated PMM-managed kernel page directory for kreloc=OK")
        _managed_frame(cr3, "kerncr3")
        if virt != KERNEL_HIGH_LINK_BASE:
            raise AssertionError(f"kernvirt= must be the higher-half kernel entry, got {virt:#x}")
        _page_aligned(phys, "kernphys")
        if phys >= KERNEL_HIGHER_HALF_BASE:
            raise AssertionError("kernphys= must remain a physical frame, not a higher-half virtual address")
        if phys == virt:
            raise AssertionError("kernphys= must be non-identity when kreloc=OK")
        validate_low_identity_probe(fields, relocated=True)
        validate_kernel_high_mainline(fields, expected_cr3=cr3)
        validate_kernel_high_alias(fields, expected_vaddr=virt, expected_phys=phys)
        validate_kernel_high_exec(fields, relocated=True)
        validate_kernel_persistent_alias(
            fields,
            expected_vaddr=virt,
            expected_phys=phys,
            expected_cr3=cr3,
        )
        return

    raise AssertionError(f"kreloc= must be LOW, HIGH, or OK, got {status}")


def validate_kernel_relocation_dir_candidate(
    fields: dict[str, str],
    *,
    expected_vaddr: int,
    expected_phys: int,
) -> None:
    _exact(fields, "kreldir", "OK")
    (
        directory,
        high_pde,
        low_pde,
        entry_xlat,
        stack_xlat,
        low_xlat,
    ) = _hex_tuple(fields, "kreldirx", 6, "/")
    entry_pte, stack_pte, low_pte = _hex_tuple(fields, "kreldirp", 3, "/")

    _managed_frame(directory, "kreldirx directory")
    if directory in FIXED_BOOTSTRAP_PAGE_DIRS:
        raise AssertionError("kreldirx= directory must be a dedicated PMM-managed relocation page directory")
    if directory == _hex(fields, "kerncr3"):
        raise AssertionError("kreldirx= directory is only a candidate while kreloc=HIGH")

    if (high_pde & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS:
        raise AssertionError("kreldirx= high PDE must be present and supervisor-writable")
    kppt = _hex(fields, "kppt")
    if (high_pde & ~(PAGE_SIZE - 1)) != kppt:
        raise AssertionError("kreldirx= high PDE must point at the persistent high alias page table")
    if low_pde & PTE_PRESENT:
        raise AssertionError("kreldirx= low PDE must be absent in the candidate relocation directory")

    if entry_xlat != expected_phys:
        raise AssertionError("kreldirx= entry translation must preserve the persistent higher-half kernel text")
    stack_phys = _hex(fields, "kpspa")
    if stack_xlat != stack_phys:
        raise AssertionError("kreldirx= stack translation must preserve the persistent higher-half kernel stack")
    if low_xlat != MISSING_TRANSLATION:
        raise AssertionError("kreldirx= low identity translation must be absent in the candidate directory")

    if (entry_pte & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS:
        raise AssertionError("kreldirp= entry PTE must be present and supervisor-writable")
    if (entry_pte & ~(PAGE_SIZE - 1)) != (entry_xlat & ~(PAGE_SIZE - 1)):
        raise AssertionError("kreldirp= entry PTE frame must match kreldirx= entry translation")
    if expected_vaddr != KERNEL_HIGHER_HALF_BASE + expected_phys:
        raise AssertionError("kreldirx= expected high entry must remain the direct higher-half alias")

    if (stack_pte & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS:
        raise AssertionError("kreldirp= stack PTE must be present and supervisor-writable")
    if (stack_pte & ~(PAGE_SIZE - 1)) != (stack_xlat & ~(PAGE_SIZE - 1)):
        raise AssertionError("kreldirp= stack PTE frame must match kreldirx= stack translation")
    if low_pte & PTE_PRESENT:
        raise AssertionError("kreldirp= low PTE must not retain the present bit in the candidate directory")


def validate_kernel_relocation_live_switch(fields: dict[str, str]) -> None:
    _exact(fields, "krelive", "OK")
    (
        eip,
        esp,
        live_cr3,
        return_cr3,
        code_vaddr,
        code_phys,
        stack_vaddr,
        stack_phys,
        data_vaddr,
        data_phys,
    ) = _hex_tuple(fields, "krelivex", 10, "/")
    code_xlat, stack_xlat, data_xlat, low_xlat, magic = _hex_tuple(fields, "krelivep", 5, "/")
    directory, _, _, _, _, _ = _hex_tuple(fields, "kreldirx", 6, "/")
    kerncr3 = _hex(fields, "kerncr3")

    if live_cr3 != directory:
        raise AssertionError("krelivex= live CR3 must be the PMM-backed relocation directory")
    if live_cr3 == kerncr3:
        raise AssertionError("krelivex= live CR3 must differ from the long-lived bootstrap kerncr3 while kreloc=HIGH")
    if live_cr3 in FIXED_BOOTSTRAP_PAGE_DIRS:
        raise AssertionError("krelivex= live CR3 must not be a fixed bootstrap/user page directory")
    _managed_frame(live_cr3, "krelivex live CR3")
    if return_cr3 != PAGING_DIR_ADDR:
        raise AssertionError("krelivex= return CR3 must prove the bounded proof switched back to bootstrap CR3")

    _page_aligned(code_vaddr, "krelivex code vaddr")
    _page_aligned(code_phys, "krelivex code phys")
    _page_aligned(stack_vaddr, "krelivex stack vaddr")
    _page_aligned(stack_phys, "krelivex stack phys")
    if code_vaddr != KERNEL_HIGHER_HALF_BASE + code_phys:
        raise AssertionError("krelivex= code page must be the direct higher-half alias of its physical page")
    if stack_vaddr != KERNEL_HIGHER_HALF_BASE + stack_phys:
        raise AssertionError("krelivex= stack page must be the direct higher-half alias of its physical page")
    if data_vaddr != KERNEL_HIGHER_HALF_BASE + data_phys:
        raise AssertionError("krelivex= data slot must be written through its higher-half alias")

    if not (KERNEL_LOW_LINK_BASE <= code_phys < KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES):
        raise AssertionError("krelivex= code phys must be inside the kernel image")
    if not (KERNEL_STACK_LOW <= stack_phys < KERNEL_STACK_TOP):
        raise AssertionError("krelivex= stack phys must be inside the kernel stack")
    if not (KERNEL_LOW_LINK_BASE <= data_phys < KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES):
        raise AssertionError("krelivex= data phys must be inside the kernel image")
    if not (code_vaddr <= eip < code_vaddr + PAGE_SIZE):
        raise AssertionError("krelivex= EIP must be inside the high relocation-switch code page")
    if not (stack_vaddr <= esp < stack_vaddr + PAGE_SIZE):
        raise AssertionError("krelivex= ESP must be inside the high relocation-switch stack page")

    if code_xlat != code_phys:
        raise AssertionError("krelivep= code translation must survive under the relocation directory")
    if stack_xlat != stack_phys:
        raise AssertionError("krelivep= stack translation must survive under the relocation directory")
    if data_xlat != data_phys:
        raise AssertionError("krelivep= high data translation must survive under the relocation directory")
    if low_xlat != MISSING_TRANSLATION:
        raise AssertionError("krelivep= low identity translation must be absent during the live CR3 proof")
    if magic != KERNEL_RELOCATION_LIVE_MAGIC:
        raise AssertionError("krelivep= magic must prove the live relocation directory wrote through high data")


def validate_low_identity_probe(fields: dict[str, str], *, relocated: bool) -> None:
    if "klowid" not in fields:
        if relocated:
            raise AssertionError("kreloc=OK must include klowid= low-identity mapping policy/probe")
        return

    policy, vaddr, xlat, pte = _hex_tuple(fields, "klowid", 4, "/")
    if vaddr != KERNEL_LOW_LINK_BASE:
        raise AssertionError(f"klowid= must probe the low linked kernel entry page, got {vaddr:#x}")

    if relocated:
        if policy != LOW_IDENTITY_TRAPPED:
            raise AssertionError("klowid= must prove the low kernel entry identity mapping is trapped/absent for kreloc=OK")
        if xlat != MISSING_TRANSLATION:
            raise AssertionError("klowid= must report no low identity translation once kreloc=OK")
        if pte & PTE_PRESENT:
            raise AssertionError("klowid= PTE flags must not retain the present bit once kreloc=OK")
        return

    if policy != LOW_IDENTITY_PRESENT:
        raise AssertionError("klowid= must expose the retained low identity dependency before kreloc=OK")
    if xlat != vaddr:
        raise AssertionError("klowid= must translate the retained low identity page back to itself before kreloc=OK")
    if not (pte & PTE_PRESENT):
        raise AssertionError("klowid= must include the present bit for the retained low identity mapping")
    if (pte & ~(PAGE_SIZE - 1)) != (xlat & ~(PAGE_SIZE - 1)):
        raise AssertionError("klowid= PTE frame must match the retained low identity translation")


def validate_kernel_high_mainline(fields: dict[str, str], *, expected_cr3: int) -> None:
    _exact(fields, "khmain", "OK")
    (
        entry_eip,
        late_eip,
        entry_esp,
        late_esp,
        cr3,
        tss_esp0,
        idt_bias,
        checkpoints,
    ) = _hex_tuple(fields, "khmspan", 8, "/")

    _in_range(
        entry_eip,
        KERNEL_HIGH_LINK_BASE,
        KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES,
        "khmspan entry EIP",
    )
    _in_range(
        late_eip,
        KERNEL_HIGH_LINK_BASE,
        KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES,
        "khmspan late EIP",
    )
    _in_range(entry_esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "khmspan entry ESP")
    _in_range(late_esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "khmspan late ESP")
    if entry_eip == late_eip:
        raise AssertionError("khmspan= must contain two distinct higher-half mainline checkpoints")
    if cr3 != expected_cr3:
        raise AssertionError("khmspan= CR3 must match the active kernel relocation CR3")
    if tss_esp0 != KERNEL_HIGH_STACK_TOP:
        raise AssertionError("khmspan= must prove TSS esp0 uses the higher-half kernel stack")
    if idt_bias != KERNEL_HIGHER_HALF_BASE:
        raise AssertionError("khmspan= must prove IDT gates were rebuilt for higher-half kernel handlers")
    if checkpoints < KERNEL_HIGH_MAINLINE_MIN_CHECKPOINTS:
        raise AssertionError("khmspan= must prove at least two live higher-half mainline checkpoints")

    (
        entry_xlat,
        late_xlat,
        entry_stack_xlat,
        late_stack_xlat,
    ) = _hex_tuple(fields, "khmxlat", 4, "/")
    (
        pde,
        entry_pte,
        late_pte,
        entry_stack_pte,
        late_stack_pte,
    ) = _hex_tuple(fields, "khmpte", 5, "/")

    expected_xlats = (
        (entry_xlat, entry_eip - KERNEL_HIGHER_HALF_BASE, "entry EIP"),
        (late_xlat, late_eip - KERNEL_HIGHER_HALF_BASE, "late EIP"),
        (entry_stack_xlat, entry_esp - KERNEL_HIGHER_HALF_BASE, "entry ESP"),
        (late_stack_xlat, late_esp - KERNEL_HIGHER_HALF_BASE, "late ESP"),
    )
    for actual, expected, label in expected_xlats:
        if actual != expected:
            raise AssertionError(f"khmxlat= must translate high-mainline {label} back to {expected:#x}")

    if not (pde & PTE_PRESENT):
        raise AssertionError("khmpte= high-mainline PDE must be present")
    if (pde & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS:
        raise AssertionError("khmpte= high-mainline PDE must be supervisor-writable")
    kppt = _hex(fields, "kppt")
    if (pde & ~(PAGE_SIZE - 1)) != kppt:
        raise AssertionError("khmpte= high-mainline PDE must point at the persistent high alias page table")

    for name, pte, xlat in (
        ("entry text", entry_pte, entry_xlat),
        ("late text", late_pte, late_xlat),
        ("entry stack", entry_stack_pte, entry_stack_xlat),
        ("late stack", late_stack_pte, late_stack_xlat),
    ):
        if (pte & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS:
            raise AssertionError(f"khmpte= {name} PTE must be present and supervisor-writable")
        if (pte & ~(PAGE_SIZE - 1)) != (xlat & ~(PAGE_SIZE - 1)):
            raise AssertionError(f"khmpte= {name} PTE frame must match khmxlat=")


def validate_kernel_high_alias(
    fields: dict[str, str],
    *,
    expected_vaddr: int,
    expected_phys: int,
) -> None:
    _exact(fields, "kmap", "OK")

    alias_vaddr = _hex(fields, "kmapva")
    alias_phys = _hex(fields, "kmappa")
    alias_table = _hex(fields, "kmappt")
    alias_reclaimed = _hex(fields, "kmapfree")
    low_word = _hex(fields, "kmaplo")
    high_word = _hex(fields, "kmaphi")

    _page_aligned(alias_vaddr, "kmapva")
    _page_aligned(alias_phys, "kmappa")
    if alias_vaddr != expected_vaddr:
        raise AssertionError(
            f"kmapva= must be the higher-half alias of the kernel entry page, got {alias_vaddr:#x}"
        )
    if alias_vaddr < KERNEL_HIGHER_HALF_BASE:
        raise AssertionError(f"kmapva= must be in the higher half, got {alias_vaddr:#x}")
    if alias_phys >= KERNEL_HIGHER_HALF_BASE:
        raise AssertionError("kmappa= must be a physical frame, not a higher-half virtual address")
    if alias_phys != expected_phys:
        raise AssertionError(
            f"kmappa= must match the kernel entry physical page {expected_phys:#x}, got {alias_phys:#x}"
        )
    if alias_phys == alias_vaddr:
        raise AssertionError("kmapva= and kmappa= must prove a non-identity kernel text alias")
    _managed_frame(alias_table, "kmappt")
    _managed_frame(alias_reclaimed, "kmapfree")
    if alias_table == alias_phys:
        raise AssertionError("kmappt= must be distinct from the aliased kernel text frame")
    if alias_reclaimed != alias_table:
        raise AssertionError("kmapfree= must match kmappt= to prove kernel-alias page-table reclaim")
    if low_word == 0:
        raise AssertionError("kmaplo= must record nonzero bytes read from the low kernel entry")
    if high_word != low_word:
        raise AssertionError("kmaphi= must match kmaplo= after reading the higher-half kernel alias")


def validate_kernel_high_exec(fields: dict[str, str], *, relocated: bool) -> None:
    _exact(fields, "khiexec", "OK")

    eip = _hex(fields, "khieip")
    esp = _hex(fields, "khiesp")
    cr3 = _hex(fields, "khicr3")
    vaddr = _hex(fields, "khiva")
    phys = _hex(fields, "khipa")
    stack_vaddr = _hex(fields, "khistk")
    stack_phys = _hex(fields, "khistkpa")
    table = _hex(fields, "khipt")
    reclaimed = _hex(fields, "khifree")
    xlat = _hex(fields, "khixlat")
    stack_xlat = _hex(fields, "khisxlat")
    stack_slot = _hex(fields, "khislot")
    stack_slot_phys = _hex(fields, "khislotpa")
    stack_word = _hex(fields, "khisword")
    return_eip = _hex(fields, "khiret")

    _in_range(eip, KERNEL_HIGH_LINK_BASE, KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES, "khieip")
    _in_range(esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "khiesp")
    _page_aligned(vaddr, "khiva")
    _page_aligned(phys, "khipa")
    _page_aligned(stack_vaddr, "khistk")
    _page_aligned(stack_phys, "khistkpa")

    if vaddr != (eip & ~(PAGE_SIZE - 1)):
        raise AssertionError("khiva= must be the page containing the high trampoline EIP")
    if not (KERNEL_LOW_LINK_BASE <= phys < KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES):
        raise AssertionError("khipa= must be the low physical kernel text page backing khiva")
    if vaddr != KERNEL_HIGHER_HALF_BASE + phys:
        raise AssertionError("khiva= must be the higher-half alias of khipa")
    if stack_vaddr != (esp & ~(PAGE_SIZE - 1)):
        raise AssertionError("khistk= must be the page containing the high trampoline ESP")
    if not (KERNEL_STACK_LOW <= stack_phys < KERNEL_STACK_TOP):
        raise AssertionError("khistkpa= must be the low physical kernel stack page backing khistk")
    if stack_vaddr != KERNEL_HIGHER_HALF_BASE + stack_phys:
        raise AssertionError("khistk= must be the higher-half alias of khistkpa")
    if xlat != phys:
        raise AssertionError("khixlat= must translate khiva= back to khipa=")
    if stack_xlat != stack_phys:
        raise AssertionError("khisxlat= must translate khistk= back to khistkpa=")
    if not (stack_vaddr <= stack_slot < stack_vaddr + PAGE_SIZE):
        raise AssertionError("khislot= must be a high-stack slot inside khistk=")
    expected_slot_phys = stack_phys + (stack_slot & (PAGE_SIZE - 1))
    if stack_slot_phys != expected_slot_phys:
        raise AssertionError(
            f"khislotpa= must be the low physical backing for khislot=, got {stack_slot_phys:#x}"
        )
    if stack_word != KERNEL_HIGH_EXEC_STACK_MAGIC:
        raise AssertionError(
            f"khisword= must prove a high-stack write of {KERNEL_HIGH_EXEC_STACK_MAGIC:08X}"
        )

    if relocated:
        expected_cr3 = _hex(fields, "kerncr3")
        if cr3 != expected_cr3:
            raise AssertionError("khicr3= must match kerncr3= once kreloc=OK")
        _in_range(
            return_eip,
            KERNEL_HIGH_LINK_BASE,
            KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES,
            "khiret",
        )
    elif cr3 != PAGING_DIR_ADDR:
        raise AssertionError("khicr3= must prove the high trampoline still ran under the low bootstrap page directory")
    else:
        _in_range(
            return_eip,
            KERNEL_LOW_LINK_BASE,
            KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES,
            "khiret",
        )

    if phys == vaddr or stack_phys == stack_vaddr:
        raise AssertionError("khiexec proof must use non-identity high aliases")
    _managed_frame(table, "khipt")
    _managed_frame(reclaimed, "khifree")
    if table in (phys, stack_phys):
        raise AssertionError("khipt= must be distinct from the aliased text and stack frames")
    if reclaimed != table:
        raise AssertionError("khifree= must match khipt= to prove high-exec page-table reclaim")


def validate_kernel_persistent_alias(
    fields: dict[str, str],
    *,
    expected_vaddr: int,
    expected_phys: int,
    expected_cr3: int,
) -> None:
    _exact(fields, "kpmap", "OK")

    vaddr = _hex(fields, "kpva")
    phys = _hex(fields, "kppa")
    pages = _hex(fields, "kppages")
    table = _hex(fields, "kppt")
    cr3 = _hex(fields, "kpcr3")
    dir_mask = _hex(fields, "kpdirs")
    xlat = _hex(fields, "kpxlat")
    last_xlat = _hex(fields, "kplast")
    low_word = _hex(fields, "kplo")
    high_word = _hex(fields, "kphi")
    stack_vaddr = _hex(fields, "kpsva")
    stack_phys = _hex(fields, "kpspa")
    stack_pages = _hex(fields, "kpspages")
    stack_xlat = _hex(fields, "kpsxlat")

    _page_aligned(vaddr, "kpva")
    _page_aligned(phys, "kppa")
    if vaddr != expected_vaddr:
        raise AssertionError(f"kpva= must be the persistent higher-half kernel text base, got {vaddr:#x}")
    if vaddr < KERNEL_HIGHER_HALF_BASE:
        raise AssertionError(f"kpva= must be in the higher half, got {vaddr:#x}")
    if phys >= KERNEL_HIGHER_HALF_BASE:
        raise AssertionError("kppa= must be a physical frame, not a higher-half virtual address")
    if phys != expected_phys:
        raise AssertionError(f"kppa= must match the kernel text physical base {expected_phys:#x}, got {phys:#x}")
    if vaddr == phys:
        raise AssertionError("kpva= and kppa= must prove a non-identity persistent kernel alias")
    if pages != KERNEL_PERSISTENT_ALIAS_PAGES:
        raise AssertionError(
            f"kppages= must cover the kernel ELF window ({KERNEL_PERSISTENT_ALIAS_PAGES:#x} pages), got {pages:#x}"
        )

    _managed_frame(table, "kppt")
    if table in (phys, stack_phys):
        raise AssertionError("kppt= must be distinct from aliased kernel text and stack frames")
    if cr3 != expected_cr3:
        raise AssertionError("kpcr3= must match the active kernel relocation CR3")
    if dir_mask != KERNEL_PERSISTENT_DIR_MASK:
        raise AssertionError(
            f"kpdirs= must prove the high kernel PDE was installed in every fixed process page directory, got {dir_mask:#x}"
        )
    if xlat != phys:
        raise AssertionError("kpxlat= must translate kpva= back to kppa=")
    expected_last = phys + ((pages - 1) * PAGE_SIZE)
    if last_xlat != expected_last:
        raise AssertionError(
            f"kplast= must translate the last persistent kernel alias page to {expected_last:#x}, got {last_xlat:#x}"
        )
    if low_word == 0:
        raise AssertionError("kplo= must record nonzero bytes read from low kernel text")
    if high_word != low_word:
        raise AssertionError("kphi= must match kplo= through the persistent higher-half alias")

    _page_aligned(stack_vaddr, "kpsva")
    _page_aligned(stack_phys, "kpspa")
    if stack_phys != KERNEL_STACK_LOW:
        raise AssertionError(f"kpspa= must be the low kernel stack base, got {stack_phys:#x}")
    if stack_vaddr != KERNEL_HIGHER_HALF_BASE + stack_phys:
        raise AssertionError("kpsva= must be the higher-half alias of kpspa=")
    if stack_pages != KERNEL_STACK_ALIAS_PAGES:
        raise AssertionError(
            f"kpspages= must cover the whole low kernel stack window ({KERNEL_STACK_ALIAS_PAGES:#x} pages), got {stack_pages:#x}"
        )
    if stack_xlat != stack_phys:
        raise AssertionError("kpsxlat= must translate kpsva= back to kpspa=")
    if stack_vaddr == stack_phys:
        raise AssertionError("kpsva= and kpspa= must prove a non-identity persistent stack alias")


def validate_kernel_persistent_exec(
    fields: dict[str, str],
    *,
    expected_cr3: int,
    relocated: bool,
) -> None:
    _exact(fields, "kpexec", "OK")

    eip = _hex(fields, "kpeip")
    esp = _hex(fields, "kpesp")
    cr3 = _hex(fields, "kpecr3")
    vaddr = _hex(fields, "kpeva")
    phys = _hex(fields, "kpepa")
    stack_vaddr = _hex(fields, "kpestk")
    stack_phys = _hex(fields, "kpestkpa")
    xlat = _hex(fields, "kpexlat")
    stack_xlat = _hex(fields, "kpesxlat")
    stack_slot = _hex(fields, "kpeslot")
    stack_slot_phys = _hex(fields, "kpeslotpa")
    stack_word = _hex(fields, "kpesword")
    return_eip = _hex(fields, "kperet")

    _in_range(eip, KERNEL_HIGH_LINK_BASE, KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES, "kpeip")
    _in_range(esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "kpesp")
    _page_aligned(vaddr, "kpeva")
    _page_aligned(phys, "kpepa")
    _page_aligned(stack_vaddr, "kpestk")
    _page_aligned(stack_phys, "kpestkpa")

    if cr3 != expected_cr3:
        raise AssertionError("kpecr3= must match the active persistent kernel alias CR3")
    if vaddr != (eip & ~(PAGE_SIZE - 1)):
        raise AssertionError("kpeva= must be the page containing the persistent high-exec EIP")
    if not (KERNEL_LOW_LINK_BASE <= phys < KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES):
        raise AssertionError("kpepa= must be the low physical kernel text page backing kpeva")
    if vaddr != KERNEL_HIGHER_HALF_BASE + phys:
        raise AssertionError("kpeva= must be the higher-half alias of kpepa")
    if stack_vaddr != (esp & ~(PAGE_SIZE - 1)):
        raise AssertionError("kpestk= must be the page containing the persistent high-exec ESP")
    if not (KERNEL_STACK_LOW <= stack_phys < KERNEL_STACK_TOP):
        raise AssertionError("kpestkpa= must be the low physical kernel stack page backing kpestk")
    if stack_vaddr != KERNEL_HIGHER_HALF_BASE + stack_phys:
        raise AssertionError("kpestk= must be the higher-half alias of kpestkpa")
    if xlat != phys:
        raise AssertionError("kpexlat= must translate kpeva= back to kpepa=")
    if stack_xlat != stack_phys:
        raise AssertionError("kpesxlat= must translate kpestk= back to kpestkpa=")
    if not (stack_vaddr <= stack_slot < stack_vaddr + PAGE_SIZE):
        raise AssertionError("kpeslot= must be a high-stack slot inside kpestk=")
    expected_slot_phys = stack_phys + (stack_slot & (PAGE_SIZE - 1))
    if stack_slot_phys != expected_slot_phys:
        raise AssertionError(
            f"kpeslotpa= must be the low physical backing for kpeslot=, got {stack_slot_phys:#x}"
        )
    if stack_word != KERNEL_PERSISTENT_EXEC_STACK_MAGIC:
        raise AssertionError(
            f"kpesword= must prove a persistent high-stack write of {KERNEL_PERSISTENT_EXEC_STACK_MAGIC:08X}"
        )
    if phys == vaddr or stack_phys == stack_vaddr:
        raise AssertionError("kpexec proof must use non-identity persistent high aliases")

    if relocated:
        _in_range(
            return_eip,
            KERNEL_HIGH_LINK_BASE,
            KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES,
            "kperet",
        )
    else:
        _in_range(
            return_eip,
            KERNEL_LOW_LINK_BASE,
            KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES,
            "kperet",
        )


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
    (
        table_resolves,
        generic_resolves,
        generic_successes,
        last_resolve_mode,
        last_success_mode,
        last_caller_kind,
        last_target_kind,
        last_generic_pid,
    ) = _hex_tuple(fields, "execmap", 8, "/")
    if table_resolves < 2:
        raise AssertionError("execmap= must prove table-backed exec resolved USERPROB and Doom")
    if generic_resolves == 0:
        raise AssertionError("execmap= must prove a generic root .ELF path was resolved")
    if generic_successes == 0:
        raise AssertionError("execmap= must prove a generic root .ELF successfully launched")
    if last_resolve_mode != SYS_EXEC_RESOLVE_TABLE or last_success_mode != SYS_EXEC_RESOLVE_TABLE:
        raise AssertionError("execmap= must show the final Doom exec used the table resolver")
    if last_caller_kind != USER_KIND_GENERIC or last_target_kind != USER_KIND_DOOM:
        raise AssertionError("execmap= must prove Doom was launched by a generic user process")
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
    if last_generic_pid != abi_pid:
        raise AssertionError("execmap= must tie the successful generic root .ELF launch to ABIPROBE")
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
        status_attempts,
        status_successes,
        status_failures,
        status_last_pid,
        status_last_parent,
        status_last_state,
        status_last_ticks,
    ) = _hex_tuple(fields, "pstat", 7, "/")
    if status_attempts < 3 or status_successes < 2:
        raise AssertionError("pstat= must prove process_status handled current and pid lookups")
    if status_failures == 0:
        raise AssertionError("pstat= must prove process_status classified invalid pid lookups")
    if status_last_pid != abi_pid:
        raise AssertionError("pstat= last PID must match the ABI probe PID")
    if status_last_parent != boot_user_pid:
        raise AssertionError("pstat= parent PID must match the USERPROB launcher PID")
    if status_last_state != 2:
        raise AssertionError("pstat= last state must prove the queried process was running")
    if status_last_ticks == 0:
        raise AssertionError("pstat= must record nonzero scheduler tick accounting")

    (
        yield_attempts,
        yield_switches,
        yield_noops,
        yield_last_from,
        yield_last_to,
    ) = _hex_tuple(fields, "yield", 5, "/")
    if yield_attempts == 0:
        raise AssertionError("yield= must prove SYS_YIELD was exercised")
    if yield_switches + yield_noops != yield_attempts:
        raise AssertionError("yield= attempts must equal switches plus noops")
    if yield_last_from != abi_pid:
        raise AssertionError("yield= last source PID must match the ABI probe PID")
    if yield_switches == 0 and yield_last_to != 0xFFFFFFFF:
        raise AssertionError("yield= no-switch proof must keep the target PID sentinel")
    if yield_switches != 0 and yield_last_to in (0, 0xFFFFFFFF):
        raise AssertionError("yield= switched proof must record a real target PID")

    (
        block_attempts,
        block_transitions,
        block_wakeups,
        block_failures,
        block_last_pid,
        block_last_reason,
        block_last_object,
        block_last_woken_pid,
        block_last_wake_reason,
    ) = _hex_tuple(fields, "kblock", 9, "/")
    if block_attempts < 2:
        raise AssertionError("kblock= must prove multiple kernel block reasons were exercised")
    if block_transitions < 2:
        raise AssertionError("kblock= must prove runnable-to-blocked transitions")
    if block_wakeups < 2:
        raise AssertionError("kblock= must prove blocked-to-runnable wakeups")
    if block_failures != 0:
        raise AssertionError("kblock= must not hide failed kernel block attempts")
    if block_last_pid != abi_pid:
        raise AssertionError("kblock= last blocker PID must match the ABI probe PID")
    if block_last_reason != PROC_BLOCK_WAITPID:
        raise AssertionError("kblock= must prove waitpid uses the generic block primitive")
    if block_last_object in (0, 0xFFFFFFFF):
        raise AssertionError("kblock= must record the waited child PID as its object")
    if block_last_woken_pid != abi_pid:
        raise AssertionError("kblock= last woken PID must match the ABI probe PID")
    if block_last_wake_reason != PROC_BLOCK_WAITPID:
        raise AssertionError("kblock= must prove waitpid woke through the generic wake path")

    (
        sleep_attempts,
        sleep_blocks,
        sleep_wakeups,
        _sleep_noops,
        sleep_failures,
        sleep_last_pid,
        sleep_last_until,
        sleep_last_ticks,
        sleep_last_woken_pid,
    ) = _hex_tuple(fields, "ksleep", 9, "/")
    if sleep_attempts == 0:
        raise AssertionError("ksleep= must prove SYS_SLEEP_TICKS was exercised")
    if sleep_blocks == 0:
        raise AssertionError("ksleep= must prove the kernel marked a process non-runnable")
    if sleep_wakeups == 0:
        raise AssertionError("ksleep= must prove the PIT wake path made the sleeper ready")
    if sleep_failures != 0:
        raise AssertionError("ksleep= must not hide failed kernel sleep attempts")
    if sleep_last_pid != abi_pid:
        raise AssertionError("ksleep= last sleeper PID must match the ABI probe PID")
    if sleep_last_ticks == 0 or sleep_last_until == 0:
        raise AssertionError("ksleep= must record a nonzero wake deadline")
    if sleep_last_woken_pid != abi_pid:
        raise AssertionError("ksleep= last woken PID must match the ABI probe PID")

    (
        wait_attempts,
        wait_reaps,
        wait_failures,
        _wait_nohang,
        wait_seeded,
        wait_last_pid,
        wait_last_status,
        wait_blocks,
        wait_block_wakeups,
    ) = _hex_tuple(fields, "wait", 9, "/")
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
    if wait_blocks == 0 or wait_block_wakeups == 0:
        raise AssertionError("wait= must prove blocking waitpid slept and woke in the kernel")
    wait_seed_pid = _hex(fields, "waitseed")
    if wait_seed_pid == 0 or wait_seed_pid == 0xFFFFFFFF:
        raise AssertionError("waitseed= must record the seeded preempt-probe child PID")

    (
        fork_successes,
        fork_failures,
        fork_parent_pid,
        fork_child_pid,
        fork_parent_return,
        fork_child_return,
        fork_pages,
        fork_fds,
        fork_owned_freed,
        fork_zombies,
    ) = _hex_tuple(fields, "fork", 10, "/")
    if fork_successes == 0:
        raise AssertionError("fork= must prove SYS_FORK succeeded at least once")
    if fork_failures != 0:
        raise AssertionError("fork= must prove the bounded fork proof did not hit an error path")
    if fork_parent_pid != abi_pid:
        raise AssertionError("fork= parent PID must match the ABI probe PID")
    if fork_child_pid in (0, 0xFFFFFFFF) or fork_child_pid == fork_parent_pid:
        raise AssertionError("fork= must record a distinct child PID")
    if fork_parent_return != fork_child_pid:
        raise AssertionError("fork= must prove the parent returned the child PID")
    if fork_child_return != 0:
        raise AssertionError("fork= must prove the child returned zero")
    if fork_pages == 0:
        raise AssertionError("fork= must prove eager child address-space page copying")
    if fork_fds == 0:
        raise AssertionError("fork= must prove fork-time fd descriptor cloning")
    if fork_owned_freed == 0:
        raise AssertionError("fork= must prove fork child PMM-backed pages were reclaimed")
    if fork_zombies == 0:
        raise AssertionError("fork= must prove child exit left a wait-reapable zombie")

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

    frame_ds, frame_es, frame_fs, frame_gs = _hex_tuple(fields, "psegs", 4, ":")
    for name, selector in (
        ("DS", frame_ds),
        ("ES", frame_es),
        ("FS", frame_fs),
        ("GS", frame_gs),
    ):
        if selector != USER_DATA_SEG or (selector & 0x3) != 0x3:
            _raise_preemption_failure(
                fields,
                f"psegs= {name} must be the restored Ring 3 user data selector",
            )

    from_eflags, to_eflags, frame_eflags, live_sanitized, selftest_sanitized = _hex_tuple(
        fields, "peflags", 5, ":"
    )
    for name, value in (
        ("source", from_eflags),
        ("target", to_eflags),
        ("frame", frame_eflags),
    ):
        if value != SANITIZED_USER_EFLAGS:
            _raise_preemption_failure(
                fields,
                f"peflags= {name} EFLAGS must be sanitized to IF-on, IOPL-zero user flags",
            )
    if selftest_sanitized == 0:
        _raise_preemption_failure(
            fields, "peflags= must prove the scheduler self-test exercised EFLAGS sanitization"
        )
    if live_sanitized > preempt + user_irq_ticks:
        _raise_preemption_failure(
            fields, "peflags= live sanitizer count is larger than the live IRQ frame population"
        )


def validate_fault_observability(fields: dict[str, str]) -> None:
    source = _field(fields, "faultsrc")
    mode = _field(fields, "faultmode")
    if source not in {
        FAULT_SOURCE_NONE,
        FAULT_SOURCE_EXPECTED,
        FAULT_SOURCE_USER,
        FAULT_SOURCE_DOOM,
        FAULT_SOURCE_KERNEL,
    }:
        raise AssertionError(f"faultsrc= has unknown source {source!r}")
    if mode not in {FAULT_MODE_NONE, FAULT_MODE_USER, FAULT_MODE_KERNEL}:
        raise AssertionError(f"faultmode= has unknown mode {mode!r}")

    fault = _hex_tuple(fields, "fault", 11, "/")
    pf = _hex_tuple(fields, "pf", 5, "/")
    regs = _hex_tuple(fields, "regs", 8, "/")
    segs = _hex_tuple(fields, "segs", 6, "/")
    proc = _hex_tuple(fields, "proc", 9, "/")
    (
        expected_recovered,
        user_contained,
        doom_contained,
        kernel_panics,
        last_contained,
    ) = _hex_tuple(fields, "faultcontain", 5, "/")
    panic = fields.get("panic", "NONE")

    if source == FAULT_SOURCE_NONE:
        if mode != FAULT_MODE_NONE:
            raise AssertionError("faultmode= must be NONE when faultsrc=NONE")
        if last_contained != 0:
            raise AssertionError("faultcontain= last-contained must be zero when faultsrc=NONE")
        if any(fault):
            raise AssertionError("fault= must be all zero when faultsrc=NONE")
        if any(pf):
            raise AssertionError("pf= must be all zero when faultsrc=NONE")
        if any(regs):
            raise AssertionError("regs= must be all zero when faultsrc=NONE")
        if any(segs):
            raise AssertionError("segs= must be all zero when faultsrc=NONE")
        if any(proc):
            raise AssertionError("proc= must be all zero when faultsrc=NONE")
        return

    if regs[7] == 0:
        raise AssertionError("regs= must include a nonzero EFLAGS snapshot for recorded faults")
    if segs[4] != fault[3] or segs[5] != fault[5]:
        raise AssertionError("segs= CS/SS must mirror the compact fault= frame")
    if source in {FAULT_SOURCE_EXPECTED, FAULT_SOURCE_USER, FAULT_SOURCE_DOOM}:
        if proc[0] == 0 or proc[8] == 0:
            raise AssertionError("proc= must include process pointer and CR3 for contained Ring 3 faults")

    if fault[0] == 14:
        expected_mode = _fault_mode_id(mode)
        expected_pf = (
            fault[6],
            fault[1],
            expected_mode,
            _page_fault_access(fault[1]),
            _page_fault_reason(fault[1]),
        )
        if pf != expected_pf:
            raise AssertionError(
                "pf= must mirror page-fault CR2/error/mode/access/reason classification"
            )
    elif any(pf):
        raise AssertionError("pf= must be zero when the compact fault vector is not a page fault")

    if source == FAULT_SOURCE_KERNEL:
        if mode != FAULT_MODE_KERNEL:
            raise AssertionError("faultmode= must be KERNEL for kernel exception panics")
        if last_contained != 0:
            raise AssertionError("faultcontain= last-contained must be zero for kernel panics")
        if kernel_panics == 0:
            raise AssertionError("faultcontain= must count kernel panics when faultsrc=KERNEL")
        if panic != "KEXC":
            raise AssertionError("panic= must be KEXC when faultsrc=KERNEL")
        if fault[3] & 0x3:
            raise AssertionError("fault= CS must be Ring 0 when faultsrc=KERNEL")
        return

    if mode != FAULT_MODE_USER:
        raise AssertionError("faultmode= must be USER for contained Ring 3 faults")
    if last_contained != 1:
        raise AssertionError("faultcontain= last-contained must be one for contained Ring 3 faults")
    if not (fault[3] & 0x3):
        raise AssertionError("fault= CS must be Ring 3 for contained user faults")

    if source == FAULT_SOURCE_EXPECTED:
        if expected_recovered == 0:
            raise AssertionError("faultcontain= must count expected recovered faults")
        if fault[0] != 14:
            raise AssertionError("expected user fault containment must come from vector 14")
    elif source == FAULT_SOURCE_USER:
        if user_contained == 0:
            raise AssertionError("faultcontain= must count non-Doom user faults")
    elif source == FAULT_SOURCE_DOOM:
        if doom_contained == 0:
            raise AssertionError("faultcontain= must count Doom user faults")
        if fields.get("doomrun") != "FAULT":
            raise AssertionError("doomrun= must be FAULT when faultsrc=DOOM")
        for name, value in (
            ("doomfault", fault[6]),
            ("doomfaultip", fault[2]),
            ("doomfaultv", fault[0]),
            ("doomfaulterr", fault[1]),
        ):
            if hex8_field(fields, name) != value:
                raise AssertionError(f"{name}= must mirror the compact fault= frame")


def validate_status(
    text: str,
    *,
    require_exec: bool = False,
    require_preempt: bool = False,
) -> None:
    fields = parse_status(text)
    validate_pmm_boot_proof(fields)
    validate_firmware_boot_handoff(fields)
    validate_kernel_clock_proof(fields)
    validate_vm_mapping(fields)
    validate_fault_observability(fields)
    if require_exec:
        validate_exec(fields)
    if require_preempt:
        validate_preemption(fields)


def validate_repo_contract(root: Path = ROOT) -> None:
    real_wad_workflow = _read(root, ".github/workflows/real-wad-smoke.yml")
    real_wad_soak_workflow = _read(root, ".github/workflows/real-wad-soak.yml")
    os_workflow = _read(root, ".github/workflows/os-smoke.yml")
    makefile = _read(root, "Makefile")
    process_vm = _read(root, "docs/architecture.txt")
    boot_vm = _read(root, "docs/architecture.txt")
    gaps = _read(root, "docs/proof.txt")
    playable = _read(root, "docs/proof.txt")
    tests_readme = _read(root, "tests/strategy.txt")
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
        (tests_readme, "test strategy doc"),
    ):
        _require(text, "tools/check_vm_status_proof.py", label)
        _require(text, "kreloc=HIGH", label)
        _require(text, "krelocstep=KPMAIN_HIGH", label)
        _require(text, "kerneip=", label)
        _require(text, "kernesp=", label)
        _require(text, "kerncr3=", label)
        _require(text, "kernvirt=", label)
        _require(text, "kernphys=", label)
        _require(text, "khmain=OK", label)
        _require(text, "khmspan=", label)
        _require(text, "khmxlat=", label)
        _require(text, "khmpte=", label)
        _require(text, "uguard=", label)
        _require(text, "vmmguard=", label)
        _require(text, "e820map=", label)
        _require(text, "pmmuse=", label)
        _require(text, "pmmtype=", label)
        _require(text, "pmmchk=", label)
        _require(text, "pmmalloc=", label)
        _require(text, "pmmdeny=", label)
        _require(text, "kmap=OK", label)
        _require(text, "kmapva=", label)
        _require(text, "kmappa=", label)
        _require(text, "kmappt=", label)
        _require(text, "kmapfree=", label)
        _require(text, "kmaplo=", label)
        _require(text, "kmaphi=", label)
        _require(text, "vmmhfree", label)
        _require(text, "uexec=OK", label)
        _require(text, "upath=USERPROB.ELF", label)
        _require(text, "abiexec=OK", label)
        _require(text, "abipath=ABIPROBE.ELF", label)
        _require(text, "abiprobe=OK", label)
        _require(text, "argvsrc=2", label)
        _require(text, "execmap=", label)
        _require(text, "procpool=", label)
        _require(text, "fdexec=", label)
        _require(text, "fdup=", label)
        _require(text, "kblock=", label)
        _require(text, "ksleep=", label)
        _require(text, "pf=", label)
        _require(text, "regs=", label)
        _require(text, "segs=", label)
        _require(text, "proc=", label)
        _require(text, "wait=", label)
        _require(text, "waitseed=", label)
        _require(text, "fork=", label)
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
        _require(text, "kreldir=OK", label)
        _require(text, "kreldirx=", label)
        _require(text, "kreldirp=", label)
        _require(text, "krelive=OK", label)
        _require(text, "krelivex=", label)
        _require(text, "krelivep=", label)
        _require(text, "candidate relocation page directory", label)

    for text, label in (
        (process_vm, "process VM doc"),
        (boot_vm, "boot loader VM doc"),
        (tests_readme, "test strategy doc"),
    ):
        for needle in (
            "khiexec=OK",
            "khieip=",
            "khiesp=",
            "khicr3=",
            "khiva=",
            "khipa=",
            "khistk=",
            "khistkpa=",
            "khipt=",
            "khifree=",
            "khixlat=",
            "khisxlat=",
            "khislot=",
            "khislotpa=",
            "khisword=",
            "khiret=",
        ):
            _require(text, needle, label)

    for text, label in (
        (process_vm, "process VM doc"),
        (boot_vm, "boot loader VM doc"),
        (gaps, "gap ledger"),
        (playable, "playable proof doc"),
    ):
        for needle in (
            "kpmap=OK",
            "kpva=",
            "kppa=",
            "kppages=",
            "kppt=",
            "kpcr3=",
            "kpdirs=",
            "kpxlat=",
            "kplast=",
            "kplo=",
            "kphi=",
            "kpsva=",
            "kpspa=",
            "kpspages=",
            "kpsxlat=",
            "kpexec=OK",
            "kpeip=",
            "kpesp=",
            "kpecr3=",
            "kpeva=",
            "kpepa=",
            "kpestk=",
            "kpestkpa=",
            "kpexlat=",
            "kpesxlat=",
            "kpeslot=",
            "kpeslotpa=",
            "kpesword=",
            "kperet=",
        ):
            _require(text, needle, label)

    for text, label in (
        (process_vm, "process VM doc"),
        (boot_vm, "boot loader VM doc"),
        (gaps, "gap ledger"),
    ):
        _require(text, "pframe", label)
        _require(text, "psegs", label)
        _require(text, "peflags", label)

    process_exec = _read(root, "docs/architecture.txt")
    doom_runtime = _read(root, "docs/architecture.txt")
    for text, label in (
        (process_vm, "process VM doc"),
        (process_exec, "process exec doc"),
    ):
        _require(text, "exec target PID", label)
        _require(text, "pfrom", label)
        _require(text, "pto", label)
        _require(text, "preempt", label)
        _require(text, "clocksrc=PIT", label)
        _require(text, "clockirq=", label)
        _require(text, "clocktick=", label)
        _require(text, "clockdoom=", label)
        _require(text, "clocksch=", label)
        _require(text, "clockpirq=", label)

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
    parser.add_argument(
        "status",
        nargs="*",
        type=Path,
        help="status.txt files to validate; with no files, validate the repo contract",
    )
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
            validate_repo_contract()
            print("VM status proof contract OK")
            return 0
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
