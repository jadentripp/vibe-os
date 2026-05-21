# Input Event Contract

The original Doom tree stays unmodified. PS/2 keyboard and mouse IRQs now feed a
generic kernel input queue, and the OS-facing Doom port drains that queue with
`SYS_POLL_INPUT` in `doom_port/platform.c`. `doom_port/input.c` translates typed
kernel events into normal Doom `event_t` values.

Generic ABI:

- `SYS_POLL_INPUT` writes one `vibe_input_event_t` to the user pointer supplied
  in arg0 and requires arg1 to be at least `sizeof(vibe_input_event_t)`.
- A return value of `1` means an event was copied; `0` means the queue is empty.
- Each event carries `timestamp`, `device_id`, `type`, `code`, and three signed
  value fields. The current device IDs are keyboard `1` and mouse `2`.
- Keyboard events use type `VIBE_INPUT_EVENT_KEY`, `code` as the current
  kernel key code, and `value0` as `VIBE_INPUT_KEY_PRESSED` (`1`) or
  `VIBE_INPUT_KEY_RELEASED` (`0`). The current key-code set is
  Doom-compatible because Doom is the first caller, but the queue contract is
  not Doom-specific.
- Mouse packet events use type `VIBE_INPUT_EVENT_MOUSE_PACKET`, `code` as the
  PS/2 button mask, `value0` as signed X delta, and `value1` as signed Y delta.
- Public headers pin the guest ABI as `VIBE_INPUT_EVENT_BYTES == 28` and expose
  `vibe_input_make_key_event()` plus `vibe_input_make_mouse_packet_event()` so
  future games can construct or replay typed events without depending on
  Doom's translation helpers.
- `VIBE_INPUT_MOUSE_BUTTON_LEFT`, `VIBE_INPUT_MOUSE_BUTTON_RIGHT`, and
  `VIBE_INPUT_MOUSE_BUTTON_MIDDLE` name the raw PS/2 button bits. Game-specific
  button remapping belongs in the consuming port, not in the kernel queue.

Keyboard:

- `SYS_POLL_KEY` remains as the legacy packed-key drain for compatibility.
- Bit `0x00010000` marks a valid event.
- Bit `0x00000100` marks press versus release.
- Bits `0..7` already contain Doom's key code, matching `doomdef.h`.
- The kernel maps Set 1 make/break scancodes for arrows, Enter, Escape, Space,
  Ctrl, Alt, Shift, Tab, number keys, letters, Backspace, minus/equal, and F1-F12.
- Extended `0xe0` scancodes cover arrows, keypad Enter, right Ctrl/Alt, and Delete
  as Doom Backspace.
- Smoke status exposes `keyseen=` as a cumulative bitmask updated only when the
  Doom user process consumes generic key events. The real-WAD proof requires the
  scripted Up/Ctrl/Space/Escape bits, so a random IRQ counter cannot satisfy
  the keyboard lane. `keylast=` keeps the last packed key event for triage.

Mouse:

- `SYS_POLL_MOUSE` remains as the legacy packed-mouse drain for compatibility.
- Bit `0x01000000` marks a valid event.
- Bits `0..2` carry PS/2 button state, byte 1 carries signed X delta, and byte 2
  carries signed Y delta.
- The port maps PS/2 left/right/middle order into Doom's left/middle/right button
  order, then applies a small 4x relative-motion scale before posting `ev_mouse`.
- Smoke status also exposes `mousebtn=` and `mousedelta=`. Those fields are
  updated when the Doom user process consumes generic mouse events, so the proof
  distinguishes a real left-click/movement packet from an empty IRQ counter.
- `inputqueue=`, `inputpoll=`, and `inputlast=` expose the generic queue path:
  total generic events enqueued, Doom-consumed generic events, and the last
  consumed event's timestamp/device/type tuple.

Host tests prove the translation without QEMU or WAD data:

- `tests/host/test_doom_input_contract.py` compiles and runs
  `tests/host/doom_input_test.c` against `doom_port/input.c`.
- The same test also checks that the kernel scancode map still covers the Doom
  play keys and extended press/release path.
- The real-WAD cloud workflow injects deterministic keyboard phases and one
  mouse phase with QEMU monitor input, captures each status snapshot, and
  requires Doom-poll counters plus `keyseen`, `mousebtn`, and `mousedelta`
  proof fields to advance.
