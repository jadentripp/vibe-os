BITS 32

%define O_RDONLY 0
%define O_RDWR 2
%define O_CREAT 0x0100
%define O_TRUNC 0x0200
%define SEEK_SET 0

section .text

global Sys_DebugNumber
global Sys_MakeCodeWriteable
global Sys_FileOpenRead
global Sys_FileOpenWrite
global Sys_FileClose
global Sys_FileSeek
global Sys_FileRead
global Sys_FileWrite
global Sys_FileTime
global Sys_mkdir
global Sys_Error
global Sys_Printf
global Sys_Quit
global Sys_FloatTime
global Sys_ConsoleInput
global Sys_Sleep
global Sys_SendKeyEvents
global Sys_HighFPPrecision
global Sys_LowFPPrecision
global Sys_Warn
global Sys_DebugLog
global Sys_Init
global Sys_SetFPCW

extern Host_Shutdown
extern close
extern exit
extern fstat
extern lseek
extern mkdir
extern open
extern printf
extern quake_pump_input
extern read
extern stat
extern vprintf
extern vibe_monotonic_milliseconds
extern write

Sys_DebugNumber:
Sys_MakeCodeWriteable:
Sys_Sleep:
Sys_HighFPPrecision:
Sys_LowFPPrecision:
Sys_Init:
Sys_SetFPCW:
Sys_DebugLog:
    ret

Sys_SendKeyEvents:
    jmp quake_pump_input

Sys_FileOpenRead:
    push ebp
    mov ebp, esp
    sub esp, 44
    push dword 0
    push dword O_RDONLY
    push dword [ebp + 8]
    call open
    add esp, 12
    test eax, eax
    js .open_failed
    mov edx, [ebp + 12]
    mov [edx], eax
    push dword esp
    push dword eax
    call fstat
    add esp, 8
    test eax, eax
    js .stat_failed
    mov eax, [esp + 28]
    leave
    ret

.stat_failed:
    mov eax, [ebp + 12]
    mov ebx, [eax]
    push ebx
    call close
    add esp, 4

.open_failed:
    mov edx, [ebp + 12]
    mov dword [edx], -1
    mov eax, -1
    leave
    ret

Sys_FileOpenWrite:
    push ebp
    mov ebp, esp
    push dword 0666o
    push dword O_RDWR | O_CREAT | O_TRUNC
    push dword [ebp + 8]
    call open
    add esp, 12
    pop ebp
    ret

Sys_FileClose:
    jmp close

Sys_FileSeek:
    push ebp
    mov ebp, esp
    push dword SEEK_SET
    push dword [ebp + 12]
    push dword [ebp + 8]
    call lseek
    add esp, 12
    pop ebp
    ret

Sys_FileRead:
    jmp read

Sys_FileWrite:
    jmp write

Sys_FileTime:
    push ebp
    mov ebp, esp
    sub esp, 44
    push dword esp
    push dword [ebp + 8]
    call stat
    add esp, 8
    test eax, eax
    js .missing
    mov eax, [esp + 36]
    test eax, eax
    jnz .done
    mov eax, 1
    jmp .done

.missing:
    mov eax, -1

.done:
    leave
    ret

Sys_mkdir:
    push ebp
    mov ebp, esp
    push dword 0777o
    push dword [ebp + 8]
    call mkdir
    add esp, 8
    pop ebp
    ret

Sys_Error:
    push ebp
    mov ebp, esp
    push dword sys_error_prefix
    call printf
    add esp, 4
    lea eax, [ebp + 12]
    push eax
    push dword [ebp + 8]
    call vprintf
    add esp, 8
    push dword newline
    call printf
    add esp, 4
    call Host_Shutdown
    push dword 1
    call exit
    add esp, 4
    jmp $

Sys_Warn:
Sys_Printf:
    push ebp
    mov ebp, esp
    lea eax, [ebp + 12]
    push eax
    push dword [ebp + 8]
    call vprintf
    add esp, 8
    pop ebp
    ret

Sys_Quit:
    call Host_Shutdown
    push dword 0
    call exit
    add esp, 4
    jmp $

Sys_FloatTime:
    push ebp
    mov ebp, esp
    call vibe_monotonic_milliseconds
    mov [float_time_milliseconds], eax
    fild dword [float_time_milliseconds]
    fidiv dword [milliseconds_per_second]
    pop ebp
    ret

Sys_ConsoleInput:
    xor eax, eax
    ret

section .data

global isDedicated
global nostdout
global basedir
global cachedir
global sys_linerefresh

float_time_milliseconds dd 0
milliseconds_per_second dd 1000
isDedicated dd 0
nostdout dd 0
basedir dd basedir_text
cachedir dd 0
sys_linerefresh:
    dd sys_linerefresh_name
    dd sys_linerefresh_value
    dd 0
    dd 0
    dd 0
    dd 0

basedir_text db "", 0
sys_linerefresh_name db "sys_linerefresh", 0
sys_linerefresh_value db "0", 0
sys_error_prefix db "Sys_Error: ", 0
newline db 10, 0
