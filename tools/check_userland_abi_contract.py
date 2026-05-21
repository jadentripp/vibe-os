#!/usr/bin/env python3
"""Host-only checks for the public userland/game ABI contract."""

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]


def read_text(relative_path):
    return (ROOT / relative_path).read_text()


def require_tokens(failures, relative_path, tokens, category=None):
    text = read_text(relative_path)
    prefix = f"{category}: " if category else ""
    for token in tokens:
        if token not in text:
            failures.append(f"{prefix}{relative_path}: missing {token!r}")


def reject_tokens(failures, relative_path, tokens):
    text = read_text(relative_path)
    for token in tokens:
        if token in text:
            failures.append(f"{relative_path}: rejected stale wording {token!r}")


ABI_REQUIREMENTS = {
    "clock": {
        "doom_port/include/vibe_os.h": (
            "VIBE_SYS_CLOCK_GETTIME",
            "VIBE_CLOCK_MONOTONIC",
            "vibe_clock_time_t",
            "vibe_clock_gettime",
            "vibe_clock_monotonic",
            "vibe_monotonic_milliseconds",
        ),
        "doom_port/include/time.h": (
            "CLOCK_MONOTONIC",
            "int clock_gettime(clockid_t clock_id, struct timespec* tp);",
        ),
        "doom_port/libc.c": (
            "int vibe_clock_gettime(unsigned long clock_id, vibe_clock_time_t* out)",
            "int clock_gettime(clockid_t clock_id, struct timespec* tp)",
        ),
        "docs/clock-time.md": (
            "The reusable user/kernel contract is `VIBE_SYS_CLOCK_GETTIME`",
            "new consumers should use the monotonic clock API",
        ),
    },
    "input": {
        "doom_port/include/vibe_os.h": (
            "VIBE_SYS_POLL_INPUT",
            "VIBE_SYS_INPUT_STATUS",
            "vibe_input_event_t",
            "vibe_input_status_t",
            "vibe_poll_input",
            "vibe_drain_input",
            "vibe_input_status",
        ),
        "doom_port/libc.c": (
            "int vibe_poll_input(vibe_input_event_t* event)",
            "int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events)",
            "int vibe_input_status(vibe_input_status_t* status)",
        ),
        "docs/input.md": (
            "Generic ABI:",
            "the queue contract is\n  not Doom-specific",
            "future games can construct or replay typed events",
        ),
    },
    "framebuffer": {
        "doom_port/include/vibe_os.h": (
            "VIBE_IOCTL_FBINFO",
            "VIBE_IOCTL_PRESENT_INDEXED",
            "vibe_fb_info_t",
            "vibe_present_indexed_t",
            "vibe_fb_get_info",
            "vibe_present_indexed_checked",
        ),
        "doom_port/libc.c": (
            "int vibe_fb_get_info(vibe_fb_info_t* info)",
            "int vibe_present_indexed_checked(const vibe_present_indexed_t* present)",
        ),
        "docs/graphics.md": (
            "The framebuffer contract is intentionally split into three reusable layers",
            "stable and generic enough for future indexed\ngames",
        ),
    },
    "audio": {
        "doom_port/include/vibe_os.h": (
            "VIBE_SYS_AUDIO",
            "VIBE_AUDIO_DEVICE_INFO",
            "VIBE_AUDIO_PCM_RING_INFO",
            "vibe_audio_voice_desc_t",
            "vibe_audio_device_info_t",
            "vibe_audio_pcm_ring_info_t",
            "vibe_audio_voice_desc_init",
        ),
        "docs/audio.md": (
            "Reusable audio syscall surface:",
            "Doom is the first\n  high-pressure caller",
            "reusable contract:",
            "without Doom fields or WAD assumptions",
        ),
    },
    "files": {
        "doom_port/include/vibe_os.h": (
            "VIBE_SYS_OPEN",
            "VIBE_SYS_READ",
            "VIBE_SYS_WRITE",
            "VIBE_SYS_LSEEK",
            "VIBE_SYS_CLOSE",
            "VIBE_SYS_UNLINK",
            "VIBE_SYS_STAT",
            "VIBE_SYS_FSTAT",
            "VIBE_SYS_FTRUNCATE",
            "VIBE_SYS_LISTDIR",
            "vibe_dirent_t",
            "vibe_listdir",
            "vibe_file_size",
            "vibe_file_read_all",
        ),
        "doom_port/libc.c": (
            "int open(const char* path, int flags, ...)",
            "ssize_t read(int fd, void* buffer, size_t count)",
            "ssize_t write(int fd, const void* buffer, size_t count)",
            "int ftruncate(int fd, off_t length)",
            "int vibe_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries)",
            "int vibe_file_read_all(const char* path, void* buffer, unsigned long capacity, unsigned long* out_size)",
        ),
        "docs/doom-libc-runtime.md": (
            "Generic file consumers",
            "`vibe_file_size` and `vibe_file_read_all`",
            "`vibe_listdir`",
        ),
    },
    "process": {
        "doom_port/include/vibe_os.h": (
            "VIBE_SYS_EXEC",
            "VIBE_SYS_FORK",
            "VIBE_SYS_WAITPID",
            "VIBE_SYS_GETPID",
            "VIBE_EXEC_PATH_MAX",
            "VIBE_EXEC_ARG_MAX",
            "VIBE_EXEC_ARG_STR_MAX",
        ),
        "doom_port/include/unistd.h": (
            "int execv(const char* path, char* const argv[]);",
            "int execve(const char* path, char* const argv[], char* const envp[]);",
            "pid_t fork(void);",
            "pid_t getpid(void);",
        ),
        "doom_port/include/sys/wait.h": (
            "pid_t waitpid(pid_t pid, int* status, int options);",
        ),
        "doom_port/libc.c": (
            "int execv(const char* path, char* const argv[])",
            "int execve(const char* path, char* const argv[], char* const envp[])",
            "pid_t getpid(void)",
            "pid_t fork(void)",
            "pid_t waitpid(pid_t pid, int* status, int options)",
        ),
        "docs/process-exec.md": (
            "## Second Freestanding Program Contract",
            "A second freestanding C program uses the same launch ABI as the probe and Doom.",
            "`execv(\"HELLO.ELF\", argv)`",
            "PID-preserving address-space overlay",
        ),
    },
}


GENERIC_DOC_REQUIREMENTS = {
    "docs/doom-libc-runtime.md": (
        "## General-Purpose ABI Audit",
        "A second freestanding C program does not need to include Doom headers",
        "The reusable surface today is:",
        "The ABI is reusable, but not POSIX-complete.",
    ),
    "docs/process-exec.md": (
        "The in-tree image builder still places only",
        "kernel change is required for another root-level 8.3 `.ELF` name",
        "The generic pool is reusable, but it is still small and static.",
    ),
}


STALE_DOC_WORDING = {
    "docs/doom-libc-runtime.md": (
        "the current exec handoff still resets the global fd table",
    ),
}


def main():
    failures = []
    for category, files in ABI_REQUIREMENTS.items():
        for relative_path, tokens in files.items():
            require_tokens(failures, relative_path, tokens, category=category)

    for relative_path, tokens in GENERIC_DOC_REQUIREMENTS.items():
        require_tokens(failures, relative_path, tokens)

    for relative_path, tokens in STALE_DOC_WORDING.items():
        reject_tokens(failures, relative_path, tokens)

    if failures:
        print("Userland ABI contract check failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print("Userland ABI contract OK: generic clock/input/framebuffer/audio/file/process surface is documented.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
