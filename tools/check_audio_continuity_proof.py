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
    "sfxq",
    "sfxbytes",
    "sfxdma",
    "sfxsrc",
    "sfxlast",
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
    "musicpos",
    "musicbuf",
    "musicunder",
    "musicdrops",
    "musicstream",
    "musicpull",
    "sb16",
    "dma",
    "play",
    "voiceq",
    "musicq",
)
MONOTONIC_COUNTERS = (
    "doomsound",
    "sfxmix",
    "sfxsrc",
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
    "musicpos",
    "musicunder",
    "musicdrops",
    "dma",
)
FINAL_POSITIVE_COUNTERS = (
    "doomsound",
    "sfxmix",
    "sfxsrc",
    "audioirq",
    "refill",
    "musicmix",
    "musicpos",
    "dma",
)
PROGRESS_COUNTERS = ("doomsound", "audioirq", "refill", "sfxmix", "musicmix", "musicpos")
MIN_PHASED_PROGRESS = {
    "audioirq": len(SNAPSHOT_ORDER) - 1,
    "refill": len(SNAPSHOT_ORDER) - 1,
}
MAX_SAFETY_DELTAS = {
    "mixclip": 0,
    "musicunder": 0,
    "musicdrops": 0,
}
PROGRESS_TUPLE_COMPONENTS = (
    ("voiceq", 3, 2, "stream update"),
)
MIN_MUSIC_STREAM_UPDATE_DELTA = 2
TUPLE_FIELDS = {
    "sb16": 2,
    "play": 2,
    "voiceq": 3,
    "sfxq": 4,
    "sfxbytes": 2,
    "sfxdma": 2,
    "sfxlast": 3,
    "musicq": 2,
    "musicpull": 2,
}
MUSIC_STREAM_MODES = ("NONE", "PUSH", "PULL")
SUMMARY_FIELDS = (
    "audio",
    "doomsound",
    "sfxmix",
    "sfxq",
    "sfxbytes",
    "sfxdma",
    "sfxsrc",
    "sfxlast",
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
    "musicpos",
    "musicbuf",
    "musicunder",
    "musicdrops",
    "musicstream",
    "musicpull",
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
        elif name == "musicstream":
            if fields[name] not in MUSIC_STREAM_MODES:
                raise AssertionError(
                    f"{label} musicstream= must be one of {', '.join(MUSIC_STREAM_MODES)}, "
                    f"got {fields[name]!r}"
                )
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


def _assert_min_delta(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
    minimum: int,
) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first = _hex(first_fields, name, first_label)
    last = _hex(last_fields, name, last_label)
    delta = last - first
    if delta < minimum:
        raise AssertionError(
            f"{name}= must advance by at least {minimum:08X} across phase snapshots, "
            f"got {delta:08X}"
        )


def _assert_max_delta(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
    maximum: int,
    reason: str,
) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first = _hex(first_fields, name, first_label)
    last = _hex(last_fields, name, last_label)
    delta = last - first
    if delta > maximum:
        raise AssertionError(
            f"{name}= {reason} delta must be <= {maximum:08X}, got {delta:08X}"
        )


def _assert_phase_progress(
    snapshots: list[tuple[str, dict[str, str]]],
    earlier_label: str,
    later_label: str,
    name: str,
    reason: str,
) -> None:
    lookup = {label: fields for label, fields in snapshots}
    earlier = _hex(lookup[earlier_label], name, earlier_label)
    later = _hex(lookup[later_label], name, later_label)
    if later <= earlier:
        raise AssertionError(
            f"{name}= must increase from {earlier_label} to {later_label} for {reason}, "
            f"got {earlier:08X}->{later:08X}"
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


def _assert_tuple_component_progress(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
    count: int,
    index: int,
    reason: str,
) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first = _hex_tuple(first_fields, name, first_label, count)
    last = _hex_tuple(last_fields, name, last_label, count)
    if last[index] <= first[index]:
        raise AssertionError(
            f"{name}= {reason} counter must increase from {first_label} to {last_label}, "
            f"got {first[index]:08X}->{last[index]:08X}"
        )


def _assert_tuple_component_phase_progress(
    snapshots: list[tuple[str, dict[str, str]]],
    earlier_label: str,
    later_label: str,
    name: str,
    count: int,
    index: int,
    reason: str,
) -> None:
    lookup = {label: fields for label, fields in snapshots}
    earlier = _hex_tuple(lookup[earlier_label], name, earlier_label, count)[index]
    later = _hex_tuple(lookup[later_label], name, later_label, count)[index]
    if later <= earlier:
        raise AssertionError(
            f"{name}= {reason} counter must increase from {earlier_label} to {later_label}, "
            f"got {earlier:08X}->{later:08X}"
        )


def _assert_tuple_component_min_delta(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
    count: int,
    index: int,
    minimum: int,
    reason: str,
) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first = _hex_tuple(first_fields, name, first_label, count)
    last = _hex_tuple(last_fields, name, last_label, count)
    delta = last[index] - first[index]
    if delta < minimum:
        raise AssertionError(
            f"{name}= {reason} counter must advance by at least {minimum:08X}, "
            f"got {delta:08X}"
        )


def _assert_tuple_component_nonzero(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
    count: int,
    index: int,
    reason: str,
) -> None:
    for label, fields in snapshots:
        value = _hex_tuple(fields, name, label, count)[index]
        if value > 0:
            return
    raise AssertionError(f"{name}= {reason} counter must be nonzero in at least one snapshot")


def _assert_voice_lane_consistency(snapshots: list[tuple[str, dict[str, str]]]) -> None:
    for label, fields in snapshots:
        voices = _hex(fields, "voices", label)
        sfxvoices = _hex(fields, "sfxvoices", label)
        musicvoices = _hex(fields, "musicvoices", label)
        if voices != sfxvoices + musicvoices:
            raise AssertionError(
                f"{label} voices= must equal sfxvoices= plus musicvoices=, "
                f"got {voices:08X} != {sfxvoices:08X}+{musicvoices:08X}"
            )


def _assert_music_stream_health(
    snapshots: list[tuple[str, dict[str, str]]],
    *,
    use_pull_stream: bool,
) -> None:
    buffers = [_hex(fields, "musicbuf", label) for label, fields in snapshots]
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    if use_pull_stream:
        first_update = _hex_tuple(first_fields, "musicpull", first_label, 2)[1]
        last_update = _hex_tuple(last_fields, "musicpull", last_label, 2)[1]
        counter = "musicpull= pull refill"
    else:
        first_update = _hex_tuple(first_fields, "voiceq", first_label, 3)[2]
        last_update = _hex_tuple(last_fields, "voiceq", last_label, 3)[2]
        counter = "voiceq= stream update"
    update_delta = last_update - first_update

    if update_delta < MIN_MUSIC_STREAM_UPDATE_DELTA:
        raise AssertionError(
            f"{counter} counter must advance by at least "
            f"{MIN_MUSIC_STREAM_UPDATE_DELTA} across music health snapshots, "
            f"got {update_delta:08X}"
        )
    if len(set(buffers)) < 2:
        raise AssertionError("musicbuf= must show changing stream-window health across snapshots")


def _assert_pull_request_refill_consistency(snapshots: list[tuple[str, dict[str, str]]]) -> None:
    for label, fields in snapshots:
        request, refill = _hex_tuple(fields, "musicpull", label, 2)
        if refill > request:
            raise AssertionError(
                f"{label} musicpull= refill counter cannot exceed request counter, "
                f"got {request:08X}:{refill:08X}"
            )


def _assert_music_stream_mode(
    snapshots: list[tuple[str, dict[str, str]]],
    *,
    require_pull_stream: bool,
) -> None:
    modes = {fields["musicstream"] for _, fields in snapshots}
    if "NONE" in modes:
        raise AssertionError("musicstream= must name PUSH or PULL while proving music continuity")

    if require_pull_stream:
        if modes != {"PULL"}:
            raise AssertionError(
                "musicstream=PULL is required for a hardware-paced music proof; "
                f"got {', '.join(sorted(modes))}"
            )
        _assert_pull_request_refill_consistency(snapshots)
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 0, "pull request")
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 1, "pull refill")
        _assert_tuple_component_min_delta(
            snapshots,
            "musicpull",
            2,
            0,
            MIN_MUSIC_STREAM_UPDATE_DELTA,
            "pull request",
        )
        _assert_tuple_component_min_delta(
            snapshots,
            "musicpull",
            2,
            1,
            MIN_MUSIC_STREAM_UPDATE_DELTA,
            "pull refill",
        )
        _assert_tuple_component_nonzero(snapshots, "musicpull", 2, 0, "pull request")
        _assert_tuple_component_nonzero(snapshots, "musicpull", 2, 1, "pull refill")
        _assert_tuple_component_progress(snapshots, "voiceq", 3, 2, "stream update service")
        return

    if "PULL" in modes:
        _assert_pull_request_refill_consistency(snapshots)
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 0, "pull request")
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 1, "pull refill")
        _assert_tuple_component_progress(snapshots, "voiceq", 3, 2, "stream update service")


def validate_status(
    final_status: str,
    baseline_status: str,
    fire_status: str,
    movement_status: str,
    use_status: str,
    menu_status: str,
    require_pull_stream: bool = False,
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
    if all(_hex(fields, "musicvoices", label) == 0 for label, fields in snapshots):
        raise AssertionError("musicvoices= must be nonzero in at least one snapshot")
    if all(_hex(fields, "musicbuf", label) == 0 for label, fields in snapshots):
        raise AssertionError("musicbuf= must be nonzero in at least one snapshot")

    if _hex(final_fields, "ack8", "final") == 0 and _hex(final_fields, "ack16", "final") == 0:
        raise AssertionError("final ack8= or ack16= must be nonzero to prove SB16 IRQ ACKs")
    if _hex_tuple(final_fields, "sb16", "final", 2)[0] == 0:
        raise AssertionError("final sb16= must expose a nonzero SB16 DSP major version")
    if _hex_tuple(final_fields, "play", "final", 2)[0] == 0:
        raise AssertionError("final play= must prove SB16 playback was started")
    if _hex_tuple(final_fields, "voiceq", "final", 3)[0] == 0:
        raise AssertionError("final voiceq= must prove at least one audio voice was queued")
    if _hex_tuple(final_fields, "sfxq", "final", 4)[0] == 0:
        raise AssertionError("final sfxq= must prove at least one non-music Doom SFX was submitted")
    sfx_submit, sfx_output = _hex_tuple(final_fields, "sfxbytes", "final", 2)
    if sfx_submit == 0 or sfx_output == 0:
        raise AssertionError("final sfxbytes= must prove submitted and SB16-output SFX PCM bytes")
    sfx_dma_mixes, sfx_dma_bytes = _hex_tuple(final_fields, "sfxdma", "final", 2)
    if sfx_dma_mixes == 0 or sfx_dma_bytes == 0:
        raise AssertionError("final sfxdma= must prove SFX mixed during SB16 DMA refills")
    _, sfx_rate, sfx_length = _hex_tuple(final_fields, "sfxlast", "final", 3)
    if sfx_rate == 0 or sfx_length == 0:
        raise AssertionError("final sfxlast= must expose a nonzero SFX sample rate and padded length")
    if _hex_tuple(final_fields, "musicq", "final", 2)[0] == 0:
        raise AssertionError("final musicq= must prove the music voice was queued")

    uses_pull_stream = any(fields["musicstream"] == "PULL" for _, fields in snapshots)

    _assert_voice_lane_consistency(snapshots)
    for name in MONOTONIC_COUNTERS:
        _assert_nondecreasing(snapshots, name)
    for name, count in (
        ("play", 2),
        ("voiceq", 3),
        ("sfxq", 4),
        ("sfxbytes", 2),
        ("sfxdma", 2),
        ("musicq", 2),
    ):
        _assert_tuple_nondecreasing(snapshots, name, count)
    _assert_tuple_nondecreasing(snapshots, "musicpull", 2)
    for name in PROGRESS_COUNTERS:
        _assert_progress(snapshots, name)
    for name, minimum in MIN_PHASED_PROGRESS.items():
        _assert_min_delta(snapshots, name, minimum)
    _assert_phase_progress(snapshots, "baseline", "fire", "doomsound", "scripted fire SFX")
    _assert_phase_progress(snapshots, "baseline", "fire", "sfxmix", "scripted fire SFX")
    _assert_phase_progress(snapshots, "baseline", "fire", "sfxsrc", "scripted fire WAD SFX")
    _assert_tuple_component_progress(snapshots, "sfxq", 4, 0, "scripted fire SFX submit")
    _assert_tuple_component_progress(snapshots, "sfxbytes", 2, 0, "scripted fire SFX submit bytes")
    _assert_tuple_component_progress(snapshots, "sfxbytes", 2, 1, "scripted fire SFX output bytes")
    _assert_tuple_component_progress(snapshots, "sfxdma", 2, 0, "SB16 DMA SFX refill mix")
    _assert_tuple_component_progress(snapshots, "sfxdma", 2, 1, "SB16 DMA SFX refill bytes")
    _assert_tuple_component_phase_progress(
        snapshots,
        "baseline",
        "fire",
        "sfxdma",
        2,
        0,
        "scripted fire SB16 DMA SFX refill mix",
    )
    _assert_tuple_component_phase_progress(
        snapshots,
        "baseline",
        "fire",
        "sfxdma",
        2,
        1,
        "scripted fire SB16 DMA SFX refill bytes",
    )
    for name, maximum in MAX_SAFETY_DELTAS.items():
        _assert_max_delta(snapshots, name, maximum, "audio safety")
    _assert_music_stream_mode(snapshots, require_pull_stream=require_pull_stream)
    if uses_pull_stream or require_pull_stream:
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 0, "pull request")
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 1, "pull refill")
    else:
        for name, count, index, reason in PROGRESS_TUPLE_COMPONENTS:
            _assert_tuple_component_progress(snapshots, name, count, index, reason)
    _assert_music_stream_health(
        snapshots,
        use_pull_stream=uses_pull_stream or require_pull_stream,
    )


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
                "audio_backend=\"-audiodev none,id=snd0 -device sb16,audiodev=snd0\"",
                "QEMU_EXTRA_ARGS=\"$audio_backend\"",
                "tools/check_audio_continuity_proof.py",
                "--require-pull-stream",
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
                "--require-pull-stream $$audio_args",
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
                "sfxq=",
                "sfxbytes=",
                "sfxdma=",
                "sfxsrc=",
                "sfxlast=",
                "VIBE_AUDIO_FLAG_WAD_SFX",
                "VIBE_AUDIO_MUSIC_PULL_STATE",
                "hardware-paced pull request",
                "musicpos=",
                "musicbuf=",
                "musicunder=",
                "musicdrops=",
                "musicstream=PULL",
                "musicpull=",
                "stream-health evidence",
                "single static music carrier",
                "no new mixclip=, musicunder=, or musicdrops=",
            ),
        ),
        (
            MUSIC_DOC,
            music_doc,
            (
                "stateful stream cursor",
                "VIBE_AUDIO_MUSIC_PULL_STATE",
                "VIBE_AUDIO_UPDATE_SFX",
                "hardware-paced pull request",
                "separate from normal Doom SFX",
                "musicpos=",
                "musicbuf=",
                "musicunder=",
                "musicdrops=",
                "musicstream=PULL",
                "musicpull=",
                "long-playback wrap",
                "static stream window",
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
    parser.add_argument(
        "--require-pull-stream",
        action="store_true",
        help="Require the hardware-paced musicstream=PULL request/refill contract.",
    )
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
            require_pull_stream=args.require_pull_stream,
        )
    except AssertionError as exc:
        summary = f"\nfinal audio summary: {summarize_status(final_status)}" if final_status else ""
        print(f"audio continuity proof failed: {exc}{summary}", file=sys.stderr)
        return 1

    print(
        "audio continuity proof OK: SB16 IRQ/refill, SFX DMA refill, and "
        "kernel-visible music stream counters progressed across status snapshots"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
