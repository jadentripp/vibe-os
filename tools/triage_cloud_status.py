#!/usr/bin/env python3
"""Classify the next real-WAD cloud status line into a repair lane."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
SUMMARY_FIELDS = (
    "exec",
    "path",
    "execsys",
    "target",
    "argv0",
    "doom",
    "doomrun",
    "doomopen",
    "doomread",
    "doomerr",
    "doomexit",
    "doomfault",
    "doomfaultip",
    "doomfaultv",
    "doomfaulterr",
    "fault",
    "panic",
    "shutdown",
    "gameplay",
    "gstate",
    "gmap",
    "gtic",
    "leveltime",
    "doompresent",
    "doompal",
    "doomframe",
    "pflags",
    "gflags",
    "pdelta",
    "keyirq",
    "keyqueue",
    "keypoll",
    "gfx",
    "usr",
    "wad",
    "lmp",
    "heap",
    "free",
    "ticks",
)
EXECSYS_NAMES = (
    "attempts",
    "successes",
    "failures",
    "handoffs",
    "scheduled",
    "rollbacks",
)


@dataclass(frozen=True)
class TriageRule:
    name: str
    fields: tuple[str, ...]
    meaning: str
    next_step: str


TRIAGE_RULES = (
    TriageRule(
        "exec-not-attempted",
        ("execsys", "target", "argv0", "doomrun"),
        "The probe never attempted the syscall exec handoff into DOOM.ELF.",
        "Inspect the user-probe completion path and the expected-fault recovery into SYS_EXEC.",
    ),
    TriageRule(
        "exec-failed",
        ("exec", "path", "execsys", "target", "argv0", "doom"),
        "The kernel attempted exec, but lookup, ELF loading, argv seeding, or handoff failed.",
        "Read the six execsys counters, then inspect process_exec_path/process_exec_handoff_current.",
    ),
    TriageRule(
        "doom-user-fault",
        ("doomrun", "doomfault", "doomfaultip", "doomfaultv", "doomfaulterr", "fault"),
        "Doom entered user mode and faulted before the proof completed.",
        "Symbolize doomfaultip against build/doom.elf and decode the vector/error/CR2 fields.",
    ),
    TriageRule(
        "missing-wad-open-read",
        ("doomopen", "doomread", "doomerr", "doommode", "doomlog", "wad", "lmp"),
        "Doom did not successfully open/read the WAD through the libc/syscall/FAT path.",
        "If Doom also faulted, fix the fault first; otherwise inspect path mapping and FAT read/lseek.",
    ),
    TriageRule(
        "frames-no-gameplay",
        ("doompresent", "doompal", "doomframe", "gameplay", "gstate", "gmap", "leveltime"),
        "Frames or palette updates happened, but Doom did not prove E1M1 gameplay.",
        "Inspect Doom startup log/state: it may be rendering a title/error/menu path rather than GS_LEVEL.",
    ),
    TriageRule(
        "input-no-effect",
        ("keyirq", "keyqueue", "keypoll", "pflags", "pdelta", "gflags"),
        "Keyboard events reached the OS, but scripted fire/move/use/menu effects were not observed.",
        "Compare early/fire/move/use/menu snapshots and inspect PS/2 translation plus Doom event injection.",
    ),
    TriageRule(
        "kernel-panic",
        ("panic", "fault"),
        "The kernel recorded an unhandled non-Doom exception before halting.",
        "Decode fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall, then inspect the matching kernel path.",
    ),
    TriageRule(
        "os-shutdown-requested",
        ("shutdown", "panic", "fault"),
        "The OS recorded a halt or reboot request in the status block.",
        "Verify this came from an intentional shutdown/reboot proof lane before treating QEMU exit as a failure.",
    ),
    TriageRule(
        "artifact-proof-failure",
        ("status.early.txt", "status.after-*.txt", "kernel.elf", "user_probe.elf", "doom.elf"),
        "The cloud artifact package failed even if the final status line looked plausible.",
        "Run check_cloud_playability_artifacts.py; look for missing snapshots, duplicate basenames, or forbidden payloads.",
    ),
    TriageRule(
        "playability-status-green",
        ("doomrun", "gameplay", "doompresent", "pflags", "gflags"),
        "The final status has no obvious local triage failure.",
        "Run the real-WAD, human-playability, and cloud artifact checkers before claiming playable Doom.",
    ),
)


def parse_status(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise ValueError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    if not fields:
        raise ValueError("no key=value status fields found")
    return fields


def _field(fields: dict[str, str], name: str) -> str:
    return fields.get(name, "<missing>")


def _hex(fields: dict[str, str], name: str) -> int | None:
    value = fields.get(name)
    if value is None or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        return None
    return int(value, 16)


def _hex_nonzero(fields: dict[str, str], *names: str) -> bool:
    return any((_hex(fields, name) or 0) != 0 for name in names)


def _execsys(fields: dict[str, str]) -> tuple[int, ...] | None:
    value = fields.get("execsys")
    if value is None:
        return None
    parts = value.split("/")
    if len(parts) != len(EXECSYS_NAMES):
        return None
    parsed: list[int] = []
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            return None
        parsed.append(int(part, 16))
    return tuple(parsed)


def summarize(fields: dict[str, str]) -> str:
    return " ".join(f"{name}={fields.get(name, '<missing>')}" for name in SUMMARY_FIELDS)


def classify(fields: dict[str, str]) -> tuple[str, list[str]]:
    notes: list[str] = []
    execsys = _execsys(fields)
    doomrun = fields.get("doomrun")
    panic = fields.get("panic")
    shutdown = fields.get("shutdown")

    if panic not in (None, "NONE"):
        notes.append(f"kernel-panic: panic={panic} fault={_field(fields, 'fault')}")
        return "kernel-panic", notes

    if shutdown not in (None, "NONE"):
        notes.append(f"os-shutdown-requested: shutdown={shutdown} panic={_field(fields, 'panic')}")
        return "os-shutdown-requested", notes

    if execsys is None:
        notes.append("exec-failed: execsys is missing or malformed")
        return "exec-failed", notes

    attempts, successes, failures, handoffs, scheduled, rollbacks = execsys
    execsys_detail = ", ".join(
        f"{name}={value:#x}" for name, value in zip(EXECSYS_NAMES, execsys)
    )

    if attempts == 0:
        notes.append(
            "exec-not-attempted: "
            f"{execsys_detail}; target={_field(fields, 'target')} argv0={_field(fields, 'argv0')}"
        )
        return "exec-not-attempted", notes

    if (
        fields.get("exec") != "OK"
        or fields.get("path") != "DOOM.ELF"
        or fields.get("doom") != "OK"
        or successes == 0
        or handoffs == 0
        or scheduled == 0
        or failures != 0
        or rollbacks != 0
        or _hex(fields, "target") in (None, 0, 0xFFFFFFFF)
        or _hex(fields, "argv0") in (None, 0, 0xFFFFFFFF)
    ):
        notes.append(
            "exec-failed: "
            f"exec={_field(fields, 'exec')} path={_field(fields, 'path')} "
            f"doom={_field(fields, 'doom')} {execsys_detail} "
            f"target={_field(fields, 'target')} argv0={_field(fields, 'argv0')}"
        )
        return "exec-failed", notes

    if doomrun == "FAULT" or _hex_nonzero(
        fields, "doomfault", "doomfaultip", "doomfaultv", "doomfaulterr"
    ):
        notes.append(
            "doom-user-fault: "
            f"doomfault(CR2)={_field(fields, 'doomfault')} "
            f"doomfaultip(EIP)={_field(fields, 'doomfaultip')} "
            f"doomfaultv(vector)={_field(fields, 'doomfaultv')} "
            f"doomfaulterr={_field(fields, 'doomfaulterr')} "
            f"fault={_field(fields, 'fault')}"
        )
        if fields.get("doomopen") != "OK" or fields.get("doomread") != "OK":
            notes.append(
                "missing-wad-open-read: WAD open/read did not complete, but the Doom fault is earlier priority"
            )
        return "doom-user-fault", notes

    if doomrun == "EXIT" or (_hex(fields, "doomexit") or 0) != 0:
        notes.append(
            "doom-user-exit: "
            f"doomrun={_field(fields, 'doomrun')} doomexit={_field(fields, 'doomexit')}"
        )
        return "doom-user-exit", notes

    if fields.get("doomopen") != "OK" or fields.get("doomread") != "OK" or (
        _hex(fields, "doomerr") or 0
    ) != 0:
        notes.append(
            "missing-wad-open-read: "
            f"doomopen={_field(fields, 'doomopen')} doomread={_field(fields, 'doomread')} "
            f"doomerr={_field(fields, 'doomerr')} doommode={_field(fields, 'doommode')} "
            f"doomlog={_field(fields, 'doomlog')}"
        )
        return "missing-wad-open-read", notes

    if doomrun != "RUN":
        notes.append(f"doom-not-running: doomrun={_field(fields, 'doomrun')}")
        return "doom-not-running", notes

    has_frames = _hex_nonzero(fields, "doompresent", "doompal", "doomframe")
    if has_frames and (
        fields.get("gameplay") != "OK"
        or fields.get("gstate") != "00000000"
        or fields.get("gmap") != "00000101"
        or (_hex(fields, "leveltime") or 0) == 0
    ):
        notes.append(
            "frames-no-gameplay: "
            f"doompresent={_field(fields, 'doompresent')} doompal={_field(fields, 'doompal')} "
            f"doomframe={_field(fields, 'doomframe')} gameplay={_field(fields, 'gameplay')} "
            f"gstate={_field(fields, 'gstate')} gmap={_field(fields, 'gmap')} "
            f"leveltime={_field(fields, 'leveltime')}"
        )
        return "frames-no-gameplay", notes

    if (
        (_hex(fields, "keyirq") or 0) == 0
        or (_hex(fields, "keyqueue") or 0) == 0
        or (_hex(fields, "keypoll") or 0) == 0
        or (_hex(fields, "pdelta") or 0) == 0
    ):
        notes.append(
            "input-no-effect: "
            f"keyirq={_field(fields, 'keyirq')} keyqueue={_field(fields, 'keyqueue')} "
            f"keypoll={_field(fields, 'keypoll')} pflags={_field(fields, 'pflags')} "
            f"pdelta={_field(fields, 'pdelta')} gflags={_field(fields, 'gflags')}"
        )
        return "input-no-effect", notes

    notes.append("playability-status-green: final status has no obvious first-failure field")
    return "playability-status-green", notes


def render_diagnosis(status: str) -> str:
    fields = parse_status(status)
    primary, notes = classify(fields)
    rule = next((candidate for candidate in TRIAGE_RULES if candidate.name == primary), None)
    lines = [
        f"primary: {primary}",
        f"summary: {summarize(fields)}",
    ]
    lines.extend(f"- {note}" for note in notes)
    if rule is not None:
        lines.append(f"next: {rule.next_step}")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "status",
        help="status file path, or '-' to read a raw status line from stdin",
    )
    args = parser.parse_args(argv)

    try:
        if args.status == "-":
            status = sys.stdin.read()
        else:
            status = Path(args.status).read_text()
        print(render_diagnosis(status))
    except (OSError, ValueError) as exc:
        print(f"cloud status triage failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
