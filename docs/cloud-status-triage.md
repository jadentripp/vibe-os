# Cloud Status Triage

Use this when the next **Real WAD smoke** run uploads `real-wad-smoke-status`.
The proof checker remains the gate; this map is for deciding which repair lane
owns the first failure.

The GitHub workflow also prints this classifier in the Actions log when
`build/status.txt` exists, so most failures should already show a `primary:`
line before you download artifacts.

Fast lane selection should go through the cloud-only dispatcher:

```sh
python3 tools/run_cloud_playability.py --ref main --lane gameplay
python3 tools/run_cloud_playability.py --ref main --lane audio
python3 tools/run_cloud_playability.py --ref main --lane persistence --save-slot 0
```

Use `--lane persistence` while the save/load path is under repair. It sends
`audible_audio_proof=false` and `persistence_save_slot=0`, which keeps
FAT/save-growth failures separate from audible-audio proof failures. Use
`--lane audio` to debug the remote aggregate audio proof without running the
reboot persistence boot.

To wait for the cloud run, download the allowlisted status artifact, triage it,
and run the artifact checker in one loop:

```sh
python3 tools/run_cloud_playability.py --ref main --lane audio \
  --wait \
  --download-artifacts build/cloud-run-audio
```

To measure repeatability without raw status/log uploads, use the soak mode. It
downloads `real-wad-soak-metadata` and validates the JSON-only summary:

```sh
python3 tools/run_cloud_playability.py --ref main --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3 \
  --wait \
  --download-artifacts build/cloud-soak-audio
```

For an existing soak run, select the metadata artifact directly:

```sh
python3 tools/run_cloud_playability.py --run-id RUN_ID --soak \
  --download-artifacts build/cloud-soak-RUN_ID
```

Persistence failures upload both the normal copied status files and mirrored
phase status/triage text as top-level `status.persistence-*` files. For a failed
save-slot write, inspect `status.persistence-write.status.save-slot-0.txt` and
its matching `.triage.txt` first; those files are allowed diagnostics, not proof
relaxations.

Run the local classifier on the final status line:

```sh
python3 tools/triage_cloud_status.py path/to/real-wad-smoke-status/status.txt
```

Status/proof tools should parse status text through `tools/status_fields.py`
instead of open-coded regular expressions. The helper preserves composite
values such as `execsys=a/b/c/d/e/f`, rejects duplicate `key=value` fields, and
keeps tuple/hex validation reusable across Doom, VM/process, storage, audio,
input, panic, and shutdown checkers.

If the artifact includes `doom.symbols`, the classifier auto-loads it from the
same directory and resolves `doomfaultip` to the nearest original Doom or port
function. You can also pass it explicitly:

```sh
python3 tools/triage_cloud_status.py \
  --doom-symbols path/to/real-wad-smoke-status/doom.symbols \
  path/to/real-wad-smoke-status/status.txt
```

Then run the actual gates:

```sh
python3 tools/check_real_wad_proof.py \
  --baseline path/to/real-wad-smoke-status/status.after-start.txt \
  --start path/to/real-wad-smoke-status/status.after-start.txt \
  --fire path/to/real-wad-smoke-status/status.after-fire.txt \
  --movement path/to/real-wad-smoke-status/status.after-move.txt \
  --use path/to/real-wad-smoke-status/status.after-use.txt \
  --mouse path/to/real-wad-smoke-status/status.after-mouse.txt \
  --menu path/to/real-wad-smoke-status/status.after-menu.txt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_cloud_playability_artifacts.py path/to/real-wad-smoke-status
```

## Failure Map

| Class | Status fields | Interpretation | First repair lane |
| --- | --- | --- | --- |
| `exec-not-attempted` | `execsys=00000000/...`, `target=FFFFFFFF` or `00000000`, `entry=00000000`, `stack=00000000`, `argv0=00000000`, `envp=00000000`, often `doomrun=WAIT` | The probe did not make the `SYS_EXEC("DOOM.ELF")` transition. | User-probe completion, expected-fault recovery, syscall dispatch entry. |
| `exec-failed` | `exec!=OK`, `path!=DOOM.ELF`, `doom!=OK`, nonzero `execerr` or `execres`, `execsys` failures or rollbacks nonzero, successes/handoffs/scheduled zero, bad `target`, `ppid`, `entry`, `stack`, `argc`, `argv`, `envp`, `argv0`, or `envp0` | The kernel attempted exec but did not complete the process/ELF/argv/envp handoff. | `process_exec_path`, ELF lookup/load checks, argv stack seeding, rollback path. |
| `doom-user-fault` | `doomrun=FAULT`, nonzero `doomfault`, `doomfaultip`, `doomfaultv`, `doomfaulterr`, or nonzero compact `fault=` tuple | Doom entered user mode and faulted. `doomfault` is CR2, `doomfaultip` is EIP, `doomfaultv` is the exception vector, and `doomfaulterr` is the x86 error code. | Resolve `doomfaultip` with `doom.symbols`; decode vector/error/CR2; inspect stack, paging, segment, and syscall ABI. |
| `kernel-panic` | `panic=KEXC`, usually with a nonzero compact `fault=` tuple | The kernel recorded an unhandled non-Doom exception before halting. | Decode `fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall`, then inspect the matching kernel path. |
| `os-shutdown-requested` | `shutdown=HALT`, `shutdown=REBOOT`, or `shutdown=POWEROFF` | The OS recorded a halt, reboot, or poweroff request in the status block. | Verify this came from an intentional shutdown/reboot/poweroff proof lane before treating QEMU exit as a failure. |
| `ata-storage-stalled` | `atawait=BUSY`, `atawait=DRQ`, `atawait=READY`, or `atawait=DATA` before Doom frames, or nonzero `atafail` / `atatmo`; use `ataop`, `atalba`, `atastat`, and `ataerr` for detail | The kernel is stuck in or has failed an ATA PIO wait/transfer before Doom produced frames. | `ata_wait_not_busy`, `ata_wait_drq`, `ata_wait_ready`, data-port transfer, last LBA selection, and ATA command/status bits. |
| `missing-wad-open-read` | `doomopen!=OK`, `doomread!=OK`, weak `doomwad=open/read/seek/magic`, nonzero `doomerr`, nonzero `doomerrno`, suspicious `doommode`, or Doom error text in `doomlog` | Doom did not successfully open/read/seek the WAD through the libc/syscall/FAT path. If `doomrun=FAULT` is also present, fix the fault first because WAD I/O may simply not have been reached. | Doom libc path mapping, `open/read/lseek`, FAT file lookup, WAD protection rules. |
| `persistence-save-write-failed` | `doomsav` names a save slot, `savewr=00000000/00000000`, nonzero `doomerrno`, negative `fwr` result, or `fio`/`fal` allocation failure fields | Doom reached gameplay and attempted a DOOMSAV write, but the save payload did not complete. This can be the only red gate after playability/audio/preemption already passed. | Persistence status first; then FAT free-cluster budget, dynamic allocation, truncate/free-chain refresh, or write-path repair using `fwr`, `fio`, and `fal`. |
| `persistence-save-growth-allocation-partial` | `doomsav` names a save slot, `savewr=00000400/00000001` or another positive short write, `fwr` result is positive but less than the requested save length, `fal=000000E0/...`, and `fio` shows allocation was reached | Doom reached gameplay, opened/truncated `DOOMSAV*.DSG`, wrote the first save cluster, then failed while allocating/growing the rest of the save file. This should outrank input/playability snapshot complaints during the reboot persistence boot. | FAT save-growth allocation: inspect free-cluster scan state, last data cluster, truncate/free-chain refresh, and why the allocator returned `E0` after a short positive write. Newer kernels also emit `fam` and `fac` for free-hint, FAT-copy retry, and free-cluster probe state. |
| `persistence-load-malformed-stream` | Reboot load status has `doomsav`/`saverd` read evidence plus `savestm=` or `savethk=` at an unarchive thinker/specials stage, usually with nonzero `doomerr` or `doomrun=EXIT` | Doom read the save payload back, but the original load path rejected the serialized thinker or specials stream, for example an unknown class byte. This is not a short write and not a generic input/playability failure. | Use `savestm=stage/slot/offset/value/reports` and `savethk=archive_offset/archive_value/unarchive_offset/unarchive_value` to pick thinker vs specials, then run the persistence image checker with that stream offset. |
| `persistence-load-not-completed` | Reboot load status has `doomsav`/`saverd` evidence, but `saveclose=00000000`, `doomsav` lacks close, `saveact` lacks load-done, `saveact` still has a nonzero gameaction, or no gameplay return is proven | Doom started the reboot load path but did not prove `G_DoLoadGame` completed and returned to gameplay. This should outrank input snapshot complaints during the persistence boot. | Inspect `saverd`, `saveclose`, `saveact`, and the expected DOOMSAV payload size before looking at gameplay/input counters. |
| `doom-init-stalled` | `doominit` is missing, malformed, has missing milestone bits, or has a zero report count after WAD I/O is green | Doom entered user mode and WAD I/O is visible, but the port did not report all first startup milestones. | Decode `doominit`, then inspect the last reported platform hook and nearby Doom startup log text. |
| `frames-no-gameplay` | Nonzero `doompresent`, `doompal`, or `doomframe`, but `gameplay!=OK`, `gstate!=00000000`, `gmap!=00000101`, or `leveltime=00000000` | The renderer is alive, but the engine has not proved E1M1 `GS_LEVEL` gameplay. | Doom startup state, WAD/game mode selection, title/menu/error path, gameplay status reporting. |
| `input-no-effect` | `inputqueue/inputpoll` are zero, `keyirq/keyqueue/keypoll` are zero or fail to increase across keyboard phase snapshots; `keyseen` lacks Up/Ctrl/Space/Escape bits; `mouseirq/mousepkt/mousepoll` fail the mouse snapshot when requested; `pflags` lacks movement/fire/use/menu/ammo/refire/turn bits; `pdelta=00000000`; raw `pammo`/`prefire` does not prove fire; raw `pangle`/`pangledelta` does not prove mouse turn; `status.after-move.txt` does not change `ppos` from `status.after-start.txt`; final `gflags` lacks menu-active evidence | Input either did not enter the OS/queue/poll path or did not mutate Doom state. | PS/2 scan translation, generic event queue, `I_StartTic`, scripted monitor timing, Doom event mapping. |
| `doom-timer-not-proven` | `ticks` is zero or missing, `dtick` is zero/missing, or `dtick` does not equal `floor(ticks * 35 / 100)` | Doom reached gameplay, but the status line does not prove the Doom 35 Hz timebase derived from the OS timer. | `SYS_TIME`, PIT tick accounting, and smoke `dtick` emission. |
| `preemption-not-proven` | `preempt`, `pirq`, `pattempt`, `puser`, `pround`, or `pctx` are zero; `pirq` differs from `preempt`; `pmask` does not contain both Doom-to-probe and probe-to-Doom bits; `pfrom`/`pto` are missing, equal, zero, or `FFFFFFFF`; `pkind` does not name Doom and preempt probe; `peip` is malformed or zero; `pcr3` does not cross Doom/preempt page directories; `pkstk` does not cross Doom/preempt kernel stacks; `pspin=50524545`; `pself!=OK` | Doom reached gameplay, but the cloud line does not prove live PIT interrupts switched both ways between Ring 3 processes and let the alternate probe execute. | `scheduler_tick`, live preempt-probe seeding during Doom exec, IRQ frame save/restore, CR3/TSS switch, and timer IRQ delivery in user mode. |
| `artifact-proof-failure` | Checker complains about missing `status.early.txt`, `status.after-*.txt`, duplicate basenames, forbidden WAD/disk/image/pixel payloads, missing diagnostic ELFs, or missing `doom.symbols` | The status line may be useful, but the uploaded evidence package is not acceptable proof. | `.github/workflows/real-wad-smoke.yml` upload block and `tools/check_cloud_playability_artifacts.py` contract. |
| `playability-status-green` | `doomrun=RUN`, `gameplay=OK`, E1M1 fields correct, frame/palette counters nonzero, WAD I/O green, input/audio/preemption counters active | The final line has no obvious first-failure field, but proof gates can still fail on snapshot-baseline details. | Still require `check_real_wad_proof.py`, `check_human_playability_proof.py`, `check_audio_continuity_proof.py`, and artifact checker pass before claiming playable Doom. |

## Quick Reads

- `execsys=a/b/c/d/e/f` means attempts, successes, failures, handoffs,
  scheduled targets, and rollbacks.
- `execerr` is the kernel-side process exec errno and `execres` is the syscall
  result returned on failure. `ppid`, `entry`, `stack`, `argc`, `argv`, `envp`,
  `argv0`, and `envp0` describe the target process metadata and seeded argument
  stack.
- `doomfaultv=0000000E` is a page fault; pair it with `doomfault` (CR2) and
  `doomfaulterr`. The triage tool decodes common page-fault error bits.
- `doomfaultv=0000000D` is a general protection fault; expect segment, stack,
  or privilege-transition bugs.
- `panic=KEXC` is a kernel-side panic record, not a Doom user fault. Pair it
  with `fault=` first.
- `shutdown=HALT`, `shutdown=REBOOT`, or `shutdown=POWEROFF` means the OS
  shutdown path ran; that is only proof when the cloud run intentionally
  requested it. Reboot/poweroff claims also need observed guest-requested QEMU
  exit in the shutdown proof manifest.
- Shutdown/panic claims need `tools/check_shutdown_panic_proof.py` on the
  opt-in artifact set; a normal smoke artifact that merely reaches monitor
  `quit` is cleanup evidence, not guest shutdown evidence.
- `ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo`
  are the storage-side heartbeat. A persistence write boot that shows
  `atawait=DRQ atastat=00000080`, `atawait=READY`, or `atawait=DATA` with no Doom frames is an ATA PIO lane,
  not a Doom gameplay lane.
- `doomopen=FAIL doomread=FAIL` after `doomrun=FAULT` usually means Doom died
  before its WAD path, not that FAT is necessarily broken.
- Current real-WAD evidence can be past the old fault and WAD I/O blockers while
  still failing proof gates. If Doom is `RUN`, WAD I/O is green, gameplay and
  counters are active, but the checker is red, read the checker error literally:
  the likely lane is `usr=OK` consistency, scripted `use` phase progression,
  mouse baseline/effect evidence, audio baseline continuity, or missing phase
  snapshots.
- `doomwad=a/b/c/d` means Doom-side `DOOM1.WAD` opens, reads, lseeks, and the
  first four WAD bytes seen by Doom. For the real shareware proof, `d` should be
  `44415749` (`IWAD` as little-endian hex).
- `missing-wad-open-read` without a Doom fault prints the `doomwad`,
  `doomseek`, `doomclose`, `doomerr`, `doomerrno`, `doommode`, `doomlog`,
  `wad`, and `lmp` fields so the next owner can separate path-mapping/libc
  failures from FAT root/WAD loading failures.
- `persistence-save-write-failed` is for the opt-in reboot persistence lane,
  not the first playability boot. If the first gates are green but the save
  phase reports `doomerrno=FFFFFFFB`, `savewr=00000000/00000000`, and
  `fal=000000E0/...`, the useful first question is whether the real-WAD image
  had free FAT clusters available for DOOMSAV growth.
- `persistence-save-growth-allocation-partial` is the more precise version
  for the May 20, 2026 cloud persistence signature from run `26191091635`:
  the save boot was in real gameplay/audio, opened the save file, wrote exactly
  one `0x400`-byte cluster (`savewr=00000400/00000001`), then hit
  `fal=000000E0/...` while trying to grow the remaining `0x40000`-byte save.
  Treat that as a FAT growth-allocation lane, not an input lane, even if the
  persistence boot did not replay the full human-playability input proof.
- `savestm=stage/slot/offset/value/reports` and
  `savethk=archive_offset/archive_value/unarchive_offset/unarchive_value` are
  the first fields to read after a reboot-load failure. `stage=00000015` points
  at unarchiving thinkers, while `stage=00000017` points at unarchiving
  specials. If the classifier prints `persistence-load-malformed-stream`, the
  `value` byte is the suspicious class code at `offset`; if it prints
  `persistence-load-not-completed`, the load did not prove the
  request/read/close/done sequence yet. Default unset stream fields such as
  `savestm=00000000/FFFFFFFF/FFFFFFFF/00000000/00000000` are ignored for lane
  selection, so normal non-persistence runs do not look like failed load attempts.
- `saveact=flags/gameaction/slot/reports` separates requested-vs-completed
  Doom actions. For load proof, the flags must include load requested
  (`0x20`) and load done (`0x40`), `gameaction` must be zero after the load,
  and `reports` must be nonzero. A status with only `0x20` is a
  load-not-completed lane even if `saverd` read the full file.
- `doominit=flags/reports` records first Doom port milestones: entry, `I_Init`,
  zone allocation, network, sound, graphics, palette, tic polling, and first
  frame. Missing bits localize startup stalls before gameplay fields become
  meaningful.
- `doompresent>0` without `gameplay=OK` means rendering happened, but not enough
  to call the OS Doom-playable.
- `pspin=50524545` is only the seeded preempt-probe magic. A later value proves
  the alternate Ring 3 spin task got CPU time after a timer switch.
- A green final status without the phase snapshot files is still not proof.
  The required proof bundle is the final status plus early/start/fire/move/use/
  mouse/menu snapshots and the non-WAD diagnostics accepted by the artifact
  checker.
