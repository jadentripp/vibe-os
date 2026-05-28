# vibe-os

vibe-os is a from-scratch OS that boots its own image, runs Ring 3 ELF apps,
and exposes its own syscall ABI for files, memory, time, input, video, audio,
config, and saves.

It has two active targets:

- x86 PC in QEMU: BIOS and UEFI image paths.
- Raspberry Pi 4 in QEMU: native AArch64 `kernel8.img` plus one FAT boot image.

Both targets show the guest launcher screen, discover apps from `/SYSTEM` and
`/APPS`, and launch Doom or Quake by generic app path. The games are installed
apps, not root `PAYLOAD*.ELF` slots.

This is not Linux, SDL, Chocolate Doom, or a desktop wrapper. QEMU provides
hardware; vibe-os owns the boot path, kernel/runtime code, storage, app
discovery, syscalls, framebuffer, input, and audio ABI.

## What QEMU Is

QEMU is the computer that vibe-os boots on during local and CI testing.
`qemu-system-x86_64` emulates a PC. `qemu-system-aarch64 -M raspi4b` emulates
a Raspberry Pi 4-like machine.

QEMU is not the OS. vibe-os still has to bring its own boot code, kernel,
drivers, filesystem reads, process model, syscalls, framebuffer rendering,
input handling, audio path, and app launcher.

When the README says the Pi target works in QEMU, it means the same Pi boot
image is attached to an emulated Pi 4 and vibe-os runs against emulated Pi
hardware. That is hardware-equivalent evidence, not a claim that the image has
already been proven on a physical Raspberry Pi board.

## Play

Requirements: `make`, `nasm`, `cc`, `git`, `curl`, and QEMU. Use
`qemu-system-x86_64` for x86 and `qemu-system-aarch64` for Pi 4.

Start the x86 PC image:

```sh
make play
```

Start the Pi 4 image locally:

```sh
make ALLOW_LOCAL_VM=1 pi4-local-qemu-live
```

Pick Doom with `1` or a click. Pick Quake with `2` or a click. WADs, PAKs,
disk images, screenshots, raw audio, VM logs, and secrets stay out of git.

Remote visible Pi play is available through noVNC:

```sh
./tools/play_now_codespaces.sh --pi4 --repo jadentripp/vibe-os --ref main
```

## App Layout

The image installs OS and app files in FAT paths:

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
and asks the kernel to launch that ELF by path. Doom and Quake are the first
proven apps, not special kernel cases.

## Raspberry Pi 4

The Pi 4 path is assembly-first AArch64: boot, exceptions, syscalls, timer,
preemption, framebuffer, input, storage, app discovery, runtime ABI, and app
entry are guest-owned assembly.

The QEMU proof boots one exact Pi image, selects Doom and Quake from the
launcher, reads app manifests plus real WAD/PAK assets, renders changed frames,
drives input, reports USB-Audio status, and reaches `panic=NONE` plus
`shutdown=NONE`.

Physical Raspberry Pi hardware proof is not claimed yet.

## Verify

Host-only checks:

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

The status checker is assembly: `tools/vibe_status_check.asm`.

## Source

- `boot/` - x86 BIOS and UEFI boot assembly.
- `boot/pi4/` - Pi 4 AArch64 boot/kernel/runtime assembly.
- `kernel/` - x86 kernel assembly.
- `user/` - Ring 3 launchers, runtime ABI, probes, and app manifests.
- `doom_port/` - Doom adapter code.
- `quake_port/` - Quake adapter code.
- `third_party/doom/` - pristine id Software Doom source.
- `third_party/quake/` - pristine id Software Quake source.
- `tools/` - assembly and shell host tools for images, linking, QEMU, and
  validation.

Project-owned guest code is assembly-first. Original game source stays in
`third_party/`; generated assets and external game data stay out of the repo.

## Boundaries

- Supported today: QEMU x86 PC and QEMU Raspberry Pi 4.
- Not claimed: arbitrary physical PCs, installers, unknown disks, completed Pi
  hardware proof, or a Unix/POSIX-compatible OS.
- Vendor Doom and Quake trees should stay pristine.

This README is the human overview. `make play` is the quickest x86 route;
`make ALLOW_LOCAL_VM=1 pi4-local-qemu-live` is the quickest Pi route.
