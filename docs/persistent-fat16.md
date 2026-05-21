# Persistent FAT16 Writable Files

The generated disk image now creates concrete FAT16 root entries for Doom-owned
persistent state:

- `DEFAULT.CFG`: 16 KiB for Doom defaults, mapped from `/.doomrc` and
  `default.cfg` by the Doom port libc, including Doom's `c:/doomdata` and
  `c:\doomdata` CD-ROM spellings.
- `DOOMSAV0.DSG` through `DOOMSAV5.DSG`: 256 KiB per save slot.

Each pre-created file starts with root-directory size 0 and first cluster 0.
The kernel also accepts root-level 8.3 create/open requests from user
processes. It keeps a per-descriptor seek offset in a small reusable fd table,
allocates free clusters as writes extend a file, updates both FAT copies, and
writes the root entry's first-cluster and size fields. Reads use the persisted
root-entry size, so a fresh image behaves like empty defaults/save slots while
later boots can read back data written into the image.

Reusable FAT16 syscall surface:

- The supported userland filesystem surface is a root-level 8.3 FAT16 contract,
  not a Doom save-file shortcut. `open`, `read`, `write`, `lseek`, `close`,
  `unlink`, `stat`, `fstat`, `ftruncate`, `truncate`, and `vibe_listdir` all
  operate through the shared fd/FAT path used by Doom and by future games and
  tools.
- `vibe_listdir("/")` returns fixed-size `vibe_dirent_t` records for live root
  entries, `vibe_listdir("/ASSETS")` can list a single read-only root-level
  FAT16 subdirectory when the generated image contains one, and read-only
  `open`/`read`/`lseek`/`stat`/`fstat` can resolve one file below that
  directory such as `/ASSETS/README.TXT`. Public headers pin
  `VIBE_DIRENT_NAME_BYTES == 16` and
  `VIBE_DIRENT_BYTES == 32`, expose FAT attribute bits such as
  `VIBE_DIRENT_ATTR_DIRECTORY`, and provide `vibe_dirent_is_directory()` plus
  `vibe_dirent_is_regular_file()` for callers that want to scan the generated
  image without copying Doom-specific filename knowledge.
- The generic path intentionally remains small: root/current-directory prefixes
  normalize to the FAT root, valid 8.3 names are accepted, one root-level
  subdirectory component can be listed read-only, and one file below that
  subdirectory can be opened read-only. Nested traversal, writable
  subdirectories, long filenames, rename, timestamps, ownership, and
  delete-while-open semantics are outside the current syscall contract.
- Directory/file mismatches now use reusable errno classifications instead of
  Doom-shaped fallbacks: opening or unlinking a directory as a file returns
  `EISDIR`, while asking `vibe_listdir` to list an existing regular file
  returns `ENOTDIR`.
- Host tests and image checkers exercise this surface without committing WADs,
  mutated disks, pixel dumps, or raw audio captures. Scratch files such as
  `FATPROOF.TMP` are created only inside in-memory checker copies.

Current kernel contract:

- Supported syscalls: `open`, `read`, `write`, `lseek`, `close`, `unlink`,
  `stat`, `fstat`, root `listdir`, and descriptor `ftruncate`. The Doom libc
  also exposes `truncate(path, size)` through `open` plus `ftruncate`.
- Supported writable paths: `DEFAULT.CFG` and `doomsav0.dsg` through
  `doomsav5.dsg`, plus their unmodified Doom DOS/CD-ROM forms such as
  `c:\doomdata\default.cfg` and `c:\doomdata\doomsav3.dsg`. Arbitrary valid
  root-level 8.3 names can also be opened with write/create/truncate-style
  flags. The generic VFS parser normalizes root/current-directory spellings such
  as `/README.TXT`, `\README.TXT`, and `./README.TXT` to the same FAT16 root
  entry while still rejecting real subdirectory components. Existing dynamic
  root files can be opened read-only for readback.
- Supported asset paths: generated images package `/ASSETS/README.TXT` as a
  root-level 8.3 directory plus one regular file below it. Userland can list
  `/ASSETS`, stat the README, open it read-only, read it, and seek within it.
  Attempts to open one-level subdirectory files with write, create, truncate,
  or append flags return `EACCES`; descriptor `ftruncate` on the resulting
  read-only fd returns `EBADF`; `unlink` remains root-8.3-only and rejects
  subdirectory paths with `EINVAL` before it can touch FAT metadata.
- Supported persistence model: dynamic root-level FAT16 allocation for the
  known 8.3 Doom defaults/save files and a reusable dynamic file table for
  additional root entries.
  This is enough for Doom defaults and save slots, while the broader filesystem
  contract remains intentionally smaller than POSIX.
- Supported descriptor model: WAD reads and writable root files share the same
  open fd table, so duplicate opens get independent offsets and `close`
  releases the descriptor slot. The fd table is intentionally small and bounded;
  exhaustion returns `EMFILE`.
- Supported growth: file size can grow through `write` after `lseek` or through
  `ftruncate`; sparse gaps are zero-filled before they become readable file
  data. Known Doom state files retain their small guard capacities, while
  generic root 8.3 files use the FAT/free-space path rather than the old
  Doom-save-sized ceiling.
- Supported truncation: `O_TRUNC` still frees the old cluster chain, resets
  first cluster to 0, and persists size 0. `ftruncate` can also shrink a file in
  place, freeing tail clusters after validating the chain, or grow it with
  zero-filled bytes. Writable `open(..., O_TRUNC)` reserves an fd slot before
  truncating, so `EMFILE` cannot erase Doom defaults or saves.
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
  size for protected WAD/ELF files, writable root files, and read-only
  one-level subdirectory files. `stat("/")` reports readonly directory mode for
  the FAT root, and `stat("/ASSETS")` reports readonly directory mode for a
  matching root-level directory entry instead of treating it as a regular file.
  `VIBE_SYS_LISTDIR`/`vibe_listdir` copies readonly fixed-size `vibe_dirent_t`
  records for live root entries and for one-level root subdirectories,
  including normalized 8.3 display name, size, mode, first cluster, and raw FAT
  attributes. Timestamps, owners, and device fields are zero. Both root and
  subdirectory listings validate the user buffer by
  `max_entries * VIBE_DIRENT_BYTES`, so the reusable syscall contract does not
  depend on the caller's pointer value.
- Supported validation: nested path traversal, empty names, long filenames, and
  unsupported characters are rejected; leading root separators and `./` prefixes
  are path normalization only, not subdirectory traversal. Existing directories
  cannot be opened as generic writable files, unlinked through the file-delete
  path, or shadowed by `O_CREAT`; those directory-as-file calls return
  `EISDIR`. `vibe_listdir` still requires an actual directory and reports
  `ENOTDIR` for an existing regular file.
  `DOOM1.WAD`, `USERPROB.ELF`, and `DOOM.ELF` remain protected read-only
  entries and cannot be deleted, truncated, or opened writable. Read-only
  subdirectory files also reject write/create/truncate opens. Unknown `open`
  flag bits are rejected as `EINVAL` in the kernel, even if libc callers
  normally filter them first.
- Unsupported in the kernel syscall surface: nested subdirectory traversal,
  writable subdirectories, long filenames, rename, timestamps, ownership,
  permissions beyond read-only
  directory/regular-file versus writable regular-file mode, and no POSIX delete-while-open behavior.
  This kernel deliberately invalidates descriptors when their root entry is
  unlinked.

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
When passed `--save-thinker-offset` or `--save-specials-offset`, the checker
also walks Doom's original save-stream class bytes from that offset. The
thinker pass accepts only `tc_mobj` records followed by `tc_end` and validates
each archived mobj's WAD-independent state/type/player indexes against Doom's
original `states`, `mobjinfo`, and player ranges; the specials pass accepts
only Doom's `tc_ceiling`, `tc_door`, `tc_floor`, `tc_plat`,
`tc_flash`, `tc_strobe`, `tc_glow`, and final `tc_endspecials` classes, with
the final specials terminator immediately before the `0x1d` consistency
marker. If `--load-status` or `--save-write-status` includes runtime
`savestm=` / `savethk=` fields, the checker can derive those stream offsets
without extra CLI flags and reports `thinkers=OK` / `specials=OK` summaries.
This lets cloud artifacts separate FAT short-write failures, which still show
up as size/cluster/read diagnostics, from malformed Doom stream failures such
as `unknown special tclass 112`.

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
`DOOMSAVN.DSG` bytes and reboot comparison count. The reported `savewr=` byte
count must cover the full persisted save payload, so an out-of-band full
`DOOMSAVN.DSG` image cannot be paired with a short write status and pass. To
claim save/load
playability, add `--load-status` from the reboot boot after a scripted Doom
load-menu path. That status must include `doomsav=` open/read/close bits for the
requested slot, `saverd=` bytes at least as large as the saved payload, a
`saveclose=` event, `gameplay=OK`, the saved episode/map in `gmap=`, and
`leveltime=` at or beyond the save header leveltime. The port only sets
the load-done bit after `G_DoLoadGame` has returned, the level is live, and a
later Doom level tick has advanced with a valid player mobj; this keeps stale
pre-load gameplay snapshots from passing as playable reboot persistence. It must
also carry
`savethk=` unarchive-thinker and `savestm=` unarchive-specials stream boundaries;
otherwise the load proof is rejected as blind even if the high-level fields look
green. If the runtime reports `savestm` at `stage=00000018`, the checker treats
that as the post-specials position and verifies that the offset points at the
final `0x1d` consistency marker; failures after that point are post-load
completion-state failures, not malformed thinker/specials streams. A 24-byte
menu-string read
does not count as loading the game. When load fails inside Doom's savegame
unarchiver, `savestm=` and `savethk=` expose the port-wrapper save-stream
offsets and class bytes without modifying the original Doom source. Normal
wrapper entry/exit samples report the byte currently at `save_p`; if original
Doom raises `I_Error` while reading thinker or specials class bytes, the port
emits one final status-only sample from `save_p - 1`, so the top byte in
`savestm`/`savethk` is the offending class that Doom already consumed. That
lets a status line alone identify failures such as `Unknown tclass 112` as
`next_byte=0x70` at the failing save-stream offset, while `doomsav=`,
`saverd=`, `savewr=`, `saveclose=`, and FAT checker output still decide whether
the bytes reached the image cleanly.
The reboot comparison requires `--baseline-image` too, so a preseeded image can
never be reported as a reboot persistence proof without also proving the
requested bytes changed from the fresh image. With a baseline image present, the
checker also verifies both FAT copies agree, every allocated data cluster is
owned by exactly one live root entry, and protected `DOOM1.WAD`, `USERPROB.ELF`,
and `DOOM.ELF` entries have unchanged metadata and bytes. The checker-side FAT
reader can list the root directory and follow simple read-only 8.3 subdirectory
entries for lookup/readback proof. The kernel now exposes the root listing,
one-level subdirectory listing, and read-only one-level subdirectory
lookup/open/read/stat pieces of that contract to user processes.

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
disk artifact. The same proof also requires the generated `/ASSETS/README.TXT`
package to exist, round-trip with the expected bytes, and reject host-modeled
write, create, truncate, and unlink attempts below that read-only subdirectory.
The Makefile wrapper exposes the same checker path with
`PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF=1 make persistence-image-check`, keeping
the host proof runnable without launching QEMU locally.

Storage install/recovery boundary:

- The persistence proof is a generated-image proof, not an arbitrary-disk
  install or recovery proof. It proves that the repo image layout can be
  mutated, rebooted, and inspected; it does not prove vibe-os can partition a
  blank disk, preserve an unknown existing disk, or repair damaged user media.
- `tools/check_storage_install_boundary.py --image build/disk.img --json`
  produces an `install-image-manifest` for the current generated raw image:
  MBR/FAT16 layout, unused partition-table slots, raw Stage 2/kernel region
  non-overlap, FAT BPB total-sector and hidden-sector fields, FAT/root/data
  geometry, root-entry inventory, FAT-copy agreement, and cluster ownership.
  That manifest is intentionally scoped to `build/disk.img`.
- The machine-readable install/recovery rows live in
  `docs/storage-install-boundary.md`. `STORAGE_BOUNDARY[ARBITRARY_DISK_INSTALL]`
  and `STORAGE_BOUNDARY[ARBITRARY_DISK_RECOVERY]` stay unclaimed until a future
  proof starts from blank or damaged media and reaches the same boot,
  persistence, and recovery gates through a real installer or recovery path.
  A safe arbitrary-disk installer would also need explicit device selection,
  read-only preflight inventory, refusal on unknown existing data by default,
  opt-in destructive confirmation for exact byte ranges, a dry-run manifest,
  and post-write verification that no unapproved ranges changed.

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
Kernel contract tests now also pin descriptor-level `ftruncate`, signed
`lseek(..., SEEK_END)` offsets, sparse-write gap zeroing, and root/current-directory prefix normalization for generic 8.3 paths, so the executable proof
covers behavior needed by games and tools beyond Doom save replacement.

ATA PIO waits are bounded and status-reported. The ATA path makes sure commands only start once stale `DRQ` is clear, labels the explicit 256-word PIO loops as
`atawait=DATA`, and waits for the data-request phase to drain after the loop.
The smoke line includes `ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo` so a cloud persistence write boot that parks in
`ata_wait_drq`, `ata_wait_ready`, or the data transfer reports the last
operation and command-status byte instead of silently looking like a Doom
startup/gameplay wait.

Remaining storage gaps before a broad Doom-capable claim:

- Writable semantics are still deliberately narrow: kernel syscalls handle
  root-level 8.3 files, reusable dynamic root entries, readonly root directory
  listing, readonly listing of one root-level subdirectory, and read-only files
  one level below that subdirectory, but no nested traversal, no writable
  subdirectories, no writable create/truncate/unlink behavior below
  subdirectories, no rename, no long filenames, no timestamps/ownership, and no POSIX
  delete-while-open behavior. Host-side validation can inspect read-only
  subdirectory trees more deeply than the kernel syscall surface can.
- The storage proof is image-level and cloud-runner scoped. The OS can mutate
  the generated FAT16 disk image, but there is not yet a broader storage boot
  path story for installing, selecting, or safely recovering persistent media
  outside this generated image workflow.
- The archived real-WAD cloud run `26156172979` is historical context for an
  older save-slot lane: it showed a changed `DOOMSAV0.DSG` description and a
  reboot comparison, but it predates the stricter Doom-shaped save payload
  checker. Future storage or workflow changes must rerun the current executable
  proof gate before making a fresh save/load persistence claim.
