#!/usr/bin/env python3
"""Validate scripted Doom gameplay transitions from decoded status snapshots."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

from status_fields import (
    parse_status_fields,
    require_hex8_field,
    require_hex_tuple_field,
    require_status_field,
    summarize_status_fields,
)

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
PLAYABLE_DOC = ROOT / "docs" / "proof.txt"
MAKEFILE = ROOT / "Makefile"

SCHEMA = "scripted-gameplay-proof-v1"
SOURCE = "real-wad-cloud-scripted-gameplay"
GATE = "tools/check_scripted_gameplay_proof.py"

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
INPUT_COUNTERS = ("inputqueue", "inputpoll")
KEY_COUNTERS = ("keyirq", "keyqueue", "keypoll")
MOUSE_COUNTERS = ("mouseirq", "mousepkt", "mousepoll")
FRAME_COUNTERS = ("doompresent",)
TIMER_COUNTERS = ("dtick",)
PREEMPT_COUNTERS = ("preempt", "pirq", "pattempt", "puser")
SCHEDULER_DIAGNOSTIC_COUNTERS = ("pskip",)
AUDIO_PROGRESS_COUNTERS = ("audioirq", "refill", "musicpos")
AUDIO_SAFETY_COUNTERS = ("mixunder", "musicunder", "musicdrops")
PERFORMANCE_REQUIRED_FIELDS = (
    "doompresent",
    "dtick",
    "inputdepth",
    "audioirq",
    "refill",
    "musicpos",
    "musicbuf",
    "musicpull",
    "mixunder",
    "musicunder",
    "musicdrops",
    "preempt",
    "pirq",
    "pattempt",
    "pskip",
    "puser",
)
LONG_RUN_CADENCE_HEALTHY = "long-run-cadence-observed"
LONG_RUN_WINDOW_START = "use"
LONG_RUN_WINDOW_END = "mouse"
LONG_RUN_MIN_DOOM_TICS = 0x80

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
    "inputqueue",
    "inputpoll",
    "inputlast",
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
    "doompresent",
    "dtick",
    "audioirq",
    "refill",
    "musicpos",
    "inputdepth",
    "musicbuf",
    "musicpull",
    "mixunder",
    "musicunder",
    "musicdrops",
    "preempt",
    "pirq",
    "pattempt",
    "pskip",
    "puser",
)


def _require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label} missing {needle!r}")


def _status_fields(status: str) -> dict[str, str]:
    return parse_status_fields(status, error_type=AssertionError)


def summarize_status(status: str) -> str:
    try:
        fields = _status_fields(status)
    except AssertionError as exc:
        return f"unparseable status: {exc}"
    return summarize_status_fields(fields, SUMMARY_FIELDS)


def _field(status: str, name: str) -> str:
    fields = _status_fields(status)
    return require_status_field(fields, name, error_type=AssertionError)


def _hex_field(status: str, name: str) -> int:
    fields = _status_fields(status)
    return require_hex8_field(fields, name, error_type=AssertionError)


def _position_field(status: str, name: str) -> tuple[int, int]:
    fields = _status_fields(status)
    return require_hex_tuple_field(fields, name, 2, sep=":", error_type=AssertionError)


def _tuple_field(status: str, name: str, parts: int) -> tuple[int, ...]:
    fields = _status_fields(status)
    return require_hex_tuple_field(fields, name, parts, sep=":", error_type=AssertionError)


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


def _assert_tuple_not_decreasing(
    before: str,
    after: str,
    field: str,
    parts: int,
    before_label: str,
    after_label: str,
) -> None:
    before_values = _tuple_field(before, field, parts)
    after_values = _tuple_field(after, field, parts)
    for index, (before_value, after_value) in enumerate(zip(before_values, after_values)):
        if after_value < before_value:
            raise AssertionError(
                f"{after_label} {field}= component {index} must not decrease after {before_label}, "
                f"got {before_value:08X}->{after_value:08X}"
            )


def _assert_tuple_component_not_decreasing(
    before: str,
    after: str,
    field: str,
    parts: int,
    index: int,
    before_label: str,
    after_label: str,
) -> None:
    before_value = _tuple_field(before, field, parts)[index]
    after_value = _tuple_field(after, field, parts)[index]
    if after_value < before_value:
        raise AssertionError(
            f"{after_label} {field}= component {index} must not decrease after {before_label}, "
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
    _assert_increasing(snapshots["start"], snapshots["fire"], INPUT_COUNTERS, "start", "fire")
    _assert_increasing(snapshots["fire"], snapshots["movement"], INPUT_COUNTERS, "fire", "movement")
    _assert_increasing(snapshots["movement"], snapshots["use"], INPUT_COUNTERS, "movement", "use")
    _assert_increasing(snapshots["use"], snapshots["mouse"], INPUT_COUNTERS, "use", "mouse")
    _assert_increasing(snapshots["mouse"], snapshots["menu"], INPUT_COUNTERS, "mouse", "menu")
    _assert_not_decreasing(snapshots["menu"], snapshots["final"], INPUT_COUNTERS, "menu", "final")


def _require_performance_observability(snapshots: dict[str, str]) -> None:
    for phase in PHASE_ORDER:
        status = snapshots[phase]
        fields = _status_fields(status)
        for name in PERFORMANCE_REQUIRED_FIELDS:
            if name not in fields:
                raise AssertionError(f"{phase} missing performance field {name}=")
        _tuple_field(status, "inputdepth", 2)
        _tuple_field(status, "musicpull", 2)
        for name in PERFORMANCE_REQUIRED_FIELDS:
            if name not in ("inputdepth", "musicpull"):
                _hex_field(status, name)

    previous_phase = "start"
    previous_status = snapshots[previous_phase]
    for phase in ("fire", "movement", "use", "mouse", "menu", "final"):
        status = snapshots[phase]
        _assert_not_decreasing(
            previous_status,
            status,
            (
                FRAME_COUNTERS
                + TIMER_COUNTERS
                + PREEMPT_COUNTERS
                + SCHEDULER_DIAGNOSTIC_COUNTERS
                + AUDIO_PROGRESS_COUNTERS
                + AUDIO_SAFETY_COUNTERS
            ),
            previous_phase,
            phase,
        )
        _assert_tuple_component_not_decreasing(previous_status, status, "inputdepth", 2, 1, previous_phase, phase)
        _assert_tuple_not_decreasing(previous_status, status, "musicpull", 2, previous_phase, phase)
        previous_phase = phase
        previous_status = status

    _assert_increasing(snapshots["start"], snapshots["menu"], FRAME_COUNTERS, "start", "menu")
    _assert_increasing(snapshots["start"], snapshots["menu"], TIMER_COUNTERS, "start", "menu")
    _assert_increasing(snapshots["start"], snapshots["menu"], PREEMPT_COUNTERS, "start", "menu")


def _counter_progress(snapshots: dict[str, str], name: str) -> dict[str, str]:
    return _counter_progress_between(snapshots, "start", "final", name)


def _counter_progress_between(
    snapshots: dict[str, str],
    start_phase: str,
    final_phase: str,
    name: str,
) -> dict[str, str]:
    start = _hex_field(snapshots[start_phase], name)
    final = _hex_field(snapshots[final_phase], name)
    return {
        "start": _hex8(start),
        "final": _hex8(final),
        "delta": _hex8(final - start),
    }


def _tuple_progress(snapshots: dict[str, str], name: str, labels: tuple[str, ...]) -> dict[str, dict[str, str]]:
    return _tuple_progress_between(snapshots, "start", "final", name, labels)


def _tuple_progress_between(
    snapshots: dict[str, str],
    start_phase: str,
    final_phase: str,
    name: str,
    labels: tuple[str, ...],
) -> dict[str, dict[str, str]]:
    start_values = _tuple_field(snapshots[start_phase], name, len(labels))
    final_values = _tuple_field(snapshots[final_phase], name, len(labels))
    progress = {}
    for label, start, final in zip(labels, start_values, final_values):
        progress[label] = {
            "start": _hex8(start),
            "final": _hex8(final),
            "delta": _hex8(final - start),
        }
    return progress


def _max_tuple_component(snapshots: dict[str, str], name: str, parts: int, index: int) -> int:
    return max(_tuple_field(snapshots[phase], name, parts)[index] for phase in PHASE_ORDER)


def _gauge_summary(snapshots: dict[str, str], name: str) -> dict[str, str | bool]:
    values = [_hex_field(snapshots[phase], name) for phase in PHASE_ORDER]
    return {
        "start": _hex8(values[0]),
        "final": _hex8(values[-1]),
        "min": _hex8(min(values)),
        "max": _hex8(max(values)),
        "changed": len(set(values)) > 1,
    }


def _delta(progress: dict[str, str]) -> int:
    return int(progress["delta"], 16)


def _window_counter_progress(
    snapshots: dict[str, str],
    start_phase: str,
    final_phase: str,
) -> dict[str, dict[str, str]]:
    counters = (
        "gtic",
        "leveltime",
        "doompresent",
        "dtick",
        "pirq",
        "preempt",
        "pattempt",
        "pskip",
        "puser",
        "audioirq",
        "refill",
        "musicpos",
        "mixunder",
        "musicunder",
        "musicdrops",
    )
    return {
        name: _counter_progress_between(snapshots, start_phase, final_phase, name)
        for name in counters
    }


def _cadence_duration(gtic_delta: int, leveltime_delta: int) -> dict[str, str]:
    return {
        "doom_tics": _hex8(gtic_delta),
        "leveltime_tics": _hex8(leveltime_delta),
        "approx_seconds_at_35hz": f"{gtic_delta / 35:.2f}",
    }


def _cadence_health(
    *,
    gtic_delta: int,
    leveltime_delta: int,
    frame_delta: int,
    dtick_delta: int,
    pirq_delta: int,
    preempt_delta: int,
    puser_delta: int,
    audioirq_delta: int,
    refill_delta: int,
    musicpos_delta: int,
    pull_refill_delta: int,
    input_drop_delta: int,
    audio_pressure: bool,
) -> dict[str, object]:
    return {
        "doom_progress": gtic_delta > 0 and leveltime_delta > 0,
        "frame_progress": frame_delta > 0 and dtick_delta > 0,
        "scheduler_progress": pirq_delta > 0 and preempt_delta > 0 and puser_delta > 0,
        "audio_progress": (
            audioirq_delta > 0
            and refill_delta > 0
            and musicpos_delta > 0
            and pull_refill_delta > 0
        ),
        "input_dropped": _hex8(input_drop_delta),
        "audio_pressure": audio_pressure,
    }


def _build_cadence_window(
    snapshots: dict[str, str],
    start_phase: str,
    final_phase: str,
) -> dict[str, object]:
    counters = _window_counter_progress(snapshots, start_phase, final_phase)
    inputdepth = _tuple_progress_between(snapshots, start_phase, final_phase, "inputdepth", ("queued", "dropped"))
    musicpull = _tuple_progress_between(snapshots, start_phase, final_phase, "musicpull", ("requests", "refills"))

    gtic_delta = _delta(counters["gtic"])
    leveltime_delta = _delta(counters["leveltime"])
    frame_delta = _delta(counters["doompresent"])
    dtick_delta = _delta(counters["dtick"])
    pirq_delta = _delta(counters["pirq"])
    preempt_delta = _delta(counters["preempt"])
    puser_delta = _delta(counters["puser"])
    audioirq_delta = _delta(counters["audioirq"])
    refill_delta = _delta(counters["refill"])
    musicpos_delta = _delta(counters["musicpos"])
    pull_refill_delta = _delta(musicpull["refills"])
    pskip_delta = _delta(counters["pskip"])
    pattempt_delta = _delta(counters["pattempt"])
    input_drop_delta = _delta(inputdepth["dropped"])
    audio_pressure = any(
        _delta(counters[name]) > 0
        for name in ("mixunder", "musicunder", "musicdrops")
    )

    return {
        "from": start_phase,
        "to": final_phase,
        "duration": _cadence_duration(gtic_delta, leveltime_delta),
        "counters": counters,
        "inputdepth": inputdepth,
        "musicpull": musicpull,
        "health": _cadence_health(
            gtic_delta=gtic_delta,
            leveltime_delta=leveltime_delta,
            frame_delta=frame_delta,
            dtick_delta=dtick_delta,
            pirq_delta=pirq_delta,
            preempt_delta=preempt_delta,
            puser_delta=puser_delta,
            audioirq_delta=audioirq_delta,
            refill_delta=refill_delta,
            musicpos_delta=musicpos_delta,
            pull_refill_delta=pull_refill_delta,
            input_drop_delta=input_drop_delta,
            audio_pressure=audio_pressure,
        ),
        "ratios": {
            "frames_per_1024_gtic": _hex8((frame_delta * 1024) // gtic_delta if gtic_delta else 0),
            "leveltime_per_1024_gtic": _hex8((leveltime_delta * 1024) // gtic_delta if gtic_delta else 0),
            "pirq_per_1024_gtic": _hex8((pirq_delta * 1024) // gtic_delta if gtic_delta else 0),
            "audioirq_per_1024_gtic": _hex8((audioirq_delta * 1024) // gtic_delta if gtic_delta else 0),
            "refill_per_1024_gtic": _hex8((refill_delta * 1024) // gtic_delta if gtic_delta else 0),
            "pull_refill_per_1024_gtic": _hex8((pull_refill_delta * 1024) // gtic_delta if gtic_delta else 0),
            "musicpos_per_leveltime": _hex8(musicpos_delta // leveltime_delta if leveltime_delta else 0),
            "pskip_per_1024_pattempt": _hex8((pskip_delta * 1024) // pattempt_delta if pattempt_delta else 0),
        },
    }


def _build_phase_cadence_windows(snapshots: dict[str, str]) -> dict[str, dict[str, object]]:
    windows = {}
    for before, after in zip(PHASE_ORDER, PHASE_ORDER[1:]):
        windows[f"{before}->{after}"] = _build_cadence_window(snapshots, before, after)
    return windows


def _slowdown_triage_for_verdict(verdict: str) -> dict[str, object]:
    if verdict == LONG_RUN_CADENCE_HEALTHY:
        return {
            "primary_lane": "remote-presentation-throughput",
            "operator_hint": (
                "OS-side Doom/frame/input/audio/scheduler cadence stayed healthy; "
                "if noVNC still slows down, inspect cloud CPU quota/load and noVNC/QEMU display throughput first"
            ),
            "status_only_next_steps": [
                "compare play_window ratios across soak attempts",
                "run the play-now diagnostics helper during the slow session",
                "prefer a 4+ CPU Codespace or faster disposable cloud VM before changing guest code",
            ],
        }
    if verdict == "long-run-window-too-short":
        return {
            "primary_lane": "cadence-evidence-gap",
            "operator_hint": "the status snapshots do not include a long enough pre-menu gameplay window",
            "status_only_next_steps": [
                "rerun the real-WAD soak path with --require-long-run-cadence",
                "inspect gameplay-proof.json long_run_cadence after download",
            ],
        }
    if verdict == "input-loss-observed":
        return {
            "primary_lane": "os-input-queue",
            "operator_hint": "input drops were recorded in status, so inspect generic input drain before blaming noVNC",
            "status_only_next_steps": [
                "compare inputdepth queued/dropped deltas by phase",
                "check keyqueue/keypoll and mousepkt/mousepoll progression",
            ],
        }
    if verdict == "audio-pressure-observed" or verdict == "audio-cadence-stalled":
        return {
            "primary_lane": "os-audio-cadence",
            "operator_hint": "audio service or safety counters are the first status-visible slowdown lane",
            "status_only_next_steps": [
                "run the SB16 continuity checker on the same phase snapshots",
                "compare audioirq/refill/musicpull/musicpos deltas by phase",
            ],
        }
    if verdict == "scheduler-cadence-stalled":
        return {
            "primary_lane": "os-scheduler-cadence",
            "operator_hint": "timer IRQ/preemption/user-window counters stalled during gameplay",
            "status_only_next_steps": [
                "inspect pirq/preempt/puser deltas and VM/process proof output",
            ],
        }
    if verdict == "guest-cadence-stalled":
        return {
            "primary_lane": "doom-frame-cadence",
            "operator_hint": "Doom tics advanced but frame or Doom-time status cadence stalled",
            "status_only_next_steps": [
                "compare doompresent and dtick deltas against gtic/leveltime",
            ],
        }
    return {
        "primary_lane": "unknown-cadence-lane",
        "operator_hint": "long-run cadence produced an unrecognized verdict; read the interpretation literally",
        "status_only_next_steps": ["inspect gameplay-proof.json long_run_cadence"],
    }


def _build_long_run_cadence(snapshots: dict[str, str]) -> dict[str, object]:
    play_window = _build_cadence_window(snapshots, LONG_RUN_WINDOW_START, LONG_RUN_WINDOW_END)
    session_window = _build_cadence_window(snapshots, "start", "final")
    menu_tail_window = _build_cadence_window(snapshots, "menu", "final")
    phase_windows = _build_phase_cadence_windows(snapshots)

    play_counters = play_window["counters"]
    play_musicpull = play_window["musicpull"]
    play_inputdepth = play_window["inputdepth"]
    gtic_delta = _delta(play_counters["gtic"])
    leveltime_delta = _delta(play_counters["leveltime"])
    frame_delta = _delta(play_counters["doompresent"])
    dtick_delta = _delta(play_counters["dtick"])
    pirq_delta = _delta(play_counters["pirq"])
    preempt_delta = _delta(play_counters["preempt"])
    puser_delta = _delta(play_counters["puser"])
    audioirq_delta = _delta(play_counters["audioirq"])
    refill_delta = _delta(play_counters["refill"])
    musicpos_delta = _delta(play_counters["musicpos"])
    pull_refill_delta = _delta(play_musicpull["refills"])
    input_drop_delta = _delta(play_inputdepth["dropped"])
    audio_pressure = any(
        _delta(play_counters[name]) > 0
        for name in ("mixunder", "musicunder", "musicdrops")
    )

    if gtic_delta < LONG_RUN_MIN_DOOM_TICS or leveltime_delta < LONG_RUN_MIN_DOOM_TICS:
        verdict = "long-run-window-too-short"
        interpretation = (
            f"the {LONG_RUN_WINDOW_START}->{LONG_RUN_WINDOW_END} gameplay window captured "
            f"{gtic_delta:#x}/{leveltime_delta:#x} Doom tics, below the {LONG_RUN_MIN_DOOM_TICS:#x} "
            "status-only cadence floor"
        )
    elif frame_delta == 0 or dtick_delta == 0:
        verdict = "guest-cadence-stalled"
        interpretation = "Doom tic counters advanced, but frame or Doom-time status cadence stalled"
    elif pirq_delta == 0 or preempt_delta == 0 or puser_delta == 0:
        verdict = "scheduler-cadence-stalled"
        interpretation = "Doom stayed in gameplay, but timer IRQ/preemption/user IRQ counters did not all advance"
    elif input_drop_delta != 0:
        verdict = "input-loss-observed"
        interpretation = "Doom stayed in gameplay, but inputdepth= recorded dropped input events"
    elif audioirq_delta == 0 or refill_delta == 0 or pull_refill_delta == 0 or musicpos_delta == 0:
        verdict = "audio-cadence-stalled"
        interpretation = "Doom stayed in gameplay, but SB16 IRQ/refill/pull/music position counters did not all advance"
    elif audio_pressure:
        verdict = "audio-pressure-observed"
        interpretation = "Doom and SB16 cadence advanced, but audio underrun/drop counters increased"
    else:
        verdict = LONG_RUN_CADENCE_HEALTHY
        interpretation = (
            "pre-menu gameplay stayed live long enough to compare Doom tics, frames, "
            "timer IRQ/preemption, SB16 IRQ/refill, and music position progress"
        )

    return {
        "verdict": verdict,
        "interpretation": interpretation,
        "required_when": "--require-long-run-cadence",
        "minimum_play_window_doom_tics": _hex8(LONG_RUN_MIN_DOOM_TICS),
        "status_fields": [
            "gtic",
            "leveltime",
            "doompresent",
            "dtick",
            "pirq",
            "preempt",
            "pattempt",
            "pskip",
            "puser",
            "audioirq",
            "refill",
            "musicpos",
            "musicpull",
            "inputdepth",
            "mixunder",
            "musicunder",
            "musicdrops",
        ],
        "slowdown_triage": _slowdown_triage_for_verdict(verdict),
        "play_window": play_window,
        "session_window": session_window,
        "menu_tail_window": menu_tail_window,
        "phase_windows": phase_windows,
    }


def require_long_run_cadence(snapshots: dict[str, str]) -> None:
    cadence = _build_long_run_cadence(snapshots)
    if cadence.get("verdict") != LONG_RUN_CADENCE_HEALTHY:
        triage = cadence.get("slowdown_triage", {})
        primary_lane = triage.get("primary_lane", "unknown-cadence-lane") if isinstance(triage, dict) else "unknown-cadence-lane"
        raise AssertionError(
            "long-run cadence must show pre-menu Doom/frame/scheduler/audio progress, "
            f"got {cadence.get('verdict')} ({primary_lane}): {cadence.get('interpretation')}"
        )


def _build_performance_diagnostics(snapshots: dict[str, str]) -> dict:
    frame = _counter_progress(snapshots, "doompresent")
    timer = {
        "ticks": _counter_progress(snapshots, "gtic"),
        "leveltime": _counter_progress(snapshots, "leveltime"),
        "doom_time": _counter_progress(snapshots, "dtick"),
    }
    queue = _tuple_progress(snapshots, "inputdepth", ("queued", "dropped"))
    input_events = {
        "enqueued": _counter_progress(snapshots, "inputqueue"),
        "polled": _counter_progress(snapshots, "inputpoll"),
        "max_queued": _hex8(_max_tuple_component(snapshots, "inputdepth", 2, 0)),
    }
    audio = {
        "music_buffer": _gauge_summary(snapshots, "musicbuf"),
        "music_pull": _tuple_progress(snapshots, "musicpull", ("requests", "refills")),
        "mixer_underruns": _counter_progress(snapshots, "mixunder"),
        "music_underruns": _counter_progress(snapshots, "musicunder"),
        "music_drops": _counter_progress(snapshots, "musicdrops"),
    }
    scheduler = {
        "preemptions": _counter_progress(snapshots, "preempt"),
        "timer_irqs": _counter_progress(snapshots, "pirq"),
        "attempts": _counter_progress(snapshots, "pattempt"),
        "skips": _counter_progress(snapshots, "pskip"),
        "user_irqs": _counter_progress(snapshots, "puser"),
    }
    long_run_cadence = _build_long_run_cadence(snapshots)

    queued_final = int(queue["queued"]["final"], 16)
    queued_max = int(input_events["max_queued"], 16)
    dropped_delta = int(queue["dropped"]["delta"], 16)
    music_under_delta = int(audio["music_underruns"]["delta"], 16)
    music_drop_delta = int(audio["music_drops"]["delta"], 16)
    mix_under_delta = int(audio["mixer_underruns"]["delta"], 16)
    preempt_delta = int(scheduler["preemptions"]["delta"], 16)
    frame_delta = int(frame["delta"], 16)
    dtick_delta = int(timer["doom_time"]["delta"], 16)

    if dropped_delta:
        verdict = "os-input-loss"
        interpretation = "input queue drops increased during the script; investigate kernel input backlog before blaming noVNC"
    elif queued_final or queued_max > 8:
        verdict = "os-input-backlog"
        interpretation = "input remained queued during the script; slowdown may include OS-side input drain pressure"
    elif music_under_delta or music_drop_delta or mix_under_delta:
        verdict = "os-audio-pressure"
        interpretation = "audio safety counters increased during the script; investigate SB16 refill or mixer pacing"
    elif preempt_delta == 0:
        verdict = "os-preemption-stalled"
        interpretation = "timer preemption did not advance during the script"
    elif frame_delta == 0 or dtick_delta == 0:
        verdict = "guest-progress-stalled"
        interpretation = "Doom frame or 35 Hz timer counters did not advance during the script"
    else:
        verdict = "os-pipeline-healthy"
        interpretation = (
            "frame, timer, input, audio, and preemption counters advanced without queue drops; "
            "if noVNC still feels slower over time, suspect QEMU TCG/noVNC/display throughput first"
        )

    return {
        "verdict": verdict,
        "interpretation": interpretation,
        "frames": frame,
        "timer": timer,
        "input": {
            "queue": queue,
            "events": input_events,
        },
        "audio": audio,
        "scheduler": scheduler,
        "long_run_cadence": long_run_cadence,
    }


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
    _require_performance_observability(snapshots)


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def build_manifest(
    snapshots: dict[str, str],
    paths: dict[str, Path] | None = None,
    *,
    require_cadence: bool = False,
) -> dict:
    validate_statuses(snapshots)
    if require_cadence:
        require_long_run_cadence(snapshots)

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
            "inputqueue": _field(start, "inputqueue"),
            "inputpoll": _field(start, "inputpoll"),
            "inputlast": _field(start, "inputlast"),
        },
        "transitions": {
            "fire": {
                "inputpoll": _field(snapshots["fire"], "inputpoll"),
                "inputlast": _field(snapshots["fire"], "inputlast"),
                "keyseen": _field(snapshots["fire"], "keyseen"),
                "pflags": _field(snapshots["fire"], "pflags"),
                "pammo": _field(snapshots["fire"], "pammo"),
                "prefire": _field(snapshots["fire"], "prefire"),
            },
            "movement": {
                "inputpoll": _field(movement, "inputpoll"),
                "inputlast": _field(movement, "inputlast"),
                "keyseen": _field(movement, "keyseen"),
                "pflags": _field(movement, "pflags"),
                "start_ppos": _field(start, "ppos"),
                "movement_ppos": _field(movement, "ppos"),
                "pdelta": _field(movement, "pdelta"),
            },
            "use": {
                "inputpoll": _field(snapshots["use"], "inputpoll"),
                "inputlast": _field(snapshots["use"], "inputlast"),
                "keyseen": _field(snapshots["use"], "keyseen"),
                "pflags": _field(snapshots["use"], "pflags"),
            },
            "mouse": {
                "inputpoll": _field(mouse, "inputpoll"),
                "inputlast": _field(mouse, "inputlast"),
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
                "inputpoll": _field(snapshots["menu"], "inputpoll"),
                "inputlast": _field(snapshots["menu"], "inputlast"),
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
            "inputpoll": _field(final, "inputpoll"),
            "inputlast": _field(final, "inputlast"),
        },
        "performance_diagnostics": _build_performance_diagnostics(snapshots),
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
    playable_doc = (root / "docs" / "proof.txt").read_text()
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
        "performance diagnostics",
        "os-pipeline-healthy",
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
    parser.add_argument(
        "--require-long-run-cadence",
        action="store_true",
        help="Require the status-only pre-menu long-run cadence window used by soak proof attempts",
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
        manifest = build_manifest(
            snapshots,
            paths=paths,
            require_cadence=args.require_long_run_cadence,
        )
        if args.write_json is not None:
            args.write_json.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    except (OSError, AssertionError) as exc:
        final = snapshots.get("final", "")
        summary = f"\nstatus summary: {summarize_status(final)}" if final else ""
        print(f"scripted gameplay proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    print(
        "scripted gameplay proof OK: clean E1M1 start, cumulative fire/move/use/menu "
        "state, player-position delta, Doom mouse turn state, and status cadence verified"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
