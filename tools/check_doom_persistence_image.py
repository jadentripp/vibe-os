#!/usr/bin/env python3
"""Validate Doom config/save persistence inside a vibe-os FAT16 disk image.

This tool is intended for remote/cloud runs after Doom has written to the
image. It inspects only FAT metadata and the DEFAULT.CFG / DOOMSAV*.DSG bytes;
it does not print or export WAD contents, rendered pixels, or disk images.
"""

import argparse
import importlib.util
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAKE_WAD_IMAGE = ROOT / "tools" / "make_wad_image.py"
SAVE_DESCRIPTION_BYTES = 24
SAVE_VERSION_BYTES = 16
SAVE_GAME_HEADER_BYTES = 10
SAVE_GAMESTATE_OFFSET = SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + SAVE_GAME_HEADER_BYTES
DEFAULT_MARKERS = (
    b"mouse_sensitivity",
    b"screenblocks",
    b"use_mouse",
    b"chatmacro0",
)
DEFAULT_NUMERIC_FIELDS = {
    "mouse_sensitivity": (0, 255),
    "screenblocks": (3, 11),
    "use_mouse": (0, 1),
}
DEFAULT_STRING_FIELDS = ("chatmacro0",)
EXPECTED_SAVE_VERSION = b"version 110"
MIN_SAVE_BYTES = 4096
SAVE_CONSISTENCY_MARKER = 0x1D
DOOM_PLAYER_RECORD_BYTES = 280
DOOM_PLAYER_RECORD_SCAN_BYTES = 4
DOOM_MOBJ_RECORD_BYTES = 156
DOOM_MOBJ_TYPE_OFFSET = 88
DOOM_MOBJ_STATE_OFFSET = 100
DOOM_MOBJ_PLAYER_OFFSET = 132
DOOM_NUM_STATES = 967
DOOM_NUM_MOBJ_TYPES = 137
DOOM_MAXPLAYERS = 4
MIN_ARCHIVED_WORLD_BYTES = 1024
MIN_SERIALIZED_NONZERO_BYTES = 64
MIN_SERIALIZED_DISTINCT_BYTES = 8
REQUIRED_DOOM_INIT_FLAGS = 0x000001FF
DOOM_THINKER_CLASSES = {
    0: ("tc_end", 0),
    1: ("tc_mobj", DOOM_MOBJ_RECORD_BYTES),
}
DOOM_SPECIAL_CLASSES = {
    0: ("tc_ceiling", 52),
    1: ("tc_door", 40),
    2: ("tc_floor", 44),
    3: ("tc_plat", 56),
    4: ("tc_flash", 36),
    5: ("tc_strobe", 36),
    6: ("tc_glow", 28),
    7: ("tc_endspecials", 0),
}
SAVE_STAGE_ARCHIVE_THINKERS_BEFORE = 0x05
SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE = 0x07
SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE = 0x15
SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE = 0x17
SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER = 0x18
SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED = 0x1A
SAVE_STREAM_UNSET_OFFSET = 0xFFFFFFFF
SAVE_STAGE_NAMES = {
    SAVE_STAGE_ARCHIVE_THINKERS_BEFORE: "archive-thinkers-before",
    SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE: "archive-specials-before",
    SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE: "unarchive-thinkers-before",
    SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE: "unarchive-specials-before",
    SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER: "unarchive-specials-after",
    SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED: "unarchive-thinkers-repaired",
}
FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
DEFAULT_ASSIGNMENT_PATTERN = re.compile(r"^([A-Za-z0-9_]+)\s+(.+)$")
REBOOT_EXACT_FIELDS = {
    "exec": "OK",
    "path": "DOOM.ELF",
    "doom": "OK",
    "doomrun": "RUN",
    "doomopen": "OK",
    "doomread": "OK",
    "gameplay": "OK",
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
REBOOT_ZERO_HEX_FIELDS = (
    "execerr",
    "execres",
    "doomexit",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
)
REBOOT_POSITIVE_HEX_FIELDS = (
    "target",
    "ppid",
    "entry",
    "stack",
    "argv",
    "envp",
    "argv0",
    "doomseek",
    "doomsbrk",
    "doompresent",
    "leveltime",
    "dtick",
    "free",
    "ticks",
)
DEFAULT_WRITE_EXACT_FIELDS = {
    "doom": "OK",
    "doomopen": "OK",
    "doomread": "OK",
    "gameplay": "OK",
    "panic": "NONE",
    "shutdown": "NONE",
    "usr": "OK",
    "wad": "OK",
}
DEFAULT_WRITE_ZERO_HEX_FIELDS = (
    "doomexit",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
)
DEFAULT_WRITE_REQUIRED_OPEN_FLAGS = 0x00000301
SAVE_WRITE_EXACT_FIELDS = {
    "doom": "OK",
    "doomopen": "OK",
    "doomread": "OK",
    "gameplay": "OK",
    "panic": "NONE",
    "shutdown": "NONE",
    "usr": "OK",
    "wad": "OK",
}
SAVE_WRITE_ZERO_HEX_FIELDS = DEFAULT_WRITE_ZERO_HEX_FIELDS
SAVE_WRITE_REQUIRED_OPEN_FLAGS = DEFAULT_WRITE_REQUIRED_OPEN_FLAGS
SAVELOAD_EVENT_OPEN = 0x0001
SAVELOAD_EVENT_READ = 0x0002
SAVELOAD_EVENT_WRITE = 0x0004
SAVELOAD_EVENT_CLOSE = 0x0008
SAVELOAD_REQUIRED_LOAD_FLAGS = SAVELOAD_EVENT_OPEN | SAVELOAD_EVENT_READ | SAVELOAD_EVENT_CLOSE
SAVEACTION_DESCRIPTION = 0x0004
SAVEACTION_SAVE_REQUESTED = 0x0008
SAVEACTION_SAVE_DONE = 0x0010
SAVEACTION_LOAD_REQUESTED = 0x0020
SAVEACTION_LOAD_DONE = 0x0040
SAVE_WRITE_REQUIRED_ACTION_FLAGS = (
    SAVEACTION_DESCRIPTION | SAVEACTION_SAVE_REQUESTED | SAVEACTION_SAVE_DONE
)
SAVE_LOAD_REQUIRED_ACTION_FLAGS = SAVEACTION_LOAD_REQUESTED | SAVEACTION_LOAD_DONE

spec = importlib.util.spec_from_file_location("make_wad_image", MAKE_WAD_IMAGE)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)


class PersistenceProofError(AssertionError):
    pass


def _trim_c_string(raw):
    return raw.split(b"\0", 1)[0].strip()


def _u32le(raw, offset):
    return int.from_bytes(raw[offset:offset + 4], "little", signed=False)


def _s32le(raw, offset):
    return int.from_bytes(raw[offset:offset + 4], "little", signed=True)


def _align4(offset):
    return offset + ((4 - (offset & 3)) & 3)


def _read_image(path):
    data = Path(path).read_bytes()
    if len(data) < make_wad_image.SECTOR_SIZE * (make_wad_image.PARTITION_START + 1):
        raise PersistenceProofError(f"{path} is too small to contain the FAT16 partition")
    return bytearray(data)


def _require_entry(fs, name):
    meta = fs.root_file_metadata(name)
    if meta is None:
        raise PersistenceProofError(f"missing FAT16 root entry {name.decode('ascii', 'replace')}")
    return meta


def _validate_fat_layout(fs):
    try:
        fs.validate_fat_copies_match()
        fs.validate_allocated_clusters_reachable()
    except ValueError as exc:
        raise PersistenceProofError(str(exc)) from exc


def _validate_dynamic_fat_proof(image):
    try:
        proof = make_wad_image.prove_dynamic_fat16_mutation(
            make_wad_image.Fat16Image(bytearray(image))
        )
    except ValueError as exc:
        raise PersistenceProofError(f"dynamic FAT mutation proof failed: {exc}") from exc
    return proof


def _validate_protected_entries(fs, baseline_fs=None):
    for name in make_wad_image.PROTECTED_ROOT_NAMES:
        meta = _require_entry(fs, name)
        if not meta["protected"]:
            raise PersistenceProofError(f"{name!r} is not marked protected by the image parser")
        if meta["size"] <= 0 or meta["cluster"] < 2:
            raise PersistenceProofError(f"{name!r} does not point at persisted file data")
        try:
            current = fs.read_root_file(name)
        except ValueError as exc:
            raise PersistenceProofError(f"{name!r} has an invalid FAT chain: {exc}") from exc
        if meta["size"] != len(current):
            raise PersistenceProofError(f"{name!r} metadata size does not match readable bytes")
        if baseline_fs is not None:
            baseline_meta = _require_entry(baseline_fs, name)
            if (
                meta["cluster"] != baseline_meta["cluster"]
                or meta["size"] != baseline_meta["size"]
                or current != baseline_fs.read_root_file(name)
            ):
                label = name.decode("ascii", "replace").strip()
                raise PersistenceProofError(f"protected entry {label} changed from baseline image")


def _validate_default(fs):
    meta = _require_entry(fs, make_wad_image.WRITABLE_DEFAULT_NAME)
    data = fs.read_root_file(make_wad_image.WRITABLE_DEFAULT_NAME)
    if meta["size"] != len(data):
        raise PersistenceProofError("DEFAULT.CFG metadata size does not match readable bytes")
    if not data:
        raise PersistenceProofError("DEFAULT.CFG is still empty")
    if len(data) > make_wad_image.WRITABLE_DEFAULT_BYTES:
        raise PersistenceProofError("DEFAULT.CFG exceeds the configured Doom defaults capacity")
    if b"\0" in data:
        raise PersistenceProofError("DEFAULT.CFG contains NUL bytes")
    if not data.endswith(b"\n"):
        tail = data[-1] if data else 0
        raise PersistenceProofError(
            f"DEFAULT.CFG is not newline-terminated (bytes={len(data)}, last=0x{tail:02X})"
        )
    missing = [marker.decode("ascii") for marker in DEFAULT_MARKERS if marker not in data]
    if missing:
        raise PersistenceProofError(
            "DEFAULT.CFG does not look like a complete Doom defaults file; "
            f"missing {', '.join(missing)}"
        )
    try:
        text = data.decode("ascii")
    except UnicodeDecodeError as exc:
        raise PersistenceProofError("DEFAULT.CFG is not ASCII text") from exc

    fields = {}
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        match = DEFAULT_ASSIGNMENT_PATTERN.fullmatch(stripped)
        if not match:
            raise PersistenceProofError(f"DEFAULT.CFG has malformed defaults line {stripped!r}")
        fields[match.group(1)] = match.group(2).strip()

    for name, (minimum, maximum) in DEFAULT_NUMERIC_FIELDS.items():
        value = fields.get(name)
        if value is None:
            raise PersistenceProofError(f"DEFAULT.CFG missing {name} assignment")
        try:
            parsed = int(value, 10)
        except ValueError as exc:
            raise PersistenceProofError(f"DEFAULT.CFG {name} is not an integer") from exc
        if not (minimum <= parsed <= maximum):
            raise PersistenceProofError(
                f"DEFAULT.CFG {name}={parsed} is outside {minimum}..{maximum}"
            )

    for name in DEFAULT_STRING_FIELDS:
        value = fields.get(name)
        if value is None:
            raise PersistenceProofError(f"DEFAULT.CFG missing {name} assignment")
        if len(value) < 2 or not (value.startswith('"') and value.endswith('"')):
            raise PersistenceProofError(f"DEFAULT.CFG {name} must be a quoted string")

    return len(data)


def _boolean_words(data, offset, count):
    return [_u32le(data, offset + index * 4) for index in range(count)]


def _validate_plausible_player_record(data, offset):
    if offset + DOOM_PLAYER_RECORD_BYTES >= len(data):
        return False, "record would run past save payload"

    checks = []
    playerstate = _u32le(data, offset + 4)
    viewheight = _s32le(data, offset + 20)
    health = _s32le(data, offset + 32)
    armorpoints = _s32le(data, offset + 36)
    armortype = _s32le(data, offset + 40)
    powers = [_s32le(data, offset + 44 + index * 4) for index in range(6)]
    cards = _boolean_words(data, offset + 68, 6)
    backpack = _u32le(data, offset + 92)
    readyweapon = _u32le(data, offset + 112)
    pendingweapon = _u32le(data, offset + 116)
    weaponowned = _boolean_words(data, offset + 120, 9)
    ammo = [_s32le(data, offset + 156 + index * 4) for index in range(4)]
    maxammo = [_s32le(data, offset + 172 + index * 4) for index in range(4)]
    cheats = _s32le(data, offset + 196)
    refire = _s32le(data, offset + 200)
    colormap = _s32le(data, offset + 240)
    didsecret = _u32le(data, offset + 276)
    psprite_states = [_u32le(data, offset + 244 + index * 16) for index in range(2)]

    checks.append((playerstate in (0, 1, 2), f"playerstate={playerstate}"))
    checks.append((0 <= viewheight <= 64 * 65536, f"viewheight={viewheight}"))
    checks.append((-100 <= health <= 300, f"health={health}"))
    checks.append((0 <= armorpoints <= 300, f"armorpoints={armorpoints}"))
    checks.append((0 <= armortype <= 2, f"armortype={armortype}"))
    checks.append((all(0 <= value <= 200000 for value in powers), f"powers={powers}"))
    checks.append((all(value in (0, 1) for value in cards), f"cards={cards}"))
    checks.append((backpack in (0, 1), f"backpack={backpack}"))
    checks.append((0 <= readyweapon <= 8, f"readyweapon={readyweapon}"))
    checks.append((0 <= pendingweapon <= 10, f"pendingweapon={pendingweapon}"))
    checks.append((all(value in (0, 1) for value in weaponowned), f"weaponowned={weaponowned}"))
    checks.append((weaponowned[0] == 1 and weaponowned[1] == 1, "missing fist/pistol ownership"))
    checks.append((all(0 <= value <= 1000 for value in ammo), f"ammo={ammo}"))
    checks.append((all(1 <= value <= 1000 for value in maxammo), f"maxammo={maxammo}"))
    checks.append((all(value <= limit for value, limit in zip(ammo, maxammo)), "ammo exceeds maxammo"))
    checks.append((0 <= cheats <= 7, f"cheats={cheats}"))
    checks.append((0 <= refire <= 255, f"refire={refire}"))
    checks.append((0 <= colormap <= 3, f"colormap={colormap}"))
    checks.append((didsecret in (0, 1), f"didsecret={didsecret}"))
    checks.append((all(value <= 2048 for value in psprite_states), f"psprite states={psprite_states}"))

    for ok, reason in checks:
        if not ok:
            return False, reason
    return True, "OK"


def _find_plausible_player_record(data, slot):
    reasons = []
    for pad in range(DOOM_PLAYER_RECORD_SCAN_BYTES):
        offset = SAVE_GAMESTATE_OFFSET + pad
        ok, reason = _validate_plausible_player_record(data, offset)
        if ok:
            return offset
        reasons.append(f"+{pad}: {reason}")
    raise PersistenceProofError(
        f"DOOMSAV{slot}.DSG does not contain a plausible archived Doom player record "
        f"after the save header ({'; '.join(reasons)})"
    )


def _parse_save_stream_offset(value, label):
    try:
        offset = int(str(value), 0)
    except ValueError as exc:
        raise PersistenceProofError(f"{label} must be an integer offset, got {value!r}") from exc
    if offset < 0:
        raise PersistenceProofError(f"{label} must not be negative")
    return offset


def _save_stage_name(stage):
    return SAVE_STAGE_NAMES.get(stage, f"unknown-stage-0x{stage:X}")


def _save_stream_next_byte(value):
    return (value >> 24) & 0xFF


def _runtime_stream_offsets(status, *, expected_slot=None):
    if status is None:
        return {}
    fields = _status_fields(status)
    offsets = {}
    if "savestm" in fields:
        stage, slot, offset, value, reports = _status_hex_tuple_field(fields, "savestm", 5)
        offsets["savestm"] = {
            "stage": stage,
            "stage_name": _save_stage_name(stage),
            "slot": slot,
            "offset": offset,
            "value": value,
            "reports": reports,
        }
        if reports != 0:
            if expected_slot is not None and slot != expected_slot:
                raise PersistenceProofError(
                    f"save stream status savestm= slot must be {expected_slot}, got {slot}"
                )
            if offset == SAVE_STREAM_UNSET_OFFSET:
                raise PersistenceProofError(
                    "save stream status savestm= reported an unset stream offset"
                )
            if stage in (SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE, SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE):
                offsets["specials"] = offset
            elif stage == SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER:
                offsets["specials_after"] = offset
            elif stage == SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE:
                offsets["thinkers"] = offset
            elif stage == SAVE_STAGE_ARCHIVE_THINKERS_BEFORE:
                offsets["archive_thinkers"] = offset
            elif stage == SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED:
                offsets["repaired_thinkers"] = offset
    if "savethk" in fields:
        archive_offset, archive_value, unarchive_offset, unarchive_value = (
            _status_hex_tuple_field(fields, "savethk", 4)
        )
        offsets["savethk"] = {
            "archive_offset": archive_offset,
            "archive_value": archive_value,
            "unarchive_offset": unarchive_offset,
            "unarchive_value": unarchive_value,
        }
        if unarchive_offset != SAVE_STREAM_UNSET_OFFSET:
            offsets["thinkers"] = unarchive_offset
        elif archive_offset != SAVE_STREAM_UNSET_OFFSET:
            offsets["thinkers"] = archive_offset
    return offsets


def validate_save_load_stream_status(status, *, slot):
    runtime_offsets = _runtime_stream_offsets(status, expected_slot=slot)
    savethk = runtime_offsets.get("savethk")
    if savethk is None:
        raise PersistenceProofError(
            "save load status savethk= must prove the unarchive thinker stream boundary"
        )
    if savethk["unarchive_offset"] == SAVE_STREAM_UNSET_OFFSET:
        raise PersistenceProofError(
            "save load status savethk= must report the unarchive thinker stream offset"
        )

    savestm = runtime_offsets.get("savestm")
    if savestm is None:
        raise PersistenceProofError(
            "save load status savestm= must prove the unarchive specials stream boundary"
        )
    if savestm["reports"] == 0:
        raise PersistenceProofError(
            "save load status savestm= must include at least one save-stream report"
        )
    if savestm["stage"] == SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED:
        raise PersistenceProofError(
            "save load status savestm= reports a repaired thinker stream; "
            "this cannot be claimed as an original Doom save/load proof"
        )
    if savestm["stage"] not in (
        SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE,
        SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER,
    ):
        raise PersistenceProofError(
            "save load status savestm= must reach the original Doom "
            "P_UnArchiveSpecials entrypoint before save/load proof can be green; "
            f"got {_save_stage_name(savestm['stage'])}"
        )
    if "thinkers" not in runtime_offsets:
        raise PersistenceProofError(
            "save load status must provide the thinker stream offset"
        )
    if "specials" not in runtime_offsets and "specials_after" not in runtime_offsets:
        raise PersistenceProofError(
            "save load status must provide the specials stream boundary"
        )
    return runtime_offsets


def _require_save_offset(data, offset, label):
    if offset < SAVE_GAMESTATE_OFFSET:
        raise PersistenceProofError(
            f"{label} offset 0x{offset:X} points inside the Doom save header"
        )
    final_payload_offset = len(data) - 1
    if offset >= final_payload_offset:
        raise PersistenceProofError(
            f"{label} offset 0x{offset:X} points outside serialized game-state bytes"
        )


def _validate_mobj_record_semantics(data, record_offset, class_offset, slot):
    # Doom saves mobj_t->state/type/player as small table/player indexes, not pointers.
    state = _u32le(data, record_offset + DOOM_MOBJ_STATE_OFFSET)
    mobj_type = _u32le(data, record_offset + DOOM_MOBJ_TYPE_OFFSET)
    player = _u32le(data, record_offset + DOOM_MOBJ_PLAYER_OFFSET)

    if state >= DOOM_NUM_STATES:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG malformed thinker stream at 0x{class_offset:X}: "
            f"tc_mobj semantic state index {state} outside 0..{DOOM_NUM_STATES - 1}"
        )
    if mobj_type >= DOOM_NUM_MOBJ_TYPES:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG malformed thinker stream at 0x{class_offset:X}: "
            f"tc_mobj semantic type index {mobj_type} outside 0..{DOOM_NUM_MOBJ_TYPES - 1}"
        )
    if player > DOOM_MAXPLAYERS:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG malformed thinker stream at 0x{class_offset:X}: "
            f"tc_mobj semantic player index {player} outside 0..{DOOM_MAXPLAYERS}"
        )


def parse_thinker_stream(data, offset, *, slot=0):
    """Parse Doom's P_ArchiveThinkers class stream from a save payload."""

    _require_save_offset(data, offset, f"DOOMSAV{slot}.DSG thinker stream")
    cursor = offset
    counts = {}
    final_payload_offset = len(data) - 1
    while cursor < final_payload_offset:
        class_offset = cursor
        tclass = data[cursor]
        cursor += 1
        name, record_size = DOOM_THINKER_CLASSES.get(tclass, (None, None))
        if name is None:
            raise PersistenceProofError(
                f"DOOMSAV{slot}.DSG malformed thinker stream at 0x{class_offset:X}: "
                f"unknown tclass {tclass}"
            )
        counts[name] = counts.get(name, 0) + 1
        if name == "tc_end":
            return {
                "offset": offset,
                "end_offset": class_offset + 1,
                "counts": counts,
                "terminator": name,
            }
        record_offset = _align4(cursor)
        record_end = record_offset + record_size
        if record_end > final_payload_offset:
            raise PersistenceProofError(
                f"DOOMSAV{slot}.DSG malformed thinker stream at 0x{class_offset:X}: "
                f"{name} record runs past save payload"
            )
        if name == "tc_mobj":
            _validate_mobj_record_semantics(data, record_offset, class_offset, slot)
        cursor = record_end
    raise PersistenceProofError(
        f"DOOMSAV{slot}.DSG malformed thinker stream from 0x{offset:X}: "
        "missing tc_end before final consistency marker"
    )


def parse_specials_stream(data, offset, *, slot=0):
    """Parse Doom's P_ArchiveSpecials class stream from a save payload."""

    _require_save_offset(data, offset, f"DOOMSAV{slot}.DSG specials stream")
    cursor = offset
    counts = {}
    final_payload_offset = len(data) - 1
    while cursor < final_payload_offset:
        class_offset = cursor
        tclass = data[cursor]
        cursor += 1
        name, record_size = DOOM_SPECIAL_CLASSES.get(tclass, (None, None))
        if name is None:
            raise PersistenceProofError(
                f"DOOMSAV{slot}.DSG malformed specials stream at 0x{class_offset:X}: "
                f"unknown special tclass {tclass}"
            )
        counts[name] = counts.get(name, 0) + 1
        if name == "tc_endspecials":
            if class_offset + 1 != final_payload_offset:
                raise PersistenceProofError(
                    f"DOOMSAV{slot}.DSG malformed specials stream at 0x{class_offset:X}: "
                    "tc_endspecials is not immediately followed by Doom's final consistency marker"
                )
            return {
                "offset": offset,
                "end_offset": class_offset + 1,
                "counts": counts,
                "terminator": name,
            }
        record_offset = _align4(cursor)
        record_end = record_offset + record_size
        if record_end > final_payload_offset:
            raise PersistenceProofError(
                f"DOOMSAV{slot}.DSG malformed specials stream at 0x{class_offset:X}: "
                f"{name} record runs past save payload"
            )
        cursor = record_end
    raise PersistenceProofError(
        f"DOOMSAV{slot}.DSG malformed specials stream from 0x{offset:X}: "
        "missing tc_endspecials before final consistency marker"
    )


def _stream_summary(prefix, parsed):
    count_text = ",".join(
        f"{name}={count}" for name, count in sorted(parsed["counts"].items())
    )
    return (
        f"{prefix}=OK offset=0x{parsed['offset']:X} end=0x{parsed['end_offset']:X} "
        f"{count_text}"
    )


def _validate_save_slot(
    fs,
    slot,
    *,
    thinker_offset=None,
    specials_offset=None,
    stream_status=None,
):
    if slot < 0 or slot >= len(make_wad_image.WRITABLE_SAVE_NAMES):
        raise PersistenceProofError(f"save slot {slot} is outside DOOMSAV0.DSG..DOOMSAV5.DSG")

    name = make_wad_image.WRITABLE_SAVE_NAMES[slot]
    meta = _require_entry(fs, name)
    data = fs.read_root_file(name)
    if meta["size"] != len(data):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG metadata size does not match readable bytes")
    if len(data) > make_wad_image.WRITABLE_SAVE_BYTES:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG exceeds the configured Doom save capacity")
    if len(data) < SAVE_GAMESTATE_OFFSET:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG is too small for a Doom save header")
    if len(data) < MIN_SAVE_BYTES:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG is too small for a real Doom save payload")
    if data[-1] != SAVE_CONSISTENCY_MARKER:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG is missing Doom's final 0x{SAVE_CONSISTENCY_MARKER:02X} consistency marker"
        )

    description = _trim_c_string(data[:SAVE_DESCRIPTION_BYTES])
    version_bytes = data[SAVE_DESCRIPTION_BYTES:SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES]
    if not description:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has an empty save description")
    if any(ch < 0x20 or ch > 0x7E for ch in description):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has a non-printable save description")
    if b"\0" not in data[:SAVE_DESCRIPTION_BYTES]:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG save description is not NUL-terminated")
    if (
        version_bytes[:len(EXPECTED_SAVE_VERSION)] != EXPECTED_SAVE_VERSION
        or any(version_bytes[len(EXPECTED_SAVE_VERSION):])
    ):
        version = _trim_c_string(version_bytes)
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has unexpected Doom version {version!r}")
    version = EXPECTED_SAVE_VERSION
    if version != EXPECTED_SAVE_VERSION:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has unexpected Doom version {version!r}")
    skill = data[SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES]
    episode = data[SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 1]
    game_map = data[SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 2]
    player_flags = data[
        SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 3:
        SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 7
    ]
    leveltime = (
        (data[SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 7] << 16)
        | (data[SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 8] << 8)
        | data[SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 9]
    )
    if skill > 4:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has an invalid skill byte")
    if not (1 <= episode <= 4 and 1 <= game_map <= 9):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has an invalid episode/map header")
    if tuple(player_flags) != (1, 0, 0, 0):
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG must be a single-player save with only player 1 active"
        )
    if leveltime == 0:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has zero leveltime in the save header")

    player_record_offset = _find_plausible_player_record(data, slot)
    serialized = data[SAVE_GAMESTATE_OFFSET:-1]
    archived_world = data[player_record_offset + DOOM_PLAYER_RECORD_BYTES:-1]
    if len(archived_world) < MIN_ARCHIVED_WORLD_BYTES:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG does not contain enough archived Doom world state"
        )
    if sum(byte != 0 for byte in serialized) < MIN_SERIALIZED_NONZERO_BYTES:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG does not contain serialized game-state bytes")
    if len(set(serialized)) < MIN_SERIALIZED_DISTINCT_BYTES:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG serialized game-state bytes are too uniform for a Doom save"
        )

    stream_summaries = []
    runtime_offsets = _runtime_stream_offsets(stream_status, expected_slot=slot)
    if thinker_offset is None:
        thinker_offset = runtime_offsets.get("thinkers")
    if specials_offset is None:
        specials_offset = runtime_offsets.get("specials")
    if thinker_offset is not None:
        parsed = parse_thinker_stream(data, thinker_offset, slot=slot)
        stream_summaries.append(_stream_summary("thinkers", parsed))
    if specials_offset is not None:
        parsed = parse_specials_stream(data, specials_offset, slot=slot)
        stream_summaries.append(_stream_summary("specials", parsed))
    return (
        len(data),
        description.decode("ascii", "replace"),
        version.decode("ascii", "replace"),
        skill,
        episode,
        game_map,
        leveltime,
        stream_summaries,
    )


def _validate_expected_save_description(slot, actual, expected):
    try:
        encoded = expected.encode("ascii")
    except UnicodeEncodeError as exc:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG expected save description must be ASCII"
        ) from exc
    if not encoded:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG expected save description must not be empty"
        )
    if len(encoded) >= SAVE_DESCRIPTION_BYTES:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG expected save description must fit in "
            f"{SAVE_DESCRIPTION_BYTES - 1} bytes"
        )
    if any(ch < 0x20 or ch > 0x7E for ch in encoded):
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG expected save description must be printable ASCII"
        )
    if actual != expected:
        raise PersistenceProofError(
            f"DOOMSAV{slot}.DSG description must be {expected!r}, got {actual!r}"
        )


def _require_fresh_save_baseline(baseline_fs, name, label):
    if baseline_fs is None:
        raise PersistenceProofError(
            f"{label} save-slot proof requires --baseline-image with a fresh empty slot"
        )
    baseline_meta = _require_entry(baseline_fs, name)
    baseline = baseline_fs.read_root_file(name)
    if baseline_meta["cluster"] != 0 or baseline_meta["size"] != 0 or baseline:
        raise PersistenceProofError(
            f"{label} baseline image is already populated; save-slot proof requires "
            "a fresh empty baseline so preseeded evidence cannot pass"
        )


def _require_changed(fs, baseline_fs, name, label):
    if baseline_fs is None:
        return
    current = fs.read_root_file(name)
    baseline = baseline_fs.read_root_file(name)
    if current == baseline:
        raise PersistenceProofError(f"{label} did not change from baseline image")


def _format_save_status_diagnostics(status):
    if status is None:
        return ""
    try:
        fields = _status_fields(status)
    except PersistenceProofError as exc:
        return f" status=unparseable({exc})"

    interesting = (
        "doomsav",
        "saverd",
        "savewr",
        "saveclose",
        "savemode",
        "saveact",
        "savedesc",
        "savestm",
        "savethk",
        "doomwrite",
        "doomclose",
        "doommode",
        "fwr",
        "fio",
        "fal",
        "fam",
        "fac",
        "fault",
    )
    present = [f"{name}={fields[name]}" for name in interesting if name in fields]
    return f" status: {' '.join(present)}" if present else ""


def _format_save_slot_diagnostics(fs, slot, status=None):
    name = make_wad_image.WRITABLE_SAVE_NAMES[slot]
    label = f"DOOMSAV{slot}.DSG"
    pieces = []
    try:
        meta = _require_entry(fs, name)
        pieces.append(f"size={meta['size']}")
        pieces.append(f"cluster={meta['cluster']}")
        if meta["cluster"]:
            try:
                chain = fs.cluster_chain(meta["cluster"])
                pieces.append(f"clusters={len(chain)}")
            except ValueError as exc:
                pieces.append(f"chain_error={exc}")
        try:
            data = fs.read_root_file(name)
            pieces.append(f"readable={len(data)}")
            if data:
                pieces.append(f"last=0x{data[-1]:02X}")
        except ValueError as exc:
            pieces.append(f"read_error={exc}")
    except PersistenceProofError as exc:
        pieces.append(f"entry_error={exc}")
    return (
        f"{label} diagnostics: {', '.join(pieces)}"
        f"{_format_save_status_diagnostics(status)}"
    )


def _require_save_write_covers_payload(status, *, slot, save_size):
    fields = _status_fields(status)
    saveload_flags, saveload_slot = _status_hex_tuple_field(fields, "doomsav", 2)
    if saveload_slot != slot:
        raise PersistenceProofError(
            f"save write status doomsav= slot must be {slot}, got {saveload_slot}"
        )
    if (saveload_flags & SAVELOAD_EVENT_WRITE) == 0:
        raise PersistenceProofError(
            "save write status doomsav= must include a DOOMSAV write event"
        )
    save_write_bytes, save_write_events = _status_hex_tuple_field(fields, "savewr", 2)
    if save_write_events == 0:
        raise PersistenceProofError("save write status savewr= must report a write event")
    if save_write_bytes < save_size:
        raise PersistenceProofError(
            f"save write status savewr= must cover the full persisted DOOMSAV{slot}.DSG payload "
            f"({save_write_bytes} < {save_size})"
        )


def _require_reboot_survived(fs, reboot_fs, name, label):
    if reboot_fs is None:
        return
    current_meta = _require_entry(fs, name)
    reboot_meta = _require_entry(reboot_fs, name)
    current = fs.read_root_file(name)
    reboot = reboot_fs.read_root_file(name)
    if (
        current_meta["cluster"] != reboot_meta["cluster"]
        or current_meta["size"] != reboot_meta["size"]
        or current != reboot
    ):
        raise PersistenceProofError(f"{label} did not survive reboot image comparison")


def _status_fields(status):
    fields = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise PersistenceProofError(f"reboot status has duplicate {name}= field")
        fields[name] = match.group(2)
    if not fields:
        raise PersistenceProofError("reboot status has no key=value fields")
    return fields


def _status_field(fields, name):
    value = fields.get(name)
    if value is None:
        raise PersistenceProofError(f"reboot status missing {name}= field")
    return value


def _status_hex_field(fields, name):
    value = _status_field(fields, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        raise PersistenceProofError(
            f"reboot status {name}= must be eight hex digits, got {value!r}"
        )
    return int(value, 16)


def _status_hex_tuple_field(fields, name, count, separator="/"):
    value = _status_field(fields, name)
    parts = value.split(separator)
    if len(parts) != count:
        raise PersistenceProofError(
            f"reboot status {name}= must have {count} hex parts separated by {separator!r}"
        )
    parsed = []
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            raise PersistenceProofError(
                f"reboot status {name}= part must be eight hex digits, got {part!r}"
            )
        parsed.append(int(part, 16))
    return tuple(parsed)


def validate_reboot_status(status):
    if "Aurora OS v0.2" not in status:
        raise PersistenceProofError("reboot status is missing Aurora OS banner")

    fields = _status_fields(status)
    for name, expected in REBOOT_EXACT_FIELDS.items():
        value = _status_field(fields, name)
        if value != expected:
            raise PersistenceProofError(
                f"reboot status {name}= must be {expected}, got {value!r}"
            )

    for name in REBOOT_ZERO_HEX_FIELDS:
        value = _status_hex_field(fields, name)
        if value != 0:
            raise PersistenceProofError(f"reboot status {name}= must be zero, got {value:#x}")

    for name in REBOOT_POSITIVE_HEX_FIELDS:
        value = _status_hex_field(fields, name)
        if value == 0:
            raise PersistenceProofError(f"reboot status {name}= must be nonzero")

    if _status_hex_field(fields, "argc") != 1:
        raise PersistenceProofError("reboot status argc= must prove a single argv[0]")
    if _status_hex_field(fields, "envp0") != 0:
        raise PersistenceProofError("reboot status envp0= must prove an empty envp")

    attempts, successes, failures, handoffs, scheduled, rollbacks = _status_hex_tuple_field(
        fields, "execsys", 6
    )
    if attempts == 0 or successes == 0 or handoffs == 0 or scheduled == 0:
        raise PersistenceProofError(
            "reboot status execsys= must prove a successful syscall exec handoff"
        )
    if failures != 0 or rollbacks != 0:
        raise PersistenceProofError("reboot status execsys= must not report failures")

    opens, reads, seeks, magic = _status_hex_tuple_field(fields, "doomwad", 4)
    if opens == 0 or reads == 0 or seeks == 0:
        raise PersistenceProofError("reboot status doomwad= must prove WAD open/read/lseek")
    if magic != 0x44415749:
        raise PersistenceProofError(f"reboot status doomwad= magic must be IWAD, got {magic:#x}")

    init_flags, init_reports = _status_hex_tuple_field(fields, "doominit", 2)
    if (init_flags & REQUIRED_DOOM_INIT_FLAGS) != REQUIRED_DOOM_INIT_FLAGS:
        raise PersistenceProofError(
            f"reboot status doominit= flags must include {REQUIRED_DOOM_INIT_FLAGS:#x}"
        )
    if init_reports == 0:
        raise PersistenceProofError("reboot status doominit= report count must be nonzero")

    if any(_status_hex_tuple_field(fields, "fault", 11)):
        raise PersistenceProofError("reboot status fault= must be all zero")


def validate_default_write_status(status):
    if "Aurora OS v0.2" not in status:
        raise PersistenceProofError("default write status is missing Aurora OS banner")

    fields = _status_fields(status)
    run_state = _status_field(fields, "doomrun")
    if run_state not in ("RUN", "EXIT"):
        raise PersistenceProofError(
            f"default write status doomrun= must be RUN or EXIT, got {run_state!r}"
        )

    for name, expected in DEFAULT_WRITE_EXACT_FIELDS.items():
        value = _status_field(fields, name)
        if value != expected:
            raise PersistenceProofError(
                f"default write status {name}= must be {expected}, got {value!r}"
            )

    for name in DEFAULT_WRITE_ZERO_HEX_FIELDS:
        value = _status_hex_field(fields, name)
        if value != 0:
            raise PersistenceProofError(
                f"default write status {name}= must be zero, got {value:#x}"
            )

    write_count = _status_hex_field(fields, "doomwrite")
    close_count = _status_hex_field(fields, "doomclose")
    if write_count == 0:
        raise PersistenceProofError("default write status doomwrite= must prove file output")
    if close_count < 3:
        raise PersistenceProofError(
            "default write status doomclose= must prove DEFAULT.CFG was closed"
        )

    flags, _mode = _status_hex_tuple_field(fields, "doommode", 2, separator=":")
    if flags != DEFAULT_WRITE_REQUIRED_OPEN_FLAGS:
        raise PersistenceProofError(
            "default write status doommode= must prove DEFAULT.CFG was opened "
            f"O_WRONLY|O_CREAT|O_TRUNC, got {flags:#x}"
        )

    if any(_status_hex_tuple_field(fields, "fault", 11)):
        raise PersistenceProofError("default write status fault= must be all zero")


def validate_save_write_status(status, expected_slot=None):
    if "Aurora OS v0.2" not in status:
        raise PersistenceProofError("save write status is missing Aurora OS banner")

    fields = _status_fields(status)
    run_state = _status_field(fields, "doomrun")
    if run_state not in ("RUN", "EXIT"):
        raise PersistenceProofError(
            f"save write status doomrun= must be RUN or EXIT, got {run_state!r}"
        )

    for name, expected in SAVE_WRITE_EXACT_FIELDS.items():
        value = _status_field(fields, name)
        if value != expected:
            raise PersistenceProofError(
                f"save write status {name}= must be {expected}, got {value!r}"
            )

    for name in SAVE_WRITE_ZERO_HEX_FIELDS:
        value = _status_hex_field(fields, name)
        if value != 0:
            raise PersistenceProofError(
                f"save write status {name}= must be zero, got {value:#x}"
            )

    write_count = _status_hex_field(fields, "doomwrite")
    close_count = _status_hex_field(fields, "doomclose")
    if write_count == 0:
        raise PersistenceProofError("save write status doomwrite= must prove file output")
    if close_count == 0:
        raise PersistenceProofError("save write status doomclose= must prove the save file was closed")

    flags, _mode = _status_hex_tuple_field(fields, "doommode", 2, separator=":")
    if flags != SAVE_WRITE_REQUIRED_OPEN_FLAGS:
        raise PersistenceProofError(
            "save write status doommode= must prove DOOMSAV was opened "
            f"O_WRONLY|O_CREAT|O_TRUNC, got {flags:#x}"
        )

    saveload_flags, saveload_slot = _status_hex_tuple_field(fields, "doomsav", 2)
    if expected_slot is not None and saveload_slot != expected_slot:
        raise PersistenceProofError(
            f"save write status doomsav= slot must be {expected_slot}, got {saveload_slot}"
        )
    if (saveload_flags & (SAVELOAD_EVENT_OPEN | SAVELOAD_EVENT_WRITE | SAVELOAD_EVENT_CLOSE)) != (
        SAVELOAD_EVENT_OPEN | SAVELOAD_EVENT_WRITE | SAVELOAD_EVENT_CLOSE
    ):
        raise PersistenceProofError(
            "save write status doomsav= must prove a DOOMSAV open/write/close path"
        )
    save_write_bytes, save_write_events = _status_hex_tuple_field(fields, "savewr", 2)
    if save_write_bytes == 0 or save_write_events == 0:
        raise PersistenceProofError("save write status savewr= must prove DOOMSAV payload bytes")
    if _status_hex_field(fields, "saveclose") == 0:
        raise PersistenceProofError("save write status saveclose= must prove a DOOMSAV close")
    save_flags, _save_mode = _status_hex_tuple_field(fields, "savemode", 2, separator=":")
    if save_flags != SAVE_WRITE_REQUIRED_OPEN_FLAGS:
        raise PersistenceProofError(
            "save write status savemode= must prove DOOMSAV was opened "
            f"O_WRONLY|O_CREAT|O_TRUNC, got {save_flags:#x}"
        )

    saveaction_flags, _saveaction_gameaction, saveaction_slot, saveaction_reports = (
        _status_hex_tuple_field(fields, "saveact", 4)
    )
    if expected_slot is not None and saveaction_slot != expected_slot:
        raise PersistenceProofError(
            f"save write status saveact= slot must be {expected_slot}, got {saveaction_slot}"
        )
    if saveaction_reports == 0:
        raise PersistenceProofError("save write status saveact= must prove Doom action reporting")
    if (saveaction_flags & SAVE_WRITE_REQUIRED_ACTION_FLAGS) != SAVE_WRITE_REQUIRED_ACTION_FLAGS:
        raise PersistenceProofError(
            "save write status saveact= must prove the original Doom save was "
            "requested, described, and completed through the original Doom ticker path"
        )
    savedesc_len, savedesc_hash = _status_hex_tuple_field(fields, "savedesc", 2)
    if savedesc_len == 0 or savedesc_hash == 0:
        raise PersistenceProofError(
            "save write status savedesc= must preserve the Doom save description marker"
        )

    if any(_status_hex_tuple_field(fields, "fault", 11)):
        raise PersistenceProofError("save write status fault= must be all zero")


def validate_save_load_status(status, *, slot, save_size, episode, game_map, leveltime):
    validate_reboot_status(status)

    fields = _status_fields(status)
    saveload_flags, saveload_slot = _status_hex_tuple_field(fields, "doomsav", 2)
    if saveload_slot != slot:
        raise PersistenceProofError(
            f"save load status doomsav= slot must be {slot}, got {saveload_slot}"
        )
    if (saveload_flags & SAVELOAD_REQUIRED_LOAD_FLAGS) != SAVELOAD_REQUIRED_LOAD_FLAGS:
        raise PersistenceProofError(
            "save load status doomsav= must prove a DOOMSAV open/read/close path"
        )

    read_bytes, read_events = _status_hex_tuple_field(fields, "saverd", 2)
    if read_events == 0:
        raise PersistenceProofError("save load status saverd= must prove at least one DOOMSAV read")
    if read_bytes < save_size:
        raise PersistenceProofError(
            f"save load status saverd= must read the full DOOMSAV payload "
            f"({read_bytes} < {save_size})"
        )
    if _status_hex_field(fields, "saveclose") == 0:
        raise PersistenceProofError("save load status saveclose= must prove a DOOMSAV close")

    saveaction_flags, saveaction_gameaction, saveaction_slot, saveaction_reports = (
        _status_hex_tuple_field(fields, "saveact", 4)
    )
    if saveaction_slot != slot:
        raise PersistenceProofError(
            f"save load status saveact= slot must be {slot}, got {saveaction_slot}"
        )
    if saveaction_reports == 0:
        raise PersistenceProofError("save load status saveact= must prove Doom action reporting")
    if (saveaction_flags & SAVE_LOAD_REQUIRED_ACTION_FLAGS) != SAVE_LOAD_REQUIRED_ACTION_FLAGS:
        raise PersistenceProofError(
            "save load status saveact= must prove the original Doom load was "
            "requested and completed after G_DoLoadGame returned"
        )
    if saveaction_gameaction != 0:
        raise PersistenceProofError(
            f"save load status saveact= gameaction must be ga_nothing after load, got {saveaction_gameaction}"
        )

    expected_map = (episode << 8) | game_map
    actual_map = _status_hex_field(fields, "gmap")
    if actual_map != expected_map:
        raise PersistenceProofError(
            f"save load status gmap= must match the saved episode/map "
            f"0x{expected_map:08X}, got 0x{actual_map:08X}"
        )

    actual_leveltime = _status_hex_field(fields, "leveltime")
    if actual_leveltime < leveltime:
        raise PersistenceProofError(
            f"save load status leveltime= must be at least the saved leveltime "
            f"({actual_leveltime} < {leveltime})"
        )


def validate_image(
    path,
    *,
    baseline_image=None,
    reboot_baseline_image=None,
    reboot_status_path=None,
    write_status_path=None,
    save_write_status_path=None,
    load_status_path=None,
    require_default=False,
    require_save_slots=(),
    require_save_descriptions=None,
    require_dynamic_fat_proof=False,
    save_thinker_offset=None,
    save_specials_offset=None,
):
    image = _read_image(path)
    fs = make_wad_image.Fat16Image(image)
    baseline_fs = make_wad_image.Fat16Image(_read_image(baseline_image)) if baseline_image else None
    reboot_fs = (
        make_wad_image.Fat16Image(_read_image(reboot_baseline_image))
        if reboot_baseline_image
        else None
    )
    require_save_descriptions = require_save_descriptions or {}
    summary = []

    if baseline_fs is not None and not require_default and not require_save_slots:
        raise PersistenceProofError(
            "baseline image comparison requires --require-default or --require-save-slot"
        )
    if reboot_fs is not None and not require_default and not require_save_slots:
        raise PersistenceProofError(
            "reboot image comparison requires --require-default or --require-save-slot"
        )
    if reboot_fs is not None and baseline_fs is None:
        raise PersistenceProofError(
            "reboot image comparison requires --baseline-image so survived bytes are also proven to be Doom-written"
        )
    if reboot_status_path is not None and reboot_fs is None:
        raise PersistenceProofError("--reboot-status requires --reboot-baseline-image")
    if write_status_path is not None and not require_default:
        raise PersistenceProofError("--write-status requires --require-default")
    if save_write_status_path is not None and not require_save_slots:
        raise PersistenceProofError("--save-write-status requires --require-save-slot")
    if save_write_status_path is not None and len(require_save_slots) != 1:
        raise PersistenceProofError("--save-write-status requires exactly one --require-save-slot")
    if load_status_path is not None and len(require_save_slots) != 1:
        raise PersistenceProofError("--load-status requires exactly one --require-save-slot")
    if load_status_path is not None and reboot_fs is None:
        raise PersistenceProofError("--load-status requires --reboot-baseline-image")
    unknown_description_slots = sorted(set(require_save_descriptions) - set(require_save_slots))
    if unknown_description_slots:
        joined = ", ".join(str(slot) for slot in unknown_description_slots)
        raise PersistenceProofError(
            "--require-save-description requires matching --require-save-slot "
            f"for slot(s): {joined}"
        )
    if reboot_fs is not None and require_save_slots and save_write_status_path is None:
        raise PersistenceProofError(
            "save-slot reboot proof requires --save-write-status from the write boot"
        )

    _validate_fat_layout(fs)
    if baseline_fs is not None:
        _validate_fat_layout(baseline_fs)
    if reboot_fs is not None:
        _validate_fat_layout(reboot_fs)
    _validate_protected_entries(fs, baseline_fs)
    if reboot_fs is not None:
        _validate_protected_entries(reboot_fs, baseline_fs)
    _require_entry(fs, make_wad_image.WRITABLE_DEFAULT_NAME)
    for name in make_wad_image.WRITABLE_SAVE_NAMES:
        _require_entry(fs, name)

    if require_dynamic_fat_proof:
        proof = _validate_dynamic_fat_proof(image)
        summary.append(
            "dynamic FAT allocation/free/truncate proof=OK "
            f"scratch={proof['proof_name']} "
            f"clusters={proof['initial_clusters']}/{proof['grown_clusters']}/{proof['shrunk_clusters']} "
            f"free={proof['free_clusters']} "
            "remount=OK"
        )

    write_status_ok = False
    if write_status_path is not None:
        validate_default_write_status(Path(write_status_path).read_text())
        write_status_ok = True
    save_write_status_ok = False
    save_write_status_text = None
    if save_write_status_path is not None:
        save_write_status_text = Path(save_write_status_path).read_text()
        validate_save_write_status(
            save_write_status_text,
            expected_slot=require_save_slots[0],
        )
        save_write_status_ok = True
    load_status_text = Path(load_status_path).read_text() if load_status_path is not None else None

    if require_default:
        default_size = _validate_default(fs)
        _require_changed(
            fs,
            baseline_fs,
            make_wad_image.WRITABLE_DEFAULT_NAME,
            "DEFAULT.CFG",
        )
        _require_reboot_survived(
            fs,
            reboot_fs,
            make_wad_image.WRITABLE_DEFAULT_NAME,
            "DEFAULT.CFG",
        )
        suffix = " changed-from-baseline" if baseline_fs is not None else ""
        if reboot_fs is not None:
            suffix += " survived-reboot"
        summary.append(f"DEFAULT.CFG bytes={default_size}{suffix}")

    save_slot_infos = {}
    for slot in require_save_slots:
        stream_status_text = load_status_text or save_write_status_text
        try:
            (
                size,
                description,
                version,
                skill,
                episode,
                game_map,
                leveltime,
                stream_summaries,
            ) = (
                _validate_save_slot(
                    fs,
                    slot,
                    thinker_offset=save_thinker_offset,
                    specials_offset=save_specials_offset,
                    stream_status=stream_status_text,
                )
            )
        except PersistenceProofError as exc:
            diagnostics = _format_save_slot_diagnostics(fs, slot, save_write_status_text)
            raise PersistenceProofError(f"{exc}; {diagnostics}") from exc
        if slot in require_save_descriptions:
            _validate_expected_save_description(slot, description, require_save_descriptions[slot])
        save_slot_infos[slot] = {
            "size": size,
            "description": description,
            "version": version,
            "skill": skill,
            "episode": episode,
            "game_map": game_map,
            "leveltime": leveltime,
            "stream_summaries": stream_summaries,
        }
        if save_write_status_text is not None:
            _require_save_write_covers_payload(
                save_write_status_text,
                slot=slot,
                save_size=size,
            )
        _require_fresh_save_baseline(
            baseline_fs,
            make_wad_image.WRITABLE_SAVE_NAMES[slot],
            f"DOOMSAV{slot}.DSG",
        )
        _require_changed(
            fs,
            baseline_fs,
            make_wad_image.WRITABLE_SAVE_NAMES[slot],
            f"DOOMSAV{slot}.DSG",
        )
        _require_reboot_survived(
            fs,
            reboot_fs,
            make_wad_image.WRITABLE_SAVE_NAMES[slot],
            f"DOOMSAV{slot}.DSG",
        )
        suffix = " changed-from-baseline" if baseline_fs is not None else ""
        if reboot_fs is not None:
            suffix += " survived-reboot"
        summary.append(
            f"DOOMSAV{slot}.DSG bytes={size}{suffix} "
            f"description={description!r} version={version!r} leveltime={leveltime}"
        )
        summary.extend(
            f"DOOMSAV{slot}.DSG {stream_summary}"
            for stream_summary in stream_summaries
        )

    if reboot_status_path is not None:
        validate_reboot_status(Path(reboot_status_path).read_text())
        summary.append("reboot status runtime=OK")
    if load_status_path is not None:
        slot = require_save_slots[0]
        info = save_slot_infos[slot]
        validate_save_load_status(
            load_status_text,
            slot=slot,
            save_size=info["size"],
            episode=info["episode"],
            game_map=info["game_map"],
            leveltime=info["leveltime"],
        )
        validate_save_load_stream_status(load_status_text, slot=slot)
        summary.append(f"save load status gameplay=OK slot={slot}")
    if write_status_ok:
        summary.append("default write status closed=OK")
    if save_write_status_ok:
        summary.append("save write status closed=OK")

    if not summary:
        summary.append("persistence entries present")
    return summary


def parse_args():
    parser = argparse.ArgumentParser(
        description="Check Doom DEFAULT.CFG / DOOMSAV*.DSG persistence in a vibe-os disk image."
    )
    parser.add_argument("image", help="path to a vibe-os FAT16 disk image")
    parser.add_argument(
        "--require-default",
        action="store_true",
        help="require DEFAULT.CFG to contain Doom defaults text",
    )
    parser.add_argument(
        "--baseline-image",
        help="fresh image copied before the remote boot; requested entries must differ from it",
    )
    parser.add_argument(
        "--reboot-baseline-image",
        help="image copied after the write boot; requested entries must match it after reboot",
    )
    parser.add_argument(
        "--reboot-status",
        help="decoded status.txt captured from the reboot boot; Doom runtime/fault gates must pass",
    )
    parser.add_argument(
        "--write-status",
        help="decoded status.txt captured from the default-writing boot; Doom must have closed O_TRUNC defaults output",
    )
    parser.add_argument(
        "--save-write-status",
        help="decoded status.txt captured from the save-writing boot; Doom must have written and closed an O_TRUNC save file",
    )
    parser.add_argument(
        "--load-status",
        help="decoded status.txt captured after the reboot/load boot; Doom must read the full DOOMSAV payload and return to gameplay",
    )
    parser.add_argument(
        "--require-save-slot",
        action="append",
        type=int,
        default=[],
        metavar="N",
        help="require DOOMSAVN.DSG to contain a Doom save header; may be repeated",
    )
    parser.add_argument(
        "--require-save-description",
        action="append",
        default=[],
        metavar="N=TEXT",
        help="require DOOMSAVN.DSG to contain exactly TEXT as its decoded save description",
    )
    parser.add_argument(
        "--require-dynamic-fat-proof",
        action="store_true",
        help="mutate an in-memory copy to prove dynamic FAT create/grow/shrink/truncate/delete behavior",
    )
    parser.add_argument(
        "--save-thinker-offset",
        help="byte offset inside DOOMSAVN.DSG where Doom's thinker class stream starts; accepts decimal or 0x-prefixed hex",
    )
    parser.add_argument(
        "--save-specials-offset",
        help="byte offset inside DOOMSAVN.DSG where Doom's specials class stream starts; accepts decimal or 0x-prefixed hex",
    )
    return parser.parse_args()


def parse_required_save_descriptions(values):
    descriptions = {}
    for value in values:
        if "=" not in value:
            raise SystemExit(
                "--require-save-description must be SLOT=TEXT, for example 0=VIBE-SLOT-0"
            )
        slot_text, description = value.split("=", 1)
        try:
            slot = int(slot_text, 10)
        except ValueError:
            raise SystemExit(
                f"--require-save-description slot must be an integer, got {slot_text!r}"
            ) from None
        if slot in descriptions:
            raise SystemExit(f"duplicate --require-save-description for slot {slot}")
        descriptions[slot] = description
    return descriptions


def main():
    args = parse_args()
    for line in validate_image(
        args.image,
        baseline_image=args.baseline_image,
        reboot_baseline_image=args.reboot_baseline_image,
        reboot_status_path=args.reboot_status,
        write_status_path=args.write_status,
        save_write_status_path=args.save_write_status,
        load_status_path=args.load_status,
        require_default=args.require_default,
        require_save_slots=args.require_save_slot,
        require_save_descriptions=parse_required_save_descriptions(
            args.require_save_description
        ),
        require_dynamic_fat_proof=args.require_dynamic_fat_proof,
        save_thinker_offset=(
            _parse_save_stream_offset(args.save_thinker_offset, "--save-thinker-offset")
            if args.save_thinker_offset is not None
            else None
        ),
        save_specials_offset=(
            _parse_save_stream_offset(args.save_specials_offset, "--save-specials-offset")
            if args.save_specials_offset is not None
            else None
        ),
    ):
        print(line)


if __name__ == "__main__":
    try:
        main()
    except PersistenceProofError as exc:
        raise SystemExit(f"persistence proof failed: {exc}") from None
