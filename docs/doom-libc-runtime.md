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
and dirty-source fields. `VIBE_IOCTL_PRESENT_INDEXED` accepts a
`vibe_present_indexed_t` describing a 320x200 indexed frame plus 256-entry RGB
palette. Doom's `I_FinishUpdate` now uses this ioctl path while the older
`SYS_PRESENT` remains available for the low-level probe.
Generic ports should call `vibe_fb_get_info` and then
`vibe_present_indexed_checked` when they want libc to reject unsupported formats
or oversized sources before entering the present ioctl.

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
inheritance flags for each allocated fd. This is metadata only for now: `fork()`
does not clone descriptors yet, and the current exec handoff still resets the
global fd table before entering the new image.

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
