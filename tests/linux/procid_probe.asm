; procid_probe.asm - Linux i386 process/session/prctl seed probe for vibe-os.
;
; This proves the currently implemented process-ID seed surface, not a full
; Linux process-group/session/user-ID model.
bits 32
global start

%define SYS_EXIT              1
%define SYS_WRITE             4
%define SYS_GETPID           20
%define SYS_GETUID           24
%define SYS_GETGID           47
%define SYS_GETEUID          49
%define SYS_GETEGID          50
%define SYS_SETPGID          57
%define SYS_GETPPID          64
%define SYS_SETSID           66
%define SYS_GETPGID         132
%define SYS_GETSID          147
%define SYS_PRCTL           172
%define SYS_GETTID          224

%define PR_SET_DUMPABLE       4
%define PR_SET_NAME          15
%define PR_SET_NO_NEW_PRIVS  38

section .text
start:
    mov eax, SYS_GETPID
    int 0x80
    test eax, eax
    js fail
    jz fail
    mov [pid_value], eax

    mov eax, SYS_GETTID
    int 0x80
    cmp eax, [pid_value]
    jne fail

    mov eax, SYS_GETPPID
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_GETUID
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_GETEUID
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_GETGID
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_GETEGID
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_GETPGID
    xor ebx, ebx
    int 0x80
    cmp eax, [pid_value]
    jne fail

    mov eax, SYS_GETSID
    xor ebx, ebx
    int 0x80
    cmp eax, [pid_value]
    jne fail

    mov eax, SYS_SETPGID
    xor ebx, ebx
    xor ecx, ecx
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_PRCTL
    mov ebx, PR_SET_NAME
    mov ecx, proc_name
    xor edx, edx
    xor esi, esi
    xor edi, edi
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_PRCTL
    mov ebx, PR_SET_DUMPABLE
    mov ecx, 1
    xor edx, edx
    xor esi, esi
    xor edi, edi
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_PRCTL
    mov ebx, PR_SET_NO_NEW_PRIVS
    mov ecx, 1
    xor edx, edx
    xor esi, esi
    xor edi, edi
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_SETSID
    int 0x80
    cmp eax, [pid_value]
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 31
    int 0x80

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
proc_name: db "procid_probe", 0
ok_msg: db "procid ok", 10
ok_len equ $ - ok_msg
fail_msg: db "procid fail", 10
fail_len equ $ - fail_msg

section .bss
pid_value: resd 1
