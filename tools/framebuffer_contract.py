"""Reference framebuffer contracts for the Doom present path.

This host-only module mirrors the kernel's intended video contract without
including or emitting copyrighted Doom pixels: user space supplies a 320x200
indexed frame plus a 256-entry RGB palette, the kernel keeps a byte-for-byte
indexed shadow for smoke checks, and VBE backends scale to XRGB8888.
"""

DOOM_WIDTH = 320
DOOM_HEIGHT = 200
DOOM_FRAME_BYTES = DOOM_WIDTH * DOOM_HEIGHT
PALETTE_BYTES = 256 * 3
XRGB_BYTES_PER_PIXEL = 4


def validate_indexed_inputs(frame: bytes, palette: bytes) -> None:
    if len(frame) != DOOM_FRAME_BYTES:
        raise ValueError(f"indexed frame must be {DOOM_FRAME_BYTES} bytes")
    if len(palette) != PALETTE_BYTES:
        raise ValueError(f"palette must be {PALETTE_BYTES} bytes")


def xrgb8888_pixel(index: int, palette: bytes) -> bytes:
    base = index * 3
    red, green, blue = palette[base:base + 3]
    return bytes((blue, green, red, 0))


def indexed_shadow(frame: bytes, palette: bytes) -> bytes:
    validate_indexed_inputs(frame, palette)
    return bytes(frame)


def scale_2x_xrgb8888_centered(
    frame: bytes,
    palette: bytes,
    width: int = 640,
    height: int = 480,
) -> bytes:
    validate_indexed_inputs(frame, palette)
    if width < DOOM_WIDTH * 2 or height < DOOM_HEIGHT * 2:
        raise ValueError("framebuffer must fit a 2x Doom frame")

    pitch = width * XRGB_BYTES_PER_PIXEL
    out = bytearray(pitch * height)
    x0 = ((width - DOOM_WIDTH * 2) // 2) * XRGB_BYTES_PER_PIXEL
    y0 = (height - DOOM_HEIGHT * 2) // 2

    for y in range(DOOM_HEIGHT):
        row = frame[y * DOOM_WIDTH:(y + 1) * DOOM_WIDTH]
        dst0 = (y0 + y * 2) * pitch + x0
        dst1 = dst0 + pitch
        cursor0 = dst0
        cursor1 = dst1
        for index in row:
            pixel = xrgb8888_pixel(index, palette)
            out[cursor0:cursor0 + 4] = pixel
            out[cursor0 + 4:cursor0 + 8] = pixel
            out[cursor1:cursor1 + 4] = pixel
            out[cursor1 + 4:cursor1 + 8] = pixel
            cursor0 += 8
            cursor1 += 8

    return bytes(out)


def present_contract(frame: bytes, palette: bytes, backend: str = "lfb") -> dict[str, bytes]:
    shadow = indexed_shadow(frame, palette)
    result = {"indexed_shadow": shadow}
    if backend == "lfb":
        result["xrgb8888"] = scale_2x_xrgb8888_centered(frame, palette)
    elif backend != "mode13":
        raise ValueError(f"unknown backend: {backend}")
    return result
