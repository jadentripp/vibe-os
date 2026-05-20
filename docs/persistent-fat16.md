# Persistent FAT16 Writable Files

The generated disk image now creates concrete FAT16 root entries for Doom-owned
persistent state:

- `DEFAULT.CFG`: 16 KiB for Doom defaults, mapped from `/.doomrc` and
  `default.cfg` by the Doom port libc, including Doom's `c:/doomdata` and
  `c:\doomdata` CD-ROM spellings.
- `DOOMSAV0.DSG` through `DOOMSAV5.DSG`: 256 KiB per save slot.

Each pre-created file starts with root-directory size 0 and first cluster 0.
The kernel also accepts small root-level 8.3 create/open requests from user
processes. It keeps a per-descriptor seek offset in a small reusable fd table,
allocates free clusters as writes extend a file, updates both FAT copies, and
writes the root entry's first-cluster and size fields. Reads use the persisted
root-entry size, so a fresh image behaves like empty defaults/save slots while
later boots can read back data written into the image.

Current kernel contract:

- Supported syscalls: `open`, `read`, `write`, `lseek`, `close`, `unlink`,
  `stat`, and `fstat`.
- Supported writable paths: `DEFAULT.CFG` and `doomsav0.dsg` through
  `doomsav5.dsg`, plus their unmodified Doom DOS/CD-ROM forms such as
  `c:\doomdata\default.cfg` and `c:\doomdata\doomsav3.dsg`. Arbitrary valid
  root-level 8.3 names can also be opened with write/create/truncate-style
  flags. Existing dynamic root files can be opened read-only for readback.
- Supported persistence model: dynamic root-level FAT16 allocation for the
  known 8.3 Doom defaults/save files and a bounded dynamic file table for
  additional root entries.
- Supported descriptor model: WAD reads and writable root files share the same
  open fd table, so duplicate opens get independent offsets and `close`
  releases the descriptor slot. The fd table is intentionally small and bounded;
  exhaustion returns `EMFILE`.
- Supported growth: file size can grow up to the per-file guard capacity.
- Supported truncation: `O_TRUNC` frees the old cluster chain, resets first
  cluster to 0, and persists size 0. The kernel validates the whole FAT chain
  before mutating entries, so a corrupt loop or out-of-range pointer fails
  without partially freeing the file. Writable `open(..., O_TRUNC)` also
  reserves an fd slot before truncating, so `EMFILE` cannot erase Doom defaults
  or saves.
- Supported allocation hygiene: newly allocated clusters are zero-filled before
  they become file data, FAT updates are written to both FAT copies, and root
  entry size/first-cluster metadata is updated after successful writes. The
  host image checker now walks the root directory plus read-only subdirectory
  trees, rejects duplicate live names within a directory, cross-linked file or
  directory chains, and allocated data clusters that are not reachable from any
  live directory entry, so leaked clusters cannot pass as healthy persistence
  evidence.
- Supported deletion: `unlink`/`remove` frees the FAT cluster chain, marks the
  root entry deleted (`0xe5`), clears the in-kernel writable slot, and
  invalidates open descriptors for that file. Later `O_CREAT` can reuse the
  deleted root slot.
- Supported chain hardening: FAT frees reject chains that point outside the data
  area, into a free cluster, or around a loop before writing any FAT updates.
  Allocation/link failures try to roll back the just-allocated cluster instead
  of silently leaking it.
- Supported creation: missing known root entries are created on storage init and
  can be recreated with `O_CREAT` after deletion.
- Supported metadata: `stat` and `fstat` report regular-file mode, one link, and
  size for protected WAD/ELF files and writable root files. Timestamps, owners,
  and device fields are zero.
- Supported validation: subdirectories, path traversal, empty names, long
  filenames, and unsupported characters are rejected; `DOOM1.WAD`,
  `USERPROB.ELF`, and `DOOM.ELF` remain protected read-only entries and cannot
  be deleted, truncated, or opened writable. Unknown `open` flag bits are
  rejected as `EINVAL` in the kernel, even if libc callers normally filter them
  first.
- Unsupported in the kernel syscall surface: subdirectories, long filenames, no rename,
  timestamps, ownership, permissions beyond read-only versus writable
  regular-file mode, and no POSIX delete-while-open behavior. This kernel
  deliberately invalidates descriptors when their root entry is unlinked.

`tools/check_doom_persistence_image.py` validates a remote/cloud-mutated image
without launching QEMU locally. Use `--require-default` to require Doom-shaped
defaults text in `DEFAULT.CFG`, and `--require-save-slot N` to require a
`DOOMSAVN.DSG` file with Doom's 24-byte save description and 16-byte
`version 110` marker plus plausible game-state header bytes. For real proof,
copy the fresh remote `disk.img` before boot and pass it back with
`--baseline-image`; requested entries must differ from the baseline image, so
preseeded host bytes do not count as Doom persistence. For reboot proof, copy an
after-write snapshot of the same disk image and pass it with
`--reboot-baseline-image` after booting the image again; requested entries must
still have the same FAT root cluster, size, and bytes. Add `--reboot-status`
with the second boot's decoded status so the same proof also requires a live
Doom runtime: no user fault, panic, shutdown, or failed `usr`/`wad`/runtime
health fields. The reboot comparison requires `--baseline-image` too, so a
preseeded image can never be reported as a reboot persistence proof without also
proving the requested bytes changed from the fresh image. With a baseline image
present, the checker also verifies both FAT copies agree, every allocated data
cluster is owned by exactly one live root entry, and protected `DOOM1.WAD`,
  `USERPROB.ELF`, and `DOOM.ELF` entries have unchanged metadata and bytes. The
  checker-side FAT reader can list the root directory and follow simple
  read-only 8.3 subdirectory entries for lookup/readback proof; this is
  deliberately a validation/tooling capability until the kernel grows a real
  directory syscall contract.

The host-side `Fat16Image` mutator in `tools/make_wad_image.py` exercises sparse
writes, growth, replacement, in-place shrink with tail-cluster freeing,
resize-to-zero, delete, zero-fill checks, FAT-copy agreement, root directory
listing, and read-only subdirectory lookup/readback. That is a test harness for
image inspection; the kernel-facing truncate contract remains `O_TRUNC` to
zero, because Doom only needs config/save replacement semantics today.

This is enough for Doom defaults and save slots without turning the kernel into
a general-purpose FAT filesystem.

Remaining storage gaps before a broad Doom-capable claim:

- Writable semantics are still deliberately narrow: kernel syscalls handle
  root-level 8.3 files, bounded dynamic root entries, no subdirectories, no rename,
  no long filenames, no timestamps/ownership, and no POSIX delete-while-open behavior.
  Host-side validation can now inspect read-only
  subdirectory trees, but user processes cannot create or traverse them yet.
- The storage proof is image-level and cloud-runner scoped. The OS can mutate
  the generated FAT16 disk image, but there is not yet a broader storage boot
  path story for installing, selecting, or safely recovering persistent media
  outside this generated image workflow.
- The archived real-WAD cloud run `26155149926` proves save-slot reboot
  persistence for this commit: `DOOMSAV0.DSG` is changed from the fresh baseline with
  description `VIBESAVE`, keeps Doom's `version 110` marker, and survives a
  second boot of the same remote image with `reboot status runtime=OK`. Future
  storage or workflow changes must rerun that executable proof gate before
  making a fresh persistence claim.
