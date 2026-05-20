import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DoomMusicTests(unittest.TestCase):
    def test_music_parser_and_renderer_have_host_proof(self):
        source = ROOT / "tests" / "host" / "doom_music_test.c"

        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "doom_music_test"
            subprocess.run(
                [
                    os.environ.get("CLANG", "clang"),
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
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

    def test_doom_music_hooks_submit_pcm_through_audio_syscall(self):
        makefile = (ROOT / "Makefile").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        music_h = (ROOT / "doom_port" / "music.h").read_text()
        music_c = (ROOT / "doom_port" / "music.c").read_text()

        self.assertIn("doom_port/music.c", makefile)
        for token in (
            "#include \"music.h\"",
            "static unsigned char music_pcm[2][VIBE_MUSIC_STREAM_BYTES];",
            "vibe_music_stream_begin(",
            "vibe_music_stream_render(",
            "vibe_music_stream_set_volume(",
            "VIBE_AUDIO_START_SFX",
            "VIBE_AUDIO_UPDATE_SFX",
            "vibe_music_audio_handle",
            "pump_music_stream",
            "I_RegisterSong",
            "I_PlaySong",
            "I_StopSong",
        ):
            with self.subTest(token=token):
                self.assertIn(token, platform)

        for token in (
            "VIBE_MUSIC_FORMAT_MUS",
            "VIBE_MUSIC_FORMAT_MIDI",
            "VIBE_MUSIC_STREAM_BYTES",
            "vibe_music_render_stats_t",
            "program_count",
            "pan_count",
            "expression_count",
            "sustain_count",
            "pitch_bend_count",
            "percussion_note_count",
            "active_voice_peak",
            "loop_count",
            "stream_start_sample",
            "stream_end_sample",
            "vibe_music_register_song",
            "vibe_music_stream_begin",
            "vibe_music_stream_render",
            "vibe_music_stream_set_volume",
            "vibe_music_stream_position",
            "vibe_music_render_pcm",
        ):
            with self.subTest(token=token):
                self.assertIn(token, music_h)

        for token in (
            "render_mus_pass",
            "render_midi_pass",
            "synth_note_on",
            "synth_render_until",
            "channel_volume",
            "channel_expression",
            "channel_pan",
            "channel_program",
            "channel_sustain",
            "channel_pitch_bend",
            "mus_channel_to_midi",
            "synth_set_pitch_bend",
            "synth_set_sustain",
            "vibe_music_note_freq_x16",
            "++stats->loop_count",
            "render_pcm_window",
            "stream_position",
        ):
            with self.subTest(token=token):
                self.assertIn(token, music_c)

    def test_music_docs_describe_architecture_and_fallbacks(self):
        music_doc = (ROOT / "docs" / "doom-music.md").read_text()

        for token in (
            "MUS parser",
            "Standard MIDI format 0",
            "deterministic unsigned 8-bit PCM",
            "VIBE_AUDIO_START_SFX",
            "VIBE_AUDIO_UPDATE_SFX",
            "stateful stream cursor",
            "streamed music chunks",
            "pitch bend",
            "program changes",
            "pan, expression, sustain",
            "separate from normal Doom SFX",
            "PC speaker fallback",
            "SB16",
        ):
            with self.subTest(token=token):
                self.assertIn(token, music_doc)


if __name__ == "__main__":
    unittest.main()
