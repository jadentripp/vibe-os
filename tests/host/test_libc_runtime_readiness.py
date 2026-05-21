import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class LibcRuntimeReadinessTests(unittest.TestCase):
    def test_public_runtime_header_declares_generic_game_tool_wrappers(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()

        for token in (
            "int vibe_syscall_errno(int raw_result, int fallback_errno);",
            "int vibe_clock_monotonic(vibe_clock_time_t* out);",
            "unsigned long vibe_clock_ticks_to_milliseconds",
            "int vibe_file_size(const char* path, unsigned long* out_size);",
            "int vibe_file_read_all(",
            "int vibe_poll_input(vibe_input_event_t* event);",
            "int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events);",
            "int vibe_input_status(vibe_input_status_t* status);",
            "int vibe_fb_get_info(vibe_fb_info_t* info);",
            "int vibe_fb_can_present_indexed(",
            "int vibe_present_indexed(const vibe_present_indexed_t* present);",
            "int vibe_present_indexed_checked(const vibe_present_indexed_t* present);",
            "unsigned long vibe_heap_capabilities(void);",
            "unsigned long vibe_vm_capabilities(void);",
            "void* vibe_mmap_anon(unsigned long length, int prot);",
            "`vibe_poll_input` and `vibe_input_status`",
            "`vibe_drain_input` is a bounded nonblocking drain helper",
            "`vibe_fb_get_info` queries the reusable framebuffer contract",
            "`vibe_vm_capabilities` and `vibe_mmap_anon`",
        ):
            with self.subTest(token=token):
                self.assertIn(token, header)

        for token in (
            "int vibe_syscall_errno(int raw_result, int fallback_errno)",
            "int vibe_clock_monotonic(vibe_clock_time_t* out)",
            "int vibe_file_size(const char* path, unsigned long* out_size)",
            "int vibe_file_read_all(",
            "int vibe_poll_input(vibe_input_event_t* event)",
            "VIBE_SYS_POLL_INPUT",
            "(unsigned long)sizeof(*event)",
            "int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events)",
            "int vibe_input_status(vibe_input_status_t* status)",
            "VIBE_SYS_INPUT_STATUS",
            "(unsigned long)sizeof(*status)",
            "int vibe_fb_get_info(vibe_fb_info_t* info)",
            "VIBE_IOCTL_FBINFO",
            "int vibe_fb_can_present_indexed(",
            "int vibe_present_indexed(const vibe_present_indexed_t* present)",
            "ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED",
            "int vibe_present_indexed_checked(const vibe_present_indexed_t* present)",
            "unsigned long vibe_heap_capabilities(void)",
            "unsigned long vibe_vm_capabilities(void)",
            "void* vibe_mmap_anon(unsigned long length, int prot)",
        ):
            with self.subTest(token=token):
                self.assertIn(token, libc)

    def test_generic_runtime_contracts_have_host_proof(self):
        source = ROOT / "tests" / "host" / "libc_runtime_readiness_test.c"

        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "libc_runtime_readiness_test"
            subprocess.run(
                [
                    os.environ.get("CLANG", "clang"),
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-Wno-pointer-to-int-cast",
                    "-Wno-void-pointer-to-int-cast",
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    str(source),
                    "-o",
                    str(binary),
                ],
                check=True,
                cwd=ROOT,
            )
            subprocess.run([str(binary)], check=True, cwd=ROOT)


if __name__ == "__main__":
    unittest.main()
