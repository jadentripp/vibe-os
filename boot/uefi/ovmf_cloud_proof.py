#!/usr/bin/env python3
"""Prepare the opt-in disposable-cloud OVMF proof path.

The default contract mode is intentionally host-only: it rebuilds the current
UEFI packaging artifacts, writes a JSON proof manifest, and does not require or
invoke QEMU/OVMF. The OVMF attempt/prove modes are reserved for GitHub Actions
Ubuntu runners so local macOS development never needs QEMU to run this checker.

This script does not claim UEFI boot support. Until a future EFI loader reads
the kernel, fills GOP and memory-map handoff data, calls ExitBootServices, and
enters the kernel successfully, SUPPORT[UEFI] remains unclaimed.
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
    "BOOTX64.EFI is still an EFI_UNSUPPORTED host stub",
    "no ESP/FAT kernel reader exists in the EFI application",
    "no GOP framebuffer boot-info handoff exists",
    "no UEFI memory map handoff exists",
    "ExitBootServices is not called",
    "the current kernel is not entered from an OVMF boot",
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
}

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
        "-drive",
        f"if=pflash,format=raw,readonly=on,file={ovmf_code}",
        "-drive",
        f"if=pflash,format=raw,file={ovmf_vars}",
        "-drive",
        f"file={esp_image},format=raw,if=virtio,media=disk",
    ]


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
    command = _qemu_command(qemu, ovmf_code, ovmf_vars, esp_image)
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

    # Today there is no trustworthy UEFI status marker to parse. A future loader
    # must replace this with a kernel-entry proof before mode=prove can pass.
    return {
        "execution": "run",
        "runner": "github-actions-ubuntu",
        "outcome": outcome,
        "returncode": returncode,
        "elapsed_seconds": round(elapsed, 3),
        "timeout_seconds": args.timeout_seconds,
        "kernel_booted": False,
        "proof": "not-proven",
        "qemu_command": command,
        "ovmf_code": str(ovmf_code),
        "ovmf_vars_template": str(ovmf_vars_template),
        "ovmf_vars_copy": _relative(ovmf_vars),
        "result_note": "OVMF execution is only an attempt until a UEFI kernel-entry marker exists.",
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
            "reason": "contract mode is QEMU-free and safe for local hosts",
        }
    else:
        ovmf = _run_ovmf_attempt(args, out_dir, host)

    return {
        "schema": "uefi-ovmf-cloud-proof-v1",
        "mode": args.mode,
        "support_claim": "unclaimed",
        "support_row": "SUPPORT[UEFI]",
        "uefi_boot_rows_moved": False,
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
        help="contract is QEMU-free; attempt/prove require GitHub Actions OVMF",
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
        print("UEFI OVMF proof failed: the current loader did not boot the kernel.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
