# Play Now In The Cloud

Fastest safe path: run QEMU on a disposable Linux host, not on the Mac.
With GitHub CLI authenticated for Codespaces on the Mac, this is the one command
to play from the local checkout:

```sh
./tools/play_now_codespaces.sh
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
in the browser, create the Codespace, and run:

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
necessarily a kernel or input regression. Use `--machine` for a larger
Codespace when you need smoother interactive play; 4-core+ is the preferred
shape for longer human playtests.

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
  --dry-run
```

The first two commands prove and open the interactive noVNC path. The latter
two print the exact GitHub Actions proof and soak dispatches without launching
local QEMU or downloading forbidden artifacts.
When downloading proof artifacts, the helper prints separate failure lanes for
gameplay/input, SB16 continuity, optional audible audio aggregate, and optional
persistence/save-load triage. Keep those boundaries intact: a green gameplay
artifact is not a persistence proof, and an audio flake should not obscure a
save/load failure.

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
For live slowdown triage, use the diagnostics command printed by the launcher:

```sh
gh codespace ssh -c "<codespace-name>" -- /tmp/vibe-os-play-now-diagnostics.sh
```

It reports process/load, the forwarded noVNC port, filtered OS serial status
lines such as `inputdepth=`, `musicbuf=`, `musicpull=`, `mixunder=`,
`dtick/preempt`, and recent play/noVNC logs with token-shaped values redacted.
It does not print the Codespaces environment.
When finished, delete the disposable environment with
`gh codespace delete -c "<codespace-name>" --force` or from GitHub's
`Code` > `Codespaces` menu. Deletion removes the remote `/tmp` WAD and generated
VM artifacts.

Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens the menu.
VNC does not carry game audio in this quick path; current SB16 and audible audio
are proved by the cloud `real-wad-smoke.yml` aggregate audio proof.

To turn the same remote session into a human proof bundle, leave
`./tools/play_now_remote.sh` running and open a second SSH shell on the
disposable host:

```sh
./tools/run_remote_human_playtest.sh \
  --playtester jt \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"
```

The helper prompts for the playable Doom actions, captures each status phase
through the remote monitor socket, writes the allowlisted proof bundle, validates
it before download, creates `/tmp/vibe-os-human-proof.tgz`, and prints the local
post-download checker commands. The longer version lives in
`docs/runbooks/remote-doom-playtest.md`; its collector writes
`human-playtest-checklist.txt` with the post-download checker commands and phase
hashes to compare.
The guided helper validates the playtester handle, scripted proof run ID, proof
output directory, and proof tarball path before the first capture prompt. Proof
output and the tarball must be remote scratch paths outside the git checkout.
