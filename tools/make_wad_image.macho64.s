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
	pushq	%rax
	movl	$131352, %eax                   ## imm = 0x20118
	callq	____chkstk_darwin
	subq	%rax, %rsp
	popq	%rax
	movq	%rsi, %r12
	movl	%edi, %r13d
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	movslq	%edi, %rdi
	movl	$8, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_299
## %bb.1:
	movq	%rax, %r14
	cmpl	$4, %r13d
	je	LBB0_5
## %bb.2:
	cmpl	$5, %r13d
	jne	LBB0_7
## %bb.3:
	movq	8(%r12), %rbx
	leaq	L_.str(%rip), %rsi
	movq	%rbx, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_9
## %bb.4:
	movq	32(%r12), %rdi
	movq	16(%r12), %rsi
	movq	24(%r12), %rdx
	movl	$1, %ecx
	callq	_mutate_root_marker
	jmp	LBB0_240
LBB0_5:
	movq	8(%r12), %rbx
	leaq	L_.str.1(%rip), %rsi
	movq	%rbx, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_9
## %bb.6:
	movq	16(%r12), %rsi
	movq	24(%r12), %rdi
	leaq	L_.str.2(%rip), %rdx
	xorl	%ecx, %ecx
	callq	_mutate_root_marker
	jmp	LBB0_240
LBB0_7:
	cmpl	$3, %r13d
	jl	LBB0_104
## %bb.8:
	movq	8(%r12), %rbx
LBB0_9:
	leaq	L_.str.3(%rip), %rsi
	movq	%rbx, %rdi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_101
LBB0_10:
	movq	%r14, -131296(%rbp)             ## 8-byte Spill
	movl	$1, %r14d
	movq	$0, -131224(%rbp)               ## 8-byte Folded Spill
	movl	$0, %eax
	movq	%rax, -131312(%rbp)             ## 8-byte Spill
	movl	$0, %eax
	movq	%rax, -131232(%rbp)             ## 8-byte Spill
	xorl	%ecx, %ecx
	movq	$0, -131304(%rbp)               ## 8-byte Folded Spill
	movq	$0, -131216(%rbp)               ## 8-byte Folded Spill
	movq	$0, -131288(%rbp)               ## 8-byte Folded Spill
	movq	$0, -131280(%rbp)               ## 8-byte Folded Spill
	movq	$0, -131208(%rbp)               ## 8-byte Folded Spill
	movq	$0, -131264(%rbp)               ## 8-byte Folded Spill
	xorl	%r15d, %r15d
	movq	$0, -131248(%rbp)               ## 8-byte Folded Spill
	movq	$0, -131256(%rbp)               ## 8-byte Folded Spill
	movq	%r12, -131336(%rbp)             ## 8-byte Spill
	movl	%r13d, -131268(%rbp)            ## 4-byte Spill
	jmp	LBB0_14
LBB0_11:                                ##   in Loop: Header=BB0_14 Depth=1
	movl	$1, %eax
	movq	%rax, -131232(%rbp)             ## 8-byte Spill
	.p2align	4
LBB0_12:                                ##   in Loop: Header=BB0_14 Depth=1
	movl	-131240(%rbp), %ecx             ## 4-byte Reload
LBB0_13:                                ##   in Loop: Header=BB0_14 Depth=1
	incl	%r14d
	cmpl	%r13d, %r14d
	jge	LBB0_73
LBB0_14:                                ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_61 Depth 2
                                        ##     Child Loop BB0_46 Depth 2
	movl	%ecx, -131240(%rbp)             ## 4-byte Spill
	movslq	%r14d, %rax
	movq	(%r12,%rax,8), %rbx
	movq	%rbx, %rdi
	leaq	L_.str.14(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_25
## %bb.15:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.15(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_25
## %bb.16:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.16(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_11
## %bb.17:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.17(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_27
## %bb.18:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.18(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_29
## %bb.19:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.19(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_30
## %bb.20:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.20(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_33
## %bb.21:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.22(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_49
## %bb.22:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.24(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_64
## %bb.23:                              ##   in Loop: Header=BB0_14 Depth=1
	cmpb	$45, (%rbx)
	movl	-131240(%rbp), %ecx             ## 4-byte Reload
	je	LBB0_322
## %bb.24:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	-131296(%rbp), %rax             ## 8-byte Reload
	movq	-131304(%rbp), %rdx             ## 8-byte Reload
	movq	%rbx, (%rax,%rdx,8)
	incq	%rdx
	movq	%rdx, -131304(%rbp)             ## 8-byte Spill
	jmp	LBB0_13
	.p2align	4
LBB0_25:                                ##   in Loop: Header=BB0_14 Depth=1
	incl	%r14d
	cmpl	%r13d, %r14d
	jge	LBB0_281
## %bb.26:                              ##   in Loop: Header=BB0_14 Depth=1
	movslq	%r14d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131224(%rbp)             ## 8-byte Spill
	jmp	LBB0_12
LBB0_27:                                ##   in Loop: Header=BB0_14 Depth=1
	incl	%r14d
	cmpl	%r13d, %r14d
	movl	-131240(%rbp), %ecx             ## 4-byte Reload
	jge	LBB0_298
## %bb.28:                              ##   in Loop: Header=BB0_14 Depth=1
	movslq	%r14d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131312(%rbp)             ## 8-byte Spill
	jmp	LBB0_13
LBB0_29:                                ##   in Loop: Header=BB0_14 Depth=1
	movl	$1, %ecx
	jmp	LBB0_13
LBB0_30:                                ##   in Loop: Header=BB0_14 Depth=1
	incl	%r14d
	cmpl	%r13d, %r14d
	jge	LBB0_304
## %bb.31:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	-131256(%rbp), %rbx             ## 8-byte Reload
	leaq	8(,%rbx,8), %rsi
	movq	-131216(%rbp), %rdi             ## 8-byte Reload
	callq	_realloc
	testq	%rax, %rax
	je	LBB0_305
## %bb.32:                              ##   in Loop: Header=BB0_14 Depth=1
	movslq	%r14d, %rcx
	movq	(%r12,%rcx,8), %rdx
	movq	%rax, -131216(%rbp)             ## 8-byte Spill
	movq	%rdx, (%rax,%rbx,8)
	incq	%rbx
	movq	%rbx, -131256(%rbp)             ## 8-byte Spill
	jmp	LBB0_12
LBB0_33:                                ##   in Loop: Header=BB0_14 Depth=1
	incl	%r14d
	cmpl	%r13d, %r14d
	jge	LBB0_307
## %bb.34:                              ##   in Loop: Header=BB0_14 Depth=1
	leaq	8(,%r15,8), %rax
	leaq	(%rax,%rax,2), %rsi
	movq	-131248(%rbp), %rdi             ## 8-byte Reload
	callq	_realloc
	movq	%rax, -131248(%rbp)             ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_311
## %bb.35:                              ##   in Loop: Header=BB0_14 Depth=1
	movslq	%r14d, %rax
	movq	(%r12,%rax,8), %r12
	movq	%r12, %rdi
	movl	$61, %esi
	callq	_strchr
	testq	%rax, %rax
	je	LBB0_302
## %bb.36:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rax, %rbx
	movq	%rax, %r13
	subq	%r12, %r13
	je	LBB0_302
## %bb.37:                              ##   in Loop: Header=BB0_14 Depth=1
	cmpb	$0, 1(%rbx)
	je	LBB0_302
## %bb.38:                              ##   in Loop: Header=BB0_14 Depth=1
	cmpq	$64, %r13
	jae	LBB0_310
## %bb.39:                              ##   in Loop: Header=BB0_14 Depth=1
	movl	$64, %ecx
	leaq	-131200(%rbp), %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	callq	___memcpy_chk
	movb	$0, -131200(%rbp,%r13)
	movq	$0, -131328(%rbp)
	movl	$4, %ecx
	leaq	-131200(%rbp), %rdi
	leaq	-96(%rbp), %rsi
	leaq	-131328(%rbp), %rdx
	callq	_parse_path83
	cmpq	$1, -131328(%rbp)
	jne	LBB0_308
## %bb.40:                              ##   in Loop: Header=BB0_14 Depth=1
	movl	-88(%rbp), %eax
	movl	$19525, %ecx                    ## imm = 0x4C45
	xorl	%ecx, %eax
	movzbl	-86(%rbp), %ecx
	xorl	$70, %ecx
	orw	%ax, %cx
	movq	-131336(%rbp), %r12             ## 8-byte Reload
	movl	-131268(%rbp), %r13d            ## 4-byte Reload
	jne	LBB0_309
## %bb.41:                              ##   in Loop: Header=BB0_14 Depth=1
	leaq	(%r15,%r15,2), %rax
	movq	-131248(%rbp), %rcx             ## 8-byte Reload
	leaq	(%rcx,%rax,8), %rax
	movl	-89(%rbp), %ecx
	movl	%ecx, 7(%rax)
	movq	-96(%rbp), %rcx
	movq	%rcx, (%rax)
	movq	(%rax), %rcx
	movabsq	$2314885604590964548, %rdx      ## imm = 0x202020314D4F4F44
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$4918308063554842957, %rsi      ## imm = 0x444157202020314D
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	LBB0_301
## %bb.42:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$2314934069018903883, %rdx      ## imm = 0x20204C454E52454B
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499685168104782, %rsi      ## imm = 0x464C4520204C454E
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	LBB0_301
## %bb.43:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$4778128234594521941, %rdx      ## imm = 0x424F525052455355
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499831985918034, %rsi      ## imm = 0x464C45424F525052
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	LBB0_301
## %bb.44:                              ##   in Loop: Header=BB0_14 Depth=1
	incq	%rbx
	movq	%rbx, 16(%rax)
	testq	%r15, %r15
	je	LBB0_71
## %bb.45:                              ##   in Loop: Header=BB0_14 Depth=1
	leaq	1(%r15), %rcx
	movq	-131248(%rbp), %rdx             ## 8-byte Reload
	.p2align	4
LBB0_46:                                ##   Parent Loop BB0_14 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	(%rdx), %rsi
	xorq	(%rax), %rsi
	movq	3(%rdx), %rdi
	xorq	3(%rax), %rdi
	orq	%rsi, %rdi
	je	LBB0_284
## %bb.47:                              ##   in Loop: Header=BB0_46 Depth=2
	addq	$24, %rdx
	decq	%r15
	jne	LBB0_46
## %bb.48:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rcx, %r15
	jmp	LBB0_12
LBB0_49:                                ##   in Loop: Header=BB0_14 Depth=1
	incl	%r14d
	cmpl	%r13d, %r14d
	jge	LBB0_323
## %bb.50:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	-131208(%rbp), %rax             ## 8-byte Reload
	leaq	8(,%rax,8), %rax
	leaq	(%rax,%rax,2), %rsi
	movq	-131264(%rbp), %rdi             ## 8-byte Reload
	callq	_realloc
	movq	%rax, -131264(%rbp)             ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_326
## %bb.51:                              ##   in Loop: Header=BB0_14 Depth=1
	movslq	%r14d, %rax
	movq	(%r12,%rax,8), %r12
	movq	%r12, %rdi
	movl	$61, %esi
	callq	_strchr
	testq	%rax, %rax
	je	LBB0_306
## %bb.52:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rax, %rbx
	movq	%rax, %r13
	subq	%r12, %r13
	je	LBB0_306
## %bb.53:                              ##   in Loop: Header=BB0_14 Depth=1
	cmpb	$0, 1(%rbx)
	je	LBB0_306
## %bb.54:                              ##   in Loop: Header=BB0_14 Depth=1
	cmpq	$64, %r13
	jae	LBB0_325
## %bb.55:                              ##   in Loop: Header=BB0_14 Depth=1
	movl	$64, %ecx
	leaq	-131200(%rbp), %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	callq	___memcpy_chk
	movb	$0, -131200(%rbp,%r13)
	movq	$0, -131328(%rbp)
	movl	$4, %ecx
	leaq	-131200(%rbp), %rdi
	leaq	-96(%rbp), %rsi
	leaq	-131328(%rbp), %rdx
	callq	_parse_path83
	cmpq	$1, -131328(%rbp)
	jne	LBB0_324
## %bb.56:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	-131208(%rbp), %rax             ## 8-byte Reload
	leaq	(%rax,%rax,2), %rax
	movq	-131264(%rbp), %rcx             ## 8-byte Reload
	leaq	(%rcx,%rax,8), %rax
	movl	-89(%rbp), %ecx
	movl	%ecx, 7(%rax)
	movq	-96(%rbp), %rcx
	movq	%rcx, (%rax)
	movq	(%rax), %rcx
	movabsq	$2314885604590964548, %rdx      ## imm = 0x202020314D4F4F44
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$4918308063554842957, %rsi      ## imm = 0x444157202020314D
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	movq	-131336(%rbp), %r12             ## 8-byte Reload
	movl	-131268(%rbp), %r13d            ## 4-byte Reload
	je	LBB0_303
## %bb.57:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$2314934069018903883, %rdx      ## imm = 0x20204C454E52454B
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499685168104782, %rsi      ## imm = 0x464C4520204C454E
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	LBB0_303
## %bb.58:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$4778128234594521941, %rdx      ## imm = 0x424F525052455355
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499831985918034, %rsi      ## imm = 0x464C45424F525052
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	LBB0_303
## %bb.59:                              ##   in Loop: Header=BB0_14 Depth=1
	incq	%rbx
	movq	%rbx, 16(%rax)
	movq	-131208(%rbp), %rcx             ## 8-byte Reload
	testq	%rcx, %rcx
	je	LBB0_72
## %bb.60:                              ##   in Loop: Header=BB0_14 Depth=1
	incq	%rcx
	movq	-131264(%rbp), %rdx             ## 8-byte Reload
	.p2align	4
LBB0_61:                                ##   Parent Loop BB0_14 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	(%rdx), %rsi
	xorq	(%rax), %rsi
	movq	3(%rdx), %rdi
	xorq	3(%rax), %rdi
	orq	%rsi, %rdi
	je	LBB0_293
## %bb.62:                              ##   in Loop: Header=BB0_61 Depth=2
	addq	$24, %rdx
	decq	-131208(%rbp)                   ## 8-byte Folded Spill
	jne	LBB0_61
## %bb.63:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rcx, -131208(%rbp)             ## 8-byte Spill
	jmp	LBB0_12
LBB0_64:                                ##   in Loop: Header=BB0_14 Depth=1
	incl	%r14d
	cmpl	%r13d, %r14d
	jge	LBB0_332
## %bb.65:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	-131288(%rbp), %rax             ## 8-byte Reload
	leaq	1(%rax), %rbx
	imulq	$104, %rbx, %rsi
	movq	-131280(%rbp), %rdi             ## 8-byte Reload
	callq	_realloc
	movq	%rax, -131280(%rbp)             ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_334
## %bb.66:                              ##   in Loop: Header=BB0_14 Depth=1
	movslq	%r14d, %rax
	movq	(%r12,%rax,8), %r12
	movq	%r12, %rdi
	movl	$61, %esi
	callq	_strchr
	testq	%rax, %rax
	je	LBB0_321
## %bb.67:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%r12, %rsi
	movq	%rax, %r13
	movq	%rax, %r12
	subq	%rsi, %r12
	je	LBB0_321
## %bb.68:                              ##   in Loop: Header=BB0_14 Depth=1
	cmpb	$0, 1(%r13)
	je	LBB0_321
## %bb.69:                              ##   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, -131384(%rbp)             ## 8-byte Spill
	cmpq	$96, %r12
	jae	LBB0_333
## %bb.70:                              ##   in Loop: Header=BB0_14 Depth=1
	imulq	$104, -131288(%rbp), %rbx       ## 8-byte Folded Reload
	addq	-131280(%rbp), %rbx             ## 8-byte Folded Reload
	incq	%r13
	movq	%rbx, %rdi
	movq	%r12, %rdx
	callq	_memcpy
	movb	$0, (%rbx,%r12)
	movq	%r13, 96(%rbx)
	movq	-131384(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131288(%rbp)             ## 8-byte Spill
	movq	-131336(%rbp), %r12             ## 8-byte Reload
	movl	-131268(%rbp), %r13d            ## 4-byte Reload
	jmp	LBB0_12
LBB0_71:                                ##   in Loop: Header=BB0_14 Depth=1
	movl	$1, %r15d
	jmp	LBB0_12
LBB0_72:                                ##   in Loop: Header=BB0_14 Depth=1
	movl	$1, %eax
	movq	%rax, -131208(%rbp)             ## 8-byte Spill
	jmp	LBB0_12
LBB0_73:
	movq	-131312(%rbp), %rbx             ## 8-byte Reload
	testq	%rbx, %rbx
	je	LBB0_103
## %bb.74:
	movl	%ecx, -131240(%rbp)             ## 4-byte Spill
	cmpq	$0, -131304(%rbp)               ## 8-byte Folded Reload
	jne	LBB0_312
## %bb.75:
	cmpq	$0, -131224(%rbp)               ## 8-byte Folded Reload
	jne	LBB0_312
## %bb.76:
	cmpl	$0, -131232(%rbp)               ## 4-byte Folded Reload
	jne	LBB0_312
## %bb.77:
	testq	%r15, %r15
	jne	LBB0_312
## %bb.78:
	cmpq	$0, -131208(%rbp)               ## 8-byte Folded Reload
	jne	LBB0_312
## %bb.79:
	cmpq	$0, -131288(%rbp)               ## 8-byte Folded Reload
	jne	LBB0_312
## %bb.80:
	movq	%rbx, %rdi
	callq	_read_file
	movq	%rax, -96(%rbp)
	movq	%rdx, -88(%rbp)
	cmpq	$536870912, %rdx                ## imm = 0x20000000
	jne	LBB0_313
## %bb.81:
	movq	%rax, %r14
	cmpw	$-21931, 510(%rax)              ## imm = 0xAA55
	jne	LBB0_314
## %bb.82:
	cmpl	$2048, 454(%r14)                ## imm = 0x800
	jne	LBB0_315
## %bb.83:
	cmpl	$1046528, 458(%r14)             ## imm = 0xFF800
	jne	LBB0_315
## %bb.84:
	cmpw	$-21931, 1049086(%r14)          ## imm = 0xAA55
	jne	LBB0_316
## %bb.85:
	cmpw	$512, 1048587(%r14)             ## imm = 0x200
	jne	LBB0_317
## %bb.86:
	cmpb	$16, 1048589(%r14)
	jne	LBB0_318
## %bb.87:
	leaq	L_str.515(%rip), %rdi
	callq	_puts
	leaq	L_.str.135(%rip), %rdi
	movq	%rbx, %rsi
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.136(%rip), %rdi
	movl	$536870912, %esi                ## imm = 0x20000000
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.137(%rip), %rdi
	movl	$2048, %esi                     ## imm = 0x800
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.138(%rip), %rdi
	movl	$1046528, %esi                  ## imm = 0xFF800
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.139(%rip), %rdi
	movl	$2561, %esi                     ## imm = 0xA01
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.140(%rip), %rdi
	movl	$2593, %esi                     ## imm = 0xA21
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.141(%rip), %rdi
	movl	$512, %esi                      ## imm = 0x200
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.142(%rip), %rdi
	movl	$65373, %esi                    ## imm = 0xFF5D
	xorl	%eax, %eax
	callq	_printf
	movq	%r14, -131224(%rbp)             ## 8-byte Spill
	addq	$1311232, %r14                  ## imm = 0x140200
	leaq	-131200(%rbp), %r15
	leaq	L_.str.143(%rip), %r13
	leaq	-96(%rbp), %rbx
	xorl	%r12d, %r12d
	jmp	LBB0_89
	.p2align	4
LBB0_88:                                ##   in Loop: Header=BB0_89 Depth=1
	incq	%r12
	addq	$32, %r14
	cmpq	$512, %r12                      ## imm = 0x200
	je	LBB0_93
LBB0_89:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14), %eax
	cmpl	$229, %eax
	je	LBB0_88
## %bb.90:                              ##   in Loop: Header=BB0_89 Depth=1
	testl	%eax, %eax
	je	LBB0_93
## %bb.91:                              ##   in Loop: Header=BB0_89 Depth=1
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	_format_fat_name
	movzbl	11(%r14), %ecx
	movzwl	26(%r14), %r8d
	movl	28(%r14), %r9d
	movq	%r13, %rdi
	movl	%r12d, %esi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	testb	$16, 11(%r14)
	je	LBB0_88
## %bb.92:                              ##   in Loop: Header=BB0_89 Depth=1
	movzwl	26(%r14), %edx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movl	$3, %ecx
	callq	_inspect_directory
	jmp	LBB0_88
LBB0_93:
	cmpq	$0, -131256(%rbp)               ## 8-byte Folded Reload
	je	LBB0_100
## %bb.94:
	leaq	-96(%rbp), %r14
	leaq	-131200(%rbp), %r15
	leaq	L_.str.151(%rip), %r12
	xorl	%ebx, %ebx
	.p2align	4
LBB0_95:                                ## =>This Inner Loop Header: Depth=1
	movq	-131216(%rbp), %rax             ## 8-byte Reload
	movq	(%rax,%rbx,8), %r13
	movq	%r14, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_inspect_find_path
	testl	%eax, %eax
	je	LBB0_285
## %bb.96:                              ##   in Loop: Header=BB0_95 Depth=1
	testb	$16, -131196(%rbp)
	jne	LBB0_288
## %bb.97:                              ##   in Loop: Header=BB0_95 Depth=1
	movl	-131188(%rbp), %edx
	testl	%edx, %edx
	je	LBB0_286
## %bb.98:                              ##   in Loop: Header=BB0_95 Depth=1
	movl	-131192(%rbp), %ecx
	leal	-65375(%rcx), %eax
	cmpl	$-65374, %eax                   ## imm = 0xFFFF00A2
	jbe	LBB0_287
## %bb.99:                              ##   in Loop: Header=BB0_95 Depth=1
	movq	%r12, %rdi
	movq	%r13, %rsi
                                        ## kill: def $ecx killed $ecx killed $rcx
	xorl	%eax, %eax
	callq	_printf
	incq	%rbx
	cmpq	%rbx, -131256(%rbp)             ## 8-byte Folded Reload
	jne	LBB0_95
LBB0_100:
	leaq	-96(%rbp), %rdi
	movl	-131240(%rbp), %esi             ## 4-byte Reload
	callq	_inspect_pi4_manifest
	movq	-131224(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-131216(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-131248(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-131264(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-131280(%rbp), %rdi             ## 8-byte Reload
	jmp	LBB0_265
LBB0_101:
	movq	%r14, -131296(%rbp)             ## 8-byte Spill
	xorps	%xmm0, %xmm0
	movaps	%xmm0, -131088(%rbp)
	movaps	%xmm0, -131104(%rbp)
	movaps	%xmm0, -131120(%rbp)
	movaps	%xmm0, -131136(%rbp)
	movaps	%xmm0, -131152(%rbp)
	movaps	%xmm0, -131168(%rbp)
	movaps	%xmm0, -131184(%rbp)
	movaps	%xmm0, -131200(%rbp)
	movq	$0, -131072(%rbp)
	movq	16(%r12), %rax
	movq	%rax, -131256(%rbp)             ## 8-byte Spill
	cmpl	$4, %r13d
	jb	LBB0_132
## %bb.102:
	movq	$0, -131248(%rbp)               ## 8-byte Folded Spill
	movq	-131160(%rbp), %rax
	movq	%rax, -131232(%rbp)             ## 8-byte Spill
	movq	-131168(%rbp), %rax
	movq	%rax, -131208(%rbp)             ## 8-byte Spill
	movq	-131184(%rbp), %rax
	movq	%rax, -131224(%rbp)             ## 8-byte Spill
	movq	-131176(%rbp), %rax
	movq	%rax, -131216(%rbp)             ## 8-byte Spill
	movl	$3, %r15d
	movl	$0, -131312(%rbp)               ## 4-byte Folded Spill
	xorl	%r14d, %r14d
	movq	$0, -131240(%rbp)               ## 8-byte Folded Spill
	jmp	LBB0_135
LBB0_103:
	movq	-131296(%rbp), %r14             ## 8-byte Reload
	jmp	LBB0_105
LBB0_104:
	movq	$0, -131224(%rbp)               ## 8-byte Folded Spill
	movl	$0, %eax
	movq	%rax, -131232(%rbp)             ## 8-byte Spill
	movl	$0, %ecx
	movl	$0, %eax
	movq	%rax, -131304(%rbp)             ## 8-byte Spill
	movl	$0, %eax
	movq	%rax, -131216(%rbp)             ## 8-byte Spill
	movl	$0, %eax
	movq	%rax, -131288(%rbp)             ## 8-byte Spill
	movl	$0, %eax
	movq	%rax, -131280(%rbp)             ## 8-byte Spill
	movl	$0, %eax
	movq	%rax, -131208(%rbp)             ## 8-byte Spill
	movl	$0, %eax
	movq	%rax, -131264(%rbp)             ## 8-byte Spill
	movl	$0, %r15d
	movl	$0, %eax
	movq	%rax, -131248(%rbp)             ## 8-byte Spill
	movl	$0, %eax
	movq	%rax, -131256(%rbp)             ## 8-byte Spill
	cmpl	$2, %r13d
	je	LBB0_10
LBB0_105:
	testl	%ecx, %ecx
	jne	LBB0_319
## %bb.106:
	cmpq	$0, -131256(%rbp)               ## 8-byte Folded Reload
	jne	LBB0_319
## %bb.107:
	movq	-131304(%rbp), %r12             ## 8-byte Reload
	leaq	-4(%r12), %rax
	cmpq	$3, %rax
	movq	-131216(%rbp), %r13             ## 8-byte Reload
	movq	-131264(%rbp), %r9              ## 8-byte Reload
	jb	LBB0_109
## %bb.108:
	cmpq	$1, %r12
	jne	LBB0_337
LBB0_109:
	testq	%r15, %r15
	movq	-131248(%rbp), %r10             ## 8-byte Reload
	movq	-131208(%rbp), %rbx             ## 8-byte Reload
	je	LBB0_116
## %bb.110:
	xorl	%eax, %eax
	jmp	LBB0_112
	.p2align	4
LBB0_111:                               ##   in Loop: Header=BB0_112 Depth=1
	incq	%rax
	cmpq	%r15, %rax
	je	LBB0_116
LBB0_112:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_114 Depth 2
	testq	%rax, %rax
	je	LBB0_111
## %bb.113:                             ##   in Loop: Header=BB0_112 Depth=1
	leaq	(%rax,%rax,2), %rcx
	leaq	(%r10,%rcx,8), %rcx
	movq	%r10, %rdx
	movq	%rax, %rsi
	.p2align	4
LBB0_114:                               ##   Parent Loop BB0_112 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	LBB0_277
## %bb.115:                             ##   in Loop: Header=BB0_114 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	LBB0_114
	jmp	LBB0_111
LBB0_116:
	testq	%rbx, %rbx
	je	LBB0_127
## %bb.117:
	xorl	%eax, %eax
	jmp	LBB0_119
	.p2align	4
LBB0_118:                               ##   in Loop: Header=BB0_119 Depth=1
	incq	%rax
	cmpq	%rbx, %rax
	je	LBB0_127
LBB0_119:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_121 Depth 2
                                        ##     Child Loop BB0_125 Depth 2
	testq	%rax, %rax
	je	LBB0_123
## %bb.120:                             ##   in Loop: Header=BB0_119 Depth=1
	leaq	(%rax,%rax,2), %rcx
	leaq	(%r9,%rcx,8), %rcx
	movq	%r9, %rdx
	movq	%rax, %rsi
	.p2align	4
LBB0_121:                               ##   Parent Loop BB0_119 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	LBB0_278
## %bb.122:                             ##   in Loop: Header=BB0_121 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	LBB0_121
LBB0_123:                               ##   in Loop: Header=BB0_119 Depth=1
	testq	%r15, %r15
	je	LBB0_118
## %bb.124:                             ##   in Loop: Header=BB0_119 Depth=1
	leaq	(%rax,%rax,2), %rcx
	leaq	(%r9,%rcx,8), %rcx
	movq	%r10, %rdx
	movq	%r15, %rsi
	.p2align	4
LBB0_125:                               ##   Parent Loop BB0_119 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	LBB0_279
## %bb.126:                             ##   in Loop: Header=BB0_125 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	LBB0_125
	jmp	LBB0_118
LBB0_127:
	movq	$536870912, -131192(%rbp)       ## imm = 0x20000000
	movl	$536870912, %edi                ## imm = 0x20000000
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_320
## %bb.128:
	movq	%rax, -131200(%rbp)
	leaq	-131184(%rbp), %rdi
	movl	$131072, %esi                   ## imm = 0x20000
	callq	___bzero
	cmpq	$3, %r12
	movq	%r13, -131216(%rbp)             ## 8-byte Spill
	jbe	LBB0_131
## %bb.129:
	movq	8(%r14), %rdx
	movq	16(%r14), %rcx
	movq	24(%r14), %r8
	cmpq	$4, %r12
	jne	LBB0_237
## %bb.130:
	xorl	%r9d, %r9d
	jmp	LBB0_239
LBB0_131:
	xorl	%r9d, %r9d
	xorl	%ecx, %ecx
	xorl	%edx, %edx
	xorl	%r8d, %r8d
	jmp	LBB0_239
LBB0_132:
	xorl	%eax, %eax
	jmp	LBB0_174
LBB0_133:                               ##   in Loop: Header=BB0_135 Depth=1
	movl	$1, %eax
	movq	%rax, -131248(%rbp)             ## 8-byte Spill
	.p2align	4
LBB0_134:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_173
LBB0_135:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_169 Depth 2
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rbx
	movq	%rbx, %rdi
	leaq	L_.str.4(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_150
## %bb.136:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.5(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_152
## %bb.137:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.6(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_154
## %bb.138:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.7(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_156
## %bb.139:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.8(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_158
## %bb.140:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.9(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_160
## %bb.141:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.10(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_133
## %bb.142:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.11(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_162
## %bb.143:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.12(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_163
## %bb.144:                             ##   in Loop: Header=BB0_135 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.13(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB0_294
## %bb.145:                             ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.146:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rbx
	movq	$0, -96(%rbp)
	movq	%rbx, %rdi
	leaq	-96(%rbp), %rsi
	movl	$10, %edx
	callq	_strtol
	movq	-96(%rbp), %rcx
	cmpq	%rbx, %rcx
	je	LBB0_335
## %bb.147:                             ##   in Loop: Header=BB0_135 Depth=1
	cmpb	$61, (%rcx)
	jne	LBB0_335
## %bb.148:                             ##   in Loop: Header=BB0_135 Depth=1
	cmpq	$6, %rax
	jae	LBB0_335
## %bb.149:                             ##   in Loop: Header=BB0_135 Depth=1
	incq	%rcx
	movq	%rcx, -131112(%rbp,%rax,8)
	jmp	LBB0_134
	.p2align	4
LBB0_150:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.151:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131240(%rbp)             ## 8-byte Spill
	jmp	LBB0_134
	.p2align	4
LBB0_152:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.153:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131192(%rbp)
	jmp	LBB0_134
LBB0_154:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.155:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131224(%rbp)             ## 8-byte Spill
	jmp	LBB0_134
LBB0_156:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.157:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131216(%rbp)             ## 8-byte Spill
	jmp	LBB0_134
LBB0_158:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.159:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131208(%rbp)             ## 8-byte Spill
	jmp	LBB0_134
LBB0_160:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.161:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, -131232(%rbp)             ## 8-byte Spill
	jmp	LBB0_134
LBB0_162:                               ##   in Loop: Header=BB0_135 Depth=1
	movl	$1, -131312(%rbp)               ## 4-byte Folded Spill
	jmp	LBB0_134
LBB0_163:                               ##   in Loop: Header=BB0_135 Depth=1
	incl	%r15d
	cmpl	%r13d, %r15d
	jge	LBB0_294
## %bb.164:                             ##   in Loop: Header=BB0_135 Depth=1
	movslq	%r15d, %rax
	movq	(%r12,%rax,8), %rbx
	movq	$0, -96(%rbp)
	movq	%rbx, %rdi
	leaq	-96(%rbp), %rsi
	movl	$10, %edx
	callq	_strtol
	movq	-96(%rbp), %rcx
	cmpq	%rbx, %rcx
	je	LBB0_339
## %bb.165:                             ##   in Loop: Header=BB0_135 Depth=1
	cmpb	$0, (%rcx)
	jne	LBB0_339
## %bb.166:                             ##   in Loop: Header=BB0_135 Depth=1
	cmpq	$5, %rax
	ja	LBB0_339
## %bb.167:                             ##   in Loop: Header=BB0_135 Depth=1
	testq	%r14, %r14
	je	LBB0_172
## %bb.168:                             ##   in Loop: Header=BB0_135 Depth=1
	xorl	%ecx, %ecx
	.p2align	4
LBB0_169:                               ##   Parent Loop BB0_135 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	cmpl	%eax, -131144(%rbp,%rcx,4)
	je	LBB0_134
## %bb.170:                             ##   in Loop: Header=BB0_169 Depth=2
	incq	%rcx
	cmpq	%rcx, %r14
	jne	LBB0_169
## %bb.171:                             ##   in Loop: Header=BB0_135 Depth=1
	cmpq	$6, %r14
	jae	LBB0_340
LBB0_172:                               ##   in Loop: Header=BB0_135 Depth=1
	movl	%eax, -131144(%rbp,%r14,4)
	incq	%r14
	jmp	LBB0_134
LBB0_173:
	movq	-131232(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131160(%rbp)
	movq	-131208(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131168(%rbp)
	movq	-131216(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131176(%rbp)
	movq	-131224(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131184(%rbp)
	movq	%r14, -131120(%rbp)
	movl	-131312(%rbp), %eax             ## 4-byte Reload
	movl	%eax, -131148(%rbp)
	movq	-131248(%rbp), %rax             ## 8-byte Reload
	movl	%eax, -131152(%rbp)
	movq	-131240(%rbp), %rax             ## 8-byte Reload
LBB0_174:
	movq	%rax, -131200(%rbp)
	movq	-131256(%rbp), %rbx             ## 8-byte Reload
	movq	%rbx, %rdi
	callq	_read_file
	movq	%rax, %r14
	movq	%rax, -131328(%rbp)
	movq	%rdx, -131320(%rbp)
	leaq	-131328(%rbp), %rdi
	movq	%rbx, %rsi
	callq	_validate_image_layout
	xorps	%xmm0, %xmm0
	movaps	%xmm0, -131360(%rbp)
	movaps	%xmm0, -131376(%rbp)
	movq	-131200(%rbp), %rbx
	testq	%rbx, %rbx
	je	LBB0_176
## %bb.175:
	movq	%rbx, %rdi
	callq	_read_file
	movq	%rax, -131240(%rbp)             ## 8-byte Spill
	movq	%rax, -131360(%rbp)
	movq	%rdx, -131352(%rbp)
	leaq	-131360(%rbp), %rdi
	movq	%rbx, %rsi
	callq	_validate_image_layout
	jmp	LBB0_177
LBB0_176:
	movq	$0, -131240(%rbp)               ## 8-byte Folded Spill
LBB0_177:
	movq	-131192(%rbp), %rbx
	testq	%rbx, %rbx
	je	LBB0_179
## %bb.178:
	movq	%rbx, %rdi
	callq	_read_file
	movq	%rax, -131224(%rbp)             ## 8-byte Spill
	movq	%rax, -131376(%rbp)
	movq	%rdx, -131368(%rbp)
	leaq	-131376(%rbp), %rdi
	movq	%rbx, %rsi
	callq	_validate_image_layout
	jmp	LBB0_180
LBB0_179:
	movq	$0, -131224(%rbp)               ## 8-byte Folded Spill
LBB0_180:
	movl	-131152(%rbp), %ebx
	testl	%ebx, %ebx
	je	LBB0_190
## %bb.181:
	xorl	%eax, %eax
	movabsq	$2329570836308444484, %rcx      ## imm = 0x20544C5541464544
	movabsq	$5135866231194932545, %rdx      ## imm = 0x47464320544C5541
	jmp	LBB0_183
	.p2align	4
LBB0_182:                               ##   in Loop: Header=BB0_183 Depth=1
	addq	$32, %rax
	cmpq	$16384, %rax                    ## imm = 0x4000
	je	LBB0_280
LBB0_183:                               ## =>This Inner Loop Header: Depth=1
	movzbl	1311232(%r14,%rax), %esi
	cmpl	$229, %esi
	je	LBB0_182
## %bb.184:                             ##   in Loop: Header=BB0_183 Depth=1
	testl	%esi, %esi
	je	LBB0_280
## %bb.185:                             ##   in Loop: Header=BB0_183 Depth=1
	movq	1311232(%r14,%rax), %rsi
	xorq	%rcx, %rsi
	movq	1311235(%r14,%rax), %rdi
	xorq	%rdx, %rdi
	orq	%rsi, %rdi
	jne	LBB0_182
## %bb.186:
	testb	$16, 1311243(%r14,%rax)
	jne	LBB0_328
## %bb.187:
	cmpl	$0, 1311260(%r14,%rax)
	je	LBB0_329
## %bb.188:
	cmpq	$0, -131240(%rbp)               ## 8-byte Folded Reload
	je	LBB0_190
## %bb.189:
	leaq	_DEFAULT_CFG_NAME(%rip), %rdx
	leaq	-131328(%rbp), %rdi
	leaq	-131360(%rbp), %rsi
	callq	_root_file_equal
	testl	%eax, %eax
	jne	LBB0_336
LBB0_190:
	movl	%ebx, -131208(%rbp)             ## 4-byte Spill
	movq	-131120(%rbp), %r12
	testq	%r12, %r12
	je	LBB0_211
## %bb.191:
	xorl	%r13d, %r13d
	leaq	-131328(%rbp), %r15
	movq	%r12, -131216(%rbp)             ## 8-byte Spill
	.p2align	4
LBB0_192:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_195 Depth 2
	movslq	-131144(%rbp,%r13,4), %rax
	cmpq	$6, %rax
	jae	LBB0_290
## %bb.193:                             ##   in Loop: Header=BB0_192 Depth=1
	movq	-131112(%rbp,%rax,8), %rbx
	movabsq	$2330121683245944644, %rcx      ## imm = 0x205641534D4F4F44
	movq	%rcx, -112(%rbp)
	movl	$1196639264, -105(%rbp)         ## imm = 0x47534420
	orb	$48, %al
	movb	%al, -105(%rbp)
	xorl	%eax, %eax
	jmp	LBB0_195
	.p2align	4
LBB0_194:                               ##   in Loop: Header=BB0_195 Depth=2
	addq	$32, %rax
	cmpq	$16384, %rax                    ## imm = 0x4000
	je	LBB0_276
LBB0_195:                               ##   Parent Loop BB0_192 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	1311232(%r14,%rax), %ecx
	cmpl	$229, %ecx
	je	LBB0_194
## %bb.196:                             ##   in Loop: Header=BB0_195 Depth=2
	testl	%ecx, %ecx
	je	LBB0_276
## %bb.197:                             ##   in Loop: Header=BB0_195 Depth=2
	movq	1311232(%r14,%rax), %rcx
	xorq	-112(%rbp), %rcx
	movq	1311235(%r14,%rax), %rdx
	xorq	-109(%rbp), %rdx
	orq	%rcx, %rdx
	jne	LBB0_194
## %bb.198:                             ##   in Loop: Header=BB0_192 Depth=1
	movzbl	1311243(%r14,%rax), %ecx
	movzwl	1311258(%r14,%rax), %edx
	movl	1311260(%r14,%rax), %eax
	movq	%rax, %rsi
	shlq	$32, %rsi
	orq	%rdx, %rsi
	movq	%rcx, %rdx
	shlq	$32, %rdx
	incq	%rdx
	movq	%rdx, -96(%rbp)
	movq	%rsi, -88(%rbp)
	testb	$16, %cl
	jne	LBB0_291
## %bb.199:                             ##   in Loop: Header=BB0_192 Depth=1
	cmpl	$63, %eax
	jbe	LBB0_292
## %bb.200:                             ##   in Loop: Header=BB0_192 Depth=1
	cmpq	$0, -131240(%rbp)               ## 8-byte Folded Reload
	je	LBB0_202
## %bb.201:                             ##   in Loop: Header=BB0_192 Depth=1
	movq	%r15, %rdi
	leaq	-131360(%rbp), %rsi
	leaq	-112(%rbp), %rdx
	callq	_root_file_equal
	testl	%eax, %eax
	jne	LBB0_296
LBB0_202:                               ##   in Loop: Header=BB0_192 Depth=1
	cmpq	$0, -131224(%rbp)               ## 8-byte Folded Reload
	je	LBB0_204
## %bb.203:                             ##   in Loop: Header=BB0_192 Depth=1
	movq	%r15, %rdi
	leaq	-131376(%rbp), %rsi
	leaq	-112(%rbp), %rdx
	callq	_root_file_equal
	testl	%eax, %eax
	je	LBB0_295
LBB0_204:                               ##   in Loop: Header=BB0_192 Depth=1
	movq	%r15, %rdi
	leaq	-96(%rbp), %rsi
	leaq	L_.str.82(%rip), %rdx
	callq	_read_root_file_blob
	movq	%rax, %r15
	movq	%rdx, %r12
	testq	%rbx, %rbx
	je	LBB0_208
## %bb.205:                             ##   in Loop: Header=BB0_192 Depth=1
	movq	%rbx, %rdi
	callq	_strlen
	cmpq	$25, %rax
	jae	LBB0_297
## %bb.206:                             ##   in Loop: Header=BB0_192 Depth=1
	cmpq	$24, %r12
	jb	LBB0_289
## %bb.207:                             ##   in Loop: Header=BB0_192 Depth=1
	movq	%r15, %rdi
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	_memcmp
	testl	%eax, %eax
	jne	LBB0_289
LBB0_208:                               ##   in Loop: Header=BB0_192 Depth=1
	cmpq	$40, %r12
	jb	LBB0_282
## %bb.209:                             ##   in Loop: Header=BB0_192 Depth=1
	movabsq	$2336927755350992246, %rax      ## imm = 0x206E6F6973726576
	cmpq	%rax, 24(%r15)
	jne	LBB0_282
## %bb.210:                             ##   in Loop: Header=BB0_192 Depth=1
	movq	%r15, %rdi
	callq	_free
	incq	%r13
	movq	-131216(%rbp), %r12             ## 8-byte Reload
	cmpq	%r12, %r13
	leaq	-131328(%rbp), %r15
	jne	LBB0_192
LBB0_211:
	movq	-131184(%rbp), %r15
	movq	%r15, %rdi
	xorl	%esi, %esi
	callq	_check_write_status
	movq	-131176(%rbp), %rdi
	movq	%rdi, -131232(%rbp)             ## 8-byte Spill
	movl	$1, %esi
	callq	_check_write_status
	movq	-131168(%rbp), %rdi
	testq	%rdi, %rdi
	je	LBB0_248
## %bb.212:
	movq	%rdi, -131248(%rbp)             ## 8-byte Spill
	callq	_read_file
	movq	-131248(%rbp), %rdi             ## 8-byte Reload
	movq	%rax, -96(%rbp)
	movq	%rdx, -88(%rbp)
	testq	%rax, %rax
	je	LBB0_248
## %bb.213:
	movq	%rdx, %rbx
	cmpq	$11, %rdx
	jb	LBB0_217
## %bb.214:
	movq	%rax, %r13
	movabsq	$8746391181324018023, %rax      ## imm = 0x79616C70656D6167
	movl	$11, %ecx
	movabsq	$5426623667539570789, %rdx      ## imm = 0x4B4F3D79616C7065
	.p2align	4
LBB0_215:                               ## =>This Inner Loop Header: Depth=1
	movq	-11(%r13,%rcx), %rsi
	xorq	%rax, %rsi
	movq	-8(%r13,%rcx), %r8
	xorq	%rdx, %r8
	orq	%rsi, %r8
	je	LBB0_218
## %bb.216:                             ##   in Loop: Header=BB0_215 Depth=1
	incq	%rcx
	cmpq	%rbx, %rcx
	jbe	LBB0_215
LBB0_217:
	leaq	L_.str.101(%rip), %rsi
	callq	_die_path
LBB0_218:
	movl	$1702257011, %ecx               ## imm = 0x65766173
	movl	(%r13), %eax
	xorl	%ecx, %eax
	movzwl	4(%r13), %edx
	xorl	$25714, %edx                    ## imm = 0x6472
	orl	%eax, %edx
	jne	LBB0_220
## %bb.219:
	cmpb	$61, 6(%r13)
	movq	%r13, %rax
	je	LBB0_227
LBB0_220:
	leaq	-7(%rbx), %rdx
	xorl	%eax, %eax
	movabsq	$4294976512, %rsi               ## imm = 0x100002400
	jmp	LBB0_222
	.p2align	4
LBB0_221:                               ##   in Loop: Header=BB0_222 Depth=1
	incq	%rax
	cmpq	%rax, %rdx
	je	LBB0_283
LBB0_222:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r13,%rax), %edi
	cmpq	$32, %rdi
	ja	LBB0_221
## %bb.223:                             ##   in Loop: Header=BB0_222 Depth=1
	btq	%rdi, %rsi
	jae	LBB0_221
## %bb.224:                             ##   in Loop: Header=BB0_222 Depth=1
	movl	1(%r13,%rax), %edi
	xorl	%ecx, %edi
	movzwl	5(%r13,%rax), %r8d
	xorl	$25714, %r8d                    ## imm = 0x6472
	orl	%edi, %r8d
	jne	LBB0_221
## %bb.225:                             ##   in Loop: Header=BB0_222 Depth=1
	cmpb	$61, 7(%r13,%rax)
	jne	LBB0_221
## %bb.226:
	addq	%r13, %rax
	incq	%rax
LBB0_227:
	movzbl	7(%rax), %edi
	testb	%dil, %dil
	je	LBB0_331
## %bb.228:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB0_229:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB0_231
## %bb.230:                             ##   in Loop: Header=BB0_229 Depth=1
	addl	$-48, %esi
	jmp	LBB0_235
	.p2align	4
LBB0_231:                               ##   in Loop: Header=BB0_229 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB0_233
## %bb.232:                             ##   in Loop: Header=BB0_229 Depth=1
	addl	$-87, %esi
	jmp	LBB0_235
	.p2align	4
LBB0_233:                               ##   in Loop: Header=BB0_229 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB0_241
## %bb.234:                             ##   in Loop: Header=BB0_229 Depth=1
	addl	$-55, %esi
LBB0_235:                               ##   in Loop: Header=BB0_229 Depth=1
	testl	%esi, %esi
	js	LBB0_241
## %bb.236:                             ##   in Loop: Header=BB0_229 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	8(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB0_229
	jmp	LBB0_242
LBB0_237:
	cmpq	$6, %r12
	jae	LBB0_338
## %bb.238:
	movq	32(%r14), %r9
LBB0_239:
	subq	$8, %rsp
	leaq	-131200(%rbp), %rdi
	movq	-131224(%rbp), %rsi             ## 8-byte Reload
	pushq	-131232(%rbp)                   ## 8-byte Folded Reload
	pushq	-131288(%rbp)                   ## 8-byte Folded Reload
	movq	-131280(%rbp), %r12             ## 8-byte Reload
	pushq	%r12
	pushq	%rbx
	movq	-131264(%rbp), %r13             ## 8-byte Reload
	pushq	%r13
	pushq	%r15
	movq	-131248(%rbp), %r15             ## 8-byte Reload
	pushq	%r15
	callq	_install_bootable_layout
	addq	$64, %rsp
	movq	(%r14), %rdi
	movq	-131200(%rbp), %rbx
	movq	-131192(%rbp), %rdx
	movq	%rbx, %rsi
	callq	_write_file
	movq	%rbx, %rdi
	callq	_free
	movq	%r15, %rdi
	callq	_free
	movq	%r13, %rdi
	callq	_free
	movq	-131216(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	%r12, %rdi
	callq	_free
LBB0_240:
	movq	%r14, %rdi
	jmp	LBB0_266
LBB0_241:
	testl	%edx, %edx
	je	LBB0_331
LBB0_242:
	testl	%ecx, %ecx
	je	LBB0_327
## %bb.243:
	leaq	L_.str.102(%rip), %rsi
	leaq	-96(%rbp), %rdi
	movl	$1, %edx
	callq	_status_hex_tuple_part
	testl	%eax, %eax
	je	LBB0_327
## %bb.244:
	movl	$6, %eax
	movl	$1768841584, %ecx               ## imm = 0x696E6170
	.p2align	4
LBB0_245:                               ## =>This Inner Loop Header: Depth=1
	movl	-6(%r13,%rax), %edx
	xorl	%ecx, %edx
	movzwl	-2(%r13,%rax), %esi
	xorl	$15715, %esi                    ## imm = 0x3D63
	orl	%edx, %esi
	je	LBB0_272
## %bb.246:                             ##   in Loop: Header=BB0_245 Depth=1
	incq	%rax
	cmpq	%rbx, %rax
	jbe	LBB0_245
LBB0_247:
	movq	%r13, %rdi
	callq	_free
LBB0_248:
	movq	%r15, %r13
	movq	-131160(%rbp), %rbx
	testq	%rbx, %rbx
	movl	-131208(%rbp), %r15d            ## 4-byte Reload
	je	LBB0_259
## %bb.249:
	movq	%rbx, %rdi
	callq	_read_file
	testq	%rax, %rax
	je	LBB0_259
## %bb.250:
	cmpq	$11, %rdx
	jb	LBB0_254
## %bb.251:
	movabsq	$8746391181324018023, %rcx      ## imm = 0x79616C70656D6167
	movl	$11, %esi
	movabsq	$5426623667539570789, %rdi      ## imm = 0x4B4F3D79616C7065
	.p2align	4
LBB0_252:                               ## =>This Inner Loop Header: Depth=1
	movq	-11(%rax,%rsi), %r8
	xorq	%rcx, %r8
	movq	-8(%rax,%rsi), %r9
	xorq	%rdi, %r9
	orq	%r8, %r9
	je	LBB0_255
## %bb.253:                             ##   in Loop: Header=BB0_252 Depth=1
	incq	%rsi
	cmpq	%rdx, %rsi
	jbe	LBB0_252
LBB0_254:
	leaq	L_.str.107(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_255:
	movl	$6, %ecx
	movl	$1768841584, %esi               ## imm = 0x696E6170
	.p2align	4
LBB0_256:                               ## =>This Inner Loop Header: Depth=1
	movl	-6(%rax,%rcx), %edi
	xorl	%esi, %edi
	movzwl	-2(%rax,%rcx), %r8d
	xorl	$15715, %r8d                    ## imm = 0x3D63
	orl	%edi, %r8d
	je	LBB0_268
## %bb.257:                             ##   in Loop: Header=BB0_256 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	LBB0_256
LBB0_258:
	movq	%rax, %rdi
	callq	_free
LBB0_259:
	cmpl	$0, -131148(%rbp)
	je	LBB0_261
## %bb.260:
	movq	%r13, %rdi
	callq	_check_dynamic_fat_status
	movl	%eax, %ebx
	movq	-131232(%rbp), %rdi             ## 8-byte Reload
	callq	_check_dynamic_fat_status
	orl	%ebx, %eax
	je	LBB0_330
LBB0_261:
	leaq	L_str(%rip), %rdi
	callq	_puts
	leaq	L_.str.55(%rip), %rdi
	movq	-131256(%rbp), %rsi             ## 8-byte Reload
	xorl	%eax, %eax
	callq	_printf
	testl	%r15d, %r15d
	leaq	L_.str.58(%rip), %rax
	leaq	L_.str.57(%rip), %rsi
	cmoveq	%rax, %rsi
	leaq	L_.str.56(%rip), %rdi
	xorl	%eax, %eax
	callq	_printf
	testq	%r12, %r12
	je	LBB0_264
## %bb.262:
	leaq	L_.str.59(%rip), %rbx
	xorl	%r15d, %r15d
	.p2align	4
LBB0_263:                               ## =>This Inner Loop Header: Depth=1
	movl	-131144(%rbp,%r15,4), %esi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_printf
	incq	%r15
	cmpq	%r15, %r12
	jne	LBB0_263
LBB0_264:
	leaq	L_str.514(%rip), %rdi
	callq	_puts
	movq	%r14, %rdi
	callq	_free
	movq	-131240(%rbp), %rdi             ## 8-byte Reload
	callq	_free
	movq	-131224(%rbp), %rdi             ## 8-byte Reload
LBB0_265:
	callq	_free
	movq	-131296(%rbp), %rdi             ## 8-byte Reload
LBB0_266:
	callq	_free
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB0_300
## %bb.267:
	xorl	%eax, %eax
	addq	$131352, %rsp                   ## imm = 0x20118
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB0_268:
	movl	$10, %ecx
	movabsq	$5714572474359636336, %rsi      ## imm = 0x4F4E3D63696E6170
	.p2align	4
LBB0_269:                               ## =>This Inner Loop Header: Depth=1
	movq	-10(%rax,%rcx), %rdi
	xorq	%rsi, %rdi
	movzwl	-2(%rax,%rcx), %r8d
	xorq	$17742, %r8                     ## imm = 0x454E
	orq	%rdi, %r8
	je	LBB0_258
## %bb.270:                             ##   in Loop: Header=BB0_269 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	LBB0_269
## %bb.271:
	leaq	L_.str.108(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_272:
	movl	$10, %eax
	movabsq	$5714572474359636336, %rcx      ## imm = 0x4F4E3D63696E6170
	.p2align	4
LBB0_273:                               ## =>This Inner Loop Header: Depth=1
	movq	-10(%r13,%rax), %rdx
	xorq	%rcx, %rdx
	movzwl	-2(%r13,%rax), %esi
	xorq	$17742, %rsi                    ## imm = 0x454E
	orq	%rdx, %rsi
	je	LBB0_247
## %bb.274:                             ##   in Loop: Header=BB0_273 Depth=1
	incq	%rax
	cmpq	%rbx, %rax
	jbe	LBB0_273
## %bb.275:
	leaq	L_.str.106(%rip), %rsi
	movq	-131248(%rbp), %rdi             ## 8-byte Reload
	callq	_die_path
LBB0_276:
	callq	_main.cold.37
LBB0_277:
	callq	_main.cold.26
LBB0_278:
	callq	_main.cold.27
LBB0_279:
	callq	_main.cold.28
LBB0_280:
	callq	_main.cold.33
LBB0_281:
	callq	_main.cold.24
LBB0_282:
	callq	_main.cold.43
LBB0_283:
	callq	_main.cold.46
LBB0_284:
	callq	_main.cold.16
LBB0_285:
	leaq	L_.str.147(%rip), %rsi
	movq	%r13, %rdi
	callq	_die_path
LBB0_286:
	leaq	L_.str.149(%rip), %rsi
	movq	%r13, %rdi
	callq	_die_path
LBB0_287:
	leaq	L_.str.150(%rip), %rsi
	movq	%r13, %rdi
	callq	_die_path
LBB0_288:
	leaq	L_.str.148(%rip), %rsi
	movq	%r13, %rdi
	callq	_die_path
LBB0_289:
	callq	_main.cold.41
LBB0_290:
	callq	_main.cold.45
LBB0_291:
	callq	_main.cold.38
LBB0_292:
	callq	_main.cold.44
LBB0_293:
	callq	_main.cold.8
LBB0_294:
	movq	-131232(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131160(%rbp)
	movq	-131208(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131168(%rbp)
	movq	-131216(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131176(%rbp)
	movq	-131224(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131184(%rbp)
	leaq	L_.str.49(%rip), %rdi
	callq	_die
LBB0_295:
	callq	_main.cold.40
LBB0_296:
	callq	_main.cold.39
LBB0_297:
	callq	_main.cold.42
LBB0_298:
	callq	_main.cold.23
LBB0_299:
	callq	_main.cold.49
LBB0_300:
	callq	___stack_chk_fail
LBB0_301:
	callq	_main.cold.17
LBB0_302:
	callq	_main.cold.19
LBB0_303:
	callq	_main.cold.9
LBB0_304:
	callq	_main.cold.21
LBB0_305:
	callq	_main.cold.22
LBB0_306:
	callq	_main.cold.11
LBB0_307:
	callq	_main.cold.13
LBB0_308:
	callq	_main.cold.14
LBB0_309:
	callq	_main.cold.15
LBB0_310:
	callq	_main.cold.18
LBB0_311:
	callq	_main.cold.20
LBB0_312:
	callq	_main.cold.25
LBB0_313:
	leaq	L_.str.61(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_314:
	leaq	L_.str.62(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_315:
	leaq	L_.str.63(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_316:
	leaq	L_.str.64(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_317:
	leaq	L_.str.65(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_318:
	leaq	L_.str.66(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB0_319:
	callq	_main.cold.32
LBB0_320:
	callq	_main.cold.30
LBB0_321:
	callq	_main.cold.4
LBB0_322:
	callq	_main.cold.1
LBB0_323:
	callq	_main.cold.6
LBB0_324:
	callq	_main.cold.7
LBB0_325:
	callq	_main.cold.10
LBB0_326:
	callq	_main.cold.12
LBB0_327:
	leaq	L_.str.103(%rip), %rsi
	movq	-131248(%rbp), %rdi             ## 8-byte Reload
	callq	_die_path
LBB0_328:
	callq	_main.cold.34
LBB0_329:
	callq	_main.cold.36
LBB0_330:
	callq	_main.cold.48
LBB0_331:
	callq	_main.cold.47
LBB0_332:
	callq	_main.cold.2
LBB0_333:
	callq	_main.cold.3
LBB0_334:
	callq	_main.cold.5
LBB0_335:
	movq	-131232(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131160(%rbp)
	movq	-131208(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131168(%rbp)
	movq	-131216(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131176(%rbp)
	movq	-131224(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131184(%rbp)
	leaq	L_.str.52(%rip), %rdi
	callq	_die
LBB0_336:
	callq	_main.cold.35
LBB0_337:
	callq	_main.cold.31
LBB0_338:
	callq	_main.cold.29
LBB0_339:
	movq	-131232(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131160(%rbp)
	movq	-131208(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131168(%rbp)
	movq	-131216(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131176(%rbp)
	movq	-131224(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131184(%rbp)
	leaq	L_.str.50(%rip), %rdi
	callq	_die
LBB0_340:
	movq	-131232(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131160(%rbp)
	movq	-131208(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131168(%rbp)
	movq	-131216(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131176(%rbp)
	movq	-131224(%rbp), %rax             ## 8-byte Reload
	movq	%rax, -131184(%rbp)
	leaq	L_.str.51(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker
_mutate_root_marker:                    ## @mutate_root_marker
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
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
	movl	%ecx, %r12d
	movq	%rdx, %r15
	movq	%rsi, %r13
	movq	%rdi, %rbx
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	callq	_read_file
	cmpq	$536870912, %rdx                ## imm = 0x20000000
	jne	LBB1_27
## %bb.1:
	movq	%rax, %r14
	movq	%rax, -131184(%rbp)
	movq	$536870912, -131176(%rbp)       ## imm = 0x20000000
	leaq	-131168(%rbp), %rdi
	leaq	1049088(%rax), %rsi
	movl	$131072, %edx                   ## imm = 0x20000
	callq	_memcpy
	leaq	L_.str.37(%rip), %rsi
	movq	%r13, %rdi
	callq	_strcmp
	testl	%eax, %eax
	movl	%r12d, -68(%rbp)                ## 4-byte Spill
	je	LBB1_2
## %bb.3:
	leaq	L_.str.38(%rip), %rsi
	movq	%r13, %rdi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB1_4
## %bb.5:
	leaq	L_.str.39(%rip), %rsi
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
	addq	$1311232, %r15                  ## imm = 0x140200
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
	leal	-65375(%rdi), %eax
	cmpl	$-65374, %eax                   ## imm = 0xFFFF00A2
	jbe	LBB1_30
## %bb.17:                              ##   in Loop: Header=BB1_14 Depth=1
	shll	$13, %edi
	addq	%r15, %rdi
	movl	$8192, %esi                     ## imm = 0x2000
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
	leaq	L_.str.30(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB1_31:
	callq	___stack_chk_fail
LBB1_28:
	callq	_mutate_root_marker.cold.1
LBB1_29:
	callq	_mutate_root_marker.cold.3
                                        ## -- End function
	.p2align	4                               ## -- Begin function die
_die:                                   ## @die
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.128(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0                          ## -- Begin function install_bootable_layout
LCPI3_0:
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
	.byte	15                              ## 0xf
	.byte	0                               ## 0x0
LCPI3_1:
	.byte	0                               ## 0x0
	.byte	2                               ## 0x2
	.byte	16                              ## 0x10
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
LCPI3_2:
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
LCPI3_3:
	.space	16,16
LCPI3_4:
	.space	16,63
LCPI3_5:
	.space	16,48
LCPI3_6:
	.space	16,32
LCPI3_7:
	.space	16,96
LCPI3_8:
	.space	16,64
LCPI3_9:
	.space	16,80
LCPI3_10:
	.space	16,112
LCPI3_11:
	.space	16,128
LCPI3_12:
	.byte	192                             ## 0xc0
	.byte	255                             ## 0xff
	.byte	192                             ## 0xc0
	.byte	255                             ## 0xff
	.byte	64                              ## 0x40
	.byte	0                               ## 0x0
	.byte	192                             ## 0xc0
	.byte	255                             ## 0xff
	.byte	64                              ## 0x40
	.byte	0                               ## 0x0
	.byte	64                              ## 0x40
	.byte	0                               ## 0x0
	.byte	192                             ## 0xc0
	.byte	255                             ## 0xff
	.byte	64                              ## 0x40
	.byte	0                               ## 0x0
LCPI3_13:
	.byte	128                             ## 0x80
	.byte	255                             ## 0xff
	.byte	128                             ## 0x80
	.byte	255                             ## 0xff
	.byte	2                               ## 0x2
	.byte	0                               ## 0x0
	.byte	2                               ## 0x2
	.byte	0                               ## 0x0
	.byte	8                               ## 0x8
	.byte	0                               ## 0x0
	.byte	8                               ## 0x8
	.byte	0                               ## 0x0
	.byte	8                               ## 0x8
	.byte	0                               ## 0x0
	.byte	8                               ## 0x8
	.byte	0                               ## 0x0
LCPI3_14:
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
LCPI3_15:
	.long	1                               ## 0x1
	.long	1                               ## 0x1
	.long	1                               ## 0x1
	.long	1                               ## 0x1
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	4
_install_bootable_layout:               ## @install_bootable_layout
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movl	$15752, %eax                    ## imm = 0x3D88
	callq	____chkstk_darwin
	subq	%rax, %rsp
	popq	%rax
	movq	%rcx, %r14
	movq	%rsi, %r15
	movq	%rdi, %r12
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	testq	%rdx, %rdx
	setne	%al
	testq	%rcx, %rcx
	setne	%cl
	xorl	%esi, %esi
	movq	%rdx, %rdi
	orq	%r14, %rdi
	sete	%sil
	andb	%al, %cl
	movq	%r8, -15672(%rbp)               ## 8-byte Spill
	testq	%r8, %r8
	movzbl	%cl, %eax
	cmovel	%esi, %eax
	testb	%al, %al
	je	LBB3_344
## %bb.1:
	movq	%r9, %r13
	movl	64(%rbp), %eax
	xorps	%xmm0, %xmm0
	movups	%xmm0, -15704(%rbp)
	movups	%xmm0, -15720(%rbp)
	movups	%xmm0, -15736(%rbp)
	movups	%xmm0, -15752(%rbp)
	movq	$0, -15688(%rbp)
	movl	%eax, -15760(%rbp)
	xorl	%eax, %eax
	testq	%r15, %r15
	setne	%al
	movl	%eax, -15756(%rbp)
	movq	(%r12), %rbx
	testq	%rdx, %rdx
	movq	%r12, -15656(%rbp)              ## 8-byte Spill
	movq	%r15, -15784(%rbp)              ## 8-byte Spill
	je	LBB3_6
## %bb.2:
	movq	%rdx, %r15
	movq	%rdx, %rdi
	callq	_read_file
	cmpq	$512, %rdx                      ## imm = 0x200
	jne	LBB3_356
## %bb.3:
	movq	%rax, %r12
	movl	$512, %r15d                     ## imm = 0x200
	movl	$512, %edx                      ## imm = 0x200
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_memcpy
	movq	%r12, %rdi
	callq	_free
	movq	%r14, %rdi
	callq	_read_file
	cmpq	$8193, %rdx                     ## imm = 0x2001
	jae	LBB3_357
## %bb.4:
	movq	%rax, %r14
	movq	-15656(%rbp), %r12              ## 8-byte Reload
	addq	(%r12), %r15
	movq	%r15, %rdi
	movq	%rax, %rsi
	callq	_memcpy
	movq	%r14, %rdi
	callq	_free
	movq	-15672(%rbp), %rdi              ## 8-byte Reload
	callq	_read_file
	cmpq	$229377, %rdx                   ## imm = 0x38001
	jae	LBB3_358
## %bb.5:
	movq	%rax, %r14
	movl	$8704, %edi                     ## imm = 0x2200
	addq	(%r12), %rdi
	movq	%rax, %rsi
	callq	_memcpy
	movq	%r14, %rdi
	callq	_free
	movq	-15784(%rbp), %r15              ## 8-byte Reload
	jmp	LBB3_7
LBB3_6:
	movw	$15595, (%rbx)                  ## imm = 0x3CEB
	movb	$-112, 2(%rbx)
LBB3_7:
	testq	%r15, %r15
	sete	%al
	movl	$1146310486, 440(%rbx)          ## imm = 0x44534F56
	movaps	LCPI3_0(%rip), %xmm0            ## xmm0 = [128,1,1,0,6,254,255,255,0,8,0,0,0,248,1,0]
	movups	%xmm0, 446(%rbx)
	movw	$-21931, 510(%rbx)              ## imm = 0xAA55
	movq	(%r12), %rcx
	movw	$15595, 1048576(%rcx)           ## imm = 0x3CEB
	movb	$-112, 1048578(%rcx)
	movabsq	$2314941808397928790, %rdx      ## imm = 0x2020534F45424956
	movq	%rdx, 1048579(%rcx)
	movaps	LCPI3_1(%rip), %xmm0            ## xmm0 = [0,2,2,1,0,2,0,2,0,0,248,0,1,63,0,16]
	movups	%xmm0, 1048587(%rcx)
	movabsq	$0x0FF8000000080000, %rdx
	movq	%rdx, 1048603(%rcx)
	movw	$-32768, 1048611(%rcx)          ## imm = 0x8000
	movl	$218104105, 1048614(%rcx)       ## imm = 0xD000129
	movb	$-48, 1048618(%rcx)
	movabsq	$6278109480483965270, %rdx      ## imm = 0x5720534F45424956
	movq	%rdx, 1048619(%rcx)
	movl	$541344087, 1048626(%rcx)       ## imm = 0x20444157
	movabsq	$2314885625596363078, %rdx      ## imm = 0x2020203631544146
	movq	%rdx, 1048630(%rcx)
	movw	$-21931, 1049086(%rcx)          ## imm = 0xAA55
	cmpl	$0, 64(%rbp)
	sete	%cl
	orb	%al, %cl
	movq	%r13, -15768(%rbp)              ## 8-byte Spill
	jne	LBB3_9
## %bb.8:
	leaq	L_.str.309(%rip), %rsi
	movq	%r15, %rdi
	callq	_reject_repo_local_external_asset
	jmp	LBB3_10
LBB3_9:
	testq	%r15, %r15
	je	LBB3_22
LBB3_10:
	movq	%r15, %rdi
	callq	_read_file
	movq	%rax, -15624(%rbp)              ## 8-byte Spill
	cmpq	$5242881, %rdx                  ## imm = 0x500001
	jae	LBB3_352
## %bb.11:
	movq	%rdx, %rbx
	cmpq	$11, %rdx
	jbe	LBB3_353
## %bb.12:
	movq	-15624(%rbp), %rsi              ## 8-byte Reload
	cmpl	$1145132873, (%rsi)             ## imm = 0x44415749
	je	LBB3_14
## %bb.13:
	cmpl	$1145132880, (%rsi)             ## imm = 0x44415750
	jne	LBB3_360
LBB3_14:
	movl	4(%rsi), %eax
	testq	%rax, %rax
	je	LBB3_354
## %bb.15:
	movl	8(%rsi), %ecx
	shlq	$4, %rax
	leaq	(%rax,%rcx), %rdx
	cmpq	%rbx, %rdx
	ja	LBB3_355
## %bb.16:
	addq	%rsi, %rcx
	addq	$4, %rcx
	xorl	%edx, %edx
	jmp	LBB3_19
	.p2align	4
LBB3_17:                                ##   in Loop: Header=BB3_19 Depth=1
	cmpq	%rsi, %rbx
	jb	LBB3_336
LBB3_18:                                ##   in Loop: Header=BB3_19 Depth=1
	addq	$16, %rdx
	cmpq	%rdx, %rax
	je	LBB3_67
LBB3_19:                                ## =>This Inner Loop Header: Depth=1
	movl	-4(%rcx,%rdx), %esi
	movl	(%rcx,%rdx), %edi
	testq	%rdi, %rdi
	je	LBB3_17
## %bb.20:                              ##   in Loop: Header=BB3_19 Depth=1
	addq	%rsi, %rdi
	cmpq	%rbx, %rdi
	jbe	LBB3_18
## %bb.21:
	leaq	L_.str.326(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_22:
	movl	$1048576, %edi                  ## imm = 0x100000
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB3_361
## %bb.23:
	movq	%rax, %rbx
	movq	$0, -15600(%rbp)
	movq	$0, -15616(%rbp)
	movq	$0, -15608(%rbp)
	movl	$12, -15588(%rbp)
	movl	$18, %edi
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB3_362
## %bb.24:
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
	je	LBB3_363
## %bb.25:
	movq	%r14, -15664(%rbp)              ## 8-byte Spill
	movq	%rbx, -15624(%rbp)              ## 8-byte Spill
	movb	$1, (%rax)
	movabsq	$5207093865752713555, %rcx      ## imm = 0x48435048544E5953
	movq	%rax, -15776(%rbp)              ## 8-byte Spill
	movq	%rcx, 4(%rax)
	movl	$1516, %edi                     ## imm = 0x5EC
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB3_364
## %bb.26:
	movb	$42, (%rax)
	movq	%rax, -15632(%rbp)              ## 8-byte Spill
	addq	$172, %rax
	movq	%rax, -15640(%rbp)              ## 8-byte Spill
	leaq	_switch_textures(%rip), %r14
	movl	$7, %edx
	xorl	%r15d, %r15d
	movq	-15640(%rbp), %r13              ## 8-byte Reload
	.p2align	4
LBB3_27:                                ## =>This Inner Loop Header: Depth=1
	leaq	172(%r15), %rax
	movq	-15632(%rbp), %rcx              ## 8-byte Reload
	movb	%al, -3(%rcx,%rdx)
	movb	%ah, -2(%rcx,%rdx)
	movq	%rdx, %r12
	movw	$0, -1(%rcx,%rdx)
	movq	(%r14), %rbx
	movq	$0, 172(%rcx,%r15)
	movq	%rbx, %rdi
	callq	_strlen
	cmpq	$9, %rax
	jae	LBB3_337
## %bb.28:                              ##   in Loop: Header=BB3_27 Depth=1
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
	jne	LBB3_27
## %bb.29:
	movl	$10752, %edi                    ## imm = 0x2A00
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB3_365
## %bb.30:
	movq	%rax, %r14
	movl	$8704, %edi                     ## imm = 0x2200
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	movq	-15624(%rbp), %rbx              ## 8-byte Reload
	je	LBB3_366
## %bb.31:
	movq	%rax, %r15
	leaq	-15232(%rbp), %rdi
	movl	$4096, %esi                     ## imm = 0x1000
	callq	___bzero
	movw	$0, -15256(%rbp)
	movq	$0, -15264(%rbp)
	xorps	%xmm0, %xmm0
	movaps	%xmm0, -15296(%rbp)
	movaps	%xmm0, -15312(%rbp)
	movaps	%xmm0, -15328(%rbp)
	movq	$0, -15280(%rbp)
	movaps	%xmm0, -15360(%rbp)
	movaps	%xmm0, -15376(%rbp)
	movaps	%xmm0, -15392(%rbp)
	movaps	%xmm0, -15408(%rbp)
	movaps	%xmm0, -15424(%rbp)
	movaps	%xmm0, -15440(%rbp)
	movaps	%xmm0, -15456(%rbp)
	movq	$0, -15344(%rbp)
	movaps	%xmm0, -15472(%rbp)
	movaps	%xmm0, -15488(%rbp)
	movaps	%xmm0, -15504(%rbp)
	movaps	%xmm0, -15520(%rbp)
	movl	$0, -15676(%rbp)
	movups	%xmm0, -15542(%rbp)
	movaps	%xmm0, -15552(%rbp)
	movb	$0, -15641(%rbp)
	movups	%xmm0, -15574(%rbp)
	movaps	%xmm0, -15584(%rbp)
	movdqa	LCPI3_2(%rip), %xmm4            ## xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$80, %eax
	movdqa	LCPI3_3(%rip), %xmm0            ## xmm0 = [16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16]
	movdqa	LCPI3_4(%rip), %xmm5            ## xmm5 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
	movdqa	LCPI3_5(%rip), %xmm1            ## xmm1 = [48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48]
	movdqa	LCPI3_6(%rip), %xmm2            ## xmm2 = [32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32]
	movdqa	LCPI3_7(%rip), %xmm3            ## xmm3 = [96,96,96,96,96,96,96,96,96,96,96,96,96,96,96,96]
	.p2align	4
LBB3_32:                                ## =>This Inner Loop Header: Depth=1
	movdqa	%xmm4, %xmm6
	paddb	%xmm0, %xmm6
	movdqa	%xmm4, %xmm7
	pand	%xmm5, %xmm7
	pand	%xmm5, %xmm6
	movdqu	%xmm7, -80(%r14,%rax)
	movdqu	%xmm6, -64(%r14,%rax)
	movdqa	%xmm4, %xmm8
	paddb	%xmm1, %xmm8
	movdqa	%xmm7, %xmm9
	pxor	%xmm2, %xmm9
	pand	%xmm5, %xmm8
	movdqu	%xmm9, -48(%r14,%rax)
	movdqu	%xmm8, -32(%r14,%rax)
	movdqu	%xmm7, -16(%r14,%rax)
	movdqu	%xmm6, (%r14,%rax)
	paddb	%xmm3, %xmm4
	addq	$96, %rax
	cmpq	$10832, %rax                    ## imm = 0x2A50
	jne	LBB3_32
## %bb.33:
	movq	%r14, -15640(%rbp)              ## 8-byte Spill
	movdqa	LCPI3_2(%rip), %xmm4            ## xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$112, %eax
	movdqa	LCPI3_8(%rip), %xmm5            ## xmm5 = [64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64]
	movdqa	LCPI3_9(%rip), %xmm6            ## xmm6 = [80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80]
	movdqa	LCPI3_10(%rip), %xmm7           ## xmm7 = [112,112,112,112,112,112,112,112,112,112,112,112,112,112,112,112]
	movdqa	LCPI3_11(%rip), %xmm8           ## xmm8 = [128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128]
	.p2align	4
LBB3_34:                                ## =>This Inner Loop Header: Depth=1
	movdqa	%xmm4, %xmm9
	paddb	%xmm0, %xmm9
	movdqu	%xmm4, -112(%r15,%rax)
	movdqu	%xmm9, -96(%r15,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm2, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm1, %xmm10
	movdqu	%xmm9, -80(%r15,%rax)
	movdqu	%xmm10, -64(%r15,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm5, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm6, %xmm10
	movdqu	%xmm9, -48(%r15,%rax)
	movdqu	%xmm10, -32(%r15,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm3, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm7, %xmm10
	movdqu	%xmm9, -16(%r15,%rax)
	movdqu	%xmm10, (%r15,%rax)
	pxor	%xmm8, %xmm4
	subq	$-128, %rax
	cmpq	$8816, %rax                     ## imm = 0x2270
	jne	LBB3_34
## %bb.35:
	movl	$458753, -15258(%rbp)           ## imm = 0x70001
	movaps	LCPI3_12(%rip), %xmm0           ## xmm0 = [192,255,192,255,64,0,192,255,64,0,64,0,192,255,64,0]
	movaps	%xmm0, -15472(%rbp)
	movl	$1, -15328(%rbp)
	movb	$1, -15324(%rbp)
	movabsq	$844420635164672, %rax          ## imm = 0x2FFFF00000000
	movq	%rax, -15320(%rbp)
	movl	$0, -15323(%rbp)
	movw	$1, -15312(%rbp)
	movb	$1, -15310(%rbp)
	movl	$0, -15309(%rbp)
	movb	$0, -15305(%rbp)
	movabsq	$562967133224961, %rax          ## imm = 0x20003FFFF0001
	movq	%rax, -15304(%rbp)
	movb	$1, -15296(%rbp)
	movl	$0, -15295(%rbp)
	movb	$0, -15291(%rbp)
	movabsq	$985166713389058, %rax          ## imm = 0x38000FFFF0002
	movq	%rax, -15290(%rbp)
	movb	$1, -15282(%rbp)
	movl	$0, -15281(%rbp)
	movb	$0, -15277(%rbp)
	movl	$-65533, -15276(%rbp)           ## imm = 0xFFFF0003
	movl	$0, -15456(%rbp)
	movq	$45, -15452(%rbp)
	movq	$45, -15444(%rbp)
	movabsq	$5570745284657502035, %rax      ## imm = 0x4D4F435242315753
	movq	%rax, -15436(%rbp)
	movq	$0, -15428(%rbp)
	movq	$0, -15422(%rbp)
	movb	$45, -15422(%rbp)
	movq	$45, -15414(%rbp)
	movq	%rax, -15406(%rbp)
	movq	$0, -15398(%rbp)
	movq	$0, -15392(%rbp)
	movb	$45, -15392(%rbp)
	movq	$45, -15384(%rbp)
	movq	%rax, -15376(%rbp)
	movq	$0, -15362(%rbp)
	movq	$0, -15368(%rbp)
	movb	$45, -15362(%rbp)
	movq	$45, -15354(%rbp)
	movq	%rax, -15346(%rbp)
	movw	$0, -15338(%rbp)
	movl	$1, -15520(%rbp)
	movw	$32767, -15516(%rbp)            ## imm = 0x7FFF
	movw	$0, -15510(%rbp)
	movl	$0, -15514(%rbp)
	movl	$65538, -15508(%rbp)            ## imm = 0x10002
	movw	$-16384, -15504(%rbp)           ## imm = 0xC000
	movb	$1, -15502(%rbp)
	movb	$0, -15497(%rbp)
	movl	$0, -15501(%rbp)
	movl	$131075, -15496(%rbp)           ## imm = 0x20003
	movw	$0, -15492(%rbp)
	movb	$2, -15490(%rbp)
	movl	$0, -15486(%rbp)
	movl	$0, -15489(%rbp)
	movl	$1073741827, -15482(%rbp)       ## imm = 0x40000003
	movb	$3, -15478(%rbp)
	movb	$0, -15473(%rbp)
	movl	$0, -15477(%rbp)
	movl	$4, -15676(%rbp)
	movl	$8388608, -15552(%rbp)          ## imm = 0x800000
	movq	$0, -15548(%rbp)
	movw	$12633, -15544(%rbp)            ## imm = 0x3159
	movl	$1263755078, -15548(%rbp)       ## imm = 0x4B535F46
	movq	$0, -15540(%rbp)
	movw	$12633, -15536(%rbp)            ## imm = 0x3159
	movl	$1263755078, -15540(%rbp)       ## imm = 0x4B535F46
	movw	$160, -15532(%rbp)
	movaps	LCPI3_13(%rip), %xmm0           ## xmm0 = [128,255,128,255,2,0,2,0,8,0,8,0,8,0,8,0]
	movaps	%xmm0, -15584(%rbp)
	movabsq	$844433520132096, %rax          ## imm = 0x3000200010000
	movq	%rax, -15568(%rbp)
	movw	$-1, -15560(%rbp)
	leaq	L_.str.328(%rip), %r9
	leaq	-15600(%rbp), %r13
	leaq	-15616(%rbp), %r12
	leaq	-15608(%rbp), %rdx
	leaq	-15588(%rbp), %r14
	movq	%r13, %rdi
	movq	%r12, %rsi
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$10752                          ## imm = 0x2A00
	pushq	-15640(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.329(%rip), %r9
	movq	%r13, %rdi
	movq	%r12, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$8704                           ## imm = 0x2200
	movq	%r15, -15792(%rbp)              ## 8-byte Spill
	pushq	%r15
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.330(%rip), %r9
	movq	%r13, %rdi
	movq	%r12, %rsi
	movq	%r12, %r15
	leaq	-15608(%rbp), %rdx
	movq	%rdx, %r12
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$12
	pushq	-15776(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.331(%rip), %r9
	movq	%r13, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$1516                           ## imm = 0x5EC
	pushq	-15632(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	movq	-15616(%rbp), %rbx
	movq	-15600(%rbp), %rax
	cmpq	-15608(%rbp), %rbx
	jne	LBB3_38
## %bb.36:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -15608(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_368
## %bb.37:
	movq	%rax, -15600(%rbp)
LBB3_38:
	leaq	1(%rbx), %rcx
	movq	%rcx, -15616(%rbp)
	shlq	$4, %rbx
	xorps	%xmm0, %xmm0
	movups	%xmm0, (%rax,%rbx)
	movl	$1414750022, 8(%rax,%rbx)       ## imm = 0x54535F46
	movl	$1414676820, 11(%rax,%rbx)      ## imm = 0x54524154
	leaq	L_.str.327(%rip), %r9
	leaq	-15600(%rbp), %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	leaq	-15588(%rbp), %r8
	movq	-15624(%rbp), %rcx              ## 8-byte Reload
	pushq	$4096                           ## imm = 0x1000
	leaq	-15232(%rbp), %rax
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	movq	-15616(%rbp), %rbx
	movq	-15608(%rbp), %r15
	movq	-15600(%rbp), %rax
	cmpq	%r15, %rbx
	jne	LBB3_41
## %bb.39:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %r15d
	cmovneq	%rcx, %r15
	movq	%r15, -15608(%rbp)
	movq	%r15, %rsi
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_369
## %bb.40:
	movq	%rax, -15600(%rbp)
LBB3_41:
	xorps	%xmm0, %xmm0
	leaq	1(%rbx), %r14
	movq	%rbx, %rcx
	shlq	$4, %rcx
	movups	%xmm0, (%rax,%rcx)
	movl	$1313169222, 8(%rax,%rcx)       ## imm = 0x4E455F46
	movb	$68, 12(%rax,%rcx)
	cmpq	%r15, %r14
	jne	LBB3_44
## %bb.42:
	leaq	(%r15,%r15), %rcx
	testq	%r15, %r15
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -15608(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_370
## %bb.43:
	movq	%rax, -15600(%rbp)
LBB3_44:
	addq	$2, %rbx
	movq	%rbx, -15616(%rbp)
	shlq	$4, %r14
	xorps	%xmm0, %xmm0
	movups	%xmm0, (%rax,%r14)
	movl	$1414750035, 8(%rax,%r14)       ## imm = 0x54535F53
	movl	$1414676820, 11(%rax,%r14)      ## imm = 0x54524154
	leaq	L_.str.396(%rip), %r9
	leaq	-15600(%rbp), %r12
	leaq	-15616(%rbp), %r13
	leaq	-15608(%rbp), %rdx
	leaq	-15588(%rbp), %r15
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	-15624(%rbp), %rbx              ## 8-byte Reload
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	movq	-15664(%rbp), %r14              ## 8-byte Reload
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.397(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.398(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.399(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.400(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.401(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.402(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.403(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.404(%rip), %r9
	movq	%r12, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	pushq	$18
	pushq	%r14
	callq	_add_lump
	addq	$16, %rsp
	movq	-15616(%rbp), %rbx
	movq	-15600(%rbp), %rax
	cmpq	-15608(%rbp), %rbx
	jne	LBB3_47
## %bb.45:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -15608(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_371
## %bb.46:
	movq	%rax, -15600(%rbp)
LBB3_47:
	leaq	1(%rbx), %rcx
	movq	%rcx, -15616(%rbp)
	shlq	$4, %rbx
	xorps	%xmm0, %xmm0
	movups	%xmm0, (%rax,%rbx)
	movl	$1313169235, 8(%rax,%rbx)       ## imm = 0x4E455F53
	movb	$68, 12(%rax,%rbx)
	leaq	L_.str.336(%rip), %r9
	leaq	-15600(%rbp), %r14
	leaq	-15616(%rbp), %r15
	leaq	-15608(%rbp), %r12
	leaq	-15588(%rbp), %rbx
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	movq	-15624(%rbp), %r13              ## 8-byte Reload
	movq	%r13, %rcx
	movq	%rbx, %r8
	pushq	$18
	pushq	-15664(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	_FIXTURE_MUS_SCORE_END(%rip), %rax
	leaq	L_.str.337(%rip), %r9
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	movq	%r13, %rcx
	movq	%rbx, %r8
	pushq	$17
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.338(%rip), %r9
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	movq	%r13, %rcx
	movq	%rbx, %r8
	pushq	$17
	leaq	_FIXTURE_MUS_SCORE_END(%rip), %rax
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	movq	-15616(%rbp), %rbx
	movq	-15600(%rbp), %rax
	cmpq	-15608(%rbp), %rbx
	jne	LBB3_50
## %bb.48:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -15608(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_372
## %bb.49:
	movq	%rax, -15600(%rbp)
LBB3_50:
	leaq	1(%rbx), %rcx
	movq	%rcx, -15616(%rbp)
	shlq	$4, %rbx
	xorps	%xmm0, %xmm0
	movups	%xmm0, (%rax,%rbx)
	movl	$827142469, 8(%rax,%rbx)        ## imm = 0x314D3145
	leaq	-15264(%rbp), %rax
	leaq	L_.str.340(%rip), %r9
	leaq	-15600(%rbp), %r15
	leaq	-15616(%rbp), %r12
	leaq	-15608(%rbp), %r13
	leaq	-15588(%rbp), %r14
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	-15624(%rbp), %rbx              ## 8-byte Reload
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$10
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	-15328(%rbp), %rax
	leaq	L_.str.341(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$56
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	-15456(%rbp), %rax
	leaq	L_.str.342(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$120
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	-15472(%rbp), %rax
	leaq	L_.str.343(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$16
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	-15520(%rbp), %rax
	leaq	L_.str.344(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$48
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	-15676(%rbp), %rax
	leaq	L_.str.345(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$4
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	movq	-15616(%rbp), %rbx
	movq	-15600(%rbp), %rax
	cmpq	-15608(%rbp), %rbx
	jne	LBB3_53
## %bb.51:
	leaq	(%rbx,%rbx), %rcx
	testq	%rbx, %rbx
	movl	$128, %esi
	cmovneq	%rcx, %rsi
	movq	%rsi, -15608(%rbp)
	shlq	$4, %rsi
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_373
## %bb.52:
	movq	%rax, -15600(%rbp)
LBB3_53:
	leaq	1(%rbx), %rcx
	movq	%rcx, -15616(%rbp)
	shlq	$4, %rbx
	xorps	%xmm0, %xmm0
	movups	%xmm0, (%rax,%rbx)
	movl	$1162104654, 8(%rax,%rbx)       ## imm = 0x45444F4E
	movb	$83, 12(%rax,%rbx)
	leaq	-15552(%rbp), %rax
	leaq	L_.str.347(%rip), %r9
	leaq	-15600(%rbp), %r14
	leaq	-15616(%rbp), %r15
	leaq	-15608(%rbp), %r12
	leaq	-15588(%rbp), %r13
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	movq	-15624(%rbp), %rbx              ## 8-byte Reload
	movq	%rbx, %rcx
	movq	%r13, %r8
	pushq	$26
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	-15641(%rbp), %rax
	leaq	L_.str.348(%rip), %r9
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	movq	%rbx, %rcx
	movq	%r13, %r8
	pushq	$1
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	leaq	-15584(%rbp), %rax
	leaq	L_.str.349(%rip), %r9
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	movq	%rbx, %r13
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	pushq	$26
	pushq	%rax
	callq	_add_lump
	addq	$16, %rsp
	movl	$33, %ebx
	leaq	L_.str.405(%rip), %r14
	leaq	-15248(%rbp), %r15
	movq	-15664(%rbp), %r12              ## 8-byte Reload
	.p2align	4
LBB3_54:                                ## =>This Inner Loop Header: Depth=1
	movl	$16, %esi
	movq	%r15, %rdi
	movq	%r14, %rdx
	movl	%ebx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r13, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r15, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	incl	%ebx
	cmpl	$96, %ebx
	jne	LBB3_54
## %bb.55:
	leaq	L_.str.406(%rip), %r15
	leaq	-15248(%rbp), %r14
	movl	$16, %esi
	movq	%r14, %rdi
	movq	%r15, %rdx
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	leaq	-15588(%rbp), %r8
	movq	%r13, %rbx
	movq	%r13, %rcx
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	movq	%r15, %rdx
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %r15
	movq	%r15, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %r13
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r15, %rdi
	leaq	-15616(%rbp), %rsi
	movq	%rsi, %r15
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%rdi, %r15
	leaq	-15616(%rbp), %rsi
	movq	%rsi, %r13
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.406(%rip), %rdx
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r15, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.407(%rip), %r9
	movq	%r15, %rdi
	movq	%r13, %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%r14, %rdi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r15, %rdi
	movq	%r15, %r13
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%rdx, %r15
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r13, %rdi
	leaq	-15616(%rbp), %rsi
	movq	%rsi, %r13
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.408(%rip), %rdx
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.409(%rip), %r9
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.410(%rip), %rdx
	movl	$16, %esi
	movq	%r14, %rdi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.410(%rip), %rdx
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.410(%rip), %rdx
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.410(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.410(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.410(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.411(%rip), %r9
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.412(%rip), %rdx
	movl	$16, %esi
	movq	%r14, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.412(%rip), %rdx
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.412(%rip), %rdx
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.412(%rip), %rdx
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.412(%rip), %rdx
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%r14, %rdi
	leaq	L_.str.412(%rip), %rdx
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	movq	%r14, %r9
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.413(%rip), %r9
	leaq	-15600(%rbp), %rdi
	movq	%rdi, %r14
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.414(%rip), %r9
	movq	%r14, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	movq	%rbx, %rcx
	leaq	-15588(%rbp), %r8
	pushq	$18
	pushq	%r12
	callq	_add_lump
	addq	$16, %rsp
	xorl	%r14d, %r14d
	movq	%r12, %r13
	movq	-15624(%rbp), %r15              ## 8-byte Reload
	.p2align	4
LBB3_56:                                ## =>This Inner Loop Header: Depth=1
	movl	$16, %esi
	leaq	-15248(%rbp), %rbx
	movq	%rbx, %rdi
	leaq	L_.str.415(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%r8d, %r8d
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.415(%rip), %rdx
	movl	%r14d, %ecx
	movl	$1, %r8d
	xorl	%eax, %eax
	callq	_snprintf
	leaq	-15600(%rbp), %r12
	movq	%r12, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.415(%rip), %rdx
	movl	%r14d, %ecx
	movl	$2, %r8d
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r12, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.416(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r12, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.417(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r12, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.418(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r12, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.419(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r12, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	movl	$16, %esi
	movq	%rbx, %rdi
	leaq	L_.str.420(%rip), %rdx
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	_snprintf
	movq	%r12, %rdi
	leaq	-15616(%rbp), %rsi
	leaq	-15608(%rbp), %rdx
	movq	%r15, %rcx
	leaq	-15588(%rbp), %r8
	movq	%rbx, %r9
	pushq	$18
	pushq	%r13
	callq	_add_lump
	addq	$16, %rsp
	incl	%r14d
	cmpl	$5, %r14d
	jne	LBB3_56
## %bb.57:
	leaq	L_.str.421(%rip), %r9
	leaq	-15600(%rbp), %r15
	leaq	-15616(%rbp), %r12
	leaq	-15608(%rbp), %r13
	leaq	-15588(%rbp), %r14
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	-15624(%rbp), %rbx              ## 8-byte Reload
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	-15664(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.422(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	-15664(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.423(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	-15664(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.424(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	-15664(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	leaq	L_.str.425(%rip), %r9
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	pushq	$18
	pushq	-15664(%rbp)                    ## 8-byte Folded Reload
	callq	_add_lump
	addq	$16, %rsp
	movl	-15588(%rbp), %eax
	movq	-15616(%rbp), %rdx
	movq	%rdx, %rcx
	shlq	$4, %rcx
	leaq	(%rcx,%rax), %r14
	cmpq	$1048576, %r14                  ## imm = 0x100000
	ja	LBB3_367
## %bb.58:
	testq	%rdx, %rdx
	je	LBB3_63
## %bb.59:
	movq	-15600(%rbp), %rsi
	addq	$8, %rsi
	movq	%rax, %rdi
	movq	%rdx, %r8
	.p2align	4
LBB3_60:                                ## =>This Inner Loop Header: Depth=1
	cmpq	$1048573, %rdi                  ## imm = 0xFFFFD
	jae	LBB3_338
## %bb.61:                              ##   in Loop: Header=BB3_60 Depth=1
	movl	-8(%rsi), %r9d
	movl	%r9d, (%rbx,%rdi)
	leaq	-1048569(%rdi), %r9
	cmpq	$-1048578, %r9                  ## imm = 0xFFEFFFFE
	jbe	LBB3_339
## %bb.62:                              ##   in Loop: Header=BB3_60 Depth=1
	movl	-4(%rsi), %r9d
	movl	%r9d, 4(%rbx,%rdi)
	movq	(%rsi), %r9
	movq	%r9, 8(%rbx,%rdi)
	addq	$16, %rsi
	addq	$16, %rdi
	decq	%r8
	jne	LBB3_60
LBB3_63:
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
	je	LBB3_66
## %bb.64:
	addq	%rax, %rcx
	movl	$40, %r15d
	subq	%rcx, %r15
	leaq	L___const.build_generated_wad.pattern(%rip), %r13
	.p2align	4
LBB3_65:                                ## =>This Inner Loop Header: Depth=1
	leaq	40(%r14), %r12
	cmpq	$1048536, %r14                  ## imm = 0xFFFD8
	movl	$1048536, %edx                  ## imm = 0xFFFD8
	cmovbq	%r14, %rdx
	addq	%r15, %rdx
	leaq	(%rbx,%r14), %rdi
	movq	%r13, %rsi
	callq	_memcpy
	addq	$-40, %r15
	cmpq	$1048536, %r14                  ## imm = 0xFFFD8
	movq	%r12, %r14
	jb	LBB3_65
LBB3_66:
	movq	-15600(%rbp), %rdi
	callq	_free
	movq	-15664(%rbp), %rdi              ## 8-byte Reload
	callq	_free
	movq	-15776(%rbp), %rdi              ## 8-byte Reload
	callq	_free
	movq	-15632(%rbp), %rdi              ## 8-byte Reload
	callq	_free
	movq	-15640(%rbp), %rdi              ## 8-byte Reload
	callq	_free
	movq	-15792(%rbp), %rdi              ## 8-byte Reload
	callq	_free
	movl	$1048576, %ebx                  ## imm = 0x100000
	movq	-15656(%rbp), %r12              ## 8-byte Reload
LBB3_67:
	movq	%rbx, -15752(%rbp)
	movl	$0, -15584(%rbp)
	leaq	-15584(%rbp), %rcx
	movq	%r12, %rdi
	movq	-15624(%rbp), %rsi              ## 8-byte Reload
	movq	%rbx, %rdx
	callq	_write_cluster_chain
	cmpl	$2, %eax
	jne	LBB3_345
## %bb.68:
	movq	40(%rbp), %r13
	movq	24(%rbp), %rax
	movq	%rax, -15640(%rbp)              ## 8-byte Spill
	movq	16(%rbp), %r15
	movq	(%r12), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  ## imm = 0x140260
	xorl	%esi, %esi
                                        ## implicit-def: $ecx
	movq	-15768(%rbp), %r14              ## 8-byte Reload
LBB3_69:                                ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_71
## %bb.70:                              ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	jne	LBB3_72
LBB3_71:                                ##   in Loop: Header=BB3_69 Depth=1
	movl	%esi, %ecx
LBB3_72:                                ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	je	LBB3_91
## %bb.73:                              ##   in Loop: Header=BB3_69 Depth=1
	cmpl	$229, %edi
	je	LBB3_91
## %bb.74:                              ##   in Loop: Header=BB3_69 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_76
## %bb.75:                              ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	jne	LBB3_77
LBB3_76:                                ##   in Loop: Header=BB3_69 Depth=1
	leaq	1(%rsi), %rcx
LBB3_77:                                ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	je	LBB3_91
## %bb.78:                              ##   in Loop: Header=BB3_69 Depth=1
	cmpl	$229, %edi
	je	LBB3_91
## %bb.79:                              ##   in Loop: Header=BB3_69 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_81
## %bb.80:                              ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	jne	LBB3_82
LBB3_81:                                ##   in Loop: Header=BB3_69 Depth=1
	leaq	2(%rsi), %rcx
LBB3_82:                                ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	je	LBB3_91
## %bb.83:                              ##   in Loop: Header=BB3_69 Depth=1
	cmpl	$229, %edi
	je	LBB3_91
## %bb.84:                              ##   in Loop: Header=BB3_69 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_86
## %bb.85:                              ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	jne	LBB3_87
LBB3_86:                                ##   in Loop: Header=BB3_69 Depth=1
	leaq	3(%rsi), %rcx
LBB3_87:                                ##   in Loop: Header=BB3_69 Depth=1
	testl	%edi, %edi
	je	LBB3_91
## %bb.88:                              ##   in Loop: Header=BB3_69 Depth=1
	cmpl	$229, %edi
	je	LBB3_91
## %bb.89:                              ##   in Loop: Header=BB3_69 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      ## imm = 0x200
	jne	LBB3_69
## %bb.90:
	callq	_install_bootable_layout.cold.46
LBB3_91:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB3_346
## %bb.92:
	shll	$5, %ecx
	xorps	%xmm0, %xmm0
	movups	%xmm0, (%rax,%rcx)
	movups	%xmm0, 16(%rax,%rcx)
	movabsq	$2314885604590964548, %rdx      ## imm = 0x202020314D4F4F44
	movq	%rdx, (%rax,%rcx)
	movl	$1145132832, 7(%rax,%rcx)       ## imm = 0x44415720
	movb	$32, 11(%rax,%rcx)
	movw	$2, 26(%rax,%rcx)
	movb	%bl, 28(%rax,%rcx)
	movb	%bh, 29(%rax,%rcx)
	shrl	$16, %ebx
	movb	%bl, 30(%rax,%rcx)
	movb	$0, 31(%rax,%rcx)
	movq	-15624(%rbp), %rdi              ## 8-byte Reload
	callq	_free
	movq	-15672(%rbp), %rdi              ## 8-byte Reload
	testq	%rdi, %rdi
	je	LBB3_94
## %bb.93:
	callq	_read_file
	movq	%rax, %rbx
	movq	%rdx, %r8
	leaq	_KERNEL_ELF_NAME(%rip), %rsi
	movl	$1, %edx
	movq	%r12, %rdi
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	_write_file_path
	movq	%rbx, %rdi
	callq	_free
LBB3_94:
	testq	%r14, %r14
	je	LBB3_96
## %bb.95:
	movq	%r14, %rdi
	callq	_read_file
	movq	%rax, %rbx
	movq	%rdx, %r8
	leaq	_USER_PROBE_NAME(%rip), %rsi
	movl	$1, %edx
	movq	%r12, %rdi
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	_write_file_path
	movq	%rbx, %rdi
	callq	_free
LBB3_96:
	cmpq	$0, 24(%rbp)
	movq	32(%rbp), %r14
	je	LBB3_105
## %bb.97:
	movq	-15728(%rbp), %r12
	movq	-15720(%rbp), %rax
	movq	%rax, -15632(%rbp)              ## 8-byte Spill
	jmp	LBB3_100
	.p2align	4
LBB3_98:                                ##   in Loop: Header=BB3_100 Depth=1
	movq	%r13, %r15
LBB3_99:                                ##   in Loop: Header=BB3_100 Depth=1
	movq	-15624(%rbp), %rdi              ## 8-byte Reload
	callq	_free
	addq	$24, %r15
	decq	-15640(%rbp)                    ## 8-byte Folded Spill
	je	LBB3_104
LBB3_100:                               ## =>This Inner Loop Header: Depth=1
	movq	16(%r15), %rdi
	callq	_read_file
	movq	%rax, %rcx
	movq	%rdx, %rbx
	movl	7(%r15), %eax
	movl	%eax, -15225(%rbp)
	movq	(%r15), %rax
	movq	%rax, -15232(%rbp)
	movl	$1, %edx
	movq	-15656(%rbp), %rdi              ## 8-byte Reload
	movq	%r15, %r13
	leaq	-15232(%rbp), %rsi
	movq	%rcx, -15624(%rbp)              ## 8-byte Spill
	movq	%rbx, %r8
	movl	$32, %r9d
	callq	_write_file_path
	cmpl	$0, 64(%rbp)
	je	LBB3_98
## %bb.101:                             ##   in Loop: Header=BB3_100 Depth=1
	movq	%r13, %r15
	movq	%r13, %rdi
	leaq	-15232(%rbp), %r13
	movq	%r13, %rsi
	callq	_format_fat_name
	imulq	$104, -15632(%rbp), %r14        ## 8-byte Folded Reload
	leaq	104(%r14), %rsi
	movq	%r12, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_330
## %bb.102:                             ##   in Loop: Header=BB3_100 Depth=1
	movq	%rax, %r12
	leaq	(%rax,%r14), %rdi
	movl	$96, %esi
	leaq	L_.str.427(%rip), %rdx
	movq	%r13, %rcx
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$96, %eax
	jae	LBB3_331
## %bb.103:                             ##   in Loop: Header=BB3_100 Depth=1
	movq	%rbx, 96(%r12,%r14)
	incq	-15632(%rbp)                    ## 8-byte Folded Spill
	movq	32(%rbp), %r14
	jmp	LBB3_99
LBB3_104:
	movq	%r12, -15728(%rbp)
	movq	-15632(%rbp), %rax              ## 8-byte Reload
	movq	%rax, -15720(%rbp)
	movq	-15656(%rbp), %r12              ## 8-byte Reload
	movq	40(%rbp), %r13
LBB3_105:
	testq	%r13, %r13
	je	LBB3_113
## %bb.106:
	movq	-15712(%rbp), %rax
	movq	%rax, -15640(%rbp)              ## 8-byte Spill
	movq	-15704(%rbp), %rax
	movq	%rax, -15632(%rbp)              ## 8-byte Spill
	leaq	-15232(%rbp), %rbx
	jmp	LBB3_108
	.p2align	4
LBB3_107:                               ##   in Loop: Header=BB3_108 Depth=1
	movq	%r12, %rdi
	callq	_free
	addq	$24, %r14
	movq	-15624(%rbp), %r13              ## 8-byte Reload
	decq	%r13
	je	LBB3_112
LBB3_108:                               ## =>This Inner Loop Header: Depth=1
	movq	%r13, -15624(%rbp)              ## 8-byte Spill
	movq	16(%r14), %rdi
	callq	_read_file
	movq	%rax, %r12
	movq	%rdx, %r15
	movl	7(%r14), %eax
	movl	%eax, -15225(%rbp)
	movq	(%r14), %rax
	movq	%rax, -15232(%rbp)
	movl	$1, %edx
	movq	-15656(%rbp), %rdi              ## 8-byte Reload
	movq	%rbx, %rsi
	movq	%r12, %rcx
	movq	%r15, %r8
	movl	$32, %r9d
	callq	_write_file_path
	cmpl	$0, 64(%rbp)
	je	LBB3_107
## %bb.109:                             ##   in Loop: Header=BB3_108 Depth=1
	movq	%r12, -15672(%rbp)              ## 8-byte Spill
	movq	%r14, %r13
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_format_fat_name
	imulq	$104, -15632(%rbp), %r14        ## 8-byte Folded Reload
	leaq	104(%r14), %rsi
	movq	-15640(%rbp), %rdi              ## 8-byte Reload
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_332
## %bb.110:                             ##   in Loop: Header=BB3_108 Depth=1
	leaq	(%rax,%r14), %rdi
	movl	$96, %esi
	leaq	L_.str.427(%rip), %rdx
	movq	%rbx, %r12
	movq	%rbx, %rcx
	movq	%rax, %rbx
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$96, %eax
	jae	LBB3_333
## %bb.111:                             ##   in Loop: Header=BB3_108 Depth=1
	movq	%rbx, -15640(%rbp)              ## 8-byte Spill
	movq	%r15, 96(%rbx,%r14)
	incq	-15632(%rbp)                    ## 8-byte Folded Spill
	movq	%r13, %r14
	movq	%r12, %rbx
	movq	-15672(%rbp), %r12              ## 8-byte Reload
	jmp	LBB3_107
LBB3_112:
	movq	-15640(%rbp), %rax              ## 8-byte Reload
	movq	%rax, -15712(%rbp)
	movq	-15632(%rbp), %rax              ## 8-byte Reload
	movq	%rax, -15704(%rbp)
	movq	-15656(%rbp), %r12              ## 8-byte Reload
LBB3_113:
	movq	$0, -15328(%rbp)
	leaq	_STATE_DIR_NAME(%rip), %rdx
	movq	%r12, %rdi
	xorl	%esi, %esi
	movl	$16, %ecx
	callq	_ensure_child_directory
	leaq	_DEFAULT_PI4_ASSET_README_PATH(%rip), %rdi
	leaq	-15232(%rbp), %rbx
	leaq	-15328(%rbp), %r14
	movl	$4, %ecx
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	_parse_path83
	movq	-15328(%rbp), %rdx
	leaq	_DEFAULT_PI4_ASSET_README(%rip), %rcx
	movl	$35, %r8d
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movl	$33, %r9d
	callq	_write_file_path
	leaq	_DEFAULT_PI4_ASSET_MAP_PATH(%rip), %rdi
	movl	$4, %ecx
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	_parse_path83
	movq	-15328(%rbp), %rdx
	leaq	_DEFAULT_PI4_ASSET_MAP(%rip), %rcx
	movl	$23, %r8d
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movl	$33, %r9d
	callq	_write_file_path
	movaps	LCPI3_2(%rip), %xmm0            ## xmm0 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movaps	%xmm0, -15456(%rbp)
	movdqa	LCPI3_14(%rip), %xmm0           ## xmm0 = [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
	movdqa	%xmm0, -15440(%rbp)
	leaq	_DEFAULT_PI4_ASSET_PALETTE_PATH(%rip), %rdi
	movl	$4, %ecx
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	_parse_path83
	movq	-15328(%rbp), %rdx
	leaq	-15456(%rbp), %rcx
	movl	$32, %r8d
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movl	$33, %r9d
	callq	_write_file_path
	cmpq	$0, 56(%rbp)
	je	LBB3_149
## %bb.114:
	movabsq	$2314885530818453536, %rax      ## imm = 0x2020202020202020
	leaq	1123369(%rax), %rcx
	movq	%rcx, -15632(%rbp)              ## 8-byte Spill
	addq	$271262000, %rax                ## imm = 0x102B2130
	movq	%rax, -15672(%rbp)              ## 8-byte Spill
	xorl	%r12d, %r12d
	jmp	LBB3_116
	.p2align	4
LBB3_115:                               ##   in Loop: Header=BB3_116 Depth=1
	incq	%r12
	cmpq	56(%rbp), %r12
	je	LBB3_149
LBB3_116:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB3_143 Depth 2
	imulq	$104, %r12, %rax
	movq	48(%rbp), %rcx
	leaq	(%rcx,%rax), %r14
	movq	96(%rcx,%rax), %r15
	movq	$0, -15456(%rbp)
	movl	$8, %ecx
	movq	%r14, %rdi
	leaq	-15232(%rbp), %rsi
	leaq	-15456(%rbp), %rdx
	callq	_parse_path83
	movq	-15456(%rbp), %rbx
	cmpq	$1, %rbx
	jbe	LBB3_329
## %bb.117:                             ##   in Loop: Header=BB3_116 Depth=1
	cmpq	$2, %rbx
	movq	%r14, -15624(%rbp)              ## 8-byte Spill
	jne	LBB3_119
## %bb.118:                             ##   in Loop: Header=BB3_116 Depth=1
	movq	-15232(%rbp), %rax
	xorq	-15632(%rbp), %rax              ## 8-byte Folded Reload
	movq	-15229(%rbp), %rcx
	movabsq	$2314885530818453536, %rdx      ## imm = 0x2020202020202020
	xorq	%rdx, %rcx
	orq	%rax, %rcx
	je	LBB3_127
LBB3_119:                               ##   in Loop: Header=BB3_116 Depth=1
	movq	%r15, %rdi
	callq	_read_file
	movq	%rax, %r13
	movq	%rdx, %r14
LBB3_120:                               ##   in Loop: Header=BB3_116 Depth=1
	xorl	%r15d, %r15d
LBB3_121:                               ##   in Loop: Header=BB3_116 Depth=1
	movq	-15656(%rbp), %rdi              ## 8-byte Reload
	leaq	-15232(%rbp), %rsi
	movq	%rbx, %rdx
	movq	%r13, %rcx
	movq	%r14, %r8
	movl	$33, %r9d
	callq	_write_file_path
	movq	%r13, %rdi
	callq	_free
	testb	%r15b, %r15b
	je	LBB3_123
## %bb.122:                             ##   in Loop: Header=BB3_116 Depth=1
	movl	$1, -15744(%rbp)
	movq	%r14, -15736(%rbp)
LBB3_123:                               ##   in Loop: Header=BB3_116 Depth=1
	cmpl	$0, 64(%rbp)
	je	LBB3_115
## %bb.124:                             ##   in Loop: Header=BB3_116 Depth=1
	movq	-15696(%rbp), %rdi
	movq	-15688(%rbp), %r15
	imulq	$104, %r15, %r13
	leaq	104(%r13), %rsi
	callq	_realloc
	testq	%rax, %rax
	je	LBB3_334
## %bb.125:                             ##   in Loop: Header=BB3_116 Depth=1
	movq	%rax, %rbx
	movq	%rax, -15696(%rbp)
	movq	%rax, %rdi
	addq	%r13, %rdi
	movl	$96, %esi
	leaq	L_.str.427(%rip), %rdx
	movq	-15624(%rbp), %rcx              ## 8-byte Reload
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$96, %eax
	jae	LBB3_335
## %bb.126:                             ##   in Loop: Header=BB3_116 Depth=1
	movq	%r14, 96(%rbx,%r13)
	incq	%r15
	movq	%r15, -15688(%rbp)
	jmp	LBB3_115
LBB3_127:                               ##   in Loop: Header=BB3_116 Depth=1
	movq	-15221(%rbp), %rax
	xorq	-15672(%rbp), %rax              ## 8-byte Folded Reload
	movq	-15218(%rbp), %rcx
	movabsq	$5422703525238939696, %rdx      ## imm = 0x4B41502020202030
	xorq	%rdx, %rcx
	xorl	%edx, %edx
	orq	%rax, %rcx
	sete	%al
	movl	%eax, -15640(%rbp)              ## 4-byte Spill
	setne	%dl
	cmpl	$0, 64(%rbp)
	je	LBB3_130
## %bb.128:                             ##   in Loop: Header=BB3_116 Depth=1
	testl	%edx, %edx
	jne	LBB3_130
## %bb.129:                             ##   in Loop: Header=BB3_116 Depth=1
	movq	%r15, %rdi
	leaq	L_.str.430(%rip), %rsi
	callq	_reject_repo_local_external_asset
	movq	%r15, %rdi
	callq	_read_file
	movq	%rax, %r13
	movq	%rdx, %r14
	jmp	LBB3_131
LBB3_130:                               ##   in Loop: Header=BB3_116 Depth=1
	movq	%r15, %rdi
	movl	%edx, -15768(%rbp)              ## 4-byte Spill
	callq	_read_file
	movq	%rax, %r13
	movq	%rdx, %r14
	cmpl	$0, -15768(%rbp)                ## 4-byte Folded Reload
	jne	LBB3_120
LBB3_131:                               ##   in Loop: Header=BB3_116 Depth=1
	cmpq	$11, %r14
	jbe	LBB3_341
## %bb.132:                             ##   in Loop: Header=BB3_116 Depth=1
	cmpl	$1262698832, (%r13)             ## imm = 0x4B434150
	jne	LBB3_342
## %bb.133:                             ##   in Loop: Header=BB3_116 Depth=1
	movl	8(%r13), %eax
	testq	%rax, %rax
	je	LBB3_343
## %bb.134:                             ##   in Loop: Header=BB3_116 Depth=1
	movl	%eax, %ecx
	andl	$63, %ecx
	jne	LBB3_343
## %bb.135:                             ##   in Loop: Header=BB3_116 Depth=1
	movl	4(%r13), %ecx
	leaq	(%rax,%rcx), %rdx
	cmpq	%r14, %rdx
	ja	LBB3_340
## %bb.136:                             ##   in Loop: Header=BB3_116 Depth=1
	leaq	60(%rcx), %rdx
	cmpq	%r14, %rdx
	ja	LBB3_327
## %bb.137:                             ##   in Loop: Header=BB3_116 Depth=1
	leaq	64(%rcx), %rdx
	cmpq	%r14, %rdx
	ja	LBB3_325
## %bb.138:                             ##   in Loop: Header=BB3_116 Depth=1
	cmpb	$0, (%r13,%rcx)
	je	LBB3_326
## %bb.139:                             ##   in Loop: Header=BB3_116 Depth=1
	movl	56(%r13,%rcx), %edx
	movl	60(%r13,%rcx), %esi
	addq	%rdx, %rsi
	cmpq	%r14, %rsi
	ja	LBB3_324
## %bb.140:                             ##   in Loop: Header=BB3_116 Depth=1
	cmpl	$64, %eax
	je	LBB3_141
## %bb.142:                             ##   in Loop: Header=BB3_116 Depth=1
	shrl	$6, %eax
	decq	%rax
	subq	$-128, %rcx
	.p2align	4
LBB3_143:                               ##   Parent Loop BB3_116 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	leaq	-4(%rcx), %rdx
	cmpq	%r14, %rdx
	ja	LBB3_327
## %bb.144:                             ##   in Loop: Header=BB3_143 Depth=2
	cmpq	%r14, %rcx
	ja	LBB3_325
## %bb.145:                             ##   in Loop: Header=BB3_143 Depth=2
	cmpb	$0, -64(%r13,%rcx)
	je	LBB3_326
## %bb.146:                             ##   in Loop: Header=BB3_143 Depth=2
	movl	-8(%r13,%rcx), %edx
	movl	-4(%r13,%rcx), %esi
	addq	%rdx, %rsi
	cmpq	%r14, %rsi
	ja	LBB3_324
## %bb.147:                             ##   in Loop: Header=BB3_143 Depth=2
	addq	$64, %rcx
	decq	%rax
	jne	LBB3_143
LBB3_141:                               ##   in Loop: Header=BB3_116 Depth=1
	movl	-15640(%rbp), %r15d             ## 4-byte Reload
	jmp	LBB3_121
LBB3_149:
	cmpl	$0, 64(%rbp)
	movq	-15656(%rbp), %r15              ## 8-byte Reload
	je	LBB3_208
## %bb.150:
	leaq	_PI4_KERNEL8_IMG_NAME(%rip), %rdx
	leaq	L_.str.165(%rip), %rcx
	leaq	-15760(%rbp), %rbx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	callq	_proof_manifest_require_root_file
	leaq	_PI4_CONFIG_TXT_NAME(%rip), %rdx
	leaq	L_.str.168(%rip), %rcx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	callq	_proof_manifest_require_root_file
	cmpq	$0, -15720(%rbp)
	jne	LBB3_359
## %bb.151:
	movq	-15688(%rbp), %rbx
	testq	%rbx, %rbx
	je	LBB3_155
## %bb.152:
	movq	-15696(%rbp), %r14
	leaq	_PI4_SYSTEM_INIT_PATH(%rip), %r13
	movq	%r14, %r15
	movq	%rbx, %r12
	.p2align	4
LBB3_153:                               ## =>This Inner Loop Header: Depth=1
	movq	%r15, %rdi
	movq	%r13, %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB3_156
## %bb.154:                             ##   in Loop: Header=BB3_153 Depth=1
	addq	$104, %r15
	decq	%r12
	jne	LBB3_153
LBB3_155:
	callq	_install_bootable_layout.cold.35
LBB3_156:
	cmpq	$0, 96(%r15)
	je	LBB3_155
## %bb.157:
	movq	%r14, %r12
	movq	%rbx, %r13
	.p2align	4
LBB3_158:                               ## =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	leaq	_PI4_SYSTEM_ABIPROBE_PATH(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB3_161
## %bb.159:                             ##   in Loop: Header=BB3_158 Depth=1
	addq	$104, %r12
	decq	%r13
	jne	LBB3_158
LBB3_160:
	callq	_install_bootable_layout.cold.34
LBB3_161:
	cmpq	$0, 96(%r12)
	je	LBB3_160
## %bb.162:
	leaq	_PI4_APP_INDEX_PATH(%rip), %r13
	.p2align	4
LBB3_163:                               ## =>This Inner Loop Header: Depth=1
	movq	%r14, %rdi
	movq	%r13, %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB3_166
## %bb.164:                             ##   in Loop: Header=BB3_163 Depth=1
	addq	$104, %r14
	decq	%rbx
	jne	LBB3_163
LBB3_165:
	callq	_install_bootable_layout.cold.33
LBB3_166:
	cmpq	$0, 96(%r14)
	je	LBB3_165
## %bb.167:
	movq	-15656(%rbp), %rcx              ## 8-byte Reload
	movq	(%rcx), %rax
	movq	%rax, -15520(%rbp)
	movq	8(%rcx), %rax
	movq	%rax, -15512(%rbp)
	leaq	-15520(%rbp), %rdi
	leaq	-15232(%rbp), %rsi
	xorl	%edx, %edx
	callq	_load_pi4_app_catalog
	pxor	%xmm0, %xmm0
	movdqa	%xmm0, -15328(%rbp)
	movq	$0, -15312(%rbp)
	movq	-15704(%rbp), %r13
	testq	%r13, %r13
	je	LBB3_172
## %bb.168:
	movq	%r14, -15640(%rbp)              ## 8-byte Spill
	movq	-15712(%rbp), %r14
	movq	%r14, -15632(%rbp)              ## 8-byte Spill
	movq	%r13, %rbx
	.p2align	4
LBB3_169:                               ## =>This Inner Loop Header: Depth=1
	movq	%r14, %rdi
	leaq	L_.str.165(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB3_173
## %bb.170:                             ##   in Loop: Header=BB3_169 Depth=1
	addq	$104, %r14
	decq	%rbx
	jne	LBB3_169
## %bb.171:
	movq	$0, -15624(%rbp)                ## 8-byte Folded Spill
	jmp	LBB3_174
LBB3_172:
	movq	$0, -15624(%rbp)                ## 8-byte Folded Spill
	jmp	LBB3_177
LBB3_173:
	movq	%r14, -15624(%rbp)              ## 8-byte Spill
LBB3_174:
	movq	-15632(%rbp), %rbx              ## 8-byte Reload
	movq	-15640(%rbp), %r14              ## 8-byte Reload
	.p2align	4
LBB3_175:                               ## =>This Inner Loop Header: Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.168(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB3_178
## %bb.176:                             ##   in Loop: Header=BB3_175 Depth=1
	addq	$104, %rbx
	decq	%r13
	jne	LBB3_175
LBB3_177:
	xorl	%ebx, %ebx
LBB3_178:
	leaq	L_.str.439(%rip), %rsi
	leaq	-15328(%rbp), %r13
	movq	%r13, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.440(%rip), %rsi
	movq	%r13, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.139(%rip), %rsi
	movq	%r13, %rdi
	movl	$2561, %edx                     ## imm = 0xA01
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.140(%rip), %rsi
	movq	%r13, %rdi
	movl	$2593, %edx                     ## imm = 0xA21
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.141(%rip), %rsi
	movq	%r13, %rdi
	movl	$512, %edx                      ## imm = 0x200
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.441(%rip), %rsi
	leaq	_PROOF_MANIFEST_PATH(%rip), %rdx
	movq	%r13, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	movq	-15624(%rbp), %r13              ## 8-byte Reload
	testq	%r13, %r13
	je	LBB3_181
## %bb.179:
	leaq	L_.str.442(%rip), %rsi
	leaq	-15328(%rbp), %rdi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r13), %rdx
	leaq	L_.str.443(%rip), %rsi
	leaq	-15328(%rbp), %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	testq	%rbx, %rbx
	je	LBB3_182
LBB3_180:
	leaq	L_.str.445(%rip), %rsi
	leaq	-15328(%rbp), %r13
	movq	%r13, %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%rbx), %rdx
	leaq	L_.str.446(%rip), %rsi
	movq	%r13, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	jmp	LBB3_183
LBB3_181:
	leaq	L_.str.444(%rip), %rsi
	leaq	-15328(%rbp), %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	testq	%rbx, %rbx
	jne	LBB3_180
LBB3_182:
	leaq	L_.str.447(%rip), %rsi
	leaq	-15328(%rbp), %rdi
	xorl	%eax, %eax
	callq	_text_appendf
LBB3_183:
	leaq	L_.str.448(%rip), %rsi
	leaq	-15328(%rbp), %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.449(%rip), %rsi
	leaq	_PI4_APP_LAYOUT(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.450(%rip), %rsi
	leaq	_PI4_APP_DISCOVERY_MODEL(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.451(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.452(%rip), %rsi
	leaq	_PI4_APP_EXEC_MODEL(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.248(%rip), %rsi
	leaq	L_.str.177(%rip), %r13
	movq	%rbx, %rdi
	movq	%r13, %rdx
	movq	%r15, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r15), %rcx
	leaq	L_.str.499(%rip), %r15
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.179(%rip), %r13
	movq	%rbx, %rdi
	leaq	L_.str.248(%rip), %rsi
	movq	%r13, %rdx
	movq	%r12, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r12), %rcx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.181(%rip), %r12
	movq	%rbx, %rdi
	leaq	L_.str.248(%rip), %rsi
	movq	%r12, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r14), %rcx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	-15232(%rbp), %rcx
	leaq	L_.str.453(%rip), %rsi
	leaq	_PI4_APP_RECORD_COUNT_KEY(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	cmpq	$0, -15232(%rbp)
	je	LBB3_195
## %bb.184:
	leaq	-15224(%rbp), %rax
	movq	-15696(%rbp), %r12
	movq	-15688(%rbp), %rcx
	movq	%rcx, -15632(%rbp)              ## 8-byte Spill
	xorl	%ebx, %ebx
	movq	%r12, -15640(%rbp)              ## 8-byte Spill
	.p2align	4
LBB3_185:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB3_187 Depth 2
                                        ##     Child Loop BB3_191 Depth 2
	imulq	$948, %rbx, %rcx                ## imm = 0x3B4
	movq	%rcx, -15624(%rbp)              ## 8-byte Spill
	leaq	(%rax,%rcx), %r14
	addq	$160, %r14
	cmpq	$0, -15632(%rbp)                ## 8-byte Folded Reload
	je	LBB3_321
## %bb.186:                             ##   in Loop: Header=BB3_185 Depth=1
	addq	%rax, -15624(%rbp)              ## 8-byte Folded Spill
	movq	%r12, %r13
	movq	-15632(%rbp), %r15              ## 8-byte Reload
	.p2align	4
LBB3_187:                               ##   Parent Loop BB3_185 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	%r13, %rdi
	movq	%r14, %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB3_189
## %bb.188:                             ##   in Loop: Header=BB3_187 Depth=2
	addq	$104, %r13
	decq	%r15
	jne	LBB3_187
	jmp	LBB3_321
	.p2align	4
LBB3_189:                               ##   in Loop: Header=BB3_185 Depth=1
	cmpq	$0, 96(%r13)
	je	LBB3_321
## %bb.190:                             ##   in Loop: Header=BB3_185 Depth=1
	movq	-15624(%rbp), %rax              ## 8-byte Reload
	leaq	320(%rax), %r15
	movq	%r12, %r14
	movq	-15632(%rbp), %r12              ## 8-byte Reload
	.p2align	4
LBB3_191:                               ##   Parent Loop BB3_185 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB3_193
## %bb.192:                             ##   in Loop: Header=BB3_191 Depth=2
	addq	$104, %r14
	decq	%r12
	jne	LBB3_191
	jmp	LBB3_322
	.p2align	4
LBB3_193:                               ##   in Loop: Header=BB3_185 Depth=1
	cmpq	$0, 96(%r14)
	je	LBB3_322
## %bb.194:                             ##   in Loop: Header=BB3_185 Depth=1
	leaq	-15328(%rbp), %r12
	movq	%r12, %rdi
	leaq	L_.str.500(%rip), %rsi
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rdx
	movq	%rbx, %rcx
	movq	-15624(%rbp), %r15              ## 8-byte Reload
	movq	%r15, %r8
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	64(%r15), %r8
	movq	%r12, %rdi
	leaq	L_.str.501(%rip), %rsi
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rdx
	movq	%rbx, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.502(%rip), %rsi
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r13), %r8
	movq	%r12, %rdi
	leaq	L_.str.503(%rip), %rsi
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %r13
	movq	%r13, %rdx
	movq	%rbx, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.504(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r14), %r8
	movq	%r12, %rdi
	leaq	L_.str.505(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.506(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	_PI4_APP_LAUNCH_MODEL(%rip), %r8
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.507(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	leaq	_PI4_APP_EXEC_MODEL(%rip), %r8
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	480(%r15), %r14
	movq	%r12, %rdi
	leaq	L_.str.508(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.509(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r14, %r8
	xorl	%eax, %eax
	callq	_text_appendf
	addq	$640, %r15                      ## imm = 0x280
	movq	%r12, %rdi
	leaq	L_.str.510(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.511(%rip), %rsi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	incq	%rbx
	cmpq	-15232(%rbp), %rbx
	leaq	-15224(%rbp), %rax
	movq	-15640(%rbp), %r12              ## 8-byte Reload
	jb	LBB3_185
LBB3_195:
	leaq	L_.str.454(%rip), %rsi
	leaq	-15328(%rbp), %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.455(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.456(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	cmpq	$0, -15784(%rbp)                ## 8-byte Folded Reload
	leaq	L_.str.198(%rip), %rax
	leaq	L_.str.201(%rip), %rdx
	cmovneq	%rax, %rdx
	leaq	L_.str.457(%rip), %rsi
	leaq	L_.str.199(%rip), %rax
	leaq	L_.str.202(%rip), %r14
	cmovneq	%rax, %r14
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.458(%rip), %rsi
	movq	%rbx, %rdi
	movq	%r14, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.459(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.460(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	movq	-15752(%rbp), %rdx
	leaq	L_.str.461(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.462(%rip), %rsi
	movq	%rbx, %rdi
	movl	$3, %edx
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.463(%rip), %rsi
	leaq	_DEFAULT_PI4_ASSET_README_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.464(%rip), %rsi
	movl	$35, %edx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.465(%rip), %rsi
	leaq	_DEFAULT_PI4_ASSET_MAP_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.466(%rip), %rsi
	movl	$23, %edx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.467(%rip), %rsi
	leaq	_DEFAULT_PI4_ASSET_PALETTE_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.468(%rip), %rsi
	movq	%rbx, %rdi
	movl	$32, %edx
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.469(%rip), %rsi
	leaq	_PROOF_QUAKE_PAK_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.470(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	movl	-15744(%rbp), %r14d
	testl	%r14d, %r14d
	leaq	L_.str.226(%rip), %rax
	leaq	L_.str.193(%rip), %rdx
	cmoveq	%rax, %rdx
	leaq	L_.str.471(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	testl	%r14d, %r14d
	je	LBB3_197
## %bb.196:
	leaq	L_.str.472(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.473(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.474(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.475(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	movq	-15736(%rbp), %rdx
	leaq	L_.str.476(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	jmp	LBB3_198
LBB3_197:
	leaq	L_.str.477(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.478(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.479(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
	leaq	L_.str.475(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	_text_appendf
LBB3_198:
	movq	-15704(%rbp), %rbx
	leaq	L_.str.480(%rip), %rsi
	leaq	-15328(%rbp), %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	testq	%rbx, %rbx
	je	LBB3_201
## %bb.199:
	movq	-15712(%rbp), %r14
	leaq	-15328(%rbp), %r12
	leaq	L_.str.482(%rip), %r13
	xorl	%r15d, %r15d
	.p2align	4
LBB3_200:                               ## =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	leaq	L_.str.481(%rip), %rsi
	movq	%r15, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r14), %rcx
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	incq	%r15
	addq	$104, %r14
	cmpq	%r15, %rbx
	jne	LBB3_200
LBB3_201:
	movq	-15720(%rbp), %rbx
	leaq	L_.str.483(%rip), %rsi
	leaq	-15328(%rbp), %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	testq	%rbx, %rbx
	je	LBB3_204
## %bb.202:
	movq	-15728(%rbp), %r14
	leaq	-15328(%rbp), %r12
	leaq	L_.str.485(%rip), %r13
	xorl	%r15d, %r15d
	.p2align	4
LBB3_203:                               ## =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	leaq	L_.str.484(%rip), %rsi
	movq	%r15, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r14), %rcx
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	incq	%r15
	addq	$104, %r14
	cmpq	%r15, %rbx
	jne	LBB3_203
LBB3_204:
	movq	-15688(%rbp), %rbx
	leaq	L_.str.486(%rip), %rsi
	leaq	-15328(%rbp), %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	testq	%rbx, %rbx
	je	LBB3_207
## %bb.205:
	movq	-15696(%rbp), %r14
	leaq	-15328(%rbp), %r12
	leaq	_PROOF_QUAKE_PAK_PATH(%rip), %r13
	xorl	%r15d, %r15d
	.p2align	4
LBB3_206:                               ## =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	leaq	L_.str.487(%rip), %rsi
	movq	%r15, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r14, %rdi
	movq	%r13, %rsi
	callq	_strcmp
	testl	%eax, %eax
	leaq	L_.str.306(%rip), %rcx
	leaq	L_.str.305(%rip), %rax
	cmoveq	%rax, %rcx
	movq	%r12, %rdi
	leaq	L_.str.488(%rip), %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.489(%rip), %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r14, %rdi
	movq	%r13, %rsi
	callq	_strcmp
	testl	%eax, %eax
	leaq	L_.str.307(%rip), %rcx
	leaq	L_.str.199(%rip), %rax
	cmoveq	%rax, %rcx
	movq	%r12, %rdi
	leaq	L_.str.490(%rip), %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.491(%rip), %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	%r12, %rdi
	leaq	L_.str.492(%rip), %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	movq	96(%r14), %rcx
	movq	%r12, %rdi
	leaq	L_.str.493(%rip), %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_text_appendf
	incq	%r15
	addq	$104, %r14
	cmpq	%r15, %rbx
	jne	LBB3_206
LBB3_207:
	movq	$0, -15552(%rbp)
	leaq	_PROOF_MANIFEST_PATH(%rip), %rdi
	leaq	-15456(%rbp), %rbx
	leaq	-15552(%rbp), %rdx
	movl	$4, %ecx
	movq	%rbx, %rsi
	callq	_parse_path83
	movq	-15552(%rbp), %rdx
	movq	-15328(%rbp), %r14
	movq	-15320(%rbp), %r8
	movq	-15656(%rbp), %r15              ## 8-byte Reload
	movq	%r15, %rdi
	movq	%rbx, %rsi
	movq	%r14, %rcx
	movl	$33, %r9d
	callq	_write_file_path
	movq	%r14, %rdi
	callq	_free
LBB3_208:
	leaq	_DEFAULT_CFG_NAME(%rip), %rsi
	leaq	_DEFAULT_CFG_CONTENT(%rip), %rcx
	movl	$1, %edx
	movl	$17, %r8d
	movq	%r15, %rdi
	movl	$32, %r9d
	callq	_write_file_path
	xorl	%eax, %eax
	pxor	%xmm0, %xmm0
	.p2align	4
LBB3_209:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB3_210 Depth 2
	movl	%eax, %ecx
	orb	$48, %cl
	movq	(%r15), %rdi
	leaq	1311232(%rdi), %rdx
	addq	$1311328, %rdi                  ## imm = 0x140260
	xorl	%r8d, %r8d
                                        ## implicit-def: $esi
LBB3_210:                               ##   Parent Loop BB3_209 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	-96(%rdi), %r9d
	cmpl	$229, %r9d
	je	LBB3_212
## %bb.211:                             ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	jne	LBB3_213
LBB3_212:                               ##   in Loop: Header=BB3_210 Depth=2
	movl	%r8d, %esi
LBB3_213:                               ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	je	LBB3_231
## %bb.214:                             ##   in Loop: Header=BB3_210 Depth=2
	cmpl	$229, %r9d
	je	LBB3_231
## %bb.215:                             ##   in Loop: Header=BB3_210 Depth=2
	movzbl	-64(%rdi), %r9d
	cmpl	$229, %r9d
	je	LBB3_217
## %bb.216:                             ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	jne	LBB3_218
LBB3_217:                               ##   in Loop: Header=BB3_210 Depth=2
	leaq	1(%r8), %rsi
LBB3_218:                               ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	je	LBB3_231
## %bb.219:                             ##   in Loop: Header=BB3_210 Depth=2
	cmpl	$229, %r9d
	je	LBB3_231
## %bb.220:                             ##   in Loop: Header=BB3_210 Depth=2
	movzbl	-32(%rdi), %r9d
	cmpl	$229, %r9d
	je	LBB3_222
## %bb.221:                             ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	jne	LBB3_223
LBB3_222:                               ##   in Loop: Header=BB3_210 Depth=2
	leaq	2(%r8), %rsi
LBB3_223:                               ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	je	LBB3_231
## %bb.224:                             ##   in Loop: Header=BB3_210 Depth=2
	cmpl	$229, %r9d
	je	LBB3_231
## %bb.225:                             ##   in Loop: Header=BB3_210 Depth=2
	movzbl	(%rdi), %r9d
	cmpl	$229, %r9d
	je	LBB3_227
## %bb.226:                             ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	jne	LBB3_228
LBB3_227:                               ##   in Loop: Header=BB3_210 Depth=2
	leaq	3(%r8), %rsi
LBB3_228:                               ##   in Loop: Header=BB3_210 Depth=2
	testl	%r9d, %r9d
	je	LBB3_231
## %bb.229:                             ##   in Loop: Header=BB3_210 Depth=2
	cmpl	$229, %r9d
	je	LBB3_231
## %bb.230:                             ##   in Loop: Header=BB3_210 Depth=2
	addq	$4, %r8
	subq	$-128, %rdi
	cmpq	$512, %r8                       ## imm = 0x200
	jne	LBB3_210
	jmp	LBB3_323
	.p2align	4
LBB3_231:                               ##   in Loop: Header=BB3_209 Depth=1
	cmpl	$512, %esi                      ## imm = 0x200
	jae	LBB3_328
## %bb.232:                             ##   in Loop: Header=BB3_209 Depth=1
	shll	$5, %esi
	movdqu	%xmm0, (%rdx,%rsi)
	movdqu	%xmm0, 16(%rdx,%rsi)
	movl	$1297043268, (%rdx,%rsi)        ## imm = 0x4D4F4F44
	movl	$1447121741, 3(%rdx,%rsi)       ## imm = 0x5641534D
	movb	%cl, 7(%rdx,%rsi)
	movl	$541545284, 8(%rdx,%rsi)        ## imm = 0x20475344
	movl	$0, 26(%rdx,%rsi)
	movw	$0, 30(%rdx,%rsi)
	incl	%eax
	cmpl	$6, %eax
	jne	LBB3_209
## %bb.233:
	movq	(%r15), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  ## imm = 0x140260
	xorl	%esi, %esi
                                        ## implicit-def: $ecx
LBB3_234:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_236
## %bb.235:                             ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	jne	LBB3_237
LBB3_236:                               ##   in Loop: Header=BB3_234 Depth=1
	movl	%esi, %ecx
LBB3_237:                               ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	je	LBB3_256
## %bb.238:                             ##   in Loop: Header=BB3_234 Depth=1
	cmpl	$229, %edi
	je	LBB3_256
## %bb.239:                             ##   in Loop: Header=BB3_234 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_241
## %bb.240:                             ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	jne	LBB3_242
LBB3_241:                               ##   in Loop: Header=BB3_234 Depth=1
	leaq	1(%rsi), %rcx
LBB3_242:                               ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	je	LBB3_256
## %bb.243:                             ##   in Loop: Header=BB3_234 Depth=1
	cmpl	$229, %edi
	je	LBB3_256
## %bb.244:                             ##   in Loop: Header=BB3_234 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_246
## %bb.245:                             ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	jne	LBB3_247
LBB3_246:                               ##   in Loop: Header=BB3_234 Depth=1
	leaq	2(%rsi), %rcx
LBB3_247:                               ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	je	LBB3_256
## %bb.248:                             ##   in Loop: Header=BB3_234 Depth=1
	cmpl	$229, %edi
	je	LBB3_256
## %bb.249:                             ##   in Loop: Header=BB3_234 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_251
## %bb.250:                             ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	jne	LBB3_252
LBB3_251:                               ##   in Loop: Header=BB3_234 Depth=1
	leaq	3(%rsi), %rcx
LBB3_252:                               ##   in Loop: Header=BB3_234 Depth=1
	testl	%edi, %edi
	je	LBB3_256
## %bb.253:                             ##   in Loop: Header=BB3_234 Depth=1
	cmpl	$229, %edi
	je	LBB3_256
## %bb.254:                             ##   in Loop: Header=BB3_234 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      ## imm = 0x200
	jne	LBB3_234
## %bb.255:
	callq	_install_bootable_layout.cold.42
LBB3_256:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB3_347
## %bb.257:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movdqu	%xmm0, 16(%rax,%rcx)
	movabsq	$2329578481653007696, %rdx      ## imm = 0x2054534953524550
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       ## imm = 0x4B484320
	movb	$32, 11(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	movw	$0, 30(%rax,%rcx)
	movq	(%r15), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  ## imm = 0x140260
	xorl	%esi, %esi
                                        ## implicit-def: $ecx
LBB3_258:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_260
## %bb.259:                             ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	jne	LBB3_261
LBB3_260:                               ##   in Loop: Header=BB3_258 Depth=1
	movl	%esi, %ecx
LBB3_261:                               ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	je	LBB3_280
## %bb.262:                             ##   in Loop: Header=BB3_258 Depth=1
	cmpl	$229, %edi
	je	LBB3_280
## %bb.263:                             ##   in Loop: Header=BB3_258 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_265
## %bb.264:                             ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	jne	LBB3_266
LBB3_265:                               ##   in Loop: Header=BB3_258 Depth=1
	leaq	1(%rsi), %rcx
LBB3_266:                               ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	je	LBB3_280
## %bb.267:                             ##   in Loop: Header=BB3_258 Depth=1
	cmpl	$229, %edi
	je	LBB3_280
## %bb.268:                             ##   in Loop: Header=BB3_258 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_270
## %bb.269:                             ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	jne	LBB3_271
LBB3_270:                               ##   in Loop: Header=BB3_258 Depth=1
	leaq	2(%rsi), %rcx
LBB3_271:                               ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	je	LBB3_280
## %bb.272:                             ##   in Loop: Header=BB3_258 Depth=1
	cmpl	$229, %edi
	je	LBB3_280
## %bb.273:                             ##   in Loop: Header=BB3_258 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_275
## %bb.274:                             ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	jne	LBB3_276
LBB3_275:                               ##   in Loop: Header=BB3_258 Depth=1
	leaq	3(%rsi), %rcx
LBB3_276:                               ##   in Loop: Header=BB3_258 Depth=1
	testl	%edi, %edi
	je	LBB3_280
## %bb.277:                             ##   in Loop: Header=BB3_258 Depth=1
	cmpl	$229, %edi
	je	LBB3_280
## %bb.278:                             ##   in Loop: Header=BB3_258 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      ## imm = 0x200
	jne	LBB3_258
## %bb.279:
	callq	_install_bootable_layout.cold.40
LBB3_280:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB3_348
## %bb.281:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movdqu	%xmm0, 16(%rax,%rcx)
	movabsq	$2328718701980172627, %rdx      ## imm = 0x2051455245564153
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       ## imm = 0x4B484320
	movb	$32, 11(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	movw	$0, 30(%rax,%rcx)
	movq	(%r15), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  ## imm = 0x140260
	xorl	%esi, %esi
                                        ## implicit-def: $ecx
LBB3_282:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_284
## %bb.283:                             ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	jne	LBB3_285
LBB3_284:                               ##   in Loop: Header=BB3_282 Depth=1
	movl	%esi, %ecx
LBB3_285:                               ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	je	LBB3_304
## %bb.286:                             ##   in Loop: Header=BB3_282 Depth=1
	cmpl	$229, %edi
	je	LBB3_304
## %bb.287:                             ##   in Loop: Header=BB3_282 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_289
## %bb.288:                             ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	jne	LBB3_290
LBB3_289:                               ##   in Loop: Header=BB3_282 Depth=1
	leaq	1(%rsi), %rcx
LBB3_290:                               ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	je	LBB3_304
## %bb.291:                             ##   in Loop: Header=BB3_282 Depth=1
	cmpl	$229, %edi
	je	LBB3_304
## %bb.292:                             ##   in Loop: Header=BB3_282 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_294
## %bb.293:                             ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	jne	LBB3_295
LBB3_294:                               ##   in Loop: Header=BB3_282 Depth=1
	leaq	2(%rsi), %rcx
LBB3_295:                               ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	je	LBB3_304
## %bb.296:                             ##   in Loop: Header=BB3_282 Depth=1
	cmpl	$229, %edi
	je	LBB3_304
## %bb.297:                             ##   in Loop: Header=BB3_282 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	LBB3_299
## %bb.298:                             ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	jne	LBB3_300
LBB3_299:                               ##   in Loop: Header=BB3_282 Depth=1
	leaq	3(%rsi), %rcx
LBB3_300:                               ##   in Loop: Header=BB3_282 Depth=1
	testl	%edi, %edi
	je	LBB3_304
## %bb.301:                             ##   in Loop: Header=BB3_282 Depth=1
	cmpl	$229, %edi
	je	LBB3_304
## %bb.302:                             ##   in Loop: Header=BB3_282 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      ## imm = 0x200
	jne	LBB3_282
## %bb.303:
	callq	_install_bootable_layout.cold.38
LBB3_304:
	cmpl	$512, %ecx                      ## imm = 0x200
	jae	LBB3_349
## %bb.305:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, (%rax,%rcx)
	movdqu	%xmm0, 16(%rax,%rcx)
	movabsq	$2328718701962022732, %rdx      ## imm = 0x2051455244414F4C
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       ## imm = 0x4B484320
	movb	$32, 11(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	movw	$0, 30(%rax,%rcx)
	leaq	16(%r15), %rax
	movl	$22, %ecx
	movdqa	LCPI3_15(%rip), %xmm1           ## xmm1 = [1,1,1,1]
	pxor	%xmm5, %xmm5
	pxor	%xmm4, %xmm4
	.p2align	4
LBB3_306:                               ## =>This Inner Loop Header: Depth=1
	movq	-24(%r15,%rcx,2), %xmm2         ## xmm2 = mem[0],zero
	movq	-16(%r15,%rcx,2), %xmm3         ## xmm3 = mem[0],zero
	pcmpeqw	%xmm0, %xmm2
	pmovzxwd	%xmm2, %xmm2                    ## xmm2 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero
	pand	%xmm1, %xmm2
	paddd	%xmm5, %xmm2
	pcmpeqw	%xmm0, %xmm3
	pmovzxwd	%xmm3, %xmm3                    ## xmm3 = xmm3[0],zero,xmm3[1],zero,xmm3[2],zero,xmm3[3],zero
	pand	%xmm1, %xmm3
	paddd	%xmm4, %xmm3
	cmpq	$64246, %rcx                    ## imm = 0xFAF6
	je	LBB3_308
## %bb.307:                             ##   in Loop: Header=BB3_306 Depth=1
	movq	-8(%r15,%rcx,2), %xmm4          ## xmm4 = mem[0],zero
	movq	(%r15,%rcx,2), %xmm5            ## xmm5 = mem[0],zero
	pcmpeqw	%xmm0, %xmm4
	pmovzxwd	%xmm4, %xmm4                    ## xmm4 = xmm4[0],zero,xmm4[1],zero,xmm4[2],zero,xmm4[3],zero
	pand	%xmm1, %xmm4
	pcmpeqw	%xmm0, %xmm5
	pmovzxwd	%xmm5, %xmm5                    ## xmm5 = xmm5[0],zero,xmm5[1],zero,xmm5[2],zero,xmm5[3],zero
	pand	%xmm1, %xmm5
	paddd	%xmm4, %xmm2
	paddd	%xmm5, %xmm3
	addq	$16, %rcx
	movdqa	%xmm2, %xmm5
	movdqa	%xmm3, %xmm4
	jmp	LBB3_306
LBB3_308:
	paddd	%xmm2, %xmm3
	pshufd	$238, %xmm3, %xmm0              ## xmm0 = xmm3[2,3,2,3]
	paddd	%xmm3, %xmm0
	pshufd	$85, %xmm0, %xmm1               ## xmm1 = xmm0[1,1,1,1]
	paddd	%xmm0, %xmm1
	movd	%xmm1, %ecx
	cmpw	$1, 128484(%r15)
	adcl	$0, %ecx
	xorl	%edx, %edx
	cmpw	$0, 128486(%r15)
	sete	%dl
	cmpw	$1, 128488(%r15)
	adcl	%ecx, %edx
	xorl	%ecx, %ecx
	cmpw	$0, 128490(%r15)
	sete	%cl
	cmpw	$1, 128492(%r15)
	adcl	%edx, %ecx
	xorl	%edx, %edx
	cmpw	$0, 128494(%r15)
	sete	%dl
	cmpw	$1, 128496(%r15)
	adcl	%ecx, %edx
	cmpl	$4095, %edx                     ## imm = 0xFFF
	jbe	LBB3_350
## %bb.309:
	movl	$-8, 16(%r15)
	movq	(%r15), %rdx
	leaq	1049088(%rdx), %rsi
	leaq	1180160(%rdx), %rdi
	leaq	131088(%r15), %rcx
	cmpq	%rcx, %rsi
	setae	%r8b
	cmpq	%rdi, %rax
	setae	%dil
	orb	%r8b, %dil
	jne	LBB3_312
## %bb.310:
	xorl	%esi, %esi
	.p2align	4
LBB3_311:                               ## =>This Inner Loop Header: Depth=1
	movzwl	16(%r15,%rsi,2), %edi
	movw	%di, 1049088(%rdx,%rsi,2)
	movzwl	18(%r15,%rsi,2), %edi
	movw	%di, 1049090(%rdx,%rsi,2)
	addq	$2, %rsi
	cmpq	$65536, %rsi                    ## imm = 0x10000
	jne	LBB3_311
	jmp	LBB3_314
LBB3_312:
	xorl	%edx, %edx
	.p2align	4
LBB3_313:                               ## =>This Inner Loop Header: Depth=1
	movdqu	16(%r15,%rdx,2), %xmm0
	movdqu	32(%r15,%rdx,2), %xmm1
	movdqu	%xmm0, (%rsi,%rdx,2)
	movdqu	%xmm1, 16(%rsi,%rdx,2)
	addq	$16, %rdx
	cmpq	$65536, %rdx                    ## imm = 0x10000
	jne	LBB3_313
LBB3_314:
	movq	(%r15), %rdx
	leaq	1180160(%rdx), %rsi
	leaq	1311232(%rdx), %rdi
	cmpq	%rcx, %rsi
	setae	%cl
	cmpq	%rdi, %rax
	setae	%al
	orb	%cl, %al
	jne	LBB3_317
## %bb.315:
	xorl	%eax, %eax
	.p2align	4
LBB3_316:                               ## =>This Inner Loop Header: Depth=1
	movzwl	16(%r15,%rax,2), %ecx
	movw	%cx, 1180160(%rdx,%rax,2)
	movzwl	18(%r15,%rax,2), %ecx
	movw	%cx, 1180162(%rdx,%rax,2)
	addq	$2, %rax
	cmpq	$65536, %rax                    ## imm = 0x10000
	jne	LBB3_316
	jmp	LBB3_319
LBB3_317:
	xorl	%eax, %eax
	.p2align	4
LBB3_318:                               ## =>This Inner Loop Header: Depth=1
	movdqu	16(%r15,%rax,2), %xmm0
	movdqu	32(%r15,%rax,2), %xmm1
	movdqu	%xmm0, (%rsi,%rax,2)
	movdqu	%xmm1, 16(%rsi,%rax,2)
	addq	$16, %rax
	cmpq	$65536, %rax                    ## imm = 0x10000
	jne	LBB3_318
LBB3_319:
	movq	-15728(%rbp), %rdi
	callq	_free
	movq	-15712(%rbp), %rdi
	callq	_free
	movq	-15696(%rbp), %rdi
	callq	_free
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB3_351
## %bb.320:
	addq	$15752, %rsp                    ## imm = 0x3D88
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB3_321:
	movq	%r14, %rdi
	callq	_install_bootable_layout.cold.32
LBB3_322:
	movq	%r15, %rdi
	callq	_install_bootable_layout.cold.31
LBB3_323:
	callq	_install_bootable_layout.cold.44
LBB3_324:
	leaq	L_.str.437(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_325:
	callq	_install_bootable_layout.cold.27
LBB3_326:
	leaq	L_.str.436(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_327:
	callq	_install_bootable_layout.cold.28
LBB3_328:
	callq	_install_bootable_layout.cold.43
LBB3_329:
	callq	_install_bootable_layout.cold.29
LBB3_330:
	callq	_install_bootable_layout.cold.22
LBB3_331:
	callq	_install_bootable_layout.cold.21
LBB3_332:
	callq	_install_bootable_layout.cold.24
LBB3_333:
	callq	_install_bootable_layout.cold.23
LBB3_334:
	callq	_install_bootable_layout.cold.26
LBB3_335:
	callq	_install_bootable_layout.cold.25
LBB3_336:
	leaq	L_.str.325(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_337:
	callq	_install_bootable_layout.cold.15
LBB3_338:
	callq	_install_bootable_layout.cold.5
LBB3_339:
	callq	_install_bootable_layout.cold.4
LBB3_340:
	leaq	L_.str.435(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_341:
	leaq	L_.str.431(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_342:
	leaq	L_.str.433(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_343:
	leaq	L_.str.434(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_344:
	callq	_install_bootable_layout.cold.1
LBB3_345:
	callq	_install_bootable_layout.cold.20
LBB3_346:
	callq	_install_bootable_layout.cold.45
LBB3_347:
	callq	_install_bootable_layout.cold.41
LBB3_348:
	callq	_install_bootable_layout.cold.39
LBB3_349:
	callq	_install_bootable_layout.cold.37
LBB3_350:
	callq	_install_bootable_layout.cold.36
LBB3_351:
	callq	___stack_chk_fail
LBB3_352:
	leaq	L_.str.318(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_353:
	leaq	L_.str.319(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_354:
	leaq	L_.str.323(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_355:
	leaq	L_.str.324(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_356:
	leaq	L_.str.312(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_357:
	movq	%rdx, %rdi
	callq	_install_bootable_layout.cold.3
LBB3_358:
	movq	%rdx, %rdi
	callq	_install_bootable_layout.cold.2
LBB3_359:
	callq	_install_bootable_layout.cold.30
LBB3_360:
	leaq	L_.str.322(%rip), %rsi
	movq	%r15, %rdi
	callq	_die_path
LBB3_361:
	callq	_install_bootable_layout.cold.19
LBB3_362:
	callq	_install_bootable_layout.cold.18
LBB3_363:
	callq	_install_bootable_layout.cold.17
LBB3_364:
	callq	_install_bootable_layout.cold.16
LBB3_365:
	callq	_install_bootable_layout.cold.14
LBB3_366:
	callq	_install_bootable_layout.cold.13
LBB3_367:
	callq	_install_bootable_layout.cold.6
LBB3_368:
	callq	_install_bootable_layout.cold.12
LBB3_369:
	callq	_install_bootable_layout.cold.11
LBB3_370:
	callq	_install_bootable_layout.cold.10
LBB3_371:
	callq	_install_bootable_layout.cold.9
LBB3_372:
	callq	_install_bootable_layout.cold.8
LBB3_373:
	callq	_install_bootable_layout.cold.7
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file
_write_file:                            ## @write_file
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	movq	%rdx, %r14
	movq	%rsi, %r12
	movq	%rdi, %rbx
	leaq	L_.str.512(%rip), %rsi
	callq	_fopen
	testq	%rax, %rax
	je	LBB4_4
## %bb.1:
	movq	%rax, %r15
	testq	%r14, %r14
	je	LBB4_3
## %bb.2:
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%r14, %rdx
	movq	%r15, %rcx
	callq	_fwrite
	cmpq	%r14, %rax
	jne	LBB4_5
LBB4_3:
	movq	%r15, %rdi
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	jmp	_fclose                         ## TAILCALL
LBB4_4:
	movq	%rbx, %rdi
	callq	_write_file.cold.1
LBB4_5:
	leaq	L_.str.513(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_file
_read_file:                             ## @read_file
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	movq	%rdi, %rbx
	leaq	L_.str.31(%rip), %rsi
	callq	_fopen
	testq	%rax, %rax
	je	LBB5_8
## %bb.1:
	movq	%rax, %r14
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$2, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB5_9
## %bb.2:
	movq	%r14, %rdi
	callq	_ftell
	testq	%rax, %rax
	js	LBB5_10
## %bb.3:
	movq	%rax, %r15
	movq	%r14, %rdi
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB5_9
## %bb.4:
	leaq	1(%r15), %rdi
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB5_11
## %bb.5:
	movq	%rax, %r12
	testq	%r15, %r15
	je	LBB5_7
## %bb.6:
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%r15, %rdx
	movq	%r14, %rcx
	callq	_fread
	cmpq	%r15, %rax
	jne	LBB5_12
LBB5_7:
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
LBB5_9:
	leaq	L_.str.32(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB5_8:
	movq	%rbx, %rdi
	callq	_read_file.cold.2
LBB5_10:
	leaq	L_.str.33(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB5_11:
	callq	_read_file.cold.1
LBB5_12:
	leaq	L_.str.34(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
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
	leaq	L_.str.35(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path
_write_file_path:                       ## @write_file_path
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movl	%r9d, -44(%rbp)                 ## 4-byte Spill
	movq	%r8, -56(%rbp)                  ## 8-byte Spill
	movq	%rcx, %r8
	movq	%rdx, %r12
	movq	%rsi, %r13
	movq	%rdi, %r14
	cmpq	$1, %rdx
	je	LBB7_7
## %bb.1:
	movq	%r8, -64(%rbp)                  ## 8-byte Spill
	testq	%r12, %r12
	je	LBB7_24
## %bb.2:
	leaq	-1(%r12), %rbx
	xorl	%eax, %eax
	movq	%r13, %r15
	.p2align	4
LBB7_3:                                 ## =>This Inner Loop Header: Depth=1
	movq	%r14, %rdi
	movl	%eax, %esi
	movq	%r15, %rdx
	movl	$17, %ecx
	callq	_ensure_child_directory
                                        ## kill: def $eax killed $eax def $rax
	addq	$11, %r15
	decq	%rbx
	jne	LBB7_3
## %bb.4:
	testl	%eax, %eax
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	je	LBB7_7
## %bb.5:
	leal	-65375(%rax), %ecx
	cmpl	$-65374, %ecx                   ## imm = 0xFFFF00A2
	jbe	LBB7_6
## %bb.8:
	movq	(%r14), %rcx
	shll	$13, %eax
	leaq	(%rcx,%rax), %rbx
	addq	$1311232, %rbx                  ## imm = 0x140200
	movl	$8192, %r15d                    ## imm = 0x2000
	jmp	LBB7_9
LBB7_7:
	movl	$1311232, %ebx                  ## imm = 0x140200
	addq	(%r14), %rbx
	movl	$16384, %r15d                   ## imm = 0x4000
LBB7_9:
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
	jmp	LBB7_10
	.p2align	4
LBB7_13:                                ##   in Loop: Header=BB7_10 Depth=1
	incl	%esi
	movq	%rsi, %r8
	shlq	$5, %r8
	addl	$32, %edi
	cmpq	%rdx, %r8
	ja	LBB7_14
LBB7_10:                                ## =>This Inner Loop Header: Depth=1
	movl	%edi, %edi
	movzbl	(%rbx,%rdi), %r8d
	cmpl	$229, %r8d
	je	LBB7_13
## %bb.11:                              ##   in Loop: Header=BB7_10 Depth=1
	testl	%r8d, %r8d
	je	LBB7_14
## %bb.12:                              ##   in Loop: Header=BB7_10 Depth=1
	movq	(%rbx,%rdi), %r8
	xorq	(%rcx), %r8
	movq	3(%rbx,%rdi), %r9
	xorq	3(%rcx), %r9
	orq	%r8, %r9
	jne	LBB7_13
LBB7_22:
	movl	%esi, %edx
	shlq	$5, %rdx
	cmpq	%r15, %rdx
	jae	LBB7_23
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
LBB7_14:
	xorl	%edi, %edi
                                        ## implicit-def: $r9d
	xorl	%r8d, %r8d
	.p2align	4
LBB7_15:                                ## =>This Inner Loop Header: Depth=1
	movl	%edi, %esi
	movzbl	(%rbx,%rsi), %r10d
	movl	%r8d, %esi
	testl	%r10d, %r10d
	je	LBB7_18
## %bb.16:                              ##   in Loop: Header=BB7_15 Depth=1
	movl	%r8d, %esi
	cmpl	$229, %r10d
	je	LBB7_18
## %bb.17:                              ##   in Loop: Header=BB7_15 Depth=1
	movl	%r9d, %esi
LBB7_18:                                ##   in Loop: Header=BB7_15 Depth=1
	testl	%r10d, %r10d
	je	LBB7_22
## %bb.19:                              ##   in Loop: Header=BB7_15 Depth=1
	cmpl	$229, %r10d
	je	LBB7_22
## %bb.20:                              ##   in Loop: Header=BB7_15 Depth=1
	incl	%r8d
	movq	%r8, %r10
	shlq	$5, %r10
	addl	$32, %edi
	movl	%esi, %r9d
	cmpq	%rdx, %r10
	jbe	LBB7_15
## %bb.21:
	callq	_write_file_path.cold.3
LBB7_23:
	callq	_write_file_path.cold.4
LBB7_24:
	callq	_write_file_path.cold.1
LBB7_6:
	callq	_write_file_path.cold.2
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory
_ensure_child_directory:                ## @ensure_child_directory
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movq	%rdx, %r15
	movl	%esi, %ebx
	testl	%esi, %esi
	je	LBB8_3
## %bb.1:
	leal	-65375(%rbx), %eax
	cmpl	$-65374, %eax                   ## imm = 0xFFFF00A2
	jbe	LBB8_2
## %bb.4:
	movq	(%rdi), %rax
	movl	%ebx, %edx
	shll	$13, %edx
	leaq	(%rax,%rdx), %r13
	addq	$1311232, %r13                  ## imm = 0x140200
	movl	$8192, %r9d                     ## imm = 0x2000
	jmp	LBB8_5
LBB8_3:
	movl	$1311232, %r13d                 ## imm = 0x140200
	addq	(%rdi), %r13
	movl	$16384, %r9d                    ## imm = 0x4000
LBB8_5:
	leaq	-32(%r9), %r12
	xorl	%eax, %eax
	xorl	%r8d, %r8d
	jmp	LBB8_6
	.p2align	4
LBB8_9:                                 ##   in Loop: Header=BB8_6 Depth=1
	incl	%r8d
	movq	%r8, %rdx
	shlq	$5, %rdx
	addl	$32, %eax
	cmpq	%r12, %rdx
	ja	LBB8_10
LBB8_6:                                 ## =>This Inner Loop Header: Depth=1
	movl	%eax, %eax
	movzbl	(%r13,%rax), %edx
	cmpl	$229, %edx
	je	LBB8_9
## %bb.7:                               ##   in Loop: Header=BB8_6 Depth=1
	testl	%edx, %edx
	je	LBB8_10
## %bb.8:                               ##   in Loop: Header=BB8_6 Depth=1
	movq	(%r13,%rax), %rdx
	xorq	(%r15), %rdx
	movq	3(%r13,%rax), %rsi
	xorq	3(%r15), %rsi
	orq	%rdx, %rsi
	jne	LBB8_9
## %bb.18:
	movl	%r8d, %eax
	shlq	$5, %rax
	movzbl	11(%r13,%rax), %edx
	testb	$16, %dl
	je	LBB8_27
## %bb.19:
	testb	$1, %cl
	je	LBB8_21
## %bb.20:
	orb	$1, %dl
	movb	%dl, 11(%r13,%rax)
LBB8_21:
	movq	%rax, %rcx
	orq	$28, %rcx
	cmpq	%r9, %rcx
	ja	LBB8_28
## %bb.22:
	movzwl	26(%r13,%rax), %eax
	jmp	LBB8_26
LBB8_10:
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
LBB8_11:                                ## =>This Inner Loop Header: Depth=1
	movl	%r14d, %edx
	movzbl	(%r13,%rdx), %edi
	movl	%ecx, %edx
	testl	%edi, %edi
	je	LBB8_14
## %bb.12:                              ##   in Loop: Header=BB8_11 Depth=1
	movl	%ecx, %edx
	cmpl	$229, %edi
	je	LBB8_14
## %bb.13:                              ##   in Loop: Header=BB8_11 Depth=1
	movl	%esi, %edx
LBB8_14:                                ##   in Loop: Header=BB8_11 Depth=1
	testl	%edi, %edi
	je	LBB8_23
## %bb.15:                              ##   in Loop: Header=BB8_11 Depth=1
	cmpl	$229, %edi
	je	LBB8_23
## %bb.16:                              ##   in Loop: Header=BB8_11 Depth=1
	incl	%ecx
	movq	%rcx, %rdi
	shlq	$5, %rdi
	addl	$32, %r14d
	movl	%edx, %esi
	cmpq	%r12, %rdi
	jbe	LBB8_11
## %bb.17:
	callq	_ensure_child_directory.cold.4
LBB8_23:
	movl	%edx, %ecx
	shlq	$5, %rcx
	cmpq	-64(%rbp), %rcx                 ## 8-byte Folded Reload
	jae	LBB8_29
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
	leal	-65375(%rax), %esi
	movl	$0, 28(%r13,%rcx)
	cmpl	$-65374, %esi                   ## imm = 0xFFFF00A2
	jbe	LBB8_30
## %bb.25:
	movq	-56(%rbp), %rcx                 ## 8-byte Reload
	movq	(%rcx), %rcx
	movl	%eax, %esi
	shlq	$13, %rsi
	movups	%xmm0, 1311232(%rcx,%rsi)
	movups	%xmm0, 1311248(%rcx,%rsi)
	movabsq	$2314885530818453550, %rdi      ## imm = 0x202020202020202E
	movq	%rdi, 1311232(%rcx,%rsi)
	movl	$538976288, 1311239(%rcx,%rsi)  ## imm = 0x20202020
	movb	%r8b, 1311243(%rcx,%rsi)
	movb	%al, 1311258(%rcx,%rsi)
	movb	%dl, 1311259(%rcx,%rsi)
	movl	$0, 1311260(%rcx,%rsi)
	movups	%xmm0, 1311264(%rcx,%rsi)
	movups	%xmm0, 1325616(%rcx,%rsi)
	movabsq	$2314885530818457134, %rdx      ## imm = 0x2020202020202E2E
	movq	%rdx, 1325600(%rcx,%rsi)
	movl	$538976288, 1325607(%rcx,%rsi)  ## imm = 0x20202020
	movb	$16, 1325611(%rcx,%rsi)
	movb	%bl, 1325626(%rcx,%rsi)
	movb	%bh, 1325627(%rcx,%rsi)
	movl	$0, 1325628(%rcx,%rsi)
LBB8_26:
                                        ## kill: def $eax killed $eax killed $rax
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB8_29:
	callq	_ensure_child_directory.cold.2
LBB8_30:
	callq	_ensure_child_directory.cold.3
LBB8_2:
	callq	_ensure_child_directory.cold.1
LBB8_27:
	callq	_ensure_child_directory.cold.6
LBB8_28:
	callq	_ensure_child_directory.cold.5
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain
_write_cluster_chain:                   ## @write_cluster_chain
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movq	%rcx, %r14
	movq	%rsi, -80(%rbp)                 ## 8-byte Spill
	movq	%rdi, %r12
	movq	%rdx, -56(%rbp)                 ## 8-byte Spill
	leaq	8191(%rdx), %r15
	shrq	$13, %r15
	cmpl	$2, %r15d
	movl	$1, %edi
	cmovael	%r15d, %edi
	movl	$4, %esi
	movq	%rdi, -64(%rbp)                 ## 8-byte Spill
	callq	_calloc
	testq	%rax, %rax
	je	LBB9_25
## %bb.1:
	movq	%rax, %rbx
	leaq	20(%r12), %rcx
	xorl	%eax, %eax
	movl	$2, %edx
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	.p2align	4
LBB9_2:                                 ## =>This Inner Loop Header: Depth=1
	cmpw	$0, (%rcx)
	jne	LBB9_4
## %bb.3:                               ##   in Loop: Header=BB9_2 Depth=1
	movl	%eax, %esi
	incl	%eax
	movl	%edx, (%rbx,%rsi,4)
LBB9_4:                                 ##   in Loop: Header=BB9_2 Depth=1
	cmpq	$65373, %rdx                    ## imm = 0xFF5D
	ja	LBB9_5
## %bb.9:                               ##   in Loop: Header=BB9_2 Depth=1
	incq	%rdx
	addq	$2, %rcx
	cmpl	%r8d, %eax
	jb	LBB9_2
LBB9_5:
	cmpl	%r8d, %eax
	jne	LBB9_10
## %bb.6:
	movq	%r14, -72(%rbp)                 ## 8-byte Spill
	movl	(%rbx), %r9d
	movl	%r9d, %esi
	cmpl	$2, %r15d
	jb	LBB9_17
## %bb.7:
	leaq	-1(%r8), %rsi
	movl	%esi, %eax
	andl	$3, %eax
	leal	-2(%r8), %ecx
	cmpl	$3, %ecx
	jae	LBB9_11
## %bb.8:
	movl	$1, %edx
	movl	%r9d, %ecx
	jmp	LBB9_14
LBB9_11:
	andq	$-4, %rsi
	xorl	%edx, %edx
	movl	%r9d, %ecx
	.p2align	4
LBB9_12:                                ## =>This Inner Loop Header: Depth=1
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
	jne	LBB9_12
## %bb.13:
	incq	%rdx
LBB9_14:
	movl	%ecx, %esi
	testq	%rax, %rax
	je	LBB9_17
## %bb.15:
	leaq	(%rbx,%rdx,4), %rdx
	xorl	%edi, %edi
	.p2align	4
LBB9_16:                                ## =>This Inner Loop Header: Depth=1
	movl	(%rdx,%rdi,4), %esi
	movl	%ecx, %ecx
	movw	%si, 16(%r12,%rcx,2)
	incq	%rdi
	movl	%esi, %ecx
	cmpq	%rdi, %rax
	jne	LBB9_16
LBB9_17:
	movl	%r9d, -44(%rbp)                 ## 4-byte Spill
	movl	%esi, %eax
	movw	$-1, 16(%r12,%rax,2)
	xorl	%r14d, %r14d
	movq	-56(%rbp), %r15                 ## 8-byte Reload
	jmp	LBB9_18
	.p2align	4
LBB9_22:                                ##   in Loop: Header=BB9_18 Depth=1
	shlq	$13, %rax
	movq	(%r12), %rcx
	leaq	(%rcx,%rax), %rdi
	addq	$1311232, %rdi                  ## imm = 0x140200
	movq	-56(%rbp), %rsi                 ## 8-byte Reload
	subq	%r15, %rsi
	addq	-80(%rbp), %rsi                 ## 8-byte Folded Reload
	movq	%r13, %rdx
	callq	_memcpy
	movq	-64(%rbp), %r8                  ## 8-byte Reload
LBB9_23:                                ##   in Loop: Header=BB9_18 Depth=1
	subq	%r13, %r15
	incq	%r14
	cmpq	%r14, %r8
	je	LBB9_24
LBB9_18:                                ## =>This Inner Loop Header: Depth=1
	movl	(%rbx,%r14,4), %eax
	leal	-65375(%rax), %ecx
	cmpl	$-65374, %ecx                   ## imm = 0xFFFF00A2
	jbe	LBB9_26
## %bb.19:                              ##   in Loop: Header=BB9_18 Depth=1
	movl	$8192, %r13d                    ## imm = 0x2000
	cmpq	$8191, %r15                     ## imm = 0x1FFF
	ja	LBB9_22
## %bb.20:                              ##   in Loop: Header=BB9_18 Depth=1
	movq	%r15, %r13
	testq	%r15, %r15
	jne	LBB9_22
## %bb.21:                              ##   in Loop: Header=BB9_18 Depth=1
	xorl	%r13d, %r13d
	jmp	LBB9_23
LBB9_24:
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
LBB9_26:
	callq	_write_cluster_chain.cold.2
LBB9_25:
	callq	_write_cluster_chain.cold.3
LBB9_10:
	callq	_write_cluster_chain.cold.1
                                        ## -- End function
	.p2align	4                               ## -- Begin function validate_image_layout
_validate_image_layout:                 ## @validate_image_layout
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	cmpq	$536870912, 8(%rdi)             ## imm = 0x20000000
	jne	LBB10_1
## %bb.3:
	movq	(%rdi), %rax
	cmpw	$-21931, 510(%rax)              ## imm = 0xAA55
	jne	LBB10_4
## %bb.5:
	cmpl	$2048, 454(%rax)                ## imm = 0x800
	jne	LBB10_7
## %bb.6:
	cmpl	$1046528, 458(%rax)             ## imm = 0xFF800
	jne	LBB10_7
## %bb.8:
	cmpw	$-21931, 1049086(%rax)          ## imm = 0xAA55
	jne	LBB10_9
## %bb.10:
	cmpw	$512, 1048587(%rax)             ## imm = 0x200
	jne	LBB10_11
## %bb.12:
	cmpb	$16, 1048589(%rax)
	jne	LBB10_13
## %bb.14:
	popq	%rbp
	retq
LBB10_1:
	leaq	L_.str.61(%rip), %rax
	jmp	LBB10_2
LBB10_4:
	leaq	L_.str.62(%rip), %rax
	jmp	LBB10_2
LBB10_7:
	leaq	L_.str.63(%rip), %rax
	jmp	LBB10_2
LBB10_9:
	leaq	L_.str.64(%rip), %rax
	jmp	LBB10_2
LBB10_11:
	leaq	L_.str.65(%rip), %rax
	jmp	LBB10_2
LBB10_13:
	leaq	L_.str.66(%rip), %rax
LBB10_2:
	movq	%rsi, %rdi
	movq	%rax, %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status
_check_write_status:                    ## @check_write_status
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	subq	$16, %rsp
	testq	%rdi, %rdi
	je	LBB11_101
## %bb.1:
	movl	%esi, %r12d
	movq	%rdi, %rbx
	callq	_read_file
	movq	%rax, -48(%rbp)
	movq	%rdx, -40(%rbp)
	testq	%rax, %rax
	je	LBB11_101
## %bb.2:
	movq	%rax, %r14
	movq	%rdx, %r15
	testl	%r12d, %r12d
	je	LBB11_53
## %bb.3:
	cmpq	$7, %r15
	jb	LBB11_13
## %bb.4:
	movl	$1702257011, %eax               ## imm = 0x65766173
	xorl	(%r14), %eax
	movzwl	4(%r14), %ecx
	xorl	$29303, %ecx                    ## imm = 0x7277
	orl	%eax, %ecx
	movabsq	$4294976512, %r12               ## imm = 0x100002400
	jne	LBB11_6
## %bb.5:
	cmpb	$61, 6(%r14)
	movq	%r14, %rax
	je	LBB11_15
LBB11_6:
	leaq	-6(%r15), %rax
	cmpq	$1, %rax
	je	LBB11_13
## %bb.7:
	leaq	-7(%r15), %rcx
	xorl	%eax, %eax
	movl	$1702257011, %edx               ## imm = 0x65766173
	jmp	LBB11_8
	.p2align	4
LBB11_12:                               ##   in Loop: Header=BB11_8 Depth=1
	incq	%rax
	cmpq	%rax, %rcx
	je	LBB11_13
LBB11_8:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %esi
	cmpq	$32, %rsi
	ja	LBB11_12
## %bb.9:                               ##   in Loop: Header=BB11_8 Depth=1
	btq	%rsi, %r12
	jae	LBB11_12
## %bb.10:                              ##   in Loop: Header=BB11_8 Depth=1
	movl	1(%r14,%rax), %esi
	xorl	%edx, %esi
	movzwl	5(%r14,%rax), %edi
	xorl	$29303, %edi                    ## imm = 0x7277
	orl	%esi, %edi
	jne	LBB11_12
## %bb.11:                              ##   in Loop: Header=BB11_8 Depth=1
	cmpb	$61, 7(%r14,%rax)
	jne	LBB11_12
## %bb.14:
	addq	%r14, %rax
	incq	%rax
LBB11_15:
	movzbl	7(%rax), %edi
	testb	%dil, %dil
	je	LBB11_102
## %bb.16:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB11_17:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB11_19
## %bb.18:                              ##   in Loop: Header=BB11_17 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB11_24
	jmp	LBB11_25
	.p2align	4
LBB11_19:                               ##   in Loop: Header=BB11_17 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB11_21
## %bb.20:                              ##   in Loop: Header=BB11_17 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB11_24
	jmp	LBB11_25
	.p2align	4
LBB11_21:                               ##   in Loop: Header=BB11_17 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB11_25
## %bb.22:                              ##   in Loop: Header=BB11_17 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB11_25
LBB11_24:                               ##   in Loop: Header=BB11_17 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	8(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB11_17
	jmp	LBB11_26
LBB11_101:
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB11_53:
	cmpq	$10, %r15
	jb	LBB11_63
## %bb.54:
	movabsq	$8388361638216953700, %rdx      ## imm = 0x746972776D6F6F64
	leaq	-9(%r15), %rax
	movq	(%r14), %rcx
	xorq	%rdx, %rcx
	movzbl	8(%r14), %esi
	xorq	$101, %rsi
	orq	%rcx, %rsi
	jne	LBB11_56
## %bb.55:
	cmpb	$61, 9(%r14)
	movq	%r14, %rcx
	je	LBB11_65
LBB11_56:
	cmpq	$1, %rax
	je	LBB11_63
## %bb.57:
	leaq	-10(%r15), %rsi
	xorl	%ecx, %ecx
	movabsq	$4294976512, %rdi               ## imm = 0x100002400
	jmp	LBB11_58
	.p2align	4
LBB11_62:                               ##   in Loop: Header=BB11_58 Depth=1
	incq	%rcx
	cmpq	%rcx, %rsi
	je	LBB11_63
LBB11_58:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rcx), %r8d
	cmpq	$32, %r8
	ja	LBB11_62
## %bb.59:                              ##   in Loop: Header=BB11_58 Depth=1
	btq	%r8, %rdi
	jae	LBB11_62
## %bb.60:                              ##   in Loop: Header=BB11_58 Depth=1
	movq	1(%r14,%rcx), %r8
	xorq	%rdx, %r8
	movzbl	9(%r14,%rcx), %r9d
	xorq	$101, %r9
	orq	%r8, %r9
	jne	LBB11_62
## %bb.61:                              ##   in Loop: Header=BB11_58 Depth=1
	cmpb	$61, 10(%r14,%rcx)
	jne	LBB11_62
## %bb.64:
	addq	%r14, %rcx
	incq	%rcx
LBB11_65:
	movzbl	10(%rcx), %r8d
	testb	%r8b, %r8b
	je	LBB11_105
## %bb.66:
	xorl	%esi, %esi
	xorl	%edx, %edx
	.p2align	4
LBB11_67:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%r8b, %edi
	leal	-48(%rdi), %r9d
	cmpb	$9, %r9b
	ja	LBB11_69
## %bb.68:                              ##   in Loop: Header=BB11_67 Depth=1
	addl	$-48, %edi
	testl	%edi, %edi
	jns	LBB11_74
	jmp	LBB11_75
	.p2align	4
LBB11_69:                               ##   in Loop: Header=BB11_67 Depth=1
	leal	-97(%r8), %r9d
	cmpb	$5, %r9b
	ja	LBB11_71
## %bb.70:                              ##   in Loop: Header=BB11_67 Depth=1
	addl	$-87, %edi
	testl	%edi, %edi
	jns	LBB11_74
	jmp	LBB11_75
	.p2align	4
LBB11_71:                               ##   in Loop: Header=BB11_67 Depth=1
	addb	$-65, %r8b
	cmpb	$5, %r8b
	ja	LBB11_75
## %bb.72:                              ##   in Loop: Header=BB11_67 Depth=1
	addl	$-55, %edi
	testl	%edi, %edi
	js	LBB11_75
LBB11_74:                               ##   in Loop: Header=BB11_67 Depth=1
	shll	$4, %edx
	orl	%edi, %edx
	movzbl	11(%rcx,%rsi), %r8d
	incq	%rsi
	testb	%r8b, %r8b
	jne	LBB11_67
	jmp	LBB11_76
LBB11_25:
	testl	%edx, %edx
	je	LBB11_102
LBB11_26:
	testl	%ecx, %ecx
	je	LBB11_103
## %bb.27:
	leaq	L_.str.88(%rip), %rsi
	leaq	-48(%rbp), %rdi
	movl	$1, %edx
	callq	_status_hex_tuple_part
	testl	%eax, %eax
	je	LBB11_103
## %bb.28:
	cmpq	$10, %r15
	jb	LBB11_38
## %bb.29:
	movabsq	$8317986210936414579, %rcx      ## imm = 0x736F6C6365766173
	movq	(%r14), %rax
	xorq	%rcx, %rax
	movzbl	8(%r14), %edx
	xorq	$101, %rdx
	orq	%rax, %rdx
	jne	LBB11_31
## %bb.30:
	cmpb	$61, 9(%r14)
	movq	%r14, %rax
	je	LBB11_40
LBB11_31:
	leaq	-9(%r15), %rax
	cmpq	$1, %rax
	je	LBB11_38
## %bb.32:
	addq	$-10, %r15
	xorl	%eax, %eax
	jmp	LBB11_33
	.p2align	4
LBB11_37:                               ##   in Loop: Header=BB11_33 Depth=1
	incq	%rax
	cmpq	%rax, %r15
	je	LBB11_38
LBB11_33:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %edx
	cmpq	$32, %rdx
	ja	LBB11_37
## %bb.34:                              ##   in Loop: Header=BB11_33 Depth=1
	btq	%rdx, %r12
	jae	LBB11_37
## %bb.35:                              ##   in Loop: Header=BB11_33 Depth=1
	movq	1(%r14,%rax), %rdx
	xorq	%rcx, %rdx
	movzbl	9(%r14,%rax), %esi
	xorq	$101, %rsi
	orq	%rdx, %rsi
	jne	LBB11_37
## %bb.36:                              ##   in Loop: Header=BB11_33 Depth=1
	cmpb	$61, 10(%r14,%rax)
	jne	LBB11_37
## %bb.39:
	addq	%r14, %rax
	incq	%rax
LBB11_40:
	movzbl	10(%rax), %edi
	testb	%dil, %dil
	je	LBB11_104
## %bb.41:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB11_42:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB11_44
## %bb.43:                              ##   in Loop: Header=BB11_42 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB11_49
	jmp	LBB11_50
	.p2align	4
LBB11_44:                               ##   in Loop: Header=BB11_42 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB11_46
## %bb.45:                              ##   in Loop: Header=BB11_42 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB11_49
	jmp	LBB11_50
	.p2align	4
LBB11_46:                               ##   in Loop: Header=BB11_42 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB11_50
## %bb.47:                              ##   in Loop: Header=BB11_42 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB11_50
LBB11_49:                               ##   in Loop: Header=BB11_42 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	11(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB11_42
	jmp	LBB11_51
LBB11_50:
	testl	%edx, %edx
	je	LBB11_104
LBB11_51:
	testl	%ecx, %ecx
	jne	LBB11_100
## %bb.52:
	leaq	L_.str.91(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB11_75:
	testl	%esi, %esi
	je	LBB11_105
LBB11_76:
	testl	%edx, %edx
	je	LBB11_106
## %bb.77:
	movabsq	$8317986210936414579, %rdx      ## imm = 0x736F6C6365766173
	addq	$133762545, %rdx                ## imm = 0x7F90DF1
	movq	(%r14), %rcx
	xorq	%rdx, %rcx
	movzbl	8(%r14), %esi
	xorq	$101, %rsi
	orq	%rcx, %rsi
	jne	LBB11_79
## %bb.78:
	cmpb	$61, 9(%r14)
	movq	%r14, %rcx
	je	LBB11_88
LBB11_79:
	cmpq	$1, %rax
	je	LBB11_86
## %bb.80:
	addq	$-10, %r15
	xorl	%eax, %eax
	movabsq	$4294976512, %rcx               ## imm = 0x100002400
	jmp	LBB11_81
	.p2align	4
LBB11_85:                               ##   in Loop: Header=BB11_81 Depth=1
	incq	%rax
	cmpq	%rax, %r15
	je	LBB11_86
LBB11_81:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %esi
	cmpq	$32, %rsi
	ja	LBB11_85
## %bb.82:                              ##   in Loop: Header=BB11_81 Depth=1
	btq	%rsi, %rcx
	jae	LBB11_85
## %bb.83:                              ##   in Loop: Header=BB11_81 Depth=1
	movq	1(%r14,%rax), %rsi
	xorq	%rdx, %rsi
	movzbl	9(%r14,%rax), %edi
	xorq	$101, %rdi
	orq	%rsi, %rdi
	jne	LBB11_85
## %bb.84:                              ##   in Loop: Header=BB11_81 Depth=1
	cmpb	$61, 10(%r14,%rax)
	jne	LBB11_85
## %bb.87:
	leaq	(%r14,%rax), %rcx
	incq	%rcx
LBB11_88:
	movzbl	10(%rcx), %edi
	testb	%dil, %dil
	je	LBB11_107
## %bb.89:
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align	4
LBB11_90:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB11_92
## %bb.91:                              ##   in Loop: Header=BB11_90 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB11_97
	jmp	LBB11_98
	.p2align	4
LBB11_92:                               ##   in Loop: Header=BB11_90 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB11_94
## %bb.93:                              ##   in Loop: Header=BB11_90 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB11_97
	jmp	LBB11_98
	.p2align	4
LBB11_94:                               ##   in Loop: Header=BB11_90 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB11_98
## %bb.95:                              ##   in Loop: Header=BB11_90 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB11_98
LBB11_97:                               ##   in Loop: Header=BB11_90 Depth=1
	shll	$4, %eax
	orl	%esi, %eax
	movzbl	11(%rcx,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB11_90
	jmp	LBB11_99
LBB11_98:
	testl	%edx, %edx
	je	LBB11_107
LBB11_99:
	testl	%eax, %eax
	je	LBB11_108
LBB11_100:
	movq	%r14, %rdi
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	jmp	_free                           ## TAILCALL
LBB11_13:
	callq	_check_write_status.cold.1
LBB11_38:
	callq	_check_write_status.cold.2
LBB11_63:
	callq	_check_write_status.cold.5
LBB11_86:
	callq	_check_write_status.cold.6
LBB11_103:
	leaq	L_.str.89(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB11_102:
	callq	_check_write_status.cold.4
LBB11_104:
	callq	_check_write_status.cold.3
LBB11_105:
	callq	_check_write_status.cold.8
LBB11_107:
	callq	_check_write_status.cold.7
LBB11_106:
	leaq	L_.str.93(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB11_108:
	leaq	L_.str.95(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_dynamic_fat_status
_check_dynamic_fat_status:              ## @check_dynamic_fat_status
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	xorl	%r14d, %r14d
	testq	%rdi, %rdi
	je	LBB12_42
## %bb.1:
	movq	%rdi, %rbx
	callq	_read_file
	movq	%rax, -72(%rbp)
	movq	%rdx, -64(%rbp)
	testq	%rax, %rax
	je	LBB12_42
## %bb.2:
	xorl	%r14d, %r14d
	cmpq	$7, %rdx
	jb	LBB12_41
## %bb.3:
	movl	$1685348710, %ecx               ## imm = 0x64746166
	xorl	(%rax), %ecx
	leaq	-6(%rdx), %rsi
	movzwl	4(%rax), %edi
	xorl	$28281, %edi                    ## imm = 0x6E79
	orl	%ecx, %edi
	jne	LBB12_5
## %bb.4:
	cmpb	$61, 6(%rax)
	je	LBB12_13
LBB12_5:
	cmpq	$1, %rsi
	je	LBB12_41
## %bb.6:
	leaq	-7(%rdx), %rcx
	xorl	%edi, %edi
	movabsq	$4294976512, %r8                ## imm = 0x100002400
	movl	$1685348710, %r9d               ## imm = 0x64746166
	jmp	LBB12_7
	.p2align	4
LBB12_11:                               ##   in Loop: Header=BB12_7 Depth=1
	incq	%rdi
	cmpq	%rdi, %rcx
	je	LBB12_12
LBB12_7:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%rax,%rdi), %r10d
	cmpq	$32, %r10
	ja	LBB12_11
## %bb.8:                               ##   in Loop: Header=BB12_7 Depth=1
	btq	%r10, %r8
	jae	LBB12_11
## %bb.9:                               ##   in Loop: Header=BB12_7 Depth=1
	movl	1(%rax,%rdi), %r10d
	xorl	%r9d, %r10d
	movzwl	5(%rax,%rdi), %r11d
	xorl	$28281, %r11d                   ## imm = 0x6E79
	orl	%r10d, %r11d
	jne	LBB12_11
## %bb.10:                              ##   in Loop: Header=BB12_7 Depth=1
	cmpb	$61, 7(%rax,%rdi)
	jne	LBB12_11
LBB12_13:
	movl	$1685348710, %ecx               ## imm = 0x64746166
	xorl	(%rax), %ecx
	movzwl	4(%rax), %edi
	xorl	$28281, %edi                    ## imm = 0x6E79
	orl	%ecx, %edi
	jne	LBB12_15
## %bb.14:
	cmpb	$61, 6(%rax)
	movq	%rax, %rcx
	je	LBB12_24
LBB12_15:
	cmpq	$1, %rsi
	je	LBB12_22
## %bb.16:
	addq	$-7, %rdx
	xorl	%ecx, %ecx
	movabsq	$4294976512, %rsi               ## imm = 0x100002400
	movl	$1685348710, %edi               ## imm = 0x64746166
	jmp	LBB12_17
	.p2align	4
LBB12_21:                               ##   in Loop: Header=BB12_17 Depth=1
	incq	%rcx
	cmpq	%rcx, %rdx
	je	LBB12_22
LBB12_17:                               ## =>This Inner Loop Header: Depth=1
	movzbl	(%rax,%rcx), %r8d
	cmpq	$32, %r8
	ja	LBB12_21
## %bb.18:                              ##   in Loop: Header=BB12_17 Depth=1
	btq	%r8, %rsi
	jae	LBB12_21
## %bb.19:                              ##   in Loop: Header=BB12_17 Depth=1
	movl	1(%rax,%rcx), %r8d
	xorl	%edi, %r8d
	movzwl	5(%rax,%rcx), %r9d
	xorl	$28281, %r9d                    ## imm = 0x6E79
	orl	%r8d, %r9d
	jne	LBB12_21
## %bb.20:                              ##   in Loop: Header=BB12_17 Depth=1
	cmpb	$61, 7(%rax,%rcx)
	jne	LBB12_21
## %bb.23:
	addq	%rax, %rcx
	incq	%rcx
LBB12_24:
	movzbl	7(%rcx), %edi
	testb	%dil, %dil
	je	LBB12_43
## %bb.25:
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	.p2align	4
LBB12_26:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB12_28
## %bb.27:                              ##   in Loop: Header=BB12_26 Depth=1
	addl	$-48, %esi
	jmp	LBB12_32
	.p2align	4
LBB12_28:                               ##   in Loop: Header=BB12_26 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB12_30
## %bb.29:                              ##   in Loop: Header=BB12_26 Depth=1
	addl	$-87, %esi
	jmp	LBB12_32
LBB12_30:                               ##   in Loop: Header=BB12_26 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB12_34
## %bb.31:                              ##   in Loop: Header=BB12_26 Depth=1
	addl	$-55, %esi
LBB12_32:                               ##   in Loop: Header=BB12_26 Depth=1
	testl	%esi, %esi
	js	LBB12_34
## %bb.33:                              ##   in Loop: Header=BB12_26 Depth=1
	shll	$4, %r13d
	orl	%esi, %r13d
	movzbl	8(%rcx,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB12_26
	jmp	LBB12_35
LBB12_12:
	xorl	%r14d, %r14d
	jmp	LBB12_41
LBB12_34:
	testl	%edx, %edx
	je	LBB12_43
LBB12_35:
	movq	%rax, -56(%rbp)                 ## 8-byte Spill
	leaq	L_.str.109(%rip), %r14
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
	jne	LBB12_36
## %bb.37:
	movl	%eax, %ecx
	cmpl	$0, -48(%rbp)                   ## 4-byte Folded Reload
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	jne	LBB12_41
## %bb.38:
	cmpl	$0, -44(%rbp)                   ## 4-byte Folded Reload
	jne	LBB12_41
## %bb.39:
	testl	%r15d, %r15d
	jne	LBB12_41
## %bb.40:
	testl	%ecx, %ecx
	je	LBB12_44
LBB12_41:
	movq	%rax, %rdi
	callq	_free
LBB12_42:
	movl	%r14d, %eax
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB12_36:
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	jmp	LBB12_41
LBB12_22:
	callq	_check_dynamic_fat_status.cold.1
LBB12_43:
	callq	_check_dynamic_fat_status.cold.2
LBB12_44:
	leaq	L_.str.110(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function root_file_equal
_root_file_equal:                       ## @root_file_equal
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	subq	$40, %rsp
	movq	(%rdi), %rax
	xorl	%r9d, %r9d
	jmp	LBB13_1
	.p2align	4
LBB13_6:                                ##   in Loop: Header=BB13_1 Depth=1
	addq	$32, %r9
	cmpq	$16384, %r9                     ## imm = 0x4000
	je	LBB13_7
LBB13_1:                                ## =>This Inner Loop Header: Depth=1
	movzbl	1311232(%rax,%r9), %ecx
	cmpl	$229, %ecx
	je	LBB13_6
## %bb.2:                               ##   in Loop: Header=BB13_1 Depth=1
	testl	%ecx, %ecx
	je	LBB13_3
## %bb.4:                               ##   in Loop: Header=BB13_1 Depth=1
	movq	1311232(%rax,%r9), %rcx
	xorq	(%rdx), %rcx
	movq	1311235(%rax,%r9), %r8
	xorq	3(%rdx), %r8
	orq	%rcx, %r8
	jne	LBB13_6
## %bb.5:
	movzbl	1311243(%rax,%r9), %r8d
	movzwl	1311258(%rax,%r9), %r10d
	movl	1311260(%rax,%r9), %ecx
	shlq	$32, %rcx
	orq	%r10, %rcx
	shlq	$32, %r8
	movl	$1, %eax
	movb	$1, %r9b
	jmp	LBB13_8
LBB13_7:
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	jmp	LBB13_8
LBB13_3:
	xorl	%r9d, %r9d
	movq	%rcx, %r8
	movq	%rcx, %rax
LBB13_8:
	orq	%r8, %rax
	movq	%rax, -56(%rbp)
	movq	%rcx, -48(%rbp)
	movq	(%rsi), %r10
	xorl	%r11d, %r11d
	jmp	LBB13_9
	.p2align	4
LBB13_12:                               ##   in Loop: Header=BB13_9 Depth=1
	addq	$32, %r11
	cmpq	$16384, %r11                    ## imm = 0x4000
	je	LBB13_13
LBB13_9:                                ## =>This Inner Loop Header: Depth=1
	movzbl	1311232(%r10,%r11), %eax
	cmpl	$229, %eax
	je	LBB13_12
## %bb.10:                              ##   in Loop: Header=BB13_9 Depth=1
	testl	%eax, %eax
	je	LBB13_19
## %bb.11:                              ##   in Loop: Header=BB13_9 Depth=1
	movq	1311232(%r10,%r11), %rax
	xorq	(%rdx), %rax
	movq	1311235(%r10,%r11), %rbx
	xorq	3(%rdx), %rbx
	orq	%rax, %rbx
	jne	LBB13_12
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
	jne	LBB13_19
## %bb.15:
	xorq	%rdx, %rcx
	shrq	$32, %rcx
	jne	LBB13_19
## %bb.16:
	leaq	L_.str.71(%rip), %rdx
	leaq	-56(%rbp), %rax
	movq	%rsi, %r14
	movq	%rax, %rsi
	callq	_read_root_file_blob
	movq	%rax, %rbx
	movq	%rdx, %r15
	leaq	L_.str.72(%rip), %rdx
	leaq	-40(%rbp), %rsi
	movq	%r14, %rdi
	callq	_read_root_file_blob
	movq	%rax, %r14
	xorl	%ecx, %ecx
	cmpq	%rdx, %r15
	jne	LBB13_18
## %bb.17:
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_memcmp
	xorl	%ecx, %ecx
	testl	%eax, %eax
	sete	%cl
LBB13_18:
	movq	%rbx, %rdi
	movl	%ecx, %ebx
	callq	_free
	movq	%r14, %rdi
	callq	_free
	movl	%ebx, %eax
	jmp	LBB13_19
LBB13_13:
	xorl	%eax, %eax
LBB13_19:
	addq	$40, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_root_file_blob
_read_root_file_blob:                   ## @read_root_file_blob
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
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
	je	LBB14_10
## %bb.1:
	movq	%rbx, -56(%rbp)                 ## 8-byte Spill
	testq	%rbx, %rbx
	je	LBB14_9
## %bb.2:
	movl	8(%r13), %ebx
	leal	-65375(%rbx), %eax
	cmpl	$-65373, %eax                   ## imm = 0xFFFF00A3
	jb	LBB14_11
## %bb.3:
	movl	$65375, %r15d                   ## imm = 0xFF5F
	xorl	%r12d, %r12d
	.p2align	4
LBB14_4:                                ## =>This Inner Loop Header: Depth=1
	leal	-65375(%rbx), %eax
	cmpl	$-65373, %eax                   ## imm = 0xFFFF00A3
	jb	LBB14_12
## %bb.5:                               ##   in Loop: Header=BB14_4 Depth=1
	decl	%r15d
	je	LBB14_12
## %bb.6:                               ##   in Loop: Header=BB14_4 Depth=1
	movq	-72(%rbp), %rax                 ## 8-byte Reload
	movq	(%rax), %r14
	movq	-56(%rbp), %r13                 ## 8-byte Reload
	subq	%r12, %r13
	cmpq	$8192, %r13                     ## imm = 0x2000
	movl	$8192, %eax                     ## imm = 0x2000
	cmovaeq	%rax, %r13
	movq	-64(%rbp), %rax                 ## 8-byte Reload
	leaq	(%rax,%r12), %rdi
	movl	%ebx, %eax
	shll	$13, %eax
	leaq	(%r14,%rax), %rsi
	addq	$1311232, %rsi                  ## imm = 0x140200
	movq	%r13, %rdx
	callq	_memcpy
	addq	%r13, %r12
	cmpq	-56(%rbp), %r12                 ## 8-byte Folded Reload
	jae	LBB14_9
## %bb.7:                               ##   in Loop: Header=BB14_4 Depth=1
	movl	%ebx, %eax
	movzwl	1049088(%r14,%rax,2), %ebx
	cmpl	$65528, %ebx                    ## imm = 0xFFF8
	jb	LBB14_4
## %bb.8:
	leaq	L_.str.75(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB14_9:
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
LBB14_12:
	leaq	L_.str.74(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB14_10:
	callq	_read_root_file_blob.cold.1
LBB14_11:
	leaq	L_.str.73(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part
_status_hex_tuple_part:                 ## @status_hex_tuple_part
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rax
	movq	%rdx, %rbx
	callq	_status_find_field
	testq	%rax, %rax
	je	LBB15_53
## %bb.1:
	testq	%rbx, %rbx
	je	LBB15_13
	.p2align	4
LBB15_2:                                ## =>This Inner Loop Header: Depth=1
	incq	%rax
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB15_5
## %bb.3:                               ##   in Loop: Header=BB15_2 Depth=1
	cmpl	$58, %ecx
	je	LBB15_5
## %bb.4:                               ##   in Loop: Header=BB15_2 Depth=1
	testl	%ecx, %ecx
	jne	LBB15_2
LBB15_10:
	callq	_status_hex_tuple_part.cold.1
LBB15_5:
	cmpq	$1, %rbx
	je	LBB15_13
## %bb.6:
	addq	$2, %rax
	.p2align	4
LBB15_7:                                ## =>This Inner Loop Header: Depth=1
	movzbl	-2(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB15_11
## %bb.8:                               ##   in Loop: Header=BB15_7 Depth=1
	cmpl	$58, %ecx
	je	LBB15_11
## %bb.9:                               ##   in Loop: Header=BB15_7 Depth=1
	testl	%ecx, %ecx
	je	LBB15_10
## %bb.17:                              ##   in Loop: Header=BB15_7 Depth=1
	incq	%rax
	jmp	LBB15_7
LBB15_11:
	cmpq	$2, %rbx
	jne	LBB15_18
LBB15_12:
	decq	%rax
	jmp	LBB15_13
	.p2align	4
LBB15_18:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB15_22
## %bb.19:                              ##   in Loop: Header=BB15_18 Depth=1
	cmpl	$58, %ecx
	je	LBB15_22
## %bb.20:                              ##   in Loop: Header=BB15_18 Depth=1
	testl	%ecx, %ecx
	je	LBB15_10
## %bb.21:                              ##   in Loop: Header=BB15_18 Depth=1
	incq	%rax
	jmp	LBB15_18
LBB15_22:
	cmpq	$3, %rbx
	je	LBB15_13
## %bb.23:
	addq	$4, %rax
	.p2align	4
LBB15_24:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-4(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB15_28
## %bb.25:                              ##   in Loop: Header=BB15_24 Depth=1
	cmpl	$58, %ecx
	je	LBB15_28
## %bb.26:                              ##   in Loop: Header=BB15_24 Depth=1
	testl	%ecx, %ecx
	je	LBB15_10
## %bb.27:                              ##   in Loop: Header=BB15_24 Depth=1
	incq	%rax
	jmp	LBB15_24
LBB15_28:
	cmpq	$4, %rbx
	jne	LBB15_30
## %bb.29:
	addq	$-3, %rax
	jmp	LBB15_13
	.p2align	4
LBB15_30:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-3(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB15_34
## %bb.31:                              ##   in Loop: Header=BB15_30 Depth=1
	cmpl	$58, %ecx
	je	LBB15_34
## %bb.32:                              ##   in Loop: Header=BB15_30 Depth=1
	testl	%ecx, %ecx
	je	LBB15_10
## %bb.33:                              ##   in Loop: Header=BB15_30 Depth=1
	incq	%rax
	jmp	LBB15_30
LBB15_34:
	cmpq	$5, %rbx
	jne	LBB15_36
## %bb.35:
	addq	$-2, %rax
LBB15_13:
	movzbl	(%rax), %edi
	testb	%dil, %dil
	je	LBB15_54
## %bb.14:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
LBB15_15:                               ## =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	LBB15_45
## %bb.16:                              ##   in Loop: Header=BB15_15 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	LBB15_50
	jmp	LBB15_51
	.p2align	4
LBB15_45:                               ##   in Loop: Header=BB15_15 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	LBB15_47
## %bb.46:                              ##   in Loop: Header=BB15_15 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	LBB15_50
	jmp	LBB15_51
	.p2align	4
LBB15_47:                               ##   in Loop: Header=BB15_15 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	LBB15_51
## %bb.48:                              ##   in Loop: Header=BB15_15 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	LBB15_51
LBB15_50:                               ##   in Loop: Header=BB15_15 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	1(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	LBB15_15
	jmp	LBB15_52
LBB15_51:
	testl	%edx, %edx
	je	LBB15_54
LBB15_52:
	movl	%ecx, %eax
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq
	.p2align	4
LBB15_36:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-2(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB15_40
## %bb.37:                              ##   in Loop: Header=BB15_36 Depth=1
	cmpl	$58, %ecx
	je	LBB15_40
## %bb.38:                              ##   in Loop: Header=BB15_36 Depth=1
	testl	%ecx, %ecx
	je	LBB15_10
## %bb.39:                              ##   in Loop: Header=BB15_36 Depth=1
	incq	%rax
	jmp	LBB15_36
LBB15_40:
	cmpq	$6, %rbx
	je	LBB15_12
LBB15_41:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	LBB15_13
## %bb.42:                              ##   in Loop: Header=BB15_41 Depth=1
	cmpl	$58, %ecx
	je	LBB15_13
## %bb.43:                              ##   in Loop: Header=BB15_41 Depth=1
	testl	%ecx, %ecx
	je	LBB15_10
## %bb.44:                              ##   in Loop: Header=BB15_41 Depth=1
	incq	%rax
	jmp	LBB15_41
LBB15_54:
	callq	_status_hex_tuple_part.cold.2
LBB15_53:
	callq	_status_hex_tuple_part.cold.3
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_find_field
_status_find_field:                     ## @status_find_field
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	(%rdi), %rbx
	testq	%rbx, %rbx
	je	LBB16_6
## %bb.1:
	movq	%rsi, %r14
	movq	%rdi, %r12
	movq	%rsi, %rdi
	callq	_strlen
	movq	8(%r12), %r13
	movq	%r13, %r12
	subq	%rax, %r12
	jbe	LBB16_6
## %bb.2:
	movq	%rax, %r15
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%rax, %rdx
	callq	_memcmp
	testl	%eax, %eax
	jne	LBB16_4
## %bb.3:
	cmpb	$61, (%rbx,%r15)
	je	LBB16_14
LBB16_4:
	cmpq	$1, %r12
	jne	LBB16_8
LBB16_6:
	xorl	%r12d, %r12d
LBB16_15:
	movq	%r12, %rax
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB16_8:
	incq	%rbx
	decq	%r13
	xorl	%r12d, %r12d
	jmp	LBB16_10
	.p2align	4
LBB16_9:                                ##   in Loop: Header=BB16_10 Depth=1
	incq	%rbx
	decq	%r13
	cmpq	%r13, %r15
	je	LBB16_15
LBB16_10:                               ## =>This Inner Loop Header: Depth=1
	movzbl	-1(%rbx), %eax
	cmpq	$32, %rax
	ja	LBB16_9
## %bb.11:                              ##   in Loop: Header=BB16_10 Depth=1
	movabsq	$4294976512, %rcx               ## imm = 0x100002400
	btq	%rax, %rcx
	jae	LBB16_9
## %bb.12:                              ##   in Loop: Header=BB16_10 Depth=1
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_memcmp
	testl	%eax, %eax
	jne	LBB16_9
## %bb.13:                              ##   in Loop: Header=BB16_10 Depth=1
	cmpb	$61, (%rbx,%r15)
	jne	LBB16_9
LBB16_14:
	leaq	(%rbx,%r15), %r12
	incq	%r12
	jmp	LBB16_15
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83
_parse_path83:                          ## @parse_path83
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$88, %rsp
	movq	%rdx, -120(%rbp)                ## 8-byte Spill
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	testq	%rdi, %rdi
	je	LBB17_26
## %bb.1:
	movq	%rdi, %r12
	movzbl	(%rdi), %edx
	testb	%dl, %dl
	je	LBB17_26
## %bb.2:
	movq	%rcx, %r15
	movq	%rsi, %r14
	incq	%r12
	xorl	%eax, %eax
	movl	$11822, %ebx                    ## imm = 0x2E2E
	xorl	%ecx, %ecx
	jmp	LBB17_5
	.p2align	4
LBB17_3:                                ##   in Loop: Header=BB17_5 Depth=1
	xorl	%ecx, %ecx
LBB17_4:                                ##   in Loop: Header=BB17_5 Depth=1
	movzbl	(%r12), %edx
	incq	%r12
	testb	%dl, %dl
	je	LBB17_15
LBB17_5:                                ## =>This Inner Loop Header: Depth=1
	cmpb	$92, %dl
	je	LBB17_7
## %bb.6:                               ##   in Loop: Header=BB17_5 Depth=1
	movzbl	%dl, %esi
	cmpl	$47, %esi
	jne	LBB17_12
LBB17_7:                                ##   in Loop: Header=BB17_5 Depth=1
	testq	%rcx, %rcx
	je	LBB17_3
## %bb.8:                               ##   in Loop: Header=BB17_5 Depth=1
	movb	$0, -112(%rbp,%rcx)
	cmpq	%r15, %rax
	je	LBB17_23
## %bb.9:                               ##   in Loop: Header=BB17_5 Depth=1
	movl	-112(%rbp), %ecx
	xorl	%ebx, %ecx
	movzbl	-110(%rbp), %edx
	orw	%cx, %dx
	je	LBB17_24
## %bb.10:                              ##   in Loop: Header=BB17_5 Depth=1
	cmpw	$46, -112(%rbp)
	je	LBB17_3
## %bb.14:                              ##   in Loop: Header=BB17_5 Depth=1
	leaq	1(%rax), %r13
	leaq	(%rax,%rax,4), %rcx
	leaq	(%rax,%rcx,2), %rsi
	addq	%r14, %rsi
	leaq	-112(%rbp), %rdi
	callq	_fat83_from_display_component
	xorl	%ecx, %ecx
	movq	%r13, %rax
	jmp	LBB17_4
	.p2align	4
LBB17_12:                               ##   in Loop: Header=BB17_5 Depth=1
	leaq	1(%rcx), %rsi
	cmpq	$64, %rsi
	jae	LBB17_25
## %bb.13:                              ##   in Loop: Header=BB17_5 Depth=1
	movb	%dl, -112(%rbp,%rcx)
	movq	%rsi, %rcx
	jmp	LBB17_4
LBB17_15:
	testq	%rcx, %rcx
	je	LBB17_20
## %bb.16:
	movb	$0, -112(%rbp,%rcx)
	cmpq	%r15, %rax
	je	LBB17_29
## %bb.17:
	movl	$11822, %ecx                    ## imm = 0x2E2E
	xorl	-112(%rbp), %ecx
	movzbl	-110(%rbp), %edx
	orw	%cx, %dx
	je	LBB17_30
## %bb.18:
	cmpw	$46, -112(%rbp)
	je	LBB17_20
## %bb.19:
	leaq	1(%rax), %rbx
	leaq	(%rax,%rax,4), %rcx
	leaq	(%rax,%rcx,2), %rax
	addq	%rax, %r14
	leaq	-112(%rbp), %rdi
	movq	%r14, %rsi
	callq	_fat83_from_display_component
	movq	%rbx, %rax
LBB17_20:
	testq	%rax, %rax
	je	LBB17_27
## %bb.21:
	movq	-120(%rbp), %rcx                ## 8-byte Reload
	movq	%rax, (%rcx)
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB17_28
## %bb.22:
	addq	$88, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB17_23:
	callq	_parse_path83.cold.2
LBB17_24:
	callq	_parse_path83.cold.1
LBB17_25:
	callq	_parse_path83.cold.6
LBB17_26:
	callq	_parse_path83.cold.7
LBB17_27:
	callq	_parse_path83.cold.5
LBB17_28:
	callq	___stack_chk_fail
LBB17_29:
	callq	_parse_path83.cold.4
LBB17_30:
	callq	_parse_path83.cold.3
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component
_fat83_from_display_component:          ## @fat83_from_display_component
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	%rsi, %rbx
	movq	%rdi, %r12
	movabsq	$2314885530818453536, %rax      ## imm = 0x2020202020202020
	movq	%rax, (%rsi)
	movl	$538976288, 7(%rsi)             ## imm = 0x20202020
	movl	$46, %esi
	callq	_strchr
	movq	%rax, %r14
	testq	%rax, %rax
	je	LBB18_1
## %bb.3:
	movq	%r14, %r13
	subq	%r12, %r13
	leaq	1(%r14), %rdi
	movq	%rdi, -48(%rbp)                 ## 8-byte Spill
	callq	_strlen
	movq	%rax, %r15
	leaq	-9(%r13), %rax
	cmpq	$-8, %rax
	jb	LBB18_18
## %bb.4:
	cmpq	$4, %r15
	jae	LBB18_18
## %bb.5:
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	movl	$46, %esi
	callq	_strchr
	testq	%rax, %rax
	je	LBB18_6
## %bb.19:
	callq	_fat83_from_display_component.cold.1
LBB18_1:
	movq	%r12, %rdi
	callq	_strlen
	movq	%rax, %r13
	addq	$-9, %rax
	cmpq	$-8, %rax
	jb	LBB18_18
## %bb.2:
	xorl	%r15d, %r15d
LBB18_6:
	xorl	%eax, %eax
	jmp	LBB18_7
	.p2align	4
LBB18_10:                               ##   in Loop: Header=BB18_7 Depth=1
	movb	%cl, (%rbx,%rax)
	incq	%rax
	cmpq	%rax, %r13
	je	LBB18_11
LBB18_7:                                ## =>This Inner Loop Header: Depth=1
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
	jne	LBB18_10
## %bb.8:                               ##   in Loop: Header=BB18_7 Depth=1
	cmpb	$45, %cl
	je	LBB18_10
## %bb.9:                               ##   in Loop: Header=BB18_7 Depth=1
	movzbl	%cl, %edx
	cmpl	$95, %edx
	je	LBB18_10
## %bb.21:
	callq	_fat83_from_display_component.cold.2
LBB18_11:
	testq	%r15, %r15
	je	LBB18_17
## %bb.12:
	xorl	%eax, %eax
	jmp	LBB18_13
	.p2align	4
LBB18_16:                               ##   in Loop: Header=BB18_13 Depth=1
	movb	%cl, 8(%rbx,%rax)
	incq	%rax
	cmpq	%rax, %r15
	je	LBB18_17
LBB18_13:                               ## =>This Inner Loop Header: Depth=1
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
	jne	LBB18_16
## %bb.14:                              ##   in Loop: Header=BB18_13 Depth=1
	cmpb	$45, %cl
	je	LBB18_16
## %bb.15:                              ##   in Loop: Header=BB18_13 Depth=1
	movzbl	%cl, %edx
	cmpl	$95, %edx
	je	LBB18_16
## %bb.20:
	callq	_fat83_from_display_component.cold.3
LBB18_17:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB18_18:
	callq	_fat83_from_display_component.cold.4
                                        ## -- End function
	.p2align	4                               ## -- Begin function format_fat_name
_format_fat_name:                       ## @format_fat_name
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movzbl	(%rdi), %eax
	cmpb	$32, %al
	jne	LBB19_5
## %bb.1:
	xorl	%eax, %eax
	jmp	LBB19_2
LBB19_5:
	movb	%al, (%rsi)
	movzbl	1(%rdi), %ecx
	movl	$1, %eax
	cmpb	$32, %cl
	je	LBB19_2
## %bb.6:
	movb	%cl, 1(%rsi)
	movzbl	2(%rdi), %ecx
	movl	$2, %eax
	cmpb	$32, %cl
	je	LBB19_2
## %bb.7:
	movb	%cl, 2(%rsi)
	movzbl	3(%rdi), %ecx
	movl	$3, %eax
	cmpb	$32, %cl
	je	LBB19_2
## %bb.8:
	movb	%cl, 3(%rsi)
	movzbl	4(%rdi), %ecx
	movl	$4, %eax
	cmpb	$32, %cl
	je	LBB19_2
## %bb.9:
	movb	%cl, 4(%rsi)
	movzbl	5(%rdi), %ecx
	movl	$5, %eax
	cmpb	$32, %cl
	je	LBB19_2
## %bb.10:
	movb	%cl, 5(%rsi)
	movzbl	6(%rdi), %ecx
	movl	$6, %eax
	cmpb	$32, %cl
	je	LBB19_2
## %bb.11:
	movb	%cl, 6(%rsi)
	movzbl	7(%rdi), %ecx
	movl	$7, %eax
	cmpb	$32, %cl
	je	LBB19_2
## %bb.12:
	movb	%cl, 7(%rsi)
	movl	$8, %eax
LBB19_2:
	cmpb	$32, 8(%rdi)
	je	LBB19_18
## %bb.3:
	movb	$46, (%rsi,%rax)
	movzbl	8(%rdi), %ecx
	cmpb	$32, %cl
	jne	LBB19_13
## %bb.4:
	incq	%rax
	jmp	LBB19_18
LBB19_13:
	movb	%cl, 1(%rsi,%rax)
	movzbl	9(%rdi), %ecx
	cmpb	$32, %cl
	jne	LBB19_15
## %bb.14:
	addq	$2, %rax
	jmp	LBB19_18
LBB19_15:
	movb	%cl, 2(%rsi,%rax)
	movzbl	10(%rdi), %ecx
	cmpb	$32, %cl
	jne	LBB19_17
## %bb.16:
	addq	$3, %rax
	jmp	LBB19_18
LBB19_17:
	movb	%cl, 3(%rsi,%rax)
	addq	$4, %rax
LBB19_18:
	movb	$0, (%rsi,%rax)
	popq	%rbp
	retq
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_directory
_inspect_directory:                     ## @inspect_directory
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$216, %rsp
                                        ## kill: def $edx killed $edx def $rdx
	movq	%rsi, -248(%rbp)                ## 8-byte Spill
	movq	%rdi, -240(%rbp)                ## 8-byte Spill
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	movl	%ecx, -228(%rbp)                ## 4-byte Spill
	testl	%ecx, %ecx
	sete	%al
	leal	-65375(%rdx), %ecx
	cmpl	$-65373, %ecx                   ## imm = 0xFFFF00A3
	setb	%cl
	orb	%al, %cl
	je	LBB20_1
LBB20_9:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB20_12
## %bb.10:
	addq	$216, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB20_1:
	movq	-240(%rbp), %rax                ## 8-byte Reload
	movq	(%rax), %rax
	shll	$13, %edx
	leaq	(%rax,%rdx), %rbx
	addq	$1311232, %rbx                  ## imm = 0x140200
	decl	-228(%rbp)                      ## 4-byte Folded Spill
	leaq	-61(%rbp), %r12
	leaq	-224(%rbp), %r13
	xorl	%r14d, %r14d
	jmp	LBB20_2
	.p2align	4
LBB20_8:                                ##   in Loop: Header=BB20_2 Depth=1
	addq	$32, %r14
	cmpq	$8192, %r14                     ## imm = 0x2000
	je	LBB20_9
LBB20_2:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%rbx,%r14), %eax
	cmpl	$46, %eax
	je	LBB20_8
## %bb.3:                               ##   in Loop: Header=BB20_2 Depth=1
	cmpl	$229, %eax
	je	LBB20_8
## %bb.4:                               ##   in Loop: Header=BB20_2 Depth=1
	testl	%eax, %eax
	je	LBB20_9
## %bb.5:                               ##   in Loop: Header=BB20_2 Depth=1
	leaq	(%rbx,%r14), %rdi
	movq	%r12, %rsi
	callq	_format_fat_name
	movl	$160, %esi
	movq	%r13, %rdi
	leaq	L_.str.144(%rip), %rdx
	movq	-248(%rbp), %rcx                ## 8-byte Reload
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$160, %eax
	jae	LBB20_11
## %bb.6:                               ##   in Loop: Header=BB20_2 Depth=1
	movzwl	26(%rbx,%r14), %r15d
	movl	28(%rbx,%r14), %r8d
	movzbl	11(%rbx,%r14), %edx
	leaq	L_.str.146(%rip), %rdi
	movq	%r13, %rsi
	movl	%r15d, %ecx
	xorl	%eax, %eax
	callq	_printf
	testb	$16, 11(%rbx,%r14)
	je	LBB20_8
## %bb.7:                               ##   in Loop: Header=BB20_2 Depth=1
	movq	-240(%rbp), %rdi                ## 8-byte Reload
	movq	%r13, %rsi
	movl	%r15d, %edx
	movl	-228(%rbp), %ecx                ## 4-byte Reload
	callq	_inspect_directory
	jmp	LBB20_8
LBB20_11:
	callq	_inspect_directory.cold.1
LBB20_12:
	callq	___stack_chk_fail
                                        ## -- End function
	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0                          ## -- Begin function inspect_pi4_manifest
LCPI21_0:
	.byte	97                              ## 0x61
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	45                              ## 0x2d
	.byte	109                             ## 0x6d
	.byte	97                              ## 0x61
	.byte	110                             ## 0x6e
	.byte	105                             ## 0x69
	.byte	102                             ## 0x66
	.byte	101                             ## 0x65
	.byte	115                             ## 0x73
	.byte	116                             ## 0x74
	.byte	45                              ## 0x2d
	.byte	118                             ## 0x76
	.byte	49                              ## 0x31
	.byte	0                               ## 0x0
LCPI21_1:
	.byte	118                             ## 0x76
	.byte	105                             ## 0x69
	.byte	98                              ## 0x62
	.byte	101                             ## 0x65
	.byte	45                              ## 0x2d
	.byte	111                             ## 0x6f
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	105                             ## 0x69
	.byte	52                              ## 0x34
	.byte	45                              ## 0x2d
	.byte	105                             ## 0x69
	.byte	109                             ## 0x6d
	.byte	97                              ## 0x61
	.byte	103                             ## 0x67
LCPI21_2:
	.byte	111                             ## 0x6f
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	105                             ## 0x69
	.byte	52                              ## 0x34
	.byte	45                              ## 0x2d
	.byte	102                             ## 0x66
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	49                              ## 0x31
	.byte	54                              ## 0x36
	.byte	45                              ## 0x2d
	.byte	118                             ## 0x76
	.byte	49                              ## 0x31
	.byte	0                               ## 0x0
LCPI21_3:
	.byte	118                             ## 0x76
	.byte	105                             ## 0x69
	.byte	98                              ## 0x62
	.byte	101                             ## 0x65
	.byte	45                              ## 0x2d
	.byte	111                             ## 0x6f
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	105                             ## 0x69
	.byte	52                              ## 0x34
	.byte	45                              ## 0x2d
	.byte	102                             ## 0x66
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	49                              ## 0x31
LCPI21_4:
	.byte	84                              ## 0x54
	.byte	88                              ## 0x58
	.byte	84                              ## 0x54
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
LCPI21_5:
	.byte	47                              ## 0x2f
	.byte	80                              ## 0x50
	.byte	82                              ## 0x52
	.byte	79                              ## 0x4f
	.byte	79                              ## 0x4f
	.byte	70                              ## 0x46
	.byte	47                              ## 0x2f
	.byte	77                              ## 0x4d
	.byte	65                              ## 0x41
	.byte	78                              ## 0x4e
	.byte	73                              ## 0x49
	.byte	70                              ## 0x46
	.byte	69                              ## 0x45
	.byte	83                              ## 0x53
	.byte	84                              ## 0x54
	.byte	46                              ## 0x2e
LCPI21_6:
	.byte	45                              ## 0x2d
	.byte	97                              ## 0x61
	.byte	112                             ## 0x70
	.byte	112                             ## 0x70
	.byte	45                              ## 0x2d
	.byte	105                             ## 0x69
	.byte	110                             ## 0x6e
	.byte	115                             ## 0x73
	.byte	116                             ## 0x74
	.byte	97                              ## 0x61
	.byte	108                             ## 0x6c
	.byte	108                             ## 0x6c
	.byte	45                              ## 0x2d
	.byte	118                             ## 0x76
	.byte	49                              ## 0x31
	.byte	0                               ## 0x0
LCPI21_7:
	.byte	118                             ## 0x76
	.byte	105                             ## 0x69
	.byte	98                              ## 0x62
	.byte	101                             ## 0x65
	.byte	45                              ## 0x2d
	.byte	111                             ## 0x6f
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	105                             ## 0x69
	.byte	52                              ## 0x34
	.byte	45                              ## 0x2d
	.byte	97                              ## 0x61
	.byte	112                             ## 0x70
	.byte	112                             ## 0x70
	.byte	45                              ## 0x2d
LCPI21_8:
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	108                             ## 0x6c
	.byte	117                             ## 0x75
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	97                              ## 0x61
	.byte	112                             ## 0x70
	.byte	112                             ## 0x70
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	116                             ## 0x74
	.byte	114                             ## 0x72
	.byte	101                             ## 0x65
	.byte	101                             ## 0x65
	.byte	0                               ## 0x0
LCPI21_9:
	.byte	115                             ## 0x73
	.byte	121                             ## 0x79
	.byte	115                             ## 0x73
	.byte	116                             ## 0x74
	.byte	101                             ## 0x65
	.byte	109                             ## 0x6d
	.byte	45                              ## 0x2d
	.byte	105                             ## 0x69
	.byte	110                             ## 0x6e
	.byte	105                             ## 0x69
	.byte	116                             ## 0x74
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	108                             ## 0x6c
	.byte	117                             ## 0x75
	.byte	115                             ## 0x73
LCPI21_10:
	.byte	99                              ## 0x63
	.byte	45                              ## 0x2d
	.byte	118                             ## 0x76
	.byte	102                             ## 0x66
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	104                             ## 0x68
	.byte	45                              ## 0x2d
	.byte	101                             ## 0x65
	.byte	120                             ## 0x78
	.byte	101                             ## 0x65
	.byte	99                              ## 0x63
	.byte	0                               ## 0x0
LCPI21_11:
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	110                             ## 0x6e
	.byte	101                             ## 0x65
	.byte	114                             ## 0x72
	.byte	105                             ## 0x69
	.byte	99                              ## 0x63
	.byte	45                              ## 0x2d
	.byte	118                             ## 0x76
	.byte	102                             ## 0x66
	.byte	115                             ## 0x73
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	104                             ## 0x68
LCPI21_12:
	.byte	101                             ## 0x65
	.byte	108                             ## 0x6c
	.byte	48                              ## 0x30
	.byte	45                              ## 0x2d
	.byte	101                             ## 0x65
	.byte	108                             ## 0x6c
	.byte	102                             ## 0x66
	.byte	45                              ## 0x2d
	.byte	98                              ## 0x62
	.byte	121                             ## 0x79
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	104                             ## 0x68
	.byte	0                               ## 0x0
LCPI21_13:
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	110                             ## 0x6e
	.byte	101                             ## 0x65
	.byte	114                             ## 0x72
	.byte	105                             ## 0x69
	.byte	99                              ## 0x63
	.byte	45                              ## 0x2d
	.byte	97                              ## 0x61
	.byte	97                              ## 0x61
	.byte	114                             ## 0x72
	.byte	99                              ## 0x63
	.byte	104                             ## 0x68
	.byte	54                              ## 0x36
	.byte	52                              ## 0x34
	.byte	45                              ## 0x2d
LCPI21_14:
	.byte	69                              ## 0x45
	.byte	77                              ## 0x4d
	.byte	47                              ## 0x2f
	.byte	65                              ## 0x41
	.byte	66                              ## 0x42
	.byte	73                              ## 0x49
	.byte	80                              ## 0x50
	.byte	82                              ## 0x52
	.byte	79                              ## 0x4f
	.byte	66                              ## 0x42
	.byte	69                              ## 0x45
	.byte	46                              ## 0x2e
	.byte	69                              ## 0x45
	.byte	76                              ## 0x4c
	.byte	70                              ## 0x46
	.byte	0                               ## 0x0
LCPI21_15:
	.byte	47                              ## 0x2f
	.byte	83                              ## 0x53
	.byte	89                              ## 0x59
	.byte	83                              ## 0x53
	.byte	84                              ## 0x54
	.byte	69                              ## 0x45
	.byte	77                              ## 0x4d
	.byte	47                              ## 0x2f
	.byte	65                              ## 0x41
	.byte	66                              ## 0x42
	.byte	73                              ## 0x49
	.byte	80                              ## 0x50
	.byte	82                              ## 0x52
	.byte	79                              ## 0x4f
	.byte	66                              ## 0x42
	.byte	69                              ## 0x45
LCPI21_16:
	.byte	47                              ## 0x2f
	.byte	65                              ## 0x41
	.byte	80                              ## 0x50
	.byte	80                              ## 0x50
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	73                              ## 0x49
	.byte	78                              ## 0x4e
	.byte	68                              ## 0x44
	.byte	69                              ## 0x45
	.byte	88                              ## 0x58
	.byte	46                              ## 0x2e
	.byte	84                              ## 0x54
	.byte	88                              ## 0x58
	.byte	84                              ## 0x54
	.byte	0                               ## 0x0
LCPI21_17:
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	110                             ## 0x6e
	.byte	101                             ## 0x65
	.byte	114                             ## 0x72
	.byte	105                             ## 0x69
	.byte	99                              ## 0x63
	.byte	45                              ## 0x2d
	.byte	112                             ## 0x70
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	104                             ## 0x68
	.byte	45                              ## 0x2d
	.byte	101                             ## 0x65
	.byte	120                             ## 0x78
	.byte	101                             ## 0x65
LCPI21_18:
	.long	99                              ## 0x63
	.long	0                               ## 0x0
	.long	0                               ## 0x0
	.long	0                               ## 0x0
LCPI21_19:
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	110                             ## 0x6e
	.byte	101                             ## 0x65
	.byte	114                             ## 0x72
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	101                             ## 0x65
	.byte	100                             ## 0x64
	.byte	45                              ## 0x2d
	.byte	102                             ## 0x66
	.byte	105                             ## 0x69
	.byte	120                             ## 0x78
	.byte	116                             ## 0x74
	.byte	117                             ## 0x75
	.byte	114                             ## 0x72
LCPI21_20:
	.long	101                             ## 0x65
	.long	0                               ## 0x0
	.long	0                               ## 0x0
	.long	0                               ## 0x0
LCPI21_21:
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	101                             ## 0x65
	.byte	100                             ## 0x64
	.byte	45                              ## 0x2d
	.byte	98                              ## 0x62
	.byte	121                             ## 0x79
	.byte	45                              ## 0x2d
	.byte	98                              ## 0x62
	.byte	117                             ## 0x75
	.byte	105                             ## 0x69
	.byte	108                             ## 0x6c
	.byte	100                             ## 0x64
	.byte	101                             ## 0x65
	.byte	114                             ## 0x72
	.byte	0                               ## 0x0
LCPI21_22:
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	110                             ## 0x6e
	.byte	101                             ## 0x65
	.byte	114                             ## 0x72
	.byte	97                              ## 0x61
	.byte	116                             ## 0x74
	.byte	101                             ## 0x65
	.byte	100                             ## 0x64
	.byte	45                              ## 0x2d
	.byte	98                              ## 0x62
	.byte	121                             ## 0x79
	.byte	45                              ## 0x2d
	.byte	98                              ## 0x62
	.byte	117                             ## 0x75
	.byte	105                             ## 0x69
LCPI21_23:
	.byte	107                             ## 0x6b
	.byte	97                              ## 0x61
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	100                             ## 0x64
	.byte	45                              ## 0x2d
	.byte	102                             ## 0x66
	.byte	105                             ## 0x69
	.byte	108                             ## 0x6c
	.byte	101                             ## 0x65
	.byte	45                              ## 0x2d
	.byte	111                             ## 0x6f
	.byte	110                             ## 0x6e
	.byte	108                             ## 0x6c
	.byte	121                             ## 0x79
	.byte	0                               ## 0x0
LCPI21_24:
	.byte	112                             ## 0x70
	.byte	97                              ## 0x61
	.byte	99                              ## 0x63
	.byte	107                             ## 0x6b
	.byte	97                              ## 0x61
	.byte	103                             ## 0x67
	.byte	101                             ## 0x65
	.byte	100                             ## 0x64
	.byte	45                              ## 0x2d
	.byte	102                             ## 0x66
	.byte	105                             ## 0x69
	.byte	108                             ## 0x6c
	.byte	101                             ## 0x65
	.byte	45                              ## 0x2d
	.byte	111                             ## 0x6f
	.byte	110                             ## 0x6e
LCPI21_25:
	.byte	83                              ## 0x53
	.byte	69                              ## 0x45
	.byte	84                              ## 0x54
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	82                              ## 0x52
	.byte	69                              ## 0x45
	.byte	65                              ## 0x41
	.byte	68                              ## 0x44
	.byte	77                              ## 0x4d
	.byte	69                              ## 0x45
	.byte	46                              ## 0x2e
	.byte	84                              ## 0x54
	.byte	88                              ## 0x58
	.byte	84                              ## 0x54
	.byte	0                               ## 0x0
LCPI21_26:
	.byte	47                              ## 0x2f
	.byte	65                              ## 0x41
	.byte	83                              ## 0x53
	.byte	83                              ## 0x53
	.byte	69                              ## 0x45
	.byte	84                              ## 0x54
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	82                              ## 0x52
	.byte	69                              ## 0x45
	.byte	65                              ## 0x41
	.byte	68                              ## 0x44
	.byte	77                              ## 0x4d
	.byte	69                              ## 0x45
	.byte	46                              ## 0x2e
	.byte	84                              ## 0x54
LCPI21_27:
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	77                              ## 0x4d
	.byte	65                              ## 0x41
	.byte	80                              ## 0x50
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	69                              ## 0x45
	.byte	49                              ## 0x31
	.byte	77                              ## 0x4d
	.byte	49                              ## 0x31
	.byte	46                              ## 0x2e
	.byte	77                              ## 0x4d
	.byte	65                              ## 0x41
	.byte	80                              ## 0x50
	.byte	0                               ## 0x0
LCPI21_28:
	.byte	47                              ## 0x2f
	.byte	65                              ## 0x41
	.byte	83                              ## 0x53
	.byte	83                              ## 0x53
	.byte	69                              ## 0x45
	.byte	84                              ## 0x54
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	77                              ## 0x4d
	.byte	65                              ## 0x41
	.byte	80                              ## 0x50
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	69                              ## 0x45
	.byte	49                              ## 0x31
	.byte	77                              ## 0x4d
LCPI21_29:
	.byte	88                              ## 0x58
	.byte	84                              ## 0x54
	.byte	85                              ## 0x55
	.byte	82                              ## 0x52
	.byte	69                              ## 0x45
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	80                              ## 0x50
	.byte	65                              ## 0x41
	.byte	76                              ## 0x4c
	.byte	48                              ## 0x30
	.byte	46                              ## 0x2e
	.byte	66                              ## 0x42
	.byte	73                              ## 0x49
	.byte	78                              ## 0x4e
	.byte	0                               ## 0x0
LCPI21_30:
	.byte	47                              ## 0x2f
	.byte	65                              ## 0x41
	.byte	83                              ## 0x53
	.byte	83                              ## 0x53
	.byte	69                              ## 0x45
	.byte	84                              ## 0x54
	.byte	83                              ## 0x53
	.byte	47                              ## 0x2f
	.byte	84                              ## 0x54
	.byte	69                              ## 0x45
	.byte	88                              ## 0x58
	.byte	84                              ## 0x54
	.byte	85                              ## 0x55
	.byte	82                              ## 0x52
	.byte	69                              ## 0x45
	.byte	83                              ## 0x53
LCPI21_31:
	.byte	112                             ## 0x70
	.byte	117                             ## 0x75
	.byte	116                             ## 0x74
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
	.byte	0                               ## 0x0
LCPI21_32:
	.byte	101                             ## 0x65
	.byte	120                             ## 0x78
	.byte	116                             ## 0x74
	.byte	101                             ## 0x65
	.byte	114                             ## 0x72
	.byte	110                             ## 0x6e
	.byte	97                              ## 0x61
	.byte	108                             ## 0x6c
	.byte	45                              ## 0x2d
	.byte	104                             ## 0x68
	.byte	111                             ## 0x6f
	.byte	115                             ## 0x73
	.byte	116                             ## 0x74
	.byte	45                              ## 0x2d
	.byte	105                             ## 0x69
	.byte	110                             ## 0x6e
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	4
_inspect_pi4_manifest:                  ## @inspect_pi4_manifest
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movl	$16264, %eax                    ## imm = 0x3F88
	callq	____chkstk_darwin
	subq	%rax, %rsp
	popq	%rax
	movl	%esi, %r12d
	movq	%rdi, %r14
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	movq	$0, -16120(%rbp)
	leaq	_PROOF_MANIFEST_PATH(%rip), %rsi
	leaq	-16304(%rbp), %rdx
	callq	_inspect_find_path
	testl	%eax, %eax
	je	LBB21_1
## %bb.3:
	leaq	_PROOF_MANIFEST_PATH(%rip), %rdx
	leaq	-16304(%rbp), %rsi
	movq	%r14, %rdi
	callq	_inspect_read_file_blob
	movq	%rax, %r15
	movq	%rax, -16112(%rbp)
	movq	%rdx, -16104(%rbp)
	leaq	L_.str.155(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_225
## %bb.4:
	movdqa	-16096(%rbp), %xmm0
	movdqu	-16082(%rbp), %xmm1
	pxor	LCPI21_0(%rip), %xmm1
	pxor	LCPI21_1(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_226
## %bb.5:
	leaq	L_.str.157(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_227
## %bb.6:
	movdqa	-16096(%rbp), %xmm0
	movdqu	-16091(%rbp), %xmm1
	pxor	LCPI21_2(%rip), %xmm1
	pxor	LCPI21_3(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_228
## %bb.7:
	leaq	L_.str.159(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	callq	_manifest_require_u64
	cmpq	$2561, %rax                     ## imm = 0xA01
	jne	LBB21_229
## %bb.8:
	leaq	L_.str.160(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	callq	_manifest_require_u64
	cmpq	$2593, %rax                     ## imm = 0xA21
	jne	LBB21_230
## %bb.9:
	leaq	L_.str.161(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	callq	_manifest_require_u64
	cmpq	$512, %rax                      ## imm = 0x200
	jne	LBB21_231
## %bb.10:
	leaq	L_.str.162(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_232
## %bb.11:
	movdqa	-16096(%rbp), %xmm0
	movd	-16080(%rbp), %xmm1             ## xmm1 = mem[0],zero,zero,zero
	pxor	LCPI21_4(%rip), %xmm1
	pxor	LCPI21_5(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_233
## %bb.12:
	movl	-16292(%rbp), %edx
	leaq	L_.str.163(%rip), %rdi
	leaq	_PROOF_MANIFEST_PATH(%rip), %rsi
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.164(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_234
## %bb.13:
	movabsq	$3330495784990950731, %rax      ## imm = 0x2E384C454E52454B
	xorq	-16096(%rbp), %rax
	movl	-16088(%rbp), %ecx
	xorq	$4672841, %rcx                  ## imm = 0x474D49
	orq	%rax, %rcx
	jne	LBB21_235
## %bb.14:
	leaq	L_.str.164(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_236
## %bb.15:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.164(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.165(%rip), %rdx
	leaq	L_.str.166(%rip), %rcx
	leaq	-16112(%rbp), %rbx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.167(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_237
## %bb.16:
	movabsq	$6065864128152358723, %rax      ## imm = 0x542E4749464E4F43
	xorq	-16096(%rbp), %rax
	movabsq	$23741016620616006, %rcx        ## imm = 0x5458542E474946
	xorq	-16093(%rbp), %rcx
	orq	%rax, %rcx
	jne	LBB21_238
## %bb.17:
	leaq	L_.str.167(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_239
## %bb.18:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.167(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.168(%rip), %rdx
	leaq	L_.str.169(%rip), %rcx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.170(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_240
## %bb.19:
	movdqa	-16096(%rbp), %xmm0
	movdqu	-16085(%rbp), %xmm1
	pxor	LCPI21_6(%rip), %xmm1
	pxor	LCPI21_7(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_241
## %bb.20:
	leaq	L_.str.170(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_242
## %bb.21:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.170(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.172(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_243
## %bb.22:
	movdqa	-16096(%rbp), %xmm0
	movdqu	-16085(%rbp), %xmm1
	pxor	LCPI21_8(%rip), %xmm1
	pxor	LCPI21_9(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_244
## %bb.23:
	leaq	L_.str.172(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_245
## %bb.24:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.172(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.173(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_246
## %bb.25:
	movabsq	$3274240491775026806, %rax      ## imm = 0x2D7070612D736676
	xorq	-16096(%rbp), %rax
	movabsq	$33888479228800368, %rcx        ## imm = 0x7865646E692D70
	xorq	-16090(%rbp), %rcx
	orq	%rax, %rcx
	jne	LBB21_247
## %bb.26:
	leaq	L_.str.173(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_248
## %bb.27:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.173(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.174(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_249
## %bb.28:
	movdqa	-16096(%rbp), %xmm0
	movdqu	-16090(%rbp), %xmm1
	pxor	LCPI21_10(%rip), %xmm1
	pxor	LCPI21_11(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_250
## %bb.29:
	leaq	L_.str.174(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_251
## %bb.30:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.174(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.176(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_252
## %bb.31:
	movdqa	-16096(%rbp), %xmm0
	movdqa	-16080(%rbp), %xmm1
	pxor	LCPI21_12(%rip), %xmm1
	pxor	LCPI21_13(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_253
## %bb.32:
	leaq	L_.str.176(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_254
## %bb.33:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.176(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.177(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_255
## %bb.34:
	movabsq	$5065499746169867849, %rax      ## imm = 0x464C452E54494E49
	xorq	-16088(%rbp), %rax
	movabsq	$3408456721467265839, %rcx      ## imm = 0x2F4D45545359532F
	xorq	-16096(%rbp), %rcx
	movzbl	-16080(%rbp), %edx
	orq	%rcx, %rdx
	orq	%rax, %rdx
	jne	LBB21_256
## %bb.35:
	leaq	L_.str.177(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_257
## %bb.36:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.177(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	_PI4_SYSTEM_INIT_PATH(%rip), %rdx
	leaq	L_.str.178(%rip), %rcx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.179(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_258
## %bb.37:
	movdqa	-16096(%rbp), %xmm0
	movdqu	-16091(%rbp), %xmm1
	pxor	LCPI21_14(%rip), %xmm1
	pxor	LCPI21_15(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_259
## %bb.38:
	leaq	L_.str.179(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_260
## %bb.39:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.179(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	_PI4_SYSTEM_ABIPROBE_PATH(%rip), %rdx
	leaq	L_.str.180(%rip), %rcx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.181(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_261
## %bb.40:
	movdqa	-16096(%rbp), %xmm0
	pxor	LCPI21_16(%rip), %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_262
## %bb.41:
	movq	%r14, -16136(%rbp)              ## 8-byte Spill
	leaq	L_.str.181(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-16096(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_263
## %bb.42:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.181(%rip), %rsi
	leaq	-16096(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	_PI4_APP_INDEX_PATH(%rip), %r14
	leaq	L_.str.182(%rip), %rcx
	leaq	-16120(%rbp), %r8
	movq	-16136(%rbp), %r13              ## 8-byte Reload
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	_inspect_manifest_require_file
	leaq	-16096(%rbp), %rsi
	movq	%r13, %rdi
	movl	%r12d, %edx
	callq	_load_pi4_app_catalog
	movq	-16096(%rbp), %rdx
	leaq	L_.str.280(%rip), %rdi
	leaq	_PI4_APP_DISCOVERY_MODEL(%rip), %rcx
	movq	%r14, %rsi
	xorl	%eax, %eax
	callq	_printf
	movq	-16096(%rbp), %rcx
	leaq	L_.str.183(%rip), %rdx
	leaq	-912(%rbp), %rdi
	movl	$32, %esi
	xorl	%eax, %eax
	callq	_snprintf
	leaq	_PI4_APP_RECORD_COUNT_KEY(%rip), %rsi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_264
## %bb.43:
	leaq	-208(%rbp), %rdi
	leaq	-912(%rbp), %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_265
## %bb.44:
	movl	%r12d, -16164(%rbp)             ## 4-byte Spill
	movq	%r15, -16248(%rbp)              ## 8-byte Spill
	leaq	_PI4_APP_RECORD_COUNT_KEY(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_266
## %bb.45:
	leaq	L_.str.248(%rip), %rdi
	leaq	_PI4_APP_RECORD_COUNT_KEY(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	cmpq	$0, -16096(%rbp)
	je	LBB21_49
## %bb.46:
	movabsq	$3257288252468650337, %rcx      ## imm = 0x2D34366863726161
	movabsq	$3270573694450034023, %rdx      ## imm = 0x2D636972656E6567
	movabsq	$29401359420586338, %rax        ## imm = 0x687461702D7962
	movabsq	$3271421361136888933, %rsi      ## imm = 0x2D666C652D306C65
	leaq	L_.str.276(%rip), %r13
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rbx
	leaq	-816(%rbp), %r14
	leaq	-208(%rbp), %r15
	movq	%rdx, %xmm2
	movq	%rcx, %xmm0
	movq	%rsi, %xmm3
	movq	%rax, %xmm1
	punpcklqdq	%xmm0, %xmm2            ## xmm2 = xmm2[0],xmm0[0]
	movdqa	%xmm2, -16208(%rbp)             ## 16-byte Spill
	punpcklqdq	%xmm1, %xmm3            ## xmm3 = xmm3[0],xmm1[0]
	movdqa	%xmm3, -16192(%rbp)             ## 16-byte Spill
	movq	$0, -16128(%rbp)                ## 8-byte Folded Spill
	xorl	%r12d, %r12d
	jmp	LBB21_47
	.p2align	4
LBB21_117:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.292(%rip), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	_printf
LBB21_118:                              ##   in Loop: Header=BB21_47 Depth=1
	movq	-16224(%rbp), %rax              ## 8-byte Reload
	incq	%rax
	addq	$948, %r12                      ## imm = 0x3B4
	movq	%r12, -16128(%rbp)              ## 8-byte Spill
	movq	%rax, %r12
	cmpq	-16096(%rbp), %rax
	leaq	L_.str.276(%rip), %r13
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rbx
	leaq	-208(%rbp), %r15
	leaq	-816(%rbp), %r14
	jae	LBB21_49
LBB21_47:                               ## =>This Inner Loop Header: Depth=1
	movl	$64, %esi
	movq	%r14, %rdi
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.259(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_48
## %bb.70:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	movq	-16128(%rbp), %r13              ## 8-byte Reload
	je	LBB21_269
## %bb.71:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	-16088(,%r13), %rsi
	addq	%rbp, %rsi
	movq	%r15, %rdi
	movq	%rsi, -16160(%rbp)              ## 8-byte Spill
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_270
## %bb.72:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	leaq	-816(%rbp), %r14
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_271
## %bb.73:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.263(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_272
## %bb.74:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_273
## %bb.75:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	-16024(,%r13), %rsi
	addq	%rbp, %rsi
	movq	%r15, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_274
## %bb.76:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_275
## %bb.77:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.260(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_276
## %bb.78:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_277
## %bb.79:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	-15928(,%r13), %rsi
	addq	%rbp, %rsi
	movq	%r15, %rdi
	movq	%rsi, -16152(%rbp)              ## 8-byte Spill
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_278
## %bb.80:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_279
## %bb.81:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.281(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_280
## %bb.82:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	-15180(%rbp,%r13), %ebx
	leaq	-16112(%rbp), %r13
	movq	%r13, %rdi
	movq	%r14, %rsi
	callq	_manifest_require_u64
	cmpq	%rbx, %rax
	jne	LBB21_281
## %bb.83:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rbx
	je	LBB21_282
## %bb.84:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.264(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	movq	-16128(%rbp), %r13              ## 8-byte Reload
	jae	LBB21_283
## %bb.85:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_284
## %bb.86:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	-15768(,%r13), %rsi
	addq	%rbp, %rsi
	movq	%r15, %rdi
	movq	%rsi, -16144(%rbp)              ## 8-byte Spill
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_285
## %bb.87:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_286
## %bb.88:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.282(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_287
## %bb.89:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	-15164(%rbp,%r13), %ebx
	leaq	-16112(%rbp), %r13
	movq	%r13, %rdi
	movq	%r14, %rsi
	callq	_manifest_require_u64
	cmpq	%rbx, %rax
	jne	LBB21_288
## %bb.90:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rbx
	je	LBB21_289
## %bb.91:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.283(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	movq	-16128(%rbp), %r13              ## 8-byte Reload
	jae	LBB21_290
## %bb.92:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_291
## %bb.93:                              ##   in Loop: Header=BB21_47 Depth=1
	movzwl	-192(%rbp), %eax
	movd	%eax, %xmm0
	pxor	LCPI21_18(%rip), %xmm0
	movdqa	-208(%rbp), %xmm1
	pxor	LCPI21_17(%rip), %xmm1
	por	%xmm0, %xmm1
	ptest	%xmm1, %xmm1
	jne	LBB21_292
## %bb.94:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_293
## %bb.95:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.284(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_294
## %bb.96:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_295
## %bb.97:                              ##   in Loop: Header=BB21_47 Depth=1
	movdqa	-192(%rbp), %xmm0
	pxor	-16192(%rbp), %xmm0             ## 16-byte Folded Reload
	movdqa	-208(%rbp), %xmm1
	pxor	-16208(%rbp), %xmm1             ## 16-byte Folded Reload
	por	%xmm0, %xmm1
	ptest	%xmm1, %xmm1
	jne	LBB21_296
## %bb.98:                              ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_297
## %bb.99:                              ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r14, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.285(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_298
## %bb.100:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_299
## %bb.101:                             ##   in Loop: Header=BB21_47 Depth=1
	leaq	-15608(,%r13), %r14
	addq	%rbp, %r14
	movq	%r15, %rdi
	movq	%r14, %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_300
## %bb.102:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	leaq	-816(%rbp), %r13
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_301
## %bb.103:                             ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r13, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.220(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_302
## %bb.104:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_303
## %bb.105:                             ##   in Loop: Header=BB21_47 Depth=1
	movq	%r15, %rdi
	movq	%r14, %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_304
## %bb.106:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_305
## %bb.107:                             ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r13, %rdi
	leaq	L_.str.276(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	leaq	L_.str.265(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_306
## %bb.108:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_307
## %bb.109:                             ##   in Loop: Header=BB21_47 Depth=1
	movq	-16128(%rbp), %rax              ## 8-byte Reload
	leaq	(%rax,%rbp), %rbx
	addq	$-15448, %rbx                   ## imm = 0xC3A8
	movq	%r15, %rdi
	movq	%rbx, %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_308
## %bb.110:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_309
## %bb.111:                             ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$64, %esi
	movq	%r13, %rdi
	leaq	L_.str.276(%rip), %rdx
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rcx
	movq	%r12, %r8
	leaq	L_.str.286(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_310
## %bb.112:                             ##   in Loop: Header=BB21_47 Depth=1
	movq	%rbx, -16240(%rbp)              ## 8-byte Spill
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_311
## %bb.113:                             ##   in Loop: Header=BB21_47 Depth=1
	movq	-208(%rbp), %rax
	movabsq	$7308613637443382901, %rcx      ## imm = 0x656D69616C636E75
	xorq	%rcx, %rax
	movzwl	-200(%rbp), %ecx
	xorq	$100, %rcx
	orq	%rax, %rcx
	jne	LBB21_312
## %bb.114:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	leaq	-16112(%rbp), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_313
## %bb.115:                             ##   in Loop: Header=BB21_47 Depth=1
	leaq	L_.str.248(%rip), %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.287(%rip), %rdi
	leaq	_PI4_APP_RECORD_PREFIX(%rip), %rsi
	movq	%r12, -16224(%rbp)              ## 8-byte Spill
	movq	%r12, %rdx
	movq	-16160(%rbp), %r13              ## 8-byte Reload
	movq	%r13, %rcx
	movq	-16152(%rbp), %r8               ## 8-byte Reload
	movq	-16144(%rbp), %rbx              ## 8-byte Reload
	movq	%rbx, %r9
	xorl	%eax, %eax
	leaq	_PI4_APP_EXEC_MODEL(%rip), %r15
	pushq	%r15
	leaq	_PI4_APP_LAUNCH_MODEL(%rip), %r10
	pushq	%r10
	movq	-16240(%rbp), %r15              ## 8-byte Reload
	pushq	%r15
	pushq	%r14
	callq	_printf
	addq	$32, %rsp
	movq	-16128(%rbp), %r12              ## 8-byte Reload
	leaq	(%r12,%rbp), %r10
	addq	$-15288, %r10                   ## imm = 0xC448
	subq	$8, %rsp
	leaq	L_.str.288(%rip), %rdi
	movq	-16152(%rbp), %rsi              ## 8-byte Reload
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%r15, %r8
	movq	%r14, %r9
	xorl	%eax, %eax
	pushq	%r10
	callq	_printf
	addq	$16, %rsp
	movl	-15168(%rbp,%r12), %r9d
	movl	-15164(%rbp,%r12), %r8d
	leaq	L_.str.289(%rip), %rdi
	movq	%rbx, %rsi
	leaq	_PI4_APP_EXEC_MODEL(%rip), %rdx
	movq	%r13, %rcx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.290(%rip), %rdi
	movq	%r15, %rsi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	_printf
	cmpl	$0, -15144(%rbp,%r12)
	je	LBB21_117
## %bb.116:                             ##   in Loop: Header=BB21_47 Depth=1
	movl	-15152(%rbp,%r12), %r8d
	movl	-15148(%rbp,%r12), %ecx
	leaq	L_.str.291(%rip), %rdi
	movq	%r14, %rsi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	_printf
	jmp	LBB21_118
LBB21_49:
	leaq	L_.str.184(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	callq	_manifest_require_u64
	cmpq	$257, %rax                      ## imm = 0x101
	jae	LBB21_267
## %bb.50:
	movq	%rax, %rbx
	leaq	L_.str.184(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_268
## %bb.51:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.184(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	testq	%rbx, %rbx
	movq	-16136(%rbp), %r15              ## 8-byte Reload
	je	LBB21_54
## %bb.52:
	xorl	%r14d, %r14d
	leaq	-16112(%rbp), %r12
	leaq	-16120(%rbp), %r13
	.p2align	4
LBB21_53:                               ## =>This Inner Loop Header: Depth=1
	movq	%r15, %rdi
	movq	%r12, %rsi
	leaq	L_.str.185(%rip), %rdx
	movq	%r14, %rcx
	movq	%r13, %r8
	callq	_inspect_manifest_require_indexed_sized_file
	incq	%r14
	cmpq	%r14, %rbx
	jne	LBB21_53
LBB21_54:
	leaq	L_.str.186(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	callq	_manifest_require_u64
	cmpq	$257, %rax                      ## imm = 0x101
	jae	LBB21_314
## %bb.55:
	movq	%rax, %rbx
	leaq	L_.str.186(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_315
## %bb.56:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.186(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	testq	%rbx, %rbx
	movq	-16136(%rbp), %r15              ## 8-byte Reload
	je	LBB21_59
## %bb.57:
	xorl	%r14d, %r14d
	leaq	-16112(%rbp), %r12
	leaq	-16120(%rbp), %r13
	.p2align	4
LBB21_58:                               ## =>This Inner Loop Header: Depth=1
	movq	%r15, %rdi
	movq	%r12, %rsi
	leaq	L_.str.187(%rip), %rdx
	movq	%r14, %rcx
	movq	%r13, %r8
	callq	_inspect_manifest_require_indexed_sized_file
	incq	%r14
	cmpq	%r14, %rbx
	jne	LBB21_58
LBB21_59:
	leaq	L_.str.188(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_316
## %bb.60:
	movabsq	$4708282724724461380, %rax      ## imm = 0x41572E314D4F4F44
	xorq	-208(%rbp), %rax
	movzwl	-200(%rbp), %ecx
	xorq	$68, %rcx
	orq	%rax, %rcx
	movq	-16136(%rbp), %r14              ## 8-byte Reload
	jne	LBB21_317
## %bb.61:
	leaq	L_.str.190(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_318
## %bb.62:
	movabsq	$7233193513526980452, %rax      ## imm = 0x6461772D6D6F6F64
	xorq	-208(%rbp), %rax
	movzbl	-200(%rbp), %ecx
	orq	%rax, %rcx
	jne	LBB21_319
## %bb.63:
	leaq	L_.str.192(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_320
## %bb.64:
	movabsq	$32772479305216624, %rax        ## imm = 0x746E6573657270
	cmpq	%rax, -208(%rbp)
	jne	LBB21_321
## %bb.65:
	leaq	L_.str.194(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-848(%rbp), %rdx
	movl	$32, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_322
## %bb.66:
	leaq	L_.str.196(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-880(%rbp), %rdx
	movl	$32, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_323
## %bb.67:
	movabsq	$7809644666444609637, %rcx      ## imm = 0x6C616E7265747865
	movabsq	$3271131108425889135, %rdx      ## imm = 0x2D6564697374756F
	movabsq	$31367303424468324, %rsi        ## imm = 0x6F7065722D6564
	movq	-848(%rbp), %rax
	xorq	%rcx, %rax
	movzbl	-840(%rbp), %ecx
	orq	%rax, %rcx
	je	LBB21_68
## %bb.119:
	movdqa	-848(%rbp), %xmm0
	movzwl	-832(%rbp), %eax
	movd	%eax, %xmm1
	pxor	LCPI21_19(%rip), %xmm0
	pxor	LCPI21_20(%rip), %xmm1
	por	%xmm0, %xmm1
	ptest	%xmm1, %xmm1
	jne	LBB21_122
## %bb.120:
	movdqa	-880(%rbp), %xmm0
	movdqu	-875(%rbp), %xmm1
	pxor	LCPI21_21(%rip), %xmm1
	pxor	LCPI21_22(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	je	LBB21_123
## %bb.121:
	callq	_inspect_pi4_manifest.cold.68
LBB21_1:
	testl	%r12d, %r12d
	je	LBB21_223
## %bb.2:
	callq	_inspect_pi4_manifest.cold.191
LBB21_68:
	movq	-880(%rbp), %rax
	xorq	%rdx, %rax
	movq	-875(%rbp), %rcx
	xorq	%rsi, %rcx
	orq	%rax, %rcx
	jne	LBB21_69
LBB21_123:
	leaq	L_.str.205(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_324
## %bb.124:
	movdqa	-208(%rbp), %xmm0
	movdqu	-205(%rbp), %xmm1
	pxor	LCPI21_23(%rip), %xmm1
	pxor	LCPI21_24(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_325
## %bb.125:
	leaq	L_.str.207(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_326
## %bb.126:
	movq	-208(%rbp), %rax
	movabsq	$7308613637443382901, %rcx      ## imm = 0x656D69616C636E75
	xorq	%rcx, %rax
	movzwl	-200(%rbp), %ecx
	xorq	$100, %rcx
	orq	%rax, %rcx
	jne	LBB21_327
## %bb.127:
	leaq	L_.str.189(%rip), %rdx
	leaq	L_.str.209(%rip), %rcx
	leaq	-16112(%rbp), %rbx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.188(%rip), %rsi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_328
## %bb.128:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.188(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.190(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_329
## %bb.129:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.190(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.192(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_330
## %bb.130:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.192(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.194(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_331
## %bb.131:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.194(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.196(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_332
## %bb.132:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.196(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.205(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_333
## %bb.133:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.205(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.207(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_334
## %bb.134:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.207(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.209(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_335
## %bb.135:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.209(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.210(%rip), %rdi
	leaq	-848(%rbp), %rsi
	leaq	-880(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.211(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_336
## %bb.136:
	cmpw	$51, -208(%rbp)
	jne	LBB21_337
## %bb.137:
	leaq	L_.str.213(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_338
## %bb.138:
	movdqa	-208(%rbp), %xmm0
	movdqu	-205(%rbp), %xmm1
	pxor	LCPI21_25(%rip), %xmm1
	pxor	LCPI21_26(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_339
## %bb.139:
	leaq	_DEFAULT_PI4_ASSET_README_PATH(%rip), %rdx
	leaq	L_.str.214(%rip), %rcx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.215(%rip), %rsi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_340
## %bb.140:
	movdqa	-208(%rbp), %xmm0
	movdqu	-202(%rbp), %xmm1
	pxor	LCPI21_27(%rip), %xmm1
	pxor	LCPI21_28(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_341
## %bb.141:
	leaq	_DEFAULT_PI4_ASSET_MAP_PATH(%rip), %rdx
	leaq	L_.str.216(%rip), %rcx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.217(%rip), %rsi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_342
## %bb.142:
	movdqa	-208(%rbp), %xmm0
	movdqu	-198(%rbp), %xmm1
	pxor	LCPI21_29(%rip), %xmm1
	pxor	LCPI21_30(%rip), %xmm0
	por	%xmm1, %xmm0
	ptest	%xmm0, %xmm0
	jne	LBB21_343
## %bb.143:
	leaq	_DEFAULT_PI4_ASSET_PALETTE_PATH(%rip), %rdx
	leaq	L_.str.218(%rip), %rcx
	leaq	-16120(%rbp), %r8
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.219(%rip), %rsi
	movq	%rbx, %rdi
	callq	_manifest_require_u64
	movq	%rax, -16144(%rbp)              ## 8-byte Spill
	cmpq	$257, %rax                      ## imm = 0x101
	jae	LBB21_344
## %bb.144:
	leaq	L_.str.219(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_345
## %bb.145:
	movabsq	$7957628980220749357, %rbx      ## imm = 0x6E6F2D656C69662D
	movabsq	$7234302044551733616, %r15      ## imm = 0x646567616B636170
	movabsq	$34177693749437804, %r12        ## imm = 0x796C6E6F2D656C
	movabsq	$7594807730828173675, %r13      ## imm = 0x69662D646567616B
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.219(%rip), %rsi
	xorl	%r14d, %r14d
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	movq	%r15, %xmm0
	movdqa	%xmm0, -16208(%rbp)             ## 16-byte Spill
	movq	%rbx, %xmm0
	movdqa	%xmm0, -16272(%rbp)             ## 16-byte Spill
	movq	%r13, %xmm0
	movdqa	%xmm0, -16192(%rbp)             ## 16-byte Spill
	movq	%r12, %xmm0
	movdqa	%xmm0, -16288(%rbp)             ## 16-byte Spill
	cmpq	$0, -16144(%rbp)                ## 8-byte Folded Reload
	je	LBB21_150
## %bb.146:
	leaq	L_.str.220(%rip), %rbx
	leaq	-272(%rbp), %r15
	leaq	-16112(%rbp), %r14
	movaps	-16208(%rbp), %xmm0             ## 16-byte Reload
	unpcklpd	-16272(%rbp), %xmm0             ## 16-byte Folded Reload
                                        ## xmm0 = xmm0[0],mem[0]
	movaps	%xmm0, -16240(%rbp)             ## 16-byte Spill
	movdqa	-16192(%rbp), %xmm0             ## 16-byte Reload
	punpcklqdq	-16288(%rbp), %xmm0     ## 16-byte Folded Reload
                                        ## xmm0 = xmm0[0],mem[0]
	movdqa	%xmm0, -16224(%rbp)             ## 16-byte Spill
	xorl	%r12d, %r12d
	xorl	%r13d, %r13d
	.p2align	4
LBB21_147:                              ## =>This Inner Loop Header: Depth=1
	movl	$64, %esi
	movq	%r15, %rdi
	leaq	L_.str.294(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_148
## %bb.156:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	-336(%rbp), %rdi
	leaq	L_.str.296(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, -16128(%rbp)              ## 8-byte Spill
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_350
## %bb.157:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%r15, %rsi
	leaq	-816(%rbp), %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_351
## %bb.158:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	-400(%rbp), %rdi
	leaq	L_.str.299(%rip), %rdx
	movq	%rbx, %rcx
	movq	-16128(%rbp), %r12              ## 8-byte Reload
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	leaq	-464(%rbp), %rdi
	leaq	-656(%rbp), %r15
	jae	LBB21_352
## %bb.159:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	L_.str.300(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_353
## %bb.160:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	-528(%rbp), %rdi
	leaq	L_.str.301(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_354
## %bb.161:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	-592(%rbp), %rdi
	leaq	L_.str.302(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_355
## %bb.162:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	%r13d, -16152(%rbp)             ## 4-byte Spill
	movl	$64, %esi
	movq	%r15, %rdi
	leaq	L_.str.303(%rip), %rdx
	movq	%rbx, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB21_356
## %bb.163:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	-816(%rbp), %rax
	movabsq	$5422703589951031599, %rcx      ## imm = 0x4B41502F3144492F
	xorq	%rcx, %rax
	movq	-810(%rbp), %rcx
	movabsq	$21182435881405249, %rdx        ## imm = 0x4B41502E304B41
	xorq	%rdx, %rcx
	xorl	%ebx, %ebx
	orq	%rax, %rcx
	setne	%r15b
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-400(%rbp), %rsi
	leaq	-208(%rbp), %r13
	movq	%r13, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	leaq	-528(%rbp), %r12
	je	LBB21_357
## %bb.164:                             ##   in Loop: Header=BB21_147 Depth=1
	movb	%r15b, %bl
	testl	%ebx, %ebx
	leaq	L_.str.306(%rip), %rsi
	leaq	L_.str.305(%rip), %rax
	cmoveq	%rax, %rsi
	movq	%r13, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_358
## %bb.165:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-464(%rbp), %rsi
	movq	%r13, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_359
## %bb.166:                             ##   in Loop: Header=BB21_147 Depth=1
	movd	-192(%rbp), %xmm0               ## xmm0 = mem[0],zero,zero,zero
	pxor	LCPI21_31(%rip), %xmm0
	movdqa	-208(%rbp), %xmm1
	pxor	LCPI21_32(%rip), %xmm1
	por	%xmm0, %xmm1
	ptest	%xmm1, %xmm1
	jne	LBB21_360
## %bb.167:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	-816(%rbp), %rax
	movabsq	$5422703589951031599, %rcx      ## imm = 0x4B41502F3144492F
	xorq	%rcx, %rax
	movq	-810(%rbp), %rcx
	movabsq	$21182435881405249, %rdx        ## imm = 0x4B41502E304B41
	xorq	%rdx, %rcx
	xorl	%ebx, %ebx
	orq	%rax, %rcx
	setne	%r15b
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_361
## %bb.168:                             ##   in Loop: Header=BB21_147 Depth=1
	movb	%r15b, %bl
	testl	%ebx, %ebx
	leaq	L_.str.307(%rip), %rsi
	leaq	L_.str.199(%rip), %rax
	cmoveq	%rax, %rsi
	movq	%r13, %rdi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB21_362
## %bb.169:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-592(%rbp), %rsi
	movq	%r13, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	leaq	-656(%rbp), %rsi
	je	LBB21_363
## %bb.170:                             ##   in Loop: Header=BB21_147 Depth=1
	movdqu	-205(%rbp), %xmm0
	pxor	-16224(%rbp), %xmm0             ## 16-byte Folded Reload
	movdqa	-208(%rbp), %xmm1
	pxor	-16240(%rbp), %xmm1             ## 16-byte Folded Reload
	por	%xmm0, %xmm1
	ptest	%xmm1, %xmm1
	jne	LBB21_364
## %bb.171:                             ##   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%r13, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_365
## %bb.172:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	-208(%rbp), %rax
	movabsq	$7308613637443382901, %rcx      ## imm = 0x656D69616C636E75
	xorq	%rcx, %rax
	movzwl	-200(%rbp), %ecx
	xorq	$100, %rcx
	orq	%rax, %rcx
	jne	LBB21_366
## %bb.173:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	-16136(%rbp), %rdi              ## 8-byte Reload
	movq	%r14, %rsi
	leaq	-816(%rbp), %rdx
	leaq	-336(%rbp), %rcx
	leaq	-16120(%rbp), %r8
	callq	_inspect_manifest_require_file
	movq	-816(%rbp), %rax
	movabsq	$5422703589951031599, %rcx      ## imm = 0x4B41502F3144492F
	xorq	%rcx, %rax
	movq	-810(%rbp), %rcx
	movabsq	$21182435881405249, %rdx        ## imm = 0x4B41502E304B41
	xorq	%rdx, %rcx
	orq	%rax, %rcx
	setne	%r15b
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-272(%rbp), %r13
	movq	%r13, %rsi
	leaq	-208(%rbp), %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_367
## %bb.174:                             ##   in Loop: Header=BB21_147 Depth=1
	leaq	L_.str.248(%rip), %rbx
	movq	%rbx, %rdi
	movq	%r13, %rsi
	leaq	-208(%rbp), %r12
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-400(%rbp), %r13
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_368
## %bb.175:                             ##   in Loop: Header=BB21_147 Depth=1
	movb	%r15b, -16160(%rbp)             ## 1-byte Spill
	movq	%rbx, %rdi
	movq	%r13, %rsi
	leaq	-208(%rbp), %r15
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-464(%rbp), %r13
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_369
## %bb.176:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-528(%rbp), %r12
	movq	%r12, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	leaq	-656(%rbp), %r15
	je	LBB21_370
## %bb.177:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%r12, %rsi
	leaq	-208(%rbp), %r13
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	-592(%rbp), %r12
	movq	%r12, %rsi
	movq	%r13, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	movl	-16152(%rbp), %r13d             ## 4-byte Reload
	je	LBB21_371
## %bb.178:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%r12, %rsi
	leaq	-208(%rbp), %r12
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	leaq	-336(%rbp), %r12
	je	LBB21_372
## %bb.179:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%r15, %rsi
	leaq	-208(%rbp), %r15
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	_printf
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_373
## %bb.180:                             ##   in Loop: Header=BB21_147 Depth=1
	movq	%r15, %rdx
	xorl	%r15d, %r15d
	movzbl	-16160(%rbp), %eax              ## 1-byte Folded Reload
	movb	%al, %r15b
	movq	%rbx, %rdi
	movq	%r12, %rsi
	xorl	%eax, %eax
	callq	_printf
	testl	%r15d, %r15d
	movl	$1, %eax
	cmovel	%eax, %r13d
	movq	-16128(%rbp), %r12              ## 8-byte Reload
	incq	%r12
	cmpq	%r12, -16144(%rbp)              ## 8-byte Folded Reload
	leaq	L_.str.220(%rip), %rbx
	leaq	-272(%rbp), %r15
	jne	LBB21_147
## %bb.149:
	testl	%r13d, %r13d
	setne	%r14b
LBB21_150:
	leaq	L_.str.221(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_346
## %bb.151:
	movabsq	$5422703589951031599, %rax      ## imm = 0x4B41502F3144492F
	xorq	-208(%rbp), %rax
	movabsq	$21182435881405249, %rcx        ## imm = 0x4B41502E304B41
	xorq	-202(%rbp), %rcx
	orq	%rax, %rcx
	movl	-16164(%rbp), %r12d             ## 4-byte Reload
	movabsq	$32772479305216624, %r13        ## imm = 0x746E6573657270
	jne	LBB21_347
## %bb.152:
	leaq	L_.str.222(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_348
## %bb.153:
	movabsq	$7021161732687099249, %rax      ## imm = 0x61702D656B617571
	xorq	-208(%rbp), %rax
	movzwl	-200(%rbp), %ecx
	xorq	$107, %rcx
	orq	%rax, %rcx
	jne	LBB21_349
## %bb.154:
	leaq	L_.str.224(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-816(%rbp), %rdx
	movl	$32, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_155
## %bb.181:
	movl	$1702060641, %eax               ## imm = 0x65736261
	xorl	-816(%rbp), %eax
	movl	$7630437, %r15d                 ## imm = 0x746E65
	xorl	-813(%rbp), %r15d
	orl	%eax, %r15d
	je	LBB21_182
## %bb.198:
	cmpq	%r13, -816(%rbp)
	jne	LBB21_405
## %bb.199:
	leaq	L_.str.227(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_389
## %bb.200:
	movq	-208(%rbp), %rax
	movabsq	$7809644666444609637, %rcx      ## imm = 0x6C616E7265747865
	xorq	%rcx, %rax
	movzbl	-200(%rbp), %ecx
	orq	%rax, %rcx
	jne	LBB21_390
## %bb.201:
	leaq	L_.str.228(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_391
## %bb.202:
	movq	-208(%rbp), %rax
	movabsq	$3271131108425889135, %rcx      ## imm = 0x2D6564697374756F
	xorq	%rcx, %rax
	movq	-203(%rbp), %rcx
	movabsq	$31367303424468324, %rdx        ## imm = 0x6F7065722D6564
	xorq	%rdx, %rcx
	orq	%rax, %rcx
	jne	LBB21_392
## %bb.203:
	leaq	L_.str.229(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_393
## %bb.204:
	movdqa	-16208(%rbp), %xmm1             ## 16-byte Reload
	punpcklqdq	-16272(%rbp), %xmm1     ## 16-byte Folded Reload
                                        ## xmm1 = xmm1[0],mem[0]
	movdqu	-205(%rbp), %xmm0
	movdqa	-16192(%rbp), %xmm2             ## 16-byte Reload
	punpcklqdq	-16288(%rbp), %xmm2     ## 16-byte Folded Reload
                                        ## xmm2 = xmm2[0],mem[0]
	pxor	-208(%rbp), %xmm1
	pxor	%xmm0, %xmm2
	por	%xmm2, %xmm1
	ptest	%xmm1, %xmm1
	jne	LBB21_394
## %bb.205:
	leaq	L_.str.230(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_395
## %bb.206:
	movabsq	$7308613637443382901, %rcx      ## imm = 0x656D69616C636E75
	xorq	-208(%rbp), %rcx
	movzwl	-200(%rbp), %eax
	xorq	$100, %rax
	orq	%rcx, %rax
	jne	LBB21_396
## %bb.207:
	leaq	_PROOF_QUAKE_PAK_PATH(%rip), %rdx
	leaq	L_.str.232(%rip), %rcx
	leaq	-16112(%rbp), %rbx
	leaq	-16120(%rbp), %r8
	movq	-16136(%rbp), %rdi              ## 8-byte Reload
	movq	%rbx, %rsi
	callq	_inspect_manifest_require_file
	leaq	L_.str.221(%rip), %rsi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_397
## %bb.208:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.221(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.222(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_398
## %bb.209:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.222(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.224(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_399
## %bb.210:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.224(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.227(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_400
## %bb.211:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.227(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.228(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_401
## %bb.212:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.228(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.229(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_402
## %bb.213:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.229(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.230(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_403
## %bb.214:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.230(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.232(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_404
## %bb.215:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.232(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.233(%rip), %rdi
	jmp	LBB21_216
LBB21_182:
	leaq	L_.str.227(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_374
## %bb.183:
	movl	$1702060641, %eax               ## imm = 0x65736261
	xorl	-208(%rbp), %eax
	movl	$7630437, %ecx                  ## imm = 0x746E65
	xorl	-205(%rbp), %ecx
	orl	%eax, %ecx
	jne	LBB21_375
## %bb.184:
	leaq	L_.str.228(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_376
## %bb.185:
	movl	$1702060641, %eax               ## imm = 0x65736261
	xorl	-208(%rbp), %eax
	movl	$7630437, %ecx                  ## imm = 0x746E65
	xorl	-205(%rbp), %ecx
	orl	%eax, %ecx
	jne	LBB21_377
## %bb.186:
	leaq	L_.str.229(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_378
## %bb.187:
	movl	$1702060641, %eax               ## imm = 0x65736261
	xorl	-208(%rbp), %eax
	movl	$7630437, %ecx                  ## imm = 0x746E65
	xorl	-205(%rbp), %ecx
	orl	%eax, %ecx
	jne	LBB21_379
## %bb.188:
	leaq	L_.str.230(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_380
## %bb.189:
	movabsq	$7308613637443382901, %rcx      ## imm = 0x656D69616C636E75
	xorq	-208(%rbp), %rcx
	movzwl	-200(%rbp), %eax
	xorq	$100, %rax
	orq	%rcx, %rax
	jne	LBB21_381
## %bb.190:
	leaq	L_.str.221(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_382
## %bb.191:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.221(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.222(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_383
## %bb.192:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.222(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.224(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_384
## %bb.193:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.224(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.227(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_385
## %bb.194:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.227(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.228(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_386
## %bb.195:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.228(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.229(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_387
## %bb.196:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.229(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.230(%rip), %rsi
	leaq	-16112(%rbp), %rdi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB21_388
## %bb.197:
	leaq	L_.str.248(%rip), %rdi
	leaq	L_.str.230(%rip), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	L_.str.231(%rip), %rdi
LBB21_216:
	leaq	_PROOF_QUAKE_PAK_PATH(%rip), %rsi
	xorl	%eax, %eax
	callq	_printf
	cmpq	%r13, -816(%rbp)
	leaq	L_.str.206(%rip), %rax
	leaq	L_.str.226(%rip), %rcx
	cmoveq	%rax, %rcx
	leaq	L_.str.235(%rip), %rdi
	leaq	-848(%rbp), %rsi
	leaq	-816(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	testl	%r12d, %r12d
	je	LBB21_222
## %bb.217:
	movabsq	$7809644666444609637, %rcx      ## imm = 0x6C616E7265747865
	xorq	-848(%rbp), %rcx
	movzbl	-840(%rbp), %eax
	orq	%rcx, %rax
	jne	LBB21_406
## %bb.218:
	movabsq	$3271131108425889135, %rax      ## imm = 0x2D6564697374756F
	xorq	-880(%rbp), %rax
	movabsq	$31367303424468324, %rcx        ## imm = 0x6F7065722D6564
	xorq	-875(%rbp), %rcx
	orq	%rax, %rcx
	jne	LBB21_406
## %bb.219:
	cmpq	%r13, -816(%rbp)
	jne	LBB21_407
## %bb.220:
	testl	%r15d, %r15d
	setne	%al
	testb	%al, %r14b
	je	LBB21_408
## %bb.221:
	leaq	L_str.516(%rip), %rdi
	callq	_puts
LBB21_222:
	movq	-16120(%rbp), %rsi
	leaq	L_.str.240(%rip), %rdi
	xorl	%eax, %eax
	callq	_printf
	movq	-16248(%rbp), %rdi              ## 8-byte Reload
	callq	_free
LBB21_223:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB21_409
## %bb.224:
	addq	$16264, %rsp                    ## imm = 0x3F88
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB21_48:
	callq	_inspect_pi4_manifest.cold.63
LBB21_269:
	callq	_inspect_pi4_manifest.cold.62
LBB21_271:
	callq	_inspect_pi4_manifest.cold.61
LBB21_272:
	callq	_inspect_pi4_manifest.cold.60
LBB21_273:
	callq	_inspect_pi4_manifest.cold.59
LBB21_275:
	callq	_inspect_pi4_manifest.cold.58
LBB21_276:
	callq	_inspect_pi4_manifest.cold.57
LBB21_277:
	callq	_inspect_pi4_manifest.cold.56
LBB21_279:
	callq	_inspect_pi4_manifest.cold.55
LBB21_280:
	callq	_inspect_pi4_manifest.cold.54
LBB21_282:
	callq	_inspect_pi4_manifest.cold.53
LBB21_283:
	callq	_inspect_pi4_manifest.cold.52
LBB21_284:
	callq	_inspect_pi4_manifest.cold.51
LBB21_281:
	callq	_inspect_pi4_manifest.cold.21
LBB21_278:
	callq	_inspect_pi4_manifest.cold.20
LBB21_274:
	callq	_inspect_pi4_manifest.cold.19
LBB21_270:
	callq	_inspect_pi4_manifest.cold.18
LBB21_286:
	callq	_inspect_pi4_manifest.cold.50
LBB21_287:
	callq	_inspect_pi4_manifest.cold.49
LBB21_289:
	callq	_inspect_pi4_manifest.cold.48
LBB21_290:
	callq	_inspect_pi4_manifest.cold.47
LBB21_291:
	callq	_inspect_pi4_manifest.cold.46
LBB21_293:
	callq	_inspect_pi4_manifest.cold.45
LBB21_294:
	callq	_inspect_pi4_manifest.cold.44
LBB21_295:
	callq	_inspect_pi4_manifest.cold.43
LBB21_297:
	callq	_inspect_pi4_manifest.cold.42
LBB21_298:
	callq	_inspect_pi4_manifest.cold.41
LBB21_299:
	callq	_inspect_pi4_manifest.cold.40
LBB21_301:
	callq	_inspect_pi4_manifest.cold.39
LBB21_302:
	callq	_inspect_pi4_manifest.cold.38
LBB21_303:
	callq	_inspect_pi4_manifest.cold.37
LBB21_305:
	callq	_inspect_pi4_manifest.cold.36
LBB21_306:
	callq	_inspect_pi4_manifest.cold.35
LBB21_307:
	callq	_inspect_pi4_manifest.cold.34
LBB21_309:
	callq	_inspect_pi4_manifest.cold.33
LBB21_310:
	callq	_inspect_pi4_manifest.cold.32
LBB21_311:
	callq	_inspect_pi4_manifest.cold.31
LBB21_313:
	callq	_inspect_pi4_manifest.cold.30
LBB21_312:
	callq	_inspect_pi4_manifest.cold.29
LBB21_308:
	callq	_inspect_pi4_manifest.cold.28
LBB21_304:
	callq	_inspect_pi4_manifest.cold.27
LBB21_300:
	callq	_inspect_pi4_manifest.cold.26
LBB21_296:
	callq	_inspect_pi4_manifest.cold.25
LBB21_292:
	callq	_inspect_pi4_manifest.cold.24
LBB21_288:
	callq	_inspect_pi4_manifest.cold.23
LBB21_285:
	callq	_inspect_pi4_manifest.cold.22
LBB21_364:
	callq	_inspect_pi4_manifest.cold.79
LBB21_362:
	callq	_inspect_pi4_manifest.cold.78
LBB21_360:
	callq	_inspect_pi4_manifest.cold.77
LBB21_358:
	callq	_inspect_pi4_manifest.cold.76
LBB21_363:
	callq	_inspect_pi4_manifest.cold.89
LBB21_353:
	callq	_inspect_pi4_manifest.cold.96
LBB21_365:
	callq	_inspect_pi4_manifest.cold.88
LBB21_359:
	callq	_inspect_pi4_manifest.cold.91
LBB21_351:
	callq	_inspect_pi4_manifest.cold.98
LBB21_352:
	callq	_inspect_pi4_manifest.cold.97
LBB21_356:
	callq	_inspect_pi4_manifest.cold.93
LBB21_148:
	callq	_inspect_pi4_manifest.cold.100
LBB21_350:
	callq	_inspect_pi4_manifest.cold.99
LBB21_354:
	callq	_inspect_pi4_manifest.cold.95
LBB21_355:
	callq	_inspect_pi4_manifest.cold.94
LBB21_357:
	callq	_inspect_pi4_manifest.cold.92
LBB21_361:
	callq	_inspect_pi4_manifest.cold.90
LBB21_366:
	callq	_inspect_pi4_manifest.cold.80
LBB21_371:
	callq	_inspect_pi4_manifest.cold.83
LBB21_370:
	callq	_inspect_pi4_manifest.cold.84
LBB21_369:
	callq	_inspect_pi4_manifest.cold.85
LBB21_368:
	callq	_inspect_pi4_manifest.cold.86
LBB21_372:
	callq	_inspect_pi4_manifest.cold.82
LBB21_367:
	callq	_inspect_pi4_manifest.cold.87
LBB21_373:
	callq	_inspect_pi4_manifest.cold.81
LBB21_409:
	callq	___stack_chk_fail
LBB21_406:
	callq	_inspect_pi4_manifest.cold.123
LBB21_225:
	callq	_inspect_pi4_manifest.cold.190
LBB21_226:
	callq	_inspect_pi4_manifest.cold.1
LBB21_227:
	callq	_inspect_pi4_manifest.cold.189
LBB21_228:
	callq	_inspect_pi4_manifest.cold.2
LBB21_229:
	callq	_inspect_pi4_manifest.cold.3
LBB21_230:
	callq	_inspect_pi4_manifest.cold.4
LBB21_231:
	callq	_inspect_pi4_manifest.cold.5
LBB21_232:
	callq	_inspect_pi4_manifest.cold.188
LBB21_233:
	callq	_inspect_pi4_manifest.cold.6
LBB21_234:
	callq	_inspect_pi4_manifest.cold.187
LBB21_235:
	callq	_inspect_pi4_manifest.cold.7
LBB21_236:
	callq	_inspect_pi4_manifest.cold.186
LBB21_237:
	callq	_inspect_pi4_manifest.cold.185
LBB21_238:
	callq	_inspect_pi4_manifest.cold.8
LBB21_239:
	callq	_inspect_pi4_manifest.cold.184
LBB21_240:
	callq	_inspect_pi4_manifest.cold.183
LBB21_241:
	callq	_inspect_pi4_manifest.cold.9
LBB21_242:
	callq	_inspect_pi4_manifest.cold.182
LBB21_243:
	callq	_inspect_pi4_manifest.cold.181
LBB21_244:
	callq	_inspect_pi4_manifest.cold.10
LBB21_245:
	callq	_inspect_pi4_manifest.cold.180
LBB21_246:
	callq	_inspect_pi4_manifest.cold.179
LBB21_247:
	callq	_inspect_pi4_manifest.cold.11
LBB21_248:
	callq	_inspect_pi4_manifest.cold.178
LBB21_249:
	callq	_inspect_pi4_manifest.cold.177
LBB21_250:
	callq	_inspect_pi4_manifest.cold.12
LBB21_251:
	callq	_inspect_pi4_manifest.cold.176
LBB21_252:
	callq	_inspect_pi4_manifest.cold.175
LBB21_253:
	callq	_inspect_pi4_manifest.cold.13
LBB21_254:
	callq	_inspect_pi4_manifest.cold.174
LBB21_255:
	callq	_inspect_pi4_manifest.cold.173
LBB21_256:
	callq	_inspect_pi4_manifest.cold.14
LBB21_257:
	callq	_inspect_pi4_manifest.cold.172
LBB21_258:
	callq	_inspect_pi4_manifest.cold.171
LBB21_259:
	callq	_inspect_pi4_manifest.cold.15
LBB21_260:
	callq	_inspect_pi4_manifest.cold.170
LBB21_261:
	callq	_inspect_pi4_manifest.cold.169
LBB21_262:
	callq	_inspect_pi4_manifest.cold.16
LBB21_263:
	callq	_inspect_pi4_manifest.cold.168
LBB21_264:
	callq	_inspect_pi4_manifest.cold.167
LBB21_265:
	callq	_inspect_pi4_manifest.cold.17
LBB21_266:
	callq	_inspect_pi4_manifest.cold.166
LBB21_267:
	callq	_inspect_pi4_manifest.cold.165
LBB21_268:
	callq	_inspect_pi4_manifest.cold.164
LBB21_314:
	callq	_inspect_pi4_manifest.cold.163
LBB21_315:
	callq	_inspect_pi4_manifest.cold.162
LBB21_316:
	callq	_inspect_pi4_manifest.cold.161
LBB21_317:
	callq	_inspect_pi4_manifest.cold.64
LBB21_318:
	callq	_inspect_pi4_manifest.cold.160
LBB21_319:
	callq	_inspect_pi4_manifest.cold.65
LBB21_320:
	callq	_inspect_pi4_manifest.cold.159
LBB21_321:
	callq	_inspect_pi4_manifest.cold.66
LBB21_322:
	callq	_inspect_pi4_manifest.cold.158
LBB21_323:
	callq	_inspect_pi4_manifest.cold.157
LBB21_324:
	callq	_inspect_pi4_manifest.cold.156
LBB21_325:
	callq	_inspect_pi4_manifest.cold.70
LBB21_326:
	callq	_inspect_pi4_manifest.cold.155
LBB21_327:
	callq	_inspect_pi4_manifest.cold.71
LBB21_328:
	callq	_inspect_pi4_manifest.cold.154
LBB21_329:
	callq	_inspect_pi4_manifest.cold.153
LBB21_330:
	callq	_inspect_pi4_manifest.cold.152
LBB21_331:
	callq	_inspect_pi4_manifest.cold.151
LBB21_332:
	callq	_inspect_pi4_manifest.cold.150
LBB21_333:
	callq	_inspect_pi4_manifest.cold.149
LBB21_334:
	callq	_inspect_pi4_manifest.cold.148
LBB21_335:
	callq	_inspect_pi4_manifest.cold.147
LBB21_336:
	callq	_inspect_pi4_manifest.cold.146
LBB21_337:
	callq	_inspect_pi4_manifest.cold.72
LBB21_338:
	callq	_inspect_pi4_manifest.cold.145
LBB21_339:
	callq	_inspect_pi4_manifest.cold.73
LBB21_340:
	callq	_inspect_pi4_manifest.cold.144
LBB21_341:
	callq	_inspect_pi4_manifest.cold.74
LBB21_342:
	callq	_inspect_pi4_manifest.cold.143
LBB21_343:
	callq	_inspect_pi4_manifest.cold.75
LBB21_344:
	callq	_inspect_pi4_manifest.cold.142
LBB21_345:
	callq	_inspect_pi4_manifest.cold.141
LBB21_346:
	callq	_inspect_pi4_manifest.cold.140
LBB21_347:
	callq	_inspect_pi4_manifest.cold.101
LBB21_348:
	callq	_inspect_pi4_manifest.cold.139
LBB21_349:
	callq	_inspect_pi4_manifest.cold.102
LBB21_155:
	callq	_inspect_pi4_manifest.cold.138
LBB21_122:
	callq	_inspect_pi4_manifest.cold.67
LBB21_405:
	callq	_inspect_pi4_manifest.cold.118
LBB21_389:
	callq	_inspect_pi4_manifest.cold.137
LBB21_390:
	callq	_inspect_pi4_manifest.cold.119
LBB21_391:
	callq	_inspect_pi4_manifest.cold.136
LBB21_392:
	callq	_inspect_pi4_manifest.cold.120
LBB21_393:
	callq	_inspect_pi4_manifest.cold.135
LBB21_394:
	callq	_inspect_pi4_manifest.cold.121
LBB21_395:
	callq	_inspect_pi4_manifest.cold.134
LBB21_396:
	callq	_inspect_pi4_manifest.cold.122
LBB21_397:
	callq	_inspect_pi4_manifest.cold.133
LBB21_398:
	callq	_inspect_pi4_manifest.cold.132
LBB21_399:
	callq	_inspect_pi4_manifest.cold.131
LBB21_400:
	callq	_inspect_pi4_manifest.cold.130
LBB21_401:
	callq	_inspect_pi4_manifest.cold.129
LBB21_402:
	callq	_inspect_pi4_manifest.cold.128
LBB21_403:
	callq	_inspect_pi4_manifest.cold.127
LBB21_404:
	callq	_inspect_pi4_manifest.cold.126
LBB21_407:
	callq	_inspect_pi4_manifest.cold.124
LBB21_408:
	callq	_inspect_pi4_manifest.cold.125
LBB21_69:
	callq	_inspect_pi4_manifest.cold.69
LBB21_374:
	callq	_inspect_pi4_manifest.cold.117
LBB21_375:
	callq	_inspect_pi4_manifest.cold.103
LBB21_376:
	callq	_inspect_pi4_manifest.cold.116
LBB21_377:
	callq	_inspect_pi4_manifest.cold.104
LBB21_378:
	callq	_inspect_pi4_manifest.cold.115
LBB21_379:
	callq	_inspect_pi4_manifest.cold.105
LBB21_380:
	callq	_inspect_pi4_manifest.cold.114
LBB21_381:
	callq	_inspect_pi4_manifest.cold.106
LBB21_382:
	callq	_inspect_pi4_manifest.cold.113
LBB21_383:
	callq	_inspect_pi4_manifest.cold.112
LBB21_384:
	callq	_inspect_pi4_manifest.cold.111
LBB21_385:
	callq	_inspect_pi4_manifest.cold.110
LBB21_386:
	callq	_inspect_pi4_manifest.cold.109
LBB21_387:
	callq	_inspect_pi4_manifest.cold.108
LBB21_388:
	callq	_inspect_pi4_manifest.cold.107
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_find_path
_inspect_find_path:                     ## @inspect_find_path
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$120, %rsp
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	movq	(%rdi), %rax
	leaq	1311232(%rax), %r8
	addq	$1311232, %rax                  ## imm = 0x140200
	movl	$16352, %ebx                    ## imm = 0x3FE0
	movq	%rsi, %r14
	jmp	LBB22_1
	.p2align	4
LBB22_42:                               ##   in Loop: Header=BB22_1 Depth=1
	incq	%r14
LBB22_1:                                ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB22_6 Depth 2
                                        ##     Child Loop BB22_24 Depth 2
                                        ##     Child Loop BB22_35 Depth 2
	movzbl	(%r14), %ecx
	cmpl	$47, %ecx
	je	LBB22_42
## %bb.2:                               ##   in Loop: Header=BB22_1 Depth=1
	cmpl	$92, %ecx
	je	LBB22_42
## %bb.3:                               ##   in Loop: Header=BB22_1 Depth=1
	testl	%ecx, %ecx
	je	LBB22_31
## %bb.4:                               ##   in Loop: Header=BB22_1 Depth=1
	movq	%rax, -144(%rbp)                ## 8-byte Spill
	movq	%rsi, -136(%rbp)                ## 8-byte Spill
	xorl	%eax, %eax
	movq	%rdx, -152(%rbp)                ## 8-byte Spill
	testb	%cl, %cl
	je	LBB22_22
LBB22_6:                                ##   Parent Loop BB22_1 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	%cl, %esi
	cmpl	$47, %esi
	je	LBB22_22
## %bb.7:                               ##   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %esi
	je	LBB22_22
## %bb.8:                               ##   in Loop: Header=BB22_6 Depth=2
	movb	%cl, -128(%rbp,%rax)
	movzbl	1(%r14,%rax), %ecx
	testl	%ecx, %ecx
	je	LBB22_21
## %bb.9:                               ##   in Loop: Header=BB22_6 Depth=2
	cmpl	$47, %ecx
	je	LBB22_21
## %bb.10:                              ##   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %ecx
	je	LBB22_21
## %bb.11:                              ##   in Loop: Header=BB22_6 Depth=2
	movb	%cl, -127(%rbp,%rax)
	movzbl	2(%r14,%rax), %ecx
	testl	%ecx, %ecx
	je	LBB22_20
## %bb.12:                              ##   in Loop: Header=BB22_6 Depth=2
	cmpl	$47, %ecx
	je	LBB22_20
## %bb.13:                              ##   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %ecx
	je	LBB22_20
## %bb.14:                              ##   in Loop: Header=BB22_6 Depth=2
	movb	%cl, -126(%rbp,%rax)
	movzbl	3(%r14,%rax), %ecx
	testl	%ecx, %ecx
	je	LBB22_19
## %bb.15:                              ##   in Loop: Header=BB22_6 Depth=2
	cmpl	$47, %ecx
	je	LBB22_19
## %bb.16:                              ##   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %ecx
	je	LBB22_19
## %bb.17:                              ##   in Loop: Header=BB22_6 Depth=2
	cmpq	$60, %rax
	je	LBB22_43
## %bb.18:                              ##   in Loop: Header=BB22_6 Depth=2
	movb	%cl, -125(%rbp,%rax)
	movzbl	4(%r14,%rax), %ecx
	addq	$4, %rax
	testb	%cl, %cl
	jne	LBB22_6
LBB22_22:                               ##   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	jmp	LBB22_23
LBB22_21:                               ##   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	incq	%r14
	incq	%rax
	jmp	LBB22_23
LBB22_20:                               ##   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	addq	$2, %r14
	addq	$2, %rax
	jmp	LBB22_23
LBB22_19:                               ##   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	addq	$3, %r14
	addq	$3, %rax
LBB22_23:                               ##   in Loop: Header=BB22_1 Depth=1
	movb	$0, -128(%rbp,%rax)
	movl	$1, %r15d
	xorl	%r13d, %r13d
	movq	%r8, -160(%rbp)                 ## 8-byte Spill
	jmp	LBB22_24
	.p2align	4
LBB22_30:                               ##   in Loop: Header=BB22_24 Depth=2
	movl	%r15d, %r13d
	shlq	$5, %r13
	incl	%r15d
	cmpq	%rbx, %r13
	ja	LBB22_31
LBB22_24:                               ##   Parent Loop BB22_1 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	(%r8,%r13), %eax
	cmpl	$46, %eax
	je	LBB22_30
## %bb.25:                              ##   in Loop: Header=BB22_24 Depth=2
	cmpl	$229, %eax
	je	LBB22_30
## %bb.26:                              ##   in Loop: Header=BB22_24 Depth=2
	testl	%eax, %eax
	je	LBB22_32
## %bb.27:                              ##   in Loop: Header=BB22_24 Depth=2
	addq	%r8, %r13
	cmpb	$15, 11(%r13)
	je	LBB22_30
## %bb.28:                              ##   in Loop: Header=BB22_24 Depth=2
	movq	%r13, %rdi
	leaq	-61(%rbp), %r12
	movq	%r12, %rsi
	callq	_format_fat_name
	movq	%r12, %rdi
	leaq	-128(%rbp), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB22_34
## %bb.29:                              ##   in Loop: Header=BB22_24 Depth=2
	movq	-160(%rbp), %r8                 ## 8-byte Reload
	jmp	LBB22_30
LBB22_34:                               ##   in Loop: Header=BB22_1 Depth=1
	movzbl	11(%r13), %eax
	movzwl	26(%r13), %r8d
	movl	28(%r13), %ecx
	movq	%r14, %rdi
	movq	-152(%rbp), %rdx                ## 8-byte Reload
	jmp	LBB22_35
	.p2align	4
LBB22_44:                               ##   in Loop: Header=BB22_35 Depth=2
	incq	%rdi
LBB22_35:                               ##   Parent Loop BB22_1 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	(%rdi), %esi
	cmpl	$47, %esi
	je	LBB22_44
## %bb.36:                              ##   in Loop: Header=BB22_35 Depth=2
	cmpl	$92, %esi
	je	LBB22_44
## %bb.37:                              ##   in Loop: Header=BB22_1 Depth=1
	testl	%esi, %esi
	je	LBB22_38
## %bb.39:                              ##   in Loop: Header=BB22_1 Depth=1
	testb	$16, %al
	je	LBB22_31
## %bb.40:                              ##   in Loop: Header=BB22_1 Depth=1
	movl	%r8d, %eax
	addl	$-65375, %eax                   ## imm = 0xFFFF00A1
	cmpl	$-65374, %eax                   ## imm = 0xFFFF00A2
	jbe	LBB22_45
## %bb.41:                              ##   in Loop: Header=BB22_1 Depth=1
	shll	$13, %r8d
	movq	-144(%rbp), %rax                ## 8-byte Reload
	addq	%rax, %r8
	movl	$8160, %ebx                     ## imm = 0x1FE0
	movq	-136(%rbp), %rsi                ## 8-byte Reload
	jmp	LBB22_1
LBB22_31:
	xorl	%eax, %eax
LBB22_32:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rcx
	movq	(%rcx), %rcx
	cmpq	-48(%rbp), %rcx
	jne	LBB22_46
## %bb.33:
	addq	$120, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB22_38:
	movl	$1, (%rdx)
	movb	%al, 4(%rdx)
	movw	$0, 5(%rdx)
	movb	$0, 7(%rdx)
	movl	%r8d, 8(%rdx)
	movl	%ecx, 12(%rdx)
	movl	$1, %eax
	jmp	LBB22_32
LBB22_43:
	callq	_inspect_find_path.cold.1
LBB22_46:
	callq	___stack_chk_fail
LBB22_45:
	leaq	L_.str.152(%rip), %rsi
	movq	-136(%rbp), %rdi                ## 8-byte Reload
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_read_file_blob
_inspect_read_file_blob:                ## @inspect_read_file_blob
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movq	%rdx, -48(%rbp)                 ## 8-byte Spill
	movq	%rsi, %r13
	movq	%rdi, -72(%rbp)                 ## 8-byte Spill
	movl	12(%rsi), %ebx
	leaq	1(%rbx), %rdi
	movl	$1, %esi
	callq	_calloc
	movq	%rax, -64(%rbp)                 ## 8-byte Spill
	testq	%rax, %rax
	je	LBB23_11
## %bb.1:
	movq	%rbx, -56(%rbp)                 ## 8-byte Spill
	testq	%rbx, %rbx
	je	LBB23_10
## %bb.2:
	testb	$16, 4(%r13)
	jne	LBB23_12
## %bb.3:
	movl	8(%r13), %ebx
	leal	-65375(%rbx), %eax
	cmpl	$-65373, %eax                   ## imm = 0xFFFF00A3
	jb	LBB23_13
## %bb.4:
	movl	$65375, %r15d                   ## imm = 0xFF5F
	xorl	%r12d, %r12d
	.p2align	4
LBB23_5:                                ## =>This Inner Loop Header: Depth=1
	leal	-65375(%rbx), %eax
	cmpl	$-65373, %eax                   ## imm = 0xFFFF00A3
	jb	LBB23_14
## %bb.6:                               ##   in Loop: Header=BB23_5 Depth=1
	decl	%r15d
	je	LBB23_14
## %bb.7:                               ##   in Loop: Header=BB23_5 Depth=1
	movq	-72(%rbp), %rax                 ## 8-byte Reload
	movq	(%rax), %r14
	movq	-56(%rbp), %r13                 ## 8-byte Reload
	subq	%r12, %r13
	cmpq	$8192, %r13                     ## imm = 0x2000
	movl	$8192, %eax                     ## imm = 0x2000
	cmovaeq	%rax, %r13
	movq	-64(%rbp), %rax                 ## 8-byte Reload
	leaq	(%rax,%r12), %rdi
	movl	%ebx, %eax
	shll	$13, %eax
	leaq	(%r14,%rax), %rsi
	addq	$1311232, %rsi                  ## imm = 0x140200
	movq	%r13, %rdx
	callq	_memcpy
	addq	%r13, %r12
	cmpq	-56(%rbp), %r12                 ## 8-byte Folded Reload
	jae	LBB23_10
## %bb.8:                               ##   in Loop: Header=BB23_5 Depth=1
	movl	%ebx, %eax
	movzwl	1049088(%r14,%rax,2), %ebx
	cmpl	$65528, %ebx                    ## imm = 0xFFF8
	jb	LBB23_5
## %bb.9:
	leaq	L_.str.75(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB23_10:
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
LBB23_14:
	leaq	L_.str.74(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB23_11:
	callq	_inspect_read_file_blob.cold.1
LBB23_12:
	leaq	L_.str.241(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB23_13:
	leaq	L_.str.73(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_file
_inspect_manifest_require_file:         ## @inspect_manifest_require_file
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
	movq	%r8, %r14
	movq	%rcx, %r15
	movq	%rdx, %rbx
	movq	%rsi, %r12
	leaq	-56(%rbp), %rdx
	movq	%rbx, %rsi
	callq	_inspect_find_path
	testl	%eax, %eax
	je	LBB24_6
## %bb.1:
	testb	$16, -52(%rbp)
	jne	LBB24_7
## %bb.2:
	movl	-44(%rbp), %r13d
	testq	%r13, %r13
	je	LBB24_8
## %bb.3:
	testq	%r15, %r15
	je	LBB24_5
## %bb.4:
	movq	%r12, %rdi
	movq	%r15, %rsi
	callq	_manifest_require_u64
	cmpq	%r13, %rax
	jne	LBB24_9
LBB24_5:
	movl	-48(%rbp), %ecx
	leaq	L_.str.252(%rip), %rdi
	movq	%rbx, %rsi
	movl	%r13d, %edx
	xorl	%eax, %eax
	callq	_printf
	incq	(%r14)
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB24_6:
	leaq	L_.str.249(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB24_7:
	leaq	L_.str.250(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB24_8:
	leaq	L_.str.251(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB24_9:
	callq	_inspect_manifest_require_file.cold.1
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog
_load_pi4_app_catalog:                  ## @load_pi4_app_catalog
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$248, %rsp
	movl	%edx, -204(%rbp)                ## 4-byte Spill
	movq	%rsi, %r14
	movq	%rdi, %r13
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	leaq	_PI4_APP_INDEX_PATH(%rip), %rsi
	leaq	-280(%rbp), %rdx
	callq	_inspect_find_path
	testl	%eax, %eax
	je	LBB25_44
## %bb.1:
	testb	$16, -276(%rbp)
	jne	LBB25_45
## %bb.2:
	cmpl	$0, -268(%rbp)
	je	LBB25_46
## %bb.3:
	leaq	_PI4_APP_INDEX_PATH(%rip), %rbx
	leaq	-280(%rbp), %rsi
	movq	%r13, %rdi
	movq	%rbx, %rdx
	callq	_inspect_read_file_blob
	movq	%rax, -256(%rbp)                ## 8-byte Spill
	movq	%rax, -248(%rbp)
	movq	%rdx, -240(%rbp)
	leaq	L_.str.255(%rip), %rdx
	leaq	-248(%rbp), %r15
	movq	%r15, %rdi
	movq	%rbx, %rsi
	callq	_text_manifest_require_value
	movq	$0, -176(%rbp)
	leaq	L_.str.256(%rip), %rsi
	leaq	-112(%rbp), %rdx
	movl	$32, %ecx
	movq	%r15, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_47
## %bb.4:
	cmpb	$0, -112(%rbp)
	je	LBB25_48
## %bb.5:
	callq	___error
	movl	$0, (%rax)
	leaq	-112(%rbp), %rdi
	leaq	-176(%rbp), %rsi
	movl	$10, %edx
	callq	_strtoull
	movq	%rax, %r12
	callq	___error
	cmpl	$0, (%rax)
	jne	LBB25_49
## %bb.6:
	movq	-176(%rbp), %rax
	testq	%rax, %rax
	je	LBB25_49
## %bb.7:
	cmpb	$0, (%rax)
	jne	LBB25_49
## %bb.8:
	movq	%r13, -200(%rbp)                ## 8-byte Spill
	leaq	-17(%r12), %rax
	cmpq	$-17, %rax
	jbe	LBB25_50
## %bb.9:
	movl	$15176, %esi                    ## imm = 0x3B48
	movq	%r14, %rdi
	callq	___bzero
	movq	%r12, (%r14)
	leaq	L_.str.276(%rip), %rbx
	leaq	L_.str.258(%rip), %r15
	leaq	-112(%rbp), %r13
	xorl	%r8d, %r8d
	movq	%r12, -216(%rbp)                ## 8-byte Spill
	jmp	LBB25_10
	.p2align	4
LBB25_42:                               ##   in Loop: Header=BB25_10 Depth=1
	cmpl	$0, -204(%rbp)                  ## 4-byte Folded Reload
	movq	-216(%rbp), %r12                ## 8-byte Reload
	leaq	-112(%rbp), %r13
	movq	-192(%rbp), %r8                 ## 8-byte Reload
	jne	LBB25_75
LBB25_43:                               ##   in Loop: Header=BB25_10 Depth=1
	incq	%r8
	addq	$948, %r14                      ## imm = 0x3B4
	cmpq	%r8, %r12
	leaq	L_.str.276(%rip), %rbx
	je	LBB25_12
LBB25_10:                               ## =>This Inner Loop Header: Depth=1
	movl	$64, %esi
	movq	%r13, %rdi
	movq	%rbx, %rdx
	movq	%r15, %rcx
	movq	%r8, -192(%rbp)                 ## 8-byte Spill
	leaq	L_.str.259(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB25_11
## %bb.14:                              ##   in Loop: Header=BB25_10 Depth=1
	movl	$64, %ecx
	leaq	-248(%rbp), %rdi
	movq	%r13, %rsi
	leaq	-176(%rbp), %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_52
## %bb.15:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, -176(%rbp)
	movq	-192(%rbp), %r8                 ## 8-byte Reload
	je	LBB25_53
## %bb.16:                              ##   in Loop: Header=BB25_10 Depth=1
	movl	$64, %esi
	leaq	-112(%rbp), %r13
	movq	%r13, %rdi
	movq	%rbx, %rdx
	movq	%r15, %rcx
	leaq	L_.str.260(%rip), %r9
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB25_54
## %bb.17:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	168(%r14), %rbx
	movl	$160, %ecx
	leaq	-248(%rbp), %rdi
	movq	%r13, %rsi
	movq	%rbx, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_55
## %bb.18:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%rbx)
	movq	-200(%rbp), %r13                ## 8-byte Reload
	je	LBB25_56
## %bb.19:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	904(%r14), %r15
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	_inspect_find_path
	testl	%eax, %eax
	je	LBB25_57
## %bb.20:                              ##   in Loop: Header=BB25_10 Depth=1
	testb	$16, 908(%r14)
	jne	LBB25_58
## %bb.21:                              ##   in Loop: Header=BB25_10 Depth=1
	movq	%r14, %rax
	movq	%rbx, -184(%rbp)                ## 8-byte Spill
	cmpl	$0, 916(%r14)
	je	LBB25_59
## %bb.22:                              ##   in Loop: Header=BB25_10 Depth=1
	movq	%rax, %r13
	leaq	8(%rax), %rbx
	movq	-200(%rbp), %rdi                ## 8-byte Reload
	movq	%r15, %rsi
	movq	-184(%rbp), %r12                ## 8-byte Reload
	movq	%r12, %rdx
	callq	_inspect_read_file_blob
	movq	%rax, -264(%rbp)                ## 8-byte Spill
	movq	%rax, -232(%rbp)
	movq	%rdx, -224(%rbp)
	leaq	-232(%rbp), %r15
	movq	%r15, %rdi
	movq	%r12, %rsi
	leaq	L_.str.261(%rip), %rdx
	callq	_text_manifest_require_value
	movl	$64, %ecx
	movq	%r15, %rdi
	leaq	L_.str.259(%rip), %rsi
	movq	%rbx, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_60
## %bb.23:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%rbx)
	je	LBB25_61
## %bb.24:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	-176(%rbp), %rdi
	movq	%rbx, %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB25_62
## %bb.25:                              ##   in Loop: Header=BB25_10 Depth=1
	movq	%r13, %r14
	leaq	72(%r13), %rbx
	movl	$96, %ecx
	movq	%r15, %rdi
	leaq	L_.str.263(%rip), %rsi
	movq	%rbx, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_63
## %bb.26:                              ##   in Loop: Header=BB25_10 Depth=1
	movq	-200(%rbp), %r12                ## 8-byte Reload
	cmpb	$0, (%rbx)
	je	LBB25_64
## %bb.27:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	328(%r14), %r13
	movl	$160, %ecx
	movq	%r15, %rdi
	leaq	L_.str.264(%rip), %rsi
	movq	%r13, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_65
## %bb.28:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%r13)
	je	LBB25_66
## %bb.29:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	488(%r14), %rbx
	movl	$160, %ecx
	movq	%r15, %rdi
	leaq	L_.str.220(%rip), %rsi
	movq	%rbx, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_67
## %bb.30:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%rbx)
	je	LBB25_68
## %bb.31:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	648(%r14), %r15
	movl	$160, %ecx
	leaq	-232(%rbp), %rdi
	leaq	L_.str.265(%rip), %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_69
## %bb.32:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%r15)
	je	LBB25_70
## %bb.33:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	808(%r14), %r15
	movl	$96, %ecx
	leaq	-232(%rbp), %rdi
	leaq	L_.str.266(%rip), %rsi
	movq	%r15, %rdx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB25_71
## %bb.34:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%r15)
	je	LBB25_72
## %bb.35:                              ##   in Loop: Header=BB25_10 Depth=1
	movq	-264(%rbp), %rdi                ## 8-byte Reload
	callq	_free
	leaq	920(%r14), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	callq	_inspect_find_path
	testl	%eax, %eax
	leaq	L_.str.258(%rip), %r15
	je	LBB25_73
## %bb.36:                              ##   in Loop: Header=BB25_10 Depth=1
	testb	$16, 924(%r14)
	jne	LBB25_74
## %bb.37:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpl	$0, 932(%r14)
	je	LBB25_74
## %bb.38:                              ##   in Loop: Header=BB25_10 Depth=1
	leaq	936(%r14), %rdx
	movq	%r12, %rdi
	movq	%rbx, %rsi
	callq	_inspect_find_path
	movl	%eax, 952(%r14)
	testl	%eax, %eax
	je	LBB25_42
## %bb.39:                              ##   in Loop: Header=BB25_10 Depth=1
	testb	$16, 940(%r14)
	movq	-216(%rbp), %r12                ## 8-byte Reload
	leaq	-112(%rbp), %r13
	movq	-192(%rbp), %r8                 ## 8-byte Reload
	jne	LBB25_41
## %bb.40:                              ##   in Loop: Header=BB25_10 Depth=1
	cmpl	$0, 948(%r14)
	jne	LBB25_43
LBB25_41:
	leaq	L_.str.269(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB25_12:
	movq	-256(%rbp), %rdi                ## 8-byte Reload
	callq	_free
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB25_51
## %bb.13:
	addq	$248, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB25_74:
	leaq	L_.str.268(%rip), %rsi
	movq	%r13, %rdi
	callq	_die_path
LBB25_67:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.9
LBB25_64:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.12
LBB25_55:
	leaq	-112(%rbp), %rdi
	callq	_load_pi4_app_catalog.cold.17
LBB25_65:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.11
LBB25_61:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.14
LBB25_53:
	leaq	-112(%rbp), %rdi
	callq	_load_pi4_app_catalog.cold.19
LBB25_54:
	callq	_load_pi4_app_catalog.cold.18
LBB25_59:
	leaq	L_.str.273(%rip), %rsi
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_die_path
LBB25_11:
	callq	_load_pi4_app_catalog.cold.21
LBB25_52:
	leaq	-112(%rbp), %rdi
	callq	_load_pi4_app_catalog.cold.20
LBB25_56:
	leaq	-112(%rbp), %rdi
	callq	_load_pi4_app_catalog.cold.16
LBB25_66:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.10
LBB25_57:
	leaq	L_.str.271(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB25_60:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.15
LBB25_63:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.13
LBB25_62:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.3
LBB25_58:
	leaq	L_.str.272(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB25_72:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.4
LBB25_73:
	leaq	L_.str.267(%rip), %rsi
	movq	%r13, %rdi
	callq	_die_path
LBB25_68:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.8
LBB25_69:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.7
LBB25_70:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.6
LBB25_71:
	movq	-184(%rbp), %rdi                ## 8-byte Reload
	callq	_load_pi4_app_catalog.cold.5
LBB25_75:
	leaq	L_.str.270(%rip), %rsi
	movq	%rbx, %rdi
	callq	_die_path
LBB25_49:
	callq	_load_pi4_app_catalog.cold.2
LBB25_44:
	callq	_load_pi4_app_catalog.cold.26
LBB25_45:
	callq	_load_pi4_app_catalog.cold.1
LBB25_46:
	callq	_load_pi4_app_catalog.cold.25
LBB25_47:
	callq	_load_pi4_app_catalog.cold.24
LBB25_48:
	callq	_load_pi4_app_catalog.cold.23
LBB25_50:
	callq	_load_pi4_app_catalog.cold.22
LBB25_51:
	callq	___stack_chk_fail
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_indexed_sized_file
_inspect_manifest_require_indexed_sized_file: ## @inspect_manifest_require_indexed_sized_file
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$424, %rsp                      ## imm = 0x1A8
	movq	%r8, %r14
	movq	%rcx, %r12
	movq	%rdx, %r13
	movq	%rsi, %rbx
	movq	%rdi, %r15
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	leaq	L_.str.294(%rip), %rdx
	leaq	-272(%rbp), %rdi
	movl	$64, %esi
	movq	%r13, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB26_7
## %bb.1:
	leaq	L_.str.296(%rip), %rdx
	leaq	-336(%rbp), %rdi
	movl	$64, %esi
	movq	%r13, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	_snprintf
	cmpl	$64, %eax
	jae	LBB26_8
## %bb.2:
	leaq	-272(%rbp), %rsi
	leaq	-464(%rbp), %rdx
	movl	$128, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB26_9
## %bb.3:
	leaq	-464(%rbp), %rdx
	leaq	-336(%rbp), %rcx
	movq	%r15, %rdi
	movq	%rbx, %rsi
	movq	%r14, %r8
	callq	_inspect_manifest_require_file
	leaq	-272(%rbp), %rsi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB26_10
## %bb.4:
	leaq	L_.str.248(%rip), %rdi
	leaq	-272(%rbp), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	leaq	-336(%rbp), %rsi
	leaq	-208(%rbp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB26_11
## %bb.5:
	leaq	L_.str.248(%rip), %rdi
	leaq	-336(%rbp), %rsi
	leaq	-208(%rbp), %rdx
	xorl	%eax, %eax
	callq	_printf
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB26_12
## %bb.6:
	addq	$424, %rsp                      ## imm = 0x1A8
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB26_7:
	callq	_inspect_manifest_require_indexed_sized_file.cold.5
LBB26_8:
	callq	_inspect_manifest_require_indexed_sized_file.cold.4
LBB26_9:
	callq	_inspect_manifest_require_indexed_sized_file.cold.3
LBB26_10:
	callq	_inspect_manifest_require_indexed_sized_file.cold.2
LBB26_11:
	callq	_inspect_manifest_require_indexed_sized_file.cold.1
LBB26_12:
	callq	___stack_chk_fail
                                        ## -- End function
	.p2align	4                               ## -- Begin function manifest_get_value
_manifest_get_value:                    ## @manifest_get_value
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movq	%rcx, %r12
	movq	%rdx, %r15
	movq	%rdi, %r13
	movq	(%rdi), %r14
	movq	%rsi, -72(%rbp)                 ## 8-byte Spill
	movq	%rsi, %rdi
	callq	_strlen
	movq	8(%r13), %rbx
	testq	%rbx, %rbx
	je	LBB27_18
## %bb.1:
	movq	%rax, %rcx
	movq	%r12, -56(%rbp)                 ## 8-byte Spill
	movq	%r15, -48(%rbp)                 ## 8-byte Spill
	xorl	%r15d, %r15d
	movq	%rax, -64(%rbp)                 ## 8-byte Spill
	jmp	LBB27_2
	.p2align	4
LBB27_17:                               ##   in Loop: Header=BB27_2 Depth=1
	cmpq	%rbx, %r15
	jae	LBB27_18
LBB27_2:                                ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB27_3 Depth 2
                                        ##     Child Loop BB27_8 Depth 2
	movq	%r15, %r12
	incq	%r15
	cmpq	%r15, %rbx
	cmovaq	%rbx, %r15
	movq	%r12, %r13
	.p2align	4
LBB27_3:                                ##   Parent Loop BB27_2 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	(%r14,%r13), %eax
	cmpl	$10, %eax
	je	LBB27_7
## %bb.4:                               ##   in Loop: Header=BB27_3 Depth=2
	cmpl	$13, %eax
	je	LBB27_7
## %bb.5:                               ##   in Loop: Header=BB27_3 Depth=2
	incq	%r13
	cmpq	%rbx, %r13
	jb	LBB27_3
## %bb.6:                               ##   in Loop: Header=BB27_2 Depth=1
	movq	%r15, %r13
	jmp	LBB27_12
	.p2align	4
LBB27_7:                                ##   in Loop: Header=BB27_2 Depth=1
	movq	%r13, %r15
	cmpq	%rbx, %r13
	jb	LBB27_8
	jmp	LBB27_12
	.p2align	4
LBB27_10:                               ##   in Loop: Header=BB27_8 Depth=2
	incq	%r15
	cmpq	%r15, %rbx
	je	LBB27_11
LBB27_8:                                ##   Parent Loop BB27_2 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movzbl	(%r14,%r15), %eax
	cmpl	$13, %eax
	je	LBB27_10
## %bb.9:                               ##   in Loop: Header=BB27_8 Depth=2
	cmpl	$10, %eax
	je	LBB27_10
	jmp	LBB27_12
	.p2align	4
LBB27_11:                               ##   in Loop: Header=BB27_2 Depth=1
	movq	%rbx, %r15
LBB27_12:                               ##   in Loop: Header=BB27_2 Depth=1
	leaq	(%r12,%rcx), %rax
	subq	%rax, %r13
	jbe	LBB27_17
## %bb.13:                              ##   in Loop: Header=BB27_2 Depth=1
	addq	%r14, %r12
	movq	%r12, %rdi
	movq	-72(%rbp), %rsi                 ## 8-byte Reload
	movq	%rcx, %rdx
	movq	%rax, -80(%rbp)                 ## 8-byte Spill
	callq	_memcmp
	movq	-64(%rbp), %rcx                 ## 8-byte Reload
	testl	%eax, %eax
	movq	-80(%rbp), %rax                 ## 8-byte Reload
	jne	LBB27_17
## %bb.14:                              ##   in Loop: Header=BB27_2 Depth=1
	cmpb	$61, (%r14,%rax)
	jne	LBB27_17
## %bb.15:
	cmpq	-56(%rbp), %r13                 ## 8-byte Folded Reload
	ja	LBB27_20
## %bb.16:
	leaq	-1(%r13), %rdx
	leaq	(%r12,%rcx), %rsi
	incq	%rsi
	movq	-48(%rbp), %rbx                 ## 8-byte Reload
	movq	%rbx, %rdi
	callq	_memcpy
	movb	$0, -1(%rbx,%r13)
	movl	$1, %eax
	jmp	LBB27_19
LBB27_18:
	xorl	%eax, %eax
LBB27_19:
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB27_20:
	callq	_manifest_get_value.cold.1
                                        ## -- End function
	.p2align	4                               ## -- Begin function manifest_require_u64
_manifest_require_u64:                  ## @manifest_require_u64
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	subq	$88, %rsp
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -16(%rbp)
	movq	$0, -88(%rbp)
	leaq	-80(%rbp), %rdx
	movl	$64, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB28_6
## %bb.1:
	callq	___error
	movl	$0, (%rax)
	leaq	-80(%rbp), %rdi
	leaq	-88(%rbp), %rsi
	movl	$10, %edx
	callq	_strtoull
	movq	%rax, %rbx
	callq	___error
	cmpl	$0, (%rax)
	jne	LBB28_7
## %bb.2:
	movq	-88(%rbp), %rax
	testq	%rax, %rax
	je	LBB28_7
## %bb.3:
	cmpb	$0, (%rax)
	jne	LBB28_7
## %bb.4:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-16(%rbp), %rax
	jne	LBB28_8
## %bb.5:
	movq	%rbx, %rax
	addq	$88, %rsp
	popq	%rbx
	popq	%rbp
	retq
LBB28_7:
	callq	_manifest_require_u64.cold.1
LBB28_6:
	callq	_manifest_require_u64.cold.2
LBB28_8:
	callq	___stack_chk_fail
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_manifest_require_value
_text_manifest_require_value:           ## @text_manifest_require_value
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r14
	pushq	%rbx
	subq	$176, %rsp
	movq	%rdx, %r14
	movq	%rsi, %rbx
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -24(%rbp)
	leaq	L_.str.155(%rip), %rsi
	leaq	-192(%rbp), %rdx
	movl	$160, %ecx
	callq	_manifest_get_value
	testl	%eax, %eax
	je	LBB29_5
## %bb.1:
	cmpb	$0, -192(%rbp)
	je	LBB29_6
## %bb.2:
	leaq	-192(%rbp), %rdi
	movq	%r14, %rsi
	callq	_strcmp
	testl	%eax, %eax
	jne	LBB29_7
## %bb.3:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-24(%rbp), %rax
	jne	LBB29_8
## %bb.4:
	addq	$176, %rsp
	popq	%rbx
	popq	%r14
	popq	%rbp
	retq
LBB29_5:
	movq	%rbx, %rdi
	callq	_text_manifest_require_value.cold.3
LBB29_6:
	movq	%rbx, %rdi
	callq	_text_manifest_require_value.cold.2
LBB29_7:
	movq	%rbx, %rdi
	callq	_text_manifest_require_value.cold.1
LBB29_8:
	callq	___stack_chk_fail
                                        ## -- End function
	.p2align	4                               ## -- Begin function reject_repo_local_external_asset
_reject_repo_local_external_asset:      ## @reject_repo_local_external_asset
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	subq	$2064, %rsp                     ## imm = 0x810
	movq	%rsi, %r14
	movq	%rdi, %rbx
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -40(%rbp)
	leaq	L_.str.120(%rip), %rdi
	leaq	-1072(%rbp), %rsi
	callq	_realpath$DARWIN_EXTSN
	testq	%rax, %rax
	je	LBB30_7
## %bb.1:
	leaq	-2096(%rbp), %rsi
	movq	%rbx, %rdi
	callq	_realpath$DARWIN_EXTSN
	testq	%rax, %rax
	je	LBB30_8
## %bb.2:
	leaq	-1072(%rbp), %r12
	movq	%r12, %rdi
	callq	_strlen
	movq	%rax, %r15
	leaq	-2096(%rbp), %rdi
	movq	%r12, %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB30_9
## %bb.3:
	leaq	-2096(%rbp), %rdi
	leaq	-1072(%rbp), %rsi
	movq	%r15, %rdx
	callq	_strncmp
	testl	%eax, %eax
	jne	LBB30_5
## %bb.4:
	cmpb	$47, -2096(%rbp,%r15)
	je	LBB30_9
LBB30_5:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-40(%rbp), %rax
	jne	LBB30_10
## %bb.6:
	addq	$2064, %rsp                     ## imm = 0x810
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB30_9:
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	_reject_repo_local_external_asset.cold.1
LBB30_7:
	callq	_reject_repo_local_external_asset.cold.3
LBB30_8:
	movq	%rbx, %rdi
	callq	_reject_repo_local_external_asset.cold.2
LBB30_10:
	callq	___stack_chk_fail
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump
_add_lump:                              ## @add_lump
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	%r9, %r15
	movq	%r8, %r14
	movq	%rcx, -48(%rbp)                 ## 8-byte Spill
	movq	%rsi, %rbx
	movq	(%rsi), %r13
	movq	(%rdi), %rax
	cmpq	(%rdx), %r13
	jne	LBB31_3
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
	je	LBB31_11
## %bb.2:
	movq	%rax, (%r12)
	movq	(%rbx), %r13
LBB31_3:
	movq	24(%rbp), %r12
	leaq	1(%r13), %rcx
	movq	%rcx, (%rbx)
	shlq	$4, %r13
	addq	%rax, %r13
	testq	%r12, %r12
	je	LBB31_4
## %bb.5:
	movl	(%r14), %eax
	jmp	LBB31_6
LBB31_4:
	xorl	%eax, %eax
LBB31_6:
	movl	%eax, (%r13)
	movl	%r12d, 4(%r13)
	movq	$0, 8(%r13)
	movq	%r15, %rdi
	callq	_strlen
	cmpq	$9, %rax
	jae	LBB31_12
## %bb.7:
	addq	$8, %r13
	movq	%r13, %rdi
	movq	%r15, %rsi
	movq	%rax, %rdx
	callq	_memcpy
	testq	%r12, %r12
	je	LBB31_10
## %bb.8:
	movl	(%r14), %eax
	leaq	(%r12,%rax), %rcx
	cmpq	$1048577, %rcx                  ## imm = 0x100001
	jae	LBB31_13
## %bb.9:
	movq	16(%rbp), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	addq	%rax, %rdi
	movq	%r12, %rdx
	callq	_memcpy
	addl	%r12d, (%r14)
LBB31_10:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB31_12:
	callq	_add_lump.cold.2
LBB31_13:
	callq	_add_lump.cold.1
LBB31_11:
	callq	_add_lump.cold.3
                                        ## -- End function
	.p2align	4                               ## -- Begin function proof_manifest_require_root_file
_proof_manifest_require_root_file:      ## @proof_manifest_require_root_file
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	%rcx, %rbx
	movq	56(%rdi), %r13
	testq	%r13, %r13
	je	LBB32_13
## %bb.1:
	movq	%rdx, %r14
	movq	%rsi, %r15
	movq	48(%rdi), %r12
	.p2align	4
LBB32_3:                                ## =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	movq	%rbx, %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB32_4
## %bb.2:                               ##   in Loop: Header=BB32_3 Depth=1
	addq	$104, %r12
	decq	%r13
	jne	LBB32_3
LBB32_13:
	movq	%rbx, %rdi
	callq	_proof_manifest_require_root_file.cold.3
LBB32_4:
	movl	$1311232, %eax                  ## imm = 0x140200
	addq	(%r15), %rax
	movq	$-28, %rcx
	jmp	LBB32_5
	.p2align	4
LBB32_8:                                ##   in Loop: Header=BB32_5 Depth=1
	addq	$-32, %rcx
	addq	$32, %rax
	cmpq	$-16412, %rcx                   ## imm = 0xBFE4
	je	LBB32_9
LBB32_5:                                ## =>This Inner Loop Header: Depth=1
	movzbl	(%rax), %edx
	cmpl	$229, %edx
	je	LBB32_8
## %bb.6:                               ##   in Loop: Header=BB32_5 Depth=1
	testl	%edx, %edx
	je	LBB32_9
## %bb.7:                               ##   in Loop: Header=BB32_5 Depth=1
	movq	(%rax), %rdx
	xorq	(%r14), %rdx
	movq	3(%rax), %rsi
	xorq	3(%r14), %rsi
	orq	%rdx, %rsi
	jne	LBB32_8
## %bb.10:
	negq	%rcx
	cmpq	$16385, %rcx                    ## imm = 0x4001
	jae	LBB32_14
## %bb.11:
	cmpl	$0, 28(%rax)
	je	LBB32_9
## %bb.12:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB32_9:
	movq	%rbx, %rdi
	callq	_proof_manifest_require_root_file.cold.1
LBB32_14:
	callq	_proof_manifest_require_root_file.cold.2
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_appendf
_text_appendf:                          ## @text_appendf
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$216, %rsp
	movq	%rsi, %r14
	movq	%rdi, %rbx
	movq	%rdx, -240(%rbp)
	movq	%rcx, -232(%rbp)
	movq	%r8, -224(%rbp)
	movq	%r9, -216(%rbp)
	testb	%al, %al
	je	LBB33_19
## %bb.18:
	movaps	%xmm0, -208(%rbp)
	movaps	%xmm1, -192(%rbp)
	movaps	%xmm2, -176(%rbp)
	movaps	%xmm3, -160(%rbp)
	movaps	%xmm4, -144(%rbp)
	movaps	%xmm5, -128(%rbp)
	movaps	%xmm6, -112(%rbp)
	movaps	%xmm7, -96(%rbp)
LBB33_19:
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -48(%rbp)
	movq	(%rdi), %rax
	testq	%rax, %rax
	jne	LBB33_3
## %bb.1:
	movq	$512, 16(%rbx)                  ## imm = 0x200
	movl	$512, %edi                      ## imm = 0x200
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB33_13
## %bb.2:
	movq	%rax, (%rbx)
LBB33_3:
	leaq	16(%rbp), %r13
	movabsq	$206158430224, %r12             ## imm = 0x3000000010
	leaq	-80(%rbp), %r15
	.p2align	4
LBB33_4:                                ## =>This Inner Loop Header: Depth=1
	movq	16(%rbx), %rsi
	movq	%rsi, %rcx
	subq	8(%rbx), %rcx
	cmpq	$127, %rcx
	ja	LBB33_7
## %bb.5:                               ##   in Loop: Header=BB33_4 Depth=1
	addq	%rsi, %rsi
	movq	%rsi, 16(%rbx)
	movq	%rax, %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB33_14
## %bb.6:                               ##   in Loop: Header=BB33_4 Depth=1
	movq	%rax, (%rbx)
LBB33_7:                                ##   in Loop: Header=BB33_4 Depth=1
	leaq	-256(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	%r13, -72(%rbp)
	movq	%r12, -80(%rbp)
	movq	8(%rbx), %rax
	movq	16(%rbx), %rsi
	movq	(%rbx), %rdi
	addq	%rax, %rdi
	subq	%rax, %rsi
	movq	%r14, %rdx
	movq	%r15, %rcx
	callq	_vsnprintf
	testl	%eax, %eax
	js	LBB33_15
## %bb.8:                               ##   in Loop: Header=BB33_4 Depth=1
	movl	%eax, %eax
	movq	8(%rbx), %rsi
	movq	16(%rbx), %rcx
	subq	%rsi, %rcx
	addq	%rax, %rsi
	cmpq	%rax, %rcx
	ja	LBB33_11
## %bb.9:                               ##   in Loop: Header=BB33_4 Depth=1
	incq	%rsi
	movq	%rsi, 16(%rbx)
	movq	(%rbx), %rdi
	callq	_realloc
	testq	%rax, %rax
	je	LBB33_16
## %bb.10:                              ##   in Loop: Header=BB33_4 Depth=1
	movq	%rax, (%rbx)
	jmp	LBB33_4
LBB33_11:
	movq	%rsi, 8(%rbx)
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	-48(%rbp), %rax
	jne	LBB33_17
## %bb.12:
	addq	$216, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB33_15:
	callq	_text_appendf.cold.2
LBB33_16:
	callq	_text_appendf.cold.1
LBB33_14:
	callq	_text_appendf.cold.3
LBB33_17:
	callq	___stack_chk_fail
LBB33_13:
	callq	_text_appendf.cold.4
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.1
_main.cold.1:                           ## @main.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.2
_main.cold.2:                           ## @main.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.3
_main.cold.3:                           ## @main.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.133(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.4
_main.cold.4:                           ## @main.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.132(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.5
_main.cold.5:                           ## @main.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.6
_main.cold.6:                           ## @main.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.7
_main.cold.7:                           ## @main.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.131(%rip), %rdi
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
	leaq	L_.str.127(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.10
_main.cold.10:                          ## @main.cold.10
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.130(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.11
_main.cold.11:                          ## @main.cold.11
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.129(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.12
_main.cold.12:                          ## @main.cold.12
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.13
_main.cold.13:                          ## @main.cold.13
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.14
_main.cold.14:                          ## @main.cold.14
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.113(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.15
_main.cold.15:                          ## @main.cold.15
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.115(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.16
_main.cold.16:                          ## @main.cold.16
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.21(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.17
_main.cold.17:                          ## @main.cold.17
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.127(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.18
_main.cold.18:                          ## @main.cold.18
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.112(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.19
_main.cold.19:                          ## @main.cold.19
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.111(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.20
_main.cold.20:                          ## @main.cold.20
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.21
_main.cold.21:                          ## @main.cold.21
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.22
_main.cold.22:                          ## @main.cold.22
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.23
_main.cold.23:                          ## @main.cold.23
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.24
_main.cold.24:                          ## @main.cold.24
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.25
_main.cold.25:                          ## @main.cold.25
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.26
_main.cold.26:                          ## @main.cold.26
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.25(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.27
_main.cold.27:                          ## @main.cold.27
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.28
_main.cold.28:                          ## @main.cold.28
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.27(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.29
_main.cold.29:                          ## @main.cold.29
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.28(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.30
_main.cold.30:                          ## @main.cold.30
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.31
_main.cold.31:                          ## @main.cold.31
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.32
_main.cold.32:                          ## @main.cold.32
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.33
_main.cold.33:                          ## @main.cold.33
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.67(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.34
_main.cold.34:                          ## @main.cold.34
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.68(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.35
_main.cold.35:                          ## @main.cold.35
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.70(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.36
_main.cold.36:                          ## @main.cold.36
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.69(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.37
_main.cold.37:                          ## @main.cold.37
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.77(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.38
_main.cold.38:                          ## @main.cold.38
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.78(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.39
_main.cold.39:                          ## @main.cold.39
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.80(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.40
_main.cold.40:                          ## @main.cold.40
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.81(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.41
_main.cold.41:                          ## @main.cold.41
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.84(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.42
_main.cold.42:                          ## @main.cold.42
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.83(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.43
_main.cold.43:                          ## @main.cold.43
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.86(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.44
_main.cold.44:                          ## @main.cold.44
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.79(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.45
_main.cold.45:                          ## @main.cold.45
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.87(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.46
_main.cold.46:                          ## @main.cold.46
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.96(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.47
_main.cold.47:                          ## @main.cold.47
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.98(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.48
_main.cold.48:                          ## @main.cold.48
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.53(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.49
_main.cold.49:                          ## @main.cold.49
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker.cold.1
_mutate_root_marker.cold.1:             ## @mutate_root_marker.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.40(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker.cold.2
_mutate_root_marker.cold.2:             ## @mutate_root_marker.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function mutate_root_marker.cold.3
_mutate_root_marker.cold.3:             ## @mutate_root_marker.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.36(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.1
_install_bootable_layout.cold.1:        ## @install_bootable_layout.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.308(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.2
_install_bootable_layout.cold.2:        ## @install_bootable_layout.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.316(%rip), %rsi
	leaq	L_.str.314(%rip), %rdx
	movl	$229376, %r8d                   ## imm = 0x38000
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.3
_install_bootable_layout.cold.3:        ## @install_bootable_layout.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.316(%rip), %rsi
	leaq	L_.str.313(%rip), %rdx
	movl	$8192, %r8d                     ## imm = 0x2000
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.4
_install_bootable_layout.cold.4:        ## @install_bootable_layout.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.48(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.5
_install_bootable_layout.cold.5:        ## @install_bootable_layout.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.48(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.6
_install_bootable_layout.cold.6:        ## @install_bootable_layout.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.350(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.7
_install_bootable_layout.cold.7:        ## @install_bootable_layout.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.8
_install_bootable_layout.cold.8:        ## @install_bootable_layout.cold.8
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.9
_install_bootable_layout.cold.9:        ## @install_bootable_layout.cold.9
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.10
_install_bootable_layout.cold.10:       ## @install_bootable_layout.cold.10
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.11
_install_bootable_layout.cold.11:       ## @install_bootable_layout.cold.11
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.12
_install_bootable_layout.cold.12:       ## @install_bootable_layout.cold.12
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.13
_install_bootable_layout.cold.13:       ## @install_bootable_layout.cold.13
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.14
_install_bootable_layout.cold.14:       ## @install_bootable_layout.cold.14
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.15
_install_bootable_layout.cold.15:       ## @install_bootable_layout.cold.15
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.394(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.16
_install_bootable_layout.cold.16:       ## @install_bootable_layout.cold.16
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.17
_install_bootable_layout.cold.17:       ## @install_bootable_layout.cold.17
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.18
_install_bootable_layout.cold.18:       ## @install_bootable_layout.cold.18
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.19
_install_bootable_layout.cold.19:       ## @install_bootable_layout.cold.19
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.20
_install_bootable_layout.cold.20:       ## @install_bootable_layout.cold.20
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.310(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.21
_install_bootable_layout.cold.21:       ## @install_bootable_layout.cold.21
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.428(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.22
_install_bootable_layout.cold.22:       ## @install_bootable_layout.cold.22
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.23
_install_bootable_layout.cold.23:       ## @install_bootable_layout.cold.23
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.428(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.24
_install_bootable_layout.cold.24:       ## @install_bootable_layout.cold.24
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.25
_install_bootable_layout.cold.25:       ## @install_bootable_layout.cold.25
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.428(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.26
_install_bootable_layout.cold.26:       ## @install_bootable_layout.cold.26
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.27
_install_bootable_layout.cold.27:       ## @install_bootable_layout.cold.27
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.36(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.28
_install_bootable_layout.cold.28:       ## @install_bootable_layout.cold.28
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.36(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.29
_install_bootable_layout.cold.29:       ## @install_bootable_layout.cold.29
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.429(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.30
_install_bootable_layout.cold.30:       ## @install_bootable_layout.cold.30
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	leaq	L_.str.438(%rip), %rdi
	pushq	$93
	popq	%rsi
	pushq	$1
	popq	%rdx
	callq	_fwrite
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.31
_install_bootable_layout.cold.31:       ## @install_bootable_layout.cold.31
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.497(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.32
_install_bootable_layout.cold.32:       ## @install_bootable_layout.cold.32
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.497(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.33
_install_bootable_layout.cold.33:       ## @install_bootable_layout.cold.33
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.497(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.34
_install_bootable_layout.cold.34:       ## @install_bootable_layout.cold.34
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.497(%rip), %rsi
	leaq	_PI4_SYSTEM_ABIPROBE_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.35
_install_bootable_layout.cold.35:       ## @install_bootable_layout.cold.35
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.497(%rip), %rsi
	leaq	_PI4_SYSTEM_INIT_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.36
_install_bootable_layout.cold.36:       ## @install_bootable_layout.cold.36
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.311(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.37
_install_bootable_layout.cold.37:       ## @install_bootable_layout.cold.37
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.38
_install_bootable_layout.cold.38:       ## @install_bootable_layout.cold.38
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.426(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.39
_install_bootable_layout.cold.39:       ## @install_bootable_layout.cold.39
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.40
_install_bootable_layout.cold.40:       ## @install_bootable_layout.cold.40
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.426(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.41
_install_bootable_layout.cold.41:       ## @install_bootable_layout.cold.41
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.42
_install_bootable_layout.cold.42:       ## @install_bootable_layout.cold.42
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.426(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.43
_install_bootable_layout.cold.43:       ## @install_bootable_layout.cold.43
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.44
_install_bootable_layout.cold.44:       ## @install_bootable_layout.cold.44
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.426(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.45
_install_bootable_layout.cold.45:       ## @install_bootable_layout.cold.45
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function install_bootable_layout.cold.46
_install_bootable_layout.cold.46:       ## @install_bootable_layout.cold.46
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.426(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file.cold.1
_write_file.cold.1:                     ## @write_file.cold.1
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
	.p2align	4                               ## -- Begin function read_file.cold.1
_read_file.cold.1:                      ## @read_file.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_file.cold.2
_read_file.cold.2:                      ## @read_file.cold.2
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
	.p2align	4                               ## -- Begin function write_file_path.cold.1
_write_file_path.cold.1:                ## @write_file_path.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.42(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path.cold.2
_write_file_path.cold.2:                ## @write_file_path.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path.cold.3
_write_file_path.cold.3:                ## @write_file_path.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_file_path.cold.4
_write_file_path.cold.4:                ## @write_file_path.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.1
_ensure_child_directory.cold.1:         ## @ensure_child_directory.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.2
_ensure_child_directory.cold.2:         ## @ensure_child_directory.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.3
_ensure_child_directory.cold.3:         ## @ensure_child_directory.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.4
_ensure_child_directory.cold.4:         ## @ensure_child_directory.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.47(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.5
_ensure_child_directory.cold.5:         ## @ensure_child_directory.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.36(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function ensure_child_directory.cold.6
_ensure_child_directory.cold.6:         ## @ensure_child_directory.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.43(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain.cold.1
_write_cluster_chain.cold.1:            ## @write_cluster_chain.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.46(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain.cold.2
_write_cluster_chain.cold.2:            ## @write_cluster_chain.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function write_cluster_chain.cold.3
_write_cluster_chain.cold.3:            ## @write_cluster_chain.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.1
_check_write_status.cold.1:             ## @check_write_status.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.96(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.2
_check_write_status.cold.2:             ## @check_write_status.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.99(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.3
_check_write_status.cold.3:             ## @check_write_status.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.98(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.4
_check_write_status.cold.4:             ## @check_write_status.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.98(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.5
_check_write_status.cold.5:             ## @check_write_status.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.99(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.6
_check_write_status.cold.6:             ## @check_write_status.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.99(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.7
_check_write_status.cold.7:             ## @check_write_status.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.98(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_write_status.cold.8
_check_write_status.cold.8:             ## @check_write_status.cold.8
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.98(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_dynamic_fat_status.cold.1
_check_dynamic_fat_status.cold.1:       ## @check_dynamic_fat_status.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.96(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function check_dynamic_fat_status.cold.2
_check_dynamic_fat_status.cold.2:       ## @check_dynamic_fat_status.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.98(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function read_root_file_blob.cold.1
_read_root_file_blob.cold.1:            ## @read_root_file_blob.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part.cold.1
_status_hex_tuple_part.cold.1:          ## @status_hex_tuple_part.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.97(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part.cold.2
_status_hex_tuple_part.cold.2:          ## @status_hex_tuple_part.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.98(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function status_hex_tuple_part.cold.3
_status_hex_tuple_part.cold.3:          ## @status_hex_tuple_part.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.96(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.1
_parse_path83.cold.1:                   ## @parse_path83.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.119(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.2
_parse_path83.cold.2:                   ## @parse_path83.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.117(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.3
_parse_path83.cold.3:                   ## @parse_path83.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.119(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.4
_parse_path83.cold.4:                   ## @parse_path83.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.117(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.5
_parse_path83.cold.5:                   ## @parse_path83.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.122(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.6
_parse_path83.cold.6:                   ## @parse_path83.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.121(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function parse_path83.cold.7
_parse_path83.cold.7:                   ## @parse_path83.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.116(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.1
_fat83_from_display_component.cold.1:   ## @fat83_from_display_component.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.124(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.2
_fat83_from_display_component.cold.2:   ## @fat83_from_display_component.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.125(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.3
_fat83_from_display_component.cold.3:   ## @fat83_from_display_component.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.126(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function fat83_from_display_component.cold.4
_fat83_from_display_component.cold.4:   ## @fat83_from_display_component.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.123(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_directory.cold.1
_inspect_directory.cold.1:              ## @inspect_directory.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.145(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.1
_inspect_pi4_manifest.cold.1:           ## @inspect_pi4_manifest.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.2
_inspect_pi4_manifest.cold.2:           ## @inspect_pi4_manifest.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.3
_inspect_pi4_manifest.cold.3:           ## @inspect_pi4_manifest.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.244(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.4
_inspect_pi4_manifest.cold.4:           ## @inspect_pi4_manifest.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.244(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.5
_inspect_pi4_manifest.cold.5:           ## @inspect_pi4_manifest.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.244(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.6
_inspect_pi4_manifest.cold.6:           ## @inspect_pi4_manifest.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.7
_inspect_pi4_manifest.cold.7:           ## @inspect_pi4_manifest.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.8
_inspect_pi4_manifest.cold.8:           ## @inspect_pi4_manifest.cold.8
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.9
_inspect_pi4_manifest.cold.9:           ## @inspect_pi4_manifest.cold.9
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.10
_inspect_pi4_manifest.cold.10:          ## @inspect_pi4_manifest.cold.10
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.11
_inspect_pi4_manifest.cold.11:          ## @inspect_pi4_manifest.cold.11
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.12
_inspect_pi4_manifest.cold.12:          ## @inspect_pi4_manifest.cold.12
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.13
_inspect_pi4_manifest.cold.13:          ## @inspect_pi4_manifest.cold.13
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.14
_inspect_pi4_manifest.cold.14:          ## @inspect_pi4_manifest.cold.14
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.15
_inspect_pi4_manifest.cold.15:          ## @inspect_pi4_manifest.cold.15
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.16
_inspect_pi4_manifest.cold.16:          ## @inspect_pi4_manifest.cold.16
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.17
_inspect_pi4_manifest.cold.17:          ## @inspect_pi4_manifest.cold.17
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.18
_inspect_pi4_manifest.cold.18:          ## @inspect_pi4_manifest.cold.18
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.19
_inspect_pi4_manifest.cold.19:          ## @inspect_pi4_manifest.cold.19
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.20
_inspect_pi4_manifest.cold.20:          ## @inspect_pi4_manifest.cold.20
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.21
_inspect_pi4_manifest.cold.21:          ## @inspect_pi4_manifest.cold.21
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.253(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.22
_inspect_pi4_manifest.cold.22:          ## @inspect_pi4_manifest.cold.22
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.23
_inspect_pi4_manifest.cold.23:          ## @inspect_pi4_manifest.cold.23
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.253(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.24
_inspect_pi4_manifest.cold.24:          ## @inspect_pi4_manifest.cold.24
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.25
_inspect_pi4_manifest.cold.25:          ## @inspect_pi4_manifest.cold.25
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.26
_inspect_pi4_manifest.cold.26:          ## @inspect_pi4_manifest.cold.26
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.27
_inspect_pi4_manifest.cold.27:          ## @inspect_pi4_manifest.cold.27
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.28
_inspect_pi4_manifest.cold.28:          ## @inspect_pi4_manifest.cold.28
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.29
_inspect_pi4_manifest.cold.29:          ## @inspect_pi4_manifest.cold.29
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.30
_inspect_pi4_manifest.cold.30:          ## @inspect_pi4_manifest.cold.30
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.31
_inspect_pi4_manifest.cold.31:          ## @inspect_pi4_manifest.cold.31
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.32
_inspect_pi4_manifest.cold.32:          ## @inspect_pi4_manifest.cold.32
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.33
_inspect_pi4_manifest.cold.33:          ## @inspect_pi4_manifest.cold.33
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.34
_inspect_pi4_manifest.cold.34:          ## @inspect_pi4_manifest.cold.34
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.35
_inspect_pi4_manifest.cold.35:          ## @inspect_pi4_manifest.cold.35
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.36
_inspect_pi4_manifest.cold.36:          ## @inspect_pi4_manifest.cold.36
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.37
_inspect_pi4_manifest.cold.37:          ## @inspect_pi4_manifest.cold.37
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.38
_inspect_pi4_manifest.cold.38:          ## @inspect_pi4_manifest.cold.38
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.39
_inspect_pi4_manifest.cold.39:          ## @inspect_pi4_manifest.cold.39
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.40
_inspect_pi4_manifest.cold.40:          ## @inspect_pi4_manifest.cold.40
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.41
_inspect_pi4_manifest.cold.41:          ## @inspect_pi4_manifest.cold.41
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.42
_inspect_pi4_manifest.cold.42:          ## @inspect_pi4_manifest.cold.42
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.43
_inspect_pi4_manifest.cold.43:          ## @inspect_pi4_manifest.cold.43
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.44
_inspect_pi4_manifest.cold.44:          ## @inspect_pi4_manifest.cold.44
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.45
_inspect_pi4_manifest.cold.45:          ## @inspect_pi4_manifest.cold.45
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.46
_inspect_pi4_manifest.cold.46:          ## @inspect_pi4_manifest.cold.46
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.47
_inspect_pi4_manifest.cold.47:          ## @inspect_pi4_manifest.cold.47
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.48
_inspect_pi4_manifest.cold.48:          ## @inspect_pi4_manifest.cold.48
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.49
_inspect_pi4_manifest.cold.49:          ## @inspect_pi4_manifest.cold.49
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.50
_inspect_pi4_manifest.cold.50:          ## @inspect_pi4_manifest.cold.50
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.51
_inspect_pi4_manifest.cold.51:          ## @inspect_pi4_manifest.cold.51
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.52
_inspect_pi4_manifest.cold.52:          ## @inspect_pi4_manifest.cold.52
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.53
_inspect_pi4_manifest.cold.53:          ## @inspect_pi4_manifest.cold.53
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.54
_inspect_pi4_manifest.cold.54:          ## @inspect_pi4_manifest.cold.54
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.55
_inspect_pi4_manifest.cold.55:          ## @inspect_pi4_manifest.cold.55
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.56
_inspect_pi4_manifest.cold.56:          ## @inspect_pi4_manifest.cold.56
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.57
_inspect_pi4_manifest.cold.57:          ## @inspect_pi4_manifest.cold.57
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.58
_inspect_pi4_manifest.cold.58:          ## @inspect_pi4_manifest.cold.58
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.59
_inspect_pi4_manifest.cold.59:          ## @inspect_pi4_manifest.cold.59
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.60
_inspect_pi4_manifest.cold.60:          ## @inspect_pi4_manifest.cold.60
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.61
_inspect_pi4_manifest.cold.61:          ## @inspect_pi4_manifest.cold.61
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.62
_inspect_pi4_manifest.cold.62:          ## @inspect_pi4_manifest.cold.62
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.63
_inspect_pi4_manifest.cold.63:          ## @inspect_pi4_manifest.cold.63
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.64
_inspect_pi4_manifest.cold.64:          ## @inspect_pi4_manifest.cold.64
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.65
_inspect_pi4_manifest.cold.65:          ## @inspect_pi4_manifest.cold.65
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.66
_inspect_pi4_manifest.cold.66:          ## @inspect_pi4_manifest.cold.66
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.67
_inspect_pi4_manifest.cold.67:          ## @inspect_pi4_manifest.cold.67
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.204(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.68
_inspect_pi4_manifest.cold.68:          ## @inspect_pi4_manifest.cold.68
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.203(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.69
_inspect_pi4_manifest.cold.69:          ## @inspect_pi4_manifest.cold.69
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.200(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.70
_inspect_pi4_manifest.cold.70:          ## @inspect_pi4_manifest.cold.70
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.71
_inspect_pi4_manifest.cold.71:          ## @inspect_pi4_manifest.cold.71
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.72
_inspect_pi4_manifest.cold.72:          ## @inspect_pi4_manifest.cold.72
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.73
_inspect_pi4_manifest.cold.73:          ## @inspect_pi4_manifest.cold.73
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.74
_inspect_pi4_manifest.cold.74:          ## @inspect_pi4_manifest.cold.74
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.75
_inspect_pi4_manifest.cold.75:          ## @inspect_pi4_manifest.cold.75
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.76
_inspect_pi4_manifest.cold.76:          ## @inspect_pi4_manifest.cold.76
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.77
_inspect_pi4_manifest.cold.77:          ## @inspect_pi4_manifest.cold.77
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.78
_inspect_pi4_manifest.cold.78:          ## @inspect_pi4_manifest.cold.78
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.79
_inspect_pi4_manifest.cold.79:          ## @inspect_pi4_manifest.cold.79
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.80
_inspect_pi4_manifest.cold.80:          ## @inspect_pi4_manifest.cold.80
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.81
_inspect_pi4_manifest.cold.81:          ## @inspect_pi4_manifest.cold.81
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.82
_inspect_pi4_manifest.cold.82:          ## @inspect_pi4_manifest.cold.82
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.83
_inspect_pi4_manifest.cold.83:          ## @inspect_pi4_manifest.cold.83
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.84
_inspect_pi4_manifest.cold.84:          ## @inspect_pi4_manifest.cold.84
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.85
_inspect_pi4_manifest.cold.85:          ## @inspect_pi4_manifest.cold.85
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.86
_inspect_pi4_manifest.cold.86:          ## @inspect_pi4_manifest.cold.86
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.87
_inspect_pi4_manifest.cold.87:          ## @inspect_pi4_manifest.cold.87
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.88
_inspect_pi4_manifest.cold.88:          ## @inspect_pi4_manifest.cold.88
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.89
_inspect_pi4_manifest.cold.89:          ## @inspect_pi4_manifest.cold.89
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.90
_inspect_pi4_manifest.cold.90:          ## @inspect_pi4_manifest.cold.90
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.91
_inspect_pi4_manifest.cold.91:          ## @inspect_pi4_manifest.cold.91
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.92
_inspect_pi4_manifest.cold.92:          ## @inspect_pi4_manifest.cold.92
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.93
_inspect_pi4_manifest.cold.93:          ## @inspect_pi4_manifest.cold.93
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.94
_inspect_pi4_manifest.cold.94:          ## @inspect_pi4_manifest.cold.94
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.95
_inspect_pi4_manifest.cold.95:          ## @inspect_pi4_manifest.cold.95
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.96
_inspect_pi4_manifest.cold.96:          ## @inspect_pi4_manifest.cold.96
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.97
_inspect_pi4_manifest.cold.97:          ## @inspect_pi4_manifest.cold.97
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.98
_inspect_pi4_manifest.cold.98:          ## @inspect_pi4_manifest.cold.98
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.297(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.99
_inspect_pi4_manifest.cold.99:          ## @inspect_pi4_manifest.cold.99
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.100
_inspect_pi4_manifest.cold.100:         ## @inspect_pi4_manifest.cold.100
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.101
_inspect_pi4_manifest.cold.101:         ## @inspect_pi4_manifest.cold.101
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.102
_inspect_pi4_manifest.cold.102:         ## @inspect_pi4_manifest.cold.102
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.103
_inspect_pi4_manifest.cold.103:         ## @inspect_pi4_manifest.cold.103
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.104
_inspect_pi4_manifest.cold.104:         ## @inspect_pi4_manifest.cold.104
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.105
_inspect_pi4_manifest.cold.105:         ## @inspect_pi4_manifest.cold.105
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.106
_inspect_pi4_manifest.cold.106:         ## @inspect_pi4_manifest.cold.106
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.107
_inspect_pi4_manifest.cold.107:         ## @inspect_pi4_manifest.cold.107
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.108
_inspect_pi4_manifest.cold.108:         ## @inspect_pi4_manifest.cold.108
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.109
_inspect_pi4_manifest.cold.109:         ## @inspect_pi4_manifest.cold.109
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.110
_inspect_pi4_manifest.cold.110:         ## @inspect_pi4_manifest.cold.110
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.111
_inspect_pi4_manifest.cold.111:         ## @inspect_pi4_manifest.cold.111
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.112
_inspect_pi4_manifest.cold.112:         ## @inspect_pi4_manifest.cold.112
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.113
_inspect_pi4_manifest.cold.113:         ## @inspect_pi4_manifest.cold.113
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.114
_inspect_pi4_manifest.cold.114:         ## @inspect_pi4_manifest.cold.114
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.115
_inspect_pi4_manifest.cold.115:         ## @inspect_pi4_manifest.cold.115
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.116
_inspect_pi4_manifest.cold.116:         ## @inspect_pi4_manifest.cold.116
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.117
_inspect_pi4_manifest.cold.117:         ## @inspect_pi4_manifest.cold.117
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.118
_inspect_pi4_manifest.cold.118:         ## @inspect_pi4_manifest.cold.118
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.234(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.119
_inspect_pi4_manifest.cold.119:         ## @inspect_pi4_manifest.cold.119
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.120
_inspect_pi4_manifest.cold.120:         ## @inspect_pi4_manifest.cold.120
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.121
_inspect_pi4_manifest.cold.121:         ## @inspect_pi4_manifest.cold.121
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.122
_inspect_pi4_manifest.cold.122:         ## @inspect_pi4_manifest.cold.122
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.243(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.123
_inspect_pi4_manifest.cold.123:         ## @inspect_pi4_manifest.cold.123
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.236(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.124
_inspect_pi4_manifest.cold.124:         ## @inspect_pi4_manifest.cold.124
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.237(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.125
_inspect_pi4_manifest.cold.125:         ## @inspect_pi4_manifest.cold.125
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.238(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.126
_inspect_pi4_manifest.cold.126:         ## @inspect_pi4_manifest.cold.126
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.127
_inspect_pi4_manifest.cold.127:         ## @inspect_pi4_manifest.cold.127
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.128
_inspect_pi4_manifest.cold.128:         ## @inspect_pi4_manifest.cold.128
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.129
_inspect_pi4_manifest.cold.129:         ## @inspect_pi4_manifest.cold.129
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.130
_inspect_pi4_manifest.cold.130:         ## @inspect_pi4_manifest.cold.130
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.131
_inspect_pi4_manifest.cold.131:         ## @inspect_pi4_manifest.cold.131
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.132
_inspect_pi4_manifest.cold.132:         ## @inspect_pi4_manifest.cold.132
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.133
_inspect_pi4_manifest.cold.133:         ## @inspect_pi4_manifest.cold.133
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.134
_inspect_pi4_manifest.cold.134:         ## @inspect_pi4_manifest.cold.134
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.135
_inspect_pi4_manifest.cold.135:         ## @inspect_pi4_manifest.cold.135
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.136
_inspect_pi4_manifest.cold.136:         ## @inspect_pi4_manifest.cold.136
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.137
_inspect_pi4_manifest.cold.137:         ## @inspect_pi4_manifest.cold.137
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.138
_inspect_pi4_manifest.cold.138:         ## @inspect_pi4_manifest.cold.138
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.225(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.139
_inspect_pi4_manifest.cold.139:         ## @inspect_pi4_manifest.cold.139
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.140
_inspect_pi4_manifest.cold.140:         ## @inspect_pi4_manifest.cold.140
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.141
_inspect_pi4_manifest.cold.141:         ## @inspect_pi4_manifest.cold.141
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.142
_inspect_pi4_manifest.cold.142:         ## @inspect_pi4_manifest.cold.142
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.293(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.143
_inspect_pi4_manifest.cold.143:         ## @inspect_pi4_manifest.cold.143
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.144
_inspect_pi4_manifest.cold.144:         ## @inspect_pi4_manifest.cold.144
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.145
_inspect_pi4_manifest.cold.145:         ## @inspect_pi4_manifest.cold.145
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.146
_inspect_pi4_manifest.cold.146:         ## @inspect_pi4_manifest.cold.146
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.147
_inspect_pi4_manifest.cold.147:         ## @inspect_pi4_manifest.cold.147
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.148
_inspect_pi4_manifest.cold.148:         ## @inspect_pi4_manifest.cold.148
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.149
_inspect_pi4_manifest.cold.149:         ## @inspect_pi4_manifest.cold.149
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.150
_inspect_pi4_manifest.cold.150:         ## @inspect_pi4_manifest.cold.150
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.151
_inspect_pi4_manifest.cold.151:         ## @inspect_pi4_manifest.cold.151
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.152
_inspect_pi4_manifest.cold.152:         ## @inspect_pi4_manifest.cold.152
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.153
_inspect_pi4_manifest.cold.153:         ## @inspect_pi4_manifest.cold.153
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.154
_inspect_pi4_manifest.cold.154:         ## @inspect_pi4_manifest.cold.154
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.155
_inspect_pi4_manifest.cold.155:         ## @inspect_pi4_manifest.cold.155
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.156
_inspect_pi4_manifest.cold.156:         ## @inspect_pi4_manifest.cold.156
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.157
_inspect_pi4_manifest.cold.157:         ## @inspect_pi4_manifest.cold.157
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.197(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.158
_inspect_pi4_manifest.cold.158:         ## @inspect_pi4_manifest.cold.158
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.195(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.159
_inspect_pi4_manifest.cold.159:         ## @inspect_pi4_manifest.cold.159
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.160
_inspect_pi4_manifest.cold.160:         ## @inspect_pi4_manifest.cold.160
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.161
_inspect_pi4_manifest.cold.161:         ## @inspect_pi4_manifest.cold.161
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.162
_inspect_pi4_manifest.cold.162:         ## @inspect_pi4_manifest.cold.162
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.163
_inspect_pi4_manifest.cold.163:         ## @inspect_pi4_manifest.cold.163
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.293(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.164
_inspect_pi4_manifest.cold.164:         ## @inspect_pi4_manifest.cold.164
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.165
_inspect_pi4_manifest.cold.165:         ## @inspect_pi4_manifest.cold.165
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.293(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.166
_inspect_pi4_manifest.cold.166:         ## @inspect_pi4_manifest.cold.166
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.167
_inspect_pi4_manifest.cold.167:         ## @inspect_pi4_manifest.cold.167
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.168
_inspect_pi4_manifest.cold.168:         ## @inspect_pi4_manifest.cold.168
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.169
_inspect_pi4_manifest.cold.169:         ## @inspect_pi4_manifest.cold.169
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.170
_inspect_pi4_manifest.cold.170:         ## @inspect_pi4_manifest.cold.170
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.171
_inspect_pi4_manifest.cold.171:         ## @inspect_pi4_manifest.cold.171
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.172
_inspect_pi4_manifest.cold.172:         ## @inspect_pi4_manifest.cold.172
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.173
_inspect_pi4_manifest.cold.173:         ## @inspect_pi4_manifest.cold.173
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.174
_inspect_pi4_manifest.cold.174:         ## @inspect_pi4_manifest.cold.174
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.175
_inspect_pi4_manifest.cold.175:         ## @inspect_pi4_manifest.cold.175
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.176
_inspect_pi4_manifest.cold.176:         ## @inspect_pi4_manifest.cold.176
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.177
_inspect_pi4_manifest.cold.177:         ## @inspect_pi4_manifest.cold.177
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.178
_inspect_pi4_manifest.cold.178:         ## @inspect_pi4_manifest.cold.178
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.179
_inspect_pi4_manifest.cold.179:         ## @inspect_pi4_manifest.cold.179
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.180
_inspect_pi4_manifest.cold.180:         ## @inspect_pi4_manifest.cold.180
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.181
_inspect_pi4_manifest.cold.181:         ## @inspect_pi4_manifest.cold.181
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.182
_inspect_pi4_manifest.cold.182:         ## @inspect_pi4_manifest.cold.182
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.183
_inspect_pi4_manifest.cold.183:         ## @inspect_pi4_manifest.cold.183
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.184
_inspect_pi4_manifest.cold.184:         ## @inspect_pi4_manifest.cold.184
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.185
_inspect_pi4_manifest.cold.185:         ## @inspect_pi4_manifest.cold.185
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.186
_inspect_pi4_manifest.cold.186:         ## @inspect_pi4_manifest.cold.186
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.187
_inspect_pi4_manifest.cold.187:         ## @inspect_pi4_manifest.cold.187
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.188
_inspect_pi4_manifest.cold.188:         ## @inspect_pi4_manifest.cold.188
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.189
_inspect_pi4_manifest.cold.189:         ## @inspect_pi4_manifest.cold.189
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.190
_inspect_pi4_manifest.cold.190:         ## @inspect_pi4_manifest.cold.190
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.242(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_pi4_manifest.cold.191
_inspect_pi4_manifest.cold.191:         ## @inspect_pi4_manifest.cold.191
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.154(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_find_path.cold.1
_inspect_find_path.cold.1:              ## @inspect_find_path.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.153(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_read_file_blob.cold.1
_inspect_read_file_blob.cold.1:         ## @inspect_read_file_blob.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_file.cold.1
_inspect_manifest_require_file.cold.1:  ## @inspect_manifest_require_file.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.253(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.1
_load_pi4_app_catalog.cold.1:           ## @load_pi4_app_catalog.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdi
	leaq	L_.str.272(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.2
_load_pi4_app_catalog.cold.2:           ## @load_pi4_app_catalog.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.275(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	leaq	L_.str.256(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.3
_load_pi4_app_catalog.cold.3:           ## @load_pi4_app_catalog.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.262(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.4
_load_pi4_app_catalog.cold.4:           ## @load_pi4_app_catalog.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	L_.str.266(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.5
_load_pi4_app_catalog.cold.5:           ## @load_pi4_app_catalog.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	L_.str.266(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.6
_load_pi4_app_catalog.cold.6:           ## @load_pi4_app_catalog.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	L_.str.265(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.7
_load_pi4_app_catalog.cold.7:           ## @load_pi4_app_catalog.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	L_.str.265(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.8
_load_pi4_app_catalog.cold.8:           ## @load_pi4_app_catalog.cold.8
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	L_.str.220(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.9
_load_pi4_app_catalog.cold.9:           ## @load_pi4_app_catalog.cold.9
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	L_.str.220(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.10
_load_pi4_app_catalog.cold.10:          ## @load_pi4_app_catalog.cold.10
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	L_.str.264(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.11
_load_pi4_app_catalog.cold.11:          ## @load_pi4_app_catalog.cold.11
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	L_.str.264(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.12
_load_pi4_app_catalog.cold.12:          ## @load_pi4_app_catalog.cold.12
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	L_.str.263(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.13
_load_pi4_app_catalog.cold.13:          ## @load_pi4_app_catalog.cold.13
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	L_.str.263(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.14
_load_pi4_app_catalog.cold.14:          ## @load_pi4_app_catalog.cold.14
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	L_.str.259(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.15
_load_pi4_app_catalog.cold.15:          ## @load_pi4_app_catalog.cold.15
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	L_.str.259(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.16
_load_pi4_app_catalog.cold.16:          ## @load_pi4_app_catalog.cold.16
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.17
_load_pi4_app_catalog.cold.17:          ## @load_pi4_app_catalog.cold.17
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.18
_load_pi4_app_catalog.cold.18:          ## @load_pi4_app_catalog.cold.18
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.19
_load_pi4_app_catalog.cold.19:          ## @load_pi4_app_catalog.cold.19
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.20
_load_pi4_app_catalog.cold.20:          ## @load_pi4_app_catalog.cold.20
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rcx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.21
_load_pi4_app_catalog.cold.21:          ## @load_pi4_app_catalog.cold.21
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.277(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.22
_load_pi4_app_catalog.cold.22:          ## @load_pi4_app_catalog.cold.22
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.257(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.23
_load_pi4_app_catalog.cold.23:          ## @load_pi4_app_catalog.cold.23
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	leaq	L_.str.256(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.24
_load_pi4_app_catalog.cold.24:          ## @load_pi4_app_catalog.cold.24
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdx
	leaq	L_.str.256(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.25
_load_pi4_app_catalog.cold.25:          ## @load_pi4_app_catalog.cold.25
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdi
	leaq	L_.str.273(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function load_pi4_app_catalog.cold.26
_load_pi4_app_catalog.cold.26:          ## @load_pi4_app_catalog.cold.26
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	_PI4_APP_INDEX_PATH(%rip), %rdi
	leaq	L_.str.271(%rip), %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_indexed_sized_file.cold.1
_inspect_manifest_require_indexed_sized_file.cold.1: ## @inspect_manifest_require_indexed_sized_file.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_indexed_sized_file.cold.2
_inspect_manifest_require_indexed_sized_file.cold.2: ## @inspect_manifest_require_indexed_sized_file.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.247(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_indexed_sized_file.cold.3
_inspect_manifest_require_indexed_sized_file.cold.3: ## @inspect_manifest_require_indexed_sized_file.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.297(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_indexed_sized_file.cold.4
_inspect_manifest_require_indexed_sized_file.cold.4: ## @inspect_manifest_require_indexed_sized_file.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function inspect_manifest_require_indexed_sized_file.cold.5
_inspect_manifest_require_indexed_sized_file.cold.5: ## @inspect_manifest_require_indexed_sized_file.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.295(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function manifest_get_value.cold.1
_manifest_get_value.cold.1:             ## @manifest_get_value.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.298(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function manifest_require_u64.cold.1
_manifest_require_u64.cold.1:           ## @manifest_require_u64.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.246(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function manifest_require_u64.cold.2
_manifest_require_u64.cold.2:           ## @manifest_require_u64.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.245(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_manifest_require_value.cold.1
_text_manifest_require_value.cold.1:    ## @text_manifest_require_value.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.274(%rip), %rsi
	leaq	L_.str.155(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_manifest_require_value.cold.2
_text_manifest_require_value.cold.2:    ## @text_manifest_require_value.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.279(%rip), %rsi
	leaq	L_.str.155(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_manifest_require_value.cold.3
_text_manifest_require_value.cold.3:    ## @text_manifest_require_value.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.278(%rip), %rsi
	leaq	L_.str.155(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function reject_repo_local_external_asset.cold.1
_reject_repo_local_external_asset.cold.1: ## @reject_repo_local_external_asset.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.317(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function reject_repo_local_external_asset.cold.2
_reject_repo_local_external_asset.cold.2: ## @reject_repo_local_external_asset.cold.2
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
	.p2align	4                               ## -- Begin function reject_repo_local_external_asset.cold.3
_reject_repo_local_external_asset.cold.3: ## @reject_repo_local_external_asset.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	leaq	L_.str.120(%rip), %rdi
	movq	%rax, %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump.cold.1
_add_lump.cold.1:                       ## @add_lump.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.395(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump.cold.2
_add_lump.cold.2:                       ## @add_lump.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.394(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function add_lump.cold.3
_add_lump.cold.3:                       ## @add_lump.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function proof_manifest_require_root_file.cold.1
_proof_manifest_require_root_file.cold.1: ## @proof_manifest_require_root_file.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.496(%rip), %rsi
	leaq	L_.str.494(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function proof_manifest_require_root_file.cold.2
_proof_manifest_require_root_file.cold.2: ## @proof_manifest_require_root_file.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.36(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function proof_manifest_require_root_file.cold.3
_proof_manifest_require_root_file.cold.3: ## @proof_manifest_require_root_file.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.495(%rip), %rsi
	leaq	L_.str.494(%rip), %rcx
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_appendf.cold.1
_text_appendf.cold.1:                   ## @text_appendf.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_appendf.cold.2
_text_appendf.cold.2:                   ## @text_appendf.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.498(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_appendf.cold.3
_text_appendf.cold.3:                   ## @text_appendf.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function text_appendf.cold.4
_text_appendf.cold.4:                   ## @text_appendf.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.29(%rip), %rdi
	callq	_die
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
	.asciz	"--proof-manifest"

L_.str.17:                              ## @.str.17
	.asciz	"--inspect"

L_.str.18:                              ## @.str.18
	.asciz	"--require-real-assets"

L_.str.19:                              ## @.str.19
	.asciz	"--require-file"

L_.str.20:                              ## @.str.20
	.asciz	"--root-elf"

L_.str.21:                              ## @.str.21
	.asciz	"duplicate --root-elf entry"

L_.str.22:                              ## @.str.22
	.asciz	"--root-file"

L_.str.23:                              ## @.str.23
	.asciz	"duplicate --root-file entry"

L_.str.24:                              ## @.str.24
	.asciz	"--asset"

L_.str.25:                              ## @.str.25
	.asciz	"duplicate --root-elf FAT16 name"

L_.str.26:                              ## @.str.26
	.asciz	"duplicate --root-file FAT16 name"

L_.str.27:                              ## @.str.27
	.asciz	"--root-file conflicts with --root-elf FAT16 name"

L_.str.28:                              ## @.str.28
	.asciz	"bootable image positional inputs are image, stage1, stage2, kernel, and user probe only"

L_.str.29:                              ## @.str.29
	.asciz	"out of memory"

L_.str.30:                              ## @.str.30
	.asciz	"unexpected disk image size"

L_.str.31:                              ## @.str.31
	.asciz	"rb"

L_.str.32:                              ## @.str.32
	.asciz	"seek failed"

L_.str.33:                              ## @.str.33
	.asciz	"tell failed"

L_.str.34:                              ## @.str.34
	.asciz	"read failed"

L_.str.35:                              ## @.str.35
	.asciz	"make_wad_image: %s: %s\n"

L_.str.36:                              ## @.str.36
	.asciz	"read past end"

L_.str.37:                              ## @.str.37
	.asciz	"PERSISTENCE_CHECKPOINT_NAME"

	.section	__TEXT,__const
_PERSISTENCE_CHECKPOINT_NAME:           ## @PERSISTENCE_CHECKPOINT_NAME
	.asciz	"PERSIST CHK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.38:                              ## @.str.38
	.asciz	"SAVE_REQUEST_NAME"

	.section	__TEXT,__const
_SAVE_REQUEST_NAME:                     ## @SAVE_REQUEST_NAME
	.asciz	"SAVEREQ CHK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.39:                              ## @.str.39
	.asciz	"LOAD_REQUEST_NAME"

	.section	__TEXT,__const
_LOAD_REQUEST_NAME:                     ## @LOAD_REQUEST_NAME
	.asciz	"LOADREQ CHK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.40:                              ## @.str.40
	.asciz	"unknown root marker symbol"

L_.str.41:                              ## @.str.41
	.asciz	"cluster outside FAT16 data area"

L_.str.42:                              ## @.str.42
	.asciz	"FAT16 file path is empty"

L_.str.43:                              ## @.str.43
	.asciz	"FAT16 path component exists but is not a directory"

L_.str.44:                              ## @.str.44
	.asciz	".          "

L_.str.45:                              ## @.str.45
	.asciz	"..         "

L_.str.46:                              ## @.str.46
	.asciz	"file does not fit in FAT16 data area"

L_.str.47:                              ## @.str.47
	.asciz	"FAT16 directory is full"

L_.str.48:                              ## @.str.48
	.asciz	"write past end"

L_.str.49:                              ## @.str.49
	.asciz	"usage: make_wad_image [--require-real-assets] [--require-file FAT_PATH] --inspect IMAGE\n       make_wad_image [--proof-manifest] [--primary-asset-wad PATH|--wad PATH] [--root-elf NAME.ELF=PATH] [--root-file NAME.EXT=PATH] [--asset IMAGE_8.3_PATH=HOST_PATH] OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF]]\n       make_wad_image --write-root-marker SYMBOL APP IMAGE\n       make_wad_image --delete-root-marker SYMBOL IMAGE\n       make_wad_image --check-persistence IMAGE [--baseline-image IMAGE] [--reboot-baseline-image IMAGE] [--write-status FILE] [--save-write-status FILE] [--load-status FILE] [--reboot-status FILE] [--require-default] [--require-dynamic-fat-proof] [--require-save-slot N] [--require-save-description N=TEXT]"

L_.str.50:                              ## @.str.50
	.asciz	"--require-save-slot expects slot 0..5"

L_.str.51:                              ## @.str.51
	.asciz	"too many save slots requested"

L_.str.52:                              ## @.str.52
	.asciz	"--require-save-description expects SLOT=TEXT with slot 0..5"

L_.str.53:                              ## @.str.53
	.asciz	"dynamic FAT proof was requested without a write status file"

L_.str.55:                              ## @.str.55
	.asciz	"image=%s\n"

L_.str.56:                              ## @.str.56
	.asciz	"default_cfg=%s\n"

L_.str.57:                              ## @.str.57
	.asciz	"checked"

L_.str.58:                              ## @.str.58
	.asciz	"not-requested"

L_.str.59:                              ## @.str.59
	.asciz	"save_slot_%d=checked\n"

L_.str.61:                              ## @.str.61
	.asciz	"unexpected image size"

L_.str.62:                              ## @.str.62
	.asciz	"missing MBR signature"

L_.str.63:                              ## @.str.63
	.asciz	"unexpected partition layout"

L_.str.64:                              ## @.str.64
	.asciz	"missing FAT boot signature"

L_.str.65:                              ## @.str.65
	.asciz	"unexpected FAT bytes per sector"

L_.str.66:                              ## @.str.66
	.asciz	"unexpected FAT sectors per cluster"

	.section	__TEXT,__const
_DEFAULT_CFG_NAME:                      ## @DEFAULT_CFG_NAME
	.asciz	"DEFAULT CFG"

	.section	__TEXT,__cstring,cstring_literals
L_.str.67:                              ## @.str.67
	.asciz	"DEFAULT.CFG is missing from the FAT root"

L_.str.68:                              ## @.str.68
	.asciz	"DEFAULT.CFG is a directory"

L_.str.69:                              ## @.str.69
	.asciz	"DEFAULT.CFG was not written"

L_.str.70:                              ## @.str.70
	.asciz	"DEFAULT.CFG did not change from the persistence baseline"

L_.str.71:                              ## @.str.71
	.asciz	"left image"

L_.str.72:                              ## @.str.72
	.asciz	"right image"

L_.str.73:                              ## @.str.73
	.asciz	"file has invalid first cluster"

L_.str.74:                              ## @.str.74
	.asciz	"file cluster chain is invalid"

L_.str.75:                              ## @.str.75
	.asciz	"file cluster chain ended early"

L_.str.77:                              ## @.str.77
	.asciz	"required save slot is missing from the FAT root"

L_.str.78:                              ## @.str.78
	.asciz	"required save slot is a directory"

L_.str.79:                              ## @.str.79
	.asciz	"required save slot is too small to prove persistence"

L_.str.80:                              ## @.str.80
	.asciz	"required save slot did not change from the persistence baseline"

L_.str.81:                              ## @.str.81
	.asciz	"required save slot changed across reboot/load proof"

L_.str.82:                              ## @.str.82
	.asciz	"save slot"

L_.str.83:                              ## @.str.83
	.asciz	"required save description is longer than Doom's save title field"

L_.str.84:                              ## @.str.84
	.asciz	"required save slot does not contain the requested description"

L_.str.85:                              ## @.str.85
	.asciz	"version "

L_.str.86:                              ## @.str.86
	.asciz	"required save slot does not contain the expected version header"

L_.str.87:                              ## @.str.87
	.asciz	"save slot must be 0..5"

_PRIMARY_SAVE_SLOT_TEMPLATE_NAME:       ## @PRIMARY_SAVE_SLOT_TEMPLATE_NAME
	.asciz	"DOOMSAV DSG"

L_.str.88:                              ## @.str.88
	.asciz	"savewr"

L_.str.89:                              ## @.str.89
	.asciz	"save write status did not prove save slot bytes and calls"

L_.str.90:                              ## @.str.90
	.asciz	"saveclose"

L_.str.91:                              ## @.str.91
	.asciz	"save write status did not prove close"

L_.str.92:                              ## @.str.92
	.asciz	"doomwrite"

L_.str.93:                              ## @.str.93
	.asciz	"write status did not prove file writes"

L_.str.94:                              ## @.str.94
	.asciz	"doomclose"

L_.str.95:                              ## @.str.95
	.asciz	"write status did not prove closes"

L_.str.96:                              ## @.str.96
	.asciz	"required status tuple is missing"

L_.str.97:                              ## @.str.97
	.asciz	"status tuple has too few parts"

L_.str.98:                              ## @.str.98
	.asciz	"status field did not contain a hex value"

L_.str.99:                              ## @.str.99
	.asciz	"required status field is missing"

L_.str.100:                             ## @.str.100
	.asciz	"gameplay=OK"

L_.str.101:                             ## @.str.101
	.asciz	"load status did not return to gameplay"

L_.str.102:                             ## @.str.102
	.asciz	"saverd"

L_.str.103:                             ## @.str.103
	.asciz	"load status did not prove save slot reads"

L_.str.104:                             ## @.str.104
	.asciz	"panic="

L_.str.105:                             ## @.str.105
	.asciz	"panic=NONE"

L_.str.106:                             ## @.str.106
	.asciz	"load status reported a panic"

L_.str.107:                             ## @.str.107
	.asciz	"reboot status did not return to gameplay"

L_.str.108:                             ## @.str.108
	.asciz	"reboot status reported a panic"

L_.str.109:                             ## @.str.109
	.asciz	"fatdyn"

L_.str.110:                             ## @.str.110
	.asciz	"fatdyn status did not prove dynamic FAT activity"

L_.str.111:                             ## @.str.111
	.asciz	"--root-elf must be NAME.ELF=PATH"

L_.str.112:                             ## @.str.112
	.asciz	"--root-elf display name is too long"

L_.str.113:                             ## @.str.113
	.asciz	"--root-elf must be a root-level NAME.ELF"

L_.str.114:                             ## @.str.114
	.asciz	"ELF"

L_.str.115:                             ## @.str.115
	.asciz	"--root-elf name must use .ELF"

L_.str.116:                             ## @.str.116
	.asciz	"FAT16 path must not be empty"

L_.str.117:                             ## @.str.117
	.asciz	"FAT16 path is too deep"

L_.str.118:                             ## @.str.118
	.asciz	".."

L_.str.119:                             ## @.str.119
	.asciz	"FAT16 path must not use dot traversal"

L_.str.120:                             ## @.str.120
	.asciz	"."

L_.str.121:                             ## @.str.121
	.asciz	"FAT16 path component is too long"

L_.str.122:                             ## @.str.122
	.asciz	"FAT16 path must name at least one component"

L_.str.123:                             ## @.str.123
	.asciz	"FAT16 path component must fit 8.3"

L_.str.124:                             ## @.str.124
	.asciz	"FAT16 path component has too many dots"

L_.str.125:                             ## @.str.125
	.asciz	"FAT16 path component has unsupported characters"

L_.str.126:                             ## @.str.126
	.asciz	"FAT16 extension has unsupported characters"

	.section	__TEXT,__const
_PRIMARY_ASSET_WAD_NAME:                ## @PRIMARY_ASSET_WAD_NAME
	.asciz	"DOOM1   WAD"

_KERNEL_ELF_NAME:                       ## @KERNEL_ELF_NAME
	.asciz	"KERNEL  ELF"

_USER_PROBE_NAME:                       ## @USER_PROBE_NAME
	.asciz	"USERPROBELF"

	.section	__TEXT,__cstring,cstring_literals
L_.str.127:                             ## @.str.127
	.asciz	"root file option tries to replace a protected boot entry"

L_.str.128:                             ## @.str.128
	.asciz	"make_wad_image: %s\n"

L_.str.129:                             ## @.str.129
	.asciz	"--root-file must be NAME.EXT=PATH"

L_.str.130:                             ## @.str.130
	.asciz	"--root-file display name is too long"

L_.str.131:                             ## @.str.131
	.asciz	"--root-file must be a root-level 8.3 file name"

L_.str.132:                             ## @.str.132
	.asciz	"--asset must be IMAGE_8.3_PATH=HOST_PATH"

L_.str.133:                             ## @.str.133
	.asciz	"--asset display path is too long"

L_.str.135:                             ## @.str.135
	.asciz	"image_path=%s\n"

L_.str.136:                             ## @.str.136
	.asciz	"image_size=%zu\n"

L_.str.137:                             ## @.str.137
	.asciz	"partition_lba=%u\n"

L_.str.138:                             ## @.str.138
	.asciz	"partition_sectors=%u\n"

L_.str.139:                             ## @.str.139
	.asciz	"root_lba=%u\n"

L_.str.140:                             ## @.str.140
	.asciz	"data_lba=%u\n"

L_.str.141:                             ## @.str.141
	.asciz	"root_entry_count=%u\n"

L_.str.142:                             ## @.str.142
	.asciz	"data_clusters=%u\n"

L_.str.143:                             ## @.str.143
	.asciz	"root[%u]=%s attr=0x%02X cluster=%u size=%u\n"

L_.str.144:                             ## @.str.144
	.asciz	"%s/%s"

L_.str.145:                             ## @.str.145
	.asciz	"inspect path is too long"

L_.str.146:                             ## @.str.146
	.asciz	"path=%s attr=0x%02X cluster=%u size=%u\n"

L_.str.147:                             ## @.str.147
	.asciz	"required FAT file is missing"

L_.str.148:                             ## @.str.148
	.asciz	"required FAT path is a directory"

L_.str.149:                             ## @.str.149
	.asciz	"required FAT file is empty"

L_.str.150:                             ## @.str.150
	.asciz	"required FAT file has invalid first cluster"

L_.str.151:                             ## @.str.151
	.asciz	"required_file=%s state=present size=%u cluster=%u\n"

L_.str.152:                             ## @.str.152
	.asciz	"directory has invalid first cluster"

L_.str.153:                             ## @.str.153
	.asciz	"inspect path component is too long"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PROOF_MANIFEST_PATH
_PROOF_MANIFEST_PATH:
	.asciz	"/PROOF/MANIFEST.TXT"

	.section	__TEXT,__cstring,cstring_literals
L_.str.154:                             ## @.str.154
	.asciz	"Pi proof manifest is required for real asset proof"

L_.str.155:                             ## @.str.155
	.asciz	"schema"

L_.str.156:                             ## @.str.156
	.asciz	"vibe-os-pi4-image-manifest-v1"

L_.str.157:                             ## @.str.157
	.asciz	"layout"

L_.str.158:                             ## @.str.158
	.asciz	"vibe-os-pi4-fat16-v1"

L_.str.159:                             ## @.str.159
	.asciz	"root_lba"

L_.str.160:                             ## @.str.160
	.asciz	"data_lba"

L_.str.161:                             ## @.str.161
	.asciz	"root_entry_count"

L_.str.162:                             ## @.str.162
	.asciz	"manifest_path"

L_.str.163:                             ## @.str.163
	.asciz	"manifest_path=%s state=present size=%u\n"

L_.str.164:                             ## @.str.164
	.asciz	"kernel_file"

L_.str.165:                             ## @.str.165
	.asciz	"KERNEL8.IMG"

L_.str.166:                             ## @.str.166
	.asciz	"kernel_size"

L_.str.167:                             ## @.str.167
	.asciz	"config_file"

L_.str.168:                             ## @.str.168
	.asciz	"CONFIG.TXT"

L_.str.169:                             ## @.str.169
	.asciz	"config_size"

L_.str.170:                             ## @.str.170
	.asciz	"app_model_schema"

L_.str.171:                             ## @.str.171
	.asciz	"vibe-os-pi4-app-install-v1"

L_.str.172:                             ## @.str.172
	.asciz	"app_layout"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PI4_APP_LAYOUT
_PI4_APP_LAYOUT:
	.asciz	"system-init-plus-apps-tree"

	.section	__TEXT,__cstring,cstring_literals
L_.str.173:                             ## @.str.173
	.asciz	"app_discovery_model"

	.section	__TEXT,__const
_PI4_APP_DISCOVERY_MODEL:               ## @PI4_APP_DISCOVERY_MODEL
	.asciz	"vfs-app-index"

	.section	__TEXT,__cstring,cstring_literals
L_.str.174:                             ## @.str.174
	.asciz	"app_launch_model"

L_.str.175:                             ## @.str.175
	.asciz	"generic-vfs-path-exec"

L_.str.176:                             ## @.str.176
	.asciz	"app_exec_model"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PI4_APP_EXEC_MODEL
_PI4_APP_EXEC_MODEL:
	.asciz	"generic-aarch64-el0-elf-by-path"

	.section	__TEXT,__cstring,cstring_literals
L_.str.177:                             ## @.str.177
	.asciz	"system_init"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PI4_SYSTEM_INIT_PATH
_PI4_SYSTEM_INIT_PATH:
	.asciz	"/SYSTEM/INIT.ELF"

	.section	__TEXT,__cstring,cstring_literals
L_.str.178:                             ## @.str.178
	.asciz	"system_init_size"

L_.str.179:                             ## @.str.179
	.asciz	"system_abiprobe"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PI4_SYSTEM_ABIPROBE_PATH
_PI4_SYSTEM_ABIPROBE_PATH:
	.asciz	"/SYSTEM/ABIPROBE.ELF"

	.section	__TEXT,__cstring,cstring_literals
L_.str.180:                             ## @.str.180
	.asciz	"system_abiprobe_size"

L_.str.181:                             ## @.str.181
	.asciz	"app_index"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PI4_APP_INDEX_PATH
_PI4_APP_INDEX_PATH:
	.asciz	"/APPS/INDEX.TXT"

	.section	__TEXT,__cstring,cstring_literals
L_.str.182:                             ## @.str.182
	.asciz	"app_index_size"

L_.str.183:                             ## @.str.183
	.asciz	"%zu"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PI4_APP_RECORD_COUNT_KEY
_PI4_APP_RECORD_COUNT_KEY:
	.asciz	"app_record_count"

_PI4_APP_RECORD_PREFIX:                 ## @PI4_APP_RECORD_PREFIX
	.asciz	"app_record"

	.section	__TEXT,__cstring,cstring_literals
L_.str.184:                             ## @.str.184
	.asciz	"root_file_count"

L_.str.185:                             ## @.str.185
	.asciz	"root_file"

L_.str.186:                             ## @.str.186
	.asciz	"root_elf_count"

L_.str.187:                             ## @.str.187
	.asciz	"root_elf"

L_.str.188:                             ## @.str.188
	.asciz	"primary_asset_file"

L_.str.189:                             ## @.str.189
	.asciz	"DOOM1.WAD"

L_.str.190:                             ## @.str.190
	.asciz	"primary_asset_kind"

L_.str.191:                             ## @.str.191
	.asciz	"doom-wad"

L_.str.192:                             ## @.str.192
	.asciz	"primary_asset_state"

L_.str.193:                             ## @.str.193
	.asciz	"present"

L_.str.194:                             ## @.str.194
	.asciz	"primary_asset_source"

L_.str.195:                             ## @.str.195
	.asciz	"Pi proof manifest is missing primary WAD source"

L_.str.196:                             ## @.str.196
	.asciz	"primary_asset_repo_state"

L_.str.197:                             ## @.str.197
	.asciz	"Pi proof manifest is missing primary WAD repo state"

L_.str.198:                             ## @.str.198
	.asciz	"external"

L_.str.199:                             ## @.str.199
	.asciz	"outside-repo"

L_.str.200:                             ## @.str.200
	.asciz	"Pi proof manifest external WAD must be marked outside-repo"

L_.str.201:                             ## @.str.201
	.asciz	"generated-fixture"

L_.str.202:                             ## @.str.202
	.asciz	"generated-by-builder"

L_.str.203:                             ## @.str.203
	.asciz	"Pi proof manifest generated WAD must be marked generated-by-builder"

L_.str.204:                             ## @.str.204
	.asciz	"Pi proof manifest primary WAD source must be external or generated-fixture"

L_.str.205:                             ## @.str.205
	.asciz	"primary_asset_evidence"

L_.str.206:                             ## @.str.206
	.asciz	"packaged-file-only"

L_.str.207:                             ## @.str.207
	.asciz	"primary_asset_hardware_proof"

L_.str.208:                             ## @.str.208
	.asciz	"unclaimed"

L_.str.209:                             ## @.str.209
	.asciz	"primary_asset_size"

L_.str.210:                             ## @.str.210
	.asciz	"manifest_asset=DOOM1.WAD kind=doom-wad source=%s repo_state=%s evidence=packaged-file-only hardware_proof=unclaimed state=present\n"

L_.str.211:                             ## @.str.211
	.asciz	"default_asset_count"

L_.str.213:                             ## @.str.213
	.asciz	"default_asset.0.file"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @DEFAULT_PI4_ASSET_README_PATH
_DEFAULT_PI4_ASSET_README_PATH:
	.asciz	"/ASSETS/README.TXT"

	.section	__TEXT,__cstring,cstring_literals
L_.str.214:                             ## @.str.214
	.asciz	"default_asset.0.size"

L_.str.215:                             ## @.str.215
	.asciz	"default_asset.1.file"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @DEFAULT_PI4_ASSET_MAP_PATH
_DEFAULT_PI4_ASSET_MAP_PATH:
	.asciz	"/ASSETS/MAPS/E1M1.MAP"

	.section	__TEXT,__cstring,cstring_literals
L_.str.216:                             ## @.str.216
	.asciz	"default_asset.1.size"

L_.str.217:                             ## @.str.217
	.asciz	"default_asset.2.file"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @DEFAULT_PI4_ASSET_PALETTE_PATH
_DEFAULT_PI4_ASSET_PALETTE_PATH:
	.asciz	"/ASSETS/TEXTURES/PAL0.BIN"

	.section	__TEXT,__cstring,cstring_literals
L_.str.218:                             ## @.str.218
	.asciz	"default_asset.2.size"

L_.str.219:                             ## @.str.219
	.asciz	"asset_count"

L_.str.220:                             ## @.str.220
	.asciz	"asset"

L_.str.221:                             ## @.str.221
	.asciz	"quake_pak_file"

	.section	__TEXT,__const
_PROOF_QUAKE_PAK_PATH:                  ## @PROOF_QUAKE_PAK_PATH
	.asciz	"/ID1/PAK0.PAK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.222:                             ## @.str.222
	.asciz	"quake_pak_kind"

L_.str.223:                             ## @.str.223
	.asciz	"quake-pak"

L_.str.224:                             ## @.str.224
	.asciz	"quake_pak_state"

L_.str.225:                             ## @.str.225
	.asciz	"Pi proof manifest is missing Quake PAK state"

L_.str.226:                             ## @.str.226
	.asciz	"absent"

L_.str.227:                             ## @.str.227
	.asciz	"quake_pak_source"

L_.str.228:                             ## @.str.228
	.asciz	"quake_pak_repo_state"

L_.str.229:                             ## @.str.229
	.asciz	"quake_pak_evidence"

L_.str.230:                             ## @.str.230
	.asciz	"quake_pak_hardware_proof"

L_.str.231:                             ## @.str.231
	.asciz	"manifest_asset=%s kind=quake-pak source=absent repo_state=absent evidence=absent hardware_proof=unclaimed state=absent\n"

L_.str.232:                             ## @.str.232
	.asciz	"quake_pak_size"

L_.str.233:                             ## @.str.233
	.asciz	"manifest_asset=%s kind=quake-pak source=external repo_state=outside-repo evidence=packaged-file-only hardware_proof=unclaimed state=present\n"

L_.str.234:                             ## @.str.234
	.asciz	"Pi proof manifest Quake PAK state must be present or absent"

L_.str.235:                             ## @.str.235
	.asciz	"manifest_asset_handoff=OK primary_asset_state=present primary_asset_source=%s primary_asset_evidence=packaged-file-only primary_asset_hardware_proof=unclaimed quake_pak_state=%s quake_pak_evidence=%s quake_pak_hardware_proof=unclaimed\n"

L_.str.236:                             ## @.str.236
	.asciz	"real Pi asset proof requires an external outside-repo Doom WAD"

L_.str.237:                             ## @.str.237
	.asciz	"real Pi asset proof requires an external outside-repo Quake PAK"

L_.str.238:                             ## @.str.238
	.asciz	"real Pi asset proof requires checked_files to include /ID1/PAK0.PAK"

L_.str.240:                             ## @.str.240
	.asciz	"pi4_manifest=OK checked_files=%zu\n"

L_.str.241:                             ## @.str.241
	.asciz	"expected a file, found a directory"

L_.str.242:                             ## @.str.242
	.asciz	"Pi proof manifest is missing a required field"

L_.str.243:                             ## @.str.243
	.asciz	"Pi proof manifest field does not match the boot artifact"

L_.str.244:                             ## @.str.244
	.asciz	"Pi proof manifest numeric field does not match the boot artifact"

L_.str.245:                             ## @.str.245
	.asciz	"Pi proof manifest is missing a required size field"

L_.str.246:                             ## @.str.246
	.asciz	"Pi proof manifest size field is not decimal"

L_.str.247:                             ## @.str.247
	.asciz	"Pi proof manifest is missing a command-visible field"

L_.str.248:                             ## @.str.248
	.asciz	"%s=%s\n"

L_.str.249:                             ## @.str.249
	.asciz	"Pi proof manifest names a file missing from the FAT image"

L_.str.250:                             ## @.str.250
	.asciz	"Pi proof manifest expected a file, found a directory"

L_.str.251:                             ## @.str.251
	.asciz	"Pi proof manifest file is empty"

L_.str.252:                             ## @.str.252
	.asciz	"manifest_file=%s state=present size=%u cluster=%u\n"

L_.str.253:                             ## @.str.253
	.asciz	"Pi proof manifest file size does not match the FAT image"

L_.str.255:                             ## @.str.255
	.asciz	"vibe-os-app-index-v1"

L_.str.256:                             ## @.str.256
	.asciz	"app_count"

L_.str.257:                             ## @.str.257
	.asciz	"Pi app index app_count is outside the supported app catalog"

L_.str.258:                             ## @.str.258
	.asciz	"app"

L_.str.259:                             ## @.str.259
	.asciz	"id"

L_.str.260:                             ## @.str.260
	.asciz	"manifest"

L_.str.261:                             ## @.str.261
	.asciz	"vibe-os-app-v1"

L_.str.262:                             ## @.str.262
	.asciz	"make_wad_image: %s: app id does not match /APPS/INDEX.TXT\n"

L_.str.263:                             ## @.str.263
	.asciz	"name"

L_.str.264:                             ## @.str.264
	.asciz	"exec"

L_.str.265:                             ## @.str.265
	.asciz	"icon"

L_.str.266:                             ## @.str.266
	.asciz	"input"

L_.str.267:                             ## @.str.267
	.asciz	"Pi app manifest exec target is missing from the FAT image"

L_.str.268:                             ## @.str.268
	.asciz	"Pi app manifest exec target must be a nonempty file"

L_.str.269:                             ## @.str.269
	.asciz	"Pi app manifest resource must be a nonempty file"

L_.str.270:                             ## @.str.270
	.asciz	"real Pi app layout requires the manifest resource file"

L_.str.271:                             ## @.str.271
	.asciz	"Pi app layout names a file missing from the FAT image"

L_.str.272:                             ## @.str.272
	.asciz	"Pi app layout expected a file, found a directory"

L_.str.273:                             ## @.str.273
	.asciz	"Pi app layout file is empty"

L_.str.274:                             ## @.str.274
	.asciz	"make_wad_image: %s: app manifest field %s does not match image layout\n"

L_.str.275:                             ## @.str.275
	.asciz	"make_wad_image: %s: app manifest field %s is not decimal\n"

L_.str.276:                             ## @.str.276
	.asciz	"%s.%zu.%s"

L_.str.277:                             ## @.str.277
	.asciz	"manifest indexed key is too long"

L_.str.278:                             ## @.str.278
	.asciz	"make_wad_image: %s: missing app manifest field %s\n"

L_.str.279:                             ## @.str.279
	.asciz	"make_wad_image: %s: empty app manifest field %s\n"

L_.str.280:                             ## @.str.280
	.asciz	"app_index_manifest=%s state=present schema=vibe-os-app-index-v1 app_count=%zu discovery=%s\n"

L_.str.281:                             ## @.str.281
	.asciz	"manifest_size"

L_.str.282:                             ## @.str.282
	.asciz	"exec_size"

L_.str.283:                             ## @.str.283
	.asciz	"launch"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @PI4_APP_LAUNCH_MODEL
_PI4_APP_LAUNCH_MODEL:
	.asciz	"generic-path-exec"

	.section	__TEXT,__cstring,cstring_literals
L_.str.284:                             ## @.str.284
	.asciz	"exec_model"

L_.str.285:                             ## @.str.285
	.asciz	"resource"

L_.str.286:                             ## @.str.286
	.asciz	"hardware_proof"

L_.str.287:                             ## @.str.287
	.asciz	"%s=%zu state=present id=%s manifest=%s exec=%s resource=%s icon=%s launch=%s exec_model=%s\n"

L_.str.288:                             ## @.str.288
	.asciz	"app_manifest=%s state=present id=%s exec=%s icon=%s resource=%s input=%s\n"

L_.str.289:                             ## @.str.289
	.asciz	"app_exec=%s state=present model=%s app=%s size=%u cluster=%u\n"

L_.str.290:                             ## @.str.290
	.asciz	"app_icon=%s state=manifest app=%s\n"

L_.str.291:                             ## @.str.291
	.asciz	"app_resource=%s state=present app=%s source=manifest size=%u cluster=%u\n"

L_.str.292:                             ## @.str.292
	.asciz	"app_resource=%s state=absent app=%s source=manifest\n"

L_.str.293:                             ## @.str.293
	.asciz	"Pi proof manifest count is too large"

L_.str.294:                             ## @.str.294
	.asciz	"%s.%zu.file"

L_.str.295:                             ## @.str.295
	.asciz	"Pi proof manifest key is too long"

L_.str.296:                             ## @.str.296
	.asciz	"%s.%zu.size"

L_.str.297:                             ## @.str.297
	.asciz	"Pi proof manifest is missing an indexed file"

L_.str.298:                             ## @.str.298
	.asciz	"Pi proof manifest value is too long"

L_.str.299:                             ## @.str.299
	.asciz	"%s.%zu.kind"

L_.str.300:                             ## @.str.300
	.asciz	"%s.%zu.source"

L_.str.301:                             ## @.str.301
	.asciz	"%s.%zu.repo_state"

L_.str.302:                             ## @.str.302
	.asciz	"%s.%zu.evidence"

L_.str.303:                             ## @.str.303
	.asciz	"%s.%zu.hardware_proof"

L_.str.304:                             ## @.str.304
	.asciz	"external-host-input"

L_.str.305:                             ## @.str.305
	.asciz	"quake-pak0"

L_.str.306:                             ## @.str.306
	.asciz	"generic-external-asset"

L_.str.307:                             ## @.str.307
	.asciz	"unchecked"

L_.str.308:                             ## @.str.308
	.asciz	"stage1, stage2, and kernel paths must be provided together"

L_.str.309:                             ## @.str.309
	.asciz	"external Doom WAD"

L_.str.310:                             ## @.str.310
	.asciz	"primary WAD asset (DOOM1.WAD) must start at cluster 2"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @DEFAULT_CFG_CONTENT
_DEFAULT_CFG_CONTENT:
	.asciz	"screenblocks\t\t11\n"

	.section	__TEXT,__cstring,cstring_literals
L_.str.311:                             ## @.str.311
	.asciz	"FAT16 image does not leave enough OS-created file headroom"

L_.str.312:                             ## @.str.312
	.asciz	"stage1 must be exactly 512 bytes"

L_.str.313:                             ## @.str.313
	.asciz	"stage2"

L_.str.314:                             ## @.str.314
	.asciz	"kernel"

	.section	__TEXT,__const
_FAT_VOLUME_LABEL:                      ## @FAT_VOLUME_LABEL
	.asciz	"VIBEOS WAD "

	.section	__TEXT,__cstring,cstring_literals
L_.str.316:                             ## @.str.316
	.asciz	"make_wad_image: %s is %zu bytes, exceeds %zu bytes\n"

L_.str.317:                             ## @.str.317
	.asciz	"make_wad_image: %s: %s must stay outside the repo for Pi proof packaging\n"

L_.str.318:                             ## @.str.318
	.asciz	"WAD exceeds primary asset load limit"

L_.str.319:                             ## @.str.319
	.asciz	"too small to be a WAD"

L_.str.320:                             ## @.str.320
	.asciz	"IWAD"

L_.str.321:                             ## @.str.321
	.asciz	"PWAD"

L_.str.322:                             ## @.str.322
	.asciz	"does not start with IWAD or PWAD"

L_.str.323:                             ## @.str.323
	.asciz	"WAD has no lumps"

L_.str.324:                             ## @.str.324
	.asciz	"WAD directory is outside the file"

L_.str.325:                             ## @.str.325
	.asciz	"WAD marker lump points outside the file"

L_.str.326:                             ## @.str.326
	.asciz	"WAD lump data is outside the file"

L_.str.327:                             ## @.str.327
	.asciz	"F_SKY1"

L_.str.328:                             ## @.str.328
	.asciz	"PLAYPAL"

L_.str.329:                             ## @.str.329
	.asciz	"COLORMAP"

L_.str.330:                             ## @.str.330
	.asciz	"PNAMES"

L_.str.331:                             ## @.str.331
	.asciz	"TEXTURE1"

L_.str.332:                             ## @.str.332
	.asciz	"F_START"

L_.str.333:                             ## @.str.333
	.asciz	"F_END"

L_.str.334:                             ## @.str.334
	.asciz	"S_START"

L_.str.335:                             ## @.str.335
	.asciz	"S_END"

L_.str.336:                             ## @.str.336
	.asciz	"SYNTHPCH"

L_.str.337:                             ## @.str.337
	.asciz	"D_INTRO"

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @FIXTURE_MUS_SCORE_END
_FIXTURE_MUS_SCORE_END:
	.ascii	"MUS\032\001\000\020\000\001\000\000\000\000\000\000\000`"

	.section	__TEXT,__cstring,cstring_literals
L_.str.338:                             ## @.str.338
	.asciz	"D_E1M1"

L_.str.340:                             ## @.str.340
	.asciz	"THINGS"

L_.str.341:                             ## @.str.341
	.asciz	"LINEDEFS"

L_.str.342:                             ## @.str.342
	.asciz	"SIDEDEFS"

L_.str.343:                             ## @.str.343
	.asciz	"VERTEXES"

L_.str.344:                             ## @.str.344
	.asciz	"SEGS"

L_.str.345:                             ## @.str.345
	.asciz	"SSECTORS"

L_.str.346:                             ## @.str.346
	.asciz	"NODES"

L_.str.347:                             ## @.str.347
	.asciz	"SECTORS"

L_.str.348:                             ## @.str.348
	.asciz	"REJECT"

L_.str.349:                             ## @.str.349
	.asciz	"BLOCKMAP"

L_.str.350:                             ## @.str.350
	.asciz	"generated WAD directory overflow"

	.p2align	4, 0x0                          ## @__const.build_generated_wad.pattern
L___const.build_generated_wad.pattern:
	.asciz	"vibe-os hard-path IDE FAT16 WAD fixture\n"

	.section	__DATA,__const
	.p2align	4, 0x0                          ## @switch_textures
_switch_textures:
	.quad	L_.str.351
	.quad	L_.str.352
	.quad	L_.str.353
	.quad	L_.str.354
	.quad	L_.str.355
	.quad	L_.str.356
	.quad	L_.str.357
	.quad	L_.str.358
	.quad	L_.str.359
	.quad	L_.str.360
	.quad	L_.str.361
	.quad	L_.str.362
	.quad	L_.str.363
	.quad	L_.str.364
	.quad	L_.str.365
	.quad	L_.str.366
	.quad	L_.str.367
	.quad	L_.str.368
	.quad	L_.str.369
	.quad	L_.str.370
	.quad	L_.str.371
	.quad	L_.str.372
	.quad	L_.str.373
	.quad	L_.str.374
	.quad	L_.str.375
	.quad	L_.str.376
	.quad	L_.str.377
	.quad	L_.str.378
	.quad	L_.str.379
	.quad	L_.str.380
	.quad	L_.str.381
	.quad	L_.str.382
	.quad	L_.str.383
	.quad	L_.str.384
	.quad	L_.str.385
	.quad	L_.str.386
	.quad	L_.str.387
	.quad	L_.str.388
	.quad	L_.str.389
	.quad	L_.str.390
	.quad	L_.str.391
	.quad	L_.str.392

	.section	__TEXT,__cstring,cstring_literals
L_.str.351:                             ## @.str.351
	.asciz	"SW1BRCOM"

L_.str.352:                             ## @.str.352
	.asciz	"SW2BRCOM"

L_.str.353:                             ## @.str.353
	.asciz	"SW1BRN1"

L_.str.354:                             ## @.str.354
	.asciz	"SW2BRN1"

L_.str.355:                             ## @.str.355
	.asciz	"SW1BRN2"

L_.str.356:                             ## @.str.356
	.asciz	"SW2BRN2"

L_.str.357:                             ## @.str.357
	.asciz	"SW1BRNGN"

L_.str.358:                             ## @.str.358
	.asciz	"SW2BRNGN"

L_.str.359:                             ## @.str.359
	.asciz	"SW1BROWN"

L_.str.360:                             ## @.str.360
	.asciz	"SW2BROWN"

L_.str.361:                             ## @.str.361
	.asciz	"SW1COMM"

L_.str.362:                             ## @.str.362
	.asciz	"SW2COMM"

L_.str.363:                             ## @.str.363
	.asciz	"SW1COMP"

L_.str.364:                             ## @.str.364
	.asciz	"SW2COMP"

L_.str.365:                             ## @.str.365
	.asciz	"SW1DIRT"

L_.str.366:                             ## @.str.366
	.asciz	"SW2DIRT"

L_.str.367:                             ## @.str.367
	.asciz	"SW1EXIT"

L_.str.368:                             ## @.str.368
	.asciz	"SW2EXIT"

L_.str.369:                             ## @.str.369
	.asciz	"SW1GRAY"

L_.str.370:                             ## @.str.370
	.asciz	"SW2GRAY"

L_.str.371:                             ## @.str.371
	.asciz	"SW1GRAY1"

L_.str.372:                             ## @.str.372
	.asciz	"SW2GRAY1"

L_.str.373:                             ## @.str.373
	.asciz	"SW1METAL"

L_.str.374:                             ## @.str.374
	.asciz	"SW2METAL"

L_.str.375:                             ## @.str.375
	.asciz	"SW1PIPE"

L_.str.376:                             ## @.str.376
	.asciz	"SW2PIPE"

L_.str.377:                             ## @.str.377
	.asciz	"SW1SLAD"

L_.str.378:                             ## @.str.378
	.asciz	"SW2SLAD"

L_.str.379:                             ## @.str.379
	.asciz	"SW1STARG"

L_.str.380:                             ## @.str.380
	.asciz	"SW2STARG"

L_.str.381:                             ## @.str.381
	.asciz	"SW1STON1"

L_.str.382:                             ## @.str.382
	.asciz	"SW2STON1"

L_.str.383:                             ## @.str.383
	.asciz	"SW1STON2"

L_.str.384:                             ## @.str.384
	.asciz	"SW2STON2"

L_.str.385:                             ## @.str.385
	.asciz	"SW1STONE"

L_.str.386:                             ## @.str.386
	.asciz	"SW2STONE"

L_.str.387:                             ## @.str.387
	.asciz	"SW1STRTN"

L_.str.388:                             ## @.str.388
	.asciz	"SW2STRTN"

L_.str.389:                             ## @.str.389
	.asciz	"SKY1"

L_.str.390:                             ## @.str.390
	.asciz	"SKY2"

L_.str.391:                             ## @.str.391
	.asciz	"SKY3"

L_.str.392:                             ## @.str.392
	.asciz	"SKY4"

L_.str.394:                             ## @.str.394
	.asciz	"WAD lump name too long"

L_.str.395:                             ## @.str.395
	.asciz	"generated WAD fixture overflow"

L_.str.396:                             ## @.str.396
	.asciz	"PUNGA0"

L_.str.397:                             ## @.str.397
	.asciz	"PUNGB0"

L_.str.398:                             ## @.str.398
	.asciz	"PUNGC0"

L_.str.399:                             ## @.str.399
	.asciz	"PUNGD0"

L_.str.400:                             ## @.str.400
	.asciz	"PISGA0"

L_.str.401:                             ## @.str.401
	.asciz	"PISGB0"

L_.str.402:                             ## @.str.402
	.asciz	"PISGC0"

L_.str.403:                             ## @.str.403
	.asciz	"PISFA0"

L_.str.404:                             ## @.str.404
	.asciz	"PLAYA0"

L_.str.405:                             ## @.str.405
	.asciz	"STCFN%03d"

L_.str.406:                             ## @.str.406
	.asciz	"STTNUM%d"

L_.str.407:                             ## @.str.407
	.asciz	"STTMINUS"

L_.str.408:                             ## @.str.408
	.asciz	"STYSNUM%d"

L_.str.409:                             ## @.str.409
	.asciz	"STTPRCNT"

L_.str.410:                             ## @.str.410
	.asciz	"STKEYS%d"

L_.str.411:                             ## @.str.411
	.asciz	"STARMS"

L_.str.412:                             ## @.str.412
	.asciz	"STGNUM%d"

L_.str.413:                             ## @.str.413
	.asciz	"STFB0"

L_.str.414:                             ## @.str.414
	.asciz	"STBAR"

L_.str.415:                             ## @.str.415
	.asciz	"STFST%d%d"

L_.str.416:                             ## @.str.416
	.asciz	"STFTR%d0"

L_.str.417:                             ## @.str.417
	.asciz	"STFTL%d0"

L_.str.418:                             ## @.str.418
	.asciz	"STFOUCH%d"

L_.str.419:                             ## @.str.419
	.asciz	"STFEVL%d"

L_.str.420:                             ## @.str.420
	.asciz	"STFKILL%d"

L_.str.421:                             ## @.str.421
	.asciz	"STFGOD0"

L_.str.422:                             ## @.str.422
	.asciz	"STFDEAD0"

L_.str.423:                             ## @.str.423
	.asciz	"TITLEPIC"

L_.str.424:                             ## @.str.424
	.asciz	"CREDIT"

L_.str.425:                             ## @.str.425
	.asciz	"HELP2"

L_.str.426:                             ## @.str.426
	.asciz	"FAT16 root directory is full"

L_.str.427:                             ## @.str.427
	.asciz	"%s"

L_.str.428:                             ## @.str.428
	.asciz	"manifest file name is too long"

_STATE_DIR_NAME:                        ## @STATE_DIR_NAME
	.asciz	"STATE      "

	.section	__TEXT,__const
	.p2align	4, 0x0                          ## @DEFAULT_PI4_ASSET_README
_DEFAULT_PI4_ASSET_README:
	.asciz	"vibe-os FAT16 one-level asset file\n"

	.p2align	4, 0x0                          ## @DEFAULT_PI4_ASSET_MAP
_DEFAULT_PI4_ASSET_MAP:
	.asciz	"name=E1M1\nmusic=D_E1M1\n"

	.section	__TEXT,__cstring,cstring_literals
L_.str.429:                             ## @.str.429
	.asciz	"--asset path must include a directory component"

L_.str.430:                             ## @.str.430
	.asciz	"external Quake PAK"

	.section	__TEXT,__const
_QUAKE_ID1_DIR_NAME:                    ## @QUAKE_ID1_DIR_NAME
	.asciz	"ID1        "

_QUAKE_PAK0_NAME:                       ## @QUAKE_PAK0_NAME
	.asciz	"PAK0    PAK"

	.section	__TEXT,__cstring,cstring_literals
L_.str.431:                             ## @.str.431
	.asciz	"too small to be a Quake PAK"

L_.str.432:                             ## @.str.432
	.asciz	"PACK"

L_.str.433:                             ## @.str.433
	.asciz	"does not start with PACK"

L_.str.434:                             ## @.str.434
	.asciz	"PAK directory size is invalid"

L_.str.435:                             ## @.str.435
	.asciz	"PAK directory is outside the file"

L_.str.436:                             ## @.str.436
	.asciz	"PAK entry has an empty name"

L_.str.437:                             ## @.str.437
	.asciz	"PAK entry data is outside the file"

	.section	__TEXT,__const
_PI4_KERNEL8_IMG_NAME:                  ## @PI4_KERNEL8_IMG_NAME
	.asciz	"KERNEL8 IMG"

_PI4_CONFIG_TXT_NAME:                   ## @PI4_CONFIG_TXT_NAME
	.asciz	"CONFIG  TXT"

	.section	__TEXT,__cstring,cstring_literals
L_.str.438:                             ## @.str.438
	.asciz	"make_wad_image: Pi proof manifest requires system ELFs under /SYSTEM, not root ELF fallbacks\n"

L_.str.439:                             ## @.str.439
	.asciz	"schema=vibe-os-pi4-image-manifest-v1\n"

L_.str.440:                             ## @.str.440
	.asciz	"layout=vibe-os-pi4-fat16-v1\n"

L_.str.441:                             ## @.str.441
	.asciz	"manifest_path=%s\n"

L_.str.442:                             ## @.str.442
	.asciz	"kernel_file=%s\n"

L_.str.443:                             ## @.str.443
	.asciz	"kernel_size=%zu\n"

L_.str.444:                             ## @.str.444
	.asciz	"kernel_file=absent\n"

L_.str.445:                             ## @.str.445
	.asciz	"config_file=%s\n"

L_.str.446:                             ## @.str.446
	.asciz	"config_size=%zu\n"

L_.str.447:                             ## @.str.447
	.asciz	"config_file=absent\n"

L_.str.448:                             ## @.str.448
	.asciz	"app_model_schema=vibe-os-pi4-app-install-v1\n"

L_.str.449:                             ## @.str.449
	.asciz	"app_layout=%s\n"

L_.str.450:                             ## @.str.450
	.asciz	"app_discovery_model=%s\n"

L_.str.451:                             ## @.str.451
	.asciz	"app_launch_model=generic-vfs-path-exec\n"

L_.str.452:                             ## @.str.452
	.asciz	"app_exec_model=%s\n"

L_.str.453:                             ## @.str.453
	.asciz	"%s=%zu\n"

L_.str.454:                             ## @.str.454
	.asciz	"primary_asset_file=DOOM1.WAD\n"

L_.str.455:                             ## @.str.455
	.asciz	"primary_asset_kind=doom-wad\n"

L_.str.456:                             ## @.str.456
	.asciz	"primary_asset_state=present\n"

L_.str.457:                             ## @.str.457
	.asciz	"primary_asset_source=%s\n"

L_.str.458:                             ## @.str.458
	.asciz	"primary_asset_repo_state=%s\n"

L_.str.459:                             ## @.str.459
	.asciz	"primary_asset_evidence=packaged-file-only\n"

L_.str.460:                             ## @.str.460
	.asciz	"primary_asset_hardware_proof=unclaimed\n"

L_.str.461:                             ## @.str.461
	.asciz	"primary_asset_size=%zu\n"

L_.str.462:                             ## @.str.462
	.asciz	"default_asset_count=%u\n"

L_.str.463:                             ## @.str.463
	.asciz	"default_asset.0.file=%s\n"

L_.str.464:                             ## @.str.464
	.asciz	"default_asset.0.size=%zu\n"

L_.str.465:                             ## @.str.465
	.asciz	"default_asset.1.file=%s\n"

L_.str.466:                             ## @.str.466
	.asciz	"default_asset.1.size=%zu\n"

L_.str.467:                             ## @.str.467
	.asciz	"default_asset.2.file=%s\n"

L_.str.468:                             ## @.str.468
	.asciz	"default_asset.2.size=%u\n"

L_.str.469:                             ## @.str.469
	.asciz	"quake_pak_file=%s\n"

L_.str.470:                             ## @.str.470
	.asciz	"quake_pak_kind=quake-pak\n"

L_.str.471:                             ## @.str.471
	.asciz	"quake_pak_state=%s\n"

L_.str.472:                             ## @.str.472
	.asciz	"quake_pak_source=external\n"

L_.str.473:                             ## @.str.473
	.asciz	"quake_pak_repo_state=outside-repo\n"

L_.str.474:                             ## @.str.474
	.asciz	"quake_pak_evidence=packaged-file-only\n"

L_.str.475:                             ## @.str.475
	.asciz	"quake_pak_hardware_proof=unclaimed\n"

L_.str.476:                             ## @.str.476
	.asciz	"quake_pak_size=%zu\n"

L_.str.477:                             ## @.str.477
	.asciz	"quake_pak_source=absent\n"

L_.str.478:                             ## @.str.478
	.asciz	"quake_pak_repo_state=absent\n"

L_.str.479:                             ## @.str.479
	.asciz	"quake_pak_evidence=absent\n"

L_.str.480:                             ## @.str.480
	.asciz	"root_file_count=%zu\n"

L_.str.481:                             ## @.str.481
	.asciz	"root_file.%zu.file=%s\n"

L_.str.482:                             ## @.str.482
	.asciz	"root_file.%zu.size=%zu\n"

L_.str.483:                             ## @.str.483
	.asciz	"root_elf_count=%zu\n"

L_.str.484:                             ## @.str.484
	.asciz	"root_elf.%zu.file=%s\n"

L_.str.485:                             ## @.str.485
	.asciz	"root_elf.%zu.size=%zu\n"

L_.str.486:                             ## @.str.486
	.asciz	"asset_count=%zu\n"

L_.str.487:                             ## @.str.487
	.asciz	"asset.%zu.file=%s\n"

L_.str.488:                             ## @.str.488
	.asciz	"asset.%zu.kind=%s\n"

L_.str.489:                             ## @.str.489
	.asciz	"asset.%zu.source=external-host-input\n"

L_.str.490:                             ## @.str.490
	.asciz	"asset.%zu.repo_state=%s\n"

L_.str.491:                             ## @.str.491
	.asciz	"asset.%zu.evidence=packaged-file-only\n"

L_.str.492:                             ## @.str.492
	.asciz	"asset.%zu.hardware_proof=unclaimed\n"

L_.str.493:                             ## @.str.493
	.asciz	"asset.%zu.size=%zu\n"

L_.str.494:                             ## @.str.494
	.asciz	"root file"

L_.str.495:                             ## @.str.495
	.asciz	"make_wad_image: Pi proof manifest requires %s %s\n"

L_.str.496:                             ## @.str.496
	.asciz	"make_wad_image: Pi proof manifest %s %s is missing or empty\n"

L_.str.497:                             ## @.str.497
	.asciz	"make_wad_image: Pi proof manifest requires installed app file %s\n"

L_.str.498:                             ## @.str.498
	.asciz	"manifest formatting failed"

L_.str.499:                             ## @.str.499
	.asciz	"%s_size=%zu\n"

L_.str.500:                             ## @.str.500
	.asciz	"%s.%zu.id=%s\n"

L_.str.501:                             ## @.str.501
	.asciz	"%s.%zu.name=%s\n"

L_.str.502:                             ## @.str.502
	.asciz	"%s.%zu.manifest=%s\n"

L_.str.503:                             ## @.str.503
	.asciz	"%s.%zu.manifest_size=%zu\n"

L_.str.504:                             ## @.str.504
	.asciz	"%s.%zu.exec=%s\n"

L_.str.505:                             ## @.str.505
	.asciz	"%s.%zu.exec_size=%zu\n"

L_.str.506:                             ## @.str.506
	.asciz	"%s.%zu.launch=%s\n"

L_.str.507:                             ## @.str.507
	.asciz	"%s.%zu.exec_model=%s\n"

L_.str.508:                             ## @.str.508
	.asciz	"%s.%zu.resource=%s\n"

L_.str.509:                             ## @.str.509
	.asciz	"%s.%zu.asset=%s\n"

L_.str.510:                             ## @.str.510
	.asciz	"%s.%zu.icon=%s\n"

L_.str.511:                             ## @.str.511
	.asciz	"%s.%zu.hardware_proof=unclaimed\n"

L_.str.512:                             ## @.str.512
	.asciz	"wb"

L_.str.513:                             ## @.str.513
	.asciz	"write failed"

L_str:                                  ## @str
	.asciz	"schema=vibe-os-c-persistence-proof-v1"

L_str.514:                              ## @str.514
	.asciz	"result=ok"

L_str.515:                              ## @str.515
	.asciz	"schema=vibe-os-c-image-inspect-v1"

L_str.516:                              ## @str.516
	.asciz	"real_asset_manifest=OK primary_asset_source=external primary_asset_repo_state=outside-repo quake_pak_source=external quake_pak_repo_state=outside-repo checked_files_include_pak=true"

.subsections_via_symbols
