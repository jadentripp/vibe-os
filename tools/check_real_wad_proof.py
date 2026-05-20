#!/usr/bin/env python3
"""Validate the non-pixel status proof from the real-WAD smoke run."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import check_human_playability_proof


DEFAULT_REJECT_PATTERNS = (
    r"doom error",
    r"i_error",
    r"pnames not found",
    r"w_getnumforname",
    r"w_cachelumpnum",
    r"r_inittextures",
)
PREEMPT_PROBE_MAGIC = 0x50524545
USER_KIND_DOOM = 2
USER_KIND_PREEMPT_PROBE = 3
PROC_DOOM_PAGE_DIR_ADDR = 0x00082000
PROC_PREEMPT_PAGE_DIR_ADDR = 0x00083000
PROC_DOOM_KERNEL_STACK_TOP = 0x00073000
PROC_PREEMPT_PROBE_KERNEL_STACK_TOP = 0x00072000
REQUIRED_DOOM_INIT_FLAGS = 0x000001FF

EXACT_FIELDS = {
    "exec": "OK",
    "path": "DOOM.ELF",
    "doom": "OK",
    "doomrun": "RUN",
    "doomopen": "OK",
    "doomread": "OK",
    "gameplay": "OK",
    "gstate": "00000000",
    "gmap": "00000101",
    "gfx": "OK",
    "pself": "OK",
    "pg": "ON",
    "pmm": "OK",
    "vmm": "OK",
    "libc": "OK",
    "c": "OK",
    "usr": "OK",
    "wad": "OK",
    "lmp": "OK",
    "heap": "OK",
    "panic": "NONE",
    "shutdown": "NONE",
}

HEX_FIELDS = (
    "target",
    "ppid",
    "entry",
    "stack",
    "argc",
    "argv",
    "envp",
    "argv0",
    "envp0",
    "execerr",
    "execres",
    "doomwrite",
    "doomseek",
    "doomclose",
    "doomsbrk",
    "doomerr",
    "doomerrno",
    "doompresent",
    "doompal",
    "doomframe",
    "doomnonzero",
    "doomcolors",
    "gtic",
    "leveltime",
    "dtick",
    "gflags",
    "gaction",
    "pflags",
    "pbuttons",
    "pdelta",
    "doomexit",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
    "doomsound",
    "sfxmix",
    "voices",
    "sfxvoices",
    "audioirq",
    "ack8",
    "ack16",
    "refill",
    "half",
    "mixwrap",
    "mixover",
    "mixunder",
    "mixclip",
    "steal",
    "pitchclamp",
    "panclamp",
    "musicvoices",
    "musicmix",
    "musicloop",
    "musicpos",
    "musicbuf",
    "musicunder",
    "musicdrops",
    "dma",
    "keyirq",
    "keyqueue",
    "keypoll",
    "keyseen",
    "keylast",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "mousebtn",
    "preempt",
    "pirq",
    "pattempt",
    "pskip",
    "puser",
    "pround",
    "pctx",
    "pfrom",
    "pto",
    "pspin",
    "free",
    "ticks",
)

FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
REQUIRED_SNAPSHOT_LABELS = ("baseline", "start", "fire", "movement", "use", "mouse", "menu")
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
    "doom",
    "doomrun",
    "doomopen",
    "doomread",
    "doomwad",
    "doomerr",
    "doomerrno",
    "doomexit",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
    "fault",
    "panic",
    "shutdown",
    "doominit",
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "dtick",
    "doompresent",
    "doompal",
    "doomframe",
    "sfxmix",
    "sfxvoices",
    "musicvoices",
    "musicmix",
    "musicloop",
    "musicpos",
    "musicbuf",
    "musicunder",
    "musicdrops",
    "sb16",
    "dma",
    "play",
    "voiceq",
    "musicq",
    "pflags",
    "gflags",
    "keyirq",
    "keyqueue",
    "keypoll",
    "keyseen",
    "keylast",
    "mouse",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "mousebtn",
    "mousedelta",
    "gfx",
    "fb",
    "fbpolicy",
    "fbgeom",
    "fbdirty",
    "usr",
    "wad",
    "lmp",
    "heap",
    "free",
    "ticks",
    "preempt",
    "pirq",
    "pattempt",
    "pskip",
    "puser",
    "pround",
    "pctx",
    "pfrom",
    "pto",
    "pkind",
    "peip",
    "pcr3",
    "pkstk",
    "pspin",
)


def _field(status: str, name: str) -> str:
    fields = _status_fields(status)
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"missing {name}= field")
    return value


def _status_fields(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise AssertionError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    return fields


def summarize_status(status: str) -> str:
    """Return a compact proof-field summary for CI failure logs."""

    try:
        fields = _status_fields(status)
    except AssertionError as exc:
        return f"unparseable status: {exc}"
    return " ".join(f"{name}={fields.get(name, '<missing>')}" for name in SUMMARY_FIELDS)


def _hex_field(status: str, name: str) -> int:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be eight hex digits, got {value!r}")
    return int(value, 16)


def _hex_field_gt(status: str, name: str, minimum: int) -> int:
    parsed = _hex_field(status, name)
    if parsed <= minimum:
        raise AssertionError(f"{name}= must be greater than {minimum:#x}, got {parsed:#x}")
    return parsed


def _exact_field(status: str, name: str, expected: str) -> None:
    value = _field(status, name)
    if value != expected:
        raise AssertionError(f"{name}= must be {expected}, got {value!r}")


def _choice_field(status: str, name: str, choices: tuple[str, ...]) -> None:
    value = _field(status, name)
    if value not in choices:
        joined = ", ".join(choices)
        raise AssertionError(f"{name}= must be one of {joined}, got {value!r}")


def _hex_tuple_field(status: str, name: str, count: int, separator: str = "/") -> tuple[int, ...]:
    value = _field(status, name)
    parts = value.split(separator)
    if len(parts) != count:
        raise AssertionError(f"{name}= must have {count} hex parts separated by {separator!r}")
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            raise AssertionError(f"{name}= part must be eight hex digits, got {part!r}")
    return tuple(int(part, 16) for part in parts)


def _doom_init_field(status: str) -> tuple[int, int]:
    flags, reports = _hex_tuple_field(status, "doominit", 2)
    if (flags & REQUIRED_DOOM_INIT_FLAGS) != REQUIRED_DOOM_INIT_FLAGS:
        raise AssertionError(
            f"doominit= flags must include {REQUIRED_DOOM_INIT_FLAGS:#x}, got {flags:#x}"
        )
    if reports == 0:
        raise AssertionError("doominit= report count must be nonzero")
    return flags, reports


def _doom_wad_field(status: str) -> tuple[int, int, int, int]:
    opens, reads, seeks, magic = _hex_tuple_field(status, "doomwad", 4)
    if opens == 0:
        raise AssertionError("doomwad= must prove a Doom DOOM1.WAD open")
    if reads == 0:
        raise AssertionError("doomwad= must prove a Doom DOOM1.WAD read")
    if seeks == 0:
        raise AssertionError("doomwad= must prove a Doom DOOM1.WAD lseek")
    if magic != 0x44415749:
        raise AssertionError(f"doomwad= magic must be IWAD, got {magic:#x}")
    return opens, reads, seeks, magic


def _sample_field(status: str, name: str) -> tuple[int, int, int]:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be three eight-digit hex samples, got {value!r}")
    samples = tuple(int(part, 16) for part in value.split(":"))
    for sample in samples:
        if sample > 0xff:
            raise AssertionError(f"{name}= samples must be indexed color bytes, got {sample:#x}")
    return samples


def _visual_phase_signature(status: str, label: str) -> tuple[int, int, int, int, int, tuple[int, int, int]]:
    try:
        present = _hex_field_gt(status, "doompresent", 0)
        palette = _hex_field_gt(status, "doompal", 0)
        frame = _hex_field_gt(status, "doomframe", 0)
        nonzero = _hex_field_gt(status, "doomnonzero", 1024)
        colors = _hex_field_gt(status, "doomcolors", 64)
        samples = _sample_field(status, "doomsamp")
    except AssertionError as exc:
        raise AssertionError(f"{label} visual proof: {exc}") from exc
    return present, palette, frame, nonzero, colors, samples


def _assert_scripted_visual_progression(snapshots: dict[str, str | None], final_status: str) -> None:
    ordered = [
        ("baseline", snapshots.get("baseline")),
        ("start", snapshots.get("start")),
        ("fire", snapshots.get("fire")),
        ("movement", snapshots.get("movement")),
        ("use", snapshots.get("use")),
        ("mouse", snapshots.get("mouse")),
        ("menu", snapshots.get("menu")),
        ("final", final_status),
    ]
    previous_label: str | None = None
    previous_present: int | None = None
    previous_status: str | None = None
    frame_hashes: set[int] = set()

    for label, status in ordered:
        if status is None or "doompresent=" not in status:
            continue
        if previous_status is not None and status == previous_status:
            continue
        present, _palette, frame, _nonzero, _colors, _samples = _visual_phase_signature(status, label)
        frame_hashes.add(frame)
        if previous_present is not None and present <= previous_present:
            raise AssertionError(
                f"{label} doompresent= must advance after {previous_label}, "
                f"got {previous_present:08X}->{present:08X}"
            )
        previous_label = label
        previous_present = present
        previous_status = status

    if len(frame_hashes) < 2:
        raise AssertionError(
            "scripted visual proof must show at least one doomframe= hash change across snapshots"
        )


def _position_field(status: str, name: str) -> None:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be two eight-digit hex coordinates, got {value!r}")


def _colon_tuple_field(status: str, name: str, count: int) -> tuple[int, ...]:
    value = _field(status, name)
    parts = value.split(":")
    if len(parts) != count:
        raise AssertionError(f"{name}= must have {count} hex parts separated by ':'")
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            raise AssertionError(f"{name}= part must be eight hex digits, got {part!r}")
    return tuple(int(part, 16) for part in parts)


def _display_geometry_fields(status: str) -> None:
    backend = _field(status, "fb")
    policy = _field(status, "fbpolicy")
    if backend == "M13":
        if policy != "M13":
            raise AssertionError(f"fbpolicy= must be M13 for fb=M13, got {policy!r}")
    elif backend == "LFB":
        if policy not in ("ASP", "SQ"):
            raise AssertionError(f"fbpolicy= must be ASP or SQ for fb=LFB, got {policy!r}")
    else:
        raise AssertionError(f"fb= must be LFB or M13, got {backend!r}")

    x, y, width, height, scale = _colon_tuple_field(status, "fbgeom", 5)
    dirty_x, dirty_y, dirty_width, dirty_height, dirty_count = _colon_tuple_field(status, "fbdirty", 5)
    if policy == "M13":
        if (x, y, width, height, scale) != (0, 0, 320, 200, 1):
            raise AssertionError(f"fbgeom= for M13 must be 0:0:320:200:1, got {_field(status, 'fbgeom')!r}")
    elif policy == "ASP":
        if width != 320 * scale or height != 240 * scale or scale < 2:
            raise AssertionError(f"fbgeom= ASP must be 320x240 integer-scaled, got {_field(status, 'fbgeom')!r}")
    elif policy == "SQ":
        if width != 320 * scale or height != 200 * scale or scale < 2:
            raise AssertionError(f"fbgeom= SQ must be 320x200 integer-scaled, got {_field(status, 'fbgeom')!r}")
    if dirty_x >= 320 or dirty_y >= 200:
        raise AssertionError(f"fbdirty= origin must be inside the Doom source frame, got {_field(status, 'fbdirty')!r}")
    if dirty_count and (dirty_width == 0 or dirty_height == 0):
        raise AssertionError(f"fbdirty= changed pixels need nonzero bounds, got {_field(status, 'fbdirty')!r}")
    if dirty_width > 320 or dirty_height > 200:
        raise AssertionError(f"fbdirty= bounds exceed the Doom source frame, got {_field(status, 'fbdirty')!r}")


def _open_mode_field(status: str, name: str) -> None:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be two eight-digit hex values, got {value!r}")


def _validate_core_status(status: str) -> None:
    _status_fields(status)
    for name, expected in EXACT_FIELDS.items():
        _exact_field(status, name, expected)
    for name in HEX_FIELDS:
        _hex_field(status, name)
    _choice_field(status, "fb", ("LFB", "M13"))
    _display_geometry_fields(status)
    _choice_field(status, "audio", ("SB16", "NONE"))
    _choice_field(status, "mouse", ("OK", "NONE"))
    _open_mode_field(status, "doommode")
    _position_field(status, "ppos")
    _position_field(status, "mousedelta")
    sb16_version = _colon_tuple_field(status, "sb16", 2)
    play = _colon_tuple_field(status, "play", 2)
    voiceq = _colon_tuple_field(status, "voiceq", 3)
    musicq = _colon_tuple_field(status, "musicq", 2)

    attempts, successes, failures, handoffs, scheduled, rollbacks = _hex_tuple_field(
        status, "execsys", 6
    )
    if attempts == 0 or successes == 0 or handoffs == 0 or scheduled == 0:
        raise AssertionError("execsys= must prove a successful syscall exec handoff")
    if failures != 0 or rollbacks != 0:
        raise AssertionError("execsys= must not report failures or rollbacks in real-WAD proof")

    if _hex_field(status, "execerr") != 0:
        raise AssertionError("execerr= must be zero after successful real-WAD exec")
    if _hex_field(status, "execres") != 0:
        raise AssertionError("execres= must be zero after successful real-WAD exec")
    _hex_field_gt(status, "target", 0)
    ppid = _hex_field(status, "ppid")
    if ppid in (0, 0xFFFFFFFF):
        raise AssertionError(f"ppid= must prove a live exec parent PID, got {ppid:#x}")
    _hex_field_gt(status, "entry", 0)
    _hex_field_gt(status, "stack", 0)
    if _hex_field(status, "argc") != 1:
        raise AssertionError("argc= must prove a single argv[0] exec stack")
    _hex_field_gt(status, "argv", 0)
    _hex_field_gt(status, "envp", 0)
    _hex_field_gt(status, "argv0", 0)
    if _hex_field(status, "envp0") != 0:
        raise AssertionError("envp0= must prove the exec stack has an empty envp terminator")
    _hex_field_gt(status, "doomseek", 0)
    _doom_wad_field(status)
    _doom_init_field(status)
    _hex_field_gt(status, "doomsbrk", 0)
    if _hex_field(status, "doomexit") != 0:
        raise AssertionError("doomexit= must be zero for the real-WAD gameplay proof")
    for fault_field in ("doomfault", "doomfaultip", "doomfaultv", "doomfaulterr"):
        if _hex_field(status, fault_field) != 0:
            raise AssertionError(f"{fault_field}= must be zero for the real-WAD gameplay proof")
    if any(_hex_tuple_field(status, "fault", 11)):
        raise AssertionError("fault= must be all zero for the real-WAD gameplay proof")
    _hex_field_gt(status, "free", 0)
    timer_ticks = _hex_field_gt(status, "ticks", 0)
    doom_ticks = _hex_field_gt(status, "dtick", 0)
    expected_doom_ticks = (timer_ticks * 35) // 100
    if doom_ticks != expected_doom_ticks:
        raise AssertionError(
            f"dtick= must equal floor(ticks*35/100), got {doom_ticks:08X} for ticks={timer_ticks:08X}"
        )
    audio = _field(status, "audio")
    if audio == "SB16":
        if sb16_version[0] == 0:
            raise AssertionError("sb16= must expose a nonzero SB16 DSP major version when audio=SB16")
        _hex_field_gt(status, "dma", 0)
        if play[0] == 0:
            raise AssertionError("play= must prove SB16 playback started when audio=SB16")
        if voiceq[0] == 0:
            raise AssertionError("voiceq= must prove an audio voice was queued when audio=SB16")
        if musicq[0] == 0:
            raise AssertionError("musicq= must prove the music voice was queued when audio=SB16")
        _hex_field_gt(status, "musicpos", 0)
    preempt_switches = _hex_field_gt(status, "preempt", 0)
    irq_switches = _hex_field_gt(status, "pirq", 0)
    if irq_switches != preempt_switches:
        raise AssertionError("pirq= must match preempt= to prove timer IRQ-driven switches")
    _hex_field_gt(status, "pattempt", 0)
    _hex_field_gt(status, "puser", 0)
    _hex_field_gt(status, "pround", 0)
    _hex_field_gt(status, "pctx", 0)
    pfrom = _hex_field(status, "pfrom")
    pto = _hex_field(status, "pto")
    if pfrom in (0, 0xFFFFFFFF):
        raise AssertionError(f"pfrom= must record a live source PID, got {pfrom:#x}")
    if pto in (0, 0xFFFFFFFF):
        raise AssertionError(f"pto= must record a live target PID, got {pto:#x}")
    if pfrom == pto:
        raise AssertionError("pfrom= and pto= must prove a switch between different processes")
    pkind = _hex_tuple_field(status, "pkind", 2, separator=":")
    if set(pkind) != {USER_KIND_DOOM, USER_KIND_PREEMPT_PROBE}:
        raise AssertionError("pkind= must prove a Doom/preempt-probe scheduler switch")
    from_eip, to_eip = _hex_tuple_field(status, "peip", 2, separator=":")
    if from_eip == 0 or to_eip == 0:
        raise AssertionError("peip= must record nonzero source and target EIPs")
    pcr3 = _hex_tuple_field(status, "pcr3", 2, separator=":")
    if set(pcr3) != {PROC_DOOM_PAGE_DIR_ADDR, PROC_PREEMPT_PAGE_DIR_ADDR}:
        raise AssertionError("pcr3= must prove distinct Doom/preempt-probe address spaces")
    pkstk = _hex_tuple_field(status, "pkstk", 2, separator=":")
    if set(pkstk) != {PROC_DOOM_KERNEL_STACK_TOP, PROC_PREEMPT_PROBE_KERNEL_STACK_TOP}:
        raise AssertionError("pkstk= must prove distinct Doom/preempt-probe kernel stacks")
    spin = _hex_field(status, "pspin")
    if spin in (0, PREEMPT_PROBE_MAGIC):
        raise AssertionError("pspin= must prove the Ring 3 preempt probe executed after seeding")


def validate_status(
    status: str,
    baseline_status: str | None = None,
    start_status: str | None = None,
    movement_status: str | None = None,
    fire_status: str | None = None,
    use_status: str | None = None,
    mouse_status: str | None = None,
    menu_status: str | None = None,
    reject_patterns: tuple[str, ...] = DEFAULT_REJECT_PATTERNS,
    require_snapshots: bool = True,
) -> None:
    snapshots = {
        "baseline": baseline_status,
        "start": start_status,
        "fire": fire_status,
        "movement": movement_status,
        "use": use_status,
        "mouse": mouse_status,
        "menu": menu_status,
    }
    if require_snapshots:
        missing = [
            label for label in REQUIRED_SNAPSHOT_LABELS
            if snapshots.get(label) is None
        ]
        if missing:
            raise AssertionError(
                "missing required scripted status snapshot(s): " + ", ".join(missing)
            )

    _validate_core_status(status)
    _hex_field_gt(status, "leveltime", 0)
    _assert_scripted_visual_progression(snapshots, status)
    check_human_playability_proof.validate_status(
        status,
        baseline_status,
        start_status=start_status,
        movement_status=movement_status,
        fire_status=fire_status,
        use_status=use_status,
        mouse_status=mouse_status,
        menu_status=menu_status,
        reject_patterns=reject_patterns,
    )

    for pattern in reject_patterns:
        if re.search(pattern, status, re.IGNORECASE):
            raise AssertionError(f"rejected Doom error string matched: {pattern}")


def _read_existing(path: Path | None) -> str | None:
    return path.read_text() if path is not None and path.exists() else None


def _auto_snapshot(final_status: Path, label: str) -> Path:
    return final_status.with_name(f"status.{label}.txt")


def _resolve_snapshot(explicit: Path | None, auto: Path | None) -> str | None:
    if explicit is not None:
        return explicit.read_text()
    return _read_existing(auto)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("status", type=Path, help="Decoded build/status.txt from real-WAD smoke")
    parser.add_argument("--baseline", type=Path, help="Decoded pre-input status snapshot")
    parser.add_argument("--start", type=Path, help="Decoded status after Doom autostarts E1M1")
    parser.add_argument("--movement", type=Path, help="Decoded status after scripted movement")
    parser.add_argument("--fire", type=Path, help="Decoded status after scripted fire")
    parser.add_argument("--use", type=Path, help="Decoded status after scripted use")
    parser.add_argument("--mouse", type=Path, help="Decoded status after scripted mouse input")
    parser.add_argument("--menu", type=Path, help="Decoded status after scripted menu toggle")
    parser.add_argument(
        "--no-auto-snapshots",
        action="store_true",
        help="Only use explicitly supplied snapshot paths",
    )
    args = parser.parse_args(argv)

    status = ""
    try:
        status = args.status.read_text()
        baseline = args.baseline
        start = args.start
        fire = args.fire
        movement = args.movement
        use = args.use
        mouse = args.mouse
        menu = args.menu
        if not args.no_auto_snapshots:
            if baseline is None:
                after_start = _auto_snapshot(args.status, "after-start")
                baseline = after_start if after_start.exists() else _auto_snapshot(args.status, "early")
            start = start or _auto_snapshot(args.status, "after-start")
            fire = fire or _auto_snapshot(args.status, "after-fire")
            movement = movement or _auto_snapshot(args.status, "after-move")
            use = use or _auto_snapshot(args.status, "after-use")
            mouse = mouse or _auto_snapshot(args.status, "after-mouse")
            menu = menu or _auto_snapshot(args.status, "after-menu")
        snapshots = {
            "baseline": _resolve_snapshot(args.baseline, baseline),
            "start": _resolve_snapshot(args.start, start),
            "fire": _resolve_snapshot(args.fire, fire),
            "movement": _resolve_snapshot(args.movement, movement),
            "use": _resolve_snapshot(args.use, use),
            "mouse": _resolve_snapshot(args.mouse, mouse),
            "menu": _resolve_snapshot(args.menu, menu),
        }
        validate_status(
            status,
            baseline_status=snapshots["baseline"],
            start_status=snapshots["start"],
            fire_status=snapshots["fire"],
            movement_status=snapshots["movement"],
            use_status=snapshots["use"],
            mouse_status=snapshots["mouse"],
            menu_status=snapshots["menu"],
        )
    except (OSError, AssertionError) as exc:
        summary = f"\nstatus summary: {summarize_status(status)}" if status else ""
        print(f"real-WAD proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    print(
        "real-WAD proof OK: system, storage, process, audio/input telemetry, "
        "non-pixel visual, gameplay, and scripted playability status are nontrivial"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
