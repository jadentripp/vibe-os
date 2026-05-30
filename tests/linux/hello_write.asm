; hello_write.asm — a static Linux i386 ELF that writes a line and exits 42.
;
; This is a *Linux* binary: it issues raw `int 0x80` with the Linux i386
; syscall numbers (write=4, exit=1), so it only runs correctly once vibe-os
; loads it under PERSONALITY_LINUX (the Linux personality syscall path).
;
; Built with the repo toolchain (no GNU as / musl on this host):
;   nasm -f elf32 hello_write.asm -o hello_write.o
;   build/link_elf32 -o hello_write --base 0x08048000 hello_write.o
; link_elf32's entry symbol is `start` (not `_start`).
bits 32
global start

section .text
start:
    mov eax, 4              ; sys_write (Linux i386)
    mov ebx, 1              ; fd = stdout
    mov ecx, msg
    mov edx, msg_len
    int 0x80
    mov eax, 1              ; sys_exit (Linux i386)
    mov ebx, 42             ; status 42 (proves the exit-code path)
    int 0x80
.hang:
    jmp .hang               ; never reached; guards against a runaway entry

section .data
msg:    db "hello from linux personality", 10
msg_len equ $ - msg
