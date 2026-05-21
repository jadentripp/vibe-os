# Play Now In The Cloud

Fastest safe path: run QEMU on a disposable Linux host, not on the Mac.
With GitHub CLI authenticated for Codespaces on the Mac, this is the one command
to play from the local checkout:

```sh
./tools/play_now_codespaces.sh
```

Safety contract:

- No local VM/QEMU on the Mac.
- `CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC`: do not run `qemu-system-*`,
  `make run`, `make run-headless`, `make smoke`, or the local-VM opt-in flag
  on the Mac.
- `CLOUD_PLAYTEST_REMOTE_QEMU_ONLY`: QEMU commands in this document run only on
  a disposable remote Ubuntu host, GitHub Codespace, or equivalent cloud shell.
- `CLOUD_PLAYTEST_FORBIDDEN_UPLOADS`: never copy or upload WADs, `disk.img`,
  raw disk images, screenshots, framebuffer dumps, rendered pixels,
  `status.*.bin`, QEMU WAV files, or other raw audio captures off the
  disposable host.
- `CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST`: only status text, logs, ELF diagnostics,
  `doom.symbols`, human-playtest notes/observations/checklist/session/manifest
  files, and optional aggregate `audio-proof.json` may leave the disposable
  host.

Never transfer these from the remote host: `DOOM1.WAD`, `build/disk.img`,
framebuffer or screenshot files, `status.*.bin`, `build/doom-audio.wav`, or
other raw audio. If a remote audio proof was attempted, clean it up before
destroying the disposable host:

```sh
rm -f /tmp/vibe-os-DOOM1.WAD
rm -f ~/vibe-os-cloud-playtest/build/doom-audio.wav
```

When the local checkout is dirty, or when another worker owns the current
workspace, launch from a pushed repo/ref instead:

```sh
VIBE_REPO=jadentripp/vibe-os VIBE_REF=main \
  ./tools/play_now_codespaces.sh
```

or:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

Explicit repo/ref mode verifies the GitHub repo and branch before Codespaces
creation and ignores unrelated local dirt. Inferred current-branch mode still
requires a clean checkout synced with upstream, because that mode uses local git
state as proof of what will run remotely. Branch names are checked with Git's
normal branch-name validator before any Codespaces API call, so typoed or
malformed refs fail while the Mac is still in preflight.

The launcher checks GitHub CLI auth, repo/ref selection, machine selection, and
port `6080`, then creates or reuses a disposable GitHub Codespace. It starts
`./tools/play_now_remote.sh` inside the Codespace, waits for noVNC, makes port
`6080` private, and opens/prints the noVNC URL. The Mac only controls
Codespaces and opens a browser; it does not run QEMU, fetch the WAD, build
`disk.img`, or copy play artifacts back.
On initial attach, GitHub can briefly reject SSH with a permission/public-key
error while the Codespace is still authorizing or starting. The launcher retries
that stdin-fed `bash -s` start path, prints an authorization hint, and sanitizes
known token-shaped stderr before showing it.

Before creation, the launcher also checks the selected pushed branch for the
required play payload: `.devcontainer/devcontainer.json`,
`.devcontainer/Dockerfile`, `tools/play_now_remote.sh`,
`tools/check_play_now_remote.py`, `tools/prepare_shareware_wad.py`,
`tools/make_wad_image.py`, and `Makefile`. A branch that has not pushed those
files fails before Codespaces creation with the missing path named in the
error.

If the launcher reports that GitHub CLI cannot access Codespaces, run:

```sh
gh auth refresh -h github.com -s codespace
```

If you do not want to grant that local scope right now, ask the launcher for the
browser-only Codespaces path instead:

```sh
./tools/play_now_codespaces.sh --web-url \
  --repo jadentripp/vibe-os \
  --ref main
```

That verifies the pushed repo/ref and required play files, then prints a
GitHub `codespaces/new` URL plus the exact in-Codespace commands. Open the URL
in the browser, select a 4-core+ machine when GitHub offers one, create the
Codespace, and run:

```sh
./tools/play_now_remote.sh --preflight --require-novnc
./tools/play_now_remote.sh --require-novnc
```

The devcontainer prints those commands when you attach, so a Codespace created
from the GitHub web UI has the same path as the CLI-created one.
With explicit `--repo` and `--ref`, `--web-url` also works when local `gh` auth
is unavailable; in that case it falls back to the generic Codespaces creation
URL after verifying the branch and play payload with `git`.

Optional dry run:

```sh
./tools/play_now_codespaces.sh --preflight
VIBE_REPO=jadentripp/vibe-os VIBE_REF=main \
  ./tools/play_now_codespaces.sh --preflight --no-open
```

The default Codespaces machine is often 2-core. Doom is playable there, but
QEMU, noVNC, and the first build can contend for CPU, so short stutters are not
necessarily a kernel or input regression. For CLI-created Codespaces, the
launcher asks GitHub for available machines on the selected repo/ref and, when
possible, selects the smallest 4+ CPU machine for smoother interactive play.
Pass `--machine` to override that choice. In browser-only `--web-url` mode,
select a 4-core+ machine in GitHub's creation screen when available; GitHub's
default is the lowest valid machine and may land back on the slow 2-core shape.
Inside the remote host, `./tools/play_now_remote.sh --preflight` reports the
effective CPU count using cgroup quota/cpuset limits when available, so a
container capped to 2 cores still gets the slowdown warning even if the backing
host exposes more CPUs.

Optional GitHub-hosted dry run: dispatch **Cloud play-now preflight** on the
same branch. It installs the remote dependencies on `ubuntu-latest`, runs
`./tools/play_now_remote.sh --preflight --require-novnc`, verifies the VM safety
contract, and uploads no artifacts. It is useful when you want to know the
remote host shape is ready before spending a Codespace.

The short safe hardware-lab loop is:

```sh
./tools/play_now_codespaces.sh --preflight --repo jadentripp/vibe-os --ref main
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
python3 tools/run_cloud_playability.py --ref main --lane gameplay --dry-run
python3 tools/run_cloud_playability.py --ref main --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3 \
  --write-audit-log build/cloud-soak-audio/cloud-playability-audit.json \
  --dry-run
```

The first two commands prove and open the interactive noVNC path. The latter
two print the exact GitHub Actions proof and soak dispatches without launching
local QEMU or downloading forbidden artifacts. Add `--write-audit-log` to
downloaded proof runs when handing evidence to another person; the JSON records
the workflow, artifact name, commands, checker ref, artifact policy, and
failure lanes printed by the helper.
When downloading proof artifacts, the helper prints separate failure lanes for
gameplay/input, SB16 continuity, optional audible audio aggregate, and optional
persistence/save-load triage. Keep those boundaries intact: a green gameplay
artifact is not a persistence proof, and an audio flake should not obscure a
save/load failure.
The same output includes a `rerun only the red lane` block. Use the gameplay
command for boot/input regressions, the audio command for SB16 or aggregate
audio failures, and the persistence command for save/load failures instead of
rerunning the full proof by habit.

To use a different noVNC port, set `NOVNC_PORT` on the Mac before the launch
and before the optional dry run. The launcher validates that port locally,
passes the same value into the Codespace, waits for that exact forwarded port,
and fails closed if GitHub CLI cannot mark it private.
Inside the remote host, preflight also validates `VNC_DISPLAY` and refuses a
configuration where the QEMU VNC port and noVNC port overlap. noVNC is served
from the first available web root among `/usr/share/novnc`,
`/usr/local/share/novnc`, and `/opt/homebrew/share/novnc`, or from an explicit
`NOVNC_WEB_ROOT` when set.

Use a plain remote Ubuntu host instead when you do not want Codespaces:

```sh
git clone https://github.com/jadentripp/vibe-os.git
cd vibe-os
git checkout main
sudo apt-get update
sudo apt-get install -y nasm qemu-system-x86 clang make netcat-openbsd curl novnc websockify
./tools/play_now_remote.sh --preflight
./tools/play_now_remote.sh
```

The explicit manual WAD/image build, when you need to separate it from the play
script, is:

```sh
python3 tools/prepare_shareware_wad.py --output /tmp/DOOM1.WAD
make DOOM_WAD=/tmp/DOOM1.WAD
```

For interactive play on a plain cloud VM, choose 4+ vCPUs when possible. A
2-vCPU VM is useful for smoke checks, but noVNC plus QEMU TCG can stutter enough
to make manual Doom control feel worse than the OS status actually is.

For a fresh disposable Ubuntu shell, the bootstrap helper performs that setup
and then starts the same remote play script:

```sh
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/main/tools/play_now_cloud_shell.sh \
  | VIBE_REF=main bash
```

If `VIBE_REF` is omitted, the bootstrap helper defaults to `main`.

Use `--preflight-only` when you want it to stop after dependency and noVNC
checks:

```sh
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/main/tools/play_now_cloud_shell.sh \
  | bash -s -- --preflight-only
```

The preflight is a dry run: it checks the remote host and exits before fetching
the WAD, building the disk image, or launching QEMU.

Open the noVNC URL printed by the script. In GitHub Codespaces, forward port
`6080` and open the forwarded browser URL with `/vnc.html?autoconnect=1`. On a
plain remote VM, tunnel noVNC to the Mac:

```sh
ssh -L 6080:127.0.0.1:6080 user@remote-host
```

Then open `http://127.0.0.1:6080/vnc.html?autoconnect=1`. If noVNC is not
available on the remote host, tunnel the raw VNC port instead:

```sh
ssh -L 5901:127.0.0.1:5901 user@remote-host
```

Then connect a VNC client to `localhost:5901`.
For a long-lived tunnel-only terminal, use the no-command form:

```sh
ssh -N -L 5901:127.0.0.1:5901 user@remote-host
```

The script refuses to run QEMU on macOS. Use a disposable remote Linux host or
Codespace for playtesting. It fetches the validated shareware `DOOM1.WAD` to
`/tmp/vibe-os-DOOM1.WAD`, keeps WAD data outside the repo, and does not upload
disk images, pixels, WADs, or raw audio.
On repeated launches in the same remote checkout, it reuses cached object files
but deletes and rebuilds `build/disk.img` so the boot image always binds the
freshly validated WAD.

The Mac-side Codespaces launcher does not download WADs, disk images, rendered
pixels, raw audio, or remote logs. If you need a proof bundle later, use the
allowlisted collector flow below instead of copying generated VM artifacts.
For live slowdown triage, use the status-only diagnostics command printed by
the launcher:

```sh
gh codespace ssh -c "<codespace-name>" -- /tmp/vibe-os-play-now-diagnostics.sh
```

It reports host CPU count/load, the forwarded noVNC port, the play process,
filtered OS serial status lines such as `inputdepth=`, `musicbuf=`,
`musicpull=`, `mixunder=`, `dtick/preempt`, `doompresent=`, and recent
play/noVNC logs with token-shaped values redacted. It does not print the
Codespaces environment, GitHub tokens, WAD data, pixels, raw audio, or full
logs. If those OS status fields look healthy but the browser still stutters on
a 2-core host, restart on the selected 4+ CPU Codespace or a faster disposable
cloud VM before treating it as a Doom/input regression.
Remote fetch/startup errors use the same redaction rules for GitHub tokens,
authorization headers, common secret environment values, and signed URL parameters
before they are printed locally.
Useful cleanup and inspection commands are printed by the launcher and are safe
to keep in your notes:

```sh
gh codespace ssh -c "<codespace-name>" -- tail -f /tmp/vibe-os-play-now.log
gh codespace ssh -c "<codespace-name>" -- /tmp/vibe-os-play-now-diagnostics.sh
gh codespace ssh -c "<codespace-name>" -- /tmp/vibe-os-play-now-stop.sh
gh codespace ports -c "<codespace-name>"
gh api /user/codespaces/<codespace-name> --jq .machine
gh codespace ssh -c "<codespace-name>" -- \
  'if [ -s /tmp/vibe-os-play-now.pid ]; then kill "$(cat /tmp/vibe-os-play-now.pid)"; fi'
gh codespace delete -c "<codespace-name>" --force
```

When finished, destroy the disposable Codespace or remote host. Delete the
disposable environment with
`gh codespace delete -c "<codespace-name>" --force` or from GitHub's
`Code` > `Codespaces` menu. Deletion removes the remote `/tmp` WAD and generated
VM artifacts.
On normal play-script exit, `/tmp/vibe-os-play-now.pid` and
`/tmp/vibe-os-play-now.novnc-port` are removed automatically. If the remote host
is killed hard, the next launcher run treats stale metadata as stale and rewrites
it before starting.

Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens the menu.
VNC does not carry game audio in this quick path; current SB16 and audible audio
are proved by the cloud `real-wad-smoke.yml` aggregate audio proof.

To turn the same remote session into a human proof bundle, leave
`./tools/play_now_remote.sh` running and open a second SSH shell on the
disposable host:

```sh
python3 tools/collect_human_playtest_bundle.py --print-template \
  --build-dir build \
  --output-dir /tmp/vibe-os-human-proof \
  --playtester jt \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"

python3 tools/collect_human_playtest_bundle.py --print-phase-guide

./tools/run_remote_human_playtest.sh \
  --playtester jt \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"
```

The dry-run template prints the exact status-only capture, collect, download,
verify, cleanup, and safe artifact policy commands without reading artifacts or
launching QEMU. The shorter phase guide repeats just the phase order, output
status filenames, expected human action, expected status-only signal, and
350-tick duration gate. The guided helper then prompts for the playable Doom
actions, prints the expected status signal before each capture, captures each
status phase through the remote monitor socket, asks you to tie the session to
a green Real WAD smoke run, records a slowdown level and short status-only
slowdown note, records noVNC focus and the audio observation mode, writes the
allowlisted proof bundle, validates it before download, creates
`/tmp/vibe-os-human-proof.tgz`, and prints the local post-download checker
commands. The longer version lives in `docs/runbooks/remote-doom-playtest.md`;
its collector writes `human-playtest-observations.json` plus
`human-playtest-checklist.txt` with the post-download checker commands and phase
hashes to compare.
The guided helper validates the playtester handle, scripted proof run ID, proof
output directory, and proof tarball path before the first capture prompt. Proof
output and the tarball must be remote scratch paths outside the git checkout.
After downloading the allowlisted proof bundle, verify it locally with:

```sh
python3 tools/check_cloud_playability_artifacts.py --human-session ./vibe-os-human-proof
```
