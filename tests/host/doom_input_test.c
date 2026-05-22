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
    vibe_input_status_t status;
    vibe_input_device_status_t device;

    input = input_key(123, vibe_input_ps2_set1_key_code(0x48, 1), 1);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYDOWN);
    CHECK(event.data1 == VIBE_DOOM_KEY_UPARROW);
    CHECK(event.data2 == 0);
    CHECK(event.data3 == 0);
    CHECK(vibe_input_key_ps2_set1_scancode(&input) == 0x48);
    CHECK(vibe_input_key_ps2_set1_is_extended(&input));

    input = input_key(124, vibe_input_ps2_set1_key_code(0x01, 0), 0);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYUP);
    CHECK(event.data1 == VIBE_DOOM_KEY_ESCAPE);
    CHECK(vibe_input_key_ps2_set1_scancode(&input) == 0x01);
    CHECK(!vibe_input_key_ps2_set1_is_extended(&input));

    input = input_key(125, 0, 1);
    CHECK(!vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);
    input = input_key(125, vibe_input_ps2_set1_key_code(0x1c, 0), 1);
    input.value0 = 2;
    CHECK(!vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);
    input.type = VIBE_INPUT_EVENT_NONE;
    input.code = vibe_input_ps2_set1_key_code(0x1c, 0);
    CHECK(!vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);

    input = input_key(126, vibe_input_ps2_set1_key_code(0x1d, 1), 1);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_KEYDOWN);
    CHECK(event.data1 == VIBE_DOOM_KEY_RCTRL);

    input = input_mouse(127, 0x01u, 2, -3);
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_MOUSE);
    CHECK(event.data1 == 0x01);
    CHECK(event.data2 == 8);
    CHECK(event.data3 == -12);

    input = input_mouse(128, 0xf2u, -1, 1);
    CHECK(vibe_input_mouse_buttons(&input) == VIBE_INPUT_MOUSE_BUTTON_RIGHT);
    CHECK(vibe_input_mouse_button_is_down(&input, VIBE_INPUT_MOUSE_BUTTON_RIGHT));
    CHECK(!vibe_input_mouse_button_is_down(&input, VIBE_INPUT_MOUSE_BUTTON_LEFT));
    CHECK(!vibe_input_mouse_button_is_down(&input, 0x08u));
    CHECK(vibe_input_mouse_delta_x(&input) == -1);
    CHECK(vibe_input_mouse_delta_y(&input) == 1);
    CHECK(vibe_input_mouse_has_motion(&input));
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.data1 == 0x04);
    CHECK(event.data2 == -4);
    CHECK(event.data3 == 4);

    input = input_mouse(129, 0x04u, 0, 0);
    CHECK(vibe_input_mouse_button_is_down(&input, VIBE_INPUT_MOUSE_BUTTON_MIDDLE));
    CHECK(!vibe_input_mouse_has_motion(&input));
    CHECK(vibe_doom_translate_input_event(&input, &event));
    CHECK(event.data1 == 0x02);

    input.device_id = VIBE_INPUT_DEVICE_KEYBOARD;
    input.type = VIBE_INPUT_EVENT_MOUSE_PACKET;
    CHECK(!vibe_doom_translate_input_event(&input, &event));
    CHECK(event.type == VIBE_DOOM_INPUT_NONE);
    CHECK(vibe_input_mouse_buttons(&input) == 0);
    CHECK(vibe_input_mouse_delta_x(&input) == 0);
    CHECK(vibe_input_mouse_delta_y(&input) == 0);

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

    status.abi_version = VIBE_INPUT_ABI_VERSION;
    status.event_bytes = VIBE_INPUT_EVENT_BYTES;
    status.queue_capacity = VIBE_INPUT_EVENT_QUEUE_CAPACITY;
    status.status_bytes = VIBE_INPUT_STATUS_BYTES;
    status.queue_usable_capacity = VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY;
    status.overflow_policy = VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST;
    status.queued_events = 3;
    status.polled_events = 4;
    status.dropped_events = 1;
    status.total_events = 8;
    status.keyboard_status = VIBE_INPUT_DEVICE_STATUS_READY;
    status.mouse_status = VIBE_INPUT_DEVICE_STATUS_ERROR;
    CHECK(vibe_input_status_abi_is_current(&status));
    CHECK(vibe_input_status_usable_capacity(&status) == VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY);
    CHECK(vibe_input_status_uses_drop_oldest(&status));
    CHECK(vibe_input_status_keyboard_is_ready(&status));
    CHECK(!vibe_input_status_mouse_is_ready(&status));
    CHECK(vibe_input_status_counters_are_consistent(&status));
    status.overflow_policy = 0;
    CHECK(!vibe_input_status_abi_is_current(&status));
    CHECK(!vibe_input_status_uses_drop_oldest(&status));

    device.abi_version = VIBE_INPUT_ABI_VERSION;
    device.status_bytes = VIBE_INPUT_DEVICE_STATUS_BYTES;
    device.device_id = VIBE_INPUT_DEVICE_KEYBOARD;
    device.status = VIBE_INPUT_DEVICE_STATUS_READY;
    device.capabilities = VIBE_INPUT_DEVICE_CAP_KEYS | VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT;
    device.irq_count = 5;
    device.event_count = 4;
    device.polled_events = 3;
    device.dropped_events = 1;
    device.last_timestamp = 130;
    device.last_event_type = VIBE_INPUT_EVENT_KEY;
    device.last_code = vibe_input_ps2_set1_key_code(0x2a, 0);
    device.active_state = VIBE_INPUT_MOD_SHIFT;
    device.axis_x_total = 0;
    device.axis_y_total = 0;
    device.reserved0 = 0;
    CHECK(vibe_input_device_status_abi_is_current(&device));
    CHECK(vibe_input_device_record_is_ready(&device));
    CHECK(vibe_input_device_status_has_capability(&device, VIBE_INPUT_DEVICE_CAP_KEYS));
    CHECK(vibe_input_device_status_counters_are_consistent(&device));
    CHECK(vibe_input_device_status_keyboard_modifiers(&device) == VIBE_INPUT_MOD_SHIFT);
    device.device_id = VIBE_INPUT_DEVICE_MOUSE;
    device.capabilities = VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER | VIBE_INPUT_DEVICE_CAP_BUTTONS;
    device.active_state = VIBE_INPUT_MOUSE_BUTTON_LEFT;
    CHECK(vibe_input_device_status_mouse_buttons(&device) == VIBE_INPUT_MOUSE_BUTTON_LEFT);

    return 0;
}
