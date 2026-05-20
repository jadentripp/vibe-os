# Audio Path

The first real Doom audio target is an ISA Sound Blaster 16 compatible device at
base port `0x220`. This is the practical hobby-OS target because QEMU exposes an
SB16 model and the device has a simple DSP reset/version probe before the harder
mixing work.

Current kernel behavior:

- probes the SB16 DSP reset/read ports and records `audio=SB16` or `audio=NONE`
  in the smoke status block
- configures SB16 mixer IRQ/DMA routing for IRQ 5, 8-bit DMA 1, and 16-bit DMA 5
- owns a 4096-byte, 4096-byte-aligned unsigned-silence DMA buffer in low kernel
  memory for ISA DMA reachability
- programs 8-bit DMA channel 1 with mask, flip-flop, address, page, count, and
  auto-init memory-to-device mode writes
- starts 8-bit DMA playback with DSP speaker-on, time-constant, block-size, and
  auto-init output commands when Doom exercises the audio syscall
- stops playback with DSP exit-auto-init/speaker-off and masks DMA channel 1
- installs an IRQ 5 handler that acknowledges the SB16 DSP status ports and
  records IRQ accounting
- exposes `SYS_AUDIO`/`VIBE_SYS_AUDIO` for the Doom platform layer
- records Doom sound calls as `doomsound=<hex count>` plus last command, handle,
  and packed parameters in kernel memory

SB16 constants in `kernel/kernel.asm`:

- DSP base: `SB16_BASE equ 0x0220`
- reset/read/write/status ports: `0x226`, `0x22a`, `0x22c`, `0x22e`
- reset acknowledgement: `0xaa`
- version command: `0xe1`
- playback defaults: IRQ 5, 8-bit DMA 1, 16-bit DMA 5
- DMA buffer: `SB16_DMA_BUFFER_BYTES equ 4096`
- DMA block: `SB16_DMA_BLOCK_BYTES equ SB16_DMA_BUFFER_BYTES / 2`
- 8-bit DMA mode: `DMA8_CH1_AUTO_READ_MODE equ 0x59`

8-bit DMA playback:

The current low layer is intentionally simple: Doom sound start/update/init
syscalls trigger the SB16 start path, which clears the kernel-owned DMA buffer to
unsigned 8-bit silence (`0x80`) and starts auto-init playback at 11025 Hz. This
is enough for the OS to prove that it owns the DMA buffer and can attempt PCM
output on QEMU or real SB16-compatible hardware without touching Doom source.

Remaining gaps:

- Doom SFX are not mixed into PCM yet; the syscall still records handle,
  volume, separation, and pitch data for the next mixer milestone.
- MUS/MIDI synthesis is not implemented.
- IRQ refill currently records/acknowledges interrupts but does not rotate or
  refill half-buffers with mixed samples.
- Local `make test` stays host-only and does not launch QEMU; VM smoke remains
  behind the explicit repo-owned `ALLOW_LOCAL_VM=1` opt-in.

Fallback plan:

If SB16 probing fails, keep `audio=NONE` and preserve the syscall counters. A
PC speaker fallback can later consume the same `SYS_AUDIO` start/stop events for
simple one-voice beeps without changing Doom source.
