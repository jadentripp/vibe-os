# Test Strategy

The test suite is layered so low-level changes get fast feedback before a VM
boot:

- `make test` runs host-side artifact checks for the boot sectors, ELF files,
  FAT16 disk image, WAD fixture, and build/source contracts.
- GitHub Actions then runs `make ALLOW_LOCAL_VM=1 smoke` and verifies the
  booted VGA status line.
- The manual **Real WAD smoke** workflow can run without a private secret: it
  accepts a WAD URL input, otherwise tries `REAL_DOOM_WAD_URL`, otherwise uses a
  public Archive.org gzipped shareware WAD. The runner validates the extracted
  `DOOM1.WAD` SHA-1 and size before building with `DOOM_WAD`, then requires Doom
  presentation and keyboard input evidence while keeping WADs, disk images, and
  rendered Doom pixels out of uploaded artifacts.
- Future Doom bring-up should add focused libc-test cases, Doom WAD/parser
  golden tests, and deterministic frame checksums once framebuffer output
  exists.

Local `make test` does not launch QEMU.
