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
    _require(makefile, "shutdown-panic-proof-check:", "Makefile")
    _require(makefile, "tools/check_shutdown_panic_proof.py --repo-contract", "Makefile")
    _require(makefile, "KERNEL_EXTRA_NASMFLAGS ?=", "Makefile")
    _require(makefile, 'grep -Eq "panic=(NONE|KEXC)"', "Makefile")
    _require(makefile, 'grep -Eq "shutdown=(NONE|HALT|REBOOT|POWEROFF)"', "Makefile")

    for needle in (
        "trap cleanup EXIT INT TERM",
        "capture_snapshot failure",
        "pmemsave 0x9d000 4096",
        "-serial \"file:$serial_log\"",
        "-monitor \"unix:$monitor_sock,server,nowait\"",
        "-no-reboot",
        "-no-shutdown",
        "SMOKE_EXPECT_GUEST_EXIT",
        "wait_for_guest_exit",
        "SMOKE_SHUTDOWN_TIMEOUT",
        "wait_for_shutdown",
        "kill -9 \"$qemu_pid\"",
    ):
        _require(smoke_runner, needle, "smoke runner")

    for needle in (
        "shutdown_panic_proof:",
        "SHUTDOWN_PANIC_PROOF_PANIC",
        "SHUTDOWN_PANIC_PROOF_HALT",
        "SHUTDOWN_PANIC_PROOF_REBOOT",
        "SHUTDOWN_PANIC_PROOF_POWEROFF",
        "--manifest build/shutdown-panic-proof/shutdown-panic-proof.json",
        "build/shutdown-panic-proof/**",
        "build/proof-*/*.log",
    ):
        _require(os_workflow, needle, "OS smoke workflow")

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
        "SHUTDOWN_POWEROFF equ 3",
        "panic_status dd 0",
        "shutdown_state dd 0",
        "SHUTDOWN_PANIC_PROOF_PANIC",
        "SHUTDOWN_PANIC_PROOF_HALT",
        "SHUTDOWN_PANIC_PROOF_REBOOT",
        "SHUTDOWN_PANIC_PROOF_POWEROFF",
        'smoke_panic_text db " panic="',
        'smoke_shutdown_text db " shutdown="',
        "mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION",
        "call write_smoke_status",
        "mov dword [shutdown_state], SHUTDOWN_HALT",
        "mov dword [shutdown_state], SHUTDOWN_REBOOT",
        "mov dword [shutdown_state], SHUTDOWN_POWEROFF",
        "RESET_CONTROL_PORT equ 0x0cf9",
        "RESET_CONTROL_FULL_RESET equ 0x06",
        "SHUTDOWN_PROOF_DELAY_TICKS equ 2000",
        "shutdown_proof_wait_before_guest_exit:",
        "call pic_unmask_timer",
        "acpi_poweroff:",
    ):
        _require(kernel, needle, "kernel")

    for needle in (
        "KERNEL_HIGHER_HALF_BASE equ 0xc0000000",
        "KERNEL_HIGHER_HALF_PDE_INDEX equ KERNEL_HIGHER_HALF_BASE >> 22",
        "VMM_HIGH_TEST_VADDR equ KERNEL_HIGHER_HALF_BASE",
        "vmm_dynamic_page_tables dd 0",
        "vmm_active_page_tables dd 0",
        "vmm_reclaimed_page_tables dd 0",
        "vmm_last_reclaimed_page_table dd 0",
        "vmm_user_guard_pages dd 0",
        "vmm_high_mapping_status db 0",
        "vmm_clear_process_guard_page:",
        "call vmm_clear_process_guard_page",
        "vmm_unmap_page:",
        "mov dword [VMM_HIGH_TEST_VADDR], VMM_HIGH_TEST_MAGIC",
        "mov byte [vmm_high_mapping_status], 1",
    ):
        _require(kernel, needle, "kernel VM contract")

    vmm_map = kernel.split("vmm_map_page:", 1)[1].split("vmm_unmap_page:", 1)[0]
    for needle in (
        "call pmm_alloc_page",
        "inc dword [vmm_dynamic_page_tables]",
        "inc dword [vmm_active_page_tables]",
    ):
        _require(vmm_map, needle, "dynamic VMM mapper")
    if "cmp edx, PAGING_TOTAL_PAGES" in vmm_map:
        raise AssertionError("vmm_map_page must not be limited to the static identity table span")

    vmm_unmap = kernel.split("vmm_unmap_page:", 1)[1].split("vmm_identity_page:", 1)[0]
    for needle in (
        "mov [vmm_map_pde_ptr], edi",
        "mov [vmm_map_table_addr], edx",
        ".scan_table:",
        "cmp eax, PMM_MANAGED_START",
        "cmp eax, PMM_MANAGED_END",
        "mov [vmm_last_reclaimed_page_table], eax",
        "call pmm_free_page",
        "dec dword [vmm_active_page_tables]",
        "inc dword [vmm_reclaimed_page_tables]",
    ):
        _require(vmm_unmap, needle, "dynamic VMM unmapper")

    munmap = kernel.split(".munmap:", 1)[1].split(".ioctl:", 1)[0]
    for needle in (
        "process_munmap_pages_released dd 0",
        "process_munmap_non_tail_kept dd 0",
        "inc dword [process_munmap_attempts]",
        "and eax, PAGE_SIZE - 1",
        "call user_range_validate",
        "cmp eax, [esi + PROC_BRK]",
        "call process_clear_user_range",
        "mov [esi + PROC_BRK], eax",
        "add [process_munmap_pages_released], eax",
        "inc dword [process_munmap_non_tail_kept]",
    ):
        _require(kernel if needle.endswith(" dd 0") else munmap, needle, "brk-backed munmap")

    panic_path = kernel.split(".not_expected_user_fault:", 1)[1].split("doom_user_fault:", 1)[0]
    _require(panic_path, "mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION", "kernel panic path")
    _require(panic_path, "call write_smoke_status", "kernel panic path")
    if panic_path.index("mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION") > panic_path.index("call write_smoke_status"):
        raise AssertionError("panic status must be set before the smoke status write")

    for needle in (
        "panic=KEXC",
        "shutdown=HALT",
        "shutdown=REBOOT",
        "shutdown=POWEROFF",
        "tools/check_shutdown_panic_proof.py",
        "status-before-cleanup",
        "status-before-reset",
        "status-before-poweroff",
        "reset-control / PS/2 reset exits QEMU",
        "tools/check_vm_safety_contract.py",
    ):
        _require(gap_doc, needle, "gap ledger")
    _require(tests_readme, "tools/check_vm_safety_contract.py", "tests README")
    _require(tests_readme, "tools/check_shutdown_panic_proof.py", "tests README")


def main() -> int:
    try:
        validate_repo_contract()
    except AssertionError as exc:
        print(f"VM safety contract failed: {exc}", file=sys.stderr)
        return 1

    print("VM safety contract OK: local QEMU opt-in, cloud diagnostics, panic/shutdown status, and dynamic high VMM mapping are machine-checkable")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
