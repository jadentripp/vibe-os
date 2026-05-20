# Process Virtual Memory

The kernel now keeps explicit address-space metadata per process:

- each process record has a page-directory physical address
- user processes have VM region tables with base, end, and flags
- heap pages become user-accessible as `sbrk` advances the process `brk`
- syscall pointer validation walks the current process region table

The boot kernel still uses identity-mapped physical memory, but the page
permissions are no longer one flat user window. The kernel page directory maps
low memory as supervisor writable pages. User process page directories clone the
kernel mapping, then replace only the user-owned PDEs with private page tables
whose PTEs carry the user bit.

## Current Address Spaces

`process_user_probe` owns:

- code/data/stack: `USER_CODE_ADDR` through `USER_STACK_TOP`
- heap: `USER_HEAP_START` through the current probe `brk`
- page directory: `PROC_PROBE_PAGE_DIR_ADDR`

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
  rewrite the live IRQ frame, and resume it with `iretd`. The current boot flow
  still needs a second long-lived runnable user task before Doom can demonstrate
  frequent real task-to-task switches instead of mostly reporting no eligible
  saved-frame candidate.
- Page-table structures are fixed low-memory pages, not dynamically allocated
  or reclaimed with process lifetime.
- User page permissions are writable for now. The ELF loader does not split
  text read/execute from data/write permissions yet.
