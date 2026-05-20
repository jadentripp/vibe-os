# Post-Checkpoint Doom Gaps

This is the single honesty ledger for the Doom-capability checkpoint. It is
about what still has to be proved before saying "you can play Doom on vibe-os",
not about making the project sound finished.

The `GAP[...]` lines below are intentionally machine-readable. Keep each row's
`status`, `category`, `gate`, and `evidence` fields current; host tests parse
them so README and runbook wording cannot quietly drift into overclaiming.

## Closed Since Earlier Checkpoints

- The smoke status now exposes `doomexit=`, `doomfault=`, `doomfaultip=`,
  `doomfaultv=`, `doomfaulterr=`, and compact `fault=` frame diagnostics. The
  kernel records Doom's user-mode `exit()` status plus CR2, faulting EIP,
  exception vector, x86 error code, selectors, stack, current process identity,
  state, and last syscall; those values are now part of the cloud-safe RAM
  status artifact so a real-WAD run can prove Doom is still running and has not
  faulted.
- Doom user faults record `doomrun=FAULT` plus `doomfault=<cr2>`,
  `doomfaultip=<eip>`, `doomfaultv=<vector>`, `doomfaulterr=<error-code>`, and
  `fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall`.
- The FAT16 image has root entries for `DEFAULT.CFG` and `DOOMSAV0.DSG` through
  `DOOMSAV5.DSG`, and host tests prove image-level allocation/readback behavior.

## Latest Cloud Evidence

As of 2026-05-20, the latest reported real-WAD cloud evidence has moved past the
old "Doom faults before WAD I/O" stage. Archived manual run `26149350434` on
commit `da9c136` passes the current scripted real-WAD cloud artifact checker and
triages as `playability-status-green`. That is a real scripted cloud proof for
that commit, but it is still not a Doom-capable proof for the dirty current
branch or a human-facing playable claim.

What the current evidence proves:

- The disposable real-WAD workflow can fetch and validate the shareware
  `DOOM1.WAD`, build the image, boot it in cloud QEMU, and start the Doom ELF
  through the generic `SYS_EXEC("DOOM.ELF")` path.
- Real-WAD Doom reaches `doomrun=RUN` with WAD I/O visible through the kernel
  file path: `doomopen=OK`, `doomread=OK`, nonzero seek/close counters, and
  `doomwad` magic for `IWAD`.
- Frame/gameplay counters are active enough to show the engine is presenting
  frames and reaching E1M1 gameplay status rather than dying during startup.
- Scripted keyboard input, mouse input, SB16/audio counters, and live
  preemption counters are active in the cloud status stream.
- The exact archived snapshot set for `26149350434` passes the real-WAD,
  human-playability, audio-continuity, artifact-hygiene, and status-triage
  checkers without uploading WAD bytes, disk images, rendered pixels, or audio
  samples.
- Earlier page-fault diagnostics remain useful, but they are historical repair
  context rather than the current primary blocker.

What still fails:

- A previous run is useful evidence, but it is stale once the kernel/runtime,
  workflow, or checker contract changes. The dirty current branch needs a
  fresh manual real-WAD workflow pass on the exact commit being claimed.
- A green final status line is not sufficient by itself. The exact cloud
  artifact for the claimed commit must pass `tools/check_real_wad_proof.py`,
  `tools/check_human_playability_proof.py`, `tools/check_audio_continuity_proof.py`,
  and `tools/check_cloud_playability_artifacts.py` on the uploaded snapshot set.
- The opt-in persistence/audible proof lane is not green yet. Heavy run
  `26149570191` proved disk-level `DEFAULT.CFG` persistence across the same
  runner image, but its reboot status faults in user mode at `memset+0x20`
  (`doomfaultip=01029F20`) before Doom reaches gameplay again. Its
  `audio-proof.json` also predates the stricter continuity-bearing manifest
  contract, so it fails the current audible proof checker.
- The project still needs stronger gameplay proof and a recorded remote human
  playtest before a human-facing "playable" claim is honest.

Earlier red runs kept for context:

- Manual real-WAD run `26146035600` on commit `269dbb8` reached exec handoff but
  faulted in Ring 3 at `FindResponseFile+0x34` with `doomfaultip=01003224`,
  vector `0000000E`, error `00000005`, and `CR2=00000000`.
- Normal cloud smoke run `26146488906` on commit `34eb98d` reached generated-WAD
  open/read and then faulted at `W_AddFile+0x246` with
  `doomfaultip=01024D06`. Those failures should not be described as the latest
  blocker after the newer real-WAD cloud run evidence.

## Machine-Readable Gap Ledger

- `GAP[CLOUD_BOOT] status=open category=cloud-boot gate=real-wad-smoke.yml evidence=status.txt`

Current state:

- The normal cloud smoke builds `disk.img`, boots QEMU in GitHub Actions, and
  verifies the synthetic-WAD status path.
- The manual real-WAD workflow validates the shareware `DOOM1.WAD` size/hash,
  rebuilds the image with that WAD, and keeps WAD bytes, disk images, and
  rendered pixels out of uploaded artifacts.
- Current archived real-WAD cloud evidence reaches Doom runtime, WAD I/O,
  frames, gameplay status, input counters, audio counters, and preemption
  counters, and run `26149350434` passes the scripted proof checkers for commit
  `da9c136`.
- The current branch has uncommitted kernel, checker, workflow, and doc changes,
  so that green artifact is evidence for the previous commit, not a reusable
  claim for this worktree.

Still missing:

- A current passing manual real-WAD cloud workflow on the exact commit being
  claimed. A previous run is useful evidence, but it is stale once the
  kernel/runtime, workflow, or checker contract changes.
- A green run must include a final `status.txt`; `status.failure.txt` from a
  timed-out/faulted smoke is diagnostic evidence only.
- The status snapshot bundle must include clean early/start/fire/move/use/mouse/menu
  baselines that make the proof gates reproducible.

Executable gate:

- Trigger `.github/workflows/real-wad-smoke.yml` for the target ref, then archive
  only the uploaded non-WAD diagnostics: `status*.txt`, `status*.bin`, QEMU log,
  serial log, monitor log, and ELF files.

- `GAP[REAL_GAMEPLAY] status=open category=real-gameplay gate=check_real_wad_proof.py evidence=gameplay-status`

Current state:

- `tools/check_real_wad_proof.py` requires Doom to enter `GS_LEVEL`, reach E1M1,
  advance tics, present non-pixel visual summaries, read the WAD through kernel
  file syscalls, keep Doom exit/fault counters at zero, and report coherent
  process/storage/VM/audio/input/scheduler telemetry.
- The checker delegates scripted input validation to
  `tools/check_human_playability_proof.py`.
- The latest green real-WAD cloud evidence proves the important runtime
  direction: Doom boots, runs, opens/reads the real WAD, presents frames, reaches
  gameplay status, emits input/audio/preemption counters, and passes the
  scripted snapshot checkers for its commit.

Still missing:

- A fresh real-WAD status artifact on the current commit where every required
  field and every required phase snapshot passes the checkers.
- Preserve the now-green scripted `usr=OK`, `use`, mouse effect, audio
  continuity, and preemption evidence while landing the pending kernel/checker
  changes. Any regression in those fields reopens this gap as an implementation
  bug, not just a documentation issue.
- Stronger gameplay proof still matters after the gates pass: the current
  counter/status proof should be paired with a remote human playtest before the
  public claim becomes "playable Doom" rather than "scripted cloud proof".

Executable gate:

- Run `python3 tools/check_real_wad_proof.py` with the early, fire, movement,
  use, menu, and final status artifacts from the cloud workflow, and require it
  to pass without local QEMU or pixel dumps. Then run
  `tools/check_audio_continuity_proof.py` on the same real-WAD snapshot set when
  audio is part of the claim.

- `GAP[HUMAN_PLAYTEST] status=open category=human-playtest gate=remote-doom-playtest.md evidence=human-session-notes`

Current state:

- `docs/runbooks/remote-doom-playtest.md` describes the safe human path: boot on a
  disposable remote host, expose loopback-only VNC through SSH, keep the WAD
  outside git, and validate downloaded diagnostics afterward.
- Deterministic scripted start/fire/move/use/mouse/menu checks are a strong
  cloud-safe proxy.

Still missing:

- A person has not yet completed and recorded a current remote VNC playtest where
  keyboard actions visibly affect the menu and E1M1 gameplay, with mouse actions
  visibly affecting the same remote session when mouse support is claimed.

Executable gate:

- Follow the remote runbook, capture non-WAD status artifacts after real keyboard
  and mouse actions, and run `tools/check_cloud_playability_artifacts.py` plus
  the real-WAD and human-playability checkers on the downloaded diagnostics.

- `GAP[PERSISTENCE] status=open category=persistence gate=reboot-persistence-proof evidence=mutated-disk-status`

Current state:

- The FAT16 image has root entries for Doom config and save files.
- Host tests prove allocation, readback, sparse growth, shrink/zero truncation,
  deletion, protected-file refusal, corrupt-chain rejection before mutation,
  FAT-copy agreement, and libc save/config file modes without launching QEMU.
- `tools/check_doom_persistence_image.py` can inspect a mutated remote image and
  require complete Doom-shaped `DEFAULT.CFG` markers plus a `DOOMSAVN.DSG` save
  header with Doom 1.10 version text, plausible game-state bytes, and enough
  payload to be more than a tiny hand-shaped header. With `--baseline-image`, it
  also requires the requested entries to differ from the fresh pre-boot image, so
  host-preseeded bytes do not count as a persistence proof. With
  `--reboot-baseline-image`, it compares the post-reboot disk against the
  after-write snapshot and requires the requested entries to keep the same FAT
  root cluster, size, and bytes; that reboot comparison now requires the fresh
  baseline too.
  The same baseline comparison rejects protected WAD/ELF mutation.
- The kernel implements FAT16 cluster allocation/free/truncate over the disk
  image, with validate-before-free chain hardening, so the storage layer is no
  longer a read-only WAD loader.
- Host-only persistence tests now prove the Doom state files specifically:
  `DEFAULT.CFG` and `DOOMSAV0.DSG` allocate clusters on demand, sparse growth
  reads back zero-filled gaps, both FAT copies stay synchronized, replacement
  frees stale clusters, and shrink/zero truncation restores the free-cluster
  budget.
- The real-WAD workflow has an opt-in `persistence_proof` path that keeps the
  disk image inside the disposable runner, captures the fresh baseline
  immediately after rebuilding the real-WAD image, restores that baseline before
  the persistence boot, boots once to attempt a Doom quit/save script, runs the
  image checker, captures an after-write snapshot, then the same disk image is
  booted again for a cloud reboot proof. The requested entries must match that
  after-write snapshot. The uploaded artifact includes only status/log/checker
  text, not WAD or disk bytes.
  Summary for the proof gate: captures the fresh baseline immediately after rebuilding;
  same disk image is booted again; cloud reboot proof; reboot comparison now requires the fresh baseline.

Still missing:

- There is not yet an archived successful cloud artifact proving the opt-in
  reboot path with a real WAD and deterministic Doom input script. Until that
  artifact exists, this remains an executable gate rather than a completed
  proof claim.
- The writable FAT path is still Doom-shaped, not full dynamic writable FS semantics:
  root-level 8.3 files, bounded dynamic entries, no subdirectories,
  no rename, no long filenames, and no POSIX delete-while-open behavior.
- There is not yet a broader storage boot path story beyond mutating and
  rebooting the generated FAT16 image inside the disposable proof workflow.

Executable gate:

- Run the opt-in `persistence_proof` cloud path with a deterministic Doom menu
  script that writes `DEFAULT.CFG`, and optionally `DOOMSAVN.DSG`; archive only
  status/log diagnostics, not the disk image. If it fails to drive the menu,
  finish the same flow through the remote VNC runbook and then run
  `python3 tools/check_doom_persistence_image.py --baseline-image
  /tmp/vibe-os-disk.before-persistence.img --reboot-baseline-image
  /tmp/vibe-os-disk.after-persistence-write.img --require-default
  --require-save-slot N build/disk.img` on that remote image before deleting it.

- `GAP[AUDIO] status=open category=audio gate=remote-sb16-audible-proof evidence=audio-status`

Current state:

- The kernel has an SB16 path with IRQ/DMA setup, stereo unsigned 8-bit SFX
  mixing, active voice tracking, panning, pitch stepping, refill accounting, and
  smoke-visible audio counters.
- The Doom port has a freestanding MUS/MIDI parser and bounded PCM renderer that
  submits music as a looped PCM carrier through the same audio syscall and SB16
  voice mixer path without editing the original Doom tree.

Still missing:

- No current cloud or remote artifact proves audible output from a real Doom run.
- Music renders bounded PCM windows and loops that carrier rather than advancing
  a long-running MUS/MIDI pull/refill stream; balancing between music and SFX
  still needs real playback tuning.
- A new `tools/check_audio_continuity_proof.py` gate can validate `audio=SB16`,
  IRQ/refill, SFX, and looped music-carrier counter progression across status
  snapshots without capturing audio bytes, but it still needs a current remote
  artifact with clean baseline/fire/move/use/menu/final progression to pass.
- `tools/check_audible_audio_proof.py` now defines the next host-safe proof:
  the cloud workflow can opt into a temporary QEMU WAV backend, reduce the
  capture to aggregate `audio-proof.json`, delete the WAV, and upload only the
  manifest plus status/log diagnostics. The artifact checker rejects raw audio
  files and validates `audio-proof.json` when present.

Executable gate:

- Run the remote SB16 continuity checker against a real-WAD cloud artifact, then
  run the real-WAD workflow with `audible_audio_proof=true` and require
  `python3 tools/check_audible_audio_proof.py audio-proof.json` to pass on the
  downloaded aggregate manifest. For human quality notes, use remote audio
  forwarding without uploading captured Doom audio. Harden the stream path so
  long music playback does not rely on a single pre-rendered window and exposes
  song-position status counters across the scripted snapshots.

- `GAP[VM_POSIX] status=open category=vm-posix gate=vm-posix-contract evidence=host-and-cloud-tests`

Current state:

- User processes have separate page directories, user/supervisor page bits,
  process VM-region metadata, `int 0x80`, table-backed `exec`, syscall pointer
  validation, anonymous/private `mmap`, display `ioctl`, file syscalls, and
  classified `fork`/`waitpid` failures.
- The `SYS_EXEC` handoff now restores the caller if argv stack seeding or live
  syscall-frame patching fails after the target address space was activated, so
  the rollback counter no longer leaves a half-prepared target running.
- Exec targets reuse their table slots with fresh PIDs, stale user PTE teardown,
  and stack-PTE rearming before image load. Exit and failed exec paths retire
  user mappings instead of only changing process state.
- Timer preemption has a real Ring 3 IRQ-frame switch path: it saves the
  interrupted task, selects a different READY process record, switches CR3/TSS,
  rewrites the live interrupt frame, and reports `pirq` plus
  `pfrom`/`pto`/`peip`/`pspin` status. The preempt probe's stack sampler is
  guarded to run only while that process address space is active.

Still missing:

- This is not a full POSIX environment. There is no arbitrary-path `exec`, real
  `fork`, descriptor duplication, file-backed `mmap`, signal model, terminal
  device model, or POSIX delete-while-open behavior.
- The process model is still a fixed-slot launch/switch contract, not a robust
  Unix process model with dynamic PIDs, reaping, fd inheritance, address-space
  teardown, or general child lifecycle semantics.
- The kernel is still identity-mapped in low memory, page-table allocation is not
  fully dynamic, and 32-bit paging cannot enforce NX.

Executable gate:

- Keep unsupported ABI calls classified as explicit errors, add host tests for
  every new syscall contract, and add cloud tests for any VM behavior used by
  Doom rather than documenting it as assumed.

- `GAP[SHUTDOWN_PANIC] status=open category=shutdown-panic gate=panic-poweroff-proof evidence=panic-status`

Current state:

- User-space `exit()` is handled for the probe and Doom process paths.
- Doom `exit()` records `doomrun=EXIT` plus `doomexit=<code>`.
- Expected user isolation faults are reported by the probe, Doom user faults are
  visible through `doomfault=`, `doomfaultip=`, `doomfaultv=`, and
  `doomfaulterr=`, the latest trap frame is visible through `fault=`, and Doom
  startup text is tailed into `doomlog=`.
- The interactive shell has `halt` and PS/2-controller `reboot` commands.
- Unhandled non-Doom exceptions set `panic=KEXC`, preserve the latest
  `fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall` tuple, write the
  smoke status block, and then halt. Shell `halt` and `reboot` record
  `shutdown=HALT` or `shutdown=REBOOT` before stopping/rebooting.
- `tools/check_vm_safety_contract.py` machine-checks the local-QEMU opt-in,
  cloud diagnostic upload hygiene, panic status fields, and shutdown status
  fields without launching QEMU.
- `tools/check_shutdown_panic_proof.py` now defines the stricter status-only
  artifact contract for the opt-in disposable-cloud proof lane. It requires
  `status.panic.txt`, `status.shutdown-halt.txt`, `status.shutdown-reboot.txt`,
  a `shutdown-panic-proof.json` manifest, explicit `status-before-cleanup`
  evidence, and no WAD, disk, pixel, or raw-audio artifacts.
- The OS smoke workflow now has an opt-in `shutdown_panic_proof` mode that builds
  proof kernels with `SHUTDOWN_PANIC_PROOF_PANIC`,
  `SHUTDOWN_PANIC_PROOF_HALT`, and `SHUTDOWN_PANIC_PROOF_REBOOT` on the
  disposable runner and then runs the checker against the uploaded-status
  contract.

Still missing:

- The cloud smoke runner uses QEMU `-no-reboot -no-shutdown` and exits through
  the QEMU monitor `quit` command. There is no cloud proof that an OS-requested
  reboot, shutdown, or ACPI poweroff works end to end.
- The opt-in proof lane records status before monitor cleanup, so monitor quit
  is not accepted as proof evidence, but guest reset/poweroff is still open
  until a cloud run proves QEMU exits for an OS-requested reason. A fatal crash
  before the exception handler can update status may only be visible through
  serial/QEMU logs.

Executable gate:

- Run the opt-in disposable cloud `shutdown_panic_proof` workflow mode on the
  exact commit being claimed, download its status-only artifact, and pass
  `tools/check_shutdown_panic_proof.py /path/to/artifact`.
- Add a true guest reset or ACPI poweroff path, then extend the checker to
  assert QEMU exits for that guest reason rather than only preserving
  status-before-cleanup evidence.

- `GAP[HARDWARE_LIMITS] status=open category=hardware-limits gate=hardware-matrix evidence=compatibility-notes`

Current state:

- The supported target is BIOS x86 in QEMU with ATA PIO, FAT16, PS/2 keyboard,
  PS/2 mouse when present, PIT timing, VBE XRGB8888 LFB or VGA Mode 13h fallback,
  and optional SB16-compatible audio.

Still missing:

- There is no UEFI boot path, AHCI/SATA native driver, USB input/storage stack,
  SMP, APIC/HPET coverage, general PCI enumeration beyond narrow device needs,
  broad VBE mode matrix, or proof on physical hardware.

Executable gate:

- Publish a small hardware/support matrix and add one cloud or disposable-machine
  proof per newly claimed device class. Until then, claims should stay scoped to
  the current QEMU BIOS/IDE/PS2/VBE/SB16 target.

## Claim Boundary

Do not call the project Doom-capable from README, release notes, or comments just
because host tests pass. A playable claim requires at least:

- a current manual real-WAD cloud workflow pass for the exact commit
- `check_real_wad_proof.py` and `check_human_playability_proof.py` passing on the
  uploaded status artifacts
- `check_audio_continuity_proof.py` passing when audio/SB16 is part of the claim
- `doomrun=RUN`, `doomopen=OK`, `doomread=OK`, `gameplay=OK`, and all
  `doomfault*` fields cleared in those artifacts
- clean `usr=OK`, scripted `use`, mouse, audio baseline, and preemption evidence
  in the phase snapshots
- a remote human playtest or an explicit statement that only scripted
  cloud-safe playability has been proved
- no tracked WADs, disk images, rendered Doom pixels, or modified
  `third_party/doom` files
