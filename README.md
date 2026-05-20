# vibe-os

This repo is a practical "can we actually build an OS with agentic coding?"
workspace. The first milestone is a tiny x86 BIOS-bootable operating system:

- 512-byte Stage 1 MBR boot sector
- Stage 2 loader read from raw disk sectors with BIOS EDD `INT 0x13`
- Stage 2-owned A20 enable, GDT setup, and protected-mode transition
- Stage 2 ELF32 executable parser that loads kernel `PT_LOAD` segments
- repo-owned ELF32 linker for NASM and freestanding C object files, including
  separate executable/read-only and writable `PT_LOAD` segment flags
- 32-bit protected-mode kernel entered through its ELF entry point at `0x10000`
- own VGA text console, PS/2 keyboard polling, and PS/2 auxiliary mouse packet
  decode for Doom input
- kernel-owned IDT/PIC/PIT timer tick
- kernel-owned GDT with Ring 0/Ring 3 descriptors and a TSS
- paging enabled with supervisor-only kernel identity mappings, per-process
  page directories for user processes, ELF segment write-permission metadata,
  and a map-page self-test
- a standalone user ELF loaded from FAT16, entered in Ring 3, invoking
  `int 0x80`, and proving supervisor pages fault
- tiny user-space C runtime entrypoint that links a freestanding C probe into
  `USERPROB.ELF`
- user-mode syscall smoke coverage for `sbrk`, `mmap`, `ioctl`, `open`,
  `read`, `lseek`, classified `fork`/`waitpid`, and console `write`
- syscall pointer validation walks the current process VM region table, so the
  tiny probe and the larger Doom image have different valid mapped regions
- table-backed `SYS_EXEC` handoff that validates a user path, loads a supported
  image, seeds a scheduler-visible Ring 3 context with an argv-shaped stack,
  marks the caller exited, and switches to the target process record
- physical frame accounting for the first managed 32 MiB
- 8 MiB free-list heap with `kalloc`/`kfree` and boot-time high-memory self-test
- freestanding cdecl-style libc subset: strings, memory helpers, integer math, x87 init/test, and `kprintf`
- freestanding C build path that compiles C into the booted kernel image
- vendored official id Software Doom source release at
  `third_party/doom/linuxdoom-1.10`
- freestanding i386 compile/link smoke for 57 unmodified original Doom engine
  modules against the vibe-os platform layer, excluding only the Linux `i_*`
  platform files
- FAT16 disk image carries the linked `DOOM.ELF` user artifact alongside the
  WAD and Ring 3 probe, with kernel-side directory discovery, load, and ELF
  program-header validation
- hard-path WAD loading through an ATA PIO IDE driver and a FAT16 reader
- dynamic FAT16 writable files for Doom defaults, save slots, and bounded
  root-level 8.3 user-created files, with kernel
  read/write/lseek/truncate/unlink/stat support over allocated cluster chains
  and shared per-descriptor offsets for WAD and writable file descriptors
- WAD header/directory parsing with named-lump lookup for Doom assets
- text UI with an interactive shell
- local QEMU targets guarded behind an explicit opt-in, plus a host-side safety
  contract that keeps `make test` QEMU-free
- GitHub Actions smoke tests for cloud-side boot validation with status/log
  diagnostics on failure

## Legitimacy Boundary

- The kernel runs in 32-bit protected mode with its own flat-memory setup.
- The boot path does not use GRUB or Multiboot. `boot/stage1.asm` is the MBR
  sector, and `boot/stage2.asm` is loaded from raw LBAs before the FAT
  partition.
- The kernel is not jumped to as a raw sector blob. The build emits real ELF32
  relocatable objects, `tools/link_elf32.py` links them into an ELF executable,
  and Stage 2 parses the executable's program headers before jumping to the
  entry point.
- Paging, physical-frame accounting, heap allocation, libc helpers, console I/O,
  interrupts, and timer ticks are kernel-owned code in this repo.
- User/kernel separation is not just a label: the boot probe enters Ring 3 with
  user selectors from a standalone C-backed `USERPROB.ELF` file loaded through
  FAT16, allocates user heap, opens and reads `DOOM1.WAD` through kernel
  syscalls, calls the syscall gate, then intentionally faults on a
  supervisor-only kernel page and records the expected page fault.
- `DOOM1.WAD` is not passed in as a GRUB module or RAM disk. The build creates an
  IDE disk image with boot sectors, an MBR partition table, and a FAT16
  partition, and the kernel reads
  `DOOM1.WAD` through its own ATA PIO and FAT16 code.
- The current WAD is a generated IWAD-shaped fixture used to prove the storage
  path and lump parser. A real Doom milestone should replace it with the
  shareware WAD without changing the kernel storage path. The image builder
  supports this with a local, untracked WAD path.
- External programs here are build/test tools: assembler, C compiler, image
  generator, and emulator. They are not runtime OS services.
- Doom source legitimacy is pinned to the official id Software public release:
  `third_party/doom/ORIGIN.md` records the upstream repository and commit, and
  host tests hash the original files used by the compile smoke so port work
  stays outside the vendor tree.
- The detailed source-integrity contract lives in `docs/doom-provenance.md`.
  In short: `third_party/doom` is read-only vendor code, the build compiles the
  original `linuxdoom-1.10` engine objects plus isolated `doom_port/*` shims,
  and host tests reject dirty vendor-tree state, wrapper engines, tracked WADs,
  disk images, logs, rendered pixel artifacts, and runtime/build references to
  shortcut source ports or host display/audio APIs.

## Requirements

- `nasm`
- `qemu-system-x86_64`
- `clang`
- `make`

On macOS:

```sh
brew install nasm qemu
```

Apple's `clang` from Xcode Command Line Tools is sufficient for the
freestanding C probe.

## Build

```sh
make
```

The disk image is written to `build/disk.img`.

By default the image contains a generated IWAD-shaped storage fixture so public
CI can boot without copyrighted game data. To build the same OS image with a
real shareware WAD, keep the WAD outside git and pass it explicitly:

```sh
make clean
make DOOM_WAD=/absolute/path/to/DOOM1.WAD
```

The builder validates that the supplied file is a WAD and fits the kernel's
current 5 MiB WAD load window. `*.wad` and `*.WAD` are ignored by this repo so
game data is not accidentally committed.

Run host-side artifact tests without launching QEMU:

```sh
make test
```

Current disk layout:

- LBA 0: Stage 1 MBR and partition table
- LBA 1-16: Stage 2 bootloader
- LBA 17-144: protected-mode kernel ELF image
- LBA 2048+: FAT16 partition containing `DOOM1.WAD`, `USERPROB.ELF`, and
  `DOOM.ELF`, plus empty dynamic `DEFAULT.CFG` and `DOOMSAV0.DSG` through
  `DOOMSAV5.DSG` writable root entries

See `docs/persistent-fat16.md` for the bounded root-level persistence contract,
the Doom save/config path mapping, and the baseline-vs-mutated remote-image
checker for `DEFAULT.CFG` / `DOOMSAV*.DSG` proof.

See `docs/boot-loader-vm.md` for the raw-sector boot chain, protected-mode ELF
handoff, fixed low-memory reservations, paging contract, and VM gaps.

See `docs/process-vm.md` for the current process address-space contract,
including per-process page directories, VM regions, and remaining VM gaps.

See `docs/process-exec.md` for the current table-backed exec handoff,
process-replacement, argv-stack, and scheduler integration contract.

See `docs/post-checkpoint-gaps.md` for the current post-checkpoint honesty
ledger. Its machine-readable `GAP[...]` rows track the remaining cloud boot,
real gameplay, human playtest, persistence, audio, VM/POSIX, shutdown/panic, and
hardware-limit gates still needed before a playable claim.

See `docs/graphics.md` for the VBE/Mode 13h framebuffer contract and current
scaler limits.

## Run

Local QEMU targets are opt-in:

```sh
make ALLOW_LOCAL_VM=1 run
```

For a non-graphical boot check:

```sh
make ALLOW_LOCAL_VM=1 smoke
```

The repo also includes `.github/workflows/os-smoke.yml`, which builds the disk
image, runs host artifact tests, and runs the smoke test in GitHub Actions.
The VM safety contract is checked without launching QEMU:

```sh
make vm-safety-check
```

For a real-WAD test, run the **Real WAD smoke** workflow manually.
You can paste a URL to `DOOM1.WAD`, `DOOM1.WAD.gz`, or a zip containing
`DOOM1.WAD`; leave the input empty to use `REAL_DOOM_WAD_URL` if the repository
secret is set, otherwise the workflow falls back to the public Archive.org
shareware WAD gzip. In the disposable runner it extracts `DOOM1.WAD`, validates
the expected shareware v1.9 size (`4196020` bytes) and SHA-1
(`5b2e249b9c5133ec987b3ea77596381dc0d6bc1d`), builds `disk.img` with
`DOOM_WAD`, boots it in cloud QEMU, and runs a deterministic input script
through the QEMU monitor. The QEMU step captures status snapshots first; the
separate proof steps then require Doom framebuffer presentation and kernel
status counters showing Doom autostarted E1M1, advanced level time in
`GS_LEVEL`, accepted fire/use/move/mouse/menu input, and changed player/menu
state.
That split keeps failed cloud boots diagnosable from text artifacts instead of
skipping the proof tools. The workflow uploads only non-WAD diagnostics
(`status*.txt`, `status*.bin`, logs, ELF files, and `doom.symbols` for fault
triage). It deliberately does not upload `disk.img`, `gfx.bin`, `vga*.txt`, or
WAD paths, since those may contain Doom game data or rendered pixels.

For the stronger cloud-safe playable proof, see
`docs/playable-cloud-proof.md`. The real-WAD workflow now uses a deterministic
fire/move/use/mouse/menu input script and validates non-pixel status fields for
keyboard delivery, PS/2 mouse delivery, player movement, action commands, menu
activation, and visual activity summaries. Its checker also requires coherent
process/exec, storage, VM, audio, mouse, scheduler, and Doom file I/O telemetry
so a green run is diagnosable from text artifacts alone.
The same workflow has an opt-in `audible_audio_proof` mode that uses a
temporary QEMU WAV backend on the disposable runner, reduces it to aggregate
`audio-proof.json`, validates that manifest, and deletes the WAV before upload.
Raw audio files are not diagnostic artifacts.

Current proof status: the latest analyzed real-WAD run is red. Run
`26146035600` on commit `269dbb8` reached `exec=OK path=DOOM.ELF` with valid
entry, stack, argc, argv, and argv0 fields, then Doom faulted in Ring 3 at
`FindResponseFile+0x34` (`doomfaultip=01003224`, page-fault vector `0x0E`,
error `0x05`, `CR2=00000000`) before `doomopen` / `doomread`. That is useful
bring-up evidence, not a Doom-capable claim.

For a human actually trying the image, use
`docs/runbooks/remote-doom-playtest.md`. It keeps QEMU on a disposable remote
host, exposes a loopback-only VNC display through SSH, keeps `DOOM1.WAD` outside
git, and validates downloaded diagnostics with
`tools/check_cloud_playability_artifacts.py`.

## Shell Commands

- `help`
- `about`
- `clear`
- `echo <text>`
- `mem`
- `mode`
- `ticks`
- `heap`
- `paging`
- `libc`
- `c`
- `user`
- `wad`
- `reboot`
- `halt`

## Hard-Way Doom Roadmap

Already implemented:

- raw BIOS boot sector and Stage 2 bootloader, without GRUB
- Stage 2 ELF32 kernel loader
- repo-owned ELF32 linker for `R_386_32` and `R_386_PC32` relocations
- 32-bit protected mode with flat GDT
- kernel GDT, TSS, Ring 3 transition, `int 0x80`, and a supervisor-page fault
  isolation probe
- standalone user ELF build, FAT16 storage entry, kernel ELF validation, and
  Ring 3 entry from the loaded executable
- freestanding C user program linked through a tiny `crt0` instead of a
  hand-written assembly-only probe
- first POSIX-shaped user syscall slice: `sbrk`, `open`, `read`, `write`,
  `lseek`, `close`, `unlink`, `stat`, `fstat`, anonymous/private `mmap`,
  display `ioctl`, classified `fork`/`waitpid`, and table-backed `exec`,
  exercised by the user ELF and host lifecycle contracts
- paging, PMM/VMM self-tests, and kernel heap
- kernel libc subset and a freestanding C probe linked from a clang ELF object
- ATA PIO, MBR partition parsing, FAT16 root/cluster loading, and WAD parsing
- official `linuxdoom-1.10` source import, with a no-modification provenance
  policy and a freestanding link smoke for the original engine plus vibe-os
  replacement `i_*` platform layer
- `DOOM.ELF` embedded as a FAT16 root file and discovered by the kernel storage
  path
- widened low-memory paging/PMM coverage to 32 MiB and loaded the linked Doom
  executable into its `0x01000000` image window for ELF validation
- Doom's platform `I_GetTime` now calls a kernel 35 Hz time syscall instead of
  using a fake local counter
- Doom's platform `I_FinishUpdate` calls the display `ioctl` present path for
  a 320x200 8-bit indexed frame plus RGB palette, and CI verifies bytes written
  to the VGA graphics aperture at `0xA0000`
- Stage 2 attempts VBE 32-bpp linear-framebuffer discovery/set, passes the
  framebuffer contract through the boot info block, and the kernel maps that
  LFB to present a 2x XRGB8888-scaled Doom frame with Mode 13h fallback
- Doom's platform `I_StartTic` drains a kernel `SYS_POLL_KEY` queue fed by a
  PS/2 IRQ1 scancode handler and posts normal Doom `ev_keydown`/`ev_keyup`
  events without modifying the original engine source
- the kernel enables the PS/2 auxiliary device when present, decodes 3-byte
  mouse packets from IRQ12 into `SYS_POLL_MOUSE`, records `mouse=*` smoke
  counters, and the Doom platform layer posts `ev_mouse` events without editing
  Doom source
- Stage 2 enters VGA mode 13h before protected mode, while the cloud smoke
  reads kernel status from a normal RAM status block so graphics memory and
  boot status can be verified separately
- after the Ring 3 probe, the kernel enters the loaded original `DOOM.ELF`
  through its ELF entry point with a Doom-sized user stack/heap window; the
  latest real-WAD diagnostics prove the syscall-driven exec handoff reaches
  Doom user mode, but they also prove Doom currently faults before WAD open/read
- the kernel captures a bounded tail of Doom's user-mode stdout/stderr stream
  into the RAM smoke artifact as `doomlog=...`, so startup failures are
  diagnosable without editing Doom source
- optional external `DOOM_WAD=/path/to/DOOM1.WAD` image builds for real
  shareware WAD testing without committing game data
- manual GitHub Actions real-WAD smoke path using a private
  `REAL_DOOM_WAD_URL`, with artifacts limited to non-WAD diagnostics

Still required before this is actually Doom-capable:

- a current passing manual real-WAD cloud workflow on the exact commit being
  claimed, followed by review of the non-WAD status diagnostics
- fix the current Doom user-mode page fault at `FindResponseFile+0x34` and
  prove `doomrun=RUN`, `doomopen=OK`, and `doomread=OK` on a fresh cloud run
- a passing `tools/check_real_wad_proof.py` run on that current real-WAD status
  artifact, including zero Doom exit/fault counters and coherent process,
  storage, VM, input, audio, scheduler, and gameplay telemetry
- a remote human VNC playtest using `docs/runbooks/remote-doom-playtest.md`,
  including status capture after keyboard-driven menu and gameplay actions
- higher-half kernel mapping or another non-identity kernel layout, plus
  dynamically allocated page tables and non-identity user frame backing
- broader VM/POSIX coverage: arbitrary-path `exec`, richer `mmap`, fuller file
  semantics, descriptor duplication, and more device/ioctl contracts
- current passing save/config persistence proof after a real-WAD reboot using
  `tools/check_doom_persistence_image.py --baseline-image`, not just host-side
  FAT lifecycle coverage
- broader framebuffer mode support, aspect policy, fullscreen behavior, and
  dirty-rect presentation beyond the current XRGB8888 VBE path
- remote SB16 continuity proof now has a status-only checker, but audible human
  validation still needs a current `audio-proof.json` or listener proof, and
  long-running music streaming beyond the current looped PCM carrier is still
  open
- graceful Doom exit/reboot behavior for a human session
- a scoped hardware/support matrix; current claims should stay bounded to the
  QEMU BIOS/IDE/PS2/VBE/SB16 target until each new device class has its own
  disposable-runner or hardware proof
