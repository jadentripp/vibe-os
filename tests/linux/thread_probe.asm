; thread_probe.asm - Linux i386 thread/signal metadata seed probe for vibe-os.
bits 32
global start

%define SYS_EXIT_GROUP       252
%define SYS_WRITE              4
%define SYS_WAITPID            7
%define SYS_CLONE            120
%define SYS_RT_SIGACTION     174
%define SYS_RT_SIGPROCMASK   175
%define SYS_SIGALTSTACK      186
%define SYS_SET_TID_ADDRESS  258
%define SYS_SET_ROBUST_LIST  311
%define SYS_GET_ROBUST_LIST  312

%define SIGCHLD              17
%define SIGUSR1              10
%define SIG_SETMASK           2
%define CLONE_PARENT_SETTID   0x00100000

section .text
start:
    mov eax, SYS_SET_TID_ADDRESS
    mov ebx, tid_value
    int 0x80
    test eax, eax
    jle fail

    mov eax, SYS_SET_ROBUST_LIST
    mov ebx, robust_head
    mov ecx, 12
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_GET_ROBUST_LIST
    xor ebx, ebx
    mov ecx, robust_out
    mov edx, robust_len_out
    int 0x80
    test eax, eax
    jne fail
    cmp dword [robust_out], robust_head
    jne fail
    cmp dword [robust_len_out], 12
    jne fail

    mov eax, SYS_SIGALTSTACK
    mov ebx, alt_stack
    mov ecx, old_alt_stack
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_RT_SIGPROCMASK
    mov ebx, SIG_SETMASK
    mov ecx, sigmask_new
    mov edx, sigmask_old
    mov esi, 8
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_RT_SIGACTION
    mov ebx, SIGUSR1
    mov ecx, sigaction_new
    mov edx, sigaction_old
    mov esi, 8
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_RT_SIGACTION
    mov ebx, SIGUSR1
    xor ecx, ecx
    mov edx, sigaction_readback
    mov esi, 8
    int 0x80
    test eax, eax
    jne fail
    cmp dword [sigaction_readback], handler_stub
    jne fail

    mov eax, SYS_CLONE
    mov ebx, SIGCHLD | CLONE_PARENT_SETTID
    xor ecx, ecx
    mov edx, parent_tid
    xor esi, esi
    xor edi, edi
    int 0x80
    test eax, eax
    js fail
    jz child
    cmp dword [parent_tid], 0
    je fail

    mov eax, SYS_WAITPID
    mov ebx, [parent_tid]
    mov ecx, wait_status
    xor edx, edx
    int 0x80
    cmp eax, [parent_tid]
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT_GROUP
    mov ebx, 33
    int 0x80

child:
    mov eax, SYS_EXIT_GROUP
    xor ebx, ebx
    int 0x80

fail:
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80
    mov eax, SYS_EXIT_GROUP
    mov ebx, 1
    int 0x80

handler_stub:
    ret

section .data
ok_msg: db "thread ok", 10
ok_len equ $ - ok_msg
fail_msg: db "thread fail", 10
fail_len equ $ - fail_msg
sigmask_new: dd 0x00000200, 0
sigmask_old: dq 0
sigaction_new:
    dd handler_stub
    dd 0
    dd 0
    dd 0
    dd 0
sigaction_old: times 5 dd 0
sigaction_readback: times 5 dd 0
alt_stack:
    dd alt_stack_mem
    dd 0
    dd 4096
old_alt_stack: times 3 dd 0
robust_head: times 3 dd 0

section .bss
tid_value: resd 1
robust_out: resd 1
robust_len_out: resd 1
parent_tid: resd 1
wait_status: resd 1
alt_stack_mem: resb 4096
