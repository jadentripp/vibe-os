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

As of 2026-05-20, manual run `26151623245` on kernel/runtime commit `4c2c5c9`
is the current scripted cloud truth-serum run for the current runtime code. It
passes the real-WAD, human-playability, SB16/audio-continuity, audible-audio
manifest, persistence reboot, artifact hygiene, and status-triage gates. It
triages as `playability-status-green`.

This is real scripted cloud evidence for the current kernel/runtime code, but it
is not a human-facing Doom-capable proof by itself. Later commits that only
update evidence docs/tests do not change the booted runtime. Any kernel,
runtime, workflow, or proof-checker change must rerun the gates before becoming
the next claimed proof point. The project still needs the remote human playtest
and the remaining hard-mode architecture gaps below before README or release
notes should say "you can play Doom on vibe-os" without caveats.

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
- The `26151623245` final status shows live real-WAD Doom with `doomrun=RUN`,
  `doomopen=OK`, `doomread=OK`, `gameplay=OK`, `usr=OK`,
  input/mouse/audio counters, and live preemption counters. Its artifact set
  passes the real-WAD, human-playability, audio-continuity, audible-audio,
  persistence-reboot, artifact-hygiene, and status-triage checkers without
  uploading WAD bytes, disk images, rendered pixels, or raw audio samples.
- Earlier page-fault diagnostics remain useful, but they are historical repair
  context rather than the current primary blocker.

What still fails:

- A green scripted cloud run is not the same thing as a human playtest. A person
  still needs to complete and record the remote VNC path with keyboard/menu and
  gameplay actions.
- The remaining architecture gaps are still real: higher-half or non-identity
  kernel mapping, broader VM/POSIX semantics, broader graphics policy, more
  complete music streaming, a human shutdown/reboot story, and hardware classes
  beyond the current QEMU BIOS/IDE/PS2/VBE/SB16 target.

Earlier red runs kept for context:

- Manual real-WAD run `26150621804` on commit `1db3a7a` reached gameplay and
  triaged as `playability-status-green`, but failed the proof gate at `usr=FAIL`.
- Manual real-WAD run `26149350434` on commit `da9c136` passed the then-current
  scripted checker set, but became stale after later lifecycle/proof-gate
  changes.
- Heavy run `26149570191` proved disk-level `DEFAULT.CFG` persistence, but its
  reboot status faulted at `memset+0x20` (`doomfaultip=01029F20`) and its
  `audio-proof.json` predates the stricter continuity-bearing manifest contract.
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
  counters, and run `26151623245` passes the scripted proof checkers for commit
  `4c2c5c9`.
- The matching normal cloud `os-smoke` run `26151623239` passes the generated-WAD
  boot smoke plus the opt-in shutdown/panic proof lane for the same
  kernel/runtime commit.

Still missing:

- This exact commit boundary is the kernel/runtime commit `4c2c5c9`, which has
  a current passing manual real-WAD cloud workflow. Future kernel/runtime,
  workflow, or checker changes must rerun the same gate before making a fresh
  claim.
- A future green run must include a final `status.txt`; `status.failure.txt`
  from a timed-out/faulted smoke is diagnostic evidence only.
- Future status snapshot bundles must include clean early/start/fire/move/use/mouse/menu
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
- The latest green real-WAD cloud evidence proves the important runtime path:
  Doom boots, runs, opens/reads the real WAD, presents frames, reaches gameplay
  status, emits input/audio/preemption counters, and passes the scripted
  snapshot checkers for commit `4c2c5c9`.

Still missing:

- The current kernel/runtime commit has a fresh real-WAD status artifact where
  every required field and every required phase snapshot passes the checkers.
  Future commits must preserve the now-green scripted `usr=OK`, `use`, mouse
  effect, audio continuity, and preemption evidence. Any regression in those
  fields reopens this gap as an implementation bug, not just a documentation
  issue.
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
- Run `26151623245` passes that reboot proof for `DEFAULT.CFG`: the write proof
  reports `DEFAULT.CFG bytes=512 changed-from-baseline`, and the reboot proof
  reports `DEFAULT.CFG bytes=512 changed-from-baseline survived-reboot` plus
  `reboot status runtime=OK`.

Still missing:

- Save-slot persistence still needs the same cloud reboot proof when a run
  explicitly requires `DOOMSAVN.DSG`; the current green artifact proves
  `DEFAULT.CFG` persistence.
- The writable FAT path is still Doom-shaped, not full dynamic writable FS semantics:
  root-level 8.3 files, bounded dynamic entries, no subdirectories,
  no rename, no long filenames, and no POSIX delete-while-open behavior.
- There is not yet a broader storage boot path story beyond mutating and
  rebooting the generated FAT16 image inside the disposable proof workflow.

Executable gate:

- Run the opt-in `persistence_proof` cloud path with a deterministic Doom menu
  script that writes `DEFAULT.CFG`, or set `persistence_save_slot=N` to require
  a matching `DOOMSAVN.DSG` save-slot proof instead; use `text=NAME` for save
  descriptions so typing is batched through the QEMU monitor; archive only
  status/log diagnostics, not the disk image. If it fails to drive the menu,
  finish the same flow through the remote VNC runbook and then run
  `python3 tools/check_doom_persistence_image.py --baseline-image
  /tmp/vibe-os-disk.before-persistence.img --reboot-baseline-image
  /tmp/vibe-os-disk.after-persistence-write.img --require-default build/disk.img`
  or `--require-save-slot N` on that remote image before deleting it.

- `GAP[AUDIO] status=open category=audio gate=remote-sb16-audible-proof evidence=audio-status`

Current state:

- The kernel has an SB16 path with IRQ/DMA setup, stereo unsigned 8-bit SFX
  mixing, active voice tracking, panning, pitch stepping, refill accounting, and
  smoke-visible audio counters.
- The Doom port has a freestanding MUS/MIDI parser and stateful stream cursor
  that submits streamed music chunks through the same audio syscall and SB16
  voice mixer path without editing the original Doom tree.
- Run `26151623245` passes `tools/check_audio_continuity_proof.py` and
  `tools/check_audible_audio_proof.py` with status-only SB16 continuity and a
  copyright-safe aggregate `audio-proof.json`, proving non-silent audible output
  without uploading raw audio.

Still missing:

- Music now advances chunk-by-chunk from the port-owned song cursor, but the
  kernel still needs a hardware-paced MUS/MIDI pull/refill stream with explicit
  `musicpos=` and ring-health status; balancing between music and SFX still
  needs real playback tuning.
- Human listener quality validation is still separate from the aggregate
  audible-output proof. For human quality notes, use remote audio forwarding
  without uploading captured Doom audio.

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
  process VM-region metadata, `int 0x80`, Doom/probe table-backed `exec`,
  arbitrary root-level FAT16 `.ELF` exec into the reusable probe-class slot,
  syscall pointer validation, anonymous/private `mmap`, display `ioctl`, file
  syscalls, and classified `fork`/`waitpid` failures.
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

- This is not a full POSIX environment. Exec now accepts arbitrary root-level
  FAT16 `.ELF` paths, but there are no directories, long filenames, dynamic
  child slots, real `fork`, descriptor duplication, file-backed `mmap`, signal
  model, terminal device model, or POSIX delete-while-open behavior.
- The process model is still a fixed-slot launch/switch contract with a generic
  probe-class exec fallback, not a robust Unix process model with dynamic PIDs,
  reaping, fd inheritance, address-space teardown, or general child lifecycle
  semantics.
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

- `GAP[HARDWARE_LIMITS] status=open category=hardware-limits gate=check_hardware_support_matrix.py evidence=support-matrix`

Current state:

- The supported target is BIOS x86 in QEMU with ATA PIO, FAT16, PS/2 keyboard,
  PS/2 mouse when present, PIT timing, VBE XRGB8888 LFB or VGA Mode 13h fallback,
  and optional SB16-compatible audio.
- `docs/hardware-support.md` is the scoped hardware/support matrix. Its
  machine-readable `SUPPORT[...]` rows mark BIOS boot, IDE/ATA PIO, FAT16, PS/2
  keyboard/mouse, PIT, VBE/VGA, and SB16 as claimed only inside the current QEMU
  device-model boundary.

Still missing:

- There is no UEFI boot path, AHCI/SATA native driver, USB input/storage stack,
  SMP, APIC/HPET coverage, general PCI enumeration beyond narrow device needs,
  broad VBE mode matrix, or proof on physical hardware.
- UEFI, AHCI, USB, SMP, APIC, HPET, and physical hardware remain unclaimed
  `SUPPORT[...]` rows until a specific proof lane exists for each device class.

Executable gate:

- Run `python3 tools/check_hardware_support_matrix.py`. Future device-class
  claims must add or update a `SUPPORT[...]` row, name the proof boundary, and
  add one host-checkable cloud, disposable-machine, or hardware proof before
  README, docs, runbooks, tests, or release notes describe that class as
  supported. Until then, claims should stay scoped to the current QEMU
  BIOS/IDE/PS2/VBE/SB16 target.

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
