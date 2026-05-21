# Remote Doom Playtest Runbook

This is the safe human-run path for playing vibe-os Doom without running QEMU on
the laptop and without committing or uploading WAD data, disk images, or Doom
pixels to the repository.

For the copy-paste cloud path, including noVNC and SPICE options, use
`docs/runbooks/cloud-interactive-playtest.md`. The safety rail is the same here:

- `CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC`: do not run QEMU, `make run`,
  `make run-headless`, `make smoke`, or `ALLOW_LOCAL_VM=1` on the Mac.
- `CLOUD_PLAYTEST_REMOTE_QEMU_ONLY`: QEMU commands in this runbook are for the
  disposable remote host only.
- `CLOUD_PLAYTEST_FORBIDDEN_UPLOADS`: never upload or copy WADs, `disk.img`,
  raw disk images, raw audio, screenshots, framebuffer dumps, rendered pixels,
  or `status.*.bin` files off the disposable host.
- `CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST`: only status text, logs, ELF diagnostics,
  `doom.symbols`, human-playtest notes/checklist/session/manifest files, and
  optional aggregate `audio-proof.json` may leave the disposable host.

Use a disposable remote Ubuntu VM, Codespace, or throwaway remote host that runs
QEMU. The host only needs CPU emulation; hardware virtualization is helpful but
not required because the runbook uses QEMU TCG. This does not prove vibe-os boots
directly on physical hardware; that remains outside the current
`docs/hardware-support.md` matrix claims.

## Remote Host Setup

Install the same build tools used by CI:

```sh
sudo apt-get update
sudo apt-get install -y nasm qemu-system-x86 clang make netcat-openbsd curl
git clone https://github.com/jadentripp/vibe-os.git
cd vibe-os
```

Fetch and validate the shareware WAD on the remote host only:

```sh
python3 tools/prepare_shareware_wad.py \
  --url "$DOOM_WAD_URL" \
  --output /tmp/DOOM1.WAD
```

`DOOM_WAD_URL` may point to `DOOM1.WAD`, `DOOM1.WAD.gz`, or a zip containing
`DOOM1.WAD`. The tool validates the shareware v1.9 size and SHA-1 before writing
the output path. Keep `/tmp/DOOM1.WAD` outside git and delete it when finished.

Build the raw disk image on the remote host:

```sh
rm -f build/disk.img
make DOOM_WAD=/tmp/DOOM1.WAD
```

That preserves valid cached compilation outputs on reruns but forces the boot
image to bind the freshly validated WAD. The faster `tools/play_now_remote.sh`
path does this for you.

## Interactive Boot

Start QEMU on the remote host with a loopback-only VNC display and monitor
socket:

```sh
# CLOUD_PLAYTEST_REMOTE_QEMU_ONLY: run this block on the disposable remote host,
# never on macOS.
mkdir -p build
qemu-system-x86_64 \
  -machine pc,accel=tcg \
  -audiodev none,id=snd0 \
  -device sb16,audiodev=snd0 \
  -drive file=build/disk.img,format=raw,if=ide,index=0,media=disk \
  -boot c \
  -display vnc=127.0.0.1:1 \
  -serial file:build/serial.remote.log \
  -monitor unix:build/monitor.remote.sock,server,nowait \
  -no-reboot \
  -no-shutdown
```

From your laptop, tunnel only the VNC port:

```sh
ssh -L 5901:127.0.0.1:5901 user@remote-host
```

Then connect a VNC client to `localhost:5901`. The QEMU display is remote; no
local QEMU process is involved.

## Controls To Try

Expected keyboard controls:

- Arrow keys: move and turn.
- Ctrl: fire.
- Space: use/open.
- Enter: confirm menu items.
- Escape: open or close the Doom menu.
- Shift, Alt, Tab, number keys, and F1-F12 are translated by the PS/2 keyboard
  path, but the current automated proof only gates fire, move, use, and menu.

Expected mouse behavior:

- `mouse=OK` means the PS/2 auxiliary device initialized. The automated
  real-WAD workflow now injects `mouse_move` plus a button click and
  captures `status.after-mouse.txt`; the checker requires `mouseirq`,
  `mousepkt`, and `mousepoll` to increase, proving the event reached Doom
  through `SYS_POLL_INPUT`.
- In a manual VNC session, relative movement and the first three buttons should
  turn/aim/fire through normal Doom `ev_mouse` events. VNC grab/release and
  host pointer acceleration are still worth noting in the playtest notes.

Expected audio behavior:

- `-audiodev none,id=snd0 -device sb16,audiodev=snd0` exposes the intended
  Sound Blaster 16 target to the guest while discarding audio bytes on the
  disposable remote host.
- Status should report `audio=SB16` when the probe succeeds and `audio=NONE`
  when the remote QEMU/audio setup does not expose the device.
- `dtick=` must equal `floor(ticks * 35 / 100)`, proving the guest exposes
  Doom's 35 Hz time base separately from raw PIT interrupt ticks.
- VNC does not carry audio. Treat sound as status/counter proof unless you also
  configure remote audio forwarding on the disposable host.
- Run `tools/check_audio_continuity_proof.py --require-pull-stream` on the
  downloaded status snapshots. It proves SB16 version, DMA programming,
  playback start, voice queue, IRQ/refill, SFX, music mixing, pull-requested
  music chunk service, `musicpull=` request/refill counters, and `musicrend=`
  renderer provenance progressed; it does not upload audio samples or prove a
  human heard sound.
- For an audible remote proof that still avoids publishing copyrighted audio, run
  the GitHub workflow with `audible_audio_proof=true`. That uses QEMU's WAV
  backend on the disposable runner, analyzes the temporary capture into
  aggregate `audio-proof.json`, validates it with
  `tools/check_audible_audio_proof.py`, requires the same status-only SB16 continuity
  snapshots so music alone cannot pass as SFX proof, and deletes the
  temporary WAV before upload. Keep the manifest and status files; do not upload
  or keep captured Doom audio.
- For a manual listener check, use remote audio forwarding on the disposable
  host and record written notes only. If you make a local audio capture to debug
  clipping or balance, delete the temporary WAV when done and do not add it to a
  diagnostic artifact.

## Human Status Capture

Capture non-pixel status while the VM is running. The fastest remote proof path
is the guided helper from a second SSH shell on the disposable host:

```sh
./tools/run_remote_human_playtest.sh \
  --playtester "<name-or-initials>" \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"
```

Before a live capture, you can print the exact status-only command template
without reading artifacts or touching QEMU:

```sh
python3 tools/collect_human_playtest_bundle.py \
  --print-template \
  --build-dir build \
  --output-dir /tmp/vibe-os-human-proof \
  --playtester "<name-or-initials>" \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>" \
  --commit "$(git rev-parse --short=12 HEAD)"
```

The template includes the capture loop, collector command, tarball command,
local post-download checkers, cleanup notes, the safe artifact policy, and the
4+ CPU Codespaces/noVNC recommendation. It ends with
`dry-run: no files were copied`, and QEMU is not launched.

It prompts the human for each VNC action, calls the collector's
`--capture-phase` helper for all eight phases, runs the bundle collector with
the required `--confirm-*` flags, validates the allowlisted bundle before
download, creates `/tmp/vibe-os-human-proof.tgz`, and prints the exact `scp` and
local `--human-session` command with the expected commit and scripted proof run
ID baked in. Before capture it asks the operator to confirm the linked Real WAD
smoke run is green; after capture it records slowdown as `not-observed`, `mild`,
`moderate`, or `severe` plus a short status-only note. It does not launch QEMU
and refuses to run on macOS.
Before the first capture prompt, it also validates that `--playtester` matches
the notes schema, `--scripted-proof-run-id` is a numeric GitHub Actions run ID,
and both the proof output directory and proof tarball live outside the git
checkout. If any of those checks fail, stop and fix the remote scratch paths
instead of collecting a session that the Mac-side checker will reject later.

Manual equivalent: use the collector's
`--capture-phase` helper so the remote QEMU monitor writes one temporary memory
snapshot, the helper decodes it to the exact required text filename, and the
temporary `status.*.bin` file is deleted immediately. Use the same filenames as
the scripted cloud proof so the local checkers can compare real human actions
across the same phases:

```sh
capture_status() {
  phase="$1"
  python3 tools/collect_human_playtest_bundle.py \
    --build-dir build \
    --monitor-socket build/monitor.remote.sock \
    --capture-phase "$phase"
  status_file="build/status.$phase.txt"
  if [ "$phase" = final ]; then status_file="build/status.txt"; fi
  sed -n '1,220p' "$status_file"
}

# Capture before input, then play through VNC and capture after each action.
# Do not synthesize these inputs through the QEMU monitor for a human claim:
# one person should use the VNC client and wait for the visible response before
# each capture. The strict checker requires at least 350 Doom ticks, about ten
# seconds of in-game time, from after-start to final.
capture_status early
# Confirm E1M1 is visibly up in VNC.
capture_status after-start
# Press Ctrl/fire in VNC.
capture_status after-fire
# Hold an arrow key long enough to move or turn.
capture_status after-move
# Press Space/use.
capture_status after-use
# Move the mouse and click once.
capture_status after-mouse
# Press Escape to open the menu.
capture_status after-menu
# Leave the session up long enough to cross the proof duration window, then
# capture the final status from the same remote VNC session.
capture_status final
```

The helper understands only the eight proof phases: `early`, `after-start`,
`after-fire`, `after-move`, `after-use`, `after-mouse`, `after-menu`, and
`final`. `final` is written to `build/status.txt`; the other phases are written
to `build/status.<phase>.txt`. Each successful capture prints
`human status capture OK` plus a compact `status audit summary:` line. If the
captured status page is missing any field required by
`human-playtest-session.json`, the helper fails immediately and deletes the
temporary `status.*.bin` capture instead of letting a weak phase reach the
bundle step.

Collect the manual proof bundle on the disposable remote host. Use an empty
scratch directory outside the repository. The collector does not launch QEMU; it
copies only status text, logs, ELF diagnostics, `doom.symbols`, optional
`audio-proof.json`, writes `human-playtest-notes.txt`, writes
`human-playtest-checklist.txt` with `schema=human-playtest-checklist-v1`, writes
a structured `human-playtest-session.json` transcript for every manual phase,
writes a `human-playtest-manifest.json` SHA-256 inventory, and then runs
`tools/check_cloud_playability_artifacts.py --human-session` against the bundle.
It deliberately skips `disk.img`, WADs, status binaries, screenshots, pixel
dumps, and raw audio:

```sh
python3 tools/collect_human_playtest_bundle.py \
  --build-dir build \
  --output-dir /tmp/vibe-os-human-proof \
  --playtester "<name-or-initials>" \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>" \
  --audio status-only \
  --slowdown not-observed \
  --slowdown-notes "not-observed-during-capture" \
  --confirm-scripted-proof-green \
  --confirm-remote-vnc \
  --confirm-e1m1-visible \
  --confirm-keyboard-fire \
  --confirm-keyboard-move \
  --confirm-keyboard-use \
  --confirm-mouse-action \
  --confirm-menu-escape \
  --confirm-slowdown-notes \
  --confirm-phase-actions \
  --confirm-phase-status-hashes \
  --confirm-no-forbidden-artifacts \
  --confirm-post-download-verification
```

`audio=` may be `status-only`, `listener-pass`, `audio-proof-json-pass`, or
`not-tested`. Use `audio-proof-json-pass` only when the bundle also contains a
validated aggregate `audio-proof.json`. `--scripted-proof-run-id` must be the
GitHub Actions **Real WAD smoke** run ID that already passed for the code being
human-played. The `--confirm-*` flags are deliberate operator confirmations:
they say the linked scripted run was green first, the playtester used the remote
VNC display, E1M1 was visible, Ctrl/fire worked, arrow movement or turning
worked, Space/use worked, mouse movement/click worked, Escape opened the menu,
slowdown was recorded honestly, the named status phase files were captured
after the actions, WAD/disk/pixel/raw-audio artifacts were excluded, and the
checker will be rerun after download. Keep subjective comments in
`--slowdown-notes` or separate status-only notes if useful, but do not store
screenshots, audio captures, WADs, disk images, `status.*.bin` files, or ad hoc
binaries in the proof directory.

If you need to audit the exact notes format, the collector writes these required
keys: `schema=human-playtest-notes-v2`, `commit=...`,
`scripted_proof=real-wad-smoke-pass`, `scripted_proof_run_id=...`,
`scripted_proof_url=https://github.com/jadentripp/vibe-os/actions/runs/...`,
`scripted_proof_checked=green-before-human-session`,
`proof_basis=scripted-green-plus-remote-vnc-human`,
`playtester=...`, `remote_host=disposable`, `qemu_location=remote`,
`qemu_display=127.0.0.1:1`, `monitor_socket=unix-monitor-socket`,
`vnc_tunnel=loopback-only`, `vnc_endpoint=127.0.0.1:5901`,
`wad=shareware-v1.9-validated-remote-only`, `display=pass`,
`keyboard=pass`, `mouse=pass`,
`visual_evidence=e1m1-visible-via-remote-vnc`,
`keyboard_evidence=fire-move-use-menu-visible`,
`mouse_evidence=motion-click-visible`,
`menu_evidence=escape-menu-visible`,
`slowdown=not-observed|mild|moderate|severe`,
`slowdown_notes=...`,
`status_capture=monitor-pmemsave-0x9d000`,
`session_phases=early,after-start,after-fire,after-move,after-use,after-mouse,after-menu,final`,
`phase_hash_early=...`, `phase_hash_after_start=...`,
`phase_hash_after_fire=...`, `phase_hash_after_move=...`,
`phase_hash_after_use=...`, `phase_hash_after_mouse=...`,
`phase_hash_after_menu=...`, `phase_hash_final=...`,
`diagnostics=non-wad-status-only`, `proof_bundle=allowlisted-status-only`,
`no_local_qemu=yes`, `no_wad_upload=yes`, `no_disk_upload=yes`, and
`no_pixel_upload=yes`, `operator_scripted_proof_green=confirmed`,
`operator_remote_vnc=confirmed`,
`operator_e1m1_visible=confirmed`,
`operator_keyboard_fire=confirmed`,
`operator_keyboard_move=confirmed`,
`operator_keyboard_use=confirmed`,
`operator_mouse_action=confirmed`,
`operator_menu_escape=confirmed`,
`operator_slowdown_notes=recorded`,
`operator_phase_actions=confirmed`,
`operator_phase_status_hashes=confirmed`,
`operator_no_forbidden_artifacts=confirmed`, and
`operator_post_download_verification=required`.

The companion `human-playtest-session.json` uses
`schema=human-playtest-session-v1`. It records the remote endpoint, human
attestations, operator confirmations, the linked scripted real-WAD run ID, the
exact phase order, the `phase_status_hashes` copied from the notes, each
required status file, byte count, SHA-256 hash, and a compact status summary for
that phase. The artifact checker rebuilds that transcript from the bundle and
fails if any status file, note value, phase order, hash, or summary was changed
after collection. It also checks that every `phase_hash_*` note exactly matches
the current status file content.

The companion `human-playtest-checklist.txt` uses
`schema=human-playtest-checklist-v1` and gives the post-download human review
commands plus the phase hashes copied from the status files. The checker
rebuilds it from the notes and status files so stale checklist text cannot pass
as fresh human evidence.

The companion `human-playtest-manifest.json` uses
`schema=human-playtest-manifest-v1` and is generated by the collector. It lists
the expected status, ELF, symbol, log, optional aggregate-audio, notes,
checklist, and session files with byte counts and SHA-256 hashes, plus the
status-only artifact policy. The artifact checker requires this manifest in
`--human-session` mode, requires the bundle to be flat and allowlisted, records
`requires_post_download_verification=true`, and rejects bundles whose file
inventory or hashes changed after collection.

Download `/tmp/vibe-os-human-proof` or a tarball of it. Do not download
`build/disk.img` or `/tmp/DOOM1.WAD`.

If you used `tools/run_remote_human_playtest.sh`, download only the tarball it
prints, then run the printed local checker commands and compare the local
`post-download human verification OK` line with the remote `pre-download human
verification OK` line.
The guided helper prints both post-download gates: the bundle-level
`tools/check_cloud_playability_artifacts.py --human-session` command and the
strict `tools/check_human_playability_proof.py --require-human-session` command
with the same expected commit and scripted Real WAD smoke run ID.
Do not create the tarball inside the repository checkout. The guided helper
refuses repo-local tarball paths and only packages the flat allowlisted proof
directory it just validated.

For a fully automated truth-serum run, use the GitHub Actions **Real WAD smoke**
workflow instead of this manual VNC path. It captures:

- `status.early.txt`
- `status.after-start.txt`
- `status.after-fire.txt`
- `status.after-move.txt`
- `status.after-use.txt`
- `status.after-mouse.txt`
- `status.after-menu.txt`
- `status.txt`
- `smoke.log`, `qemu.log`, `monitor.log`, and `serial.log`
- `kernel.elf`, `user_probe.elf`, `doom.elf`, and `doom.symbols`

It deliberately does not upload `disk.img`, `gfx.bin`, `vga*.txt`, WAD files, or
rendered Doom pixels.

For repeated flake detection, use the GitHub Actions **Real WAD soak** workflow.
It runs the same real-WAD cloud proof multiple times and uploads only JSON
metadata: per-attempt status summaries plus `real-wad-soak-summary.json`. The
soak summary is the aggregate proof artifact; it does not contain WAD bytes,
disk images, logs, framebuffer data, raw status text, rendered pixels, or raw
audio. The default `min_passes` value equals `attempts`, so any failed attempt
marks the run red while still leaving a JSON flake record. Lower `min_passes`
only when intentionally measuring intermittent behavior.

Dispatch the soak against the branch under test and set the matching
`expected_ref` guard:

```sh
branch=$(git branch --show-current)
gh workflow run real-wad-soak.yml \
  --ref "$branch" \
  -f expected_ref="$branch" \
  -f attempts=3 \
  -f min_passes=3
```

The workflow also has a Run workflow branch selector in GitHub's UI. The
`expected_ref` input fails early if the selected `workflow_dispatch` ref does
not match the branch you meant to prove, before any WAD fetch. GitHub only
offers manual dispatch for workflow files that already exist on the repository
default branch; when this branch changes only `.github/workflows/real-wad-soak.yml`,
the repeat proof cannot be dispatched from the UI until that workflow file is
available on default. In that case, the host-only guard is:
`python3 tools/check_cloud_playability_artifacts.py --repo-contract`.

The repeated pass criteria are explicit in the summary and in
`tools/check_cloud_playability_artifacts.py`: playability, input state changes, SB16 continuity, and optional audible aggregate proof.
In concrete terms, every successful attempt must have passed the real-WAD proof, the scripted
human-playability gate that checks fire/move/use/mouse/menu state deltas, and
the status-only SB16 continuity gate. If `audible_audio_proof=true`, every
successful attempt must also include a validated aggregate `audio-proof.json`
reduced from a temporary remote WAV; the soak artifact keeps only the JSON
summary and never uploads the WAV.

After downloading the `real-wad-soak-metadata` artifact, validate it locally:

```sh
python3 tools/check_cloud_playability_artifacts.py \
  --soak-summary path/to/real-wad-soak-metadata
```

After downloading the diagnostic artifact, validate it locally without WAD data
or QEMU. The artifact checker also rejects duplicate status basenames and
renamed WAD/disk/image payload signatures, so do not add extra binaries to the
diagnostic directory:

```sh
python3 tools/triage_cloud_status.py path/to/real-wad-smoke-status/status.txt

python3 tools/check_real_wad_proof.py \
  --baseline path/to/real-wad-smoke-status/status.after-start.txt \
  --start path/to/real-wad-smoke-status/status.after-start.txt \
  --fire path/to/real-wad-smoke-status/status.after-fire.txt \
  --movement path/to/real-wad-smoke-status/status.after-move.txt \
  --use path/to/real-wad-smoke-status/status.after-use.txt \
  --mouse path/to/real-wad-smoke-status/status.after-mouse.txt \
  --menu path/to/real-wad-smoke-status/status.after-menu.txt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_human_playability_proof.py path/to/real-wad-smoke-status/status.txt

python3 tools/check_human_playability_proof.py \
  --baseline path/to/real-wad-smoke-status/status.after-start.txt \
  --start path/to/real-wad-smoke-status/status.after-start.txt \
  --fire path/to/real-wad-smoke-status/status.after-fire.txt \
  --movement path/to/real-wad-smoke-status/status.after-move.txt \
  --use path/to/real-wad-smoke-status/status.after-use.txt \
  --mouse path/to/real-wad-smoke-status/status.after-mouse.txt \
  --menu path/to/real-wad-smoke-status/status.after-menu.txt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_vm_status_proof.py \
  --require-exec \
  --require-preempt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_audio_continuity_proof.py \
  --require-pull-stream \
  --baseline path/to/real-wad-smoke-status/status.after-start.txt \
  --fire path/to/real-wad-smoke-status/status.after-fire.txt \
  --movement path/to/real-wad-smoke-status/status.after-move.txt \
  --use path/to/real-wad-smoke-status/status.after-use.txt \
  --menu path/to/real-wad-smoke-status/status.after-menu.txt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_audible_audio_proof.py \
  path/to/real-wad-smoke-status/audio-proof.json

python3 tools/check_cloud_playability_artifacts.py path/to/real-wad-smoke-status

python3 tools/check_cloud_playability_artifacts.py \
  --human-session path/to/vibe-os-human-proof \
  --expected-commit "$(git rev-parse --short=12 HEAD)" \
  --expected-scripted-proof-run-id "<passing-real-wad-smoke-run-id>"

python3 tools/check_human_playability_proof.py \
  --require-human-session \
  --human-notes path/to/vibe-os-human-proof/human-playtest-notes.txt \
  --expected-commit "$(git rev-parse --short=12 HEAD)" \
  --expected-scripted-proof-run-id "<passing-real-wad-smoke-run-id>" \
  path/to/vibe-os-human-proof/status.txt
```

The audible checker command is only expected to pass when the workflow was
triggered with `audible_audio_proof=true` and the artifact contains
`audio-proof.json`. The `--human-session` artifact check is for the manual VNC
bundle and requires `human-playtest-notes.txt`; if you used
`tools/collect_human_playtest_bundle.py`, that check already ran once on the
remote host before download. The collector prints a `pre-download human
verification OK` line containing `session_id=`, `bundle_sha256=`,
`manifest_sha256=`, and short `phase status hashes:`. The local
`--human-session` command prints the same values under `post-download human
verification OK`; compare them exactly before treating the downloaded bundle as
the evidence packet.

The strict human-playability checker is the pass/fail gate for the manual
session itself. In `--require-human-session` mode it requires all eight status
snapshots, verifies the `human-playtest-notes.txt` commit and scripted run ID,
recomputes every note-level `phase_hash_*` value from the downloaded status
files, rejects WAD/disk/pixel/raw-audio payloads in the proof directory, and
requires at least 350 Doom ticks of elapsed `gtic=` and `leveltime=` from
`status.after-start.txt` to `status.txt`.

`triage_cloud_status.py` auto-loads `doom.symbols` from the artifact directory,
so a `doom-user-fault` report should include the nearest Doom function for
`doomfaultip` plus page-fault/WAD I/O context.

## Manual Review Checklist

Call a remote human playtest credible only after checking all of this:

- The image was built on the remote host with a validated external
  `DOOM1.WAD`; no WAD is tracked in git.
- Doom reaches the title/menu or E1M1 visually in the VNC display.
- Verify keyboard and mouse actions visibly affect Doom: Arrow keys, Ctrl, Space,
  Enter, Escape, and relative mouse movement/clicks all change the menu or E1M1.
- The downloaded manual proof bundle contains `human-playtest-notes.txt`,
  `human-playtest-checklist.txt`, `human-playtest-session.json`,
  `human-playtest-manifest.json`,
  `status.early.txt`, `status.after-start.txt`, `status.after-fire.txt`,
  `status.after-move.txt`, `status.after-use.txt`, `status.after-mouse.txt`,
  `status.after-menu.txt`, `status.txt`, `doom.symbols`, and the diagnostic ELF
  files, was produced with `tools/collect_human_playtest_bundle.py`, and
  `tools/check_cloud_playability_artifacts.py --human-session` passes.
- The notes are `schema=human-playtest-notes-v2`, include every `phase_hash_*`
  field, include the per-control `operator_*` confirmation fields, include
  `scripted_proof_url=`, `scripted_proof_checked=green-before-human-session`,
  and `slowdown=` / `slowdown_notes=`, and the local
  `post-download human verification OK` line matches the remote
  `pre-download human verification OK` line.
- The generated checklist is `schema=human-playtest-checklist-v1`, names the
  same session ID, commit, scripted proof run ID, scripted proof URL, slowdown
  note, phase hashes, and local checker commands you used after download.
- `tools/check_human_playability_proof.py --require-human-session` passes with
  `--human-notes`, the expected commit under test, and the linked passing
  real-WAD smoke run ID. A final-only checker pass is not enough for the manual
  human gate.
- `status.txt` or the GitHub artifact reports `gameplay=OK`,
  `gmap=00000101`, increasing `gtic`/`leveltime`, nonzero `keyirq`,
  `keyqueue`, and `keypoll`, `keyseen` bits for Up/Ctrl/Space/Escape, nonzero
  `mouseirq`/`mousepkt`/`mousepoll` when mouse is expected, changed `ppos` from
  `status.after-start.txt` to
  `status.after-move.txt`, fire ammo/refire evidence in `pflags`, mouse turn
  evidence from Doom gameplay state, and menu inactive-to-active evidence after
  Escape.
- Save/config writes are attempted from Doom and then checked after a rebooted
  remote image before claiming persistence beyond the current host tests. The
  GitHub **Real WAD smoke** workflow has an opt-in `persistence_proof` input
  for this path, and setting `persistence_save_slot=N` also enables the same
  path. It copies the fresh `build/disk.img` to a runner-local baseline
  immediately after rebuilding the real-WAD image, restores that baseline before
  the persistence boot, plants a marker file requesting either default-config
  persistence or a specific `DOOMSAVN.DSG` save slot, checks that the requested
  file changed from that baseline, captures an after-write image snapshot, boots
  the same image again with a load marker when save-slot proof is requested, and
  checks that the requested FAT entries still match the after-write snapshot.
  The checker summary is saved as status text; the disk image and WAD are not
  uploaded.

  If your input script creates a save, set `persistence_save_slot` to require
  the matching `DOOMSAVN.DSG`. The save-slot checker now rejects proof without a
  fresh baseline whose requested slot is empty, then requires a Doom-shaped save
  payload: NUL-terminated description, exact `version 110`, single-player
  header, nonzero leveltime, plausible archived player/world state, and Doom's
  final `0x1d` consistency marker. The rebooted save-slot proof also requires
  `--save-write-status build/status.persistence-write.txt`, so the first boot
  has to show a fault-free live Doom run with write/close counters and an
  `O_WRONLY|O_CREAT|O_TRUNC` save-file open. It also requires
  `--load-status build/status.persistence-load.txt` on the reboot/load boot:
  `doomsav=` must name the requested slot, `saverd=` must cover the full
  savegame payload rather than only the menu description, and the final status
  must be back in matching gameplay. The workflow slot path uses marker files
  in the FAT image to request save and load work from Doom, so it does not rely
  on a timed menu-key script.

  For a manual remote proof, copy a fresh baseline before booting, create the
  save in Doom, snapshot the after-write image, reboot the same image, capture
  the reboot status text, and run the image-local checker on the disposable host,
  not on the laptop:

  ```sh
  cp build/disk.img /tmp/vibe-os-disk.before-persistence.img
  # Boot remotely, create save slot 0 from Doom, then stop QEMU through monitor quit.
  cp build/disk.img /tmp/vibe-os-disk.after-persistence-write.img
  python3 tools/check_doom_persistence_image.py \
    --baseline-image /tmp/vibe-os-disk.before-persistence.img \
    --save-write-status build/status.persistence-write.txt \
    --require-save-slot 0 \
    build/disk.img | tee build/status.persistence-write-proof.txt

  # Boot the same build/disk.img again, load slot 0 from Doom's menu, and capture
  # build/status.persistence-load.txt.
  python3 tools/check_doom_persistence_image.py \
    --baseline-image /tmp/vibe-os-disk.before-persistence.img \
    --reboot-baseline-image /tmp/vibe-os-disk.after-persistence-write.img \
    --reboot-status build/status.persistence-load.txt \
    --save-write-status build/status.persistence-write.txt \
    --load-status build/status.persistence-load.txt \
    --require-save-slot 0 \
    build/disk.img | tee build/status.persistence-reboot-proof.txt
  ```

  For a defaults-only proof, use `--require-default` and add `--write-status
  build/status.persistence-write.txt` to the first checker invocation after
  quitting Doom through its menu. The checker reads `DEFAULT.CFG` and
  `DOOMSAV0.DSG` through the FAT parser and prints only compact metadata, save
  description, version text, leveltime, and whether the requested entry changed
  from the baseline and survived the reboot comparison. Do not upload
  `build/disk.img`, the baseline, or the after-write snapshot because those
  images contain the WAD; keep only status/checker text when preserving proof.
- Audio is described honestly: `audio=SB16` plus the audio continuity checker
  proves the guest SB16 path advanced through IRQ/refill, SFX, `sfxdma=`
  DMA-refill output, looped music-stream counters, and `musicrend=` MUS/MIDI
  renderer provenance; audible remote sound requires separate host audio
  forwarding or the aggregate `audio-proof.json` lane. Neither lane should
  publish captured Doom audio.
- Exit is handled through the QEMU monitor (`quit`) today. A graceful Doom
  quit-to-shell or reboot path is still a gap.
- Shutdown/panic evidence is a separate opt-in OS smoke lane. When
  `shutdown_panic_proof` is enabled, validate the downloaded artifact with
  `tools/check_shutdown_panic_proof.py`; do not count monitor `quit` cleanup as
  a guest-requested halt, reboot, poweroff, or panic proof. The reboot and
  poweroff proof phases must show status captured before the guest request and
  an observed QEMU exit caused by that guest request.

## Honest Remaining Gaps

- Display scaling is fixed nearest-neighbor 2x with a Mode 13h fallback; there
  is no aspect-correct fullscreen policy yet.
- Mouse input has a real PS/2 path and a cloud mouse-injection proof; VNC
  pointer tuning policy is still unpolished.
- Save/config persistence has host and filesystem coverage plus an opt-in cloud
  workflow path, but still needs a current passing real-WAD reboot proof after
  Doom changes settings or saves a game.
- Music renders streamed chunks from a port-owned song cursor and updates the
  SB16 music voice; kernel-owned pull/refill streaming and human listener
  validation remain unfinished until explicit `musicpos=`/ring-health status and
  remote listening notes exist.
- Doom exit/reboot behavior is not polished for a human session.
- Hardware support remains bounded to the QEMU BIOS/IDE/PS2/VBE/SB16 target in
  `docs/hardware-support.md`; this runbook does not prove UEFI, PCI
  enumeration, AHCI, USB, SMP, APIC, HPET, or physical-hardware support.

Cleanup:

```sh
rm -f /tmp/DOOM1.WAD
rm -f build/status.*.bin build/human-playtest-notes.txt
```

Then destroy the disposable remote host.
