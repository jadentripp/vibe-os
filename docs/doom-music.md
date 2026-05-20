# Doom Music Path

This repo now has a self-contained Doom music path in `doom_port/music.c` and
`doom_port/music.h`. It is intentionally port-owned code, not a change to the
pristine `third_party/doom` tree.

Current behavior:

- detects Doom MUS lumps by the `MUS\x1a` header and Standard MIDI files by the
  `MThd` header
- includes a MUS parser for score events from WAD lump bytes, including note on, note off,
  pitch wheel skip, system events, controller changes, score end, and MUS
  variable-length delays
- parses Standard MIDI format 0 tracks, including running status, note on,
  note off, controller volume, tempo meta events, SysEx skip, and end-of-track
- maintains 16 channels of volume state and a bounded 16-voice active-note
  table so music scheduling is separate from the SB16 SFX active-voice mixer
- synthesizes deterministic unsigned 8-bit PCM with a simple square-wave,
  OPL-inspired voice model backed by an integer MIDI note frequency table
- uses only freestanding integer code and does not call host audio, MIDI, math,
  or operating-system libraries

Integration:

The Doom platform hooks in `doom_port/platform.c` now register song lump
pointers through `vibe_music_register_song`, render a bounded PCM window with
`vibe_music_render_song`, and submit that PCM to the existing `SYS_AUDIO` path
using `VIBE_AUDIO_START_SFX`. The temporary music handle space is separated with
`VIBE_MUSIC_AUDIO_HANDLE_BASE`, so the kernel can distinguish music-carrier
voices from normal Doom SFX handles if the SB16 mixer grows first-class music
commands later.

This is not final realtime music streaming yet. The current port renders a
65536-byte PCM window at 11025 Hz and, for looping songs, repeats the parsed song
inside that window. That gets real MUS/MIDI event data onto the same kernel audio
contract as SFX without colliding with the active SB16 IRQ refill assembly work.
A later kernel milestone can replace the carrier voice with a dedicated
`START_MUSIC_PCM` or pull-based streaming command.

Fallback design:

SB16 remains the real target for Doom-capable audio. A PC speaker fallback should
not duplicate the SB16 mixer. If needed, it can consume the same parsed music
schedule at a lower layer by selecting the loudest active melody voice, converting
its MIDI note to a PIT divisor, and toggling one square wave until SB16 is
available. That would prove music timing on machines without SB16 while keeping
polyphonic PCM and SFX mixing in the SB16 path.

Host proof:

`tests/host/doom_music_test.c` builds the renderer directly into a host binary
and feeds it tiny MUS and MIDI fixtures. The tests verify format detection,
channel state, tempo/controller handling, looping, deterministic output, invalid
input silence, and non-silent unsigned 8-bit PCM generation without launching
QEMU.
