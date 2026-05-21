# Input Event Contract

The original Doom tree stays unmodified. PS/2 keyboard and mouse IRQs now feed a
generic kernel input queue, and the OS-facing Doom port drains that queue with
`SYS_POLL_INPUT` in `doom_port/platform.c`. `doom_port/input.c` translates typed
kernel events into normal Doom `event_t` values.

Generic ABI:

- `SYS_POLL_INPUT` writes one `vibe_input_event_t` to the user pointer supplied
  in arg0 and requires arg1 to be at least `sizeof(vibe_input_event_t)`.
- A return value of `1` means an event was copied; `0` means the queue is empty.
- `VIBE_SYS_INPUT_STATUS` (`SYS_INPUT_STATUS` in the kernel table) writes one
  `vibe_input_status_t` to the user pointer supplied in arg0 and requires arg1
  to be at least `sizeof(vibe_input_status_t)`.
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
- Public headers also pin `VIBE_INPUT_STATUS_BYTES == 112`. The status record
  reports the ABI version, event size, queue capacity, queued event count,
  total enqueued events, total polled events, `dropped_events`, capability bits,
  keyboard IRQ/event counts, `keyboard_down_count`, the last keyboard code, a
  256-bit `keyboard_state` bitmap keyed by event `code`, mouse
  IRQ/packet/sync-loss counts, current `mouse_buttons`, signed cumulative mouse
  deltas, and the last generic event device/type. This status API is a proof
  and health surface; polling it must not consume input events.
- `VIBE_INPUT_MOUSE_BUTTON_LEFT`, `VIBE_INPUT_MOUSE_BUTTON_RIGHT`, and
  `VIBE_INPUT_MOUSE_BUTTON_MIDDLE` name the raw PS/2 button bits, and
  `VIBE_INPUT_MOUSE_BUTTON_MASK` names the supported bit range.
- Raw PS/2 button order is preserved in generic events and status.
  Game-specific
  button remapping belongs in the consuming port, not in the kernel queue.
- `vibe_input_mouse_buttons()`, `vibe_input_mouse_button_is_down()`,
  `vibe_input_mouse_delta_x()`, `vibe_input_mouse_delta_y()`, and
  `vibe_input_mouse_has_motion()` normalize mouse packet reads for any future
  user program. The matching status helpers
  `vibe_input_status_mouse_buttons()`,
  `vibe_input_status_mouse_button_is_down()`, and
  `vibe_input_status_mouse_has_motion()` expose the same raw-button and
  cumulative-motion semantics without consuming events.
- Queue overflow semantics are overwrite-oldest: when the shared input ring is
  full, the kernel advances the tail, writes the new event, and increments
  `dropped_events`. Programs that require lossless input can compare
  `total_events`, `polled_events`, `queued_events`, and `dropped_events` from
  `vibe_input_status_t`.

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
- The generic status path keeps raw PS/2 button state in `mouse_buttons`; Doom's
  button-order remap remains only in `doom_port/input.c`.
- Smoke status also exposes `mousebtn=` and `mousedelta=`. Those fields are
  updated when the Doom user process consumes generic mouse events, so the proof
  distinguishes a real left-click/movement packet from an empty IRQ counter.
- `inputqueue=`, `inputdepth=`, `inputpoll=`, and `inputlast=` expose the
  generic queue path: total generic events enqueued,
  `<currently queued>:<dropped>` backlog/drop telemetry, Doom-consumed generic
  events, and the last consumed event's timestamp/device/type tuple.
- The scripted gameplay proof copies `inputdepth` into
  `gameplay-proof.json` performance diagnostics. `os-pipeline-healthy` means
  the queue did not drop events and did not retain a backlog at the final
  snapshot. `os-input-backlog` or `os-input-loss` means slowdown triage should
  investigate the generic input queue before blaming noVNC or QEMU throughput.

Host tests prove the translation without QEMU or WAD data:

- `tests/host/test_doom_input_contract.py` compiles and runs
  `tests/host/doom_input_test.c` against `doom_port/input.c`.
- The same test also checks that the kernel scancode map still covers the Doom
  play keys and extended press/release path.
- The real-WAD cloud workflow injects deterministic keyboard phases and one
  mouse phase with QEMU monitor input, captures each status snapshot, and
  requires Doom-poll counters plus `keyseen`, `mousebtn`, and `mousedelta`
  proof fields to advance.
