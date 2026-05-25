BITS 32

extern vibe_launcher_choose_payload
extern vibe_user_execv
extern vibe_user_write_all

section .text
global user_main

align 16
user_main:
    push ebp
    mov ebp, esp
    push ebx

    call vibe_launcher_choose_payload
    mov ebx, eax

    mov [launcher_argv], ebx
    mov dword [launcher_argv + 4], 0
    push launcher_argv
    push ebx
    call vibe_user_execv
    add esp, 8

    push launcher_exec_failed_text
    push 1
    call vibe_user_write_all
    add esp, 8

    mov eax, 1
    pop ebx
    pop ebp
    ret

section .rodata
launcher_exec_failed_text db `launcher exec failed\n`, 0

section .data
align 4
launcher_argv dd 0, 0
