bits 32

global start
extern user_main

SYS_EXIT equ 2

section .text

start:
    call user_main
    mov ebx, eax
    mov eax, SYS_EXIT
    int 0x80

.halt:
    jmp .halt
