.arch armv8-a

.section .text.pi4_quake_engine.cd, "ax", %progbits

.balign 16
.global CDAudio_Init
.global CDAudio_Pause
.global CDAudio_Play
.global CDAudio_Resume
.global CDAudio_Shutdown
.global CDAudio_Stop
.global CDAudio_Update
.type CDAudio_Init, %function
.type CDAudio_Pause, %function
.type CDAudio_Play, %function
.type CDAudio_Resume, %function
.type CDAudio_Shutdown, %function
.type CDAudio_Stop, %function
.type CDAudio_Update, %function
CDAudio_Init:
    mov x0, xzr
    ret
CDAudio_Pause:
CDAudio_Play:
CDAudio_Resume:
CDAudio_Shutdown:
CDAudio_Stop:
CDAudio_Update:
    ret
.size CDAudio_Init, . - CDAudio_Init
.size CDAudio_Pause, . - CDAudio_Pause
.size CDAudio_Play, . - CDAudio_Play
.size CDAudio_Resume, . - CDAudio_Resume
.size CDAudio_Shutdown, . - CDAudio_Shutdown
.size CDAudio_Stop, . - CDAudio_Stop
.size CDAudio_Update, . - CDAudio_Update

.section .note.GNU-stack, "", %progbits
