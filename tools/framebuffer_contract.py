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
VISUAL_PROOF_SEED = 0x811C9DC5
VISUAL_PROOF_ADD = 0x01000193


def validate_indexed_inputs(frame: bytes, palette: bytes) -> None:
    if len(frame) != DOOM_FRAME_BYTES:
        raise ValueError(f"indexed frame must be {DOOM_FRAME_BYTES} bytes")
    if len(palette) != PALETTE_BYTES:
        raise ValueError(f"palette must be {PALETTE_BYTES} bytes")


def xrgb8888_pixel(index: int, palette: bytes) -> bytes:
    base = index * 3
    red, green, blue = palette[base:base + 3]
    return bytes((blue, green, red, 0))


def _rol32(value: int, bits: int) -> int:
    return ((value << bits) | (value >> (32 - bits))) & 0xFFFFFFFF


def _proof_hash(data: bytes) -> int:
    value = VISUAL_PROOF_SEED
    for byte in data:
        value = _rol32(value, 5)
        value ^= byte
        value = (value + VISUAL_PROOF_ADD) & 0xFFFFFFFF
    return value


def visual_proof_fields(frame: bytes, palette: bytes) -> dict[str, int]:
    validate_indexed_inputs(frame, palette)
    transitions = 0
    previous = frame[0]

    for index in frame[1:]:
        if index != previous:
            transitions += 1
        previous = index

    return {
        "doompal": _proof_hash(palette),
        "doomframe": _proof_hash(frame),
        "doomnonzero": sum(1 for index in frame if index != 0),
        "doomcolors": transitions,
    }


def scale_2x_geometry(width: int, height: int) -> dict[str, int]:
    if width < DOOM_WIDTH * 2 or height < DOOM_HEIGHT * 2:
        raise ValueError("framebuffer must fit a 2x Doom frame")

    return {
        "width": width,
        "height": height,
        "pitch": width * XRGB_BYTES_PER_PIXEL,
        "x": (width - DOOM_WIDTH * 2) // 2,
        "y": (height - DOOM_HEIGHT * 2) // 2,
        "scaled_width": DOOM_WIDTH * 2,
        "scaled_height": DOOM_HEIGHT * 2,
    }


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
    geometry = scale_2x_geometry(width, height)
    pitch = geometry["pitch"]
    out = bytearray(pitch * height)
    x0 = geometry["x"] * XRGB_BYTES_PER_PIXEL
    y0 = geometry["y"]

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
    result = {"indexed_shadow": shadow, "visual_proof": visual_proof_fields(frame, palette)}
    if backend == "lfb":
        result["xrgb8888"] = scale_2x_xrgb8888_centered(frame, palette)
    elif backend != "mode13":
        raise ValueError(f"unknown backend: {backend}")
    return result
