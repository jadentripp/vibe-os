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
MOUSE_EVENT_COUNTERS = ("mouseirq", "mousepkt", "mousepoll")
RUN_COUNTERS = ("gtic", "leveltime")
MENU_ACTIVE_FLAG = 0x1
KEY_SEEN_UP = 0x00000001
KEY_SEEN_FIRE = 0x00000010
KEY_SEEN_USE = 0x00000020
KEY_SEEN_MENU = 0x00000040
REQUIRED_SCRIPTED_KEYS = KEY_SEEN_UP | KEY_SEEN_FIRE | KEY_SEEN_USE | KEY_SEEN_MENU
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
REQUIRED_FINAL_PFLAGS_WITH_USE_SNAPSHOT = (
    PFLAG_PLAYER
    | PFLAG_MOVE_CMD
    | PFLAG_ATTACK_CMD
    | PFLAG_MENU
    | PFLAG_POS_DELTA
)
REQUIRED_FIRE_STATE_PFLAGS = PFLAG_AMMO_DELTA | PFLAG_REFIRE

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
    "keyseen",
    "keylast",
    "mouse",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "mousebtn",
    "mousedelta",
    "doomrun",
    "doomopen",
    "doomread",
    "doomerr",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
    "fault",
    "panic",
    "shutdown",
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


def _assert_position_changed(before: str, after: str, before_label: str, after_label: str) -> None:
    before_pos = _position_field(before, "ppos")
    after_pos = _position_field(after, "ppos")
    if after_pos == before_pos:
        raise AssertionError(
            f"{after_label} ppos= must differ from {before_label}, got "
            f"{after_pos[0]:08X}:{after_pos[1]:08X}"
        )


def _flag_names(mask: int) -> str:
    names = [name for flag, name in PFLAG_NAMES.items() if mask & flag]
    return ", ".join(names) if names else f"{mask:#x}"


def _require_pflags(status: str, mask: int) -> int:
    flags = _hex_field(status, "pflags")
    missing = mask & ~flags
    if missing:
        raise AssertionError(f"pflags= missing {_flag_names(missing)}")
    return flags


def _require_any_pflag(status: str, mask: int, label: str) -> int:
    flags = _hex_field(status, "pflags")
    if not (flags & mask):
        raise AssertionError(f"{label} pflags= missing one of {_flag_names(mask)}")
    return flags


def _require_keyseen(status: str, mask: int, label: str) -> int:
    seen = _hex_field(status, "keyseen")
    missing = mask & ~seen
    if missing:
        raise AssertionError(f"{label} keyseen= missing scripted key bit(s) {missing:08X}")
    return seen


def _assert_increasing(baseline: str, final: str, names: tuple[str, ...]) -> None:
    for name in names:
        before = _hex_field(baseline, name)
        after = _hex_field(final, name)
        if after <= before:
            raise AssertionError(
                f"{name}= must increase from baseline to final, got {before:08X}->{after:08X}"
            )


def _assert_not_decreasing(baseline: str, final: str, names: tuple[str, ...]) -> None:
    for name in names:
        before = _hex_field(baseline, name)
        after = _hex_field(final, name)
        if after < before:
            raise AssertionError(
                f"{name}= must not decrease across snapshots, got {before:08X}->{after:08X}"
            )


def _assert_pair_any_component_increasing(baseline: str, final: str, name: str) -> None:
    before_left, before_right = _position_field(baseline, name)
    after_left, after_right = _position_field(final, name)
    if after_left <= before_left and after_right <= before_right:
        raise AssertionError(
            f"{name}= must increase in at least one component, got "
            f"{before_left:08X}:{before_right:08X}->{after_left:08X}:{after_right:08X}"
        )


def _assert_pair_not_decreasing(baseline: str, final: str, name: str) -> None:
    before_left, before_right = _position_field(baseline, name)
    after_left, after_right = _position_field(final, name)
    if after_left < before_left or after_right < before_right:
        raise AssertionError(
            f"{name}= must not decrease across snapshots, got "
            f"{before_left:08X}:{before_right:08X}->{after_left:08X}:{after_right:08X}"
        )


def _assert_keyboard_phase_progression(
    baseline_status: str | None,
    fire_status: str | None,
    movement_status: str | None,
    use_status: str | None,
    menu_status: str | None,
) -> None:
    previous_label = "baseline"
    previous_status = baseline_status
    for label, snapshot in (
        ("fire", fire_status),
        ("movement", movement_status),
        ("use", use_status),
        ("menu", menu_status),
    ):
        if previous_status is not None and snapshot is not None:
            try:
                _assert_increasing(previous_status, snapshot, KEY_EVENT_COUNTERS)
                _assert_increasing(previous_status, snapshot, RUN_COUNTERS)
            except AssertionError as exc:
                raise AssertionError(
                    f"{label} snapshot must advance keyboard/runtime counters after {previous_label}: {exc}"
                ) from exc
        if snapshot is not None:
            previous_label = label
            previous_status = snapshot


def _require_level_snapshot(snapshot: str, label: str) -> None:
    if _field(snapshot, "gameplay") != "OK":
        raise AssertionError(f"{label} snapshot gameplay=OK is required")
    _hex_field_eq(snapshot, "gstate", 0, "GS_LEVEL (00000000)")
    _hex_field_eq(snapshot, "gmap", 0x00000101, "E1M1 (00000101)")
    for name in RUN_COUNTERS:
        _hex_field_gt(snapshot, name, 0)


def _require_menu_inactive(snapshot: str, label: str) -> None:
    if _hex_field(snapshot, "gflags") & MENU_ACTIVE_FLAG:
        raise AssertionError(f"{label} snapshot gflags= must not have the menu-active bit")


def validate_status(
    final_status: str,
    baseline_status: str | None = None,
    start_status: str | None = None,
    movement_status: str | None = None,
    fire_status: str | None = None,
    use_status: str | None = None,
    mouse_status: str | None = None,
    menu_status: str | None = None,
    reject_patterns: tuple[str, ...] = DEFAULT_REJECT_PATTERNS,
) -> None:
    """Validate that status artifacts prove keyboard playability without pixels."""

    _status_fields(final_status)
    for label, snapshot in (
        ("baseline", baseline_status),
        ("start", start_status),
        ("movement", movement_status),
        ("fire", fire_status),
        ("use", use_status),
        ("mouse", mouse_status),
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
    _hex_field(final_status, "keylast")
    _require_keyseen(final_status, REQUIRED_SCRIPTED_KEYS, "final")

    _position_field(final_status, "ppos")
    _hex_field_gt(final_status, "pdelta", 0)
    _hex_field_gt(final_status, "gflags", 0)
    if not (_hex_field(final_status, "gflags") & MENU_ACTIVE_FLAG):
        raise AssertionError("gflags= must have the menu-active bit set after scripted Escape")
    _hex_field(final_status, "gaction")
    _hex_field(final_status, "pbuttons")
    final_required_pflags = (
        REQUIRED_FINAL_PFLAGS_WITH_USE_SNAPSHOT
        if use_status is not None
        else REQUIRED_PFLAGS
    )
    _require_pflags(final_status, final_required_pflags)
    _require_any_pflag(final_status, REQUIRED_FIRE_STATE_PFLAGS, "final fire-state proof")

    if baseline_status is not None:
        _assert_increasing(baseline_status, final_status, KEY_EVENT_COUNTERS)
        _assert_increasing(baseline_status, final_status, RUN_COUNTERS)

    if start_status is not None:
        _require_level_snapshot(start_status, "start")
        _require_menu_inactive(start_status, "start")
        _position_field(start_status, "ppos")
        if baseline_status is not None:
            _assert_not_decreasing(baseline_status, start_status, RUN_COUNTERS)

    _assert_keyboard_phase_progression(
        start_status or baseline_status,
        fire_status,
        movement_status,
        use_status,
        menu_status,
    )

    if movement_status is not None:
        _require_level_snapshot(movement_status, "movement")
        _require_keyseen(movement_status, KEY_SEEN_UP, "movement snapshot")
        _require_pflags(movement_status, PFLAG_PLAYER | PFLAG_MOVE_CMD | PFLAG_POS_DELTA)
        _hex_field_gt(movement_status, "pdelta", 0)
        if start_status is not None:
            _assert_position_changed(start_status, movement_status, "start", "movement")

    if fire_status is not None:
        _require_level_snapshot(fire_status, "fire")
        _require_keyseen(fire_status, KEY_SEEN_FIRE, "fire snapshot")
        _require_pflags(fire_status, PFLAG_PLAYER | PFLAG_ATTACK_CMD)
        _require_any_pflag(fire_status, REQUIRED_FIRE_STATE_PFLAGS, "fire snapshot")

    if use_status is not None:
        _require_level_snapshot(use_status, "use")
        _require_keyseen(use_status, KEY_SEEN_USE, "use snapshot")
        _require_pflags(use_status, PFLAG_PLAYER | PFLAG_USE_CMD)

    if mouse_status is not None:
        _require_level_snapshot(mouse_status, "mouse")
        if _field(mouse_status, "mouse") != "OK":
            raise AssertionError("mouse snapshot mouse=OK is required when --mouse is supplied")
        for name in MOUSE_EVENT_COUNTERS:
            _hex_field_gt(mouse_status, name, 0)
        mouse_buttons = _hex_field(mouse_status, "mousebtn")
        if mouse_buttons == 0:
            raise AssertionError("mousebtn= must record a scripted mouse button press")
        mouse_dx, mouse_dy = _position_field(mouse_status, "mousedelta")
        if mouse_dx == 0 and mouse_dy == 0:
            raise AssertionError("mousedelta= must record nonzero movement from the mouse phase")
        if baseline_status is not None:
            _assert_increasing(baseline_status, mouse_status, MOUSE_EVENT_COUNTERS)
            _assert_pair_any_component_increasing(baseline_status, mouse_status, "mousedelta")
        _assert_not_decreasing(mouse_status, final_status, MOUSE_EVENT_COUNTERS)
        _assert_pair_not_decreasing(mouse_status, final_status, "mousedelta")
        if _field(final_status, "mouse") != "OK":
            raise AssertionError("final status mouse=OK is required when --mouse is supplied")
        if _hex_field(final_status, "mousebtn") == 0:
            raise AssertionError("final status mousebtn= must retain a scripted mouse button press")

    if menu_status is not None:
        _require_level_snapshot(menu_status, "menu")
        _require_keyseen(menu_status, KEY_SEEN_MENU, "menu snapshot")
        _require_pflags(menu_status, PFLAG_MENU)
        if not (_hex_field(menu_status, "gflags") & MENU_ACTIVE_FLAG):
            raise AssertionError("menu snapshot gflags= must have the menu-active bit set")
        if start_status is not None:
            _require_menu_inactive(start_status, "start")

    for pattern in reject_patterns:
        if re.search(pattern, final_status, re.IGNORECASE):
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
    parser.add_argument("final_status", type=Path, help="Decoded final build/status.txt")
    parser.add_argument(
        "--baseline",
        type=Path,
        help="Decoded pre-input status after Doom autostarts, such as build/status.after-start.txt",
    )
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

    final_status = ""
    try:
        final_status = args.final_status.read_text()
        baseline = args.baseline
        start = args.start
        movement = args.movement
        fire = args.fire
        use = args.use
        mouse = args.mouse
        menu = args.menu
        if not args.no_auto_snapshots:
            if baseline is None:
                early = _auto_snapshot(args.final_status, "early")
                after_start = _auto_snapshot(args.final_status, "after-start")
                baseline = early if early.exists() else after_start
            start = start or _auto_snapshot(args.final_status, "after-start")
            fire = fire or _auto_snapshot(args.final_status, "after-fire")
            movement = movement or _auto_snapshot(args.final_status, "after-move")
            use = use or _auto_snapshot(args.final_status, "after-use")
            mouse = mouse or _auto_snapshot(args.final_status, "after-mouse")
            menu = menu or _auto_snapshot(args.final_status, "after-menu")
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
            final_status,
            snapshots["baseline"],
            start_status=snapshots["start"],
            movement_status=snapshots["movement"],
            fire_status=snapshots["fire"],
            use_status=snapshots["use"],
            mouse_status=snapshots["mouse"],
            menu_status=snapshots["menu"],
        )
    except (OSError, AssertionError) as exc:
        summary = f"\nstatus summary: {summarize_status(final_status)}" if final_status else ""
        print(f"human-playability proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    print(
        "human-playability proof OK: scripted start/fire/use/move/mouse/menu changed Doom state without WAD pixels"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
