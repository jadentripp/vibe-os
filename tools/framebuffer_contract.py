"""Reference framebuffer contracts for the Doom present path.

This host-only module mirrors the kernel's intended video contract without
including or emitting copyrighted Doom pixels: user space supplies a 320x200
indexed frame plus a 256-entry RGB palette, the kernel keeps a byte-for-byte
indexed shadow for smoke checks, and VBE backends scale to XRGB8888.
"""

DOOM_WIDTH = 320
DOOM_HEIGHT = 200
DOOM_ASPECT_HEIGHT = 240
DOOM_FRAME_BYTES = DOOM_WIDTH * DOOM_HEIGHT
PALETTE_BYTES = 256 * 3
XRGB_BYTES_PER_PIXEL = 4
VISUAL_PROOF_SEED = 0x811C9DC5
VISUAL_PROOF_ADD = 0x01000193
POLICY_MODE13 = "mode13"
POLICY_ASPECT = "aspect"
POLICY_SQUARE = "square"


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


def lfb_geometry(width: int, height: int, pitch: int | None = None) -> dict[str, int | str]:
    if pitch is None:
        pitch = width * XRGB_BYTES_PER_PIXEL
    if pitch < width * XRGB_BYTES_PER_PIXEL:
        raise ValueError("framebuffer pitch must fit the visible width")

    aspect_scale = min(width // DOOM_WIDTH, height // DOOM_ASPECT_HEIGHT)
    if aspect_scale >= 2:
        scale = aspect_scale
        policy = POLICY_ASPECT
        scaled_height = DOOM_ASPECT_HEIGHT * scale
    else:
        scale = min(width // DOOM_WIDTH, height // DOOM_HEIGHT)
        if scale < 2:
            raise ValueError("framebuffer must fit either aspect-correct or square 2x Doom")
        policy = POLICY_SQUARE
        scaled_height = DOOM_HEIGHT * scale

    scaled_width = DOOM_WIDTH * scale
    return {
        "width": width,
        "height": height,
        "pitch": pitch,
        "x": (width - scaled_width) // 2,
        "y": (height - scaled_height) // 2,
        "scaled_width": scaled_width,
        "scaled_height": scaled_height,
        "scale": scale,
        "policy": policy,
    }


def indexed_shadow(frame: bytes, palette: bytes) -> bytes:
    validate_indexed_inputs(frame, palette)
    return bytes(frame)


def dirty_rect(previous: bytes, frame: bytes) -> dict[str, int]:
    if len(previous) != DOOM_FRAME_BYTES:
        raise ValueError(f"previous frame must be {DOOM_FRAME_BYTES} bytes")
    if len(frame) != DOOM_FRAME_BYTES:
        raise ValueError(f"indexed frame must be {DOOM_FRAME_BYTES} bytes")

    min_x = DOOM_WIDTH
    min_y = DOOM_HEIGHT
    max_x = -1
    max_y = -1
    count = 0

    for offset, (old, new) in enumerate(zip(previous, frame)):
        if old == new:
            continue
        count += 1
        x = offset % DOOM_WIDTH
        y = offset // DOOM_WIDTH
        min_x = min(min_x, x)
        min_y = min(min_y, y)
        max_x = max(max_x, x)
        max_y = max(max_y, y)

    if count == 0:
        return {"x": 0, "y": 0, "width": 0, "height": 0, "count": 0}
    return {
        "x": min_x,
        "y": min_y,
        "width": max_x - min_x + 1,
        "height": max_y - min_y + 1,
        "count": count,
    }


def scale_xrgb8888_centered(
    frame: bytes,
    palette: bytes,
    width: int = 640,
    height: int = 480,
    pitch: int | None = None,
) -> bytes:
    validate_indexed_inputs(frame, palette)
    geometry = lfb_geometry(width, height, pitch)
    pitch = geometry["pitch"]
    out = bytearray(pitch * height)
    x0 = geometry["x"] * XRGB_BYTES_PER_PIXEL
    y0 = geometry["y"]
    scale = geometry["scale"]
    visual_height = DOOM_ASPECT_HEIGHT if geometry["policy"] == POLICY_ASPECT else DOOM_HEIGHT

    for visual_y in range(visual_height):
        source_y = (visual_y * DOOM_HEIGHT) // visual_height
        row = frame[source_y * DOOM_WIDTH:(source_y + 1) * DOOM_WIDTH]
        for repeat_y in range(scale):
            cursor = (y0 + visual_y * scale + repeat_y) * pitch + x0
            for index in row:
                pixel = xrgb8888_pixel(index, palette)
                for _ in range(scale):
                    out[cursor:cursor + 4] = pixel
                    cursor += 4

    return bytes(out)


def scale_2x_geometry(width: int, height: int) -> dict[str, int]:
    geometry = lfb_geometry(width, height)
    if geometry["scale"] != 2:
        raise ValueError("framebuffer does not select a 2x Doom frame")
    return geometry


def scale_2x_xrgb8888_centered(
    frame: bytes,
    palette: bytes,
    width: int = 640,
    height: int = 480,
) -> bytes:
    return scale_xrgb8888_centered(frame, palette, width, height)


def present_contract(
    frame: bytes,
    palette: bytes,
    backend: str = "lfb",
    previous: bytes | None = None,
) -> dict[str, bytes | dict[str, int] | dict[str, int | str]]:
    shadow = indexed_shadow(frame, palette)
    if previous is None:
        previous = bytes(DOOM_FRAME_BYTES)
    result = {
        "indexed_shadow": shadow,
        "visual_proof": visual_proof_fields(frame, palette),
        "dirty": dirty_rect(previous, frame),
    }
    if backend == "lfb":
        result["geometry"] = lfb_geometry(640, 480)
        result["xrgb8888"] = scale_xrgb8888_centered(frame, palette)
    elif backend != "mode13":
        raise ValueError(f"unknown backend: {backend}")
    else:
        result["geometry"] = {
            "width": DOOM_WIDTH,
            "height": DOOM_HEIGHT,
            "pitch": DOOM_WIDTH,
            "x": 0,
            "y": 0,
            "scaled_width": DOOM_WIDTH,
            "scaled_height": DOOM_HEIGHT,
            "scale": 1,
            "policy": POLICY_MODE13,
        }
    return result
