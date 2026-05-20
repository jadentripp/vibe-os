# Process Virtual Memory

The kernel now keeps explicit address-space metadata per process:

- each process record has a page-directory physical address
- each process record has a dedicated Ring 0 stack top loaded into `tss_esp0`
  by `process_activate`
- user processes have VM region tables with base, end, and
  read/write/execute-intent flags
- heap pages become user-accessible as `sbrk` advances the process `brk`
- syscall pointer validation walks the current process region table

The boot kernel still uses identity-mapped physical memory, but the page
permissions are no longer one flat user window. The kernel page directory maps
low memory as supervisor writable pages. User process page directories clone the
kernel mapping, then replace only the user-owned PDEs with private page tables
whose PTEs carry the user bit. Page-table helpers now accept explicit user
read-vs-write PTE flags; writable user pages use `PTE_WRITE`, while
read/execute-only pages can be re-marked without it.

## Current Address Spaces

`process_user_probe` owns:

- packed code/data: `USER_CODE_ADDR` through `USER_STACK_BOTTOM`
- stack: `USER_STACK_BOTTOM` through `USER_STACK_TOP`
- heap: `USER_HEAP_START` through the current probe `brk`
- page directory: `PROC_PROBE_PAGE_DIR_ADDR`

`process_preempt_probe` is a second non-Doom scheduler probe record. It uses
the same minimal probe VM contract but has its own PID and kernel stack top, so
host contracts can prove that the round-robin selector has an eligible
alternate target without depending on Doom internals or real WAD data.

`process_doom` owns:

- loaded Doom image: `DOOM_USER_BASE` through `DOOM_USER_HEAP_START`
- heap: `DOOM_USER_HEAP_START` through the current Doom `brk`
- stack: `DOOM_USER_STACK_BOTTOM` through `DOOM_USER_STACK_TOP`
- page directory: `PROC_DOOM_PAGE_DIR_ADDR`

The probe address space has cloned PDE 3 only. The Doom address space has
cloned PDEs 4 through 7 only. Kernel mappings remain supervisor-only in both
address spaces, so a Ring 3 access to kernel pages, or to another process's
user window, faults instead of passing the page-table permission check.

Heap windows are reserved in the process metadata, but they are not all granted
to Ring 3 at process start. `SYS_SBRK` marks the newly covered heap pages with
the user bit and flushes the active CR3 before returning to user mode. The
syscall validator also checks heap pointers against the current process `brk`.

`SYS_MMAP` currently shares that heap window rather than allocating independent
VM objects. It accepts only anonymous/private mappings, rounds the requested
length to whole pages, marks the new pages in the current process page
directory, zero-fills the returned range, and advances `brk`. `SYS_MUNMAP`
validates that the range belongs to the current process, then returns success
without reclaiming pages. That keeps the ABI useful for ports that expect
`mmap` as an allocator while avoiding fake file mapping or clone-era lifetime
semantics.

## Process Lifecycle

Process records now carry enough saved-frame state for both timer preemption
and syscall-driven exec handoff. `process_seed_initial_user_context` initializes
the saved Ring 3 frame for a fresh target, marks it READY, and sets
`PROC_FLAG_IRQ_FRAME_VALID`. `SYS_EXEC` uses that helper, writes an argv-shaped
stack, patches the interrupted syscall frame, marks the caller EXITED, and then
activates the target process record. Failure paths before frame patch leave the
current process in place.

## Permissions

The kernel records source-level region intent with `VM_REGION_READ`,
`VM_REGION_WRITE`, and `VM_REGION_EXEC`. On current x86 paging there is no NX
bit, so execute permission is metadata only, but write permission is real: the
ELF prepare path reads each `PT_LOAD` program header's `p_flags` and marks pages
without `ELF_PF_W` as user-readable but not writable. Writable segments, stacks,
and pages newly exposed by `SYS_SBRK` are marked with `PTE_WRITE`.

The repo linker emits separate `PT_LOAD` groups for executable, read-only, and
writable allocated sections where those groups exist. Text-bearing segments are
`PF_R|PF_X` and omit `PF_W`, while data and bss are carried by `PF_R|PF_W`
segments. The user ELF prepare paths honor those flags when marking process
pages, so text pages no longer need to remain writable just because data exists
in the same executable.

## Guards

The probe process clears a not-present guard page immediately before
`USER_CODE_ADDR` and immediately after `USER_HEAP_END`. Doom's post-window guard
is the unmapped PDE after `DOOM_USER_END`. More precise stack red zones are
still blocked by the current packed user layouts, where the probe stack and heap
are adjacent and the Doom heap grows up to the stack bottom.

## Remaining Gaps

- The design still uses identity-mapped physical frames rather than relocating
  per-process user pages onto arbitrary PMM frames.
- Timer IRQ preemption now has an end-to-end restore path for saved Ring 3
  interrupt frames: the scheduler can save the interrupted task, pick another
  READY task with a valid saved frame, switch CR3 through `process_activate`,
  load that task's kernel stack into `tss_esp0`, rewrite the live IRQ frame,
  and resume it with `iretd`. The source-level self-test now uses the same
  seeded-context helper as exec for the alternate probe, so a process that was
  launched rather than timer-saved has the same scheduler-visible frame shape.
- Page-table structures are fixed low-memory page-table pages, not dynamically
  allocated or reclaimed with process lifetime.
- Exact execute-disable enforcement is still blocked by the current 32-bit x86
  paging mode: `VM_REGION_EXEC` and `PF_X` are metadata until the kernel grows
  hardware NX or a different paging mode. Write protection is enforced today.
