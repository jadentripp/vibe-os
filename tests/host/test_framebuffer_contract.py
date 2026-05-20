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

        top_left = 40 * 640 * 4
        self.assertEqual(result["xrgb8888"][:top_left], bytes(top_left))
        self.assertEqual(result["xrgb8888"][top_left:top_left + 4], fb.xrgb8888_pixel(frame[0], palette))
        self.assertEqual(result["xrgb8888"][top_left + 4:top_left + 8], fb.xrgb8888_pixel(frame[0], palette))
        self.assertEqual(
            result["xrgb8888"][top_left + 640 * 4:top_left + 640 * 4 + 4],
            fb.xrgb8888_pixel(frame[0], palette),
        )

        second_source = frame[1]
        self.assertEqual(result["xrgb8888"][top_left + 8:top_left + 12], fb.xrgb8888_pixel(second_source, palette))

    def test_lfb_contract_centers_wider_targets(self):
        frame = fixture_frame()
        palette = fixture_palette()
        out = fb.scale_2x_xrgb8888_centered(frame, palette, width=800, height=600)
        pitch = 800 * 4
        offset = 100 * pitch + 80 * 4
        self.assertEqual(out[offset:offset + 4], fb.xrgb8888_pixel(frame[0], palette))
        self.assertEqual(out[offset - 4:offset], b"\x00\x00\x00\x00")

    def test_rejects_wrong_frame_or_palette_sizes(self):
        palette = fixture_palette()
        with self.assertRaises(ValueError):
            fb.present_contract(b"\x00", palette)
        with self.assertRaises(ValueError):
            fb.present_contract(fixture_frame(), b"\x00")


if __name__ == "__main__":
    unittest.main()
