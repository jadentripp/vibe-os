	.file	"link_aarch64_user_elf.linux.c"
	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$456, %rsp                      # imm = 0x1C8
	movq	%rsi, %rbx
	movl	%edi, %ebp
	movslq	%edi, %rdi
	movl	$8, %esi
	callq	calloc@PLT
	movq	%rax, 168(%rsp)                 # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_511
# %bb.1:
	cmpl	$2, %ebp
	jl	.LBB0_380
# %bb.2:
	movl	$15204352, %r12d                # imm = 0xE80000
	movl	$1, %r15d
	movq	$0, 120(%rsp)                   # 8-byte Folded Spill
	leaq	.L.str.2(%rip), %r14
	movq	$0, 128(%rsp)                   # 8-byte Folded Spill
	jmp	.LBB0_6
	.p2align	4
.LBB0_3:                                #   in Loop: Header=BB0_6 Depth=1
	movq	%r13, %rdi
	movq	%r14, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_10
# %bb.4:                                #   in Loop: Header=BB0_6 Depth=1
	movq	168(%rsp), %rax                 # 8-byte Reload
	movq	128(%rsp), %rcx                 # 8-byte Reload
	movq	%r13, (%rax,%rcx,8)
	incq	%rcx
	movq	%rcx, 128(%rsp)                 # 8-byte Spill
.LBB0_5:                                #   in Loop: Header=BB0_6 Depth=1
	incl	%r15d
	cmpl	%ebp, %r15d
	jge	.LBB0_16
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movslq	%r15d, %rax
	movq	(%rbx,%rax,8), %r13
	cmpb	$45, (%r13)
	jne	.LBB0_3
# %bb.7:                                #   in Loop: Header=BB0_6 Depth=1
	cmpb	$111, 1(%r13)
	jne	.LBB0_9
# %bb.8:                                #   in Loop: Header=BB0_6 Depth=1
	cmpb	$0, 2(%r13)
	je	.LBB0_14
.LBB0_9:                                #   in Loop: Header=BB0_6 Depth=1
	movq	%r13, %rdi
	movq	%r14, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_382
.LBB0_10:                               #   in Loop: Header=BB0_6 Depth=1
	incl	%r15d
	cmpl	%ebp, %r15d
	jge	.LBB0_484
# %bb.11:                               #   in Loop: Header=BB0_6 Depth=1
	movslq	%r15d, %rax
	movq	(%rbx,%rax,8), %r13
	movq	$0, 296(%rsp)
	callq	__errno_location@PLT
	movl	$0, (%rax)
	movq	%r13, %rdi
	leaq	296(%rsp), %rsi
	xorl	%edx, %edx
	callq	strtoull@PLT
	movq	%rax, %r12
	callq	__errno_location@PLT
	cmpl	$0, (%rax)
	jne	.LBB0_461
# %bb.12:                               #   in Loop: Header=BB0_6 Depth=1
	movq	296(%rsp), %rax
	testq	%rax, %rax
	je	.LBB0_461
# %bb.13:                               #   in Loop: Header=BB0_6 Depth=1
	cmpb	$0, (%rax)
	je	.LBB0_5
	jmp	.LBB0_461
.LBB0_14:                               #   in Loop: Header=BB0_6 Depth=1
	incl	%r15d
	cmpl	%ebp, %r15d
	jge	.LBB0_508
# %bb.15:                               #   in Loop: Header=BB0_6 Depth=1
	movslq	%r15d, %rax
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 120(%rsp)                 # 8-byte Spill
	jmp	.LBB0_5
.LBB0_16:
	cmpq	$0, 120(%rsp)                   # 8-byte Folded Reload
	movq	128(%rsp), %rdi                 # 8-byte Reload
	je	.LBB0_380
# %bb.17:
	testq	%rdi, %rdi
	je	.LBB0_380
# %bb.18:
	xorps	%xmm0, %xmm0
	movups	%xmm0, 408(%rsp)
	movups	%xmm0, 424(%rsp)
	movups	%xmm0, 392(%rsp)
	movups	%xmm0, 376(%rsp)
	movups	%xmm0, 360(%rsp)
	movups	%xmm0, 344(%rsp)
	movups	%xmm0, 328(%rsp)
	movups	%xmm0, 312(%rsp)
	movq	$0, 440(%rsp)
	movq	%r12, 408(%rsp)
	movq	%rdi, 304(%rsp)
	movl	$56, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_512
# %bb.19:
	movq	%rax, %r15
	movq	%rax, 296(%rsp)
	xorl	%r13d, %r13d
	movq	%rax, 136(%rsp)                 # 8-byte Spill
	jmp	.LBB0_21
	.p2align	4
.LBB0_20:                               #   in Loop: Header=BB0_21 Depth=1
	movq	144(%rsp), %r13                 # 8-byte Reload
	incq	%r13
	cmpq	128(%rsp), %r13                 # 8-byte Folded Reload
	movq	136(%rsp), %r15                 # 8-byte Reload
	je	.LBB0_121
.LBB0_21:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_48 Depth 2
                                        #     Child Loop BB0_93 Depth 2
                                        #     Child Loop BB0_106 Depth 2
	imulq	$56, %r13, %rbp
	movq	168(%rsp), %rax                 # 8-byte Reload
	movq	(%rax,%r13,8), %r14
	movq	%r14, (%r15,%rbp)
	movq	%r14, %rdi
	leaq	.L.str.9(%rip), %rsi
	callq	fopen@PLT
	testq	%rax, %rax
	je	.LBB0_462
# %bb.22:                               #   in Loop: Header=BB0_21 Depth=1
	movq	%rax, %rbx
	movq	%r14, 8(%rsp)                   # 8-byte Spill
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$2, %edx
	callq	fseek@PLT
	testl	%eax, %eax
	jne	.LBB0_454
# %bb.23:                               #   in Loop: Header=BB0_21 Depth=1
	movq	%rbx, %rdi
	callq	ftell@PLT
	testq	%rax, %rax
	js	.LBB0_463
# %bb.24:                               #   in Loop: Header=BB0_21 Depth=1
	movq	%rax, %r14
	movq	%rbx, %rdi
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	fseek@PLT
	testl	%eax, %eax
	jne	.LBB0_454
# %bb.25:                               #   in Loop: Header=BB0_21 Depth=1
	cmpq	$1, %r14
	movq	%r14, %rdi
	adcq	$0, %rdi
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_464
# %bb.26:                               #   in Loop: Header=BB0_21 Depth=1
	testq	%r14, %r14
	movq	%rax, %r12
	je	.LBB0_28
# %bb.27:                               #   in Loop: Header=BB0_21 Depth=1
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%r14, %rdx
	movq	%rbx, %rcx
	callq	fread@PLT
	cmpq	%r14, %rax
	jne	.LBB0_485
.LBB0_28:                               #   in Loop: Header=BB0_21 Depth=1
	addq	%r15, %rbp
	movq	%rbx, %rdi
	callq	fclose@PLT
	movq	%r14, 16(%rbp)
	movq	%r12, 8(%rbp)
	cmpq	$64, %r14
	jb	.LBB0_453
# %bb.29:                               #   in Loop: Header=BB0_21 Depth=1
	movq	%r12, %rdi
	cmpl	$1179403647, (%r12)             # imm = 0x464C457F
	jne	.LBB0_453
# %bb.30:                               #   in Loop: Header=BB0_21 Depth=1
	cmpb	$2, 4(%rdi)
	jne	.LBB0_456
# %bb.31:                               #   in Loop: Header=BB0_21 Depth=1
	cmpb	$1, 5(%rdi)
	jne	.LBB0_456
# %bb.32:                               #   in Loop: Header=BB0_21 Depth=1
	cmpw	$1, 16(%rdi)
	jne	.LBB0_455
# %bb.33:                               #   in Loop: Header=BB0_21 Depth=1
	cmpw	$183, 18(%rdi)
	jne	.LBB0_455
# %bb.34:                               #   in Loop: Header=BB0_21 Depth=1
	movzwl	58(%rdi), %r8d
	cmpq	$63, %r8
	jbe	.LBB0_465
# %bb.35:                               #   in Loop: Header=BB0_21 Depth=1
	movzwl	60(%rdi), %ecx
	movzwl	62(%rdi), %eax
	movq	%rcx, 64(%rsp)                  # 8-byte Spill
	cmpw	%cx, %ax
	jae	.LBB0_469
# %bb.36:                               #   in Loop: Header=BB0_21 Depth=1
	movl	40(%rdi), %r12d
	movl	44(%rdi), %ebx
	shlq	$32, %rbx
	leaq	(%rbx,%r12), %rcx
	movq	%r14, %rdx
	subq	%rcx, %rdx
	jb	.LBB0_466
# %bb.37:                               #   in Loop: Header=BB0_21 Depth=1
	movq	64(%rsp), %rsi                  # 8-byte Reload
	imulq	%r8, %rsi
	cmpq	%rdx, %rsi
	ja	.LBB0_466
# %bb.38:                               #   in Loop: Header=BB0_21 Depth=1
	imulq	%r8, %rax
	leaq	(%rax,%rcx), %rsi
	addq	$24, %rsi
	movq	%r14, %rdx
	subq	%rsi, %rdx
	jb	.LBB0_467
# %bb.39:                               #   in Loop: Header=BB0_21 Depth=1
	cmpq	$3, %rdx
	jbe	.LBB0_467
# %bb.40:                               #   in Loop: Header=BB0_21 Depth=1
	addq	%rcx, %rax
	movq	%r14, %rcx
	subq	%rax, %rcx
	addq	$-28, %rcx
	cmpq	$3, %rcx
	jbe	.LBB0_468
# %bb.41:                               #   in Loop: Header=BB0_21 Depth=1
	leaq	32(%rax), %rcx
	movq	%r14, %rdx
	subq	%rcx, %rdx
	cmpq	$3, %rdx
	jbe	.LBB0_470
# %bb.42:                               #   in Loop: Header=BB0_21 Depth=1
	leaq	36(%rax), %rdx
	movq	%r14, %rsi
	subq	%rdx, %rsi
	cmpq	$3, %rsi
	jbe	.LBB0_471
# %bb.43:                               #   in Loop: Header=BB0_21 Depth=1
	movq	%r8, 104(%rsp)                  # 8-byte Spill
	movq	24(%rdi,%rax), %rsi
	movq	%r14, %rax
	movq	%rsi, 56(%rsp)                  # 8-byte Spill
	subq	%rsi, %rax
	jb	.LBB0_472
# %bb.44:                               #   in Loop: Header=BB0_21 Depth=1
	movl	(%rdi,%rcx), %ecx
	movl	(%rdi,%rdx), %edx
	shlq	$32, %rdx
	orq	%rcx, %rdx
	movq	%rdx, 24(%rsp)                  # 8-byte Spill
	cmpq	%rax, %rdx
	ja	.LBB0_472
# %bb.45:                               #   in Loop: Header=BB0_21 Depth=1
	movq	%rdi, (%rsp)                    # 8-byte Spill
	movq	%r13, 144(%rsp)                 # 8-byte Spill
	movq	64(%rsp), %r15                  # 8-byte Reload
	movq	%r15, 32(%rbp)
	movl	$88, %esi
	movq	%r15, %rdi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_473
# %bb.46:                               #   in Loop: Header=BB0_21 Depth=1
	movq	(%rsp), %rcx                    # 8-byte Reload
	addq	%rcx, 56(%rsp)                  # 8-byte Folded Spill
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	movq	%rbp, 88(%rsp)                  # 8-byte Spill
	movq	%rax, 24(%rbp)
	imulq	$88, %r15, %rdx
	movq	%rdx, 32(%rsp)                  # 8-byte Spill
	movq	%rax, %r15
	leaq	(%r12,%rbx), %r13
	addq	$60, %r13
	addq	%rbx, %r12
	negq	%r12
	xorl	%ebp, %ebp
	movq	%rax, 72(%rsp)                  # 8-byte Spill
	jmp	.LBB0_48
	.p2align	4
.LBB0_47:                               #   in Loop: Header=BB0_48 Depth=2
	addq	$88, %rbp
	movq	104(%rsp), %rax                 # 8-byte Reload
	addq	%rax, %r13
	subq	%rax, %r12
	cmpq	%rbp, 32(%rsp)                  # 8-byte Folded Reload
	je	.LBB0_92
.LBB0_48:                               #   Parent Loop BB0_21 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	leaq	-60(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_400
# %bb.49:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	cmpq	$3, %rax
	jbe	.LBB0_400
# %bb.50:                               #   in Loop: Header=BB0_48 Depth=2
	movl	-60(%rcx,%r13), %ebx
	movq	24(%rsp), %rdx                  # 8-byte Reload
	subq	%rbx, %rdx
	jbe	.LBB0_394
# %bb.51:                               #   in Loop: Header=BB0_48 Depth=2
	addq	56(%rsp), %rbx                  # 8-byte Folded Reload
	movq	%rbx, %rdi
	xorl	%esi, %esi
	callq	memchr@PLT
	testq	%rax, %rax
	je	.LBB0_401
# %bb.52:                               #   in Loop: Header=BB0_48 Depth=2
	movq	%rbx, (%r15,%rbp)
	leaq	-56(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_402
# %bb.53:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-4, %rax
	cmpq	$3, %rax
	jbe	.LBB0_402
# %bb.54:                               #   in Loop: Header=BB0_48 Depth=2
	movq	(%rsp), %rcx                    # 8-byte Reload
	movl	-56(%rcx,%r13), %edx
	movl	%edx, 8(%r15,%rbp)
	leaq	-52(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_403
# %bb.55:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-8, %rax
	cmpq	$3, %rax
	jbe	.LBB0_403
# %bb.56:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	-48(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_397
# %bb.57:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-12, %rax
	cmpq	$3, %rax
	jbe	.LBB0_397
# %bb.58:                               #   in Loop: Header=BB0_48 Depth=2
	movl	-52(%rcx,%r13), %esi
	movl	-48(%rcx,%r13), %eax
	shlq	$32, %rax
	orq	%rsi, %rax
	movq	%rax, 16(%r15,%rbp)
	leaq	-36(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_404
# %bb.59:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-24, %rax
	cmpq	$3, %rax
	jbe	.LBB0_404
# %bb.60:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	-32(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_405
# %bb.61:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-28, %rax
	cmpq	$3, %rax
	jbe	.LBB0_405
# %bb.62:                               #   in Loop: Header=BB0_48 Depth=2
	movq	-36(%rcx,%r13), %rdi
	movq	%rdi, 24(%r15,%rbp)
	leaq	-28(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_398
# %bb.63:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-32, %rax
	cmpq	$3, %rax
	jbe	.LBB0_398
# %bb.64:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	-24(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_406
# %bb.65:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-36, %rax
	cmpq	$3, %rax
	jbe	.LBB0_406
# %bb.66:                               #   in Loop: Header=BB0_48 Depth=2
	movq	-28(%rcx,%r13), %r8
	movq	%r8, 32(%r15,%rbp)
	leaq	-20(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_408
# %bb.67:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-40, %rax
	cmpq	$3, %rax
	jbe	.LBB0_408
# %bb.68:                               #   in Loop: Header=BB0_48 Depth=2
	movl	-20(%rcx,%r13), %eax
	movl	%eax, 40(%r15,%rbp)
	leaq	-16(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_409
# %bb.69:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-44, %rax
	cmpq	$3, %rax
	jbe	.LBB0_409
# %bb.70:                               #   in Loop: Header=BB0_48 Depth=2
	movl	-16(%rcx,%r13), %eax
	movl	%eax, 44(%r15,%rbp)
	leaq	-12(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_407
# %bb.71:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-48, %rax
	cmpq	$3, %rax
	jbe	.LBB0_407
# %bb.72:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	-8(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_399
# %bb.73:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-52, %rax
	cmpq	$3, %rax
	jbe	.LBB0_399
# %bb.74:                               #   in Loop: Header=BB0_48 Depth=2
	movq	-12(%rcx,%r13), %rax
	movq	%rax, 48(%r15,%rbp)
	leaq	-4(%r13), %rax
	cmpq	%r14, %rax
	ja	.LBB0_395
# %bb.75:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-56, %rax
	cmpq	$3, %rax
	jbe	.LBB0_395
# %bb.76:                               #   in Loop: Header=BB0_48 Depth=2
	cmpq	%r14, %r13
	ja	.LBB0_396
# %bb.77:                               #   in Loop: Header=BB0_48 Depth=2
	leaq	(%r14,%r12), %rax
	addq	$-60, %rax
	cmpq	$3, %rax
	jbe	.LBB0_396
# %bb.78:                               #   in Loop: Header=BB0_48 Depth=2
	movq	-4(%rcx,%r13), %rax
	movq	%rax, 56(%r15,%rbp)
	movl	$-1, %r15d
	testb	$2, %sil
	je	.LBB0_89
# %bb.79:                               #   in Loop: Header=BB0_48 Depth=2
	cmpl	$1, %edx
	je	.LBB0_81
# %bb.80:                               #   in Loop: Header=BB0_48 Depth=2
	cmpl	$8, %edx
	jne	.LBB0_426
.LBB0_81:                               #   in Loop: Header=BB0_48 Depth=2
	movq	%r8, 96(%rsp)                   # 8-byte Spill
	movq	%rdi, 40(%rsp)                  # 8-byte Spill
	movq	%rsi, 112(%rsp)                 # 8-byte Spill
	movl	%edx, 48(%rsp)                  # 4-byte Spill
	movl	$5, %edx
	movq	%rbx, %rdi
	leaq	.L.str.27(%rip), %rsi
	callq	strncmp@PLT
	xorl	%r15d, %r15d
	testl	%eax, %eax
	je	.LBB0_88
# %bb.82:                               #   in Loop: Header=BB0_48 Depth=2
	movl	$7, %edx
	movq	%rbx, %rdi
	leaq	.L.str.28(%rip), %rsi
	callq	strncmp@PLT
	testl	%eax, %eax
	je	.LBB0_87
# %bb.83:                               #   in Loop: Header=BB0_48 Depth=2
	movl	$5, %edx
	movq	%rbx, %rdi
	leaq	.L.str.29(%rip), %rsi
	callq	strncmp@PLT
	movl	$2, %r15d
	testl	%eax, %eax
	je	.LBB0_88
# %bb.84:                               #   in Loop: Header=BB0_48 Depth=2
	movl	$4, %edx
	movq	%rbx, %rdi
	leaq	.L.str.30(%rip), %rsi
	callq	strncmp@PLT
	testl	%eax, %eax
	movq	(%rsp), %rcx                    # 8-byte Reload
	movl	48(%rsp), %edx                  # 4-byte Reload
	movq	112(%rsp), %rax                 # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	96(%rsp), %r8                   # 8-byte Reload
	je	.LBB0_89
# %bb.85:                               #   in Loop: Header=BB0_48 Depth=2
	movl	$0, %r15d
	testb	$4, %al
	jne	.LBB0_89
# %bb.86:                               #   in Loop: Header=BB0_48 Depth=2
	andl	$1, %eax
	incl	%eax
	movl	%eax, %r15d
	jmp	.LBB0_89
.LBB0_87:                               #   in Loop: Header=BB0_48 Depth=2
	movl	$1, %r15d
.LBB0_88:                               #   in Loop: Header=BB0_48 Depth=2
	movq	(%rsp), %rcx                    # 8-byte Reload
	movl	48(%rsp), %edx                  # 4-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	96(%rsp), %r8                   # 8-byte Reload
.LBB0_89:                               #   in Loop: Header=BB0_48 Depth=2
	movq	72(%rsp), %rax                  # 8-byte Reload
	movl	%r15d, 80(%rax,%rbp)
	movq	%rax, %r15
	cmpl	$8, %edx
	je	.LBB0_47
# %bb.90:                               #   in Loop: Header=BB0_48 Depth=2
	movq	%r14, %rax
	subq	%rdi, %rax
	jb	.LBB0_414
# %bb.91:                               #   in Loop: Header=BB0_48 Depth=2
	cmpq	%rax, %r8
	jbe	.LBB0_47
	jmp	.LBB0_414
	.p2align	4
.LBB0_92:                               #   in Loop: Header=BB0_21 Depth=1
	xorl	%ebx, %ebx
	movq	88(%rsp), %r13                  # 8-byte Reload
	movq	64(%rsp), %rax                  # 8-byte Reload
	.p2align	4
.LBB0_93:                               #   Parent Loop BB0_21 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$2, 8(%r15,%rbx)
	je	.LBB0_95
# %bb.94:                               #   in Loop: Header=BB0_93 Depth=2
	addq	$88, %rbx
	cmpq	%rbx, 32(%rsp)                  # 8-byte Folded Reload
	jne	.LBB0_93
	jmp	.LBB0_410
	.p2align	4
.LBB0_95:                               #   in Loop: Header=BB0_21 Depth=1
	movl	40(%r15,%rbx), %ecx
	cmpl	%ecx, %eax
	jbe	.LBB0_478
# %bb.96:                               #   in Loop: Header=BB0_21 Depth=1
	movq	56(%r15,%rbx), %rbp
	cmpq	$23, %rbp
	jbe	.LBB0_475
# %bb.97:                               #   in Loop: Header=BB0_21 Depth=1
	movq	32(%r15,%rbx), %r15
	movq	%r15, %rax
	orq	%rbp, %rax
	shrq	$32, %rax
	je	.LBB0_99
# %bb.98:                               #   in Loop: Header=BB0_21 Depth=1
	movq	%r15, %rax
	xorl	%edx, %edx
	divq	%rbp
	jmp	.LBB0_100
	.p2align	4
.LBB0_99:                               #   in Loop: Header=BB0_21 Depth=1
	movl	%r15d, %eax
	xorl	%edx, %edx
	divl	%ebp
                                        # kill: def $edx killed $edx def $rdx
                                        # kill: def $eax killed $eax def $rax
.LBB0_100:                              #   in Loop: Header=BB0_21 Depth=1
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	testq	%rdx, %rdx
	jne	.LBB0_477
# %bb.101:                              #   in Loop: Header=BB0_21 Depth=1
	imulq	$88, %rcx, %rax
	movq	16(%rsp), %rcx                  # 8-byte Reload
	addq	%rax, %rcx
	movq	24(%rcx), %rdx
	movq	%r14, %rax
	movq	%rdx, 24(%rsp)                  # 8-byte Spill
	subq	%rdx, %rax
	jb	.LBB0_474
# %bb.102:                              #   in Loop: Header=BB0_21 Depth=1
	movq	32(%rcx), %rcx
	movq	%rcx, 56(%rsp)                  # 8-byte Spill
	cmpq	%rax, %rcx
	ja	.LBB0_474
# %bb.103:                              #   in Loop: Header=BB0_21 Depth=1
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rdi, 48(%r13)
	cmpq	%r15, %rbp
	movl	$1, %eax
	cmovaq	%rax, %rdi
	movl	$56, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_476
# %bb.104:                              #   in Loop: Header=BB0_21 Depth=1
	movq	%rax, %r12
	movq	%rax, 40(%r13)
	cmpq	%r15, %rbp
	movq	(%rsp), %rdx                    # 8-byte Reload
	ja	.LBB0_20
# %bb.105:                              #   in Loop: Header=BB0_21 Depth=1
	movq	%rbp, %rcx
	movq	%rdx, %rax
	addq	24(%rsp), %rax                  # 8-byte Folded Reload
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	movq	72(%rsp), %rax                  # 8-byte Reload
	movq	24(%rax,%rbx), %r15
	addq	$32, %r12
	movq	%r14, %rbx
	subq	%r15, %rbx
	addq	$20, %r15
	addq	$-20, %rbx
	xorl	%ebp, %ebp
	movq	%rcx, 104(%rsp)                 # 8-byte Spill
	.p2align	4
.LBB0_106:                              #   Parent Loop BB0_21 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	leaq	-20(%r15), %rax
	cmpq	%r14, %rax
	ja	.LBB0_420
# %bb.107:                              #   in Loop: Header=BB0_106 Depth=2
	leaq	20(%rbx), %rax
	cmpq	$3, %rax
	jbe	.LBB0_420
# %bb.108:                              #   in Loop: Header=BB0_106 Depth=2
	movl	-20(%rdx,%r15), %r13d
	movq	56(%rsp), %rdx                  # 8-byte Reload
	subq	%r13, %rdx
	jbe	.LBB0_418
# %bb.109:                              #   in Loop: Header=BB0_106 Depth=2
	addq	24(%rsp), %r13                  # 8-byte Folded Reload
	movq	%r13, %rdi
	xorl	%esi, %esi
	callq	memchr@PLT
	testq	%rax, %rax
	je	.LBB0_419
# %bb.110:                              #   in Loop: Header=BB0_106 Depth=2
	movq	%r13, -32(%r12)
	movq	(%rsp), %rdx                    # 8-byte Reload
	movzbl	-16(%rdx,%r15), %eax
	movb	%al, (%r12)
	leaq	-14(%r15), %rax
	cmpq	%r14, %rax
	ja	.LBB0_415
# %bb.111:                              #   in Loop: Header=BB0_106 Depth=2
	leaq	14(%rbx), %rax
	cmpq	$1, %rax
	jbe	.LBB0_415
# %bb.112:                              #   in Loop: Header=BB0_106 Depth=2
	movzwl	-14(%rdx,%r15), %eax
	movw	%ax, -24(%r12)
	leaq	-12(%r15), %rax
	cmpq	%r14, %rax
	ja	.LBB0_422
# %bb.113:                              #   in Loop: Header=BB0_106 Depth=2
	leaq	12(%rbx), %rax
	cmpq	$3, %rax
	jbe	.LBB0_422
# %bb.114:                              #   in Loop: Header=BB0_106 Depth=2
	leaq	-8(%r15), %rax
	cmpq	%r14, %rax
	ja	.LBB0_417
# %bb.115:                              #   in Loop: Header=BB0_106 Depth=2
	leaq	8(%rbx), %rax
	cmpq	$3, %rax
	jbe	.LBB0_417
# %bb.116:                              #   in Loop: Header=BB0_106 Depth=2
	movq	-12(%rdx,%r15), %rax
	movq	%rax, -16(%r12)
	leaq	-4(%r15), %rcx
	movq	%rbx, %rax
	addq	$4, %rax
	setb	%al
	cmpq	%r14, %rcx
	ja	.LBB0_416
# %bb.117:                              #   in Loop: Header=BB0_106 Depth=2
	testb	%al, %al
	jne	.LBB0_416
# %bb.118:                              #   in Loop: Header=BB0_106 Depth=2
	cmpq	%r14, %r15
	ja	.LBB0_421
# %bb.119:                              #   in Loop: Header=BB0_106 Depth=2
	cmpq	$3, %rbx
	jbe	.LBB0_421
# %bb.120:                              #   in Loop: Header=BB0_106 Depth=2
	movq	-4(%rdx,%r15), %rax
	movq	%rax, -8(%r12)
	incq	%rbp
	addq	$56, %r12
	movq	104(%rsp), %rcx                 # 8-byte Reload
	addq	%rcx, %r15
	subq	%rcx, %rbx
	cmpq	32(%rsp), %rbp                  # 8-byte Folded Reload
	jb	.LBB0_106
	jmp	.LBB0_20
.LBB0_121:
	movq	$0, 176(%rsp)
	movl	$0, 84(%rsp)
	leaq	.L.str.37(%rip), %r8
	leaq	296(%rsp), %r14
	leaq	176(%rsp), %r15
	leaq	84(%rsp), %rbx
	movq	%r14, %rdi
	movq	%r15, %rsi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movq	%rbx, %r9
	callq	place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	movl	$1, %edx
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	movl	$2, %edx
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	place_matching
	movq	%r14, %rdi
	movq	%r15, %rsi
	movl	$2, %edx
	movl	$1, %ecx
	xorl	%r8d, %r8d
	movq	%rbx, %r9
	callq	place_matching
	movq	304(%rsp), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_171
# %bb.122:
	movq	176(%rsp), %rbp
	movl	84(%rsp), %eax
	movl	%eax, 112(%rsp)                 # 4-byte Spill
	movq	296(%rsp), %r14
	movl	376(%rsp), %eax
	movl	%eax, 64(%rsp)                  # 4-byte Spill
	movq	400(%rsp), %rax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	movq	408(%rsp), %rax
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	xorl	%r12d, %r12d
	movq	%r14, 32(%rsp)                  # 8-byte Spill
	jmp	.LBB0_124
	.p2align	4
.LBB0_123:                              #   in Loop: Header=BB0_124 Depth=1
	incq	%r12
	cmpq	40(%rsp), %r12                  # 8-byte Folded Reload
	je	.LBB0_170
.LBB0_124:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_128 Depth 2
                                        #       Child Loop BB0_145 Depth 3
                                        #         Child Loop BB0_147 Depth 4
	imulq	$56, %r12, %rcx
	cmpq	$0, 48(%r14,%rcx)
	je	.LBB0_123
# %bb.125:                              #   in Loop: Header=BB0_124 Depth=1
	addq	%r14, %rcx
	xorl	%r15d, %r15d
	movq	%r12, 88(%rsp)                  # 8-byte Spill
	movq	%rcx, 72(%rsp)                  # 8-byte Spill
	jmp	.LBB0_128
.LBB0_161:                              #   in Loop: Header=BB0_128 Depth=2
	movq	16(%rax), %rdx
.LBB0_169:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	296(%rsp), %rdi
	movq	%rbx, %rsi
	leaq	240(%rsp), %rcx
	leaq	152(%rsp), %r8
	callq	mark_matching_common_symbols
.LBB0_126:                              #   in Loop: Header=BB0_128 Depth=2
	movq	72(%rsp), %rcx                  # 8-byte Reload
	.p2align	4
.LBB0_127:                              #   in Loop: Header=BB0_128 Depth=2
	incq	%r15
	cmpq	48(%rcx), %r15
	jae	.LBB0_123
.LBB0_128:                              #   Parent Loop BB0_124 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_145 Depth 3
                                        #         Child Loop BB0_147 Depth 4
	movq	40(%rcx), %rbx
	imulq	$56, %r15, %rax
	cmpw	$-14, 8(%rbx,%rax)
	jne	.LBB0_127
# %bb.129:                              #   in Loop: Header=BB0_128 Depth=2
	addq	%rax, %rbx
	cmpl	$0, 48(%rbx)
	jne	.LBB0_127
# %bb.130:                              #   in Loop: Header=BB0_128 Depth=2
	movq	(%rbx), %rax
	movq	%rax, (%rsp)                    # 8-byte Spill
	cmpb	$0, (%rax)
	je	.LBB0_132
# %bb.131:                              #   in Loop: Header=BB0_128 Depth=2
	cmpb	$16, 32(%rbx)
	jae	.LBB0_143
.LBB0_132:                              #   in Loop: Header=BB0_128 Depth=2
	movq	$0, 240(%rsp)
	movq	$0, 152(%rsp)
	leaq	296(%rsp), %rdi
	movq	%rbx, %rsi
	xorl	%edx, %edx
	leaq	240(%rsp), %rcx
	leaq	152(%rsp), %r8
	callq	mark_matching_common_symbols
	movq	152(%rsp), %rax
	cmpq	$2, %rax
	jae	.LBB0_134
# %bb.133:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rbx, %rsi
	movq	%rbp, %rbx
	jmp	.LBB0_137
.LBB0_134:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	-1(%rax), %rcx
	testq	%rcx, %rax
	jne	.LBB0_479
# %bb.135:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rax, %rcx
	negq	%rcx
	cmpq	%rcx, %rbp
	ja	.LBB0_480
# %bb.136:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rbx, %rsi
	leaq	(%rax,%rbp), %rbx
	decq	%rbx
	andq	%rcx, %rbx
.LBB0_137:                              #   in Loop: Header=BB0_128 Depth=2
	movq	240(%rsp), %rbp
	addq	%rbx, %rbp
	jb	.LBB0_457
# %bb.138:                              #   in Loop: Header=BB0_128 Depth=2
	movq	56(%rsp), %rax                  # 8-byte Reload
	leaq	(%rax,%rbx), %r13
	leaq	296(%rsp), %rdi
	movq	%r13, %rdx
	leaq	240(%rsp), %rcx
	leaq	152(%rsp), %r8
	callq	mark_matching_common_symbols
	cmpq	%rbx, %rbp
	jbe	.LBB0_126
# %bb.139:                              #   in Loop: Header=BB0_128 Depth=2
	cmpl	$0, 112(%rsp)                   # 4-byte Folded Reload
	movq	72(%rsp), %rcx                  # 8-byte Reload
	jne	.LBB0_141
# %bb.140:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%r13, 432(%rsp)
	movl	$1, 112(%rsp)                   # 4-byte Folded Spill
.LBB0_141:                              #   in Loop: Header=BB0_128 Depth=2
	movq	56(%rsp), %rax                  # 8-byte Reload
	addq	%rbp, %rax
	movq	%rax, 440(%rsp)
	cmpl	$0, 64(%rsp)                    # 4-byte Folded Reload
	je	.LBB0_162
# %bb.142:                              #   in Loop: Header=BB0_128 Depth=2
	cmpq	24(%rsp), %rbp                  # 8-byte Folded Reload
	jbe	.LBB0_127
	jmp	.LBB0_163
.LBB0_143:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rbx, 96(%rsp)                  # 8-byte Spill
	movq	%r15, 48(%rsp)                  # 8-byte Spill
	movq	%rbp, 104(%rsp)                 # 8-byte Spill
	xorl	%eax, %eax
	xorl	%ecx, %ecx
	xorl	%r15d, %r15d
	jmp	.LBB0_145
	.p2align	4
.LBB0_144:                              #   in Loop: Header=BB0_145 Depth=3
	incq	%r15
	cmpq	40(%rsp), %r15                  # 8-byte Folded Reload
	movq	32(%rsp), %r14                  # 8-byte Reload
	je	.LBB0_157
.LBB0_145:                              #   Parent Loop BB0_124 Depth=1
                                        #     Parent Loop BB0_128 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_147 Depth 4
	imulq	$56, %r15, %rbx
	movq	48(%r14,%rbx), %rbp
	testq	%rbp, %rbp
	je	.LBB0_144
# %bb.146:                              #   in Loop: Header=BB0_145 Depth=3
	addq	%r14, %rbx
	movq	40(%rbx), %r12
	movq	%rax, %r14
	movq	%rcx, %r13
	.p2align	4
.LBB0_147:                              #   Parent Loop BB0_124 Depth=1
                                        #     Parent Loop BB0_128 Depth=2
                                        #       Parent Loop BB0_145 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movzwl	8(%r12), %eax
	testl	%eax, %eax
	je	.LBB0_152
# %bb.148:                              #   in Loop: Header=BB0_147 Depth=4
	cmpl	$65522, %eax                    # imm = 0xFFF2
	je	.LBB0_152
# %bb.149:                              #   in Loop: Header=BB0_147 Depth=4
	movq	(%r12), %rdi
	cmpb	$0, (%rdi)
	je	.LBB0_152
# %bb.150:                              #   in Loop: Header=BB0_147 Depth=4
	movq	(%rsp), %rsi                    # 8-byte Reload
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_152
# %bb.151:                              #   in Loop: Header=BB0_147 Depth=4
	movzbl	32(%r12), %edx
	cmpb	$16, %dl
	jae	.LBB0_154
	.p2align	4
.LBB0_152:                              #   in Loop: Header=BB0_147 Depth=4
	movq	%r13, %rcx
	movq	%r14, %rax
.LBB0_153:                              #   in Loop: Header=BB0_147 Depth=4
	addq	$56, %r12
	movq	%rax, %r14
	movq	%rcx, %r13
	decq	%rbp
	jne	.LBB0_147
	jmp	.LBB0_144
.LBB0_154:                              #   in Loop: Header=BB0_147 Depth=4
	movq	%rbx, %rcx
	movq	%r12, %rax
	testq	%r14, %r14
	je	.LBB0_153
# %bb.155:                              #   in Loop: Header=BB0_147 Depth=4
	movzbl	32(%r14), %esi
	andb	$-16, %sil
	movq	%rbx, %rcx
	movq	%r12, %rax
	cmpb	$32, %sil
	je	.LBB0_153
# %bb.156:                              #   in Loop: Header=BB0_147 Depth=4
	andb	$-16, %dl
	movq	%r13, %rcx
	movq	%r14, %rax
	cmpb	$32, %dl
	je	.LBB0_153
	jmp	.LBB0_448
.LBB0_157:                              #   in Loop: Header=BB0_128 Depth=2
	testq	%rax, %rax
	movq	88(%rsp), %r12                  # 8-byte Reload
	movq	104(%rsp), %rbp                 # 8-byte Reload
	movq	48(%rsp), %r15                  # 8-byte Reload
	movq	96(%rsp), %rbx                  # 8-byte Reload
	je	.LBB0_132
# %bb.158:                              #   in Loop: Header=BB0_128 Depth=2
	testq	%rcx, %rcx
	je	.LBB0_132
# %bb.159:                              #   in Loop: Header=BB0_128 Depth=2
	movzwl	8(%rax), %edx
	cmpl	$65522, %edx                    # imm = 0xFFF2
	je	.LBB0_164
# %bb.160:                              #   in Loop: Header=BB0_128 Depth=2
	cmpl	$65521, %edx                    # imm = 0xFFF1
	je	.LBB0_161
# %bb.166:                              #   in Loop: Header=BB0_128 Depth=2
	cmpq	%rdx, 32(%rcx)
	jbe	.LBB0_506
# %bb.167:                              #   in Loop: Header=BB0_128 Depth=2
	movq	24(%rcx), %rcx
	imulq	$88, %rdx, %rdx
	cmpl	$0, 84(%rcx,%rdx)
	je	.LBB0_504
# %bb.168:                              #   in Loop: Header=BB0_128 Depth=2
	addq	%rdx, %rcx
	movq	16(%rax), %rdx
	addq	72(%rcx), %rdx
	jmp	.LBB0_169
.LBB0_162:                              #   in Loop: Header=BB0_128 Depth=2
	movl	$1, 376(%rsp)
	movq	%rbx, 384(%rsp)
	movq	%rbx, 392(%rsp)
	movq	%rbx, 400(%rsp)
	movl	$1, 64(%rsp)                    # 4-byte Folded Spill
	movq	%rbx, 24(%rsp)                  # 8-byte Spill
	cmpq	24(%rsp), %rbp                  # 8-byte Folded Reload
	jbe	.LBB0_127
.LBB0_163:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rbp, 400(%rsp)
	movq	%rbp, 24(%rsp)                  # 8-byte Spill
	jmp	.LBB0_127
.LBB0_164:                              #   in Loop: Header=BB0_128 Depth=2
	cmpl	$0, 48(%rax)
	je	.LBB0_505
# %bb.165:                              #   in Loop: Header=BB0_128 Depth=2
	movq	40(%rax), %rdx
	jmp	.LBB0_169
.LBB0_170:
	movq	%rbp, 176(%rsp)
	movl	112(%rsp), %eax                 # 4-byte Reload
	movl	%eax, 84(%rsp)
.LBB0_171:
	cmpl	$0, 312(%rsp)
	je	.LBB0_509
# %bb.172:
	movq	320(%rsp), %rbx
	cmpq	%rbx, 328(%rsp)
	je	.LBB0_509
# %bb.173:
	cmpl	$0, 84(%rsp)
	movq	176(%rsp), %rcx
	jne	.LBB0_175
# %bb.174:
	movq	408(%rsp), %rax
	addq	%rcx, %rax
	movq	%rax, 432(%rsp)
	movq	%rax, 440(%rsp)
.LBB0_175:
	movq	%rcx, 184(%rsp)                 # 8-byte Spill
	movq	%rcx, 424(%rsp)
	movq	416(%rsp), %rax
	testq	%rax, %rax
	je	.LBB0_513
# %bb.176:
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	leaq	4096(%rax), %r14
	movl	$1, %esi
	movq	%r14, %rdi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_514
# %bb.177:
	cmpq	%rbx, 336(%rsp)
	jbe	.LBB0_179
# %bb.178:
	movl	$0, 152(%rsp)
	movw	$1, %dx
	cmpl	$0, 344(%rsp)
	jne	.LBB0_180
	jmp	.LBB0_182
.LBB0_179:
	xorl	%edx, %edx
	cmpl	$0, 344(%rsp)
	je	.LBB0_182
.LBB0_180:
	movq	368(%rsp), %rcx
	cmpq	352(%rsp), %rcx
	jbe	.LBB0_182
# %bb.181:
	movzwl	%dx, %ecx
	leal	1(%rcx), %edx
	movl	$1, 152(%rsp,%rcx,4)
.LBB0_182:
	cmpl	$0, 376(%rsp)
	je	.LBB0_186
# %bb.183:
	movq	400(%rsp), %rcx
	cmpq	384(%rsp), %rcx
	jbe	.LBB0_186
# %bb.184:
	movzwl	%dx, %ecx
	leal	1(%rcx), %edx
	movl	%edx, (%rsp)                    # 4-byte Spill
	movl	$2, 152(%rsp,%rcx,4)
	jmp	.LBB0_187
.LBB0_186:
	movl	%edx, (%rsp)                    # 4-byte Spill
.LBB0_187:
	movq	%r14, 192(%rsp)                 # 8-byte Spill
	movq	%rax, 216(%rsp)                 # 8-byte Spill
	movq	296(%rsp), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	movq	48(%rax), %r12
	testq	%r12, %r12
	je	.LBB0_510
# %bb.188:
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	40(%rax), %r13
	xorl	%r15d, %r15d
	leaq	.L.str.51(%rip), %rbx
	jmp	.LBB0_190
	.p2align	4
.LBB0_189:                              #   in Loop: Header=BB0_190 Depth=1
	addq	$56, %r13
	decq	%r12
	je	.LBB0_201
.LBB0_190:                              # =>This Inner Loop Header: Depth=1
	movzwl	8(%r13), %ebp
	testq	%rbp, %rbp
	je	.LBB0_189
# %bb.191:                              #   in Loop: Header=BB0_190 Depth=1
	movq	(%r13), %rdi
	movq	%rbx, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_189
# %bb.192:                              #   in Loop: Header=BB0_190 Depth=1
	movzbl	32(%r13), %eax
	cmpl	$15, %eax
	jbe	.LBB0_501
# %bb.193:                              #   in Loop: Header=BB0_190 Depth=1
	testb	$13, %al
	jne	.LBB0_507
# %bb.194:                              #   in Loop: Header=BB0_190 Depth=1
	cmpl	$65521, %ebp                    # imm = 0xFFF1
	movq	16(%rsp), %rdi                  # 8-byte Reload
	je	.LBB0_500
# %bb.195:                              #   in Loop: Header=BB0_190 Depth=1
	cmpq	%rbp, 32(%rdi)
	jbe	.LBB0_500
# %bb.196:                              #   in Loop: Header=BB0_190 Depth=1
	movq	24(%rdi), %rax
	imulq	$88, %rbp, %rcx
	cmpl	$0, 84(%rax,%rcx)
	je	.LBB0_483
# %bb.197:                              #   in Loop: Header=BB0_190 Depth=1
	addq	%rcx, %rax
	cmpl	$0, 80(%rax)
	jne	.LBB0_483
# %bb.198:                              #   in Loop: Header=BB0_190 Depth=1
	testb	$4, 16(%rax)
	je	.LBB0_483
# %bb.199:                              #   in Loop: Header=BB0_190 Depth=1
	testq	%r15, %r15
	movq	%r13, %r15
	je	.LBB0_189
# %bb.200:
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	main.cold.22
.LBB0_201:
	testq	%r15, %r15
	je	.LBB0_510
# %bb.202:
	movzwl	8(%r15), %eax
	cmpl	$65522, %eax                    # imm = 0xFFF2
	movq	216(%rsp), %rbp                 # 8-byte Reload
	movq	192(%rsp), %r13                 # 8-byte Reload
	je	.LBB0_205
# %bb.203:
	cmpl	$65521, %eax                    # imm = 0xFFF1
	jne	.LBB0_207
# %bb.204:
	movq	16(%r15), %rcx
	jmp	.LBB0_210
.LBB0_205:
	cmpl	$0, 48(%r15)
	je	.LBB0_532
# %bb.206:
	movq	40(%r15), %rcx
	jmp	.LBB0_210
.LBB0_207:
	movq	16(%rsp), %rcx                  # 8-byte Reload
	cmpq	%rax, 32(%rcx)
	jbe	.LBB0_533
# %bb.208:
	movq	24(%rcx), %rdx
	imulq	$88, %rax, %rax
	cmpl	$0, 84(%rdx,%rax)
	je	.LBB0_534
# %bb.209:
	addq	%rax, %rdx
	movq	16(%r15), %rcx
	addq	72(%rdx), %rcx
.LBB0_210:
	movl	$1179403647, (%rbp)             # imm = 0x464C457F
	movw	$258, 4(%rbp)                   # imm = 0x102
	movb	$1, 6(%rbp)
	cmpq	$16, %r13
	movl	(%rsp), %edi                    # 4-byte Reload
	jb	.LBB0_515
# %bb.211:
	movq	%r13, %rax
	andq	$-2, %rax
	cmpq	$16, %rax
	je	.LBB0_515
# %bb.212:
	movb	$2, 16(%rbp)
	cmpq	$18, %rax
	je	.LBB0_516
# %bb.213:
	movb	$-73, 18(%rbp)
	movq	%r13, %rdx
	andq	$-4, %rdx
	cmpq	$20, %rdx
	je	.LBB0_517
# %bb.214:
	movb	$1, 20(%rbp)
	cmpq	$24, %rdx
	je	.LBB0_518
# %bb.215:
	movl	%ecx, 24(%rbp)
	cmpq	$28, %rdx
	je	.LBB0_519
# %bb.216:
	movq	%rcx, %rsi
	shrq	$32, %rsi
	movb	%sil, 28(%rbp)
	movq	%rcx, %rsi
	shrq	$40, %rsi
	movb	%sil, 29(%rbp)
	movq	%rcx, %rsi
	shrq	$48, %rsi
	movb	%sil, 30(%rbp)
	shrq	$56, %rcx
	movb	%cl, 31(%rbp)
	cmpq	$32, %rdx
	je	.LBB0_520
# %bb.217:
	movb	$64, 32(%rbp)
	movq	24(%rsp), %rdx                  # 8-byte Reload
	leaq	4060(%rdx), %rcx
	shrq	$2, %rcx
	cmpq	$3, %rcx
	jbe	.LBB0_502
# %bb.218:
	cmpq	$52, %rax
	je	.LBB0_524
# %bb.219:
	movb	$64, 52(%rbp)
	cmpq	$54, %rax
	je	.LBB0_525
# %bb.220:
	movb	$56, 54(%rbp)
	cmpq	$56, %rax
	je	.LBB0_526
# %bb.221:
	movb	%dil, 56(%rbp)
	cmpq	$62, %rax
	je	.LBB0_527
# %bb.222:
	cmpq	$60, %rax
	je	.LBB0_528
# %bb.223:
	cmpq	$58, %rax
	je	.LBB0_529
# %bb.224:
	testw	%di, %di
	je	.LBB0_242
# %bb.225:
	movq	408(%rsp), %rax
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	leaq	4092(%rdx), %rax
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	movzwl	%di, %eax
	imulq	$56, %rax, %rax
	movq	%rax, 72(%rsp)                  # 8-byte Spill
	movl	$64, %esi
	leaq	152(%rsp), %rdi
	xorl	%r8d, %r8d
	.p2align	4
.LBB0_226:                              # =>This Inner Loop Header: Depth=1
	cmpq	%r13, %rsi
	ja	.LBB0_486
# %bb.227:                              #   in Loop: Header=BB0_226 Depth=1
	leaq	(%rdx,%r8), %rax
	addq	$4032, %rax                     # imm = 0xFC0
	cmpq	$3, %rax
	jbe	.LBB0_486
# %bb.228:                              #   in Loop: Header=BB0_226 Depth=1
	movslq	(%rdi), %rax
	movq	%rax, %r9
	shlq	$5, %r9
	leaq	312(%rsp), %rcx
	movq	8(%rcx,%r9), %r14
	movq	16(%rcx,%r9), %rbx
	movq	24(%rcx,%r9), %r10
	movl	$1, (%rbp,%rsi)
	leaq	4(%rsi), %r9
	cmpq	32(%rsp), %r9                   # 8-byte Folded Reload
	ja	.LBB0_487
# %bb.229:                              #   in Loop: Header=BB0_226 Depth=1
	cmpl	$1, %eax
	setne	%r9b
	addb	%r9b, %r9b
	orb	$4, %r9b
	testl	%eax, %eax
	movzbl	%r9b, %eax
	movl	$5, %ecx
	cmovel	%ecx, %eax
	movb	%al, 4(%rbp,%rsi)
	movw	$0, 5(%rbp,%rsi)
	movb	$0, 7(%rbp,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$4024, %rax                     # imm = 0xFB8
	cmpq	$3, %rax
	jbe	.LBB0_488
# %bb.230:                              #   in Loop: Header=BB0_226 Depth=1
	leaq	4096(%r14), %rax
	movb	%r14b, 8(%rbp,%rsi)
	movb	%ah, 9(%rbp,%rsi)
	movl	%eax, %r9d
	shrl	$16, %r9d
	movb	%r9b, 10(%rbp,%rsi)
	movl	%eax, %r9d
	shrl	$24, %r9d
	movb	%r9b, 11(%rbp,%rsi)
	leaq	(%rdx,%r8), %r9
	addq	$4020, %r9                      # imm = 0xFB4
	cmpq	$3, %r9
	jbe	.LBB0_489
# %bb.231:                              #   in Loop: Header=BB0_226 Depth=1
	movq	%rax, %r9
	shrq	$32, %r9
	movb	%r9b, 12(%rbp,%rsi)
	movq	%rax, %r9
	shrq	$40, %r9
	movb	%r9b, 13(%rbp,%rsi)
	movq	%rax, %r9
	shrq	$48, %r9
	movb	%r9b, 14(%rbp,%rsi)
	shrq	$56, %rax
	movb	%al, 15(%rbp,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$4016, %rax                     # imm = 0xFB0
	cmpq	$3, %rax
	jbe	.LBB0_490
# %bb.232:                              #   in Loop: Header=BB0_226 Depth=1
	movq	%rdi, (%rsp)                    # 8-byte Spill
	movq	56(%rsp), %rax                  # 8-byte Reload
	leaq	(%r14,%rax), %r15
	movl	%r15d, 16(%rbp,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$4012, %rax                     # imm = 0xFAC
	cmpq	$3, %rax
	jbe	.LBB0_491
# %bb.233:                              #   in Loop: Header=BB0_226 Depth=1
	movq	%r14, %r11
	movq	%r15, %r9
	shrq	$32, %r9
	movb	%r9b, 20(%rbp,%rsi)
	movq	%r15, %r13
	shrq	$40, %r13
	movb	%r13b, 21(%rbp,%rsi)
	movq	%r15, %rax
	shrq	$48, %rax
	movb	%al, 22(%rbp,%rsi)
	movq	%r15, %r12
	shrq	$56, %r12
	movb	%r12b, 23(%rbp,%rsi)
	movq	%rbp, %r14
	leaq	(%rdx,%r8), %rbp
	addq	$4008, %rbp                     # imm = 0xFA8
	cmpq	$3, %rbp
	jbe	.LBB0_492
# %bb.234:                              #   in Loop: Header=BB0_226 Depth=1
	movq	%rdx, %rdi
	movl	%r15d, %ebp
	shrl	$8, %ebp
	movl	%r15d, %ecx
	shrl	$16, %ecx
	movl	%r15d, %edx
	shrl	$24, %edx
	movb	%r15b, 24(%r14,%rsi)
	movb	%bpl, 25(%r14,%rsi)
	movb	%cl, 26(%r14,%rsi)
	movb	%dl, 27(%r14,%rsi)
	leaq	(%rdi,%r8), %rcx
	addq	$4004, %rcx                     # imm = 0xFA4
	cmpq	$3, %rcx
	jbe	.LBB0_493
# %bb.235:                              #   in Loop: Header=BB0_226 Depth=1
	movq	%r14, %rbp
	movq	%rdi, %rdx
	movb	%r9b, 28(%r14,%rsi)
	movb	%r13b, 29(%r14,%rsi)
	movb	%al, 30(%r14,%rsi)
	movb	%r12b, 31(%r14,%rsi)
	leaq	(%rdi,%r8), %rax
	addq	$4000, %rax                     # imm = 0xFA0
	cmpq	$3, %rax
	jbe	.LBB0_494
# %bb.236:                              #   in Loop: Header=BB0_226 Depth=1
	subq	%r11, %rbx
	movl	%ebx, 32(%rbp,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3996, %rax                     # imm = 0xF9C
	cmpq	$3, %rax
	movq	192(%rsp), %r13                 # 8-byte Reload
	movq	(%rsp), %rdi                    # 8-byte Reload
	jbe	.LBB0_495
# %bb.237:                              #   in Loop: Header=BB0_226 Depth=1
	movq	%rbx, %rax
	shrq	$32, %rax
	movb	%al, 36(%rbp,%rsi)
	movq	%rbx, %rax
	shrq	$40, %rax
	movb	%al, 37(%rbp,%rsi)
	movq	%rbx, %rax
	shrq	$48, %rax
	movb	%al, 38(%rbp,%rsi)
	shrq	$56, %rbx
	movb	%bl, 39(%rbp,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3992, %rax                     # imm = 0xF98
	cmpq	$3, %rax
	jbe	.LBB0_496
# %bb.238:                              #   in Loop: Header=BB0_226 Depth=1
	subq	%r11, %r10
	movl	%r10d, 40(%rbp,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3988, %rax                     # imm = 0xF94
	cmpq	$3, %rax
	jbe	.LBB0_497
# %bb.239:                              #   in Loop: Header=BB0_226 Depth=1
	movq	%r10, %rax
	shrq	$32, %rax
	movb	%al, 44(%rbp,%rsi)
	movq	%r10, %rax
	shrq	$40, %rax
	movb	%al, 45(%rbp,%rsi)
	movq	%r10, %rax
	shrq	$48, %rax
	movb	%al, 46(%rbp,%rsi)
	shrq	$56, %r10
	movb	%r10b, 47(%rbp,%rsi)
	leaq	(%rdx,%r8), %rax
	addq	$3984, %rax                     # imm = 0xF90
	cmpq	$3, %rax
	jbe	.LBB0_498
# %bb.240:                              #   in Loop: Header=BB0_226 Depth=1
	movl	$4096, 48(%rbp,%rsi)            # imm = 0x1000
	leaq	(%rdx,%r8), %rax
	addq	$3980, %rax                     # imm = 0xF8C
	cmpq	$3, %rax
	jbe	.LBB0_499
# %bb.241:                              #   in Loop: Header=BB0_226 Depth=1
	movl	$0, 52(%rbp,%rsi)
	addq	$-56, %r8
	addq	$56, %rsi
	addq	$4, %rdi
	movq	72(%rsp), %rax                  # 8-byte Reload
	addq	%r8, %rax
	jne	.LBB0_226
.LBB0_242:
	cmpq	$0, 40(%rsp)                    # 8-byte Folded Reload
	je	.LBB0_374
# %bb.243:
	xorl	%ebx, %ebx
	jmp	.LBB0_245
	.p2align	4
.LBB0_244:                              #   in Loop: Header=BB0_245 Depth=1
	incq	%rbx
	cmpq	40(%rsp), %rbx                  # 8-byte Folded Reload
	je	.LBB0_253
.LBB0_245:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_248 Depth 2
	imulq	$56, %rbx, %r14
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	32(%rax,%r14), %rax
	cmpq	$2, %rax
	jb	.LBB0_244
# %bb.246:                              #   in Loop: Header=BB0_245 Depth=1
	addq	16(%rsp), %r14                  # 8-byte Folded Reload
	movl	$1, %r15d
	movl	$96, %r12d
	jmp	.LBB0_248
	.p2align	4
.LBB0_247:                              #   in Loop: Header=BB0_248 Depth=2
	incq	%r15
	addq	$88, %r12
	cmpq	%rax, %r15
	jae	.LBB0_244
.LBB0_248:                              #   Parent Loop BB0_245 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	24(%r14), %rcx
	cmpl	$0, 76(%rcx,%r12)
	je	.LBB0_247
# %bb.249:                              #   in Loop: Header=BB0_248 Depth=2
	cmpl	$8, (%rcx,%r12)
	je	.LBB0_247
# %bb.250:                              #   in Loop: Header=BB0_248 Depth=2
	movq	24(%rcx,%r12), %rdx
	testq	%rdx, %rdx
	je	.LBB0_247
# %bb.251:                              #   in Loop: Header=BB0_248 Depth=2
	movq	56(%rcx,%r12), %rdi
	leaq	(%rdi,%rdx), %rax
	addq	$4096, %rax                     # imm = 0x1000
	cmpq	%r13, %rax
	ja	.LBB0_458
# %bb.252:                              #   in Loop: Header=BB0_248 Depth=2
	addq	$4096, %rdi                     # imm = 0x1000
	addq	%rbp, %rdi
	movq	8(%r14), %rsi
	addq	16(%rcx,%r12), %rsi
	callq	memcpy@PLT
	movq	32(%r14), %rax
	jmp	.LBB0_247
.LBB0_253:
	movq	440(%rsp), %rax
	movq	%rax, 224(%rsp)                 # 8-byte Spill
	movq	408(%rsp), %rax
	movq	432(%rsp), %rcx
	movq	%rcx, 232(%rsp)                 # 8-byte Spill
	movq	184(%rsp), %rbx                 # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	addq	%rax, %rbx
	xorl	%eax, %eax
	movq	%rbx, 184(%rsp)                 # 8-byte Spill
	jmp	.LBB0_255
	.p2align	4
.LBB0_254:                              #   in Loop: Header=BB0_255 Depth=1
	movq	448(%rsp), %rax                 # 8-byte Reload
	incq	%rax
	cmpq	40(%rsp), %rax                  # 8-byte Folded Reload
	je	.LBB0_374
.LBB0_255:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_260 Depth 2
                                        #       Child Loop BB0_276 Depth 3
                                        #         Child Loop BB0_311 Depth 4
                                        #           Child Loop BB0_315 Depth 5
	movq	%rax, 448(%rsp)                 # 8-byte Spill
	imulq	$56, %rax, %r11
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	32(%rax,%r11), %rsi
	testq	%rsi, %rsi
	je	.LBB0_254
# %bb.256:                              #   in Loop: Header=BB0_255 Depth=1
	addq	16(%rsp), %r11                  # 8-byte Folded Reload
	xorl	%ecx, %ecx
	movq	%r11, 64(%rsp)                  # 8-byte Spill
	jmp	.LBB0_260
	.p2align	4
.LBB0_257:                              #   in Loop: Header=BB0_260 Depth=2
	movq	32(%r11), %rsi
.LBB0_258:                              #   in Loop: Header=BB0_260 Depth=2
	movq	200(%rsp), %rcx                 # 8-byte Reload
.LBB0_259:                              #   in Loop: Header=BB0_260 Depth=2
	incq	%rcx
	cmpq	%rsi, %rcx
	jae	.LBB0_254
.LBB0_260:                              #   Parent Loop BB0_255 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_276 Depth 3
                                        #         Child Loop BB0_311 Depth 4
                                        #           Child Loop BB0_315 Depth 5
	movq	24(%r11), %r15
	imulq	$88, %rcx, %r12
	movl	8(%r15,%r12), %eax
	cmpl	$9, %eax
	je	.LBB0_262
# %bb.261:                              #   in Loop: Header=BB0_260 Depth=2
	cmpl	$4, %eax
	jne	.LBB0_259
.LBB0_262:                              #   in Loop: Header=BB0_260 Depth=2
	movq	%rcx, 200(%rsp)                 # 8-byte Spill
	addq	%r15, %r12
	movl	44(%r12), %ecx
	cmpq	%rcx, %rsi
	jbe	.LBB0_427
# %bb.263:                              #   in Loop: Header=BB0_260 Depth=2
	movl	40(%r12), %edx
	cmpq	%rdx, %rsi
	jbe	.LBB0_423
# %bb.264:                              #   in Loop: Header=BB0_260 Depth=2
	imulq	$88, %rdx, %rdx
	cmpl	$2, 8(%r15,%rdx)
	jne	.LBB0_423
# %bb.265:                              #   in Loop: Header=BB0_260 Depth=2
	imulq	$88, %rcx, %rcx
	cmpl	$0, 84(%r15,%rcx)
	je	.LBB0_258
# %bb.266:                              #   in Loop: Header=BB0_260 Depth=2
	addq	%rcx, %r15
	cmpl	$9, %eax
	je	.LBB0_452
# %bb.267:                              #   in Loop: Header=BB0_260 Depth=2
	cmpl	$8, 8(%r15)
	je	.LBB0_450
# %bb.268:                              #   in Loop: Header=BB0_260 Depth=2
	cmpq	$24, 56(%r12)
	jne	.LBB0_449
# %bb.269:                              #   in Loop: Header=BB0_260 Depth=2
	movq	32(%r12), %rcx
	movq	%rcx, %rax
	movabsq	$-6148914691236517205, %rdx     # imm = 0xAAAAAAAAAAAAAAAB
	mulq	%rdx
	movq	%rdx, 104(%rsp)                 # 8-byte Spill
	rorq	$3, %rax
	movabsq	$768614336404564651, %rdx       # imm = 0xAAAAAAAAAAAAAAB
	cmpq	%rdx, %rax
	jae	.LBB0_451
# %bb.270:                              #   in Loop: Header=BB0_260 Depth=2
	cmpq	$24, %rcx
	movq	200(%rsp), %rcx                 # 8-byte Reload
	jb	.LBB0_259
# %bb.271:                              #   in Loop: Header=BB0_260 Depth=2
	shrq	$4, 104(%rsp)                   # 8-byte Folded Spill
	xorl	%r9d, %r9d
	movq	%r15, 96(%rsp)                  # 8-byte Spill
	movq	%r12, 112(%rsp)                 # 8-byte Spill
	jmp	.LBB0_276
.LBB0_272:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%rax, %rcx
	shrq	$32, %rcx
	movb	%cl, (%rbp,%rdx)
	movq	%rax, %rcx
	shrq	$40, %rcx
	movb	%cl, 1(%rbp,%rdx)
	movq	%rax, %rcx
	shrq	$48, %rcx
	movb	%cl, 2(%rbp,%rdx)
	shrq	$56, %rax
.LBB0_273:                              #   in Loop: Header=BB0_276 Depth=3
	movl	%eax, %esi
.LBB0_274:                              #   in Loop: Header=BB0_276 Depth=3
	movb	%sil, 3(%rbp,%rdx)
.LBB0_275:                              #   in Loop: Header=BB0_276 Depth=3
	incq	%r9
	cmpq	104(%rsp), %r9                  # 8-byte Folded Reload
	je	.LBB0_257
.LBB0_276:                              #   Parent Loop BB0_255 Depth=1
                                        #     Parent Loop BB0_260 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_311 Depth 4
                                        #           Child Loop BB0_315 Depth 5
	leaq	(%r9,%r9,2), %rax
	shlq	$3, %rax
	addq	24(%r12), %rax
	movq	16(%r11), %rcx
	movq	%rcx, %rdx
	subq	%rax, %rdx
	jb	.LBB0_384
# %bb.277:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rdx
	jbe	.LBB0_384
# %bb.278:                              #   in Loop: Header=BB0_276 Depth=3
	leaq	4(%rax), %rsi
	movq	%rcx, %rdx
	subq	%rsi, %rdx
	jb	.LBB0_386
# %bb.279:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rdx
	jbe	.LBB0_386
# %bb.280:                              #   in Loop: Header=BB0_276 Depth=3
	leaq	8(%rax), %rsi
	movq	%rcx, %rdx
	subq	%rsi, %rdx
	jb	.LBB0_388
# %bb.281:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rdx
	jbe	.LBB0_388
# %bb.282:                              #   in Loop: Header=BB0_276 Depth=3
	leaq	12(%rax), %rsi
	movq	%rcx, %rdx
	subq	%rsi, %rdx
	jb	.LBB0_383
# %bb.283:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rdx
	jbe	.LBB0_383
# %bb.284:                              #   in Loop: Header=BB0_276 Depth=3
	leaq	16(%rax), %rdx
	movq	%rcx, %rsi
	subq	%rdx, %rsi
	jb	.LBB0_385
# %bb.285:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rsi
	jbe	.LBB0_385
# %bb.286:                              #   in Loop: Header=BB0_276 Depth=3
	leaq	20(%rax), %rsi
	subq	%rsi, %rcx
	jb	.LBB0_387
# %bb.287:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rcx
	jbe	.LBB0_387
# %bb.288:                              #   in Loop: Header=BB0_276 Depth=3
	movq	8(%r11), %rdi
	movq	(%rdi,%rax), %r8
	movl	8(%rdi,%rax), %ecx
	movl	12(%rdi,%rax), %eax
	movl	(%rdi,%rdx), %r10d
	movl	(%rdi,%rsi), %edi
	movq	%r11, 240(%rsp)
	movq	%r12, 248(%rsp)
	movq	%r15, 256(%rsp)
	movq	%r9, 264(%rsp)
	movq	%r8, 272(%rsp)
	movl	%ecx, 280(%rsp)
	movq	%rax, 288(%rsp)
	leal	-257(%rcx), %r14d
	cmpl	$42, %r14d
	ja	.LBB0_328
# %bb.289:                              #   in Loop: Header=BB0_276 Depth=3
	movl	$4, %edx
	movabsq	$4399090237440, %rsi            # imm = 0x4003E360000
	movq	%r14, 32(%rsp)                  # 8-byte Spill
	btq	%r14, %rsi
	jae	.LBB0_326
.LBB0_290:                              #   in Loop: Header=BB0_276 Depth=3
	movq	32(%r15), %rcx
	subq	%r8, %rcx
	jb	.LBB0_390
# %bb.291:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	%rcx, %rdx
	ja	.LBB0_390
# %bb.292:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	%rax, 48(%r11)
	jbe	.LBB0_393
# %bb.293:                              #   in Loop: Header=BB0_276 Depth=3
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
	je	.LBB0_391
# %bb.294:                              #   in Loop: Header=BB0_276 Depth=3
	testb	$12, %al
	jne	.LBB0_389
# %bb.295:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r10, 24(%rsp)                  # 8-byte Spill
	movq	%rdi, 72(%rsp)                  # 8-byte Spill
	movq	%r8, 56(%rsp)                   # 8-byte Spill
	movq	%r9, (%rsp)                     # 8-byte Spill
	cmpw	$0, 8(%rsi)
	je	.LBB0_303
# %bb.296:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r11, %rdi
	leaq	240(%rsp), %rdx
	callq	defined_symbol_value_for_relocation
.LBB0_297:                              #   in Loop: Header=BB0_276 Depth=3
	movq	32(%rsp), %r8                   # 8-byte Reload
	cmpl	$42, %r8d
	movq	64(%rsp), %r11                  # 8-byte Reload
	movq	96(%rsp), %r15                  # 8-byte Reload
	movq	112(%rsp), %r12                 # 8-byte Reload
	movq	(%rsp), %r9                     # 8-byte Reload
	ja	.LBB0_275
# %bb.298:                              #   in Loop: Header=BB0_276 Depth=3
	movq	72(%rsp), %rcx                  # 8-byte Reload
	shlq	$32, %rcx
	addq	24(%rsp), %rcx                  # 8-byte Folded Reload
	addq	%rcx, %rax
	movq	72(%r15), %rcx
	movq	56(%rsp), %rsi                  # 8-byte Reload
	addq	%rsi, %rcx
	movq	64(%r15), %rdx
	addq	%rsi, %rdx
	addq	$4096, %rdx                     # imm = 0x1000
	leaq	.LJTI0_1(%rip), %rdi
	movslq	(%rdi,%r8,4), %rsi
	addq	%rdi, %rsi
	jmpq	*%rsi
.LBB0_299:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r13, %rcx
	subq	%rdx, %rcx
	jb	.LBB0_433
# %bb.300:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$7, %rcx
	jbe	.LBB0_433
# %bb.301:                              #   in Loop: Header=BB0_276 Depth=3
	movl	%eax, (%rbp,%rdx)
	addq	$4, %rdx
	movq	%r13, %rcx
	subq	%rdx, %rcx
	jb	.LBB0_440
# %bb.302:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rcx
	ja	.LBB0_272
	jmp	.LBB0_440
	.p2align	4
.LBB0_303:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%rsi, %r14
	movq	(%rsi), %r12
	movq	%r12, %rdi
	leaq	.L.str.90(%rip), %rsi
	callq	strcmp@PLT
	movl	%eax, %ecx
	movq	8(%rsp), %rax                   # 8-byte Reload
	testl	%ecx, %ecx
	je	.LBB0_297
# %bb.304:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r12, %rdi
	leaq	.L.str.91(%rip), %rsi
	callq	strcmp@PLT
	movl	%eax, %ecx
	movq	%rbx, %rax
	testl	%ecx, %ecx
	je	.LBB0_297
# %bb.305:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r12, %rdi
	leaq	.L.str.92(%rip), %rsi
	callq	strcmp@PLT
	movl	%eax, %ecx
	movq	232(%rsp), %rax                 # 8-byte Reload
	testl	%ecx, %ecx
	je	.LBB0_297
# %bb.306:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r12, %rdi
	leaq	.L.str.93(%rip), %rsi
	callq	strcmp@PLT
	movl	%eax, %ecx
	movq	232(%rsp), %rax                 # 8-byte Reload
	testl	%ecx, %ecx
	je	.LBB0_297
# %bb.307:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r12, %rdi
	leaq	.L.str.94(%rip), %rsi
	callq	strcmp@PLT
	movl	%eax, %ecx
	movq	224(%rsp), %rax                 # 8-byte Reload
	testl	%ecx, %ecx
	je	.LBB0_297
# %bb.308:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r12, %rdi
	leaq	.L.str.95(%rip), %rsi
	callq	strcmp@PLT
	movl	%eax, %ecx
	movq	224(%rsp), %rax                 # 8-byte Reload
	testl	%ecx, %ecx
	je	.LBB0_297
# %bb.309:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r14, 208(%rsp)                 # 8-byte Spill
	xorl	%ebx, %ebx
	xorl	%r14d, %r14d
	movq	$0, 136(%rsp)                   # 8-byte Folded Spill
	movq	$0, 88(%rsp)                    # 8-byte Folded Spill
	movq	$0, 144(%rsp)                   # 8-byte Folded Spill
	jmp	.LBB0_311
	.p2align	4
.LBB0_310:                              #   in Loop: Header=BB0_311 Depth=4
	incq	%r14
	cmpq	40(%rsp), %r14                  # 8-byte Folded Reload
	je	.LBB0_371
.LBB0_311:                              #   Parent Loop BB0_255 Depth=1
                                        #     Parent Loop BB0_260 Depth=2
                                        #       Parent Loop BB0_276 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB0_315 Depth 5
	imulq	$56, %r14, %rcx
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	48(%rax,%rcx), %rbp
	testq	%rbp, %rbp
	je	.LBB0_310
# %bb.312:                              #   in Loop: Header=BB0_311 Depth=4
	addq	%rax, %rcx
	movq	%rcx, 48(%rsp)                  # 8-byte Spill
	movq	40(%rcx), %r13
	jmp	.LBB0_315
.LBB0_313:                              #   in Loop: Header=BB0_315 Depth=5
	movq	%r13, 88(%rsp)                  # 8-byte Spill
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 136(%rsp)                 # 8-byte Spill
	.p2align	4
.LBB0_314:                              #   in Loop: Header=BB0_315 Depth=5
	addq	$56, %r13
	decq	%rbp
	je	.LBB0_310
.LBB0_315:                              #   Parent Loop BB0_255 Depth=1
                                        #     Parent Loop BB0_260 Depth=2
                                        #       Parent Loop BB0_276 Depth=3
                                        #         Parent Loop BB0_311 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	movzwl	8(%r13), %r15d
	testw	%r15w, %r15w
	je	.LBB0_314
# %bb.316:                              #   in Loop: Header=BB0_315 Depth=5
	movq	(%r13), %rdi
	cmpb	$0, (%rdi)
	je	.LBB0_314
# %bb.317:                              #   in Loop: Header=BB0_315 Depth=5
	movq	%r12, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_314
# %bb.318:                              #   in Loop: Header=BB0_315 Depth=5
	movzbl	32(%r13), %eax
	cmpb	$16, %al
	jb	.LBB0_314
# %bb.319:                              #   in Loop: Header=BB0_315 Depth=5
	cmpw	$-14, %r15w
	jne	.LBB0_322
# %bb.320:                              #   in Loop: Header=BB0_315 Depth=5
	movq	88(%rsp), %rax                  # 8-byte Reload
	testq	%rax, %rax
	je	.LBB0_313
# %bb.321:                              #   in Loop: Header=BB0_315 Depth=5
	movzbl	32(%rax), %eax
	andb	$-16, %al
	cmpb	$32, %al
	je	.LBB0_313
	jmp	.LBB0_314
.LBB0_322:                              #   in Loop: Header=BB0_315 Depth=5
	testq	%rbx, %rbx
	je	.LBB0_324
# %bb.323:                              #   in Loop: Header=BB0_315 Depth=5
	movzbl	32(%rbx), %ecx
	andb	$-16, %cl
	cmpb	$32, %cl
	jne	.LBB0_325
.LBB0_324:                              #   in Loop: Header=BB0_315 Depth=5
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 144(%rsp)                 # 8-byte Spill
	movq	%r13, %rbx
	jmp	.LBB0_314
.LBB0_325:                              #   in Loop: Header=BB0_315 Depth=5
	andb	$-16, %al
	cmpb	$32, %al
	je	.LBB0_314
	jmp	.LBB0_425
.LBB0_326:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$0, 32(%rsp)                    # 8-byte Folded Reload
	jne	.LBB0_328
# %bb.327:                              #   in Loop: Header=BB0_276 Depth=3
	movl	$8, %edx
	jmp	.LBB0_290
.LBB0_328:                              #   in Loop: Header=BB0_276 Depth=3
	testl	%ecx, %ecx
	je	.LBB0_275
	jmp	.LBB0_428
.LBB0_329:                              #   in Loop: Header=BB0_276 Depth=3
	movl	$4, %ecx
	jmp	.LBB0_361
.LBB0_330:                              #   in Loop: Header=BB0_276 Depth=3
	xorl	%ecx, %ecx
	movb	$1, %r8b
	jmp	.LBB0_362
.LBB0_331:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	.LBB0_429
# %bb.332:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rsi
	jbe	.LBB0_429
# %bb.333:                              #   in Loop: Header=BB0_276 Depth=3
	subq	%rcx, %rax
	testb	$3, %al
	jne	.LBB0_442
# %bb.334:                              #   in Loop: Header=BB0_276 Depth=3
	sarq	$2, %rax
	leaq	-33554432(%rax), %rcx
	cmpq	$-67108865, %rcx                # imm = 0xFBFFFFFF
	jbe	.LBB0_443
# %bb.335:                              #   in Loop: Header=BB0_276 Depth=3
	movl	(%rbp,%rdx), %ecx
	movl	$-67108864, %esi                # imm = 0xFC000000
	andl	%esi, %ecx
	cmpl	$335544320, %ecx                # imm = 0x14000000
	jne	.LBB0_446
# %bb.336:                              #   in Loop: Header=BB0_276 Depth=3
	movb	%al, (%rbp,%rdx)
	movb	%ah, 1(%rbp,%rdx)
	movl	%eax, %ecx
	shrl	$16, %ecx
	movb	%cl, 2(%rbp,%rdx)
	shrl	$24, %eax
	andb	$3, %al
	orb	$20, %al
	jmp	.LBB0_273
.LBB0_337:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r13, %rcx
	subq	%rdx, %rcx
	jb	.LBB0_430
# %bb.338:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rcx
	jbe	.LBB0_430
# %bb.339:                              #   in Loop: Header=BB0_276 Depth=3
	movl	(%rbp,%rdx), %esi
	movl	%esi, %ecx
	andl	$2130706432, %ecx               # imm = 0x7F000000
	cmpl	$285212672, %ecx                # imm = 0x11000000
	jne	.LBB0_431
# %bb.340:                              #   in Loop: Header=BB0_276 Depth=3
	testl	$4194304, %esi                  # imm = 0x400000
	jne	.LBB0_436
# %bb.341:                              #   in Loop: Header=BB0_276 Depth=3
	movl	%esi, %ecx
	andl	$-1853881345, %ecx              # imm = 0x918003FF
	shll	$10, %eax
	andl	$4193280, %eax                  # imm = 0x3FFC00
	orl	%ecx, %eax
	movb	%sil, (%rbp,%rdx)
	movb	%ah, 1(%rbp,%rdx)
	shrl	$16, %eax
	movb	%al, 2(%rbp,%rdx)
	shrl	$24, %esi
	jmp	.LBB0_274
.LBB0_342:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	.LBB0_439
# %bb.343:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rsi
	jbe	.LBB0_439
# %bb.344:                              #   in Loop: Header=BB0_276 Depth=3
	andq	$-4096, %rcx                    # imm = 0xF000
	subq	%rcx, %rax
	sarq	$12, %rax
	leaq	-1048576(%rax), %rcx
	cmpq	$-2097153, %rcx                 # imm = 0xFFDFFFFF
	jbe	.LBB0_432
# %bb.345:                              #   in Loop: Header=BB0_276 Depth=3
	movl	(%rbp,%rdx), %ecx
	movl	%ecx, %esi
	andl	$-1627389952, %esi              # imm = 0x9F000000
	cmpl	$-1879048192, %esi              # imm = 0x90000000
	jne	.LBB0_437
# %bb.346:                              #   in Loop: Header=BB0_276 Depth=3
	andl	$31, %ecx
	movl	%eax, %esi
	andl	$28, %esi
	leal	(%rcx,%rsi,8), %ecx
	movb	%cl, (%rbp,%rdx)
	movl	%eax, %ecx
	shrl	$5, %ecx
	movb	%cl, 1(%rbp,%rdx)
	movl	%eax, %ecx
	shrl	$13, %ecx
	movb	%cl, 2(%rbp,%rdx)
	shll	$5, %eax
	orb	$-112, %al
	jmp	.LBB0_273
.LBB0_347:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	.LBB0_435
# %bb.348:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rsi
	jbe	.LBB0_435
# %bb.349:                              #   in Loop: Header=BB0_276 Depth=3
	subq	%rcx, %rax
	leaq	-1048576(%rax), %rcx
	cmpq	$-2097153, %rcx                 # imm = 0xFFDFFFFF
	jbe	.LBB0_438
# %bb.350:                              #   in Loop: Header=BB0_276 Depth=3
	movl	(%rbp,%rdx), %ecx
	movl	%ecx, %esi
	andl	$-1627389952, %esi              # imm = 0x9F000000
	cmpl	$268435456, %esi                # imm = 0x10000000
	jne	.LBB0_434
# %bb.351:                              #   in Loop: Header=BB0_276 Depth=3
	andl	$31, %ecx
	movl	%eax, %esi
	andl	$28, %esi
	leal	(%rcx,%rsi,8), %ecx
	movb	%cl, (%rbp,%rdx)
	movl	%eax, %ecx
	shrl	$5, %ecx
	movb	%cl, 1(%rbp,%rdx)
	movl	%eax, %ecx
	shrl	$13, %ecx
	movb	%cl, 2(%rbp,%rdx)
	shlb	$5, %al
	andb	$96, %al
	orb	$16, %al
	jmp	.LBB0_273
.LBB0_352:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	.LBB0_445
# %bb.353:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rsi
	jbe	.LBB0_445
# %bb.354:                              #   in Loop: Header=BB0_276 Depth=3
	subq	%rcx, %rax
	testb	$3, %al
	jne	.LBB0_447
# %bb.355:                              #   in Loop: Header=BB0_276 Depth=3
	sarq	$2, %rax
	leaq	-33554432(%rax), %rcx
	cmpq	$-67108865, %rcx                # imm = 0xFBFFFFFF
	jbe	.LBB0_441
# %bb.356:                              #   in Loop: Header=BB0_276 Depth=3
	movl	(%rbp,%rdx), %ecx
	movl	$-67108864, %esi                # imm = 0xFC000000
	andl	%esi, %ecx
	cmpl	$-1811939328, %ecx              # imm = 0x94000000
	jne	.LBB0_444
# %bb.357:                              #   in Loop: Header=BB0_276 Depth=3
	movb	%al, (%rbp,%rdx)
	movb	%ah, 1(%rbp,%rdx)
	movl	%eax, %ecx
	shrl	$16, %ecx
	movb	%cl, 2(%rbp,%rdx)
	shrl	$24, %eax
	andb	$3, %al
	orb	$-108, %al
	jmp	.LBB0_273
.LBB0_358:                              #   in Loop: Header=BB0_276 Depth=3
	movl	$1, %ecx
	jmp	.LBB0_361
.LBB0_359:                              #   in Loop: Header=BB0_276 Depth=3
	movl	$3, %ecx
	jmp	.LBB0_361
.LBB0_360:                              #   in Loop: Header=BB0_276 Depth=3
	movl	$2, %ecx
.LBB0_361:                              #   in Loop: Header=BB0_276 Depth=3
	xorl	%r8d, %r8d
.LBB0_362:                              #   in Loop: Header=BB0_276 Depth=3
	movq	%r13, %rsi
	subq	%rdx, %rsi
	jb	.LBB0_413
# %bb.363:                              #   in Loop: Header=BB0_276 Depth=3
	cmpq	$3, %rsi
	jbe	.LBB0_413
# %bb.364:                              #   in Loop: Header=BB0_276 Depth=3
	movl	(%rbp,%rdx), %edi
	movl	%edi, %esi
	andl	$989855744, %esi                # imm = 0x3B000000
	cmpl	$956301312, %esi                # imm = 0x39000000
	jne	.LBB0_411
# %bb.365:                              #   in Loop: Header=BB0_276 Depth=3
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
	jne	.LBB0_412
# %bb.366:                              #   in Loop: Header=BB0_276 Depth=3
	testb	%r8b, %r8b
	movq	(%rsp), %r9                     # 8-byte Reload
	je	.LBB0_368
# %bb.367:                              #   in Loop: Header=BB0_276 Depth=3
	xorl	%ecx, %ecx
	jmp	.LBB0_370
.LBB0_368:                              #   in Loop: Header=BB0_276 Depth=3
	movl	$-1, %r8d
	shll	%cl, %r8d
	notl	%r8d
	testl	%r8d, %eax
	jne	.LBB0_424
# %bb.369:                              #   in Loop: Header=BB0_276 Depth=3
	movl	%ecx, %ecx
.LBB0_370:                              #   in Loop: Header=BB0_276 Depth=3
	andl	$4095, %eax                     # imm = 0xFFF
                                        # kill: def $cl killed $cl killed $rcx
	shrq	%cl, %rax
	movl	%edi, %ecx
	andl	$-37747713, %ecx                # imm = 0xFDC003FF
	shll	$10, %eax
	orl	%ecx, %eax
	movb	%dil, (%rbp,%rdx)
	movb	%ah, 1(%rbp,%rdx)
	shrl	$16, %eax
	movb	%al, 2(%rbp,%rdx)
	jmp	.LBB0_274
.LBB0_371:                              #   in Loop: Header=BB0_276 Depth=3
	testq	%rbx, %rbx
	movq	144(%rsp), %rdi                 # 8-byte Reload
	cmoveq	136(%rsp), %rdi                 # 8-byte Folded Reload
	movq	88(%rsp), %rsi                  # 8-byte Reload
	cmovneq	%rbx, %rsi
	testq	%rsi, %rsi
	je	.LBB0_459
# %bb.372:                              #   in Loop: Header=BB0_276 Depth=3
	testq	%rdi, %rdi
	je	.LBB0_459
# %bb.373:                              #   in Loop: Header=BB0_276 Depth=3
	leaq	240(%rsp), %rdx
	callq	defined_symbol_value_for_relocation
	movq	216(%rsp), %rbp                 # 8-byte Reload
	movq	192(%rsp), %r13                 # 8-byte Reload
	movq	184(%rsp), %rbx                 # 8-byte Reload
	jmp	.LBB0_297
.LBB0_374:
	leaq	.L.str.116(%rip), %rsi
	movq	120(%rsp), %rdi                 # 8-byte Reload
	callq	fopen@PLT
	testq	%rax, %rax
	je	.LBB0_530
# %bb.375:
	movq	%rax, %rbx
	movl	$1, %esi
	movq	%rbp, %rdi
	movq	%r13, %rdx
	movq	%rax, %rcx
	callq	fwrite@PLT
	cmpq	%r13, %rax
	jne	.LBB0_531
# %bb.376:
	movq	%rbx, %rdi
	callq	fclose@PLT
	movq	%rbp, %rdi
	callq	free@PLT
	movq	16(%rsp), %r15                  # 8-byte Reload
	leaq	40(%r15), %rbx
	movq	128(%rsp), %r14                 # 8-byte Reload
	.p2align	4
.LBB0_377:                              # =>This Inner Loop Header: Depth=1
	movq	(%rbx), %rdi
	callq	free@PLT
	movq	-16(%rbx), %rdi
	callq	free@PLT
	movq	-32(%rbx), %rdi
	callq	free@PLT
	addq	$56, %rbx
	decq	%r14
	jne	.LBB0_377
# %bb.378:
	movq	%r15, %rdi
	callq	free@PLT
	movq	168(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	xorl	%eax, %eax
.LBB0_379:
	addq	$456, %rsp                      # imm = 0x1C8
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB0_380:
	movq	168(%rsp), %rdi                 # 8-byte Reload
	callq	main.cold.4
.LBB0_381:
	movl	$1, %eax
	jmp	.LBB0_379
.LBB0_382:
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.4(%rip), %rsi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	jmp	.LBB0_381
.LBB0_383:
	callq	main.cold.81
.LBB0_384:
	callq	main.cold.84
.LBB0_385:
	callq	main.cold.80
.LBB0_386:
	callq	main.cold.83
.LBB0_387:
	callq	main.cold.79
.LBB0_388:
	callq	main.cold.82
.LBB0_389:
	leaq	.L.str.85(%rip), %rcx
	jmp	.LBB0_392
.LBB0_390:
	leaq	.L.str.64(%rip), %rsi
	leaq	240(%rsp), %rdi
	callq	die_relocation
.LBB0_391:
	leaq	.L.str.84(%rip), %rcx
.LBB0_392:
	leaq	240(%rsp), %rdi
	movq	%rsi, %rdx
	movq	%r11, %rsi
	callq	die_relocation_symbol
.LBB0_393:
	leaq	.L.str.83(%rip), %rsi
	leaq	240(%rsp), %rdi
	callq	die_relocation
.LBB0_394:
	callq	main.cold.5
.LBB0_395:
	callq	main.cold.103
.LBB0_396:
	callq	main.cold.102
.LBB0_397:
	callq	main.cold.112
.LBB0_398:
	callq	main.cold.109
.LBB0_399:
	callq	main.cold.104
.LBB0_400:
	callq	main.cold.116
.LBB0_401:
	callq	main.cold.115
.LBB0_402:
	callq	main.cold.114
.LBB0_403:
	callq	main.cold.113
.LBB0_404:
	callq	main.cold.111
.LBB0_405:
	callq	main.cold.110
.LBB0_406:
	callq	main.cold.108
.LBB0_407:
	callq	main.cold.105
.LBB0_408:
	callq	main.cold.107
.LBB0_409:
	callq	main.cold.106
.LBB0_410:
	leaq	.L.str.35(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_411:
	callq	main.cold.75
.LBB0_412:
	callq	main.cold.76
.LBB0_413:
	callq	main.cold.78
.LBB0_414:
	leaq	.L.str.22(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_415:
	callq	main.cold.12
.LBB0_416:
	callq	main.cold.9
.LBB0_417:
	callq	main.cold.10
.LBB0_418:
	callq	main.cold.7
.LBB0_419:
	callq	main.cold.13
.LBB0_420:
	callq	main.cold.14
.LBB0_421:
	callq	main.cold.8
.LBB0_422:
	callq	main.cold.11
.LBB0_423:
	callq	main.cold.52
.LBB0_424:
	callq	main.cold.77
.LBB0_425:
	movq	%r12, %rdi
	callq	main.cold.55
.LBB0_426:
	callq	main.cold.6
.LBB0_427:
	callq	main.cold.51
.LBB0_428:
	leaq	.L.str.63(%rip), %rsi
	leaq	240(%rsp), %rdi
	callq	die_relocation
.LBB0_429:
	callq	main.cold.61
.LBB0_430:
	callq	main.cold.68
.LBB0_431:
	callq	main.cold.66
.LBB0_432:
	callq	main.cold.70
.LBB0_433:
	callq	main.cold.57
.LBB0_434:
	callq	main.cold.72
.LBB0_435:
	callq	main.cold.74
.LBB0_436:
	callq	main.cold.67
.LBB0_437:
	callq	main.cold.69
.LBB0_438:
	callq	main.cold.73
.LBB0_439:
	callq	main.cold.71
.LBB0_440:
	callq	main.cold.56
.LBB0_441:
	callq	main.cold.64
.LBB0_442:
	callq	main.cold.58
.LBB0_443:
	callq	main.cold.60
.LBB0_444:
	callq	main.cold.63
.LBB0_445:
	callq	main.cold.65
.LBB0_446:
	callq	main.cold.59
.LBB0_447:
	callq	main.cold.62
.LBB0_448:
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	main.cold.15
.LBB0_449:
	callq	main.cold.53
.LBB0_450:
	callq	main.cold.85
.LBB0_451:
	callq	main.cold.54
.LBB0_452:
	movq	%r11, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	callq	die_relocation_section
.LBB0_453:
	leaq	.L.str.15(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_454:
	leaq	.L.str.10(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_455:
	leaq	.L.str.17(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_456:
	leaq	.L.str.16(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_457:
	callq	main.cold.21
.LBB0_458:
	callq	main.cold.50
.LBB0_459:
	cmpb	$0, (%r12)
	jne	.LBB0_481
# %bb.460:
	leaq	.L.str.86(%rip), %rcx
	jmp	.LBB0_482
.LBB0_461:
	movq	%r13, %rdi
	callq	main.cold.2
.LBB0_462:
	movq	%r14, %rdi
	callq	main.cold.123
.LBB0_463:
	leaq	.L.str.11(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_464:
	callq	main.cold.122
.LBB0_465:
	leaq	.L.str.18(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_466:
	leaq	.L.str.20(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_467:
	callq	main.cold.121
.LBB0_468:
	callq	main.cold.120
.LBB0_469:
	leaq	.L.str.19(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_470:
	callq	main.cold.119
.LBB0_471:
	callq	main.cold.118
.LBB0_472:
	leaq	.L.str.21(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_473:
	callq	main.cold.117
.LBB0_474:
	leaq	.L.str.34(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_475:
	leaq	.L.str.32(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_476:
	callq	main.cold.101
.LBB0_477:
	leaq	.L.str.33(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_478:
	leaq	.L.str.31(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_479:
	callq	main.cold.19
.LBB0_480:
	callq	main.cold.20
.LBB0_481:
	leaq	.L.str.87(%rip), %rcx
.LBB0_482:
	leaq	240(%rsp), %rdi
	movq	64(%rsp), %rsi                  # 8-byte Reload
	movq	208(%rsp), %rdx                 # 8-byte Reload
	callq	die_relocation_symbol
.LBB0_483:
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	main.cold.23
.LBB0_484:
	callq	main.cold.1
.LBB0_485:
	leaq	.L.str.12(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.LBB0_486:
	callq	main.cold.49
.LBB0_487:
	callq	main.cold.48
.LBB0_488:
	callq	main.cold.47
.LBB0_489:
	callq	main.cold.46
.LBB0_490:
	callq	main.cold.45
.LBB0_491:
	callq	main.cold.44
.LBB0_492:
	callq	main.cold.43
.LBB0_493:
	callq	main.cold.42
.LBB0_494:
	callq	main.cold.41
.LBB0_495:
	callq	main.cold.40
.LBB0_496:
	callq	main.cold.39
.LBB0_497:
	callq	main.cold.38
.LBB0_498:
	callq	main.cold.37
.LBB0_499:
	callq	main.cold.36
.LBB0_500:
	callq	main.cold.24
.LBB0_501:
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	main.cold.26
.LBB0_502:
	leaq	.LJTI0_0(%rip), %rax
	movslq	(%rax,%rcx,4), %rcx
	addq	%rax, %rcx
	jmpq	*%rcx
.LBB0_503:
	callq	main.cold.32
.LBB0_504:
	callq	main.cold.18
.LBB0_505:
	callq	main.cold.16
.LBB0_506:
	callq	main.cold.17
.LBB0_507:
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	main.cold.25
.LBB0_508:
	callq	main.cold.3
.LBB0_509:
	callq	main.cold.100
.LBB0_510:
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	main.cold.97
.LBB0_511:
	callq	main.cold.125
.LBB0_512:
	callq	main.cold.124
.LBB0_513:
	callq	main.cold.99
.LBB0_514:
	callq	main.cold.98
.LBB0_515:
	callq	main.cold.95
.LBB0_516:
	callq	main.cold.94
.LBB0_517:
	callq	main.cold.93
.LBB0_518:
	callq	main.cold.92
.LBB0_519:
	callq	main.cold.91
.LBB0_520:
	callq	main.cold.90
.LBB0_521:
	callq	main.cold.31
.LBB0_522:
	callq	main.cold.30
.LBB0_523:
	callq	main.cold.29
.LBB0_524:
	callq	main.cold.89
.LBB0_525:
	callq	main.cold.88
.LBB0_526:
	callq	main.cold.87
.LBB0_527:
	callq	main.cold.33
.LBB0_528:
	callq	main.cold.34
.LBB0_529:
	callq	main.cold.35
.LBB0_530:
	movq	120(%rsp), %rdi                 # 8-byte Reload
	callq	main.cold.86
.LBB0_531:
	leaq	.L.str.117(%rip), %rsi
	movq	120(%rsp), %rdi                 # 8-byte Reload
	callq	die_path
.LBB0_532:
	callq	main.cold.27
.LBB0_533:
	callq	main.cold.28
.LBB0_534:
	callq	main.cold.96
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.section	.rodata,"a",@progbits
	.p2align	2, 0x0
.LJTI0_0:
	.long	.LBB0_503-.LJTI0_0
	.long	.LBB0_521-.LJTI0_0
	.long	.LBB0_522-.LJTI0_0
	.long	.LBB0_523-.LJTI0_0
.LJTI0_1:
	.long	.LBB0_299-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_347-.LJTI0_1
	.long	.LBB0_342-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_337-.LJTI0_1
	.long	.LBB0_330-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_331-.LJTI0_1
	.long	.LBB0_352-.LJTI0_1
	.long	.LBB0_358-.LJTI0_1
	.long	.LBB0_360-.LJTI0_1
	.long	.LBB0_359-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_275-.LJTI0_1
	.long	.LBB0_329-.LJTI0_1
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function die
	.type	die,@function
die:                                    # @die
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.7(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end1:
	.size	die, .Lfunc_end1-die
                                        # -- End function
	.p2align	4                               # -- Begin function die_path
	.type	die_path,@function
die_path:                               # @die_path
# %bb.0:
	pushq	%rax
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.13(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end2:
	.size	die_path, .Lfunc_end2-die_path
                                        # -- End function
	.text
	.p2align	4                               # -- Begin function place_matching
	.type	place_matching,@function
place_matching:                         # @place_matching
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$56, %rsp
	movq	%r9, 8(%rsp)                    # 8-byte Spill
	movq	8(%rdi), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB3_13
# %bb.1:
	movq	%r8, %r12
	movl	%ecx, %r9d
	movq	%rsi, %r10
	movq	%rdi, %r11
	movq	(%rdi), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	leaq	16(%rdi), %rax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	xorl	%r15d, %r15d
	movl	%edx, 4(%rsp)                   # 4-byte Spill
	movq	%rdi, 32(%rsp)                  # 8-byte Spill
	jmp	.LBB3_2
	.p2align	4
.LBB3_12:                               #   in Loop: Header=BB3_2 Depth=1
	incq	%r15
	cmpq	40(%rsp), %r15                  # 8-byte Folded Reload
	je	.LBB3_13
.LBB3_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_4 Depth 2
	imulq	$56, %r15, %rax
	movq	16(%rsp), %rcx                  # 8-byte Reload
	movq	32(%rcx,%rax), %r13
	cmpq	$2, %r13
	jb	.LBB3_12
# %bb.3:                                #   in Loop: Header=BB3_2 Depth=1
	addq	16(%rsp), %rax                  # 8-byte Folded Reload
	movq	24(%rax), %r14
	movl	$172, %eax
	addq	%rax, %r14
	decq	%r13
	movq	%r15, 48(%rsp)                  # 8-byte Spill
	jmp	.LBB3_4
.LBB3_30:                               #   in Loop: Header=BB3_4 Depth=2
	addq	%rcx, (%r10)
	.p2align	4
.LBB3_31:                               #   in Loop: Header=BB3_4 Depth=2
	addq	$88, %r14
	decq	%r13
	je	.LBB3_12
.LBB3_4:                                #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$0, (%r14)
	jne	.LBB3_31
# %bb.5:                                #   in Loop: Header=BB3_4 Depth=2
	cmpl	%edx, -4(%r14)
	jne	.LBB3_31
# %bb.6:                                #   in Loop: Header=BB3_4 Depth=2
	movl	-76(%r14), %ebp
	xorl	%eax, %eax
	cmpl	$8, %ebp
	sete	%al
	cmpl	%eax, %r9d
	jne	.LBB3_31
# %bb.7:                                #   in Loop: Header=BB3_4 Depth=2
	testq	%r12, %r12
	je	.LBB3_9
# %bb.8:                                #   in Loop: Header=BB3_4 Depth=2
	movq	-84(%r14), %rdi
	movq	%r12, %rsi
	movl	%r9d, %r15d
	movq	%r10, %rbx
	callq	strcmp@PLT
	movq	32(%rsp), %r11                  # 8-byte Reload
	movq	%rbx, %r10
	movl	4(%rsp), %edx                   # 4-byte Reload
	movl	%r15d, %r9d
	movq	48(%rsp), %r15                  # 8-byte Reload
	testl	%eax, %eax
	jne	.LBB3_31
.LBB3_9:                                #   in Loop: Header=BB3_4 Depth=2
	movq	-36(%r14), %rcx
	movq	(%r10), %rax
	cmpq	$2, %rcx
	movl	$1, %esi
	cmovbq	%rsi, %rcx
	jb	.LBB3_16
# %bb.10:                               #   in Loop: Header=BB3_4 Depth=2
	leaq	-1(%rcx), %rsi
	testq	%rsi, %rcx
	jne	.LBB3_11
# %bb.14:                               #   in Loop: Header=BB3_4 Depth=2
	movq	%rcx, %rsi
	negq	%rsi
	cmpq	%rsi, %rax
	ja	.LBB3_32
# %bb.15:                               #   in Loop: Header=BB3_4 Depth=2
	addq	%rcx, %rax
	decq	%rax
	andq	%rsi, %rax
.LBB3_16:                               #   in Loop: Header=BB3_4 Depth=2
	movq	%rax, (%r10)
	movq	%rax, -20(%r14)
	movq	(%r10), %rdi
	addq	112(%r11), %rdi
	movq	%rdi, -12(%r14)
	movl	$1, (%r14)
	cmpl	$8, %ebp
	jne	.LBB3_20
# %bb.17:                               #   in Loop: Header=BB3_4 Depth=2
	movq	8(%rsp), %rcx                   # 8-byte Reload
	cmpl	$0, (%rcx)
	movl	%edx, %esi
	jne	.LBB3_19
# %bb.18:                               #   in Loop: Header=BB3_4 Depth=2
	movq	%rdi, 136(%r11)
	movq	8(%rsp), %rcx                   # 8-byte Reload
	movl	$1, (%rcx)
	movl	-4(%r14), %esi
.LBB3_19:                               #   in Loop: Header=BB3_4 Depth=2
	movq	-52(%r14), %rcx
	addq	%rcx, %rdi
	movq	%rdi, 144(%r11)
	jmp	.LBB3_23
.LBB3_20:                               #   in Loop: Header=BB3_4 Depth=2
	movq	-52(%r14), %rcx
	movq	(%r10), %rsi
	addq	%rcx, %rsi
	cmpq	120(%r11), %rsi
	jbe	.LBB3_22
# %bb.21:                               #   in Loop: Header=BB3_4 Depth=2
	movq	%rsi, 120(%r11)
.LBB3_22:                               #   in Loop: Header=BB3_4 Depth=2
	movl	%edx, %esi
.LBB3_23:                               #   in Loop: Header=BB3_4 Depth=2
	movslq	%esi, %rsi
	shlq	$5, %rsi
	movq	24(%rsp), %rbx                  # 8-byte Reload
	leaq	(%rbx,%rsi), %rdi
	cmpl	$0, (%rbx,%rsi)
	jne	.LBB3_25
# %bb.24:                               #   in Loop: Header=BB3_4 Depth=2
	movl	$1, (%rdi)
	movq	%rax, 8(%rdi)
	movq	%rax, 16(%rdi)
	movq	%rax, 24(%rdi)
.LBB3_25:                               #   in Loop: Header=BB3_4 Depth=2
	addq	%rcx, %rax
	cmpl	$8, -76(%r14)
	je	.LBB3_28
# %bb.26:                               #   in Loop: Header=BB3_4 Depth=2
	cmpq	16(%rdi), %rax
	jbe	.LBB3_28
# %bb.27:                               #   in Loop: Header=BB3_4 Depth=2
	movq	%rax, 16(%rdi)
.LBB3_28:                               #   in Loop: Header=BB3_4 Depth=2
	cmpq	24(%rdi), %rax
	jbe	.LBB3_30
# %bb.29:                               #   in Loop: Header=BB3_4 Depth=2
	movq	%rax, 24(%rdi)
	jmp	.LBB3_30
.LBB3_13:
	addq	$56, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB3_32:
	callq	place_matching.cold.2
.LBB3_11:
	callq	place_matching.cold.1
.Lfunc_end3:
	.size	place_matching, .Lfunc_end3-place_matching
                                        # -- End function
	.p2align	4                               # -- Begin function mark_matching_common_symbols
	.type	mark_matching_common_symbols,@function
mark_matching_common_symbols:           # @mark_matching_common_symbols
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$56, %rsp
	movq	%r8, 40(%rsp)                   # 8-byte Spill
	movq	%rcx, 32(%rsp)                  # 8-byte Spill
	movq	%rdx, 48(%rsp)                  # 8-byte Spill
	movq	16(%rsi), %rbp
	movq	24(%rsi), %rdx
	cmpq	$1, %rbp
	adcq	$0, %rbp
	movq	8(%rdi), %r9
	testq	%r9, %r9
	je	.LBB4_27
# %bb.1:
	movq	%rsi, %r12
	movq	%rdi, 24(%rsp)                  # 8-byte Spill
	movq	(%rdi), %r10
	xorl	%r15d, %r15d
	movq	%r9, 16(%rsp)                   # 8-byte Spill
	movq	%r10, (%rsp)                    # 8-byte Spill
	jmp	.LBB4_2
	.p2align	4
.LBB4_11:                               #   in Loop: Header=BB4_2 Depth=1
	incq	%r15
	cmpq	%r9, %r15
	je	.LBB4_12
.LBB4_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_4 Depth 2
	imulq	$56, %r15, %rax
	movq	48(%r10,%rax), %r14
	testq	%r14, %r14
	je	.LBB4_11
# %bb.3:                                #   in Loop: Header=BB4_2 Depth=1
	addq	%r10, %rax
	movq	40(%rax), %r13
	movzwl	8(%r12), %ebx
	jmp	.LBB4_4
	.p2align	4
.LBB4_23:                               #   in Loop: Header=BB4_4 Depth=2
	cmpq	%r12, %r13
	je	.LBB4_24
	.p2align	4
.LBB4_25:                               #   in Loop: Header=BB4_4 Depth=2
	addq	$56, %r13
	decq	%r14
	je	.LBB4_11
.LBB4_4:                                #   Parent Loop BB4_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpw	$-14, %bx
	jne	.LBB4_25
# %bb.5:                                #   in Loop: Header=BB4_4 Depth=2
	cmpw	$-14, 8(%r13)
	jne	.LBB4_25
# %bb.6:                                #   in Loop: Header=BB4_4 Depth=2
	movq	(%r12), %rdi
	cmpb	$0, (%rdi)
	je	.LBB4_23
# %bb.7:                                #   in Loop: Header=BB4_4 Depth=2
	movq	(%r13), %rsi
	cmpb	$0, (%rsi)
	je	.LBB4_23
# %bb.8:                                #   in Loop: Header=BB4_4 Depth=2
	cmpb	$16, 32(%r12)
	jb	.LBB4_23
# %bb.9:                                #   in Loop: Header=BB4_4 Depth=2
	cmpb	$15, 32(%r13)
	jbe	.LBB4_23
# %bb.10:                               #   in Loop: Header=BB4_4 Depth=2
	movq	%rdx, 8(%rsp)                   # 8-byte Spill
	callq	strcmp@PLT
	movq	(%rsp), %r10                    # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	8(%rsp), %rdx                   # 8-byte Reload
	testl	%eax, %eax
	jne	.LBB4_25
.LBB4_24:                               #   in Loop: Header=BB4_4 Depth=2
	movq	16(%r13), %rax
	movq	24(%r13), %rcx
	cmpq	%rdx, %rcx
	cmovaq	%rcx, %rdx
	cmpq	%rbp, %rax
	cmovaq	%rax, %rbp
	jmp	.LBB4_25
.LBB4_12:
	leaq	-1(%rbp), %rax
	testq	%rax, %rbp
	jne	.LBB4_26
# %bb.13:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	(%rax), %rcx
	xorl	%r14d, %r14d
	movq	%rcx, (%rsp)                    # 8-byte Spill
	jmp	.LBB4_14
	.p2align	4
.LBB4_32:                               #   in Loop: Header=BB4_14 Depth=1
	incq	%r14
	cmpq	%r9, %r14
	je	.LBB4_28
.LBB4_14:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_16 Depth 2
	imulq	$56, %r14, %rax
	movq	48(%rcx,%rax), %r15
	testq	%r15, %r15
	je	.LBB4_32
# %bb.15:                               #   in Loop: Header=BB4_14 Depth=1
	addq	%rcx, %rax
	movq	40(%rax), %r13
	movzwl	8(%r12), %ebx
	jmp	.LBB4_16
	.p2align	4
.LBB4_29:                               #   in Loop: Header=BB4_16 Depth=2
	cmpq	%r12, %r13
	je	.LBB4_30
	.p2align	4
.LBB4_31:                               #   in Loop: Header=BB4_16 Depth=2
	addq	$56, %r13
	decq	%r15
	je	.LBB4_32
.LBB4_16:                               #   Parent Loop BB4_14 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpw	$-14, %bx
	jne	.LBB4_31
# %bb.17:                               #   in Loop: Header=BB4_16 Depth=2
	cmpw	$-14, 8(%r13)
	jne	.LBB4_31
# %bb.18:                               #   in Loop: Header=BB4_16 Depth=2
	movq	(%r12), %rdi
	cmpb	$0, (%rdi)
	je	.LBB4_29
# %bb.19:                               #   in Loop: Header=BB4_16 Depth=2
	movq	(%r13), %rsi
	cmpb	$0, (%rsi)
	je	.LBB4_29
# %bb.20:                               #   in Loop: Header=BB4_16 Depth=2
	cmpb	$16, 32(%r12)
	jb	.LBB4_29
# %bb.21:                               #   in Loop: Header=BB4_16 Depth=2
	cmpb	$15, 32(%r13)
	jbe	.LBB4_29
# %bb.22:                               #   in Loop: Header=BB4_16 Depth=2
	movq	%rdx, 8(%rsp)                   # 8-byte Spill
	callq	strcmp@PLT
	movq	(%rsp), %rcx                    # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	8(%rsp), %rdx                   # 8-byte Reload
	testl	%eax, %eax
	jne	.LBB4_31
.LBB4_30:                               #   in Loop: Header=BB4_16 Depth=2
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 40(%r13)
	movl	$1, 48(%r13)
	jmp	.LBB4_31
.LBB4_27:
	leaq	-1(%rbp), %rax
	testq	%rax, %rbp
	jne	.LBB4_26
.LBB4_28:
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rdx, (%rax)
	movq	40(%rsp), %rax                  # 8-byte Reload
	movq	%rbp, (%rax)
	addq	$56, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB4_26:
	callq	mark_matching_common_symbols.cold.1
.Lfunc_end4:
	.size	mark_matching_common_symbols, .Lfunc_end4-mark_matching_common_symbols
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function die_relocation_section
	.type	die_relocation_section,@function
die_relocation_section:                 # @die_relocation_section
# %bb.0:
	pushq	%rax
	movq	(%rsi), %rax
	cmpb	$0, (%rax)
	movq	stderr@GOTPCREL(%rip), %rsi
	leaq	.L.str.67(%rip), %rcx
	cmovneq	%rax, %rcx
	movq	(%rsi), %rax
	movq	(%rdx), %rsi
	cmpb	$0, (%rsi)
	movq	(%rdi), %rdx
	leaq	.L.str.68(%rip), %r8
	cmovneq	%rsi, %r8
	leaq	.L.str.66(%rip), %rsi
	leaq	.L.str.59(%rip), %r9
	movq	%rax, %rdi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end5:
	.size	die_relocation_section, .Lfunc_end5-die_relocation_section
                                        # -- End function
	.p2align	4                               # -- Begin function die_relocation
	.type	die_relocation,@function
die_relocation:                         # @die_relocation
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
	movq	%rsi, 16(%rsp)                  # 8-byte Spill
	movq	%rdi, %rbx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	8(%rdi), %rcx
	movq	(%rcx), %rcx
	cmpb	$0, (%rcx)
	movq	(%rax), %rax
	movq	%rax, (%rsp)                    # 8-byte Spill
	leaq	.L.str.67(%rip), %r12
	cmovneq	%rcx, %r12
	movq	16(%rdi), %rax
	movq	(%rax), %rax
	cmpb	$0, (%rax)
	movq	(%rdi), %rcx
	leaq	.L.str.68(%rip), %r13
	cmovneq	%rax, %r13
	movq	(%rcx), %rbp
	movq	24(%rdi), %r14
	movq	32(%rdi), %rax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movl	40(%rdi), %r15d
	movl	%r15d, %edi
	callq	relocation_name
	movq	%rax, %r10
	subq	$8, %rsp
	leaq	.L.str.69(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movq	%rbp, %rdx
	movq	%r12, %rcx
	movq	%r13, %r8
	movq	%r14, %r9
	xorl	%eax, %eax
	pushq	24(%rsp)                        # 8-byte Folded Reload
	pushq	48(%rbx)
	pushq	%r15
	pushq	%r10
	pushq	48(%rsp)                        # 8-byte Folded Reload
	callq	fprintf@PLT
	addq	$48, %rsp
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end6:
	.size	die_relocation, .Lfunc_end6-die_relocation
                                        # -- End function
	.text
	.p2align	4                               # -- Begin function relocation_name
	.type	relocation_name,@function
relocation_name:                        # @relocation_name
# %bb.0:
                                        # kill: def $edi killed $edi def $rdi
	leal	-257(%rdi), %eax
	cmpl	$42, %eax
	ja	.LBB7_1
# %bb.3:
	leaq	.LJTI7_0(%rip), %rcx
	movslq	(%rcx,%rax,4), %rax
	addq	%rcx, %rax
	jmpq	*%rax
.LBB7_4:
	leaq	.L.str.71(%rip), %rax
	retq
.LBB7_1:
	testl	%edi, %edi
	jne	.LBB7_15
# %bb.2:
	leaq	.L.str.70(%rip), %rax
	retq
.LBB7_15:
	leaq	.L.str.82(%rip), %rax
	retq
.LBB7_10:
	leaq	.L.str.77(%rip), %rax
	retq
.LBB7_9:
	leaq	.L.str.76(%rip), %rax
	retq
.LBB7_7:
	leaq	.L.str.74(%rip), %rax
	retq
.LBB7_6:
	leaq	.L.str.73(%rip), %rax
	retq
.LBB7_11:
	leaq	.L.str.78(%rip), %rax
	retq
.LBB7_8:
	leaq	.L.str.75(%rip), %rax
	retq
.LBB7_14:
	leaq	.L.str.81(%rip), %rax
	retq
.LBB7_5:
	leaq	.L.str.72(%rip), %rax
	retq
.LBB7_13:
	leaq	.L.str.80(%rip), %rax
	retq
.LBB7_12:
	leaq	.L.str.79(%rip), %rax
	retq
.Lfunc_end7:
	.size	relocation_name, .Lfunc_end7-relocation_name
	.section	.rodata,"a",@progbits
	.p2align	2, 0x0
.LJTI7_0:
	.long	.LBB7_4-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_5-.LJTI7_0
	.long	.LBB7_6-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_7-.LJTI7_0
	.long	.LBB7_8-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_9-.LJTI7_0
	.long	.LBB7_10-.LJTI7_0
	.long	.LBB7_11-.LJTI7_0
	.long	.LBB7_12-.LJTI7_0
	.long	.LBB7_13-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_15-.LJTI7_0
	.long	.LBB7_14-.LJTI7_0
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function die_relocation_symbol
	.type	die_relocation_symbol,@function
die_relocation_symbol:                  # @die_relocation_symbol
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$56, %rsp
	movq	%rcx, 48(%rsp)                  # 8-byte Spill
	movq	%rdx, 32(%rsp)                  # 8-byte Spill
	movq	%rsi, 24(%rsp)                  # 8-byte Spill
	movq	%rdi, %rbx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	8(%rdi), %rcx
	movq	(%rcx), %rcx
	cmpb	$0, (%rcx)
	movq	(%rax), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	leaq	.L.str.67(%rip), %r15
	cmovneq	%rcx, %r15
	movq	16(%rdi), %rax
	movq	(%rax), %rax
	cmpb	$0, (%rax)
	movq	(%rdi), %rcx
	leaq	.L.str.68(%rip), %r14
	cmovneq	%rax, %r14
	movq	(%rcx), %r12
	movq	24(%rdi), %r13
	movq	32(%rdi), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	movl	40(%rdi), %ebp
	movl	%ebp, %edi
	callq	relocation_name
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movq	48(%rbx), %rbx
	movq	24(%rsp), %rdi                  # 8-byte Reload
	movq	32(%rsp), %rsi                  # 8-byte Reload
	callq	relocation_symbol_name
	movq	%rax, %r10
	leaq	.L.str.88(%rip), %rsi
	movq	16(%rsp), %rdi                  # 8-byte Reload
	movq	%r12, %rdx
	movq	%r15, %rcx
	movq	%r14, %r8
	movq	%r13, %r9
	xorl	%eax, %eax
	pushq	48(%rsp)                        # 8-byte Folded Reload
	pushq	%r10
	pushq	%rbx
	pushq	%rbp
	pushq	40(%rsp)                        # 8-byte Folded Reload
	pushq	80(%rsp)                        # 8-byte Folded Reload
	callq	fprintf@PLT
	addq	$48, %rsp
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end8:
	.size	die_relocation_symbol, .Lfunc_end8-die_relocation_symbol
                                        # -- End function
	.text
	.p2align	4                               # -- Begin function defined_symbol_value_for_relocation
	.type	defined_symbol_value_for_relocation,@function
defined_symbol_value_for_relocation:    # @defined_symbol_value_for_relocation
# %bb.0:
	pushq	%rax
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
	je	.LBB9_1
# %bb.3:
	testb	$12, %cl
	jne	.LBB9_4
# %bb.5:
	movzwl	8(%rax), %ecx
	cmpl	$65522, %ecx                    # imm = 0xFFF2
	je	.LBB9_8
# %bb.6:
	cmpl	$65521, %ecx                    # imm = 0xFFF1
	jne	.LBB9_11
# %bb.7:
	movq	16(%rax), %rax
	popq	%rcx
	retq
.LBB9_8:
	cmpl	$0, 48(%rax)
	je	.LBB9_9
# %bb.10:
	movq	40(%rax), %rax
	popq	%rcx
	retq
.LBB9_11:
	cmpq	%rcx, 32(%rsi)
	jbe	.LBB9_12
# %bb.13:
	movq	24(%rsi), %rdi
	imulq	$88, %rcx, %rcx
	cmpl	$0, 84(%rdi,%rcx)
	je	.LBB9_14
# %bb.15:
	addq	%rcx, %rdi
	movq	16(%rax), %rax
	addq	72(%rdi), %rax
	popq	%rcx
	retq
.LBB9_1:
	leaq	.L.str.96(%rip), %rcx
	jmp	.LBB9_2
.LBB9_4:
	leaq	.L.str.97(%rip), %rcx
	jmp	.LBB9_2
.LBB9_9:
	leaq	.L.str.43(%rip), %rcx
	jmp	.LBB9_2
.LBB9_12:
	leaq	.L.str.98(%rip), %rcx
	jmp	.LBB9_2
.LBB9_14:
	leaq	.L.str.45(%rip), %rcx
.LBB9_2:
	movq	%rdx, %rdi
	movq	%rax, %rdx
	callq	die_relocation_symbol
.Lfunc_end9:
	.size	defined_symbol_value_for_relocation, .Lfunc_end9-defined_symbol_value_for_relocation
                                        # -- End function
	.p2align	4                               # -- Begin function relocation_symbol_name
	.type	relocation_symbol_name,@function
relocation_symbol_name:                 # @relocation_symbol_name
# %bb.0:
	movq	(%rsi), %rax
	cmpb	$0, (%rax)
	je	.LBB10_1
.LBB10_4:
	retq
.LBB10_1:
	movzbl	32(%rsi), %ecx
	andb	$15, %cl
	leaq	.L.str.89(%rip), %rax
	cmpb	$3, %cl
	jne	.LBB10_4
# %bb.2:
	movzwl	8(%rsi), %ecx
	cmpq	%rcx, 32(%rdi)
	jbe	.LBB10_4
# %bb.3:
	movq	24(%rdi), %rax
	imulq	$88, %rcx, %rcx
	movq	(%rax,%rcx), %rax
	retq
.Lfunc_end10:
	.size	relocation_symbol_name, .Lfunc_end10-relocation_symbol_name
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function main.cold.1
	.type	main.cold.1,@function
main.cold.1:                            # @main.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.3(%rip), %rdi
	callq	die
.Lfunc_end11:
	.size	main.cold.1, .Lfunc_end11-main.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.2
	.type	main.cold.2,@function
main.cold.2:                            # @main.cold.2
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.8(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end12:
	.size	main.cold.2, .Lfunc_end12-main.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.3
	.type	main.cold.3,@function
main.cold.3:                            # @main.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.1(%rip), %rdi
	callq	die
.Lfunc_end13:
	.size	main.cold.3, .Lfunc_end13-main.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.4
	.type	main.cold.4,@function
main.cold.4:                            # @main.cold.4
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	leaq	.L.str.5(%rip), %rdi
	pushq	$77
	popq	%rsi
	pushq	$1
	popq	%rdx
	callq	fwrite@PLT
	movq	%rbx, %rdi
	popq	%rbx
	jmp	free@PLT                        # TAILCALL
.Lfunc_end14:
	.size	main.cold.4, .Lfunc_end14-main.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.5
	.type	main.cold.5,@function
main.cold.5:                            # @main.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.24(%rip), %rdi
	callq	die
.Lfunc_end15:
	.size	main.cold.5, .Lfunc_end15-main.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.6
	.type	main.cold.6,@function
main.cold.6:                            # @main.cold.6
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end16:
	.size	main.cold.6, .Lfunc_end16-main.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.7
	.type	main.cold.7,@function
main.cold.7:                            # @main.cold.7
# %bb.0:
	pushq	%rax
	leaq	.L.str.24(%rip), %rdi
	callq	die
.Lfunc_end17:
	.size	main.cold.7, .Lfunc_end17-main.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.8
	.type	main.cold.8,@function
main.cold.8:                            # @main.cold.8
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end18:
	.size	main.cold.8, .Lfunc_end18-main.cold.8
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.9
	.type	main.cold.9,@function
main.cold.9:                            # @main.cold.9
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end19:
	.size	main.cold.9, .Lfunc_end19-main.cold.9
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.10
	.type	main.cold.10,@function
main.cold.10:                           # @main.cold.10
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end20:
	.size	main.cold.10, .Lfunc_end20-main.cold.10
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.11
	.type	main.cold.11,@function
main.cold.11:                           # @main.cold.11
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end21:
	.size	main.cold.11, .Lfunc_end21-main.cold.11
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.12
	.type	main.cold.12,@function
main.cold.12:                           # @main.cold.12
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end22:
	.size	main.cold.12, .Lfunc_end22-main.cold.12
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.13
	.type	main.cold.13,@function
main.cold.13:                           # @main.cold.13
# %bb.0:
	pushq	%rax
	leaq	.L.str.25(%rip), %rdi
	callq	die
.Lfunc_end23:
	.size	main.cold.13, .Lfunc_end23-main.cold.13
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.14
	.type	main.cold.14,@function
main.cold.14:                           # @main.cold.14
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end24:
	.size	main.cold.14, .Lfunc_end24-main.cold.14
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.15
	.type	main.cold.15,@function
main.cold.15:                           # @main.cold.15
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.42(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end25:
	.size	main.cold.15, .Lfunc_end25-main.cold.15
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.16
	.type	main.cold.16,@function
main.cold.16:                           # @main.cold.16
# %bb.0:
	pushq	%rax
	leaq	.L.str.43(%rip), %rdi
	callq	die
.Lfunc_end26:
	.size	main.cold.16, .Lfunc_end26-main.cold.16
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.17
	.type	main.cold.17,@function
main.cold.17:                           # @main.cold.17
# %bb.0:
	pushq	%rax
	leaq	.L.str.44(%rip), %rdi
	callq	die
.Lfunc_end27:
	.size	main.cold.17, .Lfunc_end27-main.cold.17
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.18
	.type	main.cold.18,@function
main.cold.18:                           # @main.cold.18
# %bb.0:
	pushq	%rax
	leaq	.L.str.45(%rip), %rdi
	callq	die
.Lfunc_end28:
	.size	main.cold.18, .Lfunc_end28-main.cold.18
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.19
	.type	main.cold.19,@function
main.cold.19:                           # @main.cold.19
# %bb.0:
	pushq	%rax
	leaq	.L.str.39(%rip), %rdi
	callq	die
.Lfunc_end29:
	.size	main.cold.19, .Lfunc_end29-main.cold.19
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.20
	.type	main.cold.20,@function
main.cold.20:                           # @main.cold.20
# %bb.0:
	pushq	%rax
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end30:
	.size	main.cold.20, .Lfunc_end30-main.cold.20
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.21
	.type	main.cold.21,@function
main.cold.21:                           # @main.cold.21
# %bb.0:
	pushq	%rax
	leaq	.L.str.41(%rip), %rdi
	callq	die
.Lfunc_end31:
	.size	main.cold.21, .Lfunc_end31-main.cold.21
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.22
	.type	main.cold.22,@function
main.cold.22:                           # @main.cold.22
# %bb.0:
	pushq	%rax
	movq	(%rdi), %rdi
	leaq	.L.str.55(%rip), %rsi
	callq	die_path
.Lfunc_end32:
	.size	main.cold.22, .Lfunc_end32-main.cold.22
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.23
	.type	main.cold.23,@function
main.cold.23:                           # @main.cold.23
# %bb.0:
	pushq	%rax
	movq	(%rdi), %rdi
	leaq	.L.str.54(%rip), %rsi
	callq	die_path
.Lfunc_end33:
	.size	main.cold.23, .Lfunc_end33-main.cold.23
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.24
	.type	main.cold.24,@function
main.cold.24:                           # @main.cold.24
# %bb.0:
	pushq	%rax
	movq	(%rdi), %rdi
	leaq	.L.str.54(%rip), %rsi
	callq	die_path
.Lfunc_end34:
	.size	main.cold.24, .Lfunc_end34-main.cold.24
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.25
	.type	main.cold.25,@function
main.cold.25:                           # @main.cold.25
# %bb.0:
	pushq	%rax
	movq	(%rdi), %rdi
	leaq	.L.str.53(%rip), %rsi
	callq	die_path
.Lfunc_end35:
	.size	main.cold.25, .Lfunc_end35-main.cold.25
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.26
	.type	main.cold.26,@function
main.cold.26:                           # @main.cold.26
# %bb.0:
	pushq	%rax
	movq	(%rdi), %rdi
	leaq	.L.str.52(%rip), %rsi
	callq	die_path
.Lfunc_end36:
	.size	main.cold.26, .Lfunc_end36-main.cold.26
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.27
	.type	main.cold.27,@function
main.cold.27:                           # @main.cold.27
# %bb.0:
	pushq	%rax
	leaq	.L.str.43(%rip), %rdi
	callq	die
.Lfunc_end37:
	.size	main.cold.27, .Lfunc_end37-main.cold.27
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.28
	.type	main.cold.28,@function
main.cold.28:                           # @main.cold.28
# %bb.0:
	pushq	%rax
	leaq	.L.str.44(%rip), %rdi
	callq	die
.Lfunc_end38:
	.size	main.cold.28, .Lfunc_end38-main.cold.28
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.29
	.type	main.cold.29,@function
main.cold.29:                           # @main.cold.29
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end39:
	.size	main.cold.29, .Lfunc_end39-main.cold.29
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.30
	.type	main.cold.30,@function
main.cold.30:                           # @main.cold.30
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end40:
	.size	main.cold.30, .Lfunc_end40-main.cold.30
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.31
	.type	main.cold.31,@function
main.cold.31:                           # @main.cold.31
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end41:
	.size	main.cold.31, .Lfunc_end41-main.cold.31
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.32
	.type	main.cold.32,@function
main.cold.32:                           # @main.cold.32
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end42:
	.size	main.cold.32, .Lfunc_end42-main.cold.32
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.33
	.type	main.cold.33,@function
main.cold.33:                           # @main.cold.33
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end43:
	.size	main.cold.33, .Lfunc_end43-main.cold.33
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.34
	.type	main.cold.34,@function
main.cold.34:                           # @main.cold.34
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end44:
	.size	main.cold.34, .Lfunc_end44-main.cold.34
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.35
	.type	main.cold.35,@function
main.cold.35:                           # @main.cold.35
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end45:
	.size	main.cold.35, .Lfunc_end45-main.cold.35
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.36
	.type	main.cold.36,@function
main.cold.36:                           # @main.cold.36
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end46:
	.size	main.cold.36, .Lfunc_end46-main.cold.36
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.37
	.type	main.cold.37,@function
main.cold.37:                           # @main.cold.37
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end47:
	.size	main.cold.37, .Lfunc_end47-main.cold.37
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.38
	.type	main.cold.38,@function
main.cold.38:                           # @main.cold.38
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end48:
	.size	main.cold.38, .Lfunc_end48-main.cold.38
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.39
	.type	main.cold.39,@function
main.cold.39:                           # @main.cold.39
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end49:
	.size	main.cold.39, .Lfunc_end49-main.cold.39
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.40
	.type	main.cold.40,@function
main.cold.40:                           # @main.cold.40
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end50:
	.size	main.cold.40, .Lfunc_end50-main.cold.40
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.41
	.type	main.cold.41,@function
main.cold.41:                           # @main.cold.41
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end51:
	.size	main.cold.41, .Lfunc_end51-main.cold.41
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.42
	.type	main.cold.42,@function
main.cold.42:                           # @main.cold.42
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end52:
	.size	main.cold.42, .Lfunc_end52-main.cold.42
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.43
	.type	main.cold.43,@function
main.cold.43:                           # @main.cold.43
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end53:
	.size	main.cold.43, .Lfunc_end53-main.cold.43
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.44
	.type	main.cold.44,@function
main.cold.44:                           # @main.cold.44
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end54:
	.size	main.cold.44, .Lfunc_end54-main.cold.44
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.45
	.type	main.cold.45,@function
main.cold.45:                           # @main.cold.45
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end55:
	.size	main.cold.45, .Lfunc_end55-main.cold.45
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.46
	.type	main.cold.46,@function
main.cold.46:                           # @main.cold.46
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end56:
	.size	main.cold.46, .Lfunc_end56-main.cold.46
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.47
	.type	main.cold.47,@function
main.cold.47:                           # @main.cold.47
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end57:
	.size	main.cold.47, .Lfunc_end57-main.cold.47
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.48
	.type	main.cold.48,@function
main.cold.48:                           # @main.cold.48
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end58:
	.size	main.cold.48, .Lfunc_end58-main.cold.48
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.49
	.type	main.cold.49,@function
main.cold.49:                           # @main.cold.49
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end59:
	.size	main.cold.49, .Lfunc_end59-main.cold.49
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.50
	.type	main.cold.50,@function
main.cold.50:                           # @main.cold.50
# %bb.0:
	pushq	%rax
	leaq	.L.str.48(%rip), %rdi
	callq	die
.Lfunc_end60:
	.size	main.cold.50, .Lfunc_end60-main.cold.50
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.51
	.type	main.cold.51,@function
main.cold.51:                           # @main.cold.51
# %bb.0:
	pushq	%rax
	leaq	.L.str.57(%rip), %rdi
	callq	die
.Lfunc_end61:
	.size	main.cold.51, .Lfunc_end61-main.cold.51
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.52
	.type	main.cold.52,@function
main.cold.52:                           # @main.cold.52
# %bb.0:
	pushq	%rax
	leaq	.L.str.58(%rip), %rdi
	callq	die
.Lfunc_end62:
	.size	main.cold.52, .Lfunc_end62-main.cold.52
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.53
	.type	main.cold.53,@function
main.cold.53:                           # @main.cold.53
# %bb.0:
	pushq	%rax
	leaq	.L.str.61(%rip), %rdi
	callq	die
.Lfunc_end63:
	.size	main.cold.53, .Lfunc_end63-main.cold.53
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.54
	.type	main.cold.54,@function
main.cold.54:                           # @main.cold.54
# %bb.0:
	pushq	%rax
	leaq	.L.str.62(%rip), %rdi
	callq	die
.Lfunc_end64:
	.size	main.cold.54, .Lfunc_end64-main.cold.54
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.55
	.type	main.cold.55,@function
main.cold.55:                           # @main.cold.55
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.42(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end65:
	.size	main.cold.55, .Lfunc_end65-main.cold.55
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.56
	.type	main.cold.56,@function
main.cold.56:                           # @main.cold.56
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end66:
	.size	main.cold.56, .Lfunc_end66-main.cold.56
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.57
	.type	main.cold.57,@function
main.cold.57:                           # @main.cold.57
# %bb.0:
	pushq	%rax
	leaq	.L.str.65(%rip), %rdi
	callq	die
.Lfunc_end67:
	.size	main.cold.57, .Lfunc_end67-main.cold.57
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.58
	.type	main.cold.58,@function
main.cold.58:                           # @main.cold.58
# %bb.0:
	pushq	%rax
	leaq	.L.str.113(%rip), %rdi
	callq	die
.Lfunc_end68:
	.size	main.cold.58, .Lfunc_end68-main.cold.58
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.59
	.type	main.cold.59,@function
main.cold.59:                           # @main.cold.59
# %bb.0:
	pushq	%rax
	leaq	.L.str.115(%rip), %rdi
	callq	die
.Lfunc_end69:
	.size	main.cold.59, .Lfunc_end69-main.cold.59
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.60
	.type	main.cold.60,@function
main.cold.60:                           # @main.cold.60
# %bb.0:
	pushq	%rax
	leaq	.L.str.114(%rip), %rdi
	callq	die
.Lfunc_end70:
	.size	main.cold.60, .Lfunc_end70-main.cold.60
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.61
	.type	main.cold.61,@function
main.cold.61:                           # @main.cold.61
# %bb.0:
	pushq	%rax
	leaq	.L.str.112(%rip), %rdi
	callq	die
.Lfunc_end71:
	.size	main.cold.61, .Lfunc_end71-main.cold.61
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.62
	.type	main.cold.62,@function
main.cold.62:                           # @main.cold.62
# %bb.0:
	pushq	%rax
	leaq	.L.str.113(%rip), %rdi
	callq	die
.Lfunc_end72:
	.size	main.cold.62, .Lfunc_end72-main.cold.62
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.63
	.type	main.cold.63,@function
main.cold.63:                           # @main.cold.63
# %bb.0:
	pushq	%rax
	leaq	.L.str.115(%rip), %rdi
	callq	die
.Lfunc_end73:
	.size	main.cold.63, .Lfunc_end73-main.cold.63
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.64
	.type	main.cold.64,@function
main.cold.64:                           # @main.cold.64
# %bb.0:
	pushq	%rax
	leaq	.L.str.114(%rip), %rdi
	callq	die
.Lfunc_end74:
	.size	main.cold.64, .Lfunc_end74-main.cold.64
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.65
	.type	main.cold.65,@function
main.cold.65:                           # @main.cold.65
# %bb.0:
	pushq	%rax
	leaq	.L.str.112(%rip), %rdi
	callq	die
.Lfunc_end75:
	.size	main.cold.65, .Lfunc_end75-main.cold.65
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.66
	.type	main.cold.66,@function
main.cold.66:                           # @main.cold.66
# %bb.0:
	pushq	%rax
	leaq	.L.str.106(%rip), %rdi
	callq	die
.Lfunc_end76:
	.size	main.cold.66, .Lfunc_end76-main.cold.66
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.67
	.type	main.cold.67,@function
main.cold.67:                           # @main.cold.67
# %bb.0:
	pushq	%rax
	leaq	.L.str.107(%rip), %rdi
	callq	die
.Lfunc_end77:
	.size	main.cold.67, .Lfunc_end77-main.cold.67
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.68
	.type	main.cold.68,@function
main.cold.68:                           # @main.cold.68
# %bb.0:
	pushq	%rax
	leaq	.L.str.105(%rip), %rdi
	callq	die
.Lfunc_end78:
	.size	main.cold.68, .Lfunc_end78-main.cold.68
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.69
	.type	main.cold.69,@function
main.cold.69:                           # @main.cold.69
# %bb.0:
	pushq	%rax
	leaq	.L.str.104(%rip), %rdi
	callq	die
.Lfunc_end79:
	.size	main.cold.69, .Lfunc_end79-main.cold.69
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.70
	.type	main.cold.70,@function
main.cold.70:                           # @main.cold.70
# %bb.0:
	pushq	%rax
	leaq	.L.str.103(%rip), %rdi
	callq	die
.Lfunc_end80:
	.size	main.cold.70, .Lfunc_end80-main.cold.70
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.71
	.type	main.cold.71,@function
main.cold.71:                           # @main.cold.71
# %bb.0:
	pushq	%rax
	leaq	.L.str.102(%rip), %rdi
	callq	die
.Lfunc_end81:
	.size	main.cold.71, .Lfunc_end81-main.cold.71
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.72
	.type	main.cold.72,@function
main.cold.72:                           # @main.cold.72
# %bb.0:
	pushq	%rax
	leaq	.L.str.101(%rip), %rdi
	callq	die
.Lfunc_end82:
	.size	main.cold.72, .Lfunc_end82-main.cold.72
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.73
	.type	main.cold.73,@function
main.cold.73:                           # @main.cold.73
# %bb.0:
	pushq	%rax
	leaq	.L.str.100(%rip), %rdi
	callq	die
.Lfunc_end83:
	.size	main.cold.73, .Lfunc_end83-main.cold.73
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.74
	.type	main.cold.74,@function
main.cold.74:                           # @main.cold.74
# %bb.0:
	pushq	%rax
	leaq	.L.str.99(%rip), %rdi
	callq	die
.Lfunc_end84:
	.size	main.cold.74, .Lfunc_end84-main.cold.74
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.75
	.type	main.cold.75,@function
main.cold.75:                           # @main.cold.75
# %bb.0:
	pushq	%rax
	leaq	.L.str.109(%rip), %rdi
	callq	die
.Lfunc_end85:
	.size	main.cold.75, .Lfunc_end85-main.cold.75
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.76
	.type	main.cold.76,@function
main.cold.76:                           # @main.cold.76
# %bb.0:
	pushq	%rax
	leaq	.L.str.110(%rip), %rdi
	callq	die
.Lfunc_end86:
	.size	main.cold.76, .Lfunc_end86-main.cold.76
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.77
	.type	main.cold.77,@function
main.cold.77:                           # @main.cold.77
# %bb.0:
	pushq	%rax
	leaq	.L.str.111(%rip), %rdi
	callq	die
.Lfunc_end87:
	.size	main.cold.77, .Lfunc_end87-main.cold.77
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.78
	.type	main.cold.78,@function
main.cold.78:                           # @main.cold.78
# %bb.0:
	pushq	%rax
	leaq	.L.str.108(%rip), %rdi
	callq	die
.Lfunc_end88:
	.size	main.cold.78, .Lfunc_end88-main.cold.78
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.79
	.type	main.cold.79,@function
main.cold.79:                           # @main.cold.79
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end89:
	.size	main.cold.79, .Lfunc_end89-main.cold.79
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.80
	.type	main.cold.80,@function
main.cold.80:                           # @main.cold.80
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end90:
	.size	main.cold.80, .Lfunc_end90-main.cold.80
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.81
	.type	main.cold.81,@function
main.cold.81:                           # @main.cold.81
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end91:
	.size	main.cold.81, .Lfunc_end91-main.cold.81
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.82
	.type	main.cold.82,@function
main.cold.82:                           # @main.cold.82
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end92:
	.size	main.cold.82, .Lfunc_end92-main.cold.82
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.83
	.type	main.cold.83,@function
main.cold.83:                           # @main.cold.83
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end93:
	.size	main.cold.83, .Lfunc_end93-main.cold.83
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.84
	.type	main.cold.84,@function
main.cold.84:                           # @main.cold.84
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end94:
	.size	main.cold.84, .Lfunc_end94-main.cold.84
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.85
	.type	main.cold.85,@function
main.cold.85:                           # @main.cold.85
# %bb.0:
	pushq	%rax
	leaq	.L.str.60(%rip), %rdi
	callq	die
.Lfunc_end95:
	.size	main.cold.85, .Lfunc_end95-main.cold.85
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.86
	.type	main.cold.86,@function
main.cold.86:                           # @main.cold.86
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end96:
	.size	main.cold.86, .Lfunc_end96-main.cold.86
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.87
	.type	main.cold.87,@function
main.cold.87:                           # @main.cold.87
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end97:
	.size	main.cold.87, .Lfunc_end97-main.cold.87
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.88
	.type	main.cold.88,@function
main.cold.88:                           # @main.cold.88
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end98:
	.size	main.cold.88, .Lfunc_end98-main.cold.88
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.89
	.type	main.cold.89,@function
main.cold.89:                           # @main.cold.89
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end99:
	.size	main.cold.89, .Lfunc_end99-main.cold.89
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.90
	.type	main.cold.90,@function
main.cold.90:                           # @main.cold.90
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end100:
	.size	main.cold.90, .Lfunc_end100-main.cold.90
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.91
	.type	main.cold.91,@function
main.cold.91:                           # @main.cold.91
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end101:
	.size	main.cold.91, .Lfunc_end101-main.cold.91
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.92
	.type	main.cold.92,@function
main.cold.92:                           # @main.cold.92
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end102:
	.size	main.cold.92, .Lfunc_end102-main.cold.92
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.93
	.type	main.cold.93,@function
main.cold.93:                           # @main.cold.93
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end103:
	.size	main.cold.93, .Lfunc_end103-main.cold.93
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.94
	.type	main.cold.94,@function
main.cold.94:                           # @main.cold.94
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end104:
	.size	main.cold.94, .Lfunc_end104-main.cold.94
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.95
	.type	main.cold.95,@function
main.cold.95:                           # @main.cold.95
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end105:
	.size	main.cold.95, .Lfunc_end105-main.cold.95
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.96
	.type	main.cold.96,@function
main.cold.96:                           # @main.cold.96
# %bb.0:
	pushq	%rax
	leaq	.L.str.45(%rip), %rdi
	callq	die
.Lfunc_end106:
	.size	main.cold.96, .Lfunc_end106-main.cold.96
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.97
	.type	main.cold.97,@function
main.cold.97:                           # @main.cold.97
# %bb.0:
	pushq	%rax
	movq	(%rdi), %rdi
	leaq	.L.str.56(%rip), %rsi
	callq	die_path
.Lfunc_end107:
	.size	main.cold.97, .Lfunc_end107-main.cold.97
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.98
	.type	main.cold.98,@function
main.cold.98:                           # @main.cold.98
# %bb.0:
	pushq	%rax
	leaq	.L.str.6(%rip), %rdi
	callq	die
.Lfunc_end108:
	.size	main.cold.98, .Lfunc_end108-main.cold.98
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.99
	.type	main.cold.99,@function
main.cold.99:                           # @main.cold.99
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end109:
	.size	main.cold.99, .Lfunc_end109-main.cold.99
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.100
	.type	main.cold.100,@function
main.cold.100:                          # @main.cold.100
# %bb.0:
	pushq	%rax
	leaq	.L.str.38(%rip), %rdi
	callq	die
.Lfunc_end110:
	.size	main.cold.100, .Lfunc_end110-main.cold.100
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.101
	.type	main.cold.101,@function
main.cold.101:                          # @main.cold.101
# %bb.0:
	pushq	%rax
	leaq	.L.str.6(%rip), %rdi
	callq	die
.Lfunc_end111:
	.size	main.cold.101, .Lfunc_end111-main.cold.101
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.102
	.type	main.cold.102,@function
main.cold.102:                          # @main.cold.102
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end112:
	.size	main.cold.102, .Lfunc_end112-main.cold.102
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.103
	.type	main.cold.103,@function
main.cold.103:                          # @main.cold.103
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end113:
	.size	main.cold.103, .Lfunc_end113-main.cold.103
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.104
	.type	main.cold.104,@function
main.cold.104:                          # @main.cold.104
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end114:
	.size	main.cold.104, .Lfunc_end114-main.cold.104
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.105
	.type	main.cold.105,@function
main.cold.105:                          # @main.cold.105
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end115:
	.size	main.cold.105, .Lfunc_end115-main.cold.105
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.106
	.type	main.cold.106,@function
main.cold.106:                          # @main.cold.106
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end116:
	.size	main.cold.106, .Lfunc_end116-main.cold.106
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.107
	.type	main.cold.107,@function
main.cold.107:                          # @main.cold.107
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end117:
	.size	main.cold.107, .Lfunc_end117-main.cold.107
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.108
	.type	main.cold.108,@function
main.cold.108:                          # @main.cold.108
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end118:
	.size	main.cold.108, .Lfunc_end118-main.cold.108
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.109
	.type	main.cold.109,@function
main.cold.109:                          # @main.cold.109
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end119:
	.size	main.cold.109, .Lfunc_end119-main.cold.109
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.110
	.type	main.cold.110,@function
main.cold.110:                          # @main.cold.110
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end120:
	.size	main.cold.110, .Lfunc_end120-main.cold.110
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.111
	.type	main.cold.111,@function
main.cold.111:                          # @main.cold.111
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end121:
	.size	main.cold.111, .Lfunc_end121-main.cold.111
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.112
	.type	main.cold.112,@function
main.cold.112:                          # @main.cold.112
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end122:
	.size	main.cold.112, .Lfunc_end122-main.cold.112
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.113
	.type	main.cold.113,@function
main.cold.113:                          # @main.cold.113
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end123:
	.size	main.cold.113, .Lfunc_end123-main.cold.113
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.114
	.type	main.cold.114,@function
main.cold.114:                          # @main.cold.114
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end124:
	.size	main.cold.114, .Lfunc_end124-main.cold.114
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.115
	.type	main.cold.115,@function
main.cold.115:                          # @main.cold.115
# %bb.0:
	pushq	%rax
	leaq	.L.str.25(%rip), %rdi
	callq	die
.Lfunc_end125:
	.size	main.cold.115, .Lfunc_end125-main.cold.115
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.116
	.type	main.cold.116,@function
main.cold.116:                          # @main.cold.116
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end126:
	.size	main.cold.116, .Lfunc_end126-main.cold.116
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.117
	.type	main.cold.117,@function
main.cold.117:                          # @main.cold.117
# %bb.0:
	pushq	%rax
	leaq	.L.str.6(%rip), %rdi
	callq	die
.Lfunc_end127:
	.size	main.cold.117, .Lfunc_end127-main.cold.117
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.118
	.type	main.cold.118,@function
main.cold.118:                          # @main.cold.118
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end128:
	.size	main.cold.118, .Lfunc_end128-main.cold.118
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.119
	.type	main.cold.119,@function
main.cold.119:                          # @main.cold.119
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end129:
	.size	main.cold.119, .Lfunc_end129-main.cold.119
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.120
	.type	main.cold.120,@function
main.cold.120:                          # @main.cold.120
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end130:
	.size	main.cold.120, .Lfunc_end130-main.cold.120
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.121
	.type	main.cold.121,@function
main.cold.121:                          # @main.cold.121
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end131:
	.size	main.cold.121, .Lfunc_end131-main.cold.121
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.122
	.type	main.cold.122,@function
main.cold.122:                          # @main.cold.122
# %bb.0:
	pushq	%rax
	leaq	.L.str.6(%rip), %rdi
	callq	die
.Lfunc_end132:
	.size	main.cold.122, .Lfunc_end132-main.cold.122
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.123
	.type	main.cold.123,@function
main.cold.123:                          # @main.cold.123
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end133:
	.size	main.cold.123, .Lfunc_end133-main.cold.123
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.124
	.type	main.cold.124,@function
main.cold.124:                          # @main.cold.124
# %bb.0:
	pushq	%rax
	leaq	.L.str.6(%rip), %rdi
	callq	die
.Lfunc_end134:
	.size	main.cold.124, .Lfunc_end134-main.cold.124
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.125
	.type	main.cold.125,@function
main.cold.125:                          # @main.cold.125
# %bb.0:
	pushq	%rax
	leaq	.L.str.6(%rip), %rdi
	callq	die
.Lfunc_end135:
	.size	main.cold.125, .Lfunc_end135-main.cold.125
                                        # -- End function
	.p2align	4                               # -- Begin function place_matching.cold.1
	.type	place_matching.cold.1,@function
place_matching.cold.1:                  # @place_matching.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.39(%rip), %rdi
	callq	die
.Lfunc_end136:
	.size	place_matching.cold.1, .Lfunc_end136-place_matching.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function place_matching.cold.2
	.type	place_matching.cold.2,@function
place_matching.cold.2:                  # @place_matching.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end137:
	.size	place_matching.cold.2, .Lfunc_end137-place_matching.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function mark_matching_common_symbols.cold.1
	.type	mark_matching_common_symbols.cold.1,@function
mark_matching_common_symbols.cold.1:    # @mark_matching_common_symbols.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.46(%rip), %rdi
	callq	die
.Lfunc_end138:
	.size	mark_matching_common_symbols.cold.1, .Lfunc_end138-mark_matching_common_symbols.cold.1
                                        # -- End function
	.type	.L.str.1,@object                # @.str.1
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.1:
	.asciz	"-o requires an output path"
	.size	.L.str.1, 27

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.asciz	"--base"
	.size	.L.str.2, 7

	.type	.L.str.3,@object                # @.str.3
.L.str.3:
	.asciz	"--base requires an address"
	.size	.L.str.3, 27

	.type	.L.str.4,@object                # @.str.4
.L.str.4:
	.asciz	"link_aarch64_user_elf: unknown option %s\n"
	.size	.L.str.4, 42

	.type	.L.str.5,@object                # @.str.5
.L.str.5:
	.asciz	"usage: link_aarch64_user_elf -o OUTPUT [--base 0xADDR] INPUT.o [INPUT.o ...]\n"
	.size	.L.str.5, 78

	.type	.L.str.6,@object                # @.str.6
.L.str.6:
	.asciz	"out of memory"
	.size	.L.str.6, 14

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"link_aarch64_user_elf: %s\n"
	.size	.L.str.7, 27

	.type	.L.str.8,@object                # @.str.8
.L.str.8:
	.asciz	"link_aarch64_user_elf: invalid address: %s\n"
	.size	.L.str.8, 44

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"rb"
	.size	.L.str.9, 3

	.type	.L.str.10,@object               # @.str.10
.L.str.10:
	.asciz	"seek failed"
	.size	.L.str.10, 12

	.type	.L.str.11,@object               # @.str.11
.L.str.11:
	.asciz	"tell failed"
	.size	.L.str.11, 12

	.type	.L.str.12,@object               # @.str.12
.L.str.12:
	.asciz	"read failed"
	.size	.L.str.12, 12

	.type	.L.str.13,@object               # @.str.13
.L.str.13:
	.asciz	"link_aarch64_user_elf: %s: %s\n"
	.size	.L.str.13, 31

	.type	.L.str.14,@object               # @.str.14
.L.str.14:
	.asciz	"\177ELF"
	.size	.L.str.14, 5

	.type	.L.str.15,@object               # @.str.15
.L.str.15:
	.asciz	"not an ELF file"
	.size	.L.str.15, 16

	.type	.L.str.16,@object               # @.str.16
.L.str.16:
	.asciz	"expected ELF64 little-endian"
	.size	.L.str.16, 29

	.type	.L.str.17,@object               # @.str.17
.L.str.17:
	.asciz	"expected AArch64 relocatable ELF"
	.size	.L.str.17, 33

	.type	.L.str.18,@object               # @.str.18
.L.str.18:
	.asciz	"section header size too small"
	.size	.L.str.18, 30

	.type	.L.str.19,@object               # @.str.19
.L.str.19:
	.asciz	"section string table index out of range"
	.size	.L.str.19, 40

	.type	.L.str.20,@object               # @.str.20
.L.str.20:
	.asciz	"section headers out of range"
	.size	.L.str.20, 29

	.type	.L.str.21,@object               # @.str.21
.L.str.21:
	.asciz	"section string table out of range"
	.size	.L.str.21, 34

	.type	.L.str.22,@object               # @.str.22
.L.str.22:
	.asciz	"section data out of range"
	.size	.L.str.22, 26

	.type	.L.str.23,@object               # @.str.23
.L.str.23:
	.asciz	"unexpected end of file"
	.size	.L.str.23, 23

	.type	.L.str.24,@object               # @.str.24
.L.str.24:
	.asciz	"string table offset out of range"
	.size	.L.str.24, 33

	.type	.L.str.25,@object               # @.str.25
.L.str.25:
	.asciz	"unterminated string table entry"
	.size	.L.str.25, 32

	.type	.L.str.26,@object               # @.str.26
.L.str.26:
	.asciz	"unsupported allocated section type"
	.size	.L.str.26, 35

	.type	.L.str.27,@object               # @.str.27
.L.str.27:
	.asciz	".text"
	.size	.L.str.27, 6

	.type	.L.str.28,@object               # @.str.28
.L.str.28:
	.asciz	".rodata"
	.size	.L.str.28, 8

	.type	.L.str.29,@object               # @.str.29
.L.str.29:
	.asciz	".data"
	.size	.L.str.29, 6

	.type	.L.str.30,@object               # @.str.30
.L.str.30:
	.asciz	".bss"
	.size	.L.str.30, 5

	.type	.L.str.31,@object               # @.str.31
.L.str.31:
	.asciz	"symbol string table link out of range"
	.size	.L.str.31, 38

	.type	.L.str.32,@object               # @.str.32
.L.str.32:
	.asciz	"symbol table entry size too small"
	.size	.L.str.32, 34

	.type	.L.str.33,@object               # @.str.33
.L.str.33:
	.asciz	"symbol table size is not a multiple of entry size"
	.size	.L.str.33, 50

	.type	.L.str.34,@object               # @.str.34
.L.str.34:
	.asciz	"symbol string table out of range"
	.size	.L.str.34, 33

	.type	.L.str.35,@object               # @.str.35
.L.str.35:
	.asciz	"missing symbol table"
	.size	.L.str.35, 21

	.type	.L.str.37,@object               # @.str.37
.L.str.37:
	.asciz	".text.pi4_abi_probe.entry"
	.size	.L.str.37, 26

	.type	.L.str.38,@object               # @.str.38
.L.str.38:
	.asciz	"missing loadable text"
	.size	.L.str.38, 22

	.type	.L.str.39,@object               # @.str.39
.L.str.39:
	.asciz	"section alignment is not a power of two"
	.size	.L.str.39, 40

	.type	.L.str.40,@object               # @.str.40
.L.str.40:
	.asciz	"section alignment overflow"
	.size	.L.str.40, 27

	.type	.L.str.41,@object               # @.str.41
.L.str.41:
	.asciz	"common symbol allocation overflow"
	.size	.L.str.41, 34

	.type	.L.str.42,@object               # @.str.42
.L.str.42:
	.asciz	"link_aarch64_user_elf: duplicate symbol: %s\n"
	.size	.L.str.42, 45

	.type	.L.str.43,@object               # @.str.43
.L.str.43:
	.asciz	"common symbol was not allocated"
	.size	.L.str.43, 32

	.type	.L.str.44,@object               # @.str.44
.L.str.44:
	.asciz	"symbol section out of range"
	.size	.L.str.44, 28

	.type	.L.str.45,@object               # @.str.45
.L.str.45:
	.asciz	"symbol is not in a loadable section"
	.size	.L.str.45, 36

	.type	.L.str.46,@object               # @.str.46
.L.str.46:
	.asciz	"common symbol alignment is not a power of two"
	.size	.L.str.46, 46

	.type	.L.str.47,@object               # @.str.47
.L.str.47:
	.asciz	"no allocated file-backed sections"
	.size	.L.str.47, 34

	.type	.L.str.48,@object               # @.str.48
.L.str.48:
	.asciz	"section output range is outside image"
	.size	.L.str.48, 38

	.type	.L.str.50,@object               # @.str.50
.L.str.50:
	.asciz	"write past output"
	.size	.L.str.50, 18

	.type	.L.str.51,@object               # @.str.51
.L.str.51:
	.asciz	"_start"
	.size	.L.str.51, 7

	.type	.L.str.52,@object               # @.str.52
.L.str.52:
	.asciz	"_start entry symbol must not be local"
	.size	.L.str.52, 38

	.type	.L.str.53,@object               # @.str.53
.L.str.53:
	.asciz	"_start entry symbol must be a function"
	.size	.L.str.53, 39

	.type	.L.str.54,@object               # @.str.54
.L.str.54:
	.asciz	"_start entry symbol must be in executable text"
	.size	.L.str.54, 47

	.type	.L.str.55,@object               # @.str.55
.L.str.55:
	.asciz	"duplicate _start entry symbol"
	.size	.L.str.55, 30

	.type	.L.str.56,@object               # @.str.56
.L.str.56:
	.asciz	"first input must define CRT0 _start entry symbol"
	.size	.L.str.56, 49

	.type	.L.str.57,@object               # @.str.57
.L.str.57:
	.asciz	"relocation target section out of range"
	.size	.L.str.57, 39

	.type	.L.str.58,@object               # @.str.58
.L.str.58:
	.asciz	"RELA section does not link to the symbol table"
	.size	.L.str.58, 47

	.type	.L.str.59,@object               # @.str.59
.L.str.59:
	.asciz	"REL relocation sections are unsupported; AArch64 user objects must use RELA"
	.size	.L.str.59, 76

	.type	.L.str.60,@object               # @.str.60
.L.str.60:
	.asciz	"cannot relocate into NOBITS section"
	.size	.L.str.60, 36

	.type	.L.str.61,@object               # @.str.61
.L.str.61:
	.asciz	"unsupported RELA entry size"
	.size	.L.str.61, 28

	.type	.L.str.62,@object               # @.str.62
.L.str.62:
	.asciz	"RELA section size is not a multiple of entry size"
	.size	.L.str.62, 50

	.type	.L.str.63,@object               # @.str.63
.L.str.63:
	.asciz	"unsupported AArch64 relocation"
	.size	.L.str.63, 31

	.type	.L.str.64,@object               # @.str.64
.L.str.64:
	.asciz	"relocation target range is outside section"
	.size	.L.str.64, 43

	.type	.L.str.65,@object               # @.str.65
.L.str.65:
	.asciz	"ABS64 relocation target outside output"
	.size	.L.str.65, 39

	.type	.L.str.66,@object               # @.str.66
.L.str.66:
	.asciz	"link_aarch64_user_elf: %s: %s -> %s: %s\n"
	.size	.L.str.66, 41

	.type	.L.str.67,@object               # @.str.67
.L.str.67:
	.asciz	"<unnamed-relocations>"
	.size	.L.str.67, 22

	.type	.L.str.68,@object               # @.str.68
.L.str.68:
	.asciz	"<unnamed-target>"
	.size	.L.str.68, 17

	.type	.L.str.69,@object               # @.str.69
.L.str.69:
	.asciz	"link_aarch64_user_elf: %s: %s -> %s relocation %zu offset 0x%llx type %s(%u) symbol %zu: %s\n"
	.size	.L.str.69, 93

	.type	.L.str.70,@object               # @.str.70
.L.str.70:
	.asciz	"R_AARCH64_NONE"
	.size	.L.str.70, 15

	.type	.L.str.71,@object               # @.str.71
.L.str.71:
	.asciz	"R_AARCH64_ABS64"
	.size	.L.str.71, 16

	.type	.L.str.72,@object               # @.str.72
.L.str.72:
	.asciz	"R_AARCH64_ADR_PREL_LO21"
	.size	.L.str.72, 24

	.type	.L.str.73,@object               # @.str.73
.L.str.73:
	.asciz	"R_AARCH64_ADR_PREL_PG_HI21"
	.size	.L.str.73, 27

	.type	.L.str.74,@object               # @.str.74
.L.str.74:
	.asciz	"R_AARCH64_ADD_ABS_LO12_NC"
	.size	.L.str.74, 26

	.type	.L.str.75,@object               # @.str.75
.L.str.75:
	.asciz	"R_AARCH64_LDST8_ABS_LO12_NC"
	.size	.L.str.75, 28

	.type	.L.str.76,@object               # @.str.76
.L.str.76:
	.asciz	"R_AARCH64_JUMP26"
	.size	.L.str.76, 17

	.type	.L.str.77,@object               # @.str.77
.L.str.77:
	.asciz	"R_AARCH64_CALL26"
	.size	.L.str.77, 17

	.type	.L.str.78,@object               # @.str.78
.L.str.78:
	.asciz	"R_AARCH64_LDST16_ABS_LO12_NC"
	.size	.L.str.78, 29

	.type	.L.str.79,@object               # @.str.79
.L.str.79:
	.asciz	"R_AARCH64_LDST32_ABS_LO12_NC"
	.size	.L.str.79, 29

	.type	.L.str.80,@object               # @.str.80
.L.str.80:
	.asciz	"R_AARCH64_LDST64_ABS_LO12_NC"
	.size	.L.str.80, 29

	.type	.L.str.81,@object               # @.str.81
.L.str.81:
	.asciz	"R_AARCH64_LDST128_ABS_LO12_NC"
	.size	.L.str.81, 30

	.type	.L.str.82,@object               # @.str.82
.L.str.82:
	.asciz	"UNKNOWN"
	.size	.L.str.82, 8

	.type	.L.str.83,@object               # @.str.83
.L.str.83:
	.asciz	"relocation symbol index out of range"
	.size	.L.str.83, 37

	.type	.L.str.84,@object               # @.str.84
.L.str.84:
	.asciz	"unsupported relocation symbol binding"
	.size	.L.str.84, 38

	.type	.L.str.85,@object               # @.str.85
.L.str.85:
	.asciz	"unsupported relocation symbol type"
	.size	.L.str.85, 35

	.type	.L.str.86,@object               # @.str.86
.L.str.86:
	.asciz	"relocation references an unnamed undefined symbol"
	.size	.L.str.86, 50

	.type	.L.str.87,@object               # @.str.87
.L.str.87:
	.asciz	"unresolved symbol"
	.size	.L.str.87, 18

	.type	.L.str.88,@object               # @.str.88
.L.str.88:
	.asciz	"link_aarch64_user_elf: %s: %s -> %s relocation %zu offset 0x%llx type %s(%u) symbol %zu (%s): %s\n"
	.size	.L.str.88, 98

	.type	.L.str.89,@object               # @.str.89
.L.str.89:
	.asciz	"<unnamed>"
	.size	.L.str.89, 10

	.type	.L.str.90,@object               # @.str.90
.L.str.90:
	.asciz	"__pi4_user_image_base"
	.size	.L.str.90, 22

	.type	.L.str.91,@object               # @.str.91
.L.str.91:
	.asciz	"__pi4_user_image_end"
	.size	.L.str.91, 21

	.type	.L.str.92,@object               # @.str.92
.L.str.92:
	.asciz	"__pi4_user_bss_start"
	.size	.L.str.92, 21

	.type	.L.str.93,@object               # @.str.93
.L.str.93:
	.asciz	"__bss_start"
	.size	.L.str.93, 12

	.type	.L.str.94,@object               # @.str.94
.L.str.94:
	.asciz	"__pi4_user_bss_end"
	.size	.L.str.94, 19

	.type	.L.str.95,@object               # @.str.95
.L.str.95:
	.asciz	"__bss_end"
	.size	.L.str.95, 10

	.type	.L.str.96,@object               # @.str.96
.L.str.96:
	.asciz	"unsupported resolved symbol binding"
	.size	.L.str.96, 36

	.type	.L.str.97,@object               # @.str.97
.L.str.97:
	.asciz	"unsupported resolved symbol type"
	.size	.L.str.97, 33

	.type	.L.str.98,@object               # @.str.98
.L.str.98:
	.asciz	"symbol section index is out of range"
	.size	.L.str.98, 37

	.type	.L.str.99,@object               # @.str.99
.L.str.99:
	.asciz	"ADR relocation target outside output"
	.size	.L.str.99, 37

	.type	.L.str.100,@object              # @.str.100
.L.str.100:
	.asciz	"ADR relocation is out of +/-1 MiB range"
	.size	.L.str.100, 40

	.type	.L.str.101,@object              # @.str.101
.L.str.101:
	.asciz	"ADR relocation target is not an ADR instruction"
	.size	.L.str.101, 48

	.type	.L.str.102,@object              # @.str.102
.L.str.102:
	.asciz	"ADRP relocation target outside output"
	.size	.L.str.102, 38

	.type	.L.str.103,@object              # @.str.103
.L.str.103:
	.asciz	"ADRP relocation is out of +/-4 GiB range"
	.size	.L.str.103, 41

	.type	.L.str.104,@object              # @.str.104
.L.str.104:
	.asciz	"ADRP relocation target is not an ADRP instruction"
	.size	.L.str.104, 50

	.type	.L.str.105,@object              # @.str.105
.L.str.105:
	.asciz	"ADD_LO12 relocation target outside output"
	.size	.L.str.105, 42

	.type	.L.str.106,@object              # @.str.106
.L.str.106:
	.asciz	"ADD_LO12 relocation target is not an ADD-immediate instruction"
	.size	.L.str.106, 63

	.type	.L.str.107,@object              # @.str.107
.L.str.107:
	.asciz	"ADD_LO12 relocation target uses a shifted immediate"
	.size	.L.str.107, 52

	.type	.L.str.108,@object              # @.str.108
.L.str.108:
	.asciz	"LDST_LO12 relocation target outside output"
	.size	.L.str.108, 43

	.type	.L.str.109,@object              # @.str.109
.L.str.109:
	.asciz	"LDST_LO12 relocation target is not a load/store unsigned-immediate instruction"
	.size	.L.str.109, 79

	.type	.L.str.110,@object              # @.str.110
.L.str.110:
	.asciz	"LDST_LO12 relocation target size does not match relocation"
	.size	.L.str.110, 59

	.type	.L.str.111,@object              # @.str.111
.L.str.111:
	.asciz	"LDST_LO12 relocation target is not aligned for access size"
	.size	.L.str.111, 59

	.type	.L.str.112,@object              # @.str.112
.L.str.112:
	.asciz	"branch relocation target outside output"
	.size	.L.str.112, 40

	.type	.L.str.113,@object              # @.str.113
.L.str.113:
	.asciz	"branch relocation target is not 4-byte aligned"
	.size	.L.str.113, 47

	.type	.L.str.114,@object              # @.str.114
.L.str.114:
	.asciz	"branch relocation is out of +/-128 MiB range"
	.size	.L.str.114, 45

	.type	.L.str.115,@object              # @.str.115
.L.str.115:
	.asciz	"branch relocation target has the wrong opcode"
	.size	.L.str.115, 46

	.type	.L.str.116,@object              # @.str.116
.L.str.116:
	.asciz	"wb"
	.size	.L.str.116, 3

	.type	.L.str.117,@object              # @.str.117
.L.str.117:
	.asciz	"write failed"
	.size	.L.str.117, 13

	.ident	"Apple clang version 21.0.0 (clang-2100.1.1.101)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym main.cold.1
	.addrsig_sym main.cold.2
	.addrsig_sym main.cold.3
	.addrsig_sym main.cold.4
	.addrsig_sym main.cold.5
	.addrsig_sym main.cold.6
	.addrsig_sym main.cold.7
	.addrsig_sym main.cold.8
	.addrsig_sym main.cold.9
	.addrsig_sym main.cold.10
	.addrsig_sym main.cold.11
	.addrsig_sym main.cold.12
	.addrsig_sym main.cold.13
	.addrsig_sym main.cold.14
	.addrsig_sym main.cold.15
	.addrsig_sym main.cold.16
	.addrsig_sym main.cold.17
	.addrsig_sym main.cold.18
	.addrsig_sym main.cold.19
	.addrsig_sym main.cold.20
	.addrsig_sym main.cold.21
	.addrsig_sym main.cold.22
	.addrsig_sym main.cold.23
	.addrsig_sym main.cold.24
	.addrsig_sym main.cold.25
	.addrsig_sym main.cold.26
	.addrsig_sym main.cold.27
	.addrsig_sym main.cold.28
	.addrsig_sym main.cold.29
	.addrsig_sym main.cold.30
	.addrsig_sym main.cold.31
	.addrsig_sym main.cold.32
	.addrsig_sym main.cold.33
	.addrsig_sym main.cold.34
	.addrsig_sym main.cold.35
	.addrsig_sym main.cold.36
	.addrsig_sym main.cold.37
	.addrsig_sym main.cold.38
	.addrsig_sym main.cold.39
	.addrsig_sym main.cold.40
	.addrsig_sym main.cold.41
	.addrsig_sym main.cold.42
	.addrsig_sym main.cold.43
	.addrsig_sym main.cold.44
	.addrsig_sym main.cold.45
	.addrsig_sym main.cold.46
	.addrsig_sym main.cold.47
	.addrsig_sym main.cold.48
	.addrsig_sym main.cold.49
	.addrsig_sym main.cold.50
	.addrsig_sym main.cold.51
	.addrsig_sym main.cold.52
	.addrsig_sym main.cold.53
	.addrsig_sym main.cold.54
	.addrsig_sym main.cold.55
	.addrsig_sym main.cold.56
	.addrsig_sym main.cold.57
	.addrsig_sym main.cold.58
	.addrsig_sym main.cold.59
	.addrsig_sym main.cold.60
	.addrsig_sym main.cold.61
	.addrsig_sym main.cold.62
	.addrsig_sym main.cold.63
	.addrsig_sym main.cold.64
	.addrsig_sym main.cold.65
	.addrsig_sym main.cold.66
	.addrsig_sym main.cold.67
	.addrsig_sym main.cold.68
	.addrsig_sym main.cold.69
	.addrsig_sym main.cold.70
	.addrsig_sym main.cold.71
	.addrsig_sym main.cold.72
	.addrsig_sym main.cold.73
	.addrsig_sym main.cold.74
	.addrsig_sym main.cold.75
	.addrsig_sym main.cold.76
	.addrsig_sym main.cold.77
	.addrsig_sym main.cold.78
	.addrsig_sym main.cold.79
	.addrsig_sym main.cold.80
	.addrsig_sym main.cold.81
	.addrsig_sym main.cold.82
	.addrsig_sym main.cold.83
	.addrsig_sym main.cold.84
	.addrsig_sym main.cold.85
	.addrsig_sym main.cold.86
	.addrsig_sym main.cold.87
	.addrsig_sym main.cold.88
	.addrsig_sym main.cold.89
	.addrsig_sym main.cold.90
	.addrsig_sym main.cold.91
	.addrsig_sym main.cold.92
	.addrsig_sym main.cold.93
	.addrsig_sym main.cold.94
	.addrsig_sym main.cold.95
	.addrsig_sym main.cold.96
	.addrsig_sym main.cold.97
	.addrsig_sym main.cold.98
	.addrsig_sym main.cold.99
	.addrsig_sym main.cold.100
	.addrsig_sym main.cold.101
	.addrsig_sym main.cold.102
	.addrsig_sym main.cold.103
	.addrsig_sym main.cold.104
	.addrsig_sym main.cold.105
	.addrsig_sym main.cold.106
	.addrsig_sym main.cold.107
	.addrsig_sym main.cold.108
	.addrsig_sym main.cold.109
	.addrsig_sym main.cold.110
	.addrsig_sym main.cold.111
	.addrsig_sym main.cold.112
	.addrsig_sym main.cold.113
	.addrsig_sym main.cold.114
	.addrsig_sym main.cold.115
	.addrsig_sym main.cold.116
	.addrsig_sym main.cold.117
	.addrsig_sym main.cold.118
	.addrsig_sym main.cold.119
	.addrsig_sym main.cold.120
	.addrsig_sym main.cold.121
	.addrsig_sym main.cold.122
	.addrsig_sym main.cold.123
	.addrsig_sym main.cold.124
	.addrsig_sym main.cold.125
	.addrsig_sym place_matching.cold.1
	.addrsig_sym place_matching.cold.2
	.addrsig_sym mark_matching_common_symbols.cold.1
