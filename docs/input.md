# Doom Input Contract

The original Doom tree stays unmodified. The OS-facing port drains kernel input
syscalls in `doom_port/platform.c`, translates them through `doom_port/input.c`,
and posts normal Doom `event_t` values.

Keyboard:

- `SYS_POLL_KEY` returns one packed event at a time.
- Bit `0x00010000` marks a valid event.
- Bit `0x00000100` marks press versus release.
- Bits `0..7` already contain Doom's key code, matching `doomdef.h`.
- The kernel maps Set 1 make/break scancodes for arrows, Enter, Escape, Space,
  Ctrl, Alt, Shift, Tab, number keys, letters, Backspace, minus/equal, and F1-F12.
- Extended `0xe0` scancodes cover arrows, keypad Enter, right Ctrl/Alt, and Delete
  as Doom Backspace.

Mouse:

- `SYS_POLL_MOUSE` returns one packed PS/2 packet event at a time.
- Bit `0x01000000` marks a valid event.
- Bits `0..2` carry PS/2 button state, byte 1 carries signed X delta, and byte 2
  carries signed Y delta.
- The port maps PS/2 left/right/middle order into Doom's left/middle/right button
  order, then applies a small 4x relative-motion scale before posting `ev_mouse`.
- Smoke status also exposes `mousebtn=` and `mousedelta=`. Those fields are
  updated when the Doom user process consumes `SYS_POLL_MOUSE`, so the proof
  distinguishes a real left-click/movement packet from an empty IRQ counter.

Host tests prove the translation without QEMU or WAD data:

- `tests/host/test_doom_input_contract.py` compiles and runs
  `tests/host/doom_input_test.c` against `doom_port/input.c`.
- The same test also checks that the kernel scancode map still covers the Doom
  play keys and extended press/release path.
- The real-WAD cloud workflow injects one deterministic mouse phase with QEMU
  monitor `mouse_move`/`mouse_button`, captures `status.after-mouse.txt`, and
  requires IRQ12, packet, Doom poll counters, `mousebtn`, and `mousedelta` to
  advance.
