# vibe-os

vibe-os is a small x86 hobby operating system built to answer one concrete
question: can this repo boot its own kernel, load the original Doom engine, and
make Doom playable without hiding behind Linux, GRUB, a wrapper source port, or
a RAM-disk shortcut?

The project stance is **"legit but playable first"**. The fastest path should
get a real person into Doom through a disposable remote run, while the technical
boundary stays honest: original Doom source stays vendor-clean, game data stays
out of git, and the OS owns the boot/runtime path.

## Can You Play It?

Mostly yes, but with an important caveat.

The current remote path boots vibe-os in cloud QEMU, loads a validated
shareware `DOOM1.WAD` from the FAT16 disk image through the kernel's ATA/FAT
path, starts the original `linuxdoom-1.10` engine as `DOOM.ELF`, reaches E1M1,
accepts keyboard and mouse input, presents frames, and exercises SB16 audio
counters. The latest published serious proof triages as
`playability-status-green`.

The part that is still being treated as unfinished is save/load persistence.
`DEFAULT.CFG` and dynamic FAT mutation have host and image-level coverage, but
a current green cloud reboot proof for `DOOMSAV0.DSG` is still the gate before
we claim "playable Doom OS with persistent saves."

Do not run local Mac QEMU for the quick path. Use a disposable remote host,
GitHub Codespaces, or GitHub Actions. That keeps the laptop out of the blast
radius.

## Fastest safe path

From this checkout, the one-command interactive path is:

```sh
./tools/play_now_codespaces.sh
```

If the local checkout is dirty or you want the pushed `main` branch explicitly:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

If GitHub CLI does not have Codespaces API scope, ask it for the browser-only
creation URL:

```sh
./tools/play_now_codespaces.sh --web-url \
  --repo jadentripp/vibe-os \
  --ref main
```

The Codespace path creates or reuses a disposable GitHub Codespace, starts the
vibe-os QEMU session there, marks noVNC private, and opens or prints the
browser URL. QEMU, the downloaded WAD, disk images, framebuffer captures, and
raw audio stay remote.

If you are already inside a disposable Ubuntu host or Codespace, run:

```sh
./tools/play_now_remote.sh
```

For a fresh remote shell with no local `gh` involvement:

```sh
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/main/tools/play_now_cloud_shell.sh \
  | VIBE_REF=main bash
```

The VNC display is for graphics and input. VNC does not carry game audio; audio
proof currently comes from the cloud `real-wad-smoke.yml` aggregate audio proof
and SB16 status counters, not from your browser speakers.

## What Is Real Here

This is not Linux plus Chocolate Doom. It is also not a GRUB Multiboot kernel
with `DOOM1.WAD` handed in as a boot module.

The boot chain starts with `boot/stage1.asm`, a 512-byte MBR sector. Stage 1
loads `boot/stage2.asm` from raw LBAs with BIOS EDD `INT 0x13`. Stage 2 enables
A20, installs a GDT, switches to 32-bit protected mode, parses the kernel's
ELF32 program headers, and jumps to the kernel entry point.

The kernel then owns the OS work: GDT/IDT/PIC/PIT, paging, a TSS, physical frame
accounting, heap allocation, serial/VGA diagnostics, PS/2 keyboard and mouse
input, VBE/Mode 13h presentation, ATA PIO, MBR partition parsing, FAT16
directories and cluster chains, a syscall gate, Ring 3 user processes, and a
small libc/runtime surface.

Doom source legitimacy is pinned to the official id Software public release.
`third_party/doom/ORIGIN.md` records the upstream repository and commit.
`third_party/doom` is treated as read-only vendor code; the build compiles the
unmodified original engine objects plus isolated `doom_port/*` platform and
libc shims. Host checks reject vendor-tree edits, wrapper engines, tracked WADs,
disk images, rendered pixel artifacts, logs, and shortcut source-port paths.

The current implementation is proven for the QEMU BIOS/IDE/PS2/VBE/SB16
target, not broad PC or physical hardware compatibility. `docs/hardware-support.md`
is the support matrix. It separates claimed QEMU device classes from unclaimed
UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and physical-hardware
support. `boot/uefi/README.md` is only a contract scaffold today;
SUPPORT[UEFI] remains unclaimed. The kernel emits status-only PCI diagnostics
such as `pci=`, `pciprobe=`, `pcicount=`, `pcifirst=`, `pciid=`, and
`pciclass=`, but those are not a PCI driver claim.

## Current Proof Status

Last published proof baseline: run `26165681561` on kernel/runtime commit
`c525952` is the latest archived scripted cloud proof that passes the serious
real-WAD gates. It reaches `doomrun=RUN`, `doomopen=OK`, `doomread=OK`,
`gameplay=OK`, `usr=OK`, live keyboard/mouse/SB16/preemption counters, the
scripted gameplay transition proof, and the aggregate audible-audio proof. The
matching `os-smoke` run `26165678183` also passes the generated-WAD smoke for
the same kernel/runtime commit, and the real-WAD run triages as
`playability-status-green`.

That is strong scripted cloud evidence, not by itself a claim that the current
branch is human-playable forever. Any kernel, runtime, workflow, or proof-checker
change must rerun the relevant gates.

Persistence/save-load should only be claimed for a matching green current-head
cloud persistence run. The older `26156172979` / `eabd307` save-slot reboot
proof is historical evidence for that older runtime, not the current proof
point. Current-head save proof must include both the reboot comparison and the
first boot's `--save-write-status` runtime gate.

Current-head cloud proof state: pending for this branch until the pushed commit
passes the cloud gates below. Before push, keep the host-only readiness gate
green:

```sh
make cloud-playability-check
git diff --check
```

After push, prove the selected branch/ref explicitly:

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

gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=true \
  -f persistence_save_slot=0
```

For repeated proof:

```sh
branch=$(git branch --show-current)
gh workflow run real-wad-soak.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f attempts=3 \
  -f min_passes=3 \
  -f audible_audio_proof=true
```

For a human proof session, use `docs/runbooks/remote-doom-playtest.md`. It keeps
QEMU remote, collects only allowlisted diagnostics, ties the manual run to a
passing scripted real-WAD run, and validates the bundle with
`tools/check_cloud_playability_artifacts.py --human-session`. The guided wrapper
is:

```sh
./tools/run_remote_human_playtest.sh \
  --playtester jt \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"
```

The lower-level collector is `tools/collect_human_playtest_bundle.py`. The proof
bundle includes `human-playtest-notes-v2`, `human-playtest-checklist.txt`,
`human-playtest-session.json`, and `human-playtest-manifest.json`; compare the
collector's `pre-download human verification OK` line with the local
`post-download human verification OK` line before treating it as evidence.

## Build And Test

Required local tools:

- `nasm`
- `clang`
- `make`
- `qemu-system-x86_64` only for explicit opt-in local VM targets

On macOS:

```sh
brew install nasm qemu
```

Apple's Xcode Command Line Tools `clang` is enough for the freestanding build.

Build the default public image:

```sh
make
```

The default image uses a generated IWAD-shaped fixture so public CI can test the
storage path without game data. To build with a real shareware WAD, keep it
outside git:

```sh
make clean
make DOOM_WAD=/absolute/path/to/DOOM1.WAD
```

Run host-side tests without launching QEMU:

```sh
make test
make playability-host-check
```

Local VM targets are deliberately opt-in:

```sh
make ALLOW_LOCAL_VM=1 run
make ALLOW_LOCAL_VM=1 smoke
```

The VM safety contract is checked without launching QEMU:

```sh
make vm-safety-check
```

The shutdown/panic slice is also cloud-oriented. The `os-smoke.yml` workflow has
an opt-in `shutdown_panic_proof` mode that emits `shutdown-panic-proof.json`,
`status.panic.txt`, `status.shutdown-halt.txt`, `status.shutdown-reboot.txt`,
and `status.shutdown-poweroff.txt`. Validate a downloaded artifact with:

```sh
python3 tools/check_shutdown_panic_proof.py /path/to/artifact
```

## Disk Image Layout

- LBA 0: Stage 1 MBR and partition table
- LBA 1-16: Stage 2 bootloader
- LBA 17-208: protected-mode kernel ELF image
- LBA 2048+: FAT16 partition containing `DOOM1.WAD`, `USERPROB.ELF`, and
  `DOOM.ELF`, plus empty dynamic `DEFAULT.CFG` and `DOOMSAV0.DSG` through
  `DOOMSAV5.DSG` writable root entries

## Runtime Shape

The OS is intentionally narrow. Its job is to boot, draw Doom frames, read
input, keep time, load a WAD, run user-mode Doom, and provide enough C/POSIX-ish
runtime for the original engine.

| Area | Current shape |
| --- | --- |
| Boot | BIOS MBR Stage 1, raw-sector Stage 2, ELF32 kernel loader |
| CPU | 32-bit protected mode, flat GDT, IDT/PIC/PIT, TSS |
| Memory | Paging, frame accounting for the first managed 32 MiB, kernel heap, user VM regions |
| User mode | Ring 3 probe and Doom process, `int 0x80`, table-backed exec handoff |
| Storage | ATA PIO, MBR, FAT16 root files, dynamic cluster allocation/free/truncate |
| Doom | Official `linuxdoom-1.10` engine objects plus `doom_port/*` shims |
| Graphics | VBE 32-bpp LFB when available, Mode 13h fallback, Doom 320x200 indexed present path |
| Input | PS/2 keyboard and mouse to normal Doom events |
| Audio | SB16 path with Doom SFX/music status proof and aggregate cloud audio proof |
| Safety | Local QEMU opt-in, cloud diagnostics only, WAD/disk/pixel/audio artifacts excluded |

The interactive kernel shell still exists for diagnostics: `help`, `about`,
`clear`, `echo`, `mem`, `mode`, `ticks`, `heap`, `paging`, `libc`, `c`, `user`,
`wad`, `reboot`, `halt`, and `poweroff`.

## Still required before this is actually Doom-capable

These are the remaining gaps before the project can honestly call itself done
for playable Doom rather than "very close":

- A current green cloud persistence run proving Doom-created `DOOMSAV*.DSG`
  survives reboot and reloads back into gameplay.
- A remote human VNC playtest from `docs/runbooks/remote-doom-playtest.md`,
  tied to a passing scripted run and checked after download.
- Repeated real-WAD cloud runs to catch input/audio/timing flakes.
- Better human-session polish: graceful Doom exit/reboot behavior and clearer
  remote audio expectations.
- Stronger VM/POSIX coverage: richer `mmap`, `dup`/descriptor semantics,
  broader exec targets, and less fixed-slot process machinery.
- Higher-half/non-identity cleanup beyond the current low-memory runtime
  contract.
- Broader framebuffer/fullscreen/aspect behavior beyond the current QEMU VBE
  target.
- Hardware-class expansions only when proven: UEFI, real PCI enumeration, AHCI,
  USB, SMP, APIC, HPET, or physical hardware support must update
  `docs/hardware-support.md` and pass the support-matrix checker before README
  language can claim them.

The detailed honesty ledger lives in `docs/post-checkpoint-gaps.md`; its
machine-readable `GAP[...]` rows are the source of truth for open proof gates.

## Docs Map

- `docs/doom-provenance.md`: original Doom source integrity and asset boundary.
- `docs/doom-libc-runtime.md`: libc and syscall runtime expectations.
- `docs/boot-loader-vm.md`: raw-sector boot, ELF handoff, paging, and VM gaps.
- `docs/process-vm.md`: process address spaces and user/kernel mappings.
- `docs/process-exec.md`: table-backed exec, argv stack, and scheduler handoff.
- `docs/persistent-fat16.md`: dynamic FAT16 persistence contract.
- `docs/graphics.md`: framebuffer and scaler behavior.
- `docs/playable-cloud-proof.md`: scripted cloud proof contract.
- `docs/runbooks/play-now-cloud.md`: shortest remote play path.
- `docs/runbooks/codespaces-play-now.md`: Codespaces launcher details.
- `docs/runbooks/cloud-interactive-playtest.md`: fuller remote noVNC/SPICE flow.
- `docs/runbooks/remote-doom-playtest.md`: human proof collection.
- `docs/hardware-support.md`: bounded hardware support matrix.
- `boot/uefi/README.md`: contract-only UEFI scaffold.
