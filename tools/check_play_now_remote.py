#!/usr/bin/env python3
"""Preflight the fastest remote Doom play path without launching QEMU."""

from __future__ import annotations

import argparse
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
class PreflightReport:
    platform_name: str
    novnc_port: int
    required_tools: tuple[ToolStatus, ...]
    novnc: NovncStatus

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


def check_preflight(
    *,
    env: Mapping[str, str] | None = None,
    platform_name: str | None = None,
    which: Callable[[str], str | None] = shutil.which,
    path_is_dir: Callable[[Path], bool] = Path.is_dir,
) -> PreflightReport:
    """Return a preflight report or raise before any VM action is possible."""

    effective_env = os.environ if env is None else env
    effective_platform = platform.system() if platform_name is None else platform_name
    novnc_port = _validate_tcp_port(
        "NOVNC_PORT", effective_env.get("NOVNC_PORT", DEFAULT_NOVNC_PORT)
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

    web_root = next((root for root in NOVNC_WEB_ROOTS if path_is_dir(root)), None)
    return PreflightReport(
        platform_name=effective_platform,
        novnc_port=novnc_port,
        required_tools=required_tools,
        novnc=NovncStatus(websockify=which("websockify"), web_root=web_root),
    )


def render_report(report: PreflightReport) -> str:
    lines = [
        "play-now remote preflight OK",
        f"platform: {report.platform_name}",
        f"noVNC port: {report.novnc_port}",
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

    lines.append("dry-run: QEMU was not launched")
    lines.append("next: run ./tools/play_now_remote.sh on the remote host")
    return "\n".join(lines) + "\n"


def main(
    argv: list[str] | None = None,
    *,
    env: Mapping[str, str] | None = None,
    stdout: TextIO = sys.stdout,
    stderr: TextIO = sys.stderr,
    platform_name: str | None = None,
    which: Callable[[str], str | None] = shutil.which,
    path_is_dir: Callable[[Path], bool] = Path.is_dir,
) -> int:
    parser = argparse.ArgumentParser(
        description="Dry-run preflight for the remote vibe-os Doom play path."
    )
    parser.parse_args(argv)

    try:
        report = check_preflight(
            env=env,
            platform_name=platform_name,
            which=which,
            path_is_dir=path_is_dir,
        )
    except PreflightError as exc:
        print(f"play-now remote preflight failed: {exc}", file=stderr)
        print("dry-run: QEMU was not launched", file=stderr)
        return 1

    stdout.write(render_report(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
