# PS/2 Mouse Input

The kernel initializes the PS/2 auxiliary device during boot. If the controller
and mouse acknowledge setup, `mouse=OK` appears in the RAM smoke status;
otherwise the status remains observable as `mouse=NONE`.

Runtime flow:

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

Smoke counters:

- `mouseirq=` counts IRQ12 entries during the current Doom run.
- `mousepkt=` counts decoded non-overflow 3-byte packets.
- `mousepoll=` counts generic mouse events consumed by the Doom user process.
- `mousebtn=` ORs together the PS/2 button bits from mouse packets Doom
  actually polled. The cloud script requires bit 0 from its left click.
- `mousedelta=` reports the absolute X/Y movement totals from mouse packets
  Doom actually polled, formatted as `XXXXXXXX:YYYYYYYY`.
- `inputqueue=`, `inputpoll=`, and `inputlast=` expose the shared input queue
  before the Doom-specific mouse proof fields.

The bridge exposes relative movement and the first three PS/2 buttons. PS/2
reports left/right/middle, while Doom's original X11 path treats buttons as
left/middle/right, so the port remaps those bits before posting the event. Raw
signed deltas are scaled by 4 to match the coarser feel of the original Linux
mouse path.

The cloud smoke runner accepts `mouse=DX:DY` and `mousebtn=MASK` actions in
`SMOKE_INPUT_SCRIPT`. The real-WAD workflow uses those actions to capture
`status.after-mouse.txt`, and the proof checker requires `mouseirq`, `mousepkt`,
`mousepoll`, `mousebtn`, `mousedelta`, the `pflags` turn bit, and a raw
`pangle`/`pangledelta` change from the early status snapshot. This proves the
scripted mouse phase carried movement/button data all the way through
`SYS_POLL_INPUT` and into Doom gameplay state. The runtime sets the turn bit
from sampled `ticcmd.angleturn` or from the resulting player-angle delta, not
just because IRQ12 fired.

It does not yet provide cursor grabbing policy, wheel packets, or acceleration
tuning beyond Doom's own `mouse_sensitivity`.
