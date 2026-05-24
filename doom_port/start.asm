BITS 32

%define VIBE_SYS_GAMEPLAY_STATUS 15
%define VIBE_DOOM_INIT_STATUS 0x40000000
%define VIBE_DOOM_INIT_START 0x00000001

section .text

global user_main
global start

extern vibe_syscall3
extern D_DoomMain
extern exit
extern myargc
extern myargv

user_main:
    push ebp
    mov ebp, esp

    push dword 0
    push dword 0
    push dword VIBE_DOOM_INIT_STATUS | VIBE_DOOM_INIT_START
    push dword VIBE_SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16

    mov dword [myargc], 6
    mov dword [myargv], argv_storage

    call D_DoomMain

    xor eax, eax
    leave
    ret

start:
    push ebp
    mov ebp, esp

    call user_main

    push dword 0
    call exit
    add esp, 4

.halt:
    jmp .halt

section .data

arg0 db "vibe-doom", 0
arg_warp db "-warp", 0
arg_episode db "1", 0
arg_map db "1", 0
arg_skill db "-skill", 0
arg_skill_medium db "3", 0

argv_storage:
    dd arg0
    dd arg_warp
    dd arg_episode
    dd arg_map
    dd arg_skill
    dd arg_skill_medium
    dd 0
