; tls_probe.asm - prove Linux i386 set_thread_area and GS-based TLS.
bits 32
global start

LINUX_SYS_EXIT equ 1
LINUX_SYS_WRITE equ 4
LINUX_SYS_SET_THREAD_AREA equ 243
TLS_MAGIC equ 0x544c534f

section .text
start:
    mov eax, LINUX_SYS_SET_THREAD_AREA
    mov ebx, user_desc
    int 0x80
    test eax, eax
    jnz .fail

    mov eax, [user_desc]
    shl eax, 3
    or ax, 3
    mov gs, ax
    mov eax, [gs:0]
    cmp eax, TLS_MAGIC
    jne .fail

    mov eax, LINUX_SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80

    mov eax, [gs:0]
    cmp eax, TLS_MAGIC
    jne .fail

    mov eax, LINUX_SYS_EXIT
    xor ebx, ebx
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

section .data
user_desc:
    dd 0xffffffff
    dd tls_area
    dd 0x000fffff
    dd 0x00000051

tls_area:
    dd TLS_MAGIC

ok_msg: db "tls ok", 10
ok_len equ $ - ok_msg

fail_msg: db "tls fail", 10
fail_len equ $ - fail_msg
