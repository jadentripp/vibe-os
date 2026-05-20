# Test Strategy

The test suite is layered so low-level changes get fast feedback before a VM
boot:

- `make test` runs host-side artifact checks for the boot sectors, ELF files,
  FAT16 disk image, WAD fixture, and build/source contracts.
- Boot/loader/VM contract tests compare the Stage 1 and Stage 2 raw-LBA
  constants, Makefile byte guards, image-builder layout, generated `disk.img`
  boot regions, protected-mode Stage 2 ELF handoff, and user/supervisor paging
  boundaries without launching QEMU.
- `tests/host/test_doom_source.py` is the original-Doom provenance gate. It
  hashes the vendored `linuxdoom-1.10` source boundary, audits the Makefile so
  original engine objects and `doom_port/*` shims stay separate, and invokes
  `tools/check_repo_hygiene.py` to reject tracked WADs, disk images, rendered
  pixel artifacts, logs, wrapper/source-port paths, dirty `third_party/doom`
  worktree state, and runtime/build references to shortcut source ports or host
  display/audio APIs.
- Host storage tests cover root-level 8.3 lifecycle behavior: create, readback,
  truncate, delete, cluster-chain freeing/reuse, protected WAD/ELF refusal, and
  syscall-backed `unlink`/`stat`/`fstat` libc wrappers. They also pin kernel
  rejection of unknown `open` flags, `EMFILE` fd exhaustion, and the Doom-only
  `c:\doomdata` `mkdir` shim.
- `tests/host/test_doom_persistence_image.py` and
  `tools/check_doom_persistence_image.py` prove the non-QEMU image-inspection
  path for Doom defaults and saves: `DEFAULT.CFG` must contain Doom-shaped
  defaults text, and `DOOMSAVN.DSG` must carry Doom's save description plus
  `version ...` header. With `--baseline-image`, requested entries must also
  differ from the fresh pre-boot image before a remote reboot run can claim
  persistence.
- Host process tests prove that `SYS_EXEC` is more than a FAT loader: the path
  rejects unsafe active-slot reloads, seeds a scheduler-visible target context,
  writes an argc/argv stack shape, patches the live syscall frame, marks the
  caller exited, and records handoff/schedule/rollback counters.
- `tests/host/test_framebuffer_contract.py` proves the 320x200 indexed shadow,
  RGB palette to XRGB8888 conversion, 2x scaling, and centering contract without
  using rendered Doom pixels.
- GitHub Actions then runs `make ALLOW_LOCAL_VM=1 smoke` and verifies the
  booted VGA status line.
- The manual **Real WAD smoke** workflow can run without a private secret: it
  accepts a WAD URL input, otherwise tries `REAL_DOOM_WAD_URL`, otherwise uses a
  public Archive.org gzipped shareware WAD. The runner validates the extracted
  `DOOM1.WAD` SHA-1 and size before building with `DOOM_WAD`, then requires
  `gameplay=OK`, `gmap=00000101` (E1M1), `leveltime>0`, `doompresent>0`,
  nontrivial visual status hashes/counters, scripted fire/use/move/mouse/menu
  input status, a key event, and no known Doom startup error strings in the decoded
  status artifact.
  QEMU is bounded by a smoke-level timeout and writes status, monitor, smoke,
  QEMU, and serial logs while keeping WADs, disk images, framebuffer dumps, and
  rendered Doom pixels out of uploaded artifacts.
- `tools/check_real_wad_proof.py` is the source-level truth-serum gate for that
  real-WAD status proof. It now validates the wider debug contract too:
  VM/kernel health, syscall exec counters, FAT/WAD file access, Doom runtime
  counters, audio/mouse telemetry fields, live scheduler-preemption proof, and
  non-pixel visual summaries. It requires the early/fire/move/use/mouse/menu status
  snapshots as well as the final status, so a single good-looking final line
  cannot stand in for scripted input proof. Host tests assert that the GitHub workflow and
  smoke target invoke it, so a future green CI claim must include those status
  counters rather than framebuffer bytes.
- `tools/check_human_playability_proof.py` compares decoded status snapshots
  from the deterministic input phases. It requires keyboard counters to
  increase across each keyboard phase, mouse IRQ/packet/poll counters to
  advance during the mouse phase, Doom to remain in E1M1 gameplay, player
  movement/action/menu flags to be set, and `pdelta>0` without reading WAD or
  framebuffer artifacts.
- `tools/check_audio_continuity_proof.py` is the remote-safe SB16 audio gate. It
  compares the same decoded status snapshots, requires `audio=SB16`, and proves
  IRQ/refill, SFX, and looped music-carrier counters progressed without storing
  audio samples. This is not a full MUS/MIDI song-position streaming proof.
- `tools/check_audible_audio_proof.py` is the optional remote audible-output
  gate. In cloud it analyzes a temporary QEMU WAV capture into aggregate
  `audio-proof.json`, validates non-silent duration/window/RMS/peak metrics tied
  to the final `audio=SB16` status, and keeps raw audio out of artifacts.
- `tests/host/test_post_checkpoint_gaps.py` guards the post-checkpoint honesty
  ledger: Doom exit/fault diagnostics, including CR2, EIP, vector, and x86
  error code, must stay visible in status, save/config persistence must be
  proved at image level, and the missing
  cloud boot, real gameplay, human playtest, audio, VM/POSIX,
  shutdown/panic, and hardware-limit claims must remain documented.
- `tools/check_playability_gap_ledger.py` parses the `GAP[...]` rows in
  `docs/post-checkpoint-gaps.md` so every open Doom-capability claim has a
  concrete category, executable gate, and evidence artifact before README text
  can call it done.
  It also requires the latest analyzed failed real-WAD run to stay documented
  until a newer current run replaces that evidence.
- `tools/check_vm_safety_contract.py` machine-checks the local-QEMU opt-in,
  cloud diagnostic upload hygiene, panic status fields, and shutdown status
  fields without launching QEMU.
- `tools/check_cloud_playability_artifacts.py` validates the remote human-run
  runbook, workflow upload hygiene, expected non-WAD diagnostic files, and
  downloaded real-WAD status artifacts without requiring a WAD or local QEMU.
  It rejects forbidden filenames, duplicate required basenames, unexpected ELF
  binaries, raw audio files, and renamed WAD/disk/image/audio payload
  signatures. If `audio-proof.json` is present, it validates that aggregate
  manifest too.
- `tools/triage_cloud_status.py` classifies a downloaded real-WAD status line
  into the first repair lane. The custom linker also writes `build/doom.symbols`
  so cloud artifacts can symbolize `doomfaultip` and decode page-fault/WAD I/O
  context without uploading Doom data or framebuffer pixels.
- `tools/check_vm_safety_contract.py` validates the safety rail: local QEMU
  targets must remain behind `ALLOW_LOCAL_VM=1`, host tests stay QEMU-free,
  cloud workflows upload only status/log diagnostics for proof lanes, and kernel
  `panic=` / `shutdown=` fields remain smoke-visible.
- `tools/prepare_shareware_wad.py` is covered with synthetic raw/gzip/zip WAD
  sources so the remote runbook's WAD extraction and validation path is tested
  without network access or real game data.
- Still manual: actually launching the manual workflow, reviewing its uploaded
  diagnostics, and deciding whether the current visual/input/audio state is good
  enough to call the OS Doom-capable.
- Future Doom bring-up should add focused libc-test cases, Doom WAD/parser
  golden tests, and stricter deterministic visual expectations once framebuffer
  output stabilizes.

Local `make test` does not launch QEMU.
