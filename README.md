# vibe-os

vibe-os is a from-scratch OS that boots its own image, runs Ring 3 ELF apps,
and exposes its own syscall ABI for files, memory, time, input, video, audio,
config, and saves.

`main` is currently playable on the 32-bit x86 QEMU PC build. Raspberry Pi 4 is
the active native port target: assembly-first AArch64 boot/runtime, same
launcher/app model, no Linux wrapper.

## Play

Requirements: `make`, `nasm`, `cc`, `git`, `curl`, and
`qemu-system-x86_64`.

```sh
make play
```

This fetches public shareware Doom/Quake data into `~/.cache/vibe-os`, builds
`build/play/disk.img`, boots vibe-os, and opens the launcher. Pick Doom or
Quake with `1`/`2`, `W`/`S` plus Enter, or the mouse.

Use your own data:

```sh
DOOM_WAD=/absolute/path/to/DOOM1.WAD \
  QUAKE_PAK=/absolute/path/to/PAK0.PAK \
  make play
```

WADs, PAKs, disk images, screenshots, raw audio, VM logs, and secrets stay out
of git.

## App Layout

The image uses normal FAT paths instead of root `PAYLOAD*.ELF` slots:

- `/SYSTEM/INIT.ELF` - launcher
- `/SYSTEM/ABIPROBE.ELF` - ABI probe
- `/APPS/INDEX.TXT` - installed app index
- `/APPS/DOOM/MANIFEST.TXT`
- `/APPS/DOOM/APP.ELF`
- `/APPS/QUAKE/MANIFEST.TXT`
- `/APPS/QUAKE/APP.ELF`

Doom and Quake are the first proven apps, not special process paths.

## Raspberry Pi 4

Pi 4 is not claimed playable on `main` yet.

Target shape:

- Boot one Pi image natively on Raspberry Pi 4.
- Show the same vibe-os launcher.
- Discover apps from `/SYSTEM` and `/APPS`.
- Launch Doom and Quake by generic AArch64 Ring 3 ELF exec path.
- Prove serial boot, framebuffer output, timer/preemption, FAT/VFS app and
  asset reads, input, audio status, rendered frames, gameplay progress,
  `panic=NONE`, `shutdown=NONE`, and honest final gates.

## Verify

Host-only:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
git diff --check
```

Cloud QEMU proof lanes:

```sh
gh workflow run real-wad-smoke.yml --ref main
gh workflow run real-quake-smoke.yml --ref main
```

Manual cloud play:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

## Boundaries

Supported today: QEMU PC BIOS/IDE/PS2/VBE/SB16-style hardware.

In progress: Raspberry Pi 4 native AArch64.

Not claimed: arbitrary physical PCs, installers, unknown disks, AHCI, HDA,
completed Pi hardware proof, or a Unix/POSIX-compatible OS.

The vendored Doom and Quake source trees in `third_party/` should stay
pristine. Project-owned guest code is assembly-first; original game engine C is
compiled as third-party source.
