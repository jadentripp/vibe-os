# Test Strategy

The test suite is layered so low-level changes get fast feedback before a VM
boot:

- `make test` runs host-side artifact checks for the boot sectors, ELF files,
  FAT16 disk image, WAD fixture, and build/source contracts.
- Boot/loader/VM contract tests compare the Stage 1 and Stage 2 raw-LBA
  constants, Makefile byte guards, image-builder layout, generated `disk.img`
  boot regions, protected-mode Stage 2 ELF handoff, and user/supervisor paging
  boundaries without launching QEMU. They also pin the higher-half seed contract:
  `vmm_map_page` can allocate a missing page table from PMM and the VMM self-test
  maps a high non-identity alias before unmapping it, after which an empty
  PMM-backed page-table frame is reclaimed. The smoke contract exposes that as
  `vmmhi=OK`, `vmmhva=`, `vmmhpa=`, `vmmhpt=`, and `vmmhfree=`.
- `tests/host/test_doom_source.py` is the original-Doom provenance gate. It
  hashes the vendored `linuxdoom-1.10` source boundary, audits the Makefile so
  original engine objects and `doom_port/*` shims stay separate, and invokes
  `tools/check_repo_hygiene.py` to reject tracked WADs, disk images, rendered
  pixel artifacts, logs, wrapper/source-port paths, dirty `third_party/doom`
  worktree state, renamed raw/gzip/zip/tar WAD payloads, and runtime/build
  references to shortcut source ports or host display/audio APIs. `.gitignore`
  is checked for the common WAD archive, screenshot/pixel, disk-image, log, and
  raw-audio spillover patterns so accidental local proof output is harder to
  stage.
- Host storage tests cover root-level 8.3 lifecycle behavior: create, readback,
  sparse growth, truncate/resize-to-zero, delete, cluster-chain freeing/reuse,
  corrupt-chain validation before mutation, FAT-copy agreement,
  duplicate-root/cross-link/orphaned-cluster rejection, protected WAD/ELF
  refusal, and syscall-backed `unlink`/`stat`/`fstat` libc wrappers. They also
  pin kernel rejection of unknown `open` flags, `EMFILE` fd exhaustion, and the
  Doom-only `c:\doomdata` `mkdir` shim.
- `tests/host/test_doom_persistence_image.py` and
  `tools/check_doom_persistence_image.py` prove the non-QEMU image-inspection
  path for Doom defaults and saves: `DEFAULT.CFG` must contain complete
  Doom-shaped defaults markers, and `DOOMSAVN.DSG` must carry Doom's save
  description, `version 110` header, plausible game-state bytes, and enough
  payload to rule out tiny fake headers. With `--baseline-image`, requested
  entries must also differ from the fresh pre-boot image; reboot comparison
  requires that fresh baseline plus a clean `--reboot-status` runtime/fault gate
  before it can claim persistence. Rebooted `DOOMSAVN.DSG` proof additionally
  requires `--save-write-status` from the write boot, proving Doom reported file
  output and a close before the mutated save bytes count, plus `--load-status`
  from the reboot/load boot proving Doom read the full save payload back into
  matching gameplay. The checker also
  rejects storage leaks where allocated FAT clusters are not owned by exactly
  one live root entry.
- Host process tests prove that `SYS_EXEC` is more than a fixed string loader:
  the path resolves Doom/probe table entries, parses arbitrary root-level FAT16
  `.ELF` names into the reusable probe-class slot, rejects unsafe active-slot
  reloads, seeds a scheduler-visible target context, writes an argc/argv stack
  shape, records `argvsrc=2` for a copied user vector, patches the live syscall
  frame, marks the caller exited, and records handoff/schedule/rollback
  counters. The same tests pin the bounded
  `waitpid` child scan/reap path, `WNOHANG` live-child result, fd owner
  enforcement, exec-time inheritance/close-on-exec handoff, and process-owned
  fd teardown. They also cover anonymous brk-backed `mmap` accounting and
  page-aligned tail `munmap` reclaim plus non-tail validation holes, without
  claiming that `fork`, descriptor duplication, or reusable VM objects exist
  yet.
- `tools/check_vm_status_proof.py` requires the matching cloud status to expose
  `vmmhfree`, `argvsrc=2`, and `peip` evidence before a VM/process artifact can
  be accepted.
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
  nontrivial visual status hashes/counters, scripted start/fire/use/move/mouse/menu
  input status, a key event, and no known Doom startup error strings in the decoded
  status artifact.
  QEMU is bounded by a smoke-level timeout and writes status, monitor, smoke,
  QEMU, and serial logs while keeping WADs, disk images, framebuffer dumps, and
  rendered Doom pixels out of uploaded artifacts.
- `tools/check_real_wad_proof.py` is the source-level truth-serum gate for that
  real-WAD status proof. It now validates the wider debug contract too:
  VM/kernel health, syscall exec counters, FAT/WAD file access, Doom runtime
  counters, audio/mouse telemetry fields, live scheduler-preemption proof, and
  non-pixel visual summaries. It requires the early/start/fire/move/use/mouse/menu status
  snapshots as well as the final status, so a single good-looking final line
  cannot stand in for scripted input proof. Host tests assert that the GitHub workflow and
  smoke target invoke it, so a future green CI claim must include those status
  counters rather than framebuffer bytes.
- `tools/check_vm_status_proof.py` separately gates the VM/process status
  fields used by cloud artifacts, including higher-half VMM self-test,
  syscall-driven exec handoff, and timer preemption evidence.
- `tools/check_human_playability_proof.py` compares decoded status snapshots
  from the deterministic input phases. It requires keyboard counters to
  increase across each keyboard phase, mouse IRQ/packet/poll counters to
  advance during the mouse phase, Doom to remain in E1M1 gameplay, `keyseen` to
  record Up/Ctrl/Space/Escape, player movement/action/menu flags to be set,
  `pdelta>0`, `ppos` to change after the movement phase, fire to change
  ammo/refire state, the mouse phase to set Doom's gameplay turn proof bit from
  `ticcmd.angleturn` or the resulting player-angle delta, and Escape to flip the
  menu bit without reading WAD or framebuffer artifacts.
- `tools/check_audio_continuity_proof.py` is the remote-safe SB16 audio gate. It
  compares the same decoded status snapshots, requires `audio=SB16`, and proves
  IRQ/refill, non-music SFX, music mixing, `voiceq=` stream-update counters,
  and kernel-visible `musicpos=` progress without storing audio samples. This
  is still not a full hardware-paced MUS/MIDI pull-stream proof.
- `tools/check_audible_audio_proof.py` is the optional remote audible-output
  gate. In cloud it analyzes a temporary QEMU WAV capture into aggregate
  `audio-proof.json`, validates non-silent duration/window/RMS/peak metrics tied
  to the final `audio=SB16` status plus the same status-only SB16 continuity
  snapshots, and keeps raw audio out of artifacts.
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
- `tools/check_hardware_support_matrix.py` parses
  `docs/hardware-support.md` so README/docs/runbook/test language stays bounded
  to the QEMU BIOS/IDE/PS2/VBE/SB16 device-model proof. It rejects unsupported
  UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and physical-hardware
  support wording unless the matrix grows a claimed row and a proof boundary
  first.
  It also requires the kernel's bounded QEMU bus-0 PCI status scan and the
  `pci=`, `pciprobe=`, `pcicount=`, `pcifirst=`, `pciid=`, and `pciclass=`
  smoke fields to remain status-only diagnostics rather than a broad PCI claim.
  Future hardware classes now have machine-readable `PROOF_REQUIREMENT[...]`
  rows plus active `NEGATIVE_CLAIM[...]` rows, so unsupported UEFI, PCI, AHCI,
  USB, SMP, APIC, HPET, and physical-machine wording stays tied to a concrete
  future proof instead of becoming advertising copy.
  The same checker pins `NEXT_UNLOCK[PCI_ENUMERATION]` as the next hardware
  class to implement before AHCI or USB can honestly move forward.
  It also checks the contract-only `boot/uefi/README.md` scaffold: each
  `UEFI_BOOT[...]` row must stay unimplemented with no evidence, and `boot/uefi`
  must stay out of the current Makefile image path until a separate opt-in UEFI
  build exists.
- `tools/check_vm_safety_contract.py` machine-checks the local-QEMU opt-in,
  cloud diagnostic upload hygiene, panic status fields, shutdown status fields,
  guard-page helper, dynamic high VMM mapping/reclaim, and brk-backed tail
  `munmap` contract without launching QEMU.
- `tools/check_vm_status_proof.py` validates cloud status artifacts for the VM
  legitimacy fields: `vmmhfree` must match the reclaimed dynamic page table,
  Doom exec must report `argvsrc=2`, and `peip` must show timer IRQ switching
  between Doom and the preempt probe.
- `tools/check_shutdown_panic_proof.py` validates the opt-in disposable-cloud
  shutdown/panic proof contract and any downloaded proof artifact. It requires
  `shutdown-panic-proof.json` plus dedicated panic, halt, reboot-request, and
  poweroff-request status files, rejects missing status or monitor-quit-only
  evidence, and requires observed guest exit for reboot/poweroff phases.
- `tools/check_cloud_playability_artifacts.py` validates the remote human-run
  runbook, workflow upload hygiene, expected non-WAD diagnostic files, and
  downloaded real-WAD status artifacts without requiring a WAD or local QEMU.
  The docs it checks must keep a `Current-head cloud proof state` note plus the
  explicit `gh workflow run os-smoke.yml`, `real-wad-smoke.yml`, and soak
  dispatch commands, so host-only changes cannot masquerade as cloud proof.
  The repo contract also locks the repeated **Real WAD soak** workflow's
  `expected_ref` branch guard and default-branch dispatch limitation docs.
  It rejects forbidden filenames, duplicate required basenames, unexpected ELF
  binaries, raw audio files, compressed WAD archives, and renamed WAD/disk/image/audio payload
  signatures. In `--human-session` mode it also requires
  `human-playtest-checklist.txt`, `human-playtest-session.json`, and
  `human-playtest-manifest.json`, requires a flat allowlisted bundle, rebuilds
  the human phase transcript from the status files and notes, verifies every
  note-level `phase_hash_*` value, verifies the generated checklist and bundle
  inventory SHA-256 hashes, and prints a stable post-download verification ID
  for comparison with the remote collector output. If `audio-proof.json` is
  present, it validates that aggregate manifest too.
- `tools/collect_human_playtest_bundle.py` is the remote-host helper for manual
  VNC sessions. It does not launch QEMU; it copies only allowlisted status/log
  diagnostics and required ELF/symbol files from the disposable host build
  directory, requires explicit `--confirm-*` operator flags, writes structured
  `human-playtest-notes.txt` with phase status hashes, a
  `human-playtest-checklist.txt` review file, a `human-playtest-session.json`
  transcript tied to the passing scripted real-WAD run ID, and
  `human-playtest-manifest.json`, refuses proof output inside the repo, and
  immediately invokes
  `tools/check_cloud_playability_artifacts.py --human-session`.
- `tools/run_remote_human_playtest.sh` is the faster guided wrapper for that
  same remote-only human path. It refuses macOS, does not launch QEMU, prompts
  the playtester through the eight required Doom phases, calls the collector's
  `--capture-phase` helper for each status snapshot, builds
  `/tmp/vibe-os-human-proof.tgz`, and prints the local post-download checker
  commands. The normal remote invocation is
  `tools/run_remote_human_playtest.sh --playtester NAME --scripted-proof-run-id RUN_ID`.
- `tools/play_now_codespaces.sh` is the one-command disposable play launcher.
  It is safe to run from the Mac because it only drives GitHub Codespaces with
  `gh`: create or reuse a disposable Codespace, start
  `tools/play_now_remote.sh` inside it, mark noVNC port `6080` private, and
  print/open the noVNC URL. It must not run QEMU locally or copy WAD, disk,
  pixel, screenshot, log, or raw-audio artifacts back from Codespaces.
- `.github/workflows/cloud-play-now-preflight.yml` is the manual cloud dry-run
  for the play host shape. It installs the remote dependencies on
  `ubuntu-latest`, runs `tools/play_now_remote.sh --preflight --require-novnc`,
  checks the safety contract, and exits before QEMU, WAD fetch, image build, or
  artifact upload.
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
