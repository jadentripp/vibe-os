#!/usr/bin/env python3
"""Classify the next real-WAD cloud status line into a repair lane."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
SUMMARY_FIELDS = (
    "exec",
    "path",
    "execsys",
    "execerr",
    "execres",
    "target",
    "entry",
    "stack",
    "argc",
    "argv",
    "argv0",
    "doom",
    "doomrun",
    "doomopen",
    "doomread",
    "doomerr",
    "doomexit",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
    "fault",
    "panic",
    "shutdown",
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "doompresent",
    "doompal",
    "doomframe",
    "pflags",
    "gflags",
    "pdelta",
    "keyirq",
    "keyqueue",
    "keypoll",
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
    "preempt",
    "pattempt",
    "pskip",
    "puser",
    "pround",
    "pctx",
    "pfrom",
    "pto",
    "peip",
    "pspin",
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
PREEMPT_PROBE_MAGIC = 0x50524545
PLAYABILITY_REQUIRED_FLAGS = 0x0000003F
PLAYABILITY_FIRE_STATE_FLAGS = 0x000000C0


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
        "exec-not-attempted",
        ("execsys", "execerr", "execres", "target", "entry", "stack", "argc", "argv", "argv0", "doomrun"),
        "The probe never attempted the syscall exec handoff into DOOM.ELF.",
        "Inspect the user-probe completion path and the expected-fault recovery into SYS_EXEC.",
    ),
    TriageRule(
        "exec-failed",
        ("exec", "path", "execsys", "execerr", "execres", "target", "entry", "stack", "argc", "argv", "argv0", "doom"),
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
        ("doomopen", "doomread", "doomerr", "doommode", "doomlog", "wad", "lmp"),
        "Doom did not successfully open/read the WAD through the libc/syscall/FAT path.",
        "If Doom also faulted, fix the fault first; otherwise inspect path mapping and FAT read/lseek.",
    ),
    TriageRule(
        "frames-no-gameplay",
        ("doompresent", "doompal", "doomframe", "gameplay", "gstate", "gmap", "leveltime"),
        "Frames or palette updates happened, but Doom did not prove E1M1 gameplay.",
        "Inspect Doom startup log/state: it may be rendering a title/error/menu path rather than GS_LEVEL.",
    ),
    TriageRule(
        "input-no-effect",
        ("keyirq", "keyqueue", "keypoll", "mouseirq", "mousepkt", "mousepoll", "mousebtn", "mousedelta", "pflags", "pdelta", "gflags"),
        "Keyboard or mouse events reached the OS, but scripted start/fire/move/use/menu/mouse effects were not observed.",
        "Compare early/start/fire/move/use/menu snapshots and inspect PS/2 translation plus Doom event injection.",
    ),
    TriageRule(
        "preemption-not-proven",
        ("preempt", "pattempt", "puser", "pround", "pctx", "pfrom", "pto", "peip", "pspin", "pself"),
        "Doom reached gameplay, but the status does not prove live timer-driven switching between Ring 3 tasks.",
        "Inspect scheduler_tick, the live preempt probe seeding path, and whether timer IRQs are interrupting user code.",
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
        "artifact-proof-failure",
        ("status.early.txt", "status.after-*.txt", "kernel.elf", "user_probe.elf", "doom.elf", "doom.symbols"),
        "The cloud artifact package failed even if the final status line looked plausible.",
        "Run check_cloud_playability_artifacts.py; look for missing snapshots, duplicate basenames, or forbidden payloads.",
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
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise ValueError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    if not fields:
        raise ValueError("no key=value status fields found")
    return fields


def _field(fields: dict[str, str], name: str) -> str:
    return fields.get(name, "<missing>")


def _hex(fields: dict[str, str], name: str) -> int | None:
    value = fields.get(name)
    if value is None or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        return None
    return int(value, 16)


def _hex_nonzero(fields: dict[str, str], *names: str) -> bool:
    return any((_hex(fields, name) or 0) != 0 for name in names)


def _execsys(fields: dict[str, str]) -> tuple[int, ...] | None:
    value = fields.get("execsys")
    if value is None:
        return None
    parts = value.split("/")
    if len(parts) != len(EXECSYS_NAMES):
        return None
    parsed: list[int] = []
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            return None
        parsed.append(int(part, 16))
    return tuple(parsed)


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


def _exec_detail(fields: dict[str, str]) -> str:
    return (
        f"execerr={_field(fields, 'execerr')} execres={_field(fields, 'execres')} "
        f"target={_field(fields, 'target')} entry={_field(fields, 'entry')} "
        f"stack={_field(fields, 'stack')} argc={_field(fields, 'argc')} "
        f"argv={_field(fields, 'argv')} argv0={_field(fields, 'argv0')}"
    )


def summarize(fields: dict[str, str]) -> str:
    return " ".join(f"{name}={fields.get(name, '<missing>')}" for name in SUMMARY_FIELDS)


def _parse_hex_field(value: str) -> int | None:
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        return None
    return int(value, 16)


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
    if cr2 is not None and eip is not None and cr2 == eip and vector == 0x0E:
        lines.append("fault-hint: page fault tried to fetch or touch the faulting EIP page")
    if symbol_map_path is None:
        lines.append(
            "symbol: no doom.symbols map found; pass --doom-symbols or use the next cloud artifact"
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
        f"doomseek={_field(fields, 'doomseek')} doomclose={_field(fields, 'doomclose')} "
        f"doomerr={_field(fields, 'doomerr')} doommode={_field(fields, 'doommode')} "
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
        or _hex(fields, "entry") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "stack") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "argc") != 1
        or _hex(fields, "argv") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "argv0") in (None, 0, 0xFFFFFFFF)
    ):
        notes.append(
            "exec-failed: "
            f"exec={_field(fields, 'exec')} path={_field(fields, 'path')} "
            f"doom={_field(fields, 'doom')} {execsys_detail} "
            f"{_exec_detail(fields)}"
        )
        return "exec-failed", notes

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

    if doomrun == "EXIT" or (_hex(fields, "doomexit") or 0) != 0:
        notes.append(
            "doom-user-exit: "
            f"doomrun={_field(fields, 'doomrun')} doomexit={_field(fields, 'doomexit')}"
        )
        return "doom-user-exit", notes

    if fields.get("doomopen") != "OK" or fields.get("doomread") != "OK" or (
        _hex(fields, "doomerr") or 0
    ) != 0:
        notes.append(
            "missing-wad-open-read: "
            f"doomopen={_field(fields, 'doomopen')} doomread={_field(fields, 'doomread')} "
            f"doomerr={_field(fields, 'doomerr')} doommode={_field(fields, 'doommode')} "
            f"doomlog={_field(fields, 'doomlog')}"
        )
        return "missing-wad-open-read", notes

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
    pflags = _hex(fields, "pflags") or 0
    if (
        (_hex(fields, "keyirq") or 0) == 0
        or (_hex(fields, "keyqueue") or 0) == 0
        or (_hex(fields, "keypoll") or 0) == 0
        or (_hex(fields, "mouseirq") or 0) == 0
        or (_hex(fields, "mousepkt") or 0) == 0
        or (_hex(fields, "mousepoll") or 0) == 0
        or ((_hex(fields, "mousebtn") or 0) & 0x1) == 0
        or mouse_delta is None
        or mouse_delta[0] == 0
        or mouse_delta[1] == 0
        or (_hex(fields, "pdelta") or 0) == 0
        or (pflags & PLAYABILITY_REQUIRED_FLAGS) != PLAYABILITY_REQUIRED_FLAGS
        or (pflags & PLAYABILITY_FIRE_STATE_FLAGS) == 0
    ):
        notes.append(
            "input-no-effect: "
            f"keyirq={_field(fields, 'keyirq')} keyqueue={_field(fields, 'keyqueue')} "
            f"keypoll={_field(fields, 'keypoll')} pflags={_field(fields, 'pflags')} "
            f"pdelta={_field(fields, 'pdelta')} gflags={_field(fields, 'gflags')} "
            f"mouseirq={_field(fields, 'mouseirq')} mousepkt={_field(fields, 'mousepkt')} "
            f"mousepoll={_field(fields, 'mousepoll')} mousebtn={_field(fields, 'mousebtn')} "
            f"mousedelta={_field(fields, 'mousedelta')}"
        )
        return "input-no-effect", notes

    peip = _hex_pair(fields, "peip")
    pfrom = _hex(fields, "pfrom")
    pto = _hex(fields, "pto")
    spin = _hex(fields, "pspin")
    if (
        fields.get("pself") != "OK"
        or (_hex(fields, "preempt") or 0) == 0
        or (_hex(fields, "pattempt") or 0) == 0
        or (_hex(fields, "puser") or 0) == 0
        or (_hex(fields, "pround") or 0) == 0
        or (_hex(fields, "pctx") or 0) == 0
        or pfrom in (None, 0, 0xFFFFFFFF)
        or pto in (None, 0, 0xFFFFFFFF)
        or pfrom == pto
        or peip is None
        or peip[0] == 0
        or peip[1] == 0
        or spin in (None, 0, PREEMPT_PROBE_MAGIC)
    ):
        notes.append(
            "preemption-not-proven: "
            f"preempt={_field(fields, 'preempt')} pattempt={_field(fields, 'pattempt')} "
            f"puser={_field(fields, 'puser')} pround={_field(fields, 'pround')} "
            f"pctx={_field(fields, 'pctx')} pfrom={_field(fields, 'pfrom')} "
            f"pto={_field(fields, 'pto')} peip={_field(fields, 'peip')} "
            f"pspin={_field(fields, 'pspin')} pself={_field(fields, 'pself')}"
        )
        return "preemption-not-proven", notes

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
        print(render_diagnosis(status, status_path=status_path, doom_symbols=args.doom_symbols))
    except (OSError, ValueError) as exc:
        print(f"cloud status triage failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
