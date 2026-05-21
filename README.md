# vibe-os

vibe-os is a Doom-shaped hobby operating system. The point is not to build a
tiny Linux clone, and it is definitely not to install Linux and launch a source
port. The point is sharper than that:

> boot a repo-owned x86 OS, bring up the hardware-facing runtime it needs, and
> run the original public Doom engine on top of that boundary.

The project stance is **"legit but playable first"**. Playable matters because
the OS should get a real person into E1M1 as soon as possible. Legit matters
because the impressive part disappears if the project quietly leans on Linux,
GRUB modules, patched Doom sources, checked-in WADs, or local proof artifacts
that nobody can audit.

## Current State

You can boot vibe-os in a disposable cloud VM and reach real-WAD Doom gameplay.
The current remote path builds a raw x86 disk image, boots the repo's BIOS boot
chain, starts the kernel, reads the shareware `DOOM1.WAD` through the kernel
ATA/FAT16 path, runs `DOOM.ELF` as a Ring 3 process, presents frames, accepts
keyboard and mouse input, and exercises SB16 audio status paths.

That is a real milestone, but it is not the final claim.

Current-head cloud proof state: save persistence is not green yet. The previous
persistence blocker truncated `DOOMSAV0.DSG` to 1024 bytes after the first
write; current cloud artifacts after commit `4a8bad7` show the save write now
reaches 25718 bytes, but reboot/load still exits with
`Unknown tclass 112 in savegame`.
Persistence/save-load should only be claimed after a matching green current-head
cloud persistence run proves the save survives reboot and loads back into
gameplay.

The best archived scripted cloud evidence remains useful context: run
`26165681561` on kernel/runtime commit `c525952` reached `doomrun=RUN`, entered
E1M1, passed the real-WAD, scripted input, mouse, SB16/audio-continuity, and
artifact-hygiene gates, and triaged as `playability-status-green`. The matching
generated-WAD `os-smoke` run was `26165678183`. That is scripted cloud
evidence for that commit, not a blank check for every future commit.

## Play It Safely

Do not use local Mac QEMU for the quick path. The play path is intentionally a
disposable remote run so the laptop stays out of the blast radius.

The shortest route from this checkout is GitHub Codespaces:

```sh
./tools/play_now_codespaces.sh
```

To force the public repo and pushed `main` branch:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

If your `gh` login cannot create Codespaces from the CLI, use the browser-only
fallback:

```sh
./tools/play_now_codespaces.sh --web-url \
  --repo jadentripp/vibe-os \
  --ref main
```

The Codespace path creates or reuses a disposable Codespace, starts the remote
QEMU/noVNC session there, marks the noVNC port private, and avoids copying WADs,
disk images, framebuffer captures, or raw audio onto the Mac. If you are already
inside a disposable Ubuntu host or Codespace, run:

```sh
./tools/play_now_remote.sh
```

For a fresh remote shell without local `gh` involvement:

```sh
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/main/tools/play_now_cloud_shell.sh \
  | VIBE_REF=main bash
```

The browser VNC session carries video and input. It does not carry browser audio
today; audio proof comes from the cloud real-WAD workflow's aggregate audio
metadata and SB16 status counters.

## What Makes It Real

vibe-os owns the boot and OS boundary. The disk starts with `boot/stage1.asm`, a
512-byte MBR sector. Stage 1 loads `boot/stage2.asm` from raw LBAs with BIOS EDD
`INT 0x13`. Stage 2 enables A20, installs a GDT, switches to 32-bit protected
mode, parses ELF32 program headers, and jumps into the kernel.

The kernel then handles the narrow runtime Doom needs: GDT/IDT/PIC/PIT, paging,
a TSS, physical frame accounting, heap allocation, serial and VGA diagnostics,
VBE or Mode 13h presentation, PS/2 keyboard and mouse, ATA PIO, MBR partition
parsing, FAT16 directories and cluster chains, a syscall gate, Ring 3 processes,
and a small libc/POSIX-ish surface.

The Doom side is equally deliberate. The engine source is the official id
Software public release, imported under `third_party/doom` and treated as a
pristine vendor tree. The build compiles the unmodified `linuxdoom-1.10` engine
objects plus separate `doom_port/*` platform, input, audio, and libc shims.
Game data stays out of git; a real run supplies a lawful `DOOM1.WAD` at build or
cloud-run time.

The current hardware claim is bounded to the QEMU BIOS/IDE/PS2/VBE/SB16 target.
This is not broad PC or physical hardware compatibility. `docs/hardware-support.md`
is the support matrix, `boot/uefi/README.md` is only a contract scaffold, and
SUPPORT[UEFI] remains unclaimed. The kernel emits status-only PCI diagnostics
such as `pci=`, `pciprobe=`, `pcicount=`, `pcifirst=`, `pciid=`, and
`pciclass=`, but that is not a PCI driver claim.

## System Shape

| Area | What vibe-os currently owns |
| --- | --- |
| Boot | BIOS MBR Stage 1, raw-sector Stage 2, ELF32 kernel loader |
| CPU | 32-bit protected mode, flat GDT, IDT/PIC/PIT, TSS |
| Memory | Paging, first 32 MiB frame accounting, kernel heap, user VM regions |
| User mode | Ring 3 probe and Doom process, `int 0x80`, table-backed exec handoff |
| Storage | ATA PIO, MBR, FAT16 root files, dynamic allocation/free/truncate |
| Doom | Original `linuxdoom-1.10` engine files plus isolated `doom_port/*` shims |
| Graphics | VBE 32-bpp LFB when available, Mode 13h fallback, Doom 320x200 present path |
| Input | PS/2 keyboard and mouse translated into Doom events |
| Audio | SB16 playback path, Doom SFX/music counters, aggregate cloud audio proof |
| Safety | Local QEMU opt-in, cloud diagnostics only, WAD/disk/pixel/audio artifacts excluded |

The diagnostic shell still exists for bring-up work: `help`, `about`, `clear`,
`echo`, `mem`, `mode`, `ticks`, `heap`, `paging`, `libc`, `c`, `user`, `wad`,
`reboot`, `halt`, and `poweroff`.

## Build And Test

Local builds do not need to launch a VM. On macOS, install the basic tools:

```sh
brew install nasm qemu
```

Apple's Xcode Command Line Tools `clang` is enough for the freestanding build.

Build the default public image:

```sh
make
```

The default image uses a generated IWAD-shaped fixture so public CI can exercise
the storage path without shipping game data. To build with a real shareware WAD,
keep it outside git:

```sh
make clean
make DOOM_WAD=/absolute/path/to/DOOM1.WAD
```

Run the host-side safety and proof contracts without local QEMU:

```sh
make test
make playability-host-check
make cloud-playability-check
git diff --check
```

Local VM targets are deliberately opt-in:

```sh
make ALLOW_LOCAL_VM=1 run
make ALLOW_LOCAL_VM=1 smoke
```

The VM safety contract itself is checked without launching QEMU:

```sh
make vm-safety-check
```

## Cloud Proof

After a push, dispatch cloud proofs against an explicit branch/ref guard:

```sh
branch=$(git branch --show-current)
gh workflow run os-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f shutdown_panic_proof=false

gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=true \
  -f persistence_proof=false

gh workflow run real-wad-soak.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f attempts=3 \
  -f min_passes=3 \
  -f audible_audio_proof=true
```

For the persistence truth serum, use the dispatcher:

```sh
python3 tools/run_cloud_playability.py --ref "$branch" --lane persistence \
  --save-slot 0 \
  --wait \
  --download-artifacts build/cloud-run-persistence
```

The detailed proof contract lives in `docs/playable-cloud-proof.md`; the gap
ledger lives in `docs/post-checkpoint-gaps.md`. Those docs are intentionally
more exacting than this README.

For a human proof session, use `docs/runbooks/remote-doom-playtest.md`. The
guided helper is `tools/run_remote_human_playtest.sh --playtester NAME
--scripted-proof-run-id RUN_ID`, and the lower-level collector is
`tools/collect_human_playtest_bundle.py`. A reviewed human bundle includes
`human-playtest-notes-v2`, `human-playtest-checklist.txt`,
`human-playtest-session.json`, and `human-playtest-manifest.json`; compare the
helper's `pre-download human verification OK` line with the local
`post-download human verification OK` line before treating the session as
evidence.

## Disk Image Layout

- LBA 0: Stage 1 MBR and partition table
- LBA 1-16: Stage 2 bootloader
- LBA 17-208: protected-mode kernel ELF image
- LBA 2048+: FAT16 partition containing `DOOM1.WAD`, `USERPROB.ELF`, and
  `DOOM.ELF`, plus writable `DEFAULT.CFG` and `DOOMSAV0.DSG` through
  `DOOMSAV5.DSG` root entries

## What Is Still Not Proven

Do not call vibe-os a finished Doom-capable OS until the current branch has a
green real-WAD cloud run for gameplay, a green save/load persistence reboot run,
and a recorded remote human VNC session where keyboard and mouse actions
visibly affect gameplay.

There are also deeper hard-mode gaps beyond immediate playability: richer
VM/POSIX semantics, less fixed-slot process machinery, higher-half/non-identity
cleanup, broader framebuffer policy, fuller music/audio behavior, and hardware
classes beyond the current QEMU target. UEFI, PCI enumeration, AHCI, USB, SMP,
APIC, HPET, and physical hardware only become claims after the support matrix
and its checker say they are proved.

## Docs Map

- `docs/doom-provenance.md`: original Doom source integrity and asset boundary.
- `docs/doom-libc-runtime.md`: libc and syscall runtime expectations.
- `docs/boot-loader-vm.md`: raw-sector boot, ELF handoff, paging, and VM gaps.
- `docs/process-vm.md`: process address spaces and user/kernel mappings.
- `docs/process-exec.md`: exec handoff, argv stack, and scheduler handoff.
- `docs/persistent-fat16.md`: dynamic FAT16 persistence contract.
- `docs/graphics.md`: framebuffer and scaler behavior.
- `docs/audio.md`: SB16, Doom SFX, and music runtime notes.
- `docs/mouse-input.md`: PS/2 mouse input contract.
- `docs/playable-cloud-proof.md`: scripted cloud proof contract.
- `docs/runbooks/play-now-cloud.md`: shortest remote play path.
- `docs/runbooks/codespaces-play-now.md`: Codespaces launcher details.
- `docs/runbooks/cloud-interactive-playtest.md`: fuller remote noVNC/SPICE flow.
- `docs/runbooks/remote-doom-playtest.md`: human proof collection.
- `docs/hardware-support.md`: bounded hardware support matrix.
- `boot/uefi/README.md`: contract-only UEFI scaffold.
