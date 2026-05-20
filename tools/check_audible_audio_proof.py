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

WORKFLOW = ROOT / ".github" / "workflows" / "real-wad-smoke.yml"
MAKEFILE = ROOT / "Makefile"
AUDIO_DOC = ROOT / "docs" / "audio.md"
MUSIC_DOC = ROOT / "docs" / "doom-music.md"
PLAYABLE_DOC = ROOT / "docs" / "playable-cloud-proof.md"
RUNBOOK = ROOT / "docs" / "runbooks" / "remote-doom-playtest.md"
ARTIFACT_CHECKER = ROOT / "tools" / "check_cloud_playability_artifacts.py"

SCHEMA = "vibe-os-audible-audio-proof-v4"
FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
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


def _status_fields(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise AssertionError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    return fields


def _hex_value(fields: dict[str, str], name: str) -> int:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"status missing {name}= field")
    if not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
        raise AssertionError(f"{name}= must be eight hex digits, got {value!r}")
    return int(value, 16)


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
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
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
    for counter in ("doomsound", "audioirq", "refill", "sfxmix", "musicmix", "musicpos"):
        _hex_positive(fields, counter)
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
    if _hex_tuple(fields, "musicq", 2)[0] == 0:
        raise AssertionError("status musicq= must prove the music voice was queued")
    if fields.get("musicstream") not in check_audio_continuity_proof.MUSIC_STREAM_MODES:
        raise AssertionError(f"status musicstream= must be a known mode, got {fields.get('musicstream')!r}")
    _hex_tuple(fields, "musicpull", 2)
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
        "sfxmix": fields["sfxmix"],
        "sfxvoices": fields["sfxvoices"],
        "musicmix": fields["musicmix"],
        "musicloop": fields.get("musicloop", "00000000"),
        "musicpos": fields["musicpos"],
        "musicbuf": fields["musicbuf"],
        "musicunder": fields["musicunder"],
        "musicdrops": fields["musicdrops"],
        "musicstream": fields["musicstream"],
        "musicpull": fields["musicpull"],
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
        for name in ("doomsound", "audioirq", "refill", "sfxmix", "musicmix", "musicpos")
    }
    progress["voiceq_update"] = _tuple_counter_delta(
        baseline_fields, final_fields, "voiceq", 3, 2
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
    music_buffers = [_hex_value(fields, "musicbuf") for fields in ordered_fields]
    update_delta = int(progress["voiceq_update"]["delta"], 16)
    position_delta = int(progress["musicpos"]["delta"], 16)
    stream_health = {
        "buffer_floor": f"{min(music_buffers):08X}",
        "buffer_peak": f"{max(music_buffers):08X}",
        "buffer_final": final_fields["musicbuf"],
        "buffered_window_snapshots": sum(1 for value in music_buffers if value > 0),
        "distinct_buffer_windows": len(set(music_buffers)),
        "under_delta": _counter_delta(baseline_fields, final_fields, "musicunder")["delta"],
        "drop_delta": _counter_delta(baseline_fields, final_fields, "musicdrops")["delta"],
        "stream_update_delta": progress["voiceq_update"]["delta"],
        "position_delta": progress["musicpos"]["delta"],
        "position_delta_per_update_floor": f"{(position_delta // update_delta) if update_delta else 0:08X}",
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
        "claim": (
            "musicstream=PUSH proves pushed chunk continuity; musicstream=PULL plus "
            "advancing musicpull= counters is required before claiming hardware-paced music"
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
        "music_stream_update_progress": int(progress["voiceq_update"]["delta"], 16) > 0,
        "irq_refill_progress": (
            int(progress["audioirq"]["delta"], 16) > 0
            and int(progress["refill"]["delta"], 16) > 0
        ),
        "mix_lanes": {
            "non_music_sfx": {
                "counter": "sfxmix",
                "delta": progress["sfxmix"]["delta"],
                "active_voice_snapshots": sum(
                    1 for fields in snapshot_fields.values() if _hex_value(fields, "sfxvoices") > 0
                ),
            },
            "music": {
                "counter": "musicmix",
                "delta": progress["musicmix"]["delta"],
                "active_voice_snapshots": sum(
                    1 for fields in snapshot_fields.values() if _hex_value(fields, "musicvoices") > 0
                ),
                "buffered_window_snapshots": sum(
                    1 for fields in snapshot_fields.values() if _hex_value(fields, "musicbuf") > 0
                ),
                "stream_update_delta": progress["voiceq_update"]["delta"],
                "position_delta": progress["musicpos"]["delta"],
            },
            "shared_sb16_refill": {
                "irq_delta": progress["audioirq"]["delta"],
                "refill_delta": progress["refill"]["delta"],
            },
        },
        "stream_health": stream_health,
        "stream_contract": stream_contract,
        "mixer_safety": mixer_safety,
        "scripted_phase_proof": fire_phase,
        "progress": progress,
        "claim": (
            "non-silent remote QEMU output plus status-only SB16 continuity; "
            "music chunks are advanced by a kernel-visible stream-position contract, "
            "musicstream= names whether that proof is PUSH or future PULL, "
            "aggregate listener-quality metadata is machine checked, but subjective "
            "human approval is still unproven"
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
                "is not a human listening pass."
            ),
        },
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
    for counter in ("dma", "sfxvoices", "musicbuf", "musicunder", "musicdrops"):
        value = status.get(counter)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest status.{counter} must be eight hex digits")
    if int(status["dma"], 16) <= 0:
        raise AssertionError("manifest status.dma must be nonzero")
    if status.get("musicstream") not in check_audio_continuity_proof.MUSIC_STREAM_MODES:
        raise AssertionError("manifest status.musicstream must be a known music stream mode")
    for name, count in (("sb16", 2), ("play", 2), ("voiceq", 3), ("musicq", 2), ("musicpull", 2)):
        value = status.get(name)
        if not isinstance(value, str):
            raise AssertionError(f"manifest status.{name} must be present")
        parts = value.split(":")
        if len(parts) != count or any(not re.fullmatch(r"[0-9A-Fa-f]{8}", part) for part in parts):
            raise AssertionError(f"manifest status.{name} must have {count} colon-separated hex parts")
        if name != "musicpull" and int(parts[0], 16) <= 0:
            raise AssertionError(f"manifest status.{name} first counter must be nonzero")

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
    for name in ("doomsound", "audioirq", "refill", "sfxmix", "musicmix", "musicpos", "voiceq_update"):
        entry = progress.get(name)
        if not isinstance(entry, dict):
            raise AssertionError(f"manifest continuity.progress.{name} must be an object")
        for key in ("start", "final", "delta"):
            value = entry.get(key)
            if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
                raise AssertionError(f"manifest continuity.progress.{name}.{key} must be eight hex digits")
        if int(entry["delta"], 16) <= 0:
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
        ("non_music_sfx", sfx_lane, ("delta",)),
        ("music", music_lane, ("delta", "stream_update_delta", "position_delta")),
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
    if sfx_lane["active_voice_snapshots"] < 0:
        raise AssertionError("manifest non_music_sfx lane active voice snapshots cannot be negative")
    if music_lane.get("active_voice_snapshots", 0) <= 0:
        raise AssertionError("manifest music lane must have active voice snapshots")
    if music_lane.get("buffered_window_snapshots", 0) <= 0:
        raise AssertionError("manifest music lane must have buffered window snapshots")

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
    if stream_contract["mode"] == "PUSH" and stream_contract.get("current_push_proof") is not True:
        raise AssertionError("manifest stream contract must mark current PUSH proof")
    if stream_contract["mode"] == "PULL" and stream_contract.get("hardware_paced") is not True:
        raise AssertionError("manifest stream contract must mark PULL as hardware paced")
    for key in (
        "buffer_floor",
        "buffer_peak",
        "buffer_final",
        "under_delta",
        "drop_delta",
        "stream_update_delta",
        "position_delta",
        "position_delta_per_update_floor",
    ):
        value = stream_health.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest continuity.stream_health.{key} must be eight hex digits")
    for key in ("buffer_peak", "stream_update_delta", "position_delta", "position_delta_per_update_floor"):
        if int(stream_health[key], 16) <= 0:
            raise AssertionError(f"manifest continuity.stream_health.{key} must be nonzero")
    if int(stream_health["stream_update_delta"], 16) < check_audio_continuity_proof.MIN_MUSIC_STREAM_UPDATE_DELTA:
        raise AssertionError("manifest stream health stream_update_delta is below proof threshold")
    if int(stream_health["under_delta"], 16) > MAX_MUSIC_UNDERRUN_DELTA:
        raise AssertionError("manifest stream health under_delta exceeds proof threshold")
    if int(stream_health["drop_delta"], 16) > MAX_MUSIC_DROP_DELTA:
        raise AssertionError("manifest stream health drop_delta exceeds proof threshold")

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
    for key in ("doomsound_delta", "sfxmix_delta", "musicmix_delta"):
        value = scripted_phase_proof.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest continuity.scripted_phase_proof.{key} must be eight hex digits")
    for key in ("doomsound_delta", "sfxmix_delta"):
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


def validate_repo_contract() -> None:
    workflow = WORKFLOW.read_text()
    makefile = MAKEFILE.read_text()
    audio_doc = AUDIO_DOC.read_text()
    music_doc = MUSIC_DOC.read_text()
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
                "sfxmix= counts non-music Doom SFX only",
                "QEMU WAV backend",
                "aggregate JSON",
                "delete the temporary WAV",
                "status-only SB16 continuity",
                "musicpos=",
                "musicbuf=",
                "stream_contract",
                "musicstream=PUSH",
                "listener-quality metadata",
                "stream-health",
                "Doom audio assets come from WAD lumps",
                "VNC does not carry audio by default",
                "raw audio must not be uploaded",
            ),
        ),
        (
            MUSIC_DOC,
            music_doc,
            (
                "long-running music streaming contract",
                "song-position",
                "stateful stream cursor",
                "long-playback wrap",
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
