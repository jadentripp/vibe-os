# Remote Doom Playtest Runbook

This is the safe human-run path for playing vibe-os Doom without running QEMU on
the laptop and without committing or uploading WAD data, disk images, or Doom
pixels to the repository.

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
  through `SYS_POLL_MOUSE`.
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
- Run `tools/check_audio_continuity_proof.py` on the downloaded status snapshots.
  It proves SB16 version, DMA programming, playback start, voice queue,
  IRQ/refill, SFX, and looped music-carrier counters progressed; it does not
  upload audio samples or prove a human heard sound.
- For an audible remote proof that still avoids publishing copyrighted audio, run
  the GitHub workflow with `audible_audio_proof=true`. That uses QEMU's WAV
  backend on the disposable runner, analyzes the temporary capture into
  aggregate `audio-proof.json`, validates it with
  `tools/check_audible_audio_proof.py`, requires the same status-only SB16 continuity
  snapshots so a music carrier alone cannot pass as SFX proof, and deletes the
  temporary WAV before upload. Keep the manifest and status files; do not upload
  or keep captured Doom audio.
- For a manual listener check, use remote audio forwarding on the disposable
  host and record written notes only. If you make a local audio capture to debug
  clipping or balance, delete the temporary WAV when done and do not add it to a
  diagnostic artifact.

## Human Status Capture

Capture non-pixel status while the VM is running. Use the same filenames as the
scripted cloud proof so the local checkers can compare real human actions across
the same phases:

```sh
capture_status() {
  label="$1"
  printf 'pmemsave 0x9d000 4096 build/status.%s.bin\n' "$label" \
    | nc -w 3 -U build/monitor.remote.sock
  perl -e 'local $/; $d = <>; $d =~ s/\0/ /g; print $d' \
    "build/status.$label.bin" > "build/status.$label.txt"
  sed -n '1,220p' "build/status.$label.txt"
}

# Capture before input, then play through VNC and capture after each action.
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

cp build/status.after-start.txt build/status.early.txt
cp build/status.after-menu.txt build/status.txt
rm -f build/status.*.bin
```

Collect the manual proof bundle on the disposable remote host. Use an empty
scratch directory outside the repository. The collector does not launch QEMU; it
copies only status text, logs, ELF diagnostics, `doom.symbols`, optional
`audio-proof.json`, writes `human-playtest-notes.txt`, and then runs
`tools/check_cloud_playability_artifacts.py --human-session` against the bundle.
It deliberately skips `disk.img`, WADs, status binaries, screenshots, pixel
dumps, and raw audio:

```sh
python3 tools/collect_human_playtest_bundle.py \
  --build-dir build \
  --output-dir /tmp/vibe-os-human-proof \
  --playtester "<name-or-initials>" \
  --audio status-only
```

`audio=` may be `status-only`, `listener-pass`, `audio-proof-json-pass`, or
`not-tested`. Use `audio-proof-json-pass` only when the bundle also contains a
validated aggregate `audio-proof.json`. Keep subjective comments in extra text
keys if useful, but do not store screenshots, audio captures, WADs, disk images,
or `status.*.bin` files in the proof directory.

If you need to audit the exact notes format, the collector writes these required
keys: `schema=human-playtest-notes-v1`, `commit=...`, `playtester=...`,
`remote_host=disposable`, `qemu_location=remote`,
`qemu_display=127.0.0.1:1`, `monitor_socket=unix-monitor-socket`,
`vnc_tunnel=loopback-only`, `vnc_endpoint=127.0.0.1:5901`,
`wad=shareware-v1.9-validated-remote-only`, `display=pass`,
`keyboard=pass`, `mouse=pass`, `diagnostics=non-wad-status-only`,
`proof_bundle=allowlisted-status-only`, `no_local_qemu=yes`,
`no_wad_upload=yes`, `no_disk_upload=yes`, and `no_pixel_upload=yes`.

Download `/tmp/vibe-os-human-proof` or a tarball of it. Do not download
`build/disk.img` or `/tmp/DOOM1.WAD`.

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

python3 tools/check_audio_continuity_proof.py \
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
  --human-session path/to/vibe-os-human-proof
```

The audible checker command is only expected to pass when the workflow was
triggered with `audible_audio_proof=true` and the artifact contains
`audio-proof.json`. The `--human-session` artifact check is for the manual VNC
bundle and requires `human-playtest-notes.txt`; if you used
`tools/collect_human_playtest_bundle.py`, that check already ran once on the
remote host before download.

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
  `status.early.txt`, `status.after-start.txt`, `status.after-fire.txt`,
  `status.after-move.txt`, `status.after-use.txt`, `status.after-mouse.txt`,
  `status.after-menu.txt`, `status.txt`, `doom.symbols`, and the diagnostic ELF
  files, was produced with `tools/collect_human_playtest_bundle.py`, and
  `tools/check_cloud_playability_artifacts.py --human-session` passes.
- `status.txt` or the GitHub artifact reports `gameplay=OK`,
  `gmap=00000101`, increasing `gtic`/`leveltime`, nonzero `keyirq`,
  `keyqueue`, and `keypoll`, `keyseen` bits for Up/Ctrl/Space/Escape, nonzero
  `mouseirq`/`mousepkt`/`mousepoll` when mouse is expected, changed `ppos` from
  `status.after-start.txt` to
  `status.after-move.txt`, fire ammo/refire evidence in `pflags`, and menu
  inactive-to-active evidence after Escape.
- Save/config writes are attempted from Doom and then checked after a rebooted
  remote image before claiming persistence beyond the current host tests. The
  GitHub **Real WAD smoke** workflow has an opt-in `persistence_proof` input
  for this path. It copies the fresh `build/disk.img` to a runner-local
  baseline immediately after rebuilding the real-WAD image, restores that
  baseline before the persistence boot, performs a first boot with
  `persistence_input_script`, checks that `DEFAULT.CFG` changed from that
  baseline, captures an after-write image snapshot, boots the same image again,
  and checks that the requested FAT entries still match the after-write snapshot.
  The checker summary is saved as status text; the disk image and WAD are not
  uploaded. If your input script creates a save, set `persistence_save_slot` to
  require the matching `DOOMSAVN.DSG`. For scripted save names, prefer the
  smoke-runner `text=NAME` action over one `sendkey` action per letter so the
  QEMU monitor connection latency does not consume the proof timeout.

  For a manual remote proof, copy a baseline before booting, quit Doom through
  its menu so `I_Quit` writes defaults, optionally create a save, boot the same
  image again, and run the image-local checker on the disposable host, not on
  the laptop:

  ```sh
  cp build/disk.img /tmp/vibe-os-disk.before-persistence.img
  # Boot remotely, quit Doom or create a save.
  cp build/disk.img /tmp/vibe-os-disk.after-persistence-write.img
  # Boot the same build/disk.img again.
  python3 tools/check_doom_persistence_image.py \
    --baseline-image /tmp/vibe-os-disk.before-persistence.img \
    --reboot-baseline-image /tmp/vibe-os-disk.after-persistence-write.img \
    --require-default \
    --require-save-slot 0 \
    build/disk.img
  ```

  The checker reads `DEFAULT.CFG` and `DOOMSAV0.DSG` through the FAT parser,
  requires a fresh baseline for reboot claims, and prints only compact metadata,
  save description, version text, and whether the requested entry changed from
  the baseline and survived the reboot comparison. Do not upload `build/disk.img`
  because it contains the WAD.
- Audio is described honestly: `audio=SB16` plus the audio continuity checker
  proves the guest SB16 path advanced through IRQ/refill, SFX, and looped
  music-carrier counters; audible remote sound requires separate host audio
  forwarding or the aggregate `audio-proof.json` lane. Neither lane should
  publish captured Doom audio.
- Exit is handled through the QEMU monitor (`quit`) today. A graceful Doom
  quit-to-shell or reboot path is still a gap.
- Shutdown/panic evidence is a separate opt-in OS smoke lane. When
  `shutdown_panic_proof` is enabled, validate the downloaded artifact with
  `tools/check_shutdown_panic_proof.py`; do not count monitor `quit` cleanup as
  a guest-requested halt, reboot, or panic proof.

## Honest Remaining Gaps

- Display scaling is fixed nearest-neighbor 2x with a Mode 13h fallback; there
  is no aspect-correct fullscreen policy yet.
- Mouse input has a real PS/2 path and a cloud mouse-injection proof; VNC
  pointer tuning policy is still unpolished.
- Save/config persistence has host and filesystem coverage plus an opt-in cloud
  workflow path, but still needs a current passing real-WAD reboot proof after
  Doom changes settings or saves a game.
- Music renders bounded PCM windows and loops them as an SB16 carrier voice mixed
  with SFX; long realtime music streaming and audible remote validation remain
  unfinished until `audio-proof.json` passes on a current real-WAD run and a
  song-position streaming proof replaces the bounded carrier claim.
- Doom exit/reboot behavior is not polished for a human session.
- Hardware support remains bounded to the QEMU BIOS/IDE/PS2/VBE/SB16 target in
  `docs/hardware-support.md`; this runbook does not prove UEFI, AHCI, USB, SMP,
  APIC, HPET, or physical-hardware support.

Cleanup:

```sh
rm -f /tmp/DOOM1.WAD
rm -f build/status.*.bin build/human-playtest-notes.txt
```

Then destroy the disposable remote host.
