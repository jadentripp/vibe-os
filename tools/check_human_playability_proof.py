#!/usr/bin/env python3
"""Validate non-pixel human-playability signals from smoke status artifacts."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


DEFAULT_REJECT_PATTERNS = (
    r"doom error",
    r"i_error",
    r"pnames not found",
    r"w_getnumforname",
    r"w_cachelumpnum",
    r"r_inittextures",
)

KEY_EVENT_COUNTERS = ("keyirq", "keyqueue", "keypoll")
RUN_COUNTERS = ("gtic", "leveltime")
MENU_ACTIVE_FLAG = 0x1
PFLAG_PLAYER = 0x0001
PFLAG_MOVE_CMD = 0x0002
PFLAG_ATTACK_CMD = 0x0004
PFLAG_USE_CMD = 0x0008
PFLAG_MENU = 0x0010
PFLAG_POS_DELTA = 0x0020
PFLAG_AMMO_DELTA = 0x0040
PFLAG_REFIRE = 0x0080

PFLAG_NAMES = {
    PFLAG_PLAYER: "player",
    PFLAG_MOVE_CMD: "move command",
    PFLAG_ATTACK_CMD: "attack command",
    PFLAG_USE_CMD: "use command",
    PFLAG_MENU: "menu",
    PFLAG_POS_DELTA: "position delta",
    PFLAG_AMMO_DELTA: "ammo delta",
    PFLAG_REFIRE: "refire",
}
REQUIRED_PFLAGS = (
    PFLAG_PLAYER
    | PFLAG_MOVE_CMD
    | PFLAG_ATTACK_CMD
    | PFLAG_USE_CMD
    | PFLAG_MENU
    | PFLAG_POS_DELTA
)

FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
SUMMARY_FIELDS = (
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "doompresent",
    "gflags",
    "gaction",
    "pflags",
    "pbuttons",
    "ppos",
    "pdelta",
    "keyirq",
    "keyqueue",
    "keypoll",
    "doomrun",
    "doomopen",
    "doomread",
    "doomerr",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
    "fault",
    "gfx",
    "usr",
)


def _status_fields(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise AssertionError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    return fields


def summarize_status(status: str) -> str:
    """Return the playability fields most useful in cloud CI logs."""

    try:
        fields = _status_fields(status)
    except AssertionError as exc:
        return f"unparseable status: {exc}"
    return " ".join(f"{name}={fields.get(name, '<missing>')}" for name in SUMMARY_FIELDS)


def _field(status: str, name: str) -> str:
    fields = _status_fields(status)
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"missing {name}= field")
    return value


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


def _hex_field_eq(status: str, name: str, expected: int, label: str) -> None:
    parsed = _hex_field(status, name)
    if parsed != expected:
        raise AssertionError(f"{name}= must be {label}, got {parsed:08X}")


def _position_field(status: str, name: str) -> tuple[int, int]:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be two eight-digit hex coordinates, got {value!r}")
    left, right = value.split(":")
    return int(left, 16), int(right, 16)


def _flag_names(mask: int) -> str:
    names = [name for flag, name in PFLAG_NAMES.items() if mask & flag]
    return ", ".join(names) if names else f"{mask:#x}"


def _require_pflags(status: str, mask: int) -> int:
    flags = _hex_field(status, "pflags")
    missing = mask & ~flags
    if missing:
        raise AssertionError(f"pflags= missing {_flag_names(missing)}")
    return flags


def _assert_increasing(baseline: str, final: str, names: tuple[str, ...]) -> None:
    for name in names:
        before = _hex_field(baseline, name)
        after = _hex_field(final, name)
        if after <= before:
            raise AssertionError(
                f"{name}= must increase from baseline to final, got {before:08X}->{after:08X}"
            )


def validate_status(
    final_status: str,
    baseline_status: str | None = None,
    movement_status: str | None = None,
    fire_status: str | None = None,
    use_status: str | None = None,
    menu_status: str | None = None,
    reject_patterns: tuple[str, ...] = DEFAULT_REJECT_PATTERNS,
) -> None:
    """Validate that status artifacts prove keyboard playability without pixels."""

    _status_fields(final_status)
    for label, snapshot in (
        ("baseline", baseline_status),
        ("movement", movement_status),
        ("fire", fire_status),
        ("use", use_status),
        ("menu", menu_status),
    ):
        if snapshot is not None:
            try:
                _status_fields(snapshot)
            except AssertionError as exc:
                raise AssertionError(f"{label} snapshot: {exc}") from exc

    if _field(final_status, "gameplay") != "OK":
        raise AssertionError("gameplay=OK is required")
    _hex_field_eq(final_status, "gstate", 0, "GS_LEVEL (00000000)")
    _hex_field_eq(final_status, "gmap", 0x00000101, "E1M1 (00000101)")

    for name in RUN_COUNTERS:
        _hex_field_gt(final_status, name, 0)
    _hex_field_gt(final_status, "doompresent", 0)

    for name in KEY_EVENT_COUNTERS:
        _hex_field_gt(final_status, name, 0)

    _position_field(final_status, "ppos")
    _hex_field_gt(final_status, "pdelta", 0)
    _hex_field_gt(final_status, "gflags", 0)
    if not (_hex_field(final_status, "gflags") & MENU_ACTIVE_FLAG):
        raise AssertionError("gflags= must have the menu-active bit set after scripted Escape")
    _hex_field(final_status, "gaction")
    _hex_field(final_status, "pbuttons")
    _require_pflags(final_status, REQUIRED_PFLAGS)

    if baseline_status is not None:
        _assert_increasing(baseline_status, final_status, KEY_EVENT_COUNTERS)
        _assert_increasing(baseline_status, final_status, RUN_COUNTERS)

    if movement_status is not None:
        if _field(movement_status, "gameplay") != "OK":
            raise AssertionError("movement snapshot gameplay=OK is required")
        _hex_field_eq(movement_status, "gmap", 0x00000101, "E1M1 (00000101)")
        _require_pflags(movement_status, PFLAG_PLAYER | PFLAG_MOVE_CMD | PFLAG_POS_DELTA)
        _hex_field_gt(movement_status, "pdelta", 0)

    if fire_status is not None:
        if _field(fire_status, "gameplay") != "OK":
            raise AssertionError("fire snapshot gameplay=OK is required")
        _hex_field_eq(fire_status, "gmap", 0x00000101, "E1M1 (00000101)")
        _require_pflags(fire_status, PFLAG_PLAYER | PFLAG_ATTACK_CMD)

    if use_status is not None:
        if _field(use_status, "gameplay") != "OK":
            raise AssertionError("use snapshot gameplay=OK is required")
        _hex_field_eq(use_status, "gmap", 0x00000101, "E1M1 (00000101)")
        _require_pflags(use_status, PFLAG_PLAYER | PFLAG_USE_CMD)

    if menu_status is not None:
        if _field(menu_status, "gameplay") != "OK":
            raise AssertionError("menu snapshot gameplay=OK is required")
        _hex_field_eq(menu_status, "gmap", 0x00000101, "E1M1 (00000101)")
        _require_pflags(menu_status, PFLAG_MENU)
        if not (_hex_field(menu_status, "gflags") & MENU_ACTIVE_FLAG):
            raise AssertionError("menu snapshot gflags= must have the menu-active bit set")

    for pattern in reject_patterns:
        if re.search(pattern, final_status, re.IGNORECASE):
            raise AssertionError(f"rejected Doom error string matched: {pattern}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("final_status", type=Path, help="Decoded final build/status.txt")
    parser.add_argument(
        "--baseline",
        type=Path,
        help="Decoded pre-injection status, such as build/status.early.txt",
    )
    parser.add_argument("--movement", type=Path, help="Decoded status after scripted movement")
    parser.add_argument("--fire", type=Path, help="Decoded status after scripted fire")
    parser.add_argument("--use", type=Path, help="Decoded status after scripted use")
    parser.add_argument("--menu", type=Path, help="Decoded status after scripted menu toggle")
    args = parser.parse_args(argv)

    final_status = ""
    try:
        final_status = args.final_status.read_text()
        baseline_status = args.baseline.read_text() if args.baseline else None
        movement_status = args.movement.read_text() if args.movement else None
        fire_status = args.fire.read_text() if args.fire else None
        use_status = args.use.read_text() if args.use else None
        menu_status = args.menu.read_text() if args.menu else None
        validate_status(
            final_status,
            baseline_status,
            movement_status=movement_status,
            fire_status=fire_status,
            use_status=use_status,
            menu_status=menu_status,
        )
    except (OSError, AssertionError) as exc:
        summary = f"\nstatus summary: {summarize_status(final_status)}" if final_status else ""
        print(f"human-playability proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    print(
        "human-playability proof OK: scripted fire/use/move/menu changed Doom status without WAD pixels"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
