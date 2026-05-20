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
MIN_SAVE_BYTES = 512
SAVE_HEADER_BYTES = SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES + 7
REQUIRED_DOOM_INIT_FLAGS = 0x000001FF
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
    "doomrun": "EXIT",
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

spec = importlib.util.spec_from_file_location("make_wad_image", MAKE_WAD_IMAGE)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)


class PersistenceProofError(AssertionError):
    pass


def _trim_c_string(raw):
    return raw.split(b"\0", 1)[0].strip()


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
        raise PersistenceProofError("DEFAULT.CFG is not newline-terminated")
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


def _validate_save_slot(fs, slot):
    if slot < 0 or slot >= len(make_wad_image.WRITABLE_SAVE_NAMES):
        raise PersistenceProofError(f"save slot {slot} is outside DOOMSAV0.DSG..DOOMSAV5.DSG")

    name = make_wad_image.WRITABLE_SAVE_NAMES[slot]
    meta = _require_entry(fs, name)
    data = fs.read_root_file(name)
    minimum = SAVE_DESCRIPTION_BYTES + SAVE_VERSION_BYTES
    if meta["size"] != len(data):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG metadata size does not match readable bytes")
    if len(data) > make_wad_image.WRITABLE_SAVE_BYTES:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG exceeds the configured Doom save capacity")
    if len(data) < minimum:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG is too small for a Doom save header")
    if len(data) < MIN_SAVE_BYTES:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG is too small for a real Doom save payload")

    description = _trim_c_string(data[:SAVE_DESCRIPTION_BYTES])
    version = _trim_c_string(data[SAVE_DESCRIPTION_BYTES:minimum])
    if not description:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has an empty save description")
    if any(ch < 0x20 or ch > 0x7E for ch in description):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has a non-printable save description")
    if version != EXPECTED_SAVE_VERSION:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has unexpected Doom version {version!r}")
    skill = data[minimum]
    episode = data[minimum + 1]
    game_map = data[minimum + 2]
    player_flags = data[minimum + 3:minimum + 7]
    if skill > 4:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has an invalid skill byte")
    if not (1 <= episode <= 4 and 1 <= game_map <= 9):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has an invalid episode/map header")
    if not player_flags[0]:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG does not mark player 1 active")
    if not any(player_flags):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has no active player flags")
    if not any(data[SAVE_HEADER_BYTES:]):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG does not contain serialized game-state bytes")
    return len(data), description.decode("ascii", "replace"), version.decode("ascii", "replace")


def _require_changed(fs, baseline_fs, name, label):
    if baseline_fs is None:
        return
    current = fs.read_root_file(name)
    baseline = baseline_fs.read_root_file(name)
    if current == baseline:
        raise PersistenceProofError(f"{label} did not change from baseline image")


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
    if close_count == 0:
        raise PersistenceProofError("default write status doomclose= must prove file close")

    flags, _mode = _status_hex_tuple_field(fields, "doommode", 2, separator=":")
    if flags != DEFAULT_WRITE_REQUIRED_OPEN_FLAGS:
        raise PersistenceProofError(
            "default write status doommode= must prove DEFAULT.CFG was opened "
            f"O_WRONLY|O_CREAT|O_TRUNC, got {flags:#x}"
        )

    if any(_status_hex_tuple_field(fields, "fault", 11)):
        raise PersistenceProofError("default write status fault= must be all zero")


def validate_image(
    path,
    *,
    baseline_image=None,
    reboot_baseline_image=None,
    reboot_status_path=None,
    write_status_path=None,
    require_default=False,
    require_save_slots=(),
    require_dynamic_fat_proof=False,
):
    image = _read_image(path)
    fs = make_wad_image.Fat16Image(image)
    baseline_fs = make_wad_image.Fat16Image(_read_image(baseline_image)) if baseline_image else None
    reboot_fs = (
        make_wad_image.Fat16Image(_read_image(reboot_baseline_image))
        if reboot_baseline_image
        else None
    )
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
            f"free={proof['free_clusters']}"
        )

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

    for slot in require_save_slots:
        size, description, version = _validate_save_slot(fs, slot)
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
            f"DOOMSAV{slot}.DSG bytes={size}{suffix} description={description!r} version={version!r}"
        )

    if reboot_status_path is not None:
        validate_reboot_status(Path(reboot_status_path).read_text())
        summary.append("reboot status runtime=OK")
    if write_status_path is not None:
        validate_default_write_status(Path(write_status_path).read_text())
        summary.append("default write status exited=OK")

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
        help="decoded status.txt captured from the default-writing boot; Doom must have exited cleanly after O_TRUNC defaults output",
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
        "--require-dynamic-fat-proof",
        action="store_true",
        help="mutate an in-memory copy to prove dynamic FAT create/grow/shrink/truncate/delete behavior",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    for line in validate_image(
        args.image,
        baseline_image=args.baseline_image,
        reboot_baseline_image=args.reboot_baseline_image,
        reboot_status_path=args.reboot_status,
        write_status_path=args.write_status,
        require_default=args.require_default,
        require_save_slots=args.require_save_slot,
        require_dynamic_fat_proof=args.require_dynamic_fat_proof,
    ):
        print(line)


if __name__ == "__main__":
    try:
        main()
    except PersistenceProofError as exc:
        raise SystemExit(f"persistence proof failed: {exc}") from None
