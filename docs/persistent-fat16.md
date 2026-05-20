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
  cluster to 0, and persists size 0.
- Supported deletion: `unlink`/`remove` frees the FAT cluster chain, marks the
  root entry deleted (`0xe5`), clears the in-kernel writable slot, and
  invalidates open descriptors for that file. Later `O_CREAT` can reuse the
  deleted root slot.
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
- Unsupported: subdirectories, long filenames, rename, timestamps, ownership,
  permissions beyond read-only versus writable regular-file mode, and POSIX
  delete-while-open behavior. This kernel deliberately invalidates descriptors
  when their root entry is unlinked.

`tools/check_doom_persistence_image.py` validates a remote/cloud-mutated image
without launching QEMU locally. Use `--require-default` to require Doom-shaped
defaults text in `DEFAULT.CFG`, and `--require-save-slot N` to require a
`DOOMSAVN.DSG` file with Doom's 24-byte save description and 16-byte
`version ...` marker. For real proof, copy the fresh remote `disk.img` before
boot and pass it back with `--baseline-image`; requested entries must differ
from the baseline image, so preseeded host bytes do not count as Doom
persistence.

This is enough for Doom defaults and save slots without turning the kernel into
a general-purpose FAT filesystem.
