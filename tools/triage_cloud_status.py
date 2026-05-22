#!/usr/bin/env python3
"""Classify the next real-WAD cloud status line into a repair lane."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

from status_fields import (
    hex8_field,
    hex_tuple_field,
    parse_hex8,
    parse_status_fields,
    summarize_status_fields,
)

SUMMARY_FIELDS = (
    "exec",
    "path",
    "execsys",
    "execerr",
    "execres",
    "target",
    "ppid",
    "entry",
    "stack",
    "argc",
    "argv",
    "envp",
    "argv0",
    "envp0",
    "biosboot",
    "biosflags",
    "biosentry",
    "doom",
    "doomrun",
    "doomopen",
    "doomread",
    "doomwad",
    "doominit",
    "doomerr",
    "doomerrno",
    "doommode",
    "doomwrite",
    "doomclose",
    "doomexit",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
    "fault",
    "pf",
    "faultsrc",
    "faultmode",
    "faultcontain",
    "regs",
    "segs",
    "proc",
    "panic",
    "shutdown",
    "ata",
    "ataop",
    "atawait",
    "atalba",
    "atastat",
    "ataerr",
    "atafail",
    "atatmo",
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "dtick",
    "doompresent",
    "fb",
    "fbdev",
    "fbmmio",
    "fbpolicy",
    "fbgeom",
    "fbdirty",
    "fbpresent",
    "fbinfo",
    "fbcap",
    "fbsrc",
    "fbacct",
    "doompal",
    "doomframe",
    "pflags",
    "gflags",
    "pdelta",
    "pangle",
    "pangledelta",
    "pammo",
    "prefire",
    "inputqueue",
    "inputpoll",
    "inputdepth",
    "inputstat",
    "inputpolicy",
    "inputdev",
    "inputdevices",
    "inputmods",
    "inputlast",
    "keyirq",
    "keyqueue",
    "keypoll",
    "keyseen",
    "keylast",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "mousebtn",
    "mousedelta",
    "gfx",
    "usr",
    "wad",
    "lmp",
    "heap",
    "free",
    "ticks",
    "audio",
    "adev",
    "pcm",
    "pcmbuf",
    "pcmstream",
    "pcmwrite",
    "pcmqueue",
    "pcmpull",
    "pcmirq",
    "pcmdma",
    "audioirq",
    "refill",
    "musicpos",
    "musicpull",
    "musicbuf",
    "mixunder",
    "musicunder",
    "musicdrops",
    "sb16",
    "dma",
    "play",
    "voiceq",
    "musicq",
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
    "pcr3",
    "pkstk",
    "peip",
    "pframe",
    "psegs",
    "peflags",
    "pspin",
    "kblock",
    "ksleep",
    "doomsav",
    "saverd",
    "savewr",
    "saveclose",
    "savemode",
    "saveact",
    "savedesc",
    "savestm",
    "savethk",
    "fwr",
    "fal",
    "fam",
    "fac",
    "fatdyn",
    "fio",
    "flb",
    "fcl",
)
EXECSYS_NAMES = (
    "attempts",
    "successes",
    "failures",
    "handoffs",
    "scheduled",
    "rollbacks",
)
FAULT_TUPLE_NAMES = (
    "vector",
    "error",
    "eip",
    "cs",
    "esp",
    "ss",
    "cr2",
    "pid",
    "kind",
    "state",
    "syscall",
)
VECTOR_NAMES = {
    0x00: "divide-error",
    0x06: "invalid-opcode",
    0x08: "double-fault",
    0x0A: "invalid-tss",
    0x0B: "segment-not-present",
    0x0C: "stack-segment-fault",
    0x0D: "general-protection",
    0x0E: "page-fault",
}
PAGE_FAULT_ERROR_BITS = (
    (0, "protection"),
    (1, "write"),
    (2, "user"),
    (3, "reserved-bit"),
    (4, "instruction-fetch"),
)
PF_ACCESS_NAMES = {
    0: "none",
    1: "read",
    2: "write",
    3: "instruction-fetch",
}
PF_MODE_NAMES = {
    0: "none",
    1: "user",
    2: "kernel",
}
PF_REASON_FLAGS = (
    (0x00000001, "not-present"),
    (0x00000002, "protection"),
    (0x00000004, "reserved-bit"),
    (0x00000008, "instruction-fetch"),
)
PREEMPT_PROBE_MAGIC = 0x50524545
USER_CODE_SEG = 0x1B
USER_DATA_SEG = 0x23
SANITIZED_USER_EFLAGS = 0x00000202
KERNEL_ENTRY = 0x00010000
BIOS_BOOT_REQUIRED_FLAGS = 0x00000D91
BIOS_BOOT_DISK_FLAGS = 0x0000000C
BIOS_BOOT_VIDEO_FLAGS = 0x00000060
PROC_BLOCK_WAITPID = 2
UEFI_REQUIRED_HANDOFF_FLAG_MASK = 0x0000007F
UEFI_LOADER_REQUIRED_HANDOFF_FIELDS = {
    "handoff": 0x9000,
    "bootinfo": 0x7000,
    "e820": 0x7100,
    "tramp32": 0x8000,
    "transition64": 0xA000,
}
PLAYABILITY_REQUIRED_FLAGS = 0x0000013F
PLAYABILITY_FIRE_STATE_FLAGS = 0x000000C0
KEY_SEEN_SCRIPTED_FLAGS = 0x00000071
LONG_RUN_REQUIRED_FIELDS = (
    "gtic",
    "leveltime",
    "dtick",
    "doompresent",
    "fbcap",
    "pirq",
    "preempt",
    "pattempt",
    "pskip",
    "puser",
    "audioirq",
    "refill",
    "musicpos",
)
LONG_RUN_REQUIRED_TUPLES = (
    ("fbpresent", 9, ":"),
    ("fbinfo", 3, ":"),
    ("fbsrc", 7, ":"),
    ("fbacct", 9, ":"),
    ("fbgeom", 5, ":"),
    ("fbdirty", 5, ":"),
    ("pcmstream", 5, ":"),
    ("pcmwrite", 4, ":"),
    ("pcmqueue", 6, ":"),
    ("pcmpull", 3, ":"),
    ("pcmirq", 3, ":"),
    ("pcmdma", 6, ":"),
    ("musicpull", 2, ":"),
    ("inputdepth", 2, ":"),
)
REQUIRED_DOOM_INIT_FLAGS = 0x000001FF
SAVELOAD_EVENT_READ = 0x0002
SAVELOAD_EVENT_CLOSE = 0x0008
SAVEACTION_LOAD_REQUESTED = 0x0020
SAVEACTION_LOAD_DONE = 0x0040
SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE = 0x15
SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE = 0x17
SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER = 0x18
SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED = 0x1A
SAVE_STREAM_UNSET_OFFSET = 0xFFFFFFFF
SAVE_LOAD_STREAM_STAGES = {
    SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE,
    SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE,
    SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER,
    SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED,
}
SAVE_STAGE_NAMES = {
    SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE: "unarchive-thinkers-before",
    SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE: "unarchive-specials-before",
    SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER: "unarchive-specials-after",
    SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED: "unarchive-thinkers-repaired",
}
VALID_THINKER_CLASSES = {0, 1}
VALID_SPECIAL_CLASSES = set(range(8))
UNKNOWN_TCLASS_PATTERN = re.compile(r"doomlog=.*?Unknown\s+tclass\s+([0-9]+)\s+in\s+savegame")
DOOMLOG_FIELD_PATTERN = re.compile(
    r"(?:^|\s)doomlog=(.*?)(?=\s\s+[A-Za-z][A-Za-z0-9_]*=|$)"
)


@dataclass(frozen=True)
class TriageRule:
    name: str
    fields: tuple[str, ...]
    meaning: str
    next_step: str


@dataclass(frozen=True)
class Symbol:
    address: int
    size: int
    sym_type: str
    bind: str
    section: str
    obj_path: str
    name: str


@dataclass(frozen=True)
class SymbolHit:
    symbol: Symbol
    offset: int
    inside_declared_size: bool


TRIAGE_RULES = (
    TriageRule(
        "bios-handoff-not-proven",
        ("biosboot", "biosflags", "biosentry", "e820", "e820cnt"),
        "The status does not prove the BIOS Stage 2 handoff into the kernel.",
        "Hand off to the BIOS boot owner: inspect Stage 2 E820, disk read, video handoff, A20, GDT/protected mode, ELF validation, and entry coverage.",
    ),
    TriageRule(
        "fault-containment-not-proven",
        ("faultsrc", "faultmode", "faultcontain", "fault", "panic", "doomrun"),
        "The crash/debug fields are missing or inconsistent, so the status cannot prove fault containment.",
        "Hand off to the crash/debug owner: verify fault classification, Ring 3 containment counters, and panic-only kernel exception handling.",
    ),
    TriageRule(
        "kernel-blocking-not-proven",
        ("kblock", "ksleep", "wait", "waitseed", "pstat", "yield"),
        "The status does not prove kernel-owned blocking and sleep primitives.",
        "Hand off to the scheduler/process owner: inspect generic block transitions, waitpid wakeups, SYS_SLEEP_TICKS, and PIT wake accounting.",
    ),
    TriageRule(
        "uefi-marker-not-proven",
        (
            "ovmf.proof",
            "ovmf.exit_boot_services",
            "ovmf.kernel_handoff_after_exit_boot_services",
            "ovmf.loader_handoff_evidence",
            "ovmf.kernel_entry_evidence",
        ),
        "The UEFI OVMF proof did not capture the kernel-owned VIBEKERN entry marker after ExitBootServices.",
        "Hand off to the UEFI boot owner: inspect the OVMF manifest markers, loader handoff attempt, and required kernel-entry flags.",
    ),
    TriageRule(
        "exec-not-attempted",
        ("execsys", "execerr", "execres", "target", "ppid", "entry", "stack", "argc", "argv", "envp", "argv0", "envp0", "doomrun"),
        "The probe never attempted the syscall exec handoff into DOOM.ELF.",
        "Inspect the user-probe completion path and the expected-fault recovery into SYS_EXEC.",
    ),
    TriageRule(
        "exec-failed",
        ("exec", "path", "execsys", "execerr", "execres", "target", "ppid", "entry", "stack", "argc", "argv", "envp", "argv0", "envp0", "doom"),
        "The kernel attempted exec, but lookup, ELF loading, argv seeding, or handoff failed.",
        "Read execerr/execres and the six execsys counters, then inspect process_exec_path/process_exec_handoff_current.",
    ),
    TriageRule(
        "doom-user-fault",
        ("doomrun", "doomfault", "doomfaultip", "doomfaultv", "doomfaulterr", "fault"),
        "Doom entered user mode and faulted before the proof completed.",
        "Symbolize doomfaultip with doom.symbols and decode the vector/error/CR2 fields.",
    ),
    TriageRule(
        "missing-wad-open-read",
        ("doomopen", "doomread", "doomwad", "doomerr", "doomerrno", "doommode", "doomlog", "wad", "lmp"),
        "Doom did not successfully open/read the WAD through the libc/syscall/FAT path.",
        "If Doom also faulted, fix the fault first; otherwise inspect path mapping and FAT read/lseek.",
    ),
    TriageRule(
        "persistence-save-write-failed",
        ("doomerrno", "doommode", "doomsav", "savewr", "saveclose", "savemode", "fwr", "fal", "fam", "fac", "fio"),
        "Doom reached the save path, but the DOOMSAV write did not complete.",
        "Inspect the persistence status, then hand off to FAT allocation/free-space or write-path repair with the fwr/fio/fal fields.",
    ),
    TriageRule(
        "persistence-save-growth-allocation-partial",
        ("doomsav", "savewr", "saveclose", "savemode", "fwr", "fal", "fam", "fac", "fio"),
        "Doom reached the save path and wrote one cluster, but save-file growth stopped at the next FAT allocation.",
        "Hand off to FAT save-growth allocation: inspect the last data cluster/free scan and why the allocator returned E0 after a short positive write.",
    ),
    TriageRule(
        "persistence-load-malformed-stream",
        ("doomsav", "saverd", "saveclose", "saveact", "savestm", "savethk", "doomerr"),
        "Doom read the saved payload back but the unarchive thinker/specials stream is malformed.",
        "Use savestm/savethk to choose thinker vs specials parsing, then inspect the save stream checker failure at that offset.",
    ),
    TriageRule(
        "persistence-load-not-completed",
        ("doomsav", "saverd", "saveclose", "saveact", "savestm", "savethk", "doomerr"),
        "Doom started the reboot load path, but did not prove G_DoLoadGame completed and returned to gameplay.",
        "Inspect saverd/saveclose/saveact first; then compare load-status with the persisted DOOMSAV size.",
    ),
    TriageRule(
        "doom-init-stalled",
        ("doominit", "doomlog", "doomopen", "doomread", "doomwad", "gameplay", "doompresent"),
        "Doom entered user mode but did not report all first initialization milestones.",
        "Decode doominit flags, then inspect the last completed platform hook and nearby Doom startup log text.",
    ),
    TriageRule(
        "frames-no-gameplay",
        ("doompresent", "doompal", "doomframe", "gameplay", "gstate", "gmap", "leveltime"),
        "Frames or palette updates happened, but Doom did not prove E1M1 gameplay.",
        "Inspect Doom startup log/state: it may be rendering a title/error/menu path rather than GS_LEVEL.",
    ),
    TriageRule(
        "input-no-effect",
        (
            "keyirq",
            "keyqueue",
            "keypoll",
            "mouseirq",
            "mousepkt",
            "mousepoll",
            "mousebtn",
            "mousedelta",
            "pflags",
            "pdelta",
            "pangle",
            "pangledelta",
            "pammo",
            "prefire",
            "gflags",
        ),
        "Keyboard or mouse events reached the OS, but scripted start/fire/move/use/menu/mouse effects were not observed.",
        "Compare early/start/fire/move/use/menu snapshots and inspect PS/2 translation plus Doom event injection.",
    ),
    TriageRule(
        "doom-timer-not-proven",
        ("ticks", "dtick", "gtic", "leveltime"),
        "Doom reached gameplay, but the status does not prove the 35 Hz Doom time base derived from PIT ticks.",
        "Inspect SYS_TIME and smoke dtick emission; dtick must equal floor(ticks * 35 / 100).",
    ),
    TriageRule(
        "preemption-not-proven",
        ("preempt", "pirq", "pattempt", "puser", "pround", "pctx", "pmask", "pfrom", "pto", "pkind", "peip", "pcr3", "pkstk", "pframe", "psegs", "peflags", "pspin", "pself"),
        "Doom reached gameplay, but the status does not prove live timer-driven switching between Ring 3 tasks.",
        "Inspect scheduler_tick, the live preempt probe seeding path, and whether timer IRQs are interrupting user code.",
    ),
    TriageRule(
        "long-run-cadence-not-proven",
        ("gtic", "leveltime", "dtick", "doompresent", "pirq", "preempt", "pattempt", "pskip", "puser", "audioirq", "refill", "musicpos", "musicpull", "inputdepth", "mixunder", "musicunder", "musicdrops"),
        "Doom reached gameplay, but the final status does not expose a complete status-only cadence picture for slowdown triage.",
        "Run the real-WAD soak with long-run cadence enabled, then inspect gameplay-proof.json long_run_cadence and the JSON soak metadata.",
    ),
    TriageRule(
        "kernel-panic",
        ("panic", "fault"),
        "The kernel recorded an unhandled non-Doom exception before halting.",
        "Decode fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall, then inspect the matching kernel path.",
    ),
    TriageRule(
        "os-shutdown-requested",
        ("shutdown", "panic", "fault"),
        "The OS recorded a halt or reboot request in the status block.",
        "Verify this came from an intentional shutdown/reboot proof lane before treating QEMU exit as a failure.",
    ),
    TriageRule(
        "ata-storage-stalled",
        ("ata", "ataop", "atawait", "atalba", "atastat", "ataerr", "atafail", "atatmo"),
        "The kernel is stuck in or has failed an ATA PIO wait before Doom produced frames.",
        "Inspect ata_wait_not_busy/ata_wait_drq/ata_wait_ready, data-port transfer state, the last LBA, and the command/status bits before widening to Doom startup.",
    ),
    TriageRule(
        "artifact-proof-failure",
        ("status.early.txt", "status.after-*.txt", "gameplay-proof.json", "audio-proof.json", "save-load-proof.json"),
        "The cloud artifact package failed even if the final status line looked plausible.",
        "Run check_cloud_playability_artifacts.py; look for missing status/JSON proof files, duplicate basenames, or forbidden payloads.",
    ),
    TriageRule(
        "playability-status-green",
        ("doomrun", "gameplay", "doompresent", "pflags", "gflags"),
        "The final status has no obvious local triage failure.",
        "Run the real-WAD, human-playability, and cloud artifact checkers before claiming playable Doom.",
    ),
)


class SymbolMap:
    def __init__(self, symbols: list[Symbol]):
        self.symbols = sorted(symbols, key=lambda symbol: (symbol.address, symbol.name))

    @classmethod
    def parse(cls, text: str) -> "SymbolMap":
        symbols: list[Symbol] = []
        for line_number, raw_line in enumerate(text.splitlines(), start=1):
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) != 7:
                raise ValueError(f"malformed symbol map line {line_number}: expected 7 tab-separated fields")
            address, size, sym_type, bind, section, obj_path, name = parts
            if not re.fullmatch(r"[0-9A-Fa-f]{8}", address):
                raise ValueError(f"malformed symbol map line {line_number}: bad address {address!r}")
            if not re.fullmatch(r"[0-9A-Fa-f]{8}", size):
                raise ValueError(f"malformed symbol map line {line_number}: bad size {size!r}")
            symbols.append(
                Symbol(
                    int(address, 16),
                    int(size, 16),
                    sym_type,
                    bind,
                    section,
                    obj_path,
                    name,
                )
            )
        if not symbols:
            raise ValueError("symbol map has no symbols")
        return cls(symbols)

    def lookup(self, address: int) -> SymbolHit | None:
        candidates = [
            symbol
            for symbol in self.symbols
            if symbol.address <= address and symbol.sym_type in ("FUNC", "NOTYPE")
        ]
        if not candidates:
            candidates = [symbol for symbol in self.symbols if symbol.address <= address]
        if not candidates:
            return None
        symbol = max(candidates, key=lambda candidate: candidate.address)
        offset = address - symbol.address
        return SymbolHit(
            symbol=symbol,
            offset=offset,
            inside_declared_size=symbol.size == 0 or offset < symbol.size,
        )


def parse_status(status: str) -> dict[str, str]:
    fields = parse_status_fields(status, error_type=ValueError)
    doomlog = DOOMLOG_FIELD_PATTERN.search(status)
    if doomlog is not None:
        fields["doomlog"] = doomlog.group(1).strip()
    return fields


def _field(fields: dict[str, str], name: str) -> str:
    return fields.get(name, "<missing>")


def _hex(fields: dict[str, str], name: str) -> int | None:
    return hex8_field(fields, name)


def _hex_nonzero(fields: dict[str, str], *names: str) -> bool:
    return any((_hex(fields, name) or 0) != 0 for name in names)


def _execsys(fields: dict[str, str]) -> tuple[int, ...] | None:
    return hex_tuple_field(fields, "execsys", len(EXECSYS_NAMES))


def _hex_pair(fields: dict[str, str], name: str) -> tuple[int, int] | None:
    value = fields.get(name)
    if value is None:
        return None
    parts = value.split(":")
    if len(parts) != 2:
        return None
    left = _parse_hex_field(parts[0])
    right = _parse_hex_field(parts[1])
    if left is None or right is None:
        return None
    return left, right


def _hex_tuple(
    fields: dict[str, str],
    name: str,
    count: int,
    sep: str = "/",
) -> tuple[int, ...] | None:
    return hex_tuple_field(fields, name, count, sep=sep)


def _exec_detail(fields: dict[str, str]) -> str:
    return (
        f"execerr={_field(fields, 'execerr')} execres={_field(fields, 'execres')} "
        f"target={_field(fields, 'target')} ppid={_field(fields, 'ppid')} entry={_field(fields, 'entry')} "
        f"stack={_field(fields, 'stack')} argc={_field(fields, 'argc')} "
        f"argv={_field(fields, 'argv')} envp={_field(fields, 'envp')} "
        f"argv0={_field(fields, 'argv0')} envp0={_field(fields, 'envp0')}"
    )


def summarize(fields: dict[str, str]) -> str:
    return summarize_status_fields(fields, SUMMARY_FIELDS)


def _parse_hex_field(value: str) -> int | None:
    return parse_hex8(value)


def _fault_tuple(fields: dict[str, str]) -> dict[str, int] | None:
    value = fields.get("fault")
    if value is None:
        return None
    parts = value.split("/")
    if len(parts) != len(FAULT_TUPLE_NAMES):
        return None
    parsed: dict[str, int] = {}
    for name, part in zip(FAULT_TUPLE_NAMES, parts):
        item = _parse_hex_field(part)
        if item is None:
            return None
        parsed[name] = item
    return parsed


def _pf_tuple(fields: dict[str, str]) -> tuple[int, int, int, int, int] | None:
    return _hex_tuple(fields, "pf", 5)


def _expected_pf_tuple(fault: dict[str, int], mode: str) -> tuple[int, int, int, int, int]:
    mode_id = {"NONE": 0, "USER": 1, "KERNEL": 2}.get(mode, 0)
    error = fault["error"]
    if error & 0x10:
        access = 3
    elif error & 0x02:
        access = 2
    else:
        access = 1
    reason = 0x00000002 if error & 0x01 else 0x00000001
    if error & 0x08:
        reason |= 0x00000004
    if error & 0x10:
        reason |= 0x00000008
    return fault["cr2"], error, mode_id, access, reason


def _format_pf_tuple(pf: tuple[int, int, int, int, int] | None) -> str:
    if pf is None:
        return "pf=<missing>"
    cr2, error, mode, access, reason = pf
    reason_names = [name for bit, name in PF_REASON_FLAGS if reason & bit]
    if not reason_names:
        reason_names = ["none"]
    return (
        f"pf={cr2:08X}/{error:08X}/"
        f"{PF_MODE_NAMES.get(mode, f'mode-{mode}')}/"
        f"{PF_ACCESS_NAMES.get(access, f'access-{access}')}/"
        f"{'+'.join(reason_names)}"
    )


def _looks_like_full_runtime_status(fields: dict[str, str]) -> bool:
    return any(
        name in fields
        for name in (
            "exec",
            "doomrun",
            "e820",
            "pmm",
            "biosboot",
            "clocksrc",
            "faultsrc",
            "kblock",
            "ksleep",
        )
    )


def _bios_handoff_issue(fields: dict[str, str]) -> str | None:
    if fields.get("uefi") == "OK":
        return None
    if not _looks_like_full_runtime_status(fields):
        return None
    if fields.get("biosboot") != "OK":
        return f"biosboot={_field(fields, 'biosboot')} is not OK"
    flags = _hex(fields, "biosflags")
    entry = _hex_tuple(fields, "biosentry", 2)
    if flags is None:
        return f"biosflags={_field(fields, 'biosflags')} is missing or malformed"
    if flags & BIOS_BOOT_REQUIRED_FLAGS != BIOS_BOOT_REQUIRED_FLAGS:
        return "biosflags missing Stage 2/E820/A20/GDT/protected-mode/ELF/entry coverage bits"
    if flags & BIOS_BOOT_DISK_FLAGS == 0:
        return "biosflags missing BIOS disk-read evidence"
    if flags & BIOS_BOOT_VIDEO_FLAGS == 0:
        return "biosflags missing BIOS video handoff evidence"
    if entry is None:
        return f"biosentry={_field(fields, 'biosentry')} is missing or malformed"
    if entry[0] != KERNEL_ENTRY:
        return f"biosentry entry {entry[0]:08X} does not match linked kernel entry {KERNEL_ENTRY:08X}"
    if entry[1] == 0:
        return "biosentry does not report a loaded ELF segment"
    return None


def _fault_containment_issue(fields: dict[str, str]) -> str | None:
    if not _looks_like_full_runtime_status(fields):
        return None
    source = fields.get("faultsrc")
    mode = fields.get("faultmode")
    contain = _hex_tuple(fields, "faultcontain", 5)
    fault = _fault_tuple(fields)
    pf = _pf_tuple(fields)
    regs = _hex_tuple(fields, "regs", 8)
    segs = _hex_tuple(fields, "segs", 6)
    proc = _hex_tuple(fields, "proc", 9)
    if source is None or mode is None or contain is None or fault is None or pf is None:
        return (
            f"faultsrc={_field(fields, 'faultsrc')} faultmode={_field(fields, 'faultmode')} "
            f"faultcontain={_field(fields, 'faultcontain')} fault={_field(fields, 'fault')} "
            f"pf={_field(fields, 'pf')}"
        )
    if regs is None or segs is None or proc is None:
        return (
            f"regs={_field(fields, 'regs')} segs={_field(fields, 'segs')} "
            f"proc={_field(fields, 'proc')} is missing or malformed"
        )
    if source not in {"NONE", "EXPECT", "USER", "DOOM", "KERNEL"}:
        return f"unknown faultsrc={source}"
    if mode not in {"NONE", "USER", "KERNEL"}:
        return f"unknown faultmode={mode}"
    expected_recovered, user_contained, doom_contained, kernel_panics, last_contained = contain
    if source == "NONE":
        if mode != "NONE":
            return "faultsrc=NONE must pair with faultmode=NONE"
        if last_contained != 0:
            return "faultsrc=NONE must not report a last-contained fault"
        if any(fault.values()):
            return "faultsrc=NONE must keep compact fault fields zero"
        if any(pf):
            return "faultsrc=NONE must keep page-fault classification zero"
        return None
    if source == "KERNEL":
        if mode != "KERNEL":
            return "kernel exceptions must report faultmode=KERNEL"
        if last_contained != 0:
            return "kernel exceptions must not be reported as contained"
        if kernel_panics == 0 or fields.get("panic") != "KEXC":
            return "kernel exception status must increment kernel panic count and set panic=KEXC"
    elif mode != "USER" or last_contained != 1:
        return "contained user faults must report faultmode=USER and last-contained=1"
    if fault["vector"] == 0x0E:
        expected_pf = _expected_pf_tuple(fault, mode)
        if pf != expected_pf:
            return (
                "pf does not mirror page-fault CR2/error/mode/access/reason: "
                f"{_format_pf_tuple(pf)} expected={_format_pf_tuple(expected_pf)}"
            )
    elif any(pf):
        return "pf must be zero when fault vector is not a page fault"
    if regs[7] == 0:
        return "regs missing EFLAGS snapshot"
    if segs[4] != fault["cs"] or segs[5] != fault["ss"]:
        return "segs CS/SS do not mirror the compact fault frame"
    if source in {"EXPECT", "USER", "DOOM"} and (proc[0] == 0 or proc[8] == 0):
        return "proc missing process pointer/CR3 for contained Ring 3 fault"
    if source == "KERNEL":
        return None
    if source == "EXPECT" and expected_recovered == 0:
        return "expected recovered fault count is zero"
    if source == "USER" and user_contained == 0:
        return "generic user containment count is zero"
    if source == "DOOM":
        if doom_contained == 0:
            return "Doom containment count is zero"
        if fields.get("doomrun") != "FAULT":
            return "faultsrc=DOOM must pair with doomrun=FAULT"
    return None


def _kernel_blocking_issue(fields: dict[str, str]) -> str | None:
    if not _looks_like_full_runtime_status(fields):
        return None
    abi_pid = _hex(fields, "abipid") or _hex(fields, "target")
    block = _hex_tuple(fields, "kblock", 9)
    sleep = _hex_tuple(fields, "ksleep", 9)
    if block is None:
        return f"kblock={_field(fields, 'kblock')} is missing or malformed"
    if sleep is None:
        return f"ksleep={_field(fields, 'ksleep')} is missing or malformed"
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
    ) = block
    if block_attempts < 2 or block_transitions < 2 or block_wakeups < 2:
        return "kblock does not prove multiple block transitions and wakeups"
    if block_failures != 0:
        return "kblock reports failed block attempts"
    if abi_pid is not None and (block_last_pid != abi_pid or block_last_woken_pid != abi_pid):
        return "kblock last blocker/woken PID does not match the ABI probe"
    if block_last_reason != PROC_BLOCK_WAITPID or block_last_wake_reason != PROC_BLOCK_WAITPID:
        return "kblock does not prove waitpid used the generic block/wake path"
    if block_last_object in (0, 0xFFFFFFFF):
        return "kblock does not record a waited child object"

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
    ) = sleep
    if sleep_attempts == 0 or sleep_blocks == 0 or sleep_wakeups == 0:
        return "ksleep does not prove SYS_SLEEP_TICKS blocked and woke through PIT"
    if sleep_failures != 0:
        return "ksleep reports failed sleep attempts"
    if abi_pid is not None and (sleep_last_pid != abi_pid or sleep_last_woken_pid != abi_pid):
        return "ksleep last sleeper/woken PID does not match the ABI probe"
    if sleep_last_until == 0 or sleep_last_ticks == 0:
        return "ksleep does not record a wake deadline"
    return None


def _decode_page_fault_error(error: int) -> str:
    flags = [name for bit, name in PAGE_FAULT_ERROR_BITS if error & (1 << bit)]
    if error & 0x01:
        presence = "protection violation"
    else:
        presence = "not-present page"
    if not flags:
        return f"{presence}, supervisor read"
    return f"{presence}, " + ", ".join(flags)


def _exception_summary(vector: int | None, error: int | None) -> str:
    if vector is None:
        return "vector=<missing>"
    name = VECTOR_NAMES.get(vector, f"vector-{vector:#x}")
    if error is None:
        return f"vector={vector:02X} ({name}) error=<missing>"
    if vector == 0x0E:
        return f"vector={vector:02X} ({name}) error={error:08X} ({_decode_page_fault_error(error)})"
    return f"vector={vector:02X} ({name}) error={error:08X}"


def _format_symbol_hit(address: int, hit: SymbolHit | None) -> str:
    if hit is None:
        return f"symbol: no symbol at or before {address:08X}"
    symbol = hit.symbol
    location = f"{symbol.name}+0x{hit.offset:X}"
    if hit.offset == 0:
        location = symbol.name
    if symbol.size and not hit.inside_declared_size:
        location += " (nearest preceding symbol; EIP is outside declared size)"
    return (
        f"symbol: {address:08X} -> {location} "
        f"[{symbol.sym_type} {symbol.bind} {symbol.section} {symbol.obj_path}]"
    )


def load_symbol_map(path: Path) -> SymbolMap:
    return SymbolMap.parse(path.read_text(encoding="ascii"))


def infer_symbol_map_path(status_path: Path | None, explicit: Path | None) -> Path | None:
    if explicit is not None:
        return explicit
    candidates: list[Path] = []
    if status_path is not None:
        candidates.extend(
            (
                status_path.with_name("doom.symbols"),
                status_path.parent / "build" / "doom.symbols",
            )
        )
    candidates.append(Path("build") / "doom.symbols")
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def render_doom_fault_context(fields: dict[str, str], symbol_map_path: Path | None) -> list[str]:
    lines: list[str] = []
    vector = _hex(fields, "doomfaultv")
    error = _hex(fields, "doomfaulterr")
    eip = _hex(fields, "doomfaultip")
    cr2 = _hex(fields, "doomfault")
    lines.append(
        "fault-decode: "
        f"{_exception_summary(vector, error)} "
        f"eip={_field(fields, 'doomfaultip')} cr2={_field(fields, 'doomfault')}"
    )
    tuple_fields = _fault_tuple(fields)
    if tuple_fields is not None and tuple_fields.get("vector", 0) != 0:
        lines.append(
            "kernel-fault-tuple: "
            + " ".join(f"{name}={value:08X}" for name, value in tuple_fields.items())
        )
    pf = _pf_tuple(fields)
    if pf is not None and any(pf):
        lines.append("page-fault: " + _format_pf_tuple(pf))
    regs = _hex_tuple(fields, "regs", 8)
    if regs is not None and any(regs):
        lines.append(
            "registers: "
            + " ".join(
                f"{name}={value:08X}"
                for name, value in zip(("eax", "ebx", "ecx", "edx", "esi", "edi", "ebp", "eflags"), regs)
            )
        )
    segs = _hex_tuple(fields, "segs", 6)
    proc = _hex_tuple(fields, "proc", 9)
    if segs is not None and any(segs):
        lines.append(
            "segments: "
            + " ".join(
                f"{name}={value:08X}" for name, value in zip(("ds", "es", "fs", "gs", "cs", "ss"), segs)
            )
        )
    if proc is not None and any(proc):
        lines.append(
            "process: "
            + " ".join(
                f"{name}={value:08X}"
                for name, value in zip(
                    ("ptr", "base", "end", "brk", "heap_start", "heap_end", "stack_top", "entry", "cr3"),
                    proc,
                )
            )
        )
    if cr2 is not None and eip is not None and cr2 == eip and vector == 0x0E:
        lines.append("fault-hint: page fault tried to fetch or touch the faulting EIP page")
    if symbol_map_path is None:
        lines.append(
            "symbol: no doom.symbols map found; pass --doom-symbols or keep a local build directory"
        )
        return lines
    try:
        symbol_map = load_symbol_map(symbol_map_path)
    except (OSError, ValueError) as exc:
        lines.append(f"symbol: failed to read {symbol_map_path}: {exc}")
        return lines
    if eip is None:
        lines.append("symbol: doomfaultip is missing or malformed")
    else:
        lines.append(_format_symbol_hit(eip, symbol_map.lookup(eip)))
    return lines


def render_wad_io_context(fields: dict[str, str]) -> list[str]:
    lines = [
        "wad-io: "
        f"doomopen={_field(fields, 'doomopen')} doomread={_field(fields, 'doomread')} "
        f"doomwad={_field(fields, 'doomwad')} "
        f"doomseek={_field(fields, 'doomseek')} doomclose={_field(fields, 'doomclose')} "
        f"doomerr={_field(fields, 'doomerr')} doomerrno={_field(fields, 'doomerrno')} "
        f"doommode={_field(fields, 'doommode')} "
        f"doomlog={_field(fields, 'doomlog')}",
        "wad-source: "
        f"kernel_wad={_field(fields, 'wad')} lump_probe={_field(fields, 'lmp')} "
        f"exec_path={_field(fields, 'path')}",
    ]
    if fields.get("wad") == "OK" and fields.get("lmp") == "OK":
        lines.append(
            "wad-hint: disk image and WAD fixture were visible; focus Doom libc path mapping, fd state, FAT seek/read, or filename case"
        )
    else:
        lines.append(
            "wad-hint: kernel WAD/lump probes are not green; inspect FAT root lookup and WAD directory loading before Doom libc"
        )
    return lines


def _status_nonzero_or_error(fields: dict[str, str], name: str) -> bool:
    value = _hex(fields, name)
    return value is not None and value != 0


def _persistence_save_write_failed(fields: dict[str, str]) -> bool:
    doomsav = _hex_tuple(fields, "doomsav", 2)
    savewr = _hex_tuple(fields, "savewr", 2)
    saveclose = _hex(fields, "saveclose")
    fwr = _hex_tuple(fields, "fwr", 11)
    fal = _hex_tuple(fields, "fal", 4)
    fio = _hex_tuple(fields, "fio", 20)

    save_slot_seen = doomsav is not None and doomsav[1] != 0xFFFFFFFF
    save_write_missing = savewr is not None and (savewr[0] == 0 or savewr[1] == 0)
    partial_save_growth_failed = _persistence_save_growth_allocation_partial(fields)
    file_write_failed = (
        fwr is not None
        and (fwr[1] & 0x80000000) != 0
        and fwr[2] != 0
    )
    fat_alloc_failed = fal is not None and fal[0] in (0xE0, 0xE1)
    file_io_failed = fio is not None and (fio[0] != 0 or fio[14] != 0)

    return (
        save_slot_seen
        and (save_write_missing or partial_save_growth_failed)
        and (
            _status_nonzero_or_error(fields, "doomerrno")
            or file_write_failed
            or fat_alloc_failed
            or file_io_failed
            or (saveclose is not None and saveclose != 0)
        )
    )


def _persistence_save_growth_allocation_partial(fields: dict[str, str]) -> bool:
    doomsav = _hex_tuple(fields, "doomsav", 2)
    savewr = _hex_tuple(fields, "savewr", 2)
    fwr = _hex_tuple(fields, "fwr", 11)
    fal = _hex_tuple(fields, "fal", 4)
    fio = _hex_tuple(fields, "fio", 20)
    if doomsav is None or doomsav[1] == 0xFFFFFFFF:
        return False
    if savewr is None or savewr[0] == 0 or savewr[1] == 0:
        return False
    if fwr is None or fal is None or fio is None:
        return False

    write_result = fwr[1]
    requested = fwr[9]
    if write_result == 0 or write_result >= requested:
        return False
    if write_result != savewr[0]:
        return False

    fat_allocator_failed_after_refresh = fal[0] == 0xE0 and fal[3] != 0
    file_io_reached_allocation = fio[14] != 0
    return fat_allocator_failed_after_refresh and file_io_reached_allocation


def _save_action(fields: dict[str, str]) -> tuple[int, int, int, int] | None:
    return _hex_tuple(fields, "saveact", 4)


def _save_stream(fields: dict[str, str]) -> tuple[int, int, int, int, int] | None:
    return _hex_tuple(fields, "savestm", 5)


def _save_thinker(fields: dict[str, str]) -> tuple[int, int, int, int] | None:
    return _hex_tuple(fields, "savethk", 4)


def _save_stage_name(stage: int) -> str:
    return SAVE_STAGE_NAMES.get(stage, f"unknown-stage-0x{stage:X}")


def _save_stream_next_byte(value: int) -> int:
    return (value >> 24) & 0xFF


def _save_stream_load_meaningful(savestm: tuple[int, int, int, int, int] | None) -> bool:
    if savestm is None:
        return False
    stage, slot, offset, _value, reports = savestm
    return (
        reports != 0
        and stage in SAVE_LOAD_STREAM_STAGES
        and slot != SAVE_STREAM_UNSET_OFFSET
        and offset != SAVE_STREAM_UNSET_OFFSET
    )


def _save_thinker_load_meaningful(savethk: tuple[int, int, int, int] | None) -> bool:
    if savethk is None:
        return False
    _archive_offset, _archive_value, unarchive_offset, _unarchive_value = savethk
    return unarchive_offset not in (0, SAVE_STREAM_UNSET_OFFSET)


def _doomlog_unknown_tclass(status: str | None) -> int | None:
    if status is None:
        return None
    match = UNKNOWN_TCLASS_PATTERN.search(status)
    if match is None:
        return None
    return int(match.group(1), 10)


def _status_unknown_tclass(fields: dict[str, str]) -> tuple[int, str] | None:
    savestm = _save_stream(fields)
    if _save_stream_load_meaningful(savestm):
        stage, _slot, _offset, value, _reports = savestm
        next_byte = _save_stream_next_byte(value)
        if stage == SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE and next_byte not in VALID_THINKER_CLASSES:
            return next_byte, "savestm"
        if stage == SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE and next_byte not in VALID_SPECIAL_CLASSES:
            return next_byte, "savestm"

    savethk = _save_thinker(fields)
    if _save_thinker_load_meaningful(savethk):
        _archive_offset, _archive_value, _unarchive_offset, unarchive_value = savethk
        next_byte = _save_stream_next_byte(unarchive_value)
        if next_byte not in VALID_THINKER_CLASSES:
            return next_byte, "savethk"

    return None


def _persistence_load_attempted(fields: dict[str, str]) -> bool:
    doomsav = _hex_tuple(fields, "doomsav", 2)
    saverd = _hex_tuple(fields, "saverd", 2)
    saveact = _save_action(fields)
    savestm = _save_stream(fields)
    savethk = _save_thinker(fields)
    return (
        (doomsav is not None and (doomsav[0] & SAVELOAD_EVENT_READ) != 0)
        or (saverd is not None and (saverd[0] != 0 or saverd[1] != 0))
        or (saveact is not None and (saveact[0] & SAVEACTION_LOAD_REQUESTED) != 0)
        or _save_stream_load_meaningful(savestm)
        or _save_thinker_load_meaningful(savethk)
    )


def _persistence_load_completed(fields: dict[str, str]) -> bool:
    saveact = _save_action(fields)
    if saveact is None:
        return False
    flags, gameaction, _slot, reports = saveact
    return (
        (flags & (SAVEACTION_LOAD_REQUESTED | SAVEACTION_LOAD_DONE))
        == (SAVEACTION_LOAD_REQUESTED | SAVEACTION_LOAD_DONE)
        and gameaction == 0
        and reports != 0
        and fields.get("gameplay") == "OK"
    )


def _load_stream_reached_final_marker(fields: dict[str, str]) -> bool:
    savestm = _save_stream(fields)
    return (
        _save_stream_load_meaningful(savestm)
        and savestm[0] == SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER
        and _save_stream_next_byte(savestm[3]) == 0x1D
    )


def _load_done_before_post_tic(fields: dict[str, str]) -> bool:
    saveact = _save_action(fields)
    return (
        saveact is not None
        and (saveact[0] & SAVEACTION_LOAD_DONE) != 0
        and saveact[1] != 0
    )


def _malformed_load_stream_kind(fields: dict[str, str]) -> str | None:
    savestm = _save_stream(fields)
    if _save_stream_load_meaningful(savestm):
        stage, _slot, _offset, value, reports = savestm
        next_byte = _save_stream_next_byte(value)
        if reports != 0 and stage == SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE and next_byte not in VALID_THINKER_CLASSES:
            return "thinker"
        if reports != 0 and stage == SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE and next_byte not in VALID_SPECIAL_CLASSES:
            return "specials"

    savethk = _save_thinker(fields)
    doom_error = (_hex(fields, "doomerr") or 0) != 0 or fields.get("doomrun") == "EXIT"
    if doom_error and _save_thinker_load_meaningful(savethk):
        archive_offset, _archive_value, unarchive_offset, unarchive_value = savethk
        unarchive_next = _save_stream_next_byte(unarchive_value)
        if unarchive_offset not in (0, SAVE_STREAM_UNSET_OFFSET) and unarchive_next not in VALID_THINKER_CLASSES:
            return "thinker"
        if archive_offset not in (0, SAVE_STREAM_UNSET_OFFSET) and unarchive_offset not in (0, SAVE_STREAM_UNSET_OFFSET):
            return "stream"
    if doom_error and _save_stream_load_meaningful(savestm):
        stage = savestm[0]
        if stage == SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE:
            return "thinker"
        if stage == SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE:
            return "specials"
        if stage == SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER:
            return None
        if stage == SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED:
            return "stream"
    return None


def _persistence_load_malformed_stream(fields: dict[str, str]) -> bool:
    return _persistence_load_attempted(fields) and _malformed_load_stream_kind(fields) is not None


def _persistence_load_not_completed(fields: dict[str, str]) -> bool:
    if not _persistence_load_attempted(fields):
        return False
    if _persistence_load_malformed_stream(fields):
        return False
    saveclose = _hex(fields, "saveclose")
    saverd = _hex_tuple(fields, "saverd", 2)
    saveact = _save_action(fields)
    doomsav = _hex_tuple(fields, "doomsav", 2)
    missing_close = saveclose is not None and saveclose == 0
    incomplete_read_close_flags = doomsav is not None and (doomsav[0] & SAVELOAD_EVENT_CLOSE) == 0
    missing_done = saveact is not None and (
        (saveact[0] & SAVEACTION_LOAD_DONE) == 0 or saveact[1] != 0 or saveact[3] == 0
    )
    missing_read = saverd is not None and (saverd[0] == 0 or saverd[1] == 0)
    return (
        missing_close
        or incomplete_read_close_flags
        or missing_done
        or missing_read
        or not _persistence_load_completed(fields)
    )


def render_persistence_load_context(fields: dict[str, str], status: str | None = None) -> list[str]:
    kind = _malformed_load_stream_kind(fields)
    prefix = "persistence-load-malformed-stream" if kind is not None else "persistence-load-not-completed"
    lines = [
        f"{prefix}: "
        f"kind={kind or '<none>'} doomerr={_field(fields, 'doomerr')} doomrun={_field(fields, 'doomrun')} "
        f"doomsav={_field(fields, 'doomsav')} saverd={_field(fields, 'saverd')} "
        f"saveclose={_field(fields, 'saveclose')} saveact={_field(fields, 'saveact')} "
        f"savestm={_field(fields, 'savestm')} savethk={_field(fields, 'savethk')}",
    ]
    savestm = _save_stream(fields)
    if savestm is not None:
        stage, slot, offset, value, reports = savestm
        lines.append(
            "persistence-load-stream: "
            f"stage=0x{stage:X}({_save_stage_name(stage)}) slot={slot} offset=0x{offset:X} "
            f"value=0x{value:X} next_byte=0x{_save_stream_next_byte(value):02X} reports={reports}"
        )
    savethk = _save_thinker(fields)
    if savethk is not None:
        archive_offset, archive_value, unarchive_offset, unarchive_value = savethk
        lines.append(
            "persistence-load-thinkers: "
            f"archive_offset=0x{archive_offset:X} archive_value=0x{archive_value:X} "
            f"unarchive_offset=0x{unarchive_offset:X} unarchive_value=0x{unarchive_value:X} "
            f"unarchive_next_byte=0x{_save_stream_next_byte(unarchive_value):02X}"
        )
    status_unknown_tclass = _status_unknown_tclass(fields)
    if status_unknown_tclass is not None:
        value, source = status_unknown_tclass
        lines.append(
            f"persistence-status: unknown_tclass={value} (0x{value:02X}) from {source}"
        )
    unknown_tclass = _doomlog_unknown_tclass(status)
    if unknown_tclass is not None:
        lines.append(
            f"persistence-doomlog: unknown_tclass={unknown_tclass} (0x{unknown_tclass:02X})"
        )
    if kind == "specials":
        lines.append("persistence-hint: malformed specials stream; run the save image checker with the savestm offset")
    elif kind == "thinker":
        lines.append("persistence-hint: malformed thinker stream; run the save image checker with the savethk/savestm offset")
    elif kind == "stream":
        lines.append("persistence-hint: thinker boundary was reported, but the next load stream still failed")
    elif _load_stream_reached_final_marker(fields) and _load_done_before_post_tic(fields):
        lines.append(
            "persistence-hint: load-done was sampled before post-load ga_nothing; "
            "the Doom port must delay load completion until a later playable level tick"
        )
    elif _load_stream_reached_final_marker(fields):
        lines.append(
            "persistence-hint: post-load completion state; Doom returned from P_UnArchiveSpecials "
            "with the final marker next, so inspect saveact gameaction/load-done and post-load gameplay"
        )
    else:
        lines.append("persistence-hint: load-not-completed; saveact must include load requested and load done with ga_nothing")
    return lines


def render_persistence_save_context(fields: dict[str, str]) -> list[str]:
    lines = [
        "persistence-save: "
        f"doomerrno={_field(fields, 'doomerrno')} doommode={_field(fields, 'doommode')} "
        f"doomsav={_field(fields, 'doomsav')} savewr={_field(fields, 'savewr')} "
        f"saveclose={_field(fields, 'saveclose')} savemode={_field(fields, 'savemode')} "
        f"saveact={_field(fields, 'saveact')} savedesc={_field(fields, 'savedesc')}",
        "persistence-write-debug: "
        f"fwr={_field(fields, 'fwr')} fio={_field(fields, 'fio')} "
        f"fal={_field(fields, 'fal')} fam={_field(fields, 'fam')} "
        f"fac={_field(fields, 'fac')} flb={_field(fields, 'flb')} fcl={_field(fields, 'fcl')}",
    ]
    fal = _hex_tuple(fields, "fal", 4)
    fio = _hex_tuple(fields, "fio", 20)
    fwr = _hex_tuple(fields, "fwr", 11)
    savewr = _hex_tuple(fields, "savewr", 2)
    if fwr is not None and savewr is not None and 0 < fwr[1] < fwr[9]:
        lines.append(
            "persistence-short-write: "
            f"wrote={savewr[0]:#x} write_count={savewr[1]:#x} "
            f"requested={fwr[9]:#x} result={fwr[1]:#x}"
        )
    if _persistence_save_growth_allocation_partial(fields) and fwr is not None and savewr is not None:
        lines.append(
            "persistence-partial-save: "
            f"wrote={savewr[0]:#x} write_count={savewr[1]:#x} requested={fwr[9]:#x} "
            f"short_write={fwr[1]:#x}"
        )
    if fal is not None and fal[0] == 0xE0:
        lines.append(
            "persistence-hint: FAT allocation exhausted after a cache refresh while growing the save file"
        )
    if fio is not None and fio[14] != 0:
        lines.append(
            "persistence-hint: file_write reached cluster allocation; inspect FAT free-cluster budget and dynamic allocation"
        )
    return lines


def render_doom_init_context(fields: dict[str, str]) -> list[str]:
    init = _hex_tuple(fields, "doominit", 2)
    if init is None:
        return ["doom-init: doominit field is missing or malformed"]
    flags, reports = init
    missing = REQUIRED_DOOM_INIT_FLAGS & ~flags
    return [
        f"doom-init: flags={flags:08X} reports={reports:08X} required={REQUIRED_DOOM_INIT_FLAGS:08X}",
        f"doom-init-missing: {missing:08X}",
    ]


def _long_run_missing_fields(fields: dict[str, str]) -> list[str]:
    missing = [
        name
        for name in LONG_RUN_REQUIRED_FIELDS
        if _hex(fields, name) is None
    ]
    for name, count, sep in LONG_RUN_REQUIRED_TUPLES:
        if _hex_tuple(fields, name, count, sep=sep) is None:
            missing.append(name)
    return missing


def _long_run_cadence_issue(fields: dict[str, str]) -> str | None:
    missing = _long_run_missing_fields(fields)
    if missing:
        return "missing or malformed cadence fields: " + ", ".join(missing)

    core = ("gtic", "leveltime", "dtick", "doompresent")
    zero_core = [name for name in core if (_hex(fields, name) or 0) == 0]
    if zero_core:
        return "zero Doom/frame cadence fields: " + ", ".join(zero_core)

    scheduler = ("pirq", "preempt", "pattempt", "puser")
    zero_scheduler = [name for name in scheduler if (_hex(fields, name) or 0) == 0]
    if zero_scheduler:
        return "zero scheduler cadence fields: " + ", ".join(zero_scheduler)

    audio = ("audioirq", "refill", "musicpos")
    zero_audio = [name for name in audio if (_hex(fields, name) or 0) == 0]
    musicpull = _hex_tuple(fields, "musicpull", 2, sep=":")
    if musicpull is not None and musicpull[1] == 0:
        zero_audio.append("musicpull.refills")
    if zero_audio:
        return "zero SB16/music cadence fields: " + ", ".join(zero_audio)

    inputdepth = _hex_tuple(fields, "inputdepth", 2, sep=":")
    if inputdepth is not None and inputdepth[1] != 0:
        return f"input queue drops recorded: inputdepth={_field(fields, 'inputdepth')}"

    pressure = [
        name
        for name in ("mixunder", "musicunder", "musicdrops")
        if (_hex(fields, name) or 0) != 0
    ]
    if pressure:
        return "audio pressure counters are nonzero: " + ", ".join(pressure)

    return None


def render_long_run_cadence_context(fields: dict[str, str]) -> list[str]:
    issue = _long_run_cadence_issue(fields)
    prefix = "long-run-cadence-not-proven" if issue is not None else "long-run-cadence"
    lines = [
        f"{prefix}: "
        f"gtic={_field(fields, 'gtic')} leveltime={_field(fields, 'leveltime')} "
        f"dtick={_field(fields, 'dtick')} doompresent={_field(fields, 'doompresent')} "
        f"fbcap={_field(fields, 'fbcap')} fbsrc={_field(fields, 'fbsrc')} "
        f"fbacct={_field(fields, 'fbacct')} fbpresent={_field(fields, 'fbpresent')} "
        f"pirq={_field(fields, 'pirq')} preempt={_field(fields, 'preempt')} "
        f"pattempt={_field(fields, 'pattempt')} pskip={_field(fields, 'pskip')} "
        f"puser={_field(fields, 'puser')} audioirq={_field(fields, 'audioirq')} "
        f"refill={_field(fields, 'refill')} musicpos={_field(fields, 'musicpos')} "
        f"musicpull={_field(fields, 'musicpull')} pcmstream={_field(fields, 'pcmstream')} "
        f"pcmwrite={_field(fields, 'pcmwrite')} pcmqueue={_field(fields, 'pcmqueue')} "
        f"pcmpull={_field(fields, 'pcmpull')} "
        f"pcmirq={_field(fields, 'pcmirq')} pcmdma={_field(fields, 'pcmdma')} "
        f"inputdepth={_field(fields, 'inputdepth')} "
        f"mixunder={_field(fields, 'mixunder')} musicunder={_field(fields, 'musicunder')} "
        f"musicdrops={_field(fields, 'musicdrops')}"
    ]
    if issue is None:
        lines.append(
            "long-run-hint: final status has the required cadence counters; use "
            "gameplay-proof.json long_run_cadence for phase-to-phase deltas"
        )
    else:
        lines.append(f"long-run-hint: {issue}")
    return lines


def _parse_uefi_manifest(text: str) -> dict[str, object] | None:
    try:
        parsed = json.loads(text)
    except json.JSONDecodeError:
        return None
    if not isinstance(parsed, dict):
        return None
    if parsed.get("schema") != "uefi-ovmf-cloud-proof-v1":
        return None
    return parsed


def _uefi_hex(value: object) -> int | None:
    if not isinstance(value, str):
        return None
    try:
        return int(value, 16)
    except ValueError:
        return None


def _uefi_kernel_entry_issue(ovmf: dict[str, object]) -> str | None:
    if ovmf.get("exit_boot_services") is not True:
        return "ExitBootServices did not complete"
    if ovmf.get("kernel_handoff_after_exit_boot_services") is not True:
        return "loader did not record a kernel handoff attempt after ExitBootServices"
    loader_evidence = ovmf.get("loader_handoff_evidence")
    if not isinstance(loader_evidence, dict):
        return "loader_handoff_evidence is missing"
    if loader_evidence.get("step") != "kernel-handoff" or loader_evidence.get("status") != "attempting":
        return "loader_handoff_evidence is not the bounded kernel-handoff marker"
    for key, expected in UEFI_LOADER_REQUIRED_HANDOFF_FIELDS.items():
        value = _uefi_hex(loader_evidence.get(key))
        if value != expected:
            return f"loader_handoff_evidence.{key}={loader_evidence.get(key)!r} does not match 0x{expected:08X}"
    for key in ("entry32", "segments"):
        value = _uefi_hex(loader_evidence.get(key))
        if value is None or value == 0:
            return f"loader_handoff_evidence.{key} is missing or zero"
    loader_flags = _uefi_hex(loader_evidence.get("flags"))
    if loader_flags is None or loader_flags & UEFI_REQUIRED_HANDOFF_FLAG_MASK != UEFI_REQUIRED_HANDOFF_FLAG_MASK:
        return f"loader_handoff_evidence.flags={loader_evidence.get('flags')!r} misses required handoff bits"
    if ovmf.get("kernel_entry_after_exit_boot_services") is not True:
        return "kernel-owned marker was not captured after ExitBootServices"
    if ovmf.get("kernel_booted") is not True or ovmf.get("kernel_entry_status") != "OK":
        return "kernel_booted/kernel_entry_status are not green"
    evidence = ovmf.get("kernel_entry_evidence")
    if not isinstance(evidence, dict):
        return "kernel_entry_evidence is missing"
    for key, expected in {"handoff": 0x9000, "bootinfo": 0x7000, "e820": 0x7100}.items():
        value = _uefi_hex(evidence.get(key))
        if value != expected:
            return f"kernel_entry_evidence.{key}={evidence.get(key)!r} does not match 0x{expected:08X}"
    for key in ("entry", "segments"):
        value = _uefi_hex(evidence.get(key))
        if value is None or value == 0:
            return f"kernel_entry_evidence.{key} is missing or zero"
    flags = _uefi_hex(evidence.get("flags"))
    if flags is None or flags & UEFI_REQUIRED_HANDOFF_FLAG_MASK != UEFI_REQUIRED_HANDOFF_FLAG_MASK:
        return f"kernel_entry_evidence.flags={evidence.get('flags')!r} misses required handoff bits"
    return None


def render_uefi_manifest_diagnosis(manifest: dict[str, object]) -> str:
    ovmf = manifest.get("ovmf")
    if not isinstance(ovmf, dict):
        ovmf = {}
    issue = _uefi_kernel_entry_issue(ovmf)
    primary = "uefi-marker-not-proven" if issue is not None else "uefi-marker-green"
    lines = [
        f"primary: {primary}",
        "summary: "
        f"mode={manifest.get('mode', '<missing>')} "
        f"support_claim={manifest.get('support_claim', '<missing>')} "
        f"proof={ovmf.get('proof', '<missing>')} "
        f"exit_boot_services={ovmf.get('exit_boot_services', '<missing>')} "
        f"kernel_handoff_after_exit_boot_services={ovmf.get('kernel_handoff_after_exit_boot_services', '<missing>')} "
        f"kernel_entry_after_exit_boot_services={ovmf.get('kernel_entry_after_exit_boot_services', '<missing>')} "
        f"kernel_booted={ovmf.get('kernel_booted', '<missing>')} "
        f"kernel_entry_status={ovmf.get('kernel_entry_status', '<missing>')}",
    ]
    if issue is None:
        lines.append("- uefi-marker-green: OVMF captured the kernel-owned VIBEKERN entry marker after ExitBootServices")
    else:
        lines.append(f"- uefi-marker-not-proven: {issue}")
        lines.append(
            "- uefi-marker-context: "
            f"last_step={ovmf.get('handoff_step_reached', '<missing>')} "
            f"proof_step={ovmf.get('proof_step_reached', '<missing>')} "
            f"kernel_handoff={ovmf.get('kernel_handoff', '<missing>')} "
            f"loader_handoff_evidence={ovmf.get('loader_handoff_evidence', {})} "
            f"kernel_entry_evidence={ovmf.get('kernel_entry_evidence', {})}"
        )
    rule = next((candidate for candidate in TRIAGE_RULES if candidate.name == "uefi-marker-not-proven"), None)
    if rule is not None and issue is not None:
        lines.append(f"next: {rule.next_step}")
    return "\n".join(lines)


def classify(fields: dict[str, str]) -> tuple[str, list[str]]:
    notes: list[str] = []
    execsys = _execsys(fields)
    doomrun = fields.get("doomrun")
    panic = fields.get("panic")
    shutdown = fields.get("shutdown")

    if panic not in (None, "NONE"):
        notes.append(f"kernel-panic: panic={panic} fault={_field(fields, 'fault')}")
        return "kernel-panic", notes

    if shutdown not in (None, "NONE"):
        notes.append(f"os-shutdown-requested: shutdown={shutdown} panic={_field(fields, 'panic')}")
        return "os-shutdown-requested", notes

    bios_issue = _bios_handoff_issue(fields)
    if bios_issue is not None:
        notes.append(
            "bios-handoff-not-proven: "
            f"{bios_issue}; biosboot={_field(fields, 'biosboot')} "
            f"biosflags={_field(fields, 'biosflags')} biosentry={_field(fields, 'biosentry')}"
        )
        return "bios-handoff-not-proven", notes

    fault_issue = _fault_containment_issue(fields)
    if fault_issue is not None:
        notes.append(
            "fault-containment-not-proven: "
            f"{fault_issue}; faultsrc={_field(fields, 'faultsrc')} "
            f"faultmode={_field(fields, 'faultmode')} "
            f"faultcontain={_field(fields, 'faultcontain')} fault={_field(fields, 'fault')}"
        )
        return "fault-containment-not-proven", notes

    ata_wait = fields.get("atawait")
    ata_failures = _hex(fields, "atafail") or 0
    ata_timeouts = _hex(fields, "atatmo") or 0
    ata_active_before_frames = (
        ata_wait in ("BUSY", "DRQ", "READY", "DATA")
        and fields.get("gameplay") != "OK"
        and not _hex_nonzero(fields, "doompresent", "doompal", "doomframe")
    )
    if ata_failures or ata_timeouts or ata_active_before_frames:
        notes.append(
            "ata-storage-stalled: "
            f"ata={_field(fields, 'ata')} ataop={_field(fields, 'ataop')} "
            f"atawait={_field(fields, 'atawait')} atalba={_field(fields, 'atalba')} "
            f"atastat={_field(fields, 'atastat')} ataerr={_field(fields, 'ataerr')} "
            f"atafail={_field(fields, 'atafail')} atatmo={_field(fields, 'atatmo')}"
        )
        return "ata-storage-stalled", notes

    if execsys is None:
        notes.append("exec-failed: execsys is missing or malformed")
        return "exec-failed", notes

    attempts, successes, failures, handoffs, scheduled, rollbacks = execsys
    execsys_detail = ", ".join(
        f"{name}={value:#x}" for name, value in zip(EXECSYS_NAMES, execsys)
    )

    if attempts == 0:
        notes.append(
            "exec-not-attempted: "
            f"{execsys_detail}; {_exec_detail(fields)}"
        )
        return "exec-not-attempted", notes

    if (
        fields.get("exec") != "OK"
        or fields.get("path") != "DOOM.ELF"
        or fields.get("doom") != "OK"
        or (_hex(fields, "execerr") or 0) != 0
        or (_hex(fields, "execres") or 0) != 0
        or successes == 0
        or handoffs == 0
        or scheduled == 0
        or failures != 0
        or rollbacks != 0
        or _hex(fields, "target") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "ppid") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "entry") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "stack") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "argc") != 1
        or _hex(fields, "argv") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "envp") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "argv0") in (None, 0, 0xFFFFFFFF)
        or (_hex(fields, "envp0") or 0) != 0
    ):
        notes.append(
            "exec-failed: "
            f"exec={_field(fields, 'exec')} path={_field(fields, 'path')} "
            f"doom={_field(fields, 'doom')} {execsys_detail} "
            f"{_exec_detail(fields)}"
        )
        return "exec-failed", notes

    block_issue = _kernel_blocking_issue(fields)
    if block_issue is not None:
        notes.append(
            "kernel-blocking-not-proven: "
            f"{block_issue}; kblock={_field(fields, 'kblock')} "
            f"ksleep={_field(fields, 'ksleep')} wait={_field(fields, 'wait')} "
            f"waitseed={_field(fields, 'waitseed')}"
        )
        return "kernel-blocking-not-proven", notes

    if doomrun == "FAULT" or _hex_nonzero(
        fields, "doomfault", "doomfaultip", "doomfaultv", "doomfaulterr"
    ):
        notes.append(
            "doom-user-fault: "
            f"doomfault(CR2)={_field(fields, 'doomfault')} "
            f"doomfaultip(EIP)={_field(fields, 'doomfaultip')} "
            f"doomfaultv(vector)={_field(fields, 'doomfaultv')} "
            f"doomfaulterr={_field(fields, 'doomfaulterr')} "
            f"fault={_field(fields, 'fault')}"
        )
        if fields.get("doomopen") != "OK" or fields.get("doomread") != "OK":
            notes.append(
                "missing-wad-open-read: WAD open/read did not complete, but the Doom fault is earlier priority"
            )
        return "doom-user-fault", notes

    doomwad = _hex_tuple(fields, "doomwad", 4)
    if fields.get("doomopen") != "OK" or fields.get("doomread") != "OK" or doomwad is None or doomwad[0] == 0 or doomwad[1] == 0 or doomwad[2] == 0 or doomwad[3] != 0x44415749:
        notes.append(
            "missing-wad-open-read: "
            f"doomopen={_field(fields, 'doomopen')} doomread={_field(fields, 'doomread')} "
            f"doomwad={_field(fields, 'doomwad')} "
            f"doomerr={_field(fields, 'doomerr')} doomerrno={_field(fields, 'doomerrno')} "
            f"doommode={_field(fields, 'doommode')} "
            f"doomlog={_field(fields, 'doomlog')}"
        )
        return "missing-wad-open-read", notes

    doominit = _hex_tuple(fields, "doominit", 2)
    if doominit is None or (doominit[0] & REQUIRED_DOOM_INIT_FLAGS) != REQUIRED_DOOM_INIT_FLAGS or doominit[1] == 0:
        notes.append(
            "doom-init-stalled: "
            f"doominit={_field(fields, 'doominit')} doomlog={_field(fields, 'doomlog')} "
            f"gameplay={_field(fields, 'gameplay')} doompresent={_field(fields, 'doompresent')}"
        )
        return "doom-init-stalled", notes

    if _persistence_load_malformed_stream(fields):
        kind = _malformed_load_stream_kind(fields) or "stream"
        notes.append(
            "persistence-load-malformed-stream: "
            f"kind={kind} doomerr={_field(fields, 'doomerr')} doomrun={_field(fields, 'doomrun')} "
            f"doomsav={_field(fields, 'doomsav')} saverd={_field(fields, 'saverd')} "
            f"saveclose={_field(fields, 'saveclose')} saveact={_field(fields, 'saveact')} "
            f"savestm={_field(fields, 'savestm')} savethk={_field(fields, 'savethk')}"
        )
        return "persistence-load-malformed-stream", notes

    if _persistence_load_not_completed(fields):
        notes.append(
            "persistence-load-not-completed: "
            f"doomerr={_field(fields, 'doomerr')} doomrun={_field(fields, 'doomrun')} "
            f"doomsav={_field(fields, 'doomsav')} saverd={_field(fields, 'saverd')} "
            f"saveclose={_field(fields, 'saveclose')} saveact={_field(fields, 'saveact')} "
            f"savestm={_field(fields, 'savestm')} savethk={_field(fields, 'savethk')}"
        )
        return "persistence-load-not-completed", notes

    if _persistence_save_write_failed(fields):
        if _persistence_save_growth_allocation_partial(fields):
            notes.append(
                "persistence-save-growth-allocation-partial: "
                f"doomsav={_field(fields, 'doomsav')} savewr={_field(fields, 'savewr')} "
                f"saveclose={_field(fields, 'saveclose')} savemode={_field(fields, 'savemode')} "
                f"fwr={_field(fields, 'fwr')} fal={_field(fields, 'fal')} "
                f"fam={_field(fields, 'fam')} fac={_field(fields, 'fac')} "
                f"fio={_field(fields, 'fio')} flb={_field(fields, 'flb')} fcl={_field(fields, 'fcl')}"
            )
            return "persistence-save-growth-allocation-partial", notes
        notes.append(
            "persistence-save-write-failed: "
            f"doomerrno={_field(fields, 'doomerrno')} doommode={_field(fields, 'doommode')} "
            f"doomsav={_field(fields, 'doomsav')} savewr={_field(fields, 'savewr')} "
            f"saveclose={_field(fields, 'saveclose')} savemode={_field(fields, 'savemode')} "
            f"fwr={_field(fields, 'fwr')} fal={_field(fields, 'fal')} "
            f"fam={_field(fields, 'fam')} fac={_field(fields, 'fac')} "
            f"fio={_field(fields, 'fio')} flb={_field(fields, 'flb')} fcl={_field(fields, 'fcl')}"
        )
        return "persistence-save-write-failed", notes

    if doomrun == "EXIT" or (_hex(fields, "doomexit") or 0) != 0:
        notes.append(
            "doom-user-exit: "
            f"doomrun={_field(fields, 'doomrun')} doomexit={_field(fields, 'doomexit')}"
        )
        return "doom-user-exit", notes

    if doomrun != "RUN":
        notes.append(f"doom-not-running: doomrun={_field(fields, 'doomrun')}")
        return "doom-not-running", notes

    has_frames = _hex_nonzero(fields, "doompresent", "doompal", "doomframe")
    if has_frames and (
        fields.get("gameplay") != "OK"
        or fields.get("gstate") != "00000000"
        or fields.get("gmap") != "00000101"
        or (_hex(fields, "leveltime") or 0) == 0
    ):
        notes.append(
            "frames-no-gameplay: "
            f"doompresent={_field(fields, 'doompresent')} doompal={_field(fields, 'doompal')} "
            f"doomframe={_field(fields, 'doomframe')} gameplay={_field(fields, 'gameplay')} "
            f"gstate={_field(fields, 'gstate')} gmap={_field(fields, 'gmap')} "
            f"leveltime={_field(fields, 'leveltime')}"
        )
        return "frames-no-gameplay", notes

    mouse_delta = _hex_pair(fields, "mousedelta")
    input_depth = _hex_tuple(fields, "inputdepth", 2, ":")
    input_stat = _hex_tuple(fields, "inputstat", 4, ":")
    input_policy = _hex_tuple(fields, "inputpolicy", 2, ":")
    input_dev = _hex_tuple(fields, "inputdev", 2, ":")
    pflags = _hex(fields, "pflags") or 0
    keyseen = _hex(fields, "keyseen") or 0
    if (
        (_hex(fields, "inputqueue") or 0) == 0
        or (_hex(fields, "inputpoll") or 0) == 0
        or input_depth is None
        or input_stat is None
        or input_policy is None
        or input_dev is None
        or input_policy[0] != 1
        or input_policy[1] != input_stat[3]
        or input_depth[0] > input_stat[3]
        or input_depth[1] != input_stat[2]
        or input_stat[0] != input_depth[0] + input_stat[1] + input_stat[2]
        or input_dev[0] != 1
        or input_dev[1] not in {0, 1, 2}
        or fields.get("inputlast") is None
        or fields.get("inputlast") == "00000000:00000000:00000000"
        or (_hex(fields, "keyirq") or 0) == 0
        or (_hex(fields, "keyqueue") or 0) == 0
        or (_hex(fields, "keypoll") or 0) == 0
        or (keyseen & KEY_SEEN_SCRIPTED_FLAGS) != KEY_SEEN_SCRIPTED_FLAGS
        or (_hex(fields, "mouseirq") or 0) == 0
        or (_hex(fields, "mousepkt") or 0) == 0
        or (_hex(fields, "mousepoll") or 0) == 0
        or (_hex(fields, "mousebtn") or 0) == 0
        or mouse_delta is None
        or (mouse_delta[0] == 0 and mouse_delta[1] == 0)
        or (_hex(fields, "pdelta") or 0) == 0
        or (_hex(fields, "pangledelta") or 0) == 0
        or (pflags & PLAYABILITY_REQUIRED_FLAGS) != PLAYABILITY_REQUIRED_FLAGS
        or (pflags & PLAYABILITY_FIRE_STATE_FLAGS) == 0
    ):
        notes.append(
            "input-no-effect: "
            f"inputqueue={_field(fields, 'inputqueue')} inputpoll={_field(fields, 'inputpoll')} "
            f"inputdepth={_field(fields, 'inputdepth')} inputstat={_field(fields, 'inputstat')} "
            f"inputpolicy={_field(fields, 'inputpolicy')} inputdev={_field(fields, 'inputdev')} "
            f"inputdevices={_field(fields, 'inputdevices')} inputmods={_field(fields, 'inputmods')} "
            f"inputlast={_field(fields, 'inputlast')} "
            f"keyirq={_field(fields, 'keyirq')} keyqueue={_field(fields, 'keyqueue')} "
            f"keypoll={_field(fields, 'keypoll')} keyseen={_field(fields, 'keyseen')} "
            f"pflags={_field(fields, 'pflags')} "
            f"pdelta={_field(fields, 'pdelta')} gflags={_field(fields, 'gflags')} "
            f"pangle={_field(fields, 'pangle')} pangledelta={_field(fields, 'pangledelta')} "
            f"pammo={_field(fields, 'pammo')} prefire={_field(fields, 'prefire')} "
            f"mouseirq={_field(fields, 'mouseirq')} mousepkt={_field(fields, 'mousepkt')} "
            f"mousepoll={_field(fields, 'mousepoll')} mousebtn={_field(fields, 'mousebtn')} "
            f"mousedelta={_field(fields, 'mousedelta')}"
        )
        return "input-no-effect", notes

    timer_ticks = _hex(fields, "ticks")
    doom_ticks = _hex(fields, "dtick")
    if (
        timer_ticks is None
        or timer_ticks == 0
        or doom_ticks is None
        or doom_ticks == 0
        or doom_ticks != (timer_ticks * 35) // 100
    ):
        notes.append(
            "doom-timer-not-proven: "
            f"ticks={_field(fields, 'ticks')} dtick={_field(fields, 'dtick')} "
            f"gtic={_field(fields, 'gtic')} leveltime={_field(fields, 'leveltime')}"
        )
        return "doom-timer-not-proven", notes

    peip = _hex_pair(fields, "peip")
    pkind = _hex_pair(fields, "pkind")
    pcr3 = _hex_pair(fields, "pcr3")
    pkstk = _hex_pair(fields, "pkstk")
    pframe = _hex_tuple(fields, "pframe", 5)
    psegs = _hex_tuple(fields, "psegs", 4, ":")
    peflags = _hex_tuple(fields, "peflags", 5, ":")
    pfrom = _hex(fields, "pfrom")
    pto = _hex(fields, "pto")
    spin = _hex(fields, "pspin")
    pair_mask = _hex(fields, "pmask")
    preempt_switches = _hex(fields, "preempt")
    irq_switches = _hex(fields, "pirq")
    if (
        fields.get("pself") != "OK"
        or (preempt_switches or 0) == 0
        or (irq_switches or 0) == 0
        or irq_switches != preempt_switches
        or (_hex(fields, "pattempt") or 0) == 0
        or (_hex(fields, "puser") or 0) == 0
        or (_hex(fields, "puser") or 0) < (preempt_switches or 0)
        or (_hex(fields, "pround") or 0) == 0
        or (_hex(fields, "pctx") or 0) == 0
        or pair_mask is None
        or (pair_mask & 0x3) != 0x3
        or pfrom in (None, 0, 0xFFFFFFFF)
        or pto in (None, 0, 0xFFFFFFFF)
        or pfrom == pto
        or pkind is None
        or set(pkind) != {2, 3}
        or peip is None
        or peip[0] == 0
        or peip[1] == 0
        or pcr3 is None
        or set(pcr3) != {0x00082000, 0x00083000}
        or pkstk is None
        or set(pkstk) != {0x00073000, 0x00072000}
        or pframe is None
        or pframe[0] != irq_switches
        or pframe[1] != peip[1]
        or pframe[2] != USER_CODE_SEG
        or (pframe[2] & 0x3) != 0x3
        or pframe[3] == 0
        or pframe[4] != USER_DATA_SEG
        or (pframe[4] & 0x3) != 0x3
        or psegs is None
        or any(selector != USER_DATA_SEG or (selector & 0x3) != 0x3 for selector in psegs)
        or peflags is None
        or peflags[0] != SANITIZED_USER_EFLAGS
        or peflags[1] != SANITIZED_USER_EFLAGS
        or peflags[2] != SANITIZED_USER_EFLAGS
        or peflags[4] == 0
        or peflags[3] > (preempt_switches or 0) + (_hex(fields, "puser") or 0)
        or spin in (None, 0, PREEMPT_PROBE_MAGIC)
    ):
        notes.append(
            "preemption-not-proven: "
            f"preempt={_field(fields, 'preempt')} pirq={_field(fields, 'pirq')} "
            f"pattempt={_field(fields, 'pattempt')} "
            f"puser={_field(fields, 'puser')} pround={_field(fields, 'pround')} "
            f"pctx={_field(fields, 'pctx')} pmask={_field(fields, 'pmask')} "
            f"pfrom={_field(fields, 'pfrom')} "
            f"pto={_field(fields, 'pto')} pkind={_field(fields, 'pkind')} "
            f"peip={_field(fields, 'peip')} pcr3={_field(fields, 'pcr3')} "
            f"pkstk={_field(fields, 'pkstk')} "
            f"pframe={_field(fields, 'pframe')} psegs={_field(fields, 'psegs')} "
            f"peflags={_field(fields, 'peflags')} "
            f"pspin={_field(fields, 'pspin')} pself={_field(fields, 'pself')}"
        )
        return "preemption-not-proven", notes

    cadence_issue = _long_run_cadence_issue(fields)
    if cadence_issue is not None:
        notes.append(
            "long-run-cadence-not-proven: "
            f"{cadence_issue}; "
            f"gtic={_field(fields, 'gtic')} leveltime={_field(fields, 'leveltime')} "
            f"doompresent={_field(fields, 'doompresent')} pirq={_field(fields, 'pirq')} "
            f"pskip={_field(fields, 'pskip')} audioirq={_field(fields, 'audioirq')} "
            f"refill={_field(fields, 'refill')} musicpos={_field(fields, 'musicpos')} "
            f"musicpull={_field(fields, 'musicpull')} pcmstream={_field(fields, 'pcmstream')} "
            f"pcmpull={_field(fields, 'pcmpull')} inputdepth={_field(fields, 'inputdepth')}"
        )
        return "long-run-cadence-not-proven", notes

    notes.append(
        "long-run-cadence: final status includes Doom/frame, scheduler, SB16 refill, "
        "music, and input-depth counters for slowdown triage"
    )
    notes.append("playability-status-green: final status has no obvious first-failure field")
    return "playability-status-green", notes


def render_diagnosis(
    status: str,
    *,
    status_path: Path | None = None,
    doom_symbols: Path | None = None,
) -> str:
    fields = parse_status(status)
    primary, notes = classify(fields)
    rule = next((candidate for candidate in TRIAGE_RULES if candidate.name == primary), None)
    symbol_map_path = infer_symbol_map_path(status_path, doom_symbols)
    lines = [
        f"primary: {primary}",
        f"summary: {summarize(fields)}",
    ]
    lines.extend(f"- {note}" for note in notes)
    if primary == "doom-user-fault":
        lines.extend(f"- {note}" for note in render_doom_fault_context(fields, symbol_map_path))
    if primary == "missing-wad-open-read":
        lines.extend(f"- {note}" for note in render_wad_io_context(fields))
    if primary == "persistence-save-write-failed":
        lines.extend(f"- {note}" for note in render_persistence_save_context(fields))
    if primary == "persistence-save-growth-allocation-partial":
        lines.extend(f"- {note}" for note in render_persistence_save_context(fields))
    if primary in ("persistence-load-malformed-stream", "persistence-load-not-completed"):
        lines.extend(f"- {note}" for note in render_persistence_load_context(fields, status))
    if primary == "doom-init-stalled":
        lines.extend(f"- {note}" for note in render_doom_init_context(fields))
    if primary in ("long-run-cadence-not-proven", "playability-status-green"):
        lines.extend(f"- {note}" for note in render_long_run_cadence_context(fields))
    if rule is not None:
        lines.append(f"next: {rule.next_step}")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "status",
        help="status file path, or '-' to read a raw status line from stdin",
    )
    parser.add_argument(
        "--doom-symbols",
        type=Path,
        help="Optional doom.symbols map from the same cloud artifact or local build",
    )
    args = parser.parse_args(argv)

    try:
        status_path = None
        if args.status == "-":
            status = sys.stdin.read()
        else:
            status_path = Path(args.status)
            status = status_path.read_text()
        uefi_manifest = _parse_uefi_manifest(status)
        if uefi_manifest is not None:
            print(render_uefi_manifest_diagnosis(uefi_manifest))
        else:
            print(render_diagnosis(status, status_path=status_path, doom_symbols=args.doom_symbols))
    except (OSError, ValueError) as exc:
        print(f"cloud status triage failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
