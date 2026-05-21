#!/usr/bin/env python3
"""Shared parser helpers for vibe-os status/proof key-value fields."""

from __future__ import annotations

import re
from collections.abc import Iterable


FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
HEX8_PATTERN = re.compile(r"[0-9A-Fa-f]{8}")


def parse_status_fields(
    text: str,
    *,
    error_type: type[Exception] = ValueError,
    require_any: bool = True,
) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(text):
        name = match.group(1)
        if name in fields:
            raise error_type(f"duplicate {name}= field")
        fields[name] = match.group(2)
    if require_any and not fields:
        raise error_type("no key=value status fields found")
    return fields


def require_status_field(
    fields: dict[str, str],
    name: str,
    *,
    error_type: type[Exception] = AssertionError,
) -> str:
    value = fields.get(name)
    if value is None:
        raise error_type(f"status missing {name}= field")
    return value


def parse_hex8(value: str) -> int | None:
    if not HEX8_PATTERN.fullmatch(value):
        return None
    return int(value, 16)


def hex8_field(fields: dict[str, str], name: str) -> int | None:
    value = fields.get(name)
    if value is None:
        return None
    return parse_hex8(value)


def require_hex8_field(
    fields: dict[str, str],
    name: str,
    *,
    error_type: type[Exception] = AssertionError,
) -> int:
    value = require_status_field(fields, name, error_type=error_type)
    parsed = parse_hex8(value)
    if parsed is None:
        raise error_type(f"{name}= must be an 8-digit hexadecimal value, got {value!r}")
    return parsed


def parse_hex_tuple(value: str, count: int, sep: str = "/") -> tuple[int, ...] | None:
    parts = value.split(sep)
    if len(parts) != count:
        return None
    parsed: list[int] = []
    for part in parts:
        item = parse_hex8(part)
        if item is None:
            return None
        parsed.append(item)
    return tuple(parsed)


def hex_tuple_field(
    fields: dict[str, str],
    name: str,
    count: int,
    sep: str = "/",
) -> tuple[int, ...] | None:
    value = fields.get(name)
    if value is None:
        return None
    return parse_hex_tuple(value, count, sep)


def require_hex_tuple_field(
    fields: dict[str, str],
    name: str,
    count: int,
    sep: str = "/",
    *,
    error_type: type[Exception] = AssertionError,
) -> tuple[int, ...]:
    value = require_status_field(fields, name, error_type=error_type)
    parsed = parse_hex_tuple(value, count, sep)
    if parsed is None:
        raise error_type(f"{name}= must contain {count} hex fields separated by {sep!r}")
    return parsed


def summarize_status_fields(fields: dict[str, str], names: Iterable[str]) -> str:
    return " ".join(f"{name}={fields.get(name, '<missing>')}" for name in names)
