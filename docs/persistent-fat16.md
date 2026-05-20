# Persistent FAT16 Writable Files

The generated disk image now creates concrete FAT16 root entries for Doom-owned
persistent state:

- `DEFAULT.CFG`: 16 KiB for Doom defaults, mapped from `/.doomrc` and
  `default.cfg` by the Doom port libc.
- `DOOMSAV0.DSG` through `DOOMSAV5.DSG`: 256 KiB per save slot.

Each file starts with root-directory size 0 and first cluster 0. The kernel
opens these known paths, keeps a per-file seek offset, allocates free clusters
as writes extend a file, updates both FAT copies, and writes the root entry's
first-cluster and size fields. Reads use the persisted root-entry size, so a
fresh image behaves like empty defaults/save slots while later boots can read
back data written into the image.

Current kernel contract:

- Supported syscalls: `open`, `read`, `write`, `lseek`, and `close`.
- Supported writable paths: `DEFAULT.CFG` and `doomsav0.dsg` through
  `doomsav5.dsg`.
- Supported persistence model: dynamic root-level FAT16 allocation for the
  known 8.3 Doom defaults/save files.
- Supported growth: file size can grow up to the per-file guard capacity.
- Supported truncation: `O_TRUNC` frees the old cluster chain, resets first
  cluster to 0, and persists size 0.
- Supported creation: missing known root entries are created on storage init.
- Unsupported: arbitrary path creation beyond the known Doom root-level 8.3
  names, timestamps, subdirectories, and long filenames.

This is enough for Doom defaults and save slots without turning the kernel into
a general-purpose FAT filesystem.
