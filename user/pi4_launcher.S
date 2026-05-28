#include "pi4_runtime.inc"

// AArch64 Pi 4 guest desktop launcher.

.arch armv8-a

.equ PI4_LAUNCHER_FRAME_WIDTH,          1280
.equ PI4_LAUNCHER_FRAME_HEIGHT,         720
.equ PI4_LAUNCHER_FRAME_STRIDE,         PI4_LAUNCHER_FRAME_WIDTH
.equ PI4_LAUNCHER_FRAME_BYTES,          PI4_LAUNCHER_FRAME_WIDTH * PI4_LAUNCHER_FRAME_HEIGHT

.equ PI4_LAUNCHER_TOPBAR_HEIGHT,        56
.equ PI4_LAUNCHER_WINDOW_X,             32
.equ PI4_LAUNCHER_WINDOW_Y,             72
.equ PI4_LAUNCHER_WINDOW_W,             1216
.equ PI4_LAUNCHER_WINDOW_H,             92
.equ PI4_LAUNCHER_DOCK_X,               32
.equ PI4_LAUNCHER_DOCK_Y,               176
.equ PI4_LAUNCHER_DOCK_W,               1216
.equ PI4_LAUNCHER_DOCK_H,               504
.equ PI4_LAUNCHER_DOOM_CARD_X,          48
.equ PI4_LAUNCHER_QUAKE_CARD_X,         680
.equ PI4_LAUNCHER_CARD_Y,               204
.equ PI4_LAUNCHER_CARD_W,               552
.equ PI4_LAUNCHER_CARD_H,               464
.equ PI4_LAUNCHER_CARD_ART_INSET,       24
.equ PI4_LAUNCHER_CARD_ART_W,           PI4_LAUNCHER_CARD_W - (PI4_LAUNCHER_CARD_ART_INSET * 2)
.equ PI4_LAUNCHER_CARD_ART_H,           336
.equ PI4_LAUNCHER_CARD_CHROME_INSET,    16
.equ PI4_LAUNCHER_CARD_TITLE_Y_OFF,     10
.equ PI4_LAUNCHER_CARD_TITLE_H,         12
.equ PI4_LAUNCHER_ICON_SIZE,            256
.equ PI4_LAUNCHER_ICON_DISPLAY_SIZE,    320
.equ PI4_LAUNCHER_DOOM_ICON_X,          164
.equ PI4_LAUNCHER_QUAKE_ICON_X,         796
.equ PI4_LAUNCHER_ICON_Y,               228
.equ PI4_LAUNCHER_LABEL_Y,              556
.equ PI4_LAUNCHER_LABEL_H,              7
.equ PI4_LAUNCHER_LABEL_SCALE,          7
.equ PI4_LAUNCHER_LABEL_GLYPH_W,        5
.equ PI4_LAUNCHER_LABEL_ADVANCE,        6
.equ PI4_LAUNCHER_APP_LABEL_MAX_CHARS,  16
.equ PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF,  140
.equ PI4_LAUNCHER_LAUNCH_BUTTON_Y,      PI4_LAUNCHER_CARD_Y + PI4_LAUNCHER_CARD_H - 56
.equ PI4_LAUNCHER_LAUNCH_BUTTON_W,      272
.equ PI4_LAUNCHER_LAUNCH_BUTTON_H,      48
.equ PI4_LAUNCHER_KEY_BADGE_X_OFF,      72
.equ PI4_LAUNCHER_KEY_BADGE_Y,          PI4_LAUNCHER_LAUNCH_BUTTON_Y
.equ PI4_LAUNCHER_KEY_BADGE_W,          48
.equ PI4_LAUNCHER_KEY_BADGE_H,          48
.equ PI4_LAUNCHER_KEY_BADGE_DIGIT_X_OFF, 12
.equ PI4_LAUNCHER_KEY_BADGE_DIGIT_Y_OFF, 4
.equ PI4_LAUNCHER_KEY_BADGE_DIGIT_W,    3
.equ PI4_LAUNCHER_KEY_BADGE_DIGIT_H,    5
.equ PI4_LAUNCHER_KEY_BADGE_DIGIT_SCALE, 8
.equ PI4_LAUNCHER_PLAY_GLYPH_W,         32
.equ PI4_LAUNCHER_PLAY_GLYPH_H,         28
.equ PI4_LAUNCHER_BUTTON_LABEL_X_OFF,   PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF + 184
.equ PI4_LAUNCHER_BUTTON_LABEL_Y,       PI4_LAUNCHER_LAUNCH_BUTTON_Y + 15
.equ PI4_LAUNCHER_BUTTON_LABEL_W,       19
.equ PI4_LAUNCHER_BUTTON_LABEL_H,       5
.equ PI4_LAUNCHER_BUTTON_LABEL_SCALE,   4
.equ PI4_LAUNCHER_CARD_HIT_PAD_X,       24
.equ PI4_LAUNCHER_CARD_HIT_PAD_Y,       24
.equ PI4_LAUNCHER_DOOM_HIT_X0,          PI4_LAUNCHER_DOOM_CARD_X - PI4_LAUNCHER_CARD_HIT_PAD_X
.equ PI4_LAUNCHER_DOOM_HIT_X1,          PI4_LAUNCHER_DOOM_CARD_X + PI4_LAUNCHER_CARD_W + PI4_LAUNCHER_CARD_HIT_PAD_X - 1
.equ PI4_LAUNCHER_QUAKE_HIT_X0,         PI4_LAUNCHER_QUAKE_CARD_X - PI4_LAUNCHER_CARD_HIT_PAD_X
.equ PI4_LAUNCHER_QUAKE_HIT_X1,         PI4_LAUNCHER_QUAKE_CARD_X + PI4_LAUNCHER_CARD_W + PI4_LAUNCHER_CARD_HIT_PAD_X - 1
.equ PI4_LAUNCHER_CARD_HIT_Y0,          PI4_LAUNCHER_CARD_Y - PI4_LAUNCHER_CARD_HIT_PAD_Y
.equ PI4_LAUNCHER_CARD_HIT_Y1,          PI4_LAUNCHER_CARD_Y + PI4_LAUNCHER_CARD_H + PI4_LAUNCHER_CARD_HIT_PAD_Y - 1
.equ PI4_LAUNCHER_CURSOR_W,             9
.equ PI4_LAUNCHER_CURSOR_H,             13
.equ PI4_LAUNCHER_CURSOR_SCALE,         4
.equ PI4_LAUNCHER_CURSOR_SHADOW_OFFSET, 4
.equ PI4_LAUNCHER_CURSOR_DRAW_W,        PI4_LAUNCHER_CURSOR_W * PI4_LAUNCHER_CURSOR_SCALE
.equ PI4_LAUNCHER_CURSOR_DRAW_H,        PI4_LAUNCHER_CURSOR_H * PI4_LAUNCHER_CURSOR_SCALE
.equ PI4_LAUNCHER_CURSOR_START_X,       PI4_LAUNCHER_DOOM_CARD_X + PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF + (PI4_LAUNCHER_LAUNCH_BUTTON_W / 2)
.equ PI4_LAUNCHER_CURSOR_START_Y,       PI4_LAUNCHER_LAUNCH_BUTTON_Y + (PI4_LAUNCHER_LAUNCH_BUTTON_H / 2)
.equ PI4_LAUNCHER_CURSOR_MAX_X,         PI4_LAUNCHER_FRAME_WIDTH - PI4_LAUNCHER_CURSOR_DRAW_W - 1
.equ PI4_LAUNCHER_CURSOR_MAX_Y,         PI4_LAUNCHER_FRAME_HEIGHT - PI4_LAUNCHER_CURSOR_DRAW_H - 1

.equ PI4_LAUNCHER_APP_RECORD_COUNT,           PI4_VIBE_APP_RECORD_CAPACITY
.equ PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT,   PI4_VIBE_VISIBLE_APP_RECORD_COUNT
.equ PI4_LAUNCHER_APP_RECORD_FIRST,           0
.equ PI4_LAUNCHER_APP_RECORD_SECOND,          1
.equ PI4_LAUNCHER_APP_RECORD_DEFAULT,         PI4_LAUNCHER_APP_RECORD_FIRST
.equ PI4_LAUNCHER_APP_RECORD_0,            PI4_LAUNCHER_APP_RECORD_FIRST
.equ PI4_LAUNCHER_APP_RECORD_1,            PI4_LAUNCHER_APP_RECORD_SECOND
.equ PI4_LAUNCHER_APP_RECORD_NONE,            PI4_LAUNCHER_APP_RECORD_COUNT
.equ PI4_LAUNCHER_APP_RECORD_BYTES,           40
.equ PI4_LAUNCHER_APP_RECORD_NAME,            8
.equ PI4_LAUNCHER_APP_RECORD_PATH,            16
.equ PI4_LAUNCHER_APP_RECORD_STATE,           24
.equ PI4_LAUNCHER_APP_RECORD_STATE_TEXT,      32
.equ PI4_LAUNCHER_APP_RECORD_STATE_ABSENT,    0
.equ PI4_LAUNCHER_APP_RECORD_STATE_PRESENT,   1

.equ PI4_LAUNCHER_CARD_RECORD_INDEX,      0
.equ PI4_LAUNCHER_CARD_RECORD_CARD_X,    8
.equ PI4_LAUNCHER_CARD_RECORD_ICON_X,    16
.equ PI4_LAUNCHER_CARD_RECORD_ACCENT,    24
.equ PI4_LAUNCHER_CARD_RECORD_DARK,      32
.equ PI4_LAUNCHER_CARD_RECORD_POSTER,    40
.equ PI4_LAUNCHER_CARD_RECORD_ICON_DRAW, 48
.equ PI4_LAUNCHER_CARD_RECORD_KEY_BITMAP, 56
.equ PI4_LAUNCHER_CARD_RECORD_ICON_PIXELS, 64
.equ PI4_LAUNCHER_CARD_RECORD_BYTES,     72

.equ PI4_LAUNCHER_APP_INDEX_READY,      0x00000010
.equ PI4_LAUNCHER_APP_MANIFEST_READY_BASE, 0x00000020
.equ PI4_LAUNCHER_APP_EXEC_READY_BASE,  0x00000040
.equ PI4_LAUNCHER_APP_TEXT_BYTES,       2048
.equ PI4_LAUNCHER_APP_NAME_BYTES,       32
.equ PI4_LAUNCHER_APP_PATH_BYTES,       PI4_VIBE_EXEC_REQUEST_PATH_MAX_BYTES
.equ PI4_LAUNCHER_APP_ICON_BYTES,       64
.equ PI4_LAUNCHER_APP_KEY_BYTES,        32
.equ PI4_LAUNCHER_APP_COUNT_BYTES,      16
.equ PI4_LAUNCHER_EXEC_REQUEST_RESERVED_OFFSET, PI4_VIBE_EXEC_REQUEST_RESERVED_OFFSET

.equ PI4_LAUNCHER_PHASE_COLD,           0
.equ PI4_LAUNCHER_PHASE_FRAME_READY,    1
.equ PI4_LAUNCHER_PHASE_SELECTION_READY, 2
.equ PI4_LAUNCHER_PHASE_EXEC_WAIT,      3

.equ PI4_LAUNCHER_STATE_MAGIC,          0x5049344c41554e43
.equ PI4_LAUNCHER_STATE_PHASE,          8
.equ PI4_LAUNCHER_STATE_FRAME,          16
.equ PI4_LAUNCHER_STATE_WIDTH,          24
.equ PI4_LAUNCHER_STATE_HEIGHT,         32
.equ PI4_LAUNCHER_STATE_STRIDE,         40
.equ PI4_LAUNCHER_STATE_BYTES,          48
.equ PI4_LAUNCHER_STATE_APP_RECORD_COUNT,     56
.equ PI4_LAUNCHER_STATE_SELECTED_INDEX, 64
.equ PI4_LAUNCHER_STATE_SELECTED_APP_RECORD,  72
.equ PI4_LAUNCHER_STATE_SELECTED_NAME,  80
.equ PI4_LAUNCHER_STATE_SELECTED_PATH,  88
.equ PI4_LAUNCHER_STATE_RENDER_COUNT,   96
.equ PI4_LAUNCHER_STATE_PRESENT_COUNT,  104
.equ PI4_LAUNCHER_STATE_POLL_RESULT,    112
.equ PI4_LAUNCHER_STATE_INPUT_TYPE,     120
.equ PI4_LAUNCHER_STATE_INPUT_CODE,     128
.equ PI4_LAUNCHER_STATE_INPUT_VALUE0,   136
.equ PI4_LAUNCHER_STATE_CHANGE_COUNT,   144
.equ PI4_LAUNCHER_STATE_RECORD_COUNT,   152
.equ PI4_LAUNCHER_STATE_RECORD_INDEX,   160
.equ PI4_LAUNCHER_STATE_RECORD_ENTRY,    168
.equ PI4_LAUNCHER_STATE_RECORD_NAME,    176
.equ PI4_LAUNCHER_STATE_RECORD_PATH,    184
.equ PI4_LAUNCHER_STATE_EXEC_REQUEST,   192
.equ PI4_LAUNCHER_STATE_EXEC_RESULT,    200
.equ PI4_LAUNCHER_STATE_EXEC_ERRNO,     208
.equ PI4_LAUNCHER_STATE_EXEC_COUNT,     216
.equ PI4_LAUNCHER_STATE_SELECTED_STATE, 224
.equ PI4_LAUNCHER_STATE_SELECTED_STATE_TEXT, 232
.equ PI4_LAUNCHER_STATE_RECORD_STATE,   240
.equ PI4_LAUNCHER_STATE_RECORD_STATE_TEXT, 248
.equ PI4_LAUNCHER_STATE_ABI_VERSION,    256
.equ PI4_LAUNCHER_STATE_TOTAL_BYTES,    264
.equ PI4_LAUNCHER_STATE_INPUT_TIMESTAMP, 272
.equ PI4_LAUNCHER_STATE_INPUT_DEVICE_ID, 280
.equ PI4_LAUNCHER_STATE_INPUT_ACTION,   288
.equ PI4_LAUNCHER_STATE_INPUT_ACTION_COUNT, 296
.equ PI4_LAUNCHER_STATE_MOVE_COUNT,     304
.equ PI4_LAUNCHER_STATE_RECORD_ACTION_COUNT, 312
.equ PI4_LAUNCHER_STATE_PRESENT_STATUS, 320
.equ PI4_LAUNCHER_STATE_PRESENT_ERRNO,  328
.equ PI4_LAUNCHER_STATE_EXEC_REQUEST_ABI, 336
.equ PI4_LAUNCHER_STATE_EXEC_REQUEST_BYTES, 344
.equ PI4_LAUNCHER_STATE_EXEC_REQUEST_RESERVED, 352
.equ PI4_LAUNCHER_STATE_EXEC_REQUEST_PATH, 360
.equ PI4_LAUNCHER_STATE_EXEC_ARGV,       368
.equ PI4_LAUNCHER_STATE_EXEC_ATTEMPT_STATE, 376
.equ PI4_LAUNCHER_STATE_EXEC_REQUEST_COUNT, 384
.equ PI4_LAUNCHER_STATE_ABI_VERSION_VALUE, 2
.equ PI4_LAUNCHER_STATE_TOTAL_BYTES_VALUE, 392

.equ PI4_INPUT_EVENT_TIMESTAMP,         0
.equ PI4_INPUT_EVENT_DEVICE_ID,         8
.equ PI4_INPUT_EVENT_TYPE,              16
.equ PI4_INPUT_EVENT_CODE,              24
.equ PI4_INPUT_EVENT_VALUE0,            32
.equ PI4_INPUT_EVENT_VALUE1,            40

.equ PI4_INPUT_DEVICE_KEYBOARD,         1
.equ PI4_INPUT_DEVICE_MOUSE,            2
.equ PI4_INPUT_DEVICE_UART,             3
.equ PI4_INPUT_DEVICE_USB,              4
.equ PI4_INPUT_EVENT_KEY,               1
.equ PI4_INPUT_EVENT_MOUSE_PACKET,      2
.equ PI4_INPUT_EVENT_UART,              3
.equ PI4_INPUT_KEY_PRESSED,             1
.equ PI4_INPUT_KEY_SCANCODE_MASK,       0x7f
.equ PI4_INPUT_KEY_TOKEN_HID_SHIFT,     8
.equ PI4_INPUT_KEY_TOKEN_FIELD_MASK,    0xff
.equ PI4_INPUT_MOUSE_BUTTON_LEFT,       0x01

.equ PI4_INPUT_SCANCODE_1,              0x02
.equ PI4_INPUT_SCANCODE_2,              0x03
.equ PI4_INPUT_SCANCODE_ENTER,          0x1c
.equ PI4_INPUT_SCANCODE_A,              0x1e
.equ PI4_INPUT_SCANCODE_D,              0x20
.equ PI4_INPUT_SCANCODE_SPACE,          0x39
.equ PI4_INPUT_SCANCODE_W,              0x11
.equ PI4_INPUT_SCANCODE_S,              0x1f
.equ PI4_INPUT_SCANCODE_LEFT,           0x4b
.equ PI4_INPUT_SCANCODE_RIGHT,          0x4d
.equ PI4_INPUT_SCANCODE_UP,             0x48
.equ PI4_INPUT_SCANCODE_DOWN,           0x50
.equ PI4_INPUT_HID_USAGE_1,             0x1e
.equ PI4_INPUT_HID_USAGE_2,             0x1f
.equ PI4_INPUT_HID_USAGE_A,             0x04
.equ PI4_INPUT_HID_USAGE_D,             0x07
.equ PI4_INPUT_HID_USAGE_W,             0x1a
.equ PI4_INPUT_HID_USAGE_S,             0x16
.equ PI4_INPUT_HID_USAGE_ENTER,         0x28
.equ PI4_INPUT_HID_USAGE_SPACE,         0x2c
.equ PI4_INPUT_HID_USAGE_LEFT,          0x50
.equ PI4_INPUT_HID_USAGE_RIGHT,         0x4f
.equ PI4_INPUT_HID_USAGE_UP,            0x52
.equ PI4_INPUT_HID_USAGE_DOWN,          0x51
.equ PI4_INPUT_HID_USAGE_KP_ENTER,      0x58
.equ PI4_INPUT_HID_USAGE_KP_1,          0x59
.equ PI4_INPUT_HID_USAGE_KP_2,          0x5a

.equ PI4_LAUNCHER_INPUT_ACTION_NONE,    0
.equ PI4_LAUNCHER_INPUT_ACTION_MOVED,   1
.equ PI4_LAUNCHER_INPUT_ACTION_RECORD,  2

.equ PI4_LAUNCHER_EXEC_ATTEMPT_IDLE,    0
.equ PI4_LAUNCHER_EXEC_ATTEMPT_PREPARED, 1
.equ PI4_LAUNCHER_EXEC_ATTEMPT_RETURNED, 2
.equ PI4_LAUNCHER_EXEC_ATTEMPT_ENOSYS,  3
.equ PI4_LAUNCHER_EXEC_ATTEMPT_FAILED,  4
.equ PI4_LAUNCHER_EXEC_ATTEMPT_OK,      5

.equ PI4_LAUNCHER_UART_EVENT_NONE,      0
.equ PI4_LAUNCHER_UART_EVENT_SELECT_1,  1
.equ PI4_LAUNCHER_UART_EVENT_SELECT_2,  2
.equ PI4_LAUNCHER_UART_EVENT_ENTER,     3
.equ PI4_LAUNCHER_UART_EVENT_UP,        4
.equ PI4_LAUNCHER_UART_EVENT_DOWN,      5
.equ PI4_LAUNCHER_UART_EVENT_LAUNCH_1,  7
.equ PI4_LAUNCHER_UART_EVENT_LAUNCH_2,  8

.equ PI4_COLOR_BLACK,                   0
.equ PI4_COLOR_BG0,                     1
.equ PI4_COLOR_BG1,                     2
.equ PI4_COLOR_PANEL,                   3
.equ PI4_COLOR_SELECTED,                4
.equ PI4_COLOR_TEXT,                    5
.equ PI4_COLOR_DIM,                     6
.equ PI4_COLOR_BORDER,                  7
.equ PI4_COLOR_DOOM,                    8
.equ PI4_COLOR_QUAKE,                   9
.equ PI4_COLOR_DOOM_DARK,               10
.equ PI4_COLOR_DOOM_FIRE,               11
.equ PI4_COLOR_QUAKE_DARK,              12
.equ PI4_COLOR_QUAKE_GOLD,              13
.equ PI4_COLOR_CARD,                    14
.equ PI4_COLOR_HILITE,                  15

.extern pi4_launcher_app_record_present_state
.extern pi4_launcher_app_record_absent_state
.extern pi4_launcher_key_1_bitmap
.extern pi4_launcher_key_2_bitmap
.extern pi4_launcher_enter_label_bitmap
.extern pi4_launcher_cursor_bitmap
.extern pi4_launcher_indexed_palette
.extern pi4_launcher_load_art
.extern pi4_launcher_art_flags
.extern pi4_launcher_app_discovery_flags
.extern pi4_launcher_doom_icon_pixels
.extern pi4_launcher_quake_icon_pixels
.extern vibe_user_present_indexed
.extern vibe_user_fb_get_info
.extern vibe_user_poll_input
.extern vibe_user_exec_request
.extern vibe_user_file_read_at

.section .text.pi4_launcher.entry, "ax", %progbits
.balign 16
.global user_main
.global pi4_launcher_start
.type user_main, %function
.type pi4_launcher_start, %function
user_main:
pi4_launcher_start:
    bl pi4_launcher_discover_apps
    bl pi4_launcher_load_art
    mov x19, #PI4_LAUNCHER_APP_RECORD_DEFAULT
    bl pi4_launcher_reset_desktop_state

    mov x0, xzr
    mov x1, x19
    bl pi4_launcher_render_frame
    bl pi4_launcher_present_frame

.Lpi4_launcher_poll:
    adrp x0, pi4_launcher_input_event
    add x0, x0, :lo12:pi4_launcher_input_event
    bl vibe_user_poll_input

    adrp x21, pi4_launcher_state
    add x21, x21, :lo12:pi4_launcher_state
    str x0, [x21, #PI4_LAUNCHER_STATE_POLL_RESULT]

    cmp x0, #1
    b.ne .Lpi4_launcher_wait

    adrp x0, pi4_launcher_input_event
    add x0, x0, :lo12:pi4_launcher_input_event
    ldr x22, [x0, #PI4_INPUT_EVENT_TIMESTAMP]
    str x22, [x21, #PI4_LAUNCHER_STATE_INPUT_TIMESTAMP]
    ldr x22, [x0, #PI4_INPUT_EVENT_DEVICE_ID]
    str x22, [x21, #PI4_LAUNCHER_STATE_INPUT_DEVICE_ID]
    ldr x22, [x0, #PI4_INPUT_EVENT_TYPE]
    str x22, [x21, #PI4_LAUNCHER_STATE_INPUT_TYPE]
    ldr x22, [x0, #PI4_INPUT_EVENT_CODE]
    str x22, [x21, #PI4_LAUNCHER_STATE_INPUT_CODE]
    ldr x22, [x0, #PI4_INPUT_EVENT_VALUE0]
    str x22, [x21, #PI4_LAUNCHER_STATE_INPUT_VALUE0]

    mov x1, x19
    bl pi4_launcher_apply_input_event
    mov x19, x0
    mov x20, x1
    str x20, [x21, #PI4_LAUNCHER_STATE_INPUT_ACTION]
    cbz x20, .Lpi4_launcher_poll

    ldr x22, [x21, #PI4_LAUNCHER_STATE_CHANGE_COUNT]
    add x22, x22, #1
    str x22, [x21, #PI4_LAUNCHER_STATE_CHANGE_COUNT]
    ldr x22, [x21, #PI4_LAUNCHER_STATE_INPUT_ACTION_COUNT]
    add x22, x22, #1
    str x22, [x21, #PI4_LAUNCHER_STATE_INPUT_ACTION_COUNT]

    cmp x20, #PI4_LAUNCHER_INPUT_ACTION_MOVED
    b.ne .Lpi4_launcher_count_record_action
    ldr x22, [x21, #PI4_LAUNCHER_STATE_MOVE_COUNT]
    add x22, x22, #1
    str x22, [x21, #PI4_LAUNCHER_STATE_MOVE_COUNT]
    b .Lpi4_launcher_action_count_done

.Lpi4_launcher_count_record_action:
    cmp x20, #PI4_LAUNCHER_INPUT_ACTION_RECORD
    b.ne .Lpi4_launcher_action_count_done
    ldr x22, [x21, #PI4_LAUNCHER_STATE_RECORD_ACTION_COUNT]
    add x22, x22, #1
    str x22, [x21, #PI4_LAUNCHER_STATE_RECORD_ACTION_COUNT]

.Lpi4_launcher_action_count_done:
    cmp x20, #PI4_LAUNCHER_INPUT_ACTION_RECORD
    b.eq .Lpi4_launcher_record_action
    cmp x20, #PI4_LAUNCHER_INPUT_ACTION_MOVED
    b.ne .Lpi4_launcher_render_non_record
    adrp x22, pi4_launcher_failed_app_record
    add x22, x22, :lo12:pi4_launcher_failed_app_record
    mov x23, #PI4_LAUNCHER_APP_RECORD_NONE
    str x23, [x22]

.Lpi4_launcher_render_non_record:
    mov x0, xzr
    mov x1, x19
    bl pi4_launcher_render_frame
    b .Lpi4_launcher_present_after_input

.Lpi4_launcher_record_action:
    mov x0, x19
    bl pi4_launcher_record_selection
    mov x0, xzr
    mov x1, x19
    bl pi4_launcher_render_frame
    bl pi4_launcher_prepare_visible_exec_request
    bl pi4_launcher_present_frame
    bl pi4_launcher_request_recorded_app
    mov x0, xzr
    mov x1, x19
    bl pi4_launcher_render_frame
    adrp x0, pi4_launcher_state
    add x0, x0, :lo12:pi4_launcher_state
    mov x1, #PI4_LAUNCHER_PHASE_SELECTION_READY
    str x1, [x0, #PI4_LAUNCHER_STATE_PHASE]

.Lpi4_launcher_present_after_input:
    bl pi4_launcher_present_frame
    b .Lpi4_launcher_poll

.Lpi4_launcher_wait:
    yield
    b .Lpi4_launcher_poll
.size user_main, . - user_main
.size pi4_launcher_start, . - pi4_launcher_start

.type pi4_launcher_reset_desktop_state, %function
pi4_launcher_reset_desktop_state:
    adrp x0, pi4_launcher_cursor_x
    add x0, x0, :lo12:pi4_launcher_cursor_x
    mov x1, #PI4_LAUNCHER_CURSOR_START_X
    str x1, [x0]
    adrp x0, pi4_launcher_cursor_y
    add x0, x0, :lo12:pi4_launcher_cursor_y
    mov x1, #PI4_LAUNCHER_CURSOR_START_Y
    str x1, [x0]
    adrp x0, pi4_launcher_mouse_buttons
    add x0, x0, :lo12:pi4_launcher_mouse_buttons
    str xzr, [x0]
    adrp x2, pi4_launcher_desktop_app_record_defaults
    add x2, x2, :lo12:pi4_launcher_desktop_app_record_defaults
    adrp x3, pi4_launcher_desktop_app_record_defaults_end
    add x3, x3, :lo12:pi4_launcher_desktop_app_record_defaults_end
.Lpi4_reset_desktop_app_record_next:
    cmp x2, x3
    b.hs .Lpi4_reset_desktop_app_records_done
    ldp x0, x1, [x2], #16
    str x1, [x0]
    b .Lpi4_reset_desktop_app_record_next
.Lpi4_reset_desktop_app_records_done:
    adrp x0, pi4_launcher_present_status
    add x0, x0, :lo12:pi4_launcher_present_status
    str xzr, [x0]
    adrp x0, pi4_launcher_fbinfo_status
    add x0, x0, :lo12:pi4_launcher_fbinfo_status
    mov x1, #-1
    str x1, [x0]
    adrp x0, pi4_launcher_state
    add x0, x0, :lo12:pi4_launcher_state
    mov x1, #PI4_LAUNCHER_PHASE_COLD
    str x1, [x0, #PI4_LAUNCHER_STATE_PHASE]
    mov x1, #PI4_LAUNCHER_INPUT_ACTION_NONE
    str x1, [x0, #PI4_LAUNCHER_STATE_INPUT_ACTION]
    str xzr, [x0, #PI4_LAUNCHER_STATE_PRESENT_ERRNO]
    ret
.size pi4_launcher_reset_desktop_state, . - pi4_launcher_reset_desktop_state

.type pi4_launcher_discover_apps, %function
pi4_launcher_discover_apps:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]

    bl pi4_launcher_reset_app_records

    adrp x0, pi4_launcher_app_index_path
    add x0, x0, :lo12:pi4_launcher_app_index_path
    mov x1, xzr
    adrp x2, pi4_launcher_app_text_buffer
    add x2, x2, :lo12:pi4_launcher_app_text_buffer
    mov x3, #PI4_LAUNCHER_APP_TEXT_BYTES
    adrp x4, pi4_launcher_app_text_size
    add x4, x4, :lo12:pi4_launcher_app_text_size
    bl vibe_user_file_read_at
    cbnz x0, .Lpi4_discover_done

    adrp x20, pi4_launcher_app_text_size
    add x20, x20, :lo12:pi4_launcher_app_text_size
    ldr x20, [x20]
    cbz x20, .Lpi4_discover_done

    adrp x19, pi4_launcher_app_discovery_flags
    add x19, x19, :lo12:pi4_launcher_app_discovery_flags
    mov x21, #PI4_LAUNCHER_APP_INDEX_READY
    str x21, [x19]

    adrp x0, pi4_launcher_app_text_buffer
    add x0, x0, :lo12:pi4_launcher_app_text_buffer
    mov x1, x20
    bl pi4_launcher_read_app_count
    mov x21, x0
    adrp x0, pi4_launcher_app_index_count
    add x0, x0, :lo12:pi4_launcher_app_index_count
    str x21, [x0]
    cbz x21, .Lpi4_discover_done
    cmp x21, #PI4_LAUNCHER_APP_RECORD_COUNT
    b.ls .Lpi4_discover_count_ready
    mov x21, #PI4_LAUNCHER_APP_RECORD_COUNT

.Lpi4_discover_count_ready:
    adrp x23, pi4_launcher_app_manifest_paths
    add x23, x23, :lo12:pi4_launcher_app_manifest_paths
    adrp x24, pi4_launcher_app_index_key_buffer
    add x24, x24, :lo12:pi4_launcher_app_index_key_buffer
    mov x22, xzr

.Lpi4_discover_next_manifest_path:
    cmp x22, x21
    b.hs .Lpi4_discover_load_start

    mov x0, x22
    mov x1, x24
    bl pi4_launcher_build_manifest_key
    cbnz x0, .Lpi4_discover_manifest_advance

    lsl x25, x22, #6
    add x25, x23, x25
    adrp x0, pi4_launcher_app_text_buffer
    add x0, x0, :lo12:pi4_launcher_app_text_buffer
    mov x1, x20
    mov x2, x24
    mov x3, x25
    mov x4, #PI4_LAUNCHER_APP_PATH_BYTES
    bl pi4_launcher_find_key_value_copy

.Lpi4_discover_manifest_advance:
    add x22, x22, #1
    b .Lpi4_discover_next_manifest_path

.Lpi4_discover_load_start:
    mov x22, xzr

.Lpi4_discover_load_next:
    cmp x22, x21
    b.hs .Lpi4_discover_done
    lsl x25, x22, #6
    add x25, x23, x25
    ldrb w0, [x25]
    cbz w0, .Lpi4_discover_load_advance
    lsl x26, x22, #1
    mov x2, #PI4_LAUNCHER_APP_MANIFEST_READY_BASE
    lsl x2, x2, x26
    mov x3, #PI4_LAUNCHER_APP_EXEC_READY_BASE
    lsl x3, x3, x26
    mov x0, x22
    mov x1, x25
    bl pi4_launcher_load_app_manifest

.Lpi4_discover_load_advance:
    add x22, x22, #1
    b .Lpi4_discover_load_next

.Lpi4_discover_done:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_discover_apps, . - pi4_launcher_discover_apps

.type pi4_launcher_reset_app_records, %function
pi4_launcher_reset_app_records:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    adrp x0, pi4_launcher_app_record_names
    add x0, x0, :lo12:pi4_launcher_app_record_names
    mov x1, #(PI4_LAUNCHER_APP_NAME_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT)
    bl pi4_launcher_zero_buffer
    adrp x0, pi4_launcher_app_record_paths
    add x0, x0, :lo12:pi4_launcher_app_record_paths
    mov x1, #(PI4_LAUNCHER_APP_PATH_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT)
    bl pi4_launcher_zero_buffer
    adrp x0, pi4_launcher_app_manifest_paths
    add x0, x0, :lo12:pi4_launcher_app_manifest_paths
    mov x1, #(PI4_LAUNCHER_APP_PATH_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT)
    bl pi4_launcher_zero_buffer
    adrp x0, pi4_launcher_app_record_assets
    add x0, x0, :lo12:pi4_launcher_app_record_assets
    mov x1, #(PI4_LAUNCHER_APP_PATH_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT)
    bl pi4_launcher_zero_buffer
    adrp x0, pi4_launcher_app_record_icons
    add x0, x0, :lo12:pi4_launcher_app_record_icons
    mov x1, #(PI4_LAUNCHER_APP_ICON_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT)
    bl pi4_launcher_zero_buffer

    adrp x0, pi4_launcher_app_text_size
    add x0, x0, :lo12:pi4_launcher_app_text_size
    str xzr, [x0]
    adrp x0, pi4_launcher_app_read_size
    add x0, x0, :lo12:pi4_launcher_app_read_size
    str xzr, [x0]
    adrp x0, pi4_launcher_app_discovery_flags
    add x0, x0, :lo12:pi4_launcher_app_discovery_flags
    str xzr, [x0]
    adrp x0, pi4_launcher_app_discovered_count
    add x0, x0, :lo12:pi4_launcher_app_discovered_count
    str xzr, [x0]
    adrp x0, pi4_launcher_app_index_count
    add x0, x0, :lo12:pi4_launcher_app_index_count
    str xzr, [x0]

    adrp x19, pi4_launcher_app_catalog_table
    add x19, x19, :lo12:pi4_launcher_app_catalog_table
    adrp x21, pi4_launcher_app_record_absent_state
    add x21, x21, :lo12:pi4_launcher_app_record_absent_state
    mov x22, xzr

.Lpi4_reset_app_record_next:
    cmp x22, #PI4_LAUNCHER_APP_RECORD_COUNT
    b.hs .Lpi4_reset_app_records_done
    str x22, [x19]
    mov x0, x22
    bl pi4_launcher_default_name
    str x0, [x19, #PI4_LAUNCHER_APP_RECORD_NAME]
    str xzr, [x19, #PI4_LAUNCHER_APP_RECORD_PATH]
    mov x0, #PI4_LAUNCHER_APP_RECORD_STATE_ABSENT
    str x0, [x19, #PI4_LAUNCHER_APP_RECORD_STATE]
    str x21, [x19, #PI4_LAUNCHER_APP_RECORD_STATE_TEXT]
    add x19, x19, #PI4_LAUNCHER_APP_RECORD_BYTES
    add x22, x22, #1
    b .Lpi4_reset_app_record_next

.Lpi4_reset_app_records_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_launcher_reset_app_records, . - pi4_launcher_reset_app_records

.type pi4_launcher_read_app_count, %function
pi4_launcher_read_app_count:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    mov x19, x0
    mov x20, x1
    mov x21, xzr
    mov x22, xzr
    adrp x0, pi4_launcher_app_count_value
    add x0, x0, :lo12:pi4_launcher_app_count_value
    mov x1, #PI4_LAUNCHER_APP_COUNT_BYTES
    bl pi4_launcher_zero_buffer

    mov x0, x19
    mov x1, x20
    adrp x2, pi4_launcher_key_app_count
    add x2, x2, :lo12:pi4_launcher_key_app_count
    adrp x3, pi4_launcher_app_count_value
    add x3, x3, :lo12:pi4_launcher_app_count_value
    mov x4, #PI4_LAUNCHER_APP_COUNT_BYTES
    bl pi4_launcher_find_key_value_copy
    cbnz x0, .Lpi4_app_count_fail

    adrp x19, pi4_launcher_app_count_value
    add x19, x19, :lo12:pi4_launcher_app_count_value

.Lpi4_app_count_digit:
    ldrb w0, [x19], #1
    cbz w0, .Lpi4_app_count_done
    cmp w0, #'0'
    b.lo .Lpi4_app_count_fail
    cmp w0, #'9'
    b.hi .Lpi4_app_count_fail
    sub w0, w0, #'0'
    mov x1, #10
    madd x21, x21, x1, x0
    add x22, x22, #1
    b .Lpi4_app_count_digit

.Lpi4_app_count_done:
    cbz x22, .Lpi4_app_count_fail
    mov x0, x21
    b .Lpi4_app_count_return

.Lpi4_app_count_fail:
    mov x0, xzr

.Lpi4_app_count_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_read_app_count, . - pi4_launcher_read_app_count

.type pi4_launcher_build_manifest_key, %function
pi4_launcher_build_manifest_key:
    mov x3, x0
    mov w2, #'a'
    strb w2, [x1], #1
    mov w2, #'p'
    strb w2, [x1], #1
    strb w2, [x1], #1
    mov w2, #'.'
    strb w2, [x1], #1
    cbnz x3, .Lpi4_manifest_key_nonzero
    mov w2, #'0'
    strb w2, [x1], #1
    b .Lpi4_manifest_key_suffix

.Lpi4_manifest_key_nonzero:
    mov x4, #10
    mov x5, #1

.Lpi4_manifest_key_power_next:
    udiv x6, x3, x4
    cmp x5, x6
    b.hi .Lpi4_manifest_key_digit_next
    mul x5, x5, x4
    b .Lpi4_manifest_key_power_next

.Lpi4_manifest_key_digit_next:
    udiv x6, x3, x5
    add w2, w6, #'0'
    strb w2, [x1], #1
    msub x3, x6, x5, x3
    udiv x5, x5, x4
    cbnz x5, .Lpi4_manifest_key_digit_next

.Lpi4_manifest_key_suffix:
    mov w2, #'.'
    strb w2, [x1], #1
    mov w2, #'m'
    strb w2, [x1], #1
    mov w2, #'a'
    strb w2, [x1], #1
    mov w2, #'n'
    strb w2, [x1], #1
    mov w2, #'i'
    strb w2, [x1], #1
    mov w2, #'f'
    strb w2, [x1], #1
    mov w2, #'e'
    strb w2, [x1], #1
    mov w2, #'s'
    strb w2, [x1], #1
    mov w2, #'t'
    strb w2, [x1], #1
    mov w2, #'='
    strb w2, [x1], #1
    strb wzr, [x1]
    mov x0, xzr
    ret
.size pi4_launcher_build_manifest_key, . - pi4_launcher_build_manifest_key

.type pi4_launcher_load_app_manifest, %function
pi4_launcher_load_app_manifest:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    cmp x19, #PI4_LAUNCHER_APP_RECORD_COUNT
    b.hs .Lpi4_manifest_done
    cbz x20, .Lpi4_manifest_done
    ldrb w0, [x20]
    cbz w0, .Lpi4_manifest_done

    mov x0, x20
    mov x1, xzr
    adrp x2, pi4_launcher_app_text_buffer
    add x2, x2, :lo12:pi4_launcher_app_text_buffer
    mov x3, #PI4_LAUNCHER_APP_TEXT_BYTES
    adrp x4, pi4_launcher_app_text_size
    add x4, x4, :lo12:pi4_launcher_app_text_size
    bl vibe_user_file_read_at
    cbnz x0, .Lpi4_manifest_done
    adrp x23, pi4_launcher_app_text_size
    add x23, x23, :lo12:pi4_launcher_app_text_size
    ldr x23, [x23]
    cbz x23, .Lpi4_manifest_done

    bl pi4_launcher_or_discovery_flag_x21

    adrp x24, pi4_launcher_app_record_names
    add x24, x24, :lo12:pi4_launcher_app_record_names
    lsl x0, x19, #5
    add x24, x24, x0
    adrp x25, pi4_launcher_app_record_paths
    add x25, x25, :lo12:pi4_launcher_app_record_paths
    lsl x0, x19, #6
    add x25, x25, x0
    adrp x26, pi4_launcher_app_record_assets
    add x26, x26, :lo12:pi4_launcher_app_record_assets
    lsl x0, x19, #6
    add x26, x26, x0

    adrp x0, pi4_launcher_app_text_buffer
    add x0, x0, :lo12:pi4_launcher_app_text_buffer
    mov x1, x23
    adrp x2, pi4_launcher_key_name
    add x2, x2, :lo12:pi4_launcher_key_name
    mov x3, x24
    mov x4, #PI4_LAUNCHER_APP_NAME_BYTES
    bl pi4_launcher_find_key_value_copy
    cbz x0, .Lpi4_manifest_name_ready

    adrp x0, pi4_launcher_app_text_buffer
    add x0, x0, :lo12:pi4_launcher_app_text_buffer
    mov x1, x23
    adrp x2, pi4_launcher_key_id
    add x2, x2, :lo12:pi4_launcher_key_id
    mov x3, x24
    mov x4, #PI4_LAUNCHER_APP_NAME_BYTES
    bl pi4_launcher_find_key_value_copy

.Lpi4_manifest_name_ready:
    ldrb w0, [x24]
    cbnz w0, .Lpi4_manifest_have_name
    mov x0, x19
    bl pi4_launcher_default_name
    mov x24, x0
.Lpi4_manifest_have_name:

    adrp x0, pi4_launcher_app_text_buffer
    add x0, x0, :lo12:pi4_launcher_app_text_buffer
    mov x1, x23
    adrp x2, pi4_launcher_key_exec
    add x2, x2, :lo12:pi4_launcher_key_exec
    mov x3, x25
    mov x4, #PI4_LAUNCHER_APP_PATH_BYTES
    bl pi4_launcher_find_key_value_copy
    cbnz x0, .Lpi4_manifest_done
    ldrb w0, [x25]
    cmp w0, #'/'
    b.ne .Lpi4_manifest_done

    adrp x0, pi4_launcher_app_text_buffer
    add x0, x0, :lo12:pi4_launcher_app_text_buffer
    mov x1, x23
    adrp x2, pi4_launcher_key_asset
    add x2, x2, :lo12:pi4_launcher_key_asset
    mov x3, x26
    mov x4, #PI4_LAUNCHER_APP_PATH_BYTES
    bl pi4_launcher_find_key_value_copy

    adrp x0, pi4_launcher_app_text_buffer
    add x0, x0, :lo12:pi4_launcher_app_text_buffer
    mov x1, x23
    adrp x2, pi4_launcher_key_icon
    add x2, x2, :lo12:pi4_launcher_key_icon
    adrp x3, pi4_launcher_app_record_icons
    add x3, x3, :lo12:pi4_launcher_app_record_icons
    mov x4, #PI4_LAUNCHER_APP_ICON_BYTES
    madd x3, x19, x4, x3
    bl pi4_launcher_find_key_value_copy

    mov x0, x25
    bl pi4_launcher_check_elf_magic
    cbnz x0, .Lpi4_manifest_done

    mov x21, x22
    bl pi4_launcher_or_discovery_flag_x21
    mov x0, x19
    mov x1, x24
    mov x2, x25
    bl pi4_launcher_mark_app_record_present

.Lpi4_manifest_done:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_launcher_load_app_manifest, . - pi4_launcher_load_app_manifest

.type pi4_launcher_or_discovery_flag_x21, %function
pi4_launcher_or_discovery_flag_x21:
    adrp x0, pi4_launcher_app_discovery_flags
    add x0, x0, :lo12:pi4_launcher_app_discovery_flags
    ldr x1, [x0]
    orr x1, x1, x21
    str x1, [x0]
    ret
.size pi4_launcher_or_discovery_flag_x21, . - pi4_launcher_or_discovery_flag_x21

.type pi4_launcher_app_record_entry_ptr, %function
pi4_launcher_app_record_entry_ptr:
    cmp x0, #PI4_LAUNCHER_APP_RECORD_COUNT
    b.hs .Lpi4_app_record_entry_invalid
    adrp x1, pi4_launcher_app_catalog_table
    add x1, x1, :lo12:pi4_launcher_app_catalog_table
    mov x2, #PI4_LAUNCHER_APP_RECORD_BYTES
    madd x0, x0, x2, x1
    ret
.Lpi4_app_record_entry_invalid:
    mov x0, xzr
    ret
.size pi4_launcher_app_record_entry_ptr, . - pi4_launcher_app_record_entry_ptr

.type pi4_launcher_default_name, %function
pi4_launcher_default_name:
    adrp x0, pi4_launcher_app_record_generic_name
    add x0, x0, :lo12:pi4_launcher_app_record_generic_name
    ret
.size pi4_launcher_default_name, . - pi4_launcher_default_name

.type pi4_launcher_mark_app_record_present, %function
pi4_launcher_mark_app_record_present:
    cmp x0, #PI4_LAUNCHER_APP_RECORD_COUNT
    b.hs .Lpi4_mark_app_record_done
    adrp x3, pi4_launcher_app_catalog_table
    add x3, x3, :lo12:pi4_launcher_app_catalog_table
    mov x4, #PI4_LAUNCHER_APP_RECORD_BYTES
    madd x3, x0, x4, x3
    str x0, [x3]
    str x1, [x3, #PI4_LAUNCHER_APP_RECORD_NAME]
    str x2, [x3, #PI4_LAUNCHER_APP_RECORD_PATH]
    mov x4, #PI4_LAUNCHER_APP_RECORD_STATE_PRESENT
    str x4, [x3, #PI4_LAUNCHER_APP_RECORD_STATE]
    adrp x4, pi4_launcher_app_record_present_state
    add x4, x4, :lo12:pi4_launcher_app_record_present_state
    str x4, [x3, #PI4_LAUNCHER_APP_RECORD_STATE_TEXT]
    adrp x3, pi4_launcher_app_discovered_count
    add x3, x3, :lo12:pi4_launcher_app_discovered_count
    ldr x4, [x3]
    add x4, x4, #1
    str x4, [x3]
.Lpi4_mark_app_record_done:
    ret
.size pi4_launcher_mark_app_record_present, . - pi4_launcher_mark_app_record_present

.type pi4_launcher_check_elf_magic, %function
pi4_launcher_check_elf_magic:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x1, xzr
    adrp x2, pi4_launcher_app_magic_buffer
    add x2, x2, :lo12:pi4_launcher_app_magic_buffer
    mov x3, #4
    adrp x4, pi4_launcher_app_read_size
    add x4, x4, :lo12:pi4_launcher_app_read_size
    bl vibe_user_file_read_at
    cbnz x0, .Lpi4_check_elf_fail
    adrp x1, pi4_launcher_app_read_size
    add x1, x1, :lo12:pi4_launcher_app_read_size
    ldr x1, [x1]
    cmp x1, #4
    b.ne .Lpi4_check_elf_fail
    adrp x1, pi4_launcher_app_magic_buffer
    add x1, x1, :lo12:pi4_launcher_app_magic_buffer
    ldrb w2, [x1]
    cmp w2, #0x7f
    b.ne .Lpi4_check_elf_fail
    ldrb w2, [x1, #1]
    cmp w2, #'E'
    b.ne .Lpi4_check_elf_fail
    ldrb w2, [x1, #2]
    cmp w2, #'L'
    b.ne .Lpi4_check_elf_fail
    ldrb w2, [x1, #3]
    cmp w2, #'F'
    b.ne .Lpi4_check_elf_fail
    mov x0, xzr
    b .Lpi4_check_elf_done
.Lpi4_check_elf_fail:
    mov x0, #PI4_VIBE_ENOENT
    neg x0, x0
.Lpi4_check_elf_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_launcher_check_elf_magic, . - pi4_launcher_check_elf_magic

.type pi4_launcher_find_key_value_copy, %function
pi4_launcher_find_key_value_copy:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    add x20, x0, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    cmp x23, #2
    b.lo .Lpi4_find_fail
    cbz x19, .Lpi4_find_fail
    cbz x21, .Lpi4_find_fail
    cbz x22, .Lpi4_find_fail
    mov x24, x19

.Lpi4_find_line:
    cmp x24, x20
    b.hs .Lpi4_find_fail
    ldrb w0, [x24]
    cmp w0, #10
    b.eq .Lpi4_find_advance_one
    cmp w0, #13
    b.eq .Lpi4_find_advance_one
    cmp w0, #'#'
    b.eq .Lpi4_find_skip_line
    mov x25, x24
    mov x26, x21

.Lpi4_find_compare_key:
    ldrb w0, [x26], #1
    cbz w0, .Lpi4_find_matched
    cmp x25, x20
    b.hs .Lpi4_find_skip_line
    ldrb w1, [x25], #1
    cmp w1, w0
    b.ne .Lpi4_find_skip_line
    b .Lpi4_find_compare_key

.Lpi4_find_matched:
    mov x27, xzr
    sub x28, x23, #1

.Lpi4_find_copy_value:
    cmp x25, x20
    b.hs .Lpi4_find_terminate
    ldrb w0, [x25], #1
    cbz w0, .Lpi4_find_terminate
    cmp w0, #10
    b.eq .Lpi4_find_terminate
    cmp w0, #13
    b.eq .Lpi4_find_terminate
    cmp x27, x28
    b.hs .Lpi4_find_fail
    strb w0, [x22, x27]
    add x27, x27, #1
    b .Lpi4_find_copy_value

.Lpi4_find_terminate:
    cbz x27, .Lpi4_find_fail
    strb wzr, [x22, x27]
    mov x0, xzr
    b .Lpi4_find_done

.Lpi4_find_skip_line:
    cmp x24, x20
    b.hs .Lpi4_find_fail
    ldrb w0, [x24], #1
    cmp w0, #10
    b.ne .Lpi4_find_skip_line
    b .Lpi4_find_line

.Lpi4_find_advance_one:
    add x24, x24, #1
    b .Lpi4_find_line

.Lpi4_find_fail:
    mov x0, #PI4_VIBE_ENOENT
    neg x0, x0

.Lpi4_find_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_launcher_find_key_value_copy, . - pi4_launcher_find_key_value_copy

.type pi4_launcher_zero_buffer, %function
pi4_launcher_zero_buffer:
    cbz x1, .Lpi4_zero_done
.Lpi4_zero_next:
    strb wzr, [x0], #1
    subs x1, x1, #1
    b.ne .Lpi4_zero_next
.Lpi4_zero_done:
    ret
.size pi4_launcher_zero_buffer, . - pi4_launcher_zero_buffer

.type pi4_launcher_present_frame, %function
pi4_launcher_present_frame:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    adrp x1, pi4_launcher_state
    add x1, x1, :lo12:pi4_launcher_state
    ldr x2, [x1, #PI4_LAUNCHER_STATE_PRESENT_COUNT]
    add x2, x2, #1
    str x2, [x1, #PI4_LAUNCHER_STATE_PRESENT_COUNT]
    mov x2, #-1
    str x2, [x1, #PI4_LAUNCHER_STATE_PRESENT_STATUS]
    str xzr, [x1, #PI4_LAUNCHER_STATE_PRESENT_ERRNO]

    adrp x0, pi4_launcher_present
    add x0, x0, :lo12:pi4_launcher_present
    bl vibe_user_present_indexed
    mov x19, x0

    adrp x1, pi4_launcher_present_status
    add x1, x1, :lo12:pi4_launcher_present_status
    str x0, [x1]

    adrp x1, pi4_launcher_state
    add x1, x1, :lo12:pi4_launcher_state
    str x0, [x1, #PI4_LAUNCHER_STATE_PRESENT_STATUS]
    mov x2, x0
    cmp x2, #0
    b.ge .Lpi4_launcher_present_errno_ready
    neg x2, x2
    b .Lpi4_launcher_present_errno_store

.Lpi4_launcher_present_errno_ready:
    mov x2, xzr

.Lpi4_launcher_present_errno_store:
    str x2, [x1, #PI4_LAUNCHER_STATE_PRESENT_ERRNO]

    bl pi4_launcher_record_frame_evidence
    mov x0, x19
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_launcher_present_frame, . - pi4_launcher_present_frame

.type pi4_launcher_record_frame_evidence, %function
pi4_launcher_record_frame_evidence:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adrp x0, pi4_launcher_fbinfo
    add x0, x0, :lo12:pi4_launcher_fbinfo
    bl vibe_user_fb_get_info

    adrp x1, pi4_launcher_fbinfo_status
    add x1, x1, :lo12:pi4_launcher_fbinfo_status
    str x0, [x1]

    adrp x1, pi4_launcher_fbinfo_count
    add x1, x1, :lo12:pi4_launcher_fbinfo_count
    ldr x2, [x1]
    add x2, x2, #1
    str x2, [x1]

    cbnz x0, .Lpi4_launcher_frame_evidence_done

    adrp x1, pi4_launcher_fbinfo
    add x1, x1, :lo12:pi4_launcher_fbinfo
    adrp x2, pi4_launcher_fb_dirty_x
    add x2, x2, :lo12:pi4_launcher_fb_dirty_x
    ldr x3, [x1, #PI4_VIBE_FB_INFO_DIRTY_X_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_dirty_y
    add x2, x2, :lo12:pi4_launcher_fb_dirty_y
    ldr x3, [x1, #PI4_VIBE_FB_INFO_DIRTY_Y_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_dirty_width
    add x2, x2, :lo12:pi4_launcher_fb_dirty_width
    ldr x3, [x1, #PI4_VIBE_FB_INFO_DIRTY_WIDTH_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_dirty_height
    add x2, x2, :lo12:pi4_launcher_fb_dirty_height
    ldr x3, [x1, #PI4_VIBE_FB_INFO_DIRTY_HEIGHT_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_dirty_count
    add x2, x2, :lo12:pi4_launcher_fb_dirty_count
    ldr x3, [x1, #PI4_VIBE_FB_INFO_DIRTY_COUNT_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_capabilities
    add x2, x2, :lo12:pi4_launcher_fb_capabilities
    ldr x3, [x1, #PI4_VIBE_FB_INFO_CAPABILITIES_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_present_format
    add x2, x2, :lo12:pi4_launcher_fb_present_format
    ldr x3, [x1, #PI4_VIBE_FB_INFO_PRESENT_FORMAT_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_max_present_width
    add x2, x2, :lo12:pi4_launcher_fb_max_present_width
    ldr x3, [x1, #PI4_VIBE_FB_INFO_MAX_PRESENT_WIDTH_OFFSET]
    str x3, [x2]
    adrp x2, pi4_launcher_fb_max_present_height
    add x2, x2, :lo12:pi4_launcher_fb_max_present_height
    ldr x3, [x1, #PI4_VIBE_FB_INFO_MAX_PRESENT_HEIGHT_OFFSET]
    str x3, [x2]

.Lpi4_launcher_frame_evidence_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_launcher_record_frame_evidence, . - pi4_launcher_record_frame_evidence

.type pi4_launcher_apply_input_event, %function
pi4_launcher_apply_input_event:
    mov x9, x1
    mov x10, #PI4_LAUNCHER_INPUT_ACTION_NONE
    cbz x0, .Lpi4_input_done

    ldr x2, [x0, #PI4_INPUT_EVENT_DEVICE_ID]
    ldr x3, [x0, #PI4_INPUT_EVENT_TYPE]
    cmp x2, #PI4_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_input_keyboard_device
    cmp x2, #PI4_INPUT_DEVICE_USB
    b.eq .Lpi4_input_usb_device
    b .Lpi4_input_uart_event

.Lpi4_input_usb_device:
    cmp x3, #PI4_INPUT_EVENT_KEY
    b.eq .Lpi4_input_keyboard_event_ready
    cmp x3, #PI4_INPUT_EVENT_MOUSE_PACKET
    b.eq pi4_launcher_apply_mouse_event
    b .Lpi4_input_done

.Lpi4_input_keyboard_device:
    cmp x3, #PI4_INPUT_EVENT_KEY
    b.ne .Lpi4_input_done
.Lpi4_input_keyboard_event_ready:
    ldr x4, [x0, #PI4_INPUT_EVENT_VALUE0]
    cmp x4, #PI4_INPUT_KEY_PRESSED
    b.ne .Lpi4_input_done
    ldr x4, [x0, #PI4_INPUT_EVENT_CODE]
    ldr x5, [x0, #PI4_INPUT_EVENT_VALUE1]
    cbnz x5, .Lpi4_input_hid_usage_ready
    cmp x2, #PI4_INPUT_DEVICE_USB
    b.ne .Lpi4_input_hid_usage_ready
    ubfx x5, x4, #PI4_INPUT_KEY_TOKEN_HID_SHIFT, #8
    cbnz x5, .Lpi4_input_hid_usage_ready
    and x5, x4, #PI4_INPUT_KEY_TOKEN_FIELD_MASK

.Lpi4_input_hid_usage_ready:
    and x4, x4, #PI4_INPUT_KEY_SCANCODE_MASK

    cmp x5, #PI4_INPUT_HID_USAGE_1
    b.eq .Lpi4_input_move_doom
    cmp x5, #PI4_INPUT_HID_USAGE_KP_1
    b.eq .Lpi4_input_move_doom
    cmp x5, #PI4_INPUT_HID_USAGE_2
    b.eq .Lpi4_input_move_quake
    cmp x5, #PI4_INPUT_HID_USAGE_KP_2
    b.eq .Lpi4_input_move_quake
    cmp x5, #PI4_INPUT_HID_USAGE_ENTER
    b.eq .Lpi4_input_record_current
    cmp x5, #PI4_INPUT_HID_USAGE_KP_ENTER
    b.eq .Lpi4_input_record_current
    cmp x5, #PI4_INPUT_HID_USAGE_SPACE
    b.eq .Lpi4_input_record_current
    cmp x5, #PI4_INPUT_HID_USAGE_A
    b.eq .Lpi4_input_move_doom
    cmp x5, #PI4_INPUT_HID_USAGE_LEFT
    b.eq .Lpi4_input_move_doom
    cmp x5, #PI4_INPUT_HID_USAGE_W
    b.eq .Lpi4_input_move_doom
    cmp x5, #PI4_INPUT_HID_USAGE_UP
    b.eq .Lpi4_input_move_doom
    cmp x5, #PI4_INPUT_HID_USAGE_D
    b.eq .Lpi4_input_move_quake
    cmp x5, #PI4_INPUT_HID_USAGE_RIGHT
    b.eq .Lpi4_input_move_quake
    cmp x5, #PI4_INPUT_HID_USAGE_S
    b.eq .Lpi4_input_move_quake
    cmp x5, #PI4_INPUT_HID_USAGE_DOWN
    b.eq .Lpi4_input_move_quake

    cmp x4, #PI4_INPUT_SCANCODE_1
    b.eq .Lpi4_input_move_doom
    cmp x4, #PI4_INPUT_SCANCODE_2
    b.eq .Lpi4_input_move_quake
    cmp x4, #PI4_INPUT_SCANCODE_ENTER
    b.eq .Lpi4_input_record_current
    cmp x4, #PI4_INPUT_SCANCODE_SPACE
    b.eq .Lpi4_input_record_current
    cmp x4, #PI4_INPUT_SCANCODE_A
    b.eq .Lpi4_input_move_doom
    cmp x4, #PI4_INPUT_SCANCODE_LEFT
    b.eq .Lpi4_input_move_doom
    cmp x4, #PI4_INPUT_SCANCODE_D
    b.eq .Lpi4_input_move_quake
    cmp x4, #PI4_INPUT_SCANCODE_RIGHT
    b.eq .Lpi4_input_move_quake
    cmp x4, #PI4_INPUT_SCANCODE_W
    b.eq .Lpi4_input_move_doom
    cmp x4, #PI4_INPUT_SCANCODE_UP
    b.eq .Lpi4_input_move_doom
    cmp x4, #PI4_INPUT_SCANCODE_S
    b.eq .Lpi4_input_move_quake
    cmp x4, #PI4_INPUT_SCANCODE_DOWN
    b.eq .Lpi4_input_move_quake
    b .Lpi4_input_done

.Lpi4_input_uart_event:
    cmp x2, #PI4_INPUT_DEVICE_MOUSE
    b.ne .Lpi4_input_uart_device
    cmp x3, #PI4_INPUT_EVENT_MOUSE_PACKET
    b.ne .Lpi4_input_done
    b pi4_launcher_apply_mouse_event

.Lpi4_input_uart_device:
    cmp x2, #PI4_INPUT_DEVICE_UART
    b.ne .Lpi4_input_done
    cmp x3, #PI4_INPUT_EVENT_UART
    b.ne .Lpi4_input_done
    ldr x4, [x0, #PI4_INPUT_EVENT_CODE]
    cmp x4, #PI4_LAUNCHER_UART_EVENT_NONE
    b.eq .Lpi4_input_done

.Lpi4_input_have_uart_event:
    cmp x4, #PI4_LAUNCHER_UART_EVENT_SELECT_1
    b.eq .Lpi4_input_move_doom
    cmp x4, #PI4_LAUNCHER_UART_EVENT_SELECT_2
    b.eq .Lpi4_input_move_quake
    cmp x4, #PI4_LAUNCHER_UART_EVENT_LAUNCH_1
    b.eq .Lpi4_input_record_doom
    cmp x4, #PI4_LAUNCHER_UART_EVENT_LAUNCH_2
    b.eq .Lpi4_input_record_quake
    cmp x4, #PI4_LAUNCHER_UART_EVENT_ENTER
    b.eq .Lpi4_input_record_current
    cmp x4, #PI4_LAUNCHER_UART_EVENT_UP
    b.eq .Lpi4_input_move_doom
    cmp x4, #PI4_LAUNCHER_UART_EVENT_DOWN
    b.eq .Lpi4_input_move_quake
    b .Lpi4_input_done

.Lpi4_input_move_doom:
    mov x9, #PI4_LAUNCHER_APP_RECORD_0
    mov x10, #PI4_LAUNCHER_INPUT_ACTION_MOVED
    b .Lpi4_input_done

.Lpi4_input_move_quake:
    mov x9, #PI4_LAUNCHER_APP_RECORD_1
    mov x10, #PI4_LAUNCHER_INPUT_ACTION_MOVED
    b .Lpi4_input_done

.Lpi4_input_record_doom:
    mov x9, #PI4_LAUNCHER_APP_RECORD_0
    mov x10, #PI4_LAUNCHER_INPUT_ACTION_RECORD
    b .Lpi4_input_done

.Lpi4_input_record_quake:
    mov x9, #PI4_LAUNCHER_APP_RECORD_1
    mov x10, #PI4_LAUNCHER_INPUT_ACTION_RECORD
    b .Lpi4_input_done

.Lpi4_input_record_current:
    mov x10, #PI4_LAUNCHER_INPUT_ACTION_RECORD

.Lpi4_input_done:
    mov x0, x9
    mov x1, x10
    ret
.size pi4_launcher_apply_input_event, . - pi4_launcher_apply_input_event

.type pi4_launcher_apply_mouse_event, %function
pi4_launcher_apply_mouse_event:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]

    mov x19, x0
    mov x20, x1
    mov x21, #PI4_LAUNCHER_INPUT_ACTION_NONE

    adrp x22, pi4_launcher_cursor_x
    add x22, x22, :lo12:pi4_launcher_cursor_x
    ldr x0, [x22]
    ldr x1, [x19, #PI4_INPUT_EVENT_VALUE0]
    add x0, x0, x1
    bl pi4_launcher_clip_cursor_x
    str x0, [x22]
    mov x22, x0

    adrp x23, pi4_launcher_cursor_y
    add x23, x23, :lo12:pi4_launcher_cursor_y
    ldr x0, [x23]
    ldr x1, [x19, #PI4_INPUT_EVENT_VALUE1]
    sub x0, x0, x1
    bl pi4_launcher_clip_cursor_y
    str x0, [x23]
    mov x23, x0

    mov x0, x22
    mov x1, x23
    bl pi4_launcher_pointer_focus
    mov x9, x0
    adrp x15, pi4_launcher_hover_app_record
    add x15, x15, :lo12:pi4_launcher_hover_app_record
    str x9, [x15]

    ldr x10, [x19, #PI4_INPUT_EVENT_CODE]
    adrp x11, pi4_launcher_mouse_buttons
    add x11, x11, :lo12:pi4_launcher_mouse_buttons
    ldr x12, [x11]
    str x10, [x11]
    eor x13, x10, x12

    adrp x14, pi4_launcher_active_app_record
    add x14, x14, :lo12:pi4_launcher_active_app_record
    tst x10, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.eq .Lpi4_mouse_clear_active
    cmp x9, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_mouse_clear_active
    str x9, [x14]
    b .Lpi4_mouse_active_ready

.Lpi4_mouse_clear_active:
    mov x15, #PI4_LAUNCHER_APP_RECORD_NONE
    str x15, [x14]

.Lpi4_mouse_active_ready:
    tst x10, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.eq .Lpi4_mouse_focus
    tst x12, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.ne .Lpi4_mouse_focus
    cmp x9, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_mouse_focus
    mov x20, x9
    mov x21, #PI4_LAUNCHER_INPUT_ACTION_RECORD
    b .Lpi4_mouse_done

.Lpi4_mouse_focus:
    cmp x9, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_mouse_motion
    cmp x9, x20
    b.eq .Lpi4_mouse_motion
    mov x20, x9
    mov x21, #PI4_LAUNCHER_INPUT_ACTION_MOVED
    b .Lpi4_mouse_done

.Lpi4_mouse_motion:
    ldr x14, [x19, #PI4_INPUT_EVENT_VALUE0]
    cbnz x14, .Lpi4_mouse_mark_moved
    ldr x14, [x19, #PI4_INPUT_EVENT_VALUE1]
    cbnz x14, .Lpi4_mouse_mark_moved
    cbz x13, .Lpi4_mouse_done

.Lpi4_mouse_mark_moved:
    mov x21, #PI4_LAUNCHER_INPUT_ACTION_MOVED

.Lpi4_mouse_done:
    mov x0, x20
    mov x1, x21
    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_apply_mouse_event, . - pi4_launcher_apply_mouse_event

.type pi4_launcher_clip_cursor_x, %function
pi4_launcher_clip_cursor_x:
    cmp x0, #0
    b.ge .Lpi4_clip_cursor_x_nonnegative
    mov x0, xzr
    ret
.Lpi4_clip_cursor_x_nonnegative:
    cmp x0, #PI4_LAUNCHER_CURSOR_MAX_X
    b.le .Lpi4_clip_cursor_x_done
    mov x0, #PI4_LAUNCHER_CURSOR_MAX_X
.Lpi4_clip_cursor_x_done:
    ret
.size pi4_launcher_clip_cursor_x, . - pi4_launcher_clip_cursor_x

.type pi4_launcher_clip_cursor_y, %function
pi4_launcher_clip_cursor_y:
    cmp x0, #0
    b.ge .Lpi4_clip_cursor_y_nonnegative
    mov x0, xzr
    ret
.Lpi4_clip_cursor_y_nonnegative:
    cmp x0, #PI4_LAUNCHER_CURSOR_MAX_Y
    b.le .Lpi4_clip_cursor_y_done
    mov x0, #PI4_LAUNCHER_CURSOR_MAX_Y
.Lpi4_clip_cursor_y_done:
    ret
.size pi4_launcher_clip_cursor_y, . - pi4_launcher_clip_cursor_y

.type pi4_launcher_pointer_focus, %function
pi4_launcher_pointer_focus:
    cmp x1, #PI4_LAUNCHER_CARD_HIT_Y0
    b.lt .Lpi4_pointer_none
    ldr x2, =PI4_LAUNCHER_CARD_HIT_Y1
    cmp x1, x2
    b.gt .Lpi4_pointer_none

    adrp x4, pi4_launcher_card_records
    add x4, x4, :lo12:pi4_launcher_card_records
    mov x5, xzr

.Lpi4_pointer_record_loop:
    cmp x5, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_pointer_none
    ldr x6, [x4, #PI4_LAUNCHER_CARD_RECORD_CARD_X]
    sub x7, x6, #PI4_LAUNCHER_CARD_HIT_PAD_X
    cmp x0, x7
    b.lt .Lpi4_pointer_next_record
    add x7, x6, #PI4_LAUNCHER_CARD_W
    add x7, x7, #(PI4_LAUNCHER_CARD_HIT_PAD_X - 1)
    cmp x0, x7
    b.gt .Lpi4_pointer_next_record
    ldr x0, [x4, #PI4_LAUNCHER_CARD_RECORD_INDEX]
    ret

.Lpi4_pointer_next_record:
    add x5, x5, #1
    add x4, x4, #PI4_LAUNCHER_CARD_RECORD_BYTES
    b .Lpi4_pointer_record_loop

.Lpi4_pointer_none:
    mov x0, #PI4_LAUNCHER_APP_RECORD_COUNT
    ret
.size pi4_launcher_pointer_focus, . - pi4_launcher_pointer_focus

.type pi4_launcher_record_selection, %function
pi4_launcher_record_selection:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    mov x19, x0
    adrp x20, pi4_launcher_state
    add x20, x20, :lo12:pi4_launcher_state
    mov x2, #PI4_LAUNCHER_PHASE_SELECTION_READY
    str x2, [x20, #PI4_LAUNCHER_STATE_PHASE]
    str x19, [x20, #PI4_LAUNCHER_STATE_RECORD_INDEX]
    adrp x4, pi4_launcher_active_app_record
    add x4, x4, :lo12:pi4_launcher_active_app_record
    str x19, [x4]
    adrp x4, pi4_launcher_failed_app_record
    add x4, x4, :lo12:pi4_launcher_failed_app_record
    mov x3, #PI4_LAUNCHER_APP_RECORD_NONE
    str x3, [x4]

    mov x0, x19
    bl pi4_launcher_app_record_entry_ptr
    cbz x0, .Lpi4_record_selection_invalid

    mov x2, x0
    str x2, [x20, #PI4_LAUNCHER_STATE_RECORD_ENTRY]
    ldr x3, [x2, #PI4_LAUNCHER_APP_RECORD_NAME]
    str x3, [x20, #PI4_LAUNCHER_STATE_RECORD_NAME]
    ldr x3, [x2, #PI4_LAUNCHER_APP_RECORD_PATH]
    str x3, [x20, #PI4_LAUNCHER_STATE_RECORD_PATH]
    ldr x3, [x2, #PI4_LAUNCHER_APP_RECORD_STATE]
    str x3, [x20, #PI4_LAUNCHER_STATE_RECORD_STATE]
    ldr x3, [x2, #PI4_LAUNCHER_APP_RECORD_STATE_TEXT]
    str x3, [x20, #PI4_LAUNCHER_STATE_RECORD_STATE_TEXT]
    b .Lpi4_record_selection_count

.Lpi4_record_selection_invalid:
    str xzr, [x20, #PI4_LAUNCHER_STATE_RECORD_ENTRY]
    str xzr, [x20, #PI4_LAUNCHER_STATE_RECORD_NAME]
    str xzr, [x20, #PI4_LAUNCHER_STATE_RECORD_PATH]
    str xzr, [x20, #PI4_LAUNCHER_STATE_RECORD_STATE]
    adrp x3, pi4_launcher_app_record_absent_state
    add x3, x3, :lo12:pi4_launcher_app_record_absent_state
    str x3, [x20, #PI4_LAUNCHER_STATE_RECORD_STATE_TEXT]

.Lpi4_record_selection_count:
    ldr x3, [x20, #PI4_LAUNCHER_STATE_RECORD_COUNT]
    add x3, x3, #1
    str x3, [x20, #PI4_LAUNCHER_STATE_RECORD_COUNT]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_launcher_record_selection, . - pi4_launcher_record_selection

.type pi4_launcher_prepare_visible_exec_request, %function
pi4_launcher_prepare_visible_exec_request:
    adrp x0, pi4_launcher_state
    add x0, x0, :lo12:pi4_launcher_state
    adrp x1, pi4_launcher_exec_request
    add x1, x1, :lo12:pi4_launcher_exec_request
    str x1, [x0, #PI4_LAUNCHER_STATE_EXEC_REQUEST]
    mov x2, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    str x2, [x1, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET]
    str x2, [x0, #PI4_LAUNCHER_STATE_EXEC_REQUEST_ABI]
    mov x2, #PI4_VIBE_EXEC_REQUEST_BYTES
    str x2, [x1, #PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET]
    str x2, [x0, #PI4_LAUNCHER_STATE_EXEC_REQUEST_BYTES]
    str xzr, [x0, #PI4_LAUNCHER_STATE_EXEC_RESULT]
    str xzr, [x0, #PI4_LAUNCHER_STATE_EXEC_ERRNO]

    ldr x2, [x0, #PI4_LAUNCHER_STATE_RECORD_INDEX]
    cmp x2, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_launcher_prepare_visible_inval

    adrp x4, pi4_launcher_app_catalog_table
    add x4, x4, :lo12:pi4_launcher_app_catalog_table
    mov x3, #PI4_LAUNCHER_APP_RECORD_BYTES
    madd x4, x2, x3, x4
    ldr x5, [x4]
    cmp x5, x2
    b.ne .Lpi4_launcher_prepare_visible_inval
    ldr x6, [x4, #PI4_LAUNCHER_APP_RECORD_PATH]
    cbz x6, .Lpi4_launcher_prepare_visible_inval

    mov x7, #-1
    str x7, [x1, #PI4_LAUNCHER_EXEC_REQUEST_RESERVED_OFFSET]
    str x7, [x0, #PI4_LAUNCHER_STATE_EXEC_REQUEST_RESERVED]
    str x6, [x1, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    str x6, [x0, #PI4_LAUNCHER_STATE_EXEC_REQUEST_PATH]
    adrp x7, pi4_launcher_exec_argv
    add x7, x7, :lo12:pi4_launcher_exec_argv
    str x6, [x7]
    str xzr, [x7, #8]
    str x7, [x0, #PI4_LAUNCHER_STATE_EXEC_ARGV]
    mov x8, #PI4_LAUNCHER_EXEC_ATTEMPT_PREPARED
    str x8, [x0, #PI4_LAUNCHER_STATE_EXEC_ATTEMPT_STATE]
    mov x8, #PI4_LAUNCHER_PHASE_EXEC_WAIT
    str x8, [x0, #PI4_LAUNCHER_STATE_PHASE]
    mov x0, xzr
    ret

.Lpi4_launcher_prepare_visible_inval:
    mov x8, #-1
    str x8, [x1, #PI4_LAUNCHER_EXEC_REQUEST_RESERVED_OFFSET]
    str x8, [x0, #PI4_LAUNCHER_STATE_EXEC_REQUEST_RESERVED]
    str xzr, [x1, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    str xzr, [x0, #PI4_LAUNCHER_STATE_EXEC_REQUEST_PATH]
    adrp x7, pi4_launcher_exec_argv
    add x7, x7, :lo12:pi4_launcher_exec_argv
    str xzr, [x7]
    str xzr, [x7, #8]
    str x7, [x0, #PI4_LAUNCHER_STATE_EXEC_ARGV]
    mov x8, #-PI4_VIBE_EINVAL
    str x8, [x0, #PI4_LAUNCHER_STATE_EXEC_RESULT]
    mov x8, #PI4_VIBE_EINVAL
    str x8, [x0, #PI4_LAUNCHER_STATE_EXEC_ERRNO]
    mov x8, #PI4_LAUNCHER_EXEC_ATTEMPT_FAILED
    str x8, [x0, #PI4_LAUNCHER_STATE_EXEC_ATTEMPT_STATE]
    mov x8, #PI4_LAUNCHER_PHASE_SELECTION_READY
    str x8, [x0, #PI4_LAUNCHER_STATE_PHASE]
    mov x0, #-PI4_VIBE_EINVAL
    ret
.size pi4_launcher_prepare_visible_exec_request, . - pi4_launcher_prepare_visible_exec_request

.type pi4_launcher_request_recorded_app, %function
pi4_launcher_request_recorded_app:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    adrp x19, pi4_launcher_state
    add x19, x19, :lo12:pi4_launcher_state
    adrp x20, pi4_launcher_exec_request
    add x20, x20, :lo12:pi4_launcher_exec_request
    str x20, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST]
    mov x0, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    str x0, [x20, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET]
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_ABI]
    mov x0, #PI4_VIBE_EXEC_REQUEST_BYTES
    str x0, [x20, #PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET]
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_BYTES]
    mov x0, #-PI4_VIBE_EINVAL
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_RESULT]
    mov x0, #PI4_VIBE_EINVAL
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_ERRNO]
    ldr x0, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_COUNT]
    add x0, x0, #1
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_COUNT]
    mov x0, #PI4_LAUNCHER_EXEC_ATTEMPT_FAILED
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_ATTEMPT_STATE]
    mov x0, #PI4_LAUNCHER_PHASE_SELECTION_READY
    str x0, [x19, #PI4_LAUNCHER_STATE_PHASE]
    mov x0, #-1
    str x0, [x20, #PI4_LAUNCHER_EXEC_REQUEST_RESERVED_OFFSET]
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_RESERVED]
    str xzr, [x20, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    str xzr, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_PATH]

    ldr x21, [x19, #PI4_LAUNCHER_STATE_RECORD_INDEX]
    cmp x21, #PI4_LAUNCHER_APP_RECORD_COUNT
    b.hs .Lpi4_launcher_exec_local_inval

    adrp x22, pi4_launcher_app_catalog_table
    add x22, x22, :lo12:pi4_launcher_app_catalog_table
    mov x0, #PI4_LAUNCHER_APP_RECORD_BYTES
    madd x22, x21, x0, x22
    ldr x0, [x22]
    cmp x0, x21
    b.ne .Lpi4_launcher_exec_local_inval
    ldr x22, [x22, #PI4_LAUNCHER_APP_RECORD_PATH]
    cbz x22, .Lpi4_launcher_exec_local_inval

    mov x0, #-1
    str x0, [x20, #PI4_LAUNCHER_EXEC_REQUEST_RESERVED_OFFSET]
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_RESERVED]
    str x22, [x20, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    str x22, [x19, #PI4_LAUNCHER_STATE_EXEC_REQUEST_PATH]

    adrp x1, pi4_launcher_exec_argv
    add x1, x1, :lo12:pi4_launcher_exec_argv
    str x22, [x1]
    str xzr, [x1, #8]
.Lpi4_launcher_exec_have_argv:
    str x1, [x19, #PI4_LAUNCHER_STATE_EXEC_ARGV]
    mov x2, #PI4_LAUNCHER_EXEC_ATTEMPT_PREPARED
    str x2, [x19, #PI4_LAUNCHER_STATE_EXEC_ATTEMPT_STATE]
    mov x2, #PI4_LAUNCHER_PHASE_EXEC_WAIT
    str x2, [x19, #PI4_LAUNCHER_STATE_PHASE]
    mov x0, x20
    adrp x2, pi4_launcher_exec_envp
    add x2, x2, :lo12:pi4_launcher_exec_envp
    bl vibe_user_exec_request

    mov x21, x0
    str x21, [x19, #PI4_LAUNCHER_STATE_EXEC_RESULT]
    mov x2, #PI4_LAUNCHER_EXEC_ATTEMPT_RETURNED
    cmp x21, #0
    b.ge .Lpi4_launcher_exec_attempt_ready
    mov x2, #PI4_LAUNCHER_EXEC_ATTEMPT_FAILED
    mov x3, #PI4_VIBE_ENOSYS
    neg x3, x3
    cmp x21, x3
    b.ne .Lpi4_launcher_exec_attempt_ready
    mov x2, #PI4_LAUNCHER_EXEC_ATTEMPT_ENOSYS

.Lpi4_launcher_exec_attempt_ready:
    str x2, [x19, #PI4_LAUNCHER_STATE_EXEC_ATTEMPT_STATE]
    mov x2, x21
    cmp x2, #0
    b.ge .Lpi4_launcher_exec_errno_zero
    neg x2, x2
    b .Lpi4_launcher_exec_errno_ready

.Lpi4_launcher_exec_errno_zero:
    mov x2, xzr

.Lpi4_launcher_exec_errno_ready:
    str x2, [x19, #PI4_LAUNCHER_STATE_EXEC_ERRNO]
    b .Lpi4_launcher_exec_returned_failure

.Lpi4_launcher_exec_returned_failure:
    adrp x2, pi4_launcher_active_app_record
    add x2, x2, :lo12:pi4_launcher_active_app_record
    mov x3, #PI4_LAUNCHER_APP_RECORD_NONE
    str x3, [x2]
    adrp x2, pi4_launcher_failed_app_record
    add x2, x2, :lo12:pi4_launcher_failed_app_record
    ldr x3, [x19, #PI4_LAUNCHER_STATE_RECORD_INDEX]
    str x3, [x2]

.Lpi4_launcher_exec_update_count:
    ldr x0, [x19, #PI4_LAUNCHER_STATE_EXEC_COUNT]
    add x0, x0, #1
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_COUNT]
    mov x0, #PI4_LAUNCHER_PHASE_SELECTION_READY
    str x0, [x19, #PI4_LAUNCHER_STATE_PHASE]
    mov x0, x21

    b .Lpi4_launcher_exec_done

.Lpi4_launcher_exec_local_inval:
    mov x21, #-PI4_VIBE_EINVAL
    adrp x2, pi4_launcher_active_app_record
    add x2, x2, :lo12:pi4_launcher_active_app_record
    mov x3, #PI4_LAUNCHER_APP_RECORD_NONE
    str x3, [x2]
    adrp x2, pi4_launcher_failed_app_record
    add x2, x2, :lo12:pi4_launcher_failed_app_record
    ldr x3, [x19, #PI4_LAUNCHER_STATE_RECORD_INDEX]
    str x3, [x2]
    ldr x0, [x19, #PI4_LAUNCHER_STATE_EXEC_COUNT]
    add x0, x0, #1
    str x0, [x19, #PI4_LAUNCHER_STATE_EXEC_COUNT]
    mov x0, x21

.Lpi4_launcher_exec_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_request_recorded_app, . - pi4_launcher_request_recorded_app

.section .text.pi4_launcher.render, "ax", %progbits
.balign 16
.global pi4_launcher_render_frame
.type pi4_launcher_render_frame, %function
pi4_launcher_render_frame:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    cbnz x0, .Lpi4_render_have_frame
    adrp x0, pi4_launcher_frame
    add x0, x0, :lo12:pi4_launcher_frame

.Lpi4_render_have_frame:
    mov x19, x0
    cmp x1, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    csel x20, xzr, x1, hs

    mov x0, x19
    bl pi4_launcher_fill_index_pattern

    mov x0, x19
    mov x1, #0
    mov x2, #684
    mov x3, #PI4_LAUNCHER_FRAME_WIDTH
    mov x4, #36
    mov x5, #PI4_COLOR_BG1
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #96
    mov x2, #692
    mov x3, #1088
    mov x4, #8
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #0
    mov x2, #0
    mov x3, #PI4_LAUNCHER_FRAME_WIDTH
    mov x4, #PI4_LAUNCHER_TOPBAR_HEIGHT
    mov x5, #PI4_COLOR_PANEL
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #20
    mov x2, #18
    mov x3, #18
    mov x4, #18
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #48
    mov x2, #18
    mov x3, #18
    mov x4, #18
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #76
    mov x2, #18
    mov x3, #18
    mov x4, #18
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #1168
    mov x2, #22
    mov x3, #72
    mov x4, #10
    mov x5, #PI4_COLOR_BG1
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #1180
    mov x2, #24
    mov x3, #16
    mov x4, #6
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #1204
    mov x2, #24
    mov x3, #24
    mov x4, #6
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #0
    mov x2, #PI4_LAUNCHER_TOPBAR_HEIGHT
    mov x3, #PI4_LAUNCHER_FRAME_WIDTH
    mov x4, #6
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_WINDOW_X
    add x1, x1, #6
    mov x2, #PI4_LAUNCHER_WINDOW_Y
    add x2, x2, #6
    mov x3, #PI4_LAUNCHER_WINDOW_W
    mov x4, #PI4_LAUNCHER_WINDOW_H
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_WINDOW_X
    mov x2, #PI4_LAUNCHER_WINDOW_Y
    mov x3, #PI4_LAUNCHER_WINDOW_W
    mov x4, #PI4_LAUNCHER_WINDOW_H
    mov x5, #PI4_COLOR_PANEL
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_WINDOW_X
    mov x2, #PI4_LAUNCHER_WINDOW_Y
    mov x3, #PI4_LAUNCHER_WINDOW_W
    mov x4, #PI4_LAUNCHER_WINDOW_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_WINDOW_X
    mov x2, #PI4_LAUNCHER_WINDOW_Y
    mov x3, #PI4_LAUNCHER_WINDOW_W
    mov x4, #PI4_LAUNCHER_WINDOW_H
    mov x5, #PI4_COLOR_HILITE
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    mov x0, x19
    mov x1, #64
    mov x2, #96
    mov x3, #1152
    mov x4, #40
    mov x5, #PI4_COLOR_BG1
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #96
    mov x2, #108
    mov x3, #348
    mov x4, #16
    mov x5, #PI4_COLOR_DOOM_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #484
    mov x2, #108
    mov x3, #312
    mov x4, #16
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #836
    mov x2, #108
    mov x3, #348
    mov x4, #16
    mov x5, #PI4_COLOR_QUAKE_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #128
    mov x2, #132
    mov x3, #240
    mov x4, #10
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #912
    mov x2, #132
    mov x3, #240
    mov x4, #10
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    add x1, x1, #8
    mov x2, #PI4_LAUNCHER_DOCK_Y
    add x2, x2, #8
    mov x3, #PI4_LAUNCHER_DOCK_W
    mov x4, #PI4_LAUNCHER_DOCK_H
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    mov x2, #PI4_LAUNCHER_DOCK_Y
    mov x3, #PI4_LAUNCHER_DOCK_W
    mov x4, #PI4_LAUNCHER_DOCK_H
    mov x5, #PI4_COLOR_PANEL
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    mov x2, #PI4_LAUNCHER_DOCK_Y
    mov x3, #PI4_LAUNCHER_DOCK_W
    mov x4, #PI4_LAUNCHER_DOCK_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    mov x2, #PI4_LAUNCHER_DOCK_Y
    mov x3, #PI4_LAUNCHER_DOCK_W
    mov x4, #PI4_LAUNCHER_DOCK_H
    mov x5, #PI4_COLOR_HILITE
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    add x1, x1, #8
    mov x2, #PI4_LAUNCHER_DOCK_Y
    add x2, x2, #8
    mov x3, #PI4_LAUNCHER_DOCK_W
    sub x3, x3, #16
    mov x4, #4
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    add x1, x1, #8
    mov x2, #PI4_LAUNCHER_DOCK_Y
    add x2, x2, #18
    mov x3, #PI4_LAUNCHER_DOCK_W
    sub x3, x3, #16
    mov x4, #2
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    add x1, x1, #32
    mov x2, #PI4_LAUNCHER_DOCK_Y
    add x2, x2, #8
    mov x3, #16
    mov x4, #16
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    add x1, x1, #56
    mov x2, #PI4_LAUNCHER_DOCK_Y
    add x2, x2, #8
    mov x3, #16
    mov x4, #16
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOCK_X
    add x1, x1, #80
    mov x2, #PI4_LAUNCHER_DOCK_Y
    add x2, x2, #8
    mov x3, #16
    mov x4, #16
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #56
    mov x2, #200
    mov x3, #1168
    mov x4, #448
    mov x5, #PI4_COLOR_BG1
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #640
    mov x2, #208
    mov x3, #2
    mov x4, #424
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #644
    mov x2, #208
    mov x3, #2
    mov x4, #424
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    bl pi4_launcher_render_card_bases

    mov x0, x19
    mov x1, x20
    bl pi4_launcher_draw_app_record_selected

    adrp x21, pi4_launcher_hover_app_record
    add x21, x21, :lo12:pi4_launcher_hover_app_record
    ldr x1, [x21]
    mov x0, x19
    bl pi4_launcher_draw_app_record_hover

    adrp x21, pi4_launcher_active_app_record
    add x21, x21, :lo12:pi4_launcher_active_app_record
    ldr x1, [x21]
    mov x0, x19
    bl pi4_launcher_draw_app_record_active

    adrp x21, pi4_launcher_failed_app_record
    add x21, x21, :lo12:pi4_launcher_failed_app_record
    ldr x1, [x21]
    mov x0, x19
    bl pi4_launcher_draw_app_record_failed

    mov x0, x19
    bl pi4_launcher_render_card_foregrounds
    b .Lpi4_render_cards_done

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #10
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #12
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #10
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #12
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_CARD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_CARD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_CHROME_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_TITLE_Y_OFF
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #(PI4_LAUNCHER_CARD_CHROME_INSET * 2)
    mov x4, #PI4_LAUNCHER_CARD_TITLE_H
    mov x5, #PI4_COLOR_PANEL
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_CHROME_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_TITLE_Y_OFF
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #(PI4_LAUNCHER_CARD_CHROME_INSET * 2)
    mov x4, #PI4_LAUNCHER_CARD_TITLE_H
    mov x5, #PI4_COLOR_PANEL
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_CHROME_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_TITLE_Y_OFF + PI4_LAUNCHER_CARD_TITLE_H + 2
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #(PI4_LAUNCHER_CARD_CHROME_INSET * 2)
    mov x4, #2
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_CHROME_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_TITLE_Y_OFF + PI4_LAUNCHER_CARD_TITLE_H + 2
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #(PI4_LAUNCHER_CARD_CHROME_INSET * 2)
    mov x4, #2
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    mov x5, #PI4_COLOR_DOOM_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    mov x5, #PI4_COLOR_QUAKE_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    bl pi4_launcher_draw_doom_poster

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    bl pi4_launcher_draw_quake_poster

    adrp x6, pi4_launcher_art_flags
    add x6, x6, :lo12:pi4_launcher_art_flags
    ldr x6, [x6]
    tbz x6, #PI4_LAUNCHER_APP_RECORD_0, .Lpi4_render_doom_card_art_done
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    adrp x5, pi4_launcher_doom_icon_pixels
    add x5, x5, :lo12:pi4_launcher_doom_icon_pixels
    bl pi4_launcher_draw_icon_pixels_rect

.Lpi4_render_doom_card_art_done:
    adrp x6, pi4_launcher_art_flags
    add x6, x6, :lo12:pi4_launcher_art_flags
    ldr x6, [x6]
    tbz x6, #PI4_LAUNCHER_APP_RECORD_1, .Lpi4_render_quake_card_art_done
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    adrp x5, pi4_launcher_quake_icon_pixels
    add x5, x5, :lo12:pi4_launcher_quake_icon_pixels
    bl pi4_launcher_draw_icon_pixels_rect

.Lpi4_render_quake_card_art_done:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_COLOR_DOOM_FIRE
    mov x3, #PI4_COLOR_BG1
    mov x4, #PI4_COLOR_BORDER
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_draw_launch_button

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_COLOR_QUAKE_GOLD
    mov x3, #PI4_COLOR_BG1
    mov x4, #PI4_COLOR_BORDER
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_draw_launch_button

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_HILITE
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_HILITE
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    cmp x20, #PI4_LAUNCHER_APP_RECORD_1
    b.eq .Lpi4_render_select_quake

    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    sub x1, x1, #8
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #8
    mov x3, #PI4_LAUNCHER_CARD_W
    add x3, x3, #16
    mov x4, #PI4_LAUNCHER_CARD_H
    add x4, x4, #16
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_draw_border
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    sub x1, x1, #4
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #4
    mov x3, #PI4_LAUNCHER_CARD_W
    add x3, x3, #8
    mov x4, #PI4_LAUNCHER_CARD_H
    add x4, x4, #8
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_draw_border
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #14
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #14
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #32
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 72
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #64
    mov x4, #16
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_COLOR_DOOM_FIRE
    mov x3, #PI4_COLOR_PANEL
    mov x4, #PI4_COLOR_HILITE
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_draw_launch_button
    b .Lpi4_render_selected_done

.Lpi4_render_select_quake:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    sub x1, x1, #8
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #8
    mov x3, #PI4_LAUNCHER_CARD_W
    add x3, x3, #16
    mov x4, #PI4_LAUNCHER_CARD_H
    add x4, x4, #16
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_draw_border
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    sub x1, x1, #4
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #4
    mov x3, #PI4_LAUNCHER_CARD_W
    add x3, x3, #8
    mov x4, #PI4_LAUNCHER_CARD_H
    add x4, x4, #8
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_draw_border
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #14
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #14
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #32
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 72
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #64
    mov x4, #16
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_COLOR_QUAKE_GOLD
    mov x3, #PI4_COLOR_PANEL
    mov x4, #PI4_COLOR_HILITE
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_draw_launch_button

.Lpi4_render_selected_done:
    adrp x21, pi4_launcher_hover_app_record
    add x21, x21, :lo12:pi4_launcher_hover_app_record
    ldr x21, [x21]
    cmp x21, #PI4_LAUNCHER_APP_RECORD_0
    b.eq .Lpi4_render_hover_doom
    cmp x21, #PI4_LAUNCHER_APP_RECORD_1
    b.eq .Lpi4_render_hover_quake
    b .Lpi4_render_hover_done

.Lpi4_render_hover_doom:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_COLOR_TEXT
    bl pi4_launcher_draw_hover_brackets
    b .Lpi4_render_hover_done

.Lpi4_render_hover_quake:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_COLOR_TEXT
    bl pi4_launcher_draw_hover_brackets

.Lpi4_render_hover_done:
    adrp x21, pi4_launcher_active_app_record
    add x21, x21, :lo12:pi4_launcher_active_app_record
    ldr x21, [x21]
    cmp x21, #PI4_LAUNCHER_APP_RECORD_0
    b.eq .Lpi4_render_active_doom
    cmp x21, #PI4_LAUNCHER_APP_RECORD_1
    b.eq .Lpi4_render_active_quake
    b .Lpi4_render_active_done

.Lpi4_render_active_doom:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #16
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #24
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 48
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #32
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #40
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 36
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #80
    mov x4, #8
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_COLOR_SELECTED
    mov x3, #PI4_COLOR_HILITE
    mov x4, #PI4_COLOR_SELECTED
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_launch_button
    b .Lpi4_render_active_done

.Lpi4_render_active_quake:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #16
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #24
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 48
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #32
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #40
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 36
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #80
    mov x4, #8
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_COLOR_SELECTED
    mov x3, #PI4_COLOR_HILITE
    mov x4, #PI4_COLOR_SELECTED
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_launch_button

.Lpi4_render_active_done:
    adrp x21, pi4_launcher_failed_app_record
    add x21, x21, :lo12:pi4_launcher_failed_app_record
    ldr x21, [x21]
    cmp x21, #PI4_LAUNCHER_APP_RECORD_0
    b.eq .Lpi4_render_failed_doom
    cmp x21, #PI4_LAUNCHER_APP_RECORD_1
    b.eq .Lpi4_render_failed_quake
    b .Lpi4_render_failed_done

.Lpi4_render_failed_doom:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 92
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #36
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    add x1, x1, #40
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 80
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #80
    mov x4, #12
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_COLOR_DOOM_FIRE
    mov x3, #PI4_COLOR_DOOM_FIRE
    mov x4, #PI4_COLOR_BLACK
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_launch_button
    b .Lpi4_render_failed_done

.Lpi4_render_failed_quake:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 92
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #36
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    add x1, x1, #40
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 80
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #80
    mov x4, #12
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_COLOR_DOOM_FIRE
    mov x3, #PI4_COLOR_DOOM_FIRE
    mov x4, #PI4_COLOR_BLACK
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_launch_button

.Lpi4_render_failed_done:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_CARD_X
    mov x2, #PI4_COLOR_DOOM_FIRE
    mov x3, #PI4_COLOR_HILITE
    mov x4, #PI4_COLOR_BLACK
    adrp x5, pi4_launcher_key_1_bitmap
    add x5, x5, :lo12:pi4_launcher_key_1_bitmap
    bl pi4_launcher_draw_key_badge

    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x2, #PI4_COLOR_QUAKE_GOLD
    mov x3, #PI4_COLOR_HILITE
    mov x4, #PI4_COLOR_BLACK
    adrp x5, pi4_launcher_key_2_bitmap
    add x5, x5, :lo12:pi4_launcher_key_2_bitmap
    bl pi4_launcher_draw_key_badge

    adrp x9, pi4_launcher_art_flags
    add x9, x9, :lo12:pi4_launcher_art_flags
    ldr x9, [x9]
    tbnz x9, #PI4_LAUNCHER_APP_RECORD_0, .Lpi4_render_doom_icon_done
    mov x0, x19
    mov x1, #PI4_LAUNCHER_DOOM_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    bl pi4_launcher_draw_doom_icon

.Lpi4_render_doom_icon_done:
    adrp x9, pi4_launcher_art_flags
    add x9, x9, :lo12:pi4_launcher_art_flags
    ldr x9, [x9]
    tbnz x9, #PI4_LAUNCHER_APP_RECORD_1, .Lpi4_render_quake_icon_done
    mov x0, x19
    mov x1, #PI4_LAUNCHER_QUAKE_ICON_X
    mov x2, #PI4_LAUNCHER_ICON_Y
    bl pi4_launcher_draw_quake_icon

.Lpi4_render_quake_icon_done:
    mov x0, x19
    mov x1, #PI4_LAUNCHER_APP_RECORD_0
    mov x2, #PI4_LAUNCHER_DOOM_CARD_X
    mov x3, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_app_label

    mov x0, x19
    mov x1, #PI4_LAUNCHER_APP_RECORD_0
    mov x2, #PI4_LAUNCHER_DOOM_CARD_X
    mov x3, #PI4_COLOR_TEXT
    bl pi4_launcher_draw_app_label

    mov x0, x19
    mov x1, #PI4_LAUNCHER_APP_RECORD_1
    mov x2, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x3, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_app_label

    mov x0, x19
    mov x1, #PI4_LAUNCHER_APP_RECORD_1
    mov x2, #PI4_LAUNCHER_QUAKE_CARD_X
    mov x3, #PI4_COLOR_TEXT
    bl pi4_launcher_draw_app_label

.Lpi4_render_cards_done:
    mov x0, x19
    bl pi4_launcher_draw_cursor

    bl pi4_launcher_store_state

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_render_frame, . - pi4_launcher_render_frame

.type pi4_launcher_card_record_ptr, %function
pi4_launcher_card_record_ptr:
    cmp x0, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_card_record_ptr_none
    adrp x1, pi4_launcher_card_records
    add x1, x1, :lo12:pi4_launcher_card_records
    mov x2, #PI4_LAUNCHER_CARD_RECORD_BYTES
    madd x0, x0, x2, x1
    ret
.Lpi4_card_record_ptr_none:
    mov x0, xzr
    ret
.size pi4_launcher_card_record_ptr, . - pi4_launcher_card_record_ptr

.type pi4_launcher_render_card_bases, %function
pi4_launcher_render_card_bases:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    mov x19, x0
    adrp x20, pi4_launcher_card_records
    add x20, x20, :lo12:pi4_launcher_card_records
    mov x21, xzr

.Lpi4_render_card_bases_loop:
    cmp x21, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_render_card_bases_done
    mov x0, x19
    mov x1, x20
    bl pi4_launcher_draw_card_base
    add x20, x20, #PI4_LAUNCHER_CARD_RECORD_BYTES
    add x21, x21, #1
    b .Lpi4_render_card_bases_loop

.Lpi4_render_card_bases_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_render_card_bases, . - pi4_launcher_render_card_bases

.type pi4_launcher_draw_card_base, %function
pi4_launcher_draw_card_base:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0
    mov x20, x1
    ldr x21, [x20, #PI4_LAUNCHER_CARD_RECORD_CARD_X]
    ldr x22, [x20, #PI4_LAUNCHER_CARD_RECORD_ICON_X]
    ldr x23, [x20, #PI4_LAUNCHER_CARD_RECORD_ACCENT]
    ldr x24, [x20, #PI4_LAUNCHER_CARD_RECORD_DARK]

    mov x0, x19
    mov x1, x21
    add x1, x1, #10
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #12
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_CARD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    add x1, x1, #PI4_LAUNCHER_CARD_CHROME_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_TITLE_Y_OFF
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #(PI4_LAUNCHER_CARD_CHROME_INSET * 2)
    mov x4, #PI4_LAUNCHER_CARD_TITLE_H
    mov x5, #PI4_COLOR_PANEL
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    mov x2, x23
    bl pi4_launcher_draw_card_titlebar_chrome

    mov x0, x19
    mov x1, x21
    add x1, x1, #PI4_LAUNCHER_CARD_CHROME_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_TITLE_Y_OFF + PI4_LAUNCHER_CARD_TITLE_H + 2
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #(PI4_LAUNCHER_CARD_CHROME_INSET * 2)
    mov x4, #2
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    mov x5, x24
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    ldr x9, [x20, #PI4_LAUNCHER_CARD_RECORD_POSTER]
    blr x9

    adrp x6, pi4_launcher_art_flags
    add x6, x6, :lo12:pi4_launcher_art_flags
    ldr x6, [x6]
    ldr x7, [x20, #PI4_LAUNCHER_CARD_RECORD_INDEX]
    mov x8, #1
    lsl x8, x8, x7
    tst x6, x8
    b.eq .Lpi4_draw_card_base_art_done

    mov x0, x19
    mov x1, x22
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x22
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    ldr x5, [x20, #PI4_LAUNCHER_CARD_RECORD_ICON_PIXELS]
    bl pi4_launcher_draw_icon_pixels_rect

.Lpi4_draw_card_base_art_done:
    mov x0, x19
    mov x1, x22
    mov x2, #PI4_LAUNCHER_ICON_Y
    mov x3, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x4, #PI4_LAUNCHER_ICON_DISPLAY_SIZE
    mov x5, x23
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, x21
    add x1, x1, #PI4_LAUNCHER_CARD_ART_INSET
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_ART_INSET
    mov x3, #PI4_LAUNCHER_CARD_ART_W
    mov x4, #PI4_LAUNCHER_CARD_ART_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, x21
    mov x2, x23
    mov x3, #PI4_COLOR_BG1
    mov x4, #PI4_COLOR_BORDER
    mov x5, x23
    bl pi4_launcher_draw_launch_button

    mov x0, x19
    mov x1, x21
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, x21
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_HILITE
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_launcher_draw_card_base, . - pi4_launcher_draw_card_base

.type pi4_launcher_draw_card_titlebar_chrome, %function
pi4_launcher_draw_card_titlebar_chrome:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    mov x19, x0
    mov x20, x1
    mov x21, x2

    mov x0, x19
    add x1, x20, #26
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #13
    mov x3, #14
    mov x4, #14
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #24
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #11
    mov x3, #14
    mov x4, #14
    mov x5, #PI4_COLOR_PANEL
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #24
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #11
    mov x3, #14
    mov x4, #14
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_draw_border

    mov x0, x19
    add x1, x20, #24
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #11
    mov x3, #14
    mov x4, #14
    mov x5, #PI4_COLOR_HILITE
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    mov x0, x19
    add x1, x20, #28
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #15
    mov x3, #6
    mov x4, #6
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #56
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #12
    mov x3, #160
    mov x4, #2
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #336
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #12
    mov x3, #160
    mov x4, #2
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #56
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #16
    mov x3, #160
    mov x4, #2
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #336
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #16
    mov x3, #160
    mov x4, #2
    mov x5, #PI4_COLOR_BORDER
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #56
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #20
    mov x3, #160
    mov x4, #2
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #336
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #20
    mov x3, #160
    mov x4, #2
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #236
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #14
    mov x3, #80
    mov x4, #6
    mov x5, x21
    bl pi4_launcher_fill_rect

    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_draw_card_titlebar_chrome, . - pi4_launcher_draw_card_titlebar_chrome

.type pi4_launcher_draw_app_record_selected, %function
pi4_launcher_draw_app_record_selected:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    mov x19, x0
    mov x0, x1
    bl pi4_launcher_card_record_ptr
    cbz x0, .Lpi4_draw_app_record_selected_done
    mov x20, x0
    ldr x21, [x20, #PI4_LAUNCHER_CARD_RECORD_CARD_X]
    ldr x22, [x20, #PI4_LAUNCHER_CARD_RECORD_ACCENT]

    mov x0, x19
    mov x1, x21
    sub x1, x1, #8
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #8
    mov x3, #PI4_LAUNCHER_CARD_W
    add x3, x3, #16
    mov x4, #PI4_LAUNCHER_CARD_H
    add x4, x4, #16
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, x21
    sub x1, x1, #4
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #4
    mov x3, #PI4_LAUNCHER_CARD_W
    add x3, x3, #8
    mov x4, #PI4_LAUNCHER_CARD_H
    add x4, x4, #8
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_draw_border

    mov x0, x19
    mov x1, x21
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #PI4_LAUNCHER_CARD_W
    mov x4, #14
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    mov x2, #PI4_LAUNCHER_CARD_Y
    mov x3, #14
    mov x4, #PI4_LAUNCHER_CARD_H
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    add x1, x1, #32
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 72
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #64
    mov x4, #16
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    mov x2, x22
    mov x3, #PI4_COLOR_PANEL
    mov x4, #PI4_COLOR_HILITE
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_draw_launch_button

.Lpi4_draw_app_record_selected_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_draw_app_record_selected, . - pi4_launcher_draw_app_record_selected

.type pi4_launcher_draw_app_record_hover, %function
pi4_launcher_draw_app_record_hover:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    mov x19, x0
    mov x0, x1
    bl pi4_launcher_card_record_ptr
    cbz x0, .Lpi4_draw_app_record_hover_done
    mov x20, x0
    mov x0, x19
    ldr x1, [x20, #PI4_LAUNCHER_CARD_RECORD_CARD_X]
    mov x2, #PI4_COLOR_TEXT
    bl pi4_launcher_draw_hover_brackets

.Lpi4_draw_app_record_hover_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_draw_app_record_hover, . - pi4_launcher_draw_app_record_hover

.type pi4_launcher_draw_app_record_active, %function
pi4_launcher_draw_app_record_active:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    mov x19, x0
    mov x0, x1
    bl pi4_launcher_card_record_ptr
    cbz x0, .Lpi4_draw_app_record_active_done
    mov x20, x0
    ldr x21, [x20, #PI4_LAUNCHER_CARD_RECORD_CARD_X]

    mov x0, x19
    mov x1, x21
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #16
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #24
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 48
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #32
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    add x1, x1, #40
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 36
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #80
    mov x4, #8
    mov x5, #PI4_COLOR_SELECTED
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    mov x2, #PI4_COLOR_SELECTED
    mov x3, #PI4_COLOR_HILITE
    mov x4, #PI4_COLOR_SELECTED
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_launch_button

.Lpi4_draw_app_record_active_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_draw_app_record_active, . - pi4_launcher_draw_app_record_active

.type pi4_launcher_draw_app_record_failed, %function
pi4_launcher_draw_app_record_failed:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    mov x19, x0
    mov x0, x1
    bl pi4_launcher_card_record_ptr
    cbz x0, .Lpi4_draw_app_record_failed_done
    mov x20, x0
    ldr x21, [x20, #PI4_LAUNCHER_CARD_RECORD_CARD_X]

    mov x0, x19
    mov x1, x21
    add x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 92
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #32
    mov x4, #36
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    add x1, x1, #40
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 80
    mov x3, #PI4_LAUNCHER_CARD_W
    sub x3, x3, #80
    mov x4, #12
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x21
    mov x2, #PI4_COLOR_DOOM_FIRE
    mov x3, #PI4_COLOR_DOOM_FIRE
    mov x4, #PI4_COLOR_BLACK
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_launch_button

.Lpi4_draw_app_record_failed_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_draw_app_record_failed, . - pi4_launcher_draw_app_record_failed

.type pi4_launcher_render_card_foregrounds, %function
pi4_launcher_render_card_foregrounds:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    mov x19, x0
    adrp x20, pi4_launcher_card_records
    add x20, x20, :lo12:pi4_launcher_card_records
    mov x21, xzr

.Lpi4_render_card_foregrounds_loop:
    cmp x21, #PI4_LAUNCHER_VISIBLE_APP_RECORD_COUNT
    b.hs .Lpi4_render_card_foregrounds_done
    mov x0, x19
    mov x1, x20
    bl pi4_launcher_draw_card_foreground
    add x20, x20, #PI4_LAUNCHER_CARD_RECORD_BYTES
    add x21, x21, #1
    b .Lpi4_render_card_foregrounds_loop

.Lpi4_render_card_foregrounds_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_render_card_foregrounds, . - pi4_launcher_render_card_foregrounds

.type pi4_launcher_draw_card_foreground, %function
pi4_launcher_draw_card_foreground:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0
    mov x20, x1
    ldr x21, [x20, #PI4_LAUNCHER_CARD_RECORD_INDEX]
    ldr x22, [x20, #PI4_LAUNCHER_CARD_RECORD_CARD_X]
    ldr x23, [x20, #PI4_LAUNCHER_CARD_RECORD_ICON_X]
    ldr x24, [x20, #PI4_LAUNCHER_CARD_RECORD_ACCENT]

    mov x0, x19
    mov x1, x22
    mov x2, x24
    mov x3, #PI4_COLOR_HILITE
    mov x4, #PI4_COLOR_BLACK
    ldr x5, [x20, #PI4_LAUNCHER_CARD_RECORD_KEY_BITMAP]
    bl pi4_launcher_draw_key_badge

    adrp x9, pi4_launcher_art_flags
    add x9, x9, :lo12:pi4_launcher_art_flags
    ldr x9, [x9]
    mov x10, #1
    lsl x10, x10, x21
    tst x9, x10
    b.ne .Lpi4_draw_card_foreground_icon_done

    mov x0, x19
    mov x1, x23
    mov x2, #PI4_LAUNCHER_ICON_Y
    ldr x9, [x20, #PI4_LAUNCHER_CARD_RECORD_ICON_DRAW]
    blr x9

.Lpi4_draw_card_foreground_icon_done:
    mov x0, x19
    mov x1, x21
    mov x2, x22
    mov x3, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_app_label

    mov x0, x19
    mov x1, x21
    mov x2, x22
    mov x3, #PI4_COLOR_TEXT
    bl pi4_launcher_draw_app_label

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_launcher_draw_card_foreground, . - pi4_launcher_draw_card_foreground

.type pi4_launcher_store_state, %function
pi4_launcher_store_state:
    adrp x21, pi4_launcher_state
    add x21, x21, :lo12:pi4_launcher_state
    mov x22, #PI4_LAUNCHER_PHASE_FRAME_READY
    str x22, [x21, #PI4_LAUNCHER_STATE_PHASE]
    str x19, [x21, #PI4_LAUNCHER_STATE_FRAME]
    mov x22, #PI4_LAUNCHER_FRAME_WIDTH
    str x22, [x21, #PI4_LAUNCHER_STATE_WIDTH]
    mov x22, #PI4_LAUNCHER_FRAME_HEIGHT
    str x22, [x21, #PI4_LAUNCHER_STATE_HEIGHT]
    mov x22, #PI4_LAUNCHER_FRAME_STRIDE
    str x22, [x21, #PI4_LAUNCHER_STATE_STRIDE]
    ldr x22, =PI4_LAUNCHER_FRAME_BYTES
    str x22, [x21, #PI4_LAUNCHER_STATE_BYTES]
    mov x22, #PI4_LAUNCHER_APP_RECORD_COUNT
    str x22, [x21, #PI4_LAUNCHER_STATE_APP_RECORD_COUNT]
    str x20, [x21, #PI4_LAUNCHER_STATE_SELECTED_INDEX]

    adrp x22, pi4_launcher_app_catalog_table
    add x22, x22, :lo12:pi4_launcher_app_catalog_table
    mov x23, #PI4_LAUNCHER_APP_RECORD_BYTES
    madd x22, x20, x23, x22
    str x22, [x21, #PI4_LAUNCHER_STATE_SELECTED_APP_RECORD]
    ldr x23, [x22, #PI4_LAUNCHER_APP_RECORD_NAME]
    str x23, [x21, #PI4_LAUNCHER_STATE_SELECTED_NAME]
    ldr x23, [x22, #PI4_LAUNCHER_APP_RECORD_PATH]
    str x23, [x21, #PI4_LAUNCHER_STATE_SELECTED_PATH]
    ldr x23, [x22, #PI4_LAUNCHER_APP_RECORD_STATE]
    str x23, [x21, #PI4_LAUNCHER_STATE_SELECTED_STATE]
    ldr x23, [x22, #PI4_LAUNCHER_APP_RECORD_STATE_TEXT]
    str x23, [x21, #PI4_LAUNCHER_STATE_SELECTED_STATE_TEXT]
    ldr x23, [x21, #PI4_LAUNCHER_STATE_RENDER_COUNT]
    add x23, x23, #1
    str x23, [x21, #PI4_LAUNCHER_STATE_RENDER_COUNT]
    ret
.size pi4_launcher_store_state, . - pi4_launcher_store_state

.type pi4_launcher_fill_index_pattern, %function
pi4_launcher_fill_index_pattern:
    mov x1, #0

.Lpi4_pattern_y:
    cmp x1, #PI4_LAUNCHER_FRAME_HEIGHT
    b.hs .Lpi4_pattern_done
    mov x2, #0

.Lpi4_pattern_x:
    cmp x2, #PI4_LAUNCHER_FRAME_WIDTH
    b.hs .Lpi4_pattern_next_y
    lsr x3, x2, #4
    lsr x4, x1, #4
    add x3, x3, x4
    and x3, x3, #1
    add x3, x3, #PI4_COLOR_BG0
    mov x5, #PI4_LAUNCHER_FRAME_STRIDE
    madd x6, x1, x5, x2
    strb w3, [x0, x6]
    add x2, x2, #1
    b .Lpi4_pattern_x

.Lpi4_pattern_next_y:
    add x1, x1, #1
    b .Lpi4_pattern_y

.Lpi4_pattern_done:
    ret
.size pi4_launcher_fill_index_pattern, . - pi4_launcher_fill_index_pattern

.type pi4_launcher_fill_rect, %function
pi4_launcher_fill_rect:
    mov x6, #0

.Lpi4_rect_y:
    cmp x6, x4
    b.hs .Lpi4_rect_done
    mov x7, #0

.Lpi4_rect_x:
    cmp x7, x3
    b.hs .Lpi4_rect_next_y
    add x8, x2, x6
    mov x9, #PI4_LAUNCHER_FRAME_STRIDE
    madd x8, x8, x9, x1
    add x8, x8, x7
    strb w5, [x0, x8]
    add x7, x7, #1
    b .Lpi4_rect_x

.Lpi4_rect_next_y:
    add x6, x6, #1
    b .Lpi4_rect_y

.Lpi4_rect_done:
    ret
.size pi4_launcher_fill_rect, . - pi4_launcher_fill_rect

.type pi4_launcher_draw_border, %function
pi4_launcher_draw_border:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, #1
    mov x5, x24
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, x23
    sub x2, x2, #1
    mov x3, x22
    mov x4, #1
    mov x5, x24
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #1
    mov x4, x23
    mov x5, x24
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, x22
    sub x1, x1, #1
    mov x2, x21
    mov x3, #1
    mov x4, x23
    mov x5, x24
    bl pi4_launcher_fill_rect

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_draw_border, . - pi4_launcher_draw_border

.type pi4_launcher_draw_bevel, %function
pi4_launcher_draw_bevel:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    mov x25, x6

    mov x0, x19
    add x1, x20, #1
    add x2, x21, #1
    mov x3, x22
    sub x3, x3, #2
    mov x4, #2
    mov x5, x24
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #1
    add x2, x21, #1
    mov x3, #2
    mov x4, x23
    sub x4, x4, #2
    mov x5, x24
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #1
    add x2, x21, x23
    sub x2, x2, #3
    mov x3, x22
    sub x3, x3, #2
    mov x4, #2
    mov x5, x25
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, x22
    sub x1, x1, #3
    add x2, x21, #1
    mov x3, #2
    mov x4, x23
    sub x4, x4, #2
    mov x5, x25
    bl pi4_launcher_fill_rect

    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_launcher_draw_bevel, . - pi4_launcher_draw_bevel

.type pi4_launcher_draw_doom_poster, %function
pi4_launcher_draw_doom_poster:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, x23
    mov x5, #PI4_COLOR_DOOM_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, #54
    mov x5, #PI4_COLOR_BG1
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #54
    mov x3, x22
    mov x4, #58
    mov x5, #PI4_COLOR_DOOM_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #112
    mov x3, x22
    mov x4, #62
    mov x5, #PI4_COLOR_DOOM
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #174
    mov x3, x22
    mov x4, #114
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #64
    add x2, x21, #82
    mov x3, #376
    mov x4, #18
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #28
    add x2, x21, #106
    mov x3, #448
    mov x4, #14
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #42
    add x2, x21, #130
    mov x3, #96
    mov x4, #52
    mov x5, #PI4_COLOR_DOOM_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #366
    add x2, x21, #126
    mov x3, #98
    mov x4, #58
    mov x5, #PI4_COLOR_DOOM_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #126
    add x2, x21, #74
    mov x3, #252
    mov x4, #132
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #144
    add x2, x21, #56
    mov x3, #216
    mov x4, #142
    mov x5, #PI4_COLOR_DOOM
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #166
    add x2, x21, #76
    mov x3, #172
    mov x4, #88
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #198
    add x2, x21, #92
    mov x3, #108
    mov x4, #66
    mov x5, #PI4_COLOR_TEXT
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #210
    add x2, x21, #110
    mov x3, #26
    mov x4, #18
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #268
    add x2, x21, #110
    mov x3, #26
    mov x4, #18
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #246
    add x2, x21, #132
    mov x3, #12
    mov x4, #20
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #220
    add x2, x21, #162
    mov x3, #64
    mov x4, #10
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #208
    mov x3, x22
    mov x4, #16
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #38
    add x2, x21, #234
    mov x3, #112
    mov x4, #22
    mov x5, #PI4_COLOR_DOOM
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #182
    add x2, x21, #226
    mov x3, #140
    mov x4, #34
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #354
    add x2, x21, #236
    mov x3, #116
    mov x4, #20
    mov x5, #PI4_COLOR_HILITE
    bl pi4_launcher_fill_rect

.Lpi4_doom_poster_done:
    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_draw_doom_poster, . - pi4_launcher_draw_doom_poster

.type pi4_launcher_draw_quake_poster, %function
pi4_launcher_draw_quake_poster:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, x23
    mov x5, #PI4_COLOR_QUAKE_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, #72
    mov x5, #PI4_COLOR_BG1
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #72
    mov x3, x22
    mov x4, #92
    mov x5, #PI4_COLOR_QUAKE_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #164
    mov x3, x22
    mov x4, #124
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #38
    add x2, x21, #92
    mov x3, #428
    mov x4, #12
    mov x5, #PI4_COLOR_QUAKE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #70
    add x2, x21, #130
    mov x3, #364
    mov x4, #10
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #68
    add x2, x21, #48
    mov x3, #54
    mov x4, #170
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #382
    add x2, x21, #48
    mov x3, #54
    mov x4, #170
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #80
    add x2, x21, #56
    mov x3, #30
    mov x4, #150
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #394
    add x2, x21, #56
    mov x3, #30
    mov x4, #150
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #134
    add x2, x21, #42
    mov x3, #236
    mov x4, #34
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #134
    add x2, x21, #42
    mov x3, #34
    mov x4, #166
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #336
    add x2, x21, #42
    mov x3, #34
    mov x4, #166
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #134
    add x2, x21, #174
    mov x3, #236
    mov x4, #34
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #184
    add x2, x21, #92
    mov x3, #136
    mov x4, #76
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #202
    add x2, x21, #108
    mov x3, #100
    mov x4, #44
    mov x5, #PI4_COLOR_QUAKE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #286
    add x2, x21, #188
    mov x3, #96
    mov x4, #28
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #324
    add x2, x21, #216
    mov x3, #76
    mov x4, #24
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #44
    add x2, x21, #230
    mov x3, #416
    mov x4, #18
    mov x5, #PI4_COLOR_QUAKE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #112
    add x2, x21, #254
    mov x3, #280
    mov x4, #16
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

.Lpi4_quake_poster_done:
    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_launcher_draw_quake_poster, . - pi4_launcher_draw_quake_poster

.type pi4_launcher_draw_hover_brackets, %function
pi4_launcher_draw_hover_brackets:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    mov x19, x0
    mov x20, x1
    mov x21, x2

    mov x0, x19
    mov x1, x20
    sub x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #16
    mov x3, #128
    mov x4, #6
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    sub x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #16
    mov x3, #6
    mov x4, #128
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_CARD_W - 112
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #16
    mov x3, #128
    mov x4, #6
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_CARD_W + 10
    mov x2, #PI4_LAUNCHER_CARD_Y
    sub x2, x2, #16
    mov x3, #6
    mov x4, #128
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    sub x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H + 10
    mov x3, #128
    mov x4, #6
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    sub x1, x1, #16
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 112
    mov x3, #6
    mov x4, #128
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_CARD_W - 112
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H + 10
    mov x3, #128
    mov x4, #6
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_CARD_W + 10
    mov x2, #PI4_LAUNCHER_CARD_Y
    add x2, x2, #PI4_LAUNCHER_CARD_H - 112
    mov x3, #6
    mov x4, #128
    mov x5, x21
    bl pi4_launcher_fill_rect

    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_draw_hover_brackets, . - pi4_launcher_draw_hover_brackets

.type pi4_launcher_draw_key_badge, %function
pi4_launcher_draw_key_badge:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_KEY_BADGE_X_OFF
    add x1, x1, #4
    mov x2, #PI4_LAUNCHER_KEY_BADGE_Y
    add x2, x2, #4
    mov x3, #PI4_LAUNCHER_KEY_BADGE_W
    mov x4, #PI4_LAUNCHER_KEY_BADGE_H
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_KEY_BADGE_X_OFF
    mov x2, #PI4_LAUNCHER_KEY_BADGE_Y
    mov x3, #PI4_LAUNCHER_KEY_BADGE_W
    mov x4, #PI4_LAUNCHER_KEY_BADGE_H
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_KEY_BADGE_X_OFF
    mov x2, #PI4_LAUNCHER_KEY_BADGE_Y
    mov x3, #PI4_LAUNCHER_KEY_BADGE_W
    mov x4, #PI4_LAUNCHER_KEY_BADGE_H
    mov x5, x22
    bl pi4_launcher_draw_border

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_KEY_BADGE_X_OFF
    mov x2, #PI4_LAUNCHER_KEY_BADGE_Y
    mov x3, #PI4_LAUNCHER_KEY_BADGE_W
    mov x4, #PI4_LAUNCHER_KEY_BADGE_H
    mov x5, x22
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_KEY_BADGE_X_OFF
    add x1, x1, #PI4_LAUNCHER_KEY_BADGE_DIGIT_X_OFF
    add x1, x1, #3
    mov x2, #PI4_LAUNCHER_KEY_BADGE_Y
    add x2, x2, #PI4_LAUNCHER_KEY_BADGE_DIGIT_Y_OFF
    add x2, x2, #3
    mov x3, #PI4_LAUNCHER_KEY_BADGE_DIGIT_W
    mov x4, #PI4_LAUNCHER_KEY_BADGE_DIGIT_H
    mov x5, #PI4_COLOR_BLACK
    mov x6, x24
    mov x7, #PI4_LAUNCHER_KEY_BADGE_DIGIT_SCALE
    bl pi4_launcher_draw_bitmap_scaled

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_KEY_BADGE_X_OFF
    add x1, x1, #PI4_LAUNCHER_KEY_BADGE_DIGIT_X_OFF
    mov x2, #PI4_LAUNCHER_KEY_BADGE_Y
    add x2, x2, #PI4_LAUNCHER_KEY_BADGE_DIGIT_Y_OFF
    mov x3, #PI4_LAUNCHER_KEY_BADGE_DIGIT_W
    mov x4, #PI4_LAUNCHER_KEY_BADGE_DIGIT_H
    mov x5, x23
    mov x6, x24
    mov x7, #PI4_LAUNCHER_KEY_BADGE_DIGIT_SCALE
    bl pi4_launcher_draw_bitmap_scaled

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_launcher_draw_key_badge, . - pi4_launcher_draw_key_badge

.type pi4_launcher_draw_launch_button, %function
pi4_launcher_draw_launch_button:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF
    add x1, x1, #4
    mov x2, #PI4_LAUNCHER_LAUNCH_BUTTON_Y
    add x2, x2, #4
    mov x3, #PI4_LAUNCHER_LAUNCH_BUTTON_W
    mov x4, #PI4_LAUNCHER_LAUNCH_BUTTON_H
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF
    mov x2, #PI4_LAUNCHER_LAUNCH_BUTTON_Y
    mov x3, #PI4_LAUNCHER_LAUNCH_BUTTON_W
    mov x4, #PI4_LAUNCHER_LAUNCH_BUTTON_H
    mov x5, x22
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF
    add x1, x1, #18
    mov x2, #PI4_LAUNCHER_LAUNCH_BUTTON_Y
    add x2, x2, #8
    mov x3, #236
    mov x4, #6
    mov x5, x23
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF
    mov x2, #PI4_LAUNCHER_LAUNCH_BUTTON_Y
    mov x3, #PI4_LAUNCHER_LAUNCH_BUTTON_W
    mov x4, #PI4_LAUNCHER_LAUNCH_BUTTON_H
    mov x5, x23
    bl pi4_launcher_draw_border

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF
    mov x2, #PI4_LAUNCHER_LAUNCH_BUTTON_Y
    mov x3, #PI4_LAUNCHER_LAUNCH_BUTTON_W
    mov x4, #PI4_LAUNCHER_LAUNCH_BUTTON_H
    mov x5, x21
    mov x6, #PI4_COLOR_BLACK
    bl pi4_launcher_draw_bevel

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF
    add x1, x1, #18
    mov x2, #PI4_LAUNCHER_LAUNCH_BUTTON_Y
    add x2, x2, #14
    mov x3, #12
    mov x4, #20
    mov x5, x21
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_LAUNCH_BUTTON_X_OFF
    add x1, x1, #120
    mov x2, #PI4_LAUNCHER_LAUNCH_BUTTON_Y
    add x2, x2, #10
    mov x3, x24
    bl pi4_launcher_draw_play_glyph

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_BUTTON_LABEL_X_OFF
    add x1, x1, #2
    mov x2, #PI4_LAUNCHER_BUTTON_LABEL_Y
    add x2, x2, #2
    mov x3, #PI4_LAUNCHER_BUTTON_LABEL_W
    mov x4, #PI4_LAUNCHER_BUTTON_LABEL_H
    mov x5, #PI4_COLOR_BLACK
    adrp x6, pi4_launcher_enter_label_bitmap
    add x6, x6, :lo12:pi4_launcher_enter_label_bitmap
    mov x7, #PI4_LAUNCHER_BUTTON_LABEL_SCALE
    bl pi4_launcher_draw_bitmap_scaled

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_BUTTON_LABEL_X_OFF
    mov x2, #PI4_LAUNCHER_BUTTON_LABEL_Y
    mov x3, #PI4_LAUNCHER_BUTTON_LABEL_W
    mov x4, #PI4_LAUNCHER_BUTTON_LABEL_H
    mov x5, x24
    adrp x6, pi4_launcher_enter_label_bitmap
    add x6, x6, :lo12:pi4_launcher_enter_label_bitmap
    mov x7, #PI4_LAUNCHER_BUTTON_LABEL_SCALE
    bl pi4_launcher_draw_bitmap_scaled

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_launcher_draw_launch_button, . - pi4_launcher_draw_launch_button

.type pi4_launcher_draw_play_glyph, %function
pi4_launcher_draw_play_glyph:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #8
    mov x4, #4
    mov x5, x22
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #4
    mov x3, #16
    mov x4, #4
    mov x5, x22
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #8
    mov x3, #24
    mov x4, #4
    mov x5, x22
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #12
    mov x3, #PI4_LAUNCHER_PLAY_GLYPH_W
    mov x4, #4
    mov x5, x22
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #16
    mov x3, #24
    mov x4, #4
    mov x5, x22
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #20
    mov x3, #16
    mov x4, #4
    mov x5, x22
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    add x2, x21, #24
    mov x3, #8
    mov x4, #4
    mov x5, x22
    bl pi4_launcher_fill_rect

    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_draw_play_glyph, . - pi4_launcher_draw_play_glyph

.type pi4_launcher_draw_bitmap, %function
pi4_launcher_draw_bitmap:
    mov x7, #0

.Lpi4_bitmap_y:
    cmp x7, x4
    b.hs .Lpi4_bitmap_done
    ldr w8, [x6, x7, lsl #2]
    mov x9, #0

.Lpi4_bitmap_x:
    cmp x9, x3
    b.hs .Lpi4_bitmap_next_y
    sub x10, x3, #1
    sub x10, x10, x9
    lsr w11, w8, w10
    tbz w11, #0, .Lpi4_bitmap_skip
    add x12, x2, x7
    mov x13, #PI4_LAUNCHER_FRAME_STRIDE
    madd x12, x12, x13, x1
    add x12, x12, x9
    strb w5, [x0, x12]

.Lpi4_bitmap_skip:
    add x9, x9, #1
    b .Lpi4_bitmap_x

.Lpi4_bitmap_next_y:
    add x7, x7, #1
    b .Lpi4_bitmap_y

.Lpi4_bitmap_done:
    ret
.size pi4_launcher_draw_bitmap, . - pi4_launcher_draw_bitmap

.type pi4_launcher_draw_bitmap_scaled, %function
pi4_launcher_draw_bitmap_scaled:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    mov x25, x6
    mov x26, x7
    mov x27, xzr

.Lpi4_scaled_bitmap_y:
    cmp x27, x23
    b.hs .Lpi4_scaled_bitmap_done
    ldr w8, [x25, x27, lsl #2]
    mov x28, xzr

.Lpi4_scaled_bitmap_x:
    cmp x28, x22
    b.hs .Lpi4_scaled_bitmap_next_y
    ldr w8, [x25, x27, lsl #2]
    sub x9, x22, #1
    sub x9, x9, x28
    lsr w10, w8, w9
    tbz w10, #0, .Lpi4_scaled_bitmap_skip

    mov x0, x19
    madd x1, x28, x26, x20
    madd x2, x27, x26, x21
    mov x3, x26
    mov x4, x26
    mov x5, x24
    bl pi4_launcher_fill_rect

.Lpi4_scaled_bitmap_skip:
    add x28, x28, #1
    b .Lpi4_scaled_bitmap_x

.Lpi4_scaled_bitmap_next_y:
    add x27, x27, #1
    b .Lpi4_scaled_bitmap_y

.Lpi4_scaled_bitmap_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_launcher_draw_bitmap_scaled, . - pi4_launcher_draw_bitmap_scaled

.type pi4_launcher_draw_icon_pixels_rect, %function
pi4_launcher_draw_icon_pixels_rect:
    cbz x3, .Lpi4_icon_rect_done
    cbz x4, .Lpi4_icon_rect_done
    mov x6, xzr
    mov x13, #PI4_LAUNCHER_ICON_SIZE

.Lpi4_icon_rect_y:
    cmp x6, x4
    b.hs .Lpi4_icon_rect_done
    mul x7, x6, x13
    udiv x7, x7, x4
    madd x8, x7, x13, x5
    add x9, x2, x6
    mov x10, #PI4_LAUNCHER_FRAME_STRIDE
    madd x9, x9, x10, x1
    add x9, x0, x9
    mov x11, xzr

.Lpi4_icon_rect_x:
    cmp x11, x3
    b.hs .Lpi4_icon_rect_next_y
    mul x12, x11, x13
    udiv x12, x12, x3
    ldrb w14, [x8, x12]
    cbz w14, .Lpi4_icon_rect_skip
    strb w14, [x9, x11]

.Lpi4_icon_rect_skip:
    add x11, x11, #1
    b .Lpi4_icon_rect_x

.Lpi4_icon_rect_next_y:
    add x6, x6, #1
    b .Lpi4_icon_rect_y

.Lpi4_icon_rect_done:
    ret
.size pi4_launcher_draw_icon_pixels_rect, . - pi4_launcher_draw_icon_pixels_rect

.type pi4_launcher_draw_icon_pixels, %function
pi4_launcher_draw_icon_pixels:
    mov x4, xzr

.Lpi4_icon_pixels_y:
    cmp x4, #PI4_LAUNCHER_ICON_SIZE
    b.hs .Lpi4_icon_pixels_done
    mov x5, #PI4_LAUNCHER_ICON_SIZE
    madd x6, x4, x5, x3
    add x7, x2, x4
    mov x8, #PI4_LAUNCHER_FRAME_STRIDE
    madd x7, x7, x8, x1
    add x7, x0, x7
    mov x9, xzr

.Lpi4_icon_pixels_x:
    cmp x9, #PI4_LAUNCHER_ICON_SIZE
    b.hs .Lpi4_icon_pixels_next_y
    ldrb w10, [x6, x9]
    cbz w10, .Lpi4_icon_pixels_skip
    strb w10, [x7, x9]

.Lpi4_icon_pixels_skip:
    add x9, x9, #1
    b .Lpi4_icon_pixels_x

.Lpi4_icon_pixels_next_y:
    add x4, x4, #1
    b .Lpi4_icon_pixels_y

.Lpi4_icon_pixels_done:
    ret
.size pi4_launcher_draw_icon_pixels, . - pi4_launcher_draw_icon_pixels

.type pi4_launcher_draw_doom_icon, %function
pi4_launcher_draw_doom_icon:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0
    mov x20, x1
    mov x21, x2

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #PI4_LAUNCHER_ICON_SIZE
    mov x4, #PI4_LAUNCHER_ICON_SIZE
    mov x5, #PI4_COLOR_DOOM_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #12
    add x2, x21, #12
    mov x3, #168
    mov x4, #168
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    adrp x9, pi4_launcher_art_flags
    add x9, x9, :lo12:pi4_launcher_art_flags
    ldr x9, [x9]
    tbz x9, #PI4_LAUNCHER_APP_RECORD_0, .Lpi4_doom_icon_default_art

    mov x0, x19
    mov x1, x20
    mov x2, x21
    adrp x3, pi4_launcher_doom_icon_pixels
    add x3, x3, :lo12:pi4_launcher_doom_icon_pixels
    bl pi4_launcher_draw_icon_pixels

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #PI4_LAUNCHER_ICON_SIZE
    mov x4, #PI4_LAUNCHER_ICON_SIZE
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_draw_border
    b .Lpi4_doom_icon_done

.Lpi4_doom_icon_default_art:
    mov x0, x19
    add x1, x20, #20
    add x2, x21, #20
    mov x3, #152
    mov x4, #36
    mov x5, #PI4_COLOR_DOOM
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #28
    add x2, x21, #40
    mov x3, #136
    mov x4, #32
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #36
    add x2, x21, #72
    mov x3, #120
    mov x4, #76
    mov x5, #PI4_COLOR_DOOM
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #20
    add x2, x21, #76
    mov x3, #32
    mov x4, #24
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #140
    add x2, x21, #76
    mov x3, #32
    mov x4, #24
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #56
    add x2, x21, #88
    mov x3, #26
    mov x4, #18
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #110
    add x2, x21, #88
    mov x3, #26
    mov x4, #18
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #88
    add x2, x21, #116
    mov x3, #16
    mov x4, #24
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #62
    add x2, x21, #144
    mov x3, #68
    mov x4, #12
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #68
    add x2, x21, #144
    mov x3, #8
    mov x4, #18
    mov x5, #PI4_COLOR_TEXT
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #92
    add x2, x21, #144
    mov x3, #8
    mov x4, #18
    mov x5, #PI4_COLOR_TEXT
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #116
    add x2, x21, #144
    mov x3, #8
    mov x4, #18
    mov x5, #PI4_COLOR_TEXT
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #36
    add x2, x21, #168
    mov x3, #120
    mov x4, #12
    mov x5, #PI4_COLOR_DIM
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #PI4_LAUNCHER_ICON_SIZE
    mov x4, #PI4_LAUNCHER_ICON_SIZE
    mov x5, #PI4_COLOR_DOOM_FIRE
    bl pi4_launcher_draw_border

.Lpi4_doom_icon_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_draw_doom_icon, . - pi4_launcher_draw_doom_icon

.type pi4_launcher_draw_quake_icon, %function
pi4_launcher_draw_quake_icon:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0
    mov x20, x1
    mov x21, x2

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #PI4_LAUNCHER_ICON_SIZE
    mov x4, #PI4_LAUNCHER_ICON_SIZE
    mov x5, #PI4_COLOR_QUAKE_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #12
    add x2, x21, #12
    mov x3, #168
    mov x4, #168
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    adrp x9, pi4_launcher_art_flags
    add x9, x9, :lo12:pi4_launcher_art_flags
    ldr x9, [x9]
    tbz x9, #PI4_LAUNCHER_APP_RECORD_1, .Lpi4_quake_icon_default_art

    mov x0, x19
    mov x1, x20
    mov x2, x21
    adrp x3, pi4_launcher_quake_icon_pixels
    add x3, x3, :lo12:pi4_launcher_quake_icon_pixels
    bl pi4_launcher_draw_icon_pixels

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #PI4_LAUNCHER_ICON_SIZE
    mov x4, #PI4_LAUNCHER_ICON_SIZE
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_draw_border
    b .Lpi4_quake_icon_done

.Lpi4_quake_icon_default_art:
    mov x0, x19
    add x1, x20, #24
    add x2, x21, #24
    mov x3, #144
    mov x4, #144
    mov x5, #PI4_COLOR_QUAKE_DARK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #64
    add x2, x21, #36
    mov x3, #64
    mov x4, #20
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #44
    add x2, x21, #56
    mov x3, #20
    mov x4, #76
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #128
    add x2, x21, #56
    mov x3, #20
    mov x4, #76
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #64
    add x2, x21, #132
    mov x3, #64
    mov x4, #20
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #72
    add x2, x21, #64
    mov x3, #48
    mov x4, #60
    mov x5, #PI4_COLOR_BLACK
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #86
    add x2, x21, #72
    mov x3, #20
    mov x4, #44
    mov x5, #PI4_COLOR_QUAKE
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #112
    add x2, x21, #120
    mov x3, #44
    mov x4, #20
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    add x1, x20, #136
    add x2, x21, #140
    mov x3, #32
    mov x4, #16
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_fill_rect

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #PI4_LAUNCHER_ICON_SIZE
    mov x4, #PI4_LAUNCHER_ICON_SIZE
    mov x5, #PI4_COLOR_QUAKE_GOLD
    bl pi4_launcher_draw_border

.Lpi4_quake_icon_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_draw_quake_icon, . - pi4_launcher_draw_quake_icon

.type pi4_launcher_app_record_name_ptr, %function
pi4_launcher_app_record_name_ptr:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0
    bl pi4_launcher_app_record_entry_ptr
    cbz x0, .Lpi4_app_record_name_default
    ldr x0, [x0, #PI4_LAUNCHER_APP_RECORD_NAME]
    cbnz x0, .Lpi4_app_record_name_done
.Lpi4_app_record_name_default:
    mov x0, x19
    bl pi4_launcher_default_name
.Lpi4_app_record_name_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_launcher_app_record_name_ptr, . - pi4_launcher_app_record_name_ptr

.type pi4_launcher_measure_app_label, %function
pi4_launcher_measure_app_label:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    mov x19, x0
    mov x20, xzr

.Lpi4_measure_label_next:
    cmp x20, #PI4_LAUNCHER_APP_LABEL_MAX_CHARS
    b.hs .Lpi4_measure_label_done
    ldrb w1, [x19, x20]
    cbz w1, .Lpi4_measure_label_done
    add x20, x20, #1
    b .Lpi4_measure_label_next

.Lpi4_measure_label_done:
    cbnz x20, .Lpi4_measure_label_nonempty
    mov x0, xzr
    b .Lpi4_measure_label_return

.Lpi4_measure_label_nonempty:
    mov x0, #PI4_LAUNCHER_LABEL_ADVANCE
    mul x0, x20, x0
    sub x0, x0, #1
    mov x1, #PI4_LAUNCHER_LABEL_SCALE
    mul x0, x0, x1

.Lpi4_measure_label_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_launcher_measure_app_label, . - pi4_launcher_measure_app_label

.type pi4_launcher_glyph_5x7, %function
pi4_launcher_glyph_5x7:
    cmp w0, #'a'
    b.lo .Lpi4_glyph_check_upper
    cmp w0, #'z'
    b.hi .Lpi4_glyph_check_upper
    sub w0, w0, #32

.Lpi4_glyph_check_upper:
    cmp w0, #'A'
    b.lo .Lpi4_glyph_check_digit
    cmp w0, #'Z'
    b.hi .Lpi4_glyph_check_digit
    sub x2, x0, #'A'
    adrp x1, pi4_launcher_font_alpha_5x7
    add x1, x1, :lo12:pi4_launcher_font_alpha_5x7
    mov x3, #(PI4_LAUNCHER_LABEL_H * 4)
    madd x0, x2, x3, x1
    ret

.Lpi4_glyph_check_digit:
    cmp w0, #'0'
    b.lo .Lpi4_glyph_missing
    cmp w0, #'9'
    b.hi .Lpi4_glyph_missing
    sub x2, x0, #'0'
    adrp x1, pi4_launcher_font_digit_5x7
    add x1, x1, :lo12:pi4_launcher_font_digit_5x7
    mov x3, #(PI4_LAUNCHER_LABEL_H * 4)
    madd x0, x2, x3, x1
    ret

.Lpi4_glyph_missing:
    mov x0, xzr
    ret
.size pi4_launcher_glyph_5x7, . - pi4_launcher_glyph_5x7

.type pi4_launcher_draw_app_label, %function
pi4_launcher_draw_app_label:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    mov x0, x20
    bl pi4_launcher_app_record_name_ptr
    mov x23, x0

    mov x0, x23
    bl pi4_launcher_measure_app_label
    mov x24, x0
    add x25, x21, #(PI4_LAUNCHER_CARD_W / 2)
    lsr x24, x24, #1
    sub x25, x25, x24
    mov x26, xzr

.Lpi4_draw_label_next:
    cmp x26, #PI4_LAUNCHER_APP_LABEL_MAX_CHARS
    b.hs .Lpi4_draw_label_done
    ldrb w0, [x23, x26]
    cbz w0, .Lpi4_draw_label_done
    bl pi4_launcher_glyph_5x7
    cbz x0, .Lpi4_draw_label_advance

    mov x6, x0
    mov x0, x19
    mov x1, x25
    mov x2, #PI4_LAUNCHER_LABEL_Y
    mov x3, #PI4_LAUNCHER_LABEL_GLYPH_W
    mov x4, #PI4_LAUNCHER_LABEL_H
    mov x5, x22
    mov x7, #PI4_LAUNCHER_LABEL_SCALE
    bl pi4_launcher_draw_bitmap_scaled

.Lpi4_draw_label_advance:
    add x25, x25, #(PI4_LAUNCHER_LABEL_ADVANCE * PI4_LAUNCHER_LABEL_SCALE)
    add x26, x26, #1
    b .Lpi4_draw_label_next

.Lpi4_draw_label_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_launcher_draw_app_label, . - pi4_launcher_draw_app_label

.type pi4_launcher_draw_cursor, %function
pi4_launcher_draw_cursor:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0

    adrp x0, pi4_launcher_cursor_x
    add x0, x0, :lo12:pi4_launcher_cursor_x
    ldr x20, [x0]
    adrp x0, pi4_launcher_cursor_y
    add x0, x0, :lo12:pi4_launcher_cursor_y
    ldr x21, [x0]

    mov x0, x19
    add x1, x20, #PI4_LAUNCHER_CURSOR_SHADOW_OFFSET
    add x2, x21, #PI4_LAUNCHER_CURSOR_SHADOW_OFFSET
    mov x3, #PI4_LAUNCHER_CURSOR_W
    mov x4, #PI4_LAUNCHER_CURSOR_H
    mov x5, #PI4_COLOR_BLACK
    adrp x6, pi4_launcher_cursor_bitmap
    add x6, x6, :lo12:pi4_launcher_cursor_bitmap
    mov x7, #PI4_LAUNCHER_CURSOR_SCALE
    bl pi4_launcher_draw_bitmap_scaled

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #PI4_LAUNCHER_CURSOR_W
    mov x4, #PI4_LAUNCHER_CURSOR_H
    mov x5, #PI4_COLOR_TEXT
    adrp x6, pi4_launcher_cursor_bitmap
    add x6, x6, :lo12:pi4_launcher_cursor_bitmap
    mov x7, #PI4_LAUNCHER_CURSOR_SCALE
    bl pi4_launcher_draw_bitmap_scaled

    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_launcher_draw_cursor, . - pi4_launcher_draw_cursor

.section .rodata.pi4_launcher_manifest, "a", %progbits
.balign 8
pi4_launcher_font_alpha_5x7:
    .word 0b01110, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001
    .word 0b11110, 0b10001, 0b10001, 0b11110, 0b10001, 0b10001, 0b11110
    .word 0b01111, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b01111
    .word 0b11110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b11110
    .word 0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b11111
    .word 0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b10000
    .word 0b01111, 0b10000, 0b10000, 0b10111, 0b10001, 0b10001, 0b01111
    .word 0b10001, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001
    .word 0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b11111
    .word 0b00111, 0b00010, 0b00010, 0b00010, 0b10010, 0b10010, 0b01100
    .word 0b10001, 0b10010, 0b10100, 0b11000, 0b10100, 0b10010, 0b10001
    .word 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b11111
    .word 0b10001, 0b11011, 0b10101, 0b10101, 0b10001, 0b10001, 0b10001
    .word 0b10001, 0b11001, 0b10101, 0b10011, 0b10001, 0b10001, 0b10001
    .word 0b01110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110
    .word 0b11110, 0b10001, 0b10001, 0b11110, 0b10000, 0b10000, 0b10000
    .word 0b01110, 0b10001, 0b10001, 0b10001, 0b10101, 0b10010, 0b01101
    .word 0b11110, 0b10001, 0b10001, 0b11110, 0b10100, 0b10010, 0b10001
    .word 0b01111, 0b10000, 0b10000, 0b01110, 0b00001, 0b00001, 0b11110
    .word 0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100
    .word 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110
    .word 0b10001, 0b10001, 0b10001, 0b10001, 0b01010, 0b01010, 0b00100
    .word 0b10001, 0b10001, 0b10001, 0b10101, 0b10101, 0b11011, 0b10001
    .word 0b10001, 0b10001, 0b01010, 0b00100, 0b01010, 0b10001, 0b10001
    .word 0b10001, 0b10001, 0b01010, 0b00100, 0b00100, 0b00100, 0b00100
    .word 0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b10000, 0b11111

pi4_launcher_font_digit_5x7:
    .word 0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110
    .word 0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110
    .word 0b11110, 0b00001, 0b00001, 0b01110, 0b10000, 0b10000, 0b11111
    .word 0b11110, 0b00001, 0b00001, 0b01110, 0b00001, 0b00001, 0b11110
    .word 0b10010, 0b10010, 0b10010, 0b11111, 0b00010, 0b00010, 0b00010
    .word 0b11111, 0b10000, 0b10000, 0b11110, 0b00001, 0b00001, 0b11110
    .word 0b01110, 0b10000, 0b10000, 0b11110, 0b10001, 0b10001, 0b01110
    .word 0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b01000, 0b01000
    .word 0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110
    .word 0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b00001, 0b01110

.balign 8
.global pi4_launcher_manifest
pi4_launcher_manifest:
    .ascii "schema=vibe-os-pi4-launcher-apps-v1\n"
    .ascii "app_model=manifest-vfs-exec\n"
    .ascii "app_index_schema=vibe-os-app-index-v1\n"
    .ascii "app_visible_capacity=2\n"
    .ascii "app_discovery_source=/APPS/INDEX.TXT\n"
    .ascii "app_discovery_runtime=read-app-count-and-indexed-manifest-keys\n"
    .ascii "app_metadata_runtime=manifest-name-exec-asset-icon\n"
    .ascii "launcher_app_record_table_authority=runtime-vfs-app-index\n"
    .ascii "launcher_app_table_authority=runtime-vfs-discovery\n"
    .ascii "launcher_launch_authority=manifest-exec-path\n"
    .ascii "launcher_state_schema=vibe-os-pi4-launcher-state-v2\n"
    .ascii "launcher_state_magic=PI4LAUNC\n"
    .ascii "launcher_state_bytes=392\n"
    .ascii "launcher_state.offset.selected_index=64\n"
    .ascii "launcher_state.offset.selected_path=88\n"
    .ascii "launcher_state.offset.present_count=104\n"
    .ascii "launcher_state.offset.input_type=120\n"
    .ascii "launcher_state.offset.input_code=128\n"
    .ascii "launcher_state.offset.input_value0=136\n"
    .ascii "launcher_state.offset.record_count=152\n"
    .ascii "launcher_state.offset.record_index=160\n"
    .ascii "launcher_state.offset.input_action=288\n"
    .ascii "launcher_state.offset.input_action_count=296\n"
    .ascii "launcher_state.offset.move_count=304\n"
    .ascii "launcher_state.offset.record_action_count=312\n"
    .ascii "launcher_state.offset.present_status=320\n"
    .ascii "launcher_state.offset.exec_request=192\n"
    .ascii "launcher_state.offset.exec_result=200\n"
    .ascii "launcher_state.offset.exec_errno=208\n"
    .ascii "launcher_state.offset.exec_count=216\n"
    .ascii "launcher_state.offset.exec_request_abi=336\n"
    .ascii "launcher_state.offset.exec_request_bytes=344\n"
    .ascii "launcher_state.offset.exec_request_reserved=352\n"
    .ascii "launcher_state.offset.exec_request_path=360\n"
    .ascii "launcher_state.offset.exec_argv=368\n"
    .ascii "launcher_state.offset.exec_attempt_state=376\n"
    .ascii "launcher_state.offset.exec_request_count=384\n"
    .ascii "launcher_state.exec_attempt_state.0=idle\n"
    .ascii "launcher_state.exec_attempt_state.1=prepared\n"
    .ascii "launcher_state.exec_attempt_state.2=returned\n"
    .ascii "launcher_state.exec_attempt_state.3=enosys\n"
    .ascii "launcher_state.exec_attempt_state.4=failed\n"
    .ascii "launcher_state.exec_attempt_state.5=ok\n"
    .ascii "launcher_exec_enosys_claim=request-recorded-app-only\n"
    .ascii "launcher_visible_app_record_state=fullscreen-desktop-app-cards\n"
    .ascii "launcher_visible_selected_state=focus-hover-card-and-button\n"
    .ascii "launcher_visible_exec_request=active-click-or-enter-launch\n"
    .ascii "launcher_visible_launch_state=pressed-play-button-before-exec\n"
    .ascii "launcher_visible_failure_return=failed-card-button-stripe\n"
    .ascii "launcher_visible_hover_state=cursor-corner-brackets-on-padded-card-hitbox\n"
    .ascii "launcher_visible_launch_affordance=card-play-button-glyph-and-1-2-key-badges\n"
    .ascii "launcher_visible_keyboard_labels=1-2-key-badges-and-enter-button-label\n"
    .ascii "launcher_visible_app_labels=manifest-name-rendered-with-aarch64-5x7-font\n"
    .ascii "launcher_visible_art_default=retro-mac-icon-well-with-large-real-asset-icons-and-readable-labels\n"
    .ascii "launcher_visible_card_chrome=pinstripe-titlebars-close-boxes-accent-slugs\n"
    .ascii "launcher_visible_layout=1280x720-topbar56-header1216x92-picker1216x504\n"
    .ascii "launcher_visible_card_rects=doom48,204,552,464;quake680,204,552,464\n"
    .ascii "launcher_visible_art_rects=doom72,216,504,288;quake704,216,504,288\n"
    .ascii "launcher_visible_app_icon_rects=doom164,228,320,320;quake796,228,320,320\n"
    .ascii "launcher_visible_button_rects=doom188,612,272,48;quake820,612,272,48\n"
    .ascii "launcher_visible_key_badges=doom120,612,48,48;quake752,612,48,48\n"
    .ascii "launcher_exec_argv_envp=path-stable-argv-empty-envp\n"
    .ascii "launcher_frame_evidence_schema=vibe-os-pi4-frame-evidence-v1\n"
    .ascii "launcher_frame_evidence.source=fbinfo-after-present\n"
    .ascii "launcher_frame_evidence.symbol.fbinfo=pi4_launcher_fbinfo\n"
    .ascii "launcher_frame_evidence.symbol.fbinfo_status=pi4_launcher_fbinfo_status\n"
    .ascii "launcher_frame_evidence.symbol.fb_dirty_count=pi4_launcher_fb_dirty_count\n"
    .ascii "launcher_input_source=vibe_user_poll_input\n"
    .ascii "launcher_input_lane=keyboard-mouse-uart\n"
    .ascii "launcher_input_events=click/enter/space/arrows/wasd/1/2-select/usb-hid\n"
    .ascii "launcher_mouse_policy=hover-focus-padded-card-left-press-launch\n"
    .ascii "launcher_mouse_press_policy=left-press-edge-inside-hitbox-records\n"
    .ascii "launcher_cursor_start=doom-play-button-center\n"
    .ascii "launcher_mouse_hitbox.doom=x24,y168,w600,h512\n"
    .ascii "launcher_mouse_hitbox.quake=x656,y168,w600,h512\n"
    .ascii "app_launch_claim=generic-path-exec-syscall\n"
    .byte 0

.balign 8
pi4_launcher_app_index_path:
    .asciz "/APPS/INDEX.TXT"
pi4_launcher_key_app_count:
    .asciz "app_count="
pi4_launcher_key_name:
    .asciz "name="
pi4_launcher_key_id:
    .asciz "id="
pi4_launcher_key_exec:
    .asciz "exec="
pi4_launcher_key_asset:
    .asciz "asset="
pi4_launcher_key_icon:
    .asciz "icon="

pi4_launcher_app_record_generic_name:
    .asciz "APP"

.balign 8
pi4_launcher_card_records:
    .quad PI4_LAUNCHER_APP_RECORD_0
    .quad PI4_LAUNCHER_DOOM_CARD_X
    .quad PI4_LAUNCHER_DOOM_ICON_X
    .quad PI4_COLOR_DOOM_FIRE
    .quad PI4_COLOR_DOOM_DARK
    .quad pi4_launcher_draw_doom_poster
    .quad pi4_launcher_draw_doom_icon
    .quad pi4_launcher_key_1_bitmap
    .quad pi4_launcher_doom_icon_pixels
    .quad PI4_LAUNCHER_APP_RECORD_1
    .quad PI4_LAUNCHER_QUAKE_CARD_X
    .quad PI4_LAUNCHER_QUAKE_ICON_X
    .quad PI4_COLOR_QUAKE_GOLD
    .quad PI4_COLOR_QUAKE_DARK
    .quad pi4_launcher_draw_quake_poster
    .quad pi4_launcher_draw_quake_icon
    .quad pi4_launcher_key_2_bitmap
    .quad pi4_launcher_quake_icon_pixels

.balign 8
pi4_launcher_desktop_app_record_defaults:
    .quad pi4_launcher_active_app_record
    .quad PI4_LAUNCHER_APP_RECORD_NONE
    .quad pi4_launcher_hover_app_record
    .quad PI4_LAUNCHER_APP_RECORD_DEFAULT
    .quad pi4_launcher_failed_app_record
    .quad PI4_LAUNCHER_APP_RECORD_NONE
pi4_launcher_desktop_app_record_defaults_end:

.section .data.pi4_launcher_state, "aw", %progbits
.balign 8
.global pi4_launcher_state
pi4_launcher_state:
    .quad PI4_LAUNCHER_STATE_MAGIC
    .quad PI4_LAUNCHER_PHASE_COLD
    .quad pi4_launcher_frame
    .quad PI4_LAUNCHER_FRAME_WIDTH
    .quad PI4_LAUNCHER_FRAME_HEIGHT
    .quad PI4_LAUNCHER_FRAME_STRIDE
    .quad PI4_LAUNCHER_FRAME_BYTES
    .quad PI4_LAUNCHER_APP_RECORD_COUNT
    .quad PI4_LAUNCHER_APP_RECORD_DEFAULT
    .quad pi4_launcher_app_catalog_table
    .quad pi4_launcher_app_record_generic_name
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad PI4_LAUNCHER_APP_RECORD_DEFAULT
    .quad pi4_launcher_app_catalog_table
    .quad pi4_launcher_app_record_generic_name
    .quad 0
    .quad pi4_launcher_exec_request
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad pi4_launcher_app_record_absent_state
    .quad 0
    .quad pi4_launcher_app_record_absent_state
    .quad PI4_LAUNCHER_STATE_ABI_VERSION_VALUE
    .quad PI4_LAUNCHER_STATE_TOTAL_BYTES_VALUE
    .quad 0
    .quad 0
    .quad PI4_LAUNCHER_INPUT_ACTION_NONE
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    .quad PI4_VIBE_EXEC_REQUEST_BYTES
    .quad -1
    .quad 0
    .quad pi4_launcher_exec_argv
    .quad PI4_LAUNCHER_EXEC_ATTEMPT_IDLE
    .quad 0
.global pi4_launcher_state_end
pi4_launcher_state_end:

.balign 8
.global pi4_launcher_exec_request
pi4_launcher_exec_request:
    .quad PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    .quad PI4_VIBE_EXEC_REQUEST_BYTES
    .quad -1
    .quad 0

.balign 8
.global pi4_launcher_exec_argv
pi4_launcher_exec_argv:
    .quad 0
    .quad 0
.global pi4_launcher_exec_envp
pi4_launcher_exec_envp:
    .quad 0

.balign 8
.global pi4_launcher_cursor_x
pi4_launcher_cursor_x:
    .quad PI4_LAUNCHER_CURSOR_START_X
.global pi4_launcher_cursor_y
pi4_launcher_cursor_y:
    .quad PI4_LAUNCHER_CURSOR_START_Y
.global pi4_launcher_mouse_buttons
pi4_launcher_mouse_buttons:
    .quad 0
.global pi4_launcher_active_app_record
pi4_launcher_active_app_record:
    .quad PI4_LAUNCHER_APP_RECORD_NONE
.global pi4_launcher_hover_app_record
pi4_launcher_hover_app_record:
    .quad PI4_LAUNCHER_APP_RECORD_DEFAULT
.global pi4_launcher_failed_app_record
pi4_launcher_failed_app_record:
    .quad PI4_LAUNCHER_APP_RECORD_NONE

.balign 8
.global pi4_launcher_present
pi4_launcher_present:
    .quad pi4_launcher_frame
    .quad pi4_launcher_indexed_palette
    .quad PI4_LAUNCHER_FRAME_WIDTH
    .quad PI4_LAUNCHER_FRAME_HEIGHT

.global pi4_launcher_present_status
pi4_launcher_present_status:
    .quad 0

.balign 8
.global pi4_launcher_fbinfo_status
pi4_launcher_fbinfo_status:
    .quad -1
.global pi4_launcher_fbinfo_count
pi4_launcher_fbinfo_count:
    .quad 0
.global pi4_launcher_fb_dirty_x
pi4_launcher_fb_dirty_x:
    .quad 0
.global pi4_launcher_fb_dirty_y
pi4_launcher_fb_dirty_y:
    .quad 0
.global pi4_launcher_fb_dirty_width
pi4_launcher_fb_dirty_width:
    .quad 0
.global pi4_launcher_fb_dirty_height
pi4_launcher_fb_dirty_height:
    .quad 0
.global pi4_launcher_fb_dirty_count
pi4_launcher_fb_dirty_count:
    .quad 0
.global pi4_launcher_fb_capabilities
pi4_launcher_fb_capabilities:
    .quad 0
.global pi4_launcher_fb_present_format
pi4_launcher_fb_present_format:
    .quad 0
.global pi4_launcher_fb_max_present_width
pi4_launcher_fb_max_present_width:
    .quad 0
.global pi4_launcher_fb_max_present_height
pi4_launcher_fb_max_present_height:
    .quad 0

.balign 8
.global pi4_launcher_app_discovered_count
pi4_launcher_app_discovered_count:
    .quad 0
.global pi4_launcher_app_index_count
pi4_launcher_app_index_count:
    .quad 0
pi4_launcher_app_text_size:
    .quad 0
pi4_launcher_app_read_size:
    .quad 0

.section .bss.pi4_launcher_input, "aw", %nobits
.balign 8
pi4_launcher_input_event:
    .skip PI4_VIBE_INPUT_EVENT_BYTES

.section .bss.pi4_launcher_apps, "aw", %nobits
.balign 16
pi4_launcher_app_text_buffer:
    .skip PI4_LAUNCHER_APP_TEXT_BYTES
.balign 8
pi4_launcher_app_magic_buffer:
    .skip 8
.balign 16
pi4_launcher_app_index_key_buffer:
    .skip PI4_LAUNCHER_APP_KEY_BYTES
.balign 16
pi4_launcher_app_count_value:
    .skip PI4_LAUNCHER_APP_COUNT_BYTES
.balign 16
.global pi4_launcher_app_record_names
pi4_launcher_app_record_names:
    .skip PI4_LAUNCHER_APP_NAME_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT
.balign 16
.global pi4_launcher_app_record_paths
pi4_launcher_app_record_paths:
    .skip PI4_LAUNCHER_APP_PATH_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT
.balign 16
.global pi4_launcher_app_record_assets
pi4_launcher_app_record_assets:
    .skip PI4_LAUNCHER_APP_PATH_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT
.balign 16
.global pi4_launcher_app_record_icons
pi4_launcher_app_record_icons:
    .skip PI4_LAUNCHER_APP_ICON_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT
.balign 16
.global pi4_launcher_app_manifest_paths
pi4_launcher_app_manifest_paths:
    .skip PI4_LAUNCHER_APP_PATH_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT
.balign 16
.global pi4_launcher_app_catalog_table
pi4_launcher_app_catalog_table:
    .skip PI4_LAUNCHER_APP_RECORD_BYTES * PI4_LAUNCHER_APP_RECORD_COUNT

.section .bss.pi4_launcher_fbinfo, "aw", %nobits
.balign 8
.global pi4_launcher_fbinfo
pi4_launcher_fbinfo:
    .skip PI4_VIBE_FB_INFO_BYTES

.section .bss.pi4_launcher_frame, "aw", %nobits
.balign 64
.global pi4_launcher_frame
pi4_launcher_frame:
    .skip PI4_LAUNCHER_FRAME_BYTES

.section .note.GNU-stack, "", %progbits
