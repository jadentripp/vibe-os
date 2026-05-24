BITS 32
extern __vibe_syscall0
extern __vibe_syscall1
extern __vibe_syscall2
extern __vibe_syscall3
extern vibe_user_argc
extern vibe_user_argv
extern vibe_user_environ
extern vibe_user_auxv
extern vibe_user_start_status
section .text
global vibe_user_syscall0

align 16
vibe_user_syscall0:

    push	ebp
    mov	ebp, esp
    pop	ebp
    jmp	__vibe_syscall0
.Lfunc_end0:

global vibe_user_syscall1

align 16
vibe_user_syscall1:

    push	ebp
    mov	ebp, esp
    pop	ebp
    jmp	__vibe_syscall1
.Lfunc_end1:

global vibe_user_syscall2

align 16
vibe_user_syscall2:

    push	ebp
    mov	ebp, esp
    pop	ebp
    jmp	__vibe_syscall2
.Lfunc_end2:

global vibe_user_syscall3

align 16
vibe_user_syscall3:

    push	ebp
    mov	ebp, esp
    pop	ebp
    jmp	__vibe_syscall3
.Lfunc_end3:

global vibe_user_syscall_errno

align 16
vibe_user_syscall_errno:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 8]
    xor	eax, eax
    test	ecx, ecx
    js	.LBB4_1
.LBB4_5:
    pop	ebp
    ret
.LBB4_1:
    cmp	ecx, -1
    je	.LBB4_3

    neg	ecx
    mov	eax, ecx
    pop	ebp
    ret
.LBB4_3:
    mov	eax, dword [ebp + 12]
    test	eax, eax
    jg	.LBB4_5

    mov	eax, 5
    pop	ebp
    ret
.Lfunc_end4:

global vibe_user_streq

align 16
vibe_user_streq:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 12]
    mov	eax, dword [ebp + 8]
    movzx	edx, byte [eax]
    test	dl, dl
    je	.LBB5_4

    inc	eax
align 16
.LBB5_2:
    cmp	dl, byte [ecx]
    jne	.LBB5_5

    inc	ecx
    movzx	edx, byte [eax]
    inc	eax
    test	dl, dl
    jne	.LBB5_2
.LBB5_4:
    xor	edx, edx
.LBB5_5:
    xor	eax, eax
    cmp	dl, byte [ecx]
    sete	al
    pop	ebp
    ret
.Lfunc_end5:

global vibe_user_write_all

align 16
vibe_user_write_all:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	ebx, -1
    mov	ecx, dword [ebp + 12]
align 16
.LBB6_1:
    cmp	byte [ecx + ebx + 1], 0
    lea	ebx, [ebx + 1]
    jne	.LBB6_1

    test	ebx, ebx
    je	.LBB6_12

    xor	edi, edi
align 16
.LBB6_4:
    mov	esi, ebx
    sub	esi, edi
    cmp	esi, 2147483647
    mov	eax, esi
    jb	.LBB6_6

    mov	eax, 2147483647
.LBB6_6:
    add	ecx, edi
    push	eax
    push	ecx
    push	dword [ebp + 8]
    push	4
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB6_7

    lea	ecx, [eax - 1]
    cmp	ecx, esi
    jae	.LBB6_10

    add	edi, eax
    cmp	edi, ebx
    mov	ecx, dword [ebp + 12]
    jb	.LBB6_4
.LBB6_12:
    xor	eax, eax
    jmp	.LBB6_13
.LBB6_7:
    mov	ecx, eax
    cmp	eax, -1
    mov	eax, -5
    je	.LBB6_13

    mov	eax, ecx
    jmp	.LBB6_13
.LBB6_10:
    mov	eax, -5
.LBB6_13:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end6:

global vibe_user_write_full

align 16
vibe_user_write_full:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	esi, dword [ebp + 20]
    mov	edx, dword [ebp + 16]
    test	esi, esi
    je	.LBB7_2

    mov	dword [esi], 0
.LBB7_2:
    test	edx, edx
    sete	cl
    je	.LBB7_4

    mov	edx, -22
.LBB7_4:
    xor	eax, eax
    cmp	dword [ebp + 12], 0
    sete	ch
    jne	.LBB7_6

    mov	eax, edx
.LBB7_6:
    or	cl, ch
    jne	.LBB7_22

    xor	ebx, ebx
    mov	eax, dword [ebp + 16]
    jmp	.LBB7_8
align 16
.LBB7_20:
    mov	eax, dword [ebp + 16]
    cmp	ebx, eax
    jae	.LBB7_21
.LBB7_8:
    mov	edi, eax
    sub	edi, ebx
    cmp	edi, 2147483647
    mov	eax, edi
    jb	.LBB7_10

    mov	eax, 2147483647
.LBB7_10:
    mov	ecx, dword [ebp + 12]
    add	ecx, ebx
    push	eax
    push	ecx
    push	dword [ebp + 8]
    push	4
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB7_11

    lea	ecx, [eax - 1]
    cmp	ecx, edi
    jae	.LBB7_16

    add	ebx, eax
    test	esi, esi
    je	.LBB7_20

    mov	dword [esi], ebx
    jmp	.LBB7_20
.LBB7_11:
    test	esi, esi
    je	.LBB7_13

    mov	dword [esi], ebx
.LBB7_13:
    mov	ecx, eax
    cmp	eax, -1
    mov	eax, -5
    je	.LBB7_22

    mov	eax, ecx
    jmp	.LBB7_22
.LBB7_16:
    mov	eax, -5
    test	esi, esi
    je	.LBB7_22

    mov	dword [esi], ebx
    jmp	.LBB7_22
.LBB7_21:
    xor	eax, eax
.LBB7_22:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end7:

global vibe_user_write

align 16
vibe_user_write:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 16]
    mov	eax, dword [ebp + 12]
    test	eax, eax
    sete	dl
    test	ecx, ecx
    setne	dh
    test	dl, dh
    je	.LBB8_1

    mov	eax, -22
    pop	ebp
    ret
.LBB8_1:
    push	ecx
    push	eax
    push	dword [ebp + 8]
    push	4
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end8:

global vibe_user_read_full

align 16
vibe_user_read_full:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	esi, dword [ebp + 20]
    mov	edx, dword [ebp + 16]
    test	esi, esi
    je	.LBB9_2

    mov	dword [esi], 0
.LBB9_2:
    test	edx, edx
    sete	cl
    je	.LBB9_4

    mov	edx, -22
.LBB9_4:
    xor	eax, eax
    cmp	dword [ebp + 12], 0
    sete	ch
    jne	.LBB9_6

    mov	eax, edx
.LBB9_6:
    or	cl, ch
    mov	ecx, dword [ebp + 16]
    je	.LBB9_7
.LBB9_22:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.LBB9_7:
    xor	ebx, ebx
    jmp	.LBB9_8
align 16
.LBB9_21:
    mov	ecx, dword [ebp + 16]
    cmp	ebx, ecx
    jae	.LBB9_22
.LBB9_8:
    mov	edi, ecx
    sub	edi, ebx
    cmp	edi, 2147483647
    jb	.LBB9_10

    mov	edi, 2147483647
.LBB9_10:
    mov	eax, dword [ebp + 12]
    add	eax, ebx
    push	edi
    push	eax
    push	dword [ebp + 8]
    push	7
    call	__vibe_syscall3
    add	esp, 16
    mov	ecx, eax
    test	eax, eax
    js	.LBB9_11

    xor	eax, eax
    test	ecx, ecx
    je	.LBB9_22

    cmp	ecx, edi
    ja	.LBB9_17

    add	ebx, ecx
    test	esi, esi
    je	.LBB9_21

    mov	dword [esi], ebx
    jmp	.LBB9_21
.LBB9_11:
    test	esi, esi
    je	.LBB9_13

    mov	dword [esi], ebx
.LBB9_13:
    cmp	ecx, -1
    mov	eax, -5
    je	.LBB9_22

    mov	eax, ecx
    jmp	.LBB9_22
.LBB9_17:
    mov	eax, -5
    test	esi, esi
    je	.LBB9_22

    mov	dword [esi], ebx
    jmp	.LBB9_22
.Lfunc_end9:

global vibe_user_read

align 16
vibe_user_read:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 16]
    mov	eax, dword [ebp + 12]
    test	eax, eax
    sete	dl
    test	ecx, ecx
    setne	dh
    test	dl, dh
    je	.LBB10_1

    mov	eax, -22
    pop	ebp
    ret
.LBB10_1:
    push	ecx
    push	eax
    push	dword [ebp + 8]
    push	7
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end10:

global vibe_user_read_exact

align 16
vibe_user_read_exact:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	ebx, dword [ebp + 16]
    test	ebx, ebx
    sete	cl
    mov	edx, ebx
    je	.LBB11_2

    mov	edx, -22
.LBB11_2:
    xor	edi, edi
    cmp	dword [ebp + 12], 0
    sete	ch
    mov	eax, 0
    jne	.LBB11_4

    mov	eax, edx
.LBB11_4:
    or	cl, ch
    je	.LBB11_5
.LBB11_15:
    mov	ecx, dword [ebp + 20]
    test	ecx, ecx
    je	.LBB11_17

    mov	dword [ecx], edi
.LBB11_17:
    xor	ecx, ecx
    cmp	edi, ebx
    sete	dl
    test	eax, eax
    js	.LBB11_19

    mov	cl, dl
    lea	eax, [ecx + 4*ecx - 5]
.LBB11_19:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.LBB11_5:
    xor	edi, edi
align 16
.LBB11_6:
    mov	esi, ebx
    sub	esi, edi
    cmp	esi, 2147483647
    jb	.LBB11_8

    mov	esi, 2147483647
.LBB11_8:
    mov	eax, dword [ebp + 12]
    add	eax, edi
    push	esi
    push	eax
    push	dword [ebp + 8]
    push	7
    call	__vibe_syscall3
    add	esp, 16
    mov	ecx, eax
    test	eax, eax
    js	.LBB11_9

    xor	eax, eax
    test	ecx, ecx
    je	.LBB11_15

    cmp	ecx, esi
    ja	.LBB11_13

    add	edi, ecx
    cmp	edi, ebx
    jb	.LBB11_6
    jmp	.LBB11_15
.LBB11_9:
    cmp	ecx, -1
    mov	eax, -5
    je	.LBB11_15

    mov	eax, ecx
    jmp	.LBB11_15
.LBB11_13:
    mov	eax, -5
    jmp	.LBB11_15
.Lfunc_end11:

global vibe_user_sbrk

align 16
vibe_user_sbrk:

    push	ebp
    mov	ebp, esp
    push	esi
    mov	esi, dword [ebp + 12]
    test	esi, esi
    je	.LBB12_1

    push	0
    push	0
    push	dword [ebp + 8]
    push	5
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB12_3

    mov	dword [esi], eax
    xor	eax, eax
    jmp	.LBB12_6
.LBB12_1:
    mov	eax, -22
    jmp	.LBB12_6
.LBB12_3:
    mov	ecx, eax
    cmp	eax, -1
    mov	eax, -12
    je	.LBB12_6

    mov	eax, ecx
.LBB12_6:
    pop	esi
    pop	ebp
    ret
.Lfunc_end12:

global vibe_user_open

align 16
vibe_user_open:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 16]
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	6
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end13:

global vibe_user_lseek

align 16
vibe_user_lseek:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 16]
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	8
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end14:

global vibe_user_pread

align 16
vibe_user_pread:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    push	eax
    mov	edi, dword [ebp + 20]
    mov	eax, -22
    test	edi, edi
    js	.LBB15_9

    mov	ebx, dword [ebp + 16]
    mov	esi, dword [ebp + 12]
    test	esi, esi
    sete	cl
    test	ebx, ebx
    setne	dl
    test	cl, dl
    jne	.LBB15_9

    push	1
    push	0
    push	dword [ebp + 8]
    push	8
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB15_9

    mov	dword [ebp - 16], eax
    push	0
    push	edi
    mov	edi, dword [ebp + 8]
    push	edi
    push	8
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB15_4

    push	ebx
    push	esi
    push	edi
    push	7
    call	__vibe_syscall3
    add	esp, 16
    mov	esi, eax
    push	0
    push	dword [ebp - 16]
    push	edi
    push	8
    call	__vibe_syscall3
    add	esp, 16
    mov	ecx, eax
    test	esi, esi
    jns	.LBB15_7

    mov	eax, esi
.LBB15_7:
    test	ecx, ecx
    jns	.LBB15_8
    jmp	.LBB15_9
.LBB15_4:
    push	0
    push	dword [ebp - 16]
    push	edi
    push	8
    mov	esi, eax
    call	__vibe_syscall3
    add	esp, 16
.LBB15_8:
    mov	eax, esi
.LBB15_9:
    add	esp, 4
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end15:

global vibe_user_pwrite

align 16
vibe_user_pwrite:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    push	eax
    mov	edi, dword [ebp + 20]
    mov	eax, -22
    test	edi, edi
    js	.LBB16_9

    mov	ebx, dword [ebp + 16]
    mov	esi, dword [ebp + 12]
    test	esi, esi
    sete	cl
    test	ebx, ebx
    setne	dl
    test	cl, dl
    jne	.LBB16_9

    push	1
    push	0
    push	dword [ebp + 8]
    push	8
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB16_9

    mov	dword [ebp - 16], eax
    push	0
    push	edi
    mov	edi, dword [ebp + 8]
    push	edi
    push	8
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB16_4

    push	ebx
    push	esi
    push	edi
    push	4
    call	__vibe_syscall3
    add	esp, 16
    mov	esi, eax
    push	0
    push	dword [ebp - 16]
    push	edi
    push	8
    call	__vibe_syscall3
    add	esp, 16
    mov	ecx, eax
    test	esi, esi
    jns	.LBB16_7

    mov	eax, esi
.LBB16_7:
    test	ecx, ecx
    jns	.LBB16_8
    jmp	.LBB16_9
.LBB16_4:
    push	0
    push	dword [ebp - 16]
    push	edi
    push	8
    mov	esi, eax
    call	__vibe_syscall3
    add	esp, 16
.LBB16_8:
    mov	eax, esi
.LBB16_9:
    add	esp, 4
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end16:

global vibe_user_close

align 16
vibe_user_close:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 8]
    push	12
    call	__vibe_syscall1
    add	esp, 8
    pop	ebp
    ret
.Lfunc_end17:

global vibe_user_unlink

align 16
vibe_user_unlink:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB18_2

    push	eax
    push	17
    call	__vibe_syscall1
    add	esp, 8
    pop	ebp
    ret
.LBB18_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end18:

global vibe_user_stat

align 16
vibe_user_stat:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 12]
    mov	eax, dword [ebp + 8]
    test	eax, eax
    sete	dl
    test	ecx, ecx
    sete	dh
    or	dh, dl
    jne	.LBB19_2

    push	ecx
    push	eax
    push	18
    call	__vibe_syscall2
    add	esp, 12
    pop	ebp
    ret
.LBB19_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end19:

global vibe_user_fstat

align 16
vibe_user_fstat:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	.LBB20_2

    push	eax
    push	dword [ebp + 8]
    push	19
    call	__vibe_syscall2
    add	esp, 12
    pop	ebp
    ret
.LBB20_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end20:

global vibe_user_ftruncate

align 16
vibe_user_ftruncate:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 12]
    test	eax, eax
    js	.LBB21_2

    push	eax
    push	dword [ebp + 8]
    push	27
    call	__vibe_syscall2
    add	esp, 12
    pop	ebp
    ret
.LBB21_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end21:

global vibe_user_getpid

align 16
vibe_user_getpid:

    push	ebp
    mov	ebp, esp
    push	25
    call	__vibe_syscall0
    add	esp, 4
    pop	ebp
    ret
.Lfunc_end22:

global vibe_user_getppid

align 16
vibe_user_getppid:

    push	ebp
    mov	ebp, esp
    push	40
    call	__vibe_syscall0
    add	esp, 4
    pop	ebp
    ret
.Lfunc_end23:

global vibe_user_exit

align 16
vibe_user_exit:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 8]
    push	2
    call	__vibe_syscall1
    add	esp, 8
align 16
.LBB24_1:
    jmp	.LBB24_1
.Lfunc_end24:

global vibe_user_fork

align 16
vibe_user_fork:

    push	ebp
    mov	ebp, esp
    push	23
    call	__vibe_syscall0
    add	esp, 4
    pop	ebp
    ret
.Lfunc_end25:

global vibe_user_waitpid

align 16
vibe_user_waitpid:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 16]
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	24
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end26:

global vibe_user_waitpid_nohang_reap

align 16
vibe_user_waitpid_nohang_reap:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	esi, dword [ebp + 16]
    test	esi, esi
    je	.LBB27_1

    mov	edi, dword [ebp + 12]
    mov	ebx, dword [ebp + 8]
align 16
.LBB27_5:
    push	1
    push	edi
    push	ebx
    push	24
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    jne	.LBB27_7

    push	37
    call	__vibe_syscall0
    add	esp, 4
    test	eax, eax
    js	.LBB27_7

    dec	esi
    jne	.LBB27_5

    xor	eax, eax
    jmp	.LBB27_7
.LBB27_1:
    mov	eax, -22
.LBB27_7:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end27:

global vibe_user_yield

align 16
vibe_user_yield:

    push	ebp
    mov	ebp, esp
    push	37
    call	__vibe_syscall0
    add	esp, 4
    pop	ebp
    ret
.Lfunc_end28:

global vibe_user_dup

align 16
vibe_user_dup:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 8]
    push	32
    call	__vibe_syscall1
    add	esp, 8
    pop	ebp
    ret
.Lfunc_end29:

global vibe_user_dup2

align 16
vibe_user_dup2:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	33
    call	__vibe_syscall2
    add	esp, 12
    pop	ebp
    ret
.Lfunc_end30:

global vibe_user_dup3

align 16
vibe_user_dup3:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 16]
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	34
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end31:

global vibe_user_fcntl

align 16
vibe_user_fcntl:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 16]
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	35
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end32:

global vibe_user_process_status

align 16
vibe_user_process_status:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	.LBB33_2

    push	64
    push	eax
    push	dword [ebp + 8]
    push	36
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.LBB33_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end33:

global vibe_user_process_status_current

align 16
vibe_user_process_status_current:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB34_2

    push	64
    push	eax
    push	0
    push	36
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.LBB34_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end34:

global vibe_user_sleep_ticks

align 16
vibe_user_sleep_ticks:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB35_1

    push	eax
    push	38
    call	__vibe_syscall1
    add	esp, 8
    pop	ebp
    ret
.LBB35_1:
    push	37
    call	__vibe_syscall0
    add	esp, 4
    pop	ebp
    ret
.Lfunc_end35:

global vibe_user_sleep_milliseconds

align 16
vibe_user_sleep_milliseconds:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB36_3

    cmp	eax, 42949662
    jbe	.LBB36_4

    mov	eax, -22
    pop	ebp
    ret
.LBB36_3:
    push	37
    call	__vibe_syscall0
    add	esp, 4
    pop	ebp
    ret
.LBB36_4:
    imul	eax, eax, 100
    add	eax, 999
    mov	ecx, 274877907
    mul	ecx
    shr	edx, 6
    push	edx
    push	38
    call	__vibe_syscall1
    add	esp, 8
    pop	ebp
    ret
.Lfunc_end36:

global vibe_user_mmap

align 16
vibe_user_mmap:

    push	ebp
    mov	ebp, esp
    push	esi
    mov	ecx, dword [ebp + 12]
    mov	esi, dword [ebp + 8]
    test	esi, esi
    sete	dl
    test	ecx, ecx
    sete	dh
    mov	eax, -22
    or	dh, dl
    jne	.LBB37_5

    mov	eax, dword [ebp + 20]
    mov	edx, dword [ebp + 16]
    shl	eax, 16
    movzx	edx, dx
    or	edx, eax
    push	edx
    push	ecx
    push	0
    push	20
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB37_2

    mov	dword [esi], eax
    xor	eax, eax
    jmp	.LBB37_5
.LBB37_2:
    mov	ecx, eax
    cmp	eax, -1
    mov	eax, -12
    je	.LBB37_5

    mov	eax, ecx
.LBB37_5:
    pop	esi
    pop	ebp
    ret
.Lfunc_end37:

global vibe_user_mmap_anon

align 16
vibe_user_mmap_anon:

    push	ebp
    mov	ebp, esp
    push	esi
    mov	ecx, dword [ebp + 12]
    mov	esi, dword [ebp + 8]
    test	esi, esi
    sete	dl
    test	ecx, ecx
    sete	dh
    mov	eax, -22
    or	dh, dl
    jne	.LBB38_5

    mov	eax, dword [ebp + 16]
    movzx	eax, ax
    or	eax, 2228224
    push	eax
    push	ecx
    push	0
    push	20
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB38_2

    mov	dword [esi], eax
    xor	eax, eax
    jmp	.LBB38_5
.LBB38_2:
    mov	ecx, eax
    cmp	eax, -1
    mov	eax, -12
    je	.LBB38_5

    mov	eax, ecx
.LBB38_5:
    pop	esi
    pop	ebp
    ret
.Lfunc_end38:

global vibe_user_mmap_file

align 16
vibe_user_mmap_file:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    push	eax
    mov	esi, dword [ebp + 8]
    mov	eax, -22
    test	esi, esi
    je	.LBB39_19

    mov	edx, dword [ebp + 28]
    mov	edi, dword [ebp + 12]
    test	edi, edi
    sete	cl
    or	edx, dword [ebp + 24]
    sets	dl
    or	dl, cl
    mov	dword [esi], 0
    jne	.LBB39_19

    mov	ecx, dword [ebp + 16]
    lea	edx, [ecx - 1]
    cmp	edx, 7
    setae	dl
    cmp	dword [ebp + 20], 2
    setne	dh
    or	dh, dl
    jne	.LBB39_19

    or	ecx, 2228224
    push	ecx
    push	edi
    push	0
    push	20
    call	__vibe_syscall3
    add	esp, 16
    mov	edx, eax
    test	eax, eax
    js	.LBB39_4

    mov	dword [esi], edx
    mov	eax, dword [ebp + 28]
    xor	eax, 2147483647
    mov	dword [ebp - 16], eax
    xor	esi, esi
align 16
.LBB39_7:
    cmp	esi, dword [ebp - 16]
    ja	.LBB39_8

    mov	eax, edi
    sub	eax, esi
    cmp	eax, 2147483647
    jb	.LBB39_13

    mov	eax, 2147483647
.LBB39_13:
    mov	ecx, dword [ebp + 28]
    add	ecx, esi
    mov	ebx, edx
    add	edx, esi
    push	ecx
    push	eax
    push	edx
    push	dword [ebp + 24]
    call	vibe_user_pread
    add	esp, 16
    mov	edi, eax
    test	eax, eax
    js	.LBB39_14

    xor	eax, eax
    test	edi, edi
    je	.LBB39_19

    add	esi, edi
    mov	edi, dword [ebp + 12]
    cmp	esi, edi
    mov	edx, ebx
    jb	.LBB39_7
    jmp	.LBB39_19
.LBB39_4:
    cmp	edx, -1
    mov	eax, -12
    je	.LBB39_19

    mov	eax, edx
    jmp	.LBB39_19
.LBB39_8:
    test	edx, edx
    je	.LBB39_10

    push	edi
    push	edx
    push	21
    call	__vibe_syscall2
    add	esp, 12
.LBB39_10:
    mov	eax, dword [ebp + 8]
    mov	dword [eax], 0
    mov	eax, -22
    jmp	.LBB39_19
.LBB39_14:
    test	ebx, ebx
    je	.LBB39_16

    push	dword [ebp + 12]
    push	ebx
    push	21
    call	__vibe_syscall2
    add	esp, 12
.LBB39_16:
    mov	eax, dword [ebp + 8]
    mov	dword [eax], 0
    mov	eax, edi
.LBB39_19:
    add	esp, 4
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end39:

global vibe_user_munmap

align 16
vibe_user_munmap:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 12]
    mov	eax, dword [ebp + 8]
    test	eax, eax
    sete	dl
    test	ecx, ecx
    sete	dh
    or	dh, dl
    jne	.LBB40_2

    push	ecx
    push	eax
    push	21
    call	__vibe_syscall2
    add	esp, 12
    pop	ebp
    ret
.LBB40_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end40:

global vibe_user_mmap_file_private

align 16
vibe_user_mmap_file_private:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 24]
    push	dword [ebp + 20]
    push	2
    push	dword [ebp + 16]
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    call	vibe_user_mmap_file
    add	esp, 24
    pop	ebp
    ret
.Lfunc_end41:

global vibe_user_heap_capabilities

align 16
vibe_user_heap_capabilities:

    push	ebp
    mov	ebp, esp
    mov	eax, 3
    pop	ebp
    ret
.Lfunc_end42:

global vibe_user_vm_capabilities

align 16
vibe_user_vm_capabilities:

    push	ebp
    mov	ebp, esp
    mov	eax, 65551
    pop	ebp
    ret
.Lfunc_end43:

global vibe_user_clock_gettime

align 16
vibe_user_clock_gettime:

    push	ebp
    mov	ebp, esp
    push	16
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	29
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end44:

global vibe_user_clock_monotonic

align 16
vibe_user_clock_monotonic:

    push	ebp
    mov	ebp, esp
    push	16
    push	dword [ebp + 8]
    push	1
    push	29
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end45:

global vibe_user_monotonic_milliseconds

align 16
vibe_user_monotonic_milliseconds:

    push	ebp
    mov	ebp, esp
    sub	esp, 16
    lea	eax, [ebp - 16]
    push	16
    push	eax
    push	1
    push	29
    call	__vibe_syscall3
    add	esp, 16
    mov	ecx, eax
    xor	eax, eax
    test	ecx, ecx
    js	.LBB46_2

    mov	eax, dword [ebp - 8]
.LBB46_2:
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end46:

global vibe_user_poll_input

align 16
vibe_user_poll_input:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB47_2

    push	0
    push	28
    push	eax
    push	28
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.LBB47_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end47:

global vibe_user_drain_input

align 16
vibe_user_drain_input:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	ebx, dword [ebp + 8]
    mov	edi, dword [ebp + 12]
    test	edi, edi
    sete	al
    mov	ecx, edi
    je	.LBB48_2

    mov	ecx, -22
.LBB48_2:
    xor	esi, esi
    test	ebx, ebx
    sete	dl
    jne	.LBB48_4

    mov	esi, ecx
.LBB48_4:
    or	al, dl
    jne	.LBB48_11

    xor	esi, esi
align 16
.LBB48_6:
    push	0
    push	28
    push	ebx
    push	28
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB48_7

    je	.LBB48_11

    inc	esi
    add	ebx, 28
    cmp	edi, esi
    jne	.LBB48_6

    mov	esi, edi
    jmp	.LBB48_11
.LBB48_7:
    mov	esi, eax
.LBB48_11:
    mov	eax, esi
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end48:

global vibe_user_input_status

align 16
vibe_user_input_status:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB49_2

    push	0
    push	132
    push	eax
    push	31
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.LBB49_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end49:

global vibe_user_input_device_status

align 16
vibe_user_input_device_status:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	.LBB50_2

    push	64
    push	eax
    push	dword [ebp + 8]
    push	39
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.LBB50_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end50:

global vibe_user_fb_get_info

align 16
vibe_user_fb_get_info:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB51_2

    push	eax
    push	22017
    push	1
    push	22
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.LBB51_2:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end51:

global vibe_user_fb_can_present_indexed

align 16
vibe_user_fb_can_present_indexed:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	ecx, dword [ebp + 12]
    xor	eax, eax
    test	ecx, ecx
    je	.LBB52_17

    cmp	dword [ecx], 0
    je	.LBB52_17

    cmp	dword [ecx + 4], 0
    je	.LBB52_17

    mov	edi, dword [ecx + 8]
    test	edi, edi
    je	.LBB52_17

    mov	ecx, dword [ecx + 12]
    test	ecx, ecx
    je	.LBB52_17

    mov	esi, dword [ebp + 8]
    mov	eax, ecx
    mul	edi
    seto	al
    test	esi, esi
    je	.LBB52_6

    test	al, al
    mov	eax, 0
    jne	.LBB52_17

    mov	edx, ecx
    imul	edx, edi
    test	edx, edx
    je	.LBB52_17

    mov	edx, dword [esi + 68]
    mov	ebx, edx
    not	ebx
    test	bl, 3
    jne	.LBB52_17

    cmp	dword [esi + 72], 1
    jne	.LBB52_17

    test	dl, 32
    mov	edx, dword [esi + 76]
    jne	.LBB52_12

    test	edx, edx
    setne	bl
    cmp	edi, edx
    seta	dl
    test	bl, dl
    jne	.LBB52_17

    mov	edx, dword [esi + 80]
    jmp	.LBB52_16
.LBB52_6:
    xor	eax, eax
.LBB52_17:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.LBB52_12:
    cmp	edi, edx
    jne	.LBB52_17

    cmp	ecx, dword [esi + 80]
    mov	edx, ecx
    jne	.LBB52_17
.LBB52_16:
    test	edx, edx
    sete	al
    cmp	ecx, edx
    setbe	cl
    or	cl, al
    movzx	eax, cl
    jmp	.LBB52_17
.Lfunc_end52:

global vibe_user_present_indexed

align 16
vibe_user_present_indexed:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB53_6

    cmp	dword [eax], 0
    je	.LBB53_6

    cmp	dword [eax + 4], 0
    je	.LBB53_6

    cmp	dword [eax + 8], 0
    je	.LBB53_6

    cmp	dword [eax + 12], 0
    je	.LBB53_6

    push	eax
    push	22018
    push	1
    push	22
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.LBB53_6:
    mov	eax, -22
    pop	ebp
    ret
.Lfunc_end53:

global vibe_user_present_indexed_checked

align 16
vibe_user_present_indexed_checked:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 84
    mov	esi, dword [ebp + 8]
    test	esi, esi
    je	.LBB54_21

    cmp	dword [esi], 0
    je	.LBB54_21

    cmp	dword [esi + 4], 0
    je	.LBB54_21

    cmp	dword [esi + 8], 0
    je	.LBB54_21

    cmp	dword [esi + 12], 0
    je	.LBB54_21

    lea	eax, [ebp - 96]
    push	eax
    push	22017
    push	1
    push	22
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB54_22

    mov	ebx, dword [ebp - 28]
    mov	eax, ebx
    not	eax
    test	al, 3
    mov	eax, -38
    jne	.LBB54_22

    cmp	dword [ebp - 24], 1
    jne	.LBB54_22

    cmp	dword [esi], 0
    je	.LBB54_21

    cmp	dword [esi + 4], 0
    je	.LBB54_21

    mov	edi, dword [esi + 8]
    test	edi, edi
    je	.LBB54_21

    mov	ecx, dword [esi + 12]
    test	ecx, ecx
    je	.LBB54_21

    mov	eax, ecx
    mul	edi
    jo	.LBB54_21

    mov	eax, ecx
    imul	eax, edi
    test	eax, eax
    je	.LBB54_21

    test	bl, 32
    mov	eax, dword [ebp - 20]
    jne	.LBB54_29

    test	eax, eax
    setne	dl
    cmp	edi, eax
    seta	al
    test	dl, al
    jne	.LBB54_21

    mov	eax, dword [ebp - 16]
    test	eax, eax
    setne	dl
    cmp	ecx, eax
    seta	al
    test	dl, al
    jmp	.LBB54_32
.LBB54_29:
    cmp	edi, eax
    jne	.LBB54_21

    cmp	ecx, dword [ebp - 16]
.LBB54_32:
    mov	eax, -22
    jne	.LBB54_22

    push	esi
    push	22018
    push	1
    push	22
    call	__vibe_syscall3
    add	esp, 16
    jmp	.LBB54_22
.LBB54_21:
    mov	eax, -22
.LBB54_22:
    add	esp, 84
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end54:

global vibe_user_listdir

align 16
vibe_user_listdir:

    push	ebp
    mov	ebp, esp
    push	ebx
    mov	eax, dword [ebp + 8]
    test	eax, eax
    je	.LBB55_3

    mov	edx, dword [ebp + 16]
    mov	ecx, dword [ebp + 12]
    test	edx, edx
    setne	bl
    test	ecx, ecx
    sete	bh
    test	bh, bl
    jne	.LBB55_3

    push	edx
    push	ecx
    push	eax
    push	30
    call	__vibe_syscall3
    add	esp, 16
    jmp	.LBB55_4
.LBB55_3:
    mov	eax, -22
.LBB55_4:
    pop	ebx
    pop	ebp
    ret
.Lfunc_end55:

global vibe_user_file_size

align 16
vibe_user_file_size:

    push	ebp
    mov	ebp, esp
    push	esi
    sub	esp, 44
    mov	esi, dword [ebp + 12]
    mov	ecx, dword [ebp + 8]
    test	ecx, ecx
    sete	dl
    test	esi, esi
    sete	dh
    mov	eax, -22
    or	dh, dl
    jne	.LBB56_6

    lea	eax, [ebp - 48]
    push	eax
    push	ecx
    push	18
    call	__vibe_syscall2
    add	esp, 12
    test	eax, eax
    js	.LBB56_6

    mov	ecx, 61440
    and	ecx, dword [ebp - 40]
    mov	eax, -21
    cmp	ecx, 32768
    jne	.LBB56_6

    mov	eax, dword [ebp - 20]
    test	eax, eax
    js	.LBB56_4

    mov	dword [esi], eax
    xor	eax, eax
    jmp	.LBB56_6
.LBB56_4:
    mov	eax, -75
.LBB56_6:
    add	esp, 44
    pop	esi
    pop	ebp
    ret
.Lfunc_end56:

global vibe_user_file_read_at

align 16
vibe_user_file_read_at:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	ecx, dword [ebp + 8]
    mov	eax, -22
    test	ecx, ecx
    je	.LBB57_12

    mov	ebx, dword [ebp + 20]
    mov	esi, dword [ebp + 16]
    test	ebx, ebx
    setne	dl
    test	esi, esi
    sete	dh
    test	dh, dl
    jne	.LBB57_12

    mov	eax, dword [ebp + 24]
    mov	edi, dword [ebp + 12]
    test	eax, eax
    je	.LBB57_4

    mov	dword [eax], 0
.LBB57_4:
    test	edi, edi
    js	.LBB57_5

    push	0
    push	0
    push	ecx
    push	6
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB57_12

    push	edi
    push	ebx
    push	esi
    push	eax
    mov	edi, eax
    call	vibe_user_pread
    add	esp, 16
    mov	esi, eax
    push	edi
    push	12
    call	__vibe_syscall1
    add	esp, 8
    test	esi, esi
    js	.LBB57_8

    mov	edi, dword [ebp + 24]
    test	edi, edi
    sete	cl
    test	eax, eax
    sets	dl
    or	dl, cl
    je	.LBB57_11

    mov	ecx, eax
    sar	eax, 31
    and	eax, ecx
    jmp	.LBB57_12
.LBB57_5:
    mov	eax, -75
    jmp	.LBB57_12
.LBB57_8:
    mov	eax, esi
    jmp	.LBB57_12
.LBB57_11:
    mov	dword [edi], esi
    xor	eax, eax
.LBB57_12:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end57:

global vibe_user_file_write_at

align 16
vibe_user_file_write_at:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	ecx, dword [ebp + 8]
    mov	eax, -22
    test	ecx, ecx
    je	.LBB58_12

    mov	ebx, dword [ebp + 20]
    mov	esi, dword [ebp + 16]
    test	ebx, ebx
    setne	dl
    test	esi, esi
    sete	dh
    test	dh, dl
    jne	.LBB58_12

    mov	eax, dword [ebp + 24]
    mov	edi, dword [ebp + 12]
    test	eax, eax
    je	.LBB58_4

    mov	dword [eax], 0
.LBB58_4:
    test	edi, edi
    js	.LBB58_5

    push	0
    push	258
    push	ecx
    push	6
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB58_12

    push	edi
    push	ebx
    push	esi
    push	eax
    mov	edi, eax
    call	vibe_user_pwrite
    add	esp, 16
    mov	esi, eax
    push	edi
    push	12
    call	__vibe_syscall1
    add	esp, 8
    test	esi, esi
    js	.LBB58_8

    mov	edi, dword [ebp + 24]
    test	edi, edi
    sete	cl
    test	eax, eax
    sets	dl
    or	dl, cl
    je	.LBB58_11

    mov	ecx, eax
    sar	eax, 31
    and	eax, ecx
    jmp	.LBB58_12
.LBB58_5:
    mov	eax, -75
    jmp	.LBB58_12
.LBB58_8:
    mov	eax, esi
    jmp	.LBB58_12
.LBB58_11:
    mov	dword [edi], esi
    xor	eax, eax
.LBB58_12:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end58:

global vibe_user_file_read_all

align 16
vibe_user_file_read_all:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 48
    mov	ebx, dword [ebp + 8]
    mov	eax, -22
    test	ebx, ebx
    je	.LBB59_21

    mov	edi, dword [ebp + 16]
    mov	esi, dword [ebp + 12]
    test	edi, edi
    setne	cl
    test	esi, esi
    sete	dl
    test	dl, cl
    jne	.LBB59_21

    lea	eax, [ebp - 60]
    push	eax
    push	ebx
    push	18
    call	__vibe_syscall2
    add	esp, 12
    test	eax, eax
    js	.LBB59_21

    mov	ecx, 61440
    and	ecx, dword [ebp - 52]
    mov	eax, -21
    cmp	ecx, 32768
    jne	.LBB59_21

    mov	ecx, dword [ebp - 32]
    test	ecx, ecx
    js	.LBB59_5

    mov	eax, dword [ebp + 20]
    test	eax, eax
    je	.LBB59_8

    mov	dword [eax], ecx
.LBB59_8:
    mov	eax, -28
    cmp	ecx, edi
    ja	.LBB59_21

    mov	dword [ebp - 16], ecx
    push	0
    push	0
    push	ebx
    push	6
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB59_21

    mov	ecx, dword [ebp - 16]
    test	ecx, ecx
    je	.LBB59_20

    test	esi, esi
    je	.LBB59_12

    xor	edi, edi
.LBB59_14:
    sub	ecx, edi
    lea	edx, [esi + edi]
    push	ecx
    push	edx
    mov	ebx, eax
    push	eax
    push	7
    call	__vibe_syscall3
    add	esp, 16
    test	eax, eax
    js	.LBB59_15

    je	.LBB59_18

    add	edi, eax
    mov	ecx, dword [ebp - 16]
    cmp	edi, ecx
    mov	eax, ebx
    jb	.LBB59_14
.LBB59_20:
    push	eax
    push	12
    call	__vibe_syscall1
    add	esp, 8
    mov	ecx, eax
    sar	eax, 31
    and	eax, ecx
    jmp	.LBB59_21
.LBB59_5:
    mov	eax, -75
.LBB59_21:
    add	esp, 48
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.LBB59_12:
    mov	esi, -22
    jmp	.LBB59_16
.LBB59_15:
    mov	esi, eax
    mov	eax, ebx
.LBB59_16:
    push	eax
    push	12
    call	__vibe_syscall1
    add	esp, 8
    mov	eax, esi
    jmp	.LBB59_21
.LBB59_18:
    push	ebx
    push	12
    call	__vibe_syscall1
    add	esp, 8
    mov	eax, -5
    jmp	.LBB59_21
.Lfunc_end59:

global vibe_user_startup_contract_ok

align 16
vibe_user_startup_contract_ok:

    mov	ecx, dword [vibe_user_start_status]
    not	ecx
    xor	eax, eax
    test	cl, 15
    jne	.LBB60_6

    mov	ecx, dword [vibe_user_argc]
    add	ecx, -9
    cmp	ecx, -8
    jb	.LBB60_6

    mov	ecx, dword [vibe_user_argv]
    test	ecx, ecx
    je	.LBB60_6

    push	ebp
    mov	ebp, esp
    cmp	dword [ecx], 0
    je	.LBB60_5

    cmp	dword [vibe_user_environ], 0
    setne	al
    cmp	dword [vibe_user_auxv], 0
    setne	cl
    and	cl, al
    movzx	eax, cl
.LBB60_5:
    pop	ebp
.LBB60_6:
    ret
.Lfunc_end60:

global vibe_user_auxv_get

align 16
vibe_user_auxv_get:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	ecx, dword [ebp + 12]
    test	ecx, ecx
    je	.LBB61_1

    mov	dword [ecx], 0
    mov	edx, dword [vibe_user_auxv]
    mov	eax, -2
    test	edx, edx
    je	.LBB61_9

    mov	ebx, dword [edx]
    test	ebx, ebx
    je	.LBB61_9

    mov	esi, dword [ebp + 8]
    xor	edi, edi
    cmp	ebx, esi
    je	.LBB61_8

    mov	ebx, dword [edx + 8]
    test	ebx, ebx
    je	.LBB61_9

    mov	edi, 8
    cmp	ebx, esi
    je	.LBB61_8

    mov	edi, dword [edx + 16]
    test	edi, edi
    setne	bl
    cmp	edi, esi
    sete	bh
    mov	edi, 16
    test	bl, bh
    je	.LBB61_9
.LBB61_8:
    mov	eax, dword [edx + edi + 4]
    mov	dword [ecx], eax
    xor	eax, eax
    jmp	.LBB61_9
.LBB61_1:
    mov	eax, -22
.LBB61_9:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end61:

global vibe_user_auxv_value

align 16
vibe_user_auxv_value:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	eax, dword [ebp + 12]
    mov	ecx, dword [vibe_user_auxv]
    test	ecx, ecx
    je	.LBB62_7

    mov	edi, dword [ecx]
    test	edi, edi
    je	.LBB62_7

    mov	edx, dword [ebp + 8]
    xor	esi, esi
    cmp	edi, edx
    je	.LBB62_6

    mov	edi, dword [ecx + 8]
    test	edi, edi
    je	.LBB62_7

    mov	esi, 8
    cmp	edi, edx
    je	.LBB62_6

    mov	esi, dword [ecx + 16]
    test	esi, esi
    setne	bl
    cmp	esi, edx
    sete	dl
    mov	esi, 16
    test	bl, dl
    je	.LBB62_7
.LBB62_6:
    mov	eax, dword [ecx + esi + 4]
.LBB62_7:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
.Lfunc_end62:

global vibe_user_page_size

align 16
vibe_user_page_size:

    mov	ecx, dword [vibe_user_auxv]
    mov	eax, 4096
    test	ecx, ecx
    je	.LBB63_9

    push	ebp
    mov	ebp, esp
    push	esi
    mov	esi, dword [ecx]
    test	esi, esi
    je	.LBB63_8

    xor	edx, edx
    cmp	esi, 6
    je	.LBB63_6

    mov	esi, dword [ecx + 8]
    test	esi, esi
    je	.LBB63_8

    mov	edx, 8
    cmp	esi, 6
    je	.LBB63_6

    mov	edx, 16
    cmp	dword [ecx + 16], 6
    jne	.LBB63_8
.LBB63_6:
    mov	ecx, dword [ecx + edx + 4]
    test	ecx, ecx
    mov	eax, 4096
    je	.LBB63_8

    mov	eax, ecx
.LBB63_8:
    pop	esi
    pop	ebp
.LBB63_9:
    ret
.Lfunc_end63:

global vibe_user_entry_address

align 16
vibe_user_entry_address:

    mov	ecx, dword [vibe_user_auxv]
    test	ecx, ecx
    je	.LBB64_1

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ecx]
    test	eax, eax
    je	.LBB64_10

    xor	edx, edx
    cmp	eax, 9
    je	.LBB64_9

    mov	eax, dword [ecx + 8]
    test	eax, eax
    je	.LBB64_10

    mov	edx, 8
    cmp	eax, 9
    je	.LBB64_9

    mov	edx, 16
    cmp	dword [ecx + 16], 9
    jne	.LBB64_8
.LBB64_9:
    mov	eax, dword [ecx + edx + 4]
.LBB64_10:
    pop	ebp
    ret
.LBB64_1:
    xor	eax, eax
    ret
.LBB64_8:
    xor	eax, eax
    pop	ebp
    ret
.Lfunc_end64:

global vibe_user_execv

align 16
vibe_user_execv:

    push	ebp
    mov	ebp, esp
    push	0
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	16
    call	__vibe_syscall3
    add	esp, 16
    pop	ebp
    ret
.Lfunc_end65:

global vibe_user_report_probe

align 16
vibe_user_report_probe:

    push	ebp
    mov	ebp, esp
    push	dword [ebp + 12]
    push	dword [ebp + 8]
    push	1
    call	__vibe_syscall2
    add	esp, 12
    pop	ebp
    ret
.Lfunc_end66:
