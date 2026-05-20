# Remote Doom Playtest Runbook

This is the safe human-run path for playing vibe-os Doom without running QEMU on
the laptop and without committing or uploading WAD data, disk images, or Doom
pixels to the repository.

Use a disposable remote Ubuntu VM, Codespace, or throwaway bare-metal host. The
host only needs CPU emulation; hardware virtualization is helpful but not
required because the runbook uses QEMU TCG.

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
make clean
make DOOM_WAD=/tmp/DOOM1.WAD
```

## Interactive Boot

Start QEMU on the remote host with a loopback-only VNC display and monitor
socket:

```sh
mkdir -p build
qemu-system-x86_64 \
  -machine pc,accel=tcg \
  -device sb16 \
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

- If `mouse=OK` appears in status, PS/2 relative movement and the first three
  buttons flow through `SYS_POLL_MOUSE` into Doom `ev_mouse` events.
- VNC mouse grab/release and host pointer acceleration are not normalized yet,
  so keyboard is the primary playability path.

Expected audio behavior:

- `-device sb16` exposes the intended Sound Blaster 16 target to the guest.
- Status should report `audio=SB16` when the probe succeeds and `audio=NONE`
  when the remote QEMU/audio setup does not expose the device.
- VNC does not carry audio. Treat sound as status/counter proof unless you also
  configure remote audio forwarding on the disposable host.

## Status Capture

Capture non-pixel status while the VM is running:

```sh
printf 'pmemsave 0x9d000 2048 build/status.manual.bin\n' \
  | nc -w 3 -U build/monitor.remote.sock
perl -e 'local $/; $d = <>; $d =~ s/\0/ /g; print $d' \
  build/status.manual.bin > build/status.manual.txt
sed -n '1,220p' build/status.manual.txt
```

For a fully automated truth-serum run, use the GitHub Actions **Real WAD smoke**
workflow instead of this manual VNC path. It captures:

- `status.early.txt`
- `status.after-fire.txt`
- `status.after-move.txt`
- `status.after-use.txt`
- `status.after-menu.txt`
- `status.txt`
- `smoke.log`, `qemu.log`, `monitor.log`, and `serial.log`
- `kernel.elf`, `user_probe.elf`, and `doom.elf`

It deliberately does not upload `disk.img`, `gfx.bin`, `vga*.txt`, WAD files, or
rendered Doom pixels.

After downloading the diagnostic artifact, validate it locally without WAD data
or QEMU. The artifact checker also rejects duplicate status basenames and
renamed WAD/disk/image payload signatures, so do not add extra binaries to the
diagnostic directory:

```sh
python3 tools/check_real_wad_proof.py \
  --baseline path/to/real-wad-smoke-status/status.early.txt \
  --fire path/to/real-wad-smoke-status/status.after-fire.txt \
  --movement path/to/real-wad-smoke-status/status.after-move.txt \
  --use path/to/real-wad-smoke-status/status.after-use.txt \
  --menu path/to/real-wad-smoke-status/status.after-menu.txt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_human_playability_proof.py \
  --baseline path/to/real-wad-smoke-status/status.early.txt \
  --fire path/to/real-wad-smoke-status/status.after-fire.txt \
  --movement path/to/real-wad-smoke-status/status.after-move.txt \
  --use path/to/real-wad-smoke-status/status.after-use.txt \
  --menu path/to/real-wad-smoke-status/status.after-menu.txt \
  path/to/real-wad-smoke-status/status.txt

python3 tools/check_cloud_playability_artifacts.py path/to/real-wad-smoke-status
```

## Manual Review Checklist

Call a remote human playtest credible only after checking all of this:

- The image was built on the remote host with a validated external
  `DOOM1.WAD`; no WAD is tracked in git.
- Doom reaches the title/menu or E1M1 visually in the VNC display.
- Arrow keys, Ctrl, Space, Enter, and Escape visibly affect Doom.
- `status.manual.txt` or the GitHub artifact reports `gameplay=OK`,
  `gmap=00000101`, increasing `gtic`/`leveltime`, nonzero `keyirq`,
  `keyqueue`, and `keypoll`, and nonzero playability flags.
- Save/config writes are attempted from Doom and then checked after a rebooted
  remote image before claiming persistence beyond the current host tests. Run
  the image-local checker on the disposable host, not on the laptop:

  ```sh
  python3 tools/check_doom_persistence_image.py \
    --require-default \
    --require-save-slot 0 \
    build/disk.img
  ```

  The checker reads `DEFAULT.CFG` and `DOOMSAV0.DSG` through the FAT parser and
  prints only compact metadata, save description, and version text. Do not
  upload `build/disk.img` because it contains the WAD.
- Audio is described honestly: `audio=SB16` plus SFX/music mixer counters proves
  the guest path; audible remote sound requires separate host audio forwarding.
- Exit is handled through the QEMU monitor (`quit`) today. A graceful Doom
  quit-to-shell or reboot path is still a gap.

## Honest Remaining Gaps

- Display scaling is fixed nearest-neighbor 2x with a Mode 13h fallback; there
  is no aspect-correct fullscreen policy yet.
- Mouse input has a real PS/2 path, but no cloud mouse-injection proof and no
  VNC pointer tuning policy.
- Save/config persistence has host and filesystem coverage, but still needs a
  real-WAD reboot proof after a human changes settings or saves a game.
- Music renders bounded PCM windows and loops them as an SB16 carrier voice mixed
  with SFX; long realtime music streaming and audible remote validation remain
  unfinished.
- Doom exit/reboot behavior is not polished for a human session.

Cleanup:

```sh
rm -f /tmp/DOOM1.WAD
rm -f build/status.manual.bin build/status.manual.txt
```

Then destroy the disposable remote host.
