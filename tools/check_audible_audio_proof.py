#!/usr/bin/env python3
"""Create and validate copyright-safe remote audible-audio proof manifests."""

from __future__ import annotations

import argparse
import json
import re
import struct
import sys
import wave
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import check_audio_continuity_proof  # noqa: E402
from status_fields import parse_hex8, parse_status_fields  # noqa: E402

WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
MAKEFILE = ROOT / "Makefile"
AUDIO_DOC = ROOT / "docs" / "architecture.txt"
MUSIC_DOC = ROOT / "docs" / "architecture.txt"
MUSIC_IMPL = ROOT / "doom_port" / "music.c"
MUSIC_HEADER = ROOT / "doom_port" / "music.h"
PLAYABLE_DOC = ROOT / "docs" / "proof.txt"
RUNBOOK = ROOT / "docs" / "play.txt"
ARTIFACT_CHECKER = ROOT / "tools" / "check_cloud_playability_artifacts.py"

SCHEMA = "vibe-os-audible-audio-proof-v6"
STATUS_ONLY_OS_AUDIO_SUBSYSTEM_LANE = "status-only-os-audio-subsystem"
AGGREGATE_AUDIBLE_OUTPUT_LANE = "aggregate-machine-audible-output"
HUMAN_LISTENED_QUALITY_LANE = "human-listened-quality"
MUSIC_LEGITIMACY_LANE = "os-music-legitimacy-contract"
FUTURE_HARDWARE_MIXER_REFILL_LANE = "future-hardware-paced-mixer-refill-playback"
FORBIDDEN_MANIFEST_KEYS = {
    "asset_bytes",
    "audio_bytes",
    "base64",
    "lump_bytes",
    "music_bytes",
    "pcm",
    "raw_audio",
    "samples",
    "sfx_bytes",
    "wad_bytes",
    "waveform",
}

DEFAULT_WINDOW_MS = 100
DEFAULT_MIN_DURATION_MS = 3000
DEFAULT_MIN_ACTIVE_WINDOWS = 3
DEFAULT_MIN_ACTIVE_RATIO = 0.02
DEFAULT_MIN_RMS = 0.0015
DEFAULT_MIN_PEAK = 0.01
DEFAULT_MAX_CLIPPED_SAMPLE_RATIO = 0.05
MAX_MIX_CLIP_DELTA = 0
MAX_MUSIC_UNDERRUN_DELTA = 0
MAX_MUSIC_DROP_DELTA = 0


def _asset_provenance() -> dict[str, Any]:
    return {
        "sfx_source": "runtime-wad-ds-lumps",
        "music_source": "runtime-wad-mus-or-midi-lumps",
        "repo_shipped_audio_assets": False,
        "repo_shipped_wad_assets": False,
        "manifest_contains_asset_bytes": False,
        "raw_audio_uploaded": False,
        "notes": (
            "Doom SFX and MUS/MIDI bytes come from the selected WAD at runtime; "
            "the repo and this manifest do not ship or upload those assets."
        ),
    }


def _proof_contracts() -> dict[str, Any]:
    return {
        "os_audio_subsystem": {
            "lane": STATUS_ONLY_OS_AUDIO_SUBSYSTEM_LANE,
            "proves": (
                "status-only generic device/ring/stream/mixer coherence via "
                "adev=, pcm=, pcmbuf=, half=, musicpull=, and lane counters"
            ),
            "does_not_prove": (
                "Doom asset ownership, subjective listener quality, or "
                "kernel-owned MUS/MIDI synthesis"
            ),
        },
        "aggregate_audible_output": {
            "lane": AGGREGATE_AUDIBLE_OUTPUT_LANE,
            "proves": (
                "remote QEMU WAV backend produced non-silent output reduced to "
                "aggregate metrics and tied to SB16 continuity counters"
            ),
            "does_not_prove": (
                "subjective human-listened quality, mix balance, or polished music"
            ),
        },
        "human_listened_quality": {
            "lane": HUMAN_LISTENED_QUALITY_LANE,
            "status": "not-proven-by-this-manifest",
            "required_evidence": (
                "remote audio forwarding plus listener notes, without uploading "
                "captured Doom audio"
            ),
        },
        "music_legitimacy": {
            "lane": MUSIC_LEGITIMACY_LANE,
            "current_payload_owner": "doom_port/music.c",
            "current_service_command": "VIBE_AUDIO_MIXER_UPDATE",
            "current_os_contract": (
                "VIBE_AUDIO_STREAM_INFO plus musicstream=PULL, musicpull=, "
                "musicrend=, and musicpos="
            ),
            "future_legitimacy_step": (
                "first-class kernel-owned music ring or mixer/refill stream ABI"
            ),
        },
        "hardware_paced_playback": {
            "lane": FUTURE_HARDWARE_MIXER_REFILL_LANE,
            "current_proof": (
                "SB16 IRQ/refill timing and DMA/ring counters pace user-space "
                "chunk service"
            ),
            "not_yet_proven": (
                "hardware-paced mixer/refill playback owns music payload transfer "
                "without VIBE_AUDIO_MIXER_UPDATE"
            ),
        },
    }


def _status_fields(status: str) -> dict[str, str]:
    return parse_status_fields(status, error_type=AssertionError, require_any=False)


def _hex_value(fields: dict[str, str], name: str) -> int:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"status missing {name}= field")
    parsed = parse_hex8(value)
    if parsed is None:
        raise AssertionError(f"{name}= must be eight hex digits, got {value!r}")
    return parsed


def _hex_positive(fields: dict[str, str], name: str) -> int:
    parsed = _hex_value(fields, name)
    if parsed <= 0:
        raise AssertionError(f"{name}= must be nonzero in audible audio proof")
    return parsed


def _hex_tuple(fields: dict[str, str], name: str, count: int) -> tuple[int, ...]:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"status missing {name}= field")
    parts = value.split(":")
    if len(parts) != count:
        raise AssertionError(f"{name}= must have {count} colon-separated hex parts")
    for part in parts:
        if parse_hex8(part) is None:
            raise AssertionError(f"{name}= part must be eight hex digits, got {part!r}")
    return tuple(int(part, 16) for part in parts)


def _status_summary(status_path: Path) -> dict[str, str]:
    fields = _status_fields(status_path.read_text())
    if fields.get("audio") != "SB16":
        raise AssertionError(f"status audio=SB16 is required, got {fields.get('audio')!r}")
    if fields.get("gameplay") != "OK":
        raise AssertionError(f"status gameplay=OK is required, got {fields.get('gameplay')!r}")
    if fields.get("doomrun") not in ("RUN", "EXIT"):
        raise AssertionError(f"status doomrun=RUN or EXIT is required, got {fields.get('doomrun')!r}")
    for counter in ("doomsound", "audioirq", "refill", "sfxmix", "sfxsrc", "musicmix", "musicpos"):
        _hex_positive(fields, counter)
    _hex_positive(fields, "sfxsrc")
    for counter in ("musicbuf", "musicunder", "musicdrops"):
        _hex_value(fields, counter)
    _hex_positive(fields, "dma")
    _hex_value(fields, "sfxvoices")
    if _hex_value(fields, "ack8") + _hex_value(fields, "ack16") <= 0:
        raise AssertionError("status ack8= or ack16= must be nonzero")
    if _hex_tuple(fields, "sb16", 2)[0] == 0:
        raise AssertionError("status sb16= must expose a nonzero SB16 DSP major version")
    if _hex_tuple(fields, "play", 2)[0] == 0:
        raise AssertionError("status play= must prove SB16 playback was started")
    if _hex_tuple(fields, "voiceq", 3)[0] == 0:
        raise AssertionError("status voiceq= must prove at least one audio voice was queued")
    if _hex_tuple(fields, "sfxq", 4)[0] == 0:
        raise AssertionError("status sfxq= must prove at least one non-music Doom SFX was submitted")
    sfx_submit, sfx_output = _hex_tuple(fields, "sfxbytes", 2)
    if sfx_submit == 0 or sfx_output == 0:
        raise AssertionError("status sfxbytes= must prove submitted and output SFX PCM bytes")
    sfx_dma_mixes, sfx_dma_bytes = _hex_tuple(fields, "sfxdma", 2)
    if sfx_dma_mixes == 0 or sfx_dma_bytes == 0:
        raise AssertionError("status sfxdma= must prove SFX mixed during SB16 DMA refills")
    _, sfx_rate, sfx_length = _hex_tuple(fields, "sfxlast", 3)
    if sfx_rate == 0 or sfx_length == 0:
        raise AssertionError("status sfxlast= must expose a nonzero SFX sample rate and padded length")
    if _hex_tuple(fields, "musicq", 2)[0] == 0:
        raise AssertionError("status musicq= must prove the music voice was queued")
    musicrend = _hex_tuple(fields, "musicrend", 6)
    if musicrend[0] not in (1, 2):
        raise AssertionError("status musicrend= must record MUS or MIDI renderer format")
    for value, label in (
        (musicrend[1], "render chunk"),
        (musicrend[2], "note event"),
        (musicrend[3], "render event"),
        (musicrend[4], "active voice peak"),
        (musicrend[5], "rendered sample"),
    ):
        if value == 0:
            raise AssertionError(f"status musicrend= must prove nonzero {label} evidence")
    if fields.get("musicstream") not in check_audio_continuity_proof.MUSIC_STREAM_MODES:
        raise AssertionError(f"status musicstream= must be a known mode, got {fields.get('musicstream')!r}")
    _hex_tuple(fields, "musicpull", 2)
    adev_kind, adev_status, adev_caps = _hex_tuple(fields, "adev", 3)
    if adev_kind != 1 or adev_status != 1:
        raise AssertionError("status adev= must prove a ready generic SB16 audio device")
    if adev_caps & 0x0000000F != 0x0000000F:
        raise AssertionError("status adev= must include PCM ring, mixer, pull-stream, and SB16 DMA caps")
    pcm_format, channels, sample_rate = _hex_tuple(fields, "pcm", 3)
    if (pcm_format, channels, sample_rate) != (1, 2, 11025):
        raise AssertionError("status pcm= must prove unsigned 8-bit stereo at 11025 Hz")
    ring_bytes, period_bytes, write_offset, active_half = _hex_tuple(fields, "pcmbuf", 4)
    if ring_bytes == 0 or period_bytes == 0 or period_bytes * 2 != ring_bytes:
        raise AssertionError("status pcmbuf= must expose a two-period PCM ring")
    if write_offset >= ring_bytes or active_half not in (0, 1):
        raise AssertionError("status pcmbuf= must expose a valid write offset and active half")
    if active_half != _hex_value(fields, "half"):
        raise AssertionError("status pcmbuf= active half must match half= IRQ phase")
    return {
        "audio": fields["audio"],
        "doomrun": fields["doomrun"],
        "gameplay": fields["gameplay"],
        "doomsound": fields["doomsound"],
        "sb16": fields["sb16"],
        "dma": fields["dma"],
        "play": fields["play"],
        "voiceq": fields["voiceq"],
        "musicq": fields["musicq"],
        "audioirq": fields["audioirq"],
        "ack8": fields.get("ack8", "00000000"),
        "ack16": fields.get("ack16", "00000000"),
        "refill": fields["refill"],
        "half": fields["half"],
        "sfxmix": fields["sfxmix"],
        "sfxq": fields["sfxq"],
        "sfxbytes": fields["sfxbytes"],
        "sfxdma": fields["sfxdma"],
        "sfxsrc": fields["sfxsrc"],
        "sfxlast": fields["sfxlast"],
        "sfxvoices": fields["sfxvoices"],
        "musicmix": fields["musicmix"],
        "musicloop": fields.get("musicloop", "00000000"),
        "musicpos": fields["musicpos"],
        "musicbuf": fields["musicbuf"],
        "musicunder": fields["musicunder"],
        "musicdrops": fields["musicdrops"],
        "musicstream": fields["musicstream"],
        "musicpull": fields["musicpull"],
        "musicrend": fields["musicrend"],
        "adev": fields["adev"],
        "pcm": fields["pcm"],
        "pcmbuf": fields["pcmbuf"],
    }


def _counter_delta(first: dict[str, str], last: dict[str, str], name: str) -> dict[str, Any]:
    first_value = _hex_value(first, name)
    last_value = _hex_value(last, name)
    return {
        "start": first[name],
        "final": last[name],
        "delta": f"{last_value - first_value:08X}",
    }


def _tuple_counter_delta(
    first: dict[str, str],
    last: dict[str, str],
    name: str,
    count: int,
    index: int,
) -> dict[str, Any]:
    first_tuple = _hex_tuple(first, name, count)
    last_tuple = _hex_tuple(last, name, count)
    return {
        "start": f"{first_tuple[index]:08X}",
        "final": f"{last_tuple[index]:08X}",
        "delta": f"{last_tuple[index] - first_tuple[index]:08X}",
    }


def _continuity_summary(
    *,
    final_status: str,
    baseline_status: str,
    fire_status: str,
    movement_status: str,
    use_status: str,
    menu_status: str,
) -> dict[str, Any]:
    check_audio_continuity_proof.validate_status(
        final_status,
        baseline_status=baseline_status,
        fire_status=fire_status,
        movement_status=movement_status,
        use_status=use_status,
        menu_status=menu_status,
    )
    snapshot_texts = {
        "baseline": baseline_status,
        "fire": fire_status,
        "movement": movement_status,
        "use": use_status,
        "menu": menu_status,
        "final": final_status,
    }
    snapshot_fields = {label: _status_fields(text) for label, text in snapshot_texts.items()}
    baseline_fields = snapshot_fields["baseline"]
    final_fields = snapshot_fields["final"]
    progress = {
        name: _counter_delta(baseline_fields, final_fields, name)
        for name in ("doomsound", "audioirq", "refill", "sfxmix", "sfxsrc", "musicmix", "musicpos")
    }
    progress["sfxq_submit"] = _tuple_counter_delta(
        baseline_fields, final_fields, "sfxq", 4, 0
    )
    progress["sfxbytes_submit"] = _tuple_counter_delta(
        baseline_fields, final_fields, "sfxbytes", 2, 0
    )
    progress["sfxbytes_output"] = _tuple_counter_delta(
        baseline_fields, final_fields, "sfxbytes", 2, 1
    )
    progress["sfxdma_mix"] = _tuple_counter_delta(
        baseline_fields, final_fields, "sfxdma", 2, 0
    )
    progress["sfxdma_bytes"] = _tuple_counter_delta(
        baseline_fields, final_fields, "sfxdma", 2, 1
    )
    progress["voiceq_update"] = _tuple_counter_delta(
        baseline_fields, final_fields, "voiceq", 3, 2
    )
    progress["musicpull_request"] = _tuple_counter_delta(
        baseline_fields, final_fields, "musicpull", 2, 0
    )
    progress["musicpull_refill"] = _tuple_counter_delta(
        baseline_fields, final_fields, "musicpull", 2, 1
    )
    progress["musicrend_chunk"] = _tuple_counter_delta(
        baseline_fields, final_fields, "musicrend", 6, 1
    )
    progress["musicrend_note"] = _tuple_counter_delta(
        baseline_fields, final_fields, "musicrend", 6, 2
    )
    progress["musicrend_event"] = _tuple_counter_delta(
        baseline_fields, final_fields, "musicrend", 6, 3
    )
    progress["musicrend_sample"] = _tuple_counter_delta(
        baseline_fields, final_fields, "musicrend", 6, 5
    )
    safety_progress = {
        name: _counter_delta(baseline_fields, final_fields, name)
        for name in ("mixclip", "musicunder", "musicdrops")
    }
    fire_phase = {
        "baseline_snapshot": "baseline",
        "fire_snapshot": "fire",
        "requires_scripted_fire_sfx": True,
        "doomsound_delta": _counter_delta(
            baseline_fields,
            snapshot_fields["fire"],
            "doomsound",
        )["delta"],
        "sfxmix_delta": _counter_delta(
            baseline_fields,
            snapshot_fields["fire"],
            "sfxmix",
        )["delta"],
        "sfxsrc_delta": _counter_delta(
            baseline_fields,
            snapshot_fields["fire"],
            "sfxsrc",
        )["delta"],
        "sfxsubmit_delta": _tuple_counter_delta(
            baseline_fields,
            snapshot_fields["fire"],
            "sfxq",
            4,
            0,
        )["delta"],
        "sfxoutput_delta": _tuple_counter_delta(
            baseline_fields,
            snapshot_fields["fire"],
            "sfxbytes",
            2,
            1,
        )["delta"],
        "sfxdma_delta": _tuple_counter_delta(
            baseline_fields,
            snapshot_fields["fire"],
            "sfxdma",
            2,
            1,
        )["delta"],
        "musicmix_delta": _counter_delta(
            baseline_fields,
            snapshot_fields["fire"],
            "musicmix",
        )["delta"],
        "claim": (
            "scripted fire must advance Doom sound calls and non-music SFX "
            "mixing, not music alone"
        ),
    }
    ordered_fields = [
        snapshot_fields[label]
        for label in ("baseline", "fire", "movement", "use", "menu", "final")
    ]
    ordered_snapshots = [
        (label, snapshot_fields[label])
        for label in ("baseline", "fire", "movement", "use", "menu", "final")
    ]
    music_buffers = [_hex_value(fields, "musicbuf") for fields in ordered_fields]
    pull_pairs = [_hex_tuple(fields, "musicpull", 2) for fields in ordered_fields]
    pull_pending = [max(0, request - refill) for request, refill in pull_pairs]
    uses_pull_stream = any(fields["musicstream"] == "PULL" for fields in ordered_fields)
    stream_update_progress = (
        progress["musicpull_refill"] if uses_pull_stream else progress["voiceq_update"]
    )
    update_delta = int(stream_update_progress["delta"], 16)
    position_delta = int(progress["musicpos"]["delta"], 16)
    rendered_sample_delta = int(progress["musicrend_sample"]["delta"], 16)
    voice_update_delta = int(progress["voiceq_update"]["delta"], 16)
    pull_request_delta = int(progress["musicpull_request"]["delta"], 16)
    pull_refill_delta = int(progress["musicpull_refill"]["delta"], 16)
    render_chunk_delta = int(progress["musicrend_chunk"]["delta"], 16)
    initial_buffer = music_buffers[0]
    final_buffer = music_buffers[-1]
    rendered_plus_initial_buffer = rendered_sample_delta + initial_buffer
    consumed_plus_final_buffer = position_delta + final_buffer
    stream_health = {
        "buffer_initial": f"{initial_buffer:08X}",
        "buffer_floor": f"{min(music_buffers):08X}",
        "buffer_peak": f"{max(music_buffers):08X}",
        "buffer_final": final_fields["musicbuf"],
        "buffered_window_snapshots": sum(1 for value in music_buffers if value > 0),
        "distinct_buffer_windows": len(set(music_buffers)),
        "under_delta": _counter_delta(baseline_fields, final_fields, "musicunder")["delta"],
        "drop_delta": _counter_delta(baseline_fields, final_fields, "musicdrops")["delta"],
        "stream_update_counter": "musicpull_refill" if uses_pull_stream else "voiceq_update",
        "stream_update_delta": stream_update_progress["delta"],
        "voiceq_update_delta": progress["voiceq_update"]["delta"],
        "pull_request_delta": progress["musicpull_request"]["delta"],
        "pull_refill_delta": progress["musicpull_refill"]["delta"],
        "pull_pending_peak": f"{max(pull_pending):08X}",
        "pull_pending_final": f"{pull_pending[-1]:08X}",
        "position_delta": progress["musicpos"]["delta"],
        "position_delta_per_update_floor": f"{(position_delta // update_delta) if update_delta else 0:08X}",
        "rendered_sample_delta": progress["musicrend_sample"]["delta"],
        "rendered_plus_initial_buffer": f"{rendered_plus_initial_buffer:08X}",
        "consumed_plus_final_buffer": f"{consumed_plus_final_buffer:08X}",
        "rendered_sample_covers_position": (
            rendered_plus_initial_buffer >= consumed_plus_final_buffer
        ),
        "sequenced_refill_service": (
            not uses_pull_stream
            or (
                pull_request_delta == pull_refill_delta
                and pull_refill_delta == voice_update_delta
                and pull_refill_delta == render_chunk_delta
                and max(pull_pending) <= check_audio_continuity_proof.MAX_PENDING_PULL_REQUESTS
            )
        ),
    }
    service_sequence = {
        "refill_counter": "musicpull_refill" if uses_pull_stream else "voiceq_update",
        "request_delta": progress["musicpull_request"]["delta"],
        "refill_delta": progress["musicpull_refill"]["delta"],
        "voiceq_update_delta": progress["voiceq_update"]["delta"],
        "renderer_chunk_delta": progress["musicrend_chunk"]["delta"],
        "max_pending_pull_requests": f"{check_audio_continuity_proof.MAX_PENDING_PULL_REQUESTS:08X}",
        "pull_pending_peak": stream_health["pull_pending_peak"],
        "pull_pending_final": stream_health["pull_pending_final"],
        "refill_matches_request": (
            not uses_pull_stream or pull_refill_delta == pull_request_delta
        ),
        "voice_update_matches_refill": (
            not uses_pull_stream or voice_update_delta == pull_refill_delta
        ),
        "render_chunk_matches_refill": (
            not uses_pull_stream or render_chunk_delta == pull_refill_delta
        ),
    }
    mixer_safety = {
        "mixclip_delta": safety_progress["mixclip"]["delta"],
        "musicunder_delta": safety_progress["musicunder"]["delta"],
        "musicdrop_delta": safety_progress["musicdrops"]["delta"],
        "max_mixclip_delta": f"{MAX_MIX_CLIP_DELTA:08X}",
        "max_musicunder_delta": f"{MAX_MUSIC_UNDERRUN_DELTA:08X}",
        "max_musicdrop_delta": f"{MAX_MUSIC_DROP_DELTA:08X}",
        "clip_free": int(safety_progress["mixclip"]["delta"], 16) <= MAX_MIX_CLIP_DELTA,
        "underrun_free": int(safety_progress["musicunder"]["delta"], 16) <= MAX_MUSIC_UNDERRUN_DELTA,
        "drop_free": int(safety_progress["musicdrops"]["delta"], 16) <= MAX_MUSIC_DROP_DELTA,
    }
    stream_contract = {
        "mode": final_fields["musicstream"],
        "status_field": "musicstream",
        "pull_counters": final_fields["musicpull"],
        "hardware_paced": final_fields["musicstream"] == "PULL",
        "current_push_proof": final_fields["musicstream"] == "PUSH",
        "current_payload_owner": "doom_port/music.c",
        "current_service_command": "VIBE_AUDIO_MIXER_UPDATE",
        "future_legitimacy_step": "first-class kernel-owned music ring or mixer/refill stream ABI",
        "os_surfaces": {
            "device": "VIBE_AUDIO_DEVICE_INFO",
            "ring": "VIBE_AUDIO_PCM_RING_INFO",
            "stream": "VIBE_AUDIO_STREAM_INFO",
            "mixer": "VIBE_AUDIO_MIXER_START/UPDATE/STOP/IS_PLAYING",
        },
        "service_sequence": service_sequence,
        "claim": (
            "the reusable OS audio device/ring/stream/mixer contract proves "
            "kernel SB16 refill requests paced music chunk service; "
            "voiceq= still records the port-rendered buffer submissions and does not claim "
            "kernel-owned MUS synthesis or future hardware-paced mixer/refill playback"
        ),
    }
    renderer_contract = {
        "status_counter": "musicrend",
        "parser_owner": "doom_port/music.c",
        "mus_score_end_event_type": check_audio_continuity_proof.MUS_SCORE_END_EVENT_TYPE,
        "mus_reserved_event_type_rejected": check_audio_continuity_proof.MUS_RESERVED_EVENT_TYPE,
        "mus_max_variable_delay_bytes": check_audio_continuity_proof.MUS_MAX_VARIABLE_DELAY_BYTES,
        "mus_variable_delay_requires_terminator": True,
        "mus_grouped_event_fixture": True,
        "claim": (
            "musicrend= proves parsed renderer activity in status; host renderer "
            "tests separately pin real MUS score-end parsing, grouped event "
            "handling, and strict variable-delay termination so event type 5 "
            "or a truncated delay cannot pass as a fixture-only shortcut"
        ),
    }
    return {
        "gate": "tools/check_audio_continuity_proof.py",
        "snapshots": ["baseline", "fire", "movement", "use", "menu", "final"],
        "sb16_continuity": True,
        "doomsound_progress": int(progress["doomsound"]["delta"], 16) > 0,
        "non_music_sfx_progress": int(progress["sfxmix"]["delta"], 16) > 0,
        "music_stream_progress": int(progress["musicmix"]["delta"], 16) > 0,
        "music_position_progress": int(progress["musicpos"]["delta"], 16) > 0,
        "music_stream_update_progress": int(stream_update_progress["delta"], 16) > 0,
        "irq_refill_progress": (
            int(progress["audioirq"]["delta"], 16) > 0
            and int(progress["refill"]["delta"], 16) > 0
        ),
        "mix_lanes": {
            "non_music_sfx": {
                "counter": "sfxmix",
                "delta": progress["sfxmix"]["delta"],
                "source_counter": "sfxsrc",
                "source_delta": progress["sfxsrc"]["delta"],
                "submit_counter": "sfxq[0]",
                "submit_delta": progress["sfxq_submit"]["delta"],
                "submit_bytes_delta": progress["sfxbytes_submit"]["delta"],
                "output_bytes_delta": progress["sfxbytes_output"]["delta"],
                "dma_counter": "sfxdma",
                "dma_mix_delta": progress["sfxdma_mix"]["delta"],
                "dma_bytes_delta": progress["sfxdma_bytes"]["delta"],
                "active_voice_snapshots": sum(
                    1 for fields in snapshot_fields.values() if _hex_value(fields, "sfxvoices") > 0
                ),
            },
            "music": {
                "counter": "musicmix",
                "delta": progress["musicmix"]["delta"],
                "renderer_counter": "musicrend",
                "renderer_chunk_delta": progress["musicrend_chunk"]["delta"],
                "renderer_note_delta": progress["musicrend_note"]["delta"],
                "renderer_event_delta": progress["musicrend_event"]["delta"],
                "renderer_sample_delta": progress["musicrend_sample"]["delta"],
                "renderer_final": final_fields["musicrend"],
                "active_voice_snapshots": sum(
                    1 for fields in snapshot_fields.values() if _hex_value(fields, "musicvoices") > 0
                ),
                "buffered_window_snapshots": sum(
                    1 for fields in snapshot_fields.values() if _hex_value(fields, "musicbuf") > 0
                ),
                "stream_update_delta": stream_update_progress["delta"],
                "position_delta": progress["musicpos"]["delta"],
            },
            "shared_sb16_refill": {
                "irq_delta": progress["audioirq"]["delta"],
                "refill_delta": progress["refill"]["delta"],
            },
        },
        "stream_health": stream_health,
        "stream_contract": stream_contract,
        "os_audio_contract": check_audio_continuity_proof.build_os_audio_contract(ordered_snapshots),
        "renderer_contract": renderer_contract,
        "mixer_safety": mixer_safety,
        "playability_cadence": check_audio_continuity_proof.build_playability_cadence(ordered_snapshots),
        "scripted_phase_proof": fire_phase,
        "progress": progress,
        "claim": (
            "non-silent remote QEMU output plus status-only SB16 continuity; "
            "music chunks are advanced by a kernel-visible stream-position contract, "
            "musicstream= names whether that proof is PUSH or PULL, "
            "aggregate listener-quality metadata is machine checked, but subjective "
            "human-listened quality and future hardware-paced mixer/refill playback "
            "are still unproven"
        ),
    }


def _read_required(path: Path, label: str) -> str:
    try:
        return path.read_text()
    except OSError as exc:
        raise AssertionError(f"cannot read {label} status snapshot {path}: {exc}") from exc


def _iter_normalized_samples(data: bytes, sample_width: int):
    if sample_width == 1:
        for byte in data:
            yield (byte - 128) / 128.0
        return
    if sample_width == 2:
        count = len(data) // 2
        for (sample,) in struct.iter_unpack("<h", data[: count * 2]):
            yield sample / 32768.0
        return
    if sample_width == 4:
        count = len(data) // 4
        for (sample,) in struct.iter_unpack("<i", data[: count * 4]):
            yield sample / 2147483648.0
        return
    raise AssertionError(f"unsupported WAV sample width: {sample_width} bytes")


def analyze_wav(
    wav_path: Path,
    status_path: Path,
    *,
    baseline_status_path: Path,
    fire_status_path: Path,
    movement_status_path: Path,
    use_status_path: Path,
    menu_status_path: Path,
    window_ms: int = DEFAULT_WINDOW_MS,
    min_active_rms: float = DEFAULT_MIN_RMS,
) -> dict[str, Any]:
    """Analyze a temporary remote WAV and return aggregate metrics only."""

    if window_ms <= 0:
        raise AssertionError("window_ms must be positive")
    if min_active_rms <= 0:
        raise AssertionError("min_active_rms must be positive")

    final_status_text = _read_required(status_path, "final")
    continuity = _continuity_summary(
        final_status=final_status_text,
        baseline_status=_read_required(baseline_status_path, "baseline"),
        fire_status=_read_required(fire_status_path, "fire"),
        movement_status=_read_required(movement_status_path, "movement"),
        use_status=_read_required(use_status_path, "use"),
        menu_status=_read_required(menu_status_path, "menu"),
    )

    with wave.open(str(wav_path), "rb") as wav:
        channels = wav.getnchannels()
        sample_rate = wav.getframerate()
        sample_width = wav.getsampwidth()
        total_frames = wav.getnframes()
        compression = wav.getcomptype()
        if compression != "NONE":
            raise AssertionError(f"compressed WAV is not supported: {compression}")
        if channels <= 0:
            raise AssertionError("WAV must have at least one channel")
        if sample_rate <= 0:
            raise AssertionError("WAV sample rate must be positive")
        if total_frames <= 0:
            raise AssertionError("WAV has no frames")

        frames_per_window = max(1, sample_rate * window_ms // 1000)
        bytes_per_frame = channels * sample_width
        total_windows = 0
        active_windows = 0
        first_active_window: int | None = None
        last_active_window: int | None = None
        max_window_rms = 0.0
        sum_window_rms = 0.0
        sum_active_rms = 0.0
        peak_abs = 0.0
        clipped_samples = 0
        sample_count = 0
        zero_crossings = 0
        previous_sign = 0

        while True:
            chunk = wav.readframes(frames_per_window)
            if not chunk:
                break
            samples = list(_iter_normalized_samples(chunk, sample_width))
            if not samples:
                break
            sample_count += len(samples)
            total_windows += 1
            sum_squares = 0.0
            for sample in samples:
                abs_sample = abs(sample)
                if abs_sample > peak_abs:
                    peak_abs = abs_sample
                if abs_sample >= 0.999:
                    clipped_samples += 1
                sum_squares += sample * sample
                sign = 1 if sample > 0 else -1 if sample < 0 else 0
                if sign and previous_sign and sign != previous_sign:
                    zero_crossings += 1
                if sign:
                    previous_sign = sign
            rms = (sum_squares / len(samples)) ** 0.5
            sum_window_rms += rms
            max_window_rms = max(max_window_rms, rms)
            if rms >= min_active_rms:
                if first_active_window is None:
                    first_active_window = total_windows - 1
                last_active_window = total_windows - 1
                active_windows += 1
                sum_active_rms += rms

    duration_ms = round(total_frames * 1000 / sample_rate)
    active_ratio = active_windows / total_windows if total_windows else 0.0
    mean_window_rms = sum_window_rms / total_windows if total_windows else 0.0
    mean_active_rms = sum_active_rms / active_windows if active_windows else 0.0
    active_span_windows = (
        0
        if first_active_window is None or last_active_window is None
        else last_active_window - first_active_window + 1
    )
    leading_inactive_windows = first_active_window if first_active_window is not None else total_windows
    trailing_inactive_windows = (
        total_windows - last_active_window - 1 if last_active_window is not None else total_windows
    )
    duration_seconds = total_frames / sample_rate if sample_rate else 0.0
    clipped_ratio = clipped_samples / sample_count if sample_count else 0.0
    machine_audible = (
        duration_ms >= DEFAULT_MIN_DURATION_MS
        and active_windows >= DEFAULT_MIN_ACTIVE_WINDOWS
        and active_ratio >= DEFAULT_MIN_ACTIVE_RATIO
        and peak_abs >= DEFAULT_MIN_PEAK
        and clipped_ratio <= DEFAULT_MAX_CLIPPED_SAMPLE_RATIO
    )

    return {
        "schema": SCHEMA,
        "source": "qemu-wav-temporary",
        "format": {
            "sample_rate": sample_rate,
            "channels": channels,
            "sample_width_bytes": sample_width,
            "frames": total_frames,
            "duration_ms": duration_ms,
            "window_ms": window_ms,
        },
        "analysis": {
            "total_windows": total_windows,
            "active_windows": active_windows,
            "active_window_ratio": round(active_ratio, 6),
            "first_active_window": first_active_window,
            "last_active_window": last_active_window,
            "max_window_rms_norm": round(max_window_rms, 6),
            "mean_window_rms_norm": round(mean_window_rms, 6),
            "mean_active_rms_norm": round(mean_active_rms, 6),
            "peak_abs_norm": round(peak_abs, 6),
            "zero_crossings": zero_crossings,
            "active_rms_threshold_norm": min_active_rms,
        },
        "quality": {
            "active_span_ms": active_span_windows * window_ms,
            "active_span_windows": active_span_windows,
            "leading_inactive_windows": leading_inactive_windows,
            "trailing_inactive_windows": trailing_inactive_windows,
            "clipped_sample_ratio": round(clipped_ratio, 6),
            "crest_factor_peak_over_mean_rms": round(
                peak_abs / mean_window_rms if mean_window_rms else 0.0,
                6,
            ),
            "zero_crossing_rate_per_sec": round(
                zero_crossings / duration_seconds if duration_seconds else 0.0,
                3,
            ),
        },
        "listener_quality": {
            "mode": "aggregate-metrics-no-human-listener",
            "quality_floor": "machine-audible" if machine_audible else "below-threshold",
            "subjective_listener_approved": False,
            "requires_remote_listener_notes": True,
            "machine_audible": machine_audible,
            "thresholds": {
                "min_duration_ms": DEFAULT_MIN_DURATION_MS,
                "min_active_windows": DEFAULT_MIN_ACTIVE_WINDOWS,
                "min_active_ratio": DEFAULT_MIN_ACTIVE_RATIO,
                "min_peak_abs_norm": DEFAULT_MIN_PEAK,
                "max_clipped_sample_ratio": DEFAULT_MAX_CLIPPED_SAMPLE_RATIO,
                "max_mixclip_delta": MAX_MIX_CLIP_DELTA,
                "max_musicunder_delta": MAX_MUSIC_UNDERRUN_DELTA,
                "max_musicdrop_delta": MAX_MUSIC_DROP_DELTA,
            },
            "notes": (
                "This proof validates aggregate machine-audible output and SB16 "
                "continuity only; VNC does not carry audio by default, and this "
                "is not a human listening pass or a future hardware-paced mixer/refill "
                "playback proof."
            ),
        },
        "proof_contracts": _proof_contracts(),
        "status": _status_summary(status_path),
        "continuity": continuity,
        "asset_provenance": _asset_provenance(),
        "artifact_policy": {
            "contains_raw_audio": False,
            "contains_wad_data": False,
            "contains_pixels": False,
            "upload_only_aggregate_json": True,
            "raw_audio_upload_allowed": False,
            "temporary_wav_deleted_before_upload": True,
            "vnc_carries_audio_by_default": False,
            "audible_evidence": "aggregate-cloud-output-status",
        },
    }


def _reject_forbidden_manifest_payload(value: Any, path: str = "$") -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            lowered = str(key).lower()
            if lowered in FORBIDDEN_MANIFEST_KEYS:
                if not (path == "$.status" and lowered == "pcm"):
                    raise AssertionError(f"manifest contains forbidden raw-audio key at {path}.{key}")
            _reject_forbidden_manifest_payload(child, f"{path}.{key}")
    elif isinstance(value, list):
        if len(value) > 64:
            raise AssertionError(f"manifest list at {path} is too large for aggregate proof")
        for index, child in enumerate(value):
            _reject_forbidden_manifest_payload(child, f"{path}[{index}]")
    elif isinstance(value, str) and len(value) > 512:
        raise AssertionError(f"manifest string at {path} is too large for aggregate proof")


def validate_manifest(
    manifest: dict[str, Any],
    *,
    min_duration_ms: int = DEFAULT_MIN_DURATION_MS,
    min_active_windows: int = DEFAULT_MIN_ACTIVE_WINDOWS,
    min_active_ratio: float = DEFAULT_MIN_ACTIVE_RATIO,
    min_peak_abs: float = DEFAULT_MIN_PEAK,
) -> None:
    _reject_forbidden_manifest_payload(manifest)
    if manifest.get("schema") != SCHEMA:
        raise AssertionError(f"manifest schema must be {SCHEMA!r}")
    if manifest.get("source") != "qemu-wav-temporary":
        raise AssertionError("manifest source must be qemu-wav-temporary")

    fmt = manifest.get("format")
    analysis = manifest.get("analysis")
    quality = manifest.get("quality")
    listener_quality = manifest.get("listener_quality")
    proof_contracts = manifest.get("proof_contracts")
    status = manifest.get("status")
    continuity = manifest.get("continuity")
    asset_provenance = manifest.get("asset_provenance")
    policy = manifest.get("artifact_policy")
    if not isinstance(fmt, dict) or not isinstance(analysis, dict):
        raise AssertionError("manifest must contain format and analysis objects")
    if not isinstance(quality, dict):
        raise AssertionError("manifest must contain quality object")
    if not isinstance(listener_quality, dict):
        raise AssertionError("manifest must contain listener_quality object")
    if not isinstance(status, dict) or not isinstance(continuity, dict) or not isinstance(policy, dict):
        raise AssertionError("manifest must contain status, continuity, and artifact_policy objects")
    if not isinstance(asset_provenance, dict):
        raise AssertionError("manifest must contain asset_provenance object")

    if fmt.get("duration_ms", 0) < min_duration_ms:
        raise AssertionError("captured audio duration is too short for audible proof")
    if analysis.get("active_windows", 0) < min_active_windows:
        raise AssertionError("not enough active audio windows for audible proof")
    if analysis.get("active_window_ratio", 0.0) < min_active_ratio:
        raise AssertionError("active audio ratio is too low for audible proof")
    if analysis.get("peak_abs_norm", 0.0) < min_peak_abs:
        raise AssertionError("audio peak is too low for audible proof")
    if analysis.get("max_window_rms_norm", 0.0) <= 0:
        raise AssertionError("max window RMS must be nonzero")
    if analysis.get("zero_crossings", 0) <= 0:
        raise AssertionError("zero crossings must be nonzero")

    for key in ("active_span_ms", "active_span_windows", "leading_inactive_windows", "trailing_inactive_windows"):
        if not isinstance(quality.get(key), int):
            raise AssertionError(f"manifest quality.{key} must be an integer")
        if quality[key] < 0:
            raise AssertionError(f"manifest quality.{key} cannot be negative")
    if quality["active_span_ms"] <= 0 or quality["active_span_windows"] <= 0:
        raise AssertionError("manifest quality active span must be nonzero")
    for key in ("clipped_sample_ratio", "crest_factor_peak_over_mean_rms", "zero_crossing_rate_per_sec"):
        if not isinstance(quality.get(key), (int, float)):
            raise AssertionError(f"manifest quality.{key} must be numeric")
    if quality["clipped_sample_ratio"] < 0 or quality["clipped_sample_ratio"] > DEFAULT_MAX_CLIPPED_SAMPLE_RATIO:
        raise AssertionError("manifest quality clipped sample ratio is outside proof bounds")
    if quality["crest_factor_peak_over_mean_rms"] <= 0:
        raise AssertionError("manifest quality crest factor must be nonzero")
    if quality["zero_crossing_rate_per_sec"] <= 0:
        raise AssertionError("manifest quality zero crossing rate must be nonzero")

    if listener_quality.get("mode") != "aggregate-metrics-no-human-listener":
        raise AssertionError("manifest listener_quality.mode must be aggregate-metrics-no-human-listener")
    if listener_quality.get("quality_floor") != "machine-audible":
        raise AssertionError("manifest listener_quality.quality_floor must be machine-audible")
    if listener_quality.get("subjective_listener_approved") is not False:
        raise AssertionError("manifest listener_quality must not claim subjective listener approval")
    if listener_quality.get("requires_remote_listener_notes") is not True:
        raise AssertionError("manifest listener_quality must require remote listener notes")
    if listener_quality.get("machine_audible") is not True:
        raise AssertionError("manifest listener_quality.machine_audible must be true")
    thresholds = listener_quality.get("thresholds")
    if not isinstance(thresholds, dict):
        raise AssertionError("manifest listener_quality.thresholds must be an object")
    expected_thresholds = {
        "min_duration_ms": DEFAULT_MIN_DURATION_MS,
        "min_active_windows": DEFAULT_MIN_ACTIVE_WINDOWS,
        "min_active_ratio": DEFAULT_MIN_ACTIVE_RATIO,
        "min_peak_abs_norm": DEFAULT_MIN_PEAK,
        "max_clipped_sample_ratio": DEFAULT_MAX_CLIPPED_SAMPLE_RATIO,
        "max_mixclip_delta": MAX_MIX_CLIP_DELTA,
        "max_musicunder_delta": MAX_MUSIC_UNDERRUN_DELTA,
        "max_musicdrop_delta": MAX_MUSIC_DROP_DELTA,
    }
    for key, expected in expected_thresholds.items():
        if thresholds.get(key) != expected:
            raise AssertionError(f"manifest listener_quality.thresholds.{key} must be {expected!r}")
    notes = listener_quality.get("notes")
    if not isinstance(notes, str) or "not a human listening pass" not in notes:
        raise AssertionError("manifest listener_quality.notes must state that this is not a human listening pass")
    if "VNC does not carry audio by default" not in notes:
        raise AssertionError("manifest listener_quality.notes must state that VNC does not carry audio by default")
    if proof_contracts is not None:
        _validate_proof_contracts(proof_contracts)

    expected_provenance = _asset_provenance()
    for key, expected in expected_provenance.items():
        value = asset_provenance.get(key)
        if value != expected:
            raise AssertionError(f"manifest asset_provenance.{key} must be {expected!r}")

    if status.get("audio") != "SB16":
        raise AssertionError("manifest status.audio must be SB16")
    if status.get("gameplay") != "OK":
        raise AssertionError("manifest status.gameplay must be OK")
    if status.get("doomrun") not in ("RUN", "EXIT"):
        raise AssertionError("manifest status.doomrun must be RUN or EXIT")
    for counter in ("doomsound", "audioirq", "refill", "sfxmix", "musicmix", "musicpos"):
        value = status.get(counter)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest status.{counter} must be eight hex digits")
        if int(value, 16) <= 0:
            raise AssertionError(f"manifest status.{counter} must be nonzero")
    for counter in ("dma", "half", "sfxvoices", "musicbuf", "musicunder", "musicdrops"):
        value = status.get(counter)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest status.{counter} must be eight hex digits")
    if int(status["dma"], 16) <= 0:
        raise AssertionError("manifest status.dma must be nonzero")
    if status.get("musicstream") not in check_audio_continuity_proof.MUSIC_STREAM_MODES:
        raise AssertionError("manifest status.musicstream must be a known music stream mode")
    for name, count in (
        ("sb16", 2),
        ("play", 2),
        ("voiceq", 3),
        ("sfxq", 4),
        ("sfxbytes", 2),
        ("sfxdma", 2),
        ("sfxlast", 3),
        ("musicq", 2),
        ("musicpull", 2),
        ("musicrend", 6),
        ("adev", 3),
        ("pcm", 3),
        ("pcmbuf", 4),
    ):
        value = status.get(name)
        if not isinstance(value, str):
            raise AssertionError(f"manifest status.{name} must be present")
        parts = value.split(":")
        if len(parts) != count or any(not re.fullmatch(r"[0-9A-Fa-f]{8}", part) for part in parts):
            raise AssertionError(f"manifest status.{name} must have {count} colon-separated hex parts")
        if name != "musicpull" and int(parts[0], 16) <= 0:
            raise AssertionError(f"manifest status.{name} first counter must be nonzero")
        if name in ("sfxbytes", "sfxdma", "sfxlast") and int(parts[1], 16) <= 0:
            raise AssertionError(f"manifest status.{name} second counter must be nonzero")
    if status["adev"] != "00000001:00000001:0000000F":
        raise AssertionError("manifest status.adev must prove the generic SB16 audio device contract")
    if status["pcm"] != "00000001:00000002:00002B11":
        raise AssertionError("manifest status.pcm must prove unsigned 8-bit stereo at 11025 Hz")
    ring_bytes, period_bytes, write_offset, active_half = (
        int(part, 16) for part in status["pcmbuf"].split(":")
    )
    if ring_bytes == 0 or period_bytes * 2 != ring_bytes:
        raise AssertionError("manifest status.pcmbuf must expose a two-period PCM ring")
    if write_offset >= ring_bytes or active_half not in (0, 1):
        raise AssertionError("manifest status.pcmbuf must expose a valid write offset and active half")
    if active_half != int(status["half"], 16):
        raise AssertionError("manifest status.pcmbuf active half must match status.half")

    if continuity.get("gate") != "tools/check_audio_continuity_proof.py":
        raise AssertionError("manifest continuity.gate must name the audio continuity checker")
    for key in (
        "sb16_continuity",
        "doomsound_progress",
        "non_music_sfx_progress",
        "music_stream_progress",
        "music_position_progress",
        "music_stream_update_progress",
        "irq_refill_progress",
    ):
        if continuity.get(key) is not True:
            raise AssertionError(f"manifest continuity.{key} must be true")
    progress = continuity.get("progress")
    if not isinstance(progress, dict):
        raise AssertionError("manifest continuity.progress must be an object")
    for name in (
        "doomsound",
        "audioirq",
        "refill",
        "sfxmix",
        "sfxsrc",
        "sfxq_submit",
        "sfxbytes_submit",
        "sfxbytes_output",
        "sfxdma_mix",
        "sfxdma_bytes",
        "musicmix",
        "musicpos",
        "voiceq_update",
        "musicpull_request",
        "musicpull_refill",
        "musicrend_chunk",
        "musicrend_note",
        "musicrend_event",
        "musicrend_sample",
    ):
        entry = progress.get(name)
        if not isinstance(entry, dict):
            raise AssertionError(f"manifest continuity.progress.{name} must be an object")
        for key in ("start", "final", "delta"):
            value = entry.get(key)
            if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
                raise AssertionError(f"manifest continuity.progress.{name}.{key} must be eight hex digits")
        if (
            int(entry["delta"], 16) <= 0
            and not (name.startswith("musicpull_") and status.get("musicstream") != "PULL")
        ):
            raise AssertionError(f"manifest continuity.progress.{name}.delta must be nonzero")
    for name, minimum in check_audio_continuity_proof.MIN_PHASED_PROGRESS.items():
        if int(progress[name]["delta"], 16) < minimum:
            raise AssertionError(f"manifest continuity.progress.{name}.delta must be at least {minimum:08X}")
    if int(progress["voiceq_update"]["delta"], 16) < check_audio_continuity_proof.MIN_MUSIC_STREAM_UPDATE_DELTA:
        raise AssertionError("manifest continuity.progress.voiceq_update.delta is below stream proof threshold")

    mix_lanes = continuity.get("mix_lanes")
    if not isinstance(mix_lanes, dict):
        raise AssertionError("manifest continuity.mix_lanes must be an object")
    stream_health = continuity.get("stream_health")
    if not isinstance(stream_health, dict):
        raise AssertionError("manifest continuity.stream_health must be an object")
    stream_contract = continuity.get("stream_contract")
    if not isinstance(stream_contract, dict):
        raise AssertionError("manifest continuity.stream_contract must be an object")
    os_audio_contract = continuity.get("os_audio_contract")
    if not isinstance(os_audio_contract, dict):
        raise AssertionError("manifest continuity.os_audio_contract must be an object")
    playability_cadence = continuity.get("playability_cadence")
    if playability_cadence is not None and not isinstance(playability_cadence, dict):
        raise AssertionError("manifest continuity.playability_cadence must be an object when present")
    renderer_contract = continuity.get("renderer_contract")
    if renderer_contract is not None and not isinstance(renderer_contract, dict):
        raise AssertionError("manifest continuity.renderer_contract must be an object when present")
    mixer_safety = continuity.get("mixer_safety")
    if not isinstance(mixer_safety, dict):
        raise AssertionError("manifest continuity.mixer_safety must be an object")
    scripted_phase_proof = continuity.get("scripted_phase_proof")
    if not isinstance(scripted_phase_proof, dict):
        raise AssertionError("manifest continuity.scripted_phase_proof must be an object")
    for lane_name in ("non_music_sfx", "music", "shared_sb16_refill"):
        if not isinstance(mix_lanes.get(lane_name), dict):
            raise AssertionError(f"manifest continuity.mix_lanes.{lane_name} must be an object")
    sfx_lane = mix_lanes["non_music_sfx"]
    music_lane = mix_lanes["music"]
    refill_lane = mix_lanes["shared_sb16_refill"]
    if sfx_lane.get("counter") != "sfxmix":
        raise AssertionError("manifest non_music_sfx lane must name sfxmix")
    if music_lane.get("counter") != "musicmix":
        raise AssertionError("manifest music lane must name musicmix")
    for lane_name, lane, keys in (
        (
            "non_music_sfx",
            sfx_lane,
            (
                "delta",
                "source_delta",
                "submit_delta",
                "submit_bytes_delta",
                "output_bytes_delta",
                "dma_mix_delta",
                "dma_bytes_delta",
            ),
        ),
        (
            "music",
            music_lane,
            (
                "delta",
                "stream_update_delta",
                "position_delta",
                "renderer_chunk_delta",
                "renderer_note_delta",
                "renderer_event_delta",
                "renderer_sample_delta",
            ),
        ),
        ("shared_sb16_refill", refill_lane, ("irq_delta", "refill_delta")),
    ):
        for key in keys:
            value = lane.get(key)
            if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
                raise AssertionError(f"manifest continuity.mix_lanes.{lane_name}.{key} must be eight hex digits")
            if int(value, 16) <= 0:
                raise AssertionError(f"manifest continuity.mix_lanes.{lane_name}.{key} must be nonzero")
    if not isinstance(sfx_lane.get("active_voice_snapshots"), int):
        raise AssertionError("manifest non_music_sfx lane active voice snapshots must be an integer")
    if sfx_lane.get("dma_counter") != "sfxdma":
        raise AssertionError("manifest non_music_sfx lane must name sfxdma as dma_counter")
    if sfx_lane["active_voice_snapshots"] < 0:
        raise AssertionError("manifest non_music_sfx lane active voice snapshots cannot be negative")
    if music_lane.get("active_voice_snapshots", 0) <= 0:
        raise AssertionError("manifest music lane must have active voice snapshots")
    if music_lane.get("buffered_window_snapshots", 0) <= 0:
        raise AssertionError("manifest music lane must have buffered window snapshots")
    if music_lane.get("renderer_counter") != "musicrend":
        raise AssertionError("manifest music lane must name musicrend as renderer_counter")
    renderer_final = music_lane.get("renderer_final")
    if not isinstance(renderer_final, str):
        raise AssertionError("manifest music lane must include renderer_final")
    renderer_parts = renderer_final.split(":")
    if len(renderer_parts) != 6 or any(
        not re.fullmatch(r"[0-9A-Fa-f]{8}", part) for part in renderer_parts
    ):
        raise AssertionError("manifest music lane renderer_final must have six hex parts")
    if int(renderer_parts[0], 16) not in (1, 2):
        raise AssertionError("manifest music lane renderer_final must record MUS or MIDI format")
    for part in renderer_parts[1:]:
        if int(part, 16) <= 0:
            raise AssertionError("manifest music lane renderer_final counters must be nonzero")

    for key in (
        "buffered_window_snapshots",
        "distinct_buffer_windows",
    ):
        if not isinstance(stream_health.get(key), int):
            raise AssertionError(f"manifest continuity.stream_health.{key} must be an integer")
    if stream_health["buffered_window_snapshots"] <= 0:
        raise AssertionError("manifest stream health must include buffered windows")
    if stream_health["distinct_buffer_windows"] < 2:
        raise AssertionError("manifest stream health must include changing music buffers")
    if stream_contract.get("mode") not in check_audio_continuity_proof.MUSIC_STREAM_MODES:
        raise AssertionError("manifest stream contract mode must be a known music stream mode")
    if stream_contract.get("status_field") != "musicstream":
        raise AssertionError("manifest stream contract must name musicstream")
    if not isinstance(stream_contract.get("pull_counters"), str):
        raise AssertionError("manifest stream contract must record musicpull counters")
    os_surfaces = stream_contract.get("os_surfaces")
    if os_surfaces is not None:
        if not isinstance(os_surfaces, dict):
            raise AssertionError("manifest stream contract os_surfaces must be an object")
        expected_surfaces = {
            "device": "VIBE_AUDIO_DEVICE_INFO",
            "ring": "VIBE_AUDIO_PCM_RING_INFO",
            "stream": "VIBE_AUDIO_STREAM_INFO",
            "mixer": "VIBE_AUDIO_MIXER_START/UPDATE/STOP/IS_PLAYING",
        }
        for key, expected in expected_surfaces.items():
            if os_surfaces.get(key) != expected:
                raise AssertionError(f"manifest stream contract os_surfaces.{key} must be {expected}")
    if stream_contract["mode"] == "PUSH" and stream_contract.get("current_push_proof") is not True:
        raise AssertionError("manifest stream contract must mark current PUSH proof")
    if stream_contract["mode"] == "PULL" and stream_contract.get("hardware_paced") is not True:
        raise AssertionError("manifest stream contract must mark PULL as hardware paced")
    if stream_contract["mode"] == "PULL":
        request, refill = stream_contract["pull_counters"].split(":")
        if int(request, 16) <= 0 or int(refill, 16) <= 0:
            raise AssertionError("manifest PULL stream contract must have nonzero musicpull counters")
        if int(refill, 16) > int(request, 16):
            raise AssertionError("manifest PULL stream contract cannot refill more chunks than requested")
    if stream_contract.get("current_payload_owner") is not None:
        if stream_contract.get("current_payload_owner") != "doom_port/music.c":
            raise AssertionError("manifest stream contract must name doom_port/music.c as payload owner")
    if stream_contract.get("current_service_command") is not None:
        if stream_contract.get("current_service_command") != "VIBE_AUDIO_MIXER_UPDATE":
            raise AssertionError("manifest stream contract must name VIBE_AUDIO_MIXER_UPDATE")
    service_sequence = stream_contract.get("service_sequence")
    if not isinstance(service_sequence, dict):
        raise AssertionError("manifest stream contract must include service_sequence")
    for key in (
        "request_delta",
        "refill_delta",
        "voiceq_update_delta",
        "renderer_chunk_delta",
        "max_pending_pull_requests",
        "pull_pending_peak",
        "pull_pending_final",
    ):
        value = service_sequence.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(
                f"manifest stream contract service_sequence.{key} must be eight hex digits"
            )
    for key in (
        "refill_matches_request",
        "voice_update_matches_refill",
        "render_chunk_matches_refill",
    ):
        if stream_contract["mode"] == "PULL" and service_sequence.get(key) is not True:
            raise AssertionError(f"manifest stream contract service_sequence.{key} must be true")
    if stream_contract["mode"] == "PULL":
        if int(service_sequence["pull_pending_peak"], 16) > check_audio_continuity_proof.MAX_PENDING_PULL_REQUESTS:
            raise AssertionError("manifest stream contract pending pull requests exceed proof threshold")
    future_step = stream_contract.get("future_legitimacy_step")
    if future_step is not None and "kernel-owned music ring" not in future_step:
        raise AssertionError("manifest stream contract future step must mention kernel-owned music ring")
    _validate_os_audio_contract(os_audio_contract)
    if renderer_contract is not None:
        if renderer_contract.get("status_counter") != "musicrend":
            raise AssertionError("manifest renderer contract must name musicrend")
        if renderer_contract.get("parser_owner") != "doom_port/music.c":
            raise AssertionError("manifest renderer contract must name doom_port/music.c")
        if renderer_contract.get("mus_score_end_event_type") != 6:
            raise AssertionError("manifest renderer contract must pin MUS score end to event type 6")
        if renderer_contract.get("mus_reserved_event_type_rejected") != 5:
            raise AssertionError("manifest renderer contract must reject MUS event type 5")
        if renderer_contract.get("mus_max_variable_delay_bytes") != 4:
            raise AssertionError("manifest renderer contract must pin MUS variable delay to four bytes")
        if renderer_contract.get("mus_variable_delay_requires_terminator") is not True:
            raise AssertionError("manifest renderer contract must require a terminated MUS delay")
        if renderer_contract.get("mus_grouped_event_fixture") is not True:
            raise AssertionError("manifest renderer contract must include grouped MUS event fixture proof")
    for key in (
        "buffer_floor",
        "buffer_peak",
        "buffer_final",
        "under_delta",
        "drop_delta",
        "stream_update_delta",
        "voiceq_update_delta",
        "pull_request_delta",
        "pull_refill_delta",
        "pull_pending_peak",
        "pull_pending_final",
        "position_delta",
        "position_delta_per_update_floor",
        "rendered_sample_delta",
    ):
        value = stream_health.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest continuity.stream_health.{key} must be eight hex digits")
    for key in ("buffer_initial", "rendered_plus_initial_buffer", "consumed_plus_final_buffer"):
        value = stream_health.get(key)
        if value is not None and (not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value)):
            raise AssertionError(f"manifest continuity.stream_health.{key} must be eight hex digits when present")
    for key in (
        "buffer_peak",
        "stream_update_delta",
        "position_delta",
        "position_delta_per_update_floor",
        "rendered_sample_delta",
    ):
        if int(stream_health[key], 16) <= 0:
            raise AssertionError(f"manifest continuity.stream_health.{key} must be nonzero")
    for key in ("rendered_plus_initial_buffer", "consumed_plus_final_buffer"):
        if key in stream_health and int(stream_health[key], 16) <= 0:
            raise AssertionError(f"manifest continuity.stream_health.{key} must be nonzero")
    if stream_health.get("rendered_sample_covers_position") is not True:
        raise AssertionError(
            "manifest stream health must show rendered samples plus initial "
            "musicbuf cover music position plus final musicbuf"
        )
    if stream_health.get("sequenced_refill_service") is not True:
        raise AssertionError("manifest stream health must prove sequenced pull refill service")
    if int(stream_health["stream_update_delta"], 16) < check_audio_continuity_proof.MIN_MUSIC_STREAM_UPDATE_DELTA:
        raise AssertionError("manifest stream health stream_update_delta is below proof threshold")
    if int(stream_health["pull_pending_peak"], 16) > check_audio_continuity_proof.MAX_PENDING_PULL_REQUESTS:
        raise AssertionError("manifest stream health pull_pending_peak exceeds proof threshold")
    if int(stream_health["under_delta"], 16) > MAX_MUSIC_UNDERRUN_DELTA:
        raise AssertionError("manifest stream health under_delta exceeds proof threshold")
    if int(stream_health["drop_delta"], 16) > MAX_MUSIC_DROP_DELTA:
        raise AssertionError("manifest stream health drop_delta exceeds proof threshold")

    if playability_cadence is not None:
        if not isinstance(playability_cadence.get("available"), bool):
            raise AssertionError("manifest playability_cadence.available must be boolean")
        verdict = playability_cadence.get("verdict")
        if not isinstance(verdict, str):
            raise AssertionError("manifest playability_cadence.verdict must be a string")
        if playability_cadence["available"]:
            if verdict != check_audio_continuity_proof.PLAYABILITY_CADENCE_HEALTHY:
                raise AssertionError("manifest playability_cadence verdict must be healthy when available")
            progress_obj = playability_cadence.get("progress")
            ratios = playability_cadence.get("ratios")
            safety = playability_cadence.get("safety")
            if not isinstance(progress_obj, dict) or not isinstance(ratios, dict) or not isinstance(safety, dict):
                raise AssertionError("manifest playability_cadence must include progress, ratios, and safety")
            for name in ("gtic", "leveltime", "doompresent", "audioirq", "refill", "musicpull_refill", "musicpos"):
                entry = progress_obj.get(name)
                if not isinstance(entry, dict):
                    raise AssertionError(f"manifest playability_cadence.progress.{name} must be an object")
                for key in ("start", "final", "delta"):
                    value = entry.get(key)
                    if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
                        raise AssertionError(
                            f"manifest playability_cadence.progress.{name}.{key} must be eight hex digits"
                        )
                if int(entry["delta"], 16) <= 0:
                    raise AssertionError(f"manifest playability_cadence.progress.{name}.delta must be nonzero")
            for key in (
                "audioirq_delta_per_frame_floor",
                "refill_delta_per_frame_floor",
                "pull_refill_delta_per_frame_floor",
                "musicpos_delta_per_leveltime_floor",
            ):
                value = ratios.get(key)
                if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
                    raise AssertionError(f"manifest playability_cadence.ratios.{key} must be eight hex digits")
            if playability_cadence.get("audio_pressure") is not False:
                raise AssertionError("manifest playability_cadence.audio_pressure must be false")
            for name in ("mixclip", "musicunder", "musicdrops"):
                entry = safety.get(name)
                if not isinstance(entry, dict) or int(entry.get("delta", "1"), 16) != 0:
                    raise AssertionError(f"manifest playability_cadence.safety.{name}.delta must be zero")
        else:
            reason = playability_cadence.get("reason")
            if not isinstance(reason, str) or not reason:
                raise AssertionError("manifest unavailable playability_cadence must include a reason")

    for key in (
        "mixclip_delta",
        "musicunder_delta",
        "musicdrop_delta",
        "max_mixclip_delta",
        "max_musicunder_delta",
        "max_musicdrop_delta",
    ):
        value = mixer_safety.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest continuity.mixer_safety.{key} must be eight hex digits")
    if int(mixer_safety["mixclip_delta"], 16) > MAX_MIX_CLIP_DELTA:
        raise AssertionError("manifest mixer safety mixclip_delta exceeds proof threshold")
    if int(mixer_safety["musicunder_delta"], 16) > MAX_MUSIC_UNDERRUN_DELTA:
        raise AssertionError("manifest mixer safety musicunder_delta exceeds proof threshold")
    if int(mixer_safety["musicdrop_delta"], 16) > MAX_MUSIC_DROP_DELTA:
        raise AssertionError("manifest mixer safety musicdrop_delta exceeds proof threshold")
    if mixer_safety.get("clip_free") is not True:
        raise AssertionError("manifest mixer safety clip_free must be true")
    if mixer_safety.get("underrun_free") is not True:
        raise AssertionError("manifest mixer safety underrun_free must be true")
    if mixer_safety.get("drop_free") is not True:
        raise AssertionError("manifest mixer safety drop_free must be true")

    if scripted_phase_proof.get("requires_scripted_fire_sfx") is not True:
        raise AssertionError("manifest scripted phase proof must require scripted fire SFX")
    if scripted_phase_proof.get("baseline_snapshot") != "baseline":
        raise AssertionError("manifest scripted phase proof baseline snapshot must be baseline")
    if scripted_phase_proof.get("fire_snapshot") != "fire":
        raise AssertionError("manifest scripted phase proof fire snapshot must be fire")
    for key in (
        "doomsound_delta",
        "sfxmix_delta",
        "sfxsrc_delta",
        "sfxsubmit_delta",
        "sfxoutput_delta",
        "sfxdma_delta",
        "musicmix_delta",
    ):
        value = scripted_phase_proof.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest continuity.scripted_phase_proof.{key} must be eight hex digits")
    for key in (
        "doomsound_delta",
        "sfxmix_delta",
        "sfxsrc_delta",
        "sfxsubmit_delta",
        "sfxoutput_delta",
        "sfxdma_delta",
    ):
        if int(scripted_phase_proof[key], 16) <= 0:
            raise AssertionError(
                f"manifest continuity.scripted_phase_proof.{key} must prove scripted fire SFX"
            )
    claim = scripted_phase_proof.get("claim")
    if not isinstance(claim, str) or "not music alone" not in claim:
        raise AssertionError("manifest scripted phase proof must reject music alone")

    for key in ("contains_raw_audio", "contains_wad_data", "contains_pixels"):
        if policy.get(key) is not False:
            raise AssertionError(f"manifest artifact_policy.{key} must be false")
    if policy.get("upload_only_aggregate_json") is not True:
        raise AssertionError("manifest must declare upload_only_aggregate_json=true")
    if policy.get("raw_audio_upload_allowed") is not False:
        raise AssertionError("manifest artifact_policy.raw_audio_upload_allowed must be false")
    if policy.get("temporary_wav_deleted_before_upload") is not True:
        raise AssertionError("manifest artifact_policy.temporary_wav_deleted_before_upload must be true")
    if policy.get("vnc_carries_audio_by_default") is not False:
        raise AssertionError("manifest artifact_policy.vnc_carries_audio_by_default must be false")
    if policy.get("audible_evidence") != "aggregate-cloud-output-status":
        raise AssertionError("manifest artifact_policy.audible_evidence must be aggregate-cloud-output-status")


def _validate_proof_contracts(proof_contracts: Any) -> None:
    if not isinstance(proof_contracts, dict):
        raise AssertionError("manifest proof_contracts must be an object")
    expected = _proof_contracts()
    for group, expected_contract in expected.items():
        contract = proof_contracts.get(group)
        if not isinstance(contract, dict):
            raise AssertionError(f"manifest proof_contracts.{group} must be an object")
        for key, expected_value in expected_contract.items():
            value = contract.get(key)
            if value != expected_value:
                raise AssertionError(
                    f"manifest proof_contracts.{group}.{key} must be {expected_value!r}"
                )


def _contract_hex(value: Any, path: str, *, positive: bool = False) -> int:
    if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"manifest {path} must be eight hex digits")
    parsed = int(value, 16)
    if positive and parsed <= 0:
        raise AssertionError(f"manifest {path} must be nonzero")
    return parsed


def _validate_os_audio_contract(contract: dict[str, Any]) -> None:
    if contract.get("lane") != STATUS_ONLY_OS_AUDIO_SUBSYSTEM_LANE:
        raise AssertionError("manifest os_audio_contract.lane must be status-only-os-audio-subsystem")

    status_fields = contract.get("status_fields")
    if not isinstance(status_fields, dict):
        raise AssertionError("manifest os_audio_contract.status_fields must be an object")
    expected_fields = {
        "device": "adev",
        "sample_format": "pcm",
        "ring": "pcmbuf",
        "irq_phase": "half",
        "stream": "musicstream/musicpull/musicbuf/musicpos",
        "mixer_lanes": "voices/sfxvoices/musicvoices/sfxmix/musicmix",
    }
    for key, expected in expected_fields.items():
        if status_fields.get(key) != expected:
            raise AssertionError(f"manifest os_audio_contract.status_fields.{key} must be {expected!r}")

    device = contract.get("device")
    ring = contract.get("pcm_ring")
    stream = contract.get("stream")
    lanes = contract.get("mixer_lanes")
    if not all(isinstance(value, dict) for value in (device, ring, stream, lanes)):
        raise AssertionError("manifest os_audio_contract must contain device, pcm_ring, stream, and mixer_lanes")

    if device.get("kind") != "SB16" or device.get("ready") is not True:
        raise AssertionError("manifest os_audio_contract.device must prove a ready SB16 device")
    capabilities = device.get("capabilities")
    if not isinstance(capabilities, list):
        raise AssertionError("manifest os_audio_contract.device.capabilities must be a list")
    for capability in ("pcm-ring", "mixer-voices", "pull-stream", "sb16-dma"):
        if capability not in capabilities:
            raise AssertionError(
                f"manifest os_audio_contract.device.capabilities must include {capability}"
            )
    if device.get("required_capabilities_present") is not True:
        raise AssertionError("manifest os_audio_contract.device required capabilities must be present")
    _contract_hex(device.get("playback_start_count"), "os_audio_contract.device.playback_start_count", positive=True)

    if ring.get("format") != "u8-stereo":
        raise AssertionError("manifest os_audio_contract.pcm_ring.format must be u8-stereo")
    if ring.get("channels") != 2 or ring.get("sample_rate") != 11025:
        raise AssertionError("manifest os_audio_contract.pcm_ring must prove stereo 11025 Hz output")
    ring_bytes = _contract_hex(ring.get("ring_bytes"), "os_audio_contract.pcm_ring.ring_bytes", positive=True)
    period_bytes = _contract_hex(ring.get("period_bytes"), "os_audio_contract.pcm_ring.period_bytes", positive=True)
    write_offset = _contract_hex(ring.get("write_offset"), "os_audio_contract.pcm_ring.write_offset")
    active_half = _contract_hex(ring.get("active_half"), "os_audio_contract.pcm_ring.active_half")
    if period_bytes * 2 != ring_bytes or ring.get("two_period_ring") is not True:
        raise AssertionError("manifest os_audio_contract.pcm_ring must prove a two-period ring")
    if write_offset >= ring_bytes or active_half not in (0, 1):
        raise AssertionError("manifest os_audio_contract.pcm_ring must expose valid offset and active half")
    if ring.get("active_half_matches_half") is not True:
        raise AssertionError("manifest os_audio_contract.pcm_ring must match pcmbuf active half to half=")
    _contract_hex(ring.get("irq_delta"), "os_audio_contract.pcm_ring.irq_delta", positive=True)
    _contract_hex(ring.get("refill_delta"), "os_audio_contract.pcm_ring.refill_delta", positive=True)

    if stream.get("mode") != "PULL":
        raise AssertionError("manifest os_audio_contract.stream.mode must be PULL")
    _contract_hex(stream.get("request_delta"), "os_audio_contract.stream.request_delta", positive=True)
    _contract_hex(stream.get("refill_delta"), "os_audio_contract.stream.refill_delta", positive=True)
    _contract_hex(stream.get("pending_peak"), "os_audio_contract.stream.pending_peak")
    _contract_hex(stream.get("buffer_initial"), "os_audio_contract.stream.buffer_initial")
    _contract_hex(stream.get("buffer_final"), "os_audio_contract.stream.buffer_final")
    _contract_hex(stream.get("position_delta"), "os_audio_contract.stream.position_delta", positive=True)
    if stream.get("ordered_refills") is not True:
        raise AssertionError("manifest os_audio_contract.stream must prove ordered refills")
    if stream.get("bounded_pending_requests") is not True:
        raise AssertionError("manifest os_audio_contract.stream must prove bounded pending pull requests")
    if stream.get("payload_owner") != "doom_port/music.c":
        raise AssertionError("manifest os_audio_contract.stream payload owner must be doom_port/music.c")
    if stream.get("service_command") != "VIBE_AUDIO_MIXER_UPDATE":
        raise AssertionError("manifest os_audio_contract.stream service command must be VIBE_AUDIO_MIXER_UPDATE")

    if lanes.get("voice_total_matches_lanes") is not True:
        raise AssertionError("manifest os_audio_contract.mixer_lanes must prove voice lane totals")
    if lanes.get("sfx_lane_counter") != "sfxmix" or lanes.get("music_lane_counter") != "musicmix":
        raise AssertionError("manifest os_audio_contract.mixer_lanes must name sfxmix and musicmix")
    _contract_hex(lanes.get("sfx_delta"), "os_audio_contract.mixer_lanes.sfx_delta", positive=True)
    _contract_hex(
        lanes.get("sfx_output_delta"),
        "os_audio_contract.mixer_lanes.sfx_output_delta",
        positive=True,
    )
    _contract_hex(
        lanes.get("sfx_dma_output_delta"),
        "os_audio_contract.mixer_lanes.sfx_dma_output_delta",
        positive=True,
    )
    if lanes.get("sfx_dma_output_matches_sfx_output") is not True:
        raise AssertionError(
            "manifest os_audio_contract.mixer_lanes must conserve SFX DMA/output bytes"
        )
    _contract_hex(lanes.get("music_delta"), "os_audio_contract.mixer_lanes.music_delta", positive=True)
    _contract_hex(
        lanes.get("music_render_chunk_delta"),
        "os_audio_contract.mixer_lanes.music_render_chunk_delta",
        positive=True,
    )
    _contract_hex(
        lanes.get("music_render_sample_delta"),
        "os_audio_contract.mixer_lanes.music_render_sample_delta",
        positive=True,
    )
    if lanes.get("human_listener_lane") != "not-proven-by-status":
        raise AssertionError("manifest os_audio_contract.mixer_lanes must keep human listener lane separate")

    claim = contract.get("claim")
    if not isinstance(claim, str) or "human-listened quality" not in claim:
        raise AssertionError("manifest os_audio_contract.claim must separate human-listened quality")


def validate_repo_contract() -> None:
    workflow = WORKFLOW.read_text()
    makefile = MAKEFILE.read_text()
    audio_doc = AUDIO_DOC.read_text()
    music_doc = MUSIC_DOC.read_text()
    music_impl = MUSIC_IMPL.read_text()
    music_header = MUSIC_HEADER.read_text()
    playable_doc = PLAYABLE_DOC.read_text()
    runbook = RUNBOOK.read_text()
    artifact_checker = ARTIFACT_CHECKER.read_text()

    contracts = (
        (
            WORKFLOW,
            workflow,
            (
                "audible_audio_proof:",
                "AUDIBLE_AUDIO_PROOF",
                "-audiodev wav,id=snd0,path=build/doom-audio.wav",
                "tools/check_audible_audio_proof.py",
                "--analyze-wav build/doom-audio.wav",
                "--baseline build/status.after-start.txt",
                "rm -f build/doom-audio.wav",
                "build/audio-proof.json",
            ),
        ),
        (
            MAKEFILE,
            makefile,
            (
                "audible-audio-proof-check:",
                "tools/check_audible_audio_proof.py --repo-contract",
                "audible-audio-proof-check",
            ),
        ),
        (
            AUDIO_DOC,
            audio_doc,
            (
                "tools/check_audible_audio_proof.py",
                "adev=",
                "pcm=",
                "pcmbuf=",
                "os_audio_contract",
                "status-only OS audio subsystem lane",
                "sfxmix= counts non-music Doom SFX only",
                "sfxbytes=",
                "sfxdma=",
                "sfxsrc=",
                "sfxlast=",
                "QEMU WAV backend",
                "aggregate JSON",
                "delete the temporary WAV",
                "status-only SB16 continuity",
                "musicpos=",
                "musicbuf=",
                "VIBE_AUDIO_STREAM_INFO",
                "musicrend=",
                "event type 6",
                "event type 5",
                "unterminated MUS variable-length delays",
                "grouped MUS events",
                "stream_contract",
                "device/ring/stream/mixer status coherence",
                "playability_cadence",
                "device/ring/stream/mixer",
                "musicstream=PULL",
                "listener-quality metadata",
                "stream-health",
                "Doom audio assets come from WAD lumps",
                "VNC does not carry audio by default",
                "raw audio must not be uploaded",
                "Aggregate audible-output proof (not human listener approval)",
                "human-listened quality is a separate lane",
                "future hardware-paced mixer/refill playback ABI",
            ),
        ),
        (
            MUSIC_DOC,
            music_doc,
            (
                "long-running music streaming contract",
                "song-position",
                "os_audio_contract",
                "MUS event type 6",
                "event type 5",
                "unterminated MUS variable-length delays",
                "grouped MUS events",
                "stateful stream cursor",
                "long-playback wrap",
                "Music legitimacy roadmap as OS contracts",
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
                "audible_audio_proof",
                "audio-proof.json",
                "does not upload the WAV",
                "status-only SB16 continuity",
            ),
        ),
        (
            RUNBOOK,
            runbook,
            (
                "audible remote proof",
                "audio-proof.json",
                "delete the temporary WAV",
                "status-only SB16 continuity",
            ),
        ),
        (
            ARTIFACT_CHECKER,
            artifact_checker,
            (
                "*.wav",
                "audio-proof.json",
                "check_audible_audio_proof.validate_manifest",
            ),
        ),
    )
    for path, text, needles in contracts:
        for needle in needles:
            if needle not in text:
                raise AssertionError(f"{path.relative_to(ROOT)} missing {needle!r}")


def _load_manifest(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise AssertionError(f"invalid JSON manifest: {exc}") from exc
    if not isinstance(data, dict):
        raise AssertionError("manifest must be a JSON object")
    return data


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", nargs="?", type=Path, help="audio-proof.json to validate")
    parser.add_argument("--analyze-wav", type=Path, help="temporary QEMU WAV to analyze")
    parser.add_argument("--status", type=Path, help="decoded final status.txt for WAV analysis")
    parser.add_argument("--baseline", type=Path, help="decoded status.after-start.txt")
    parser.add_argument("--fire", type=Path, help="decoded status.after-fire.txt")
    parser.add_argument("--movement", type=Path, help="decoded status.after-move.txt")
    parser.add_argument("--use", type=Path, help="decoded status.after-use.txt")
    parser.add_argument("--menu", type=Path, help="decoded status.after-menu.txt")
    parser.add_argument("--output", type=Path, help="write aggregate manifest JSON here")
    parser.add_argument("--repo-contract", action="store_true")
    parser.add_argument("--window-ms", type=int, default=DEFAULT_WINDOW_MS)
    parser.add_argument("--min-active-rms", type=float, default=DEFAULT_MIN_RMS)
    args = parser.parse_args(argv)

    try:
        if args.repo_contract:
            validate_repo_contract()
            print("audible audio proof repo contract OK")
            return 0
        if args.analyze_wav is not None:
            if args.status is None or args.output is None:
                raise AssertionError("--analyze-wav requires --status and --output")
            missing = [
                label for label, path in (
                    ("--baseline", args.baseline),
                    ("--fire", args.fire),
                    ("--movement", args.movement),
                    ("--use", args.use),
                    ("--menu", args.menu),
                )
                if path is None
            ]
            if missing:
                raise AssertionError("--analyze-wav requires audio continuity snapshots: " + ", ".join(missing))
            manifest = analyze_wav(
                args.analyze_wav,
                args.status,
                baseline_status_path=args.baseline,
                fire_status_path=args.fire,
                movement_status_path=args.movement,
                use_status_path=args.use,
                menu_status_path=args.menu,
                window_ms=args.window_ms,
                min_active_rms=args.min_active_rms,
            )
            validate_manifest(manifest)
            args.output.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
            print(f"audible audio proof manifest wrote {args.output}")
            return 0
        if args.manifest is None:
            raise AssertionError("manifest path is required unless --repo-contract is used")
        validate_manifest(_load_manifest(args.manifest))
    except (OSError, wave.Error, AssertionError) as exc:
        print(f"audible audio proof failed: {exc}", file=sys.stderr)
        return 1

    print("audible audio proof OK: aggregate QEMU WAV metrics prove non-silent remote audio output")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
