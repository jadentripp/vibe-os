# Linux Personality — M0 & M1 Requirements (High-Level)

**Date:** 2026-05-29
**Status:** Requirements outline (not a bite-sized implementation plan)
**Purpose:** Capture *what* M0 and M1 must deliver and depend on, so scope is locked even though detailed task-by-task plans are deferred until M-1 lands.
**Parent spec:** `docs/specs/2026-05-29-linux-personality-design.md`
**Prerequisite:** M-1 complete (`docs/plans/2026-05-29-linux-personality-m-1.md`) — a static Linux i386 binary runs (ELF loader, initial stack, full auxv, TLS, the static-startup syscalls, the syscall tracer).

> When each milestone is ready to build, expand this into a bite-sized plan via the `writing-plans` skill, grounded in the by-then-real M-1 code.

---

## M0 — Run a *dynamically-linked* glibc binary

**Goal:** vibe-os loads `/lib/ld-linux.so.2`, which resolves and relocates `libc.so.6`, and a dynamically-linked glibc "hello world" runs to completion with correct stdout and exit status — hitting zero `-ENOSYS`.

**Why it's its own milestone:** M-1 proved the loader/stack/ABI for a *self-contained* binary. M0 adds the entire **dynamic-linking** path: a second ELF (the interpreter) loaded and handed control, plus the file-I/O surface ld.so uses to find, read, map, and protect shared objects.

### New capabilities required
1. **`PT_INTERP` handling in the loader** — when the ELF names an interpreter, map `ld-linux.so.2` at a chosen base, pass `AT_BASE` = that base, and transfer control to the *interpreter's* entry point (not the program's).
2. **Linux-layout root filesystem** on the FAT image containing `/lib/ld-linux.so.2` and `/lib/libc.so.6` (32-bit glibc) at the exact paths the binary names. Verify FAT long-filename read of dotted lowercase names early.
3. **`/etc/ld.so.cache` → `-ENOENT`** so ld.so falls back to default search paths (no cache parser needed).
4. **File-I/O syscall surface** ld.so + glibc init exercise:
   `openat`/`open`, `close`, `read`, `pread64`, `_llseek`, `fstat64`/`stat64`/`lstat64` (or `statx`), `faccessat`/`access`, `mmap2` (`MAP_PRIVATE|MAP_FIXED`), `mprotect` (for **RELRO**), `munmap`.
5. **glibc-init extras** beyond M-1: `set_robust_list`, `prlimit64`/`getrlimit`, `rt_sigaction`, `futex` (basic/uncontended), `rseq` → `-ENOSYS` tolerated.

### Explicitly deferred
vDSO (omit `AT_SYSINFO*`; glibc uses `int 0x80`), threads, networking, GUI.

### Acceptance criteria
- Dynamic glibc hello prints correct stdout and returns its exit status.
- A binary that calls several libc functions (`printf`, `malloc`, `getpid`, file open/read) behaves correctly.
- Tracer shows ld.so's open/read/mmap2/mprotect resolution sequence; no `-ENOSYS` for the test binary.

### Key risks / dependencies
- **mmap2 semantics** (page-offset) and `MAP_FIXED` correctness for placing shared-object segments.
- **FAT path/case** mismatch hiding `libc.so.6`.
- Choosing/pinning a specific 32-bit glibc and confirming whether it uses `statx` vs the `stat64` family on the target.
- Depends entirely on M-1's loader, stack, auxv, and TLS being solid.

### Rough task groupings (to expand later)
`PT_INTERP` loader extension · rootfs builder for glibc+ld.so · file-I/O syscall batch · mmap2/mprotect for shared objects · glibc-init syscall batch · dynamic-hello acceptance.

---

## M1 — Interactive shell + coreutils

**Goal:** Boot into an interactive shell where you can `cd` a real directory tree, pipe and redirect (`ls | grep foo > out.txt`), run `ls`/`cat`/`cp`/`ps`, and **Ctrl-C a running command**.

**Why it's its own (and the heaviest) milestone:** the syscall count only roughly doubles, but it introduces **four or five genuinely new kernel subsystems** at once. This is where "I'm reimplementing a kernel" becomes literally true.

### New subsystems required (the real cost — not syscall count)
1. **Copy-on-write `fork`** — duplicate a process address space COW (clone page tables, mark COW, split on write-fault). The single biggest new mechanism. Plus `wait4`/`waitpid`, `execve` post-fork, `exit_group`. **Note:** the current fixed **6-slot** process model must become dynamic (or a much larger recyclable pool).
2. **TTY + line discipline** — termios (`TCGETS/TCSETS`), `TIOCGWINSZ`, `TIOCGPGRP/TIOCSPGRP`, `TIOCSCTTY`; canonical vs raw mode, echo, backspace; and **generating signals from keystrokes** (Ctrl-C → SIGINT) routed to the foreground process group.
3. **Real signals** — `rt_sigaction`, `rt_sigprocmask`, **`rt_sigreturn`** (context-restore trampoline — corruption risk if wrong), `sigaltstack`, `kill`, `tgkill`; delivery to the foreground group.
4. **Process groups / sessions** — `setpgid`, `getpgid`, `setsid`, `getsid` (the basis for job control).
5. **FD plumbing** — `pipe2`, `dup`/`dup2`/`dup3`, `fcntl` (`F_DUPFD`, close-on-exec, file flags), `poll`/`ppoll`.
6. **Real VFS directories** — **`getdents64`** (this is `ls`), `openat(O_DIRECTORY)`, `mkdirat`, `unlinkat`, `renameat2`, `linkat`, `symlinkat`, `readlinkat`, `chdir`/`fchdir`/`getcwd`, `fchmodat`, `fchownat`, `utimensat`, `ftruncate`, `statfs`.
7. **`futex` (real)** — bash hits it on glibc stdio locks even single-threaded.
8. **Misc** — `uname`, `sysinfo`, `clock_gettime`, `nanosleep`/`clock_nanosleep`, `get*id`/`set*id`, `getrlimit`/`prlimit64`.

### Synthetic filesystems (now mandatory)
- **procfs:** `/proc/self/{exe,fd/*,maps,status,stat,cmdline,environ}`, `/proc/{meminfo,cpuinfo,stat}`, `/proc/self/mounts`, `/proc/filesystems` — generated on read from live kernel state.
- **devfs:** `/dev/{null,zero,tty,console,random,urandom}` + `stdin/stdout/stderr` symlinks → `/proc/self/fd/{0,1,2}`.
- **Symlink emulation** layered over FAT (FAT has no native symlinks).

### Staging
- **M1a:** static **BusyBox** (`ash` + applets) — exercises fork/exec/pipe/tty/getdents/signals **without** the dynamic-linker surface. The smart first target.
- **M1b:** dynamic **bash + GNU coreutils** — leans hard on `/proc/self/exe` and the full glibc surface.

### Acceptance criteria
- Interactive prompt; `cd` a real directory tree; `ls | grep foo > out.txt`; `cat out.txt`; `cp`/`ps`.
- **Ctrl-C interrupts a running `sleep`** (proves the tty → signal → process-group path end to end).

### Key risks / dependencies
- **COW fault handling** correctness (corruption is the failure mode).
- **`rt_sigreturn`** trampoline correctness (stack corruption after handler return).
- **Dynamic process allocation** replacing the fixed 6-slot model.
- **procfs/devfs/symlink** layer over FAT, including path semantics.
- Depends on M0 (dynamic glibc) for M1b; M1a (BusyBox-static) can start right after M-1.

### Rough task groupings (to expand later)
Dynamic process table + COW fork · tty/line-discipline subsystem · signal delivery + `rt_sigreturn` · process groups/sessions · pipes + fd plumbing · VFS directory ops + `getdents64` · procfs · devfs + symlink emulation · BusyBox acceptance (M1a) · bash+coreutils acceptance (M1b).

---

## Beyond M1 (pointer only — see spec §10)
M2 threads/epoll → M3 networking → M4 display+input (incl. Xbox gamepad) → **M5 64-bit/long-mode port (⚠️ prerequisite for Chrome)** → M6 web engine → M7 WebGPU → M8 StemStudio. Each gets its own spec + plan.
