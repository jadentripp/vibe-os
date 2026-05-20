# Graphics Path

Stage 2 now attempts a VBE 32-bit linear-framebuffer mode before protected-mode
entry. It scans the BIOS VBE mode list for a 640-pixel-wide, at least
640x400-capable, 32-bpp direct-color mode with XRGB8888-compatible channel
positions. On success it sets the mode with the LFB bit and writes the physical
framebuffer address, pitch, dimensions, bpp, and channel masks into the boot
info block at `0x7000`.

If VBE discovery or mode set fails, Stage 2 falls back to VGA Mode 13h and
records the legacy `0xA0000`, 320x200, 8-bpp indexed surface in the same boot
info block.

The kernel maps a high VBE LFB page-directory slot before paging is enabled, then
selects one of two present backends:

- `M13`: program the VGA DAC and copy Doom's 320x200 indexed frame to `0xA0000`.
- `LFB`: keep the same 320x200 indexed shadow at `0xA0000` for smoke tests, then
  convert the indexed frame plus RGB palette to XRGB8888. The preferred policy
  is aspect-correct integer scaling: Doom's 320x200 source is treated as a
  320x240 4:3 image, scaled by the largest integer that fits the framebuffer,
  and centered with black letterbox/pillarbox areas. On a 640x480 LFB this fills
  the whole target at 2x; on 800x600 it renders a centered 640x480 viewport. If
  a VBE target can fit only the older 320x200 square-pixel 2x path, the kernel
  uses a labeled `SQ` fallback instead of silently pretending it is aspect
  correct.

Userland can drive the same path through a small device-control ABI on
`VIBE_DISPLAY_FD`. `VIBE_IOCTL_FBINFO` reports the active dimensions, pitch,
backend, and indexed-frame byte counts. `VIBE_IOCTL_PRESENT_INDEXED` validates a
`vibe_present_indexed_t` descriptor, then presents the described 320x200 indexed
frame through the same backend as `SYS_PRESENT`. Doom now uses this ioctl path;
the syscall is kept as a low-level compatibility/probe entrypoint.

CI still may capture `build/gfx.bin` locally inside the runner as a byte-level
contract check, but uploaded artifacts exclude rendered Doom pixels. Real-WAD
smoke disables framebuffer capture and gates visual correctness through status
fields only: presented-frame count, palette/frame hashes, nonzero indexed
pixels, color-transition count, framebuffer policy, centered viewport geometry,
and source dirty-rectangle accounting. The host reference in
`tools/framebuffer_contract.py` mirrors the scaler and aggregate proof fields so
the contract can be tested without WAD data, local QEMU, or rendered Doom pixel
artifacts. Real-WAD smoke also excludes `disk.img` and WAD data.

Remaining graphics gaps:

- The LFB path only accepts XRGB8888-compatible VBE modes.
- It maps a single 4 MiB framebuffer page-table window, which is enough for the
  current 640-wide targets but not a general multi-monitor or large-mode mapper.
- The kernel accounts dirty source rectangles and reports them in status, but it
  still redraws the full centered viewport each present instead of using partial
  hardware blits.
