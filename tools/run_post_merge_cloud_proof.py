#!/usr/bin/env python3
"""Dispatch and validate the post-merge cloud proof lane.

The lane pins OS smoke, Real WAD smoke, and UEFI OVMF loader proof to one
expected commit. It only talks to GitHub Actions and downloaded status-only
artifacts; it never runs a local VM.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import shlex
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Mapping, Sequence, TextIO


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REPO = "jadentripp/vibe-os"
REAL_WAD_LANES = ("gameplay", "audio", "persistence", "full")
UEFI_MODES = ("contract", "attempt", "prove")
DEFAULT_SAVE_SLOT = "0"
FULL_SHA_RE = re.compile(r"^[0-9A-Fa-f]{40}$")


class PostMergeCloudProofError(RuntimeError):
    """Raised when the post-merge cloud proof lane cannot proceed safely."""


@dataclass(frozen=True)
class RealWadConfig:
    audible_audio_proof: bool
    persistence_save_slot: str

    @property
    def persistence_enabled(self) -> bool:
        return self.persistence_save_slot != ""


@dataclass(frozen=True)
class WorkflowPlan:
    key: str
    workflow: str
    artifact: str
    output_subdir: str
    fields: tuple[tuple[str, str], ...]
    run_id: str = ""


def real_wad_config(lane: str, save_slot: str) -> RealWadConfig:
    if lane == "gameplay":
        return RealWadConfig(audible_audio_proof=False, persistence_save_slot="")
    if lane == "audio":
        return RealWadConfig(audible_audio_proof=True, persistence_save_slot="")
    if lane == "persistence":
        return RealWadConfig(audible_audio_proof=False, persistence_save_slot=save_slot)
    if lane == "full":
        return RealWadConfig(audible_audio_proof=True, persistence_save_slot=save_slot)
    raise PostMergeCloudProofError(f"unknown Real WAD lane: {lane}")


def validate_save_slot(raw: str) -> str:
    if raw not in {"0", "1", "2", "3", "4", "5"}:
        raise PostMergeCloudProofError(f"--save-slot must be 0..5, got {raw!r}")
    return raw


def validate_exact_commit(raw: str) -> str:
    if not FULL_SHA_RE.fullmatch(raw):
        raise PostMergeCloudProofError(
            "--commit must be the full 40-character pushed Git SHA; "
            f"got {raw!r}"
        )
    return raw.lower()


def bool_field(value: bool) -> str:
    return "true" if value else "false"


def run_command(
    command: Sequence[str],
    *,
    capture_json: bool = False,
    cwd: Path = ROOT,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(command),
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture_json else None,
    )


def command_text(command: Sequence[str]) -> str:
    return shlex.join([str(part) for part in command])


def resolve_commit(ref: str) -> str:
    candidates = [f"{ref}^{{commit}}"]
    if "/" not in ref:
        candidates.append(f"refs/heads/{ref}^{{commit}}")
    for candidate in candidates:
        try:
            result = run_command(["git", "rev-parse", candidate], capture_json=True)
        except subprocess.CalledProcessError:
            continue
        commit = result.stdout.strip()
        if commit:
            return commit
    raise PostMergeCloudProofError(
        f"could not resolve {ref!r}; pass --commit with the exact main SHA"
    )


def refuse_local_vm(env: Mapping[str, str], *, local: bool) -> None:
    if local or env.get("ALLOW_LOCAL_VM") == "1":
        raise PostMergeCloudProofError(
            "post-merge cloud proof refuses local VM execution. Unset "
            "ALLOW_LOCAL_VM and dispatch GitHub Actions instead."
        )


def workflow_run_command(
    *,
    repo: str,
    ref: str,
    workflow: str,
    fields: Sequence[tuple[str, str]],
) -> list[str]:
    command = ["gh", "workflow", "run", workflow, "--repo", repo, "--ref", ref]
    for key, value in fields:
        command.extend(["-f", f"{key}={value}"])
    return command


def run_list_command(repo: str, ref: str, workflow: str) -> list[str]:
    return [
        "gh",
        "run",
        "list",
        "--repo",
        repo,
        "--workflow",
        workflow,
        "--branch",
        ref,
        "--event",
        "workflow_dispatch",
        "--limit",
        "20",
        "--json",
        "databaseId,createdAt,headBranch,headSha,status,conclusion,url,workflowName",
    ]


def run_view_command(repo: str, run_id: str) -> list[str]:
    return [
        "gh",
        "run",
        "view",
        run_id,
        "--repo",
        repo,
        "--json",
        "databaseId,workflowName,headBranch,headSha,status,conclusion,url,event,createdAt,updatedAt",
    ]


def find_dispatched_run(
    *,
    repo: str,
    ref: str,
    workflow: str,
    commit: str,
    created_after: datetime,
    attempts: int = 30,
    delay_seconds: float = 2.0,
) -> dict[str, object]:
    threshold = created_after.timestamp() - 10
    command = run_list_command(repo, ref, workflow)
    for _ in range(attempts):
        result = run_command(command, capture_json=True)
        runs = json.loads(result.stdout or "[]")
        for run in runs:
            if str(run.get("headSha", "")) != commit:
                continue
            created_at = str(run.get("createdAt", ""))
            if not created_at:
                continue
            parsed = datetime.fromisoformat(created_at.replace("Z", "+00:00"))
            if parsed.timestamp() >= threshold:
                return run
        time.sleep(delay_seconds)
    raise PostMergeCloudProofError(
        f"could not resolve {workflow} run for {ref}@{commit} before timeout"
    )


def summarize_run(run: Mapping[str, object]) -> list[str]:
    fields = {
        "run": run.get("databaseId", ""),
        "workflow": run.get("workflowName", ""),
        "branch": run.get("headBranch", ""),
        "sha": run.get("headSha", ""),
        "status": run.get("status", ""),
        "conclusion": run.get("conclusion", ""),
        "url": run.get("url", ""),
    }
    return [f"{name}: {value}" for name, value in fields.items() if value]


def download_command(repo: str, run_id: str, artifact: str, output_dir: Path) -> list[str]:
    return [
        "gh",
        "run",
        "download",
        run_id,
        "--repo",
        repo,
        "--name",
        artifact,
        "--dir",
        str(output_dir),
    ]


def build_plans(
    *,
    ref: str,
    commit: str,
    real_wad_lane: str,
    save_slot: str,
    uefi_mode: str,
    os_run_id: str = "",
    real_wad_run_id: str = "",
    uefi_run_id: str = "",
) -> tuple[WorkflowPlan, WorkflowPlan, WorkflowPlan]:
    real_wad = real_wad_config(real_wad_lane, save_slot)
    common = (("expected_ref", ref), ("expected_sha", commit))
    real_wad_fields = (
        *common,
        ("audible_audio_proof", bool_field(real_wad.audible_audio_proof)),
        ("persistence_proof", bool_field(real_wad.persistence_enabled)),
    )
    if real_wad.persistence_enabled:
        real_wad_fields = (*real_wad_fields, ("persistence_save_slot", save_slot))
    return (
        WorkflowPlan(
            key="os",
            workflow="os-smoke.yml",
            artifact="aurora-os-smoke-proof-status",
            output_subdir="os-smoke",
            fields=common,
            run_id=os_run_id,
        ),
        WorkflowPlan(
            key="real-wad",
            workflow="real-wad-smoke.yml",
            artifact="real-wad-smoke-proof-status",
            output_subdir="real-wad-smoke",
            fields=real_wad_fields,
            run_id=real_wad_run_id,
        ),
        WorkflowPlan(
            key="uefi",
            workflow="uefi-ovmf-proof.yml",
            artifact="uefi-ovmf-proof-manifests",
            output_subdir="uefi-ovmf-proof",
            fields=(("proof_mode", uefi_mode), *common),
            run_id=uefi_run_id,
        ),
    )


def checker_command(
    *,
    download_dir: Path,
    commit: str,
    real_wad_lane: str,
    uefi_mode: str,
) -> list[str]:
    command = [
        sys.executable,
        "tools/check_post_merge_cloud_artifacts.py",
        "--expected-commit",
        commit,
        "--os",
        str(download_dir / "os-smoke"),
        "--real-wad",
        str(download_dir / "real-wad-smoke"),
        "--uefi",
        str(download_dir / "uefi-ovmf-proof"),
        "--require-real-wad-gameplay-proof",
    ]
    if real_wad_lane in {"audio", "full"}:
        command.append("--require-audible-proof")
    if real_wad_lane in {"persistence", "full"}:
        command.append("--require-persistence-proof")
    if uefi_mode == "prove":
        command.append("--require-uefi-kernel-entry")
    return command


def print_header(
    *,
    stdout: TextIO,
    repo: str,
    ref: str,
    commit: str,
    real_wad_lane: str,
    uefi_mode: str,
) -> None:
    print("vibe-os post-merge cloud proof", file=stdout)
    print(f"repo: {repo}", file=stdout)
    print(f"ref: {ref}", file=stdout)
    print(f"commit: {commit}", file=stdout)
    print(f"Real WAD lane: {real_wad_lane}", file=stdout)
    print(f"UEFI proof mode: {uefi_mode}", file=stdout)
    print("local VM: refused; this helper dispatches GitHub Actions only", file=stdout)
    print(
        "artifact policy: status-only downloads; no WADs, disk images, screenshots, raw audio, logs, secrets, one-time codes, or non-JSON UEFI proof payloads",
        file=stdout,
    )
    print(
        "runtime fields: biosboot/biosflags/biosentry/biosspan, execmap, pcmdev, faultsrc/faultmode/faultcontain plus pf/regs/segs/proc, kblock/ksleep, inputstat/inputpolicy/inputdev/inputdevices/inputmods",
        file=stdout,
    )


def main(
    argv: list[str] | None = None,
    *,
    env: Mapping[str, str] | None = None,
    stdout: TextIO = sys.stdout,
    stderr: TextIO = sys.stderr,
    platform_name: str | None = None,
) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Dispatch OS smoke, Real WAD smoke, and UEFI kernel-entry proof for one "
            "exact main commit, then validate status-only artifacts."
        )
    )
    parser.add_argument("--repo", default=DEFAULT_REPO, help="GitHub repo, owner/name")
    parser.add_argument("--ref", default="main", help="branch/ref to dispatch")
    parser.add_argument(
        "--commit",
        default="",
        help=(
            "full 40-character pushed commit SHA to require. Defaults to "
            "git rev-parse <ref>^{commit}; post-push runs should pass the "
            "pushed main SHA explicitly."
        ),
    )
    parser.add_argument(
        "--real-wad-lane",
        choices=REAL_WAD_LANES,
        default="full",
        help=(
            "Real WAD smoke lane to request. Defaults to full so the post-merge "
            "gate requires gameplay, audible audio, and save/load persistence "
            "evidence for the exact commit."
        ),
    )
    parser.add_argument("--save-slot", default=DEFAULT_SAVE_SLOT, help="DOOMSAV slot, 0..5")
    parser.add_argument(
        "--uefi-proof-mode",
        choices=UEFI_MODES,
        default="prove",
        help="UEFI OVMF workflow proof mode",
    )
    parser.add_argument("--os-run-id", default="", help="existing OS smoke run id")
    parser.add_argument("--real-wad-run-id", default="", help="existing Real WAD run id")
    parser.add_argument("--uefi-run-id", default="", help="existing UEFI proof run id")
    parser.add_argument("--wait", action="store_true", help="watch each run to completion")
    parser.add_argument(
        "--download-dir",
        type=Path,
        help="download each status-only artifact into subdirectories here",
    )
    parser.add_argument(
        "--check-only",
        action="store_true",
        help="skip GitHub calls and validate an existing --download-dir",
    )
    parser.add_argument("--dry-run", action="store_true", help="print commands only")
    parser.add_argument("--local", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args(argv)

    effective_env = os.environ if env is None else env
    _ = platform.system() if platform_name is None else platform_name

    try:
        refuse_local_vm(effective_env, local=args.local)
        save_slot = validate_save_slot(args.save_slot)
        commit = validate_exact_commit(args.commit or resolve_commit(args.ref))
        plans = build_plans(
            ref=args.ref,
            commit=commit,
            real_wad_lane=args.real_wad_lane,
            save_slot=save_slot,
            uefi_mode=args.uefi_proof_mode,
            os_run_id=args.os_run_id,
            real_wad_run_id=args.real_wad_run_id,
            uefi_run_id=args.uefi_run_id,
        )
        if args.check_only and args.download_dir is None:
            raise PostMergeCloudProofError("--check-only requires --download-dir")
    except PostMergeCloudProofError as exc:
        print(f"post-merge cloud proof failed: {exc}", file=stderr)
        return 1

    print_header(
        stdout=stdout,
        repo=args.repo,
        ref=args.ref,
        commit=commit,
        real_wad_lane=args.real_wad_lane,
        uefi_mode=args.uefi_proof_mode,
    )

    run_ids = {plan.key: plan.run_id for plan in plans}
    run_conclusion = 0

    if not args.check_only:
        for plan in plans:
            if run_ids[plan.key]:
                print(f"{plan.key} run: {run_ids[plan.key]}", file=stdout)
                metadata = run_view_command(args.repo, run_ids[plan.key])
                print(f"{plan.key} metadata: {command_text(metadata)}", file=stdout)
                continue
            command = workflow_run_command(
                repo=args.repo,
                ref=args.ref,
                workflow=plan.workflow,
                fields=plan.fields,
            )
            print(f"{plan.key} dispatch: {command_text(command)}", file=stdout)
            if args.dry_run:
                run_ids[plan.key] = plan.key.upper().replace("-", "_") + "_RUN_ID"
                print(f"{plan.key} dry-run: workflow was not dispatched", file=stdout)
                continue
            created_after = datetime.now(timezone.utc)
            try:
                run_command(command)
                run = find_dispatched_run(
                    repo=args.repo,
                    ref=args.ref,
                    workflow=plan.workflow,
                    commit=commit,
                    created_after=created_after,
                )
                run_ids[plan.key] = str(run["databaseId"])
                for line in summarize_run(run):
                    print(f"{plan.key} {line}", file=stdout)
            except (PostMergeCloudProofError, subprocess.CalledProcessError) as exc:
                print(f"post-merge cloud proof failed: {exc}", file=stderr)
                return 1

        if args.wait:
            for plan in plans:
                run_id = run_ids[plan.key]
                command = ["gh", "run", "watch", run_id, "--repo", args.repo, "--exit-status"]
                print(f"{plan.key} watch: {command_text(command)}", file=stdout)
                if args.dry_run:
                    continue
                result = subprocess.run(list(command), cwd=ROOT)
                if result.returncode != 0:
                    run_conclusion = result.returncode

    if args.download_dir is not None:
        for plan in plans:
            output_dir = args.download_dir / plan.output_subdir
            if not args.check_only:
                run_id = run_ids[plan.key]
                if not run_id:
                    print(
                        f"post-merge cloud proof failed: missing run id for {plan.key}",
                        file=stderr,
                    )
                    return 1
                command = download_command(args.repo, run_id, plan.artifact, output_dir)
                print(f"{plan.key} download: {command_text(command)}", file=stdout)
                if not args.dry_run:
                    output_dir.mkdir(parents=True, exist_ok=True)
                    try:
                        run_command(command)
                    except subprocess.CalledProcessError as exc:
                        print(f"post-merge cloud proof download failed: {exc}", file=stderr)
                        return exc.returncode

        check = checker_command(
            download_dir=args.download_dir,
            commit=commit,
            real_wad_lane=args.real_wad_lane,
            uefi_mode=args.uefi_proof_mode,
        )
        print(f"check: {command_text(check)}", file=stdout)
        if args.dry_run:
            print("dry-run: artifacts were not downloaded or checked", file=stdout)
        else:
            try:
                run_command(check)
            except subprocess.CalledProcessError as exc:
                print(f"post-merge cloud artifact check failed: {exc}", file=stderr)
                return exc.returncode

    return run_conclusion


if __name__ == "__main__":
    raise SystemExit(main())
