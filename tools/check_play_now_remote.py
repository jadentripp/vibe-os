#!/usr/bin/env python3
"""Preflight the fastest remote Doom play path without launching QEMU."""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Mapping, TextIO


REQUIRED_TOOLS = (
    "python3",
    "make",
    "nasm",
    "clang",
    "qemu-system-x86_64",
)

DEFAULT_NOVNC_PORT = "6080"
DEFAULT_VNC_DISPLAY = "1"
CGROUP_ROOT = Path("/sys/fs/cgroup")

NOVNC_WEB_ROOTS = (
    Path("/usr/share/novnc"),
    Path("/usr/local/share/novnc"),
    Path("/opt/homebrew/share/novnc"),
)

UBUNTU_INSTALL_HINT = (
    "sudo apt-get update && sudo apt-get install -y "
    "nasm qemu-system-x86 clang make netcat-openbsd curl novnc websockify"
)


class PreflightError(RuntimeError):
    """Raised when the remote play preflight cannot safely proceed."""


@dataclass(frozen=True)
class ToolStatus:
    name: str
    path: str | None

    @property
    def present(self) -> bool:
        return self.path is not None


@dataclass(frozen=True)
class NovncStatus:
    websockify: str | None
    web_root: Path | None

    @property
    def available(self) -> bool:
        return self.websockify is not None and self.web_root is not None


@dataclass(frozen=True)
class CpuDiagnostics:
    effective_count: int | None
    online_count: int | None
    cgroup_quota_count: int | None
    cgroup_cpuset_count: int | None
    limiting_source: str


@dataclass(frozen=True)
class CgroupCpuRuntime:
    stat: Mapping[str, int]
    pressure: Mapping[str, Mapping[str, float | int]]
    throttled_period_ratio: float | None


@dataclass(frozen=True)
class PreflightReport:
    platform_name: str
    cpu_count: int | None
    novnc_port: int
    vnc_display: int
    vnc_port: int
    required_tools: tuple[ToolStatus, ...]
    novnc: NovncStatus
    load_average: tuple[float, float, float] | None = None
    cpu_diagnostics: CpuDiagnostics | None = None
    cgroup_cpu: CgroupCpuRuntime | None = None

    @property
    def missing_required_tools(self) -> tuple[str, ...]:
        return tuple(tool.name for tool in self.required_tools if not tool.present)


def _is_macos(platform_name: str) -> bool:
    return platform_name == "Darwin"


def _local_vm_allowed(env: Mapping[str, str]) -> bool:
    return env.get("ALLOW_LOCAL_VM") == "1"


def _validate_tcp_port(name: str, raw_value: str) -> int:
    if not raw_value.isdigit():
        raise PreflightError(f"{name} must be a TCP port number, got {raw_value!r}")

    port = int(raw_value, 10)
    if port < 1 or port > 65535:
        raise PreflightError(f"{name} must be between 1 and 65535, got {raw_value!r}")
    return port


def _validate_vnc_display(raw_value: str) -> tuple[int, int]:
    if not raw_value.isdigit():
        raise PreflightError(
            f"VNC_DISPLAY must be a non-negative integer, got {raw_value!r}"
        )

    display = int(raw_value, 10)
    if display > 59635:
        raise PreflightError(
            "VNC_DISPLAY must map to a TCP port between 5900 and 65535, "
            f"got {raw_value!r}"
        )
    return display, 5900 + display


def _find_novnc_web_root(
    *,
    env: Mapping[str, str],
    path_is_dir: Callable[[Path], bool],
) -> Path | None:
    explicit = env.get("NOVNC_WEB_ROOT", "")
    if explicit:
        path = Path(explicit)
        if not path_is_dir(path):
            raise PreflightError(f"NOVNC_WEB_ROOT does not exist: {explicit}")
        return path

    return next((root for root in NOVNC_WEB_ROOTS if path_is_dir(root)), None)


def _read_text(path: Path) -> str | None:
    try:
        return path.read_text().strip()
    except OSError:
        return None


def _parse_cpu_range_list(raw_value: str) -> int | None:
    count = 0
    for chunk in raw_value.split(","):
        part = chunk.strip()
        if not part:
            continue
        if "-" in part:
            start_raw, end_raw = part.split("-", 1)
            if not start_raw.isdigit() or not end_raw.isdigit():
                return None
            start = int(start_raw, 10)
            end = int(end_raw, 10)
            if end < start:
                return None
            count += end - start + 1
        elif part.isdigit():
            count += 1
        else:
            return None
    return count or None


def _parse_int_key_value_lines(raw_value: str | None) -> dict[str, int]:
    if not raw_value:
        return {}

    parsed: dict[str, int] = {}
    for line in raw_value.splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue
        try:
            parsed[parts[0]] = int(parts[1], 10)
        except ValueError:
            continue
    return parsed


def _parse_pressure_lines(raw_value: str | None) -> dict[str, dict[str, float | int]]:
    if not raw_value:
        return {}

    pressure: dict[str, dict[str, float | int]] = {}
    for line in raw_value.splitlines():
        parts = line.split()
        if not parts:
            continue
        label = parts[0]
        values: dict[str, float | int] = {}
        for item in parts[1:]:
            if "=" not in item:
                continue
            key, raw_item_value = item.split("=", 1)
            try:
                values[key] = (
                    int(raw_item_value, 10)
                    if key == "total"
                    else float(raw_item_value)
                )
            except ValueError:
                continue
        if values:
            pressure[label] = values
    return pressure


def _cgroup_quota_cpu_count(cgroup_root: Path) -> int | None:
    cpu_max = _read_text(cgroup_root / "cpu.max")
    if cpu_max:
        parts = cpu_max.split()
        if len(parts) >= 2 and parts[0] != "max":
            try:
                quota = int(parts[0], 10)
                period = int(parts[1], 10)
            except ValueError:
                return None
            if quota > 0 and period > 0:
                return max(1, math.ceil(quota / period))

    quota_raw = _read_text(cgroup_root / "cpu" / "cpu.cfs_quota_us")
    period_raw = _read_text(cgroup_root / "cpu" / "cpu.cfs_period_us")
    if quota_raw and period_raw:
        try:
            quota = int(quota_raw, 10)
            period = int(period_raw, 10)
        except ValueError:
            return None
        if quota > 0 and period > 0:
            return max(1, math.ceil(quota / period))
    return None


def _cgroup_cpuset_cpu_count(cgroup_root: Path) -> int | None:
    for relative in ("cpuset.cpus.effective", "cpuset.cpus", "cpuset/cpuset.cpus"):
        raw_value = _read_text(cgroup_root / relative)
        if raw_value:
            parsed = _parse_cpu_range_list(raw_value)
            if parsed:
                return parsed
    return None


def _cgroup_cpu_runtime(cgroup_root: Path) -> CgroupCpuRuntime:
    stat: dict[str, int] = {}
    for relative in ("cpu.stat", "cpu/cpu.stat"):
        stat = _parse_int_key_value_lines(_read_text(cgroup_root / relative))
        if stat:
            break

    pressure: dict[str, dict[str, float | int]] = {}
    for relative in ("cpu.pressure", "cpu/cpu.pressure"):
        pressure = _parse_pressure_lines(_read_text(cgroup_root / relative))
        if pressure:
            break

    throttled_period_ratio = None
    nr_periods = stat.get("nr_periods")
    nr_throttled = stat.get("nr_throttled")
    if nr_periods and nr_periods > 0 and nr_throttled is not None:
        throttled_period_ratio = round(nr_throttled / nr_periods, 4)

    return CgroupCpuRuntime(
        stat=stat,
        pressure=pressure,
        throttled_period_ratio=throttled_period_ratio,
    )


def _effective_cpu_count(
    *,
    cpu_count_provider: Callable[[], int | None] = os.cpu_count,
    cgroup_root: Path = CGROUP_ROOT,
) -> int | None:
    return _cpu_diagnostics(
        cpu_count_provider=cpu_count_provider,
        cgroup_root=cgroup_root,
    ).effective_count


def _cpu_diagnostics(
    *,
    cpu_count_provider: Callable[[], int | None] = os.cpu_count,
    cgroup_root: Path = CGROUP_ROOT,
) -> CpuDiagnostics:
    online_count = cpu_count_provider()
    cgroup_quota_count = _cgroup_quota_cpu_count(cgroup_root)
    cgroup_cpuset_count = _cgroup_cpuset_cpu_count(cgroup_root)
    candidates = (
        ("online", online_count),
        ("cgroup-quota", cgroup_quota_count),
        ("cgroup-cpuset", cgroup_cpuset_count),
    )
    positive = [
        (source, count)
        for source, count in candidates
        if count is not None and count > 0
    ]
    if not positive:
        return CpuDiagnostics(
            effective_count=None,
            online_count=online_count,
            cgroup_quota_count=cgroup_quota_count,
            cgroup_cpuset_count=cgroup_cpuset_count,
            limiting_source="unknown",
        )

    effective_count = min(count for _, count in positive)
    cgroup_limits = {
        source: count
        for source, count in positive
        if source.startswith("cgroup-") and count == effective_count
    }
    if cgroup_limits:
        limiting_source = "+".join(cgroup_limits)
    else:
        limiting_source = next(
            source for source, count in positive if count == effective_count
        )

    return CpuDiagnostics(
        effective_count=effective_count,
        online_count=online_count,
        cgroup_quota_count=cgroup_quota_count,
        cgroup_cpuset_count=cgroup_cpuset_count,
        limiting_source=limiting_source,
    )


def _load_average(
    load_average_provider: Callable[[], tuple[float, float, float]] | None = None,
) -> tuple[float, float, float] | None:
    provider = load_average_provider or getattr(os, "getloadavg", None)
    if provider is None:
        return None

    try:
        one_minute, five_minute, fifteen_minute = provider()
    except (AttributeError, OSError, TypeError, ValueError):
        return None
    return (float(one_minute), float(five_minute), float(fifteen_minute))


def _report_cpu_diagnostics(report: PreflightReport) -> CpuDiagnostics:
    if report.cpu_diagnostics is not None:
        return report.cpu_diagnostics
    return CpuDiagnostics(
        effective_count=report.cpu_count,
        online_count=None,
        cgroup_quota_count=None,
        cgroup_cpuset_count=None,
        limiting_source="unknown",
    )


def check_preflight(
    *,
    env: Mapping[str, str] | None = None,
    platform_name: str | None = None,
    which: Callable[[str], str | None] = shutil.which,
    path_is_dir: Callable[[Path], bool] = Path.is_dir,
    require_novnc: bool = False,
    cpu_count_provider: Callable[[], int | None] = os.cpu_count,
    cgroup_root: Path = CGROUP_ROOT,
    load_average_provider: Callable[[], tuple[float, float, float]] | None = None,
) -> PreflightReport:
    """Return a preflight report or raise before any VM action is possible."""

    effective_env = os.environ if env is None else env
    effective_platform = platform.system() if platform_name is None else platform_name
    novnc_port = _validate_tcp_port(
        "NOVNC_PORT", effective_env.get("NOVNC_PORT", DEFAULT_NOVNC_PORT)
    )
    vnc_display, vnc_port = _validate_vnc_display(
        effective_env.get("VNC_DISPLAY", DEFAULT_VNC_DISPLAY)
    )
    if novnc_port == vnc_port:
        raise PreflightError(
            "NOVNC_PORT and VNC_DISPLAY resolve to the same loopback TCP port "
            f"127.0.0.1:{novnc_port}"
        )

    if _is_macos(effective_platform) and not _local_vm_allowed(effective_env):
        raise PreflightError(
            "Refusing to run QEMU on macOS.\n\n"
            "Use this preflight inside a disposable remote Linux host, GitHub "
            "Codespace, or cloud VM. The supported play-now path keeps QEMU "
            "off the local Mac."
        )

    required_tools = tuple(
        ToolStatus(name=tool, path=which(tool)) for tool in REQUIRED_TOOLS
    )
    missing = tuple(tool.name for tool in required_tools if not tool.present)
    if missing:
        raise PreflightError(
            "missing required tools: "
            + ", ".join(missing)
            + "\nUbuntu setup: "
            + UBUNTU_INSTALL_HINT
        )

    web_root = _find_novnc_web_root(env=effective_env, path_is_dir=path_is_dir)
    novnc = NovncStatus(websockify=which("websockify"), web_root=web_root)
    if require_novnc and not novnc.available:
        raise PreflightError(
            "noVNC is required for this launch path but is unavailable.\n"
            "Ubuntu setup: " + UBUNTU_INSTALL_HINT
        )

    cpu_diagnostics = _cpu_diagnostics(
        cpu_count_provider=cpu_count_provider,
        cgroup_root=cgroup_root,
    )
    cgroup_cpu = _cgroup_cpu_runtime(cgroup_root)
    return PreflightReport(
        platform_name=effective_platform,
        cpu_count=cpu_diagnostics.effective_count,
        novnc_port=novnc_port,
        vnc_display=vnc_display,
        vnc_port=vnc_port,
        required_tools=required_tools,
        novnc=novnc,
        load_average=_load_average(load_average_provider),
        cpu_diagnostics=cpu_diagnostics,
        cgroup_cpu=cgroup_cpu,
    )


def render_report(report: PreflightReport) -> str:
    cpu_diagnostics = _report_cpu_diagnostics(report)
    cgroup_cpu = report.cgroup_cpu
    lines = [
        "play-now remote preflight OK",
        f"platform: {report.platform_name}",
        f"host CPUs: {report.cpu_count or 'unknown'}",
        (
            "host CPU basis: "
            f"effective={cpu_diagnostics.effective_count or 'unknown'} "
            f"online={cpu_diagnostics.online_count or 'unknown'} "
            f"cgroup_quota={cpu_diagnostics.cgroup_quota_count or 'unknown'} "
            f"cgroup_cpuset={cpu_diagnostics.cgroup_cpuset_count or 'unknown'} "
            f"limit={cpu_diagnostics.limiting_source}"
        ),
        f"noVNC port: {report.novnc_port}",
        f"QEMU VNC display: :{report.vnc_display} (127.0.0.1:{report.vnc_port})",
        "required tools:",
    ]
    for tool in report.required_tools:
        lines.append(f"  {tool.name}: {tool.path}")

    lines.append("optional noVNC:")
    if report.novnc.available:
        lines.append(f"  websockify: {report.novnc.websockify}")
        lines.append(f"  web root: {report.novnc.web_root}")
        lines.append("  browser proxy: available")
    else:
        lines.append(f"  websockify: {report.novnc.websockify or 'missing'}")
        lines.append(f"  web root: {report.novnc.web_root or 'missing'}")
        lines.append("  browser proxy: unavailable; use an SSH VNC tunnel")

    if report.load_average is None:
        lines.append("loadavg: unavailable")
    else:
        one_minute, five_minute, fifteen_minute = report.load_average
        lines.append(
            f"loadavg: 1m={one_minute:.2f} 5m={five_minute:.2f} "
            f"15m={fifteen_minute:.2f}"
        )
        if report.cpu_count:
            lines.append(f"load per CPU: 1m={one_minute / report.cpu_count:.2f}")

    if cgroup_cpu is not None and cgroup_cpu.stat:
        preferred_stat_keys = (
            "usage_usec",
            "user_usec",
            "system_usec",
            "nr_periods",
            "nr_throttled",
            "throttled_usec",
        )
        stat_fields = [
            f"{key}={cgroup_cpu.stat[key]}"
            for key in preferred_stat_keys
            if key in cgroup_cpu.stat
        ]
        lines.append("cgroup cpu.stat: " + " ".join(stat_fields))
        if cgroup_cpu.throttled_period_ratio is not None:
            lines.append(
                "cgroup throttle ratio: "
                f"nr_throttled/nr_periods={cgroup_cpu.throttled_period_ratio:.4f}"
            )

    if cgroup_cpu is not None and cgroup_cpu.pressure:
        pressure_fields = []
        for label in ("some", "full"):
            values = cgroup_cpu.pressure.get(label)
            if not values:
                continue
            for key in ("avg10", "avg60", "avg300", "total"):
                if key in values:
                    pressure_fields.append(f"{label}.{key}={values[key]}")
        if pressure_fields:
            lines.append("cgroup cpu.pressure: " + " ".join(pressure_fields))

    if report.cpu_count is None:
        lines.append(
            "performance note: 4+ host CPUs are recommended for smoother "
            "QEMU/noVNC play"
        )
    elif report.cpu_count <= 2:
        lines.append(
            "performance caveat: 2-core hosts can play Doom but may stutter "
            "while QEMU, noVNC, and builds share CPU"
        )
        lines.append(
            "performance note: choose a 4-core+ Codespace when available for "
            "smoother human playtests"
        )
        lines.append(
            "2-core slowdown triage: if gtic/leveltime/doompresent/dtick keep "
            "advancing while noVNC degrades, recreate on a 4+ CPU Codespace "
            "before changing OS runtime code"
        )
        lines.append(
            "recommended Codespaces shape: 4+ CPU; the Mac launcher prefers "
            "the smallest available 4+ CPU machine for new CLI-created sessions"
        )
        if (
            report.load_average is not None
            and report.load_average[0] >= report.cpu_count
        ):
            lines.append(
                "performance warning: current 1m load is at/above available "
                "CPUs; noVNC/QEMU can degrade under sustained contention"
            )
            lines.append(
                "diagnostics tip: compare status-only snapshots during slowdown "
                "before changing OS runtime code"
            )
    elif report.cpu_count >= 4:
        lines.append(
            "performance note: 4-core+ host detected; this is the preferred "
            "shape for smoother human playtests"
        )

    if (
        cgroup_cpu is not None
        and cgroup_cpu.throttled_period_ratio is not None
        and cgroup_cpu.throttled_period_ratio > 0
    ):
        lines.append(
            "performance warning: cgroup CPU throttling is visible; "
            "sample diagnostics over time or resize to 4+ CPUs"
        )

    lines.append("dry-run: QEMU was not launched")
    lines.append("next: run ./tools/play_now_remote.sh on the remote host")
    return "\n".join(lines) + "\n"


def report_to_json(report: PreflightReport) -> dict[str, object]:
    """Return a stable machine-readable preflight report."""

    cpu_diagnostics = _report_cpu_diagnostics(report)
    cgroup_cpu = report.cgroup_cpu or CgroupCpuRuntime(
        stat={},
        pressure={},
        throttled_period_ratio=None,
    )
    warnings: list[str] = []
    recommendations: list[str] = []
    if report.cpu_count is None:
        shape = "unknown"
        recommendations.append(
            "Use a 4+ CPU Codespace or disposable cloud VM for smoother long sessions."
        )
    elif report.cpu_count <= 2:
        shape = "two-core"
        warnings.append(
            "2-core hosts can play Doom but may stutter while QEMU, noVNC, and builds share CPU."
        )
        recommendations.append(
            "Prefer a 4+ CPU Codespace for longer human playtests."
        )
    elif report.cpu_count >= 4:
        shape = "preferred-4-plus-core"
        recommendations.append(
            "Host shape is preferred for interactive noVNC play."
        )
    else:
        shape = "three-core"
        recommendations.append(
            "A 4+ CPU host is still preferred for longer human playtests."
        )

    load_average: dict[str, float] | None = None
    load_per_cpu_1m: float | None = None
    if report.load_average is not None:
        one_minute, five_minute, fifteen_minute = report.load_average
        load_average = {
            "one_minute": round(one_minute, 2),
            "five_minute": round(five_minute, 2),
            "fifteen_minute": round(fifteen_minute, 2),
        }
        if report.cpu_count:
            load_per_cpu_1m = round(one_minute / report.cpu_count, 2)
            if one_minute >= report.cpu_count:
                warnings.append(
                    "Current 1m load is at/above available CPUs; noVNC/QEMU can degrade under sustained contention."
                )
                recommendations.append(
                    "Compare status-only diagnostics snapshots during slowdown before changing OS runtime code."
                )

    if (
        cgroup_cpu.throttled_period_ratio is not None
        and cgroup_cpu.throttled_period_ratio > 0
    ):
        warnings.append(
            "Cgroup CPU throttling is visible; sustained noVNC/QEMU slowdown may be host quota pressure."
        )
        recommendations.append(
            "Use /tmp/vibe-os-play-now-diagnostics.sh --watch while playing, or resize to a 4+ CPU Codespace."
        )

    return {
        "schema": "vibe-os-play-now-preflight-v1",
        "platform": report.platform_name,
        "host_cpus": report.cpu_count,
        "cpu_diagnostics": {
            "effective_count": cpu_diagnostics.effective_count,
            "online_count": cpu_diagnostics.online_count,
            "cgroup_quota_count": cpu_diagnostics.cgroup_quota_count,
            "cgroup_cpuset_count": cpu_diagnostics.cgroup_cpuset_count,
            "limiting_source": cpu_diagnostics.limiting_source,
        },
        "ports": {
            "novnc": report.novnc_port,
            "vnc_display": report.vnc_display,
            "vnc": report.vnc_port,
        },
        "required_tools": {
            tool.name: {"present": tool.present, "path": tool.path}
            for tool in report.required_tools
        },
        "novnc": {
            "available": report.novnc.available,
            "websockify": report.novnc.websockify,
            "web_root": str(report.novnc.web_root) if report.novnc.web_root else None,
        },
        "load_average": load_average,
        "load_per_cpu_1m": load_per_cpu_1m,
        "cgroup_cpu": {
            "stat": dict(cgroup_cpu.stat),
            "pressure": {
                label: dict(values)
                for label, values in cgroup_cpu.pressure.items()
            },
            "throttled_period_ratio": cgroup_cpu.throttled_period_ratio,
        },
        "performance": {
            "host_shape": shape,
            "warnings": warnings,
            "recommendations": recommendations,
        },
        "long_session_diagnostics": {
            "text_command": "/tmp/vibe-os-play-now-diagnostics.sh",
            "json_command": "/tmp/vibe-os-play-now-diagnostics.sh --json",
            "safe_artifacts_only": True,
        },
        "dry_run": {
            "qemu_launched": False,
            "local_artifacts_copied": False,
        },
    }


def main(
    argv: list[str] | None = None,
    *,
    env: Mapping[str, str] | None = None,
    stdout: TextIO = sys.stdout,
    stderr: TextIO = sys.stderr,
    platform_name: str | None = None,
    which: Callable[[str], str | None] = shutil.which,
    path_is_dir: Callable[[Path], bool] = Path.is_dir,
    cpu_count_provider: Callable[[], int | None] = os.cpu_count,
    cgroup_root: Path = CGROUP_ROOT,
    load_average_provider: Callable[[], tuple[float, float, float]] | None = None,
) -> int:
    parser = argparse.ArgumentParser(
        description="Dry-run preflight for the remote vibe-os Doom play path."
    )
    parser.add_argument(
        "--require-novnc",
        action="store_true",
        help="fail unless websockify and a noVNC web root are available",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="emit a machine-readable preflight report",
    )
    args = parser.parse_args(argv)

    try:
        report = check_preflight(
            env=env,
            platform_name=platform_name,
            which=which,
            path_is_dir=path_is_dir,
            require_novnc=args.require_novnc,
            cpu_count_provider=cpu_count_provider,
            cgroup_root=cgroup_root,
            load_average_provider=load_average_provider,
        )
    except PreflightError as exc:
        print(f"play-now remote preflight failed: {exc}", file=stderr)
        print("dry-run: QEMU was not launched", file=stderr)
        return 1

    if args.json:
        stdout.write(json.dumps(report_to_json(report), indent=2, sort_keys=True) + "\n")
    else:
        stdout.write(render_report(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
