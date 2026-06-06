# vibe-os Linux Binary-Compatibility Personality — Design Spec

**Date:** 2026-05-29
**Status:** Draft for review
**Scope of this spec:** Milestones M-1 → M1 (run unmodified Linux i386 ELF binaries, from a static hello-world up to an interactive shell + coreutils).
**Out of scope (roadmap only):** threads, networking, display/GPU, web engine, WebGPU, StemStudio, 64-bit.

**Finish proof update (2026-06-06):** the current M-1 proof supersedes older Chromium boundary text that cites `1739/rseq`. `clone3` now preserves the validated `stack`/`stack_size` range as the shared-VM child stack bounds; the focused probe prints `clone3 ok`, exits `49`, and leaves `panic=NONE`, `shutdown=NONE`, `pmmchk=OK`. The latest Chromium pressure run keeps final status on `/BIN/CHROMIUM.ELF` by staging resource aliases while omitting the optional crashpad sidecar, with `argc=0000000C`, `largedem=0000144C/.../02D80110/...`, `linuxsys=00000488/00000078/FFFFFFEA/...`, `m1live` RUNNING status, `faultsrc=NONE`, `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. The current browser boundary is `clone(120) -> -EINVAL`; this is browser-owned startup pressure, not UI.

---

## 1. North Star & Why This Spec Exists

The long-term dream is to run **browser-based web apps (e.g. StemStudio) on vibe-os** — ideally by running a real browser (Chrome) or a webview-based wrapper (Tauri).

Every path to that goal reduces to the same requirement: **vibe-os must present a Linux-compatible userland**, because the browser, its webview, glibc, and essentially all the software involved are *Linux programs*. The leverage move — proven by **WSL1, FreeBSD's Linuxulator, gVisor, and illumos lx-zones** — is to build a **Linux personality**: a syscall-ABI compatibility layer that lets vibe-os run *unmodified* Linux binaries, so we **reuse** Linux's existing userland rather than rebuild it.

We are **not** rebuilding Linux's userland (glibc, BusyBox, bash, coreutils already exist and get reused). We are reimplementing the **Linux kernel's syscall interface** — the membrane between Ring 3 and Ring 0 — accurately enough that real Linux userland feels at home.

This spec covers only the **foundation**: getting from "nothing runs" to "an interactive shell with coreutils." Everything above it is a roadmap (§10), each rung its own future spec.

---

## 2. Grounded Starting Point (what vibe-os has *today*)

Read from `kernel/kernel.asm` (36.7k lines, single file) and `AGENTS.md`:

| Capability | State today | Relevance |
|---|---|---|
| **Bitness** | **32-bit protected mode** (`bits 32`) | Target the **Linux i386 ABI**, not x86-64. ⚠️ See §9 risk. |
| **Syscall entry** | `int 0x80` (`SYSCALL_TRAP_VECTOR equ 0x80`) | **Same vector Linux i386 uses.** Huge alignment. |
| **Error convention** | negative errno (`SYSCALL_RESULT_NEGATIVE_ERRNO`) | **Same as Linux.** |
| **Saved arg regs** | 6 GPRs saved (EBP,EDI,ESI,EDX,ECX,EBX; mask `0x3f`) but `SYSCALL_MAX_ARGS equ 3` | Frame already saves all 6 Linux arg regs; just lift the arg cap. |
| **Native syscalls** | exit, write, open, read, lseek, close, sbrk, stat, fstat, **mmap, munmap**, ioctl, **fork, waitpid**, getpid, getppid, ftruncate, clock_gettime, **listdir**, dup, fcntl, exec, unlink, yield, sleep_ticks | Operations largely **exist** — personality maps Linux numbers → these + fills gaps. |
| **auxv at exec** | M-1 worktree builds the static Linux auxv set (`AT_PHDR`, `AT_RANDOM`, `AT_EXECFN`, etc.) | `/BIN/AUXV.ELF` proves the table through `AT_NULL`; dynamic-linker `AT_BASE` is wired to the interpreter base and used by the first `ld.so` smoke. |
| **Static musl proof** | M-1 worktree builds a Zig `x86-linux-musl` static binary and maps musl `writev(146)` | `/BIN/MUSL.ELF` prints `hello, musl on vibe-os` and exits `7`; static glibc remains toolchain-gated. |
| **Paging / address spaces** | per-process page dir, CR3 switching (`KERNEL_RELOC_ABI_LIVE_CR3_SWITCH`), PMM cap raised for 256 MiB QEMU browser proofs (`pmmwin=00100000/0FFE0000`, frame map `0x00050000/0x0000FF00`) | Per-process VM exists. Current M1a seed can full-copy fork pages through high-kernel copy aliases; the Chromium fork-like `clone` path exists but has not been re-reached by the latest relocated-status proof. True COW remains future work. |
| **Process model** | **fixed 8 slots** (`PROCESS_SLOT_COUNT equ 8`), per-proc brk + heap bitmap + personality/TLS state | Works, but fixed/small — see §9. |
| **User memory** | fixed payload window (load `0x01000000`), fixed heap/stack windows, brk + mmap regions | Real but rigid; the current Linux path has enough heap-backed anonymous/file `mmap2` for the glibc smoke, but M1 still needs a general mmap arena. |
| **Filesystem** | FAT with VFS ABI (open/read/write/lseek/stat/fstat/listdir), root+table caches | Files work, and the Linux path now has a seed `open/openat(O_DIRECTORY)` + `getdents64(220)` bridge for FAT root and one-level subdirectories, focused cwd/dirfd-relative `open`/`stat` proof, and BusyBox root `ls /` proof; **no symlinks, no generic multi-level pathname/write-path model, 8.3/LFN, case-insensitive** — see §9. |
| **TLS (GS/set_thread_area)** | M-1 worktree has a single-threaded GDT TLS slot and `set_thread_area(243)` | `/BIN/TLS.ELF` proves GS-base readback; flags/limit are still intentionally minimal. |
| **Limits** | M-1 worktree has heap-backed exec staging with `PATH_MAX 4096`, `ARG_MAX 64`, `ARG_STR_MAX 4096`, `ENV_MAX 64`, `ENV_STR_MAX 4096`, and a shared 32 KiB string pool | `/BIN/XLIMIT.ELF` proves 10 argv entries, 9 env entries, and strings crossing the old 64-byte cap without fixed `.bss` growth. |
| **Dynamic-linker seed** | M0 worktree builds Zig `x86-linux-gnu` dynamic binaries with plain i386/no-SSE codegen, recognizes `PT_INTERP`, maps the interpreter, and can run real Debian i386 `ld-linux.so.2` + `libc.so.6` from the FAT image | `/BIN/GLIBC.ELF` prints `hello, glibc on vibe-os` and exits with the expected status `11`; the broader `libc_probe` prints `libc probe ok: noenv 42 pid=4` and exits `13` after checking file existence/read plus seed glibc-init calls (`getrlimit`, `prlimit64`, `set_robust_list`, `rt_sigaction`, `futex` wake/wait); `/BIN/FD.ELF` proves seed FD duplication/fcntl behavior; `rseq(386)` remains a tolerated `-ENOSYS`. |
| **Static BusyBox seed** | BusyBox 1.35.0, static i386 musl, `ET_EXEC`, no PIE, linked at `0x00e80000`; `tools/build_busybox_vibe.sh` builds it from the ignored source tree under `build/busybox-src/busybox-1.35.0` into `build/busybox-i386/busybox-vibe` (currently 192260 bytes), with rootfs injection as `/BIN/BUSYBOX.ELF` when present | Focused selectors exec `/BIN/BUSYBOX.ELF` through the Linux personality and prove `echo`, `true`, non-interactive `sh -c`, `ls /BIN`, root `ls /`, `cat`, `cp`, `grep`, `sleep`, and focused `ps` with exit `0` and `linux_last_unimpl_nr=0`. The `ps` proof uses a tiny selector-gated synthetic `/proc` seed; full interactive shell/coreutils, generic procfs/devfs, shell-composed pipes/redirection, and Ctrl-C remain M1 work. |
| **Linux Doom proof** | `tests/linux/linux_doom` is a static i386 musl `ET_EXEC` linked at `0x01000000`, built from the original Linux Doom 1.10 engine sources plus the small headless Linux platform layer in `tests/linux/linux_doom_headless.c`; rootfs injection installs it as `/BIN/LDOOM.ELF` when present | `LINUX_M1_LDOOM_SMOKE` execs `/BIN/LDOOM.ELF` through the Linux personality, reads the external shareware `DOOM1.WAD` from the FAT root, reaches the Doom game loop, and serial-proves `ldoom frame=1 checksum=983fe686 nonzero=304` before exiting `0`. Status shows `exec=OK path=/BIN/LDOOM.ELF`, Linux personality selected, no page fault, `panic=NONE`, `shutdown=NONE`, and `linux_last_unimpl_nr=0`. This is not the native `/APPS/DOOM/APP.ELF` path. |
| **Current Chromium probe** | Current available Debian sid i386 Chromium binary package `chromium_148.0.7778.178-1_i386.deb` was downloaded into ignored `build/chromium-i386/`; package SHA-256 `627276adfbd983e1537403f9f8382db27f100f3944df1f2279ca3cc65b93665e`, browser ELF SHA-256 `8a65db2dac7bebd1cf932290139e110fae970efbf6be5a2351188f824fee7c2a`, size 262608780 bytes. Matching `chromium-common_148.0.7778.178-1_i386.deb` is also staged; package SHA-256 `26344d8b9cf82e61ad67240f46ccf24cf2b902a47d29e51681c3440842c735b3`, with `icudtl.dat` SHA-256 `bd8c145abdf3f8383276ce01dfa4ae48709bef9fef1c0711eb7c3fab4f6eb7c2`. Chromium smoke uses ignored Debian sid i386 `libc6_2.42-16_i386.deb` under `build/chromium-runtime-i386/libc6-sid/` for `/LIB/LDLINUX.SO2` and `/LIB/LIBC.SO6`; package SHA-256 `4581e89be4256fe0b75c1ba7090477b65d1a4c893ddc0d438c518c6dd8e8e8fb`, ld-linux SHA-256 `2527ad9fdf19bc90734f17e10922d188dff9095abfcc1d06f97a0c1443f9f508`, libc SHA-256 `7361db7f1c6692adedfb8a1cc4956cb0bddef201aef3aa4ba53a28f0ceff8c51`, plus the 101 recursive `NEEDED` sonames recorded in ignored `build/chromium-recursive-sonames.txt`. The Chromium ELF is i386 `ET_DYN`/PIE, dynamically linked, interpreter `/lib/ld-linux.so.2`, entry `0x019e7000`, and has large `PT_LOAD` VMAs reaching `0x0fcf245c`. | The FAT image geometry supports a 512 MiB rootfs and packages `/BIN/CHROMIUM.ELF` plus `/BIN/ICUDTL.DAT`. `LINUX_M1_CHROMIUM_SMOKE` now execs that real browser ELF through `PERSONALITY_LINUX`, applies the `0x08000000` ET_DYN load bias, sparse-maps the first page of each `PT_LOAD`, pre-maps the main ELF page containing `PT_DYNAMIC`, reserves the ld.so staging window so interpreter loading does not overwrite sparse main-ELF pages, loads real sid `/LIB/LDLINUX.SO2`, and demand-pages Chromium file-backed pages from FAT. The latest parent `m1live` evidence records `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, 1739 (`0x6CB`) handled demand pages, last demand address `0x083D7000`, 945 Linux syscalls, latest captured Linux error `rseq(386) -> -ENOSYS`, process state `RUNNING`, `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. The old `0x08010D76` and `1250`/`0x082DB000` snapshots are handled/tolerated history, not the active boundary. This is current Chromium, not the old Chromium compatibility path, not headless shell, and not a native shim; it is a browser-owned userland startup pressure probe, not a browser UI claim. |
| **Conventions** | assembly-first, C modest, **no Python** (`AGENTS.md`) | Personality is kernel work → assembly-first. |

**Current Chromium update (2026-05-31, parent evidence):** after moving smoke status capture to `0x77000` and then adding live process-state reporting, the latest parent `m1live` Chromium evidence records `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, 1739 (`0x6CB`) handled demand pages, last demand address `0x083D7000`, 945 Linux syscalls, latest captured Linux error `rseq(386) -> -ENOSYS`, process state `RUNNING`, no panic, no shutdown failure, and `pmmchk=OK`. A separate wrapper run hit a bad no-version library alias for `libnspr4.so`, but the isolated disk image used the correct `/LIB/NSPR4.SO`-style aliases and did not reproduce that missing-library serial error. Treat earlier local notes about passing `setsockopt`, passing fork-like `clone`, or reaching a contained user #UD as historical/provisional until the live-status proof re-reaches those surfaces. Next work is a tighter PROCID/identity-session seed so repeated status reads prove the same browser-owned process is still running, then broader `/proc`, `/dev`, resources/locales, process/sandbox, graphics/input, and syscall work. This remains a pressure probe, not a UI/rendering claim.

**Chromium packaging note (2026-05-31):** one wrapper smoke hit exit status `127` from a bad no-version library alias for `libnspr4.so`. The isolated disk image used the correct `/LIB/NSPR4.SO` alias family and did not reproduce that missing-library serial error, so that wrapper run is packaging noise rather than the current OS boundary.

**Takeaway:** vibe-os is unusually well-positioned — its native ABI is already `int 0x80` + negative-errno + a near-POSIX call set. The personality is mostly *number remapping, ABI-exactness, and gap-filling*, not greenfield.

---

## 3. Goals & Non-Goals

### Goals (this spec)
- Run **unmodified Linux i386 ELF binaries** under a Linux personality.
- **M-1:** statically-linked binary (musl-static / `gcc -static`) prints and exits with correct status.
- **M0:** dynamically-linked **glibc** binary runs (dynamic linker + TLS + full auxv).
- **M1:** interactive shell + coreutils — `cd`, pipes, redirection, Ctrl-C interrupt, `ls`/`cat`/`cp`/`ps`.
- Build a guest-visible syscall/status proof surface as the primary dev tool; the current proof kernel keeps this compact as `linux_last_unimpl_nr`, widened the BIOS kernel-read window to 448 sectors (229376 bytes), stages the temporary ELF at `0x68000` so the full read window stays below VGA memory, uses a 32 KiB smoke-status capture at `0x77000`, moved the PMM frame map to `0x50000`, and leaves low kernel stacks/page tables clear of frame accounting.
- Strace-style development loop as the working method.

### Non-Goals (deferred to roadmap §10)
- Threads beyond `fork` (clone-with-CLONE_VM, full futex contention, robust lists under contention).
- `epoll`/`eventfd`/`signalfd`, networking/sockets (`socketcall`).
- Display server, framebuffer GUI, input beyond tty, GPU, WebGPU.
- Web engine (Chrome/WebKitGTK), Tauri, StemStudio.
- **64-bit / long mode** (prerequisite for official Google Chrome; current Debian i386 Chromium can be used as a browser-pressure probe, but still needs the broader loader/address-space/userland work in §9).
- Sandboxing (seccomp, namespaces, cgroups), security hardening, multi-user.
- ARM / Raspberry Pi 4 target.

---

## 4. Architecture

### 4.1 Dual personality, selected at exec
Keep vibe-os's **native ABI** intact. Add a **Linux personality** as a second syscall dispatch path. Each process record carries a **personality flag**; the ELF loader sets it to `LINUX` when it loads a Linux binary (detected via ELF `EI_OSABI` / a marker / load path convention), else `NATIVE`.

`int 0x80` entry inspects the current process's personality:
- `NATIVE` → existing `SYS_*` table (unchanged).
- `LINUX` → new **Linux i386 syscall table** (number → handler), args in EBX/ECX/EDX/ESI/EDI/EBP, return in EAX as `-errno`.

This is additive and low-risk: existing native programs (Doom/Quake glue) keep working untouched.

### 4.2 Components
1. **Linux ELF loader** — `PT_INTERP` handling (load `ld-linux.so.2`), `PT_LOAD` mapping, **full auxv**, SysV i386 stack layout, personality tagging.
2. **Linux syscall table + dispatch** — number remapping onto existing handlers where possible; new handlers for gaps; 6-arg passing.
3. **Process/memory** — general per-process **mmap arena** (`mmap2`), `brk`, and **COW `fork`** (clone page tables, mark COW, handle write-fault split). Current seed: Linux `fork(2)` full-copies the parent VM into a child slot, keeps Linux personality/TLS metadata, clones inheritable process state, and pairs with `waitpid(7)`/`wait4(114)` for a single child. Grow process-slot model as needed.
4. **VFS layer** — directory iteration (`getdents64`), plus a **synthetic-filesystem layer** over FAT providing `/proc`, `/dev`, and **symlink emulation**.
5. **TTY subsystem** — termios line discipline (canonical/raw, echo), window size, foreground process group, Ctrl-C → SIGINT.
6. **Signals** — `rt_sigaction`/`rt_sigprocmask`/`rt_sigreturn` trampoline, delivery to foreground process group.
7. **TLS** — `set_thread_area` + GDT/LDT GS-base entry (i386 glibc requirement).

### 4.3 Userland artifacts (reused, not built)
Assembled into a **Linux-layout root filesystem image**:
- `/lib/ld-linux.so.2`, `/lib/libc.so.6` (32-bit glibc) — for M0+.
- A static **BusyBox** (i386) — M1a.
- **bash + GNU coreutils** (i386, dynamic) — M1b.
- Minimal `/etc`, `/proc` (synthetic), `/dev` (synthetic), `/bin`, `/usr`.

Licensing note: glibc (LGPL), bash/coreutils (GPL), BusyBox (GPL) — fine to ship; keep sources/offer per license. Keep images **out of git** per `AGENTS.md`.

---

## 5. The ABI Seam (data flow)

```
Linux i386 binary executes `int 0x80`
        │   EAX = syscall nr;  EBX,ECX,EDX,ESI,EDI,EBP = args (up to 6)
        ▼
vibe-os int-0x80 trap stub  →  read process personality flag
        │
        ├─ NATIVE → existing SYS_* dispatch  (unchanged)
        │
        └─ LINUX  → linux_syscall_table[EAX]
                      │  validate/translate args (pointers checked vs process address space)
                      ▼
                    handler  →  result or -errno in EAX
                      │
                      ▼
                    iret back to Ring 3
```

- **Arg cap:** lift `SYSCALL_MAX_ARGS` to 6 for the Linux path (frame already saves the regs).
- **Unimplemented syscall:** record the syscall number in guest status and return `-ENOSYS`. A larger debug profile can add a full trace ring; the current proof kernel keeps only `linux_last_unimpl_nr` to stay under the image cap.
- **Pointer safety:** all userspace pointers validated against the process's mapped regions before deref (reject kernel/unmapped → `-EFAULT`).

---

## 6. Milestone Designs

### M-1 — Static binary (the loader + stack + TLS proof)

**Target:** `musl-static` or `gcc -static` "hello world." No dynamic linker.

**New/needed:**
- **ELF32 loader:** parse `Elf32_Ehdr`/`Phdr`, map each `PT_LOAD` (respect flags → page perms), jump to `e_entry`.
- **SysV i386 initial stack** (byte-exact): 16-byte aligned, then `argc`, `argv[]`, NULL, `envp[]`, NULL, **auxv**, AT_NULL. Off-by-4 = instant crash.
- **auxv (minimum for static glibc/musl):** `AT_PHDR, AT_PHENT, AT_PHNUM, AT_PAGESZ, AT_ENTRY, AT_FLAGS, AT_UID/EUID/GID/EGID, AT_HWCAP (conservative), AT_CLKTCK, AT_SECURE=0, AT_RANDOM (16 real bytes), AT_EXECFN`. **Omit `AT_SYSINFO`/`AT_SYSINFO_EHDR`** → glibc falls back to `int 0x80` (no vDSO needed).
- **TLS:** `set_thread_area` (243) allocating a GDT entry, set GS base; without it glibc faults on first TLS access.
- **Grow limits:** `PATH_MAX`, `ARG_MAX`, env sizes to realistic values (e.g. PATH_MAX 4096, ARG/ENV pages).

**Syscalls (Linux i386 numbers):** `write(4)`, `writev(146)`, `exit_group(252)`/`exit(1)`, `brk(45)`, `mmap2(192)`, `mprotect(125)`, `munmap(91)`, `set_thread_area(243)`, `set_tid_address(258)`, `readlink(85)`/`readlinkat(305)` (for `/proc/self/exe`; may stub), `getrandom(355)` (or rely on AT_RANDOM), `ioctl(54)` `TCGETS` -> `-ENOTTY` ok, `rt_sigprocmask(175)`.

**Acceptance:** static hello prints "hello\n" to console; exit status observable (e.g. `exit(42)` reflected in a status field per `AGENTS.md` "guest status" preference).

---

### M0 — Dynamic glibc binary (the real personality seed)

**Target:** dynamically-linked **glibc** "hello world."

**New/needed over M-1:**
- **`PT_INTERP`:** loader maps the interpreter (`/lib/ld-linux.so.2`) as a second ELF at a chosen base; pass `AT_BASE` = that base; transfer control to ld.so, not the program.
- **Current seed:** the loader records `PT_INTERP` status/match for Zig-built dynamic glibc probes, maps `/LIB/LDLINUX.SO2` as the interpreter ELF at `USER_INTERP_BASE`, sets the exec entry to the interpreter entry, and wires `AT_BASE` to that base. With real Debian i386 `ld-linux.so.2` and `libc.so.6` installed as `/LIB/LDLINUX.SO2` and `/LIB/LIBC.SO6`, `LINUX_M0_LDSO_SMOKE` now runs through `ld.so`, stats/maps `libc.so.6`, prints `hello, glibc on vibe-os`, and returns the expected exit status `11`. A broader `libc_probe` also passes `strtol`, `snprintf`, `malloc`/`realloc`/`free`, `qsort`, `access`, raw `faccessat(307)` for `AT_FDCWD`, open/read/close of `/LIB/LIBC.SO6`, seed `getrlimit(76)`, `prlimit64(340)`, `set_robust_list(311)`, query-only `rt_sigaction(174)`, basic `futex(240)` wake plus nonblocking wait, `getpid`, `getenv`, `printf`, and `fflush`, printing `libc probe ok: noenv 42 pid=4` and exiting `13`.
- **Root FS** containing `/lib/ld-linux.so.2` + `/lib/libc.so.6` at the paths the binary names. **FAT-LFN** must store the dotted lowercase names; verify case handling (see §9).
- **`/etc/ld.so.cache` → `-ENOENT`** so ld.so falls back to default search paths.
- **File syscalls ld.so uses:** `openat(295)`/`open(5)`, `close(6)`, `read(3)`, `pread64(180)`, `_llseek(140)`, `fstat64(197)`/`stat64(195)`/`lstat64(196)`, `statx(383)`, `faccessat(307)`/`access(33)`, `mmap2` with file-backed `MAP_PRIVATE|MAP_FIXED` plus anonymous fixed zero-fill pages, `mprotect` (currently accepted as a no-op), `munmap`.
- **glibc init extras:** seed `set_robust_list(311)`, `prlimit64(340)`/`getrlimit(76)`/`ugetrlimit(191)`, query-only `rt_sigaction(174)`, and basic/uncontended `futex(240)` are now present. Real signal installation/delivery and blocking/contended futex behavior remain M1 work; `rseq(386)` -> `-ENOSYS` remains ok.

**Acceptance:** dynamic glibc hello runs end-to-end; ld.so resolves and relocates `libc.so.6`; a binary that calls a few libc fns (`printf`, `malloc`/`realloc`/`free`, `getpid`), basic file existence/read operations, and seed glibc-init syscalls behaves correctly. Current test binaries are compiled for plain i386/no-SSE; optimized glibc string/SSE paths remain a separate CPU-feature/FPU-context hardening item.

---

### M1 — Interactive shell + coreutils

Staged: **M1a static BusyBox**, then **M1b dynamic bash + GNU coreutils**.

**New subsystems (the real cost — not syscall count):**

1. **COW `fork`** — `fork(2)`/`clone(120)`(fork-flags): duplicate address space copy-on-write; write-fault handler splits shared pages. Plus `wait4(114)`/`waitpid(7)`, `execve(11)` post-fork, `exit_group`. Current seed: `/BIN/FORK.ELF` proves Linux `fork(2)` returns child PID to the parent and zero to the child, preserves parent/child memory divergence through a full-copy VM clone, and reaps the child through `waitpid`; `wait4` accepts `rusage=NULL`.
2. **TTY + line discipline** — `ioctl` termios: `TCGETS/TCSETS`, `TIOCGWINSZ`, `TIOCGPGRP/TIOCSPGRP`, `TIOCSCTTY`; canonical vs raw, echo, backspace; **generate SIGINT/SIGTSTP from keystrokes** to the foreground group.
3. **Signals (real)** — `rt_sigaction(174)`, `rt_sigprocmask(175)`, **`rt_sigreturn(173)`** (context-restore trampoline — corruption risk if wrong), `sigaltstack(186)`, `kill(37)`, `tgkill(270)`; deliver tty signals to fg process group.
4. **Process groups / sessions** — `setpgid(57)`, `getpgid(132)`, `setsid(66)`, `getsid(147)`.
5. **FD plumbing** — `pipe(42)`/`pipe2(331)`, `dup(41)`/`dup2(63)`/`dup3(330)`, `fcntl(55)` (F_DUPFD, F_GETFD/SETFD close-on-exec, F_GETFL/SETFL), `poll(168)`/`ppoll(309)`. Current seed: `/BIN/FD.ELF` proves `dup`, `dup2`, `dup3(O_CLOEXEC)`, `fcntl`/`fcntl64` `F_GETFD/F_SETFD/F_DUPFD/F_GETFL/F_SETFL`, and shared descriptor offsets on a FAT-backed file; `/BIN/PIPE.ELF` proves `pipe`, `pipe2(O_CLOEXEC)`, fixed-size in-kernel pipe buffering, and pipe read/write/close over the native FD model.
6. **VFS directories** — **`getdents64(220)`** (this is `ls`), `openat(O_DIRECTORY)`, `mkdirat(296)`, `unlinkat(301)`, `renameat2(353)`, `linkat(303)`, `symlinkat(304)`, `readlinkat(305)`, `chdir(12)`/`fchdir(133)`/`getcwd(183)`, `fchmodat(306)`, `fchownat(298)`, `utimensat(320)`, `ftruncate(93)`, `statfs(99)`. Current seed: `/BIN/DIR.ELF` proves `openat(AT_FDCWD, "/", O_DIRECTORY)`, `getdents64` finding `BIN`, then `openat("/BIN", O_DIRECTORY)` and `getdents64` finding `DIR.ELF`; `/BIN/CWDDIRFD.ELF` proves `chdir("/BIN")`, `getcwd`, cwd-relative `open`/`openat`/`stat64`, dirfd-relative `openat`/`fstatat64`, and negative relative misses, but does not exercise `fchdir`; BusyBox `ls /BIN` and root `ls /` are focused-smoke proven with exit `0`. Full M1 VFS remains open.
7. **`futex` (real)** — even single-threaded bash hits it on glibc stdio locks.
8. **Misc** — `uname(122)`, `sysinfo(116)`, `clock_gettime(265)`, `nanosleep(162)`/`clock_nanosleep(267)`, `getuid/geteuid/getgid/getegid`, `getrlimit/prlimit64`.

**Current BusyBox proof:** the static BusyBox slice now boots as a real Linux-personality guest, not a native shim. The rootfs hook installs `build/busybox-i386/busybox-vibe` as `/BIN/BUSYBOX.ELF` and `tests/linux/catok.txt` as `/ETC/CATOK.TXT`; the focused smoke selectors exec that path and stage Linux argv directly. `busybox echo busybox-ok`, `busybox true`, `busybox sh -c 'echo busybox-ok'`, `busybox ls /BIN`, `busybox ls /`, `busybox cat /ETC/CATOK.TXT`, `busybox cp /ETC/CATOK.TXT /CP.TXT`, `busybox grep ... /ETC/CATOK.TXT`, `busybox sleep 1`, and focused `busybox ps` exit `0` with `linux_last_unimpl_nr=0`. The cp smoke also checks that `/CP.TXT` exists in the post-run FAT image. The required/tolerated syscall surface for this proof includes the M-1 static-libc startup set (`brk(45)`, `mmap2(192)`, `mprotect(125)`, `munmap(91)`, `set_tid_address(258)`, `set_thread_area(243)`, `rt_sigprocmask(175)`, `ioctl(54)` returning `-ENOTTY`, `getrandom(355)`, `readlink(85)`, `readlinkat(305)`, `write(4)`, `writev(146)`, `exit(1)`, `exit_group(252)`) plus `getcwd(183)` for root and one-level FAT cwd, `chdir(12)` plus cwd/dirfd-relative `open`/`stat` in the focused cwd probe, `nanosleep(162)` over native sleep ticks, i386 `get*id32` aliases, `prctl(172)` as a no-op, `sched_getaffinity(242)` returning a single-CPU mask, and selector-gated synthetic `/proc` process data for the `ps` smoke. BusyBox `ash` is still not counted as the M1 shell: the proof is non-interactive and does not cover shell-composed pipes/redirection, tty, job control, or signals.

**Current Linux Doom proof:** a real Linux i386 Doom ELF now runs under the Linux personality. The binary is `tests/linux/linux_doom`, installed as `/BIN/LDOOM.ELF`, built with Zig `x86-linux-musl` from the original Linux Doom 1.10 C sources plus a headless Linux `I_*` platform layer. The guest command path is not the native app launcher and not syscall-renumbered native Doom. It opens the rootfs `/DOOM1.WAD` (public shareware asset, kept outside git; local proof SHA-1 `5b2e249b9c5133ec987b3ea77596381dc0d6bc1d`), initializes WAD data, textures/flats/sprites/colormaps, playloop, HUD and status bar, then prints `ldoom frame=1 checksum=983fe686 nonzero=304` and exits `0`. The proof required adding Linux i386 `lseek(19)` alongside `_llseek(140)` and accepting non-fixed anonymous `mmap2` address hints. The headless platform layer also provides tiny C-locale formatting/string shims so original Doom path/lump-name code avoids host stdio assumptions; general terminal/video/audio/input and full Linux libc behavior remain unsupported.

**Latest Chromium smoke note:** parent evidence after the `0x77000` status-capture move, argv/status instrumentation, and live process-state reporting supersedes older Chromium notes: current artifacts reach `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, handle 1739 (`0x6CB`) demand pages for the real browser ELF through last demand address `0x083D7000`, reach 945 Linux syscalls, report latest captured Linux error `rseq(386) -> -ENOSYS`, and show process state `RUNNING` with `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. This is browser-owned userland still running beyond ld.so/libc startup names, not a rendered UI. The older `1250`/`0x082DB000`, `setsockopt`, clone, and #UD details remain useful historical context, not the current boundary until revalidated.

Packaging note: a separate wrapper run hit exit status `127` from an incorrect no-version `libnspr4.so` alias; the isolated proof used the correct `/LIB/NSPR4.SO` alias, so that wrapper error is packaging noise rather than the current OS boundary.

**Current Chromium proof boundary:** the first "real browser" probe uses the current available Debian sid i386 Chromium binary package (`chromium_148.0.7778.178-1_i386.deb`) and packages `/usr/lib/chromium/chromium` as `/BIN/CHROMIUM.ELF` in the FAT image, with matching `chromium-common` ICU data installed as `/BIN/ICUDTL.DAT`. The image builder and stage2 FAT geometry were lifted to a 512 MiB image with 16-sector FAT clusters so the 262608780-byte ELF can exist in the guest rootfs. The smoke selector `LINUX_M1_CHROMIUM_SMOKE` execs `/BIN/CHROMIUM.ELF` through the Linux personality with Debian sid i386 `libc6_2.42-16_i386.deb` providing `/LIB/LDLINUX.SO2` and `/LIB/LIBC.SO6`, plus 101 recursive real sid i386 `NEEDED` shared libraries under `/LIB` aliases and the tiny `/tmp`, `/dev/null`, and `/proc/self/exe` hooks. Current parent `m1live` evidence records `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, interpreter and sparse-main-ELF setup, large-ELF demand paging, 1739 (`0x6CB`) handled demand pages, last demand address `0x083D7000`, 945 Linux syscalls, latest captured Linux error `rseq(386) -> -ENOSYS`, process state `RUNNING`, `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. The earlier Crashpad `setsockopt`, fork-like `clone`, and contained #UD evidence must be re-reached under live-status evidence before being treated as current.

Current parent correction: the newest Chromium evidence after the status-buffer move, path-probe work, and `m1live` process-state reporting keeps `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, interpreter/sparse-mapping evidence from the same current status, and handled demand paging as current, now at 1739 (`0x6CB`) pages with last demand address `0x083D7000`. Do not treat the separate wrapper exit `127` around `/usr/lib/.../libnspr4.so` as the OS boundary; that run had bad no-version alias packaging, while helper-generated isolated assets map `libnspr4.so` through the `/LIB/NSPR4.SO` alias family. The current isolated proof boundary is the `RUNNING` Chromium process-state with 945 syscalls and latest captured Linux error `rseq(386) -> -ENOSYS`; socket/clone/#UD details are historical until revalidated. Seed a PROCID/identity-session check next so future runs can prove status continuity for the same browser process.

**Synthetic filesystems (now mandatory):**
- **procfs:** `/proc/self/{exe,fd/*,maps,status,stat,cmdline,environ}`, `/proc/{meminfo,cpuinfo,stat}`, `/proc/self/mounts`, `/proc/filesystems`. Generated on read from live kernel state.
- **devfs:** `/dev/{null,zero,tty,console,random,urandom}` + `stdin/stdout/stderr` symlinks → `/proc/self/fd/{0,1,2}`.
- **Symlink emulation** layered over FAT (FAT has no native symlinks).

**Acceptance:** boot into an interactive prompt where you can `cd` a real directory tree, run `ls | grep foo > out.txt` (pipes + redirection), `cat out.txt`, `cp`/`ps`, **and Ctrl-C a running `sleep`** (proves tty→signal→process-group routing).

---

## 7. Testing Strategy

**Primary tool:** build guest-visible syscall/status proof first. The current proof kernel records `linux_last_unimpl_nr`; a fuller trace ring belongs behind a debug flag or larger-kernel profile.

**Dev loop (strace-style):** run the next binary -> it dies on an unimplemented/ABI-wrong syscall -> guest status shows the next syscall or fault -> implement it -> repeat. (This is the same pressure-tested loop used by compatibility layers such as WSL1 and gVisor.)

**Test corpus, ordered = acceptance gates:**
1. `hand-asm` static binary that only `write`s + `exit`s (validates loader/stack before any libc).
2. A tiny static binary that dumps its own **auxv** to console (validates auxv before ld.so depends on it).
3. A startup-syscall probe that calls the static-libc syscall batch directly.
4. An exec-limits probe that crosses the old argv/env/string caps from inside the guest.
5. **musl-static hello** (M-1).
6. **glibc-dynamic hello** + `libc_probe` for `printf`, heap allocation, `getpid`, formatted output, `faccessat`, and file read (M0).
7. **directory probe** using raw `openat(O_DIRECTORY)` + `getdents64` before real `ls` (M1a seed).
8. **FD plumbing probe** using raw `dup`/`dup2`/`dup3` + `fcntl`/`fcntl64` before pipes/redirection (M1a seed).
9. **Pipe probe** using raw `pipe`/`pipe2` plus read/write/close before shell pipe syntax (M1a seed).
10. **Fork/wait probe** using raw `fork`, parent/child memory divergence, `waitpid`, and Linux wait-status encoding before BusyBox `ash` relies on process control (M1a seed).
11. **BusyBox** applets: current proof covers `busybox echo busybox-ok`, `busybox true`, non-interactive `busybox sh -c 'echo busybox-ok'`, `busybox ls /BIN`, `busybox ls /`, `busybox cat`, `busybox cp`, `busybox grep`, `busybox sleep`, and focused `busybox ps` from `/BIN/BUSYBOX.ELF` under the Linux personality; next targets are shell-composed pipes/redirection, interactive shell, generic procfs/devfs, tty, and signal gaps.
12. **Linux Doom headless proof** from `/BIN/LDOOM.ELF`: current proof reaches a nonblank Doom frame from the real shareware WAD under the Linux personality, with no fault/panic/shutdown and no unexpected final `-ENOSYS`.
13. **Current Chromium pressure probe** from `/BIN/CHROMIUM.ELF`: current proof packages the real Debian i386 Chromium browser ELF plus matching `/BIN/ICUDTL.DAT`, recognizes `ET_DYN`, 12 program headers, 4 `PT_LOAD`s, and `/lib/ld-linux.so.2`, applies a documented `0x08000000` ET_DYN load bias, sparse-maps the first page of each load, pre-maps the main ELF `PT_DYNAMIC` page, runs real `/LIB/LDLINUX.SO2`, stages `argc=0000000B`, and handles browser file-backed demand pages. The fresh parent `m1live` status records `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, 1739 (`0x6CB`) handled demand pages, last demand address `0x083D7000`, 945 Linux syscalls, latest captured Linux error `rseq(386) -> -ENOSYS`, process state `RUNNING`, `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. This is not an M1 acceptance gate or a UI claim; it is a browser-sized loader/address-space/userland-startup pressure proof. The older `1250`/`0x082DB000`, socket-option, fork-like clone, and #UD observations need fresh revalidation.
   Packaging note: a separate wrapper run hit exit status `127` from an incorrect no-version `libnspr4.so` alias; do not treat that packaging error as the current OS boundary.
14. **bash + coreutils** + a small shell script with pipes/redirection/`cd` (M1b).

**Regression harness:** the corpus runs on boot (or a QEMU smoke target — local QEMU allowed per `AGENTS.md`), comparing output + exit status to expected. Surface pass/fail via **guest status fields** (preferred over host inference, per `AGENTS.md`).

---

## 8. Failure Modes & Mitigations

| Failure | Symptom | Mitigation |
|---|---|---|
| auxv wrong/incomplete | ld.so/glibc crashes before first syscall, no message | Test #2 (auxv-dump binary) before any dynamic work |
| Stack layout off-by-N | immediate segfault at `_start` | Test #1 hand-asm binary; assert 16-byte alignment |
| TLS/GS not set | fault on glibc's first instruction | Isolate `set_thread_area` test; verify GS base read-back |
| COW fork bug | memory corruption across fork | Keep `/BIN/FORK.ELF` as the full-copy baseline, then add targeted COW write-after-fork patterns before enabling shared pages |
| `rt_sigreturn` trampoline wrong | stack corruption after a handler returns | Handler that mutates state + returns; verify caller resumes intact |
| FAT case/LFN mismatch | ld.so can't find `libc.so.6` | Verify LFN read of dotted lowercase names early in M0 |
| Pointer not validated | kernel reads bad userspace ptr | Validate every user ptr vs mapped regions → `-EFAULT` |

---

## 9. Risks & Open Questions

- ⚠️ **HEADLINE: official Chrome still wants 64-bit, but current i386 Chromium is a useful pressure probe.** vibe-os is `bits 32`. Official Google Chrome for Linux is not the same target as Debian's i386 Chromium package; the former still drives a long-mode/x86-64 milestone, while the latter currently gives this 32-bit Linux personality a real browser-sized ELF to push against. The current-Chromium proof gets past the old whole-file size reject, dynamic-table/PTE hazards, and missing-library loop enough to exec the browser ELF as `/BIN/CHROMIUM.ELF`, stage `argc=0000000B`, load real ld-linux, sparse-map the huge PIE, protect the main ELF dynamic page from interpreter staging overwrite, and keep the browser-owned process `RUNNING` after 1739 (`0x6CB`) handled demand pages through last demand address `0x083D7000`, 945 syscalls, and latest captured Linux error `rseq(386) -> -ENOSYS`, with `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. It still does not render a browser UI, and the older `1250`/`0x082DB000`, socket/clone/#UD notes remain historical until re-reached. **Recommendation:** keep M-1→M1 on 32-bit to build the personality machinery, use current Debian i386 Chromium as a pressure probe, and track a long-mode port as its own major milestone for official Chrome and modern browser endgame work.
  Packaging note: a separate wrapper run hit exit status `127` from an incorrect no-version `libnspr4.so` alias; do not treat that packaging error as the current OS boundary.
- **Process model is fixed (6 slots).** Real shells fork freely. Need dynamic process allocation (or a much larger, recyclable slot pool) and a general per-process mmap arena beyond today's fixed windows.
- **FAT limitations:** no symlinks, case-insensitive, LFN quirks. The synthetic-FS + symlink-emulation layer must sit above FAT; verify LFN early.
- **glibc version pinning:** the current local proof uses Debian bookworm i386 `libc6`; formal M0 should pin that artifact/version and keep confirming whether new targets use `statx` vs the `stat64` family.
- **musl as a stepping stone:** musl-static (M-1) has a much smaller, simpler syscall + TLS surface than glibc — recommended as the *first* binary even though glibc is the real target (Chrome needs glibc).
- **Assembly-first mandate (`AGENTS.md`):** personality is kernel-resident → assembly preferred; keep any C modest (e.g. only if a syscall table or struct-marshalling gets unwieldy), and **no Python** anywhere in the toolchain.
- **vDSO deferred:** safe to omit now (glibc falls back to `int 0x80`); revisit for performance later.

---

## 10. Roadmap Beyond This Spec (context, each its own spec)

```
M-1  static binary            ── this spec
M0   dynamic glibc binary     ── this spec
M1   shell + coreutils        ── this spec
─────────────────────────────────────────
M2   threads + concurrency    clone(CLONE_VM), full futex, robust lists, epoll/eventfd/signalfd, poll
M3   networking               socketcall/sockets, DNS, TCP — gateway to anything online
M4   display + input           framebuffer/DRM or fbdev, evdev-style input, the Xbox gamepad
M5   64-bit / long-mode port   ⚠️ prerequisite for official Chrome (see §9) — likely parallel-tracked
M6   web engine               Chrome on Ozone/DRM (leaner) OR WebKitGTK+GTK (drags in GTK)
M7   WebGPU                    Dawn-on-SwiftShader (software) or a real GPU driver
M8   StemStudio loads         the original goal
```

---

## 11. Decisions (defaults chosen)

- **Target Linux i386 ABI** on the existing 32-bit kernel for M-1→M1; long-mode port tracked separately (§9).
- **Additive dual personality**, per-process flag, selected at exec.
- **glibc is the end target**, but **musl-static is the first stepping stone** (M-1).
- **Build guest-visible syscall/status proof first** — it is the primary dev tool; expand to a trace ring only when the image budget allows it.
- **Assembly-first** implementation per `AGENTS.md`; C only where it keeps the surface small; no Python.
- Root-fs images and WADs/blobs stay **out of git**.
