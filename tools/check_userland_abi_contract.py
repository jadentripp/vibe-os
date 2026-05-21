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
        "docs/architecture.md": (
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
        "docs/architecture.md": (
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
        "docs/architecture.md": (
            "The framebuffer contract is intentionally split into three reusable layers",
            "stable and generic enough for future indexed\ngames",
        ),
    },
    "audio": {
        "doom_port/include/vibe_os.h": (
            "VIBE_SYS_AUDIO",
            "VIBE_AUDIO_DEVICE_INFO",
            "VIBE_AUDIO_PCM_RING_INFO",
            "VIBE_AUDIO_STREAM_INFO",
            "vibe_audio_voice_desc_t",
            "vibe_audio_device_info_t",
            "vibe_audio_pcm_ring_info_t",
            "vibe_audio_stream_info_t",
            "vibe_audio_voice_desc_init",
            "vibe_audio_device_start",
            "vibe_audio_mixer_start",
            "vibe_audio_stream_info",
        ),
        "doom_port/libc.c": (
            "int vibe_audio_device_start(void)",
            "int vibe_audio_mixer_start(unsigned long handle, const vibe_audio_voice_desc_t* desc)",
            "int vibe_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info)",
        ),
        "docs/architecture.md": (
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
            "VIBE_SYS_DUP",
            "VIBE_SYS_DUP2",
            "VIBE_SYS_DUP3",
            "VIBE_SYS_FCNTL",
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
            "int dup(int oldfd)",
            "int dup2(int oldfd, int newfd)",
            "int dup3(int oldfd, int newfd, int flags)",
            "int fcntl(int fd, int cmd, ...)",
            "int vibe_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries)",
            "int vibe_file_read_all(const char* path, void* buffer, unsigned long capacity, unsigned long* out_size)",
        ),
        "docs/architecture.md": (
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
            "VIBE_SYS_FCNTL",
            "VIBE_EXEC_PATH_MAX",
            "VIBE_EXEC_ARG_MAX",
            "VIBE_EXEC_ARG_STR_MAX",
        ),
        "doom_port/include/unistd.h": (
            "int execv(const char* path, char* const argv[]);",
            "int execve(const char* path, char* const argv[], char* const envp[]);",
            "pid_t fork(void);",
            "pid_t getpid(void);",
            "int dup(int oldfd);",
            "int dup2(int oldfd, int newfd);",
            "int dup3(int oldfd, int newfd, int flags);",
        ),
        "doom_port/include/fcntl.h": (
            "#define F_GETFD 1",
            "#define F_SETFD 2",
            "#define FD_CLOEXEC 1",
            "int fcntl(int fd, int cmd, ...);",
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
        "docs/architecture.md": (
            "## Second Freestanding Program Contract",
            "`user/abi_probe.c` is the in-tree second program proof.",
            "`build/abi_probe.elf` and packages it as root `ABIPROBE.ELF`",
            "`execv(\"ABIPROBE.ELF\", argv)`",
            "`ABIPROBE.ELF` records its success and then execs `DOOM.ELF`",
            "PID-preserving address-space overlay",
        ),
        "user/abi_probe.c": (
            "int user_main(int argc, char** argv, char** envp)",
            "ABI_PROBE_MAGIC",
            '#include "runtime.h"',
            'vibe_user_streq(argv[0], "ABIPROBE.ELF")',
            "vibe_user_getpid()",
            "vibe_user_clock_monotonic(&now)",
            "vibe_user_listdir(\"/\", root_entries, 16)",
            "vibe_user_fcntl(wad, ABI_PROBE_F_SETFD, ABI_PROBE_FD_CLOEXEC)",
            "vibe_user_report_probe(ABI_PROBE_MAGIC, flags)",
            "vibe_user_execv(doom_path, doom_argv)",
            'const char doom_path[] = "DOOM.ELF";',
        ),
        "user/runtime.h": (
            "int vibe_user_syscall3(",
            "int vibe_user_syscall_errno(",
            "int vibe_user_sbrk(long increment, void** previous_break);",
            "int vibe_user_open(const char* path, unsigned long flags, unsigned long mode);",
            "int vibe_user_close(int fd);",
            "int vibe_user_getpid(void);",
            "int vibe_user_fork(void);",
            "int vibe_user_waitpid(long pid, int* status, unsigned long options);",
            "int vibe_user_dup(int oldfd);",
            "int vibe_user_dup2(int oldfd, int newfd);",
            "int vibe_user_dup3(int oldfd, int newfd, unsigned long flags);",
            "int vibe_user_fcntl(int fd, int cmd, unsigned long arg);",
            "int vibe_user_mmap(void** out, unsigned long length, unsigned long prot, unsigned long flags);",
            "int vibe_user_mmap_anon(void** out, unsigned long length, unsigned long prot);",
            "int vibe_user_munmap(void* addr, unsigned long length);",
            "unsigned long vibe_user_heap_capabilities(void);",
            "unsigned long vibe_user_vm_capabilities(void);",
            "int vibe_user_clock_monotonic(",
            "int vibe_user_listdir(",
            "int vibe_user_execv(",
            "void vibe_user_report_probe(",
        ),
        "user/runtime.c": (
            "int $0x80",
            "VIBE_SYS_USER_PROBE",
            "VIBE_SYS_SBRK",
            "VIBE_SYS_FORK",
            "VIBE_SYS_WAITPID",
            "VIBE_SYS_MMAP",
            "VIBE_SYS_MUNMAP",
            "VIBE_SYS_GETPID",
            "VIBE_SYS_DUP",
            "VIBE_SYS_DUP2",
            "VIBE_SYS_DUP3",
            "VIBE_SYS_FCNTL",
            "VIBE_SYS_EXEC",
            "VIBE_SYS_CLOCK_GETTIME",
            "VIBE_SYS_LISTDIR",
        ),
        "Makefile": (
            "USER_ABI_PROBE_C_SRC := user/abi_probe.c",
            "USER_RUNTIME_C_SRC := user/runtime.c",
            "USER_ABI_PROBE_ELF := $(BUILD_DIR)/abi_probe.elf",
            "--root-elf ABIPROBE.ELF=$(USER_ABI_PROBE_ELF)",
        ),
        "tools/make_wad_image.py": (
            "--root-elf",
            "parse_root_elf_arg",
            "root83_from_display_name",
        ),
    },
}


GENERIC_DOC_REQUIREMENTS = {
    "docs/architecture.md": (
        "## General-Purpose ABI Audit",
        "A second freestanding C program does not need to include Doom headers",
        "The reusable surface today is:",
        "The ABI is reusable, but not POSIX-complete.",
        "## General-OS Gap Contract",
    ),
    "docs/architecture.md": (
        "`--root-elf NAME.ELF=PATH` packages additional checked or generated",
        "root-level 8.3 `.ELF` images without changing the boot path",
        "The generic pool is reusable, but it is still small and static.",
        "## Small User Runtime",
        "perform brk-style heap grows/shrinks",
        "anonymous/private mmap/munmap",
        "classified fork",
        "waitpid",
        "## POSIX Gap Decomposition",
    ),
}


POSIX_GAP_REQUIREMENTS = {
    "fork": {
        "docs/architecture.md": (
            "`fork` exists only as a classified syscall/libc surface.",
            "no child address-space clone",
            "no child address-space clone, copy-on-\n  write state",
        ),
        "docs/architecture.md": (
            "`SYS_FORK` is wired through the syscall table and returns `-ENOSYS`",
            "Address-space cloning, copy-on-write or eager page copies",
        ),
        "doom_port/libc.c": (
            "pid_t fork(void)",
            "vibe_syscall3(VIBE_SYS_FORK, 0, 0, 0)",
            "syscall_failed(raw, ENOSYS)",
        ),
        "user/probe.c": (
            "syscall3(SYS_FORK, 0, 0, 0) == -ERRNO_ENOSYS",
        ),
    },
    "fd-duplication": {
        "docs/architecture.md": (
            "Descriptor lifetime and fd duplication now have a bounded Unix-open-file-description milestone.",
            "shared root slot with a refcounted offset/status record",
            "`dup`, `dup2`, and\n  `dup3` are public syscall/libc surfaces",
            "`fcntl(F_GETFD/F_SETFD)` is the\n  descriptor-flag milestone",
            "There is still no fork-time fd\n  table cloning contract",
        ),
        "docs/architecture.md": (
            "fd duplication",
            "Public `dup`, `dup2`, and `dup3` syscalls/libc wrappers",
            "`fcntl(F_GETFD/F_SETFD)`",
            "Fork-time descriptor table cloning",
        ),
        "doom_port/libc.c": (
            "int dup(int oldfd)",
            "int dup2(int oldfd, int newfd)",
            "int dup3(int oldfd, int newfd, int flags)",
            "int fcntl(int fd, int cmd, ...)",
            "vibe_syscall3(VIBE_SYS_DUP",
            "vibe_syscall3(VIBE_SYS_DUP2",
            "vibe_syscall3(VIBE_SYS_DUP3",
            "vibe_syscall3(VIBE_SYS_FCNTL",
        ),
        "user/probe.c": (
            "PROBE_FLAG_DUP = 0x20000u",
            "PROBE_FLAG_FCNTL = 0x40000u",
            "sys_dup(defaults)",
            "sys_dup2(dup_fd, DUP2_TARGET_FD) == DUP2_TARGET_FD",
            "sys_dup3(defaults, DUP3_TARGET_FD, O_CLOEXEC) == DUP3_TARGET_FD",
            "sys_fcntl(defaults, F_SETFD, FD_CLOEXEC) == 0",
            "flags |= PROBE_FLAG_FCNTL;",
        ),
    },
    "file-backed-mmap": {
        "docs/architecture.md": (
            "VM allocation is anonymous/private and brk-backed.",
            "`MAP_FIXED`, `MAP_SHARED`, and file-backed mappings are rejected",
        ),
        "docs/architecture.md": (
            "file-backed `mmap`",
            "File-backed mappings, `MAP_SHARED`, `MAP_FIXED`",
            "reusable VM object lifetime",
        ),
        "doom_port/libc.c": (
            "if (!(flags & MAP_ANONYMOUS) || fd != -1 || !(flags & MAP_PRIVATE) || (flags & MAP_SHARED))",
            "errno = ENOSYS;",
        ),
        "user/probe.c": (
            "syscall3(SYS_MMAP, 0, 4096, mmap_fixed_flags) == -ERRNO_EINVAL",
        ),
    },
    "signals": {
        "docs/architecture.md": (
            "POSIX signal delivery is absent.",
            "there is no public `signal.h`, signal\n  mask, `kill`, interval timer signal, or handler trampoline ABI",
        ),
        "docs/architecture.md": (
            "signals",
            "`signal`, `sigaction`, `kill`, signal masks",
            "delivery across scheduler context switches",
        ),
    },
    "terminal-tty": {
        "docs/architecture.md": (
            "Terminal/tty behavior is absent.",
            "unknown display ioctls return\n  `ENOTTY`",
            "there is no stdin/stdout tty device, `termios`, `isatty`",
        ),
        "docs/architecture.md": (
            "terminal/tty",
            "classified as `ENOTTY`",
            "`termios`, `isatty`, controlling terminals",
        ),
        "doom_port/libc.c": (
            "int ioctl(int fd, unsigned long request, void* arg)",
            "syscall_failed(raw, ENOTTY)",
        ),
    },
    "dynamic-process-lifetimes": {
        "docs/architecture.md": (
            "Dynamic process lifetimes are bounded.",
            "no dynamically\n  growing process table",
            "or\n  unbounded child lifecycle manager",
        ),
        "docs/architecture.md": (
            "dynamic process lifetimes",
            "two-entry static probe-class pool",
            "Dynamically allocated process records, unbounded child slots",
        ),
    },
}


STALE_DOC_WORDING = {
    "docs/architecture.md": (
        "the current exec handoff still resets the global fd table",
    ),
}


ABSENT_PUBLIC_POSIX_SURFACE = {
    "doom_port/include/vibe_os.h": (
        "VIBE_SYS_SIGNAL",
        "VIBE_SYS_SIGACTION",
        "VIBE_SYS_KILL",
        "VIBE_SYS_TTY",
    ),
    "doom_port/include/unistd.h": (
        "int isatty(",
    ),
    "doom_port/libc.c": (
        "int isatty(",
    ),
}


def main():
    failures = []
    for category, files in ABI_REQUIREMENTS.items():
        for relative_path, tokens in files.items():
            require_tokens(failures, relative_path, tokens, category=category)

    for relative_path, tokens in GENERIC_DOC_REQUIREMENTS.items():
        require_tokens(failures, relative_path, tokens)

    for category, files in POSIX_GAP_REQUIREMENTS.items():
        for relative_path, tokens in files.items():
            require_tokens(failures, relative_path, tokens, category=category)

    for relative_path, tokens in STALE_DOC_WORDING.items():
        reject_tokens(failures, relative_path, tokens)

    for relative_path, tokens in ABSENT_PUBLIC_POSIX_SURFACE.items():
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
