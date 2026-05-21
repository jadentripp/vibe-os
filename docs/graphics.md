# Graphics Path

Stage 2 attempts a VBE 32-bit linear-framebuffer mode before protected-mode
entry. It scans the BIOS VBE mode list for a 640-pixel-wide, at least
640x400-capable, 32-bpp direct-color mode with XRGB8888-compatible channel
positions. On success it sets the mode with the LFB bit and writes the physical
framebuffer address, pitch, dimensions, bpp, and channel masks into the boot
info block at `0x7000`.

If VBE discovery or mode set fails, Stage 2 falls back to VGA Mode 13h and
records the legacy `0xA0000`, 320x200, 8-bpp indexed surface in the same boot
info block.

## Runtime Contract

The framebuffer contract is intentionally split into three reusable layers:

- Physical framebuffer: the boot path reports the active target dimensions,
  pitch, backend, and pixel layout. The current backends are public ABI values:
  `VIBE_FB_BACKEND_MODE13` and `VIBE_FB_BACKEND_LFB_XRGB8888`.
- Present source: user space submits a bounded indexed source frame plus an RGB
  palette. The only accepted source today is Doom's 320x200 index8 frame with a
  256-entry RGB24 palette, advertised as `VIBE_FB_FORMAT_INDEX8_RGB24`.
- Presentation policy: the kernel maps that source into the active target. Mode
  13h is a 1:1 indexed copy. LFB backends preserve the indexed shadow and render
  a centered XRGB8888 viewport.

Userland discovers the same contract through `VIBE_DISPLAY_FD`.
`VIBE_IOCTL_FBINFO` fills `vibe_fb_info_t` with target dimensions, pitch,
backend, indexed-source byte counts, max present dimensions, present format,
capability bits, viewport geometry, and the latest dirty source rectangle.
`VIBE_IOCTL_PRESENT_INDEXED` validates a `vibe_present_indexed_t` descriptor and
presents the described source frame through the active backend. Doom uses this
ioctl path; `SYS_PRESENT` remains a low-level compatibility/probe entrypoint.

The `vibe_fb_info_t` layout is stable and generic enough for future indexed
games: clients should key off `present_format`, `max_present_width`,
`max_present_height`, and `capabilities` instead of assuming Doom. The current
implementation still accepts only 320x200 `INDEX8_RGB24` presents, so new games
larger than that need a new present format or an expanded max-present contract.

## Scaling Policy

The kernel selects one of these policies:

- `VIBE_FB_POLICY_MODE13`: copy the indexed source directly to the Mode 13h
  surface and keep the same bytes available as the smoke-test shadow.
- `VIBE_FB_POLICY_ASPECT`: treat Doom's 320x200 source as a 320x240 4:3 image,
  scale by the largest integer that fits the target, and center it with black
  bars as needed. A 640x480 LFB fills at 2x; an 800x600 LFB renders a centered
  640x480 viewport.
- `VIBE_FB_POLICY_SQUARE`: if the target cannot fit the aspect-correct viewport
  but can fit the older 320x200 square-pixel 2x path, use this explicitly
  labeled fallback.

## Capability Bits

- `VIBE_FB_CAP_PRESENT_INDEXED`: `VIBE_IOCTL_PRESENT_INDEXED` is supported.
- `VIBE_FB_CAP_PRESENT_RGB_PALETTE`: indexed presents use an RGB24 palette.
- `VIBE_FB_CAP_XRGB8888_LFB`: the active backend renders into an XRGB8888 LFB.
- `VIBE_FB_CAP_MODE13_SHADOW`: the indexed source shadow is maintained.
- `VIBE_FB_CAP_DIRTY_SOURCE_RECT`: `FBINFO` dirty fields describe source-frame
  changes since the previous present.

## Status And Proof

Real-WAD smoke runs must not upload rendered pixels, WAD data, or disk images.
They prove graphics through aggregate status fields only:

- Source activity: present count, palette hash, frame hash, nonzero indexed
  pixel count, color-transition count, and three indexed byte samples. The
  status names are still Doom-compatible (`doompresent`, `doompal`,
  `doomframe`, `doomnonzero`, `doomcolors`, `doomsamp`), but the host reference
  treats them as generic indexed-present proof values.
- Target mapping: `fb`, `fbpolicy`, and `fbgeom` report the backend, selected
  policy, centered viewport, and integer scale.
- Dirty source bounds: `fbdirty=x:y:width:height:count` reports changed pixels
  in source-frame coordinates, not target pixels.

`tools/framebuffer_contract.py` is the host reference for this contract. It
models the indexed source format explicitly, mirrors the LFB scaler, maps generic
proof values to the current Doom status aliases, and validates status geometry
without WAD data, local QEMU, or rendered Doom pixel artifacts.

Remaining graphics gaps:

- The LFB path only accepts XRGB8888-compatible VBE modes.
- The present ABI is discoverable, but the only accepted present format is still
  a 320x200 indexed frame plus RGB24 palette; direct RGB framebuffer presents
  and larger indexed sources remain future work.
- It maps a single 4 MiB framebuffer page-table window, which is enough for the
  current 640-wide targets but not a general multi-monitor or large-mode mapper.
- Dirty source rectangles are reported in status and `FBINFO`, but the renderer
  still redraws the full centered viewport each present instead of using partial
  hardware blits.
