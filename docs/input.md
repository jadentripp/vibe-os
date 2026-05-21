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
- `VIBE_INPUT_EVENT_VALUE_COUNT` documents the three signed value slots in each
  event. Keyboard consumers should use `vibe_input_key_code()`,
  `vibe_input_key_is_pressed()`, and `vibe_input_key_is_released()` instead of
  reaching into `value0` directly.
- Public headers also pin `VIBE_INPUT_STATUS_BYTES == 112`. The status record
  reports the ABI version, event size, queue capacity, queued event count,
  total enqueued events, total polled events, `dropped_events`, capability bits,
  keyboard IRQ/event counts, `keyboard_down_count`, the last keyboard code, a
  `VIBE_INPUT_KEY_STATE_BITS` sized `keyboard_state` bitmap keyed by event `code`, mouse
  IRQ/packet/sync-loss counts, current `mouse_buttons`, signed cumulative mouse
  deltas, and the last generic event device/type. This status API is a proof
  and health surface; polling it must not consume input events.
- `VIBE_INPUT_MOUSE_BUTTON_LEFT`, `VIBE_INPUT_MOUSE_BUTTON_RIGHT`, and
  `VIBE_INPUT_MOUSE_BUTTON_MIDDLE` name the raw PS/2 button bits, and
  `VIBE_INPUT_MOUSE_BUTTON_MASK` names the supported bit range.
- Raw PS/2 button order is preserved in generic events and status.
  Game-specific
  button remapping belongs in the consuming port, not in the kernel queue.
- `VIBE_INPUT_MOUSE_AXIS_X` and `VIBE_INPUT_MOUSE_AXIS_Y` name the relative
  movement axes carried in mouse packet values 0 and 1.
- `vibe_input_mouse_buttons()`, `vibe_input_mouse_button_is_supported()`,
  `vibe_input_mouse_button_is_down()`, `vibe_input_mouse_delta_x()`,
  `vibe_input_mouse_delta_y()`, `vibe_input_mouse_delta()`, and
  `vibe_input_mouse_has_motion()` normalize mouse packet reads for any future
  user program. The matching status helpers
  `vibe_input_status_abi_is_current()`,
  `vibe_input_status_mouse_buttons()`,
  `vibe_input_status_mouse_button_is_down()`, and
  `vibe_input_status_mouse_delta()` plus
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
- Doom now drains input through `vibe_poll_input()` and keeps that scale in
  `VIBE_DOOM_MOUSE_RELATIVE_SCALE`; future games can consume the raw relative
  movement ABI directly or apply their own feel/acceleration layer.
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

PS/2 mouse bring-up:

- The kernel initializes the PS/2 auxiliary device during boot. If the
  controller and mouse acknowledge setup, `mouse=OK` appears in the RAM smoke
  status; otherwise the status remains observable as `mouse=NONE`.
- IRQ12 reads bytes from the PS/2 data port.
- The decoder resynchronizes on packet byte 0 bit 3, rejects overflow packets,
  and emits valid 3-byte packets as buttons plus signed X/Y deltas.
- The packet is queued both in the legacy packed mouse queue and in the generic
  input event queue as a `VIBE_INPUT_EVENT_MOUSE_PACKET` with a timestamp,
  device id, button mask, and signed deltas.
- `SYS_POLL_INPUT` copies one generic event at a time to Doom's platform layer.
- `doom_port/platform.c` drains that syscall in `I_StartTic`, uses
  `doom_port/input.c` to translate the generic mouse packet, and posts Doom
  `ev_mouse` events without modifying `third_party/doom`.

Mouse proof counters:

- `mouseirq=` counts IRQ12 entries during the current Doom run.
- `mousepkt=` counts decoded non-overflow 3-byte packets.
- `mousepoll=` counts generic mouse events consumed by the Doom user process.
- `mousebtn=` ORs together the PS/2 button bits from mouse packets Doom
  actually polled. The cloud script requires bit 0 from its left click.
- `mousedelta=` reports the absolute X/Y movement totals from mouse packets
  Doom actually polled, formatted as `XXXXXXXX:YYYYYYYY`.
- `inputqueue=`, `inputpoll=`, and `inputlast=` expose the shared input queue
  before the Doom-specific mouse proof fields.

The cloud smoke runner accepts `mouse=DX:DY` and `mousebtn=MASK` actions in
`SMOKE_INPUT_SCRIPT`. The real-WAD workflow uses those actions to capture
`status.after-mouse.txt`, and the proof checker requires `mouseirq`, `mousepkt`,
`mousepoll`, `mousebtn`, `mousedelta`, the `pflags` turn bit, and a raw
`pangle`/`pangledelta` change from the early status snapshot. This proves the
scripted mouse phase carried movement/button data all the way through
`SYS_POLL_INPUT` and into Doom gameplay state. The runtime sets the turn bit
from sampled `ticcmd.angleturn` or from the resulting player-angle delta, not
just because IRQ12 fired.

The OS does not yet provide cursor grabbing policy, wheel packets, or
acceleration tuning beyond Doom's own `mouse_sensitivity`.
