#include "pi4_runtime.h"

.arch armv8-a

.equ K_ENTER,      13
.equ K_ESCAPE,     27
.equ K_UPARROW,    128
.equ K_DOWNARROW,  129
.equ K_LEFTARROW,  130
.equ K_RIGHTARROW, 131
.equ K_CTRL,       133
.equ K_SHIFT,      134
.equ K_SPACE,      32
.equ K_MOUSE1,     200
.equ K_MOUSE2,     201
.equ K_MOUSE3,     202
.equ USERCMD_FORWARDMOVE, 12
.equ USERCMD_SIDEMOVE,    16
.equ CVAR_VALUE,          24
.equ CL_VIEWANGLES,       444
.equ CL_PITCHVEL,         508
.equ CL_NODRIFT,          512
.equ CL_VIEW_PITCH,       0
.equ CL_VIEW_YAW,         4
.equ PI4_INPUT_DRAIN_LIMIT,       32
.equ PI4_INPUT_UART_MOVE_TICKS,   8
.equ PI4_INPUT_UART_FIRE_TICKS,   4
.equ PI4_INPUT_DEVICE_USB,        PI4_VIBE_INPUT_DEVICE_USB
.equ PI4_INPUT_KEY_RELEASED,      0
.equ PI4_INPUT_KEY_PRESSED,       1
.equ PI4_INPUT_KEY_SCANCODE_MASK, 0x7f
.equ PI4_INPUT_SCANCODE_ESCAPE,   0x01
.equ PI4_INPUT_SCANCODE_1,        0x02
.equ PI4_INPUT_SCANCODE_2,        0x03
.equ PI4_INPUT_SCANCODE_W,        0x11
.equ PI4_INPUT_SCANCODE_ENTER,    0x1c
.equ PI4_INPUT_SCANCODE_CTRL,     0x1d
.equ PI4_INPUT_SCANCODE_A,        0x1e
.equ PI4_INPUT_SCANCODE_S,        0x1f
.equ PI4_INPUT_SCANCODE_D,        0x20
.equ PI4_INPUT_SCANCODE_LSHIFT,   0x2a
.equ PI4_INPUT_SCANCODE_RSHIFT,   0x36
.equ PI4_INPUT_SCANCODE_SPACE,    0x39
.equ PI4_INPUT_SCANCODE_UP,       0x48
.equ PI4_INPUT_SCANCODE_LEFT,     0x4b
.equ PI4_INPUT_SCANCODE_RIGHT,    0x4d
.equ PI4_INPUT_SCANCODE_DOWN,     0x50
.equ PI4_INPUT_MOUSE_BUTTON_LEFT,  0x01
.equ PI4_INPUT_MOUSE_BUTTON_RIGHT, 0x02
.equ PI4_INPUT_MOUSE_BUTTON_MID,   0x04
.equ PI4_INPUT_SOURCE_USB_HID_KEYBOARD, PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
.equ PI4_INPUT_KEY_TOKEN_HID_SHIFT, PI4_VIBE_INPUT_EVENT_KEY_TOKEN_HID_SHIFT
.equ PI4_INPUT_KEY_TOKEN_FIELD_MASK, PI4_VIBE_INPUT_EVENT_KEY_TOKEN_FIELD_MASK
.equ PI4_INPUT_HID_USAGE_ESCAPE,  PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ESCAPE
.equ PI4_INPUT_HID_USAGE_1,       PI4_VIBE_INPUT_KEY_USB_HID_USAGE_1
.equ PI4_INPUT_HID_USAGE_2,       PI4_VIBE_INPUT_KEY_USB_HID_USAGE_2
.equ PI4_INPUT_HID_USAGE_A,       PI4_VIBE_INPUT_KEY_USB_HID_USAGE_A
.equ PI4_INPUT_HID_USAGE_D,       PI4_VIBE_INPUT_KEY_USB_HID_USAGE_D
.equ PI4_INPUT_HID_USAGE_W,       PI4_VIBE_INPUT_KEY_USB_HID_USAGE_W
.equ PI4_INPUT_HID_USAGE_S,       PI4_VIBE_INPUT_KEY_USB_HID_USAGE_S
.equ PI4_INPUT_HID_USAGE_ENTER,   PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ENTER
.equ PI4_INPUT_HID_USAGE_SPACE,   PI4_VIBE_INPUT_KEY_USB_HID_USAGE_SPACE
.equ PI4_INPUT_HID_USAGE_LEFT,    PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT
.equ PI4_INPUT_HID_USAGE_RIGHT,   PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT
.equ PI4_INPUT_HID_USAGE_UP,      PI4_VIBE_INPUT_KEY_USB_HID_USAGE_UP
.equ PI4_INPUT_HID_USAGE_DOWN,    PI4_VIBE_INPUT_KEY_USB_HID_USAGE_DOWN
.equ PI4_INPUT_HID_USAGE_KP_1,    PI4_VIBE_INPUT_KEY_USB_HID_USAGE_KP_1
.equ PI4_INPUT_HID_USAGE_KP_2,    PI4_VIBE_INPUT_KEY_USB_HID_USAGE_KP_2
.equ PI4_INPUT_HID_USAGE_LEFT_CTRL, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_CTRL
.equ PI4_INPUT_HID_USAGE_LEFT_SHIFT, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_SHIFT
.equ PI4_INPUT_HID_USAGE_RIGHT_CTRL, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_CTRL
.equ PI4_INPUT_HID_USAGE_RIGHT_SHIFT, PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_SHIFT

.extern Key_Event
.extern cl
.extern m_forward
.extern m_pitch
.extern m_side
.extern m_yaw
.extern sensitivity
.extern vibe_user_poll_input

.section .text.pi4_quake_engine.input, "ax", %progbits

.balign 16
.global IN_Init
.global IN_Shutdown
.global IN_Commands
.global quake_pump_input
.global pi4_quake_note_back_input
.type IN_Init, %function
.type IN_Shutdown, %function
.type IN_Commands, %function
.type quake_pump_input, %function
.type pi4_quake_note_back_input, %function
IN_Init:
IN_Shutdown:
    ret
IN_Commands:
quake_pump_input:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #80]
    str x21, [sp, #96]
    adrp x9, quake_uart_fire_ticks
    add x9, x9, :lo12:quake_uart_fire_ticks
    ldr x10, [x9]
    cbz x10, .Linput_start_poll
    sub x10, x10, #1
    str x10, [x9]
    cbnz x10, .Linput_start_poll
    adrp x9, quake_mouse_buttons
    add x9, x9, :lo12:quake_mouse_buttons
    ldr x10, [x9]
    tst x10, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.ne .Linput_start_poll
    mov x0, #K_MOUSE1
    mov x1, xzr
    bl .Linput_emit_key_return
.Linput_start_poll:
    mov x21, #PI4_INPUT_DRAIN_LIMIT
.Linput_poll_next:
    adrp x9, quake_input_poll_count
    add x9, x9, :lo12:quake_input_poll_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    add x0, sp, #16
    bl vibe_user_poll_input
    cmp x0, #1
    b.ne .Linput_done
    adrp x9, quake_input_event_count
    add x9, x9, :lo12:quake_input_event_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    ldr x8, [sp, #(16 + PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET)]
    ldr x9, [sp, #(16 + PI4_VIBE_INPUT_EVENT_TYPE_OFFSET)]
    cmp x8, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b.eq .Linput_keyboard_event
    cmp x8, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b.eq .Linput_mouse_event
    cmp x8, #PI4_INPUT_DEVICE_USB
    b.eq .Linput_usb_event
    cmp x8, #PI4_VIBE_INPUT_DEVICE_UART
    b.eq .Linput_uart_event
    b .Linput_event_done

	.Linput_keyboard_event:
	    cmp x9, #PI4_VIBE_INPUT_EVENT_KEY
	    b.ne .Linput_event_done
	    ldr x8, [sp, #(16 + PI4_VIBE_INPUT_EVENT_CODE_OFFSET)]
	    mov x12, x8
	    ldr x1, [sp, #(16 + PI4_VIBE_INPUT_EVENT_VALUE0_OFFSET)]
	    cmp x1, #PI4_INPUT_KEY_RELEASED
	    cset x1, ne
    ldr x10, [sp, #(16 + PI4_VIBE_INPUT_EVENT_VALUE1_OFFSET)]
    cbnz x10, .Linput_usb_hid_ready
    lsr x10, x8, #PI4_INPUT_KEY_TOKEN_HID_SHIFT
    and x10, x10, #PI4_INPUT_KEY_TOKEN_FIELD_MASK
    cbnz x10, .Linput_usb_hid_ready
    ldr x11, [sp, #(16 + PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET)]
    cmp x11, #PI4_INPUT_SOURCE_USB_HID_KEYBOARD
    b.ne .Linput_keyboard_code_ready
    and x10, x8, #PI4_INPUT_KEY_TOKEN_FIELD_MASK
    cbnz x10, .Linput_usb_hid_ready
.Linput_keyboard_code_ready:
    and x8, x8, #PI4_INPUT_KEY_SCANCODE_MASK
    cmp x8, #PI4_INPUT_SCANCODE_ESCAPE
    b.eq .Linput_key_escape
    cmp x8, #PI4_INPUT_SCANCODE_1
    b.eq .Linput_key_one
    cmp x8, #PI4_INPUT_SCANCODE_2
    b.eq .Linput_key_two
    cmp x8, #PI4_INPUT_SCANCODE_W
    b.eq .Linput_key_w
    cmp x8, #PI4_INPUT_SCANCODE_UP
    b.eq .Linput_key_up
    cmp x8, #PI4_INPUT_SCANCODE_S
    b.eq .Linput_key_s
    cmp x8, #PI4_INPUT_SCANCODE_DOWN
    b.eq .Linput_key_down
    cmp x8, #PI4_INPUT_SCANCODE_A
    b.eq .Linput_key_a
    cmp x8, #PI4_INPUT_SCANCODE_LEFT
    b.eq .Linput_key_left
    cmp x8, #PI4_INPUT_SCANCODE_D
    b.eq .Linput_key_d
    cmp x8, #PI4_INPUT_SCANCODE_RIGHT
    b.eq .Linput_key_right
    cmp x8, #PI4_INPUT_SCANCODE_ENTER
    b.eq .Linput_key_enter
    cmp x8, #PI4_INPUT_SCANCODE_CTRL
    b.eq .Linput_key_ctrl
    cmp x8, #PI4_INPUT_SCANCODE_LSHIFT
    b.eq .Linput_key_shift
    cmp x8, #PI4_INPUT_SCANCODE_RSHIFT
    b.eq .Linput_key_shift
    cmp x8, #PI4_INPUT_SCANCODE_SPACE
    b.eq .Linput_key_space
    b .Linput_event_done

.Linput_usb_event:
    cmp x9, #PI4_VIBE_INPUT_EVENT_KEY
    b.eq .Linput_usb_key_event
    cmp x9, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    b.eq .Linput_mouse_event
    b .Linput_event_done

	.Linput_usb_key_event:
	    ldr x8, [sp, #(16 + PI4_VIBE_INPUT_EVENT_CODE_OFFSET)]
	    mov x12, x8
	    ldr x1, [sp, #(16 + PI4_VIBE_INPUT_EVENT_VALUE0_OFFSET)]
	    cmp x1, #PI4_INPUT_KEY_RELEASED
	    cset x1, ne
    ldr x10, [sp, #(16 + PI4_VIBE_INPUT_EVENT_VALUE1_OFFSET)]
    cbnz x10, .Linput_usb_hid_ready
    lsr x10, x8, #PI4_INPUT_KEY_TOKEN_HID_SHIFT
    and x10, x10, #PI4_INPUT_KEY_TOKEN_FIELD_MASK
    cbnz x10, .Linput_usb_hid_ready
    and x10, x8, #PI4_INPUT_KEY_TOKEN_FIELD_MASK
.Linput_usb_hid_ready:
    cmp x10, #PI4_INPUT_HID_USAGE_ESCAPE
    b.eq .Linput_key_escape
    cmp x10, #PI4_INPUT_HID_USAGE_1
    b.eq .Linput_key_one
    cmp x10, #PI4_INPUT_HID_USAGE_KP_1
    b.eq .Linput_key_one
    cmp x10, #PI4_INPUT_HID_USAGE_2
    b.eq .Linput_key_two
    cmp x10, #PI4_INPUT_HID_USAGE_KP_2
    b.eq .Linput_key_two
    cmp x10, #PI4_INPUT_HID_USAGE_W
    b.eq .Linput_key_w
    cmp x10, #PI4_INPUT_HID_USAGE_UP
    b.eq .Linput_key_up
    cmp x10, #PI4_INPUT_HID_USAGE_S
    b.eq .Linput_key_s
    cmp x10, #PI4_INPUT_HID_USAGE_DOWN
    b.eq .Linput_key_down
    cmp x10, #PI4_INPUT_HID_USAGE_A
    b.eq .Linput_key_a
    cmp x10, #PI4_INPUT_HID_USAGE_LEFT
    b.eq .Linput_key_left
    cmp x10, #PI4_INPUT_HID_USAGE_D
    b.eq .Linput_key_d
    cmp x10, #PI4_INPUT_HID_USAGE_RIGHT
    b.eq .Linput_key_right
    cmp x10, #PI4_INPUT_HID_USAGE_ENTER
    b.eq .Linput_key_enter
    cmp x10, #PI4_INPUT_HID_USAGE_LEFT_CTRL
    b.eq .Linput_key_ctrl
    cmp x10, #PI4_INPUT_HID_USAGE_RIGHT_CTRL
    b.eq .Linput_key_ctrl
    cmp x10, #PI4_INPUT_HID_USAGE_LEFT_SHIFT
    b.eq .Linput_key_shift
    cmp x10, #PI4_INPUT_HID_USAGE_RIGHT_SHIFT
    b.eq .Linput_key_shift
    cmp x10, #PI4_INPUT_HID_USAGE_SPACE
    b.eq .Linput_key_space
    mov x8, x12
    b .Linput_keyboard_code_ready

.Linput_uart_event:
    cmp x9, #PI4_VIBE_INPUT_EVENT_UART
    b.ne .Linput_event_done
    adrp x10, quake_input_uart_event_count
    add x10, x10, :lo12:quake_input_uart_event_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    ldr x8, [sp, #(16 + PI4_VIBE_INPUT_EVENT_CODE_OFFSET)]
    cmp x8, #PI4_VIBE_UART_EVENT_UP
    b.eq .Linput_uart_forward
    cmp x8, #PI4_VIBE_UART_EVENT_DOWN
    b.eq .Linput_uart_back
    cmp x8, #PI4_VIBE_UART_EVENT_CONFIRM
    b.eq .Linput_uart_fire
    cmp x8, #PI4_VIBE_UART_EVENT_SELECT_1
    b.eq .Linput_uart_left
    cmp x8, #PI4_VIBE_UART_EVENT_SELECT_2
    b.eq .Linput_uart_right
    b .Linput_event_done

.Linput_mouse_event:
    cmp x9, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    b.ne .Linput_event_done
    adrp x10, quake_input_mouse_packet_count
    add x10, x10, :lo12:quake_input_mouse_packet_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    ldr x11, [sp, #(16 + PI4_VIBE_INPUT_EVENT_VALUE0_OFFSET)]
    ldr x12, [sp, #(16 + PI4_VIBE_INPUT_EVENT_VALUE1_OFFSET)]
    adrp x9, quake_input_mouse_dx_total
    add x9, x9, :lo12:quake_input_mouse_dx_total
    ldr x10, [x9]
    add x10, x10, x11
    str x10, [x9]
    adrp x9, quake_input_mouse_dy_total
    add x9, x9, :lo12:quake_input_mouse_dy_total
    ldr x10, [x9]
    add x10, x10, x12
    str x10, [x9]
    adrp x9, quake_mouse_dx
    add x9, x9, :lo12:quake_mouse_dx
    ldr x10, [x9]
    add x10, x10, x11
    str x10, [x9]
    adrp x9, quake_mouse_dy
    add x9, x9, :lo12:quake_mouse_dy
    ldr x10, [x9]
    add x10, x10, x12
    str x10, [x9]

    ldr x11, [sp, #(16 + PI4_VIBE_INPUT_EVENT_CODE_OFFSET)]
    and x20, x11, #0x7
    adrp x9, quake_input_last_mouse_buttons
    add x9, x9, :lo12:quake_input_last_mouse_buttons
    str x20, [x9]
    adrp x9, quake_mouse_buttons
    add x9, x9, :lo12:quake_mouse_buttons
    ldr x19, [x9]
    str x20, [x9]
    eor x10, x19, x20
    tst x10, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.eq .Linput_mouse_right_button
    mov x0, #K_MOUSE1
    tst x20, #PI4_INPUT_MOUSE_BUTTON_LEFT
    b.ne .Linput_mouse_left_down
    adrp x9, quake_uart_fire_ticks
    add x9, x9, :lo12:quake_uart_fire_ticks
    ldr x1, [x9]
    cmp x1, #0
    cset x1, ne
    b .Linput_mouse_left_emit
.Linput_mouse_left_down:
    mov x1, #1
.Linput_mouse_left_emit:
    bl .Linput_emit_key_return
.Linput_mouse_right_button:
    eor x10, x19, x20
    tst x10, #PI4_INPUT_MOUSE_BUTTON_RIGHT
    b.eq .Linput_mouse_mid_button
    mov x0, #K_MOUSE2
    tst x20, #PI4_INPUT_MOUSE_BUTTON_RIGHT
    cset x1, ne
    bl .Linput_emit_key_return
.Linput_mouse_mid_button:
    eor x10, x19, x20
    tst x10, #PI4_INPUT_MOUSE_BUTTON_MID
    b.eq .Linput_event_done
    mov x0, #K_MOUSE3
    tst x20, #PI4_INPUT_MOUSE_BUTTON_MID
    cset x1, ne
    bl .Linput_emit_key_return
    b .Linput_event_done

.Linput_key_escape:
    mov x0, #K_ESCAPE
    b .Linput_emit_key
.Linput_key_w:
    mov x0, #'w'
    b .Linput_emit_key
.Linput_key_s:
    mov x0, #'s'
    b .Linput_emit_key
.Linput_key_a:
    mov x0, #'a'
    b .Linput_emit_key
.Linput_key_d:
    mov x0, #'d'
    b .Linput_emit_key
.Linput_key_up:
    mov x0, #K_UPARROW
    b .Linput_emit_key
.Linput_key_down:
    mov x0, #K_DOWNARROW
    b .Linput_emit_key
.Linput_key_left:
    mov x0, #K_LEFTARROW
    b .Linput_emit_key
.Linput_key_right:
    mov x0, #K_RIGHTARROW
    b .Linput_emit_key
.Linput_key_enter:
    mov x0, #K_ENTER
    b .Linput_emit_key
.Linput_key_ctrl:
    mov x0, #K_CTRL
    b .Linput_emit_key
.Linput_key_shift:
    mov x0, #K_SHIFT
    b .Linput_emit_key
.Linput_key_space:
    mov x0, #' '
    b .Linput_emit_key
.Linput_key_one:
    mov x0, #'1'
    b .Linput_emit_key
.Linput_key_two:
    mov x0, #'2'
.Linput_emit_key:
    bl .Linput_emit_key_return
    b .Linput_event_done
	.Linput_emit_key_return:
	    adrp x9, quake_key_state
	    add x9, x9, :lo12:quake_key_state
	    ldrb w10, [x9, x0]
	    cmp w10, w1
	    b.eq .Linput_emit_key_unchanged
	    strb w1, [x9, x0]
	    cbz x1, .Linput_count_key_release
	    adrp x9, quake_input_key_press_count
	    add x9, x9, :lo12:quake_input_key_press_count
	    b .Linput_count_key_transition
	.Linput_count_key_release:
	    adrp x9, quake_input_key_release_count
	    add x9, x9, :lo12:quake_input_key_release_count
	.Linput_count_key_transition:
		    ldr x10, [x9]
		    add x10, x10, #1
		    str x10, [x9]
		    adrp x9, quake_input_last_key
		    add x9, x9, :lo12:quake_input_last_key
		    str x0, [x9]
		    cbz x1, .Linput_key_progress_count_done
		    cmp x0, #K_MOUSE1
		    b.eq .Linput_count_action_key
		    cmp x0, #K_CTRL
		    b.eq .Linput_count_action_key
		    cmp x0, #K_SPACE
		    b.ne .Linput_key_progress_count_done
		.Linput_count_action_key:
		    adrp x9, quake_input_action_count
		    add x9, x9, :lo12:quake_input_action_count
		    ldr x10, [x9]
		    add x10, x10, #1
		    str x10, [x9]
		.Linput_key_progress_count_done:
	    adrp x9, quake_input_key_event_count
	    add x9, x9, :lo12:quake_input_key_event_count
	    ldr x10, [x9]
	    add x10, x10, #1
		    str x10, [x9]
	    b Key_Event
	.Linput_emit_key_unchanged:
	    cbz x1, .Linput_emit_key_unchanged_done
	    adrp x9, quake_input_key_repeat_count
	    add x9, x9, :lo12:quake_input_key_repeat_count
	    ldr x10, [x9]
	    add x10, x10, #1
	    str x10, [x9]
	.Linput_emit_key_unchanged_done:
	    ret
.Linput_uart_forward:
    adrp x9, quake_uart_forward_ticks
    add x9, x9, :lo12:quake_uart_forward_ticks
    b .Linput_uart_store_pulse
.Linput_uart_back:
    adrp x9, quake_uart_back_ticks
    add x9, x9, :lo12:quake_uart_back_ticks
    b .Linput_uart_store_pulse
.Linput_uart_left:
    adrp x9, quake_uart_left_ticks
    add x9, x9, :lo12:quake_uart_left_ticks
    b .Linput_uart_store_pulse
.Linput_uart_right:
    adrp x9, quake_uart_right_ticks
    add x9, x9, :lo12:quake_uart_right_ticks
    b .Linput_uart_store_pulse
.Linput_uart_store_pulse:
    mov x10, #PI4_INPUT_UART_MOVE_TICKS
    str x10, [x9]
    b .Linput_event_done
.Linput_uart_fire:
    adrp x9, quake_uart_fire_ticks
    add x9, x9, :lo12:quake_uart_fire_ticks
    mov x10, #PI4_INPUT_UART_FIRE_TICKS
    str x10, [x9]
    mov x0, #K_MOUSE1
    mov x1, #1
    bl .Linput_emit_key_return
.Linput_event_done:
    subs x21, x21, #1
    b.ne .Linput_poll_next
.Linput_done:
    ldr x21, [sp, #96]
    ldp x19, x20, [sp, #80]
    ldp x29, x30, [sp], #112
    ret
.size IN_Init, . - IN_Init
.size IN_Shutdown, . - IN_Shutdown
.size IN_Commands, . - IN_Commands
.size quake_pump_input, . - quake_pump_input

.balign 16
pi4_quake_note_back_input:
    adrp x9, quake_uart_back_ticks
    add x9, x9, :lo12:quake_uart_back_ticks
    mov x10, #PI4_INPUT_UART_MOVE_TICKS
    str x10, [x9]
    ret
.size pi4_quake_note_back_input, . - pi4_quake_note_back_input

.balign 16
.global IN_ClearStates
.type IN_ClearStates, %function
IN_ClearStates:
    adrp x0, quake_key_state
    add x0, x0, :lo12:quake_key_state
    mov x1, #256
.Lclear_next:
    strb wzr, [x0], #1
    subs x1, x1, #1
    b.ne .Lclear_next
    adrp x0, quake_mouse_dx
    add x0, x0, :lo12:quake_mouse_dx
    mov x1, #8
.Lclear_words_next:
    str xzr, [x0], #8
    subs x1, x1, #1
    b.ne .Lclear_words_next
    ret
.size IN_ClearStates, . - IN_ClearStates

.balign 16
.global IN_Move
.type IN_Move, %function
IN_Move:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    cbz x0, .Lin_move_done
    adrp x8, quake_key_state
    add x8, x8, :lo12:quake_key_state
    ldrb w9, [x8, #'w']
    cbnz w9, .Lin_move_forward
    adrp x11, quake_uart_forward_ticks
    add x11, x11, :lo12:quake_uart_forward_ticks
    ldr x12, [x11]
    cbz x12, .Lin_check_back
	.Lin_move_forward:
	    mov w10, #0x0000
	    movk w10, #0x4348, lsl #16
	    str w10, [x0, #USERCMD_FORWARDMOVE]
	    bl .Lin_count_move_command
	    b .Lin_check_side
.Lin_check_back:
    ldrb w9, [x8, #'s']
    cbnz w9, .Lin_move_back
    adrp x11, quake_uart_back_ticks
    add x11, x11, :lo12:quake_uart_back_ticks
    ldr x12, [x11]
    cbz x12, .Lin_check_side
	.Lin_move_back:
	    mov w10, #0x0000
	    movk w10, #0xc348, lsl #16
	    str w10, [x0, #USERCMD_FORWARDMOVE]
	    bl .Lin_count_move_command
	.Lin_check_side:
    ldrb w9, [x8, #'d']
    cbnz w9, .Lin_move_right
    adrp x11, quake_uart_right_ticks
    add x11, x11, :lo12:quake_uart_right_ticks
    ldr x12, [x11]
    cbz x12, .Lin_check_left
	.Lin_move_right:
	    mov w10, #0x0000
	    movk w10, #0x4348, lsl #16
	    str w10, [x0, #USERCMD_SIDEMOVE]
	    bl .Lin_count_move_command
	    b .Lin_check_key_yaw
.Lin_check_left:
    ldrb w9, [x8, #'a']
    cbnz w9, .Lin_move_left
    adrp x11, quake_uart_left_ticks
    add x11, x11, :lo12:quake_uart_left_ticks
    ldr x12, [x11]
    cbz x12, .Lin_check_key_yaw
	.Lin_move_left:
	    mov w10, #0x0000
	    movk w10, #0xc348, lsl #16
	    str w10, [x0, #USERCMD_SIDEMOVE]
	    bl .Lin_count_move_command
	.Lin_check_key_yaw:
    ldrb w9, [x8, #K_LEFTARROW]
    ldrb w10, [x8, #K_RIGHTARROW]
    cmp w9, w10
    b.eq .Lin_check_key_pitch
    adrp x11, cl
    add x11, x11, :lo12:cl
    ldr s4, [x11, #(CL_VIEWANGLES + CL_VIEW_YAW)]
    adrp x12, .Linput_float_key_yaw_step
    add x12, x12, :lo12:.Linput_float_key_yaw_step
    ldr s5, [x12]
    cbnz w9, .Lin_key_look_left
    fsub s4, s4, s5
    b .Lin_store_key_yaw
.Lin_key_look_left:
    fadd s4, s4, s5
.Lin_store_key_yaw:
    bl .Lin_wrap_yaw
	    str s4, [x11, #(CL_VIEWANGLES + CL_VIEW_YAW)]
	    bl .Lin_count_arrow_look
	    bl .Lin_count_view_change
	.Lin_check_key_pitch:
    ldrb w9, [x8, #K_UPARROW]
    ldrb w10, [x8, #K_DOWNARROW]
    cmp w9, w10
    b.eq .Lin_check_mouse_x
    adrp x11, cl
    add x11, x11, :lo12:cl
    ldr s4, [x11, #(CL_VIEWANGLES + CL_VIEW_PITCH)]
    adrp x12, .Linput_float_key_pitch_step
    add x12, x12, :lo12:.Linput_float_key_pitch_step
    ldr s5, [x12]
    cbnz w9, .Lin_key_look_up
    fadd s4, s4, s5
    b .Lin_store_key_pitch
.Lin_key_look_up:
    fsub s4, s4, s5
.Lin_store_key_pitch:
    bl .Lin_clamp_pitch
    str s4, [x11, #(CL_VIEWANGLES + CL_VIEW_PITCH)]
    str wzr, [x11, #CL_PITCHVEL]
	    mov w10, #1
	    str w10, [x11, #CL_NODRIFT]
	    bl .Lin_count_arrow_look
	    bl .Lin_count_view_change
	.Lin_check_mouse_x:
    adrp x8, quake_mouse_dx
    add x8, x8, :lo12:quake_mouse_dx
    ldr x9, [x8]
    str xzr, [x8]
    cmp x9, #0
    b.eq .Lin_check_mouse_y
    adrp x10, quake_mouse_buttons
    add x10, x10, :lo12:quake_mouse_buttons
    ldr x10, [x10]
    tst x10, #PI4_INPUT_MOUSE_BUTTON_RIGHT
    b.ne .Lin_mouse_x_strafe
    scvtf s1, x9
    bl .Lin_apply_mouse_sensitivity
    adrp x10, m_yaw
    add x10, x10, :lo12:m_yaw
    ldr s3, [x10, #CVAR_VALUE]
    fmul s1, s1, s3
    adrp x10, cl
    add x10, x10, :lo12:cl
    ldr s4, [x10, #(CL_VIEWANGLES + CL_VIEW_YAW)]
	    fsub s4, s4, s1
	    bl .Lin_wrap_yaw
	    str s4, [x10, #(CL_VIEWANGLES + CL_VIEW_YAW)]
	    bl .Lin_count_view_change
	    b .Lin_check_mouse_y
.Lin_mouse_x_strafe:
    scvtf s1, x9
    bl .Lin_apply_mouse_sensitivity
    adrp x10, m_side
    add x10, x10, :lo12:m_side
    ldr s3, [x10, #CVAR_VALUE]
    fmul s1, s1, s3
	    ldr s4, [x0, #USERCMD_SIDEMOVE]
	    fadd s4, s4, s1
	    str s4, [x0, #USERCMD_SIDEMOVE]
	    bl .Lin_count_move_command
	.Lin_check_mouse_y:
    adrp x8, quake_mouse_dy
    add x8, x8, :lo12:quake_mouse_dy
    ldr x9, [x8]
    str xzr, [x8]
    cmp x9, #0
    b.eq .Lin_move_done
    adrp x10, quake_mouse_buttons
    add x10, x10, :lo12:quake_mouse_buttons
    ldr x10, [x10]
    tst x10, #PI4_INPUT_MOUSE_BUTTON_RIGHT
    b.ne .Lin_mouse_y_move
    scvtf s1, x9
    bl .Lin_apply_mouse_sensitivity
    adrp x10, m_pitch
    add x10, x10, :lo12:m_pitch
    ldr s3, [x10, #CVAR_VALUE]
    fmul s1, s1, s3
    adrp x10, cl
    add x10, x10, :lo12:cl
    ldr s4, [x10, #(CL_VIEWANGLES + CL_VIEW_PITCH)]
    fadd s4, s4, s1
    bl .Lin_clamp_pitch
    str s4, [x10, #(CL_VIEWANGLES + CL_VIEW_PITCH)]
    str wzr, [x10, #CL_PITCHVEL]
	    mov w11, #1
	    str w11, [x10, #CL_NODRIFT]
	    bl .Lin_count_view_change
	    b .Lin_move_done
.Lin_mouse_y_move:
    scvtf s1, x9
    bl .Lin_apply_mouse_sensitivity
    adrp x10, m_forward
    add x10, x10, :lo12:m_forward
    ldr s3, [x10, #CVAR_VALUE]
    fmul s1, s1, s3
	    ldr s4, [x0, #USERCMD_FORWARDMOVE]
	    fsub s4, s4, s1
	    str s4, [x0, #USERCMD_FORWARDMOVE]
	    bl .Lin_count_move_command
	.Lin_move_done:
    adrp x8, quake_uart_forward_ticks
    add x8, x8, :lo12:quake_uart_forward_ticks
    mov x9, #4
.Lin_decay_uart_next:
    ldr x10, [x8]
    cbz x10, .Lin_decay_uart_skip
    sub x10, x10, #1
    str x10, [x8]
.Lin_decay_uart_skip:
    add x8, x8, #8
    subs x9, x9, #1
    b.ne .Lin_decay_uart_next
    ldp x29, x30, [sp], #16
    ret

.Lin_apply_mouse_sensitivity:
    adrp x12, sensitivity
    add x12, x12, :lo12:sensitivity
    ldr s2, [x12, #CVAR_VALUE]
    fmul s1, s1, s2
    ret

	.Lin_count_arrow_look:
	    adrp x12, quake_input_arrow_look_count
	    add x12, x12, :lo12:quake_input_arrow_look_count
	    ldr x9, [x12]
	    add x9, x9, #1
	    str x9, [x12]
	    ret

	.Lin_count_move_command:
	    adrp x12, quake_input_move_command_count
	    add x12, x12, :lo12:quake_input_move_command_count
	    ldr x9, [x12]
	    add x9, x9, #1
	    str x9, [x12]
	    ret

	.Lin_count_view_change:
	    adrp x12, quake_input_view_change_count
	    add x12, x12, :lo12:quake_input_view_change_count
	    ldr x9, [x12]
	    add x9, x9, #1
	    str x9, [x12]
	    ret

.Lin_wrap_yaw:
    adrp x12, .Linput_float_360
    add x12, x12, :lo12:.Linput_float_360
    ldr s5, [x12]
.Lin_wrap_yaw_low:
    fcmp s4, #0.0
    b.ge .Lin_wrap_yaw_high
    fadd s4, s4, s5
    b .Lin_wrap_yaw_low
.Lin_wrap_yaw_high:
    fcmp s4, s5
    b.lt .Lin_wrap_yaw_done
    fsub s4, s4, s5
    b .Lin_wrap_yaw_high
.Lin_wrap_yaw_done:
    ret

.Lin_clamp_pitch:
    adrp x12, .Linput_float_pitch_max
    add x12, x12, :lo12:.Linput_float_pitch_max
    ldr s5, [x12]
    fcmp s4, s5
    b.le .Lin_clamp_pitch_min
    fmov s4, s5
    ret
.Lin_clamp_pitch_min:
    adrp x12, .Linput_float_pitch_min
    add x12, x12, :lo12:.Linput_float_pitch_min
    ldr s5, [x12]
    fcmp s4, s5
    b.ge .Lin_clamp_pitch_done
    fmov s4, s5
.Lin_clamp_pitch_done:
    ret
.size IN_Move, . - IN_Move

.section .rodata.pi4_quake_engine.input, "a", %progbits
.balign 4
.Linput_float_360:
    .float 360.0
.Linput_float_pitch_max:
    .float 80.0
.Linput_float_pitch_min:
    .float -70.0
.Linput_float_key_yaw_step:
    .float 4.0
.Linput_float_key_pitch_step:
    .float 3.0

.section .bss.pi4_quake_engine.input, "aw", %nobits
.balign 16
quake_key_state:
    .skip 256
.balign 8
quake_mouse_dx:
    .skip 8
quake_mouse_dy:
    .skip 8
quake_mouse_buttons:
    .skip 8
quake_uart_forward_ticks:
    .skip 8
quake_uart_back_ticks:
    .skip 8
quake_uart_left_ticks:
    .skip 8
quake_uart_right_ticks:
    .skip 8
quake_uart_fire_ticks:
    .skip 8
.global quake_input_poll_count
.global quake_input_event_count
.global quake_input_key_event_count
.global quake_input_mouse_packet_count
.global quake_input_uart_event_count
.global quake_input_mouse_dx_total
.global quake_input_mouse_dy_total
.global quake_input_last_key
.global quake_input_last_mouse_buttons
.global quake_input_key_press_count
.global quake_input_key_release_count
.global quake_input_key_repeat_count
.global quake_input_arrow_look_count
.global quake_input_move_command_count
.global quake_input_view_change_count
.global quake_input_action_count
quake_input_poll_count:
    .skip 8
quake_input_event_count:
    .skip 8
quake_input_key_event_count:
    .skip 8
quake_input_mouse_packet_count:
    .skip 8
quake_input_uart_event_count:
    .skip 8
quake_input_mouse_dx_total:
    .skip 8
quake_input_mouse_dy_total:
    .skip 8
quake_input_last_key:
    .skip 8
quake_input_last_mouse_buttons:
    .skip 8
quake_input_key_press_count:
    .skip 8
quake_input_key_release_count:
    .skip 8
quake_input_key_repeat_count:
    .skip 8
quake_input_arrow_look_count:
    .skip 8
quake_input_move_command_count:
    .skip 8
quake_input_view_change_count:
    .skip 8
quake_input_action_count:
    .skip 8

.section .note.GNU-stack, "", %progbits
