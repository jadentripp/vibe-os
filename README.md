# vibe-os

vibe-os is a from-scratch OS that boots its own image, starts Ring 3 ELF apps,
and exposes its own syscall ABI for storage, memory, time, input, video, audio,
configuration, and saves.

Doom and Quake are the first proven apps. They are installed in the guest
filesystem, discovered by the launcher, and started through the same generic
app exec path.

This is not Linux, SDL, Chocolate Doom, or a desktop wrapper. QEMU provides the
machine; vibe-os provides the boot path, kernel/runtime code, drivers, process
model, filesystem, syscalls, framebuffer, input, and audio ABI.

## Status

| Target | Command | State |
| --- | --- | --- |
| x86 PC in QEMU | `make play` | Playable BIOS image; UEFI path is built and checked. |
| Raspberry Pi 4 in QEMU | `make ALLOW_LOCAL_VM=1 pi4-local-qemu-live` | Native AArch64 image with launcher, Doom, Quake, input, framebuffer, storage, and USB-Audio proof. |
| Physical Raspberry Pi 4 | Not claimed yet | The Pi image has QEMU hardware-equivalent evidence, not real-board proof. |

## Quick Start

Install `make`, `nasm`, `cc`, `git`, `curl`, and QEMU. Use
`qemu-system-x86_64` for the PC target and `qemu-system-aarch64` for Pi 4.

Start the x86 PC image:

```sh
make play
```

Start the Pi 4 image:

```sh
make ALLOW_LOCAL_VM=1 pi4-local-qemu-live
```

The guest launcher screen accepts keyboard and mouse input. Press `1` or click
Doom; press `2` or click Quake.

Remote Pi play through noVNC:

```sh
./tools/play_now_codespaces.sh --pi4 --repo jadentripp/vibe-os --ref main
```

## App Model

Apps are installed through normal FAT/VFS paths:

```text
/SYSTEM/INIT.ELF
/SYSTEM/ABIPROBE.ELF
/APPS/INDEX.TXT
/APPS/DOOM/MANIFEST.TXT
/APPS/DOOM/APP.ELF
/APPS/QUAKE/MANIFEST.TXT
/APPS/QUAKE/APP.ELF
/DOOM1.WAD
/ID1/PAK0.PAK
```

The launcher reads `/APPS/INDEX.TXT`, opens each app manifest, reads `exec=`,
and asks the kernel to launch that ELF by path. Doom and Quake are not special
kernel payload slots.

## Architecture

- Boot: x86 BIOS, x86 UEFI loader, and Pi 4 AArch64 boot image paths.
- Kernel/runtime: interrupts, exceptions, syscalls, memory, process state,
  timer preemption, storage, framebuffer, input, audio status, and guest
  status reporting.
- User ABI: Ring 3 entry, syscall wrappers, app launcher, ABI probes, and app
  manifests.
- App adapters: project-owned Doom and Quake glue for startup, files, input,
  video, audio, persistence, and shutdown.
- Tools: assembly and shell host tools for image creation, linking, QEMU
  launch, and validation.

Project-owned guest code is assembly-first. Original game source remains in
`third_party/`; generated images and external game data stay out of the repo.

## Verification

Host checks:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make x86-preservation-host-check
make pi4-code-gates vm-status-proof-check pi4-status-evidence-check
git diff --check
```

Pi 4 QEMU proof with public shareware data:

```sh
make ALLOW_LOCAL_VM=1 pi4-prepared-real-assets-final-gates
```

The Pi proof boots one exact image, selects Doom and Quake from the launcher,
reads app manifests plus real WAD/PAK assets, renders changed frames, drives
input, reports USB-Audio status, and reaches `panic=NONE` plus
`shutdown=NONE`.

The status checker is assembly: `tools/vibe_status_check.asm`.

## Repository

- `boot/` - x86 BIOS and UEFI boot assembly.
- `boot/pi4/` - Pi 4 AArch64 boot/kernel/runtime assembly.
- `kernel/` - x86 kernel assembly.
- `user/` - Ring 3 launchers, runtime ABI, probes, and app manifests.
- `doom_port/` - Doom adapter code.
- `quake_port/` - Quake adapter code.
- `third_party/doom/` - pristine id Software Doom source.
- `third_party/quake/` - pristine id Software Quake source.
- `tools/` - host tooling for images, linking, QEMU, and validation.

## Glossary

- QEMU: the emulated computer vibe-os boots on during local and CI testing.
  QEMU is not the OS.
- Ring 0: kernel mode, where the OS can touch hardware, memory mappings,
  interrupts, and privileged CPU state.
- Ring 3: user mode, where normal apps run. Doom and Quake run there and ask
  the OS for files, framebuffer output, input, audio, and time through syscalls.
- ELF: the executable file format vibe-os loads for user apps.
- Hardware-equivalent Pi proof: the Pi boot image running on QEMU's emulated
  Raspberry Pi 4 hardware. It is not physical Raspberry Pi proof.

## Boundaries

- WADs, PAKs, disk images, screenshots, raw audio, VM logs, and secrets stay
  out of git.
- Vendor Doom and Quake trees should stay pristine.
- Physical Raspberry Pi hardware proof is not claimed yet.
- vibe-os is not a Unix/POSIX-compatible OS.

This README is the human overview. `make play` is the quickest x86 route;
`make ALLOW_LOCAL_VM=1 pi4-local-qemu-live` is the quickest Pi route.
