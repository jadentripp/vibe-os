import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class AudioContractTests(unittest.TestCase):
    def test_public_audio_header_exposes_reusable_mixer_and_pcm_contract(self):
        abi_source = r"""
            #include "vibe_os.h"

            #define CHECK(name, expr) typedef char check_##name[(expr) ? 1 : -1]

            CHECK(voice_desc_size, sizeof(vibe_audio_voice_desc_t) == VIBE_AUDIO_VOICE_DESC_BYTES);
            CHECK(voice_samples, __builtin_offsetof(vibe_audio_voice_desc_t, samples) == 0);
            CHECK(voice_length, __builtin_offsetof(vibe_audio_voice_desc_t, length) == 4);
            CHECK(voice_flags, __builtin_offsetof(vibe_audio_voice_desc_t, flags) == 24);
            CHECK(voice_sample_rate, __builtin_offsetof(vibe_audio_voice_desc_t, sample_rate) == 28);
            CHECK(voice_music_format, __builtin_offsetof(vibe_audio_voice_desc_t, music_format) == 32);
            CHECK(voice_music_stream_start, __builtin_offsetof(vibe_audio_voice_desc_t, music_stream_start) == 52);
            CHECK(voice_music_stream_end, __builtin_offsetof(vibe_audio_voice_desc_t, music_stream_end) == 56);
            CHECK(voice_music_stream_loop_count,
                __builtin_offsetof(vibe_audio_voice_desc_t, music_stream_loop_count) == 60);

            CHECK(device_info_size, sizeof(vibe_audio_device_info_t) == VIBE_AUDIO_DEVICE_INFO_BYTES);
            CHECK(device_kind, __builtin_offsetof(vibe_audio_device_info_t, device_kind) == 0);
            CHECK(device_status, __builtin_offsetof(vibe_audio_device_info_t, status) == 4);
            CHECK(device_caps, __builtin_offsetof(vibe_audio_device_info_t, capabilities) == 28);
            CHECK(device_starts,
                __builtin_offsetof(vibe_audio_device_info_t, playback_start_count) == 44);

            CHECK(pcm_ring_size, sizeof(vibe_audio_pcm_ring_info_t) == VIBE_AUDIO_PCM_RING_INFO_BYTES);
            CHECK(pcm_format, __builtin_offsetof(vibe_audio_pcm_ring_info_t, format) == 0);
            CHECK(pcm_write_offset, __builtin_offsetof(vibe_audio_pcm_ring_info_t, write_offset) == 20);
            CHECK(pcm_clip_count, __builtin_offsetof(vibe_audio_pcm_ring_info_t, clip_count) == 44);

            CHECK(stream_info_size, sizeof(vibe_audio_stream_info_t) == VIBE_AUDIO_STREAM_INFO_BYTES);
            CHECK(stream_mode, __builtin_offsetof(vibe_audio_stream_info_t, stream_mode) == 0);
            CHECK(stream_handle, __builtin_offsetof(vibe_audio_stream_info_t, handle) == 8);
            CHECK(stream_pending,
                __builtin_offsetof(vibe_audio_stream_info_t, pending_pull_requests) == 20);
            CHECK(stream_position, __builtin_offsetof(vibe_audio_stream_info_t, position_bytes) == 44);

            CHECK(device_status_ready, VIBE_AUDIO_DEVICE_STATUS_READY == 1);
            CHECK(device_status_absent, VIBE_AUDIO_DEVICE_STATUS_ABSENT == 2);
            CHECK(generic_commands,
                VIBE_AUDIO_MIXER_START == VIBE_AUDIO_START_SFX
                && VIBE_AUDIO_MIXER_UPDATE == VIBE_AUDIO_UPDATE_SFX
                && VIBE_AUDIO_PCM_PULL_STATE == VIBE_AUDIO_MUSIC_PULL_STATE
                && VIBE_AUDIO_STREAM_INFO == 11);
        """
        abi = subprocess.run(
            [
                "clang",
                "-target",
                "i386-unknown-none-elf",
                "-std=gnu89",
                "-ffreestanding",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-I",
                str(ROOT / "doom_port" / "include"),
                "-x",
                "c",
                "-fsyntax-only",
                "-",
            ],
            cwd=ROOT,
            input=abi_source,
            capture_output=True,
            text=True,
        )
        self.assertEqual(abi.returncode, 0, abi.stderr)

        runtime_source = r"""
            #include "vibe_os.h"

            int main(void)
            {
                unsigned char samples[4] = { 128, 130, 126, 128 };
                vibe_audio_voice_desc_t voice;
                vibe_audio_device_info_t device = { 0 };
                vibe_audio_pcm_ring_info_t ring = { 0 };
                vibe_audio_stream_info_t stream = { 0 };

                vibe_audio_voice_desc_init(&voice, samples, 4, 11025, 96, 128, 128);
                if (voice.samples != samples
                    || voice.length != 4
                    || voice.sample_rate != 11025
                    || voice.volume != 96
                    || voice.separation != 128
                    || voice.pitch != 128
                    || voice.flags != 0
                    || voice.music_format != 0
                    || voice.music_stream_loop_count != 0)
                    return 1;

                device.device_kind = VIBE_AUDIO_DEVICE_SB16;
                device.status = VIBE_AUDIO_DEVICE_STATUS_READY;
                device.capabilities = VIBE_AUDIO_CAP_PCM_RING
                    | VIBE_AUDIO_CAP_MIXER_VOICES
                    | VIBE_AUDIO_CAP_PULL_STREAM;
                if (!vibe_audio_device_is_ready(&device))
                    return 2;
                if (!vibe_audio_device_has_capability(
                        &device,
                        VIBE_AUDIO_CAP_PCM_RING | VIBE_AUDIO_CAP_PULL_STREAM))
                    return 3;
                if (vibe_audio_device_has_capability(&device, VIBE_AUDIO_CAP_SB16_DMA))
                    return 4;

                ring.format = VIBE_AUDIO_FORMAT_U8_STEREO;
                ring.channels = 2;
                if (!vibe_audio_pcm_ring_is_u8_stereo(&ring))
                    return 5;
                ring.channels = 1;
                if (vibe_audio_pcm_ring_is_u8_stereo(&ring))
                    return 6;
                stream.stream_mode = VIBE_AUDIO_MUSIC_STREAM_PULL;
                stream.flags = VIBE_AUDIO_STREAM_FLAG_PULL
                    | VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING;
                stream.handle = 0x4d550001;
                stream.pull_request_count = 3;
                stream.pull_refill_count = 2;
                stream.pending_pull_requests = 1;
                if (!vibe_audio_stream_uses_pull(&stream))
                    return 7;
                if (!vibe_audio_stream_needs_refill(&stream))
                    return 8;
                if (!vibe_audio_stream_matches_handle(&stream, 0x4d550001))
                    return 9;
                if (!vibe_audio_stream_refills_are_ordered(&stream))
                    return 10;
                if (!vibe_audio_stream_has_new_refill_request(&stream, 2))
                    return 11;
                stream.pending_pull_requests = 0;
                if (vibe_audio_stream_needs_refill(&stream))
                    return 12;
                if (vibe_audio_stream_has_new_refill_request(&stream, 2))
                    return 13;
                stream.pull_refill_count = 4;
                if (vibe_audio_stream_refills_are_ordered(&stream))
                    return 14;

                vibe_audio_voice_desc_init(0, 0, 0, 0, 0, 0, 0);
                return 0;
            }
        """
        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "vibe_audio_contract"
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
                input=runtime_source,
                capture_output=True,
                text=True,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            run = subprocess.run([str(binary)], cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(run.returncode, 0, run.stdout + run.stderr)

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
            "unsigned long music_format;",
            "unsigned long music_note_events;",
            "unsigned long music_control_events;",
            "unsigned long music_active_voice_peak;",
            "unsigned long music_emitted_samples;",
            "VIBE_AUDIO_FLAG_LOOP",
            "VIBE_AUDIO_FLAG_MUSIC",
            "VIBE_AUDIO_FLAG_WAD_SFX",
            "VIBE_AUDIO_FLAG_STREAM_FINAL",
            "VIBE_AUDIO_DEVICE_SB16",
            "VIBE_AUDIO_FORMAT_U8_STEREO",
            "VIBE_AUDIO_CAP_PCM_RING",
            "VIBE_AUDIO_CAP_MIXER_VOICES",
            "VIBE_AUDIO_DEVICE_INFO",
            "VIBE_AUDIO_PCM_RING_INFO",
            "VIBE_AUDIO_STREAM_INFO",
            "Pull-stream service snapshot",
            "vibe_audio_device_info_t",
            "vibe_audio_pcm_ring_info_t",
            "vibe_audio_stream_info_t",
            "vibe_audio_stream_matches_handle",
            "vibe_audio_stream_refills_are_ordered",
            "vibe_audio_stream_has_new_refill_request",
            "typedef vibe_audio_sfx_desc_t vibe_audio_voice_desc_t;",
            "VIBE_AUDIO_MIXER_START",
            "VIBE_AUDIO_MIXER_STOP",
            "VIBE_AUDIO_MIXER_UPDATE",
            "VIBE_AUDIO_MIXER_IS_PLAYING",
            "VIBE_AUDIO_PCM_BUFFERED_BYTES",
            "VIBE_AUDIO_PCM_PULL_STATE",
            "VIBE_AUDIO_IS_PLAYING",
            "VIBE_AUDIO_BUFFERED_BYTES",
            "VIBE_AUDIO_MUSIC_PULL_STATE",
            "VIBE_AUDIO_MUSIC_STREAM_PUSH",
            "VIBE_AUDIO_MUSIC_STREAM_PULL",
        ):
            self.assertIn(source, header)

        for source in (
            "#include \"z_zone.h\"",
            "vibe_audio_voice_desc_t desc;",
            "sfxinfo_t* sfx = &S_sfx[id];",
            "sfx->data = W_CacheLumpNum(sfx->lumpnum, PU_STATIC);",
            "lump_length = W_LumpLength(sfx->lumpnum);",
            "cache_sfx_samples(id, sfx, &sample_length, &sample_rate, &sample_flags);",
            "Z_Malloc(padded_length, PU_STATIC, 0);",
            "memset(samples + raw_length, 128, padded_length - raw_length);",
            "flags |= VIBE_AUDIO_FLAG_WAD_SFX;",
            "desc.flags |= VIBE_AUDIO_FLAG_STREAM_FINAL;",
            "desc.samples = samples;",
            "desc.length = sample_length;",
            "desc.volume = (unsigned long)(vol & 0xff);",
            "desc.separation = (unsigned long)(sep & 0xff);",
            "desc.pitch = (unsigned long)(pitch & 0xff);",
            "desc.sound_id = (unsigned long)id;",
            "desc.flags = sample_flags;",
            "desc.sample_rate = sample_rate;",
            "(unsigned long)&desc",
            "VIBE_AUDIO_MIXER_START",
            "VIBE_AUDIO_MIXER_UPDATE",
            "VIBE_AUDIO_MIXER_IS_PLAYING",
            "VIBE_AUDIO_PCM_PULL_STATE",
        ):
            self.assertIn(source, platform)

    def test_kernel_exposes_generic_audio_device_and_pcm_ring_contract(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()

        for source in (
            "AUDIO_CMD_DEVICE_INFO equ 9",
            "AUDIO_CMD_PCM_RING_INFO equ 10",
            "AUDIO_CMD_STREAM_INFO equ 11",
            "AUDIO_CMD_MIXER_START equ AUDIO_CMD_START_SFX",
            "AUDIO_CMD_PCM_PULL_STATE equ AUDIO_CMD_MUSIC_PULL_STATE",
            "AUDIO_DEVICE_SB16 equ 1",
            "AUDIO_PCM_FORMAT_U8_STEREO equ 1",
            "AUDIO_CAP_PCM_RING equ 0x00000001",
            "AUDIO_CAP_MIXER_VOICES equ 0x00000002",
            "AUDIO_CAP_PULL_STREAM equ 0x00000004",
            "AUDIO_CAP_SB16_DMA equ 0x00000008",
            "AUDIO_DEVICE_INFO_KIND equ 0",
            "AUDIO_DEVICE_INFO_BYTES equ 48",
            "AUDIO_PCM_RING_INFO_FORMAT equ 0",
            "AUDIO_PCM_RING_INFO_BYTES equ 48",
            "AUDIO_STREAM_INFO_MODE equ 0",
            "AUDIO_STREAM_INFO_BYTES equ 48",
            "AUDIO_STREAM_FLAG_REFILL_PENDING equ 0x00000002",
            "audio_write_device_info:",
            "audio_write_pcm_ring_info:",
            "audio_write_stream_info:",
            "cmp ebx, AUDIO_CMD_DEVICE_INFO",
            "cmp ebx, AUDIO_CMD_PCM_RING_INFO",
            "cmp ebx, AUDIO_CMD_STREAM_INFO",
            "call audio_write_device_info",
            "call audio_write_pcm_ring_info",
            "call audio_write_stream_info",
            "mov dword [edi + AUDIO_DEVICE_INFO_KIND], AUDIO_DEVICE_SB16",
            "mov dword [edi + AUDIO_PCM_RING_INFO_FORMAT], AUDIO_PCM_FORMAT_U8_STEREO",
            "mov eax, [sb16_dma_buffer_size]",
            "mov eax, [sb16_dma_write_pos]",
            "mov [edi + AUDIO_STREAM_INFO_PULL_REQUEST_COUNT], eax",
            "mov dword [edi + AUDIO_STREAM_INFO_LOW_WATER_BYTES], AUDIO_MUSIC_PULL_LOW_WATER_BYTES",
            "smoke_audiodev_text db \" adev=\"",
            "smoke_pcm_text db \" pcm=\"",
            "smoke_pcmbuf_text db \" pcmbuf=\"",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for source in (
            'grep -q "adev="',
            'grep -q "pcm="',
            'grep -q "pcmbuf="',
        ):
            self.assertIn(source, makefile)

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
            "AUDIO_SFX_DESC_MUSIC_FORMAT equ 32",
            "AUDIO_SFX_DESC_MUSIC_NOTE_EVENTS equ 36",
            "AUDIO_SFX_DESC_MUSIC_CONTROL_EVENTS equ 40",
            "AUDIO_SFX_DESC_MUSIC_ACTIVE_VOICE_PEAK equ 44",
            "AUDIO_SFX_DESC_MUSIC_EMITTED_SAMPLES equ 48",
            "AUDIO_SFX_DESC_BYTES equ 64",
            "AUDIO_FLAG_WAD_SFX equ 0x00000004",
            "AUDIO_FLAG_STREAM_FINAL equ 0x00000008",
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
            "test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_STREAM_FINAL",
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
            "smoke_musicrend_text db \" musicrend=\"",
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
            "mov edx, [sb16_music_render_format]",
            "mov edx, [sb16_music_render_chunk_count]",
            "mov edx, [sb16_music_render_note_count]",
            "mov edx, [sb16_music_render_event_count]",
            "mov edx, [sb16_music_render_active_peak]",
            "mov edx, [sb16_music_render_sample_count]",
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
            'grep -q "musicrend="',
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
            "AUDIO_CMD_DEVICE_INFO equ 9",
            "AUDIO_CMD_PCM_RING_INFO equ 10",
            "AUDIO_CMD_STREAM_INFO equ 11",
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
            "cmp [sb16_music_stream_buffer_bytes], eax",
            "sub [sb16_music_stream_buffer_bytes], eax",
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
            "sb16_record_music_render_stats:",
            "sb16_music_render_format dd 0",
            "sb16_music_render_chunk_count dd 0",
            "sb16_music_render_note_count dd 0",
            "sb16_music_render_event_count dd 0",
            "sb16_music_render_active_peak dd 0",
            "sb16_music_render_sample_count dd 0",
            "musicrend=",
            "AUDIO_MUSIC_PULL_LOW_WATER_BYTES equ 24576",
            "sb16_note_music_pull_request:",
            "sb16_mark_music_pull_refill:",
            ".audio_buffered_bytes:",
            ".audio_music_pull_state:",
            ".audio_stream_info:",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for source in (
            "desc.flags = VIBE_AUDIO_FLAG_MUSIC;",
            "static unsigned char music_pcm[2][VIBE_MUSIC_STREAM_BYTES];",
            "VIBE_MUSIC_DEFAULT_SAMPLE_RATE) / 16)",
            "vibe_music_stream_begin(",
            "vibe_music_stream_render(",
            "desc.music_format = stats.format;",
            "desc.music_note_events = stats.note_on_count + stats.note_off_count;",
            "desc.music_emitted_samples = stats.emitted_samples;",
            "vibe_music_audio_handle(handle)",
            "VIBE_AUDIO_MIXER_START",
            "VIBE_AUDIO_MIXER_UPDATE",
            "VIBE_AUDIO_PCM_PULL_STATE",
            "VIBE_AUDIO_STREAM_INFO",
            "current_music_pull_seen",
            "current_music_refill_seen",
            "query_music_stream_info",
            "vibe_audio_stream_has_new_refill_request",
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
        self.assertIn("vibe_audio_device_info_t", audio_doc)
        self.assertIn("vibe_audio_pcm_ring_info_t", audio_doc)
        self.assertIn("vibe_audio_stream_info_t", audio_doc)
        self.assertIn("Reusable audio syscall surface", audio_doc)
        self.assertIn("vibe_audio_voice_desc_init()", audio_doc)
        self.assertIn("VIBE_AUDIO_VOICE_DESC_BYTES == 64", audio_doc)
        self.assertIn("fixed\n  48-byte records", audio_doc)
        self.assertIn("does\n  not make Doom WAD audio", audio_doc)
        self.assertIn("adev=", audio_doc)
        self.assertIn("pcm=", audio_doc)
        self.assertIn("pcmbuf=", audio_doc)
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
        self.assertIn("VIBE_AUDIO_MIXER_IS_PLAYING", audio_doc)
        self.assertIn("VIBE_AUDIO_PCM_PULL_STATE", audio_doc)
        self.assertIn("VIBE_AUDIO_STREAM_INFO", audio_doc)
        self.assertIn("device/ring/stream/mixer", audio_doc)
        self.assertIn("os_audio_contract", audio_doc)
        self.assertIn("pcmbuf=` active-half status to match the IRQ `half=` field", audio_doc)
        self.assertIn("status-only OS audio subsystem lane", audio_doc)
        self.assertIn("device/ring/stream/mixer status coherence", audio_doc)
        self.assertIn("playability_cadence", audio_doc)
        self.assertIn("OS audio cadence", audio_doc)
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
        self.assertIn("VIBE_AUDIO_MIXER_START", audio_doc)
        self.assertIn("VIBE_AUDIO_MIXER_UPDATE", audio_doc)
        self.assertIn("streamed music chunks", audio_doc)
        self.assertIn("PC speaker fallback", audio_doc)
        self.assertIn("Aggregate audible-output proof (not human listener approval)", audio_doc)
        self.assertIn("proof_contracts", audio_doc)
        self.assertIn("human-listened quality is a separate lane", audio_doc)
        self.assertIn("future hardware-paced mixer/refill playback ABI", audio_doc)
        self.assertIn("Audio quality and music legitimacy roadmap as OS contracts", audio_doc)
        self.assertNotIn("MUS/MIDI synthesis is not implemented", audio_doc)
        self.assertNotIn("Doom SFX are not mixed into PCM yet", audio_doc)

    def test_audio_checkers_pin_proof_lanes_without_vm_audio(self):
        audible_checker = (ROOT / "tools" / "check_audible_audio_proof.py").read_text()
        continuity_checker = (ROOT / "tools" / "check_audio_continuity_proof.py").read_text()
        music_doc = (ROOT / "docs" / "audio.md").read_text()

        for source in (
            "aggregate-machine-audible-output",
            "status-only-os-audio-subsystem",
            "os_audio_subsystem",
            "os_audio_contract",
            "pcmbuf= active half must match half= IRQ phase",
            "human-listened-quality",
            "not-proven-by-this-manifest",
            "future-hardware-paced-mixer-refill-playback",
            "current_payload_owner",
            "doom_port/music.c",
            "current_service_command",
            "VIBE_AUDIO_MIXER_UPDATE",
            "first-class kernel-owned music ring or mixer/refill stream ABI",
            "human-listened quality and future hardware-paced mixer/refill playback",
        ):
            with self.subTest(source=source):
                self.assertIn(source, audible_checker)

        for source in (
            "CURRENT_MUSIC_PAYLOAD_OWNER",
            "CURRENT_MUSIC_SERVICE_COMMAND",
            "FUTURE_HARDWARE_MIXER_REFILL_PLAYBACK",
            "build_os_audio_contract",
            "human-listened quality and future hardware-paced mixer/refill playback remain separate lanes",
        ):
            with self.subTest(source=source):
                self.assertIn(source, continuity_checker)

        for source in (
            "Music legitimacy roadmap as OS contracts",
            "os_audio_contract",
            "Current parser legitimacy",
            "Current stream legitimacy",
            "Current OS audio subsystem legitimacy",
            "Current audible legitimacy",
            "Future playback legitimacy",
            "Human-listened quality is a separate lane",
            "future hardware-paced mixer/refill playback ABI",
        ):
            with self.subTest(source=source):
                self.assertIn(source, music_doc)


if __name__ == "__main__":
    unittest.main()
