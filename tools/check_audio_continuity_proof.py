#!/usr/bin/env python3
"""Validate remote-safe SB16 audio continuity from smoke status snapshots."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
MAKEFILE = ROOT / "Makefile"
AUDIO_DOC = ROOT / "docs" / "audio.md"
MUSIC_DOC = ROOT / "docs" / "doom-music.md"
PLAYABLE_DOC = ROOT / "docs" / "playable-cloud-proof.md"
RUNBOOK = ROOT / "docs" / "runbooks" / "remote-doom-playtest.md"
SMOKE_RUNNER = ROOT / "tests" / "run_smoke_qemu.sh"

FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
SNAPSHOT_ORDER = ("baseline", "fire", "movement", "use", "menu", "final")
REQUIRED_AUDIO_FIELDS = (
    "audio",
    "doomsound",
    "sfxmix",
    "voices",
    "sfxvoices",
    "audioirq",
    "ack8",
    "ack16",
    "refill",
    "half",
    "mixwrap",
    "mixover",
    "mixunder",
    "mixclip",
    "steal",
    "pitchclamp",
    "panclamp",
    "musicvoices",
    "musicmix",
    "musicloop",
    "sb16",
    "dma",
    "play",
    "voiceq",
    "musicq",
)
MONOTONIC_COUNTERS = (
    "doomsound",
    "sfxmix",
    "audioirq",
    "ack8",
    "ack16",
    "refill",
    "mixwrap",
    "mixover",
    "mixunder",
    "mixclip",
    "steal",
    "pitchclamp",
    "panclamp",
    "musicmix",
    "musicloop",
    "dma",
)
FINAL_POSITIVE_COUNTERS = (
    "doomsound",
    "sfxmix",
    "audioirq",
    "refill",
    "musicvoices",
    "musicmix",
    "dma",
)
PROGRESS_COUNTERS = ("audioirq", "refill", "sfxmix", "musicmix")
TUPLE_FIELDS = {
    "sb16": 2,
    "play": 2,
    "voiceq": 3,
    "musicq": 2,
}
SUMMARY_FIELDS = (
    "audio",
    "doomsound",
    "sfxmix",
    "voices",
    "sfxvoices",
    "audioirq",
    "ack8",
    "ack16",
    "refill",
    "half",
    "mixwrap",
    "mixover",
    "mixunder",
    "mixclip",
    "steal",
    "pitchclamp",
    "panclamp",
    "musicvoices",
    "musicmix",
    "musicloop",
    "sb16",
    "dma",
    "play",
    "voiceq",
    "musicq",
    "doomrun",
    "doomopen",
    "doomread",
    "gameplay",
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
    try:
        fields = _status_fields(status)
    except AssertionError as exc:
        return f"unparseable status: {exc}"
    return " ".join(f"{name}={fields.get(name, '<missing>')}" for name in SUMMARY_FIELDS)


def _hex(fields: dict[str, str], name: str, label: str) -> int:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"{label} snapshot missing {name}= field")
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{label} {name}= must be eight hex digits, got {value!r}")
    return int(value, 16)


def _hex_tuple(fields: dict[str, str], name: str, label: str, count: int) -> tuple[int, ...]:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"{label} snapshot missing {name}= field")
    parts = value.split(":")
    if len(parts) != count:
        raise AssertionError(f"{label} {name}= must have {count} colon-separated hex parts")
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            raise AssertionError(f"{label} {name}= part must be eight hex digits, got {part!r}")
    return tuple(int(part, 16) for part in parts)


def _parse_labeled(label: str, status: str) -> dict[str, str]:
    fields = _status_fields(status)
    for name in REQUIRED_AUDIO_FIELDS:
        if name not in fields:
            raise AssertionError(f"{label} snapshot missing {name}= field")
    if fields["audio"] not in ("SB16", "NONE"):
        raise AssertionError(f"{label} audio= must be SB16 or NONE, got {fields['audio']!r}")
    for name in REQUIRED_AUDIO_FIELDS:
        if name in TUPLE_FIELDS:
            _hex_tuple(fields, name, label, TUPLE_FIELDS[name])
        elif name != "audio":
            _hex(fields, name, label)
    return fields


def _assert_nondecreasing(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
) -> None:
    previous_label, previous_fields = snapshots[0]
    previous = _hex(previous_fields, name, previous_label)
    for label, fields in snapshots[1:]:
        current = _hex(fields, name, label)
        if current < previous:
            raise AssertionError(
                f"{name}= must be monotonic across snapshots, "
                f"got {previous_label}:{previous:08X} -> {label}:{current:08X}"
            )
        previous_label = label
        previous = current


def _assert_progress(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first = _hex(first_fields, name, first_label)
    last = _hex(last_fields, name, last_label)
    if last <= first:
        raise AssertionError(
            f"{name}= must increase from {first_label} to {last_label}, "
            f"got {first:08X}->{last:08X}"
        )


def _assert_tuple_nondecreasing(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
    count: int,
) -> None:
    previous_label, previous_fields = snapshots[0]
    previous = _hex_tuple(previous_fields, name, previous_label, count)
    for label, fields in snapshots[1:]:
        current = _hex_tuple(fields, name, label, count)
        if any(now < before for now, before in zip(current, previous)):
            raise AssertionError(
                f"{name}= must be monotonic across snapshots, "
                f"got {previous_label}:{previous_fields[name]} -> {label}:{fields[name]}"
            )
        previous_label = label
        previous = current


def validate_status(
    final_status: str,
    baseline_status: str,
    fire_status: str,
    movement_status: str,
    use_status: str,
    menu_status: str,
) -> None:
    """Validate SB16 counter continuity without reading or uploading audio bytes."""

    labeled = {
        "baseline": baseline_status,
        "fire": fire_status,
        "movement": movement_status,
        "use": use_status,
        "menu": menu_status,
        "final": final_status,
    }
    snapshots = [(label, _parse_labeled(label, labeled[label])) for label in SNAPSHOT_ORDER]

    for label, fields in snapshots:
        if fields["audio"] != "SB16":
            raise AssertionError(
                f"{label} audio=SB16 is required for audible/streaming proof, "
                f"got {fields['audio']!r}"
            )

    final_fields = snapshots[-1][1]
    for name in FINAL_POSITIVE_COUNTERS:
        if _hex(final_fields, name, "final") == 0:
            raise AssertionError(f"final {name}= must be nonzero for audio continuity proof")

    if _hex(final_fields, "ack8", "final") == 0 and _hex(final_fields, "ack16", "final") == 0:
        raise AssertionError("final ack8= or ack16= must be nonzero to prove SB16 IRQ ACKs")
    if _hex_tuple(final_fields, "sb16", "final", 2)[0] == 0:
        raise AssertionError("final sb16= must expose a nonzero SB16 DSP major version")
    if _hex_tuple(final_fields, "play", "final", 2)[0] == 0:
        raise AssertionError("final play= must prove SB16 playback was started")
    if _hex_tuple(final_fields, "voiceq", "final", 3)[0] == 0:
        raise AssertionError("final voiceq= must prove at least one audio voice was queued")
    if _hex_tuple(final_fields, "musicq", "final", 2)[0] == 0:
        raise AssertionError("final musicq= must prove the music carrier was queued")

    for name in MONOTONIC_COUNTERS:
        _assert_nondecreasing(snapshots, name)
    for name, count in (("play", 2), ("voiceq", 3), ("musicq", 2)):
        _assert_tuple_nondecreasing(snapshots, name, count)
    for name in PROGRESS_COUNTERS:
        _assert_progress(snapshots, name)


def validate_repo_contract() -> None:
    workflow = WORKFLOW.read_text()
    makefile = MAKEFILE.read_text()
    audio_doc = AUDIO_DOC.read_text()
    music_doc = MUSIC_DOC.read_text()
    playable_doc = PLAYABLE_DOC.read_text()
    runbook = RUNBOOK.read_text()
    smoke_runner = SMOKE_RUNNER.read_text()

    for path, text, needles in (
        (
            WORKFLOW,
            workflow,
            (
                "QEMU_EXTRA_ARGS=\"-audiodev none,id=snd0 -device sb16,audiodev=snd0\"",
                "tools/check_audio_continuity_proof.py",
                "--baseline build/status.after-start.txt",
                "--fire build/status.after-fire.txt",
                "--movement build/status.after-move.txt",
                "--use build/status.after-use.txt",
                "--menu build/status.after-menu.txt",
            ),
        ),
        (
            MAKEFILE,
            makefile,
            (
                "QEMU_EXTRA_ARGS ?=",
                "SMOKE_REQUIRE_AUDIO_CONTINUITY ?= 0",
                "tools/check_audio_continuity_proof.py --repo-contract",
                "SMOKE_REQUIRE_AUDIO_CONTINUITY",
            ),
        ),
        (
            AUDIO_DOC,
            audio_doc,
            (
                "tools/check_audio_continuity_proof.py",
                "audio=SB16",
                "sfxmix= counts non-music Doom SFX only",
                "looped PCM carrier",
                "not full song-position continuity",
            ),
        ),
        (
            MUSIC_DOC,
            music_doc,
            (
                "bounded PCM window",
                "looped PCM carrier",
                "separate from normal Doom SFX",
                "not full song-position streaming",
            ),
        ),
        (
            PLAYABLE_DOC,
            playable_doc,
            (
                "tools/check_audio_continuity_proof.py",
                "status snapshots only",
                "does not upload audio samples",
            ),
        ),
        (
            RUNBOOK,
            runbook,
            (
                "tools/check_audio_continuity_proof.py",
                "-audiodev none,id=snd0 -device sb16,audiodev=snd0",
                "status/counter proof",
            ),
        ),
        (
            SMOKE_RUNNER,
            smoke_runner,
            (
                "QEMU_EXTRA_ARGS",
                '"${qemu_extra_args[@]}"',
            ),
        ),
    ):
        for needle in needles:
            if needle not in text:
                raise AssertionError(f"{path.relative_to(ROOT)} missing {needle!r}")


def _read(path: Path) -> str:
    try:
        return path.read_text()
    except OSError as exc:
        raise AssertionError(f"cannot read {path}: {exc}") from exc


def _auto_snapshot(final_status: Path, label: str) -> Path:
    return final_status.with_name(f"status.{label}.txt")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("status", nargs="?", type=Path, help="Decoded final status.txt")
    parser.add_argument("--baseline", type=Path, help="Decoded post-Doom-start status.after-start.txt")
    parser.add_argument("--fire", type=Path, help="Decoded status.after-fire.txt")
    parser.add_argument("--movement", type=Path, help="Decoded status.after-move.txt")
    parser.add_argument("--use", type=Path, help="Decoded status.after-use.txt")
    parser.add_argument("--menu", type=Path, help="Decoded status.after-menu.txt")
    parser.add_argument("--repo-contract", action="store_true")
    parser.add_argument("--no-auto-snapshots", action="store_true")
    args = parser.parse_args(argv)

    final_status = ""
    try:
        if args.repo_contract:
            validate_repo_contract()
            print("audio continuity repo contract OK")
            return 0

        if args.status is None:
            raise AssertionError("status path is required unless --repo-contract is used")

        baseline = args.baseline
        fire = args.fire
        movement = args.movement
        use = args.use
        menu = args.menu
        if not args.no_auto_snapshots:
            if baseline is None:
                after_start = _auto_snapshot(args.status, "after-start")
                baseline = after_start if after_start.exists() else _auto_snapshot(args.status, "early")
            fire = fire or _auto_snapshot(args.status, "after-fire")
            movement = movement or _auto_snapshot(args.status, "after-move")
            use = use or _auto_snapshot(args.status, "after-use")
            menu = menu or _auto_snapshot(args.status, "after-menu")

        missing = [
            label for label, path in (
                ("baseline", baseline),
                ("fire", fire),
                ("movement", movement),
                ("use", use),
                ("menu", menu),
            )
            if path is None
        ]
        if missing:
            raise AssertionError("missing required audio snapshot path(s): " + ", ".join(missing))

        final_status = _read(args.status)
        validate_status(
            final_status,
            baseline_status=_read(baseline),
            fire_status=_read(fire),
            movement_status=_read(movement),
            use_status=_read(use),
            menu_status=_read(menu),
        )
    except AssertionError as exc:
        summary = f"\nfinal audio summary: {summarize_status(final_status)}" if final_status else ""
        print(f"audio continuity proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    print(
        "audio continuity proof OK: SB16 IRQ/refill, SFX, and music carrier "
        "counters progressed across status snapshots"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
