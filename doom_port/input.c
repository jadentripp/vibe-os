#include "input.h"
#include "vibe_os.h"

#define VIBE_MOUSE_SCALE 4

static int sign_extend_mouse_delta(unsigned int packed, int shift)
{
    return (int)(signed char)((packed >> shift) & 0xffu);
}

static int doom_mouse_buttons_from_ps2(unsigned int packed)
{
    unsigned int ps2_buttons;
    int doom_buttons;

    ps2_buttons = packed & 0x07u;
    doom_buttons = 0;

    if (ps2_buttons & 0x01u)
        doom_buttons |= 0x01;
    if (ps2_buttons & 0x04u)
        doom_buttons |= 0x02;
    if (ps2_buttons & 0x02u)
        doom_buttons |= 0x04;

    return doom_buttons;
}

int vibe_doom_translate_key_event(unsigned int packed, vibe_doom_input_event_t* event)
{
    unsigned int key;

    if (!event)
        return 0;

    event->type = VIBE_DOOM_INPUT_NONE;
    event->data1 = 0;
    event->data2 = 0;
    event->data3 = 0;

    if (!(packed & VIBE_KEY_EVENT_VALID))
        return 0;

    key = packed & 0xffu;
    if (!key)
        return 0;

    event->type = (packed & VIBE_KEY_EVENT_DOWN)
        ? VIBE_DOOM_INPUT_KEYDOWN
        : VIBE_DOOM_INPUT_KEYUP;
    event->data1 = (int)key;

    return 1;
}

int vibe_doom_translate_mouse_event(unsigned int packed, vibe_doom_input_event_t* event)
{
    int x;
    int y;
    int buttons;

    if (!event)
        return 0;

    event->type = VIBE_DOOM_INPUT_NONE;
    event->data1 = 0;
    event->data2 = 0;
    event->data3 = 0;

    if (!(packed & VIBE_MOUSE_EVENT_VALID))
        return 0;

    buttons = doom_mouse_buttons_from_ps2(packed);
    x = sign_extend_mouse_delta(packed, 8) * VIBE_MOUSE_SCALE;
    y = sign_extend_mouse_delta(packed, 16) * VIBE_MOUSE_SCALE;

    event->type = VIBE_DOOM_INPUT_MOUSE;
    event->data1 = buttons;
    event->data2 = x;
    event->data3 = y;

    return 1;
}
