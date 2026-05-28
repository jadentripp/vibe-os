#include "pi4_runtime.h"

.arch armv8-a

.extern vibe_user_start_status
.extern vibe_user_auxv
.extern vibe_user_entry_stack
.extern vibe_user_syscall0
.extern vibe_user_exit_status
.extern vibe_user_exec_request
.extern vibe_user_fb_get_info
.extern vibe_user_present_indexed_checked
.extern vibe_user_drain_input
.extern vibe_user_poll_input
.extern vibe_user_input_status
.extern vibe_user_input_keyboard_status
.extern vibe_user_input_mouse_status
.extern vibe_user_input_uart_status

.section .text.pi4_abi_probe.entry, "ax", %progbits
.balign 16
.global user_main
.global pi4_abi_probe_start
.type user_main, %function
.type pi4_abi_probe_start, %function
user_main:
pi4_abi_probe_start:
    mov x20, x0
    mov x21, x1
    mov x22, x2

    adrp x19, pi4_abi_probe_status
    add x19, x19, :lo12:pi4_abi_probe_status

    mov x9, #PI4_VIBE_ABI_PROBE_STATE_ENTERED
    str x9, [x19, #PI4_VIBE_ABI_PROBE_STATUS_STATE_OFFSET]
    str x20, [x19, #PI4_VIBE_ABI_PROBE_STATUS_ARGC_OFFSET]
    str x21, [x19, #PI4_VIBE_ABI_PROBE_STATUS_ARGV_OFFSET]
    str x22, [x19, #PI4_VIBE_ABI_PROBE_STATUS_ENVP_OFFSET]

    adrp x9, vibe_user_start_status
    add x9, x9, :lo12:vibe_user_start_status
    ldr x9, [x9]
    str x9, [x19, #PI4_VIBE_ABI_PROBE_STATUS_START_FLAGS_OFFSET]

    adrp x9, vibe_user_auxv
    add x9, x9, :lo12:vibe_user_auxv
    ldr x10, [x9]
    str x10, [x19, #PI4_VIBE_ABI_PROBE_STATUS_AUXV_OFFSET]
    cbz x10, .Lpi4_probe_aux_record_done
    ldr x11, [x10]
    str x11, [x19, #PI4_VIBE_ABI_PROBE_STATUS_AUX0_TYPE_OFFSET]
    ldr x11, [x10, #8]
    str x11, [x19, #PI4_VIBE_ABI_PROBE_STATUS_AUX0_VALUE_OFFSET]

    mov x11, x10
    mov x12, #(PI4_VIBE_USER_AUX_MAX + 1)
.Lpi4_probe_aux_scan:
    cbz x12, .Lpi4_probe_aux_record_done
    ldr x13, [x11]
    cbz x13, .Lpi4_probe_aux_null_found
    add x11, x11, #16
    sub x12, x12, #1
    b .Lpi4_probe_aux_scan
.Lpi4_probe_aux_null_found:
    sub x13, x11, x10
    str x13, [x19, #PI4_VIBE_ABI_PROBE_STATUS_AUX_NULL_OFF_OFFSET]

.Lpi4_probe_aux_record_done:
    adrp x9, vibe_user_entry_stack
    add x9, x9, :lo12:vibe_user_entry_stack
    ldr x9, [x9]
    str x9, [x19, #PI4_VIBE_ABI_PROBE_STATUS_ENTRY_STACK_OFFSET]

    mov w0, #PI4_VIBE_SYS_GETPID
    bl vibe_user_syscall0
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_GETPID_OFFSET]

    adrp x0, pi4_abi_probe_input_status
    add x0, x0, :lo12:pi4_abi_probe_input_status
    bl vibe_user_input_status
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_INPUT_STATUS_OFFSET]

    adrp x0, pi4_abi_probe_keyboard_status
    add x0, x0, :lo12:pi4_abi_probe_keyboard_status
    bl vibe_user_input_keyboard_status
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_INPUT_KEYBOARD_STATUS_OFFSET]

    adrp x0, pi4_abi_probe_mouse_status
    add x0, x0, :lo12:pi4_abi_probe_mouse_status
    bl vibe_user_input_mouse_status
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_INPUT_MOUSE_STATUS_OFFSET]

    adrp x0, pi4_abi_probe_uart_status
    add x0, x0, :lo12:pi4_abi_probe_uart_status
    bl vibe_user_input_uart_status
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_INPUT_UART_STATUS_OFFSET]

    adrp x0, pi4_abi_probe_fb_info
    add x0, x0, :lo12:pi4_abi_probe_fb_info
    bl vibe_user_fb_get_info
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_FB_INFO_OFFSET]

    adrp x0, pi4_abi_probe_input_event
    add x0, x0, :lo12:pi4_abi_probe_input_event
    bl vibe_user_poll_input
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_POLL_INPUT_OFFSET]

    adrp x0, pi4_abi_probe_drain_events
    add x0, x0, :lo12:pi4_abi_probe_drain_events
    mov x1, #2
    bl vibe_user_drain_input
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_DRAIN_INPUT_OFFSET]

    adrp x0, pi4_abi_probe_present
    add x0, x0, :lo12:pi4_abi_probe_present
    bl vibe_user_present_indexed_checked
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_PRESENT_OFFSET]

    adrp x0, pi4_abi_probe_exec_request
    add x0, x0, :lo12:pi4_abi_probe_exec_request
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_EXEC_REQ_PTR_OFFSET]
    adrp x1, pi4_abi_probe_exec_argv
    add x1, x1, :lo12:pi4_abi_probe_exec_argv
    mov x2, xzr
    bl vibe_user_exec_request
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_EXEC_REQUEST_OFFSET]

    mov x9, #PI4_VIBE_ABI_PROBE_STATE_WRAPPERS_DONE
    str x9, [x19, #PI4_VIBE_ABI_PROBE_STATUS_STATE_OFFSET]

    ldr x9, [x19, #PI4_VIBE_ABI_PROBE_STATUS_START_FLAGS_OFFSET]
    and x9, x9, #PI4_VIBE_USER_START_REQUIRED_FLAGS
    cmp x9, #PI4_VIBE_USER_START_REQUIRED_FLAGS
    cset x0, ne
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_EXIT_CODE_OFFSET]
    str x0, [x19, #PI4_VIBE_ABI_PROBE_STATUS_EXIT_WRAPPER_OFFSET]
    bl vibe_user_exit_status

.Lpi4_abi_probe_halt:
    wfe
    b .Lpi4_abi_probe_halt
.size user_main, . - user_main
.size pi4_abi_probe_start, . - pi4_abi_probe_start

.section .rodata.pi4_abi_probe_manifest, "a", %progbits
.balign 8
.global pi4_abi_probe_manifest
pi4_abi_probe_manifest:
    .asciz "vibe-os pi4 ABIPROBE.ELF AArch64 user runtime wrappers"

.section .rodata.pi4_abi_probe_frame, "a", %progbits
.balign 8
pi4_abi_probe_frame:
    .byte 0

.section .rodata.pi4_abi_probe_palette, "a", %progbits
.balign 8
pi4_abi_probe_palette:
    .rept 256
    .byte 0, 0, 0
    .endr

.section .data.pi4_abi_probe_present, "aw", %progbits
.balign 8
pi4_abi_probe_present:
    .quad pi4_abi_probe_frame
    .quad pi4_abi_probe_palette
    .quad 1
    .quad 1

.balign 8
pi4_abi_probe_exec_request:
    .quad PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    .quad PI4_VIBE_EXEC_REQUEST_BYTES
    .quad PI4_VIBE_EXEC_REQUEST_COMPAT_NONE
    .quad pi4_abi_probe_doom_app_path
pi4_abi_probe_exec_argv:
    .quad pi4_abi_probe_doom_app_path
    .quad 0
pi4_abi_probe_doom_app_path:
    .asciz "/APPS/DOOM/APP.ELF"
    .balign 8

.section .data.pi4_abi_probe_status, "aw", %progbits
.balign 8
.global pi4_abi_probe_status
pi4_abi_probe_status:
    .quad 0x3149424155344950
    .skip PI4_VIBE_ABI_PROBE_STATUS_BYTES - 8, 0

.section .bss.pi4_abi_probe, "aw", %nobits
.balign 8
pi4_abi_probe_input_event:
    .skip PI4_VIBE_INPUT_EVENT_BYTES
.balign 8
pi4_abi_probe_input_status:
    .skip PI4_VIBE_INPUT_STATUS_BYTES
.balign 8
pi4_abi_probe_keyboard_status:
    .skip PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
.balign 8
pi4_abi_probe_mouse_status:
    .skip PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
.balign 8
pi4_abi_probe_uart_status:
    .skip PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
.balign 8
pi4_abi_probe_drain_events:
    .skip PI4_VIBE_INPUT_EVENT_BYTES * 2
.balign 8
pi4_abi_probe_fb_info:
    .skip PI4_VIBE_FB_INFO_BYTES

.section .note.GNU-stack, "", %progbits
