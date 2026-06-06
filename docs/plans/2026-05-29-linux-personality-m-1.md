# Linux Personality M-1 Implementation Plan — Run a Static Linux i386 Binary

> **Finish proof update (2026-06-06):** the `clone3` vfork-style stack contract is now fixed by preserving the validated `clone3` stack range as the shared-VM child stack bounds; focused QEMU proof prints `clone3 ok`, records two waitpid wakeups, exits `49`, and keeps `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. The latest Chromium pressure run stages recursive sid i386 libraries plus Chromium resource aliases, intentionally omits the optional crashpad sidecar so final status remains browser-owned, and records `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000C`, `largedem=0000144C/.../02D80110/...`, `linuxsys=00000488/00000078/FFFFFFEA/...`, `m1live` RUNNING status, `faultsrc=NONE`, `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`. The current browser boundary is now `clone(120) -> -EINVAL`, not the older `1739/rseq` note below, and still not a browser UI claim.

> **Current branch status:** Tasks 1-3 have landed on `feat/linux-personality-m-1`: `edda888` adds the Linux `-ENOSYS` default proof state, `bb84f67` adds the per-process personality flag and dispatch branch, and `f8cd8a0` adds the `hello_write` test-binary/rootfs scaffold. The current worktree extends that scaffold with `auxv_dump`, `tls_probe`, `startup_probe`, `exec_limits_probe`, `dir_probe`, `fd_probe`, `pipe_probe`, `fork_probe`, and a Zig-built static musl `hello_musl` acceptance binary. Flagged QEMU runs have proved `/BIN/HELLO.ELF`, `/BIN/AUXV.ELF`, `/BIN/TLS.ELF`, `/BIN/STARTUP.ELF`, `/BIN/XLIMIT.ELF`, `/BIN/DIR.ELF`, `/BIN/FD.ELF`, `/BIN/PIPE.ELF`, `/BIN/FORK.ELF` (`fork ok`, full-copy `fork`/`waitpid`, exit `21`), and `/BIN/MUSL.ELF`. M0 dynamic glibc is also green: `hello_glibc` prints `hello, glibc on vibe-os` and exits `11`, while `libc_probe` prints `libc probe ok: noenv 42 pid=4` and exits `13`; `rseq(386)` still returns the tolerated `-ENOSYS`. M1a BusyBox is real guest proof: `/BIN/BUSYBOX.ELF` runs `busybox echo busybox-ok` and `busybox true` with exit `0`; `busybox sh -c 'echo busybox-ok'` still exits `1` with `sh: out of memory`, so `ash` is not yet accepted. The Linux personality also has a static i386 Linux Doom proof from `/BIN/LDOOM.ELF` with the external shareware WAD, reaching `ldoom frame=1 checksum=983fe686 nonzero=304` and exit `0`.
>
> The current browser pressure probe packages the current available Debian sid i386 Chromium 148.0.7778.178-1 binary as `/BIN/CHROMIUM.ELF`, matching `chromium-common` ICU data as `/BIN/ICUDTL.DAT`, sid `libc6_2.42-16_i386.deb`, and the 101 recursive real sid i386 `NEEDED` shared libraries under `/LIB` aliases. The latest parent QEMU run after tiny path and identity-session probes, with `-m 256M -cpu qemu32,+sse,+sse2`, records `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, `m1live` status, 1739 handled demand pages (`0x6CB`), last demand address `0x083D7000`, 945 Linux syscalls, and process state `RUNNING`. The latest Linux error is the tolerated optional `rseq(386) -> -ENOSYS`; the PROCID probe and identity-session seed are in place. This is browser-owned userland startup beyond ld.so/libc naming the next missing capability, not a rendered browser UI.

> **Chromium update (2026-05-31):** the browser pressure probe now stages the real sid i386 dependency chain plus Chromium ICU data far enough to exec the browser PIE, stage 11 argv entries, match `/lib/ld-linux.so.2`, load real sid `/LIB/LDLINUX.SO2`, and keep Chromium running into browser-owned startup beyond ld.so/libc under `PERSONALITY_LINUX`. The smoke-status capture moved from `0x40000` to `0x77000` after the old location was found to overlap the live GDT/TSS/IDT area, so fresh browser proof must be based on the relocated buffer. The kernel still contains synthetic Linux library dirs, libc/ld-linux/GLib/GObject/GIO/HarfBuzz-subset aliases, synthetic-dir relative `openat`, recognized optional `rseq(386)`, `-ENOENT` for absent absolute Linux paths such as `/etc/ld.so.cache`, file-backed demand paging, present-PTE `mprotect` updates, SSE/FPU context save/restore, `clock_gettime`, `uname`, `gettid`, pipe-backed `socketpair`, `setsockopt(SOL_SOCKET, SO_PASSCRED)`, and fork-like `clone(120)` support. The latest honest proof is `m1live`: 1739 handled demand pages (`0x6CB`), last demand address `0x083D7000`, 945 Linux syscalls, process state `RUNNING`, and latest error `rseq(386) -> -ENOSYS`. This is still not a UI proof; it names the next missing capability from live Chromium startup, with PROCID/identity-session seed work now in place.

> **Chromium packaging note (2026-05-31):** one wrapper smoke hit exit status `127` from a bad no-version library alias for `libnspr4.so`. The isolated disk image used the correct `/LIB/NSPR4.SO` alias family and did not reproduce that missing-library serial error, so that wrapper run is packaging noise rather than the current OS boundary.
>
> **Chromium resource staging note (2026-05-31):** `tools/chromium_i386_smoke_assets.sh` remains conservative by default: it stages `/BIN/CHROMIUM.ELF`, `/BIN/ICUDTL.DAT`, and the recursive ELF dependency chain only. When the next kernel path-alias work is ready to look past ld.so into Chromium resource opens, the helper can be run with `--include-resources` or `CHROMIUM_I386_INCLUDE_RESOURCES=1` to add ignored package resources under short `/CHROMIUM/*.PAK` and `/CHROMIUM/*.BIN` aliases, plus `/CHROMIUM/CRASHPAD.ELF` when the handler is present. These are guest-staging aliases for future path mapping, not a browser UI claim.

> **Tiny browser path probes (2026-05-31):** `/tmp` and `/tmp/chromium-profile` now reuse the existing synthetic-directory path for `stat/statx`, `access/faccessat`, and `open/openat(O_DIRECTORY)`. `/dev/null` has exact Linux `open/openat`, `read`, `write`, and `fstat64` coverage, and `/proc/self/exe` has exact `readlink/readlinkat` coverage. Focused parent QEMU smokes proved `/BIN/TMPDIR.ELF` (`tmpdir ok`, exit `23`), `/BIN/DEVNULL.ELF` (`devnull ok`, exit `23`), and `/BIN/PROCEXE.ELF` (`proc self exe ok`, exit `25`) with `panic=NONE`, `shutdown=NONE`, and `pmmchk=OK`; they are startup probes, not claims of tmpfs, devfs, or procfs generality.

> **Event-loop FD seed (2026-05-31):** the Linux personality now handles `eventfd/eventfd2`, `epoll_create/ctl/wait/create1`, and `timerfd_create/settime/gettime` with small in-kernel FD kinds aimed at Chromium startup. This removes the immediate event-loop syscall frontier; it is readiness/timer seed behavior, not a complete Linux epoll or timer subsystem.
>
> **Chromium FD/path hardening note (2026-05-31):** Linux `writev(146)` now covers stdout/stderr, exact `/dev/null` descriptors, and the existing pipe write end; pipe `fstat64/statx` reports a FIFO mode. Exact `/proc/self/exe` now participates in `access`, `stat64/statx`, and readonly `open/openat`, while relative `faccessat/fstatat64/statx` is accepted only for the existing synthetic directory FD path.

**Goal:** Make vibe-os load and run an *unmodified, statically-linked* Linux i386 ELF binary that writes to stdout and exits with a correct status code.

**Architecture:** Add a per-process **personality flag** to the existing process record. The `int 0x80` dispatcher (currently a `cmp eax, SYS_*` chain at `kernel/kernel.asm:22429`) branches to a **separate Linux i386 syscall path** when the flag is `LINUX`; native programs (Doom/Quake) are untouched. A new **Linux ELF32 loader** maps `PT_LOAD` segments and builds a SysV-i386 initial stack (argc/argv/envp + minimal auxv). The current proof kernel keeps a compact `linux_last_unimpl_nr` status field rather than a full trace ring, and the BIOS boot path now reads a 448-sector kernel window (229376 bytes) with the temporary ELF load buffer at `0x68000` so the whole staging window stays below VGA memory; the smoke status window is 32 KiB at `0x77000`, and the PMM frame map lives at `0x50000` so low kernel stacks/page tables and frame accounting stay separated.

**Tech Stack:** NASM (`bits 32`), the existing single-file kernel `kernel/kernel.asm`, the repo-owned `build/link_elf32` linker for hand-written i386 test binaries, Zig for the static musl acceptance binary, FAT disk image for the guest filesystem, and QEMU for local boot proof. Static glibc still needs a separate Linux i386 static glibc toolchain. **No Python** (per `AGENTS.md`). Assembly-first; C only if a surface stays tiny.

---

## Conventions for this plan (read first)

- **"Test" in an OS kernel = a guest binary + expected serial/guest-status output, run in QEMU.** There is no pytest. Each task's acceptance is: build a tiny i386 binary, place it on the FAT image, boot vibe-os in QEMU, and confirm the expected console output and/or a **guest status field** (the `AGENTS.md`-preferred proof mechanism — emit results from the OS itself, don't infer host-side).
- **Asm shown for *new, self-contained* logic is literal** (equates, the personality flag, the dispatch branch, auxv entries, the GDT TLS entry, test binaries). Asm for *bodies that extend existing deep routines* is given as precise structure that **must follow the conventions of the cited anchor routine** (register save/restore via `pushad`/`popad`, `clc`/`stc` success/failure, `PROC_*` field offsets). Always open the anchor and mirror it.
- **Linux i386 ABI reminder:** entry `int 0x80`; syscall number in `EAX`; args in `EBX, ECX, EDX, ESI, EDI, EBP` (up to 6); return value in `EAX` as a result or `-errno`. vibe-os already uses `int 0x80` + negative-errno (`SYSCALL_RESULT_NEGATIVE_ERRNO`) and already saves all six GPRs in its syscall frame (`SYSCALL_SAVED_REG_MASK 0x3f`).
- **Commit after every task.** Per `AGENTS.md`, only the parent/main agent runs git state-changing commands; subagents report changed paths.
- Keep disk images / blobs **out of git**.

## Parent / worker queue note

- Parent/main agent owns all git state changes. Child workers must not stage, commit, checkout, switch, restore, reset, stash, merge, rebase, pull, or push.
- Child workers may inspect files, edit their assigned files, run host-only checks, and report changed paths/results.
- Avoid assigning multiple broad edits to `kernel/kernel.asm` at once. It is a single large file; split future work by narrow anchors (loader/stack, auxv, TLS, startup syscalls) and have workers avoid overlapping the same syscall, exec, process-record, or GDT regions.
- Current next large slice after M-1 hardening: continue M1a from the static BusyBox echo/true proof toward `ash`, `ls`, `cat`, and scripted shell behavior, or extend the M0 dynamic-glibc proof to less-stubbed signal/futex behavior. Static musl, larger exec staging, dynamic glibc stdout/exit, a `printf`/heap/file-existence/file-read/glibc-init libc probe, raw `getdents64`, seed Linux FD duplication/fcntl behavior, pipes, full-copy `fork`/`waitpid`, first BusyBox applet dispatch, and a headless Linux Doom frame proof are now in place; static glibc needs a separate Linux i386 static glibc toolchain. The current Chromium pressure probe makes the next browser-specific architecture slice explicit: real large-PIE sparse mapping, demand paging, ICU data mapping, `PT_DYNAMIC` premap, ld.so staging reservation, high-physical-page-table alias handling, Linux-layout library aliases, synthetic library directories, and early browser identity/session probes are in the fresh relocated proof. The latest parent run records `exec=OK path=/BIN/CHROMIUM.ELF argc=0000000B`, `m1live` status, 1739 handled demand pages (`0x6CB`) through `0x083D7000`, 945 Linux syscalls, process state `RUNNING`, and tolerated `rseq(386) -> -ENOSYS` as the latest error. This is a live browser-startup boundary, not UI. The next browser-specific blocker should be named from that status, then broader `/proc`, `/dev`, `/usr/lib/os-release`, socket semantics, resource-pack/locales packaging, graphics/input, process/sandbox, and syscall work before any browser UI can be claimed.

  Packaging note: a separate wrapper run hit exit status `127` from an incorrect no-version `libnspr4.so` alias; the isolated proof used the correct `/LIB/NSPR4.SO` alias, so that wrapper error is packaging noise rather than the current OS boundary.

---

## File / Anchor Map

All kernel work is in `kernel/kernel.asm` unless noted. Key existing anchors to read before editing:

| Anchor | Line | Why it matters to M-1 |
|---|---|---|
| Syscall equates / frame | 940–960 | `SYSCALL_TRAP_VECTOR=0x80`, `SYSCALL_MAX_ARGS=3` (lift to 6), frame offsets |
| Native syscall numbers | 774–844 | `SYS_*` table; Linux path is parallel to this |
| `int 0x80` dispatch chain | ~22429 | `cmp eax, SYS_*` chain — insert personality branch at its top |
| `process_seed_initial_user_context` | 19004 | sets `PROC_SAVED_EIP`←`PROC_ENTRY`, `PROC_SAVED_ESP`←`PROC_STACK_TOP` |
| `process_exec_prepare_elf_image` | 21093 | existing ELF-image prep — model the Linux loader on it |
| Existing auxv equates | 925–934 | `SYS_EXEC_AUX_AT_PAGESZ/ENTRY/NULL` — extend to full auxv |
| `vmm_map_page` | 7958 | map a physical page into a process address space |
| `vmm_mark_process_user_page` | 6938 | tag a user page in the process VM model |
| `fat_load_file` | 13969 | load a file from FAT into memory (loader input) |
| `fat_find_file` | 13223 | resolve a name on FAT |
| Process record fields | 614–715 | `PROC_ENTRY, PROC_STACK_TOP, PROC_PAGE_DIR, PROC_KIND, PROC_VM_FLAGS, PROC_BRK, PROC_HEAP_START/END, PROC_ARGV/ENVP` |
| GDT setup | (search `gdt`) | add a per-process TLS (GS-base) descriptor for `set_thread_area` |

Landed/new files:
- `tests/linux/hello_write.asm` — hand-written i386 static binary: `write` + `exit`.
- `tests/linux/auxv_dump.asm` — hand-written i386 static binary that walks and prints the initial auxv table; useful once Task 5 kernel auxv work lands.
- `tests/linux/tls_probe.asm` — hand-written i386 static binary that calls `set_thread_area`, loads `gs`, and proves a `gs:0` TLS read survives a syscall.
- `tests/linux/startup_probe.asm` — hand-written i386 static binary that exercises the static-libc startup syscall batch (`brk`, `set_tid_address`, `mmap2`, `mprotect`, `ioctl`, `getrandom`, `rt_sigprocmask`, `readlink`, `munmap`, `exit_group`).
- `tests/linux/exec_limits_probe.asm` — hand-written i386 static binary that validates larger exec argv/env stack staging from inside the guest.
- `tests/linux/dir_probe.asm` — hand-written i386 static binary that proves `openat(O_DIRECTORY)` and `getdents64(220)` on `/` and `/BIN`.
- `tests/linux/fd_probe.asm` — hand-written i386 static binary that proves Linux `dup`, `dup2`, `dup3`, `fcntl`, and `fcntl64` on a FAT-backed file descriptor.
- `tests/linux/pipe_probe.asm` — hand-written i386 static binary that proves Linux `pipe`, `pipe2`, pipe read/write buffering, close, and close-on-exec flags.
- `tests/linux/fork_probe.asm` — hand-written i386 static binary that proves Linux `fork`, parent/child memory divergence, `waitpid`, and Linux wait-status encoding.
- `tests/linux/hello_musl.c` — real static musl acceptance binary built with Zig (`x86-linux-musl`) and installed as `/BIN/MUSL.ELF` when present.
- `tests/linux/hello_glibc.c` — dynamic glibc hello built with Zig (`x86-linux-gnu`, no-SSE i386 codegen) and installed as `/BIN/GLIBC.ELF` for the M0 smoke.
- `tests/linux/libc_probe.c` — dynamic glibc M0 probe for `strtol`, `snprintf`, heap allocation, `qsort`, `access`, raw `faccessat(307)` for `AT_FDCWD`, open/read/close of `/LIB/LIBC.SO6`, seed `getrlimit`, `prlimit64`, `set_robust_list`, `rt_sigaction`, `futex`, `getpid`, `getenv`, `printf`, and `fflush`.
- `build/busybox-i386/busybox-vibe` — ignored BusyBox 1.35.0 static i386 musl `ET_EXEC` artifact (112460 bytes, linked at `0x00e80000`) installed by `tools/mkrootfs.sh` as `/BIN/BUSYBOX.ELF` when present.
- `tests/linux/linux_doom_headless.c` / `tests/linux/linux_doom` — static i386 musl Linux Doom proof built from original Linux Doom 1.10 sources plus a headless Linux platform layer; installed as `/BIN/LDOOM.ELF` when present and proved with the external shareware `DOOM1.WAD`.
- `tests/linux/Makefile` — assembles with NASM (`-f elf32`) and links with `build/link_elf32`.
- `tools/mkrootfs.sh` — rebuilds `build/disk.img` with Linux test binaries injected through `IMAGE_EXTRA_ROOT_ELF_ARGS`.

---

## Task 1: Linux `-ENOSYS` proof state

**Status:** Implemented and committed in `edda888`, then trimmed for the live M0/M1 proof kernel. Live anchors: `kernel/kernel.asm` has `LINUX_ENOSYS`, `linux_syscall_unimpl`, and `linux_last_unimpl_nr`. The earlier ring buffer was removed to keep the flagged kernel compact; current guest-status proof records the last `-ENOSYS` syscall number.

**Files:**
- Modify: `kernel/kernel.asm` — add data buffer + `linux_syscall_trace` routine + `linux_syscall_unimpl` handler.

- [x] **Step 1: Define compact Linux ENOSYS proof state (data section)**

Add near the other syscall state (~`kernel.asm:11768`):

```nasm
linux_last_unimpl_nr   dd 0               ; last ENOSYS syscall number (guest-status proof)
```

- [x] **Step 2: Keep tracing as debug-only future work**

Historical plan note: the first pass recorded `(nr=EAX, args EBX/ECX/EDX/ESI/EDI/EBP)` into a ring buffer. The live branch removed that ring for size; keep future tracing behind a separate debug flag or a larger-kernel profile.

- [x] **Step 3: Write `linux_syscall_unimpl` (default handler -> -ENOSYS)**

```nasm
LINUX_ENOSYS equ 38
linux_syscall_unimpl:
    mov [linux_last_unimpl_nr], eax
    mov eax, -LINUX_ENOSYS        ; -38 in EAX (negative-errno convention)
    ret
```

- [x] **Step 4: Verify it assembles**

Run: `cd ~/Documents/vibe-os && make` (or the project's assemble target — check `Makefile`).
Expected: builds with no NASM errors. (No behavior change yet — not wired in.)

- [x] **Step 5: Commit**

```bash
git add kernel/kernel.asm
git commit -m "feat(linux-personality): add ENOSYS proof state"
```

---

## Task 2: Per-process personality flag + dispatch branch

**Status:** Implemented and committed in `bb84f67`. Live anchors: `PROCESS_RECORD_BYTES equ 188`, `PROC_PERSONALITY equ 184`, `PERSONALITY_NATIVE`, `PERSONALITY_LINUX`, the native default in `process_seed_initial_user_context`, and `.linux_dispatch` in `syscall_handler`.

**Files:**
- Modify: `kernel/kernel.asm` — add `PROC_PERSONALITY` field, equates, and a branch at the top of the `int 0x80` dispatch (~22429).

- [x] **Step 1: Add personality equates + a process-record field**

Process records are `PROCESS_RECORD_BYTES equ 184` (line 616) with fields up to `PROC_HEAP_PAGE_COUNT equ 180`. Add a new field; if 184 is full, bump the record size (and audit every `times`/record allocation that uses `PROCESS_RECORD_BYTES`).

```nasm
PERSONALITY_NATIVE equ 0
PERSONALITY_LINUX  equ 1
PROC_PERSONALITY   equ 184          ; new field; bump PROCESS_RECORD_BYTES to 188
```

Change `PROCESS_RECORD_BYTES equ 184` → `equ 188` and re-verify all record-array reservations.

- [x] **Step 2: Default new processes to NATIVE**

In `process_seed_initial_user_context` (19004), before the final `ret`, add:

```nasm
    mov dword [esi + PROC_PERSONALITY], PERSONALITY_NATIVE
```

(esi = process record pointer in that routine.)

- [x] **Step 3: Branch the dispatcher on personality**

At the **top** of the `int 0x80` dispatch (immediately before the first `cmp eax, SYS_USER_PROBE` at ~22429), insert:

```nasm
    push ebx
    mov ebx, [current_process_ptr]
    cmp dword [ebx + PROC_PERSONALITY], PERSONALITY_LINUX
    pop ebx
    je .linux_dispatch            ; new Linux path below; native chain falls through
```

The existing `cmp eax, SYS_USER_PROBE` native chain now falls through after this branch.

- [x] **Step 4: Stub `.linux_dispatch` to route everything to unimpl**

```nasm
.linux_dispatch:
    call linux_syscall_trace
    call linux_syscall_unimpl     ; every Linux syscall logs + returns -ENOSYS for now
    jmp .return
```

- [x] **Step 5: Verify it assembles + native still boots**

Run: `make && <project QEMU target>` (check `Makefile`/`tools/` for the run recipe).
Expected: vibe-os boots; Doom/Quake/native probes behave exactly as before (no process is `LINUX` yet, so the new branch is never taken).

- [x] **Step 6: Commit**

```bash
git add kernel/kernel.asm
git commit -m "feat(linux-personality): per-process personality flag + dispatch branch"
```

---

## Task 3: Host-side test binary + rootfs tooling

**Status:** Implemented and committed in `f8cd8a0` for the `hello_write` scaffold. The current worktree also adds the `auxv_dump` host binary ahead of Task 5. Current worktree tooling uses NASM and `build/link_elf32`; do not reintroduce external GNU binutils as the default path.

**Files:**
- Created: `tests/linux/hello_write.asm`, `tests/linux/auxv_dump.asm`, `tests/linux/Makefile`, `tools/mkrootfs.sh`.

- [x] **Step 1: Write the hand-asm static test binary (`tests/linux/hello_write.asm`)**

A freestanding i386 Linux binary using raw `int 0x80` — no libc, so it isolates the loader + the two syscalls. (i386 numbers: `write=4`, `exit=1`.)

```nasm
; build:
;   nasm -f elf32 hello_write.asm -o hello_write.o
;   build/link_elf32 -o hello_write --base 0x00e80000 hello_write.o
bits 32
global _start
section .text
_start:
    mov eax, 4          ; sys_write
    mov ebx, 1          ; fd = stdout
    mov ecx, msg
    mov edx, msg_len
    int 0x80
    mov eax, 1          ; sys_exit
    mov ebx, 42         ; status 42 (proves exit-code path)
    int 0x80
section .data
msg:    db "hello from linux personality", 10
msg_len equ $ - msg
```

- [x] **Step 2: Write `tests/linux/Makefile`**

```make
NASM ?= nasm
LINK_ELF32 ?= $(REPO_ROOT)/build/link_elf32
BASE ?= 0x00e80000
BINARIES := hello_write auxv_dump

%.o: %.asm
	$(NASM) -f elf32 $< -o $@

%: %.o $(LINK_ELF32)
	$(LINK_ELF32) -o $@ --base $(BASE) $<
clean:
	rm -f *.o $(BINARIES)
```

- [x] **Step 3: Write `tools/mkrootfs.sh`** (inject binaries into the FAT image at known paths)

```sh
#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

make build/link_elf32
make -C tests/linux

ASSETS="--asset /BIN/HELLO.ELF=tests/linux/hello_write --asset /BIN/AUXV.ELF=tests/linux/auxv_dump"
DEPS="tests/linux/hello_write tests/linux/auxv_dump"
make DOOM_WAD= ALLOW_LOCAL_VM=0 \
     IMAGE_EXTRA_ROOT_ELF_ARGS="$ASSETS" \
     IMAGE_EXTRA_ROOT_ELF_DEPS="$DEPS"
```

The live script also has a `--dry-run` mode that prints the Makefile image-builder hook without creating `build/disk.img`.

- [x] **Step 4: Verify the binary builds and is a valid ELF32**

Run: `make build/link_elf32 && make -C tests/linux && file tests/linux/hello_write`
Expected: `ELF 32-bit LSB executable, Intel 80386`; no interpreter or libc dependency.

- [x] **Step 5: Commit**

```bash
git add tests/linux/hello_write.asm tests/linux/Makefile tools/mkrootfs.sh
git commit -m "test(linux-personality): static hello_write binary + rootfs tooling"
```

---

## Task 4: Linux ELF32 loader (static PT_LOAD) + minimal stack

**Current worktree note:** Task 4 is implemented as the first practical loader/stack proof by reusing the existing `process_exec_path`, `user_elf_prepare`, and `process_exec_seed_argv_stack` machinery for `/BIN/HELLO.ELF` and `/BIN/AUXV.ELF`, then restoring `PERSONALITY_LINUX` after `process_seed_initial_user_context`. Linux `write(4)`, `exit(1)`, and `exit_group(252)` dispatch route through existing native syscall bodies. The `LINUX_M1_SMOKE` path intentionally bypasses the normal launcher to boot `/BIN/HELLO.ELF`; the generic `make smoke` assertion still reports `usr=FAIL/gfx=FAIL` in that mode because the normal launcher is not the target.

**Verification note:** The focused hello run:
`make smoke ALLOW_LOCAL_VM=1 KERNEL_EXTRA_NASMFLAGS='-D LINUX_M1_SMOKE' IMAGE_EXTRA_ROOT_ELF_ARGS='--asset /BIN/HELLO.ELF=tests/linux/hello_write --asset /BIN/AUXV.ELF=tests/linux/auxv_dump' IMAGE_EXTRA_ROOT_ELF_DEPS='tests/linux/hello_write tests/linux/auxv_dump' SMOKE_QEMU_TIMEOUT=45`
returned through the generic smoke assertion, but guest proof succeeded: serial printed `hello from linux personality`, and `status.early.txt` had `path=/BIN/HELLO.ELF`, `persona=00000001`, and `linuxm1=00000002/00000001/00000001/00000000/00000001/0000002A/00000000` (`status/attempts/successes/failures/personality/exit_status/last_error`).

**Files:**
- Modify: `kernel/kernel.asm` — add `linux_exec_load_elf` (model on `process_exec_prepare_elf_image:21093`), and a minimal stack builder.

- [ ] **Step 1: Add the loader entry that detects + maps a Linux ELF**

Read `process_exec_prepare_elf_image` (21093) and `fat_load_file` (13969) first to reuse their file-load + page-map conventions. Add `linux_exec_load_elf`:
  - Input: pointer to the loaded ELF image bytes (from `fat_load_file`) + target process record in `esi`.
  - Parse `Elf32_Ehdr`: verify `e_ident` magic `0x7F 'E' 'L' 'F'`, `EI_CLASS=ELFCLASS32 (1)`, `e_machine=EM_386 (3)`, `e_type=ET_EXEC (2)` (static, fixed-address).
  - For each `Elf32_Phdr` with `p_type==PT_LOAD (1)`: map pages covering `[p_vaddr, p_vaddr+p_memsz)` via `vmm_map_page` (7958) + `vmm_mark_process_user_page` (6938), copy `p_filesz` bytes from the image, zero the `p_memsz-p_filesz` BSS tail. Apply perms from `p_flags` (R/W/X).
  - Set `PROC_ENTRY` ← `e_entry`.
  - Set `PROC_PERSONALITY` ← `PERSONALITY_LINUX`.

Structure (mirror anchor conventions — `Elf32_Ehdr`/`Elf32_Phdr` offsets are standard):

```nasm
ELF_EI_MAG          equ 0x464c457f     ; "\x7fELF" little-endian dword
EHDR_E_ENTRY        equ 24
EHDR_E_PHOFF        equ 28
EHDR_E_PHENTSIZE    equ 42
EHDR_E_PHNUM        equ 44
PHDR_P_TYPE         equ 0
PHDR_P_OFFSET       equ 4
PHDR_P_VADDR        equ 8
PHDR_P_FILESZ       equ 16
PHDR_P_MEMSZ        equ 20
PHDR_P_FLAGS        equ 24
PT_LOAD             equ 1

linux_exec_load_elf:
    ; esi = process record, eax = image base in kernel memory, ecx = image size
    ; ... validate Elf32_Ehdr (cmp dword [eax], ELF_EI_MAG) ...
    ; ... loop e_phnum phdrs at eax+e_phoff, map+copy each PT_LOAD ...
    ; ... mov edx,[eax+EHDR_E_ENTRY] ; mov [esi+PROC_ENTRY],edx ...
    ; ... mov dword [esi+PROC_PERSONALITY], PERSONALITY_LINUX ...
    ; clc on success / stc on failure (anchor convention)
    ret
```

- [ ] **Step 2: Build the minimal initial stack (argc/argv/envp, no auxv yet)**

The user stack lives at `PROC_STACK_TOP`. Build downward, 16-byte aligned, per SysV i386:
`[argc][argv0 ptr]...[NULL][envp0 ptr]...[NULL]`. For `hello_write` (ignores argv): `argc=1`, one argv pointer to the string `"HELLO"`, NULL, NULL. Set `PROC_SAVED_ESP` to the final aligned `esp` (`process_seed_initial_user_context` sets it from `PROC_STACK_TOP`; override after seeding, or build before seeding and pass the adjusted top).

```nasm
linux_build_initial_stack:
    ; esi = process record; writes argc/argv/envp to top of user stack
    ; returns adjusted stack pointer in eax (store into PROC_STACK_TOP/PROC_SAVED_ESP)
    ; layout (low->high): argc=1, &argv0, 0, 0   (argv0 -> a "PROG\0" string placed above)
    ret
```

- [ ] **Step 3: Implement `write` and `exit` so the binary can run**

Add to `linux_syscall_dispatch` (replace the blanket unimpl jump with a small chain):

```nasm
linux_syscall_dispatch:
    call linux_syscall_trace
    cmp eax, 4
    je linux_sys_write          ; reuse native write path (SYS_WRITE handler)
    cmp eax, 1
    je linux_sys_exit           ; reuse native exit path (SYS_EXIT handler)
    jmp linux_syscall_unimpl
```

`linux_sys_write`: validate the user buffer, then call the existing native write implementation (the handler behind `SYS_WRITE equ 4`) — fd 1 → console. Return byte count in EAX.
`linux_sys_exit`: store `EBX` (status) into the process's exit-status field and route into the existing native exit/teardown path (behind `SYS_EXIT`). Surface the status in a **guest status field** for the test harness.

- [ ] **Step 4: Wire a boot-time launch of `/BIN/HELLO` under the Linux personality**

Add a temporary boot hook (behind a build flag, e.g. `%ifdef LINUX_M1_SMOKE`) that, after init, `fat_load_file`s `/BIN/HELLO`, calls `linux_exec_load_elf`, `linux_build_initial_stack`, `process_seed_initial_user_context`, and schedules it.

- [ ] **Step 5: Verify end-to-end in QEMU**

Run: `make build/link_elf32 && make -C tests/linux && tools/mkrootfs.sh && make LINUX_M1_SMOKE=1 && <run QEMU>`
Expected console: `hello from linux personality`, and the guest exit-status field reads `42`. Confirm `linux_last_unimpl_nr` stays `0` for this binary.

- [ ] **Step 6: Commit**

```bash
git add kernel/kernel.asm
git commit -m "feat(linux-personality): ELF32 static loader + minimal stack + write/exit"
```

---

## Task 5: Full auxv builder

**Current worktree note:** Implemented. Linux-personality execs now emit `AT_PHDR`, `AT_PHENT`, `AT_PHNUM`, `AT_PAGESZ`, `AT_BASE=0`, `AT_FLAGS=0`, `AT_ENTRY`, `AT_UID/EUID/GID/EGID=0`, `AT_HWCAP=FPU`, `AT_CLKTCK=100`, `AT_SECURE=0`, `AT_RANDOM`, `AT_EXECFN`, and `AT_NULL`. `AT_PHDR` points to a copy of the ELF program header table on the initial stack; `AT_RANDOM` points to 16 stack bytes seeded from timer/process state. Native execs still get the previous three-pair auxv. The status writer no longer prints the Linux trace tuple, keeping the proof-only `LINUX_M1_SMOKE` kernel compact; the trace counters remain in kernel memory.

**Verification note:** The focused auxv run:
`make smoke ALLOW_LOCAL_VM=1 KERNEL_EXTRA_NASMFLAGS='-D LINUX_M1_SMOKE -D LINUX_M1_AUXV_SMOKE' IMAGE_EXTRA_ROOT_ELF_ARGS='--asset /BIN/HELLO.ELF=tests/linux/hello_write --asset /BIN/AUXV.ELF=tests/linux/auxv_dump' IMAGE_EXTRA_ROOT_ELF_DEPS='tests/linux/hello_write tests/linux/auxv_dump' SMOKE_QEMU_TIMEOUT=45`
returned through the generic smoke assertion, but QEMU exited cleanly and serial printed:
`AT_PHDR=0x00ecffa8`, `AT_PHENT=0x20`, `AT_PHNUM=2`, `AT_PAGESZ=0x1000`, `AT_ENTRY=0x00e80000`, `AT_HWCAP=1`, `AT_CLKTCK=0x64`, `AT_RANDOM=0x00ecff98`, `AT_EXECFN=0x00ecfff0`, then `auxv end`. Guest status had `path=/BIN/AUXV.ELF`, `persona=00000001`, and `linuxm1=00000002/00000001/00000001/00000000/00000001/00000000/00000000`.

**Files:**
- Modify: `kernel/kernel.asm` — extend stack builder with the complete auxv glibc/musl require.

- [x] **Step 1: Write `tests/linux/auxv_dump.asm`** (verifies auxv before any libc depends on it)

A static binary that walks past argv+envp on its own stack to the auxv and prints each `(type, value)` as it finds key types, then exits. (Reads `[esp]`=argc, skips argv+NULL, skips envp+NULL, then reads auxv pairs until `AT_NULL=0`.)

```nasm
bits 32
global _start
section .text
_start:
    mov esi, esp
    lodsd                       ; argc
    lea esi, [esi + eax*4]      ; skip argv[]
    add esi, 4                  ; skip argv NULL
.skipenv:
    lodsd
    test eax, eax
    jnz .skipenv                ; skip envp[] to its NULL
.auxv:
    lodsd                       ; a_type
    mov ebx, eax
    lodsd                       ; a_val
    test ebx, ebx
    jz .done                    ; AT_NULL
    ; (emit ebx:eax via write of a fixed-format line; impl detail)
    jmp .auxv
.done:
    mov eax, 1
    xor ebx, ebx
    int 0x80
```

- [x] **Step 2: Add the auxv equates**

```nasm
AT_NULL   equ 0
AT_PHDR   equ 3
AT_PHENT  equ 4
AT_PHNUM  equ 5
AT_PAGESZ equ 6
AT_BASE   equ 7
AT_FLAGS  equ 8
AT_ENTRY  equ 9
AT_UID    equ 11
AT_EUID   equ 12
AT_GID    equ 13
AT_EGID   equ 14
AT_HWCAP  equ 16
AT_CLKTCK equ 17
AT_SECURE equ 23
AT_RANDOM equ 25
AT_EXECFN equ 31
```

- [x] **Step 3: Extend the Linux stack path to append the full auxv**

After the envp NULL, write `(type,value)` dword pairs terminated by `AT_NULL,0`:
  - `AT_PHDR` = user vaddr of the program headers (`e_phoff` mapped into the image's load address), `AT_PHENT` = `e_phentsize`, `AT_PHNUM` = `e_phnum` (carry these out of `linux_exec_load_elf`).
  - `AT_PAGESZ`=4096, `AT_BASE`=0 (no interpreter for static), `AT_FLAGS`=0, `AT_ENTRY`=`e_entry`, `AT_UID/EUID/GID/EGID`=0, `AT_HWCAP`= a conservative value (e.g. just `FPU` bit; do **not** advertise features you don't emulate), `AT_CLKTCK`=100, `AT_SECURE`=0.
  - `AT_RANDOM` = pointer to 16 real random bytes placed on the stack (glibc reads these for stack canaries — **mandatory**; omitting it aborts glibc). Generate via the existing RNG / `clock` entropy.
  - `AT_EXECFN` = pointer to the program path string on the stack.
  - **Do not** emit `AT_SYSINFO`/`AT_SYSINFO_EHDR` → glibc falls back to `int 0x80` (no vDSO needed).

- [x] **Step 4: Verify in QEMU**

Run the `auxv_dump` binary as the smoke target.
Expected: console shows `AT_PHDR`, `AT_PHNUM`, `AT_ENTRY`, `AT_PAGESZ=4096`, `AT_RANDOM` (non-zero pointer) lines, terminates cleanly (exit 0).

- [ ] **Step 5: Commit**

```bash
git add kernel/kernel.asm tests/linux/auxv_dump.asm tests/linux/Makefile
git commit -m "feat(linux-personality): full auxv builder + auxv_dump test"
```

---

## Task 6: TLS via `set_thread_area` (GS base)

**Status:** Implemented in the current worktree. The live implementation reserves GDT index 6 as a single-threaded Linux TLS slot, accepts `set_thread_area(243)` for `entry_number == -1` or that reserved index, writes the assigned entry number back, stores the Linux TLS base in the process record, programs a DPL3 flat 32-bit data descriptor, and restores Linux GS from the saved user segment state on syscall return/context activation. The current M-1 implementation intentionally ignores `user_desc` flags/limit and uses the flat i386 descriptor shape needed by the in-repo static probe.

**Files:**
- Modify: `kernel/kernel.asm` — add `set_thread_area` handler + a per-process GDT TLS descriptor; load GS on context switch.

- [x] **Step 1: Reserve a GDT entry for user TLS**

Find the GDT setup (search `gdt`). Add one user-DPL3 data descriptor (the "TLS" slot). i386 glibc/musl set up a `struct user_desc` and call `set_thread_area(243)`; the kernel fills a GDT/LDT entry and returns its `entry_number`. Reserve a fixed entry index for the single-threaded M-1 case.

- [x] **Step 2: Implement `set_thread_area` (number 243)**

`struct user_desc` layout (input pointer in EBX): `entry_number(0), base_addr(4), limit(8), flags(12)`. If `entry_number == -1`, assign the reserved index and write it back. Program the GDT descriptor: base=`base_addr`, limit=`limit`, DPL=3, 32-bit, granularity per `flags`. Return 0.

```nasm
LINUX_SYS_SET_THREAD_AREA equ 243
UD_ENTRY_NUMBER equ 0
UD_BASE_ADDR    equ 4
UD_LIMIT        equ 8
UD_FLAGS        equ 12
; in linux_syscall_dispatch:  cmp eax, 243 / je linux_sys_set_thread_area
linux_sys_set_thread_area:
    ; ebx -> user_desc; validate ptr; assign reserved entry if -1;
    ; build GDT descriptor (base/limit/DPL3); store entry_number back; eax=0
    ret
```

- [x] **Step 3: Load GS with the TLS selector for Linux processes**

In `process_activate` (19152) — which already restores segment regs — ensure that for `PERSONALITY_LINUX` processes, `GS` is loaded with the TLS selector (RPL 3) after the descriptor is set. (Native processes keep `USER_DATA_SEG` in GS as today.)

- [x] **Step 4: Verify with a TLS-touching binary**

Write a tiny static binary that calls `set_thread_area`, loads `gs`, and reads `mov eax, [gs:0]` from a value it stored at its TLS base; write the value out. Run in QEMU.
Expected: the value round-trips (proves GS base is live). Trace shows syscall 243 returning 0.

Proof command:

```bash
make smoke ALLOW_LOCAL_VM=1 SMOKE_SKIP_ASSERTIONS=1 KERNEL_EXTRA_NASMFLAGS='-D LINUX_M1_SMOKE -D LINUX_M1_TLS_SMOKE' IMAGE_EXTRA_ROOT_ELF_ARGS='--asset /BIN/HELLO.ELF=tests/linux/hello_write --asset /BIN/AUXV.ELF=tests/linux/auxv_dump --asset /BIN/TLS.ELF=tests/linux/tls_probe' IMAGE_EXTRA_ROOT_ELF_DEPS='tests/linux/hello_write tests/linux/auxv_dump tests/linux/tls_probe' SMOKE_QEMU_TIMEOUT=45
```

Observed proof:

- Serial: `tls ok`
- Status: `path=/BIN/TLS.ELF`, `argvsrc=00000001`, `linuxm1=00000002/00000001/00000001/00000000/00000001/00000000/00000000`
- Relocation/high-mainline guard still healthy: `kreloc=HIGH`, `krelocstep=KPMAIN_HIGH`, `khmain=OK`, `kpmap=OK`, `kpexec=OK`, `panic=NONE`

- [ ] **Step 5: Commit**

```bash
git add kernel/kernel.asm tests/linux/tls_probe.asm
git commit -m "feat(linux-personality): set_thread_area + GS-based TLS"
```

---

## Task 7: Remaining static-glibc startup syscalls + grow limits

**Status:** Kernel-side startup syscall batch is implemented and proved with `/BIN/STARTUP.ELF` in the current worktree. A real static musl binary is also built with Zig and proved as `/BIN/MUSL.ELF`. Exec staging now uses a compact heap-backed arena instead of fixed argv/env `.bss` buffers, with path length 4096, 64 argv pointers, 64 env pointers, 4096-byte per-string caps, and a shared 32 KiB string pool. `/BIN/XLIMIT.ELF` proves the new path by receiving 10 argv entries, 9 env entries, and long strings crossing the old 64-byte cap. `/BIN/DIR.ELF` starts M1a by proving directory FDs plus Linux `dirent64` output for FAT root and `/BIN`; `/BIN/FD.ELF` continues M1a by proving descriptor duplication and fcntl flag state; `/BIN/PIPE.ELF` proves fixed-size pipe buffering plus `pipe2(O_CLOEXEC)`; `/BIN/FORK.ELF` proves a full-copy Linux `fork` seed with parent/child memory divergence and `waitpid` status encoding. `/BIN/BUSYBOX.ELF` now proves first real BusyBox applet dispatch through the Linux personality: `busybox echo busybox-ok` prints the marker and exits `0`, and `busybox true` exits `0`; `busybox sh -c 'echo busybox-ok'` currently exits `1` with `sh: out of memory`, so shell acceptance remains future work. Implemented Linux i386 calls: `fork(2)`, `waitpid(7)`, `brk(45)`, `mmap2(192)`, `mprotect(125)`, `munmap(91)`, `writev(146)`, `set_tid_address(258)`, `rt_sigprocmask(175)`, `ioctl(54)` returning `-ENOTTY` for fd 1 `TCGETS`, `getrandom(355)`, `readlink(85)`, `readlinkat(305)`, `wait4(114)` with `rusage=NULL`, seed `open/openat(O_DIRECTORY)`, `getdents64(220)`, `pipe(42)`, `dup(41)`, `dup2(63)`, `fcntl(55)`, `fcntl64(221)`, `dup3(330)`, `pipe2(331)`, `getpid(20)`, `prctl(172)` as a no-op, and `sched_getaffinity(242)` returning a single-CPU mask. Static glibc is not yet built on this Mac: Zig reports that `x86-linux-gnu` libc requires dynamic linking, and no separate Linux i386 static glibc toolchain is installed.

**Files:**
- Modify: `kernel/kernel.asm` — add the syscalls glibc's static startup touches; grow exec limits.

- [x] **Step 1: Grow the small limits**

Raised the exec limits that block real binaries (anchors at 844, 919–934): `SYS_EXEC_PATH_MAX 64`→`4096`, `SYS_EXEC_ARG_MAX 8`→`64`, `SYS_EXEC_ARG_STR_MAX 64`→`4096`, `SYS_EXEC_ENV_MAX 8`→`64`, `SYS_EXEC_ENV_STR_MAX 64`→`4096`.

Implementation note: the live fix does not grow fixed `.bss` buffers. It lazily allocates one `SYS_EXEC_STAGE_BYTES` arena from `kalloc`, stores the path buffer and argv/env pointer tables there, and copies argv/env strings into a shared 32 KiB string pool before seeding the user stack. The default kernel remains `159872` bytes.

Proof command:

```bash
make smoke ALLOW_LOCAL_VM=1 SMOKE_SKIP_ASSERTIONS=1 KERNEL_EXTRA_NASMFLAGS='-D LINUX_M1_SMOKE -D LINUX_M1_EXEC_LIMITS_SMOKE' IMAGE_EXTRA_ROOT_ELF_ARGS='--asset /BIN/HELLO.ELF=tests/linux/hello_write --asset /BIN/AUXV.ELF=tests/linux/auxv_dump --asset /BIN/TLS.ELF=tests/linux/tls_probe --asset /BIN/STARTUP.ELF=tests/linux/startup_probe --asset /BIN/XLIMIT.ELF=tests/linux/exec_limits_probe --asset /BIN/MUSL.ELF=tests/linux/hello_musl' IMAGE_EXTRA_ROOT_ELF_DEPS='tests/linux/hello_write tests/linux/auxv_dump tests/linux/tls_probe tests/linux/startup_probe tests/linux/exec_limits_probe tests/linux/hello_musl' SMOKE_QEMU_TIMEOUT=45
```

Observed proof:

- Serial: `exec limits ok`
- Status: `path=/BIN/XLIMIT.ELF`, `argc=0000000A`, `envp0=00ECFE88`, `argvsrc=00000002`, `linuxm1=00000002/00000001/00000001/00000000/00000001/00000009/00000000`
- Guard fields: `faultsrc=NONE`, `panic=NONE`

- [x] **Step 2: Map the startup syscalls into `linux_syscall_dispatch`**

Add `cmp eax, N / je handler` for each (i386 numbers), reusing native handlers where one exists:

| Linux nr | Syscall | Implementation |
|---|---|---|
| 252 | `exit_group` | same teardown as `exit` (1) |
| 45 | `brk` | reuse native `SYS_SBRK (5)` against `PROC_BRK/HEAP_START/END`; Linux `brk` returns the *new break* (or current if arg=0), not an error |
| 192 | `mmap2` | anonymous private map via `vmm_map_page`; offset is in **pages**; back `MAP_ANONYMOUS` from the process heap arena |
| 91 | `munmap` | reuse native `SYS_MUNMAP (21)` |
| 125 | `mprotect` | accepted no-op for current static/dynamic probes; real RELRO permissions remain M0 hardening |
| 146 | `writev` | bounded stdout/stderr iovec write path used by musl stdio |
| 258 | `set_tid_address` | store pointer, return a fake tid (e.g. `PROC_PID`) |
| 175 | `rt_sigprocmask` | store/return mask; no delivery yet (return 0) |
| 54 | `ioctl` | `TCGETS` on fd 1 → `-ENOTTY` (25) so glibc picks block buffering |
| 355 | `getrandom` | fill buffer from the same RNG used for `AT_RANDOM`; return count |
| 85/305 | `readlink(at)` | `/proc/self/exe` → the program path; else `-ENOENT` |

Anything else still hits `linux_syscall_unimpl` (logged) — that's the discovery mechanism for later milestones.

In-repo proof command:

```bash
make smoke ALLOW_LOCAL_VM=1 SMOKE_SKIP_ASSERTIONS=1 KERNEL_EXTRA_NASMFLAGS='-D LINUX_M1_SMOKE -D LINUX_M1_STARTUP_SMOKE' IMAGE_EXTRA_ROOT_ELF_ARGS='--asset /BIN/HELLO.ELF=tests/linux/hello_write --asset /BIN/AUXV.ELF=tests/linux/auxv_dump --asset /BIN/TLS.ELF=tests/linux/tls_probe --asset /BIN/STARTUP.ELF=tests/linux/startup_probe' IMAGE_EXTRA_ROOT_ELF_DEPS='tests/linux/hello_write tests/linux/auxv_dump tests/linux/tls_probe tests/linux/startup_probe' SMOKE_QEMU_TIMEOUT=45
```

Observed proof:

- Serial: `startup ok`
- Status: `path=/BIN/STARTUP.ELF`, `linuxm1=00000002/00000001/00000001/00000000/00000001/00000007/00000000`
- Guard fields: `faultsrc=NONE`, `panic=NONE`, `kreloc=HIGH`, `krelocstep=KPMAIN_HIGH`, `khmain=OK`, `kpmap=OK`, `kpexec=OK`

- [x] **Step 3: Build the M-1 acceptance binary — a *real* static musl hello**

Build on the host with Zig:

```bash
make -C tests/linux real-libc
```

`tools/mkrootfs.sh` installs the resulting `tests/linux/hello_musl` as `/BIN/MUSL.ELF` when it exists.

Static glibc note: `zig cc -target x86-linux-gnu -static ...` currently fails with `libc of the specified target requires dynamic linking`, and this macOS workspace still has no separate `i686-linux-gnu-gcc`/static glibc toolchain.

```c
#include <stdio.h>
int main(void){ puts("hello, musl on vibe-os"); return 7; }
```

- [x] **Step 4: Run it in QEMU (the M-1 musl acceptance test)**

Run: build musl-static and boot it as the smoke target.
Expected: console prints `hello, musl on vibe-os`; guest exit-status field = `7`; guest status shows **no new `-ENOSYS`** for this binary (`linux_last_unimpl_nr` unchanged).

Observed proof:

- Serial: `hello, musl on vibe-os`
- Status: `path=/BIN/MUSL.ELF`, `linuxm1=00000002/00000001/00000001/00000000/00000001/00000007/00000000`
- Guard fields: `faultsrc=NONE`, `faultmode=NONE`, `panic=NONE`, `kreloc=HIGH`, `krelocstep=KPMAIN_HIGH`, `khmain=OK`, `kpmap=OK`, `kpexec=OK`

- [ ] **Step 4b: Optional static glibc acceptance**

Requires a Linux i386 static glibc toolchain that can produce a no-interpreter ELF. If/when available, build a `printf`/`puts` hello, install it as `/BIN/GLIBC.ELF`, and repeat the smoke proof. Dynamic glibc remains M0.

Current M0 seed: Zig's `x86-linux-gnu` target produces small dynamic i386/no-SSE executables at the vibe-os user base. One is installed as `/BIN/GLIBC.ELF` for each focused smoke; the loader records `PT_INTERP` status/match, maps `/LIB/LDLINUX.SO2` at `USER_INTERP_BASE`, retargets dynamic exec to the interpreter entry, and wires `AT_BASE` to that base. With real Debian i386 `ld-linux.so.2` and `libc.so.6` installed as `/LIB/LDLINUX.SO2` and `/LIB/LIBC.SO6`, the `LINUX_M0_LDSO_SMOKE` proof now runs through `ld.so`, resolves/maps `libc.so.6`, prints `hello, glibc on vibe-os`, and returns the expected exit status `11` (`linuxm1=.../0000000B/.../00000182`). The broader `libc_probe` prints `libc probe ok: noenv 42 pid=4` and returns exit status `13`, covering `strtol`, `snprintf`, `malloc`/`realloc`/`free`, `qsort`, `access`, raw `faccessat(307)` for `AT_FDCWD`, open/read/close of `/LIB/LIBC.SO6`, seed `getrlimit`, `prlimit64`, `set_robust_list`, query-only `rt_sigaction`, basic `futex` wake plus nonblocking wait, `getpid`, `getenv`, `printf`, and `fflush`. This is still M0 seed work, not static glibc acceptance; `rseq(386)` remains a tolerated `-ENOSYS`, compact `faccessat` does not yet implement general dirfd semantics, real signal/futex semantics remain M1 work, and optimized glibc string/SSE paths remain future CPU-feature/FPU-context work.

Current M1a BusyBox seed: BusyBox 1.35.0 is built outside git as a static i386 musl `ET_EXEC` binary, no PIE, linked at `0x00e80000`, copied to `build/busybox-i386/busybox-vibe`, and installed by `tools/mkrootfs.sh` as `/BIN/BUSYBOX.ELF`. The artifact is 112460 bytes. Two focused QEMU smokes boot with `LINUX_M1_SMOKE`, exec `/BIN/BUSYBOX.ELF` through the Linux personality, and stage argv as real BusyBox applet invocations:

- `busybox echo busybox-ok`: serial prints `busybox-ok`; status shows `exec=OK`, `path=/BIN/BUSYBOX.ELF`, `argc=00000003`, `argvsrc=00000002`, `linuxm1=00000002/00000001/00000001/00000000/00000001/00000000/00000000/00000000`, no fault/page-fault fields set, `panic=NONE`, and `shutdown=NONE`.
- `busybox true`: status shows `exec=OK`, `path=/BIN/BUSYBOX.ELF`, `argc=00000002`, `argvsrc=00000002`, the same Linux-personality success tuple with exit `0` and last `-ENOSYS` `0`, no fault/page-fault fields set, `panic=NONE`, and `shutdown=NONE`.

The successful BusyBox applet proofs require/tolerate the existing static-libc startup surface plus `prctl(172)` as a no-op and `sched_getaffinity(242)` returning a single-CPU mask. `ash` is compiled in but not accepted: `busybox sh -c 'echo busybox-ok'` reaches userland and fails cleanly as a process with `sh: out of memory`, exit `1`, no kernel fault/panic/shutdown, and no unexpected `-ENOSYS`. `ls`/`cat`/filesystem applets are still unproved in this pass.

Current Linux Doom proof: `tests/linux/linux_doom` is built as a static i386 musl `ET_EXEC` at `0x01000000`, from the original Linux Doom 1.10 engine sources and the headless Linux platform layer in `tests/linux/linux_doom_headless.c`. `tools/mkrootfs.sh` installs it as `/BIN/LDOOM.ELF` when present. The focused QEMU smoke boots with `LINUX_M1_SMOKE -D LINUX_M1_LDOOM_SMOKE`, packages the external shareware `DOOM1.WAD` as the rootfs primary asset, execs `/BIN/LDOOM.ELF` through `PERSONALITY_LINUX`, and reaches a rendered frame: serial prints `ldoom frame=1 checksum=983fe686 nonzero=304`; status shows `exec=OK`, `path=/BIN/LDOOM.ELF`, Linux personality selected, exit `0`, `linux_last_unimpl_nr=0`, `faultsrc=NONE`, `panic=NONE`, and `shutdown=NONE`. Required/fixed surface for this proof includes Linux i386 `lseek(19)`, existing `_llseek(140)`, file `open/read/fstat/close`, anonymous `mmap2(192)` with non-fixed address hints accepted, and the static musl startup/TLS/syscall set. The guest platform layer provides tiny formatting/string shims and direct Linux `write`/`lseek` wrappers; this is still a Linux ELF proof, not the native `/APPS/DOOM/APP.ELF` path, and it does not claim general Linux video/audio/input support.

Current Chromium pressure proof: the current available Debian sid i386 `chromium_148.0.7778.178-1_i386.deb` binary package is packaged as `/BIN/CHROMIUM.ELF` from `/usr/lib/chromium/chromium`. The package SHA-256 is `627276adfbd983e1537403f9f8382db27f100f3944df1f2279ca3cc65b93665e`; the browser ELF SHA-256 is `8a65db2dac7bebd1cf932290139e110fae970efbf6be5a2351188f824fee7c2a`. Matching `chromium-common_148.0.7778.178-1_i386.deb` supplies `/BIN/ICUDTL.DAT`; its package SHA-256 is `26344d8b9cf82e61ad67240f46ccf24cf2b902a47d29e51681c3440842c735b3`, and `icudtl.dat` SHA-256 is `bd8c145abdf3f8383276ce01dfa4ae48709bef9fef1c0711eb7c3fab4f6eb7c2`. The current Chromium smoke uses separate ignored Debian sid i386 `libc6_2.42-16_i386.deb` artifacts for `/LIB/LDLINUX.SO2` and `/LIB/LIBC.SO6`; the package SHA-256 is `4581e89be4256fe0b75c1ba7090477b65d1a4c893ddc0d438c518c6dd8e8e8fb`, ld-linux SHA-256 is `2527ad9fdf19bc90734f17e10922d188dff9095abfcc1d06f97a0c1443f9f508`, and libc SHA-256 is `7361db7f1c6692adedfb8a1cc4956cb0bddef201aef3aa4ba53a28f0ceff8c51`. After relocating the smoke-status window away from live CPU tables, the latest focused smoke stages the 101 recursive real sid i386 `NEEDED` shared-library assets plus the tiny `/tmp`, `/dev/null`, `/proc/self/exe`, and PROCID/identity-session startup hooks. The parent QEMU run reports Linux personality selected, real sid ld-linux loaded, `m1live` status, 1739 handled demand pages (`0x6CB`), last demand address `0x083D7000`, 945 Linux syscalls, process state `RUNNING`, and latest error `rseq(386) -> -ENOSYS`. The proof path now honestly covers the browser ELF, staged argv, `PT_INTERP`, ET_DYN load bias, sparse mapping, `PT_DYNAMIC` premap, ld.so staging reservation, present-PTE `mprotect`, file-backed demand paging, and Chromium-owned startup beyond ld.so/libc. Browser UI remains unproved; the latest boundary is live startup naming the next missing capability, not the older `0x08010D76` or no-exit demand snapshot.

Current packaging correction: the separate exit-`127` wrapper run came from bad hand-staging of a no-version `libnspr4.so` alias. The helper-generated asset set maps the package's real `libnspr4.so` soname to the correct `/LIB/NSPR4.SO` alias family, so that wrapper error is packaging noise. Current browser work should treat `/etc/ld.so.cache -> -ENOENT` and `0x08010D76` as handled/tolerated evidence in the relocated proof; the fresh frontier is the `m1live` Chromium RUNNING state after 1739 handled demand pages through `0x083D7000`, with `rseq(386) -> -ENOSYS` as the latest error and no browser UI claim.

- [ ] **Step 5: Commit**

```bash
git add kernel/kernel.asm tests/linux/
git commit -m "feat(linux-personality): static glibc/musl hello runs end-to-end (M-1 complete)"
```

---

## M-1 Done — Definition of Done

- [x] An unmodified hand-asm static binary runs (`write`+`exit`, status propagates).
- [x] An `auxv_dump` binary confirms the full auxv is correct.
- [x] TLS works (`set_thread_area` + `gs:0` round-trip).
- [x] A hand-asm startup probe covers the static-libc syscall batch now implemented in the Linux dispatcher.
- [x] A **statically-linked musl** "hello world" runs to completion with correct stdout and exit status, hitting **zero new `-ENOSYS`**.
- [x] Larger exec path/argv/env limits are implemented without fixed `.bss` growth.
- [ ] Optional: a **statically-linked glibc** "hello world" runs once a suitable static glibc toolchain is available.
- [ ] Native (Doom/Quake) programs are unaffected.
- [ ] Each task committed separately; no disk images in git.

**Next:** continue M1a from the static BusyBox echo/true proof toward BusyBox `ash`, `ls`, `cat`, and scripted shell behavior; in parallel, harden the M0 dynamic-linker seed around real signal/futex semantics and protection behavior. For the browser pressure path, improve live-state/demand-refault status around the current no-exit Chromium snapshot, then re-reach the socket/clone surface and fill the next real Linux surface (`/usr/lib/os-release`, `/proc`, `/dev`, broader sockets, resource packs/locales, graphics/input, process/sandbox).

---

## Self-Review notes (author)

- **Spec coverage:** Covers spec §6 "M-1" for loader, stack, auxv, TLS, listed syscalls, static musl acceptance, and larger heap-backed exec path/argv/env staging. Static glibc is optional/toolchain-gated, while dynamic glibc stays M0.
- **Known soft spots (honest):** Asm bodies for `linux_exec_load_elf`, `linux_build_initial_stack`, and `set_thread_area` are given as precise structure + standard ELF/`user_desc` offsets rather than line-complete NASM, because they extend deep existing routines (`process_exec_prepare_elf_image`, `process_activate`, the GDT setup) whose internal register/stack conventions must be read and mirrored at implementation time. Every such task names the exact anchor to model on. The *new self-contained* code (ENOSYS proof state, personality flag + dispatch branch, auxv entries/equates, test binaries) is literal.
- **Type/name consistency:** `PROC_PERSONALITY`, `PERSONALITY_LINUX`, `linux_syscall_dispatch`, `linux_syscall_trace`, `linux_syscall_unimpl`, `linux_exec_load_elf`, `linux_build_initial_stack` used consistently across tasks.
