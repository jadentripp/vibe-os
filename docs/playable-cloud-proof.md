# Playable Cloud Proof

The playable-Doom milestone is proved in cloud CI without uploading WADs, disk
images, framebuffer dumps, or rendered WAD pixels. The proof is status-driven:
the OS boots the validated shareware `DOOM1.WAD`, Doom autostarts E1M1, QEMU
injects deterministic keyboard input through the same PS/2 path a human would
use, and the kernel exports compact counters and state deltas from Doom.

## Deterministic Script

The manual **Real WAD smoke** workflow runs this input script after Doom has had
time to settle:

```text
after-fire:hold=ctrl:800,wait=2,snapshot
after-move:hold=up:1200,wait=3,snapshot
after-use:spc,wait=2,snapshot
after-menu:esc,wait=2,snapshot
```

Each phase uses QEMU monitor `sendkey`, waits for Doom to process ticks, and
captures a decoded status artifact. The final status is captured after the menu
phase. `tests/run_smoke_qemu.sh` still supports the older `SMOKE_SENDKEYS`
fallback, but `SMOKE_INPUT_SCRIPT` is the deterministic playability path.

## Non-Pixel Evidence

The cloud proof requires these status families:

- Runtime: `gameplay=OK`, `gstate=00000000`, `gmap=00000101`, `gtic>0`, and
  `leveltime>0` prove the real engine reached E1M1 gameplay.
- Input pipeline: `keyirq`, `keyqueue`, and `keypoll` increase from the early
  snapshot to the final snapshot, proving IRQ1 input entered the kernel queue
  and Doom consumed it through `SYS_POLL_KEY`.
- Player/action deltas: `pflags` records cumulative player, movement, attack,
  use, menu, and position-delta observations; `pdelta>0` proves the player
  moved in Doom state, not only that a key was delivered.
- Menu state: final `gflags` has the menu-active bit after Escape, proving the
  scripted input can affect the Doom UI while remaining in `GS_LEVEL`.
- Visual presence without pixels: `doompal`, `doomframe`, `doomnonzero`,
  `doomcolors`, and `doomsamp` summarize palette/frame activity without
  uploading `gfx.bin` or any rendered frame bytes.

`tools/check_real_wad_proof.py` gates the real-WAD status on both the non-pixel
visual proof and the scripted playability proof. `tools/check_human_playability_proof.py`
can also compare the phase snapshots directly.

## Safe Remote Runbook

1. Open the **Real WAD smoke** workflow in GitHub Actions and run it manually.
   Leave `wad_url` empty to use `REAL_DOOM_WAD_URL` or the public shareware
   fallback, or provide a temporary URL to `DOOM1.WAD`, `DOOM1.WAD.gz`, or a zip
   containing `DOOM1.WAD`.
2. Confirm the fetch step prints the expected shareware v1.9 size and SHA-1.
   The workflow rebuilds with `DOOM_WAD=/tmp/DOOM1.WAD` and deletes that local
   WAD after the post-smoke validation.
3. Review `status.early.txt`, `status.after-fire.txt`, `status.after-move.txt`,
   `status.after-use.txt`, `status.after-menu.txt`, and `status.txt` in the
   uploaded diagnostic artifact. These are text status files, not framebuffer
   or WAD artifacts.
4. Treat the run as playable-cloud-proof green only when both checker steps
   pass and the uploaded paths exclude `build/disk.img`, `build/gfx.bin`,
   `build/vga*.txt`, and any WAD path.

This is still not a substitute for a human visually playing Doom, but it is a
stronger cloud-safe proxy: it proves real-WAD boot, level progression, input
delivery, player movement, fire/use commands, and menu control through the same
kernel/port paths a human session uses.
