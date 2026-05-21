# Codespaces Play Now

Use this path when you want to play vibe-os Doom quickly without running local
Mac QEMU. The Codespace is the disposable Linux host; QEMU, noVNC, and the WAD
stay there. Do not add WADs, disk images, screenshots, pixels, raw audio, or
other play artifacts to git.

## Create The Codespace

Fastest path from the Mac, with GitHub CLI authenticated for Codespaces:

```sh
./tools/play_now_codespaces.sh
```

Fastest path from any checkout state is to pin the pushed repo/ref explicitly:

```sh
VIBE_REPO=jadentripp/vibe-os VIBE_REF=main \
  ./tools/play_now_codespaces.sh
```

The equivalent flag form is:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main
```

Explicit repo/ref mode verifies that the GitHub repo is accessible and the
branch exists remotely, then ignores unrelated local dirt. That is intentional:
Codespaces runs the pushed branch, not uncommitted Mac files.

If you omit `--ref`/`VIBE_REF`, the launcher infers the current git branch and
uses it as proof of what will run remotely. In that inferred-branch mode it
refuses a dirty checkout or a current branch that differs from its upstream.

The launcher checks GitHub CLI auth, the selected repo/ref, the required
remote play files on that pushed ref, the chosen Codespaces machine, and the
noVNC port before creating anything.
If GitHub CLI reports a missing Codespaces API scope, refresh it once:

```sh
gh auth refresh -h github.com -s codespace
```

Or skip local Codespaces API scope and create the same environment in the
browser:

```sh
./tools/play_now_codespaces.sh --web-url \
  --repo jadentripp/vibe-os \
  --ref main
```

Open the printed `codespaces/new` URL, confirm the branch and
`.devcontainer/devcontainer.json`, then click `Create codespace`. When the
browser terminal attaches, `.devcontainer/play-now-welcome.sh` prints the two
commands to start the real vibe-os boot path.
With explicit `--repo` and `--ref`, this browser-only mode does not require
local `gh` authentication. If authenticated `gh` is unavailable, the launcher
still verifies the pushed branch and required play files with `git`, then falls
back to the generic Codespaces creation URL.

The launch creates a disposable Codespace from the current repo and branch,
starts `./tools/play_now_remote.sh` inside it, waits for noVNC, sets port `6080`
private, opens/prints the noVNC URL, and prints the log and delete commands.
QEMU, the shareware WAD, `build/disk.img`, pixel output, and raw audio never run
on or copy back to the Mac.
If the first SSH attach fails with a permission or public-key error while the
Codespace is still coming up, leave the launcher running. It retries the
stdin-fed `bash -s` start command and prints a browser authorization hint
without dumping the remote environment.

The default Codespaces machine is often 2-core. That is enough for a quick Doom
playtest, but QEMU plus noVNC can stutter while the image is building or while
the browser stream is busy. When the CLI creates a new Codespace and you did
not pass `--machine`, the launcher asks GitHub for available machines on the
selected repo/ref and selects the smallest 4+ CPU machine when one is
available. Pass `--machine` when you want a specific machine. In browser-only
`--web-url` mode, select a 4-core+ machine manually in the GitHub creation
screen; GitHub's default is the lowest valid machine and may be the slow 2-core
shape.

Optional dry run:

```sh
./tools/play_now_codespaces.sh --preflight
VIBE_REPO=jadentripp/vibe-os VIBE_REF=main \
  ./tools/play_now_codespaces.sh --preflight --no-open
```

If port `6080` is unavailable, set `NOVNC_PORT` for the launch and optional
preflight:

```sh
NOVNC_PORT=6173 ./tools/play_now_codespaces.sh --preflight
NOVNC_PORT=6173 ./tools/play_now_codespaces.sh
```

The launcher uses that exact port in the remote Codespace, waits for the
matching forwarded port, and refuses to print or open the noVNC URL if it cannot
mark the port private or the port never becomes ready.

New Codespaces get an auto-generated display name short enough for the GitHub
CLI limit. Pass `--display-name` only when you need a specific name.

To reuse a specific existing Codespace:

```sh
./tools/play_now_codespaces.sh --codespace "<codespace-name>"
```

Delete the disposable play environment when done:

```sh
gh codespace delete -c "<codespace-name>" --force
```

Useful inspection and cleanup commands are printed by the launcher:

```sh
gh codespace ssh -c "<codespace-name>" -- tail -f /tmp/vibe-os-play-now.log
gh codespace ssh -c "<codespace-name>" -- /tmp/vibe-os-play-now-diagnostics.sh
gh codespace ports -c "<codespace-name>"
gh api /user/codespaces/<codespace-name> --jq .machine
```

If a play process is still running and you want to stop it before deletion:

```sh
gh codespace ssh -c "<codespace-name>" -- \
  'if [ -s /tmp/vibe-os-play-now.pid ]; then kill "$(cat /tmp/vibe-os-play-now.pid)"; fi'
```

The remote play script records its own `/tmp/vibe-os-play-now.pid` and
`/tmp/vibe-os-play-now.novnc-port` while it is running and removes them on a
normal exit. If the Codespace is killed hard, rerunning the launcher treats a
stale PID file as stale state and rewrites it before starting.

For slowdown triage while the game is running, use the diagnostics command
printed by the launcher:

```sh
gh codespace ssh -c "<codespace-name>" -- /tmp/vibe-os-play-now-diagnostics.sh
```

The helper prints only host CPU count/load, process status, noVNC port, filtered
OS serial status lines, and recent play/noVNC logs with token-shaped values
redacted. It does not print the Codespaces environment, GitHub tokens, WAD
data, pixels, raw audio, or full logs. If the status fields are healthy but the
browser stream still stutters on a 2-core machine, restart on a 4+ CPU
Codespace before calling it a Doom/input regression.

Manual browser path:

1. Run `./tools/play_now_codespaces.sh --web-url --repo jadentripp/vibe-os --ref <branch>`, or open `https://github.com/codespaces/new`.
2. Select `jadentripp/vibe-os`.
3. Select the branch that contains the Doom play work.
4. Select `.devcontainer/devcontainer.json` if GitHub asks for a dev container configuration.
5. Choose a 4-core+ machine when GitHub offers one.
6. Click `Create codespace`.
7. Wait until the Codespace finishes building the dev container and prints the play welcome text.

The dev container installs Python 3 plus the toolchain used by
`./tools/play_now_remote.sh`: `nasm`, `qemu-system-x86`, `clang`, `make`,
`netcat-openbsd`, `curl`, `novnc`, and `websockify`.

## Launcher Diagnostics

Use preflight whenever you want to verify the Mac-side control path without
creating a Codespace:

```sh
./tools/play_now_codespaces.sh --dry-run --machine basicLinux32gb --no-open
```

Expected successful output includes `play-now Codespaces preflight OK`, the
repo, ref, selected or inspected machine, `machine selection:`, `noVNC port:
6080 (private)`, the noVNC wait timeout, `GitHub repo/ref: verified`, `remote
play payload: verified on selected ref`, `local artifact transfer: none`, and
the 2-core performance caveat plus 4-core+ guidance. The dry run also prints
`dry-run: Codespace was not created or modified`. If it reports a dirty tree,
missing upstream, or ahead/behind counts, either fix and push the current branch
or rerun with explicit `--repo` and `--ref` for a branch that already exists on
GitHub. Invalid noVNC ports, inaccessible GitHub repos/branches, and branches
missing the devcontainer or remote play scripts always fail before Codespaces
creation.

For a GitHub-hosted prerequisite check that does not create a Codespace, run
the manual **Cloud play-now preflight** workflow on the same branch. It executes
the remote runner preflight with `--require-novnc` on `ubuntu-latest`, checks
the VM safety contract, and does not fetch a WAD, build `disk.img`, launch QEMU,
or upload artifacts.

After interactive play, use the cloud-only proof helper for machine evidence
instead of copying anything out of the Codespace:

```sh
python3 tools/run_cloud_playability.py --ref <branch> --lane gameplay --wait \
  --download-artifacts build/cloud-run-gameplay \
  --write-audit-log build/cloud-run-gameplay/cloud-playability-audit.json
python3 tools/run_cloud_playability.py --ref <branch> --lane audio \
  --soak-attempts 3 \
  --soak-min-passes 3 \
  --wait \
  --download-artifacts build/cloud-soak-audio \
  --write-audit-log build/cloud-soak-audio/cloud-playability-audit.json
```

The first command downloads and triages the allowlisted single-run status
artifact. The second downloads the JSON-only soak metadata and validates its
summary.
The audit JSON records the exact `gh`, checker, triage, workflow, artifact, and
failure-lane information that was printed, so the proof is reviewable after the
branch and shared worktree have moved on.
The helper prints a separate failure-lane block after every download command:
gameplay/input, SB16 continuity, audible audio aggregate when requested, and
persistence/save-load when requested. Treat those as independent repair lanes
instead of upgrading a partial proof into a broader claim.
The adjacent `rerun only the red lane` block gives the exact gameplay, audio,
or persistence command to retry, so a single red lane does not force a full
proof rerun.

For a formal human proof from the running Codespace, open a second Codespace
terminal and print the dry-run bundle template before capture:

```sh
python3 tools/collect_human_playtest_bundle.py --print-template \
  --build-dir build \
  --output-dir /tmp/vibe-os-human-proof \
  --playtester "<name-or-initials>" \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"
```

It prints the exact status capture, collect, tarball, local post-download
verification, cleanup, safe artifact policy, and 4+ CPU noVNC guidance without
reading artifacts or launching QEMU.

## Run The Play Script

In the Codespace terminal:

```sh
./tools/play_now_remote.sh --preflight --require-novnc
./tools/play_now_remote.sh --require-novnc
```

The preflight is a dry run: it checks host safety, dependency availability,
effective CPU count from cgroup quotas/cpuset when available, and noVNC/VNC port
safety, then exits before fetching a WAD, building, or launching QEMU.
`--require-novnc` keeps the
Codespaces path browser-first: if noVNC is missing, fix the Codespace instead
of silently falling back to a raw VNC-only setup. The play script fetches and
validates the shareware `DOOM1.WAD` into `/tmp/vibe-os-DOOM1.WAD`, outside the
repository. Leave it outside git. The script refuses to run QEMU on macOS; this
runbook uses remote Codespaces QEMU only.
For fast retries, the play script preserves valid cached compilation outputs
but removes and rebuilds `build/disk.img` on every launch. That keeps the
image tied to the validated WAD without forcing a full clean rebuild.

## Open noVNC

1. Keep the play script running.
2. In Codespaces, open the `Ports` tab.
3. Find port `6080`.
4. If it is not already forwarded, click `Forward a Port` and enter `6080`.
5. Set visibility to private unless you deliberately need otherwise.
6. Open the forwarded `6080` URL in the browser.

If the page does not connect automatically, use the forwarded Codespaces origin
with this path:

```text
/vnc.html?autoconnect=1
```

Do not open the raw `127.0.0.1:6080` noVNC URL in your local Mac browser unless
you created an SSH tunnel for that port. In Codespaces, the forwarded URL is the
bridge to the noVNC server. The QEMU VNC server stays bound to `127.0.0.1`
inside the Codespace.

Controls: arrows move and turn, Ctrl fires, Space uses, and Escape opens the
menu. Click the noVNC canvas before recorded human-proof actions if focus is
ambiguous. noVNC does not carry game audio in this fast path; the guided human
helper records audio as `status-only`, `listener-pass`, `audio-proof-json-pass`,
or `not-tested`.

The Codespaces launcher never downloads the remote WAD, disk image, rendered
pixels, raw audio, screenshots, or remote logs to the Mac. Remote fetch/startup
errors and diagnostics redact GitHub tokens, authorization headers, common
secret environment values, and signed URL parameters before printing. Use the
separate allowlisted proof collector only when you intentionally need a
status-only human proof bundle.

## Destroy The Codespace

When finished:

1. Stop the play script with `Ctrl-C`, or use the `gh codespace ssh` stop command printed by the launcher.
2. Return to the repository on GitHub.
3. Open `Code`.
4. Open the `Codespaces` tab.
5. Click the `...` menu for the Codespace.
6. Click `Delete`.
7. Confirm deletion.

Deleting the Codespace removes the remote `/tmp` WAD and generated VM artifacts.
Do not copy them back into the repository.

## Remote Shell Without Codespaces

If Codespaces is unavailable, open any disposable Ubuntu cloud shell and run the
bootstrap helper there:

```sh
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/main/tools/play_now_cloud_shell.sh \
  | VIBE_REF=main bash
```

Omit `VIBE_REF` to use `main`. That installs the remote play dependencies,
checks out the pushed branch into `~/vibe-os-play-now`, runs the noVNC
preflight, and starts
`./tools/play_now_remote.sh --require-novnc` on the remote host. Tunnel or
forward port `6080`, then open the forwarded URL with
`/vnc.html?autoconnect=1`.
