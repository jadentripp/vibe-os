#include "pi4_runtime.h"

.arch armv8-a

.extern D_DoomMain
.extern myargc
.extern myargv
.extern pi4_doom_engine_mark_probe_done
.extern pi4_doom_engine_mark_selected
.extern vibe_user_file_probe_assets

.section .text.pi4_doom_engine.entry, "ax", %progbits
.balign 16
.global user_main
.global pi4_doom_engine_start
.type user_main, %function
.type pi4_doom_engine_start, %function
user_main:
pi4_doom_engine_start:
    stp x29, x30, [sp, #-32]!
    mov x29, sp

    bl pi4_doom_engine_mark_selected
    bl vibe_user_file_probe_assets
    bl pi4_doom_engine_mark_probe_done

    adrp x0, myargc
    add x0, x0, :lo12:myargc
    mov x1, #6
    str w1, [x0]

    adrp x0, myargv
    add x0, x0, :lo12:myargv
    adrp x1, pi4_doom_engine_argv
    add x1, x1, :lo12:pi4_doom_engine_argv
    str x1, [x0]

    bl D_DoomMain

    mov x0, xzr
    ldp x29, x30, [sp], #32
    ret
.size user_main, . - user_main
.size pi4_doom_engine_start, . - pi4_doom_engine_start

.section .rodata.pi4_doom_engine_manifest, "a", %progbits
.balign 8
.global pi4_doom_engine_manifest
pi4_doom_engine_manifest:
    .asciz "schema=vibe-os-pi4-doom-engine-bridge-v1"
    .asciz "app_exec=/APPS/DOOM/APP.ELF"
    .asciz "app_kind=doom"
    .asciz "app_arch=AARCH64"
    .asciz "doom_source=third_party/doom/linuxdoom-1.10"
    .asciz "doom_engine_link=linked-runtime-progress-real-frame-input"
    .asciz "doom_wad_access=pi4-file-open-size-chunked-runtime-read-abi-input-polled-counters"
    .asciz "doom_input_claim=wasd-arrows-qe-strafe-tab-menu-mouse"
    .asciz "doom_load_input_claim=keyboard-mouse-posted-during-runtime-wad-read"
    .asciz "doom_present_claim=every-engine-finish-update-with-frame-input-read-status"
    .asciz "doom_audio_claim=pcm-abi-probe-gated-no-sfx-mix-claim"
    .asciz "app_launch_claim=engine-entry-visible-progress"
    .asciz "vibe-os pi4 /APPS/DOOM/APP.ELF original Doom engine bridge with runtime WAD reads"

.balign 8
pi4_doom_engine_arg0:
    .asciz "/APPS/DOOM/APP.ELF"
pi4_doom_engine_arg_warp:
    .asciz "-warp"
pi4_doom_engine_arg_episode:
    .asciz "1"
pi4_doom_engine_arg_map:
    .asciz "1"
pi4_doom_engine_arg_skill:
    .asciz "-skill"
pi4_doom_engine_arg_skill_medium:
    .asciz "3"

.section .data.pi4_doom_engine_argv, "aw", %progbits
.balign 8
pi4_doom_engine_argv:
    .quad pi4_doom_engine_arg0
    .quad pi4_doom_engine_arg_warp
    .quad pi4_doom_engine_arg_episode
    .quad pi4_doom_engine_arg_map
    .quad pi4_doom_engine_arg_skill
    .quad pi4_doom_engine_arg_skill_medium
    .quad 0

.section .note.GNU-stack, "", %progbits
