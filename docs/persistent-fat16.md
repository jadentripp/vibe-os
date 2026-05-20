# Persistent FAT16 Writable Files

The generated disk image now reserves concrete FAT16 files for Doom-owned
persistent state:

- `DEFAULT.CFG`: 16 KiB for Doom defaults, mapped from `/.doomrc` and
  `default.cfg` by the Doom port libc.
- `DOOMSAV0.DSG` through `DOOMSAV5.DSG`: 256 KiB per save slot.

Each file has an allocated, zero-filled FAT chain in the image but starts with a
logical root-directory size of 0. The kernel opens these known paths, keeps a
per-file seek offset, writes sectors through ATA PIO, and updates the FAT16 root
entry size when writes extend a file. Reads use the persisted root-entry size,
so a fresh image behaves like empty defaults/save slots while later boots can
read back data written into the image.

Current kernel contract:

- Supported syscalls: `open`, `read`, `write`, `lseek`, and `close`.
- Supported writable paths: `DEFAULT.CFG` and `doomsav0.dsg` through
  `doomsav5.dsg`.
- Supported persistence model: fixed preallocated cluster chains only.
- Supported growth: file size can grow up to the preallocated capacity.
- Unsupported: creating new directory entries, allocating additional FAT
  clusters, freeing/truncating clusters, timestamps, subdirectories, and long
  filenames.

This is enough for Doom defaults and a first save-slot path without introducing
general-purpose FAT mutation while scheduler/process work is still moving.
