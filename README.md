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

## Where It Stands

You can play Doom through Codespaces/noVNC on a disposable cloud machine. That
keeps QEMU and the bootable disk image away from the laptop.

The cloud proof is green for first-boot gameplay with real `DOOM1.WAD`: Doom
boots as `DOOM.ELF`, runs as a Ring 3 process, reads the WAD through the
ATA/FAT path, accepts scripted keyboard and mouse input, renders frames, and
feeds the SB16 PCM path.

Ring 3 is the CPU's normal user-program privilege level. Here it means Doom
crosses a syscall boundary like another small C program would.

Save/config persistence is green in the cloud too. The proof lane writes
`DEFAULT.CFG`, creates a real Doom save in `DOOMSAV*.DSG`, reboots the same
mutated FAT image, reads the save back, and returns to gameplay. A small C
FAT-image checker verifies the files and guest status instead of relying on a
host script to guess what happened.

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
3. The bootloader reads `KERNEL.ELF` from the FAT16 partition, validates its
   cluster chain, then switches the CPU from early BIOS mode into 32-bit
   protected mode, where programs can use more memory and the CPU can enforce
   privilege levels.
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

- boot: raw BIOS boot sector, Stage 2 loader, FAT16 kernel-file loading with
  chain validation, and 32-bit protected-mode entry
- CPU: interrupt tables, exceptions, syscalls, user/kernel transitions, and
  timer-driven preemption
- memory: paging, BIOS memory-map-driven physical page accounting, heaps,
  guard pages, and higher-half kernel page-table proof work
- programs: Ring 3 ELF launch for Doom and small probe programs
- files: ATA/IDE PIO, a block-device boundary, FAT16 reads/writes, config files,
  WAD loading, save-file write/read plumbing, readonly `/ASSETS`, and writable
  `/STATE` files through the same user file ABI, with live FAT allocation
  accounting; the guest now reports a generic VFS ABI mask proving open, read,
  write, seek, stat, directory listing, truncate, unlink, and close paths ran
  outside Doom
- input and video: keyboard, mouse, a reusable input event queue, a reusable
  indexed framebuffer device, palette conversion, and frame presentation; the
  OVMF cloud proof now exercises non-Doom Ring 3 input and framebuffer
  lifecycles through the generic device ABIs
- audio and runtime: SB16-style PCM contracts, x87/FPU handling, and the
  freestanding C/math/string support Doom expects; the OVMF cloud proof now
  exercises a non-Doom Ring 3 PCM lifecycle through the generic audio ABI

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
- add no new host scripting stack; the checked-in proof/build path is C, shell,
  Make, and guest status, with Python treated as debt rather than infrastructure
- keep the OS itself assembly-first; C is for original Doom, small runtime glue,
  and the smallest practical host tools, not a substitute for kernel work
- prefer general devices, syscalls, and file APIs over Doom-only shortcuts

## Claim Boundaries

QEMU BIOS/IDE/PS2/VBE/SB16 is the supported target for playable Doom. That
evidence is limited to the emulated device model. `docs/architecture.txt` has
the full support matrix.

UEFI is an opt-in source-level boot path, documented in
`boot/uefi/CONTRACT.txt`. The loader has a bounded 64-bit-to-32-bit handoff
path. The cloud workflow builds a real `BOOTX64.EFI`, packages it into the same
kind of FAT16 disk image the kernel can read, and boots that image under
disposable OVMF. The latest green prove run captured the kernel-owned
`VIBEKERN step=uefi-entry status=OK` marker on `main`, proved ATA, MBR
partition selection, WAD loading, Ring 3 ABI exec, and launched `DOOM.ELF` with
`doom=OK`, `doomrun=EXIT`, and `panic=NONE`. It also exposes an SB16 device and
requires the generic audio ABI to open, write, query, drain, and close a PCM
stream outside Doom. It also requires the generic input ABI to poll the event
queue and query aggregate, keyboard, and mouse status outside Doom, and requires
the generic framebuffer ABI to query the device, present pixels, mark the
surface dirty, and do that through the ioctl path outside Doom. That proves the
UEFI loader reaches the same kernel storage, process, input, video, and
audio-device paths far enough to exec Doom and exercise separate non-Doom
clients. Interactive play remains proven on the BIOS/IDE noVNC
target, not UEFI, and UEFI does not claim physical PC support yet.
PCI fields such as `pci=`, `pciprobe=`, `pciapi=`, `pcilookahci=`,
`pcilookhda=`, `ahcibar=`, and `ahcireq=` are diagnostics, not a broad hardware
support claim.

ACPI table discovery now runs in guest assembly: the kernel scans firmware
memory for the RSDP, identity-maps ACPI table pages on demand, validates
checksums, records RSDT/XSDT pointers, and parses MADT/HPET hardware inventory:
LAPICs, IOAPICs, interrupt source overrides, and HPET block metadata. It also
probes CPUID and reads the CPU's APIC-base MSR when the processor advertises
MSR/APIC support. The kernel maps the advertised LAPIC, IOAPIC, and HPET MMIO
pages and reads identity and capability registers as a hardware probe. The
IOAPIC probe reads redirection entries, including the first interrupt-source
override, so future routing work can use the actual table shape. The HPET probe
also verifies that the main counter advances, and the status path refreshes a
live HPET counter sample after boot. Kernel MMIO pages are copied into every
process page directory as supervisor-only mappings, so Ring 0 interrupt code
can reach device registers even when it interrupted a Ring 3 process. IRQ
handlers send end-of-interrupt through a shared assembly EOI helper and publish
`irqeoi=`. The guest builds an `irqplan=`/`irqgsi=` route plan from MADT
interrupt-source overrides for the timer, keyboard, audio, mouse, and primary
IDE IRQs. It then computes IOAPIC redirection entries in `ioapicplan=`,
`ioapicidx=`, `ioapiclo=`, and `ioapichi=`.

The supported QEMU path now attempts LAPIC/IOAPIC routing by default. The
kernel software-enables the LAPIC through `lapiclive=`, arms the IOAPIC routes,
masks the legacy PIC when the handoff succeeds, sends device EOIs through the
LAPIC, and reports `irqctl=APIC`, `apic=LIVE`, and `apicirq=` from inside the
guest. The monotonic millisecond clock also switches from PIT accounting to the
HPET main counter after the HPET probe succeeds, reported as `clocksrc=HPET`,
`hpet=LIVE`, and `clockhpet=`. If the firmware/device checks fail, it stays on
the older PIC/PIT path instead of pretending APIC or HPET are available.
`VIBE_DISABLE_APIC_IRQ` is the build escape hatch for an explicit PIC-fallback
proof.

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
make ALLOW_LOCAL_VM=0 DOOM_WAD= image-builder-tool
make ALLOW_LOCAL_VM=0 DOOM_WAD= test
make ALLOW_LOCAL_VM=0 DOOM_WAD= playability-host-check
```

The critical build path uses small C tools for ELF linking, disk-image creation,
and status validation; OS substance should keep moving into assembly and
guest-visible kernel behavior.
Cloud proofs run in GitHub Actions, Codespaces, or another disposable machine:

```sh
gh workflow run os-smoke.yml --ref main -f expected_ref=main
gh workflow run real-wad-smoke.yml --ref main -f expected_ref=main
gh workflow run real-wad-smoke.yml --ref main -f persistence_save_slot=0 -f audible_audio_proof=false -f expected_ref=main
gh workflow run uefi-ovmf-proof.yml --ref main -f proof_mode=prove -f expected_ref=main
```

Those workflows exercise the boot smoke, the Real WAD gameplay lane, and the
isolated save/load persistence lane in the cloud. Local QEMU stays opt-in only.

## Disk Layout

The generated image is intentionally simple: LBA 0 is Stage 1 MBR plus an active
FAT16 partition table, LBA 1-16 is Stage 2, `LBA 17-336` keeps a raw kernel ELF
fallback, and LBA 2048+ holds the FAT16 filesystem. Stage 2 now prefers the
`KERNEL.ELF` file from that FAT16 root, bounds-checks its data clusters, requires
an end-of-chain marker, and only then falls back to the raw window if the FAT
path fails. Doom, probes, config, saves, and assets also live in the FAT16
partition.

Core code lives in `boot/stage1.asm`, `boot/stage2.asm`, `boot/uefi/loader.asm`, `kernel/kernel.asm`, `user/crt0.asm`, and `doom_port/`; detailed contracts live in `docs/architecture.txt`, `docs/proof.txt`, `docs/play.txt`, `docs/doom-provenance.txt`, and `third_party/doom/ORIGIN.md`.
