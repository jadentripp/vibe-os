; stdio_dup_probe.asm - Linux i386 stdio dup/redirection probe for vibe-os.
;
; Pins the fd semantics shell pipelines and redirection need: dup2 to stdout
; for a writable root file, then dup2 to stdout/stdin for a pipe pair.
bits 32
global start

%define SYS_EXIT   1
%define SYS_READ   3
%define SYS_WRITE  4
%define SYS_CLOSE  6
%define SYS_DUP    41
%define SYS_PIPE   42
%define SYS_DUP2   63
%define SYS_OPENAT 295

%define AT_FDCWD   0xffffff9c
%define O_RDONLY   0x00000000
%define O_RDWR     0x00000002
%define O_CREAT    0x00000040
%define O_TRUNC    0x00000200
%define O_CLOEXEC  0x00080000
%define MODE_0644  0x000001a4

section .text
start:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_stdio
    mov edx, O_RDWR | O_CREAT | O_TRUNC | O_CLOEXEC
    mov esi, MODE_0644
    int 0x80
    test eax, eax
    js fail
    mov [file_fd], eax

    mov eax, SYS_DUP
    mov ebx, 1
    int 0x80
    test eax, eax
    js fail
    mov [saved_stdout], eax

    mov eax, SYS_DUP
    xor ebx, ebx
    int 0x80
    test eax, eax
    js fail
    mov [saved_stdin], eax

    mov eax, SYS_DUP2
    mov ebx, [file_fd]
    mov ecx, 1
    int 0x80
    cmp eax, 1
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [file_fd]
    int 0x80
    test eax, eax
    jne fail
    mov dword [file_fd], -1

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, file_payload
    mov edx, file_payload_len
    int 0x80
    cmp eax, file_payload_len
    jne fail

    call restore_stdout
    jc fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_stdio
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [file_fd], eax

    mov eax, SYS_READ
    mov ebx, [file_fd]
    mov ecx, read_buf
    mov edx, file_payload_len
    int 0x80
    cmp eax, file_payload_len
    jne fail

    mov esi, file_payload
    mov edi, read_buf
    mov ecx, file_payload_len
    call memeq
    jc fail

    mov eax, SYS_READ
    mov ebx, [file_fd]
    mov ecx, read_buf
    mov edx, 1
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [file_fd]
    int 0x80
    test eax, eax
    jne fail
    mov dword [file_fd], -1

    mov eax, SYS_PIPE
    mov ebx, pipefd
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_DUP2
    mov ebx, [pipefd + 4]
    mov ecx, 1
    int 0x80
    cmp eax, 1
    jne fail

    mov eax, SYS_DUP2
    mov ebx, [pipefd]
    xor ecx, ecx
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [pipefd + 4]
    int 0x80
    test eax, eax
    jne fail
    mov dword [pipefd + 4], -1

    mov eax, SYS_CLOSE
    mov ebx, [pipefd]
    int 0x80
    test eax, eax
    jne fail
    mov dword [pipefd], -1

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, pipe_payload
    mov edx, pipe_payload_len
    int 0x80
    cmp eax, pipe_payload_len
    jne fail

    mov eax, SYS_READ
    xor ebx, ebx
    mov ecx, read_buf
    mov edx, pipe_payload_len
    int 0x80
    cmp eax, pipe_payload_len
    jne fail

    mov esi, pipe_payload
    mov edi, read_buf
    mov ecx, pipe_payload_len
    call memeq
    jc fail

    call restore_stdout
    jc fail
    call restore_stdin
    jc fail
    call close_saved_stdio

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 43
    int 0x80

fail:
    call cleanup_for_fail
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 1
    int 0x80

restore_stdout:
    cmp dword [saved_stdout], 0
    jl .missing
    mov eax, SYS_DUP2
    mov ebx, [saved_stdout]
    mov ecx, 1
    int 0x80
    cmp eax, 1
    jne .fail
    clc
    ret

.missing:
    stc
    ret

.fail:
    stc
    ret

restore_stdin:
    cmp dword [saved_stdin], 0
    jl .missing
    mov eax, SYS_DUP2
    mov ebx, [saved_stdin]
    xor ecx, ecx
    int 0x80
    test eax, eax
    jne .fail
    clc
    ret

.missing:
    stc
    ret

.fail:
    stc
    ret

close_saved_stdio:
    cmp dword [saved_stdout], 0
    jl .stdin
    mov eax, SYS_CLOSE
    mov ebx, [saved_stdout]
    int 0x80
    mov dword [saved_stdout], -1

.stdin:
    cmp dword [saved_stdin], 0
    jl .done
    mov eax, SYS_CLOSE
    mov ebx, [saved_stdin]
    int 0x80
    mov dword [saved_stdin], -1

.done:
    ret

cleanup_for_fail:
    cmp dword [saved_stdout], 0
    jl .restore_stdin
    call restore_stdout

.restore_stdin:
    cmp dword [saved_stdin], 0
    jl .close_file
    call restore_stdin

.close_file:
    cmp dword [file_fd], 0
    jl .close_pipe_read
    mov eax, SYS_CLOSE
    mov ebx, [file_fd]
    int 0x80
    mov dword [file_fd], -1

.close_pipe_read:
    cmp dword [pipefd], 0
    jl .close_pipe_write
    mov eax, SYS_CLOSE
    mov ebx, [pipefd]
    int 0x80
    mov dword [pipefd], -1

.close_pipe_write:
    cmp dword [pipefd + 4], 0
    jl .close_saved
    mov eax, SYS_CLOSE
    mov ebx, [pipefd + 4]
    int 0x80
    mov dword [pipefd + 4], -1

.close_saved:
    call close_saved_stdio
    ret

memeq:
    test ecx, ecx
    jz .same

.next:
    mov al, [esi]
    cmp al, [edi]
    jne .different
    inc esi
    inc edi
    dec ecx
    jne .next

.same:
    clc
    ret

.different:
    stc
    ret

section .data
path_stdio: db "/STDIO.TXT", 0

file_payload: db "stdio-file", 10
file_payload_len equ $ - file_payload
pipe_payload: db "stdio-pipe"
pipe_payload_len equ $ - pipe_payload

ok_msg: db "stdio dup ok", 10
ok_len equ $ - ok_msg
fail_msg: db "stdio dup fail", 10
fail_len equ $ - fail_msg

saved_stdout: dd -1
saved_stdin:  dd -1
file_fd:      dd -1
pipefd:       dd -1, -1

section .bss
read_buf: resb 32
