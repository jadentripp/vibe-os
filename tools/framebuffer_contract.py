"""Reference framebuffer contracts for indexed present paths.

This host-only module mirrors the kernel's intended video contract without
including or emitting copyrighted Doom pixels: user space supplies a bounded
indexed source frame plus a 256-entry RGB palette, the kernel keeps a
byte-for-byte indexed shadow for smoke checks, and VBE backends scale to
XRGB8888. Doom currently provides the only source format, but the checks below
are written against an explicit source spec so future games can reuse the same
contract.
"""

from dataclasses import dataclass
import re


@dataclass(frozen=True)
class IndexedSourceFormat:
    name: str
    width: int
    height: int
    aspect_height: int
    min_integer_scale: int = 2
    palette_entries: int = 256
    palette_entry_bytes: int = 3

    @property
    def frame_bytes(self) -> int:
        return self.width * self.height

    @property
    def palette_bytes(self) -> int:
        return self.palette_entries * self.palette_entry_bytes


DOOM_SOURCE = IndexedSourceFormat(
    name="doom-index8-rgb24",
    width=320,
    height=200,
    aspect_height=240,
)
DEFAULT_SOURCE = DOOM_SOURCE

DOOM_WIDTH = DOOM_SOURCE.width
DOOM_HEIGHT = DOOM_SOURCE.height
DOOM_ASPECT_HEIGHT = DOOM_SOURCE.aspect_height
DOOM_FRAME_BYTES = DOOM_SOURCE.frame_bytes
PALETTE_BYTES = DOOM_SOURCE.palette_bytes
XRGB_BYTES_PER_PIXEL = 4
VISUAL_PROOF_SEED = 0x811C9DC5
VISUAL_PROOF_ADD = 0x01000193
BACKEND_MODE13 = 1
BACKEND_LFB_XRGB8888 = 2
POLICY_MODE13 = "mode13"
POLICY_ASPECT = "aspect"
POLICY_SQUARE = "square"
STATUS_BACKEND_MODE13 = "M13"
STATUS_BACKEND_LFB = "LFB"
STATUS_POLICY_MODE13 = "M13"
STATUS_POLICY_ASPECT = "ASP"
STATUS_POLICY_SQUARE = "SQ"
CAP_PRESENT_INDEXED = 0x00000001
CAP_PRESENT_RGB_PALETTE = 0x00000002
CAP_XRGB8888_LFB = 0x00000004
CAP_MODE13_SHADOW = 0x00000008
CAP_DIRTY_SOURCE_RECT = 0x00000010
FORMAT_INDEX8_RGB24 = 1
PROOF_STATUS_FIELD_MAP = {
    "palette_hash": "doompal",
    "frame_hash": "doomframe",
    "nonzero_pixels": "doomnonzero",
    "color_transitions": "doomcolors",
}
HEX8_PATTERN = re.compile(r"[0-9A-Fa-f]{8}")


def validate_source(source: IndexedSourceFormat) -> None:
    if source.width <= 0 or source.height <= 0:
        raise ValueError("source dimensions must be positive")
    if source.aspect_height < source.height:
        raise ValueError("source aspect height must be at least source height")
    if source.min_integer_scale <= 0:
        raise ValueError("source minimum integer scale must be positive")
    if source.palette_entries <= 0 or source.palette_entry_bytes <= 0:
        raise ValueError("source palette dimensions must be positive")


def validate_indexed_inputs(
    frame: bytes,
    palette: bytes,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> None:
    validate_source(source)
    if len(frame) != source.frame_bytes:
        raise ValueError(f"indexed frame must be {source.frame_bytes} bytes")
    if len(palette) != source.palette_bytes:
        raise ValueError(f"palette must be {source.palette_bytes} bytes")


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


def present_proof_fields(
    frame: bytes,
    palette: bytes,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, int]:
    validate_indexed_inputs(frame, palette, source)
    transitions = 0
    previous = frame[0]

    for index in frame[1:]:
        if index != previous:
            transitions += 1
        previous = index

    return {
        "palette_hash": _proof_hash(palette),
        "frame_hash": _proof_hash(frame),
        "nonzero_pixels": sum(1 for index in frame if index != 0),
        "color_transitions": transitions,
    }


def visual_proof_fields(
    frame: bytes,
    palette: bytes,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, int]:
    proof = present_proof_fields(frame, palette, source)
    return {
        status_name: proof[generic_name]
        for generic_name, status_name in PROOF_STATUS_FIELD_MAP.items()
    }


def lfb_geometry(
    width: int,
    height: int,
    pitch: int | None = None,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, int | str]:
    validate_source(source)
    if pitch is None:
        pitch = width * XRGB_BYTES_PER_PIXEL
    if pitch < width * XRGB_BYTES_PER_PIXEL:
        raise ValueError("framebuffer pitch must fit the visible width")

    aspect_scale = min(width // source.width, height // source.aspect_height)
    if aspect_scale >= source.min_integer_scale:
        scale = aspect_scale
        policy = POLICY_ASPECT
        scaled_height = source.aspect_height * scale
    else:
        scale = min(width // source.width, height // source.height)
        if scale < source.min_integer_scale:
            raise ValueError("framebuffer must fit either aspect-correct or square indexed source")
        policy = POLICY_SQUARE
        scaled_height = source.height * scale

    scaled_width = source.width * scale
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


def indexed_shadow(
    frame: bytes,
    palette: bytes,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> bytes:
    validate_indexed_inputs(frame, palette, source)
    return bytes(frame)


def dirty_rect(
    previous: bytes,
    frame: bytes,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, int]:
    validate_source(source)
    if len(previous) != source.frame_bytes:
        raise ValueError(f"previous frame must be {source.frame_bytes} bytes")
    if len(frame) != source.frame_bytes:
        raise ValueError(f"indexed frame must be {source.frame_bytes} bytes")

    min_x = source.width
    min_y = source.height
    max_x = -1
    max_y = -1
    count = 0

    for offset, (old, new) in enumerate(zip(previous, frame)):
        if old == new:
            continue
        count += 1
        x = offset % source.width
        y = offset // source.width
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
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> bytes:
    validate_indexed_inputs(frame, palette, source)
    geometry = lfb_geometry(width, height, pitch, source)
    pitch = geometry["pitch"]
    out = bytearray(pitch * height)
    x0 = geometry["x"] * XRGB_BYTES_PER_PIXEL
    y0 = geometry["y"]
    scale = geometry["scale"]
    visual_height = source.aspect_height if geometry["policy"] == POLICY_ASPECT else source.height

    for visual_y in range(visual_height):
        source_y = (visual_y * source.height) // visual_height
        row = frame[source_y * source.width:(source_y + 1) * source.width]
        for repeat_y in range(scale):
            cursor = (y0 + visual_y * scale + repeat_y) * pitch + x0
            for index in row:
                pixel = xrgb8888_pixel(index, palette)
                for _ in range(scale):
                    out[cursor:cursor + 4] = pixel
                    cursor += 4

    return bytes(out)


def scale_2x_geometry(
    width: int,
    height: int,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, int]:
    geometry = lfb_geometry(width, height, source=source)
    if geometry["scale"] != 2:
        raise ValueError("framebuffer does not select a 2x indexed source frame")
    return geometry


def scale_2x_xrgb8888_centered(
    frame: bytes,
    palette: bytes,
    width: int = 640,
    height: int = 480,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> bytes:
    return scale_xrgb8888_centered(frame, palette, width, height, source=source)


def fbinfo_contract(
    backend: str = "lfb",
    width: int = 640,
    height: int = 480,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, int | str]:
    validate_source(source)
    if backend == "mode13":
        geometry = {
            "width": source.width,
            "height": source.height,
            "pitch": source.width,
            "x": 0,
            "y": 0,
            "scaled_width": source.width,
            "scaled_height": source.height,
            "scale": 1,
            "policy": POLICY_MODE13,
        }
        backend_id = BACKEND_MODE13
        capabilities = CAP_PRESENT_INDEXED | CAP_PRESENT_RGB_PALETTE | CAP_MODE13_SHADOW | CAP_DIRTY_SOURCE_RECT
    elif backend == "lfb":
        geometry = lfb_geometry(width, height, source=source)
        backend_id = BACKEND_LFB_XRGB8888
        capabilities = (
            CAP_PRESENT_INDEXED
            | CAP_PRESENT_RGB_PALETTE
            | CAP_XRGB8888_LFB
            | CAP_MODE13_SHADOW
            | CAP_DIRTY_SOURCE_RECT
        )
    else:
        raise ValueError(f"unknown backend: {backend}")

    return {
        "width": geometry["width"],
        "height": geometry["height"],
        "pitch": geometry["pitch"],
        "backend": backend_id,
        "source_name": source.name,
        "source_width": source.width,
        "source_height": source.height,
        "source_aspect_height": source.aspect_height,
        "frame_bytes": source.frame_bytes,
        "palette_bytes": source.palette_bytes,
        "scale": geometry["scale"],
        "view_x": geometry["x"],
        "view_y": geometry["y"],
        "view_width": geometry["scaled_width"],
        "view_height": geometry["scaled_height"],
        "policy": geometry["policy"],
        "capabilities": capabilities,
        "present_format": FORMAT_INDEX8_RGB24,
        "max_present_width": source.width,
        "max_present_height": source.height,
    }


def present_contract(
    frame: bytes,
    palette: bytes,
    backend: str = "lfb",
    previous: bytes | None = None,
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, bytes | dict[str, int] | dict[str, int | str]]:
    shadow = indexed_shadow(frame, palette, source)
    if previous is None:
        previous = bytes(source.frame_bytes)
    result = {
        "indexed_shadow": shadow,
        "proof": present_proof_fields(frame, palette, source),
        "visual_proof": visual_proof_fields(frame, palette, source),
        "dirty": dirty_rect(previous, frame, source),
    }
    if backend == "lfb":
        result["geometry"] = lfb_geometry(640, 480, source=source)
        result["xrgb8888"] = scale_xrgb8888_centered(frame, palette, source=source)
    elif backend != "mode13":
        raise ValueError(f"unknown backend: {backend}")
    else:
        result["geometry"] = {
            "width": source.width,
            "height": source.height,
            "pitch": source.width,
            "x": 0,
            "y": 0,
            "scaled_width": source.width,
            "scaled_height": source.height,
            "scale": 1,
            "policy": POLICY_MODE13,
        }
    return result


def _parse_status_hex_tuple(value: str, count: int) -> tuple[int, ...]:
    parts = value.split(":")
    if len(parts) != count:
        raise AssertionError(f"must have {count} hex parts separated by ':'")
    parsed: list[int] = []
    for part in parts:
        if not HEX8_PATTERN.fullmatch(part):
            raise AssertionError(f"part must be eight hex digits, got {part!r}")
        parsed.append(int(part, 16))
    return tuple(parsed)


def validate_status_display_fields(
    fields: dict[str, str],
    source: IndexedSourceFormat = DEFAULT_SOURCE,
) -> dict[str, int | str | tuple[int, ...]]:
    validate_source(source)
    try:
        backend = fields["fb"]
        policy = fields["fbpolicy"]
        geometry = _parse_status_hex_tuple(fields["fbgeom"], 5)
        dirty = _parse_status_hex_tuple(fields["fbdirty"], 5)
    except KeyError as exc:
        raise AssertionError(f"status missing {exc.args[0]}= field") from exc
    except AssertionError as exc:
        raise AssertionError(f"framebuffer status field {exc}") from exc

    x, y, view_width, view_height, scale = geometry
    dirty_x, dirty_y, dirty_width, dirty_height, dirty_count = dirty

    if backend == STATUS_BACKEND_MODE13:
        if policy != STATUS_POLICY_MODE13:
            raise AssertionError(f"fbpolicy= must be M13 for fb=M13, got {policy!r}")
    elif backend == STATUS_BACKEND_LFB:
        if policy not in (STATUS_POLICY_ASPECT, STATUS_POLICY_SQUARE):
            raise AssertionError(f"fbpolicy= must be ASP or SQ for fb=LFB, got {policy!r}")
    else:
        raise AssertionError(f"fb= must be LFB or M13, got {backend!r}")

    if policy == STATUS_POLICY_MODE13:
        expected = (0, 0, source.width, source.height, 1)
        if geometry != expected:
            raise AssertionError(
                f"fbgeom= for M13 must be 0:0:{source.width}:{source.height}:1, got {fields['fbgeom']!r}"
            )
    elif policy == STATUS_POLICY_ASPECT:
        if (
            view_width != source.width * scale
            or view_height != source.aspect_height * scale
            or scale < source.min_integer_scale
        ):
            raise AssertionError(
                f"fbgeom= ASP must be {source.width}x{source.aspect_height} integer-scaled, "
                f"got {fields['fbgeom']!r}"
            )
    elif policy == STATUS_POLICY_SQUARE:
        if (
            view_width != source.width * scale
            or view_height != source.height * scale
            or scale < source.min_integer_scale
        ):
            raise AssertionError(
                f"fbgeom= SQ must be {source.width}x{source.height} integer-scaled, "
                f"got {fields['fbgeom']!r}"
            )

    if dirty_count == 0:
        if (dirty_x, dirty_y, dirty_width, dirty_height) != (0, 0, 0, 0):
            raise AssertionError(f"fbdirty= with zero changed pixels must have zero bounds, got {fields['fbdirty']!r}")
    else:
        if dirty_x >= source.width or dirty_y >= source.height:
            raise AssertionError(
                f"fbdirty= origin must be inside the source frame, got {fields['fbdirty']!r}"
            )
        if dirty_width == 0 or dirty_height == 0:
            raise AssertionError(f"fbdirty= changed pixels need nonzero bounds, got {fields['fbdirty']!r}")
        if dirty_x + dirty_width > source.width or dirty_y + dirty_height > source.height:
            raise AssertionError(f"fbdirty= bounds exceed the source frame, got {fields['fbdirty']!r}")

    return {
        "backend": backend,
        "policy": policy,
        "view_x": x,
        "view_y": y,
        "view_width": view_width,
        "view_height": view_height,
        "scale": scale,
        "dirty": dirty,
    }
