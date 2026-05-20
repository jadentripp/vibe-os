bits 32

global start

SYS_USER_PROBE equ 1
SYS_EXIT equ 2
SYS_EXPECT_FAULT equ 3
USER_PROBE_MAGIC equ 0x13579BDF
USER_FAULT_ADDR equ 0x00010000

start:
    mov eax, SYS_USER_PROBE
    mov ebx, USER_PROBE_MAGIC
    int 0x80

    mov eax, SYS_EXPECT_FAULT
    int 0x80

    mov eax, [USER_FAULT_ADDR]

    mov eax, SYS_EXIT
    int 0x80

.hang:
    jmp .hang
