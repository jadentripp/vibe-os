#include "pi4_runtime.h"

.arch armv8-a

// jmp_buf is six 64-bit words in quake_port/include/setjmp.h.
// Save a compact AArch64 return context that matches that fixed ABI.

.section .text.pi4_quake_engine.setjmp, "ax", %progbits

.balign 16
.global setjmp
.type setjmp, %function
setjmp:
    stp x19, x20, [x0, #0]
    str x21, [x0, #16]
    str x29, [x0, #24]
    mov x9, sp
    str x9, [x0, #32]
    str x30, [x0, #40]
    mov x0, xzr
    ret
.size setjmp, . - setjmp

.balign 16
.global longjmp
.type longjmp, %function
longjmp:
    mov x9, x0
    sxtw x0, w1
    cbnz x0, .Llongjmp_value_ready
    mov x0, #1
.Llongjmp_value_ready:
    ldp x19, x20, [x9, #0]
    ldr x21, [x9, #16]
    ldr x29, [x9, #24]
    ldr x10, [x9, #32]
    ldr x30, [x9, #40]
    mov sp, x10
    ret
.size longjmp, . - longjmp

.section .note.GNU-stack, "", %progbits
