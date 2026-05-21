import json
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DoomPortabilityBoundaryTests(unittest.TestCase):
    def run_checker(self):
        result = subprocess.run(
            ["python3", "tools/check_doom_portability_boundary.py", "--json"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        return json.loads(result.stdout)

    def test_boundary_checker_classifies_original_and_replacement_sources(self):
        report = self.run_checker()
        boundary = report["compile_boundary"]

        self.assertEqual(report["vendor"]["status"], "pristine")
        self.assertEqual(boundary["original_c_sources"], 62)
        self.assertEqual(boundary["compile_unchanged_sources"], 57)
        self.assertEqual(
            boundary["excluded_platform_sources"],
            ["i_main.c", "i_net.c", "i_sound.c", "i_system.c", "i_video.c"],
        )
        self.assertIn("g_game.c", boundary["wrapped_original_sources"])
        self.assertIn("p_saveg.c", boundary["wrapped_original_sources"])

        for source in boundary["port_sources"]:
            with self.subTest(source=source):
                self.assertTrue(source.startswith("doom_port/"))
                self.assertNotIn("third_party/doom", source)

    def test_boundary_checker_records_reusable_game_port_hooks(self):
        report = self.run_checker()
        hooks = report["reusable_libc_hooks"]

        expected_hooks = {
            "files": {
                "open",
                "read",
                "write",
                "close",
                "lseek",
                "access",
                "unlink",
                "vibe_file_size",
                "vibe_file_read_all",
            },
            "metadata": {"stat", "fstat", "mkdir", "vibe_listdir"},
            "stdio": {"fopen", "fread", "fwrite", "fseek", "fflush", "fclose"},
            "memory": {
                "malloc",
                "calloc",
                "realloc",
                "free",
                "mmap",
                "munmap",
                "vibe_mmap_anon",
                "vibe_heap_capabilities",
                "vibe_vm_capabilities",
            },
            "process": {"execv", "execve", "execl", "fork", "waitpid", "getpid"},
            "devices": {
                "ioctl",
                "clock_gettime",
                "vibe_clock_gettime",
                "vibe_clock_monotonic",
                "vibe_poll_input",
                "vibe_drain_input",
                "vibe_input_status",
                "vibe_audio_device_start",
                "vibe_audio_mixer_start",
                "vibe_audio_mixer_update",
                "vibe_audio_mixer_stop",
                "vibe_audio_mixer_is_playing",
                "vibe_audio_device_info",
                "vibe_audio_pcm_ring_info",
                "vibe_audio_stream_info",
                "vibe_fb_get_info",
                "vibe_present_indexed",
                "vibe_present_indexed_checked",
            },
        }
        self.assertEqual(set(hooks), set(expected_hooks))
        for group, names in expected_hooks.items():
            with self.subTest(group=group):
                self.assertTrue(names.issubset(set(hooks[group])))

    def test_portability_readiness_doc_tracks_checker_contract(self):
        docs = (ROOT / "docs" / "doom-provenance.md").read_text()
        checker = (ROOT / "tools" / "check_doom_portability_boundary.py").read_text()

        for token in (
            "tools/check_doom_portability_boundary.py",
            "third_party/doom",
            "57 original linuxdoom C files",
            "i_main.c",
            "i_system.c",
            "i_video.c",
            "i_sound.c",
            "i_net.c",
            "doom_port/libc.c",
            "Reusable hooks",
        ):
            with self.subTest(token=token):
                self.assertIn(token, docs)
        self.assertIn("ORIGINAL_PLATFORM_SOURCES", checker)
        self.assertIn("REUSABLE_LIBC_HOOKS", checker)


if __name__ == "__main__":
    unittest.main()
