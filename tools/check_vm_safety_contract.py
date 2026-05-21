#!/usr/bin/env python3
"""Validate VM opt-in, cloud diagnostics, and panic/shutdown evidence contracts."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CLOUD_RUNBOOKS = (
    "docs/runbooks/play-now-cloud.md",
    "docs/runbooks/remote-doom-playtest.md",
)
CLOUD_POLICY_MARKERS = (
    "CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC",
    "CLOUD_PLAYTEST_REMOTE_QEMU_ONLY",
    "CLOUD_PLAYTEST_FORBIDDEN_UPLOADS",
    "CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST",
)
CLOUD_FORBIDDEN_PAYLOAD_PATTERN = re.compile(
    r"("
    r"DOOM1\.WAD|"
    r"\*\.WAD|\*\.wad|"
    r"\b[\w.-]+\.wad\b|\b[\w.-]+\.WAD\b|"
    r"build/disk\.img|disk\.img|"
    r"\b[\w.-]+\.(?:img|iso|raw|qcow2)\b|"
    r"status\.\*\.bin|status\.[\w.-]+\.bin|"
    r"gfx\.bin|gfx\*\.txt|vga\*\.txt|"
    r"\b[\w.-]+\.(?:png|ppm|pgm|bmp)\b|"
    r"doom-audio\.wav|"
    r"\b[\w.-]+\.(?:wav|wave|mp3|ogg|oga|flac|aiff|aif|au)\b"
    r")",
    re.IGNORECASE,
)
CLOUD_FORBIDDEN_TRANSFER_PATTERN = re.compile(
    r"\b("
    r"scp|rsync|"
    r"curl\s+(?:--upload-file|-T)|"
    r"aws\s+s3\s+cp|gsutil\s+cp|rclone\s+copy|"
    r"gh\s+(?:release|run)\s+upload|"
    r"tar\s+.*(?:-c|--create)|"
    r"zip"
    r")\b",
    re.IGNORECASE,
)
CLOUD_LOCAL_QEMU_COMMAND_PATTERNS = (
    (re.compile(r"\bbrew\s+install\s+qemu\b", re.IGNORECASE), "brew install qemu"),
    (
        re.compile(
            r"\bmake\b[^\n#]*\bALLOW_LOCAL_VM=1\b[^\n#]*(?:\brun\b|\brun-headless\b|\bsmoke\b)",
            re.IGNORECASE,
        ),
        "make ALLOW_LOCAL_VM=1 VM target",
    ),
    (
        re.compile(
            r"\bALLOW_LOCAL_VM=1\b[^\n#]*\bmake\b[^\n#]*(?:\brun\b|\brun-headless\b|\bsmoke\b)",
            re.IGNORECASE,
        ),
        "ALLOW_LOCAL_VM=1 make VM target",
    ),
    (re.compile(r"\btests/run_smoke_qemu\.sh\b"), "tests/run_smoke_qemu.sh"),
    (re.compile(r"\bQEMU\s*=\s*qemu-system", re.IGNORECASE), "QEMU=qemu-system"),
)
CLOUD_QEMU_COMMAND_PATTERN = re.compile(r"^\s*qemu-system-[A-Za-z0-9_+.-]+\b", re.MULTILINE)


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


def _fenced_blocks(text: str) -> list[str]:
    return [
        match.group("body")
        for match in re.finditer(
            r"```(?P<lang>[^\n]*)\n(?P<body>.*?)```",
            text,
            re.DOTALL,
        )
    ]


def _non_comment_lines(block: str) -> list[str]:
    return [
        line
        for line in block.splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]


def validate_cloud_runbook_text(text: str, label: str) -> None:
    for marker in CLOUD_POLICY_MARKERS:
        _require(text, marker, label)

    for block in _fenced_blocks(text):
        if (
            CLOUD_QEMU_COMMAND_PATTERN.search(block)
            and "CLOUD_PLAYTEST_REMOTE_QEMU_ONLY" not in block
        ):
            raise AssertionError(f"{label} QEMU command block missing remote-only sentinel")

        for line in _non_comment_lines(block):
            for pattern, description in CLOUD_LOCAL_QEMU_COMMAND_PATTERNS:
                if pattern.search(line):
                    raise AssertionError(f"{label} instructs local Mac QEMU path: {description}")

            if (
                CLOUD_FORBIDDEN_TRANSFER_PATTERN.search(line)
                and CLOUD_FORBIDDEN_PAYLOAD_PATTERN.search(line)
            ):
                raise AssertionError(
                    f"{label} transfers forbidden WAD/disk/pixel/raw-audio payload: {line.strip()}"
                )


def validate_cloud_interactive_runbooks(root: Path = ROOT) -> None:
    runbooks = {relative: _read(root, relative) for relative in CLOUD_RUNBOOKS}
    cloud = runbooks["docs/runbooks/play-now-cloud.md"]
    remote = runbooks["docs/runbooks/remote-doom-playtest.md"]
    play_now_script = _read(root, "tools/play_now_remote.sh")
    codespaces_script = _read(root, "tools/play_now_codespaces.sh")
    human_playtest_script = _read(root, "tools/run_remote_human_playtest.sh")

    for text, label in (
        (cloud, "cloud interactive playtest runbook"),
        (remote, "remote Doom playtest runbook"),
    ):
        validate_cloud_runbook_text(text, label)

    for needle in (
        "No local VM/QEMU on the Mac",
        "disposable remote Ubuntu",
        "GitHub Codespace",
        "tools/prepare_shareware_wad.py",
        "--output /tmp/DOOM1.WAD",
        "make DOOM_WAD=/tmp/DOOM1.WAD",
        "ssh -N -L 5901:127.0.0.1:5901",
        "http://127.0.0.1:6080/vnc.html?autoconnect=1",
        "tools/collect_human_playtest_bundle.py",
        "tools/play_now_codespaces.sh",
        "tools/check_cloud_playability_artifacts.py --human-session",
        "CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST",
        "Never transfer these from the remote host",
        "rm -f /tmp/vibe-os-DOOM1.WAD",
        "rm -f ~/vibe-os-cloud-playtest/build/doom-audio.wav",
        "destroy the disposable",
    ):
        _require(cloud, needle, "cloud interactive playtest runbook")

    for needle in (
        "Refusing to run QEMU on macOS",
        'ALLOW_LOCAL_VM:-0',
        "qemu-system-x86_64",
        'NOVNC_WEB_ROOTS=(',
        'resolve_novnc_web_root',
        'websockify --web="$NOVNC_WEB_ROOT_RESOLVED"',
        'VNC_DISPLAY="${VNC_DISPLAY:-1}"',
        'NOVNC_PORT="${NOVNC_PORT:-6080}"',
        '-display "vnc=127.0.0.1:$VNC_DISPLAY"',
        '127.0.0.1:$((5900 + VNC_DISPLAY))',
        '/vnc.html?autoconnect=1',
    ):
        _require(play_now_script, needle, "play-now remote script")

    for needle in (
        "Usage: tools/play_now_codespaces.sh [options]",
        "codespace create",
        "gh \"${create_args[@]}\"",
        "--preflight, --dry-run",
        "--web-url",
        "require_clean_pushed_git_state",
        "local git working tree is dirty",
        "differs from upstream",
        "print_web_fallback_hint",
        "local gh Codespaces API: not required for this browser path",
        "play-now Codespaces preflight OK",
        "local artifact transfer: none",
        "dry-run: Codespace was not created or modified",
        "novnc_url_from_browse_url",
        "remote_start_payload | gh codespace ssh -c \"$CODESPACE_NAME\" -- env VIBE_PLAY_REF=\"$REF\" NOVNC_PORT=\"$NOVNC_PORT\" bash -s",
        "./tools/play_now_remote.sh --preflight",
        "NOVNC_PORT=$NOVNC_PORT nohup ./tools/play_now_remote.sh",
        "gh codespace ports visibility \"$NOVNC_PORT:private\"",
        "noVNC port $NOVNC_PORT is private",
        "vnc.html?autoconnect=1",
        "Makefile",
        "tools/prepare_shareware_wad.py",
        "tools/make_wad_image.py",
    ):
        _require(codespaces_script, needle, "Codespaces play-now launcher")

    for forbidden in (
        "qemu-system-x86_64",
        "make DOOM_WAD",
        "python3 tools/prepare_shareware_wad.py",
        "gh codespace cp",
        "scp ",
        "build/disk.img",
        "DOOM1.WAD",
        "doom-audio.wav",
    ):
        if forbidden in codespaces_script:
            raise AssertionError(
                f"Codespaces launcher should not run/copy forbidden payload {forbidden!r}"
            )

    for needle in (
        "Refusing to run the remote human playtest helper on macOS",
        "tools/collect_human_playtest_bundle.py",
        "--capture-phase \"$phase\"",
        "--confirm-no-forbidden-artifacts",
        "python3 tools/check_cloud_playability_artifacts.py --human-session ./vibe-os-human-proof",
    ):
        _require(human_playtest_script, needle, "remote human playtest helper")

    for forbidden in (
        "qemu-system",
        "DOOM1.WAD",
        "disk.img",
        "gfx.bin",
        "doom-audio.wav",
    ):
        if forbidden in human_playtest_script:
            raise AssertionError(
                f"remote human playtest helper should not launch/transfer forbidden payload {forbidden!r}"
            )

    for needle in (
        "docs/runbooks/play-now-cloud.md",
        "CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC",
        "CLOUD_PLAYTEST_REMOTE_QEMU_ONLY",
        "CLOUD_PLAYTEST_FORBIDDEN_UPLOADS",
        "CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST",
    ):
        _require(remote, needle, "remote Doom playtest runbook")


def validate_repo_contract(root: Path = ROOT) -> None:
    makefile = _read(root, "Makefile")
    smoke_runner = _read(root, "tests/run_smoke_qemu.sh")
    os_workflow = _read(root, ".github/workflows/os-smoke.yml")
    real_wad_workflow = _read(root, ".github/workflows/real-wad-smoke.yml")
    real_wad_soak_workflow = _read(root, ".github/workflows/real-wad-soak.yml")
    cloud_play_workflow = _read(root, ".github/workflows/cloud-play-now-preflight.yml")
    stage2 = _read(root, "boot/stage2.asm")
    kernel = _read(root, "kernel/kernel.asm")
    probe = _read(root, "user/probe.c")
    process_doc = _read(root, "docs/process-exec.md")
    process_vm_doc = _read(root, "docs/process-vm.md")
    boot_vm_doc = _read(root, "docs/boot-loader-vm.md")
    doom_runtime_doc = _read(root, "docs/doom-libc-runtime.md")
    gap_doc = _read(root, "docs/post-checkpoint-gaps.md")
    tests_readme = _read(root, "tests/README.md")

    validate_cloud_interactive_runbooks(root)

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
    _require(makefile, 'grep -q "vmmhi=OK"', "Makefile")
    _require(makefile, 'grep -q "vmmhva=C0000000"', "Makefile")
    _require(makefile, 'grep -q "vmmhpa="', "Makefile")
    _require(makefile, 'grep -q "vmmhpt="', "Makefile")
    _require(makefile, 'grep -q "vmmhfree="', "Makefile")
    _require(makefile, 'grep -Eq "panic=(NONE|KEXC)"', "Makefile")
    _require(makefile, 'grep -Eq "shutdown=(NONE|HALT|REBOOT|POWEROFF)"', "Makefile")
    _require(makefile, "tools/link_elf32.py -o $@ --base 0x10000", "kernel low-link contract")
    _require(stage2, "KERNEL_PHYS equ 0x00010000", "Stage 2 low-load contract")
    _require(stage2, "jmp eax", "Stage 2 low-entry contract")

    for needle in (
        "trap cleanup EXIT INT TERM",
        "capture_snapshot failure",
        "pmemsave 0x9d000 8192",
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
        "if [ \"$mode\" = \"status-before-reset\" ]; then\n              expect_guest_exit=1\n              no_shutdown=0",
        "--manifest build/shutdown-panic-proof/shutdown-panic-proof.json",
        "build/shutdown-panic-proof/**",
        "build/proof-*/*.log",
    ):
        _require(os_workflow, needle, "OS smoke workflow")

    for workflow, label in (
        (os_workflow, "OS smoke workflow"),
        (real_wad_workflow, "real-WAD workflow"),
        (real_wad_soak_workflow, "real-WAD soak workflow"),
        (cloud_play_workflow, "cloud play-now preflight workflow"),
    ):
        _require(workflow, "FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true", label)
        _require(workflow, "uses: actions/checkout@v6", label)
        if "uses: actions/checkout@v4" in workflow:
            raise AssertionError(f"{label} must not use deprecated checkout@v4")

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
        for forbidden in (
            "build/disk.img",
            "build/gfx.bin",
            "build/vga.txt",
            "build/vga*.txt",
            "build/doom-audio.wav",
            "*.wav",
            "*.png",
            "DOOM1.WAD",
            "*.WAD",
            "*.wad",
        ):
            if forbidden in upload:
                raise AssertionError(f"{label} upload block includes forbidden artifact {forbidden}")

    for needle in (
        "workflow_dispatch:",
        "runs-on: ubuntu-latest",
        "NOVNC_PORT: ${{ inputs.novnc_port }}",
        "qemu-system-x86",
        "./tools/play_now_remote.sh \"${args[@]}\"",
        "--preflight",
        "--require-novnc",
        "dry-run: QEMU was not launched",
        "python3 tools/check_vm_safety_contract.py",
        "This workflow did not launch QEMU, fetch a WAD, build disk.img, or upload logs/artifacts.",
        "VIBE_REPO=${{ github.repository }} VIBE_REF=${{ github.ref_name }} ./tools/play_now_codespaces.sh",
        "VIBE_REPO=${{ github.repository }} VIBE_REF=${{ github.ref_name }} ./tools/play_now_codespaces.sh --web-url",
        "tools/play_now_cloud_shell.sh",
    ):
        _require(cloud_play_workflow, needle, "cloud play-now preflight workflow")

    for forbidden in (
        "actions/upload-artifact",
        "DOOM1.WAD",
        "make DOOM_WAD",
        "qemu-system-x86_64 \\",
        "build/disk.img",
        "gh codespace cp",
        "scp ",
    ):
        if forbidden in cloud_play_workflow:
            raise AssertionError(
                f"cloud play-now preflight workflow includes forbidden payload/action {forbidden!r}"
            )

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
        "CMOS_RTC_SECONDS_REGISTER equ 0x00",
        "SHUTDOWN_PROOF_DELAY_SECONDS equ 20",
        "read_cmos_seconds:",
        "shutdown_proof_wait_before_guest_exit:",
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
        "vmm_high_test_phys dd 0",
        "vmm_high_test_table dd 0",
        "vmm_high_test_reclaimed dd 0",
        "vmm_high_mapping_status db 0",
        'smoke_vmmhi_text db " vmmhi=", 0',
        'smoke_vmmhva_text db " vmmhva=", 0',
        'smoke_vmmhpa_text db " vmmhpa=", 0',
        'smoke_vmmhpt_text db " vmmhpt=", 0',
        'smoke_vmmhfree_text db " vmmhfree=", 0',
        "USER_PROBE_EXPECTED_FLAGS equ 0x0007ffff",
        "SYS_EXEC_ARGV_SOURCE_DEFAULT equ 1",
        "SYS_EXEC_ARGV_SOURCE_USER equ 2",
        "PROCESS_RECORD_BYTES equ 168",
        "PROC_HEAP_BITMAP equ 160",
        "PROC_HEAP_PAGE_COUNT equ 164",
        "process_heap_mark_range:",
        "process_heap_clear_range:",
        "process_heap_range_is_mapped:",
        "process_wait_vm_reaps dd 0",
        "process_wait_vm_pages_reclaimed dd 0",
        "process_wait_last_vm_pages_reclaimed dd 0",
        'smoke_vmreap_text db " vmreap=", 0',
        "process_sbrk_shrink_calls dd 0",
        "process_sbrk_pages_released dd 0",
        "PROCESS_SLOT_COUNT equ 6",
        "PROCESS_GENERIC_SLOT_COUNT equ 2",
        "USER_KIND_GENERIC equ 4",
        "PROC_GENERIC0_PAGE_DIR_ADDR equ 0x00089000",
        "PROC_GENERIC1_PAGE_DIR_ADDR equ 0x0008b000",
        "process_generic0:",
        "process_generic1:",
        "process_generic_exec_slots:",
        "process_alloc_generic_exec_slot:",
        "process_generic_slot_allocations dd 0",
        "process_generic_slot_failures dd 0",
        "sys_exec_last_argv_source dd 0",
        'smoke_exec_argvsrc_text db " argvsrc=", 0',
        "mov edx, [sys_exec_last_argv_source]",
        "vmm_clear_process_guard_page:",
        "call vmm_clear_process_guard_page",
        "vmm_unmap_page:",
        "mov dword [VMM_HIGH_TEST_VADDR], VMM_HIGH_TEST_MAGIC",
        "mov [vmm_high_test_phys], ebx",
        "mov [vmm_high_test_table], eax",
        "mov [vmm_high_test_reclaimed], eax",
        "cmp eax, [vmm_high_test_table]",
        "mov byte [vmm_high_mapping_status], 1",
    ):
        _require(kernel, needle, "kernel VM contract")

    for needle in (
        "%else\nKERNEL_BASE equ 0x10000\norg KERNEL_BASE\n%endif",
        "PAGING_DIR_ADDR equ 0x00090000",
        "PAGING_TABLES_ADDR equ 0x00091000",
        "PAGING_TABLES_ADDR | PTE_KERNEL_FLAGS",
        "mov eax, PAGING_DIR_ADDR",
        "mov cr3, eax",
    ):
        _require(kernel, needle, "running-kernel identity contract")

    for text, label in (
        (boot_vm_doc, "boot loader VM docs"),
        (process_vm_doc, "process VM docs"),
    ):
        for needle in (
            "KERNEL_RELOCATION_GAP[current]=high-alias-only",
            "KERNEL_RELOCATION_GAP[missing]=running-kernel-non-identity",
            "`vmmhi=OK` is not a kernel relocation claim",
            "`kreloc=OK`",
            "`kerneip=`",
            "`kernesp=`",
            "`kerncr3=`",
            "`kernvirt=`",
            "`kernphys=`",
        ):
            _require(text, needle, label)

    for text, label in (
        (kernel, "kernel"),
        (makefile, "Makefile"),
        (os_workflow, "OS smoke workflow"),
        (real_wad_workflow, "real-WAD workflow"),
    ):
        for forbidden in (
            "smoke_kreloc_text",
            'grep -q "kreloc=OK"',
            " kreloc=OK",
            "kerneip=",
            "kernesp=",
            "kerncr3=",
            "kernvirt=",
            "kernphys=",
        ):
            if forbidden in text:
                raise AssertionError(
                    f"{label} must not claim running-kernel relocation with {forbidden!r}"
                )

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
    sbrk = kernel.split(".sbrk:", 1)[1].split(".open:", 1)[0]
    for needle in (
        "test ebx, 0x80000000",
        "jnz .sbrk_shrink",
        ".sbrk_shrink:",
        "cmp edx, [esi + PROC_HEAP_START]",
        "call process_clear_user_range",
        "add [process_sbrk_pages_released], eax",
        "inc dword [process_sbrk_shrink_calls]",
        "mov eax, [sbrk_old_brk]",
    ):
        _require(sbrk, needle, "brk shrink")
    for needle in (
        "VM_OBJECT_KIND_NONE equ 0",
        "VM_OBJECT_KIND_ANON_BRK equ 1",
        "process_mmap_last_object_kind dd 0",
        "process_mmap_last_base dd 0",
        "process_mmap_last_end dd 0",
        "process_mmap_last_prot dd 0",
        "process_mmap_last_flags dd 0",
        "mov dword [process_mmap_last_object_kind], VM_OBJECT_KIND_NONE",
        "process_munmap_pages_released dd 0",
        "process_munmap_non_tail_kept dd 0",
        "process_munmap_holes_punched dd 0",
        "process_munmap_pages_unmapped dd 0",
    ):
        _require(kernel, needle, "brk-backed mmap/munmap metadata")

    mmap = kernel.split(".mmap:", 1)[1].split(".munmap:", 1)[0]
    for needle in (
        "mov dword [process_mmap_last_object_kind], VM_OBJECT_KIND_ANON_BRK",
        "mov [process_mmap_last_base], eax",
        "mov [process_mmap_last_end], eax",
        "mov [process_mmap_last_prot], eax",
        "mov [process_mmap_last_flags], eax",
    ):
        _require(mmap, needle, "brk-backed mmap object metadata")
    for needle in (
        "inc dword [process_munmap_attempts]",
        "and eax, PAGE_SIZE - 1",
        "call user_range_validate",
        "cmp eax, [esi + PROC_BRK]",
        "call process_clear_user_range",
        "mov [esi + PROC_BRK], eax",
        "add [process_munmap_pages_released], eax",
        "inc dword [process_munmap_non_tail_kept]",
        "inc dword [process_munmap_holes_punched]",
        "add [process_munmap_pages_unmapped], eax",
    ):
        _require(munmap, needle, "brk-backed munmap")

    for needle in (
        "PROBE_FLAG_NEGATIVE_SYSCALLS = 0x1000u",
        "PROBE_FLAG_SBRK_SHRINK = 0x8000u",
        "PROBE_FLAG_DUP = 0x20000u",
        "ERRNO_EINVAL = 22",
        "syscall3(0x7fffffffu, 0, 0, 0) == -ERRNO_ENOSYS",
        "syscall3(SYS_MMAP, 0, 0, mmap_flags) == -ERRNO_EINVAL",
        "syscall3(SYS_MUNMAP, 0, 4096, 0) == -ERRNO_EINVAL",
        "syscall3(SYS_WAITPID, (uint32_t)-1, USER_FAULT_ADDR, 0) == -ERRNO_EINVAL",
        "unsigned char *hole = sys_mmap(8192",
        "sys_sbrk(-4096) == trim + 4096",
        "sys_write(1, trim + 4096, 1) == -ERRNO_EINVAL",
        "sys_munmap(hole, 4096) == 0",
        "sys_write(1, hole, 1) == -ERRNO_EINVAL",
        "sys_dup(defaults)",
        "sys_dup2(dup_fd, DUP2_TARGET_FD) == DUP2_TARGET_FD",
        "sys_dup3(defaults, DUP3_TARGET_FD, O_CLOEXEC) == DUP3_TARGET_FD",
        "sys_fcntl(defaults, F_SETFD, FD_CLOEXEC) == 0",
        "mmap_hole_ok && sys_munmap(video, DOOM_FRAME_BYTES + DOOM_PALETTE_BYTES) == 0",
        "char *abi_probe_argv[] = {(char *)abi_probe_path, (char *)0};",
        "return sys_execv(abi_probe_path, abi_probe_argv) == 0 ? 0 : 1;",
    ):
        _require(probe, needle, "user probe VM/POSIX contract")

    abi_probe = _read(root, "user/abi_probe.c")
    for needle in (
        "char* doom_argv[] = { (char*)doom_path, 0 };",
        "vibe_user_fcntl(wad, ABI_PROBE_F_SETFD, ABI_PROBE_FD_CLOEXEC)",
        "return vibe_user_execv(doom_path, doom_argv) == 0 ? 0 : 25;",
    ):
        _require(abi_probe, needle, "ABI probe VM/POSIX contract")
    user_runtime = _read(root, "user/runtime.c")
    for needle in (
        "int vibe_user_syscall3(",
        "int $0x80",
        "VIBE_SYS_EXEC",
    ):
        _require(user_runtime, needle, "user runtime syscall contract")

    validator = kernel.split("user_range_validate:", 1)[1].split("doom_log_char:", 1)[0]
    _require(validator, "call process_heap_range_is_mapped", "heap mapping validator")
    wait_reap = kernel.split("process_waitpid_current:", 1)[1].split("scheduler_prepare_live_preempt_probe:", 1)[0]
    for needle in (
        "call process_teardown_user_vm",
        "add [process_wait_vm_pages_reclaimed], eax",
        "inc dword [process_wait_vm_reaps]",
    ):
        _require(wait_reap, needle, "waitpid VM reap")
    scheduler_prepare = kernel.split("scheduler_prepare_live_preempt_probe:", 1)[1].split("scheduler_capture_preempt_spin:", 1)[0]
    _require(scheduler_prepare, "call process_restore_user_image_vm", "preempt probe restore")
    scheduler_tick = kernel.split("scheduler_tick:", 1)[1].split("process_save_irq_context:", 1)[0]
    scheduler_select = kernel.split("scheduler_select_next_ready:", 1)[1].split("scheduler_preempt_self_test:", 1)[0]
    for needle in (
        "call process_save_irq_context",
        "call scheduler_select_next_ready",
        "mov [scheduler_last_preempt_from_pid], eax",
        "mov [scheduler_last_preempt_to_pid], eax",
        "mov [scheduler_last_preempt_from_cr3], eax",
        "mov [scheduler_last_preempt_to_cr3], eax",
        "mov [scheduler_last_preempt_from_kstack], eax",
        "mov [scheduler_last_preempt_to_kstack], eax",
        "call process_activate",
        "call process_restore_irq_context",
        "inc dword [scheduler_irq_frame_rewrites]",
    ):
        _require(scheduler_tick, needle, "timer preemption save/restore contract")
    if not (
        scheduler_tick.index("call process_save_irq_context")
        < scheduler_tick.index("call scheduler_select_next_ready")
        < scheduler_tick.index("call process_activate")
        < scheduler_tick.index("call process_restore_irq_context")
        < scheduler_tick.index("inc dword [scheduler_irq_frame_rewrites]")
    ):
        raise AssertionError("timer preemption save/restore contract has unsafe ordering")
    for needle in (
        "cmp dword [edi + PROC_STATE], PROC_STATE_READY",
        "test dword [edi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID",
        "test dword [edi + PROC_SAVED_CS], 3",
        "cmp dword [edi + PROC_SAVED_EIP], 0",
        "mov [scheduler_next_process_ptr], edi",
        "mov [scheduler_next_pid], edx",
    ):
        _require(scheduler_select, needle, "round-robin user-frame selection contract")

    copy_argv = kernel.split("sys_exec_copy_argv:", 1)[1].split("sys_exec_copy_user_arg_string:", 1)[0]
    _require(copy_argv, "mov dword [sys_exec_last_argv_source], SYS_EXEC_ARGV_SOURCE_USER", "exec argv source proof")
    generic = kernel.split("process_exec_resolve_generic_root83:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
    _require(generic, "call process_alloc_generic_exec_slot", "generic exec pool")
    _require(generic, "mov [process_exec_target], esi", "generic exec pool")
    allocator = kernel.split("process_alloc_generic_exec_slot:", 1)[1].split("process_retire_exec_slot:", 1)[0]
    for needle in (
        "mov edi, process_generic_exec_slots",
        "cmp dword [esi + PROC_STATE], PROC_STATE_UNUSED",
        "cmp dword [esi + PROC_PARENT_PID], 0xffffffff",
        "cmp dword [esi + PROC_STATE], PROC_STATE_EXITED",
        "cmp dword [esi + PROC_STATE], PROC_STATE_FAULTED",
        "mov dword [process_exec_last_error], -ERRNO_ENOMEM",
    ):
        _require(allocator, needle, "generic exec pool")
    _require(process_doc, "`argvsrc=2`", "process exec docs")
    _require(process_doc, "two-entry generic probe-class pool", "process exec docs")
    _require(process_doc, "negative syscall probe bit", "process exec docs")
    for needle in (
        "records a single last-mapping object descriptor tagged",
        "`VM_OBJECT_KIND_ANON_BRK`",
        "not a reusable object table or lookup structure yet",
        "this remains a brk-backed",
        "`vmreap=`",
    ):
        _require(process_vm_doc, needle, "process VM docs")
    for needle in (
        "`VM_OBJECT_KIND_ANON_BRK` last-object descriptor",
        "host contracts can distinguish",
    ):
        _require(doom_runtime_doc, needle, "Doom libc runtime docs")

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
        "vmmhi=OK",
        "vmmhfree=",
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

    print("VM safety contract OK: local QEMU opt-in, cloud diagnostics, safe cloud interactive playtest docs, panic/shutdown status, dynamic high VMM mapping, and the higher-half relocation gap are machine-checkable")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
