#!/usr/bin/env python3
"""Validate remote-safe SB16 audio continuity from smoke status snapshots."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from status_fields import parse_hex8, parse_status_fields, summarize_status_fields  # noqa: E402

WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
MAKEFILE = ROOT / "Makefile"
AUDIO_DOC = ROOT / "docs" / "architecture.txt"
MUSIC_DOC = ROOT / "docs" / "architecture.txt"
MUSIC_IMPL = ROOT / "doom_port" / "music.c"
MUSIC_HEADER = ROOT / "doom_port" / "music.h"
PLAYABLE_DOC = ROOT / "docs" / "proof.txt"
RUNBOOK = ROOT / "docs" / "play.txt"
SMOKE_RUNNER = ROOT / "tests" / "run_smoke_qemu.sh"

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
    "musicrend",
    "adev",
    "pcm",
    "pcmbuf",
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
MAX_PENDING_PULL_REQUESTS = 1
PLAYABILITY_CADENCE_FIELDS = ("gtic", "leveltime", "doompresent")
PLAYABILITY_CADENCE_HEALTHY = "os-audio-cadence-observed"
CURRENT_MUSIC_PAYLOAD_OWNER = "doom_port/music.c"
CURRENT_MUSIC_SERVICE_COMMAND = "VIBE_AUDIO_MIXER_UPDATE"
FUTURE_HARDWARE_MIXER_REFILL_PLAYBACK = "future hardware-paced mixer/refill playback ABI"
AUDIO_DEVICE_SB16 = 1
AUDIO_DEVICE_STATUS_READY = 1
AUDIO_PCM_FORMAT_U8_STEREO = 1
AUDIO_OUTPUT_CHANNELS = 2
AUDIO_OUTPUT_SAMPLE_RATE = 11025
AUDIO_CAP_PCM_RING = 0x00000001
AUDIO_CAP_MIXER_VOICES = 0x00000002
AUDIO_CAP_PULL_STREAM = 0x00000004
AUDIO_CAP_SB16_DMA = 0x00000008
AUDIO_REQUIRED_CAPABILITIES = (
    AUDIO_CAP_PCM_RING
    | AUDIO_CAP_MIXER_VOICES
    | AUDIO_CAP_PULL_STREAM
    | AUDIO_CAP_SB16_DMA
)
AUDIO_CAPABILITY_NAMES = (
    (AUDIO_CAP_PCM_RING, "pcm-ring"),
    (AUDIO_CAP_MIXER_VOICES, "mixer-voices"),
    (AUDIO_CAP_PULL_STREAM, "pull-stream"),
    (AUDIO_CAP_SB16_DMA, "sb16-dma"),
)
MUS_SCORE_END_EVENT_TYPE = 6
MUS_RESERVED_EVENT_TYPE = 5
MUS_MAX_VARIABLE_DELAY_BYTES = 4
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
    "musicrend": 6,
    "adev": 3,
    "pcm": 3,
    "pcmbuf": 4,
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
    "musicrend",
    "adev",
    "pcm",
    "pcmbuf",
    "sb16",
    "dma",
    "play",
    "voiceq",
    "musicq",
    "doomrun",
    "doomopen",
    "doomread",
    "gameplay",
    "gtic",
    "leveltime",
    "doompresent",
)


def _status_fields(status: str) -> dict[str, str]:
    return parse_status_fields(status, error_type=AssertionError, require_any=False)


def summarize_status(status: str) -> str:
    try:
        fields = _status_fields(status)
    except AssertionError as exc:
        return f"unparseable status: {exc}"
    return summarize_status_fields(fields, SUMMARY_FIELDS)


def _hex(fields: dict[str, str], name: str, label: str) -> int:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"{label} snapshot missing {name}= field")
    parsed = parse_hex8(value)
    if parsed is None:
        raise AssertionError(f"{label} {name}= must be eight hex digits, got {value!r}")
    return parsed


def _hex_tuple(fields: dict[str, str], name: str, label: str, count: int) -> tuple[int, ...]:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"{label} snapshot missing {name}= field")
    parts = value.split(":")
    if len(parts) != count:
        raise AssertionError(f"{label} {name}= must have {count} colon-separated hex parts")
    for part in parts:
        if parse_hex8(part) is None:
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


def _assert_sfx_dma_output_consistency(snapshots: list[tuple[str, dict[str, str]]]) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first_sfxbytes = _hex_tuple(first_fields, "sfxbytes", first_label, 2)
    last_sfxbytes = _hex_tuple(last_fields, "sfxbytes", last_label, 2)
    first_sfxdma = _hex_tuple(first_fields, "sfxdma", first_label, 2)
    last_sfxdma = _hex_tuple(last_fields, "sfxdma", last_label, 2)

    for label, fields in snapshots:
        sfxmix = _hex(fields, "sfxmix", label)
        sfxbytes = _hex_tuple(fields, "sfxbytes", label, 2)
        sfxdma = _hex_tuple(fields, "sfxdma", label, 2)
        if sfxdma[0] > sfxmix:
            raise AssertionError(
                f"{label} sfxdma= mix count cannot exceed sfxmix= lane count, "
                f"got {sfxdma[0]:08X}>{sfxmix:08X}"
            )
        if sfxdma[1] > sfxbytes[1]:
            raise AssertionError(
                f"{label} sfxdma= bytes cannot exceed sfxbytes= output bytes, "
                f"got {sfxdma[1]:08X}>{sfxbytes[1]:08X}"
            )

    output_delta = last_sfxbytes[1] - first_sfxbytes[1]
    dma_delta = last_sfxdma[1] - first_sfxdma[1]
    if output_delta != dma_delta:
        raise AssertionError(
            "sfxbytes= output delta must match sfxdma= byte delta for IRQ-mixed SFX, "
            f"got {output_delta:08X} output and {dma_delta:08X} DMA bytes"
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
        if request - refill > MAX_PENDING_PULL_REQUESTS:
            raise AssertionError(
                f"{label} musicpull= pending pull request backlog must stay <= "
                f"{MAX_PENDING_PULL_REQUESTS}, got {request - refill:08X}"
            )


def _assert_pull_stream_sequence(snapshots: list[tuple[str, dict[str, str]]]) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first_pull = _hex_tuple(first_fields, "musicpull", first_label, 2)
    last_pull = _hex_tuple(last_fields, "musicpull", last_label, 2)
    first_voiceq = _hex_tuple(first_fields, "voiceq", first_label, 3)
    last_voiceq = _hex_tuple(last_fields, "voiceq", last_label, 3)
    first_render = _hex_tuple(first_fields, "musicrend", first_label, 6)
    last_render = _hex_tuple(last_fields, "musicrend", last_label, 6)

    request_delta = last_pull[0] - first_pull[0]
    refill_delta = last_pull[1] - first_pull[1]
    update_delta = last_voiceq[2] - first_voiceq[2]
    render_chunk_delta = last_render[1] - first_render[1]

    if refill_delta != request_delta:
        raise AssertionError(
            "musicpull= pull refill delta must match pull request delta for "
            "sequenced pull-stream service, "
            f"got {request_delta:08X} requests and {refill_delta:08X} refills"
        )
    if update_delta != refill_delta:
        raise AssertionError(
            "voiceq= stream update delta must match musicpull= pull refill delta, "
            f"got {update_delta:08X} updates and {refill_delta:08X} refills"
        )
    if render_chunk_delta != refill_delta:
        raise AssertionError(
            "musicrend= render chunk delta must match musicpull= pull refill delta, "
            f"got {render_chunk_delta:08X} chunks and {refill_delta:08X} refills"
        )

    previous_label, previous_fields = snapshots[0]
    previous_pull = _hex_tuple(previous_fields, "musicpull", previous_label, 2)
    previous_voiceq = _hex_tuple(previous_fields, "voiceq", previous_label, 3)
    previous_render = _hex_tuple(previous_fields, "musicrend", previous_label, 6)
    previous_pos = _hex(previous_fields, "musicpos", previous_label)
    for label, fields in snapshots[1:]:
        current_pull = _hex_tuple(fields, "musicpull", label, 2)
        current_voiceq = _hex_tuple(fields, "voiceq", label, 3)
        current_render = _hex_tuple(fields, "musicrend", label, 6)
        current_pos = _hex(fields, "musicpos", label)
        refill_step = current_pull[1] - previous_pull[1]
        update_step = current_voiceq[2] - previous_voiceq[2]
        render_step = current_render[1] - previous_render[1]
        if refill_step:
            if update_step != refill_step:
                raise AssertionError(
                    f"{label} voiceq= stream update step must match pull refill step, "
                    f"got {update_step:08X} updates and {refill_step:08X} refills"
                )
            if render_step != refill_step:
                raise AssertionError(
                    f"{label} musicrend= render chunk step must match pull refill step, "
                    f"got {render_step:08X} chunks and {refill_step:08X} refills"
                )
            if current_pos <= previous_pos:
                raise AssertionError(
                    f"{label} musicpos= must advance when a pull refill is serviced, "
                    f"got {previous_pos:08X}->{current_pos:08X}"
                )
        previous_label = label
        previous_pull = current_pull
        previous_voiceq = current_voiceq
        previous_render = current_render
        previous_pos = current_pos


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
        _assert_pull_stream_sequence(snapshots)
        return

    if "PULL" in modes:
        _assert_pull_request_refill_consistency(snapshots)
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 0, "pull request")
        _assert_tuple_component_progress(snapshots, "musicpull", 2, 1, "pull refill")
        _assert_tuple_component_progress(snapshots, "voiceq", 3, 2, "stream update service")
        _assert_pull_stream_sequence(snapshots)


def _assert_music_render_evidence(snapshots: list[tuple[str, dict[str, str]]]) -> None:
    final_label, final_fields = snapshots[-1]
    final_format, final_chunks, final_notes, final_events, final_peak, final_samples = _hex_tuple(
        final_fields,
        "musicrend",
        final_label,
        6,
    )

    if final_format not in (1, 2):
        raise AssertionError(
            "musicrend= must record a MUS or MIDI renderer format for parser-backed music, "
            f"got {final_format:08X}"
        )
    for value, label in (
        (final_chunks, "render chunk"),
        (final_notes, "note event"),
        (final_events, "render event"),
        (final_peak, "active voice peak"),
        (final_samples, "rendered sample"),
    ):
        if value == 0:
            raise AssertionError(f"musicrend= {label} evidence must be nonzero")

    _assert_tuple_component_progress(snapshots, "musicrend", 6, 1, "render chunk")
    _assert_tuple_component_progress(snapshots, "musicrend", 6, 2, "note event")
    _assert_tuple_component_progress(snapshots, "musicrend", 6, 3, "render event")
    _assert_tuple_component_progress(snapshots, "musicrend", 6, 5, "rendered sample")


def _assert_music_render_covers_stream_service(
    snapshots: list[tuple[str, dict[str, str]]],
    *,
    use_pull_stream: bool,
) -> None:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    if use_pull_stream:
        first_service = _hex_tuple(first_fields, "musicpull", first_label, 2)[1]
        last_service = _hex_tuple(last_fields, "musicpull", last_label, 2)[1]
        service_label = "musicpull= refill"
    else:
        first_service = _hex_tuple(first_fields, "voiceq", first_label, 3)[2]
        last_service = _hex_tuple(last_fields, "voiceq", last_label, 3)[2]
        service_label = "voiceq= stream update"

    first_render = _hex_tuple(first_fields, "musicrend", first_label, 6)
    last_render = _hex_tuple(last_fields, "musicrend", last_label, 6)
    first_pos = _hex(first_fields, "musicpos", first_label)
    last_pos = _hex(last_fields, "musicpos", last_label)
    first_buffer = _hex(first_fields, "musicbuf", first_label)
    last_buffer = _hex(last_fields, "musicbuf", last_label)

    service_delta = last_service - first_service
    render_chunk_delta = last_render[1] - first_render[1]
    rendered_sample_delta = last_render[5] - first_render[5]
    consumed_sample_delta = last_pos - first_pos

    # The baseline snapshot can already have a partially consumed music window.
    # The conserved quantity is rendered bytes plus the initial buffer, not
    # rendered bytes alone.
    if render_chunk_delta < service_delta:
        raise AssertionError(
            "musicrend= render chunk delta must cover stream service updates, "
            f"got {render_chunk_delta:08X} chunks for {service_delta:08X} {service_label} updates"
        )
    if rendered_sample_delta + first_buffer < consumed_sample_delta + last_buffer:
        raise AssertionError(
            "musicrend= rendered sample delta plus initial musicbuf= must cover "
            "musicpos= consumed samples plus final musicbuf=, "
            f"got {rendered_sample_delta:08X} rendered + {first_buffer:08X} buffered "
            f"for {consumed_sample_delta:08X} consumed + {last_buffer:08X} buffered"
        )


def _audio_capability_names(capabilities: int) -> list[str]:
    return [name for bit, name in AUDIO_CAPABILITY_NAMES if capabilities & bit]


def _assert_audio_device_contract(snapshots: list[tuple[str, dict[str, str]]]) -> None:
    for label, fields in snapshots:
        device_kind, device_status, capabilities = _hex_tuple(fields, "adev", label, 3)
        if device_kind != AUDIO_DEVICE_SB16:
            raise AssertionError(f"{label} adev= must report SB16 device kind 00000001")
        if device_status != AUDIO_DEVICE_STATUS_READY:
            raise AssertionError(f"{label} adev= must report ready status 00000001")
        if capabilities & AUDIO_REQUIRED_CAPABILITIES != AUDIO_REQUIRED_CAPABILITIES:
            raise AssertionError(
                f"{label} adev= capabilities must include PCM ring, mixer voices, "
                "pull stream, and SB16 DMA"
            )

        pcm_format, channels, sample_rate = _hex_tuple(fields, "pcm", label, 3)
        if pcm_format != AUDIO_PCM_FORMAT_U8_STEREO:
            raise AssertionError(f"{label} pcm= must use unsigned 8-bit stereo format 00000001")
        if channels != AUDIO_OUTPUT_CHANNELS:
            raise AssertionError(f"{label} pcm= must expose two output channels")
        if sample_rate != AUDIO_OUTPUT_SAMPLE_RATE:
            raise AssertionError(f"{label} pcm= must expose the SB16 output rate 11025")

        ring_bytes, period_bytes, write_offset, active_half = _hex_tuple(fields, "pcmbuf", label, 4)
        status_half = _hex(fields, "half", label)
        if ring_bytes == 0 or period_bytes == 0:
            raise AssertionError(f"{label} pcmbuf= must expose nonzero ring and period bytes")
        if period_bytes * 2 != ring_bytes:
            raise AssertionError(f"{label} pcmbuf= period bytes must be half of the PCM ring")
        if write_offset >= ring_bytes:
            raise AssertionError(f"{label} pcmbuf= write offset must stay inside the PCM ring")
        if active_half not in (0, 1):
            raise AssertionError(f"{label} pcmbuf= active half must be 0 or 1")
        if active_half != status_half:
            raise AssertionError(f"{label} pcmbuf= active half must match half= IRQ phase")


def _hex8(value: int) -> str:
    return f"{value & 0xFFFFFFFF:08X}"


def _counter_delta_summary(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
) -> dict[str, str]:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first = _hex(first_fields, name, first_label)
    last = _hex(last_fields, name, last_label)
    return {
        "start": _hex8(first),
        "final": _hex8(last),
        "delta": _hex8(last - first),
    }


def _tuple_delta_summary(
    snapshots: list[tuple[str, dict[str, str]]],
    name: str,
    count: int,
    index: int,
) -> dict[str, str]:
    first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    first = _hex_tuple(first_fields, name, first_label, count)[index]
    last = _hex_tuple(last_fields, name, last_label, count)[index]
    return {
        "start": _hex8(first),
        "final": _hex8(last),
        "delta": _hex8(last - first),
    }


def _has_complete_hex_fields(
    snapshots: list[tuple[str, dict[str, str]]],
    names: tuple[str, ...],
) -> bool:
    return all(
        name in fields and parse_hex8(fields[name]) is not None
        for _, fields in snapshots
        for name in names
    )


def build_playability_cadence(
    snapshots: list[tuple[str, dict[str, str]]],
) -> dict[str, object]:
    """Summarize optional OS-side audio cadence vs Doom progress fields."""

    if not _has_complete_hex_fields(snapshots, PLAYABILITY_CADENCE_FIELDS):
        missing = [
            name
            for name in PLAYABILITY_CADENCE_FIELDS
            if not all(name in fields for _, fields in snapshots)
        ]
        return {
            "available": False,
            "verdict": "status-fields-unavailable",
            "status_fields": list(PLAYABILITY_CADENCE_FIELDS),
            "reason": "missing status fields: " + ", ".join(missing or PLAYABILITY_CADENCE_FIELDS),
        }

    progress = {
        name: _counter_delta_summary(snapshots, name)
        for name in PLAYABILITY_CADENCE_FIELDS
    }
    audioirq = _counter_delta_summary(snapshots, "audioirq")
    refill = _counter_delta_summary(snapshots, "refill")
    pull_refill = _tuple_delta_summary(snapshots, "musicpull", 2, 1)
    musicpos = _counter_delta_summary(snapshots, "musicpos")
    safety = {
        name: _counter_delta_summary(snapshots, name)
        for name in ("mixclip", "musicunder", "musicdrops")
    }

    frame_delta = int(progress["doompresent"]["delta"], 16)
    gtic_delta = int(progress["gtic"]["delta"], 16)
    leveltime_delta = int(progress["leveltime"]["delta"], 16)
    audioirq_delta = int(audioirq["delta"], 16)
    refill_delta = int(refill["delta"], 16)
    pull_refill_delta = int(pull_refill["delta"], 16)
    musicpos_delta = int(musicpos["delta"], 16)
    audio_pressure = any(int(entry["delta"], 16) > 0 for entry in safety.values())

    if frame_delta == 0 or gtic_delta == 0 or leveltime_delta == 0:
        verdict = "guest-progress-stalled"
        interpretation = "Doom frame/tic counters did not advance while checking audio cadence"
    elif audio_pressure:
        verdict = "os-audio-pressure"
        interpretation = "audio safety counters increased during the audio proof window"
    elif audioirq_delta == 0 or refill_delta == 0 or pull_refill_delta == 0:
        verdict = "audio-cadence-stalled"
        interpretation = "Doom progressed but SB16 IRQ/refill/pull service did not all advance"
    else:
        verdict = PLAYABILITY_CADENCE_HEALTHY
        interpretation = (
            "Doom frame/tic progress, SB16 IRQ/refill progress, and pull-stream "
            "service all advanced without audio safety regressions"
        )

    return {
        "available": True,
        "verdict": verdict,
        "interpretation": interpretation,
        "status_fields": list(PLAYABILITY_CADENCE_FIELDS),
        "progress": {
            **progress,
            "audioirq": audioirq,
            "refill": refill,
            "musicpull_refill": pull_refill,
            "musicpos": musicpos,
        },
        "ratios": {
            "audioirq_delta_per_frame_floor": _hex8(audioirq_delta // frame_delta if frame_delta else 0),
            "refill_delta_per_frame_floor": _hex8(refill_delta // frame_delta if frame_delta else 0),
            "pull_refill_delta_per_frame_floor": _hex8(pull_refill_delta // frame_delta if frame_delta else 0),
            "musicpos_delta_per_leveltime_floor": _hex8(musicpos_delta // leveltime_delta if leveltime_delta else 0),
        },
        "safety": safety,
        "audio_pressure": audio_pressure,
    }


def build_os_audio_contract(
    snapshots: list[tuple[str, dict[str, str]]],
) -> dict[str, object]:
    """Build a status-only OS audio device/ring/stream/mixer contract summary."""

    _first_label, first_fields = snapshots[0]
    last_label, last_fields = snapshots[-1]
    device_kind, device_status, capabilities = _hex_tuple(last_fields, "adev", last_label, 3)
    pcm_format, channels, sample_rate = _hex_tuple(last_fields, "pcm", last_label, 3)
    ring_bytes, period_bytes, write_offset, active_half = _hex_tuple(
        last_fields,
        "pcmbuf",
        last_label,
        4,
    )
    half_matches = all(
        _hex_tuple(fields, "pcmbuf", label, 4)[3] == _hex(fields, "half", label)
        for label, fields in snapshots
    )
    pull_pairs = [_hex_tuple(fields, "musicpull", label, 2) for label, fields in snapshots]
    pending = [max(0, request - refill) for request, refill in pull_pairs]
    voice_lanes_match = all(
        _hex(fields, "voices", label)
        == _hex(fields, "sfxvoices", label) + _hex(fields, "musicvoices", label)
        for label, fields in snapshots
    )
    requested, refilled = pull_pairs[-1]

    return {
        "lane": "status-only-os-audio-subsystem",
        "status_fields": {
            "device": "adev",
            "sample_format": "pcm",
            "ring": "pcmbuf",
            "irq_phase": "half",
            "stream": "musicstream/musicpull/musicbuf/musicpos",
            "mixer_lanes": "voices/sfxvoices/musicvoices/sfxmix/musicmix",
        },
        "device": {
            "kind": "SB16" if device_kind == AUDIO_DEVICE_SB16 else f"unknown-{device_kind:08X}",
            "ready": device_status == AUDIO_DEVICE_STATUS_READY,
            "capabilities": _audio_capability_names(capabilities),
            "required_capabilities_present": (
                capabilities & AUDIO_REQUIRED_CAPABILITIES == AUDIO_REQUIRED_CAPABILITIES
            ),
            "playback_start_count": last_fields["play"].split(":")[0],
        },
        "pcm_ring": {
            "format": "u8-stereo" if pcm_format == AUDIO_PCM_FORMAT_U8_STEREO else f"unknown-{pcm_format:08X}",
            "channels": channels,
            "sample_rate": sample_rate,
            "ring_bytes": f"{ring_bytes:08X}",
            "period_bytes": f"{period_bytes:08X}",
            "write_offset": f"{write_offset:08X}",
            "active_half": f"{active_half:08X}",
            "two_period_ring": ring_bytes > 0 and period_bytes * 2 == ring_bytes,
            "active_half_matches_half": half_matches,
            "irq_delta": _counter_delta_summary(snapshots, "audioirq")["delta"],
            "refill_delta": _counter_delta_summary(snapshots, "refill")["delta"],
        },
        "stream": {
            "mode": last_fields["musicstream"],
            "request_delta": _tuple_delta_summary(snapshots, "musicpull", 2, 0)["delta"],
            "refill_delta": _tuple_delta_summary(snapshots, "musicpull", 2, 1)["delta"],
            "ordered_refills": refilled <= requested,
            "bounded_pending_requests": max(pending) <= MAX_PENDING_PULL_REQUESTS,
            "pending_peak": f"{max(pending):08X}",
            "buffer_initial": first_fields["musicbuf"],
            "buffer_final": last_fields["musicbuf"],
            "position_delta": _counter_delta_summary(snapshots, "musicpos")["delta"],
            "payload_owner": CURRENT_MUSIC_PAYLOAD_OWNER,
            "service_command": CURRENT_MUSIC_SERVICE_COMMAND,
        },
        "mixer_lanes": {
            "voice_total_matches_lanes": voice_lanes_match,
            "sfx_lane_counter": "sfxmix",
            "music_lane_counter": "musicmix",
            "sfx_delta": _counter_delta_summary(snapshots, "sfxmix")["delta"],
            "sfx_output_delta": _tuple_delta_summary(snapshots, "sfxbytes", 2, 1)["delta"],
            "sfx_dma_output_delta": _tuple_delta_summary(snapshots, "sfxdma", 2, 1)["delta"],
            "sfx_dma_output_matches_sfx_output": (
                _tuple_delta_summary(snapshots, "sfxbytes", 2, 1)["delta"]
                == _tuple_delta_summary(snapshots, "sfxdma", 2, 1)["delta"]
            ),
            "music_delta": _counter_delta_summary(snapshots, "musicmix")["delta"],
            "music_render_chunk_delta": _tuple_delta_summary(snapshots, "musicrend", 6, 1)["delta"],
            "music_render_sample_delta": _tuple_delta_summary(snapshots, "musicrend", 6, 5)["delta"],
            "human_listener_lane": "not-proven-by-status",
        },
        "claim": (
            "status-only generic device/ring/stream/mixer contract; Doom SFX, "
            "parser-backed music, and human-listened quality remain separate lanes"
        ),
    }


def _assert_playability_cadence_if_present(
    snapshots: list[tuple[str, dict[str, str]]],
) -> None:
    cadence = build_playability_cadence(snapshots)
    if cadence.get("available") is not True:
        return
    if cadence.get("verdict") != PLAYABILITY_CADENCE_HEALTHY:
        raise AssertionError(
            "playability cadence must show Doom progress with advancing audio service, "
            f"got {cadence.get('verdict')}"
        )


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
        ("musicrend", 6),
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
    _assert_sfx_dma_output_consistency(snapshots)
    for name, maximum in MAX_SAFETY_DELTAS.items():
        _assert_max_delta(snapshots, name, maximum, "audio safety")
    _assert_music_render_evidence(snapshots)
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
    _assert_music_render_covers_stream_service(
        snapshots,
        use_pull_stream=uses_pull_stream or require_pull_stream,
    )
    _assert_audio_device_contract(snapshots)
    _assert_playability_cadence_if_present(snapshots)


def validate_repo_contract() -> None:
    workflow = WORKFLOW.read_text()
    makefile = MAKEFILE.read_text()
    audio_doc = AUDIO_DOC.read_text()
    music_doc = MUSIC_DOC.read_text()
    music_impl = MUSIC_IMPL.read_text()
    music_header = MUSIC_HEADER.read_text()
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
                "adev=",
                "pcm=",
                "pcmbuf=",
                "os_audio_contract",
                "pcmbuf=` active-half status to match the IRQ `half=` field",
                "sfxmix= counts non-music Doom SFX only",
                "sfxq=",
                "sfxbytes=",
                "sfxdma=",
                "sfxsrc=",
                "sfxlast=",
                "VIBE_AUDIO_FLAG_WAD_SFX",
                "VIBE_AUDIO_MUSIC_PULL_STATE",
                "VIBE_AUDIO_STREAM_INFO",
                "hardware-paced pull request",
                "musicpos=",
                "musicbuf=",
                "musicunder=",
                "musicdrops=",
                "musicstream=PULL",
                "musicpull=",
                "musicrend=",
                "rendered-sample delta",
                "buffered coverage",
                "event type 6",
                "event type 5",
                "unterminated MUS variable-length delays",
                "grouped MUS events",
                "stream-health evidence",
                "playability_cadence",
                "OS audio cadence",
                "status-only OS audio subsystem lane",
                "single static music carrier",
                "no new mixclip=, musicunder=, or musicdrops=",
                "Aggregate audible-output proof (not human listener approval)",
                "human-listened quality is a separate lane",
                "future hardware-paced mixer/refill playback ABI",
            ),
        ),
        (
            MUSIC_DOC,
            music_doc,
            (
                "stateful stream cursor",
                "VIBE_AUDIO_PCM_PULL_STATE",
                "VIBE_AUDIO_MIXER_UPDATE",
                "hardware-paced pull request",
                "separate from normal Doom SFX",
                "musicpos=",
                "musicbuf=",
                "musicunder=",
                "musicdrops=",
                "musicstream=PULL",
                "musicpull=",
                "musicrend=",
                "MUS event type 6",
                "event type 5",
                "unterminated MUS variable-length delays",
                "grouped MUS events",
                "zero-duration songs do not become silent looping streams",
                "rendered-sample delta",
                "coverage is the real stream invariant",
                "long-playback wrap",
                "static stream window",
                "Music legitimacy roadmap as OS contracts",
                "os_audio_contract",
                "future hardware-paced mixer/refill playback ABI",
            ),
        ),
        (
            MUSIC_IMPL,
            music_impl,
            (
                "VIBE_MUSIC_MUS_EVENT_SCORE_END 6u",
                "event_type == VIBE_MUSIC_MUS_EVENT_SCORE_END",
                "read_mus_delay",
                "mus_parse_fail",
                "++stats->score_end_count",
                "++stats->invalid_event_count",
            ),
        ),
        (
            MUSIC_HEADER,
            music_header,
            (
                "score_end_count",
                "invalid_event_count",
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
        "audio continuity proof OK: generic device/ring/stream status, SB16 "
        "IRQ/refill, SFX DMA refill, and kernel-visible music stream counters "
        "progressed across status snapshots; "
        "human-listened quality and future hardware-paced mixer/refill playback remain separate lanes"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
