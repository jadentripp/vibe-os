BITS 32

%define SYS_GAMEPLAY_STATUS 15
%define QUAKE_STATUS_INIT 0x51000000
%define QUAKE_INIT_AUDIO 0x00000010
%define QUAKE_STATUS_AUDIO 0x54000000

%define VIBE_AUDIO_FORMAT_U8_STEREO 1
%define QUAKE_DMA_RATE 11025
%define QUAKE_DMA_CHANNELS 2
%define QUAKE_DMA_SAMPLEBITS 8
%define QUAKE_DMA_SAMPLES 32768
%define QUAKE_DMA_BYTES QUAKE_DMA_SAMPLES
%define QUAKE_DMA_SAMPLE_RATE_CHANNELS 22050

%define DMA_GAMEALIVE 0
%define DMA_SOUNDALIVE 4
%define DMA_SPLITBUFFER 8
%define DMA_CHANNELS 12
%define DMA_SAMPLES 16
%define DMA_SUBMISSION_CHUNK 20
%define DMA_SAMPLEPOS 24
%define DMA_SAMPLEBITS 28
%define DMA_SPEED 32
%define DMA_BUFFER 36
%define DMA_BYTES 40

%define PCM_DESC_SAMPLES 0
%define PCM_DESC_LENGTH 4
%define PCM_DESC_SAMPLE_RATE 8
%define PCM_DESC_CHANNELS 12
%define PCM_DESC_FORMAT 16
%define PCM_DESC_FLAGS 20
%define PCM_DESC_BYTES 64

section .text

global SNDDMA_Init
global SNDDMA_GetDMAPos
global SNDDMA_Shutdown
global SNDDMA_Submit

extern memset
extern shm
extern sn
extern vibe_audio_device_shutdown
extern vibe_audio_device_start
extern vibe_audio_pcm_close
extern vibe_audio_pcm_open
extern vibe_audio_pcm_write_desc
extern vibe_monotonic_milliseconds
extern vibe_syscall3

SNDDMA_Init:
    push ebp
    mov ebp, esp
    push dword DMA_BYTES
    push dword 0
    push dword sn
    call memset
    add esp, 12

    mov dword [sn + DMA_GAMEALIVE], 1
    mov dword [sn + DMA_SOUNDALIVE], 1
    mov dword [sn + DMA_SPLITBUFFER], 0
    mov dword [sn + DMA_CHANNELS], QUAKE_DMA_CHANNELS
    mov dword [sn + DMA_SAMPLES], QUAKE_DMA_SAMPLES
    mov dword [sn + DMA_SUBMISSION_CHUNK], 1
    mov dword [sn + DMA_SAMPLEPOS], 0
    mov dword [sn + DMA_SAMPLEBITS], QUAKE_DMA_SAMPLEBITS
    mov dword [sn + DMA_SPEED], QUAKE_DMA_RATE
    mov dword [sn + DMA_BUFFER], quake_dma_buffer
    mov dword [shm], sn

    call vibe_audio_device_start
    cmp eax, 0
    jl .fail

    mov dword [quake_pcm_desc + PCM_DESC_SAMPLES], 0
    mov dword [quake_pcm_desc + PCM_DESC_LENGTH], 0
    mov dword [quake_pcm_desc + PCM_DESC_SAMPLE_RATE], QUAKE_DMA_RATE
    mov dword [quake_pcm_desc + PCM_DESC_CHANNELS], QUAKE_DMA_CHANNELS
    mov dword [quake_pcm_desc + PCM_DESC_FORMAT], VIBE_AUDIO_FORMAT_U8_STEREO
    mov dword [quake_pcm_desc + PCM_DESC_FLAGS], 0
    push dword quake_pcm_desc
    call vibe_audio_pcm_open
    add esp, 4
    cmp eax, 0
    jl .fail
    mov [quake_audio_handle], eax

    push eax
    push dword 0
    push dword QUAKE_STATUS_INIT | QUAKE_INIT_AUDIO
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16
    mov eax, 1
    pop ebp
    ret

.fail:
    mov dword [shm], 0
    xor eax, eax
    pop ebp
    ret

SNDDMA_GetDMAPos:
    push ebx
    push edx
    call vibe_monotonic_milliseconds
    mov ebx, QUAKE_DMA_SAMPLE_RATE_CHANNELS
    mul ebx
    mov ebx, 1000
    div ebx
    and eax, QUAKE_DMA_SAMPLES - 1
    mov [sn + DMA_SAMPLEPOS], eax
    pop edx
    pop ebx
    ret

SNDDMA_Submit:
    push ebp
    mov ebp, esp
    cmp dword [quake_audio_handle], 0
    je .done
    mov dword [quake_pcm_desc + PCM_DESC_SAMPLES], quake_dma_buffer
    mov dword [quake_pcm_desc + PCM_DESC_LENGTH], QUAKE_DMA_BYTES
    mov dword [quake_pcm_desc + PCM_DESC_SAMPLE_RATE], QUAKE_DMA_RATE
    mov dword [quake_pcm_desc + PCM_DESC_CHANNELS], QUAKE_DMA_CHANNELS
    mov dword [quake_pcm_desc + PCM_DESC_FORMAT], VIBE_AUDIO_FORMAT_U8_STEREO
    mov dword [quake_pcm_desc + PCM_DESC_FLAGS], 0
    push dword quake_pcm_desc
    push dword [quake_audio_handle]
    call vibe_audio_pcm_write_desc
    add esp, 8
    cmp eax, 0
    jl .done
    inc dword [quake_audio_write_count]
    push dword [quake_audio_handle]
    push dword [quake_audio_write_count]
    push dword QUAKE_STATUS_AUDIO
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16
.done:
    pop ebp
    ret

SNDDMA_Shutdown:
    push ebp
    mov ebp, esp
    cmp dword [quake_audio_handle], 0
    je .device
    push dword [quake_audio_handle]
    call vibe_audio_pcm_close
    add esp, 4
    mov dword [quake_audio_handle], 0
.device:
    call vibe_audio_device_shutdown
    mov dword [shm], 0
    pop ebp
    ret

section .bss
align 4
quake_audio_handle resd 1
quake_audio_write_count resd 1
quake_pcm_desc resb PCM_DESC_BYTES
quake_dma_buffer resb QUAKE_DMA_BYTES
