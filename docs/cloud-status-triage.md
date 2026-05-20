# Cloud Status Triage

Use this when the next **Real WAD smoke** run uploads `real-wad-smoke-status`.
The proof checker remains the gate; this map is for deciding which repair lane
owns the first failure.

Run the local classifier on the final status line:

```sh
python3 tools/triage_cloud_status.py path/to/real-wad-smoke-status/status.txt
```

Then run the actual gates:

```sh
python3 tools/check_real_wad_proof.py \
  --baseline path/to/real-wad-smoke-status/status.early.txt \
  --fire path/to/real-wad-smoke-status/status.after-fire.txt \
  --movement path/to/real-wad-smoke-status/status.after-move.txt \
  --use path/to/real-wad-smoke-status/status.after-use.txt \
  --menu path/to/real-wad-smoke-status/status.after-menu.txt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_cloud_playability_artifacts.py path/to/real-wad-smoke-status
```

## Failure Map

| Class | Status fields | Interpretation | First repair lane |
| --- | --- | --- | --- |
| `exec-not-attempted` | `execsys=00000000/...`, `target=FFFFFFFF` or `00000000`, `argv0=00000000`, often `doomrun=WAIT` | The probe did not make the `SYS_EXEC("DOOM.ELF")` transition. | User-probe completion, expected-fault recovery, syscall dispatch entry. |
| `exec-failed` | `exec!=OK`, `path!=DOOM.ELF`, `doom!=OK`, `execsys` failures or rollbacks nonzero, successes/handoffs/scheduled zero, bad `target` or `argv0` | The kernel attempted exec but did not complete the process/ELF/argv handoff. | `process_exec_path`, ELF lookup/load checks, argv stack seeding, rollback path. |
| `doom-user-fault` | `doomrun=FAULT`, nonzero `doomfault`, `doomfaultip`, `doomfaultv`, `doomfaulterr`, or nonzero compact `fault=` tuple | Doom entered user mode and faulted. `doomfault` is CR2, `doomfaultip` is EIP, `doomfaultv` is the exception vector, and `doomfaulterr` is the x86 error code. | Symbolize `doomfaultip` against `build/doom.elf`; decode vector/error/CR2; inspect stack, paging, segment, and syscall ABI. |
| `kernel-panic` | `panic=KEXC`, usually with a nonzero compact `fault=` tuple | The kernel recorded an unhandled non-Doom exception before halting. | Decode `fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall`, then inspect the matching kernel path. |
| `os-shutdown-requested` | `shutdown=HALT` or `shutdown=REBOOT` | The OS recorded a halt or reboot request in the status block. | Verify this came from an intentional shutdown/reboot proof lane before treating QEMU exit as a failure. |
| `missing-wad-open-read` | `doomopen!=OK`, `doomread!=OK`, nonzero `doomerr`, suspicious `doommode`, or Doom error text in `doomlog` | Doom did not successfully open/read the WAD through the libc/syscall/FAT path. If `doomrun=FAULT` is also present, fix the fault first because WAD I/O may simply not have been reached. | Doom libc path mapping, `open/read/lseek`, FAT file lookup, WAD protection rules. |
| `frames-no-gameplay` | Nonzero `doompresent`, `doompal`, or `doomframe`, but `gameplay!=OK`, `gstate!=00000000`, `gmap!=00000101`, or `leveltime=00000000` | The renderer is alive, but the engine has not proved E1M1 `GS_LEVEL` gameplay. | Doom startup state, WAD/game mode selection, title/menu/error path, gameplay status reporting. |
| `input-no-effect` | `keyirq/keyqueue/keypoll` are zero or fail to increase across phase snapshots; `pflags` lacks movement/fire/use/menu bits; `pdelta=00000000`; final `gflags` lacks menu-active evidence | Input either did not enter the OS/queue/poll path or did not mutate Doom state. | PS/2 scan translation, event queue, `I_StartTic`, scripted sendkey timing, Doom event mapping. |
| `artifact-proof-failure` | Checker complains about missing `status.early.txt`, `status.after-*.txt`, duplicate basenames, forbidden WAD/disk/image/pixel payloads, or missing diagnostic ELFs | The status line may be useful, but the uploaded evidence package is not acceptable proof. | `.github/workflows/real-wad-smoke.yml` upload block and `tools/check_cloud_playability_artifacts.py` contract. |
| `playability-status-green` | `doomrun=RUN`, `gameplay=OK`, E1M1 fields correct, frame/palette counters nonzero, input/player flags nonzero | The final line has no obvious first-failure field. | Still require `check_real_wad_proof.py`, `check_human_playability_proof.py`, and artifact checker pass before claiming playable Doom. |

## Quick Reads

- `execsys=a/b/c/d/e/f` means attempts, successes, failures, handoffs,
  scheduled targets, and rollbacks.
- `doomfaultv=0000000E` is a page fault; pair it with `doomfault` (CR2) and
  `doomfaulterr`.
- `doomfaultv=0000000D` is a general protection fault; expect segment, stack,
  or privilege-transition bugs.
- `panic=KEXC` is a kernel-side panic record, not a Doom user fault. Pair it
  with `fault=` first.
- `shutdown=HALT` or `shutdown=REBOOT` means the OS shutdown path ran; that is
  only proof when the cloud run intentionally requested it.
- `doomopen=FAIL doomread=FAIL` after `doomrun=FAULT` usually means Doom died
  before its WAD path, not that FAT is necessarily broken.
- `doompresent>0` without `gameplay=OK` means rendering happened, but not enough
  to call the OS Doom-playable.
- A green final status without the phase snapshot files is still not proof.
