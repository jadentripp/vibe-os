#ifndef VIBE_DOOM_PORT_INPUT_H
#define VIBE_DOOM_PORT_INPUT_H

#include "vibe_os.h"

enum {
    VIBE_DOOM_INPUT_NONE = 0,
    VIBE_DOOM_INPUT_KEYDOWN = 1,
    VIBE_DOOM_INPUT_KEYUP = 2,
    VIBE_DOOM_INPUT_MOUSE = 3,
};

enum {
    VIBE_DOOM_KEY_RIGHTARROW = 0xae,
    VIBE_DOOM_KEY_LEFTARROW = 0xac,
    VIBE_DOOM_KEY_UPARROW = 0xad,
    VIBE_DOOM_KEY_DOWNARROW = 0xaf,
    VIBE_DOOM_KEY_ESCAPE = 27,
    VIBE_DOOM_KEY_ENTER = 13,
    VIBE_DOOM_KEY_TAB = 9,
    VIBE_DOOM_KEY_F1 = 0xbb,
    VIBE_DOOM_KEY_F2 = 0xbc,
    VIBE_DOOM_KEY_F3 = 0xbd,
    VIBE_DOOM_KEY_F4 = 0xbe,
    VIBE_DOOM_KEY_F5 = 0xbf,
    VIBE_DOOM_KEY_F6 = 0xc0,
    VIBE_DOOM_KEY_F7 = 0xc1,
    VIBE_DOOM_KEY_F8 = 0xc2,
    VIBE_DOOM_KEY_F9 = 0xc3,
    VIBE_DOOM_KEY_F10 = 0xc4,
    VIBE_DOOM_KEY_F11 = 0xd7,
    VIBE_DOOM_KEY_F12 = 0xd8,
    VIBE_DOOM_KEY_BACKSPACE = 127,
    VIBE_DOOM_KEY_PAUSE = 0xff,
    VIBE_DOOM_KEY_EQUALS = 0x3d,
    VIBE_DOOM_KEY_MINUS = 0x2d,
    VIBE_DOOM_KEY_RSHIFT = 0xb6,
    VIBE_DOOM_KEY_RCTRL = 0x9d,
    VIBE_DOOM_KEY_RALT = 0xb8,
};

typedef struct vibe_doom_input_event {
    int type;
    int data1;
    int data2;
    int data3;
} vibe_doom_input_event_t;

int vibe_doom_translate_input_event(const vibe_input_event_t* input, vibe_doom_input_event_t* event);
int vibe_doom_translate_key_event(unsigned int packed, vibe_doom_input_event_t* event);
int vibe_doom_translate_mouse_event(unsigned int packed, vibe_doom_input_event_t* event);

#endif
