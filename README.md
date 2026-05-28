# vibe-os

vibe-os is a from-scratch operating system that boots Doom and Quake as normal
apps inside the guest OS. It has two active hardware targets:

- x86 PC in QEMU: BIOS and UEFI image paths.
- Raspberry Pi 4 in QEMU: native AArch64 `kernel8.img` plus one FAT boot image.

Both targets boot an OS image, show the guest launcher screen, discover apps
from the filesystem, and launch Doom or Quake through a generic Ring 3 ELF exec
path. The games live under `/APPS`, not in hard-coded payload slots.

This is not Linux, SDL, Chocolate Doom, or a desktop wrapper. QEMU provides
hardware; vibe-os owns the boot path, kernel, drivers, files, processes,
syscalls, framebuffer, input, audio ABI, and app launch path.

## Play

Requirements: `make`, `nasm`, `clang` or `cc`, `git`, `curl`, and QEMU.
Use `qemu-system-x86_64` for the PC target and `qemu-system-aarch64` for Pi 4.

Start the x86 PC image:

```sh
make play
```

Start the Pi 4 image locally:

```sh
make ALLOW_LOCAL_VM=1 pi4-local-qemu-live
```

The launcher accepts keyboard and mouse input. Press `1` or click Doom; press
`2` or click Quake. WAD and PAK files stay outside git and are prepared in an
external cache.

Remote visible Pi play is still available through noVNC:

```sh
./tools/play_now_codespaces.sh --pi4 --repo jadentripp/vibe-os --ref main
```

## Filesystem Shape

The boot image installs OS files and apps in a normal FAT/VFS layout:

```text
/SYSTEM/INIT.ELF
/SYSTEM/ABIPROBE.ELF
/APPS/INDEX.TXT
/APPS/DOOM/APP.TXT
/APPS/DOOM/APP.ELF
/APPS/QUAKE/APP.TXT
/APPS/QUAKE/APP.ELF
/DOOM1.WAD
/ID1/PAK0.PAK
```

The launcher reads `/APPS/INDEX.TXT`, opens each app manifest, reads the
`exec=` path, and asks the kernel to launch that AArch64 or x86 ELF by path.
Doom and Quake are the first proven apps, not kernel exceptions.

## Verify

Fast host checks:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-loader-object
make x86-preservation-host-check
make pi4-code-gates vm-status-proof-check pi4-status-evidence-check
git diff --check
```

Pi 4 QEMU proof with public shareware data:

```sh
make ALLOW_LOCAL_VM=1 pi4-prepared-real-assets-final-gates
```

A green Pi proof validates the exact image that QEMU boots: serial status,
framebuffer changes, app index and manifest reads, Doom WAD reads, Quake PAK
reads, generic app ELF exec by path, process/memory/preemption gates, USB input,
USB audio status, rendered frames, gameplay input progress, `panic=NONE`, and
`shutdown=NONE`.

The status contract lives in `tools/vibe_status_check.c`.

## Source

- `boot/` - x86 BIOS, UEFI, and Pi 4 boot assembly.
- `kernel/` - x86 kernel assembly.
- `boot/pi4/` - Pi 4 AArch64 kernel/runtime assembly.
- `user/` - Ring 3 launchers, runtime ABI, probes, and app manifests.
- `doom_port/` - project-owned Doom adapter code.
- `quake_port/` - project-owned Quake adapter code.
- `third_party/doom/` - pristine id Software Doom source.
- `third_party/quake/` - pristine id Software Quake source.
- `tools/` - small host utilities for images, linking, QEMU, and validation.

Project-owned guest OS code is assembly-first. C is used for original game
sources, modest port glue where it is smaller, and host tools. Python is not
part of the build or proof path.

## Boundaries

- Real Raspberry Pi hardware proof is not claimed yet; current Pi evidence is
  local QEMU hardware-equivalent evidence.
- WADs, PAKs, disk images, framebuffer dumps, raw audio, VM logs, and secrets
  stay out of git.
- The vendor Doom and Quake trees should stay pristine.
- vibe-os is not a Unix/POSIX clone.

This README is the human overview. `make play` is the quickest x86 route;
`make ALLOW_LOCAL_VM=1 pi4-local-qemu-live` is the quickest Pi route.
