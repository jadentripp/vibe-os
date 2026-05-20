#ifndef VIBE_DOOM_PORT_MUSIC_H
#define VIBE_DOOM_PORT_MUSIC_H

#define VIBE_MUSIC_DEFAULT_SAMPLE_RATE 11025u
#define VIBE_MUSIC_RENDER_BYTES 65536u
#define VIBE_MUSIC_MAX_SONGS 8

enum {
    VIBE_MUSIC_FORMAT_NONE = 0,
    VIBE_MUSIC_FORMAT_MUS = 1,
    VIBE_MUSIC_FORMAT_MIDI = 2,
};

typedef struct vibe_music_render_stats {
    unsigned long format;
    unsigned long note_on_count;
    unsigned long note_off_count;
    unsigned long controller_count;
    unsigned long tempo_count;
    unsigned long clipped_samples;
    unsigned long emitted_samples;
} vibe_music_render_stats_t;

void vibe_music_init(void);
int vibe_music_detect(const void* data);
int vibe_music_register_song(void* data);
void vibe_music_unregister_song(int handle);
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
