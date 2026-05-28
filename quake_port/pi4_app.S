#include "pi4_runtime.h"

// Native AArch64 Quake app for the Pi lane.
//
// This still does not claim the original Quake engine is linked, but it is no
// longer just a slot scaffold: it opens the Quake PAK, consumes the runtime
// input queue, updates an app-owned arena/crosshair state from keyboard,
// mouse, and UART events, and continuously presents changed indexed frames
// through the Pi framebuffer ABI.

.arch armv8-a

.equ PI4_QUAKE_FRAME_WIDTH,        320
.equ PI4_QUAKE_FRAME_HEIGHT,       200
.equ PI4_QUAKE_FRAME_BYTES,        64000

.equ PI4_INPUT_EVENT_TIMESTAMP,    0
.equ PI4_INPUT_EVENT_DEVICE_ID,    8
.equ PI4_INPUT_EVENT_TYPE,         16
.equ PI4_INPUT_EVENT_CODE,         24
.equ PI4_INPUT_EVENT_VALUE0,       32
.equ PI4_INPUT_EVENT_VALUE1,       40
.equ PI4_INPUT_DEVICE_KEYBOARD,    PI4_VIBE_INPUT_DEVICE_KEYBOARD
.equ PI4_INPUT_DEVICE_MOUSE,       PI4_VIBE_INPUT_DEVICE_MOUSE
.equ PI4_INPUT_DEVICE_UART,        PI4_VIBE_INPUT_DEVICE_UART
.equ PI4_INPUT_DEVICE_USB,         PI4_VIBE_INPUT_DEVICE_USB
.equ PI4_INPUT_EVENT_KEY,          PI4_VIBE_INPUT_EVENT_KEY
.equ PI4_INPUT_EVENT_MOUSE_PACKET, PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
.equ PI4_INPUT_EVENT_UART,         PI4_VIBE_INPUT_EVENT_UART
.equ PI4_INPUT_KEY_PRESSED,        1
.equ PI4_INPUT_KEY_SCANCODE_MASK,  0x7f
.equ PI4_INPUT_MOUSE_BUTTON_LEFT,  0x01
.equ PI4_INPUT_KEY_TOKEN_HID_SHIFT, PI4_VIBE_INPUT_EVENT_KEY_TOKEN_HID_SHIFT
.equ PI4_INPUT_KEY_TOKEN_FIELD_MASK, PI4_VIBE_INPUT_EVENT_KEY_TOKEN_FIELD_MASK

.equ PI4_INPUT_SCANCODE_ESCAPE,    0x01
.equ PI4_INPUT_SCANCODE_W,         0x11
.equ PI4_INPUT_SCANCODE_CTRL,      0x1d
.equ PI4_INPUT_SCANCODE_A,         0x1e
.equ PI4_INPUT_SCANCODE_S,         0x1f
.equ PI4_INPUT_SCANCODE_D,         0x20
.equ PI4_INPUT_SCANCODE_LSHIFT,    0x2a
.equ PI4_INPUT_SCANCODE_RSHIFT,    0x36
.equ PI4_INPUT_SCANCODE_ENTER,     0x1c
.equ PI4_INPUT_SCANCODE_SPACE,     0x39
.equ PI4_INPUT_SCANCODE_UP,        0x48
.equ PI4_INPUT_SCANCODE_LEFT,      0x4b
.equ PI4_INPUT_SCANCODE_RIGHT,     0x4d
.equ PI4_INPUT_SCANCODE_DOWN,      0x50
.equ PI4_INPUT_HID_USAGE_ESCAPE,   PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ESCAPE
.equ PI4_INPUT_HID_USAGE_W,        PI4_VIBE_INPUT_KEY_USB_HID_USAGE_W
.equ PI4_INPUT_HID_USAGE_A,        PI4_VIBE_INPUT_KEY_USB_HID_USAGE_A
.equ PI4_INPUT_HID_USAGE_S,        PI4_VIBE_INPUT_KEY_USB_HID_USAGE_S
.equ PI4_INPUT_HID_USAGE_D,        PI4_VIBE_INPUT_KEY_USB_HID_USAGE_D
.equ PI4_INPUT_HID_USAGE_ENTER,    PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ENTER
.equ PI4_INPUT_HID_USAGE_SPACE,    PI4_VIBE_INPUT_KEY_USB_HID_USAGE_SPACE
.equ PI4_INPUT_HID_USAGE_LEFT,     PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT
.equ PI4_INPUT_HID_USAGE_RIGHT,    PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT
.equ PI4_INPUT_HID_USAGE_UP,       PI4_VIBE_INPUT_KEY_USB_HID_USAGE_UP
.equ PI4_INPUT_HID_USAGE_DOWN,     PI4_VIBE_INPUT_KEY_USB_HID_USAGE_DOWN
.equ PI4_INPUT_HID_USAGE_LEFT_CTRL, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_CTRL
.equ PI4_INPUT_HID_USAGE_LEFT_SHIFT, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_SHIFT
.equ PI4_INPUT_HID_USAGE_RIGHT_CTRL, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_CTRL
.equ PI4_INPUT_HID_USAGE_RIGHT_SHIFT, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_SHIFT

.equ PI4_QUAKE_KEY_FORWARD,        0x01
.equ PI4_QUAKE_KEY_BACK,           0x02
.equ PI4_QUAKE_KEY_LEFT,           0x04
.equ PI4_QUAKE_KEY_RIGHT,          0x08
.equ PI4_QUAKE_KEY_FIRE,           0x10
.equ PI4_QUAKE_KEY_JUMP,           0x20
.equ PI4_QUAKE_KEY_LOOK_UP,        0x40
.equ PI4_QUAKE_KEY_LOOK_DOWN,      0x80
.equ PI4_QUAKE_KEY_LOOK_LEFT,      0x100
.equ PI4_QUAKE_KEY_LOOK_RIGHT,     0x200

.equ PI4_QUAKE_STATE_MAGIC,        0
.equ PI4_QUAKE_STATE_ARGC,         8
.equ PI4_QUAKE_STATE_ARGV,         16
.equ PI4_QUAKE_STATE_ENVP,         24
.equ PI4_QUAKE_STATE_FRAME_INDEX,  32
.equ PI4_QUAKE_STATE_INPUT_COUNT,  40
.equ PI4_QUAKE_STATE_LAST_CODE,    48
.equ PI4_QUAKE_STATE_PRESENT,      56
.equ PI4_QUAKE_STATE_POLL,         64
.equ PI4_QUAKE_STATE_PLAYER_X,     72
.equ PI4_QUAKE_STATE_PLAYER_Y,     80
.equ PI4_QUAKE_STATE_PRESENTS,     88
.equ PI4_QUAKE_STATE_AIM_X,        96
.equ PI4_QUAKE_STATE_AIM_Y,        104
.equ PI4_QUAKE_STATE_KEY_MASK,     112
.equ PI4_QUAKE_STATE_MOUSE_BUTTONS,120
.equ PI4_QUAKE_STATE_SHOT_COUNT,   128
.equ PI4_QUAKE_STATE_LAST_DEVICE,  136
.equ PI4_QUAKE_STATE_LAST_TYPE,    144
.equ PI4_QUAKE_STATE_LAST_DX,      152
.equ PI4_QUAKE_STATE_LAST_DY,      160
.equ PI4_QUAKE_STATE_SCORE,        168
.equ PI4_QUAKE_STATE_SCORED_SHOT,  176
.equ PI4_QUAKE_STATE_MUZZLE_TICKS, 184
.equ PI4_QUAKE_STATE_TARGET_X,     192
.equ PI4_QUAKE_STATE_TARGET_Y,     200
.equ PI4_QUAKE_STATE_TARGET_DX,    208
.equ PI4_QUAKE_STATE_HIT_TICKS,    216
.equ PI4_QUAKE_STATE_JUMP_TICKS,   224
.equ PI4_QUAKE_STATE_MENU_OPEN,    232
.equ PI4_QUAKE_STATE_PAK_FD,       240
.equ PI4_QUAKE_STATE_PAK_SIZE,     248
.equ PI4_QUAKE_STATE_PAK_READ,     256
.equ PI4_QUAKE_STATE_PAK_MAGIC,    264
.equ PI4_QUAKE_STATE_PAK_STATUS,   272
.equ PI4_QUAKE_STATE_PAK_DIR_OFS,  280
.equ PI4_QUAKE_STATE_PAK_DIR_LEN,  288
.equ PI4_QUAKE_STATE_PAK_ENTRIES,  296
.equ PI4_QUAKE_STATE_PAK_SEED,     304
.equ PI4_QUAKE_STATE_BYTES,        312

.extern vibe_user_file_open
.extern vibe_user_file_read
.extern vibe_user_file_size
.extern vibe_user_present_indexed_checked
.extern vibe_user_poll_input

.section .text.pi4_quake_app.entry, "ax", %progbits
.balign 16
.global user_main
.global pi4_quake_app_start
.type user_main, %function
.type pi4_quake_app_start, %function
user_main:
pi4_quake_app_start:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    adrp x19, pi4_quake_app_state
    add x19, x19, :lo12:pi4_quake_app_state
    movz x9, #0x4159
    movk x9, #0x5150, lsl #16
    movk x9, #0x4b45, lsl #32
    str x9, [x19, #PI4_QUAKE_STATE_MAGIC]
    str x0, [x19, #PI4_QUAKE_STATE_ARGC]
    str x1, [x19, #PI4_QUAKE_STATE_ARGV]
    str x2, [x19, #PI4_QUAKE_STATE_ENVP]

    mov x20, xzr
    str xzr, [x19, #PI4_QUAKE_STATE_INPUT_COUNT]
    str xzr, [x19, #PI4_QUAKE_STATE_LAST_CODE]
    mov x9, #160
    str x9, [x19, #PI4_QUAKE_STATE_PLAYER_X]
    str x9, [x19, #PI4_QUAKE_STATE_AIM_X]
    mov x9, #112
    str x9, [x19, #PI4_QUAKE_STATE_PLAYER_Y]
    mov x9, #96
    str x9, [x19, #PI4_QUAKE_STATE_AIM_Y]
    str xzr, [x19, #PI4_QUAKE_STATE_PRESENTS]
    str xzr, [x19, #PI4_QUAKE_STATE_KEY_MASK]
    str xzr, [x19, #PI4_QUAKE_STATE_MOUSE_BUTTONS]
    str xzr, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    str xzr, [x19, #PI4_QUAKE_STATE_SCORE]
    str xzr, [x19, #PI4_QUAKE_STATE_SCORED_SHOT]
    str xzr, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
    mov x9, #164
    str x9, [x19, #PI4_QUAKE_STATE_TARGET_X]
    mov x9, #88
    str x9, [x19, #PI4_QUAKE_STATE_TARGET_Y]
    mov x9, #2
    str x9, [x19, #PI4_QUAKE_STATE_TARGET_DX]
    str xzr, [x19, #PI4_QUAKE_STATE_HIT_TICKS]
    str xzr, [x19, #PI4_QUAKE_STATE_JUMP_TICKS]
    str xzr, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_FD]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_SIZE]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_READ]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_MAGIC]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_DIR_OFS]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_DIR_LEN]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_ENTRIES]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_SEED]

    mov x0, x19
    bl pi4_quake_probe_pak

.Lpi4_quake_frame_loop:
    str x20, [x19, #PI4_QUAKE_STATE_FRAME_INDEX]

    mov x0, x19
    bl pi4_quake_poll_inputs

    mov x0, x19
    bl pi4_quake_step_game

    mov x0, x19
    bl pi4_quake_render_frame

    adrp x0, pi4_quake_present
    add x0, x0, :lo12:pi4_quake_present
    bl vibe_user_present_indexed_checked
    str x0, [x19, #PI4_QUAKE_STATE_PRESENT]
    ldr x9, [x19, #PI4_QUAKE_STATE_PRESENTS]
    add x9, x9, #1
    str x9, [x19, #PI4_QUAKE_STATE_PRESENTS]

    add x20, x20, #1
    mov x9, #0x2000
.Lpi4_quake_frame_pace:
    subs x9, x9, #1
    b.ne .Lpi4_quake_frame_pace
    b .Lpi4_quake_frame_loop

    mov x0, xzr
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size user_main, . - user_main
.size pi4_quake_app_start, . - pi4_quake_app_start

.type pi4_quake_probe_pak, %function
pi4_quake_probe_pak:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0

    adrp x0, pi4_quake_pak_path
    add x0, x0, :lo12:pi4_quake_pak_path
    bl vibe_user_file_open
    str x0, [x19, #PI4_QUAKE_STATE_PAK_FD]
    cmp x0, #0
    b.lt .Lpi4_quake_probe_missing

    mov x20, x0
    bl vibe_user_file_size
    str x0, [x19, #PI4_QUAKE_STATE_PAK_SIZE]
    cmp x0, #0
    b.lt .Lpi4_quake_probe_open_only

    mov x0, x20
    adrp x1, pi4_quake_pak_header
    add x1, x1, :lo12:pi4_quake_pak_header
    mov x2, #12
    bl vibe_user_file_read
    str x0, [x19, #PI4_QUAKE_STATE_PAK_READ]
    cmp x0, #12
    b.lt .Lpi4_quake_probe_open_only

    adrp x9, pi4_quake_pak_header
    add x9, x9, :lo12:pi4_quake_pak_header
    ldr w10, [x9]
    str x10, [x19, #PI4_QUAKE_STATE_PAK_MAGIC]
    mov w11, #0x4150
    movk w11, #0x4b43, lsl #16
    cmp w10, w11
    b.ne .Lpi4_quake_probe_open_only
    ldr w11, [x9, #4]
    ldr w12, [x9, #8]
    str x11, [x19, #PI4_QUAKE_STATE_PAK_DIR_OFS]
    str x12, [x19, #PI4_QUAKE_STATE_PAK_DIR_LEN]
    lsr x13, x12, #6
    str x13, [x19, #PI4_QUAKE_STATE_PAK_ENTRIES]
    ldr x14, [x19, #PI4_QUAKE_STATE_PAK_SIZE]
    eor x13, x11, x12
    eor x13, x13, x14
    and x13, x13, #0xff
    str x13, [x19, #PI4_QUAKE_STATE_PAK_SEED]
    mov x9, #2
    str x9, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    b .Lpi4_quake_probe_done

.Lpi4_quake_probe_open_only:
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_DIR_OFS]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_DIR_LEN]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_ENTRIES]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_SEED]
    mov x9, #1
    str x9, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    b .Lpi4_quake_probe_done

.Lpi4_quake_probe_missing:
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_SIZE]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_READ]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_MAGIC]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_DIR_OFS]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_DIR_LEN]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_ENTRIES]
    str xzr, [x19, #PI4_QUAKE_STATE_PAK_SEED]

.Lpi4_quake_probe_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_quake_probe_pak, . - pi4_quake_probe_pak

.type pi4_quake_poll_inputs, %function
pi4_quake_poll_inputs:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0
    mov x20, #16

.Lpi4_quake_poll_next:
    adrp x0, pi4_quake_input_event
    add x0, x0, :lo12:pi4_quake_input_event
    bl vibe_user_poll_input
    str x0, [x19, #PI4_QUAKE_STATE_POLL]
    cmp x0, #1
    b.ne .Lpi4_quake_poll_done

    ldr x9, [x19, #PI4_QUAKE_STATE_INPUT_COUNT]
    add x9, x9, #1
    str x9, [x19, #PI4_QUAKE_STATE_INPUT_COUNT]

    adrp x10, pi4_quake_input_event
    add x10, x10, :lo12:pi4_quake_input_event
    ldr x11, [x10, #PI4_INPUT_EVENT_DEVICE_ID]
    ldr x12, [x10, #PI4_INPUT_EVENT_TYPE]
    ldr x13, [x10, #PI4_INPUT_EVENT_CODE]
    str x11, [x19, #PI4_QUAKE_STATE_LAST_DEVICE]
    str x12, [x19, #PI4_QUAKE_STATE_LAST_TYPE]
    str x13, [x19, #PI4_QUAKE_STATE_LAST_CODE]

    cmp x11, #PI4_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_quake_poll_keyboard
    cmp x11, #PI4_INPUT_DEVICE_MOUSE
    b.eq .Lpi4_quake_poll_mouse
    cmp x11, #PI4_INPUT_DEVICE_USB
    b.eq .Lpi4_quake_poll_usb
    cmp x11, #PI4_INPUT_DEVICE_UART
    b.eq .Lpi4_quake_poll_uart
    b .Lpi4_quake_poll_consume_done

.Lpi4_quake_poll_keyboard:
    cmp x12, #PI4_INPUT_EVENT_KEY
    b.ne .Lpi4_quake_poll_consume_done
    ldr x14, [x10, #PI4_INPUT_EVENT_VALUE0]
    ldr x15, [x10, #PI4_INPUT_EVENT_VALUE1]
    cbnz x15, .Lpi4_quake_usb_hid_ready
    and x13, x13, #PI4_INPUT_KEY_SCANCODE_MASK
    b .Lpi4_quake_key_dispatch

.Lpi4_quake_poll_usb:
    cmp x12, #PI4_INPUT_EVENT_MOUSE_PACKET
    b.eq .Lpi4_quake_poll_mouse
    cmp x12, #PI4_INPUT_EVENT_KEY
    b.ne .Lpi4_quake_poll_consume_done
    ldr x14, [x10, #PI4_INPUT_EVENT_VALUE0]
    ldr x15, [x10, #PI4_INPUT_EVENT_VALUE1]
    cbnz x15, .Lpi4_quake_usb_hid_ready
    lsr x15, x13, #PI4_INPUT_KEY_TOKEN_HID_SHIFT
    and x15, x15, #PI4_INPUT_KEY_TOKEN_FIELD_MASK
    cbnz x15, .Lpi4_quake_usb_hid_ready
    and x15, x13, #PI4_INPUT_KEY_TOKEN_FIELD_MASK
.Lpi4_quake_usb_hid_ready:
    cmp x15, #PI4_INPUT_HID_USAGE_ESCAPE
    b.eq .Lpi4_quake_usb_escape
    cmp x15, #PI4_INPUT_HID_USAGE_W
    b.eq .Lpi4_quake_usb_w
    cmp x15, #PI4_INPUT_HID_USAGE_UP
    b.eq .Lpi4_quake_usb_up
    cmp x15, #PI4_INPUT_HID_USAGE_S
    b.eq .Lpi4_quake_usb_s
    cmp x15, #PI4_INPUT_HID_USAGE_DOWN
    b.eq .Lpi4_quake_usb_down
    cmp x15, #PI4_INPUT_HID_USAGE_A
    b.eq .Lpi4_quake_usb_a
    cmp x15, #PI4_INPUT_HID_USAGE_LEFT
    b.eq .Lpi4_quake_usb_left
    cmp x15, #PI4_INPUT_HID_USAGE_D
    b.eq .Lpi4_quake_usb_d
    cmp x15, #PI4_INPUT_HID_USAGE_RIGHT
    b.eq .Lpi4_quake_usb_right
    cmp x15, #PI4_INPUT_HID_USAGE_ENTER
    b.eq .Lpi4_quake_usb_enter
    cmp x15, #PI4_INPUT_HID_USAGE_LEFT_CTRL
    b.eq .Lpi4_quake_usb_ctrl
    cmp x15, #PI4_INPUT_HID_USAGE_SPACE
    b.eq .Lpi4_quake_usb_space
    cmp x15, #PI4_INPUT_HID_USAGE_LEFT_SHIFT
    b.eq .Lpi4_quake_usb_lshift
    cmp x15, #PI4_INPUT_HID_USAGE_RIGHT_CTRL
    b.eq .Lpi4_quake_usb_ctrl
    cmp x15, #PI4_INPUT_HID_USAGE_RIGHT_SHIFT
    b.eq .Lpi4_quake_usb_rshift
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_usb_escape:
    mov x13, #PI4_INPUT_SCANCODE_ESCAPE
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_w:
    mov x13, #PI4_INPUT_SCANCODE_W
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_up:
    mov x13, #PI4_INPUT_SCANCODE_UP
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_s:
    mov x13, #PI4_INPUT_SCANCODE_S
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_down:
    mov x13, #PI4_INPUT_SCANCODE_DOWN
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_a:
    mov x13, #PI4_INPUT_SCANCODE_A
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_left:
    mov x13, #PI4_INPUT_SCANCODE_LEFT
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_d:
    mov x13, #PI4_INPUT_SCANCODE_D
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_right:
    mov x13, #PI4_INPUT_SCANCODE_RIGHT
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_enter:
    mov x13, #PI4_INPUT_SCANCODE_ENTER
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_ctrl:
    mov x13, #PI4_INPUT_SCANCODE_CTRL
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_space:
    mov x13, #PI4_INPUT_SCANCODE_SPACE
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_lshift:
    mov x13, #PI4_INPUT_SCANCODE_LSHIFT
    b .Lpi4_quake_key_dispatch
.Lpi4_quake_usb_rshift:
    mov x13, #PI4_INPUT_SCANCODE_RSHIFT

.Lpi4_quake_key_dispatch:
    mov x15, #0
    cmp x13, #PI4_INPUT_SCANCODE_ESCAPE
    b.eq .Lpi4_quake_key_menu
    cmp x13, #PI4_INPUT_SCANCODE_W
    b.eq .Lpi4_quake_key_forward
    cmp x13, #PI4_INPUT_SCANCODE_UP
    b.eq .Lpi4_quake_key_look_up
    cmp x13, #PI4_INPUT_SCANCODE_S
    b.eq .Lpi4_quake_key_back
    cmp x13, #PI4_INPUT_SCANCODE_DOWN
    b.eq .Lpi4_quake_key_look_down
    cmp x13, #PI4_INPUT_SCANCODE_A
    b.eq .Lpi4_quake_key_left
    cmp x13, #PI4_INPUT_SCANCODE_LEFT
    b.eq .Lpi4_quake_key_look_left
    cmp x13, #PI4_INPUT_SCANCODE_D
    b.eq .Lpi4_quake_key_right
    cmp x13, #PI4_INPUT_SCANCODE_RIGHT
    b.eq .Lpi4_quake_key_look_right
    cmp x13, #PI4_INPUT_SCANCODE_ENTER
    b.eq .Lpi4_quake_key_fire
    cmp x13, #PI4_INPUT_SCANCODE_CTRL
    b.eq .Lpi4_quake_key_fire
    cmp x13, #PI4_INPUT_SCANCODE_SPACE
    b.eq .Lpi4_quake_key_jump
    cmp x13, #PI4_INPUT_SCANCODE_LSHIFT
    b.eq .Lpi4_quake_key_jump
    cmp x13, #PI4_INPUT_SCANCODE_RSHIFT
    b.eq .Lpi4_quake_key_jump
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_key_menu:
    cbz x14, .Lpi4_quake_poll_consume_done
    ldr x16, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    eor x16, x16, #1
    str x16, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_key_forward:
    mov x15, #PI4_QUAKE_KEY_FORWARD
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_back:
    mov x15, #PI4_QUAKE_KEY_BACK
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_left:
    mov x15, #PI4_QUAKE_KEY_LEFT
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_right:
    mov x15, #PI4_QUAKE_KEY_RIGHT
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_fire:
    ldr x16, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    cbz x16, .Lpi4_quake_key_fire_game
    cbz x14, .Lpi4_quake_poll_consume_done
    str xzr, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_key_fire_game:
    mov x15, #PI4_QUAKE_KEY_FIRE
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_jump:
    ldr x16, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    cbz x16, .Lpi4_quake_key_jump_game
    cbz x14, .Lpi4_quake_poll_consume_done
    str xzr, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_key_jump_game:
    mov x15, #PI4_QUAKE_KEY_JUMP
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_look_up:
    mov x15, #PI4_QUAKE_KEY_LOOK_UP
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_look_down:
    mov x15, #PI4_QUAKE_KEY_LOOK_DOWN
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_look_left:
    mov x15, #PI4_QUAKE_KEY_LOOK_LEFT
    b .Lpi4_quake_key_update_mask
.Lpi4_quake_key_look_right:
    mov x15, #PI4_QUAKE_KEY_LOOK_RIGHT
.Lpi4_quake_key_update_mask:
    ldr x16, [x19, #PI4_QUAKE_STATE_KEY_MASK]
    cbz x14, .Lpi4_quake_key_release
    orr x16, x16, x15
    cmp x15, #PI4_QUAKE_KEY_FIRE
    b.eq .Lpi4_quake_key_press_fire
    cmp x15, #PI4_QUAKE_KEY_JUMP
    b.ne .Lpi4_quake_key_store
    mov x17, #18
    str x17, [x19, #PI4_QUAKE_STATE_JUMP_TICKS]
    b .Lpi4_quake_key_store
.Lpi4_quake_key_press_fire:
    ldr x17, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    add x17, x17, #1
    str x17, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    b .Lpi4_quake_key_store
.Lpi4_quake_key_release:
    bic x16, x16, x15
.Lpi4_quake_key_store:
    str x16, [x19, #PI4_QUAKE_STATE_KEY_MASK]
    b .Lpi4_quake_poll_consume_done

.Lpi4_quake_poll_mouse:
    cmp x12, #PI4_INPUT_EVENT_MOUSE_PACKET
    b.ne .Lpi4_quake_poll_consume_done
    ldr x14, [x10, #PI4_INPUT_EVENT_VALUE0]
    ldr x15, [x10, #PI4_INPUT_EVENT_VALUE1]
    str x14, [x19, #PI4_QUAKE_STATE_LAST_DX]
    str x15, [x19, #PI4_QUAKE_STATE_LAST_DY]
    ldr x16, [x19, #PI4_QUAKE_STATE_AIM_X]
    add x16, x16, x14
    mov x0, x16
    mov x1, #18
    mov x2, #301
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_AIM_X]
    ldr x16, [x19, #PI4_QUAKE_STATE_AIM_Y]
    sub x16, x16, x15
    mov x0, x16
    mov x1, #10
    mov x2, #189
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_AIM_Y]
    and x13, x13, #0x7
    str x13, [x19, #PI4_QUAKE_STATE_MOUSE_BUTTONS]
    tst x13, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.eq .Lpi4_quake_poll_consume_done
    ldr x16, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    add x16, x16, #1
    str x16, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    b .Lpi4_quake_poll_consume_done

.Lpi4_quake_poll_uart:
    cmp x12, #PI4_INPUT_EVENT_UART
    b.ne .Lpi4_quake_poll_consume_done
    cmp x13, #PI4_VIBE_UART_EVENT_UP
    b.eq .Lpi4_quake_uart_up
    cmp x13, #PI4_VIBE_UART_EVENT_DOWN
    b.eq .Lpi4_quake_uart_down
    cmp x13, #PI4_VIBE_UART_EVENT_SELECT_1
    b.eq .Lpi4_quake_uart_left
    cmp x13, #PI4_VIBE_UART_EVENT_SELECT_2
    b.eq .Lpi4_quake_uart_right
    cmp x13, #PI4_VIBE_UART_EVENT_CONFIRM
    b.eq .Lpi4_quake_uart_fire
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_uart_up:
    ldr x14, [x19, #PI4_QUAKE_STATE_PLAYER_Y]
    sub x14, x14, #5
    b .Lpi4_quake_uart_store_y
.Lpi4_quake_uart_down:
    ldr x14, [x19, #PI4_QUAKE_STATE_PLAYER_Y]
    add x14, x14, #5
.Lpi4_quake_uart_store_y:
    mov x0, x14
    mov x1, #24
    mov x2, #184
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_PLAYER_Y]
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_uart_left:
    ldr x14, [x19, #PI4_QUAKE_STATE_PLAYER_X]
    sub x14, x14, #5
    b .Lpi4_quake_uart_store_x
.Lpi4_quake_uart_right:
    ldr x14, [x19, #PI4_QUAKE_STATE_PLAYER_X]
    add x14, x14, #5
.Lpi4_quake_uart_store_x:
    mov x0, x14
    mov x1, #16
    mov x2, #303
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_PLAYER_X]
    b .Lpi4_quake_poll_consume_done
.Lpi4_quake_uart_fire:
    ldr x14, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    add x14, x14, #1
    str x14, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]

.Lpi4_quake_poll_consume_done:
    subs x20, x20, #1
    b.ne .Lpi4_quake_poll_next

.Lpi4_quake_poll_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_quake_poll_inputs, . - pi4_quake_poll_inputs

.type pi4_quake_step_game, %function
pi4_quake_step_game:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0

    ldr x10, [x19, #PI4_QUAKE_STATE_KEY_MASK]
    ldr x11, [x19, #PI4_QUAKE_STATE_PLAYER_X]
    ldr x12, [x19, #PI4_QUAKE_STATE_PLAYER_Y]

    tst x10, #PI4_QUAKE_KEY_FORWARD
    b.eq .Lpi4_quake_step_back
    sub x12, x12, #3
.Lpi4_quake_step_back:
    tst x10, #PI4_QUAKE_KEY_BACK
    b.eq .Lpi4_quake_step_left
    add x12, x12, #3
.Lpi4_quake_step_left:
    tst x10, #PI4_QUAKE_KEY_LEFT
    b.eq .Lpi4_quake_step_right
    sub x11, x11, #3
.Lpi4_quake_step_right:
    tst x10, #PI4_QUAKE_KEY_RIGHT
    b.eq .Lpi4_quake_step_clamp_x
    add x11, x11, #3

.Lpi4_quake_step_clamp_x:
    mov x0, x11
    mov x1, #16
    mov x2, #303
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_PLAYER_X]
    mov x0, x12
    mov x1, #24
    mov x2, #184
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_PLAYER_Y]

    ldr x10, [x19, #PI4_QUAKE_STATE_KEY_MASK]
    ldr x11, [x19, #PI4_QUAKE_STATE_AIM_X]
    ldr x12, [x19, #PI4_QUAKE_STATE_AIM_Y]
    tst x10, #PI4_QUAKE_KEY_LOOK_LEFT
    b.eq .Lpi4_quake_step_look_right
    sub x11, x11, #4
.Lpi4_quake_step_look_right:
    tst x10, #PI4_QUAKE_KEY_LOOK_RIGHT
    b.eq .Lpi4_quake_step_look_up
    add x11, x11, #4
.Lpi4_quake_step_look_up:
    tst x10, #PI4_QUAKE_KEY_LOOK_UP
    b.eq .Lpi4_quake_step_look_down
    sub x12, x12, #3
.Lpi4_quake_step_look_down:
    tst x10, #PI4_QUAKE_KEY_LOOK_DOWN
    b.eq .Lpi4_quake_step_clamp_aim
    add x12, x12, #3
.Lpi4_quake_step_clamp_aim:
    mov x0, x11
    mov x1, #18
    mov x2, #301
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_AIM_X]
    mov x0, x12
    mov x1, #10
    mov x2, #189
    bl pi4_quake_clamp
    str x0, [x19, #PI4_QUAKE_STATE_AIM_Y]

    ldr x13, [x19, #PI4_QUAKE_STATE_TARGET_X]
    ldr x14, [x19, #PI4_QUAKE_STATE_TARGET_DX]
    add x13, x13, x14
    cmp x13, #78
    b.ge .Lpi4_quake_target_check_right
    mov x13, #78
    neg x14, x14
    b .Lpi4_quake_target_store_x
.Lpi4_quake_target_check_right:
    cmp x13, #242
    b.le .Lpi4_quake_target_store_x
    mov x13, #242
    neg x14, x14
.Lpi4_quake_target_store_x:
    str x13, [x19, #PI4_QUAKE_STATE_TARGET_X]
    str x14, [x19, #PI4_QUAKE_STATE_TARGET_DX]

    ldr x15, [x19, #PI4_QUAKE_STATE_FRAME_INDEX]
    lsr x15, x15, #2
    and x15, x15, #0x1f
    cmp x15, #16
    b.lt .Lpi4_quake_target_y_ready
    mov x16, #31
    sub x15, x16, x15
.Lpi4_quake_target_y_ready:
    add x15, x15, #78
    str x15, [x19, #PI4_QUAKE_STATE_TARGET_Y]

    ldr x13, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
    cbz x13, .Lpi4_quake_step_hit_ticks
    sub x13, x13, #1
    str x13, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
.Lpi4_quake_step_hit_ticks:
    ldr x13, [x19, #PI4_QUAKE_STATE_HIT_TICKS]
    cbz x13, .Lpi4_quake_step_jump_ticks
    sub x13, x13, #1
    str x13, [x19, #PI4_QUAKE_STATE_HIT_TICKS]

.Lpi4_quake_step_jump_ticks:
    ldr x13, [x19, #PI4_QUAKE_STATE_JUMP_TICKS]
    cbz x13, .Lpi4_quake_step_autofire
    sub x13, x13, #1
    str x13, [x19, #PI4_QUAKE_STATE_JUMP_TICKS]

.Lpi4_quake_step_autofire:
    ldr x10, [x19, #PI4_QUAKE_STATE_KEY_MASK]
    tst x10, #PI4_QUAKE_KEY_FIRE
    b.eq .Lpi4_quake_step_shot
    ldr x13, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    ldr x14, [x19, #PI4_QUAKE_STATE_SCORED_SHOT]
    cmp x13, x14
    b.ne .Lpi4_quake_step_shot
    ldr x13, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
    cbnz x13, .Lpi4_quake_step_shot
    ldr x13, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    add x13, x13, #1
    str x13, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]

.Lpi4_quake_step_shot:
    ldr x10, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    cbz x10, .Lpi4_quake_step_done
    ldr x14, [x19, #PI4_QUAKE_STATE_SCORED_SHOT]
    cmp x10, x14
    b.eq .Lpi4_quake_step_done
    str x10, [x19, #PI4_QUAKE_STATE_SCORED_SHOT]

    mov x14, #10
    str x14, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]

    ldr x11, [x19, #PI4_QUAKE_STATE_TARGET_X]
    ldr x12, [x19, #PI4_QUAKE_STATE_AIM_X]
    sub x13, x12, x11
    mov x14, #22
    neg x14, x14
    cmp x13, x14
    b.lt .Lpi4_quake_step_done
    cmp x13, #22
    b.gt .Lpi4_quake_step_done
    ldr x11, [x19, #PI4_QUAKE_STATE_TARGET_Y]
    ldr x12, [x19, #PI4_QUAKE_STATE_AIM_Y]
    sub x13, x12, x11
    mov x14, #24
    neg x14, x14
    cmp x13, x14
    b.lt .Lpi4_quake_step_done
    cmp x13, #24
    b.gt .Lpi4_quake_step_done
    ldr x13, [x19, #PI4_QUAKE_STATE_SCORE]
    add x13, x13, #1
    str x13, [x19, #PI4_QUAKE_STATE_SCORE]
    mov x13, #16
    str x13, [x19, #PI4_QUAKE_STATE_HIT_TICKS]
    ldr x13, [x19, #PI4_QUAKE_STATE_TARGET_DX]
    neg x13, x13
    str x13, [x19, #PI4_QUAKE_STATE_TARGET_DX]

.Lpi4_quake_step_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_quake_step_game, . - pi4_quake_step_game

.type pi4_quake_clamp, %function
pi4_quake_clamp:
    cmp x0, x1
    b.ge .Lpi4_quake_clamp_max
    mov x0, x1
.Lpi4_quake_clamp_max:
    cmp x0, x2
    b.le .Lpi4_quake_clamp_done
    mov x0, x2
.Lpi4_quake_clamp_done:
    ret
.size pi4_quake_clamp, . - pi4_quake_clamp

.type pi4_quake_render_frame, %function
pi4_quake_render_frame:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    adrp x20, pi4_quake_frame
    add x20, x20, :lo12:pi4_quake_frame
    ldr x21, [x19, #PI4_QUAKE_STATE_FRAME_INDEX]
    ldr x22, [x19, #PI4_QUAKE_STATE_PLAYER_X]
    ldr x23, [x19, #PI4_QUAKE_STATE_PLAYER_Y]
    ldr x24, [x19, #PI4_QUAKE_STATE_AIM_X]
    ldr x25, [x19, #PI4_QUAKE_STATE_AIM_Y]
    ldr x26, [x19, #PI4_QUAKE_STATE_SHOT_COUNT]
    ldr x27, [x19, #PI4_QUAKE_STATE_SCORE]

    mov x0, x20
    mov x1, #0
    mov x2, #0
    mov x3, #PI4_QUAKE_FRAME_WIDTH
    mov x4, #54
    mov x5, #1
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #0
    mov x2, #54
    mov x3, #PI4_QUAKE_FRAME_WIDTH
    mov x4, #78
    mov x5, #3
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #0
    mov x2, #132
    mov x3, #PI4_QUAKE_FRAME_WIDTH
    mov x4, #68
    mov x5, #5
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, x21
    mov x2, x22
    mov x3, x23
    bl pi4_quake_draw_world_motion

    and x28, x21, #0x1f
    mov x0, x20
    mov x1, #112
    sub x1, x1, x28, lsr #2
    mov x2, #44
    mov x3, #96
    add x3, x3, x28, lsr #1
    mov x4, #88
    mov x5, #2
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #106
    mov x2, #42
    mov x3, #4
    mov x4, #94
    mov x5, #4
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #210
    mov x2, #42
    mov x3, #4
    mov x4, #94
    mov x5, #4
    bl pi4_quake_fill_rect

    ldr x9, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    cmp x9, #2
    b.ne .Lpi4_quake_pak_world_done
    mov x0, x20
    mov x1, #138
    ldr x10, [x19, #PI4_QUAKE_STATE_PAK_SEED]
    add x1, x1, x10, lsr #4
    mov x2, #72
    mov x3, #42
    mov x4, #60
    mov x5, #4
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #150
    ldr x10, [x19, #PI4_QUAKE_STATE_PAK_ENTRIES]
    and x10, x10, #0xf
    add x1, x1, x10
    mov x2, #82
    mov x3, #18
    mov x4, #40
    mov x5, #9
    bl pi4_quake_fill_rect
.Lpi4_quake_pak_world_done:

    mov x0, x20
    ldr x1, [x19, #PI4_QUAKE_STATE_TARGET_X]
    sub x1, x1, #14
    ldr x2, [x19, #PI4_QUAKE_STATE_TARGET_Y]
    sub x2, x2, #16
    mov x3, #28
    mov x4, #32
    mov x5, #6
    ldr x9, [x19, #PI4_QUAKE_STATE_HIT_TICKS]
    cbz x9, .Lpi4_quake_target_color_ready
    mov x5, #8
.Lpi4_quake_target_color_ready:
    bl pi4_quake_fill_rect

    mov x0, x20
    ldr x1, [x19, #PI4_QUAKE_STATE_TARGET_X]
    sub x1, x1, #9
    ldr x2, [x19, #PI4_QUAKE_STATE_TARGET_Y]
    sub x2, x2, #7
    mov x3, #18
    mov x4, #4
    mov x5, #11
    bl pi4_quake_fill_rect

    mov x0, x20
    and x1, x22, #0x3f
    add x1, x1, #128
    mov x2, #170
    ldr x9, [x19, #PI4_QUAKE_STATE_JUMP_TICKS]
    cbz x9, .Lpi4_quake_weapon_y_ready
    sub x2, x2, #10
.Lpi4_quake_weapon_y_ready:
    mov x3, #48
    mov x4, #24
    mov x5, #7
    ldr x28, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
    cbz x28, .Lpi4_quake_weapon_color_ready
    mov x5, #8
.Lpi4_quake_weapon_color_ready:
    bl pi4_quake_fill_rect

    ldr x28, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
    cbz x28, .Lpi4_quake_muzzle_done
    mov x0, x20
    mov x1, #150
    mov x2, #148
    mov x3, #22
    mov x4, #18
    mov x5, #8
    bl pi4_quake_fill_rect

    mov x0, x20
    sub x1, x24, #4
    sub x2, x25, #4
    mov x3, #9
    mov x4, #9
    mov x5, #8
    bl pi4_quake_fill_rect
.Lpi4_quake_muzzle_done:

    mov x0, x20
    sub x1, x22, #5
    sub x2, x23, #8
    mov x3, #10
    mov x4, #16
    mov x5, #11
    bl pi4_quake_fill_rect

    mov x0, x20
    sub x1, x22, #9
    add x2, x23, #3
    mov x3, #18
    mov x4, #3
    mov x5, #7
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #8
    mov x2, #184
    lsr x3, x22, #2
    mov x4, #4
    mov x5, #9
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #8
    mov x2, #190
    lsr x3, x23, #2
    mov x4, #4
    mov x5, #10
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #248
    mov x2, #184
    and x3, x27, #0x3f
    add x3, x3, #8
    mov x4, #10
    mov x5, #11
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #12
    mov x2, #8
    adrp x3, pi4_quake_text_title
    add x3, x3, :lo12:pi4_quake_text_title
    mov x4, #11
    mov x5, #2
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #12
    mov x2, #27
    ldr x9, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    cmp x9, #2
    b.eq .Lpi4_quake_draw_mode_pak
    adrp x3, pi4_quake_text_fallback
    add x3, x3, :lo12:pi4_quake_text_fallback
    b .Lpi4_quake_draw_mode_ready
.Lpi4_quake_draw_mode_pak:
    adrp x3, pi4_quake_text_pak_play
    add x3, x3, :lo12:pi4_quake_text_pak_play
.Lpi4_quake_draw_mode_ready:
    mov x4, #8
    mov x5, #1
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #214
    mov x2, #172
    adrp x3, pi4_quake_text_score
    add x3, x3, :lo12:pi4_quake_text_score
    mov x4, #11
    mov x5, #1
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #90
    mov x2, #184
    adrp x3, pi4_quake_text_controls
    add x3, x3, :lo12:pi4_quake_text_controls
    mov x4, #11
    mov x5, #1
    bl pi4_quake_draw_text

    ldr x9, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    cmp x9, #2
    b.eq .Lpi4_quake_draw_pak_ok
    cmp x9, #1
    b.eq .Lpi4_quake_draw_pak_file
    adrp x3, pi4_quake_text_pak_missing
    add x3, x3, :lo12:pi4_quake_text_pak_missing
    mov x5, #10
    b .Lpi4_quake_draw_pak_status
.Lpi4_quake_draw_pak_file:
    adrp x3, pi4_quake_text_pak_file
    add x3, x3, :lo12:pi4_quake_text_pak_file
    mov x5, #8
    b .Lpi4_quake_draw_pak_status
.Lpi4_quake_draw_pak_ok:
    adrp x3, pi4_quake_text_pak_ok
    add x3, x3, :lo12:pi4_quake_text_pak_ok
    mov x5, #11
.Lpi4_quake_draw_pak_status:
    mov x0, x20
    mov x1, #12
    mov x2, #42
    mov x4, x5
    mov x5, #1
    bl pi4_quake_draw_text

    ldr x9, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    cmp x9, #2
    b.ne .Lpi4_quake_draw_pak_bar_done
    mov x0, x20
    mov x1, #12
    mov x2, #51
    ldr x3, [x19, #PI4_QUAKE_STATE_PAK_ENTRIES]
    and x3, x3, #0x3f
    add x3, x3, #12
    mov x4, #4
    mov x5, #9
    bl pi4_quake_fill_rect

    mov x0, x20
    ldr x9, [x19, #PI4_QUAKE_STATE_PAK_SEED]
    and x9, x9, #0x3f
    add x1, x9, #226
    mov x2, #51
    mov x3, #6
    mov x4, #4
    mov x5, #8
    bl pi4_quake_fill_rect
.Lpi4_quake_draw_pak_bar_done:

    mov x0, x20
    ldr x1, [x19, #PI4_QUAKE_STATE_KEY_MASK]
    ldr x2, [x19, #PI4_QUAKE_STATE_MOUSE_BUTTONS]
    ldr x3, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
    bl pi4_quake_draw_input_pad

    cmp x21, #96
    b.hs .Lpi4_quake_splash_done
    mov x0, x20
    mov x1, #28
    mov x2, #46
    mov x3, #264
    mov x4, #96
    mov x5, #0
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #70
    mov x2, #58
    adrp x3, pi4_quake_text_title
    add x3, x3, :lo12:pi4_quake_text_title
    mov x4, #11
    mov x5, #3
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #109
    mov x2, #92
    ldr x9, [x19, #PI4_QUAKE_STATE_PAK_STATUS]
    cmp x9, #2
    b.eq .Lpi4_quake_splash_pak_text
    adrp x3, pi4_quake_text_assembly_fallback
    add x3, x3, :lo12:pi4_quake_text_assembly_fallback
    b .Lpi4_quake_splash_text_ready
.Lpi4_quake_splash_pak_text:
    adrp x3, pi4_quake_text_pak_start
    add x3, x3, :lo12:pi4_quake_text_pak_start
.Lpi4_quake_splash_text_ready:
    mov x4, #8
    mov x5, #1
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #88
    mov x2, #108
    adrp x3, pi4_quake_text_control_hint
    add x3, x3, :lo12:pi4_quake_text_control_hint
    mov x4, #11
    mov x5, #1
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #121
    mov x2, #124
    adrp x3, pi4_quake_text_no_crash
    add x3, x3, :lo12:pi4_quake_text_no_crash
    mov x4, #6
    mov x5, #1
    bl pi4_quake_draw_text
.Lpi4_quake_splash_done:

    mov x0, x20
    mov x1, x24
    mov x2, x25
    ldr x3, [x19, #PI4_QUAKE_STATE_MUZZLE_TICKS]
    bl pi4_quake_draw_crosshair

    ldr x9, [x19, #PI4_QUAKE_STATE_MENU_OPEN]
    cbz x9, .Lpi4_quake_menu_done
    mov x0, x20
    mov x1, #54
    mov x2, #50
    mov x3, #212
    mov x4, #88
    mov x5, #0
    bl pi4_quake_fill_rect

    mov x0, x20
    mov x1, #124
    mov x2, #62
    adrp x3, pi4_quake_text_menu
    add x3, x3, :lo12:pi4_quake_text_menu
    mov x4, #11
    mov x5, #2
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #86
    mov x2, #96
    adrp x3, pi4_quake_text_menu_resume
    add x3, x3, :lo12:pi4_quake_text_menu_resume
    mov x4, #8
    mov x5, #1
    bl pi4_quake_draw_text

    mov x0, x20
    mov x1, #86
    mov x2, #112
    adrp x3, pi4_quake_text_menu_jump
    add x3, x3, :lo12:pi4_quake_text_menu_jump
    mov x4, #11
    mov x5, #1
    bl pi4_quake_draw_text
.Lpi4_quake_menu_done:

    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_quake_render_frame, . - pi4_quake_render_frame

.type pi4_quake_draw_world_motion, %function
pi4_quake_draw_world_motion:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    mov x23, #160
    sub x23, x21, x23
    asr x23, x23, #3

    mov x0, x19
    mov x1, #78
    sub x1, x1, x23
    mov x2, #56
    mov x3, #7
    mov x4, #76
    mov x5, #2
    bl pi4_quake_fill_rect

    mov x0, x19
    mov x1, #235
    sub x1, x1, x23
    mov x2, #56
    mov x3, #7
    mov x4, #76
    mov x5, #2
    bl pi4_quake_fill_rect

    add x24, x22, x20, lsl #1
    and x24, x24, #0x3f
    mov x25, #0
.Lpi4_quake_world_floor_next:
    mov x0, x19
    mov x1, #0
    mov x2, #132
    add x2, x2, x24
    mov x3, #PI4_QUAKE_FRAME_WIDTH
    mov x4, #2
    mov x5, #4
    tst x25, #1
    b.eq .Lpi4_quake_world_floor_color_ready
    mov x5, #7
.Lpi4_quake_world_floor_color_ready:
    bl pi4_quake_fill_rect
    add x24, x24, #13
    and x24, x24, #0x3f
    add x25, x25, #1
    cmp x25, #5
    b.lt .Lpi4_quake_world_floor_next

    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_quake_draw_world_motion, . - pi4_quake_draw_world_motion

.type pi4_quake_draw_crosshair, %function
pi4_quake_draw_crosshair:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, #12
    mov x23, #12
    cbz x3, .Lpi4_quake_crosshair_size_ready
    mov x22, #18
    mov x23, #8
.Lpi4_quake_crosshair_size_ready:
    mov x0, x19
    sub x1, x20, x22
    mov x2, x21
    add x3, x22, x22
    add x3, x3, #1
    mov x4, #1
    mov x5, x23
    bl pi4_quake_fill_rect

    mov x0, x19
    mov x1, x20
    sub x2, x21, #10
    mov x3, #1
    mov x4, #21
    mov x5, x23
    bl pi4_quake_fill_rect

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_quake_draw_crosshair, . - pi4_quake_draw_crosshair

.type pi4_quake_draw_input_pad, %function
pi4_quake_draw_input_pad:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    mov x23, #4
    tst x20, #PI4_QUAKE_KEY_FORWARD
    b.eq .Lpi4_quake_pad_w_color_ready
    mov x23, #12
.Lpi4_quake_pad_w_color_ready:
    mov x0, x19
    mov x1, #196
    mov x2, #178
    mov x3, #7
    mov x4, #7
    mov x5, x23
    bl pi4_quake_fill_rect

    mov x23, #4
    tst x20, #PI4_QUAKE_KEY_LEFT
    b.eq .Lpi4_quake_pad_a_color_ready
    mov x23, #12
.Lpi4_quake_pad_a_color_ready:
    mov x0, x19
    mov x1, #188
    mov x2, #186
    mov x3, #7
    mov x4, #7
    mov x5, x23
    bl pi4_quake_fill_rect

    mov x23, #4
    tst x20, #PI4_QUAKE_KEY_BACK
    b.eq .Lpi4_quake_pad_s_color_ready
    mov x23, #12
.Lpi4_quake_pad_s_color_ready:
    mov x0, x19
    mov x1, #196
    mov x2, #186
    mov x3, #7
    mov x4, #7
    mov x5, x23
    bl pi4_quake_fill_rect

    mov x23, #4
    tst x20, #PI4_QUAKE_KEY_RIGHT
    b.eq .Lpi4_quake_pad_d_color_ready
    mov x23, #12
.Lpi4_quake_pad_d_color_ready:
    mov x0, x19
    mov x1, #204
    mov x2, #186
    mov x3, #7
    mov x4, #7
    mov x5, x23
    bl pi4_quake_fill_rect

    mov x23, #4
    tst x21, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.eq .Lpi4_quake_pad_mouse_color_ready
    mov x23, #12
.Lpi4_quake_pad_mouse_color_ready:
    mov x0, x19
    mov x1, #220
    mov x2, #186
    mov x3, #7
    mov x4, #7
    mov x5, x23
    bl pi4_quake_fill_rect

    mov x23, #4
    tst x20, #PI4_QUAKE_KEY_JUMP
    b.eq .Lpi4_quake_pad_jump_color_ready
    mov x23, #8
.Lpi4_quake_pad_jump_color_ready:
    mov x0, x19
    mov x1, #232
    mov x2, #178
    mov x3, #7
    mov x4, #7
    mov x5, x23
    bl pi4_quake_fill_rect

    mov x23, #4
    cbz x22, .Lpi4_quake_pad_fire_color_ready
    mov x23, #8
.Lpi4_quake_pad_fire_color_ready:
    mov x0, x19
    mov x1, #232
    mov x2, #186
    mov x3, #7
    mov x4, #7
    mov x5, x23
    bl pi4_quake_fill_rect

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_quake_draw_input_pad, . - pi4_quake_draw_input_pad

.type pi4_quake_draw_text, %function
pi4_quake_draw_text:
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
    cbnz x24, .Lpi4_quake_text_next_char
    mov x24, #1

.Lpi4_quake_text_next_char:
    ldrb w25, [x22], #1
    cbz x25, .Lpi4_quake_text_done
    cmp x25, #32
    b.ne .Lpi4_quake_text_lookup
    mov x9, #6
    madd x20, x9, x24, x20
    b .Lpi4_quake_text_next_char

.Lpi4_quake_text_lookup:
    sub x9, x25, #65
    cmp x9, #25
    b.hi .Lpi4_quake_text_digit_lookup
    adrp x26, pi4_quake_font_upper
    add x26, x26, :lo12:pi4_quake_font_upper
    mov x10, #7
    madd x26, x9, x10, x26
    b .Lpi4_quake_text_glyph_ready

.Lpi4_quake_text_digit_lookup:
    sub x9, x25, #48
    cmp x9, #9
    b.hi .Lpi4_quake_text_dash_lookup
    adrp x26, pi4_quake_font_digits
    add x26, x26, :lo12:pi4_quake_font_digits
    mov x10, #7
    madd x26, x9, x10, x26
    b .Lpi4_quake_text_glyph_ready

.Lpi4_quake_text_dash_lookup:
    cmp x25, #45
    b.ne .Lpi4_quake_text_advance_unknown
    adrp x26, pi4_quake_font_dash
    add x26, x26, :lo12:pi4_quake_font_dash
    b .Lpi4_quake_text_glyph_ready

.Lpi4_quake_text_advance_unknown:
    mov x9, #6
    madd x20, x9, x24, x20
    b .Lpi4_quake_text_next_char

.Lpi4_quake_text_glyph_ready:
    mov x27, #0
.Lpi4_quake_text_row_loop:
    ldrb w28, [x26, x27]
    mov x10, #0
.Lpi4_quake_text_col_loop:
    mov x11, #4
    sub x11, x11, x10
    mov x12, #1
    lsl x12, x12, x11
    tst x28, x12
    b.eq .Lpi4_quake_text_skip_pixel
    mul x1, x10, x24
    add x1, x1, x20
    mul x2, x27, x24
    add x2, x2, x21
    mov x0, x19
    mov x3, x24
    mov x4, x24
    mov x5, x23
    bl pi4_quake_fill_rect
.Lpi4_quake_text_skip_pixel:
    add x10, x10, #1
    cmp x10, #5
    b.lt .Lpi4_quake_text_col_loop
    add x27, x27, #1
    cmp x27, #7
    b.lt .Lpi4_quake_text_row_loop
    mov x9, #6
    madd x20, x9, x24, x20
    b .Lpi4_quake_text_next_char

.Lpi4_quake_text_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_quake_draw_text, . - pi4_quake_draw_text

.type pi4_quake_fill_rect, %function
pi4_quake_fill_rect:
    cbz x3, .Lpi4_quake_rect_done
    cbz x4, .Lpi4_quake_rect_done
    mov x6, #PI4_QUAKE_FRAME_WIDTH
    mul x7, x2, x6
    add x7, x7, x1
    add x0, x0, x7
    sub x8, x6, x3
.Lpi4_quake_rect_row:
    mov x9, x3
.Lpi4_quake_rect_col:
    strb w5, [x0], #1
    subs x9, x9, #1
    b.ne .Lpi4_quake_rect_col
    add x0, x0, x8
    subs x4, x4, #1
    b.ne .Lpi4_quake_rect_row
.Lpi4_quake_rect_done:
    ret
.size pi4_quake_fill_rect, . - pi4_quake_fill_rect

.section .rodata.pi4_quake_app_manifest, "a", %progbits
.balign 8
.global pi4_quake_app_manifest
pi4_quake_app_manifest:
    .asciz "schema=vibe-os-pi4-quake-app-v1"
    .asciz "app_exec=/APPS/QUAKE/APP.ELF"
    .asciz "app_kind=quake"
    .asciz "app_arch=AARCH64"
    .asciz "app_launch_claim=pak-backed-play-loop-not-engine-proof"
    .asciz "app_runtime_status=assembly-native-pak-backed-playable-loop"
    .asciz "app_frame_progression=pak-seeded-input-player-look-indexed-present-loop"
    .asciz "app_input_state=keyboard-usb-mouse-uart-move-look-fire-jump-menu"
    .asciz "app_scene_motion=player-position-drives-world-parallax"
    .asciz "quake_original_source=not-linked-yet"
    .asciz "quake_engine_claim=not-original-engine-fallback-only"
    .asciz "quake_assets_claim=opens-reads-header-seeds-scene-from-/ID1/PAK0.PAK"
    .asciz "vibe-os pi4 /APPS/QUAKE/APP.ELF Quake AArch64 app"

.section .rodata.pi4_quake_text, "a", %progbits
.balign 8
pi4_quake_text_title:
    .asciz "VIBE QUAKE"
pi4_quake_text_fallback:
    .asciz "FALLBACK PLAY"
pi4_quake_text_pak_play:
    .asciz "PAK PLAY"
pi4_quake_text_score:
    .asciz "SCORE"
pi4_quake_text_controls:
    .asciz "WASD MOVE ARROWS LOOK"
pi4_quake_text_assembly_fallback:
    .asciz "ASSEMBLY FALLBACK"
pi4_quake_text_pak_start:
    .asciz "PAK START"
pi4_quake_text_control_hint:
    .asciz "WASD MOVE ARROWS LOOK"
pi4_quake_text_no_crash:
    .asciz "NOT ENGINE"
pi4_quake_text_pak_ok:
    .asciz "PAK OK"
pi4_quake_text_pak_file:
    .asciz "PAK FILE"
pi4_quake_text_pak_missing:
    .asciz "PAK MISSING"
pi4_quake_text_menu:
    .asciz "MENU"
pi4_quake_text_menu_resume:
    .asciz "ESC RESUME"
pi4_quake_text_menu_jump:
    .asciz "FIRE RESUME"
pi4_quake_pak_path:
    .asciz "/ID1/PAK0.PAK"

.balign 8
pi4_quake_font_upper:
    .byte 0x0e, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11
    .byte 0x1e, 0x11, 0x11, 0x1e, 0x11, 0x11, 0x1e
    .byte 0x0e, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0e
    .byte 0x1e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1e
    .byte 0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x1f
    .byte 0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x10
    .byte 0x0e, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0f
    .byte 0x11, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11
    .byte 0x0e, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0e
    .byte 0x07, 0x02, 0x02, 0x02, 0x12, 0x12, 0x0c
    .byte 0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11
    .byte 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1f
    .byte 0x11, 0x1b, 0x15, 0x15, 0x11, 0x11, 0x11
    .byte 0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11
    .byte 0x0e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e
    .byte 0x1e, 0x11, 0x11, 0x1e, 0x10, 0x10, 0x10
    .byte 0x0e, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0d
    .byte 0x1e, 0x11, 0x11, 0x1e, 0x14, 0x12, 0x11
    .byte 0x0f, 0x10, 0x10, 0x0e, 0x01, 0x01, 0x1e
    .byte 0x1f, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    .byte 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e
    .byte 0x11, 0x11, 0x11, 0x11, 0x11, 0x0a, 0x04
    .byte 0x11, 0x11, 0x11, 0x15, 0x15, 0x15, 0x0a
    .byte 0x11, 0x11, 0x0a, 0x04, 0x0a, 0x11, 0x11
    .byte 0x11, 0x11, 0x0a, 0x04, 0x04, 0x04, 0x04
    .byte 0x1f, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1f

pi4_quake_font_digits:
    .byte 0x0e, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0e
    .byte 0x04, 0x0c, 0x04, 0x04, 0x04, 0x04, 0x0e
    .byte 0x0e, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1f
    .byte 0x1e, 0x01, 0x01, 0x0e, 0x01, 0x01, 0x1e
    .byte 0x02, 0x06, 0x0a, 0x12, 0x1f, 0x02, 0x02
    .byte 0x1f, 0x10, 0x10, 0x1e, 0x01, 0x01, 0x1e
    .byte 0x0e, 0x10, 0x10, 0x1e, 0x11, 0x11, 0x0e
    .byte 0x1f, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08
    .byte 0x0e, 0x11, 0x11, 0x0e, 0x11, 0x11, 0x0e
    .byte 0x0e, 0x11, 0x11, 0x0f, 0x01, 0x01, 0x0e

pi4_quake_font_dash:
    .byte 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00

.section .rodata.pi4_quake_palette, "a", %progbits
.balign 8
pi4_quake_palette:
    .byte 0x00, 0x00, 0x00
    .byte 0x24, 0x18, 0x10
    .byte 0x50, 0x28, 0x18
    .byte 0x84, 0x3c, 0x20
    .byte 0xa8, 0x64, 0x28
    .byte 0x38, 0x68, 0x58
    .byte 0x68, 0x90, 0x78
    .byte 0xd0, 0xbc, 0x84
    .byte 0xf4, 0xd8, 0x70
    .byte 0x30, 0x88, 0xc0
    .byte 0xa0, 0x30, 0x28
    .byte 0xe8, 0xe0, 0xc0
    .rept 244
    .byte 0x18, 0x18, 0x1c
    .endr

.section .data.pi4_quake_app, "aw", %progbits
.balign 8
pi4_quake_present:
    .quad pi4_quake_frame
    .quad pi4_quake_palette
    .quad PI4_QUAKE_FRAME_WIDTH
    .quad PI4_QUAKE_FRAME_HEIGHT

.balign 8
.global pi4_quake_app_state
pi4_quake_app_state:
    .skip PI4_QUAKE_STATE_BYTES, 0

.section .bss.pi4_quake_app, "aw", %nobits
.balign 16
pi4_quake_frame:
    .skip PI4_QUAKE_FRAME_BYTES
.balign 16
pi4_quake_input_event:
    .skip PI4_VIBE_INPUT_EVENT_BYTES
.balign 16
pi4_quake_pak_header:
    .skip 12

.section .note.GNU-stack, "", %progbits
