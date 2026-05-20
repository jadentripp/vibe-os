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
        ):
            self.assertIn(source, header)

        for source in (
            "#include \"z_zone.h\"",
            "vibe_audio_sfx_desc_t desc;",
            "sfxinfo_t* sfx = &S_sfx[id];",
            "sfx->data = W_CacheLumpNum(sfx->lumpnum, PU_STATIC);",
            "lump_length = W_LumpLength(sfx->lumpnum);",
            "desc.samples = lump_data + 8;",
            "desc.length = (unsigned long)(lump_length - 8);",
            "desc.volume = (unsigned long)(vol & 0xff);",
            "desc.separation = (unsigned long)(sep & 0xff);",
            "desc.pitch = (unsigned long)(pitch & 0xff);",
            "desc.sound_id = (unsigned long)id;",
            "(unsigned long)&desc",
            "VIBE_AUDIO_START_SFX",
            "VIBE_AUDIO_UPDATE_SFX",
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
            "AUDIO_SFX_DESC_BYTES equ 24",
            "audio_mix_sfx_descriptor:",
            "call user_range_validate",
            "cmp ebx, SB16_DMA_BUFFER_BYTES",
            "mov edi, sb16_dma_buffer",
            "add edi, [sb16_dma_write_pos]",
            "sub eax, 128",
            "imul eax, ebp",
            "sar eax, 7",
            "inc dword [sb16_mix_clip_count]",
            "inc dword [sb16_sfx_mix_count]",
            "add [sb16_sfx_mix_bytes], eax",
            "inc dword [sb16_mix_underrun_count]",
            "smoke_sfxmix_text db \" sfxmix=\"",
        ):
            self.assertIn(source, kernel)

    def test_audio_doc_tracks_current_gaps(self):
        audio_doc = (ROOT / "docs" / "audio.md").read_text()

        self.assertIn("vibe_audio_sfx_desc_t", audio_doc)
        self.assertIn("deterministic mono mix", audio_doc)
        self.assertIn("MUS/MIDI synthesis is not implemented", audio_doc)
        self.assertNotIn("Doom SFX are not mixed into PCM yet", audio_doc)


if __name__ == "__main__":
    unittest.main()
