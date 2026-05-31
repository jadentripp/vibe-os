# Linux Personality — M0 & M1 Requirements (High-Level)

**Date:** 2026-05-29
**Status:** Requirements outline (not a bite-sized implementation plan)
**Purpose:** Capture *what* M0 and M1 must deliver and depend on, so scope is locked even though detailed task-by-task plans are deferred until M-1 lands.
**Parent spec:** `docs/specs/2026-05-29-linux-personality-design.md`
**Prerequisite:** M-1 complete (`docs/plans/2026-05-29-linux-personality-m-1.md`) — a static Linux i386 binary runs (ELF loader, initial stack, full auxv, TLS, the static-startup syscalls, and compact `-ENOSYS` proof state).
**Current M-1 branch status:** Tasks 1-3 are scaffolded/committed on `feat/linux-personality-m-1`; the current worktree runs the hand-written `/BIN/HELLO.ELF` Linux test under `PERSONALITY_LINUX` with `write`/`exit` and exit status `42`, `/BIN/AUXV.ELF` confirms the full initial auxv through `AT_NULL`, `/BIN/TLS.ELF` proves `set_thread_area` + GS TLS with `tls ok`, `/BIN/STARTUP.ELF` proves the static-startup syscall batch with `startup ok` and exit status `7`, `/BIN/XLIMIT.ELF` proves heap-backed exec staging beyond the old argv/env/string caps with `exec limits ok` and exit status `9`, and Zig-built `/BIN/MUSL.ELF` proves real static musl stdio with `hello, musl on vibe-os` and exit status `7`. The branch also has an M0 seed: Zig-built `/BIN/GLIBC.ELF` now runs through real Debian i386 `ld-linux.so.2` + `libc.so.6`, prints `hello, glibc on vibe-os`, and returns the test program's expected exit status `11`; a broader `libc_probe` checks libc functions plus file existence/read and seed glibc-init calls (`getrlimit`, `prlimit64`, `set_robust_list`, `rt_sigaction`, `futex`), then prints `libc probe ok: noenv 42 pid=4` and exits `13`. M1a seeds are also in place: `/BIN/DIR.ELF` proves `openat(O_DIRECTORY)` and `getdents64(220)` on `/` and `/BIN`, printing `dir ok` and exiting `15`; `/BIN/FD.ELF` proves `dup`, `dup2`, `dup3`, `fcntl`, and `fcntl64` descriptor behavior, printing `fd ok` and exiting `17`; `/BIN/PIPE.ELF` proves `pipe`, `pipe2`, pipe read/write buffering, close, and close-on-exec flags, printing `pipe ok` and exiting `19`; `/BIN/FORK.ELF` proves full-copy Linux `fork`, parent/child memory divergence, and `waitpid` status encoding, printing `fork ok` and exiting `21`; `/BIN/BUSYBOX.ELF` proves BusyBox 1.35.0 static i386 musl applet dispatch, with `busybox echo busybox-ok` printing `busybox-ok` and `busybox true` exiting `0`; `/BIN/LDOOM.ELF` proves a static i386 Linux Doom binary can run through the Linux personality, load the rootfs shareware `DOOM1.WAD`, reach the game loop, print `ldoom frame=1 checksum=983fe686 nonzero=304`, and exit `0`. The current browser pressure probe packages the current available Debian sid i386 Chromium 148.0.7778.178-1 binary as `/BIN/CHROMIUM.ELF`, matching `chromium-common` ICU data as `/BIN/ICUDTL.DAT`, sid `libc6_2.42-16_i386.deb`, and the 101 recursive real sid i386 `NEEDED` shared libraries under `/LIB` aliases. Latest relocated-status proof with QEMU `-m 256M -cpu qemu32,+sse,+sse2` records `exec=OK`, `path=/BIN/CHROMIUM.ELF`, `interp=00000001/00000001`, `largelf=00000006/00000003/0000000C/00000004/00000001/00000001/00000000/0FCF245C/0FA71001`, `largeentry=019E7000`, `largebias=08000000/08000000/17CF245C/18000000`, `largemap=00000007/08010000/00010000/02007000/00000000/00006280`, `largedem=00000002/00000002/00000000/00000002/08010D76/08010000/00010000/00001000`, no panic, and no shutdown failure. Browser UI remains unproved; the current fresh boundary is early ld.so/Chromium demand paging around `/etc/ld.so.cache -> -ENOENT` and a user page fault at `0x08010D76`, while the older socket/clone/#UD notes need revalidation after the status-buffer relocation. Static glibc is optional for M-1 hardening and needs a separate Linux i386 static glibc toolchain; Zig's `x86-linux-gnu` libc target requires dynamic linking. BusyBox `ash` is compiled in but not yet accepted: `busybox sh -c 'echo busybox-ok'` currently exits `1` with `sh: out of memory`.

**Chromium packaging note (2026-05-31):** one wrapper smoke hit exit status `127` from a bad no-version library alias for `libnspr4.so`. The isolated disk image used the correct `/LIB/NSPR4.SO` alias family and did not reproduce that missing-library serial error, so that wrapper run is packaging noise rather than the current OS boundary.

> When each milestone is ready to build, expand this into a bite-sized plan via the `writing-plans` skill, grounded in the by-then-real M-1 code.

---

## M0 — Run a *dynamically-linked* glibc binary

**Goal:** vibe-os loads `/lib/ld-linux.so.2`, which resolves and relocates `libc.so.6`, and a dynamically-linked glibc "hello world" runs to completion with correct stdout and exit status. `rseq(386) -> -ENOSYS` is acceptable; other `-ENOSYS` results should be treated as the next implementation target.

**Why it's its own milestone:** M-1 proved the loader/stack/ABI for a *self-contained* binary. M0 adds the entire **dynamic-linking** path: a second ELF (the interpreter) loaded and handed control, plus the file-I/O surface ld.so uses to find, read, map, and protect shared objects.

**Current branch seed:** the worktree builds `tests/linux/hello_glibc` and `tests/linux/libc_probe` with Zig (`x86-linux-gnu`, fixed base `0x00e80000`, plain i386/no-SSE codegen) and installs one of them as `/BIN/GLIBC.ELF` for the focused smoke. The local proof uses real Debian i386 runtime assets under ignored `build/glibc-i386/`, installed into the FAT image as `/LIB/LDLINUX.SO2` and `/LIB/LIBC.SO6`. The kernel records `PT_INTERP` as `interp=status/match`, maps `/LIB/LDLINUX.SO2` as the interpreter ELF at `USER_INTERP_BASE`, sets the dynamic exec entry to the interpreter entry, wires `AT_BASE`, implements the `statx(AT_EMPTY_PATH)`/file-backed `mmap2`/anonymous fixed zero-fill path `ld.so` needed, accepts `mprotect` as a no-op for now, marks Linux `brk` growth in the heap bitmap so glibc stdio buffers validate correctly, routes compact `faccessat(307)` with `AT_FDCWD` through the existing Linux `access` path, and provides seed `getrlimit`/`ugetrlimit`/`prlimit64`, `set_robust_list`, query-only `rt_sigaction`, and basic `futex` wake/nonblocking-wait behavior. `LINUX_M0_LDSO_SMOKE` prints `hello, glibc on vibe-os` with exit status `11`; the same hook with `libc_probe` checks file existence, reads the ELF magic from `/LIB/LIBC.SO6`, checks those seed init syscalls, then prints `libc probe ok: noenv 42 pid=4` with exit status `13`.

### New capabilities required
1. **`PT_INTERP` handling in the loader** — when the ELF names an interpreter, map `ld-linux.so.2` at a chosen base, pass `AT_BASE` = that base, and transfer control to the *interpreter's* entry point (not the program's).
   - Seed status: `PT_INTERP` discovery, exact path matching, fixed-base interpreter mapping, `AT_BASE` plumbing, entry retargeting, real `ld.so` execution, `libc.so.6` discovery/stat/mapping, dynamic hello stdout/exit, `/LIB/LIBC.SO6` existence/read proof, and seed glibc-init syscalls are in place. The remaining work is broader protection, full dirfd-style file semantics, real signal/futex semantics, and SSE/FPU context.
2. **Linux-layout root filesystem** on the FAT image containing `/lib/ld-linux.so.2` and `/lib/libc.so.6` (32-bit glibc) at the exact paths the binary names. Verify FAT long-filename read of dotted lowercase names early.
3. **`/etc/ld.so.cache` → `-ENOENT`** so ld.so falls back to default search paths (no cache parser needed).
4. **File-I/O syscall surface** ld.so + glibc init exercise:
   `openat`/`open`, `close`, `read`, `pread64`, `_llseek`, `fstat64`/`stat64`/`lstat64`, `statx`, `faccessat`/`access`, `mmap2` (`MAP_PRIVATE|MAP_FIXED` file maps and anonymous fixed zero-fill), `mprotect` (currently accepted as a no-op; real **RELRO** perms later), `munmap`.
5. **glibc-init extras** beyond M-1: `set_robust_list`, `prlimit64`/`getrlimit`/`ugetrlimit`, `rt_sigaction`, `futex` (basic/uncontended), `rseq` → `-ENOSYS` tolerated.

### Explicitly deferred
vDSO (omit `AT_SYSINFO*`; glibc uses `int 0x80`), threads, networking, GUI.

### Acceptance criteria
- Dynamic glibc hello prints correct stdout and returns its exit status. Current seed proves `hello, glibc on vibe-os` with exit status `11`.
- A binary that calls several libc functions behaves correctly. Current seed proves `strtol`, `snprintf`, `malloc`/`realloc`/`free`, `qsort`, `access`, raw `faccessat(307)` for `AT_FDCWD`, open/read/close of `/LIB/LIBC.SO6`, `getrlimit`, `prlimit64`, `set_robust_list`, `rt_sigaction`, basic `futex`, `getpid`, `getenv`, `printf`, and `fflush`.
- Guest status shows the ld.so open/read/statx/mmap2/mprotect resolution sequence remains fault-free; only explicitly tolerated `rseq -> -ENOSYS` remains for the test binary.

### Key risks / dependencies
- **mmap2 semantics** (page-offset) and `MAP_FIXED` correctness for placing shared-object segments.
- **FAT path/case** mismatch hiding `libc.so.6`.
- **SSE/FPU context:** current Linux C probes are compiled for plain i386/no-SSE. Optimized glibc string/SSE paths need explicit CPU-feature/FPU-context work before becoming acceptance surface.
- Choosing/pinning a specific 32-bit glibc and confirming whether it uses `statx` vs the `stat64` family on the target.
- Depends entirely on M-1's loader, stack, auxv, and TLS being solid.

### Rough task groupings (to expand later)
`PT_INTERP` loader extension · rootfs builder for glibc+ld.so · file-I/O syscall batch · mmap2/mprotect for shared objects · glibc-init syscall batch · dynamic-hello acceptance.

---

## M1 — Interactive shell + coreutils

**Goal:** Boot into an interactive shell where you can `cd` a real directory tree, pipe and redirect (`ls | grep foo > out.txt`), run `ls`/`cat`/`cp`/`ps`, and **Ctrl-C a running command**.

**Why it's its own (and the heaviest) milestone:** the syscall count only roughly doubles, but it introduces **four or five genuinely new kernel subsystems** at once. This is where "I'm reimplementing a kernel" becomes literally true.

### New subsystems required (the real cost — not syscall count)
1. **Copy-on-write `fork`** — duplicate a process address space COW (clone page tables, mark COW, split on write-fault). The single biggest new mechanism. Plus `wait4`/`waitpid`, `execve` post-fork, `exit_group`. Seed status: Linux `fork(2)`, `waitpid(7)`, and `wait4(114)` with `rusage=NULL` now work for one child by full-copying user pages through high-kernel copy aliases; COW is still future work. **Note:** the current fixed **6-slot** process model must become dynamic (or a much larger recyclable pool).
2. **TTY + line discipline** — termios (`TCGETS/TCSETS`), `TIOCGWINSZ`, `TIOCGPGRP/TIOCSPGRP`, `TIOCSCTTY`; canonical vs raw mode, echo, backspace; and **generating signals from keystrokes** (Ctrl-C → SIGINT) routed to the foreground process group.
3. **Real signals** — `rt_sigaction`, `rt_sigprocmask`, **`rt_sigreturn`** (context-restore trampoline — corruption risk if wrong), `sigaltstack`, `kill`, `tgkill`; delivery to the foreground group.
4. **Process groups / sessions** — `setpgid`, `getpgid`, `setsid`, `getsid` (the basis for job control).
5. **FD plumbing** — `pipe2`, `dup`/`dup2`/`dup3`, `fcntl` (`F_DUPFD`, close-on-exec, file flags), `poll`/`ppoll`.
   - Seed status: Linux `pipe(42)`, `dup(41)`, `dup2(63)`, `fcntl(55)`, `fcntl64(221)`, `dup3(330)`, and `pipe2(331)` now route through the native FD model for fixed-size pipe buffering, descriptor duplication, close-on-exec flags, `F_DUPFD`, and minimal `F_GETFL/F_SETFL` append/nonblock flag handling. `/BIN/FD.ELF` proves shared descriptor offsets and close-on-exec reporting; `/BIN/PIPE.ELF` proves pipe read/write/close plus `pipe2(O_CLOEXEC)`.
6. **Real VFS directories** — **`getdents64`** (this is `ls`), `openat(O_DIRECTORY)`, `mkdirat`, `unlinkat`, `renameat2`, `linkat`, `symlinkat`, `readlinkat`, `chdir`/`fchdir`/`getcwd`, `fchmodat`, `fchownat`, `utimensat`, `ftruncate`, `statfs`.
   - Seed status: `open/openat(..., O_DIRECTORY)` can create directory FDs for FAT root and one-level FAT directories, and `getdents64(220)` emits Linux `dirent64` records from FAT entries. This is enough for the hand-asm `/BIN/DIR.ELF` probe, not yet a full `ls`/cwd/pathname implementation.
7. **`futex` (real)** — bash hits it on glibc stdio locks even single-threaded.
8. **Misc** — `uname`, `sysinfo`, `clock_gettime`, `nanosleep`/`clock_nanosleep`, `get*id`/`set*id`, `getrlimit`/`prlimit64`.

### Synthetic filesystems (now mandatory)
- **procfs:** `/proc/self/{exe,fd/*,maps,status,stat,cmdline,environ}`, `/proc/{meminfo,cpuinfo,stat}`, `/proc/self/mounts`, `/proc/filesystems` — generated on read from live kernel state.
- **devfs:** `/dev/{null,zero,tty,console,random,urandom}` + `stdin/stdout/stderr` symlinks → `/proc/self/fd/{0,1,2}`.
- **Symlink emulation** layered over FAT (FAT has no native symlinks).

### Staging
- **M1a:** static **BusyBox** (`ash` + applets) — exercises fork/exec/pipe/tty/getdents/signals **without** the dynamic-linker surface. Current proof: BusyBox 1.35.0 static i386 musl, `ET_EXEC`, no PIE, linked at `0x00e80000`, 112460 bytes, built under ignored `build/busybox-src/busybox-1.35.0`, copied to `build/busybox-i386/busybox-vibe`, and installed as `/BIN/BUSYBOX.ELF`. `busybox echo busybox-ok` prints the marker and exits `0`; `busybox true` exits `0`. Both show `exec=OK`, Linux personality selected, `last_error=0`, `linux_last_unimpl_nr=0`, and no fault/panic/shutdown failure. The same Linux-personality surface now also runs the static `/BIN/LDOOM.ELF` headless Doom proof from the shareware WAD to a nonblank frame (`checksum=983fe686`, `nonzero=304`, exit `0`). `busybox sh -c 'echo busybox-ok'`, `ls`, and `cat` remain unproved.
- **M1b:** dynamic **bash + GNU coreutils** — leans hard on `/proc/self/exe` and the full glibc surface.
- **Browser pressure probe:** current available Debian sid i386 Chromium (`chromium_148.0.7778.178-1_i386.deb`) is not an M1 acceptance item, but it is now a reproducible later-roadmap probe. The ignored artifact lives under `build/chromium-i386/`, package SHA-256 `627276adfbd983e1537403f9f8382db27f100f3944df1f2279ca3cc65b93665e`, browser ELF SHA-256 `8a65db2dac7bebd1cf932290139e110fae970efbf6be5a2351188f824fee7c2a`. Matching ignored `chromium-common_148.0.7778.178-1_i386.deb` supplies `/BIN/ICUDTL.DAT`; package SHA-256 `26344d8b9cf82e61ad67240f46ccf24cf2b902a47d29e51681c3440842c735b3`, `icudtl.dat` SHA-256 `bd8c145abdf3f8383276ce01dfa4ae48709bef9fef1c0711eb7c3fab4f6eb7c2`. Chromium smoke also stages ignored Debian sid i386 `libc6_2.42-16_i386.deb` under `build/chromium-runtime-i386/libc6-sid/`, package SHA-256 `4581e89be4256fe0b75c1ba7090477b65d1a4c893ddc0d438c518c6dd8e8e8fb`, so `/LIB/LDLINUX.SO2` and `/LIB/LIBC.SO6` match the current sid browser ABI, plus 101 recursive real sid i386 `NEEDED` shared-library assets under `/LIB` aliases. The 512 MiB FAT image packages `/BIN/CHROMIUM.ELF` and `/BIN/ICUDTL.DAT`; the latest relocated-status `LINUX_M1_CHROMIUM_SMOKE` reports `exec=OK path=/BIN/CHROMIUM.ELF interp=00000001/00000001 largelf=00000006/00000003/0000000C/00000004/00000001/00000001/00000000/0FCF245C/0FA71001 largeentry=019E7000 largebias=08000000/08000000/17CF245C/18000000 largemap=00000007/08010000/00010000/02007000/00000000/00006280 largedem=00000002/00000002/00000000/00000002/08010D76/08010000/00010000/00001000`, Linux personality selected, real sid ld-linux loaded, no kernel panic/shutdown. Large-ELF handling now pre-maps the main ELF `PT_DYNAMIC` page, reserves the ld.so staging window before sparse allocation, begins demand-paging Chromium file-backed data, handles inherited present-but-supervisor identity mappings inside the browser VMA by replacing them with user page tables, updates present PTE permissions for `mprotect`, reads/writes high physical process page tables through copy aliases, supplies synthetic Linux library directories, recognizes optional `rseq(386) -> -ENOSYS`, saves/restores SSE/FPU context, provides seed `socketpair`, implements `setsockopt(SOL_SOCKET, SO_PASSCRED)`, and routes fork-like `clone` through full-copy fork. The current fresh proof has not re-reached `setsockopt` or `clone`; next requirements are pushing the early demand-page boundary around `/etc/ld.so.cache -> -ENOENT` and `0x08010D76`, then `/proc`/`/dev`, `/usr/lib/os-release`, broader socket semantics, resource-pack/locales packaging, graphics/input, process/sandbox, and many more syscalls.

  Latest parent evidence supersedes the old boundary text above: the proof exits `127` around `openat`/`access` probing for `/usr/lib/.../libnspr4.so`. `setsockopt`, fork-like `clone`, and #UD remain implemented/historical surfaces, not current Chromium progress claims.

### Acceptance criteria
- Interactive prompt; `cd` a real directory tree; `ls | grep foo > out.txt`; `cat out.txt`; `cp`/`ps`.
- **Ctrl-C interrupts a running `sleep`** (proves the tty → signal → process-group path end to end).
- Current seed acceptance: static BusyBox launches under the Linux personality from `/BIN/BUSYBOX.ELF`, applet dispatch works for `echo` and `true`, exit code `0` is reported, and the smoke does not end on an unexpected `-ENOSYS`. Static Linux Doom also launches from `/BIN/LDOOM.ELF`, loads `/DOOM1.WAD`, reaches a nonblank frame, exits `0`, and does not fault/panic/shutdown or end on an unexpected `-ENOSYS`. Current Chromium is only a pressure probe: it is packaged, execs under the Linux personality, loads ld-linux, and begins demand-paging browser file-backed data, but it still stops before any browser UI at the early relocated-status demand-page boundary; socket/clone/#UD evidence needs to be revalidated.

  Current Chromium acceptance stops at the `127` `/usr/lib/.../libnspr4.so` library-path boundary; do not count the older socket/clone/#UD notes as accepted until the relocated proof re-reaches them.

### Key risks / dependencies
- **COW fault handling** correctness (corruption is the failure mode).
- **`rt_sigreturn`** trampoline correctness (stack corruption after handler return).
- **Dynamic process allocation** replacing the fixed 6-slot model.
- **procfs/devfs/symlink** layer over FAT, including path semantics.
- Depends on M0 (dynamic glibc) for M1b; M1a (BusyBox-static) can start right after M-1.

### Rough task groupings (to expand later)
Dynamic process table + COW fork · tty/line-discipline subsystem · signal delivery + `rt_sigreturn` · process groups/sessions · pipes + fd plumbing · VFS directory ops + `getdents64` · procfs · devfs + symlink emulation · BusyBox acceptance (echo/true done; `ash`/`ls`/`cat` pending) · bash+coreutils acceptance (M1b).

---

## Beyond M1 (pointer only — see spec §10)
M2 threads/epoll → M3 networking → M4 display+input (incl. Xbox gamepad) → **M5 64-bit/long-mode port (⚠️ prerequisite for official Chrome)** → M6 web engine/current-Chromium pressure probes → M7 WebGPU → M8 StemStudio. Each gets its own spec + plan.
