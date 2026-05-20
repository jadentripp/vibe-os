import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class AudioContractTests(unittest.TestCase):
    def test_doom_platform_submits_raw_sfx_descriptors(self):
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()

        for source in (
            "typedef struct vibe_audio_sfx_desc",
            "const unsigned char* samples;",
            "unsigned long length;",
            "unsigned long volume;",
            "unsigned long separation;",
            "unsigned long pitch;",
            "unsigned long sound_id;",
            "unsigned long flags;",
            "unsigned long sample_rate;",
            "VIBE_AUDIO_FLAG_LOOP",
            "VIBE_AUDIO_FLAG_MUSIC",
            "VIBE_AUDIO_FLAG_WAD_SFX",
            "VIBE_AUDIO_IS_PLAYING",
            "VIBE_AUDIO_BUFFERED_BYTES",
            "VIBE_AUDIO_MUSIC_PULL_STATE",
            "VIBE_AUDIO_MUSIC_STREAM_PUSH",
            "VIBE_AUDIO_MUSIC_STREAM_PULL",
        ):
            self.assertIn(source, header)

        for source in (
            "#include \"z_zone.h\"",
            "vibe_audio_sfx_desc_t desc;",
            "sfxinfo_t* sfx = &S_sfx[id];",
            "sfx->data = W_CacheLumpNum(sfx->lumpnum, PU_STATIC);",
            "lump_length = W_LumpLength(sfx->lumpnum);",
            "cache_sfx_samples(id, sfx, &sample_length, &sample_rate, &sample_flags);",
            "Z_Malloc(padded_length, PU_STATIC, 0);",
            "memset(samples + raw_length, 128, padded_length - raw_length);",
            "flags |= VIBE_AUDIO_FLAG_WAD_SFX;",
            "desc.samples = samples;",
            "desc.length = sample_length;",
            "desc.volume = (unsigned long)(vol & 0xff);",
            "desc.separation = (unsigned long)(sep & 0xff);",
            "desc.pitch = (unsigned long)(pitch & 0xff);",
            "desc.sound_id = (unsigned long)id;",
            "desc.flags = sample_flags;",
            "desc.sample_rate = sample_rate;",
            "(unsigned long)&desc",
            "VIBE_AUDIO_START_SFX",
            "VIBE_AUDIO_UPDATE_SFX",
            "VIBE_AUDIO_IS_PLAYING",
            "VIBE_AUDIO_MUSIC_PULL_STATE",
        ):
            self.assertIn(source, platform)

    def test_kernel_mixes_sfx_into_sb16_dma_buffer(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "AUDIO_SFX_DESC_SAMPLES equ 0",
            "AUDIO_SFX_DESC_LENGTH equ 4",
            "AUDIO_SFX_DESC_VOLUME equ 8",
            "AUDIO_SFX_DESC_SEPARATION equ 12",
            "AUDIO_SFX_DESC_PITCH equ 16",
            "AUDIO_SFX_DESC_SOUND_ID equ 20",
            "AUDIO_SFX_DESC_FLAGS equ 24",
            "AUDIO_SFX_DESC_SAMPLE_RATE equ 28",
            "AUDIO_SFX_DESC_BYTES equ 32",
            "AUDIO_FLAG_WAD_SFX equ 0x00000004",
            "audio_mix_sfx_descriptor:",
            "call user_range_validate",
            "cmp ebx, SB16_DMA_BUFFER_BYTES",
            "mov edi, sb16_dma_buffer",
            "add edi, [sb16_dma_write_pos]",
            "sub eax, 128",
            "imul eax, ebp",
            "sar eax, 7",
            "inc dword [sb16_mix_clip_count]",
            "inc dword [sb16_mix_wrap_count]",
            "inc dword [sb16_mix_overwrite_count]",
            "inc dword [sb16_sfx_mix_count]",
            "add [sb16_sfx_mix_bytes], eax",
            "add [sb16_sfx_output_bytes], eax",
            "inc dword [sb16_sfx_dma_mix_count]",
            "add [sb16_sfx_dma_mix_bytes], eax",
            "inc dword [sb16_sfx_wad_start_count]",
            "sb16_sfx_last_rate dd 0",
            "sb16_sfx_dma_mix_count dd 0",
            "sb16_sfx_dma_mix_bytes dd 0",
            "inc dword [sb16_mix_underrun_count]",
            "smoke_sfxmix_text db \" sfxmix=\"",
            "smoke_sfxq_text db \" sfxq=\"",
            "smoke_sfxbytes_text db \" sfxbytes=\"",
            "smoke_sfxdma_text db \" sfxdma=\"",
            "smoke_sfxsrc_text db \" sfxsrc=\"",
            "smoke_sfxlast_text db \" sfxlast=\"",
        ):
            self.assertIn(source, kernel)

    def test_sb16_irq_ack_refill_and_ring_status_are_smoke_visible(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "SB16_DSP_READ_STATUS equ SB16_BASE + 0x0e",
            "SB16_DSP_ACK16 equ SB16_BASE + 0x0f",
            "irq_audio:",
            "inc dword [sb16_irq_count]",
            "inc dword [sb16_irq_ack8_count]",
            "inc dword [sb16_irq_ack16_count]",
            "inc dword [sb16_irq_refill_count]",
            "xor dword [sb16_irq_half_index], 1",
            "sb16_irq_ack8_count dd 0",
            "sb16_irq_ack16_count dd 0",
            "sb16_irq_refill_count dd 0",
            "sb16_irq_half_index dd 0",
            "sb16_mix_wrap_count dd 0",
            "sb16_mix_overwrite_count dd 0",
            "smoke_audioirq_text db \" audioirq=\"",
            "smoke_audioack8_text db \" ack8=\"",
            "smoke_audioack16_text db \" ack16=\"",
            "smoke_audiorefill_text db \" refill=\"",
            "smoke_audiohalf_text db \" half=\"",
            "smoke_mixwrap_text db \" mixwrap=\"",
            "smoke_mixover_text db \" mixover=\"",
            "smoke_mixunder_text db \" mixunder=\"",
        ):
            self.assertIn(source, kernel)

    def test_active_sfx_voice_table_and_irq_refill_are_tracked(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "AUDIO_MAX_SFX_VOICES equ 8",
            "AUDIO_PITCH_STEP_NORMAL equ 0x00010000",
            "sb16_voice_active times AUDIO_MAX_SFX_VOICES db 0",
            "sb16_voice_handles times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_samples times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_lengths times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_positions times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_volumes times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_steps times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_left_volumes times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_right_volumes times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_started_at times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_flags times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_loop_counts times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_pending_samples times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_voice_pending_lengths times AUDIO_MAX_SFX_VOICES dd 0",
            "sb16_active_sfx_voice_count dd 0",
            "audio_register_sfx_voice:",
            "audio_stop_sfx_voice:",
            "audio_update_sfx_voice:",
            ".audio_is_playing:",
            "sb16_refill_active_half:",
            "sb16_find_steal_voice:",
            "sb16_pitch_to_step:",
            "sb16_compute_pan_from_args:",
            "call audio_register_sfx_voice",
            "call audio_stop_sfx_voice",
            "call audio_update_sfx_voice",
            "call sb16_find_voice_by_handle",
            "call sb16_refill_active_half",
            "mov [sb16_voice_handles + ebx * 4], eax",
            "mov [sb16_voice_steps + ebx * 4], eax",
            "mov [sb16_voice_left_volumes + ebx * 4], eax",
            "mov [sb16_voice_right_volumes + ebx * 4], eax",
            "mov [sb16_voice_started_at + ebx * 4], eax",
            "mov [sb16_voice_positions + ebx * 4], eax",
            "mov byte [sb16_voice_active + ebx], 0",
            "inc dword [sb16_voice_refill_count]",
            "inc dword [sb16_voice_finished_count]",
            "smoke_audiovoices_text db \" voices=\"",
            "smoke_sfxvoices_text db \" sfxvoices=\"",
        ):
            self.assertIn(source, kernel)

    def test_sfx_playback_uses_stereo_pan_pitch_and_bounded_steals(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "SB16_DSP_SET_OUTPUT_RATE equ 0x41",
            "SB16_DSP_8BIT_AUTO_OUT equ 0xc6",
            "SB16_DSP_MODE_UNSIGNED_STEREO equ 0x20",
            "mov al, SB16_SAMPLE_RATE_HIGH",
            "mov al, SB16_SAMPLE_RATE_LOW",
            "mov al, SB16_DSP_MODE_UNSIGNED_STEREO",
            "call sb16_find_steal_voice",
            "inc dword [sb16_voice_steal_count]",
            "inc dword [sb16_voice_age_counter]",
            "shl eax, 9",
            "shl eax, 11",
            "shr edx, 16",
            "add [sb16_mix_source_pos], eax",
            "mov [edi + 1], al",
            "imul ebx, ebx",
            "sub eax, 257",
            "mov [sb16_pan_left_arg], edx",
            "mov [sb16_pan_right_arg], edx",
            "inc dword [sb16_pitch_clamp_count]",
            "inc dword [sb16_pan_clamp_count]",
            "test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC",
            ".fallback_next:",
        ):
            self.assertIn(source, kernel)

    def test_audio_smoke_status_covers_mixer_safety_counters(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()

        for source in (
            "smoke_mixclip_text db \" mixclip=\"",
            "smoke_voicesteal_text db \" steal=\"",
            "smoke_pitchclamp_text db \" pitchclamp=\"",
            "smoke_panclamp_text db \" panclamp=\"",
            "smoke_sfxvoices_text db \" sfxvoices=\"",
            "smoke_musicvoices_text db \" musicvoices=\"",
            "smoke_musicmix_text db \" musicmix=\"",
            "smoke_musicloop_text db \" musicloop=\"",
            "smoke_musicpos_text db \" musicpos=\"",
            "smoke_musicbuf_text db \" musicbuf=\"",
            "smoke_musicunder_text db \" musicunder=\"",
            "smoke_musicdrops_text db \" musicdrops=\"",
            "smoke_musicstream_text db \" musicstream=\"",
            "smoke_musicpull_text db \" musicpull=\"",
            "smoke_sfxq_text db \" sfxq=\"",
            "smoke_sfxbytes_text db \" sfxbytes=\"",
            "smoke_sfxdma_text db \" sfxdma=\"",
            "smoke_sfxsrc_text db \" sfxsrc=\"",
            "smoke_sfxlast_text db \" sfxlast=\"",
            "smoke_sb16ver_text db \" sb16=\"",
            "smoke_dmaprog_text db \" dma=\"",
            "smoke_play_text db \" play=\"",
            "smoke_voiceq_text db \" voiceq=\"",
            "smoke_musicq_text db \" musicq=\"",
            "mov edx, [sb16_mix_clip_count]",
            "mov edx, [sb16_voice_steal_count]",
            "mov edx, [sb16_pitch_clamp_count]",
            "mov edx, [sb16_pan_clamp_count]",
            "mov edx, [sb16_active_sfx_voice_count]",
            "mov edx, [sb16_active_music_voice_count]",
            "mov edx, [sb16_music_mix_count]",
            "mov edx, [sb16_music_loop_count]",
            "mov edx, [sb16_music_stream_pos_bytes]",
            "mov edx, [sb16_music_stream_buffer_bytes]",
            "mov edx, [sb16_music_stream_under_count]",
            "mov edx, [sb16_music_stream_drop_count]",
            "mov eax, [sb16_music_stream_mode]",
            "mov edx, [sb16_music_pull_request_count]",
            "mov edx, [sb16_music_pull_refill_count]",
            "mov edx, [sb16_sfx_voice_start_count]",
            "mov edx, [sb16_sfx_submit_bytes]",
            "mov edx, [sb16_sfx_dma_mix_count]",
            "mov edx, [sb16_sfx_dma_mix_bytes]",
            "mov edx, [sb16_sfx_wad_start_count]",
            "mov edx, [sb16_sfx_last_rate]",
            "mov edx, [sb16_dma_program_count]",
            "mov edx, [sb16_playback_start_count]",
            "mov edx, [sb16_voice_start_count]",
            "mov edx, [sb16_music_start_count]",
        ):
            self.assertIn(source, kernel)

        for source in (
            'grep -q "sfxmix="',
            'grep -q "sfxq="',
            'grep -q "sfxbytes="',
            'grep -q "sfxdma="',
            'grep -q "sfxsrc="',
            'grep -q "sfxlast="',
            'grep -q "voices="',
            'grep -q "sfxvoices="',
            'grep -q "audioirq="',
            'grep -q "mixclip="',
            'grep -q "steal="',
            'grep -q "pitchclamp="',
            'grep -q "panclamp="',
            'grep -q "musicvoices="',
            'grep -q "musicmix="',
            'grep -q "musicloop="',
            'grep -q "musicpos="',
            'grep -q "musicbuf="',
            'grep -q "musicunder="',
            'grep -q "musicdrops="',
            'grep -q "musicstream="',
            'grep -q "musicpull="',
            'grep -q "sb16="',
            'grep -q "dma="',
            'grep -q "play="',
            'grep -q "voiceq="',
            'grep -q "musicq="',
        ):
            self.assertIn(source, makefile)

    def test_music_carrier_voices_loop_and_share_sfx_mixer(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()

        for source in (
            "AUDIO_FLAG_LOOP equ 0x00000001",
            "AUDIO_FLAG_MUSIC equ 0x00000002",
            "AUDIO_CMD_IS_PLAYING equ 6",
            "AUDIO_CMD_BUFFERED_BYTES equ 7",
            "AUDIO_MUSIC_HANDLE_BASE equ 0x4d550000",
            "or dword [audio_sfx_flags_arg], AUDIO_FLAG_MUSIC",
            ".refresh_stream_window:",
            "sb16_music_promote_pending_window:",
            ".maybe_promote_pending:",
            "mov [sb16_voice_samples + ebx * 4], eax",
            "mov [sb16_voice_lengths + ebx * 4], eax",
            "mov [sb16_voice_pending_samples + ebx * 4], eax",
            "mov [sb16_voice_pending_lengths + ebx * 4], eax",
            "mov dword [sb16_voice_positions + ebx * 4], 0",
            "test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_LOOP",
            "inc dword [sb16_voice_loop_counts + ebx * 4]",
            "inc dword [sb16_music_loop_count]",
            "inc dword [sb16_music_mix_count]",
            "add [sb16_music_mix_bytes], eax",
            ".count_sfx_mix:",
            "sb16_active_music_voice_count dd 0",
            "sb16_music_start_count dd 0",
            "sb16_music_stop_count dd 0",
            "sb16_music_stream_pos_bytes dd 0",
            "sb16_music_stream_buffer_bytes dd 0",
            "sb16_music_stream_under_count dd 0",
            "sb16_music_stream_drop_count dd 0",
            "sb16_music_stream_mode dd AUDIO_MUSIC_STREAM_NONE",
            "sb16_music_pull_request_count dd 0",
            "sb16_music_pull_refill_count dd 0",
            "AUDIO_MUSIC_PULL_LOW_WATER_BYTES equ 24576",
            "sb16_note_music_pull_request:",
            "sb16_mark_music_pull_refill:",
            ".audio_buffered_bytes:",
            ".audio_music_pull_state:",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for source in (
            "desc.flags = VIBE_AUDIO_FLAG_MUSIC;",
            "static unsigned char music_pcm[2][VIBE_MUSIC_STREAM_BYTES];",
            "VIBE_MUSIC_DEFAULT_SAMPLE_RATE) / 16)",
            "vibe_music_stream_begin(",
            "vibe_music_stream_render(",
            "vibe_music_audio_handle(handle)",
            "VIBE_AUDIO_START_SFX",
            "VIBE_AUDIO_UPDATE_SFX",
            "VIBE_AUDIO_MUSIC_PULL_STATE",
            "current_music_pull_seen",
            "pump_music_stream",
            "report_doom_init_status(VIBE_DOOM_INIT_TIC);\n    pump_music_stream();",
            "report_doom_init_status(VIBE_DOOM_INIT_FRAME);\n    pump_music_stream();",
        ):
            with self.subTest(source=source):
                self.assertIn(source, platform)

    def test_audio_contract_stays_host_only(self):
        makefile = (ROOT / "Makefile").read_text()
        audio_test = (ROOT / "tests" / "host" / "test_audio_contract.py").read_text()

        self.assertIn("ALLOW_LOCAL_VM ?= 0", makefile)
        self.assertNotIn("qemu" + "-system", audio_test.lower())
        self.assertNotIn("run_smoke" + "_qemu", audio_test)

    def test_audio_doc_tracks_current_gaps(self):
        audio_doc = (ROOT / "docs" / "audio.md").read_text()

        self.assertIn("vibe_audio_sfx_desc_t", audio_doc)
        self.assertIn("interleaved unsigned 8-bit stereo", audio_doc)
        self.assertIn("Doom's original squared pan law", audio_doc)
        self.assertIn("16.16 source position", audio_doc)
        self.assertIn("oldest non-music active voice", audio_doc)
        self.assertIn("audioirq=", audio_doc)
        self.assertIn("voices=", audio_doc)
        self.assertIn("sfxvoices=", audio_doc)
        self.assertIn("sfxq=", audio_doc)
        self.assertIn("sfxbytes=", audio_doc)
        self.assertIn("sfxdma=", audio_doc)
        self.assertIn("sfxsrc=", audio_doc)
        self.assertIn("sfxlast=", audio_doc)
        self.assertIn("sfxmix=` counts only normal Doom SFX voices", audio_doc)
        self.assertIn("VIBE_AUDIO_IS_PLAYING", audio_doc)
        self.assertIn("VIBE_AUDIO_MUSIC_PULL_STATE", audio_doc)
        self.assertIn("pending music window", audio_doc)
        self.assertIn("mixwrap", audio_doc)
        self.assertIn("mixover", audio_doc)
        self.assertIn("mixclip", audio_doc)
        self.assertIn("pitchclamp", audio_doc)
        self.assertIn("musicvoices", audio_doc)
        self.assertIn("musicmix", audio_doc)
        self.assertIn("musicloop", audio_doc)
        self.assertIn("musicpos", audio_doc)
        self.assertIn("musicbuf", audio_doc)
        self.assertIn("musicunder", audio_doc)
        self.assertIn("musicdrops", audio_doc)
        self.assertIn("musicstream=PULL", audio_doc)
        self.assertIn("musicpull=", audio_doc)
        self.assertIn("active voice table", audio_doc)
        self.assertIn("Doom music:", audio_doc)
        self.assertIn("deterministic unsigned 8-bit PCM", audio_doc)
        self.assertIn("VIBE_AUDIO_START_SFX", audio_doc)
        self.assertIn("VIBE_AUDIO_UPDATE_SFX", audio_doc)
        self.assertIn("streamed music chunks", audio_doc)
        self.assertIn("PC speaker fallback", audio_doc)
        self.assertNotIn("MUS/MIDI synthesis is not implemented", audio_doc)
        self.assertNotIn("Doom SFX are not mixed into PCM yet", audio_doc)


if __name__ == "__main__":
    unittest.main()
