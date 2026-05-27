#include "pi4_runtime.h"

.arch armv8-a

.extern user_main
.extern vibe_user_exit

.section .text.pi4_crt0.start, "ax", %progbits
.balign 16
.global _start
.global start
.type _start, %function
.type start, %function
_start:
start:
    mov x19, sp

    adrp x27, vibe_user_start_status
    add x27, x27, :lo12:vibe_user_start_status
    str xzr, [x27]

    ldr x20, [x19]
    cmp x20, #1
    b.lo .Lpi4_start_invalid
    cmp x20, #PI4_VIBE_USER_ARG_MAX
    b.hi .Lpi4_start_invalid

    ldr x9, [x27]
    orr x9, x9, #PI4_VIBE_USER_START_FLAG_ARGV_BOUNDED
    str x9, [x27]

    add x21, x19, #8
    add x22, x21, x20, lsl #3
    add x22, x22, #8

    adrp x9, vibe_user_argc
    add x9, x9, :lo12:vibe_user_argc
    str x20, [x9]
    adrp x9, vibe_user_argv
    add x9, x9, :lo12:vibe_user_argv
    str x21, [x9]
    adrp x9, vibe_user_environ
    add x9, x9, :lo12:vibe_user_environ
    str x22, [x9]

    mov x23, x22
    mov x24, #(PI4_VIBE_USER_ENV_MAX + 1)
.Lpi4_find_auxv:
    cbz x24, .Lpi4_start_invalid
    ldr x9, [x23]
    cbz x9, .Lpi4_auxv_found
    add x23, x23, #8
    sub x24, x24, #1
    b .Lpi4_find_auxv

.Lpi4_auxv_found:
    ldr x9, [x27]
    orr x9, x9, #PI4_VIBE_USER_START_FLAG_ENVP_BOUNDED
    str x9, [x27]

    add x23, x23, #8
    adrp x9, vibe_user_auxv
    add x9, x9, :lo12:vibe_user_auxv
    str x23, [x9]

    ldr x9, [x23]
    cbz x9, .Lpi4_start_invalid
    ldr x9, [x27]
    orr x9, x9, #PI4_VIBE_USER_START_FLAG_AUXV_PRESENT
    str x9, [x27]

    mov x25, x23
    mov x24, #(PI4_VIBE_USER_AUX_MAX + 1)
.Lpi4_find_auxv_end:
    cbz x24, .Lpi4_start_invalid
    ldr x9, [x25]
    cbz x9, .Lpi4_auxv_bounded
    add x25, x25, #16
    sub x24, x24, #1
    b .Lpi4_find_auxv_end

.Lpi4_auxv_bounded:
    ldr x9, [x27]
    orr x9, x9, #PI4_VIBE_USER_START_FLAG_AUXV_BOUNDED
    str x9, [x27]

.Lpi4_call_main:
    adrp x9, vibe_user_entry_stack
    add x9, x9, :lo12:vibe_user_entry_stack
    str x19, [x9]

    and x9, x19, #0xf
    cbnz x9, .Lpi4_start_invalid
    mov sp, x19

    ldr x9, [x27]
    orr x9, x9, #PI4_VIBE_USER_START_FLAG_STACK_ALIGNED
    str x9, [x27]

    mov x29, xzr
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl user_main

    mov sp, x19
    bl vibe_user_exit

.Lpi4_start_invalid:
    mov x0, #PI4_VIBE_USER_START_FAIL_STATUS
    bl vibe_user_exit

.Lpi4_start_halt:
    wfe
    b .Lpi4_start_halt
.size _start, . - _start
.size start, . - start

.section .bss.pi4_crt0, "aw", %nobits
.balign 8
.global vibe_user_argc
.global vibe_user_argv
.global vibe_user_environ
.global vibe_user_auxv
.global vibe_user_start_status
.global vibe_user_entry_stack
vibe_user_argc:
    .skip 8
vibe_user_argv:
    .skip 8
vibe_user_environ:
    .skip 8
vibe_user_auxv:
    .skip 8
vibe_user_start_status:
    .skip 8
vibe_user_entry_stack:
    .skip 8

.section .note.GNU-stack, "", %progbits
