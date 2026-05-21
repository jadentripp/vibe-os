#include "input.h"
#include "vibe_os.h"

#define CHECK(expr) do { if (!(expr)) return __LINE__; } while (0)

static unsigned int pack_key(unsigned int key, int down)
{
    unsigned int packed;

    packed = VIBE_KEY_EVENT_VALID | (key & 0xffu);
    if (down)
        packed |= VIBE_KEY_EVENT_DOWN;
    return packed;
}

static unsigned int pack_mouse(unsigned int buttons, int x, int y)
{
    return VIBE_MOUSE_EVENT_VALID
        | (buttons & 0x07u)
        | (((unsigned int)(unsigned char)x) << 8)
        | (((unsigned int)(unsigned char)y) << 16);
}

static vibe_input_event_t input_key(unsigned long timestamp, unsigned int key, int down)
{
    vibe_input_event_t input;

    input.timestamp = timestamp;
    input.device_id = VIBE_INPUT_DEVICE_KEYBOARD;
    input.type = VIBE_INPUT_EVENT_KEY;
    input.code = key;
    input.value0 = down ? 1 : 0;
    input.value1 = 0;
    input.value2 = 0;
    return input;
}

static vibe_input_event_t input_mouse(unsigned long timestamp, unsigned int buttons, int x, int y)
{
    vibe_input_event_t input;

    input.timestamp = timestamp;
    input.device_id = VIBE_INPUT_DEVICE_MOUSE;
    input.type = VIBE_INPUT_EVENT_MOUSE_PACKET;
    input.code = buttons;
    input.value0 = x;
    input.value1 = y;
    input.value2 = 0;
    return input;
}

int main(void)
{
    vibe_doom_input_event_t event;
    vibe_input_event_t input;

    input = input_key(123, VIBE_DOOM_KEY_UPARROW, 1);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYDOWN);
    CHECK(event.data1 == VIBE_DOOM_KEY_UPARROW);
    CHECK(event.data2 == 0);
    CHECK(event.data3 == 0);

    input = input_key(124, VIBE_DOOM_KEY_ESCAPE, 0);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYUP);
    CHECK(event.data1 == VIBE_DOOM_KEY_ESCAPE);

    input = input_key(125, 0, 1);
    CHECK(!vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);
    input.type = VIBE_INPUT_EVENT_NONE;
    input.code = VIBE_DOOM_KEY_ENTER;
    CHECK(!vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);

    input = input_mouse(126, 0x01u, 2, -3);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_MOUSE);
    CHECK(event.data1 == 0x01);
    CHECK(event.data2 == 8);
    CHECK(event.data3 == -12);

    input = input_mouse(127, 0x02u, -1, 1);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.data1 == 0x04);
    CHECK(event.data2 == -4);
    CHECK(event.data3 == 4);

    input = input_mouse(128, 0x04u, 0, 0);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.data1 == 0x02);

    input.device_id = VIBE_INPUT_DEVICE_KEYBOARD;
    input.type = VIBE_INPUT_EVENT_MOUSE_PACKET;
    CHECK(!vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);

    CHECK(vibe_doom_translate_key_event(pack_key(VIBE_DOOM_KEY_UPARROW, 1), &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYDOWN);
    CHECK(event.data1 == VIBE_DOOM_KEY_UPARROW);

    CHECK(vibe_doom_translate_key_event(pack_key(VIBE_DOOM_KEY_ESCAPE, 0), &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYUP);
    CHECK(event.data1 == VIBE_DOOM_KEY_ESCAPE);

    CHECK(!vibe_doom_translate_key_event(pack_key(0, 1), &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);
    CHECK(!vibe_doom_translate_key_event(VIBE_DOOM_KEY_ENTER, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);

    CHECK(vibe_doom_translate_mouse_event(pack_mouse(0x01u, 2, -3), &event));
    CHECK(event.type == VIBE_DOOM_INPUT_MOUSE);
    CHECK(event.data1 == 0x01);
    CHECK(event.data2 == 8);
    CHECK(event.data3 == -12);

    CHECK(vibe_doom_translate_mouse_event(pack_mouse(0x02u, -1, 1), &event));
    CHECK(event.data1 == 0x04);
    CHECK(event.data2 == -4);
    CHECK(event.data3 == 4);

    CHECK(vibe_doom_translate_mouse_event(pack_mouse(0x04u, 0, 0), &event));
    CHECK(event.data1 == 0x02);

    CHECK(vibe_doom_translate_mouse_event(pack_mouse(0x07u, -128, 127), &event));
    CHECK(event.data1 == 0x07);
    CHECK(event.data2 == -512);
    CHECK(event.data3 == 508);

    CHECK(!vibe_doom_translate_mouse_event(0x07u, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);

    return 0;
}
