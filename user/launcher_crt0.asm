bits 32

global start
global vibe_user_argc
global vibe_user_argv
global vibe_user_environ
global vibe_user_auxv
global vibe_user_start_status
global __vibe_syscall0
global __vibe_syscall1
global __vibe_syscall2
global __vibe_syscall3
extern user_main

SYS_EXIT equ 2
PREEMPT_PROBE_MAGIC equ 0x50524545
VIBE_USER_ARG_MAX equ 8
VIBE_USER_ENV_MAX equ 8
VIBE_USER_START_FLAG_ARGV_BOUNDED equ 0x00000001
VIBE_USER_START_FLAG_ENVP_BOUNDED equ 0x00000002
VIBE_USER_START_FLAG_AUXV_PRESENT equ 0x00000004
VIBE_USER_START_FLAG_STACK_ALIGNED equ 0x00000008
VIBE_USER_START_FAIL_STATUS equ 0x96
SYSCALL_TRAP_VECTOR equ 0x80

section .text

start:
    cld
    fnclex
    cmp eax, PREEMPT_PROBE_MAGIC
    je preempt_spin
    mov dword [vibe_user_start_status], 0
    mov eax, [esp]
    cmp eax, 1
    jb .invalid_start_stack
    cmp eax, VIBE_USER_ARG_MAX
    ja .invalid_start_stack
    or dword [vibe_user_start_status], VIBE_USER_START_FLAG_ARGV_BOUNDED
    lea ebx, [esp + 4]
    lea ecx, [ebx + eax * 4 + 4]
    mov [vibe_user_argc], eax
    mov [vibe_user_argv], ebx
    mov [vibe_user_environ], ecx
    mov edx, ecx
    mov esi, VIBE_USER_ENV_MAX + 1

.find_auxv:
    cmp esi, 0
    je .invalid_start_stack
    cmp dword [edx], 0
    je .auxv_found
    add edx, 4
    dec esi
    jmp .find_auxv

.auxv_found:
    or dword [vibe_user_start_status], VIBE_USER_START_FLAG_ENVP_BOUNDED
    add edx, 4
    mov [vibe_user_auxv], edx
    cmp dword [edx], 0
    je .call_main
    or dword [vibe_user_start_status], VIBE_USER_START_FLAG_AUXV_PRESENT

.call_main:
    mov [vibe_user_entry_stack], esp
    and esp, 0xfffffff0
    or dword [vibe_user_start_status], VIBE_USER_START_FLAG_STACK_ALIGNED
    sub esp, 12
    mov [esp], eax
    mov [esp + 4], ebx
    mov [esp + 8], ecx
    xor ebp, ebp
    call user_main
    mov esp, [vibe_user_entry_stack]
    mov ebx, eax
    mov eax, SYS_EXIT
    int SYSCALL_TRAP_VECTOR

.halt:
    jmp .halt

.invalid_start_stack:
    mov ebx, VIBE_USER_START_FAIL_STATUS
    mov eax, SYS_EXIT
    int SYSCALL_TRAP_VECTOR
    jmp .halt

__vibe_syscall0:
    push ebx
    mov eax, [esp + 8]
    int SYSCALL_TRAP_VECTOR
    cld
    pop ebx
    ret

__vibe_syscall1:
    push ebx
    mov eax, [esp + 8]
    mov ebx, [esp + 12]
    int SYSCALL_TRAP_VECTOR
    cld
    pop ebx
    ret

__vibe_syscall2:
    push ebx
    mov eax, [esp + 8]
    mov ebx, [esp + 12]
    mov ecx, [esp + 16]
    int SYSCALL_TRAP_VECTOR
    cld
    pop ebx
    ret

__vibe_syscall3:
    push ebx
    mov eax, [esp + 8]
    mov ebx, [esp + 12]
    mov ecx, [esp + 16]
    mov edx, [esp + 20]
    int SYSCALL_TRAP_VECTOR
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
vibe_user_start_status resd 1
vibe_user_entry_stack resd 1
