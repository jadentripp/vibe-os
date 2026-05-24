BITS 32

section .text

global CDAudio_Play
global CDAudio_Stop
global CDAudio_Pause
global CDAudio_Resume
global CDAudio_Update
global CDAudio_Init
global CDAudio_Shutdown

CDAudio_Play:
CDAudio_Stop:
CDAudio_Pause:
CDAudio_Resume:
CDAudio_Update:
CDAudio_Shutdown:
    ret

CDAudio_Init:
    xor eax, eax
    ret
