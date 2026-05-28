	.build_version macos, 13, 0	sdk_version 26, 5
	.section	__TEXT,__text,regular,pure_instructions
	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0                          ## -- Begin function main
LCPI0_0:
	.byte	128                             ## 0x80
	.byte	1                               ## 0x1
	.byte	1                               ## 0x1
	.byte	0                               ## 0x0
	.byte	6                               ## 0x6
	.byte	254                             ## 0xfe
	.byte	255                             ## 0xff
	.byte	255                             ## 0xff
	.byte	0                               ## 0x0
	.byte	8                               ## 0x8
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	248                             ## 0xf8
	.byte	1                               ## 0x1
	.byte	0                               ## 0x0
LCPI0_1:
	.byte	0                               ## 0x0
	.byte	2                               ## 0x2
	.byte	2                               ## 0x2
	.byte	1                               ## 0x1
	.byte	0                               ## 0x0
	.byte	2                               ## 0x2
	.byte	0                               ## 0x0
	.byte	2                               ## 0x2
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	248                             ## 0xf8
	.byte	0                               ## 0x0
	.byte	1                               ## 0x1
	.byte	63                              ## 0x3f
	.byte	0                               ## 0x0
	.byte	16                              ## 0x10
LCPI0_2:
	.byte	0                               ## 0x0
	.byte	1                               ## 0x1
	.byte	2                               ## 0x2
	.byte	3                               ## 0x3
	.byte	4                               ## 0x4
	.byte	5                               ## 0x5
	.byte	6                               ## 0x6
	.byte	7                               ## 0x7
	.byte	8                               ## 0x8
	.byte	9                               ## 0x9
	.byte	10                              ## 0xa
	.byte	11                              ## 0xb
	.byte	12                              ## 0xc
	.byte	13                              ## 0xd
	.byte	14                              ## 0xe
	.byte	15                              ## 0xf
LCPI0_3:
	.space	16,16
LCPI0_4:
	.space	16,63
LCPI0_5:
	.space	16,48
LCPI0_6:
	.space	16,32
LCPI0_7:
	.space	16,96
LCPI0_8:
	.space	16,64
LCPI0_9:
	.space	16,80
LCPI0_10:
	.space	16,112
LCPI0_11:
	.space	16,128
LCPI0_12:
	.byte	16                              ## 0x10
	.byte	17                              ## 0x11
	.byte	18                              ## 0x12
	.byte	19                              ## 0x13
	.byte	20                              ## 0x14
	.byte	21                              ## 0x15
	.byte	22                              ## 0x16
	.byte	23                              ## 0x17
	.byte	24                              ## 0x18
	.byte	25                              ## 0x19
	.byte	26                              ## 0x1a
	.byte	27                              ## 0x1b
	.byte	28                              ## 0x1c
	.byte	29                              ## 0x1d
	.byte	30                              ## 0x1e
	.byte	31                              ## 0x1f
LCPI0_13:
	.long	1                               ## 0x1
	.long	1                               ## 0x1
	.long	1                               ## 0x1
	.long	1                               ## 0x1
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	4
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movl	$135416, %eax                   ## imm = 0x210F8
	callq	____chkstk_darwin
	subq	%rax, %rsp
	popq	%rax
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rsi, -135320(%rbp)             ## 8-byte Spill
	movl	%edi, %ebx
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	movslq	%edi, %rdi
	movl	$8, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_486
## %bb.1:
	movq	%rax, %r14
	cmpl	$4, %ebx
	movq	%rax, -135416(%rbp)             ## 8-byte Spill
	movl	%ebx, -135328(%rbp)             ## 4-byte Spill
	je	LBB0_5
## %bb.2:
	cmpl	$5, %ebx
	jne	LBB0_7
## %bb.3:
	movq	-135320(%rbp), %rax             ## 8-byte Reload
	movq	8(%rax), %rbx
	leaq	L_.str(%rip), %rsi
	movq	%rbx, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_9
## %bb.4:
	movq	-135320(%rbp), %rax             ## 8-byte Reload
	movq	32(%rax), %rdi
	movq	16(%rax), %rsi
	movq	24(%rax), %rdx
	movl	$1, %ecx
	callq	_mutate_root_marker
	jmp	LBB0_409
LBB0_5:
	movq	-135320(%rbp), %rax             ## 8-byte Reload
	movq	8(%rax), %rbx
	leaq	L_.str.1(%rip), %rsi
	movq	%rbx, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_9
## %bb.6:
	movq	-135320(%rbp), %rax             ## 8-byte Reload
	movq	16(%rax), %rsi
	movq	24(%rax), %rdi
	leaq	L_.str.2(%rip), %rdx
	xorl	%ecx, %ecx
	callq	_mutate_root_marker
	jmp	LBB0_409
LBB0_7:
	cmpl	$3, %ebx
	jl	LBB0_12
## %bb.8:
	movq	-135320(%rbp), %rax             ## 8-byte Reload
	movq	8(%rax), %rbx
LBB0_9:
	leaq	L_.str.3(%rip), %rsi
	movq	%rbx, %rdi
	callq	_strcmp
	testl	%eax, %eax
	movl	-135328(%rbp), %ecx             ## 4-byte Reload
	jne	LBB0_13
## %bb.10:
	pxor	%xmm0, %xmm0
	movdqa	%xmm0, -135184(%rbp)
	movdqa	%xmm0, -135200(%rbp)
	movdqa	%xmm0, -135216(%rbp)
	movdqa	%xmm0, -135232(%rbp)
	movdqa	%xmm0, -135248(%rbp)
	movdqa	%xmm0, -135264(%rbp)
	movdqa	%xmm0, -135280(%rbp)
	movdqa	%xmm0, -135296(%rbp)
	movq	$0, -135168(%rbp)
	movq	-135320(%rbp), %rax             ## 8-byte Reload
	movq	16(%rax), %rax
	movq	%rax, -135400(%rbp)             ## 8-byte Spill
	cmpl	$4, %ecx
	jb	LBB0_98
## %bb.11:
	movq	$0, -135408(%rbp)               ## 8-byte Folded Spill
	movq	-135256(%rbp), %rax
	movq	%rax, -135344(%rbp)             ## 8-byte Spill
	movq	-135264(%rbp), %rax
	movq	%rax, -135384(%rbp)             ## 8-byte Spill
	movq	-135280(%rbp), %rax
	movq	%rax, -135352(%rbp)             ## 8-byte Spill
	movq	-135272(%rbp), %rax
	movq	%rax, -135336(%rbp)             ## 8-byte Spill
	movl	$3, %r12d
	leaq	L_.str.4(%rip), %r15
	movl	$0, -135392(%rbp)               ## 4-byte Folded Spill
	xorl	%r13d, %r13d
	xorl	%r14d, %r14d
	jmp	LBB0_111
LBB0_12:
	cmpl	$2, %ebx
	jne	LBB0_499
LBB0_13:
	movl	$1, %r12d
	movq	$0, -135352(%rbp)               ## 8-byte Folded Spill
	movq	$0, -135344(%rbp)               ## 8-byte Folded Spill
	xorl	%r15d, %r15d
	xorl	%r13d, %r13d
	movq	$0, -135384(%rbp)               ## 8-byte Folded Spill
	movq	$0, -135336(%rbp)               ## 8-byte Folded Spill
	xorl	%r14d, %r14d
	jmp	LBB0_17
LBB0_14:                                ##   in Loop: Header=BB0_17 Depth=1
	movl	$1, %r13d
LBB0_15:                                ##   in Loop: Header=BB0_17 Depth=1
	movl	-135328(%rbp), %r9d             ## 4-byte Reload
	.p2align	4
LBB0_16:                                ##   in Loop: Header=BB0_17 Depth=1
	incl	%r12d
	cmpl	%r9d, %r12d
	jge	LBB0_51
LBB0_17:                                ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_41 Depth 2
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rbx
	movq	%rbx, %rdi
	leaq	L_.str.14(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_24
## %bb.18:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.15(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_24
## %bb.19:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.16(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_26
## %bb.20:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.17(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_28
## %bb.21:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.19(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_44
## %bb.22:                              ##   in Loop: Header=BB0_17 Depth=1
	cmpb	$45, (%rbx)
	movq	-135336(%rbp), %rcx             ## 8-byte Reload
	je	LBB0_478
## %bb.23:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	-135416(%rbp), %rax             ## 8-byte Reload
	movq	%rbx, (%rax,%rcx,8)
	incq	%rcx
	movq	%rcx, -135336(%rbp)             ## 8-byte Spill
	jmp	LBB0_15
	.p2align	4
LBB0_24:                                ##   in Loop: Header=BB0_17 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %r9d             ## 4-byte Reload
	cmpl	%r9d, %r12d
	jge	LBB0_460
## %bb.25:                              ##   in Loop: Header=BB0_17 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, -135352(%rbp)             ## 8-byte Spill
	jmp	LBB0_16
LBB0_26:                                ##   in Loop: Header=BB0_17 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %r9d             ## 4-byte Reload
	cmpl	%r9d, %r12d
	jge	LBB0_475
## %bb.27:                              ##   in Loop: Header=BB0_17 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, -135344(%rbp)             ## 8-byte Spill
	jmp	LBB0_16
LBB0_28:                                ##   in Loop: Header=BB0_17 Depth=1
	movq	%r14, -135408(%rbp)             ## 8-byte Spill
	incl	%r12d
	cmpl	-135328(%rbp), %r12d            ## 4-byte Folded Reload
	jge	LBB0_481
## %bb.29:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%r13, -135400(%rbp)             ## 8-byte Spill
	leaq	8(,%r13,8), %rax
	leaq	(%rax,%rax,2), %rsi
	movq	%r15, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_480
## %bb.30:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rax, %r14
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %r15
	movq	%r15, %rdi
	movl	$61, %esi
	callq	_strchr
	testq	%rax, %rax
	je	LBB0_471
## %bb.31:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rax, %rbx
	movq	%rax, %r13
	subq	%r15, %r13
	je	LBB0_471
## %bb.32:                              ##   in Loop: Header=BB0_17 Depth=1
	cmpb	$0, 1(%rbx)
	je	LBB0_471
## %bb.33:                              ##   in Loop: Header=BB0_17 Depth=1
	cmpq	$64, %r13
	jae	LBB0_479
## %bb.34:                              ##   in Loop: Header=BB0_17 Depth=1
	movl	$64, %ecx
	leaq	-135296(%rbp), %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	callq	___memcpy_chk
	movb	$0, -135296(%rbp,%r13)
	movq	$0, -80(%rbp)
	movl	$4, %ecx
	leaq	-135296(%rbp), %rdi
	leaq	-4176(%rbp), %rsi
	leaq	-80(%rbp), %rdx
	callq	_parse_path83
	cmpq	$1, -80(%rbp)
	jne	LBB0_482
## %bb.35:                              ##   in Loop: Header=BB0_17 Depth=1
	movl	-4168(%rbp), %eax
	movl	$19525, %ecx                    ## imm = 0x4C45
	xorl	%ecx, %eax
	movzbl	-4166(%rbp), %ecx
	xorl	$70, %ecx
	orw	%ax, %cx
	movq	-135400(%rbp), %r8              ## 8-byte Reload
	jne	LBB0_483
## %bb.36:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%r14, %r15
	leaq	(%r8,%r8,2), %rax
	leaq	(%r14,%rax,8), %rax
	movl	-4169(%rbp), %ecx
	movl	%ecx, 7(%rax)
	movq	-4176(%rbp), %rcx
	movq	%rcx, (%rax)
	movq	(%rax), %rcx
	movabsq	$2314885604590964548, %rdx      ## imm = 0x202020314D4F4F44
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$4918308063554842957, %rsi      ## imm = 0x444157202020314D
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	movq	-135408(%rbp), %r14             ## 8-byte Reload
	je	LBB0_465
## %bb.37:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	(%rax), %rcx
	movabsq	$2314934069018903883, %rdx      ## imm = 0x20204C454E52454B
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499685168104782, %rsi      ## imm = 0x464C4520204C454E
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	LBB0_465
## %bb.38:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	(%rax), %rcx
	movabsq	$4778128234594521941, %rdx      ## imm = 0x424F525052455355
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499831985918034, %rsi      ## imm = 0x464C45424F525052
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	LBB0_465
## %bb.39:                              ##   in Loop: Header=BB0_17 Depth=1
	incq	%rbx
	movq	%rbx, 16(%rax)
	testq	%r8, %r8
	je	LBB0_14
## %bb.40:                              ##   in Loop: Header=BB0_17 Depth=1
	leaq	1(%r8), %rcx
	movq	%r15, %rdx
	movl	-135328(%rbp), %r9d             ## 4-byte Reload
	.p2align	4
LBB0_41:                                ##   Parent Loop BB0_17 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	(%rdx), %rsi
	xorq	(%rax), %rsi
	movq	3(%rdx), %rdi
	xorq	3(%rax), %rdi
	orq	%rsi, %rdi
	je	LBB0_457
## %bb.42:                              ##   in Loop: Header=BB0_41 Depth=2
	addq	$24, %rdx
	decq	%r8
	jne	LBB0_41
## %bb.43:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rcx, %r13
	jmp	LBB0_16
LBB0_44:                                ##   in Loop: Header=BB0_17 Depth=1
	incl	%r12d
	cmpl	-135328(%rbp), %r12d            ## 4-byte Folded Reload
	jge	LBB0_488
## %bb.45:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%r13, -135400(%rbp)             ## 8-byte Spill
	movq	%r15, -135392(%rbp)             ## 8-byte Spill
	leaq	1(%r14), %rax
	movq	%rax, -135408(%rbp)             ## 8-byte Spill
	imulq	$104, %rax, %rsi
	movq	-135384(%rbp), %rdi             ## 8-byte Reload
	callq	_realloc
	movq	%rax, -135384(%rbp)             ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_490
## %bb.46:                              ##   in Loop: Header=BB0_17 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rbx
	movq	%rbx, %rdi
	movl	$61, %esi
	callq	_strchr
	testq	%rax, %rax
	je	LBB0_477
## %bb.47:                              ##   in Loop: Header=BB0_17 Depth=1
	movq	%rax, %r13
	movq	%rax, %r15
	subq	%rbx, %r15
	je	LBB0_477
## %bb.48:                              ##   in Loop: Header=BB0_17 Depth=1
	cmpb	$0, 1(%r13)
	je	LBB0_477
## %bb.49:                              ##   in Loop: Header=BB0_17 Depth=1
	cmpq	$96, %r15
	jae	LBB0_489
## %bb.50:                              ##   in Loop: Header=BB0_17 Depth=1
	imulq	$104, %r14, %r14
	addq	-135384(%rbp), %r14             ## 8-byte Folded Reload
	incq	%r13
	movq	%r14, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	_memcpy
	movb	$0, (%r14,%r15)
	movq	%r13, 96(%r14)
	movq	-135408(%rbp), %r14             ## 8-byte Reload
	movq	-135392(%rbp), %r15             ## 8-byte Reload
	movq	-135400(%rbp), %r13             ## 8-byte Reload
	jmp	LBB0_15
LBB0_51:
	movq	-135344(%rbp), %r12             ## 8-byte Reload
	testq	%r12, %r12
	je	LBB0_85
## %bb.52:
	cmpq	$0, -135336(%rbp)               ## 8-byte Folded Reload
	jne	LBB0_491
## %bb.53:
	cmpq	$0, -135352(%rbp)               ## 8-byte Folded Reload
	jne	LBB0_491
## %bb.54:
	testq	%r13, %r13
	jne	LBB0_491
## %bb.55:
	testq	%r14, %r14
	jne	LBB0_491
## %bb.56:
	movq	%r12, %rdi
	callq	_read_file
	cmpq	$67108864, %rdx                 ## imm = 0x4000000
	jne	LBB0_492
## %bb.57:
	movq	%rax, %rbx
	cmpw	$-21931, 510(%rax)              ## imm = 0xAA55
	jne	LBB0_493
## %bb.58:
	cmpl	$2048, 454(%rbx)                ## imm = 0x800
	jne	LBB0_494
## %bb.59:
	cmpl	$129024, 458(%rbx)              ## imm = 0x1F800
	jne	LBB0_494
## %bb.60:
	cmpw	$-21931, 1049086(%rbx)          ## imm = 0xAA55
	jne	LBB0_495
## %bb.61:
	cmpw	$512, 1048587(%rbx)             ## imm = 0x200
	jne	LBB0_496
## %bb.62:
	movq	%r15, -135392(%rbp)             ## 8-byte Spill
	cmpb	$2, 1048589(%rbx)
	jne	LBB0_497
## %bb.63:
	leaq	L_str.233(%rip), %rdi
	callq	_puts
	leaq	L_.str.125(%rip), %rdi
	movl	$67108864, %esi                 ## imm = 0x4000000
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.126(%rip), %rdi
	movl	$2048, %esi                     ## imm = 0x800
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.127(%rip), %rdi
	movl	$129024, %esi                   ## imm = 0x1F800
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.128(%rip), %rdi
	movl	$2561, %esi                     ## imm = 0xA01
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.129(%rip), %rdi
	movl	$2593, %esi                     ## imm = 0xA21
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.130(%rip), %rdi
	movl	$64239, %esi                    ## imm = 0xFAEF
	xorl	%eax, %eax
	callq	_printf
	movq	%rbx, %r13
	addq	$1311232, %r13                  ## imm = 0x140200
	leaq	L_.str.131(%rip), %r14
	leaq	-135296(%rbp), %r15
	xorl	%r12d, %r12d
	jmp	LBB0_67
LBB0_64:                                ##   in Loop: Header=BB0_67 Depth=1
	addq	$2, %rax
LBB0_65:                                ##   in Loop: Header=BB0_67 Depth=1
	movb	$0, -135296(%rbp,%rax)
	movzbl	11(%r13), %ecx
	movzwl	26(%r13), %r8d
	movl	28(%r13), %r9d
	movq	%r14, %rdi
	movl	%r12d, %esi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
LBB0_66:                                ##   in Loop: Header=BB0_67 Depth=1
	incq	%r12
	addq	$32, %r13
	cmpq	$512, %r12                      ## imm = 0x200
	je	LBB0_84
LBB0_67:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%r13), %eax
	cmpl	$229, %eax
	je	LBB0_66
## %bb.68:                              ##   in Loop: Header=BB0_67 Depth=1
	testl	%eax, %eax
	je	LBB0_84
## %bb.69:                              ##   in Loop: Header=BB0_67 Depth=1
	cmpb	$32, %al
	jne	LBB0_71
## %bb.70:                              ##   in Loop: Header=BB0_67 Depth=1
	xorl	%eax, %eax
	jmp	LBB0_79
	.p2align	4
LBB0_71:                                ##   in Loop: Header=BB0_67 Depth=1
	movb	%al, -135296(%rbp)
	movzbl	1(%r13), %ecx
	movl	$1, %eax
	cmpb	$32, %cl
	je	LBB0_79
## %bb.72:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135295(%rbp)
	movzbl	2(%r13), %ecx
	movl	$2, %eax
	cmpb	$32, %cl
	je	LBB0_79
## %bb.73:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135294(%rbp)
	movzbl	3(%r13), %ecx
	movl	$3, %eax
	cmpb	$32, %cl
	je	LBB0_79
## %bb.74:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135293(%rbp)
	movzbl	4(%r13), %ecx
	movl	$4, %eax
	cmpb	$32, %cl
	je	LBB0_79
## %bb.75:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135292(%rbp)
	movzbl	5(%r13), %ecx
	movl	$5, %eax
	cmpb	$32, %cl
	je	LBB0_79
## %bb.76:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135291(%rbp)
	movzbl	6(%r13), %ecx
	movl	$6, %eax
	cmpb	$32, %cl
	je	LBB0_79
## %bb.77:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135290(%rbp)
	movzbl	7(%r13), %ecx
	movl	$7, %eax
	cmpb	$32, %cl
	je	LBB0_79
## %bb.78:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135289(%rbp)
	movl	$8, %eax
	.p2align	4
LBB0_79:                                ##   in Loop: Header=BB0_67 Depth=1
	movzbl	8(%r13), %ecx
	cmpb	$32, %cl
	je	LBB0_65
## %bb.80:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	$46, -135296(%rbp,%rax)
	movb	%cl, -135295(%rbp,%rax)
	movzbl	9(%r13), %ecx
	cmpb	$32, %cl
	je	LBB0_64
## %bb.81:                              ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135294(%rbp,%rax)
	movzbl	10(%r13), %ecx
	cmpb	$32, %cl
	jne	LBB0_83
## %bb.82:                              ##   in Loop: Header=BB0_67 Depth=1
	addq	$3, %rax
	jmp	LBB0_65
LBB0_83:                                ##   in Loop: Header=BB0_67 Depth=1
	movb	%cl, -135293(%rbp,%rax)
	addq	$4, %rax
	jmp	LBB0_65
LBB0_84:
	movq	%rbx, %rdi
	callq	_free
	movq	-135392(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-135384(%rbp), %rdi             ## 8-byte Reload
	jmp	LBB0_441
LBB0_85:
	movq	-135336(%rbp), %rcx             ## 8-byte Reload
	leaq	-4(%rcx), %rax
	cmpq	$3, %rax
	movq	-135416(%rbp), %r12             ## 8-byte Reload
	jb	LBB0_87
## %bb.86:
	cmpq	$1, %rcx
	jne	LBB0_499
LBB0_87:
	testq	%r13, %r13
	je	LBB0_94
## %bb.88:
	xorl	%eax, %eax
	jmp	LBB0_90
	.p2align	4
LBB0_89:                                ##   in Loop: Header=BB0_90 Depth=1
	incq	%rax
	cmpq	%r13, %rax
	je	LBB0_94
LBB0_90:                                ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_92 Depth 2
	testq	%rax, %rax
	je	LBB0_89
## %bb.91:                              ##   in Loop: Header=BB0_90 Depth=1
	leaq	(%rax,%rax,2), %rcx
	leaq	(%r15,%rcx,8), %rcx
	movq	%r15, %rdx
	movq	%rax, %rsi
	.p2align	4
LBB0_92:                                ##   Parent Loop BB0_90 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	LBB0_456
## %bb.93:                              ##   in Loop: Header=BB0_92 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	LBB0_92
	jmp	LBB0_89
LBB0_94:
	movq	$67108864, -135288(%rbp)        ## imm = 0x4000000
	movl	$67108864, %edi                 ## imm = 0x4000000
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_500
## %bb.95:
	movq	%rax, %rbx
	movq	%r13, -135400(%rbp)             ## 8-byte Spill
	movq	%r14, -135408(%rbp)             ## 8-byte Spill
	movq	%r15, -135392(%rbp)             ## 8-byte Spill
	movq	%rax, -135296(%rbp)
	leaq	-135280(%rbp), %rdi
	movl	$131072, %esi                   ## imm = 0x20000
	callq	___bzero
	movb	$1, %dil
	movq	-135336(%rbp), %rcx             ## 8-byte Reload
	cmpq	$3, %rcx
	jbe	LBB0_99
## %bb.96:
	movq	8(%r12), %r13
	movq	16(%r12), %r14
	movq	24(%r12), %r15
	cmpq	$4, %rcx
	jne	LBB0_410
## %bb.97:
	xorl	%r12d, %r12d
	jmp	LBB0_100
LBB0_98:
	xorl	%r14d, %r14d
	jmp	LBB0_150
LBB0_99:
	xorl	%r12d, %r12d
	xorl	%r15d, %r15d
	xorl	%r13d, %r13d
	xorl	%r14d, %r14d
LBB0_100:
	xorl	%r9d, %r9d
LBB0_101:
	testq	%r13, %r13
	setne	%al
	testq	%r14, %r14
	setne	%cl
	xorl	%edx, %edx
	movq	%r13, %rsi
	orq	%r14, %rsi
	sete	%dl
	andb	%al, %cl
	testq	%r15, %r15
	movzbl	%cl, %eax
	cmovel	%edx, %eax
	testb	%al, %al
	je	LBB0_501
## %bb.102:
	testq	%r9, %r9
	setne	%al
	orb	%dil, %al
	je	LBB0_502
## %bb.103:
	movq	%r9, -135456(%rbp)              ## 8-byte Spill
	movl	%edi, -135420(%rbp)             ## 4-byte Spill
	testq	%r13, %r13
	movq	%r12, -135344(%rbp)             ## 8-byte Spill
	je	LBB0_213
## %bb.104:
	movq	%r15, %r12
	movq	%r13, %rdi
	callq	_read_file
	cmpq	$512, %rdx                      ## imm = 0x200
	jne	LBB0_514
## %bb.105:
	movq	%rax, %r15
	movl	$512, %edx                      ## imm = 0x200
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_memcpy
	movq	%r15, %rdi
	callq	_free
	movq	%r14, %rdi
	callq	_read_file
	cmpq	$8193, %rdx                     ## imm = 0x2001
	jae	LBB0_515
## %bb.106:
	movq	%rax, %r14
	leaq	512(%rbx), %rdi
	movq	%rax, %rsi
	callq	_memcpy
	movq	%r14, %rdi
	callq	_free
	movq	%r12, %r15
	movq	%r12, %rdi
	callq	_read_file
	cmpq	$163841, %rdx                   ## imm = 0x28001
	jae	LBB0_517
## %bb.107:
	movq	%rax, %r14
	movq	%rbx, %rdi
	addq	$8704, %rdi                     ## imm = 0x2200
	movq	%rax, %rsi
	callq	_memcpy
	movq	%r14, %rdi
	callq	_free
	movq	-135344(%rbp), %r12             ## 8-byte Reload
	jmp	LBB0_214
LBB0_108:                               ##   in Loop: Header=BB0_111 Depth=1
	movl	$1, %eax
	movq	%rax, -135408(%rbp)             ## 8-byte Spill
LBB0_109:                               ##   in Loop: Header=BB0_111 Depth=1
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	.p2align	4
LBB0_110:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	cmpl	%edx, %r12d
	jge	LBB0_149
LBB0_111:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_145 Depth 2
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rbx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_126
## %bb.112:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.5(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_128
## %bb.113:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.6(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_130
## %bb.114:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.7(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_132
## %bb.115:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.8(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_134
## %bb.116:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.9(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_136
## %bb.117:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.10(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_108
## %bb.118:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.11(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_138
## %bb.119:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.12(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_139
## %bb.120:                             ##   in Loop: Header=BB0_111 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.13(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_470
## %bb.121:                             ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	cmpl	-135328(%rbp), %r12d            ## 4-byte Folded Reload
	jge	LBB0_470
## %bb.122:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rbx
	movq	$0, -4176(%rbp)
	movq	%rbx, %rdi
	leaq	-4176(%rbp), %rsi
	movl	$10, %edx
	callq	_strtol
	movq	-4176(%rbp), %rcx
	cmpq	%rbx, %rcx
	je	LBB0_519
## %bb.123:                             ##   in Loop: Header=BB0_111 Depth=1
	cmpb	$61, (%rcx)
	jne	LBB0_519
## %bb.124:                             ##   in Loop: Header=BB0_111 Depth=1
	cmpq	$6, %rax
	jae	LBB0_519
## %bb.125:                             ##   in Loop: Header=BB0_111 Depth=1
	incq	%rcx
	movq	%rcx, -135208(%rbp,%rax,8)
	jmp	LBB0_109
	.p2align	4
LBB0_126:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	cmpl	%edx, %r12d
	jge	LBB0_470
## %bb.127:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %r14
	jmp	LBB0_110
	.p2align	4
LBB0_128:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	cmpl	%edx, %r12d
	jge	LBB0_470
## %bb.129:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, -135288(%rbp)
	jmp	LBB0_110
LBB0_130:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	cmpl	%edx, %r12d
	jge	LBB0_470
## %bb.131:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, -135352(%rbp)             ## 8-byte Spill
	jmp	LBB0_110
LBB0_132:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	cmpl	%edx, %r12d
	jge	LBB0_470
## %bb.133:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, -135336(%rbp)             ## 8-byte Spill
	jmp	LBB0_110
LBB0_134:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	cmpl	%edx, %r12d
	jge	LBB0_470
## %bb.135:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, -135384(%rbp)             ## 8-byte Spill
	jmp	LBB0_110
LBB0_136:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	cmpl	%edx, %r12d
	jge	LBB0_470
## %bb.137:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, -135344(%rbp)             ## 8-byte Spill
	jmp	LBB0_110
LBB0_138:                               ##   in Loop: Header=BB0_111 Depth=1
	movl	$1, -135392(%rbp)               ## 4-byte Folded Spill
	jmp	LBB0_109
LBB0_139:                               ##   in Loop: Header=BB0_111 Depth=1
	incl	%r12d
	cmpl	-135328(%rbp), %r12d            ## 4-byte Folded Reload
	jge	LBB0_470
## %bb.140:                             ##   in Loop: Header=BB0_111 Depth=1
	movslq	%r12d, %rax
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	(%rcx,%rax,8), %rbx
	movq	$0, -4176(%rbp)
	movq	%rbx, %rdi
	leaq	-4176(%rbp), %rsi
	movl	$10, %edx
	callq	_strtol
	movq	-4176(%rbp), %rcx
	cmpq	%rbx, %rcx
	je	LBB0_529
## %bb.141:                             ##   in Loop: Header=BB0_111 Depth=1
	cmpb	$0, (%rcx)
	jne	LBB0_529
## %bb.142:                             ##   in Loop: Header=BB0_111 Depth=1
	cmpq	$5, %rax
	ja	LBB0_529
## %bb.143:                             ##   in Loop: Header=BB0_111 Depth=1
	testq	%r13, %r13
	movl	-135328(%rbp), %edx             ## 4-byte Reload
	je	LBB0_148
## %bb.144:                             ##   in Loop: Header=BB0_111 Depth=1
	xorl	%ecx, %ecx
	.p2align	4
LBB0_145:                               ##   Parent Loop BB0_111 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	cmpl	%eax, -135240(%rbp,%rcx,4)
	je	LBB0_110
## %bb.146:                             ##   in Loop: Header=BB0_145 Depth=2
	incq	%rcx
	cmpq	%rcx, %r13
	jne	LBB0_145
## %bb.147:                             ##   in Loop: Header=BB0_111 Depth=1
	cmpq	$6, %r13
	jae	LBB0_536
LBB0_148:                               ##   in Loop: Header=BB0_111 Depth=1
	movl	%eax, -135240(%rbp,%r13,4)
	incq	%r13
	jmp	LBB0_110
LBB0_149:
	movq	-135344(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135256(%rbp)
	movq	-135384(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135264(%rbp)
	movq	-135336(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135272(%rbp)
	movq	-135352(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135280(%rbp)
	movq	%r13, -135216(%rbp)
	movl	-135392(%rbp), %eax             ## 4-byte Reload
	movl	%eax, -135244(%rbp)
	movq	-135408(%rbp), %rax             ## 8-byte Reload
	movl	%eax, -135248(%rbp)
LBB0_150:
	movq	%r14, -135296(%rbp)
	movq	-135400(%rbp), %rbx             ## 8-byte Reload
	movq	%rbx, %rdi
	callq	_read_file
	movq	%rax, %r14
	movq	%rax, -80(%rbp)
	movq	%rdx, -72(%rbp)
	leaq	-80(%rbp), %rdi
	movq	%rbx, %rsi
	callq	_validate_image_layout
	pxor	%xmm0, %xmm0
	movdqa	%xmm0, -4208(%rbp)
	movdqa	%xmm0, -135376(%rbp)
	movq	-135296(%rbp), %rbx
	testq	%rbx, %rbx
	je	LBB0_152
## %bb.151:
	movq	%rbx, %rdi
	callq	_read_file
	movq	%rax, -135320(%rbp)             ## 8-byte Spill
	movq	%rax, -4208(%rbp)
	movq	%rdx, -4200(%rbp)
	leaq	-4208(%rbp), %rdi
	movq	%rbx, %rsi
	callq	_validate_image_layout
	jmp	LBB0_153
LBB0_152:
	movq	$0, -135320(%rbp)               ## 8-byte Folded Spill
LBB0_153:
	movq	-135288(%rbp), %rbx
	testq	%rbx, %rbx
	je	LBB0_155
## %bb.154:
	movq	%rbx, %rdi
	callq	_read_file
	movq	%rax, -135328(%rbp)             ## 8-byte Spill
	movq	%rax, -135376(%rbp)
	movq	%rdx, -135368(%rbp)
	leaq	-135376(%rbp), %rdi
	movq	%rbx, %rsi
	callq	_validate_image_layout
	jmp	LBB0_156
LBB0_155:
	movq	$0, -135328(%rbp)               ## 8-byte Folded Spill
LBB0_156:
	movl	-135248(%rbp), %ebx
	testl	%ebx, %ebx
	je	LBB0_166
## %bb.157:
	xorl	%eax, %eax
	movabsq	$2329570836308444484, %rcx      ## imm = 0x20544C5541464544
	movabsq	$5135866231194932545, %rdx      ## imm = 0x47464320544C5541
	jmp	LBB0_159
	.p2align	4
LBB0_158:                               ##   in Loop: Header=BB0_159 Depth=1
	addq	$32, %rax
	cmpq	$16384, %rax                    ## imm = 0x4000
	je	LBB0_459
LBB0_159:                               ## =>This Inner Loop Header: Depth=1
	movzbl	1311232(%r14,%rax), %esi
	cmpl	$229, %esi
	je	LBB0_158
## %bb.160:                             ##   in Loop: Header=BB0_159 Depth=1
	testl	%esi, %esi
	je	LBB0_459
## %bb.161:                             ##   in Loop: Header=BB0_159 Depth=1
	movq	1311232(%r14,%rax), %rsi
	xorq	%rcx, %rsi
	movq	1311235(%r14,%rax), %rdi
	xorq	%rdx, %rdi
	orq	%rsi, %rdi
	jne	LBB0_158
## %bb.162:
	testb	$16, 1311243(%r14,%rax)
	jne	LBB0_510
## %bb.163:
	cmpl	$0, 1311260(%r14,%rax)
	je	LBB0_511
## %bb.164:
	cmpq	$0, -135320(%rbp)               ## 8-byte Folded Reload
	je	LBB0_166
## %bb.165:
	leaq	_DEFAULT_CFG_NAME(%rip), %rdx
	leaq	-80(%rbp), %rdi
	leaq	-4208(%rbp), %rsi
	callq	_root_file_equal
	testl	%eax, %eax
	jne	LBB0_520
LBB0_166:
	movl	%ebx, -135336(%rbp)             ## 4-byte Spill
	movq	-135216(%rbp), %r12
	testq	%r12, %r12
	je	LBB0_187
## %bb.167:
	xorl	%r13d, %r13d
	leaq	-80(%rbp), %r15
	movq	%r12, -135352(%rbp)             ## 8-byte Spill
	.p2align	4
LBB0_168:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_171 Depth 2
	movslq	-135240(%rbp,%r13,4), %rax
	cmpq	$6, %rax
	jae	LBB0_466
## %bb.169:                             ##   in Loop: Header=BB0_168 Depth=1
	movq	-135208(%rbp,%rax,8), %rbx
	movabsq	$2330121683245944644, %rcx      ## imm = 0x205641534D4F4F44
	movq	%rcx, -4192(%rbp)
	movl	$1196639264, -4185(%rbp)        ## imm = 0x47534420
	orb	$48, %al
	movb	%al, -4185(%rbp)
	xorl	%eax, %eax
	jmp	LBB0_171
	.p2align	4
LBB0_170:                               ##   in Loop: Header=BB0_171 Depth=2
	addq	$32, %rax
	cmpq	$16384, %rax                    ## imm = 0x4000
	je	LBB0_455
LBB0_171:                               ##   Parent Loop BB0_168 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	1311232(%r14,%rax), %ecx
	cmpl	$229, %ecx
	je	LBB0_170
## %bb.172:                             ##   in Loop: Header=BB0_171 Depth=2
	testl	%ecx, %ecx
	je	LBB0_455
## %bb.173:                             ##   in Loop: Header=BB0_171 Depth=2
	movq	1311232(%r14,%rax), %rcx
	xorq	-4192(%rbp), %rcx
	movq	1311235(%r14,%rax), %rdx
	xorq	-4189(%rbp), %rdx
	orq	%rcx, %rdx
	jne	LBB0_170
## %bb.174:                             ##   in Loop: Header=BB0_168 Depth=1
	movzbl	1311243(%r14,%rax), %ecx
	movzwl	1311258(%r14,%rax), %edx
	movl	1311260(%r14,%rax), %eax
	movq	%rax, %rsi
	shlq	$32, %rsi
	orq	%rdx, %rsi
	movq	%rcx, %rdx
	shlq	$32, %rdx
	incq	%rdx
	movq	%rdx, -4176(%rbp)
	movq	%rsi, -4168(%rbp)
	testb	$16, %cl
	jne	LBB0_467
## %bb.175:                             ##   in Loop: Header=BB0_168 Depth=1
	cmpl	$63, %eax
	jbe	LBB0_468
## %bb.176:                             ##   in Loop: Header=BB0_168 Depth=1
	cmpq	$0, -135320(%rbp)               ## 8-byte Folded Reload
	je	LBB0_178
## %bb.177:                             ##   in Loop: Header=BB0_168 Depth=1
	movq	%r15, %rdi
	leaq	-4208(%rbp), %rsi
	leaq	-4192(%rbp), %rdx
	callq	_root_file_equal
	testl	%eax, %eax
	jne	LBB0_473
LBB0_178:                               ##   in Loop: Header=BB0_168 Depth=1
	cmpq	$0, -135328(%rbp)               ## 8-byte Folded Reload
	je	LBB0_180
## %bb.179:                             ##   in Loop: Header=BB0_168 Depth=1
	movq	%r15, %rdi
	leaq	-135376(%rbp), %rsi
	leaq	-4192(%rbp), %rdx
	callq	_root_file_equal
	testl	%eax, %eax
	je	LBB0_472
LBB0_180:                               ##   in Loop: Header=BB0_168 Depth=1
	movq	%r15, %rdi
	leaq	-4176(%rbp), %rsi
	leaq	L_.str.75(%rip), %rdx
	callq	_read_root_file_blob
	movq	%rax, %r15
	movq	%rdx, %r12
	testq	%rbx, %rbx
	je	LBB0_184
## %bb.181:                             ##   in Loop: Header=BB0_168 Depth=1
	movq	%rbx, %rdi
	callq	_strlen
	cmpq	$25, %rax
	jae	LBB0_474
## %bb.182:                             ##   in Loop: Header=BB0_168 Depth=1
	cmpq	$24, %r12
	jb	LBB0_464
## %bb.183:                             ##   in Loop: Header=BB0_168 Depth=1
	movq	%r15, %rdi
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	_memcmp
	testl	%eax, %eax
	jne	LBB0_464
LBB0_184:                               ##   in Loop: Header=BB0_168 Depth=1
	cmpq	$40, %r12
	jb	LBB0_461
## %bb.185:                             ##   in Loop: Header=BB0_168 Depth=1
	movabsq	$2336927755350992246, %rax      ## imm = 0x206E6F6973726576
	cmpq	%rax, 24(%r15)
	jne	LBB0_461
## %bb.186:                             ##   in Loop: Header=BB0_168 Depth=1
	movq	%r15, %rdi
	callq	_free
	incq	%r13
	movq	-135352(%rbp), %r12             ## 8-byte Reload
	cmpq	%r12, %r13
	leaq	-80(%rbp), %r15
	jne	LBB0_168
LBB0_187:
	movq	-135280(%rbp), %r15
	movq	%r15, %rdi
	xorl	%esi, %esi
	callq	_check_write_status
	movq	-135272(%rbp), %rdi
	movq	%rdi, -135384(%rbp)             ## 8-byte Spill
	movl	$1, %esi
	callq	_check_write_status
	movq	-135264(%rbp), %rdi
	testq	%rdi, %rdi
	je	LBB0_424
## %bb.188:
	movq	%rdi, -135344(%rbp)             ## 8-byte Spill
	callq	_read_file
	movq	-135344(%rbp), %rdi             ## 8-byte Reload
	movq	%rax, -4176(%rbp)
	movq	%rdx, -4168(%rbp)
	testq	%rax, %rax
	je	LBB0_424
## %bb.189:
	movq	%rdx, %rbx
	cmpq	$11, %rdx
	jb	LBB0_193
## %bb.190:
	movq	%rax, %r13
	movabsq	$8746391181324018023, %rax      ## imm = 0x79616C70656D6167
	movl	$11, %ecx
	movabsq	$5426623667539570789, %rdx      ## imm = 0x4B4F3D79616C7065
	.p2align	4
LBB0_191:                               ## =>This Inner Loop Header: Depth=1
	movq	-11(%r13,%rcx), %rsi
	xorq	%rax, %rsi
	movq	-8(%r13,%rcx), %r8
	xorq	%rdx, %r8
	orq	%rsi, %r8
	je	LBB0_194
## %bb.192:                             ##   in Loop: Header=BB0_191 Depth=1
	incq	%rcx
	cmpq	%rbx, %rcx
	jbe	LBB0_191
LBB0_193:
	leaq	L_.str.94(%rip), %rsi
	callq	_die_path
LBB0_194:
	movl	$1702257011, %ecx               ## imm = 0x65766173
	movl	(%r13), %eax
	xorl	%ecx, %eax
	movzwl	4(%r13), %edx
	xorl	$25714, %edx                    ## imm = 0x6472
	orl	%eax, %edx
	jne	LBB0_196
## %bb.195:
	cmpb	$61, 6(%r13)
	movq	%r13, %rax
	je	LBB0_203
LBB0_196:
	leaq	-7(%rbx), %rdx
	xorl	%eax, %eax
	movabsq	$4294976512, %rsi               ## imm = 0x100002400
	jmp	LBB0_198
	.p2align	4
LBB0_197:                               ##   in Loop: Header=BB0_198 Depth=1
	incq	%rax
	cmpq	%rax, %rdx
	je	LBB0_462
LBB0_198:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r13,%rax), %edi
	cmpq	$32, %rdi
	ja	LBB0_197
## %bb.199:                             ##   in Loop: Header=BB0_198 Depth=1
	btq	%rdi, %rsi
	jae	LBB0_197
## %bb.200:                             ##   in Loop: Header=BB0_198 Depth=1
	movl	1(%r13,%rax), %edi
	xorl	%ecx, %edi
	movzwl	5(%r13,%rax), %r8d
	xorl	$25714, %r8d                    ## imm = 0x6472
	orl	%edi, %r8d
	jne	LBB0_197
## %bb.201:                             ##   in Loop: Header=BB0_198 Depth=1
	cmpb	$61, 7(%r13,%rax)
	jne	LBB0_197
## %bb.202:
	addq	%r13, %rax
	incq	%rax
LBB0_203:
	movzbl	7(%rax), %edi
	testb	%dil, %dil
	je	LBB0_513
## %bb.204:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB0_205:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB0_207
## %bb.206:                             ##   in Loop: Header=BB0_205 Depth=1
	addl	$-48, %esi
	jmp	LBB0_211
	.p2align	4
LBB0_207:                               ##   in Loop: Header=BB0_205 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB0_209
## %bb.208:                             ##   in Loop: Header=BB0_205 Depth=1
	addl	$-87, %esi
	jmp	LBB0_211
	.p2align	4
LBB0_209:                               ##   in Loop: Header=BB0_205 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB0_417
## %bb.210:                             ##   in Loop: Header=BB0_205 Depth=1
	addl	$-55, %esi
LBB0_211:                               ##   in Loop: Header=BB0_205 Depth=1
	testl	%esi, %esi
	js	LBB0_417
## %bb.212:                             ##   in Loop: Header=BB0_205 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	8(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB0_205
	jmp	LBB0_418
LBB0_213:
	movw	$15595, (%rbx)                  ## imm = 0x3CEB
	movb	$-112, 2(%rbx)
LBB0_214:
	movl	$1146310486, 440(%rbx)          ## imm = 0x44534F56
	movaps	LCPI0_0(%rip), %xmm0            ## xmm0 = [128,1,1,0,6,254,255,255,0,8,0,0,0,248,1,0]
	movups	%xmm0, 446(%rbx)
	movw	$-21931, 510(%rbx)              ## imm = 0xAA55
	movw	$15595, 1048576(%rbx)           ## imm = 0x3CEB
	movb	$-112, 1048578(%rbx)
	movabsq	$2314941808397928790, %rax      ## imm = 0x2020534F45424956
	movq	%rax, 1048579(%rbx)
	movdqa	LCPI0_1(%rip), %xmm0            ## xmm0 = [0,2,2,1,0,2,0,2,0,0,248,0,1,63,0,16]
	movdqu	%xmm0, 1048587(%rbx)
	movabsq	$141863388262694912, %rax       ## imm = 0x1F8000000080000
	movq	%rax, 1048603(%rbx)
	movw	$-32768, 1048611(%rbx)          ## imm = 0x8000
	movl	$218104105, 1048614(%rbx)       ## imm = 0xD000129
	movb	$-48, 1048618(%rbx)
	movabsq	$6278109480483965270, %rax      ## imm = 0x5720534F45424956
	movq	%rax, 1048619(%rbx)
	movl	$541344087, 1048626(%rbx)       ## imm = 0x20444157
	movabsq	$2314885625596363078, %rax      ## imm = 0x2020203631544146
	movq	%rax, 1048630(%rbx)
	movw	$-21931, 1049086(%rbx)          ## imm = 0xAA55
	movq	-135352(%rbp), %r14             ## 8-byte Reload
	testq	%r14, %r14
	je	LBB0_221
## %bb.215:
	movq	%r14, %rdi
	callq	_read_file
	cmpq	$5242881, %rdx                  ## imm = 0x500001
	jae	LBB0_516
## %bb.216:
	cmpq	$11, %rdx
	jbe	LBB0_518
## %bb.217:
	movq	%rax, %rbx
	cmpl	$1145132873, (%rax)             ## imm = 0x44415749
	je	LBB0_219
## %bb.218:
	cmpl	$1145132880, (%rbx)             ## imm = 0x44415750
	jne	LBB0_521
LBB0_219:
	movl	4(%rbx), %eax
	movl	8(%rbx), %ecx
	shlq	$4, %rax
	addq	%rcx, %rax
	cmpq	%rdx, %rax
	jbe	LBB0_266
## %bb.220:
	leaq	L_.str.146(%rip), %rsi
	movq	%r14, %rdi
	callq	_die_path
LBB0_221:
	movl	$1048576, %edi                  ## imm = 0x100000
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_522
## %bb.222:
	movq	%rax, %rbx
	movq	$0, -135376(%rbp)
	movq	$0, -4192(%rbp)
	movq	$0, -135312(%rbp)
	movl	$12, -135300(%rbp)
	movl	$18, %edi
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_523
## %bb.223:
	movq	%rax, %r14
	movb	$1, (%rax)
	movb	$1, 2(%rax)
	movb	$12, 8(%rax)
	movb	$1, 13(%rax)
	movb	$-1, 17(%rax)
	movl	$12, %edi
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_524
## %bb.224:
	movq	%r14, -135328(%rbp)             ## 8-byte Spill
	movq	%rbx, -135320(%rbp)             ## 8-byte Spill
	movq	%r15, -135448(%rbp)             ## 8-byte Spill
	movb	$1, (%rax)
	movabsq	$5207093865752713555, %rcx      ## imm = 0x48435048544E5953
	movq	%rax, -135432(%rbp)             ## 8-byte Spill
	movq	%rcx, 4(%rax)
	movl	$1516, %edi                     ## imm = 0x5EC
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_525
## %bb.225:
	movb	$42, (%rax)
	movq	%rax, -135352(%rbp)             ## 8-byte Spill
	addq	$172, %rax
	movq	%rax, -135336(%rbp)             ## 8-byte Spill
	leaq	_switch_textures(%rip), %r14
	movl	$7, %edx
	xorl	%r15d, %r15d
	movq	-135336(%rbp), %r13             ## 8-byte Reload
	.p2align	4
LBB0_226:                               ## =>This Inner Loop Header: Depth=1
	leaq	172(%r15), %rax
	movq	-135352(%rbp), %rcx             ## 8-byte Reload
	movb	%al, -3(%rcx,%rdx)
	movb	%ah, -2(%rcx,%rdx)
	movq	%rdx, %r12
	movw	$0, -1(%rcx,%rdx)
	movq	(%r14), %rbx
	movq	$0, 172(%rcx,%r15)
	movq	%rbx, %rdi
	callq	_strlen
	cmpq	$9, %rax
	jae	LBB0_476
## %bb.227:                             ##   in Loop: Header=BB0_226 Depth=1
	leaq	(%r15,%r13), %rdi
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	_memcpy
	movl	$65537, 12(%r13,%r15)           ## imm = 0x10001
	movw	$1, 20(%r13,%r15)
	addq	$32, %r15
	addq	$8, %r14
	movq	%r12, %rdx
	addq	$4, %rdx
	cmpq	$1344, %r15                     ## imm = 0x540
	jne	LBB0_226
## %bb.228:
	movl	$10752, %edi                    ## imm = 0x2A00
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_526
## %bb.229:
	movq	%rax, %rbx
	movl	$8704, %edi                     ## imm = 0x2200
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_527
## %bb.230:
	movq	%rax, %r14
	leaq	-4176(%rbp), %rdi
	movl	$4096, %esi                     ## imm = 0x1000
	callq	___bzero
	movw	$0, -4200(%rbp)
	movq	$0, -4208(%rbp)
	movdqa	LCPI0_2(%rip), %xmm4            ## xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$80, %eax
	movdqa	LCPI0_3(%rip), %xmm0            ## xmm0 = [16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16]
	movdqa	LCPI0_4(%rip), %xmm5            ## xmm5 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
	movdqa	LCPI0_5(%rip), %xmm1            ## xmm1 = [48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48]
	movdqa	LCPI0_6(%rip), %xmm2            ## xmm2 = [32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32]
	movdqa	LCPI0_7(%rip), %xmm3            ## xmm3 = [96,96,96,96,96,96,96,96,96,96,96,96,96,96,96,96]
	.p2align	4
LBB0_231:                               ## =>This Inner Loop Header: Depth=1
	movdqa	%xmm4, %xmm6
	paddb	%xmm0, %xmm6
	movdqa	%xmm4, %xmm7
	pand	%xmm5, %xmm7
	pand	%xmm5, %xmm6
	movdqu	%xmm7, -80(%rbx,%rax)
	movdqu	%xmm6, -64(%rbx,%rax)
	movdqa	%xmm4, %xmm8
	paddb	%xmm1, %xmm8
	movdqa	%xmm7, %xmm9
	pxor	%xmm2, %xmm9
	pand	%xmm5, %xmm8
	movdqu	%xmm9, -48(%rbx,%rax)
	movdqu	%xmm8, -32(%rbx,%rax)
	movdqu	%xmm7, -16(%rbx,%rax)
	movdqu	%xmm6, (%rbx,%rax)
	paddb	%xmm3, %xmm4
	addq	$96, %rax
	cmpq	$10832, %rax                    ## imm = 0x2A50
	jne	LBB0_231
## %bb.232:
	movq	%rbx, -135336(%rbp)             ## 8-byte Spill
	movdqa	LCPI0_2(%rip), %xmm4            ## xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$112, %eax
	movdqa	LCPI0_8(%rip), %xmm5            ## xmm5 = [64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64]
	movdqa	LCPI0_9(%rip), %xmm6            ## xmm6 = [80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80]
	movdqa	LCPI0_10(%rip), %xmm7           ## xmm7 = [112,112,112,112,112,112,112,112,112,112,112,112,112,112,112,112]
	movdqa	LCPI0_11(%rip), %xmm8           ## xmm8 = [128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128]
	.p2align	4
LBB0_233:                               ## =>This Inner Loop Header: Depth=1
	movdqa	%xmm4, %xmm9
	paddb	%xmm0, %xmm9
	movdqu	%xmm4, -112(%r14,%rax)
	movdqu	%xmm9, -96(%r14,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm2, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm1, %xmm10
	movdqu	%xmm9, -80(%r14,%rax)
	movdqu	%xmm10, -64(%r14,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm5, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm6, %xmm10
	movdqu	%xmm9, -48(%r14,%rax)
	movdqu	%xmm10, -32(%r14,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm3, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm7, %xmm10
	movdqu	%xmm9, -16(%r14,%rax)
	movdqu	%xmm10, (%r14,%rax)
	pxor	%xmm8, %xmm4
	subq	$-128, %rax
	cmpq	$8816, %rax                     ## imm = 0x2270
	jne	LBB0_233
## %bb.234:
	leaq	L_.str.147(%rip), %r9
	leaq	-135376(%rbp), %r15
	leaq	-4192(%rbp), %r13
	leaq	-135312(%rbp), %rdx
	leaq	-135300(%rbp), %rbx
	movq	%r15, %rdi
	movq	%r13, %rsi
	movq	-135320(%rbp), %r12             ## 8-byte Reload
	movq	%r12, %rcx
	movq	%rbx, %r8
	pushq	$10752                          ## imm = 0x2A00
	pushq	-135336(%rbp)                   ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.148(%rip), %r9
	movq	%r15, %rdi
	movq	%r13, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%r12, %rcx
	movq	%rbx, %r8
	pushq	$8704                           ## imm = 0x2200
	movq	%r14, -135440(%rbp)             ## 8-byte Spill
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.149(%rip), %r9
	movq	%r15, %rdi
	movq	%r13, %rsi
	movq	%r13, %r14
	leaq	-135312(%rbp), %rdx
	movq	%rdx, %r13
	movq	%r12, %rcx
	movq	%rbx, %r8
	pushq	$12
	pushq	-135432(%rbp)                   ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.150(%rip), %r9
	movq	%r15, %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%r12, %rcx
	movq	%rbx, %r8
	pushq	$1516                           ## imm = 0x5EC
	pushq	-135352(%rbp)                   ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	movq	-4192(%rbp), %rbx
	movq	-135376(%rbp), %rax
	cmpq	-135312(%rbp), %rbx
	jne	LBB0_237
## %bb.235:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -135312(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_530
## %bb.236:
	movq	%rax, -135376(%rbp)
LBB0_237:
	leaq	-4176(%rbp), %r10
	leaq	1(%rbx), %rcx
	movq	%rcx, -4192(%rbp)
	shlq	$4, %rbx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rbx)
	movl	$1414750022, 8(%rax,%rbx)       ## imm = 0x54535F46
	movl	$1414676820, 11(%rax,%rbx)      ## imm = 0x54524154
	leaq	L_.str.152(%rip), %r9
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	leaq	-135312(%rbp), %rdx
	leaq	-135300(%rbp), %r8
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	pushq	$4096                           ## imm = 0x1000
	pushq	%r10
	callq	_add_lump
	addq	$16, %rsp
	movq	-4192(%rbp), %rbx
	movq	-135312(%rbp), %r14
	movq	-135376(%rbp), %rax
	cmpq	%r14, %rbx
	jne	LBB0_240
## %bb.238:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %r14d
	cmovneq	%rcx, %r14
	movq	%r14, -135312(%rbp)
	movq	%r14, %rsi
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_531
## %bb.239:
	movq	%rax, -135376(%rbp)
LBB0_240:
	pxor	%xmm0, %xmm0
	leaq	1(%rbx), %r15
	movq	%r15, -4192(%rbp)
	movq	%rbx, %rcx
	shlq	$4, %rcx
	movdqu	%xmm0, (%rax,%rcx)
	movl	$1313169222, 8(%rax,%rcx)       ## imm = 0x4E455F46
	movb	$68, 12(%rax,%rcx)
	cmpq	%r14, %r15
	jne	LBB0_243
## %bb.241:
	leaq	(%r14,%r14), %rcx
	testq	%r14, %r14
	movl	$128, %r14d
	cmovneq	%rcx, %r14
	movq	%r14, -135312(%rbp)
	movq	%r14, %rsi
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_532
## %bb.242:
	movq	%rax, -135376(%rbp)
LBB0_243:
	leaq	2(%rbx), %r12
	shlq	$4, %r15
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%r15)
	movl	$1414750035, 8(%rax,%r15)       ## imm = 0x54535F53
	movl	$1414676820, 11(%rax,%r15)      ## imm = 0x54524154
	cmpq	%r14, %r12
	jne	LBB0_246
## %bb.244:
	leaq	(%r14,%r14), %rcx
	testq	%r14, %r14
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -135312(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_533
## %bb.245:
	movq	%rax, -135376(%rbp)
	pxor	%xmm0, %xmm0
LBB0_246:
	addq	$3, %rbx
	movq	%rbx, -4192(%rbp)
	shlq	$4, %r12
	movdqu	%xmm0, (%rax,%r12)
	movl	$1313169235, 8(%rax,%r12)       ## imm = 0x4E455F53
	movb	$68, 12(%rax,%r12)
	leaq	L_.str.156(%rip), %r9
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	leaq	-135312(%rbp), %rdx
	leaq	-135300(%rbp), %r8
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	pushq	$18
	pushq	-135328(%rbp)                   ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	movq	-4192(%rbp), %rbx
	movq	-135312(%rbp), %r14
	movq	-135376(%rbp), %rax
	cmpq	%r14, %rbx
	jne	LBB0_249
## %bb.247:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %r14d
	cmovneq	%rcx, %r14
	movq	%r14, -135312(%rbp)
	movq	%r14, %rsi
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_534
## %bb.248:
	movq	%rax, -135376(%rbp)
LBB0_249:
	leaq	1(%rbx), %r15
	movq	%rbx, %rcx
	shlq	$4, %rcx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movl	$1313431364, 8(%rax,%rcx)       ## imm = 0x4E495F44
	movl	$1330795598, 11(%rax,%rcx)      ## imm = 0x4F52544E
	cmpq	%r14, %r15
	jne	LBB0_252
## %bb.250:
	leaq	(%r14,%r14), %rcx
	testq	%r14, %r14
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -135312(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_535
## %bb.251:
	movq	%rax, -135376(%rbp)
	pxor	%xmm0, %xmm0
LBB0_252:
	addq	$2, %rbx
	movq	%rbx, -4192(%rbp)
	shlq	$4, %r15
	movdqu	%xmm0, (%rax,%r15)
	movl	$827142469, 8(%rax,%r15)        ## imm = 0x314D3145
	leaq	-4208(%rbp), %rax
	leaq	L_.str.159(%rip), %r9
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	leaq	-135312(%rbp), %rdx
	leaq	-135300(%rbp), %r8
	movq	-135320(%rbp), %rcx             ## 8-byte Reload
	movq	%rcx, %r13
	pushq	$10
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	movl	$33, %ebx
	leaq	L_.str.205(%rip), %r14
	leaq	-80(%rbp), %r15
	movq	-135328(%rbp), %r12             ## 8-byte Reload
	.p2align	4
LBB0_253:                               ## =>This Inner Loop Header: Depth=1
	movl	$16, %esi
	movq	%r15, %rdi
	movq	%r14, %rdx
	movl	%ebx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	leaq	-135312(%rbp), %rdx
	movq	%r13, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	incl	%ebx
	cmpl	$96, %ebx
	jne	LBB0_253
## %bb.254:
	leaq	L_.str.206(%rip), %r14
	leaq	-80(%rbp), %r15
	movl	$16, %esi
	movq	%r15, %rdi
	movq	%r14, %rdx
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	leaq	-135312(%rbp), %rdx
	leaq	-135300(%rbp), %r8
	movq	%r13, %rbx
	movq	%r13, %rcx
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	movq	%r14, %rdx
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %r13
	movq	%r13, %rdi
	leaq	-4192(%rbp), %r14
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.206(%rip), %rdx
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%r15, %rdi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	movq	%r14, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rdx, %r13
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.207(%rip), %rdx
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.208(%rip), %r9
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.209(%rip), %rdx
	movl	$16, %esi
	movq	%r15, %rdi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.209(%rip), %rdx
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.209(%rip), %rdx
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.209(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.209(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.209(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.210(%rip), %r9
	leaq	-135376(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.211(%rip), %rdx
	movl	$16, %esi
	movq	%r15, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%rdi, %r14
	leaq	-4192(%rbp), %rsi
	movq	%rsi, %r13
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.211(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r14, %rdi
	movq	%r13, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rdx, %r14
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.211(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r14, %rdx
	movq	%r14, %r13
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r8, %r14
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.211(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.211(%rip), %rdx
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%rdi, %r14
	leaq	-4192(%rbp), %rsi
	movq	%rsi, %r13
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r15, %rdi
	leaq	L_.str.211(%rip), %rdx
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r14, %rdi
	movq	%r13, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.212(%rip), %r9
	movq	%r14, %rdi
	movq	%r13, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rdx, %r15
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.213(%rip), %r9
	movq	%r14, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-135300(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	xorl	%r14d, %r14d
	movq	-135320(%rbp), %r15             ## 8-byte Reload
	movq	-135328(%rbp), %r12             ## 8-byte Reload
	.p2align	4
LBB0_255:                               ## =>This Inner Loop Header: Depth=1
	movl	$16, %esi
	leaq	-80(%rbp), %rbx
	movq	%rbx, %rdi
	leaq	L_.str.214(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%r8d, %r8d
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	leaq	-135312(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-135300(%rbp), %r13
	movq	%r13, %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.214(%rip), %rdx
	movl	%r14d, %ecx
	movl	$1, %r8d
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	leaq	-135312(%rbp), %rdx
	movq	%r15, %rcx
	movq	%r13, %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.214(%rip), %rdx
	movl	%r14d, %ecx
	movl	$2, %r8d
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	movq	%rsi, %r13
	leaq	-135312(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-135300(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.215(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	movq	%r13, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rdx, %r13
	movq	%r15, %rcx
	leaq	-135300(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.216(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	movq	%r13, %rdx
	movq	%r15, %rcx
	leaq	-135300(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.217(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	movq	%r13, %rdx
	movq	%r15, %rcx
	leaq	-135300(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.218(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	movq	%r13, %rdx
	movq	%r15, %rcx
	leaq	-135300(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.219(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-135376(%rbp), %rdi
	leaq	-4192(%rbp), %rsi
	movq	%r13, %rdx
	movq	%r15, %rcx
	leaq	-135300(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	incl	%r14d
	cmpl	$5, %r14d
	jne	LBB0_255
## %bb.256:
	leaq	L_.str.220(%rip), %r9
	leaq	-135376(%rbp), %r13
	leaq	-4192(%rbp), %r15
	leaq	-135312(%rbp), %rdx
	leaq	-135300(%rbp), %r14
	movq	%r13, %rdi
	movq	%r15, %rsi
	movq	-135320(%rbp), %rbx             ## 8-byte Reload
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	movq	-135328(%rbp), %r12             ## 8-byte Reload
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.221(%rip), %r9
	movq	%r13, %rdi
	movq	%r15, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.222(%rip), %r9
	movq	%r13, %rdi
	movq	%r15, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.223(%rip), %r9
	movq	%r13, %rdi
	movq	%r15, %rsi
	leaq	-135312(%rbp), %rdx
	movq	%rdx, %r15
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.224(%rip), %r9
	movq	%r13, %rdi
	leaq	-4192(%rbp), %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	-135300(%rbp), %eax
	movq	-4192(%rbp), %rdx
	movq	%rdx, %rcx
	shlq	$4, %rcx
	leaq	(%rcx,%rax), %r14
	cmpq	$1048576, %r14                  ## imm = 0x100000
	ja	LBB0_528
## %bb.257:
	testq	%rdx, %rdx
	je	LBB0_262
## %bb.258:
	movq	-135376(%rbp), %rsi
	addq	$8, %rsi
	movq	%rax, %rdi
	movq	%rdx, %r8
	.p2align	4
LBB0_259:                               ## =>This Inner Loop Header: Depth=1
	cmpq	$1048573, %rdi                  ## imm = 0xFFFFD
	jae	LBB0_484
## %bb.260:                             ##   in Loop: Header=BB0_259 Depth=1
	movl	-8(%rsi), %r9d
	movl	%r9d, (%rbx,%rdi)
	leaq	-1048569(%rdi), %r9
	cmpq	$-1048578, %r9                  ## imm = 0xFFEFFFFE
	jbe	LBB0_485
## %bb.261:                             ##   in Loop: Header=BB0_259 Depth=1
	movl	-4(%rsi), %r9d
	movl	%r9d, 4(%rbx,%rdi)
	movq	(%rsi), %r9
	movq	%r9, 8(%rbx,%rdi)
	addq	$16, %rsi
	addq	$16, %rdi
	decq	%r8
	jne	LBB0_259
LBB0_262:
	movl	$1145132873, (%rbx)             ## imm = 0x44415749
	movb	%dl, 4(%rbx)
	movb	%dh, 5(%rbx)
	movl	%edx, %esi
	shrl	$16, %esi
	movb	%sil, 6(%rbx)
	shrl	$24, %edx
	movb	%dl, 7(%rbx)
	movb	%al, 8(%rbx)
	movb	%ah, 9(%rbx)
	movl	%eax, %edx
	shrl	$16, %edx
	movb	%dl, 10(%rbx)
	movl	%eax, %edx
	shrl	$24, %edx
	movb	%dl, 11(%rbx)
	cmpq	$1048576, %r14                  ## imm = 0x100000
	movq	%rbx, %r13
	je	LBB0_265
## %bb.263:
	addq	%rax, %rcx
	movl	$40, %r15d
	subq	%rcx, %r15
	leaq	L___const.build_generated_wad.pattern(%rip), %rbx
	.p2align	4
LBB0_264:                               ## =>This Inner Loop Header: Depth=1
	leaq	40(%r14), %r12
	cmpq	$1048536, %r14                  ## imm = 0xFFFD8
	movl	$1048536, %edx                  ## imm = 0xFFFD8
	cmovbq	%r14, %rdx
	addq	%r15, %rdx
	leaq	(%r14,%r13), %rdi
	movq	%rbx, %rsi
	callq	_memcpy
	addq	$-40, %r15
	cmpq	$1048536, %r14                  ## imm = 0xFFFD8
	movq	%r12, %r14
	jb	LBB0_264
LBB0_265:
	movq	-135376(%rbp), %rdi
	callq	_free
	movq	-135328(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-135432(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-135352(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-135336(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-135440(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movl	$1048576, %edx                  ## imm = 0x100000
	movq	-135344(%rbp), %r12             ## 8-byte Reload
	movq	-135448(%rbp), %r15             ## 8-byte Reload
	movq	%r13, %rbx
LBB0_266:
	movl	$0, -135376(%rbp)
	leaq	-135296(%rbp), %rdi
	leaq	-135376(%rbp), %rcx
	movq	%rbx, %rsi
	movq	%rdx, %r14
	callq	_write_cluster_chain
	cmpl	$2, %eax
	jne	LBB0_503
## %bb.267:
	movq	-135296(%rbp), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  ## imm = 0x140260
	xorl	%esi, %esi
                                        ## implicit-def: $ecx
LBB0_268:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_270
## %bb.269:                             ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	jne	LBB0_271
LBB0_270:                               ##   in Loop: Header=BB0_268 Depth=1
	movl	%esi, %ecx
LBB0_271:                               ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	je	LBB0_290
## %bb.272:                             ##   in Loop: Header=BB0_268 Depth=1
	cmpl	$229, %edi
	je	LBB0_290
## %bb.273:                             ##   in Loop: Header=BB0_268 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_275
## %bb.274:                             ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	jne	LBB0_276
LBB0_275:                               ##   in Loop: Header=BB0_268 Depth=1
	leaq	1(%rsi), %rcx
LBB0_276:                               ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	je	LBB0_290
## %bb.277:                             ##   in Loop: Header=BB0_268 Depth=1
	cmpl	$229, %edi
	je	LBB0_290
## %bb.278:                             ##   in Loop: Header=BB0_268 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_280
## %bb.279:                             ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	jne	LBB0_281
LBB0_280:                               ##   in Loop: Header=BB0_268 Depth=1
	leaq	2(%rsi), %rcx
LBB0_281:                               ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	je	LBB0_290
## %bb.282:                             ##   in Loop: Header=BB0_268 Depth=1
	cmpl	$229, %edi
	je	LBB0_290
## %bb.283:                             ##   in Loop: Header=BB0_268 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_285
## %bb.284:                             ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	jne	LBB0_286
LBB0_285:                               ##   in Loop: Header=BB0_268 Depth=1
	leaq	3(%rsi), %rcx
LBB0_286:                               ##   in Loop: Header=BB0_268 Depth=1
	testl	%edi, %edi
	je	LBB0_290
## %bb.287:                             ##   in Loop: Header=BB0_268 Depth=1
	cmpl	$229, %edi
	je	LBB0_290
## %bb.288:                             ##   in Loop: Header=BB0_268 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      ## imm = 0x200
	jne	LBB0_268
## %bb.289:
	callq	_main.cold.37
LBB0_290:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB0_504
## %bb.291:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movdqu	%xmm0, 16(%rax,%rcx)
	movabsq	$2314885604590964548, %rdx      ## imm = 0x202020314D4F4F44
	movq	%rdx, (%rax,%rcx)
	movl	$1145132832, 7(%rax,%rcx)       ## imm = 0x44415720
	movb	$32, 11(%rax,%rcx)
	movw	$2, 26(%rax,%rcx)
	movq	%r14, %rdx
	movb	%dl, 28(%rax,%rcx)
	movb	%dh, 29(%rax,%rcx)
	shrl	$16, %edx
	movb	%dl, 30(%rax,%rcx)
	movb	$0, 31(%rax,%rcx)
	movq	%rbx, %rdi
	callq	_free
	testq	%r15, %r15
	je	LBB0_293
## %bb.292:
	movq	%r15, %rdi
	callq	_read_file
	movq	%rax, %rbx
	movq	%rdx, %r8
	leaq	_KERNEL_ELF_NAME(%rip), %rsi
	leaq	-135296(%rbp), %rdi
	movl	$1, %edx
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	_write_file_path
	movq	%rbx, %rdi
	callq	_free
LBB0_293:
	movq	-135456(%rbp), %rdi             ## 8-byte Reload
	testq	%rdi, %rdi
	je	LBB0_296
## %bb.294:
	callq	_read_file
	movq	%rax, %rbx
	movq	%rdx, %r8
	leaq	_USER_PROBE_NAME(%rip), %rsi
	leaq	-135296(%rbp), %rdi
	movl	$1, %edx
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	_write_file_path
	movq	%rbx, %rdi
	callq	_free
	cmpb	$0, -135420(%rbp)               ## 1-byte Folded Reload
	jne	LBB0_296
## %bb.295:
	movq	%r12, %rdi
	callq	_read_file
	movq	%rax, %rbx
	movq	%rdx, %r8
	leaq	_LEGACY_APP_ELF_NAME(%rip), %rsi
	leaq	-135296(%rbp), %rdi
	movl	$1, %edx
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	_write_file_path
	movq	%rbx, %rdi
	callq	_free
LBB0_296:
	movq	-135400(%rbp), %r13             ## 8-byte Reload
	testq	%r13, %r13
	je	LBB0_299
## %bb.297:
	movq	-135392(%rbp), %rax             ## 8-byte Reload
	leaq	16(%rax), %r12
	leaq	-135296(%rbp), %rbx
	leaq	-4176(%rbp), %r14
	.p2align	4
LBB0_298:                               ## =>This Inner Loop Header: Depth=1
	movq	(%r12), %rdi
	callq	_read_file
	movq	%rax, %r15
	movq	%rdx, %r8
	movl	-9(%r12), %eax
	movl	%eax, -4169(%rbp)
	movq	-16(%r12), %rax
	movq	%rax, -4176(%rbp)
	movl	$1, %edx
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r15, %rcx
	movl	$32, %r9d
	callq	_write_file_path
	movq	%r15, %rdi
	callq	_free
	addq	$24, %r12
	decq	%r13
	jne	LBB0_298
LBB0_299:
	movq	$0, -4208(%rbp)
	leaq	_STATE_DIR_NAME(%rip), %rdx
	leaq	-135296(%rbp), %rbx
	xorl	%r15d, %r15d
	movq	%rbx, %rdi
	xorl	%esi, %esi
	movl	$16, %ecx
	callq	_ensure_child_directory
	leaq	L_.str.226(%rip), %rdi
	leaq	-4176(%rbp), %r14
	leaq	-4208(%rbp), %r12
	movl	$4, %ecx
	movq	%r14, %rsi
	movq	%r12, %rdx
	callq	_parse_path83
	movq	-4208(%rbp), %rdx
	leaq	_package_default_assets.readme(%rip), %rcx
	movl	$35, %r8d
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movl	$33, %r9d
	callq	_write_file_path
	leaq	L_.str.227(%rip), %rdi
	movl	$4, %ecx
	movq	%r14, %rsi
	movq	%r12, %rdx
	callq	_parse_path83
	movq	-4208(%rbp), %rdx
	leaq	_package_default_assets.map(%rip), %rcx
	movl	$23, %r8d
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movl	$33, %r9d
	callq	_write_file_path
	movaps	LCPI0_2(%rip), %xmm0            ## xmm0 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movaps	%xmm0, -80(%rbp)
	movdqa	LCPI0_12(%rip), %xmm0           ## xmm0 = [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
	movdqa	%xmm0, -64(%rbp)
	leaq	L_.str.228(%rip), %rdi
	movl	$4, %ecx
	movq	%r14, %rsi
	movq	%r12, %rdx
	callq	_parse_path83
	movq	-4208(%rbp), %rdx
	leaq	-80(%rbp), %rcx
	movl	$32, %r8d
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movl	$33, %r9d
	callq	_write_file_path
	movq	-135408(%rbp), %rbx             ## 8-byte Reload
	testq	%rbx, %rbx
	je	LBB0_303
## %bb.300:
	movq	-135384(%rbp), %r12             ## 8-byte Reload
	.p2align	4
LBB0_301:                               ## =>This Inner Loop Header: Depth=1
	movq	96(%r12), %r13
	movq	$0, -80(%rbp)
	movl	$8, %ecx
	movq	%r12, %rdi
	leaq	-4176(%rbp), %rsi
	leaq	-80(%rbp), %rdx
	callq	_parse_path83
	movq	-80(%rbp), %r14
	cmpq	$1, %r14
	jbe	LBB0_469
## %bb.302:                             ##   in Loop: Header=BB0_301 Depth=1
	movq	%r13, %rdi
	callq	_read_file
	movq	%rax, %r13
	movq	%rdx, %r8
	leaq	-135296(%rbp), %rdi
	leaq	-4176(%rbp), %rsi
	movq	%r14, %rdx
	movq	%rax, %rcx
	movl	$33, %r9d
	callq	_write_file_path
	movq	%r13, %rdi
	callq	_free
	addq	$104, %r12
	decq	%rbx
	jne	LBB0_301
LBB0_303:
	leaq	_DEFAULT_CFG_NAME(%rip), %rsi
	leaq	_DEFAULT_CFG_CONTENT(%rip), %rcx
	leaq	-135296(%rbp), %rdi
	movl	$1, %edx
	movl	$17, %r8d
	movl	$32, %r9d
	callq	_write_file_path
	movq	-135296(%rbp), %rbx
	leaq	1311232(%rbx), %rax
	leaq	1311328(%rbx), %rcx
	pxor	%xmm0, %xmm0
	movq	-135416(%rbp), %r14             ## 8-byte Reload
	.p2align	4
LBB0_304:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_305 Depth 2
	movl	%r15d, %edx
	orb	$48, %dl
	movq	$-512, %rdi                     ## imm = 0xFE00
	movq	%rcx, %r8
                                        ## implicit-def: $esi
LBB0_305:                               ##   Parent Loop BB0_304 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	-96(%r8), %r9d
	cmpl	$229, %r9d
	je	LBB0_307
## %bb.306:                             ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	jne	LBB0_308
LBB0_307:                               ##   in Loop: Header=BB0_305 Depth=2
	leaq	512(%rdi), %rsi
LBB0_308:                               ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	je	LBB0_326
## %bb.309:                             ##   in Loop: Header=BB0_305 Depth=2
	cmpl	$229, %r9d
	je	LBB0_326
## %bb.310:                             ##   in Loop: Header=BB0_305 Depth=2
	movzbl	-64(%r8), %r9d
	cmpl	$229, %r9d
	je	LBB0_312
## %bb.311:                             ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	jne	LBB0_313
LBB0_312:                               ##   in Loop: Header=BB0_305 Depth=2
	leaq	513(%rdi), %rsi
LBB0_313:                               ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	je	LBB0_326
## %bb.314:                             ##   in Loop: Header=BB0_305 Depth=2
	cmpl	$229, %r9d
	je	LBB0_326
## %bb.315:                             ##   in Loop: Header=BB0_305 Depth=2
	movzbl	-32(%r8), %r9d
	cmpl	$229, %r9d
	je	LBB0_317
## %bb.316:                             ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	jne	LBB0_318
LBB0_317:                               ##   in Loop: Header=BB0_305 Depth=2
	leaq	514(%rdi), %rsi
LBB0_318:                               ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	je	LBB0_326
## %bb.319:                             ##   in Loop: Header=BB0_305 Depth=2
	cmpl	$229, %r9d
	je	LBB0_326
## %bb.320:                             ##   in Loop: Header=BB0_305 Depth=2
	movzbl	(%r8), %r9d
	cmpl	$229, %r9d
	je	LBB0_322
## %bb.321:                             ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	jne	LBB0_323
LBB0_322:                               ##   in Loop: Header=BB0_305 Depth=2
	leaq	515(%rdi), %rsi
LBB0_323:                               ##   in Loop: Header=BB0_305 Depth=2
	testl	%r9d, %r9d
	je	LBB0_326
## %bb.324:                             ##   in Loop: Header=BB0_305 Depth=2
	cmpl	$229, %r9d
	je	LBB0_326
## %bb.325:                             ##   in Loop: Header=BB0_305 Depth=2
	subq	$-128, %r8
	addq	$4, %rdi
	jne	LBB0_305
	jmp	LBB0_458
	.p2align	4
LBB0_326:                               ##   in Loop: Header=BB0_304 Depth=1
	cmpl	$512, %esi                      ## imm = 0x200
	jae	LBB0_463
## %bb.327:                             ##   in Loop: Header=BB0_304 Depth=1
	movl	%esi, %esi
	shlq	$5, %rsi
	movdqu	%xmm0, (%rax,%rsi)
	movdqu	%xmm0, 16(%rax,%rsi)
	movl	$1297043268, (%rax,%rsi)        ## imm = 0x4D4F4F44
	movl	$1447121741, 3(%rax,%rsi)       ## imm = 0x5641534D
	movb	%dl, 7(%rax,%rsi)
	movl	$541545284, 8(%rax,%rsi)        ## imm = 0x20475344
	movl	$0, 26(%rax,%rsi)
	movw	$0, 30(%rax,%rsi)
	incl	%r15d
	cmpl	$6, %r15d
	jne	LBB0_304
## %bb.328:
	leaq	1311328(%rbx), %rdx
	movq	$-512, %rsi                     ## imm = 0xFE00
                                        ## implicit-def: $ecx
	movq	-135392(%rbp), %r15             ## 8-byte Reload
LBB0_329:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_331
## %bb.330:                             ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	jne	LBB0_332
LBB0_331:                               ##   in Loop: Header=BB0_329 Depth=1
	leaq	512(%rsi), %rcx
LBB0_332:                               ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	je	LBB0_351
## %bb.333:                             ##   in Loop: Header=BB0_329 Depth=1
	cmpl	$229, %edi
	je	LBB0_351
## %bb.334:                             ##   in Loop: Header=BB0_329 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_336
## %bb.335:                             ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	jne	LBB0_337
LBB0_336:                               ##   in Loop: Header=BB0_329 Depth=1
	leaq	513(%rsi), %rcx
LBB0_337:                               ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	je	LBB0_351
## %bb.338:                             ##   in Loop: Header=BB0_329 Depth=1
	cmpl	$229, %edi
	je	LBB0_351
## %bb.339:                             ##   in Loop: Header=BB0_329 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_341
## %bb.340:                             ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	jne	LBB0_342
LBB0_341:                               ##   in Loop: Header=BB0_329 Depth=1
	leaq	514(%rsi), %rcx
LBB0_342:                               ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	je	LBB0_351
## %bb.343:                             ##   in Loop: Header=BB0_329 Depth=1
	cmpl	$229, %edi
	je	LBB0_351
## %bb.344:                             ##   in Loop: Header=BB0_329 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_346
## %bb.345:                             ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	jne	LBB0_347
LBB0_346:                               ##   in Loop: Header=BB0_329 Depth=1
	leaq	515(%rsi), %rcx
LBB0_347:                               ##   in Loop: Header=BB0_329 Depth=1
	testl	%edi, %edi
	je	LBB0_351
## %bb.348:                             ##   in Loop: Header=BB0_329 Depth=1
	cmpl	$229, %edi
	je	LBB0_351
## %bb.349:                             ##   in Loop: Header=BB0_329 Depth=1
	subq	$-128, %rdx
	addq	$4, %rsi
	jne	LBB0_329
## %bb.350:
	callq	_main.cold.33
LBB0_351:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB0_505
## %bb.352:
	movl	%ecx, %ecx
	shlq	$5, %rcx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movdqu	%xmm0, 16(%rax,%rcx)
	movabsq	$2329578481653007696, %rdx      ## imm = 0x2054534953524550
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       ## imm = 0x4B484320
	movb	$32, 1311243(%rbx,%rcx)
	movw	$0, 30(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	leaq	1311328(%rbx), %rdx
	movq	$-512, %rsi                     ## imm = 0xFE00
                                        ## implicit-def: $ecx
LBB0_353:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_355
## %bb.354:                             ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	jne	LBB0_356
LBB0_355:                               ##   in Loop: Header=BB0_353 Depth=1
	leaq	512(%rsi), %rcx
LBB0_356:                               ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	je	LBB0_375
## %bb.357:                             ##   in Loop: Header=BB0_353 Depth=1
	cmpl	$229, %edi
	je	LBB0_375
## %bb.358:                             ##   in Loop: Header=BB0_353 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_360
## %bb.359:                             ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	jne	LBB0_361
LBB0_360:                               ##   in Loop: Header=BB0_353 Depth=1
	leaq	513(%rsi), %rcx
LBB0_361:                               ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	je	LBB0_375
## %bb.362:                             ##   in Loop: Header=BB0_353 Depth=1
	cmpl	$229, %edi
	je	LBB0_375
## %bb.363:                             ##   in Loop: Header=BB0_353 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_365
## %bb.364:                             ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	jne	LBB0_366
LBB0_365:                               ##   in Loop: Header=BB0_353 Depth=1
	leaq	514(%rsi), %rcx
LBB0_366:                               ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	je	LBB0_375
## %bb.367:                             ##   in Loop: Header=BB0_353 Depth=1
	cmpl	$229, %edi
	je	LBB0_375
## %bb.368:                             ##   in Loop: Header=BB0_353 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_370
## %bb.369:                             ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	jne	LBB0_371
LBB0_370:                               ##   in Loop: Header=BB0_353 Depth=1
	leaq	515(%rsi), %rcx
LBB0_371:                               ##   in Loop: Header=BB0_353 Depth=1
	testl	%edi, %edi
	je	LBB0_375
## %bb.372:                             ##   in Loop: Header=BB0_353 Depth=1
	cmpl	$229, %edi
	je	LBB0_375
## %bb.373:                             ##   in Loop: Header=BB0_353 Depth=1
	subq	$-128, %rdx
	addq	$4, %rsi
	jne	LBB0_353
## %bb.374:
	callq	_main.cold.31
LBB0_375:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB0_506
## %bb.376:
	movl	%ecx, %ecx
	shlq	$5, %rcx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movdqu	%xmm0, 16(%rax,%rcx)
	movabsq	$2328718701980172627, %rdx      ## imm = 0x2051455245564153
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       ## imm = 0x4B484320
	movb	$32, 1311243(%rbx,%rcx)
	movw	$0, 30(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	leaq	1311328(%rbx), %rdx
	movq	$-512, %rsi                     ## imm = 0xFE00
                                        ## implicit-def: $ecx
LBB0_377:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_379
## %bb.378:                             ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	jne	LBB0_380
LBB0_379:                               ##   in Loop: Header=BB0_377 Depth=1
	leaq	512(%rsi), %rcx
LBB0_380:                               ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	je	LBB0_399
## %bb.381:                             ##   in Loop: Header=BB0_377 Depth=1
	cmpl	$229, %edi
	je	LBB0_399
## %bb.382:                             ##   in Loop: Header=BB0_377 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_384
## %bb.383:                             ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	jne	LBB0_385
LBB0_384:                               ##   in Loop: Header=BB0_377 Depth=1
	leaq	513(%rsi), %rcx
LBB0_385:                               ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	je	LBB0_399
## %bb.386:                             ##   in Loop: Header=BB0_377 Depth=1
	cmpl	$229, %edi
	je	LBB0_399
## %bb.387:                             ##   in Loop: Header=BB0_377 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_389
## %bb.388:                             ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	jne	LBB0_390
LBB0_389:                               ##   in Loop: Header=BB0_377 Depth=1
	leaq	514(%rsi), %rcx
LBB0_390:                               ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	je	LBB0_399
## %bb.391:                             ##   in Loop: Header=BB0_377 Depth=1
	cmpl	$229, %edi
	je	LBB0_399
## %bb.392:                             ##   in Loop: Header=BB0_377 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB0_394
## %bb.393:                             ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	jne	LBB0_395
LBB0_394:                               ##   in Loop: Header=BB0_377 Depth=1
	leaq	515(%rsi), %rcx
LBB0_395:                               ##   in Loop: Header=BB0_377 Depth=1
	testl	%edi, %edi
	je	LBB0_399
## %bb.396:                             ##   in Loop: Header=BB0_377 Depth=1
	cmpl	$229, %edi
	je	LBB0_399
## %bb.397:                             ##   in Loop: Header=BB0_377 Depth=1
	subq	$-128, %rdx
	addq	$4, %rsi
	jne	LBB0_377
## %bb.398:
	callq	_main.cold.29
LBB0_399:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB0_507
## %bb.400:
	movl	%ecx, %ecx
	shlq	$5, %rcx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movdqu	%xmm0, 16(%rax,%rcx)
	movabsq	$2328718701962022732, %rdx      ## imm = 0x2051455244414F4C
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       ## imm = 0x4B484320
	movb	$32, 11(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	movw	$0, 30(%rax,%rcx)
	movl	$22, %eax
	movdqa	LCPI0_13(%rip), %xmm1           ## xmm1 = [1,1,1,1]
	pxor	%xmm5, %xmm5
	pxor	%xmm4, %xmm4
	.p2align	4
LBB0_401:                               ## =>This Inner Loop Header: Depth=1
	movq	-135320(%rbp,%rax,2), %xmm2     ## xmm2 = mem[0],zero
	movq	-135312(%rbp,%rax,2), %xmm3     ## xmm3 = mem[0],zero
	pcmpeqw	%xmm0, %xmm2
	pmovzxwd	%xmm2, %xmm2                    ## xmm2 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero
	pand	%xmm1, %xmm2
	paddd	%xmm5, %xmm2
	pcmpeqw	%xmm0, %xmm3
	pmovzxwd	%xmm3, %xmm3                    ## xmm3 = xmm3[0],zero,xmm3[1],zero,xmm3[2],zero,xmm3[3],zero
	pand	%xmm1, %xmm3
	paddd	%xmm4, %xmm3
	cmpq	$64246, %rax                    ## imm = 0xFAF6
	je	LBB0_403
## %bb.402:                             ##   in Loop: Header=BB0_401 Depth=1
	movq	-135304(%rbp,%rax,2), %xmm4     ## xmm4 = mem[0],zero
	movq	-135296(%rbp,%rax,2), %xmm5     ## xmm5 = mem[0],zero
	pcmpeqw	%xmm0, %xmm4
	pmovzxwd	%xmm4, %xmm4                    ## xmm4 = xmm4[0],zero,xmm4[1],zero,xmm4[2],zero,xmm4[3],zero
	pand	%xmm1, %xmm4
	pcmpeqw	%xmm0, %xmm5
	pmovzxwd	%xmm5, %xmm5                    ## xmm5 = xmm5[0],zero,xmm5[1],zero,xmm5[2],zero,xmm5[3],zero
	pand	%xmm1, %xmm5
	paddd	%xmm4, %xmm2
	paddd	%xmm5, %xmm3
	addq	$16, %rax
	movdqa	%xmm2, %xmm5
	movdqa	%xmm3, %xmm4
	jmp	LBB0_401
LBB0_403:
	paddd	%xmm2, %xmm3
	pshufd	$238, %xmm3, %xmm0              ## xmm0 = xmm3[2,3,2,3]
	paddd	%xmm3, %xmm0
	pshufd	$85, %xmm0, %xmm1               ## xmm1 = xmm0[1,1,1,1]
	paddd	%xmm0, %xmm1
	movd	%xmm1, %eax
	cmpw	$1, -6812(%rbp)
	adcl	$0, %eax
	xorl	%ecx, %ecx
	cmpw	$0, -6810(%rbp)
	sete	%cl
	cmpw	$1, -6808(%rbp)
	adcl	%eax, %ecx
	xorl	%eax, %eax
	cmpw	$0, -6806(%rbp)
	sete	%al
	cmpw	$1, -6804(%rbp)
	adcl	%ecx, %eax
	xorl	%ecx, %ecx
	cmpw	$0, -6802(%rbp)
	sete	%cl
	cmpw	$1, -6800(%rbp)
	adcl	%eax, %ecx
	cmpl	$4095, %ecx                     ## imm = 0xFFF
	jbe	LBB0_508
## %bb.404:
	movl	$-8, -135280(%rbp)
	movl	$524552, %eax                   ## imm = 0x80108
	.p2align	4
LBB0_405:                               ## =>This Inner Loop Header: Depth=1
	movdqu	-1184384(%rbp,%rax,2), %xmm0
	movdqu	-1184368(%rbp,%rax,2), %xmm1
	movdqu	%xmm0, -16(%rbx,%rax,2)
	movdqu	%xmm1, (%rbx,%rax,2)
	addq	$16, %rax
	cmpq	$590088, %rax                   ## imm = 0x90108
	jne	LBB0_405
## %bb.406:
	movl	$590088, %eax                   ## imm = 0x90108
	.p2align	4
LBB0_407:                               ## =>This Inner Loop Header: Depth=1
	movdqu	-1315456(%rbp,%rax,2), %xmm0
	movdqu	-1315440(%rbp,%rax,2), %xmm1
	movdqu	%xmm0, -16(%rbx,%rax,2)
	movdqu	%xmm1, (%rbx,%rax,2)
	addq	$16, %rax
	cmpq	$655624, %rax                   ## imm = 0xA0108
	jne	LBB0_407
## %bb.408:
	movq	(%r14), %rdi
	movq	-135288(%rbp), %rdx
	movq	%rbx, %rsi
	callq	_write_file
	movq	%rbx, %rdi
	callq	_free
	movq	%r15, %rdi
	callq	_free
	movq	-135384(%rbp), %rdi             ## 8-byte Reload
	callq	_free
LBB0_409:
	movq	%r14, %rdi
	jmp	LBB0_442
LBB0_410:
	movq	%r12, %rax
	movq	32(%r12), %r9
	cmpq	$6, %rcx
	jne	LBB0_453
## %bb.411:
	movq	40(%rax), %r12
	testq	%r12, %r12
	je	LBB0_453
## %bb.412:
	movq	-135400(%rbp), %rsi             ## 8-byte Reload
	testq	%rsi, %rsi
	je	LBB0_454
## %bb.413:
	movabsq	$3477976621076005200, %rax      ## imm = 0x3044414F4C594150
	movabsq	$5065499754490842956, %rcx      ## imm = 0x464C453044414F4C
	movq	-135392(%rbp), %rdx             ## 8-byte Reload
	.p2align	4
LBB0_414:                               ## =>This Inner Loop Header: Depth=1
	movq	(%rdx), %rdi
	xorq	%rax, %rdi
	movq	3(%rdx), %r8
	xorq	%rcx, %r8
	orq	%rdi, %r8
	je	LBB0_498
## %bb.415:                             ##   in Loop: Header=BB0_414 Depth=1
	addq	$24, %rdx
	decq	%rsi
	jne	LBB0_414
LBB0_454:
	xorl	%edi, %edi
	jmp	LBB0_101
LBB0_417:
	testl	%edx, %edx
	je	LBB0_513
LBB0_418:
	testl	%ecx, %ecx
	je	LBB0_509
## %bb.419:
	leaq	L_.str.95(%rip), %rsi
	leaq	-4176(%rbp), %rdi
	movl	$1, %edx
	callq	_status_hex_tuple_part
	testl	%eax, %eax
	je	LBB0_509
## %bb.420:
	movl	$6, %eax
	movl	$1768841584, %ecx               ## imm = 0x696E6170
	.p2align	4
LBB0_421:                               ## =>This Inner Loop Header: Depth=1
	movl	-6(%r13,%rax), %edx
	xorl	%ecx, %edx
	movzwl	-2(%r13,%rax), %esi
	xorl	$15715, %esi                    ## imm = 0x3D63
	orl	%edx, %esi
	je	LBB0_448
## %bb.422:                             ##   in Loop: Header=BB0_421 Depth=1
	incq	%rax
	cmpq	%rbx, %rax
	jbe	LBB0_421
LBB0_423:
	movq	%r13, %rdi
	callq	_free
LBB0_424:
	movq	%r15, %r13
	movq	-135256(%rbp), %rbx
	testq	%rbx, %rbx
	movl	-135336(%rbp), %r15d            ## 4-byte Reload
	je	LBB0_435
## %bb.425:
	movq	%rbx, %rdi
	callq	_read_file
	testq	%rax, %rax
	je	LBB0_435
## %bb.426:
	cmpq	$11, %rdx
	jb	LBB0_430
## %bb.427:
	movabsq	$8746391181324018023, %rcx      ## imm = 0x79616C70656D6167
	movl	$11, %esi
	movabsq	$5426623667539570789, %rdi      ## imm = 0x4B4F3D79616C7065
	.p2align	4
LBB0_428:                               ## =>This Inner Loop Header: Depth=1
	movq	-11(%rax,%rsi), %r8
	xorq	%rcx, %r8
	movq	-8(%rax,%rsi), %r9
	xorq	%rdi, %r9
	orq	%r8, %r9
	je	LBB0_431
## %bb.429:                             ##   in Loop: Header=BB0_428 Depth=1
	incq	%rsi
	cmpq	%rdx, %rsi
	jbe	LBB0_428
LBB0_430:
	leaq	L_.str.100(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_431:
	movl	$6, %ecx
	movl	$1768841584, %esi               ## imm = 0x696E6170
	.p2align	4
LBB0_432:                               ## =>This Inner Loop Header: Depth=1
	movl	-6(%rax,%rcx), %edi
	xorl	%esi, %edi
	movzwl	-2(%rax,%rcx), %r8d
	xorl	$15715, %r8d                    ## imm = 0x3D63
	orl	%edi, %r8d
	je	LBB0_444
## %bb.433:                             ##   in Loop: Header=BB0_432 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	LBB0_432
LBB0_434:
	movq	%rax, %rdi
	callq	_free
LBB0_435:
	cmpl	$0, -135244(%rbp)
	je	LBB0_437
## %bb.436:
	movq	%r13, %rdi
	callq	_check_dynamic_fat_status
	movl	%eax, %ebx
	movq	-135384(%rbp), %rdi             ## 8-byte Reload
	callq	_check_dynamic_fat_status
	orl	%ebx, %eax
	je	LBB0_512
LBB0_437:
	leaq	L_str(%rip), %rdi
	callq	_puts
	leaq	L_.str.48(%rip), %rdi
	movq	-135400(%rbp), %rsi             ## 8-byte Reload
	xorl	%eax, %eax
	callq	_printf
	testl	%r15d, %r15d
	leaq	L_.str.51(%rip), %rax
	leaq	L_.str.50(%rip), %rsi
	cmoveq	%rax, %rsi
	leaq	L_.str.49(%rip), %rdi
	xorl	%eax, %eax
	callq	_printf
	testq	%r12, %r12
	je	LBB0_440
## %bb.438:
	leaq	L_.str.52(%rip), %rbx
	xorl	%r15d, %r15d
	.p2align	4
LBB0_439:                               ## =>This Inner Loop Header: Depth=1
	movl	-135240(%rbp,%r15,4), %esi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_printf
	incq	%r15
	cmpq	%r15, %r12
	jne	LBB0_439
LBB0_440:
	leaq	L_str.232(%rip), %rdi
	callq	_puts
	movq	%r14, %rdi
	callq	_free
	movq	-135320(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-135328(%rbp), %rdi             ## 8-byte Reload
LBB0_441:
	callq	_free
	movq	-135416(%rbp), %rdi             ## 8-byte Reload
LBB0_442:
	callq	_free
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB0_487
## %bb.443:
	xorl	%eax, %eax
	addq	$135416, %rsp                   ## imm = 0x210F8
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB0_444:
	movl	$10, %ecx
	movabsq	$5714572474359636336, %rsi      ## imm = 0x4F4E3D63696E6170
	.p2align	4
LBB0_445:                               ## =>This Inner Loop Header: Depth=1
	movq	-10(%rax,%rcx), %rdi
	xorq	%rsi, %rdi
	movzwl	-2(%rax,%rcx), %r8d
	xorq	$17742, %r8                     ## imm = 0x454E
	orq	%rdi, %r8
	je	LBB0_434
## %bb.446:                             ##   in Loop: Header=BB0_445 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	LBB0_445
## %bb.447:
	leaq	L_.str.101(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_448:
	movl	$10, %eax
	movabsq	$5714572474359636336, %rcx      ## imm = 0x4F4E3D63696E6170
	.p2align	4
LBB0_449:                               ## =>This Inner Loop Header: Depth=1
	movq	-10(%r13,%rax), %rdx
	xorq	%rcx, %rdx
	movzwl	-2(%r13,%rax), %esi
	xorq	$17742, %rsi                    ## imm = 0x454E
	orq	%rdx, %rsi
	je	LBB0_423
## %bb.450:                             ##   in Loop: Header=BB0_449 Depth=1
	incq	%rax
	cmpq	%rbx, %rax
	jbe	LBB0_449
## %bb.451:
	leaq	L_.str.99(%rip), %rsi
	movq	-135344(%rbp), %rdi             ## 8-byte Reload
	callq	_die_path
LBB0_453:
	xorl	%r12d, %r12d
	jmp	LBB0_101
LBB0_455:
	callq	_main.cold.58
LBB0_456:
	callq	_main.cold.17
LBB0_457:
	callq	_main.cold.9
LBB0_458:
	callq	_main.cold.35
LBB0_459:
	callq	_main.cold.54
LBB0_460:
	callq	_main.cold.15
LBB0_461:
	callq	_main.cold.64
LBB0_462:
	callq	_main.cold.67
LBB0_463:
	callq	_main.cold.34
LBB0_464:
	callq	_main.cold.62
LBB0_465:
	callq	_main.cold.10
LBB0_466:
	callq	_main.cold.66
LBB0_467:
	callq	_main.cold.59
LBB0_468:
	callq	_main.cold.65
LBB0_469:
	callq	_main.cold.26
LBB0_470:
	movq	-135344(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135256(%rbp)
	movq	-135384(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135264(%rbp)
	movq	-135336(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135272(%rbp)
	movq	-135352(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135280(%rbp)
	leaq	L_.str.42(%rip), %rdi
	callq	_die
LBB0_471:
	callq	_main.cold.12
LBB0_472:
	callq	_main.cold.61
LBB0_473:
	callq	_main.cold.60
LBB0_474:
	callq	_main.cold.63
LBB0_475:
	callq	_main.cold.14
LBB0_476:
	callq	_main.cold.47
LBB0_477:
	callq	_main.cold.4
LBB0_478:
	callq	_main.cold.1
LBB0_479:
	callq	_main.cold.11
LBB0_480:
	callq	_main.cold.13
LBB0_481:
	callq	_main.cold.6
LBB0_482:
	callq	_main.cold.7
LBB0_483:
	callq	_main.cold.8
LBB0_484:
	callq	_main.cold.24
LBB0_485:
	callq	_main.cold.23
LBB0_486:
	callq	_main.cold.70
LBB0_487:
	callq	___stack_chk_fail
LBB0_488:
	callq	_main.cold.2
LBB0_489:
	callq	_main.cold.3
LBB0_490:
	callq	_main.cold.5
LBB0_491:
	callq	_main.cold.16
LBB0_492:
	leaq	L_.str.54(%rip), %rsi
	movq	%r12, %rdi
	callq	_die_path
LBB0_493:
	leaq	L_.str.55(%rip), %rsi
	movq	%r12, %rdi
	callq	_die_path
LBB0_494:
	leaq	L_.str.56(%rip), %rsi
	movq	%r12, %rdi
	callq	_die_path
LBB0_495:
	leaq	L_.str.57(%rip), %rsi
	movq	%r12, %rdi
	callq	_die_path
LBB0_496:
	leaq	L_.str.58(%rip), %rsi
	movq	%r12, %rdi
	callq	_die_path
LBB0_497:
	leaq	L_.str.59(%rip), %rsi
	movq	%r12, %rdi
	callq	_die_path
LBB0_498:
	callq	_main.cold.18
LBB0_499:
	callq	_main.cold.53
LBB0_500:
	callq	_main.cold.52
LBB0_501:
	callq	_main.cold.19
LBB0_502:
	callq	_main.cold.20
LBB0_503:
	callq	_main.cold.25
LBB0_504:
	callq	_main.cold.36
LBB0_505:
	callq	_main.cold.32
LBB0_506:
	callq	_main.cold.30
LBB0_507:
	callq	_main.cold.28
LBB0_508:
	callq	_main.cold.27
LBB0_509:
	leaq	L_.str.96(%rip), %rsi
	movq	-135344(%rbp), %rdi             ## 8-byte Reload
	callq	_die_path
LBB0_510:
	callq	_main.cold.55
LBB0_511:
	callq	_main.cold.57
LBB0_512:
	callq	_main.cold.69
LBB0_513:
	callq	_main.cold.68
LBB0_514:
	leaq	L_.str.136(%rip), %rsi
	movq	%r13, %rdi
	callq	_die_path
LBB0_515:
	movq	%rdx, %rdi
	callq	_main.cold.22
LBB0_516:
	leaq	L_.str.141(%rip), %rsi
	movq	%r14, %rdi
	callq	_die_path
LBB0_517:
	movq	%rdx, %rdi
	callq	_main.cold.21
LBB0_518:
	leaq	L_.str.142(%rip), %rsi
	movq	%r14, %rdi
	callq	_die_path
LBB0_519:
	movq	-135344(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135256(%rbp)
	movq	-135384(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135264(%rbp)
	movq	-135336(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135272(%rbp)
	movq	-135352(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135280(%rbp)
	leaq	L_.str.45(%rip), %rdi
	callq	_die
LBB0_520:
	callq	_main.cold.56
LBB0_521:
	leaq	L_.str.145(%rip), %rsi
	movq	%r14, %rdi
	callq	_die_path
LBB0_522:
	callq	_main.cold.51
LBB0_523:
	callq	_main.cold.50
LBB0_524:
	callq	_main.cold.49
LBB0_525:
	callq	_main.cold.48
LBB0_526:
	callq	_main.cold.46
LBB0_527:
	callq	_main.cold.45
LBB0_528:
	callq	_main.cold.38
LBB0_529:
	movq	-135344(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135256(%rbp)
	movq	-135384(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135264(%rbp)
	movq	-135336(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135272(%rbp)
	movq	-135352(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135280(%rbp)
	leaq	L_.str.43(%rip), %rdi
	callq	_die
LBB0_530:
	callq	_main.cold.44
LBB0_531:
	callq	_main.cold.43
LBB0_532:
	callq	_main.cold.42
LBB0_533:
	callq	_main.cold.41
LBB0_534:
	callq	_main.cold.40
LBB0_535:
	callq	_main.cold.39
LBB0_536:
	movq	-135344(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135256(%rbp)
	movq	-135384(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135264(%rbp)
	movq	-135336(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135272(%rbp)
	movq	-135352(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -135280(%rbp)
	leaq	L_.str.44(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker
_mutate_root_marker:                    ## @mutate_root_marker
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movl	$131144, %eax                   ## imm = 0x20048
	callq	____chkstk_darwin
	subq	%rax, %rsp
	popq	%rax
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movl	%ecx, %r12d
	movq	%rdx, %r15
	movq	%rsi, %r13
	movq	%rdi, %rbx
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	callq	_read_file
	cmpq	$67108864, %rdx                 ## imm = 0x4000000
	jne	LBB1_27
## %bb.1:
	movq	%rax, %r14
	movq	%rax, -131184(%rbp)
	movq	$67108864, -131176(%rbp)        ## imm = 0x4000000
	leaq	-131168(%rbp), %rdi
	leaq	1049088(%rax), %rsi
	movl	$131072, %edx                   ## imm = 0x20000
	callq	_memcpy
	leaq	L_.str.30(%rip), %rsi
	movq	%r13, %rdi
	callq	_strcmp
	testl	%eax, %eax
	movl	%r12d, -68(%rbp)                ## 4-byte Spill
	je	LBB1_2
## %bb.3:
	leaq	L_.str.31(%rip), %rsi
	movq	%r13, %rdi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB1_4
## %bb.5:
	leaq	L_.str.32(%rip), %rsi
	movq	%r13, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB1_28
## %bb.6:
	leaq	_LOAD_REQUEST_NAME(%rip), %r13
	jmp	LBB1_7
LBB1_2:
	leaq	_PERSISTENCE_CHECKPOINT_NAME(%rip), %r13
	jmp	LBB1_7
LBB1_4:
	leaq	_SAVE_REQUEST_NAME(%rip), %r13
LBB1_7:
	movl	7(%r13), %eax
	movl	%eax, -57(%rbp)
	movq	(%r13), %rax
	movq	%rax, -64(%rbp)
	leaq	1311232(%r14), %r12
	movq	$-28, %rax
	jmp	LBB1_8
	.p2align	4
LBB1_11:                                ##   in Loop: Header=BB1_8 Depth=1
	addq	$-32, %rax
	addq	$32, %r12
	cmpq	$-16412, %rax                   ## imm = 0xBFE4
	je	LBB1_19
LBB1_8:                                 ## =>This Inner Loop Header: Depth=1
	movzbl	(%r12), %ecx
	cmpl	$229, %ecx
	je	LBB1_11
## %bb.9:                               ##   in Loop: Header=BB1_8 Depth=1
	testl	%ecx, %ecx
	je	LBB1_19
## %bb.10:                              ##   in Loop: Header=BB1_8 Depth=1
	movq	(%r12), %rcx
	xorq	-64(%rbp), %rcx
	movq	3(%r12), %rdx
	xorq	-61(%rbp), %rdx
	orq	%rcx, %rdx
	jne	LBB1_11
## %bb.12:
	movq	%r13, -80(%rbp)                 ## 8-byte Spill
	movq	%r15, -88(%rbp)                 ## 8-byte Spill
	movq	%rbx, -96(%rbp)                 ## 8-byte Spill
	negq	%rax
	cmpq	$16385, %rax                    ## imm = 0x4001
	jae	LBB1_29
## %bb.13:
	movzwl	26(%r12), %r13d
	movq	%r14, %r15
	addq	$1325568, %r15                  ## imm = 0x143A00
	movl	$65537, %ebx                    ## imm = 0x10001
	.p2align	4
LBB1_14:                                ## =>This Inner Loop Header: Depth=1
	cmpw	$2, %r13w
	jb	LBB1_18
## %bb.15:                              ##   in Loop: Header=BB1_14 Depth=1
	decl	%ebx
	je	LBB1_18
## %bb.16:                              ##   in Loop: Header=BB1_14 Depth=1
	movzwl	%r13w, %edi
	movl	%edi, %eax
	movzwl	-131168(%rbp,%rax,2), %r13d
	movw	$0, -131168(%rbp,%rax,2)
	leal	-64241(%rdi), %eax
	cmpl	$-64240, %eax                   ## imm = 0xFFFF0510
	jbe	LBB1_30
## %bb.17:                              ##   in Loop: Header=BB1_14 Depth=1
	shll	$10, %edi
	addq	%r15, %rdi
	movl	$1024, %esi                     ## imm = 0x400
	callq	___bzero
	cmpw	$-8, %r13w
	jb	LBB1_14
LBB1_18:
	xorps	%xmm0, %xmm0
	movups	%xmm0, (%r12)
	movups	%xmm0, 16(%r12)
	movb	$-27, (%r12)
	movq	-96(%rbp), %rbx                 ## 8-byte Reload
	movq	-88(%rbp), %r15                 ## 8-byte Reload
	movq	-80(%rbp), %r13                 ## 8-byte Reload
LBB1_19:
	cmpl	$0, -68(%rbp)                   ## 4-byte Folded Reload
	je	LBB1_21
## %bb.20:
	movq	%r15, %rdi
	callq	_strlen
	leaq	-131184(%rbp), %rdi
	movl	$1, %edx
	movq	%r13, %rsi
	movq	%r15, %rcx
	movq	%rax, %r8
	movl	$32, %r9d
	callq	_write_file_path
	movq	-131184(%rbp), %r14
LBB1_21:
	movl	$-8, -131168(%rbp)
	movl	$524552, %eax                   ## imm = 0x80108
	.p2align	4
LBB1_22:                                ## =>This Inner Loop Header: Depth=1
	movups	-1180272(%rbp,%rax,2), %xmm0
	movups	-1180256(%rbp,%rax,2), %xmm1
	movups	%xmm0, -16(%r14,%rax,2)
	movups	%xmm1, (%r14,%rax,2)
	addq	$16, %rax
	cmpq	$590088, %rax                   ## imm = 0x90108
	jne	LBB1_22
## %bb.23:
	movl	$590088, %eax                   ## imm = 0x90108
	.p2align	4
LBB1_24:                                ## =>This Inner Loop Header: Depth=1
	movups	-1311344(%rbp,%rax,2), %xmm0
	movups	-1311328(%rbp,%rax,2), %xmm1
	movups	%xmm0, -16(%r14,%rax,2)
	movups	%xmm1, (%r14,%rax,2)
	addq	$16, %rax
	cmpq	$655624, %rax                   ## imm = 0xA0108
	jne	LBB1_24
## %bb.25:
	movq	-131176(%rbp), %rdx
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	_write_file
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB1_31
## %bb.26:
	movq	%r14, %rdi
	addq	$131144, %rsp                   ## imm = 0x20048
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	jmp	_free                           ## TAILCALL
LBB1_30:
	callq	_mutate_root_marker.cold.2
LBB1_27:
	leaq	L_.str.23(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB1_31:
	callq	___stack_chk_fail
LBB1_28:
	callq	_mutate_root_marker.cold.1
LBB1_29:
	callq	_mutate_root_marker.cold.3
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function die
_die:                                   ## @die
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.121(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file
_write_file:                            ## @write_file
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rdx, %r14
	movq	%rsi, %r12
	movq	%rdi, %rbx
	leaq	L_.str.230(%rip), %rsi
	callq	_fopen
	testq	%rax, %rax
	je	LBB3_4
## %bb.1:
	movq	%rax, %r15
	testq	%r14, %r14
	je	LBB3_3
## %bb.2:
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%r14, %rdx
	movq	%r15, %rcx
	callq	_fwrite
	cmpq	%r14, %rax
	jne	LBB3_5
LBB3_3:
	movq	%r15, %rdi
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	jmp	_fclose                         ## TAILCALL
LBB3_4:
	movq	%rbx, %rdi
	callq	_write_file.cold.1
LBB3_5:
	leaq	L_.str.231(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_file
_read_file:                             ## @read_file
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rdi, %rbx
	leaq	L_.str.24(%rip), %rsi
	callq	_fopen
	testq	%rax, %rax
	je	LBB4_8
## %bb.1:
	movq	%rax, %r14
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$2, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB4_9
## %bb.2:
	movq	%r14, %rdi
	callq	_ftell
	testq	%rax, %rax
	js	LBB4_10
## %bb.3:
	movq	%rax, %r15
	movq	%r14, %rdi
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB4_9
## %bb.4:
	leaq	1(%r15), %rdi
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB4_11
## %bb.5:
	movq	%rax, %r12
	testq	%r15, %r15
	je	LBB4_7
## %bb.6:
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%r15, %rdx
	movq	%r14, %rcx
	callq	_fread
	cmpq	%r15, %rax
	jne	LBB4_12
LBB4_7:
	movq	%r14, %rdi
	callq	_fclose
	movq	%r12, %rax
	movq	%r15, %rdx
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB4_9:
	leaq	L_.str.25(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB4_8:
	movq	%rbx, %rdi
	callq	_read_file.cold.2
LBB4_10:
	leaq	L_.str.26(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB4_11:
	callq	_read_file.cold.1
LBB4_12:
	leaq	L_.str.27(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function die_path
_die_path:                              ## @die_path
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.28(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path
_write_file_path:                       ## @write_file_path
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movl	%r9d, -44(%rbp)                 ## 4-byte Spill
	movq	%r8, -56(%rbp)                  ## 8-byte Spill
	movq	%rcx, %r8
	movq	%rdx, %r12
	movq	%rsi, %r13
	movq	%rdi, %r14
	cmpq	$1, %rdx
	je	LBB6_7
## %bb.1:
	movq	%r8, -64(%rbp)                  ## 8-byte Spill
	testq	%r12, %r12
	je	LBB6_24
## %bb.2:
	leaq	-1(%r12), %rbx
	xorl	%eax, %eax
	movq	%r13, %r15
	.p2align	4
LBB6_3:                                 ## =>This Inner Loop Header: Depth=1
	movq	%r14, %rdi
	movl	%eax, %esi
	movq	%r15, %rdx
	movl	$17, %ecx
	callq	_ensure_child_directory
                                        ## kill: def $eax killed $eax def $rax
	addq	$11, %r15
	decq	%rbx
	jne	LBB6_3
## %bb.4:
	testl	%eax, %eax
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	je	LBB6_7
## %bb.5:
	leal	-64241(%rax), %ecx
	cmpl	$-64240, %ecx                   ## imm = 0xFFFF0510
	jbe	LBB6_6
## %bb.8:
	movq	(%r14), %rcx
	shll	$10, %eax
	leaq	(%rcx,%rax), %rbx
	addq	$1325568, %rbx                  ## imm = 0x143A00
	movl	$1024, %r15d                    ## imm = 0x400
	jmp	LBB6_9
LBB6_7:
	movl	$1311232, %ebx                  ## imm = 0x140200
	addq	(%r14), %rbx
	movl	$16384, %r15d                   ## imm = 0x4000
LBB6_9:
	leaq	-68(%rbp), %rcx
	movq	%r14, %rdi
	movq	%r8, %rsi
	movq	-56(%rbp), %rdx                 ## 8-byte Reload
	callq	_write_cluster_chain
	leaq	(%r12,%r12,4), %rcx
	leaq	(%r12,%rcx,2), %rcx
	addq	%r13, %rcx
	addq	$-11, %rcx
	leaq	-32(%r15), %rdx
	xorl	%edi, %edi
	xorl	%esi, %esi
	jmp	LBB6_10
	.p2align	4
LBB6_13:                                ##   in Loop: Header=BB6_10 Depth=1
	incl	%esi
	movq	%rsi, %r8
	shlq	$5, %r8
	addl	$32, %edi
	cmpq	%rdx, %r8
	ja	LBB6_14
LBB6_10:                                ## =>This Inner Loop Header: Depth=1
	movl	%edi, %edi
	movzbl	(%rbx,%rdi), %r8d
	cmpl	$229, %r8d
	je	LBB6_13
## %bb.11:                              ##   in Loop: Header=BB6_10 Depth=1
	testl	%r8d, %r8d
	je	LBB6_14
## %bb.12:                              ##   in Loop: Header=BB6_10 Depth=1
	movq	(%rbx,%rdi), %r8
	xorq	(%rcx), %r8
	movq	3(%rbx,%rdi), %r9
	xorq	3(%rcx), %r9
	orq	%r8, %r9
	jne	LBB6_13
LBB6_22:
	movl	%esi, %edx
	shlq	$5, %rdx
	cmpq	%r15, %rdx
	jae	LBB6_23
## %bb.25:
	xorps	%xmm0, %xmm0
	movups	%xmm0, 16(%rbx,%rdx)
	movups	%xmm0, (%rbx,%rdx)
	movq	(%rcx), %rsi
	movq	%rsi, (%rbx,%rdx)
	movl	7(%rcx), %ecx
	movl	%ecx, 7(%rbx,%rdx)
	movl	-44(%rbp), %ecx                 ## 4-byte Reload
	movb	%cl, 11(%rbx,%rdx)
	movb	%al, 26(%rbx,%rdx)
	movb	%ah, 27(%rbx,%rdx)
	movq	-56(%rbp), %rcx                 ## 8-byte Reload
	movb	%cl, 28(%rbx,%rdx)
	movb	%ch, 29(%rbx,%rdx)
	movl	%ecx, %eax
	shrl	$16, %eax
	movb	%al, 30(%rbx,%rdx)
	shrl	$24, %ecx
	movb	%cl, 31(%rbx,%rdx)
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB6_14:
	xorl	%edi, %edi
                                        ## implicit-def: $r9d
	xorl	%r8d, %r8d
	.p2align	4
LBB6_15:                                ## =>This Inner Loop Header: Depth=1
	movl	%edi, %esi
	movzbl	(%rbx,%rsi), %r10d
	movl	%r8d, %esi
	testl	%r10d, %r10d
	je	LBB6_18
## %bb.16:                              ##   in Loop: Header=BB6_15 Depth=1
	movl	%r8d, %esi
	cmpl	$229, %r10d
	je	LBB6_18
## %bb.17:                              ##   in Loop: Header=BB6_15 Depth=1
	movl	%r9d, %esi
LBB6_18:                                ##   in Loop: Header=BB6_15 Depth=1
	testl	%r10d, %r10d
	je	LBB6_22
## %bb.19:                              ##   in Loop: Header=BB6_15 Depth=1
	cmpl	$229, %r10d
	je	LBB6_22
## %bb.20:                              ##   in Loop: Header=BB6_15 Depth=1
	incl	%r8d
	movq	%r8, %r10
	shlq	$5, %r10
	addl	$32, %edi
	movl	%esi, %r9d
	cmpq	%rdx, %r10
	jbe	LBB6_15
## %bb.21:
	callq	_write_file_path.cold.3
LBB6_23:
	callq	_write_file_path.cold.4
LBB6_24:
	callq	_write_file_path.cold.1
LBB6_6:
	callq	_write_file_path.cold.2
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory
_ensure_child_directory:                ## @ensure_child_directory
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rdx, %r15
	movl	%esi, %ebx
	testl	%esi, %esi
	je	LBB7_3
## %bb.1:
	leal	-64241(%rbx), %eax
	cmpl	$-64240, %eax                   ## imm = 0xFFFF0510
	jbe	LBB7_2
## %bb.4:
	movq	(%rdi), %rax
	movl	%ebx, %edx
	shll	$10, %edx
	leaq	(%rax,%rdx), %r13
	addq	$1325568, %r13                  ## imm = 0x143A00
	movl	$1024, %r9d                     ## imm = 0x400
	jmp	LBB7_5
LBB7_3:
	movl	$1311232, %r13d                 ## imm = 0x140200
	addq	(%rdi), %r13
	movl	$16384, %r9d                    ## imm = 0x4000
LBB7_5:
	leaq	-32(%r9), %r12
	xorl	%eax, %eax
	xorl	%r8d, %r8d
	jmp	LBB7_6
	.p2align	4
LBB7_9:                                 ##   in Loop: Header=BB7_6 Depth=1
	incl	%r8d
	movq	%r8, %rdx
	shlq	$5, %rdx
	addl	$32, %eax
	cmpq	%r12, %rdx
	ja	LBB7_10
LBB7_6:                                 ## =>This Inner Loop Header: Depth=1
	movl	%eax, %eax
	movzbl	(%r13,%rax), %edx
	cmpl	$229, %edx
	je	LBB7_9
## %bb.7:                               ##   in Loop: Header=BB7_6 Depth=1
	testl	%edx, %edx
	je	LBB7_10
## %bb.8:                               ##   in Loop: Header=BB7_6 Depth=1
	movq	(%r13,%rax), %rdx
	xorq	(%r15), %rdx
	movq	3(%r13,%rax), %rsi
	xorq	3(%r15), %rsi
	orq	%rdx, %rsi
	jne	LBB7_9
## %bb.18:
	movl	%r8d, %eax
	shlq	$5, %rax
	movzbl	11(%r13,%rax), %edx
	testb	$16, %dl
	je	LBB7_27
## %bb.19:
	testb	$1, %cl
	je	LBB7_21
## %bb.20:
	orb	$1, %dl
	movb	%dl, 11(%r13,%rax)
LBB7_21:
	movq	%rax, %rcx
	orq	$28, %rcx
	cmpq	%r9, %rcx
	ja	LBB7_28
## %bb.22:
	movzwl	26(%r13,%rax), %eax
	jmp	LBB7_26
LBB7_10:
	movq	%r9, -64(%rbp)                  ## 8-byte Spill
	movl	%ecx, -48(%rbp)                 ## 4-byte Spill
	movb	$0, -41(%rbp)
	xorl	%r14d, %r14d
	leaq	-41(%rbp), %rsi
	leaq	-68(%rbp), %rcx
	movq	%rdi, -56(%rbp)                 ## 8-byte Spill
	xorl	%edx, %edx
	callq	_write_cluster_chain
                                        ## kill: def $eax killed $eax def $rax
                                        ## implicit-def: $esi
	xorl	%ecx, %ecx
	.p2align	4
LBB7_11:                                ## =>This Inner Loop Header: Depth=1
	movl	%r14d, %edx
	movzbl	(%r13,%rdx), %edi
	movl	%ecx, %edx
	testl	%edi, %edi
	je	LBB7_14
## %bb.12:                              ##   in Loop: Header=BB7_11 Depth=1
	movl	%ecx, %edx
	cmpl	$229, %edi
	je	LBB7_14
## %bb.13:                              ##   in Loop: Header=BB7_11 Depth=1
	movl	%esi, %edx
LBB7_14:                                ##   in Loop: Header=BB7_11 Depth=1
	testl	%edi, %edi
	je	LBB7_23
## %bb.15:                              ##   in Loop: Header=BB7_11 Depth=1
	cmpl	$229, %edi
	je	LBB7_23
## %bb.16:                              ##   in Loop: Header=BB7_11 Depth=1
	incl	%ecx
	movq	%rcx, %rdi
	shlq	$5, %rdi
	addl	$32, %r14d
	movl	%edx, %esi
	cmpq	%r12, %rdi
	jbe	LBB7_11
## %bb.17:
	callq	_ensure_child_directory.cold.4
LBB7_23:
	movl	%edx, %ecx
	shlq	$5, %rcx
	cmpq	-64(%rbp), %rcx                 ## 8-byte Folded Reload
	jae	LBB7_29
## %bb.24:
	xorps	%xmm0, %xmm0
	movups	%xmm0, 16(%r13,%rcx)
	movups	%xmm0, (%r13,%rcx)
	movq	(%r15), %rdx
	movq	%rdx, (%r13,%rcx)
	movl	7(%r15), %edx
	movl	%edx, 7(%r13,%rcx)
	movl	-48(%rbp), %r8d                 ## 4-byte Reload
	movb	%r8b, 11(%r13,%rcx)
	movb	%al, 26(%r13,%rcx)
	movl	%eax, %edx
	shrl	$8, %edx
	movb	%dl, 27(%r13,%rcx)
	leal	-64241(%rax), %esi
	movl	$0, 28(%r13,%rcx)
	cmpl	$-64240, %esi                   ## imm = 0xFFFF0510
	jbe	LBB7_30
## %bb.25:
	movq	-56(%rbp), %rcx                 ## 8-byte Reload
	movq	(%rcx), %rcx
	movl	%eax, %esi
	shlq	$10, %rsi
	movups	%xmm0, 1325568(%rcx,%rsi)
	movups	%xmm0, 1325584(%rcx,%rsi)
	movabsq	$2314885530818453550, %rdi      ## imm = 0x202020202020202E
	movq	%rdi, 1325568(%rcx,%rsi)
	movl	$538976288, 1325575(%rcx,%rsi)  ## imm = 0x20202020
	movb	%r8b, 1325579(%rcx,%rsi)
	movb	%al, 1325594(%rcx,%rsi)
	movb	%dl, 1325595(%rcx,%rsi)
	movl	$0, 1325596(%rcx,%rsi)
	movups	%xmm0, 1325600(%rcx,%rsi)
	movups	%xmm0, 1325616(%rcx,%rsi)
	movabsq	$2314885530818457134, %rdx      ## imm = 0x2020202020202E2E
	movq	%rdx, 1325600(%rcx,%rsi)
	movl	$538976288, 1325607(%rcx,%rsi)  ## imm = 0x20202020
	movb	$16, 1325611(%rcx,%rsi)
	movb	%bl, 1325626(%rcx,%rsi)
	movb	%bh, 1325627(%rcx,%rsi)
	movl	$0, 1325628(%rcx,%rsi)
LBB7_26:
                                        ## kill: def $eax killed $eax killed $rax
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB7_29:
	callq	_ensure_child_directory.cold.2
LBB7_30:
	callq	_ensure_child_directory.cold.3
LBB7_2:
	callq	_ensure_child_directory.cold.1
LBB7_27:
	callq	_ensure_child_directory.cold.6
LBB7_28:
	callq	_ensure_child_directory.cold.5
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain
_write_cluster_chain:                   ## @write_cluster_chain
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rcx, %r14
	movq	%rsi, -80(%rbp)                 ## 8-byte Spill
	movq	%rdi, %r12
	movq	%rdx, -56(%rbp)                 ## 8-byte Spill
	leaq	1023(%rdx), %r15
	shrq	$10, %r15
	cmpl	$2, %r15d
	movl	$1, %edi
	cmovael	%r15d, %edi
	movl	$4, %esi
	movq	%rdi, -64(%rbp)                 ## 8-byte Spill
	callq	_calloc
	testq	%rax, %rax
	je	LBB8_25
## %bb.1:
	movq	%rax, %rbx
	leaq	20(%r12), %rcx
	xorl	%eax, %eax
	movl	$2, %edx
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	.p2align	4
LBB8_2:                                 ## =>This Inner Loop Header: Depth=1
	cmpw	$0, (%rcx)
	jne	LBB8_4
## %bb.3:                               ##   in Loop: Header=BB8_2 Depth=1
	movl	%eax, %esi
	incl	%eax
	movl	%edx, (%rbx,%rsi,4)
LBB8_4:                                 ##   in Loop: Header=BB8_2 Depth=1
	cmpq	$64239, %rdx                    ## imm = 0xFAEF
	ja	LBB8_5
## %bb.9:                               ##   in Loop: Header=BB8_2 Depth=1
	incq	%rdx
	addq	$2, %rcx
	cmpl	%r8d, %eax
	jb	LBB8_2
LBB8_5:
	cmpl	%r8d, %eax
	jne	LBB8_10
## %bb.6:
	movq	%r14, -72(%rbp)                 ## 8-byte Spill
	movl	(%rbx), %r9d
	movl	%r9d, %esi
	cmpl	$2, %r15d
	jb	LBB8_17
## %bb.7:
	leaq	-1(%r8), %rsi
	movl	%esi, %eax
	andl	$3, %eax
	leal	-2(%r8), %ecx
	cmpl	$3, %ecx
	jae	LBB8_11
## %bb.8:
	movl	$1, %edx
	movl	%r9d, %ecx
	jmp	LBB8_14
LBB8_11:
	andq	$-4, %rsi
	xorl	%edx, %edx
	movl	%r9d, %ecx
	.p2align	4
LBB8_12:                                ## =>This Inner Loop Header: Depth=1
	movl	4(%rbx,%rdx,4), %edi
	movl	%ecx, %ecx
	movw	%di, 16(%r12,%rcx,2)
	movl	8(%rbx,%rdx,4), %ecx
	movw	%cx, 16(%r12,%rdi,2)
	movl	12(%rbx,%rdx,4), %edi
	movw	%di, 16(%r12,%rcx,2)
	movl	16(%rbx,%rdx,4), %ecx
	movw	%cx, 16(%r12,%rdi,2)
	addq	$4, %rdx
	cmpq	%rdx, %rsi
	jne	LBB8_12
## %bb.13:
	incq	%rdx
LBB8_14:
	movl	%ecx, %esi
	testq	%rax, %rax
	je	LBB8_17
## %bb.15:
	leaq	(%rbx,%rdx,4), %rdx
	xorl	%edi, %edi
	.p2align	4
LBB8_16:                                ## =>This Inner Loop Header: Depth=1
	movl	(%rdx,%rdi,4), %esi
	movl	%ecx, %ecx
	movw	%si, 16(%r12,%rcx,2)
	incq	%rdi
	movl	%esi, %ecx
	cmpq	%rdi, %rax
	jne	LBB8_16
LBB8_17:
	movl	%r9d, -44(%rbp)                 ## 4-byte Spill
	movl	%esi, %eax
	movw	$-1, 16(%r12,%rax,2)
	xorl	%r14d, %r14d
	movq	-56(%rbp), %r15                 ## 8-byte Reload
	jmp	LBB8_18
	.p2align	4
LBB8_22:                                ##   in Loop: Header=BB8_18 Depth=1
	shlq	$10, %rax
	movq	(%r12), %rcx
	leaq	(%rcx,%rax), %rdi
	addq	$1325568, %rdi                  ## imm = 0x143A00
	movq	-56(%rbp), %rsi                 ## 8-byte Reload
	subq	%r15, %rsi
	addq	-80(%rbp), %rsi                 ## 8-byte Folded Reload
	movq	%r13, %rdx
	callq	_memcpy
	movq	-64(%rbp), %r8                  ## 8-byte Reload
LBB8_23:                                ##   in Loop: Header=BB8_18 Depth=1
	subq	%r13, %r15
	incq	%r14
	cmpq	%r14, %r8
	je	LBB8_24
LBB8_18:                                ## =>This Inner Loop Header: Depth=1
	movl	(%rbx,%r14,4), %eax
	leal	-64241(%rax), %ecx
	cmpl	$-64240, %ecx                   ## imm = 0xFFFF0510
	jbe	LBB8_26
## %bb.19:                              ##   in Loop: Header=BB8_18 Depth=1
	movl	$1024, %r13d                    ## imm = 0x400
	cmpq	$1023, %r15                     ## imm = 0x3FF
	ja	LBB8_22
## %bb.20:                              ##   in Loop: Header=BB8_18 Depth=1
	movq	%r15, %r13
	testq	%r15, %r15
	jne	LBB8_22
## %bb.21:                              ##   in Loop: Header=BB8_18 Depth=1
	xorl	%r13d, %r13d
	jmp	LBB8_23
LBB8_24:
	movq	%rbx, %rdi
	movq	%r8, %rbx
	callq	_free
	movq	-72(%rbp), %rax                 ## 8-byte Reload
	movl	%ebx, (%rax)
	movl	-44(%rbp), %eax                 ## 4-byte Reload
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB8_26:
	callq	_write_cluster_chain.cold.2
LBB8_25:
	callq	_write_cluster_chain.cold.3
LBB8_10:
	callq	_write_cluster_chain.cold.1
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function validate_image_layout
_validate_image_layout:                 ## @validate_image_layout
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	cmpq	$67108864, 8(%rdi)              ## imm = 0x4000000
	jne	LBB9_1
## %bb.3:
	movq	(%rdi), %rax
	cmpw	$-21931, 510(%rax)              ## imm = 0xAA55
	jne	LBB9_4
## %bb.5:
	cmpl	$2048, 454(%rax)                ## imm = 0x800
	jne	LBB9_7
## %bb.6:
	cmpl	$129024, 458(%rax)              ## imm = 0x1F800
	jne	LBB9_7
## %bb.8:
	cmpw	$-21931, 1049086(%rax)          ## imm = 0xAA55
	jne	LBB9_9
## %bb.10:
	cmpw	$512, 1048587(%rax)             ## imm = 0x200
	jne	LBB9_11
## %bb.12:
	cmpb	$2, 1048589(%rax)
	jne	LBB9_13
## %bb.14:
	popq	%rbp
	retq
LBB9_1:
	leaq	L_.str.54(%rip), %rax
	jmp	LBB9_2
LBB9_4:
	leaq	L_.str.55(%rip), %rax
	jmp	LBB9_2
LBB9_7:
	leaq	L_.str.56(%rip), %rax
	jmp	LBB9_2
LBB9_9:
	leaq	L_.str.57(%rip), %rax
	jmp	LBB9_2
LBB9_11:
	leaq	L_.str.58(%rip), %rax
	jmp	LBB9_2
LBB9_13:
	leaq	L_.str.59(%rip), %rax
LBB9_2:
	movq	%rsi, %rdi
	movq	%rax, %rsi
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status
_check_write_status:                    ## @check_write_status
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	subq	$16, %rsp
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	testq	%rdi, %rdi
	je	LBB10_101
## %bb.1:
	movl	%esi, %r12d
	movq	%rdi, %rbx
	callq	_read_file
	movq	%rax, -48(%rbp)
	movq	%rdx, -40(%rbp)
	testq	%rax, %rax
	je	LBB10_101
## %bb.2:
	movq	%rax, %r14
	movq	%rdx, %r15
	testl	%r12d, %r12d
	je	LBB10_53
## %bb.3:
	cmpq	$7, %r15
	jb	LBB10_13
## %bb.4:
	movl	$1702257011, %eax               ## imm = 0x65766173
	xorl	(%r14), %eax
	movzwl	4(%r14), %ecx
	xorl	$29303, %ecx                    ## imm = 0x7277
	orl	%eax, %ecx
	movabsq	$4294976512, %r12               ## imm = 0x100002400
	jne	LBB10_6
## %bb.5:
	cmpb	$61, 6(%r14)
	movq	%r14, %rax
	je	LBB10_15
LBB10_6:
	leaq	-6(%r15), %rax
	cmpq	$1, %rax
	je	LBB10_13
## %bb.7:
	leaq	-7(%r15), %rcx
	xorl	%eax, %eax
	movl	$1702257011, %edx               ## imm = 0x65766173
	jmp	LBB10_8
	.p2align	4
LBB10_12:                               ##   in Loop: Header=BB10_8 Depth=1
	incq	%rax
	cmpq	%rax, %rcx
	je	LBB10_13
LBB10_8:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %esi
	cmpq	$32, %rsi
	ja	LBB10_12
## %bb.9:                               ##   in Loop: Header=BB10_8 Depth=1
	btq	%rsi, %r12
	jae	LBB10_12
## %bb.10:                              ##   in Loop: Header=BB10_8 Depth=1
	movl	1(%r14,%rax), %esi
	xorl	%edx, %esi
	movzwl	5(%r14,%rax), %edi
	xorl	$29303, %edi                    ## imm = 0x7277
	orl	%esi, %edi
	jne	LBB10_12
## %bb.11:                              ##   in Loop: Header=BB10_8 Depth=1
	cmpb	$61, 7(%r14,%rax)
	jne	LBB10_12
## %bb.14:
	addq	%r14, %rax
	incq	%rax
LBB10_15:
	movzbl	7(%rax), %edi
	testb	%dil, %dil
	je	LBB10_102
## %bb.16:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB10_17:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB10_19
## %bb.18:                              ##   in Loop: Header=BB10_17 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB10_24
	jmp	LBB10_25
	.p2align	4
LBB10_19:                               ##   in Loop: Header=BB10_17 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB10_21
## %bb.20:                              ##   in Loop: Header=BB10_17 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB10_24
	jmp	LBB10_25
	.p2align	4
LBB10_21:                               ##   in Loop: Header=BB10_17 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB10_25
## %bb.22:                              ##   in Loop: Header=BB10_17 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB10_25
LBB10_24:                               ##   in Loop: Header=BB10_17 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	8(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB10_17
	jmp	LBB10_26
LBB10_101:
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB10_53:
	cmpq	$10, %r15
	jb	LBB10_63
## %bb.54:
	movabsq	$8388361638216953700, %rdx      ## imm = 0x746972776D6F6F64
	leaq	-9(%r15), %rax
	movq	(%r14), %rcx
	xorq	%rdx, %rcx
	movzbl	8(%r14), %esi
	xorq	$101, %rsi
	orq	%rcx, %rsi
	jne	LBB10_56
## %bb.55:
	cmpb	$61, 9(%r14)
	movq	%r14, %rcx
	je	LBB10_65
LBB10_56:
	cmpq	$1, %rax
	je	LBB10_63
## %bb.57:
	leaq	-10(%r15), %rsi
	xorl	%ecx, %ecx
	movabsq	$4294976512, %rdi               ## imm = 0x100002400
	jmp	LBB10_58
	.p2align	4
LBB10_62:                               ##   in Loop: Header=BB10_58 Depth=1
	incq	%rcx
	cmpq	%rcx, %rsi
	je	LBB10_63
LBB10_58:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rcx), %r8d
	cmpq	$32, %r8
	ja	LBB10_62
## %bb.59:                              ##   in Loop: Header=BB10_58 Depth=1
	btq	%r8, %rdi
	jae	LBB10_62
## %bb.60:                              ##   in Loop: Header=BB10_58 Depth=1
	movq	1(%r14,%rcx), %r8
	xorq	%rdx, %r8
	movzbl	9(%r14,%rcx), %r9d
	xorq	$101, %r9
	orq	%r8, %r9
	jne	LBB10_62
## %bb.61:                              ##   in Loop: Header=BB10_58 Depth=1
	cmpb	$61, 10(%r14,%rcx)
	jne	LBB10_62
## %bb.64:
	addq	%r14, %rcx
	incq	%rcx
LBB10_65:
	movzbl	10(%rcx), %r8d
	testb	%r8b, %r8b
	je	LBB10_105
## %bb.66:
	xorl	%esi, %esi
	xorl	%edx, %edx
	.p2align	4
LBB10_67:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%r8b, %edi
	leal	-48(%rdi), %r9d
	cmpb	$9, %r9b
	ja	LBB10_69
## %bb.68:                              ##   in Loop: Header=BB10_67 Depth=1
	addl	$-48, %edi
	testl	%edi, %edi
	jns	LBB10_74
	jmp	LBB10_75
	.p2align	4
LBB10_69:                               ##   in Loop: Header=BB10_67 Depth=1
	leal	-97(%r8), %r9d
	cmpb	$5, %r9b
	ja	LBB10_71
## %bb.70:                              ##   in Loop: Header=BB10_67 Depth=1
	addl	$-87, %edi
	testl	%edi, %edi
	jns	LBB10_74
	jmp	LBB10_75
	.p2align	4
LBB10_71:                               ##   in Loop: Header=BB10_67 Depth=1
	addb	$-65, %r8b
	cmpb	$5, %r8b
	ja	LBB10_75
## %bb.72:                              ##   in Loop: Header=BB10_67 Depth=1
	addl	$-55, %edi
	testl	%edi, %edi
	js	LBB10_75
LBB10_74:                               ##   in Loop: Header=BB10_67 Depth=1
	shll	$4, %edx
	orl	%edi, %edx
	movzbl	11(%rcx,%rsi), %r8d
	incq	%rsi
	testb	%r8b, %r8b
	jne	LBB10_67
	jmp	LBB10_76
LBB10_25:
	testl	%edx, %edx
	je	LBB10_102
LBB10_26:
	testl	%ecx, %ecx
	je	LBB10_103
## %bb.27:
	leaq	L_.str.81(%rip), %rsi
	leaq	-48(%rbp), %rdi
	movl	$1, %edx
	callq	_status_hex_tuple_part
	testl	%eax, %eax
	je	LBB10_103
## %bb.28:
	cmpq	$10, %r15
	jb	LBB10_38
## %bb.29:
	movabsq	$8317986210936414579, %rcx      ## imm = 0x736F6C6365766173
	movq	(%r14), %rax
	xorq	%rcx, %rax
	movzbl	8(%r14), %edx
	xorq	$101, %rdx
	orq	%rax, %rdx
	jne	LBB10_31
## %bb.30:
	cmpb	$61, 9(%r14)
	movq	%r14, %rax
	je	LBB10_40
LBB10_31:
	leaq	-9(%r15), %rax
	cmpq	$1, %rax
	je	LBB10_38
## %bb.32:
	addq	$-10, %r15
	xorl	%eax, %eax
	jmp	LBB10_33
	.p2align	4
LBB10_37:                               ##   in Loop: Header=BB10_33 Depth=1
	incq	%rax
	cmpq	%rax, %r15
	je	LBB10_38
LBB10_33:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %edx
	cmpq	$32, %rdx
	ja	LBB10_37
## %bb.34:                              ##   in Loop: Header=BB10_33 Depth=1
	btq	%rdx, %r12
	jae	LBB10_37
## %bb.35:                              ##   in Loop: Header=BB10_33 Depth=1
	movq	1(%r14,%rax), %rdx
	xorq	%rcx, %rdx
	movzbl	9(%r14,%rax), %esi
	xorq	$101, %rsi
	orq	%rdx, %rsi
	jne	LBB10_37
## %bb.36:                              ##   in Loop: Header=BB10_33 Depth=1
	cmpb	$61, 10(%r14,%rax)
	jne	LBB10_37
## %bb.39:
	addq	%r14, %rax
	incq	%rax
LBB10_40:
	movzbl	10(%rax), %edi
	testb	%dil, %dil
	je	LBB10_104
## %bb.41:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB10_42:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB10_44
## %bb.43:                              ##   in Loop: Header=BB10_42 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB10_49
	jmp	LBB10_50
	.p2align	4
LBB10_44:                               ##   in Loop: Header=BB10_42 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB10_46
## %bb.45:                              ##   in Loop: Header=BB10_42 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB10_49
	jmp	LBB10_50
	.p2align	4
LBB10_46:                               ##   in Loop: Header=BB10_42 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB10_50
## %bb.47:                              ##   in Loop: Header=BB10_42 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB10_50
LBB10_49:                               ##   in Loop: Header=BB10_42 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	11(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB10_42
	jmp	LBB10_51
LBB10_50:
	testl	%edx, %edx
	je	LBB10_104
LBB10_51:
	testl	%ecx, %ecx
	jne	LBB10_100
## %bb.52:
	leaq	L_.str.84(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB10_75:
	testl	%esi, %esi
	je	LBB10_105
LBB10_76:
	testl	%edx, %edx
	je	LBB10_106
## %bb.77:
	movabsq	$8317986210936414579, %rdx      ## imm = 0x736F6C6365766173
	addq	$133762545, %rdx                ## imm = 0x7F90DF1
	movq	(%r14), %rcx
	xorq	%rdx, %rcx
	movzbl	8(%r14), %esi
	xorq	$101, %rsi
	orq	%rcx, %rsi
	jne	LBB10_79
## %bb.78:
	cmpb	$61, 9(%r14)
	movq	%r14, %rcx
	je	LBB10_88
LBB10_79:
	cmpq	$1, %rax
	je	LBB10_86
## %bb.80:
	addq	$-10, %r15
	xorl	%eax, %eax
	movabsq	$4294976512, %rcx               ## imm = 0x100002400
	jmp	LBB10_81
	.p2align	4
LBB10_85:                               ##   in Loop: Header=BB10_81 Depth=1
	incq	%rax
	cmpq	%rax, %r15
	je	LBB10_86
LBB10_81:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %esi
	cmpq	$32, %rsi
	ja	LBB10_85
## %bb.82:                              ##   in Loop: Header=BB10_81 Depth=1
	btq	%rsi, %rcx
	jae	LBB10_85
## %bb.83:                              ##   in Loop: Header=BB10_81 Depth=1
	movq	1(%r14,%rax), %rsi
	xorq	%rdx, %rsi
	movzbl	9(%r14,%rax), %edi
	xorq	$101, %rdi
	orq	%rsi, %rdi
	jne	LBB10_85
## %bb.84:                              ##   in Loop: Header=BB10_81 Depth=1
	cmpb	$61, 10(%r14,%rax)
	jne	LBB10_85
## %bb.87:
	leaq	(%r14,%rax), %rcx
	incq	%rcx
LBB10_88:
	movzbl	10(%rcx), %edi
	testb	%dil, %dil
	je	LBB10_107
## %bb.89:
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align	4
LBB10_90:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB10_92
## %bb.91:                              ##   in Loop: Header=BB10_90 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB10_97
	jmp	LBB10_98
	.p2align	4
LBB10_92:                               ##   in Loop: Header=BB10_90 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB10_94
## %bb.93:                              ##   in Loop: Header=BB10_90 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB10_97
	jmp	LBB10_98
	.p2align	4
LBB10_94:                               ##   in Loop: Header=BB10_90 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB10_98
## %bb.95:                              ##   in Loop: Header=BB10_90 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB10_98
LBB10_97:                               ##   in Loop: Header=BB10_90 Depth=1
	shll	$4, %eax
	orl	%esi, %eax
	movzbl	11(%rcx,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB10_90
	jmp	LBB10_99
LBB10_98:
	testl	%edx, %edx
	je	LBB10_107
LBB10_99:
	testl	%eax, %eax
	je	LBB10_108
LBB10_100:
	movq	%r14, %rdi
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	jmp	_free                           ## TAILCALL
LBB10_13:
	callq	_check_write_status.cold.1
LBB10_38:
	callq	_check_write_status.cold.2
LBB10_63:
	callq	_check_write_status.cold.5
LBB10_86:
	callq	_check_write_status.cold.6
LBB10_103:
	leaq	L_.str.82(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB10_102:
	callq	_check_write_status.cold.4
LBB10_104:
	callq	_check_write_status.cold.3
LBB10_105:
	callq	_check_write_status.cold.8
LBB10_107:
	callq	_check_write_status.cold.7
LBB10_106:
	leaq	L_.str.86(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB10_108:
	leaq	L_.str.88(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_dynamic_fat_status
_check_dynamic_fat_status:              ## @check_dynamic_fat_status
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	xorl	%r14d, %r14d
	testq	%rdi, %rdi
	je	LBB11_42
## %bb.1:
	movq	%rdi, %rbx
	callq	_read_file
	movq	%rax, -72(%rbp)
	movq	%rdx, -64(%rbp)
	testq	%rax, %rax
	je	LBB11_42
## %bb.2:
	xorl	%r14d, %r14d
	cmpq	$7, %rdx
	jb	LBB11_41
## %bb.3:
	movl	$1685348710, %ecx               ## imm = 0x64746166
	xorl	(%rax), %ecx
	leaq	-6(%rdx), %rsi
	movzwl	4(%rax), %edi
	xorl	$28281, %edi                    ## imm = 0x6E79
	orl	%ecx, %edi
	jne	LBB11_5
## %bb.4:
	cmpb	$61, 6(%rax)
	je	LBB11_13
LBB11_5:
	cmpq	$1, %rsi
	je	LBB11_41
## %bb.6:
	leaq	-7(%rdx), %rcx
	xorl	%edi, %edi
	movabsq	$4294976512, %r8                ## imm = 0x100002400
	movl	$1685348710, %r9d               ## imm = 0x64746166
	jmp	LBB11_7
	.p2align	4
LBB11_11:                               ##   in Loop: Header=BB11_7 Depth=1
	incq	%rdi
	cmpq	%rdi, %rcx
	je	LBB11_12
LBB11_7:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%rax,%rdi), %r10d
	cmpq	$32, %r10
	ja	LBB11_11
## %bb.8:                               ##   in Loop: Header=BB11_7 Depth=1
	btq	%r10, %r8
	jae	LBB11_11
## %bb.9:                               ##   in Loop: Header=BB11_7 Depth=1
	movl	1(%rax,%rdi), %r10d
	xorl	%r9d, %r10d
	movzwl	5(%rax,%rdi), %r11d
	xorl	$28281, %r11d                   ## imm = 0x6E79
	orl	%r10d, %r11d
	jne	LBB11_11
## %bb.10:                              ##   in Loop: Header=BB11_7 Depth=1
	cmpb	$61, 7(%rax,%rdi)
	jne	LBB11_11
LBB11_13:
	movl	$1685348710, %ecx               ## imm = 0x64746166
	xorl	(%rax), %ecx
	movzwl	4(%rax), %edi
	xorl	$28281, %edi                    ## imm = 0x6E79
	orl	%ecx, %edi
	jne	LBB11_15
## %bb.14:
	cmpb	$61, 6(%rax)
	movq	%rax, %rcx
	je	LBB11_24
LBB11_15:
	cmpq	$1, %rsi
	je	LBB11_22
## %bb.16:
	addq	$-7, %rdx
	xorl	%ecx, %ecx
	movabsq	$4294976512, %rsi               ## imm = 0x100002400
	movl	$1685348710, %edi               ## imm = 0x64746166
	jmp	LBB11_17
	.p2align	4
LBB11_21:                               ##   in Loop: Header=BB11_17 Depth=1
	incq	%rcx
	cmpq	%rcx, %rdx
	je	LBB11_22
LBB11_17:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%rax,%rcx), %r8d
	cmpq	$32, %r8
	ja	LBB11_21
## %bb.18:                              ##   in Loop: Header=BB11_17 Depth=1
	btq	%r8, %rsi
	jae	LBB11_21
## %bb.19:                              ##   in Loop: Header=BB11_17 Depth=1
	movl	1(%rax,%rcx), %r8d
	xorl	%edi, %r8d
	movzwl	5(%rax,%rcx), %r9d
	xorl	$28281, %r9d                    ## imm = 0x6E79
	orl	%r8d, %r9d
	jne	LBB11_21
## %bb.20:                              ##   in Loop: Header=BB11_17 Depth=1
	cmpb	$61, 7(%rax,%rcx)
	jne	LBB11_21
## %bb.23:
	addq	%rax, %rcx
	incq	%rcx
LBB11_24:
	movzbl	7(%rcx), %edi
	testb	%dil, %dil
	je	LBB11_43
## %bb.25:
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	.p2align	4
LBB11_26:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB11_28
## %bb.27:                              ##   in Loop: Header=BB11_26 Depth=1
	addl	$-48, %esi
	jmp	LBB11_32
	.p2align	4
LBB11_28:                               ##   in Loop: Header=BB11_26 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB11_30
## %bb.29:                              ##   in Loop: Header=BB11_26 Depth=1
	addl	$-87, %esi
	jmp	LBB11_32
LBB11_30:                               ##   in Loop: Header=BB11_26 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB11_34
## %bb.31:                              ##   in Loop: Header=BB11_26 Depth=1
	addl	$-55, %esi
LBB11_32:                               ##   in Loop: Header=BB11_26 Depth=1
	testl	%esi, %esi
	js	LBB11_34
## %bb.33:                              ##   in Loop: Header=BB11_26 Depth=1
	shll	$4, %r13d
	orl	%esi, %r13d
	movzbl	8(%rcx,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB11_26
	jmp	LBB11_35
LBB11_12:
	xorl	%r14d, %r14d
	jmp	LBB11_41
LBB11_34:
	testl	%edx, %edx
	je	LBB11_43
LBB11_35:
	movq	%rax, -56(%rbp)                 ## 8-byte Spill
	leaq	L_.str.102(%rip), %r14
	leaq	-72(%rbp), %r12
	movl	$2, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	_status_hex_tuple_part
	movl	%eax, -48(%rbp)                 ## 4-byte Spill
	movl	$4, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	_status_hex_tuple_part
	movl	%eax, -44(%rbp)                 ## 4-byte Spill
	movl	$6, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	_status_hex_tuple_part
	movl	%eax, %r15d
	movl	$7, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	_status_hex_tuple_part
	movl	$1, %r14d
	testl	%r13d, %r13d
	jne	LBB11_36
## %bb.37:
	movl	%eax, %ecx
	cmpl	$0, -48(%rbp)                   ## 4-byte Folded Reload
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	jne	LBB11_41
## %bb.38:
	cmpl	$0, -44(%rbp)                   ## 4-byte Folded Reload
	jne	LBB11_41
## %bb.39:
	testl	%r15d, %r15d
	jne	LBB11_41
## %bb.40:
	testl	%ecx, %ecx
	je	LBB11_44
LBB11_41:
	movq	%rax, %rdi
	callq	_free
LBB11_42:
	movl	%r14d, %eax
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB11_36:
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	jmp	LBB11_41
LBB11_22:
	callq	_check_dynamic_fat_status.cold.1
LBB11_43:
	callq	_check_dynamic_fat_status.cold.2
LBB11_44:
	leaq	L_.str.103(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function root_file_equal
_root_file_equal:                       ## @root_file_equal
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	(%rdi), %rax
	xorl	%r9d, %r9d
	jmp	LBB12_1
	.p2align	4
LBB12_6:                                ##   in Loop: Header=BB12_1 Depth=1
	addq	$32, %r9
	cmpq	$16384, %r9                     ## imm = 0x4000
	je	LBB12_7
LBB12_1:                                ## =>This Inner Loop Header: Depth=1
	movzbl	1311232(%rax,%r9), %ecx
	cmpl	$229, %ecx
	je	LBB12_6
## %bb.2:                               ##   in Loop: Header=BB12_1 Depth=1
	testl	%ecx, %ecx
	je	LBB12_3
## %bb.4:                               ##   in Loop: Header=BB12_1 Depth=1
	movq	1311232(%rax,%r9), %rcx
	xorq	(%rdx), %rcx
	movq	1311235(%rax,%r9), %r8
	xorq	3(%rdx), %r8
	orq	%rcx, %r8
	jne	LBB12_6
## %bb.5:
	movzbl	1311243(%rax,%r9), %r8d
	movzwl	1311258(%rax,%r9), %r10d
	movl	1311260(%rax,%r9), %ecx
	shlq	$32, %rcx
	orq	%r10, %rcx
	shlq	$32, %r8
	movl	$1, %eax
	movb	$1, %r9b
	jmp	LBB12_8
LBB12_7:
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	jmp	LBB12_8
LBB12_3:
	xorl	%r9d, %r9d
	movq	%rcx, %r8
	movq	%rcx, %rax
LBB12_8:
	orq	%r8, %rax
	movq	%rax, -56(%rbp)
	movq	%rcx, -48(%rbp)
	movq	(%rsi), %r10
	xorl	%r11d, %r11d
	jmp	LBB12_9
	.p2align	4
LBB12_12:                               ##   in Loop: Header=BB12_9 Depth=1
	addq	$32, %r11
	cmpq	$16384, %r11                    ## imm = 0x4000
	je	LBB12_13
LBB12_9:                                ## =>This Inner Loop Header: Depth=1
	movzbl	1311232(%r10,%r11), %eax
	cmpl	$229, %eax
	je	LBB12_12
## %bb.10:                              ##   in Loop: Header=BB12_9 Depth=1
	testl	%eax, %eax
	je	LBB12_19
## %bb.11:                              ##   in Loop: Header=BB12_9 Depth=1
	movq	1311232(%r10,%r11), %rax
	xorq	(%rdx), %rax
	movq	1311235(%r10,%r11), %rbx
	xorq	3(%rdx), %rbx
	orq	%rax, %rbx
	jne	LBB12_12
## %bb.14:
	movzwl	1311258(%r10,%r11), %eax
	movl	1311260(%r10,%r11), %edx
	shlq	$32, %rdx
	orq	%rdx, %rax
	movzbl	1311243(%r10,%r11), %r10d
	shlq	$32, %r10
	leaq	1(%r10), %r11
	movq	%r11, -40(%rbp)
	movq	%rax, -32(%rbp)
	cmpq	%r10, %r8
	sete	%al
	andb	%al, %r9b
	xorl	%eax, %eax
	cmpb	$1, %r9b
	jne	LBB12_19
## %bb.15:
	xorq	%rdx, %rcx
	shrq	$32, %rcx
	jne	LBB12_19
## %bb.16:
	leaq	L_.str.64(%rip), %rdx
	leaq	-56(%rbp), %rax
	movq	%rsi, %r14
	movq	%rax, %rsi
	callq	_read_root_file_blob
	movq	%rax, %rbx
	movq	%rdx, %r15
	leaq	L_.str.65(%rip), %rdx
	leaq	-40(%rbp), %rsi
	movq	%r14, %rdi
	callq	_read_root_file_blob
	movq	%rax, %r14
	xorl	%ecx, %ecx
	cmpq	%rdx, %r15
	jne	LBB12_18
## %bb.17:
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_memcmp
	xorl	%ecx, %ecx
	testl	%eax, %eax
	sete	%cl
LBB12_18:
	movq	%rbx, %rdi
	movl	%ecx, %ebx
	callq	_free
	movq	%r14, %rdi
	callq	_free
	movl	%ebx, %eax
	jmp	LBB12_19
LBB12_13:
	xorl	%eax, %eax
LBB12_19:
	addq	$40, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_root_file_blob
_read_root_file_blob:                   ## @read_root_file_blob
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rdx, -48(%rbp)                 ## 8-byte Spill
	movq	%rsi, %r13
	movq	%rdi, -72(%rbp)                 ## 8-byte Spill
	movl	12(%rsi), %ebx
	testq	%rbx, %rbx
	movl	$1, %edi
	cmovneq	%rbx, %rdi
	movl	$1, %esi
	callq	_calloc
	movq	%rax, -64(%rbp)                 ## 8-byte Spill
	testq	%rax, %rax
	je	LBB13_10
## %bb.1:
	movq	%rbx, -56(%rbp)                 ## 8-byte Spill
	testq	%rbx, %rbx
	je	LBB13_9
## %bb.2:
	movl	8(%r13), %ebx
	leal	-64241(%rbx), %eax
	cmpl	$-64239, %eax                   ## imm = 0xFFFF0511
	jb	LBB13_11
## %bb.3:
	movl	$64241, %r15d                   ## imm = 0xFAF1
	xorl	%r12d, %r12d
	.p2align	4
LBB13_4:                                ## =>This Inner Loop Header: Depth=1
	leal	-64241(%rbx), %eax
	cmpl	$-64239, %eax                   ## imm = 0xFFFF0511
	jb	LBB13_12
## %bb.5:                               ##   in Loop: Header=BB13_4 Depth=1
	decl	%r15d
	je	LBB13_12
## %bb.6:                               ##   in Loop: Header=BB13_4 Depth=1
	movq	-72(%rbp), %rax                 ## 8-byte Reload
	movq	(%rax), %r14
	movq	-56(%rbp), %r13                 ## 8-byte Reload
	subq	%r12, %r13
	cmpq	$1024, %r13                     ## imm = 0x400
	movl	$1024, %eax                     ## imm = 0x400
	cmovaeq	%rax, %r13
	movq	-64(%rbp), %rax                 ## 8-byte Reload
	leaq	(%rax,%r12), %rdi
	movl	%ebx, %eax
	shll	$10, %eax
	leaq	(%r14,%rax), %rsi
	addq	$1325568, %rsi                  ## imm = 0x143A00
	movq	%r13, %rdx
	callq	_memcpy
	addq	%r13, %r12
	cmpq	-56(%rbp), %r12                 ## 8-byte Folded Reload
	jae	LBB13_9
## %bb.7:                               ##   in Loop: Header=BB13_4 Depth=1
	movl	%ebx, %eax
	movzwl	1049088(%r14,%rax,2), %ebx
	cmpl	$65528, %ebx                    ## imm = 0xFFF8
	jb	LBB13_4
## %bb.8:
	leaq	L_.str.68(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB13_9:
	movq	-64(%rbp), %rax                 ## 8-byte Reload
	movq	-56(%rbp), %rdx                 ## 8-byte Reload
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB13_12:
	leaq	L_.str.67(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB13_10:
	callq	_read_root_file_blob.cold.1
LBB13_11:
	leaq	L_.str.66(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part
_status_hex_tuple_part:                 ## @status_hex_tuple_part
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -24
	movq	%rdx, %rbx
	callq	_status_find_field
	testq	%rax, %rax
	je	LBB14_53
## %bb.1:
	testq	%rbx, %rbx
	je	LBB14_13
	.p2align	4
LBB14_2:                                ## =>This Inner Loop Header: Depth=1
	incq	%rax
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB14_5
## %bb.3:                               ##   in Loop: Header=BB14_2 Depth=1
	cmpl	$58, %ecx
	je	LBB14_5
## %bb.4:                               ##   in Loop: Header=BB14_2 Depth=1
	testl	%ecx, %ecx
	jne	LBB14_2
LBB14_10:
	callq	_status_hex_tuple_part.cold.1
LBB14_5:
	cmpq	$1, %rbx
	je	LBB14_13
## %bb.6:
	addq	$2, %rax
	.p2align	4
LBB14_7:                                ## =>This Inner Loop Header: Depth=1
	movzbl	-2(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB14_11
## %bb.8:                               ##   in Loop: Header=BB14_7 Depth=1
	cmpl	$58, %ecx
	je	LBB14_11
## %bb.9:                               ##   in Loop: Header=BB14_7 Depth=1
	testl	%ecx, %ecx
	je	LBB14_10
## %bb.17:                              ##   in Loop: Header=BB14_7 Depth=1
	incq	%rax
	jmp	LBB14_7
LBB14_11:
	cmpq	$2, %rbx
	jne	LBB14_18
LBB14_12:
	decq	%rax
	jmp	LBB14_13
	.p2align	4
LBB14_18:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB14_22
## %bb.19:                              ##   in Loop: Header=BB14_18 Depth=1
	cmpl	$58, %ecx
	je	LBB14_22
## %bb.20:                              ##   in Loop: Header=BB14_18 Depth=1
	testl	%ecx, %ecx
	je	LBB14_10
## %bb.21:                              ##   in Loop: Header=BB14_18 Depth=1
	incq	%rax
	jmp	LBB14_18
LBB14_22:
	cmpq	$3, %rbx
	je	LBB14_13
## %bb.23:
	addq	$4, %rax
	.p2align	4
LBB14_24:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-4(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB14_28
## %bb.25:                              ##   in Loop: Header=BB14_24 Depth=1
	cmpl	$58, %ecx
	je	LBB14_28
## %bb.26:                              ##   in Loop: Header=BB14_24 Depth=1
	testl	%ecx, %ecx
	je	LBB14_10
## %bb.27:                              ##   in Loop: Header=BB14_24 Depth=1
	incq	%rax
	jmp	LBB14_24
LBB14_28:
	cmpq	$4, %rbx
	jne	LBB14_30
## %bb.29:
	addq	$-3, %rax
	jmp	LBB14_13
	.p2align	4
LBB14_30:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-3(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB14_34
## %bb.31:                              ##   in Loop: Header=BB14_30 Depth=1
	cmpl	$58, %ecx
	je	LBB14_34
## %bb.32:                              ##   in Loop: Header=BB14_30 Depth=1
	testl	%ecx, %ecx
	je	LBB14_10
## %bb.33:                              ##   in Loop: Header=BB14_30 Depth=1
	incq	%rax
	jmp	LBB14_30
LBB14_34:
	cmpq	$5, %rbx
	jne	LBB14_36
## %bb.35:
	addq	$-2, %rax
LBB14_13:
	movzbl	(%rax), %edi
	testb	%dil, %dil
	je	LBB14_54
## %bb.14:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB14_15:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB14_45
## %bb.16:                              ##   in Loop: Header=BB14_15 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB14_50
	jmp	LBB14_51
	.p2align	4
LBB14_45:                               ##   in Loop: Header=BB14_15 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB14_47
## %bb.46:                              ##   in Loop: Header=BB14_15 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB14_50
	jmp	LBB14_51
	.p2align	4
LBB14_47:                               ##   in Loop: Header=BB14_15 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB14_51
## %bb.48:                              ##   in Loop: Header=BB14_15 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB14_51
LBB14_50:                               ##   in Loop: Header=BB14_15 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	1(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB14_15
	jmp	LBB14_52
LBB14_51:
	testl	%edx, %edx
	je	LBB14_54
LBB14_52:
	movl	%ecx, %eax
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq
	.p2align	4
LBB14_36:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-2(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB14_40
## %bb.37:                              ##   in Loop: Header=BB14_36 Depth=1
	cmpl	$58, %ecx
	je	LBB14_40
## %bb.38:                              ##   in Loop: Header=BB14_36 Depth=1
	testl	%ecx, %ecx
	je	LBB14_10
## %bb.39:                              ##   in Loop: Header=BB14_36 Depth=1
	incq	%rax
	jmp	LBB14_36
LBB14_40:
	cmpq	$6, %rbx
	je	LBB14_12
LBB14_41:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB14_13
## %bb.42:                              ##   in Loop: Header=BB14_41 Depth=1
	cmpl	$58, %ecx
	je	LBB14_13
## %bb.43:                              ##   in Loop: Header=BB14_41 Depth=1
	testl	%ecx, %ecx
	je	LBB14_10
## %bb.44:                              ##   in Loop: Header=BB14_41 Depth=1
	incq	%rax
	jmp	LBB14_41
LBB14_54:
	callq	_status_hex_tuple_part.cold.2
LBB14_53:
	callq	_status_hex_tuple_part.cold.3
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_find_field
_status_find_field:                     ## @status_find_field
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	(%rdi), %rbx
	testq	%rbx, %rbx
	je	LBB15_6
## %bb.1:
	movq	%rsi, %r14
	movq	%rdi, %r12
	movq	%rsi, %rdi
	callq	_strlen
	movq	8(%r12), %r13
	movq	%r13, %r12
	subq	%rax, %r12
	jbe	LBB15_6
## %bb.2:
	movq	%rax, %r15
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%rax, %rdx
	callq	_memcmp
	testl	%eax, %eax
	jne	LBB15_4
## %bb.3:
	cmpb	$61, (%rbx,%r15)
	je	LBB15_14
LBB15_4:
	cmpq	$1, %r12
	jne	LBB15_8
LBB15_6:
	xorl	%r12d, %r12d
LBB15_15:
	movq	%r12, %rax
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB15_8:
	incq	%rbx
	decq	%r13
	xorl	%r12d, %r12d
	jmp	LBB15_10
	.p2align	4
LBB15_9:                                ##   in Loop: Header=BB15_10 Depth=1
	incq	%rbx
	decq	%r13
	cmpq	%r13, %r15
	je	LBB15_15
LBB15_10:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-1(%rbx), %eax
	cmpq	$32, %rax
	ja	LBB15_9
## %bb.11:                              ##   in Loop: Header=BB15_10 Depth=1
	movabsq	$4294976512, %rcx               ## imm = 0x100002400
	btq	%rax, %rcx
	jae	LBB15_9
## %bb.12:                              ##   in Loop: Header=BB15_10 Depth=1
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_memcmp
	testl	%eax, %eax
	jne	LBB15_9
## %bb.13:                              ##   in Loop: Header=BB15_10 Depth=1
	cmpb	$61, (%rbx,%r15)
	jne	LBB15_9
LBB15_14:
	leaq	(%rbx,%r15), %r12
	incq	%r12
	jmp	LBB15_15
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83
_parse_path83:                          ## @parse_path83
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$88, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rdx, -120(%rbp)                ## 8-byte Spill
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	testq	%rdi, %rdi
	je	LBB16_26
## %bb.1:
	movq	%rdi, %r12
	movzbl	(%rdi), %edx
	testb	%dl, %dl
	je	LBB16_26
## %bb.2:
	movq	%rcx, %r15
	movq	%rsi, %r14
	incq	%r12
	xorl	%eax, %eax
	movl	$11822, %ebx                    ## imm = 0x2E2E
	xorl	%ecx, %ecx
	jmp	LBB16_5
	.p2align	4
LBB16_3:                                ##   in Loop: Header=BB16_5 Depth=1
	xorl	%ecx, %ecx
LBB16_4:                                ##   in Loop: Header=BB16_5 Depth=1
	movzbl	(%r12), %edx
	incq	%r12
	testb	%dl, %dl
	je	LBB16_15
LBB16_5:                                ## =>This Inner Loop Header: Depth=1
	cmpb	$92, %dl
	je	LBB16_7
## %bb.6:                               ##   in Loop: Header=BB16_5 Depth=1
	movzbl	%dl, %esi
	cmpl	$47, %esi
	jne	LBB16_12
LBB16_7:                                ##   in Loop: Header=BB16_5 Depth=1
	testq	%rcx, %rcx
	je	LBB16_3
## %bb.8:                               ##   in Loop: Header=BB16_5 Depth=1
	movb	$0, -112(%rbp,%rcx)
	cmpq	%r15, %rax
	je	LBB16_23
## %bb.9:                               ##   in Loop: Header=BB16_5 Depth=1
	movl	-112(%rbp), %ecx
	xorl	%ebx, %ecx
	movzbl	-110(%rbp), %edx
	orw	%cx, %dx
	je	LBB16_24
## %bb.10:                              ##   in Loop: Header=BB16_5 Depth=1
	cmpw	$46, -112(%rbp)
	je	LBB16_3
## %bb.14:                              ##   in Loop: Header=BB16_5 Depth=1
	leaq	1(%rax), %r13
	leaq	(%rax,%rax,4), %rcx
	leaq	(%rax,%rcx,2), %rsi
	addq	%r14, %rsi
	leaq	-112(%rbp), %rdi
	callq	_fat83_from_display_component
	xorl	%ecx, %ecx
	movq	%r13, %rax
	jmp	LBB16_4
	.p2align	4
LBB16_12:                               ##   in Loop: Header=BB16_5 Depth=1
	leaq	1(%rcx), %rsi
	cmpq	$64, %rsi
	jae	LBB16_25
## %bb.13:                              ##   in Loop: Header=BB16_5 Depth=1
	movb	%dl, -112(%rbp,%rcx)
	movq	%rsi, %rcx
	jmp	LBB16_4
LBB16_15:
	testq	%rcx, %rcx
	je	LBB16_20
## %bb.16:
	movb	$0, -112(%rbp,%rcx)
	cmpq	%r15, %rax
	je	LBB16_29
## %bb.17:
	movl	$11822, %ecx                    ## imm = 0x2E2E
	xorl	-112(%rbp), %ecx
	movzbl	-110(%rbp), %edx
	orw	%cx, %dx
	je	LBB16_30
## %bb.18:
	cmpw	$46, -112(%rbp)
	je	LBB16_20
## %bb.19:
	leaq	1(%rax), %rbx
	leaq	(%rax,%rax,4), %rcx
	leaq	(%rax,%rcx,2), %rax
	addq	%rax, %r14
	leaq	-112(%rbp), %rdi
	movq	%r14, %rsi
	callq	_fat83_from_display_component
	movq	%rbx, %rax
LBB16_20:
	testq	%rax, %rax
	je	LBB16_27
## %bb.21:
	movq	-120(%rbp), %rcx                ## 8-byte Reload
	movq	%rax, (%rcx)
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB16_28
## %bb.22:
	addq	$88, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB16_23:
	callq	_parse_path83.cold.2
LBB16_24:
	callq	_parse_path83.cold.1
LBB16_25:
	callq	_parse_path83.cold.6
LBB16_26:
	callq	_parse_path83.cold.7
LBB16_27:
	callq	_parse_path83.cold.5
LBB16_28:
	callq	___stack_chk_fail
LBB16_29:
	callq	_parse_path83.cold.4
LBB16_30:
	callq	_parse_path83.cold.3
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component
_fat83_from_display_component:          ## @fat83_from_display_component
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rsi, %rbx
	movq	%rdi, %r12
	movabsq	$2314885530818453536, %rax      ## imm = 0x2020202020202020
	movq	%rax, (%rsi)
	movl	$538976288, 7(%rsi)             ## imm = 0x20202020
	movl	$46, %esi
	callq	_strchr
	movq	%rax, %r14
	testq	%rax, %rax
	je	LBB17_1
## %bb.3:
	movq	%r14, %r13
	subq	%r12, %r13
	leaq	1(%r14), %rdi
	movq	%rdi, -48(%rbp)                 ## 8-byte Spill
	callq	_strlen
	movq	%rax, %r15
	leaq	-9(%r13), %rax
	cmpq	$-8, %rax
	jb	LBB17_18
## %bb.4:
	cmpq	$4, %r15
	jae	LBB17_18
## %bb.5:
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	movl	$46, %esi
	callq	_strchr
	testq	%rax, %rax
	je	LBB17_6
## %bb.19:
	callq	_fat83_from_display_component.cold.1
LBB17_1:
	movq	%r12, %rdi
	callq	_strlen
	movq	%rax, %r13
	addq	$-9, %rax
	cmpq	$-8, %rax
	jb	LBB17_18
## %bb.2:
	xorl	%r15d, %r15d
LBB17_6:
	xorl	%eax, %eax
	jmp	LBB17_7
	.p2align	4
LBB17_10:                               ##   in Loop: Header=BB17_7 Depth=1
	movb	%cl, (%rbx,%rax)
	incq	%rax
	cmpq	%rax, %r13
	je	LBB17_11
LBB17_7:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%r12,%rax), %edx
	leal	-97(%rdx), %ecx
	leal	-32(%rdx), %esi
	cmpb	$26, %cl
	movzbl	%sil, %ecx
	cmovael	%edx, %ecx
	leal	-65(%rcx), %edx
	cmpb	$26, %dl
	setb	%dl
	leal	-48(%rcx), %esi
	cmpb	$10, %sil
	setb	%sil
	orb	%dl, %sil
	jne	LBB17_10
## %bb.8:                               ##   in Loop: Header=BB17_7 Depth=1
	cmpb	$45, %cl
	je	LBB17_10
## %bb.9:                               ##   in Loop: Header=BB17_7 Depth=1
	movzbl	%cl, %edx
	cmpl	$95, %edx
	je	LBB17_10
## %bb.21:
	callq	_fat83_from_display_component.cold.2
LBB17_11:
	testq	%r15, %r15
	je	LBB17_17
## %bb.12:
	xorl	%eax, %eax
	jmp	LBB17_13
	.p2align	4
LBB17_16:                               ##   in Loop: Header=BB17_13 Depth=1
	movb	%cl, 8(%rbx,%rax)
	incq	%rax
	cmpq	%rax, %r15
	je	LBB17_17
LBB17_13:                               ## =>This Inner Loop Header: Depth=1
	movzbl	1(%r14,%rax), %edx
	leal	-97(%rdx), %ecx
	leal	-32(%rdx), %esi
	cmpb	$26, %cl
	movzbl	%sil, %ecx
	cmovael	%edx, %ecx
	leal	-65(%rcx), %edx
	cmpb	$26, %dl
	setb	%dl
	leal	-48(%rcx), %esi
	cmpb	$10, %sil
	setb	%sil
	orb	%dl, %sil
	jne	LBB17_16
## %bb.14:                              ##   in Loop: Header=BB17_13 Depth=1
	cmpb	$45, %cl
	je	LBB17_16
## %bb.15:                              ##   in Loop: Header=BB17_13 Depth=1
	movzbl	%cl, %edx
	cmpl	$95, %edx
	je	LBB17_16
## %bb.20:
	callq	_fat83_from_display_component.cold.3
LBB17_17:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB17_18:
	callq	_fat83_from_display_component.cold.4
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump
_add_lump:                              ## @add_lump
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%r9, %r15
	movq	%r8, %r14
	movq	%rcx, -48(%rbp)                 ## 8-byte Spill
	movq	%rsi, %rbx
	movq	(%rsi), %r13
	movq	(%rdi), %rax
	cmpq	(%rdx), %r13
	jne	LBB18_3
## %bb.1:
	movq	%rdi, %r12
	leaq	(,%r13,2), %rcx
	testq	%r13, %r13
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, (%rdx)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB18_11
## %bb.2:
	movq	%rax, (%r12)
	movq	(%rbx), %r13
LBB18_3:
	movq	24(%rbp), %r12
	leaq	1(%r13), %rcx
	movq	%rcx, (%rbx)
	shlq	$4, %r13
	addq	%rax, %r13
	testq	%r12, %r12
	je	LBB18_4
## %bb.5:
	movl	(%r14), %eax
	jmp	LBB18_6
LBB18_4:
	xorl	%eax, %eax
LBB18_6:
	movl	%eax, (%r13)
	movl	%r12d, 4(%r13)
	movq	$0, 8(%r13)
	movq	%r15, %rdi
	callq	_strlen
	cmpq	$9, %rax
	jae	LBB18_12
## %bb.7:
	addq	$8, %r13
	movq	%r13, %rdi
	movq	%r15, %rsi
	movq	%rax, %rdx
	callq	_memcpy
	testq	%r12, %r12
	je	LBB18_10
## %bb.8:
	movl	(%r14), %eax
	leaq	(%r12,%rax), %rcx
	cmpq	$1048577, %rcx                  ## imm = 0x100001
	jae	LBB18_13
## %bb.9:
	movq	16(%rbp), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	addq	%rax, %rdi
	movq	%r12, %rdx
	callq	_memcpy
	addl	%r12d, (%r14)
LBB18_10:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB18_12:
	callq	_add_lump.cold.2
LBB18_13:
	callq	_add_lump.cold.1
LBB18_11:
	callq	_add_lump.cold.3
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.1
_main.cold.1:                           ## @main.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.2
_main.cold.2:                           ## @main.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.3
_main.cold.3:                           ## @main.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.123(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.4
_main.cold.4:                           ## @main.cold.4
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.122(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.5
_main.cold.5:                           ## @main.cold.5
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.6
_main.cold.6:                           ## @main.cold.6
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.7
_main.cold.7:                           ## @main.cold.7
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.106(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.8
_main.cold.8:                           ## @main.cold.8
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.108(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.9
_main.cold.9:                           ## @main.cold.9
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.18(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.10
_main.cold.10:                          ## @main.cold.10
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.120(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.11
_main.cold.11:                          ## @main.cold.11
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.105(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.12
_main.cold.12:                          ## @main.cold.12
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.104(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.13
_main.cold.13:                          ## @main.cold.13
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.14
_main.cold.14:                          ## @main.cold.14
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.15
_main.cold.15:                          ## @main.cold.15
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.16
_main.cold.16:                          ## @main.cold.16
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.17
_main.cold.17:                          ## @main.cold.17
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.20(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.18
_main.cold.18:                          ## @main.cold.18
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.21(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.19
_main.cold.19:                          ## @main.cold.19
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.132(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.20
_main.cold.20:                          ## @main.cold.20
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.133(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.21
_main.cold.21:                          ## @main.cold.21
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.140(%rip), %rsi
	leaq	L_.str.138(%rip), %rdx
	movl	$163840, %r8d                   ## imm = 0x28000
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.22
_main.cold.22:                          ## @main.cold.22
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.140(%rip), %rsi
	leaq	L_.str.137(%rip), %rdx
	movl	$8192, %r8d                     ## imm = 0x2000
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.23
_main.cold.23:                          ## @main.cold.23
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.24
_main.cold.24:                          ## @main.cold.24
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.25
_main.cold.25:                          ## @main.cold.25
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.134(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.26
_main.cold.26:                          ## @main.cold.26
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.229(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.27
_main.cold.27:                          ## @main.cold.27
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.135(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.28
_main.cold.28:                          ## @main.cold.28
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.29
_main.cold.29:                          ## @main.cold.29
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.225(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.30
_main.cold.30:                          ## @main.cold.30
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.31
_main.cold.31:                          ## @main.cold.31
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.225(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.32
_main.cold.32:                          ## @main.cold.32
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.33
_main.cold.33:                          ## @main.cold.33
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.225(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.34
_main.cold.34:                          ## @main.cold.34
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.35
_main.cold.35:                          ## @main.cold.35
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.225(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.36
_main.cold.36:                          ## @main.cold.36
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.37
_main.cold.37:                          ## @main.cold.37
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.225(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.38
_main.cold.38:                          ## @main.cold.38
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.160(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.39
_main.cold.39:                          ## @main.cold.39
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.40
_main.cold.40:                          ## @main.cold.40
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.41
_main.cold.41:                          ## @main.cold.41
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.42
_main.cold.42:                          ## @main.cold.42
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.43
_main.cold.43:                          ## @main.cold.43
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.44
_main.cold.44:                          ## @main.cold.44
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.45
_main.cold.45:                          ## @main.cold.45
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.46
_main.cold.46:                          ## @main.cold.46
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.47
_main.cold.47:                          ## @main.cold.47
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.161(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.48
_main.cold.48:                          ## @main.cold.48
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.49
_main.cold.49:                          ## @main.cold.49
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.50
_main.cold.50:                          ## @main.cold.50
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.51
_main.cold.51:                          ## @main.cold.51
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.52
_main.cold.52:                          ## @main.cold.52
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.53
_main.cold.53:                          ## @main.cold.53
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.54
_main.cold.54:                          ## @main.cold.54
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.60(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.55
_main.cold.55:                          ## @main.cold.55
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.61(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.56
_main.cold.56:                          ## @main.cold.56
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.63(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.57
_main.cold.57:                          ## @main.cold.57
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.62(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.58
_main.cold.58:                          ## @main.cold.58
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.70(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.59
_main.cold.59:                          ## @main.cold.59
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.71(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.60
_main.cold.60:                          ## @main.cold.60
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.73(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.61
_main.cold.61:                          ## @main.cold.61
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.74(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.62
_main.cold.62:                          ## @main.cold.62
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.77(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.63
_main.cold.63:                          ## @main.cold.63
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.76(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.64
_main.cold.64:                          ## @main.cold.64
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.79(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.65
_main.cold.65:                          ## @main.cold.65
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.72(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.66
_main.cold.66:                          ## @main.cold.66
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.80(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.67
_main.cold.67:                          ## @main.cold.67
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.89(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.68
_main.cold.68:                          ## @main.cold.68
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.91(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.69
_main.cold.69:                          ## @main.cold.69
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.46(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.70
_main.cold.70:                          ## @main.cold.70
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker.cold.1
_mutate_root_marker.cold.1:             ## @mutate_root_marker.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.33(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker.cold.2
_mutate_root_marker.cold.2:             ## @mutate_root_marker.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.34(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker.cold.3
_mutate_root_marker.cold.3:             ## @mutate_root_marker.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file.cold.1
_write_file.cold.1:                     ## @write_file.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -24
	movq	%rdi, %rbx
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_file.cold.1
_read_file.cold.1:                      ## @read_file.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_file.cold.2
_read_file.cold.2:                      ## @read_file.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -24
	movq	%rdi, %rbx
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_die_path
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path.cold.1
_write_file_path.cold.1:                ## @write_file_path.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.35(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path.cold.2
_write_file_path.cold.2:                ## @write_file_path.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.34(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path.cold.3
_write_file_path.cold.3:                ## @write_file_path.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path.cold.4
_write_file_path.cold.4:                ## @write_file_path.cold.4
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.1
_ensure_child_directory.cold.1:         ## @ensure_child_directory.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.34(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.2
_ensure_child_directory.cold.2:         ## @ensure_child_directory.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.3
_ensure_child_directory.cold.3:         ## @ensure_child_directory.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.34(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.4
_ensure_child_directory.cold.4:         ## @ensure_child_directory.cold.4
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.5
_ensure_child_directory.cold.5:         ## @ensure_child_directory.cold.5
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.6
_ensure_child_directory.cold.6:         ## @ensure_child_directory.cold.6
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.36(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain.cold.1
_write_cluster_chain.cold.1:            ## @write_cluster_chain.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.39(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain.cold.2
_write_cluster_chain.cold.2:            ## @write_cluster_chain.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.34(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain.cold.3
_write_cluster_chain.cold.3:            ## @write_cluster_chain.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.1
_check_write_status.cold.1:             ## @check_write_status.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.89(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.2
_check_write_status.cold.2:             ## @check_write_status.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.92(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.3
_check_write_status.cold.3:             ## @check_write_status.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.91(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.4
_check_write_status.cold.4:             ## @check_write_status.cold.4
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.91(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.5
_check_write_status.cold.5:             ## @check_write_status.cold.5
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.92(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.6
_check_write_status.cold.6:             ## @check_write_status.cold.6
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.92(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.7
_check_write_status.cold.7:             ## @check_write_status.cold.7
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.91(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.8
_check_write_status.cold.8:             ## @check_write_status.cold.8
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.91(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_dynamic_fat_status.cold.1
_check_dynamic_fat_status.cold.1:       ## @check_dynamic_fat_status.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.89(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_dynamic_fat_status.cold.2
_check_dynamic_fat_status.cold.2:       ## @check_dynamic_fat_status.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.91(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_root_file_blob.cold.1
_read_root_file_blob.cold.1:            ## @read_root_file_blob.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part.cold.1
_status_hex_tuple_part.cold.1:          ## @status_hex_tuple_part.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.90(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part.cold.2
_status_hex_tuple_part.cold.2:          ## @status_hex_tuple_part.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.91(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part.cold.3
_status_hex_tuple_part.cold.3:          ## @status_hex_tuple_part.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.89(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.1
_parse_path83.cold.1:                   ## @parse_path83.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.112(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.2
_parse_path83.cold.2:                   ## @parse_path83.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.110(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.3
_parse_path83.cold.3:                   ## @parse_path83.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.112(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.4
_parse_path83.cold.4:                   ## @parse_path83.cold.4
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.110(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.5
_parse_path83.cold.5:                   ## @parse_path83.cold.5
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.115(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.6
_parse_path83.cold.6:                   ## @parse_path83.cold.6
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.114(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.7
_parse_path83.cold.7:                   ## @parse_path83.cold.7
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.109(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.1
_fat83_from_display_component.cold.1:   ## @fat83_from_display_component.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.117(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.2
_fat83_from_display_component.cold.2:   ## @fat83_from_display_component.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.118(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.3
_fat83_from_display_component.cold.3:   ## @fat83_from_display_component.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.119(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.4
_fat83_from_display_component.cold.4:   ## @fat83_from_display_component.cold.4
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.116(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump.cold.1
_add_lump.cold.1:                       ## @add_lump.cold.1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.204(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump.cold.2
_add_lump.cold.2:                       ## @add_lump.cold.2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.161(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump.cold.3
_add_lump.cold.3:                       ## @add_lump.cold.3
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	L_.str.22(%rip), %rdi
	callq	_die
	.cfi_endproc
                                        ## -- End function
	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"--write-root-marker"

L_.str.1:                               ## @.str.1
	.asciz	"--delete-root-marker"

L_.str.2:                               ## @.str.2
	.space	1

L_.str.3:                               ## @.str.3
	.asciz	"--check-persistence"

L_.str.4:                               ## @.str.4
	.asciz	"--baseline-image"

L_.str.5:                               ## @.str.5
	.asciz	"--reboot-baseline-image"

L_.str.6:                               ## @.str.6
	.asciz	"--write-status"

L_.str.7:                               ## @.str.7
	.asciz	"--save-write-status"

L_.str.8:                               ## @.str.8
	.asciz	"--load-status"

L_.str.9:                               ## @.str.9
	.asciz	"--reboot-status"

L_.str.10:                              ## @.str.10
	.asciz	"--require-default"

L_.str.11:                              ## @.str.11
	.asciz	"--require-dynamic-fat-proof"

L_.str.12:                              ## @.str.12
	.asciz	"--require-save-slot"

L_.str.13:                              ## @.str.13
	.asciz	"--require-save-description"

L_.str.14:                              ## @.str.14
	.asciz	"--primary-asset-wad"

L_.str.15:                              ## @.str.15
	.asciz	"--wad"

L_.str.16:                              ## @.str.16
	.asciz	"--inspect"

L_.str.17:                              ## @.str.17
	.asciz	"--root-elf"

L_.str.18:                              ## @.str.18
	.asciz	"duplicate --root-elf entry"

L_.str.19:                              ## @.str.19
	.asciz	"--asset"

L_.str.20:                              ## @.str.20
	.asciz	"duplicate --root-elf FAT16 name"

	.section	__TEXT,__const
_LEGACY_APP_ELF_NAME:               ## @LEGACY_APP_ELF_NAME
	.asciz	"APP     ELF"

	.section	__TEXT,__cstring,cstring_literals
L_.str.21:                              ## @.str.21
	.asciz	"legacy payload ELF conflicts with --root-elf"

L_.str.22:                              ## @.str.22
	.asciz	"out of memory"

L_.str.23:                              ## @.str.23
	.asciz	"unexpected disk image size"

L_.str.24:                              ## @.str.24
	.asciz	"rb"

L_.str.25:                              ## @.str.25
	.asciz	"seek failed"

L_.str.26:                              ## @.str.26
	.asciz	"tell failed"

L_.str.27:                              ## @.str.27
	.asciz	"read failed"

L_.str.28:                              ## @.str.28
	.asciz	"make_wad_image: %s: %s\n"

L_.str.29:                              ## @.str.29
	.asciz	"read past end"

L_.str.30:                              ## @.str.30
	.asciz	"PERSISTENCE_CHECKPOINT_NAME"

	.section	__TEXT,__const
_PERSISTENCE_CHECKPOINT_NAME:           ## @PERSISTENCE_CHECKPOINT_NAME
	.asciz	"PERSIST CHK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.31:                              ## @.str.31
	.asciz	"SAVE_REQUEST_NAME"

	.section	__TEXT,__const
_SAVE_REQUEST_NAME:                     ## @SAVE_REQUEST_NAME
	.asciz	"SAVEREQ CHK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.32:                              ## @.str.32
	.asciz	"LOAD_REQUEST_NAME"

	.section	__TEXT,__const
_LOAD_REQUEST_NAME:                     ## @LOAD_REQUEST_NAME
	.asciz	"LOADREQ CHK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.33:                              ## @.str.33
	.asciz	"unknown root marker symbol"

L_.str.34:                              ## @.str.34
	.asciz	"cluster outside FAT16 data area"

L_.str.35:                              ## @.str.35
	.asciz	"FAT16 file path is empty"

L_.str.36:                              ## @.str.36
	.asciz	"FAT16 path component exists but is not a directory"

L_.str.37:                              ## @.str.37
	.asciz	".          "

L_.str.38:                              ## @.str.38
	.asciz	"..         "

L_.str.39:                              ## @.str.39
	.asciz	"file does not fit in FAT16 data area"

L_.str.40:                              ## @.str.40
	.asciz	"FAT16 directory is full"

L_.str.41:                              ## @.str.41
	.asciz	"write past end"

L_.str.42:                              ## @.str.42
	.asciz	"usage: make_wad_image [--inspect IMAGE] [--primary-asset-wad PATH|--wad PATH] [--root-elf NAME.ELF=PATH] [--asset IMAGE_8.3_PATH=HOST_PATH] OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF [LEGACY_APP_ELF]]]\n       make_wad_image --write-root-marker SYMBOL PAYLOAD IMAGE\n       make_wad_image --delete-root-marker SYMBOL IMAGE\n       make_wad_image --check-persistence IMAGE [--baseline-image IMAGE] [--reboot-baseline-image IMAGE] [--write-status FILE] [--save-write-status FILE] [--load-status FILE] [--reboot-status FILE] [--require-default] [--require-dynamic-fat-proof] [--require-save-slot N] [--require-save-description N=TEXT]"

L_.str.43:                              ## @.str.43
	.asciz	"--require-save-slot expects slot 0..5"

L_.str.44:                              ## @.str.44
	.asciz	"too many save slots requested"

L_.str.45:                              ## @.str.45
	.asciz	"--require-save-description expects SLOT=TEXT with slot 0..5"

L_.str.46:                              ## @.str.46
	.asciz	"dynamic FAT proof was requested without a write status file"

L_.str.48:                              ## @.str.48
	.asciz	"image=%s\n"

L_.str.49:                              ## @.str.49
	.asciz	"default_cfg=%s\n"

L_.str.50:                              ## @.str.50
	.asciz	"checked"

L_.str.51:                              ## @.str.51
	.asciz	"not-requested"

L_.str.52:                              ## @.str.52
	.asciz	"save_slot_%d=checked\n"

L_.str.54:                              ## @.str.54
	.asciz	"unexpected image size"

L_.str.55:                              ## @.str.55
	.asciz	"missing MBR signature"

L_.str.56:                              ## @.str.56
	.asciz	"unexpected partition layout"

L_.str.57:                              ## @.str.57
	.asciz	"missing FAT boot signature"

L_.str.58:                              ## @.str.58
	.asciz	"unexpected FAT bytes per sector"

L_.str.59:                              ## @.str.59
	.asciz	"unexpected FAT sectors per cluster"

	.section	__TEXT,__const
_DEFAULT_CFG_NAME:                      ## @DEFAULT_CFG_NAME
	.asciz	"DEFAULT CFG"

	.section	__TEXT,__cstring,cstring_literals
L_.str.60:                              ## @.str.60
	.asciz	"DEFAULT.CFG is missing from the FAT root"

L_.str.61:                              ## @.str.61
	.asciz	"DEFAULT.CFG is a directory"

L_.str.62:                              ## @.str.62
	.asciz	"DEFAULT.CFG was not written"

L_.str.63:                              ## @.str.63
	.asciz	"DEFAULT.CFG did not change from the persistence baseline"

L_.str.64:                              ## @.str.64
	.asciz	"left image"

L_.str.65:                              ## @.str.65
	.asciz	"right image"

L_.str.66:                              ## @.str.66
	.asciz	"file has invalid first cluster"

L_.str.67:                              ## @.str.67
	.asciz	"file cluster chain is invalid"

L_.str.68:                              ## @.str.68
	.asciz	"file cluster chain ended early"

L_.str.70:                              ## @.str.70
	.asciz	"required save slot is missing from the FAT root"

L_.str.71:                              ## @.str.71
	.asciz	"required save slot is a directory"

L_.str.72:                              ## @.str.72
	.asciz	"required save slot is too small to prove persistence"

L_.str.73:                              ## @.str.73
	.asciz	"required save slot did not change from the persistence baseline"

L_.str.74:                              ## @.str.74
	.asciz	"required save slot changed across reboot/load proof"

L_.str.75:                              ## @.str.75
	.asciz	"save slot"

L_.str.76:                              ## @.str.76
	.asciz	"required save description is longer than Doom's save title field"

L_.str.77:                              ## @.str.77
	.asciz	"required save slot does not contain the requested description"

L_.str.78:                              ## @.str.78
	.asciz	"version "

L_.str.79:                              ## @.str.79
	.asciz	"required save slot does not contain the expected version header"

L_.str.80:                              ## @.str.80
	.asciz	"save slot must be 0..5"

_PRIMARY_SAVE_SLOT_TEMPLATE_NAME:       ## @PRIMARY_SAVE_SLOT_TEMPLATE_NAME
	.asciz	"DOOMSAV DSG"

L_.str.81:                              ## @.str.81
	.asciz	"savewr"

L_.str.82:                              ## @.str.82
	.asciz	"save write status did not prove save slot bytes and calls"

L_.str.83:                              ## @.str.83
	.asciz	"saveclose"

L_.str.84:                              ## @.str.84
	.asciz	"save write status did not prove close"

L_.str.85:                              ## @.str.85
	.asciz	"doomwrite"

L_.str.86:                              ## @.str.86
	.asciz	"write status did not prove file writes"

L_.str.87:                              ## @.str.87
	.asciz	"doomclose"

L_.str.88:                              ## @.str.88
	.asciz	"write status did not prove closes"

L_.str.89:                              ## @.str.89
	.asciz	"required status tuple is missing"

L_.str.90:                              ## @.str.90
	.asciz	"status tuple has too few parts"

L_.str.91:                              ## @.str.91
	.asciz	"status field did not contain a hex value"

L_.str.92:                              ## @.str.92
	.asciz	"required status field is missing"

L_.str.93:                              ## @.str.93
	.asciz	"gameplay=OK"

L_.str.94:                              ## @.str.94
	.asciz	"load status did not return to gameplay"

L_.str.95:                              ## @.str.95
	.asciz	"saverd"

L_.str.96:                              ## @.str.96
	.asciz	"load status did not prove save slot reads"

L_.str.97:                              ## @.str.97
	.asciz	"panic="

L_.str.98:                              ## @.str.98
	.asciz	"panic=NONE"

L_.str.99:                              ## @.str.99
	.asciz	"load status reported a panic"

L_.str.100:                             ## @.str.100
	.asciz	"reboot status did not return to gameplay"

L_.str.101:                             ## @.str.101
	.asciz	"reboot status reported a panic"

L_.str.102:                             ## @.str.102
	.asciz	"fatdyn"

L_.str.103:                             ## @.str.103
	.asciz	"fatdyn status did not prove dynamic FAT activity"

L_.str.104:                             ## @.str.104
	.asciz	"--root-elf must be NAME.ELF=PATH"

L_.str.105:                             ## @.str.105
	.asciz	"--root-elf display name is too long"

L_.str.106:                             ## @.str.106
	.asciz	"--root-elf must be a root-level NAME.ELF"

L_.str.107:                             ## @.str.107
	.asciz	"ELF"

L_.str.108:                             ## @.str.108
	.asciz	"--root-elf name must use .ELF"

L_.str.109:                             ## @.str.109
	.asciz	"FAT16 path must not be empty"

L_.str.110:                             ## @.str.110
	.asciz	"FAT16 path is too deep"

L_.str.111:                             ## @.str.111
	.asciz	".."

L_.str.112:                             ## @.str.112
	.asciz	"FAT16 path must not use dot traversal"

L_.str.114:                             ## @.str.114
	.asciz	"FAT16 path component is too long"

L_.str.115:                             ## @.str.115
	.asciz	"FAT16 path must name at least one component"

L_.str.116:                             ## @.str.116
	.asciz	"FAT16 path component must fit 8.3"

L_.str.117:                             ## @.str.117
	.asciz	"FAT16 path component has too many dots"

L_.str.118:                             ## @.str.118
	.asciz	"FAT16 path component has unsupported characters"

L_.str.119:                             ## @.str.119
	.asciz	"FAT16 extension has unsupported characters"

	.section	__TEXT,__const
_PRIMARY_ASSET_WAD_NAME:                ## @PRIMARY_ASSET_WAD_NAME
	.asciz	"DOOM1   WAD"

_KERNEL_ELF_NAME:                       ## @KERNEL_ELF_NAME
	.asciz	"KERNEL  ELF"

_USER_PROBE_NAME:                       ## @USER_PROBE_NAME
	.asciz	"USERPROBELF"

	.section	__TEXT,__cstring,cstring_literals
L_.str.120:                             ## @.str.120
	.asciz	"--root-elf tries to replace a protected boot entry"

L_.str.121:                             ## @.str.121
	.asciz	"make_wad_image: %s\n"

L_.str.122:                             ## @.str.122
	.asciz	"--asset must be IMAGE_8.3_PATH=HOST_PATH"

L_.str.123:                             ## @.str.123
	.asciz	"--asset display path is too long"

L_.str.125:                             ## @.str.125
	.asciz	"image_size=%zu\n"

L_.str.126:                             ## @.str.126
	.asciz	"partition_lba=%u\n"

L_.str.127:                             ## @.str.127
	.asciz	"partition_sectors=%u\n"

L_.str.128:                             ## @.str.128
	.asciz	"root_lba=%u\n"

L_.str.129:                             ## @.str.129
	.asciz	"data_lba=%u\n"

L_.str.130:                             ## @.str.130
	.asciz	"data_clusters=%u\n"

L_.str.131:                             ## @.str.131
	.asciz	"root[%u]=%s attr=0x%02X cluster=%u size=%u\n"

L_.str.132:                             ## @.str.132
	.asciz	"stage1, stage2, and kernel paths must be provided together"

L_.str.133:                             ## @.str.133
	.asciz	"legacy positional app ELF packaging requires a user probe ELF path"

L_.str.134:                             ## @.str.134
	.asciz	"primary WAD asset (DOOM1.WAD) must start at cluster 2"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @DEFAULT_CFG_CONTENT
_DEFAULT_CFG_CONTENT:
	.asciz	"screenblocks\t\t11\n"

	.section	__TEXT,__cstring,cstring_literals
L_.str.135:                             ## @.str.135
	.asciz	"FAT16 image does not leave enough OS-created file headroom"

L_.str.136:                             ## @.str.136
	.asciz	"stage1 must be exactly 512 bytes"

L_.str.137:                             ## @.str.137
	.asciz	"stage2"

L_.str.138:                             ## @.str.138
	.asciz	"kernel"

_FAT_VOLUME_LABEL:                      ## @FAT_VOLUME_LABEL
	.asciz	"VIBEOS WAD "

L_.str.140:                             ## @.str.140
	.asciz	"make_wad_image: %s is %zu bytes, exceeds %zu bytes\n"

L_.str.141:                             ## @.str.141
	.asciz	"WAD exceeds primary asset load limit"

L_.str.142:                             ## @.str.142
	.asciz	"too small to be a WAD"

L_.str.143:                             ## @.str.143
	.asciz	"IWAD"

L_.str.144:                             ## @.str.144
	.asciz	"PWAD"

L_.str.145:                             ## @.str.145
	.asciz	"does not start with IWAD or PWAD"

L_.str.146:                             ## @.str.146
	.asciz	"WAD directory is outside the file"

L_.str.147:                             ## @.str.147
	.asciz	"PLAYPAL"

L_.str.148:                             ## @.str.148
	.asciz	"COLORMAP"

L_.str.149:                             ## @.str.149
	.asciz	"PNAMES"

L_.str.150:                             ## @.str.150
	.asciz	"TEXTURE1"

L_.str.151:                             ## @.str.151
	.asciz	"F_START"

L_.str.152:                             ## @.str.152
	.asciz	"F_SKY1"

L_.str.153:                             ## @.str.153
	.asciz	"F_END"

L_.str.154:                             ## @.str.154
	.asciz	"S_START"

L_.str.155:                             ## @.str.155
	.asciz	"S_END"

L_.str.156:                             ## @.str.156
	.asciz	"SYNTHPCH"

L_.str.157:                             ## @.str.157
	.asciz	"D_INTRO"

L_.str.159:                             ## @.str.159
	.asciz	"THINGS"

L_.str.160:                             ## @.str.160
	.asciz	"generated WAD directory overflow"

	.p2align	4, 0x0                          ## @__const.build_generated_wad.pattern
L___const.build_generated_wad.pattern:
	.asciz	"vibe-os hard-path IDE FAT16 WAD fixture\n"

L_.str.161:                             ## @.str.161
	.asciz	"WAD lump name too long"

	.section	__DATA,__const
	.p2align	4, 0x0                          ## @switch_textures
_switch_textures:
	.quad	L_.str.162
	.quad	L_.str.163
	.quad	L_.str.164
	.quad	L_.str.165
	.quad	L_.str.166
	.quad	L_.str.167
	.quad	L_.str.168
	.quad	L_.str.169
	.quad	L_.str.170
	.quad	L_.str.171
	.quad	L_.str.172
	.quad	L_.str.173
	.quad	L_.str.174
	.quad	L_.str.175
	.quad	L_.str.176
	.quad	L_.str.177
	.quad	L_.str.178
	.quad	L_.str.179
	.quad	L_.str.180
	.quad	L_.str.181
	.quad	L_.str.182
	.quad	L_.str.183
	.quad	L_.str.184
	.quad	L_.str.185
	.quad	L_.str.186
	.quad	L_.str.187
	.quad	L_.str.188
	.quad	L_.str.189
	.quad	L_.str.190
	.quad	L_.str.191
	.quad	L_.str.192
	.quad	L_.str.193
	.quad	L_.str.194
	.quad	L_.str.195
	.quad	L_.str.196
	.quad	L_.str.197
	.quad	L_.str.198
	.quad	L_.str.199
	.quad	L_.str.200
	.quad	L_.str.201
	.quad	L_.str.202
	.quad	L_.str.203

	.section	__TEXT,__cstring,cstring_literals
L_.str.162:                             ## @.str.162
	.asciz	"SW1BRCOM"

L_.str.163:                             ## @.str.163
	.asciz	"SW2BRCOM"

L_.str.164:                             ## @.str.164
	.asciz	"SW1BRN1"

L_.str.165:                             ## @.str.165
	.asciz	"SW2BRN1"

L_.str.166:                             ## @.str.166
	.asciz	"SW1BRN2"

L_.str.167:                             ## @.str.167
	.asciz	"SW2BRN2"

L_.str.168:                             ## @.str.168
	.asciz	"SW1BRNGN"

L_.str.169:                             ## @.str.169
	.asciz	"SW2BRNGN"

L_.str.170:                             ## @.str.170
	.asciz	"SW1BROWN"

L_.str.171:                             ## @.str.171
	.asciz	"SW2BROWN"

L_.str.172:                             ## @.str.172
	.asciz	"SW1COMM"

L_.str.173:                             ## @.str.173
	.asciz	"SW2COMM"

L_.str.174:                             ## @.str.174
	.asciz	"SW1COMP"

L_.str.175:                             ## @.str.175
	.asciz	"SW2COMP"

L_.str.176:                             ## @.str.176
	.asciz	"SW1DIRT"

L_.str.177:                             ## @.str.177
	.asciz	"SW2DIRT"

L_.str.178:                             ## @.str.178
	.asciz	"SW1EXIT"

L_.str.179:                             ## @.str.179
	.asciz	"SW2EXIT"

L_.str.180:                             ## @.str.180
	.asciz	"SW1GRAY"

L_.str.181:                             ## @.str.181
	.asciz	"SW2GRAY"

L_.str.182:                             ## @.str.182
	.asciz	"SW1GRAY1"

L_.str.183:                             ## @.str.183
	.asciz	"SW2GRAY1"

L_.str.184:                             ## @.str.184
	.asciz	"SW1METAL"

L_.str.185:                             ## @.str.185
	.asciz	"SW2METAL"

L_.str.186:                             ## @.str.186
	.asciz	"SW1PIPE"

L_.str.187:                             ## @.str.187
	.asciz	"SW2PIPE"

L_.str.188:                             ## @.str.188
	.asciz	"SW1SLAD"

L_.str.189:                             ## @.str.189
	.asciz	"SW2SLAD"

L_.str.190:                             ## @.str.190
	.asciz	"SW1STARG"

L_.str.191:                             ## @.str.191
	.asciz	"SW2STARG"

L_.str.192:                             ## @.str.192
	.asciz	"SW1STON1"

L_.str.193:                             ## @.str.193
	.asciz	"SW2STON1"

L_.str.194:                             ## @.str.194
	.asciz	"SW1STON2"

L_.str.195:                             ## @.str.195
	.asciz	"SW2STON2"

L_.str.196:                             ## @.str.196
	.asciz	"SW1STONE"

L_.str.197:                             ## @.str.197
	.asciz	"SW2STONE"

L_.str.198:                             ## @.str.198
	.asciz	"SW1STRTN"

L_.str.199:                             ## @.str.199
	.asciz	"SW2STRTN"

L_.str.200:                             ## @.str.200
	.asciz	"SKY1"

L_.str.201:                             ## @.str.201
	.asciz	"SKY2"

L_.str.202:                             ## @.str.202
	.asciz	"SKY3"

L_.str.203:                             ## @.str.203
	.asciz	"SKY4"

L_.str.204:                             ## @.str.204
	.asciz	"generated WAD fixture overflow"

L_.str.205:                             ## @.str.205
	.asciz	"STCFN%03d"

L_.str.206:                             ## @.str.206
	.asciz	"STTNUM%d"

L_.str.207:                             ## @.str.207
	.asciz	"STYSNUM%d"

L_.str.208:                             ## @.str.208
	.asciz	"STTPRCNT"

L_.str.209:                             ## @.str.209
	.asciz	"STKEYS%d"

L_.str.210:                             ## @.str.210
	.asciz	"STARMS"

L_.str.211:                             ## @.str.211
	.asciz	"STGNUM%d"

L_.str.212:                             ## @.str.212
	.asciz	"STFB0"

L_.str.213:                             ## @.str.213
	.asciz	"STBAR"

L_.str.214:                             ## @.str.214
	.asciz	"STFST%d%d"

L_.str.215:                             ## @.str.215
	.asciz	"STFTR%d0"

L_.str.216:                             ## @.str.216
	.asciz	"STFTL%d0"

L_.str.217:                             ## @.str.217
	.asciz	"STFOUCH%d"

L_.str.218:                             ## @.str.218
	.asciz	"STFEVL%d"

L_.str.219:                             ## @.str.219
	.asciz	"STFKILL%d"

L_.str.220:                             ## @.str.220
	.asciz	"STFGOD0"

L_.str.221:                             ## @.str.221
	.asciz	"STFDEAD0"

L_.str.222:                             ## @.str.222
	.asciz	"TITLEPIC"

L_.str.223:                             ## @.str.223
	.asciz	"CREDIT"

L_.str.224:                             ## @.str.224
	.asciz	"HELP2"

L_.str.225:                             ## @.str.225
	.asciz	"FAT16 root directory is full"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @package_default_assets.readme
_package_default_assets.readme:
	.asciz	"vibe-os FAT16 one-level asset file\n"

	.p2align	4, 0x0                          ## @package_default_assets.map
_package_default_assets.map:
	.asciz	"name=E1M1\nmusic=D_E1M1\n"

	.section	__TEXT,__cstring,cstring_literals
_STATE_DIR_NAME:                        ## @STATE_DIR_NAME
	.asciz	"STATE      "

L_.str.226:                             ## @.str.226
	.asciz	"/assets/readme.txt"

L_.str.227:                             ## @.str.227
	.asciz	"/assets/maps/e1m1.map"

L_.str.228:                             ## @.str.228
	.asciz	"/assets/textures/pal0.bin"

L_.str.229:                             ## @.str.229
	.asciz	"--asset path must include a directory component"

L_.str.230:                             ## @.str.230
	.asciz	"wb"

L_.str.231:                             ## @.str.231
	.asciz	"write failed"

L_str:                                  ## @str
	.asciz	"schema=vibe-os-c-persistence-proof-v1"

L_str.232:                              ## @str.232
	.asciz	"result=ok"

L_str.233:                              ## @str.233
	.asciz	"schema=vibe-os-c-image-inspect-v1"

.subsections_via_symbols
