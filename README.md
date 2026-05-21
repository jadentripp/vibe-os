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

The repo stays on one integration lane, `main`. Work is split by subsystem:
boot/process, VM, FAT/storage, graphics/input, audio, libc/ABI, cloud play UX,
docs, and proof checkers. Larger slices are delegated to parallel agents with
separate ownership boundaries, then merged through the same proof gates instead
of through long-lived branches.

The prompting strategy is intentionally mechanical: make a claim, turn it into a
host or cloud checker, implement the smallest real OS subsystem that can satisfy
that checker, and keep the failure artifacts honest. That is why the project has
proof scripts for things like original Doom provenance, WAD hygiene, FAT
mutation, Ring 3 exec, preemption, save/load persistence, audio continuity, and
safe cloud play.

Doom is the pressure test, not the excuse for shortcuts. Doom-specific needs are
used to harden reusable interfaces: file descriptors and VFS, generic input
events, clock syscalls, framebuffer ioctls, audio device/ring/stream contracts,
process launch, VM, FAT mutation, and a freestanding libc.

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
Prefer a 4+ CPU Codespace for longer noVNC play. If a 2-core session slows down,
use the printed diagnostics helper twice about a minute apart before treating it
as an OS runtime regression.

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

Disk layout: LBA 0 is Stage 1 MBR and partition table. LBA 1-16: Stage 2
bootloader. LBA 17-272: protected-mode kernel ELF image. LBA 2048+ is the
FAT16 partition containing `DOOM1.WAD`, `USERPROB.ELF`, `ABIPROBE.ELF`,
`DOOM.ELF`, writable Doom config/save files, and generated asset files.

## Docs

Markdown is capped to durable surfaces, not scratch notes. Human entry points
are this README plus `docs/play.md`. Technical and evidence contracts live in
`docs/architecture.md`, `docs/proof.md`, and `docs/doom-provenance.md`.
Auxiliary README files are scoped to tests, the future UEFI scaffold, and the
vendored Doom origin record.
