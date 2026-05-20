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
VIBE_REPO=jadentripp/vibe-os VIBE_REF=jt/doom-gameplay-proof \
  ./tools/play_now_codespaces.sh
```

or:

```sh
./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref jt/doom-gameplay-proof
```

Explicit repo/ref mode verifies the GitHub repo and branch before Codespaces
creation and ignores unrelated local dirt. Inferred current-branch mode still
requires a clean checkout synced with upstream, because that mode uses local git
state as proof of what will run remotely.

The launcher checks GitHub CLI auth, repo/ref selection, machine selection, and
port `6080`, then creates or reuses a disposable GitHub Codespace. It starts
`./tools/play_now_remote.sh` inside the Codespace, waits for noVNC, makes port
`6080` private, and opens/prints the noVNC URL. The Mac only controls
Codespaces and opens a browser; it does not run QEMU, fetch the WAD, build
`disk.img`, or copy play artifacts back.

Before creation, the launcher also checks the selected pushed branch for the
required play payload: `.devcontainer/devcontainer.json`,
`.devcontainer/Dockerfile`, `tools/play_now_remote.sh`,
and `tools/check_play_now_remote.py`. A branch that has not pushed those files
fails before Codespaces creation with the missing path named in the error.

If the launcher reports that GitHub CLI cannot access Codespaces, run:

```sh
gh auth refresh -h github.com -s codespace
```

Optional dry run:

```sh
./tools/play_now_codespaces.sh --preflight
VIBE_REPO=jadentripp/vibe-os VIBE_REF=jt/doom-gameplay-proof \
  ./tools/play_now_codespaces.sh --preflight --no-open
```

Optional GitHub-hosted dry run: dispatch **Cloud play-now preflight** on the
same branch. It installs the remote dependencies on `ubuntu-latest`, runs
`./tools/play_now_remote.sh --preflight --require-novnc`, verifies the VM safety
contract, and uploads no artifacts. It is useful when you want to know the
remote host shape is ready before spending a Codespace.

To use a different noVNC port, set `NOVNC_PORT` on the Mac before the launch
and before the optional dry run. The launcher validates that port locally,
passes the same value into the Codespace, waits for that exact forwarded port,
and fails closed if GitHub CLI cannot mark it private.

Use a plain remote Ubuntu host instead when you do not want Codespaces:

```sh
git clone https://github.com/jadentripp/vibe-os.git
cd vibe-os
git checkout jt/doom-gameplay-proof
sudo apt-get update
sudo apt-get install -y nasm qemu-system-x86 clang make netcat-openbsd curl novnc websockify
./tools/play_now_remote.sh --preflight
./tools/play_now_remote.sh
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

The Mac-side Codespaces launcher does not download WADs, disk images, rendered
pixels, raw audio, or remote logs. If you need a proof bundle later, use the
allowlisted collector flow below instead of copying generated VM artifacts.

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
