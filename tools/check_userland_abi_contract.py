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
        "docs/architecture.txt": (
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
            "vibe_input_status_uses_drop_oldest",
            "vibe_input_status_keyboard_is_ready",
            "vibe_input_status_mouse_is_ready",
        ),
        "doom_port/libc.c": (
            "int vibe_poll_input(vibe_input_event_t* event)",
            "int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events)",
            "int vibe_input_status(vibe_input_status_t* status)",
        ),
        "docs/architecture.txt": (
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
        "user/runtime.h": (
            "VIBE_USER_SYS_DISPLAY_IOCTL",
            "vibe_user_fb_get_info",
            "vibe_user_fb_can_present_indexed",
            "vibe_user_present_indexed_checked",
        ),
        "user/abi_probe.c": (
            "ABI_PROBE_FLAG_FRAMEBUFFER",
            "prove_framebuffer_device",
            "vibe_user_present_indexed_checked(&present)",
        ),
        "doom_port/libc.c": (
            "int vibe_fb_get_info(vibe_fb_info_t* info)",
            "int vibe_present_indexed_checked(const vibe_present_indexed_t* present)",
        ),
        "docs/architecture.txt": (
            "The framebuffer contract is intentionally split into three reusable layers",
            "stable and generic enough for future indexed\ngames",
            "ABI probe is now a second non-Doom framebuffer consumer",
        ),
    },
    "audio": {
        "doom_port/include/vibe_os.h": (
            "VIBE_SYS_AUDIO",
            "VIBE_AUDIO_DEVICE_INFO",
            "VIBE_AUDIO_PCM_RING_INFO",
            "VIBE_AUDIO_STREAM_INFO",
            "VIBE_AUDIO_STREAM_WRITE",
            "vibe_audio_voice_desc_t",
            "vibe_audio_device_info_t",
            "vibe_audio_pcm_ring_info_t",
            "vibe_audio_stream_info_t",
            "vibe_audio_voice_desc_init",
            "vibe_audio_device_start",
            "vibe_audio_mixer_start",
            "vibe_audio_stream_info",
            "vibe_audio_stream_write",
        ),
        "doom_port/libc.c": (
            "int vibe_audio_device_start(void)",
            "int vibe_audio_mixer_start(unsigned long handle, const vibe_audio_voice_desc_t* desc)",
            "int vibe_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info)",
            "int vibe_audio_stream_write(unsigned long handle, const vibe_audio_voice_desc_t* desc)",
        ),
        "user/runtime.h": (
            "static inline int vibe_user_audio_device_start(void)",
            "static inline int vibe_user_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info)",
            "static inline int vibe_user_audio_pcm_write(",
            "static inline int vibe_user_audio_stream_write(",
        ),
        "docs/architecture.txt": (
            "Reusable audio syscall surface:",
            "Doom is the first\n  high-pressure caller",
            "reusable contract:",
            "without Doom fields or WAD assumptions",
            "kernel-owned PCM stream write/refill ABI",
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
        "docs/architecture.txt": (
            "Generic file consumers",
            "`vibe_file_size` and `vibe_file_read_all`",
            "`vibe_listdir`",
        ),
    },
    "process": {
        "doom_port/include/vibe_os.h": (
            "VIBE_OS_ABI_VERSION = 1",
            "VIBE_SYSCALL_VECTOR = 0x80",
            "VIBE_SYSCALL_MAX_ARGS = 3",
            "VIBE_SYSCALL_ERROR_NEGATIVE_ERRNO = 1",
            "VIBE_PROCESS_FAULT_EXIT_STATUS_BASE = 0x80",
            "VIBE_SYS_EXEC",
            "VIBE_SYS_FORK",
            "VIBE_SYS_WAITPID",
            "VIBE_SYS_GETPID",
            "VIBE_SYS_FCNTL",
            "VIBE_SYS_PROCESS_STATUS",
            "VIBE_SYS_YIELD",
            "VIBE_SYS_SLEEP_TICKS",
            "VIBE_PROCESS_STATUS_ABI_VERSION",
            "vibe_process_status_t",
            "VIBE_EXEC_PATH_MAX",
            "VIBE_EXEC_ARG_MAX",
            "VIBE_EXEC_ARG_STR_MAX",
            "VIBE_EXEC_STACK_ABI_VERSION = 1",
            "VIBE_EXEC_STACK_ALIGN = 16",
            "VIBE_EXEC_AUX_AT_PAGESZ = 6",
            "VIBE_EXEC_AUX_AT_ENTRY = 9",
            "VIBE_EXEC_AUXV_PAIR_COUNT = 3",
            "VIBE_EXEC_RESOLVE_GENERIC_ROOT83",
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
        "docs/architecture.txt": (
            "## Second Freestanding Program Contract",
            "`user/abi_probe.c` is the in-tree second program proof.",
            "`build/abi_probe.elf` and packages it as root `ABIPROBE.ELF`",
            "`execve(\"ABIPROBE.ELF\", argv, envp)`",
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
            "ABI_PROBE_FLAG_PROCESS",
            "prove_process_services(pid)",
            "vibe_user_process_status_current(&status)",
            "vibe_user_yield() != 0",
            "vibe_user_sleep_ticks(1) != 0",
            'vibe_user_streq(envp[0], "PROBE_LAUNCHER=USERPROB")',
            'vibe_user_streq(envp[1], "ABI_ENV=present")',
            'vibe_user_execve("", doom_argv, envp) != -22',
            'vibe_user_execve(missing_path, doom_argv, envp) != -ABI_PROBE_ERRNO_ENOENT',
            "vibe_user_report_probe(ABI_PROBE_MAGIC, flags)",
            "vibe_user_execv(doom_path, doom_argv)",
            'const char doom_path[] = "DOOM.ELF";',
            'const char missing_path[] = "NOPE.ELF";',
        ),
        "user/runtime.h": (
            "int vibe_user_syscall3(",
            "int vibe_user_syscall_errno(",
            "static inline int vibe_user_result_is_error(",
            "static inline int vibe_user_result_errno(",
            "int vibe_user_sbrk(long increment, void** previous_break);",
            "int vibe_user_open(const char* path, unsigned long flags, unsigned long mode);",
            "int vibe_user_close(int fd);",
            "int vibe_user_getpid(void);",
            "int vibe_user_fork(void);",
            "int vibe_user_waitpid(long pid, int* status, unsigned long options);",
            "int vibe_user_waitpid_nohang_reap(long pid, int* status, unsigned long max_polls);",
            "int vibe_user_waitpid_nohang_reap_exact(long pid, int* status, unsigned long max_polls)",
            "int vibe_user_dup(int oldfd);",
            "int vibe_user_dup2(int oldfd, int newfd);",
            "int vibe_user_dup3(int oldfd, int newfd, unsigned long flags);",
            "int vibe_user_fcntl(int fd, int cmd, unsigned long arg);",
            "int vibe_user_process_status(long pid, vibe_process_status_t* out);",
            "int vibe_user_process_status_current(vibe_process_status_t* out);",
            "int vibe_user_yield(void);",
            "int vibe_user_sleep_ticks(unsigned long ticks);",
            "int vibe_user_sleep_milliseconds(unsigned long milliseconds);",
            "int vibe_user_get_cloexec(int fd, int* out)",
            "int vibe_user_set_cloexec(int fd, int enabled)",
            "int vibe_user_mmap(void** out, unsigned long length, unsigned long prot, unsigned long flags);",
            "int vibe_user_mmap_anon(void** out, unsigned long length, unsigned long prot);",
            "VIBE_USER_VM_CAP_FILE_PRIVATE_COPY",
            "int vibe_user_mmap_file(",
            "int vibe_user_mmap_file_private(void** out, unsigned long length, unsigned long prot, int fd, long offset);",
            "int vibe_user_munmap(void* addr, unsigned long length);",
            "unsigned long vibe_user_heap_capabilities(void);",
            "unsigned long vibe_user_vm_capabilities(void);",
            "int vibe_user_clock_monotonic(",
            "int vibe_user_listdir(",
            "int vibe_user_dirent_name_eq(",
            "int vibe_user_listdir_find(",
            "int vibe_user_validate_exec_argv(",
            "int vibe_user_validate_exec_envp(",
            "int vibe_user_execv(",
            "int vibe_user_execv_checked(",
            "int vibe_user_execve_checked(",
            "int vibe_user_execve(",
            "void vibe_user_report_probe(",
        ),
        "user/runtime.c": (
            "int $0x80",
            "vibe_user_result_errno(raw_result, fallback_errno)",
            "VIBE_SYS_USER_PROBE",
            "VIBE_SYS_SBRK",
            "VIBE_SYS_FORK",
            "VIBE_SYS_WAITPID",
            "vibe_user_waitpid_nohang_reap",
            "VIBE_SYS_MMAP",
            "VIBE_SYS_MUNMAP",
            "VIBE_SYS_GETPID",
            "VIBE_SYS_DUP",
            "VIBE_SYS_DUP2",
            "VIBE_SYS_DUP3",
            "VIBE_SYS_FCNTL",
            "VIBE_SYS_PROCESS_STATUS",
            "VIBE_SYS_YIELD",
            "VIBE_SYS_SLEEP_TICKS",
            "vibe_user_process_status",
            "vibe_user_sleep_ticks",
            "vibe_user_mmap_file",
            "vibe_user_pread",
            "VIBE_SYS_EXEC",
            "vibe_user_syscall3(VIBE_SYS_EXEC, (unsigned long)path, (unsigned long)argv, 0)",
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
    "trap-hardening": {
        "kernel/kernel.asm": (
            "VIBE_USER_ABI_VERSION equ 1",
            "SYSCALL_TRAP_VECTOR equ 0x80",
            "SYSCALL_MAX_ARGS equ 3",
            "SYSCALL_RESULT_NEGATIVE_ERRNO equ 1",
            "SYSCALL_SAVED_REG_MASK equ 0x0000003f",
            "SYSCALL_FRAME_BYTES equ 44",
            "SYS_EXEC_STACK_ABI_VERSION equ 1",
            "SYS_EXEC_STACK_ALIGN equ 16",
            "inc dword [syscall_trap_entry_count]",
            "mov dword [syscall_abi_version_seen], VIBE_USER_ABI_VERSION",
            "mov dword [syscall_saved_reg_mask_seen], SYSCALL_SAVED_REG_MASK",
            "mov dword [syscall_frame_bytes_seen], SYSCALL_FRAME_BYTES",
            "sys_exec_last_stack_abi dd 0",
            "sys_exec_last_stack_align dd 0",
            "sys_exec_last_auxv_pairs dd 0",
            "process_exit_last_pid dd 0xffffffff",
            "process_fault_last_status dd 0",
            "SYSCALL_RETURN_EFLAGS_SET equ 0x00000202",
            "SYSCALL_RETURN_EFLAGS_KEEP_MASK equ 0xfff88aff",
            "SYSCALL_SANITIZE_EFLAGS_OFFSET equ 8 + SYSCALL_FRAME_EFLAGS",
            "call syscall_sanitize_return_frame",
            "syscall_return_eflags_last_before dd 0",
            "syscall_return_eflags_last_after dd 0",
            "syscall_return_eflags_sanitize_count dd 0",
        ),
        "user/crt0.asm": (
            "global __vibe_syscall0",
            "global __vibe_syscall1",
            "global __vibe_syscall2",
            "global __vibe_syscall3",
            "VIBE_USER_ABI_VERSION equ 1",
            "VIBE_USER_STACK_ABI_VERSION equ 1",
            "SYSCALL_TRAP_VECTOR equ 0x80",
            "SYSCALL_MAX_ARGS equ 3",
            "__vibe_syscall0:",
            "__vibe_syscall1:",
            "__vibe_syscall2:",
            "__vibe_syscall3:",
            "int 0x80",
            "cld",
            "pop ebx",
        ),
        "user/runtime.c": (
            "__vibe_syscall0(number)",
            "__vibe_syscall1(number, arg0)",
            "__vibe_syscall2(number, arg0, arg1)",
            "__vibe_syscall3(number, arg0, arg1, arg2)",
        ),
    },
    "libc-runtime": {
        "doom_port/include/stdlib.h": (
            "long strtol(const char* text, char** endptr, int base);",
            "unsigned long strtoul(const char* text, char** endptr, int base);",
            "double strtod(const char* text, char** endptr);",
            "double atof(const char* text);",
            "int rand(void);",
            "void srand(unsigned int seed);",
        ),
        "doom_port/include/string.h": (
            "char* strerror(int error);",
        ),
        "doom_port/include/stdio.h": (
            "int fgetc(FILE* stream);",
            "int ungetc(int ch, FILE* stream);",
            "char* fgets(char* buffer, int size, FILE* stream);",
            "int fputc(int ch, FILE* stream);",
            "int fputs(const char* text, FILE* stream);",
            "int puts(const char* text);",
            "void rewind(FILE* stream);",
            "void perror(const char* text);",
        ),
        "doom_port/include/time.h": (
            "#define CLOCKS_PER_SEC 1000L",
            "clock_t clock(void);",
            "time_t time(time_t* out);",
        ),
        "doom_port/libc.c": (
            "long strtol(const char* text, char** endptr, int base)",
            "unsigned long strtoul(const char* text, char** endptr, int base)",
            "double strtod(const char* text, char** endptr)",
            "double atof(const char* text)",
            "char* strerror(int error)",
            "scan_text_read_number",
            "scan_read_number",
            "int fgetc(FILE* stream)",
            "char* fgets(char* buffer, int size, FILE* stream)",
            "int fputs(const char* text, FILE* stream)",
            "void rewind(FILE* stream)",
            "void perror(const char* text)",
            "clock_t clock(void)",
            "time_t time(time_t* out)",
            "errno = ENOSYS;",
        ),
        "docs/architecture.txt": (
            "libc helpers cover common C game/tool glue beyond Doom",
            "`strtol`/`strtoul` with 32-bit range checks",
            "decimal-only `strtod`/`atof`",
            "The tiny stdio scanner supports bounded `%s`, `%[^\\n]`, `%i`, `%d`, `%u`, `%o`, `%x`, `%X`, and `%c`",
            "Character and line-oriented stdio is intentionally small but reusable",
            "LIBC_RUNTIME_CONTRACT[STRING_CONVERSION_ERRNO]",
            "LIBC_RUNTIME_CONTRACT[STDIO_SCAN_SUBSET]",
            "LIBC_RUNTIME_CONTRACT[STDIO_LINE_IO]",
            "LIBC_RUNTIME_CONTRACT[TIME_BOUNDARY]",
        ),
    },
    "fpu-runtime": {
        "kernel/kernel.asm": (
            "CR0_FPU_REQUIRED_BITS equ CR0_MP | CR0_NE",
            "and eax, CR0_FPU_CLEAR_MASK",
            "or eax, CR0_FPU_REQUIRED_BITS",
            "fnstcw [fpu_control_word]",
            "fnstsw [fpu_status_word]",
            "fsqrt",
            "process_fpu_switch_context:",
            "fnsave [edi]",
            "frstor [edi]",
            "fpu_record_exception_if_math:",
            "fnclex",
            "smoke_fpu_text db \" fpu=\", 0",
            "smoke_fpuctx_text db \" fpuctx=\", 0",
        ),
        "user/crt0.asm": (
            "fnclex",
        ),
        "doom_port/include/math.h": (
            "double sin(double x);",
            "double cos(double x);",
            "double atan(double x);",
            "double atan2(double y, double x);",
            "double pow(double x, double y);",
            "double sqrt(double x);",
            "double floor(double x);",
            "double ceil(double x);",
            "double fabs(double x);",
        ),
        "doom_port/libc.c": (
            "double sqrt(double x)",
            "double floor(double x)",
            "double ceil(double x)",
            "double fabs(double x)",
            "double pow(double x, double y)",
            "fsqrt",
            "frndint",
            "fyl2x",
        ),
        "docs/architecture.txt": (
            "## x87/FPU and math runtime",
            "CR0.MP and CR0.NE are set, while CR0.EM and CR0.TS are clear",
            "eager x87 save/restore",
            "Doom and future C games get these math functions from the freestanding runtime",
        ),
    },
}


GENERIC_DOC_REQUIREMENTS = {
        "docs/architecture.txt": (
            "## General-Purpose ABI Audit",
            "A second freestanding C program does not need to include Doom headers",
            "The reusable surface today is:",
            "`VIBE_OS_ABI_VERSION`, `VIBE_SYSCALL_VECTOR`",
            "returns either a non-negative\n  value or a negative errno",
            "versioned contract:\n  `argc`, `argv[]`, a null terminator, `envp[]`, a null terminator",
            "`VIBE_PROCESS_FAULT_EXIT_STATUS_BASE`",
            "The ABI is reusable, but not POSIX-complete.",
            "## General-OS Gap Contract",
        ),
    "docs/architecture.txt": (
        "`--root-elf NAME.ELF=PATH` packages additional checked or generated",
        "root-level 8.3 `.ELF` images without changing the boot path",
        "The generic pool is reusable, but it is still small and static.",
        "## Small User Runtime",
        "perform brk-style heap grows/shrinks",
        "anonymous/private mmap/munmap",
        "bounded fork",
        "waitpid",
        "USER_RUNTIME_CONTRACT[EXEC_ENV_HELPER]",
        "USER_RUNTIME_CONTRACT[LISTDIR_FIND_HELPER]",
        "USER_RUNTIME_CONTRACT[FD_CLOEXEC_HELPER]",
        "## POSIX Gap Decomposition",
    ),
}


POSIX_GAP_REQUIREMENTS = {
    "fork": {
        "docs/architecture.txt": (
            "`SYS_FORK` now implements a bounded probe-class fork",
            "eagerly copies present user pages into PMM-backed child frames",
            "parent returns the child PID while the child resumes with zero",
            "USER_RUNTIME_CONTRACT[WAIT_REAP_HELPER]",
        ),
        "doom_port/libc.c": (
            "pid_t fork(void)",
            "vibe_syscall3(VIBE_SYS_FORK, 0, 0, 0)",
            "syscall_failed(raw, ENOSYS)",
        ),
        "user/abi_probe.c": (
            "child = vibe_user_fork();",
            "vibe_user_waitpid(child, &status, 0)",
            "duplicate_reap == -ABI_PROBE_ERRNO_ECHILD",
            "shared_offset == 4",
        ),
    },
    "fd-duplication": {
        "docs/architecture.txt": (
            "Descriptor lifetime and fd duplication now have a bounded Unix-open-file-description milestone.",
            "shared root slot with a refcounted offset/status record",
            "`dup`, `dup2`, and\n  `dup3` are public syscall/libc surfaces",
            "`fcntl(F_GETFD/F_SETFD)` is the\n  descriptor-flag milestone",
            "fork-time fd descriptor cloning now shares open-file descriptions",
        ),
        "docs/architecture.txt": (
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
        "docs/architecture.txt": (
            "VM allocation is anonymous/private and brk-backed.",
            "copy-backed private file mapping",
            "POSIX-shaped `mmap(..., MAP_PRIVATE, fd, offset)`",
            "VIBE_VM_CAP_FILE_PRIVATE_COPY",
            "`MAP_FIXED`, `MAP_SHARED`, and kernel file-backed VM objects are still unsupported",
            "USER_RUNTIME_CONTRACT[FILE_PRIVATE_MMAP]",
            "file-backed `mmap`",
            "reusable VM object lifetime",
        ),
        "user/runtime.h": (
            "VIBE_USER_VM_CAP_FILE_PRIVATE_COPY",
            "int vibe_user_mmap_file(",
            "int vibe_user_mmap_file_private(void** out, unsigned long length, unsigned long prot, int fd, long offset);",
        ),
        "user/runtime.c": (
            "VIBE_USER_VM_CAP_FILE_PRIVATE_COPY",
            "int vibe_user_mmap_file(",
            "vibe_user_mmap_anon(out, length, prot)",
            "vibe_user_pread(",
            "(void)vibe_user_munmap(mapped, length);",
        ),
        "user/abi_probe.c": (
            "prove_file_private_mapping",
            "vibe_user_mmap_file_private(",
            "vibe_user_lseek(fd, 0, ABI_PROBE_SEEK_CUR) != 7",
            "mapped_tail_is_zero",
        ),
        "doom_port/libc.c": (
            "VIBE_VM_CAP_FILE_PRIVATE_COPY",
            "static int mmap_copy_file_private",
            "got = pread(fd,",
            "mmap_copy_file_private(fd, mapped, length, offset)",
            "errno = ENOSYS;",
        ),
        "user/probe.c": (
            "syscall3(SYS_MMAP, 0, 4096, mmap_fixed_flags) == -ERRNO_EINVAL",
        ),
    },
    "signals": {
        "docs/architecture.txt": (
            "POSIX signal delivery is absent.",
            "there is no public `signal.h`, signal\n  mask, `kill`, interval timer signal, or handler trampoline ABI",
        ),
        "docs/architecture.txt": (
            "signals",
            "`signal`, `sigaction`, `kill`, signal masks",
            "delivery across scheduler context switches",
        ),
    },
    "terminal-tty": {
        "docs/architecture.txt": (
            "Terminal/tty behavior is absent.",
            "unknown display ioctls return\n  `ENOTTY`",
            "there is no stdin/stdout tty device, `termios`, `isatty`",
        ),
        "docs/architecture.txt": (
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
        "docs/architecture.txt": (
            "Dynamic process lifetimes are bounded.",
            "no dynamically\n  growing process table",
            "or\n  unbounded child lifecycle manager",
        ),
        "docs/architecture.txt": (
            "dynamic process lifetimes",
            "two-entry static probe-class pool",
            "Dynamically allocated process records, unbounded child slots",
        ),
    },
}


STALE_DOC_WORDING = {
    "docs/architecture.txt": (
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

    print("Userland ABI contract OK: generic clock/input/framebuffer/audio/file/process, x87 math, libc glue, and copy-backed file-private mmap surface is documented.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
