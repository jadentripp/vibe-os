# Play Now In The Cloud

Fastest safe path: run QEMU on a disposable Linux host, not on the Mac.

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

Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens the menu.
VNC does not carry game audio in this quick path; current SB16 and audible audio
are proved by the cloud `real-wad-smoke.yml` aggregate audio proof.
