# Audio Path

The first real Doom audio target is an ISA Sound Blaster 16 compatible device at
base port `0x220`. This is the practical hobby-OS target because QEMU exposes an
SB16 model and the device has a simple DSP reset/version probe before the harder
mixing work.

Current kernel behavior:

- probes the SB16 DSP reset/read ports and records `audio=SB16` or `audio=NONE`
  in the smoke status block
- configures SB16 mixer IRQ/DMA routing for IRQ 5, 8-bit DMA 1, and 16-bit DMA 5
- owns a 4096-byte, 4096-byte-aligned unsigned-silence DMA buffer in low kernel
  memory for ISA DMA reachability
- programs 8-bit DMA channel 1 with mask, flip-flop, address, page, count, and
  auto-init memory-to-device mode writes
- starts 8-bit DMA playback with DSP speaker-on, time-constant, block-size, and
  stereo auto-init output commands when Doom exercises the audio syscall
- stops playback with DSP exit-auto-init/speaker-off and masks DMA channel 1
- installs an IRQ 5 handler that reads the 8-bit DSP status/ack port, reads the
  16-bit ack port, records which ACK paths were pending, and advances
  half-buffer refill accounting while playback is active
- exposes `SYS_AUDIO`/`VIBE_SYS_AUDIO` for the Doom platform layer
- records Doom sound calls as `doomsound=<hex count>` plus last command, handle,
  and packed parameters in kernel memory
- accepts Doom SFX descriptors from the platform layer and reports successful
  buffer submissions as `sfxmix=<hex count>`
- keeps a fixed eight-slot active voice table keyed by Doom sound handle, with
  sample pointer, length, fixed-point current position, volume, separation,
  pitch, panned left/right gains, pitch step, and start order
- handles `START_SFX`, `STOP_SFX`, and `UPDATE_SFX` by registering, clearing, or
  retuning active voices before the next DMA half-buffer refill
- steals the oldest active voice when all eight slots are full, so new SFX stay
  bounded without always crushing slot zero
- reports audio IRQ and mixer ring health in smoke status:
  `voices=`, `audioirq=`, `ack8=`, `ack16=`, `refill=`, `half=`, `mixwrap=`,
  `mixover=`, `mixunder=`, `mixclip=`, `steal=`, `pitchclamp=`, and
  `panclamp=`

SB16 constants in `kernel/kernel.asm`:

- DSP base: `SB16_BASE equ 0x0220`
- reset/read/write/status ports: `0x226`, `0x22a`, `0x22c`, `0x22e`
- reset acknowledgement: `0xaa`
- version command: `0xe1`
- playback defaults: IRQ 5, 8-bit DMA 1, 16-bit DMA 5
- DMA buffer: `SB16_DMA_BUFFER_BYTES equ 4096`
- DMA block: `SB16_DMA_BLOCK_BYTES equ SB16_DMA_BUFFER_BYTES / 2`
- 8-bit DMA mode: `DMA8_CH1_AUTO_READ_MODE equ 0x59`
- DSP output command: `SB16_DSP_8BIT_AUTO_OUT equ 0xc6` with
  `SB16_DSP_MODE_UNSIGNED_STEREO equ 0x20`

8-bit SFX DMA playback:

The Doom platform layer keeps original Doom source pristine, resolves the `ds*`
sound lump for `I_StartSound`, caches the lump, strips the 8-byte Doom sound
header, and passes a small `vibe_audio_sfx_desc_t` through `SYS_AUDIO`. The
descriptor contains the raw unsigned 8-bit PCM sample pointer, length, volume,
separation, pitch, and Doom sound id.

The kernel validates the descriptor and sample range against the current Doom
process memory map, then registers the sound in the active voice table. Each
SB16 IRQ toggles the tracked half-buffer, clears that half to unsigned silence,
and mixes every active voice into interleaved unsigned 8-bit stereo bytes. Each
source sample is centered around `0x80`, scaled by the voice's panned gain,
added to the existing left or right DMA byte, clipped back to unsigned 8-bit
PCM, and written into the kernel-owned SB16 DMA ring.

Separation follows Doom's original squared pan law in source-contract form:
`left = volume - ((volume * (sep + 1)^2) >> 16)` and
`right = volume - ((volume * (sep - 256)^2) >> 16)`, with gains clamped to the
Doom SFX volume range. Pitch uses a 16.16 source position and a table-free
integer step curve anchored at `pitch=128` as `1.0x`; the curve gives useful
subsample stepping around Doom's pitch variations while preserving bounded low
pitch behavior.

The mixer ring now keeps explicit safety counters. `mixwrap` increments whenever
`sb16_dma_write_pos` wraps back to the start of the 4096-byte DMA ring,
`mixover` increments when a mixer byte lands in the half-buffer currently marked
as active by IRQ accounting, and `mixunder` increments for rejected or empty SFX
submissions. These are deliberately smoke-visible so host tests can pin the
source contract without requiring local QEMU or real Doom pixels/audio assets.

Active SFX playback has bounded state instead of only one-shot submissions.
`START_SFX` validates the descriptor and user sample range, then writes, reuses,
or steals one of eight voice slots. `STOP_SFX` clears the matching handle, and
`UPDATE_SFX` refreshes volume, separation, pitch, derived pan gains, and pitch
step for the existing handle. Refill advances each voice's 16.16 source
position, supports repeated source samples for low pitch and skipped source
samples for high pitch, and retires voices that reach the end of their sample.

Mixer safety is smoke-visible. `mixclip` counts left/right output clipping,
`mixunder` counts invalid/empty SFX or active refills with no voices, `steal`
counts bounded oldest-voice replacement, and the clamp counters show bad or
extreme caller parameters that had to be made safe before mixing.

Doom music:

Music is now owned by isolated Doom port code instead of kernel assembly or the
vendor Doom tree. `doom_port/music.c` detects MUS and Standard MIDI bytes,
parses their event streams, tracks channel volume and active notes, schedules
MUS/MIDI delays, and renders deterministic unsigned 8-bit PCM with a small
integer square-wave synth. The renderer is deliberately freestanding: it does
not call host MIDI, audio, math, or operating-system libraries.

`I_RegisterSong` stores the cached WAD lump pointer, `I_PlaySong` renders a
65536-byte PCM window at 11025 Hz, and the platform layer submits that PCM
through `SYS_AUDIO` using `VIBE_AUDIO_START_SFX` with a separated music handle
range. This is a bridge into the existing SB16 path, not a second mixer. The
music architecture should keep targeting the same SB16 DMA/refill output path
so the parser/renderer work can share SFX clipping, silence, and status
accounting. The kernel can later grow a first-class streaming music command
without changing the MUS/MIDI parser or Doom's original sources. See
`docs/doom-music.md` for the full pipeline and fallback design.

Remaining gaps:

- Music currently renders bounded PCM windows instead of a pull-based realtime
  stream, so long-term looping should move into a dedicated kernel music command
  or a refilled user/kernel PCM queue.
- IRQ refill still needs real playback validation under VM smoke and click-free
  voice ramping for steals/stops.
- Music and SFX now share the SB16 carrier path, but the final mixer still needs
  explicit music status counters and balancing once the kernel owns streaming.
- Local `make test` stays host-only and does not launch QEMU; VM smoke remains
  behind the explicit repo-owned `ALLOW_LOCAL_VM=1` opt-in.

Fallback plan:

If SB16 probing fails, keep `audio=NONE` and preserve the syscall counters. A
PC speaker fallback can later consume the parsed music schedule by selecting one
melody voice and converting its MIDI note to a PIT divisor. That proves timing
and audible music on minimal hardware without duplicating the SB16 SFX mixer.
