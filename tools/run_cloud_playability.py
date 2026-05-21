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
SMOKE_WORKFLOW = "real-wad-smoke.yml"
SMOKE_ARTIFACT = "real-wad-smoke-status"
SOAK_WORKFLOW = "real-wad-soak.yml"
SOAK_ARTIFACT = "real-wad-soak-metadata"
DEFAULT_REPO = "jadentripp/vibe-os"
DEFAULT_SAVE_SLOT = "0"
LANES = ("auto", "gameplay", "audio", "persistence", "full")
MAX_SOAK_ATTEMPTS = 20
CLOUD_AUDIT_SCHEMA = "cloud-playability-audit-v1"
STATUS_TRIAGE_BASENAMES = ("status.txt", "status.failure.txt")


class CloudPlayabilityError(RuntimeError):
    """Raised when the cloud playability helper cannot proceed safely."""


@dataclass(frozen=True)
class LaneConfig:
    audible_audio_proof: bool
    persistence_save_slot: str

    @property
    def persistence_enabled(self) -> bool:
        return self.persistence_save_slot != ""


@dataclass(frozen=True)
class SoakConfig:
    attempts: int
    min_passes: int


def lane_config(lane: str, save_slot: str) -> LaneConfig:
    if lane == "auto":
        raise CloudPlayabilityError(
            "--lane auto is only valid while inspecting downloaded artifacts; "
            "choose gameplay, audio, persistence, or full for a new dispatch"
        )
    if lane == "gameplay":
        return LaneConfig(audible_audio_proof=False, persistence_save_slot="")
    if lane == "audio":
        return LaneConfig(audible_audio_proof=True, persistence_save_slot="")
    if lane == "persistence":
        return LaneConfig(audible_audio_proof=False, persistence_save_slot=save_slot)
    if lane == "full":
        return LaneConfig(audible_audio_proof=True, persistence_save_slot=save_slot)
    raise CloudPlayabilityError(f"unknown proof lane: {lane}")


def validate_positive_integer(
    option: str,
    raw: str,
    *,
    maximum: int | None = None,
) -> int:
    if not raw.isdigit():
        raise CloudPlayabilityError(f"{option} must be a positive integer, got {raw!r}")
    value = int(raw, 10)
    if value < 1:
        raise CloudPlayabilityError(f"{option} must be a positive integer, got {raw!r}")
    if maximum is not None and value > maximum:
        raise CloudPlayabilityError(f"{option} is capped at {maximum}, got {value}")
    return value


def validate_soak_config(
    *,
    lane: str,
    requested: bool,
    attempts_raw: str,
    min_passes_raw: str,
    run_id: str,
) -> SoakConfig | None:
    if not requested and not attempts_raw and not min_passes_raw:
        return None
    if lane in {"persistence", "full"}:
        raise CloudPlayabilityError(
            "real-wad-soak.yml repeats the gameplay/audio proof only; use "
            "--lane gameplay or --lane audio with --soak-attempts, and run "
            "the persistence lane separately"
        )
    if not attempts_raw:
        if min_passes_raw:
            raise CloudPlayabilityError("--soak-min-passes requires --soak-attempts")
        if run_id:
            return SoakConfig(attempts=0, min_passes=0)
        raise CloudPlayabilityError("--soak dispatch requires --soak-attempts")

    attempts = validate_positive_integer(
        "--soak-attempts", attempts_raw, maximum=MAX_SOAK_ATTEMPTS
    )
    min_passes = (
        attempts
        if not min_passes_raw
        else validate_positive_integer("--soak-min-passes", min_passes_raw)
    )
    if min_passes > attempts:
        raise CloudPlayabilityError("--soak-min-passes cannot exceed --soak-attempts")
    return SoakConfig(attempts=attempts, min_passes=min_passes)


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


def build_smoke_workflow_fields(
    *,
    ref: str,
    wad_url: str,
    config: LaneConfig,
) -> list[tuple[str, str]]:
    fields = [
        ("expected_ref", ref),
        ("audible_audio_proof", bool_field(config.audible_audio_proof)),
        ("persistence_proof", bool_field(config.persistence_enabled)),
    ]
    if wad_url:
        fields.append(("wad_url", wad_url))
    if config.persistence_enabled:
        fields.append(("persistence_save_slot", config.persistence_save_slot))
    return fields


def build_soak_workflow_fields(
    *,
    ref: str,
    wad_url: str,
    config: LaneConfig,
    soak: SoakConfig,
) -> list[tuple[str, str]]:
    fields = [
        ("expected_ref", ref),
        ("attempts", str(soak.attempts)),
        ("min_passes", str(soak.min_passes)),
        ("audible_audio_proof", bool_field(config.audible_audio_proof)),
    ]
    if wad_url:
        fields.append(("wad_url", wad_url))
    return fields


def workflow_run_command(
    *,
    workflow: str,
    repo: str,
    ref: str,
    fields: Sequence[tuple[str, str]],
) -> list[str]:
    command = [
        "gh",
        "workflow",
        "run",
        workflow,
        "--repo",
        repo,
        "--ref",
        ref,
    ]
    for key, value in fields:
        command.extend(["-f", f"{key}={value}"])
    return command


def command_text(command: Sequence[str]) -> str:
    return shlex.join([str(part) for part in command])


def write_audit_log(path: Path, audit: Mapping[str, object], stdout: TextIO) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(audit, indent=2, sort_keys=True) + "\n")
    print(f"audit log: {path}", file=stdout)


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


def run_metadata(repo: str, run_id: str) -> dict[str, object]:
    result = run_command(run_view_command(repo, run_id), capture_json=True)
    return json.loads(result.stdout or "{}")


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


def latest_run_for_ref(repo: str, ref: str, workflow: str) -> dict[str, object]:
    command = [
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
        "10",
        "--json",
        "databaseId,createdAt,headBranch,headSha,status,conclusion,url",
    ]
    result = run_command(command, capture_json=True)
    runs = json.loads(result.stdout or "[]")
    if not runs:
        raise CloudPlayabilityError(
            f"could not find a recent {workflow} workflow_dispatch run for ref {ref!r}"
        )
    return runs[0]


def find_dispatched_run(
    *,
    repo: str,
    ref: str,
    workflow: str,
    created_after: datetime,
    attempts: int = 30,
    delay_seconds: float = 2.0,
) -> dict[str, object]:
    threshold = created_after.timestamp() - 10
    last_error: Exception | None = None
    for _ in range(attempts):
        try:
            run = latest_run_for_ref(repo, ref, workflow)
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


def download_artifact_command(
    repo: str,
    run_id: str,
    output_dir: Path,
    artifact: str,
) -> list[str]:
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


def artifact_checker_command(
    output_dir: Path,
    config: LaneConfig,
    *,
    soak: bool,
    checker_root: Path | None = None,
) -> list[str]:
    tool = "tools/check_cloud_playability_artifacts.py"
    if checker_root is not None:
        tool = str(checker_root / tool)
    if soak:
        return [
            sys.executable,
            tool,
            "--soak-summary",
            str(output_dir),
        ]

    command = [
        sys.executable,
        tool,
        str(output_dir),
        "--require-gameplay-proof",
    ]
    if config.audible_audio_proof:
        command.append("--require-audible-proof")
    return command


def persistence_checker_command(
    output_dir: Path,
    *,
    checker_root: Path | None = None,
    json_output: bool = False,
) -> list[str]:
    tool = "tools/triage_persistence_artifacts.py"
    if checker_root is not None:
        tool = str(checker_root / tool)
    command = [sys.executable, tool]
    if json_output:
        command.append("--json")
    command.append(str(output_dir))
    return command


def verify_persistence_artifacts(
    output_dir: Path,
    *,
    checker_root: Path | None,
    stdout: TextIO,
) -> None:
    command = persistence_checker_command(
        output_dir,
        checker_root=checker_root,
        json_output=True,
    )
    result = run_command(command, capture_json=True)
    report = json.loads(result.stdout or "{}")
    overall = report.get("overall")
    print(f"persistence check: overall={overall}", file=stdout)
    if overall != "persistence-proof-green":
        raise CloudPlayabilityError(
            f"persistence artifact triage was {overall!r}, expected "
            "persistence-proof-green"
        )


def infer_lane_from_artifacts(output_dir: Path) -> str:
    if (output_dir / "real-wad-soak-summary.json").exists() or list(
        output_dir.rglob("real-wad-soak-summary.json")
    ):
        return "audio"
    has_audio = (output_dir / "audio-proof.json").exists() or bool(
        list(output_dir.rglob("audio-proof.json"))
    )
    has_persistence = any(output_dir.glob("status.persistence*.txt")) or bool(
        list(output_dir.rglob("status.persistence*.txt"))
    )
    if has_audio and has_persistence:
        return "full"
    if has_persistence:
        return "persistence"
    if has_audio:
        return "audio"
    return "gameplay"


def find_status_for_triage(output_dir: Path) -> Path | None:
    for basename in STATUS_TRIAGE_BASENAMES:
        candidate = output_dir / basename
        if candidate.exists():
            return candidate
        matches = sorted(output_dir.rglob(basename))
        if matches:
            return matches[0]
    return None


def checker_worktree_path(ref: str) -> Path:
    safe = re.sub(r"[^A-Za-z0-9._-]+", "-", ref).strip("-") or "checker"
    return ROOT / "build" / "cloud-checkers" / safe[:80]


def prepare_checker_worktree(ref: str, *, dry_run: bool, stdout: TextIO) -> Path:
    path = checker_worktree_path(ref)
    print(f"checker ref: detached {ref}", file=stdout)
    print(f"checker worktree: {path}", file=stdout)
    command = ["git", "worktree", "add", "--detach", str(path), ref]
    print(f"checker checkout: {shlex.join(command)}", file=stdout)
    if dry_run:
        return path
    if path.exists():
        head = run_command(
            ["git", "-C", str(path), "rev-parse", "HEAD"],
            capture_json=True,
        ).stdout.strip()
        requested = run_command(
            ["git", "rev-parse", ref],
            capture_json=True,
        ).stdout.strip()
        if head != requested:
            raise CloudPlayabilityError(
                f"checker worktree {path} already exists at {head}, not {requested}"
            )
        return path
    path.parent.mkdir(parents=True, exist_ok=True)
    run_command(command)
    return path


def triage_status(
    output_dir: Path,
    stdout: TextIO,
    *,
    checker_root: Path | None = None,
) -> None:
    status_path = find_status_for_triage(output_dir)
    if status_path is None:
        print(
            f"triage: no status.txt or status.failure.txt found under {output_dir}",
            file=stdout,
        )
        return
    tool = "tools/triage_cloud_status.py"
    if checker_root is not None:
        tool = str(checker_root / tool)
    print(f"triage: {status_path}", file=stdout)
    run_command([sys.executable, tool, str(status_path)])


def lane_failure_report(
    *,
    output_dir: Path,
    config: LaneConfig,
    soak: bool,
) -> list[str]:
    if soak:
        return [
            "failure lanes:",
            (
                "  gameplay/audio soak: "
                f"{sys.executable} tools/check_cloud_playability_artifacts.py "
                f"--soak-summary {output_dir}"
            ),
            (
                "  long-run cadence/noVNC slowdown: inspect "
                f"{output_dir / 'real-wad-soak-summary.json'} status_cadence entries"
            ),
            "  persistence: not requested by real-wad-soak.yml; run --lane persistence separately",
        ]

    report = [
        "failure lanes:",
        (
            "  gameplay/input: "
            f"{sys.executable} tools/check_cloud_playability_artifacts.py "
            f"{output_dir} --require-gameplay-proof"
        ),
        (
            "  SB16 continuity: "
            f"{sys.executable} tools/check_audio_continuity_proof.py "
            f"--baseline {output_dir / 'status.after-start.txt'} "
            f"--fire {output_dir / 'status.after-fire.txt'} "
            f"--movement {output_dir / 'status.after-move.txt'} "
            f"--use {output_dir / 'status.after-use.txt'} "
            f"--menu {output_dir / 'status.after-menu.txt'} "
            f"{output_dir / 'status.txt'}"
        ),
        (
            "  long-run cadence/noVNC slowdown: "
            f"{sys.executable} tools/check_scripted_gameplay_proof.py "
            f"--start {output_dir / 'status.after-start.txt'} "
            f"--fire {output_dir / 'status.after-fire.txt'} "
            f"--movement {output_dir / 'status.after-move.txt'} "
            f"--use {output_dir / 'status.after-use.txt'} "
            f"--mouse {output_dir / 'status.after-mouse.txt'} "
            f"--menu {output_dir / 'status.after-menu.txt'} "
            f"--write-json {output_dir / 'gameplay-proof.json'} "
            f"--require-long-run-cadence "
            f"{output_dir / 'status.txt'}"
        ),
    ]
    if config.audible_audio_proof:
        report.append(
            "  audible audio aggregate: "
            f"{sys.executable} tools/check_audible_audio_proof.py "
            f"{output_dir / 'audio-proof.json'}"
        )
    else:
        report.append("  audible audio aggregate: not requested for this lane")

    if config.persistence_enabled:
        report.append(
            "  persistence/save-load: "
            "inspect status.persistence-*.txt and run "
            f"{sys.executable} tools/triage_cloud_status.py "
            f"{output_dir / 'status.persistence-load.txt'}"
        )
    else:
        report.append("  persistence/save-load: not requested for this lane")
    return report


def helper_command(
    *,
    repo: str,
    ref: str,
    lane: str,
    output_dir: str,
    extra: Sequence[str] = (),
) -> str:
    command = [
        "python3",
        "tools/run_cloud_playability.py",
        "--repo",
        repo,
        "--ref",
        ref,
        "--lane",
        lane,
        *extra,
        "--wait",
        "--download-artifacts",
        output_dir,
    ]
    return command_text(command)


def lane_rerun_report(
    *,
    repo: str,
    ref: str,
    save_slot: str,
    config: LaneConfig,
    soak: SoakConfig | None,
) -> list[str]:
    if soak is not None:
        lane = "audio" if config.audible_audio_proof else "gameplay"
        attempts = str(soak.attempts) if soak.attempts else "ATTEMPTS"
        min_passes = str(soak.min_passes) if soak.min_passes else "MIN_PASSES"
        return [
            "rerun only the red lane:",
            (
                f"  {lane} soak red: "
                + helper_command(
                    repo=repo,
                    ref=ref,
                    lane=lane,
                    extra=("--soak-attempts", attempts, "--soak-min-passes", min_passes),
                    output_dir=f"build/cloud-soak-{lane}",
                )
            ),
            (
                f"  {lane} single-run triage: "
                + helper_command(
                    repo=repo,
                    ref=ref,
                    lane=lane,
                    output_dir=f"build/cloud-run-{lane}",
                )
            ),
            "  persistence: not requested by real-wad-soak.yml; rerun persistence separately if that lane is red",
        ]

    return [
        "rerun only the red lane:",
        (
            "  gameplay/input red: "
            + helper_command(
                repo=repo,
                ref=ref,
                lane="gameplay",
                output_dir="build/cloud-run-gameplay",
            )
        ),
        (
            "  audio red: "
            + helper_command(
                repo=repo,
                ref=ref,
                lane="audio",
                output_dir="build/cloud-run-audio",
            )
        ),
        (
            "  persistence/save-load red: "
            + helper_command(
                repo=repo,
                ref=ref,
                lane="persistence",
                extra=("--save-slot", save_slot),
                output_dir="build/cloud-run-persistence",
            )
        ),
        (
            "  long-run cadence/noVNC slowdown: "
            + helper_command(
                repo=repo,
                ref=ref,
                lane="audio",
                extra=("--soak-attempts", "3", "--soak-min-passes", "3"),
                output_dir="build/cloud-soak-audio",
            )
        ),
    ]


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
            "proof lane: auto infers after artifact download for existing runs; "
            "gameplay is fastest; audio isolates audible proof; "
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
        "--checker-ref",
        default="",
        help=(
            "run artifact checks from a detached git worktree at this ref. Use "
            "'run' with --run-id to use the run head SHA, keeping old cloud "
            "proofs reproducible when local checkers have moved on."
        ),
    )
    parser.add_argument(
        "--soak-attempts",
        default="",
        help=(
            "dispatch real-wad-soak.yml instead of a single smoke run; valid with "
            "--lane gameplay or --lane audio, capped at 20 attempts"
        ),
    )
    parser.add_argument(
        "--soak",
        action="store_true",
        help=(
            "use the real-wad-soak.yml metadata artifact for --run-id inspection. "
            "New soak dispatches still require --soak-attempts."
        ),
    )
    parser.add_argument(
        "--soak-min-passes",
        default="",
        help=(
            "required passing attempts for --soak-attempts. Empty means every "
            "attempt must pass."
        ),
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
        "--write-audit-log",
        type=Path,
        help=(
            "write a machine-readable JSON audit record of the selected workflow, "
            "artifact policy, run metadata, commands, checker ref, and failure lanes"
        ),
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
        if args.lane == "auto":
            if not args.run_id and not args.download_artifacts:
                raise CloudPlayabilityError(
                    "--lane auto needs --run-id and/or --download-artifacts; "
                    "choose a concrete lane for new dispatch"
                )
            config = LaneConfig(audible_audio_proof=False, persistence_save_slot="")
        else:
            config = lane_config(args.lane, save_slot)
        soak = validate_soak_config(
            lane=args.lane,
            requested=args.soak,
            attempts_raw=args.soak_attempts,
            min_passes_raw=args.soak_min_passes,
            run_id=args.run_id,
        )
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
    if args.lane == "auto":
        print(
            "lane: auto (infer gameplay/audio/persistence/full from downloaded artifacts)",
            file=stdout,
        )
    else:
        print(f"lane: {args.lane} ({render_lane_help(args.lane, config)})", file=stdout)
    if soak:
        if soak.attempts:
            print(
                f"mode: repeated soak ({SOAK_WORKFLOW}, attempts={soak.attempts}, "
                f"min_passes={soak.min_passes})",
                file=stdout,
            )
        else:
            print(f"mode: repeated soak ({SOAK_WORKFLOW}, existing run)", file=stdout)
    else:
        print(f"mode: single smoke ({SMOKE_WORKFLOW})", file=stdout)
    print("local VM: refused; this helper dispatches GitHub Actions only", file=stdout)
    print("artifact policy: no WADs, disk images, rendered pixels, or raw audio", file=stdout)

    workflow = SOAK_WORKFLOW if soak else SMOKE_WORKFLOW
    artifact = SOAK_ARTIFACT if soak else SMOKE_ARTIFACT
    audit: dict[str, object] = {
        "schema": CLOUD_AUDIT_SCHEMA,
        "repo": args.repo,
        "ref": args.ref,
        "lane_requested": args.lane,
        "lane_effective": None if args.lane == "auto" else args.lane,
        "mode": "soak" if soak else "smoke",
        "workflow": workflow,
        "artifact": artifact,
        "dry_run": args.dry_run,
        "local_vm": "refused",
        "artifact_policy": {
            "contains_wad_data": False,
            "contains_disk_image": False,
            "contains_pixels": False,
            "contains_raw_audio": False,
        },
        "commands": {},
        "failure_lanes": [],
        "rerun_lanes": [],
        "run_metadata": None,
        "checker_ref": None,
        "checker_worktree": None,
        "download_dir": None,
    }

    run_id = args.run_id
    metadata: dict[str, object] | None = None
    checker_root: Path | None = None
    run_conclusion = 0
    if not run_id:
        if soak:
            if not soak.attempts:
                print(
                    "cloud playability failed: --soak dispatch requires --soak-attempts",
                    file=stderr,
                )
                return 1
            fields = build_soak_workflow_fields(
                ref=args.ref,
                wad_url=wad_url,
                config=config,
                soak=soak,
            )
        else:
            fields = build_smoke_workflow_fields(
                ref=args.ref,
                wad_url=wad_url,
                config=config,
            )
        command = workflow_run_command(
            workflow=workflow,
            repo=args.repo,
            ref=args.ref,
            fields=fields,
        )
        audit["commands"]["dispatch"] = command_text(command)  # type: ignore[index]
        print(f"dispatch: {command_text(command)}", file=stdout)
        if args.dry_run:
            print("dry-run: workflow was not dispatched", file=stdout)
        else:
            created_after = datetime.now(timezone.utc)
            try:
                run_command(command)
                run = find_dispatched_run(
                    repo=args.repo,
                    ref=args.ref,
                    workflow=workflow,
                    created_after=created_after,
                )
                metadata = run
                audit["run_metadata"] = run
                run_id = str(run["databaseId"])
                for line in summarize_run(run):
                    print(line, file=stdout)
            except (CloudPlayabilityError, subprocess.CalledProcessError) as exc:
                print(f"cloud playability failed: {exc}", file=stderr)
                return 1
    else:
        print(f"run: {run_id}", file=stdout)
        metadata_command = run_view_command(args.repo, run_id)
        audit["commands"]["metadata"] = command_text(metadata_command)  # type: ignore[index]
        print(f"metadata: {command_text(metadata_command)}", file=stdout)
        if not args.dry_run:
            try:
                metadata = run_metadata(args.repo, run_id)
                audit["run_metadata"] = metadata
                for line in summarize_run(metadata):
                    print(line, file=stdout)
            except (json.JSONDecodeError, subprocess.CalledProcessError) as exc:
                print(f"cloud playability failed: could not read run metadata: {exc}", file=stderr)
                return 1

    if args.checker_ref:
        checker_ref = args.checker_ref
        if checker_ref == "run":
            if metadata is None:
                if args.dry_run:
                    checker_ref = "RUN_HEAD_SHA"
                else:
                    print(
                        "cloud playability failed: --checker-ref run requires --run-id metadata",
                        file=stderr,
                    )
                    return 1
            else:
                checker_ref = str(metadata.get("headSha") or "")
                if not checker_ref:
                    print(
                        "cloud playability failed: run metadata did not include headSha",
                        file=stderr,
                    )
                    return 1
        try:
            checker_root = prepare_checker_worktree(
                checker_ref,
                dry_run=args.dry_run,
                stdout=stdout,
            )
            audit["checker_ref"] = checker_ref
            audit["checker_worktree"] = str(checker_root)
        except (CloudPlayabilityError, subprocess.CalledProcessError) as exc:
            print(f"cloud playability failed: {exc}", file=stderr)
            return 1

    if args.dry_run and not run_id and (args.wait or args.download_artifacts):
        run_id = "RUN_ID"

    if args.wait and run_id:
        command = ["gh", "run", "watch", run_id, "--repo", args.repo, "--exit-status"]
        audit["commands"]["watch"] = command_text(command)  # type: ignore[index]
        print(f"watch: {command_text(command)}", file=stdout)
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
        command = download_artifact_command(args.repo, run_id, output_dir, artifact)
        audit["commands"]["download"] = command_text(command)  # type: ignore[index]
        audit["download_dir"] = str(output_dir)
        print(f"download: {command_text(command)}", file=stdout)
        effective_config = config
        if args.lane == "auto" and args.dry_run:
            print(
                "lane inference: after download, inspect audio-proof.json and "
                "status.persistence*.txt before selecting checker gates",
                file=stdout,
            )
        checker: list[str] | None = None
        if args.lane == "auto":
            checker_tool = "tools/check_cloud_playability_artifacts.py"
            if checker_root is not None:
                checker_tool = str(checker_root / checker_tool)
            print(
                f"check: deferred until lane inference ({sys.executable} {checker_tool})",
                file=stdout,
            )
        else:
            checker = artifact_checker_command(
                output_dir,
                effective_config,
                soak=soak is not None,
                checker_root=checker_root,
            )
            audit["commands"]["check"] = command_text(checker)  # type: ignore[index]
            print(f"check: {command_text(checker)}", file=stdout)
            if effective_config.persistence_enabled and soak is None:
                persistence_command = persistence_checker_command(
                    output_dir,
                    checker_root=checker_root,
                )
                audit["commands"]["persistence_check"] = command_text(persistence_command)  # type: ignore[index]
                print(
                    f"persistence check: {command_text(persistence_command)} "
                    "(requires persistence-proof-green)",
                    file=stdout,
                )
        failure_lanes = lane_failure_report(
            output_dir=output_dir,
            config=config,
            soak=soak is not None,
        )
        audit["failure_lanes"] = failure_lanes
        for line in failure_lanes:
            print(line, file=stdout)
        rerun_lanes = lane_rerun_report(
            repo=args.repo,
            ref=args.ref,
            save_slot=save_slot,
            config=config,
            soak=soak,
        )
        audit["rerun_lanes"] = rerun_lanes
        for line in rerun_lanes:
            print(line, file=stdout)
        if not args.no_triage and soak is None:
            triage_tool = "tools/triage_cloud_status.py"
            if checker_root is not None:
                triage_tool = str(checker_root / triage_tool)
            triage_command = [sys.executable, triage_tool, str(output_dir / "status.txt")]
            audit["commands"]["triage"] = command_text(triage_command)  # type: ignore[index]
            print(
                f"triage command: {command_text(triage_command)} "
                f"(fallback: {output_dir / 'status.failure.txt'})",
                file=stdout,
            )
        elif not args.no_triage:
            print(
                "triage: soak metadata has no raw status text; validate the JSON "
                "summary here, and use a single-run gameplay/audio lane to debug "
                "a failed attempt",
                file=stdout,
            )
        if args.dry_run:
            print("dry-run: artifact was not downloaded", file=stdout)
        else:
            try:
                output_dir.mkdir(parents=True, exist_ok=True)
                run_command(command)
                if args.lane == "auto":
                    inferred_lane = infer_lane_from_artifacts(output_dir)
                    effective_config = lane_config(inferred_lane, save_slot)
                    audit["lane_effective"] = inferred_lane
                    print(f"lane inferred: {inferred_lane}", file=stdout)
                    checker = artifact_checker_command(
                        output_dir,
                        effective_config,
                        soak=soak is not None,
                        checker_root=checker_root,
                    )
                    audit["commands"]["check"] = command_text(checker)  # type: ignore[index]
                    print(f"check: {command_text(checker)}", file=stdout)
                    if effective_config.persistence_enabled and soak is None:
                        persistence_command = persistence_checker_command(
                            output_dir,
                            checker_root=checker_root,
                        )
                        audit["commands"]["persistence_check"] = command_text(persistence_command)  # type: ignore[index]
                        print(
                            f"persistence check: {command_text(persistence_command)} "
                            "(requires persistence-proof-green)",
                            file=stdout,
                        )
                if not args.no_triage and soak is None:
                    triage_status(output_dir, stdout, checker_root=checker_root)
                if checker is None:
                    raise CloudPlayabilityError("internal error: no artifact checker selected")
                run_command(checker)
                if effective_config.persistence_enabled and soak is None:
                    verify_persistence_artifacts(
                        output_dir,
                        checker_root=checker_root,
                        stdout=stdout,
                    )
            except CloudPlayabilityError as exc:
                print(f"cloud playability artifact check failed: {exc}", file=stderr)
                return 1
            except subprocess.CalledProcessError as exc:
                print(f"cloud playability artifact check failed: {exc}", file=stderr)
                return exc.returncode

    if args.write_audit_log:
        write_audit_log(args.write_audit_log, audit, stdout)

    return run_conclusion


if __name__ == "__main__":
    raise SystemExit(main())
