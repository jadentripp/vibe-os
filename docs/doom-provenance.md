# Doom Provenance And Honesty Contract

This project is trying to run Doom on a hobby operating system, not hide Linux
or a source port under a thin wrapper. The rule is simple: the original Doom
engine drop stays original, and vibe-os owns the boot path, kernel, drivers,
runtime, and platform boundary around it.

The stance is "legit but playable first": document the lawful public Doom
source base and repo-owned OS boundary plainly, keep proprietary game data and
rendered proof assets out of git, and make the fastest human path a disposable
remote run rather than a local asset-sprawl shortcut.

## Original Doom

- Upstream source: `https://github.com/id-Software/DOOM`
- Imported commit: `a77dfb96cb91780ca334d0d4cfd86957558007e0`
- Local vendor root: `third_party/doom`
- Engine source used for the game build: `third_party/doom/linuxdoom-1.10`

`linuxdoom-1.10` is the closest lawful public source base for this repo. It is
the id Software GPL source release, not the commercial DOS tree. The repo must
not edit files under `third_party/doom`; all port work belongs outside that
tree.

## Port Boundary

The Doom build compiles original engine `.c` files from
`third_party/doom/linuxdoom-1.10` and filters out only the Linux platform files
named `i_*.c`. Those files are the OS interface layer in the original Linux
release, so vibe-os replaces that boundary with freestanding code under
`doom_port/`.

Allowed port-owned code includes:

- `doom_port/start.c`
- `doom_port/platform.c`
- `doom_port/input.c`
- `doom_port/libc.c`
- `doom_port/music.c`
- headers under `doom_port/include/`
- kernel syscalls, drivers, storage, graphics, input, and audio code
- build scripts, tests, and documentation outside `third_party/doom`

Not allowed:

- editing `third_party/doom`
- importing `doomgeneric`, Chocolate Doom, Crispy Doom, PrBoom, or another Doom
  source port as the engine
- committing WAD files, disk images, framebuffer dumps, screenshots, VM logs, or
  rendered real-WAD pixels as proof

## Mechanical Checks

`tests/host/test_doom_source.py` records the upstream commit, verifies a
deterministic hash over the original `linuxdoom-1.10` `.c` and `.h` files plus
the top-level release docs, verifies a second deterministic hash over the full
imported `third_party/doom` vendor tree, checks that the Makefile compiles
original engine objects and separate `doom_port` objects, and rejects
source-port/wrapper paths.

`tools/check_repo_hygiene.py` scans tracked files and fails if game data,
generated VM evidence, rendered pixel artifacts, wrapper-engine paths, or
runtime/build references to shortcut engines and host display/audio APIs have
entered git. It also rejects standalone music/audio assets such as MUS, MIDI,
soundfonts, tracker modules, and compressed audio, sniffs renamed raw WAD
payloads plus gzip, zip, and tar containers with WAD member names or WAD magic,
and checks
`git status -- third_party/doom` so unstaged, staged, or untracked vendor-tree
edits fail the host suite. The repo `.gitignore` mirrors the common WAD archive,
disk image, rendered pixel, screenshot, log, and raw-audio spillover patterns.
This is intentionally conservative because the public repository should contain
source and text diagnostics, not copyrighted data, ambiguous proof artifacts, or
a quietly patched Doom engine.

## What Is Honest To Claim

Honest:

- vibe-os has a real x86 boot path, protected-mode kernel, ATA/FAT storage,
  framebuffer/input/timer/audio/syscall runtime work, and a freestanding Doom
  link using original id Software sources plus `doom_port` shims.
- Those hardware-facing claims are bounded by `docs/hardware-support.md` to the
  current QEMU BIOS/IDE/PS2/VBE/SB16 device-model proof.
- The local generated WAD fixture proves the storage and loader path without
  shipping game data.
- The manual real-WAD cloud workflow is the current truth-serum path because it
  fetches a validated shareware `DOOM1.WAD` in a disposable runner, boots the OS,
  and uploads only non-WAD diagnostics.
- The fastest safe human try path is `docs/runbooks/play-now-cloud.md`: use a
  disposable remote Linux host or GitHub Codespace and run
  `./tools/play_now_remote.sh` there, not local Mac QEMU. The longer interactive
  proof flow lives in `docs/runbooks/cloud-interactive-playtest.md`.
- The current cloud status may honestly say scripted playability/input and
  aggregate audible audio have been cloud-proven. Persistence/save-load should
  only be claimed when the matching cloud persistence lane is green; the current
  baseline docs record a rebooted `DOOMSAV0.DSG` save-slot proof, and later
  runtime, workflow, or checker changes need a fresh cloud run before updating
  that claim.

Not honest yet:

- claiming the OS is fully Doom-capable without a current passing real-WAD cloud
  run on the exact commit being claimed
- treating `./tools/play_now_remote.sh` as a local Mac QEMU path instead of a
  disposable remote-host path
- claiming human playability from framebuffer dumps or WAD-derived screenshots
  committed to the repo
- claiming this is the original DOS Doom source; it is the public GPL
  `linuxdoom-1.10` release
- claiming POSIX completeness, full process isolation, or a general-purpose OS
  beyond the implemented Doom-oriented runtime
- claiming UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, physical
  hardware, or broad PC compatibility before the support matrix has a claimed
  row and proof for that device class

Before saying "you can play Doom on vibe-os", require a current real-WAD cloud
workflow pass, status proof that Doom reaches E1M1 gameplay, deterministic input
proof that keyboard actions affect game state, and a reviewed path for trying it
interactively on a disposable remote QEMU host or a cloud VM.
