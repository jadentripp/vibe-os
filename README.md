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
keyboard controls worked well enough to play, though the session slowed down
over time on a 2-core Codespace. The launcher now warns about that target and
prints cleanup commands for the disposable Codespace.

Cloud run `26201062911` on commit `121185c` reached real-WAD gameplay with
`panic=NONE`, `usr=OK`, `doom=OK`, `doomrun=RUN`, and `gameplay=OK`. A newer
persistence-lane run `26201081378` on commit `53eef0f` also reached E1M1 and
triaged as `playability-status-green`, but the workflow still failed later, so
save/load is not green.

The latest gameplay-lane cloud run, `26202349037` on commit `bc97cc3`, is green:
it reached E1M1 with real `DOOM1.WAD`, input, `doomrun=RUN`, `gameplay=OK`,
`panic=NONE`, `musicq=00000001:00000000`, and SB16 continuity gates. Audio-lane
run `26202447113` on the same commit also passed the audible-audio aggregate.
These followed failed run `26201835975` on commit `1450b73`, which exposed a real
port bug: the MUS parser accepted the synthetic fixture's old end marker but
rejected the real Doom MUS end event. The parser now handles the real event and
cloud gameplay/audio proofs are back to green. The reboot save/load proof
remains a separate gate.

The strongest older cloud proof reached real-WAD E1M1 on commit `ed4d00f` in
run `26199297160`: the OS booted, read shareware `DOOM1.WAD` through the kernel
ATA/FAT path, started Doom as a Ring 3 process, rendered frames, accepted
scripted keyboard/mouse input, and produced SB16 audio-continuity counters. That
run did not prove save/load; reboot load failed in original Doom with
`Unknown tclass 112 in savegame`.

Older scripted cloud evidence is still useful context, not a claim about the
tip of `main`: run `26165681561` on commit `c525952` reached `doomrun=RUN`,
entered E1M1, and triaged as `playability-status-green`; generated-WAD run
`26165678183` matched that boot path. The strongest save-write proof wrote and
reread `DOOMSAV0.DSG` at `25718` bytes before reboot load failed, with
`savestm=` and `savethk=` diagnostics. Persistence/save-load should only be
claimed after a green cloud persistence run proves the save survives reboot and
loads back into gameplay.

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
