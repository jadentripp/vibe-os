# PS/2 Mouse Input

The kernel initializes the PS/2 auxiliary device during boot. If the controller
and mouse acknowledge setup, `mouse=OK` appears in the RAM smoke status;
otherwise the status remains observable as `mouse=NONE`.

Runtime flow:

- IRQ12 reads bytes from the PS/2 data port.
- The decoder resynchronizes on packet byte 0 bit 3, rejects overflow packets,
  and packs valid 3-byte packets as buttons plus signed X/Y deltas.
- `SYS_POLL_MOUSE` returns one packed event at a time from a bounded queue.
- `doom_port/platform.c` drains that syscall in `I_StartTic` and posts Doom
  `ev_mouse` events without modifying `third_party/doom`.

Smoke counters:

- `mouseirq=` counts IRQ12 entries during the current Doom run.
- `mousepkt=` counts decoded non-overflow 3-byte packets.
- `mousepoll=` counts mouse events consumed by the Doom user process.

The bridge currently exposes relative movement and the first three PS/2 buttons.
It does not yet provide host-side smoke injection for mouse movement, cursor
grabbing policy, wheel packets, or acceleration tuning beyond Doom's own
`mouse_sensitivity`.
