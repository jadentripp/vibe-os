# vibe-os

vibe-os is an assembly-native x86 OS/runtime that boots a raw disk image,
loads its own kernel, launches Ring 3 ELF programs, and runs large verified
payloads such as the original id Software Linux Doom engine as `DOOM.ELF` and
original Quake as `QUAKE.ELF`.

The central test is deliberately concrete:

Can an OS we own provide enough real kernel, filesystem, process, memory,
graphics, input, and audio services for real game payloads to run as user
processes?

This is not Linux running Doom or Quake. It is not Chocolate Doom, doomgeneric,
SDL, or a desktop wrapper. QEMU boots a vibe-os disk image, the vibe-os loaders
and kernel take over the machine, payloads read external WAD/PAK data through
vibe-os storage paths, and user processes talk to vibe-os for files, memory,
time, input, video, audio, config, and saves.

## Current Claim

- Project-owned guest code is assembly-owned: BIOS boot, UEFI loader, kernel,
  interrupt/syscall/user-entry paths, user runtime, ABI probes, libc
  compatibility surface, payload platform layers, input, music/audio glue,
  save/config glue, and startup code are NASM sources.
- The major C payloads are original id Software sources under
  `third_party/doom` and `third_party/quake`.
- Tiny host-only C utilities remain for image building, ELF linking, and status
  validation. They are not part of the guest OS path.
- Python is not part of the tracked build or proof path.
- Release-quality proofs run in cloud lanes that boot disposable QEMU VMs,
  launch `DOOM.ELF` or `QUAKE.ELF`, drive scripted input, and check
  guest-emitted status fields.

In short: vibe-os is an assembly-native OS/runtime/platform environment that
runs original game engines as Ring 3 payloads through a generic ELF/process and
syscall ABI.

## What It Owns

- **Boot and loaders:** BIOS MBR, Stage 2 loader, FAT16 `KERNEL.ELF` loading,
  ELF validation, protected-mode entry, and a NASM UEFI loader path.
- **Kernel:** GDT/IDT, exceptions, IRQs, syscalls, paging, physical memory
  accounting, process state, user/kernel transitions, timer preemption, and
  guest status reporting.
- **Storage:** ATA/IDE PIO, block-device dispatch, FAT16 reads and writes,
  package/asset loading, config files, save files, and file-descriptor-style
  user ABI paths.
- **User ABI:** Ring 3 ELF launch, user entry code, syscall wrappers, runtime
  helpers, and ABI probes.
- **Payload platform glue:** startup, libc/string/stdio/math compatibility,
  input, framebuffer presentation, palette conversion, music/audio glue,
  save/config glue, and shutdown behavior for verified payloads.
- **Devices:** keyboard, mouse, framebuffer/VBE-style presentation, and an
  SB16-style PCM/audio path.

Doom and Quake are proof payloads. The point is to make OS services general
enough for other freestanding programs, not to hide app-only shortcuts behind a
demo.

## Doom Boundary

The vendored Doom source lives in `third_party/doom/linuxdoom-1.10`. It is the
official id Software public Doom source release, imported from
`id-Software/DOOM` commit `a77dfb96cb91780ca334d0d4cfd86957558007e0`; its
GPL-2.0 license text is recorded in `third_party/doom/LICENSE.TXT`.

That vendor tree should stay pristine. vibe-os builds the original Doom engine
sources and links them against project-owned assembly in `doom_port/`. The
Unix/Linux platform files from the Doom tree are not the OS port; vibe-os
provides that layer.

`DOOM1.WAD` is game data, not source code, and is not tracked.

## Quake Boundary

The vendored Quake source lives in `third_party/quake`. It is GPL-covered id
Software source with license text in `third_party/quake/gnu.txt`.

That vendor tree should stay pristine. vibe-os builds the original Quake engine
sources and links them against project-owned assembly in `quake_port/`.

`PAK0.PAK` is game data, not source code, and is not tracked.

## Boot Path

1. QEMU boots a raw vibe-os disk image.
2. The BIOS path runs Stage 1 and Stage 2.
3. Stage 2 reads `KERNEL.ELF` from FAT16 and enters the kernel.
4. The kernel sets up memory, interrupts, syscalls, files, input, video, audio,
   and user processes.
5. Probe ELFs exercise the generic user ABI.
6. Large payload ELFs such as `DOOM.ELF` and `QUAKE.ELF` start as Ring 3
   processes.
7. Payloads read external package data, render frames, accept scripted or human
   input, emit audio, and can write config/save data through vibe-os paths.

UEFI has a NASM loader object/PE path and dual-image build target. Interactive
play and real-WAD proof currently use the BIOS/IDE/QEMU PC route.

## Build

Host-only checks are the default safe path:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-loader-object
git diff --check
```

Those checks build the boot image, `KERNEL.ELF`, user probe ELFs, `DOOM.ELF`,
`QUAKE.ELF`, the host image/status utilities, and the assembly-native guest
build audit.

To build a local disk image with a real WAD, keep the WAD outside git and pass
it explicitly:

```sh
make DOOM_WAD=/path/to/DOOM1.WAD
```

The generated image is `build/disk.img`. The FAT16 disk packages the guest
artifacts under their boot/runtime names, including `KERNEL.ELF`,
`USERPROB.ELF`, `ABIPROBE.ELF`, `DOOM.ELF`, and `QUAKE.ELF`.

## Real-WAD Proof

The strongest proof runs in GitHub Actions on a disposable runner. It fetches
and validates the public shareware `DOOM1.WAD`, builds a temporary disk image,
boots vibe-os in QEMU, drives scripted gameplay input, and uploads status-only
proof artifacts.

```sh
gh workflow run real-wad-smoke.yml \
  --ref main \
  -f expected_ref=main \
  -f expected_sha="$(git rev-parse origin/main)"
```

After the run completes, download only the status artifact:

```sh
gh run download RUN_ID \
  --repo jadentripp/vibe-os \
  --name real-wad-smoke-proof-status \
  --dir build/cloud-run-RUN_ID

tr ' ' '\n' < build/cloud-run-RUN_ID/status.txt |
  grep -E '^(path|usr|doom|doomrun|doomopen|doomread|gameplay|panic|shutdown|gfx|audio|apic|hpet|preempt)='
```

A successful main proof should show `path=DOOM.ELF`, `usr=OK`, `doom=OK`,
`doomrun=RUN` or `doomrun=EXIT`, `doomopen=OK`, `doomread=OK`,
`gameplay=OK`, `panic=NONE`, `shutdown=NONE`, graphics and audio status, and a
nonzero preemption proof. Storage, input, process, memory, APIC/HPET, and VFS
gates are checked by the workflow and `tools/vibe_status_check.c`.

## Real-Quake Proof

The Quake proof lane fetches and validates public shareware `PAK0.PAK`, builds
a temporary disk image, boots vibe-os in QEMU, launches `QUAKE.ELF`, and checks
guest status fields for real PAK reads, rendered frames, input, audio, gameplay
progress, process legitimacy, memory, and preemption.

```sh
gh workflow run real-quake-smoke.yml \
  --ref main \
  -f expected_ref=main \
  -f expected_sha="$(git rev-parse origin/main)"
```

The proof artifact policy is intentionally narrow: upload status/JSON proof
only, never WADs, disk images, screenshots, rendered pixels, raw audio, VM
logs, tokens, or one-time codes.

## Local QEMU

Local QEMU is opt-in:

```sh
make ALLOW_LOCAL_VM=1 DOOM_WAD=/path/to/DOOM1.WAD smoke
```

Use it for debugging and interactive iteration. The cloud real-WAD lane remains
the authoritative release proof because it runs from a clean checkout on a
disposable runner and enforces the full status contract.

Manual cloud play is available through the noVNC helper:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

## Repository Map

- `boot/` - BIOS and UEFI loader assembly.
- `kernel/` - assembly kernel, drivers, process/runtime machinery, and status
  fields.
- `user/` - Ring 3 entry/runtime/probe assembly.
- `doom_port/` - assembly platform, libc, input, audio, save/config, and
  startup layer that lets original Doom run on vibe-os.
- `quake_port/` - assembly platform, input, audio, math, setjmp, sys, video,
  and startup layer that lets original Quake run on vibe-os.
- `third_party/doom/` - vendored Doom source; keep this pristine.
- `third_party/quake/` - vendored Quake source; keep this pristine.
- `tools/` - tiny host-only C and shell utilities for building images,
  linking ELF32 payloads, launching cloud play, and validating status.
- `.github/workflows/` - cloud proof lanes.

## Boundaries

- Supported target: QEMU PC BIOS/IDE/PS2/VBE/SB16-style hardware.
- Not claimed: arbitrary physical PCs, installers, unknown disks, USB, AHCI,
  HDA, data recovery, or a general Unix/POSIX system.
- Original Doom and Quake remain original Doom and Quake; vibe-os did not
  rewrite the game engines.
- Host build/proof utilities are workshop equipment, not guest OS code.
- WADs, generated disk images, screenshots, framebuffer dumps, raw audio, VM
  logs, and secrets stay out of git.

This README is the human overview. Detailed truth should live in code,
workflow checks, and guest status fields. When a README claim and proof
disagree, fix the weaker one before claiming success.
