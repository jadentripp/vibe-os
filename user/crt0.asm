bits 32

global start
global vibe_user_argc
global vibe_user_argv
global vibe_user_environ
global vibe_user_auxv
global __vibe_syscall0
global __vibe_syscall1
global __vibe_syscall2
global __vibe_syscall3
extern user_main

SYS_EXIT equ 2
PREEMPT_PROBE_MAGIC equ 0x50524545
VIBE_USER_ABI_VERSION equ 1
VIBE_USER_STACK_ABI_VERSION equ 1
SYSCALL_TRAP_VECTOR equ 0x80
SYSCALL_MAX_ARGS equ 3

section .text

start:
    cld
    fnclex
    cmp eax, PREEMPT_PROBE_MAGIC
    je preempt_spin
    mov eax, [esp]
    lea ebx, [esp + 4]
    lea ecx, [ebx + eax * 4 + 4]
    mov [vibe_user_argc], eax
    mov [vibe_user_argv], ebx
    mov [vibe_user_environ], ecx
    mov edx, ecx

.find_auxv:
    cmp dword [edx], 0
    je .auxv_found
    add edx, 4
    jmp .find_auxv

.auxv_found:
    add edx, 4
    mov [vibe_user_auxv], edx
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

; int 0x80 ABI: eax=syscall number, ebx/ecx/edx=args, eax=result.
; These C-callable thunks preserve ebx and leave DF clear for C callers.
__vibe_syscall0:
    push ebx
    mov eax, [esp + 8]
    int 0x80
    cld
    pop ebx
    ret

__vibe_syscall1:
    push ebx
    mov eax, [esp + 8]
    mov ebx, [esp + 12]
    int 0x80
    cld
    pop ebx
    ret

__vibe_syscall2:
    push ebx
    mov eax, [esp + 8]
    mov ebx, [esp + 12]
    mov ecx, [esp + 16]
    int 0x80
    cld
    pop ebx
    ret

__vibe_syscall3:
    push ebx
    mov eax, [esp + 8]
    mov ebx, [esp + 12]
    mov ecx, [esp + 16]
    mov edx, [esp + 20]
    int 0x80
    cld
    pop ebx
    ret

preempt_spin:
    mov dword [esp - 4], PREEMPT_PROBE_MAGIC

.loop:
    inc dword [esp - 4]
    jmp .loop

section .bss
align 4
vibe_user_argc resd 1
vibe_user_argv resd 1
vibe_user_environ resd 1
vibe_user_auxv resd 1
