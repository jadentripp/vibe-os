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

- CPU/runtime health: `pg=ON`, `pmm=OK`, `vmm=OK`, `libc=OK`, `c=OK`,
  `usr=OK`, `heap=OK`, `free>0`, and `ticks>0` prove the protected-mode kernel,
  memory managers, C runtime probes, heap, and PIT timer are alive in the smoke
  VM.
- Process/exec: `exec=OK`, `path=DOOM.ELF`, `execsys=a/b/c/d/e/f`,
  `target`, `argv0`, `doom=OK`, and `doomrun=RUN` show that the kernel loaded
  the Doom ELF, performed a syscall-driven exec handoff, seeded argv, and left
  Doom running rather than merely validating bytes on disk. The six `execsys`
  counters are attempts, successes, failures, handoffs, scheduled targets, and
  rollbacks.
- Storage/libc: `wad=OK`, `lmp=OK`, `doomopen=OK`, `doomread=OK`,
  `doomseek`, `doomsbrk`, `doommode`, `doomerr=00000000`,
  `doomexit=00000000`, `doomfault=00000000`, `doomfaultip=00000000`,
  `doomfaultv=00000000`, `doomfaulterr=00000000`, `fault=0/.../0`,
  `panic=NONE`, `shutdown=NONE`, and `doomlog` make
  WAD/FAT/syscall/process failures visible without uploading the WAD or disk
  image. On a Doom user fault, `doomfault` is CR2, `doomfaultip` is the
  faulting EIP, `doomfaultv` is the CPU exception vector, and `doomfaulterr`
  is the x86 error code. The compact `fault=` tuple records
  vector/error/eip/cs/esp/ss/cr2/pid/kind/state/last-syscall for the most
  recent fault frame. `panic=KEXC` is reserved for unhandled non-Doom kernel
  exceptions, and `shutdown=HALT`/`shutdown=REBOOT` mark intentional OS shutdown
  paths.
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
- Audio/mouse observability: `audio`, `doomsound`, `sfxmix`, `voices`,
  `musicvoices`, `musicmix`, `musicloop`, `audioirq`, `ack8`, `ack16`,
  `refill`, mixer safety counters, `mouse`,
  `mouseirq`, `mousepkt`, and `mousepoll` are required to be present and
  well-formed even when hardware is absent (`audio=NONE`, `mouse=NONE`).
  `tools/check_audio_continuity_proof.py` is the stricter SB16 path: it compares
  the phase snapshots using status snapshots only, requires `audio=SB16`, and
  proves IRQ/refill, SFX, and looped music-carrier counters progressed without
  uploading audio samples. It does not upload audio samples.
  `tools/check_audio_continuity_proof.py` checks status snapshots only and
  does not upload audio samples.
- Scheduler proof: `preempt`, `pattempt`, `pskip`, and `pself=OK` expose the
  timer preemption selector and its self-test status in every cloud artifact.

`tools/check_real_wad_proof.py` gates the real-WAD status on both the non-pixel
visual proof and the scripted playability proof, plus the system/process/storage
debug contract above. A final status line by itself is not sufficient: the gate
requires the early, fire, movement, use, and menu snapshots so keyboard counters
and Doom action flags can be compared across the scripted phases. It rejects
duplicate fields, malformed hex, weak synthetic exec counters, Doom error
strings, failed self-tests, and status lines that only prove a boot banner.
`tools/check_human_playability_proof.py` can also compare the phase snapshots
directly.

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
   The real-WAD checker consumes them like this:

   ```sh
   python3 tools/check_real_wad_proof.py \
     --baseline build/status.early.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --menu build/status.after-menu.txt \
     build/status.txt

   python3 tools/check_audio_continuity_proof.py \
     --baseline build/status.early.txt \
     --fire build/status.after-fire.txt \
     --movement build/status.after-move.txt \
     --use build/status.after-use.txt \
     --menu build/status.after-menu.txt \
     build/status.txt
   ```

4. Treat the run as playable-cloud-proof green only when the QEMU capture step
   finishes, both checker steps pass, and
   `tools/check_cloud_playability_artifacts.py` accepts the downloaded artifact.
   That artifact gate rejects WAD/disk/image/pixel filenames, duplicate required
   status basenames, and renamed WAD/disk/image payload signatures. The workflow
   intentionally keeps proof assertions in the checker steps so a failed cloud
   boot still uploads status files and prints the exact failing fields.

This is still not a substitute for a human visually playing Doom, but it is a
stronger cloud-safe proxy: it proves real-WAD boot, level progression, input
delivery, player movement, fire/use commands, and menu control through the same
kernel/port paths a human session uses.

For a live human session, use the Remote Doom Playtest Runbook in
`docs/runbooks/remote-doom-playtest.md`. That path keeps QEMU on a disposable
remote host, connects through VNC over SSH, and uses
`tools/check_cloud_playability_artifacts.py` to validate downloaded diagnostics
without storing WAD data or rendered pixels in the repo.
