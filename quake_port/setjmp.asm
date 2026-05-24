BITS 32

section .text

global setjmp
global longjmp

; jmp_buf layout: ebx, esi, edi, ebp, esp_after_return, eip_after_return.
setjmp:
    mov edx, [esp + 4]
    mov [edx + 0], ebx
    mov [edx + 4], esi
    mov [edx + 8], edi
    mov [edx + 12], ebp
    lea eax, [esp + 4]
    mov [edx + 16], eax
    mov eax, [esp]
    mov [edx + 20], eax
    xor eax, eax
    ret

longjmp:
    mov edx, [esp + 4]
    mov eax, [esp + 8]
    test eax, eax
    jnz .value_ready
    mov eax, 1

.value_ready:
    mov ebx, [edx + 0]
    mov esi, [edx + 4]
    mov edi, [edx + 8]
    mov ebp, [edx + 12]
    mov esp, [edx + 16]
    jmp dword [edx + 20]
