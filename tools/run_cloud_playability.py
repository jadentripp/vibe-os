#!/usr/bin/env python3
"""Dispatch and inspect cloud-only real-WAD playability proofs.

This helper is intentionally Mac-safe: it talks to GitHub Actions through
`gh`, downloads only the allowlisted status artifact, and never launches QEMU
or builds a local disk image.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import shlex
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Mapping, Sequence, TextIO


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = "real-wad-smoke.yml"
ARTIFACT = "real-wad-smoke-status"
DEFAULT_REPO = "jadentripp/vibe-os"
DEFAULT_SAVE_SLOT = "0"
LANES = ("gameplay", "audio", "persistence", "full")


class CloudPlayabilityError(RuntimeError):
    """Raised when the cloud playability helper cannot proceed safely."""


@dataclass(frozen=True)
class LaneConfig:
    audible_audio_proof: bool
    persistence_save_slot: str

    @property
    def persistence_enabled(self) -> bool:
        return self.persistence_save_slot != ""


def lane_config(lane: str, save_slot: str) -> LaneConfig:
    if lane == "gameplay":
        return LaneConfig(audible_audio_proof=False, persistence_save_slot="")
    if lane == "audio":
        return LaneConfig(audible_audio_proof=True, persistence_save_slot="")
    if lane == "persistence":
        return LaneConfig(audible_audio_proof=False, persistence_save_slot=save_slot)
    if lane == "full":
        return LaneConfig(audible_audio_proof=True, persistence_save_slot=save_slot)
    raise CloudPlayabilityError(f"unknown proof lane: {lane}")


def validate_save_slot(raw: str) -> str:
    if raw not in {"0", "1", "2", "3", "4", "5"}:
        raise CloudPlayabilityError(f"--save-slot must be 0..5, got {raw!r}")
    return raw


def validate_wad_url(raw: str) -> str:
    if not raw:
        return raw
    if raw.startswith(("http://", "https://")):
        return raw
    raise CloudPlayabilityError(
        "--wad-url must be an http(s) URL. Do not pass a local DOOM1.WAD path; "
        "the WAD must stay outside git and be fetched inside the GitHub runner."
    )


def refuse_local_vm(
    *,
    env: Mapping[str, str],
    platform_name: str,
    local: bool,
) -> None:
    if local or env.get("ALLOW_LOCAL_VM") == "1":
        raise CloudPlayabilityError(
            "cloud-only helper refuses local VM execution. Unset ALLOW_LOCAL_VM "
            "and dispatch GitHub Actions instead; do not run QEMU on this Mac."
        )
    if platform_name == "Darwin":
        return


def bool_field(value: bool) -> str:
    return "true" if value else "false"


def build_workflow_fields(
    *,
    ref: str,
    wad_url: str,
    config: LaneConfig,
) -> list[tuple[str, str]]:
    fields = [
        ("expected_ref", ref),
        ("audible_audio_proof", bool_field(config.audible_audio_proof)),
        ("persistence_proof", "false"),
    ]
    if wad_url:
        fields.append(("wad_url", wad_url))
    if config.persistence_enabled:
        fields.append(("persistence_save_slot", config.persistence_save_slot))
    return fields


def workflow_run_command(
    *,
    repo: str,
    ref: str,
    fields: Sequence[tuple[str, str]],
) -> list[str]:
    command = [
        "gh",
        "workflow",
        "run",
        WORKFLOW,
        "--repo",
        repo,
        "--ref",
        ref,
    ]
    for key, value in fields:
        command.extend(["-f", f"{key}={value}"])
    return command


def run_command(
    command: Sequence[str],
    *,
    cwd: Path = ROOT,
    capture_json: bool = False,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(command),
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture_json else None,
    )


def latest_run_for_ref(repo: str, ref: str) -> dict[str, object]:
    command = [
        "gh",
        "run",
        "list",
        "--repo",
        repo,
        "--workflow",
        WORKFLOW,
        "--branch",
        ref,
        "--event",
        "workflow_dispatch",
        "--limit",
        "10",
        "--json",
        "databaseId,createdAt,headBranch,headSha,status,conclusion,url",
    ]
    result = run_command(command, capture_json=True)
    runs = json.loads(result.stdout or "[]")
    if not runs:
        raise CloudPlayabilityError(
            f"could not find a recent {WORKFLOW} workflow_dispatch run for ref {ref!r}"
        )
    return runs[0]


def find_dispatched_run(
    *,
    repo: str,
    ref: str,
    created_after: datetime,
    attempts: int = 30,
    delay_seconds: float = 2.0,
) -> dict[str, object]:
    threshold = created_after.timestamp() - 10
    last_error: Exception | None = None
    for _ in range(attempts):
        try:
            run = latest_run_for_ref(repo, ref)
            created_at = str(run.get("createdAt", ""))
            if created_at:
                parsed = datetime.fromisoformat(created_at.replace("Z", "+00:00"))
                if parsed.timestamp() >= threshold:
                    return run
        except Exception as exc:  # pragma: no cover - exercised through CLI use.
            last_error = exc
        time.sleep(delay_seconds)
    if last_error is not None:
        raise CloudPlayabilityError(f"could not resolve dispatched run: {last_error}")
    raise CloudPlayabilityError("could not resolve dispatched run before timeout")


def download_artifact_command(repo: str, run_id: str, output_dir: Path) -> list[str]:
    return [
        "gh",
        "run",
        "download",
        run_id,
        "--repo",
        repo,
        "--name",
        ARTIFACT,
        "--dir",
        str(output_dir),
    ]


def artifact_checker_command(output_dir: Path, config: LaneConfig) -> list[str]:
    command = [
        sys.executable,
        "tools/check_cloud_playability_artifacts.py",
        str(output_dir),
        "--require-gameplay-proof",
    ]
    if config.audible_audio_proof:
        command.append("--require-audible-proof")
    return command


def triage_status(output_dir: Path, stdout: TextIO) -> None:
    status_path = output_dir / "status.txt"
    if not status_path.exists():
        matches = sorted(output_dir.rglob("status.txt"))
        status_path = matches[0] if matches else status_path
    if not status_path.exists():
        print(f"triage: no status.txt found under {output_dir}", file=stdout)
        return
    print(f"triage: {status_path}", file=stdout)
    run_command([sys.executable, "tools/triage_cloud_status.py", str(status_path)])


def render_lane_help(lane: str, config: LaneConfig) -> str:
    if lane == "gameplay":
        return "fast gameplay/input proof; audio WAV capture and persistence are off"
    if lane == "audio":
        return "gameplay plus aggregate audible audio proof; persistence is off"
    if lane == "persistence":
        return (
            "save/load persistence proof with audible audio off, so FAT/save "
            "failures are isolated from audio flakes"
        )
    if lane == "full":
        return "combined audio plus persistence proof; use after isolated lanes are green"
    return f"custom lane audible={config.audible_audio_proof} persistence={config.persistence_enabled}"


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
            "Dispatch or inspect the cloud-only vibe-os real-WAD playability proof. "
            "This never runs local QEMU."
        )
    )
    parser.add_argument(
        "--lane",
        choices=LANES,
        default="gameplay",
        help=(
            "proof lane: gameplay is fastest; audio isolates audible proof; "
            "persistence isolates save/load with audio off; full combines both"
        ),
    )
    parser.add_argument("--repo", default=DEFAULT_REPO, help="GitHub repo, owner/name")
    parser.add_argument("--ref", default="main", help="pushed branch/ref to dispatch")
    parser.add_argument(
        "--wad-url",
        default="",
        help=(
            "optional http(s) URL to DOOM1.WAD, DOOM1.WAD.gz, or a zip containing "
            "DOOM1.WAD. Empty uses the workflow secret/fallback inside the runner."
        ),
    )
    parser.add_argument(
        "--save-slot",
        default=DEFAULT_SAVE_SLOT,
        help="DOOMSAV slot for persistence/full lanes, 0..5",
    )
    parser.add_argument(
        "--run-id",
        default="",
        help="inspect/download an existing run instead of dispatching a new one",
    )
    parser.add_argument(
        "--wait",
        action="store_true",
        help="watch the cloud run and return its conclusion",
    )
    parser.add_argument(
        "--download-artifacts",
        type=Path,
        help="download the real-wad-smoke-status artifact into this directory",
    )
    parser.add_argument(
        "--no-triage",
        action="store_true",
        help="skip triage/status checker commands after artifact download",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print the GitHub Actions commands without running them",
    )
    parser.add_argument(
        "--local",
        action="store_true",
        help=argparse.SUPPRESS,
    )
    args = parser.parse_args(argv)

    effective_env = os.environ if env is None else env
    effective_platform = platform.system() if platform_name is None else platform_name

    try:
        refuse_local_vm(
            env=effective_env,
            platform_name=effective_platform,
            local=args.local,
        )
        save_slot = validate_save_slot(args.save_slot)
        wad_url = validate_wad_url(args.wad_url)
        config = lane_config(args.lane, save_slot)
        if args.download_artifacts and not args.wait and not args.run_id:
            raise CloudPlayabilityError(
                "--download-artifacts with a new dispatch requires --wait so the "
                "status artifact exists, or --run-id to inspect an existing run"
            )
    except CloudPlayabilityError as exc:
        print(f"cloud playability failed: {exc}", file=stderr)
        return 1

    print("vibe-os cloud playability", file=stdout)
    print(f"repo: {args.repo}", file=stdout)
    print(f"ref: {args.ref}", file=stdout)
    print(f"lane: {args.lane} ({render_lane_help(args.lane, config)})", file=stdout)
    print("local VM: refused; this helper dispatches GitHub Actions only", file=stdout)
    print("artifact policy: no WADs, disk images, rendered pixels, or raw audio", file=stdout)

    run_id = args.run_id
    run_conclusion = 0
    if not run_id:
        fields = build_workflow_fields(ref=args.ref, wad_url=wad_url, config=config)
        command = workflow_run_command(repo=args.repo, ref=args.ref, fields=fields)
        print(f"dispatch: {shlex.join(command)}", file=stdout)
        if args.dry_run:
            print("dry-run: workflow was not dispatched", file=stdout)
        else:
            created_after = datetime.now(timezone.utc)
            try:
                run_command(command)
                run = find_dispatched_run(
                    repo=args.repo,
                    ref=args.ref,
                    created_after=created_after,
                )
                run_id = str(run["databaseId"])
                print(f"run: {run_id}", file=stdout)
                if run.get("url"):
                    print(f"url: {run['url']}", file=stdout)
            except (CloudPlayabilityError, subprocess.CalledProcessError) as exc:
                print(f"cloud playability failed: {exc}", file=stderr)
                return 1
    else:
        print(f"run: {run_id}", file=stdout)

    if args.dry_run and not run_id and (args.wait or args.download_artifacts):
        run_id = "RUN_ID"

    if args.wait and run_id:
        command = ["gh", "run", "watch", run_id, "--repo", args.repo, "--exit-status"]
        print(f"watch: {shlex.join(command)}", file=stdout)
        if not args.dry_run:
            try:
                run_command(command)
            except subprocess.CalledProcessError as exc:
                run_conclusion = exc.returncode

    if args.download_artifacts:
        if not run_id:
            print(
                "cloud playability failed: --download-artifacts needs --run-id, "
                "--wait, or a non-dry dispatch that can resolve a run id",
                file=stderr,
            )
            return 1
        output_dir = args.download_artifacts
        command = download_artifact_command(args.repo, run_id, output_dir)
        print(f"download: {shlex.join(command)}", file=stdout)
        checker = artifact_checker_command(output_dir, config)
        print(f"check: {shlex.join(checker)}", file=stdout)
        if not args.no_triage:
            print(
                f"triage command: {shlex.join([sys.executable, 'tools/triage_cloud_status.py', str(output_dir / 'status.txt')])}",
                file=stdout,
            )
        if args.dry_run:
            print("dry-run: artifact was not downloaded", file=stdout)
        else:
            try:
                output_dir.mkdir(parents=True, exist_ok=True)
                run_command(command)
                if not args.no_triage:
                    triage_status(output_dir, stdout)
                run_command(checker)
            except subprocess.CalledProcessError as exc:
                print(f"cloud playability artifact check failed: {exc}", file=stderr)
                return exc.returncode

    return run_conclusion


if __name__ == "__main__":
    raise SystemExit(main())
