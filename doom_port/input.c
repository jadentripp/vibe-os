#include "input.h"

#define VIBE_DOOM_MOUSE_DELTA_MAX (0x7fffffffL / VIBE_DOOM_MOUSE_RELATIVE_SCALE)
#define VIBE_DOOM_MOUSE_DELTA_MIN ((-0x7fffffffL - 1L) / VIBE_DOOM_MOUSE_RELATIVE_SCALE)

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

static int scale_doom_mouse_delta(long delta)
{
    if (delta > VIBE_DOOM_MOUSE_DELTA_MAX)
        return 0x7fffffff;
    if (delta < VIBE_DOOM_MOUSE_DELTA_MIN)
        return -0x7fffffff - 1;
    return (int)(delta * VIBE_DOOM_MOUSE_RELATIVE_SCALE);
}

static void clear_doom_input_event(vibe_doom_input_event_t* event)
{
    event->type = VIBE_DOOM_INPUT_NONE;
    event->data1 = 0;
    event->data2 = 0;
    event->data3 = 0;
}

static int translate_key_fields(unsigned int key, long down, vibe_doom_input_event_t* event)
{
    if (!key)
        return 0;

    event->type = down
        ? VIBE_DOOM_INPUT_KEYDOWN
        : VIBE_DOOM_INPUT_KEYUP;
    event->data1 = (int)key;

    return 1;
}

static int translate_mouse_fields(unsigned int buttons, long dx, long dy, vibe_doom_input_event_t* event)
{
    event->type = VIBE_DOOM_INPUT_MOUSE;
    event->data1 = doom_mouse_buttons_from_ps2(buttons & VIBE_INPUT_MOUSE_BUTTON_MASK);
    event->data2 = scale_doom_mouse_delta(dx);
    event->data3 = scale_doom_mouse_delta(dy);

    return 1;
}

int vibe_doom_translate_input_event(const vibe_input_event_t* input, vibe_doom_input_event_t* event)
{
    if (!event)
        return 0;

    clear_doom_input_event(event);

    if (!input)
        return 0;

    if (vibe_input_event_is_key(input)) {
        if (!vibe_input_key_is_pressed(input) && !vibe_input_key_is_released(input))
            return 0;
        return translate_key_fields(
            (unsigned int)vibe_input_key_code(input) & 0xffu,
            vibe_input_key_is_pressed(input),
            event);
    }

    if (vibe_input_event_is_mouse_packet(input)) {
        return translate_mouse_fields(
            (unsigned int)vibe_input_mouse_buttons(input),
            vibe_input_mouse_delta(input, VIBE_INPUT_MOUSE_AXIS_X),
            vibe_input_mouse_delta(input, VIBE_INPUT_MOUSE_AXIS_Y),
            event);
    }

    return 0;
}

int vibe_doom_translate_key_event(unsigned int packed, vibe_doom_input_event_t* event)
{
    if (!event)
        return 0;

    clear_doom_input_event(event);

    if (!(packed & VIBE_KEY_EVENT_VALID))
        return 0;

    return translate_key_fields(
        packed & 0xffu,
        (packed & VIBE_KEY_EVENT_DOWN) != 0,
        event);
}

int vibe_doom_translate_mouse_event(unsigned int packed, vibe_doom_input_event_t* event)
{
    if (!event)
        return 0;

    clear_doom_input_event(event);

    if (!(packed & VIBE_MOUSE_EVENT_VALID))
        return 0;

    return translate_mouse_fields(
        packed & 0x07u,
        sign_extend_mouse_delta(packed, 8),
        sign_extend_mouse_delta(packed, 16),
        event);
}
