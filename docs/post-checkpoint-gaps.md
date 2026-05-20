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
old "Doom faults before WAD I/O" stage. It is still not a Doom-capable proof,
but the first repair lane has changed.

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
- Earlier page-fault diagnostics remain useful, but they are historical repair
  context rather than the current primary blocker.

What still fails:

- The proof gates are not clean enough to say "playable Doom" yet. The current
  cleanup lane is around `usr=OK` consistency, scripted `use` snapshot
  progression, mouse snapshot/effect baselines, and SB16/audio baseline
  continuity.
- A green final status line is not sufficient by itself. The exact cloud
  artifact for the claimed commit must pass `tools/check_real_wad_proof.py`,
  `tools/check_human_playability_proof.py`, `tools/check_audio_continuity_proof.py`,
  and `tools/check_cloud_playability_artifacts.py` on the uploaded snapshot set.
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
- Current real-WAD cloud evidence reaches Doom runtime, WAD I/O, frames,
  gameplay status, input counters, audio counters, and preemption counters.
- The proof is still red because the uploaded snapshot set needs `usr`, `use`,
  mouse, and audio-baseline cleanup before the checkers can certify it.

Still missing:

- A current passing manual real-WAD cloud workflow on the exact commit being
  claimed. A previous run is useful evidence, but it is stale once the
  kernel/runtime changes.
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
- The latest real-WAD cloud evidence proves the important runtime direction:
  Doom boots, runs, opens/reads the real WAD, presents frames, reaches gameplay
  status, and emits input/audio/preemption counters.

Still missing:

- A fresh real-WAD status artifact on the current commit where every required
  field and every required phase snapshot passes the checkers.
- The remaining proof work is baseline hygiene, not a known pre-WAD crash:
  make `usr=OK` stable in the proof status, prove the scripted `use` phase,
  prove mouse button/motion effects against the baseline, and make the audio
  continuity baseline line up with the same snapshot sequence.
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
  require Doom-shaped `DEFAULT.CFG` text plus a `DOOMSAVN.DSG` save header
  without exporting the WAD or rendered pixels. With `--baseline-image`, it also
  requires the requested entries to differ from the fresh pre-boot image, so
  host-preseeded bytes do not count as a persistence proof. With
  `--reboot-baseline-image`, it compares the post-reboot disk against the
  after-write snapshot and requires the requested entries to keep the same FAT
  root cluster, size, and bytes. The same baseline comparison rejects protected
  WAD/ELF mutation.
- The kernel implements FAT16 cluster allocation/free/truncate over the disk
  image, with validate-before-free chain hardening, so the storage layer is no
  longer a read-only WAD loader.
- The real-WAD workflow has an opt-in `persistence_proof` path that keeps the
  disk image inside the disposable runner, boots once to attempt a Doom quit/save
  script, runs the image checker, captures an after-write snapshot, then the
  same disk image is booted again for a cloud reboot proof. The requested
  entries must match that after-write snapshot.

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
- Timer preemption has a real Ring 3 IRQ-frame switch path: it saves the
  interrupted task, selects a different READY process record, switches CR3/TSS,
  rewrites the live interrupt frame, and reports `pfrom`/`pto`/`peip`/`pspin`
  status. The preempt probe's stack sampler is guarded to run only while that
  process address space is active.

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

Still missing:

- The cloud smoke runner uses QEMU `-no-reboot -no-shutdown` and exits through
  the QEMU monitor `quit` command. There is no cloud proof that an OS-requested
  reboot, shutdown, or ACPI poweroff works end to end.
- There is no disposable-cloud proof that intentionally triggers a kernel panic
  and captures `panic=KEXC` from the RAM status block. A fatal crash before the
  exception handler can update status may only be visible through serial/QEMU
  logs.

Executable gate:

- Add an explicit reboot/shutdown proof mode in a disposable cloud runner, or add
  an ACPI poweroff path and assert QEMU exits for that reason.
- Add an explicit disposable panic proof mode that forces a kernel exception,
  captures `panic=KEXC`, `shutdown=NONE`, and the compact `fault=` record, and
  uploads only status/log diagnostics.

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
