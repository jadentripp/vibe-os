# Process Exec Launcher

The boot path now routes Doom through a small process exec launcher instead of
jumping straight from the boot flow into a Doom-only loaded slot.

- `process_boot_launch_doom` asks `process_exec_path` to launch `DOOM.ELF`.
- `process_exec_path` resolves a string path through `process_exec_table`, looks
  up the matching FAT 8.3 root entry, loads the ELF bytes through the common
  FAT loader, and prepares the target process record from the ELF entry point.
- Smoke status includes `exec=OK path=DOOM.ELF` when the generic launcher
  reaches the loaded process image.
- `SYS_EXEC` is reserved in the syscall ABI, but userland exec is not wired to
  replace the current process yet.

Remaining gaps:

- The launcher table has one real boot entry today.
- ELF preparation still delegates Doom's memory-window validation to the
  existing Doom ELF parser.
- Userland cannot yet call `exec` to replace itself or spawn another process.
