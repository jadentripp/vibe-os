# Doom libc runtime contract

The Doom tree under `third_party/doom` stays pristine. The OS-facing runtime
contract lives in `doom_port` and exposes enough POSIX-shaped behavior for
linuxdoom file and stdio use without patching original engine sources.

## Runtime Asset Boundary

The repository carries source code, tests, docs, and generated storage
fixtures, not real Doom game assets. The original engine looks up
`DOOM1.WAD` at runtime through the libc/file syscall path; public builds use a
generated IWAD-shaped fixture, while real-Doom proof runs must provide a local
user-owned or validated shareware WAD outside git with `DOOM_WAD` or the
real-WAD workflow input. The WAD is runtime input, not port source.
Compressed WAD archives such as `*.wad.gz`, `*.wad.zip`, `*.iwad.zip`, and
`*.pwad.zip` are treated as game assets too.

Real-WAD diagnostics must stay copyright-safe: upload status text/binaries,
logs, ELF files, symbols, and aggregate JSON proof only. Do not track or upload
WAD files, disk images, raw audio captures, screenshots, framebuffer dumps, or
rendered pixel artifacts.

## General-Purpose ABI Audit

A second freestanding C program does not need to include Doom headers or call
Doom port hooks. Doom is the first large consumer, but the public surface is the
small `vibe_os.h` syscall ABI plus libc/POSIX-shaped wrappers in
`doom_port/libc.c`.

The reusable surface today is:

- Clock: `VIBE_SYS_CLOCK_GETTIME`, `vibe_clock_monotonic`, and
  `clock_gettime(CLOCK_MONOTONIC)` expose monotonic PIT time for game loops and
  tools. This is not wall-clock time.
- Input: `vibe_poll_input`, `vibe_drain_input`, and `vibe_input_status` expose
  typed keyboard/mouse events and queue health without Doom translation.
- Framebuffer: `vibe_fb_get_info`, `vibe_present_indexed`, and
  `vibe_present_indexed_checked` expose the discoverable indexed-present
  contract through `VIBE_DISPLAY_FD` and display ioctls.
- Audio: `SYS_AUDIO` accepts generic `vibe_audio_voice_desc_t` voice commands
  and reports `vibe_audio_device_info_t` / `vibe_audio_pcm_ring_info_t` device
  state. Doom WAD SFX and music parsing remain only one caller of that mixer.
- Generic file consumers can use `open`, `read`, `write`, `lseek`, `close`,
  `dup`, `dup2`, `dup3`, `stat`, `fstat`, `unlink`, `ftruncate`, `truncate`,
  `vibe_listdir`, `vibe_file_size`, and `vibe_file_read_all` against the
  current FAT16 root model.
- Process code can use `execv`/`execve`, `getpid`, `wait`/`waitpid`, and the
  explicit `fork()` `ENOSYS` result. `argv` is bounded by `VIBE_EXEC_*`, `envp`
  is empty, and descriptors inherit across exec unless opened with
  `O_CLOEXEC`.

## Clock And Time

vibe-os owns a small monotonic clock service backed by the PIT timer interrupt.
The PIT is programmed for 100 Hz, so one kernel tick is 10 milliseconds.

The reusable user/kernel contract is `VIBE_SYS_CLOCK_GETTIME` with
`VIBE_CLOCK_MONOTONIC`. It fills `vibe_clock_time_t` with:

- `ticks`: raw monotonic PIT ticks since boot.
- `frequency_hz`: currently `100`.
- `milliseconds`: monotonic milliseconds since boot, derived from ticks.
- `flags`: reserved, currently zero.

This is not wall-clock time. The CMOS/RTC path is not exposed as libc time, and
no API currently claims calendar seconds, timezone, or persistence across boots.

The Doom port consumes this general clock through `vibe_monotonic_milliseconds`
and converts milliseconds to Doom's 35 Hz `I_GetTime` value in the port layer.
The legacy `VIBE_SYS_TIME` syscall still returns Doom tics for compatibility,
but new consumers should use the monotonic clock API.

Cloud slowdown proof uses this same monotonic contract without treating it as
wall-clock time. The status-only long-run cadence checker compares Doom-facing
`gtic`, `leveltime`, and `dtick` progress with frame (`doompresent`), scheduler
(`pirq`, `preempt`, `pattempt`, `pskip`, `puser`), and SB16/music
(`audioirq`, `refill`, `musicpull`, `musicpos`) counters across captured
gameplay snapshots. If those counters advance together while a remote VNC
session feels slower, the status artifact points first at host/display
throughput; if one lane stalls or records drops/underruns, the JSON proof names
that lane directly.

Host-safe validation lives in source/contract tests:

- `tests/host/doom_libc_allocator_test.c` mocks the clock syscall and validates
  `vibe_clock_gettime`, `vibe_monotonic_ticks`, `vibe_monotonic_milliseconds`,
  and `clock_gettime(CLOCK_MONOTONIC, ...)`.
- `tests/host/test_artifacts.py` pins the kernel syscall number, PIT frequency,
  smoke-status `clockhz=` / `clockms=` fields, and Doom's use of the generic
  monotonic helper.

The ABI is reusable, but not POSIX-complete. The image builder can package
additional root-level 8.3 `.ELF` files with `--root-elf NAME.ELF=PATH`, but the
runtime model still lacks directories for open/exec traversal, long filenames,
environment copying, true `fork`, blocking waits, signals, threads, dynamic
process growth, reusable file-backed VM objects, direct RGB presents, larger
present sources, and audio formats beyond the current unsigned 8-bit stereo
mixer path.

## General-OS Gap Contract

The port intentionally separates "present and reusable" from "not implemented
yet" so future POSIX work has executable edges instead of vague TODOs:

- `fork` exists only as a classified syscall/libc surface. `fork()` enters
  `VIBE_SYS_FORK` and returns `ENOSYS`; no child address-space clone, copy-on-
  write state, parent/child return split, or fork-time descriptor table clone is
  implied by the current process ABI.
- Descriptor lifetime and fd duplication now have a bounded Unix-open-file-description milestone.
  Fds have owner PID, generation, descriptor-level close-on-exec metadata, and
  a shared root slot with a refcounted offset/status record. `dup`, `dup2`, and
  `dup3` are public syscall/libc surfaces; the Ring 3 probe verifies that reads
  through duplicated descriptors advance one shared offset, and `dup3(...,
  O_CLOEXEC)` is closed by the next exec. `fcntl(F_GETFD/F_SETFD)` is the
  descriptor-flag milestone: callers can read or toggle `FD_CLOEXEC` on an
  already-open fd without reopening the file. There is still no fork-time fd
  table cloning contract, `fcntl(F_DUPFD*)`, or dynamic per-process fd
  namespace.
- VM allocation is anonymous/private and brk-backed. `mmap()` accepts only the
  `MAP_PRIVATE | MAP_ANONYMOUS`, `fd == -1`, `offset == 0`, non-fixed path;
  `MAP_FIXED`, `MAP_SHARED`, and file-backed mappings are rejected before a port
  can accidentally depend on reusable VM object lifetime.
- POSIX signal delivery is absent. User faults are kernel trap/process-state
  events, not `SIGSEGV` or `sigaction`; there is no public `signal.h`, signal
  mask, `kill`, interval timer signal, or handler trampoline ABI.
- Terminal/tty behavior is absent. Input is the typed event queue and display
  control is `ioctl(VIBE_DISPLAY_FD, ...)`; unknown display ioctls return
  `ENOTTY`, but there is no stdin/stdout tty device, `termios`, `isatty`, job
  control, or controlling-terminal model.
- Dynamic process lifetimes are bounded. Exec can select reusable static slots
  and `waitpid` can reap exited/faulted children, but there is no dynamically
  growing process table, orphan reparenting, blocking sleep queue for waits, or
  unbounded child lifecycle manager.

## Small User Runtime

`user/runtime.h` and `user/runtime.c` are the reusable non-Doom runtime seed for
small non-Doom user programs and freestanding tools. They do not try to be libc
and they do not depend on Doom port hooks. The layer owns the raw `int 0x80` call stub, centralizes the
same `-errno` / legacy `-1` conversion rule as the Doom libc shim, and exposes
minimal wrappers for the crt0-launched tool shape: write a complete string,
read `getpid`, duplicate descriptors with `dup`/`dup2`/`dup3`, query the
monotonic clock, list a root directory, `execv` another root `.ELF`, and report
a probe status word.

`user/abi_probe.c` now consumes that runtime instead of carrying its own inline
syscall assembly. That keeps the second-program proof honest: future small
non-Doom user programs can include the same header, link the same source with
`user/crt0.asm`, and stay on the public `vibe_os.h` syscall ABI while the Doom
libc remains available for POSIX-shaped ports.

## File ABI

User mode calls `vibe_syscall3` with the syscall numbers in
`doom_port/include/vibe_os.h`. File syscalls follow this convention:

- success returns a non-negative value;
- classified failure returns `-errno`;
- legacy kernel paths may return `-1`, which libc maps to an operation-specific
  fallback errno;
- open flags use `O_ACCMODE`, `O_RDONLY`, `O_WRONLY`, `O_RDWR`, `O_CREAT`,
  `O_TRUNC`, `O_APPEND`, `O_CLOEXEC`, and no-op `O_BINARY` from
  `doom_port/include/fcntl.h`.

The libc shim validates impossible access modes before entering the kernel.
This keeps stdio mode parsing deterministic for Doom's `fopen("r")`,
`fopen("w")`, response-file `rb`, save/config writes, and append/update modes.
The kernel now classifies the obvious Doom file syscall failures as `ENOENT`,
`EINVAL`, `EBADF`, `ENOMEM`, `EMFILE`, `EACCES`, `EIO`, or `ENOSYS` before libc
maps them to `errno`. Unknown `open` flag bits are rejected in the kernel as
`EINVAL`; running out of process fd slots is `EMFILE`, not a fake heap failure.

Path normalization is intentionally Doom-shaped, not a general directory layer.
The port maps Doom's Unix default path (`/.doomrc`), DOS/CD-ROM default path
(`c:/doomdata/default.cfg` or `c:\doomdata\default.cfg`), and plain
`default.cfg` to the FAT root file `DEFAULT.CFG`. It also maps
`doomsav0.dsg` through `doomsav5.dsg`, including the DOS/CD-ROM
`c:\doomdata\...` spelling, to the corresponding FAT root save files. This lets
the unmodified engine's `M_SaveDefaults`, `M_ReadSaveStrings`, `M_WriteFile`,
and save/load paths exercise the real FAT/syscall layer.

`mkdir` is a compatibility shim for Doom's startup call to `c:\doomdata`: that
specific path succeeds because the port maps Doom's state files into the FAT
root. Other directory creation still returns `ENOSYS`; there is no directory
allocator yet.

`unlink`, `remove`, `stat`, and `fstat` are real syscall-backed libc wrappers.
The FAT16 layer reports regular-file size/mode metadata for WAD/ELF artifacts
and writable root files, refuses deletion or writable opens of protected
`DOOM1.WAD`, `USERPROB.ELF`, and `DOOM.ELF`, and invalidates writable
descriptors whose root entry is deleted.

The tiny stdio scanner intentionally covers the original Doom patterns used for
defaults and saves: `%s`, `%[^\n]`, `%i`, `%d`, `%x`, literal text, and
whitespace. That includes save/version reads such as `sscanf("version 110",
"version %i", ...)`, so the port does not need a patched Doom parser.
Generic tools can rely on stdio write buffering being drained by either
`fflush(stream)`, `fclose(stream)`, or process-wide `fflush(NULL)`. The host
runtime-readiness test keeps that behavior covered separately from Doom's save
and defaults paths.

The tiny printf formatter is still integer/string only, but its ABI is now
useful beyond Doom status text: `snprintf` returns the would-have-written byte
count, terminates nonzero-sized buffers after truncation, honors width and
precision for signed/unsigned/hex integers, handles sign-aware zero padding,
supports precision-limited strings, and accepts the C89 `l` integer modifier.
It intentionally does not claim floating-point, locale, left-alignment, or the
full POSIX flag matrix.

Small non-Doom tools can also use `vibe_file_size` and `vibe_file_read_all` for
bounded whole-file reads. These helpers are still descriptor-backed and report
normal `errno` values: directories are rejected as `EISDIR`, undersized caller
buffers return `ENOSPC` after reporting the needed size, and kernel-classified
file failures preserve the underlying errno.

## Memory, Device, And Process ABI

The libc allocator is a small first-fit heap over `SYS_SBRK`. Allocations are
16-byte aligned, freed blocks are reused, oversized free blocks are split, and
adjacent free blocks are coalesced on `free()` and on shrinking `realloc()`.
That keeps temporary C-runtime allocations from leaving avoidable holes before
later larger requests. The kernel `SYS_SBRK` ABI now accepts negative
increments as a brk-style trim path: it moves the process break down, unmaps
only fully released heap pages, clears their heap-bitmap validation bits, and
returns the old break.

`mmap()` is syscall-backed for the practical porting case Doom-adjacent code
usually wants: anonymous, private memory with `fd == -1` and `offset == 0`.
The kernel implements it as a page-rounded allocation from the current
process heap, maps the new pages with user permissions derived from `prot`, and
returns a zero-filled range. Successful mappings also update a single
`VM_OBJECT_KIND_ANON_BRK` last-object descriptor with base/end/prot/flags so
host contracts can distinguish the current brk-backed object model from a real
VMA table. `munmap()` validates the supplied user range, punches validation
holes for non-tail ranges, and moves `brk` back for tail releases.
File-backed mappings, `MAP_FIXED`, and shared mappings are rejected before libc
enters the kernel.
`vibe_heap_capabilities`, `vibe_vm_capabilities`, and `vibe_mmap_anon` make that
limited model explicit for ports that need to choose between arena allocation,
anonymous scratch memory, and unsupported file-backed mapping paths.

Display device control is exposed through `ioctl(VIBE_DISPLAY_FD, ...)`.
`VIBE_IOCTL_FBINFO` fills a `vibe_fb_info_t` with the active framebuffer
contract, including capability bits, present format, max present size, geometry,
and dirty-source fields. The current backend advertises
`VIBE_FB_CAP_FIXED_PRESENT_SIZE`, so the advertised present size is exact rather
than a range. `VIBE_IOCTL_PRESENT_INDEXED` accepts a
`vibe_present_indexed_t` describing a 320x200 indexed frame plus 256-entry RGB
palette. Doom's `I_FinishUpdate` now uses this ioctl path while the older
`SYS_PRESENT` remains available for the low-level probe.
Generic ports should call `vibe_fb_get_info` and then
`vibe_present_indexed_checked` when they want libc to reject unsupported formats
or wrong-size sources before entering the present ioctl.

`execv()` passes a bounded `argv` vector through the syscall ABI. Doom and the
boot probe keep table-backed launch entries, and other root-level FAT16 `.ELF`
names are parsed as 8.3 paths and loaded into the reusable probe-class user
window. That is useful for small user utilities, but it is still not a Unix
loader: there are no directories, long filenames, dynamic process slots, or
environment copying, and probe-class self-reexec is rejected while the current
slot is active.
The libc `environ` pointer is present and points at an empty, null-terminated
environment vector. `execve()` accepts `NULL` or empty `envp` only and returns
`ENOSYS` for non-empty environments until environment copying exists.

Directory and metadata support is intentionally narrow but explicit. `stat("/")`
reports a readonly directory, regular files report `S_IFREG` plus user read/write
bits where appropriate, and `S_ISDIR`/`S_ISREG` are available for small tools
that should inspect file type instead of comparing mode constants by hand.

`fork()` is deliberately classified rather than faked: it returns `ENOSYS`
until process cloning has real address-space and file descriptor semantics.
`wait()/waitpid()` now enter a real process-table scanner. They return
`ECHILD` when the current process has no matching child, validate a non-null
status pointer, reap already-exited or faulted child records into `UNUSED`, and
write the child's stored exit status. Blocking on a live child, process-group
waits, and nonzero wait options still return explicit errors instead of
pretending that scheduling/blocking semantics are implemented.

The kernel fd table also records owner PID, open generation, and explicit
inheritance flags for each allocated descriptor. Each allocated open file has a
root fd slot with the shared offset and metadata; duplicated descriptors point
at that root and hold a refcount until close. `fork()` does not clone descriptor
tables yet, but exec retags inheritable descriptors from the caller PID to the
target PID and closes descriptors opened with `O_CLOEXEC` or created with
`dup3(..., O_CLOEXEC)`. Process teardown, fault handling, target-slot reuse,
and wait reaping close process-owned descriptors.

## Runtime proof

The kernel smoke status reports Doom file/runtime counters from the port ABI:
`doomopen`, `doomread`, `doomwad`, `doomwrite`, `doomseek`, `doomclose`,
`doomsbrk`, `doomerr`, `doomerrno`, `doommode`, `doomsav`, `saverd`, `savewr`,
`saveclose`, `savemode`, `savestm`, `savethk`, `fwr`, `fal`, `doominit`,
`doomexit`, `doomfault`, `doomfaultip`, `doomfaultv`, `doomfaulterr`, the compact `fault` frame tuple, `panic`, and
`shutdown`. These are counters, last-open mode/flag bits, the most recent
negative kernel errno returned to Doom, first-init milestone bits, user-mode
exit/fault diagnostics, and kernel stop-state markers, not filesystem internals.
`doomwad` is a compact open/read/lseek/magic tuple for the real `DOOM1.WAD`
path, `doominit` records the port-reported startup milestones before gameplay,
and the `doomsav`/`saverd`/`savewr` tuple family records port-reported
`DOOMSAV*.DSG` open/read/write/close evidence. `savestm` and `savethk`
record original-Doom save-stream offsets from port-side wrappers, including the
thinker stream boundary that must start with Doom's `tc_mobj` or `tc_end`
markers during save/load debugging. `fwr` and `fal` are compact
kernel-side write/allocation diagnostics for cloud save-write failures. They
prove the original Doom code reached the port-layer file contract while keeping
vendor Doom sources untouched.

`tools/check_doom_persistence_image.py` is the non-QEMU persistence proof tool.
After a remote/cloud run writes defaults or a save slot into a disposable
`disk.img`, run it on that remote image with `--baseline-image` pointing at the
fresh pre-boot image, plus `--require-default` and optional `--require-save-slot
N`. It reads only `DEFAULT.CFG` and `DOOMSAVN.DSG` through the FAT parser and
checks for Doom-shaped defaults text, the savegame description/version header,
and requested entries that changed from the baseline. Reboot-survival claims add
`--reboot-baseline-image` for the after-write snapshot plus `--reboot-status`
for the second boot's decoded status. The checker requires the fresh baseline in
that mode too, and the status gate rejects user faults, panics, shutdowns, and
failed Doom runtime health fields so persisted bytes alone cannot count as
proof. For save/load playability, add `--load-status` from a reboot boot after
the scripted load menu path; the checker requires a full `DOOMSAVN.DSG` payload
read, `doomrun=RUN`, wrapper load-requested/load-done `saveact` bits after
`G_DoLoadGame` has returned to `ga_nothing`, and post-load `gameplay=OK` status
whose map and leveltime match the saved header.
