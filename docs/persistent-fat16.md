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
defaults text in `DEFAULT.CFG`: ASCII, newline-terminated assignments for
`mouse_sensitivity`, `use_mouse`, `screenblocks`, and quoted `chatmacro0`, with
the numeric fields inside Doom-plausible ranges. Use `--require-save-slot N`
only with a fresh `--baseline-image`; save-slot proof is rejected unless the
baseline `DOOMSAVN.DSG` root entry is still empty, so preseeded saves cannot be
mistaken for Doom-written persistence. The save validator requires Doom's
24-byte NUL-terminated printable description, exact zero-padded 16-byte
`version 110` marker, plausible skill/episode/map bytes, single-player
`playeringame` flags, nonzero `leveltime`, a plausible archived i386
`player_t` record, enough non-uniform serialized world/game-state bytes, and
the final `0x1d` consistency marker written by `G_DoSaveGame`.

For real proof, copy the fresh remote `disk.img` before boot and pass it back
with `--baseline-image`; requested entries must differ from the baseline image.
For reboot proof, copy an after-write snapshot of the same disk image and pass
it with `--reboot-baseline-image` after booting the image again; requested
entries must still have the same FAT root cluster, size, and bytes. Add
`--reboot-status` with the second boot's decoded status so the same proof also
requires a live Doom runtime: no user fault, panic, shutdown, or failed
`usr`/`wad`/runtime health fields. Add `--write-status` when `DEFAULT.CFG` is
proved through the runtime defaults checkpoint; the checker then requires the
write boot to report the last `O_WRONLY|O_CREAT|O_TRUNC` defaults open, a
completed defaults close, and no user fault before accepting the disk bytes.
For save-slot proof, add `--save-write-status` with the first boot's decoded
status; current save-slot reboot proof refuses to pass without that write-boot
runtime evidence, and the checker requires Doom to be live, fault-free, writing,
closing, and using an `O_WRONLY|O_CREAT|O_TRUNC` save-file open before the
`DOOMSAVN.DSG` bytes and reboot comparison count. To claim save/load
playability, add `--load-status` from the reboot boot after a scripted Doom
load-menu path. That status must include `doomsav=` open/read/close bits for the
requested slot, `saverd=` bytes at least as large as the saved payload, a
`saveclose=` event, `gameplay=OK`, the saved episode/map in `gmap=`, and
`leveltime=` at or beyond the save header leveltime. A 24-byte menu-string read
does not count as loading the game.
The reboot comparison requires `--baseline-image` too, so a preseeded image can
never be reported as a reboot persistence proof without also proving the
requested bytes changed from the fresh image. With a baseline image present, the
checker also verifies both FAT copies agree, every allocated data cluster is
owned by exactly one live root entry, and protected `DOOM1.WAD`, `USERPROB.ELF`,
and `DOOM.ELF` entries have unchanged metadata and bytes. The checker-side FAT
reader can list the root directory and follow simple read-only 8.3 subdirectory
entries for lookup/readback proof; this is deliberately a validation/tooling
capability until the kernel grows a real directory syscall contract.

Add `--require-dynamic-fat-proof` when the artifact should also prove the image
still supports dynamic filesystem behavior. That option mutates an in-memory
copy only: it creates `FATPROOF.TMP`, writes a multi-cluster file, sparse-extends
it while proving zero-filled holes, shrinks it while proving tail-cluster free
and tail-byte zeroing, truncates it to size zero, rewrites it, deletes it, and
proves the deleted root slot can be reused. After each size-changing step the
checker reparses the mutated bytes through a fresh FAT reader and reads the file
back, so the proof covers read-after-remount behavior rather than only
same-object state. The checker then revalidates FAT-copy agreement and
reachable-cluster ownership on the mutated copy, so this is a host-verifiable
allocation/free/truncate proof without putting a scratch file back into the real
disk artifact.
The Makefile wrapper exposes the same checker path with
`PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF=1 make persistence-image-check`, keeping
the host proof runnable without launching QEMU locally.

The Doom libc buffers formatted `fprintf` output until `fflush()` / `fclose()`,
so `M_SaveDefaults()` does not spend the cloud proof window performing one disk
syscall per default line. The port checkpoints defaults only when the cloud
persistence proof has stamped a root-level `PERSIST.CHK` marker into the image,
Doom is already in live gameplay, and the generated `DEFAULT.CFG` is still
empty, partial, or missing core defaults markers. The default real-WAD cloud
workflow waits for that checkpoint before snapshotting the disk; the save-slot
proof path skips the marker so `DOOMSAV*.DSG` runs boot from the clean captured
baseline. `--write-status` keeps the wait honest by rejecting a `DEFAULT.CFG`
proof until the defaults file has been opened with `O_TRUNC` and closed.
Persistence control markers are cached during `I_ZoneBase` and checked again
during `I_Init`; both happen before live gameplay, and the marker readers are
one-shot even when a marker is absent. The leveltime checkpoint therefore
consumes the cached `PERSIST.CHK`, `SAVEREQ.CHK`, or `LOADREQ.CHK` decision
instead of scanning the FAT root directory on the frame that arms the save or
load.

The save/load cloud proof uses `SAVEREQ.CHK` and `LOADREQ.CHK` marker files to
request a Doom save slot. The marker file size is `slot + 1`, so the Doom port
can learn the requested slot with `stat()` instead of reading marker file data
from the live gameplay loop. That keeps the proof focused on the real
`DOOMSAV*.DSG` write/read path instead of spending the critical window on a
throwaway marker payload read.
When the cached save request is present, the port enters the original
`G_SaveGame()` path as soon as Doom has a live level/player. Original Doom's
`G_SaveGame()` only queues `sendsave`; the port leaves that queue intact so the
original `G_BuildTiccmd()` and `G_Ticker()` path turns it into
`ga_savegame`. As soon as the action is promoted, the port clears outstanding
save-special bits from Doom's circular ticcmd buffer for the console player,
then leaves `ga_savegame` for original Doom to drain at the top of the next
`G_Ticker()`. That avoids re-processing the same queued save command when either
the normal `maketic` slot or the port's `gametic` bridge slot wraps as a
`NET GAME` save while still preserving original Doom's save timing and
serializer.

The host-side `Fat16Image` mutator in `tools/make_wad_image.py` exercises sparse
writes, growth, replacement, in-place shrink with tail-cluster freeing,
resize-to-zero, delete, deleted root-slot reuse, zero-fill checks, FAT-copy
agreement, root directory listing, and read-only subdirectory lookup/readback.
That is a test harness for image inspection; the kernel-facing truncate contract
remains `O_TRUNC` to zero, because Doom only needs config/save replacement
semantics today.

This is enough for Doom defaults and save slots without turning the kernel into
a general-purpose FAT filesystem.

ATA PIO waits are bounded and status-reported. The ATA path makes sure commands only start once stale `DRQ` is clear, labels the explicit 256-word PIO loops as
`atawait=DATA`, and waits for the data-request phase to drain after the loop.
The smoke line includes `ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo` so a cloud persistence write boot that parks in
`ata_wait_drq`, `ata_wait_ready`, or the data transfer reports the last
operation and command-status byte instead of silently looking like a Doom
startup/gameplay wait.

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
- The archived real-WAD cloud run `26156172979` is historical context for an
  older save-slot lane: it showed a changed `DOOMSAV0.DSG` description and a
  reboot comparison, but it predates the stricter Doom-shaped save payload
  checker. Future storage or workflow changes must rerun the current executable
  proof gate before making a fresh save/load persistence claim.
