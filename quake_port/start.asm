BITS 32

%define QUAKE_FRAME_MILLISECONDS 50
%define QUAKE_MEMORY_BYTES 0x00580000
%define SYS_GAMEPLAY_STATUS 15
%define QUAKE_STATUS_INIT 0x51000000
%define QUAKE_INIT_START 0x00000001
%define QUAKE_INIT_HOST 0x00000002
%define QUAKE_STATUS_FRAME 0x52000000

section .text

global start

extern COM_InitArgv
extern Host_Frame
extern Host_Init
extern host_framecount
extern exit
extern malloc
extern sv
extern vibe_syscall3

start:
    push ebp
    mov ebp, esp

    push dword argv_storage
    push dword 4
    call COM_InitArgv
    add esp, 8

    push dword 0
    push dword 0
    push dword QUAKE_STATUS_INIT | QUAKE_INIT_START
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16

    push dword QUAKE_MEMORY_BYTES
    call malloc
    add esp, 4
    test eax, eax
    jz .failed

    mov [quake_parms + 16], eax
    mov dword [quake_parms + 20], QUAKE_MEMORY_BYTES

    push dword quake_parms
    call Host_Init
    add esp, 4

    push dword 0
    push dword 0
    push dword QUAKE_STATUS_INIT | QUAKE_INIT_HOST
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16

.frame_loop:
    push dword QUAKE_FRAME_MILLISECONDS
    call quake_frame_seconds
    add esp, 4
    sub esp, 4
    fstp dword [esp]
    call Host_Frame
    add esp, 4
    call quake_report_frame
    jmp .frame_loop

.failed:
    push dword 1
    call exit
    add esp, 4

.halt:
    jmp .halt

quake_frame_seconds:
    push ebp
    mov ebp, esp
    fild dword [ebp + 8]
    fidiv dword [milliseconds_per_second]
    pop ebp
    ret

quake_report_frame:
    push ebp
    mov ebp, esp
    mov eax, [host_framecount]
    mov edx, [sv]
    shl edx, 8
    or edx, QUAKE_STATUS_FRAME
    push dword 0
    push eax
    push edx
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16
    pop ebp
    ret

section .data

milliseconds_per_second dd 1000

arg0 db "vibe-quake", 0
arg_nocdaudio db "-nocdaudio", 0
arg_map db "+map", 0
arg_start db "start", 0

argv_storage:
    dd arg0
    dd arg_nocdaudio
    dd arg_map
    dd arg_start
    dd 0

basedir db "", 0

quake_parms:
    dd basedir
    dd 0
    dd 4
    dd argv_storage
    dd 0
    dd 0
