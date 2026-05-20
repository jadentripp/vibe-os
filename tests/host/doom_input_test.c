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

int main(void)
{
    vibe_doom_input_event_t event;

    CHECK(vibe_doom_translate_key_event(pack_key(VIBE_DOOM_KEY_UPARROW, 1), &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYDOWN);
    CHECK(event.data1 == VIBE_DOOM_KEY_UPARROW);
    CHECK(event.data2 == 0);
    CHECK(event.data3 == 0);

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
