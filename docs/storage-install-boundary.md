# Storage Install And Recovery Boundary

vibe-os currently mutates and reboots the repo-generated FAT16 image in cloud
QEMU. That is a real storage persistence proof, but it is not an installable
general OS on arbitrary disks.

The current storage proof starts from `tools/make_wad_image.py`: LBA 0 is the
repo MBR, LBA 1-16 is Stage 2, LBA 17-208 is the kernel ELF staging area, and
LBA 2048 is the FAT16 partition containing the protected WAD/ELF entries plus
root-level writable FAT16 files. The cloud workflow copies a fresh generated
image, boots it, lets Doom write `DEFAULT.CFG` or `DOOMSAV*.DSG`, reboots the
same image, and then proves the bytes survived and loaded back through the
runtime.

That boundary matters. The project does not partition a blank disk, does not
discover arbitrary existing partitions, does not install onto another layout,
does not repair corrupted user disks, and does not preserve an unknown disk's
existing contents. The host checker can inspect an install-image-manifest for
the generated image layout; it is a recovery/inventory aid for repo artifacts,
not an installer.

## Machine-Readable Boundary

- `STORAGE_BOUNDARY[GENERATED_FAT16_IMAGE] status=claimed scope=repo-built-raw-image gate=layout-manifest-plus-fat-checkers evidence=disk-img-status`
- `STORAGE_BOUNDARY[CLOUD_MUTATE_REBOOT] status=proven scope=disposable-qemu-disk-image gate=reboot-persistence-proof evidence=real-wad-smoke-26203744974`
- `STORAGE_BOUNDARY[HOST_RECOVERY_INSPECTION] status=claimed scope=host-generated-image-inspection gate=install-image-manifest evidence=check_storage_install_boundary.py`
- `STORAGE_BOUNDARY[ARBITRARY_DISK_INSTALL] status=unclaimed scope=none gate=future-installer-proof evidence=none`
- `STORAGE_BOUNDARY[ARBITRARY_DISK_RECOVERY] status=unclaimed scope=none gate=future-recovery-proof evidence=none`

## Host Inventory Checker

`tools/check_storage_install_boundary.py --repo-contract` validates this
document's rows and required caveats. With `--image build/disk.img --json`, it
verifies the generated raw image shape and prints an
`install-image-manifest` summary: MBR signature, unused partition-table slots,
FAT16 partition type/start/end, non-overlap with the raw Stage 2/kernel staging
regions, BPB total-sector and hidden-sector fields, FAT/root/data geometry,
FAT reserved entries, FAT-copy/cluster-ownership health, and live root-entry
inventory.

The checker intentionally refuses to widen the claim. A passing manifest means
"this repo-built image has the expected boot/FAT layout and recoverable root
inventory." It does not mean the OS can install to arbitrary media.

## Future Proof Requirements

- `STORAGE_PROOF_REQUIREMENT[INSTALLER] status=future artifact=installer-cloud-disk requires=blank-disk-to-bootable-vibe-os evidence=none`
- `STORAGE_PROOF_REQUIREMENT[RECOVERY] status=future artifact=damaged-image-recovery-report requires=detect-and-repair-or-refuse evidence=none`
- `STORAGE_PROOF_REQUIREMENT[ARBITRARY_MEDIA] status=future artifact=media-matrix-proof requires=explicit-device-and-layout-rows evidence=none`

A real install proof needs a separate opt-in lane that starts from a blank disk
artifact, writes the MBR/loader/kernel/FAT layout using an installer path rather
than `make_wad_image.py`, boots that installed disk in disposable cloud QEMU,
and then runs the same gameplay/persistence status gates. Before that path can
point at arbitrary user media, it also needs user-data safety gates: explicit
device selection, read-only inventory of the current partition table and
filesystem signatures, a default refusal when non-empty or unknown data is
present, an opt-in destructive confirmation that names the exact device and
byte ranges to be overwritten, a dry-run manifest, and post-write verification
that only the approved ranges changed. A real recovery proof needs
damaged-image fixtures, a report that says exactly what was detected, and
either a verified repair or a safe refusal for each fixture.
