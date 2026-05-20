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

SCHEMA = "vibe-os-audible-audio-proof-v1"
FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
FORBIDDEN_MANIFEST_KEYS = {
    "audio_bytes",
    "base64",
    "pcm",
    "raw_audio",
    "samples",
    "waveform",
}

DEFAULT_WINDOW_MS = 100
DEFAULT_MIN_DURATION_MS = 3000
DEFAULT_MIN_ACTIVE_WINDOWS = 3
DEFAULT_MIN_ACTIVE_RATIO = 0.02
DEFAULT_MIN_RMS = 0.0015
DEFAULT_MIN_PEAK = 0.01


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
    for counter in ("audioirq", "refill", "sfxmix", "musicmix"):
        _hex_positive(fields, counter)
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
    return {
        "audio": fields["audio"],
        "doomrun": fields["doomrun"],
        "gameplay": fields["gameplay"],
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
    baseline_fields = _status_fields(baseline_status)
    final_fields = _status_fields(final_status)
    progress = {
        name: _counter_delta(baseline_fields, final_fields, name)
        for name in ("audioirq", "refill", "sfxmix", "musicmix")
    }
    progress["voiceq_update"] = _tuple_counter_delta(
        baseline_fields, final_fields, "voiceq", 3, 2
    )
    return {
        "gate": "tools/check_audio_continuity_proof.py",
        "snapshots": ["baseline", "fire", "movement", "use", "menu", "final"],
        "sb16_continuity": True,
        "non_music_sfx_progress": int(progress["sfxmix"]["delta"], 16) > 0,
        "music_stream_progress": int(progress["musicmix"]["delta"], 16) > 0,
        "music_stream_update_progress": int(progress["voiceq_update"]["delta"], 16) > 0,
        "irq_refill_progress": (
            int(progress["audioirq"]["delta"], 16) > 0
            and int(progress["refill"]["delta"], 16) > 0
        ),
        "progress": progress,
        "claim": (
            "non-silent remote QEMU output plus status-only SB16 continuity; "
            "music chunks are advanced by a port-owned song-position stream, "
            "but human listener quality is still unproven"
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
        zero_crossings = 0
        previous_sign = 0

        while True:
            chunk = wav.readframes(frames_per_window)
            if not chunk:
                break
            samples = list(_iter_normalized_samples(chunk, sample_width))
            if not samples:
                break
            total_windows += 1
            sum_squares = 0.0
            for sample in samples:
                abs_sample = abs(sample)
                if abs_sample > peak_abs:
                    peak_abs = abs_sample
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
        "status": _status_summary(status_path),
        "continuity": continuity,
        "artifact_policy": {
            "contains_raw_audio": False,
            "contains_wad_data": False,
            "contains_pixels": False,
            "upload_only_aggregate_json": True,
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
    status = manifest.get("status")
    continuity = manifest.get("continuity")
    policy = manifest.get("artifact_policy")
    if not isinstance(fmt, dict) or not isinstance(analysis, dict):
        raise AssertionError("manifest must contain format and analysis objects")
    if not isinstance(status, dict) or not isinstance(continuity, dict) or not isinstance(policy, dict):
        raise AssertionError("manifest must contain status, continuity, and artifact_policy objects")

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

    if status.get("audio") != "SB16":
        raise AssertionError("manifest status.audio must be SB16")
    if status.get("gameplay") != "OK":
        raise AssertionError("manifest status.gameplay must be OK")
    if status.get("doomrun") not in ("RUN", "EXIT"):
        raise AssertionError("manifest status.doomrun must be RUN or EXIT")
    for counter in ("audioirq", "refill", "sfxmix", "musicmix"):
        value = status.get(counter)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest status.{counter} must be eight hex digits")
        if int(value, 16) <= 0:
            raise AssertionError(f"manifest status.{counter} must be nonzero")
    for counter in ("dma", "sfxvoices"):
        value = status.get(counter)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
            raise AssertionError(f"manifest status.{counter} must be eight hex digits")
    if int(status["dma"], 16) <= 0:
        raise AssertionError("manifest status.dma must be nonzero")
    for name, count in (("sb16", 2), ("play", 2), ("voiceq", 3), ("musicq", 2)):
        value = status.get(name)
        if not isinstance(value, str):
            raise AssertionError(f"manifest status.{name} must be present")
        parts = value.split(":")
        if len(parts) != count or any(not re.fullmatch(r"[0-9A-Fa-f]{8}", part) for part in parts):
            raise AssertionError(f"manifest status.{name} must have {count} colon-separated hex parts")
        if int(parts[0], 16) <= 0:
            raise AssertionError(f"manifest status.{name} first counter must be nonzero")

    if continuity.get("gate") != "tools/check_audio_continuity_proof.py":
        raise AssertionError("manifest continuity.gate must name the audio continuity checker")
    for key in (
        "sb16_continuity",
        "non_music_sfx_progress",
        "music_stream_progress",
        "music_stream_update_progress",
        "irq_refill_progress",
    ):
        if continuity.get(key) is not True:
            raise AssertionError(f"manifest continuity.{key} must be true")
    progress = continuity.get("progress")
    if not isinstance(progress, dict):
        raise AssertionError("manifest continuity.progress must be an object")
    for name in ("audioirq", "refill", "sfxmix", "musicmix", "voiceq_update"):
        entry = progress.get(name)
        if not isinstance(entry, dict):
            raise AssertionError(f"manifest continuity.progress.{name} must be an object")
        for key in ("start", "final", "delta"):
            value = entry.get(key)
            if not isinstance(value, str) or not re.fullmatch(r"[0-9A-Fa-f]{8}", value):
                raise AssertionError(f"manifest continuity.progress.{name}.{key} must be eight hex digits")
        if int(entry["delta"], 16) <= 0:
            raise AssertionError(f"manifest continuity.progress.{name}.delta must be nonzero")

    for key in ("contains_raw_audio", "contains_wad_data", "contains_pixels"):
        if policy.get(key) is not False:
            raise AssertionError(f"manifest artifact_policy.{key} must be false")
    if policy.get("upload_only_aggregate_json") is not True:
        raise AssertionError("manifest must declare upload_only_aggregate_json=true")


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
            ),
        ),
        (
            MUSIC_DOC,
            music_doc,
            (
                "long-running music streaming contract",
                "song-position",
                "stateful stream cursor",
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
