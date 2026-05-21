#ifndef VIBE_DOOM_PORT_MUSIC_H
#define VIBE_DOOM_PORT_MUSIC_H

#define VIBE_MUSIC_DEFAULT_SAMPLE_RATE 11025u
#define VIBE_MUSIC_RENDER_BYTES 65536u
#define VIBE_MUSIC_STREAM_BYTES 32768u
#define VIBE_MUSIC_MAX_SONGS 8

enum {
    VIBE_MUSIC_FORMAT_NONE = 0,
    VIBE_MUSIC_FORMAT_MUS = 1,
    VIBE_MUSIC_FORMAT_MIDI = 2,
};

enum {
    VIBE_MUSIC_STREAM_FLAG_ACTIVE = 0x00000001u,
    VIBE_MUSIC_STREAM_FLAG_LOOPING = 0x00000002u,
    VIBE_MUSIC_STREAM_FLAG_VALID_SONG = 0x00000004u,
};

typedef struct vibe_music_render_stats {
    unsigned long format;
    unsigned long note_on_count;
    unsigned long note_off_count;
    unsigned long controller_count;
    unsigned long program_count;
    unsigned long pan_count;
    unsigned long expression_count;
    unsigned long sustain_count;
    unsigned long pitch_bend_count;
    unsigned long percussion_note_count;
    unsigned long all_notes_off_count;
    unsigned long active_voice_peak;
    unsigned long tempo_count;
    unsigned long score_end_count;
    unsigned long invalid_event_count;
    unsigned long loop_count;
    unsigned long clipped_samples;
    unsigned long emitted_samples;
    unsigned long stream_start_sample;
    unsigned long stream_end_sample;
    unsigned long stream_song_samples;
    unsigned long stream_loop_samples;
    unsigned long stream_loop_count;
    unsigned long stream_chunk_index;
    unsigned long stream_chunk_bytes;
} vibe_music_render_stats_t;

typedef struct vibe_music_stream_snapshot {
    unsigned long format;
    unsigned long flags;
    unsigned long sample_rate;
    unsigned long volume;
    unsigned long position;
    unsigned long song_samples;
    unsigned long loop_samples;
    unsigned long loop_count;
    unsigned long chunk_index;
} vibe_music_stream_snapshot_t;

void vibe_music_init(void);
int vibe_music_detect(const void* data);
int vibe_music_register_song(void* data);
void vibe_music_unregister_song(int handle);
void vibe_music_stream_begin(
    int handle,
    unsigned long sample_rate,
    unsigned long volume,
    int looping);
void vibe_music_stream_stop(int handle);
void vibe_music_stream_set_volume(int handle, unsigned long volume);
unsigned long vibe_music_stream_position(int handle);
unsigned long vibe_music_stream_song_samples(int handle);
unsigned long vibe_music_stream_loop_samples(int handle);
unsigned long vibe_music_stream_loop_count(int handle);
int vibe_music_stream_snapshot(int handle, vibe_music_stream_snapshot_t* snapshot);
unsigned long vibe_music_stream_render(
    int handle,
    unsigned char* out,
    unsigned long out_len,
    vibe_music_render_stats_t* stats);
unsigned long vibe_music_render_song(
    int handle,
    unsigned char* out,
    unsigned long out_len,
    unsigned long sample_rate,
    unsigned long volume,
    int looping,
    vibe_music_render_stats_t* stats);
unsigned long vibe_music_render_pcm(
    const void* data,
    unsigned char* out,
    unsigned long out_len,
    unsigned long sample_rate,
    unsigned long volume,
    int looping,
    vibe_music_render_stats_t* stats);

#endif
