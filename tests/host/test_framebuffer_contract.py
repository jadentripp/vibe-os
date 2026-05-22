import subprocess
import tempfile
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
        self.assertEqual(lfb["source_aspect_width"], 320)
        self.assertEqual(lfb["source_aspect_height"], 240)
        self.assertEqual(lfb["pixel_aspect"], (240, 200))
        self.assertEqual(lfb["abi_version"], fb.ABI_VERSION)
        self.assertEqual(lfb["present_semantics"], fb.PRESENT_SEMANTICS_INDEXED_SOURCE)
        self.assertEqual(lfb["present_format"], fb.FORMAT_INDEX8_RGB24)
        self.assertEqual((lfb["max_present_width"], lfb["max_present_height"]), (320, 200))
        self.assertEqual(lfb["frame_bytes"], fb.DOOM_FRAME_BYTES)
        self.assertEqual(lfb["palette_bytes"], fb.PALETTE_BYTES)
        self.assertEqual(lfb["capabilities"] & fb.CAP_PRESENT_INDEXED, fb.CAP_PRESENT_INDEXED)
        self.assertEqual(lfb["capabilities"] & fb.CAP_PRESENT_RGB_PALETTE, fb.CAP_PRESENT_RGB_PALETTE)
        self.assertEqual(lfb["capabilities"] & fb.CAP_XRGB8888_LFB, fb.CAP_XRGB8888_LFB)
        self.assertEqual(lfb["capabilities"] & fb.CAP_MODE13_SHADOW, fb.CAP_MODE13_SHADOW)
        self.assertEqual(lfb["capabilities"] & fb.CAP_DIRTY_SOURCE_RECT, fb.CAP_DIRTY_SOURCE_RECT)
        self.assertEqual(lfb["capabilities"] & fb.CAP_FIXED_PRESENT_SIZE, fb.CAP_FIXED_PRESENT_SIZE)

        mode13 = fb.fbinfo_contract("mode13")
        self.assertEqual(mode13["backend"], fb.BACKEND_MODE13)
        self.assertEqual(mode13["present_format"], fb.FORMAT_INDEX8_RGB24)
        self.assertFalse(mode13["capabilities"] & fb.CAP_XRGB8888_LFB)
        self.assertEqual(mode13["capabilities"] & fb.CAP_MODE13_SHADOW, fb.CAP_MODE13_SHADOW)
        self.assertEqual(mode13["capabilities"] & fb.CAP_FIXED_PRESENT_SIZE, fb.CAP_FIXED_PRESENT_SIZE)

    def test_mode13_fbinfo_is_legacy_fallback_with_the_same_present_abi(self):
        mode13 = fb.fbinfo_contract("mode13")

        self.assertEqual(mode13["backend"], fb.BACKEND_MODE13)
        self.assertEqual((mode13["width"], mode13["height"], mode13["pitch"]), (320, 200, 320))
        self.assertEqual((mode13["view_x"], mode13["view_y"]), (0, 0))
        self.assertEqual((mode13["view_width"], mode13["view_height"], mode13["scale"]), (320, 200, 1))
        self.assertEqual(mode13["policy"], fb.POLICY_MODE13)
        self.assertEqual(mode13["present_format"], fb.FORMAT_INDEX8_RGB24)
        self.assertTrue(fb.can_present_indexed_descriptor(mode13, 320, 200))
        self.assertFalse(mode13["capabilities"] & fb.CAP_XRGB8888_LFB)

    def test_fixed_present_size_cap_matches_kernel_ioctl_validation(self):
        info = fb.fbinfo_contract("lfb", width=800, height=600)

        self.assertEqual(
            fb.present_size_contract(info),
            {"kind": "fixed", "format": fb.FORMAT_INDEX8_RGB24, "max_width": 320, "max_height": 200},
        )
        self.assertTrue(fb.can_present_indexed_descriptor(info, 320, 200))
        self.assertFalse(fb.can_present_indexed_descriptor(info, 319, 200))
        self.assertFalse(fb.can_present_indexed_descriptor(info, 320, 199))
        self.assertFalse(fb.can_present_indexed_descriptor(info, 321, 200))

        variable_size_info = dict(info)
        variable_size_info["capabilities"] &= ~fb.CAP_FIXED_PRESENT_SIZE
        self.assertEqual(fb.present_size_contract(variable_size_info)["kind"], "bounded")
        self.assertTrue(fb.can_present_indexed_descriptor(variable_size_info, 160, 100))
        self.assertFalse(fb.can_present_indexed_descriptor(variable_size_info, 321, 200))
        self.assertFalse(fb.can_present_indexed_descriptor(variable_size_info, 320, 201))

        unsupported = dict(info, present_format=0)
        self.assertFalse(fb.can_present_indexed_descriptor(unsupported, 320, 200))
        unsupported_palette = dict(info)
        unsupported_palette["capabilities"] &= ~fb.CAP_PRESENT_RGB_PALETTE
        self.assertFalse(fb.can_present_indexed_descriptor(unsupported_palette, 320, 200))

    def test_present_descriptor_validation_rejects_mismatched_buffers(self):
        info = fb.fbinfo_contract("lfb", width=800, height=600)
        frame = fixture_frame()
        palette = fixture_palette()

        fb.validate_present_indexed_descriptor(info, frame, palette, 320, 200)
        with self.assertRaisesRegex(ValueError, "not accepted"):
            fb.validate_present_indexed_descriptor(info, frame, palette, 319, 200)
        with self.assertRaisesRegex(ValueError, "indexed frame"):
            variable = dict(info)
            variable["capabilities"] &= ~fb.CAP_FIXED_PRESENT_SIZE
            fb.validate_present_indexed_descriptor(variable, frame[:-1], palette, 320, 200)
        with self.assertRaisesRegex(ValueError, "palette"):
            fb.validate_present_indexed_descriptor(info, frame, palette[:-1], 320, 200)

    def test_source_metadata_supports_a_second_indexed_game_shape(self):
        second_game = fb.IndexedSourceFormat(
            name="second-game-index8",
            width=160,
            height=100,
            aspect_height=120,
            min_integer_scale=2,
        )
        metadata = fb.source_metadata(second_game)
        info = fb.fbinfo_contract("lfb", width=640, height=480, source=second_game)
        frame = bytes(second_game.frame_bytes)
        palette = fixture_palette()

        self.assertEqual(metadata["source_name"], "second-game-index8")
        self.assertEqual(metadata["pixel_aspect"], (120, 100))
        self.assertEqual((info["source_width"], info["source_height"]), (160, 100))
        self.assertEqual(info["source_aspect_height"], 120)
        self.assertEqual((info["view_width"], info["view_height"]), (640, 480))
        fb.validate_present_indexed_descriptor(info, frame, palette, 160, 100)

    def test_graphics_doc_records_os_level_framebuffer_boundaries(self):
        docs = (ROOT / "docs" / "architecture.txt").read_text()
        for token in (
            "If VBE discovery or mode set fails, Stage 2 falls back to VGA Mode 13h",
            "The only accepted source today is Doom's 320x200 index8 frame",
            "`VIBE_FB_CAP_FIXED_PRESENT_SIZE`",
            "`max_present_width` by `max_present_height`",
            "source aspect width/height",
            "pixel aspect metadata",
            "`vibe_present_indexed_checked`",
            "Dirty source bounds",
            "source-frame coordinates, not target pixels",
            "`fbsrc=`",
            "`fbacct=`",
            "Future indexed backends can clear that bit",
            "true maxima",
        ):
            with self.subTest(token=token):
                self.assertIn(token, docs)

    def test_public_header_declares_backend_ids_for_fbinfo(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        self.assertIn("VIBE_FB_ABI_VERSION = 1", header)
        self.assertIn("VIBE_FB_PRESENT_SEMANTICS_INDEXED_SOURCE = 1", header)
        self.assertIn("VIBE_FB_BACKEND_MODE13 = 1", header)
        self.assertIn("VIBE_FB_BACKEND_LFB_XRGB8888 = 2", header)
        self.assertIn("VIBE_FB_POLICY_ASPECT = 2", header)
        self.assertIn("VIBE_FB_FORMAT_INDEX8_RGB24 = 1", header)
        self.assertIn("VIBE_FB_CAP_FIXED_PRESENT_SIZE = 0x00000020u", header)
        self.assertIn("vibe_fb_info_supports_indexed_rgb24", header)
        self.assertIn("vibe_fb_info_present_size_is_accepted", header)
        self.assertIn("vibe_fb_info_accepts_present_indexed", header)
        self.assertIn("vibe_present_indexed_frame_bytes", header)
        self.assertIn("vibe_fb_info_dirty_rect_is_bounded", header)
        self.assertIn("vibe_fb_info_source_format", header)
        self.assertIn("vibe_fb_info_source_width", header)
        self.assertIn("vibe_fb_info_source_height", header)
        self.assertIn("vibe_fb_info_source_palette_entry_bytes", header)
        self.assertIn("vibe_fb_info_source_aspect_height", header)

    def test_public_header_helpers_support_a_second_indexed_game(self):
        source = r"""
            #include "vibe_os.h"

            int main(void)
            {
                unsigned char frame[160 * 100];
                unsigned char palette[VIBE_FB_RGB24_PALETTE_BYTES];
                vibe_present_indexed_t present;
                vibe_fb_info_t info = {0};

                info.backend = VIBE_FB_BACKEND_LFB_XRGB8888;
                info.present_format = VIBE_FB_FORMAT_INDEX8_RGB24;
                info.capabilities = VIBE_FB_CAP_PRESENT_INDEXED
                    | VIBE_FB_CAP_PRESENT_RGB_PALETTE
                    | VIBE_FB_CAP_XRGB8888_LFB;
                info.max_present_width = 160;
                info.max_present_height = 100;
                info.palette_bytes = VIBE_FB_RGB24_PALETTE_BYTES;
                info.scale = 2;
                info.view_width = 320;
                info.view_height = 240;
                info.policy = VIBE_FB_POLICY_ASPECT;

                vibe_present_indexed_init(&present, frame, palette, 160, 100);
                if (present.frame != frame || present.palette != palette)
                    return 1;
                if (!vibe_fb_info_supports_indexed_rgb24(&info))
                    return 2;
                if (vibe_fb_info_requires_fixed_present_size(&info))
                    return 3;
                if (!vibe_fb_info_present_size_is_accepted(&info, 160, 100)
                    || !vibe_fb_info_present_size_is_accepted(&info, 80, 100)
                    || vibe_fb_info_present_size_is_accepted(&info, 161, 100))
                    return 4;
                if (vibe_fb_info_present_frame_bytes(&info) != 16000)
                    return 5;
                if (vibe_fb_info_present_palette_bytes(&info) != VIBE_FB_RGB24_PALETTE_BYTES)
                    return 6;
                if (vibe_fb_info_source_format(&info) != VIBE_FB_FORMAT_INDEX8_RGB24
                    || vibe_fb_info_source_width(&info) != 160
                    || vibe_fb_info_source_height(&info) != 100
                    || vibe_fb_info_source_palette_entries(&info) != VIBE_FB_INDEXED_PALETTE_COLORS
                    || vibe_fb_info_source_palette_entry_bytes(&info) != VIBE_FB_RGB24_PALETTE_ENTRY_BYTES
                    || vibe_fb_info_source_aspect_width(&info) != 160
                    || vibe_fb_info_source_aspect_height(&info) != 120)
                    return 7;
                if (vibe_present_indexed_frame_bytes(&present) != 16000
                    || !vibe_fb_info_accepts_present_indexed(&info, &present))
                    return 8;

                info.capabilities |= VIBE_FB_CAP_DIRTY_SOURCE_RECT;
                info.dirty_count = 0;
                info.dirty_x = 0;
                info.dirty_y = 0;
                info.dirty_width = 0;
                info.dirty_height = 0;
                if (!vibe_fb_info_dirty_rect_is_empty(&info)
                    || !vibe_fb_info_dirty_rect_is_bounded(&info))
                    return 9;
                info.dirty_count = 2;
                info.dirty_x = 10;
                info.dirty_y = 20;
                info.dirty_width = 30;
                info.dirty_height = 40;
                if (!vibe_fb_info_dirty_rect_is_bounded(&info))
                    return 10;
                info.dirty_width = 151;
                if (vibe_fb_info_dirty_rect_is_bounded(&info))
                    return 11;
                info.dirty_width = 30;

                present.width = 0;
                if (vibe_fb_info_accepts_present_indexed(&info, &present)
                    || vibe_present_indexed_frame_bytes(&present) != 0)
                    return 12;
                present.width = 160;

                info.capabilities |= VIBE_FB_CAP_FIXED_PRESENT_SIZE;
                if (!vibe_fb_info_requires_fixed_present_size(&info)
                    || !vibe_fb_info_present_size_is_accepted(&info, 160, 100)
                    || vibe_fb_info_present_size_is_accepted(&info, 80, 100))
                    return 13;

                return 0;
            }
        """
        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "second_game_fb_contract"
            build = subprocess.run(
                [
                    "clang",
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-Werror",
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    "-x",
                    "c",
                    "-",
                    "-o",
                    str(binary),
                ],
                cwd=ROOT,
                input=source,
                capture_output=True,
                text=True,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            run = subprocess.run([str(binary)], cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(run.returncode, 0, run.stdout + run.stderr)

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

    def test_kernel_records_generic_framebuffer_device_ownership(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for token in (
            "FRAMEBUFFER_HANDOFF_SOURCE_VBE equ 2",
            "FRAMEBUFFER_HANDOFF_SOURCE_GOP equ 3",
            "FRAMEBUFFER_GOP_BOOT_MODE equ 0xffff",
            "FB_PRESENT_WIDTH equ DOOM_SCREEN_WIDTH",
            "FB_PRESENT_FRAME_BYTES equ FB_PRESENT_WIDTH * FB_PRESENT_HEIGHT",
            "framebuffer_capabilities dd 0",
            "framebuffer_mmio_phys_base dd 0",
            "framebuffer_mmio_page_count dd 0",
            "framebuffer_source_format dd VIBE_FB_FORMAT_INDEX8_RGB24",
            "framebuffer_source_width dd FB_PRESENT_WIDTH",
            "framebuffer_source_aspect_height dd FB_PRESENT_ASPECT_HEIGHT",
            'smoke_fbdev_text db " fbdev="',
            'smoke_fbmmio_text db " fbmmio="',
            'smoke_fbinfo_text db " fbinfo="',
            'smoke_fbcap_text db " fbcap="',
            'smoke_fbsrc_text db " fbsrc="',
            'smoke_fbacct_text db " fbacct="',
        ):
            with self.subTest(token=token):
                self.assertIn(token, kernel)

        self.assertIn("cmp word [BOOT_VIDEO_MODE], FRAMEBUFFER_GOP_BOOT_MODE", kernel)
        self.assertIn("mov dword [framebuffer_handoff_source], FRAMEBUFFER_HANDOFF_SOURCE_GOP", kernel)
        self.assertIn("mov ebx, FB_PRESENT_FRAME_BYTES", kernel)
        self.assertIn("mov ebx, FB_PRESENT_PALETTE_BYTES", kernel)
        self.assertIn("mov ebx, [present_width_arg]", kernel)
        self.assertIn("mov [framebuffer_last_present_width], ebx", kernel)
        self.assertIn("mov edx, [framebuffer_info_query_count]", kernel)
        self.assertIn("mov edx, [framebuffer_source_format]", kernel)
        self.assertIn("mov edx, FRAMEBUFFER_PRESENT_SEMANTICS_INDEXED_SOURCE", kernel)
        self.assertIn("mov edx, [framebuffer_present_bad_desc_count]", kernel)
        self.assertIn("mov edx, [framebuffer_dirty_total_pixels]", kernel)
        self.assertIn("or dword [framebuffer_capabilities], VIBE_FB_CAP_XRGB8888_LFB", kernel)
        self.assertIn("mov eax, [framebuffer_capabilities]", kernel)

    def test_kernel_validates_user_pointers_for_framebuffer_abi(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        present_syscall = kernel.split(".present:", 1)[1].split(".present_success:", 1)[0]
        fbinfo_ioctl = kernel.split(".ioctl_fbinfo:", 1)[1].split(".ioctl_present_indexed:", 1)[0]
        present_ioctl = kernel.split(".ioctl_present_indexed:", 1)[1].split(".ioctl_present_success:", 1)[0]

        for source in (
            "mov ebx, FB_PRESENT_FRAME_BYTES",
            "call user_range_validate",
            "mov ebx, FB_PRESENT_PALETTE_BYTES",
        ):
            with self.subTest(sys_present=source):
                self.assertIn(source, present_syscall)

        self.assertIn("mov ebx, VIBE_FB_INFO_BYTES", fbinfo_ioctl)
        self.assertIn("call user_range_validate", fbinfo_ioctl)

        for source in (
            "mov ebx, VIBE_PRESENT_DESC_BYTES",
            "call user_range_validate",
            "cmp eax, [framebuffer_source_width]",
            "cmp eax, [framebuffer_source_height]",
            "mov ebx, [framebuffer_source_frame_bytes]",
            "mov ebx, [framebuffer_source_palette_bytes]",
            "inc dword [framebuffer_present_bad_size_count]",
            "inc dword [framebuffer_present_bad_range_count]",
        ):
            with self.subTest(present_ioctl=source):
                self.assertIn(source, present_ioctl)

    def test_dirty_rect_reports_changed_source_bounds_and_count(self):
        previous = bytearray(fb.DOOM_FRAME_BYTES)
        frame = bytearray(previous)
        frame[10 + 20 * fb.DOOM_WIDTH] = 1
        frame[30 + 25 * fb.DOOM_WIDTH] = 2

        dirty = fb.dirty_rect(bytes(previous), bytes(frame))

        self.assertEqual(dirty, {"x": 10, "y": 20, "width": 21, "height": 6, "count": 2})
        self.assertTrue(fb.dirty_rect_is_bounded(dirty))
        self.assertEqual(fb.dirty_rect(bytes(frame), bytes(frame))["count"], 0)
        self.assertTrue(fb.dirty_rect_is_bounded(fb.dirty_rect(bytes(frame), bytes(frame))))
        self.assertFalse(fb.dirty_rect_is_bounded({"x": 319, "y": 199, "width": 2, "height": 1, "count": 1}))
        self.assertFalse(fb.dirty_rect_is_bounded({"x": 0, "y": 0, "width": 0, "height": 0, "count": 1}))

    def test_initial_present_dirty_rect_compares_against_zero_source_frame(self):
        palette = fixture_palette()
        frame = bytearray(fb.DOOM_FRAME_BYTES)
        frame[0] = 1
        frame[fb.DOOM_FRAME_BYTES - 1] = 2

        result = fb.present_contract(bytes(frame), palette)

        self.assertEqual(result["dirty"], {"x": 0, "y": 0, "width": 320, "height": 200, "count": 2})

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
            "fbcap": "0000003F",
            "fbpolicy": "ASP",
            "fbsrc": "00000001:00000140:000000C8:00000140:000000F0:00000100:00000003",
            "fbacct": "00000001:00000001:00000000:00000000:00000000:00000001:00000002:0000FA00:00000300",
            "fbgeom": "00000050:0000003C:00000280:000001E0:00000002",
            "fbdirty": "0000000A:00000014:00000015:00000006:00000002",
        }

        display = fb.validate_status_display_fields(fields)

        self.assertEqual(display["backend"], "LFB")
        self.assertEqual(display["policy"], "ASP")
        self.assertEqual((display["view_x"], display["view_y"]), (80, 60))
        self.assertEqual((display["view_width"], display["view_height"]), (640, 480))
        self.assertEqual(display["capabilities"] & fb.CAP_DIRTY_SOURCE_RECT, fb.CAP_DIRTY_SOURCE_RECT)
        self.assertEqual(display["dirty"], (10, 20, 21, 6, 2))

        future_source = fb.IndexedSourceFormat(
            name="future-game-index8",
            width=160,
            height=100,
            aspect_height=120,
        )
        future_fields = {
            "fb": "LFB",
            "fbcap": "0000003F",
            "fbpolicy": "ASP",
            "fbsrc": "00000001:000000A0:00000064:000000A0:00000078:00000100:00000003",
            "fbacct": "00000001:00000001:00000000:00000000:00000000:00000000:00000000:00000000:00000000",
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
            "fbcap": "0000003B",
            "fbpolicy": "M13",
            "fbsrc": "00000001:00000140:000000C8:00000140:000000F0:00000100:00000003",
            "fbacct": "00000001:00000001:00000000:00000000:00000000:00000001:00000001:0000FA00:00000300",
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
