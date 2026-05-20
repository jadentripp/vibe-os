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
  pixel artifacts, logs, or wrapper/source-port paths.
- Host storage tests cover root-level 8.3 lifecycle behavior: create, readback,
  truncate, delete, cluster-chain freeing/reuse, protected WAD/ELF refusal, and
  syscall-backed `unlink`/`stat`/`fstat` libc wrappers.
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
  nontrivial visual status hashes/counters, scripted fire/use/move/menu input
  status, a key event, and no known Doom startup error strings in the decoded
  status artifact.
  QEMU is bounded by a smoke-level timeout and writes status, monitor, smoke,
  QEMU, and serial logs while keeping WADs, disk images, framebuffer dumps, and
  rendered Doom pixels out of uploaded artifacts.
- `tools/check_real_wad_proof.py` is the source-level truth-serum gate for that
  real-WAD status proof. Host tests assert that the GitHub workflow and smoke
  target invoke it, so a future green CI claim must include those non-pixel
  status counters rather than framebuffer bytes.
- `tools/check_human_playability_proof.py` compares decoded status snapshots
  from the deterministic input phases. It requires keyboard counters to
  increase, Doom to remain in E1M1 gameplay, player movement/action/menu flags
  to be set, and `pdelta>0` without reading WAD or framebuffer artifacts.
- Still manual: actually launching the manual workflow, reviewing its uploaded
  diagnostics, and deciding whether the current visual/input/audio state is good
  enough to call the OS Doom-capable.
- Future Doom bring-up should add focused libc-test cases, Doom WAD/parser
  golden tests, and stricter deterministic visual expectations once framebuffer
  output stabilizes.

Local `make test` does not launch QEMU.
