; clone3_probe.asm - Linux i386 clone3 fork-like probe for vibe-os.
;
; Proves the supported fork-like clone3 case plus the vfork-style stack contract:
; clone3 stack is the low address, stack_size is the range, and the kernel
; starts the child at stack + stack_size.
bits 32
global start

%define SYS_EXIT    1
%define SYS_WRITE   4
%define SYS_WAITPID 7
%define SYS_CLONE3  435

%define SIGCHLD     17
%define CLONE_VM    0x00000100
%define CLONE_VFORK 0x00004000

section .text
start:
    mov ebx, clone_args_fork
    call run_clone3_wait
    test eax, eax
    jnz fail

    mov eax, SYS_CLONE3
    mov ebx, clone_args_vfork_stack
    mov ecx, clone_args_size
    int 0x80
    cmp eax, 0
    jl fail
    jmp ok_exit

ok_exit:
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 49
    int 0x80

run_clone3_wait:
    mov eax, SYS_CLONE3
    mov ecx, clone_args_size
    int 0x80
    cmp eax, 0
    jl clone_fail
    jz child

    mov [child_pid], eax

    mov eax, SYS_WAITPID
    mov ebx, [child_pid]
    mov ecx, wait_status
    xor edx, edx
    int 0x80
    cmp eax, [child_pid]
    jne clone_fail
    cmp dword [wait_status], 0
    jne clone_fail
    xor eax, eax
    ret

child:
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

clone_fail:
    mov eax, 1
    ret

fail:
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80

    mov eax, SYS_EXIT
    mov ebx, 1
    int 0x80

section .data
align 8
clone_args_fork:
    dq 0        ; flags
    dq 0        ; pidfd
    dq 0        ; child_tid
    dq 0        ; parent_tid
    dq SIGCHLD  ; exit_signal
    dq 0        ; stack
    dq 0        ; stack_size
    dq 0        ; tls
    dq 0        ; set_tid
    dq 0        ; set_tid_size
    dq 0        ; cgroup

clone_args_vfork_stack:
    dq CLONE_VM | CLONE_VFORK
    dq 0
    dq 0
    dq 0
    dq SIGCHLD
    dd child_stack, 0
    dd child_stack_size, 0
    dq 0
    dq 0
    dq 0
    dq 0
clone_args_size equ clone_args_vfork_stack - clone_args_fork
%if clone_args_size != 88
    %error "clone_args must stay at Linux clone3 size 88"
%endif

ok_msg:   db "clone3 ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "clone3 fail", 10
fail_len  equ $ - fail_msg

section .bss
child_pid:   resd 1
wait_status: resd 1
alignb 16
child_stack: resb 4096
child_stack_size equ $ - child_stack
