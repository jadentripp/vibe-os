# vibe-os

vibe-os is a Doom-focused hobby operating system. It boots a repo-owned x86
kernel, brings up the hardware/runtime surface Doom needs, and runs the
original id Software `linuxdoom-1.10` engine through our own platform layer.

This is not Linux plus a Doom source port, and it is not a patched vendor Doom
tree. The rule is simple: keep the original Doom source pristine, keep WADs out
of git, and make the OS boundary real.

## Now

`main` contains the hard-mode architecture we have been building toward:

- BIOS boot sector and Stage 2 loader, no GRUB handoff.
- 32-bit protected-mode kernel with paging, IDT/PIC/PIT, TSS, and preemption
  proof fields.
- Ring 3 user execution through `int 0x80`, with `USERPROB.ELF` launching the
  Doom process path instead of the kernel directly jumping into Doom.
- ATA PIO disk access, MBR parsing, FAT16 file reads and writable FAT updates.
- VBE/Mode 13h framebuffer paths, PS/2 keyboard/mouse input, and SB16-oriented
  audio plumbing.
- Freestanding C runtime and separate `doom_port/*` platform code for the
  original Doom sources in `third_party/doom`.

The strongest older cloud proof reached real-WAD E1M1 on commit `ed4d00f`
in run `26199297160`: the OS booted, read shareware `DOOM1.WAD` through the
kernel ATA/FAT path, started Doom as a Ring 3 process, rendered frames, accepted
scripted keyboard/mouse input, and produced SB16 audio-continuity counters.
That run did not prove save/load; reboot load failed in original Doom with
`Unknown tclass 112 in savegame`.

The latest real-WAD truth-serum run for the newer subsystem checkpoint
`40d81cd` is red: run `26200478218` boots far enough to capture kernel status,
but reports `panic=KEXC`, `usr=FAIL`, `doom=FAIL`, and `gameplay=WAIT` before
Doom reaches gameplay. So the project is very close to playable again, but
`main` should not be advertised as playable until that regression is fixed and
the cloud proof is green.

## Can I Play It?

Not reliably on `main` as of the latest checked cloud proof. The safe path
exists, but the latest cloud run is red and needs to be fixed first.

When it is green, use a disposable cloud machine. Do not run local QEMU on this
Mac unless you explicitly opt in.

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
./tools/play_now_codespaces.sh --web-url --repo jadentripp/vibe-os --ref main
./tools/play_now_remote.sh
```

The Codespaces/noVNC path keeps QEMU, the disk image, WAD data, framebuffer
captures, and raw audio off the laptop.

## What Counts

The project can claim a milestone only when the cloud artifacts prove it:

- Real shareware `DOOM1.WAD` boots from the disk image.
- Doom reaches E1M1 on `main`.
- Keyboard and mouse input visibly change game state.
- `DOOMSAV*.DSG` survives reboot and loads back into gameplay.
- A remote human noVNC playtest confirms it is actually playable.

Generated IWAD-shaped fixtures are useful for public CI, but they do not count
as a real Doom proof. Checked-in WAD files, disk images, framebuffer dumps, and
raw audio captures are forbidden.

## Build And Test

Host-side checks are safe:

```sh
make ALLOW_LOCAL_VM=0 DOOM_WAD= build-only
python3 -m unittest discover -s tests/host -p 'test_*.py'
make ALLOW_LOCAL_VM=0 cloud-playability-check
```

Real-WAD proofs run in GitHub Actions or Codespaces:

```sh
python3 tools/run_cloud_playability.py --repo jadentripp/vibe-os --ref main \
  --lane persistence \
  --save-slot 0 \
  --wait \
  --download-artifacts build/cloud-run-persistence
```

## Project Shape

The OS is intentionally Doom-first, but the subsystems are being built as
general OS surfaces instead of one-off Doom hooks: file descriptors and VFS,
generic input events, clock syscalls, framebuffer ioctls, audio device/ring
contracts, process launch, VM, and FAT mutation.

The hardware claim is bounded to the cloud/QEMU target for now:
BIOS, IDE/ATA, PS/2, VBE/Mode 13h, and SB16-style audio. This is not yet a
general PC compatibility claim.

## Source And Assets

The Doom engine code lives under `third_party/doom` and should stay unmodified.
Port code lives under `doom_port/`. Real game assets come from a legitimate
`DOOM1.WAD` supplied outside the repo.

## Deeper Docs

- `docs/playable-cloud-proof.md` explains the proof gates.
- `docs/post-checkpoint-gaps.md` is the detailed gap ledger.
- `docs/doom-provenance.md` documents source and WAD boundaries.
- `docs/persistent-fat16.md` covers save/load and FAT behavior.
- `docs/audio.md` covers SB16/SFX/music evidence.
- `docs/runbooks/play-now-cloud.md` covers Codespaces/noVNC testing.
- `docs/hardware-support.md` keeps hardware claims honest.
