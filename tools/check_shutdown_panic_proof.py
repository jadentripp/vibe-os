#!/usr/bin/env python3
"""Validate shutdown, reboot-request, and panic proof status artifacts."""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SCHEMA = "shutdown-panic-proof-v1"
MANIFEST_NAME = "shutdown-panic-proof.json"

FIELD_PATTERN = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
FORBIDDEN_ARTIFACT_PATTERNS = (
    "*.wad",
    "*.WAD",
    "*.iwad",
    "*.IWAD",
    "*.pwad",
    "*.PWAD",
    "*.img",
    "*.iso",
    "*.raw",
    "*.qcow2",
    "gfx.bin",
    "gfx*.txt",
    "vga*.bin",
    "vga*.txt",
    "*.png",
    "*.ppm",
    "*.pgm",
    "*.bmp",
    "*.wav",
    "*.wave",
    "*.mp3",
    "*.ogg",
    "*.oga",
    "*.flac",
    "*.aiff",
    "*.aif",
    "*.au",
)

PHASES = {
    "panic": {
        "status": "status.panic.txt",
        "panic": "KEXC",
        "shutdown": "NONE",
        "triggers": ("kernel-proof-invalid-opcode", "shell-panic"),
        "evidence": ("status-before-cleanup",),
        "requires_fault": True,
    },
    "shutdown-halt": {
        "status": "status.shutdown-halt.txt",
        "panic": "NONE",
        "shutdown": "HALT",
        "triggers": ("kernel-proof-halt", "shell-halt"),
        "evidence": ("status-before-cleanup",),
        "requires_fault": False,
    },
    "shutdown-reboot": {
        "status": "status.shutdown-reboot.txt",
        "panic": "NONE",
        "shutdown": "REBOOT",
        "triggers": ("kernel-proof-reboot-request", "shell-reboot"),
        "evidence": ("status-before-reset", "status-before-cleanup"),
        "requires_fault": False,
    },
}

REQUIRED_POLICY_FLAGS = (
    "contains_wad_data",
    "contains_disk_image",
    "contains_pixel_dump",
    "contains_raw_audio",
)


def _read(root: Path, relative: str) -> str:
    return (root / relative).read_text()


def _require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label} missing {needle!r}")


def _status_fields(status: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in FIELD_PATTERN.finditer(status):
        name = match.group(1)
        if name in fields:
            raise AssertionError(f"duplicate {name}= field")
        fields[name] = match.group(2)
    return fields


def _field(fields: dict[str, str], name: str) -> str:
    value = fields.get(name)
    if value is None:
        raise AssertionError(f"missing {name}= field")
    return value


def _hex_tuple_field(fields: dict[str, str], name: str, count: int) -> tuple[int, ...]:
    value = _field(fields, name)
    parts = value.split("/")
    if len(parts) != count:
        raise AssertionError(f"{name}= must have {count} hex parts separated by '/'")
    parsed = []
    for part in parts:
        if not re.fullmatch(r"[0-9A-Fa-f]{8}", part):
            raise AssertionError(f"{name}= part must be eight hex digits, got {part!r}")
        parsed.append(int(part, 16))
    return tuple(parsed)


def _relative_names(root: Path) -> list[str]:
    return [
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file()
    ]


def _find_one(names: list[str], basename: str) -> str | None:
    matches = [name for name in names if Path(name).name == basename]
    if len(matches) > 1:
        joined = ", ".join(matches)
        raise AssertionError(f"duplicate diagnostic file basename {basename}: {joined}")
    return matches[0] if matches else None


def _assert_artifact_hygiene(artifact_dir: Path, names: list[str]) -> None:
    for name in names:
        basename = Path(name).name
        for pattern in FORBIDDEN_ARTIFACT_PATTERNS:
            if fnmatch.fnmatchcase(basename, pattern):
                raise AssertionError(f"forbidden WAD/disk/pixel/audio artifact present: {name}")
        data = (artifact_dir / name).read_bytes()
        if data.startswith((b"IWAD", b"PWAD")):
            raise AssertionError(f"forbidden WAD payload content in {name}")
        if data.startswith((b"\x89PNG\r\n\x1a\n", b"BM", b"P6", b"P5")):
            raise AssertionError(f"forbidden image payload content in {name}")
        if data.startswith((b"RIFF", b"ID3", b"OggS", b"fLaC", b"FORM")):
            raise AssertionError(f"forbidden audio payload content in {name}")
        if data.startswith(b"QFI\xfb"):
            raise AssertionError(f"forbidden QCOW2 payload content in {name}")
        if (
            len(data) >= 512
            and data[510:512] == b"\x55\xaa"
            and b"FAT" in data[: min(len(data), 4096)]
        ):
            raise AssertionError(f"forbidden raw FAT disk image content in {name}")


def validate_phase_status(status: str, phase: str) -> None:
    if phase not in PHASES:
        raise AssertionError(f"unknown shutdown/panic phase {phase!r}")
    spec = PHASES[phase]
    fields = _status_fields(status)
    panic = _field(fields, "panic")
    shutdown = _field(fields, "shutdown")
    if panic != spec["panic"]:
        raise AssertionError(f"{phase} panic= must be {spec['panic']}, got {panic!r}")
    if shutdown != spec["shutdown"]:
        raise AssertionError(f"{phase} shutdown= must be {spec['shutdown']}, got {shutdown!r}")
    if spec["requires_fault"]:
        fault = _hex_tuple_field(fields, "fault", 11)
        if fault[0] == 0 or fault[2] == 0:
            raise AssertionError("panic proof must include nonzero fault vector and EIP")
        if not any(fault):
            raise AssertionError("panic proof fault= tuple must not be all zero")


def _load_manifest(path: Path) -> dict[str, Any]:
    try:
        manifest = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise AssertionError(f"{path.name} is not valid JSON: {exc}") from exc
    if not isinstance(manifest, dict):
        raise AssertionError(f"{path.name} must be a JSON object")
    return manifest


def validate_manifest(manifest: dict[str, Any], artifact_dir: Path) -> None:
    if manifest.get("schema") != SCHEMA:
        raise AssertionError(f"manifest schema must be {SCHEMA}")
    if manifest.get("source") != "github-actions-disposable-vm":
        raise AssertionError("manifest source must be github-actions-disposable-vm")
    if manifest.get("no_local_qemu") is not True:
        raise AssertionError("manifest no_local_qemu must be true")

    policy = manifest.get("artifact_policy")
    if not isinstance(policy, dict):
        raise AssertionError("manifest artifact_policy must be an object")
    for flag in REQUIRED_POLICY_FLAGS:
        if policy.get(flag) is not False:
            raise AssertionError(f"manifest artifact_policy.{flag} must be false")

    phases = manifest.get("phases")
    if not isinstance(phases, dict):
        raise AssertionError("manifest phases must be an object")

    names = _relative_names(artifact_dir)
    for phase, spec in PHASES.items():
        entry = phases.get(phase)
        if not isinstance(entry, dict):
            raise AssertionError(f"manifest missing {phase} phase")
        status_name = entry.get("status")
        if status_name != spec["status"]:
            raise AssertionError(f"{phase} status must be {spec['status']}")
        trigger = entry.get("trigger")
        if trigger not in spec["triggers"]:
            allowed = ", ".join(spec["triggers"])
            raise AssertionError(f"{phase} trigger must be one of {allowed}")
        evidence = entry.get("evidence")
        if evidence not in spec["evidence"]:
            allowed = ", ".join(spec["evidence"])
            raise AssertionError(f"{phase} evidence must be one of {allowed}")
        if entry.get("monitor_quit_evidence") is not False:
            raise AssertionError(f"{phase} monitor_quit_evidence must be false")
        cleanup = entry.get("cleanup")
        if cleanup not in ("monitor-quit-after-evidence", "guest-reset-or-exit-after-evidence"):
            raise AssertionError(f"{phase} cleanup must describe post-evidence cleanup")
        if "monitor-quit" in str(trigger) or evidence == "monitor-quit":
            raise AssertionError(f"{phase} proof must not use QEMU monitor quit as evidence")

        found = _find_one(names, status_name)
        if found is None:
            raise AssertionError(f"missing expected {phase} status artifact: {status_name}")
        validate_phase_status((artifact_dir / found).read_text(), phase)


def validate_artifact_dir(artifact_dir: Path, manifest_path: Path | None = None) -> None:
    if not artifact_dir.exists():
        raise AssertionError(f"artifact directory does not exist: {artifact_dir}")
    names = _relative_names(artifact_dir)
    _assert_artifact_hygiene(artifact_dir, names)
    if manifest_path is None:
        found = _find_one(names, MANIFEST_NAME)
        if found is None:
            raise AssertionError(f"missing expected shutdown/panic manifest: {MANIFEST_NAME}")
        manifest_path = artifact_dir / found
    validate_manifest(_load_manifest(manifest_path), artifact_dir)


def validate_repo_contract(root: Path = ROOT) -> None:
    makefile = _read(root, "Makefile")
    kernel = _read(root, "kernel/kernel.asm")
    workflow = _read(root, ".github/workflows/os-smoke.yml")
    vm_checker = _read(root, "tools/check_vm_safety_contract.py")
    gap_doc = _read(root, "docs/post-checkpoint-gaps.md")
    tests_readme = _read(root, "tests/README.md")
    readme = _read(root, "README.md")

    for needle in (
        "KERNEL_EXTRA_NASMFLAGS ?=",
        "$(NASM) -f elf32 -D ELF_KERNEL $(KERNEL_EXTRA_NASMFLAGS)",
        "shutdown-panic-proof-check:",
        "tools/check_shutdown_panic_proof.py --repo-contract",
    ):
        _require(makefile, needle, "Makefile")

    for needle in (
        "SHUTDOWN_PANIC_PROOF_PANIC",
        "SHUTDOWN_PANIC_PROOF_HALT",
        "SHUTDOWN_PANIC_PROOF_REBOOT",
        "ud2",
        "mov dword [shutdown_state], SHUTDOWN_HALT",
        "mov dword [shutdown_state], SHUTDOWN_REBOOT",
        ".proof_reboot_status_loop:",
    ):
        _require(kernel, needle, "kernel")

    for needle in (
        "shutdown_panic_proof:",
        "KERNEL_EXTRA_NASMFLAGS=\"-D ${define}\"",
        "run_phase panic SHUTDOWN_PANIC_PROOF_PANIC status.panic.txt",
        "run_phase shutdown-halt SHUTDOWN_PANIC_PROOF_HALT status.shutdown-halt.txt",
        "run_phase shutdown-reboot SHUTDOWN_PANIC_PROOF_REBOOT status.shutdown-reboot.txt",
        "shutdown-panic-proof.json",
        "--manifest build/shutdown-panic-proof/shutdown-panic-proof.json",
        "build/shutdown-panic-proof",
        "status.panic.txt",
        "status.shutdown-halt.txt",
        "status.shutdown-reboot.txt",
    ):
        _require(workflow, needle, "OS smoke workflow")

    upload = workflow.split("uses: actions/upload-artifact@v4", 1)[1]
    for needle in (
        "build/shutdown-panic-proof/**",
        "build/status*.txt",
        "build/proof-*/*.log",
    ):
        _require(upload, needle, "OS smoke workflow upload")
    for forbidden in ("build/disk.img", "DOOM1.WAD", "*.WAD", "*.wad", "build/gfx.bin"):
        if forbidden in upload:
            raise AssertionError(f"OS smoke workflow upload includes forbidden artifact {forbidden}")

    _require(vm_checker, "tools/check_shutdown_panic_proof.py", "VM safety checker")
    _require(gap_doc, "tools/check_shutdown_panic_proof.py", "gap ledger")
    _require(gap_doc, "status-before-cleanup", "gap ledger")
    _require(gap_doc, "guest reset/poweroff is still open", "gap ledger")
    _require(readme, "shutdown_panic_proof", "README")
    _require(tests_readme, "check_shutdown_panic_proof.py", "tests README")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "artifact_dir",
        nargs="?",
        type=Path,
        help="downloaded shutdown/panic proof artifact directory",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        help=f"explicit {MANIFEST_NAME} path",
    )
    parser.add_argument(
        "--repo-contract",
        action="store_true",
        help="validate docs/workflow/Makefile proof-mode wiring",
    )
    args = parser.parse_args(argv)

    try:
        if args.repo_contract or args.artifact_dir is None:
            validate_repo_contract()
        if args.artifact_dir is not None:
            validate_artifact_dir(args.artifact_dir, args.manifest)
    except (OSError, AssertionError) as exc:
        print(f"shutdown/panic proof check failed: {exc}", file=sys.stderr)
        return 1

    print("shutdown/panic proof check OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
