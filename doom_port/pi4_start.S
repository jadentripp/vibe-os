#include "pi4_runtime.h"

// AArch64 Doom app entry for the Pi lane.
//
// This stays honest about not being the original Doom engine, but it is no
// longer a two-frame scaffold: it runs a live indexed-frame loop and moves the
// rendered view from the same input ABI the launcher and engine bridge use.

.arch armv8-a

.extern vibe_user_start_status
.extern vibe_user_file_probe_assets
.extern vibe_user_input_status
.extern vibe_user_present_indexed
.extern vibe_user_poll_input
.extern vibe_user_audio_device_info
.extern vibe_user_audio_pcm_ring_info
.extern vibe_user_audio_device_start
.extern vibe_user_audio_pcm_open
.extern vibe_user_audio_pcm_write

.equ PI4_DOOM_FRAME_WIDTH,           320
.equ PI4_DOOM_FRAME_HEIGHT,          200
.equ PI4_DOOM_FRAME_BYTES,           64000
.equ PI4_DOOM_AUDIO_PACKET_BYTES,     960
.equ PI4_DOOM_CENTER_X,              160
.equ PI4_DOOM_HORIZON_Y,             88
.equ PI4_DOOM_FLOOR_Y,               112
.equ PI4_DOOM_INPUT_POLL_BUDGET,     8

.equ PI4_DOOM_STATUS_ARGC,            8
.equ PI4_DOOM_STATUS_ARGV,            16
.equ PI4_DOOM_STATUS_ENVP,            24
.equ PI4_DOOM_STATUS_START_FLAGS,     32
.equ PI4_DOOM_STATUS_GETPID,          40
.equ PI4_DOOM_STATUS_FB_INFO,         48
.equ PI4_DOOM_STATUS_PRESENT0,        56
.equ PI4_DOOM_STATUS_INPUT_STATUS,    64
.equ PI4_DOOM_STATUS_POLL_INPUT,      72
.equ PI4_DOOM_STATUS_FRAME_INDEX,     80
.equ PI4_DOOM_STATUS_INPUT_CODE,      88
.equ PI4_DOOM_STATUS_INPUT_SEEN,      96
.equ PI4_DOOM_STATUS_PRESENT1,        104
.equ PI4_DOOM_STATUS_PRESENT_COUNT,   112
.equ PI4_DOOM_STATUS_INPUT_STATUS1,   120
.equ PI4_DOOM_STATUS_PROGRESS,        128
.equ PI4_DOOM_STATUS_PLAYER_X,        136
.equ PI4_DOOM_STATUS_PLAYER_Y,        144
.equ PI4_DOOM_STATUS_PLAYER_ANGLE,    152
.equ PI4_DOOM_STATUS_ACTION_COUNT,    160
.equ PI4_DOOM_STATUS_LAST_EVENT_TYPE, 168
.equ PI4_DOOM_STATUS_FIRE_TICS,       176
.equ PI4_DOOM_STATUS_BYTES,           184

.section .text.pi4_doom.entry, "ax", %progbits
.balign 16
.global user_main
.global pi4_doom_app_start
.type user_main, %function
.type pi4_doom_app_start, %function
user_main:
pi4_doom_app_start:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    adrp x19, pi4_doom_app_status
    add x19, x19, :lo12:pi4_doom_app_status
    str x0, [x19, #PI4_DOOM_STATUS_ARGC]
    str x1, [x19, #PI4_DOOM_STATUS_ARGV]
    str x2, [x19, #PI4_DOOM_STATUS_ENVP]

    adrp x9, vibe_user_start_status
    add x9, x9, :lo12:vibe_user_start_status
    ldr x9, [x9]
    str x9, [x19, #PI4_DOOM_STATUS_START_FLAGS]

    bl vibe_user_file_probe_assets
    bl pi4_doom_audio_start

    mov x20, xzr
    mov x21, xzr
    mov x22, xzr
    mov x23, xzr
    mov x24, #40
    mov x25, xzr
    mov x26, xzr
    mov x27, xzr
    mov x28, xzr

.Lpi4_doom_frame_loop:
    bl pi4_doom_poll_controls

    add x20, x20, #1
    cbz x26, .Lpi4_doom_fire_ready
    sub x26, x26, #1
.Lpi4_doom_fire_ready:
    str x20, [x19, #PI4_DOOM_STATUS_FRAME_INDEX]
    str x23, [x19, #PI4_DOOM_STATUS_PLAYER_X]
    str x24, [x19, #PI4_DOOM_STATUS_PLAYER_Y]
    str x25, [x19, #PI4_DOOM_STATUS_PLAYER_ANGLE]
    str x27, [x19, #PI4_DOOM_STATUS_ACTION_COUNT]
    str x26, [x19, #PI4_DOOM_STATUS_FIRE_TICS]
    str x28, [x19, #PI4_DOOM_STATUS_INPUT_CODE]
    str x22, [x19, #PI4_DOOM_STATUS_INPUT_SEEN]

    mov x0, x20
    mov x1, x23
    mov x2, x24
    mov x3, x25
    mov x4, x26
    mov x5, x27
    bl pi4_doom_render_frame
    bl pi4_doom_audio_tick

    adrp x0, pi4_doom_present
    add x0, x0, :lo12:pi4_doom_present
    bl vibe_user_present_indexed
    str x0, [x19, #PI4_DOOM_STATUS_PRESENT1]
    str x20, [x19, #PI4_DOOM_STATUS_PRESENT_COUNT]
    orr x9, x28, x20, lsl #32
    str x9, [x19, #PI4_DOOM_STATUS_PROGRESS]

    bl pi4_doom_delay
    b .Lpi4_doom_frame_loop
.size user_main, . - user_main
.size pi4_doom_app_start, . - pi4_doom_app_start

.type pi4_doom_poll_controls, %function
pi4_doom_poll_controls:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    str x21, [sp, #16]
    mov x21, #PI4_DOOM_INPUT_POLL_BUDGET

    adrp x0, pi4_doom_input_status
    add x0, x0, :lo12:pi4_doom_input_status
    bl vibe_user_input_status
    str x0, [x19, #PI4_DOOM_STATUS_INPUT_STATUS]
    cmp x0, #0
    b.lt .Lpi4_doom_poll_next
    bl pi4_doom_apply_input_snapshot

.Lpi4_doom_poll_next:
    cbz x21, .Lpi4_doom_poll_done
    sub x21, x21, #1
    adrp x0, pi4_doom_input_event
    add x0, x0, :lo12:pi4_doom_input_event
    bl vibe_user_poll_input
    str x0, [x19, #PI4_DOOM_STATUS_POLL_INPUT]
    cmp x0, #1
    b.ne .Lpi4_doom_poll_done

    adrp x9, pi4_doom_input_event
    add x9, x9, :lo12:pi4_doom_input_event
    ldr x11, [x9, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ldr x12, [x9, #PI4_VIBE_INPUT_EVENT_TYPE_OFFSET]
    ldr x13, [x9, #PI4_VIBE_INPUT_EVENT_CODE_OFFSET]
    ldr x14, [x9, #PI4_VIBE_INPUT_EVENT_VALUE0_OFFSET]
    ldr x15, [x9, #PI4_VIBE_INPUT_EVENT_VALUE1_OFFSET]
    str x12, [x19, #PI4_DOOM_STATUS_LAST_EVENT_TYPE]

    cmp x12, #PI4_VIBE_INPUT_EVENT_UART
    b.eq .Lpi4_doom_poll_uart
    cmp x12, #PI4_VIBE_INPUT_EVENT_KEY
    b.eq .Lpi4_doom_poll_key
    cmp x12, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    b.eq .Lpi4_doom_poll_mouse
    b .Lpi4_doom_poll_next

.Lpi4_doom_poll_uart:
    cmp x11, #PI4_VIBE_INPUT_DEVICE_UART
    b.ne .Lpi4_doom_poll_next
    cmp x13, #PI4_VIBE_UART_EVENT_SELECT_1
    b.eq .Lpi4_doom_action_left
    cmp x13, #PI4_VIBE_UART_EVENT_SELECT_2
    b.eq .Lpi4_doom_action_right
    cmp x13, #PI4_VIBE_UART_EVENT_UP
    b.eq .Lpi4_doom_action_forward
    cmp x13, #PI4_VIBE_UART_EVENT_DOWN
    b.eq .Lpi4_doom_action_back
    cmp x13, #PI4_VIBE_UART_EVENT_CONFIRM
    b.eq .Lpi4_doom_action_fire
    b .Lpi4_doom_poll_next

.Lpi4_doom_poll_key:
    cmp x14, #PI4_VIBE_INPUT_KEY_PRESSED
    b.ne .Lpi4_doom_poll_next
    and x16, x13, #PI4_VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK
    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_A
    b.eq .Lpi4_doom_action_left
    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT
    b.eq .Lpi4_doom_action_left
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_A
    b.eq .Lpi4_doom_action_left
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT
    b.eq .Lpi4_doom_action_left

    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_D
    b.eq .Lpi4_doom_action_right
    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT
    b.eq .Lpi4_doom_action_right
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_D
    b.eq .Lpi4_doom_action_right
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT
    b.eq .Lpi4_doom_action_right

    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_W
    b.eq .Lpi4_doom_action_forward
    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_UP
    b.eq .Lpi4_doom_action_forward
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_W
    b.eq .Lpi4_doom_action_forward
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_UP
    b.eq .Lpi4_doom_action_forward

    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_S
    b.eq .Lpi4_doom_action_back
    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_DOWN
    b.eq .Lpi4_doom_action_back
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_S
    b.eq .Lpi4_doom_action_back
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_DOWN
    b.eq .Lpi4_doom_action_back

    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_SPACE
    b.eq .Lpi4_doom_action_fire
    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_ENTER
    b.eq .Lpi4_doom_action_fire
    cmp x16, #PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_CTRL
    b.eq .Lpi4_doom_action_fire
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_SPACE
    b.eq .Lpi4_doom_action_fire
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ENTER
    b.eq .Lpi4_doom_action_fire
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_CTRL
    b.eq .Lpi4_doom_action_fire
    cmp x15, #PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_CTRL
    b.eq .Lpi4_doom_action_fire
    b .Lpi4_doom_poll_next

.Lpi4_doom_poll_mouse:
    orr x16, x13, x14
    orr x16, x16, x15
    cbz x16, .Lpi4_doom_poll_next
    asr x16, x14, #3
    add x23, x23, x16
    asr x16, x15, #4
    sub x24, x24, x16
    cbz x13, .Lpi4_doom_mouse_no_fire
    mov x26, #8
.Lpi4_doom_mouse_no_fire:
    add x28, x13, #0x100
    b .Lpi4_doom_action_finish

.Lpi4_doom_action_left:
    sub x23, x23, #8
    sub x25, x25, #3
    mov x28, x13
    b .Lpi4_doom_action_finish

.Lpi4_doom_action_right:
    add x23, x23, #8
    add x25, x25, #3
    mov x28, x13
    b .Lpi4_doom_action_finish

.Lpi4_doom_action_forward:
    add x24, x24, #6
    mov x28, x13
    b .Lpi4_doom_action_finish

.Lpi4_doom_action_back:
    sub x24, x24, #6
    mov x28, x13
    b .Lpi4_doom_action_finish

.Lpi4_doom_action_fire:
    mov x26, #8
    mov x28, x13

.Lpi4_doom_action_finish:
    mov x22, #1
    add x27, x27, #1
    bl pi4_doom_clamp_state
    b .Lpi4_doom_poll_next

.Lpi4_doom_poll_done:
    ldr x21, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_doom_poll_controls, . - pi4_doom_poll_controls

.type pi4_doom_apply_input_snapshot, %function
pi4_doom_apply_input_snapshot:
    adrp x9, pi4_doom_input_status
    add x9, x9, :lo12:pi4_doom_input_status
    ldr x10, [x9, #PI4_VIBE_INPUT_STATUS_KEYBOARD_STATUS_OFFSET]
    cmp x10, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    b.ne .Lpi4_doom_snapshot_done
    add x9, x9, #PI4_VIBE_INPUT_STATUS_KEYBOARD_STATE_OFFSET
    ldr x10, [x9]
    ldr x11, [x9, #8]
    mov x17, xzr

    mov x12, #1
    lsl x12, x12, #30
    tst x10, x12
    b.ne .Lpi4_doom_snapshot_left
    mov x12, #1
    lsl x12, x12, #11
    tst x11, x12
    b.eq .Lpi4_doom_snapshot_right_check
.Lpi4_doom_snapshot_left:
    sub x23, x23, #4
    sub x25, x25, #2
    orr x17, x17, #0x04

.Lpi4_doom_snapshot_right_check:
    mov x12, #1
    lsl x12, x12, #32
    tst x10, x12
    b.ne .Lpi4_doom_snapshot_right
    mov x12, #1
    lsl x12, x12, #13
    tst x11, x12
    b.eq .Lpi4_doom_snapshot_forward_check
.Lpi4_doom_snapshot_right:
    add x23, x23, #4
    add x25, x25, #2
    orr x17, x17, #0x08

.Lpi4_doom_snapshot_forward_check:
    mov x12, #1
    lsl x12, x12, #17
    tst x10, x12
    b.ne .Lpi4_doom_snapshot_forward
    mov x12, #1
    lsl x12, x12, #8
    tst x11, x12
    b.eq .Lpi4_doom_snapshot_back_check
.Lpi4_doom_snapshot_forward:
    add x24, x24, #3
    orr x17, x17, #0x01

.Lpi4_doom_snapshot_back_check:
    mov x12, #1
    lsl x12, x12, #31
    tst x10, x12
    b.ne .Lpi4_doom_snapshot_back
    mov x12, #1
    lsl x12, x12, #16
    tst x11, x12
    b.eq .Lpi4_doom_snapshot_fire_check
.Lpi4_doom_snapshot_back:
    sub x24, x24, #3
    orr x17, x17, #0x02

.Lpi4_doom_snapshot_fire_check:
    mov x12, #1
    lsl x12, x12, #29
    tst x10, x12
    b.ne .Lpi4_doom_snapshot_fire
    mov x12, #1
    lsl x12, x12, #57
    tst x10, x12
    b.eq .Lpi4_doom_snapshot_finish
.Lpi4_doom_snapshot_fire:
    mov x26, #8
    orr x17, x17, #0x10

.Lpi4_doom_snapshot_finish:
    cbz x17, .Lpi4_doom_snapshot_done
    mov x22, #1
    add x27, x27, #1
    add x28, x17, #0x200
    b pi4_doom_clamp_state

.Lpi4_doom_snapshot_done:
    ret
.size pi4_doom_apply_input_snapshot, . - pi4_doom_apply_input_snapshot

.type pi4_doom_clamp_state, %function
pi4_doom_clamp_state:
    mov x9, #56
    cmp x23, x9
    csel x23, x9, x23, gt
    neg x9, x9
    cmp x23, x9
    csel x23, x9, x23, lt

    mov x9, #255
    cmp x24, x9
    csel x24, x9, x24, gt
    cmp x24, #0
    csel x24, xzr, x24, lt

    mov x9, #48
    cmp x25, x9
    csel x25, x9, x25, gt
    neg x9, x9
    cmp x25, x9
    csel x25, x9, x25, lt
    ret
.size pi4_doom_clamp_state, . - pi4_doom_clamp_state

.type pi4_doom_render_frame, %function
pi4_doom_render_frame:
    adrp x6, pi4_doom_frame
    add x6, x6, :lo12:pi4_doom_frame
    mov x7, xzr

.Lpi4_doom_render_row:
    mov x8, xzr

.Lpi4_doom_render_col:
    cmp x7, #PI4_DOOM_HORIZON_Y
    b.lo .Lpi4_doom_render_sky
    cmp x7, #PI4_DOOM_FLOOR_Y
    b.lo .Lpi4_doom_render_wall

    add x9, x8, x2
    lsr x9, x9, #4
    lsr x10, x7, #3
    eor x9, x9, x10
    and x9, x9, #1
    mov w11, #2
    cbz x9, .Lpi4_doom_render_base_ready
    mov w11, #3
    b .Lpi4_doom_render_base_ready

.Lpi4_doom_render_sky:
    lsr x9, x7, #5
    add w11, w9, #9
    b .Lpi4_doom_render_base_ready

.Lpi4_doom_render_wall:
    add x9, x8, x3
    eor x9, x9, x0, lsr #1
    and x9, x9, #0x20
    mov w11, #4
    cbz x9, .Lpi4_doom_render_base_ready
    mov w11, #5

.Lpi4_doom_render_base_ready:
    add x9, x1, x3
    asr x9, x9, #2
    add x10, x9, #28
    cmp x8, x10
    b.lo .Lpi4_doom_render_side_wall
    mov x12, #PI4_DOOM_FRAME_WIDTH
    sub x12, x12, x10
    cmp x8, x12
    b.hs .Lpi4_doom_render_side_wall
    b .Lpi4_doom_render_actor_check

.Lpi4_doom_render_side_wall:
    mov w11, #6

.Lpi4_doom_render_actor_check:
    mov x12, #PI4_DOOM_CENTER_X
    asr x9, x1, #1
    add x12, x12, x9
    asr x9, x3, #1
    add x12, x12, x9
    and x9, x2, #63
    lsr x9, x9, #2
    add x13, x9, #16
    sub x14, x12, x13
    add x15, x12, x13
    cmp x8, x14
    b.lo .Lpi4_doom_render_weapon_check
    cmp x8, x15
    b.hs .Lpi4_doom_render_weapon_check
    mov x16, #92
    sub x14, x16, x9
    add x15, x16, x9
    add x15, x15, #34
    cmp x7, x14
    b.lo .Lpi4_doom_render_weapon_check
    cmp x7, x15
    b.hs .Lpi4_doom_render_weapon_check
    mov w11, #7
    cbz x4, .Lpi4_doom_render_weapon_check
    cmp x7, #100
    b.hi .Lpi4_doom_render_weapon_check
    mov w11, #11

.Lpi4_doom_render_weapon_check:
    mov x12, #PI4_DOOM_CENTER_X
    asr x9, x1, #1
    sub x12, x12, x9
    and x9, x0, #7
    add x13, x9, #150
    cmp x7, x13
    b.lo .Lpi4_doom_render_reticle_check
    sub x14, x12, #34
    add x15, x12, #34
    cmp x8, x14
    b.lo .Lpi4_doom_render_reticle_check
    cmp x8, x15
    b.hs .Lpi4_doom_render_reticle_check
    mov w11, #8
    cbz x4, .Lpi4_doom_render_reticle_check
    cmp x7, #170
    b.hs .Lpi4_doom_render_reticle_check
    mov w11, #11

.Lpi4_doom_render_reticle_check:
    mov x12, #PI4_DOOM_CENTER_X
    asr x9, x3, #1
    add x12, x12, x9
    sub x14, x12, #1
    add x15, x12, #2
    cmp x8, x14
    b.lo .Lpi4_doom_render_reticle_h
    cmp x8, x15
    b.hs .Lpi4_doom_render_reticle_h
    cmp x7, #94
    b.lo .Lpi4_doom_render_reticle_h
    cmp x7, #106
    b.hs .Lpi4_doom_render_reticle_h
    mov w11, #11
    b .Lpi4_doom_store_pixel

.Lpi4_doom_render_reticle_h:
    cmp x7, #99
    b.lo .Lpi4_doom_store_pixel
    cmp x7, #102
    b.hs .Lpi4_doom_store_pixel
    sub x14, x12, #9
    add x15, x12, #10
    cmp x8, x14
    b.lo .Lpi4_doom_store_pixel
    cmp x8, x15
    b.hs .Lpi4_doom_store_pixel
    mov w11, #11

.Lpi4_doom_store_pixel:
    strb w11, [x6], #1
    add x8, x8, #1
    cmp x8, #PI4_DOOM_FRAME_WIDTH
    b.lo .Lpi4_doom_render_col
    add x7, x7, #1
    cmp x7, #PI4_DOOM_FRAME_HEIGHT
    b.lo .Lpi4_doom_render_row
    ret
.size pi4_doom_render_frame, . - pi4_doom_render_frame

.type pi4_doom_delay, %function
pi4_doom_delay:
    mov x0, #0x10
    lsl x0, x0, #12
.Lpi4_doom_delay_next:
    subs x0, x0, #1
    b.ne .Lpi4_doom_delay_next
    ret
.size pi4_doom_delay, . - pi4_doom_delay

.type pi4_doom_audio_start, %function
pi4_doom_audio_start:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, pi4_doom_audio_device_info
    add x0, x0, :lo12:pi4_doom_audio_device_info
    bl vibe_user_audio_device_info
    adrp x0, pi4_doom_audio_ring_info
    add x0, x0, :lo12:pi4_doom_audio_ring_info
    bl vibe_user_audio_pcm_ring_info
    bl vibe_user_audio_device_start
    cmp x0, #0
    b.lt .Lpi4_doom_audio_start_done
    adrp x0, pi4_doom_audio_desc
    add x0, x0, :lo12:pi4_doom_audio_desc
    bl vibe_user_audio_pcm_open
    cmp x0, #0
    b.le .Lpi4_doom_audio_start_done
    adrp x1, pi4_doom_audio_handle
    add x1, x1, :lo12:pi4_doom_audio_handle
    str x0, [x1]
.Lpi4_doom_audio_start_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_doom_audio_start, . - pi4_doom_audio_start

.type pi4_doom_audio_tick, %function
pi4_doom_audio_tick:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    adrp x19, pi4_doom_audio_handle
    add x19, x19, :lo12:pi4_doom_audio_handle
    ldr x0, [x19]
    cbz x0, .Lpi4_doom_audio_tick_done
    adrp x19, pi4_doom_audio_phase
    add x19, x19, :lo12:pi4_doom_audio_phase
    ldr x20, [x19]
    adrp x21, pi4_doom_audio_packet
    add x21, x21, :lo12:pi4_doom_audio_packet
    mov x2, #PI4_DOOM_AUDIO_PACKET_BYTES
.Lpi4_doom_audio_fill_next:
    add x20, x20, #7
    and x3, x20, #0xff
    eor x3, x3, x20, lsr #3
    and x3, x3, #0x7f
    add x3, x3, #64
    strb w3, [x21], #1
    subs x2, x2, #1
    b.ne .Lpi4_doom_audio_fill_next
    str x20, [x19]
    adrp x1, pi4_doom_audio_packet
    add x1, x1, :lo12:pi4_doom_audio_packet
    adrp x2, pi4_doom_audio_desc
    add x2, x2, :lo12:pi4_doom_audio_desc
    str x1, [x2, #PI4_VIBE_AUDIO_DESC_SAMPLES_OFFSET]
    mov x3, #PI4_DOOM_AUDIO_PACKET_BYTES
    str x3, [x2, #PI4_VIBE_AUDIO_DESC_LENGTH_OFFSET]
    adrp x0, pi4_doom_audio_handle
    add x0, x0, :lo12:pi4_doom_audio_handle
    ldr x0, [x0]
    mov x1, x2
    bl vibe_user_audio_pcm_write
.Lpi4_doom_audio_tick_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_doom_audio_tick, . - pi4_doom_audio_tick

.section .rodata.pi4_doom_manifest, "a", %progbits
.balign 8
.global pi4_doom_app_manifest
pi4_doom_app_manifest:
    .asciz "schema=vibe-os-pi4-doom-app-v3"
    .asciz "app_exec=/APPS/DOOM/APP.ELF"
    .asciz "app_kind=doom"
    .asciz "app_arch=AARCH64"
    .asciz "app_launch_claim=none"
    .asciz "vibe-os pi4 /APPS/DOOM/APP.ELF Doom AArch64 runtime glue"
    .asciz "doom_source=third_party/doom/linuxdoom-1.10"
    .asciz "doom_engine_link=not-linked-yet"
    .asciz "doom_wad_access=not-read-by-app-yet"
    .asciz "app_runtime_claim=assembly-live-frame-loop-snapshot-and-event-input"
    .asciz "audio_runtime_claim=usb-audio-u8-stereo-pcm-stream"
    .asciz "original_engine_claim=none"
    .asciz "status_schema=pi4-doom-app-state-v3"

.section .rodata.pi4_doom_palette, "a", %progbits
.balign 8
pi4_doom_palette:
    .byte 0, 0, 0
    .byte 30, 32, 52
    .byte 52, 42, 34
    .byte 92, 72, 48
    .byte 94, 84, 72
    .byte 150, 112, 72
    .byte 38, 38, 44
    .byte 152, 24, 20
    .byte 82, 82, 96
    .byte 26, 52, 82
    .byte 38, 78, 118
    .byte 255, 214, 90
    .rept 244
    .byte 0, 0, 0
    .endr

.section .data.pi4_doom_present, "aw", %progbits
.balign 8
pi4_doom_present:
    .quad pi4_doom_frame
    .quad pi4_doom_palette
    .quad PI4_DOOM_FRAME_WIDTH
    .quad PI4_DOOM_FRAME_HEIGHT

.balign 8
pi4_doom_audio_desc:
    .quad pi4_doom_audio_packet
    .quad PI4_DOOM_AUDIO_PACKET_BYTES
    .quad PI4_VIBE_AUDIO_SAMPLE_RATE
    .quad PI4_VIBE_AUDIO_CHANNELS
    .quad PI4_VIBE_AUDIO_FORMAT_U8_STEREO
    .quad 0
    .quad 0
    .quad 0

.balign 8
pi4_doom_audio_handle:
    .quad 0

.balign 8
pi4_doom_audio_phase:
    .quad 0

.section .data.pi4_doom_app_status, "aw", %progbits
.balign 8
.global pi4_doom_app_status
pi4_doom_app_status:
    .quad 0x314d4f4f444950
    .skip PI4_DOOM_STATUS_BYTES - 8, 0

.section .bss.pi4_doom, "aw", %nobits
.balign 8
pi4_doom_fb_info:
    .skip PI4_VIBE_FB_INFO_BYTES
.balign 8
pi4_doom_input_status:
    .skip PI4_VIBE_INPUT_STATUS_BYTES
.balign 8
pi4_doom_input_event:
    .skip PI4_VIBE_INPUT_EVENT_BYTES
.balign 8
pi4_doom_audio_device_info:
    .skip PI4_VIBE_AUDIO_DEVICE_INFO_BYTES
.balign 8
pi4_doom_audio_ring_info:
    .skip PI4_VIBE_AUDIO_PCM_RING_INFO_BYTES
.balign 16
pi4_doom_audio_packet:
    .skip PI4_DOOM_AUDIO_PACKET_BYTES
.balign 16
pi4_doom_frame:
    .skip PI4_DOOM_FRAME_BYTES

.section .note.GNU-stack, "", %progbits
