#include "pi4_runtime.h"

// Entry glue for the experimental Pi 4 Quake engine payload bridge.
//
// This deliberately calls the original WinQuake Host_Init/Host_Frame path and
// relies on the Pi runtime ABI for VFS assets, input, video, audio, and ticks.

.arch armv8-a

.equ QUAKE_PARMS_MEMBASE, 32
.equ QUAKE_PARMS_MEMSIZE, 40
.equ K_CTRL, 133
.equ K_SPACE, 32
.equ K_MOUSE1, 200

.extern COM_InitArgv
.extern Host_Init
.extern Key_SetBinding
.extern SCR_EndLoadingPlaque
.extern Sys_FloatTime
.extern key_dest
.extern malloc
.extern pi4_quake_begin_default_game
.extern pi4_quake_force_game_view
.extern pi4_quake_host_frame
.extern quake_pump_input
.extern pi4_quake_present_assets_ready_frame
.extern pi4_quake_present_engine_ready_frame
.extern pi4_quake_present_heap_error_frame
.extern pi4_quake_present_host_init_frame
.extern pi4_quake_present_missing_pak_frame
.extern pi4_quake_present_runtime_error_frame
.extern pi4_quake_present_startup_frame
.extern vibe_user_close
.extern vibe_user_exit
.extern vibe_user_file_open
.extern VID_Update

.section .text.pi4_quake_engine.start, "ax", %progbits
.balign 16
.global user_main
.global pi4_quake_engine_start
.type user_main, %function
.type pi4_quake_engine_start, %function
user_main:
pi4_quake_engine_start:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    str x19, [sp, #16]

    bl pi4_quake_present_startup_frame
    bl pi4_quake_engine_preflight_assets
    cbz x0, .Lpi4_quake_engine_assets_ready
    mov x0, #1
    bl vibe_user_exit
.Lpi4_quake_engine_assets_ready:
    bl pi4_quake_present_assets_ready_frame

    mov x0, #4
    adrp x1, pi4_quake_engine_argv
    add x1, x1, :lo12:pi4_quake_engine_argv
    bl COM_InitArgv

    mov x0, xzr
    movk x0, #0x0080, lsl #16
    bl malloc
    cbz x0, .Lpi4_quake_engine_failed

    adrp x19, pi4_quake_engine_parms
    add x19, x19, :lo12:pi4_quake_engine_parms
    str x0, [x19, #QUAKE_PARMS_MEMBASE]
    mov x9, xzr
    movk x9, #0x0080, lsl #16
    str w9, [x19, #QUAKE_PARMS_MEMSIZE]

    bl pi4_quake_present_host_init_frame
    mov x0, x19
    bl Host_Init
    bl pi4_quake_engine_install_play_binds
    bl pi4_quake_begin_default_game
    bl pi4_quake_present_engine_ready_frame

    mov x20, #240
.Lpi4_quake_engine_warmup_loop:
    adrp x9, pi4_quake_engine_max_frame_seconds
    add x9, x9, :lo12:pi4_quake_engine_max_frame_seconds
    ldr s0, [x9]
    bl pi4_quake_host_frame
    bl pi4_quake_force_game_view
    subs x20, x20, #1
    b.ne .Lpi4_quake_engine_warmup_loop
    bl SCR_EndLoadingPlaque
    adrp x9, key_dest
    add x9, x9, :lo12:key_dest
    str wzr, [x9]

    adrp x9, pi4_quake_engine_frame_seconds
    add x9, x9, :lo12:pi4_quake_engine_frame_seconds
    ldr s0, [x9]
    bl pi4_quake_host_frame
    bl pi4_quake_force_game_view
    bl VID_Update
    bl Sys_FloatTime
    adrp x9, pi4_quake_engine_last_time
    add x9, x9, :lo12:pi4_quake_engine_last_time
    str d0, [x9]

.Lpi4_quake_engine_frame_loop:
    bl quake_pump_input
    bl Sys_FloatTime
    adrp x9, pi4_quake_engine_last_time
    add x9, x9, :lo12:pi4_quake_engine_last_time
    ldr d1, [x9]
    fsub d2, d0, d1
    fcmp d2, #0.0
    b.gt .Lpi4_quake_engine_check_min_tick
    yield
    b .Lpi4_quake_engine_frame_loop
.Lpi4_quake_engine_check_min_tick:
    adrp x10, pi4_quake_engine_frame_seconds_double
    add x10, x10, :lo12:pi4_quake_engine_frame_seconds_double
    ldr d3, [x10]
    fcmp d2, d3
    b.ge .Lpi4_quake_engine_check_max_tick
    yield
    b .Lpi4_quake_engine_frame_loop
.Lpi4_quake_engine_check_max_tick:
    str d0, [x9]
    adrp x9, pi4_quake_engine_max_frame_seconds_double
    add x9, x9, :lo12:pi4_quake_engine_max_frame_seconds_double
    ldr d3, [x9]
    fcmp d2, d3
    b.le .Lpi4_quake_engine_use_tick
    adrp x9, pi4_quake_engine_max_frame_seconds
    add x9, x9, :lo12:pi4_quake_engine_max_frame_seconds
    ldr s0, [x9]
    b .Lpi4_quake_engine_call_frame
.Lpi4_quake_engine_use_tick:
    fcvt s0, d2
.Lpi4_quake_engine_call_frame:
    bl pi4_quake_host_frame
    bl pi4_quake_force_game_view
    b .Lpi4_quake_engine_frame_loop

.Lpi4_quake_engine_failed:
    bl pi4_quake_present_heap_error_frame
    mov x0, #1
    bl vibe_user_exit

.Lpi4_quake_engine_halt:
    wfe
    b .Lpi4_quake_engine_halt
.size user_main, . - user_main
.size pi4_quake_engine_start, . - pi4_quake_engine_start

.balign 16
.type pi4_quake_engine_install_play_binds, %function
pi4_quake_engine_install_play_binds:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x0, #K_MOUSE1
    adrp x1, pi4_quake_bind_attack
    add x1, x1, :lo12:pi4_quake_bind_attack
    bl Key_SetBinding

    mov x0, #K_CTRL
    adrp x1, pi4_quake_bind_attack
    add x1, x1, :lo12:pi4_quake_bind_attack
    bl Key_SetBinding

    mov x0, #K_SPACE
    adrp x1, pi4_quake_bind_jump
    add x1, x1, :lo12:pi4_quake_bind_jump
    bl Key_SetBinding

    ldp x29, x30, [sp], #16
    ret
.size pi4_quake_engine_install_play_binds, . - pi4_quake_engine_install_play_binds

.balign 16
.type pi4_quake_engine_preflight_assets, %function
pi4_quake_engine_preflight_assets:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    adrp x0, pi4_quake_engine_pak0_path
    add x0, x0, :lo12:pi4_quake_engine_pak0_path
    bl vibe_user_file_open
    cmp x0, #0
    b.lt .Lpi4_quake_engine_preflight_missing_pak
    mov x19, x0
    bl vibe_user_close
    mov x0, xzr
    b .Lpi4_quake_engine_preflight_done

.Lpi4_quake_engine_preflight_missing_pak:
    bl pi4_quake_present_missing_pak_frame
    mov x0, #1
.Lpi4_quake_engine_preflight_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_quake_engine_preflight_assets, . - pi4_quake_engine_preflight_assets

.section .rodata.pi4_quake_engine_manifest, "a", %progbits
.balign 8
.global pi4_quake_engine_manifest
pi4_quake_engine_manifest:
    .asciz "schema=vibe-os-pi4-quake-engine-bridge-v1"
    .asciz "payload_file=PAYLOAD1.ELF"
    .asciz "payload_kind=quake"
    .asciz "payload_arch=AARCH64"
    .asciz "quake_original_source=compiled-aarch64"
    .asciz "quake_engine_hook=original-engine-runtime-bridge"
    .asciz "quake_asset_path=/ID1/PAK0.PAK"
    .asciz "quake_input_hook=wasd-arrows-mouse-fire-space-jump-escape-menu"
    .asciz "quake_progress_hook=startup-frame-before-host-init"
    .asciz "quake_progress_hook=pak-preflight-before-host-init"
    .asciz "quake_progress_hook=assets-ready-frame-after-pak-open"
    .asciz "quake_progress_hook=host-init-frame-after-heap-before-host-init"
    .asciz "quake_progress_hook=missing-pak-frame-on-open-failure"
    .asciz "quake_progress_hook=runtime-error-frame-from-port-runtime-failures"
    .asciz "quake_progress_hook=heap-error-frame-on-malloc-failure"
    .asciz "quake_progress_hook=engine-ready-frame-before-first-host-frame"
    .asciz "quake_progress_hook=first-host-frame-immediate-after-init"
    .asciz "quake_progress_hook=first-vid-update-immediate-after-first-host-frame"
    .asciz "quake_progress_hook=first-engine-vid-update-counted"
    .asciz "quake_progress_hook=engine-vid-update-counted-every-frame"
    .asciz "quake_progress_hook=progress-frame-kind-exported"
    .asciz "quake_input_hook=movement-view-action-counters-exported"
    .asciz "quake_progress_hook=frame-input-pak-counters-exported"
    .asciz "quake_first_frame_path=Host_Init-then-Host_Frame-then-VID_Update-before-loop"
    .asciz "quake_progress_note=guest-visible-status-hooks-only-no-hardware-proof"
    .asciz "quake_present_status=startup/assets-ready/host-init/engine-ready/missing-pak/runtime-error/heap-error"
    .asciz "vibe-os pi4 Quake AArch64 engine bridge"

.balign 4
pi4_quake_engine_frame_seconds:
    .float 0.016666668
pi4_quake_engine_max_frame_seconds:
    .float 0.05
.balign 8
pi4_quake_engine_frame_seconds_double:
    .double 0.016666666666666666
pi4_quake_engine_max_frame_seconds_double:
    .double 0.05
pi4_quake_bind_attack:
    .asciz "+attack"
pi4_quake_bind_jump:
    .asciz "+jump"
.section .data.pi4_quake_engine_start, "aw", %progbits
.balign 8
pi4_quake_engine_arg0:
    .asciz "vibe-quake"
pi4_quake_engine_arg_nocdaudio:
    .asciz "-nocdaudio"
pi4_quake_engine_arg_map:
    .asciz "+map"
pi4_quake_engine_arg_start:
    .asciz "start"
pi4_quake_engine_basedir:
    .asciz ""
pi4_quake_engine_pak0_path:
    .asciz "/ID1/PAK0.PAK"

.balign 8
pi4_quake_engine_argv:
    .quad pi4_quake_engine_arg0
    .quad pi4_quake_engine_arg_nocdaudio
    .quad pi4_quake_engine_arg_map
    .quad pi4_quake_engine_arg_start
    .quad 0

.balign 8
pi4_quake_engine_parms:
    .quad pi4_quake_engine_basedir
    .quad 0
    .word 4
    .word 0
    .quad pi4_quake_engine_argv
    .quad 0
    .word 0
    .word 0

.section .bss.pi4_quake_engine_start, "aw", %nobits
.balign 8
pi4_quake_engine_last_time:
    .skip 8

.section .note.GNU-stack, "", %progbits
