# Test Strategy

The test suite is layered so low-level changes get fast feedback before a VM
boot:

- `make test` runs host-side artifact checks for the boot sectors, ELF files,
  FAT16 disk image, WAD fixture, and build/source contracts.
- `tests/host/test_framebuffer_contract.py` proves the 320x200 indexed shadow,
  RGB palette to XRGB8888 conversion, 2x scaling, and centering contract without
  using rendered Doom pixels.
- GitHub Actions then runs `make ALLOW_LOCAL_VM=1 smoke` and verifies the
  booted VGA status line.
- The manual **Real WAD smoke** workflow can run without a private secret: it
  accepts a WAD URL input, otherwise tries `REAL_DOOM_WAD_URL`, otherwise uses a
  public Archive.org gzipped shareware WAD. The runner validates the extracted
  `DOOM1.WAD` SHA-1 and size before building with `DOOM_WAD`, then requires
  `gameplay=OK`, `gmap=00000101` (E1M1), `leveltime>0`, `doompresent>0`, a key
  event, and no known Doom startup error strings in the decoded status artifact.
  QEMU is bounded by a smoke-level timeout and writes status, monitor, smoke,
  QEMU, and serial logs while keeping WADs, disk images, framebuffer dumps, and
  rendered Doom pixels out of uploaded artifacts.
- `tools/check_real_wad_proof.py` is the source-level truth-serum gate for that
  real-WAD status proof. Host tests assert that the GitHub workflow and smoke
  target invoke it, so a future green CI claim must include those non-pixel
  status counters.
- Still manual: actually launching the manual workflow, reviewing its uploaded
  diagnostics, and deciding whether the current visual/input/audio state is good
  enough to call the OS Doom-capable.
- Future Doom bring-up should add focused libc-test cases, Doom WAD/parser
  golden tests, and deterministic frame checksums once framebuffer output
  exists.

Local `make test` does not launch QEMU.
