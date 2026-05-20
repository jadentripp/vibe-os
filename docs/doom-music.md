# Doom Music Path

This repo now has a self-contained Doom music path in `doom_port/music.c` and
`doom_port/music.h`. It is intentionally port-owned code, not a change to the
pristine `third_party/doom` tree.

Current behavior:

- detects Doom MUS lumps by the `MUS\x1a` header and Standard MIDI files by the
  `MThd` header
- includes a MUS parser for score events from WAD lump bytes, including note on,
  note off, MUS-to-MIDI channel mapping for percussion, pitch bend, system
  events, program changes, pan, expression, sustain, all-notes-off handling,
  score end, and MUS variable-length delays
- parses Standard MIDI format 0 tracks, including running status, note on,
  note off, controller volume, pan, expression, sustain, pitch bend, program
  changes, tempo meta events, SysEx skip, and end-of-track
- maintains 16 channels of volume, expression, pan, program, sustain, and pitch
  bend state plus a bounded 16-voice active-note table so music scheduling is
  separate from the SB16 SFX active-voice mixer
- synthesizes deterministic unsigned 8-bit PCM with a simple square/noise,
  OPL-inspired voice model backed by an integer MIDI note frequency table;
  program changes alter duty color and percussion notes use deterministic
  channel-local noise rather than a silent placeholder
- uses only freestanding integer code and does not call host audio, MIDI, math,
  or operating-system libraries

Integration:

The Doom platform hooks in `doom_port/platform.c` now register song lump
pointers through `vibe_music_register_song`, start a stateful stream cursor with
`vibe_music_stream_begin`, render streamed music chunks with
`vibe_music_stream_render`, and submit those chunks to the existing `SYS_AUDIO`
path. The first chunk uses `VIBE_AUDIO_START_SFX`; subsequent chunks use
`VIBE_AUDIO_UPDATE_SFX` so the kernel refreshes the music voice's sample window
without changing Doom's original sources. The temporary music handle space is
separated with `VIBE_MUSIC_AUDIO_HANDLE_BASE`, so the kernel can distinguish
music voices from normal Doom SFX handles. The descriptor also marks the voice
with `VIBE_AUDIO_FLAG_MUSIC`.
Runtime music volume changes call `vibe_music_stream_set_volume`, so future
chunks honor Doom's current music volume without resetting the song position.
The platform hook now polls `VIBE_AUDIO_BUFFERED_BYTES` before rendering a new
chunk. The kernel keeps the currently mixed window plus one pending music window,
then promotes the pending window from the SB16 IRQ refill path when the current
one drains. That turns normal early refreshes into buffered continuity instead
of `musicdrops=` while still making true pending-slot overwrites visible.
For looping songs, the stream now measures one parsed song pass and wraps only
the renderer's internal start point to that loop length while keeping the public
stream position cumulative. That long-playback wrap keeps chunk rendering from
falling off the old bounded loop-pass limit after many minutes of looping music.
For non-looping songs, the stream now also measures the parsed song length and
stops at the parsed song end instead of emitting endless silence chunks. That
keeps intermission or one-shot music honest in the port layer and gives the
platform hook a clean zero-render signal to stop the SB16 music voice.

This is a meaningful step past the old single bounded PCM carrier, but it is
not final hardware-paced pull streaming yet. The current port renders
32768-byte chunks at 11025 Hz from the current song position and schedules the
next chunk from Doom's regular sound hooks once the kernel buffer reaches a
low-water mark. The kernel still treats music as an SB16 active
voice, so music and sound effects mix in the IRQ refill path instead of
competing for a separate backend. Smoke status exposes `musicvoices=`,
`musicmix=`, `musicpos=`, `musicbuf=`, `musicunder=`, `musicdrops=`, and the
third `voiceq=` component so this continuity is testable and separate from
normal Doom SFX. `sfxmix=` counts only non-music sound effects, while music
increments `musicmix=`.

The remote-safe audio checker now proves that the SB16 path mixed non-music SFX,
mixed music, accepted streamed music chunk updates, and advanced kernel-visible
`musicpos=` across status snapshots. It also rejects incoherent lane accounting:
`voices=` must match `sfxvoices=` plus `musicvoices=`, `sfxmix=` must prove SFX
lane progress, the music lane must be active in at least one snapshot, and at
least one music snapshot must show a buffered stream window. It now also
requires more than one stream update and changing `musicbuf=` values so the
proof includes stream-health movement instead of a static carrier. The gate also
requires no new `mixclip=`, `musicunder=`, or `musicdrops=` deltas during the
scripted proof. That is still push-fed song-position progress, not a claim that
the kernel owns the final pull stream.
The checker treats this lane as separate from normal Doom SFX even if the final
snapshot lands after the active music voice drained.
A later kernel milestone can replace the push-style `VIBE_AUDIO_UPDATE_SFX`
refresh with a dedicated `START_MUSIC_STREAM` or pull-based ring-buffer command.

Long-running music streaming contract:

The long-running music streaming contract now has status-visible kernel
accounting plus a host-proved long-playback wrap in the port renderer, but the
final pull model is still open.

To fully close the music gap, the kernel should own hardware-paced stream
refills instead of relying on Doom's sound tick to push the next chunk. The proof
should remain status-only and copyright-safe:

- `musicstream=OK` when the active music path is a pull/refill stream rather
  than the current push-updated SB16 voice.
- `musicpos=` increasing across early/fire/move/use/menu/final snapshots,
  proving the kernel refill path consumed music beyond the first rendered
  window.
- `musicbuf=`, `musicunder=`, and `musicdrops=` expose stream-window health
  without uploading PCM.
- `musicloop=` increasing only when the parsed song loops, not when a short
  sample window wraps.
- `tools/check_audio_continuity_proof.py` compares these fields across the same
  real-WAD snapshots and rejects a static stream window. A successor gate should
  additionally require a true
  kernel pull/refill command before any doc calls music streaming complete.

That contract preserves the current parser/renderer work: the port can keep
parsing original Doom MUS/MIDI lumps outside `third_party/doom`, but rendering
must move from the current buffer-aware pushed chunks to "render the next
bounded slice from the current song position whenever the SB16 hardware path
needs more music PCM."

Fallback design:

SB16 remains the current QEMU-backed target for Doom-capable audio. A future
PC speaker fallback should not duplicate the SB16 mixer. If needed, it can consume
the same parsed music schedule at a lower layer by selecting the loudest active
melody voice, converting its MIDI note to a PIT divisor, and toggling one square
wave until SB16 is available. That would need its own support-matrix row and
proof before docs call PC speaker audio supported.

Host proof:

`tests/host/doom_music_test.c` builds the renderer directly into a host binary
and feeds it tiny MUS and MIDI fixtures. The tests verify format detection,
channel state, tempo/controller handling, pitch bend, program changes, pan,
expression, sustain, percussion channel mapping, streaming volume updates,
long-playback wrap behavior, larger streamed chunks, non-looping songs stop at their parsed song end,
looping, deterministic output, invalid input silence, and non-silent unsigned
8-bit PCM generation without launching QEMU.
