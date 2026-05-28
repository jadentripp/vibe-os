// Raspberry Pi 4 live UART input lane for launcher/gameplay selection.

.arch armv8-a

.equ PI4_PERIPHERAL_BASE,               0xfe000000
.equ PI4_UART0_BASE,                    0xfe201000
.equ PI4_UART0_DR,                      PI4_UART0_BASE + 0x00
.equ PI4_UART0_ECR,                     PI4_UART0_BASE + 0x04
.equ PI4_UART0_FR,                      PI4_UART0_BASE + 0x18
.equ PI4_AUX_BASE,                      0xfe215000
.equ PI4_AUX_ENABLES,                   PI4_AUX_BASE + 0x04
.equ PI4_AUX_MU_IO,                     PI4_AUX_BASE + 0x40
.equ PI4_AUX_MU_IER,                    PI4_AUX_BASE + 0x44
.equ PI4_AUX_MU_LCR,                    PI4_AUX_BASE + 0x4c
.equ PI4_AUX_MU_LSR,                    PI4_AUX_BASE + 0x54
.equ PI4_AUX_MU_CNTL,                   PI4_AUX_BASE + 0x60
.equ PI4_DWC2_BASE,                     0xfe980000
.equ PI4_DWC2_GAHBCFG,                  PI4_DWC2_BASE + 0x008
.equ PI4_DWC2_GUSBCFG,                  PI4_DWC2_BASE + 0x00c
.equ PI4_DWC2_GINTSTS,                  PI4_DWC2_BASE + 0x014
.equ PI4_DWC2_HCFG,                     PI4_DWC2_BASE + 0x400
.equ PI4_DWC2_HPRT0,                    PI4_DWC2_BASE + 0x440
.equ PI4_DWC2_HCCHAR0,                  PI4_DWC2_BASE + 0x500
.equ PI4_DWC2_HCSPLT0,                  PI4_DWC2_BASE + 0x504
.equ PI4_DWC2_HCINT0,                   PI4_DWC2_BASE + 0x508
.equ PI4_DWC2_HCINTMSK0,                PI4_DWC2_BASE + 0x50c
.equ PI4_DWC2_HCTSIZ0,                  PI4_DWC2_BASE + 0x510
.equ PI4_DWC2_HCDMA0,                   PI4_DWC2_BASE + 0x514

.equ PI4_UART_FR_RXFE,                  4
.equ PI4_UART_DR_DATA_MASK,             0x00ff
.equ PI4_UART_DR_FE,                    8
.equ PI4_UART_DR_PE,                    9
.equ PI4_UART_DR_BE,                    10
.equ PI4_UART_DR_OE,                    11
.equ PI4_UART_DR_ERROR_MASK,            0x0f00
.equ PI4_AUX_MU_LSR_DATA_READY,         0
.equ PI4_DWC2_GAHBCFG_DMA_EN,           5
.equ PI4_DWC2_GUSBCFG_FORCEHOSTMODE,    29
.equ PI4_DWC2_GINTSTS_CURMODE_HOST,     0
.equ PI4_DWC2_HPRT0_CONNSTS,            0
.equ PI4_DWC2_HPRT0_ENA,                2
.equ PI4_DWC2_HPRT0_RST,                8
.equ PI4_DWC2_HPRT0_PWR,                12
.equ PI4_DWC2_HPRT0_SPD_SHIFT,          17
.equ PI4_DWC2_HPRT0_SPD_LOW_SPEED,      2
.equ PI4_DWC2_HCINT_XFERCOMPL,          0
.equ PI4_DWC2_HCINT_CHHLTD,             1
.equ PI4_DWC2_HCINT_STALL,              3
.equ PI4_DWC2_HCINT_NAK,                4
.equ PI4_DWC2_HCCHAR_EPNUM_SHIFT,       11
.equ PI4_DWC2_HCCHAR_EPDIR,             15
.equ PI4_DWC2_HCCHAR_LSPDDEV,           17
.equ PI4_DWC2_HCCHAR_EPTYPE_SHIFT,      18
.equ PI4_DWC2_HCCHAR_MC_SHIFT,          20
.equ PI4_DWC2_HCCHAR_DEVADDR_SHIFT,     22
.equ PI4_DWC2_HCCHAR_CHENA,             31
.equ PI4_DWC2_HCTSIZ_PKTCNT_SHIFT,      19
.equ PI4_DWC2_HCTSIZ_PID_SHIFT,         29
.equ PI4_DWC2_EPTYPE_CONTROL,           0
.equ PI4_DWC2_EPTYPE_INTERRUPT,         3
.equ PI4_DWC2_PID_DATA0,                0
.equ PI4_DWC2_PID_DATA1,                2
.equ PI4_DWC2_PID_SETUP,                3
.equ PI4_USB_EP0_MPS,                   64
.equ PI4_USB_EP0_MPS_DEFAULT,           8
.equ PI4_USB_HID_MPS,                   8
.equ PI4_USB_HID_REPORT_MAX,            8
.equ PI4_USB_HID_MOUSE_REPORT_BYTES,    4
.equ PI4_USB_ENDPOINT_MPS_MAX,          64
.equ PI4_USB_DEVICE_HID,                1
.equ PI4_USB_DEVICE_ADDR_DEFAULT,       0
.equ PI4_USB_DEVICE_ADDR_HUB,           1
.equ PI4_USB_DEVICE_ADDR_HID0,          2
.equ PI4_USB_DEVICE_ADDR_HID1,          3
.equ PI4_USB_DEVICE_KIND_UNKNOWN,       0
.equ PI4_USB_DEVICE_KIND_KEYBOARD,      1
.equ PI4_USB_DEVICE_KIND_MOUSE,         2
.equ PI4_USB_HID_CAP_KEYBOARD,          0x01
.equ PI4_USB_HID_CAP_MOUSE,             0x02
.equ PI4_USB_DESCRIPTOR_TYPE_DEVICE,     1
.equ PI4_USB_DESCRIPTOR_TYPE_CONFIGURATION, 2
.equ PI4_USB_DESCRIPTOR_TYPE_INTERFACE,  4
.equ PI4_USB_DESCRIPTOR_TYPE_ENDPOINT,   5
.equ PI4_USB_DESCRIPTOR_TYPE_HUB,        0x29
.equ PI4_USB_ENDPOINT_DIR_IN,            0x80
.equ PI4_USB_ENDPOINT_NUMBER_MASK,       0x0f
.equ PI4_USB_ENDPOINT_TRANSFER_MASK,     0x03
.equ PI4_USB_ENDPOINT_TRANSFER_INTERRUPT, 3
.equ PI4_USB_DEVICE_CLASS_HUB,           9
.equ PI4_USB_HID_INTERFACE_CLASS,        3
.equ PI4_USB_HID_BOOT_SUBCLASS,          1
.equ PI4_USB_HID_BOOT_KEYBOARD,          1
.equ PI4_USB_HID_BOOT_MOUSE,             2
.equ PI4_USB_HUB_MAX_PORTS,              8
.equ PI4_USB_HUB_REQ_GET_STATUS,         0
.equ PI4_USB_HUB_REQ_SET_FEATURE,        3
.equ PI4_USB_HUB_FEATURE_PORT_RESET,     4
.equ PI4_USB_HUB_FEATURE_PORT_POWER,     8
.equ PI4_USB_HUB_PORT_CONNECTION,        0
.equ PI4_USB_HUB_PORT_ENABLE,            1
.equ PI4_USB_HUB_DESCRIPTOR_BYTES,        16
.equ PI4_USB_CONFIG_DESCRIPTOR_BYTES,     128
.equ PI4_USB_STATUS_WAIT,               0
.equ PI4_USB_STATUS_HOST,               1
.equ PI4_USB_STATUS_PORT,               2
.equ PI4_USB_STATUS_ADDR,               3
.equ PI4_USB_STATUS_HID,                4

.equ PI4_UART_INPUT_QUEUE_SIZE,         8
.equ PI4_UART_INPUT_QUEUE_MASK,         PI4_UART_INPUT_QUEUE_SIZE - 1

.equ PI4_INPUT_DEVICE_KEYBOARD,         1
.equ PI4_INPUT_DEVICE_MOUSE,            2
.equ PI4_INPUT_DEVICE_UART,             3
.equ PI4_INPUT_DEVICE_USB,              4

.equ PI4_UART_INPUT_ESC_NONE,           0
.equ PI4_UART_INPUT_ESC_SEEN,           1
.equ PI4_UART_INPUT_ESC_CSI,            2

.equ PI4_INPUT_EVENT_NONE,              0
.equ PI4_INPUT_EVENT_SELECT_1,          1
.equ PI4_INPUT_EVENT_SELECT_2,          2
.equ PI4_INPUT_EVENT_ENTER,             3
.equ PI4_INPUT_EVENT_UP,                4
.equ PI4_INPUT_EVENT_DOWN,              5
.equ PI4_INPUT_EVENT_MOUSE_PACKET,      6
.equ PI4_INPUT_EVENT_LAUNCH_1,          7
.equ PI4_INPUT_EVENT_LAUNCH_2,          8
.equ PI4_INPUT_EVENT_TYPE_KEY,          1
.equ PI4_INPUT_EVENT_TYPE_MOUSE_PACKET, 2
.equ PI4_INPUT_EVENT_TYPE_UART,         3

.equ PI4_INPUT_QUEUE_SLOT_BYTES,        8
.equ PI4_INPUT_EVENT_TOKEN_KIND_MASK,   0xff
.equ PI4_INPUT_EVENT_TOKEN_KEY,         0x80000000
.equ PI4_INPUT_EVENT_TOKEN_KEY_CODE_MASK, 0xff
.equ PI4_INPUT_EVENT_TOKEN_KEY_HID_SHIFT, 8
.equ PI4_INPUT_EVENT_TOKEN_KEY_ACTION_SHIFT, 24
.equ PI4_INPUT_EVENT_TOKEN_MOUSE_BUTTONS_SHIFT, 8
.equ PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_X_SHIFT, 16
.equ PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_Y_SHIFT, 24
.equ PI4_INPUT_KEY_RELEASED,            0
.equ PI4_INPUT_KEY_PRESSED,             1
.equ PI4_INPUT_KEY_PS2_ESCAPE,          0x01
.equ PI4_INPUT_KEY_PS2_1,               0x02
.equ PI4_INPUT_KEY_PS2_2,               0x03
.equ PI4_INPUT_KEY_PS2_3,               0x04
.equ PI4_INPUT_KEY_PS2_4,               0x05
.equ PI4_INPUT_KEY_PS2_5,               0x06
.equ PI4_INPUT_KEY_PS2_6,               0x07
.equ PI4_INPUT_KEY_PS2_7,               0x08
.equ PI4_INPUT_KEY_PS2_BACKSPACE,       0x0e
.equ PI4_INPUT_KEY_PS2_TAB,             0x0f
.equ PI4_INPUT_KEY_PS2_Q,               0x10
.equ PI4_INPUT_KEY_PS2_LEFT_CTRL,       0x1d
.equ PI4_INPUT_KEY_PS2_W,               0x11
.equ PI4_INPUT_KEY_PS2_E,               0x12
.equ PI4_INPUT_KEY_PS2_ENTER,           0x1c
.equ PI4_INPUT_KEY_PS2_A,               0x1e
.equ PI4_INPUT_KEY_PS2_S,               0x1f
.equ PI4_INPUT_KEY_PS2_D,               0x20
.equ PI4_INPUT_KEY_PS2_LEFT_SHIFT,      0x2a
.equ PI4_INPUT_KEY_PS2_RIGHT_SHIFT,     0x36
.equ PI4_INPUT_KEY_PS2_SPACE,           0x39
.equ PI4_INPUT_KEY_PS2_LEFT_ALT,        0x38
.equ PI4_INPUT_KEY_PS2_LEFT,            0x4b
.equ PI4_INPUT_KEY_PS2_RIGHT,           0x4d
.equ PI4_INPUT_KEY_PS2_UP,              0x48
.equ PI4_INPUT_KEY_PS2_DOWN,            0x50
.equ PI4_INPUT_KEY_PS2_RIGHT_CTRL,      0x9d
.equ PI4_INPUT_KEY_PS2_RIGHT_ALT,       0xb8
.equ PI4_INPUT_MOD_SHIFT,               0x00000001
.equ PI4_INPUT_MOD_CTRL,                0x00000002
.equ PI4_INPUT_MOD_ALT,                 0x00000004
.equ PI4_USB_PENDING_QUEUE_SIZE,        32
.equ PI4_USB_PENDING_QUEUE_MASK,        PI4_USB_PENDING_QUEUE_SIZE - 1

.section .text.boot, "ax", %progbits
.balign 16
.type pi4_uart_input_init, %function
pi4_uart_input_init:
    str x30, [sp, #-16]!
    ldr x0, =PI4_AUX_ENABLES
    mov w1, #1
    str w1, [x0]
    ldr x0, =PI4_AUX_MU_IER
    str wzr, [x0]
    ldr x0, =PI4_AUX_MU_LCR
    mov w1, #3
    str w1, [x0]
    ldr x0, =PI4_AUX_MU_CNTL
    mov w1, #3
    str w1, [x0]

    adr x0, pi4_uart_input_head
    strb wzr, [x0]
    adr x0, pi4_uart_input_tail
    strb wzr, [x0]
    adr x0, pi4_uart_input_esc_state
    strb wzr, [x0]
    adr x0, pi4_uart_input_mouse_phase
    strb wzr, [x0]
    adr x0, pi4_uart_input_mouse_byte0
    strb wzr, [x0]
    adr x0, pi4_uart_input_mouse_byte1
    strb wzr, [x0]
    adr x0, pi4_uart_input_total_events
    str xzr, [x0]
    adr x0, pi4_uart_input_polled_events
    str xzr, [x0]
    adr x0, pi4_uart_input_dropped_events
    str xzr, [x0]
    adr x0, pi4_uart_input_last_event
    strb wzr, [x0]
    adr x0, pi4_uart_input_last_device
    str xzr, [x0]
    adr x0, pi4_uart_input_last_type
    str xzr, [x0]
    adr x0, pi4_uart_input_last_code
    str xzr, [x0]
    adr x0, pi4_uart_input_select_1_events
    str xzr, [x0]
    adr x0, pi4_uart_input_select_2_events
    str xzr, [x0]
    adr x0, pi4_uart_input_enter_events
    str xzr, [x0]
    adr x0, pi4_uart_input_up_events
    str xzr, [x0]
    adr x0, pi4_uart_input_down_events
    str xzr, [x0]
    adr x0, pi4_input_keyboard_events
    str xzr, [x0]
    adr x0, pi4_input_keyboard_down_count
    str xzr, [x0]
    adr x0, pi4_input_keyboard_last_code
    str xzr, [x0]
    adr x0, pi4_input_keyboard_state
    mov x1, #8
.Linput_init_clear_keyboard_state:
    str xzr, [x0], #8
    subs x1, x1, #1
    b.ne .Linput_init_clear_keyboard_state
    adr x0, pi4_input_mouse_packet_count
    str xzr, [x0]
    adr x0, pi4_input_mouse_delta_x_total
    str xzr, [x0]
    adr x0, pi4_input_mouse_delta_y_total
    str xzr, [x0]
    adr x0, pi4_uart_input_mouse_buttons
    str xzr, [x0]
    adr x0, pi4_uart_input_mouse_delta_x
    str xzr, [x0]
    adr x0, pi4_uart_input_mouse_delta_y
    str xzr, [x0]
    bl pi4_usb_input_init
    ldr x30, [sp], #16
    ret
.size pi4_uart_input_init, . - pi4_uart_input_init

.type pi4_uart_input_poll, %function
pi4_uart_input_poll:
    str x30, [sp, #-16]!
    adr x0, pi4_uart_input_poll_calls
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    mov w9, #PI4_INPUT_EVENT_NONE

.Lpoll_read_next:
    ldr x0, =PI4_UART0_FR
    ldr w1, [x0]
    adr x2, pi4_uart_input_last_uart0_fr
    str x1, [x2]
    tbnz w1, #PI4_UART_FR_RXFE, .Lpoll_try_aux

    adr x2, pi4_uart_input_uart0_ready_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    ldr x0, =PI4_UART0_DR
    ldr w1, [x0]
    adr x2, pi4_uart_input_last_uart0_dr
    str x1, [x2]
    tst w1, #PI4_UART_DR_ERROR_MASK
    b.ne .Lpoll_rx_error
    and w1, w1, #PI4_UART_DR_DATA_MASK
    b .Lpoll_have_byte

.Lpoll_try_aux:
    ldr x0, =PI4_AUX_MU_LSR
    ldr w1, [x0]
    adr x2, pi4_uart_input_last_aux_lsr
    str x1, [x2]
    tbz w1, #PI4_AUX_MU_LSR_DATA_READY, .Lpoll_try_usb
    ldr x0, =PI4_AUX_MU_IO
    ldr w1, [x0]
    adr x2, pi4_uart_input_last_uart0_dr
    str x1, [x2]
    and w1, w1, #PI4_UART_DR_DATA_MASK

.Lpoll_have_byte:
    adr x2, pi4_uart_input_mouse_phase
    ldrb w3, [x2]
    cbnz w3, .Lpoll_mouse_active

    adr x2, pi4_uart_input_esc_state
    ldrb w3, [x2]
    cbnz w3, .Lpoll_escape_active

.Lpoll_translate_byte:
    cmp w1, #'1'
    b.eq .Lpoll_launch_1
    cmp w1, #'2'
    b.eq .Lpoll_launch_2
    cmp w1, #'\r'
    b.eq .Lpoll_enter
    cmp w1, #'\n'
    b.eq .Lpoll_enter
    cmp w1, #' '
    b.eq .Lpoll_enter
    cmp w1, #0x1b
    b.eq .Lpoll_escape_start
    cmp w1, #'a'
    b.eq .Lpoll_select_1
    cmp w1, #'A'
    b.eq .Lpoll_select_1
    cmp w1, #'d'
    b.eq .Lpoll_select_2
    cmp w1, #'D'
    b.eq .Lpoll_select_2
    cmp w1, #'w'
    b.eq .Lpoll_up
    cmp w1, #'W'
    b.eq .Lpoll_up
    cmp w1, #'s'
    b.eq .Lpoll_down
    cmp w1, #'S'
    b.eq .Lpoll_down
    b .Lpoll_maybe_mouse_start

.Lpoll_mouse_active:
    cmp w3, #1
    b.eq .Lpoll_mouse_byte1
    cmp w3, #2
    b.eq .Lpoll_mouse_byte2
    strb wzr, [x2]
    b .Lpoll_no_event

.Lpoll_mouse_byte1:
    tbnz w1, #6, .Lpoll_mouse_restart_or_drop
    adr x3, pi4_uart_input_mouse_byte1
    strb w1, [x3]
    mov w3, #2
    strb w3, [x2]
    b .Lpoll_no_event

.Lpoll_mouse_byte2:
    tbnz w1, #6, .Lpoll_mouse_restart_or_drop
    strb wzr, [x2]
    adr x3, pi4_uart_input_mouse_byte0
    ldrb w5, [x3]
    adr x3, pi4_uart_input_mouse_byte1
    ldrb w6, [x3]

    mov x7, xzr
    tbz w5, #5, .Lpoll_mouse_left_ready
    orr x7, x7, #1
.Lpoll_mouse_left_ready:
    tbz w5, #4, .Lpoll_mouse_buttons_ready
    orr x7, x7, #2
.Lpoll_mouse_buttons_ready:
    adr x3, pi4_uart_input_mouse_buttons
    str x7, [x3]

    and w7, w5, #0x03
    lsl w7, w7, #6
    and w8, w6, #0x3f
    orr w7, w7, w8
    lsl w7, w7, #24
    asr w7, w7, #24
    sxtw x7, w7
    adr x3, pi4_uart_input_mouse_delta_x
    str x7, [x3]

    and w7, w5, #0x0c
    lsl w7, w7, #4
    and w8, w1, #0x3f
    orr w7, w7, w8
    lsl w7, w7, #24
    asr w7, w7, #24
    sxtw x7, w7
    adr x3, pi4_uart_input_mouse_delta_y
    str x7, [x3]

    bl pi4_input_pack_mouse_event
    mov w1, w0
    b .Lpoll_enqueue_event

.Lpoll_mouse_restart_or_drop:
    strb wzr, [x2]
    b .Lpoll_maybe_mouse_start

.Lpoll_escape_active:
    cmp w3, #PI4_UART_INPUT_ESC_SEEN
    b.eq .Lpoll_escape_seen
    cmp w3, #PI4_UART_INPUT_ESC_CSI
    b.eq .Lpoll_escape_csi
    strb wzr, [x2]
    b .Lpoll_no_event

.Lpoll_escape_seen:
    cmp w1, #'['
    b.ne .Lpoll_escape_reset_translate
    mov w3, #PI4_UART_INPUT_ESC_CSI
    strb w3, [x2]
    b .Lpoll_no_event

.Lpoll_escape_csi:
    strb wzr, [x2]
    cmp w1, #'A'
    b.eq .Lpoll_up
    cmp w1, #'B'
    b.eq .Lpoll_down
    cmp w1, #'C'
    b.eq .Lpoll_select_2
    cmp w1, #'D'
    b.eq .Lpoll_select_1
    b .Lpoll_no_event

.Lpoll_select_1:
    mov w1, #PI4_INPUT_EVENT_SELECT_1
    b .Lpoll_enqueue_event

.Lpoll_select_2:
    mov w1, #PI4_INPUT_EVENT_SELECT_2
    b .Lpoll_enqueue_event

.Lpoll_enter:
    mov w1, #PI4_INPUT_EVENT_ENTER
    b .Lpoll_enqueue_event

.Lpoll_up:
    mov w1, #PI4_INPUT_EVENT_UP
    b .Lpoll_enqueue_event

.Lpoll_down:
    mov w1, #PI4_INPUT_EVENT_DOWN
    b .Lpoll_enqueue_event

.Lpoll_launch_1:
    mov w1, #PI4_INPUT_EVENT_LAUNCH_1
    b .Lpoll_enqueue_event

.Lpoll_launch_2:
    mov w1, #PI4_INPUT_EVENT_LAUNCH_2
    b .Lpoll_enqueue_event

.Lpoll_maybe_mouse_start:
    tbnz w1, #7, .Lpoll_no_event
    tbz w1, #6, .Lpoll_no_event
    adr x2, pi4_uart_input_mouse_byte0
    strb w1, [x2]
    adr x2, pi4_uart_input_mouse_phase
    mov w3, #1
    strb w3, [x2]
    b .Lpoll_no_event

.Lpoll_escape_start:
    mov w3, #PI4_UART_INPUT_ESC_SEEN
    strb w3, [x2]
    b .Lpoll_no_event

.Lpoll_escape_reset:
    strb wzr, [x2]
    b .Lpoll_no_event

.Lpoll_escape_reset_translate:
    strb wzr, [x2]
    b .Lpoll_translate_byte

.Lpoll_rx_error:
    adr x2, pi4_uart_input_uart0_error_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    ldr x0, =PI4_UART0_ECR
    str wzr, [x0]
    adr x0, pi4_uart_input_esc_state
    strb wzr, [x0]
    adr x0, pi4_uart_input_mouse_phase
    strb wzr, [x0]
    b .Lpoll_no_event

.Lpoll_enqueue_event:
    and w10, w1, #PI4_INPUT_EVENT_TOKEN_KIND_MASK
    adr x7, pi4_uart_input_total_events
    ldr x8, [x7]
    add x8, x8, #1
    str x8, [x7]
    adr x7, pi4_uart_input_last_event
    strb w10, [x7]
    tbnz w1, #31, .Lpoll_record_key_event
    cmp w10, #PI4_INPUT_EVENT_MOUSE_PACKET
    b.eq .Lpoll_record_mouse_event

.Lpoll_record_uart_event:
    adr x7, pi4_uart_input_last_device
    mov x8, #PI4_INPUT_DEVICE_UART
    str x8, [x7]
    adr x7, pi4_uart_input_last_type
    mov x8, #PI4_INPUT_EVENT_TYPE_UART
    str x8, [x7]
    adr x7, pi4_uart_input_last_code
    str x10, [x7]
    cmp w10, #PI4_INPUT_EVENT_SELECT_1
    b.eq .Lpoll_count_select_1
    cmp w10, #PI4_INPUT_EVENT_SELECT_2
    b.eq .Lpoll_count_select_2
    cmp w10, #PI4_INPUT_EVENT_LAUNCH_1
    b.eq .Lpoll_count_select_1
    cmp w10, #PI4_INPUT_EVENT_LAUNCH_2
    b.eq .Lpoll_count_select_2
    cmp w10, #PI4_INPUT_EVENT_ENTER
    b.eq .Lpoll_count_enter
    cmp w10, #PI4_INPUT_EVENT_UP
    b.eq .Lpoll_count_up
    cmp w10, #PI4_INPUT_EVENT_DOWN
    b.eq .Lpoll_count_down
    b .Lpoll_event_done

.Lpoll_record_key_event:
    adr x7, pi4_uart_input_last_device
    mov x8, #PI4_INPUT_DEVICE_KEYBOARD
    str x8, [x7]
    adr x7, pi4_uart_input_last_type
    mov x8, #PI4_INPUT_EVENT_TYPE_KEY
    str x8, [x7]
    and x8, x1, #PI4_INPUT_EVENT_TOKEN_KEY_CODE_MASK
    adr x7, pi4_uart_input_last_code
    str x8, [x7]
    adr x7, pi4_input_keyboard_events
    ldr x8, [x7]
    add x8, x8, #1
    str x8, [x7]
    and x8, x1, #PI4_INPUT_EVENT_TOKEN_KEY_CODE_MASK
    adr x7, pi4_input_keyboard_last_code
    str x8, [x7]
    cmp x8, #PI4_INPUT_KEY_PS2_1
    b.eq .Lpoll_key_count_select_1
    cmp x8, #PI4_INPUT_KEY_PS2_2
    b.eq .Lpoll_key_count_select_2
    cmp x8, #PI4_INPUT_KEY_PS2_ENTER
    b.eq .Lpoll_key_count_enter
    cmp x8, #PI4_INPUT_KEY_PS2_SPACE
    b.eq .Lpoll_key_count_enter
    cmp x8, #PI4_INPUT_KEY_PS2_W
    b.eq .Lpoll_key_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_UP
    b.eq .Lpoll_key_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_A
    b.eq .Lpoll_key_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_LEFT
    b.eq .Lpoll_key_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_S
    b.eq .Lpoll_key_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_DOWN
    b.eq .Lpoll_key_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_D
    b.eq .Lpoll_key_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_RIGHT
    b.eq .Lpoll_key_count_down
.Lpoll_key_count_done:
    ubfx x8, x1, #PI4_INPUT_EVENT_TOKEN_KEY_ACTION_SHIFT, #8
    cmp x8, #PI4_INPUT_KEY_PRESSED
    b.eq .Lpoll_record_key_down
    cmp x8, #PI4_INPUT_KEY_RELEASED
    b.eq .Lpoll_record_key_up
    b .Lpoll_event_done

.Lpoll_key_count_select_1:
    adr x7, pi4_uart_input_select_1_events
    b .Lpoll_key_increment_event_counter

.Lpoll_key_count_select_2:
    adr x7, pi4_uart_input_select_2_events
    b .Lpoll_key_increment_event_counter

.Lpoll_key_count_enter:
    adr x7, pi4_uart_input_enter_events
    b .Lpoll_key_increment_event_counter

.Lpoll_key_count_up:
    adr x7, pi4_uart_input_up_events
    b .Lpoll_key_increment_event_counter

.Lpoll_key_count_down:
    adr x7, pi4_uart_input_down_events

.Lpoll_key_increment_event_counter:
    ldr x11, [x7]
    add x11, x11, #1
    str x11, [x7]
    b .Lpoll_key_count_done

.Lpoll_record_key_down:
    and x0, x1, #PI4_INPUT_EVENT_TOKEN_KEY_CODE_MASK
    bl pi4_input_set_key_down
    adr x7, pi4_input_keyboard_down_count
    ldr x8, [x7]
    add x8, x8, #1
    str x8, [x7]
    adr x7, pi4_input_keyboard_last_code
    ldr x8, [x7]
    cmp x8, #PI4_INPUT_KEY_PS2_1
    b.eq .Lpoll_count_select_1
    cmp x8, #PI4_INPUT_KEY_PS2_2
    b.eq .Lpoll_count_select_2
    cmp x8, #PI4_INPUT_KEY_PS2_ENTER
    b.eq .Lpoll_count_enter
    cmp x8, #PI4_INPUT_KEY_PS2_SPACE
    b.eq .Lpoll_count_enter
    cmp x8, #PI4_INPUT_KEY_PS2_W
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_UP
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_A
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_LEFT
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_S
    b.eq .Lpoll_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_DOWN
    b.eq .Lpoll_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_D
    b.eq .Lpoll_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_RIGHT
    b.eq .Lpoll_count_down
    b .Lpoll_event_done

.Lpoll_record_key_up:
    and x0, x1, #PI4_INPUT_EVENT_TOKEN_KEY_CODE_MASK
    bl pi4_input_set_key_up
    adr x7, pi4_input_keyboard_down_count
    ldr x8, [x7]
    cbz x8, .Lpoll_record_key_up_semantic
    sub x8, x8, #1
    str x8, [x7]
.Lpoll_record_key_up_semantic:
    adr x7, pi4_input_keyboard_last_code
    ldr x8, [x7]
    cmp x8, #PI4_INPUT_KEY_PS2_1
    b.eq .Lpoll_count_select_1
    cmp x8, #PI4_INPUT_KEY_PS2_2
    b.eq .Lpoll_count_select_2
    cmp x8, #PI4_INPUT_KEY_PS2_ENTER
    b.eq .Lpoll_count_enter
    cmp x8, #PI4_INPUT_KEY_PS2_SPACE
    b.eq .Lpoll_count_enter
    cmp x8, #PI4_INPUT_KEY_PS2_W
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_UP
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_A
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_LEFT
    b.eq .Lpoll_count_up
    cmp x8, #PI4_INPUT_KEY_PS2_S
    b.eq .Lpoll_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_DOWN
    b.eq .Lpoll_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_D
    b.eq .Lpoll_count_down
    cmp x8, #PI4_INPUT_KEY_PS2_RIGHT
    b.eq .Lpoll_count_down
    b .Lpoll_event_done

.Lpoll_record_mouse_event:
    adr x7, pi4_uart_input_last_device
    mov x8, #PI4_INPUT_DEVICE_MOUSE
    str x8, [x7]
    adr x7, pi4_uart_input_last_type
    mov x8, #PI4_INPUT_EVENT_TYPE_MOUSE_PACKET
    str x8, [x7]
    lsr x8, x1, #PI4_INPUT_EVENT_TOKEN_MOUSE_BUTTONS_SHIFT
    and x8, x8, #0xff
    adr x7, pi4_uart_input_last_code
    str x8, [x7]
    tst x8, #1
    b.eq .Lpoll_mouse_no_left_press
    adr x7, pi4_uart_input_enter_events
    ldr x11, [x7]
    add x11, x11, #1
    str x11, [x7]
.Lpoll_mouse_no_left_press:
    adr x7, pi4_input_mouse_packet_count
    ldr x8, [x7]
    add x8, x8, #1
    str x8, [x7]
    lsr x8, x1, #PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_X_SHIFT
    sxtb x8, w8
    adr x7, pi4_input_mouse_delta_x_total
    ldr x11, [x7]
    add x11, x11, x8
    str x11, [x7]
    lsr x8, x1, #PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_Y_SHIFT
    sxtb x8, w8
    adr x7, pi4_input_mouse_delta_y_total
    ldr x11, [x7]
    add x11, x11, x8
    str x11, [x7]
    b .Lpoll_event_done

.Lpoll_count_select_1:
    adr x7, pi4_uart_input_select_1_events
    b .Lpoll_increment_event_counter

.Lpoll_count_select_2:
    adr x7, pi4_uart_input_select_2_events
    b .Lpoll_increment_event_counter

.Lpoll_count_enter:
    adr x7, pi4_uart_input_enter_events
    b .Lpoll_increment_event_counter

.Lpoll_count_up:
    adr x7, pi4_uart_input_up_events
    b .Lpoll_increment_event_counter

.Lpoll_count_down:
    adr x7, pi4_uart_input_down_events

.Lpoll_increment_event_counter:
    ldr x8, [x7]
    add x8, x8, #1
    str x8, [x7]

.Lpoll_event_done:
    adr x2, pi4_uart_input_head
    adr x3, pi4_uart_input_tail
    ldrb w4, [x2]
    ldrb w5, [x3]
    add w6, w4, #1
    and w6, w6, #PI4_UART_INPUT_QUEUE_MASK
    cmp w6, w5
    b.eq .Lpoll_drop_event
    adr x7, pi4_uart_input_queue
    str x1, [x7, x4, lsl #3]
    strb w6, [x2]
    mov w9, #1
    b .Lpoll_read_next

.Lpoll_drop_event:
    adr x7, pi4_uart_input_dropped_events
    ldr x8, [x7]
    add x8, x8, #1
    str x8, [x7]
    b .Lpoll_no_event

.Lpoll_no_event:
    b .Lpoll_read_next

.Lpoll_try_usb:
    sub sp, sp, #16
    str x9, [sp]
    bl pi4_usb_input_poll
    ldr x9, [sp]
    add sp, sp, #16
    cbz w0, .Lpoll_done
    mov w1, w0
    b .Lpoll_enqueue_event

.Lpoll_done:
    mov w0, w9
    ldr x30, [sp], #16
    ret
.size pi4_uart_input_poll, . - pi4_uart_input_poll

.type pi4_usb_input_init, %function
pi4_usb_input_init:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    adr x0, pi4_usb_ready
    strb wzr, [x0]
    adr x0, pi4_usb_last_key
    strb wzr, [x0]
    adr x0, pi4_usb_last_mouse_buttons
    strb wzr, [x0]
    adr x0, pi4_usb_device_kind
    strb wzr, [x0]
    adr x0, pi4_usb_probe_device_kind
    strb wzr, [x0]
    adr x0, pi4_usb_probe_device_class
    strb wzr, [x0]
    adr x0, pi4_usb_ready_caps
    strb wzr, [x0]
    adr x0, pi4_usb_keyboard_ready
    strb wzr, [x0]
    adr x0, pi4_usb_mouse_ready
    strb wzr, [x0]
    adr x0, pi4_usb_config_value
    mov w1, #1
    strb w1, [x0]
    adr x0, pi4_usb_hid_interface_num
    strb wzr, [x0]
    adr x0, pi4_usb_hid_ep_num
    mov w1, #1
    strb w1, [x0]
    adr x0, pi4_usb_hid_mps
    mov w1, #PI4_USB_HID_MPS
    strb w1, [x0]
    adr x0, pi4_usb_hid_report_bytes
    mov w1, #PI4_USB_HID_REPORT_MAX
    strb w1, [x0]
    adr x0, pi4_usb_hid_next_pid
    mov w1, #PI4_DWC2_PID_DATA0
    strb w1, [x0]
    adr x0, pi4_usb_keyboard_interface_num
    strb wzr, [x0]
    adr x0, pi4_usb_mouse_interface_num
    strb wzr, [x0]
    adr x0, pi4_usb_keyboard_addr
    mov w1, #PI4_USB_DEVICE_HID
    strb w1, [x0]
    adr x0, pi4_usb_mouse_addr
    strb w1, [x0]
    adr x0, pi4_usb_hub_ports
    strb wzr, [x0]
    adr x0, pi4_usb_addr0_ep0_mps
    mov w1, #PI4_USB_EP0_MPS_DEFAULT
    strb w1, [x0]
    adr x0, pi4_usb_addr1_ep0_mps
    strb w1, [x0]
    adr x0, pi4_usb_addr2_ep0_mps
    strb w1, [x0]
    adr x0, pi4_usb_addr3_ep0_mps
    strb w1, [x0]
    adr x0, pi4_usb_keyboard_ep_num
    mov w1, #1
    strb w1, [x0]
    adr x0, pi4_usb_mouse_ep_num
    mov w1, #1
    strb w1, [x0]
    adr x0, pi4_usb_keyboard_mps
    mov w1, #PI4_USB_HID_MPS
    strb w1, [x0]
    adr x0, pi4_usb_mouse_mps
    mov w1, #PI4_USB_HID_MPS
    strb w1, [x0]
    adr x0, pi4_usb_keyboard_report_bytes
    mov w1, #PI4_USB_HID_REPORT_MAX
    strb w1, [x0]
    adr x0, pi4_usb_mouse_report_bytes
    mov w1, #PI4_USB_HID_MOUSE_REPORT_BYTES
    strb w1, [x0]
    adr x0, pi4_usb_keyboard_next_pid
    mov w1, #PI4_DWC2_PID_DATA0
    strb w1, [x0]
    adr x0, pi4_usb_mouse_next_pid
    mov w1, #PI4_DWC2_PID_DATA0
    strb w1, [x0]
    adr x0, pi4_usb_pending_key_token
    str xzr, [x0]
    adr x0, pi4_usb_pending_head
    strb wzr, [x0]
    adr x0, pi4_usb_pending_tail
    strb wzr, [x0]
    adr x0, pi4_usb_pending_queue
    mov x1, #PI4_USB_PENDING_QUEUE_SIZE
.Lusb_init_clear_pending_queue:
    str xzr, [x0], #8
    subs x1, x1, #1
    b.ne .Lusb_init_clear_pending_queue
    adr x0, pi4_usb_keyboard_mods
    strb wzr, [x0]
    adr x0, pi4_usb_keyboard_keys
    str xzr, [x0]
    adr x0, pi4_usb_status_stage
    strb wzr, [x0]

    ldr x0, =PI4_DWC2_GUSBCFG
    ldr w1, [x0]
    mov w2, #1
    lsl w2, w2, #PI4_DWC2_GUSBCFG_FORCEHOSTMODE
    orr w1, w1, w2
    str w1, [x0]

    ldr x0, =PI4_DWC2_GAHBCFG
    ldr w1, [x0]
    mov w2, #1
    lsl w2, w2, #PI4_DWC2_GAHBCFG_DMA_EN
    orr w1, w1, w2
    str w1, [x0]

    ldr x0, =PI4_DWC2_HCFG
    str wzr, [x0]

    adr x0, pi4_usb_status_stage
    mov w1, #PI4_USB_STATUS_HOST
    strb w1, [x0]

    ldr x0, =PI4_DWC2_HPRT0
    ldr w1, [x0]
    tbz w1, #PI4_DWC2_HPRT0_CONNSTS, .Lusb_init_done
    adr x3, pi4_usb_status_stage
    mov w4, #PI4_USB_STATUS_PORT
    strb w4, [x3]
    mov w2, #1
    lsl w2, w2, #PI4_DWC2_HPRT0_PWR
    orr w1, w1, w2
    mov w2, #1
    lsl w2, w2, #PI4_DWC2_HPRT0_RST
    orr w1, w1, w2
    str w1, [x0]
    mov x2, #0x4000
.Lusb_reset_delay:
    subs x2, x2, #1
    b.ne .Lusb_reset_delay

    ldr w1, [x0]
    mov w2, #1
    lsl w2, w2, #PI4_DWC2_HPRT0_RST
    bic w1, w1, w2
    mov w2, #1
    lsl w2, w2, #PI4_DWC2_HPRT0_PWR
    orr w1, w1, w2
    str w1, [x0]
    mov x2, #0x4000
.Lusb_enable_delay:
    subs x2, x2, #1
    b.ne .Lusb_enable_delay

    ldr w1, [x0]
    tbz w1, #PI4_DWC2_HPRT0_ENA, .Lusb_init_done

    mov x0, #PI4_USB_DEVICE_ADDR_DEFAULT
    bl pi4_usb_probe_device_descriptor
    cbz w0, .Lusb_init_done
    adr x0, pi4_usb_probe_device_class
    ldrb w20, [x0]

    mov w0, #PI4_USB_DEVICE_ADDR_HUB
    bl pi4_usb_assign_default_address
    cbz w0, .Lusb_init_done
    adr x0, pi4_usb_status_stage
    mov w1, #PI4_USB_STATUS_ADDR
    strb w1, [x0]

    cmp w20, #PI4_USB_DEVICE_CLASS_HUB
    b.ne .Lusb_probe_direct_hid

    bl pi4_usb_enumerate_hub
    cbz w0, .Lusb_probe_stage_done
    adr x0, pi4_usb_status_stage
    mov w1, #PI4_USB_STATUS_HID
    strb w1, [x0]
    b .Lusb_probe_stage_done

.Lusb_probe_direct_hid:
    mov x0, #PI4_USB_DEVICE_ADDR_HUB
    bl pi4_usb_probe_hid_kind
    cbz w0, .Lusb_probe_stage_done
    mov x0, #PI4_USB_DEVICE_ADDR_HUB
    bl pi4_usb_set_config_for_addr
    cbz w0, .Lusb_init_done
    bl pi4_usb_configure_hid_interfaces
    cbz w0, .Lusb_init_done

    adr x0, pi4_usb_status_stage
    mov w1, #PI4_USB_STATUS_HID
    strb w1, [x0]

.Lusb_probe_stage_done:
    adr x0, pi4_usb_ready
    ldrb w1, [x0]
    cbz w1, .Lusb_init_done
    adr x0, pi4_usb_status_stage
    mov w1, #PI4_USB_STATUS_HID
    strb w1, [x0]

.Lusb_init_done:
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_input_init, . - pi4_usb_input_init

.type pi4_usb_configure_hid_interfaces, %function
pi4_usb_configure_hid_interfaces:
    str x30, [sp, #-16]!
    str x19, [sp, #-16]!
    mov x19, xzr

    adr x0, pi4_usb_keyboard_ready
    ldrb w0, [x0]
    cbz w0, .Lusb_configure_mouse

    adr x5, pi4_usb_keyboard_addr
    ldrb w0, [x5]
    cbnz w0, .Lusb_configure_keyboard_addr_ready
    mov w0, #PI4_USB_DEVICE_HID
.Lusb_configure_keyboard_addr_ready:
    mov x1, #0x21
    mov x2, #0x0b
    mov x3, #0
    adr x5, pi4_usb_keyboard_interface_num
    ldrb w4, [x5]
    bl pi4_usb_control_no_data

    adr x5, pi4_usb_keyboard_addr
    ldrb w0, [x5]
    cbnz w0, .Lusb_configure_keyboard_idle_addr_ready
    mov w0, #PI4_USB_DEVICE_HID
.Lusb_configure_keyboard_idle_addr_ready:
    mov x1, #0x21
    mov x2, #0x0a
    mov x3, #0
    adr x5, pi4_usb_keyboard_interface_num
    ldrb w4, [x5]
    bl pi4_usb_control_no_data
    orr x19, x19, #PI4_USB_HID_CAP_KEYBOARD
    b .Lusb_configure_mouse

.Lusb_configure_keyboard_fail:
    adr x0, pi4_usb_keyboard_ready
    strb wzr, [x0]

.Lusb_configure_mouse:
    adr x0, pi4_usb_mouse_ready
    ldrb w0, [x0]
    cbz w0, .Lusb_configure_done

    adr x5, pi4_usb_mouse_addr
    ldrb w0, [x5]
    cbnz w0, .Lusb_configure_mouse_addr_ready
    mov w0, #PI4_USB_DEVICE_HID
.Lusb_configure_mouse_addr_ready:
    mov x1, #0x21
    mov x2, #0x0b
    mov x3, #0
    adr x5, pi4_usb_mouse_interface_num
    ldrb w4, [x5]
    bl pi4_usb_control_no_data

    adr x5, pi4_usb_mouse_addr
    ldrb w0, [x5]
    cbnz w0, .Lusb_configure_mouse_idle_addr_ready
    mov w0, #PI4_USB_DEVICE_HID
.Lusb_configure_mouse_idle_addr_ready:
    mov x1, #0x21
    mov x2, #0x0a
    mov x3, #0
    adr x5, pi4_usb_mouse_interface_num
    ldrb w4, [x5]
    bl pi4_usb_control_no_data
    orr x19, x19, #PI4_USB_HID_CAP_MOUSE
    b .Lusb_configure_done

.Lusb_configure_mouse_fail:
    adr x0, pi4_usb_mouse_ready
    strb wzr, [x0]

.Lusb_configure_done:
    bl pi4_usb_refresh_hid_ready
    mov x0, x19
    ldr x19, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_configure_hid_interfaces, . - pi4_usb_configure_hid_interfaces

.type pi4_usb_refresh_hid_ready, %function
pi4_usb_refresh_hid_ready:
    adr x0, pi4_usb_keyboard_ready
    ldrb w1, [x0]
    adr x0, pi4_usb_mouse_ready
    ldrb w2, [x0]
    mov w3, wzr
    cbz w1, .Lusb_refresh_caps_mouse
    orr w3, w3, #PI4_USB_HID_CAP_KEYBOARD
.Lusb_refresh_caps_mouse:
    cbz w2, .Lusb_refresh_caps_done
    orr w3, w3, #PI4_USB_HID_CAP_MOUSE
.Lusb_refresh_caps_done:
    adr x0, pi4_usb_ready_caps
    strb w3, [x0]
    adr x0, pi4_usb_ready
    cmp w3, #0
    cset w4, ne
    strb w4, [x0]

    cbz w1, .Lusb_refresh_try_mouse_legacy
    adr x0, pi4_usb_device_kind
    mov w4, #PI4_USB_DEVICE_KIND_KEYBOARD
    strb w4, [x0]
    adr x0, pi4_usb_keyboard_interface_num
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_interface_num
    strb w4, [x0]
    adr x0, pi4_usb_keyboard_ep_num
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_ep_num
    strb w4, [x0]
    adr x0, pi4_usb_keyboard_mps
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_mps
    strb w4, [x0]
    adr x0, pi4_usb_keyboard_report_bytes
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_report_bytes
    strb w4, [x0]
    adr x0, pi4_usb_keyboard_next_pid
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_next_pid
    strb w4, [x0]
    ret

.Lusb_refresh_try_mouse_legacy:
    cbz w2, .Lusb_refresh_unknown_legacy
    adr x0, pi4_usb_device_kind
    mov w4, #PI4_USB_DEVICE_KIND_MOUSE
    strb w4, [x0]
    adr x0, pi4_usb_mouse_interface_num
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_interface_num
    strb w4, [x0]
    adr x0, pi4_usb_mouse_ep_num
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_ep_num
    strb w4, [x0]
    adr x0, pi4_usb_mouse_mps
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_mps
    strb w4, [x0]
    adr x0, pi4_usb_mouse_report_bytes
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_report_bytes
    strb w4, [x0]
    adr x0, pi4_usb_mouse_next_pid
    ldrb w4, [x0]
    adr x0, pi4_usb_hid_next_pid
    strb w4, [x0]
    ret

.Lusb_refresh_unknown_legacy:
    adr x0, pi4_usb_device_kind
    strb wzr, [x0]
    ret
.size pi4_usb_refresh_hid_ready, . - pi4_usb_refresh_hid_ready

.type pi4_usb_control_ep0_mps, %function
pi4_usb_control_ep0_mps:
    and w0, w0, #0xff
    cmp w0, #0
    b.eq .Lusb_ep0_mps_addr0
    cmp w0, #1
    b.eq .Lusb_ep0_mps_addr1
    cmp w0, #2
    b.eq .Lusb_ep0_mps_addr2
    cmp w0, #3
    b.eq .Lusb_ep0_mps_addr3
    mov w0, #PI4_USB_EP0_MPS_DEFAULT
    ret
.Lusb_ep0_mps_addr0:
    adr x1, pi4_usb_addr0_ep0_mps
    b .Lusb_ep0_mps_load
.Lusb_ep0_mps_addr1:
    adr x1, pi4_usb_addr1_ep0_mps
    b .Lusb_ep0_mps_load
.Lusb_ep0_mps_addr2:
    adr x1, pi4_usb_addr2_ep0_mps
    b .Lusb_ep0_mps_load
.Lusb_ep0_mps_addr3:
    adr x1, pi4_usb_addr3_ep0_mps
.Lusb_ep0_mps_load:
    ldrb w0, [x1]
    cbnz w0, .Lusb_ep0_mps_done
    mov w0, #PI4_USB_EP0_MPS_DEFAULT
.Lusb_ep0_mps_done:
    ret
.size pi4_usb_control_ep0_mps, . - pi4_usb_control_ep0_mps

.type pi4_usb_store_addr_ep0_mps, %function
pi4_usb_store_addr_ep0_mps:
    and w0, w0, #0xff
    and w1, w1, #0xff
    cbnz w1, .Lusb_store_ep0_mps_nonzero
    mov w1, #PI4_USB_EP0_MPS_DEFAULT
.Lusb_store_ep0_mps_nonzero:
    cmp w1, #PI4_USB_EP0_MPS_DEFAULT
    b.hs .Lusb_store_ep0_mps_min_ready
    mov w1, #PI4_USB_EP0_MPS_DEFAULT
.Lusb_store_ep0_mps_min_ready:
    cmp w1, #PI4_USB_EP0_MPS
    b.ls .Lusb_store_ep0_mps_max_ready
    mov w1, #PI4_USB_EP0_MPS
.Lusb_store_ep0_mps_max_ready:
    cmp w0, #0
    b.eq .Lusb_store_ep0_mps_addr0
    cmp w0, #1
    b.eq .Lusb_store_ep0_mps_addr1
    cmp w0, #2
    b.eq .Lusb_store_ep0_mps_addr2
    cmp w0, #3
    b.eq .Lusb_store_ep0_mps_addr3
    ret
.Lusb_store_ep0_mps_addr0:
    adr x2, pi4_usb_addr0_ep0_mps
    b .Lusb_store_ep0_mps_write
.Lusb_store_ep0_mps_addr1:
    adr x2, pi4_usb_addr1_ep0_mps
    b .Lusb_store_ep0_mps_write
.Lusb_store_ep0_mps_addr2:
    adr x2, pi4_usb_addr2_ep0_mps
    b .Lusb_store_ep0_mps_write
.Lusb_store_ep0_mps_addr3:
    adr x2, pi4_usb_addr3_ep0_mps
.Lusb_store_ep0_mps_write:
    strb w1, [x2]
    ret
.size pi4_usb_store_addr_ep0_mps, . - pi4_usb_store_addr_ep0_mps

.type pi4_usb_reset_default_ep0_mps, %function
pi4_usb_reset_default_ep0_mps:
    adr x0, pi4_usb_addr0_ep0_mps
    mov w1, #PI4_USB_EP0_MPS_DEFAULT
    strb w1, [x0]
    ret
.size pi4_usb_reset_default_ep0_mps, . - pi4_usb_reset_default_ep0_mps

.type pi4_usb_copy_default_ep0_mps_to_addr, %function
pi4_usb_copy_default_ep0_mps_to_addr:
    str x30, [sp, #-16]!
    mov w2, w0
    adr x1, pi4_usb_addr0_ep0_mps
    ldrb w1, [x1]
    mov w0, w2
    bl pi4_usb_store_addr_ep0_mps
    ldr x30, [sp], #16
    ret
.size pi4_usb_copy_default_ep0_mps_to_addr, . - pi4_usb_copy_default_ep0_mps_to_addr

.type pi4_usb_assign_default_address, %function
pi4_usb_assign_default_address:
    str x30, [sp, #-16]!
    str x19, [sp, #-16]!
    mov w19, w0
    mov x0, #PI4_USB_DEVICE_ADDR_DEFAULT
    mov x1, #0
    mov x2, #5
    mov x3, x19
    mov x4, #0
    bl pi4_usb_control_no_data
    cbz w0, .Lusb_assign_default_done
    mov w0, w19
    bl pi4_usb_copy_default_ep0_mps_to_addr
    mov x2, #0x4000
.Lusb_assign_address_delay:
    subs x2, x2, #1
    b.ne .Lusb_assign_address_delay
    mov w0, #1
.Lusb_assign_default_done:
    ldr x19, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_assign_default_address, . - pi4_usb_assign_default_address

.type pi4_usb_set_config_for_addr, %function
pi4_usb_set_config_for_addr:
    str x30, [sp, #-16]!
    str x19, [sp, #-16]!
    mov x19, x0
    adr x5, pi4_usb_config_value
    ldrb w3, [x5]
    cbnz w3, .Lusb_set_config_for_addr_value_ready
    mov w3, #1
.Lusb_set_config_for_addr_value_ready:
    mov x0, x19
    mov x1, #0
    mov x2, #9
    mov x4, #0
    bl pi4_usb_control_no_data
    ldr x19, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_set_config_for_addr, . - pi4_usb_set_config_for_addr

.type pi4_usb_probe_device_descriptor, %function
pi4_usb_probe_device_descriptor:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    mov x19, x0
    adr x20, pi4_usb_device_descriptor
    mov x0, x20
    mov x1, #3
.Lusb_probe_device_clear:
    str xzr, [x0], #8
    subs x1, x1, #1
    b.ne .Lusb_probe_device_clear

    mov x0, x19
    mov x1, #0x80
    mov x2, #6
    mov x3, #0x0100
    mov x4, #0
    mov x5, #8
    mov x6, x20
    bl pi4_usb_control_in
    cbz w0, .Lusb_probe_device_fail

    ldrb w1, [x20, #1]
    cmp w1, #PI4_USB_DESCRIPTOR_TYPE_DEVICE
    b.ne .Lusb_probe_device_fail
    ldrb w1, [x20, #4]
    adr x2, pi4_usb_probe_device_class
    strb w1, [x2]
    ldrb w1, [x20, #7]
    cbnz w1, .Lusb_probe_device_mps_ready
    mov w1, #PI4_USB_EP0_MPS_DEFAULT
.Lusb_probe_device_mps_ready:
    mov w0, w19
    bl pi4_usb_store_addr_ep0_mps
    mov w0, #1
    b .Lusb_probe_device_done

.Lusb_probe_device_fail:
    adr x0, pi4_usb_probe_device_class
    strb wzr, [x0]
    mov w0, #0

.Lusb_probe_device_done:
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_probe_device_descriptor, . - pi4_usb_probe_device_descriptor

.type pi4_usb_probe_hub_descriptor, %function
pi4_usb_probe_hub_descriptor:
    str x30, [sp, #-16]!
    adr x6, pi4_usb_hub_descriptor
    mov x0, x6
    mov x1, #2
.Lusb_probe_hub_clear:
    str xzr, [x0], #8
    subs x1, x1, #1
    b.ne .Lusb_probe_hub_clear

    mov x0, #PI4_USB_DEVICE_ADDR_HUB
    mov x1, #0xa0
    mov x2, #6
    mov x3, #0x2900
    mov x4, #0
    mov x5, #PI4_USB_HUB_DESCRIPTOR_BYTES
    adr x6, pi4_usb_hub_descriptor
    bl pi4_usb_control_in
    cbz w0, .Lusb_probe_hub_default_ports
    adr x1, pi4_usb_hub_descriptor
    ldrb w2, [x1, #2]
    cbnz w2, .Lusb_probe_hub_ports_nonzero
.Lusb_probe_hub_default_ports:
    mov w2, #PI4_USB_HUB_MAX_PORTS
.Lusb_probe_hub_ports_nonzero:
    cmp w2, #PI4_USB_HUB_MAX_PORTS
    b.ls .Lusb_probe_hub_ports_ready
    mov w2, #PI4_USB_HUB_MAX_PORTS
.Lusb_probe_hub_ports_ready:
    adr x1, pi4_usb_hub_ports
    strb w2, [x1]
    mov w0, #1
    ldr x30, [sp], #16
    ret
.size pi4_usb_probe_hub_descriptor, . - pi4_usb_probe_hub_descriptor

.type pi4_usb_hub_set_port_feature, %function
pi4_usb_hub_set_port_feature:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    mov x19, x0
    mov x20, x1
    mov x0, #PI4_USB_DEVICE_ADDR_HUB
    mov x1, #0x23
    mov x2, #PI4_USB_HUB_REQ_SET_FEATURE
    mov x3, x20
    mov x4, x19
    bl pi4_usb_control_no_data
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_hub_set_port_feature, . - pi4_usb_hub_set_port_feature

.type pi4_usb_hub_get_port_status, %function
pi4_usb_hub_get_port_status:
    str x30, [sp, #-16]!
    str x19, [sp, #-16]!
    mov x19, x0
    adr x6, pi4_usb_hub_port_status
    str wzr, [x6]
    mov x0, #PI4_USB_DEVICE_ADDR_HUB
    mov x1, #0xa3
    mov x2, #PI4_USB_HUB_REQ_GET_STATUS
    mov x3, #0
    mov x4, x19
    mov x5, #4
    adr x6, pi4_usb_hub_port_status
    bl pi4_usb_control_in
    ldr x19, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_hub_get_port_status, . - pi4_usb_hub_get_port_status

.type pi4_usb_enumerate_hub, %function
pi4_usb_enumerate_hub:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23, [sp, #-16]!
    mov x0, #PI4_USB_DEVICE_ADDR_HUB
    bl pi4_usb_set_config_for_addr
    cbz w0, .Lusb_enumerate_hub_fail

    bl pi4_usb_probe_hub_descriptor
    adr x0, pi4_usb_hub_ports
    ldrb w20, [x0]
    cbnz w20, .Lusb_enumerate_hub_ports_ready
    mov w20, #PI4_USB_HUB_MAX_PORTS
.Lusb_enumerate_hub_ports_ready:
    mov x19, #1
.Lusb_enumerate_hub_power_loop:
    cmp x19, x20
    b.hi .Lusb_enumerate_hub_power_done
    mov x0, x19
    mov x1, #PI4_USB_HUB_FEATURE_PORT_POWER
    bl pi4_usb_hub_set_port_feature
    add x19, x19, #1
    b .Lusb_enumerate_hub_power_loop
.Lusb_enumerate_hub_power_done:
    mov x2, #0x4000
.Lusb_enumerate_hub_power_delay:
    subs x2, x2, #1
    b.ne .Lusb_enumerate_hub_power_delay

    mov x19, #1
    mov x21, #PI4_USB_DEVICE_ADDR_HID0
.Lusb_enumerate_hub_port_loop:
    cmp x19, x20
    b.hi .Lusb_enumerate_hub_configure
    cmp x21, #PI4_USB_DEVICE_ADDR_HID1
    b.hi .Lusb_enumerate_hub_configure

    mov x0, x19
    bl pi4_usb_hub_get_port_status
    cbz w0, .Lusb_enumerate_hub_next_port
    adr x0, pi4_usb_hub_port_status
    ldr w22, [x0]
    tbz w22, #PI4_USB_HUB_PORT_CONNECTION, .Lusb_enumerate_hub_next_port

    mov x0, x19
    mov x1, #PI4_USB_HUB_FEATURE_PORT_RESET
    bl pi4_usb_hub_set_port_feature
    cbz w0, .Lusb_enumerate_hub_next_port
    mov x2, #0x4000
.Lusb_enumerate_hub_reset_delay:
    subs x2, x2, #1
    b.ne .Lusb_enumerate_hub_reset_delay

    mov x23, #4
.Lusb_enumerate_hub_enable_retry:
    mov x0, x19
    bl pi4_usb_hub_get_port_status
    cbz w0, .Lusb_enumerate_hub_enable_wait
    adr x0, pi4_usb_hub_port_status
    ldr w22, [x0]
    tbnz w22, #PI4_USB_HUB_PORT_ENABLE, .Lusb_enumerate_hub_port_enabled
.Lusb_enumerate_hub_enable_wait:
    mov x2, #0x1000
.Lusb_enumerate_hub_enable_delay:
    subs x2, x2, #1
    b.ne .Lusb_enumerate_hub_enable_delay
    subs x23, x23, #1
    b.ne .Lusb_enumerate_hub_enable_retry
    b .Lusb_enumerate_hub_next_port

.Lusb_enumerate_hub_port_enabled:

    bl pi4_usb_reset_default_ep0_mps
    mov x0, #PI4_USB_DEVICE_ADDR_DEFAULT
    bl pi4_usb_probe_device_descriptor
    cbz w0, .Lusb_enumerate_hub_next_port

    mov w0, w21
    bl pi4_usb_assign_default_address
    cbz w0, .Lusb_enumerate_hub_next_port

    adr x0, pi4_usb_probe_device_class
    ldrb w0, [x0]
    cmp w0, #PI4_USB_DEVICE_CLASS_HUB
    b.eq .Lusb_enumerate_hub_assigned_next

    mov x0, x21
    bl pi4_usb_probe_hid_kind
    cbz w0, .Lusb_enumerate_hub_assigned_next
    mov x0, x21
    bl pi4_usb_set_config_for_addr

.Lusb_enumerate_hub_assigned_next:
    add x21, x21, #1

.Lusb_enumerate_hub_next_port:
    add x19, x19, #1
    b .Lusb_enumerate_hub_port_loop

.Lusb_enumerate_hub_configure:
    bl pi4_usb_configure_hid_interfaces
    b .Lusb_enumerate_hub_done

.Lusb_enumerate_hub_fail:
    mov w0, #0

.Lusb_enumerate_hub_done:
    ldr x23, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_enumerate_hub, . - pi4_usb_enumerate_hub

.type pi4_usb_control_no_data, %function
pi4_usb_control_no_data:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    mov x19, x0
    adr x20, pi4_usb_setup_packet
    strb w1, [x20]
    strb w2, [x20, #1]
    strh w3, [x20, #2]
    strh w4, [x20, #4]
    strh wzr, [x20, #6]
    mov x0, x19
    bl pi4_usb_control_ep0_mps
    mov w21, w0

    mov x0, x19
    mov x1, #0
    mov x2, #0
    mov x3, #PI4_DWC2_EPTYPE_CONTROL
    mov x4, x21
    mov x5, #PI4_DWC2_PID_SETUP
    mov x6, #8
    mov x7, x20
    bl pi4_usb_hc_transfer
    tbz w0, #PI4_DWC2_HCINT_XFERCOMPL, .Lusb_control_fail

    mov x0, x19
    mov x1, #0
    mov x2, #1
    mov x3, #PI4_DWC2_EPTYPE_CONTROL
    mov x4, x21
    mov x5, #PI4_DWC2_PID_DATA1
    mov x6, #0
    mov x7, x20
    bl pi4_usb_hc_transfer
    tbz w0, #PI4_DWC2_HCINT_XFERCOMPL, .Lusb_control_fail

    mov w0, #1
    b .Lusb_control_done

.Lusb_control_fail:
    mov w0, #0

.Lusb_control_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_control_no_data, . - pi4_usb_control_no_data

.type pi4_usb_control_in, %function
pi4_usb_control_in:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23, [sp, #-16]!
    mov x19, x0
    mov x20, x5
    mov x21, x6
    adr x22, pi4_usb_setup_packet
    strb w1, [x22]
    strb w2, [x22, #1]
    strh w3, [x22, #2]
    strh w4, [x22, #4]
    strh w5, [x22, #6]
    mov x0, x19
    bl pi4_usb_control_ep0_mps
    mov w23, w0

    mov x0, x19
    mov x1, #0
    mov x2, #0
    mov x3, #PI4_DWC2_EPTYPE_CONTROL
    mov x4, x23
    mov x5, #PI4_DWC2_PID_SETUP
    mov x6, #8
    mov x7, x22
    bl pi4_usb_hc_transfer
    tbz w0, #PI4_DWC2_HCINT_XFERCOMPL, .Lusb_control_in_fail

    mov x0, x19
    mov x1, #0
    mov x2, #1
    mov x3, #PI4_DWC2_EPTYPE_CONTROL
    mov x4, x23
    mov x5, #PI4_DWC2_PID_DATA1
    mov x6, x20
    mov x7, x21
    bl pi4_usb_hc_transfer
    tbz w0, #PI4_DWC2_HCINT_XFERCOMPL, .Lusb_control_in_fail

    mov x0, x19
    mov x1, #0
    mov x2, #0
    mov x3, #PI4_DWC2_EPTYPE_CONTROL
    mov x4, x23
    mov x5, #PI4_DWC2_PID_DATA1
    mov x6, #0
    mov x7, x22
    bl pi4_usb_hc_transfer
    tbz w0, #PI4_DWC2_HCINT_XFERCOMPL, .Lusb_control_in_fail

    mov w0, #1
    b .Lusb_control_in_done

.Lusb_control_in_fail:
    mov w0, #0

.Lusb_control_in_done:
    ldr x23, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_control_in, . - pi4_usb_control_in

.type pi4_usb_probe_hid_kind, %function
pi4_usb_probe_hid_kind:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    mov x21, x0
    mov w22, #0
    adr x0, pi4_usb_probe_device_kind
    strb wzr, [x0]
    adr x0, pi4_usb_config_value
    mov w1, #1
    strb w1, [x0]
    adr x19, pi4_usb_config_descriptor
    mov x0, x19
    mov x1, #(PI4_USB_CONFIG_DESCRIPTOR_BYTES / 8)
.Lusb_probe_clear_descriptor:
    str xzr, [x0], #8
    subs x1, x1, #1
    b.ne .Lusb_probe_clear_descriptor

    mov x0, x21
    mov x1, #0x80
    mov x2, #6
    mov x3, #0x0200
    mov x4, #0
    mov x5, #9
    mov x6, x19
    bl pi4_usb_control_in
    cbz w0, .Lusb_probe_unknown

    ldrb w8, [x19]
    cmp w8, #9
    b.lo .Lusb_probe_unknown
    ldrb w8, [x19, #1]
    cmp w8, #PI4_USB_DESCRIPTOR_TYPE_CONFIGURATION
    b.ne .Lusb_probe_unknown
    ldrb w12, [x19, #5]
    cbz w12, .Lusb_probe_keep_default_config
    adr x13, pi4_usb_config_value
    strb w12, [x13]
.Lusb_probe_keep_default_config:
    ldrb w8, [x19, #2]
    ldrb w9, [x19, #3]
    orr w8, w8, w9, lsl #8
    mov w9, #PI4_USB_CONFIG_DESCRIPTOR_BYTES
    cmp w8, w9
    csel w8, w8, w9, lo
    cmp w8, #9
    b.hs .Lusb_probe_length_ready
    mov w8, #9
.Lusb_probe_length_ready:
    uxtw x20, w8

    mov x0, x21
    mov x1, #0x80
    mov x2, #6
    mov x3, #0x0200
    mov x4, #0
    mov x5, x20
    mov x6, x19
    bl pi4_usb_control_in
    cbz w0, .Lusb_probe_unknown

    ldrb w2, [x19]
    cmp w2, #9
    b.lo .Lusb_probe_unknown
    ldrb w2, [x19, #1]
    cmp w2, #PI4_USB_DESCRIPTOR_TYPE_CONFIGURATION
    b.ne .Lusb_probe_unknown

    add x20, x19, x20
    mov x10, x19
    mov w11, #PI4_USB_DEVICE_KIND_UNKNOWN
.Lusb_probe_next_descriptor:
    add x7, x10, #2
    cmp x7, x20
    b.hi .Lusb_probe_finish
    ldrb w2, [x10]
    cmp w2, #2
    b.lo .Lusb_probe_finish
    add x7, x10, x2
    cmp x7, x20
    b.hi .Lusb_probe_finish
    ldrb w3, [x10, #1]
    cmp w3, #PI4_USB_DESCRIPTOR_TYPE_INTERFACE
    b.eq .Lusb_probe_interface
    cmp w3, #PI4_USB_DESCRIPTOR_TYPE_ENDPOINT
    b.eq .Lusb_probe_endpoint
    b .Lusb_probe_advance

.Lusb_probe_interface:
    mov w11, #PI4_USB_DEVICE_KIND_UNKNOWN
    cmp w2, #8
    b.lo .Lusb_probe_advance
    ldrb w4, [x10, #5]
    cmp w4, #PI4_USB_HID_INTERFACE_CLASS
    b.ne .Lusb_probe_advance
    ldrb w4, [x10, #6]
    cmp w4, #PI4_USB_HID_BOOT_SUBCLASS
    b.ne .Lusb_probe_advance
    ldrb w4, [x10, #7]
    cmp w4, #PI4_USB_HID_BOOT_KEYBOARD
    b.eq .Lusb_probe_keyboard
    cmp w4, #PI4_USB_HID_BOOT_MOUSE
    b.eq .Lusb_probe_mouse
    b .Lusb_probe_advance

.Lusb_probe_endpoint:
    cbz w11, .Lusb_probe_advance
    cmp w2, #7
    b.lo .Lusb_probe_advance
    ldrb w4, [x10, #2]
    tbz w4, #7, .Lusb_probe_advance
    ldrb w5, [x10, #3]
    and w5, w5, #PI4_USB_ENDPOINT_TRANSFER_MASK
    cmp w5, #PI4_USB_ENDPOINT_TRANSFER_INTERRUPT
    b.ne .Lusb_probe_advance
    and w4, w4, #PI4_USB_ENDPOINT_NUMBER_MASK
    cbz w4, .Lusb_probe_advance
    cmp w11, #PI4_USB_DEVICE_KIND_KEYBOARD
    b.eq .Lusb_probe_keyboard_endpoint
    cmp w11, #PI4_USB_DEVICE_KIND_MOUSE
    b.eq .Lusb_probe_mouse_endpoint
    b .Lusb_probe_advance

.Lusb_probe_keyboard_endpoint:
    adr x5, pi4_usb_keyboard_ep_num
    strb w4, [x5]
    ldrb w5, [x10, #4]
    ldrb w6, [x10, #5]
    orr w5, w5, w6, lsl #8
    and w5, w5, #0x7ff
    cbz w5, .Lusb_probe_keyboard_endpoint_ready
    mov w6, #PI4_USB_ENDPOINT_MPS_MAX
    cmp w5, w6
    csel w5, w5, w6, lo
    adr x6, pi4_usb_keyboard_mps
    strb w5, [x6]
    mov w6, #PI4_USB_HID_REPORT_MAX
    cmp w5, w6
    csel w5, w5, w6, lo
    adr x6, pi4_usb_keyboard_report_bytes
    strb w5, [x6]
.Lusb_probe_keyboard_endpoint_ready:
    adr x5, pi4_usb_keyboard_ready
    mov w6, #1
    strb w6, [x5]
    adr x5, pi4_usb_keyboard_addr
    strb w21, [x5]
    orr w22, w22, #PI4_USB_HID_CAP_KEYBOARD
    b .Lusb_probe_advance

.Lusb_probe_mouse_endpoint:
    adr x5, pi4_usb_mouse_ep_num
    strb w4, [x5]
    ldrb w5, [x10, #4]
    ldrb w6, [x10, #5]
    orr w5, w5, w6, lsl #8
    and w5, w5, #0x7ff
    cbz w5, .Lusb_probe_mouse_endpoint_ready
    mov w6, #PI4_USB_ENDPOINT_MPS_MAX
    cmp w5, w6
    csel w5, w5, w6, lo
    adr x6, pi4_usb_mouse_mps
    strb w5, [x6]
    mov w6, #PI4_USB_HID_MOUSE_REPORT_BYTES
    cmp w5, w6
    csel w5, w5, w6, lo
    adr x6, pi4_usb_mouse_report_bytes
    strb w5, [x6]
.Lusb_probe_mouse_endpoint_ready:
    adr x5, pi4_usb_mouse_ready
    mov w6, #1
    strb w6, [x5]
    adr x5, pi4_usb_mouse_addr
    strb w21, [x5]
    orr w22, w22, #PI4_USB_HID_CAP_MOUSE
    b .Lusb_probe_advance

.Lusb_probe_advance:
    add x10, x10, x2
    b .Lusb_probe_next_descriptor

.Lusb_probe_keyboard:
    mov w11, #PI4_USB_DEVICE_KIND_KEYBOARD
    ldrb w5, [x10, #2]
    adr x6, pi4_usb_keyboard_interface_num
    strb w5, [x6]
    adr x0, pi4_usb_probe_device_kind
    mov w1, #PI4_USB_DEVICE_KIND_KEYBOARD
    strb w1, [x0]
    b .Lusb_probe_advance

.Lusb_probe_mouse:
    mov w11, #PI4_USB_DEVICE_KIND_MOUSE
    ldrb w5, [x10, #2]
    adr x6, pi4_usb_mouse_interface_num
    strb w5, [x6]
    adr x0, pi4_usb_probe_device_kind
    mov w1, #PI4_USB_DEVICE_KIND_MOUSE
    strb w1, [x0]
    b .Lusb_probe_advance

.Lusb_probe_unknown:
    adr x0, pi4_usb_probe_device_kind
    ldrb w0, [x0]
    cbnz w0, .Lusb_probe_default_endpoint
    mov w0, #0
    b .Lusb_probe_done

.Lusb_probe_finish:
    cbnz w22, .Lusb_probe_refresh_success
    adr x0, pi4_usb_probe_device_kind
    ldrb w0, [x0]
    cbz w0, .Lusb_probe_unknown

.Lusb_probe_default_endpoint:
    cmp w0, #PI4_USB_DEVICE_KIND_KEYBOARD
    b.eq .Lusb_probe_default_keyboard
    cmp w0, #PI4_USB_DEVICE_KIND_MOUSE
    b.eq .Lusb_probe_default_mouse
    mov w0, #0
    b .Lusb_probe_done

.Lusb_probe_default_keyboard:
    adr x1, pi4_usb_keyboard_ready
    mov w2, #1
    strb w2, [x1]
    adr x1, pi4_usb_keyboard_addr
    strb w21, [x1]
    orr w22, w22, #PI4_USB_HID_CAP_KEYBOARD
    b .Lusb_probe_refresh_success

.Lusb_probe_default_mouse:
    adr x1, pi4_usb_mouse_ready
    mov w2, #1
    strb w2, [x1]
    adr x1, pi4_usb_mouse_addr
    strb w21, [x1]
    orr w22, w22, #PI4_USB_HID_CAP_MOUSE

.Lusb_probe_refresh_success:
    bl pi4_usb_refresh_hid_ready
    mov w0, #1

.Lusb_probe_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_probe_hid_kind, . - pi4_usb_probe_hid_kind

.type pi4_usb_input_poll, %function
pi4_usb_input_poll:
    str x30, [sp, #-16]!
    adr x0, pi4_usb_ready
    ldrb w0, [x0]
    cbz w0, .Lusb_poll_none

    adr x0, pi4_usb_pending_key_token
    ldr x1, [x0]
    cbnz x1, .Lusb_poll_pending_key
    bl pi4_usb_pending_pop
    cbnz x0, .Lusb_poll_done

    mov w0, #PI4_USB_DEVICE_KIND_KEYBOARD
    bl pi4_usb_poll_hid_kind
    cbnz x0, .Lusb_poll_done
    mov w0, #PI4_USB_DEVICE_KIND_MOUSE
    bl pi4_usb_poll_hid_kind
    cbnz x0, .Lusb_poll_done
    bl pi4_usb_pending_pop
    b .Lusb_poll_done

.Lusb_poll_none:
    mov w0, #PI4_INPUT_EVENT_NONE
    b .Lusb_poll_done

.Lusb_poll_pending_key:
    str xzr, [x0]
    mov x0, x1

.Lusb_poll_done:
    ldr x30, [sp], #16
    ret
.size pi4_usb_input_poll, . - pi4_usb_input_poll

.type pi4_usb_poll_hid_kind, %function
pi4_usb_poll_hid_kind:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23, [sp, #-16]!
    mov w19, w0
    cmp w19, #PI4_USB_DEVICE_KIND_KEYBOARD
    b.eq .Lusb_poll_kind_keyboard
    cmp w19, #PI4_USB_DEVICE_KIND_MOUSE
    b.eq .Lusb_poll_kind_mouse
    b .Lusb_poll_kind_none

.Lusb_poll_kind_keyboard:
    adr x8, pi4_usb_keyboard_ready
    ldrb w8, [x8]
    cbz w8, .Lusb_poll_kind_none
    adr x8, pi4_usb_keyboard_addr
    ldrb w21, [x8]
    cbnz w21, .Lusb_poll_kind_keyboard_addr_ready
    mov w21, #PI4_USB_DEVICE_HID
.Lusb_poll_kind_keyboard_addr_ready:
    adr x8, pi4_usb_keyboard_interface_num
    ldrb w23, [x8]
    adr x8, pi4_usb_keyboard_ep_num
    ldrb w1, [x8]
    adr x8, pi4_usb_keyboard_mps
    ldrb w4, [x8]
    adr x20, pi4_usb_keyboard_next_pid
    ldrb w5, [x20]
    adr x8, pi4_usb_keyboard_report_bytes
    ldrb w6, [x8]
    mov w22, w6
    b .Lusb_poll_kind_transfer

.Lusb_poll_kind_mouse:
    adr x8, pi4_usb_mouse_ready
    ldrb w8, [x8]
    cbz w8, .Lusb_poll_kind_none
    adr x8, pi4_usb_mouse_addr
    ldrb w21, [x8]
    cbnz w21, .Lusb_poll_kind_mouse_addr_ready
    mov w21, #PI4_USB_DEVICE_HID
.Lusb_poll_kind_mouse_addr_ready:
    adr x8, pi4_usb_mouse_interface_num
    ldrb w23, [x8]
    adr x8, pi4_usb_mouse_ep_num
    ldrb w1, [x8]
    adr x8, pi4_usb_mouse_mps
    ldrb w4, [x8]
    adr x20, pi4_usb_mouse_next_pid
    ldrb w5, [x20]
    adr x8, pi4_usb_mouse_report_bytes
    ldrb w6, [x8]
    mov w22, w6

.Lusb_poll_kind_transfer:
    cbnz w1, .Lusb_poll_kind_endpoint_ready
    mov w1, #1
.Lusb_poll_kind_endpoint_ready:
    cbnz w4, .Lusb_poll_kind_mps_ready
    mov w4, #PI4_USB_HID_MPS
.Lusb_poll_kind_mps_ready:
    mov w8, #PI4_USB_ENDPOINT_MPS_MAX
    cmp w4, w8
    csel w4, w4, w8, lo
    cbnz w6, .Lusb_poll_kind_report_len_ready
    mov w6, #PI4_USB_HID_REPORT_MAX
.Lusb_poll_kind_report_len_ready:
    mov w8, #PI4_USB_HID_REPORT_MAX
    cmp w6, w8
    csel w6, w6, w8, lo
    mov w22, w6
    adr x7, pi4_usb_hid_report
    str xzr, [x7]
    mov x0, x21
    mov x2, #1
    mov x3, #PI4_DWC2_EPTYPE_INTERRUPT
    bl pi4_usb_hc_transfer
    tbz w0, #PI4_DWC2_HCINT_XFERCOMPL, .Lusb_poll_kind_control_fallback
    ldrb w9, [x20]
    eor w9, w9, #PI4_DWC2_PID_DATA1
    strb w9, [x20]
    adr x8, pi4_usb_device_kind
    ldrb w10, [x8]
    cmp w19, w10
    b.ne .Lusb_poll_kind_translate
    adr x8, pi4_usb_hid_next_pid
    strb w9, [x8]
.Lusb_poll_kind_translate:
    mov w0, w19
    bl pi4_usb_translate_hid_report
    cbnz x0, .Lusb_poll_kind_done
    b .Lusb_poll_kind_control_fallback

.Lusb_poll_kind_control_fallback:
    adr x6, pi4_usb_hid_report
    str xzr, [x6]
    mov x0, x21
    mov x1, #0xa1
    mov x2, #1
    mov x3, #0x0100
    mov x4, x23
    mov x5, x22
    bl pi4_usb_control_in
    cbz w0, .Lusb_poll_kind_none
    mov w0, w19
    bl pi4_usb_translate_hid_report
    b .Lusb_poll_kind_done

.Lusb_poll_kind_none:
    mov w0, #PI4_INPUT_EVENT_NONE

.Lusb_poll_kind_done:
    ldr x23, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_poll_hid_kind, . - pi4_usb_poll_hid_kind

.type pi4_usb_pending_push, %function
pi4_usb_pending_push:
    cbz x0, .Lusb_pending_push_drop
    adr x1, pi4_usb_pending_head
    adr x2, pi4_usb_pending_tail
    ldrb w3, [x1]
    ldrb w4, [x2]
    add w5, w3, #1
    and w5, w5, #PI4_USB_PENDING_QUEUE_MASK
    cmp w5, w4
    b.eq .Lusb_pending_push_drop
    adr x6, pi4_usb_pending_queue
    str x0, [x6, x3, lsl #3]
    strb w5, [x1]
    mov w0, #1
    ret
.Lusb_pending_push_drop:
    mov w0, #0
    ret
.size pi4_usb_pending_push, . - pi4_usb_pending_push

.type pi4_usb_pending_pop, %function
pi4_usb_pending_pop:
    adr x1, pi4_usb_pending_head
    adr x2, pi4_usb_pending_tail
    ldrb w3, [x1]
    ldrb w4, [x2]
    cmp w3, w4
    b.eq .Lusb_pending_pop_empty
    adr x5, pi4_usb_pending_queue
    ldr x0, [x5, x4, lsl #3]
    str xzr, [x5, x4, lsl #3]
    add w4, w4, #1
    and w4, w4, #PI4_USB_PENDING_QUEUE_MASK
    strb w4, [x2]
    ret
.Lusb_pending_pop_empty:
    mov w0, #PI4_INPUT_EVENT_NONE
    ret
.size pi4_usb_pending_pop, . - pi4_usb_pending_pop

.type pi4_usb_translate_hid_report, %function
pi4_usb_translate_hid_report:
    str x30, [sp, #-16]!
    and w0, w0, #0xff
    cbnz w0, .Lusb_translate_hid_store_kind
    adr x1, pi4_usb_device_kind
    ldrb w0, [x1]
    cbnz w0, .Lusb_translate_hid_kind_ready
    adr x2, pi4_usb_probe_device_kind
    ldrb w0, [x2]
    cbz w0, .Lusb_translate_hid_classify
    strb w0, [x1]
    b .Lusb_translate_hid_kind_ready
.Lusb_translate_hid_classify:
    bl pi4_usb_classify_hid_report
    cbz w0, .Lusb_translate_hid_none
.Lusb_translate_hid_store_kind:
    adr x1, pi4_usb_device_kind
    strb w0, [x1]
.Lusb_translate_hid_kind_ready:
    cmp w0, #PI4_USB_DEVICE_KIND_MOUSE
    b.eq .Lusb_translate_hid_mouse
    cmp w0, #PI4_USB_DEVICE_KIND_KEYBOARD
    b.eq .Lusb_translate_hid_keyboard
.Lusb_translate_hid_none:
    mov w0, #PI4_INPUT_EVENT_NONE
    ldr x30, [sp], #16
    ret
.Lusb_translate_hid_mouse:
    ldr x30, [sp], #16
    b pi4_usb_translate_mouse_report
.Lusb_translate_hid_keyboard:
    ldr x30, [sp], #16
    b pi4_usb_translate_keyboard_report
.size pi4_usb_translate_hid_report, . - pi4_usb_translate_hid_report

.type pi4_usb_classify_hid_report, %function
pi4_usb_classify_hid_report:
    adr x1, pi4_usb_hid_report
    ldrb w2, [x1]
    ldrb w3, [x1, #1]
    ldrb w4, [x1, #2]
    cbnz w3, .Lusb_classify_mouse
    cbnz w4, .Lusb_classify_keyboard
    ldrb w4, [x1, #3]
    cbnz w4, .Lusb_classify_keyboard
    ldrb w4, [x1, #4]
    cbnz w4, .Lusb_classify_keyboard
    ldrb w4, [x1, #5]
    cbnz w4, .Lusb_classify_keyboard
    ldrb w4, [x1, #6]
    cbnz w4, .Lusb_classify_keyboard
    ldrb w4, [x1, #7]
    cbnz w4, .Lusb_classify_keyboard
    and w4, w2, #0xf8
    cbnz w4, .Lusb_classify_keyboard
    and w4, w2, #0x07
    cbnz w4, .Lusb_classify_mouse
    mov w0, #PI4_USB_DEVICE_KIND_UNKNOWN
    ret

.Lusb_classify_keyboard:
    adr x1, pi4_usb_device_kind
    mov w0, #PI4_USB_DEVICE_KIND_KEYBOARD
    strb w0, [x1]
    ret

.Lusb_classify_mouse:
    adr x1, pi4_usb_device_kind
    mov w0, #PI4_USB_DEVICE_KIND_MOUSE
    strb w0, [x1]
    ret
.size pi4_usb_classify_hid_report, . - pi4_usb_classify_hid_report

.type pi4_usb_translate_keyboard_report, %function
pi4_usb_translate_keyboard_report:
    str x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    str x25, [sp, #-16]!
    adr x19, pi4_usb_hid_report
    adr x20, pi4_usb_keyboard_keys
    adr x17, pi4_usb_keyboard_mods

    ldrb w21, [x17]
    ldrb w22, [x19]

    mov w23, w21
    bic w23, w23, w22
    mov x24, #0
.Lusb_key_modifier_release_loop:
    tbz w23, #0, .Lusb_key_modifier_release_next
    add w0, w24, #0xe0
    mov w1, #PI4_INPUT_KEY_RELEASED
    bl pi4_usb_enqueue_key_change
.Lusb_key_modifier_release_next:
    lsr w23, w23, #1
    add x24, x24, #1
    cmp x24, #8
    b.lo .Lusb_key_modifier_release_loop

    mov x24, #0
.Lusb_key_release_loop:
    ldrb w0, [x20, x24]
    cbz w0, .Lusb_key_release_next
    add x1, x19, #2
    bl pi4_usb_key_in_report
    cbnz w0, .Lusb_key_release_next
    ldrb w0, [x20, x24]
    mov w1, #PI4_INPUT_KEY_RELEASED
    bl pi4_usb_enqueue_key_change
.Lusb_key_release_next:
    add x24, x24, #1
    cmp x24, #6
    b.lo .Lusb_key_release_loop

    mov w23, w22
    bic w23, w23, w21
    mov x24, #0
.Lusb_key_modifier_press_loop:
    tbz w23, #0, .Lusb_key_modifier_press_next
    add w0, w24, #0xe0
    mov w1, #PI4_INPUT_KEY_PRESSED
    bl pi4_usb_enqueue_key_change
.Lusb_key_modifier_press_next:
    lsr w23, w23, #1
    add x24, x24, #1
    cmp x24, #8
    b.lo .Lusb_key_modifier_press_loop

    mov x24, #0
.Lusb_key_press_loop:
    add x25, x19, #2
    ldrb w0, [x25, x24]
    cbz w0, .Lusb_key_press_next
    mov x1, x20
    bl pi4_usb_key_in_report
    cbnz w0, .Lusb_key_press_next
    add x25, x19, #2
    ldrb w0, [x25, x24]
    mov w1, #PI4_INPUT_KEY_PRESSED
    bl pi4_usb_enqueue_key_change
.Lusb_key_press_next:
    add x24, x24, #1
    cmp x24, #6
    b.lo .Lusb_key_press_loop

    strb w22, [x17]
    ldr x0, [x19]
    lsr x0, x0, #16
    str x0, [x20]
    bl pi4_usb_pending_pop

.Lusb_key_done:
    ldr x25, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldr x30, [sp], #16
    ret
.size pi4_usb_translate_keyboard_report, . - pi4_usb_translate_keyboard_report

.type pi4_usb_key_in_report, %function
pi4_usb_key_in_report:
    cbz w0, .Lusb_key_in_report_no
    mov x2, #6
.Lusb_key_in_report_next:
    ldrb w3, [x1], #1
    cmp w3, w0
    b.eq .Lusb_key_in_report_yes
    subs x2, x2, #1
    b.ne .Lusb_key_in_report_next
.Lusb_key_in_report_no:
    mov w0, #0
    ret
.Lusb_key_in_report_yes:
    mov w0, #1
    ret
.size pi4_usb_key_in_report, . - pi4_usb_key_in_report

.type pi4_usb_enqueue_key_change, %function
pi4_usb_enqueue_key_change:
    str x30, [sp, #-16]!
    mov w2, w0
    bl pi4_usb_make_key_token
    cbz w0, .Lusb_enqueue_key_done
    adr x3, pi4_usb_last_key
    strb w2, [x3]
    bl pi4_usb_pending_push
.Lusb_enqueue_key_done:
    ldr x30, [sp], #16
    ret
.size pi4_usb_enqueue_key_change, . - pi4_usb_enqueue_key_change

.type pi4_usb_make_key_token, %function
pi4_usb_make_key_token:
    str x30, [sp, #-16]!
    mov w2, w0
    mov w3, w1
    bl pi4_usb_hid_to_ps2
    cbz w0, .Lusb_make_key_none
    mov w9, w0
    mov w0, #1
    lsl w0, w0, #31
    and w2, w2, #0xff
    orr w0, w0, w2, lsl #PI4_INPUT_EVENT_TOKEN_KEY_HID_SHIFT
    and w3, w3, #0xff
    orr w0, w0, w3, lsl #PI4_INPUT_EVENT_TOKEN_KEY_ACTION_SHIFT
    orr w0, w0, w9
    ldr x30, [sp], #16
    ret
.Lusb_make_key_none:
    mov w0, #PI4_INPUT_EVENT_NONE
    ldr x30, [sp], #16
    ret
.size pi4_usb_make_key_token, . - pi4_usb_make_key_token

.type pi4_usb_hid_to_ps2, %function
pi4_usb_hid_to_ps2:
    cmp w0, #0x29
    b.eq .Lusb_hid_ps2_escape
    cmp w0, #0x1e
    b.eq .Lusb_hid_ps2_1
    cmp w0, #0x59
    b.eq .Lusb_hid_ps2_1
    cmp w0, #0x1f
    b.eq .Lusb_hid_ps2_2
    cmp w0, #0x5a
    b.eq .Lusb_hid_ps2_2
    cmp w0, #0x20
    b.eq .Lusb_hid_ps2_3
    cmp w0, #0x21
    b.eq .Lusb_hid_ps2_4
    cmp w0, #0x22
    b.eq .Lusb_hid_ps2_5
    cmp w0, #0x23
    b.eq .Lusb_hid_ps2_6
    cmp w0, #0x24
    b.eq .Lusb_hid_ps2_7
    cmp w0, #0x04
    b.eq .Lusb_hid_ps2_a
    cmp w0, #0x07
    b.eq .Lusb_hid_ps2_d
    cmp w0, #0x08
    b.eq .Lusb_hid_ps2_e
    cmp w0, #0x14
    b.eq .Lusb_hid_ps2_q
    cmp w0, #0x1a
    b.eq .Lusb_hid_ps2_w
    cmp w0, #0x16
    b.eq .Lusb_hid_ps2_s
    cmp w0, #0x28
    b.eq .Lusb_hid_ps2_enter
    cmp w0, #0x58
    b.eq .Lusb_hid_ps2_enter
    cmp w0, #0x2a
    b.eq .Lusb_hid_ps2_backspace
    cmp w0, #0x2b
    b.eq .Lusb_hid_ps2_tab
    cmp w0, #0x2c
    b.eq .Lusb_hid_ps2_space
    cmp w0, #0x50
    b.eq .Lusb_hid_ps2_left
    cmp w0, #0x4f
    b.eq .Lusb_hid_ps2_right
    cmp w0, #0x52
    b.eq .Lusb_hid_ps2_up
    cmp w0, #0x51
    b.eq .Lusb_hid_ps2_down
    cmp w0, #0xe0
    b.eq .Lusb_hid_ps2_left_ctrl
    cmp w0, #0xe1
    b.eq .Lusb_hid_ps2_left_shift
    cmp w0, #0xe2
    b.eq .Lusb_hid_ps2_left_alt
    cmp w0, #0xe4
    b.eq .Lusb_hid_ps2_right_ctrl
    cmp w0, #0xe5
    b.eq .Lusb_hid_ps2_right_shift
    cmp w0, #0xe6
    b.eq .Lusb_hid_ps2_right_alt
    mov w0, #0
    ret
.Lusb_hid_ps2_escape:
    mov w0, #PI4_INPUT_KEY_PS2_ESCAPE
    ret
.Lusb_hid_ps2_1:
    mov w0, #PI4_INPUT_KEY_PS2_1
    ret
.Lusb_hid_ps2_2:
    mov w0, #PI4_INPUT_KEY_PS2_2
    ret
.Lusb_hid_ps2_3:
    mov w0, #PI4_INPUT_KEY_PS2_3
    ret
.Lusb_hid_ps2_4:
    mov w0, #PI4_INPUT_KEY_PS2_4
    ret
.Lusb_hid_ps2_5:
    mov w0, #PI4_INPUT_KEY_PS2_5
    ret
.Lusb_hid_ps2_6:
    mov w0, #PI4_INPUT_KEY_PS2_6
    ret
.Lusb_hid_ps2_7:
    mov w0, #PI4_INPUT_KEY_PS2_7
    ret
.Lusb_hid_ps2_a:
    mov w0, #PI4_INPUT_KEY_PS2_A
    ret
.Lusb_hid_ps2_d:
    mov w0, #PI4_INPUT_KEY_PS2_D
    ret
.Lusb_hid_ps2_e:
    mov w0, #PI4_INPUT_KEY_PS2_E
    ret
.Lusb_hid_ps2_q:
    mov w0, #PI4_INPUT_KEY_PS2_Q
    ret
.Lusb_hid_ps2_w:
    mov w0, #PI4_INPUT_KEY_PS2_W
    ret
.Lusb_hid_ps2_s:
    mov w0, #PI4_INPUT_KEY_PS2_S
    ret
.Lusb_hid_ps2_enter:
    mov w0, #PI4_INPUT_KEY_PS2_ENTER
    ret
.Lusb_hid_ps2_backspace:
    mov w0, #PI4_INPUT_KEY_PS2_BACKSPACE
    ret
.Lusb_hid_ps2_tab:
    mov w0, #PI4_INPUT_KEY_PS2_TAB
    ret
.Lusb_hid_ps2_space:
    mov w0, #PI4_INPUT_KEY_PS2_SPACE
    ret
.Lusb_hid_ps2_left:
    mov w0, #PI4_INPUT_KEY_PS2_LEFT
    ret
.Lusb_hid_ps2_right:
    mov w0, #PI4_INPUT_KEY_PS2_RIGHT
    ret
.Lusb_hid_ps2_up:
    mov w0, #PI4_INPUT_KEY_PS2_UP
    ret
.Lusb_hid_ps2_down:
    mov w0, #PI4_INPUT_KEY_PS2_DOWN
    ret
.Lusb_hid_ps2_left_ctrl:
    mov w0, #PI4_INPUT_KEY_PS2_LEFT_CTRL
    ret
.Lusb_hid_ps2_left_shift:
    mov w0, #PI4_INPUT_KEY_PS2_LEFT_SHIFT
    ret
.Lusb_hid_ps2_left_alt:
    mov w0, #PI4_INPUT_KEY_PS2_LEFT_ALT
    ret
.Lusb_hid_ps2_right_ctrl:
    mov w0, #PI4_INPUT_KEY_PS2_RIGHT_CTRL
    ret
.Lusb_hid_ps2_right_shift:
    mov w0, #PI4_INPUT_KEY_PS2_RIGHT_SHIFT
    ret
.Lusb_hid_ps2_right_alt:
    mov w0, #PI4_INPUT_KEY_PS2_RIGHT_ALT
    ret
.size pi4_usb_hid_to_ps2, . - pi4_usb_hid_to_ps2

.type pi4_usb_translate_mouse_report, %function
pi4_usb_translate_mouse_report:
    adr x1, pi4_usb_hid_report
    ldrb w2, [x1]
    and w2, w2, #0x07
    ldrsb x3, [x1, #1]
    ldrsb x4, [x1, #2]
    adr x5, pi4_usb_last_mouse_buttons
    ldrb w6, [x5]
    cmp w2, w6
    b.ne .Lusb_mouse_report_event
    cbnz x3, .Lusb_mouse_report_event
    cbnz x4, .Lusb_mouse_report_event
    mov w0, #PI4_INPUT_EVENT_NONE
    ret

.Lusb_mouse_report_event:
    strb w2, [x5]
    adr x5, pi4_uart_input_mouse_buttons
    str x2, [x5]
    adr x5, pi4_uart_input_mouse_delta_x
    str x3, [x5]
    adr x5, pi4_uart_input_mouse_delta_y
    str x4, [x5]
    b pi4_input_pack_mouse_event
    ret
.size pi4_usb_translate_mouse_report, . - pi4_usb_translate_mouse_report

.type pi4_input_pack_mouse_event, %function
pi4_input_pack_mouse_event:
    adr x5, pi4_uart_input_mouse_buttons
    ldr x0, [x5]
    and x0, x0, #0xff
    adr x5, pi4_uart_input_mouse_delta_x
    ldr x1, [x5]
    and x1, x1, #0xff
    adr x5, pi4_uart_input_mouse_delta_y
    ldr x2, [x5]
    and x2, x2, #0xff
    mov x3, #PI4_INPUT_EVENT_MOUSE_PACKET
    orr x0, x3, x0, lsl #PI4_INPUT_EVENT_TOKEN_MOUSE_BUTTONS_SHIFT
    orr x0, x0, x1, lsl #PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_X_SHIFT
    orr x0, x0, x2, lsl #PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_Y_SHIFT
    ret
.size pi4_input_pack_mouse_event, . - pi4_input_pack_mouse_event

.type pi4_input_set_key_down, %function
pi4_input_set_key_down:
    and x0, x0, #0xff
    lsr x1, x0, #6
    and x2, x0, #63
    mov x3, #1
    lsl x3, x3, x2
    adr x4, pi4_input_keyboard_state
    ldr x5, [x4, x1, lsl #3]
    orr x5, x5, x3
    str x5, [x4, x1, lsl #3]
    ret
.size pi4_input_set_key_down, . - pi4_input_set_key_down

.type pi4_input_set_key_up, %function
pi4_input_set_key_up:
    and x0, x0, #0xff
    lsr x1, x0, #6
    and x2, x0, #63
    mov x3, #1
    lsl x3, x3, x2
    adr x4, pi4_input_keyboard_state
    ldr x5, [x4, x1, lsl #3]
    bic x5, x5, x3
    str x5, [x4, x1, lsl #3]
    ret
.size pi4_input_set_key_up, . - pi4_input_set_key_up

.type pi4_input_key_state_test, %function
pi4_input_key_state_test:
    and x0, x0, #0xff
    lsr x1, x0, #6
    and x2, x0, #63
    mov x3, #1
    lsl x3, x3, x2
    adr x4, pi4_input_keyboard_state
    ldr x5, [x4, x1, lsl #3]
    tst x5, x3
    cset x0, ne
    ret
.size pi4_input_key_state_test, . - pi4_input_key_state_test

.type pi4_usb_hc_transfer, %function
pi4_usb_hc_transfer:
    ldr x8, =PI4_DWC2_HCCHAR0
    str wzr, [x8]
    ldr x8, =PI4_DWC2_HCSPLT0
    str wzr, [x8]
    mov w9, #0x3fff
    ldr x8, =PI4_DWC2_HCINT0
    str w9, [x8]
    ldr x8, =PI4_DWC2_HCINTMSK0
    str w9, [x8]

    ldr x8, =PI4_DWC2_HCDMA0
    str w7, [x8]

    cbnz x6, .Lusb_hctsiz_len
    mov x10, #1
    b .Lusb_hctsiz_ready
.Lusb_hctsiz_len:
    add x10, x6, x4
    sub x10, x10, #1
    udiv x10, x10, x4
.Lusb_hctsiz_ready:
    mov w11, w6
    lsl w12, w10, #PI4_DWC2_HCTSIZ_PKTCNT_SHIFT
    orr w11, w11, w12
    lsl w12, w5, #PI4_DWC2_HCTSIZ_PID_SHIFT
    orr w11, w11, w12
    ldr x8, =PI4_DWC2_HCTSIZ0
    str w11, [x8]

    mov w11, w4
    lsl w12, w1, #PI4_DWC2_HCCHAR_EPNUM_SHIFT
    orr w11, w11, w12
    cbz x2, .Lusb_hcchar_dir_done
    mov w12, #1
    lsl w12, w12, #PI4_DWC2_HCCHAR_EPDIR
    orr w11, w11, w12
.Lusb_hcchar_dir_done:
    lsl w12, w3, #PI4_DWC2_HCCHAR_EPTYPE_SHIFT
    orr w11, w11, w12
    cmp w3, #PI4_DWC2_EPTYPE_INTERRUPT
    b.ne .Lusb_hcchar_mult_done
    mov w12, #1
    lsl w12, w12, #PI4_DWC2_HCCHAR_MC_SHIFT
    orr w11, w11, w12
.Lusb_hcchar_mult_done:
    lsl w12, w0, #PI4_DWC2_HCCHAR_DEVADDR_SHIFT
    orr w11, w11, w12
    ldr x8, =PI4_DWC2_HPRT0
    ldr w12, [x8]
    lsr w12, w12, #PI4_DWC2_HPRT0_SPD_SHIFT
    and w12, w12, #3
    cmp w12, #PI4_DWC2_HPRT0_SPD_LOW_SPEED
    b.ne .Lusb_hcchar_speed_done
    mov w12, #1
    lsl w12, w12, #PI4_DWC2_HCCHAR_LSPDDEV
    orr w11, w11, w12
.Lusb_hcchar_speed_done:
    mov w12, #1
    lsl w12, w12, #PI4_DWC2_HCCHAR_CHENA
    orr w11, w11, w12
    ldr x8, =PI4_DWC2_HCCHAR0
    str w11, [x8]
    b pi4_usb_wait_halt
.size pi4_usb_hc_transfer, . - pi4_usb_hc_transfer

.type pi4_usb_wait_halt, %function
pi4_usb_wait_halt:
    ldr x0, =PI4_DWC2_HCINT0
    mov x2, #0x100000
.Lusb_wait_halt_loop:
    ldr w1, [x0]
    tbnz w1, #PI4_DWC2_HCINT_CHHLTD, .Lusb_wait_halt_done
    subs x2, x2, #1
    b.ne .Lusb_wait_halt_loop
.Lusb_wait_halt_done:
    mov w0, w1
    ret
.size pi4_usb_wait_halt, . - pi4_usb_wait_halt

.type pi4_uart_input_pop, %function
pi4_uart_input_pop:
    adr x0, pi4_uart_input_head
    adr x1, pi4_uart_input_tail
    ldrb w2, [x0]
    ldrb w3, [x1]
    cmp w2, w3
    b.eq .Lpop_empty

    adr x4, pi4_uart_input_queue
    ldr x6, [x4, x3, lsl #3]
    add w3, w3, #1
    and w3, w3, #PI4_UART_INPUT_QUEUE_MASK
    strb w3, [x1]
    adr x4, pi4_uart_input_polled_events
    ldr x5, [x4]
    add x5, x5, #1
    str x5, [x4]
    and w7, w6, #PI4_INPUT_EVENT_TOKEN_KIND_MASK
    cmp w7, #PI4_INPUT_EVENT_MOUSE_PACKET
    b.eq .Lpop_mouse_packet
    mov x0, x6
    ret

.Lpop_mouse_packet:
    lsr x8, x6, #PI4_INPUT_EVENT_TOKEN_MOUSE_BUTTONS_SHIFT
    and x8, x8, #0xff
    adr x4, pi4_uart_input_mouse_buttons
    str x8, [x4]
    lsr x8, x6, #PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_X_SHIFT
    sxtb x8, w8
    adr x4, pi4_uart_input_mouse_delta_x
    str x8, [x4]
    lsr x8, x6, #PI4_INPUT_EVENT_TOKEN_MOUSE_DELTA_Y_SHIFT
    sxtb x8, w8
    adr x4, pi4_uart_input_mouse_delta_y
    str x8, [x4]
    mov w0, #PI4_INPUT_EVENT_MOUSE_PACKET
    ret

.Lpop_empty:
    mov w0, #PI4_INPUT_EVENT_NONE
    ret
.size pi4_uart_input_pop, . - pi4_uart_input_pop

.type pi4_uart_input_snapshot, %function
pi4_uart_input_snapshot:
    adr x5, pi4_uart_input_head
    ldrb w0, [x5]
    adr x5, pi4_uart_input_tail
    ldrb w1, [x5]
    sub w0, w0, w1
    and w0, w0, #PI4_UART_INPUT_QUEUE_MASK
    adr x5, pi4_uart_input_total_events
    ldr x1, [x5]
    adr x5, pi4_uart_input_polled_events
    ldr x2, [x5]
    adr x5, pi4_uart_input_dropped_events
    ldr x3, [x5]
    adr x5, pi4_uart_input_last_event
    ldrb w4, [x5]
    ret
.size pi4_uart_input_snapshot, . - pi4_uart_input_snapshot

.type pi4_uart_input_event_counts_snapshot, %function
pi4_uart_input_event_counts_snapshot:
    adr x5, pi4_uart_input_select_1_events
    ldr x0, [x5]
    adr x5, pi4_uart_input_select_2_events
    ldr x1, [x5]
    adr x5, pi4_uart_input_enter_events
    ldr x2, [x5]
    adr x5, pi4_uart_input_up_events
    ldr x3, [x5]
    adr x5, pi4_uart_input_down_events
    ldr x4, [x5]
    ret
.size pi4_uart_input_event_counts_snapshot, . - pi4_uart_input_event_counts_snapshot

.global pi4_uart_input_rx_debug_snapshot
.type pi4_uart_input_rx_debug_snapshot, %function
pi4_uart_input_rx_debug_snapshot:
    adr x5, pi4_uart_input_poll_calls
    ldr x0, [x5]
    adr x5, pi4_uart_input_last_uart0_fr
    ldr x1, [x5]
    adr x5, pi4_uart_input_uart0_ready_count
    ldr x2, [x5]
    adr x5, pi4_uart_input_last_uart0_dr
    ldr x3, [x5]
    adr x5, pi4_uart_input_uart0_error_count
    ldr x4, [x5]
    adr x5, pi4_uart_input_last_aux_lsr
    ldr x5, [x5]
    ret
.size pi4_uart_input_rx_debug_snapshot, . - pi4_uart_input_rx_debug_snapshot

.type pi4_uart_input_mouse_snapshot, %function
pi4_uart_input_mouse_snapshot:
    adr x5, pi4_uart_input_mouse_buttons
    ldr x0, [x5]
    adr x5, pi4_uart_input_mouse_delta_x
    ldr x1, [x5]
    adr x5, pi4_uart_input_mouse_delta_y
    ldr x2, [x5]
    ret
.size pi4_uart_input_mouse_snapshot, . - pi4_uart_input_mouse_snapshot

.type pi4_input_last_snapshot, %function
pi4_input_last_snapshot:
    adr x5, pi4_uart_input_last_device
    ldr x0, [x5]
    adr x5, pi4_uart_input_last_type
    ldr x1, [x5]
    adr x5, pi4_uart_input_last_code
    ldr x2, [x5]
    ret
.size pi4_input_last_snapshot, . - pi4_input_last_snapshot

.type pi4_input_keyboard_snapshot, %function
pi4_input_keyboard_snapshot:
    str x30, [sp, #-16]!
    adr x5, pi4_input_keyboard_events
    ldr x9, [x5]
    adr x5, pi4_input_keyboard_down_count
    ldr x10, [x5]
    adr x5, pi4_input_keyboard_last_code
    ldr x11, [x5]
    mov x12, xzr
    mov x0, #PI4_INPUT_KEY_PS2_LEFT_SHIFT
    bl pi4_input_key_state_test
    cbnz x0, .Lkeyboard_snapshot_shift
    mov x0, #PI4_INPUT_KEY_PS2_RIGHT_SHIFT
    bl pi4_input_key_state_test
    cbz x0, .Lkeyboard_snapshot_ctrl
.Lkeyboard_snapshot_shift:
    orr x12, x12, #PI4_INPUT_MOD_SHIFT
.Lkeyboard_snapshot_ctrl:
    mov x0, #PI4_INPUT_KEY_PS2_LEFT_CTRL
    bl pi4_input_key_state_test
    cbnz x0, .Lkeyboard_snapshot_ctrl_set
    mov x0, #PI4_INPUT_KEY_PS2_RIGHT_CTRL
    bl pi4_input_key_state_test
    cbz x0, .Lkeyboard_snapshot_alt
.Lkeyboard_snapshot_ctrl_set:
    orr x12, x12, #PI4_INPUT_MOD_CTRL
.Lkeyboard_snapshot_alt:
    mov x0, #PI4_INPUT_KEY_PS2_LEFT_ALT
    bl pi4_input_key_state_test
    cbnz x0, .Lkeyboard_snapshot_alt_set
    mov x0, #PI4_INPUT_KEY_PS2_RIGHT_ALT
    bl pi4_input_key_state_test
    cbz x0, .Lkeyboard_snapshot_done
.Lkeyboard_snapshot_alt_set:
    orr x12, x12, #PI4_INPUT_MOD_ALT
.Lkeyboard_snapshot_done:
    mov x0, x9
    mov x1, x10
    mov x2, x11
    adr x3, pi4_input_keyboard_state
    mov x4, x12
    ldr x30, [sp], #16
    ret
.size pi4_input_keyboard_snapshot, . - pi4_input_keyboard_snapshot

.type pi4_input_mouse_status_snapshot, %function
pi4_input_mouse_status_snapshot:
    adr x5, pi4_input_mouse_packet_count
    ldr x0, [x5]
    adr x5, pi4_uart_input_mouse_buttons
    ldr x1, [x5]
    adr x5, pi4_input_mouse_delta_x_total
    ldr x2, [x5]
    adr x5, pi4_input_mouse_delta_y_total
    ldr x3, [x5]
    ret
.size pi4_input_mouse_status_snapshot, . - pi4_input_mouse_status_snapshot

.type pi4_usb_input_snapshot, %function
pi4_usb_input_snapshot:
    adr x5, pi4_usb_ready
    ldrb w0, [x5]
    adr x5, pi4_usb_device_kind
    ldrb w1, [x5]
    adr x5, pi4_usb_status_stage
    ldrb w2, [x5]
    adr x5, pi4_usb_ready_caps
    ldrb w3, [x5]
    adr x5, pi4_usb_keyboard_ready
    ldrb w4, [x5]
    adr x5, pi4_usb_mouse_ready
    ldrb w5, [x5]
    ret
.size pi4_usb_input_snapshot, . - pi4_usb_input_snapshot

.section .pi4_input_state, "aw", %progbits
.balign 8
pi4_uart_input_head:
    .skip 1
pi4_uart_input_tail:
    .skip 1
pi4_uart_input_esc_state:
    .skip 1
pi4_uart_input_mouse_phase:
    .skip 1
pi4_uart_input_mouse_byte0:
    .skip 1
pi4_uart_input_mouse_byte1:
    .skip 1
    .balign 8
pi4_uart_input_queue:
    .skip PI4_UART_INPUT_QUEUE_SIZE * PI4_INPUT_QUEUE_SLOT_BYTES
    .balign 8
pi4_uart_input_total_events:
    .quad 0
pi4_uart_input_polled_events:
    .quad 0
pi4_uart_input_dropped_events:
    .quad 0
pi4_uart_input_last_event:
    .skip 1
    .balign 8
pi4_uart_input_last_device:
    .quad 0
pi4_uart_input_last_type:
    .quad 0
pi4_uart_input_last_code:
    .quad 0
pi4_uart_input_select_1_events:
    .quad 0
pi4_uart_input_select_2_events:
    .quad 0
pi4_uart_input_enter_events:
    .quad 0
pi4_uart_input_up_events:
    .quad 0
pi4_uart_input_down_events:
    .quad 0
pi4_uart_input_poll_calls:
    .quad 0
pi4_uart_input_last_uart0_fr:
    .quad 0
pi4_uart_input_uart0_ready_count:
    .quad 0
pi4_uart_input_last_uart0_dr:
    .quad 0
pi4_uart_input_uart0_error_count:
    .quad 0
pi4_uart_input_last_aux_lsr:
    .quad 0
pi4_input_keyboard_events:
    .quad 0
pi4_input_keyboard_down_count:
    .quad 0
pi4_input_keyboard_last_code:
    .quad 0
pi4_input_keyboard_state:
    .skip 8 * 8
pi4_input_mouse_packet_count:
    .quad 0
pi4_input_mouse_delta_x_total:
    .quad 0
pi4_input_mouse_delta_y_total:
    .quad 0
pi4_uart_input_mouse_buttons:
    .quad 0
pi4_uart_input_mouse_delta_x:
    .quad 0
pi4_uart_input_mouse_delta_y:
    .quad 0
pi4_usb_ready:
    .skip 1
pi4_usb_last_key:
    .skip 1
pi4_usb_last_mouse_buttons:
    .skip 1
pi4_usb_device_kind:
    .skip 1
pi4_usb_probe_device_kind:
    .skip 1
pi4_usb_probe_device_class:
    .skip 1
pi4_usb_config_value:
    .skip 1
pi4_usb_hid_interface_num:
    .skip 1
pi4_usb_hid_ep_num:
    .skip 1
pi4_usb_hid_mps:
    .skip 1
pi4_usb_hid_report_bytes:
    .skip 1
pi4_usb_hid_next_pid:
    .skip 1
pi4_usb_status_stage:
    .skip 1
pi4_usb_ready_caps:
    .skip 1
pi4_usb_keyboard_ready:
    .skip 1
pi4_usb_mouse_ready:
    .skip 1
pi4_usb_keyboard_addr:
    .skip 1
pi4_usb_mouse_addr:
    .skip 1
pi4_usb_hub_ports:
    .skip 1
pi4_usb_addr0_ep0_mps:
    .skip 1
pi4_usb_addr1_ep0_mps:
    .skip 1
pi4_usb_addr2_ep0_mps:
    .skip 1
pi4_usb_addr3_ep0_mps:
    .skip 1
pi4_usb_keyboard_interface_num:
    .skip 1
pi4_usb_mouse_interface_num:
    .skip 1
pi4_usb_keyboard_ep_num:
    .skip 1
pi4_usb_mouse_ep_num:
    .skip 1
pi4_usb_keyboard_mps:
    .skip 1
pi4_usb_mouse_mps:
    .skip 1
pi4_usb_keyboard_report_bytes:
    .skip 1
pi4_usb_mouse_report_bytes:
    .skip 1
pi4_usb_keyboard_next_pid:
    .skip 1
pi4_usb_mouse_next_pid:
    .skip 1
    .balign 8
pi4_usb_pending_key_token:
    .quad 0
pi4_usb_pending_head:
    .skip 1
pi4_usb_pending_tail:
    .skip 1
    .balign 8
pi4_usb_pending_queue:
    .skip PI4_USB_PENDING_QUEUE_SIZE * 8
pi4_usb_keyboard_mods:
    .skip 1
    .balign 8
pi4_usb_keyboard_keys:
    .skip 8
    .balign 8
pi4_usb_setup_packet:
    .skip 8
    .balign 8
pi4_usb_hid_report:
    .skip 8
    .balign 8
pi4_usb_device_descriptor:
    .skip 24
    .balign 8
pi4_usb_hub_descriptor:
    .skip PI4_USB_HUB_DESCRIPTOR_BYTES
    .balign 8
pi4_usb_hub_port_status:
    .skip 4
    .balign 8
pi4_usb_config_descriptor:
    .skip PI4_USB_CONFIG_DESCRIPTOR_BYTES
