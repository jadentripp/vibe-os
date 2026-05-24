BITS 32

section .text

global tan

tan:
    push ebp
    mov ebp, esp
    fld qword [ebp + 8]
    fptan
    fstp st0
    pop ebp
    ret
