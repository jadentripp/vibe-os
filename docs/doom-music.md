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

Asset provenance:

MUS/MIDI song lumps from the selected WAD are the only Doom music asset source.
The repo does not ship Doom songs, sound effects, WAD bytes, rendered music, or
other prebuilt Doom audio assets. The proof surface records parser/mixer status
and aggregate output health only; it does not upload MUS, MIDI, SFX, PCM, or WAV
payloads.

Integration:

The Doom platform hooks in `doom_port/platform.c` now register song lump
pointers through `vibe_music_register_song`, start a stateful stream cursor with
`vibe_music_stream_begin`, render streamed music chunks with
`vibe_music_stream_render`, and submit those chunks to the existing `SYS_AUDIO`
path. `I_PlaySong` only starts the stream cursor; the first chunk render is
deferred to the normal tic/frame/sound update pump so startup cannot block
inside the synthesizer before Doom reaches gameplay status. The first chunk uses
`VIBE_AUDIO_START_SFX`; subsequent chunks use `VIBE_AUDIO_UPDATE_SFX` so the
kernel refreshes the music voice's sample window without changing Doom's
original sources. The temporary music handle space is separated with
`VIBE_MUSIC_AUDIO_HANDLE_BASE`, so the kernel can distinguish music voices from
normal Doom SFX handles. The descriptor also marks the voice with
`VIBE_AUDIO_FLAG_MUSIC`.
Runtime music volume changes call `vibe_music_stream_set_volume`, so future
chunks honor Doom's current music volume without resetting the song position.
The platform hook now polls `VIBE_AUDIO_MUSIC_PULL_STATE` before rendering a new
chunk after the initial music start. The kernel keeps the currently mixed window
plus one pending music window, promotes the pending window from the SB16 IRQ
refill path when the current one drains, and raises the next pull request from
that same refill path when the active plus pending window falls below the stream
low-water mark. That turns normal early refreshes into hardware-paced request
service instead of `musicdrops=` while still making true pending-slot overwrites
visible.
For looping songs, the stream now measures one parsed song pass and wraps only
the renderer's internal start point to that loop length while keeping the public
stream position cumulative. That long-playback wrap keeps chunk rendering from
falling off the old bounded loop-pass limit after many minutes of looping music.
For non-looping songs, the stream now also measures the parsed song length and
stops at the parsed song end instead of emitting endless silence chunks. That
keeps intermission or one-shot music honest in the port layer and gives the
platform hook a clean zero-render signal to stop the SB16 music voice.

This is a meaningful step past the old single bounded PCM carrier and the old
Doom-tick-pushed chunks. The current port still renders 32768-byte chunks at
11025 Hz from the current song position, but it now does so to answer
SB16-refill-side pull requests instead of deciding from a port-owned buffered
byte poll. In other words, the visible proof follows a hardware-paced pull request
from the SB16 refill path. The kernel still treats music as an SB16 active voice, so music and
sound effects mix in the IRQ refill path instead of competing for a separate
backend. Smoke status exposes `musicvoices=`, `musicmix=`, `musicpos=`,
`musicbuf=`, `musicunder=`, `musicdrops=`, and the third `voiceq=` component so
this continuity is testable and separate from normal Doom SFX. It also exposes
`VIBE_AUDIO_MUSIC_PULL_STATE`, `musicstream=PULL`, and
`musicpull=<requests>:<refills>` to make the current request/service contract
explicit. This is hardware-paced pull service, not a claim that the kernel owns
MUS/MIDI parsing or synthesis. `sfxmix=` counts only non-music sound effects,
while music increments `musicmix=`.

The remote-safe audio checker now proves that the SB16 path mixed non-music SFX,
mixed music, accepted streamed music chunk updates, and advanced kernel-visible
`musicpos=` across status snapshots. It also rejects incoherent lane accounting:
`voices=` must match `sfxvoices=` plus `musicvoices=`, `sfxmix=` must prove SFX
lane progress, the music lane must be active in at least one snapshot, and at
least one music snapshot must show a buffered stream window. It now also
requires more than one stream update and changing `musicbuf=` values so the
proof includes stream-health movement instead of a static carrier. The gate also
requires the scripted fire phase to advance Doom sound calls and non-music SFX
mixing, so music-only or carrier-only output cannot stand in for firing the
shotgun in the play proof. It also requires no new `mixclip=`, `musicunder=`, or
`musicdrops=` deltas during the scripted proof. For PULL mode it requires
advancing `musicpull=` request and refill counters, with the refill count never
exceeding requests, plus `voiceq=` update-service evidence for the chunks the
port rendered. The checker treats this lane as separate from normal Doom SFX
even if the final snapshot lands after the active music voice drained.
A later kernel milestone can replace `VIBE_AUDIO_UPDATE_SFX` service chunks with
a dedicated kernel-owned music ring or in-kernel renderer, but it should keep
the same request/refill proof shape.

Long-running music streaming contract:

The long-running music streaming contract now has status-visible kernel
request/refill accounting plus a host-proved long-playback wrap in the port
renderer. The song-position cursor is explicit proof data: it lets host checks
distinguish a hardware-paced pull request and real position advance from a
static stream window. The open legitimacy step is kernel-owned rendering or a
first-class music ring, not the request timing itself.

To fully close the music gap, the kernel should own more of the stream payload
path instead of using `VIBE_AUDIO_UPDATE_SFX` as the service command. The proof
should remain status-only and copyright-safe:

- `musicstream=PULL` only when the active music path is paced by SB16 refill
  requests rather than by Doom's own buffer polling.
- `musicpull=<requests>:<refills>` increasing in the pull/refill model, so host
  checks can reject a pull-stream claim that never requested or never serviced
  hardware-paced chunks.
- `musicpos=` increasing across early/fire/move/use/menu/final snapshots,
  proving the kernel refill path consumed music beyond the first rendered
  window.
- `musicbuf=`, `musicunder=`, and `musicdrops=` expose stream-window health
  without uploading PCM.
- `musicloop=` increasing only when the parsed song loops, not when a short
  sample window wraps.
- `tools/check_audio_continuity_proof.py` compares these fields across the same
  real-WAD snapshots and rejects a static stream window. Its
  `--require-pull-stream` mode rejects `musicstream=PUSH` and requires
  `musicstream=PULL` plus advancing `musicpull=` counters before any doc calls
  the current audio path hardware-paced.

That contract preserves the current parser/renderer work: the port can keep
parsing original Doom MUS/MIDI lumps outside `third_party/doom`, while the next
legitimacy step moves from request-serviced `UPDATE_SFX` chunks toward a
dedicated music stream ABI or kernel-owned renderer.

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
