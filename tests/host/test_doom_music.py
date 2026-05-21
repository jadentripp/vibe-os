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
            "VIBE_AUDIO_MIXER_START",
            "VIBE_AUDIO_MIXER_UPDATE",
            "VIBE_AUDIO_PCM_PULL_STATE",
            "VIBE_AUDIO_STREAM_INFO",
            "current_music_pull_seen",
            "current_music_refill_seen",
            "query_music_stream_info",
            "vibe_audio_stream_has_new_refill_request",
            "VIBE_MUSIC_DEFAULT_SAMPLE_RATE) / 16)",
            "vibe_music_audio_handle",
            "stop_music_stream_handle",
            "current_music_handle != handle",
            "pump_music_stream",
            "I_RegisterSong",
            "I_PlaySong",
            "I_StopSong",
            "if (handle == current_music_handle)\n        I_StopSong(handle);",
            "desc.music_format = stats.format;",
            "desc.music_note_events = stats.note_on_count + stats.note_off_count;",
            "desc.music_control_events = stats.controller_count",
            "+ stats.score_end_count",
            "desc.music_active_voice_peak = stats.active_voice_peak;",
            "desc.music_emitted_samples = stats.emitted_samples;",
        ):
            with self.subTest(token=token):
                self.assertIn(token, platform)

        play_song_body = platform.split(
            "void I_PlaySong(int handle, int looping)", 1
        )[1].split("void I_StopSong", 1)[0]
        self.assertIn("vibe_music_stream_begin(", play_song_body)
        self.assertNotIn("pump_music_stream();", play_song_body)

        for hook in (
            "void I_StartTic(void)",
            "void I_UpdateSound(void)",
            "void I_SubmitSound(void)",
        ):
            with self.subTest(hook=hook):
                hook_body = platform.split(hook, 1)[1].split("\n}", 1)[0]
                self.assertIn("pump_music_stream();", hook_body)

        for token in (
            "VIBE_MUSIC_FORMAT_MUS",
            "VIBE_MUSIC_FORMAT_MIDI",
            "VIBE_MUSIC_STREAM_BYTES",
            "#define VIBE_MUSIC_STREAM_BYTES 32768u",
            "vibe_music_render_stats_t",
            "program_count",
            "pan_count",
            "expression_count",
            "sustain_count",
            "pitch_bend_count",
            "percussion_note_count",
            "score_end_count",
            "invalid_event_count",
            "active_voice_peak",
            "loop_count",
            "stream_start_sample",
            "stream_end_sample",
            "stream_song_samples",
            "stream_chunk_index",
            "stream_chunk_bytes",
            "vibe_music_register_song",
            "vibe_music_stream_begin",
            "vibe_music_stream_render",
            "vibe_music_stream_set_volume",
            "vibe_music_stream_position",
            "vibe_music_stream_song_samples",
            "vibe_music_stream_loop_samples",
            "vibe_music_stream_loop_count",
            "vibe_music_render_pcm",
        ):
            with self.subTest(token=token):
                self.assertIn(token, music_h)

        for token in (
            "render_mus_pass",
            "VIBE_MUSIC_MUS_EVENT_SCORE_END",
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
            "stream_song_samples",
            "stream_loop_samples",
            "stream_loop_count",
            "stream_sequence",
            "stats->score_end_count",
            "stats->invalid_event_count",
        ):
            with self.subTest(token=token):
                self.assertIn(token, music_c)

    def test_music_docs_describe_architecture_and_fallbacks(self):
        music_doc = (ROOT / "docs" / "audio.md").read_text()

        for token in (
            "MUS parser",
            "Standard MIDI format 0",
            "deterministic unsigned 8-bit PCM",
            "VIBE_AUDIO_MIXER_START",
            "VIBE_AUDIO_MIXER_UPDATE",
            "stateful stream cursor",
            "streamed music chunks",
            "deferred to the normal tic/frame/sound update pump",
            "larger streamed chunks",
            "non-looping songs stop at their parsed song end",
            "zero-duration songs do not become silent looping streams",
            "MUS event type 6",
            "event type 5",
            "unterminated MUS variable-length delays",
            "grouped MUS events",
            "pitch bend",
            "program changes",
            "pan, expression, sustain",
            "separate from normal Doom SFX",
            "musicrend=",
            "renderer provenance",
            "PC speaker fallback",
            "SB16",
        ):
            with self.subTest(token=token):
                self.assertIn(token, music_doc)


if __name__ == "__main__":
    unittest.main()
