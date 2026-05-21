# Proof And Gap Ledger

This is the canonical evidence log for vibe-os: what the automated and cloud
proofs have shown, what remains open, and what the project is allowed to claim.

## Post-Checkpoint Doom Gaps

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

- `docs/play.md` describes the safe human path: boot on a
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
- `docs/architecture.md` is the scoped hardware/support matrix. Its
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


## Playable Cloud Proof



The playable-Doom milestone is only proved when the cloud CI proof gates pass
without uploading WADs, disk images, framebuffer dumps, or rendered WAD pixels.
The intended proof is status-driven: the OS boots the validated shareware
`DOOM1.WAD`, Doom autostarts E1M1, QEMU injects deterministic keyboard and mouse
input through the same PS/2 device paths a human would use, Doom consumes those
events through the generic input queue, and the kernel exports
compact counters and state deltas from Doom.

This file describes the required green path. A scripted green run is not by itself a claim that the current branch is human-playable, and it is not enough
without the reviewed remote VNC bundle.

Latest current-head evidence is manual **Real WAD smoke** run `26206176284` on
`7390468`. It booted the validated shareware WAD and passed real-WAD gameplay,
scripted human-playability, scripted gameplay transition, VM/process, status
triage, and save/load persistence in the cloud run. The persistence artifact
triages as `persistence-proof-green`, with `first-boot`, `save-write`,
`reboot-load`, and `manifest/status` all passing: it wrote `DOOMSAV0.DSG` at
`25718` bytes, rebooted the same disk image, read the save payload back, closed
it, and returned to gameplay.
Persistence/save-load is now green for this current-head evidence lane.

That run is not a post-fix full-lane green run. Its audio lane failed under the
old checker with `musicrend= rendered sample delta must keep pace...`. After
the local checker was corrected to validate buffered music coverage, the
downloaded `26206176284` artifact passes `tools/check_audio_continuity_proof.py`
locally, so the run is current evidence for gameplay and persistence, plus a
known audio-checker false red. The VM/process checker has since become stricter
about user-probe dup/fd evidence (`uflags=`/`fdup=`), so that older artifact is
not a current VM/process proof under the latest checker. A fresh post-fix cloud
run is still required before claiming current-head full-lane green.

Previous full-lane green run `26205557019` on `bfd04e8` remains useful history:
it passed gameplay, scripted human-playability, gameplay transition,
VM/process, SB16 continuity, audible aggregate proof, artifact hygiene, status
triage, and save/load persistence. The matching push-triggered **OS smoke** run
`26205496796` on the same commit also passed the generated-WAD boot and
VM/process exec gates. Older green runs such as `26203744974` on `f9a688e`
remain useful repair history, but they are no longer the latest current-head
evidence.

Cloud triage still separates persistence failures into short-write,
malformed-stream, load-not-completed, checker/artifact mismatch, and green
write/load lanes. The older `Unknown tclass 112 in savegame` failure remains
historical repair context, not the current blocker. Current save-slot proof must
include the first boot's decoded save-write runtime gate plus the rebooted image
comparison and `--load-status` evidence that Doom read the full `DOOMSAV*.DSG`
payload back into gameplay, so changed save bytes alone do not count. A
human-facing playable claim still needs
a recorded remote VNC playtest bundle from `docs/play.md`, with
structured `human-playtest-notes-v2` notes, required operator confirmations,
per-phase status SHA-256 fields, a phase-by-phase
`human-playtest-session.json` transcript tied to the passing scripted run ID, a
`human-playtest-checklist.txt` review file with
`schema=human-playtest-checklist-v1`, a SHA-256
`human-playtest-manifest.json`, and the same non-WAD status checks passing
locally after download.

## Current-Head Dispatch

Before push, run the host-only readiness contract:

```sh
make playability-host-check
```

That target is intentionally QEMU-free on the local machine: it rebuilds the
synthetic image, runs host tests, repo hygiene/original-Doom provenance,
dynamic FAT persistence-image proof, cloud artifact/runbook contracts, play-now
script contracts, and whitespace checks before any cloud dispatch.

After push, dispatch the selected branch/ref with explicit guards so the job
fails early if GitHub Actions is pointed at the wrong branch:

```sh
branch=$(git branch --show-current)
gh workflow run os-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f shutdown_panic_proof=false
```

Then use the cloud-only dispatcher for the real-WAD lane you want. It refuses
local VM execution, accepts only an optional HTTP(S) WAD URL, and prints the
artifact download and triage commands:

```sh
python3 tools/run_cloud_playability.py --ref "$branch" --lane gameplay
python3 tools/run_cloud_playability.py --ref "$branch" --lane audio
python3 tools/run_cloud_playability.py --ref "$branch" --lane persistence \
  --save-slot 0
```

`gameplay` is the fastest proof path. `audio` enables the temporary remote WAV
reduction to `audio-proof.json`. `persistence` intentionally leaves
`audible_audio_proof=false` so save/load failures are isolated from audio
flakes while the kernel FAT/save path is moving.
Downloaded artifacts now print explicit failure lanes: gameplay/input, SB16
continuity, audible audio aggregate when requested, and persistence/save-load
when requested. Keep those boundaries intact when deciding what the current
branch actually proves.
The reboot persistence proof is skipped when the first real-WAD boot step fails,
because a second boot cannot prove save/load until the primary boot has produced
usable status snapshots.
When persistence fails before a top-level copy step runs, the artifact still
includes mirrored phase status and triage text such as
`status.persistence-write.status.save-slot-0.txt`; WADs, disk images, pixels,
and raw audio remain excluded.

When you want the helper to wait and pull the allowlisted status artifact:

```sh
python3 tools/run_cloud_playability.py --ref "$branch" --lane persistence \
  --save-slot 0 \
  --wait \
  --download-artifacts "build/cloud-run-persistence"
```

For existing runs, prefer the reproducible inspection form. `--lane auto`
infers the lane from the downloaded allowlisted files: `audio-proof.json`
selects the audio gate, `status.persistence*.txt` selects the persistence gate,
and both together select the combined gate. `--checker-ref run` checks out a
detached copy of the exact run commit under `build/cloud-checkers/`, so the
download is judged by the checker/ref that produced the cloud proof even if the
local shared worktree has moved on:

```sh
python3 tools/run_cloud_playability.py --run-id "$GITHUB_RUN_ID" \
  --lane auto \
  --checker-ref run \
  --download-artifacts "build/cloud-run-$GITHUB_RUN_ID" \
  --write-audit-log "build/cloud-run-$GITHUB_RUN_ID/cloud-playability-audit.json"
```

The helper prints the `gh run view` metadata command, run URL/status/conclusion
fields when available, the detached checker checkout command, the artifact
download command, the checker command, and the status triage command. That is
the intended agent handoff surface; avoid reconstructing those commands from
Actions logs by hand. The optional audit JSON uses
`schema=cloud-playability-audit-v1` and records the selected repo/ref, lane,
workflow/artifact name, no-local-VM and artifact policy, run metadata when
available, detached checker ref/worktree, download directory, checker command,
triage command, and the printed failure-lane block so a later reviewer can
replay exactly what was checked.

Manual equivalent commands are still:

```sh
gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=false \
  -f persistence_proof=false

gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=true \
  -f persistence_proof=false

gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=false \
  -f persistence_save_slot=0
```

For a downloaded non-persistence gameplay/audio proof artifact, require both
machine-checkable manifests:

```sh
python3 tools/check_cloud_playability_artifacts.py \
  path/to/real-wad-smoke-status \
  --require-gameplay-proof \
  --require-audible-proof
```

Once `.github/workflows/real-wad-soak.yml` is present on the repository default
branch, run the repeated proof:

```sh
branch=$(git branch --show-current)
python3 tools/run_cloud_playability.py --ref "$branch" --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3
```

## Deterministic Script

The manual **Real WAD smoke** workflow runs this input script after Doom has had
time to settle:

```text
after-start:wait=2,snapshot
after-fire:hold=ctrl:800,wait-status-min=pflags:000000C5:80:2,wait=1,snapshot
after-move:hold=up:1200,wait-status-min=pdelta:00000001:80:2,wait=1,snapshot
after-use:hold=spc:3000,snapshot,wait=2
after-mouse:mousebtn=1,wait=1,mouse=4:0,wait=1,mousebtn=0,wait=1,mouse=64:0,wait-status-min=pangledelta:00000001:80:2,wait=1,snapshot
after-menu:esc,wait=2,snapshot
```

Keyboard phases use QEMU monitor `sendkey`; the mouse phase uses
`mouse_move`/`mouse_button` against the PS/2 auxiliary path. Each phase waits
for Doom to process ticks and captures a decoded status artifact. The final
status is captured after the menu phase. `tests/run_smoke_qemu.sh` still
supports the older `SMOKE_SENDKEYS` fallback, but `SMOKE_INPUT_SCRIPT` is the
deterministic playability path.
The mouse turn proof is status-only: the scripted mouse phase waits for
`pangledelta` to change after PS/2 mouse movement, then records the compact
phase snapshot without storing pixels or raw input logs.
The `after-start` snapshot is the clean pre-input checkpoint: the port starts
Doom directly in E1M1, the checker verifies it is already `GS_LEVEL`, and later
phases must mutate state from that baseline.

`tools/check_scripted_gameplay_proof.py` is the disjoint runtime-transition
gate for this script. It consumes only decoded status text, requires a clean E1M1 start
before scripted input, verifies cumulative key/player proof across fire, move,
use, mouse, and menu phases, and can write
`gameplay-proof.json` with schema `scripted-gameplay-proof-v1`. The manifest
contains status byte counts and SHA-256 hashes plus the compact transition
fields, not WAD bytes, disk images, framebuffer dumps, screenshots, or audio.
It also includes status-only performance diagnostics. Those diagnostics compare
`doompresent`, `dtick`, `inputdepth`, `musicpull`, audio safety counters, and
preemption counters across the same phase snapshots. A healthy proof reports
`os-pipeline-healthy`, which means the OS-side frame/timer/input/audio/scheduler
counters advanced without input drops or audio safety regressions. If a
Codespaces/noVNC play session still slows down while this verdict stays healthy,
triage should start with remote QEMU TCG/noVNC/display throughput rather than
assuming Doom is building an OS-side input queue.
The long-run cadence object is also status-only. It records `duration`,
`health`, normalized ratios, and per-phase windows such as `use->mouse`, plus a
`slowdown_triage.primary_lane` hint. A healthy long-run proof points first at
`remote-presentation-throughput`; input drops, audio underruns, or stalled
preemption instead point back at the corresponding OS-side status lane. The
single-run smoke artifact may be too short to prove this lane; the repeated
soak path is the preferred way to gather longer status cadence without
uploading WADs, disk images, pixels, raw status text, logs, or raw audio.

## Repeated Cloud Soak

The manual **Real WAD soak** workflow repeats the same cloud proof without
uploading WADs, disk images, logs, status text, rendered pixels, or raw audio.
Each attempt runs the real-WAD, scripted human-playability, and SB16 continuity
gates. When `audible_audio_proof=true`, each attempt must also reduce the
temporary QEMU WAV to aggregate audio metadata and delete the WAV before any
artifact upload.

The only uploaded soak artifact is JSON metadata:
`real-wad-soak-summary.json` plus per-attempt JSON files. The summary records
the requested attempt count, required pass threshold, pass/flake counts,
per-phase status SHA-256 hashes, compact status field summaries, gate outcomes,
and the artifact policy. It is intentionally not a replacement for the
single-run diagnostic artifact when a new failure needs deep triage.

To soak the branch you are currently testing, dispatch the workflow with an
explicit ref guard through the cloud-only helper:

```sh
branch=$(git branch --show-current)
python3 tools/run_cloud_playability.py --ref "$branch" --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3 \
  --wait \
  --download-artifacts "build/cloud-soak-audio"
```

For an existing **Real WAD soak** run, use `--soak` to download and validate
the JSON metadata artifact without guessing the original attempt count:

```sh
python3 tools/run_cloud_playability.py --run-id RUN_ID --soak \
  --download-artifacts "build/cloud-soak-RUN_ID"
```

`expected_ref` is an early workflow guard: it fails before toolchain install or
WAD fetch if the selected `workflow_dispatch` branch/ref is not the branch you
intended to prove. GitHub can only dispatch a workflow file that already exists
on the repository default branch, so branch-only edits to
`.github/workflows/real-wad-soak.yml` are limited to host-only contract
validation until that workflow file is present on the default branch.

A soak is green only when the configured threshold passes the same repeated
criteria every successful attempt: playability, input state changes, SB16
continuity, and optional audible aggregate proof. The default threshold requires
every attempt to pass; lowering `min_passes` is useful for measuring flakes but
records the failed attempts in the summary. Validate a downloaded soak artifact
locally with:

```sh
python3 tools/check_cloud_playability_artifacts.py \
  --soak-summary path/to/real-wad-soak-metadata
```

The manual equivalent remains:

```sh
gh workflow run real-wad-soak.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f attempts=3 \
  -f min_passes=3 \
  -f audible_audio_proof=true
```

## Non-Pixel Evidence

The cloud proof requires these status families:

- CPU/runtime health: `pg=ON`, `pmm=OK`, `vmm=OK`, `vmmhi=OK`, `libc=OK`,
  `c=OK`, `usr=OK`, `heap=OK`, `free>0`, and `ticks>0` prove the
  protected-mode kernel, memory managers, C runtime probes, heap, and PIT timer
  are alive in the smoke VM. The `vmmhva`/`vmmhpa`/`vmmhpt`/`vmmhfree` fields
  additionally show the high-half alias, backing frame, dynamic page table, and
  reclaimed table frame.
- Process/exec: `exec=OK`, `path=DOOM.ELF`, `uexec=OK`,
  `upath=USERPROB.ELF`, `abiexec=OK`, `abipath=ABIPROBE.ELF`,
  `abiprobe=OK`, `execsys=a/b/c/d/e/f`, `execerr=00000000`,
  `execres=00000000`, `target`, `entry`, `stack`, `argc`, `argv`, `envp`,
  `argv0`, `envp0`, `argvsrc=2`, `ppid`, `upid`, `uentry`, `doom=OK`, and
  `doomrun=RUN` show that the kernel loaded the boot probe and Doom through the
  exec resolver, ran the packaged ABI probe as a generic root `.ELF`, performed
  a syscall-driven Doom handoff, seeded the user ABI stack from the copied user
  vector, recorded process parent metadata, and left Doom running rather than
  merely validating bytes on disk. `procpool=`,
  `pidseq=`, `fdexec=`, `fdup=`, `wait=`, and `vmreap=` additionally show bounded
  process-slot reuse, PID generation movement, exec-time fd inheritance, a
  userland wait/reap proof, and child VM teardown during reap. The six
  `execsys`
  counters are attempts, successes, failures, handoffs, scheduled targets, and
  rollbacks.
- Storage/libc: `wad=OK`, `lmp=OK`, `doomopen=OK`, `doomread=OK`,
  `doomseek`, `doomsbrk`, `doommode`, `doomerr=00000000`,
  `doomerrno=00000000`,
  `doomexit=00000000`, `doomfault=00000000`, `doomfaultip=00000000`,
  `doomfaultv=00000000`, `doomfaulterr=00000000`, `fault=0/.../0`,
  `panic=NONE`, `shutdown=NONE`, and `doomlog` make
  WAD/FAT/syscall/process failures visible without uploading the WAD or disk
  image. On a Doom user fault, `doomfault` is CR2, `doomfaultip` is the
  faulting EIP, `doomfaultv` is the CPU exception vector, and `doomfaulterr`
  is the x86 error code. The compact `fault=` tuple records
  vector/error/eip/cs/esp/ss/cr2/pid/kind/state/last-syscall for the most
  recent fault frame. `panic=KEXC` is reserved for unhandled non-Doom kernel
  exceptions, and `shutdown=HALT`/`shutdown=REBOOT`/`shutdown=POWEROFF` mark
  intentional OS shutdown paths. Those shutdown/panic values only become proof
  when paired with the opt-in `shutdown-panic-proof.json` artifact and
  `tools/check_shutdown_panic_proof.py`; monitor `quit` cleanup does not count,
  and reboot/poweroff proof must observe QEMU exit from the guest request.
- Runtime: `gameplay=OK`, `gstate=00000000`, `gmap=00000101`, `gtic>0`, and
  `leveltime>0` prove the real engine reached E1M1 gameplay.
- Input pipeline: `inputqueue`, `inputpoll`, and `inputlast` expose the generic
  queue path used by Doom. `keyirq`, `keyqueue`, and `keypoll` increase from the
  early snapshot through the fire, movement, use, and menu snapshots, while
  `keyseen` and `keylast` prove the scripted Up/Ctrl/Space/Escape keys were the
  keys Doom consumed through `SYS_POLL_INPUT`.
- Player/action deltas: `pflags` records cumulative player, movement, attack,
  use, menu, position-delta, ammo-delta, refire, and turn observations;
  `pdelta>0`
  and a changed `ppos` between `status.after-start.txt` and
  `status.after-move.txt` prove the player moved in Doom state, not only that a
  key was delivered. The raw `pammo`/`prefire` fields must also change across
  the fire phase, so Ctrl cannot pass as a key counter or cumulative flag alone.
- Mouse turn proof: `status.after-mouse.txt` must include both PS/2 mouse
  IRQ/packet/generic-poll counters, the `pflags` turn bit, and a raw `pangle` /
  `pangledelta` change from Doom gameplay state. The runtime sets the turn bit
  from Doom's live `ticcmd.angleturn` when sampled, or from a durable
  player-angle delta after Doom has applied the command, so mouse proof cannot
  pass on kernel delivery alone.
- Menu state: `status.after-start.txt` must have the menu bit clear, and
  `status.after-menu.txt` plus final `gflags` must have it set after Escape,
  proving the scripted input toggled Doom UI state while remaining in
  `GS_LEVEL`.
- Visual presence without pixels: `doompal`, `doomframe`, `doomnonzero`,
  `doomcolors`, and `doomsamp` summarize palette/frame activity without
  uploading `gfx.bin` or any rendered frame bytes. `fb`, `fbpolicy`, `fbgeom`,
  and `fbdirty` prove whether the run used Mode 13h, aspect-correct integer LFB
  scaling (`ASP`), or the labeled square fallback (`SQ`), plus the centered
  viewport and changed source bounds.
- Doom timer proof: `dtick` is the kernel's 35 Hz Doom time conversion and must
  equal `floor(ticks * 35 / 100)`, so the real-WAD checker can distinguish PIT
  progress from Doom's expected tic rate.
- Audio/mouse observability: `audio`, `adev`, `pcm`, `pcmbuf`, `doomsound`,
  `sfxmix`, `sfxdma`, `voices`, `sfxvoices`, `musicvoices`, `musicmix`,
  `musicloop`, `musicpos`, `musicbuf`, `musicunder`, `musicdrops`, `musicrend`,
  `sb16`, `dma`, `play`, `voiceq`, `musicq`, `audioirq`, `ack8`,
  `ack16`, `refill`, mixer safety counters, `mouse`,
  `mouseirq`, `mousepkt`, and `mousepoll` are required to be present and
  well-formed. The automated mouse phase requires `mouse=OK` and proves IRQ12,
  packet decode, and Doom generic-input consumption increased without
  uploading pixels.
  `tools/check_audio_continuity_proof.py` is the stricter SB16 path: it compares
  the phase snapshots using status snapshots only, requires `audio=SB16`,
  proves the generic audio device/PCM ring contract through `adev=`, `pcm=`, and
  `pcmbuf=`, and proves SB16 version, DMA programming, playback start, voice
  queue, IRQ/refill, non-music SFX, `sfxdma=` SFX bytes from the IRQ-driven DMA
  refill mixer, music mixing, kernel-visible `musicpos=` progress, and
  pull-requested music chunk service with advancing `musicpull=` counters plus
  `musicrend=` renderer provenance progressed without
  uploading audio samples. It does not upload audio samples.
  `tools/check_audio_continuity_proof.py` checks status snapshots only and
  does not upload audio samples.
- Optional audible-output proof: when the manual workflow is run with
  `audible_audio_proof=true`, QEMU uses a temporary WAV backend on the
  disposable runner, `tools/check_audible_audio_proof.py` reduces that file to
  aggregate `audio-proof.json`, and the workflow deletes the WAV before upload.
  The manifest proves non-silent remote audio output tied to the final
  `audio=SB16` status counters and the same status-only SB16 continuity gate.
  It fails if the music path moves but non-music `sfxmix=` or IRQ-refill
  `sfxdma=` does not progress, and it does not upload the WAV or any captured
  samples.
- Scheduler proof: `preempt`, `pirq`, `pattempt`, `pskip`, `puser`, `pround`,
  `pctx`, `pmask`, `pfrom`, `pto`, `pkind`, `peip`, `pcr3`, `pkstk`, `pspin`, and
  `pself=OK` expose live PIT preemption. A valid proof requires `pirq` to match
  `preempt`, Ring 3 timer IRQs, switches in both directions between Doom and
  the preempt probe, a switch between different PIDs, Doom/preempt probe kinds,
  nonzero source/target EIPs, distinct Doom/preempt-probe CR3s, distinct
  Doom/preempt-probe kernel stacks, and a `pspin` value beyond the seeded
  `50524545` magic from the alternate Ring 3 preempt probe.

`tools/check_vm_status_proof.py` is the legitimacy ratchet for the VM/process
status fields. It requires `vmmhfree` to match the reclaimed `vmmhpt` frame,
`uexec=OK`/`upath=USERPROB.ELF` for the boot probe,
`abiexec=OK`/`abipath=ABIPROBE.ELF`/`abiprobe=OK` for the generic ABI probe,
`argvsrc=2` for the Doom exec path, `procpool=`/`fdexec=`/`fdup=`/`wait=`/`vmreap=`
for bounded process-slot reuse, exec-time fd inheritance, the wait/reap proof,
and child VM teardown during reap, and
`pmask` plus `pkind`/`peip`/`pcr3`/`pkstk` to cross the Doom/preempt-probe tasks,
user windows, address spaces, and kernel stacks in both directions during timer
IRQ preemption.

`tools/check_real_wad_proof.py` gates the real-WAD status on both the non-pixel
visual proof and the scripted playability proof, plus the system/process/storage
debug contract above. A final status line by itself is not sufficient: the gate
uses `status.after-start.txt` as the post-Doom-start baseline and requires the
start, fire, movement, use, mouse, and menu snapshots so
keyboard and mouse counters plus Doom action flags and position/ammo/menu state
can be compared across the scripted phases. It rejects
duplicate fields, malformed hex, weak synthetic exec counters, Doom error
strings, failed self-tests, and status lines that only prove a boot banner.
`tools/check_vm_status_proof.py` is the executable VM/process status gate for
the paging, exec, and preemption fields in that debug contract.
`tools/check_human_playability_proof.py` can also compare the phase snapshots
directly.
`tools/check_scripted_gameplay_proof.py` is stricter about ordering than the
general playability checker: `status.after-start.txt` must be a clean E1M1
new-game state with no scripted key bits, no action proof flags, no menu bit,
and `pdelta=00000000`; later snapshots must retain cumulative key/player proof
bits rather than merely showing a final aggregate. It then requires movement to
change `ppos`, the mouse phase to advance IRQ/packet/poll counters and set
Doom gameplay turn proof bit while retaining button/motion proof, and
Escape to flip the menu bit while the game remains in `GS_LEVEL`.
The same manifest's performance diagnostics distinguish remote presentation
slowdown from OS pressure: `os-input-backlog` or `os-input-loss` points at
generic input drain/drop trouble, `os-audio-pressure` points at SB16 refill or
mixer pacing, `os-preemption-stalled` points at timer scheduling, and
`os-pipeline-healthy` means those OS-side counters stayed healthy even if
noVNC felt slow.

## Safe Remote Runbook

1. Open the **Real WAD smoke** workflow in GitHub Actions and run it manually.
   Leave `wad_url` empty to use `REAL_DOOM_WAD_URL` or the public shareware
   fallback, or provide a temporary URL to `DOOM1.WAD`, `DOOM1.WAD.gz`, or a zip
   containing `DOOM1.WAD`.
2. Confirm the fetch step prints the expected shareware v1.9 size and SHA-1.
   The workflow rebuilds with `DOOM_WAD=/tmp/DOOM1.WAD` and deletes that local
   WAD after the post-smoke validation.
3. Review `status.early.txt`, `status.after-start.txt`,
   `status.after-fire.txt`, `status.after-move.txt`, `status.after-use.txt`,
   `status.after-mouse.txt`, `status.after-menu.txt`, and `status.txt` in the
   uploaded diagnostic artifact. These are text status files, not framebuffer
   or WAD artifacts. The same artifact should include `doom.symbols` so
   `tools/triage_cloud_status.py` can symbolize `doomfaultip` if Doom reaches
   user mode and faults.
   The real-WAD checker consumes them like this. The audible checker applies
   only when `audible_audio_proof=true` produced `audio-proof.json`:

   ```sh
   python3 tools/check_real_wad_proof.py \
     --baseline build/status.after-start.txt \
     --start build/status.after-start.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --mouse build/status.after-mouse.txt \
     --menu build/status.after-menu.txt \
     build/status.txt

   python3 tools/check_scripted_gameplay_proof.py \
     --start build/status.after-start.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --mouse build/status.after-mouse.txt \
     --menu build/status.after-menu.txt \
     --write-json build/gameplay-proof.json \
     build/status.txt

   python3 tools/check_vm_status_proof.py \
     --require-exec \
     --require-preempt \
     build/status.txt

   python3 tools/check_audio_continuity_proof.py \
     --require-pull-stream \
     --baseline build/status.after-start.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --menu build/status.after-menu.txt \
     build/status.txt

   python3 tools/check_audible_audio_proof.py build/audio-proof.json
   ```

4. Treat the run as playable-cloud-proof green only when the QEMU capture step
   finishes, the gameplay/input/audio checker steps pass, and
   `tools/check_cloud_playability_artifacts.py --require-gameplay-proof`
   accepts the downloaded artifact. If `audible_audio_proof=true`, also require
   `--require-audible-proof`.
   That artifact gate rejects WAD/disk/image/pixel filenames, duplicate required
   status basenames, and renamed WAD/disk/image payload signatures. The workflow
   intentionally keeps proof assertions in the checker steps so a failed cloud
   boot still uploads status files and prints the exact failing fields.

This is still not a substitute for a human visually playing Doom, but it is a
stronger cloud-safe proxy: it proves real-WAD boot, level progression, input
delivery, player movement, fire/use commands, and menu control through the same
kernel/port paths a human session uses.

For a live human session, use the Remote Doom Playtest Runbook in
`docs/play.md`. That path keeps QEMU on a disposable
remote host, connects through VNC over SSH, and uses
`tools/collect_human_playtest_bundle.py --capture-phase` on the remote host to
capture each named status phase from the QEMU monitor without keeping
`status.*.bin`, then uses the same collector to build an allowlisted proof
bundle before download. The bundle is then validated with
`tools/check_cloud_playability_artifacts.py --human-session`, including
`human-playtest-notes.txt`, `human-playtest-checklist.txt`,
`human-playtest-session.json`, and `human-playtest-manifest.json`, without
storing WAD data, disk images, audio captures, or rendered pixels in the repo.
The session transcript records the linked passing real-WAD run ID, exact phase
order, operator confirmations, per-status byte counts, SHA-256 hashes, and
compact status summaries; the notes also carry `phase_hash_early` through
`phase_hash_final` so the checker can compare the human note hashes against the
downloaded status files. The generated checklist records the post-download
review commands and the phase hashes, and the manifest ties the notes,
checklist, session transcript, and diagnostics to exact byte counts and SHA-256
hashes. The manifest records `requires_post_download_verification=true`, and
the local checker prints a `post-download human verification OK` line with
`session_id`, `bundle_sha256`, `manifest_sha256`, and short phase hashes to
compare against the remote collector's `pre-download human verification OK`
line.

## Cloud Triage

Use `tools/run_cloud_playability.py --lane gameplay`, `--lane audio`, or
`--lane persistence --save-slot 0` to rerun only the red proof lane. For a
downloaded `real-wad-smoke-status` artifact, run
`tools/triage_cloud_status.py build/status.txt` first, then the actual proof
checkers. Status/proof tools should parse status text through
`tools/status_fields.py` so composite fields such as `execsys=a/b/c/d/e/f` stay
intact and duplicate `key=value` fields fail loudly.

The classifier names the first repair lane with these stable labels:
`exec-not-attempted`, `exec-failed`, `doom-user-fault`, `kernel-panic`,
`os-shutdown-requested`, `ata-storage-stalled`, `missing-wad-open-read`,
`persistence-save-write-failed`, `persistence-save-growth-allocation-partial`,
`persistence-load-malformed-stream`, `persistence-load-not-completed`,
`doom-init-stalled`, `frames-no-gameplay`, `input-no-effect`,
`doom-timer-not-proven`, `preemption-not-proven`,
`long-run-cadence-not-proven`, `artifact-proof-failure`, and
`playability-status-green`.

`ata-storage-stalled` covers `atawait=BUSY`, `atawait=DRQ`, `atawait=READY`, or `atawait=DATA`
before Doom frames, or nonzero `atafail` / `atatmo`; use `ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo` for detail.
If `doomrun=RUN`, WAD I/O is green, and input/audio/preemption counters active,
proof gates can still fail on snapshot-baseline details such as
`usr=OK` consistency, scripted `use` phase progression, mouse baseline/effect evidence,
audio baseline continuity, or missing early/start/fire/move/use/
mouse/menu snapshots. Read the checker error literally before changing kernel
code.

For slowdown-specific evidence, prefer the status-only cadence lane before
guessing from noVNC feel:

```sh
python3 tools/run_cloud_playability.py --ref "$branch" --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3 \
  --wait \
  --download-artifacts "build/cloud-soak-audio"
```

The downloaded soak summary contains per-attempt `status_cadence` entries copied
from `gameplay-proof.json`. For a single downloaded smoke artifact, rerun the
scripted checker with `--require-long-run-cadence` only if the input script
captured a long enough pre-menu window; otherwise treat
`long-run-window-too-short` as an evidence gap and use the soak lane.

Shutdown and panic claims are separate from normal playability. The opt-in
`shutdown_panic_proof` lane must be validated with
`tools/check_shutdown_panic_proof.py`; a QEMU monitor cleanup or ordinary failed
boot is not guest halt/reboot/poweroff evidence.
