# Post-Checkpoint Doom Gaps

This is the single honesty ledger for the Doom-capability checkpoint. It is
about what still has to be proved before saying "you can play Doom on vibe-os",
not about making the project sound finished.

The `GAP[...]` lines below are intentionally machine-readable. Keep each row's
`status`, `category`, `gate`, and `evidence` fields current; host tests parse
them so README and runbook wording cannot quietly drift into overclaiming.

## Closed Since Earlier Checkpoints

- The smoke status now exposes `doomexit=`, `doomfault=`, `doomfaultip=`,
  `doomfaultv=`, `doomfaulterr=`, and compact `fault=` frame diagnostics. The
  kernel records Doom's user-mode `exit()` status plus CR2, faulting EIP,
  exception vector, x86 error code, selectors, stack, current process identity,
  state, and last syscall; those values are now part of the cloud-safe RAM
  status artifact so a real-WAD run can prove Doom is still running and has not
  faulted.
- Doom user faults record `doomrun=FAULT` plus `doomfault=<cr2>`,
  `doomfaultip=<eip>`, `doomfaultv=<vector>`, `doomfaulterr=<error-code>`, and
  `fault=vector/error/eip/cs/esp/ss/cr2/pid/kind/state/syscall`.
- The FAT16 image has root entries for `DEFAULT.CFG` and `DOOMSAV0.DSG` through
  `DOOMSAV5.DSG`, and host tests prove image-level allocation/readback behavior.

## Machine-Readable Gap Ledger

- `GAP[CLOUD_BOOT] status=open category=cloud-boot gate=real-wad-smoke.yml evidence=status.txt`

Current state:

- The normal cloud smoke builds `disk.img`, boots QEMU in GitHub Actions, and
  verifies the synthetic-WAD status path.
- The manual real-WAD workflow validates the shareware `DOOM1.WAD` size/hash,
  rebuilds the image with that WAD, and keeps WAD bytes, disk images, and
  rendered pixels out of uploaded artifacts.

Still missing:

- A current passing manual real-WAD cloud workflow on the exact commit being
  claimed. A previous run is useful evidence, but it is stale once the kernel/runtime changes.

Executable gate:

- Trigger `.github/workflows/real-wad-smoke.yml` for the target ref, then archive
  only the uploaded non-WAD diagnostics: `status*.txt`, `status*.bin`, QEMU log,
  serial log, monitor log, and ELF files.

- `GAP[REAL_GAMEPLAY] status=open category=real-gameplay gate=check_real_wad_proof.py evidence=gameplay-status`

Current state:

- `tools/check_real_wad_proof.py` requires Doom to enter `GS_LEVEL`, reach E1M1,
  advance tics, present non-pixel visual summaries, read the WAD through kernel
  file syscalls, keep Doom exit/fault counters at zero, and report coherent
  process/storage/VM/audio/input/scheduler telemetry.
- The checker delegates scripted input validation to
  `tools/check_human_playability_proof.py`.

Still missing:

- A fresh real-WAD status artifact proving those fields on the current commit
  after the real-WAD fault is fixed.

Executable gate:

- Run `python3 tools/check_real_wad_proof.py` with the early, fire, movement,
  use, menu, and final status artifacts from the cloud workflow, and require it
  to pass without local QEMU or pixel dumps.

- `GAP[HUMAN_PLAYTEST] status=open category=human-playtest gate=remote-doom-playtest.md evidence=human-session-notes`

Current state:

- `docs/runbooks/remote-doom-playtest.md` describes the safe human path: boot on a
  disposable remote host, expose loopback-only VNC through SSH, keep the WAD
  outside git, and validate downloaded diagnostics afterward.
- Deterministic scripted fire/move/use/menu checks are a strong cloud-safe proxy.

Still missing:

- A person has not yet completed and recorded a current remote VNC playtest where
  keyboard actions visibly affect the menu and E1M1 gameplay.

Executable gate:

- Follow the remote runbook, capture non-WAD status artifacts after real keyboard
  actions, and run `tools/check_cloud_playability_artifacts.py` plus the real-WAD
  and human-playability checkers on the downloaded diagnostics.

- `GAP[PERSISTENCE] status=open category=persistence gate=reboot-persistence-proof evidence=mutated-disk-status`

Current state:

- The FAT16 image has root entries for Doom config and save files.
- Host tests prove allocation, readback, truncation, deletion, protected-file
  refusal, and libc save/config file modes without launching QEMU.
- `tools/check_doom_persistence_image.py` can inspect a mutated remote image and
  require Doom-shaped `DEFAULT.CFG` text plus a `DOOMSAVN.DSG` save header
  without exporting the WAD or rendered pixels.
- The kernel implements FAT16 cluster allocation/free/truncate over the disk
  image, so the storage layer is no longer a read-only WAD loader.

Still missing:

- There is not yet a cloud reboot proof where Doom writes a config or save file,
  the VM exits, the same disk image is booted again, and Doom or a verifier reads
  the persisted bytes back.

Executable gate:

- Add a persistence probe mode or deterministic Doom menu script that writes a
  save/config file, preserves the mutated disk image inside the disposable cloud
  runner, boots it again, verifies the bytes through OS file syscalls, and then
  runs `python3 tools/check_doom_persistence_image.py --require-default
  --require-save-slot N build/disk.img` on that remote image before deleting it.

- `GAP[AUDIO] status=open category=audio gate=remote-sb16-audible-proof evidence=audio-status`

Current state:

- The kernel has an SB16 path with IRQ/DMA setup, stereo unsigned 8-bit SFX
  mixing, active voice tracking, panning, pitch stepping, refill accounting, and
  smoke-visible audio counters.
- The Doom port has a freestanding MUS/MIDI parser and bounded PCM renderer that
  submits music as a looped PCM carrier through the same audio syscall and SB16
  voice mixer path without editing the original Doom tree.

Still missing:

- No current cloud or remote artifact proves audible output from a real Doom run.
- Music renders bounded PCM windows and loops that carrier rather than advancing
  a long-running MUS/MIDI pull/refill stream; balancing between music and SFX
  still needs real playback tuning.

Executable gate:

- Add a remote SB16 validation run that captures status counters plus a safe audio
  observation, then harden the stream path so long music playback does not rely on
  a single pre-rendered window.

- `GAP[VM_POSIX] status=open category=vm-posix gate=vm-posix-contract evidence=host-and-cloud-tests`

Current state:

- User processes have separate page directories, user/supervisor page bits,
  process VM-region metadata, `int 0x80`, table-backed `exec`, syscall pointer
  validation, anonymous/private `mmap`, display `ioctl`, file syscalls, and
  classified `fork`/`waitpid` failures.

Still missing:

- This is not a full POSIX environment. There is no arbitrary-path `exec`, real
  `fork`, descriptor duplication, file-backed `mmap`, signal model, terminal
  device model, or POSIX delete-while-open behavior.
- The kernel is still identity-mapped in low memory, page-table allocation is not
  fully dynamic, and 32-bit paging cannot enforce NX.

Executable gate:

- Keep unsupported ABI calls classified as explicit errors, add host tests for
  every new syscall contract, and add cloud tests for any VM behavior used by
  Doom rather than documenting it as assumed.

- `GAP[SHUTDOWN_PANIC] status=open category=shutdown-panic gate=panic-poweroff-proof evidence=panic-status`

Current state:

- User-space `exit()` is handled for the probe and Doom process paths.
- Doom `exit()` records `doomrun=EXIT` plus `doomexit=<code>`.
- Expected user isolation faults are reported by the probe, Doom user faults are
  visible through `doomfault=`, `doomfaultip=`, `doomfaultv=`, and
  `doomfaulterr=`, and Doom startup text is tailed into `doomlog=`.
- The interactive shell has `halt` and PS/2-controller `reboot` commands.

Still missing:

- The cloud smoke runner uses QEMU `-no-reboot -no-shutdown` and exits through
  the QEMU monitor `quit` command. There is no cloud proof that an OS-requested
  reboot, shutdown, or ACPI poweroff works end to end.
- Arbitrary kernel exceptions still fall into `exception_halt` without a rich
  panic record in the status block. A fatal kernel crash before the status block
  is updated may only be visible through serial/QEMU logs.

Executable gate:

- Add an explicit reboot/shutdown proof mode in a disposable cloud runner, or add
  an ACPI poweroff path and assert QEMU exits for that reason.
- Add a compact panic record with vector, error code, EIP, CR2, and current
  process kind, then make the smoke runner decode and upload it as text.

- `GAP[HARDWARE_LIMITS] status=open category=hardware-limits gate=hardware-matrix evidence=compatibility-notes`

Current state:

- The supported target is BIOS x86 in QEMU with ATA PIO, FAT16, PS/2 keyboard,
  PS/2 mouse when present, PIT timing, VBE XRGB8888 LFB or VGA Mode 13h fallback,
  and optional SB16-compatible audio.

Still missing:

- There is no UEFI boot path, AHCI/SATA native driver, USB input/storage stack,
  SMP, APIC/HPET coverage, general PCI enumeration beyond narrow device needs,
  broad VBE mode matrix, or proof on physical hardware.

Executable gate:

- Publish a small hardware/support matrix and add one cloud or disposable-machine
  proof per newly claimed device class. Until then, claims should stay scoped to
  the current QEMU BIOS/IDE/PS2/VBE/SB16 target.

## Claim Boundary

Do not call the project Doom-capable from README, release notes, or comments just
because host tests pass. A playable claim requires at least:

- a current manual real-WAD cloud workflow pass for the exact commit
- `check_real_wad_proof.py` and `check_human_playability_proof.py` passing on the
  uploaded status artifacts
- a remote human playtest or an explicit statement that only scripted
  cloud-safe playability has been proved
- no tracked WADs, disk images, rendered Doom pixels, or modified
  `third_party/doom` files
