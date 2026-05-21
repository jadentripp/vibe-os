#!/usr/bin/env python3
"""Check that the Doom port boundary stays explicit and source-preserving."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOOM_ROOT = ROOT / "third_party" / "doom"
DOOM_SRC = DOOM_ROOT / "linuxdoom-1.10"
MAKEFILE = ROOT / "Makefile"

ORIGINAL_PLATFORM_SOURCES = {
    "i_main.c": {
        "replacement": "doom_port/start.c",
        "boundary": "process entry and static argv handoff",
    },
    "i_system.c": {
        "replacement": "doom_port/platform.c",
        "boundary": "time, heap bootstrap, quit, error, and low-memory hooks",
    },
    "i_video.c": {
        "replacement": "doom_port/platform.c",
        "boundary": "palette, indexed framebuffer presentation, and screen reads",
    },
    "i_sound.c": {
        "replacement": "doom_port/platform.c + doom_port/music.c",
        "boundary": "sound/music lifecycle and host-independent audio queueing",
    },
    "i_net.c": {
        "replacement": "doom_port/platform.c",
        "boundary": "single-player net stubs and tic command dispatch",
    },
}

WRAPPED_ORIGINAL_SOURCES = {
    "g_game.c": {
        "cflags": ("DOOM_G_GAME_CFLAGS",),
        "reason": "save/load checkpoint wrappers call renamed original functions",
    },
    "p_saveg.c": {
        "cflags": ("DOOM_P_SAVEG_CFLAGS",),
        "reason": "save-stream diagnostics call renamed original archive functions",
    },
}

REQUIRED_PORT_SOURCES = {
    "doom_port/input.c",
    "doom_port/libc.c",
    "doom_port/music.c",
    "doom_port/platform.c",
    "doom_port/save_debug.c",
    "doom_port/start.c",
}

REUSABLE_LIBC_HOOKS = {
    "files": ("open", "read", "write", "close", "lseek", "access", "unlink"),
    "metadata": ("stat", "fstat", "mkdir", "vibe_listdir"),
    "stdio": ("fopen", "fread", "fwrite", "fseek", "fflush", "fclose"),
    "memory": ("malloc", "calloc", "realloc", "free", "mmap", "munmap"),
    "process": ("execv", "execve", "execl", "fork", "waitpid", "getpid"),
    "devices": ("ioctl", "clock_gettime", "vibe_clock_gettime"),
}

FORBIDDEN_VENDOR_TOKENS = ("VIBE_SYS_", "vibe_syscall", "vibe_os.h", "doom_port")


def fail(message: str) -> None:
    raise AssertionError(message)


def read_makefile() -> str:
    return MAKEFILE.read_text()


def make_var(name: str, text: str) -> str:
    match = re.search(rf"^{re.escape(name)}\s*:?=\s*(.+)$", text, re.MULTILINE)
    if not match:
        fail(f"missing Makefile variable {name}")
    return match.group(1).strip()


def git(args: list[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode:
        fail(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result.stdout


def c_sources() -> list[Path]:
    return sorted(DOOM_SRC.glob("*.c"))


def check_vendor_pristine() -> dict[str, object]:
    status = git(
        [
            "status",
            "--porcelain=v1",
            "--untracked-files=all",
            "--",
            "third_party/doom",
        ]
    )
    if status:
        fail("third_party/doom has worktree changes:\n" + status)

    tracked = [
        path
        for path in git(["ls-files", "--", "third_party/doom"]).splitlines()
        if path.strip()
    ]
    if not tracked:
        fail("third_party/doom has no tracked files")

    for path in DOOM_SRC.glob("*.[ch]"):
        text = path.read_text(errors="ignore")
        for token in FORBIDDEN_VENDOR_TOKENS:
            if token in text:
                fail(f"vendor source {path.relative_to(ROOT)} mentions {token}")

    return {
        "tracked_files": len(tracked),
        "status": "pristine",
        "source_policy": "no Vibe OS or doom_port tokens in original sources",
    }


def check_compile_boundary() -> dict[str, object]:
    makefile = read_makefile()
    original_sources = c_sources()
    expected_engine_sources = [
        path.name for path in original_sources if path.name not in ORIGINAL_PLATFORM_SOURCES
    ]
    port_sources = set(make_var("DOOM_PORT_SRCS", makefile).split())

    if "DOOM_SRC_DIR := third_party/doom/linuxdoom-1.10" not in makefile:
        fail("Makefile must build original Doom from third_party/doom/linuxdoom-1.10")
    if "$(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))" not in makefile:
        fail("Makefile must exclude original i_*.c platform files from original compile set")
    if not REQUIRED_PORT_SOURCES.issubset(port_sources):
        missing = sorted(REQUIRED_PORT_SOURCES - port_sources)
        fail(f"missing port sources in DOOM_PORT_SRCS: {', '.join(missing)}")
    for source in port_sources:
        if not source.startswith("doom_port/") or "third_party/doom" in source:
            fail(f"port source escapes doom_port boundary: {source}")
        if not (ROOT / source).exists():
            fail(f"port source is listed but missing: {source}")

    for source, meta in WRAPPED_ORIGINAL_SOURCES.items():
        if source not in expected_engine_sources:
            fail(f"wrapped original source is not in compile set: {source}")
        for flag_var in meta["cflags"]:
            if flag_var not in makefile:
                fail(f"{source} wrapper flag variable is missing: {flag_var}")

    return {
        "original_c_sources": len(original_sources),
        "compile_unchanged_sources": len(expected_engine_sources),
        "excluded_platform_sources": sorted(ORIGINAL_PLATFORM_SOURCES),
        "wrapped_original_sources": WRAPPED_ORIGINAL_SOURCES,
        "port_sources": sorted(port_sources),
    }


def check_replacement_symbols() -> dict[str, object]:
    platform = (ROOT / "doom_port" / "platform.c").read_text()
    start = (ROOT / "doom_port" / "start.c").read_text()
    save_debug = (ROOT / "doom_port" / "save_debug.c").read_text()

    expected = {
        "entry": ("void start(void)", "D_DoomMain();"),
        "system": (
            "void I_Init(void)",
            "byte* I_ZoneBase(int* size)",
            "int I_GetTime(void)",
            "void I_Quit(void)",
            "void I_Error(char* error, ...)",
        ),
        "video": (
            "void I_InitGraphics(void)",
            "void I_SetPalette(byte* palette)",
            "void I_FinishUpdate(void)",
            "void I_ReadScreen(byte* scr)",
        ),
        "sound": (
            "void I_InitSound(void)",
            "int I_StartSound(int id, int vol, int sep, int pitch, int priority)",
            "int I_RegisterSong(void* data)",
            "void I_PlaySong(int handle, int looping)",
        ),
        "network": ("void I_InitNetwork(void)", "void I_NetCmd(void)"),
        "wrapped_game": (
            "void doom_original_G_BuildTiccmd(ticcmd_t* cmd);",
            "void doom_original_G_Ticker(void);",
            "void G_BuildTiccmd(ticcmd_t* cmd)",
            "void G_Ticker(void)",
        ),
        "wrapped_save": (
            "void doom_original_P_ArchivePlayers(void);",
            "void P_ArchivePlayers(void)",
            "void P_UnArchiveThinkers(void)",
        ),
    }

    haystacks = {
        "entry": start,
        "system": platform,
        "video": platform,
        "sound": platform,
        "network": platform,
        "wrapped_game": platform,
        "wrapped_save": save_debug,
    }
    for category, tokens in expected.items():
        text = haystacks[category]
        for token in tokens:
            if token not in text:
                fail(f"missing {category} replacement token: {token}")

    return {
        name: {
            "replacement": meta["replacement"],
            "boundary": meta["boundary"],
        }
        for name, meta in sorted(ORIGINAL_PLATFORM_SOURCES.items())
    }


def check_reusable_libc_hooks() -> dict[str, object]:
    libc = (ROOT / "doom_port" / "libc.c").read_text()
    headers = "\n".join(
        path.read_text(errors="ignore")
        for path in (ROOT / "doom_port" / "include").glob("**/*.h")
    )
    combined = libc + "\n" + headers
    found: dict[str, list[str]] = {}
    for category, hooks in REUSABLE_LIBC_HOOKS.items():
        found[category] = []
        for hook in hooks:
            if re.search(rf"\b{re.escape(hook)}\s*\(", combined):
                found[category].append(hook)
            else:
                fail(f"missing reusable libc/platform hook: {hook}")
    return found


def build_report() -> dict[str, object]:
    return {
        "vendor": check_vendor_pristine(),
        "compile_boundary": check_compile_boundary(),
        "replacement_boundary": check_replacement_symbols(),
        "reusable_libc_hooks": check_reusable_libc_hooks(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    args = parser.parse_args()

    try:
        report = build_report()
    except AssertionError as exc:
        print(f"doom portability boundary check failed: {exc}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
    else:
        boundary = report["compile_boundary"]
        print("Doom portability boundary OK")
        print(f"- vendor tree: {report['vendor']['status']}")
        print(f"- original C sources: {boundary['original_c_sources']}")
        print(f"- compile unchanged: {boundary['compile_unchanged_sources']}")
        print(
            "- replaced platform sources: "
            + ", ".join(boundary["excluded_platform_sources"])
        )
        print(
            "- reusable hook groups: "
            + ", ".join(sorted(report["reusable_libc_hooks"]))
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
