#!/usr/bin/env python3
"""Validate VM opt-in, cloud diagnostics, and panic/shutdown evidence contracts."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def _read(root: Path, relative: str) -> str:
    return (root / relative).read_text()


def _require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label} missing {needle!r}")


def _target_line(makefile: str, target: str) -> str:
    match = re.search(rf"^{re.escape(target)}:[^\n]*", makefile, re.MULTILINE)
    if not match:
        raise AssertionError(f"Makefile missing {target} target")
    return match.group(0)


def _target_block(makefile: str, target: str) -> str:
    line = _target_line(makefile, target)
    start = makefile.index(line)
    next_target = re.search(r"^[A-Za-z0-9_.-]+:[^\n]*", makefile[start + len(line) :], re.MULTILINE)
    if next_target is None:
        return makefile[start:]
    return makefile[start : start + len(line) + next_target.start()]


def _upload_block(workflow: str) -> str:
    marker = "uses: actions/upload-artifact@v4"
    if marker not in workflow:
        raise AssertionError("workflow must upload diagnostics")
    return workflow.split(marker, 1)[1]


def validate_repo_contract(root: Path = ROOT) -> None:
    makefile = _read(root, "Makefile")
    smoke_runner = _read(root, "tests/run_smoke_qemu.sh")
    os_workflow = _read(root, ".github/workflows/os-smoke.yml")
    real_wad_workflow = _read(root, ".github/workflows/real-wad-smoke.yml")
    kernel = _read(root, "kernel/kernel.asm")
    gap_doc = _read(root, "docs/post-checkpoint-gaps.md")
    tests_readme = _read(root, "tests/README.md")

    _require(makefile, "ALLOW_LOCAL_VM ?= 0", "Makefile")
    _require(makefile, "vm-consent:", "Makefile")
    for target in ("run", "run-headless", "smoke"):
        line = _target_line(makefile, target)
        if "vm-consent" not in line:
            raise AssertionError(f"{target} target must depend on vm-consent")

    test_block = _target_block(makefile, "test").lower()
    if "qemu" in test_block:
        raise AssertionError("make test must not launch or require QEMU")
    _require(makefile, "vm-safety-check:", "Makefile")
    _require(makefile, "tools/check_vm_safety_contract.py", "Makefile")
    _require(makefile, 'grep -Eq "panic=(NONE|KEXC)"', "Makefile")
    _require(makefile, 'grep -Eq "shutdown=(NONE|HALT|REBOOT)"', "Makefile")

    for needle in (
        "trap cleanup EXIT INT TERM",
        "capture_snapshot failure",
        "pmemsave 0x9d000 2048",
        "-serial \"file:$serial_log\"",
        "-monitor \"unix:$monitor_sock,server,nowait\"",
        "-no-reboot",
        "-no-shutdown",
        "SMOKE_SHUTDOWN_TIMEOUT",
        "wait_for_shutdown",
        "kill -9 \"$qemu_pid\"",
    ):
        _require(smoke_runner, needle, "smoke runner")

    for workflow, label in (
        (os_workflow, "OS smoke workflow"),
        (real_wad_workflow, "real-WAD workflow"),
    ):
        _require(workflow, "runs-on: ubuntu-latest", label)
        _require(workflow, "ALLOW_LOCAL_VM=1", label)
        _require(workflow, "if: always()", label)
        upload = _upload_block(workflow)
        for needle in ("build/status*.txt", "build/status*.bin", "build/*.log", "build/doom.symbols"):
            _require(upload, needle, label)
        for forbidden in ("build/disk.img", "build/gfx.bin", "DOOM1.WAD", "*.WAD", "*.wad"):
            if forbidden in upload:
                raise AssertionError(f"{label} upload block includes forbidden artifact {forbidden}")

    for needle in (
        "SMOKE_SKIP_ASSERTIONS=1",
        "Assert real-WAD proof gates",
        "Assert scripted human-playability gates",
        "Triage cloud status",
        "tools/triage_cloud_status.py build/status.txt",
        "Show smoke diagnostics",
        'rm -f "$WAD_PATH"',
    ):
        _require(real_wad_workflow, needle, "real-WAD workflow")

    for needle in (
        "PANIC_UNHANDLED_EXCEPTION equ 1",
        "SHUTDOWN_HALT equ 1",
        "SHUTDOWN_REBOOT equ 2",
        "panic_status dd 0",
        "shutdown_state dd 0",
        'smoke_panic_text db " panic="',
        'smoke_shutdown_text db " shutdown="',
        "mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION",
        "call write_smoke_status",
        "mov dword [shutdown_state], SHUTDOWN_HALT",
        "mov dword [shutdown_state], SHUTDOWN_REBOOT",
    ):
        _require(kernel, needle, "kernel")

    panic_path = kernel.split(".not_expected_user_fault:", 1)[1].split("doom_user_fault:", 1)[0]
    _require(panic_path, "mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION", "kernel panic path")
    _require(panic_path, "call write_smoke_status", "kernel panic path")
    if panic_path.index("mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION") > panic_path.index("call write_smoke_status"):
        raise AssertionError("panic status must be set before the smoke status write")

    for needle in (
        "panic=KEXC",
        "shutdown=HALT",
        "shutdown=REBOOT",
        "tools/check_vm_safety_contract.py",
    ):
        _require(gap_doc, needle, "gap ledger")
    _require(tests_readme, "tools/check_vm_safety_contract.py", "tests README")


def main() -> int:
    try:
        validate_repo_contract()
    except AssertionError as exc:
        print(f"VM safety contract failed: {exc}", file=sys.stderr)
        return 1

    print("VM safety contract OK: local QEMU opt-in, cloud diagnostics, and panic/shutdown status are machine-checkable")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
