import unittest

from tools import framebuffer_contract as fb


def fixture_frame():
    return bytes((x + y) & 0xFF for y in range(fb.DOOM_HEIGHT) for x in range(fb.DOOM_WIDTH))


def fixture_palette():
    data = bytearray()
    for index in range(256):
        data.extend((index, 255 - index, (index * 3) & 0xFF))
    return bytes(data)


class FramebufferContractTests(unittest.TestCase):
    def test_mode13_shadow_preserves_doom_indexed_frame(self):
        frame = fixture_frame()
        palette = fixture_palette()
        result = fb.present_contract(frame, palette, backend="mode13")
        self.assertEqual(result["indexed_shadow"], frame)
        self.assertNotIn("xrgb8888", result)

    def test_lfb_contract_keeps_shadow_and_converts_to_xrgb8888(self):
        frame = fixture_frame()
        palette = fixture_palette()
        result = fb.present_contract(frame, palette, backend="lfb")
        self.assertEqual(result["indexed_shadow"], frame)
        self.assertEqual(len(result["xrgb8888"]), 640 * 480 * 4)
        self.assertEqual(result["geometry"]["policy"], fb.POLICY_ASPECT)
        self.assertEqual(result["geometry"]["scale"], 2)

        top_left = 0
        self.assertEqual(result["xrgb8888"][top_left:top_left + 4], fb.xrgb8888_pixel(frame[0], palette))
        self.assertEqual(result["xrgb8888"][top_left + 4:top_left + 8], fb.xrgb8888_pixel(frame[0], palette))
        self.assertEqual(
            result["xrgb8888"][top_left + 640 * 4:top_left + 640 * 4 + 4],
            fb.xrgb8888_pixel(frame[0], palette),
        )

        second_source = frame[1]
        self.assertEqual(result["xrgb8888"][top_left + 8:top_left + 12], fb.xrgb8888_pixel(second_source, palette))

    def test_lfb_contract_centers_aspect_correct_integer_targets(self):
        frame = fixture_frame()
        palette = fixture_palette()
        out = fb.scale_xrgb8888_centered(frame, palette, width=800, height=600)
        geometry = fb.lfb_geometry(800, 600)
        pitch = 800 * 4
        offset = geometry["y"] * pitch + geometry["x"] * 4
        self.assertEqual(geometry["policy"], fb.POLICY_ASPECT)
        self.assertEqual((geometry["x"], geometry["y"]), (80, 60))
        self.assertEqual((geometry["scaled_width"], geometry["scaled_height"]), (640, 480))
        self.assertEqual(out[offset:offset + 4], fb.xrgb8888_pixel(frame[0], palette))
        self.assertEqual(out[offset - 4:offset], b"\x00\x00\x00\x00")

    def test_lfb_contract_uses_labeled_square_fallback_when_aspect_does_not_fit(self):
        frame = fixture_frame()
        palette = fixture_palette()
        out = fb.scale_xrgb8888_centered(frame, palette, width=641, height=401)
        pitch = 641 * 4
        geometry = fb.lfb_geometry(641, 401)
        last_source = frame[-1]
        last_pixel = fb.xrgb8888_pixel(last_source, palette)
        x = geometry["x"] + geometry["scaled_width"] - 1
        y = geometry["y"] + geometry["scaled_height"] - 1
        offset = y * pitch + x * 4

        self.assertEqual(geometry["policy"], fb.POLICY_SQUARE)
        self.assertEqual((geometry["scaled_width"], geometry["scaled_height"]), (640, 400))
        self.assertEqual(out[offset:offset + 4], last_pixel)
        self.assertEqual(len(out), pitch * 401)

    def test_lfb_contract_scales_up_to_largest_integer_aspect_viewport(self):
        geometry = fb.lfb_geometry(1024, 768)
        self.assertEqual(geometry["policy"], fb.POLICY_ASPECT)
        self.assertEqual(geometry["scale"], 3)
        self.assertEqual((geometry["x"], geometry["y"]), (32, 24))
        self.assertEqual((geometry["scaled_width"], geometry["scaled_height"]), (960, 720))

    def test_dirty_rect_reports_changed_source_bounds_and_count(self):
        previous = bytearray(fb.DOOM_FRAME_BYTES)
        frame = bytearray(previous)
        frame[10 + 20 * fb.DOOM_WIDTH] = 1
        frame[30 + 25 * fb.DOOM_WIDTH] = 2

        dirty = fb.dirty_rect(bytes(previous), bytes(frame))

        self.assertEqual(dirty, {"x": 10, "y": 20, "width": 21, "height": 6, "count": 2})
        self.assertEqual(fb.dirty_rect(bytes(frame), bytes(frame))["count"], 0)

    def test_visual_proof_fields_are_aggregate_only(self):
        frame = fixture_frame()
        palette = fixture_palette()
        proof = fb.visual_proof_fields(frame, palette)

        self.assertEqual(set(proof), {"doompal", "doomframe", "doomnonzero", "doomcolors"})
        self.assertEqual(proof["doomnonzero"], fb.DOOM_FRAME_BYTES - frame.count(0))
        self.assertGreater(proof["doompal"], 0)
        self.assertGreater(proof["doomframe"], 0)
        self.assertGreater(proof["doomcolors"], 0)

        changed = bytearray(frame)
        changed[123] ^= 0x7F
        changed_proof = fb.visual_proof_fields(bytes(changed), palette)
        self.assertNotEqual(changed_proof["doomframe"], proof["doomframe"])
        self.assertEqual(changed_proof["doompal"], proof["doompal"])

    def test_rejects_wrong_frame_or_palette_sizes(self):
        palette = fixture_palette()
        with self.assertRaises(ValueError):
            fb.present_contract(b"\x00", palette)
        with self.assertRaises(ValueError):
            fb.present_contract(fixture_frame(), b"\x00")
        with self.assertRaises(ValueError):
            fb.scale_2x_geometry(639, 480)


if __name__ == "__main__":
    unittest.main()
