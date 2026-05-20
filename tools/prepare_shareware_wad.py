#!/usr/bin/env python3
"""Fetch/extract/validate the shareware DOOM1.WAD without touching the repo."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import io
import sys
import urllib.request
import zipfile
from pathlib import Path


EXPECTED_SHAREWARE_SHA1 = "5b2e249b9c5133ec987b3ea77596381dc0d6bc1d"
EXPECTED_SHAREWARE_BYTES = 4196020


def _read_source(source: Path | None, url: str | None) -> bytes:
    if source is not None and url is not None:
        raise AssertionError("use either --source or --url, not both")
    if source is None and url is None:
        raise AssertionError("one of --source or --url is required")
    if source is not None:
        return source.read_bytes()
    with urllib.request.urlopen(url, timeout=60) as response:
        return response.read()


def extract_wad(raw: bytes) -> bytes:
    if raw[:2] == b"\x1f\x8b":
        return gzip.decompress(raw)
    if raw[:4] == b"PK\x03\x04":
        with zipfile.ZipFile(io.BytesIO(raw)) as archive:
            matches = [
                name for name in archive.namelist()
                if Path(name).name.upper() == "DOOM1.WAD"
            ]
            if not matches:
                raise AssertionError("zip archive does not contain DOOM1.WAD")
            return archive.read(matches[0])
    if raw[:4] in (b"IWAD", b"PWAD"):
        return raw
    raise AssertionError("source is not a WAD, gzip-compressed WAD, or zip containing DOOM1.WAD")


def validate_wad(data: bytes, expected_sha1: str, expected_bytes: int) -> None:
    if data[:4] != b"IWAD":
        raise AssertionError("extracted DOOM1.WAD is not an IWAD")
    actual_size = len(data)
    actual_sha1 = hashlib.sha1(data).hexdigest()
    if actual_size != expected_bytes:
        raise AssertionError(
            f"DOOM1.WAD size mismatch: got {actual_size}, expected {expected_bytes}"
        )
    if actual_sha1 != expected_sha1:
        raise AssertionError(
            f"DOOM1.WAD SHA-1 mismatch: got {actual_sha1}, expected {expected_sha1}"
        )


def prepare_wad(
    output: Path,
    source: Path | None,
    url: str | None,
    expected_sha1: str,
    expected_bytes: int,
) -> None:
    data = extract_wad(_read_source(source, url))
    validate_wad(data, expected_sha1, expected_bytes)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(data)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, help="local WAD, WAD.gz, or zip source")
    parser.add_argument("--url", help="remote WAD, WAD.gz, or zip URL")
    parser.add_argument("--output", type=Path, required=True, help="output path for validated DOOM1.WAD")
    parser.add_argument("--expected-sha1", default=EXPECTED_SHAREWARE_SHA1)
    parser.add_argument("--expected-bytes", type=int, default=EXPECTED_SHAREWARE_BYTES)
    args = parser.parse_args(argv)

    try:
        prepare_wad(
            args.output,
            args.source,
            args.url,
            args.expected_sha1.lower(),
            args.expected_bytes,
        )
    except (OSError, AssertionError, zipfile.BadZipFile, gzip.BadGzipFile) as exc:
        print(f"prepare shareware WAD failed: {exc}", file=sys.stderr)
        return 1

    data = args.output.read_bytes()
    print(
        "Validated shareware DOOM1.WAD: "
        f"{len(data)} bytes, SHA-1 {hashlib.sha1(data).hexdigest()}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
