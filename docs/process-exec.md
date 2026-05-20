# Process Exec And Launch

The boot path still routes Doom through the generic exec table, but `SYS_EXEC`
is no longer just a loader helper. It now prepares a table-supported image,
builds a scheduler-visible user context for the target process record, patches
the live syscall return frame, and `iretd`s into the target instead of returning
to the caller.

## Loader Contract

- `process_exec_table` currently recognizes `DOOM.ELF` and `USERPROB.ELF`.
  Each entry names the public path, FAT 8.3 root entry, load buffer, byte limit,
  and fixed process record.
- `process_exec_path` resolves the copied path through that table, rejects an
  active target slot when syscall mode requests active-process safety, loads the
  file through the common FAT reader, validates ELF magic, and delegates segment
  preparation to the matching user-image parser.
- Failure paths set `process_exec_last_error` before returning carry, so syscall
  error handling can distinguish invalid paths, missing files, unsafe active
  target reloads, and loader/ELF I/O failures.

## `SYS_EXEC` Handoff

- The syscall validates and copies a bounded user path into
  `sys_exec_path_buffer`.
- The current ABI accepts `path`, an optional user `argv`, and zero flags.
  Nonzero flags return `-EINVAL`. `argv == NULL` falls back to a single
  `argv[0]` copied from the exec path; a non-null vector is copied into kernel
  staging buffers before the old address space is replaced.
- It asks `process_exec_path` for a table-backed target while
  `process_exec_reject_active_target` is set. This prevents reloading the image
  backing the currently running process, because a partial reload could not be
  rolled back safely.
- On success, `process_exec_handoff_current` resets the target process record,
  stores the prepared ELF entry, seeds `PROC_SAVED_EIP`, `PROC_SAVED_ESP`,
  selectors, `EFLAGS`, and `PROC_FLAG_IRQ_FRAME_VALID`, and writes a real
  `argc`, `argv[]`, `NULL`, `envp NULL` stack layout from the bounded staged
  arguments.
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
- The fixed-slot model means this is a process replacement/switch rather than a
  Unix-style PID-preserving address-space overlay. The old caller stops running;
  the table target's fixed process record becomes current.

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
`target=<pid>`, `entry=<eip>`, `stack=<esp>`, `argc=<n>`, `argv=<ptr>`, and
`argv0=<ptr>`. A successful Doom launch should have zero `execerr`/`execres`,
nonzero argc/argv pointers, and nonzero target entry/stack addresses.

Failures before frame patch leave the active process current and increment the
rollback counter. Unsafe active-slot exec returns `-EACCES`; invalid pointers
return `-EINVAL`; missing table/FAT paths return `-ENOENT`; loader/ELF failures
return `-EIO`.

## Remaining Gaps

- Exec targets are still fixed table entries instead of arbitrary FAT paths.
- `argv` copying is intentionally bounded to a small static vector; environment
  copying is not implemented yet, so libc exposes an empty `envp` contract.
- Page-table structures and process records are static; there is no dynamic PID
  allocation or address-space reclamation.
