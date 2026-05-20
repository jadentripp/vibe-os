# Test Strategy

The test suite is layered so low-level changes get fast feedback before a VM
boot:

- `make test` runs host-side artifact checks for the boot sectors, ELF files,
  FAT16 disk image, WAD fixture, and build/source contracts.
- GitHub Actions then runs `make ALLOW_LOCAL_VM=1 smoke` and verifies the
  booted VGA status line.
- Future Doom bring-up should add focused libc-test cases, Doom WAD/parser
  golden tests, and deterministic frame checksums once framebuffer output
  exists.

Local `make test` does not launch QEMU.
