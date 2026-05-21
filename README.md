# vibe-os

vibe-os is a Doom-shaped hobby operating system. It does not install Linux and
launch a source port. It boots a repo-owned x86 OS, brings up the runtime Doom
needs, and runs the official id Software public release across that boundary.

The project stance is **"legit but playable first"**: get a real person into
E1M1 quickly, while keeping the claims tight. No patched vendor Doom tree, no
checked-in WADs, no GRUB handoff, no hidden Linux runtime, and no proof that
depends on this Mac.

## Where It Stands

vibe-os boots on disposable cloud hardware and reaches real-WAD Doom gameplay.
The latest cloud truth-serum run, `26199297160` on commit `ed4d00f`, booted the
raw x86 disk image, loaded the kernel through the repo BIOS bootloader, read
shareware `DOOM1.WAD` through the kernel ATA/FAT16 path, started `DOOM.ELF` as a
Ring 3 process, presented frames, accepted scripted keyboard/mouse input, and
passed VM/process, gameplay, SB16 audio-continuity, and artifact-hygiene gates.

The live blocker is save/load: the run writes and rereads a full
`DOOMSAV0.DSG` payload of `25718` bytes, then rebooted load exits inside
original Doom with `Unknown tclass 112 in savegame`. `savestm=` and `savethk=`
show the thinker boundary agrees at `0x2A64`, so the remaining failure is around
the specials stream, not the old short-write FAT bug.

Persistence/save-load should only be claimed after a green cloud persistence
run proves the save survives reboot and loads back into gameplay. A public "you
can play Doom on vibe-os" claim also needs a reviewed remote human VNC playtest.

Older scripted cloud evidence is useful context, not a claim about `main`: run
`26165681561` on commit `c525952` reached `doomrun=RUN`, entered E1M1, and
triaged as `playability-status-green`; generated-WAD run `26165678183` matched
that boot path.

## Try It In The Cloud

The safe interactive path is a disposable remote run in GitHub Codespaces. QEMU
and noVNC run on a cloud computer, not on the laptop.

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
./tools/play_now_codespaces.sh --web-url --repo jadentripp/vibe-os --ref main
./tools/play_now_remote.sh
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/main/tools/play_now_cloud_shell.sh \
  | VIBE_REF=main bash
```

The browser VNC session carries video and input. Browser audio is not the
interactive path yet; audio proof comes from SB16 status counters and cloud
aggregate metadata.

## What The OS Owns

| Area | Implemented boundary |
| --- | --- |
| Boot | 512-byte BIOS MBR Stage 1, raw-sector Stage 2, A20/GDT/protected-mode switch, ELF32 kernel load |
| CPU | 32-bit protected mode, flat GDT, IDT/PIC/PIT, TSS, timer IRQ preemption proof |
| Memory | Paging, physical frame accounting, kernel heap, user VM regions |
| User mode | Ring 3 processes, `int 0x80`, table-backed exec handoff for probe/Doom |
| Storage | ATA PIO, MBR partition parsing, FAT16 root files, dynamic allocation/free/truncate |
| Graphics | VBE 32-bpp framebuffer when available, Mode 13h fallback, Doom 320x200 present path |
| Input | PS/2 keyboard and mouse translated into generic OS input events and Doom events |
| Audio | SB16 playback path, Doom SFX/music counters, aggregate cloud audio proof path |
| Doom | Unmodified `third_party/doom` engine objects plus separate `doom_port/*` platform code |
| Safety | Local QEMU opt-in, cloud diagnostics only, WAD/disk/pixel/raw-audio artifacts excluded |

## Build And Proof

Local build/test is fine. Local VM execution is opt-in:

```sh
brew install nasm qemu
make
make test
make playability-host-check
git diff --check
make clean
make DOOM_WAD=/absolute/path/to/DOOM1.WAD
make ALLOW_LOCAL_VM=1 run
make ALLOW_LOCAL_VM=1 smoke
```

The default image uses a generated IWAD-shaped fixture so public tests can cover
the boot/storage path without shipping game data. Real `DOOM1.WAD` files stay
outside git.

Cloud proofs use explicit ref guards:

```sh
branch=$(git branch --show-current)
gh workflow run os-smoke.yml --ref "$branch" -f expected_ref="$branch" -f shutdown_panic_proof=false
gh workflow run real-wad-smoke.yml --ref "$branch" -f expected_ref="$branch" -f audible_audio_proof=true -f persistence_proof=false
gh workflow run real-wad-soak.yml --ref "$branch" -f expected_ref="$branch" -f attempts=3 -f min_passes=3 -f audible_audio_proof=true
```

The preferred dispatcher can wait, download allowed status artifacts, and check them:

```sh
python3 tools/run_cloud_playability.py --ref "$branch" --lane persistence \
  --save-slot 0 \
  --wait \
  --download-artifacts build/cloud-run-persistence
```

## Claim Boundaries

The hardware claim is bounded to QEMU BIOS/IDE/PS2/VBE/SB16. This is not broad
PC or physical hardware support. See `docs/hardware-support.md`;
`boot/uefi/README.md` is only a contract scaffold, and SUPPORT[UEFI] remains
unclaimed. Status fields such as `pci=`, `pciprobe=`, `pcicount=`, `pcifirst=`,
`pciid=`, and `pciclass=` are diagnostics, not a PCI support claim.

Do not call vibe-os a finished Doom-capable OS until `main` has a green
real-WAD gameplay run, a green save/load persistence reboot run, and a recorded
remote human VNC session where keyboard and mouse actions visibly affect
gameplay.

The human proof runbook is `docs/runbooks/remote-doom-playtest.md`. The guided
helper is `tools/run_remote_human_playtest.sh --playtester NAME
--scripted-proof-run-id RUN_ID`; the lower-level collector is
`tools/collect_human_playtest_bundle.py`. A reviewed bundle records
`human-playtest-notes-v2`, `human-playtest-checklist.txt`,
`human-playtest-session.json`, and `human-playtest-manifest.json`; compare the
helper's `pre-download human verification OK` with the local
`post-download human verification OK` before treating it as evidence.

## Disk Layout

LBA 0 is Stage 1 MBR and partition table. LBA 1-16 is Stage 2. LBA 17-208 is
the protected-mode kernel ELF. LBA 2048+ is the FAT16 partition containing
`DOOM1.WAD`, `USERPROB.ELF`, `DOOM.ELF`, writable `DEFAULT.CFG`, and
`DOOMSAV0.DSG` through `DOOMSAV5.DSG`.

## Deeper Docs

Start with `docs/playable-cloud-proof.md` for proof rules,
`docs/post-checkpoint-gaps.md` for the honest gap ledger,
`docs/doom-provenance.md` for source/assets, `docs/persistent-fat16.md` for
save/load, `docs/audio.md` for SB16/SFX/music, `docs/runbooks/play-now-cloud.md`
for Codespaces/noVNC, and `docs/boot-loader-vm.md` for the BIOS boot path.
