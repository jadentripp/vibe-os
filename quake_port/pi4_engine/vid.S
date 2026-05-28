#include "pi4_runtime.h"

.arch armv8-a

.equ BASEWIDTH,        320
.equ BASEHEIGHT,       200
.equ PALETTE_BYTES,    768
.equ SURFCACHE_BYTES,  262144
.equ VID_BUFFER,       0
.equ VID_COLORMAP,     8
.equ VID_COLORMAP16,   16
.equ VID_FULLBRIGHT,   24
.equ VID_ROWBYTES,     28
.equ VID_WIDTH,        32
.equ VID_HEIGHT,       36
.equ VID_ASPECT,       40
.equ VID_NUMPAGES,     44
.equ VID_RECALC,       48
.equ VID_CONBUFFER,    56
.equ VID_CONROWBYTES,  64
.equ VID_CONWIDTH,     68
.equ VID_CONHEIGHT,    72
.equ VID_MAXWARPWIDTH, 76
.equ VID_MAXWARPHEIGHT,80
.equ VID_DIRECT,       88
.equ VID_BYTES,        96

.extern D_InitCaches
.extern vibe_user_present_indexed
.extern vibe_user_present_indexed_checked

.section .text.pi4_quake_engine.vid, "ax", %progbits

.balign 16
.global VID_SetPalette
.global VID_ShiftPalette
.type VID_SetPalette, %function
.type VID_ShiftPalette, %function
VID_SetPalette:
VID_ShiftPalette:
    cbz x0, .Lvid_set_palette_done
    adrp x1, quake_palette
    add x1, x1, :lo12:quake_palette
    mov x2, #PALETTE_BYTES
.Lvid_set_palette_loop:
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    subs x2, x2, #1
    b.ne .Lvid_set_palette_loop
.Lvid_set_palette_done:
    ret
.size VID_SetPalette, . - VID_SetPalette
.size VID_ShiftPalette, . - VID_ShiftPalette

.balign 16
.global VID_Init
.type VID_Init, %function
VID_Init:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    bl VID_SetPalette

    adrp x19, vid
    add x19, x19, :lo12:vid
    adrp x9, vid_buffer
    add x9, x9, :lo12:vid_buffer
    str x9, [x19, #VID_BUFFER]
    str x9, [x19, #VID_CONBUFFER]

    adrp x10, host_colormap
    add x10, x10, :lo12:host_colormap
    ldr x10, [x10]
    str x10, [x19, #VID_COLORMAP]
    cbz x10, .Lvid_no_colormap
    ldr w11, [x10, #8192]
    mov w12, #256
    sub w11, w12, w11
    str w11, [x19, #VID_FULLBRIGHT]
.Lvid_no_colormap:
    str xzr, [x19, #VID_COLORMAP16]
    mov w9, #BASEWIDTH
    str w9, [x19, #VID_ROWBYTES]
    str w9, [x19, #VID_WIDTH]
    str w9, [x19, #VID_CONROWBYTES]
    str w9, [x19, #VID_CONWIDTH]
    str w9, [x19, #VID_MAXWARPWIDTH]
    mov w9, #BASEHEIGHT
    str w9, [x19, #VID_HEIGHT]
    str w9, [x19, #VID_CONHEIGHT]
    str w9, [x19, #VID_MAXWARPHEIGHT]
    adrp x9, .Lfloat_one
    add x9, x9, :lo12:.Lfloat_one
    ldr w9, [x9]
    str w9, [x19, #VID_ASPECT]
    mov w9, #1
    str w9, [x19, #VID_NUMPAGES]
    str wzr, [x19, #VID_RECALC]
    adrp x9, vid_buffer
    add x9, x9, :lo12:vid_buffer
    str x9, [x19, #VID_DIRECT]

    adrp x9, d_pzbuffer
    add x9, x9, :lo12:d_pzbuffer
    adrp x10, zbuffer
    add x10, x10, :lo12:zbuffer
    str x10, [x9]

    adrp x0, surfcache
    add x0, x0, :lo12:surfcache
    mov x1, #SURFCACHE_BYTES
    bl D_InitCaches

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size VID_Init, . - VID_Init

.balign 16
.global VID_Update
.global pi4_quake_present_assets_ready_frame
.global pi4_quake_present_audio_ready_frame
.global pi4_quake_present_engine_ready_frame
.global pi4_quake_present_heap_error_frame
.global pi4_quake_present_host_init_frame
.global pi4_quake_present_startup_frame
.global pi4_quake_present_missing_pak_frame
.global pi4_quake_present_runtime_error_frame
.type VID_Update, %function
.type pi4_quake_present_assets_ready_frame, %function
.type pi4_quake_present_audio_ready_frame, %function
.type pi4_quake_present_engine_ready_frame, %function
.type pi4_quake_present_heap_error_frame, %function
.type pi4_quake_present_host_init_frame, %function
.type pi4_quake_present_startup_frame, %function
.type pi4_quake_present_missing_pak_frame, %function
.type pi4_quake_present_runtime_error_frame, %function
VID_Update:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    bl .Lvid_stamp_frame_progress
    adrp x19, quake_present_desc
    add x19, x19, :lo12:quake_present_desc
    mov x0, x19
    bl vibe_user_present_indexed
.Lvid_update_store_result:
    bl .Lvid_record_present_result
    bl .Lvid_record_engine_frame_result
.Lvid_update_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size VID_Update, . - VID_Update

.balign 16
pi4_quake_present_startup_frame:
    mov x0, xzr
    b .Lvid_present_progress_frame
.size pi4_quake_present_startup_frame, . - pi4_quake_present_startup_frame

.balign 16
pi4_quake_present_missing_pak_frame:
    mov x0, #1
    b .Lvid_present_progress_frame
.size pi4_quake_present_missing_pak_frame, . - pi4_quake_present_missing_pak_frame

.balign 16
pi4_quake_present_runtime_error_frame:
    mov x0, #2
    b .Lvid_present_progress_frame
.size pi4_quake_present_runtime_error_frame, . - pi4_quake_present_runtime_error_frame

.balign 16
pi4_quake_present_assets_ready_frame:
    mov x0, #3
    b .Lvid_present_progress_frame
.size pi4_quake_present_assets_ready_frame, . - pi4_quake_present_assets_ready_frame

.balign 16
pi4_quake_present_audio_ready_frame:
    mov x0, #7
    b .Lvid_present_progress_frame
.size pi4_quake_present_audio_ready_frame, . - pi4_quake_present_audio_ready_frame

.balign 16
pi4_quake_present_engine_ready_frame:
    mov x0, #4
    b .Lvid_present_progress_frame
.size pi4_quake_present_engine_ready_frame, . - pi4_quake_present_engine_ready_frame

.balign 16
pi4_quake_present_heap_error_frame:
    mov x0, #5
    b .Lvid_present_progress_frame
.size pi4_quake_present_heap_error_frame, . - pi4_quake_present_heap_error_frame

.balign 16
pi4_quake_present_host_init_frame:
    mov x0, #6
    b .Lvid_present_progress_frame
.size pi4_quake_present_host_init_frame, . - pi4_quake_present_host_init_frame

.Lvid_present_progress_frame:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0
    bl .Lvid_progress_palette
    mov x0, x19
    bl .Lvid_progress_pixels
    adrp x0, quake_present_desc
    add x0, x0, :lo12:quake_present_desc
    bl vibe_user_present_indexed_checked
    cmp x0, #0
    b.ge .Lvid_progress_record
    adrp x0, quake_present_desc
    add x0, x0, :lo12:quake_present_desc
    bl vibe_user_present_indexed
.Lvid_progress_record:
    adrp x9, quake_present_last_progress_kind
    add x9, x9, :lo12:quake_present_last_progress_kind
    str x19, [x9]
    bl .Lvid_record_present_result
    adrp x9, quake_present_progress_count
    add x9, x9, :lo12:quake_present_progress_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    cmp x19, #1
    b.eq .Lvid_progress_missing_pak_count
    cmp x19, #2
    b.eq .Lvid_progress_runtime_error_count
    cmp x19, #3
    b.eq .Lvid_progress_assets_ready_count
    cmp x19, #4
    b.eq .Lvid_progress_engine_ready_count
    cmp x19, #5
    b.eq .Lvid_progress_heap_error_count
    cmp x19, #6
    b.eq .Lvid_progress_host_init_count
    adrp x9, quake_present_startup_count
    add x9, x9, :lo12:quake_present_startup_count
    b .Lvid_progress_count_kind
.Lvid_progress_missing_pak_count:
    adrp x9, quake_present_missing_pak_count
    add x9, x9, :lo12:quake_present_missing_pak_count
    b .Lvid_progress_count_kind
.Lvid_progress_runtime_error_count:
    adrp x9, quake_present_runtime_error_count
    add x9, x9, :lo12:quake_present_runtime_error_count
    b .Lvid_progress_count_kind
.Lvid_progress_assets_ready_count:
    adrp x9, quake_present_assets_ready_count
    add x9, x9, :lo12:quake_present_assets_ready_count
    b .Lvid_progress_count_kind
.Lvid_progress_engine_ready_count:
    adrp x9, quake_present_engine_ready_count
    add x9, x9, :lo12:quake_present_engine_ready_count
    b .Lvid_progress_count_kind
.Lvid_progress_heap_error_count:
    adrp x9, quake_present_heap_error_count
    add x9, x9, :lo12:quake_present_heap_error_count
    b .Lvid_progress_count_kind
.Lvid_progress_host_init_count:
    adrp x9, quake_present_host_init_count
    add x9, x9, :lo12:quake_present_host_init_count
.Lvid_progress_count_kind:
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

.Lvid_record_present_result:
    adrp x9, quake_present_last_result
    add x9, x9, :lo12:quake_present_last_result
    str x0, [x9]
    adrp x9, quake_present_count
    add x9, x9, :lo12:quake_present_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    cmp x0, #0
    b.ge .Lvid_record_present_done
    adrp x9, quake_present_fail_count
    add x9, x9, :lo12:quake_present_fail_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
.Lvid_record_present_done:
    ret

.Lvid_record_engine_frame_result:
    adrp x9, quake_present_engine_frame_count
    add x9, x9, :lo12:quake_present_engine_frame_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    cmp x0, #0
    b.ge .Lvid_record_engine_frame_first
    adrp x9, quake_present_engine_frame_fail_count
    add x9, x9, :lo12:quake_present_engine_frame_fail_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
.Lvid_record_engine_frame_first:
    adrp x9, quake_present_first_engine_frame_count
    add x9, x9, :lo12:quake_present_first_engine_frame_count
    ldr x10, [x9]
    cbnz x10, .Lvid_record_first_engine_frame_done
    mov x10, #1
    str x10, [x9]
    cmp x0, #0
    b.ge .Lvid_record_first_engine_frame_done
    adrp x9, quake_present_first_engine_frame_fail_count
    add x9, x9, :lo12:quake_present_first_engine_frame_fail_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
.Lvid_record_first_engine_frame_done:
    ret

.Lvid_stamp_frame_progress:
    adrp x9, quake_present_engine_frame_stamp
    add x9, x9, :lo12:quake_present_engine_frame_stamp
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    and x11, x10, #7
    add x11, x11, #8
    and x12, x10, #31
    add x12, x12, #(BASEWIDTH - 40)
    adrp x13, vid_buffer
    add x13, x13, :lo12:vid_buffer
    mov x14, #BASEWIDTH
    mul x15, x11, x14
    add x13, x13, x15
    add x13, x13, x12
    and x16, x10, #3
    add x16, x16, #3
    strb w16, [x13]
    add x13, x13, #1
    add x16, x16, #1
    and x16, x16, #7
    cbnz x16, .Lvid_stamp_mid_nonzero
    mov x16, #7
.Lvid_stamp_mid_nonzero:
    strb w16, [x13]
    add x13, x13, #1
    add x16, x16, #1
    and x16, x16, #7
    cbnz x16, .Lvid_stamp_tail_nonzero
    mov x16, #6
.Lvid_stamp_tail_nonzero:
    strb w16, [x13]
    ret

.Lvid_progress_palette:
    adrp x9, quake_palette
    add x9, x9, :lo12:quake_palette
    mov x10, #256
.Lvid_progress_palette_clear:
    strb wzr, [x9], #1
    strb wzr, [x9], #1
    strb wzr, [x9], #1
    subs x10, x10, #1
    b.ne .Lvid_progress_palette_clear
    adrp x9, quake_palette
    add x9, x9, :lo12:quake_palette

    add x10, x9, #(1 * 3)
    mov w11, #0x10
    strb w11, [x10]
    mov w11, #0x28
    strb w11, [x10, #1]
    mov w11, #0x50
    strb w11, [x10, #2]

    add x10, x9, #(2 * 3)
    mov w11, #0x08
    strb w11, [x10]
    mov w11, #0x58
    strb w11, [x10, #1]
    mov w11, #0x5c
    strb w11, [x10, #2]

    add x10, x9, #(3 * 3)
    mov w11, #0xf0
    strb w11, [x10]
    mov w11, #0xb8
    strb w11, [x10, #1]
    mov w11, #0x30
    strb w11, [x10, #2]

    add x10, x9, #(4 * 3)
    mov w11, #0xa8
    strb w11, [x10]
    mov w11, #0x20
    strb w11, [x10, #1]
    mov w11, #0x24
    strb w11, [x10, #2]

    add x10, x9, #(5 * 3)
    mov w11, #0xe8
    strb w11, [x10]
    mov w11, #0xe8
    strb w11, [x10, #1]
    strb w11, [x10, #2]

    add x10, x9, #(6 * 3)
    mov w11, #0x2c
    strb w11, [x10]
    mov w11, #0x34
    strb w11, [x10, #1]
    mov w11, #0x3c
    strb w11, [x10, #2]

    add x10, x9, #(7 * 3)
    mov w11, #0x40
    strb w11, [x10]
    mov w11, #0xb8
    strb w11, [x10, #1]
    mov w11, #0x68
    strb w11, [x10, #2]
    ret

.Lvid_progress_pixels:
    adrp x9, vid_buffer
    add x9, x9, :lo12:vid_buffer
    mov x10, xzr
.Lvid_progress_row:
    mov x11, xzr
.Lvid_progress_col:
    cbnz x0, .Lvid_progress_non_startup_pixel
    lsr x12, x10, #4
    lsr x13, x11, #5
    eor x12, x12, x13
    and x12, x12, #1
    add x12, x12, #1
    cmp x10, #168
    b.hs .Lvid_progress_startup_status_pixel
    cmp x10, #96
    b.lo .Lvid_progress_startup_window
    cmp x10, #104
    b.hs .Lvid_progress_startup_window
    cmp x11, #150
    b.lo .Lvid_progress_startup_window
    cmp x11, #170
    b.hs .Lvid_progress_startup_window
    mov x12, #5
    b .Lvid_progress_store_pixel
.Lvid_progress_startup_window:
    cmp x10, #72
    b.lo .Lvid_progress_store_pixel
    cmp x10, #128
    b.hs .Lvid_progress_store_pixel
    cmp x11, #56
    b.lo .Lvid_progress_store_pixel
    cmp x11, #264
    b.hs .Lvid_progress_store_pixel
    mov x12, #3
    b .Lvid_progress_store_pixel
.Lvid_progress_startup_status_pixel:
    mov x12, #6
    cmp x11, #12
    b.lo .Lvid_progress_store_pixel
    cmp x11, #78
    b.lo .Lvid_progress_startup_health_pixel
    cmp x11, #242
    b.lo .Lvid_progress_store_pixel
    cmp x11, #308
    b.hs .Lvid_progress_store_pixel
    mov x12, #3
    b .Lvid_progress_store_pixel
.Lvid_progress_startup_health_pixel:
    mov x12, #7
    b .Lvid_progress_store_pixel
.Lvid_progress_non_startup_pixel:
    cmp x0, #1
    b.eq .Lvid_progress_missing_pixel
    cmp x0, #2
    b.eq .Lvid_progress_runtime_error_pixel
    cmp x0, #3
    b.eq .Lvid_progress_assets_ready_pixel
    cmp x0, #4
    b.eq .Lvid_progress_engine_ready_pixel
    cmp x0, #6
    b.eq .Lvid_progress_host_init_pixel
    cmp x0, #7
    b.eq .Lvid_progress_audio_ready_pixel
    b .Lvid_progress_heap_error_pixel
.Lvid_progress_missing_pixel:
    mov x12, #4
    cmp x10, #8
    b.lo .Lvid_progress_missing_border
    cmp x10, #192
    b.hs .Lvid_progress_missing_border
    cmp x11, #8
    b.lo .Lvid_progress_missing_border
    cmp x11, #312
    b.hs .Lvid_progress_missing_border
    cmp x10, #68
    b.lo .Lvid_progress_missing_panel_done
    cmp x10, #132
    b.hs .Lvid_progress_missing_panel_done
    cmp x11, #40
    b.lo .Lvid_progress_missing_panel_done
    cmp x11, #280
    b.hs .Lvid_progress_missing_panel_done
    mov x12, xzr
    b .Lvid_progress_store_pixel
.Lvid_progress_missing_border:
    mov x12, #5
.Lvid_progress_missing_panel_done:
    b .Lvid_progress_store_pixel
.Lvid_progress_runtime_error_pixel:
    mov x12, #6
    cmp x10, #8
    b.lo .Lvid_progress_runtime_error_border
    cmp x10, #192
    b.hs .Lvid_progress_runtime_error_border
    cmp x11, #8
    b.lo .Lvid_progress_runtime_error_border
    cmp x11, #312
    b.hs .Lvid_progress_runtime_error_border
    cmp x10, #60
    b.lo .Lvid_progress_store_pixel
    cmp x10, #140
    b.hs .Lvid_progress_store_pixel
    cmp x11, #48
    b.lo .Lvid_progress_store_pixel
    cmp x11, #272
    b.hs .Lvid_progress_store_pixel
    mov x12, xzr
    cmp x10, #86
    b.lo .Lvid_progress_store_pixel
    cmp x10, #114
    b.hs .Lvid_progress_store_pixel
    cmp x11, #72
    b.lo .Lvid_progress_store_pixel
    cmp x11, #248
    b.hs .Lvid_progress_store_pixel
    mov x12, #4
    b .Lvid_progress_store_pixel
.Lvid_progress_runtime_error_border:
    mov x12, #4
    b .Lvid_progress_store_pixel
.Lvid_progress_assets_ready_pixel:
    mov x12, #2
    cmp x10, #10
    b.lo .Lvid_progress_assets_border
    cmp x10, #190
    b.hs .Lvid_progress_assets_border
    cmp x11, #10
    b.lo .Lvid_progress_assets_border
    cmp x11, #310
    b.hs .Lvid_progress_assets_border
    cmp x10, #154
    b.lo .Lvid_progress_assets_panel
    cmp x10, #178
    b.hs .Lvid_progress_assets_panel
    cmp x11, #18
    b.lo .Lvid_progress_assets_panel
    cmp x11, #98
    b.lo .Lvid_progress_assets_bar_done
    cmp x11, #110
    b.lo .Lvid_progress_assets_panel
    cmp x11, #190
    b.lo .Lvid_progress_assets_bar_done
    cmp x11, #202
    b.lo .Lvid_progress_assets_panel
    cmp x11, #302
    b.hs .Lvid_progress_assets_panel
.Lvid_progress_assets_bar_done:
    mov x12, #7
    b .Lvid_progress_store_pixel
.Lvid_progress_assets_panel:
    cmp x10, #50
    b.lo .Lvid_progress_store_pixel
    cmp x10, #136
    b.hs .Lvid_progress_store_pixel
    cmp x11, #38
    b.lo .Lvid_progress_store_pixel
    cmp x11, #282
    b.hs .Lvid_progress_store_pixel
    mov x12, #6
    cmp x10, #70
    b.lo .Lvid_progress_store_pixel
    cmp x10, #116
    b.hs .Lvid_progress_store_pixel
    cmp x11, #68
    b.lo .Lvid_progress_store_pixel
    cmp x11, #252
    b.hs .Lvid_progress_store_pixel
    mov x12, #7
    cmp x11, #100
    b.lo .Lvid_progress_store_pixel
    cmp x11, #220
    b.hs .Lvid_progress_store_pixel
    mov x12, #5
    b .Lvid_progress_store_pixel
.Lvid_progress_assets_border:
    mov x12, #7
    b .Lvid_progress_store_pixel
.Lvid_progress_engine_ready_pixel:
    mov x12, #1
    cmp x10, #10
    b.lo .Lvid_progress_engine_border
    cmp x10, #190
    b.hs .Lvid_progress_engine_border
    cmp x11, #10
    b.lo .Lvid_progress_engine_border
    cmp x11, #310
    b.hs .Lvid_progress_engine_border
    cmp x10, #154
    b.lo .Lvid_progress_engine_window
    cmp x10, #178
    b.hs .Lvid_progress_engine_window
    cmp x11, #18
    b.lo .Lvid_progress_engine_window
    cmp x11, #302
    b.hs .Lvid_progress_engine_window
    mov x12, #7
    b .Lvid_progress_store_pixel
.Lvid_progress_engine_window:
    cmp x10, #42
    b.lo .Lvid_progress_store_pixel
    cmp x10, #150
    b.hs .Lvid_progress_store_pixel
    cmp x11, #30
    b.lo .Lvid_progress_store_pixel
    cmp x11, #290
    b.hs .Lvid_progress_store_pixel
    mov x12, #3
    cmp x10, #56
    b.lo .Lvid_progress_store_pixel
    cmp x10, #136
    b.hs .Lvid_progress_store_pixel
    cmp x11, #46
    b.lo .Lvid_progress_store_pixel
    cmp x11, #274
    b.hs .Lvid_progress_store_pixel
    mov x12, xzr
    cmp x10, #92
    b.lo .Lvid_progress_engine_crosshair_col
    cmp x10, #108
    b.hs .Lvid_progress_engine_crosshair_col
    cmp x11, #110
    b.lo .Lvid_progress_engine_crosshair_col
    cmp x11, #210
    b.hs .Lvid_progress_engine_crosshair_col
    mov x12, #5
    b .Lvid_progress_store_pixel
.Lvid_progress_engine_crosshair_col:
    cmp x11, #152
    b.lo .Lvid_progress_store_pixel
    cmp x11, #168
    b.hs .Lvid_progress_store_pixel
    cmp x10, #70
    b.lo .Lvid_progress_store_pixel
    cmp x10, #130
    b.hs .Lvid_progress_store_pixel
    mov x12, #5
    b .Lvid_progress_store_pixel
.Lvid_progress_engine_border:
    mov x12, #3
    b .Lvid_progress_store_pixel
.Lvid_progress_host_init_pixel:
    mov x12, #2
    cmp x10, #10
    b.lo .Lvid_progress_host_init_border
    cmp x10, #190
    b.hs .Lvid_progress_host_init_border
    cmp x11, #10
    b.lo .Lvid_progress_host_init_border
    cmp x11, #310
    b.hs .Lvid_progress_host_init_border
    cmp x10, #42
    b.lo .Lvid_progress_store_pixel
    cmp x10, #154
    b.hs .Lvid_progress_store_pixel
    cmp x11, #28
    b.lo .Lvid_progress_store_pixel
    cmp x11, #292
    b.hs .Lvid_progress_store_pixel
    mov x12, #6
    cmp x10, #56
    b.lo .Lvid_progress_store_pixel
    cmp x10, #140
    b.hs .Lvid_progress_store_pixel
    cmp x11, #44
    b.lo .Lvid_progress_store_pixel
    cmp x11, #276
    b.hs .Lvid_progress_store_pixel
    mov x12, #1
    cmp x10, #86
    b.lo .Lvid_progress_store_pixel
    cmp x10, #118
    b.hs .Lvid_progress_store_pixel
    cmp x11, #70
    b.lo .Lvid_progress_store_pixel
    cmp x11, #250
    b.hs .Lvid_progress_store_pixel
    mov x12, #3
    lsr x13, x11, #4
    and x13, x13, #1
    cbnz x13, .Lvid_progress_store_pixel
    mov x12, #7
    b .Lvid_progress_store_pixel
.Lvid_progress_host_init_border:
    mov x12, #7
    b .Lvid_progress_store_pixel
.Lvid_progress_audio_ready_pixel:
    mov x12, #6
    cmp x10, #10
    b.lo .Lvid_progress_audio_ready_border
    cmp x10, #190
    b.hs .Lvid_progress_audio_ready_border
    cmp x11, #10
    b.lo .Lvid_progress_audio_ready_border
    cmp x11, #310
    b.hs .Lvid_progress_audio_ready_border
    cmp x10, #52
    b.lo .Lvid_progress_store_pixel
    cmp x10, #146
    b.hs .Lvid_progress_store_pixel
    cmp x11, #34
    b.lo .Lvid_progress_store_pixel
    cmp x11, #286
    b.hs .Lvid_progress_store_pixel
    mov x12, #2
    cmp x10, #82
    b.lo .Lvid_progress_store_pixel
    cmp x10, #118
    b.hs .Lvid_progress_store_pixel
    cmp x11, #62
    b.lo .Lvid_progress_store_pixel
    cmp x11, #258
    b.hs .Lvid_progress_store_pixel
    mov x12, #7
    lsr x13, x11, #5
    and x13, x13, #1
    cbnz x13, .Lvid_progress_store_pixel
    mov x12, #3
    b .Lvid_progress_store_pixel
.Lvid_progress_audio_ready_border:
    mov x12, #7
    b .Lvid_progress_store_pixel
.Lvid_progress_heap_error_pixel:
    mov x12, #4
    cmp x10, #6
    b.lo .Lvid_progress_heap_error_border
    cmp x10, #194
    b.hs .Lvid_progress_heap_error_border
    cmp x11, #6
    b.lo .Lvid_progress_heap_error_border
    cmp x11, #314
    b.hs .Lvid_progress_heap_error_border
    cmp x10, #58
    b.lo .Lvid_progress_store_pixel
    cmp x10, #142
    b.hs .Lvid_progress_store_pixel
    cmp x11, #44
    b.lo .Lvid_progress_store_pixel
    cmp x11, #276
    b.hs .Lvid_progress_store_pixel
    mov x12, xzr
    cmp x10, #80
    b.lo .Lvid_progress_store_pixel
    cmp x10, #120
    b.hs .Lvid_progress_store_pixel
    cmp x11, #70
    b.lo .Lvid_progress_store_pixel
    cmp x11, #250
    b.hs .Lvid_progress_store_pixel
    mov x12, #3
    cmp x11, #108
    b.lo .Lvid_progress_store_pixel
    cmp x11, #212
    b.hs .Lvid_progress_store_pixel
    mov x12, #5
    b .Lvid_progress_store_pixel
.Lvid_progress_heap_error_border:
    mov x12, #5
.Lvid_progress_store_pixel:
    cmp x10, #184
    b.lo .Lvid_progress_store_pixel_raw
    cmp x10, #196
    b.hs .Lvid_progress_store_pixel_raw
    cmp x11, #16
    b.lo .Lvid_progress_store_pixel_raw
    cmp x11, #304
    b.hs .Lvid_progress_store_pixel_raw
    cmp x10, #186
    b.lo .Lvid_progress_rail_border
    cmp x10, #194
    b.hs .Lvid_progress_rail_border
    cmp x11, #20
    b.lo .Lvid_progress_rail_border
    cmp x11, #300
    b.hs .Lvid_progress_rail_border
    mov x13, #84
    cbz x0, .Lvid_progress_rail_choose_fill
    cmp x0, #3
    b.ne .Lvid_progress_rail_check_host_init
    mov x13, #188
    b .Lvid_progress_rail_choose_fill
.Lvid_progress_rail_check_host_init:
    cmp x0, #6
    b.ne .Lvid_progress_rail_check_engine_ready
    mov x13, #224
    b .Lvid_progress_rail_choose_fill
.Lvid_progress_rail_check_engine_ready:
    cmp x0, #4
    b.ne .Lvid_progress_rail_check_error
    mov x13, #268
    b .Lvid_progress_rail_choose_fill
.Lvid_progress_rail_check_error:
    cmp x0, #7
    b.ne .Lvid_progress_rail_check_real_error
    mov x13, #208
    b .Lvid_progress_rail_choose_fill
.Lvid_progress_rail_check_real_error:
    cmp x0, #1
    b.eq .Lvid_progress_rail_full_error
    cmp x0, #2
    b.eq .Lvid_progress_rail_full_error
    cmp x0, #5
    b.ne .Lvid_progress_rail_choose_fill
.Lvid_progress_rail_full_error:
    mov x13, #300
.Lvid_progress_rail_choose_fill:
    cmp x11, x13
    b.hs .Lvid_progress_rail_track
    cmp x0, #1
    b.eq .Lvid_progress_rail_error_fill
    cmp x0, #2
    b.eq .Lvid_progress_rail_error_fill
    cmp x0, #5
    b.eq .Lvid_progress_rail_error_fill
    mov x12, #7
    b .Lvid_progress_store_pixel_raw
.Lvid_progress_rail_error_fill:
    mov x12, #4
    b .Lvid_progress_store_pixel_raw
.Lvid_progress_rail_track:
    mov x12, #6
    b .Lvid_progress_store_pixel_raw
.Lvid_progress_rail_border:
    cmp x0, #1
    b.eq .Lvid_progress_rail_error_border
    cmp x0, #2
    b.eq .Lvid_progress_rail_error_border
    cmp x0, #5
    b.eq .Lvid_progress_rail_error_border
    mov x12, #5
    b .Lvid_progress_store_pixel_raw
.Lvid_progress_rail_error_border:
    mov x12, #4
.Lvid_progress_store_pixel_raw:
    strb w12, [x9], #1
    add x11, x11, #1
    cmp x11, #BASEWIDTH
    b.lo .Lvid_progress_col
    add x10, x10, #1
    cmp x10, #BASEHEIGHT
    b.lo .Lvid_progress_row
    ret

.balign 16
.global D_BeginDirectRect
.global D_EndDirectRect
.global VID_HandlePause
.global VID_SetMode
.global VID_Shutdown
.type D_BeginDirectRect, %function
.type D_EndDirectRect, %function
.type VID_HandlePause, %function
.type VID_SetMode, %function
.type VID_Shutdown, %function
D_BeginDirectRect:
D_EndDirectRect:
VID_HandlePause:
VID_Shutdown:
    ret
VID_SetMode:
    mov x0, #1
    ret
.size D_BeginDirectRect, . - D_BeginDirectRect
.size D_EndDirectRect, . - D_EndDirectRect
.size VID_HandlePause, . - VID_HandlePause
.size VID_SetMode, . - VID_SetMode
.size VID_Shutdown, . - VID_Shutdown

.section .rodata.pi4_quake_engine.vid, "a", %progbits
.balign 4
.Lfloat_one:
    .float 1.0

.section .data.pi4_quake_engine.vid, "aw", %progbits
.balign 8
quake_present_desc:
    .quad vid_buffer
    .quad quake_palette
    .quad BASEWIDTH
    .quad BASEHEIGHT

.section .bss.pi4_quake_engine.vid, "aw", %nobits
.balign 16
.global vid
.global d_pzbuffer
.global host_colormap
.global d_8to16table
.global d_8to24table
d_pzbuffer:
    .skip 8
host_colormap:
    .skip 8
vid:
    .skip VID_BYTES
vid_buffer:
    .skip BASEWIDTH * BASEHEIGHT
zbuffer:
    .skip BASEWIDTH * BASEHEIGHT * 2
surfcache:
    .skip SURFCACHE_BYTES
d_8to16table:
    .skip 256 * 2
.balign 8
d_8to24table:
    .skip 256 * 4
quake_palette:
    .skip PALETTE_BYTES
quake_present_last_result:
    .skip 8
quake_present_count:
    .skip 8
quake_present_fail_count:
    .skip 8
.global quake_present_engine_frame_count
.global quake_present_engine_frame_fail_count
.global quake_present_last_progress_kind
quake_present_engine_frame_count:
    .skip 8
quake_present_engine_frame_fail_count:
    .skip 8
quake_present_last_progress_kind:
    .skip 8
.global quake_present_progress_count
.global quake_present_startup_count
.global quake_present_missing_pak_count
.global quake_present_runtime_error_count
.global quake_present_assets_ready_count
.global quake_present_engine_ready_count
.global quake_present_heap_error_count
.global quake_present_host_init_count
.global quake_present_first_engine_frame_count
.global quake_present_first_engine_frame_fail_count
quake_present_progress_count:
    .skip 8
quake_present_startup_count:
    .skip 8
quake_present_missing_pak_count:
    .skip 8
quake_present_runtime_error_count:
    .skip 8
quake_present_assets_ready_count:
    .skip 8
quake_present_engine_ready_count:
    .skip 8
quake_present_heap_error_count:
    .skip 8
quake_present_host_init_count:
    .skip 8
quake_present_first_engine_frame_count:
    .skip 8
quake_present_first_engine_frame_fail_count:
    .skip 8
quake_present_engine_frame_stamp:
    .skip 8

.section .note.GNU-stack, "", %progbits
