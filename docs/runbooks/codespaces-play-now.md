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
VIBE_REPO=jadentripp/vibe-os VIBE_REF=jt/doom-gameplay-proof \
  ./tools/play_now_codespaces.sh
```

The equivalent flag form is:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref jt/doom-gameplay-proof
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
  --ref jt/doom-gameplay-proof
```

Open the printed `codespaces/new` URL, confirm the branch and
`.devcontainer/devcontainer.json`, then click `Create codespace`. When the
browser terminal attaches, `.devcontainer/play-now-welcome.sh` prints the two
commands to start the real vibe-os boot path.

The launch creates a disposable Codespace from the current repo and branch,
starts `./tools/play_now_remote.sh` inside it, waits for noVNC, sets port `6080`
private, opens/prints the noVNC URL, and prints the log and delete commands.
QEMU, the shareware WAD, `build/disk.img`, pixel output, and raw audio never run
on or copy back to the Mac.

Optional dry run:

```sh
./tools/play_now_codespaces.sh --preflight
VIBE_REPO=jadentripp/vibe-os VIBE_REF=jt/doom-gameplay-proof \
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

Manual browser path:

1. Run `./tools/play_now_codespaces.sh --web-url --repo jadentripp/vibe-os --ref <branch>`, or open `https://github.com/codespaces/new`.
2. Select `jadentripp/vibe-os`.
3. Select the branch that contains the Doom play work.
4. Select `.devcontainer/devcontainer.json` if GitHub asks for a dev container configuration.
5. Click `Create codespace`.
6. Wait until the Codespace finishes building the dev container and prints the play welcome text.

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
repo, ref, selected machine, `noVNC port: 6080 (private)`, the noVNC wait
timeout, `GitHub repo/ref: verified`, `remote play payload: verified on
selected ref`, and `local artifact transfer: none`. The dry run also prints
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

## Run The Play Script

In the Codespace terminal:

```sh
./tools/play_now_remote.sh --preflight --require-novnc
./tools/play_now_remote.sh --require-novnc
```

The preflight is a dry run: it checks host safety and dependencies, then exits
before fetching a WAD, building, or launching QEMU. `--require-novnc` keeps the
Codespaces path browser-first: if noVNC is missing, fix the Codespace instead
of silently falling back to a raw VNC-only setup. The play script fetches and
validates the shareware `DOOM1.WAD` into `/tmp`, outside the repository. Leave
it outside git. The script refuses to run QEMU on macOS; this runbook uses
remote Codespaces QEMU only.

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
menu. noVNC does not carry game audio in this fast path.

The Codespaces launcher never downloads the remote WAD, disk image, rendered
pixels, raw audio, screenshots, or remote logs to the Mac. Use the separate
allowlisted proof collector only when you intentionally need a status-only human
proof bundle.

## Destroy The Codespace

When finished:

1. Stop the play script with `Ctrl-C`.
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
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/jt/doom-gameplay-proof/tools/play_now_cloud_shell.sh \
  | VIBE_REF=jt/doom-gameplay-proof bash
```

That installs the remote play dependencies, checks out the pushed branch into
`~/vibe-os-play-now`, runs the noVNC preflight, and starts
`./tools/play_now_remote.sh --require-novnc` on the remote host. Tunnel or
forward port `6080`, then open the forwarded URL with
`/vnc.html?autoconnect=1`.
