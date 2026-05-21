# vibe-os

vibe-os is a Doom-focused hobby operating system. It boots a repo-owned x86
kernel, brings up the hardware/runtime surface Doom needs, and runs the
official id Software public release, `linuxdoom-1.10`, through our own platform
layer.

This is not Linux plus a Doom source port, and it is not a patched vendor Doom
tree. The rule is simple: keep the original Doom source pristine, keep WADs out
of git, and make the OS boundary real. The stance is "legit but playable
first": get to a real E1M1 play session fast, while tying every public claim to
proof.

## Where It Stands

`main` is a real OS bring-up path, not a launcher:

- BIOS boot sector and Stage 2 loader, no GRUB handoff.
- 32-bit protected-mode kernel with paging, IDT/PIC/PIT, TSS, and preemption
  proof fields.
- Ring 3 `int 0x80` user execution, with `USERPROB.ELF` launching the Doom
  process path instead of the kernel directly jumping into Doom.
- ATA PIO disk access, MBR parsing, FAT16 file reads, writable FAT updates, and
  `DEFAULT.CFG` / `DOOMSAV*.DSG` paths on the disk image.
- VBE/Mode 13h framebuffer paths, PS/2 keyboard/mouse input, SB16-oriented
  audio plumbing, and a freestanding C runtime.
- Original Doom source in `third_party/doom`; all OS-facing port code lives in
  `doom_port/`.

Gameplay is playable through the safe cloud path. On May 21, 2026, a manual
Codespaces/noVNC session on `main` booted vibe-os and reached interactive Doom;
keyboard controls worked well enough to play, though a 2-core Codespace slowed
down over time. The launcher now warns about that target, prints cleanup
commands, and keeps QEMU off the laptop.

The latest cloud proof is green for first-boot gameplay and audio. Gameplay run
`26202349037` reached E1M1 with real `DOOM1.WAD`, input, `doomrun=RUN`,
`gameplay=OK`, `panic=NONE`, `musicq=00000001:00000000`, and SB16 continuity
gates. Audio run `26202447113` also passed the audible-audio aggregate. That is
the current "you can boot and play Doom in the cloud" proof.

Save/load is the big remaining playability hole. The strongest persistence
evidence, run `26199297160`, wrote and reread `DOOMSAV0.DSG` at `25718` bytes,
then failed during reboot load inside original Doom with
`Unknown tclass 112 in savegame`; `savestm=` and `savethk=` diagnostics keep the
failure localized. Persistence/save-load should only be claimed after a green
cloud persistence run proves the save survives reboot and loads back into
gameplay.

Older scripted cloud evidence, including run `26165681561` and generated-WAD
run `26165678183`, is historical context for the proof system, including the
`playability-status-green` triage label, not a claim about the tip of `main`.
The commit-level trail lives in `docs/post-checkpoint-gaps.md` and
`docs/playable-cloud-proof.md` rather than here.

## How It Was Built

This project has been built as a long-running agentic engineering loop. The
main agent keeps the repo on `main`, owns integration, pushes only after local
host checks pass, and treats GitHub Actions/Codespaces as the hardware target
for risky VM execution. Subagents are kept busy on broad, separate slices:
boot/process legitimacy, FAT/save persistence, graphics/input, audio, libc/ABI,
cloud play UX, docs, and proof checkers.

The prompting strategy is deliberately repetitive and evidence-driven:

- Keep original `linuxdoom-1.10` source untouched; all platform work goes in
  `doom_port/`, the kernel, tools, tests, or docs.
- Prefer general OS subsystems over Doom-only shims, even while Doom is the
  first serious workload.
- Never run local QEMU on the Mac without explicit opt-in; use disposable cloud
  runners for real boot/play tests.
- For every claim, add a checker or status field that can fail when the claim
  stops being true.
- Delegate large non-overlapping work packages to subagents, then integrate
  only reviewed diffs back on `main`.
- Keep WADs, disk images, rendered pixels, and raw audio out of git and out of
  uploaded artifacts.

At the time this README was updated, the run had been active for more than a
day, with the worker pool cycled through multiple generations. That is part of
the method: lots of parallel subsystem pressure, but one integration lane and
hard proof gates so the project does not become a pile of stitched-together
shortcuts.

## Try It Safely

Use a disposable remote run on a cloud machine. Do not run local QEMU on this
Mac unless you explicitly opt in.

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
./tools/play_now_codespaces.sh --web-url --repo jadentripp/vibe-os --ref main
./tools/play_now_remote.sh
```

The Codespaces/noVNC path keeps QEMU, disk images, WAD data, framebuffer
captures, and raw audio off the laptop. A reviewed human playtest should be
captured with `tools/run_remote_human_playtest.sh --playtester NAME
--scripted-proof-run-id RUN_ID`, which wraps
`tools/collect_human_playtest_bundle.py`; the bundle should include
`human-playtest-notes-v2`, `human-playtest-checklist.txt`,
`human-playtest-session.json`, and `post-download human verification OK`.

## Build And Prove

Host-side checks are safe:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= build-only
python3 -m unittest discover -s tests/host -p 'test_*.py'
make ALLOW_LOCAL_VM=0 cloud-playability-check
```

Real-WAD proofs run in GitHub Actions or Codespaces:

```sh
gh workflow run os-smoke.yml --ref main -f expected_ref=main -f shutdown_panic_proof=false
gh workflow run real-wad-smoke.yml --ref main -f expected_ref=main -f audible_audio_proof=true -f persistence_proof=false
gh workflow run real-wad-soak.yml --ref main -f expected_ref=main -f attempts=3 -f min_passes=3 -f audible_audio_proof=true
python3 tools/run_cloud_playability.py --repo jadentripp/vibe-os --ref main \
  --lane persistence \
  --save-slot 0 \
  --wait \
  --download-artifacts build/cloud-run-persistence
```

## Claim Boundaries

Do not call vibe-os a finished Doom-capable OS until `main` has a green
real-WAD gameplay run, a green save/load persistence reboot run, and a reviewed
remote human noVNC session where keyboard and mouse actions visibly affect
gameplay.

Generated IWAD-shaped fixtures are useful for public CI, but they do not count
as a real Doom proof. Checked-in WAD files, disk images, framebuffer dumps, and
raw audio captures are forbidden.

The hardware claim is bounded to QEMU BIOS/IDE/PS2/VBE/SB16 for now: BIOS,
IDE/ATA, PS/2, VBE/Mode 13h, and SB16-style audio. This is not yet a general PC
compatibility claim, and this is not broad PC or physical hardware
compatibility. `boot/uefi/README.md` is a contract-only UEFI scaffold, and
SUPPORT[UEFI] remains unclaimed. PCI fields such as `pci=`, `pciprobe=`, and
`pcitabcap=` are diagnostics for the QEMU target; see
`docs/hardware-support.md`.

## Project Shape

The OS is intentionally Doom-first, but the subsystems are being built as
general OS surfaces instead of one-off Doom hooks: file descriptors and VFS,
generic input events, clock syscalls, framebuffer ioctls, audio device/ring
contracts, process launch, VM, FAT mutation, and a freestanding libc.

Disk layout: LBA 0 is Stage 1 MBR and partition table. LBA 1-16: Stage 2 bootloader. LBA 17-208: protected-mode kernel ELF image. LBA 2048+ is the FAT16
partition containing `DOOM1.WAD`, `USERPROB.ELF`, `DOOM.ELF`, writable
`DEFAULT.CFG`, and `DOOMSAV0.DSG` through `DOOMSAV5.DSG`.

## Deeper Docs

- `docs/playable-cloud-proof.md` explains the proof gates.
- `docs/post-checkpoint-gaps.md` is the detailed gap ledger.
- `docs/runbooks/play-now-cloud.md` covers Codespaces/noVNC testing.
- `docs/runbooks/remote-doom-playtest.md` covers reviewed human playtests.
- `docs/doom-provenance.md` documents source and WAD boundaries.
- `docs/persistent-fat16.md` covers save/load and FAT behavior.
- `docs/audio.md` covers SB16/SFX/music evidence.
- `docs/hardware-support.md` keeps hardware claims honest.
- `docs/boot-loader-vm.md` covers the BIOS boot, loader, and VM contract.
