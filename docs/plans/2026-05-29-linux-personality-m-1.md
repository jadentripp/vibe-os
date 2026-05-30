# Linux Personality M-1 Implementation Plan — Run a Static Linux i386 Binary

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make vibe-os load and run an *unmodified, statically-linked* Linux i386 ELF binary that writes to stdout and exits with a correct status code.

**Architecture:** Add a per-process **personality flag** to the existing process record. The `int 0x80` dispatcher (currently a `cmp eax, SYS_*` chain at `kernel/kernel.asm:22429`) branches to a **separate Linux i386 syscall path** when the flag is `LINUX`; native programs (Doom/Quake) are untouched. A new **Linux ELF32 loader** maps `PT_LOAD` segments and builds a SysV-i386 initial stack (argc/argv/envp + minimal auxv). An **in-kernel syscall tracer** logs every Linux syscall and returns `-ENOSYS` for unimplemented ones — this is the primary debugging tool and the engine of strace-driven development.

**Tech Stack:** NASM (`bits 32`), the existing single-file kernel `kernel/kernel.asm`, FAT disk image for the guest filesystem, QEMU for local boot proof, GNU `as`/`ld` (or `gcc -m32 -static`/`musl-gcc`) on the host to build i386 test binaries. **No Python** (per `AGENTS.md`). Assembly-first; C only if a surface stays tiny.

---

## Conventions for this plan (read first)

- **"Test" in an OS kernel = a guest binary + expected serial/guest-status output, run in QEMU.** There is no pytest. Each task's acceptance is: build a tiny i386 binary, place it on the FAT image, boot vibe-os in QEMU, and confirm the expected console output and/or a **guest status field** (the `AGENTS.md`-preferred proof mechanism — emit results from the OS itself, don't infer host-side).
- **Asm shown for *new, self-contained* logic is literal** (equates, the personality flag, the dispatch branch, auxv entries, the GDT TLS entry, test binaries). Asm for *bodies that extend existing deep routines* is given as precise structure that **must follow the conventions of the cited anchor routine** (register save/restore via `pushad`/`popad`, `clc`/`stc` success/failure, `PROC_*` field offsets). Always open the anchor and mirror it.
- **Linux i386 ABI reminder:** entry `int 0x80`; syscall number in `EAX`; args in `EBX, ECX, EDX, ESI, EDI, EBP` (up to 6); return value in `EAX` as a result or `-errno`. vibe-os already uses `int 0x80` + negative-errno (`SYSCALL_RESULT_NEGATIVE_ERRNO`) and already saves all six GPRs in its syscall frame (`SYSCALL_SAVED_REG_MASK 0x3f`).
- **Commit after every task.** Per `AGENTS.md`, only the parent/main agent runs git state-changing commands; subagents report changed paths.
- Keep disk images / blobs **out of git**.

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

New files:
- `tests/linux/hello_write.asm` — hand-written i386 static binary: `write` + `exit`.
- `tests/linux/auxv_dump.asm` — dumps its own auxv to stdout.
- `tests/linux/Makefile` — assembles/links the test binaries with `as --32` + `ld -m elf_i386`.
- `tools/mkrootfs.sh` — copies test binaries into the FAT image at known paths.

---

## Task 1: In-kernel Linux syscall tracer + `-ENOSYS` default

**Files:**
- Modify: `kernel/kernel.asm` — add data buffer + `linux_syscall_trace` routine + `linux_syscall_unimpl` handler.

- [ ] **Step 1: Define the trace ring-buffer + counters (data section)**

Add near the other syscall state (~`kernel.asm:11768`):

```nasm
LINUX_TRACE_SLOTS      equ 64
LINUX_TRACE_ENTRY_BYTES equ 32            ; nr, 6 args, ret = 8 dwords
linux_trace_buffer     times (LINUX_TRACE_SLOTS * LINUX_TRACE_ENTRY_BYTES) db 0
linux_trace_head       dd 0               ; next slot index
linux_trace_count      dd 0               ; total syscalls seen (guest-status proof)
linux_last_unimpl_nr   dd 0               ; last ENOSYS syscall number (guest-status proof)
```

- [ ] **Step 2: Write `linux_syscall_trace` (record one entry)**

Records `(nr=EAX, args EBX/ECX/EDX/ESI/EDI/EBP, ret)` into the ring buffer. Mirror the `pushad`/`popad` convention used throughout (see `process_fpu_reset_context` at 19085). Increment `linux_trace_count`. This routine is called on entry (args) and patched with ret on exit; simplest first version records on entry only.

```nasm
; esi-free scratch routine; preserves all regs
linux_syscall_trace:
    pushad
    mov edi, [linux_trace_head]
    imul edi, edi, LINUX_TRACE_ENTRY_BYTES
    lea edi, [linux_trace_buffer + edi]
    mov [edi + 0], eax            ; nr
    mov [edi + 4], ebx
    mov [edi + 8], ecx
    mov [edi + 12], edx
    mov [edi + 16], esi
    mov [edi + 20], ebp           ; (edi original captured below)
    mov eax, [esp + 4]            ; original edi from pushad frame
    mov [edi + 24], eax
    inc dword [linux_trace_count]
    mov eax, [linux_trace_head]
    inc eax
    cmp eax, LINUX_TRACE_SLOTS
    jb .store
    xor eax, eax
.store:
    mov [linux_trace_head], eax
    popad
    ret
```

- [ ] **Step 3: Write `linux_syscall_unimpl` (default handler → -ENOSYS)**

```nasm
LINUX_ENOSYS equ 38
linux_syscall_unimpl:
    mov [linux_last_unimpl_nr], eax
    call linux_syscall_trace
    mov eax, -LINUX_ENOSYS        ; -38 in EAX (negative-errno convention)
    ret
```

- [ ] **Step 4: Verify it assembles**

Run: `cd ~/Documents/vibe-os && make` (or the project's assemble target — check `Makefile`).
Expected: builds with no NASM errors. (No behavior change yet — not wired in.)

- [ ] **Step 5: Commit**

```bash
git add kernel/kernel.asm
git commit -m "feat(linux-personality): add syscall tracer + ENOSYS default handler"
```

---

## Task 2: Per-process personality flag + dispatch branch

**Files:**
- Modify: `kernel/kernel.asm` — add `PROC_PERSONALITY` field, equates, and a branch at the top of the `int 0x80` dispatch (~22429).

- [ ] **Step 1: Add personality equates + a process-record field**

Process records are `PROCESS_RECORD_BYTES equ 184` (line 616) with fields up to `PROC_HEAP_PAGE_COUNT equ 180`. Add a new field; if 184 is full, bump the record size (and audit every `times`/record allocation that uses `PROCESS_RECORD_BYTES`).

```nasm
PERSONALITY_NATIVE equ 0
PERSONALITY_LINUX  equ 1
PROC_PERSONALITY   equ 184          ; new field; bump PROCESS_RECORD_BYTES to 188
```

Change `PROCESS_RECORD_BYTES equ 184` → `equ 188` and re-verify all record-array reservations.

- [ ] **Step 2: Default new processes to NATIVE**

In `process_seed_initial_user_context` (19004), before the final `ret`, add:

```nasm
    mov dword [esi + PROC_PERSONALITY], PERSONALITY_NATIVE
```

(esi = process record pointer in that routine.)

- [ ] **Step 3: Branch the dispatcher on personality**

At the **top** of the `int 0x80` dispatch (immediately before the first `cmp eax, SYS_USER_PROBE` at ~22429), insert:

```nasm
    push ebx
    mov ebx, [current_process_ptr]
    cmp dword [ebx + PROC_PERSONALITY], PERSONALITY_LINUX
    pop ebx
    jne .native_dispatch          ; existing chain continues here (label the existing chain)
    jmp linux_syscall_dispatch    ; new Linux path (Task 5 fills the table)
.native_dispatch:
```

Add label `.native_dispatch:` so the existing `cmp eax, SYS_USER_PROBE` chain is its target.

- [ ] **Step 4: Stub `linux_syscall_dispatch` to route everything to unimpl**

```nasm
linux_syscall_dispatch:
    call linux_syscall_trace
    jmp linux_syscall_unimpl      ; every Linux syscall logs + returns -ENOSYS for now
```

- [ ] **Step 5: Verify it assembles + native still boots**

Run: `make && <project QEMU target>` (check `Makefile`/`tools/` for the run recipe).
Expected: vibe-os boots; Doom/Quake/native probes behave exactly as before (no process is `LINUX` yet, so the new branch is never taken).

- [ ] **Step 6: Commit**

```bash
git add kernel/kernel.asm
git commit -m "feat(linux-personality): per-process personality flag + dispatch branch"
```

---

## Task 3: Host-side test binary + rootfs tooling

**Files:**
- Create: `tests/linux/hello_write.asm`, `tests/linux/Makefile`, `tools/mkrootfs.sh`.

- [ ] **Step 1: Write the hand-asm static test binary (`tests/linux/hello_write.asm`)**

A freestanding i386 Linux binary using raw `int 0x80` — no libc, so it isolates the loader + the two syscalls. (i386 numbers: `write=4`, `exit=1`.)

```nasm
; build: as --32 hello_write.asm -o hello_write.o && ld -m elf_i386 hello_write.o -o hello_write
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

- [ ] **Step 2: Write `tests/linux/Makefile`**

```make
AS = as --32
LD = ld -m elf_i386
all: hello_write auxv_dump
hello_write: hello_write.asm
	$(AS) $< -o hello_write.o && $(LD) hello_write.o -o $@
auxv_dump: auxv_dump.asm
	$(AS) $< -o auxv_dump.o && $(LD) auxv_dump.o -o $@
clean:
	rm -f *.o hello_write auxv_dump
```

- [ ] **Step 3: Write `tools/mkrootfs.sh`** (copy binaries into the FAT image at known paths)

```sh
#!/bin/sh
# Usage: tools/mkrootfs.sh <fat-image-path>
# Copies test binaries to /BIN on the guest FAT image.
set -e
IMG="$1"
make -C tests/linux
# Use the project's existing FAT image populate step (mtools or loopback);
# mirror how Doom WADs are placed. Target guest path: /BIN/HELLO, /BIN/AUXVD
mcopy -o -i "$IMG" tests/linux/hello_write ::/BIN/HELLO
mcopy -o -i "$IMG" tests/linux/auxv_dump   ::/BIN/AUXVD
```

(Adapt the copy mechanism to however the repo currently injects guest files — check `Makefile`/`tools/` for the existing FAT-populate path and reuse it.)

- [ ] **Step 4: Verify the binary builds and is a valid ELF32**

Run: `make -C tests/linux && file tests/linux/hello_write`
Expected: `ELF 32-bit LSB executable, Intel 80386, statically linked`.

- [ ] **Step 5: Commit**

```bash
git add tests/linux/hello_write.asm tests/linux/Makefile tools/mkrootfs.sh
git commit -m "test(linux-personality): static hello_write binary + rootfs tooling"
```

---

## Task 4: Linux ELF32 loader (static PT_LOAD) + minimal stack

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

Run: `make -C tests/linux && tools/mkrootfs.sh <img> && make LINUX_M1_SMOKE=1 && <run QEMU>`
Expected console: `hello from linux personality`, and the guest exit-status field reads `42`. Confirm `linux_trace_count` ≥ 2.

- [ ] **Step 6: Commit**

```bash
git add kernel/kernel.asm
git commit -m "feat(linux-personality): ELF32 static loader + minimal stack + write/exit"
```

---

## Task 5: Full auxv builder

**Files:**
- Modify: `kernel/kernel.asm` — extend stack builder with the complete auxv glibc/musl require.

- [ ] **Step 1: Write `tests/linux/auxv_dump.asm`** (verifies auxv before any libc depends on it)

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

- [ ] **Step 2: Add the auxv equates**

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

- [ ] **Step 3: Extend `linux_build_initial_stack` to append the full auxv**

After the envp NULL, write `(type,value)` dword pairs terminated by `AT_NULL,0`:
  - `AT_PHDR` = user vaddr of the program headers (`e_phoff` mapped into the image's load address), `AT_PHENT` = `e_phentsize`, `AT_PHNUM` = `e_phnum` (carry these out of `linux_exec_load_elf`).
  - `AT_PAGESZ`=4096, `AT_BASE`=0 (no interpreter for static), `AT_FLAGS`=0, `AT_ENTRY`=`e_entry`, `AT_UID/EUID/GID/EGID`=0, `AT_HWCAP`= a conservative value (e.g. just `FPU` bit; do **not** advertise features you don't emulate), `AT_CLKTCK`=100, `AT_SECURE`=0.
  - `AT_RANDOM` = pointer to 16 real random bytes placed on the stack (glibc reads these for stack canaries — **mandatory**; omitting it aborts glibc). Generate via the existing RNG / `clock` entropy.
  - `AT_EXECFN` = pointer to the program path string on the stack.
  - **Do not** emit `AT_SYSINFO`/`AT_SYSINFO_EHDR` → glibc falls back to `int 0x80` (no vDSO needed).

- [ ] **Step 4: Verify in QEMU**

Run the `auxv_dump` binary as the smoke target.
Expected: console shows `AT_PHDR`, `AT_PHNUM`, `AT_ENTRY`, `AT_PAGESZ=4096`, `AT_RANDOM` (non-zero pointer) lines, terminates cleanly (exit 0).

- [ ] **Step 5: Commit**

```bash
git add kernel/kernel.asm tests/linux/auxv_dump.asm tests/linux/Makefile
git commit -m "feat(linux-personality): full auxv builder + auxv_dump test"
```

---

## Task 6: TLS via `set_thread_area` (GS base)

**Files:**
- Modify: `kernel/kernel.asm` — add `set_thread_area` handler + a per-process GDT TLS descriptor; load GS on context switch.

- [ ] **Step 1: Reserve a GDT entry for user TLS**

Find the GDT setup (search `gdt`). Add one user-DPL3 data descriptor (the "TLS" slot). i386 glibc/musl set up a `struct user_desc` and call `set_thread_area(243)`; the kernel fills a GDT/LDT entry and returns its `entry_number`. Reserve a fixed entry index for the single-threaded M-1 case.

- [ ] **Step 2: Implement `set_thread_area` (number 243)**

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

- [ ] **Step 3: Load GS with the TLS selector for Linux processes**

In `process_activate` (19152) — which already restores segment regs — ensure that for `PERSONALITY_LINUX` processes, `GS` is loaded with the TLS selector (RPL 3) after the descriptor is set. (Native processes keep `USER_DATA_SEG` in GS as today.)

- [ ] **Step 4: Verify with a TLS-touching binary**

Write a tiny static binary that calls `set_thread_area`, loads `gs`, and reads `mov eax, [gs:0]` from a value it stored at its TLS base; write the value out. Run in QEMU.
Expected: the value round-trips (proves GS base is live). Trace shows syscall 243 returning 0.

- [ ] **Step 5: Commit**

```bash
git add kernel/kernel.asm tests/linux/tls_probe.asm
git commit -m "feat(linux-personality): set_thread_area + GS-based TLS"
```

---

## Task 7: Remaining static-glibc startup syscalls + grow limits

**Files:**
- Modify: `kernel/kernel.asm` — add the syscalls glibc's static startup touches; grow exec limits.

- [ ] **Step 1: Grow the small limits**

Raise the exec limits that block real binaries (anchors at 844, 919–934): `SYS_EXEC_PATH_MAX 64`→`4096`, `SYS_EXEC_ARG_MAX 8`→`64` (or more), `SYS_EXEC_ARG_STR_MAX 64`→`4096`, `SYS_EXEC_ENV_MAX 8`→`64`, `SYS_EXEC_ENV_STR_MAX 64`→`4096`. Re-audit any fixed buffers sized off these (grep their uses) and enlarge the backing storage.

- [ ] **Step 2: Map the startup syscalls into `linux_syscall_dispatch`**

Add `cmp eax, N / je handler` for each (i386 numbers), reusing native handlers where one exists:

| Linux nr | Syscall | Implementation |
|---|---|---|
| 252 | `exit_group` | same teardown as `exit` (1) |
| 45 | `brk` | reuse native `SYS_SBRK (5)` against `PROC_BRK/HEAP_START/END`; Linux `brk` returns the *new break* (or current if arg=0), not an error |
| 192 | `mmap2` | anonymous private map via `vmm_map_page`; offset is in **pages**; back `MAP_ANONYMOUS` from the process heap arena |
| 91 | `munmap` | reuse native `SYS_MUNMAP (21)` |
| 125 | `mprotect` | set page perms on an existing range (no-op-safe if perms already satisfy) |
| 258 | `set_tid_address` | store pointer, return a fake tid (e.g. `PROC_PID`) |
| 175 | `rt_sigprocmask` | store/return mask; no delivery yet (return 0) |
| 54 | `ioctl` | `TCGETS` on fd 1 → `-ENOTTY` (25) so glibc picks block buffering |
| 355 | `getrandom` | fill buffer from the same RNG used for `AT_RANDOM`; return count |
| 85/305 | `readlink(at)` | `/proc/self/exe` → the program path; else `-ENOENT` |

Anything else still hits `linux_syscall_unimpl` (logged) — that's the discovery mechanism for later milestones.

- [ ] **Step 3: Build the M-1 acceptance binary — a *real* static glibc hello**

Build on the host: `gcc -m32 -static hello.c -o hello_glibc` (or `musl-gcc -static` first, which has a smaller surface — recommended as the very first real-libc binary). Copy to `/BIN/HELLOG` via `tools/mkrootfs.sh`.

```c
#include <stdio.h>
int main(void){ printf("hello, glibc on vibe-os\n"); return 7; }
```

- [ ] **Step 4: Run it in QEMU (the M-1 acceptance test)**

Run: build musl-static first, then glibc-static, as the smoke target.
Expected: console prints `hello, glibc on vibe-os`; guest exit-status field = `7`; tracer shows the startup sequence (`brk`, `set_thread_area`, `set_tid_address`, `mmap2`, `ioctl→ENOTTY`, `write`, `exit_group`) and **no `-ENOSYS`** for this binary (`linux_last_unimpl_nr` unchanged).

- [ ] **Step 5: Commit**

```bash
git add kernel/kernel.asm tests/linux/
git commit -m "feat(linux-personality): static glibc/musl hello runs end-to-end (M-1 complete)"
```

---

## M-1 Done — Definition of Done

- [ ] An unmodified hand-asm static binary runs (`write`+`exit`, status propagates).
- [ ] An `auxv_dump` binary confirms the full auxv is correct.
- [ ] TLS works (`set_thread_area` + `gs:0` round-trip).
- [ ] A **statically-linked musl and glibc** "hello world" runs to completion with correct stdout and exit status, hitting **zero `-ENOSYS`**.
- [ ] Native (Doom/Quake) programs are unaffected.
- [ ] Each task committed separately; no disk images in git.

**Next:** `docs/specs/2026-05-29-linux-personality-design.md` → write the **M0 plan** (dynamic linker: `PT_INTERP`, ld.so, the file-I/O syscall set, RELRO `mprotect`, `/lib/ld-linux.so.2` + `libc.so.6` on the FAT image).

---

## Self-Review notes (author)

- **Spec coverage:** Covers spec §6 "M-1" fully (loader, stack, auxv, TLS, the listed syscalls, limits) and §7 test corpus order (hand-asm → auxv-dump → musl/glibc static). M0/M1 explicitly deferred to their own plans per the spec's milestone split.
- **Known soft spots (honest):** Asm bodies for `linux_exec_load_elf`, `linux_build_initial_stack`, and `set_thread_area` are given as precise structure + standard ELF/`user_desc` offsets rather than line-complete NASM, because they extend deep existing routines (`process_exec_prepare_elf_image`, `process_activate`, the GDT setup) whose internal register/stack conventions must be read and mirrored at implementation time. Every such task names the exact anchor to model on. The *new self-contained* code (tracer, ENOSYS, personality flag + dispatch branch, auxv entries/equates, test binaries) is literal.
- **Type/name consistency:** `PROC_PERSONALITY`, `PERSONALITY_LINUX`, `linux_syscall_dispatch`, `linux_syscall_trace`, `linux_syscall_unimpl`, `linux_exec_load_elf`, `linux_build_initial_stack` used consistently across tasks.
