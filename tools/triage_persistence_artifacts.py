#!/usr/bin/env python3
"""Phase-aware triage for cloud persistence artifact directories."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import triage_cloud_status
from status_fields import hex8_field, hex_tuple_field, parse_status_fields

SAVEACTION_LOAD_REQUESTED = 0x0020
SAVEACTION_LOAD_DONE = 0x0040
SAVELOAD_EVENT_READ = 0x0002
SAVELOAD_EVENT_CLOSE = 0x0008
SCRIPTED_GAMEPLAY_SCHEMA = "scripted-gameplay-proof-v1"

PASS = "pass"
FAIL = "fail"
MISSING = "missing"

PROOF_FAILURE_RE = re.compile(
    r"\b(AssertionError|Traceback|failed|failure|error:|FAIL)\b",
    re.IGNORECASE,
)


@dataclass(frozen=True)
class PhaseResult:
    name: str
    state: str
    classification: str
    path: str | None = None
    proof_path: str | None = None
    notes: tuple[str, ...] = ()


@dataclass(frozen=True)
class ArtifactTriage:
    artifact_dir: Path
    overall: str
    phases: tuple[PhaseResult, ...]
    interpretation: str

    def phase(self, name: str) -> PhaseResult:
        for phase in self.phases:
            if phase.name == name:
                return phase
        raise KeyError(name)

    def to_dict(self) -> dict[str, Any]:
        return {
            "artifact_dir": str(self.artifact_dir),
            "overall": self.overall,
            "interpretation": self.interpretation,
            "phases": [
                {
                    "name": phase.name,
                    "state": phase.state,
                    "classification": phase.classification,
                    "path": phase.path,
                    "proof_path": phase.proof_path,
                    "notes": list(phase.notes),
                }
                for phase in self.phases
            ],
        }


def _relative(path: Path, artifact_dir: Path) -> str:
    try:
        return str(path.relative_to(artifact_dir))
    except ValueError:
        return str(path)


def _read_status(path: Path) -> tuple[dict[str, str], str, list[str]]:
    status = path.read_text(encoding="utf-8")
    fields = parse_status_fields(status, error_type=ValueError)
    primary, notes = triage_cloud_status.classify(fields)
    return fields, primary, notes


def _hex_tuple(fields: dict[str, str], name: str, count: int) -> tuple[int, ...] | None:
    return hex_tuple_field(fields, name, count)


def _save_action(fields: dict[str, str]) -> tuple[int, int, int, int] | None:
    return _hex_tuple(fields, "saveact", 4)


def _save_read(fields: dict[str, str]) -> tuple[int, int] | None:
    return _hex_tuple(fields, "saverd", 2)


def _save_write(fields: dict[str, str]) -> tuple[int, int] | None:
    return _hex_tuple(fields, "savewr", 2)


def _doomsav(fields: dict[str, str]) -> tuple[int, int] | None:
    return _hex_tuple(fields, "doomsav", 2)


def _load_requested(fields: dict[str, str]) -> bool:
    saveact = _save_action(fields)
    doomsav = _doomsav(fields)
    saverd = _save_read(fields)
    return (
        (saveact is not None and (saveact[0] & SAVEACTION_LOAD_REQUESTED) != 0)
        or (doomsav is not None and (doomsav[0] & SAVELOAD_EVENT_READ) != 0)
        or (saverd is not None and (saverd[0] != 0 or saverd[1] != 0))
    )


def _explicit_load_evidence(fields: dict[str, str]) -> bool:
    saveact = _save_action(fields)
    saverd = _save_read(fields)
    return (
        (saveact is not None and (saveact[0] & SAVEACTION_LOAD_REQUESTED) != 0)
        or (saverd is not None and (saverd[0] != 0 or saverd[1] != 0))
    )


def _load_completed(fields: dict[str, str]) -> bool:
    saveact = _save_action(fields)
    saverd = _save_read(fields)
    saveclose = hex8_field(fields, "saveclose")
    doomsav = _doomsav(fields)
    if saveact is None or saverd is None:
        return False
    flags, gameaction, _slot, reports = saveact
    action_done = (
        (flags & (SAVEACTION_LOAD_REQUESTED | SAVEACTION_LOAD_DONE))
        == (SAVEACTION_LOAD_REQUESTED | SAVEACTION_LOAD_DONE)
        and gameaction == 0
        and reports != 0
    )
    read_done = saverd[0] != 0 and saverd[1] != 0
    close_done = saveclose is not None and saveclose != 0
    if doomsav is not None:
        close_done = close_done and (doomsav[0] & SAVELOAD_EVENT_CLOSE) != 0
    return action_done and read_done and close_done and fields.get("gameplay") == "OK"


def _write_completed(fields: dict[str, str]) -> bool:
    doomsav = _doomsav(fields)
    savewr = _save_write(fields)
    saveclose = hex8_field(fields, "saveclose")
    return (
        doomsav is not None
        and doomsav[1] != 0xFFFFFFFF
        and savewr is not None
        and savewr[0] != 0
        and savewr[1] != 0
        and saveclose is not None
        and saveclose != 0
    )


def _phase_status(
    artifact_dir: Path,
    phase_name: str,
    status_path: Path | None,
    proof_path: Path | None = None,
) -> PhaseResult:
    if status_path is None:
        return PhaseResult(
            phase_name,
            MISSING,
            f"{phase_name}-status-missing",
            proof_path=_relative(proof_path, artifact_dir) if proof_path else None,
            notes=("no matching status file was found",),
        )

    rel_status = _relative(status_path, artifact_dir)
    rel_proof = _relative(proof_path, artifact_dir) if proof_path else None
    try:
        fields, primary, notes = _read_status(status_path)
    except (OSError, ValueError) as exc:
        return PhaseResult(
            phase_name,
            FAIL,
            "status-parse-error",
            path=rel_status,
            proof_path=rel_proof,
            notes=(str(exc),),
        )

    proof_note = _proof_note(proof_path)
    rendered_notes = tuple(notes[:2] + proof_note)
    load_phase_write_note = (
        "load-phase savewr counters are ignored for save-write triage; savewr=0/0 is expected on a pure load boot",
    )
    load_rendered_notes = tuple(
        note
        for note in rendered_notes
        if not note.startswith("persistence-save-write")
        and not note.startswith("persistence-save-growth")
    )

    if phase_name == "first-boot":
        state = PASS if primary == "playability-status-green" else FAIL
        classification = "first-boot-green" if state == PASS else primary
        return PhaseResult(
            phase_name,
            state,
            classification,
            path=rel_status,
            proof_path=rel_proof,
            notes=rendered_notes,
        )

    if phase_name == "save-write":
        if _explicit_load_evidence(fields):
            return PhaseResult(
                phase_name,
                FAIL,
                "phase-status-mismatch",
                path=rel_status,
                proof_path=rel_proof,
                notes=(
                    "write-phase status contains reboot/load evidence; use a load-phase status file for load triage",
                    *rendered_notes,
                ),
            )
        if primary in (
            "persistence-save-write-failed",
            "persistence-save-growth-allocation-partial",
        ):
            return PhaseResult(
                phase_name,
                FAIL,
                primary,
                path=rel_status,
                proof_path=rel_proof,
                notes=rendered_notes,
            )
        if primary != "playability-status-green" and not (
            primary == "input-no-effect" and _write_completed(fields)
        ):
            return PhaseResult(
                phase_name,
                FAIL,
                primary,
                path=rel_status,
                proof_path=rel_proof,
                notes=rendered_notes,
            )
        if not _write_completed(fields):
            return PhaseResult(
                phase_name,
                FAIL,
                "persistence-save-write-not-proven",
                path=rel_status,
                proof_path=rel_proof,
                notes=("write-phase status is green but does not prove a nonzero DOOMSAV write and close", *rendered_notes),
            )
        proof_failure = _proof_failure(proof_path)
        save_write_notes = rendered_notes
        if primary == "input-no-effect":
            save_write_notes = (
                "write-phase status lacks full gameplay input-effect proof, but persistence triage only requires nonzero DOOMSAV write/close evidence",
                *rendered_notes,
            )
        return PhaseResult(
            phase_name,
            FAIL if proof_failure else PASS,
            "save-write-proof-status-mismatch" if proof_failure else "persistence-save-write-green",
            path=rel_status,
            proof_path=rel_proof,
            notes=save_write_notes,
        )

    if phase_name == "reboot-load":
        if primary not in (
            "playability-status-green",
            "persistence-save-write-failed",
            "persistence-save-growth-allocation-partial",
            "persistence-load-not-completed",
            "persistence-load-malformed-stream",
        ):
            return PhaseResult(
                phase_name,
                FAIL,
                primary,
                path=rel_status,
                proof_path=rel_proof,
                notes=rendered_notes,
            )
        if primary == "persistence-load-malformed-stream":
            return PhaseResult(
                phase_name,
                FAIL,
                primary,
                path=rel_status,
                proof_path=rel_proof,
                notes=rendered_notes,
            )
        if not _load_requested(fields):
            return PhaseResult(
                phase_name,
                FAIL,
                "persistence-load-not-proven",
                path=rel_status,
                proof_path=rel_proof,
                notes=(
                    "load-phase status does not show saverd= progress, doomsav read flags, or saveact load-requested",
                    *load_phase_write_note,
                    *load_rendered_notes,
                ),
            )
        if not _load_completed(fields):
            return PhaseResult(
                phase_name,
                FAIL,
                "persistence-load-not-completed",
                path=rel_status,
                proof_path=rel_proof,
                notes=(
                    *load_phase_write_note,
                    *load_rendered_notes,
                ),
            )
        proof_failure = _proof_failure(proof_path)
        return PhaseResult(
            phase_name,
            FAIL if proof_failure else PASS,
            "reboot-load-proof-status-mismatch" if proof_failure else "persistence-reboot-load-green",
            path=rel_status,
            proof_path=rel_proof,
            notes=(
                "load completed with saveact load-requested/load-done, nonzero saverd, close evidence, and gameplay=OK",
                *load_phase_write_note,
                *load_rendered_notes,
            ),
        )

    raise ValueError(f"unknown phase {phase_name!r}")


def _proof_note(proof_path: Path | None) -> list[str]:
    if proof_path is None:
        return []
    try:
        text = proof_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        return [f"proof text could not be read: {exc}"]
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if not lines:
        return ["proof text is empty"]
    prefix = "proof text reports a failure" if PROOF_FAILURE_RE.search(text) else "proof text was present"
    return [f"{prefix}: {lines[0][:160]}"]


def _proof_failure(proof_path: Path | None) -> bool:
    if proof_path is None:
        return False
    try:
        return PROOF_FAILURE_RE.search(proof_path.read_text(encoding="utf-8", errors="replace")) is not None
    except OSError:
        return True


def _find_first_existing(artifact_dir: Path, names: tuple[str, ...]) -> Path | None:
    for name in names:
        path = artifact_dir / name
        if path.exists():
            return path
    return None


def _find_status_glob(artifact_dir: Path, patterns: tuple[str, ...]) -> Path | None:
    for pattern in patterns:
        for path in sorted(artifact_dir.glob(pattern)):
            name = path.name
            if "-proof" in name or ".triage." in name or name.endswith(".triage.txt"):
                continue
            return path
    return None


def _phase_paths(artifact_dir: Path) -> dict[str, Path | None]:
    return {
        "first-boot": _find_first_existing(artifact_dir, ("status.txt",)),
        "save-write": _find_first_existing(
            artifact_dir,
            (
                "status.persistence-write.txt",
                "status.persistence-write.status.save-slot-0.txt",
            ),
        )
        or _find_status_glob(artifact_dir, ("status.persistence-write*.txt",)),
        "reboot-load": _find_first_existing(
            artifact_dir,
            (
                "status.persistence-load.txt",
                "status.persistence-reboot.txt",
                "status.persistence-load.status.save-slot-0.txt",
                "status.persistence-reboot.status.save-slot-0.txt",
            ),
        )
        or _find_status_glob(
            artifact_dir,
            ("status.persistence-load*.txt", "status.persistence-reboot*.txt"),
        ),
    }


def _proof_paths(artifact_dir: Path) -> dict[str, Path | None]:
    return {
        "save-write": _find_first_existing(
            artifact_dir,
            (
                "status.persistence-write-proof.txt",
                "status.persistence-write.proof.txt",
            ),
        ),
        "reboot-load": _find_first_existing(
            artifact_dir,
            (
                "status.persistence-load-proof.txt",
                "status.persistence-reboot-proof.txt",
                "status.persistence-load.proof.txt",
            ),
        ),
    }


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _status_entry_path_and_hash(entry: Any) -> tuple[str | None, str | None, int | None]:
    if isinstance(entry, str):
        return entry, None, None
    if not isinstance(entry, dict):
        return None, None, None
    path = entry.get("path")
    if not isinstance(path, str):
        path = entry.get("file")
    if not isinstance(path, str):
        path = None
    sha = entry.get("sha256")
    if not isinstance(sha, str):
        sha = entry.get("status_sha256")
    if not isinstance(sha, str):
        sha = None
    byte_count = entry.get("bytes")
    if not isinstance(byte_count, int):
        byte_count = None
    return path, sha, byte_count


def _manifest_phase(artifact_dir: Path) -> PhaseResult:
    manifest_path = artifact_dir / "gameplay-proof.json"
    if not manifest_path.exists():
        return PhaseResult(
            "manifest/status",
            MISSING,
            "gameplay-proof-manifest-missing",
            notes=("gameplay-proof.json is absent; status phases can still be triaged without WAD/disk/pixel/audio artifacts",),
        )

    rel_manifest = _relative(manifest_path, artifact_dir)
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return PhaseResult(
            "manifest/status",
            FAIL,
            "manifest-status-mismatch",
            path=rel_manifest,
            notes=(f"gameplay-proof.json could not be parsed: {exc}",),
        )
    if not isinstance(manifest, dict):
        return PhaseResult(
            "manifest/status",
            FAIL,
            "manifest-status-mismatch",
            path=rel_manifest,
            notes=("gameplay-proof.json root must be an object",),
        )

    mismatches: list[str] = []
    schema = manifest.get("schema")
    if schema != SCRIPTED_GAMEPLAY_SCHEMA:
        mismatches.append(f"schema={schema!r}, expected {SCRIPTED_GAMEPLAY_SCHEMA!r}")

    status_files = manifest.get("status_files")
    if not isinstance(status_files, dict) or not status_files:
        mismatches.append("status_files must be a non-empty object")
    else:
        phase_order = manifest.get("phase_order")
        if isinstance(phase_order, list):
            for phase in phase_order:
                if isinstance(phase, str) and phase not in status_files:
                    mismatches.append(f"phase_order references missing status_files[{phase!r}]")

        for phase, entry in sorted(status_files.items()):
            rel_path, expected_sha, expected_bytes = _status_entry_path_and_hash(entry)
            if rel_path is None:
                mismatches.append(f"status_files[{phase!r}] has no path")
                continue
            status_path = (artifact_dir / rel_path).resolve()
            try:
                status_path.relative_to(artifact_dir)
            except ValueError:
                mismatches.append(f"status_files[{phase!r}] points outside the artifact: {rel_path}")
                continue
            if not status_path.exists():
                mismatches.append(f"status_files[{phase!r}] points at missing {rel_path}")
                continue
            if expected_sha is not None:
                actual_sha = _sha256_file(status_path)
                if actual_sha != expected_sha:
                    mismatches.append(
                        f"status_files[{phase!r}] sha256 mismatch for {rel_path}: "
                        f"manifest={expected_sha} actual={actual_sha}"
                    )
            if expected_bytes is not None:
                actual_bytes = status_path.stat().st_size
                if actual_bytes != expected_bytes:
                    mismatches.append(
                        f"status_files[{phase!r}] byte mismatch for {rel_path}: "
                        f"manifest={expected_bytes} actual={actual_bytes}"
                    )

    if mismatches:
        return PhaseResult(
            "manifest/status",
            FAIL,
            "manifest-status-mismatch",
            path=rel_manifest,
            notes=tuple(mismatches),
        )
    return PhaseResult(
        "manifest/status",
        PASS,
        "manifest-status-green",
        path=rel_manifest,
        notes=("gameplay-proof.json status_files entries match files present in the artifact",),
    )


def _overall(phases: tuple[PhaseResult, ...]) -> str:
    phase_map = {phase.name: phase for phase in phases}
    for name in ("first-boot", "save-write", "reboot-load"):
        phase = phase_map[name]
        if phase.state == FAIL:
            if name == "first-boot":
                return "first-boot-failed"
            return phase.classification

    manifest = phase_map["manifest/status"]
    if manifest.state == FAIL:
        return "manifest-status-mismatch"

    required_missing = [
        phase
        for phase in (phase_map["save-write"], phase_map["reboot-load"])
        if phase.state == MISSING
    ]
    if required_missing:
        return "persistence-artifact-incomplete"

    if phase_map["first-boot"].state == MISSING:
        return "first-boot-status-missing"

    return "persistence-proof-green"


def _interpretation(overall: str) -> str:
    checker_classes = {
        "manifest-status-mismatch",
        "persistence-artifact-incomplete",
        "first-boot-status-missing",
        "save-write-proof-status-mismatch",
        "reboot-load-proof-status-mismatch",
    }
    if overall == "persistence-proof-green":
        return "write and reboot-load status evidence look green; no WAD/disk/pixel/audio artifact was required"
    if overall in checker_classes:
        return "artifact/checker evidence is inconsistent or incomplete; do not call this a real OS persistence failure from status alone"
    if overall == "first-boot-failed":
        return "real OS/runtime failure before the persistence write/load phases"
    if overall.startswith("persistence-save") or overall == "persistence-save-write-not-proven":
        return "real OS persistence failure in the save/write phase"
    if overall.startswith("persistence-load") or overall.startswith("persistence-reboot"):
        return "real OS persistence failure in the reboot/load phase"
    return "real OS/runtime failure shown by the phase status"


def triage_artifact_dir(artifact_dir: Path) -> ArtifactTriage:
    artifact_dir = artifact_dir.resolve()
    phase_paths = _phase_paths(artifact_dir)
    proof_paths = _proof_paths(artifact_dir)
    phases = (
        _phase_status(artifact_dir, "first-boot", phase_paths["first-boot"]),
        _phase_status(
            artifact_dir,
            "save-write",
            phase_paths["save-write"],
            proof_paths["save-write"],
        ),
        _phase_status(
            artifact_dir,
            "reboot-load",
            phase_paths["reboot-load"],
            proof_paths["reboot-load"],
        ),
        _manifest_phase(artifact_dir),
    )
    overall = _overall(phases)
    return ArtifactTriage(
        artifact_dir=artifact_dir,
        overall=overall,
        phases=phases,
        interpretation=_interpretation(overall),
    )


def render_report(triage: ArtifactTriage) -> str:
    lines = [
        f"overall: {triage.overall}",
        f"artifact: {triage.artifact_dir}",
        f"interpretation: {triage.interpretation}",
    ]
    for phase in triage.phases:
        path = f" path={phase.path}" if phase.path else ""
        proof = f" proof={phase.proof_path}" if phase.proof_path else ""
        lines.append(
            f"{phase.name}: {phase.state} {phase.classification}{path}{proof}"
        )
        for note in phase.notes:
            lines.append(f"  - {note}")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Classify cloud persistence status artifacts phase-by-phase.",
    )
    parser.add_argument("artifact_dir", type=Path)
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit a machine-readable triage report.",
    )
    args = parser.parse_args(argv)

    artifact_dir = args.artifact_dir
    if not artifact_dir.exists() or not artifact_dir.is_dir():
        print(f"persistence artifact triage failed: {artifact_dir} is not a directory", file=sys.stderr)
        return 1

    triage = triage_artifact_dir(artifact_dir)
    if args.json:
        print(json.dumps(triage.to_dict(), indent=2, sort_keys=True))
    else:
        print(render_report(triage))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
