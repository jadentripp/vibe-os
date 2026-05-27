#include "pi4_runtime.h"

.arch armv8-a

.equ O_RDONLY, 0
.equ O_RDWR,   2
.equ O_CREAT,  0x0100
.equ O_TRUNC,  0x0200
.equ SEEK_SET, 0

.extern Host_Shutdown
.extern pi4_quake_file_open
.extern pi4_quake_file_read
.extern pi4_quake_file_seek
.extern pi4_quake_file_write
.extern quake_pump_input
.extern vibe_user_close
.extern vibe_user_clock_monotonic
.extern vibe_user_exit
.extern vibe_user_fstat
.extern vibe_user_file_open
.extern vibe_user_file_size
.extern vibe_user_stat
.extern vibe_user_syscall1
.extern vibe_user_syscall2
.extern vibe_user_syscall3

.section .text.pi4_quake_engine.sys, "ax", %progbits

.balign 16
.global open
.type open, %function
open:
    b pi4_quake_file_open
.size open, . - open

.balign 16
.global read
.type read, %function
read:
    b pi4_quake_file_read
.size read, . - read

.balign 16
.global write
.type write, %function
write:
    b pi4_quake_file_write
.size write, . - write

.balign 16
.global lseek
.type lseek, %function
lseek:
    b pi4_quake_file_seek
.size lseek, . - lseek

.balign 16
.global close
.type close, %function
close:
    b vibe_user_close
.size close, . - close

.balign 16
.global unlink
.type unlink, %function
unlink:
    mov x1, x0
    mov x0, #PI4_VIBE_SYS_UNLINK
    b vibe_user_syscall1
.size unlink, . - unlink

.balign 16
.global stat
.type stat, %function
stat:
    b vibe_user_stat
.size stat, . - stat

.balign 16
.global fstat
.type fstat, %function
fstat:
    b vibe_user_fstat
.size fstat, . - fstat

.balign 16
.global mkdir
.type mkdir, %function
mkdir:
    mov x0, #-PI4_VIBE_ENOSYS
    ret
.size mkdir, . - mkdir

.balign 16
.global Sys_FileOpenRead
.type Sys_FileOpenRead, %function
Sys_FileOpenRead:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x1
    mov x1, #O_RDONLY
    mov x2, xzr
    bl open
    cmp x0, #0
    b.lt .Lsys_file_open_read_fail
    mov x20, x0
    str w20, [x19]
    bl vibe_user_file_size
    cmp x0, #0
    b.ge .Lsys_file_open_read_done
    mov x0, x20
    bl close
    mov w9, #-1
    str w9, [x19]
    mov x0, #-1
    b .Lsys_file_open_read_done
.Lsys_file_open_read_fail:
    mov w9, #-1
    str w9, [x19]
    mov x0, #-1
.Lsys_file_open_read_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size Sys_FileOpenRead, . - Sys_FileOpenRead

.balign 16
.global Sys_FileOpenWrite
.type Sys_FileOpenWrite, %function
Sys_FileOpenWrite:
    mov x1, #(O_RDWR | O_CREAT | O_TRUNC)
    mov x2, #0666
    b open
.size Sys_FileOpenWrite, . - Sys_FileOpenWrite

.balign 16
.global Sys_FileClose
.type Sys_FileClose, %function
Sys_FileClose:
    b close
.size Sys_FileClose, . - Sys_FileClose

.balign 16
.global Sys_FileSeek
.type Sys_FileSeek, %function
Sys_FileSeek:
    mov x2, #SEEK_SET
    b lseek
.size Sys_FileSeek, . - Sys_FileSeek

.balign 16
.global Sys_FileRead
.type Sys_FileRead, %function
Sys_FileRead:
    b read
.size Sys_FileRead, . - Sys_FileRead

.balign 16
.global Sys_FileWrite
.type Sys_FileWrite, %function
Sys_FileWrite:
    b write
.size Sys_FileWrite, . - Sys_FileWrite

.balign 16
.global Sys_FileTime
.type Sys_FileTime, %function
Sys_FileTime:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x1, #O_RDONLY
    mov x2, xzr
    bl open
    cmp x0, #0
    b.lt .Lsys_file_time_missing
    bl close
    mov x0, #1
    b .Lsys_file_time_done
.Lsys_file_time_missing:
    mov x0, #-1
.Lsys_file_time_done:
    ldp x29, x30, [sp], #16
    ret
.size Sys_FileTime, . - Sys_FileTime

.balign 16
.global Sys_mkdir
.type Sys_mkdir, %function
Sys_mkdir:
    mov x1, #0777
    b mkdir
.size Sys_mkdir, . - Sys_mkdir

.balign 16
.global Sys_SendKeyEvents
.type Sys_SendKeyEvents, %function
Sys_SendKeyEvents:
    b quake_pump_input
.size Sys_SendKeyEvents, . - Sys_SendKeyEvents

.balign 16
.global Sys_FloatTime
.type Sys_FloatTime, %function
Sys_FloatTime:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    add x0, sp, #16
    bl vibe_user_clock_monotonic
    cbnz x0, .Lsys_float_time_zero
    ldr x0, [sp, #(16 + PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET)]
    ucvtf d0, x0
    adrp x9, .Lmilliseconds_per_second
    add x9, x9, :lo12:.Lmilliseconds_per_second
    ldr d1, [x9]
    fdiv d0, d0, d1
    b .Lsys_float_time_done
.Lsys_float_time_zero:
    fmov d0, xzr
.Lsys_float_time_done:
    ldp x29, x30, [sp], #48
    ret
.size Sys_FloatTime, . - Sys_FloatTime

.balign 16
.global Sys_ConsoleInput
.type Sys_ConsoleInput, %function
Sys_ConsoleInput:
    mov x0, xzr
    ret
.size Sys_ConsoleInput, . - Sys_ConsoleInput

.balign 16
.global Sys_Quit
.type Sys_Quit, %function
Sys_Quit:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl Host_Shutdown
    mov x0, xzr
    bl vibe_user_exit
    ldp x29, x30, [sp], #16
    ret
.size Sys_Quit, . - Sys_Quit

.balign 16
.global Sys_DebugNumber
.global Sys_DebugLog
.global Sys_HighFPPrecision
.global Sys_Init
.global Sys_LowFPPrecision
.global Sys_MakeCodeWriteable
.global Sys_SetFPCW
.global Sys_Sleep
.type Sys_DebugNumber, %function
.type Sys_DebugLog, %function
.type Sys_HighFPPrecision, %function
.type Sys_Init, %function
.type Sys_LowFPPrecision, %function
.type Sys_MakeCodeWriteable, %function
.type Sys_SetFPCW, %function
.type Sys_Sleep, %function
Sys_DebugNumber:
Sys_DebugLog:
Sys_HighFPPrecision:
Sys_Init:
Sys_LowFPPrecision:
Sys_MakeCodeWriteable:
Sys_SetFPCW:
Sys_Sleep:
    ret
.size Sys_DebugNumber, . - Sys_DebugNumber
.size Sys_DebugLog, . - Sys_DebugLog
.size Sys_HighFPPrecision, . - Sys_HighFPPrecision
.size Sys_Init, . - Sys_Init
.size Sys_LowFPPrecision, . - Sys_LowFPPrecision
.size Sys_MakeCodeWriteable, . - Sys_MakeCodeWriteable
.size Sys_SetFPCW, . - Sys_SetFPCW
.size Sys_Sleep, . - Sys_Sleep

.section .rodata.pi4_quake_engine.sys, "a", %progbits
.balign 8
.Lmilliseconds_per_second:
    .double 1000.0

.section .data.pi4_quake_engine.sys, "aw", %progbits
.balign 8
.global basedir
.global cachedir
.global isDedicated
.global nostdout
basedir:
    .quad .Lempty_basedir
cachedir:
    .quad 0
isDedicated:
    .word 0
nostdout:
    .word 0
.Lempty_basedir:
    .asciz ""

.section .note.GNU-stack, "", %progbits
