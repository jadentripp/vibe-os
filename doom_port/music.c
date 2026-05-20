#include <stddef.h>

#include "music.h"

#define VIBE_MUSIC_MAX_CHANNELS 16
#define VIBE_MUSIC_MAX_VOICES 16
#define VIBE_MUSIC_MUS_TICKS_PER_SECOND 140u
#define VIBE_MUSIC_DEFAULT_MIDI_DIVISION 96u
#define VIBE_MUSIC_DEFAULT_TEMPO_US 500000u
#define VIBE_MUSIC_MAX_LOOP_PASSES 256u

typedef struct vibe_music_song {
    void* data;
    int format;
    int used;
    int stream_active;
    int stream_looping;
    unsigned long stream_sample_rate;
    unsigned long stream_volume;
    unsigned long stream_position;
} vibe_music_song_t;

typedef struct vibe_music_voice {
    unsigned char active;
    unsigned char channel;
    unsigned char note;
    unsigned char volume;
    unsigned int phase;
    unsigned int step;
} vibe_music_voice_t;

typedef struct vibe_music_synth {
    vibe_music_voice_t voices[VIBE_MUSIC_MAX_VOICES];
    unsigned char channel_volume[VIBE_MUSIC_MAX_CHANNELS];
    unsigned long sample_rate;
    unsigned long output_volume;
} vibe_music_synth_t;

typedef struct vibe_music_render_sink {
    unsigned char* out;
    unsigned long out_len;
    unsigned long skip_remaining;
    unsigned long cursor;
    unsigned long written;
} vibe_music_render_sink_t;

static vibe_music_song_t vibe_music_songs[VIBE_MUSIC_MAX_SONGS];

static const unsigned int vibe_music_note_freq_x16[128] = {
    131u, 139u, 147u, 156u, 165u, 175u, 185u, 196u,
    208u, 220u, 233u, 247u, 262u, 277u, 294u, 311u,
    330u, 349u, 370u, 392u, 415u, 440u, 466u, 494u,
    523u, 554u, 587u, 622u, 659u, 698u, 740u, 784u,
    831u, 880u, 932u, 988u, 1047u, 1109u, 1175u, 1245u,
    1319u, 1397u, 1480u, 1568u, 1661u, 1760u, 1865u, 1976u,
    2093u, 2217u, 2349u, 2489u, 2637u, 2794u, 2960u, 3136u,
    3322u, 3520u, 3729u, 3951u, 4186u, 4435u, 4699u, 4978u,
    5274u, 5588u, 5920u, 6272u, 6645u, 7040u, 7459u, 7902u,
    8372u, 8870u, 9397u, 9956u, 10548u, 11175u, 11840u, 12544u,
    13290u, 14080u, 14917u, 15804u, 16744u, 17740u, 18795u, 19912u,
    21096u, 22351u, 23680u, 25088u, 26580u, 28160u, 29834u, 31609u,
    33488u, 35479u, 37589u, 39824u, 42192u, 44701u, 47359u, 50175u,
    53159u, 56320u, 59669u, 63217u, 66976u, 70959u, 75178u, 79649u,
    84385u, 89402u, 94719u, 100351u, 106318u, 112640u, 119338u, 126434u,
    133952u, 141918u, 150356u, 159297u, 168769u, 178805u, 189437u, 200702u
};

static unsigned short read_le16(const unsigned char* data)
{
    return (unsigned short)data[0] | (unsigned short)((unsigned short)data[1] << 8);
}

static unsigned short read_be16(const unsigned char* data)
{
    return (unsigned short)((unsigned short)data[0] << 8) | (unsigned short)data[1];
}

static unsigned long read_be24(const unsigned char* data)
{
    return ((unsigned long)data[0] << 16) | ((unsigned long)data[1] << 8) | (unsigned long)data[2];
}

static unsigned long read_be32(const unsigned char* data)
{
    return ((unsigned long)data[0] << 24)
        | ((unsigned long)data[1] << 16)
        | ((unsigned long)data[2] << 8)
        | (unsigned long)data[3];
}

static int has_tag(const unsigned char* data, char a, char b, char c, char d)
{
    return data[0] == (unsigned char)a
        && data[1] == (unsigned char)b
        && data[2] == (unsigned char)c
        && data[3] == (unsigned char)d;
}

static void clear_output(unsigned char* out, unsigned long out_len)
{
    unsigned long i;

    for (i = 0; i < out_len; ++i)
        out[i] = 128;
}

static void reset_stats(vibe_music_render_stats_t* stats, int format)
{
    if (!stats)
        return;

    stats->format = (unsigned long)format;
    stats->note_on_count = 0;
    stats->note_off_count = 0;
    stats->controller_count = 0;
    stats->tempo_count = 0;
    stats->loop_count = 0;
    stats->clipped_samples = 0;
    stats->emitted_samples = 0;
    stats->stream_start_sample = 0;
    stats->stream_end_sample = 0;
}

static unsigned long capped_add(unsigned long left, unsigned long right, unsigned long cap)
{
    if (left >= cap)
        return cap;
    if (right > cap - left)
        return cap;
    return left + right;
}

static unsigned long mus_delay_to_samples(unsigned long delay, unsigned long sample_rate)
{
    unsigned long samples_per_tick;

    samples_per_tick = sample_rate / VIBE_MUSIC_MUS_TICKS_PER_SECOND;
    if (!samples_per_tick && delay)
        samples_per_tick = 1;
    if (samples_per_tick && delay > (unsigned long)-1 / samples_per_tick)
        return (unsigned long)-1;
    return delay * samples_per_tick;
}

static unsigned long midi_delta_to_samples(
    unsigned long delta,
    unsigned long sample_rate,
    unsigned long division,
    unsigned long tempo_us)
{
    unsigned long tempo_ms;
    unsigned long denom;
    unsigned long samples_per_tick;

    if (!delta)
        return 0;

    if (!division || (division & 0x8000u))
        division = VIBE_MUSIC_DEFAULT_MIDI_DIVISION;

    tempo_ms = tempo_us / 1000u;
    if (!tempo_ms)
        tempo_ms = 1;

    denom = division * 1000u;
    samples_per_tick = (tempo_ms * sample_rate) / denom;
    if (!samples_per_tick)
        samples_per_tick = 1;
    if (delta > (unsigned long)-1 / samples_per_tick)
        return (unsigned long)-1;
    return delta * samples_per_tick;
}

static unsigned int note_to_step(unsigned int note, unsigned long sample_rate)
{
    unsigned long step;

    if (note > 127u)
        note = 127u;
    if (!sample_rate)
        sample_rate = VIBE_MUSIC_DEFAULT_SAMPLE_RATE;

    step = ((unsigned long)vibe_music_note_freq_x16[note] * 4096u) / sample_rate;
    if (!step)
        step = 1;
    if (step > 0xffffu)
        step = 0xffffu;
    return (unsigned int)step;
}

static void synth_init(vibe_music_synth_t* synth, unsigned long sample_rate, unsigned long volume)
{
    unsigned long i;

    for (i = 0; i < VIBE_MUSIC_MAX_VOICES; ++i) {
        synth->voices[i].active = 0;
        synth->voices[i].channel = 0;
        synth->voices[i].note = 0;
        synth->voices[i].volume = 0;
        synth->voices[i].phase = 0;
        synth->voices[i].step = 0;
    }

    for (i = 0; i < VIBE_MUSIC_MAX_CHANNELS; ++i)
        synth->channel_volume[i] = 100;

    synth->sample_rate = sample_rate ? sample_rate : VIBE_MUSIC_DEFAULT_SAMPLE_RATE;
    synth->output_volume = volume > 127u ? 127u : volume;
}

static void synth_all_notes_off(vibe_music_synth_t* synth)
{
    unsigned long i;

    for (i = 0; i < VIBE_MUSIC_MAX_VOICES; ++i)
        synth->voices[i].active = 0;
}

static void synth_channel_notes_off(vibe_music_synth_t* synth, unsigned int channel)
{
    unsigned long i;

    for (i = 0; i < VIBE_MUSIC_MAX_VOICES; ++i)
        if (synth->voices[i].active && synth->voices[i].channel == (unsigned char)channel)
            synth->voices[i].active = 0;
}

static void synth_note_off(
    vibe_music_synth_t* synth,
    unsigned int channel,
    unsigned int note,
    vibe_music_render_stats_t* stats)
{
    unsigned long i;

    for (i = 0; i < VIBE_MUSIC_MAX_VOICES; ++i)
        if (synth->voices[i].active
            && synth->voices[i].channel == (unsigned char)channel
            && synth->voices[i].note == (unsigned char)note)
            synth->voices[i].active = 0;

    if (stats)
        ++stats->note_off_count;
}

static unsigned long synth_find_voice(vibe_music_synth_t* synth, unsigned int channel, unsigned int note)
{
    unsigned long i;
    unsigned long quietest;

    for (i = 0; i < VIBE_MUSIC_MAX_VOICES; ++i)
        if (synth->voices[i].active
            && synth->voices[i].channel == (unsigned char)channel
            && synth->voices[i].note == (unsigned char)note)
            return i;

    for (i = 0; i < VIBE_MUSIC_MAX_VOICES; ++i)
        if (!synth->voices[i].active)
            return i;

    quietest = 0;
    for (i = 1; i < VIBE_MUSIC_MAX_VOICES; ++i)
        if (synth->voices[i].volume < synth->voices[quietest].volume)
            quietest = i;
    return quietest;
}

static void synth_note_on(
    vibe_music_synth_t* synth,
    unsigned int channel,
    unsigned int note,
    unsigned int volume,
    vibe_music_render_stats_t* stats)
{
    unsigned long slot;
    unsigned long scaled_volume;

    if (channel >= VIBE_MUSIC_MAX_CHANNELS)
        channel = VIBE_MUSIC_MAX_CHANNELS - 1;
    if (note > 127u)
        note = 127u;
    if (volume > 127u)
        volume = 127u;

    if (!volume) {
        synth_note_off(synth, channel, note, stats);
        return;
    }

    scaled_volume = (volume * synth->channel_volume[channel]) / 127u;
    if (!scaled_volume)
        scaled_volume = 1;

    slot = synth_find_voice(synth, channel, note);
    synth->voices[slot].active = 1;
    synth->voices[slot].channel = (unsigned char)channel;
    synth->voices[slot].note = (unsigned char)note;
    synth->voices[slot].volume = (unsigned char)scaled_volume;
    synth->voices[slot].phase = 0;
    synth->voices[slot].step = note_to_step(note, synth->sample_rate);

    if (stats)
        ++stats->note_on_count;
}

static void synth_render_until(
    vibe_music_synth_t* synth,
    vibe_music_render_sink_t* sink,
    unsigned long target,
    vibe_music_render_stats_t* stats)
{
    unsigned long pos;
    unsigned long i;

    pos = sink->cursor;
    while (pos < target && sink->written < sink->out_len) {
        long mix;
        unsigned long active;
        int sample;

        mix = 0;
        active = 0;

        for (i = 0; i < VIBE_MUSIC_MAX_VOICES; ++i) {
            vibe_music_voice_t* voice;
            unsigned long amp;

            voice = &synth->voices[i];
            if (!voice->active)
                continue;

            amp = ((unsigned long)voice->volume * synth->output_volume) / 127u;
            if (amp > 127u)
                amp = 127u;

            mix += (voice->phase & 0x8000u) ? (long)amp : -(long)amp;
            voice->phase = (voice->phase + voice->step) & 0xffffu;
            ++active;
        }

        if (active)
            mix /= active < 4u ? 4 : (long)active;

        sample = (int)(128 + mix);
        if (sample < 0) {
            sample = 0;
            if (stats)
                ++stats->clipped_samples;
        } else if (sample > 255) {
            sample = 255;
            if (stats)
                ++stats->clipped_samples;
        }

        if (sink->skip_remaining) {
            --sink->skip_remaining;
        } else {
            sink->out[sink->written++] = (unsigned char)sample;
        }
        ++pos;
    }

    sink->cursor = pos;
}

static int read_midi_var(
    const unsigned char* data,
    unsigned long end,
    unsigned long* pos,
    unsigned long* out)
{
    unsigned long value;
    unsigned int i;

    value = 0;
    for (i = 0; i < 4u; ++i) {
        unsigned char b;

        if (*pos >= end)
            return 0;

        b = data[*pos];
        *pos += 1;
        value = (value << 7) | (unsigned long)(b & 0x7fu);
        if (!(b & 0x80u)) {
            *out = value;
            return 1;
        }
    }

    return 0;
}

static unsigned long read_mus_delay(const unsigned char* data, unsigned long end, unsigned long* pos)
{
    unsigned long value;
    unsigned int i;

    value = 0;
    for (i = 0; i < 4u; ++i) {
        unsigned char b;

        if (*pos >= end)
            return value;

        b = data[*pos];
        *pos += 1;
        value = (value << 7) | (unsigned long)(b & 0x7fu);
        if (!(b & 0x80u))
            break;
    }

    return value;
}

static int render_mus_pass(
    const unsigned char* data,
    vibe_music_synth_t* synth,
    vibe_music_render_sink_t* sink,
    vibe_music_render_stats_t* stats)
{
    unsigned long score_len;
    unsigned long score_start;
    unsigned long pos;
    unsigned long end;

    score_len = read_le16(data + 4);
    score_start = read_le16(data + 6);
    if (score_start < 16u || !score_len)
        return 0;

    pos = score_start;
    end = score_start + score_len;

    while (pos < end && sink->written < sink->out_len) {
        unsigned char descriptor;
        unsigned int event_type;
        unsigned int channel;
        unsigned int last_in_group;

        descriptor = data[pos++];
        event_type = (descriptor >> 4) & 0x07u;
        channel = descriptor & 0x0fu;
        last_in_group = descriptor & 0x80u;

        if (event_type == 0u) {
            unsigned int note;

            if (pos >= end)
                return 0;
            note = data[pos++] & 0x7fu;
            synth_note_off(synth, channel, note, stats);
        } else if (event_type == 1u) {
            unsigned int note;
            unsigned int volume;
            unsigned char note_byte;

            if (pos >= end)
                return 0;
            note_byte = data[pos++];
            note = note_byte & 0x7fu;
            if (note_byte & 0x80u) {
                if (pos >= end)
                    return 0;
                synth->channel_volume[channel] = data[pos++] & 0x7fu;
            }
            volume = synth->channel_volume[channel];
            synth_note_on(synth, channel, note, volume, stats);
        } else if (event_type == 2u) {
            if (pos >= end)
                return 0;
            ++pos;
        } else if (event_type == 3u) {
            unsigned int system_event;

            if (pos >= end)
                return 0;
            system_event = data[pos++] & 0x7fu;
            if (system_event == 10u)
                synth_channel_notes_off(synth, channel);
            else if (system_event == 11u)
                synth_all_notes_off(synth);
            if (stats)
                ++stats->controller_count;
        } else if (event_type == 4u) {
            unsigned int controller;
            unsigned int value;

            if (end - pos < 2u)
                return 0;
            controller = data[pos++] & 0x7fu;
            value = data[pos++] & 0x7fu;
            if (controller == 3u || controller == 5u)
                synth->channel_volume[channel] = (unsigned char)value;
            else if (controller == 10u)
                synth_channel_notes_off(synth, channel);
            else if (controller == 11u)
                synth_all_notes_off(synth);
            if (stats)
                ++stats->controller_count;
        } else if (event_type == 5u) {
            synth_all_notes_off(synth);
            return 1;
        } else {
            return 0;
        }

        if (last_in_group) {
            unsigned long delay;
            unsigned long samples;

            delay = read_mus_delay(data, end, &pos);
            samples = mus_delay_to_samples(delay, synth->sample_rate);
            synth_render_until(synth, sink, capped_add(sink->cursor, samples, (unsigned long)-1), stats);
        }
    }

    return 1;
}

static int render_midi_pass(
    const unsigned char* data,
    vibe_music_synth_t* synth,
    vibe_music_render_sink_t* sink,
    vibe_music_render_stats_t* stats)
{
    const unsigned char* track;
    unsigned long header_len;
    unsigned long track_len;
    unsigned long pos;
    unsigned long end;
    unsigned long tempo_us;
    unsigned int ntrks;
    unsigned int division;
    unsigned int running_status;

    header_len = read_be32(data + 4);
    if (header_len < 6u || header_len > 64u)
        return 0;

    ntrks = read_be16(data + 10);
    division = read_be16(data + 12);
    if (!ntrks)
        return 0;

    track = data + 8u + header_len;
    if (!has_tag(track, 'M', 'T', 'r', 'k'))
        return 0;

    track_len = read_be32(track + 4);
    pos = 0;
    end = track_len;
    track += 8;
    tempo_us = VIBE_MUSIC_DEFAULT_TEMPO_US;
    running_status = 0;

    while (pos < end && sink->written < sink->out_len) {
        unsigned long delta;
        unsigned long samples;
        unsigned int status;
        unsigned int data1;
        unsigned int have_data1;

        if (!read_midi_var(track, end, &pos, &delta))
            return 0;

        samples = midi_delta_to_samples(delta, synth->sample_rate, division, tempo_us);
        synth_render_until(synth, sink, capped_add(sink->cursor, samples, (unsigned long)-1), stats);

        if (pos >= end)
            return 0;

        status = track[pos++];
        data1 = 0;
        have_data1 = 0;
        if (status < 0x80u) {
            if (!running_status)
                return 0;
            data1 = status;
            have_data1 = 1;
            status = running_status;
        } else if (status < 0xf0u) {
            running_status = status;
        }

        if (status == 0xffu) {
            unsigned int meta_type;
            unsigned long length;

            if (pos >= end)
                return 0;
            meta_type = track[pos++];
            if (!read_midi_var(track, end, &pos, &length))
                return 0;
            if (length > end - pos)
                return 0;

            if (meta_type == 0x2fu) {
                synth_all_notes_off(synth);
                return 1;
            }
            if (meta_type == 0x51u && length == 3u) {
                tempo_us = read_be24(track + pos);
                if (!tempo_us)
                    tempo_us = VIBE_MUSIC_DEFAULT_TEMPO_US;
                if (stats)
                    ++stats->tempo_count;
            }
            pos += length;
        } else if (status == 0xf0u || status == 0xf7u) {
            unsigned long length;

            if (!read_midi_var(track, end, &pos, &length))
                return 0;
            if (length > end - pos)
                return 0;
            pos += length;
        } else {
            unsigned int kind;
            unsigned int channel;
            unsigned int data2;

            kind = status & 0xf0u;
            channel = status & 0x0fu;

            if (kind == 0xc0u || kind == 0xd0u) {
                if (!have_data1) {
                    if (pos >= end)
                        return 0;
                    data1 = track[pos++];
                }
                (void)data1;
            } else {
                if (!have_data1) {
                    if (pos >= end)
                        return 0;
                    data1 = track[pos++];
                }
                if (pos >= end)
                    return 0;
                data2 = track[pos++];

                if (kind == 0x80u) {
                    synth_note_off(synth, channel, data1, stats);
                } else if (kind == 0x90u) {
                    synth_note_on(synth, channel, data1, data2, stats);
                } else if (kind == 0xb0u) {
                    if (data1 == 7u || data1 == 11u)
                        synth->channel_volume[channel] = (unsigned char)(data2 & 0x7fu);
                    else if (data1 == 120u || data1 == 123u)
                        synth_channel_notes_off(synth, channel);
                    if (stats)
                        ++stats->controller_count;
                }
            }
        }
    }

    return 1;
}

void vibe_music_init(void)
{
    unsigned long i;

    for (i = 0; i < VIBE_MUSIC_MAX_SONGS; ++i) {
        vibe_music_songs[i].data = 0;
        vibe_music_songs[i].format = VIBE_MUSIC_FORMAT_NONE;
        vibe_music_songs[i].used = 0;
        vibe_music_songs[i].stream_active = 0;
        vibe_music_songs[i].stream_looping = 0;
        vibe_music_songs[i].stream_sample_rate = VIBE_MUSIC_DEFAULT_SAMPLE_RATE;
        vibe_music_songs[i].stream_volume = 127;
        vibe_music_songs[i].stream_position = 0;
    }
}

int vibe_music_detect(const void* data)
{
    const unsigned char* bytes;

    if (!data)
        return VIBE_MUSIC_FORMAT_NONE;

    bytes = (const unsigned char*)data;
    if (has_tag(bytes, 'M', 'U', 'S', 0x1a))
        return VIBE_MUSIC_FORMAT_MUS;
    if (has_tag(bytes, 'M', 'T', 'h', 'd'))
        return VIBE_MUSIC_FORMAT_MIDI;
    return VIBE_MUSIC_FORMAT_NONE;
}

int vibe_music_register_song(void* data)
{
    unsigned long i;
    int format;

    format = vibe_music_detect(data);
    if (format == VIBE_MUSIC_FORMAT_NONE)
        return 0;

    for (i = 0; i < VIBE_MUSIC_MAX_SONGS; ++i) {
        if (!vibe_music_songs[i].used) {
            vibe_music_songs[i].data = data;
            vibe_music_songs[i].format = format;
            vibe_music_songs[i].used = 1;
            vibe_music_songs[i].stream_active = 0;
            vibe_music_songs[i].stream_looping = 0;
            vibe_music_songs[i].stream_sample_rate = VIBE_MUSIC_DEFAULT_SAMPLE_RATE;
            vibe_music_songs[i].stream_volume = 127;
            vibe_music_songs[i].stream_position = 0;
            return (int)i + 1;
        }
    }

    return 0;
}

void vibe_music_unregister_song(int handle)
{
    unsigned long index;

    if (handle <= 0)
        return;
    index = (unsigned long)(handle - 1);
    if (index >= VIBE_MUSIC_MAX_SONGS)
        return;

    vibe_music_songs[index].data = 0;
    vibe_music_songs[index].format = VIBE_MUSIC_FORMAT_NONE;
    vibe_music_songs[index].used = 0;
    vibe_music_songs[index].stream_active = 0;
    vibe_music_songs[index].stream_looping = 0;
    vibe_music_songs[index].stream_sample_rate = VIBE_MUSIC_DEFAULT_SAMPLE_RATE;
    vibe_music_songs[index].stream_volume = 127;
    vibe_music_songs[index].stream_position = 0;
}

static unsigned long render_pcm_window(
    const void* data,
    unsigned char* out,
    unsigned long out_len,
    unsigned long start_sample,
    unsigned long sample_rate,
    unsigned long volume,
    int looping,
    vibe_music_render_stats_t* stats)
{
    vibe_music_synth_t synth;
    vibe_music_render_sink_t sink;
    unsigned long passes;
    int format;
    int ok;

    format = vibe_music_detect(data);
    reset_stats(stats, format);

    if (!out || !out_len)
        return 0;

    clear_output(out, out_len);

    if (format == VIBE_MUSIC_FORMAT_NONE)
        return 0;

    synth_init(&synth, sample_rate, volume);
    sink.out = out;
    sink.out_len = out_len;
    sink.skip_remaining = start_sample;
    sink.cursor = 0;
    sink.written = 0;
    passes = 0;
    ok = 1;

    do {
        unsigned long before;

        before = sink.cursor;
        if (format == VIBE_MUSIC_FORMAT_MUS)
            ok = render_mus_pass((const unsigned char*)data, &synth, &sink, stats);
        else
            ok = render_midi_pass((const unsigned char*)data, &synth, &sink, stats);

        if (!ok) {
            clear_output(out, out_len);
            if (stats)
                stats->emitted_samples = 0;
            return 0;
        }

        if (sink.written >= out_len)
            break;
        if (!looping || sink.cursor == before)
            break;

        if (stats)
            ++stats->loop_count;
        synth_init(&synth, sample_rate, volume);
        ++passes;
    } while (passes < VIBE_MUSIC_MAX_LOOP_PASSES);

    if (sink.written < out_len)
        synth_render_until(&synth, &sink, sink.cursor + (out_len - sink.written), stats);

    if (stats) {
        stats->emitted_samples = sink.written;
        stats->stream_start_sample = start_sample;
        stats->stream_end_sample = start_sample + sink.written;
    }

    return sink.written;
}

unsigned long vibe_music_render_pcm(
    const void* data,
    unsigned char* out,
    unsigned long out_len,
    unsigned long sample_rate,
    unsigned long volume,
    int looping,
    vibe_music_render_stats_t* stats)
{
    return render_pcm_window(data, out, out_len, 0, sample_rate, volume, looping, stats);
}

void vibe_music_stream_begin(
    int handle,
    unsigned long sample_rate,
    unsigned long volume,
    int looping)
{
    unsigned long index;

    if (handle <= 0)
        return;
    index = (unsigned long)(handle - 1);
    if (index >= VIBE_MUSIC_MAX_SONGS || !vibe_music_songs[index].used)
        return;

    vibe_music_songs[index].stream_active = 1;
    vibe_music_songs[index].stream_looping = looping;
    vibe_music_songs[index].stream_sample_rate = sample_rate ? sample_rate : VIBE_MUSIC_DEFAULT_SAMPLE_RATE;
    vibe_music_songs[index].stream_volume = volume > 127u ? 127u : volume;
    vibe_music_songs[index].stream_position = 0;
}

void vibe_music_stream_stop(int handle)
{
    unsigned long index;

    if (handle <= 0)
        return;
    index = (unsigned long)(handle - 1);
    if (index >= VIBE_MUSIC_MAX_SONGS)
        return;
    vibe_music_songs[index].stream_active = 0;
}

unsigned long vibe_music_stream_position(int handle)
{
    unsigned long index;

    if (handle <= 0)
        return 0;
    index = (unsigned long)(handle - 1);
    if (index >= VIBE_MUSIC_MAX_SONGS || !vibe_music_songs[index].used)
        return 0;
    return vibe_music_songs[index].stream_position;
}

unsigned long vibe_music_stream_render(
    int handle,
    unsigned char* out,
    unsigned long out_len,
    vibe_music_render_stats_t* stats)
{
    unsigned long index;
    unsigned long rendered;

    if (handle <= 0)
        return 0;
    index = (unsigned long)(handle - 1);
    if (index >= VIBE_MUSIC_MAX_SONGS || !vibe_music_songs[index].used)
        return 0;
    if (!vibe_music_songs[index].stream_active)
        return 0;

    rendered = render_pcm_window(
        vibe_music_songs[index].data,
        out,
        out_len,
        vibe_music_songs[index].stream_position,
        vibe_music_songs[index].stream_sample_rate,
        vibe_music_songs[index].stream_volume,
        vibe_music_songs[index].stream_looping,
        stats);
    vibe_music_songs[index].stream_position += rendered;
    return rendered;
}

unsigned long vibe_music_render_song(
    int handle,
    unsigned char* out,
    unsigned long out_len,
    unsigned long sample_rate,
    unsigned long volume,
    int looping,
    vibe_music_render_stats_t* stats)
{
    unsigned long index;

    if (handle <= 0)
        return 0;
    index = (unsigned long)(handle - 1);
    if (index >= VIBE_MUSIC_MAX_SONGS || !vibe_music_songs[index].used)
        return 0;

    return vibe_music_render_pcm(
        vibe_music_songs[index].data,
        out,
        out_len,
        sample_rate,
        volume,
        looping,
        stats);
}
