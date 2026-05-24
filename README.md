# vibe-os

vibe-os is a small x86 operating system built around one test:

Can an OS we own boot, launch the original Doom engine, and provide enough real
kernel services for it to play?

It is not Linux running Doom. It is not Chocolate Doom, doomgeneric, SDL, or a
desktop app in costume. A raw disk image boots on a QEMU PC target, vibe-os
takes over the CPU, loads its own kernel, starts user programs, and runs the
official id Software `linuxdoom-1.10` source as `DOOM.ELF` in Ring 3.

In plain English: the machine wakes up into vibe-os, vibe-os finds Doom on its
own FAT16 disk, and Doom asks vibe-os for memory, files, time, input, graphics,
and audio.

## What It Owns

- boot: BIOS MBR, Stage 2 loader, FAT16 `KERNEL.ELF` loading, ELF validation,
  protected-mode entry, and a source-level UEFI loader path
- kernel: GDT/IDT, exceptions, IRQs, syscalls, paging, physical memory
  accounting, user/kernel transitions, timer preemption, and status reporting
- storage: ATA/IDE PIO, block-device boundary, FAT16 reads/writes, WAD loading,
  config files, save files, and file-descriptor-style user ABI paths
- userland: Ring 3 ELF launch, user entry, syscall wrappers, ABI probes, and the
  Doom process path
- devices: keyboard, mouse, framebuffer presentation, palette conversion, and an
  SB16-style PCM/audio path
- runtime: the freestanding libc/math/string surface Doom expects

Doom is the first serious payload. The point is to make OS services general
enough for other small C games and tools, not to hide Doom-only shortcuts behind
a nice demo.

## What Is Vendored

The Doom engine source lives in `third_party/doom/linuxdoom-1.10`. It is the
official id Software public Doom source release, imported from
`id-Software/DOOM` commit `a77dfb96cb91780ca334d0d4cfd86957558007e0` under the
GPL-2.0 license recorded in `third_party/doom/LICENSE.TXT`.

That vendor tree should stay pristine. vibe-os code belongs in the bootloader,
kernel, user runtime, `doom_port/`, build glue, and tiny host tools around it.

`DOOM1.WAD` is game data, not source code, and is not tracked.

## How Doom Runs

1. QEMU provides the supported PC hardware model in a disposable cloud run.
2. The disk boots through the vibe-os BIOS path.
3. Stage 2 loads `KERNEL.ELF` from the FAT16 partition.
4. The kernel sets up memory, interrupts, syscalls, files, input, video, audio,
   and user processes.
5. Probe programs exercise the generic user ABI.
6. `DOOM.ELF` starts as a Ring 3 process.
7. Doom reads `DOOM1.WAD`, renders frames, accepts input, emits audio, and can
   write config/save data through vibe-os paths.

UEFI exists as a source and cloud-proof path, but interactive play is still the
BIOS/IDE/noVNC target.

## Project Direction

The guest OS path should move toward project-owned assembly:

- assembly first for boot, kernel, CPU entry, interrupts, syscalls, scheduling,
  low-level drivers, ABI boundaries, and user entry
- modest C only where it is still practical: original Doom, temporary guest
  runtime/port glue, and tiny host utilities
- no Python in the build, proof, or OS architecture
- proof should come from guest status fields, cloud boots, and small validators,
  not a pile of host-side inference scripts

The desired end state is simple to describe: an assembly-native vibe-os
environment running the original C Doom engine as its user payload.

## Build And Try It

Host-only checks are safe on this Mac:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-loader-object
git diff --check
```

Manual play belongs on a disposable cloud machine:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

Cloud proof lanes fetch and validate the public shareware WAD on the runner,
build a temporary disk image, boot vibe-os, and check guest-emitted status. The
main real-WAD lane is:

```sh
gh workflow run real-wad-smoke.yml --ref main -f expected_ref=main
```

Local QEMU is opt-in only.

## Boundaries

- Supported target: QEMU PC BIOS/IDE/PS2/VBE/SB16-style hardware.
- Not claimed: arbitrary physical PCs, installers, unknown disks, USB, AHCI,
  HDA, or data recovery.
- Original Doom remains original Doom; vibe-os did not rewrite the game engine.
- Host build/proof utilities such as `tools/make_wad_image.c`,
  `tools/link_elf32.c`, and `tools/vibe_status_check.c` are workshop equipment,
  not guest OS code.
- WADs, generated disk images, screenshots, framebuffer dumps, raw audio, VM
  logs, and secrets stay out of git.

This README is the human overview. Detailed truth should live in code, workflow
checks, and guest status fields.
