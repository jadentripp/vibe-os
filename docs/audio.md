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
- accepts Doom SFX descriptors from the platform layer and reports successful
  buffer submissions as `sfxmix=<hex count>`

SB16 constants in `kernel/kernel.asm`:

- DSP base: `SB16_BASE equ 0x0220`
- reset/read/write/status ports: `0x226`, `0x22a`, `0x22c`, `0x22e`
- reset acknowledgement: `0xaa`
- version command: `0xe1`
- playback defaults: IRQ 5, 8-bit DMA 1, 16-bit DMA 5
- DMA buffer: `SB16_DMA_BUFFER_BYTES equ 4096`
- DMA block: `SB16_DMA_BLOCK_BYTES equ SB16_DMA_BUFFER_BYTES / 2`
- 8-bit DMA mode: `DMA8_CH1_AUTO_READ_MODE equ 0x59`

8-bit SFX DMA playback:

The Doom platform layer keeps original Doom source pristine, resolves the `ds*`
sound lump for `I_StartSound`, caches the lump, strips the 8-byte Doom sound
header, and passes a small `vibe_audio_sfx_desc_t` through `SYS_AUDIO`. The
descriptor contains the raw unsigned 8-bit PCM sample pointer, length, volume,
separation, pitch, and Doom sound id.

The kernel validates the descriptor and sample range against the current Doom
process memory map, caps one submission to the 4096-byte DMA buffer, and mixes
the unsigned 8-bit PCM into the kernel-owned SB16 DMA ring. This milestone uses a
deterministic mono mix: each source sample is centered around `0x80`, scaled by
the Doom volume byte, added to the existing DMA byte, clipped back to unsigned
8-bit PCM, and written at `sb16_dma_write_pos` with wraparound. Separation and
pitch are recorded in the descriptor contract but are not applied yet.

Remaining gaps:

- MUS/MIDI synthesis is not implemented.
- IRQ refill currently records/acknowledges interrupts but does not rotate or
  refill half-buffers with mixed samples.
- Local `make test` stays host-only and does not launch QEMU; VM smoke remains
  behind the explicit repo-owned `ALLOW_LOCAL_VM=1` opt-in.

Fallback plan:

If SB16 probing fails, keep `audio=NONE` and preserve the syscall counters. A
PC speaker fallback can later consume the same `SYS_AUDIO` start/stop events for
simple one-voice beeps without changing Doom source.
