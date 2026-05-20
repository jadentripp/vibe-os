bits 32

global start
extern user_main

SYS_EXIT equ 2
PREEMPT_PROBE_MAGIC equ 0x50524545

section .text

start:
    cmp eax, PREEMPT_PROBE_MAGIC
    je preempt_spin
    mov eax, [esp]
    lea ebx, [esp + 4]
    lea ecx, [ebx + eax * 4 + 4]
    push ecx
    push ebx
    push eax
    call user_main
    add esp, 12
    mov ebx, eax
    mov eax, SYS_EXIT
    int 0x80

.halt:
    jmp .halt

preempt_spin:
    mov dword [esp - 4], PREEMPT_PROBE_MAGIC

.loop:
    inc dword [esp - 4]
    jmp .loop
