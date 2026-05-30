# vibe-os Linux Binary-Compatibility Personality — Design Spec

**Date:** 2026-05-29
**Status:** Draft for review
**Scope of this spec:** Milestones M-1 → M1 (run unmodified Linux i386 ELF binaries, from a static hello-world up to an interactive shell + coreutils).
**Out of scope (roadmap only):** threads, networking, display/GPU, web engine, WebGPU, StemStudio, 64-bit.

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
| **auxv at exec** | builds AT_PAGESZ, AT_ENTRY, AT_NULL only | Scaffolding exists; missing the entries ld.so/glibc require. |
| **Paging / address spaces** | per-process page dir, CR3 switching (`KERNEL_RELOC_ABI_LIVE_CR3_SWITCH`) | Per-process VM exists — basis for COW fork. |
| **Process model** | **fixed 6 slots** (`PROCESS_SLOT_COUNT equ 6`), 184-byte records, per-proc brk + heap bitmap | Works, but fixed/small — see §9. |
| **User memory** | fixed payload window (load `0x01000000`), fixed heap/stack windows, brk + mmap regions w/ VM object model | Real but rigid; Linux needs a general mmap arena. |
| **Filesystem** | FAT with VFS ABI (open/read/write/lseek/stat/fstat), root+table caches | Files work; **no symlinks, no real dir iteration, 8.3/LFN, case-insensitive** — see §9. |
| **TLS (GS/set_thread_area)** | **absent** | Must add — glibc i386 requires GS-based TLS. |
| **Limits** | `PATH_MAX 64`, `ARG_MAX 8`, `ARG_STR_MAX 64`, `ENV_MAX 8` | Far too small for real programs — must grow. |
| **Conventions** | assembly-first, C modest, **no Python** (`AGENTS.md`) | Personality is kernel work → assembly-first. |

**Takeaway:** vibe-os is unusually well-positioned — its native ABI is already `int 0x80` + negative-errno + a near-POSIX call set. The personality is mostly *number remapping, ABI-exactness, and gap-filling*, not greenfield.

---

## 3. Goals & Non-Goals

### Goals (this spec)
- Run **unmodified Linux i386 ELF binaries** under a Linux personality.
- **M-1:** statically-linked binary (musl-static / `gcc -static`) prints and exits with correct status.
- **M0:** dynamically-linked **glibc** binary runs (dynamic linker + TLS + full auxv).
- **M1:** interactive shell + coreutils — `cd`, pipes, redirection, Ctrl-C interrupt, `ls`/`cat`/`cp`/`ps`.
- Build an **in-kernel syscall tracer** ("vibe-strace") as the primary dev tool.
- `strace`-driven development loop as the working method.

### Non-Goals (deferred to roadmap §10)
- Threads beyond `fork` (clone-with-CLONE_VM, full futex contention, robust lists under contention).
- `epoll`/`eventfd`/`signalfd`, networking/sockets (`socketcall`).
- Display server, framebuffer GUI, input beyond tty, GPU, WebGPU.
- Web engine (Chrome/WebKitGTK), Tauri, StemStudio.
- **64-bit / long mode** (prerequisite for Chrome — see §9).
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
3. **Process/memory** — general per-process **mmap arena** (`mmap2`), `brk`, and **COW `fork`** (clone page tables, mark COW, handle write-fault split). Grow process-slot model as needed.
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
- **Unimplemented syscall:** log `(nr, args, caller EIP)` via the tracer, return `-ENOSYS`. A dev "strict mode" panics instead — this is how we discover the next syscall to implement.
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

**Syscalls (Linux i386 numbers):** `write(4)`, `exit_group(252)`/`exit(1)`, `brk(45)`, `mmap2(192)`, `mprotect(125)`, `munmap(91)`, `set_thread_area(243)`, `set_tid_address(258)`, `readlink(85)`/`readlinkat(305)` (for `/proc/self/exe`; may stub), `getrandom(355)` (or rely on AT_RANDOM), `ioctl(54)` `TCGETS` → `-ENOTTY` ok, `rt_sigprocmask(175)`.

**Acceptance:** static hello prints "hello\n" to console; exit status observable (e.g. `exit(42)` reflected in a status field per `AGENTS.md` "guest status" preference).

---

### M0 — Dynamic glibc binary (the real personality seed)

**Target:** dynamically-linked **glibc** "hello world."

**New/needed over M-1:**
- **`PT_INTERP`:** loader maps the interpreter (`/lib/ld-linux.so.2`) as a second ELF at a chosen base; pass `AT_BASE` = that base; transfer control to ld.so, not the program.
- **Root FS** containing `/lib/ld-linux.so.2` + `/lib/libc.so.6` at the paths the binary names. **FAT-LFN** must store the dotted lowercase names; verify case handling (see §9).
- **`/etc/ld.so.cache` → `-ENOENT`** so ld.so falls back to default search paths.
- **File syscalls ld.so uses:** `openat(295)`/`open(5)`, `close(6)`, `read(3)`, `pread64(180)`, `_llseek(140)`, `fstat64(197)`/`stat64(195)`/`lstat64(196)` (or `statx(383)`), `faccessat(307)`/`access(33)`, `mmap2` with `MAP_PRIVATE|MAP_FIXED`, `mprotect` (RELRO), `munmap`.
- **glibc init extras:** `set_robust_list(311)`, `prlimit64(340)`/`getrlimit`, `rt_sigaction(174)`, `futex(240)` (basic, uncontended), `rseq(386)` → `-ENOSYS` ok.

**Acceptance:** dynamic glibc hello runs end-to-end; ld.so resolves and relocates `libc.so.6`; a binary that calls a few libc fns (printf, malloc, getpid) behaves correctly.

---

### M1 — Interactive shell + coreutils

Staged: **M1a static BusyBox**, then **M1b dynamic bash + GNU coreutils**.

**New subsystems (the real cost — not syscall count):**

1. **COW `fork`** — `fork(2)`/`clone(120)`(fork-flags): duplicate address space copy-on-write; write-fault handler splits shared pages. Plus `wait4(114)`/`waitpid(7)`, `execve(11)` post-fork, `exit_group`.
2. **TTY + line discipline** — `ioctl` termios: `TCGETS/TCSETS`, `TIOCGWINSZ`, `TIOCGPGRP/TIOCSPGRP`, `TIOCSCTTY`; canonical vs raw, echo, backspace; **generate SIGINT/SIGTSTP from keystrokes** to the foreground group.
3. **Signals (real)** — `rt_sigaction(174)`, `rt_sigprocmask(175)`, **`rt_sigreturn(173)`** (context-restore trampoline — corruption risk if wrong), `sigaltstack(186)`, `kill(37)`, `tgkill(270)`; deliver tty signals to fg process group.
4. **Process groups / sessions** — `setpgid(57)`, `getpgid(132)`, `setsid(66)`, `getsid(147)`.
5. **FD plumbing** — `pipe(42)`/`pipe2(331)`, `dup(41)`/`dup2(63)`/`dup3(330)`, `fcntl(55)` (F_DUPFD, F_GETFD/SETFD close-on-exec, F_GETFL/SETFL), `poll(168)`/`ppoll(309)`.
6. **VFS directories** — **`getdents64(220)`** (this is `ls`), `openat(O_DIRECTORY)`, `mkdirat(296)`, `unlinkat(301)`, `renameat2(353)`, `linkat(303)`, `symlinkat(304)`, `readlinkat(305)`, `chdir(12)`/`fchdir(133)`/`getcwd(183)`, `fchmodat(306)`, `fchownat(298)`, `utimensat(320)`, `ftruncate(93)`, `statfs(99)`.
7. **`futex` (real)** — even single-threaded bash hits it on glibc stdio locks.
8. **Misc** — `uname(122)`, `sysinfo(116)`, `clock_gettime(265)`, `nanosleep(162)`/`clock_nanosleep(267)`, `getuid/geteuid/getgid/getegid`, `getrlimit/prlimit64`.

**Synthetic filesystems (now mandatory):**
- **procfs:** `/proc/self/{exe,fd/*,maps,status,stat,cmdline,environ}`, `/proc/{meminfo,cpuinfo,stat}`, `/proc/self/mounts`, `/proc/filesystems`. Generated on read from live kernel state.
- **devfs:** `/dev/{null,zero,tty,console,random,urandom}` + `stdin/stdout/stderr` symlinks → `/proc/self/fd/{0,1,2}`.
- **Symlink emulation** layered over FAT (FAT has no native symlinks).

**Acceptance:** boot into an interactive prompt where you can `cd` a real directory tree, run `ls | grep foo > out.txt` (pipes + redirection), `cat out.txt`, `cp`/`ps`, **and Ctrl-C a running `sleep`** (proves tty→signal→process-group routing).

---

## 7. Testing Strategy

**Primary tool:** build an **in-kernel syscall tracer first** — logs `(nr, name, args, ret, caller EIP)` for the Linux personality. This *is* the debugger for the whole project.

**Dev loop (strace-driven):** run the next binary → it dies on an unimplemented/abi-wrong syscall → the tracer shows which → implement it → repeat. (Exactly how WSL1 and gVisor were built.)

**Test corpus, ordered = acceptance gates:**
1. `hand-asm` static binary that only `write`s + `exit`s (validates loader/stack before any libc).
2. A tiny static binary that dumps its own **auxv** to console (validates auxv before ld.so depends on it).
3. **musl-static hello** (M-1).
4. **glibc-dynamic hello** + a libc-exercising binary (M0).
5. **BusyBox** applets: `echo`, `ls`, `cat`, `cp`, `grep`, `ash` interactive (M1a).
6. **bash + coreutils** + a small shell script with pipes/redirection/`cd` (M1b).

**Regression harness:** the corpus runs on boot (or a QEMU smoke target — local QEMU allowed per `AGENTS.md`), comparing output + exit status to expected. Surface pass/fail via **guest status fields** (preferred over host inference, per `AGENTS.md`).

---

## 8. Failure Modes & Mitigations

| Failure | Symptom | Mitigation |
|---|---|---|
| auxv wrong/incomplete | ld.so/glibc crashes before first syscall, no message | Test #2 (auxv-dump binary) before any dynamic work |
| Stack layout off-by-N | immediate segfault at `_start` | Test #1 hand-asm binary; assert 16-byte alignment |
| TLS/GS not set | fault on glibc's first instruction | Isolate `set_thread_area` test; verify GS base read-back |
| COW fork bug | memory corruption across fork | Targeted write-after-fork test patterns; parent/child divergence checks |
| `rt_sigreturn` trampoline wrong | stack corruption after a handler returns | Handler that mutates state + returns; verify caller resumes intact |
| FAT case/LFN mismatch | ld.so can't find `libc.so.6` | Verify LFN read of dotted lowercase names early in M0 |
| Pointer not validated | kernel reads bad userspace ptr | Validate every user ptr vs mapped regions → `-EFAULT` |

---

## 9. Risks & Open Questions

- ⚠️ **HEADLINE: 32-bit blocks the north star.** vibe-os is `bits 32`. **Modern Chrome/Chromium is x86-64-only on Linux** (32-bit Linux builds were dropped years ago). So **M-1→M1 are fully achievable on 32-bit**, but the *web-engine endgame* (Chrome → StemStudio) **requires a 64-bit / long-mode kernel port** — likely the single largest item in the whole campaign, and a prerequisite that must be decided early. Tauri/WebKitGTK is theoretically 32-bit-buildable but impractical and still needs the full GTK stack. **Recommendation:** treat a long-mode port as its own major milestone before any web-engine work; do M-1→M1 on 32-bit now to build the personality machinery, knowing the syscall *table* largely ports to x86-64 later (entry mechanism and a few ABIs change: `syscall` insn + MSR_LSTAR instead of `int 0x80`, `arch_prctl` instead of `set_thread_area`, different numbers).
- **Process model is fixed (6 slots).** Real shells fork freely. Need dynamic process allocation (or a much larger, recyclable slot pool) and a general per-process mmap arena beyond today's fixed windows.
- **FAT limitations:** no symlinks, case-insensitive, LFN quirks. The synthetic-FS + symlink-emulation layer must sit above FAT; verify LFN early.
- **glibc version pinning:** choose a specific 32-bit glibc; confirm whether it uses `statx` vs `stat64` family on the target so we implement the right ones first.
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
M5   64-bit / long-mode port   ⚠️ prerequisite for Chrome (see §9) — likely parallel-tracked
M6   web engine               Chrome on Ozone/DRM (leaner) OR WebKitGTK+GTK (drags in GTK)
M7   WebGPU                    Dawn-on-SwiftShader (software) or a real GPU driver
M8   StemStudio loads         the original goal
```

---

## 11. Decisions (defaults chosen)

- **Target Linux i386 ABI** on the existing 32-bit kernel for M-1→M1; long-mode port tracked separately (§9).
- **Additive dual personality**, per-process flag, selected at exec.
- **glibc is the end target**, but **musl-static is the first stepping stone** (M-1).
- **Build the in-kernel syscall tracer first** — it's the primary dev tool.
- **Assembly-first** implementation per `AGENTS.md`; C only where it keeps the surface small; no Python.
- Root-fs images and WADs/blobs stay **out of git**.
