BITS 32

%define SYS_GAMEPLAY_STATUS 15
%define QUAKE_STATUS_INIT 0x51000000
%define QUAKE_INIT_VIDEO 0x00000004
%define QUAKE_STATUS_FRAME 0x52000000

%define BASEWIDTH 320
%define BASEHEIGHT 200
%define PALETTE_BYTES 768
%define SURFCACHE_BYTES 262144

%define VID_BUFFER 0
%define VID_COLORMAP 4
%define VID_COLORMAP16 8
%define VID_FULLBRIGHT 12
%define VID_ROWBYTES 16
%define VID_WIDTH 20
%define VID_HEIGHT 24
%define VID_ASPECT 28
%define VID_NUMPAGES 32
%define VID_RECALC_REFDEF 36
%define VID_CONBUFFER 40
%define VID_CONROWBYTES 44
%define VID_CONWIDTH 48
%define VID_CONHEIGHT 52
%define VID_MAXWARPWIDTH 56
%define VID_MAXWARPHEIGHT 60
%define VID_DIRECT 64

section .text

global VID_SetPalette
global VID_ShiftPalette
global VID_Init
global VID_Shutdown
global VID_Update
global VID_SetMode
global VID_HandlePause
global D_BeginDirectRect
global D_EndDirectRect

extern D_InitCaches
extern d_pzbuffer
extern host_colormap
extern memcpy
extern vibe_present_indexed_checked
extern vibe_syscall3

VID_SetPalette:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    test eax, eax
    jz .done
    push dword PALETTE_BYTES
    push eax
    push dword quake_palette
    call memcpy
    add esp, 12
.done:
    pop ebp
    ret

VID_ShiftPalette:
    jmp VID_SetPalette

VID_Init:
    push ebp
    mov ebp, esp

    push dword [ebp + 8]
    call VID_SetPalette
    add esp, 4

    mov dword [vid + VID_BUFFER], vid_buffer
    mov eax, [host_colormap]
    mov [vid + VID_COLORMAP], eax
    mov dword [vid + VID_COLORMAP16], 0
    mov ecx, [eax + 8192]
    mov eax, 256
    sub eax, ecx
    mov [vid + VID_FULLBRIGHT], eax
    mov dword [vid + VID_ROWBYTES], BASEWIDTH
    mov dword [vid + VID_WIDTH], BASEWIDTH
    mov dword [vid + VID_HEIGHT], BASEHEIGHT
    mov dword [vid + VID_ASPECT], 0x3f800000
    mov dword [vid + VID_NUMPAGES], 1
    mov dword [vid + VID_RECALC_REFDEF], 0
    mov dword [vid + VID_CONBUFFER], vid_buffer
    mov dword [vid + VID_CONROWBYTES], BASEWIDTH
    mov dword [vid + VID_CONWIDTH], BASEWIDTH
    mov dword [vid + VID_CONHEIGHT], BASEHEIGHT
    mov dword [vid + VID_MAXWARPWIDTH], BASEWIDTH
    mov dword [vid + VID_MAXWARPHEIGHT], BASEHEIGHT
    mov dword [vid + VID_DIRECT], 0

    mov dword [d_pzbuffer], zbuffer
    push dword SURFCACHE_BYTES
    push dword surfcache
    call D_InitCaches
    add esp, 8

    push dword 0
    push dword 0
    push dword QUAKE_STATUS_INIT | QUAKE_INIT_VIDEO
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16

    pop ebp
    ret

VID_Shutdown:
VID_HandlePause:
D_BeginDirectRect:
D_EndDirectRect:
    ret

VID_Update:
    push ebp
    mov ebp, esp
    inc dword [quake_present_count]
    push dword quake_present_desc
    call vibe_present_indexed_checked
    add esp, 4
    push eax
    push dword [quake_present_count]
    push dword QUAKE_STATUS_FRAME
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16
    pop ebp
    ret

VID_SetMode:
    push ebp
    mov ebp, esp
    push dword [ebp + 12]
    call VID_SetPalette
    add esp, 4
    mov eax, 1
    pop ebp
    ret

section .data
align 4
quake_present_desc:
    dd vid_buffer
    dd quake_palette
    dd BASEWIDTH
    dd BASEHEIGHT

quake_present_count dd 0

section .bss
align 4
global vid
global d_8to16table
global d_8to24table

vid resb 68
vid_buffer resb BASEWIDTH * BASEHEIGHT
zbuffer resb BASEWIDTH * BASEHEIGHT * 2
surfcache resb SURFCACHE_BYTES
d_8to16table resb 256 * 2
align 4
d_8to24table resb 256 * 4
quake_palette resb PALETTE_BYTES
