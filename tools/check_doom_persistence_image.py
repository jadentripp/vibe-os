#!/usr/bin/env python3
"""Validate Doom config/save persistence inside a vibe-os FAT16 disk image.

This tool is intended for remote/cloud runs after Doom has written to the
image. It inspects only FAT metadata and the DEFAULT.CFG / DOOMSAV*.DSG bytes;
it does not print or export WAD contents, rendered pixels, or disk images.
"""

import argparse
import importlib.util
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


def _validate_protected_entries(fs):
    for name in make_wad_image.PROTECTED_ROOT_NAMES:
        meta = _require_entry(fs, name)
        if not meta["protected"]:
            raise PersistenceProofError(f"{name!r} is not marked protected by the image parser")
        if meta["size"] <= 0 or meta["cluster"] < 2:
            raise PersistenceProofError(f"{name!r} does not point at persisted file data")


def _validate_default(fs):
    meta = _require_entry(fs, make_wad_image.WRITABLE_DEFAULT_NAME)
    data = fs.read_root_file(make_wad_image.WRITABLE_DEFAULT_NAME)
    if meta["size"] != len(data):
        raise PersistenceProofError("DEFAULT.CFG metadata size does not match readable bytes")
    if not data:
        raise PersistenceProofError("DEFAULT.CFG is still empty")
    if not any(marker in data for marker in DEFAULT_MARKERS):
        raise PersistenceProofError("DEFAULT.CFG does not look like Doom defaults text")
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
    if len(data) < minimum:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG is too small for a Doom save header")

    description = _trim_c_string(data[:SAVE_DESCRIPTION_BYTES])
    version = _trim_c_string(data[SAVE_DESCRIPTION_BYTES:minimum])
    if not description:
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG has an empty save description")
    if not version.startswith(b"version "):
        raise PersistenceProofError(f"DOOMSAV{slot}.DSG is missing the Doom version marker")
    return len(data), description.decode("ascii", "replace"), version.decode("ascii", "replace")


def validate_image(path, *, require_default=False, require_save_slots=()):
    fs = make_wad_image.Fat16Image(_read_image(path))
    summary = []

    _validate_protected_entries(fs)
    _require_entry(fs, make_wad_image.WRITABLE_DEFAULT_NAME)
    for name in make_wad_image.WRITABLE_SAVE_NAMES:
        _require_entry(fs, name)

    if require_default:
        summary.append(f"DEFAULT.CFG bytes={_validate_default(fs)}")

    for slot in require_save_slots:
        size, description, version = _validate_save_slot(fs, slot)
        summary.append(
            f"DOOMSAV{slot}.DSG bytes={size} description={description!r} version={version!r}"
        )

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
        "--require-save-slot",
        action="append",
        type=int,
        default=[],
        metavar="N",
        help="require DOOMSAVN.DSG to contain a Doom save header; may be repeated",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    for line in validate_image(
        args.image,
        require_default=args.require_default,
        require_save_slots=args.require_save_slot,
    ):
        print(line)


if __name__ == "__main__":
    try:
        main()
    except PersistenceProofError as exc:
        raise SystemExit(f"persistence proof failed: {exc}") from None
