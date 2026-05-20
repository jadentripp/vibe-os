# vibe-os

This repo is a practical "can we actually build an OS with agentic coding?"
workspace. The first milestone is a tiny x86 BIOS-bootable operating system:

- 512-byte Stage 1 MBR boot sector
- Stage 2 loader read from raw disk sectors with BIOS EDD `INT 0x13`
- Stage 2-owned A20 enable, GDT setup, and protected-mode transition
- Stage 2 ELF32 executable parser that loads kernel `PT_LOAD` segments
- repo-owned ELF32 linker for NASM and freestanding C object files, including
  separate executable/read-only and writable `PT_LOAD` segment flags
- 32-bit protected-mode kernel entered through its ELF entry point at `0x10000`
- own VGA text console, PS/2 keyboard polling, and PS/2 auxiliary mouse packet
  decode for Doom input
- kernel-owned IDT/PIC/PIT timer tick
- kernel-owned GDT with Ring 0/Ring 3 descriptors and a TSS
- paging enabled with supervisor-only kernel identity mappings, per-process
  page directories for user processes, ELF segment write-permission metadata,
  and a map-page self-test
- a standalone user ELF loaded from FAT16, entered in Ring 3, invoking
  `int 0x80`, and proving supervisor pages fault
- tiny user-space C runtime entrypoint that links a freestanding C probe into
  `USERPROB.ELF`
- user-mode syscall smoke coverage for `sbrk`, `mmap`, `ioctl`, `open`,
  `read`, `lseek`, classified `fork`/`waitpid`, and console `write`
- syscall pointer validation walks the current process VM region table, so the
  tiny probe and the larger Doom image have different valid mapped regions
- table-backed `SYS_EXEC` handoff that validates a user path, loads a supported
  image, seeds a scheduler-visible Ring 3 context with an argv-shaped stack,
  marks the caller exited, and switches to the target process record
- physical frame accounting for the first managed 32 MiB
- 8 MiB free-list heap with `kalloc`/`kfree` and boot-time high-memory self-test
- freestanding cdecl-style libc subset: strings, memory helpers, integer math, x87 init/test, and `kprintf`
- freestanding C build path that compiles C into the booted kernel image
- vendored official id Software Doom source release at
  `third_party/doom/linuxdoom-1.10`
- freestanding i386 compile/link smoke for 57 unmodified original Doom engine
  modules against the vibe-os platform layer, excluding only the Linux `i_*`
  platform files
- FAT16 disk image carries the linked `DOOM.ELF` user artifact alongside the
  WAD and Ring 3 probe, with kernel-side directory discovery, load, and ELF
  program-header validation
- hard-path WAD loading through an ATA PIO IDE driver and a FAT16 reader
- dynamic FAT16 writable files for Doom defaults, save slots, and bounded
  root-level 8.3 user-created files, with kernel
  read/write/lseek/truncate/unlink/stat support over allocated cluster chains
  validate-before-free chain hardening, and shared per-descriptor offsets for
  WAD and writable file descriptors
- WAD header/directory parsing with named-lump lookup for Doom assets
- text UI with an interactive shell
- local QEMU targets guarded behind an explicit opt-in, plus a host-side safety
  contract that keeps `make test` QEMU-free
- GitHub Actions smoke tests for cloud-side boot validation with status/log
  diagnostics on failure

## Legitimacy Boundary

The project stance is "legit but playable first": keep the Doom source
provenance, OS boot/runtime boundary, and asset handling honest, while making
the fastest playable path a disposable remote run instead of a local Mac QEMU
or asset-sprawl workflow.

- The kernel runs in 32-bit protected mode with its own flat-memory setup.
- The boot path does not use GRUB or Multiboot. `boot/stage1.asm` is the MBR
  sector, and `boot/stage2.asm` is loaded from raw LBAs before the FAT
  partition.
- The kernel is not jumped to as a raw sector blob. The build emits real ELF32
  relocatable objects, `tools/link_elf32.py` links them into an ELF executable,
  and Stage 2 parses the executable's program headers before jumping to the
  entry point.
- Paging, physical-frame accounting, heap allocation, libc helpers, console I/O,
  interrupts, and timer ticks are kernel-owned code in this repo.
- User/kernel separation is not just a label: the boot probe enters Ring 3 with
  user selectors from a standalone C-backed `USERPROB.ELF` file loaded through
  FAT16, allocates user heap, opens and reads `DOOM1.WAD` through kernel
  syscalls, calls the syscall gate, then intentionally faults on a
  supervisor-only kernel page and records the expected page fault.
- `DOOM1.WAD` is not passed in as a GRUB module or RAM disk. The build creates an
  IDE disk image with boot sectors, an MBR partition table, and a FAT16
  partition, and the kernel reads
  `DOOM1.WAD` through its own ATA PIO and FAT16 code.
- The current WAD is a generated IWAD-shaped fixture used to prove the storage
  path and lump parser. A real Doom milestone should replace it with the
  shareware WAD without changing the kernel storage path. The image builder
  supports this with a local, untracked WAD path.
- External programs here are build/test tools: assembler, C compiler, image
  generator, and emulator. They are not runtime OS services.
- Hardware support is bounded by `docs/hardware-support.md`: current evidence is
  for the QEMU BIOS/IDE/PS2/VBE/SB16 target, not broad PC or physical hardware
  compatibility. The kernel also emits bounded PCI config-space diagnostics as
  `pci=`, `pciprobe=`, `pcicount=`, `pcifirst=`, `pciid=`, and `pciclass=`, but
  those fields are status-only and do not claim PCI support.
- Doom source legitimacy is pinned to the official id Software public release:
  `third_party/doom/ORIGIN.md` records the upstream repository and commit, and
  host tests hash the original files used by the compile smoke so port work
  stays outside the vendor tree.
- The detailed source-integrity contract lives in `docs/doom-provenance.md`.
  In short: `third_party/doom` is read-only vendor code, the build compiles the
  original `linuxdoom-1.10` engine objects plus isolated `doom_port/*` shims,
  and host tests reject dirty vendor-tree state, wrapper engines, tracked WADs,
  disk images, logs, rendered pixel artifacts, and runtime/build references to
  shortcut source ports or host display/audio APIs.

## Fastest Safe Play Path

If you just want to play Doom as fast as possible, use the one-command
Codespaces launcher from this Mac checkout:

```sh
./tools/play_now_codespaces.sh
```

When the local checkout is dirty or you want to launch from a known pushed
branch, pin the remote repo/ref explicitly:

```sh
VIBE_REPO=jadentripp/vibe-os VIBE_REF=jt/doom-gameplay-proof \
  ./tools/play_now_codespaces.sh
```

or:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref jt/doom-gameplay-proof
```

Explicit repo/ref mode verifies that the GitHub repo and branch exist remotely
and ignores unrelated local dirt, because the Codespace can only run pushed
code. If you omit `--ref`/`VIBE_REF`, the launcher infers the current branch and
requires the local branch to be clean and exactly synced with its upstream.

The command runs the Mac-side safety checks, creates or reuses a disposable
GitHub Codespace, starts the real vibe-os boot path there, waits for private
noVNC, and opens/prints the browser URL. QEMU, the downloaded shareware WAD,
disk images, pixels, and raw audio stay in the Codespace. If GitHub CLI needs
Codespaces scope, run `gh auth refresh -h github.com -s codespace` once. To
check the plan without creating or modifying a Codespace, run
`./tools/play_now_codespaces.sh --preflight` first.

If you already have a disposable remote Linux host or are already inside a
Codespace, run:

```sh
./tools/play_now_remote.sh
```

Do not run local Mac QEMU for the quick path. See
`docs/runbooks/play-now-cloud.md` for the shortest copy/paste path,
`docs/runbooks/codespaces-play-now.md` for the Codespaces launcher, and
`docs/runbooks/cloud-interactive-playtest.md` for the fuller remote VNC
playtest and proof-capture flow.

For the quickest human proof, leave `./tools/play_now_remote.sh` running on the
remote host and run this from a second remote SSH shell:

```sh
./tools/run_remote_human_playtest.sh \
  --playtester jt \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"
```

That helper prompts for each Doom action, captures the remote monitor status
phases, builds `/tmp/vibe-os-human-proof.tgz`, validates the allowlisted bundle
before download, and prints the local post-download verification commands.

Current cloud status at a high level: the last published baseline has scripted
real-WAD playability/input and aggregate audible-audio proof in the run recorded
below.
Persistence/save-load should only be claimed for a matching green cloud
persistence run; the current proof status below intentionally does not claim a
current-head rebooted `DOOMSAV0.DSG` save-slot proof. Later runtime, workflow,
or checker changes must rerun the relevant cloud gates. Current save-slot proof
also requires the write boot's decoded status via `--save-write-status` and a
reboot/load `--load-status` proving Doom read the full save payload back into
gameplay, so mutated `DOOMSAV*.DSG` bytes alone are not enough.

## Requirements

- `nasm`
- `qemu-system-x86_64`
- `clang`
- `make`

On macOS:

```sh
brew install nasm qemu
```

Apple's `clang` from Xcode Command Line Tools is sufficient for the
freestanding C probe.

## Build

```sh
make
```

The disk image is written to `build/disk.img`.

By default the image contains a generated IWAD-shaped storage fixture so public
CI can boot without copyrighted game data. To build the same OS image with a
real shareware WAD, keep the WAD outside git and pass it explicitly:

```sh
make clean
make DOOM_WAD=/absolute/path/to/DOOM1.WAD
```

The builder validates that the supplied file is a WAD and fits the kernel's
current 5 MiB WAD load window. `*.wad` and `*.WAD` are ignored by this repo so
game data is not accidentally committed.

Run host-side artifact tests without launching QEMU:

```sh
make test
```

Current disk layout:

- LBA 0: Stage 1 MBR and partition table
- LBA 1-16: Stage 2 bootloader
- LBA 17-208: protected-mode kernel ELF image
- LBA 2048+: FAT16 partition containing `DOOM1.WAD`, `USERPROB.ELF`, and
  `DOOM.ELF`, plus empty dynamic `DEFAULT.CFG` and `DOOMSAV0.DSG` through
  `DOOMSAV5.DSG` writable root entries

See `docs/persistent-fat16.md` for the bounded root-level persistence contract,
the Doom save/config path mapping, and the baseline-vs-mutated remote-image
checker for `DEFAULT.CFG` / `DOOMSAV*.DSG` proof.

See `docs/boot-loader-vm.md` for the raw-sector boot chain, protected-mode ELF
handoff, fixed low-memory reservations, paging contract, and VM gaps.

See `boot/uefi/README.md` for the contract-only UEFI boot path scaffold. It is
not a UEFI-bootable artifact; SUPPORT[UEFI] remains unclaimed until there is
source, build integration, and proof evidence.

See `docs/process-vm.md` for the current process address-space contract,
including per-process page directories, VM regions, and remaining VM gaps.

See `docs/process-exec.md` for the current table-backed exec handoff,
process-replacement, argv-stack, and scheduler integration contract.

See `docs/post-checkpoint-gaps.md` for the current post-checkpoint honesty
ledger. Its machine-readable `GAP[...]` rows track the remaining cloud boot,
real gameplay, human playtest, persistence, audio, VM/POSIX, shutdown/panic, and
hardware-limit gates still needed before a playable claim.

See `docs/graphics.md` for the VBE/Mode 13h framebuffer contract and current
scaler limits.

See `docs/hardware-support.md` for the support matrix that separates claimed
QEMU BIOS/IDE/PS2/VBE/SB16 device classes and status-only PCI diagnostics from
unclaimed UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and
physical-hardware support.

## Run

Local QEMU targets are opt-in:

```sh
make ALLOW_LOCAL_VM=1 run
```

For a non-graphical boot check:

```sh
make ALLOW_LOCAL_VM=1 smoke
```

The repo also includes `.github/workflows/os-smoke.yml`, which builds the disk
image, runs host artifact tests, and runs the smoke test in GitHub Actions.
The VM safety contract is checked without launching QEMU:

```sh
make vm-safety-check
```

The normal smoke path still exits QEMU through the monitor after collecting
status. For the shutdown/panic slice, the OS smoke workflow has an opt-in
`shutdown_panic_proof` mode that builds disposable proof kernels on the GitHub
runner and emits `shutdown-panic-proof.json` plus `status.panic.txt`,
`status.shutdown-halt.txt`, `status.shutdown-reboot.txt`, and
`status.shutdown-poweroff.txt`. The reboot and poweroff phases capture status
while the guest waits on CMOS RTC seconds, then the guest requests x86 reset
control / PS/2 reset or ACPI/QEMU poweroff and the workflow requires QEMU to
exit from that guest request.
Validate a downloaded artifact
with:

```sh
python3 tools/check_shutdown_panic_proof.py /path/to/artifact
```

The checker rejects missing artifacts, monitor `quit` as evidence, and
reboot/poweroff manifests that do not record an observed guest-requested QEMU
exit.

For a real-WAD test, run the **Real WAD smoke** workflow manually.
You can paste a URL to `DOOM1.WAD`, `DOOM1.WAD.gz`, or a zip containing
`DOOM1.WAD`; leave the input empty to use `REAL_DOOM_WAD_URL` if the repository
secret is set, otherwise the workflow falls back to the public Archive.org
shareware WAD gzip. In the disposable runner it extracts `DOOM1.WAD`, validates
the expected shareware v1.9 size (`4196020` bytes) and SHA-1
(`5b2e249b9c5133ec987b3ea77596381dc0d6bc1d`), builds `disk.img` with
`DOOM_WAD`, boots it in cloud QEMU, and runs a deterministic input script
through the QEMU monitor. The QEMU step captures status snapshots first; the
separate proof steps then require Doom framebuffer presentation and kernel
status counters showing Doom autostarted E1M1, advanced level time in
`GS_LEVEL`, accepted fire/use/move/mouse/menu input, and changed player/menu
state.
That split keeps failed cloud boots diagnosable from text artifacts instead of
skipping the proof tools. The workflow uploads only non-WAD diagnostics
(`status*.txt`, `status*.bin`, logs, ELF files, and `doom.symbols` for fault
triage). It deliberately does not upload `disk.img`, `gfx.bin`, `vga*.txt`, or
WAD paths, since those may contain Doom game data or rendered pixels.

For the stronger cloud-safe playable proof, see
`docs/playable-cloud-proof.md`. The real-WAD workflow now uses a deterministic
fire/move/use/mouse/menu input script and validates non-pixel status fields for
keyboard delivery, PS/2 mouse delivery, player movement, action commands, menu
activation, and visual activity summaries. Its checker also requires coherent
process/exec, storage, VM, audio, mouse, scheduler, and Doom file I/O telemetry
so a green run is diagnosable from text artifacts alone. The cloud workflows
also run `tools/check_vm_status_proof.py`, which requires `vmmhfree` to prove
dynamic page-table reclaim, `argvsrc=2` for the user-vector Doom exec path, and
`peip` evidence for timer preemption between Doom and the preempt probe.
The same workflow has an opt-in `audible_audio_proof` mode that uses a
temporary QEMU WAV backend on the disposable runner, reduces it to aggregate
`audio-proof.json`, validates that manifest against the same status-only SB16
continuity snapshots, and deletes the WAV before upload.
Raw audio files are not diagnostic artifacts.

Last published proof baseline: run `26165681561` on kernel/runtime commit
`c525952` is the latest archived scripted cloud proof that passes the serious
real-WAD gates. It reaches `doomrun=RUN`, `doomopen=OK`,
`doomread=OK`, `gameplay=OK`, `usr=OK`, live keyboard/mouse/SB16/preemption
counters, the scripted gameplay transition proof, and the aggregate
audible-audio proof. The matching `os-smoke` run `26165678183` also passes the
generated-WAD smoke for the same kernel/runtime commit, and the real-WAD run triages as
`playability-status-green`. Later commits that only
update evidence docs/tests do not change the booted runtime, but any kernel,
runtime, workflow, or proof-checker change must rerun these gates. This is
strong scripted cloud evidence, not yet a human-facing "Doom-capable" claim.
Persistence/save-load should only be claimed for a matching green current-head
cloud persistence run; the older `26156172979` / `eabd307` save-slot reboot
proof is historical evidence for that older runtime, not the current proof
point. Current-head save proof must include both the reboot comparison and the
first boot's `--save-write-status` runtime gate.

Current-head cloud proof state: pending for this branch until the pushed commit
passes the cloud gates below. Before push, keep this host-only readiness check
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

Once `.github/workflows/real-wad-soak.yml` is present on the repository default
branch, run the repeated proof too:

```sh
branch=$(git branch --show-current)
gh workflow run real-wad-soak.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f attempts=3 \
  -f min_passes=3 \
  -f audible_audio_proof=true
```

For a human actually trying the image, use
`docs/runbooks/remote-doom-playtest.md`. It keeps QEMU on a disposable remote
host, exposes a loopback-only VNC display through SSH, keeps `DOOM1.WAD` outside
git, collects an allowlisted status/log/ELF proof bundle with
`tools/run_remote_human_playtest.sh` or
`tools/collect_human_playtest_bundle.py`, requires explicit `--confirm-*`
operator confirmations, writes `human-playtest-notes-v2` with SHA-256 hashes
for every status phase, writes a phase-by-phase `human-playtest-session.json`
tied to the passing real-WAD workflow run ID, writes
`human-playtest-checklist.txt` with `schema=human-playtest-checklist-v1`, writes
a SHA-256 `human-playtest-manifest.json`, and validates downloaded diagnostics
with `tools/check_cloud_playability_artifacts.py --human-session`. Compare the
collector's `pre-download human verification OK` line with the local
`post-download human verification OK` line before treating the downloaded
bundle as the human evidence packet.

## Shell Commands

- `help`
- `about`
- `clear`
- `echo <text>`
- `mem`
- `mode`
- `ticks`
- `heap`
- `paging`
- `libc`
- `c`
- `user`
- `wad`
- `reboot`
- `halt`
- `poweroff`

## Hard-Way Doom Roadmap

Already implemented:

- raw BIOS boot sector and Stage 2 bootloader, without GRUB
- Stage 2 ELF32 kernel loader
- repo-owned ELF32 linker for `R_386_32` and `R_386_PC32` relocations
- 32-bit protected mode with flat GDT
- kernel GDT, TSS, Ring 3 transition, `int 0x80`, and a supervisor-page fault
  isolation probe
- standalone user ELF build, FAT16 storage entry, kernel ELF validation, and
  Ring 3 entry from the loaded executable
- freestanding C user program linked through a tiny `crt0` instead of a
  hand-written assembly-only probe
- first POSIX-shaped user syscall slice: `sbrk`, `open`, `read`, `write`,
  `lseek`, `close`, `unlink`, `stat`, `fstat`, anonymous/private `mmap`,
  display `ioctl`, classified `fork`/`waitpid`, and table-backed `exec`,
  exercised by the user ELF and host lifecycle contracts
- paging, PMM/VMM self-tests, and kernel heap
- kernel libc subset and a freestanding C probe linked from a clang ELF object
- ATA PIO, MBR partition parsing, FAT16 root/cluster loading, and WAD parsing
- official `linuxdoom-1.10` source import, with a no-modification provenance
  policy and a freestanding link smoke for the original engine plus vibe-os
  replacement `i_*` platform layer
- `DOOM.ELF` embedded as a FAT16 root file and discovered by the kernel storage
  path
- widened low-memory paging/PMM coverage to 32 MiB and loaded the linked Doom
  executable into its `0x01000000` image window for ELF validation
- Doom's platform `I_GetTime` now calls a kernel 35 Hz time syscall instead of
  using a fake local counter
- Doom's platform `I_FinishUpdate` calls the display `ioctl` present path for
  a 320x200 8-bit indexed frame plus RGB palette, and CI verifies bytes written
  to the VGA graphics aperture at `0xA0000`
- Stage 2 attempts VBE 32-bpp linear-framebuffer discovery/set, passes the
  framebuffer contract through the boot info block, and the kernel maps that
  LFB to present a 2x XRGB8888-scaled Doom frame with Mode 13h fallback
- Doom's platform `I_StartTic` drains a kernel `SYS_POLL_KEY` queue fed by a
  PS/2 IRQ1 scancode handler and posts normal Doom `ev_keydown`/`ev_keyup`
  events without modifying the original engine source
- the kernel enables the PS/2 auxiliary device when present, decodes 3-byte
  mouse packets from IRQ12 into `SYS_POLL_MOUSE`, records `mouse=*` smoke
  counters, and the Doom platform layer posts `ev_mouse` events without editing
  Doom source
- Stage 2 enters VGA mode 13h before protected mode, while the cloud smoke
  reads kernel status from a normal RAM status block so graphics memory and
  boot status can be verified separately
- after the Ring 3 probe, the kernel enters the loaded original `DOOM.ELF`
  through its ELF entry point with a Doom-sized user stack/heap window; the
  latest real-WAD diagnostics prove the syscall-driven exec handoff reaches
  Doom user mode, opens and reads the real IWAD, and reaches scripted E1M1
  gameplay in cloud QEMU
- the kernel captures a bounded tail of Doom's user-mode stdout/stderr stream
  into the RAM smoke artifact as `doomlog=...`, so startup failures are
  diagnosable without editing Doom source
- optional external `DOOM_WAD=/path/to/DOOM1.WAD` image builds for real
  shareware WAD testing without committing game data
- manual GitHub Actions real-WAD smoke path using a private
  `REAL_DOOM_WAD_URL`, with artifacts limited to non-WAD diagnostics

Still required before this is actually Doom-capable:

- a remote human VNC playtest using `docs/runbooks/remote-doom-playtest.md`,
  including status capture after keyboard-driven menu and gameplay actions
- relocating the running kernel onto the new higher-half/non-identity mapping
  contract, plus dynamic process page tables and non-identity user frame backing
- broader VM/POSIX coverage: exec beyond the new root-level FAT16 `.ELF`
  fallback, richer `mmap`, fuller file semantics, descriptor duplication, and
  more device/ioctl contracts
- broader framebuffer mode support, aspect policy, fullscreen behavior, and
  dirty-rect presentation beyond the current XRGB8888 VBE path
- human audio/listener validation and a stronger music stream ABI beyond the
  current SB16-refill-requested, Doom-port-rendered PULL chunks
- graceful Doom exit/reboot behavior for a human session
- new device-class claims must update `docs/hardware-support.md` and pass the
  host support-matrix checker; current claims stay bounded to the QEMU
  BIOS/IDE/PS2/VBE/SB16 target, with PCI diagnostics status-only, until each new
  class has disposable-runner or dedicated hardware proof
