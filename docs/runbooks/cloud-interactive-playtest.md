# Cloud Interactive Doom Playtest Runbook

This is the disposable cloud path for actually playing vibe-os Doom without
running a VM, QEMU, or an emulator on the Mac. The Mac only uses SSH, a browser
or viewer, and host-only artifact checkers after the remote session is done.

Safety contract:

- No local VM/QEMU on the Mac.
- `CLOUD_PLAYTEST_NO_LOCAL_QEMU_ON_MAC`: do not run `qemu-system-*`, `make run`,
  or `make run-headless` on the Mac.
- `CLOUD_PLAYTEST_REMOTE_QEMU_ONLY`: every QEMU command in this runbook is for a
  disposable remote Ubuntu host.
- `CLOUD_PLAYTEST_FORBIDDEN_UPLOADS`: never upload, publish, or copy to the Mac
  any WAD, `build/disk.img`, raw disk image, framebuffer dump, screenshot,
  rendered pixels, `status.*.bin`, QEMU WAV, or other raw audio capture.
- `CLOUD_PLAYTEST_ARTIFACT_ALLOWLIST`: only status text, logs, ELF diagnostics,
  `doom.symbols`, `human-playtest-notes.txt`, `human-playtest-checklist.txt`,
  `human-playtest-session.json`, `human-playtest-manifest.json`, and optional
  aggregate `audio-proof.json` may leave the disposable host.

## Pick A Disposable Host

Use a throwaway Ubuntu 24.04 VM, GitHub Codespace, or equivalent cloud shell
with nested virtualization optional. QEMU TCG is enough, so the host can be a
cheap CPU-only instance. Keep inbound networking closed except SSH. Use a fresh
host for the run and destroy it afterward.

Recommended shape:

- Ubuntu 24.04 or 22.04.
- 2 vCPU, 4 GB RAM, 10 GB disk or larger.
- SSH access from the Mac.
- No public VNC and no public noVNC.

Fastest Codespaces option from the Mac repo checkout:

```sh
./tools/play_now_codespaces.sh
```

That one command creates or reuses a disposable Codespace, starts the existing
remote play script there, marks the noVNC port private, and opens/prints the
browser URL. The rest of this runbook is the manual remote-host equivalent and
the optional human proof-capture flow.

If local `gh` lacks the Codespaces API scope, use the browser-only Codespaces
route instead:

```sh
./tools/play_now_codespaces.sh --web-url \
  --repo jadentripp/vibe-os \
  --ref jt/playable-rc-next
```

Open the printed URL, create the Codespace in the GitHub web UI, and run the
welcome commands in the Codespace terminal. This still keeps QEMU remote-only.

If you are already inside a fresh disposable Ubuntu shell, bootstrap the same
remote play path directly:

```sh
curl -fsSL https://raw.githubusercontent.com/jadentripp/vibe-os/jt/playable-rc-next/tools/play_now_cloud_shell.sh \
  | VIBE_REF=jt/playable-rc-next bash
```

Optional cloud prerequisite check: run the manual **Cloud play-now preflight**
GitHub Actions workflow on the branch you plan to play. It installs the remote
dependencies, runs `./tools/play_now_remote.sh --preflight --require-novnc`,
checks this safety contract, and exits before QEMU launch, WAD download, disk
image build, or artifact upload.

On the Mac, set only connection metadata:

```sh
export VIBE_CLOUD_HOST='user@remote-host'
```

## Bootstrap The Remote Host

Open an SSH shell and run the setup there:

```sh
ssh "$VIBE_CLOUD_HOST"
```

Everything below in this section runs in that remote SSH shell:

```sh
export VIBE_REPO_URL='https://github.com/jadentripp/vibe-os.git'
export VIBE_REF='main'

sudo apt-get update
sudo apt-get install -y \
  git make nasm clang qemu-system-x86 qemu-utils netcat-openbsd curl python3 \
  novnc websockify

rm -rf ~/vibe-os-cloud-playtest
git clone "$VIBE_REPO_URL" ~/vibe-os-cloud-playtest
cd ~/vibe-os-cloud-playtest
git checkout "$VIBE_REF"

./tools/play_now_remote.sh --preflight
```

WAD policy:

- The play script downloads the public shareware WAD only inside the remote
  host.
- `/tmp/vibe-os-DOOM1.WAD` stays outside git and never leaves the remote host.
- `build/disk.img` contains the WAD and never leaves the remote host.
- Delete `/tmp/vibe-os-DOOM1.WAD` before shutting the host down.

The explicit WAD preparation command, if you need to run it separately from the
play script, is:

```sh
python3 tools/prepare_shareware_wad.py --output /tmp/DOOM1.WAD
make DOOM_WAD=/tmp/DOOM1.WAD
```

## Start Remote QEMU With noVNC

Run this on the remote host, from `~/vibe-os-cloud-playtest`:

```sh
# CLOUD_PLAYTEST_REMOTE_QEMU_ONLY: run this block on the disposable remote host,
# never on macOS.
./tools/play_now_remote.sh
```

Leave that SSH tab running. The script fetches the WAD into `/tmp`, builds the
disk image, starts QEMU with loopback-only VNC on `127.0.0.1:5901`, and starts a
loopback noVNC bridge on `127.0.0.1:6080` when `websockify` and `/usr/share/novnc`
are available.

For the fastest browser path from a plain cloud VM, tunnel noVNC from a second
Mac terminal:

```sh
ssh -N -L 6080:127.0.0.1:6080 "$VIBE_CLOUD_HOST"
```

Open this local browser URL on the Mac:

```text
http://127.0.0.1:6080/vnc.html?autoconnect=1
```

In GitHub Codespaces, forward port `6080` and open the forwarded browser URL
with `/vnc.html?autoconnect=1` instead of creating an SSH tunnel.

Do not bind noVNC to `0.0.0.0` and do not open cloud firewall ports for it.

If noVNC is unavailable on the remote host, tunnel the raw VNC port instead:

```sh
ssh -N -L 5901:127.0.0.1:5901 "$VIBE_CLOUD_HOST"
```

Connect a VNC viewer on the Mac to `127.0.0.1:5901`. That viewer is only a
display/input client; QEMU still runs on the remote host.

## What To Play

Use the remote noVNC or VNC display like a normal Doom session:

- Arrow keys: move and turn.
- Ctrl: fire.
- Space: use/open.
- Enter: confirm menu items.
- Escape: open or close the Doom menu.
- Mouse movement and click: turn/fire through the PS/2 mouse path.

VNC does not carry audio. This path uses `-audiodev none` so the guest can still
exercise the SB16 device model while the disposable host discards audio bytes.
For audible proof, use only the aggregate `audio-proof.json` workflow lane
described in `docs/runbooks/remote-doom-playtest.md`; do not download a WAV or
other raw audio capture.

## Capture A Human Proof Bundle

While QEMU is running on the remote host, use the status capture phases from
`docs/runbooks/remote-doom-playtest.md`.

Fast path from a second SSH shell on the disposable host:

```sh
cd ~/vibe-os-cloud-playtest
./tools/run_remote_human_playtest.sh \
  --playtester "<name-or-initials>" \
  --scripted-proof-run-id "<passing-real-wad-smoke-run-id>"
```

The guided helper asks the human to perform each VNC action, captures the eight
status phases through `build/play-now/monitor.sock`, runs the collector with the
required operator confirmations, prints `pre-download human verification OK`,
records a slowdown level and short status-only slowdown note, builds
`/tmp/vibe-os-human-proof.tgz`, and prints the local `scp` plus post-download
verification commands. It also records the audio observation mode and requires
the operator to confirm that the linked Real WAD smoke run was green before the
human session.

Manual equivalent, if you need to capture phases one at a time:

```sh
cd ~/vibe-os-cloud-playtest

capture_status() {
  phase="$1"
  python3 tools/collect_human_playtest_bundle.py \
    --build-dir build \
    --monitor-socket build/play-now/monitor.sock \
    --capture-phase "$phase"
}

capture_status early
capture_status after-start
capture_status after-fire
capture_status after-move
capture_status after-use
capture_status after-mouse
capture_status after-menu
capture_status final
```

Between those captures, one human should use the tunneled display and wait for a
visible response before the next capture.

Collect the allowlisted proof bundle on the remote host:

```sh
cd ~/vibe-os-cloud-playtest
rm -rf /tmp/vibe-os-human-proof
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
  --confirm-audio-observation \
  --confirm-slowdown-notes \
  --confirm-phase-actions \
  --confirm-phase-status-hashes \
  --confirm-no-forbidden-artifacts \
  --confirm-post-download-verification
```

The collector runs
`tools/check_cloud_playability_artifacts.py --human-session` before download and
prints `pre-download human verification OK`. Keep that line and the generated
`human-playtest-checklist.txt`; the checklist names the local commands and phase
hashes to compare after download.

## Download Only The Allowlisted Bundle

Create a tarball of the collector output only:

```sh
ssh "$VIBE_CLOUD_HOST" \
  'cd /tmp && tar -czf vibe-os-human-proof.tgz vibe-os-human-proof'
scp "$VIBE_CLOUD_HOST:/tmp/vibe-os-human-proof.tgz" ./vibe-os-human-proof.tgz
tar -xzf ./vibe-os-human-proof.tgz
python3 tools/check_cloud_playability_artifacts.py \
  --human-session ./vibe-os-human-proof
```

The tarball must contain only the allowlist from the safety contract. If the
checker fails, delete the local bundle and fix the remote collection. Do not
manually add files to the tarball.

Never transfer these from the remote host:

- `/tmp/vibe-os-DOOM1.WAD`
- `build/disk.img`
- `build/status.*.bin`
- `build/gfx.bin`, `build/vga*.txt`, screenshots, PNG/PPM/BMP files, or other
  pixel output
- `build/doom-audio.wav`, WAV/MP3/OGG/FLAC/AIFF files, or any other raw audio
  capture

## Cleanup

Stop QEMU through its monitor or terminate the remote process, then clean the
remote host:

```sh
ssh "$VIBE_CLOUD_HOST" '
  pkill -f "qemu-system-x86_64" || true
  rm -f /tmp/vibe-os-DOOM1.WAD
  rm -f /tmp/vibe-os-human-proof.tgz
  rm -f ~/vibe-os-cloud-playtest/build/doom-audio.wav
  rm -rf /tmp/vibe-os-human-proof
  rm -rf ~/vibe-os-cloud-playtest
'
```

Finally destroy the disposable VM, Codespace, or cloud instance. Do not keep it
around as a long-lived QEMU host.
