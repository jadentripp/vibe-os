# Cloud Status Triage

Use this when the next **Real WAD smoke** run uploads `real-wad-smoke-status`.
The proof checker remains the gate; this map is for deciding which repair lane
owns the first failure.

The GitHub workflow also prints this classifier in the Actions log when
`build/status.txt` exists, so most failures should already show a `primary:`
line before you download artifacts.

Run the local classifier on the final status line:

```sh
python3 tools/triage_cloud_status.py path/to/real-wad-smoke-status/status.txt
```

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
  --baseline path/to/real-wad-smoke-status/status.early.txt \
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
| `exec-not-attempted` | `execsys=00000000/...`, `target=FFFFFFFF` or `00000000`, `entry=00000000`, `stack=00000000`, `argv0=00000000`, often `doomrun=WAIT` | The probe did not make the `SYS_EXEC("DOOM.ELF")` transition. | User-probe completion, expected-fault recovery, syscall dispatch entry. |
| `exec-failed` | `exec!=OK`, `path!=DOOM.ELF`, `doom!=OK`, nonzero `execerr` or `execres`, `execsys` failures or rollbacks nonzero, successes/handoffs/scheduled zero, bad `target`, `entry`, `stack`, `argc`, `argv`, or `argv0` | The kernel attempted exec but did not complete the process/ELF/argv handoff. | `process_exec_path`, ELF lookup/load checks, argv stack seeding, rollback path. |
| `doom-user-fault` | `doomrun=FAULT`, nonzero `doomfault`, `doomfaultip`, `doomfaultv`, `doomfaulterr`, or nonzero compact `fault=` tuple | Doom entered user mode and faulted. `doomfault` is CR2, `doomfaultip` is EIP, `doomfaultv` is the exception vector, and `doomfaulterr` is the x86 error code. | Resolve `doomfaultip` with `doom.symbols`; decode vector/error/CR2; inspect stack, paging, segment, and syscall ABI. |
| `kernel-panic` | `panic=KEXC`, usually with a nonzero compact `fault=` tuple | The kernel recorded an unhandled non-Doom exception before halting. | Decode `fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall`, then inspect the matching kernel path. |
| `os-shutdown-requested` | `shutdown=HALT` or `shutdown=REBOOT` | The OS recorded a halt or reboot request in the status block. | Verify this came from an intentional shutdown/reboot proof lane before treating QEMU exit as a failure. |
| `missing-wad-open-read` | `doomopen!=OK`, `doomread!=OK`, nonzero `doomerr`, suspicious `doommode`, or Doom error text in `doomlog` | Doom did not successfully open/read the WAD through the libc/syscall/FAT path. If `doomrun=FAULT` is also present, fix the fault first because WAD I/O may simply not have been reached. | Doom libc path mapping, `open/read/lseek`, FAT file lookup, WAD protection rules. |
| `frames-no-gameplay` | Nonzero `doompresent`, `doompal`, or `doomframe`, but `gameplay!=OK`, `gstate!=00000000`, `gmap!=00000101`, or `leveltime=00000000` | The renderer is alive, but the engine has not proved E1M1 `GS_LEVEL` gameplay. | Doom startup state, WAD/game mode selection, title/menu/error path, gameplay status reporting. |
| `input-no-effect` | `keyirq/keyqueue/keypoll` are zero or fail to increase across keyboard phase snapshots; `keyseen` lacks Up/Ctrl/Space/Escape bits; `mouseirq/mousepkt/mousepoll` fail the mouse snapshot when requested; `pflags` lacks movement/fire/use/menu/ammo/refire bits; `pdelta=00000000`; `status.after-move.txt` does not change `ppos` from `status.after-start.txt`; final `gflags` lacks menu-active evidence | Input either did not enter the OS/queue/poll path or did not mutate Doom state. | PS/2 scan translation, event queues, `I_StartTic`, scripted monitor timing, Doom event mapping. |
| `preemption-not-proven` | `preempt`, `pattempt`, `puser`, `pround`, or `pctx` are zero; `pfrom`/`pto` are missing, equal, zero, or `FFFFFFFF`; `peip` is malformed or zero; `pspin=50524545`; `pself!=OK` | Doom reached gameplay, but the cloud line does not prove a live PIT interrupt switched from one Ring 3 process to another and let the alternate probe execute. | `scheduler_tick`, live preempt-probe seeding during Doom exec, IRQ frame save/restore, and timer IRQ delivery in user mode. |
| `artifact-proof-failure` | Checker complains about missing `status.early.txt`, `status.after-*.txt`, duplicate basenames, forbidden WAD/disk/image/pixel payloads, missing diagnostic ELFs, or missing `doom.symbols` | The status line may be useful, but the uploaded evidence package is not acceptable proof. | `.github/workflows/real-wad-smoke.yml` upload block and `tools/check_cloud_playability_artifacts.py` contract. |
| `playability-status-green` | `doomrun=RUN`, `gameplay=OK`, E1M1 fields correct, frame/palette counters nonzero, input/player flags nonzero | The final line has no obvious first-failure field. | Still require `check_real_wad_proof.py`, `check_human_playability_proof.py`, and artifact checker pass before claiming playable Doom. |

## Quick Reads

- `execsys=a/b/c/d/e/f` means attempts, successes, failures, handoffs,
  scheduled targets, and rollbacks.
- `execerr` is the kernel-side process exec errno and `execres` is the syscall
  result returned on failure. `entry`, `stack`, `argc`, `argv`, and `argv0`
  describe the seeded target process frame and argument stack.
- `doomfaultv=0000000E` is a page fault; pair it with `doomfault` (CR2) and
  `doomfaulterr`. The triage tool decodes common page-fault error bits.
- `doomfaultv=0000000D` is a general protection fault; expect segment, stack,
  or privilege-transition bugs.
- `panic=KEXC` is a kernel-side panic record, not a Doom user fault. Pair it
  with `fault=` first.
- `shutdown=HALT` or `shutdown=REBOOT` means the OS shutdown path ran; that is
  only proof when the cloud run intentionally requested it.
- `doomopen=FAIL doomread=FAIL` after `doomrun=FAULT` usually means Doom died
  before its WAD path, not that FAT is necessarily broken.
- `missing-wad-open-read` without a Doom fault prints the `doomseek`,
  `doomclose`, `doomerr`, `doommode`, `doomlog`, `wad`, and `lmp` fields so the
  next owner can separate path-mapping/libc failures from FAT root/WAD loading
  failures.
- `doompresent>0` without `gameplay=OK` means rendering happened, but not enough
  to call the OS Doom-playable.
- `pspin=50524545` is only the seeded preempt-probe magic. A later value proves
  the alternate Ring 3 spin task got CPU time after a timer switch.
- A green final status without the phase snapshot files is still not proof.
