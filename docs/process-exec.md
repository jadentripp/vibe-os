# Process Exec And Launch

The boot path now routes both the initial Ring 3 probe and Doom through the
generic exec table, and the boot probe now chains through a packaged
`ABIPROBE.ELF` before Doom. `SYS_EXEC` is no longer just a loader helper: it prepares a
table-supported image, builds a scheduler-visible user context for the target
process record, patches the live syscall return frame, and `iretd`s into the
target instead of returning to the caller.

## Loader Contract

- `process_exec_table` currently recognizes `DOOM.ELF` and `USERPROB.ELF`.
  Each entry names the public path, FAT 8.3 root entry, load buffer, byte limit,
  and reusable process slot. Doom stays table-backed because it needs the larger
  Doom address window; the boot probe stays table-backed because it owns the
  initial probe address window.
- If a path is not in the table, `process_exec_resolve_generic_root83` parses a
  root-level FAT16 8.3 path, accepts only `.ELF` files, normalizes leading root
  separators and `./` current-directory prefixes, allocates one of the bounded
  generic user slots, resolves the file through the FAT root directory, and
  loads it into that probe-class address window. This makes
  `SYS_EXEC("HELLO.ELF")` and `SYS_EXEC("./HELLO.ELF")` real FAT16 lookups with
  reusable targets selected at runtime instead of hard-coded string table
  misses, while still rejecting subdirectories, long names, and non-ELF
  payloads.
- `process_exec_path` resolves the copied path through the table or generic
  root-ELF fallback, rejects an active target slot when syscall mode requests
  active-process safety, loads the file through the common FAT reader, validates
  ELF magic, and delegates segment preparation to the matching user-image
  parser.
- The storage boot path no longer preloads `USERPROB.ELF` or `DOOM.ELF` through
  image-specific FAT helpers. The first probe is prepared by
  `process_exec_path("USERPROB.ELF")`; the probe then reaches Doom with
  `SYS_EXEC("DOOM.ELF")`.
- Failure paths set `process_exec_last_error` before returning carry, so syscall
  error handling can distinguish invalid paths, missing files, unsafe active
  target reloads, and loader/ELF I/O failures.

## `SYS_EXEC` Handoff

- The syscall validates and copies a bounded user path into
  `sys_exec_path_buffer`.
- The current ABI accepts `path`, an optional user `argv`, and zero flags.
  Nonzero flags return `-EINVAL`. `argv == NULL` falls back to a single
  `argv[0]` copied from the exec path; a non-null vector is copied into kernel
  staging buffers before the old address space is replaced. The boot probe now
  launches Doom with an explicit one-entry user `argv` vector, so the Doom exec
  proof exercises the pointer-vector copy path instead of only the fallback
  path.
- It asks `process_exec_path` for a table-backed target while
  `process_exec_reject_active_target` is set. This prevents reloading the image
  backing the currently running process, because a partial reload could not be
  rolled back safely.
- Non-table `.ELF` paths currently target a bounded generic probe-class pool,
  specifically a two-entry generic probe-class pool.
  That means Doom can exec small root-level user utilities from FAT16 without
  clobbering the boot probe record. The pool is still bounded, and a generic
  process exit path is not a full shell/scheduler handoff yet.
- Before loading the target image, the kernel tears down stale user PTEs for the
  target slot, restores only its writable stack window, assigns the slot a fresh
  PID from `process_next_pid`, clears stale parent/exit/argv metadata before any
  destructive load can fail, and increments the slot generation. Table targets
  keep their dedicated slots, while generic root `.ELF` targets are chosen from
  `process_generic_exec_slots` by scanning for `UNUSED` records or orphaned
  `EXITED`/`FAULTED` records.
- On success, `process_exec_handoff_current` resets the target process record
  without changing the freshly allocated PID, stores the prepared ELF entry,
  seeds `PROC_SAVED_EIP`, `PROC_SAVED_ESP`, selectors, `EFLAGS`, and
  `PROC_FLAG_IRQ_FRAME_VALID`, and writes a real `argc`, `argv[]`, `NULL`,
  `envp NULL` stack layout from the bounded staged arguments.
- The target process record also stores exec metadata for later proof and
  accounting: parent PID, exec count, `argc`, `argv`, `envp`, and `argv[0]`.
  These fields are populated from the same stack builder that crt0 consumes.
- `waitpid()` uses that parent PID metadata instead of staying a blanket stub.
  The current implementation scans the static process table for children of the
  calling process, supports `pid == -1` and exact positive PIDs, validates a
  non-null status pointer, reaps `EXITED`/`FAULTED` child records back to
  `UNUSED`, and reports the stored exit status. Faulted children carry an
  abnormal status derived from the fault vector instead of leaking a stale zero
  exit code. `WNOHANG` is now a real nonblocking check: if a matching child is
  live but not reapable, it returns `0`; the blocking form still returns
  `ENOSYS` until there is a sleep queue.
- Open fd slots are now process-owned descriptors over shared open-file
  descriptions. `fd_lookup` rejects descriptors whose owner PID does not match
  the running process, then resolves the descriptor to the shared root slot that
  owns the file offset, kind, flags, and size metadata. `dup`, `dup2`, and
  `dup3` create refcounted descriptors pointing at that root, so reads and
  seeks through either fd observe one offset. `dup3(..., O_CLOEXEC)` makes only
  the new descriptor close-on-exec. `exec` retags inheritable descriptors from
  the caller PID to the target PID and closes descriptors opened or duplicated
  with close-on-exec. Process teardown, fault handling, target-slot reuse, and
  wait reaping all sweep descriptors owned by the retiring process. This is real
  exec-time fd inheritance/close-on-exec behavior with shared descriptions, not
  yet fork-time descriptor duplication.
- The same handoff contract applies to table-backed programs and generic
  root-level `.ELF` programs. Generic userland should treat the public ABI as:
  root-only FAT16 8.3 `.ELF` path, at most `VIBE_EXEC_ARG_MAX` argv strings,
  each bounded by `VIBE_EXEC_ARG_STR_MAX`, an argv pointer vector copied before
  the old address space is retired, an empty `envp` vector seeded by the
  kernel, and inherited descriptors limited to fd slots not opened with
  `O_CLOEXEC`. That is the reusable contract for post-Doom games and tools.
- The initial Ring 3 probe is loaded through `process_exec_path` and
  bootstrapped through the same stack builder before entering crt0. It receives
  `argc == 1`, `argv[0] == "USERPROB.ELF"`, `argv[1] == NULL`, and an empty
  `envp`, then verifies that `getpid()` reports a live user process id.
- The Ring 3 probe arms its intentional page-fault check with a recovery EIP.
  The fault handler records the frame, clears the expectation, rewrites the
  saved exception EIP to the recovery label, drops vector/error from the trap
  stack, and `iretd`s back to user mode so the following `SYS_EXEC("DOOM.ELF")`
  call is reachable.
- Only after the target context and live syscall frame are patched does the
  caller move to `PROC_STATE_EXITED`. The target is installed into
  `scheduler_next_process_ptr`, activated with `process_activate`, and resumed
  through the syscall `iretd` path.
- The old caller stops running; the table target's reusable process slot becomes
  current with its newly assigned PID. This is still not a Unix-style
  PID-preserving address-space overlay.

## Scheduler Proof

`process_seed_initial_user_context` is shared by exec handoff and the scheduler
self-test. It marks the seeded context READY with a valid Ring 3 frame, so the
round-robin selector can pick it just like a timer-saved task. The exec path also
records the selected target in `scheduler_next_process_ptr`/`scheduler_next_pid`
before activation, giving host contracts a concrete scheduler integration point
instead of only proving that bytes were loaded. The timer IRQ path passes the
live `pushad`/interrupt frame pointer into `scheduler_tick`, saves the old user
frame, selects a READY process with a valid Ring 3 frame, switches CR3 and
`tss_esp0` through `process_activate`, restores the selected frame into the IRQ
return slot, and then `iretd`s to that user context. The preemption proof now
records a bidirectional pair mask (`pmask`), source/target process IDs
(`pfrom`/`pto`), switched process kinds (`pkind`), EIPs (`peip`), page
directories (`pcr3`), kernel stacks (`pkstk`), and the rewritten IRQ return
frame (`pframe`) so the cloud gate has to prove Doom/preempt-probe CR3/TSS
switches and a Ring 3 `iretd` target in both directions, not only scheduler
counter increments. The status checker now ties those IDs to the current Doom
exec target PID and the preempt-probe child PID recorded by the wait/reap
proof, which keeps preemption evidence aligned with the current process model
instead of static slot numbers.

## Second Freestanding Program Contract

`user/abi_probe.c` is the in-tree second program proof. It is a freestanding
i386 C program linked with `user/crt0.asm`, exports
`user_main(int argc, char **argv, char **envp)`, uses the public
`doom_port/include/vibe_os.h` ABI constants through `user/runtime.h` and
`user/runtime.c`, so it does not link against Doom or the Doom port runtime.
It checks the crt0 argument/envp handoff, `getpid`, the monotonic clock
syscall, and root `listdir` against `ABIPROBE.ELF`, `USERPROB.ELF`, and
`DOOM.ELF`. When those checks pass, `ABIPROBE.ELF` records its success and then execs `DOOM.ELF`
with the same bounded user argv-vector path; this makes the packaged second
program part of the normal launch chain instead of a disk-only listing.

To launch that program today:

- Build it with the normal host build. The Makefile emits
  `build/abi_probe.elf` and packages it as root `ABIPROBE.ELF`.
- `--root-elf NAME.ELF=PATH` packages additional checked or generated
  root-level 8.3 `.ELF` images without changing the boot path. The
  `tools/make_wad_image.py` builder validates the name shape, rejects protected
  core names, and writes each extra ELF through the same FAT16 cluster allocator
  used by the core images. `ABIPROBE.ELF` uses that hook instead of a
  special-purpose image slot.
- From an existing user process, call `execv("ABIPROBE.ELF", argv)` or the raw
  `SYS_EXEC` ABI with flags zero. The kernel copies the bounded argv vector
  before retiring the caller address space, seeds an empty `envp`, assigns a
  fresh PID, and inherits only descriptors not opened with `O_CLOEXEC`. In the
  checked boot chain, `USERPROB.ELF` execs `ABIPROBE.ELF`; the ABI probe records
  `abiprobe=OK` and then execs Doom, so the later Doom handoff cannot hide
  whether the second freestanding program actually ran.
- In the new image, consume `argc`, `argv`, and `envp` from crt0. Other images
  packaged with `--root-elf`, for example `TOOL.ELF` or `GAME.ELF`, can use
  `getpid`, `waitpid`, `clock_gettime(CLOCK_MONOTONIC)`, `open`/`read`/
  `write`/`stat`/`ftruncate`, `vibe_listdir`, `vibe_poll_input`,
  `vibe_input_status`, `vibe_fb_get_info`, `vibe_present_indexed_checked`, and
  the `SYS_AUDIO` command records without depending on Doom source.

The generic pool is reusable, but it is still small and static. Generic exec is
good enough for a second utility, launcher, or indexed-framebuffer game loaded
from the FAT root. It is not yet enough for a shell that continuously starts
unbounded children, dynamically chooses address-space classes, traverses
directories, or keeps a Unix parent alive across an overlay-style exec.

## Status And Rollback Counters

Smoke status still includes `exec=OK path=...`, and `execsys=` now reports:

`attempts/successes/failures/handoffs/scheduled/rollbacks`

The same status line also records `execerr=<errno>`, `execres=<syscall result>`,
`target=<pid>`, `ppid=<pid>`, `entry=<eip>`, `stack=<esp>`, `argc=<n>`,
`argv=<ptr>`, `envp=<ptr>`, `argv0=<ptr>`, `envp0=<word>`, and
`argvsrc=<source>`. The boot-probe loader proof is separate:
`uexec=OK upath=USERPROB.ELF upid=<pid> uentry=<eip>` records that the initial
probe image used the same exec resolver before it called `SYS_EXEC`. The second
program proof is separate again:
`abiexec=OK abipath=ABIPROBE.ELF abipid=<pid> abippid=<pid> abientry=<eip>
abiargc=1 abiargvsrc=2 abiprobe=OK abiflags=00000007` records that the generic
root `.ELF` resolver selected a bounded generic slot, built the crt0 stack from
a copied user argv vector, ran `user/abi_probe.c`, and observed the probe's
success marker before Doom was launched. It also
emits `procpool=slots/generic/reuses/galloc/gfail`, `pidseq=next/last_reused/generation`,
`fdexec=handoffs/inherited/closed/owner_closes`, `fdup=dup/dup2/dup3/shared/cloexec`, and
`wait=attempts/reaps/failures/nohang/seeded/last_pid/last_status`.
It also emits `vmreap=teardowns/pages/wait_reaps/wait_pages/last_wait_pages`
so the cloud status contract can prove a waited child had its user mappings
cleared before the record became reusable. A successful
Doom launch should have zero `execerr`/`execres`, nonzero argc/argv/envp
pointers, `envp0 == 0`, nonzero target entry/stack addresses, `argvsrc=2` for
the user-vector path, at least one generic-slot allocation for `ABIPROBE.ELF`,
at least one process-slot reuse, at least one fd inherited
across exec, a successful userland `dup`/`dup2`/`dup3` shared-offset probe,
one close-on-exec duplicated descriptor, a userland `waitpid` reap of the
seeded exited child, and a nonzero `vmreap=` wait-reap page count. The
initial probe bootstrap still uses `argvsrc=1` because the kernel supplies its
own default `argv[0]`.

Failures before the target is activated leave the caller current, retire any
resolved target slot that was prepared for reuse, and increment the rollback
counter. If a later handoff step fails after the target address space has been
activated, the kernel switches the caller back to RUNNING, tears down the
half-prepared target slot's user mappings, marks it exited, and then reports the
rollback. That path retires the half-prepared target slot before the syscall
reports failure. Unsafe active-slot exec returns `-EACCES`; invalid pointers return
`-EINVAL`; missing table/FAT paths return `-ENOENT`; loader/ELF failures return
`-EIO`.

The user probe also carries a negative syscall probe bit and a wait/reap probe
bit. Before it execs Doom, the kernel seeds one bounded exited child record
under the probe's PID; the Ring 3 probe reaps it with
`waitpid(-1, &status, WNOHANG)`, checks the stored exit status, then verifies
that the next wait reports `-ECHILD`. It also verifies that an unknown syscall
returns `-ENOSYS`, impossible anonymous `mmap` requests return `-EINVAL`,
invalid `munmap` ranges return `-EINVAL`, and `waitpid` rejects an invalid user
status pointer with `-EINVAL`. That keeps the early POSIX-shaped ABI honest
about classified errors without injecting failed `SYS_EXEC` attempts into the
real-WAD proof counters.

## Remaining Gaps

- Exec now accepts arbitrary root-level FAT16 `.ELF` paths for a bounded generic
  probe-class pool and normalizes root/current-directory prefixes, but it is not
  a full path resolver: userland can list the FAT root and stat the root
  directory, but exec cannot traverse subdirectories, long filenames,
  interpreter/shebang handling, environment copying, or dynamically chosen
  address-space classes.
- Generic executables no longer overwrite the boot probe slot, but the pool is
  still statically sized to two process records and two prebuilt probe-style
  page directories. This is dynamic target selection, not dynamic process-table
  growth.
- `argv` copying is intentionally bounded to a small static vector; environment
  copying is not implemented yet, so libc exposes an empty `envp` contract and
  `execve()` rejects non-empty environments with `ENOSYS`.
- Page-table structures and process records are still static, but exec targets
  now reuse slots with fresh PIDs and teardown of stale user PTEs. Brk-backed
  `munmap` can clear process heap PTEs, track non-tail holes in per-process heap
  bitmaps, and move `brk` backward for tail releases; empty PMM-backed VMM page
  tables are returned to the frame allocator after unmap. There is not yet
  dynamic child-slot growth or general physical-frame reclamation for
  identity-shaped user pages.
- This is enough to launch the probe and Doom, preserve inheritable fds across
  exec, duplicate fds with shared offsets, close process-owned fds during
  teardown, and exercise a userland `waitpid` reap path against a seeded exited child record, but it is not a robust Unix process model.
  There is no `fork`/`exec` split, wait blocking, process groups, signal
  delivery, fork-time descriptor table cloning, unbounded dynamic child slots, or
  file-backed VM object lifetime.
- A fuller game/userland runtime still needs a libc-grade layer above the small
  `user/runtime.*` syscall wrapper seed, hierarchical path lookup, working
  directory state, dynamically sized process and fd tables, blocking scheduler
  waits, signals, threads, richer framebuffer present formats, and audio
  formats beyond the current unsigned 8-bit stereo mixer contract.

## POSIX Gap Decomposition

These gaps are deliberately tracked as contracts, not merely aspirations. Each
row names the current executable behavior and the missing general-OS behavior
that must be added before claiming POSIX compatibility.

| Area | Current contract | Intentionally missing |
| --- | --- | --- |
| `fork` | `SYS_FORK` is wired through the syscall table and returns `-ENOSYS`; libc `fork()` preserves that errno and the user probe checks the classified result. | Address-space cloning, copy-on-write or eager page copies, parent/child return-value split, inherited signal state, and fork-time fd table cloning. |
| fd duplication | Public `dup`, `dup2`, and `dup3` syscalls/libc wrappers create process-owned descriptors that share an open-file description root, including the current offset. `dup2(oldfd, oldfd)` returns the existing descriptor, `dup3(oldfd, oldfd, flags)` returns `EINVAL`, and `dup3(..., O_CLOEXEC)` is closed by the next exec. | Fork-time descriptor table cloning, `fcntl(F_DUPFD*)`, dynamically growing fd tables, and per-process fd namespaces beyond the current bounded global slot pool. |
| file-backed `mmap` | `mmap` is anonymous/private/brk-backed; `munmap` validates mapped heap ranges, reclaims tail pages, and records non-tail holes. | File-backed mappings, `MAP_SHARED`, `MAP_FIXED`, reusable VM object lifetime, VMA splitting/merging, and page-cache backed mappings. |
| signals | User faults become kernel process status and wait-reapable abnormal exits; expected-fault recovery is a probe-only trap rewrite. | `signal`, `sigaction`, `kill`, signal masks, user handler trampolines, timer signals, and delivery across scheduler context switches. |
| terminal/tty | Keyboard and mouse input use the typed input queue; display control uses `ioctl(VIBE_DISPLAY_FD, ...)`, with non-display ioctls classified as `ENOTTY`. | `termios`, `isatty`, controlling terminals, line discipline, process groups, job control, and `/dev/tty*` path/device semantics. |
| dynamic process lifetimes | Generic exec uses a two-entry static probe-class pool, fresh PIDs, slot generations, teardown of stale mappings, and wait reaping for exited/faulted children. | Dynamically allocated process records, unbounded child slots, orphan reparenting, blocking wait queues, long-lived parent shells, and arbitrary address-space classes. |
