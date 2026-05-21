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

As of 2026-05-21, manual current-head run `26206176284` on commit `7390468` is
the latest published scripted cloud truth-serum run for the pushed branch. It
passes the real-WAD gameplay, scripted human-playability, scripted gameplay
transition, status-triage, and save/load persistence lanes from the
cloud run. The persistence proof reports
`DOOMSAV0.DSG bytes=25718 changed-from-baseline description='VIBE SAVE'
version='version 110' leveltime=33`, then the reboot/load proof reads the same
save payload, closes it, records `saveact` load-done, and returns to
`gameplay=OK`. `tools/triage_persistence_artifacts.py` classifies the downloaded
artifact as `persistence-proof-green`, with `first-boot`, `save-write`,
`reboot-load`, and `manifest/status` all passing.

This is not a post-fix full-lane green run. The audio lane failed in the cloud
under the old checker with `musicrend= rendered sample delta must keep pace...`.
After the local checker was corrected to validate buffered music coverage, the
downloaded `26206176284` artifact passes `tools/check_audio_continuity_proof.py`
locally. Treat this as current evidence for gameplay and persistence, plus a
known audio-checker false red. The VM/process checker has since become stricter
about user-probe dup/fd evidence (`uflags=`/`fdup=`), so this older artifact is
not a current VM/process proof under the latest checker. Do not claim
current-head full-lane green until a fresh post-fix cloud run passes.

This is real scripted cloud evidence for the current runtime, but it is not a
human-facing Doom-capable proof by itself. The project still needs the formal
remote human playtest bundle, a post-fix full-lane cloud rerun for audio, and
the remaining hard-mode architecture gaps below before README or release notes
should say "finished Doom-capable OS" without caveats.

Historical repair context: run `26196214650` on `2788c00` reached the real-WAD
playability checks but failed earlier because `DOOMSAV0.DSG` was truncated to
1024 bytes after the first write. Its `flb=`/`fcl=` diagnostics narrowed that
older blocker to FAT save growth and chain clipping.
Another historical save/load blocker was `Unknown tclass 112 in savegame`; the
port-owned status diagnostics now expose `savestm=` and `savethk=` stream
fields so malformed thinker/specials class bytes can be triaged without
uploading the save file or editing original Doom source.

What the last published evidence proves:

- Current-head run `26206176284` on `7390468` proves the gameplay, scripted
  human-playability, gameplay transition, status triage, and save/load
  persistence lanes for the latest pushed runtime commit.
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
- The `26206176284` final status shows live real-WAD Doom with `doomrun=RUN`,
  `doomopen=OK`, `doomread=OK`, `gameplay=OK`, `usr=OK`,
  input/mouse/audio counters, and live preemption counters. Its artifact set
  passes the real-WAD, human-playability, scripted gameplay transition, cloud
  status triage, and persistence checkers without uploading WAD bytes, disk
  images, rendered pixels, or raw audio samples.
- `tools/check_vm_status_proof.py` is now the executable cloud gate for the
  higher-half VMM, exec handoff, dup/fd inheritance evidence, and preemptive
  context-switch status fields. A fresh cloud run must pass this latest gate
  before the current head can claim current VM/process proof.
- The `gameplay-proof.json` artifact from `26206176284` is schema
  `scripted-gameplay-proof-v1` and records SHA-256 hashes plus compact start,
  fire, movement, use, mouse, menu, and final state summaries without storing
  WAD bytes or pixels.
- The audio result for `26206176284` is a known checker false red: the cloud run
  failed with `musicrend= rendered sample delta must keep pace...`, while the
  downloaded artifact passes the corrected buffered-coverage
  `tools/check_audio_continuity_proof.py` locally.
- Previous full-lane green run `26205557019` on `bfd04e8` passed the real-WAD,
  human-playability, scripted gameplay transition, VM/process,
  audio-continuity, audible-audio, artifact hygiene, status-triage, and
  save/load persistence gates. Push-triggered OS smoke run `26205496796` on the
  same commit also passes the generated-WAD boot and VM/process exec gates.
- Older green runs `26203744974` on `f9a688e`, `26165681561` on `c525952`, and
  `26165678183` remain useful historical repair context, but they are no longer
  the latest current-head evidence.
- Historical save-slot persistence proof from run `26156172979` on commit
  `eabd307` reported
  `DOOMSAV0.DSG bytes=512 changed-from-baseline description='VIBESAVE' version='version 110'`
  after the write boot, then
  `DOOMSAV0.DSG bytes=512 changed-from-baseline survived-reboot description='VIBESAVE' version='version 110'`
  plus `reboot status runtime=OK` after the second boot of the same cloud disk
  image. That is useful storage evidence, but it is historical repair context
  until rerun on the current head.
- Run `26157926297` on commit `6b5319e` passes the opt-in
  `shutdown_panic_proof` workflow and the downloaded status-only artifact passes
  `tools/check_shutdown_panic_proof.py`. The proof records `panic=KEXC`,
  `shutdown=HALT`, `shutdown=REBOOT`, and `shutdown=POWEROFF`, with
  `guest_exit_observed=true` for the reboot and poweroff phases.
- Earlier page-fault diagnostics remain useful, but they are historical repair
  context rather than the current primary blocker.

What still fails:

- A green scripted cloud run is not the same thing as a human playtest. A person
  still needs to complete and record the remote VNC path with keyboard/menu and
  gameplay actions.
- The latest current-head run is not a post-fix full-lane green run. A fresh
  cloud run with the corrected buffered-coverage audio checker must pass before
  the docs can claim current-head full-lane green.
- The remaining architecture gaps are still real: relocating the running kernel
  onto the new higher-half/non-identity mapping contract, broader VM/POSIX
  semantics, broader graphics policy, more complete music streaming, and
  hardware classes beyond the current QEMU BIOS/IDE/PS2/VBE/SB16 target.

## User-Facing Legitimacy Roadmap

Playable now:

- It is fair to say the real `DOOM1.WAD` path is scripted-cloud playable in the
  disposable QEMU proof lane: Doom runs as a Ring 3 process, opens and reads the
  WAD, reaches E1M1 gameplay, accepts scripted keyboard and mouse actions, emits
  SB16/audio status counters, and persists then reloads a save slot. The latest
  current-head artifact also passes the corrected local SB16 continuity checker,
  but the cloud audio lane is still an old-checker false red until a post-fix
  cloud rerun passes.
- Keep the caveat attached: this means "playable through the repo's cloud proof
  lane with status-only artifacts." It does not yet mean a finished,
  general-purpose OS, a recorded human playtest, or current-head full-lane green.

Next playability polish:

- Complete the formal remote VNC human playtest bundle for the current commit,
  including notes, phase hashes, post-download verification, and the strict
  `--require-human-session` checker.
- Tune the user-facing session quality: smoother first-run remote play steps,
  keyboard/menu confidence from a person, mouse confirmation in the same
  session, and human audio quality notes without uploading raw Doom audio.
- Move music toward a hardware-paced kernel pull/refill stream and tune SFX/music
  balance so the audible proof becomes pleasant playback evidence, not just a
  non-silent aggregate.

Legit general-OS milestones:

- Relocate the running kernel onto the non-identity higher-half contract instead
  of only proving high aliases and process page directories.
- Grow VM/POSIX semantics beyond the fixed-slot process model: dynamic child
  lifetimes, real `fork`, fd duplication, file-backed `mmap`, reusable VM
  objects, signals, terminal behavior, and broader syscall coverage.
- Prove install/recovery and hardware support outside the current generated
  FAT16 image and QEMU BIOS/IDE/PS2/VBE/SB16 device model: UEFI, AHCI/SATA, USB,
  SMP, APIC/HPET, broader PCI/device discovery, and physical hardware each need
  their own machine-readable proof boundary before they become user-facing
  claims.

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

- `GAP[CLOUD_BOOT] status=proven category=cloud-boot gate=real-wad-smoke.yml evidence=real-wad-smoke-26206176284`

Current state:

- The normal cloud smoke builds `disk.img`, boots QEMU in GitHub Actions, and
  verifies the synthetic-WAD status path.
- The manual real-WAD workflow validates the shareware `DOOM1.WAD` size/hash,
  rebuilds the image with that WAD, and keeps WAD bytes, disk images, and
  rendered pixels out of uploaded artifacts.
- Current archived real-WAD cloud evidence reaches Doom runtime, WAD I/O,
  frames, gameplay status, input counters, audio counters, and preemption
  counters, and run `26206176284` passes the scripted gameplay and persistence
  proof checkers for commit `7390468`.
- The previous normal cloud `os-smoke` run `26205496796` passes the generated-WAD
  boot smoke for the older full-lane commit `bfd04e8`; rerun normal OS smoke
  for the exact target commit when the claim depends on generated-WAD boot
  evidence too.
- The display path now has a host-proved aspect policy: LFB presents use the
  largest centered 320x240 integer scale when the framebuffer can fit it, expose
  a labeled `SQ` fallback for 320x200 square scaling, and report `fbpolicy`,
  `fbgeom`, and `fbdirty` so future status artifacts show the exact display
  contract without uploading pixels.

Still missing:

- No known design gap is open for the scripted cloud-boot gate: `7390468` has a
  passing manual real-WAD cloud workflow with final `status.txt` and clean
  early/start/fire/move/use/mouse/menu baselines that make the proof gates
  reproducible for gameplay and persistence. Audio remains a post-fix rerun
  boundary because the cloud run used the old checker.
- Future commits still need the same gate rerun for the exact commit after push
  before making a fresh current-head claim. `status.failure.txt` from a
  timed-out/faulted smoke remains diagnostic evidence only.

Executable gate:

- Trigger `.github/workflows/real-wad-smoke.yml` for the target ref, then archive
  only the uploaded non-WAD diagnostics: `status*.txt`, `status*.bin`, QEMU log,
  serial log, monitor log, and ELF files.

- `GAP[REAL_GAMEPLAY] status=proven category=real-gameplay gate=check_real_wad_proof.py evidence=real-wad-smoke-26206176284`

Current state:

- `tools/check_real_wad_proof.py` requires Doom to enter `GS_LEVEL`, reach E1M1,
  advance tics, present non-pixel visual summaries, read the WAD through kernel
  file syscalls, keep Doom exit/fault counters at zero, and report coherent
  process/storage/VM/audio/input/scheduler telemetry.
- The checker delegates scripted input validation to
  `tools/check_human_playability_proof.py`.
- The latest real-WAD cloud evidence proves the important runtime path:
  Doom boots, runs, opens/reads the real WAD, presents frames, reaches gameplay
  status, emits input/audio/preemption counters, and passes the scripted
  snapshot checkers for commit `7390468`.

Still missing:

- No known design gap is open for the scripted real-gameplay gate: `26206176284`
  has a real-WAD status artifact where every required field and every required
  phase snapshot passes the gameplay checkers for commit `7390468`. Future
  commits must preserve the now-green scripted `usr=OK`, `use`, mouse effect,
  and preemption evidence. Audio continuity from this artifact passes only after
  the local buffered-coverage checker fix; a cloud rerun is still required
  before treating audio as current-head full-lane green. Any regression in those
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
- The manual bundle checker now requires `human-playtest-notes.txt`,
  `human-playtest-session.json`, and `human-playtest-manifest.json`. The session
  transcript must name the passing scripted real-WAD run ID and match the exact
  status phase order, byte counts, SHA-256 hashes, and compact status summaries
  rebuilt from the bundle.
- The notes schema is now `human-playtest-notes-v2`: it requires explicit
  operator confirmation fields, one SHA-256 `phase_hash_*` value for every
  human status phase, and a post-download verification commitment. The checker
  compares those note hashes against the downloaded status files and prints a
  `post-download human verification OK` line so reviewers can compare
  `session_id`, `bundle_sha256`, `manifest_sha256`, and short phase hashes
  against the remote collector output.
- `tools/check_human_playability_proof.py --require-human-session` is the strict
  manual gate. It requires all eight human phase snapshots, validates the notes
  commit and linked real-WAD run ID, recomputes the phase hashes, rejects
  forbidden WAD/disk/pixel/raw-audio artifacts in the proof directory, and
  requires at least 350 Doom ticks of elapsed `gtic=` and `leveltime=` from
  `status.after-start.txt` to `status.txt`.

Still missing:

- A person has not yet completed and recorded a current remote VNC playtest where
  keyboard actions visibly affect the menu and E1M1 gameplay, with mouse actions
  visibly affecting the same remote session when mouse support is claimed.

Executable gate:

- Follow the remote runbook, capture non-WAD status artifacts after real keyboard
  and mouse actions, collect the bundle with
  `tools/collect_human_playtest_bundle.py --scripted-proof-run-id <run-id>`
  plus the required `--confirm-*` flags, and run
  `tools/check_cloud_playability_artifacts.py --human-session`,
  `tools/check_human_playability_proof.py --require-human-session --human-notes
  human-playtest-notes.txt`, plus the real-WAD checker on the downloaded
  diagnostics. The local
  post-download verification line must match the remote pre-download
  verification line before the human packet counts as evidence.

- `GAP[PERSISTENCE] status=proven category=persistence gate=reboot-persistence-proof evidence=real-wad-smoke-26206176284`

Current state:

- The FAT16 image has root entries for Doom config and save files.
- Host tests prove allocation, readback, sparse growth, shrink/zero truncation,
  deletion, protected-file refusal, corrupt-chain rejection before mutation,
  FAT-copy agreement, duplicate-root/cross-link/orphaned-cluster rejection, and
  libc save/config file modes without launching QEMU.
- `tools/check_doom_persistence_image.py --require-dynamic-fat-proof` now
  mutates an in-memory copy of the image to prove dynamic FAT allocation, free,
  and truncate behavior: create `FATPROOF.TMP`, sparse-extend with zero-filled
  holes, shrink with tail-cluster freeing and tail-byte zeroing, truncate to
  zero, rewrite, delete, and reuse the deleted root slot, then re-check FAT-copy
  agreement and reachable-cluster ownership.
- Host image tests also cover a real FAT directory tree beyond Doom-shaped flat
  files: root directory listing, read-only 8.3 subdirectory lookup/readback, and
  checker rejection for orphaned or cross-linked clusters inside a
  subdirectory.
- `tools/check_doom_persistence_image.py` can inspect a mutated remote image and
  require complete Doom-shaped `DEFAULT.CFG` assignments with numeric range
  checks plus a `DOOMSAVN.DSG` save header with Doom 1.10 version text,
  printable description, player 1 active, plausible game-state bytes, and
  nonzero serialized payload beyond the tiny header. With `--baseline-image`, it
  also requires the requested entries to differ from the fresh pre-boot image, so
  host-preseeded bytes do not count as a persistence proof. With
  `--reboot-baseline-image`, it compares the post-reboot disk against the
  after-write snapshot and requires the requested entries to keep the same FAT
  root cluster, size, and bytes; that reboot comparison now requires the fresh
  baseline too. Save-slot reboot proof now also requires `--save-write-status`
  from the first boot, so a `DOOMSAVN.DSG` claim has to show a fault-free live
  Doom run with file output, a close, and an `O_WRONLY|O_CREAT|O_TRUNC` open
  before the save bytes and reboot comparison can pass. Save/load playability
  additionally requires `--load-status` from the reboot/load boot: Doom must
  open, read the full `DOOMSAVN.DSG` payload, close it, and report gameplay on
  the saved episode/map at or after the saved leveltime.
  The same checker gate rejects divergent FAT copies, duplicate live root
  entries, cross-linked chains, orphaned allocated clusters, malformed
  directory ownership, and protected WAD/ELF mutation.
- The kernel implements FAT16 cluster allocation/free/truncate over the disk
  image, with validate-before-free chain hardening, so the storage layer is no
  longer a read-only WAD loader.
- Host-only persistence tests now prove the Doom state files specifically:
  `DEFAULT.CFG` and `DOOMSAV0.DSG` allocate clusters on demand, sparse growth
  reads back zero-filled gaps, both FAT copies stay synchronized, replacement
  frees stale clusters, and shrink/zero truncation restores the free-cluster
  budget.
- This is not full POSIX: kernel syscalls are still root-level, and the
  subdirectory support is currently a checker/tooling proof that the FAT layer
  can account for directory-owned clusters without accepting leaks or
  crosslinks.
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
- Run `26206176284` passes save/load persistence for `DOOMSAV0.DSG` on current
  commit `7390468`: the write proof reports
  `DOOMSAV0.DSG bytes=25718 changed-from-baseline description='VIBE SAVE' version='version 110' leveltime=33`,
  the reboot proof reports the same save survived reboot with
  `specials-after=OK`, and the load proof reports `save load status gameplay=OK
  slot=0`.
- Run `26151623245` passes that reboot proof for `DEFAULT.CFG`: the write proof
  reports `DEFAULT.CFG bytes=512 changed-from-baseline`, and the reboot proof
  reports `DEFAULT.CFG bytes=512 changed-from-baseline survived-reboot` plus
  `reboot status runtime=OK`.
- Historical run `26156172979` passes the save-slot reboot proof for
  `DOOMSAV0.DSG` on older commit `eabd307`: the
  write proof reports
  `DOOMSAV0.DSG bytes=512 changed-from-baseline description='VIBESAVE' version='version 110'`,
  and the reboot proof reports
  `DOOMSAV0.DSG bytes=512 changed-from-baseline survived-reboot description='VIBESAVE' version='version 110'`
  plus `reboot status runtime=OK`.

Still missing:

- This proof is cloud-runner scoped and status-driven. It proves the generated
  FAT16 disk image can persist a Doom save across reboot and load it back into
  gameplay in the disposable QEMU target; it is not a general install/recovery
  story for arbitrary disks.
- Install/recovery remains its own claim boundary:
  `STORAGE_BOUNDARY[ARBITRARY_DISK_INSTALL] status=unclaimed` and
  `STORAGE_BOUNDARY[ARBITRARY_DISK_RECOVERY] status=unclaimed`. The current
  host checker can produce an `install-image-manifest` for the repo-generated
  image, but the next real proof must start from `blank-disk-to-bootable-vibe-os`
  and separately prove `detect-and-repair-or-refuse` behavior for damaged image
  fixtures.
- The writable FAT path is now a general root-level 8.3 VFS/FAT layer with
  descriptor truncation, signed seek offsets, sparse-write zero filling, and
  generic dynamic root entries. It is still not full POSIX: no writable
  subdirectories, no rename, no long filenames, and no POSIX delete-while-open
  behavior.
- There is not yet a broader storage boot path story beyond mutating and
  rebooting the generated FAT16 image inside the disposable proof workflow.

Executable gate:

- Run the opt-in cloud path with `persistence_proof=true` for `DEFAULT.CFG`, or
  set `persistence_save_slot=N` to require a matching marker-driven
  `DOOMSAVN.DSG` save/load proof instead; archive only status/log diagnostics,
  not the disk image. If the marker-driven slot path fails,
  finish the same flow through the remote VNC runbook and then run
  `python3 tools/check_doom_persistence_image.py --baseline-image
  /tmp/vibe-os-disk.before-persistence.img --reboot-baseline-image
  /tmp/vibe-os-disk.after-persistence-write.img --require-default build/disk.img`
  or `--require-save-slot N --save-write-status build/status.persistence-write.txt
  --load-status build/status.persistence-load.txt` on that remote image before
  deleting it.

- `GAP[AUDIO] status=open category=audio gate=remote-sb16-audible-proof evidence=audio-status`

Current state:

- The kernel has an SB16 path with IRQ/DMA setup, stereo unsigned 8-bit SFX
  mixing, active voice tracking, panning, pitch stepping, refill accounting, and
  smoke-visible audio counters.
- The Doom port has a freestanding MUS/MIDI parser and stateful stream cursor
  that submits streamed music chunks through the same audio syscall and SB16
  voice mixer path without editing the original Doom tree.
- The music stream now has host-proved long-playback wrap behavior: looping
  songs keep cumulative song-position accounting while rendering from the
  measured loop window, so long runs no longer depend on the old bounded
  loop-pass skip path.
- Current-head run `26206176284` is a known audio-checker false red: the cloud
  lane failed under the old invariant with
  `musicrend= rendered sample delta must keep pace...`, but the downloaded
  artifact passes the corrected buffered-coverage
  `tools/check_audio_continuity_proof.py` locally.
- Previous full-lane run `26205557019` passes `tools/check_audio_continuity_proof.py`
  and `tools/check_audible_audio_proof.py` with status-only SB16 continuity and
  a copyright-safe aggregate `audio-proof.json`, proving non-silent audible
  output without uploading raw audio on that older commit.
- The audible manifest contract now includes aggregate stream-health and
  listener-quality metadata without storing raw audio.

Still missing:

- Music now advances chunk-by-chunk from the port-owned song cursor with
  long-playback wrap and stricter stream-health proof, but the kernel still
  needs a hardware-paced MUS/MIDI pull/refill stream; balancing between music
  and SFX still needs real playback tuning.
- A fresh post-fix cloud audio run is still missing, so the current head cannot
  be described as full-lane green even though the downloaded old-run artifact
  passes the corrected local continuity checker.
- Human listener approval is still separate from the aggregate audible-output
  proof. For human quality notes, use remote audio forwarding without uploading
  captured Doom audio.

Executable gate:

- Run the remote SB16 continuity checker against a real-WAD cloud artifact, then
  run the real-WAD workflow with `audible_audio_proof=true` and require
  `python3 tools/check_audible_audio_proof.py audio-proof.json` to pass on the
  downloaded aggregate manifest. For human quality notes, use remote audio
  forwarding without uploading captured Doom audio. The stream path must keep
  long music playback independent of a single pre-rendered window, expose
  changing song-position and stream-health counters across the scripted
  snapshots, and eventually move to a kernel-owned pull/refill command.

- `GAP[VM_POSIX] status=open category=vm-posix gate=vm-posix-contract evidence=host-and-cloud-tests`

Current state:

- User processes have separate page directories, user/supervisor page bits,
  process VM-region metadata, `int 0x80`, Doom/probe table-backed `exec`,
  arbitrary root-level FAT16 `.ELF` exec into the reusable probe-class slot,
  syscall pointer validation, anonymous/private brk-backed `mmap`, tail
  `munmap` release for page-aligned mappings, display `ioctl`, file syscalls,
  classified `fork` failures, and a bounded `waitpid` scanner that can reap
  already-exited child records from the static process table. `WNOHANG` returns
  `0` for matching live children instead of pretending nonblocking wait is an
  unsupported option.
- File descriptor slots now carry owner PID, open-generation, and inheritance
  flag metadata. The kernel enforces owner PID on fd lookup, retags
  `FD_INHERIT_EXEC` slots from the exec caller to the target PID, closes
  `O_CLOEXEC` non-inheritable slots on exec, and sweeps process-owned
  descriptors during exit, fault, target-slot reuse, and wait reaping.
  Descriptor duplication is still absent, but future fork work now has concrete
  fd state to copy or close instead of anonymous global slots.
- The `SYS_EXEC` handoff now restores the caller if argv stack seeding or live
  syscall-frame patching fails after the target address space was activated, so
  the rollback counter no longer leaves a half-prepared target running. Status
  reports `uexec=OK`/`upath=USERPROB.ELF` when the boot probe came through the
  shared exec resolver, `abiexec=OK`/`abipath=ABIPROBE.ELF`/`abiprobe=OK` when
  the packaged ABI probe ran through a generic root `.ELF` slot, and `argvsrc=2`
  when Doom's ABI stack came from the copied user vector.
- Exec targets reuse their table slots with fresh PIDs, stale user PTE teardown,
  and stack-PTE rearming before image load. Exit and failed exec paths retire
  user mappings instead of only changing process state.
- The mmap/munmap path now records allocation/release counters. Anonymous
  mappings still come from the process heap window, but tail `munmap` clears the
  relevant process PTEs, flushes the active address space, and moves `brk` back
  to the unmapped base. Valid non-tail ranges punch validation holes in the
  heap bitmap, but they do not yet become reusable VM objects.
- Timer preemption has a real Ring 3 IRQ-frame switch path: it saves the
  interrupted task, selects a different READY process record, switches CR3/TSS,
  rewrites the live interrupt frame, and reports `pirq` plus
  `pmask`/`pfrom`/`pto`/`pkind`/`peip`/`pcr3`/`pkstk`/`pframe`/`pspin` status.
  The `pframe` tuple records the last IRQ-frame rewrite count plus the
  Ring 3 `EIP`/`CS`/`ESP`/`SS` that `iretd` will consume, so host gates can
  reject counter-only preemption evidence. The preempt probe's stack sampler is
  guarded to run only while that process address space is active.
- The VMM has a checked higher-half seed contract: `KERNEL_HIGHER_HALF_BASE` is
  `0xc0000000`, `vmm_map_page` can allocate a missing page table from PMM after
  PMM is online, and `vmm_unmap_page` returns an empty PMM-backed page-table
  frame to the allocator after clearing the last PTE. The VMM self-test maps a
  high virtual alias to a different physical frame before unmapping it. Status
  artifacts expose `vmmhi=OK`, `vmmhva=`, `vmmhpa=`, `vmmhpt=`, and
  `vmmhfree=` so the high alias, distinct PMM frame, dynamic page-table frame,
  and reclaimed table frame are visible without a framebuffer dump. This is a
  legitimate non-identity mapping capability, not a relocated running kernel.
  `tools/check_vm_status_proof.py` turns those fields into a cloud gate: it
  requires `vmmhfree` to match the reclaimed `vmmhpt` frame,
  `uexec=OK`/`upath=USERPROB.ELF` for boot-probe exec,
  `abiexec=OK`/`abipath=ABIPROBE.ELF`/`abiprobe=OK` for the generic ABI probe,
  `argvsrc=2` for user-vector Doom exec, `procpool=`/`fdexec=`/`fdup=`/`wait=`/`vmreap=` for bounded
  process-slot reuse, exec-time fd inheritance, the wait/reap proof, and child
  VM teardown during reap, and `pmask` plus
  `pkind`/`peip`/`pcr3`/`pkstk` for timer IRQ switches in both directions
  between Doom and the preempt probe.

Still missing:

- This is not a full POSIX environment. Exec now accepts arbitrary root-level
  FAT16 `.ELF` paths, but there are no directories, long filenames, dynamic
  child slots, real `fork`, descriptor duplication, file-backed `mmap`, signal
  model, terminal device model, or POSIX delete-while-open behavior.
- The process model is still a fixed-slot launch/switch contract with a generic
  probe-class exec fallback, not a robust Unix process model with dynamic PIDs,
  wait blocking, fork-time descriptor table cloning, general physical-frame reclamation
  for identity-shaped user pages, or general child lifecycle semantics.
- The running kernel is still identity-mapped in low memory, process page-table
  allocation is not fully dynamic or reclaimed with process lifetime, non-tail
  unmap punches validation holes but not reusable VM objects, user pages are
  still backed by identity-shaped frames, and 32-bit paging cannot enforce NX.

Executable gate:

- Keep unsupported ABI calls classified as explicit errors, add host tests for
  every new syscall contract, run `tools/check_vm_status_proof.py --require-exec`
  on generated-WAD OS smoke status artifacts, keep `--require-preempt` on
  long-lived real-WAD gameplay status artifacts, and add cloud tests for any VM
  behavior used by Doom rather than documenting it as assumed.

- `GAP[SHUTDOWN_PANIC] status=proven category=shutdown-panic gate=panic-poweroff-proof evidence=os-smoke-26157926297`

Current state:

- User-space `exit()` is handled for the probe and Doom process paths.
- Doom `exit()` records `doomrun=EXIT` plus `doomexit=<code>`.
- Expected user isolation faults are reported by the probe, Doom user faults are
  visible through `doomfault=`, `doomfaultip=`, `doomfaultv=`, and
  `doomfaulterr=`, the latest trap frame is visible through `fault=`, and Doom
  startup text is tailed into `doomlog=`.
- The interactive shell has `halt`, x86 reset-control / PS/2-controller
  `reboot`, and ACPI/QEMU-oriented `poweroff` commands.
- Unhandled non-Doom exceptions set `panic=KEXC`, preserve the latest
  `fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall` tuple, write the
  smoke status block, and then halt. Shell `halt` and `reboot` record
  `shutdown=HALT` or `shutdown=REBOOT`; shell `poweroff` records
  `shutdown=POWEROFF` before requesting poweroff.
- `tools/check_vm_safety_contract.py` machine-checks the local-QEMU opt-in,
  cloud diagnostic upload hygiene, panic status fields, shutdown status fields,
  and proof-only guest-exit harness knobs without launching QEMU.
- `tools/check_shutdown_panic_proof.py` now defines the stricter artifact
  contract for the opt-in disposable-cloud proof lane. It requires
  `status.panic.txt`, `status.shutdown-halt.txt`, `status.shutdown-reboot.txt`,
  `status.shutdown-poweroff.txt`, a `shutdown-panic-proof.json` manifest,
  explicit `status-before-cleanup` halt/panic evidence, `status-before-reset`
  reboot evidence, `status-before-poweroff` poweroff evidence, observed guest
  exit for reboot/poweroff phases, and no WAD, disk, pixel, or raw-audio
  artifacts.
- The OS smoke workflow now has an opt-in `shutdown_panic_proof` mode that builds
  proof kernels with `SHUTDOWN_PANIC_PROOF_PANIC`,
  `SHUTDOWN_PANIC_PROOF_HALT`, `SHUTDOWN_PANIC_PROOF_REBOOT`, and
  `SHUTDOWN_PANIC_PROOF_POWEROFF` on the disposable runner. The reboot phase
  captures status while the guest waits on CMOS RTC seconds, then uses
  `-no-reboot` so the reset-control / PS/2 reset exits QEMU, while also
  omitting `-no-shutdown`; the poweroff phase captures status during the same
  guest-owned delay, omits `-no-shutdown`, and requires the ACPI/QEMU poweroff
  request to exit QEMU.
- Run `26157926297` on commit `6b5319e` passes that workflow. Its downloaded
  artifact passed `tools/check_shutdown_panic_proof.py` and includes
  `panic=KEXC`, `shutdown=HALT`, `shutdown=REBOOT`, `shutdown=POWEROFF`, and
  `guest_exit_observed=true` for reboot and poweroff.

Still missing:

- Nothing is missing for this exact shutdown/panic proof gate on commit
  `6b5319e`.
- Future kernel/runtime, workflow, or checker changes must rerun the opt-in
  disposable cloud `shutdown_panic_proof` workflow before carrying this proof
  forward. The halt phase remains `status-before-cleanup` because `hlt`
  intentionally stops the CPU without making QEMU exit.

Executable gate:

- Re-run the opt-in disposable cloud `shutdown_panic_proof` workflow mode after
  any future relevant change, download its status-only artifact, and pass
  `tools/check_shutdown_panic_proof.py /path/to/artifact`. The manifest must
  include `guest_exit_observed=true` for the reboot and poweroff phases.

- `GAP[HARDWARE_LIMITS] status=open category=hardware-limits gate=check_hardware_support_matrix.py evidence=support-matrix`

Current state:

- The supported target is BIOS x86 in QEMU with ATA PIO, FAT16, PS/2 keyboard,
  PS/2 mouse when present, PIT timing, VBE XRGB8888 LFB or VGA Mode 13h fallback,
  and optional SB16-compatible audio.
- `docs/hardware-support.md` is the scoped hardware/support matrix. Its
  machine-readable `SUPPORT[...]` rows mark BIOS boot, IDE/ATA PIO, FAT16, PS/2
  keyboard/mouse, PIT, VBE/VGA, and SB16 as claimed only inside the current QEMU
  device-model boundary.
- `boot/uefi/README.md` now records a contract-only UEFI scaffold with
  machine-readable `UEFI_BOOT[...]` prerequisites for a future PE/COFF entry,
  ESP/FAT load path, GOP framebuffer handoff, UEFI memory map, boot-services
  exit, ELF32-compatible kernel handoff, and separate opt-in build target.
  `tools/check_hardware_support_matrix.py` requires those rows to stay
  `status=unimplemented` and outside the current Makefile image path.
- The kernel now has a bounded, status-only PCI config-space table builder for
  the QEMU legacy PC target. `PCI_STATUS[...]` and `PCI_TABLE[...]` rows keep
  that proof scoped to bus 0, devices 0-31, functions 0-7. The smoke status
  exposes `pci=`, `pciprobe=`, `pcicount=`, `pcifirst=`, `pciid=`,
  `pciclass=`, `pcitable=`, `pcitabcap=`, `pcitabuse=`, `pcilast=`,
  `pciclassh=`, `pcimulti=`, `pciclsms=`, and `pciclsbr=` so a disposable
  cloud status artifact can be checked without claiming broad PCI enumeration.

Still missing:

- There is no UEFI boot path, AHCI/SATA native driver, USB input/storage stack,
  SMP, APIC/HPET coverage, general PCI enumeration, broad VBE mode matrix, or
  proof on physical hardware. The PCI table is bounded to status-only bus-0
  discovery and does not make AHCI or USB usable.
- UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and physical hardware
  remain unclaimed `SUPPORT[...]` rows until a specific proof lane exists for
  each device class.

Executable gate:

- Run `python3 tools/check_hardware_support_matrix.py`. When a disposable QEMU
  status artifact is available, additionally run
  `python3 tools/check_hardware_support_matrix.py --status status.txt` to verify
  the bounded PCI status and table fields. Future device-class
  claims must add or update a `SUPPORT[...]` row, name the proof boundary, and
  add one host-checkable cloud, disposable-machine, or hardware proof before
  README, docs, runbooks, tests, or release notes describe that class as
  supported. Until then, claims should stay scoped to the current QEMU
  BIOS/IDE/PS2/VBE/SB16 target.

## Claim Boundary

Do not call the project Doom-capable from README, release notes, or comments just
because host tests pass. A playable claim requires at least:

- a current passing manual real-WAD cloud workflow pass for the exact commit
- `check_real_wad_proof.py` and `check_human_playability_proof.py` passing on the
  uploaded status artifacts
- `check_audio_continuity_proof.py` passing when audio/SB16 is part of the claim
- `doomrun=RUN`, `doomopen=OK`, `doomread=OK`, `gameplay=OK`, and all
  `doomfault*` fields cleared in those artifacts
- clean `usr=OK`, scripted `use`, mouse, audio baseline, and preemption evidence
  in the phase snapshots
- a remote human playtest or an explicit statement that only scripted
  cloud-safe playability has been proved
- no tracked WADs, standalone music/audio assets, disk images, rendered Doom
  pixels, or modified `third_party/doom` files
