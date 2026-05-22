#!/usr/bin/env python3
"""Prepare the opt-in disposable-cloud OVMF proof path.

The default contract mode is intentionally host-only: it rebuilds the current
UEFI packaging artifacts, writes a JSON proof manifest, and does not require or
invoke QEMU/OVMF. The OVMF attempt/prove modes are reserved for GitHub Actions
Ubuntu runners so local macOS development never needs QEMU to run this checker.

This script does not claim UEFI boot support. The EFI loader can read the
kernel, collect GOP and memory-map data, call ExitBootServices, and attempt the
handoff into the current 32-bit kernel only after validating the synthesized
legacy boot-info/E820 block. The kernel has a source-level
`VIBEKERN` UEFI entry marker, but SUPPORT[UEFI] remains unclaimed until that
kernel-owned marker and its status fields are captured under OVMF.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
import time
from pathlib import Path

import build_host_artifacts


ROOT = Path(__file__).resolve().parents[2]

DEFAULT_BLOCKERS = (
    "OVMF proof must run on a disposable GitHub Actions Ubuntu runner",
    "ExitBootServices success is an intermediate loader proof until the kernel marker is captured",
    "the loader now attempts the 64-bit UEFI to 32-bit protected-mode handoff after ExitBootServices",
    "the source-level kernel-owned UEFI entry marker and status fields still need disposable OVMF proof",
    "SUPPORT[UEFI] remains unclaimed until the current kernel is proven entered from OVMF",
)

ARTIFACT_POLICY = {
    "uploads_json_manifests_only": True,
    "uploads_esp_image": False,
    "uploads_efi_binary": False,
    "uploads_pflash_vars": False,
    "uploads_wad_data": False,
    "uploads_disk_image": False,
    "uploads_pixel_dump": False,
    "uploads_raw_audio": False,
    "uploads_vm_logs": False,
    "uploads_parsed_debugcon_markers": True,
}

STEP_ORDER = (
    "entry",
    "esp-kernel-read",
    "low-memory-reserve",
    "elf32-load",
    "gop",
    "memory-map",
    "boot-info",
    "handoff-plan",
    "low-handoff-copy",
    "exit-boot-services",
    "kernel-handoff",
)

KERNEL_ENTRY_REQUIRED_FIELDS = {
    "handoff": 0x00009000,
    "bootinfo": 0x00007000,
    "e820": 0x00007100,
}
KERNEL_ENTRY_REQUIRED_FLAG_MASK = 0x0000007F
LOADER_HANDOFF_REQUIRED_FIELDS = {
    "handoff": 0x00009000,
    "bootinfo": 0x00007000,
    "e820": 0x00007100,
    "tramp32": 0x00008000,
    "transition64": 0x0000A000,
}
LOADER_HANDOFF_REQUIRED_FLAG_MASK = 0x0000007F

OVMF_CODE_CANDIDATES = (
    "/usr/share/OVMF/OVMF_CODE_4M.fd",
    "/usr/share/OVMF/OVMF_CODE.fd",
    "/usr/share/edk2/ovmf/OVMF_CODE.fd",
    "/usr/share/qemu/OVMF_CODE.fd",
)

OVMF_VARS_CANDIDATES = (
    "/usr/share/OVMF/OVMF_VARS_4M.fd",
    "/usr/share/OVMF/OVMF_VARS.fd",
    "/usr/share/edk2/ovmf/OVMF_VARS.fd",
    "/usr/share/qemu/OVMF_VARS.fd",
)


def _first_existing(paths: tuple[str, ...]) -> Path | None:
    for path in paths:
        candidate = Path(path)
        if candidate.exists():
            return candidate
    return None


def _resolve_ovmf_path(explicit: Path | None, env_name: str, candidates: tuple[str, ...]) -> Path:
    if explicit is not None:
        return explicit
    env_value = os.environ.get(env_name)
    if env_value:
        return Path(env_value)
    candidate = _first_existing(candidates)
    if candidate is not None:
        return candidate
    raise RuntimeError(f"could not find {env_name}; install ovmf on the GitHub Actions runner")


def _guard_disposable_actions_runner(allow_non_actions: bool) -> None:
    if allow_non_actions:
        return
    if platform.system() == "Darwin":
        raise RuntimeError("OVMF attempts are not local macOS checks; run the workflow on GitHub Actions")
    if os.environ.get("GITHUB_ACTIONS") != "true" or os.environ.get("RUNNER_OS") != "Linux":
        raise RuntimeError("OVMF attempts require a GitHub Actions Linux runner")


def _relative(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def _build_packaging(kernel: Path, out_dir: Path) -> dict[str, object]:
    artifact_dir = out_dir / "host-artifacts"
    manifest = build_host_artifacts.build_artifacts(kernel, artifact_dir)
    return {
        "manifest": manifest,
        "artifact_dir": _relative(artifact_dir),
        "efi_application": _relative(artifact_dir / "BOOTX64.EFI"),
        "esp_image": _relative(artifact_dir / "esp.img"),
        "manifest_path": _relative(artifact_dir / "manifest.json"),
    }


def _qemu_command(
    qemu: str,
    ovmf_code: Path,
    ovmf_vars: Path,
    esp_image: Path,
    debugcon_path: Path,
) -> list[str]:
    return [
        qemu,
        "-machine",
        "q35,accel=tcg",
        "-m",
        "256M",
        "-display",
        "none",
        "-monitor",
        "none",
        "-serial",
        "none",
        "-net",
        "none",
        "-no-reboot",
        "-boot",
        "order=c",
        "-debugcon",
        f"file:{debugcon_path}",
        "-global",
        "isa-debugcon.iobase=0x402",
        "-device",
        "isa-debug-exit,iobase=0x501,iosize=0x02",
        "-drive",
        f"if=pflash,format=raw,readonly=on,file={ovmf_code}",
        "-drive",
        f"if=pflash,format=raw,file={ovmf_vars}",
        "-drive",
        f"file={esp_image},format=raw,if=virtio,media=disk",
    ]


def _parse_debugcon_markers(debugcon_text: str) -> dict[str, object]:
    markers: list[dict[str, str]] = []
    kernel_markers: list[dict[str, str]] = []
    last_step = "none"
    proof_step = "none"
    exit_boot_services = False
    kernel_handoff = "not-reached"
    kernel_handoff_after_exit_boot_services = False
    loader_handoff_valid = False
    loader_handoff_evidence: dict[str, str] | None = None
    kernel_booted = False
    kernel_entry_after_exit_boot_services = False
    kernel_entry_status = "missing"
    kernel_entry_candidate: dict[str, str] | None = None
    kernel_entry_evidence: dict[str, str] | None = None
    errors: list[dict[str, str]] = []

    for raw_line in debugcon_text.splitlines():
        line = raw_line.strip()
        if line.startswith("VIBEKERN "):
            fields = {}
            for token in line.split()[1:]:
                if "=" not in token:
                    continue
                key, value = token.split("=", 1)
                fields[key] = value
            if not fields:
                continue
            kernel_markers.append(fields)
            if fields.get("step") == "uefi-entry":
                kernel_entry_status = fields.get("status", "missing")
            if _valid_kernel_entry_marker(fields):
                if kernel_entry_candidate is None:
                    kernel_entry_candidate = fields
                if exit_boot_services and kernel_handoff_after_exit_boot_services:
                    kernel_booted = True
                    kernel_entry_after_exit_boot_services = True
                    proof_step = "kernel-entry"
                    kernel_entry_evidence = fields
            continue

        if not line.startswith("VIBEUEFI "):
            continue
        fields: dict[str, str] = {}
        for token in line.split()[1:]:
            if "=" not in token:
                continue
            key, value = token.split("=", 1)
            fields[key] = value
        if not fields:
            continue
        markers.append(fields)

        step = fields.get("step")
        if step in STEP_ORDER:
            last_step = step
            if step != "kernel-handoff":
                proof_step = step
        if step == "exit-boot-services" and fields.get("status") == "success":
            exit_boot_services = True
        if step == "kernel-handoff":
            kernel_handoff = fields.get("status", "reached")
            if exit_boot_services and _valid_loader_handoff_attempt_marker(fields):
                if loader_handoff_evidence is None:
                    loader_handoff_evidence = fields
                loader_handoff_valid = True
                kernel_handoff_after_exit_boot_services = True
                proof_step = "kernel-handoff"
        if "error" in fields:
            errors.append(fields)

    return {
        "markers": markers,
        "marker_count": len(markers),
        "last_step": last_step,
        "proof_step": proof_step,
        "exit_boot_services": exit_boot_services,
        "kernel_handoff": kernel_handoff,
        "kernel_handoff_after_exit_boot_services": kernel_handoff_after_exit_boot_services,
        "loader_handoff_valid": loader_handoff_valid,
        "loader_handoff_evidence": loader_handoff_evidence or {},
        "kernel_booted": kernel_booted,
        "kernel_entry_after_exit_boot_services": kernel_entry_after_exit_boot_services,
        "kernel_entry_status": kernel_entry_status,
        "kernel_entry_evidence": kernel_entry_evidence or kernel_entry_candidate or {},
        "kernel_markers": kernel_markers,
        "errors": errors,
    }


def _valid_loader_handoff_attempt_marker(fields: dict[str, str]) -> bool:
    if fields.get("step") != "kernel-handoff" or fields.get("status") != "attempting":
        return False
    for key, expected in LOADER_HANDOFF_REQUIRED_FIELDS.items():
        value = fields.get(key)
        if value is None or _parse_marker_hex(value) != expected:
            return False
    for key in ("entry32", "segments"):
        value = fields.get(key)
        if not value:
            return False
        parsed = _parse_marker_hex(value)
        if parsed is None or parsed == 0:
            return False
    flags = fields.get("flags")
    parsed_flags = _parse_marker_hex(flags) if flags else None
    if parsed_flags is None:
        return False
    if parsed_flags & LOADER_HANDOFF_REQUIRED_FLAG_MASK != LOADER_HANDOFF_REQUIRED_FLAG_MASK:
        return False
    return True


def _valid_kernel_entry_marker(fields: dict[str, str]) -> bool:
    if fields.get("step") != "uefi-entry" or fields.get("status") != "OK":
        return False
    for key, expected in KERNEL_ENTRY_REQUIRED_FIELDS.items():
        value = fields.get(key)
        if value is None or _parse_marker_hex(value) != expected:
            return False
    for key in ("entry", "segments"):
        value = fields.get(key)
        if not value:
            return False
        parsed = _parse_marker_hex(value)
        if parsed is None or parsed == 0:
            return False
    flags = fields.get("flags")
    parsed_flags = _parse_marker_hex(flags) if flags else None
    if parsed_flags is None:
        return False
    if parsed_flags & KERNEL_ENTRY_REQUIRED_FLAG_MASK != KERNEL_ENTRY_REQUIRED_FLAG_MASK:
        return False
    return True


def _parse_marker_hex(value: str) -> int | None:
    try:
        return int(value, 16)
    except ValueError:
        return None


def _run_ovmf_attempt(args: argparse.Namespace, out_dir: Path, host: dict[str, object]) -> dict[str, object]:
    _guard_disposable_actions_runner(args.allow_non_actions)

    qemu = shutil.which(args.qemu)
    if qemu is None:
        raise RuntimeError(f"missing {args.qemu}; install qemu-system-x86 on the runner")

    ovmf_code = _resolve_ovmf_path(args.ovmf_code, "OVMF_CODE", OVMF_CODE_CANDIDATES)
    ovmf_vars_template = _resolve_ovmf_path(args.ovmf_vars, "OVMF_VARS", OVMF_VARS_CANDIDATES)
    ovmf_vars = out_dir / "OVMF_VARS.fd"
    shutil.copyfile(ovmf_vars_template, ovmf_vars)

    esp_image = ROOT / str(host["esp_image"])
    debugcon_path = out_dir / "debugcon.markers"
    command = _qemu_command(qemu, ovmf_code, ovmf_vars, esp_image, debugcon_path)
    start = time.monotonic()
    try:
        completed = subprocess.run(
            command,
            cwd=ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=args.timeout_seconds,
            check=False,
        )
        elapsed = time.monotonic() - start
        outcome = "guest-exited"
        returncode: int | None = completed.returncode
    except subprocess.TimeoutExpired:
        elapsed = time.monotonic() - start
        outcome = "timeout"
        returncode = None

    debugcon_text = debugcon_path.read_text(encoding="ascii", errors="replace") if debugcon_path.exists() else ""
    parsed_markers = _parse_debugcon_markers(debugcon_text)
    if parsed_markers["kernel_booted"]:
        proof = "kernel-entry-marker"
    elif parsed_markers["exit_boot_services"]:
        proof = "exit-boot-services"
    elif parsed_markers["marker_count"]:
        proof = "partial-loader-step"
    else:
        proof = "not-proven"

    return {
        "execution": "run",
        "runner": "github-actions-ubuntu",
        "outcome": outcome,
        "returncode": returncode,
        "elapsed_seconds": round(elapsed, 3),
        "timeout_seconds": args.timeout_seconds,
        "handoff_step_reached": parsed_markers["last_step"],
        "proof_step_reached": parsed_markers["proof_step"],
        "exit_boot_services": parsed_markers["exit_boot_services"],
        "kernel_handoff": parsed_markers["kernel_handoff"],
        "kernel_handoff_after_exit_boot_services": parsed_markers[
            "kernel_handoff_after_exit_boot_services"
        ],
        "loader_handoff_valid": parsed_markers["loader_handoff_valid"],
        "loader_handoff_evidence": parsed_markers["loader_handoff_evidence"],
        "loader_handoff_required_flag_mask": f"0x{LOADER_HANDOFF_REQUIRED_FLAG_MASK:08X}",
        "kernel_booted": parsed_markers["kernel_booted"],
        "kernel_entry_after_exit_boot_services": parsed_markers["kernel_entry_after_exit_boot_services"],
        "kernel_status_evidence_required": True,
        "kernel_entry_status": parsed_markers["kernel_entry_status"],
        "kernel_entry_evidence": parsed_markers["kernel_entry_evidence"],
        "kernel_entry_required_flag_mask": f"0x{KERNEL_ENTRY_REQUIRED_FLAG_MASK:08X}",
        "proof": proof,
        "debugcon_markers": parsed_markers["markers"],
        "kernel_debugcon_markers": parsed_markers["kernel_markers"],
        "debugcon_marker_count": parsed_markers["marker_count"],
        "kernel_debugcon_marker_count": len(parsed_markers["kernel_markers"]),
        "debugcon_errors": parsed_markers["errors"],
        "debugcon_file": _relative(debugcon_path),
        "debugcon_uploaded": False,
        "qemu_command": command,
        "ovmf_code": str(ovmf_code),
        "ovmf_vars_template": str(ovmf_vars_template),
        "ovmf_vars_copy": _relative(ovmf_vars),
        "result_note": "UEFI remains unclaimed until OVMF captures the kernel-owned VIBEKERN entry marker and status fields.",
    }


def build_manifest(args: argparse.Namespace) -> dict[str, object]:
    out_dir = args.out_dir
    out_dir.mkdir(parents=True, exist_ok=True)
    kernel = args.kernel
    if not kernel.exists():
        raise RuntimeError(f"kernel does not exist: {kernel}")

    host = _build_packaging(kernel, out_dir)
    if args.mode == "contract":
        ovmf: dict[str, object] = {
            "execution": "not-run",
            "runner": "github-actions-ubuntu",
            "proof": "not-proven",
            "proof_target": "kernel-entry-debugcon-marker",
            "kernel_status_evidence_required": True,
            "loader_handoff_evidence_required": True,
            "kernel_handoff_after_exit_boot_services": False,
            "loader_handoff_valid": False,
            "loader_handoff_evidence": {},
            "loader_handoff_required_flag_mask": f"0x{LOADER_HANDOFF_REQUIRED_FLAG_MASK:08X}",
            "kernel_booted": False,
            "kernel_entry_after_exit_boot_services": False,
            "kernel_entry_status": "not-run",
            "kernel_entry_evidence": {},
            "kernel_entry_required_flag_mask": f"0x{KERNEL_ENTRY_REQUIRED_FLAG_MASK:08X}",
            "reason": "contract mode is QEMU-free and safe for local hosts",
        }
    else:
        ovmf = _run_ovmf_attempt(args, out_dir, host)

    return {
        "schema": "uefi-ovmf-cloud-proof-v1",
        "mode": args.mode,
        "support_claim": "unclaimed",
        "support_row": "SUPPORT[UEFI]",
        "uefi_boot_rows_moved": True,
        "local_qemu_required": False,
        "local_mac_qemu_required": False,
        "cloud_runner": "github-actions-ubuntu",
        "host_artifacts": host,
        "ovmf": ovmf,
        "artifact_policy": ARTIFACT_POLICY,
        "remaining_blockers": list(DEFAULT_BLOCKERS),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kernel", type=Path, required=True, help="kernel ELF bytes to package at VIBEOS/KERNEL.ELF")
    parser.add_argument("--out-dir", type=Path, required=True, help="directory for generated UEFI proof scratch data")
    parser.add_argument(
        "--mode",
        choices=("contract", "attempt", "prove"),
        default="contract",
        help="contract is QEMU-free; attempt/prove run OVMF on GitHub Actions and prove the kernel entry marker",
    )
    parser.add_argument("--qemu", default="qemu-system-x86_64", help="QEMU executable used by attempt/prove modes")
    parser.add_argument("--ovmf-code", type=Path, help="OVMF_CODE fd path for attempt/prove modes")
    parser.add_argument("--ovmf-vars", type=Path, help="OVMF_VARS fd template path for attempt/prove modes")
    parser.add_argument("--timeout-seconds", type=int, default=20, help="OVMF attempt timeout")
    parser.add_argument(
        "--allow-non-actions",
        action="store_true",
        help="developer escape hatch for Linux lab repro; never needed for local macOS contract checks",
    )
    args = parser.parse_args()

    try:
        manifest = build_manifest(args)
    except (RuntimeError, ValueError) as exc:
        print(f"UEFI OVMF proof setup failed: {exc}", file=sys.stderr)
        return 1

    manifest_path = args.out_dir / "ovmf-proof-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2, sort_keys=True))

    if args.mode == "prove" and not manifest["ovmf"].get("kernel_booted"):
        print(
            "UEFI OVMF proof failed: the kernel did not emit its UEFI entry marker after ExitBootServices.",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
