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

static unsigned int doom_key_from_ps2_set1_code(unsigned int code)
{
    static const unsigned char normal_map[128] = {
        [0x01] = VIBE_DOOM_KEY_ESCAPE,
        [0x02] = '1',
        [0x03] = '2',
        [0x04] = '3',
        [0x05] = '4',
        [0x06] = '5',
        [0x07] = '6',
        [0x08] = '7',
        [0x09] = '8',
        [0x0a] = '9',
        [0x0b] = '0',
        [0x0c] = VIBE_DOOM_KEY_MINUS,
        [0x0d] = VIBE_DOOM_KEY_EQUALS,
        [0x0e] = VIBE_DOOM_KEY_BACKSPACE,
        [0x0f] = VIBE_DOOM_KEY_TAB,
        [0x10] = 'q',
        [0x11] = 'w',
        [0x12] = 'e',
        [0x13] = 'r',
        [0x14] = 't',
        [0x15] = 'y',
        [0x16] = 'u',
        [0x17] = 'i',
        [0x18] = 'o',
        [0x19] = 'p',
        [0x1a] = '[',
        [0x1b] = ']',
        [0x1c] = VIBE_DOOM_KEY_ENTER,
        [0x1d] = VIBE_DOOM_KEY_RCTRL,
        [0x1e] = 'a',
        [0x1f] = 's',
        [0x20] = 'd',
        [0x21] = 'f',
        [0x22] = 'g',
        [0x23] = 'h',
        [0x24] = 'j',
        [0x25] = 'k',
        [0x26] = 'l',
        [0x27] = ';',
        [0x28] = 39,
        [0x29] = '`',
        [0x2a] = VIBE_DOOM_KEY_RSHIFT,
        [0x2b] = 92,
        [0x2c] = 'z',
        [0x2d] = 'x',
        [0x2e] = 'c',
        [0x2f] = 'v',
        [0x30] = 'b',
        [0x31] = 'n',
        [0x32] = 'm',
        [0x33] = ',',
        [0x34] = '.',
        [0x35] = '/',
        [0x36] = VIBE_DOOM_KEY_RSHIFT,
        [0x38] = VIBE_DOOM_KEY_RALT,
        [0x39] = ' ',
        [0x3b] = VIBE_DOOM_KEY_F1,
        [0x3c] = VIBE_DOOM_KEY_F2,
        [0x3d] = VIBE_DOOM_KEY_F3,
        [0x3e] = VIBE_DOOM_KEY_F4,
        [0x3f] = VIBE_DOOM_KEY_F5,
        [0x40] = VIBE_DOOM_KEY_F6,
        [0x41] = VIBE_DOOM_KEY_F7,
        [0x42] = VIBE_DOOM_KEY_F8,
        [0x43] = VIBE_DOOM_KEY_F9,
        [0x44] = VIBE_DOOM_KEY_F10,
        [0x48] = VIBE_DOOM_KEY_UPARROW,
        [0x4a] = VIBE_DOOM_KEY_MINUS,
        [0x4b] = VIBE_DOOM_KEY_LEFTARROW,
        [0x4d] = VIBE_DOOM_KEY_RIGHTARROW,
        [0x4e] = VIBE_DOOM_KEY_EQUALS,
        [0x50] = VIBE_DOOM_KEY_DOWNARROW,
        [0x53] = VIBE_DOOM_KEY_BACKSPACE,
        [0x57] = VIBE_DOOM_KEY_F11,
        [0x58] = VIBE_DOOM_KEY_F12,
    };
    unsigned int scancode;

    scancode = code & VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK;
    if (code & VIBE_INPUT_KEY_PS2_SET1_EXTENDED) {
        switch (scancode) {
        case 0x48:
            return VIBE_DOOM_KEY_UPARROW;
        case 0x50:
            return VIBE_DOOM_KEY_DOWNARROW;
        case 0x4b:
            return VIBE_DOOM_KEY_LEFTARROW;
        case 0x4d:
            return VIBE_DOOM_KEY_RIGHTARROW;
        case 0x1c:
            return VIBE_DOOM_KEY_ENTER;
        case 0x1d:
            return VIBE_DOOM_KEY_RCTRL;
        case 0x38:
            return VIBE_DOOM_KEY_RALT;
        case 0x53:
            return VIBE_DOOM_KEY_BACKSPACE;
        default:
            return 0;
        }
    }

    return normal_map[scancode];
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
            doom_key_from_ps2_set1_code((unsigned int)vibe_input_key_code(input)),
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
