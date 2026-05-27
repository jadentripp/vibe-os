#include "pi4_runtime.h"

.arch armv8-a

.equ VIBE_AUDIO_FORMAT_U8_STEREO, 1
.equ VIBE_AUDIO_DEVICE_START, 1
.equ VIBE_AUDIO_DEVICE_SHUTDOWN, 5
.equ VIBE_AUDIO_PCM_BUFFERED_BYTES, 7
.equ VIBE_AUDIO_DEVICE_INFO, 9
.equ VIBE_AUDIO_PCM_RING_INFO, 10
.equ VIBE_AUDIO_STREAM_INFO, 11
.equ VIBE_AUDIO_PCM_WRITE_DESC, 13
.equ VIBE_AUDIO_PCM_OPEN, 14
.equ VIBE_AUDIO_PCM_DRAIN, 15
.equ VIBE_AUDIO_PCM_CLOSE, 16

.equ QUAKE_DMA_RATE, 11025
.equ QUAKE_DMA_CHANNELS, 2
.equ QUAKE_DMA_SAMPLEBITS, 8
.equ QUAKE_DMA_SAMPLES, 32768
.equ QUAKE_DMA_BYTES, QUAKE_DMA_SAMPLES
.equ QUAKE_DMA_SAMPLE_RATE_CHANNELS, 22050

.equ DMA_GAMEALIVE, 0
.equ DMA_SOUNDALIVE, 4
.equ DMA_SPLITBUFFER, 8
.equ DMA_CHANNELS, 12
.equ DMA_SAMPLES, 16
.equ DMA_SUBMISSION_CHUNK, 20
.equ DMA_SAMPLEPOS, 24
.equ DMA_SAMPLEBITS, 28
.equ DMA_SPEED, 32
.equ DMA_BUFFER, 40
.equ DMA_BYTES, 48

.equ PCM_DESC_SAMPLES, 0
.equ PCM_DESC_LENGTH, 8
.equ PCM_DESC_SAMPLE_RATE, 16
.equ PCM_DESC_CHANNELS, 24
.equ PCM_DESC_FORMAT, 32
.equ PCM_DESC_FLAGS, 40
.equ PCM_DESC_BYTES, 128
.equ AUDIO_DEVICE_INFO_KIND, 0
.equ AUDIO_DEVICE_INFO_STATUS, 8
.equ AUDIO_DEVICE_INFO_SAMPLE_RATE, 16
.equ AUDIO_DEVICE_INFO_CHANNELS, 24
.equ AUDIO_DEVICE_INFO_FORMAT, 32
.equ AUDIO_DEVICE_INFO_RING_BYTES, 40
.equ AUDIO_DEVICE_INFO_PERIOD_BYTES, 48
.equ AUDIO_DEVICE_INFO_CAPABILITIES, 56
.equ AUDIO_PCM_RING_INFO_FORMAT, 0
.equ AUDIO_PCM_RING_INFO_CHANNELS, 8
.equ AUDIO_PCM_RING_INFO_SAMPLE_RATE, 16
.equ AUDIO_PCM_RING_INFO_RING_BYTES, 24
.equ AUDIO_PCM_RING_INFO_PERIOD_BYTES, 32
.equ AUDIO_PCM_RING_INFO_WRITE_OFFSET, 40
.equ AUDIO_PCM_RING_INFO_QUEUED_BYTES, 56
.equ AUDIO_STREAM_INFO_MODE, 0
.equ AUDIO_STREAM_INFO_FLAGS, 8
.equ AUDIO_STREAM_INFO_HANDLE, 16
.equ AUDIO_STREAM_INFO_PULL_REQUEST_COUNT, 24
.equ AUDIO_STREAM_INFO_PULL_REFILL_COUNT, 32
.equ AUDIO_STREAM_INFO_PENDING_PULL_REQUESTS, 40

.extern shm
.extern sn
.extern vibe_user_clock_monotonic
.extern vibe_user_syscall3

.section .text.pi4_quake_engine.snd, "ax", %progbits

.balign 16
.global SNDDMA_Init
.type SNDDMA_Init, %function
SNDDMA_Init:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    adrp x19, sn
    add x19, x19, :lo12:sn
    mov x0, x19
    mov x1, #DMA_BYTES
    bl .Lquake_zero_buffer

    mov w9, #1
    str w9, [x19, #DMA_GAMEALIVE]
    str wzr, [x19, #DMA_SOUNDALIVE]
    str wzr, [x19, #DMA_SPLITBUFFER]
    mov w9, #QUAKE_DMA_CHANNELS
    str w9, [x19, #DMA_CHANNELS]
    mov w9, #QUAKE_DMA_SAMPLES
    str w9, [x19, #DMA_SAMPLES]
    mov w9, #1
    str w9, [x19, #DMA_SUBMISSION_CHUNK]
    str wzr, [x19, #DMA_SAMPLEPOS]
    mov w9, #QUAKE_DMA_SAMPLEBITS
    str w9, [x19, #DMA_SAMPLEBITS]
    mov w9, #QUAKE_DMA_RATE
    str w9, [x19, #DMA_SPEED]
    adrp x9, quake_dma_buffer
    add x9, x9, :lo12:quake_dma_buffer
    str x9, [x19, #DMA_BUFFER]

    adrp x9, shm
    add x9, x9, :lo12:shm
    str x19, [x9]

    mov x1, #VIBE_AUDIO_DEVICE_START
    bl .Lquake_audio_call0
    cmp x0, #0
    b.lt .Lquake_snd_init_fail
    bl .Lquake_store_last_result

    mov x1, #VIBE_AUDIO_DEVICE_INFO
    adrp x2, quake_audio_device_info
    add x2, x2, :lo12:quake_audio_device_info
    bl .Lquake_audio_call1
    bl .Lquake_store_last_result
    cmp x0, #0
    b.lt .Lquake_snd_init_shutdown_fail
    adrp x9, quake_audio_device_info
    add x9, x9, :lo12:quake_audio_device_info
    ldr x10, [x9, #AUDIO_DEVICE_INFO_KIND]
    cmp x10, #PI4_VIBE_AUDIO_DEVICE_PI4_PWM
    b.ne .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_DEVICE_INFO_STATUS]
    cmp x10, #PI4_VIBE_AUDIO_DEVICE_STATUS_READY
    b.ne .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_DEVICE_INFO_SAMPLE_RATE]
    cbz x10, .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_DEVICE_INFO_CHANNELS]
    cmp x10, #QUAKE_DMA_CHANNELS
    b.ne .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_DEVICE_INFO_FORMAT]
    cmp x10, #VIBE_AUDIO_FORMAT_U8_STEREO
    b.ne .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_DEVICE_INFO_RING_BYTES]
    cbz x10, .Lquake_snd_init_shutdown_fail
    ldr x11, [x9, #AUDIO_DEVICE_INFO_PERIOD_BYTES]
    cbz x11, .Lquake_snd_init_shutdown_fail
    cmp x11, x10
    b.hi .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_DEVICE_INFO_CAPABILITIES]
    mov x11, #PI4_VIBE_AUDIO_CAP_FULL_MASK
    and x10, x10, x11
    cmp x10, x11
    b.ne .Lquake_snd_init_shutdown_fail

    mov x1, #VIBE_AUDIO_PCM_RING_INFO
    adrp x2, quake_audio_ring_info
    add x2, x2, :lo12:quake_audio_ring_info
    bl .Lquake_audio_call1
    bl .Lquake_store_last_result
    cmp x0, #0
    b.lt .Lquake_snd_init_shutdown_fail
    adrp x9, quake_audio_ring_info
    add x9, x9, :lo12:quake_audio_ring_info
    ldr x10, [x9, #AUDIO_PCM_RING_INFO_FORMAT]
    cmp x10, #VIBE_AUDIO_FORMAT_U8_STEREO
    b.ne .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_PCM_RING_INFO_CHANNELS]
    cmp x10, #QUAKE_DMA_CHANNELS
    b.ne .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_PCM_RING_INFO_SAMPLE_RATE]
    cbz x10, .Lquake_snd_init_shutdown_fail
    ldr x10, [x9, #AUDIO_PCM_RING_INFO_RING_BYTES]
    cbz x10, .Lquake_snd_init_shutdown_fail
    ldr x11, [x9, #AUDIO_PCM_RING_INFO_PERIOD_BYTES]
    cbz x11, .Lquake_snd_init_shutdown_fail
    cmp x11, x10
    b.hi .Lquake_snd_init_shutdown_fail
    ldr x11, [x9, #AUDIO_PCM_RING_INFO_WRITE_OFFSET]
    cmp x11, x10
    b.hs .Lquake_snd_init_shutdown_fail
    ldr x11, [x9, #AUDIO_PCM_RING_INFO_QUEUED_BYTES]
    cmp x11, x10
    b.hi .Lquake_snd_init_shutdown_fail

    bl .Lquake_prepare_open_desc
    mov x1, #VIBE_AUDIO_PCM_OPEN
    mov x2, xzr
    adrp x3, quake_pcm_desc
    add x3, x3, :lo12:quake_pcm_desc
    bl .Lquake_audio_call2
    bl .Lquake_store_last_result
    cmp x0, #0
    b.le .Lquake_snd_init_shutdown_fail
    adrp x9, quake_audio_handle
    add x9, x9, :lo12:quake_audio_handle
    str x0, [x9]

    mov x2, x0
    mov x1, #VIBE_AUDIO_STREAM_INFO
    adrp x3, quake_audio_stream_info
    add x3, x3, :lo12:quake_audio_stream_info
    bl .Lquake_audio_call2
    bl .Lquake_store_last_result
    cmp x0, #0
    b.lt .Lquake_snd_init_close_fail
    adrp x9, quake_audio_stream_info
    add x9, x9, :lo12:quake_audio_stream_info
    ldr x10, [x9, #AUDIO_STREAM_INFO_MODE]
    cmp x10, #PI4_VIBE_AUDIO_STREAM_PUSH
    b.ne .Lquake_snd_init_close_fail
    ldr x10, [x9, #AUDIO_STREAM_INFO_FLAGS]
    tst x10, #PI4_VIBE_AUDIO_STREAM_FLAG_ACTIVE
    b.eq .Lquake_snd_init_close_fail
    ldr x10, [x9, #AUDIO_STREAM_INFO_HANDLE]
    adrp x11, quake_audio_handle
    add x11, x11, :lo12:quake_audio_handle
    ldr x11, [x11]
    cmp x10, x11
    b.ne .Lquake_snd_init_close_fail
    ldr x10, [x9, #AUDIO_STREAM_INFO_PULL_REQUEST_COUNT]
    ldr x11, [x9, #AUDIO_STREAM_INFO_PULL_REFILL_COUNT]
    cmp x11, x10
    b.hi .Lquake_snd_init_close_fail
    sub x10, x10, x11
    ldr x11, [x9, #AUDIO_STREAM_INFO_PENDING_PULL_REQUESTS]
    cmp x11, x10
    b.ne .Lquake_snd_init_close_fail

    mov w9, #1
    str w9, [x19, #DMA_SOUNDALIVE]
    mov x0, #1
    b .Lquake_snd_init_done

.Lquake_snd_init_close_fail:
    adrp x9, quake_audio_handle
    add x9, x9, :lo12:quake_audio_handle
    ldr x2, [x9]
    mov x1, #VIBE_AUDIO_PCM_CLOSE
    bl .Lquake_audio_call1
    adrp x9, quake_audio_handle
    add x9, x9, :lo12:quake_audio_handle
    str xzr, [x9]

.Lquake_snd_init_shutdown_fail:
    mov x1, #VIBE_AUDIO_DEVICE_SHUTDOWN
    bl .Lquake_audio_call0

.Lquake_snd_init_fail:
    adrp x9, quake_audio_handle
    add x9, x9, :lo12:quake_audio_handle
    str xzr, [x9]
    mov x0, #1

.Lquake_snd_init_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size SNDDMA_Init, . - SNDDMA_Init

.balign 16
.global SNDDMA_GetDMAPos
.type SNDDMA_GetDMAPos, %function
SNDDMA_GetDMAPos:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    add x0, sp, #16
    bl vibe_user_clock_monotonic
    cbnz x0, .Lquake_snd_get_dma_pos_zero

    ldr x0, [sp, #(16 + PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET)]
    mov x9, #QUAKE_DMA_SAMPLE_RATE_CHANNELS
    mul x0, x0, x9
    mov x9, #1000
    udiv x0, x0, x9
    and x0, x0, #(QUAKE_DMA_SAMPLES - 1)
    adrp x9, sn
    add x9, x9, :lo12:sn
    str w0, [x9, #DMA_SAMPLEPOS]
    b .Lquake_snd_get_dma_pos_done

.Lquake_snd_get_dma_pos_zero:
    mov x0, xzr

.Lquake_snd_get_dma_pos_done:
    ldp x29, x30, [sp], #64
    ret
.size SNDDMA_GetDMAPos, . - SNDDMA_GetDMAPos

.balign 16
.global SNDDMA_Shutdown
.type SNDDMA_Shutdown, %function
SNDDMA_Shutdown:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    adrp x19, quake_audio_handle
    add x19, x19, :lo12:quake_audio_handle
    ldr x2, [x19]
    cbz x2, .Lquake_snd_shutdown_device
    mov x1, #VIBE_AUDIO_PCM_CLOSE
    bl .Lquake_audio_call1
    str xzr, [x19]

.Lquake_snd_shutdown_device:
    mov x1, #VIBE_AUDIO_DEVICE_SHUTDOWN
    bl .Lquake_audio_call0
    adrp x9, shm
    add x9, x9, :lo12:shm
    str xzr, [x9]

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size SNDDMA_Shutdown, . - SNDDMA_Shutdown

.balign 16
.global SNDDMA_Submit
.type SNDDMA_Submit, %function
SNDDMA_Submit:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    adrp x19, quake_audio_handle
    add x19, x19, :lo12:quake_audio_handle
    ldr x2, [x19]
    cbz x2, .Lquake_snd_submit_done

    bl .Lquake_prepare_submit_desc
    mov x1, #VIBE_AUDIO_PCM_WRITE_DESC
    ldr x2, [x19]
    adrp x3, quake_pcm_desc
    add x3, x3, :lo12:quake_pcm_desc
    bl .Lquake_audio_call2
    bl .Lquake_store_last_result
    cmp x0, #0
    b.lt .Lquake_snd_submit_disable_audio
    b.eq .Lquake_snd_submit_done

    adrp x9, quake_audio_write_count
    add x9, x9, :lo12:quake_audio_write_count
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]

    mov x1, #VIBE_AUDIO_PCM_BUFFERED_BYTES
    ldr x2, [x19]
    bl .Lquake_audio_call1
    bl .Lquake_store_last_result

    b .Lquake_snd_submit_done

.Lquake_snd_submit_disable_audio:
    ldr x2, [x19]
    cbz x2, .Lquake_snd_submit_clear_audio
    mov x1, #VIBE_AUDIO_PCM_CLOSE
    bl .Lquake_audio_call1

.Lquake_snd_submit_clear_audio:
    str xzr, [x19]
    adrp x9, sn
    add x9, x9, :lo12:sn
    str wzr, [x9, #DMA_SOUNDALIVE]

.Lquake_snd_submit_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size SNDDMA_Submit, . - SNDDMA_Submit

.Lquake_prepare_open_desc:
    adrp x0, quake_pcm_desc
    add x0, x0, :lo12:quake_pcm_desc
    mov x1, #PCM_DESC_BYTES
    bl .Lquake_zero_buffer
    mov x9, #QUAKE_DMA_RATE
    str x9, [x0, #PCM_DESC_SAMPLE_RATE]
    mov x9, #QUAKE_DMA_CHANNELS
    str x9, [x0, #PCM_DESC_CHANNELS]
    mov x9, #VIBE_AUDIO_FORMAT_U8_STEREO
    str x9, [x0, #PCM_DESC_FORMAT]
    ret

.Lquake_prepare_submit_desc:
    adrp x0, quake_pcm_desc
    add x0, x0, :lo12:quake_pcm_desc
    mov x1, #PCM_DESC_BYTES
    bl .Lquake_zero_buffer
    adrp x9, quake_dma_buffer
    add x9, x9, :lo12:quake_dma_buffer
    str x9, [x0, #PCM_DESC_SAMPLES]
    mov x9, #QUAKE_DMA_BYTES
    str x9, [x0, #PCM_DESC_LENGTH]
    mov x9, #QUAKE_DMA_RATE
    str x9, [x0, #PCM_DESC_SAMPLE_RATE]
    mov x9, #QUAKE_DMA_CHANNELS
    str x9, [x0, #PCM_DESC_CHANNELS]
    mov x9, #VIBE_AUDIO_FORMAT_U8_STEREO
    str x9, [x0, #PCM_DESC_FORMAT]
    ret

.Lquake_audio_call0:
    mov x0, #PI4_VIBE_SYS_AUDIO
    mov x2, xzr
    mov x3, xzr
    b vibe_user_syscall3

.Lquake_audio_call1:
    mov x0, #PI4_VIBE_SYS_AUDIO
    mov x3, xzr
    b vibe_user_syscall3

.Lquake_audio_call2:
    mov x0, #PI4_VIBE_SYS_AUDIO
    b vibe_user_syscall3

.Lquake_store_last_result:
    adrp x9, quake_audio_last_result
    add x9, x9, :lo12:quake_audio_last_result
    str x0, [x9]
    ret

.Lquake_zero_buffer:
    mov x2, x0
    cbz x1, .Lquake_zero_buffer_done
.Lquake_zero_buffer_next:
    strb wzr, [x0], #1
    subs x1, x1, #1
    b.ne .Lquake_zero_buffer_next
.Lquake_zero_buffer_done:
    mov x0, x2
    ret

.section .bss.pi4_quake_engine.snd, "aw", %nobits
.balign 16
quake_audio_handle:
    .skip 8
quake_audio_write_count:
    .skip 8
quake_audio_last_result:
    .skip 8
quake_pcm_desc:
    .skip PCM_DESC_BYTES
quake_audio_device_info:
    .skip 96
quake_audio_ring_info:
    .skip 96
quake_audio_stream_info:
    .skip 96
quake_dma_buffer:
    .skip QUAKE_DMA_BYTES

.section .note.GNU-stack, "", %progbits
