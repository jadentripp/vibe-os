; vfork_child_probe.asm - exec target for the vfork/exec parent-release probe.
bits 32
global start

%define SYS_EXIT 1

section .text
start:
    mov ecx, 0x02000000

.spin:
    dec ecx
    jnz .spin

    mov eax, SYS_EXIT
    mov ebx, 42
    int 0x80
