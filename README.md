# vibe-os

vibe-os is a Doom-focused hobby operating system. It boots a repo-owned x86
kernel, brings up the hardware/runtime surface Doom needs, and runs the
official id Software public release, `linuxdoom-1.10`, through a port layer
outside the vendor tree.

The project stance is "legit but playable first": original Doom source stays
pristine, WADs and proof artifacts stay out of git, and public status only says
what the automated and cloud proof gates have shown.

## Status

`main` is an OS bring-up path, not a launcher. The BIOS boot sector and Stage 2
loader enter a 32-bit protected-mode kernel with paging, interrupts, timer
preemption, Ring 3 syscall entry, process records, exec/wait, file-descriptor
ownership, ATA PIO, FAT16 root mutation, framebuffer output, PS/2 keyboard and
mouse input, SB16-oriented audio plumbing, and a freestanding C runtime.

Doom runs as `DOOM.ELF` from the FAT image after `USERPROB.ELF` and
`ABIPROBE.ELF` prove the public ABI and generic exec handoff. The cloud proof
is green for first-boot gameplay, SB16/audio continuity, and save/load
persistence: with real `DOOM1.WAD`, the OS reaches E1M1, accepts input from the
scripted phases, keeps Doom as a Ring 3 process, writes `DOOMSAV*.DSG`, reboots
the same disk image, and loads the save back into gameplay.

The human-facing boundary is narrower. A reviewed remote noVNC session still
has to show a person playing from the documented bundle before this README
treats that lane as proven. Long-form evidence, historical failures, and
workflow dispatch examples live in `docs/proof.md` rather than here.

## Working Model

The repo stays on one integration lane, `main`, while implementation work is
split across boot/process, FAT/storage, graphics/input, audio, libc/ABI, cloud
play UX, docs, and proof checkers. Serious claims become executable contracts,
`third_party/doom` stays pristine, VM execution happens in disposable cloud
environments by default, and Doom-specific pressure is used to harden reusable
OS interfaces instead of adding shortcuts.

## Try It Safely

Use a disposable remote run on a cloud machine. Do not run local QEMU on this
Mac unless you explicitly opt in.

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
./tools/play_now_codespaces.sh --web-url --repo jadentripp/vibe-os --ref main
./tools/play_now_remote.sh
```

The Codespaces/noVNC path keeps QEMU, disk images, WAD data, framebuffer
captures, and raw audio off the laptop. For reviewed human proof, use
`docs/play.md`; the generated bundle is checked by
`tools/check_cloud_playability_artifacts.py --human-session`.

## Build And Prove

Host-side checks are safe:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= build-only
python3 -m unittest discover -s tests/host -p 'test_*.py'
make ALLOW_LOCAL_VM=0 cloud-playability-check
```

Real-WAD proofs run in GitHub Actions, Codespaces, or disposable cloud hosts.
Use `docs/proof.md` and `docs/play.md` for dispatch commands and artifact
checks.

## Claim Boundaries

Generated IWAD-shaped fixtures are useful for public CI, but they do not count
as real Doom proof. Checked-in WAD files, disk images, framebuffer dumps, and
raw audio captures are forbidden.

The hardware claim is bounded to QEMU BIOS/IDE/PS2/VBE/SB16: BIOS, IDE/ATA,
PS/2, VBE/Mode 13h, and SB16-style audio. That evidence is limited to the
emulated device model. `boot/uefi/README.md` is a contract-only UEFI scaffold,
and SUPPORT[UEFI] remains unclaimed. PCI fields such as `pci=`, `pciprobe=`,
and `pcitabcap=` plus the `PCI_TABLE[...]` / `PCI_TABLE_CONTRACT[...]` rows are
status-only QEMU bus-0 diagnostics; see `docs/architecture.md`.

The storage claim is also bounded. The OS mutates and reboots the repo-generated
FAT16 disk image in disposable cloud QEMU, but vibe-os is not an installable OS
for arbitrary disks. It does not partition blank media, discover unknown
existing partitions, or recover damaged user disks. See
`docs/architecture.md` for the exact install and recovery boundary.

## Project Shape

The OS is intentionally Doom-first, but the subsystems are being built as
general OS surfaces instead of one-off Doom hooks: file descriptors and VFS,
generic input events, clock syscalls, framebuffer ioctls, audio device/ring/
stream contracts, process launch, VM, FAT mutation, and a freestanding libc.

Disk layout: LBA 0 is Stage 1 MBR and partition table. LBA 1-16: Stage 2
bootloader. LBA 17-208: protected-mode kernel ELF image. LBA 2048+ is the
FAT16 partition containing `DOOM1.WAD`, `USERPROB.ELF`, `ABIPROBE.ELF`,
`DOOM.ELF`, writable Doom config/save files, and generated asset files.

## Deeper Docs

- `docs/architecture.md` is the technical contract: boot, VM/process, FAT,
  libc/runtime, input, graphics, audio, hardware boundaries, and UEFI gaps.
- `docs/proof.md` explains proof gates, evidence history, current gaps, and
  the legitimacy roadmap.
- `docs/play.md` covers Codespaces/noVNC testing and reviewed human sessions.
- `docs/doom-provenance.md` documents source and WAD boundaries.
