# vibe-os

vibe-os is a from-scratch 32-bit x86 operating system for QEMU's PC hardware
model. It boots from a raw disk image, loads its own kernel, starts Ring 3 ELF
programs, and exposes its own syscall ABI for files, memory, time, input,
video, audio, config, and saves.

The current proof targets are the original id Software Doom and Quake engine
sources running as vibe-os user programs. They appear as Doom and Quake on the
guest launcher screen, but the disk image stores them in generic large-payload
slots. The OS process path is not hard-coded to either game.

This is not Linux running Doom or Quake. It is not Chocolate Doom, doomgeneric,
SDL, or a desktop wrapper. QEMU provides the emulated PC hardware; vibe-os owns
the boot path, kernel, drivers, process model, user ABI, and game adapter layer.

## Quick Start

You need `make`, `nasm`, `cc`, `git`, `curl`, and `qemu-system-x86_64` on
`PATH`.

```sh
make play
```

`make play` downloads and validates public shareware Doom and Quake data into
`~/.cache/vibe-os`, builds `build/play/disk.img`, launches QEMU, boots vibe-os,
and opens the launcher. Pick Doom or Quake inside the OS with `1`/`2`, `W`/`S`
plus Enter, or the mouse.

The WAD and PAK stay outside git. This repository contains engine source and
vibe-os glue, not commercial game data.

Build the same play image without launching QEMU:

```sh
make play-image
```

Use your own legally obtained game data:

```sh
DOOM_WAD=/absolute/path/to/DOOM1.WAD \
  QUAKE_PAK=/absolute/path/to/PAK0.PAK \
  make play
```

## What You Should See

`make play` should open a QEMU window, boot vibe-os, and show a simple launcher
with Doom and Quake choices. Selecting Doom starts the Doom engine from the
first large-payload slot. Selecting Quake starts the Quake engine from the
second large-payload slot.

If the QEMU window opens but never reaches the launcher, quit QEMU and inspect
`build/play/serial.log`.

## What Is Running

The supported interactive route is the QEMU PC BIOS path:

1. QEMU boots the raw vibe-os disk image.
2. Stage 1 and Stage 2 load `KERNEL.ELF` from FAT16.
3. The kernel initializes memory, interrupts, syscalls, storage, input, video,
   audio, and processes.
4. The kernel starts `INIT.ELF`, the NASM guest launcher.
5. The launcher presents Doom and Quake choices through the framebuffer.
6. The selected payload starts as a Ring 3 ELF process.
7. The payload reads external data, renders frames, accepts input, emits audio,
   and writes config or save data through vibe-os.

A normal image places these files in the FAT root:

- `KERNEL.ELF` - the vibe-os kernel.
- `INIT.ELF` - the guest launcher.
- `USERPROB.ELF` and `ABIPROBE.ELF` - guest test programs.
- `PAYLOAD0.ELF` - the first large payload slot, currently Doom.
- `PAYLOAD1.ELF` - the second large payload slot, currently Quake.

The slot names are deliberate. Some proof labels, build variables, game data
formats, and compatibility paths still say Doom, Quake, WAD, PAK, `DOOM1.WAD`,
or `PAK0.PAK`; those names do not define the OS process path.

## Verify

Default host-only checks:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-loader-object
git diff --check
```

These checks build the image, kernel, launcher, probe ELFs, payload ELFs, host
utilities, status validator, and assembly-native guest audit without running
local QEMU. With `DOOM_WAD=` empty, the test image uses generated Doom fixture
data; `make play` is the path that fetches playable public data. The guest
status contract is validated by `tools/vibe_status_check.asm`.

Build a non-play image with external data:

```sh
make DOOM_WAD=/path/to/DOOM1.WAD
make QUAKE_PAK=/path/to/PAK0.PAK
make DOOM_WAD=/path/to/DOOM1.WAD QUAKE_PAK=/path/to/PAK0.PAK
```

The same inputs also have generic aliases:

```sh
make PRIMARY_ASSET=/path/to/DOOM1.WAD SECONDARY_PACKAGE=/path/to/PAK0.PAK
```

## Verified Behavior

Release proof workflows run in GitHub Actions on disposable QEMU VMs. They
build a launcher-first image, select a payload from the guest launcher, launch
it through the same generic process path, drive input, and check guest-emitted
status fields.

```sh
gh workflow run real-wad-smoke.yml \
  --ref main \
  -f expected_ref=main \
  -f expected_sha="$(git rev-parse origin/main)"

gh workflow run real-quake-smoke.yml \
  --ref main \
  -f expected_ref=main \
  -f expected_sha="$(git rev-parse origin/main)"
```

A passing proof shows real external data reads, rendered frames, input progress,
gameplay or engine-state progress, `panic=NONE`, `shutdown=NONE`, and passing
storage/input/graphics/audio/process/memory/preemption gates.

Proof artifacts are status-only. Do not upload WADs, PAKs, disk images,
screenshots, rendered pixels, raw audio, VM logs, tokens, or one-time codes.

Manual cloud play is available through the noVNC helper:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

## Source And Data

The vendored Doom source lives in `third_party/doom/linuxdoom-1.10`. It is the
official id Software public Doom source release from `id-Software/DOOM` commit
`a77dfb96cb91780ca334d0d4cfd86957558007e0`. The license text is in
`third_party/doom/LICENSE.TXT`.

vibe-os builds that original Doom engine source and links it against
project-owned assembly in `doom_port/`. `DOOM1.WAD` is game data, not source
code, and is not tracked.

The vendored Quake source lives in `third_party/quake`. It is GPL-covered id
Software source with license text in `third_party/quake/gnu.txt`.

vibe-os builds that original Quake engine source and links it against
project-owned assembly in `quake_port/`. `PAK0.PAK` is game data, not source
code, and is not tracked.

The vendor trees should stay pristine.

## What vibe-os Owns

- **Boot:** BIOS MBR, Stage 2, FAT16 kernel loading, protected-mode entry, and
  a NASM UEFI loader path.
- **Kernel:** GDT/IDT, exceptions, IRQs, syscalls, paging, memory accounting,
  process state, user/kernel transitions, timer preemption, drivers, and guest
  status reporting.
- **Storage:** ATA/IDE PIO, block-device dispatch, FAT16 reads and writes,
  packaged assets, config files, save files, and file descriptors.
- **User ABI:** Ring 3 ELF launch, user entry code, syscall wrappers, runtime
  helpers, process status, ABI probes, and the NASM guest launcher.
- **Payload adapters:** project-owned assembly glue for startup, libc/string
  and stdio/math support, input, framebuffer presentation, palette/video
  conversion, audio, persistence, and shutdown.
- **Devices:** keyboard, mouse, framebuffer/VBE-style presentation, and an
  SB16-style PCM audio path.

Project-owned guest code is assembly-first today: boot paths, kernel,
user/runtime code, ABI probes, libc compatibility, payload adapters, input,
audio, persistence, and startup code are NASM sources. C is used for the
original engine sources and host utilities. Python is not part of the tracked
build or proof path.

UEFI support exists as a NASM loader object/PE path, a dual BIOS/UEFI image
target, and an OVMF cloud proof workflow. Interactive play and the current
Doom/Quake proof lanes use the BIOS/IDE/QEMU PC route.

## Repository Map

- `boot/` - BIOS and UEFI loader assembly.
- `kernel/` - assembly kernel, drivers, process/runtime machinery, and status
  fields.
- `user/` - Ring 3 entry/runtime/probe assembly and public ABI headers.
- `doom_port/` - assembly adapter for original Doom.
- `quake_port/` - assembly adapter for original Quake.
- `third_party/doom/` - vendored Doom source; keep this pristine.
- `third_party/quake/` - vendored Quake source; keep this pristine.
- `tools/` - host-only C and shell utilities for images, ELF linking, cloud
  play, and status validation.
- `.github/workflows/` - cloud proof lanes.

## Boundaries

- Supported target: QEMU PC BIOS/IDE/PS2/VBE/SB16-style hardware.
- Not claimed: arbitrary physical PCs, installers, unknown disks, USB, AHCI,
  HDA, or a general Unix/POSIX system.
- Original Doom and Quake remain original Doom and Quake; vibe-os did not
  rewrite the game engines.
- Host build/proof utilities are not guest OS code.
- WADs, PAKs, generated disk images, screenshots, framebuffer dumps, raw audio,
  VM logs, and secrets stay out of git.

This README is the human overview. `make play` is the quickest way to see the
OS; the verification commands above are the quickest way to check it.
