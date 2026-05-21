#!/usr/bin/env python3
"""Collect a status-only manual remote VNC Doom playtest proof bundle.

This helper is intended to run on a disposable remote host after a human VNC
session. It does not launch QEMU. It copies only allowlisted diagnostics out of
the remote build directory, writes the structured human notes/checklist/session
files, and then runs the same status-only artifact validator used for
downloaded cloud proofs.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
sys.path.insert(0, str(SCRIPT_DIR))

import check_cloud_playability_artifacts  # noqa: E402
from status_fields import parse_status_fields, summarize_status_fields  # noqa: E402


REQUIRED_EXACT_FILES = (
    "kernel.elf",
    "user_probe.elf",
    "doom.elf",
    "doom.symbols",
)

OPTIONAL_EXACT_FILES = (
    "audio-proof.json",
)

ALLOWLIST_PATTERNS = ("*.log",)
MAX_COPIED_LOG_BYTES = 2 * 1024 * 1024
CAPTURE_PHASES = tuple(
    phase for phase, _status_file, _human_action in check_cloud_playability_artifacts.HUMAN_SESSION_PHASES
)
CAPTURE_REQUIRED_STATUS_FIELDS = tuple(
    check_cloud_playability_artifacts.HUMAN_SESSION_STATUS_FIELDS
)

NOTE_FIELD_ORDER = (
    "schema",
    "commit",
    "scripted_proof",
    "scripted_proof_run_id",
    "scripted_proof_url",
    "scripted_proof_checked",
    "proof_basis",
    "playtester",
    "remote_host",
    "qemu_location",
    "qemu_display",
    "monitor_socket",
    "vnc_tunnel",
    "vnc_endpoint",
    "wad",
    "display",
    "keyboard",
    "mouse",
    "audio",
    "visual_evidence",
    "keyboard_evidence",
    "mouse_evidence",
    "menu_evidence",
    "audio_evidence",
    "audio_notes",
    "slowdown",
    "slowdown_notes",
    "novnc_focus",
    "novnc_focus_notes",
    "status_capture",
    "session_phases",
) + tuple(check_cloud_playability_artifacts.HUMAN_PHASE_ACTION_NOTE_KEYS.values()) + tuple(
    check_cloud_playability_artifacts.HUMAN_PHASE_HASH_NOTE_KEYS.values()
) + (
    "diagnostics",
    "proof_bundle",
    "no_local_qemu",
    "no_wad_upload",
    "no_disk_upload",
    "no_pixel_upload",
    "no_screenshot_upload",
    "no_raw_audio_upload",
) + tuple(check_cloud_playability_artifacts.HUMAN_OPERATOR_CONFIRMATION_FIELDS.values())

REVIEW_NOTE_ARGUMENTS = (
    ("after-start", "start_note", "--start-note", "E1M1-visible-in-noVNC"),
    ("after-fire", "fire_note", "--fire-note", "Ctrl-fire-visible-response"),
    ("after-move", "move_note", "--move-note", "Arrow-move-or-turn-visible-response"),
    ("after-use", "use_note", "--use-note", "Space-use-visible-response"),
    ("after-mouse", "mouse_note", "--mouse-note", "Mouse-move-click-visible-response"),
    ("after-menu", "menu_note", "--menu-note", "Escape-menu-visible-response"),
    ("final", "final_note", "--final-note", "Final-duration-window-observed"),
)

REQUIRED_CONFIRMATION_FLAGS = (
    ("confirm_scripted_proof_green", "--confirm-scripted-proof-green"),
    ("confirm_remote_vnc", "--confirm-remote-vnc"),
    ("confirm_e1m1_visible", "--confirm-e1m1-visible"),
    ("confirm_keyboard_fire", "--confirm-keyboard-fire"),
    ("confirm_keyboard_move", "--confirm-keyboard-move"),
    ("confirm_keyboard_use", "--confirm-keyboard-use"),
    ("confirm_mouse_action", "--confirm-mouse-action"),
    ("confirm_menu_escape", "--confirm-menu-escape"),
    ("confirm_audio_observation", "--confirm-audio-observation"),
    ("confirm_slowdown_notes", "--confirm-slowdown-notes"),
    ("confirm_novnc_focus_observation", "--confirm-novnc-focus-observation"),
    ("confirm_phase_actions", "--confirm-phase-actions"),
    ("confirm_phase_status_hashes", "--confirm-phase-status-hashes"),
    ("confirm_no_forbidden_artifacts", "--confirm-no-forbidden-artifacts"),
    ("confirm_post_download_verification", "--confirm-post-download-verification"),
)

SLOWDOWN_CHOICES = ("not-observed", "mild", "moderate", "severe")
NOVNC_FOCUS_CHOICES = (
    "canvas-focused-before-actions",
    "focus-retaken-during-session",
    "focus-issues-observed",
)
PHASE_STATUS_SIGNALS = {
    "early": "baseline counters before manual input",
    "after-start": "gameplay=OK, E1M1, menu inactive",
    "after-fire": "keyseen fire bit plus attack/refire/ammo status",
    "after-move": "movement key bit plus position or turn progress",
    "after-use": "use key bit plus use-command status",
    "after-mouse": "mouse counters, button, and nonzero movement delta",
    "after-menu": "menu key bit plus menu-active status",
    "final": "duration gate crossed and all manual action bits retained",
}

SECRET_REDACTIONS: tuple[tuple[re.Pattern[str], str], ...] = (
    (
        re.compile(
            r"((?:GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*(?:TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|AUTH)[A-Z0-9_]*=)[^\s]+",
            re.IGNORECASE,
        ),
        r"\1[redacted]",
    ),
    (
        re.compile(
            r"((?:GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*=)(gh[pousr]_[A-Za-z0-9_]+)",
            re.IGNORECASE,
        ),
        r"\1[redacted]",
    ),
    (re.compile(r"gh[pousr]_[A-Za-z0-9_]+"), "[redacted]"),
    (
        re.compile(r"(Authorization:\s*(?:Bearer|token)\s+)[^\s]+", re.IGNORECASE),
        r"\1[redacted]",
    ),
    (
        re.compile(
            r"((?:access_token|token|signature|sig|X-Amz-Signature|X-Amz-Credential|X-Amz-Security-Token)=)[^&\s]+",
            re.IGNORECASE,
        ),
        r"\1[redacted]",
    ),
    (re.compile(r"Bearer\s+eyJ[A-Za-z0-9_.-]+"), "Bearer [redacted]"),
)


def _path_is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def _git_head() -> str:
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "--short=12", "HEAD"],
            cwd=ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"


def _safe_note_text(value: str, label: str) -> str:
    text = " ".join(value.strip().split())
    if not text:
        raise AssertionError(f"{label} must not be empty")
    if len(text) > 160:
        raise AssertionError(f"{label} must be 160 characters or fewer")
    allowed = set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;_/()+-")
    bad = sorted({char for char in text if char not in allowed})
    if bad:
        raise AssertionError(
            f"{label} contains unsupported characters for key=value notes: {''.join(bad)!r}"
        )
    return text


def _review_phase_notes(args: argparse.Namespace) -> dict[str, str]:
    notes: dict[str, str] = {}
    missing: list[str] = []
    for phase, attr, flag, _placeholder in REVIEW_NOTE_ARGUMENTS:
        value = getattr(args, attr, None)
        if value is None:
            missing.append(flag)
            continue
        notes[phase] = _safe_note_text(value, flag)
    if missing:
        raise AssertionError(
            "manual human review requires phase notes for start/fire/move/use/mouse/menu/final: "
            + ", ".join(missing)
        )
    return notes


def _reviewer(args: argparse.Namespace) -> str:
    reviewer = _safe_note_text(args.reviewer or args.playtester, "--reviewer")
    if not re.fullmatch(r"[A-Za-z0-9._-]{2,64}", reviewer):
        raise AssertionError(
            "--reviewer must be 2-64 characters: letters, numbers, dot, underscore, or dash"
        )
    return reviewer


def _safe_machine_text(value: str, fallback: str) -> str:
    text = " ".join((value or fallback).strip().split())
    allowed = set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;_/()+-")
    cleaned = "".join(char if char in allowed else "-" for char in text)
    cleaned = "-".join(part for part in cleaned.split("-") if part)
    return cleaned[:160] or fallback


def _memory_mb() -> int:
    meminfo = Path("/proc/meminfo")
    if meminfo.exists():
        for line in meminfo.read_text(errors="replace").splitlines():
            if line.startswith("MemTotal:"):
                parts = line.split()
                if len(parts) >= 2 and parts[1].isdigit():
                    return max(1, int(parts[1]) // 1024)
    try:
        pages = os.sysconf("SC_PHYS_PAGES")
        page_size = os.sysconf("SC_PAGE_SIZE")
        return max(1, int(pages) * int(page_size) // (1024 * 1024))
    except (AttributeError, OSError, ValueError):
        return 1


def _machine_shape(args: argparse.Namespace) -> dict:
    cpu_count = os.cpu_count() or 1
    os_text = _safe_machine_text(
        f"{platform.system()} {platform.release()}",
        "unknown-os",
    )
    arch_text = _safe_machine_text(platform.machine(), "unknown-arch")
    label = args.machine_label or f"{os_text} {arch_text} {cpu_count}cpu"
    return {
        "source": "remote-collector-status-only",
        "host_class": args.remote_host,
        "label": _safe_machine_text(label, "remote-host"),
        "cpu_count": cpu_count,
        "memory_mb": _memory_mb(),
        "os": os_text,
        "arch": arch_text,
        "qemu_location": "remote",
        "vnc_endpoint": "127.0.0.1:5901",
        "vnc_tunnel": "loopback-only",
    }


def _audio_evidence_for_mode(mode: str) -> str:
    return check_cloud_playability_artifacts.HUMAN_AUDIO_EVIDENCE_BY_MODE[mode]


def _default_audio_notes(mode: str) -> str:
    return {
        "status-only": "vnc-display-input-only-sb16-status",
        "listener-pass": "remote-audio-forwarding-listener-confirmed",
        "audio-proof-json-pass": "aggregate-audio-proof-json-validated",
        "not-tested": "audio-not-tested-in-manual-session",
    }[mode]


def _redact_log_text(text: str) -> str:
    redacted = text
    for pattern, replacement in SECRET_REDACTIONS:
        redacted = pattern.sub(replacement, redacted)
    return redacted


def _assert_output_location(output_dir: Path) -> None:
    raw_output = output_dir.expanduser()
    if not raw_output.is_absolute():
        raw_output = Path.cwd() / raw_output
    lexical_output = raw_output.absolute()
    resolved_output = output_dir.resolve()
    resolved_root = ROOT.resolve()
    if _path_is_relative_to(lexical_output, resolved_root) or _path_is_relative_to(
        resolved_output, resolved_root
    ):
        raise AssertionError(
            "proof output must live outside the repository; use /tmp or another "
            "remote scratch directory so diagnostics cannot be accidentally committed"
        )


def _assert_empty_or_missing(output_dir: Path) -> None:
    if output_dir.exists() and any(output_dir.iterdir()):
        raise AssertionError(
            f"output directory must be empty or absent before collection: {output_dir}"
        )


def _copy_exact(build_dir: Path, output_dir: Path, name: str, required: bool) -> bool:
    src = build_dir / name
    if not src.exists():
        if required:
            raise AssertionError(f"missing required diagnostic in build dir: {name}")
        return False
    if not src.is_file():
        raise AssertionError(f"diagnostic path is not a file: {src}")
    shutil.copy2(src, output_dir / name)
    return True


def _copy_required_status_files(build_dir: Path, output_dir: Path) -> list[str]:
    copied: list[str] = []
    for name in check_cloud_playability_artifacts.REQUIRED_STATUS_FILES:
        _copy_exact(build_dir, output_dir, name, required=True)
        copied.append(name)
    return copied


def _copy_patterns(build_dir: Path, output_dir: Path) -> list[str]:
    copied: list[str] = []
    for pattern in ALLOWLIST_PATTERNS:
        for src in sorted(build_dir.glob(pattern)):
            if not src.is_file():
                continue
            dst = output_dir / src.name
            if dst.exists():
                raise AssertionError(f"duplicate output diagnostic basename: {src.name}")
            _copy_redacted_log(src, dst)
            copied.append(src.name)
    return copied


def _copy_redacted_log(src: Path, dst: Path) -> None:
    size = src.stat().st_size
    if size > MAX_COPIED_LOG_BYTES:
        raise AssertionError(
            f"log diagnostic is too large for the human proof bundle: {src.name} "
            f"({size} bytes, max {MAX_COPIED_LOG_BYTES})"
        )
    raw = src.read_bytes()
    reason = check_cloud_playability_artifacts._forbidden_content_reason(src, raw)
    if reason is not None:
        raise AssertionError(f"forbidden artifact content in log {src.name}: {reason}")
    if b"\0" in raw:
        raise AssertionError(f"log diagnostic must be text, not binary: {src.name}")
    text = raw.decode("utf-8", errors="replace")
    dst.write_text(_redact_log_text(text))


def _status_filename_for_phase(phase: str) -> str:
    for phase_name, status_file, _human_action in check_cloud_playability_artifacts.HUMAN_SESSION_PHASES:
        if phase_name == phase:
            return status_file
    raise AssertionError(f"unknown capture phase: {phase}")


def _assert_monitor_filename_safe(path: Path) -> None:
    text = str(path)
    if any(char.isspace() for char in text):
        raise AssertionError(
            "temporary monitor capture path must not contain whitespace because "
            "QEMU HMP pmemsave accepts an unquoted filename argument"
        )


def _capture_status_summary(status_path: Path) -> str:
    fields = parse_status_fields(
        status_path.read_text(),
        error_type=AssertionError,
        require_any=True,
    )
    missing = [name for name in CAPTURE_REQUIRED_STATUS_FIELDS if name not in fields]
    if missing:
        preview = ", ".join(missing[:8])
        extra = "" if len(missing) <= 8 else f", and {len(missing) - 8} more"
        raise AssertionError(
            f"{status_path.name} is missing required human-session status field(s): "
            f"{preview}{extra}"
        )
    return summarize_status_fields(
        fields,
        (
            "gameplay",
            "gstate",
            "gmap",
            "gtic",
            "leveltime",
            "keyirq",
            "keyqueue",
            "keypoll",
            "mouseirq",
            "mousepkt",
            "mousepoll",
            "pflags",
            "gflags",
            "panic",
            "shutdown",
        ),
    )


def _phase_guide_lines() -> list[str]:
    lines = ["status-only phase guide:"]
    for phase, status_file, human_action in check_cloud_playability_artifacts.HUMAN_SESSION_PHASES:
        hash_note = check_cloud_playability_artifacts.HUMAN_PHASE_HASH_NOTE_KEYS[phase]
        action_note = check_cloud_playability_artifacts.HUMAN_PHASE_ACTION_NOTE_KEYS.get(phase)
        note_text = f"; action_note={action_note}" if action_note else ""
        lines.append(
            f"  - {phase}: {status_file}; action={human_action}; "
            f"expected={PHASE_STATUS_SIGNALS[phase]}; hash_note={hash_note}{note_text}"
        )
    lines.append(
        "  - duration gate: final must be at least 350 gtic and leveltime ticks after after-start"
    )
    return lines


def _send_monitor_command(monitor_socket: Path, command: str, timeout_seconds: float) -> str:
    if not monitor_socket.exists():
        raise AssertionError(f"monitor socket does not exist: {monitor_socket}")
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(timeout_seconds)
        client.connect(str(monitor_socket))
        client.sendall(command.encode("ascii") + b"\n")
        try:
            client.shutdown(socket.SHUT_WR)
        except OSError:
            pass
        chunks: list[bytes] = []
        while True:
            try:
                chunk = client.recv(4096)
            except socket.timeout:
                break
            if not chunk:
                break
            chunks.append(chunk)
    return b"".join(chunks).decode("utf-8", errors="replace")


def capture_status_phase(args: argparse.Namespace) -> Path:
    build_dir = args.build_dir.resolve()
    monitor_socket = args.monitor_socket.resolve()
    if not build_dir.exists():
        raise AssertionError(f"build directory does not exist: {build_dir}")
    if not build_dir.is_dir():
        raise AssertionError(f"build directory is not a directory: {build_dir}")
    status_file = _status_filename_for_phase(args.capture_phase)
    status_path = build_dir / status_file

    with tempfile.NamedTemporaryFile(
        dir=build_dir,
        prefix=f"{status_path.stem}.",
        suffix=".bin",
        delete=False,
    ) as handle:
        temp_bin = Path(handle.name)
    temp_bin.unlink(missing_ok=True)
    _assert_monitor_filename_safe(temp_bin)

    command = f"pmemsave {args.status_address} {args.status_bytes} {temp_bin}"
    monitor_reply = _send_monitor_command(
        monitor_socket,
        command,
        timeout_seconds=args.monitor_timeout,
    )

    deadline = time.monotonic() + args.monitor_timeout
    while not temp_bin.exists() and time.monotonic() < deadline:
        time.sleep(0.05)
    if not temp_bin.exists():
        detail = f"; monitor replied: {monitor_reply.strip()}" if monitor_reply.strip() else ""
        raise AssertionError(f"QEMU monitor did not create capture file {temp_bin}{detail}")

    raw = temp_bin.read_bytes()
    if not raw:
        temp_bin.unlink(missing_ok=True)
        raise AssertionError(f"QEMU monitor wrote an empty status capture: {temp_bin}")
    status_path.write_text(raw.replace(b"\0", b" ").decode("latin-1", errors="replace"))
    try:
        _capture_status_summary(status_path)
    finally:
        temp_bin.unlink(missing_ok=True)
    return status_path


def _write_human_notes(
    args: argparse.Namespace,
    output_dir: Path,
    phase_notes: dict[str, str],
) -> None:
    phase_hash_fields = {}
    for phase, status_file, _human_action in check_cloud_playability_artifacts.HUMAN_SESSION_PHASES:
        status_path = output_dir / status_file
        if not status_path.exists():
            raise AssertionError(f"missing required status file before notes hash: {status_file}")
        phase_hash_fields[
            check_cloud_playability_artifacts.HUMAN_PHASE_HASH_NOTE_KEYS[phase]
        ] = check_cloud_playability_artifacts._sha256_file(status_path)
    phase_action_note_fields = {
        check_cloud_playability_artifacts.HUMAN_PHASE_ACTION_NOTE_KEYS[phase]: note
        for phase, note in phase_notes.items()
    }

    fields = {
        "schema": check_cloud_playability_artifacts.HUMAN_NOTES_SCHEMA,
        "commit": args.commit or _git_head(),
        "scripted_proof": "real-wad-smoke-pass",
        "scripted_proof_run_id": args.scripted_proof_run_id,
        "scripted_proof_url": (
            f"https://github.com/jadentripp/vibe-os/actions/runs/{args.scripted_proof_run_id}"
        ),
        "scripted_proof_checked": "green-before-human-session",
        "proof_basis": "scripted-green-plus-remote-vnc-human",
        "playtester": args.playtester,
        "remote_host": args.remote_host,
        "qemu_location": "remote",
        "qemu_display": "127.0.0.1:1",
        "monitor_socket": "unix-monitor-socket",
        "vnc_tunnel": "loopback-only",
        "vnc_endpoint": "127.0.0.1:5901",
        "wad": "shareware-v1.9-validated-remote-only",
        "display": args.display,
        "keyboard": args.keyboard,
        "mouse": args.mouse,
        "audio": args.audio,
        "visual_evidence": "e1m1-visible-via-remote-vnc",
        "keyboard_evidence": "fire-move-use-menu-visible",
        "mouse_evidence": "motion-click-visible",
        "menu_evidence": "escape-menu-visible",
        "audio_evidence": _audio_evidence_for_mode(args.audio),
        "audio_notes": _safe_note_text(
            args.audio_notes or _default_audio_notes(args.audio),
            "--audio-notes",
        ),
        "slowdown": args.slowdown,
        "slowdown_notes": _safe_note_text(args.slowdown_notes, "--slowdown-notes"),
        "novnc_focus": args.novnc_focus,
        "novnc_focus_notes": _safe_note_text(args.novnc_focus_notes, "--novnc-focus-notes"),
        "status_capture": "monitor-pmemsave-0x9d000",
        "session_phases": (
            "early,after-start,after-fire,after-move,after-use,after-mouse,after-menu,final"
        ),
        "diagnostics": "non-wad-status-only",
        "proof_bundle": "allowlisted-status-only",
        "no_local_qemu": "yes",
        "no_wad_upload": "yes",
        "no_disk_upload": "yes",
        "no_pixel_upload": "yes",
        "no_screenshot_upload": "yes",
        "no_raw_audio_upload": "yes",
        "operator_scripted_proof_green": "confirmed",
        "operator_remote_vnc": "confirmed",
        "operator_e1m1_visible": "confirmed",
        "operator_keyboard_fire": "confirmed",
        "operator_keyboard_move": "confirmed",
        "operator_keyboard_use": "confirmed",
        "operator_mouse_action": "confirmed",
        "operator_menu_escape": "confirmed",
        "operator_audio_observation": "recorded",
        "operator_slowdown_notes": "recorded",
        "operator_novnc_focus_observation": "recorded",
        "operator_phase_actions": "confirmed",
        "operator_phase_status_hashes": "confirmed",
        "operator_no_forbidden_artifacts": "confirmed",
        "operator_post_download_verification": "required",
    }
    fields.update(phase_action_note_fields)
    fields.update(phase_hash_fields)
    notes = "\n".join(f"{key}={fields[key]}" for key in NOTE_FIELD_ORDER) + "\n"
    (output_dir / check_cloud_playability_artifacts.HUMAN_NOTES_FILE).write_text(notes)


def _template_value(value: str | None, placeholder: str) -> str:
    return value if value else placeholder


def _print_template(args: argparse.Namespace) -> None:
    playtester = _template_value(args.playtester, "<name-or-initials>")
    run_id = _template_value(args.scripted_proof_run_id, "<passing-real-wad-smoke-run-id>")
    commit = _template_value(args.commit, "$(git rev-parse --short=12 HEAD)")
    reviewer = _template_value(args.reviewer, playtester)
    output_dir = args.output_dir or Path("/tmp/vibe-os-human-proof")
    build_dir = args.build_dir
    monitor_socket = args.monitor_socket
    phase_guide = "\n".join(_phase_guide_lines())
    review_args = "\n".join(
        f"    {flag} \"{getattr(args, attr) or placeholder}\" \\"
        for _phase, attr, flag, placeholder in REVIEW_NOTE_ARGUMENTS
    )
    print(
        f"""human proof bundle dry-run template
remote machine guidance:
  - run inside a disposable Linux host or Codespace, never macOS QEMU
  - prefer 4+ cloud CPUs for noVNC plus QEMU TCG; 2-core hosts can stutter
  - keep WADs, disk images, status binaries, pixels, screenshots, and raw audio remote-only
  - record short human action notes for start/fire/move/use/mouse/menu/final
  - compare every phase_hash_* value after download before marking the proof reviewed

{phase_guide}

capture commands:
  for phase in early after-start after-fire after-move after-use after-mouse after-menu final; do
    python3 tools/collect_human_playtest_bundle.py \\
      --build-dir {build_dir} \\
      --monitor-socket {monitor_socket} \\
      --capture-phase "$phase"
  done

collect command:
  python3 tools/collect_human_playtest_bundle.py \\
    --build-dir {build_dir} \\
    --output-dir {output_dir} \\
    --playtester "{playtester}" \\
    --reviewer "{reviewer}" \\
    --scripted-proof-run-id "{run_id}" \\
    --commit "{commit}" \\
    --machine-label "{args.machine_label or 'Codespace-or-disposable-cloud-host'}" \\
{review_args}
    --audio {args.audio} \\
    --audio-notes "{args.audio_notes or _default_audio_notes(args.audio)}" \\
    --slowdown {args.slowdown} \\
    --slowdown-notes "{args.slowdown_notes}" \\
    --novnc-focus {args.novnc_focus} \\
    --novnc-focus-notes "{args.novnc_focus_notes}" \\
    --confirm-scripted-proof-green \\
    --confirm-remote-vnc \\
    --confirm-e1m1-visible \\
    --confirm-keyboard-fire \\
    --confirm-keyboard-move \\
    --confirm-keyboard-use \\
    --confirm-mouse-action \\
    --confirm-menu-escape \\
    --confirm-audio-observation \\
    --confirm-slowdown-notes \\
    --confirm-novnc-focus-observation \\
    --confirm-phase-actions \\
    --confirm-phase-status-hashes \\
    --confirm-no-forbidden-artifacts \\
    --confirm-post-download-verification

remote package command:
  tar -C "$(dirname "{output_dir}")" -czf /tmp/vibe-os-human-proof.tgz "$(basename "{output_dir}")"

local post-download verification:
  rm -rf ./vibe-os-human-proof
  tar -xzf ./vibe-os-human-proof.tgz
  python3 tools/check_cloud_playability_artifacts.py \\
    --human-session ./vibe-os-human-proof \\
    --expected-commit "{commit}" \\
    --expected-scripted-proof-run-id "{run_id}"
  python3 tools/check_human_playability_proof.py \\
    --require-human-session \\
    --human-notes ./vibe-os-human-proof/human-playtest-notes.txt \\
    --expected-commit "{commit}" \\
    --expected-scripted-proof-run-id "{run_id}" \\
    ./vibe-os-human-proof/status.txt

cleanup:
  - delete the disposable Codespace/remote host after downloading only the tarball
  - delete remote WAD and disk-image scratch files with the host
  - compare post-download human verification OK with the saved pre-download line
dry-run: no files were copied, QEMU was not launched, and no artifacts were read
"""
    )


def collect(args: argparse.Namespace) -> list[str]:
    if args.output_dir is None:
        raise AssertionError("--output-dir is required for bundle collection")
    if not args.playtester:
        raise AssertionError("--playtester is required for bundle collection")
    if not args.scripted_proof_run_id:
        raise AssertionError("--scripted-proof-run-id is required for bundle collection")

    build_dir = args.build_dir.resolve()
    output_dir = args.output_dir
    _assert_output_location(output_dir)
    if not build_dir.exists():
        raise AssertionError(f"build directory does not exist: {build_dir}")
    if not build_dir.is_dir():
        raise AssertionError(f"build directory is not a directory: {build_dir}")
    _assert_empty_or_missing(output_dir)
    phase_notes = _review_phase_notes(args)
    reviewer = _reviewer(args)

    output_dir.mkdir(parents=True, exist_ok=True)
    copied = _copy_required_status_files(build_dir, output_dir)
    copied.extend(_copy_patterns(build_dir, output_dir))
    for name in REQUIRED_EXACT_FILES:
        _copy_exact(build_dir, output_dir, name, required=True)
        copied.append(name)
    for name in OPTIONAL_EXACT_FILES:
        if _copy_exact(build_dir, output_dir, name, required=False):
            copied.append(name)
    _write_human_notes(args, output_dir, phase_notes)
    copied.append(check_cloud_playability_artifacts.HUMAN_NOTES_FILE)

    if args.audio == "audio-proof-json-pass" and not (output_dir / "audio-proof.json").exists():
        raise AssertionError("audio=audio-proof-json-pass requires audio-proof.json")

    observations = check_cloud_playability_artifacts.build_human_observations(output_dir)
    (output_dir / check_cloud_playability_artifacts.HUMAN_OBSERVATIONS_FILE).write_text(
        json.dumps(observations, indent=2, sort_keys=True) + "\n"
    )
    copied.append(check_cloud_playability_artifacts.HUMAN_OBSERVATIONS_FILE)

    session = check_cloud_playability_artifacts.build_human_session(output_dir)
    (output_dir / check_cloud_playability_artifacts.HUMAN_SESSION_FILE).write_text(
        json.dumps(session, indent=2, sort_keys=True) + "\n"
    )
    copied.append(check_cloud_playability_artifacts.HUMAN_SESSION_FILE)

    review = check_cloud_playability_artifacts.build_human_review(
        output_dir,
        reviewer=reviewer,
        phase_notes=phase_notes,
        machine_shape=_machine_shape(args),
    )
    (output_dir / check_cloud_playability_artifacts.HUMAN_REVIEW_FILE).write_text(
        json.dumps(review, indent=2, sort_keys=True) + "\n"
    )
    copied.append(check_cloud_playability_artifacts.HUMAN_REVIEW_FILE)

    checklist = check_cloud_playability_artifacts.build_human_checklist(output_dir)
    (output_dir / check_cloud_playability_artifacts.HUMAN_CHECKLIST_FILE).write_text(checklist)
    copied.append(check_cloud_playability_artifacts.HUMAN_CHECKLIST_FILE)

    manifest = check_cloud_playability_artifacts.build_human_manifest(output_dir)
    (output_dir / check_cloud_playability_artifacts.HUMAN_MANIFEST_FILE).write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n"
    )
    copied.append(check_cloud_playability_artifacts.HUMAN_MANIFEST_FILE)

    check_cloud_playability_artifacts.validate_artifact_dir(
        output_dir,
        require_human_notes=True,
    )
    return sorted(copied)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Collect a non-WAD, non-pixel, non-audio manual remote Doom "
            "playtest proof bundle, write the generated human checklist, and "
            "validate it."
        )
    )
    parser.add_argument(
        "--build-dir",
        type=Path,
        default=ROOT / "build",
        help="remote build directory containing status text, logs, and ELF diagnostics",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="empty scratch directory outside the repo, for example /tmp/vibe-os-human-proof",
    )
    parser.add_argument(
        "--print-template",
        action="store_true",
        help="print exact status-only human proof commands without collecting or reading artifacts",
    )
    parser.add_argument(
        "--print-phase-guide",
        action="store_true",
        help="print the status-only phase/action guide without collecting or reading artifacts",
    )
    parser.add_argument("--playtester", help="human initials or handle")
    parser.add_argument(
        "--reviewer",
        help="reviewer handle for human-playtest-review.json; defaults to --playtester",
    )
    parser.add_argument("--commit", help="commit under test; defaults to git rev-parse HEAD")
    parser.add_argument(
        "--machine-label",
        help="short status-only remote machine label, such as codespaces-4-core",
    )
    for _phase, _attr, flag, placeholder in REVIEW_NOTE_ARGUMENTS:
        parser.add_argument(
            flag,
            dest=_attr,
            help=(
                "short status-only human review note for the "
                f"{check_cloud_playability_artifacts.HUMAN_REVIEW_PHASE_LABELS[_phase]} "
                f"phase; example: {placeholder}"
            ),
        )
    parser.add_argument(
        "--capture-phase",
        choices=CAPTURE_PHASES,
        help=(
            "capture one human proof phase from the remote QEMU monitor socket, "
            "decode it to the required status text file, and exit"
        ),
    )
    parser.add_argument(
        "--monitor-socket",
        type=Path,
        default=ROOT / "build" / "monitor.remote.sock",
        help="remote QEMU monitor socket used with --capture-phase",
    )
    parser.add_argument(
        "--status-address",
        default="0x9d000",
        help="guest physical address of the text status page for monitor pmemsave",
    )
    parser.add_argument(
        "--status-bytes",
        type=int,
        default=8192,
        help="number of bytes to copy from the guest status page",
    )
    parser.add_argument(
        "--monitor-timeout",
        type=float,
        default=5.0,
        help="seconds to wait for the remote monitor capture to complete",
    )
    parser.add_argument(
        "--remote-host",
        default="disposable",
        choices=("disposable",),
        help="remote host class attested by the human notes",
    )
    parser.add_argument(
        "--scripted-proof-run-id",
        help="passing GitHub Actions Real WAD smoke run ID this human session follows",
    )
    parser.add_argument("--display", default="pass", choices=("pass",))
    parser.add_argument("--keyboard", default="pass", choices=("pass",))
    parser.add_argument("--mouse", default="pass", choices=("pass",))
    parser.add_argument(
        "--slowdown",
        default="not-observed",
        choices=SLOWDOWN_CHOICES,
        help="human slowdown observation during the remote VNC session",
    )
    parser.add_argument(
        "--slowdown-notes",
        default="not-observed-during-capture",
        help="short status-only slowdown note; no screenshots, audio, or env dumps",
    )
    parser.add_argument(
        "--audio",
        default="status-only",
        choices=("status-only", "listener-pass", "audio-proof-json-pass", "not-tested"),
    )
    parser.add_argument(
        "--audio-notes",
        help="short status-only audio observation note; no raw audio, screenshots, or env dumps",
    )
    parser.add_argument(
        "--novnc-focus",
        default="canvas-focused-before-actions",
        choices=NOVNC_FOCUS_CHOICES,
        help="operator noVNC canvas focus observation during the remote session",
    )
    parser.add_argument(
        "--novnc-focus-notes",
        default="canvas-clicked-before-each-manual-action",
        help="short status-only noVNC focus note; no screenshots or env dumps",
    )
    parser.add_argument(
        "--confirm-scripted-proof-green",
        action="store_true",
        help="operator confirms the linked Real WAD smoke run was green before human play",
    )
    parser.add_argument(
        "--confirm-remote-vnc",
        action="store_true",
        help="operator confirms they used the remote VNC display, not local QEMU",
    )
    parser.add_argument(
        "--confirm-e1m1-visible",
        action="store_true",
        help="operator confirms E1M1 or a playable Doom view was visible before action proof",
    )
    parser.add_argument(
        "--confirm-keyboard-fire",
        action="store_true",
        help="operator confirms Ctrl/fire visibly affected Doom",
    )
    parser.add_argument(
        "--confirm-keyboard-move",
        action="store_true",
        help="operator confirms arrow-key movement or turning visibly affected Doom",
    )
    parser.add_argument(
        "--confirm-keyboard-use",
        action="store_true",
        help="operator confirms Space/use visibly affected Doom",
    )
    parser.add_argument(
        "--confirm-mouse-action",
        action="store_true",
        help="operator confirms remote mouse movement/click visibly affected Doom",
    )
    parser.add_argument(
        "--confirm-menu-escape",
        action="store_true",
        help="operator confirms Escape visibly opened the Doom menu",
    )
    parser.add_argument(
        "--confirm-audio-observation",
        action="store_true",
        help=(
            "operator confirms the audio observation mode was recorded: status-only, "
            "listener-pass, audio-proof-json-pass, or not-tested"
        ),
    )
    parser.add_argument(
        "--confirm-slowdown-notes",
        action="store_true",
        help="operator confirms slowdown notes were recorded, even if none was observed",
    )
    parser.add_argument(
        "--confirm-novnc-focus-observation",
        action="store_true",
        help="operator confirms noVNC canvas focus observations were recorded",
    )
    parser.add_argument(
        "--confirm-phase-actions",
        action="store_true",
        help="operator confirms the required start/fire/move/use/mouse/menu actions were visibly tried",
    )
    parser.add_argument(
        "--confirm-phase-status-hashes",
        action="store_true",
        help="operator confirms status files were captured after each named phase before collection",
    )
    parser.add_argument(
        "--confirm-no-forbidden-artifacts",
        action="store_true",
        help="operator confirms WADs, disk images, pixels, screenshots, and raw audio are excluded",
    )
    parser.add_argument(
        "--confirm-post-download-verification",
        action="store_true",
        help="operator confirms the downloaded bundle must be rechecked locally with --human-session",
    )
    args = parser.parse_args(argv)
    if args.print_phase_guide:
        print("\n".join(_phase_guide_lines()))
        return 0
    if args.print_template:
        _print_template(args)
        return 0

    if args.capture_phase:
        try:
            status_path = capture_status_phase(args)
        except (OSError, AssertionError) as exc:
            print(f"human status capture failed: {exc}", file=sys.stderr)
            return 1
        print(f"human status capture OK: {status_path}")
        print(f"status audit summary: {_capture_status_summary(status_path)}")
        print(
            f"phase expectation: {args.capture_phase} -> {status_path.name}; "
            f"{PHASE_STATUS_SIGNALS[args.capture_phase]}"
        )
        return 0

    for attr, flag in REQUIRED_CONFIRMATION_FLAGS:
        if not getattr(args, attr):
            parser.error(f"{flag} is required for manual human evidence collection")

    try:
        copied = collect(args)
        verification = check_cloud_playability_artifacts.build_human_post_download_verification(
            args.output_dir
        )
    except (OSError, AssertionError) as exc:
        print(f"human playtest bundle collection failed: {exc}", file=sys.stderr)
        return 1

    print(f"human playtest bundle OK: {args.output_dir}")
    print(
        check_cloud_playability_artifacts.format_human_post_download_verification(
            verification,
            label="pre-download human verification OK",
        )
    )
    for name in copied:
        print(f"  {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
