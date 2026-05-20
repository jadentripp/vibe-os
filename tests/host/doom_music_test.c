#include "../../doom_port/music.c"

static unsigned long count_non_silence(const unsigned char* data, unsigned long len)
{
    unsigned long i;
    unsigned long count;

    count = 0;
    for (i = 0; i < len; ++i)
        if (data[i] != 128)
            ++count;
    return count;
}

static int buffers_equal(const unsigned char* left, const unsigned char* right, unsigned long len)
{
    unsigned long i;

    for (i = 0; i < len; ++i)
        if (left[i] != right[i])
            return 0;
    return 1;
}

static unsigned long sum_abs_center(const unsigned char* data, unsigned long len)
{
    unsigned long i;
    unsigned long total;

    total = 0;
    for (i = 0; i < len; ++i) {
        if (data[i] >= 128)
            total += (unsigned long)(data[i] - 128);
        else
            total += (unsigned long)(128 - data[i]);
    }

    return total;
}

static int test_mus_fixture_renders_deterministic_pcm(void)
{
    static unsigned char mus_lump[] = {
        'M', 'U', 'S', 0x1a,
        8, 0,
        16, 0,
        1, 0,
        0, 0,
        0, 0,
        0, 0,
        0x90, 0xbc, 100, 20,
        0x80, 60, 4,
        0xd0
    };
    unsigned char pcm_a[4096];
    unsigned char pcm_b[4096];
    vibe_music_render_stats_t stats;
    unsigned long rendered;
    unsigned long rendered_again;

    if (vibe_music_detect(mus_lump) != VIBE_MUSIC_FORMAT_MUS)
        return 10;

    rendered = vibe_music_render_pcm(
        mus_lump,
        pcm_a,
        sizeof(pcm_a),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        127,
        1,
        &stats);
    rendered_again = vibe_music_render_pcm(
        mus_lump,
        pcm_b,
        sizeof(pcm_b),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        127,
        1,
        0);

    if (rendered != sizeof(pcm_a) || rendered_again != sizeof(pcm_b))
        return 11;
    if (!buffers_equal(pcm_a, pcm_b, sizeof(pcm_a)))
        return 12;
    if (count_non_silence(pcm_a, sizeof(pcm_a)) < 1024)
        return 13;
    if (stats.format != VIBE_MUSIC_FORMAT_MUS)
        return 15;
    if (stats.note_on_count < 2 || stats.note_off_count < 2)
        return 16;
    if (stats.emitted_samples != sizeof(pcm_a))
        return 17;
    if (!stats.loop_count)
        return 18;

    return 0;
}

static int test_midi_fixture_renders_note_events(void)
{
    static unsigned char midi_lump[] = {
        'M', 'T', 'h', 'd',
        0, 0, 0, 6,
        0, 0,
        0, 1,
        0, 96,
        'M', 'T', 'r', 'k',
        0, 0, 0, 23,
        0x00, 0xff, 0x51, 0x03, 0x07, 0xa1, 0x20,
        0x00, 0xb0, 0x07, 0x64,
        0x00, 0x90, 0x3c, 0x64,
        0x18, 0x80, 0x3c, 0x00,
        0x00, 0xff, 0x2f, 0x00
    };
    unsigned char pcm[4096];
    vibe_music_render_stats_t stats;
    unsigned long rendered;

    if (vibe_music_detect(midi_lump) != VIBE_MUSIC_FORMAT_MIDI)
        return 20;

    rendered = vibe_music_render_pcm(
        midi_lump,
        pcm,
        sizeof(pcm),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        96,
        0,
        &stats);

    if (rendered != sizeof(pcm))
        return 21;
    if (count_non_silence(pcm, sizeof(pcm)) < 512)
        return 22;
    if (stats.format != VIBE_MUSIC_FORMAT_MIDI)
        return 23;
    if (stats.tempo_count != 1 || stats.controller_count != 1)
        return 24;
    if (stats.note_on_count != 1 || stats.note_off_count != 1)
        return 25;
    if (stats.loop_count != 0)
        return 26;

    return 0;
}

static int test_mus_fixture_handles_controller_pitch_sustain_and_percussion(void)
{
    static unsigned char mus_lump[] = {
        'M', 'U', 'S', 0x1a,
        34, 0,
        16, 0,
        1, 0,
        0, 0,
        0, 0,
        0, 0,
        0x40, 0, 41,
        0x40, 3, 100,
        0x40, 4, 96,
        0x40, 5, 80,
        0x40, 8, 127,
        0x20, 96,
        0x10, 0xbc, 110,
        0x9f, 0xa3, 90, 10,
        0x00, 60,
        0x8f, 35, 8,
        0xc0, 8, 0, 4,
        0xd0
    };
    unsigned char pcm[4096];
    vibe_music_render_stats_t stats;
    unsigned long rendered;

    rendered = vibe_music_render_pcm(
        mus_lump,
        pcm,
        sizeof(pcm),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        127,
        0,
        &stats);

    if (rendered != sizeof(pcm))
        return 60;
    if (count_non_silence(pcm, sizeof(pcm)) < 512)
        return 61;
    if (stats.program_count != 1 || stats.pan_count != 1 || stats.expression_count != 1)
        return 62;
    if (stats.sustain_count != 2 || stats.pitch_bend_count != 1)
        return 63;
    if (stats.note_on_count != 2 || stats.note_off_count != 2)
        return 64;
    if (stats.percussion_note_count != 1 || stats.active_voice_peak < 2)
        return 65;

    return 0;
}

static int test_midi_fixture_handles_running_status_and_richer_channel_state(void)
{
    static unsigned char midi_lump[] = {
        'M', 'T', 'h', 'd',
        0, 0, 0, 6,
        0, 0,
        0, 1,
        0, 96,
        'M', 'T', 'r', 'k',
        0, 0, 0, 49,
        0x00, 0xff, 0x51, 0x03, 0x07, 0xa1, 0x20,
        0x00, 0xc0, 0x28,
        0x00, 0xb0, 0x0a, 0x20,
        0x00, 0xb0, 0x0b, 0x60,
        0x00, 0xb0, 0x40, 0x7f,
        0x00, 0x90, 0x3c, 0x64,
        0x00, 0x3e, 0x60,
        0x18, 0xe0, 0x00, 0x50,
        0x18, 0x80, 0x3c, 0x00,
        0x00, 0xb0, 0x40, 0x00,
        0x00, 0x80, 0x3e, 0x00,
        0x00, 0xff, 0x2f, 0x00
    };
    unsigned char pcm[4096];
    vibe_music_render_stats_t stats;
    unsigned long rendered;

    rendered = vibe_music_render_pcm(
        midi_lump,
        pcm,
        sizeof(pcm),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        127,
        0,
        &stats);

    if (rendered != sizeof(pcm))
        return 70;
    if (count_non_silence(pcm, sizeof(pcm)) < 512)
        return 71;
    if (stats.tempo_count != 1 || stats.program_count != 1)
        return 72;
    if (stats.pan_count != 1 || stats.expression_count != 1)
        return 73;
    if (stats.sustain_count != 2 || stats.pitch_bend_count != 1)
        return 74;
    if (stats.note_on_count != 2 || stats.note_off_count != 2)
        return 75;
    if (stats.active_voice_peak < 2)
        return 76;

    return 0;
}

static int test_register_song_slots_and_invalid_silence(void)
{
    static unsigned char mus_lump[] = {
        'M', 'U', 'S', 0x1a,
        4, 0,
        16, 0,
        1, 0,
        0, 0,
        0, 0,
        0, 0,
        0x90, 0xbc, 90, 8
    };
    static unsigned char invalid_lump[] = {
        'N', 'O', 'P', 'E', 0, 0, 0, 0
    };
    unsigned char pcm[512];
    int handle;
    unsigned long rendered;

    vibe_music_init();
    handle = vibe_music_register_song(mus_lump);
    if (handle <= 0)
        return 30;

    rendered = vibe_music_render_song(
        handle,
        pcm,
        sizeof(pcm),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        127,
        0,
        0);
    if (rendered != sizeof(pcm))
        return 31;
    if (!count_non_silence(pcm, sizeof(pcm)))
        return 32;

    vibe_music_unregister_song(handle);
    if (vibe_music_render_song(handle, pcm, sizeof(pcm), VIBE_MUSIC_DEFAULT_SAMPLE_RATE, 127, 0, 0))
        return 33;

    pcm[0] = 1;
    rendered = vibe_music_render_pcm(
        invalid_lump,
        pcm,
        sizeof(pcm),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        127,
        0,
        0);
    if (rendered)
        return 34;
    if (count_non_silence(pcm, sizeof(pcm)))
        return 35;

    return 0;
}

static int test_streaming_chunks_advance_song_position(void)
{
    static unsigned char mus_lump[] = {
        'M', 'U', 'S', 0x1a,
        8, 0,
        16, 0,
        1, 0,
        0, 0,
        0, 0,
        0, 0,
        0x90, 0xbc, 100, 20,
        0x80, 60, 4,
        0xd0
    };
    unsigned char full[1024];
    unsigned char chunks[1024];
    vibe_music_render_stats_t stats;
    int handle;
    unsigned long rendered;

    vibe_music_init();
    handle = vibe_music_register_song(mus_lump);
    if (handle <= 0)
        return 40;

    rendered = vibe_music_render_pcm(
        mus_lump,
        full,
        sizeof(full),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        127,
        1,
        0);
    if (rendered != sizeof(full))
        return 41;

    vibe_music_stream_begin(handle, VIBE_MUSIC_DEFAULT_SAMPLE_RATE, 127, 1);
    if (vibe_music_stream_position(handle) != 0)
        return 42;

    rendered = vibe_music_stream_render(handle, chunks, 512, &stats);
    if (rendered != 512)
        return 43;
    if (stats.stream_start_sample != 0 || stats.stream_end_sample != 512)
        return 44;
    if (vibe_music_stream_position(handle) != 512)
        return 45;

    rendered = vibe_music_stream_render(handle, chunks + 512, 512, &stats);
    if (rendered != 512)
        return 46;
    if (stats.stream_start_sample != 512 || stats.stream_end_sample != 1024)
        return 47;
    if (vibe_music_stream_position(handle) != 1024)
        return 48;
    if (!buffers_equal(full, chunks, sizeof(full)))
        return 49;

    vibe_music_stream_stop(handle);
    if (vibe_music_stream_render(handle, chunks, 512, &stats))
        return 50;

    return 0;
}

static int test_streaming_volume_changes_affect_future_chunks(void)
{
    static unsigned char mus_lump[] = {
        'M', 'U', 'S', 0x1a,
        8, 0,
        16, 0,
        1, 0,
        0, 0,
        0, 0,
        0, 0,
        0x90, 0xbc, 120, 40,
        0x80, 60, 4,
        0xd0
    };
    unsigned char loud[512];
    unsigned char quiet[512];
    int handle;
    unsigned long loud_energy;
    unsigned long quiet_energy;

    vibe_music_init();
    handle = vibe_music_register_song(mus_lump);
    if (handle <= 0)
        return 80;

    vibe_music_stream_begin(handle, VIBE_MUSIC_DEFAULT_SAMPLE_RATE, 127, 1);
    if (vibe_music_stream_render(handle, loud, sizeof(loud), 0) != sizeof(loud))
        return 81;
    vibe_music_stream_set_volume(handle, 32);
    if (vibe_music_stream_render(handle, quiet, sizeof(quiet), 0) != sizeof(quiet))
        return 82;

    loud_energy = sum_abs_center(loud, sizeof(loud));
    quiet_energy = sum_abs_center(quiet, sizeof(quiet));
    if (!loud_energy || !quiet_energy)
        return 83;
    if (quiet_energy >= loud_energy)
        return 84;

    return 0;
}

int main(void)
{
    int result;

    result = test_mus_fixture_renders_deterministic_pcm();
    if (result)
        return result;

    result = test_midi_fixture_renders_note_events();
    if (result)
        return result;

    result = test_mus_fixture_handles_controller_pitch_sustain_and_percussion();
    if (result)
        return result;

    result = test_midi_fixture_handles_running_status_and_richer_channel_state();
    if (result)
        return result;

    result = test_register_song_slots_and_invalid_silence();
    if (result)
        return result;

    result = test_streaming_chunks_advance_song_position();
    if (result)
        return result;

    return test_streaming_volume_changes_affect_future_chunks();
}
