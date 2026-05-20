#!/usr/bin/env python3
"""Validate scripted Doom gameplay transitions from decoded status snapshots."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
PLAYABLE_DOC = ROOT / "docs" / "playable-cloud-proof.md"
MAKEFILE = ROOT / "Makefile"

SCHEMA = "scripted-gameplay-proof-v1"
SOURCE = "real-wad-cloud-scripted-gameplay"
GATE = "tools/check_scripted_gameplay_proof.py"

FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
PHASE_ORDER = ("start", "fire", "movement", "use", "mouse", "menu", "final")
AUTO_STATUS_NAMES = {
    "start": "status.after-start.txt",
    "fire": "status.after-fire.txt",
    "movement": "status.after-move.txt",
    "use": "status.after-use.txt",
    "mouse": "status.after-mouse.txt",
    "menu": "status.after-menu.txt",
    "final": "status.txt",
}

RUN_COUNTERS = ("gtic", "leveltime")
KEY_COUNTERS = ("keyirq", "keyqueue", "keypoll")
MOUSE_COUNTERS = ("mouseirq", "mousepkt", "mousepoll")

MENU_ACTIVE_FLAG = 0x1
KEY_SEEN_UP = 0x00000001
KEY_SEEN_FIRE = 0x00000010
KEY_SEEN_USE = 0x00000020
KEY_SEEN_MENU = 0x00000040
SCRIPTED_KEY_MASK = KEY_SEEN_UP | KEY_SEEN_FIRE | KEY_SEEN_USE | KEY_SEEN_MENU

PFLAG_PLAYER = 0x0001
PFLAG_MOVE_CMD = 0x0002
PFLAG_ATTACK_CMD = 0x0004
PFLAG_USE_CMD = 0x0008
PFLAG_MENU = 0x0010
PFLAG_POS_DELTA = 0x0020
PFLAG_AMMO_DELTA = 0x0040
PFLAG_REFIRE = 0x0080
PFLAG_TURN_CMD = 0x0100
PFLAG_FIRE_STATE = PFLAG_AMMO_DELTA | PFLAG_REFIRE
PFLAG_ACTION_MASK = (
    PFLAG_MOVE_CMD
    | PFLAG_ATTACK_CMD
    | PFLAG_USE_CMD
    | PFLAG_MENU
    | PFLAG_POS_DELTA
    | PFLAG_AMMO_DELTA
    | PFLAG_REFIRE
    | PFLAG_TURN_CMD
)

FLAG_NAMES = {
    PFLAG_PLAYER: "player",
    PFLAG_MOVE_CMD: "move command",
    PFLAG_ATTACK_CMD: "attack command",
    PFLAG_USE_CMD: "use command",
    PFLAG_MENU: "menu",
    PFLAG_POS_DELTA: "position delta",
    PFLAG_AMMO_DELTA: "ammo delta",
    PFLAG_REFIRE: "refire",
    PFLAG_TURN_CMD: "turn command",
}

EXPECTED_SCRIPTED_KEYS = {
    "start": 0,
    "fire": KEY_SEEN_FIRE,
    "movement": KEY_SEEN_FIRE | KEY_SEEN_UP,
    "use": KEY_SEEN_FIRE | KEY_SEEN_UP | KEY_SEEN_USE,
    "mouse": KEY_SEEN_FIRE | KEY_SEEN_UP | KEY_SEEN_USE,
    "menu": KEY_SEEN_FIRE | KEY_SEEN_UP | KEY_SEEN_USE | KEY_SEEN_MENU,
    "final": KEY_SEEN_FIRE | KEY_SEEN_UP | KEY_SEEN_USE | KEY_SEEN_MENU,
}

EXPECTED_PFLAGS = {
    "start": PFLAG_PLAYER,
    "fire": PFLAG_PLAYER | PFLAG_ATTACK_CMD,
    "movement": PFLAG_PLAYER | PFLAG_ATTACK_CMD | PFLAG_MOVE_CMD | PFLAG_POS_DELTA,
    "use": PFLAG_PLAYER | PFLAG_ATTACK_CMD | PFLAG_MOVE_CMD | PFLAG_POS_DELTA | PFLAG_USE_CMD,
    "mouse": (
        PFLAG_PLAYER
        | PFLAG_ATTACK_CMD
        | PFLAG_MOVE_CMD
        | PFLAG_POS_DELTA
        | PFLAG_USE_CMD
        | PFLAG_TURN_CMD
    ),
    "menu": (
        PFLAG_PLAYER
        | PFLAG_ATTACK_CMD
        | PFLAG_MOVE_CMD
        | PFLAG_POS_DELTA
        | PFLAG_USE_CMD
        | PFLAG_MENU
        | PFLAG_TURN_CMD
    ),
    "final": (
        PFLAG_PLAYER
        | PFLAG_ATTACK_CMD
        | PFLAG_MOVE_CMD
        | PFLAG_POS_DELTA
        | PFLAG_USE_CMD
        | PFLAG_MENU
        | PFLAG_TURN_CMD
    ),
}

FORBIDDEN_PFLAGS = {
    "start": PFLAG_ACTION_MASK,
    "fire": PFLAG_MOVE_CMD | PFLAG_USE_CMD | PFLAG_MENU | PFLAG_POS_DELTA | PFLAG_TURN_CMD,
    "movement": PFLAG_USE_CMD | PFLAG_MENU | PFLAG_TURN_CMD,
    "use": PFLAG_MENU | PFLAG_TURN_CMD,
    "mouse": PFLAG_MENU,
}

SUMMARY_FIELDS = (
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "gflags",
    "pflags",
    "ppos",
    "pdelta",
    "pcmd",
    "pangle",
    "pangledelta",
    "pammo",
    "prefire",
    "pweapon",
    "keyirq",
    "keyqueue",
    "keypoll",
    "keyseen",
    "mouse",
    "mouseirq",
    "mousepkt",
    "mousepoll",
    "mousebtn",
    "mousedelta",
)


def _require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label} missing {needle!r}")


def _status_fields(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise AssertionError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    return fields


def summarize_status(status: str) -> str:
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


def _position_field(status: str, name: str) -> tuple[int, int]:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}:[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be two eight-digit hex coordinates, got {value!r}")
    left, right = value.split(":")
    return int(left, 16), int(right, 16)


def _hex8(value: int) -> str:
    return f"{value & 0xFFFFFFFF:08X}"


def _flag_names(mask: int) -> str:
    names = [name for flag, name in FLAG_NAMES.items() if mask & flag]
    return ", ".join(names) if names else f"{mask:#x}"


def _require_level_state(status: str, label: str) -> None:
    if _field(status, "gameplay") != "OK":
        raise AssertionError(f"{label} gameplay=OK is required")
    if _hex_field(status, "gstate") != 0:
        raise AssertionError(f"{label} gstate= must be GS_LEVEL (00000000)")
    if _hex_field(status, "gmap") != 0x00000101:
        raise AssertionError(f"{label} gmap= must be E1M1 (00000101)")
    for name in RUN_COUNTERS:
        if _hex_field(status, name) <= 0:
            raise AssertionError(f"{label} {name}= must be greater than zero")


def _assert_increasing(before: str, after: str, fields: tuple[str, ...], before_label: str, after_label: str) -> None:
    for name in fields:
        before_value = _hex_field(before, name)
        after_value = _hex_field(after, name)
        if after_value <= before_value:
            raise AssertionError(
                f"{after_label} {name}= must increase after {before_label}, "
                f"got {before_value:08X}->{after_value:08X}"
            )


def _assert_not_decreasing(before: str, after: str, fields: tuple[str, ...], before_label: str, after_label: str) -> None:
    for name in fields:
        before_value = _hex_field(before, name)
        after_value = _hex_field(after, name)
        if after_value < before_value:
            raise AssertionError(
                f"{after_label} {name}= must not decrease after {before_label}, "
                f"got {before_value:08X}->{after_value:08X}"
            )


def _require_mask(status: str, field: str, mask: int, label: str) -> int:
    value = _hex_field(status, field)
    missing = mask & ~value
    if missing:
        if field == "pflags":
            missing_text = _flag_names(missing)
        else:
            missing_text = _hex8(missing)
        raise AssertionError(f"{label} {field}= missing {missing_text}")
    return value


def _reject_mask(status: str, field: str, mask: int, label: str) -> None:
    value = _hex_field(status, field)
    present = value & mask
    if present:
        if field == "pflags":
            present_text = _flag_names(present)
        else:
            present_text = _hex8(present)
        raise AssertionError(f"{label} {field}= unexpectedly has {present_text}")


def _require_any_mask(status: str, field: str, mask: int, label: str) -> int:
    value = _hex_field(status, field)
    if not (value & mask):
        raise AssertionError(f"{label} {field}= missing one of {_flag_names(mask)}")
    return value


def _require_scripted_key_state(status: str, label: str, expected: int) -> int:
    seen = _hex_field(status, "keyseen")
    actual = seen & SCRIPTED_KEY_MASK
    if actual != expected:
        raise AssertionError(
            f"{label} keyseen= scripted bits must be {_hex8(expected)}, got {_hex8(actual)}"
        )
    return seen


def _assert_mask_superset(
    before: str,
    after: str,
    field: str,
    before_label: str,
    after_label: str,
    mask: int,
) -> None:
    before_value = _hex_field(before, field) & mask
    after_value = _hex_field(after, field) & mask
    missing = before_value & ~after_value
    if missing:
        if field == "pflags":
            missing_text = _flag_names(missing)
        else:
            missing_text = _hex8(missing)
        raise AssertionError(
            f"{after_label} {field}= must retain {before_label} proof bits: {missing_text}"
        )


def _require_clean_start(start: str) -> None:
    _require_level_state(start, "start")
    if _hex_field(start, "gflags") & MENU_ACTIVE_FLAG:
        raise AssertionError("start gflags= must not have the menu-active bit")
    _require_scripted_key_state(start, "start", 0)
    _require_mask(start, "pflags", PFLAG_PLAYER, "start")
    _reject_mask(start, "pflags", PFLAG_ACTION_MASK, "start")
    if _hex_field(start, "pdelta") != 0:
        raise AssertionError("start pdelta= must be zero before scripted movement")
    if _hex_field(start, "pangledelta") != 0:
        raise AssertionError("start pangledelta= must be zero before scripted mouse turn")
    _position_field(start, "ppos")
    for name in ("pcmd", "pangle", "pammo", "prefire", "pweapon"):
        _hex_field(start, name)


def _require_phase_masks(snapshots: dict[str, str]) -> None:
    for phase in PHASE_ORDER:
        status = snapshots[phase]
        _require_level_state(status, phase)
        for name in ("pcmd", "pangle", "pangledelta", "pammo", "prefire", "pweapon"):
            _hex_field(status, name)
        _require_scripted_key_state(status, phase, EXPECTED_SCRIPTED_KEYS[phase])
        _require_mask(status, "pflags", EXPECTED_PFLAGS[phase], phase)
        if phase != "start":
            _require_mask(status, "pflags", PFLAG_FIRE_STATE, phase)
        forbidden = FORBIDDEN_PFLAGS.get(phase, 0)
        if forbidden:
            _reject_mask(status, "pflags", forbidden, phase)


def _require_timeline(snapshots: dict[str, str]) -> None:
    previous_phase = "start"
    previous_status = snapshots[previous_phase]
    for phase in ("fire", "movement", "use", "mouse", "menu"):
        status = snapshots[phase]
        _assert_increasing(previous_status, status, RUN_COUNTERS, previous_phase, phase)
        _assert_mask_superset(previous_status, status, "keyseen", previous_phase, phase, SCRIPTED_KEY_MASK)
        _assert_mask_superset(previous_status, status, "pflags", previous_phase, phase, PFLAG_ACTION_MASK | PFLAG_PLAYER)
        previous_phase = phase
        previous_status = status

    _assert_not_decreasing(snapshots["menu"], snapshots["final"], RUN_COUNTERS, "menu", "final")
    _assert_mask_superset(snapshots["menu"], snapshots["final"], "keyseen", "menu", "final", SCRIPTED_KEY_MASK)
    _assert_mask_superset(
        snapshots["menu"],
        snapshots["final"],
        "pflags",
        "menu",
        "final",
        PFLAG_ACTION_MASK | PFLAG_PLAYER,
    )

    _assert_increasing(snapshots["start"], snapshots["fire"], KEY_COUNTERS, "start", "fire")
    _assert_increasing(snapshots["fire"], snapshots["movement"], KEY_COUNTERS, "fire", "movement")
    _assert_increasing(snapshots["movement"], snapshots["use"], KEY_COUNTERS, "movement", "use")
    _assert_not_decreasing(snapshots["use"], snapshots["mouse"], KEY_COUNTERS, "use", "mouse")
    _assert_increasing(snapshots["mouse"], snapshots["menu"], KEY_COUNTERS, "mouse", "menu")
    _assert_not_decreasing(snapshots["menu"], snapshots["final"], KEY_COUNTERS, "menu", "final")


def _require_movement(snapshots: dict[str, str]) -> None:
    start_pos = _position_field(snapshots["start"], "ppos")
    move_pos = _position_field(snapshots["movement"], "ppos")
    if start_pos == move_pos:
        raise AssertionError(
            "movement ppos= must differ from start, got "
            f"{move_pos[0]:08X}:{move_pos[1]:08X}"
        )
    if _hex_field(snapshots["movement"], "pdelta") <= _hex_field(snapshots["start"], "pdelta"):
        raise AssertionError("movement pdelta= must increase from start")
    _assert_not_decreasing(snapshots["movement"], snapshots["final"], ("pdelta",), "movement", "final")


def _require_fire_state(snapshots: dict[str, str]) -> None:
    start_ammo = _hex_field(snapshots["start"], "pammo")
    fire_ammo = _hex_field(snapshots["fire"], "pammo")
    start_refire = _hex_field(snapshots["start"], "prefire")
    fire_refire = _hex_field(snapshots["fire"], "prefire")

    if fire_ammo >= start_ammo and fire_refire <= start_refire:
        raise AssertionError(
            "fire pammo=/prefire= must prove Doom weapon state changed, "
            f"got ammo {start_ammo:08X}->{fire_ammo:08X} and refire {start_refire:08X}->{fire_refire:08X}"
        )


def _require_mouse(snapshots: dict[str, str]) -> None:
    mouse = snapshots["mouse"]
    if _field(mouse, "mouse") != "OK":
        raise AssertionError("mouse snapshot mouse=OK is required")
    _require_mask(mouse, "pflags", PFLAG_TURN_CMD, "mouse")
    _assert_increasing(snapshots["start"], mouse, MOUSE_COUNTERS, "start", "mouse")
    if _hex_field(mouse, "mousebtn") == 0:
        raise AssertionError("mouse mousebtn= must record a scripted button press")
    mouse_dx, mouse_dy = _position_field(mouse, "mousedelta")
    if mouse_dx == 0 and mouse_dy == 0:
        raise AssertionError("mouse mousedelta= must record scripted motion")
    if _hex_field(mouse, "pangle") == _hex_field(snapshots["start"], "pangle"):
        raise AssertionError("mouse pangle= must differ from start after scripted mouse turn")
    if _hex_field(mouse, "pangledelta") == 0:
        raise AssertionError("mouse pangledelta= must record a Doom player-angle change")
    _assert_not_decreasing(mouse, snapshots["final"], MOUSE_COUNTERS, "mouse", "final")
    _assert_not_decreasing(mouse, snapshots["final"], ("pangledelta",), "mouse", "final")
    if _hex_field(snapshots["final"], "mousebtn") == 0:
        raise AssertionError("final mousebtn= must retain scripted button proof")


def _require_menu(snapshots: dict[str, str]) -> None:
    for phase in ("start", "fire", "movement", "use", "mouse"):
        if _hex_field(snapshots[phase], "gflags") & MENU_ACTIVE_FLAG:
            raise AssertionError(f"{phase} gflags= must not have the menu-active bit before Escape")
    for phase in ("menu", "final"):
        if not (_hex_field(snapshots[phase], "gflags") & MENU_ACTIVE_FLAG):
            raise AssertionError(f"{phase} gflags= must have the menu-active bit after Escape")


def validate_statuses(snapshots: dict[str, str]) -> None:
    missing = [phase for phase in PHASE_ORDER if phase not in snapshots or snapshots[phase] is None]
    if missing:
        raise AssertionError("missing scripted gameplay snapshot(s): " + ", ".join(missing))
    for phase, status in snapshots.items():
        try:
            _status_fields(status)
        except AssertionError as exc:
            raise AssertionError(f"{phase} snapshot: {exc}") from exc

    _require_clean_start(snapshots["start"])
    _require_phase_masks(snapshots)
    _require_timeline(snapshots)
    _require_movement(snapshots)
    _require_fire_state(snapshots)
    _require_mouse(snapshots)
    _require_menu(snapshots)


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def build_manifest(snapshots: dict[str, str], paths: dict[str, Path] | None = None) -> dict:
    validate_statuses(snapshots)

    status_files = {}
    for phase in PHASE_ORDER:
        status_bytes = snapshots[phase].encode()
        path = paths.get(phase) if paths else None
        if path is not None and path.exists():
            status_bytes = path.read_bytes()
        status_files[phase] = {
            "path": path.name if path is not None else AUTO_STATUS_NAMES[phase],
            "bytes": len(status_bytes),
            "sha256": _sha256_bytes(status_bytes),
        }

    start = snapshots["start"]
    movement = snapshots["movement"]
    mouse = snapshots["mouse"]
    final = snapshots["final"]

    return {
        "schema": SCHEMA,
        "source": SOURCE,
        "generated_by": GATE,
        "gate": GATE,
        "phase_order": list(PHASE_ORDER),
        "status_files": status_files,
        "start_state": {
            "gstate": _field(start, "gstate"),
            "gmap": _field(start, "gmap"),
            "gflags": _field(start, "gflags"),
            "pflags": _field(start, "pflags"),
            "keyseen": _field(start, "keyseen"),
            "pdelta": _field(start, "pdelta"),
            "ppos": _field(start, "ppos"),
            "pangle": _field(start, "pangle"),
            "pammo": _field(start, "pammo"),
            "prefire": _field(start, "prefire"),
            "pweapon": _field(start, "pweapon"),
        },
        "transitions": {
            "fire": {
                "keyseen": _field(snapshots["fire"], "keyseen"),
                "pflags": _field(snapshots["fire"], "pflags"),
                "pammo": _field(snapshots["fire"], "pammo"),
                "prefire": _field(snapshots["fire"], "prefire"),
            },
            "movement": {
                "keyseen": _field(movement, "keyseen"),
                "pflags": _field(movement, "pflags"),
                "start_ppos": _field(start, "ppos"),
                "movement_ppos": _field(movement, "ppos"),
                "pdelta": _field(movement, "pdelta"),
            },
            "use": {
                "keyseen": _field(snapshots["use"], "keyseen"),
                "pflags": _field(snapshots["use"], "pflags"),
            },
            "mouse": {
                "mouseirq": _field(mouse, "mouseirq"),
                "mousepkt": _field(mouse, "mousepkt"),
                "mousepoll": _field(mouse, "mousepoll"),
                "mousebtn": _field(mouse, "mousebtn"),
                "mousedelta": _field(mouse, "mousedelta"),
                "pflags": _field(mouse, "pflags"),
                "pangle": _field(mouse, "pangle"),
                "pangledelta": _field(mouse, "pangledelta"),
            },
            "menu": {
                "keyseen": _field(snapshots["menu"], "keyseen"),
                "gflags": _field(snapshots["menu"], "gflags"),
                "pflags": _field(snapshots["menu"], "pflags"),
            },
        },
        "final_state": {
            "gtic": _field(final, "gtic"),
            "leveltime": _field(final, "leveltime"),
            "gflags": _field(final, "gflags"),
            "pflags": _field(final, "pflags"),
            "keyseen": _field(final, "keyseen"),
            "pdelta": _field(final, "pdelta"),
            "pangle": _field(final, "pangle"),
            "pangledelta": _field(final, "pangledelta"),
            "pammo": _field(final, "pammo"),
            "prefire": _field(final, "prefire"),
        },
    }


def validate_manifest(manifest: dict, snapshots: dict[str, str] | None = None, paths: dict[str, Path] | None = None) -> None:
    if manifest.get("schema") != SCHEMA:
        raise AssertionError(f"gameplay proof schema must be {SCHEMA}")
    if manifest.get("source") != SOURCE:
        raise AssertionError(f"gameplay proof source must be {SOURCE}")
    if manifest.get("generated_by") != GATE or manifest.get("gate") != GATE:
        raise AssertionError(f"gameplay proof generated_by/gate must be {GATE}")
    if manifest.get("phase_order") != list(PHASE_ORDER):
        raise AssertionError("gameplay proof phase_order is not the scripted phase order")
    if snapshots is not None:
        expected = build_manifest(snapshots, paths=paths)
        if manifest != expected:
            raise AssertionError("gameplay proof manifest does not match status snapshots")


def _auto_snapshot(final_status: Path, phase: str) -> Path:
    return final_status.with_name(AUTO_STATUS_NAMES[phase])


def _resolve_phase_paths(args: argparse.Namespace) -> dict[str, Path]:
    paths = {
        "start": args.start,
        "fire": args.fire,
        "movement": args.movement,
        "use": args.use,
        "mouse": args.mouse,
        "menu": args.menu,
        "final": args.final_status,
    }
    if not args.no_auto_snapshots:
        for phase in PHASE_ORDER:
            if paths[phase] is None:
                paths[phase] = _auto_snapshot(args.final_status, phase)
    missing = [phase for phase in PHASE_ORDER if paths[phase] is None]
    if missing:
        raise AssertionError("missing scripted gameplay snapshot path(s): " + ", ".join(missing))
    return {phase: path for phase, path in paths.items() if path is not None}


def _read_phase_statuses(paths: dict[str, Path]) -> dict[str, str]:
    snapshots = {}
    for phase in PHASE_ORDER:
        path = paths[phase]
        if not path.exists():
            raise AssertionError(f"missing {phase} status file: {path}")
        snapshots[phase] = path.read_text()
    return snapshots


def validate_repo_contract(root: Path = ROOT) -> None:
    workflow = (root / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
    playable_doc = (root / "docs" / "playable-cloud-proof.md").read_text()
    makefile = (root / "Makefile").read_text()

    for needle in (
        "Assert scripted gameplay transition gates",
        "python3 tools/check_scripted_gameplay_proof.py \\",
        "--write-json build/gameplay-proof.json",
        "build/gameplay-proof.json",
    ):
        _require(workflow, needle, "real-WAD workflow")
    for needle in (
        "tools/check_scripted_gameplay_proof.py",
        "scripted-gameplay-proof-v1",
        "clean E1M1 start",
        "cumulative key/player proof",
        "mouse turn proof",
        "gameplay-proof.json",
    ):
        _require(playable_doc, needle, "playable cloud proof doc")
    _require(makefile, "scripted-gameplay-proof-check", "Makefile")
    _require(makefile, "tools/check_scripted_gameplay_proof.py --repo-contract", "Makefile")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("final_status", nargs="?", type=Path, help="Decoded final build/status.txt")
    parser.add_argument("--start", type=Path, help="Decoded status after Doom autostarts E1M1")
    parser.add_argument("--fire", type=Path, help="Decoded status after scripted fire")
    parser.add_argument("--movement", type=Path, help="Decoded status after scripted movement")
    parser.add_argument("--use", type=Path, help="Decoded status after scripted use")
    parser.add_argument("--mouse", type=Path, help="Decoded status after scripted mouse input")
    parser.add_argument("--menu", type=Path, help="Decoded status after scripted menu toggle")
    parser.add_argument(
        "--write-json",
        type=Path,
        help="Write a status-only scripted gameplay proof manifest",
    )
    parser.add_argument(
        "--no-auto-snapshots",
        action="store_true",
        help="Only use explicitly supplied snapshot paths",
    )
    parser.add_argument(
        "--repo-contract",
        action="store_true",
        help="Validate repository wiring for the scripted gameplay proof lane",
    )
    args = parser.parse_args(argv)

    if args.repo_contract:
        try:
            validate_repo_contract()
        except (OSError, AssertionError) as exc:
            print(f"scripted gameplay proof repo contract failed: {exc}", file=sys.stderr)
            return 1
        print("scripted gameplay proof repo contract OK")
        return 0

    if args.final_status is None:
        parser.error("final_status is required unless --repo-contract is set")

    snapshots: dict[str, str] = {}
    try:
        paths = _resolve_phase_paths(args)
        snapshots = _read_phase_statuses(paths)
        manifest = build_manifest(snapshots, paths=paths)
        if args.write_json is not None:
            args.write_json.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    except (OSError, AssertionError) as exc:
        final = snapshots.get("final", "")
        summary = f"\nstatus summary: {summarize_status(final)}" if final else ""
        print(f"scripted gameplay proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    print(
        "scripted gameplay proof OK: clean E1M1 start, cumulative fire/move/use/menu "
        "state, player-position delta, and Doom mouse turn state verified"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
