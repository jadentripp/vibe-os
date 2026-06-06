; vfork_exit_group_child.asm - exec target for the vfork/exit_group probe.
bits 32
global start

%define SYS_EXIT_GROUP 252

section .text
start:
    mov eax, SYS_EXIT_GROUP
    xor ebx, ebx
    int 0x80
