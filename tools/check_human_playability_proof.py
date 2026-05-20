#!/usr/bin/env python3
"""Validate non-pixel human-playability signals from smoke status artifacts."""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
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
PFLAG_TURN_CMD = 0x0100

PFLAG_NAMES = {
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
    "pangle",
    "pangledelta",
    "pammo",
    "prefire",
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

HUMAN_MIN_SESSION_TICKS = 35 * 10
HUMAN_SESSION_PHASES = (
    ("early", "phase_hash_early", "status.early.txt"),
    ("after-start", "phase_hash_after_start", "status.after-start.txt"),
    ("after-fire", "phase_hash_after_fire", "status.after-fire.txt"),
    ("after-move", "phase_hash_after_move", "status.after-move.txt"),
    ("after-use", "phase_hash_after_use", "status.after-use.txt"),
    ("after-mouse", "phase_hash_after_mouse", "status.after-mouse.txt"),
    ("after-menu", "phase_hash_after_menu", "status.after-menu.txt"),
    ("final", "phase_hash_final", "status.txt"),
)
HUMAN_REQUIRED_NOTE_VALUES = {
    "schema": ("human-playtest-notes-v2",),
    "scripted_proof": ("real-wad-smoke-pass",),
    "remote_host": ("disposable",),
    "qemu_location": ("remote",),
    "qemu_display": ("127.0.0.1:1",),
    "monitor_socket": ("unix-monitor-socket",),
    "vnc_tunnel": ("loopback-only",),
    "vnc_endpoint": ("127.0.0.1:5901",),
    "wad": ("shareware-v1.9-validated-remote-only",),
    "display": ("pass",),
    "keyboard": ("pass",),
    "mouse": ("pass",),
    "visual_evidence": ("e1m1-visible-via-remote-vnc",),
    "keyboard_evidence": ("fire-move-use-menu-visible",),
    "mouse_evidence": ("motion-click-visible",),
    "status_capture": ("monitor-pmemsave-0x9d000",),
    "session_phases": (
        "early,after-start,after-fire,after-move,after-use,after-mouse,after-menu,final",
    ),
    "diagnostics": ("non-wad-status-only",),
    "proof_bundle": ("allowlisted-status-only",),
    "no_local_qemu": ("yes",),
    "no_wad_upload": ("yes",),
    "no_disk_upload": ("yes",),
    "no_pixel_upload": ("yes",),
    "operator_remote_vnc": ("confirmed",),
    "operator_phase_actions": ("confirmed",),
    "operator_phase_status_hashes": ("confirmed",),
    "operator_no_forbidden_artifacts": ("confirmed",),
    "operator_post_download_verification": ("required",),
}
HUMAN_OPTIONAL_NOTE_VALUES = {
    "audio": ("status-only", "listener-pass", "audio-proof-json-pass", "not-tested"),
}
HUMAN_NOTE_PATTERNS = {
    "commit": r"(?:[0-9A-Fa-f]{7,40}|unknown)",
    "playtester": r"[A-Za-z0-9._-]{2,64}",
    "scripted_proof_run_id": r"[0-9]{6,32}",
    **{note_key: r"[0-9A-Fa-f]{64}" for _, note_key, _ in HUMAN_SESSION_PHASES},
}
FORBIDDEN_ARTIFACT_PATTERNS = (
    "*.wad",
    "*.WAD",
    "*.iwad",
    "*.IWAD",
    "*.pwad",
    "*.PWAD",
    "*.img",
    "*.iso",
    "*.raw",
    "*.qcow2",
    "gfx.bin",
    "gfx*.txt",
    "vga*.bin",
    "vga*.txt",
    "*.png",
    "*.ppm",
    "*.pgm",
    "*.bmp",
    "*.wav",
    "*.wave",
    "*.mp3",
    "*.ogg",
    "*.oga",
    "*.flac",
    "*.aiff",
    "*.aif",
    "*.au",
)
FORBIDDEN_ARTIFACT_SIGNATURES = (
    (b"IWAD", "WAD/IWAD payload"),
    (b"PWAD", "WAD/PWAD payload"),
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


def _counter_delta(baseline: str, final: str, name: str) -> int:
    before = _hex_field(baseline, name)
    after = _hex_field(final, name)
    if after < before:
        raise AssertionError(f"{name}= must not go backward, got {before:08X}->{after:08X}")
    return after - before


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


def validate_human_session_status(
    snapshots: dict[str, str | None],
    min_duration_ticks: int = HUMAN_MIN_SESSION_TICKS,
) -> None:
    """Validate the stricter status timeline required for a manual VNC session."""

    missing = [
        status_file
        for phase, _note_key, status_file in HUMAN_SESSION_PHASES
        if snapshots.get(phase) is None
    ]
    if missing:
        raise AssertionError(
            "manual human proof requires every phase status file: " + ", ".join(missing)
        )

    start = snapshots["after-start"]
    final = snapshots["final"]
    assert start is not None and final is not None
    for name in RUN_COUNTERS:
        delta = _counter_delta(start, final, name)
        if delta < min_duration_ticks:
            raise AssertionError(
                f"manual human proof requires at least {min_duration_ticks} {name}= ticks "
                f"from after-start to final, got {delta}"
            )

    ordered_action_phases = (
        "after-start",
        "after-fire",
        "after-move",
        "after-use",
        "after-mouse",
        "after-menu",
    )
    for before_phase, after_phase in zip(ordered_action_phases, ordered_action_phases[1:]):
        before = snapshots[before_phase]
        after = snapshots[after_phase]
        assert before is not None and after is not None
        try:
            _assert_increasing(before, after, RUN_COUNTERS)
        except AssertionError as exc:
            raise AssertionError(
                f"manual phase {after_phase} must advance Doom time after {before_phase}: {exc}"
            ) from exc


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _load_human_notes(path: Path) -> dict[str, str]:
    notes: dict[str, str] = {}
    for line_number, line in enumerate(path.read_text().splitlines(), start=1):
        stripped = line.strip()
        if not stripped:
            continue
        if "=" not in stripped:
            raise AssertionError(f"{path.name}:{line_number} must be key=value")
        key, value = stripped.split("=", 1)
        if not key or not value:
            raise AssertionError(f"{path.name}:{line_number} must have nonempty key and value")
        if key in notes:
            raise AssertionError(f"{path.name} has duplicate {key}= field")
        notes[key] = value
    return notes


def _commit_matches(actual: str, expected: str) -> bool:
    return actual == expected or actual.startswith(expected) or expected.startswith(actual)


def validate_human_notes(
    notes_path: Path,
    phase_paths: dict[str, Path | None],
    expected_commit: str | None = None,
    expected_scripted_proof_run_id: str | None = None,
) -> None:
    """Validate collector notes against the current status files and identity."""

    notes = _load_human_notes(notes_path)
    for key, expected_values in HUMAN_REQUIRED_NOTE_VALUES.items():
        actual = notes.get(key)
        if actual not in expected_values:
            raise AssertionError(
                f"{notes_path.name} {key}= must be one of {expected_values}, got {actual!r}"
            )
    for key, allowed_values in HUMAN_OPTIONAL_NOTE_VALUES.items():
        actual = notes.get(key)
        if actual is not None and actual not in allowed_values:
            raise AssertionError(
                f"{notes_path.name} {key}= must be one of {allowed_values}, got {actual!r}"
            )
    for key, pattern in HUMAN_NOTE_PATTERNS.items():
        actual = notes.get(key)
        if actual is None:
            raise AssertionError(f"{notes_path.name} missing {key}= field")
        if not re.fullmatch(pattern, actual):
            raise AssertionError(f"{notes_path.name} {key}= has invalid value {actual!r}")

    commit = notes["commit"]
    if commit == "unknown":
        raise AssertionError(f"{notes_path.name} commit=unknown is not acceptable for human proof")
    if expected_commit and not _commit_matches(commit, expected_commit):
        raise AssertionError(
            f"{notes_path.name} commit= must match expected commit {expected_commit}, got {commit}"
        )
    if (
        expected_scripted_proof_run_id
        and notes["scripted_proof_run_id"] != expected_scripted_proof_run_id
    ):
        raise AssertionError(
            f"{notes_path.name} scripted_proof_run_id= must match "
            f"{expected_scripted_proof_run_id}, got {notes['scripted_proof_run_id']}"
        )

    for phase, note_key, status_file in HUMAN_SESSION_PHASES:
        phase_path = phase_paths.get(phase)
        if phase_path is None:
            raise AssertionError(f"missing phase status path for {status_file}")
        if not phase_path.exists():
            raise AssertionError(f"missing phase status file for notes hash: {phase_path}")
        actual_hash = _sha256_file(phase_path)
        expected_hash = notes[note_key].lower()
        if actual_hash.lower() != expected_hash:
            raise AssertionError(
                f"{notes_path.name} {note_key}= must match {status_file} SHA-256"
            )


def validate_artifact_hygiene(artifact_dir: Path) -> None:
    """Reject WADs, disk images, screenshots, raw audio, and obvious WAD payloads."""

    if not artifact_dir.exists():
        raise AssertionError(f"artifact directory does not exist: {artifact_dir}")
    if not artifact_dir.is_dir():
        raise AssertionError(f"artifact path is not a directory: {artifact_dir}")
    for path in sorted(artifact_dir.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(artifact_dir).as_posix()
        name = path.name
        for pattern in FORBIDDEN_ARTIFACT_PATTERNS:
            if fnmatch.fnmatch(name, pattern) or fnmatch.fnmatch(rel, pattern):
                raise AssertionError(f"forbidden human proof artifact present: {rel}")
        with path.open("rb") as handle:
            prefix = handle.read(4096)
        for signature, label in FORBIDDEN_ARTIFACT_SIGNATURES:
            if prefix.startswith(signature):
                raise AssertionError(f"forbidden {label} signature present in {rel}")


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
    if mouse_status is not None:
        final_required_pflags |= PFLAG_TURN_CMD
    _require_pflags(final_status, final_required_pflags)
    _require_pflags(final_status, REQUIRED_FIRE_STATE_PFLAGS)

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
        _require_pflags(fire_status, PFLAG_PLAYER | PFLAG_ATTACK_CMD | REQUIRED_FIRE_STATE_PFLAGS)

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
        _require_pflags(mouse_status, PFLAG_TURN_CMD)
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


def _resolve_snapshot_path(explicit: Path | None, auto: Path | None) -> Path | None:
    if explicit is not None:
        return explicit
    if auto is not None and auto.exists():
        return auto
    return None


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
    parser.add_argument(
        "--require-human-session",
        action="store_true",
        help=(
            "Require the complete manual remote-VNC proof: all phase snapshots, "
            "human notes, phase hashes, artifact hygiene, and a minimum Doom time window"
        ),
    )
    parser.add_argument(
        "--human-notes",
        type=Path,
        help="human-playtest-notes.txt generated by collect_human_playtest_bundle.py",
    )
    parser.add_argument(
        "--artifact-dir",
        type=Path,
        help="manual proof bundle directory; defaults to the final status parent in human mode",
    )
    parser.add_argument(
        "--expected-commit",
        help="commit expected in human-playtest-notes.txt; short or full hashes are accepted",
    )
    parser.add_argument(
        "--expected-scripted-proof-run-id",
        help="passing Real WAD smoke run ID expected in human-playtest-notes.txt",
    )
    parser.add_argument(
        "--min-human-duration-ticks",
        type=int,
        default=HUMAN_MIN_SESSION_TICKS,
        help=(
            "minimum Doom gtic/leveltime delta from after-start to final when "
            "--require-human-session is set"
        ),
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
        early_auto = _auto_snapshot(args.final_status, "early")
        early_explicit = (
            args.baseline
            if args.baseline is not None and args.baseline.name == "status.early.txt"
            else None
        )
        phase_paths = {
            "early": _resolve_snapshot_path(early_explicit, early_auto),
            "after-start": _resolve_snapshot_path(args.start, start),
            "after-fire": _resolve_snapshot_path(args.fire, fire),
            "after-move": _resolve_snapshot_path(args.movement, movement),
            "after-use": _resolve_snapshot_path(args.use, use),
            "after-mouse": _resolve_snapshot_path(args.mouse, mouse),
            "after-menu": _resolve_snapshot_path(args.menu, menu),
            "final": args.final_status,
        }
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
        if args.require_human_session:
            if args.min_human_duration_ticks < 1:
                raise AssertionError("--min-human-duration-ticks must be positive")
            if args.human_notes is None:
                raise AssertionError("--require-human-session requires --human-notes")
            validate_human_session_status(
                {
                    "early": snapshots["baseline"],
                    "after-start": snapshots["start"],
                    "after-fire": snapshots["fire"],
                    "after-move": snapshots["movement"],
                    "after-use": snapshots["use"],
                    "after-mouse": snapshots["mouse"],
                    "after-menu": snapshots["menu"],
                    "final": final_status,
                },
                min_duration_ticks=args.min_human_duration_ticks,
            )
            validate_human_notes(
                args.human_notes,
                phase_paths,
                expected_commit=args.expected_commit,
                expected_scripted_proof_run_id=args.expected_scripted_proof_run_id,
            )
            validate_artifact_hygiene(args.artifact_dir or args.final_status.parent)
    except (OSError, AssertionError) as exc:
        summary = f"\nstatus summary: {summarize_status(final_status)}" if final_status else ""
        print(f"human-playability proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    if args.require_human_session:
        print(
            "human-playability proof OK: manual remote VNC session phases, notes, "
            "duration, status hashes, and artifact hygiene verified"
        )
    else:
        print(
            "human-playability proof OK: scripted start/fire/use/move/mouse/menu changed Doom state without WAD pixels"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
