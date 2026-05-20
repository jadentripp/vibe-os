# vibe-os

This repo is a practical "can we actually build an OS with agentic coding?"
workspace. The first milestone is a tiny x86 BIOS-bootable operating system:

- 512-byte Stage 1 MBR boot sector
- Stage 2 loader read from raw disk sectors with BIOS EDD `INT 0x13`
- Stage 2-owned A20 enable, GDT setup, and protected-mode transition
- Stage 2 ELF32 executable parser that loads kernel `PT_LOAD` segments
- repo-owned ELF32 linker for NASM and freestanding C object files
- 32-bit protected-mode kernel entered through its ELF entry point at `0x10000`
- own VGA text console and PS/2 keyboard polling
- kernel-owned IDT/PIC/PIT timer tick
- kernel-owned GDT with Ring 0/Ring 3 descriptors and a TSS
- paging enabled with an identity-mapped low-memory window and a map-page self-test
- a standalone user ELF loaded from FAT16, entered in Ring 3, invoking
  `int 0x80`, and proving supervisor pages fault
- tiny user-space C runtime entrypoint that links a freestanding C probe into
  `USERPROB.ELF`
- user-mode syscall smoke coverage for `sbrk`, `open`, `read`, `lseek`, and
  console `write`
- syscall pointer validation uses a current user-process window, so the tiny
  probe and the larger Doom image can have different valid address ranges
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
- WAD header/directory parsing with named-lump lookup for Doom assets
- text UI with an interactive shell
- local QEMU targets guarded behind an explicit opt-in
- GitHub Actions smoke test for cloud-side boot validation

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
  shareware WAD without changing the kernel storage path.
- External programs here are build/test tools: assembler, C compiler, image
  generator, and emulator. They are not runtime OS services.
- Doom source legitimacy is pinned to the official id Software public release:
  `third_party/doom/ORIGIN.md` records the upstream repository and commit, and
  host tests hash the original files used by the compile smoke so port work
  stays outside the vendor tree.

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

Run host-side artifact tests without launching QEMU:

```sh
make test
```

Current disk layout:

- LBA 0: Stage 1 MBR and partition table
- LBA 1-16: Stage 2 bootloader
- LBA 17-112: protected-mode kernel ELF image
- LBA 2048+: FAT16 partition containing `DOOM1.WAD`, `USERPROB.ELF`, and
  `DOOM.ELF`

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
- first POSIX-shaped user syscall slice: `sbrk`, `open`, `read`, `lseek`, and
  `write`, exercised by the user ELF against the WAD header
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
- Doom's platform `I_FinishUpdate` calls a kernel `SYS_PRESENT` path for a
  320x200 8-bit indexed frame plus RGB palette, and CI verifies bytes written
  to the VGA graphics aperture at `0xA0000`

Still required before this is actually Doom-capable:

- higher-half kernel mapping and real user address spaces
- scheduler, process table, per-process kernel stacks, and context switching
- a broader syscall ABI: `exec`, `mmap`, fuller file I/O, input, and drawing
- safe Ring 3 launch path for `linuxdoom-1.10` with its larger address space,
  heap, and syscall surface
- POSIX-ish libc and file syscalls for Doom
- complete framebuffer mode setup and input plumbing for interactive Doom
- sound stack, or an explicit first Doom milestone that runs video/input with
  sound disabled
