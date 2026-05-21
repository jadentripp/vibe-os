import unittest
from pathlib import Path

from tools import framebuffer_contract as fb


ROOT = Path(__file__).resolve().parents[2]


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

    def test_fbinfo_contract_advertises_reusable_display_capabilities(self):
        lfb = fb.fbinfo_contract("lfb", width=800, height=600)
        self.assertEqual(lfb["backend"], fb.BACKEND_LFB_XRGB8888)
        self.assertEqual(lfb["source_name"], fb.DOOM_SOURCE.name)
        self.assertEqual((lfb["source_width"], lfb["source_height"]), (320, 200))
        self.assertEqual(lfb["source_aspect_height"], 240)
        self.assertEqual(lfb["present_format"], fb.FORMAT_INDEX8_RGB24)
        self.assertEqual((lfb["max_present_width"], lfb["max_present_height"]), (320, 200))
        self.assertEqual(lfb["frame_bytes"], fb.DOOM_FRAME_BYTES)
        self.assertEqual(lfb["palette_bytes"], fb.PALETTE_BYTES)
        self.assertEqual(lfb["capabilities"] & fb.CAP_PRESENT_INDEXED, fb.CAP_PRESENT_INDEXED)
        self.assertEqual(lfb["capabilities"] & fb.CAP_PRESENT_RGB_PALETTE, fb.CAP_PRESENT_RGB_PALETTE)
        self.assertEqual(lfb["capabilities"] & fb.CAP_XRGB8888_LFB, fb.CAP_XRGB8888_LFB)
        self.assertEqual(lfb["capabilities"] & fb.CAP_MODE13_SHADOW, fb.CAP_MODE13_SHADOW)
        self.assertEqual(lfb["capabilities"] & fb.CAP_DIRTY_SOURCE_RECT, fb.CAP_DIRTY_SOURCE_RECT)

        mode13 = fb.fbinfo_contract("mode13")
        self.assertEqual(mode13["backend"], fb.BACKEND_MODE13)
        self.assertEqual(mode13["present_format"], fb.FORMAT_INDEX8_RGB24)
        self.assertFalse(mode13["capabilities"] & fb.CAP_XRGB8888_LFB)
        self.assertEqual(mode13["capabilities"] & fb.CAP_MODE13_SHADOW, fb.CAP_MODE13_SHADOW)

    def test_public_header_declares_backend_ids_for_fbinfo(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        self.assertIn("VIBE_FB_BACKEND_MODE13 = 1", header)
        self.assertIn("VIBE_FB_BACKEND_LFB_XRGB8888 = 2", header)
        self.assertIn("VIBE_FB_POLICY_ASPECT = 2", header)
        self.assertIn("VIBE_FB_FORMAT_INDEX8_RGB24 = 1", header)

    def test_lfb_present_clears_only_when_view_geometry_changes(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        lfb_present = kernel.split(".lfb_present:", 1)[1].split(".success:", 1)[0]
        clear_guard = kernel.split("present_clear_lfb_if_geometry_changed:", 1)[1].split("present_clear_lfb:", 1)[0]

        self.assertIn("call present_clear_lfb_if_geometry_changed", lfb_present)
        self.assertNotIn("call present_clear_lfb\n    call present_lfb_xrgb8888", lfb_present)
        self.assertIn("cmp eax, [present_lfb_last_view_x]", clear_guard)
        self.assertIn("cmp eax, [present_lfb_last_view_y]", clear_guard)
        self.assertIn("cmp eax, [present_lfb_last_view_width]", clear_guard)
        self.assertIn("cmp eax, [present_lfb_last_view_height]", clear_guard)
        self.assertIn("call present_clear_lfb", clear_guard)
        self.assertIn("present_lfb_last_view_x dd 0xffffffff", kernel)

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
        proof = fb.present_proof_fields(frame, palette)

        self.assertEqual(set(proof), {"palette_hash", "frame_hash", "nonzero_pixels", "color_transitions"})
        self.assertEqual(proof["nonzero_pixels"], fb.DOOM_FRAME_BYTES - frame.count(0))
        self.assertGreater(proof["palette_hash"], 0)
        self.assertGreater(proof["frame_hash"], 0)
        self.assertGreater(proof["color_transitions"], 0)

        changed = bytearray(frame)
        changed[123] ^= 0x7F
        changed_proof = fb.present_proof_fields(bytes(changed), palette)
        self.assertNotEqual(changed_proof["frame_hash"], proof["frame_hash"])
        self.assertEqual(changed_proof["palette_hash"], proof["palette_hash"])

        status_proof = fb.visual_proof_fields(frame, palette)
        self.assertEqual(status_proof["doompal"], proof["palette_hash"])
        self.assertEqual(status_proof["doomframe"], proof["frame_hash"])
        self.assertEqual(status_proof["doomnonzero"], proof["nonzero_pixels"])
        self.assertEqual(status_proof["doomcolors"], proof["color_transitions"])

    def test_status_display_validator_is_source_format_driven(self):
        fields = {
            "fb": "LFB",
            "fbpolicy": "ASP",
            "fbgeom": "00000050:0000003C:00000280:000001E0:00000002",
            "fbdirty": "0000000A:00000014:00000015:00000006:00000002",
        }

        display = fb.validate_status_display_fields(fields)

        self.assertEqual(display["backend"], "LFB")
        self.assertEqual(display["policy"], "ASP")
        self.assertEqual((display["view_x"], display["view_y"]), (80, 60))
        self.assertEqual((display["view_width"], display["view_height"]), (640, 480))
        self.assertEqual(display["dirty"], (10, 20, 21, 6, 2))

        future_source = fb.IndexedSourceFormat(
            name="future-game-index8",
            width=160,
            height=100,
            aspect_height=120,
        )
        future_fields = {
            "fb": "LFB",
            "fbpolicy": "ASP",
            "fbgeom": "00000000:00000000:00000140:000000F0:00000002",
            "fbdirty": "00000000:00000000:00000000:00000000:00000000",
        }
        self.assertEqual(
            fb.validate_status_display_fields(future_fields, source=future_source)["view_height"],
            240,
        )

    def test_status_display_validator_rejects_out_of_bounds_dirty_source_rect(self):
        fields = {
            "fb": "M13",
            "fbpolicy": "M13",
            "fbgeom": "00000000:00000000:00000140:000000C8:00000001",
            "fbdirty": "0000013F:000000C7:00000002:00000001:00000001",
        }

        with self.assertRaisesRegex(AssertionError, "bounds exceed the source frame"):
            fb.validate_status_display_fields(fields)

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
