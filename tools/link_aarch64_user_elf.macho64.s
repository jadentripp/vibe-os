	.build_version macos, 26, 0	sdk_version 26, 5
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main                           ## -- Begin function main
	.p2align	4
_main:                                  ## @main
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$472, %rsp                      ## imm = 0x1D8
	movq	%rsi, %rbx
	movl	%edi, %r14d
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	movslq	%edi, %rdi
	movl	$8, %esi
	callq	_calloc
	movq	%rax, -232(%rbp)                ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_505
## %bb.1:
	cmpl	$2, %r14d
	jl	LBB0_120
## %bb.2:
	movl	$15204352, %r13d                ## imm = 0xE80000
	movl	$1, %r15d
	movq	$0, -208(%rbp)                  ## 8-byte Folded Spill
	movq	$0, -216(%rbp)                  ## 8-byte Folded Spill
	jmp	LBB0_6
	.p2align	4
LBB0_3:                                 ##   in Loop: Header=BB0_6 Depth=1
	movq	%r12, %rdi
	leaq	L_.str.2(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_10
## %bb.4:                               ##   in Loop: Header=BB0_6 Depth=1
	movq	-232(%rbp), %rax                ## 8-byte Reload
	movq	-216(%rbp), %rcx                ## 8-byte Reload
	movq	%r12, (%rax,%rcx,8)
	incq	%rcx
	movq	%rcx, -216(%rbp)                ## 8-byte Spill
LBB0_5:                                 ##   in Loop: Header=BB0_6 Depth=1
	incl	%r15d
	cmpl	%r14d, %r15d
	jge	LBB0_16
LBB0_6:                                 ## =>This Inner Loop Header: Depth=1
	movslq	%r15d, %rax
	movq	(%rbx,%rax,8), %r12
	cmpb	$45, (%r12)
	jne	LBB0_3
## %bb.7:                               ##   in Loop: Header=BB0_6 Depth=1
	cmpb	$111, 1(%r12)
	jne	LBB0_9
## %bb.8:                               ##   in Loop: Header=BB0_6 Depth=1
	cmpb	$0, 2(%r12)
	je	LBB0_14
LBB0_9:                                 ##   in Loop: Header=BB0_6 Depth=1
	movq	%r12, %rdi
	leaq	L_.str.2(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_174
LBB0_10:                                ##   in Loop: Header=BB0_6 Depth=1
	incl	%r15d
	cmpl	%r14d, %r15d
	jge	LBB0_464
## %bb.11:                              ##   in Loop: Header=BB0_6 Depth=1
	movslq	%r15d, %rax
	movq	(%rbx,%rax,8), %r12
	movq	$0, -488(%rbp)
	callq	___error
	movl	$0, (%rax)
	movq	%r12, %rdi
	leaq	-488(%rbp), %rsi
	xorl	%edx, %edx
	callq	_strtoull
	movq	%rax, %r13
	callq	___error
	cmpl	$0, (%rax)
	jne	LBB0_455
## %bb.12:                              ##   in Loop: Header=BB0_6 Depth=1
	movq	-488(%rbp), %rax
	testq	%rax, %rax
	je	LBB0_455
## %bb.13:                              ##   in Loop: Header=BB0_6 Depth=1
	cmpb	$0, (%rax)
	je	LBB0_5
	jmp	LBB0_455
LBB0_14:                                ##   in Loop: Header=BB0_6 Depth=1
	incl	%r15d
	cmpl	%r14d, %r15d
	jge	LBB0_504
## %bb.15:                              ##   in Loop: Header=BB0_6 Depth=1
	movslq	%r15d, %rax
	movq	(%rbx,%rax,8), %rax
	movq	%rax, -208(%rbp)                ## 8-byte Spill
	jmp	LBB0_5
LBB0_16:
	cmpq	$0, -208(%rbp)                  ## 8-byte Folded Reload
	setne	%al
	movq	-216(%rbp), %rdi                ## 8-byte Reload
	testq	%rdi, %rdi
	setne	%cl
	testb	%cl, %al
	je	LBB0_120
## %bb.17:
	xorps	%xmm0, %xmm0
	movups	%xmm0, -376(%rbp)
	movups	%xmm0, -360(%rbp)
	movups	%xmm0, -392(%rbp)
	movups	%xmm0, -408(%rbp)
	movups	%xmm0, -424(%rbp)
	movups	%xmm0, -440(%rbp)
	movups	%xmm0, -456(%rbp)
	movups	%xmm0, -472(%rbp)
	movq	$0, -344(%rbp)
	movq	%r13, -376(%rbp)
	movq	%rdi, -480(%rbp)
	movl	$56, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_515
## %bb.18:
	movq	%rax, %rbx
	movq	%rax, -488(%rbp)
	xorl	%r14d, %r14d
	movq	%rax, -192(%rbp)                ## 8-byte Spill
	jmp	LBB0_20
	.p2align	4
LBB0_19:                                ##   in Loop: Header=BB0_20 Depth=1
	movq	-224(%rbp), %r14                ## 8-byte Reload
	incq	%r14
	cmpq	-216(%rbp), %r14                ## 8-byte Folded Reload
	movq	-192(%rbp), %rbx                ## 8-byte Reload
	je	LBB0_124
LBB0_20:                                ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_47 Depth 2
                                        ##     Child Loop BB0_92 Depth 2
                                        ##     Child Loop BB0_105 Depth 2
	imulq	$56, %r14, %r12
	movq	-232(%rbp), %rax                ## 8-byte Reload
	movq	(%rax,%r14,8), %rdi
	movq	%rdi, (%rbx,%r12)
	movq	%rdi, -72(%rbp)                 ## 8-byte Spill
	leaq	L_.str.9(%rip), %rsi
	callq	_fopen
	testq	%rax, %rax
	je	LBB0_465
## %bb.21:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%rax, %r15
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$2, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB0_457
## %bb.22:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%r15, %rdi
	callq	_ftell
	movq	%rax, -120(%rbp)                ## 8-byte Spill
	testq	%rax, %rax
	js	LBB0_466
## %bb.23:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%r15, %rdi
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB0_457
## %bb.24:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%r12, %rbx
	movq	-120(%rbp), %r12                ## 8-byte Reload
	cmpq	$1, %r12
	movq	%r12, %rdi
	adcq	$0, %rdi
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_467
## %bb.25:                              ##   in Loop: Header=BB0_20 Depth=1
	testq	%r12, %r12
	movq	%rax, %r13
	je	LBB0_27
## %bb.26:                              ##   in Loop: Header=BB0_20 Depth=1
	movl	$1, %esi
	movq	%r13, %rdi
	movq	%r12, %rdx
	movq	%r15, %rcx
	callq	_fread
	cmpq	%r12, %rax
	jne	LBB0_487
LBB0_27:                                ##   in Loop: Header=BB0_20 Depth=1
	addq	-192(%rbp), %rbx                ## 8-byte Folded Reload
	movq	%r15, %rdi
	callq	_fclose
	movq	%r12, 16(%rbx)
	movq	%rbx, -128(%rbp)                ## 8-byte Spill
	movq	%r13, 8(%rbx)
	cmpq	$64, %r12
	jb	LBB0_456
## %bb.28:                              ##   in Loop: Header=BB0_20 Depth=1
	cmpl	$1179403647, (%r13)             ## imm = 0x464C457F
	jne	LBB0_456
## %bb.29:                              ##   in Loop: Header=BB0_20 Depth=1
	cmpb	$2, 4(%r13)
	jne	LBB0_459
## %bb.30:                              ##   in Loop: Header=BB0_20 Depth=1
	cmpb	$1, 5(%r13)
	jne	LBB0_459
## %bb.31:                              ##   in Loop: Header=BB0_20 Depth=1
	cmpw	$1, 16(%r13)
	jne	LBB0_458
## %bb.32:                              ##   in Loop: Header=BB0_20 Depth=1
	cmpw	$183, 18(%r13)
	jne	LBB0_458
## %bb.33:                              ##   in Loop: Header=BB0_20 Depth=1
	movzwl	58(%r13), %r8d
	cmpq	$63, %r8
	jbe	LBB0_468
## %bb.34:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%r14, -224(%rbp)                ## 8-byte Spill
	movzwl	60(%r13), %edi
	movzwl	62(%r13), %eax
	cmpw	%di, %ax
	jae	LBB0_472
## %bb.35:                              ##   in Loop: Header=BB0_20 Depth=1
	movl	40(%r13), %r12d
	movl	44(%r13), %r15d
	shlq	$32, %r15
	leaq	(%r15,%r12), %rcx
	movq	-120(%rbp), %r14                ## 8-byte Reload
	movq	%r14, %rdx
	subq	%rcx, %rdx
	jb	LBB0_469
## %bb.36:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%rdi, %rsi
	imulq	%r8, %rsi
	cmpq	%rdx, %rsi
	ja	LBB0_469
## %bb.37:                              ##   in Loop: Header=BB0_20 Depth=1
	imulq	%r8, %rax
	leaq	(%rax,%rcx), %rsi
	addq	$24, %rsi
	movq	%r14, %rdx
	subq	%rsi, %rdx
	jb	LBB0_470
## %bb.38:                              ##   in Loop: Header=BB0_20 Depth=1
	cmpq	$3, %rdx
	jbe	LBB0_470
## %bb.39:                              ##   in Loop: Header=BB0_20 Depth=1
	addq	%rcx, %rax
	movq	%r14, %rcx
	subq	%rax, %rcx
	addq	$-28, %rcx
	cmpq	$3, %rcx
	jbe	LBB0_471
## %bb.40:                              ##   in Loop: Header=BB0_20 Depth=1
	leaq	32(%rax), %rcx
	movq	%r14, %rdx
	subq	%rcx, %rdx
	cmpq	$3, %rdx
	jbe	LBB0_473
## %bb.41:                              ##   in Loop: Header=BB0_20 Depth=1
	leaq	36(%rax), %rdx
	movq	%r14, %rsi
	subq	%rdx, %rsi
	cmpq	$3, %rsi
	jbe	LBB0_474
## %bb.42:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%r8, -200(%rbp)                 ## 8-byte Spill
	movq	%rdi, -176(%rbp)                ## 8-byte Spill
	movq	24(%r13,%rax), %rsi
	movq	%r14, %rax
	movq	%rsi, -96(%rbp)                 ## 8-byte Spill
	subq	%rsi, %rax
	jb	LBB0_475
## %bb.43:                              ##   in Loop: Header=BB0_20 Depth=1
	movl	(%r13,%rcx), %ecx
	movl	(%r13,%rdx), %edx
	shlq	$32, %rdx
	orq	%rcx, %rdx
	movq	%rdx, -160(%rbp)                ## 8-byte Spill
	cmpq	%rax, %rdx
	ja	LBB0_475
## %bb.44:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%r13, -80(%rbp)                 ## 8-byte Spill
	movq	-128(%rbp), %rbx                ## 8-byte Reload
	movq	-176(%rbp), %r13                ## 8-byte Reload
	movq	%r13, 32(%rbx)
	movl	$88, %esi
	movq	%r13, %rdi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_476
## %bb.45:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	-80(%rbp), %rcx                 ## 8-byte Reload
	addq	%rcx, -96(%rbp)                 ## 8-byte Folded Spill
	movq	%rax, -88(%rbp)                 ## 8-byte Spill
	movq	%rax, %rdx
	movq	%rax, 24(%rbx)
	imulq	$88, %r13, %rax
	movq	%rax, -112(%rbp)                ## 8-byte Spill
	leaq	(%r12,%r15), %rbx
	addq	$60, %rbx
	addq	%r15, %r12
	negq	%r12
	xorl	%r13d, %r13d
	movq	%rdx, -104(%rbp)                ## 8-byte Spill
	jmp	LBB0_47
	.p2align	4
LBB0_46:                                ##   in Loop: Header=BB0_47 Depth=2
	addq	$88, %r13
	movq	-200(%rbp), %rax                ## 8-byte Reload
	addq	%rax, %rbx
	subq	%rax, %r12
	cmpq	%r13, -112(%rbp)                ## 8-byte Folded Reload
	je	LBB0_91
LBB0_47:                                ##   Parent Loop BB0_20 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	leaq	-60(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_402
## %bb.48:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	cmpq	$3, %rax
	jbe	LBB0_402
## %bb.49:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	-60(%rcx,%rbx), %r15d
	movq	-160(%rbp), %rdx                ## 8-byte Reload
	subq	%r15, %rdx
	jbe	LBB0_396
## %bb.50:                              ##   in Loop: Header=BB0_47 Depth=2
	addq	-96(%rbp), %r15                 ## 8-byte Folded Reload
	movq	%r15, %rdi
	xorl	%esi, %esi
	callq	_memchr
	testq	%rax, %rax
	je	LBB0_403
## %bb.51:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	-104(%rbp), %rdx                ## 8-byte Reload
	movq	%r15, (%rdx,%r13)
	leaq	-56(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_404
## %bb.52:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-4, %rax
	cmpq	$3, %rax
	jbe	LBB0_404
## %bb.53:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	-80(%rbp), %rcx                 ## 8-byte Reload
	movl	-56(%rcx,%rbx), %esi
	movl	%esi, 8(%rdx,%r13)
	leaq	-52(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_405
## %bb.54:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-8, %rax
	cmpq	$3, %rax
	jbe	LBB0_405
## %bb.55:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	-48(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_399
## %bb.56:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-12, %rax
	cmpq	$3, %rax
	jbe	LBB0_399
## %bb.57:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	-52(%rcx,%rbx), %edi
	movl	-48(%rcx,%rbx), %eax
	shlq	$32, %rax
	orq	%rdi, %rax
	movq	%rax, 16(%rdx,%r13)
	leaq	-36(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_406
## %bb.58:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-24, %rax
	cmpq	$3, %rax
	jbe	LBB0_406
## %bb.59:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	-32(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_407
## %bb.60:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-28, %rax
	cmpq	$3, %rax
	jbe	LBB0_407
## %bb.61:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	-36(%rcx,%rbx), %r8
	movq	%r8, 24(%rdx,%r13)
	leaq	-28(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_400
## %bb.62:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-32, %rax
	cmpq	$3, %rax
	jbe	LBB0_400
## %bb.63:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	-24(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_408
## %bb.64:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-36, %rax
	cmpq	$3, %rax
	jbe	LBB0_408
## %bb.65:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	-28(%rcx,%rbx), %r9
	movq	%r9, 32(%rdx,%r13)
	leaq	-20(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_410
## %bb.66:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-40, %rax
	cmpq	$3, %rax
	jbe	LBB0_410
## %bb.67:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	-20(%rcx,%rbx), %eax
	movl	%eax, 40(%rdx,%r13)
	leaq	-16(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_411
## %bb.68:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-44, %rax
	cmpq	$3, %rax
	jbe	LBB0_411
## %bb.69:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	-16(%rcx,%rbx), %eax
	movl	%eax, 44(%rdx,%r13)
	leaq	-12(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_409
## %bb.70:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-48, %rax
	cmpq	$3, %rax
	jbe	LBB0_409
## %bb.71:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	-8(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_401
## %bb.72:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-52, %rax
	cmpq	$3, %rax
	jbe	LBB0_401
## %bb.73:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	-12(%rcx,%rbx), %rax
	movq	%rax, 48(%rdx,%r13)
	leaq	-4(%rbx), %rax
	cmpq	%r14, %rax
	ja	LBB0_397
## %bb.74:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-56, %rax
	cmpq	$3, %rax
	jbe	LBB0_397
## %bb.75:                              ##   in Loop: Header=BB0_47 Depth=2
	cmpq	%r14, %rbx
	ja	LBB0_398
## %bb.76:                              ##   in Loop: Header=BB0_47 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-60, %rax
	cmpq	$3, %rax
	jbe	LBB0_398
## %bb.77:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	-4(%rcx,%rbx), %rax
	movq	%rax, 56(%rdx,%r13)
	movl	$-1, %r14d
	testb	$2, %dil
	je	LBB0_88
## %bb.78:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	%r9, -136(%rbp)                 ## 8-byte Spill
	movq	%r8, -144(%rbp)                 ## 8-byte Spill
	movq	%rdi, -184(%rbp)                ## 8-byte Spill
	cmpl	$1, %esi
	je	LBB0_80
## %bb.79:                              ##   in Loop: Header=BB0_47 Depth=2
	cmpl	$8, %esi
	jne	LBB0_428
LBB0_80:                                ##   in Loop: Header=BB0_47 Depth=2
	movl	%esi, -152(%rbp)                ## 4-byte Spill
	movl	$5, %edx
	movq	%r15, %rdi
	leaq	L_.str.27(%rip), %rsi
	callq	_strncmp
	xorl	%r14d, %r14d
	testl	%eax, %eax
	je	LBB0_87
## %bb.81:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	$7, %edx
	movq	%r15, %rdi
	leaq	L_.str.28(%rip), %rsi
	callq	_strncmp
	testl	%eax, %eax
	je	LBB0_86
## %bb.82:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	$5, %edx
	movq	%r15, %rdi
	leaq	L_.str.29(%rip), %rsi
	callq	_strncmp
	movl	$2, %r14d
	testl	%eax, %eax
	je	LBB0_87
## %bb.83:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	$4, %edx
	movq	%r15, %rdi
	leaq	L_.str.30(%rip), %rsi
	callq	_strncmp
	testl	%eax, %eax
	movq	-80(%rbp), %rcx                 ## 8-byte Reload
	movq	-104(%rbp), %rdx                ## 8-byte Reload
	movl	-152(%rbp), %esi                ## 4-byte Reload
	movq	-184(%rbp), %rax                ## 8-byte Reload
	movq	-144(%rbp), %r8                 ## 8-byte Reload
	movq	-136(%rbp), %r9                 ## 8-byte Reload
	je	LBB0_88
## %bb.84:                              ##   in Loop: Header=BB0_47 Depth=2
	movl	$0, %r14d
	testb	$4, %al
	jne	LBB0_88
## %bb.85:                              ##   in Loop: Header=BB0_47 Depth=2
	andl	$1, %eax
	incl	%eax
	movl	%eax, %r14d
	jmp	LBB0_88
LBB0_86:                                ##   in Loop: Header=BB0_47 Depth=2
	movl	$1, %r14d
LBB0_87:                                ##   in Loop: Header=BB0_47 Depth=2
	movq	-80(%rbp), %rcx                 ## 8-byte Reload
	movq	-104(%rbp), %rdx                ## 8-byte Reload
	movl	-152(%rbp), %esi                ## 4-byte Reload
	movq	-144(%rbp), %r8                 ## 8-byte Reload
	movq	-136(%rbp), %r9                 ## 8-byte Reload
LBB0_88:                                ##   in Loop: Header=BB0_47 Depth=2
	movl	%r14d, 80(%rdx,%r13)
	cmpl	$8, %esi
	movq	-120(%rbp), %r14                ## 8-byte Reload
	je	LBB0_46
## %bb.89:                              ##   in Loop: Header=BB0_47 Depth=2
	movq	%r14, %rax
	subq	%r8, %rax
	jb	LBB0_416
## %bb.90:                              ##   in Loop: Header=BB0_47 Depth=2
	cmpq	%rax, %r9
	jbe	LBB0_46
	jmp	LBB0_416
	.p2align	4
LBB0_91:                                ##   in Loop: Header=BB0_20 Depth=1
	xorl	%ebx, %ebx
	movq	-128(%rbp), %r14                ## 8-byte Reload
	.p2align	4
LBB0_92:                                ##   Parent Loop BB0_20 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	cmpl	$2, 8(%rdx,%rbx)
	je	LBB0_94
## %bb.93:                              ##   in Loop: Header=BB0_92 Depth=2
	addq	$88, %rbx
	cmpq	%rbx, -112(%rbp)                ## 8-byte Folded Reload
	jne	LBB0_92
	jmp	LBB0_412
	.p2align	4
LBB0_94:                                ##   in Loop: Header=BB0_20 Depth=1
	movl	40(%rdx,%rbx), %ecx
	cmpl	%ecx, -176(%rbp)                ## 4-byte Folded Reload
	jbe	LBB0_481
## %bb.95:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	56(%rdx,%rbx), %r13
	cmpq	$23, %r13
	jbe	LBB0_478
## %bb.96:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	32(%rdx,%rbx), %r15
	movq	%r15, %rax
	orq	%r13, %rax
	shrq	$32, %rax
	je	LBB0_98
## %bb.97:                              ##   in Loop: Header=BB0_20 Depth=1
	movq	%r15, %rax
	xorl	%edx, %edx
	divq	%r13
	jmp	LBB0_99
	.p2align	4
LBB0_98:                                ##   in Loop: Header=BB0_20 Depth=1
	movl	%r15d, %eax
	xorl	%edx, %edx
	divl	%r13d
                                        ## kill: def $edx killed $edx def $rdx
                                        ## kill: def $eax killed $eax def $rax
LBB0_99:                                ##   in Loop: Header=BB0_20 Depth=1
	movq	%rax, -96(%rbp)                 ## 8-byte Spill
	testq	%rdx, %rdx
	jne	LBB0_480
## %bb.100:                             ##   in Loop: Header=BB0_20 Depth=1
	imulq	$88, %rcx, %rax
	movq	-88(%rbp), %rcx                 ## 8-byte Reload
	addq	%rax, %rcx
	movq	24(%rcx), %rdx
	movq	-120(%rbp), %rax                ## 8-byte Reload
	movq	%rdx, -112(%rbp)                ## 8-byte Spill
	subq	%rdx, %rax
	jb	LBB0_477
## %bb.101:                             ##   in Loop: Header=BB0_20 Depth=1
	movq	32(%rcx), %rcx
	movq	%rcx, -160(%rbp)                ## 8-byte Spill
	cmpq	%rax, %rcx
	ja	LBB0_477
## %bb.102:                             ##   in Loop: Header=BB0_20 Depth=1
	movq	-96(%rbp), %rdi                 ## 8-byte Reload
	movq	%rdi, 48(%r14)
	cmpq	%r15, %r13
	movl	$1, %eax
	cmovaq	%rax, %rdi
	movl	$56, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_479
## %bb.103:                             ##   in Loop: Header=BB0_20 Depth=1
	movq	%rax, %r12
	movq	%rax, 40(%r14)
	cmpq	%r15, %r13
	movq	-80(%rbp), %rdx                 ## 8-byte Reload
	ja	LBB0_19
## %bb.104:                             ##   in Loop: Header=BB0_20 Depth=1
	movq	%rdx, %rax
	addq	-112(%rbp), %rax                ## 8-byte Folded Reload
	movq	%rax, -200(%rbp)                ## 8-byte Spill
	movq	-104(%rbp), %rax                ## 8-byte Reload
	movq	24(%rax,%rbx), %r15
	addq	$32, %r12
	movq	-120(%rbp), %rbx                ## 8-byte Reload
	subq	%r15, %rbx
	addq	$20, %r15
	addq	$-20, %rbx
	xorl	%ecx, %ecx
	movq	%r13, -144(%rbp)                ## 8-byte Spill
	.p2align	4
LBB0_105:                               ##   Parent Loop BB0_20 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	leaq	-20(%r15), %rax
	movq	-120(%rbp), %r14                ## 8-byte Reload
	cmpq	%r14, %rax
	ja	LBB0_422
## %bb.106:                             ##   in Loop: Header=BB0_105 Depth=2
	leaq	20(%rbx), %rax
	cmpq	$3, %rax
	jbe	LBB0_422
## %bb.107:                             ##   in Loop: Header=BB0_105 Depth=2
	movq	%rcx, -112(%rbp)                ## 8-byte Spill
	movl	-20(%rdx,%r15), %r13d
	movq	-160(%rbp), %rdx                ## 8-byte Reload
	subq	%r13, %rdx
	jbe	LBB0_420
## %bb.108:                             ##   in Loop: Header=BB0_105 Depth=2
	addq	-200(%rbp), %r13                ## 8-byte Folded Reload
	movq	%r13, %rdi
	xorl	%esi, %esi
	callq	_memchr
	testq	%rax, %rax
	je	LBB0_421
## %bb.109:                             ##   in Loop: Header=BB0_105 Depth=2
	movq	%r13, -32(%r12)
	movq	-80(%rbp), %rdx                 ## 8-byte Reload
	movzbl	-16(%rdx,%r15), %eax
	movb	%al, (%r12)
	leaq	-14(%r15), %rax
	cmpq	%r14, %rax
	ja	LBB0_417
## %bb.110:                             ##   in Loop: Header=BB0_105 Depth=2
	leaq	14(%rbx), %rax
	cmpq	$1, %rax
	jbe	LBB0_417
## %bb.111:                             ##   in Loop: Header=BB0_105 Depth=2
	movzwl	-14(%rdx,%r15), %eax
	movw	%ax, -24(%r12)
	leaq	-12(%r15), %rax
	cmpq	%r14, %rax
	movq	-144(%rbp), %r13                ## 8-byte Reload
	ja	LBB0_424
## %bb.112:                             ##   in Loop: Header=BB0_105 Depth=2
	leaq	12(%rbx), %rax
	cmpq	$3, %rax
	jbe	LBB0_424
## %bb.113:                             ##   in Loop: Header=BB0_105 Depth=2
	leaq	-8(%r15), %rax
	cmpq	%r14, %rax
	ja	LBB0_419
## %bb.114:                             ##   in Loop: Header=BB0_105 Depth=2
	leaq	8(%rbx), %rax
	cmpq	$3, %rax
	jbe	LBB0_419
## %bb.115:                             ##   in Loop: Header=BB0_105 Depth=2
	movq	-12(%rdx,%r15), %rax
	movq	%rax, -16(%r12)
	leaq	-4(%r15), %rcx
	movq	%rbx, %rax
	addq	$4, %rax
	setb	%al
	cmpq	%r14, %rcx
	ja	LBB0_418
## %bb.116:                             ##   in Loop: Header=BB0_105 Depth=2
	testb	%al, %al
	jne	LBB0_418
## %bb.117:                             ##   in Loop: Header=BB0_105 Depth=2
	cmpq	%r14, %r15
	movq	-112(%rbp), %rcx                ## 8-byte Reload
	ja	LBB0_423
## %bb.118:                             ##   in Loop: Header=BB0_105 Depth=2
	cmpq	$3, %rbx
	jbe	LBB0_423
## %bb.119:                             ##   in Loop: Header=BB0_105 Depth=2
	movq	-4(%rdx,%r15), %rax
	movq	%rax, -8(%r12)
	incq	%rcx
	addq	$56, %r12
	addq	%r13, %r15
	subq	%r13, %rbx
	cmpq	-96(%rbp), %rcx                 ## 8-byte Folded Reload
	jb	LBB0_105
	jmp	LBB0_19
LBB0_120:
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	leaq	L_.str.5(%rip), %rdi
	movl	$77, %esi
	movl	$1, %edx
	callq	_fwrite
	movq	-232(%rbp), %rdi                ## 8-byte Reload
	callq	_free
LBB0_121:
	movl	$1, %eax
LBB0_122:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rcx
	movq	(%rcx), %rcx
	cmpq	-48(%rbp), %rcx
	jne	LBB0_506
## %bb.123:
	addq	$472, %rsp                      ## imm = 0x1D8
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB0_124:
	movq	$0, -248(%rbp)
	movl	$0, -164(%rbp)
	leaq	L_.str.37(%rip), %r8
	leaq	-488(%rbp), %r14
	leaq	-248(%rbp), %r15
	leaq	-164(%rbp), %rbx
	movq	%r14, %rdi
	movq	%r15, %rsi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movq	%rbx, %r9
	callq	_place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	_place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	movl	$1, %edx
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	_place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	movl	$2, %edx
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	_place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	movl	$2, %edx
	movl	$1, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	_place_matching
	movq	-480(%rbp), %rax
	movq	%rax, -184(%rbp)                ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_176
## %bb.125:
	movq	-248(%rbp), %r13
	movl	-164(%rbp), %eax
	movl	%eax, -152(%rbp)                ## 4-byte Spill
	movq	-488(%rbp), %r14
	movl	-408(%rbp), %eax
	movl	%eax, -128(%rbp)                ## 4-byte Spill
	movq	-384(%rbp), %rax
	movq	%rax, -160(%rbp)                ## 8-byte Spill
	movq	-376(%rbp), %rax
	movq	%rax, -104(%rbp)                ## 8-byte Spill
	xorl	%eax, %eax
	movq	%r14, -120(%rbp)                ## 8-byte Spill
	jmp	LBB0_127
	.p2align	4
LBB0_126:                               ##   in Loop: Header=BB0_127 Depth=1
	movq	-176(%rbp), %rax                ## 8-byte Reload
	incq	%rax
	cmpq	-184(%rbp), %rax                ## 8-byte Folded Reload
	je	LBB0_175
LBB0_127:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_132 Depth 2
                                        ##       Child Loop BB0_149 Depth 3
                                        ##         Child Loop BB0_151 Depth 4
	movq	%rax, -176(%rbp)                ## 8-byte Spill
	imulq	$56, %rax, %rcx
	cmpq	$0, 48(%r14,%rcx)
	je	LBB0_126
## %bb.128:                             ##   in Loop: Header=BB0_127 Depth=1
	addq	%r14, %rcx
	xorl	%r12d, %r12d
	movq	%rcx, -96(%rbp)                 ## 8-byte Spill
	jmp	LBB0_132
LBB0_129:                               ##   in Loop: Header=BB0_132 Depth=2
	movq	%rax, %r13
LBB0_130:                               ##   in Loop: Header=BB0_132 Depth=2
	movq	-96(%rbp), %rcx                 ## 8-byte Reload
	.p2align	4
LBB0_131:                               ##   in Loop: Header=BB0_132 Depth=2
	incq	%r12
	cmpq	48(%rcx), %r12
	jae	LBB0_126
LBB0_132:                               ##   Parent Loop BB0_127 Depth=1
                                        ## =>  This Loop Header: Depth=2
                                        ##       Child Loop BB0_149 Depth 3
                                        ##         Child Loop BB0_151 Depth 4
	movq	40(%rcx), %rbx
	imulq	$56, %r12, %rax
	cmpw	$-14, 8(%rbx,%rax)
	jne	LBB0_131
## %bb.133:                             ##   in Loop: Header=BB0_132 Depth=2
	addq	%rax, %rbx
	cmpl	$0, 48(%rbx)
	jne	LBB0_131
## %bb.134:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	(%rbx), %rax
	movq	%rax, -80(%rbp)                 ## 8-byte Spill
	cmpb	$0, (%rax)
	je	LBB0_136
## %bb.135:                             ##   in Loop: Header=BB0_132 Depth=2
	cmpb	$16, 32(%rbx)
	jae	LBB0_147
LBB0_136:                               ##   in Loop: Header=BB0_132 Depth=2
	movq	$0, -336(%rbp)
	movq	$0, -64(%rbp)
	leaq	-488(%rbp), %rdi
	movq	%rbx, %rsi
	xorl	%edx, %edx
	leaq	-336(%rbp), %rcx
	leaq	-64(%rbp), %r8
	callq	_mark_matching_common_symbols
	movq	-64(%rbp), %rax
	cmpq	$2, %rax
	jae	LBB0_138
## %bb.137:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	%rbx, %rsi
	movq	%r13, %rbx
	jmp	LBB0_141
LBB0_138:                               ##   in Loop: Header=BB0_132 Depth=2
	leaq	-1(%rax), %rcx
	testq	%rcx, %rax
	jne	LBB0_482
## %bb.139:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	%rax, %rcx
	negq	%rcx
	cmpq	%rcx, %r13
	ja	LBB0_483
## %bb.140:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	%rbx, %rsi
	leaq	(%rax,%r13), %rbx
	decq	%rbx
	andq	%rcx, %rbx
LBB0_141:                               ##   in Loop: Header=BB0_132 Depth=2
	movq	-336(%rbp), %r15
	addq	%rbx, %r15
	jb	LBB0_460
## %bb.142:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	-104(%rbp), %rax                ## 8-byte Reload
	leaq	(%rax,%rbx), %r13
	leaq	-488(%rbp), %rdi
	movq	%r13, %rdx
	leaq	-336(%rbp), %rcx
	leaq	-64(%rbp), %r8
	callq	_mark_matching_common_symbols
	movq	%r15, %rax
	cmpq	%rbx, %r15
	jbe	LBB0_129
## %bb.143:                             ##   in Loop: Header=BB0_132 Depth=2
	cmpl	$0, -152(%rbp)                  ## 4-byte Folded Reload
	movq	-96(%rbp), %rcx                 ## 8-byte Reload
	jne	LBB0_145
## %bb.144:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	%r13, -352(%rbp)
	movl	$1, -152(%rbp)                  ## 4-byte Folded Spill
LBB0_145:                               ##   in Loop: Header=BB0_132 Depth=2
	movq	%rax, %r13
	movq	-104(%rbp), %rax                ## 8-byte Reload
	addq	%r13, %rax
	movq	%rax, -344(%rbp)
	cmpl	$0, -128(%rbp)                  ## 4-byte Folded Reload
	je	LBB0_166
## %bb.146:                             ##   in Loop: Header=BB0_132 Depth=2
	cmpq	-160(%rbp), %r13                ## 8-byte Folded Reload
	jbe	LBB0_131
	jmp	LBB0_167
LBB0_147:                               ##   in Loop: Header=BB0_132 Depth=2
	movq	%rbx, -136(%rbp)                ## 8-byte Spill
	movq	%r12, -144(%rbp)                ## 8-byte Spill
	movq	%r13, -200(%rbp)                ## 8-byte Spill
	xorl	%eax, %eax
	xorl	%ecx, %ecx
	xorl	%r15d, %r15d
	jmp	LBB0_149
	.p2align	4
LBB0_148:                               ##   in Loop: Header=BB0_149 Depth=3
	incq	%r15
	cmpq	-184(%rbp), %r15                ## 8-byte Folded Reload
	movq	-120(%rbp), %r14                ## 8-byte Reload
	je	LBB0_161
LBB0_149:                               ##   Parent Loop BB0_127 Depth=1
                                        ##     Parent Loop BB0_132 Depth=2
                                        ## =>    This Loop Header: Depth=3
                                        ##         Child Loop BB0_151 Depth 4
	imulq	$56, %r15, %rdx
	movq	48(%r14,%rdx), %r12
	testq	%r12, %r12
	je	LBB0_148
## %bb.150:                             ##   in Loop: Header=BB0_149 Depth=3
	addq	%r14, %rdx
	movq	%rdx, -112(%rbp)                ## 8-byte Spill
	movq	40(%rdx), %r14
	movq	%rax, %r13
	movq	%rcx, %rbx
	.p2align	4
LBB0_151:                               ##   Parent Loop BB0_127 Depth=1
                                        ##     Parent Loop BB0_132 Depth=2
                                        ##       Parent Loop BB0_149 Depth=3
                                        ## =>      This Inner Loop Header: Depth=4
	movzwl	8(%r14), %eax
	testl	%eax, %eax
	je	LBB0_156
## %bb.152:                             ##   in Loop: Header=BB0_151 Depth=4
	cmpl	$65522, %eax                    ## imm = 0xFFF2
	je	LBB0_156
## %bb.153:                             ##   in Loop: Header=BB0_151 Depth=4
	movq	(%r14), %rdi
	cmpb	$0, (%rdi)
	je	LBB0_156
## %bb.154:                             ##   in Loop: Header=BB0_151 Depth=4
	movq	-80(%rbp), %rsi                 ## 8-byte Reload
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_156
## %bb.155:                             ##   in Loop: Header=BB0_151 Depth=4
	movzbl	32(%r14), %edx
	cmpb	$16, %dl
	jae	LBB0_158
	.p2align	4
LBB0_156:                               ##   in Loop: Header=BB0_151 Depth=4
	movq	%rbx, %rcx
	movq	%r13, %rax
LBB0_157:                               ##   in Loop: Header=BB0_151 Depth=4
	addq	$56, %r14
	movq	%rax, %r13
	movq	%rcx, %rbx
	decq	%r12
	jne	LBB0_151
	jmp	LBB0_148
LBB0_158:                               ##   in Loop: Header=BB0_151 Depth=4
	movq	-112(%rbp), %rcx                ## 8-byte Reload
	movq	%r14, %rax
	testq	%r13, %r13
	je	LBB0_157
## %bb.159:                             ##   in Loop: Header=BB0_151 Depth=4
	movzbl	32(%r13), %esi
	andb	$-16, %sil
	movq	-112(%rbp), %rcx                ## 8-byte Reload
	movq	%r14, %rax
	cmpb	$32, %sil
	je	LBB0_157
## %bb.160:                             ##   in Loop: Header=BB0_151 Depth=4
	andb	$-16, %dl
	movq	%rbx, %rcx
	movq	%r13, %rax
	cmpb	$32, %dl
	je	LBB0_157
	jmp	LBB0_450
LBB0_161:                               ##   in Loop: Header=BB0_132 Depth=2
	testq	%rax, %rax
	movq	-200(%rbp), %r13                ## 8-byte Reload
	movq	-144(%rbp), %r12                ## 8-byte Reload
	movq	-136(%rbp), %rbx                ## 8-byte Reload
	je	LBB0_136
## %bb.162:                             ##   in Loop: Header=BB0_132 Depth=2
	testq	%rcx, %rcx
	je	LBB0_136
## %bb.163:                             ##   in Loop: Header=BB0_132 Depth=2
	movzwl	8(%rax), %edx
	cmpl	$65522, %edx                    ## imm = 0xFFF2
	je	LBB0_168
## %bb.164:                             ##   in Loop: Header=BB0_132 Depth=2
	cmpl	$65521, %edx                    ## imm = 0xFFF1
	jne	LBB0_170
## %bb.165:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	16(%rax), %rdx
	jmp	LBB0_173
LBB0_166:                               ##   in Loop: Header=BB0_132 Depth=2
	movl	$1, -408(%rbp)
	movq	%rbx, -400(%rbp)
	movq	%rbx, -392(%rbp)
	movq	%rbx, -384(%rbp)
	movl	$1, -128(%rbp)                  ## 4-byte Folded Spill
	movq	%rbx, -160(%rbp)                ## 8-byte Spill
	cmpq	-160(%rbp), %r13                ## 8-byte Folded Reload
	jbe	LBB0_131
LBB0_167:                               ##   in Loop: Header=BB0_132 Depth=2
	movq	%r13, -384(%rbp)
	movq	%r13, -160(%rbp)                ## 8-byte Spill
	jmp	LBB0_131
LBB0_168:                               ##   in Loop: Header=BB0_132 Depth=2
	cmpl	$0, 48(%rax)
	je	LBB0_510
## %bb.169:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	40(%rax), %rdx
	jmp	LBB0_173
LBB0_170:                               ##   in Loop: Header=BB0_132 Depth=2
	cmpq	%rdx, 32(%rcx)
	jbe	LBB0_511
## %bb.171:                             ##   in Loop: Header=BB0_132 Depth=2
	movq	24(%rcx), %rcx
	imulq	$88, %rdx, %rdx
	cmpl	$0, 84(%rcx,%rdx)
	je	LBB0_509
## %bb.172:                             ##   in Loop: Header=BB0_132 Depth=2
	addq	%rdx, %rcx
	movq	16(%rax), %rdx
	addq	72(%rcx), %rdx
LBB0_173:                               ##   in Loop: Header=BB0_132 Depth=2
	leaq	-488(%rbp), %rdi
	movq	%rbx, %rsi
	leaq	-336(%rbp), %rcx
	leaq	-64(%rbp), %r8
	callq	_mark_matching_common_symbols
	jmp	LBB0_130
LBB0_174:
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.4(%rip), %rsi
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	_fprintf
	jmp	LBB0_121
LBB0_175:
	movq	%r13, -248(%rbp)
	movl	-152(%rbp), %eax                ## 4-byte Reload
	movl	%eax, -164(%rbp)
LBB0_176:
	cmpl	$0, -472(%rbp)
	je	LBB0_513
## %bb.177:
	movq	-464(%rbp), %rbx
	cmpq	%rbx, -456(%rbp)
	je	LBB0_513
## %bb.178:
	cmpl	$0, -164(%rbp)
	movq	-248(%rbp), %r15
	jne	LBB0_180
## %bb.179:
	movq	-376(%rbp), %rax
	addq	%r15, %rax
	movq	%rax, -352(%rbp)
	movq	%rax, -344(%rbp)
LBB0_180:
	movq	%r15, -360(%rbp)
	movq	-368(%rbp), %rax
	testq	%rax, %rax
	je	LBB0_516
## %bb.181:
	movq	%rax, -80(%rbp)                 ## 8-byte Spill
	leaq	4096(%rax), %r14
	movl	$1, %esi
	movq	%r14, %rdi
	callq	_calloc
	movq	%rax, -128(%rbp)                ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_517
## %bb.182:
	cmpq	%rbx, -448(%rbp)
	jbe	LBB0_184
## %bb.183:
	movl	$0, -64(%rbp)
	movw	$1, %cx
	cmpl	$0, -440(%rbp)
	jne	LBB0_185
	jmp	LBB0_187
LBB0_184:
	xorl	%ecx, %ecx
	cmpl	$0, -440(%rbp)
	je	LBB0_187
LBB0_185:
	movq	-416(%rbp), %rax
	cmpq	-432(%rbp), %rax
	jbe	LBB0_187
## %bb.186:
	movzwl	%cx, %eax
	leal	1(%rax), %ecx
	movl	$1, -64(%rbp,%rax,4)
LBB0_187:
	cmpl	$0, -408(%rbp)
	movq	%r14, -240(%rbp)                ## 8-byte Spill
	je	LBB0_190
## %bb.188:
	movq	-384(%rbp), %rax
	cmpq	-400(%rbp), %rax
	jbe	LBB0_190
## %bb.189:
	movzwl	%cx, %eax
	leal	1(%rax), %ecx
	movl	$2, -64(%rbp,%rax,4)
LBB0_190:
	movq	%r15, -256(%rbp)                ## 8-byte Spill
	movq	-488(%rbp), %rax
	movq	%rax, -88(%rbp)                 ## 8-byte Spill
	movq	48(%rax), %r13
	testq	%r13, %r13
	je	LBB0_514
## %bb.191:
	movl	%ecx, %r14d
	movq	-88(%rbp), %rax                 ## 8-byte Reload
	movq	40(%rax), %r12
	xorl	%r15d, %r15d
	jmp	LBB0_193
	.p2align	4
LBB0_192:                               ##   in Loop: Header=BB0_193 Depth=1
	addq	$56, %r12
	decq	%r13
	je	LBB0_204
LBB0_193:                               ## =>This Inner Loop Header: Depth=1
	movzwl	8(%r12), %ebx
	testq	%rbx, %rbx
	je	LBB0_192
## %bb.194:                             ##   in Loop: Header=BB0_193 Depth=1
	movq	(%r12), %rdi
	leaq	L_.str.51(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_192
## %bb.195:                             ##   in Loop: Header=BB0_193 Depth=1
	movzbl	32(%r12), %eax
	cmpl	$15, %eax
	jbe	LBB0_503
## %bb.196:                             ##   in Loop: Header=BB0_193 Depth=1
	testb	$13, %al
	jne	LBB0_512
## %bb.197:                             ##   in Loop: Header=BB0_193 Depth=1
	cmpl	$65521, %ebx                    ## imm = 0xFFF1
	movq	-88(%rbp), %rdi                 ## 8-byte Reload
	je	LBB0_502
## %bb.198:                             ##   in Loop: Header=BB0_193 Depth=1
	cmpq	%rbx, 32(%rdi)
	jbe	LBB0_502
## %bb.199:                             ##   in Loop: Header=BB0_193 Depth=1
	movq	24(%rdi), %rax
	imulq	$88, %rbx, %rcx
	cmpl	$0, 84(%rax,%rcx)
	je	LBB0_486
## %bb.200:                             ##   in Loop: Header=BB0_193 Depth=1
	addq	%rcx, %rax
	cmpl	$0, 80(%rax)
	jne	LBB0_486
## %bb.201:                             ##   in Loop: Header=BB0_193 Depth=1
	testb	$4, 16(%rax)
	je	LBB0_486
## %bb.202:                             ##   in Loop: Header=BB0_193 Depth=1
	testq	%r15, %r15
	movq	%r12, %r15
	je	LBB0_192
## %bb.203:
	movq	-88(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.21
LBB0_204:
	testq	%r15, %r15
	je	LBB0_514
## %bb.205:
	movzwl	8(%r15), %eax
	cmpl	$65522, %eax                    ## imm = 0xFFF2
	movq	-128(%rbp), %rdi                ## 8-byte Reload
	movl	%r14d, %r8d
	je	LBB0_208
## %bb.206:
	cmpl	$65521, %eax                    ## imm = 0xFFF1
	movq	-240(%rbp), %r13                ## 8-byte Reload
	jne	LBB0_210
## %bb.207:
	movq	16(%r15), %rcx
	jmp	LBB0_213
LBB0_208:
	cmpl	$0, 48(%r15)
	movq	-240(%rbp), %r13                ## 8-byte Reload
	je	LBB0_535
## %bb.209:
	movq	40(%r15), %rcx
	jmp	LBB0_213
LBB0_210:
	movq	-88(%rbp), %rcx                 ## 8-byte Reload
	cmpq	%rax, 32(%rcx)
	jbe	LBB0_536
## %bb.211:
	movq	24(%rcx), %rdx
	imulq	$88, %rax, %rax
	cmpl	$0, 84(%rdx,%rax)
	je	LBB0_537
## %bb.212:
	addq	%rax, %rdx
	movq	16(%r15), %rcx
	addq	72(%rdx), %rcx
LBB0_213:
	movl	$1179403647, (%rdi)             ## imm = 0x464C457F
	movw	$258, 4(%rdi)                   ## imm = 0x102
	movb	$1, 6(%rdi)
	cmpq	$16, %r13
	jb	LBB0_518
## %bb.214:
	movq	%r13, %rax
	andq	$-2, %rax
	cmpq	$16, %rax
	je	LBB0_518
## %bb.215:
	movb	$2, 16(%rdi)
	cmpq	$18, %rax
	je	LBB0_519
## %bb.216:
	movb	$-73, 18(%rdi)
	movq	%r13, %rdx
	andq	$-4, %rdx
	cmpq	$20, %rdx
	je	LBB0_520
## %bb.217:
	movb	$1, 20(%rdi)
	cmpq	$24, %rdx
	je	LBB0_521
## %bb.218:
	movl	%ecx, 24(%rdi)
	cmpq	$28, %rdx
	je	LBB0_522
## %bb.219:
	movq	%rcx, %rsi
	shrq	$32, %rsi
	movb	%sil, 28(%rdi)
	movq	%rcx, %rsi
	shrq	$40, %rsi
	movb	%sil, 29(%rdi)
	movq	%rcx, %rsi
	shrq	$48, %rsi
	movb	%sil, 30(%rdi)
	shrq	$56, %rcx
	movb	%cl, 31(%rdi)
	cmpq	$32, %rdx
	je	LBB0_523
## %bb.220:
	movb	$64, 32(%rdi)
	movq	-80(%rbp), %rdx                 ## 8-byte Reload
	leaq	4060(%rdx), %rcx
	shrq	$2, %rcx
	cmpq	$3, %rcx
	jbe	LBB0_507
## %bb.221:
	cmpq	$52, %rax
	je	LBB0_527
## %bb.222:
	movb	$64, 52(%rdi)
	cmpq	$54, %rax
	je	LBB0_528
## %bb.223:
	movb	$56, 54(%rdi)
	cmpq	$56, %rax
	je	LBB0_529
## %bb.224:
	movb	%r8b, 56(%rdi)
	cmpq	$62, %rax
	je	LBB0_530
## %bb.225:
	cmpq	$60, %rax
	je	LBB0_531
## %bb.226:
	cmpq	$58, %rax
	je	LBB0_532
## %bb.227:
	testw	%r8w, %r8w
	je	LBB0_245
## %bb.228:
	movq	-376(%rbp), %rax
	movq	%rax, -104(%rbp)                ## 8-byte Spill
	leaq	4092(%rdx), %rax
	movq	%rax, -120(%rbp)                ## 8-byte Spill
	movzwl	%r8w, %eax
	imulq	$56, %rax, %rax
	movq	%rax, -96(%rbp)                 ## 8-byte Spill
	movl	$64, %esi
	leaq	-64(%rbp), %rcx
	xorl	%r8d, %r8d
	movq	-128(%rbp), %rdi                ## 8-byte Reload
	.p2align	4
LBB0_229:                               ## =>This Inner Loop Header: Depth=1
	cmpq	%r13, %rsi
	ja	LBB0_488
## %bb.230:                             ##   in Loop: Header=BB0_229 Depth=1
	leaq	(%rdx,%r8), %rax
	addq	$4032, %rax                     ## imm = 0xFC0
	cmpq	$3, %rax
	jbe	LBB0_488
## %bb.231:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	%rcx, -112(%rbp)                ## 8-byte Spill
	movslq	(%rcx), %rax
	movq	%rax, %r9
	shlq	$5, %r9
	leaq	-472(%rbp), %rcx
	movq	8(%rcx,%r9), %r11
	movq	16(%rcx,%r9), %rbx
	movq	24(%rcx,%r9), %r10
	movl	$1, (%rdi,%rsi)
	leaq	4(%rsi), %r9
	cmpq	-120(%rbp), %r9                 ## 8-byte Folded Reload
	ja	LBB0_489
## %bb.232:                             ##   in Loop: Header=BB0_229 Depth=1
	cmpl	$1, %eax
	setne	%r9b
	addb	%r9b, %r9b
	orb	$4, %r9b
	testl	%eax, %eax
	movzbl	%r9b, %eax
	movl	$5, %ecx
	cmovel	%ecx, %eax
	movb	%al, 4(%rdi,%rsi)
	movw	$0, 5(%rdi,%rsi)
	movb	$0, 7(%rdi,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$4024, %rax                     ## imm = 0xFB8
	cmpq	$3, %rax
	jbe	LBB0_490
## %bb.233:                             ##   in Loop: Header=BB0_229 Depth=1
	leaq	4096(%r11), %rax
	movb	%r11b, 8(%rdi,%rsi)
	movb	%ah, 9(%rdi,%rsi)
	movl	%eax, %r9d
	shrl	$16, %r9d
	movb	%r9b, 10(%rdi,%rsi)
	movl	%eax, %r9d
	shrl	$24, %r9d
	movb	%r9b, 11(%rdi,%rsi)
	leaq	(%rdx,%r8), %r9
	addq	$4020, %r9                      ## imm = 0xFB4
	cmpq	$3, %r9
	jbe	LBB0_491
## %bb.234:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	%rax, %r9
	shrq	$32, %r9
	movb	%r9b, 12(%rdi,%rsi)
	movq	%rax, %r9
	shrq	$40, %r9
	movb	%r9b, 13(%rdi,%rsi)
	movq	%rax, %r9
	shrq	$48, %r9
	movb	%r9b, 14(%rdi,%rsi)
	shrq	$56, %rax
	movb	%al, 15(%rdi,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$4016, %rax                     ## imm = 0xFB0
	cmpq	$3, %rax
	jbe	LBB0_492
## %bb.235:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	-104(%rbp), %rax                ## 8-byte Reload
	leaq	(%r11,%rax), %r15
	movl	%r15d, 16(%rdi,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$4012, %rax                     ## imm = 0xFAC
	cmpq	$3, %rax
	jbe	LBB0_493
## %bb.236:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	%r11, -80(%rbp)                 ## 8-byte Spill
	movq	%r15, %r9
	shrq	$32, %r9
	movb	%r9b, 20(%rdi,%rsi)
	movq	%r15, %r13
	shrq	$40, %r13
	movb	%r13b, 21(%rdi,%rsi)
	movq	%r15, %rax
	shrq	$48, %rax
	movb	%al, 22(%rdi,%rsi)
	movq	%r15, %r12
	shrq	$56, %r12
	movb	%r12b, 23(%rdi,%rsi)
	leaq	(%rdx,%r8), %rcx
	addq	$4008, %rcx                     ## imm = 0xFA8
	cmpq	$3, %rcx
	jbe	LBB0_494
## %bb.237:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	%rdx, %r11
	movl	%r15d, %ecx
	shrl	$8, %ecx
	movl	%r15d, %edx
	shrl	$16, %edx
	movl	%r15d, %r14d
	shrl	$24, %r14d
	movb	%r15b, 24(%rdi,%rsi)
	movb	%cl, 25(%rdi,%rsi)
	movb	%dl, 26(%rdi,%rsi)
	movb	%r14b, 27(%rdi,%rsi)
	leaq	(%r11,%r8), %rcx
	addq	$4004, %rcx                     ## imm = 0xFA4
	cmpq	$3, %rcx
	jbe	LBB0_495
## %bb.238:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	%r11, %rdx
	movb	%r9b, 28(%rdi,%rsi)
	movb	%r13b, 29(%rdi,%rsi)
	movb	%al, 30(%rdi,%rsi)
	movb	%r12b, 31(%rdi,%rsi)
	leaq	(%r11,%r8), %rax
	addq	$4000, %rax                     ## imm = 0xFA0
	cmpq	$3, %rax
	movq	-80(%rbp), %rcx                 ## 8-byte Reload
	jbe	LBB0_496
## %bb.239:                             ##   in Loop: Header=BB0_229 Depth=1
	subq	%rcx, %rbx
	movl	%ebx, 32(%rdi,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3996, %rax                     ## imm = 0xF9C
	cmpq	$3, %rax
	movq	-240(%rbp), %r13                ## 8-byte Reload
	jbe	LBB0_497
## %bb.240:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	%rbx, %rax
	shrq	$32, %rax
	movb	%al, 36(%rdi,%rsi)
	movq	%rbx, %rax
	shrq	$40, %rax
	movb	%al, 37(%rdi,%rsi)
	movq	%rbx, %rax
	shrq	$48, %rax
	movb	%al, 38(%rdi,%rsi)
	shrq	$56, %rbx
	movb	%bl, 39(%rdi,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3992, %rax                     ## imm = 0xF98
	cmpq	$3, %rax
	jbe	LBB0_498
## %bb.241:                             ##   in Loop: Header=BB0_229 Depth=1
	subq	%rcx, %r10
	movl	%r10d, 40(%rdi,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3988, %rax                     ## imm = 0xF94
	cmpq	$3, %rax
	jbe	LBB0_499
## %bb.242:                             ##   in Loop: Header=BB0_229 Depth=1
	movq	%r10, %rax
	shrq	$32, %rax
	movb	%al, 44(%rdi,%rsi)
	movq	%r10, %rax
	shrq	$40, %rax
	movb	%al, 45(%rdi,%rsi)
	movq	%r10, %rax
	shrq	$48, %rax
	movb	%al, 46(%rdi,%rsi)
	shrq	$56, %r10
	movb	%r10b, 47(%rdi,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3984, %rax                     ## imm = 0xF90
	cmpq	$3, %rax
	jbe	LBB0_500
## %bb.243:                             ##   in Loop: Header=BB0_229 Depth=1
	movl	$4096, 48(%rdi,%rsi)            ## imm = 0x1000
	leaq	(%rdx,%r8), %rax
	addq	$3980, %rax                     ## imm = 0xF8C
	cmpq	$3, %rax
	jbe	LBB0_501
## %bb.244:                             ##   in Loop: Header=BB0_229 Depth=1
	movl	$0, 52(%rdi,%rsi)
	addq	$-56, %r8
	addq	$56, %rsi
	movq	-112(%rbp), %rcx                ## 8-byte Reload
	addq	$4, %rcx
	movq	-96(%rbp), %rax                 ## 8-byte Reload
	addq	%r8, %rax
	jne	LBB0_229
LBB0_245:
	cmpq	$0, -184(%rbp)                  ## 8-byte Folded Reload
	je	LBB0_380
## %bb.246:
	xorl	%ebx, %ebx
	jmp	LBB0_248
	.p2align	4
LBB0_247:                               ##   in Loop: Header=BB0_248 Depth=1
	incq	%rbx
	cmpq	-184(%rbp), %rbx                ## 8-byte Folded Reload
	je	LBB0_256
LBB0_248:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_251 Depth 2
	imulq	$56, %rbx, %r14
	movq	-88(%rbp), %rax                 ## 8-byte Reload
	movq	32(%rax,%r14), %rax
	cmpq	$2, %rax
	jb	LBB0_247
## %bb.249:                             ##   in Loop: Header=BB0_248 Depth=1
	addq	-88(%rbp), %r14                 ## 8-byte Folded Reload
	movl	$1, %r15d
	movl	$96, %r12d
	jmp	LBB0_251
	.p2align	4
LBB0_250:                               ##   in Loop: Header=BB0_251 Depth=2
	incq	%r15
	addq	$88, %r12
	cmpq	%rax, %r15
	jae	LBB0_247
LBB0_251:                               ##   Parent Loop BB0_248 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	24(%r14), %rcx
	cmpl	$0, 76(%rcx,%r12)
	je	LBB0_250
## %bb.252:                             ##   in Loop: Header=BB0_251 Depth=2
	cmpl	$8, (%rcx,%r12)
	je	LBB0_250
## %bb.253:                             ##   in Loop: Header=BB0_251 Depth=2
	movq	24(%rcx,%r12), %rdx
	testq	%rdx, %rdx
	je	LBB0_250
## %bb.254:                             ##   in Loop: Header=BB0_251 Depth=2
	movq	56(%rcx,%r12), %rdi
	leaq	(%rdi,%rdx), %rax
	addq	$4096, %rax                     ## imm = 0x1000
	cmpq	%r13, %rax
	ja	LBB0_461
## %bb.255:                             ##   in Loop: Header=BB0_251 Depth=2
	addq	$4096, %rdi                     ## imm = 0x1000
	addq	-128(%rbp), %rdi                ## 8-byte Folded Reload
	movq	8(%r14), %rsi
	addq	16(%rcx,%r12), %rsi
	callq	_memcpy
	movq	32(%r14), %rax
	jmp	LBB0_250
LBB0_256:
	movq	-344(%rbp), %r15
	movq	-376(%rbp), %r12
	movq	-352(%rbp), %rax
	movq	%rax, -272(%rbp)                ## 8-byte Spill
	movq	-256(%rbp), %r14                ## 8-byte Reload
	addq	%r12, %r14
	xorl	%eax, %eax
	movq	%r14, -256(%rbp)                ## 8-byte Spill
	movq	%r15, -512(%rbp)                ## 8-byte Spill
	movq	%r12, -504(%rbp)                ## 8-byte Spill
	jmp	LBB0_258
	.p2align	4
LBB0_257:                               ##   in Loop: Header=BB0_258 Depth=1
	movq	-496(%rbp), %rax                ## 8-byte Reload
	incq	%rax
	cmpq	-184(%rbp), %rax                ## 8-byte Folded Reload
	je	LBB0_380
LBB0_258:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_263 Depth 2
                                        ##       Child Loop BB0_279 Depth 3
                                        ##         Child Loop BB0_314 Depth 4
                                        ##           Child Loop BB0_319 Depth 5
	movq	%rax, -496(%rbp)                ## 8-byte Spill
	imulq	$56, %rax, %r11
	movq	-88(%rbp), %rax                 ## 8-byte Reload
	movq	32(%rax,%r11), %rdi
	testq	%rdi, %rdi
	je	LBB0_257
## %bb.259:                             ##   in Loop: Header=BB0_258 Depth=1
	addq	-88(%rbp), %r11                 ## 8-byte Folded Reload
	xorl	%ecx, %ecx
	movq	%r11, -176(%rbp)                ## 8-byte Spill
	jmp	LBB0_263
	.p2align	4
LBB0_260:                               ##   in Loop: Header=BB0_263 Depth=2
	movq	32(%r11), %rdi
LBB0_261:                               ##   in Loop: Header=BB0_263 Depth=2
	movq	-264(%rbp), %rcx                ## 8-byte Reload
LBB0_262:                               ##   in Loop: Header=BB0_263 Depth=2
	incq	%rcx
	cmpq	%rdi, %rcx
	jae	LBB0_257
LBB0_263:                               ##   Parent Loop BB0_258 Depth=1
                                        ## =>  This Loop Header: Depth=2
                                        ##       Child Loop BB0_279 Depth 3
                                        ##         Child Loop BB0_314 Depth 4
                                        ##           Child Loop BB0_319 Depth 5
	movq	24(%r11), %r9
	imulq	$88, %rcx, %rsi
	movl	8(%r9,%rsi), %eax
	cmpl	$9, %eax
	je	LBB0_265
## %bb.264:                             ##   in Loop: Header=BB0_263 Depth=2
	cmpl	$4, %eax
	jne	LBB0_262
LBB0_265:                               ##   in Loop: Header=BB0_263 Depth=2
	movq	%rcx, -264(%rbp)                ## 8-byte Spill
	addq	%r9, %rsi
	movl	44(%rsi), %ecx
	cmpq	%rcx, %rdi
	jbe	LBB0_429
## %bb.266:                             ##   in Loop: Header=BB0_263 Depth=2
	movl	40(%rsi), %edx
	cmpq	%rdx, %rdi
	jbe	LBB0_425
## %bb.267:                             ##   in Loop: Header=BB0_263 Depth=2
	imulq	$88, %rdx, %rdx
	cmpl	$2, 8(%r9,%rdx)
	jne	LBB0_425
## %bb.268:                             ##   in Loop: Header=BB0_263 Depth=2
	imulq	$88, %rcx, %rcx
	cmpl	$0, 84(%r9,%rcx)
	je	LBB0_261
## %bb.269:                             ##   in Loop: Header=BB0_263 Depth=2
	addq	%rcx, %r9
	cmpl	$9, %eax
	je	LBB0_454
## %bb.270:                             ##   in Loop: Header=BB0_263 Depth=2
	cmpl	$8, 8(%r9)
	je	LBB0_452
## %bb.271:                             ##   in Loop: Header=BB0_263 Depth=2
	cmpq	$24, 56(%rsi)
	jne	LBB0_451
## %bb.272:                             ##   in Loop: Header=BB0_263 Depth=2
	movq	32(%rsi), %rcx
	movq	%rcx, %rax
	movabsq	$-6148914691236517205, %rdx     ## imm = 0xAAAAAAAAAAAAAAAB
	mulq	%rdx
	movq	%rdx, -144(%rbp)                ## 8-byte Spill
	rorq	$3, %rax
	movabsq	$768614336404564651, %rdx       ## imm = 0xAAAAAAAAAAAAAAB
	cmpq	%rdx, %rax
	jae	LBB0_453
## %bb.273:                             ##   in Loop: Header=BB0_263 Depth=2
	cmpq	$24, %rcx
	movq	-264(%rbp), %rcx                ## 8-byte Reload
	jb	LBB0_262
## %bb.274:                             ##   in Loop: Header=BB0_263 Depth=2
	shrq	$4, -144(%rbp)                  ## 8-byte Folded Spill
	xorl	%r10d, %r10d
	movq	%rsi, -152(%rbp)                ## 8-byte Spill
	movq	%r9, -160(%rbp)                 ## 8-byte Spill
	jmp	LBB0_279
LBB0_275:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%rax, %rcx
	shrq	$32, %rcx
	movb	%cl, (%rbx,%rdx)
	movq	%rax, %rcx
	shrq	$40, %rcx
	movb	%cl, 1(%rbx,%rdx)
	movq	%rax, %rcx
	shrq	$48, %rcx
	movb	%cl, 2(%rbx,%rdx)
	shrq	$56, %rax
LBB0_276:                               ##   in Loop: Header=BB0_279 Depth=3
	movl	%eax, %esi
LBB0_277:                               ##   in Loop: Header=BB0_279 Depth=3
	movb	%sil, 3(%rbx,%rdx)
LBB0_278:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	-80(%rbp), %r10                 ## 8-byte Reload
	incq	%r10
	cmpq	-144(%rbp), %r10                ## 8-byte Folded Reload
	movq	-152(%rbp), %rsi                ## 8-byte Reload
	je	LBB0_260
LBB0_279:                               ##   Parent Loop BB0_258 Depth=1
                                        ##     Parent Loop BB0_263 Depth=2
                                        ## =>    This Loop Header: Depth=3
                                        ##         Child Loop BB0_314 Depth 4
                                        ##           Child Loop BB0_319 Depth 5
	leaq	(%r10,%r10,2), %rax
	shlq	$3, %rax
	addq	24(%rsi), %rax
	movq	16(%r11), %rcx
	movq	%rcx, %rdx
	subq	%rax, %rdx
	jb	LBB0_386
## %bb.280:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rdx
	jbe	LBB0_386
## %bb.281:                             ##   in Loop: Header=BB0_279 Depth=3
	leaq	4(%rax), %rdi
	movq	%rcx, %rdx
	subq	%rdi, %rdx
	jb	LBB0_388
## %bb.282:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rdx
	jbe	LBB0_388
## %bb.283:                             ##   in Loop: Header=BB0_279 Depth=3
	leaq	8(%rax), %rdi
	movq	%rcx, %rdx
	subq	%rdi, %rdx
	jb	LBB0_390
## %bb.284:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rdx
	jbe	LBB0_390
## %bb.285:                             ##   in Loop: Header=BB0_279 Depth=3
	leaq	12(%rax), %rdi
	movq	%rcx, %rdx
	subq	%rdi, %rdx
	jb	LBB0_385
## %bb.286:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rdx
	jbe	LBB0_385
## %bb.287:                             ##   in Loop: Header=BB0_279 Depth=3
	leaq	16(%rax), %rdx
	movq	%rcx, %rdi
	subq	%rdx, %rdi
	jb	LBB0_387
## %bb.288:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rdi
	jbe	LBB0_387
## %bb.289:                             ##   in Loop: Header=BB0_279 Depth=3
	leaq	20(%rax), %r8
	subq	%r8, %rcx
	jb	LBB0_389
## %bb.290:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rcx
	jbe	LBB0_389
## %bb.291:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	8(%r11), %rdi
	movq	(%rdi,%rax), %rbx
	movl	8(%rdi,%rax), %ecx
	movl	12(%rdi,%rax), %eax
	movl	(%rdi,%rdx), %edx
	movq	%rdx, -112(%rbp)                ## 8-byte Spill
	movl	(%rdi,%r8), %edi
	movq	%r11, -336(%rbp)
	movq	%rsi, -328(%rbp)
	movq	%r9, -320(%rbp)
	movq	%r10, -312(%rbp)
	movq	%rbx, -304(%rbp)
	movl	%ecx, -296(%rbp)
	movq	%rax, -288(%rbp)
	leal	-257(%rcx), %r8d
	cmpl	$42, %r8d
	movq	%r10, -80(%rbp)                 ## 8-byte Spill
	ja	LBB0_334
## %bb.292:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	$4, %edx
	movabsq	$4399090237440, %rsi            ## imm = 0x4003E360000
	btq	%r8, %rsi
	jae	LBB0_332
LBB0_293:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	32(%r9), %rcx
	subq	%rbx, %rcx
	jb	LBB0_392
## %bb.294:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	%rcx, %rdx
	ja	LBB0_392
## %bb.295:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	%rax, 48(%r11)
	jbe	LBB0_395
## %bb.296:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	40(%r11), %rcx
	imulq	$56, %rax, %rax
	leaq	(%rcx,%rax), %rsi
	movzbl	32(%rcx,%rax), %eax
	cmpb	$32, %al
	setb	%cl
	movl	%eax, %edx
	andb	$-16, %dl
	cmpb	$32, %dl
	sete	%dl
	orb	%cl, %dl
	je	LBB0_393
## %bb.297:                             ##   in Loop: Header=BB0_279 Depth=3
	testb	$12, %al
	jne	LBB0_391
## %bb.298:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	%r8, -120(%rbp)                 ## 8-byte Spill
	movq	%rdi, -96(%rbp)                 ## 8-byte Spill
	movq	%rbx, -104(%rbp)                ## 8-byte Spill
	cmpw	$0, 8(%rsi)
	je	LBB0_306
## %bb.299:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	%r11, %rdi
	leaq	-336(%rbp), %rdx
	callq	_defined_symbol_value_for_relocation
LBB0_300:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	-120(%rbp), %r8                 ## 8-byte Reload
	cmpl	$42, %r8d
	movq	-128(%rbp), %rbx                ## 8-byte Reload
	movq	-176(%rbp), %r11                ## 8-byte Reload
	movq	-160(%rbp), %r9                 ## 8-byte Reload
	ja	LBB0_278
## %bb.301:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	-96(%rbp), %rcx                 ## 8-byte Reload
	shlq	$32, %rcx
	addq	-112(%rbp), %rcx                ## 8-byte Folded Reload
	addq	%rcx, %rax
	movq	72(%r9), %rcx
	movq	-104(%rbp), %rsi                ## 8-byte Reload
	addq	%rsi, %rcx
	movq	64(%r9), %rdx
	addq	%rsi, %rdx
	addq	$4096, %rdx                     ## imm = 0x1000
	leaq	LJTI0_1(%rip), %rdi
	movslq	(%rdi,%r8,4), %rsi
	addq	%rdi, %rsi
	jmpq	*%rsi
LBB0_302:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%r13, %rcx
	subq	%rdx, %rcx
	jb	LBB0_435
## %bb.303:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$7, %rcx
	jbe	LBB0_435
## %bb.304:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	%eax, (%rbx,%rdx)
	addq	$4, %rdx
	movq	%r13, %rcx
	subq	%rdx, %rcx
	jb	LBB0_442
## %bb.305:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rcx
	ja	LBB0_275
	jmp	LBB0_442
	.p2align	4
LBB0_306:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%rsi, -280(%rbp)                ## 8-byte Spill
	movq	(%rsi), %rbx
	movq	%rbx, %rdi
	leaq	L_.str.90(%rip), %rsi
	callq	_strcmp
	movl	%eax, %ecx
	movq	%r12, %rax
	testl	%ecx, %ecx
	je	LBB0_300
## %bb.307:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	%rbx, %rdi
	leaq	L_.str.91(%rip), %rsi
	callq	_strcmp
	movl	%eax, %ecx
	movq	%r14, %rax
	testl	%ecx, %ecx
	je	LBB0_300
## %bb.308:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	%rbx, %rdi
	leaq	L_.str.92(%rip), %rsi
	callq	_strcmp
	movl	%eax, %ecx
	movq	-272(%rbp), %rax                ## 8-byte Reload
	testl	%ecx, %ecx
	je	LBB0_300
## %bb.309:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	%rbx, %rdi
	leaq	L_.str.93(%rip), %rsi
	callq	_strcmp
	movl	%eax, %ecx
	movq	-272(%rbp), %rax                ## 8-byte Reload
	testl	%ecx, %ecx
	je	LBB0_300
## %bb.310:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	%rbx, %rdi
	leaq	L_.str.94(%rip), %rsi
	callq	_strcmp
	movl	%eax, %ecx
	movq	%r15, %rax
	testl	%ecx, %ecx
	je	LBB0_300
## %bb.311:                             ##   in Loop: Header=BB0_279 Depth=3
	movq	%rbx, %rdi
	leaq	L_.str.95(%rip), %rsi
	callq	_strcmp
	movl	%eax, %ecx
	movq	%r15, %rax
	testl	%ecx, %ecx
	je	LBB0_300
## %bb.312:                             ##   in Loop: Header=BB0_279 Depth=3
	xorl	%edx, %edx
	xorl	%eax, %eax
	movq	$0, -72(%rbp)                   ## 8-byte Folded Spill
	movq	$0, -192(%rbp)                  ## 8-byte Folded Spill
	movq	$0, -224(%rbp)                  ## 8-byte Folded Spill
	movq	%rbx, %rsi
	jmp	LBB0_314
	.p2align	4
LBB0_313:                               ##   in Loop: Header=BB0_314 Depth=4
	movq	-200(%rbp), %rax                ## 8-byte Reload
	incq	%rax
	cmpq	-184(%rbp), %rax                ## 8-byte Folded Reload
	je	LBB0_377
LBB0_314:                               ##   Parent Loop BB0_258 Depth=1
                                        ##     Parent Loop BB0_263 Depth=2
                                        ##       Parent Loop BB0_279 Depth=3
                                        ## =>      This Loop Header: Depth=4
                                        ##           Child Loop BB0_319 Depth 5
	movq	%rax, -200(%rbp)                ## 8-byte Spill
	imulq	$56, %rax, %rcx
	movq	-88(%rbp), %rax                 ## 8-byte Reload
	movq	48(%rax,%rcx), %r15
	testq	%r15, %r15
	je	LBB0_313
## %bb.315:                             ##   in Loop: Header=BB0_314 Depth=4
	addq	%rax, %rcx
	movq	%rcx, -136(%rbp)                ## 8-byte Spill
	movq	40(%rcx), %r13
	jmp	LBB0_319
	.p2align	4
LBB0_316:                               ##   in Loop: Header=BB0_319 Depth=5
	movq	%rbx, %rdx
LBB0_317:                               ##   in Loop: Header=BB0_319 Depth=5
	movq	%r12, %rsi
LBB0_318:                               ##   in Loop: Header=BB0_319 Depth=5
	addq	$56, %r13
	decq	%r15
	je	LBB0_313
LBB0_319:                               ##   Parent Loop BB0_258 Depth=1
                                        ##     Parent Loop BB0_263 Depth=2
                                        ##       Parent Loop BB0_279 Depth=3
                                        ##         Parent Loop BB0_314 Depth=4
                                        ## =>        This Inner Loop Header: Depth=5
	movzwl	8(%r13), %r14d
	testw	%r14w, %r14w
	je	LBB0_318
## %bb.320:                             ##   in Loop: Header=BB0_319 Depth=5
	movq	(%r13), %rdi
	cmpb	$0, (%rdi)
	je	LBB0_318
## %bb.321:                             ##   in Loop: Header=BB0_319 Depth=5
	movq	%rdx, %rbx
	movq	%rsi, %r12
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_316
## %bb.322:                             ##   in Loop: Header=BB0_319 Depth=5
	movzbl	32(%r13), %eax
	cmpb	$16, %al
	movq	%rbx, %rdx
	jb	LBB0_317
## %bb.324:                             ##   in Loop: Header=BB0_319 Depth=5
	cmpw	$-14, %r14w
	jne	LBB0_328
## %bb.325:                             ##   in Loop: Header=BB0_319 Depth=5
	movq	-192(%rbp), %rax                ## 8-byte Reload
	testq	%rax, %rax
	movq	%r12, %rsi
	je	LBB0_327
## %bb.326:                             ##   in Loop: Header=BB0_319 Depth=5
	movzbl	32(%rax), %eax
	andb	$-16, %al
	cmpb	$32, %al
	jne	LBB0_318
LBB0_327:                               ##   in Loop: Header=BB0_319 Depth=5
	movq	%r13, -192(%rbp)                ## 8-byte Spill
	movq	-136(%rbp), %rax                ## 8-byte Reload
	movq	%rax, -72(%rbp)                 ## 8-byte Spill
	jmp	LBB0_318
LBB0_328:                               ##   in Loop: Header=BB0_319 Depth=5
	testq	%rdx, %rdx
	je	LBB0_330
## %bb.329:                             ##   in Loop: Header=BB0_319 Depth=5
	movzbl	32(%rdx), %ecx
	andb	$-16, %cl
	cmpb	$32, %cl
	jne	LBB0_331
LBB0_330:                               ##   in Loop: Header=BB0_319 Depth=5
	movq	-136(%rbp), %rax                ## 8-byte Reload
	movq	%rax, -224(%rbp)                ## 8-byte Spill
	movq	%r13, %rdx
	jmp	LBB0_317
LBB0_331:                               ##   in Loop: Header=BB0_319 Depth=5
	andb	$-16, %al
	cmpb	$32, %al
	movq	%r12, %rsi
	je	LBB0_318
	jmp	LBB0_427
LBB0_332:                               ##   in Loop: Header=BB0_279 Depth=3
	testq	%r8, %r8
	jne	LBB0_334
## %bb.333:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	$8, %edx
	jmp	LBB0_293
LBB0_334:                               ##   in Loop: Header=BB0_279 Depth=3
	testl	%ecx, %ecx
	je	LBB0_278
	jmp	LBB0_430
LBB0_335:                               ##   in Loop: Header=BB0_279 Depth=3
	movl	$4, %ecx
	jmp	LBB0_367
LBB0_336:                               ##   in Loop: Header=BB0_279 Depth=3
	xorl	%ecx, %ecx
	movb	$1, %r8b
	jmp	LBB0_368
LBB0_337:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	LBB0_431
## %bb.338:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rsi
	jbe	LBB0_431
## %bb.339:                             ##   in Loop: Header=BB0_279 Depth=3
	subq	%rcx, %rax
	testb	$3, %al
	jne	LBB0_444
## %bb.340:                             ##   in Loop: Header=BB0_279 Depth=3
	sarq	$2, %rax
	leaq	-33554432(%rax), %rcx
	cmpq	$-67108865, %rcx                ## imm = 0xFBFFFFFF
	jbe	LBB0_445
## %bb.341:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	(%rbx,%rdx), %ecx
	movl	$-67108864, %esi                ## imm = 0xFC000000
	andl	%esi, %ecx
	cmpl	$335544320, %ecx                ## imm = 0x14000000
	jne	LBB0_448
## %bb.342:                             ##   in Loop: Header=BB0_279 Depth=3
	movb	%al, (%rbx,%rdx)
	movb	%ah, 1(%rbx,%rdx)
	movl	%eax, %ecx
	shrl	$16, %ecx
	movb	%cl, 2(%rbx,%rdx)
	shrl	$24, %eax
	andb	$3, %al
	orb	$20, %al
	jmp	LBB0_276
LBB0_343:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%r13, %rcx
	subq	%rdx, %rcx
	jb	LBB0_432
## %bb.344:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rcx
	jbe	LBB0_432
## %bb.345:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	(%rbx,%rdx), %esi
	movl	%esi, %ecx
	andl	$2130706432, %ecx               ## imm = 0x7F000000
	cmpl	$285212672, %ecx                ## imm = 0x11000000
	jne	LBB0_433
## %bb.346:                             ##   in Loop: Header=BB0_279 Depth=3
	testl	$4194304, %esi                  ## imm = 0x400000
	jne	LBB0_438
## %bb.347:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	%esi, %ecx
	andl	$-1853881345, %ecx              ## imm = 0x918003FF
	shll	$10, %eax
	andl	$4193280, %eax                  ## imm = 0x3FFC00
	orl	%ecx, %eax
	movb	%sil, (%rbx,%rdx)
	movb	%ah, 1(%rbx,%rdx)
	shrl	$16, %eax
	movb	%al, 2(%rbx,%rdx)
	shrl	$24, %esi
	jmp	LBB0_277
LBB0_348:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	LBB0_441
## %bb.349:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rsi
	jbe	LBB0_441
## %bb.350:                             ##   in Loop: Header=BB0_279 Depth=3
	andq	$-4096, %rcx                    ## imm = 0xF000
	subq	%rcx, %rax
	sarq	$12, %rax
	leaq	-1048576(%rax), %rcx
	cmpq	$-2097153, %rcx                 ## imm = 0xFFDFFFFF
	jbe	LBB0_434
## %bb.351:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	(%rbx,%rdx), %ecx
	movl	%ecx, %esi
	andl	$-1627389952, %esi              ## imm = 0x9F000000
	cmpl	$-1879048192, %esi              ## imm = 0x90000000
	jne	LBB0_439
## %bb.352:                             ##   in Loop: Header=BB0_279 Depth=3
	andl	$31, %ecx
	movl	%eax, %esi
	andl	$28, %esi
	leal	(%rcx,%rsi,8), %ecx
	movb	%cl, (%rbx,%rdx)
	movl	%eax, %ecx
	shrl	$5, %ecx
	movb	%cl, 1(%rbx,%rdx)
	movl	%eax, %ecx
	shrl	$13, %ecx
	movb	%cl, 2(%rbx,%rdx)
	shll	$5, %eax
	orb	$-112, %al
	jmp	LBB0_276
LBB0_353:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	LBB0_437
## %bb.354:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rsi
	jbe	LBB0_437
## %bb.355:                             ##   in Loop: Header=BB0_279 Depth=3
	subq	%rcx, %rax
	leaq	-1048576(%rax), %rcx
	cmpq	$-2097153, %rcx                 ## imm = 0xFFDFFFFF
	jbe	LBB0_440
## %bb.356:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	(%rbx,%rdx), %ecx
	movl	%ecx, %esi
	andl	$-1627389952, %esi              ## imm = 0x9F000000
	cmpl	$268435456, %esi                ## imm = 0x10000000
	jne	LBB0_436
## %bb.357:                             ##   in Loop: Header=BB0_279 Depth=3
	andl	$31, %ecx
	movl	%eax, %esi
	andl	$28, %esi
	leal	(%rcx,%rsi,8), %ecx
	movb	%cl, (%rbx,%rdx)
	movl	%eax, %ecx
	shrl	$5, %ecx
	movb	%cl, 1(%rbx,%rdx)
	movl	%eax, %ecx
	shrl	$13, %ecx
	movb	%cl, 2(%rbx,%rdx)
	shlb	$5, %al
	andb	$96, %al
	orb	$16, %al
	jmp	LBB0_276
LBB0_358:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	LBB0_447
## %bb.359:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rsi
	jbe	LBB0_447
## %bb.360:                             ##   in Loop: Header=BB0_279 Depth=3
	subq	%rcx, %rax
	testb	$3, %al
	jne	LBB0_449
## %bb.361:                             ##   in Loop: Header=BB0_279 Depth=3
	sarq	$2, %rax
	leaq	-33554432(%rax), %rcx
	cmpq	$-67108865, %rcx                ## imm = 0xFBFFFFFF
	jbe	LBB0_443
## %bb.362:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	(%rbx,%rdx), %ecx
	movl	$-67108864, %esi                ## imm = 0xFC000000
	andl	%esi, %ecx
	cmpl	$-1811939328, %ecx              ## imm = 0x94000000
	jne	LBB0_446
## %bb.363:                             ##   in Loop: Header=BB0_279 Depth=3
	movb	%al, (%rbx,%rdx)
	movb	%ah, 1(%rbx,%rdx)
	movl	%eax, %ecx
	shrl	$16, %ecx
	movb	%cl, 2(%rbx,%rdx)
	shrl	$24, %eax
	andb	$3, %al
	orb	$-108, %al
	jmp	LBB0_276
LBB0_364:                               ##   in Loop: Header=BB0_279 Depth=3
	movl	$1, %ecx
	jmp	LBB0_367
LBB0_365:                               ##   in Loop: Header=BB0_279 Depth=3
	movl	$3, %ecx
	jmp	LBB0_367
LBB0_366:                               ##   in Loop: Header=BB0_279 Depth=3
	movl	$2, %ecx
LBB0_367:                               ##   in Loop: Header=BB0_279 Depth=3
	xorl	%r8d, %r8d
LBB0_368:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	LBB0_415
## %bb.369:                             ##   in Loop: Header=BB0_279 Depth=3
	cmpq	$3, %rsi
	jbe	LBB0_415
## %bb.370:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	(%rbx,%rdx), %edi
	movl	%edi, %esi
	andl	$989855744, %esi                ## imm = 0x3B000000
	cmpl	$956301312, %esi                ## imm = 0x39000000
	jne	LBB0_413
## %bb.371:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	%edi, %r9d
	shrl	$30, %r9d
	movl	%edi, %esi
	shrl	$24, %esi
	movl	%edi, %r10d
	shrl	$21, %r10d
	andl	%esi, %r10d
	andl	$4, %r10d
	orl	%r9d, %r10d
	cmpl	%ecx, %r10d
	jne	LBB0_414
## %bb.372:                             ##   in Loop: Header=BB0_279 Depth=3
	testb	%r8b, %r8b
	movq	-160(%rbp), %r9                 ## 8-byte Reload
	je	LBB0_374
## %bb.373:                             ##   in Loop: Header=BB0_279 Depth=3
	xorl	%ecx, %ecx
	jmp	LBB0_376
LBB0_374:                               ##   in Loop: Header=BB0_279 Depth=3
	movl	$-1, %r8d
	shll	%cl, %r8d
	notl	%r8d
	testl	%r8d, %eax
	jne	LBB0_426
## %bb.375:                             ##   in Loop: Header=BB0_279 Depth=3
	movl	%ecx, %ecx
LBB0_376:                               ##   in Loop: Header=BB0_279 Depth=3
	andl	$4095, %eax                     ## imm = 0xFFF
                                        ## kill: def $cl killed $cl killed $rcx
	shrq	%cl, %rax
	movl	%edi, %ecx
	andl	$-37747713, %ecx                ## imm = 0xFDC003FF
	shll	$10, %eax
	orl	%ecx, %eax
	movb	%dil, (%rbx,%rdx)
	movb	%ah, 1(%rbx,%rdx)
	shrl	$16, %eax
	movb	%al, 2(%rbx,%rdx)
	jmp	LBB0_277
LBB0_377:                               ##   in Loop: Header=BB0_279 Depth=3
	movq	%rsi, %rax
	testq	%rdx, %rdx
	movq	-224(%rbp), %rdi                ## 8-byte Reload
	cmoveq	-72(%rbp), %rdi                 ## 8-byte Folded Reload
	movq	-192(%rbp), %rsi                ## 8-byte Reload
	cmovneq	%rdx, %rsi
	testq	%rsi, %rsi
	je	LBB0_462
## %bb.378:                             ##   in Loop: Header=BB0_279 Depth=3
	testq	%rdi, %rdi
	je	LBB0_462
## %bb.379:                             ##   in Loop: Header=BB0_279 Depth=3
	leaq	-336(%rbp), %rdx
	callq	_defined_symbol_value_for_relocation
	movq	-240(%rbp), %r13                ## 8-byte Reload
	movq	-256(%rbp), %r14                ## 8-byte Reload
	movq	-512(%rbp), %r15                ## 8-byte Reload
	movq	-504(%rbp), %r12                ## 8-byte Reload
	jmp	LBB0_300
LBB0_380:
	leaq	L_.str.116(%rip), %rsi
	movq	-208(%rbp), %rdi                ## 8-byte Reload
	callq	_fopen
	testq	%rax, %rax
	je	LBB0_533
## %bb.381:
	movq	%rax, %rbx
	movl	$1, %esi
	movq	-128(%rbp), %r14                ## 8-byte Reload
	movq	%r14, %rdi
	movq	%r13, %rdx
	movq	%rax, %rcx
	callq	_fwrite
	cmpq	%r13, %rax
	jne	LBB0_534
## %bb.382:
	movq	%rbx, %rdi
	callq	_fclose
	movq	%r14, %rdi
	callq	_free
	movq	-88(%rbp), %r15                 ## 8-byte Reload
	leaq	40(%r15), %rbx
	movq	-216(%rbp), %r14                ## 8-byte Reload
	.p2align	4
LBB0_383:                               ## =>This Inner Loop Header: Depth=1
	movq	(%rbx), %rdi
	callq	_free
	movq	-16(%rbx), %rdi
	callq	_free
	movq	-32(%rbx), %rdi
	callq	_free
	addq	$56, %rbx
	decq	%r14
	jne	LBB0_383
## %bb.384:
	movq	%r15, %rdi
	callq	_free
	movq	-232(%rbp), %rdi                ## 8-byte Reload
	callq	_free
	xorl	%eax, %eax
	jmp	LBB0_122
LBB0_385:
	callq	_main.cold.80
LBB0_386:
	callq	_main.cold.83
LBB0_387:
	callq	_main.cold.79
LBB0_388:
	callq	_main.cold.82
LBB0_389:
	callq	_main.cold.78
LBB0_390:
	callq	_main.cold.81
LBB0_391:
	leaq	L_.str.85(%rip), %rcx
	jmp	LBB0_394
LBB0_392:
	leaq	L_.str.64(%rip), %rsi
	leaq	-336(%rbp), %rdi
	callq	_die_relocation
LBB0_393:
	leaq	L_.str.84(%rip), %rcx
LBB0_394:
	leaq	-336(%rbp), %rdi
	movq	%rsi, %rdx
	movq	%r11, %rsi
	callq	_die_relocation_symbol
LBB0_395:
	leaq	L_.str.83(%rip), %rsi
	leaq	-336(%rbp), %rdi
	callq	_die_relocation
LBB0_396:
	callq	_main.cold.4
LBB0_397:
	callq	_main.cold.102
LBB0_398:
	callq	_main.cold.101
LBB0_399:
	callq	_main.cold.111
LBB0_400:
	callq	_main.cold.108
LBB0_401:
	callq	_main.cold.103
LBB0_402:
	callq	_main.cold.115
LBB0_403:
	callq	_main.cold.114
LBB0_404:
	callq	_main.cold.113
LBB0_405:
	callq	_main.cold.112
LBB0_406:
	callq	_main.cold.110
LBB0_407:
	callq	_main.cold.109
LBB0_408:
	callq	_main.cold.107
LBB0_409:
	callq	_main.cold.104
LBB0_410:
	callq	_main.cold.106
LBB0_411:
	callq	_main.cold.105
LBB0_412:
	leaq	L_.str.35(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_413:
	callq	_main.cold.74
LBB0_414:
	callq	_main.cold.75
LBB0_415:
	callq	_main.cold.77
LBB0_416:
	leaq	L_.str.22(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_417:
	callq	_main.cold.11
LBB0_418:
	callq	_main.cold.8
LBB0_419:
	callq	_main.cold.9
LBB0_420:
	callq	_main.cold.6
LBB0_421:
	callq	_main.cold.12
LBB0_422:
	callq	_main.cold.13
LBB0_423:
	callq	_main.cold.7
LBB0_424:
	callq	_main.cold.10
LBB0_425:
	callq	_main.cold.51
LBB0_426:
	callq	_main.cold.76
LBB0_427:
	movq	%rsi, %rdi
	callq	_main.cold.54
LBB0_428:
	callq	_main.cold.5
LBB0_429:
	callq	_main.cold.50
LBB0_430:
	leaq	L_.str.63(%rip), %rsi
	leaq	-336(%rbp), %rdi
	callq	_die_relocation
LBB0_431:
	callq	_main.cold.60
LBB0_432:
	callq	_main.cold.67
LBB0_433:
	callq	_main.cold.65
LBB0_434:
	callq	_main.cold.69
LBB0_435:
	callq	_main.cold.56
LBB0_436:
	callq	_main.cold.71
LBB0_437:
	callq	_main.cold.73
LBB0_438:
	callq	_main.cold.66
LBB0_439:
	callq	_main.cold.68
LBB0_440:
	callq	_main.cold.72
LBB0_441:
	callq	_main.cold.70
LBB0_442:
	callq	_main.cold.55
LBB0_443:
	callq	_main.cold.63
LBB0_444:
	callq	_main.cold.57
LBB0_445:
	callq	_main.cold.59
LBB0_446:
	callq	_main.cold.62
LBB0_447:
	callq	_main.cold.64
LBB0_448:
	callq	_main.cold.58
LBB0_449:
	callq	_main.cold.61
LBB0_450:
	movq	-80(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.14
LBB0_451:
	callq	_main.cold.52
LBB0_452:
	callq	_main.cold.84
LBB0_453:
	callq	_main.cold.53
LBB0_454:
	movq	%r11, %rdi
	movq	%r9, %rdx
	callq	_die_relocation_section
LBB0_455:
	movq	%r12, %rdi
	callq	_main.cold.2
LBB0_456:
	leaq	L_.str.15(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_457:
	leaq	L_.str.10(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_458:
	leaq	L_.str.17(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_459:
	leaq	L_.str.16(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_460:
	callq	_main.cold.20
LBB0_461:
	callq	_main.cold.49
LBB0_462:
	cmpb	$0, (%rax)
	jne	LBB0_484
## %bb.463:
	leaq	L_.str.86(%rip), %rcx
	jmp	LBB0_485
LBB0_464:
	callq	_main.cold.1
LBB0_465:
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.122
LBB0_466:
	leaq	L_.str.11(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_467:
	callq	_main.cold.121
LBB0_468:
	leaq	L_.str.18(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_469:
	leaq	L_.str.20(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_470:
	callq	_main.cold.120
LBB0_471:
	callq	_main.cold.119
LBB0_472:
	leaq	L_.str.19(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_473:
	callq	_main.cold.118
LBB0_474:
	callq	_main.cold.117
LBB0_475:
	leaq	L_.str.21(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_476:
	callq	_main.cold.116
LBB0_477:
	leaq	L_.str.34(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_478:
	leaq	L_.str.32(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_479:
	callq	_main.cold.100
LBB0_480:
	leaq	L_.str.33(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_481:
	leaq	L_.str.31(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_482:
	callq	_main.cold.18
LBB0_483:
	callq	_main.cold.19
LBB0_484:
	leaq	L_.str.87(%rip), %rcx
LBB0_485:
	leaq	-336(%rbp), %rdi
	movq	-176(%rbp), %rsi                ## 8-byte Reload
	movq	-280(%rbp), %rdx                ## 8-byte Reload
	callq	_die_relocation_symbol
LBB0_486:
	movq	-88(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.22
LBB0_487:
	leaq	L_.str.12(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_488:
	callq	_main.cold.48
LBB0_489:
	callq	_main.cold.47
LBB0_490:
	callq	_main.cold.46
LBB0_491:
	callq	_main.cold.45
LBB0_492:
	callq	_main.cold.44
LBB0_493:
	callq	_main.cold.43
LBB0_494:
	callq	_main.cold.42
LBB0_495:
	callq	_main.cold.41
LBB0_496:
	callq	_main.cold.40
LBB0_497:
	callq	_main.cold.39
LBB0_498:
	callq	_main.cold.38
LBB0_499:
	callq	_main.cold.37
LBB0_500:
	callq	_main.cold.36
LBB0_501:
	callq	_main.cold.35
LBB0_502:
	callq	_main.cold.23
LBB0_503:
	movq	-88(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.25
LBB0_504:
	callq	_main.cold.3
LBB0_505:
	callq	_main.cold.124
LBB0_506:
	callq	___stack_chk_fail
LBB0_507:
	leaq	LJTI0_0(%rip), %rax
	movslq	(%rax,%rcx,4), %rcx
	addq	%rax, %rcx
	jmpq	*%rcx
LBB0_508:
	callq	_main.cold.31
LBB0_509:
	callq	_main.cold.17
LBB0_510:
	callq	_main.cold.15
LBB0_511:
	callq	_main.cold.16
LBB0_512:
	movq	-88(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.24
LBB0_513:
	callq	_main.cold.99
LBB0_514:
	movq	-88(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.96
LBB0_515:
	callq	_main.cold.123
LBB0_516:
	callq	_main.cold.98
LBB0_517:
	callq	_main.cold.97
LBB0_518:
	callq	_main.cold.94
LBB0_519:
	callq	_main.cold.93
LBB0_520:
	callq	_main.cold.92
LBB0_521:
	callq	_main.cold.91
LBB0_522:
	callq	_main.cold.90
LBB0_523:
	callq	_main.cold.89
LBB0_524:
	callq	_main.cold.30
LBB0_525:
	callq	_main.cold.29
LBB0_526:
	callq	_main.cold.28
LBB0_527:
	callq	_main.cold.88
LBB0_528:
	callq	_main.cold.87
LBB0_529:
	callq	_main.cold.86
LBB0_530:
	callq	_main.cold.32
LBB0_531:
	callq	_main.cold.33
LBB0_532:
	callq	_main.cold.34
LBB0_533:
	movq	-208(%rbp), %rdi                ## 8-byte Reload
	callq	_main.cold.85
LBB0_534:
	leaq	L_.str.117(%rip), %rsi
	movq	-208(%rbp), %rdi                ## 8-byte Reload
	callq	_die_path
LBB0_535:
	callq	_main.cold.26
LBB0_536:
	callq	_main.cold.27
LBB0_537:
	callq	_main.cold.95
	.p2align	2
	.data_region jt32
L0_0_set_508 = LBB0_508-LJTI0_0
L0_0_set_524 = LBB0_524-LJTI0_0
L0_0_set_525 = LBB0_525-LJTI0_0
L0_0_set_526 = LBB0_526-LJTI0_0
LJTI0_0:
	.long	L0_0_set_508
	.long	L0_0_set_524
	.long	L0_0_set_525
	.long	L0_0_set_526
L0_1_set_302 = LBB0_302-LJTI0_1
L0_1_set_278 = LBB0_278-LJTI0_1
L0_1_set_353 = LBB0_353-LJTI0_1
L0_1_set_348 = LBB0_348-LJTI0_1
L0_1_set_343 = LBB0_343-LJTI0_1
L0_1_set_336 = LBB0_336-LJTI0_1
L0_1_set_337 = LBB0_337-LJTI0_1
L0_1_set_358 = LBB0_358-LJTI0_1
L0_1_set_364 = LBB0_364-LJTI0_1
L0_1_set_366 = LBB0_366-LJTI0_1
L0_1_set_365 = LBB0_365-LJTI0_1
L0_1_set_335 = LBB0_335-LJTI0_1
LJTI0_1:
	.long	L0_1_set_302
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_353
	.long	L0_1_set_348
	.long	L0_1_set_278
	.long	L0_1_set_343
	.long	L0_1_set_336
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_337
	.long	L0_1_set_358
	.long	L0_1_set_364
	.long	L0_1_set_366
	.long	L0_1_set_365
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_278
	.long	L0_1_set_335
	.end_data_region
                                        ## -- End function
	.p2align	4                               ## -- Begin function die
_die:                                   ## @die
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.7(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function die_path
_die_path:                              ## @die_path
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.13(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function place_matching
_place_matching:                        ## @place_matching
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$72, %rsp
	movq	%r9, -56(%rbp)                  ## 8-byte Spill
	movq	8(%rdi), %rax
	movq	%rax, -96(%rbp)                 ## 8-byte Spill
	testq	%rax, %rax
	je	LBB3_13
## %bb.1:
	movl	%ecx, %r9d
	movq	%rsi, %r10
	movq	%rdi, %r11
	movq	(%rdi), %rax
	movq	%rax, -64(%rbp)                 ## 8-byte Spill
	leaq	16(%rdi), %rax
	movq	%rax, -72(%rbp)                 ## 8-byte Spill
	xorl	%r12d, %r12d
	movl	%edx, -44(%rbp)                 ## 4-byte Spill
	movq	%r8, -88(%rbp)                  ## 8-byte Spill
	movq	%rdi, -80(%rbp)                 ## 8-byte Spill
	jmp	LBB3_2
	.p2align	4
LBB3_12:                                ##   in Loop: Header=BB3_2 Depth=1
	incq	%r12
	cmpq	-96(%rbp), %r12                 ## 8-byte Folded Reload
	je	LBB3_13
LBB3_2:                                 ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB3_4 Depth 2
	imulq	$56, %r12, %rax
	movq	-64(%rbp), %rcx                 ## 8-byte Reload
	movq	32(%rcx,%rax), %r14
	cmpq	$2, %r14
	jb	LBB3_12
## %bb.3:                               ##   in Loop: Header=BB3_2 Depth=1
	addq	-64(%rbp), %rax                 ## 8-byte Folded Reload
	movq	24(%rax), %r15
	movl	$172, %eax
	addq	%rax, %r15
	decq	%r14
	movq	%r12, -104(%rbp)                ## 8-byte Spill
	jmp	LBB3_4
LBB3_30:                                ##   in Loop: Header=BB3_4 Depth=2
	addq	%rcx, (%r10)
	.p2align	4
LBB3_31:                                ##   in Loop: Header=BB3_4 Depth=2
	addq	$88, %r15
	decq	%r14
	je	LBB3_12
LBB3_4:                                 ##   Parent Loop BB3_2 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	cmpl	$0, (%r15)
	jne	LBB3_31
## %bb.5:                               ##   in Loop: Header=BB3_4 Depth=2
	cmpl	%edx, -4(%r15)
	jne	LBB3_31
## %bb.6:                               ##   in Loop: Header=BB3_4 Depth=2
	movl	-76(%r15), %r13d
	xorl	%eax, %eax
	cmpl	$8, %r13d
	sete	%al
	cmpl	%eax, %r9d
	jne	LBB3_31
## %bb.7:                               ##   in Loop: Header=BB3_4 Depth=2
	testq	%r8, %r8
	je	LBB3_9
## %bb.8:                               ##   in Loop: Header=BB3_4 Depth=2
	movq	-84(%r15), %rdi
	movq	%r8, %rsi
	movl	%r9d, %ebx
	movq	%r10, %r12
	callq	_strcmp
	movq	-80(%rbp), %r11                 ## 8-byte Reload
	movq	%r12, %r10
	movq	-104(%rbp), %r12                ## 8-byte Reload
	movl	-44(%rbp), %edx                 ## 4-byte Reload
	movl	%ebx, %r9d
	movq	-88(%rbp), %r8                  ## 8-byte Reload
	testl	%eax, %eax
	jne	LBB3_31
LBB3_9:                                 ##   in Loop: Header=BB3_4 Depth=2
	movq	-36(%r15), %rcx
	movq	(%r10), %rax
	cmpq	$2, %rcx
	movl	$1, %esi
	cmovbq	%rsi, %rcx
	jb	LBB3_16
## %bb.10:                              ##   in Loop: Header=BB3_4 Depth=2
	leaq	-1(%rcx), %rsi
	testq	%rsi, %rcx
	jne	LBB3_11
## %bb.14:                              ##   in Loop: Header=BB3_4 Depth=2
	movq	%rcx, %rsi
	negq	%rsi
	cmpq	%rsi, %rax
	ja	LBB3_32
## %bb.15:                              ##   in Loop: Header=BB3_4 Depth=2
	addq	%rcx, %rax
	decq	%rax
	andq	%rsi, %rax
LBB3_16:                                ##   in Loop: Header=BB3_4 Depth=2
	movq	%rax, (%r10)
	movq	%rax, -20(%r15)
	movq	(%r10), %rdi
	addq	112(%r11), %rdi
	movq	%rdi, -12(%r15)
	movl	$1, (%r15)
	cmpl	$8, %r13d
	jne	LBB3_20
## %bb.17:                              ##   in Loop: Header=BB3_4 Depth=2
	movq	-56(%rbp), %rcx                 ## 8-byte Reload
	cmpl	$0, (%rcx)
	movl	%edx, %esi
	jne	LBB3_19
## %bb.18:                              ##   in Loop: Header=BB3_4 Depth=2
	movq	%rdi, 136(%r11)
	movq	-56(%rbp), %rcx                 ## 8-byte Reload
	movl	$1, (%rcx)
	movl	-4(%r15), %esi
LBB3_19:                                ##   in Loop: Header=BB3_4 Depth=2
	movq	-52(%r15), %rcx
	addq	%rcx, %rdi
	movq	%rdi, 144(%r11)
	jmp	LBB3_23
LBB3_20:                                ##   in Loop: Header=BB3_4 Depth=2
	movq	-52(%r15), %rcx
	movq	(%r10), %rsi
	addq	%rcx, %rsi
	cmpq	120(%r11), %rsi
	jbe	LBB3_22
## %bb.21:                              ##   in Loop: Header=BB3_4 Depth=2
	movq	%rsi, 120(%r11)
LBB3_22:                                ##   in Loop: Header=BB3_4 Depth=2
	movl	%edx, %esi
LBB3_23:                                ##   in Loop: Header=BB3_4 Depth=2
	movslq	%esi, %rsi
	shlq	$5, %rsi
	movq	-72(%rbp), %rbx                 ## 8-byte Reload
	leaq	(%rbx,%rsi), %rdi
	cmpl	$0, (%rbx,%rsi)
	jne	LBB3_25
## %bb.24:                              ##   in Loop: Header=BB3_4 Depth=2
	movl	$1, (%rdi)
	movq	%rax, 8(%rdi)
	movq	%rax, 16(%rdi)
	movq	%rax, 24(%rdi)
LBB3_25:                                ##   in Loop: Header=BB3_4 Depth=2
	addq	%rcx, %rax
	cmpl	$8, -76(%r15)
	je	LBB3_28
## %bb.26:                              ##   in Loop: Header=BB3_4 Depth=2
	cmpq	16(%rdi), %rax
	jbe	LBB3_28
## %bb.27:                              ##   in Loop: Header=BB3_4 Depth=2
	movq	%rax, 16(%rdi)
LBB3_28:                                ##   in Loop: Header=BB3_4 Depth=2
	cmpq	24(%rdi), %rax
	jbe	LBB3_30
## %bb.29:                              ##   in Loop: Header=BB3_4 Depth=2
	movq	%rax, 24(%rdi)
	jmp	LBB3_30
LBB3_13:
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB3_32:
	callq	_place_matching.cold.2
LBB3_11:
	callq	_place_matching.cold.1
                                        ## -- End function
	.p2align	4                               ## -- Begin function mark_matching_common_symbols
_mark_matching_common_symbols:          ## @mark_matching_common_symbols
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$72, %rsp
	movq	%r8, -96(%rbp)                  ## 8-byte Spill
	movq	%rcx, -88(%rbp)                 ## 8-byte Spill
	movq	%rdx, -104(%rbp)                ## 8-byte Spill
	movq	16(%rsi), %rdx
	movq	24(%rsi), %r8
	cmpq	$1, %rdx
	adcq	$0, %rdx
	movq	8(%rdi), %r9
	testq	%r9, %r9
	je	LBB4_27
## %bb.1:
	movq	%rsi, %r12
	movq	%rdi, -80(%rbp)                 ## 8-byte Spill
	movq	(%rdi), %r10
	xorl	%r13d, %r13d
	movq	%r9, -72(%rbp)                  ## 8-byte Spill
	movq	%r10, -48(%rbp)                 ## 8-byte Spill
	jmp	LBB4_2
	.p2align	4
LBB4_11:                                ##   in Loop: Header=BB4_2 Depth=1
	incq	%r13
	cmpq	%r9, %r13
	je	LBB4_12
LBB4_2:                                 ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB4_4 Depth 2
	imulq	$56, %r13, %rax
	movq	48(%r10,%rax), %r15
	testq	%r15, %r15
	je	LBB4_11
## %bb.3:                               ##   in Loop: Header=BB4_2 Depth=1
	addq	%r10, %rax
	movq	40(%rax), %r14
	movzwl	8(%r12), %ebx
	jmp	LBB4_4
	.p2align	4
LBB4_23:                                ##   in Loop: Header=BB4_4 Depth=2
	cmpq	%r12, %r14
	je	LBB4_24
	.p2align	4
LBB4_25:                                ##   in Loop: Header=BB4_4 Depth=2
	addq	$56, %r14
	decq	%r15
	je	LBB4_11
LBB4_4:                                 ##   Parent Loop BB4_2 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	cmpw	$-14, %bx
	jne	LBB4_25
## %bb.5:                               ##   in Loop: Header=BB4_4 Depth=2
	cmpw	$-14, 8(%r14)
	jne	LBB4_25
## %bb.6:                               ##   in Loop: Header=BB4_4 Depth=2
	movq	(%r12), %rdi
	cmpb	$0, (%rdi)
	je	LBB4_23
## %bb.7:                               ##   in Loop: Header=BB4_4 Depth=2
	movq	(%r14), %rsi
	cmpb	$0, (%rsi)
	je	LBB4_23
## %bb.8:                               ##   in Loop: Header=BB4_4 Depth=2
	cmpb	$16, 32(%r12)
	jb	LBB4_23
## %bb.9:                               ##   in Loop: Header=BB4_4 Depth=2
	cmpb	$15, 32(%r14)
	jbe	LBB4_23
## %bb.10:                              ##   in Loop: Header=BB4_4 Depth=2
	movq	%rdx, -64(%rbp)                 ## 8-byte Spill
	movq	%r8, -56(%rbp)                  ## 8-byte Spill
	callq	_strcmp
	movq	-48(%rbp), %r10                 ## 8-byte Reload
	movq	-72(%rbp), %r9                  ## 8-byte Reload
	movq	-56(%rbp), %r8                  ## 8-byte Reload
	movq	-64(%rbp), %rdx                 ## 8-byte Reload
	testl	%eax, %eax
	jne	LBB4_25
LBB4_24:                                ##   in Loop: Header=BB4_4 Depth=2
	movq	16(%r14), %rax
	movq	24(%r14), %rcx
	cmpq	%r8, %rcx
	cmovaq	%rcx, %r8
	cmpq	%rdx, %rax
	cmovaq	%rax, %rdx
	jmp	LBB4_25
LBB4_12:
	leaq	-1(%rdx), %rax
	testq	%rax, %rdx
	jne	LBB4_26
## %bb.13:
	movq	-80(%rbp), %rax                 ## 8-byte Reload
	movq	(%rax), %rcx
	xorl	%r14d, %r14d
	movq	%rcx, -48(%rbp)                 ## 8-byte Spill
	jmp	LBB4_14
	.p2align	4
LBB4_32:                                ##   in Loop: Header=BB4_14 Depth=1
	incq	%r14
	cmpq	%r9, %r14
	je	LBB4_28
LBB4_14:                                ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB4_16 Depth 2
	imulq	$56, %r14, %rax
	movq	48(%rcx,%rax), %r15
	testq	%r15, %r15
	je	LBB4_32
## %bb.15:                              ##   in Loop: Header=BB4_14 Depth=1
	addq	%rcx, %rax
	movq	40(%rax), %r13
	movzwl	8(%r12), %ebx
	jmp	LBB4_16
	.p2align	4
LBB4_29:                                ##   in Loop: Header=BB4_16 Depth=2
	cmpq	%r12, %r13
	je	LBB4_30
	.p2align	4
LBB4_31:                                ##   in Loop: Header=BB4_16 Depth=2
	addq	$56, %r13
	decq	%r15
	je	LBB4_32
LBB4_16:                                ##   Parent Loop BB4_14 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	cmpw	$-14, %bx
	jne	LBB4_31
## %bb.17:                              ##   in Loop: Header=BB4_16 Depth=2
	cmpw	$-14, 8(%r13)
	jne	LBB4_31
## %bb.18:                              ##   in Loop: Header=BB4_16 Depth=2
	movq	(%r12), %rdi
	cmpb	$0, (%rdi)
	je	LBB4_29
## %bb.19:                              ##   in Loop: Header=BB4_16 Depth=2
	movq	(%r13), %rsi
	cmpb	$0, (%rsi)
	je	LBB4_29
## %bb.20:                              ##   in Loop: Header=BB4_16 Depth=2
	cmpb	$16, 32(%r12)
	jb	LBB4_29
## %bb.21:                              ##   in Loop: Header=BB4_16 Depth=2
	cmpb	$15, 32(%r13)
	jbe	LBB4_29
## %bb.22:                              ##   in Loop: Header=BB4_16 Depth=2
	movq	%rdx, -64(%rbp)                 ## 8-byte Spill
	movq	%r8, -56(%rbp)                  ## 8-byte Spill
	callq	_strcmp
	movq	-48(%rbp), %rcx                 ## 8-byte Reload
	movq	-72(%rbp), %r9                  ## 8-byte Reload
	movq	-56(%rbp), %r8                  ## 8-byte Reload
	movq	-64(%rbp), %rdx                 ## 8-byte Reload
	testl	%eax, %eax
	jne	LBB4_31
LBB4_30:                                ##   in Loop: Header=BB4_16 Depth=2
	movq	-104(%rbp), %rax                ## 8-byte Reload
	movq	%rax, 40(%r13)
	movl	$1, 48(%r13)
	jmp	LBB4_31
LBB4_27:
	leaq	-1(%rdx), %rax
	testq	%rax, %rdx
	jne	LBB4_26
LBB4_28:
	movq	-88(%rbp), %rax                 ## 8-byte Reload
	movq	%r8, (%rax)
	movq	-96(%rbp), %rax                 ## 8-byte Reload
	movq	%rdx, (%rax)
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB4_26:
	callq	_mark_matching_common_symbols.cold.1
                                        ## -- End function
	.p2align	4                               ## -- Begin function die_relocation_section
_die_relocation_section:                ## @die_relocation_section
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rsi), %rax
	cmpb	$0, (%rax)
	movq	___stderrp@GOTPCREL(%rip), %rsi
	leaq	L_.str.67(%rip), %rcx
	cmovneq	%rax, %rcx
	movq	(%rsi), %rax
	movq	(%rdx), %rsi
	cmpb	$0, (%rsi)
	movq	(%rdi), %rdx
	leaq	L_.str.68(%rip), %r8
	cmovneq	%rsi, %r8
	leaq	L_.str.66(%rip), %rsi
	leaq	L_.str.59(%rip), %r9
	movq	%rax, %rdi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function die_relocation
_die_relocation:                        ## @die_relocation
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movq	%rsi, -72(%rbp)                 ## 8-byte Spill
	movq	%rdi, %rbx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	8(%rdi), %rcx
	movq	(%rcx), %rcx
	cmpb	$0, (%rcx)
	movq	(%rax), %rax
	movq	%rax, -64(%rbp)                 ## 8-byte Spill
	leaq	L_.str.67(%rip), %r12
	cmovneq	%rcx, %r12
	movq	16(%rdi), %rax
	movq	(%rax), %rax
	cmpb	$0, (%rax)
	movq	(%rdi), %rcx
	leaq	L_.str.68(%rip), %r13
	cmovneq	%rax, %r13
	movq	(%rcx), %r14
	movq	24(%rdi), %rax
	movq	%rax, -48(%rbp)                 ## 8-byte Spill
	movq	32(%rdi), %rax
	movq	%rax, -56(%rbp)                 ## 8-byte Spill
	movl	40(%rdi), %r15d
	movl	%r15d, %edi
	callq	_relocation_name
	movq	%rax, %r10
	subq	$8, %rsp
	leaq	L_.str.69(%rip), %rsi
	movq	-64(%rbp), %rdi                 ## 8-byte Reload
	movq	%r14, %rdx
	movq	%r12, %rcx
	movq	%r13, %r8
	movq	-48(%rbp), %r9                  ## 8-byte Reload
	xorl	%eax, %eax
	pushq	-72(%rbp)                       ## 8-byte Folded Reload
	pushq	48(%rbx)
	pushq	%r15
	pushq	%r10
	pushq	-56(%rbp)                       ## 8-byte Folded Reload
	callq	_fprintf
	addq	$48, %rsp
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function relocation_name
_relocation_name:                       ## @relocation_name
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
                                        ## kill: def $edi killed $edi def $rdi
	leal	-257(%rdi), %eax
	cmpl	$42, %eax
	ja	LBB7_1
## %bb.3:
	leaq	LJTI7_0(%rip), %rcx
	movslq	(%rcx,%rax,4), %rax
	addq	%rcx, %rax
	jmpq	*%rax
LBB7_4:
	leaq	L_.str.71(%rip), %rax
	popq	%rbp
	retq
LBB7_1:
	testl	%edi, %edi
	jne	LBB7_15
## %bb.2:
	leaq	L_.str.70(%rip), %rax
	popq	%rbp
	retq
LBB7_15:
	leaq	L_.str.82(%rip), %rax
	popq	%rbp
	retq
LBB7_10:
	leaq	L_.str.77(%rip), %rax
	popq	%rbp
	retq
LBB7_9:
	leaq	L_.str.76(%rip), %rax
	popq	%rbp
	retq
LBB7_7:
	leaq	L_.str.74(%rip), %rax
	popq	%rbp
	retq
LBB7_6:
	leaq	L_.str.73(%rip), %rax
	popq	%rbp
	retq
LBB7_11:
	leaq	L_.str.78(%rip), %rax
	popq	%rbp
	retq
LBB7_8:
	leaq	L_.str.75(%rip), %rax
	popq	%rbp
	retq
LBB7_14:
	leaq	L_.str.81(%rip), %rax
	popq	%rbp
	retq
LBB7_5:
	leaq	L_.str.72(%rip), %rax
	popq	%rbp
	retq
LBB7_13:
	leaq	L_.str.80(%rip), %rax
	popq	%rbp
	retq
LBB7_12:
	leaq	L_.str.79(%rip), %rax
	popq	%rbp
	retq
	.p2align	2
	.data_region jt32
L7_0_set_4 = LBB7_4-LJTI7_0
L7_0_set_15 = LBB7_15-LJTI7_0
L7_0_set_5 = LBB7_5-LJTI7_0
L7_0_set_6 = LBB7_6-LJTI7_0
L7_0_set_7 = LBB7_7-LJTI7_0
L7_0_set_8 = LBB7_8-LJTI7_0
L7_0_set_9 = LBB7_9-LJTI7_0
L7_0_set_10 = LBB7_10-LJTI7_0
L7_0_set_11 = LBB7_11-LJTI7_0
L7_0_set_12 = LBB7_12-LJTI7_0
L7_0_set_13 = LBB7_13-LJTI7_0
L7_0_set_14 = LBB7_14-LJTI7_0
LJTI7_0:
	.long	L7_0_set_4
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_5
	.long	L7_0_set_6
	.long	L7_0_set_15
	.long	L7_0_set_7
	.long	L7_0_set_8
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_9
	.long	L7_0_set_10
	.long	L7_0_set_11
	.long	L7_0_set_12
	.long	L7_0_set_13
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_15
	.long	L7_0_set_14
	.end_data_region
                                        ## -- End function
	.p2align	4                               ## -- Begin function die_relocation_symbol
_die_relocation_symbol:                 ## @die_relocation_symbol
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$56, %rsp
	movq	%rcx, -96(%rbp)                 ## 8-byte Spill
	movq	%rdx, -88(%rbp)                 ## 8-byte Spill
	movq	%rsi, -80(%rbp)                 ## 8-byte Spill
	movq	%rdi, %rbx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	8(%rdi), %rcx
	movq	(%rcx), %rcx
	cmpb	$0, (%rcx)
	movq	(%rax), %rax
	movq	%rax, -72(%rbp)                 ## 8-byte Spill
	leaq	L_.str.67(%rip), %r15
	cmovneq	%rcx, %r15
	movq	16(%rdi), %rax
	movq	(%rax), %rax
	cmpb	$0, (%rax)
	movq	(%rdi), %rcx
	leaq	L_.str.68(%rip), %r14
	cmovneq	%rax, %r14
	movq	(%rcx), %r12
	movq	24(%rdi), %rax
	movq	%rax, -56(%rbp)                 ## 8-byte Spill
	movq	32(%rdi), %rax
	movq	%rax, -64(%rbp)                 ## 8-byte Spill
	movl	40(%rdi), %r13d
	movl	%r13d, %edi
	callq	_relocation_name
	movq	%rax, -48(%rbp)                 ## 8-byte Spill
	movq	48(%rbx), %rbx
	movq	-80(%rbp), %rdi                 ## 8-byte Reload
	movq	-88(%rbp), %rsi                 ## 8-byte Reload
	callq	_relocation_symbol_name
	movq	%rax, %r10
	leaq	L_.str.88(%rip), %rsi
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	movq	%r12, %rdx
	movq	%r15, %rcx
	movq	%r14, %r8
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	xorl	%eax, %eax
	pushq	-96(%rbp)                       ## 8-byte Folded Reload
	pushq	%r10
	pushq	%rbx
	pushq	%r13
	pushq	-48(%rbp)                       ## 8-byte Folded Reload
	pushq	-64(%rbp)                       ## 8-byte Folded Reload
	callq	_fprintf
	addq	$48, %rsp
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function defined_symbol_value_for_relocation
_defined_symbol_value_for_relocation:   ## @defined_symbol_value_for_relocation
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rsi, %rax
	movq	%rdi, %rsi
	movzbl	32(%rax), %ecx
	cmpb	$32, %cl
	setb	%dil
	movl	%ecx, %r8d
	andb	$-16, %r8b
	cmpb	$32, %r8b
	sete	%r8b
	orb	%dil, %r8b
	je	LBB9_1
## %bb.3:
	testb	$12, %cl
	jne	LBB9_4
## %bb.5:
	movzwl	8(%rax), %ecx
	cmpl	$65522, %ecx                    ## imm = 0xFFF2
	je	LBB9_8
## %bb.6:
	cmpl	$65521, %ecx                    ## imm = 0xFFF1
	jne	LBB9_11
## %bb.7:
	movq	16(%rax), %rax
	popq	%rbp
	retq
LBB9_8:
	cmpl	$0, 48(%rax)
	je	LBB9_9
## %bb.10:
	movq	40(%rax), %rax
	popq	%rbp
	retq
LBB9_11:
	cmpq	%rcx, 32(%rsi)
	jbe	LBB9_12
## %bb.13:
	movq	24(%rsi), %rdi
	imulq	$88, %rcx, %rcx
	cmpl	$0, 84(%rdi,%rcx)
	je	LBB9_14
## %bb.15:
	addq	%rcx, %rdi
	movq	16(%rax), %rax
	addq	72(%rdi), %rax
	popq	%rbp
	retq
LBB9_1:
	leaq	L_.str.96(%rip), %rcx
	jmp	LBB9_2
LBB9_4:
	leaq	L_.str.97(%rip), %rcx
	jmp	LBB9_2
LBB9_9:
	leaq	L_.str.43(%rip), %rcx
	jmp	LBB9_2
LBB9_12:
	leaq	L_.str.98(%rip), %rcx
	jmp	LBB9_2
LBB9_14:
	leaq	L_.str.45(%rip), %rcx
LBB9_2:
	movq	%rdx, %rdi
	movq	%rax, %rdx
	callq	_die_relocation_symbol
                                        ## -- End function
	.p2align	4                               ## -- Begin function relocation_symbol_name
_relocation_symbol_name:                ## @relocation_symbol_name
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rsi), %rax
	cmpb	$0, (%rax)
	je	LBB10_1
LBB10_4:
	popq	%rbp
	retq
LBB10_1:
	movzbl	32(%rsi), %ecx
	andb	$15, %cl
	leaq	L_.str.89(%rip), %rax
	cmpb	$3, %cl
	jne	LBB10_4
## %bb.2:
	movzwl	8(%rsi), %ecx
	cmpq	%rcx, 32(%rdi)
	jbe	LBB10_4
## %bb.3:
	movq	24(%rdi), %rax
	imulq	$88, %rcx, %rcx
	movq	(%rax,%rcx), %rax
	popq	%rbp
	retq
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.1
_main.cold.1:                           ## @main.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.3(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.2
_main.cold.2:                           ## @main.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.8(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.3
_main.cold.3:                           ## @main.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.1(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.4
_main.cold.4:                           ## @main.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.24(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.5
_main.cold.5:                           ## @main.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.6
_main.cold.6:                           ## @main.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.24(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.7
_main.cold.7:                           ## @main.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.8
_main.cold.8:                           ## @main.cold.8
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.9
_main.cold.9:                           ## @main.cold.9
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.10
_main.cold.10:                          ## @main.cold.10
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.11
_main.cold.11:                          ## @main.cold.11
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.12
_main.cold.12:                          ## @main.cold.12
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.25(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.13
_main.cold.13:                          ## @main.cold.13
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.14
_main.cold.14:                          ## @main.cold.14
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.42(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.15
_main.cold.15:                          ## @main.cold.15
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.43(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.16
_main.cold.16:                          ## @main.cold.16
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.44(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.17
_main.cold.17:                          ## @main.cold.17
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.45(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.18
_main.cold.18:                          ## @main.cold.18
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.39(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.19
_main.cold.19:                          ## @main.cold.19
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.20
_main.cold.20:                          ## @main.cold.20
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.21
_main.cold.21:                          ## @main.cold.21
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rdi), %rdi
	leaq	L_.str.55(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.22
_main.cold.22:                          ## @main.cold.22
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rdi), %rdi
	leaq	L_.str.54(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.23
_main.cold.23:                          ## @main.cold.23
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rdi), %rdi
	leaq	L_.str.54(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.24
_main.cold.24:                          ## @main.cold.24
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rdi), %rdi
	leaq	L_.str.53(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.25
_main.cold.25:                          ## @main.cold.25
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rdi), %rdi
	leaq	L_.str.52(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.26
_main.cold.26:                          ## @main.cold.26
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.43(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.27
_main.cold.27:                          ## @main.cold.27
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.44(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.28
_main.cold.28:                          ## @main.cold.28
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.29
_main.cold.29:                          ## @main.cold.29
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.30
_main.cold.30:                          ## @main.cold.30
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.31
_main.cold.31:                          ## @main.cold.31
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.32
_main.cold.32:                          ## @main.cold.32
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.33
_main.cold.33:                          ## @main.cold.33
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.34
_main.cold.34:                          ## @main.cold.34
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.35
_main.cold.35:                          ## @main.cold.35
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.36
_main.cold.36:                          ## @main.cold.36
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.37
_main.cold.37:                          ## @main.cold.37
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.38
_main.cold.38:                          ## @main.cold.38
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.39
_main.cold.39:                          ## @main.cold.39
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.40
_main.cold.40:                          ## @main.cold.40
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.41
_main.cold.41:                          ## @main.cold.41
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.42
_main.cold.42:                          ## @main.cold.42
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.43
_main.cold.43:                          ## @main.cold.43
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.44
_main.cold.44:                          ## @main.cold.44
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.45
_main.cold.45:                          ## @main.cold.45
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.46
_main.cold.46:                          ## @main.cold.46
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.47
_main.cold.47:                          ## @main.cold.47
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.48
_main.cold.48:                          ## @main.cold.48
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.49
_main.cold.49:                          ## @main.cold.49
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.48(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.50
_main.cold.50:                          ## @main.cold.50
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.57(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.51
_main.cold.51:                          ## @main.cold.51
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.58(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.52
_main.cold.52:                          ## @main.cold.52
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.61(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.53
_main.cold.53:                          ## @main.cold.53
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.62(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.54
_main.cold.54:                          ## @main.cold.54
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.42(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.55
_main.cold.55:                          ## @main.cold.55
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.56
_main.cold.56:                          ## @main.cold.56
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.65(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.57
_main.cold.57:                          ## @main.cold.57
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.113(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.58
_main.cold.58:                          ## @main.cold.58
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.115(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.59
_main.cold.59:                          ## @main.cold.59
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.114(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.60
_main.cold.60:                          ## @main.cold.60
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.112(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.61
_main.cold.61:                          ## @main.cold.61
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.113(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.62
_main.cold.62:                          ## @main.cold.62
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.115(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.63
_main.cold.63:                          ## @main.cold.63
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.114(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.64
_main.cold.64:                          ## @main.cold.64
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.112(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.65
_main.cold.65:                          ## @main.cold.65
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.106(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.66
_main.cold.66:                          ## @main.cold.66
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.107(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.67
_main.cold.67:                          ## @main.cold.67
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.105(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.68
_main.cold.68:                          ## @main.cold.68
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.104(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.69
_main.cold.69:                          ## @main.cold.69
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.103(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.70
_main.cold.70:                          ## @main.cold.70
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.102(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.71
_main.cold.71:                          ## @main.cold.71
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.101(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.72
_main.cold.72:                          ## @main.cold.72
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.100(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.73
_main.cold.73:                          ## @main.cold.73
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.99(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.74
_main.cold.74:                          ## @main.cold.74
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.109(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.75
_main.cold.75:                          ## @main.cold.75
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.110(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.76
_main.cold.76:                          ## @main.cold.76
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.111(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.77
_main.cold.77:                          ## @main.cold.77
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.108(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.78
_main.cold.78:                          ## @main.cold.78
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.79
_main.cold.79:                          ## @main.cold.79
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.80
_main.cold.80:                          ## @main.cold.80
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.81
_main.cold.81:                          ## @main.cold.81
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.82
_main.cold.82:                          ## @main.cold.82
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.83
_main.cold.83:                          ## @main.cold.83
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.84
_main.cold.84:                          ## @main.cold.84
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.60(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.85
_main.cold.85:                          ## @main.cold.85
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rax
	movq	%rdi, %rbx
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.86
_main.cold.86:                          ## @main.cold.86
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.87
_main.cold.87:                          ## @main.cold.87
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.88
_main.cold.88:                          ## @main.cold.88
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.89
_main.cold.89:                          ## @main.cold.89
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.90
_main.cold.90:                          ## @main.cold.90
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.91
_main.cold.91:                          ## @main.cold.91
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.92
_main.cold.92:                          ## @main.cold.92
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.93
_main.cold.93:                          ## @main.cold.93
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.94
_main.cold.94:                          ## @main.cold.94
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.95
_main.cold.95:                          ## @main.cold.95
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.45(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.96
_main.cold.96:                          ## @main.cold.96
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rdi), %rdi
	leaq	L_.str.56(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.97
_main.cold.97:                          ## @main.cold.97
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.6(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.98
_main.cold.98:                          ## @main.cold.98
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.99
_main.cold.99:                          ## @main.cold.99
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.38(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.100
_main.cold.100:                         ## @main.cold.100
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.6(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.101
_main.cold.101:                         ## @main.cold.101
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.102
_main.cold.102:                         ## @main.cold.102
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.103
_main.cold.103:                         ## @main.cold.103
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.104
_main.cold.104:                         ## @main.cold.104
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.105
_main.cold.105:                         ## @main.cold.105
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.106
_main.cold.106:                         ## @main.cold.106
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.107
_main.cold.107:                         ## @main.cold.107
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.108
_main.cold.108:                         ## @main.cold.108
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.109
_main.cold.109:                         ## @main.cold.109
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.110
_main.cold.110:                         ## @main.cold.110
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.111
_main.cold.111:                         ## @main.cold.111
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.112
_main.cold.112:                         ## @main.cold.112
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.113
_main.cold.113:                         ## @main.cold.113
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.114
_main.cold.114:                         ## @main.cold.114
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.25(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.115
_main.cold.115:                         ## @main.cold.115
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.116
_main.cold.116:                         ## @main.cold.116
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.6(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.117
_main.cold.117:                         ## @main.cold.117
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.118
_main.cold.118:                         ## @main.cold.118
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.119
_main.cold.119:                         ## @main.cold.119
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.120
_main.cold.120:                         ## @main.cold.120
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.23(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.121
_main.cold.121:                         ## @main.cold.121
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.6(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.122
_main.cold.122:                         ## @main.cold.122
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rax
	movq	%rdi, %rbx
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.123
_main.cold.123:                         ## @main.cold.123
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.6(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.124
_main.cold.124:                         ## @main.cold.124
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.6(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function place_matching.cold.1
_place_matching.cold.1:                 ## @place_matching.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.39(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function place_matching.cold.2
_place_matching.cold.2:                 ## @place_matching.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function mark_matching_common_symbols.cold.1
_mark_matching_common_symbols.cold.1:   ## @mark_matching_common_symbols.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.46(%rip), %rdi
	callq	_die
                                        ## -- End function
	.section	__TEXT,__cstring,cstring_literals
L_.str.1:                               ## @.str.1
	.asciz	"-o requires an output path"

L_.str.2:                               ## @.str.2
	.asciz	"--base"

L_.str.3:                               ## @.str.3
	.asciz	"--base requires an address"

L_.str.4:                               ## @.str.4
	.asciz	"link_aarch64_user_elf: unknown option %s\n"

L_.str.5:                               ## @.str.5
	.asciz	"usage: link_aarch64_user_elf -o OUTPUT [--base 0xADDR] INPUT.o [INPUT.o ...]\n"

L_.str.6:                               ## @.str.6
	.asciz	"out of memory"

L_.str.7:                               ## @.str.7
	.asciz	"link_aarch64_user_elf: %s\n"

L_.str.8:                               ## @.str.8
	.asciz	"link_aarch64_user_elf: invalid address: %s\n"

L_.str.9:                               ## @.str.9
	.asciz	"rb"

L_.str.10:                              ## @.str.10
	.asciz	"seek failed"

L_.str.11:                              ## @.str.11
	.asciz	"tell failed"

L_.str.12:                              ## @.str.12
	.asciz	"read failed"

L_.str.13:                              ## @.str.13
	.asciz	"link_aarch64_user_elf: %s: %s\n"

L_.str.14:                              ## @.str.14
	.asciz	"\177ELF"

L_.str.15:                              ## @.str.15
	.asciz	"not an ELF file"

L_.str.16:                              ## @.str.16
	.asciz	"expected ELF64 little-endian"

L_.str.17:                              ## @.str.17
	.asciz	"expected AArch64 relocatable ELF"

L_.str.18:                              ## @.str.18
	.asciz	"section header size too small"

L_.str.19:                              ## @.str.19
	.asciz	"section string table index out of range"

L_.str.20:                              ## @.str.20
	.asciz	"section headers out of range"

L_.str.21:                              ## @.str.21
	.asciz	"section string table out of range"

L_.str.22:                              ## @.str.22
	.asciz	"section data out of range"

L_.str.23:                              ## @.str.23
	.asciz	"unexpected end of file"

L_.str.24:                              ## @.str.24
	.asciz	"string table offset out of range"

L_.str.25:                              ## @.str.25
	.asciz	"unterminated string table entry"

L_.str.26:                              ## @.str.26
	.asciz	"unsupported allocated section type"

L_.str.27:                              ## @.str.27
	.asciz	".text"

L_.str.28:                              ## @.str.28
	.asciz	".rodata"

L_.str.29:                              ## @.str.29
	.asciz	".data"

L_.str.30:                              ## @.str.30
	.asciz	".bss"

L_.str.31:                              ## @.str.31
	.asciz	"symbol string table link out of range"

L_.str.32:                              ## @.str.32
	.asciz	"symbol table entry size too small"

L_.str.33:                              ## @.str.33
	.asciz	"symbol table size is not a multiple of entry size"

L_.str.34:                              ## @.str.34
	.asciz	"symbol string table out of range"

L_.str.35:                              ## @.str.35
	.asciz	"missing symbol table"

L_.str.37:                              ## @.str.37
	.asciz	".text.pi4_abi_probe.entry"

L_.str.38:                              ## @.str.38
	.asciz	"missing loadable text"

L_.str.39:                              ## @.str.39
	.asciz	"section alignment is not a power of two"

L_.str.40:                              ## @.str.40
	.asciz	"section alignment overflow"

L_.str.41:                              ## @.str.41
	.asciz	"common symbol allocation overflow"

L_.str.42:                              ## @.str.42
	.asciz	"link_aarch64_user_elf: duplicate symbol: %s\n"

L_.str.43:                              ## @.str.43
	.asciz	"common symbol was not allocated"

L_.str.44:                              ## @.str.44
	.asciz	"symbol section out of range"

L_.str.45:                              ## @.str.45
	.asciz	"symbol is not in a loadable section"

L_.str.46:                              ## @.str.46
	.asciz	"common symbol alignment is not a power of two"

L_.str.47:                              ## @.str.47
	.asciz	"no allocated file-backed sections"

L_.str.48:                              ## @.str.48
	.asciz	"section output range is outside image"

L_.str.50:                              ## @.str.50
	.asciz	"write past output"

L_.str.51:                              ## @.str.51
	.asciz	"_start"

L_.str.52:                              ## @.str.52
	.asciz	"_start entry symbol must not be local"

L_.str.53:                              ## @.str.53
	.asciz	"_start entry symbol must be a function"

L_.str.54:                              ## @.str.54
	.asciz	"_start entry symbol must be in executable text"

L_.str.55:                              ## @.str.55
	.asciz	"duplicate _start entry symbol"

L_.str.56:                              ## @.str.56
	.asciz	"first input must define CRT0 _start entry symbol"

L_.str.57:                              ## @.str.57
	.asciz	"relocation target section out of range"

L_.str.58:                              ## @.str.58
	.asciz	"RELA section does not link to the symbol table"

L_.str.59:                              ## @.str.59
	.asciz	"REL relocation sections are unsupported; AArch64 user objects must use RELA"

L_.str.60:                              ## @.str.60
	.asciz	"cannot relocate into NOBITS section"

L_.str.61:                              ## @.str.61
	.asciz	"unsupported RELA entry size"

L_.str.62:                              ## @.str.62
	.asciz	"RELA section size is not a multiple of entry size"

L_.str.63:                              ## @.str.63
	.asciz	"unsupported AArch64 relocation"

L_.str.64:                              ## @.str.64
	.asciz	"relocation target range is outside section"

L_.str.65:                              ## @.str.65
	.asciz	"ABS64 relocation target outside output"

L_.str.66:                              ## @.str.66
	.asciz	"link_aarch64_user_elf: %s: %s -> %s: %s\n"

L_.str.67:                              ## @.str.67
	.asciz	"<unnamed-relocations>"

L_.str.68:                              ## @.str.68
	.asciz	"<unnamed-target>"

L_.str.69:                              ## @.str.69
	.asciz	"link_aarch64_user_elf: %s: %s -> %s relocation %zu offset 0x%llx type %s(%u) symbol %zu: %s\n"

L_.str.70:                              ## @.str.70
	.asciz	"R_AARCH64_NONE"

L_.str.71:                              ## @.str.71
	.asciz	"R_AARCH64_ABS64"

L_.str.72:                              ## @.str.72
	.asciz	"R_AARCH64_ADR_PREL_LO21"

L_.str.73:                              ## @.str.73
	.asciz	"R_AARCH64_ADR_PREL_PG_HI21"

L_.str.74:                              ## @.str.74
	.asciz	"R_AARCH64_ADD_ABS_LO12_NC"

L_.str.75:                              ## @.str.75
	.asciz	"R_AARCH64_LDST8_ABS_LO12_NC"

L_.str.76:                              ## @.str.76
	.asciz	"R_AARCH64_JUMP26"

L_.str.77:                              ## @.str.77
	.asciz	"R_AARCH64_CALL26"

L_.str.78:                              ## @.str.78
	.asciz	"R_AARCH64_LDST16_ABS_LO12_NC"

L_.str.79:                              ## @.str.79
	.asciz	"R_AARCH64_LDST32_ABS_LO12_NC"

L_.str.80:                              ## @.str.80
	.asciz	"R_AARCH64_LDST64_ABS_LO12_NC"

L_.str.81:                              ## @.str.81
	.asciz	"R_AARCH64_LDST128_ABS_LO12_NC"

L_.str.82:                              ## @.str.82
	.asciz	"UNKNOWN"

L_.str.83:                              ## @.str.83
	.asciz	"relocation symbol index out of range"

L_.str.84:                              ## @.str.84
	.asciz	"unsupported relocation symbol binding"

L_.str.85:                              ## @.str.85
	.asciz	"unsupported relocation symbol type"

L_.str.86:                              ## @.str.86
	.asciz	"relocation references an unnamed undefined symbol"

L_.str.87:                              ## @.str.87
	.asciz	"unresolved symbol"

L_.str.88:                              ## @.str.88
	.asciz	"link_aarch64_user_elf: %s: %s -> %s relocation %zu offset 0x%llx type %s(%u) symbol %zu (%s): %s\n"

L_.str.89:                              ## @.str.89
	.asciz	"<unnamed>"

L_.str.90:                              ## @.str.90
	.asciz	"__pi4_user_image_base"

L_.str.91:                              ## @.str.91
	.asciz	"__pi4_user_image_end"

L_.str.92:                              ## @.str.92
	.asciz	"__pi4_user_bss_start"

L_.str.93:                              ## @.str.93
	.asciz	"__bss_start"

L_.str.94:                              ## @.str.94
	.asciz	"__pi4_user_bss_end"

L_.str.95:                              ## @.str.95
	.asciz	"__bss_end"

L_.str.96:                              ## @.str.96
	.asciz	"unsupported resolved symbol binding"

L_.str.97:                              ## @.str.97
	.asciz	"unsupported resolved symbol type"

L_.str.98:                              ## @.str.98
	.asciz	"symbol section index is out of range"

L_.str.99:                              ## @.str.99
	.asciz	"ADR relocation target outside output"

L_.str.100:                             ## @.str.100
	.asciz	"ADR relocation is out of +/-1 MiB range"

L_.str.101:                             ## @.str.101
	.asciz	"ADR relocation target is not an ADR instruction"

L_.str.102:                             ## @.str.102
	.asciz	"ADRP relocation target outside output"

L_.str.103:                             ## @.str.103
	.asciz	"ADRP relocation is out of +/-4 GiB range"

L_.str.104:                             ## @.str.104
	.asciz	"ADRP relocation target is not an ADRP instruction"

L_.str.105:                             ## @.str.105
	.asciz	"ADD_LO12 relocation target outside output"

L_.str.106:                             ## @.str.106
	.asciz	"ADD_LO12 relocation target is not an ADD-immediate instruction"

L_.str.107:                             ## @.str.107
	.asciz	"ADD_LO12 relocation target uses a shifted immediate"

L_.str.108:                             ## @.str.108
	.asciz	"LDST_LO12 relocation target outside output"

L_.str.109:                             ## @.str.109
	.asciz	"LDST_LO12 relocation target is not a load/store unsigned-immediate instruction"

L_.str.110:                             ## @.str.110
	.asciz	"LDST_LO12 relocation target size does not match relocation"

L_.str.111:                             ## @.str.111
	.asciz	"LDST_LO12 relocation target is not aligned for access size"

L_.str.112:                             ## @.str.112
	.asciz	"branch relocation target outside output"

L_.str.113:                             ## @.str.113
	.asciz	"branch relocation target is not 4-byte aligned"

L_.str.114:                             ## @.str.114
	.asciz	"branch relocation is out of +/-128 MiB range"

L_.str.115:                             ## @.str.115
	.asciz	"branch relocation target has the wrong opcode"

L_.str.116:                             ## @.str.116
	.asciz	"wb"

L_.str.117:                             ## @.str.117
	.asciz	"write failed"

.subsections_via_symbols
