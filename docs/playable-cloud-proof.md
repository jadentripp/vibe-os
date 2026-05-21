# Playable Cloud Proof

The playable-Doom milestone is only proved when the cloud CI proof gates pass
without uploading WADs, disk images, framebuffer dumps, or rendered WAD pixels.
The intended proof is status-driven: the OS boots the validated shareware
`DOOM1.WAD`, Doom autostarts E1M1, QEMU injects deterministic keyboard and mouse
input through the same PS/2 device paths a human would use, Doom consumes those
events through the generic input queue, and the kernel exports
compact counters and state deltas from Doom.

This file describes the required green path. A scripted green run is not by itself a claim that the current branch is human-playable, and it is not enough without the reviewed remote VNC bundle.
Persistence/save-load is now green on the current cloud proof path. Manual
**Real WAD smoke** run `26203744974` on `f9a688e` booted the validated shareware
WAD, passed real-WAD gameplay, scripted human-playability, scripted gameplay
transition, VM/process, SB16 continuity, artifact hygiene, and status triage,
then wrote `DOOMSAV0.DSG` at `25718` bytes, rebooted the same disk image, read
the save payload back, closed it, and returned to gameplay. The downloaded
artifact triages as `persistence-proof-green`, with `first-boot`,
`save-write`, `reboot-load`, and `manifest/status` all passing.

Cloud triage still separates persistence failures into short-write,
malformed-stream, load-not-completed, checker/artifact mismatch, and green
write/load lanes. The older `Unknown tclass 112 in savegame` failure remains
historical repair context, not the current blocker. Current save-slot proof must
include the first boot's decoded save-write runtime gate plus the rebooted image
comparison and `--load-status` evidence that Doom read the full `DOOMSAV*.DSG`
payload back into gameplay, so changed save bytes alone do not count. A
human-facing playable claim still needs
a recorded remote VNC playtest bundle from `docs/runbooks/remote-doom-playtest.md`, with
structured `human-playtest-notes-v2` notes, required operator confirmations,
per-phase status SHA-256 fields, a phase-by-phase
`human-playtest-session.json` transcript tied to the passing scripted run ID, a
`human-playtest-checklist.txt` review file with
`schema=human-playtest-checklist-v1`, a SHA-256
`human-playtest-manifest.json`, and the same non-WAD status checks passing
locally after download.

## Current-Head Dispatch

Before push, run the host-only readiness contract:

```sh
make playability-host-check
```

That target is intentionally QEMU-free on the local machine: it rebuilds the
synthetic image, runs host tests, repo hygiene/original-Doom provenance,
dynamic FAT persistence-image proof, cloud artifact/runbook contracts, play-now
script contracts, and whitespace checks before any cloud dispatch.

After push, dispatch the selected branch/ref with explicit guards so the job
fails early if GitHub Actions is pointed at the wrong branch:

```sh
branch=$(git branch --show-current)
gh workflow run os-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f shutdown_panic_proof=false
```

Then use the cloud-only dispatcher for the real-WAD lane you want. It refuses
local VM execution, accepts only an optional HTTP(S) WAD URL, and prints the
artifact download and triage commands:

```sh
python3 tools/run_cloud_playability.py --ref "$branch" --lane gameplay
python3 tools/run_cloud_playability.py --ref "$branch" --lane audio
python3 tools/run_cloud_playability.py --ref "$branch" --lane persistence \
  --save-slot 0
```

`gameplay` is the fastest proof path. `audio` enables the temporary remote WAV
reduction to `audio-proof.json`. `persistence` intentionally leaves
`audible_audio_proof=false` so save/load failures are isolated from audio
flakes while the kernel FAT/save path is moving.
Downloaded artifacts now print explicit failure lanes: gameplay/input, SB16
continuity, audible audio aggregate when requested, and persistence/save-load
when requested. Keep those boundaries intact when deciding what the current
branch actually proves.
When persistence fails before a top-level copy step runs, the artifact still
includes mirrored phase status and triage text such as
`status.persistence-write.status.save-slot-0.txt`; WADs, disk images, pixels,
and raw audio remain excluded.

When you want the helper to wait and pull the allowlisted status artifact:

```sh
python3 tools/run_cloud_playability.py --ref "$branch" --lane persistence \
  --save-slot 0 \
  --wait \
  --download-artifacts "build/cloud-run-persistence"
```

Manual equivalent commands are still:

```sh
gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=false \
  -f persistence_proof=false

gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=true \
  -f persistence_proof=false

gh workflow run real-wad-smoke.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f audible_audio_proof=false \
  -f persistence_save_slot=0
```

For a downloaded non-persistence gameplay/audio proof artifact, require both
machine-checkable manifests:

```sh
python3 tools/check_cloud_playability_artifacts.py \
  path/to/real-wad-smoke-status \
  --require-gameplay-proof \
  --require-audible-proof
```

Once `.github/workflows/real-wad-soak.yml` is present on the repository default
branch, run the repeated proof:

```sh
branch=$(git branch --show-current)
python3 tools/run_cloud_playability.py --ref "$branch" --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3
```

## Deterministic Script

The manual **Real WAD smoke** workflow runs this input script after Doom has had
time to settle:

```text
after-start:wait=2,snapshot
after-fire:hold=ctrl:800,wait-status-min=pflags:000000C5:80:2,wait=1,snapshot
after-move:hold=up:1200,wait-status-min=pdelta:00000001:80:2,wait=1,snapshot
after-use:hold=spc:3000,snapshot,wait=2
after-mouse:mousebtn=1,wait=1,mouse=4:0,wait=1,mousebtn=0,wait=1,mouse=64:0,wait-status-min=pangledelta:00000001:80:2,wait=1,snapshot
after-menu:esc,wait=2,snapshot
```

Keyboard phases use QEMU monitor `sendkey`; the mouse phase uses
`mouse_move`/`mouse_button` against the PS/2 auxiliary path. Each phase waits
for Doom to process ticks and captures a decoded status artifact. The final
status is captured after the menu phase. `tests/run_smoke_qemu.sh` still
supports the older `SMOKE_SENDKEYS` fallback, but `SMOKE_INPUT_SCRIPT` is the
deterministic playability path.
The mouse turn proof is status-only: the scripted mouse phase waits for
`pangledelta` to change after PS/2 mouse movement, then records the compact
phase snapshot without storing pixels or raw input logs.
The `after-start` snapshot is the clean pre-input checkpoint: the port starts
Doom directly in E1M1, the checker verifies it is already `GS_LEVEL`, and later
phases must mutate state from that baseline.

`tools/check_scripted_gameplay_proof.py` is the disjoint runtime-transition
gate for this script. It consumes only decoded status text, requires a clean E1M1 start
before scripted input, verifies cumulative key/player proof across fire, move,
use, mouse, and menu phases, and can write
`gameplay-proof.json` with schema `scripted-gameplay-proof-v1`. The manifest
contains status byte counts and SHA-256 hashes plus the compact transition
fields, not WAD bytes, disk images, framebuffer dumps, screenshots, or audio.
It also includes status-only performance diagnostics. Those diagnostics compare
`doompresent`, `dtick`, `inputdepth`, `musicpull`, audio safety counters, and
preemption counters across the same phase snapshots. A healthy proof reports
`os-pipeline-healthy`, which means the OS-side frame/timer/input/audio/scheduler
counters advanced without input drops or audio safety regressions. If a
Codespaces/noVNC play session still slows down while this verdict stays healthy,
triage should start with remote QEMU TCG/noVNC/display throughput rather than
assuming Doom is building an OS-side input queue.

## Repeated Cloud Soak

The manual **Real WAD soak** workflow repeats the same cloud proof without
uploading WADs, disk images, logs, status text, rendered pixels, or raw audio.
Each attempt runs the real-WAD, scripted human-playability, and SB16 continuity
gates. When `audible_audio_proof=true`, each attempt must also reduce the
temporary QEMU WAV to aggregate audio metadata and delete the WAV before any
artifact upload.

The only uploaded soak artifact is JSON metadata:
`real-wad-soak-summary.json` plus per-attempt JSON files. The summary records
the requested attempt count, required pass threshold, pass/flake counts,
per-phase status SHA-256 hashes, compact status field summaries, gate outcomes,
and the artifact policy. It is intentionally not a replacement for the
single-run diagnostic artifact when a new failure needs deep triage.

To soak the branch you are currently testing, dispatch the workflow with an
explicit ref guard through the cloud-only helper:

```sh
branch=$(git branch --show-current)
python3 tools/run_cloud_playability.py --ref "$branch" --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3 \
  --wait \
  --download-artifacts "build/cloud-soak-audio"
```

For an existing **Real WAD soak** run, use `--soak` to download and validate
the JSON metadata artifact without guessing the original attempt count:

```sh
python3 tools/run_cloud_playability.py --run-id RUN_ID --soak \
  --download-artifacts "build/cloud-soak-RUN_ID"
```

`expected_ref` is an early workflow guard: it fails before toolchain install or
WAD fetch if the selected `workflow_dispatch` branch/ref is not the branch you
intended to prove. GitHub can only dispatch a workflow file that already exists
on the repository default branch, so branch-only edits to
`.github/workflows/real-wad-soak.yml` are limited to host-only contract
validation until that workflow file is present on the default branch.

A soak is green only when the configured threshold passes the same repeated
criteria every successful attempt: playability, input state changes, SB16
continuity, and optional audible aggregate proof. The default threshold requires
every attempt to pass; lowering `min_passes` is useful for measuring flakes but
records the failed attempts in the summary. Validate a downloaded soak artifact
locally with:

```sh
python3 tools/check_cloud_playability_artifacts.py \
  --soak-summary path/to/real-wad-soak-metadata
```

The manual equivalent remains:

```sh
gh workflow run real-wad-soak.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f attempts=3 \
  -f min_passes=3 \
  -f audible_audio_proof=true
```

## Non-Pixel Evidence

The cloud proof requires these status families:

- CPU/runtime health: `pg=ON`, `pmm=OK`, `vmm=OK`, `vmmhi=OK`, `libc=OK`,
  `c=OK`, `usr=OK`, `heap=OK`, `free>0`, and `ticks>0` prove the
  protected-mode kernel, memory managers, C runtime probes, heap, and PIT timer
  are alive in the smoke VM. The `vmmhva`/`vmmhpa`/`vmmhpt`/`vmmhfree` fields
  additionally show the high-half alias, backing frame, dynamic page table, and
  reclaimed table frame.
- Process/exec: `exec=OK`, `path=DOOM.ELF`, `uexec=OK`,
  `upath=USERPROB.ELF`, `execsys=a/b/c/d/e/f`, `execerr=00000000`,
  `execres=00000000`, `target`, `entry`, `stack`, `argc`, `argv`, `envp`,
  `argv0`, `envp0`, `argvsrc=2`, `ppid`, `upid`, `uentry`, `doom=OK`, and
  `doomrun=RUN` show that the kernel loaded the boot probe and Doom through the
  exec resolver, performed a syscall-driven Doom handoff, seeded the user ABI
  stack from the copied user vector, recorded process parent metadata, and left
  Doom running rather than merely validating bytes on disk. `procpool=`,
  `pidseq=`, `fdexec=`, and
  `wait=` additionally show bounded process-slot reuse, PID generation
  movement, exec-time fd inheritance, and a userland wait/reap proof. The six
  `execsys`
  counters are attempts, successes, failures, handoffs, scheduled targets, and
  rollbacks.
- Storage/libc: `wad=OK`, `lmp=OK`, `doomopen=OK`, `doomread=OK`,
  `doomseek`, `doomsbrk`, `doommode`, `doomerr=00000000`,
  `doomerrno=00000000`,
  `doomexit=00000000`, `doomfault=00000000`, `doomfaultip=00000000`,
  `doomfaultv=00000000`, `doomfaulterr=00000000`, `fault=0/.../0`,
  `panic=NONE`, `shutdown=NONE`, and `doomlog` make
  WAD/FAT/syscall/process failures visible without uploading the WAD or disk
  image. On a Doom user fault, `doomfault` is CR2, `doomfaultip` is the
  faulting EIP, `doomfaultv` is the CPU exception vector, and `doomfaulterr`
  is the x86 error code. The compact `fault=` tuple records
  vector/error/eip/cs/esp/ss/cr2/pid/kind/state/last-syscall for the most
  recent fault frame. `panic=KEXC` is reserved for unhandled non-Doom kernel
  exceptions, and `shutdown=HALT`/`shutdown=REBOOT`/`shutdown=POWEROFF` mark
  intentional OS shutdown paths. Those shutdown/panic values only become proof
  when paired with the opt-in `shutdown-panic-proof.json` artifact and
  `tools/check_shutdown_panic_proof.py`; monitor `quit` cleanup does not count,
  and reboot/poweroff proof must observe QEMU exit from the guest request.
- Runtime: `gameplay=OK`, `gstate=00000000`, `gmap=00000101`, `gtic>0`, and
  `leveltime>0` prove the real engine reached E1M1 gameplay.
- Input pipeline: `inputqueue`, `inputpoll`, and `inputlast` expose the generic
  queue path used by Doom. `keyirq`, `keyqueue`, and `keypoll` increase from the
  early snapshot through the fire, movement, use, and menu snapshots, while
  `keyseen` and `keylast` prove the scripted Up/Ctrl/Space/Escape keys were the
  keys Doom consumed through `SYS_POLL_INPUT`.
- Player/action deltas: `pflags` records cumulative player, movement, attack,
  use, menu, position-delta, ammo-delta, refire, and turn observations;
  `pdelta>0`
  and a changed `ppos` between `status.after-start.txt` and
  `status.after-move.txt` prove the player moved in Doom state, not only that a
  key was delivered. The raw `pammo`/`prefire` fields must also change across
  the fire phase, so Ctrl cannot pass as a key counter or cumulative flag alone.
- Mouse turn proof: `status.after-mouse.txt` must include both PS/2 mouse
  IRQ/packet/generic-poll counters, the `pflags` turn bit, and a raw `pangle` /
  `pangledelta` change from Doom gameplay state. The runtime sets the turn bit
  from Doom's live `ticcmd.angleturn` when sampled, or from a durable
  player-angle delta after Doom has applied the command, so mouse proof cannot
  pass on kernel delivery alone.
- Menu state: `status.after-start.txt` must have the menu bit clear, and
  `status.after-menu.txt` plus final `gflags` must have it set after Escape,
  proving the scripted input toggled Doom UI state while remaining in
  `GS_LEVEL`.
- Visual presence without pixels: `doompal`, `doomframe`, `doomnonzero`,
  `doomcolors`, and `doomsamp` summarize palette/frame activity without
  uploading `gfx.bin` or any rendered frame bytes. `fb`, `fbpolicy`, `fbgeom`,
  and `fbdirty` prove whether the run used Mode 13h, aspect-correct integer LFB
  scaling (`ASP`), or the labeled square fallback (`SQ`), plus the centered
  viewport and changed source bounds.
- Doom timer proof: `dtick` is the kernel's 35 Hz Doom time conversion and must
  equal `floor(ticks * 35 / 100)`, so the real-WAD checker can distinguish PIT
  progress from Doom's expected tic rate.
- Audio/mouse observability: `audio`, `adev`, `pcm`, `pcmbuf`, `doomsound`,
  `sfxmix`, `sfxdma`, `voices`, `sfxvoices`, `musicvoices`, `musicmix`,
  `musicloop`, `musicpos`, `musicbuf`, `musicunder`, `musicdrops`, `musicrend`,
  `sb16`, `dma`, `play`, `voiceq`, `musicq`, `audioirq`, `ack8`,
  `ack16`, `refill`, mixer safety counters, `mouse`,
  `mouseirq`, `mousepkt`, and `mousepoll` are required to be present and
  well-formed. The automated mouse phase requires `mouse=OK` and proves IRQ12,
  packet decode, and Doom generic-input consumption increased without
  uploading pixels.
  `tools/check_audio_continuity_proof.py` is the stricter SB16 path: it compares
  the phase snapshots using status snapshots only, requires `audio=SB16`,
  proves the generic audio device/PCM ring contract through `adev=`, `pcm=`, and
  `pcmbuf=`, and proves SB16 version, DMA programming, playback start, voice
  queue, IRQ/refill, non-music SFX, `sfxdma=` SFX bytes from the IRQ-driven DMA
  refill mixer, music mixing, kernel-visible `musicpos=` progress, and
  pull-requested music chunk service with advancing `musicpull=` counters plus
  `musicrend=` renderer provenance progressed without
  uploading audio samples. It does not upload audio samples.
  `tools/check_audio_continuity_proof.py` checks status snapshots only and
  does not upload audio samples.
- Optional audible-output proof: when the manual workflow is run with
  `audible_audio_proof=true`, QEMU uses a temporary WAV backend on the
  disposable runner, `tools/check_audible_audio_proof.py` reduces that file to
  aggregate `audio-proof.json`, and the workflow deletes the WAV before upload.
  The manifest proves non-silent remote audio output tied to the final
  `audio=SB16` status counters and the same status-only SB16 continuity gate.
  It fails if the music path moves but non-music `sfxmix=` or IRQ-refill
  `sfxdma=` does not progress, and it does not upload the WAV or any captured
  samples.
- Scheduler proof: `preempt`, `pirq`, `pattempt`, `pskip`, `puser`, `pround`,
  `pctx`, `pmask`, `pfrom`, `pto`, `pkind`, `peip`, `pcr3`, `pkstk`, `pspin`, and
  `pself=OK` expose live PIT preemption. A valid proof requires `pirq` to match
  `preempt`, Ring 3 timer IRQs, switches in both directions between Doom and
  the preempt probe, a switch between different PIDs, Doom/preempt probe kinds,
  nonzero source/target EIPs, distinct Doom/preempt-probe CR3s, distinct
  Doom/preempt-probe kernel stacks, and a `pspin` value beyond the seeded
  `50524545` magic from the alternate Ring 3 preempt probe.

`tools/check_vm_status_proof.py` is the legitimacy ratchet for the VM/process
status fields. It requires `vmmhfree` to match the reclaimed `vmmhpt` frame,
`uexec=OK`/`upath=USERPROB.ELF` for the boot probe, `argvsrc=2` for the Doom
exec path, `procpool=`/`fdexec=`/`wait=` for bounded process-slot reuse,
exec-time fd inheritance, and the wait/reap proof, and
`pmask` plus `pkind`/`peip`/`pcr3`/`pkstk` to cross the Doom/preempt-probe tasks,
user windows, address spaces, and kernel stacks in both directions during timer
IRQ preemption.

`tools/check_real_wad_proof.py` gates the real-WAD status on both the non-pixel
visual proof and the scripted playability proof, plus the system/process/storage
debug contract above. A final status line by itself is not sufficient: the gate
uses `status.after-start.txt` as the post-Doom-start baseline and requires the
start, fire, movement, use, mouse, and menu snapshots so
keyboard and mouse counters plus Doom action flags and position/ammo/menu state
can be compared across the scripted phases. It rejects
duplicate fields, malformed hex, weak synthetic exec counters, Doom error
strings, failed self-tests, and status lines that only prove a boot banner.
`tools/check_vm_status_proof.py` is the executable VM/process status gate for
the paging, exec, and preemption fields in that debug contract.
`tools/check_human_playability_proof.py` can also compare the phase snapshots
directly.
`tools/check_scripted_gameplay_proof.py` is stricter about ordering than the
general playability checker: `status.after-start.txt` must be a clean E1M1
new-game state with no scripted key bits, no action proof flags, no menu bit,
and `pdelta=00000000`; later snapshots must retain cumulative key/player proof
bits rather than merely showing a final aggregate. It then requires movement to
change `ppos`, the mouse phase to advance IRQ/packet/poll counters and set
Doom gameplay turn proof bit while retaining button/motion proof, and
Escape to flip the menu bit while the game remains in `GS_LEVEL`.
The same manifest's performance diagnostics distinguish remote presentation
slowdown from OS pressure: `os-input-backlog` or `os-input-loss` points at
generic input drain/drop trouble, `os-audio-pressure` points at SB16 refill or
mixer pacing, `os-preemption-stalled` points at timer scheduling, and
`os-pipeline-healthy` means those OS-side counters stayed healthy even if
noVNC felt slow.

## Safe Remote Runbook

1. Open the **Real WAD smoke** workflow in GitHub Actions and run it manually.
   Leave `wad_url` empty to use `REAL_DOOM_WAD_URL` or the public shareware
   fallback, or provide a temporary URL to `DOOM1.WAD`, `DOOM1.WAD.gz`, or a zip
   containing `DOOM1.WAD`.
2. Confirm the fetch step prints the expected shareware v1.9 size and SHA-1.
   The workflow rebuilds with `DOOM_WAD=/tmp/DOOM1.WAD` and deletes that local
   WAD after the post-smoke validation.
3. Review `status.early.txt`, `status.after-start.txt`,
   `status.after-fire.txt`, `status.after-move.txt`, `status.after-use.txt`,
   `status.after-mouse.txt`, `status.after-menu.txt`, and `status.txt` in the
   uploaded diagnostic artifact. These are text status files, not framebuffer
   or WAD artifacts. The same artifact should include `doom.symbols` so
   `tools/triage_cloud_status.py` can symbolize `doomfaultip` if Doom reaches
   user mode and faults.
   The real-WAD checker consumes them like this. The audible checker applies
   only when `audible_audio_proof=true` produced `audio-proof.json`:

   ```sh
   python3 tools/check_real_wad_proof.py \
     --baseline build/status.after-start.txt \
     --start build/status.after-start.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --mouse build/status.after-mouse.txt \
     --menu build/status.after-menu.txt \
     build/status.txt

   python3 tools/check_scripted_gameplay_proof.py \
     --start build/status.after-start.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --mouse build/status.after-mouse.txt \
     --menu build/status.after-menu.txt \
     --write-json build/gameplay-proof.json \
     build/status.txt

   python3 tools/check_vm_status_proof.py \
     --require-exec \
     --require-preempt \
     build/status.txt

   python3 tools/check_audio_continuity_proof.py \
     --require-pull-stream \
     --baseline build/status.after-start.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --menu build/status.after-menu.txt \
     build/status.txt

   python3 tools/check_audible_audio_proof.py build/audio-proof.json
   ```

4. Treat the run as playable-cloud-proof green only when the QEMU capture step
   finishes, the gameplay/input/audio checker steps pass, and
   `tools/check_cloud_playability_artifacts.py --require-gameplay-proof`
   accepts the downloaded artifact. If `audible_audio_proof=true`, also require
   `--require-audible-proof`.
   That artifact gate rejects WAD/disk/image/pixel filenames, duplicate required
   status basenames, and renamed WAD/disk/image payload signatures. The workflow
   intentionally keeps proof assertions in the checker steps so a failed cloud
   boot still uploads status files and prints the exact failing fields.

This is still not a substitute for a human visually playing Doom, but it is a
stronger cloud-safe proxy: it proves real-WAD boot, level progression, input
delivery, player movement, fire/use commands, and menu control through the same
kernel/port paths a human session uses.

For a live human session, use the Remote Doom Playtest Runbook in
`docs/runbooks/remote-doom-playtest.md`. That path keeps QEMU on a disposable
remote host, connects through VNC over SSH, and uses
`tools/collect_human_playtest_bundle.py --capture-phase` on the remote host to
capture each named status phase from the QEMU monitor without keeping
`status.*.bin`, then uses the same collector to build an allowlisted proof
bundle before download. The bundle is then validated with
`tools/check_cloud_playability_artifacts.py --human-session`, including
`human-playtest-notes.txt`, `human-playtest-checklist.txt`,
`human-playtest-session.json`, and `human-playtest-manifest.json`, without
storing WAD data, disk images, audio captures, or rendered pixels in the repo.
The session transcript records the linked passing real-WAD run ID, exact phase
order, operator confirmations, per-status byte counts, SHA-256 hashes, and
compact status summaries; the notes also carry `phase_hash_early` through
`phase_hash_final` so the checker can compare the human note hashes against the
downloaded status files. The generated checklist records the post-download
review commands and the phase hashes, and the manifest ties the notes,
checklist, session transcript, and diagnostics to exact byte counts and SHA-256
hashes. The manifest records `requires_post_download_verification=true`, and
the local checker prints a `post-download human verification OK` line with
`session_id`, `bundle_sha256`, `manifest_sha256`, and short phase hashes to
compare against the remote collector's `pre-download human verification OK`
line.
