# Doom Provenance And Honesty Contract

This project is trying to run Doom on a hobby operating system, not hide Linux
or a source port under a thin wrapper. The rule is simple: the original Doom
engine drop stays original, and vibe-os owns the boot path, kernel, drivers,
runtime, and platform boundary around it.

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
the top-level release docs, checks that the Makefile compiles original engine
objects and separate `doom_port` objects, and rejects source-port/wrapper paths.

`tools/check_repo_hygiene.py` scans tracked files and fails if game data,
generated VM evidence, rendered pixel artifacts, wrapper-engine paths, or
runtime/build references to shortcut engines and host display/audio APIs have
entered git. It also checks `git status -- third_party/doom` so unstaged,
staged, or untracked vendor-tree edits fail the host suite. This is
intentionally conservative because the public repository should contain source
and text diagnostics, not copyrighted data, ambiguous proof artifacts, or a
quietly patched Doom engine.

## What Is Honest To Claim

Honest:

- vibe-os has a real x86 boot path, protected-mode kernel, ATA/FAT storage,
  framebuffer/input/timer/audio/syscall runtime work, and a freestanding Doom
  link using original id Software sources plus `doom_port` shims.
- The local generated WAD fixture proves the storage and loader path without
  shipping game data.
- The manual real-WAD cloud workflow is the current truth-serum path because it
  fetches a validated shareware `DOOM1.WAD` in a disposable runner, boots the OS,
  and uploads only non-WAD diagnostics.

Not honest yet:

- claiming the OS is fully Doom-capable without a current passing real-WAD cloud
  run on the exact commit being claimed
- claiming human playability from framebuffer dumps or WAD-derived screenshots
  committed to the repo
- claiming this is the original DOS Doom source; it is the public GPL
  `linuxdoom-1.10` release
- claiming POSIX completeness, full process isolation, or a general-purpose OS
  beyond the implemented Doom-oriented runtime

Before saying "you can play Doom on vibe-os", require a current real-WAD cloud
workflow pass, status proof that Doom reaches E1M1 gameplay, deterministic input
proof that keyboard actions affect game state, and a reviewed path for trying it
interactively on disposable hardware or a cloud VM.
