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
`doomopen`, `doomread`, `doomwad`, `doomwrite`, `doomseek`, `doomclose`,
`doomsbrk`, `doomerr`, `doomerrno`, `doommode`, `doominit`, `doomexit`,
`doomfault`, `doomfaultip`, `doomfaultv`, `doomfaulterr`, the compact `fault`
frame tuple, `panic`, and `shutdown`. These are counters, last-open mode/flag
bits, the most recent negative kernel errno returned to Doom, first-init
milestone bits, user-mode exit/fault diagnostics, and kernel stop-state
markers, not filesystem internals. `doomwad` is a compact open/read/lseek/magic
tuple for the real `DOOM1.WAD` path, and `doominit` records the port-reported
startup milestones before gameplay. They prove the original Doom code reached
the port-layer file contract while keeping FAT allocation and vendor Doom
sources untouched.

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
proof.
