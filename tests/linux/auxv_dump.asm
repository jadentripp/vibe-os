; auxv_dump.asm - a static Linux i386 ELF that prints the initial auxv table.
;
; This is a Linux personality test binary: it expects the Linux i386 process
; stack shape at entry and writes using raw int 0x80 syscalls.
bits 32
global start

section .text
start:
    mov eax, 4              ; sys_write (Linux i386)
    mov ebx, 1              ; fd = stdout
    mov ecx, header
    mov edx, header_len
    int 0x80

    mov esi, esp
    lodsd                   ; eax = argc, esi = argv[0]
    lea esi, [esi + eax * 4 + 4]

.skip_env:
    lodsd
    test eax, eax
    jnz .skip_env

.next_auxv:
    mov eax, [esi]
    test eax, eax
    jz .done

    mov edi, line_type_hex
    call write_hex32
    mov eax, [esi + 4]
    mov edi, line_value_hex
    call write_hex32

    push esi
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, line
    mov edx, line_len
    int 0x80
    pop esi

    add esi, 8
    jmp .next_auxv

.done:
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, footer
    mov edx, footer_len
    int 0x80

    mov eax, 1              ; sys_exit
    xor ebx, ebx
    int 0x80
.hang:
    jmp .hang

; eax = value, edi = eight-byte ASCII hex destination.
write_hex32:
    push ebx
    push ecx
    push edx
    mov ecx, 8
.digit:
    rol eax, 4
    mov edx, eax
    and edx, 0x0f
    mov bl, [hex_digits + edx]
    mov [edi], bl
    inc edi
    loop .digit
    pop edx
    pop ecx
    pop ebx
    ret

section .data
header: db "auxv dump", 10
header_len equ $ - header

line: db "auxv type=0x"
line_type_hex: db "00000000"
      db " value=0x"
line_value_hex: db "00000000", 10
line_len equ $ - line

footer: db "auxv end", 10
footer_len equ $ - footer

hex_digits: db "0123456789abcdef"
