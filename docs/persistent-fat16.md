# Persistent FAT16 Writable Files

The generated disk image now creates concrete FAT16 root entries for Doom-owned
persistent state:

- `DEFAULT.CFG`: 16 KiB for Doom defaults, mapped from `/.doomrc` and
  `default.cfg` by the Doom port libc.
- `DOOMSAV0.DSG` through `DOOMSAV5.DSG`: 256 KiB per save slot.

Each pre-created file starts with root-directory size 0 and first cluster 0.
The kernel also accepts small root-level 8.3 create/open requests from user
processes when write/create/truncate-style flags are present. It keeps a
per-file seek offset, allocates free clusters as writes extend a file, updates
both FAT copies, and writes the root entry's first-cluster and size fields.
Reads use the persisted root-entry size, so a fresh image behaves like empty
defaults/save slots while later boots can read back data written into the
image.

Current kernel contract:

- Supported syscalls: `open`, `read`, `write`, `lseek`, and `close`.
- Supported writable paths: `DEFAULT.CFG` and `doomsav0.dsg` through
  `doomsav5.dsg`, plus arbitrary valid root-level 8.3 names opened with
  write/create/truncate-style flags.
- Supported persistence model: dynamic root-level FAT16 allocation for the
  known 8.3 Doom defaults/save files and a bounded dynamic file table for
  additional root entries.
- Supported growth: file size can grow up to the per-file guard capacity.
- Supported truncation: `O_TRUNC` frees the old cluster chain, resets first
  cluster to 0, and persists size 0.
- Supported creation: missing known root entries are created on storage init.
- Supported validation: subdirectories, path traversal, empty names, long
  filenames, and unsupported characters are rejected; `DOOM1.WAD`,
  `USERPROB.ELF`, and `DOOM.ELF` remain read-only protected entries.
- Unsupported: subdirectories, long filenames, timestamps, permissions, file
  deletion, and a fully reusable POSIX descriptor table.

This is enough for Doom defaults and save slots without turning the kernel into
a general-purpose FAT filesystem.
