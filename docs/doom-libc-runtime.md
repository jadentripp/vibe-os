# Doom libc runtime contract

The Doom tree under `third_party/doom` stays pristine. The OS-facing runtime
contract lives in `doom_port` and exposes enough POSIX-shaped behavior for
linuxdoom file and stdio use without patching original engine sources.

## File ABI

User mode calls `vibe_syscall3` with the syscall numbers in
`doom_port/include/vibe_os.h`. File syscalls follow this convention:

- success returns a non-negative value;
- classified failure returns `-errno`;
- legacy kernel paths may return `-1`, which libc maps to an operation-specific
  fallback errno;
- open flags use `O_ACCMODE`, `O_RDONLY`, `O_WRONLY`, `O_RDWR`, `O_CREAT`,
  `O_TRUNC`, `O_APPEND`, and no-op `O_BINARY` from `doom_port/include/fcntl.h`.

The libc shim validates impossible access modes before entering the kernel.
This keeps stdio mode parsing deterministic for Doom's `fopen("r")`,
`fopen("w")`, response-file `rb`, save/config writes, and append/update modes.
The kernel now classifies the obvious Doom file syscall failures as `ENOENT`,
`EINVAL`, `EBADF`, `ENOMEM`, `EACCES`, `EIO`, or `ENOSYS` before libc maps them
to `errno`.

`unlink`, `stat`, and `fstat` are real syscall-backed libc wrappers. The FAT16
layer reports regular-file size/mode metadata for WAD/ELF artifacts and writable
root files, refuses deletion of protected `DOOM1.WAD`, `USERPROB.ELF`, and
`DOOM.ELF`, and invalidates writable descriptors whose root entry is deleted.

## Memory, Device, And Process ABI

`mmap()` is syscall-backed for the practical porting case Doom-adjacent code
usually wants: anonymous, private memory with `fd == -1` and `offset == 0`.
The kernel implements it as a page-rounded allocation from the current
process heap, maps the new pages with user permissions derived from `prot`, and
returns a zero-filled range. `munmap()` validates the supplied user range but is
currently non-reclaiming because the kernel heap window is still monotonic.
File-backed mappings, `MAP_FIXED`, and shared mappings are rejected before libc
enters the kernel.

Display device control is exposed through `ioctl(VIBE_DISPLAY_FD, ...)`.
`VIBE_IOCTL_FBINFO` fills a `vibe_fb_info_t` with the active framebuffer
contract, and `VIBE_IOCTL_PRESENT_INDEXED` accepts a `vibe_present_indexed_t`
describing a 320x200 indexed frame plus 256-entry RGB palette. Doom's
`I_FinishUpdate` now uses this ioctl path while the older `SYS_PRESENT` remains
available for the low-level probe.

`fork()` and `wait()/waitpid()` are deliberately classified rather than faked:
`fork()` returns `ENOSYS` until process cloning has real address-space and file
descriptor semantics, and `wait()/waitpid()` return `ECHILD` because no child
process table exists yet. This gives POSIX-looking ports stable errno behavior
without pretending that clone/wait lifecycle semantics are implemented.

## Runtime proof

The kernel smoke status reports Doom file/runtime counters from the port ABI:
`doomopen`, `doomread`, `doomwrite`, `doomseek`, `doomclose`, `doomsbrk`,
`doomerr`, and `doommode`. These are counters and last-open mode/flag bits, not
filesystem internals. They prove the original Doom code reached the port-layer
file contract while keeping FAT allocation and vendor Doom sources untouched.
