# Process Exec And Launch

The boot path still routes Doom through the generic exec table, but `SYS_EXEC`
is no longer just a loader helper. It now prepares a table-supported image,
builds a scheduler-visible user context for the target process record, patches
the live syscall return frame, and `iretd`s into the target instead of returning
to the caller.

## Loader Contract

- `process_exec_table` currently recognizes `DOOM.ELF` and `USERPROB.ELF`.
  Each entry names the public path, FAT 8.3 root entry, load buffer, byte limit,
  and reusable process slot. Doom stays table-backed because it needs the larger
  Doom address window; the boot probe stays table-backed because it owns the
  initial probe address window.
- If a path is not in the table, `process_exec_resolve_generic_root83` parses a
  root-level FAT16 8.3 path, accepts only `.ELF` files, resolves it through the
  FAT root directory, and loads it into the reusable probe-class user process
  window. This makes `SYS_EXEC("HELLO.ELF")` a real FAT16 lookup instead of a
  hard-coded string table miss, while still rejecting subdirectories, long
  names, and non-ELF payloads.
- `process_exec_path` resolves the copied path through the table or generic
  root-ELF fallback, rejects an active target slot when syscall mode requests
  active-process safety, loads the file through the common FAT reader, validates
  ELF magic, and delegates segment preparation to the matching user-image
  parser.
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
- Non-table `.ELF` paths currently target the reusable probe-class slot. That
  means Doom can exec a small root-level user utility from FAT16, but a running
  probe-class process still cannot replace itself through the same slot until
  the kernel grows another child slot or true in-place `exec` overlay semantics.
- Before loading the target image, the kernel tears down stale user PTEs for the
  target slot, restores only its writable stack window, assigns the slot a fresh
  PID from `process_next_pid`, and increments the slot generation. That keeps
  the table-supported launch path bounded while making slots reusable instead of
  permanently tied to one fixed PID.
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
  `UNUSED`, and reports the stored exit status. `WNOHANG` is now a real
  nonblocking check: if a matching child is live but not reapable, it returns
  `0`; the blocking form still returns `ENOSYS` until there is a sleep queue.
- Open fd slots are now process-owned. `fd_lookup` rejects descriptors whose
  owner PID does not match the running process, `exec` retags slots marked
  `FD_INHERIT_EXEC` from the caller PID to the target PID, and slots without
  that bit are closed on exec. Process teardown, fault handling, target-slot
  reuse, and wait reaping all sweep descriptors owned by the retiring process.
  This is real exec-time fd inheritance/close-on-exec behavior, not yet
  fork-time descriptor duplication.
- The initial Ring 3 probe is bootstrapped through the same stack builder before
  entering crt0. It receives `argc == 1`, `argv[0] == "USERPROB.ELF"`,
  `argv[1] == NULL`, and an empty `envp`, then verifies that `getpid()` reports
  its fixed process id from user mode.
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
instead of only proving that bytes were loaded.

## Status And Rollback Counters

Smoke status still includes `exec=OK path=...`, and `execsys=` now reports:

`attempts/successes/failures/handoffs/scheduled/rollbacks`

The same status line also records `execerr=<errno>`, `execres=<syscall result>`,
`target=<pid>`, `ppid=<pid>`, `entry=<eip>`, `stack=<esp>`, `argc=<n>`,
`argv=<ptr>`, `envp=<ptr>`, `argv0=<ptr>`, `envp0=<word>`, and
`argvsrc=<source>`. A successful Doom launch should have zero
`execerr`/`execres`, nonzero argc/argv/envp pointers, `envp0 == 0`, nonzero
target entry/stack addresses, and `argvsrc=2` for the user-vector path. The
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

The user probe also carries a negative syscall probe bit. Before it execs Doom,
it verifies that an unknown syscall returns `-ENOSYS`, impossible anonymous
`mmap` requests return `-EINVAL`, invalid `munmap` ranges return `-EINVAL`, and
`waitpid` rejects an invalid user status pointer with `-EINVAL`. That keeps the
early POSIX-shaped ABI honest about classified errors without injecting failed
`SYS_EXEC` attempts into the real-WAD proof counters.

## Remaining Gaps

- Exec now accepts arbitrary root-level FAT16 `.ELF` paths for the probe-class
  user window, but it is not a full path resolver: there are no directories,
  long filenames, interpreter/shebang handling, environment copying, or
  dynamically chosen address-space classes.
- A generic executable still lands in the reusable probe-class slot. There is no
  pool of dynamic process records, so self-reexec for that slot is rejected and
  non-Doom user utilities share one bounded memory layout.
- `argv` copying is intentionally bounded to a small static vector; environment
  copying is not implemented yet, so libc exposes an empty `envp` contract.
- Page-table structures and process records are still static, but exec targets
  now reuse slots with fresh PIDs and teardown of stale user PTEs. Tail
  brk-backed `munmap` can reclaim process heap PTEs, and empty PMM-backed VMM
  page tables are returned to the frame allocator after unmap. There is not yet
  dynamic child-slot growth or general physical-frame reclamation for
  identity-shaped user pages.
- This is enough to launch the probe and Doom, preserve inheritable fds across
  exec, close process-owned fds during teardown, and reap exited child records,
  but it is not a robust Unix process model. There is no `fork`/`exec` split,
  wait blocking, process groups, signal delivery, fork-time fd duplication,
  dynamic child slots, or file-backed VM object lifetime.
