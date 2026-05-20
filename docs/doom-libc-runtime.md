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

## Runtime proof

The kernel smoke status reports Doom file/runtime counters from the port ABI:
`doomopen`, `doomread`, `doomwrite`, `doomseek`, `doomclose`, `doomsbrk`,
`doomerr`, and `doommode`. These are counters and last-open mode/flag bits, not
filesystem internals. They prove the original Doom code reached the port-layer
file contract while keeping FAT allocation and vendor Doom sources untouched.
