# Audio Path

The first real Doom audio target is an ISA Sound Blaster 16 compatible device at
base port `0x220`. This is the practical hobby-OS target because QEMU exposes an
SB16 model and the device has a simple DSP reset/version probe before the harder
mixing work. In the hardware matrix, this is claimed only as the QEMU SB16
device-model path until a separate physical audio proof exists.

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
- accepts Doom SFX descriptors from the platform layer and reports real,
  non-music Doom SFX mixing as `sfxmix=<hex count>`
- reports non-music SFX queue and asset-source proof as `sfxq=`,
  `sfxbytes=`, `sfxdma=`, `sfxsrc=`, and `sfxlast=`, so the cloud gate can
  distinguish runtime WAD `DS*` SFX submits and SB16 DMA-refill output bytes
  from generic audio calls
- keeps a fixed eight-slot active voice table keyed by Doom sound handle, with
  sample pointer, length, fixed-point current position, volume, separation,
  pitch, panned left/right gains, pitch step, start order, and explicit voice
  flags
- handles `START_SFX`, `STOP_SFX`, and `UPDATE_SFX` by registering, clearing, or
  retuning active voices before the next DMA half-buffer refill
- answers Doom's `I_SoundIsPlaying` through `VIBE_AUDIO_IS_PLAYING` by checking
  the same active voice table used by the IRQ mixer
- steals the oldest non-music active voice when all eight slots are full, falling
  back to the oldest music voice only if every slot is music, so new SFX stay
  bounded without usually cutting the music bed
- reports audio init, playback, voice queue, IRQ, and mixer ring health in smoke status:
  `sb16=`, `dma=`, `play=`, `voiceq=`, `sfxq=`, `sfxbytes=`, `sfxdma=`,
  `sfxsrc=`, `sfxlast=`, `musicq=`, `voices=`, `sfxvoices=`, `audioirq=`,
  `ack8=`, `ack16=`, `refill=`, `half=`, `mixwrap=`, `mixover=`,
  `mixunder=`, `mixclip=`, `steal=`, `pitchclamp=`, and `panclamp=`
- reports music-carrier and stream-window health separately as `musicvoices=`,
  `musicmix=`, `musicloop=`, `musicpos=`, `musicbuf=`, `musicunder=`,
  `musicdrops=`, `musicstream=`, `musicpull=`, and `musicrend=`
- records music renderer provenance as
  `musicrend=<format>:<chunks>:<notes>:<events>:<peak>:<samples>`, where
  format is the port-owned MUS or MIDI renderer and the counters prove the
  submitted music stream came from parsed song events, not a raw carrier tone
- exposes `VIBE_AUDIO_MUSIC_PULL_STATE` so Doom-port music service and SB16
  refill-side pull requests have an explicit source-level contract; the older
  `VIBE_AUDIO_BUFFERED_BYTES` query remains defined for diagnostic buffer
  inspection, but the music proof follows pull request/refill state
- records the current request-driven music stream as `musicstream=PULL`, with
  `musicpull=<requests>:<refills>` advanced by SB16 refill-side low-water
  requests and by Doom-port chunk service
- keeps the older `musicstream=PUSH` proof label documented only as the prior
  push-fed chunk mode; current hardware-paced music claims require PULL plus
  advancing `musicpull=` counters
- keeps one queued pending music window per active music voice, so an early
  `VIBE_AUDIO_UPDATE_SFX` can be promoted by the IRQ refill path when the current
  music window drains instead of replacing it or forcing a dry carrier

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
separation, pitch, Doom sound id, flags, and source sample rate. Normal SFX are
tagged with `VIBE_AUDIO_FLAG_WAD_SFX` after the platform validates the Doom
sound header and pads the sample data with unsigned silence to the original
Linux Doom mixer quantum. The music bridge submits `VIBE_AUDIO_FLAG_MUSIC`;
looping is now handled by the port-owned song cursor instead of by looping a
short kernel sample window.
Doom audio assets come from WAD lumps selected at runtime. The repo does not
ship Doom SFX, MUS, MIDI, WAD bytes, or pre-rendered audio assets for this
proof lane; `ds*` SFX lumps and MUS/MIDI song lumps are loaded from the caller's
real WAD, then reduced to status counters and aggregate proof metadata.

The kernel validates the descriptor and sample range against the current Doom
process memory map, then registers the sound in the active voice table. Each
SB16 IRQ toggles the tracked half-buffer, clears that half to unsigned silence,
and mixes every active voice into interleaved unsigned 8-bit stereo bytes. Each
source sample is centered around `0x80`, scaled by the voice's panned gain,
added to the existing left or right DMA byte, clipped back to unsigned 8-bit
PCM, and written into the kernel-owned SB16 DMA ring.

`sfxmix=` counts only normal Doom SFX voices. In plain contract terms,
sfxmix= counts non-music Doom SFX only. Music voices use the same SB16 refill
mixer but increment `musicmix=` instead, and `sfxvoices=` exposes the current
non-music voice count separately from total `voices=` and `musicvoices=`. This
keeps the proof honest: streamed music chunks can no longer make the SFX lane
look alive by themselves.

`sfxq=<starts>:<stops>:<updates>:<finished>` counts only non-music Doom SFX
voices, `sfxbytes=<submitted>:<output>` compares WAD-sourced PCM submitted by
the platform with bytes mixed into SB16 half-buffer refills, and
`sfxdma=<mixes>:<bytes>` is incremented only by the IRQ-driven SB16
half-buffer refill mixer when non-music SFX contribute bytes to the
kernel-owned DMA ring. `sfxsrc=` counts runtime WAD `DS*` sound submits, and
`sfxlast=<id>:<rate>:<length>` records the latest non-music Doom SFX id, source
sample rate, and padded sample length. The status-only cloud proof requires
these to progress during scripted fire input, so a music-only, generic beep, or
submit-only path cannot satisfy the SFX gate.

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
step for the existing handle. For music handles it can also replace the active
sample pointer and length when the current window has already drained, or queue
one pending streamed music chunk when the current window is still playing. The
refill path promotes that pending window exactly at the source boundary and
continues mixing without retiring the music voice. Doom's port layer now queries
`VIBE_AUDIO_MUSIC_PULL_STATE` instead of using its own buffered-byte low-water
policy. The kernel raises a hardware-paced pull request from the SB16 IRQ refill
path when the active plus pending music buffer falls below the three-quarter
stream-window low-water mark, and the port renders exactly the next bounded
chunk to service that request. The port still owns MUS/MIDI parsing and PCM
rendering; this is a pull-request audio stream, not kernel-owned MIDI synthesis.
Refill advances
each voice's 16.16 source position,
supports repeated source samples for low pitch and skipped source samples for
high pitch, and retires non-looping voices that reach the end of their sample.
Loop-flagged voices still wrap their source position back to zero for fallback
or non-streamed callers, but Doom music now advances by request-serviced chunks
rather than by looping one bounded carrier.
Doom's `I_SoundIsPlaying` now calls back into the audio syscall and returns true
only while that handle is still active in the mixer voice table.

The kernel now exposes a stream-visible music contract. `musicpos=` is the
cumulative music source bytes consumed by the IRQ refill mixer, `musicbuf=` is
the active plus pending music window remaining in the voice table, `musicunder=`
counts music voices that ran dry with no pending replacement, and `musicdrops=`
counts invalid music updates or updates that arrive while the single pending
slot is already occupied. `musicstream=PULL` names the current mode, while
`musicpull=` records `<requests>:<refills>` so the proof checker can reject a
claimed pull stream that never received SB16-refill requests or never served
them. Normal early music refreshes are queued rather than counted as drops.
These fields let the proof checker distinguish a progressing kernel-mixed,
request-driven stream from a single queued music sample without claiming
kernel-owned music synthesis.
The checker now treats `musicbuf=` as stream-health evidence: across the
scripted snapshots it must move, and the stream-update counter must advance more
than once, so a single static music carrier cannot satisfy the audio proof.
It also requires `musicrend=` renderer provenance to show MUS/MIDI format,
rendered chunks, note events, total render events, active renderer voice peak,
and emitted samples; a music flag plus carrier PCM cannot satisfy that lane.
The same gate now also rejects audio proofs with new `mixclip=`, `musicunder=`,
or `musicdrops=` deltas across the scripted window, and requires IRQ/refill
movement across the phase snapshots plus Doom sound-call/SFX-mix progress by the
fire phase. In other words, the status-only proof must show SB16 DMA continuity,
real Doom SFX activity, streamed music updates, and no new mixclip=,
musicunder=, or musicdrops= safety regressions.
Contract phrase for the checker: no new mixclip=, musicunder=, or musicdrops=.

Mixer safety is smoke-visible. `mixclip` counts left/right output clipping,
`mixunder` counts invalid/empty SFX or active refills with no voices, `steal`
counts bounded voice replacement, and the clamp counters show bad or extreme
caller parameters that had to be made safe before mixing.

Remote-safe continuity proof:

`tools/check_audio_continuity_proof.py` consumes only decoded status snapshots:
`status.after-start.txt`, `status.after-fire.txt`, `status.after-move.txt`,
`status.after-use.txt`, `status.after-menu.txt`, and `status.txt`. It requires
`audio=SB16` in every snapshot, a nonzero `sb16=` DSP version, nonzero `dma=`
programming and `play=` start counters, nonzero `voiceq=` and `musicq=` queue
counters, nonzero `sfxq=`, `sfxbytes=`, `sfxdma=`, `sfxsrc=`, and `sfxlast=`
SFX-source proof, monotonic audio counters, increasing IRQ/refill, non-music SFX
`sfxmix=`, SB16-refill-side SFX `sfxdma=`, runtime WAD SFX source `sfxsrc=`,
music `musicmix=` counters,
increasing `musicpos=`, a progressing `voiceq=` stream-update component,
visible `musicbuf=` / `musicunder=` / `musicdrops=` health fields,
`musicstream=PULL` for the current
SB16-refill-requested music proof, monotonic and advancing `musicpull=` counters
and `musicrend=` renderer-provenance counters,
for hardware-paced request/service evidence, coherent lane accounting where
`voices=` equals `sfxvoices=` plus
`musicvoices=`, at least one active music voice snapshot, at least one buffered
music-window snapshot, and nonzero SB16 ACK accounting. SFX
lane proof is cumulative: `sfxmix=` must progress even if every captured
snapshot lands after the short SFX voice has drained, and `sfxbytes=` plus
`sfxdma=` must show both submitted PCM and IRQ-refill DMA output byte progress.
That proves the emulated SB16 guest path was initialized, DMA-programmed,
started, queued, and continued to refill and mix both Doom SFX and streamed
music chunks across time without uploading proprietary WAD data, PCM samples, or
rendered pixels. A run with
`audio=NONE` is still useful diagnostics, but it is not an audible/streaming
audio proof.

Human-audible remote proof:

The next proof lane is `tools/check_audible_audio_proof.py`. The real-WAD
workflow has an opt-in `audible_audio_proof` input that swaps the disposable
runner from QEMU's null backend to the QEMU WAV backend:
`-audiodev wav,id=snd0,path=build/doom-audio.wav -device sb16,audiodev=snd0`.
That makes QEMU write the host-side output it would have sent to a speaker. The
workflow then analyzes the temporary WAV on the runner, writes only
`build/audio-proof.json`, validates that manifest, and must delete the temporary WAV
with `rm -f build/doom-audio.wav` before artifact upload.
VNC does not carry audio by default. The quick cloud play path is therefore a
visual/input path plus status proof; audible proof comes from aggregate cloud
output/status in `audio-proof.json`, not from the VNC session itself. The rule
is simple: raw audio must not be uploaded, and the manifest now records that the
temporary WAV is runner-local and deleted before artifact upload.

The aggregate JSON manifest is intentionally aggregate-only: sample format, duration,
active-window counts, RMS/peak summaries, zero-crossing count, listener-quality metadata,
stream-health summary, the matching final `audio=SB16` / SB16 version
/ DMA / playback / voice queue / IRQ / refill / non-music SFX / music status
counters, WAD-lump asset provenance, and a status-only SB16 continuity summary
from the same phase
snapshots. The audible checker refuses to write or
validate the manifest if only the music path progresses while `sfxmix=` stays
flat or while `sfxdma=` fails to advance through the IRQ refill path, and its
continuity summary now records separate `mix_lanes` deltas for non-music SFX,
music, stream updates, music position, and shared SB16 IRQ/refill progress plus
a `stream_health` object with buffer floor/peak/final values, under/drop deltas,
and position-per-update metadata. It also records
`stream_contract` metadata that records `musicstream=PULL`, `mixer_safety`
thresholds for clip-free, underrun-free, and
drop-free playback, plus a scripted fire-phase proof so a manifest cannot pass
on carrier or music activity alone.
The listener-quality metadata is still aggregate only: active span,
leading/trailing inactive windows, clipping ratio, crest factor, zero-crossing
rate, machine-audible thresholds, and an explicit note that subjective human
listener approval is still absent. It does not store samples, hashes, PCM bytes,
WAD bytes, pixels, or a waveform. The artifact
checker rejects raw audio files such as `*.wav`, `*.mp3`, `*.ogg`, and `*.flac`,
but accepts `audio-proof.json` when the manifest passes the checker. This proves
that a remote QEMU audio backend received non-silent output from the guest
without publishing copyrighted audio. It still does not claim subjective human
listener approval or kernel-owned hardware-paced music streaming.

Doom music:

Music is now owned by isolated Doom port code instead of kernel assembly or the
vendor Doom tree. `doom_port/music.c` detects MUS and Standard MIDI bytes,
parses their event streams, tracks channel volume/expression/pan/program,
sustain, pitch bend, percussion mapping, active notes, and peak voice use,
schedules MUS/MIDI delays, and renders deterministic unsigned 8-bit PCM with a
small integer square/noise synth. The renderer is deliberately freestanding: it
does not call host MIDI, audio, math, or operating-system libraries.

`I_RegisterSong` stores the cached WAD lump pointer, and `I_PlaySong` now starts
a port-owned stateful stream cursor instead of rendering one permanent carrier.
The platform layer renders 32768-byte streamed music chunks from the current
song position and submits the first chunk through `VIBE_AUDIO_START_SFX`; later
Doom sound, tic, and frame hooks poll `VIBE_AUDIO_MUSIC_PULL_STATE` and call
`VIBE_AUDIO_UPDATE_SFX` only when the kernel has raised a hardware-paced pull
request from the SB16 refill path. The music architecture keeps targeting the same SB16
DMA/refill output path, so the parser/renderer work shares SFX voice stealing,
clipping, silence, and status accounting. The extra `musicvoices=`, `musicmix=`,
`musicpos=`, `musicbuf=`, `musicunder=`, `musicdrops=`, `musicstream=`,
`musicpull=`, `musicrend=`, and `voiceq=` update counter make that contract visible in cloud
smoke status.
`musicstream=PULL` and advancing `musicpull=` counters make the current
request-driven status explicit; `tools/check_audio_continuity_proof.py
--require-pull-stream` is the host-only contract that rejects stale pushed-only
proofs. This still does not mean the kernel parses MUS/MIDI itself.
Runtime music volume updates feed `vibe_music_stream_set_volume`, so new chunks
use Doom's latest music volume without restarting the song cursor.
Looping songs measure one parsed song pass and wrap only the renderer's
internal start point, keeping the public stream cursor cumulative for long
playback while avoiding the old bounded loop-pass failure.
The kernel can later grow a first-class pull/refill command without changing the
MUS/MIDI parser or Doom's original sources. See `docs/doom-music.md` for the
full pipeline and fallback design.

Remaining gaps:

- Music now advances a stateful song-position cursor in the Doom port and
  services kernel pull requests with `VIBE_AUDIO_UPDATE_SFX`. The SB16 IRQ
  refill path owns request timing and `musicpull=` accounting, but the Doom port
  still renders the MUS/MIDI chunk in response. The `musicrend=` counters now
  prove those service chunks came from parsed MUS/MIDI renderer activity rather
  than a carrier tone; kernel-owned synthesis remains a future legitimacy step.
- The audible proof is a remote aggregate-output proof, not a listener recording
  or subjective quality proof. It now records aggregate listener-quality
  metadata, but a human playtest should still use remote audio forwarding for
  listening notes without uploading captured Doom audio.
- IRQ refill still needs real playback validation under VM smoke and click-free
  voice ramping for steals/stops.
- Music and SFX now share the SB16 mixer, but the final mixer still needs better
  balancing once the kernel owns a real pull stream.
- Local `make test` stays host-only and does not launch QEMU; VM smoke remains
  behind the explicit repo-owned `ALLOW_LOCAL_VM=1` opt-in.

The cloud-safe continuity gate is `tools/check_audio_continuity_proof.py`. It
checks status snapshots only: `audio=SB16`, `sb16=`, `dma=`, `play=`,
`voiceq=`, `musicq=`, IRQ/refill progress, non-music SFX mixing, streamed music
chunks, music mixer counters, changing `musicbuf=` stream-health windows,
`musicpos=` stream position, `musicstream=PULL`, and advancing `musicpull=`
request/refill plus `musicrend=` renderer counters must move across the
scripted cloud phases. Passing
`--require-pull-stream` keeps that contract explicit.

Fallback plan:

If SB16 probing fails, keep `audio=NONE` and preserve the syscall counters. A
PC speaker fallback can later consume the parsed music schedule by selecting one
melody voice and converting its MIDI note to a PIT divisor. That proves timing
and audible music on minimal hardware without duplicating the SB16 SFX mixer.
