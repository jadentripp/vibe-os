#!/usr/bin/env python3
"""Validate the non-pixel status proof from the real-WAD smoke run."""

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


def _field(status: str, name: str) -> str:
    match = re.search(rf"(?:^|\s){re.escape(name)}=([^\s]+)", status)
    if not match:
        raise AssertionError(f"missing {name}= field")
    return match.group(1)


def _hex_field_gt(status: str, name: str, minimum: int) -> int:
    value = _field(status, name)
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be eight hex digits, got {value!r}")
    parsed = int(value, 16)
    if parsed <= minimum:
        raise AssertionError(f"{name}= must be greater than {minimum:#x}, got {parsed:#x}")
    return parsed


def validate_status(status: str, reject_patterns: tuple[str, ...] = DEFAULT_REJECT_PATTERNS) -> None:
    if _field(status, "gameplay") != "OK":
        raise AssertionError("gameplay=OK is required")

    gmap = _field(status, "gmap")
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", gmap):
        raise AssertionError(f"gmap= must be eight hex digits, got {gmap!r}")
    if int(gmap, 16) != 0x00000101:
        raise AssertionError(f"gmap= must be E1M1 (00000101), got {gmap}")

    _hex_field_gt(status, "leveltime", 0)
    _hex_field_gt(status, "doompresent", 0)

    for pattern in reject_patterns:
        if re.search(pattern, status, re.IGNORECASE):
            raise AssertionError(f"rejected Doom error string matched: {pattern}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("status", type=Path, help="Decoded build/status.txt from real-WAD smoke")
    args = parser.parse_args(argv)

    try:
        status = args.status.read_text()
        validate_status(status)
    except (OSError, AssertionError) as exc:
        print(f"real-WAD proof failed: {exc}", file=sys.stderr)
        return 1

    print("real-WAD proof OK: gameplay=OK gmap=E1M1 leveltime>0 doompresent>0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
