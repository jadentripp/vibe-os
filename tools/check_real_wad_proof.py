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
}

HEX_FIELDS = (
    "target",
    "argv0",
    "doomwrite",
    "doomseek",
    "doomclose",
    "doomsbrk",
    "doomerr",
    "doompresent",
    "doompal",
    "doomframe",
    "doomnonzero",
    "doomcolors",
    "gtic",
    "leveltime",
    "gflags",
    "gaction",
    "pflags",
    "pbuttons",
    "pdelta",
    "doomsound",
    "sfxmix",
    "voices",
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
    "keyirq",
    "keyqueue",
    "keypoll",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "preempt",
    "pattempt",
    "pskip",
    "free",
    "ticks",
)

FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")


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


def _sample_field(status: str, name: str) -> tuple[int, int, int]:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be three eight-digit hex samples, got {value!r}")
    samples = tuple(int(part, 16) for part in value.split(":"))
    for sample in samples:
        if sample > 0xff:
            raise AssertionError(f"{name}= samples must be indexed color bytes, got {sample:#x}")
    return samples


def _position_field(status: str, name: str) -> None:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be two eight-digit hex coordinates, got {value!r}")


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
    _choice_field(status, "audio", ("SB16", "NONE"))
    _choice_field(status, "mouse", ("OK", "NONE"))
    _open_mode_field(status, "doommode")
    _position_field(status, "ppos")

    attempts, successes, failures, handoffs, scheduled, rollbacks = _hex_tuple_field(
        status, "execsys", 6
    )
    if attempts == 0 or successes == 0 or handoffs == 0 or scheduled == 0:
        raise AssertionError("execsys= must prove a successful syscall exec handoff")
    if failures != 0 or rollbacks != 0:
        raise AssertionError("execsys= must not report failures or rollbacks in real-WAD proof")

    _hex_field_gt(status, "target", 0)
    _hex_field_gt(status, "argv0", 0)
    _hex_field_gt(status, "doomseek", 0)
    _hex_field_gt(status, "doomsbrk", 0)
    if _hex_field(status, "doomerr") != 0:
        raise AssertionError("doomerr= must be zero")
    _hex_field_gt(status, "free", 0)
    _hex_field_gt(status, "ticks", 0)
    _hex_field_gt(status, "pattempt", 0)


def validate_status(
    status: str,
    baseline_status: str | None = None,
    movement_status: str | None = None,
    fire_status: str | None = None,
    use_status: str | None = None,
    menu_status: str | None = None,
    reject_patterns: tuple[str, ...] = DEFAULT_REJECT_PATTERNS,
) -> None:
    _validate_core_status(status)
    _hex_field_gt(status, "leveltime", 0)
    _hex_field_gt(status, "doompresent", 0)
    _hex_field_gt(status, "doompal", 0)
    _hex_field_gt(status, "doomframe", 0)
    _hex_field_gt(status, "doomnonzero", 1024)
    _hex_field_gt(status, "doomcolors", 64)
    _sample_field(status, "doomsamp")
    check_human_playability_proof.validate_status(
        status,
        baseline_status,
        movement_status=movement_status,
        fire_status=fire_status,
        use_status=use_status,
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
    parser.add_argument("--movement", type=Path, help="Decoded status after scripted movement")
    parser.add_argument("--fire", type=Path, help="Decoded status after scripted fire")
    parser.add_argument("--use", type=Path, help="Decoded status after scripted use")
    parser.add_argument("--menu", type=Path, help="Decoded status after scripted menu toggle")
    parser.add_argument(
        "--no-auto-snapshots",
        action="store_true",
        help="Only use explicitly supplied snapshot paths",
    )
    args = parser.parse_args(argv)

    try:
        status = args.status.read_text()
        baseline = args.baseline
        fire = args.fire
        movement = args.movement
        use = args.use
        menu = args.menu
        if not args.no_auto_snapshots:
            baseline = baseline or _auto_snapshot(args.status, "early")
            fire = fire or _auto_snapshot(args.status, "after-fire")
            movement = movement or _auto_snapshot(args.status, "after-move")
            use = use or _auto_snapshot(args.status, "after-use")
            menu = menu or _auto_snapshot(args.status, "after-menu")
        validate_status(
            status,
            baseline_status=_resolve_snapshot(args.baseline, baseline),
            fire_status=_resolve_snapshot(args.fire, fire),
            movement_status=_resolve_snapshot(args.movement, movement),
            use_status=_resolve_snapshot(args.use, use),
            menu_status=_resolve_snapshot(args.menu, menu),
        )
    except (OSError, AssertionError) as exc:
        print(f"real-WAD proof failed: {exc}", file=sys.stderr)
        return 1

    print(
        "real-WAD proof OK: system, storage, process, audio/input telemetry, "
        "non-pixel visual, gameplay, and scripted playability status are nontrivial"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
