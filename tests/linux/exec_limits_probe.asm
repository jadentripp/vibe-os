; exec_limits_probe.asm - verify larger exec argv/env staging from the guest.
bits 32
global start

LINUX_SYS_EXIT equ 1
LINUX_SYS_WRITE equ 4

EXPECTED_ARGC equ 10
EXPECTED_ENVC equ 9
LONG_CHECK_OFF equ 64

section .text
start:
    mov esi, esp
    mov eax, [esi]
    cmp eax, EXPECTED_ARGC
    jne .fail

    lea ebx, [esi + 4]
    mov esi, [ebx + 4]
    mov edi, arg_prefix
    call string_has_prefix
    cmp eax, 1
    jne .fail
    cmp byte [esi + LONG_CHECK_OFF], 0
    je .fail

    lea edx, [ebx + EXPECTED_ARGC * 4 + 4]
    mov esi, [edx]
    mov edi, env_prefix
    call string_has_prefix
    cmp eax, 1
    jne .fail
    cmp byte [esi + LONG_CHECK_OFF], 0
    je .fail

    xor ecx, ecx
    mov esi, edx
.count_env:
    lodsd
    test eax, eax
    jz .env_counted
    inc ecx
    cmp ecx, EXPECTED_ENVC + 1
    jae .fail
    jmp .count_env

.env_counted:
    cmp ecx, EXPECTED_ENVC
    jne .fail

    mov eax, LINUX_SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, LINUX_SYS_EXIT
    mov ebx, 9
    int 0x80

.fail:
    mov eax, LINUX_SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80
    mov eax, LINUX_SYS_EXIT
    mov ebx, 1
    int 0x80
.hang:
    jmp .hang

; esi = candidate string, edi = expected prefix. returns eax=1 on match.
string_has_prefix:
    push ebx
    push edi
    xor eax, eax
.next:
    mov bl, [edi]
    test bl, bl
    jz .ok
    cmp [esi], bl
    jne .done
    inc esi
    inc edi
    jmp .next

.ok:
    mov eax, 1

.done:
    pop edi
    pop ebx
    ret

section .data
arg_prefix: db "ARG_LONG_", 0
env_prefix: db "VIBE_EXEC_LIMITS=", 0
ok_msg: db "exec limits ok", 10
ok_len equ $ - ok_msg
fail_msg: db "exec limits fail", 10
fail_len equ $ - fail_msg
