# vibe-os

vibe-os is a tiny operating system built to answer one blunt question: can our
own bootloader, kernel, drivers, filesystem, C runtime, and process path run the
original Doom?

It is not Linux running Doom. It is not Chocolate Doom, doomgeneric, or a normal
desktop app in costume. A raw disk image boots on an x86 PC model, our code takes
over the CPU, our filesystem finds the game files, and the official id Software
public release, `linuxdoom-1.10`, runs through a platform layer outside the
vendor tree.

In plain English: the cloud computer wakes up into vibe-os, vibe-os finds Doom
on disk, and Doom plays by asking vibe-os for memory, files, time, input,
graphics, and audio.

## Status

You can play Doom through Codespaces/noVNC on a disposable cloud machine. That
keeps QEMU and the bootable disk image away from the laptop.

The cloud proof is green for first-boot gameplay, SB16/audio continuity, and
save/load persistence with real `DOOM1.WAD`: it accepts input, runs Doom as a
Ring 3 process, writes `DOOMSAV*.DSG`, and loads the save back into gameplay.

Ring 3 is the CPU's normal user-program privilege level. Here it means Doom
crosses a syscall boundary like another small C program would.

Long-form evidence, historical failures, and workflow dispatch examples live in
`docs/proof.txt`. The short version: Doom is playable through the safe cloud
path, and the stance is "legit but playable first": make the demo work, then
keep replacing shortcuts with real OS subsystems.

## Safe Play

Use a disposable remote run. Do not run local QEMU on this Mac unless you
explicitly opt in.

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
./tools/play_now_codespaces.sh --web-url --repo jadentripp/vibe-os --ref main
```

The script prints a browser link, diagnostics commands, and cleanup command. A
4+ CPU Codespace is best for longer sessions; 2-core sessions can slow down.

## Boot Story

Here is the boot path without assuming you build operating systems:

1. QEMU acts like a simple x86 PC in the cloud.
2. The first disk sector loads a bigger bootloader.
3. The bootloader switches the CPU from early BIOS mode into 32-bit protected
   mode, where programs can use more memory and the CPU can enforce privilege
   levels.
4. The kernel sets up memory, interrupts, timers, input, graphics, audio, files,
   and syscalls.
5. Small user programs run first to prove the generic process path works.
6. Doom starts as `DOOM.ELF`, reads `DOOM1.WAD` from the FAT16 disk image, and
   draws frames through the OS framebuffer path.

The point is not to make a fake Doom launcher. Doom is the stress test for real
OS services: process launch, file I/O, memory, clock, keyboard, mouse,
framebuffer, audio, and a freestanding C runtime.

## What Is Real Here

The project owns the machine path instead of outsourcing it to a host OS:

- boot: raw BIOS boot sector, Stage 2 loader, and 32-bit protected-mode entry
- CPU: interrupt tables, exceptions, syscalls, user/kernel transitions, and
  timer-driven preemption
- memory: paging, BIOS memory-map-driven physical page accounting, heaps,
  guard pages, and higher-half kernel page-table proof work
- programs: Ring 3 ELF launch for Doom and small probe programs
- files: ATA/IDE PIO, a block-device boundary, FAT16 reads/writes, config files,
  WAD loading, save-file persistence, readonly `/ASSETS`, and writable `/STATE`
  files through the same user file ABI, with live FAT allocation accounting
- input and video: keyboard, mouse, a reusable indexed framebuffer device,
  palette conversion, and frame presentation
- audio and runtime: SB16-style PCM contracts, x87/FPU handling, and the
  freestanding C/math/string support Doom expects

Doom is the first serious game target. The point is to make these OS services
general enough for other small C games and tools, not to hide one-off Doom
shortcuts behind a nice demo.

## How We Build It

This is being built like a small OS team, not a one-file stunt. The main agent
keeps `main` buildable and proofable. Subagents own broad slices such as boot,
memory, scheduling, FAT, input, graphics, audio, UEFI, and cloud proof; the
parent lane integrates them through host-only tests and disposable cloud boots.

The prompting strategy is deliberately strict:

- describe the hardware boundary, not just the desired screenshot
- define "done" with kernel status fields, tests, and cloud proof
- keep the original Doom tree pristine
- use Python for build/proof tooling, not as the place where OS behavior lives
- prefer general devices, syscalls, and file APIs over Doom-only shortcuts

## Claim Boundaries

The hardware claim is limited to QEMU BIOS/IDE/PS2/VBE/SB16. That evidence is
limited to the emulated device model. `docs/architecture.txt` has the full
support matrix.

UEFI exists as an opt-in proof path, not a claimed boot target yet. The boundary
lives in `boot/uefi/CONTRACT.txt`; `boot/uefi/build_host_artifacts.py` builds
host-only artifacts. `SUPPORT[UEFI] remains unclaimed` until cloud OVMF captures
the kernel-owned entry marker. PCI status fields such as `pci=`, `pciprobe=`,
`pciapi=`, `pcilookahci=`, `pcilookhda=`, `ahcibar=`, and `ahcireq=` are
diagnostics, not a broad hardware support claim.

ACPI table discovery, APIC/IOAPIC routing, and HPET timers are also unclaimed;
the live status still says `irqctl=PIC`, `apic=NONE`, and `hpet=NONE`.

The storage claim is also bounded. vibe-os mutates and reboots its generated
FAT16 image in disposable cloud QEMU, but it is not an installable OS for
arbitrary disks. It does not partition blank media, preserve unknown user data,
repair damaged media, or install itself onto a personal machine.

Generated IWAD-shaped fixtures are useful for public CI, but they do not count
as real Doom proof. Checked-in WAD files, disk images, raw audio, screenshots,
framebuffer dumps, and VM logs are forbidden.

## Build And Prove

These commands are host-only and safe:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= build-only
python3 -m unittest discover -s tests/host -p 'test_*.py'
make ALLOW_LOCAL_VM=0 cloud-playability-check
```

Cloud proofs run in GitHub Actions, Codespaces, or another disposable machine:

```sh
git fetch origin main
pushed_sha="$(git rev-parse origin/main^{commit})"
python3 tools/run_post_merge_cloud_proof.py --ref main --commit "$pushed_sha" --wait --download-dir build/post-merge-cloud-main
```

That post-merge command defaults to the full Real WAD lane: gameplay/input,
SB16/audible audio, save/load persistence, UEFI kernel-entry proof, and
status-only artifact checks.

## Disk Layout

The generated image is intentionally simple: LBA 0 is Stage 1 MBR plus an active
FAT16 partition table, LBA 1-16 is Stage 2, `LBA 17-336: protected-mode kernel ELF image`,
and LBA 2048+ holds Doom, probes, config, saves, and assets.

Core code lives in `boot/stage1.asm`, `boot/stage2.asm`, `boot/uefi/loader.asm`, `kernel/kernel.asm`, `user/crt0.asm`, and `doom_port/`; detailed contracts live in `docs/architecture.txt`, `docs/proof.txt`, `docs/play.txt`, `docs/doom-provenance.txt`, and `third_party/doom/ORIGIN.md`.
