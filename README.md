# vibe-os

vibe-os is an assembly-native x86 OS/runtime that boots a raw disk image,
loads its own kernel, and launches Ring 3 ELF programs through a generic
process/syscall ABI. The current build packages two large proof payload
artifacts, `DOOM.ELF` and `QUAKE.ELF`; those names are concrete disk/proof
filenames, while the public process kinds are generic primary/secondary
payload kinds.

The central test is deliberately concrete:

Can an OS we own provide enough real kernel, filesystem, process, memory,
graphics, input, and audio services for real game payloads to run as user
processes?

This is not Linux running Doom or Quake. It is not Chocolate Doom, doomgeneric,
SDL, or a desktop wrapper. QEMU boots a vibe-os disk image, the vibe-os loaders
and kernel take over the machine, payloads read external WAD/PAK data through
vibe-os storage paths, and user processes talk to vibe-os for files, memory,
time, input, video, audio, config, and saves.

## Naming

The intended OS/runtime vocabulary is generic:

- **Payload** means a Ring 3 ELF loaded through the shared process/syscall ABI.
- **Primary asset** and **secondary package** mean external data files packaged
  into the FAT image for payloads to read through VFS.
- **Persistence** means the generic save/config path exposed through the user
  runtime.
- `DOOM.ELF`, `QUAKE.ELF`, `DOOM1.WAD`, and `PAK0.PAK` are current artifact
  filenames and proof fixtures, not separate public process classes.

Some shared status fields, build/package call sites, compatibility path
mappings, and the host image builder still expose concrete Doom/Quake names
such as `doom=`, `quake=`, `DOOM1.WAD`, `PAK0.PAK`, and Doom save filenames.
Those names reflect the current proof payloads and external file formats; they
are not a claim that the ELF/process ABI is Doom- or Quake-specific.

## Current Claim

- Project-owned guest code is assembly-owned: BIOS boot, UEFI loader, kernel,
  interrupt/syscall/user-entry paths, user runtime, ABI probes, libc
  compatibility surface, payload adapters, input, music/audio glue,
  persistence glue, and startup code are NASM sources.
- The current major C proof payloads are original id Software sources under
  `third_party/doom` and `third_party/quake`.
- Tiny host-only C utilities remain for image building, ELF linking, and status
  validation. They are not part of the guest OS path.
- Python is not part of the tracked build or proof path.
- The Doom/Quake release-quality payload proofs run in cloud lanes that boot
  disposable QEMU VMs, launch concrete payload artifacts through the same
  generic ELF/process path, drive scripted input, and check guest-emitted status
  fields.

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
- **Payload adapters:** startup, libc/string/stdio/math compatibility, input,
  framebuffer presentation, palette conversion, music/audio glue, persistence
  glue, and shutdown behavior for proof payloads.
- **Devices:** keyboard, mouse, framebuffer/VBE-style presentation, and an
  SB16-style PCM/audio path.

The current proof payloads are Doom and Quake. The point is to keep the OS
services general enough for other freestanding programs, while documenting the
remaining compatibility names honestly.

## Proof Payload Boundaries

The Doom and Quake ports are proof payload adapters. They contain the
payload-specific format and filename knowledge they need, while shared
OS/runtime code is being kept or moved toward payload, package, asset, process,
VFS, graphics, input, audio, memory, and persistence terms.

### Doom

The vendored Doom source lives in `third_party/doom/linuxdoom-1.10`. It is the
official id Software public Doom source release, imported from
`id-Software/DOOM` commit `a77dfb96cb91780ca334d0d4cfd86957558007e0`; its
GPL-2.0 license text is recorded in `third_party/doom/LICENSE.TXT`.

That vendor tree should stay pristine. vibe-os builds the original Doom engine
sources and links them against project-owned assembly in `doom_port/`. The
Unix/Linux platform files from the Doom tree are not the OS port; vibe-os
provides that layer.

`DOOM1.WAD` is game data, not source code, and is not tracked.

### Quake

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
6. Large payload ELFs start as Ring 3 processes through the generic payload
   loader. The current proof image includes artifacts named `DOOM.ELF` and
   `QUAKE.ELF`.
7. Payloads read external package data, render frames, accept scripted or human
   input, emit audio, and can write config/save data through vibe-os paths.

UEFI has a NASM loader object/PE path, a dual-image build target, and a separate
OVMF cloud proof workflow. Interactive play and the Doom/Quake payload proof
lanes use the BIOS/IDE/QEMU PC route.

## Build

Host-only checks are the default safe path:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-loader-object
git diff --check
```

The explicit empty `DOOM_WAD=` keeps the Doom-side host-only checks on generated
fixture data instead of requiring local game data; with `QUAKE_PAK` unset, the
Quake data package is also omitted from the local image.

Those checks build the boot image, `KERNEL.ELF`, user probe ELFs, the current
proof payload ELFs, the host image/status utilities, and the assembly-native
guest build audit.

To build a local disk image with external game data, keep the WAD/PAK outside
git and pass it explicitly:

```sh
make DOOM_WAD=/path/to/DOOM1.WAD
make QUAKE_PAK=/path/to/PAK0.PAK
make DOOM_WAD=/path/to/DOOM1.WAD QUAKE_PAK=/path/to/PAK0.PAK
```

The generated image is `build/disk.img`. The FAT16 disk packages the guest
artifacts under their boot/runtime names. The build layer also exposes generic
aliases for the packaged data path:

```sh
make PRIMARY_ASSET=/path/to/DOOM1.WAD SECONDARY_PACKAGE=/path/to/PAK0.PAK
```

## Doom Real-WAD Proof

The Doom proof lane runs in GitHub Actions on a disposable runner. With no
custom WAD URL, it fetches and validates the public shareware `DOOM1.WAD`,
builds a temporary disk image, boots vibe-os in QEMU, drives scripted gameplay
input, and uploads status-only proof artifacts.

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

A successful Doom proof should show the Doom artifact launched through the
generic process path, real WAD reads, `gameplay=OK`, `panic=NONE`,
`shutdown=NONE`, graphics and audio status, and a nonzero preemption proof.
Storage, input, process, memory, APIC/HPET, and VFS gates are checked by the
workflow and `tools/vibe_status_check.c`.

## Real-Quake Proof

The Quake proof lane accepts a supplied `PAK0.PAK` URL and SHA-1 or falls back
to the public shareware archive and checked SHA-1 in the workflow. It builds a
temporary disk image, boots vibe-os in QEMU, launches `QUAKE.ELF`, and checks
guest status fields for real PAK reads, rendered frames, input, audio, gameplay
progress, process legitimacy, memory, and preemption.

```sh
gh workflow run real-quake-smoke.yml \
  --ref main \
  -f expected_ref=main \
  -f expected_sha="$(git rev-parse origin/main)"
```

After the run completes, download only the status artifact:

```sh
gh run download RUN_ID \
  --repo jadentripp/vibe-os \
  --name real-quake-smoke-proof-status \
  --dir build/cloud-quake-RUN_ID

tr ' ' '\n' < build/cloud-quake-RUN_ID/status.txt |
  grep -E '^(exec|uexec|quake|quakerun|quakepak|qgame|qframe|qinput|qaudio|panic|shutdown|gfx|audio|preempt|pmm|vmm)='
```

A successful Quake proof should show the Quake artifact launched through the
generic process path, real PAK accounting in `quakepak=`, gameplay progress in
`qgame=OK`, advancing frame/input/audio counters, `panic=NONE`,
`shutdown=NONE`, graphics and audio status, memory gates, and nonzero
preemption.

## Proof Artifacts

The proof artifact policy is intentionally narrow: upload status/JSON proof
only, never WADs, PAKs, disk images, screenshots, rendered pixels, raw audio,
VM logs, tokens, or one-time codes. The trusted evidence is guest-emitted
status fields plus tiny compiled validators, not screenshots or host-side
guesswork.

## Local QEMU

Local QEMU is opt-in:

```sh
make ALLOW_LOCAL_VM=1 DOOM_WAD=/path/to/DOOM1.WAD smoke
make ALLOW_LOCAL_VM=1 QUAKE_PAK=/path/to/PAK0.PAK smoke
```

Use it for debugging and interactive iteration. The cloud proof lanes remain
the authoritative release proofs because they run from clean checkouts on
disposable runners and enforce the full status contracts.

Manual cloud play is available through the noVNC helper:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

## Repository Map

- `boot/` - BIOS and UEFI loader assembly.
- `kernel/` - assembly kernel, drivers, process/runtime machinery, and status
  fields.
- `user/` - Ring 3 entry/runtime/probe assembly.
- `doom_port/` - assembly payload adapter for original Doom: startup, libc,
  input, audio, save/config, and video-facing glue.
- `quake_port/` - assembly payload adapter for original Quake: startup, input,
  audio, math, setjmp, sys, and video glue.
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
- WADs, PAKs, generated disk images, screenshots, framebuffer dumps, raw audio,
  VM logs, and secrets stay out of git.

This README is the human overview. Detailed truth should live in code,
workflow checks, and guest status fields. When a README claim and proof
disagree, fix the weaker one before claiming success.
