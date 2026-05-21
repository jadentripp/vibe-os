# Clock and Time Contract

vibe-os owns a small monotonic clock service backed by the PIT timer interrupt.
The PIT is programmed for 100 Hz, so one kernel tick is 10 milliseconds.

The reusable user/kernel contract is `VIBE_SYS_CLOCK_GETTIME` with
`VIBE_CLOCK_MONOTONIC`. It fills `vibe_clock_time_t` with:

- `ticks`: raw monotonic PIT ticks since boot.
- `frequency_hz`: currently `100`.
- `milliseconds`: monotonic milliseconds since boot, derived from ticks.
- `flags`: reserved, currently zero.

This is not wall-clock time. The CMOS/RTC path is not exposed as libc time, and
no API currently claims calendar seconds, timezone, or persistence across boots.

The Doom port consumes this general clock through `vibe_monotonic_milliseconds`
and converts milliseconds to Doom's 35 Hz `I_GetTime` value in the port layer.
The legacy `VIBE_SYS_TIME` syscall still returns Doom tics for compatibility,
but new consumers should use the monotonic clock API.

Host-safe validation lives in source/contract tests:

- `tests/host/doom_libc_allocator_test.c` mocks the clock syscall and validates
  `vibe_clock_gettime`, `vibe_monotonic_ticks`, `vibe_monotonic_milliseconds`,
  and `clock_gettime(CLOCK_MONOTONIC, ...)`.
- `tests/host/test_artifacts.py` pins the kernel syscall number, PIT frequency,
  smoke-status `clockhz=` / `clockms=` fields, and Doom's use of the generic
  monotonic helper.
