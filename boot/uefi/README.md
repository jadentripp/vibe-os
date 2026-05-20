# UEFI Boot Path Scaffold

This directory is a contract-only placeholder for a future UEFI boot path. It
does not contain a UEFI binary, a PE/COFF image, an EFI System Partition layout,
or a loader that can boot vibe-os today. SUPPORT[UEFI] remains unclaimed in
`docs/hardware-support.md`.

The current boot path is still the BIOS MBR plus raw-LBA Stage 2 loader described
in `docs/boot-loader-vm.md`. Future UEFI work must keep that path working unless
the project deliberately retires it, and must not describe vibe-os as
UEFI-bootable until each row below has real source, build, and proof evidence.

## Machine-Readable Contract

The `UEFI_BOOT[...]` rows are machine-readable. They describe prerequisites for
a future implementation; every row is intentionally `status=unimplemented`.

- `UEFI_BOOT[ENTRY] status=unimplemented requires=pe32-efi-application proof=future-host-build evidence=none`
- `UEFI_BOOT[ESP_STORAGE] status=unimplemented requires=fat-esp-kernel-read proof=future-host-build evidence=none`
- `UEFI_BOOT[FRAMEBUFFER] status=unimplemented requires=gop-boot-info proof=future-host-build evidence=none`
- `UEFI_BOOT[MEMORY_MAP] status=unimplemented requires=uefi-memory-map proof=future-host-build evidence=none`
- `UEFI_BOOT[EXIT_BOOT_SERVICES] status=unimplemented requires=exit-before-kernel-handoff proof=future-boot-run evidence=none`
- `UEFI_BOOT[KERNEL_HANDOFF] status=unimplemented requires=elf32-entry-compatible proof=future-boot-run evidence=none`
- `UEFI_BOOT[BUILD_INTEGRATION] status=unimplemented requires=separate-opt-in-target proof=future-host-build evidence=none`

## First Implementation Rules

- Produce an explicit UEFI application artifact rather than reusing the BIOS
  Stage 1 or Stage 2 raw-sector images.
- Read the kernel from an ESP/FAT path or another documented UEFI storage path;
  do not silently depend on the current raw LBA windows.
- Fill a boot-info handoff that preserves the existing kernel expectations for
  memory, framebuffer, and entry point data, or change those expectations with a
  matching host-checked contract.
- Call `ExitBootServices` before kernel entry and document which firmware
  services, if any, are still intentionally unavailable afterward.
- Add a host-only build/check target before any local VM proof, and keep local
  VM execution behind the existing opt-in safety rail.
- Keep WADs, disk images, screenshots, pixel dumps, raw audio, and VM logs out of
  git and out of default proof artifacts.
