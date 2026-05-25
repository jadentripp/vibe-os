# vibe-os

vibe-os is an assembly-native x86 OS/runtime. It boots a raw disk image, loads
its own kernel, and runs Ring 3 ELF programs through one process/syscall ABI.

The current proof programs are original Doom and original Quake. They are built
as `DOOM.ELF` and `QUAKE.ELF` because those are the executable filenames in the
FAT image and proof artifacts. They are not special ELF types. The public
process ABI uses generic payload kinds, not Doom or Quake process kinds.

The concrete test is simple:

Can an OS we own provide enough kernel, filesystem, process, memory, graphics,
input, and audio services for real game engines to run as user programs?

This is not Linux running Doom or Quake. It is not Chocolate Doom, doomgeneric,
SDL, or a desktop wrapper. QEMU boots a vibe-os disk image, the vibe-os loaders
and kernel take over the machine, and the payloads use vibe-os syscalls for
files, memory, time, input, video, audio, config, and saves.

## Current State

- Project-owned guest code is assembly-owned: boot paths, the UEFI loader, the
  kernel, user/runtime code, ABI probes, libc compatibility, payload adapters,
  input, audio, persistence, and startup code are NASM sources.
- The large C payloads are the original id Software Doom and Quake sources under
  `third_party/doom` and `third_party/quake`.
- Host-only C utilities build FAT images, link ELF32 payloads, and validate
  status artifacts. They are not part of the guest OS path.
- Python is not part of the tracked build or proof path.
- Release-quality Doom and Quake proofs run in GitHub Actions on disposable
  QEMU VMs. They launch the payload ELFs through the same generic process path,
  drive input, and check guest-emitted status fields.

There is still naming debt. Some status fields, build variables, compatibility
paths, and host image-builder internals still say `doom`, `quake`, `wad`, `pak`,
`DOOM1.WAD`, `PAK0.PAK`, or Doom save filenames. Those are current proof labels,
file-format names, or compatibility filenames. They do not mean vibe-os has a
Doom-only or Quake-only process ABI.

## What It Owns

- **Boot:** BIOS MBR, Stage 2 loader, FAT16 `KERNEL.ELF` loading, protected-mode
  entry, and a NASM UEFI loader path.
- **Kernel:** GDT/IDT, exceptions, IRQs, syscalls, paging, physical memory
  accounting, process state, user/kernel transitions, timer preemption, device
  drivers, and guest status reporting.
- **Storage:** ATA/IDE PIO, block-device dispatch, FAT16 reads and writes,
  packaged assets, config files, save files, and file-descriptor-style user ABI
  paths.
- **User ABI:** Ring 3 ELF launch, user entry code, syscall wrappers, runtime
  helpers, process status, and ABI probes.
- **Payload adapters:** assembly glue that lets the original engines use the
  vibe-os ABI for startup, libc/string/stdio/math calls, input, framebuffer
  presentation, palette/video conversion, audio, persistence, and shutdown.
- **Devices:** keyboard, mouse, framebuffer/VBE-style presentation, and an
  SB16-style PCM/audio path.

## Proof Payloads

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

## Boot Path

1. QEMU boots a raw vibe-os disk image.
2. The BIOS path runs Stage 1 and Stage 2.
3. Stage 2 reads `KERNEL.ELF` from FAT16 and enters the kernel.
4. The kernel sets up memory, interrupts, syscalls, files, input, video, audio,
   and user processes.
5. Probe ELFs exercise the generic user ABI.
6. Payload ELFs start as Ring 3 processes through the generic payload loader.
7. Payloads read external package data, render frames, accept input, emit audio,
   and can write config/save data through vibe-os paths.

UEFI has a NASM loader object/PE path, a dual BIOS/UEFI image target, and a
separate OVMF cloud proof workflow. Interactive play and the Doom/Quake payload
proof lanes currently use the BIOS/IDE/QEMU PC route.

## Build

Host-only checks are the default safe path:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-loader-object
git diff --check
```

Those checks build the boot image, `KERNEL.ELF`, probe ELFs, `DOOM.ELF`,
`QUAKE.ELF`, the host image/status utilities, and the assembly-native guest
build audit. They do not run local QEMU.

With `DOOM_WAD=` empty and `QUAKE_PAK` unset, the local image uses generated
Doom fixture data and omits a Quake PAK. To build an image with external game
data, keep the WAD/PAK outside git and pass the paths explicitly:

```sh
make DOOM_WAD=/path/to/DOOM1.WAD
make QUAKE_PAK=/path/to/PAK0.PAK
make DOOM_WAD=/path/to/DOOM1.WAD QUAKE_PAK=/path/to/PAK0.PAK
```

The generated image is `build/disk.img`. A normal build places `KERNEL.ELF`,
`USERPROB.ELF`, `ABIPROBE.ELF`, `DOOM.ELF`, and `QUAKE.ELF` in the FAT root.

The build also has generic data aliases:

```sh
make PRIMARY_ASSET=/path/to/DOOM1.WAD SECONDARY_PACKAGE=/path/to/PAK0.PAK
```

## Cloud Proofs

The Doom proof lane fetches or accepts `DOOM1.WAD`, validates it, builds a
temporary disk image, boots vibe-os in QEMU, launches `DOOM.ELF`, drives
scripted input, and uploads status-only proof artifacts.

```sh
gh workflow run real-wad-smoke.yml \
  --ref main \
  -f expected_ref=main \
  -f expected_sha="$(git rev-parse origin/main)"
```

The Quake proof lane fetches or accepts `PAK0.PAK`, validates it, builds a
temporary disk image, boots vibe-os in QEMU, launches `QUAKE.ELF`, drives
scripted input, and uploads status-only proof artifacts.

```sh
gh workflow run real-quake-smoke.yml \
  --ref main \
  -f expected_ref=main \
  -f expected_sha="$(git rev-parse origin/main)"
```

Successful proof status shows the payload ELF launched through the generic
process path, real external data reads, rendered frames, input progress,
gameplay or engine-state progress, `panic=NONE`, `shutdown=NONE`, and passing
storage/input/graphics/audio/process/memory/preemption gates.

Proof artifacts are intentionally status-only. Do not upload WADs, PAKs, disk
images, screenshots, rendered pixels, raw audio, VM logs, tokens, or one-time
codes.

## Local QEMU

Local QEMU is opt-in:

```sh
make ALLOW_LOCAL_VM=1 DOOM_WAD=/path/to/DOOM1.WAD smoke
make ALLOW_LOCAL_VM=1 QUAKE_PAK=/path/to/PAK0.PAK smoke
```

Use local QEMU for debugging and interactive iteration only. The cloud proof
lanes are the release proofs because they run from clean checkouts on disposable
runners and enforce the status contracts.

Manual cloud play is available through the noVNC helper:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

## Repository Map

- `boot/` - BIOS and UEFI loader assembly.
- `kernel/` - assembly kernel, drivers, process/runtime machinery, and status
  fields.
- `user/` - Ring 3 entry/runtime/probe assembly and public ABI headers.
- `doom_port/` - assembly adapter for original Doom.
- `quake_port/` - assembly adapter for original Quake.
- `third_party/doom/` - vendored Doom source; keep this pristine.
- `third_party/quake/` - vendored Quake source; keep this pristine.
- `tools/` - tiny host-only C and shell utilities for images, ELF linking,
  cloud play, and status validation.
- `.github/workflows/` - cloud proof lanes.

## Boundaries

- Supported target: QEMU PC BIOS/IDE/PS2/VBE/SB16-style hardware.
- Not claimed: arbitrary physical PCs, installers, unknown disks, USB, AHCI,
  HDA, data recovery, or a general Unix/POSIX system.
- Original Doom and Quake remain original Doom and Quake; vibe-os did not
  rewrite the game engines.
- Host build/proof utilities are not guest OS code.
- WADs, PAKs, generated disk images, screenshots, framebuffer dumps, raw audio,
  VM logs, and secrets stay out of git.

This README is the human overview. Detailed truth lives in code, workflow
checks, and guest status fields.
