	.file	"make_wad_image.linux.c"
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
	subq	$131336, %rsp                   # imm = 0x20108
	movq	%rsi, %rbx
	movl	%edi, %ebp
	movslq	%edi, %rdi
	movl	$8, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_301
# %bb.1:
	movq	%rax, %r14
	cmpl	$4, %ebp
	movq	%rbx, 24(%rsp)                  # 8-byte Spill
	movl	%ebp, (%rsp)                    # 4-byte Spill
	je	.LBB0_5
# %bb.2:
	cmpl	$5, %ebp
	jne	.LBB0_7
# %bb.3:
	movq	8(%rbx), %rbx
	leaq	.L.str(%rip), %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_9
# %bb.4:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	32(%rax), %rdi
	movq	16(%rax), %rsi
	movq	24(%rax), %rdx
	movl	$1, %ecx
	callq	mutate_root_marker
	jmp	.LBB0_243
.LBB0_5:
	movq	8(%rbx), %rbx
	leaq	.L.str.1(%rip), %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_9
# %bb.6:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	16(%rax), %rsi
	movq	24(%rax), %rdi
	leaq	.L.str.2(%rip), %rdx
	xorl	%ecx, %ecx
	callq	mutate_root_marker
	jmp	.LBB0_243
.LBB0_7:
	cmpl	$3, %ebp
	jl	.LBB0_105
# %bb.8:
	movq	8(%rbx), %rbx
.LBB0_9:
	leaq	.L.str.3(%rip), %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movl	(%rsp), %eax                    # 4-byte Reload
	je	.LBB0_102
.LBB0_10:
	movl	$1, %ebp
	movq	$0, 48(%rsp)                    # 8-byte Folded Spill
	movl	$0, %eax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	movl	$0, %eax
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	movl	$0, 84(%rsp)                    # 4-byte Folded Spill
	movq	$0, 64(%rsp)                    # 8-byte Folded Spill
	movq	$0, 72(%rsp)                    # 8-byte Folded Spill
	movq	$0, 88(%rsp)                    # 8-byte Folded Spill
	movq	$0, 104(%rsp)                   # 8-byte Folded Spill
	xorl	%r12d, %r12d
	movq	$0, 56(%rsp)                    # 8-byte Folded Spill
	xorl	%r15d, %r15d
	movq	$0, 16(%rsp)                    # 8-byte Folded Spill
	movq	$0, 8(%rsp)                     # 8-byte Folded Spill
	movq	%r14, 96(%rsp)                  # 8-byte Spill
	jmp	.LBB0_14
.LBB0_11:                               #   in Loop: Header=BB0_14 Depth=1
	movl	$1, %eax
	movq	%rax, 32(%rsp)                  # 8-byte Spill
.LBB0_12:                               #   in Loop: Header=BB0_14 Depth=1
	movl	(%rsp), %ecx                    # 4-byte Reload
.LBB0_13:                               #   in Loop: Header=BB0_14 Depth=1
	incl	%ebp
	cmpl	%ecx, %ebp
	jge	.LBB0_73
.LBB0_14:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_61 Depth 2
                                        #     Child Loop BB0_46 Depth 2
	movslq	%ebp, %rax
	movq	(%rbx,%rax,8), %r13
	movq	%r13, %rdi
	leaq	.L.str.14(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_25
# %bb.15:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.15(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_25
# %bb.16:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.16(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_11
# %bb.17:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.17(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_27
# %bb.18:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.18(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_29
# %bb.19:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.19(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_30
# %bb.20:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.20(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_33
# %bb.21:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.22(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_49
# %bb.22:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%r13, %rdi
	leaq	.L.str.24(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_64
# %bb.23:                               #   in Loop: Header=BB0_14 Depth=1
	cmpb	$45, (%r13)
	movl	(%rsp), %ecx                    # 4-byte Reload
	je	.LBB0_323
# %bb.24:                               #   in Loop: Header=BB0_14 Depth=1
	movq	64(%rsp), %rax                  # 8-byte Reload
	movq	%r13, (%r14,%rax,8)
	incq	%rax
	movq	%rax, 64(%rsp)                  # 8-byte Spill
	jmp	.LBB0_13
	.p2align	4
.LBB0_25:                               #   in Loop: Header=BB0_14 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_283
# %bb.26:                               #   in Loop: Header=BB0_14 Depth=1
	movslq	%ebp, %rax
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	jmp	.LBB0_13
.LBB0_27:                               #   in Loop: Header=BB0_14 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_300
# %bb.28:                               #   in Loop: Header=BB0_14 Depth=1
	movslq	%ebp, %rax
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	jmp	.LBB0_13
.LBB0_29:                               #   in Loop: Header=BB0_14 Depth=1
	movl	$1, 84(%rsp)                    # 4-byte Folded Spill
	jmp	.LBB0_12
.LBB0_30:                               #   in Loop: Header=BB0_14 Depth=1
	incl	%ebp
	cmpl	(%rsp), %ebp                    # 4-byte Folded Reload
	jge	.LBB0_305
# %bb.31:                               #   in Loop: Header=BB0_14 Depth=1
	movq	8(%rsp), %r13                   # 8-byte Reload
	leaq	8(,%r13,8), %rsi
	movq	72(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB0_306
# %bb.32:                               #   in Loop: Header=BB0_14 Depth=1
	movslq	%ebp, %rcx
	movq	(%rbx,%rcx,8), %rdx
	movq	%rax, 72(%rsp)                  # 8-byte Spill
	movq	%rdx, (%rax,%r13,8)
	incq	%r13
	movq	%r13, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB0_12
.LBB0_33:                               #   in Loop: Header=BB0_14 Depth=1
	incl	%ebp
	cmpl	(%rsp), %ebp                    # 4-byte Folded Reload
	jge	.LBB0_308
# %bb.34:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	8(,%r15,8), %rax
	leaq	(%rax,%rax,2), %rsi
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_312
# %bb.35:                               #   in Loop: Header=BB0_14 Depth=1
	movslq	%ebp, %rax
	movq	(%rbx,%rax,8), %rbx
	movq	%rbx, %rdi
	movl	$61, %esi
	callq	strchr@PLT
	testq	%rax, %rax
	je	.LBB0_303
# %bb.36:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%rax, %r13
	movq	%rax, %r14
	subq	%rbx, %r14
	je	.LBB0_303
# %bb.37:                               #   in Loop: Header=BB0_14 Depth=1
	cmpb	$0, 1(%r13)
	je	.LBB0_303
# %bb.38:                               #   in Loop: Header=BB0_14 Depth=1
	cmpq	$64, %r14
	jae	.LBB0_311
# %bb.39:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	240(%rsp), %rdi
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	memcpy@PLT
	movb	$0, 240(%rsp,%r14)
	movq	$0, 112(%rsp)
	movl	$4, %ecx
	leaq	240(%rsp), %rdi
	leaq	144(%rsp), %rsi
	leaq	112(%rsp), %rdx
	callq	parse_path83
	cmpq	$1, 112(%rsp)
	jne	.LBB0_309
# %bb.40:                               #   in Loop: Header=BB0_14 Depth=1
	movl	152(%rsp), %eax
	movl	$19525, %ecx                    # imm = 0x4C45
	xorl	%ecx, %eax
	movzbl	154(%rsp), %ecx
	xorl	$70, %ecx
	orw	%ax, %cx
	movq	96(%rsp), %r14                  # 8-byte Reload
	movq	24(%rsp), %rbx                  # 8-byte Reload
	jne	.LBB0_310
# %bb.41:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	(%r15,%r15,2), %rax
	movq	16(%rsp), %rcx                  # 8-byte Reload
	leaq	(%rcx,%rax,8), %rax
	movl	151(%rsp), %ecx
	movl	%ecx, 7(%rax)
	movq	144(%rsp), %rcx
	movq	%rcx, (%rax)
	movq	(%rax), %rcx
	movabsq	$2314885604590964548, %rdx      # imm = 0x202020314D4F4F44
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$4918308063554842957, %rsi      # imm = 0x444157202020314D
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_302
# %bb.42:                               #   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$2314934069018903883, %rdx      # imm = 0x20204C454E52454B
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499685168104782, %rsi      # imm = 0x464C4520204C454E
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_302
# %bb.43:                               #   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$4778128234594521941, %rdx      # imm = 0x424F525052455355
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499831985918034, %rsi      # imm = 0x464C45424F525052
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_302
# %bb.44:                               #   in Loop: Header=BB0_14 Depth=1
	incq	%r13
	movq	%r13, 16(%rax)
	testq	%r15, %r15
	je	.LBB0_71
# %bb.45:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	1(%r15), %rcx
	movq	16(%rsp), %rdx                  # 8-byte Reload
	.p2align	4
.LBB0_46:                               #   Parent Loop BB0_14 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	(%rdx), %rsi
	xorq	(%rax), %rsi
	movq	3(%rdx), %rdi
	xorq	3(%rax), %rdi
	orq	%rsi, %rdi
	je	.LBB0_286
# %bb.47:                               #   in Loop: Header=BB0_46 Depth=2
	addq	$24, %rdx
	decq	%r15
	jne	.LBB0_46
# %bb.48:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%rcx, %r15
	jmp	.LBB0_12
.LBB0_49:                               #   in Loop: Header=BB0_14 Depth=1
	incl	%ebp
	cmpl	(%rsp), %ebp                    # 4-byte Folded Reload
	jge	.LBB0_324
# %bb.50:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	8(,%r12,8), %rax
	leaq	(%rax,%rax,2), %rsi
	movq	56(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_327
# %bb.51:                               #   in Loop: Header=BB0_14 Depth=1
	movslq	%ebp, %rax
	movq	(%rbx,%rax,8), %rbx
	movq	%rbx, %rdi
	movl	$61, %esi
	callq	strchr@PLT
	testq	%rax, %rax
	je	.LBB0_307
# %bb.52:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%rax, %r13
	movq	%rax, %r14
	subq	%rbx, %r14
	je	.LBB0_307
# %bb.53:                               #   in Loop: Header=BB0_14 Depth=1
	cmpb	$0, 1(%r13)
	je	.LBB0_307
# %bb.54:                               #   in Loop: Header=BB0_14 Depth=1
	cmpq	$64, %r14
	jae	.LBB0_326
# %bb.55:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	240(%rsp), %rdi
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	memcpy@PLT
	movb	$0, 240(%rsp,%r14)
	movq	$0, 112(%rsp)
	movl	$4, %ecx
	leaq	240(%rsp), %rdi
	leaq	144(%rsp), %rsi
	leaq	112(%rsp), %rdx
	callq	parse_path83
	cmpq	$1, 112(%rsp)
	jne	.LBB0_325
# %bb.56:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	(%r12,%r12,2), %rax
	movq	56(%rsp), %rcx                  # 8-byte Reload
	leaq	(%rcx,%rax,8), %rax
	movl	151(%rsp), %ecx
	movl	%ecx, 7(%rax)
	movq	144(%rsp), %rcx
	movq	%rcx, (%rax)
	movq	(%rax), %rcx
	movabsq	$2314885604590964548, %rdx      # imm = 0x202020314D4F4F44
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$4918308063554842957, %rsi      # imm = 0x444157202020314D
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	movq	96(%rsp), %r14                  # 8-byte Reload
	movq	24(%rsp), %rbx                  # 8-byte Reload
	je	.LBB0_304
# %bb.57:                               #   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$2314934069018903883, %rdx      # imm = 0x20204C454E52454B
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499685168104782, %rsi      # imm = 0x464C4520204C454E
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_304
# %bb.58:                               #   in Loop: Header=BB0_14 Depth=1
	movq	(%rax), %rcx
	movabsq	$4778128234594521941, %rdx      # imm = 0x424F525052455355
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499831985918034, %rsi      # imm = 0x464C45424F525052
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_304
# %bb.59:                               #   in Loop: Header=BB0_14 Depth=1
	incq	%r13
	movq	%r13, 16(%rax)
	testq	%r12, %r12
	je	.LBB0_72
# %bb.60:                               #   in Loop: Header=BB0_14 Depth=1
	leaq	1(%r12), %rcx
	movq	56(%rsp), %rdx                  # 8-byte Reload
	.p2align	4
.LBB0_61:                               #   Parent Loop BB0_14 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	(%rdx), %rsi
	xorq	(%rax), %rsi
	movq	3(%rdx), %rdi
	xorq	3(%rax), %rdi
	orq	%rsi, %rdi
	je	.LBB0_295
# %bb.62:                               #   in Loop: Header=BB0_61 Depth=2
	addq	$24, %rdx
	decq	%r12
	jne	.LBB0_61
# %bb.63:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%rcx, %r12
	jmp	.LBB0_12
.LBB0_64:                               #   in Loop: Header=BB0_14 Depth=1
	incl	%ebp
	cmpl	(%rsp), %ebp                    # 4-byte Folded Reload
	jge	.LBB0_333
# %bb.65:                               #   in Loop: Header=BB0_14 Depth=1
	movq	88(%rsp), %rax                  # 8-byte Reload
	incq	%rax
	movq	%rax, 232(%rsp)                 # 8-byte Spill
	imulq	$104, %rax, %rsi
	movq	104(%rsp), %rdi                 # 8-byte Reload
	callq	realloc@PLT
	movq	%rax, 104(%rsp)                 # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_335
# %bb.66:                               #   in Loop: Header=BB0_14 Depth=1
	movslq	%ebp, %rax
	movq	(%rbx,%rax,8), %rbx
	movq	%rbx, %rdi
	movl	$61, %esi
	callq	strchr@PLT
	testq	%rax, %rax
	je	.LBB0_322
# %bb.67:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%rax, %r14
	movq	%rax, %r13
	subq	%rbx, %r13
	je	.LBB0_322
# %bb.68:                               #   in Loop: Header=BB0_14 Depth=1
	cmpb	$0, 1(%r14)
	je	.LBB0_322
# %bb.69:                               #   in Loop: Header=BB0_14 Depth=1
	cmpq	$96, %r13
	jae	.LBB0_334
# %bb.70:                               #   in Loop: Header=BB0_14 Depth=1
	movq	%rbx, %rsi
	imulq	$104, 88(%rsp), %rbx            # 8-byte Folded Reload
	addq	104(%rsp), %rbx                 # 8-byte Folded Reload
	incq	%r14
	movq	%rbx, %rdi
	movq	%r13, %rdx
	callq	memcpy@PLT
	movb	$0, (%rbx,%r13)
	movq	%r14, 96(%rbx)
	movq	232(%rsp), %rax                 # 8-byte Reload
	movq	%rax, 88(%rsp)                  # 8-byte Spill
	movq	96(%rsp), %r14                  # 8-byte Reload
	movq	24(%rsp), %rbx                  # 8-byte Reload
	jmp	.LBB0_12
.LBB0_71:                               #   in Loop: Header=BB0_14 Depth=1
	movl	$1, %r15d
	jmp	.LBB0_12
.LBB0_72:                               #   in Loop: Header=BB0_14 Depth=1
	movl	$1, %r12d
	jmp	.LBB0_12
.LBB0_73:
	movq	40(%rsp), %rbx                  # 8-byte Reload
	testq	%rbx, %rbx
	je	.LBB0_104
# %bb.74:
	cmpq	$0, 64(%rsp)                    # 8-byte Folded Reload
	jne	.LBB0_313
# %bb.75:
	cmpq	$0, 48(%rsp)                    # 8-byte Folded Reload
	jne	.LBB0_313
# %bb.76:
	cmpl	$0, 32(%rsp)                    # 4-byte Folded Reload
	jne	.LBB0_313
# %bb.77:
	testq	%r15, %r15
	jne	.LBB0_313
# %bb.78:
	testq	%r12, %r12
	jne	.LBB0_313
# %bb.79:
	cmpq	$0, 88(%rsp)                    # 8-byte Folded Reload
	jne	.LBB0_313
# %bb.80:
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, 144(%rsp)
	movq	%rdx, 152(%rsp)
	cmpq	$67108864, %rdx                 # imm = 0x4000000
	jne	.LBB0_314
# %bb.81:
	movq	%rax, %r14
	cmpw	$-21931, 510(%rax)              # imm = 0xAA55
	jne	.LBB0_315
# %bb.82:
	cmpl	$2048, 454(%r14)                # imm = 0x800
	jne	.LBB0_316
# %bb.83:
	cmpl	$129024, 458(%r14)              # imm = 0x1F800
	jne	.LBB0_316
# %bb.84:
	cmpw	$-21931, 1049086(%r14)          # imm = 0xAA55
	jne	.LBB0_317
# %bb.85:
	cmpw	$512, 1048587(%r14)             # imm = 0x200
	jne	.LBB0_318
# %bb.86:
	cmpb	$2, 1048589(%r14)
	jne	.LBB0_319
# %bb.87:
	leaq	.Lstr.515(%rip), %rdi
	callq	puts@PLT
	leaq	.L.str.135(%rip), %rdi
	movq	%rbx, %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.136(%rip), %rdi
	movl	$67108864, %esi                 # imm = 0x4000000
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.137(%rip), %rdi
	movl	$2048, %esi                     # imm = 0x800
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.138(%rip), %rdi
	movl	$129024, %esi                   # imm = 0x1F800
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.139(%rip), %rdi
	movl	$2561, %esi                     # imm = 0xA01
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.140(%rip), %rdi
	movl	$2593, %esi                     # imm = 0xA21
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.141(%rip), %rdi
	movl	$512, %esi                      # imm = 0x200
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.142(%rip), %rdi
	movl	$64239, %esi                    # imm = 0xFAEF
	xorl	%eax, %eax
	callq	printf@PLT
	movq	%r14, %r15
	addq	$1311232, %r15                  # imm = 0x140200
	leaq	240(%rsp), %r12
	leaq	.L.str.143(%rip), %r13
	leaq	144(%rsp), %rbp
	xorl	%ebx, %ebx
	movq	8(%rsp), %rcx                   # 8-byte Reload
	jmp	.LBB0_90
	.p2align	4
.LBB0_88:                               #   in Loop: Header=BB0_90 Depth=1
	movq	8(%rsp), %rcx                   # 8-byte Reload
.LBB0_89:                               #   in Loop: Header=BB0_90 Depth=1
	incq	%rbx
	addq	$32, %r15
	cmpq	$512, %rbx                      # imm = 0x200
	je	.LBB0_94
.LBB0_90:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%r15), %eax
	cmpl	$229, %eax
	je	.LBB0_89
# %bb.91:                               #   in Loop: Header=BB0_90 Depth=1
	testl	%eax, %eax
	je	.LBB0_94
# %bb.92:                               #   in Loop: Header=BB0_90 Depth=1
	movq	%r15, %rdi
	movq	%r12, %rsi
	callq	format_fat_name
	movzbl	11(%r15), %ecx
	movzwl	26(%r15), %r8d
	movl	28(%r15), %r9d
	movq	%r13, %rdi
	movl	%ebx, %esi
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	testb	$16, 11(%r15)
	je	.LBB0_88
# %bb.93:                               #   in Loop: Header=BB0_90 Depth=1
	movzwl	26(%r15), %edx
	movq	%rbp, %rdi
	movq	%r12, %rsi
	movl	$3, %ecx
	callq	inspect_directory
	jmp	.LBB0_88
.LBB0_94:
	testq	%rcx, %rcx
	je	.LBB0_101
# %bb.95:
	leaq	144(%rsp), %rbx
	leaq	240(%rsp), %r15
	leaq	.L.str.151(%rip), %r12
	xorl	%ebp, %ebp
	.p2align	4
.LBB0_96:                               # =>This Inner Loop Header: Depth=1
	movq	72(%rsp), %rax                  # 8-byte Reload
	movq	(%rax,%rbp,8), %r13
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	inspect_find_path
	testl	%eax, %eax
	je	.LBB0_287
# %bb.97:                               #   in Loop: Header=BB0_96 Depth=1
	testb	$16, 244(%rsp)
	jne	.LBB0_290
# %bb.98:                               #   in Loop: Header=BB0_96 Depth=1
	movl	252(%rsp), %edx
	testl	%edx, %edx
	je	.LBB0_288
# %bb.99:                               #   in Loop: Header=BB0_96 Depth=1
	movl	248(%rsp), %ecx
	leal	-64241(%rcx), %eax
	cmpl	$-64240, %eax                   # imm = 0xFFFF0510
	jbe	.LBB0_289
# %bb.100:                              #   in Loop: Header=BB0_96 Depth=1
	movq	%r12, %rdi
	movq	%r13, %rsi
                                        # kill: def $ecx killed $ecx killed $rcx
	xorl	%eax, %eax
	callq	printf@PLT
	incq	%rbp
	cmpq	%rbp, 8(%rsp)                   # 8-byte Folded Reload
	jne	.LBB0_96
.LBB0_101:
	leaq	144(%rsp), %rdi
	movl	84(%rsp), %esi                  # 4-byte Reload
	callq	inspect_pi4_manifest
	movq	%r14, %rdi
	callq	free@PLT
	movq	72(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	56(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	104(%rsp), %rdi                 # 8-byte Reload
	jmp	.LBB0_268
.LBB0_102:
	movq	%r14, 96(%rsp)                  # 8-byte Spill
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 352(%rsp)
	movaps	%xmm0, 336(%rsp)
	movaps	%xmm0, 320(%rsp)
	movaps	%xmm0, 304(%rsp)
	movaps	%xmm0, 288(%rsp)
	movaps	%xmm0, 272(%rsp)
	movaps	%xmm0, 256(%rsp)
	movaps	%xmm0, 240(%rsp)
	movq	$0, 368(%rsp)
	movq	16(%rbx), %rcx
	movq	%rcx, 72(%rsp)                  # 8-byte Spill
	cmpl	$4, %eax
	jb	.LBB0_133
# %bb.103:
	movq	$0, 56(%rsp)                    # 8-byte Folded Spill
	movq	280(%rsp), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	movq	272(%rsp), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	movq	256(%rsp), %rax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movq	264(%rsp), %rax
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	movl	$3, %ebp
	leaq	.L.str.4(%rip), %r14
	leaq	.L.str.5(%rip), %r12
	leaq	.L.str.6(%rip), %r13
	movl	$0, 64(%rsp)                    # 4-byte Folded Spill
	movq	$0, 48(%rsp)                    # 8-byte Folded Spill
	xorl	%r15d, %r15d
	jmp	.LBB0_138
.LBB0_104:
	movq	104(%rsp), %r13                 # 8-byte Reload
	movq	72(%rsp), %rax                  # 8-byte Reload
	movl	84(%rsp), %ecx                  # 4-byte Reload
	jmp	.LBB0_106
.LBB0_105:
	movq	$0, 48(%rsp)                    # 8-byte Folded Spill
	movl	$0, %eax
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	movl	$0, %eax
	movq	%rax, 64(%rsp)                  # 8-byte Spill
	movl	$0, %eax
	movl	$0, %ecx
	movq	%rcx, 88(%rsp)                  # 8-byte Spill
	movl	$0, %r13d
	movl	$0, %r12d
	movl	$0, %ecx
	movq	%rcx, 56(%rsp)                  # 8-byte Spill
	movl	$0, %r15d
	movl	$0, %ecx
	movq	%rcx, 16(%rsp)                  # 8-byte Spill
	movl	$0, %ecx
	movq	%rcx, 8(%rsp)                   # 8-byte Spill
	cmpl	$2, %ebp
	movl	$0, %ecx
	je	.LBB0_10
.LBB0_106:
	testl	%ecx, %ecx
	jne	.LBB0_320
# %bb.107:
	cmpq	$0, 8(%rsp)                     # 8-byte Folded Reload
	jne	.LBB0_320
# %bb.108:
	movq	%rax, %rbp
	movq	64(%rsp), %rcx                  # 8-byte Reload
	leaq	-4(%rcx), %rax
	cmpq	$3, %rax
	movq	56(%rsp), %r9                   # 8-byte Reload
	movq	16(%rsp), %r10                  # 8-byte Reload
	jb	.LBB0_110
# %bb.109:
	cmpq	$1, %rcx
	jne	.LBB0_338
.LBB0_110:
	testq	%r15, %r15
	je	.LBB0_117
# %bb.111:
	xorl	%eax, %eax
	jmp	.LBB0_113
	.p2align	4
.LBB0_112:                              #   in Loop: Header=BB0_113 Depth=1
	incq	%rax
	cmpq	%r15, %rax
	je	.LBB0_117
.LBB0_113:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_115 Depth 2
	testq	%rax, %rax
	je	.LBB0_112
# %bb.114:                              #   in Loop: Header=BB0_113 Depth=1
	leaq	(%rax,%rax,2), %rcx
	leaq	(%r10,%rcx,8), %rcx
	movq	%r10, %rdx
	movq	%rax, %rsi
	.p2align	4
.LBB0_115:                              #   Parent Loop BB0_113 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	.LBB0_279
# %bb.116:                              #   in Loop: Header=BB0_115 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	.LBB0_115
	jmp	.LBB0_112
.LBB0_117:
	testq	%r12, %r12
	je	.LBB0_128
# %bb.118:
	xorl	%eax, %eax
	jmp	.LBB0_120
	.p2align	4
.LBB0_119:                              #   in Loop: Header=BB0_120 Depth=1
	incq	%rax
	cmpq	%r12, %rax
	je	.LBB0_128
.LBB0_120:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_122 Depth 2
                                        #     Child Loop BB0_126 Depth 2
	testq	%rax, %rax
	je	.LBB0_124
# %bb.121:                              #   in Loop: Header=BB0_120 Depth=1
	leaq	(%rax,%rax,2), %rcx
	leaq	(%r9,%rcx,8), %rcx
	movq	%r9, %rdx
	movq	%rax, %rsi
	.p2align	4
.LBB0_122:                              #   Parent Loop BB0_120 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	.LBB0_280
# %bb.123:                              #   in Loop: Header=BB0_122 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	.LBB0_122
.LBB0_124:                              #   in Loop: Header=BB0_120 Depth=1
	testq	%r15, %r15
	je	.LBB0_119
# %bb.125:                              #   in Loop: Header=BB0_120 Depth=1
	leaq	(%rax,%rax,2), %rcx
	leaq	(%r9,%rcx,8), %rcx
	movq	%r10, %rdx
	movq	%r15, %rsi
	.p2align	4
.LBB0_126:                              #   Parent Loop BB0_120 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	.LBB0_281
# %bb.127:                              #   in Loop: Header=BB0_126 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	.LBB0_126
	jmp	.LBB0_119
.LBB0_128:
	movq	$67108864, 248(%rsp)            # imm = 0x4000000
	movl	$67108864, %edi                 # imm = 0x4000000
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_321
# %bb.129:
	movq	%rax, 240(%rsp)
	leaq	256(%rsp), %rdi
	xorl	%ebx, %ebx
	movl	$131072, %edx                   # imm = 0x20000
	xorl	%esi, %esi
	callq	memset@PLT
	movq	64(%rsp), %rax                  # 8-byte Reload
	cmpq	$3, %rax
	jbe	.LBB0_132
# %bb.130:
	movq	8(%r14), %rdx
	movq	16(%r14), %rcx
	movq	24(%r14), %r8
	cmpq	$4, %rax
	jne	.LBB0_240
# %bb.131:
	xorl	%ebx, %ebx
	jmp	.LBB0_242
.LBB0_132:
	xorl	%ecx, %ecx
	xorl	%edx, %edx
	xorl	%r8d, %r8d
	jmp	.LBB0_242
.LBB0_133:
	xorl	%r15d, %r15d
	jmp	.LBB0_177
.LBB0_134:                              #   in Loop: Header=BB0_138 Depth=1
	movl	$1, %eax
	movq	%rax, 56(%rsp)                  # 8-byte Spill
.LBB0_135:                              #   in Loop: Header=BB0_138 Depth=1
	movq	24(%rsp), %rbx                  # 8-byte Reload
.LBB0_136:                              #   in Loop: Header=BB0_138 Depth=1
	movl	(%rsp), %ecx                    # 4-byte Reload
	.p2align	4
.LBB0_137:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	cmpl	%ecx, %ebp
	jge	.LBB0_176
.LBB0_138:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_172 Depth 2
	movslq	%ebp, %rax
	movq	(%rbx,%rax,8), %rbx
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_153
# %bb.139:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	movq	%r12, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_155
# %bb.140:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	movq	%r13, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_157
# %bb.141:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.7(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_159
# %bb.142:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.8(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_161
# %bb.143:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.9(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_163
# %bb.144:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.10(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_134
# %bb.145:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.11(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_165
# %bb.146:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.12(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_166
# %bb.147:                              #   in Loop: Header=BB0_138 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.13(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_296
# %bb.148:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	cmpl	(%rsp), %ebp                    # 4-byte Folded Reload
	movq	24(%rsp), %rcx                  # 8-byte Reload
	jge	.LBB0_296
# %bb.149:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	(%rcx,%rax,8), %rbx
	movq	$0, 144(%rsp)
	movq	%rbx, %rdi
	leaq	144(%rsp), %rsi
	movl	$10, %edx
	callq	strtol@PLT
	movq	144(%rsp), %rcx
	cmpq	%rbx, %rcx
	je	.LBB0_336
# %bb.150:                              #   in Loop: Header=BB0_138 Depth=1
	cmpb	$61, (%rcx)
	jne	.LBB0_336
# %bb.151:                              #   in Loop: Header=BB0_138 Depth=1
	cmpq	$6, %rax
	jae	.LBB0_336
# %bb.152:                              #   in Loop: Header=BB0_138 Depth=1
	incq	%rcx
	movq	%rcx, 328(%rsp,%rax,8)
	jmp	.LBB0_135
	.p2align	4
.LBB0_153:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_296
# %bb.154:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	(%rbx,%rax,8), %r15
	jmp	.LBB0_137
	.p2align	4
.LBB0_155:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_296
# %bb.156:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 248(%rsp)
	jmp	.LBB0_137
.LBB0_157:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_296
# %bb.158:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB0_137
.LBB0_159:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_296
# %bb.160:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	jmp	.LBB0_137
.LBB0_161:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_296
# %bb.162:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	jmp	.LBB0_137
.LBB0_163:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	movl	(%rsp), %ecx                    # 4-byte Reload
	cmpl	%ecx, %ebp
	jge	.LBB0_296
# %bb.164:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	(%rbx,%rax,8), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	jmp	.LBB0_137
.LBB0_165:                              #   in Loop: Header=BB0_138 Depth=1
	movl	$1, 64(%rsp)                    # 4-byte Folded Spill
	jmp	.LBB0_135
.LBB0_166:                              #   in Loop: Header=BB0_138 Depth=1
	incl	%ebp
	cmpl	(%rsp), %ebp                    # 4-byte Folded Reload
	jge	.LBB0_296
# %bb.167:                              #   in Loop: Header=BB0_138 Depth=1
	movslq	%ebp, %rax
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %rbx
	movq	$0, 144(%rsp)
	movq	%rbx, %rdi
	leaq	144(%rsp), %rsi
	movl	$10, %edx
	callq	strtol@PLT
	movq	144(%rsp), %rcx
	cmpq	%rbx, %rcx
	je	.LBB0_340
# %bb.168:                              #   in Loop: Header=BB0_138 Depth=1
	cmpb	$0, (%rcx)
	jne	.LBB0_340
# %bb.169:                              #   in Loop: Header=BB0_138 Depth=1
	cmpq	$5, %rax
	ja	.LBB0_340
# %bb.170:                              #   in Loop: Header=BB0_138 Depth=1
	movq	48(%rsp), %rcx                  # 8-byte Reload
	testq	%rcx, %rcx
	movq	24(%rsp), %rbx                  # 8-byte Reload
	je	.LBB0_175
# %bb.171:                              #   in Loop: Header=BB0_138 Depth=1
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_172:                              #   Parent Loop BB0_138 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	%eax, 296(%rsp,%rcx,4)
	je	.LBB0_136
# %bb.173:                              #   in Loop: Header=BB0_172 Depth=2
	incq	%rcx
	cmpq	%rcx, 48(%rsp)                  # 8-byte Folded Reload
	jne	.LBB0_172
# %bb.174:                              #   in Loop: Header=BB0_138 Depth=1
	movq	48(%rsp), %rcx                  # 8-byte Reload
	cmpq	$6, %rcx
	jae	.LBB0_341
.LBB0_175:                              #   in Loop: Header=BB0_138 Depth=1
	movl	%eax, 296(%rsp,%rcx,4)
	incq	%rcx
	movq	%rcx, 48(%rsp)                  # 8-byte Spill
	jmp	.LBB0_136
.LBB0_176:
	movq	40(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 280(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 272(%rsp)
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 264(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 256(%rsp)
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 320(%rsp)
	movl	64(%rsp), %eax                  # 4-byte Reload
	movl	%eax, 292(%rsp)
	movq	56(%rsp), %rax                  # 8-byte Reload
	movl	%eax, 288(%rsp)
.LBB0_177:
	movq	%r15, 240(%rsp)
	movq	72(%rsp), %rbx                  # 8-byte Reload
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, %r14
	movq	%rax, 112(%rsp)
	movq	%rdx, 120(%rsp)
	leaq	112(%rsp), %rdi
	movq	%rbx, %rsi
	callq	validate_image_layout
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 192(%rsp)
	movaps	%xmm0, 208(%rsp)
	movq	240(%rsp), %rbx
	testq	%rbx, %rbx
	je	.LBB0_179
# %bb.178:
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, (%rsp)                    # 8-byte Spill
	movq	%rax, 192(%rsp)
	movq	%rdx, 200(%rsp)
	leaq	192(%rsp), %rdi
	movq	%rbx, %rsi
	callq	validate_image_layout
	jmp	.LBB0_180
.LBB0_179:
	movq	$0, (%rsp)                      # 8-byte Folded Spill
.LBB0_180:
	movq	248(%rsp), %rbx
	testq	%rbx, %rbx
	je	.LBB0_182
# %bb.181:
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movq	%rax, 208(%rsp)
	movq	%rdx, 216(%rsp)
	leaq	208(%rsp), %rdi
	movq	%rbx, %rsi
	callq	validate_image_layout
	jmp	.LBB0_183
.LBB0_182:
	movq	$0, 8(%rsp)                     # 8-byte Folded Spill
.LBB0_183:
	movl	288(%rsp), %ebx
	testl	%ebx, %ebx
	je	.LBB0_193
# %bb.184:
	xorl	%eax, %eax
	movabsq	$2329570836308444484, %rcx      # imm = 0x20544C5541464544
	movabsq	$5135866231194932545, %rdx      # imm = 0x47464320544C5541
	jmp	.LBB0_186
	.p2align	4
.LBB0_185:                              #   in Loop: Header=BB0_186 Depth=1
	addq	$32, %rax
	cmpq	$16384, %rax                    # imm = 0x4000
	je	.LBB0_282
.LBB0_186:                              # =>This Inner Loop Header: Depth=1
	movzbl	1311232(%r14,%rax), %esi
	cmpl	$229, %esi
	je	.LBB0_185
# %bb.187:                              #   in Loop: Header=BB0_186 Depth=1
	testl	%esi, %esi
	je	.LBB0_282
# %bb.188:                              #   in Loop: Header=BB0_186 Depth=1
	movq	1311232(%r14,%rax), %rsi
	xorq	%rcx, %rsi
	movq	1311235(%r14,%rax), %rdi
	xorq	%rdx, %rdi
	orq	%rsi, %rdi
	jne	.LBB0_185
# %bb.189:
	testb	$16, 1311243(%r14,%rax)
	jne	.LBB0_329
# %bb.190:
	cmpl	$0, 1311260(%r14,%rax)
	je	.LBB0_330
# %bb.191:
	cmpq	$0, (%rsp)                      # 8-byte Folded Reload
	je	.LBB0_193
# %bb.192:
	leaq	DEFAULT_CFG_NAME(%rip), %rdx
	leaq	112(%rsp), %rdi
	leaq	192(%rsp), %rsi
	callq	root_file_equal
	testl	%eax, %eax
	jne	.LBB0_337
.LBB0_193:
	movl	%ebx, 24(%rsp)                  # 4-byte Spill
	movq	320(%rsp), %rax
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_214
# %bb.194:
	xorl	%r12d, %r12d
	leaq	112(%rsp), %r13
	.p2align	4
.LBB0_195:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_198 Depth 2
	movslq	296(%rsp,%r12,4), %rax
	cmpq	$6, %rax
	jae	.LBB0_292
# %bb.196:                              #   in Loop: Header=BB0_195 Depth=1
	movq	328(%rsp,%rax,8), %r15
	movabsq	$2330121683245944644, %rcx      # imm = 0x205641534D4F4F44
	movq	%rcx, 128(%rsp)
	movl	$1196639264, 135(%rsp)          # imm = 0x47534420
	orb	$48, %al
	movb	%al, 135(%rsp)
	xorl	%eax, %eax
	jmp	.LBB0_198
	.p2align	4
.LBB0_197:                              #   in Loop: Header=BB0_198 Depth=2
	addq	$32, %rax
	cmpq	$16384, %rax                    # imm = 0x4000
	je	.LBB0_278
.LBB0_198:                              #   Parent Loop BB0_195 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	1311232(%r14,%rax), %ecx
	cmpl	$229, %ecx
	je	.LBB0_197
# %bb.199:                              #   in Loop: Header=BB0_198 Depth=2
	testl	%ecx, %ecx
	je	.LBB0_278
# %bb.200:                              #   in Loop: Header=BB0_198 Depth=2
	movq	1311232(%r14,%rax), %rcx
	xorq	128(%rsp), %rcx
	movq	1311235(%r14,%rax), %rdx
	xorq	131(%rsp), %rdx
	orq	%rcx, %rdx
	jne	.LBB0_197
# %bb.201:                              #   in Loop: Header=BB0_195 Depth=1
	movzbl	1311243(%r14,%rax), %ecx
	movzwl	1311258(%r14,%rax), %edx
	movl	1311260(%r14,%rax), %eax
	movq	%rax, %rsi
	shlq	$32, %rsi
	orq	%rdx, %rsi
	movq	%rcx, %rdx
	shlq	$32, %rdx
	incq	%rdx
	movq	%rdx, 144(%rsp)
	movq	%rsi, 152(%rsp)
	testb	$16, %cl
	jne	.LBB0_293
# %bb.202:                              #   in Loop: Header=BB0_195 Depth=1
	cmpl	$63, %eax
	jbe	.LBB0_294
# %bb.203:                              #   in Loop: Header=BB0_195 Depth=1
	cmpq	$0, (%rsp)                      # 8-byte Folded Reload
	je	.LBB0_205
# %bb.204:                              #   in Loop: Header=BB0_195 Depth=1
	movq	%r13, %rdi
	leaq	192(%rsp), %rsi
	leaq	128(%rsp), %rdx
	callq	root_file_equal
	testl	%eax, %eax
	jne	.LBB0_298
.LBB0_205:                              #   in Loop: Header=BB0_195 Depth=1
	cmpq	$0, 8(%rsp)                     # 8-byte Folded Reload
	je	.LBB0_207
# %bb.206:                              #   in Loop: Header=BB0_195 Depth=1
	movq	%r13, %rdi
	leaq	208(%rsp), %rsi
	leaq	128(%rsp), %rdx
	callq	root_file_equal
	testl	%eax, %eax
	je	.LBB0_297
.LBB0_207:                              #   in Loop: Header=BB0_195 Depth=1
	movq	%r13, %rdi
	leaq	144(%rsp), %rsi
	leaq	.L.str.82(%rip), %rdx
	callq	read_root_file_blob
	movq	%rax, %rbx
	movq	%rdx, %rbp
	testq	%r15, %r15
	je	.LBB0_211
# %bb.208:                              #   in Loop: Header=BB0_195 Depth=1
	movq	%r15, %rdi
	callq	strlen@PLT
	cmpq	$25, %rax
	jae	.LBB0_299
# %bb.209:                              #   in Loop: Header=BB0_195 Depth=1
	cmpq	$24, %rbp
	jb	.LBB0_291
# %bb.210:                              #   in Loop: Header=BB0_195 Depth=1
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movq	%rax, %rdx
	callq	bcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_291
.LBB0_211:                              #   in Loop: Header=BB0_195 Depth=1
	cmpq	$40, %rbp
	jb	.LBB0_284
# %bb.212:                              #   in Loop: Header=BB0_195 Depth=1
	movabsq	$2336927755350992246, %rax      # imm = 0x206E6F6973726576
	cmpq	%rax, 24(%rbx)
	jne	.LBB0_284
# %bb.213:                              #   in Loop: Header=BB0_195 Depth=1
	movq	%rbx, %rdi
	callq	free@PLT
	incq	%r12
	cmpq	48(%rsp), %r12                  # 8-byte Folded Reload
	jne	.LBB0_195
.LBB0_214:
	movq	256(%rsp), %r15
	movq	%r15, %rdi
	xorl	%esi, %esi
	callq	check_write_status
	movq	264(%rsp), %r12
	movq	%r12, %rdi
	movl	$1, %esi
	callq	check_write_status
	movq	272(%rsp), %rbp
	testq	%rbp, %rbp
	je	.LBB0_251
# %bb.215:
	movq	%rbp, %rdi
	callq	read_file
	movq	%rax, 144(%rsp)
	movq	%rdx, 152(%rsp)
	testq	%rax, %rax
	je	.LBB0_251
# %bb.216:
	movq	%rdx, %r13
	cmpq	$11, %rdx
	jb	.LBB0_220
# %bb.217:
	movq	%rax, %rbx
	movabsq	$8746391181324018023, %rax      # imm = 0x79616C70656D6167
	movl	$11, %ecx
	movabsq	$5426623667539570789, %rdx      # imm = 0x4B4F3D79616C7065
	.p2align	4
.LBB0_218:                              # =>This Inner Loop Header: Depth=1
	movq	-11(%rbx,%rcx), %rsi
	xorq	%rax, %rsi
	movq	-8(%rbx,%rcx), %rdi
	xorq	%rdx, %rdi
	orq	%rsi, %rdi
	je	.LBB0_221
# %bb.219:                              #   in Loop: Header=BB0_218 Depth=1
	incq	%rcx
	cmpq	%r13, %rcx
	jbe	.LBB0_218
.LBB0_220:
	leaq	.L.str.101(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_221:
	movl	$1702257011, %ecx               # imm = 0x65766173
	movl	(%rbx), %eax
	xorl	%ecx, %eax
	movzwl	4(%rbx), %edx
	xorl	$25714, %edx                    # imm = 0x6472
	orl	%eax, %edx
	jne	.LBB0_223
# %bb.222:
	cmpb	$61, 6(%rbx)
	movq	%rbx, %rax
	je	.LBB0_230
.LBB0_223:
	leaq	-7(%r13), %rdx
	xorl	%eax, %eax
	movabsq	$4294976512, %rsi               # imm = 0x100002400
	jmp	.LBB0_225
	.p2align	4
.LBB0_224:                              #   in Loop: Header=BB0_225 Depth=1
	incq	%rax
	cmpq	%rax, %rdx
	je	.LBB0_285
.LBB0_225:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%rbx,%rax), %edi
	cmpq	$32, %rdi
	ja	.LBB0_224
# %bb.226:                              #   in Loop: Header=BB0_225 Depth=1
	btq	%rdi, %rsi
	jae	.LBB0_224
# %bb.227:                              #   in Loop: Header=BB0_225 Depth=1
	movl	1(%rbx,%rax), %edi
	xorl	%ecx, %edi
	movzwl	5(%rbx,%rax), %r8d
	xorl	$25714, %r8d                    # imm = 0x6472
	orl	%edi, %r8d
	jne	.LBB0_224
# %bb.228:                              #   in Loop: Header=BB0_225 Depth=1
	cmpb	$61, 7(%rbx,%rax)
	jne	.LBB0_224
# %bb.229:
	addq	%rbx, %rax
	incq	%rax
.LBB0_230:
	movzbl	7(%rax), %edi
	testb	%dil, %dil
	je	.LBB0_332
# %bb.231:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_232:                              # =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	.LBB0_234
# %bb.233:                              #   in Loop: Header=BB0_232 Depth=1
	addl	$-48, %esi
	jmp	.LBB0_238
	.p2align	4
.LBB0_234:                              #   in Loop: Header=BB0_232 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	.LBB0_236
# %bb.235:                              #   in Loop: Header=BB0_232 Depth=1
	addl	$-87, %esi
	jmp	.LBB0_238
	.p2align	4
.LBB0_236:                              #   in Loop: Header=BB0_232 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	.LBB0_244
# %bb.237:                              #   in Loop: Header=BB0_232 Depth=1
	addl	$-55, %esi
.LBB0_238:                              #   in Loop: Header=BB0_232 Depth=1
	testl	%esi, %esi
	js	.LBB0_244
# %bb.239:                              #   in Loop: Header=BB0_232 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	8(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	.LBB0_232
	jmp	.LBB0_245
.LBB0_240:
	cmpq	$6, %rax
	jae	.LBB0_339
# %bb.241:
	movq	32(%r14), %rbx
.LBB0_242:
	subq	$8, %rsp
	leaq	248(%rsp), %rdi
	movq	56(%rsp), %rsi                  # 8-byte Reload
	movq	%rbx, %r9
	pushq	40(%rsp)                        # 8-byte Folded Reload
	pushq	104(%rsp)                       # 8-byte Folded Reload
	pushq	%r13
	pushq	%r12
	movq	96(%rsp), %r12                  # 8-byte Reload
	pushq	%r12
	pushq	%r15
	movq	72(%rsp), %r15                  # 8-byte Reload
	pushq	%r15
	callq	install_bootable_layout
	addq	$64, %rsp
	movq	(%r14), %rdi
	movq	240(%rsp), %rbx
	movq	248(%rsp), %rdx
	movq	%rbx, %rsi
	callq	write_file
	movq	%rbx, %rdi
	callq	free@PLT
	movq	%r15, %rdi
	callq	free@PLT
	movq	%r12, %rdi
	callq	free@PLT
	movq	%rbp, %rdi
	callq	free@PLT
	movq	%r13, %rdi
	callq	free@PLT
.LBB0_243:
	movq	%r14, %rdi
	jmp	.LBB0_269
.LBB0_244:
	testl	%edx, %edx
	je	.LBB0_332
.LBB0_245:
	testl	%ecx, %ecx
	je	.LBB0_328
# %bb.246:
	leaq	.L.str.102(%rip), %rsi
	leaq	144(%rsp), %rdi
	movl	$1, %edx
	callq	status_hex_tuple_part
	testl	%eax, %eax
	je	.LBB0_328
# %bb.247:
	movl	$6, %eax
	movl	$1768841584, %ecx               # imm = 0x696E6170
	.p2align	4
.LBB0_248:                              # =>This Inner Loop Header: Depth=1
	movl	-6(%rbx,%rax), %edx
	xorl	%ecx, %edx
	movzwl	-2(%rbx,%rax), %esi
	xorl	$15715, %esi                    # imm = 0x3D63
	orl	%edx, %esi
	je	.LBB0_274
# %bb.249:                              #   in Loop: Header=BB0_248 Depth=1
	incq	%rax
	cmpq	%r13, %rax
	jbe	.LBB0_248
.LBB0_250:
	movq	%rbx, %rdi
	callq	free@PLT
.LBB0_251:
	movq	280(%rsp), %rbx
	testq	%rbx, %rbx
	movl	24(%rsp), %ebp                  # 4-byte Reload
	je	.LBB0_262
# %bb.252:
	movq	%rbx, %rdi
	callq	read_file
	testq	%rax, %rax
	je	.LBB0_262
# %bb.253:
	cmpq	$11, %rdx
	jb	.LBB0_257
# %bb.254:
	movabsq	$8746391181324018023, %rcx      # imm = 0x79616C70656D6167
	movl	$11, %esi
	movabsq	$5426623667539570789, %rdi      # imm = 0x4B4F3D79616C7065
	.p2align	4
.LBB0_255:                              # =>This Inner Loop Header: Depth=1
	movq	-11(%rax,%rsi), %r8
	xorq	%rcx, %r8
	movq	-8(%rax,%rsi), %r9
	xorq	%rdi, %r9
	orq	%r8, %r9
	je	.LBB0_258
# %bb.256:                              #   in Loop: Header=BB0_255 Depth=1
	incq	%rsi
	cmpq	%rdx, %rsi
	jbe	.LBB0_255
.LBB0_257:
	leaq	.L.str.107(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_258:
	movl	$6, %ecx
	movl	$1768841584, %esi               # imm = 0x696E6170
	.p2align	4
.LBB0_259:                              # =>This Inner Loop Header: Depth=1
	movl	-6(%rax,%rcx), %edi
	xorl	%esi, %edi
	movzwl	-2(%rax,%rcx), %r8d
	xorl	$15715, %r8d                    # imm = 0x3D63
	orl	%edi, %r8d
	je	.LBB0_270
# %bb.260:                              #   in Loop: Header=BB0_259 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	.LBB0_259
.LBB0_261:
	movq	%rax, %rdi
	callq	free@PLT
.LBB0_262:
	cmpl	$0, 292(%rsp)
	je	.LBB0_264
# %bb.263:
	movq	%r15, %rdi
	callq	check_dynamic_fat_status
	movl	%eax, %ebx
	movq	%r12, %rdi
	callq	check_dynamic_fat_status
	orl	%ebx, %eax
	je	.LBB0_331
.LBB0_264:
	leaq	.Lstr(%rip), %rdi
	callq	puts@PLT
	leaq	.L.str.55(%rip), %rdi
	movq	72(%rsp), %rsi                  # 8-byte Reload
	xorl	%eax, %eax
	callq	printf@PLT
	testl	%ebp, %ebp
	leaq	.L.str.58(%rip), %rax
	leaq	.L.str.57(%rip), %rsi
	cmoveq	%rax, %rsi
	leaq	.L.str.56(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	48(%rsp), %r12                  # 8-byte Reload
	testq	%r12, %r12
	je	.LBB0_267
# %bb.265:
	leaq	.L.str.59(%rip), %rbx
	xorl	%r15d, %r15d
	.p2align	4
.LBB0_266:                              # =>This Inner Loop Header: Depth=1
	movl	296(%rsp,%r15,4), %esi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	incq	%r15
	cmpq	%r15, %r12
	jne	.LBB0_266
.LBB0_267:
	leaq	.Lstr.514(%rip), %rdi
	callq	puts@PLT
	movq	%r14, %rdi
	callq	free@PLT
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	free@PLT
	movq	8(%rsp), %rdi                   # 8-byte Reload
.LBB0_268:
	callq	free@PLT
	movq	96(%rsp), %rdi                  # 8-byte Reload
.LBB0_269:
	callq	free@PLT
	xorl	%eax, %eax
	addq	$131336, %rsp                   # imm = 0x20108
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB0_270:
	movl	$10, %ecx
	movabsq	$5714572474359636336, %rsi      # imm = 0x4F4E3D63696E6170
	.p2align	4
.LBB0_271:                              # =>This Inner Loop Header: Depth=1
	movq	-10(%rax,%rcx), %rdi
	xorq	%rsi, %rdi
	movzwl	-2(%rax,%rcx), %r8d
	xorq	$17742, %r8                     # imm = 0x454E
	orq	%rdi, %r8
	je	.LBB0_261
# %bb.272:                              #   in Loop: Header=BB0_271 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	.LBB0_271
# %bb.273:
	leaq	.L.str.108(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_274:
	movl	$10, %eax
	movabsq	$5714572474359636336, %rcx      # imm = 0x4F4E3D63696E6170
	.p2align	4
.LBB0_275:                              # =>This Inner Loop Header: Depth=1
	movq	-10(%rbx,%rax), %rdx
	xorq	%rcx, %rdx
	movzwl	-2(%rbx,%rax), %esi
	xorq	$17742, %rsi                    # imm = 0x454E
	orq	%rdx, %rsi
	je	.LBB0_250
# %bb.276:                              #   in Loop: Header=BB0_275 Depth=1
	incq	%rax
	cmpq	%r13, %rax
	jbe	.LBB0_275
# %bb.277:
	leaq	.L.str.106(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_278:
	callq	main.cold.37
.LBB0_279:
	callq	main.cold.26
.LBB0_280:
	callq	main.cold.27
.LBB0_281:
	callq	main.cold.28
.LBB0_282:
	callq	main.cold.33
.LBB0_283:
	callq	main.cold.24
.LBB0_284:
	callq	main.cold.43
.LBB0_285:
	callq	main.cold.46
.LBB0_286:
	callq	main.cold.16
.LBB0_287:
	leaq	.L.str.147(%rip), %rsi
	movq	%r13, %rdi
	callq	die_path
.LBB0_288:
	leaq	.L.str.149(%rip), %rsi
	movq	%r13, %rdi
	callq	die_path
.LBB0_289:
	leaq	.L.str.150(%rip), %rsi
	movq	%r13, %rdi
	callq	die_path
.LBB0_290:
	leaq	.L.str.148(%rip), %rsi
	movq	%r13, %rdi
	callq	die_path
.LBB0_291:
	callq	main.cold.41
.LBB0_292:
	callq	main.cold.45
.LBB0_293:
	callq	main.cold.38
.LBB0_294:
	callq	main.cold.44
.LBB0_295:
	callq	main.cold.8
.LBB0_296:
	movq	40(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 280(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 272(%rsp)
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 264(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 256(%rsp)
	leaq	.L.str.49(%rip), %rdi
	callq	die
.LBB0_297:
	callq	main.cold.40
.LBB0_298:
	callq	main.cold.39
.LBB0_299:
	callq	main.cold.42
.LBB0_300:
	callq	main.cold.23
.LBB0_301:
	callq	main.cold.49
.LBB0_302:
	callq	main.cold.17
.LBB0_303:
	callq	main.cold.19
.LBB0_304:
	callq	main.cold.9
.LBB0_305:
	callq	main.cold.21
.LBB0_306:
	callq	main.cold.22
.LBB0_307:
	callq	main.cold.11
.LBB0_308:
	callq	main.cold.13
.LBB0_309:
	callq	main.cold.14
.LBB0_310:
	callq	main.cold.15
.LBB0_311:
	callq	main.cold.18
.LBB0_312:
	callq	main.cold.20
.LBB0_313:
	callq	main.cold.25
.LBB0_314:
	leaq	.L.str.61(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_315:
	leaq	.L.str.62(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_316:
	leaq	.L.str.63(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_317:
	leaq	.L.str.64(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_318:
	leaq	.L.str.65(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_319:
	leaq	.L.str.66(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_320:
	callq	main.cold.32
.LBB0_321:
	callq	main.cold.30
.LBB0_322:
	callq	main.cold.4
.LBB0_323:
	callq	main.cold.1
.LBB0_324:
	callq	main.cold.6
.LBB0_325:
	callq	main.cold.7
.LBB0_326:
	callq	main.cold.10
.LBB0_327:
	callq	main.cold.12
.LBB0_328:
	leaq	.L.str.103(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_329:
	callq	main.cold.34
.LBB0_330:
	callq	main.cold.36
.LBB0_331:
	callq	main.cold.48
.LBB0_332:
	callq	main.cold.47
.LBB0_333:
	callq	main.cold.2
.LBB0_334:
	callq	main.cold.3
.LBB0_335:
	callq	main.cold.5
.LBB0_336:
	movq	40(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 280(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 272(%rsp)
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 264(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 256(%rsp)
	leaq	.L.str.52(%rip), %rdi
	callq	die
.LBB0_337:
	callq	main.cold.35
.LBB0_338:
	callq	main.cold.31
.LBB0_339:
	callq	main.cold.29
.LBB0_340:
	movq	40(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 280(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 272(%rsp)
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 264(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 256(%rsp)
	leaq	.L.str.50(%rip), %rdi
	callq	die
.LBB0_341:
	movq	40(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 280(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 272(%rsp)
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 264(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 256(%rsp)
	leaq	.L.str.51(%rip), %rdi
	callq	die
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker
	.type	mutate_root_marker,@function
mutate_root_marker:                     # @mutate_root_marker
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$131112, %rsp                   # imm = 0x20028
	movl	%ecx, %ebp
	movq	%rdx, %r15
	movq	%rsi, %r12
	movq	%rdi, %rbx
	callq	read_file
	cmpq	$67108864, %rdx                 # imm = 0x4000000
	jne	.LBB1_27
# %bb.1:
	movq	%rax, %r14
	movq	%rax, 24(%rsp)
	movq	$67108864, 32(%rsp)             # imm = 0x4000000
	leaq	40(%rsp), %rdi
	leaq	1049088(%rax), %rsi
	movl	$131072, %edx                   # imm = 0x20000
	callq	memcpy@PLT
	leaq	.L.str.37(%rip), %rsi
	movq	%r12, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB1_2
# %bb.8:
	leaq	.L.str.38(%rip), %rsi
	movq	%r12, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB1_9
# %bb.10:
	leaq	.L.str.39(%rip), %rsi
	movq	%r12, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB1_12
# %bb.11:
	movabsq	$2328718701962022732, %rax      # imm = 0x2051455244414F4C
	jmp	.LBB1_3
.LBB1_2:
	movabsq	$2329578481653007696, %rax      # imm = 0x2054534953524550
	jmp	.LBB1_3
.LBB1_9:
	movabsq	$2328718701980172627, %rax      # imm = 0x2051455245564153
.LBB1_3:
	movq	%rax, (%rsp)
	movl	$1263026976, 7(%rsp)            # imm = 0x4B484320
	leaq	1311232(%r14), %r12
	movq	$-28, %rax
	jmp	.LBB1_4
	.p2align	4
.LBB1_7:                                #   in Loop: Header=BB1_4 Depth=1
	addq	$-32, %rax
	addq	$32, %r12
	cmpq	$-16412, %rax                   # imm = 0xBFE4
	je	.LBB1_20
.LBB1_4:                                # =>This Inner Loop Header: Depth=1
	movzbl	(%r12), %ecx
	cmpl	$229, %ecx
	je	.LBB1_7
# %bb.5:                                #   in Loop: Header=BB1_4 Depth=1
	testl	%ecx, %ecx
	je	.LBB1_20
# %bb.6:                                #   in Loop: Header=BB1_4 Depth=1
	movq	(%r12), %rcx
	xorq	(%rsp), %rcx
	movq	3(%r12), %rdx
	xorq	3(%rsp), %rdx
	orq	%rcx, %rdx
	jne	.LBB1_7
# %bb.13:
	movl	%ebp, 12(%rsp)                  # 4-byte Spill
	movq	%r15, 16(%rsp)                  # 8-byte Spill
	negq	%rax
	cmpq	$16385, %rax                    # imm = 0x4001
	jae	.LBB1_28
# %bb.14:
	movzwl	26(%r12), %r15d
	movq	%r14, %r13
	addq	$1325568, %r13                  # imm = 0x143A00
	movl	$65537, %ebp                    # imm = 0x10001
	.p2align	4
.LBB1_15:                               # =>This Inner Loop Header: Depth=1
	cmpw	$2, %r15w
	jb	.LBB1_19
# %bb.16:                               #   in Loop: Header=BB1_15 Depth=1
	decl	%ebp
	je	.LBB1_19
# %bb.17:                               #   in Loop: Header=BB1_15 Depth=1
	movzwl	%r15w, %edi
	movl	%edi, %eax
	movzwl	40(%rsp,%rax,2), %r15d
	movw	$0, 40(%rsp,%rax,2)
	leal	-64241(%rdi), %eax
	cmpl	$-64240, %eax                   # imm = 0xFFFF0510
	jbe	.LBB1_29
# %bb.18:                               #   in Loop: Header=BB1_15 Depth=1
	shll	$10, %edi
	addq	%r13, %rdi
	movl	$1024, %edx                     # imm = 0x400
	xorl	%esi, %esi
	callq	memset@PLT
	cmpw	$-8, %r15w
	jb	.LBB1_15
.LBB1_19:
	xorps	%xmm0, %xmm0
	movups	%xmm0, 16(%r12)
	movups	%xmm0, 1(%r12)
	movb	$-27, (%r12)
	movq	16(%rsp), %r15                  # 8-byte Reload
	movl	12(%rsp), %ebp                  # 4-byte Reload
.LBB1_20:
	testl	%ebp, %ebp
	je	.LBB1_22
# %bb.21:
	movq	%r15, %rdi
	callq	strlen@PLT
	leaq	24(%rsp), %rdi
	movq	%rsp, %rsi
	movl	$1, %edx
	movq	%r15, %rcx
	movq	%rax, %r8
	movl	$32, %r9d
	callq	write_file_path
	movq	24(%rsp), %r14
.LBB1_22:
	movl	$-8, 40(%rsp)
	movl	$524552, %eax                   # imm = 0x80108
	.p2align	4
.LBB1_23:                               # =>This Inner Loop Header: Depth=1
	movups	-1049064(%rsp,%rax,2), %xmm0
	movups	-1049048(%rsp,%rax,2), %xmm1
	movups	%xmm0, -16(%r14,%rax,2)
	movups	%xmm1, (%r14,%rax,2)
	addq	$16, %rax
	cmpq	$590088, %rax                   # imm = 0x90108
	jne	.LBB1_23
# %bb.24:
	movl	$590088, %eax                   # imm = 0x90108
	.p2align	4
.LBB1_25:                               # =>This Inner Loop Header: Depth=1
	movups	-1180136(%rsp,%rax,2), %xmm0
	movups	-1180120(%rsp,%rax,2), %xmm1
	movups	%xmm0, -16(%r14,%rax,2)
	movups	%xmm1, (%r14,%rax,2)
	addq	$16, %rax
	cmpq	$655624, %rax                   # imm = 0xA0108
	jne	.LBB1_25
# %bb.26:
	movq	32(%rsp), %rdx
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	write_file
	movq	%r14, %rdi
	addq	$131112, %rsp                   # imm = 0x20028
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	jmp	free@PLT                        # TAILCALL
.LBB1_29:
	callq	mutate_root_marker.cold.2
.LBB1_27:
	leaq	.L.str.30(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB1_12:
	callq	mutate_root_marker.cold.1
.LBB1_28:
	callq	mutate_root_marker.cold.3
.Lfunc_end1:
	.size	mutate_root_marker, .Lfunc_end1-mutate_root_marker
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
	leaq	.L.str.128(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end2:
	.size	die, .Lfunc_end2-die
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function install_bootable_layout
.LCPI3_0:
	.byte	128                             # 0x80
	.byte	1                               # 0x1
	.byte	1                               # 0x1
	.byte	0                               # 0x0
	.byte	6                               # 0x6
	.byte	254                             # 0xfe
	.byte	255                             # 0xff
	.byte	255                             # 0xff
	.byte	0                               # 0x0
	.byte	8                               # 0x8
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	248                             # 0xf8
	.byte	1                               # 0x1
	.byte	0                               # 0x0
.LCPI3_1:
	.byte	0                               # 0x0
	.byte	2                               # 0x2
	.byte	2                               # 0x2
	.byte	1                               # 0x1
	.byte	0                               # 0x0
	.byte	2                               # 0x2
	.byte	0                               # 0x0
	.byte	2                               # 0x2
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	248                             # 0xf8
	.byte	0                               # 0x0
	.byte	1                               # 0x1
	.byte	63                              # 0x3f
	.byte	0                               # 0x0
	.byte	16                              # 0x10
.LCPI3_2:
	.byte	0                               # 0x0
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	4                               # 0x4
	.byte	5                               # 0x5
	.byte	6                               # 0x6
	.byte	7                               # 0x7
	.byte	8                               # 0x8
	.byte	9                               # 0x9
	.byte	10                              # 0xa
	.byte	11                              # 0xb
	.byte	12                              # 0xc
	.byte	13                              # 0xd
	.byte	14                              # 0xe
	.byte	15                              # 0xf
.LCPI3_3:
	.zero	16,16
.LCPI3_4:
	.zero	16,63
.LCPI3_5:
	.zero	16,48
.LCPI3_6:
	.zero	16,32
.LCPI3_7:
	.zero	16,96
.LCPI3_8:
	.zero	16,64
.LCPI3_9:
	.zero	16,80
.LCPI3_10:
	.zero	16,112
.LCPI3_11:
	.zero	16,128
.LCPI3_12:
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	192                             # 0xc0
	.byte	255                             # 0xff
	.byte	192                             # 0xc0
	.byte	255                             # 0xff
	.byte	64                              # 0x40
	.byte	0                               # 0x0
	.byte	192                             # 0xc0
	.byte	255                             # 0xff
	.byte	64                              # 0x40
	.byte	0                               # 0x0
	.byte	64                              # 0x40
	.byte	0                               # 0x0
	.byte	192                             # 0xc0
	.byte	255                             # 0xff
.LCPI3_13:
	.byte	0                               # 0x0
	.byte	128                             # 0x80
	.byte	255                             # 0xff
	.byte	128                             # 0x80
	.byte	255                             # 0xff
	.byte	2                               # 0x2
	.byte	0                               # 0x0
	.byte	2                               # 0x2
	.byte	0                               # 0x0
	.byte	8                               # 0x8
	.byte	0                               # 0x0
	.byte	8                               # 0x8
	.byte	0                               # 0x0
	.byte	8                               # 0x8
	.byte	0                               # 0x0
	.byte	8                               # 0x8
.LCPI3_14:
	.byte	16                              # 0x10
	.byte	17                              # 0x11
	.byte	18                              # 0x12
	.byte	19                              # 0x13
	.byte	20                              # 0x14
	.byte	21                              # 0x15
	.byte	22                              # 0x16
	.byte	23                              # 0x17
	.byte	24                              # 0x18
	.byte	25                              # 0x19
	.byte	26                              # 0x1a
	.byte	27                              # 0x1b
	.byte	28                              # 0x1c
	.byte	29                              # 0x1d
	.byte	30                              # 0x1e
	.byte	31                              # 0x1f
.LCPI3_15:
	.long	1                               # 0x1
	.long	1                               # 0x1
	.long	1                               # 0x1
	.long	1                               # 0x1
	.text
	.p2align	4
	.type	install_bootable_layout,@function
install_bootable_layout:                # @install_bootable_layout
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$15560, %rsp                    # imm = 0x3CC8
	movq	%r8, %r12
	movq	%rcx, %r14
	movq	%rsi, %r8
	movq	%rdi, %rbp
	testq	%rdx, %rdx
	setne	%al
	testq	%rcx, %rcx
	setne	%cl
	xorl	%esi, %esi
	movq	%rdx, %rdi
	orq	%r14, %rdi
	sete	%sil
	andb	%al, %cl
	testq	%r12, %r12
	movzbl	%cl, %eax
	cmovel	%esi, %eax
	testb	%al, %al
	je	.LBB3_529
# %bb.1:
	movl	15664(%rsp), %eax
	xorps	%xmm0, %xmm0
	movups	%xmm0, 232(%rsp)
	movups	%xmm0, 216(%rsp)
	movups	%xmm0, 200(%rsp)
	movups	%xmm0, 184(%rsp)
	movq	$0, 248(%rsp)
	movl	%eax, 176(%rsp)
	xorl	%eax, %eax
	testq	%r8, %r8
	setne	%al
	movl	%eax, 180(%rsp)
	movq	(%rbp), %rbx
	testq	%rdx, %rdx
	movq	%r8, 32(%rsp)                   # 8-byte Spill
	movq	%r9, 368(%rsp)                  # 8-byte Spill
	je	.LBB3_6
# %bb.2:
	movq	%r12, %r13
	movq	%rdx, %r15
	movq	%rdx, %rdi
	callq	read_file
	cmpq	$512, %rdx                      # imm = 0x200
	jne	.LBB3_540
# %bb.3:
	movq	%rax, %r12
	movl	$512, %r15d                     # imm = 0x200
	movl	$512, %edx                      # imm = 0x200
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	memcpy@PLT
	movq	%r12, %rdi
	callq	free@PLT
	movq	%r14, %rdi
	callq	read_file
	cmpq	$8193, %rdx                     # imm = 0x2001
	jae	.LBB3_541
# %bb.4:
	movq	%rax, %r14
	addq	(%rbp), %r15
	movq	%r15, %rdi
	movq	%rax, %rsi
	callq	memcpy@PLT
	movq	%r14, %rdi
	callq	free@PLT
	movq	%r13, %r12
	movq	%r13, %rdi
	callq	read_file
	cmpq	$163841, %rdx                   # imm = 0x28001
	jae	.LBB3_542
# %bb.5:
	movq	%rax, %r14
	movl	$8704, %edi                     # imm = 0x2200
	addq	(%rbp), %rdi
	movq	%rax, %rsi
	callq	memcpy@PLT
	movq	%r14, %rdi
	callq	free@PLT
	movq	32(%rsp), %r8                   # 8-byte Reload
	jmp	.LBB3_7
.LBB3_6:
	movw	$15595, (%rbx)                  # imm = 0x3CEB
	movb	$-112, 2(%rbx)
.LBB3_7:
	testq	%r8, %r8
	sete	%al
	movl	$1146310486, 440(%rbx)          # imm = 0x44534F56
	movaps	.LCPI3_0(%rip), %xmm0           # xmm0 = [128,1,1,0,6,254,255,255,0,8,0,0,0,248,1,0]
	movups	%xmm0, 446(%rbx)
	movw	$-21931, 510(%rbx)              # imm = 0xAA55
	movq	(%rbp), %rcx
	movw	$15595, 1048576(%rcx)           # imm = 0x3CEB
	movb	$-112, 1048578(%rcx)
	movabsq	$2314941808397928790, %rdx      # imm = 0x2020534F45424956
	movq	%rdx, 1048579(%rcx)
	movaps	.LCPI3_1(%rip), %xmm0           # xmm0 = [0,2,2,1,0,2,0,2,0,0,248,0,1,63,0,16]
	movups	%xmm0, 1048587(%rcx)
	movabsq	$141863388262694912, %rdx       # imm = 0x1F8000000080000
	movq	%rdx, 1048603(%rcx)
	movw	$-32768, 1048611(%rcx)          # imm = 0x8000
	movl	$218104105, 1048614(%rcx)       # imm = 0xD000129
	movb	$-48, 1048618(%rcx)
	movabsq	$6278109480483965270, %rdx      # imm = 0x5720534F45424956
	movq	%rdx, 1048619(%rcx)
	movl	$541344087, 1048626(%rcx)       # imm = 0x20444157
	movabsq	$2314885625596363078, %rdx      # imm = 0x2020203631544146
	movq	%rdx, 1048630(%rcx)
	movw	$-21931, 1049086(%rcx)          # imm = 0xAA55
	cmpl	$0, 15664(%rsp)
	sete	%cl
	orb	%al, %cl
	movq	%rbp, 48(%rsp)                  # 8-byte Spill
	jne	.LBB3_9
# %bb.8:
	leaq	.L.str.309(%rip), %rsi
	movq	%r8, %rdi
	callq	reject_repo_local_external_asset
	movq	32(%rsp), %r8                   # 8-byte Reload
	jmp	.LBB3_10
.LBB3_9:
	testq	%r8, %r8
	je	.LBB3_275
.LBB3_10:
	movq	%r8, %rdi
	callq	read_file
	cmpq	$5242881, %rdx                  # imm = 0x500001
	jae	.LBB3_536
# %bb.11:
	cmpq	$11, %rdx
	jbe	.LBB3_537
# %bb.12:
	movq	%rax, %rbx
	cmpl	$1145132873, (%rax)             # imm = 0x44415749
	je	.LBB3_14
# %bb.13:
	cmpl	$1145132880, (%rbx)             # imm = 0x44415750
	jne	.LBB3_544
.LBB3_14:
	movl	4(%rbx), %eax
	testq	%rax, %rax
	je	.LBB3_538
# %bb.15:
	movq	%rdx, %r8
	movl	8(%rbx), %ecx
	shlq	$4, %rax
	leaq	(%rax,%rcx), %rdx
	cmpq	%r8, %rdx
	ja	.LBB3_539
# %bb.16:
	addq	%rbx, %rcx
	addq	$4, %rcx
	xorl	%edx, %edx
	jmp	.LBB3_19
	.p2align	4
.LBB3_17:                               #   in Loop: Header=BB3_19 Depth=1
	cmpq	%rsi, %r8
	jb	.LBB3_505
.LBB3_18:                               #   in Loop: Header=BB3_19 Depth=1
	addq	$16, %rdx
	cmpq	%rdx, %rax
	je	.LBB3_22
.LBB3_19:                               # =>This Inner Loop Header: Depth=1
	movl	-4(%rcx,%rdx), %esi
	movl	(%rcx,%rdx), %edi
	testq	%rdi, %rdi
	je	.LBB3_17
# %bb.20:                               #   in Loop: Header=BB3_19 Depth=1
	addq	%rsi, %rdi
	cmpq	%r8, %rdi
	jbe	.LBB3_18
# %bb.21:
	leaq	.L.str.326(%rip), %rsi
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB3_22:
	movq	%r8, %rdx
.LBB3_23:
	movq	%rdx, 184(%rsp)
	movl	$0, 96(%rsp)
	leaq	96(%rsp), %rcx
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%rdx, %r13
	callq	write_cluster_chain
	cmpl	$2, %eax
	jne	.LBB3_530
# %bb.24:
	movq	15632(%rsp), %r14
	movq	15616(%rsp), %r15
	movq	(%rbp), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_25:                               # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_27
# %bb.26:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	jne	.LBB3_28
.LBB3_27:                               #   in Loop: Header=BB3_25 Depth=1
	movl	%esi, %ecx
.LBB3_28:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	je	.LBB3_47
# %bb.29:                               #   in Loop: Header=BB3_25 Depth=1
	cmpl	$229, %edi
	je	.LBB3_47
# %bb.30:                               #   in Loop: Header=BB3_25 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_32
# %bb.31:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	jne	.LBB3_33
.LBB3_32:                               #   in Loop: Header=BB3_25 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_33:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	je	.LBB3_47
# %bb.34:                               #   in Loop: Header=BB3_25 Depth=1
	cmpl	$229, %edi
	je	.LBB3_47
# %bb.35:                               #   in Loop: Header=BB3_25 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_37
# %bb.36:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	jne	.LBB3_38
.LBB3_37:                               #   in Loop: Header=BB3_25 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_38:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	je	.LBB3_47
# %bb.39:                               #   in Loop: Header=BB3_25 Depth=1
	cmpl	$229, %edi
	je	.LBB3_47
# %bb.40:                               #   in Loop: Header=BB3_25 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_42
# %bb.41:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	jne	.LBB3_43
.LBB3_42:                               #   in Loop: Header=BB3_25 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_43:                               #   in Loop: Header=BB3_25 Depth=1
	testl	%edi, %edi
	je	.LBB3_47
# %bb.44:                               #   in Loop: Header=BB3_25 Depth=1
	cmpl	$229, %edi
	je	.LBB3_47
# %bb.45:                               #   in Loop: Header=BB3_25 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_25
# %bb.46:
	callq	install_bootable_layout.cold.126
.LBB3_47:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_531
# %bb.48:
	shll	$5, %ecx
	xorps	%xmm0, %xmm0
	movups	%xmm0, 12(%rax,%rcx)
	movl	$0, 28(%rax,%rcx)
	movabsq	$2314885604590964548, %rdx      # imm = 0x202020314D4F4F44
	movq	%rdx, (%rax,%rcx)
	movl	$1145132832, 7(%rax,%rcx)       # imm = 0x44415720
	movb	$32, 11(%rax,%rcx)
	movw	$2, 26(%rax,%rcx)
	movq	%r13, %rdx
	movb	%dl, 28(%rax,%rcx)
	movb	%dh, 29(%rax,%rcx)
	shrl	$16, %edx
	movb	%dl, 30(%rax,%rcx)
	movb	$0, 31(%rax,%rcx)
	movq	%rbx, %rdi
	callq	free@PLT
	testq	%r12, %r12
	je	.LBB3_50
# %bb.49:
	movq	%r12, %rdi
	callq	read_file
	movq	%rax, %r12
	movq	%rdx, %r8
	leaq	KERNEL_ELF_NAME(%rip), %rsi
	movl	$1, %edx
	movq	%rbp, %rdi
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	write_file_path
	movq	%r12, %rdi
	callq	free@PLT
.LBB3_50:
	movq	368(%rsp), %rdi                 # 8-byte Reload
	testq	%rdi, %rdi
	movq	15624(%rsp), %rbx
	movq	%r14, %r13
	je	.LBB3_52
# %bb.51:
	callq	read_file
	movq	%rax, %r12
	movq	%rdx, %r8
	leaq	USER_PROBE_NAME(%rip), %rsi
	movl	$1, %edx
	movq	%rbp, %rdi
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	write_file_path
	movq	%r12, %rdi
	callq	free@PLT
.LBB3_52:
	testq	%rbx, %rbx
	je	.LBB3_60
# %bb.53:
	movq	208(%rsp), %r12
	movq	216(%rsp), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	leaq	384(%rsp), %rbp
	jmp	.LBB3_55
	.p2align	4
.LBB3_54:                               #   in Loop: Header=BB3_55 Depth=1
	movq	%r14, %rdi
	callq	free@PLT
	addq	$24, %r15
	decq	%rbx
	je	.LBB3_59
.LBB3_55:                               # =>This Inner Loop Header: Depth=1
	movq	16(%r15), %rdi
	callq	read_file
	movq	%rax, %r14
	movq	%rdx, %r8
	movl	7(%r15), %eax
	movl	%eax, 391(%rsp)
	movq	(%r15), %rax
	movq	%rax, 384(%rsp)
	movl	$1, %edx
	movq	48(%rsp), %rdi                  # 8-byte Reload
	movq	%rbp, %rsi
	movq	%r14, %rcx
	movq	%r8, 8(%rsp)                    # 8-byte Spill
	movl	$32, %r9d
	callq	write_file_path
	cmpl	$0, 15664(%rsp)
	je	.LBB3_54
# %bb.56:                               #   in Loop: Header=BB3_55 Depth=1
	movq	%r14, 24(%rsp)                  # 8-byte Spill
	movq	%r15, %rdi
	movq	%rbx, %r13
	movq	%rbp, %rsi
	callq	format_fat_name
	imulq	$104, 16(%rsp), %rbx            # 8-byte Folded Reload
	leaq	104(%rbx), %rsi
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_499
# %bb.57:                               #   in Loop: Header=BB3_55 Depth=1
	leaq	(%rax,%rbx), %rdi
	movl	$96, %esi
	leaq	.L.str.427(%rip), %rdx
	movq	%rax, %r12
	movq	%rbp, %r14
	movq	%rbp, %rcx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$96, %eax
	jae	.LBB3_500
# %bb.58:                               #   in Loop: Header=BB3_55 Depth=1
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 96(%r12,%rbx)
	incq	16(%rsp)                        # 8-byte Folded Spill
	movq	%r13, %rbx
	movq	15632(%rsp), %r13
	movq	%r14, %rbp
	movq	24(%rsp), %r14                  # 8-byte Reload
	jmp	.LBB3_54
.LBB3_59:
	movq	%r12, 208(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 216(%rsp)
	movq	48(%rsp), %rbp                  # 8-byte Reload
.LBB3_60:
	movq	15640(%rsp), %r12
	testq	%r12, %r12
	je	.LBB3_68
# %bb.61:
	movq	224(%rsp), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	movq	232(%rsp), %rax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	leaq	384(%rsp), %rbx
	jmp	.LBB3_63
	.p2align	4
.LBB3_62:                               #   in Loop: Header=BB3_63 Depth=1
	movq	%r14, %rdi
	callq	free@PLT
	addq	$24, %r13
	decq	%r12
	je	.LBB3_67
.LBB3_63:                               # =>This Inner Loop Header: Depth=1
	movq	16(%r13), %rdi
	callq	read_file
	movq	%rax, %r14
	movq	%rdx, %r15
	movl	7(%r13), %eax
	movl	%eax, 391(%rsp)
	movq	(%r13), %rax
	movq	%rax, 384(%rsp)
	movl	$1, %edx
	movq	48(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	movq	%r14, %rcx
	movq	%r15, %r8
	movl	$32, %r9d
	callq	write_file_path
	cmpl	$0, 15664(%rsp)
	je	.LBB3_62
# %bb.64:                               #   in Loop: Header=BB3_63 Depth=1
	movq	%r14, 24(%rsp)                  # 8-byte Spill
	movq	%r12, %r14
	movq	%r13, %rbp
	movq	%r13, %rdi
	movq	%rbx, %rsi
	callq	format_fat_name
	imulq	$104, 8(%rsp), %r12             # 8-byte Folded Reload
	leaq	104(%r12), %rsi
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_501
# %bb.65:                               #   in Loop: Header=BB3_63 Depth=1
	leaq	(%rax,%r12), %rdi
	movl	$96, %esi
	leaq	.L.str.427(%rip), %rdx
	movq	%rbx, %r13
	movq	%rbx, %rcx
	movq	%rax, %rbx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$96, %eax
	jae	.LBB3_502
# %bb.66:                               #   in Loop: Header=BB3_63 Depth=1
	movq	%rbx, 16(%rsp)                  # 8-byte Spill
	movq	%r15, 96(%rbx,%r12)
	incq	8(%rsp)                         # 8-byte Folded Spill
	movq	%r14, %r12
	movq	%r13, %rbx
	movq	%rbp, %r13
	movq	24(%rsp), %r14                  # 8-byte Reload
	jmp	.LBB3_62
.LBB3_67:
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 224(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 232(%rsp)
	movq	48(%rsp), %rbp                  # 8-byte Reload
.LBB3_68:
	movq	$0, 64(%rsp)
	leaq	STATE_DIR_NAME(%rip), %rdx
	movq	%rbp, %rdi
	xorl	%esi, %esi
	movl	$16, %ecx
	callq	ensure_child_directory
	leaq	DEFAULT_PI4_ASSET_README_PATH(%rip), %rdi
	leaq	384(%rsp), %rbx
	leaq	64(%rsp), %r14
	movl	$4, %ecx
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	parse_path83
	movq	64(%rsp), %rdx
	leaq	DEFAULT_PI4_ASSET_README(%rip), %rcx
	movl	$35, %r8d
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movl	$33, %r9d
	callq	write_file_path
	leaq	DEFAULT_PI4_ASSET_MAP_PATH(%rip), %rdi
	movl	$4, %ecx
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	parse_path83
	movq	64(%rsp), %rdx
	leaq	DEFAULT_PI4_ASSET_MAP(%rip), %rcx
	movl	$23, %r8d
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movl	$33, %r9d
	callq	write_file_path
	movaps	.LCPI3_2(%rip), %xmm0           # xmm0 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movaps	%xmm0, 288(%rsp)
	movdqa	.LCPI3_14(%rip), %xmm0          # xmm0 = [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
	movdqa	%xmm0, 304(%rsp)
	leaq	DEFAULT_PI4_ASSET_PALETTE_PATH(%rip), %rdi
	movl	$4, %ecx
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	parse_path83
	movq	64(%rsp), %rdx
	leaq	288(%rsp), %rcx
	movl	$32, %r8d
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movl	$33, %r9d
	callq	write_file_path
	cmpq	$0, 15656(%rsp)
	je	.LBB3_104
# %bb.69:
	movabsq	$2314885530818453536, %rax      # imm = 0x2020202020202020
	leaq	1123369(%rax), %rcx
	movq	%rcx, 16(%rsp)                  # 8-byte Spill
	addq	$271262000, %rax                # imm = 0x102B2130
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	xorl	%r14d, %r14d
	jmp	.LBB3_71
	.p2align	4
.LBB3_70:                               #   in Loop: Header=BB3_71 Depth=1
	incq	%r14
	cmpq	15656(%rsp), %r14
	je	.LBB3_104
.LBB3_71:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_98 Depth 2
	imulq	$104, %r14, %rax
	movq	15648(%rsp), %rcx
	leaq	(%rcx,%rax), %r15
	movq	96(%rcx,%rax), %rbx
	movq	$0, 288(%rsp)
	movl	$8, %ecx
	movq	%r15, %rdi
	leaq	384(%rsp), %rsi
	leaq	288(%rsp), %rdx
	callq	parse_path83
	movq	288(%rsp), %r12
	cmpq	$1, %r12
	jbe	.LBB3_498
# %bb.72:                               #   in Loop: Header=BB3_71 Depth=1
	cmpq	$2, %r12
	movq	%r15, 8(%rsp)                   # 8-byte Spill
	jne	.LBB3_74
# %bb.73:                               #   in Loop: Header=BB3_71 Depth=1
	movq	384(%rsp), %rax
	xorq	16(%rsp), %rax                  # 8-byte Folded Reload
	movq	387(%rsp), %rcx
	movabsq	$2314885530818453536, %rdx      # imm = 0x2020202020202020
	xorq	%rdx, %rcx
	orq	%rax, %rcx
	je	.LBB3_81
.LBB3_74:                               #   in Loop: Header=BB3_71 Depth=1
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, %r13
	movq	%rdx, %r15
	xorl	%ebx, %ebx
.LBB3_75:                               #   in Loop: Header=BB3_71 Depth=1
	movq	%rbp, %rdi
	leaq	384(%rsp), %rsi
	movq	%r12, %rdx
	movq	%r13, %rcx
	movq	%r15, %r8
	movl	$33, %r9d
	callq	write_file_path
	movq	%r13, %rdi
	callq	free@PLT
	testb	%bl, %bl
	je	.LBB3_77
# %bb.76:                               #   in Loop: Header=BB3_71 Depth=1
	movl	$1, 192(%rsp)
	movq	%r15, 200(%rsp)
.LBB3_77:                               #   in Loop: Header=BB3_71 Depth=1
	cmpl	$0, 15664(%rsp)
	je	.LBB3_70
# %bb.78:                               #   in Loop: Header=BB3_71 Depth=1
	movq	240(%rsp), %rdi
	movq	248(%rsp), %r12
	imulq	$104, %r12, %r13
	leaq	104(%r13), %rsi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_503
# %bb.79:                               #   in Loop: Header=BB3_71 Depth=1
	movq	%rax, %rbx
	movq	%rax, 240(%rsp)
	movq	%rax, %rdi
	addq	%r13, %rdi
	movl	$96, %esi
	leaq	.L.str.427(%rip), %rdx
	movq	8(%rsp), %rcx                   # 8-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$96, %eax
	jae	.LBB3_504
# %bb.80:                               #   in Loop: Header=BB3_71 Depth=1
	movq	%r15, 96(%rbx,%r13)
	incq	%r12
	movq	%r12, 248(%rsp)
	jmp	.LBB3_70
.LBB3_81:                               #   in Loop: Header=BB3_71 Depth=1
	movq	395(%rsp), %rax
	xorq	56(%rsp), %rax                  # 8-byte Folded Reload
	movq	398(%rsp), %rcx
	movabsq	$5422703525238939696, %rdx      # imm = 0x4B41502020202030
	xorq	%rdx, %rcx
	xorl	%ebp, %ebp
	orq	%rax, %rcx
	sete	%al
	movl	%eax, 24(%rsp)                  # 4-byte Spill
	setne	%bpl
	cmpl	$0, 15664(%rsp)
	je	.LBB3_84
# %bb.82:                               #   in Loop: Header=BB3_71 Depth=1
	testl	%ebp, %ebp
	jne	.LBB3_84
# %bb.83:                               #   in Loop: Header=BB3_71 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.430(%rip), %rsi
	callq	reject_repo_local_external_asset
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, %r13
	movq	%rdx, %r15
	jmp	.LBB3_86
.LBB3_84:                               #   in Loop: Header=BB3_71 Depth=1
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, %r13
	movq	%rdx, %r15
	testl	%ebp, %ebp
	je	.LBB3_86
# %bb.85:                               #   in Loop: Header=BB3_71 Depth=1
	xorl	%ebx, %ebx
	movq	48(%rsp), %rbp                  # 8-byte Reload
	jmp	.LBB3_75
.LBB3_86:                               #   in Loop: Header=BB3_71 Depth=1
	cmpq	$11, %r15
	jbe	.LBB3_526
# %bb.87:                               #   in Loop: Header=BB3_71 Depth=1
	cmpl	$1262698832, (%r13)             # imm = 0x4B434150
	movq	48(%rsp), %rbp                  # 8-byte Reload
	jne	.LBB3_527
# %bb.88:                               #   in Loop: Header=BB3_71 Depth=1
	movl	8(%r13), %eax
	testq	%rax, %rax
	je	.LBB3_528
# %bb.89:                               #   in Loop: Header=BB3_71 Depth=1
	movl	%eax, %ecx
	andl	$63, %ecx
	jne	.LBB3_528
# %bb.90:                               #   in Loop: Header=BB3_71 Depth=1
	movl	4(%r13), %ecx
	leaq	(%rax,%rcx), %rdx
	cmpq	%r15, %rdx
	ja	.LBB3_525
# %bb.91:                               #   in Loop: Header=BB3_71 Depth=1
	leaq	60(%rcx), %rdx
	cmpq	%r15, %rdx
	ja	.LBB3_496
# %bb.92:                               #   in Loop: Header=BB3_71 Depth=1
	leaq	64(%rcx), %rdx
	cmpq	%r15, %rdx
	ja	.LBB3_494
# %bb.93:                               #   in Loop: Header=BB3_71 Depth=1
	cmpb	$0, (%r13,%rcx)
	je	.LBB3_495
# %bb.94:                               #   in Loop: Header=BB3_71 Depth=1
	movl	56(%r13,%rcx), %edx
	movl	60(%r13,%rcx), %esi
	addq	%rdx, %rsi
	cmpq	%r15, %rsi
	ja	.LBB3_493
# %bb.95:                               #   in Loop: Header=BB3_71 Depth=1
	cmpl	$64, %eax
	je	.LBB3_96
# %bb.97:                               #   in Loop: Header=BB3_71 Depth=1
	shrl	$6, %eax
	decq	%rax
	subq	$-128, %rcx
	.p2align	4
.LBB3_98:                               #   Parent Loop BB3_71 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	leaq	-4(%rcx), %rdx
	cmpq	%r15, %rdx
	ja	.LBB3_496
# %bb.99:                               #   in Loop: Header=BB3_98 Depth=2
	cmpq	%r15, %rcx
	ja	.LBB3_494
# %bb.100:                              #   in Loop: Header=BB3_98 Depth=2
	cmpb	$0, -64(%r13,%rcx)
	je	.LBB3_495
# %bb.101:                              #   in Loop: Header=BB3_98 Depth=2
	movl	-8(%r13,%rcx), %edx
	movl	-4(%r13,%rcx), %esi
	addq	%rdx, %rsi
	cmpq	%r15, %rsi
	ja	.LBB3_493
# %bb.102:                              #   in Loop: Header=BB3_98 Depth=2
	addq	$64, %rcx
	decq	%rax
	jne	.LBB3_98
.LBB3_96:                               #   in Loop: Header=BB3_71 Depth=1
	movl	24(%rsp), %ebx                  # 4-byte Reload
	jmp	.LBB3_75
.LBB3_104:
	cmpl	$0, 15664(%rsp)
	je	.LBB3_163
# %bb.105:
	leaq	PI4_KERNEL8_IMG_NAME(%rip), %rdx
	leaq	.L.str.165(%rip), %rcx
	leaq	176(%rsp), %rbx
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	proof_manifest_require_root_file
	leaq	PI4_CONFIG_TXT_NAME(%rip), %rdx
	leaq	.L.str.168(%rip), %rcx
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	proof_manifest_require_root_file
	cmpq	$0, 216(%rsp)
	jne	.LBB3_543
# %bb.106:
	movq	248(%rsp), %r13
	testq	%r13, %r13
	je	.LBB3_110
# %bb.107:
	movq	240(%rsp), %r14
	leaq	PI4_SYSTEM_INIT_PATH(%rip), %rbx
	movq	%r14, %r15
	movq	%r13, %r12
	.p2align	4
.LBB3_108:                              # =>This Inner Loop Header: Depth=1
	movq	%r15, %rdi
	movq	%rbx, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB3_111
# %bb.109:                              #   in Loop: Header=BB3_108 Depth=1
	addq	$104, %r15
	decq	%r12
	jne	.LBB3_108
.LBB3_110:
	callq	install_bootable_layout.cold.115
.LBB3_111:
	cmpq	$0, 96(%r15)
	je	.LBB3_110
# %bb.112:
	leaq	PI4_SYSTEM_ABIPROBE_PATH(%rip), %rbx
	movq	%r14, %r12
	movq	%r13, %rbp
	.p2align	4
.LBB3_113:                              # =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	movq	%rbx, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB3_116
# %bb.114:                              #   in Loop: Header=BB3_113 Depth=1
	addq	$104, %r12
	decq	%rbp
	jne	.LBB3_113
.LBB3_115:
	callq	install_bootable_layout.cold.114
.LBB3_116:
	cmpq	$0, 96(%r12)
	je	.LBB3_115
# %bb.117:
	leaq	PI4_APP_INDEX_PATH(%rip), %rbx
	movq	48(%rsp), %rbp                  # 8-byte Reload
	.p2align	4
.LBB3_118:                              # =>This Inner Loop Header: Depth=1
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB3_121
# %bb.119:                              #   in Loop: Header=BB3_118 Depth=1
	addq	$104, %r14
	decq	%r13
	jne	.LBB3_118
.LBB3_120:
	callq	install_bootable_layout.cold.113
.LBB3_121:
	cmpq	$0, 96(%r14)
	je	.LBB3_120
# %bb.122:
	movq	(%rbp), %rax
	movq	%rax, 264(%rsp)
	movq	8(%rbp), %rax
	movq	%rax, 272(%rsp)
	leaq	264(%rsp), %rdi
	leaq	384(%rsp), %rsi
	xorl	%r13d, %r13d
	xorl	%edx, %edx
	callq	load_pi4_app_catalog
	pxor	%xmm0, %xmm0
	movdqa	%xmm0, 64(%rsp)
	movq	$0, 80(%rsp)
	movq	232(%rsp), %rbx
	testq	%rbx, %rbx
	je	.LBB3_131
# %bb.123:
	movq	224(%rsp), %r13
	movq	%r13, 8(%rsp)                   # 8-byte Spill
	movq	%rbx, %rbp
	.p2align	4
.LBB3_124:                              # =>This Inner Loop Header: Depth=1
	movq	%r13, %rdi
	leaq	.L.str.165(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB3_127
# %bb.125:                              #   in Loop: Header=BB3_124 Depth=1
	addq	$104, %r13
	decq	%rbp
	jne	.LBB3_124
# %bb.126:
	xorl	%r13d, %r13d
.LBB3_127:
	movq	8(%rsp), %rbp                   # 8-byte Reload
	.p2align	4
.LBB3_128:                              # =>This Inner Loop Header: Depth=1
	movq	%rbp, %rdi
	leaq	.L.str.168(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB3_132
# %bb.129:                              #   in Loop: Header=BB3_128 Depth=1
	addq	$104, %rbp
	decq	%rbx
	jne	.LBB3_128
.LBB3_131:
	xorl	%ebx, %ebx
	jmp	.LBB3_133
.LBB3_132:
	movq	%rbp, %rbx
.LBB3_133:
	leaq	.L.str.439(%rip), %rsi
	leaq	64(%rsp), %rbp
	movq	%rbp, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.440(%rip), %rsi
	movq	%rbp, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.139(%rip), %rsi
	movq	%rbp, %rdi
	movl	$2561, %edx                     # imm = 0xA01
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.140(%rip), %rsi
	movq	%rbp, %rdi
	movl	$2593, %edx                     # imm = 0xA21
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.141(%rip), %rsi
	movq	%rbp, %rdi
	movl	$512, %edx                      # imm = 0x200
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.441(%rip), %rsi
	leaq	PROOF_MANIFEST_PATH(%rip), %rdx
	movq	%rbp, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	testq	%r13, %r13
	je	.LBB3_136
# %bb.134:
	leaq	.L.str.442(%rip), %rsi
	leaq	64(%rsp), %rbp
	movq	%rbp, %rdi
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r13), %rdx
	leaq	.L.str.443(%rip), %rsi
	movq	%rbp, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	testq	%rbx, %rbx
	je	.LBB3_137
.LBB3_135:
	leaq	.L.str.445(%rip), %rsi
	leaq	64(%rsp), %r13
	movq	%r13, %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%rbx), %rdx
	leaq	.L.str.446(%rip), %rsi
	movq	%r13, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	jmp	.LBB3_138
.LBB3_136:
	leaq	.L.str.444(%rip), %rsi
	leaq	64(%rsp), %rdi
	xorl	%eax, %eax
	callq	text_appendf
	testq	%rbx, %rbx
	jne	.LBB3_135
.LBB3_137:
	leaq	.L.str.447(%rip), %rsi
	leaq	64(%rsp), %rdi
	xorl	%eax, %eax
	callq	text_appendf
.LBB3_138:
	leaq	.L.str.448(%rip), %rsi
	leaq	64(%rsp), %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.449(%rip), %rsi
	leaq	PI4_APP_LAYOUT(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.450(%rip), %rsi
	leaq	PI4_APP_DISCOVERY_MODEL(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.451(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.452(%rip), %rsi
	leaq	PI4_APP_EXEC_MODEL(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.248(%rip), %r13
	leaq	.L.str.177(%rip), %rbp
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%rbp, %rdx
	movq	%r15, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r15), %rcx
	leaq	.L.str.499(%rip), %r15
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.179(%rip), %rbp
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%rbp, %rdx
	movq	%r12, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r12), %rcx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.181(%rip), %r12
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r12, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r14), %rcx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	384(%rsp), %rcx
	leaq	.L.str.453(%rip), %rsi
	leaq	PI4_APP_RECORD_COUNT_KEY(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	cmpq	$0, 384(%rsp)
	je	.LBB3_150
# %bb.139:
	leaq	392(%rsp), %rax
	movq	240(%rsp), %r15
	movq	248(%rsp), %rcx
	movq	%rcx, 8(%rsp)                   # 8-byte Spill
	xorl	%ebp, %ebp
	movq	%r15, 16(%rsp)                  # 8-byte Spill
	.p2align	4
.LBB3_140:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_142 Depth 2
                                        #     Child Loop BB3_146 Depth 2
	imulq	$948, %rbp, %rbx                # imm = 0x3B4
	leaq	(%rax,%rbx), %r12
	addq	$160, %r12
	cmpq	$0, 8(%rsp)                     # 8-byte Folded Reload
	je	.LBB3_490
# %bb.141:                              #   in Loop: Header=BB3_140 Depth=1
	addq	%rax, %rbx
	movq	%r15, %r13
	movq	8(%rsp), %r14                   # 8-byte Reload
	.p2align	4
.LBB3_142:                              #   Parent Loop BB3_140 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%r13, %rdi
	movq	%r12, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB3_144
# %bb.143:                              #   in Loop: Header=BB3_142 Depth=2
	addq	$104, %r13
	decq	%r14
	jne	.LBB3_142
	jmp	.LBB3_490
	.p2align	4
.LBB3_144:                              #   in Loop: Header=BB3_140 Depth=1
	cmpq	$0, 96(%r13)
	je	.LBB3_490
# %bb.145:                              #   in Loop: Header=BB3_140 Depth=1
	leaq	320(%rbx), %r14
	movq	%r15, %r12
	movq	8(%rsp), %r15                   # 8-byte Reload
	.p2align	4
.LBB3_146:                              #   Parent Loop BB3_140 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB3_148
# %bb.147:                              #   in Loop: Header=BB3_146 Depth=2
	addq	$104, %r12
	decq	%r15
	jne	.LBB3_146
	jmp	.LBB3_491
	.p2align	4
.LBB3_148:                              #   in Loop: Header=BB3_140 Depth=1
	cmpq	$0, 96(%r12)
	je	.LBB3_491
# %bb.149:                              #   in Loop: Header=BB3_140 Depth=1
	leaq	64(%rsp), %r14
	movq	%r14, %rdi
	leaq	.L.str.500(%rip), %rsi
	leaq	PI4_APP_RECORD_PREFIX(%rip), %r15
	movq	%r15, %rdx
	movq	%rbp, %rcx
	movq	%rbx, %r8
	xorl	%eax, %eax
	callq	text_appendf
	leaq	64(%rbx), %r8
	movq	%r14, %rdi
	leaq	.L.str.501(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r14, %rdi
	leaq	.L.str.502(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r13), %r8
	movq	%r14, %r13
	movq	%r14, %rdi
	leaq	.L.str.503(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r14, %rdi
	leaq	.L.str.504(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r12), %r8
	movq	%r14, %rdi
	leaq	.L.str.505(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r14, %rdi
	leaq	.L.str.506(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	leaq	PI4_APP_LAUNCH_MODEL(%rip), %r8
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r14, %rdi
	leaq	.L.str.507(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	leaq	PI4_APP_EXEC_MODEL(%rip), %r8
	xorl	%eax, %eax
	callq	text_appendf
	leaq	480(%rbx), %r14
	movq	%r13, %rdi
	leaq	.L.str.508(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	movq	%r14, %r8
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r13, %rdi
	leaq	.L.str.509(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	movq	%r14, %r8
	xorl	%eax, %eax
	callq	text_appendf
	addq	$640, %rbx                      # imm = 0x280
	movq	%r13, %rdi
	leaq	.L.str.510(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	movq	%rbx, %r8
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r13, %rdi
	leaq	.L.str.511(%rip), %rsi
	movq	%r15, %rdx
	movq	%rbp, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	incq	%rbp
	cmpq	384(%rsp), %rbp
	leaq	392(%rsp), %rax
	movq	16(%rsp), %r15                  # 8-byte Reload
	jb	.LBB3_140
.LBB3_150:
	leaq	.L.str.454(%rip), %rsi
	leaq	64(%rsp), %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.455(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.456(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	cmpq	$0, 32(%rsp)                    # 8-byte Folded Reload
	leaq	.L.str.198(%rip), %rax
	leaq	.L.str.201(%rip), %rdx
	cmovneq	%rax, %rdx
	leaq	.L.str.457(%rip), %rsi
	leaq	.L.str.199(%rip), %rax
	leaq	.L.str.202(%rip), %r14
	cmovneq	%rax, %r14
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.458(%rip), %rsi
	movq	%rbx, %rdi
	movq	%r14, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.459(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.460(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	movq	184(%rsp), %rdx
	leaq	.L.str.461(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.462(%rip), %rsi
	movq	%rbx, %rdi
	movl	$3, %edx
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.463(%rip), %rsi
	leaq	DEFAULT_PI4_ASSET_README_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.464(%rip), %rsi
	movl	$35, %edx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.465(%rip), %rsi
	leaq	DEFAULT_PI4_ASSET_MAP_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.466(%rip), %rsi
	movl	$23, %edx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.467(%rip), %rsi
	leaq	DEFAULT_PI4_ASSET_PALETTE_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.468(%rip), %rsi
	movq	%rbx, %rdi
	movl	$32, %edx
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.469(%rip), %rsi
	leaq	PROOF_QUAKE_PAK_PATH(%rip), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.470(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	movl	192(%rsp), %ebp
	testl	%ebp, %ebp
	leaq	.L.str.226(%rip), %rax
	leaq	.L.str.193(%rip), %rdx
	cmoveq	%rax, %rdx
	leaq	.L.str.471(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	testl	%ebp, %ebp
	je	.LBB3_152
# %bb.151:
	leaq	.L.str.472(%rip), %rsi
	leaq	64(%rsp), %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.473(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.474(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.475(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	movq	200(%rsp), %rdx
	leaq	.L.str.476(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	jmp	.LBB3_153
.LBB3_152:
	leaq	.L.str.477(%rip), %rsi
	leaq	64(%rsp), %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.478(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.479(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
	leaq	.L.str.475(%rip), %rsi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	text_appendf
.LBB3_153:
	movq	232(%rsp), %rbx
	leaq	.L.str.480(%rip), %rsi
	leaq	64(%rsp), %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	testq	%rbx, %rbx
	je	.LBB3_156
# %bb.154:
	movq	224(%rsp), %r14
	leaq	.L.str.481(%rip), %r15
	leaq	64(%rsp), %r12
	leaq	.L.str.482(%rip), %r13
	xorl	%ebp, %ebp
	.p2align	4
.LBB3_155:                              # =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	movq	%r15, %rsi
	movq	%rbp, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r14), %rcx
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	incq	%rbp
	addq	$104, %r14
	cmpq	%rbp, %rbx
	jne	.LBB3_155
.LBB3_156:
	movq	216(%rsp), %rbx
	leaq	.L.str.483(%rip), %rsi
	leaq	64(%rsp), %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	testq	%rbx, %rbx
	je	.LBB3_159
# %bb.157:
	movq	208(%rsp), %r14
	leaq	.L.str.484(%rip), %r15
	leaq	64(%rsp), %r12
	leaq	.L.str.485(%rip), %r13
	xorl	%ebp, %ebp
	.p2align	4
.LBB3_158:                              # =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	movq	%r15, %rsi
	movq	%rbp, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r14), %rcx
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	incq	%rbp
	addq	$104, %r14
	cmpq	%rbp, %rbx
	jne	.LBB3_158
.LBB3_159:
	movq	248(%rsp), %rbx
	leaq	.L.str.486(%rip), %rsi
	leaq	64(%rsp), %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	testq	%rbx, %rbx
	leaq	.L.str.199(%rip), %r15
	je	.LBB3_162
# %bb.160:
	movq	240(%rsp), %r14
	leaq	64(%rsp), %r12
	leaq	PROOF_QUAKE_PAK_PATH(%rip), %r13
	xorl	%ebp, %ebp
	.p2align	4
.LBB3_161:                              # =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	leaq	.L.str.487(%rip), %rsi
	movq	%rbp, %rdx
	movq	%r14, %rcx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r14, %rdi
	movq	%r13, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	leaq	.L.str.306(%rip), %rcx
	leaq	.L.str.305(%rip), %rax
	cmoveq	%rax, %rcx
	movq	%r12, %rdi
	leaq	.L.str.488(%rip), %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r12, %rdi
	leaq	.L.str.489(%rip), %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r14, %rdi
	movq	%r13, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	leaq	.L.str.307(%rip), %rcx
	cmoveq	%r15, %rcx
	movq	%r12, %rdi
	leaq	.L.str.490(%rip), %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r12, %rdi
	leaq	.L.str.491(%rip), %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	%r12, %rdi
	leaq	.L.str.492(%rip), %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	movq	96(%r14), %rcx
	movq	%r12, %rdi
	leaq	.L.str.493(%rip), %rsi
	movq	%rbp, %rdx
	xorl	%eax, %eax
	callq	text_appendf
	incq	%rbp
	addq	$104, %r14
	cmpq	%rbp, %rbx
	jne	.LBB3_161
.LBB3_162:
	movq	$0, 104(%rsp)
	leaq	PROOF_MANIFEST_PATH(%rip), %rdi
	leaq	288(%rsp), %rbx
	leaq	104(%rsp), %rdx
	movl	$4, %ecx
	movq	%rbx, %rsi
	callq	parse_path83
	movq	104(%rsp), %rdx
	movq	64(%rsp), %r14
	movq	72(%rsp), %r8
	movq	48(%rsp), %rbp                  # 8-byte Reload
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r14, %rcx
	movl	$33, %r9d
	callq	write_file_path
	movq	%r14, %rdi
	callq	free@PLT
.LBB3_163:
	leaq	DEFAULT_CFG_NAME(%rip), %rsi
	leaq	DEFAULT_CFG_CONTENT(%rip), %rcx
	movl	$1, %edx
	movl	$17, %r8d
	movq	%rbp, %rdi
	movl	$32, %r9d
	callq	write_file_path
	xorl	%eax, %eax
	.p2align	4
.LBB3_164:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_165 Depth 2
	movl	%eax, %ecx
	orb	$48, %cl
	movq	(%rbp), %rdi
	leaq	1311232(%rdi), %rdx
	addq	$1311328, %rdi                  # imm = 0x140260
	xorl	%r8d, %r8d
                                        # implicit-def: $esi
.LBB3_165:                              #   Parent Loop BB3_164 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	-96(%rdi), %r9d
	cmpl	$229, %r9d
	je	.LBB3_167
# %bb.166:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	jne	.LBB3_168
.LBB3_167:                              #   in Loop: Header=BB3_165 Depth=2
	movl	%r8d, %esi
.LBB3_168:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	je	.LBB3_186
# %bb.169:                              #   in Loop: Header=BB3_165 Depth=2
	cmpl	$229, %r9d
	je	.LBB3_186
# %bb.170:                              #   in Loop: Header=BB3_165 Depth=2
	movzbl	-64(%rdi), %r9d
	cmpl	$229, %r9d
	je	.LBB3_172
# %bb.171:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	jne	.LBB3_173
.LBB3_172:                              #   in Loop: Header=BB3_165 Depth=2
	leaq	1(%r8), %rsi
.LBB3_173:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	je	.LBB3_186
# %bb.174:                              #   in Loop: Header=BB3_165 Depth=2
	cmpl	$229, %r9d
	je	.LBB3_186
# %bb.175:                              #   in Loop: Header=BB3_165 Depth=2
	movzbl	-32(%rdi), %r9d
	cmpl	$229, %r9d
	je	.LBB3_177
# %bb.176:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	jne	.LBB3_178
.LBB3_177:                              #   in Loop: Header=BB3_165 Depth=2
	leaq	2(%r8), %rsi
.LBB3_178:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	je	.LBB3_186
# %bb.179:                              #   in Loop: Header=BB3_165 Depth=2
	cmpl	$229, %r9d
	je	.LBB3_186
# %bb.180:                              #   in Loop: Header=BB3_165 Depth=2
	movzbl	(%rdi), %r9d
	cmpl	$229, %r9d
	je	.LBB3_182
# %bb.181:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	jne	.LBB3_183
.LBB3_182:                              #   in Loop: Header=BB3_165 Depth=2
	leaq	3(%r8), %rsi
.LBB3_183:                              #   in Loop: Header=BB3_165 Depth=2
	testl	%r9d, %r9d
	je	.LBB3_186
# %bb.184:                              #   in Loop: Header=BB3_165 Depth=2
	cmpl	$229, %r9d
	je	.LBB3_186
# %bb.185:                              #   in Loop: Header=BB3_165 Depth=2
	addq	$4, %r8
	subq	$-128, %rdi
	cmpq	$512, %r8                       # imm = 0x200
	jne	.LBB3_165
	jmp	.LBB3_492
	.p2align	4
.LBB3_186:                              #   in Loop: Header=BB3_164 Depth=1
	cmpl	$512, %esi                      # imm = 0x200
	jae	.LBB3_497
# %bb.187:                              #   in Loop: Header=BB3_164 Depth=1
	shll	$5, %esi
	movq	$0, 18(%rdx,%rsi)
	movq	$0, 12(%rdx,%rsi)
	movl	$1297043268, (%rdx,%rsi)        # imm = 0x4D4F4F44
	movl	$1447121741, 3(%rdx,%rsi)       # imm = 0x5641534D
	movb	%cl, 7(%rdx,%rsi)
	movl	$541545284, 8(%rdx,%rsi)        # imm = 0x20475344
	movl	$0, 26(%rdx,%rsi)
	movw	$0, 30(%rdx,%rsi)
	incl	%eax
	cmpl	$6, %eax
	jne	.LBB3_164
# %bb.188:
	movq	(%rbp), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_189:                              # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_191
# %bb.190:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	jne	.LBB3_192
.LBB3_191:                              #   in Loop: Header=BB3_189 Depth=1
	movl	%esi, %ecx
.LBB3_192:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	je	.LBB3_211
# %bb.193:                              #   in Loop: Header=BB3_189 Depth=1
	cmpl	$229, %edi
	je	.LBB3_211
# %bb.194:                              #   in Loop: Header=BB3_189 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_196
# %bb.195:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	jne	.LBB3_197
.LBB3_196:                              #   in Loop: Header=BB3_189 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_197:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	je	.LBB3_211
# %bb.198:                              #   in Loop: Header=BB3_189 Depth=1
	cmpl	$229, %edi
	je	.LBB3_211
# %bb.199:                              #   in Loop: Header=BB3_189 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_201
# %bb.200:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	jne	.LBB3_202
.LBB3_201:                              #   in Loop: Header=BB3_189 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_202:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	je	.LBB3_211
# %bb.203:                              #   in Loop: Header=BB3_189 Depth=1
	cmpl	$229, %edi
	je	.LBB3_211
# %bb.204:                              #   in Loop: Header=BB3_189 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_206
# %bb.205:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	jne	.LBB3_207
.LBB3_206:                              #   in Loop: Header=BB3_189 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_207:                              #   in Loop: Header=BB3_189 Depth=1
	testl	%edi, %edi
	je	.LBB3_211
# %bb.208:                              #   in Loop: Header=BB3_189 Depth=1
	cmpl	$229, %edi
	je	.LBB3_211
# %bb.209:                              #   in Loop: Header=BB3_189 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_189
# %bb.210:
	callq	install_bootable_layout.cold.122
.LBB3_211:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_532
# %bb.212:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, 12(%rax,%rcx)
	movl	$0, 28(%rax,%rcx)
	movabsq	$2329578481653007696, %rdx      # imm = 0x2054534953524550
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       # imm = 0x4B484320
	movb	$32, 11(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	movw	$0, 30(%rax,%rcx)
	movq	(%rbp), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_213:                              # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_215
# %bb.214:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	jne	.LBB3_216
.LBB3_215:                              #   in Loop: Header=BB3_213 Depth=1
	movl	%esi, %ecx
.LBB3_216:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	je	.LBB3_235
# %bb.217:                              #   in Loop: Header=BB3_213 Depth=1
	cmpl	$229, %edi
	je	.LBB3_235
# %bb.218:                              #   in Loop: Header=BB3_213 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_220
# %bb.219:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	jne	.LBB3_221
.LBB3_220:                              #   in Loop: Header=BB3_213 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_221:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	je	.LBB3_235
# %bb.222:                              #   in Loop: Header=BB3_213 Depth=1
	cmpl	$229, %edi
	je	.LBB3_235
# %bb.223:                              #   in Loop: Header=BB3_213 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_225
# %bb.224:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	jne	.LBB3_226
.LBB3_225:                              #   in Loop: Header=BB3_213 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_226:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	je	.LBB3_235
# %bb.227:                              #   in Loop: Header=BB3_213 Depth=1
	cmpl	$229, %edi
	je	.LBB3_235
# %bb.228:                              #   in Loop: Header=BB3_213 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_230
# %bb.229:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	jne	.LBB3_231
.LBB3_230:                              #   in Loop: Header=BB3_213 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_231:                              #   in Loop: Header=BB3_213 Depth=1
	testl	%edi, %edi
	je	.LBB3_235
# %bb.232:                              #   in Loop: Header=BB3_213 Depth=1
	cmpl	$229, %edi
	je	.LBB3_235
# %bb.233:                              #   in Loop: Header=BB3_213 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_213
# %bb.234:
	callq	install_bootable_layout.cold.120
.LBB3_235:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_533
# %bb.236:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, 12(%rax,%rcx)
	movl	$0, 28(%rax,%rcx)
	movabsq	$2328718701980172627, %rdx      # imm = 0x2051455245564153
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       # imm = 0x4B484320
	movb	$32, 11(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	movw	$0, 30(%rax,%rcx)
	movq	(%rbp), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_237:                              # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_239
# %bb.238:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	jne	.LBB3_240
.LBB3_239:                              #   in Loop: Header=BB3_237 Depth=1
	movl	%esi, %ecx
.LBB3_240:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	je	.LBB3_259
# %bb.241:                              #   in Loop: Header=BB3_237 Depth=1
	cmpl	$229, %edi
	je	.LBB3_259
# %bb.242:                              #   in Loop: Header=BB3_237 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_244
# %bb.243:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	jne	.LBB3_245
.LBB3_244:                              #   in Loop: Header=BB3_237 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_245:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	je	.LBB3_259
# %bb.246:                              #   in Loop: Header=BB3_237 Depth=1
	cmpl	$229, %edi
	je	.LBB3_259
# %bb.247:                              #   in Loop: Header=BB3_237 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_249
# %bb.248:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	jne	.LBB3_250
.LBB3_249:                              #   in Loop: Header=BB3_237 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_250:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	je	.LBB3_259
# %bb.251:                              #   in Loop: Header=BB3_237 Depth=1
	cmpl	$229, %edi
	je	.LBB3_259
# %bb.252:                              #   in Loop: Header=BB3_237 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_254
# %bb.253:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	jne	.LBB3_255
.LBB3_254:                              #   in Loop: Header=BB3_237 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_255:                              #   in Loop: Header=BB3_237 Depth=1
	testl	%edi, %edi
	je	.LBB3_259
# %bb.256:                              #   in Loop: Header=BB3_237 Depth=1
	cmpl	$229, %edi
	je	.LBB3_259
# %bb.257:                              #   in Loop: Header=BB3_237 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_237
# %bb.258:
	callq	install_bootable_layout.cold.118
.LBB3_259:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_534
# %bb.260:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, 12(%rax,%rcx)
	movl	$0, 28(%rax,%rcx)
	movabsq	$2328718701962022732, %rdx      # imm = 0x2051455244414F4C
	movq	%rdx, (%rax,%rcx)
	movl	$1263026976, 7(%rax,%rcx)       # imm = 0x4B484320
	movb	$32, 11(%rax,%rcx)
	movl	$0, 26(%rax,%rcx)
	movw	$0, 30(%rax,%rcx)
	leaq	16(%rbp), %rax
	movl	$22, %ecx
	movdqa	.LCPI3_15(%rip), %xmm1          # xmm1 = [1,1,1,1]
	pxor	%xmm5, %xmm5
	pxor	%xmm4, %xmm4
	.p2align	4
.LBB3_261:                              # =>This Inner Loop Header: Depth=1
	movq	-24(%rbp,%rcx,2), %xmm3         # xmm3 = mem[0],zero
	movq	-16(%rbp,%rcx,2), %xmm2         # xmm2 = mem[0],zero
	pcmpeqw	%xmm0, %xmm3
	punpcklwd	%xmm3, %xmm3            # xmm3 = xmm3[0,0,1,1,2,2,3,3]
	pand	%xmm1, %xmm3
	paddd	%xmm5, %xmm3
	pcmpeqw	%xmm0, %xmm2
	punpcklwd	%xmm2, %xmm2            # xmm2 = xmm2[0,0,1,1,2,2,3,3]
	pand	%xmm1, %xmm2
	paddd	%xmm4, %xmm2
	cmpq	$64246, %rcx                    # imm = 0xFAF6
	je	.LBB3_263
# %bb.262:                              #   in Loop: Header=BB3_261 Depth=1
	movq	-8(%rbp,%rcx,2), %xmm4          # xmm4 = mem[0],zero
	movq	(%rbp,%rcx,2), %xmm5            # xmm5 = mem[0],zero
	pcmpeqw	%xmm0, %xmm4
	punpcklwd	%xmm4, %xmm4            # xmm4 = xmm4[0,0,1,1,2,2,3,3]
	pand	%xmm1, %xmm4
	pcmpeqw	%xmm0, %xmm5
	punpcklwd	%xmm5, %xmm5            # xmm5 = xmm5[0,0,1,1,2,2,3,3]
	pand	%xmm1, %xmm5
	paddd	%xmm4, %xmm3
	paddd	%xmm5, %xmm2
	addq	$16, %rcx
	movdqa	%xmm3, %xmm5
	movdqa	%xmm2, %xmm4
	jmp	.LBB3_261
.LBB3_263:
	paddd	%xmm3, %xmm2
	pshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	paddd	%xmm2, %xmm0
	pshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	paddd	%xmm0, %xmm1
	movd	%xmm1, %ecx
	cmpw	$1, 128484(%rbp)
	adcl	$0, %ecx
	xorl	%edx, %edx
	cmpw	$0, 128486(%rbp)
	sete	%dl
	cmpw	$1, 128488(%rbp)
	adcl	%ecx, %edx
	xorl	%ecx, %ecx
	cmpw	$0, 128490(%rbp)
	sete	%cl
	cmpw	$1, 128492(%rbp)
	adcl	%edx, %ecx
	xorl	%edx, %edx
	cmpw	$0, 128494(%rbp)
	sete	%dl
	cmpw	$1, 128496(%rbp)
	adcl	%ecx, %edx
	cmpl	$4095, %edx                     # imm = 0xFFF
	jbe	.LBB3_535
# %bb.264:
	movl	$-8, 16(%rbp)
	movq	(%rbp), %rdx
	leaq	1049088(%rdx), %rsi
	leaq	1180160(%rdx), %rdi
	leaq	131088(%rbp), %rcx
	cmpq	%rcx, %rsi
	setae	%r8b
	cmpq	%rdi, %rax
	setae	%dil
	orb	%r8b, %dil
	jne	.LBB3_267
# %bb.265:
	xorl	%esi, %esi
	.p2align	4
.LBB3_266:                              # =>This Inner Loop Header: Depth=1
	movzwl	16(%rbp,%rsi,2), %edi
	movw	%di, 1049088(%rdx,%rsi,2)
	movzwl	18(%rbp,%rsi,2), %edi
	movw	%di, 1049090(%rdx,%rsi,2)
	addq	$2, %rsi
	cmpq	$65536, %rsi                    # imm = 0x10000
	jne	.LBB3_266
	jmp	.LBB3_269
.LBB3_267:
	xorl	%edx, %edx
	.p2align	4
.LBB3_268:                              # =>This Inner Loop Header: Depth=1
	movdqu	16(%rbp,%rdx,2), %xmm0
	movdqu	32(%rbp,%rdx,2), %xmm1
	movdqu	%xmm0, (%rsi,%rdx,2)
	movdqu	%xmm1, 16(%rsi,%rdx,2)
	addq	$16, %rdx
	cmpq	$65536, %rdx                    # imm = 0x10000
	jne	.LBB3_268
.LBB3_269:
	movq	(%rbp), %rdx
	leaq	1180160(%rdx), %rsi
	leaq	1311232(%rdx), %rdi
	cmpq	%rcx, %rsi
	setae	%cl
	cmpq	%rdi, %rax
	setae	%al
	orb	%cl, %al
	jne	.LBB3_272
# %bb.270:
	xorl	%eax, %eax
	.p2align	4
.LBB3_271:                              # =>This Inner Loop Header: Depth=1
	movzwl	16(%rbp,%rax,2), %ecx
	movw	%cx, 1180160(%rdx,%rax,2)
	movzwl	18(%rbp,%rax,2), %ecx
	movw	%cx, 1180162(%rdx,%rax,2)
	addq	$2, %rax
	cmpq	$65536, %rax                    # imm = 0x10000
	jne	.LBB3_271
	jmp	.LBB3_274
.LBB3_272:
	xorl	%eax, %eax
	.p2align	4
.LBB3_273:                              # =>This Inner Loop Header: Depth=1
	movdqu	16(%rbp,%rax,2), %xmm0
	movdqu	32(%rbp,%rax,2), %xmm1
	movdqu	%xmm0, (%rsi,%rax,2)
	movdqu	%xmm1, 16(%rsi,%rax,2)
	addq	$16, %rax
	cmpq	$65536, %rax                    # imm = 0x10000
	jne	.LBB3_273
.LBB3_274:
	movq	208(%rsp), %rdi
	callq	free@PLT
	movq	224(%rsp), %rdi
	callq	free@PLT
	movq	240(%rsp), %rdi
	callq	free@PLT
	addq	$15560, %rsp                    # imm = 0x3CC8
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB3_275:
	movl	$1048576, %edi                  # imm = 0x100000
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_545
# %bb.276:
	movq	%rax, %r14
	movl	$18, %edi
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_546
# %bb.277:
	movq	%rax, %rbx
	movb	$1, (%rax)
	movb	$1, 2(%rax)
	movb	$12, 8(%rax)
	movb	$1, 13(%rax)
	movb	$-1, 17(%rax)
	movl	$12, %edi
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_547
# %bb.278:
	movq	%r14, 24(%rsp)                  # 8-byte Spill
	movq	%rbx, 16(%rsp)                  # 8-byte Spill
	movq	%r12, 360(%rsp)                 # 8-byte Spill
	movabsq	$5207093865752713555, %rcx      # imm = 0x48435048544E5953
	movb	$1, (%rax)
	movq	%rax, 280(%rsp)                 # 8-byte Spill
	movq	%rcx, 4(%rax)
	movl	$1516, %edi                     # imm = 0x5EC
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_548
# %bb.279:
	movb	$42, (%rax)
	movq	%rax, 256(%rsp)                 # 8-byte Spill
	movq	%rax, %r13
	addq	$172, %r13
	leaq	switch_textures(%rip), %r15
	movl	$7, %ebp
	xorl	%r12d, %r12d
	.p2align	4
.LBB3_280:                              # =>This Inner Loop Header: Depth=1
	leaq	172(%r12), %rax
	movq	256(%rsp), %rcx                 # 8-byte Reload
	movb	%al, -3(%rcx,%rbp)
	movb	%ah, -2(%rcx,%rbp)
	movw	$0, -1(%rcx,%rbp)
	movq	(%r15), %rbx
	movq	$0, 172(%rcx,%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_506
# %bb.281:                              #   in Loop: Header=BB3_280 Depth=1
	leaq	(%r12,%r13), %rdi
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movl	$65537, 12(%r13,%r12)           # imm = 0x10001
	movw	$1, 20(%r13,%r12)
	addq	$32, %r12
	addq	$8, %r15
	addq	$4, %rbp
	cmpq	$1344, %r12                     # imm = 0x540
	jne	.LBB3_280
# %bb.282:
	movl	$10752, %edi                    # imm = 0x2A00
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_549
# %bb.283:
	movq	%rax, %r15
	movl	$8704, %edi                     # imm = 0x2200
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	movq	16(%rsp), %rbx                  # 8-byte Reload
	je	.LBB3_550
# %bb.284:
	movq	%rax, %rbp
	movw	$0, 100(%rsp)
	movl	$0, 96(%rsp)
	movdqa	.LCPI3_2(%rip), %xmm4           # xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$80, %eax
	movdqa	.LCPI3_3(%rip), %xmm0           # xmm0 = [16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16]
	movdqa	.LCPI3_4(%rip), %xmm5           # xmm5 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
	movdqa	.LCPI3_5(%rip), %xmm1           # xmm1 = [48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48]
	movdqa	.LCPI3_6(%rip), %xmm2           # xmm2 = [32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32]
	movdqa	.LCPI3_7(%rip), %xmm3           # xmm3 = [96,96,96,96,96,96,96,96,96,96,96,96,96,96,96,96]
	.p2align	4
.LBB3_285:                              # =>This Inner Loop Header: Depth=1
	movdqa	%xmm4, %xmm6
	paddb	%xmm0, %xmm6
	movdqa	%xmm4, %xmm7
	pand	%xmm5, %xmm7
	pand	%xmm5, %xmm6
	movdqu	%xmm7, -80(%r15,%rax)
	movdqu	%xmm6, -64(%r15,%rax)
	movdqa	%xmm4, %xmm8
	paddb	%xmm1, %xmm8
	movdqa	%xmm7, %xmm9
	pxor	%xmm2, %xmm9
	pand	%xmm5, %xmm8
	movdqu	%xmm9, -48(%r15,%rax)
	movdqu	%xmm8, -32(%r15,%rax)
	movdqu	%xmm7, -16(%r15,%rax)
	movdqu	%xmm6, (%r15,%rax)
	paddb	%xmm3, %xmm4
	addq	$96, %rax
	cmpq	$10832, %rax                    # imm = 0x2A50
	jne	.LBB3_285
# %bb.286:
	movdqa	.LCPI3_2(%rip), %xmm4           # xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$112, %eax
	movdqa	.LCPI3_8(%rip), %xmm5           # xmm5 = [64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64]
	movdqa	.LCPI3_9(%rip), %xmm6           # xmm6 = [80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80]
	movdqa	.LCPI3_10(%rip), %xmm7          # xmm7 = [112,112,112,112,112,112,112,112,112,112,112,112,112,112,112,112]
	movdqa	.LCPI3_11(%rip), %xmm8          # xmm8 = [128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128]
	.p2align	4
.LBB3_287:                              # =>This Inner Loop Header: Depth=1
	movdqa	%xmm4, %xmm9
	paddb	%xmm0, %xmm9
	movdqu	%xmm4, -112(%rbp,%rax)
	movdqu	%xmm9, -96(%rbp,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm2, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm1, %xmm10
	movdqu	%xmm9, -80(%rbp,%rax)
	movdqu	%xmm10, -64(%rbp,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm5, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm6, %xmm10
	movdqu	%xmm9, -48(%rbp,%rax)
	movdqu	%xmm10, -32(%rbp,%rax)
	movdqa	%xmm4, %xmm9
	paddb	%xmm3, %xmm9
	movdqa	%xmm4, %xmm10
	paddb	%xmm7, %xmm10
	movdqu	%xmm9, -16(%rbp,%rax)
	movdqu	%xmm10, (%rbp,%rax)
	pxor	%xmm8, %xmm4
	subq	$-128, %rax
	cmpq	$8816, %rax                     # imm = 0x2270
	jne	.LBB3_287
# %bb.288:
	movb	$0, 172(%rsp)
	movl	$0, 168(%rsp)
	movl	$0, 160(%rsp)
	movb	$0, 164(%rsp)
	movl	$0, 152(%rsp)
	movb	$0, 156(%rsp)
	movl	$0, 144(%rsp)
	movb	$0, 148(%rsp)
	movl	$0, 288(%rsp)
	movl	$0, 291(%rsp)
	movl	$0, 64(%rsp)
	movl	$0, 67(%rsp)
	movl	$0, 264(%rsp)
	movl	$0, 267(%rsp)
	movl	$0, 107(%rsp)
	movl	$0, 104(%rsp)
	movb	$0, 140(%rsp)
	movl	$0, 136(%rsp)
	movb	$0, 132(%rsp)
	movl	$0, 128(%rsp)
	movl	$0, 120(%rsp)
	movb	$0, 124(%rsp)
	movl	$0, 112(%rsp)
	movb	$0, 116(%rsp)
	movl	$2048, %edi                     # imm = 0x800
	callq	malloc@PLT
	testq	%rax, %rax
	je	.LBB3_551
# %bb.289:
	movabsq	$46179488366604, %rcx           # imm = 0x2A000000000C
	movq	%rcx, (%rax)
	movq	$0, 8(%rax)
	movl	$1497451600, 8(%rax)            # imm = 0x59414C50
	movl	$1279348825, 11(%rax)           # imm = 0x4C415059
	movq	%rax, %r14
	movq	24(%rsp), %r12                  # 8-byte Reload
	leaq	12(%r12), %rdi
	movl	$10752, %edx                    # imm = 0x2A00
	movq	%r15, 352(%rsp)                 # 8-byte Spill
	movq	%r15, %rsi
	callq	memcpy@PLT
	movabsq	$37383395355148, %rax           # imm = 0x220000002A0C
	movq	%rax, 16(%r14)
	movabsq	$5782988412433485635, %rax      # imm = 0x50414D524F4C4F43
	movq	%rax, 24(%r14)
	leaq	10764(%r12), %rdi
	movl	$8704, %edx                     # imm = 0x2200
	movq	%rbp, 344(%rsp)                 # 8-byte Spill
	movq	%rbp, %rsi
	callq	memcpy@PLT
	movabsq	$51539627020, %rax              # imm = 0xC00004C0C
	movq	%rax, 32(%r14)
	movq	$0, 40(%r14)
	movl	$1296125520, 40(%r14)           # imm = 0x4D414E50
	movw	$21317, 44(%r14)                # imm = 0x5345
	movq	280(%rsp), %rcx                 # 8-byte Reload
	movl	8(%rcx), %eax
	movl	%eax, 19476(%r12)
	movq	(%rcx), %rax
	movq	%rax, 19468(%r12)
	movabsq	$6511170440216, %rax            # imm = 0x5EC00004C18
	movq	%rax, 48(%r14)
	movabsq	$3550334407692272980, %rax      # imm = 0x3145525554584554
	movq	%rax, 56(%r14)
	leaq	19480(%r12), %rdi
	movl	$1516, %edx                     # imm = 0x5EC
	movq	256(%rsp), %rsi                 # 8-byte Reload
	callq	memcpy@PLT
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, 64(%r14)
	movl	$1414750022, 72(%r14)           # imm = 0x54535F46
	movl	$1414676820, 75(%r14)           # imm = 0x54524154
	movabsq	$17592186065412, %rax           # imm = 0x100000005204
	movq	%rax, 80(%r14)
	movq	$0, 88(%r14)
	movl	$1263755078, 88(%r14)           # imm = 0x4B535F46
	movw	$12633, 92(%r14)                # imm = 0x3159
	leaq	20996(%r12), %rdi
	movl	$4096, %edx                     # imm = 0x1000
	xorl	%esi, %esi
	callq	memset@PLT
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, 96(%r14)
	movl	$1313169222, 104(%r14)          # imm = 0x4E455F46
	movb	$68, 108(%r14)
	movdqu	%xmm0, 112(%r14)
	pxor	%xmm1, %xmm1
	movl	$1414676820, 123(%r14)          # imm = 0x54524154
	movl	$1414750035, 120(%r14)          # imm = 0x54535F53
	movabsq	$77309436420, %rax              # imm = 0x1200006204
	movq	%rax, 128(%r14)
	movq	$0, 136(%r14)
	movl	$1196315984, 136(%r14)          # imm = 0x474E5550
	movw	$12353, 140(%r14)               # imm = 0x3041
	movups	(%rbx), %xmm0
	movups	%xmm0, 25092(%r12)
	movzwl	16(%rbx), %eax
	movw	%ax, 25108(%r12)
	movabsq	$77309436438, %rax              # imm = 0x1200006216
	movq	%rax, 144(%r14)
	movq	$0, 152(%r14)
	movl	$1196315984, 152(%r14)          # imm = 0x474E5550
	movw	$12354, 156(%r14)               # imm = 0x3042
	movzwl	16(%rbx), %eax
	movw	%ax, 25126(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25110(%r12)
	movabsq	$77309436456, %rax              # imm = 0x1200006228
	movq	%rax, 160(%r14)
	movq	$0, 168(%r14)
	movl	$1196315984, 168(%r14)          # imm = 0x474E5550
	movw	$12355, 172(%r14)               # imm = 0x3043
	movzwl	16(%rbx), %eax
	movw	%ax, 25144(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25128(%r12)
	movabsq	$77309436474, %rax              # imm = 0x120000623A
	movq	%rax, 176(%r14)
	movq	$0, 184(%r14)
	movl	$1196315984, 184(%r14)          # imm = 0x474E5550
	movw	$12356, 188(%r14)               # imm = 0x3044
	movzwl	16(%rbx), %eax
	movw	%ax, 25162(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25146(%r12)
	movabsq	$77309436492, %rax              # imm = 0x120000624C
	movq	%rax, 192(%r14)
	movq	$0, 200(%r14)
	movl	$1196640592, 200(%r14)          # imm = 0x47534950
	movw	$12353, 204(%r14)               # imm = 0x3041
	movzwl	16(%rbx), %eax
	movw	%ax, 25180(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25164(%r12)
	movabsq	$77309436510, %rax              # imm = 0x120000625E
	movq	%rax, 208(%r14)
	movq	$0, 216(%r14)
	movl	$1196640592, 216(%r14)          # imm = 0x47534950
	movw	$12354, 220(%r14)               # imm = 0x3042
	movzwl	16(%rbx), %eax
	movw	%ax, 25198(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25182(%r12)
	movabsq	$77309436528, %rax              # imm = 0x1200006270
	movq	%rax, 224(%r14)
	movq	$0, 232(%r14)
	movl	$1196640592, 232(%r14)          # imm = 0x47534950
	movw	$12355, 236(%r14)               # imm = 0x3043
	movzwl	16(%rbx), %eax
	movw	%ax, 25216(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25200(%r12)
	movabsq	$77309436546, %rax              # imm = 0x1200006282
	movq	%rax, 240(%r14)
	movq	$0, 248(%r14)
	movl	$1179863376, 248(%r14)          # imm = 0x46534950
	movw	$12353, 252(%r14)               # imm = 0x3041
	movzwl	16(%rbx), %eax
	movw	%ax, 25234(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25218(%r12)
	movabsq	$77309436564, %rax              # imm = 0x1200006294
	movq	%rax, 256(%r14)
	movq	$0, 264(%r14)
	movl	$1497451600, 264(%r14)          # imm = 0x59414C50
	movw	$12353, 268(%r14)               # imm = 0x3041
	movzwl	16(%rbx), %eax
	movw	%ax, 25252(%r12)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25236(%r12)
	movdqu	%xmm1, 272(%r14)
	movb	$68, 284(%r14)
	movl	$1313169235, 280(%r14)          # imm = 0x4E455F53
	movabsq	$77309436582, %rax              # imm = 0x12000062A6
	movq	%rax, 288(%r14)
	movabsq	$5207093865752713555, %rax      # imm = 0x48435048544E5953
	movq	%rax, 296(%r14)
	movups	(%rbx), %xmm0
	movups	%xmm0, 25254(%r12)
	movzwl	16(%rbx), %eax
	movw	%ax, 25270(%r12)
	movabsq	$73014469304, %rax              # imm = 0x11000062B8
	movq	%rax, 304(%r14)
	movq	$0, 312(%r14)
	movl	$1330795598, 315(%r14)          # imm = 0x4F52544E
	movl	$1313431364, 312(%r14)          # imm = 0x4E495F44
	movaps	FIXTURE_MUS_SCORE_END(%rip), %xmm0
	movups	%xmm0, 25272(%r12)
	movb	$96, 25288(%r12)
	movabsq	$73014469321, %rax              # imm = 0x11000062C9
	movq	%rax, 320(%r14)
	movq	$0, 328(%r14)
	movl	$826629956, 328(%r14)           # imm = 0x31455F44
	movw	$12621, 332(%r14)               # imm = 0x314D
	movups	%xmm0, 25289(%r12)
	movb	$96, 25305(%r12)
	movdqu	%xmm1, 336(%r14)
	movl	$827142469, 344(%r14)           # imm = 0x314D3145
	movabsq	$42949698266, %rax              # imm = 0xA000062DA
	movq	%rax, 352(%r14)
	movq	$0, 360(%r14)
	movl	$1313425492, 360(%r14)          # imm = 0x4E494854
	movw	$21319, 364(%r14)               # imm = 0x5347
	movzwl	100(%rsp), %eax
	movw	%ax, 25310(%r12)
	movl	96(%rsp), %eax
	movl	%eax, 25306(%r12)
	movabsq	$240518193892, %rax             # imm = 0x38000062E4
	movq	%rax, 368(%r14)
	movabsq	$6000559713039960403, %rax      # imm = 0x5346454445444953
	leaq	655353(%rax), %rcx
	movq	%rcx, 376(%r14)
	movabsq	$4295426049, %rcx               # imm = 0x100070001
	movq	%rcx, 25312(%r12)
	movb	$1, 25320(%r12)
	movl	168(%rsp), %ecx
	movl	%ecx, 25321(%r12)
	movzbl	172(%rsp), %ecx
	movb	%cl, 25325(%r12)
	movabsq	$281487861547008, %rcx          # imm = 0x10002FFFF0000
	movq	%rcx, 25326(%r12)
	movb	$1, 25334(%r12)
	movl	160(%rsp), %ecx
	movl	%ecx, 25335(%r12)
	movzbl	164(%rsp), %ecx
	movb	%cl, 25339(%r12)
	movabsq	$562967133224961, %rcx          # imm = 0x20003FFFF0001
	movq	%rcx, 25340(%r12)
	movb	$1, 25348(%r12)
	movl	152(%rsp), %ecx
	movl	%ecx, 25349(%r12)
	movzbl	156(%rsp), %ecx
	movb	%cl, 25353(%r12)
	movabsq	$844429225033730, %rcx          # imm = 0x30000FFFF0002
	movq	%rcx, 25354(%r12)
	movb	$1, 25362(%r12)
	movl	144(%rsp), %ecx
	movl	%ecx, 25363(%r12)
	movzbl	148(%rsp), %ecx
	movb	%cl, 25367(%r12)
	movl	$-65533, 25368(%r12)            # imm = 0xFFFF0003
	movabsq	$515396100892, %rcx             # imm = 0x780000631C
	movq	%rcx, 384(%r14)
	movq	%rax, 392(%r14)
	movl	$0, 25372(%r12)
	movb	$45, 25376(%r12)
	movl	288(%rsp), %eax
	movl	291(%rsp), %ecx
	movl	%eax, 25377(%r12)
	movl	%ecx, 25380(%r12)
	movq	$45, 25384(%r12)
	movabsq	$5570745284657502035, %rax      # imm = 0x4D4F435242315753
	movq	%rax, 25392(%r12)
	movw	$0, 25400(%r12)
	movl	$0, 25402(%r12)
	movb	$45, 25406(%r12)
	movl	64(%rsp), %ecx
	movl	67(%rsp), %edx
	movl	%ecx, 25407(%r12)
	movl	%edx, 25410(%r12)
	movq	$45, 25414(%r12)
	movq	%rax, 25422(%r12)
	movw	$0, 25430(%r12)
	movl	$0, 25432(%r12)
	movb	$45, 25436(%r12)
	movl	264(%rsp), %ecx
	movl	267(%rsp), %edx
	movl	%edx, 25440(%r12)
	movl	%ecx, 25437(%r12)
	movq	$45, 25444(%r12)
	movq	%rax, 25452(%r12)
	movw	$0, 25460(%r12)
	movl	$0, 25462(%r12)
	movb	$45, 25466(%r12)
	movl	104(%rsp), %ecx
	movl	107(%rsp), %edx
	movl	%edx, 25470(%r12)
	movl	%ecx, 25467(%r12)
	movq	$45, 25474(%r12)
	movq	%rax, 25482(%r12)
	movabsq	$68719502228, %rax              # imm = 0x1000006394
	movq	%rax, 400(%r14)
	movabsq	$6000299133331719510, %rax      # imm = 0x5345584554524556
	movq	%rax, 408(%r14)
	movaps	.LCPI3_12(%rip), %xmm0          # xmm0 = [0,0,192,255,192,255,64,0,192,255,64,0,64,0,192,255]
	movups	%xmm0, 25490(%r12)
	movabsq	$206158455716, %rax             # imm = 0x30000063A4
	movq	%rax, 416(%r14)
	movq	$1397179731, 424(%r14)          # imm = 0x53474553
	movabsq	$9223090561878130752, %rax      # imm = 0x7FFF000000010040
	movq	%rax, 25506(%r12)
	movb	$0, 25514(%r12)
	movl	136(%rsp), %eax
	movl	%eax, 25515(%r12)
	movzbl	140(%rsp), %eax
	movb	%al, 25519(%r12)
	movl	$65538, 25520(%r12)             # imm = 0x10002
	movw	$-16384, 25524(%r12)            # imm = 0xC000
	movb	$1, 25526(%r12)
	movl	128(%rsp), %eax
	movl	%eax, 25527(%r12)
	movzbl	132(%rsp), %eax
	movb	%al, 25531(%r12)
	movl	$131075, 25532(%r12)            # imm = 0x20003
	movw	$0, 25536(%r12)
	movb	$2, 25538(%r12)
	movl	120(%rsp), %eax
	movl	%eax, 25539(%r12)
	movzbl	124(%rsp), %eax
	movb	%al, 25543(%r12)
	movl	$196608, 25544(%r12)            # imm = 0x30000
	movw	$16384, 25548(%r12)             # imm = 0x4000
	movb	$3, 25550(%r12)
	movzbl	116(%rsp), %eax
	movb	%al, 25555(%r12)
	movl	112(%rsp), %eax
	movl	%eax, 25551(%r12)
	movabsq	$17179894740, %rax              # imm = 0x4000063D4
	movq	%rax, 432(%r14)
	movabsq	$6003948476562756435, %rax      # imm = 0x53524F5443455353
	movq	%rax, 440(%r14)
	movdqu	%xmm1, 448(%r14)
	movl	$1162104654, 456(%r14)          # imm = 0x45444F4E
	movb	$83, 460(%r14)
	movabsq	$111669175256, %rax             # imm = 0x1A000063D8
	movq	%rax, 464(%r14)
	movq	$0, 472(%r14)
	movl	$1413694803, 472(%r14)          # imm = 0x54434553
	movl	$1397903188, 475(%r14)          # imm = 0x53524F54
	movabsq	$36028797018963972, %rax        # imm = 0x80000000000004
	movq	%rax, 25556(%r12)
	movabsq	$54259585605446, %rax           # imm = 0x31594B535F46
	movq	%rax, 25564(%r12)
	movq	%rax, 25572(%r12)
	movw	$160, 25580(%r12)
	movl	$0, 25582(%r12)
	movabsq	$4294992882, %rax               # imm = 0x1000063F2
	movq	%rax, 480(%r14)
	movq	$0, 488(%r14)
	movl	$1162495314, 488(%r14)          # imm = 0x454A4552
	movw	$21571, 492(%r14)               # imm = 0x5443
	movabsq	$111669175283, %rax             # imm = 0x1A000063F3
	movq	%rax, 496(%r14)
	movabsq	$5782988382167583810, %rax      # imm = 0x50414D4B434F4C42
	movq	%r14, 40(%rsp)                  # 8-byte Spill
	movq	%rax, 504(%r14)
	movaps	.LCPI3_13(%rip), %xmm0          # xmm0 = [0,128,255,128,255,2,0,2,0,8,0,8,0,8,0,8]
	movups	%xmm0, 25586(%r12)
	movabsq	$216174981153816576, %rax       # imm = 0x300020001000000
	movq	%rax, 25602(%r12)
	movw	$-256, 25610(%r12)
	movb	$-1, 25612(%r12)
	movl	$128, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movl	$32, %r13d
	movl	$25613, %ebp                    # imm = 0x640D
	movl	$1024, %ebx                     # imm = 0x400
	movl	$64, %r14d
	leaq	384(%rsp), %rdi
	.p2align	4
.LBB3_290:                              # =>This Inner Loop Header: Depth=1
	leal	1(%r13), %ecx
	movl	$16, %esi
	leaq	.L.str.405(%rip), %rdx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	8(%rsp), %r13                   # 8-byte Folded Reload
	jne	.LBB3_292
# %bb.291:                              #   in Loop: Header=BB3_290 Depth=1
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	realloc@PLT
	movq	%rax, %r12
	movq	%r14, 8(%rsp)                   # 8-byte Spill
	testq	%rax, %rax
	jne	.LBB3_293
	jmp	.LBB3_516
	.p2align	4
.LBB3_292:                              #   in Loop: Header=BB3_290 Depth=1
	movq	40(%rsp), %r12                  # 8-byte Reload
.LBB3_293:                              #   in Loop: Header=BB3_290 Depth=1
	movl	%ebp, (%r12,%r14,8)
	movl	$18, 4(%r12,%r14,8)
	movq	$0, 8(%r12,%r14,8)
	leaq	384(%rsp), %r15
	movq	%r15, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_507
# %bb.294:                              #   in Loop: Header=BB3_290 Depth=1
	movq	%r12, 40(%rsp)                  # 8-byte Spill
	leaq	(%r12,%r14,8), %rdi
	addq	$8, %rdi
	incq	%r13
	movq	%r15, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, (%rcx,%rbp)
	movzwl	16(%rax), %eax
	movw	%ax, 16(%rcx,%rbp)
	addq	$18, %rbp
	addq	$32, %rbx
	addq	$2, %r14
	cmpl	$190, %r14d
	movq	%r15, %rdi
	jne	.LBB3_290
# %bb.295:
	leaq	.L.str.406(%rip), %rdx
	leaq	384(%rsp), %rbx
	movl	$16, %esi
	movq	%rbx, %rdi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	movabsq	$77309438075, %rax              # imm = 0x120000687B
	movq	40(%rsp), %r12                  # 8-byte Reload
	movq	%rax, 1520(%r12)
	movq	$0, 1528(%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_552
# %bb.296:
	leaq	1528(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %r15                  # 8-byte Reload
	movups	(%r15), %xmm0
	movq	24(%rsp), %r14                  # 8-byte Reload
	movups	%xmm0, 26747(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26763(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$96, 8(%rsp)                    # 8-byte Folded Reload
	jne	.LBB3_299
# %bb.297:
	movl	$3072, %esi                     # imm = 0xC00
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_584
# %bb.298:
	movq	%rax, %r12
	movl	$192, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
.LBB3_299:
	movabsq	$77309438093, %rax              # imm = 0x120000688D
	movq	%rax, 1536(%r12)
	movq	$0, 1544(%r12)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_553
# %bb.300:
	leaq	1544(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26765(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26781(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	movabsq	$77309438111, %rax              # imm = 0x120000689F
	movq	%rax, 1552(%r12)
	movq	$0, 1560(%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_554
# %bb.301:
	leaq	1560(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26783(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26799(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$98, 8(%rsp)                    # 8-byte Folded Reload
	jne	.LBB3_304
# %bb.302:
	movl	$3136, %esi                     # imm = 0xC40
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_585
# %bb.303:
	movq	%rax, %r12
	movl	$196, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
.LBB3_304:
	movabsq	$77309438129, %rax              # imm = 0x12000068B1
	movq	%rax, 1568(%r12)
	movq	$0, 1576(%r12)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_555
# %bb.305:
	leaq	1576(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26801(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26817(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	movabsq	$77309438147, %rax              # imm = 0x12000068C3
	movq	%rax, 1584(%r12)
	movq	$0, 1592(%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_556
# %bb.306:
	leaq	1592(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26819(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26835(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$100, 8(%rsp)                   # 8-byte Folded Reload
	jne	.LBB3_309
# %bb.307:
	movl	$3200, %esi                     # imm = 0xC80
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_586
# %bb.308:
	movq	%rax, %r12
	movl	$200, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
.LBB3_309:
	movabsq	$77309438165, %rax              # imm = 0x12000068D5
	movq	%rax, 1600(%r12)
	movq	$0, 1608(%r12)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_557
# %bb.310:
	leaq	1608(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26837(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26853(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	movabsq	$77309438183, %rax              # imm = 0x12000068E7
	movq	%rax, 1616(%r12)
	movq	$0, 1624(%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_558
# %bb.311:
	leaq	1624(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26855(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26871(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$102, 8(%rsp)                   # 8-byte Folded Reload
	jne	.LBB3_314
# %bb.312:
	movl	$3264, %esi                     # imm = 0xCC0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_587
# %bb.313:
	movq	%rax, %r12
	movl	$204, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
.LBB3_314:
	movabsq	$77309438201, %rax              # imm = 0x12000068F9
	movq	%rax, 1632(%r12)
	movq	$0, 1640(%r12)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_559
# %bb.315:
	leaq	1640(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26873(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26889(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$103, 8(%rsp)                   # 8-byte Folded Reload
	jne	.LBB3_318
# %bb.316:
	movl	$3296, %esi                     # imm = 0xCE0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_588
# %bb.317:
	movq	%rax, %r12
	movl	$206, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
.LBB3_318:
	movabsq	$77309438219, %rax              # imm = 0x120000690B
	movq	%rax, 1648(%r12)
	movq	$0, 1656(%r12)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_560
# %bb.319:
	leaq	1656(%r12), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26891(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26907(%r14)
	leaq	.L.str.406(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$104, 8(%rsp)                   # 8-byte Folded Reload
	jne	.LBB3_322
# %bb.320:
	movl	$3328, %esi                     # imm = 0xD00
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_589
# %bb.321:
	movq	%rax, %r12
	movl	$208, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
.LBB3_322:
	movabsq	$77309438237, %rax              # imm = 0x120000691D
	movq	%rax, 1664(%r12)
	movq	$0, 1672(%r12)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_561
# %bb.323:
	leaq	1672(%r12), %rdi
	leaq	384(%rsp), %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26909(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26925(%r14)
	movq	8(%rsp), %rbx                   # 8-byte Reload
	cmpq	$105, %rbx
	jne	.LBB3_326
# %bb.324:
	movl	$3360, %esi                     # imm = 0xD20
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_590
# %bb.325:
	movq	%rax, %r13
	movl	$210, %ebx
	jmp	.LBB3_327
.LBB3_326:
	movq	%r12, %r13
.LBB3_327:
	movabsq	$77309438255, %rax              # imm = 0x120000692F
	movq	%rax, 1680(%r13)
	movabsq	$6004791754905375827, %rax      # imm = 0x53554E494D545453
	movq	%rax, 1688(%r13)
	movzwl	16(%r15), %eax
	movw	%ax, 26943(%r14)
	movups	(%r15), %xmm0
	movups	%xmm0, 26927(%r14)
	leaq	.L.str.408(%rip), %rdx
	leaq	384(%rsp), %rdi
	movl	$16, %esi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$106, %rbx
	jne	.LBB3_330
# %bb.328:
	movl	$3392, %esi                     # imm = 0xD40
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_591
# %bb.329:
	movq	%rax, %r13
	movl	$212, %r12d
	jmp	.LBB3_331
.LBB3_330:
	movq	%rbx, %r12
.LBB3_331:
	movabsq	$77309438273, %rax              # imm = 0x1200006941
	movq	%rax, 1696(%r13)
	movq	$0, 1704(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_562
# %bb.332:
	leaq	1704(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26945(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26961(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$107, %r12
	jne	.LBB3_335
# %bb.333:
	movl	$3424, %esi                     # imm = 0xD60
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_592
# %bb.334:
	movq	%rax, %r13
	movl	$214, %r12d
.LBB3_335:
	movabsq	$77309438291, %rax              # imm = 0x1200006953
	movq	%rax, 1712(%r13)
	movq	$0, 1720(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_563
# %bb.336:
	leaq	1720(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26963(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26979(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$108, %r12
	jne	.LBB3_339
# %bb.337:
	movl	$3456, %esi                     # imm = 0xD80
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_593
# %bb.338:
	movq	%rax, %r13
	movl	$216, %r12d
.LBB3_339:
	movabsq	$77309438309, %rax              # imm = 0x1200006965
	movq	%rax, 1728(%r13)
	movq	$0, 1736(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_564
# %bb.340:
	leaq	1736(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26981(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 26997(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$109, %r12
	jne	.LBB3_343
# %bb.341:
	movl	$3488, %esi                     # imm = 0xDA0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_594
# %bb.342:
	movq	%rax, %r13
	movl	$218, %r12d
.LBB3_343:
	movabsq	$77309438327, %rax              # imm = 0x1200006977
	movq	%rax, 1744(%r13)
	movq	$0, 1752(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_565
# %bb.344:
	leaq	1752(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 26999(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27015(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$110, %r12
	jne	.LBB3_347
# %bb.345:
	movl	$3520, %esi                     # imm = 0xDC0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_595
# %bb.346:
	movq	%rax, %r13
	movl	$220, %r12d
.LBB3_347:
	movabsq	$77309438345, %rax              # imm = 0x1200006989
	movq	%rax, 1760(%r13)
	movq	$0, 1768(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_566
# %bb.348:
	leaq	1768(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27017(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27033(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$111, %r12
	jne	.LBB3_351
# %bb.349:
	movl	$3552, %esi                     # imm = 0xDE0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_596
# %bb.350:
	movq	%rax, %r13
	movl	$222, %r12d
.LBB3_351:
	movabsq	$77309438363, %rax              # imm = 0x120000699B
	movq	%rax, 1776(%r13)
	movq	$0, 1784(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_567
# %bb.352:
	leaq	1784(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27035(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27051(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$112, %r12
	jne	.LBB3_355
# %bb.353:
	movl	$3584, %esi                     # imm = 0xE00
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_597
# %bb.354:
	movq	%rax, %r13
	movl	$224, %r12d
.LBB3_355:
	movabsq	$77309438381, %rax              # imm = 0x12000069AD
	movq	%rax, 1792(%r13)
	movq	$0, 1800(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_568
# %bb.356:
	leaq	1800(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27053(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27069(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$113, %r12
	jne	.LBB3_359
# %bb.357:
	movl	$3616, %esi                     # imm = 0xE20
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_598
# %bb.358:
	movq	%rax, %r13
	movl	$226, %r12d
.LBB3_359:
	movabsq	$77309438399, %rax              # imm = 0x12000069BF
	movq	%rax, 1808(%r13)
	movq	$0, 1816(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_569
# %bb.360:
	leaq	1816(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27071(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27087(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$114, %r12
	jne	.LBB3_363
# %bb.361:
	movl	$3648, %esi                     # imm = 0xE40
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_599
# %bb.362:
	movq	%rax, %r13
	movl	$228, %r12d
.LBB3_363:
	movabsq	$77309438417, %rax              # imm = 0x12000069D1
	movq	%rax, 1824(%r13)
	movq	$0, 1832(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_570
# %bb.364:
	leaq	1832(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27089(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27105(%r14)
	leaq	.L.str.408(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$115, %r12
	jne	.LBB3_367
# %bb.365:
	movl	$3680, %esi                     # imm = 0xE60
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_600
# %bb.366:
	movq	%rax, %r13
	movl	$230, %r12d
.LBB3_367:
	movabsq	$77309438435, %rax              # imm = 0x12000069E3
	movq	%rax, 1840(%r13)
	movq	$0, 1848(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_571
# %bb.368:
	leaq	1848(%r13), %rdi
	leaq	384(%rsp), %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27107(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27123(%r14)
	cmpq	$116, %r12
	jne	.LBB3_371
# %bb.369:
	movl	$3712, %esi                     # imm = 0xE80
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_601
# %bb.370:
	movq	%rax, %r13
	movl	$232, %ebx
	jmp	.LBB3_372
.LBB3_371:
	movq	%r12, %rbx
.LBB3_372:
	movabsq	$77309438453, %rax              # imm = 0x12000069F5
	movq	%rax, 1856(%r13)
	movabsq	$6074866968183460947, %rax      # imm = 0x544E435250545453
	movq	%rax, 1864(%r13)
	movzwl	16(%r15), %eax
	movw	%ax, 27141(%r14)
	movups	(%r15), %xmm0
	movups	%xmm0, 27125(%r14)
	leaq	.L.str.410(%rip), %rdx
	leaq	384(%rsp), %rdi
	movl	$16, %esi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$117, %rbx
	jne	.LBB3_375
# %bb.373:
	movl	$3744, %esi                     # imm = 0xEA0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_602
# %bb.374:
	movq	%rax, %r13
	movl	$234, %r12d
	jmp	.LBB3_376
.LBB3_375:
	movq	%rbx, %r12
.LBB3_376:
	movabsq	$77309438471, %rax              # imm = 0x1200006A07
	movq	%rax, 1872(%r13)
	movq	$0, 1880(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_572
# %bb.377:
	leaq	1880(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27143(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27159(%r14)
	leaq	.L.str.410(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$118, %r12
	jne	.LBB3_380
# %bb.378:
	movl	$3776, %esi                     # imm = 0xEC0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_603
# %bb.379:
	movq	%rax, %r13
	movl	$236, %r12d
.LBB3_380:
	movabsq	$77309438489, %rax              # imm = 0x1200006A19
	movq	%rax, 1888(%r13)
	movq	$0, 1896(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_573
# %bb.381:
	leaq	1896(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27161(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27177(%r14)
	leaq	.L.str.410(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$119, %r12
	jne	.LBB3_384
# %bb.382:
	movl	$3808, %esi                     # imm = 0xEE0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_604
# %bb.383:
	movq	%rax, %r13
	movl	$238, %r12d
.LBB3_384:
	movabsq	$77309438507, %rax              # imm = 0x1200006A2B
	movq	%rax, 1904(%r13)
	movq	$0, 1912(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_574
# %bb.385:
	leaq	1912(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27179(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27195(%r14)
	leaq	.L.str.410(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$120, %r12
	jne	.LBB3_388
# %bb.386:
	movl	$3840, %esi                     # imm = 0xF00
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_605
# %bb.387:
	movq	%rax, %r13
	movl	$240, %r12d
.LBB3_388:
	movabsq	$77309438525, %rax              # imm = 0x1200006A3D
	movq	%rax, 1920(%r13)
	movq	$0, 1928(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_575
# %bb.389:
	leaq	1928(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27197(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27213(%r14)
	leaq	.L.str.410(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$121, %r12
	jne	.LBB3_392
# %bb.390:
	movl	$3872, %esi                     # imm = 0xF20
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_606
# %bb.391:
	movq	%rax, %r13
	movl	$242, %r12d
.LBB3_392:
	movabsq	$77309438543, %rax              # imm = 0x1200006A4F
	movq	%rax, 1936(%r13)
	movq	$0, 1944(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_576
# %bb.393:
	leaq	1944(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27215(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27231(%r14)
	leaq	.L.str.410(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$122, %r12
	jne	.LBB3_396
# %bb.394:
	movl	$3904, %esi                     # imm = 0xF40
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_607
# %bb.395:
	movq	%rax, %r13
	movl	$244, %r12d
.LBB3_396:
	movabsq	$77309438561, %rax              # imm = 0x1200006A61
	movq	%rax, 1952(%r13)
	movq	$0, 1960(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_577
# %bb.397:
	leaq	1960(%r13), %rdi
	leaq	384(%rsp), %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27233(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27249(%r14)
	cmpq	$123, %r12
	jne	.LBB3_400
# %bb.398:
	movl	$3936, %esi                     # imm = 0xF60
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_608
# %bb.399:
	movq	%rax, %r13
	movl	$246, %ebx
	jmp	.LBB3_401
.LBB3_400:
	movq	%r12, %rbx
.LBB3_401:
	movabsq	$77309438579, %rax              # imm = 0x1200006A73
	movq	%rax, 1968(%r13)
	movq	$0, 1976(%r13)
	movl	$1380013139, 1976(%r13)         # imm = 0x52415453
	movw	$21325, 1980(%r13)              # imm = 0x534D
	movzwl	16(%r15), %eax
	movw	%ax, 27267(%r14)
	movups	(%r15), %xmm0
	movups	%xmm0, 27251(%r14)
	leaq	.L.str.412(%rip), %rdx
	leaq	384(%rsp), %rdi
	movl	$16, %esi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$124, %rbx
	jne	.LBB3_404
# %bb.402:
	movl	$3968, %esi                     # imm = 0xF80
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_609
# %bb.403:
	movq	%rax, %r13
	movl	$248, %r12d
	jmp	.LBB3_405
.LBB3_404:
	movq	%rbx, %r12
.LBB3_405:
	movabsq	$77309438597, %rax              # imm = 0x1200006A85
	movq	%rax, 1984(%r13)
	movq	$0, 1992(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_578
# %bb.406:
	leaq	1992(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27269(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27285(%r14)
	leaq	.L.str.412(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$125, %r12
	jne	.LBB3_409
# %bb.407:
	movl	$4000, %esi                     # imm = 0xFA0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_610
# %bb.408:
	movq	%rax, %r13
	movl	$250, %r12d
.LBB3_409:
	movabsq	$77309438615, %rax              # imm = 0x1200006A97
	movq	%rax, 2000(%r13)
	movq	$0, 2008(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_579
# %bb.410:
	leaq	2008(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27287(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27303(%r14)
	leaq	.L.str.412(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$126, %r12
	jne	.LBB3_413
# %bb.411:
	movl	$4032, %esi                     # imm = 0xFC0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_611
# %bb.412:
	movq	%rax, %r13
	movl	$252, %r12d
.LBB3_413:
	movabsq	$77309438633, %rax              # imm = 0x1200006AA9
	movq	%rax, 2016(%r13)
	movq	$0, 2024(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_580
# %bb.414:
	leaq	2024(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27305(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27321(%r14)
	leaq	.L.str.412(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$127, %r12
	jne	.LBB3_417
# %bb.415:
	movl	$4064, %esi                     # imm = 0xFE0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_612
# %bb.416:
	movq	%rax, %r13
	movl	$254, %r12d
.LBB3_417:
	movabsq	$77309438651, %rax              # imm = 0x1200006ABB
	movq	%rax, 2032(%r13)
	movq	$0, 2040(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_581
# %bb.418:
	leaq	2040(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27323(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27339(%r14)
	leaq	.L.str.412(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$128, %r12
	jne	.LBB3_421
# %bb.419:
	movl	$4096, %esi                     # imm = 0x1000
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_613
# %bb.420:
	movq	%rax, %r13
	movl	$256, %r12d                     # imm = 0x100
.LBB3_421:
	movabsq	$77309438669, %rax              # imm = 0x1200006ACD
	movq	%rax, 2048(%r13)
	movq	$0, 2056(%r13)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_582
# %bb.422:
	leaq	2056(%r13), %rdi
	leaq	384(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27341(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27357(%r14)
	leaq	.L.str.412(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$129, %r12
	jne	.LBB3_425
# %bb.423:
	movl	$4128, %esi                     # imm = 0x1020
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_614
# %bb.424:
	movq	%rax, %rbx
	movl	$258, %r12d                     # imm = 0x102
	jmp	.LBB3_426
.LBB3_425:
	movq	%r13, %rbx
.LBB3_426:
	movabsq	$77309438687, %rax              # imm = 0x1200006ADF
	movq	%rax, 2064(%rbx)
	movq	$0, 2072(%rbx)
	leaq	384(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_583
# %bb.427:
	leaq	2072(%rbx), %rdi
	leaq	384(%rsp), %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movups	%xmm0, 27359(%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 27375(%r14)
	cmpq	$130, %r12
	jne	.LBB3_430
# %bb.428:
	movl	$4160, %esi                     # imm = 0x1040
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_615
# %bb.429:
	movq	%rax, %rbx
	movl	$260, %r12d                     # imm = 0x104
.LBB3_430:
	movabsq	$77309438705, %rax              # imm = 0x1200006AF1
	movq	%rax, 2080(%rbx)
	movq	$0, 2088(%rbx)
	movl	$1111905363, 2088(%rbx)         # imm = 0x42465453
	movb	$48, 2092(%rbx)
	movzwl	16(%r15), %eax
	movw	%ax, 27393(%r14)
	movups	(%r15), %xmm0
	movups	%xmm0, 27377(%r14)
	cmpq	$131, %r12
	jne	.LBB3_433
# %bb.431:
	movl	$4192, %esi                     # imm = 0x1060
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_616
# %bb.432:
	movq	%rax, %rbx
	movl	$262, %eax                      # imm = 0x106
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB3_434
.LBB3_433:
	movq	%r12, 8(%rsp)                   # 8-byte Spill
.LBB3_434:
	movabsq	$77309438723, %rax              # imm = 0x1200006B03
	movq	%rax, 2096(%rbx)
	movq	$0, 2104(%rbx)
	movl	$1094866003, 2104(%rbx)         # imm = 0x41425453
	movq	%rbx, 40(%rsp)                  # 8-byte Spill
	movb	$82, 2108(%rbx)
	movzwl	16(%r15), %eax
	movw	%ax, 27411(%r14)
	movups	(%r15), %xmm0
	movups	%xmm0, 27395(%r14)
	movl	$132, %ebx
	movl	$27413, %r14d                   # imm = 0x6B15
	movl	$4224, %ebp                     # imm = 0x1080
	movl	$264, %r13d                     # imm = 0x108
	leaq	384(%rsp), %r12
	xorl	%ecx, %ecx
	.p2align	4
.LBB3_435:                              # =>This Inner Loop Header: Depth=1
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.415(%rip), %rdx
	movl	%ecx, 56(%rsp)                  # 4-byte Spill
	xorl	%r8d, %r8d
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	8(%rsp), %rbx                   # 8-byte Folded Reload
	movq	%rbp, 376(%rsp)                 # 8-byte Spill
	jne	.LBB3_437
# %bb.436:                              #   in Loop: Header=BB3_435 Depth=1
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rbp, %rsi
	callq	realloc@PLT
	movq	%rax, %rbp
	movq	%r13, 8(%rsp)                   # 8-byte Spill
	testq	%rax, %rax
	movq	16(%rsp), %r15                  # 8-byte Reload
	jne	.LBB3_438
	jmp	.LBB3_517
	.p2align	4
.LBB3_437:                              #   in Loop: Header=BB3_435 Depth=1
	movq	16(%rsp), %r15                  # 8-byte Reload
	movq	40(%rsp), %rbp                  # 8-byte Reload
.LBB3_438:                              #   in Loop: Header=BB3_435 Depth=1
	movl	%r14d, (%rbp,%r13,8)
	movl	$18, 4(%rbp,%r13,8)
	movq	$0, 8(%rbp,%r13,8)
	leaq	384(%rsp), %r12
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_508
# %bb.439:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	8(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%r15), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, (%rcx,%r14)
	movzwl	16(%r15), %eax
	movw	%ax, 16(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.415(%rip), %rdx
	movl	56(%rsp), %ecx                  # 4-byte Reload
	movl	$1, %r8d
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%rbx
	movq	8(%rsp), %rax                   # 8-byte Reload
	cmpq	%rax, %rbx
	jne	.LBB3_442
# %bb.440:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %r15
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbp, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_518
# %bb.441:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %rbp
	addq	%r15, %r15
	movq	%r15, 8(%rsp)                   # 8-byte Spill
.LBB3_442:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	18(%r14), %r15
	movl	%r15d, 16(%rbp,%r13,8)
	movl	$18, 20(%rbp,%r13,8)
	movq	$0, 24(%rbp,%r13,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_509
# %bb.443:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	24(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 18(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 34(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.415(%rip), %rdx
	movl	56(%rsp), %ecx                  # 4-byte Reload
	movl	$2, %r8d
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%rbx
	movq	8(%rsp), %rax                   # 8-byte Reload
	cmpq	%rax, %rbx
	jne	.LBB3_446
# %bb.444:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbp, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_522
# %bb.445:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %rbp
	addq	%r12, %r12
	movq	%r12, 8(%rsp)                   # 8-byte Spill
	leaq	384(%rsp), %r12
.LBB3_446:                              #   in Loop: Header=BB3_435 Depth=1
	addq	$18, %r15
	movl	%r15d, 32(%rbp,%r13,8)
	movl	$18, 36(%rbp,%r13,8)
	movq	$0, 40(%rbp,%r13,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_511
# %bb.447:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	40(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 36(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 52(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.416(%rip), %rdx
	movl	56(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%rbx
	movq	8(%rsp), %rax                   # 8-byte Reload
	cmpq	%rax, %rbx
	jne	.LBB3_450
# %bb.448:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbp, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_519
# %bb.449:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %rbp
	addq	%r12, %r12
	movq	%r12, 8(%rsp)                   # 8-byte Spill
	leaq	384(%rsp), %r12
.LBB3_450:                              #   in Loop: Header=BB3_435 Depth=1
	addq	$18, %r15
	movl	%r15d, 48(%rbp,%r13,8)
	movl	$18, 52(%rbp,%r13,8)
	movq	$0, 56(%rbp,%r13,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_512
# %bb.451:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	56(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 54(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 70(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.417(%rip), %rdx
	movl	56(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%rbx
	movq	8(%rsp), %rax                   # 8-byte Reload
	cmpq	%rax, %rbx
	jne	.LBB3_454
# %bb.452:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbp, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_520
# %bb.453:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %rbp
	addq	%r12, %r12
	movq	%r12, 8(%rsp)                   # 8-byte Spill
	leaq	384(%rsp), %r12
.LBB3_454:                              #   in Loop: Header=BB3_435 Depth=1
	addq	$18, %r15
	movl	%r15d, 64(%rbp,%r13,8)
	movl	$18, 68(%rbp,%r13,8)
	movq	$0, 72(%rbp,%r13,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_513
# %bb.455:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	72(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 72(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 88(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.418(%rip), %rdx
	movl	56(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%rbx
	movq	8(%rsp), %rax                   # 8-byte Reload
	cmpq	%rax, %rbx
	jne	.LBB3_458
# %bb.456:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbp, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_521
# %bb.457:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %rbp
	addq	%r12, %r12
	movq	%r12, 8(%rsp)                   # 8-byte Spill
	leaq	384(%rsp), %r12
.LBB3_458:                              #   in Loop: Header=BB3_435 Depth=1
	addq	$18, %r15
	movl	%r15d, 80(%rbp,%r13,8)
	movl	$18, 84(%rbp,%r13,8)
	movq	$0, 88(%rbp,%r13,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_514
# %bb.459:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	88(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 90(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 106(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.419(%rip), %rdx
	movl	56(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%rbx
	movq	8(%rsp), %rax                   # 8-byte Reload
	cmpq	%rax, %rbx
	jne	.LBB3_462
# %bb.460:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbp, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_523
# %bb.461:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %rbp
	addq	%r12, %r12
	movq	%r12, 8(%rsp)                   # 8-byte Spill
	leaq	384(%rsp), %r12
.LBB3_462:                              #   in Loop: Header=BB3_435 Depth=1
	addq	$18, %r15
	movl	%r15d, 96(%rbp,%r13,8)
	movl	$18, 100(%rbp,%r13,8)
	movq	$0, 104(%rbp,%r13,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_515
# %bb.463:                              #   in Loop: Header=BB3_435 Depth=1
	leaq	104(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 108(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 124(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.420(%rip), %rdx
	movl	56(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%rbx
	movq	8(%rsp), %rax                   # 8-byte Reload
	cmpq	%rax, %rbx
	jne	.LBB3_466
# %bb.464:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbp, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_524
# %bb.465:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rax, %rbp
	addq	%r12, %r12
	movq	%r12, 8(%rsp)                   # 8-byte Spill
	leaq	384(%rsp), %r12
.LBB3_466:                              #   in Loop: Header=BB3_435 Depth=1
	addq	$18, %r15
	movl	%r15d, 112(%rbp,%r13,8)
	movl	$18, 116(%rbp,%r13,8)
	movq	$0, 120(%rbp,%r13,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_510
# %bb.467:                              #   in Loop: Header=BB3_435 Depth=1
	movq	%rbp, 40(%rsp)                  # 8-byte Spill
	leaq	120(,%r13,8), %rdi
	addq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 126(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 142(%rcx,%r14)
	movl	56(%rsp), %ecx                  # 4-byte Reload
	incl	%ecx
	movq	376(%rsp), %rbp                 # 8-byte Reload
	addq	$256, %rbp                      # imm = 0x100
	addq	$16, %r13
	incq	%rbx
	addq	$18, %r15
	movq	%r15, %r14
	cmpl	$344, %r13d                     # imm = 0x158
	jne	.LBB3_435
# %bb.468:
	movq	8(%rsp), %rcx                   # 8-byte Reload
	cmpq	$172, %rcx
	jne	.LBB3_471
# %bb.469:
	movl	$5504, %esi                     # imm = 0x1580
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	testq	%rax, %rax
	movq	48(%rsp), %rbp                  # 8-byte Reload
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	16(%rsp), %r14                  # 8-byte Reload
	je	.LBB3_617
# %bb.470:
	movq	%rax, %rdi
	movl	$344, %ecx                      # imm = 0x158
	jmp	.LBB3_472
.LBB3_471:
	movq	48(%rsp), %rbp                  # 8-byte Reload
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	16(%rsp), %r14                  # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
.LBB3_472:
	movabsq	$77309439461, %rax              # imm = 0x1200006DE5
	movq	%rax, 2752(%rdi)
	movq	$0, 2760(%rdi)
	movl	$1195791443, 2760(%rdi)         # imm = 0x47465453
	movl	$809783111, 2763(%rdi)          # imm = 0x30444F47
	movzwl	16(%r14), %eax
	movw	%ax, 28149(%rbx)
	movups	(%r14), %xmm0
	movups	%xmm0, 28133(%rbx)
	cmpq	$173, %rcx
	jne	.LBB3_475
# %bb.473:
	movl	$5536, %esi                     # imm = 0x15A0
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_618
# %bb.474:
	movq	%rax, %rdi
	movabsq	$77309439479, %rax              # imm = 0x1200006DF7
	movq	%rax, 2768(%rdi)
	movabsq	$3477976577990874195, %rax      # imm = 0x3044414544465453
	movq	%rax, 2776(%rdi)
	movzwl	16(%r14), %eax
	movw	%ax, 28167(%rbx)
	movups	(%r14), %xmm0
	movups	%xmm0, 28151(%rbx)
	movl	$346, %ecx                      # imm = 0x15A
	jmp	.LBB3_478
.LBB3_475:
	movabsq	$77309439479, %rax              # imm = 0x1200006DF7
	movq	%rax, 2768(%rdi)
	movabsq	$3477976577990874195, %rax      # imm = 0x3044414544465453
	movq	%rax, 2776(%rdi)
	movzwl	16(%r14), %eax
	movw	%ax, 28167(%rbx)
	movups	(%r14), %xmm0
	movups	%xmm0, 28151(%rbx)
	cmpq	$174, %rcx
	jne	.LBB3_487
# %bb.476:
	movl	$5568, %esi                     # imm = 0x15C0
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_620
# %bb.477:
	movq	%rax, %rdi
	movl	$348, %ecx                      # imm = 0x15C
.LBB3_478:
	movabsq	$77309439497, %rax              # imm = 0x1200006E09
	movq	%rax, 2784(%rdi)
	movabsq	$4848494732404607316, %rax      # imm = 0x434950454C544954
	movq	%rax, 2792(%rdi)
	movzwl	16(%r14), %eax
	movw	%ax, 28185(%rbx)
	movups	(%r14), %xmm0
	movups	%xmm0, 28169(%rbx)
.LBB3_479:
	movabsq	$77309439515, %rax              # imm = 0x1200006E1B
	movq	%rax, 2800(%rdi)
	movq	$0, 2808(%rdi)
	movl	$1145393731, 2808(%rdi)         # imm = 0x44455243
	movw	$21577, 2812(%rdi)              # imm = 0x5449
	movzwl	16(%r14), %eax
	movw	%ax, 28203(%rbx)
	movups	(%r14), %xmm0
	movups	%xmm0, 28187(%rbx)
	cmpq	$176, %rcx
	jne	.LBB3_481
# %bb.480:
	movl	$5632, %esi                     # imm = 0x1600
	callq	realloc@PLT
	movq	%rax, %rdi
	testq	%rax, %rax
	je	.LBB3_619
.LBB3_481:
	movabsq	$77309439533, %rax              # imm = 0x1200006E2D
	movq	%rax, 2816(%rdi)
	movq	$0, 2824(%rdi)
	movl	$1347175752, 2824(%rdi)         # imm = 0x504C4548
	movb	$50, 2828(%rdi)
	movzwl	16(%r14), %eax
	movw	%ax, 28221(%rbx)
	movups	(%r14), %xmm0
	movups	%xmm0, 28205(%rbx)
	movl	$28231, %eax                    # imm = 0x6E47
	.p2align	4
.LBB3_482:                              # =>This Inner Loop Header: Depth=1
	movl	-28231(%rdi,%rax), %ecx
	movl	%ecx, -8(%rbx,%rax)
	movl	-28227(%rdi,%rax), %ecx
	movl	%ecx, -4(%rbx,%rax)
	movq	-28223(%rdi,%rax), %rcx
	movq	%rcx, (%rbx,%rax)
	addq	$16, %rax
	cmpq	$31063, %rax                    # imm = 0x7957
	jne	.LBB3_482
# %bb.483:
	movq	%rdi, %r12
	movl	$1145132873, (%rbx)             # imm = 0x44415749
	movabsq	$121216861995185, %rax          # imm = 0x6E3F000000B1
	movq	%rax, 4(%rbx)
	movl	$31055, %r15d                   # imm = 0x794F
	movq	$-31015, %r13                   # imm = 0x86D9
	.p2align	4
.LBB3_484:                              # =>This Inner Loop Header: Depth=1
	cmpq	$1048496, %r15                  # imm = 0xFFFB0
	movl	$1048496, %r14d                 # imm = 0xFFFB0
	cmovbq	%r15, %r14
	cmpq	$1048536, %r15                  # imm = 0xFFFD8
	movl	$1048536, %edx                  # imm = 0xFFFD8
	cmovbq	%r15, %rdx
	addq	%r13, %rdx
	leaq	(%rbx,%r15), %rdi
	leaq	.L__const.build_generated_wad.pattern(%rip), %rsi
	callq	memcpy@PLT
	cmpq	$1048535, %r15                  # imm = 0xFFFD7
	ja	.LBB3_486
# %bb.485:                              #   in Loop: Header=BB3_484 Depth=1
	addq	%r13, %r14
	leaq	(%rbx,%r15), %rdi
	addq	$40, %rdi
	addq	$80, %r15
	leaq	.L__const.build_generated_wad.pattern(%rip), %rsi
	movq	%r14, %rdx
	callq	memcpy@PLT
	addq	$-80, %r13
	jmp	.LBB3_484
.LBB3_486:
	movq	%r12, %rdi
	callq	free@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	280(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movq	256(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movq	352(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movq	344(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movl	$1048576, %edx                  # imm = 0x100000
	movq	360(%rsp), %r12                 # 8-byte Reload
	jmp	.LBB3_23
.LBB3_487:
	movabsq	$77309439497, %rax              # imm = 0x1200006E09
	movq	%rax, 2784(%rdi)
	movabsq	$4848494732404607316, %rax      # imm = 0x434950454C544954
	movq	%rax, 2792(%rdi)
	movzwl	16(%r14), %eax
	movw	%ax, 28185(%rbx)
	movups	(%r14), %xmm0
	movups	%xmm0, 28169(%rbx)
	cmpq	$175, %rcx
	jne	.LBB3_479
# %bb.488:
	movl	$5600, %esi                     # imm = 0x15E0
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_621
# %bb.489:
	movq	%rax, %rdi
	movl	$350, %ecx                      # imm = 0x15E
	jmp	.LBB3_479
.LBB3_490:
	movq	%r12, %rdi
	callq	install_bootable_layout.cold.112
.LBB3_491:
	movq	%r14, %rdi
	callq	install_bootable_layout.cold.111
.LBB3_492:
	callq	install_bootable_layout.cold.124
.LBB3_493:
	leaq	.L.str.437(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_494:
	callq	install_bootable_layout.cold.107
.LBB3_495:
	leaq	.L.str.436(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_496:
	callq	install_bootable_layout.cold.108
.LBB3_497:
	callq	install_bootable_layout.cold.123
.LBB3_498:
	callq	install_bootable_layout.cold.109
.LBB3_499:
	callq	install_bootable_layout.cold.102
.LBB3_500:
	callq	install_bootable_layout.cold.101
.LBB3_501:
	callq	install_bootable_layout.cold.104
.LBB3_502:
	callq	install_bootable_layout.cold.103
.LBB3_503:
	callq	install_bootable_layout.cold.106
.LBB3_504:
	callq	install_bootable_layout.cold.105
.LBB3_505:
	leaq	.L.str.325(%rip), %rsi
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB3_506:
	callq	install_bootable_layout.cold.95
.LBB3_507:
	callq	install_bootable_layout.cold.90
.LBB3_508:
	callq	install_bootable_layout.cold.23
.LBB3_509:
	callq	install_bootable_layout.cold.21
.LBB3_510:
	callq	install_bootable_layout.cold.9
.LBB3_511:
	callq	install_bootable_layout.cold.19
.LBB3_512:
	callq	install_bootable_layout.cold.17
.LBB3_513:
	callq	install_bootable_layout.cold.15
.LBB3_514:
	callq	install_bootable_layout.cold.13
.LBB3_515:
	callq	install_bootable_layout.cold.11
.LBB3_516:
	callq	install_bootable_layout.cold.91
.LBB3_517:
	callq	install_bootable_layout.cold.24
.LBB3_518:
	callq	install_bootable_layout.cold.22
.LBB3_519:
	callq	install_bootable_layout.cold.18
.LBB3_520:
	callq	install_bootable_layout.cold.16
.LBB3_521:
	callq	install_bootable_layout.cold.14
.LBB3_522:
	callq	install_bootable_layout.cold.20
.LBB3_523:
	callq	install_bootable_layout.cold.12
.LBB3_524:
	callq	install_bootable_layout.cold.10
.LBB3_525:
	leaq	.L.str.435(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_526:
	leaq	.L.str.431(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_527:
	leaq	.L.str.433(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_528:
	leaq	.L.str.434(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_529:
	callq	install_bootable_layout.cold.1
.LBB3_530:
	callq	install_bootable_layout.cold.100
.LBB3_531:
	callq	install_bootable_layout.cold.125
.LBB3_532:
	callq	install_bootable_layout.cold.121
.LBB3_533:
	callq	install_bootable_layout.cold.119
.LBB3_534:
	callq	install_bootable_layout.cold.117
.LBB3_535:
	callq	install_bootable_layout.cold.116
.LBB3_536:
	leaq	.L.str.318(%rip), %rsi
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB3_537:
	leaq	.L.str.319(%rip), %rsi
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB3_538:
	leaq	.L.str.323(%rip), %rsi
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB3_539:
	leaq	.L.str.324(%rip), %rsi
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB3_540:
	leaq	.L.str.312(%rip), %rsi
	movq	%r15, %rdi
	callq	die_path
.LBB3_541:
	movq	%rdx, %rdi
	callq	install_bootable_layout.cold.3
.LBB3_542:
	movq	%rdx, %rdi
	callq	install_bootable_layout.cold.2
.LBB3_543:
	callq	install_bootable_layout.cold.110
.LBB3_544:
	leaq	.L.str.322(%rip), %rsi
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB3_545:
	callq	install_bootable_layout.cold.99
.LBB3_546:
	callq	install_bootable_layout.cold.98
.LBB3_547:
	callq	install_bootable_layout.cold.97
.LBB3_548:
	callq	install_bootable_layout.cold.96
.LBB3_549:
	callq	install_bootable_layout.cold.94
.LBB3_550:
	callq	install_bootable_layout.cold.93
.LBB3_551:
	callq	install_bootable_layout.cold.92
.LBB3_552:
	callq	install_bootable_layout.cold.89
.LBB3_553:
	callq	install_bootable_layout.cold.87
.LBB3_554:
	callq	install_bootable_layout.cold.86
.LBB3_555:
	callq	install_bootable_layout.cold.84
.LBB3_556:
	callq	install_bootable_layout.cold.83
.LBB3_557:
	callq	install_bootable_layout.cold.81
.LBB3_558:
	callq	install_bootable_layout.cold.80
.LBB3_559:
	callq	install_bootable_layout.cold.78
.LBB3_560:
	callq	install_bootable_layout.cold.76
.LBB3_561:
	callq	install_bootable_layout.cold.74
.LBB3_562:
	callq	install_bootable_layout.cold.71
.LBB3_563:
	callq	install_bootable_layout.cold.69
.LBB3_564:
	callq	install_bootable_layout.cold.67
.LBB3_565:
	callq	install_bootable_layout.cold.65
.LBB3_566:
	callq	install_bootable_layout.cold.63
.LBB3_567:
	callq	install_bootable_layout.cold.61
.LBB3_568:
	callq	install_bootable_layout.cold.59
.LBB3_569:
	callq	install_bootable_layout.cold.57
.LBB3_570:
	callq	install_bootable_layout.cold.55
.LBB3_571:
	callq	install_bootable_layout.cold.53
.LBB3_572:
	callq	install_bootable_layout.cold.50
.LBB3_573:
	callq	install_bootable_layout.cold.48
.LBB3_574:
	callq	install_bootable_layout.cold.46
.LBB3_575:
	callq	install_bootable_layout.cold.44
.LBB3_576:
	callq	install_bootable_layout.cold.42
.LBB3_577:
	callq	install_bootable_layout.cold.40
.LBB3_578:
	callq	install_bootable_layout.cold.37
.LBB3_579:
	callq	install_bootable_layout.cold.35
.LBB3_580:
	callq	install_bootable_layout.cold.33
.LBB3_581:
	callq	install_bootable_layout.cold.31
.LBB3_582:
	callq	install_bootable_layout.cold.29
.LBB3_583:
	callq	install_bootable_layout.cold.27
.LBB3_584:
	callq	install_bootable_layout.cold.88
.LBB3_585:
	callq	install_bootable_layout.cold.85
.LBB3_586:
	callq	install_bootable_layout.cold.82
.LBB3_587:
	callq	install_bootable_layout.cold.79
.LBB3_588:
	callq	install_bootable_layout.cold.77
.LBB3_589:
	callq	install_bootable_layout.cold.75
.LBB3_590:
	callq	install_bootable_layout.cold.73
.LBB3_591:
	callq	install_bootable_layout.cold.72
.LBB3_592:
	callq	install_bootable_layout.cold.70
.LBB3_593:
	callq	install_bootable_layout.cold.68
.LBB3_594:
	callq	install_bootable_layout.cold.66
.LBB3_595:
	callq	install_bootable_layout.cold.64
.LBB3_596:
	callq	install_bootable_layout.cold.62
.LBB3_597:
	callq	install_bootable_layout.cold.60
.LBB3_598:
	callq	install_bootable_layout.cold.58
.LBB3_599:
	callq	install_bootable_layout.cold.56
.LBB3_600:
	callq	install_bootable_layout.cold.54
.LBB3_601:
	callq	install_bootable_layout.cold.52
.LBB3_602:
	callq	install_bootable_layout.cold.51
.LBB3_603:
	callq	install_bootable_layout.cold.49
.LBB3_604:
	callq	install_bootable_layout.cold.47
.LBB3_605:
	callq	install_bootable_layout.cold.45
.LBB3_606:
	callq	install_bootable_layout.cold.43
.LBB3_607:
	callq	install_bootable_layout.cold.41
.LBB3_608:
	callq	install_bootable_layout.cold.39
.LBB3_609:
	callq	install_bootable_layout.cold.38
.LBB3_610:
	callq	install_bootable_layout.cold.36
.LBB3_611:
	callq	install_bootable_layout.cold.34
.LBB3_612:
	callq	install_bootable_layout.cold.32
.LBB3_613:
	callq	install_bootable_layout.cold.30
.LBB3_614:
	callq	install_bootable_layout.cold.28
.LBB3_615:
	callq	install_bootable_layout.cold.26
.LBB3_616:
	callq	install_bootable_layout.cold.25
.LBB3_617:
	callq	install_bootable_layout.cold.8
.LBB3_618:
	callq	install_bootable_layout.cold.7
.LBB3_619:
	callq	install_bootable_layout.cold.6
.LBB3_620:
	callq	install_bootable_layout.cold.5
.LBB3_621:
	callq	install_bootable_layout.cold.4
.Lfunc_end3:
	.size	install_bootable_layout, .Lfunc_end3-install_bootable_layout
                                        # -- End function
	.p2align	4                               # -- Begin function write_file
	.type	write_file,@function
write_file:                             # @write_file
# %bb.0:
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	%rdx, %r14
	movq	%rsi, %r12
	movq	%rdi, %rbx
	leaq	.L.str.512(%rip), %rsi
	callq	fopen@PLT
	testq	%rax, %rax
	je	.LBB4_4
# %bb.1:
	movq	%rax, %r15
	testq	%r14, %r14
	je	.LBB4_3
# %bb.2:
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%r14, %rdx
	movq	%r15, %rcx
	callq	fwrite@PLT
	cmpq	%r14, %rax
	jne	.LBB4_5
.LBB4_3:
	movq	%r15, %rdi
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	jmp	fclose@PLT                      # TAILCALL
.LBB4_4:
	movq	%rbx, %rdi
	callq	write_file.cold.1
.LBB4_5:
	leaq	.L.str.513(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end4:
	.size	write_file, .Lfunc_end4-write_file
                                        # -- End function
	.p2align	4                               # -- Begin function read_file
	.type	read_file,@function
read_file:                              # @read_file
# %bb.0:
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	%rdi, %rbx
	leaq	.L.str.31(%rip), %rsi
	callq	fopen@PLT
	testq	%rax, %rax
	je	.LBB5_8
# %bb.1:
	movq	%rax, %r14
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$2, %edx
	callq	fseek@PLT
	testl	%eax, %eax
	jne	.LBB5_9
# %bb.2:
	movq	%r14, %rdi
	callq	ftell@PLT
	testq	%rax, %rax
	js	.LBB5_10
# %bb.3:
	movq	%rax, %r15
	movq	%r14, %rdi
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	fseek@PLT
	testl	%eax, %eax
	jne	.LBB5_9
# %bb.4:
	leaq	1(%r15), %rdi
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB5_11
# %bb.5:
	movq	%rax, %r12
	testq	%r15, %r15
	je	.LBB5_7
# %bb.6:
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%r15, %rdx
	movq	%r14, %rcx
	callq	fread@PLT
	cmpq	%r15, %rax
	jne	.LBB5_12
.LBB5_7:
	movq	%r14, %rdi
	callq	fclose@PLT
	movq	%r12, %rax
	movq	%r15, %rdx
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	retq
.LBB5_9:
	leaq	.L.str.32(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB5_8:
	movq	%rbx, %rdi
	callq	read_file.cold.2
.LBB5_10:
	leaq	.L.str.33(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB5_11:
	callq	read_file.cold.1
.LBB5_12:
	leaq	.L.str.34(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end5:
	.size	read_file, .Lfunc_end5-read_file
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function die_path
	.type	die_path,@function
die_path:                               # @die_path
# %bb.0:
	pushq	%rax
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.35(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end6:
	.size	die_path, .Lfunc_end6-die_path
                                        # -- End function
	.text
	.p2align	4                               # -- Begin function write_file_path
	.type	write_file_path,@function
write_file_path:                        # @write_file_path
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
	movl	%r9d, 4(%rsp)                   # 4-byte Spill
	movq	%r8, %rbx
	movq	%rcx, %r8
	movq	%rdx, %r15
	movq	%rsi, %r12
	movq	%rdi, %r13
	cmpq	$1, %rdx
	je	.LBB7_7
# %bb.1:
	movq	%r8, 8(%rsp)                    # 8-byte Spill
	testq	%r15, %r15
	je	.LBB7_24
# %bb.2:
	leaq	-1(%r15), %rbp
	xorl	%eax, %eax
	movq	%r12, %r14
	.p2align	4
.LBB7_3:                                # =>This Inner Loop Header: Depth=1
	movq	%r13, %rdi
	movl	%eax, %esi
	movq	%r14, %rdx
	movl	$17, %ecx
	callq	ensure_child_directory
                                        # kill: def $eax killed $eax def $rax
	addq	$11, %r14
	decq	%rbp
	jne	.LBB7_3
# %bb.4:
	testl	%eax, %eax
	movq	8(%rsp), %r8                    # 8-byte Reload
	je	.LBB7_7
# %bb.5:
	leal	-64241(%rax), %ecx
	cmpl	$-64240, %ecx                   # imm = 0xFFFF0510
	jbe	.LBB7_6
# %bb.8:
	movq	(%r13), %rcx
	shll	$10, %eax
	leaq	(%rcx,%rax), %rbp
	addq	$1325568, %rbp                  # imm = 0x143A00
	movl	$1024, %r14d                    # imm = 0x400
	jmp	.LBB7_9
.LBB7_7:
	movl	$1311232, %ebp                  # imm = 0x140200
	addq	(%r13), %rbp
	movl	$16384, %r14d                   # imm = 0x4000
.LBB7_9:
	leaq	20(%rsp), %rcx
	movq	%r13, %rdi
	movq	%r8, %rsi
	movq	%rbx, %rdx
	callq	write_cluster_chain
	leaq	(%r15,%r15,4), %rcx
	leaq	(%r15,%rcx,2), %rcx
	addq	%r12, %rcx
	addq	$-11, %rcx
	leaq	-32(%r14), %rdx
	xorl	%edi, %edi
	xorl	%esi, %esi
	jmp	.LBB7_10
	.p2align	4
.LBB7_13:                               #   in Loop: Header=BB7_10 Depth=1
	incl	%esi
	movq	%rsi, %r8
	shlq	$5, %r8
	addl	$32, %edi
	cmpq	%rdx, %r8
	ja	.LBB7_14
.LBB7_10:                               # =>This Inner Loop Header: Depth=1
	movl	%edi, %edi
	movzbl	(%rbp,%rdi), %r8d
	cmpl	$229, %r8d
	je	.LBB7_13
# %bb.11:                               #   in Loop: Header=BB7_10 Depth=1
	testl	%r8d, %r8d
	je	.LBB7_14
# %bb.12:                               #   in Loop: Header=BB7_10 Depth=1
	movq	(%rbp,%rdi), %r8
	xorq	(%rcx), %r8
	movq	3(%rbp,%rdi), %r9
	xorq	3(%rcx), %r9
	orq	%r8, %r9
	jne	.LBB7_13
.LBB7_22:
	movl	%esi, %edx
	shlq	$5, %rdx
	cmpq	%r14, %rdx
	jae	.LBB7_23
# %bb.25:
	xorps	%xmm0, %xmm0
	movups	%xmm0, 16(%rbp,%rdx)
	movups	%xmm0, (%rbp,%rdx)
	movq	(%rcx), %rsi
	movq	%rsi, (%rbp,%rdx)
	movl	7(%rcx), %ecx
	movl	%ecx, 7(%rbp,%rdx)
	movl	4(%rsp), %ecx                   # 4-byte Reload
	movb	%cl, 11(%rbp,%rdx)
	movb	%al, 26(%rbp,%rdx)
	movb	%ah, 27(%rbp,%rdx)
	movb	%bl, 28(%rbp,%rdx)
	movb	%bh, 29(%rbp,%rdx)
	movl	%ebx, %eax
	shrl	$16, %eax
	movb	%al, 30(%rbp,%rdx)
	shrl	$24, %ebx
	movb	%bl, 31(%rbp,%rdx)
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB7_14:
	xorl	%edi, %edi
                                        # implicit-def: $r9d
	xorl	%r8d, %r8d
	.p2align	4
.LBB7_15:                               # =>This Inner Loop Header: Depth=1
	movl	%edi, %esi
	movzbl	(%rbp,%rsi), %r10d
	movl	%r8d, %esi
	testl	%r10d, %r10d
	je	.LBB7_18
# %bb.16:                               #   in Loop: Header=BB7_15 Depth=1
	movl	%r8d, %esi
	cmpl	$229, %r10d
	je	.LBB7_18
# %bb.17:                               #   in Loop: Header=BB7_15 Depth=1
	movl	%r9d, %esi
.LBB7_18:                               #   in Loop: Header=BB7_15 Depth=1
	testl	%r10d, %r10d
	je	.LBB7_22
# %bb.19:                               #   in Loop: Header=BB7_15 Depth=1
	cmpl	$229, %r10d
	je	.LBB7_22
# %bb.20:                               #   in Loop: Header=BB7_15 Depth=1
	incl	%r8d
	movq	%r8, %r10
	shlq	$5, %r10
	addl	$32, %edi
	movl	%esi, %r9d
	cmpq	%rdx, %r10
	jbe	.LBB7_15
# %bb.21:
	callq	write_file_path.cold.3
.LBB7_23:
	callq	write_file_path.cold.4
.LBB7_24:
	callq	write_file_path.cold.1
.LBB7_6:
	callq	write_file_path.cold.2
.Lfunc_end7:
	.size	write_file_path, .Lfunc_end7-write_file_path
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory
	.type	ensure_child_directory,@function
ensure_child_directory:                 # @ensure_child_directory
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
	movq	%rdx, %r15
	movl	%esi, %ebx
	movq	%rdi, %r14
	testl	%esi, %esi
	je	.LBB8_3
# %bb.1:
	leal	-64241(%rbx), %eax
	cmpl	$-64240, %eax                   # imm = 0xFFFF0510
	jbe	.LBB8_2
# %bb.4:
	movq	(%r14), %rax
	movl	%ebx, %edx
	shll	$10, %edx
	leaq	(%rax,%rdx), %r12
	addq	$1325568, %r12                  # imm = 0x143A00
	movl	$1024, %r8d                     # imm = 0x400
	jmp	.LBB8_5
.LBB8_3:
	movl	$1311232, %r12d                 # imm = 0x140200
	addq	(%r14), %r12
	movl	$16384, %r8d                    # imm = 0x4000
.LBB8_5:
	leaq	-32(%r8), %rbp
	xorl	%eax, %eax
	xorl	%edi, %edi
	jmp	.LBB8_6
	.p2align	4
.LBB8_9:                                #   in Loop: Header=BB8_6 Depth=1
	incl	%edi
	movq	%rdi, %rdx
	shlq	$5, %rdx
	addl	$32, %eax
	cmpq	%rbp, %rdx
	ja	.LBB8_10
.LBB8_6:                                # =>This Inner Loop Header: Depth=1
	movl	%eax, %eax
	movzbl	(%r12,%rax), %edx
	cmpl	$229, %edx
	je	.LBB8_9
# %bb.7:                                #   in Loop: Header=BB8_6 Depth=1
	testl	%edx, %edx
	je	.LBB8_10
# %bb.8:                                #   in Loop: Header=BB8_6 Depth=1
	movq	(%r12,%rax), %rdx
	xorq	(%r15), %rdx
	movq	3(%r12,%rax), %rsi
	xorq	3(%r15), %rsi
	orq	%rdx, %rsi
	jne	.LBB8_9
# %bb.18:
	movl	%edi, %eax
	shlq	$5, %rax
	movzbl	11(%r12,%rax), %edx
	testb	$16, %dl
	je	.LBB8_27
# %bb.19:
	testb	$1, %cl
	je	.LBB8_21
# %bb.20:
	orb	$1, %dl
	movb	%dl, 11(%r12,%rax)
.LBB8_21:
	movq	%rax, %rcx
	orq	$28, %rcx
	cmpq	%r8, %rcx
	ja	.LBB8_28
# %bb.22:
	movzwl	26(%r12,%rax), %eax
	jmp	.LBB8_26
.LBB8_10:
	movq	%r8, 8(%rsp)                    # 8-byte Spill
	movl	%ecx, 4(%rsp)                   # 4-byte Spill
	movb	$0, 3(%rsp)
	xorl	%r13d, %r13d
	leaq	3(%rsp), %rsi
	leaq	20(%rsp), %rcx
	movq	%r14, %rdi
	xorl	%edx, %edx
	callq	write_cluster_chain
                                        # kill: def $eax killed $eax def $rax
                                        # implicit-def: $esi
	xorl	%ecx, %ecx
	.p2align	4
.LBB8_11:                               # =>This Inner Loop Header: Depth=1
	movl	%r13d, %edx
	movzbl	(%r12,%rdx), %edi
	movl	%ecx, %edx
	testl	%edi, %edi
	je	.LBB8_14
# %bb.12:                               #   in Loop: Header=BB8_11 Depth=1
	movl	%ecx, %edx
	cmpl	$229, %edi
	je	.LBB8_14
# %bb.13:                               #   in Loop: Header=BB8_11 Depth=1
	movl	%esi, %edx
.LBB8_14:                               #   in Loop: Header=BB8_11 Depth=1
	testl	%edi, %edi
	je	.LBB8_23
# %bb.15:                               #   in Loop: Header=BB8_11 Depth=1
	cmpl	$229, %edi
	je	.LBB8_23
# %bb.16:                               #   in Loop: Header=BB8_11 Depth=1
	incl	%ecx
	movq	%rcx, %rdi
	shlq	$5, %rdi
	addl	$32, %r13d
	movl	%edx, %esi
	cmpq	%rbp, %rdi
	jbe	.LBB8_11
# %bb.17:
	callq	ensure_child_directory.cold.4
.LBB8_23:
	movl	%edx, %ecx
	shlq	$5, %rcx
	cmpq	8(%rsp), %rcx                   # 8-byte Folded Reload
	jae	.LBB8_29
# %bb.24:
	xorps	%xmm0, %xmm0
	movups	%xmm0, 16(%r12,%rcx)
	movups	%xmm0, (%r12,%rcx)
	movq	(%r15), %rdx
	movq	%rdx, (%r12,%rcx)
	movl	7(%r15), %edx
	movl	%edx, 7(%r12,%rcx)
	movl	4(%rsp), %r8d                   # 4-byte Reload
	movb	%r8b, 11(%r12,%rcx)
	movb	%al, 26(%r12,%rcx)
	movl	%eax, %edx
	shrl	$8, %edx
	movb	%dl, 27(%r12,%rcx)
	leal	-64241(%rax), %esi
	movl	$0, 28(%r12,%rcx)
	cmpl	$-64240, %esi                   # imm = 0xFFFF0510
	jbe	.LBB8_30
# %bb.25:
	movq	(%r14), %rcx
	movl	%eax, %esi
	shlq	$10, %rsi
	movups	%xmm0, 1325580(%rcx,%rsi)
	movabsq	$2314885530818453550, %rdi      # imm = 0x202020202020202E
	movq	%rdi, 1325568(%rcx,%rsi)
	movl	$538976288, 1325575(%rcx,%rsi)  # imm = 0x20202020
	movb	%r8b, 1325579(%rcx,%rsi)
	movb	%al, 1325594(%rcx,%rsi)
	movb	%dl, 1325595(%rcx,%rsi)
	movups	%xmm0, 1325596(%rcx,%rsi)
	movups	%xmm0, 1325612(%rcx,%rsi)
	movabsq	$2314885530818457134, %rdx      # imm = 0x2020202020202E2E
	movq	%rdx, 1325600(%rcx,%rsi)
	movl	$538976288, 1325607(%rcx,%rsi)  # imm = 0x20202020
	movb	$16, 1325611(%rcx,%rsi)
	movb	%bl, 1325626(%rcx,%rsi)
	movb	%bh, 1325627(%rcx,%rsi)
	movl	$0, 1325628(%rcx,%rsi)
.LBB8_26:
                                        # kill: def $eax killed $eax killed $rax
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB8_29:
	callq	ensure_child_directory.cold.2
.LBB8_30:
	callq	ensure_child_directory.cold.3
.LBB8_2:
	callq	ensure_child_directory.cold.1
.LBB8_27:
	callq	ensure_child_directory.cold.6
.LBB8_28:
	callq	ensure_child_directory.cold.5
.Lfunc_end8:
	.size	ensure_child_directory, .Lfunc_end8-ensure_child_directory
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain
	.type	write_cluster_chain,@function
write_cluster_chain:                    # @write_cluster_chain
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movq	%rcx, %r14
	movq	%rsi, 32(%rsp)                  # 8-byte Spill
	movq	%rdi, %r12
	movq	%rdx, 16(%rsp)                  # 8-byte Spill
	leaq	1023(%rdx), %rbx
	shrq	$10, %rbx
	cmpl	$2, %ebx
	movl	$1, %r13d
	cmovael	%ebx, %r13d
	movl	$4, %esi
	movq	%r13, %rdi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB9_25
# %bb.1:
	movq	%rax, %rbp
	leaq	20(%r12), %rcx
	xorl	%eax, %eax
	movl	$2, %edx
	.p2align	4
.LBB9_2:                                # =>This Inner Loop Header: Depth=1
	cmpw	$0, (%rcx)
	jne	.LBB9_4
# %bb.3:                                #   in Loop: Header=BB9_2 Depth=1
	movl	%eax, %esi
	incl	%eax
	movl	%edx, (%rbp,%rsi,4)
.LBB9_4:                                #   in Loop: Header=BB9_2 Depth=1
	cmpq	$64239, %rdx                    # imm = 0xFAEF
	ja	.LBB9_5
# %bb.9:                                #   in Loop: Header=BB9_2 Depth=1
	incq	%rdx
	addq	$2, %rcx
	cmpl	%r13d, %eax
	jb	.LBB9_2
.LBB9_5:
	cmpl	%r13d, %eax
	jne	.LBB9_10
# %bb.6:
	movq	%r14, 24(%rsp)                  # 8-byte Spill
	movl	(%rbp), %r8d
	movl	%r8d, %esi
	cmpl	$2, %ebx
	jb	.LBB9_17
# %bb.7:
	leaq	-1(%r13), %rsi
	movl	%esi, %eax
	andl	$3, %eax
	leal	-2(%r13), %ecx
	cmpl	$3, %ecx
	jae	.LBB9_11
# %bb.8:
	movl	$1, %edx
	movl	%r8d, %ecx
	jmp	.LBB9_14
.LBB9_11:
	andq	$-4, %rsi
	xorl	%edx, %edx
	movl	%r8d, %ecx
	.p2align	4
.LBB9_12:                               # =>This Inner Loop Header: Depth=1
	movl	4(%rbp,%rdx,4), %edi
	movl	%ecx, %ecx
	movw	%di, 16(%r12,%rcx,2)
	movl	8(%rbp,%rdx,4), %ecx
	movw	%cx, 16(%r12,%rdi,2)
	movl	12(%rbp,%rdx,4), %edi
	movw	%di, 16(%r12,%rcx,2)
	movl	16(%rbp,%rdx,4), %ecx
	movw	%cx, 16(%r12,%rdi,2)
	addq	$4, %rdx
	cmpq	%rdx, %rsi
	jne	.LBB9_12
# %bb.13:
	incq	%rdx
.LBB9_14:
	movl	%ecx, %esi
	testq	%rax, %rax
	je	.LBB9_17
# %bb.15:
	leaq	(,%rdx,4), %rdx
	addq	%rbp, %rdx
	xorl	%edi, %edi
	.p2align	4
.LBB9_16:                               # =>This Inner Loop Header: Depth=1
	movl	(%rdx,%rdi,4), %esi
	movl	%ecx, %ecx
	movw	%si, 16(%r12,%rcx,2)
	incq	%rdi
	movl	%esi, %ecx
	cmpq	%rdi, %rax
	jne	.LBB9_16
.LBB9_17:
	movl	%r8d, 12(%rsp)                  # 4-byte Spill
	movl	%esi, %eax
	movw	$-1, 16(%r12,%rax,2)
	xorl	%r15d, %r15d
	movq	16(%rsp), %rbx                  # 8-byte Reload
	jmp	.LBB9_18
	.p2align	4
.LBB9_22:                               #   in Loop: Header=BB9_18 Depth=1
	shlq	$10, %rax
	movq	(%r12), %rcx
	leaq	(%rcx,%rax), %rdi
	addq	$1325568, %rdi                  # imm = 0x143A00
	movq	16(%rsp), %rsi                  # 8-byte Reload
	subq	%rbx, %rsi
	addq	32(%rsp), %rsi                  # 8-byte Folded Reload
	movq	%r14, %rdx
	callq	memcpy@PLT
.LBB9_23:                               #   in Loop: Header=BB9_18 Depth=1
	subq	%r14, %rbx
	incq	%r15
	cmpq	%r15, %r13
	je	.LBB9_24
.LBB9_18:                               # =>This Inner Loop Header: Depth=1
	movl	(%rbp,%r15,4), %eax
	leal	-64241(%rax), %ecx
	cmpl	$-64240, %ecx                   # imm = 0xFFFF0510
	jbe	.LBB9_26
# %bb.19:                               #   in Loop: Header=BB9_18 Depth=1
	movl	$1024, %r14d                    # imm = 0x400
	cmpq	$1023, %rbx                     # imm = 0x3FF
	ja	.LBB9_22
# %bb.20:                               #   in Loop: Header=BB9_18 Depth=1
	movq	%rbx, %r14
	testq	%rbx, %rbx
	jne	.LBB9_22
# %bb.21:                               #   in Loop: Header=BB9_18 Depth=1
	xorl	%r14d, %r14d
	jmp	.LBB9_23
.LBB9_24:
	movq	%rbp, %rdi
	callq	free@PLT
	movq	24(%rsp), %rax                  # 8-byte Reload
	movl	%r13d, (%rax)
	movl	12(%rsp), %eax                  # 4-byte Reload
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB9_26:
	callq	write_cluster_chain.cold.2
.LBB9_25:
	callq	write_cluster_chain.cold.3
.LBB9_10:
	callq	write_cluster_chain.cold.1
.Lfunc_end9:
	.size	write_cluster_chain, .Lfunc_end9-write_cluster_chain
                                        # -- End function
	.p2align	4                               # -- Begin function validate_image_layout
	.type	validate_image_layout,@function
validate_image_layout:                  # @validate_image_layout
# %bb.0:
	pushq	%rax
	cmpq	$67108864, 8(%rdi)              # imm = 0x4000000
	jne	.LBB10_1
# %bb.3:
	movq	(%rdi), %rax
	cmpw	$-21931, 510(%rax)              # imm = 0xAA55
	jne	.LBB10_4
# %bb.5:
	cmpl	$2048, 454(%rax)                # imm = 0x800
	jne	.LBB10_7
# %bb.6:
	cmpl	$129024, 458(%rax)              # imm = 0x1F800
	jne	.LBB10_7
# %bb.8:
	cmpw	$-21931, 1049086(%rax)          # imm = 0xAA55
	jne	.LBB10_9
# %bb.10:
	cmpw	$512, 1048587(%rax)             # imm = 0x200
	jne	.LBB10_11
# %bb.12:
	cmpb	$2, 1048589(%rax)
	jne	.LBB10_13
# %bb.14:
	popq	%rax
	retq
.LBB10_1:
	leaq	.L.str.61(%rip), %rax
	jmp	.LBB10_2
.LBB10_4:
	leaq	.L.str.62(%rip), %rax
	jmp	.LBB10_2
.LBB10_7:
	leaq	.L.str.63(%rip), %rax
	jmp	.LBB10_2
.LBB10_9:
	leaq	.L.str.64(%rip), %rax
	jmp	.LBB10_2
.LBB10_11:
	leaq	.L.str.65(%rip), %rax
	jmp	.LBB10_2
.LBB10_13:
	leaq	.L.str.66(%rip), %rax
.LBB10_2:
	movq	%rsi, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end10:
	.size	validate_image_layout, .Lfunc_end10-validate_image_layout
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status
	.type	check_write_status,@function
check_write_status:                     # @check_write_status
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	subq	$16, %rsp
	testq	%rdi, %rdi
	je	.LBB11_101
# %bb.1:
	movl	%esi, %ebp
	movq	%rdi, %rbx
	callq	read_file
	movq	%rax, (%rsp)
	movq	%rdx, 8(%rsp)
	testq	%rax, %rax
	je	.LBB11_101
# %bb.2:
	movq	%rax, %r14
	movq	%rdx, %r15
	testl	%ebp, %ebp
	je	.LBB11_53
# %bb.3:
	cmpq	$7, %r15
	jb	.LBB11_13
# %bb.4:
	movl	$1702257011, %eax               # imm = 0x65766173
	xorl	(%r14), %eax
	movzwl	4(%r14), %ecx
	xorl	$29303, %ecx                    # imm = 0x7277
	orl	%eax, %ecx
	movabsq	$4294976512, %r12               # imm = 0x100002400
	jne	.LBB11_6
# %bb.5:
	cmpb	$61, 6(%r14)
	movq	%r14, %rax
	je	.LBB11_15
.LBB11_6:
	leaq	-6(%r15), %rax
	cmpq	$1, %rax
	je	.LBB11_13
# %bb.7:
	leaq	-7(%r15), %rcx
	xorl	%eax, %eax
	movl	$1702257011, %edx               # imm = 0x65766173
	jmp	.LBB11_8
	.p2align	4
.LBB11_12:                              #   in Loop: Header=BB11_8 Depth=1
	incq	%rax
	cmpq	%rax, %rcx
	je	.LBB11_13
.LBB11_8:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %esi
	cmpq	$32, %rsi
	ja	.LBB11_12
# %bb.9:                                #   in Loop: Header=BB11_8 Depth=1
	btq	%rsi, %r12
	jae	.LBB11_12
# %bb.10:                               #   in Loop: Header=BB11_8 Depth=1
	movl	1(%r14,%rax), %esi
	xorl	%edx, %esi
	movzwl	5(%r14,%rax), %edi
	xorl	$29303, %edi                    # imm = 0x7277
	orl	%esi, %edi
	jne	.LBB11_12
# %bb.11:                               #   in Loop: Header=BB11_8 Depth=1
	cmpb	$61, 7(%r14,%rax)
	jne	.LBB11_12
# %bb.14:
	addq	%r14, %rax
	incq	%rax
.LBB11_15:
	movzbl	7(%rax), %edi
	testb	%dil, %dil
	je	.LBB11_102
# %bb.16:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
.LBB11_17:                              # =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	.LBB11_19
# %bb.18:                               #   in Loop: Header=BB11_17 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	.LBB11_24
	jmp	.LBB11_25
	.p2align	4
.LBB11_19:                              #   in Loop: Header=BB11_17 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	.LBB11_21
# %bb.20:                               #   in Loop: Header=BB11_17 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	.LBB11_24
	jmp	.LBB11_25
	.p2align	4
.LBB11_21:                              #   in Loop: Header=BB11_17 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	.LBB11_25
# %bb.22:                               #   in Loop: Header=BB11_17 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	.LBB11_25
.LBB11_24:                              #   in Loop: Header=BB11_17 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	8(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	.LBB11_17
	jmp	.LBB11_26
.LBB11_101:
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB11_53:
	cmpq	$10, %r15
	jb	.LBB11_63
# %bb.54:
	movabsq	$8388361638216953700, %rdx      # imm = 0x746972776D6F6F64
	leaq	-9(%r15), %rax
	movq	(%r14), %rcx
	xorq	%rdx, %rcx
	movzbl	8(%r14), %esi
	xorq	$101, %rsi
	orq	%rcx, %rsi
	jne	.LBB11_56
# %bb.55:
	cmpb	$61, 9(%r14)
	movq	%r14, %rcx
	je	.LBB11_65
.LBB11_56:
	cmpq	$1, %rax
	je	.LBB11_63
# %bb.57:
	leaq	-10(%r15), %rsi
	xorl	%ecx, %ecx
	movabsq	$4294976512, %rdi               # imm = 0x100002400
	jmp	.LBB11_58
	.p2align	4
.LBB11_62:                              #   in Loop: Header=BB11_58 Depth=1
	incq	%rcx
	cmpq	%rcx, %rsi
	je	.LBB11_63
.LBB11_58:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rcx), %r8d
	cmpq	$32, %r8
	ja	.LBB11_62
# %bb.59:                               #   in Loop: Header=BB11_58 Depth=1
	btq	%r8, %rdi
	jae	.LBB11_62
# %bb.60:                               #   in Loop: Header=BB11_58 Depth=1
	movq	1(%r14,%rcx), %r8
	xorq	%rdx, %r8
	movzbl	9(%r14,%rcx), %r9d
	xorq	$101, %r9
	orq	%r8, %r9
	jne	.LBB11_62
# %bb.61:                               #   in Loop: Header=BB11_58 Depth=1
	cmpb	$61, 10(%r14,%rcx)
	jne	.LBB11_62
# %bb.64:
	addq	%r14, %rcx
	incq	%rcx
.LBB11_65:
	movzbl	10(%rcx), %r8d
	testb	%r8b, %r8b
	je	.LBB11_105
# %bb.66:
	xorl	%esi, %esi
	xorl	%edx, %edx
	.p2align	4
.LBB11_67:                              # =>This Inner Loop Header: Depth=1
	movsbl	%r8b, %edi
	leal	-48(%rdi), %r9d
	cmpb	$9, %r9b
	ja	.LBB11_69
# %bb.68:                               #   in Loop: Header=BB11_67 Depth=1
	addl	$-48, %edi
	testl	%edi, %edi
	jns	.LBB11_74
	jmp	.LBB11_75
	.p2align	4
.LBB11_69:                              #   in Loop: Header=BB11_67 Depth=1
	leal	-97(%r8), %r9d
	cmpb	$5, %r9b
	ja	.LBB11_71
# %bb.70:                               #   in Loop: Header=BB11_67 Depth=1
	addl	$-87, %edi
	testl	%edi, %edi
	jns	.LBB11_74
	jmp	.LBB11_75
	.p2align	4
.LBB11_71:                              #   in Loop: Header=BB11_67 Depth=1
	addb	$-65, %r8b
	cmpb	$5, %r8b
	ja	.LBB11_75
# %bb.72:                               #   in Loop: Header=BB11_67 Depth=1
	addl	$-55, %edi
	testl	%edi, %edi
	js	.LBB11_75
.LBB11_74:                              #   in Loop: Header=BB11_67 Depth=1
	shll	$4, %edx
	orl	%edi, %edx
	movzbl	11(%rcx,%rsi), %r8d
	incq	%rsi
	testb	%r8b, %r8b
	jne	.LBB11_67
	jmp	.LBB11_76
.LBB11_25:
	testl	%edx, %edx
	je	.LBB11_102
.LBB11_26:
	testl	%ecx, %ecx
	je	.LBB11_103
# %bb.27:
	leaq	.L.str.88(%rip), %rsi
	movq	%rsp, %rdi
	movl	$1, %edx
	callq	status_hex_tuple_part
	testl	%eax, %eax
	je	.LBB11_103
# %bb.28:
	cmpq	$10, %r15
	jb	.LBB11_38
# %bb.29:
	movabsq	$8317986210936414579, %rcx      # imm = 0x736F6C6365766173
	movq	(%r14), %rax
	xorq	%rcx, %rax
	movzbl	8(%r14), %edx
	xorq	$101, %rdx
	orq	%rax, %rdx
	jne	.LBB11_31
# %bb.30:
	cmpb	$61, 9(%r14)
	movq	%r14, %rax
	je	.LBB11_40
.LBB11_31:
	leaq	-9(%r15), %rax
	cmpq	$1, %rax
	je	.LBB11_38
# %bb.32:
	addq	$-10, %r15
	xorl	%eax, %eax
	jmp	.LBB11_33
	.p2align	4
.LBB11_37:                              #   in Loop: Header=BB11_33 Depth=1
	incq	%rax
	cmpq	%rax, %r15
	je	.LBB11_38
.LBB11_33:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %edx
	cmpq	$32, %rdx
	ja	.LBB11_37
# %bb.34:                               #   in Loop: Header=BB11_33 Depth=1
	btq	%rdx, %r12
	jae	.LBB11_37
# %bb.35:                               #   in Loop: Header=BB11_33 Depth=1
	movq	1(%r14,%rax), %rdx
	xorq	%rcx, %rdx
	movzbl	9(%r14,%rax), %esi
	xorq	$101, %rsi
	orq	%rdx, %rsi
	jne	.LBB11_37
# %bb.36:                               #   in Loop: Header=BB11_33 Depth=1
	cmpb	$61, 10(%r14,%rax)
	jne	.LBB11_37
# %bb.39:
	addq	%r14, %rax
	incq	%rax
.LBB11_40:
	movzbl	10(%rax), %edi
	testb	%dil, %dil
	je	.LBB11_104
# %bb.41:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
.LBB11_42:                              # =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	.LBB11_44
# %bb.43:                               #   in Loop: Header=BB11_42 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	.LBB11_49
	jmp	.LBB11_50
	.p2align	4
.LBB11_44:                              #   in Loop: Header=BB11_42 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	.LBB11_46
# %bb.45:                               #   in Loop: Header=BB11_42 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	.LBB11_49
	jmp	.LBB11_50
	.p2align	4
.LBB11_46:                              #   in Loop: Header=BB11_42 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	.LBB11_50
# %bb.47:                               #   in Loop: Header=BB11_42 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	.LBB11_50
.LBB11_49:                              #   in Loop: Header=BB11_42 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	11(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	.LBB11_42
	jmp	.LBB11_51
.LBB11_50:
	testl	%edx, %edx
	je	.LBB11_104
.LBB11_51:
	testl	%ecx, %ecx
	jne	.LBB11_100
# %bb.52:
	leaq	.L.str.91(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB11_75:
	testl	%esi, %esi
	je	.LBB11_105
.LBB11_76:
	testl	%edx, %edx
	je	.LBB11_106
# %bb.77:
	movabsq	$8317986210936414579, %rdx      # imm = 0x736F6C6365766173
	addq	$133762545, %rdx                # imm = 0x7F90DF1
	movq	(%r14), %rcx
	xorq	%rdx, %rcx
	movzbl	8(%r14), %esi
	xorq	$101, %rsi
	orq	%rcx, %rsi
	jne	.LBB11_79
# %bb.78:
	cmpb	$61, 9(%r14)
	movq	%r14, %rcx
	je	.LBB11_88
.LBB11_79:
	cmpq	$1, %rax
	je	.LBB11_86
# %bb.80:
	addq	$-10, %r15
	xorl	%eax, %eax
	movabsq	$4294976512, %rcx               # imm = 0x100002400
	jmp	.LBB11_81
	.p2align	4
.LBB11_85:                              #   in Loop: Header=BB11_81 Depth=1
	incq	%rax
	cmpq	%rax, %r15
	je	.LBB11_86
.LBB11_81:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%r14,%rax), %esi
	cmpq	$32, %rsi
	ja	.LBB11_85
# %bb.82:                               #   in Loop: Header=BB11_81 Depth=1
	btq	%rsi, %rcx
	jae	.LBB11_85
# %bb.83:                               #   in Loop: Header=BB11_81 Depth=1
	movq	1(%r14,%rax), %rsi
	xorq	%rdx, %rsi
	movzbl	9(%r14,%rax), %edi
	xorq	$101, %rdi
	orq	%rsi, %rdi
	jne	.LBB11_85
# %bb.84:                               #   in Loop: Header=BB11_81 Depth=1
	cmpb	$61, 10(%r14,%rax)
	jne	.LBB11_85
# %bb.87:
	leaq	(%r14,%rax), %rcx
	incq	%rcx
.LBB11_88:
	movzbl	10(%rcx), %edi
	testb	%dil, %dil
	je	.LBB11_107
# %bb.89:
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align	4
.LBB11_90:                              # =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	.LBB11_92
# %bb.91:                               #   in Loop: Header=BB11_90 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	.LBB11_97
	jmp	.LBB11_98
	.p2align	4
.LBB11_92:                              #   in Loop: Header=BB11_90 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	.LBB11_94
# %bb.93:                               #   in Loop: Header=BB11_90 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	.LBB11_97
	jmp	.LBB11_98
	.p2align	4
.LBB11_94:                              #   in Loop: Header=BB11_90 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	.LBB11_98
# %bb.95:                               #   in Loop: Header=BB11_90 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	.LBB11_98
.LBB11_97:                              #   in Loop: Header=BB11_90 Depth=1
	shll	$4, %eax
	orl	%esi, %eax
	movzbl	11(%rcx,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	.LBB11_90
	jmp	.LBB11_99
.LBB11_98:
	testl	%edx, %edx
	je	.LBB11_107
.LBB11_99:
	testl	%eax, %eax
	je	.LBB11_108
.LBB11_100:
	movq	%r14, %rdi
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	jmp	free@PLT                        # TAILCALL
.LBB11_13:
	callq	check_write_status.cold.1
.LBB11_38:
	callq	check_write_status.cold.2
.LBB11_63:
	callq	check_write_status.cold.5
.LBB11_86:
	callq	check_write_status.cold.6
.LBB11_103:
	leaq	.L.str.89(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB11_102:
	callq	check_write_status.cold.4
.LBB11_104:
	callq	check_write_status.cold.3
.LBB11_105:
	callq	check_write_status.cold.8
.LBB11_107:
	callq	check_write_status.cold.7
.LBB11_106:
	leaq	.L.str.93(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB11_108:
	leaq	.L.str.95(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end11:
	.size	check_write_status, .Lfunc_end11-check_write_status
                                        # -- End function
	.p2align	4                               # -- Begin function check_dynamic_fat_status
	.type	check_dynamic_fat_status,@function
check_dynamic_fat_status:               # @check_dynamic_fat_status
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	xorl	%ebp, %ebp
	testq	%rdi, %rdi
	je	.LBB12_42
# %bb.1:
	movq	%rdi, %rbx
	callq	read_file
	movq	%rax, 24(%rsp)
	movq	%rdx, 32(%rsp)
	testq	%rax, %rax
	je	.LBB12_42
# %bb.2:
	xorl	%ebp, %ebp
	cmpq	$7, %rdx
	jb	.LBB12_41
# %bb.3:
	movl	$1685348710, %ecx               # imm = 0x64746166
	xorl	(%rax), %ecx
	leaq	-6(%rdx), %rsi
	movzwl	4(%rax), %edi
	xorl	$28281, %edi                    # imm = 0x6E79
	orl	%ecx, %edi
	jne	.LBB12_5
# %bb.4:
	cmpb	$61, 6(%rax)
	je	.LBB12_13
.LBB12_5:
	cmpq	$1, %rsi
	je	.LBB12_41
# %bb.6:
	leaq	-7(%rdx), %rcx
	xorl	%edi, %edi
	movabsq	$4294976512, %r8                # imm = 0x100002400
	movl	$1685348710, %r9d               # imm = 0x64746166
	jmp	.LBB12_7
	.p2align	4
.LBB12_11:                              #   in Loop: Header=BB12_7 Depth=1
	incq	%rdi
	cmpq	%rdi, %rcx
	je	.LBB12_12
.LBB12_7:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%rax,%rdi), %r10d
	cmpq	$32, %r10
	ja	.LBB12_11
# %bb.8:                                #   in Loop: Header=BB12_7 Depth=1
	btq	%r10, %r8
	jae	.LBB12_11
# %bb.9:                                #   in Loop: Header=BB12_7 Depth=1
	movl	1(%rax,%rdi), %r10d
	xorl	%r9d, %r10d
	movzwl	5(%rax,%rdi), %r11d
	xorl	$28281, %r11d                   # imm = 0x6E79
	orl	%r10d, %r11d
	jne	.LBB12_11
# %bb.10:                               #   in Loop: Header=BB12_7 Depth=1
	cmpb	$61, 7(%rax,%rdi)
	jne	.LBB12_11
.LBB12_13:
	movl	$1685348710, %ecx               # imm = 0x64746166
	xorl	(%rax), %ecx
	movzwl	4(%rax), %edi
	xorl	$28281, %edi                    # imm = 0x6E79
	orl	%ecx, %edi
	jne	.LBB12_15
# %bb.14:
	cmpb	$61, 6(%rax)
	movq	%rax, %rcx
	je	.LBB12_24
.LBB12_15:
	cmpq	$1, %rsi
	je	.LBB12_22
# %bb.16:
	addq	$-7, %rdx
	xorl	%ecx, %ecx
	movabsq	$4294976512, %rsi               # imm = 0x100002400
	movl	$1685348710, %edi               # imm = 0x64746166
	jmp	.LBB12_17
	.p2align	4
.LBB12_21:                              #   in Loop: Header=BB12_17 Depth=1
	incq	%rcx
	cmpq	%rcx, %rdx
	je	.LBB12_22
.LBB12_17:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%rax,%rcx), %r8d
	cmpq	$32, %r8
	ja	.LBB12_21
# %bb.18:                               #   in Loop: Header=BB12_17 Depth=1
	btq	%r8, %rsi
	jae	.LBB12_21
# %bb.19:                               #   in Loop: Header=BB12_17 Depth=1
	movl	1(%rax,%rcx), %r8d
	xorl	%edi, %r8d
	movzwl	5(%rax,%rcx), %r9d
	xorl	$28281, %r9d                    # imm = 0x6E79
	orl	%r8d, %r9d
	jne	.LBB12_21
# %bb.20:                               #   in Loop: Header=BB12_17 Depth=1
	cmpb	$61, 7(%rax,%rcx)
	jne	.LBB12_21
# %bb.23:
	addq	%rax, %rcx
	incq	%rcx
.LBB12_24:
	movzbl	7(%rcx), %edi
	testb	%dil, %dil
	je	.LBB12_43
# %bb.25:
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	.p2align	4
.LBB12_26:                              # =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	.LBB12_28
# %bb.27:                               #   in Loop: Header=BB12_26 Depth=1
	addl	$-48, %esi
	jmp	.LBB12_32
	.p2align	4
.LBB12_28:                              #   in Loop: Header=BB12_26 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	.LBB12_30
# %bb.29:                               #   in Loop: Header=BB12_26 Depth=1
	addl	$-87, %esi
	jmp	.LBB12_32
.LBB12_30:                              #   in Loop: Header=BB12_26 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	.LBB12_34
# %bb.31:                               #   in Loop: Header=BB12_26 Depth=1
	addl	$-55, %esi
.LBB12_32:                              #   in Loop: Header=BB12_26 Depth=1
	testl	%esi, %esi
	js	.LBB12_34
# %bb.33:                               #   in Loop: Header=BB12_26 Depth=1
	shll	$4, %r13d
	orl	%esi, %r13d
	movzbl	8(%rcx,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	.LBB12_26
	jmp	.LBB12_35
.LBB12_12:
	xorl	%ebp, %ebp
	jmp	.LBB12_41
.LBB12_34:
	testl	%edx, %edx
	je	.LBB12_43
.LBB12_35:
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	leaq	.L.str.109(%rip), %r14
	leaq	24(%rsp), %r12
	movl	$2, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	status_hex_tuple_part
	movl	%eax, 12(%rsp)                  # 4-byte Spill
	movl	$4, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	status_hex_tuple_part
	movl	%eax, 8(%rsp)                   # 4-byte Spill
	movl	$6, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	status_hex_tuple_part
	movl	%eax, %r15d
	movl	$7, %edx
	movq	%r12, %rdi
	movq	%r14, %rsi
	callq	status_hex_tuple_part
	movl	$1, %ebp
	testl	%r13d, %r13d
	jne	.LBB12_36
# %bb.37:
	movl	%eax, %ecx
	cmpl	$0, 12(%rsp)                    # 4-byte Folded Reload
	movq	16(%rsp), %rax                  # 8-byte Reload
	jne	.LBB12_41
# %bb.38:
	cmpl	$0, 8(%rsp)                     # 4-byte Folded Reload
	jne	.LBB12_41
# %bb.39:
	testl	%r15d, %r15d
	jne	.LBB12_41
# %bb.40:
	testl	%ecx, %ecx
	je	.LBB12_44
.LBB12_41:
	movq	%rax, %rdi
	callq	free@PLT
.LBB12_42:
	movl	%ebp, %eax
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB12_36:
	movq	16(%rsp), %rax                  # 8-byte Reload
	jmp	.LBB12_41
.LBB12_22:
	callq	check_dynamic_fat_status.cold.1
.LBB12_43:
	callq	check_dynamic_fat_status.cold.2
.LBB12_44:
	leaq	.L.str.110(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end12:
	.size	check_dynamic_fat_status, .Lfunc_end12-check_dynamic_fat_status
                                        # -- End function
	.p2align	4                               # -- Begin function root_file_equal
	.type	root_file_equal,@function
root_file_equal:                        # @root_file_equal
# %bb.0:
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	subq	$32, %rsp
	movq	(%rdi), %rax
	xorl	%r9d, %r9d
	jmp	.LBB13_1
	.p2align	4
.LBB13_6:                               #   in Loop: Header=BB13_1 Depth=1
	addq	$32, %r9
	cmpq	$16384, %r9                     # imm = 0x4000
	je	.LBB13_7
.LBB13_1:                               # =>This Inner Loop Header: Depth=1
	movzbl	1311232(%rax,%r9), %ecx
	cmpl	$229, %ecx
	je	.LBB13_6
# %bb.2:                                #   in Loop: Header=BB13_1 Depth=1
	testl	%ecx, %ecx
	je	.LBB13_3
# %bb.4:                                #   in Loop: Header=BB13_1 Depth=1
	movq	1311232(%rax,%r9), %rcx
	xorq	(%rdx), %rcx
	movq	1311235(%rax,%r9), %r8
	xorq	3(%rdx), %r8
	orq	%rcx, %r8
	jne	.LBB13_6
# %bb.5:
	movzbl	1311243(%rax,%r9), %r8d
	movzwl	1311258(%rax,%r9), %r10d
	movl	1311260(%rax,%r9), %ecx
	shlq	$32, %rcx
	orq	%r10, %rcx
	shlq	$32, %r8
	movl	$1, %eax
	movb	$1, %r9b
	jmp	.LBB13_8
.LBB13_7:
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	jmp	.LBB13_8
.LBB13_3:
	xorl	%r9d, %r9d
	movq	%rcx, %r8
	movq	%rcx, %rax
.LBB13_8:
	orq	%r8, %rax
	movq	%rax, 16(%rsp)
	movq	%rcx, 24(%rsp)
	movq	(%rsi), %r10
	xorl	%r11d, %r11d
	jmp	.LBB13_9
	.p2align	4
.LBB13_12:                              #   in Loop: Header=BB13_9 Depth=1
	addq	$32, %r11
	cmpq	$16384, %r11                    # imm = 0x4000
	je	.LBB13_13
.LBB13_9:                               # =>This Inner Loop Header: Depth=1
	movzbl	1311232(%r10,%r11), %eax
	cmpl	$229, %eax
	je	.LBB13_12
# %bb.10:                               #   in Loop: Header=BB13_9 Depth=1
	testl	%eax, %eax
	je	.LBB13_19
# %bb.11:                               #   in Loop: Header=BB13_9 Depth=1
	movq	1311232(%r10,%r11), %rax
	xorq	(%rdx), %rax
	movq	1311235(%r10,%r11), %rbx
	xorq	3(%rdx), %rbx
	orq	%rax, %rbx
	jne	.LBB13_12
# %bb.14:
	movzwl	1311258(%r10,%r11), %eax
	movl	1311260(%r10,%r11), %edx
	shlq	$32, %rdx
	orq	%rdx, %rax
	movzbl	1311243(%r10,%r11), %r10d
	shlq	$32, %r10
	leaq	1(%r10), %r11
	movq	%r11, (%rsp)
	movq	%rax, 8(%rsp)
	cmpq	%r10, %r8
	sete	%al
	andb	%al, %r9b
	xorl	%eax, %eax
	cmpb	$1, %r9b
	jne	.LBB13_19
# %bb.15:
	xorq	%rdx, %rcx
	shrq	$32, %rcx
	jne	.LBB13_19
# %bb.16:
	leaq	.L.str.71(%rip), %rdx
	leaq	16(%rsp), %rax
	movq	%rsi, %r14
	movq	%rax, %rsi
	callq	read_root_file_blob
	movq	%rax, %rbx
	movq	%rdx, %r15
	leaq	.L.str.72(%rip), %rdx
	movq	%rsp, %rsi
	movq	%r14, %rdi
	callq	read_root_file_blob
	movq	%rax, %r14
	xorl	%ecx, %ecx
	cmpq	%rdx, %r15
	jne	.LBB13_18
# %bb.17:
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	bcmp@PLT
	xorl	%ecx, %ecx
	testl	%eax, %eax
	sete	%cl
.LBB13_18:
	movq	%rbx, %rdi
	movl	%ecx, %ebx
	callq	free@PLT
	movq	%r14, %rdi
	callq	free@PLT
	movl	%ebx, %eax
	jmp	.LBB13_19
.LBB13_13:
	xorl	%eax, %eax
.LBB13_19:
	addq	$32, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	retq
.Lfunc_end13:
	.size	root_file_equal, .Lfunc_end13-root_file_equal
                                        # -- End function
	.p2align	4                               # -- Begin function read_root_file_blob
	.type	read_root_file_blob,@function
read_root_file_blob:                    # @read_root_file_blob
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
	movq	%rdx, (%rsp)                    # 8-byte Spill
	movq	%rsi, %r13
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	movl	12(%rsi), %r14d
	testq	%r14, %r14
	movl	$1, %edi
	cmovneq	%r14, %rdi
	movl	$1, %esi
	callq	calloc@PLT
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	testq	%rax, %rax
	je	.LBB14_10
# %bb.1:
	testq	%r14, %r14
	je	.LBB14_9
# %bb.2:
	movl	8(%r13), %ebp
	leal	-64241(%rbp), %eax
	cmpl	$-64239, %eax                   # imm = 0xFFFF0511
	jb	.LBB14_11
# %bb.3:
	movl	$64241, %ebx                    # imm = 0xFAF1
	xorl	%r15d, %r15d
	.p2align	4
.LBB14_4:                               # =>This Inner Loop Header: Depth=1
	leal	-64241(%rbp), %eax
	cmpl	$-64239, %eax                   # imm = 0xFFFF0511
	jb	.LBB14_12
# %bb.5:                                #   in Loop: Header=BB14_4 Depth=1
	decl	%ebx
	je	.LBB14_12
# %bb.6:                                #   in Loop: Header=BB14_4 Depth=1
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	(%rax), %r12
	movq	%r14, %r13
	subq	%r15, %r13
	cmpq	$1024, %r13                     # imm = 0x400
	movl	$1024, %eax                     # imm = 0x400
	cmovaeq	%rax, %r13
	movq	8(%rsp), %rax                   # 8-byte Reload
	leaq	(%rax,%r15), %rdi
	movl	%ebp, %eax
	shll	$10, %eax
	leaq	(%r12,%rax), %rsi
	addq	$1325568, %rsi                  # imm = 0x143A00
	movq	%r13, %rdx
	callq	memcpy@PLT
	addq	%r13, %r15
	cmpq	%r14, %r15
	jae	.LBB14_9
# %bb.7:                                #   in Loop: Header=BB14_4 Depth=1
	movl	%ebp, %eax
	movzwl	1049088(%r12,%rax,2), %ebp
	cmpl	$65528, %ebp                    # imm = 0xFFF8
	jb	.LBB14_4
# %bb.8:
	leaq	.L.str.75(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.LBB14_9:
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%r14, %rdx
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB14_12:
	leaq	.L.str.74(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.LBB14_10:
	callq	read_root_file_blob.cold.1
.LBB14_11:
	leaq	.L.str.73(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.Lfunc_end14:
	.size	read_root_file_blob, .Lfunc_end14-read_root_file_blob
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part
	.type	status_hex_tuple_part,@function
status_hex_tuple_part:                  # @status_hex_tuple_part
# %bb.0:
	pushq	%rbx
	movq	%rdx, %rbx
	callq	status_find_field
	testq	%rax, %rax
	je	.LBB15_53
# %bb.1:
	testq	%rbx, %rbx
	je	.LBB15_13
	.p2align	4
.LBB15_2:                               # =>This Inner Loop Header: Depth=1
	incq	%rax
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	.LBB15_5
# %bb.3:                                #   in Loop: Header=BB15_2 Depth=1
	cmpl	$58, %ecx
	je	.LBB15_5
# %bb.4:                                #   in Loop: Header=BB15_2 Depth=1
	testl	%ecx, %ecx
	jne	.LBB15_2
.LBB15_10:
	callq	status_hex_tuple_part.cold.1
.LBB15_5:
	cmpq	$1, %rbx
	je	.LBB15_13
# %bb.6:
	addq	$2, %rax
	.p2align	4
.LBB15_7:                               # =>This Inner Loop Header: Depth=1
	movzbl	-2(%rax), %ecx
	cmpl	$47, %ecx
	je	.LBB15_11
# %bb.8:                                #   in Loop: Header=BB15_7 Depth=1
	cmpl	$58, %ecx
	je	.LBB15_11
# %bb.9:                                #   in Loop: Header=BB15_7 Depth=1
	testl	%ecx, %ecx
	je	.LBB15_10
# %bb.17:                               #   in Loop: Header=BB15_7 Depth=1
	incq	%rax
	jmp	.LBB15_7
.LBB15_11:
	cmpq	$2, %rbx
	jne	.LBB15_18
.LBB15_12:
	decq	%rax
	jmp	.LBB15_13
	.p2align	4
.LBB15_18:                              # =>This Inner Loop Header: Depth=1
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	.LBB15_22
# %bb.19:                               #   in Loop: Header=BB15_18 Depth=1
	cmpl	$58, %ecx
	je	.LBB15_22
# %bb.20:                               #   in Loop: Header=BB15_18 Depth=1
	testl	%ecx, %ecx
	je	.LBB15_10
# %bb.21:                               #   in Loop: Header=BB15_18 Depth=1
	incq	%rax
	jmp	.LBB15_18
.LBB15_22:
	cmpq	$3, %rbx
	je	.LBB15_13
# %bb.23:
	addq	$4, %rax
	.p2align	4
.LBB15_24:                              # =>This Inner Loop Header: Depth=1
	movzbl	-4(%rax), %ecx
	cmpl	$47, %ecx
	je	.LBB15_28
# %bb.25:                               #   in Loop: Header=BB15_24 Depth=1
	cmpl	$58, %ecx
	je	.LBB15_28
# %bb.26:                               #   in Loop: Header=BB15_24 Depth=1
	testl	%ecx, %ecx
	je	.LBB15_10
# %bb.27:                               #   in Loop: Header=BB15_24 Depth=1
	incq	%rax
	jmp	.LBB15_24
.LBB15_28:
	cmpq	$4, %rbx
	jne	.LBB15_30
# %bb.29:
	addq	$-3, %rax
	jmp	.LBB15_13
	.p2align	4
.LBB15_30:                              # =>This Inner Loop Header: Depth=1
	movzbl	-3(%rax), %ecx
	cmpl	$47, %ecx
	je	.LBB15_34
# %bb.31:                               #   in Loop: Header=BB15_30 Depth=1
	cmpl	$58, %ecx
	je	.LBB15_34
# %bb.32:                               #   in Loop: Header=BB15_30 Depth=1
	testl	%ecx, %ecx
	je	.LBB15_10
# %bb.33:                               #   in Loop: Header=BB15_30 Depth=1
	incq	%rax
	jmp	.LBB15_30
.LBB15_34:
	cmpq	$5, %rbx
	jne	.LBB15_36
# %bb.35:
	addq	$-2, %rax
.LBB15_13:
	movzbl	(%rax), %edi
	testb	%dil, %dil
	je	.LBB15_54
# %bb.14:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
.LBB15_15:                              # =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	.LBB15_45
# %bb.16:                               #   in Loop: Header=BB15_15 Depth=1
	addl	$-48, %esi
	testl	%esi, %esi
	jns	.LBB15_50
	jmp	.LBB15_51
	.p2align	4
.LBB15_45:                              #   in Loop: Header=BB15_15 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	.LBB15_47
# %bb.46:                               #   in Loop: Header=BB15_15 Depth=1
	addl	$-87, %esi
	testl	%esi, %esi
	jns	.LBB15_50
	jmp	.LBB15_51
	.p2align	4
.LBB15_47:                              #   in Loop: Header=BB15_15 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	.LBB15_51
# %bb.48:                               #   in Loop: Header=BB15_15 Depth=1
	addl	$-55, %esi
	testl	%esi, %esi
	js	.LBB15_51
.LBB15_50:                              #   in Loop: Header=BB15_15 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	1(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	.LBB15_15
	jmp	.LBB15_52
.LBB15_51:
	testl	%edx, %edx
	je	.LBB15_54
.LBB15_52:
	movl	%ecx, %eax
	popq	%rbx
	retq
	.p2align	4
.LBB15_36:                              # =>This Inner Loop Header: Depth=1
	movzbl	-2(%rax), %ecx
	cmpl	$47, %ecx
	je	.LBB15_40
# %bb.37:                               #   in Loop: Header=BB15_36 Depth=1
	cmpl	$58, %ecx
	je	.LBB15_40
# %bb.38:                               #   in Loop: Header=BB15_36 Depth=1
	testl	%ecx, %ecx
	je	.LBB15_10
# %bb.39:                               #   in Loop: Header=BB15_36 Depth=1
	incq	%rax
	jmp	.LBB15_36
.LBB15_40:
	cmpq	$6, %rbx
	je	.LBB15_12
.LBB15_41:                              # =>This Inner Loop Header: Depth=1
	movzbl	-1(%rax), %ecx
	cmpl	$47, %ecx
	je	.LBB15_13
# %bb.42:                               #   in Loop: Header=BB15_41 Depth=1
	cmpl	$58, %ecx
	je	.LBB15_13
# %bb.43:                               #   in Loop: Header=BB15_41 Depth=1
	testl	%ecx, %ecx
	je	.LBB15_10
# %bb.44:                               #   in Loop: Header=BB15_41 Depth=1
	incq	%rax
	jmp	.LBB15_41
.LBB15_54:
	callq	status_hex_tuple_part.cold.2
.LBB15_53:
	callq	status_hex_tuple_part.cold.3
.Lfunc_end15:
	.size	status_hex_tuple_part, .Lfunc_end15-status_hex_tuple_part
                                        # -- End function
	.p2align	4                               # -- Begin function status_find_field
	.type	status_find_field,@function
status_find_field:                      # @status_find_field
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	(%rdi), %rbx
	testq	%rbx, %rbx
	je	.LBB16_6
# %bb.1:
	movq	%rsi, %r14
	movq	%rdi, %r12
	movq	%rsi, %rdi
	callq	strlen@PLT
	movq	8(%r12), %r13
	movq	%r13, %r12
	subq	%rax, %r12
	jbe	.LBB16_6
# %bb.2:
	movq	%rax, %r15
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%rax, %rdx
	callq	bcmp@PLT
	testl	%eax, %eax
	jne	.LBB16_4
# %bb.3:
	cmpb	$61, (%rbx,%r15)
	je	.LBB16_14
.LBB16_4:
	cmpq	$1, %r12
	jne	.LBB16_8
.LBB16_6:
	xorl	%r12d, %r12d
.LBB16_15:
	movq	%r12, %rax
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB16_8:
	incq	%rbx
	decq	%r13
	xorl	%r12d, %r12d
	movabsq	$4294976512, %rbp               # imm = 0x100002400
	jmp	.LBB16_10
	.p2align	4
.LBB16_9:                               #   in Loop: Header=BB16_10 Depth=1
	incq	%rbx
	decq	%r13
	cmpq	%r13, %r15
	je	.LBB16_15
.LBB16_10:                              # =>This Inner Loop Header: Depth=1
	movzbl	-1(%rbx), %eax
	cmpq	$32, %rax
	ja	.LBB16_9
# %bb.11:                               #   in Loop: Header=BB16_10 Depth=1
	btq	%rax, %rbp
	jae	.LBB16_9
# %bb.12:                               #   in Loop: Header=BB16_10 Depth=1
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	bcmp@PLT
	testl	%eax, %eax
	jne	.LBB16_9
# %bb.13:                               #   in Loop: Header=BB16_10 Depth=1
	cmpb	$61, (%rbx,%r15)
	jne	.LBB16_9
.LBB16_14:
	leaq	(%rbx,%r15), %r12
	incq	%r12
	jmp	.LBB16_15
.Lfunc_end16:
	.size	status_find_field, .Lfunc_end16-status_find_field
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83
	.type	parse_path83,@function
parse_path83:                           # @parse_path83
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$88, %rsp
	movq	%rdx, 8(%rsp)                   # 8-byte Spill
	testq	%rdi, %rdi
	je	.LBB17_25
# %bb.1:
	movq	%rdi, %r12
	movzbl	(%rdi), %edx
	testb	%dl, %dl
	je	.LBB17_25
# %bb.2:
	movq	%rcx, %r15
	movq	%rsi, %r14
	incq	%r12
	xorl	%eax, %eax
	movl	$11822, %ebp                    # imm = 0x2E2E
	leaq	16(%rsp), %r13
	xorl	%ecx, %ecx
	jmp	.LBB17_5
	.p2align	4
.LBB17_3:                               #   in Loop: Header=BB17_5 Depth=1
	xorl	%ecx, %ecx
.LBB17_4:                               #   in Loop: Header=BB17_5 Depth=1
	movzbl	(%r12), %edx
	incq	%r12
	testb	%dl, %dl
	je	.LBB17_15
.LBB17_5:                               # =>This Inner Loop Header: Depth=1
	cmpb	$92, %dl
	je	.LBB17_7
# %bb.6:                                #   in Loop: Header=BB17_5 Depth=1
	movzbl	%dl, %esi
	cmpl	$47, %esi
	jne	.LBB17_12
.LBB17_7:                               #   in Loop: Header=BB17_5 Depth=1
	testq	%rcx, %rcx
	je	.LBB17_3
# %bb.8:                                #   in Loop: Header=BB17_5 Depth=1
	movb	$0, 16(%rsp,%rcx)
	cmpq	%r15, %rax
	je	.LBB17_22
# %bb.9:                                #   in Loop: Header=BB17_5 Depth=1
	movl	16(%rsp), %ecx
	xorl	%ebp, %ecx
	movzbl	18(%rsp), %edx
	orw	%cx, %dx
	je	.LBB17_23
# %bb.10:                               #   in Loop: Header=BB17_5 Depth=1
	cmpw	$46, 16(%rsp)
	je	.LBB17_3
# %bb.14:                               #   in Loop: Header=BB17_5 Depth=1
	leaq	1(%rax), %rbx
	leaq	(%rax,%rax,4), %rcx
	leaq	(%rax,%rcx,2), %rsi
	addq	%r14, %rsi
	movq	%r13, %rdi
	callq	fat83_from_display_component
	xorl	%ecx, %ecx
	movq	%rbx, %rax
	jmp	.LBB17_4
	.p2align	4
.LBB17_12:                              #   in Loop: Header=BB17_5 Depth=1
	leaq	1(%rcx), %rsi
	cmpq	$64, %rsi
	jae	.LBB17_24
# %bb.13:                               #   in Loop: Header=BB17_5 Depth=1
	movb	%dl, 16(%rsp,%rcx)
	movq	%rsi, %rcx
	jmp	.LBB17_4
.LBB17_15:
	testq	%rcx, %rcx
	je	.LBB17_20
# %bb.16:
	movb	$0, 16(%rsp,%rcx)
	cmpq	%r15, %rax
	je	.LBB17_27
# %bb.17:
	movl	$11822, %ecx                    # imm = 0x2E2E
	xorl	16(%rsp), %ecx
	movzbl	18(%rsp), %edx
	orw	%cx, %dx
	je	.LBB17_28
# %bb.18:
	cmpw	$46, 16(%rsp)
	je	.LBB17_20
# %bb.19:
	leaq	1(%rax), %rbx
	leaq	(%rax,%rax,4), %rcx
	leaq	(%rax,%rcx,2), %rax
	addq	%rax, %r14
	leaq	16(%rsp), %rdi
	movq	%r14, %rsi
	callq	fat83_from_display_component
	movq	%rbx, %rax
.LBB17_20:
	testq	%rax, %rax
	je	.LBB17_26
# %bb.21:
	movq	8(%rsp), %rcx                   # 8-byte Reload
	movq	%rax, (%rcx)
	addq	$88, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB17_22:
	callq	parse_path83.cold.2
.LBB17_23:
	callq	parse_path83.cold.1
.LBB17_24:
	callq	parse_path83.cold.6
.LBB17_25:
	callq	parse_path83.cold.7
.LBB17_26:
	callq	parse_path83.cold.5
.LBB17_27:
	callq	parse_path83.cold.4
.LBB17_28:
	callq	parse_path83.cold.3
.Lfunc_end17:
	.size	parse_path83, .Lfunc_end17-parse_path83
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component
	.type	fat83_from_display_component,@function
fat83_from_display_component:           # @fat83_from_display_component
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	movq	%rsi, %rbx
	movq	%rdi, %r12
	movabsq	$2314885530818453536, %rax      # imm = 0x2020202020202020
	movq	%rax, (%rsi)
	movl	$538976288, 7(%rsi)             # imm = 0x20202020
	movl	$46, %esi
	callq	strchr@PLT
	movq	%rax, %r14
	testq	%rax, %rax
	je	.LBB18_1
# %bb.3:
	movq	%r14, %r13
	subq	%r12, %r13
	leaq	1(%r14), %rbp
	movq	%rbp, %rdi
	callq	strlen@PLT
	movq	%rax, %r15
	leaq	-9(%r13), %rax
	cmpq	$-8, %rax
	jb	.LBB18_18
# %bb.4:
	cmpq	$4, %r15
	jae	.LBB18_18
# %bb.5:
	movq	%rbp, %rdi
	movl	$46, %esi
	callq	strchr@PLT
	testq	%rax, %rax
	je	.LBB18_6
# %bb.19:
	callq	fat83_from_display_component.cold.1
.LBB18_1:
	movq	%r12, %rdi
	callq	strlen@PLT
	movq	%rax, %r13
	addq	$-9, %rax
	cmpq	$-8, %rax
	jb	.LBB18_18
# %bb.2:
	xorl	%r15d, %r15d
.LBB18_6:
	xorl	%eax, %eax
	jmp	.LBB18_7
	.p2align	4
.LBB18_10:                              #   in Loop: Header=BB18_7 Depth=1
	movb	%cl, (%rbx,%rax)
	incq	%rax
	cmpq	%rax, %r13
	je	.LBB18_11
.LBB18_7:                               # =>This Inner Loop Header: Depth=1
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
	jne	.LBB18_10
# %bb.8:                                #   in Loop: Header=BB18_7 Depth=1
	cmpb	$45, %cl
	je	.LBB18_10
# %bb.9:                                #   in Loop: Header=BB18_7 Depth=1
	movzbl	%cl, %edx
	cmpl	$95, %edx
	je	.LBB18_10
# %bb.21:
	callq	fat83_from_display_component.cold.2
.LBB18_11:
	testq	%r15, %r15
	je	.LBB18_17
# %bb.12:
	xorl	%eax, %eax
	jmp	.LBB18_13
	.p2align	4
.LBB18_16:                              #   in Loop: Header=BB18_13 Depth=1
	movb	%cl, 8(%rbx,%rax)
	incq	%rax
	cmpq	%rax, %r15
	je	.LBB18_17
.LBB18_13:                              # =>This Inner Loop Header: Depth=1
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
	jne	.LBB18_16
# %bb.14:                               #   in Loop: Header=BB18_13 Depth=1
	cmpb	$45, %cl
	je	.LBB18_16
# %bb.15:                               #   in Loop: Header=BB18_13 Depth=1
	movzbl	%cl, %edx
	cmpl	$95, %edx
	je	.LBB18_16
# %bb.20:
	callq	fat83_from_display_component.cold.3
.LBB18_17:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB18_18:
	callq	fat83_from_display_component.cold.4
.Lfunc_end18:
	.size	fat83_from_display_component, .Lfunc_end18-fat83_from_display_component
                                        # -- End function
	.p2align	4                               # -- Begin function format_fat_name
	.type	format_fat_name,@function
format_fat_name:                        # @format_fat_name
# %bb.0:
	movzbl	(%rdi), %eax
	cmpb	$32, %al
	jne	.LBB19_5
# %bb.1:
	xorl	%eax, %eax
	jmp	.LBB19_2
.LBB19_5:
	movb	%al, (%rsi)
	movzbl	1(%rdi), %ecx
	movl	$1, %eax
	cmpb	$32, %cl
	je	.LBB19_2
# %bb.6:
	movb	%cl, 1(%rsi)
	movzbl	2(%rdi), %ecx
	movl	$2, %eax
	cmpb	$32, %cl
	je	.LBB19_2
# %bb.7:
	movb	%cl, 2(%rsi)
	movzbl	3(%rdi), %ecx
	movl	$3, %eax
	cmpb	$32, %cl
	je	.LBB19_2
# %bb.8:
	movb	%cl, 3(%rsi)
	movzbl	4(%rdi), %ecx
	movl	$4, %eax
	cmpb	$32, %cl
	je	.LBB19_2
# %bb.9:
	movb	%cl, 4(%rsi)
	movzbl	5(%rdi), %ecx
	movl	$5, %eax
	cmpb	$32, %cl
	je	.LBB19_2
# %bb.10:
	movb	%cl, 5(%rsi)
	movzbl	6(%rdi), %ecx
	movl	$6, %eax
	cmpb	$32, %cl
	je	.LBB19_2
# %bb.11:
	movb	%cl, 6(%rsi)
	movzbl	7(%rdi), %ecx
	movl	$7, %eax
	cmpb	$32, %cl
	je	.LBB19_2
# %bb.12:
	movb	%cl, 7(%rsi)
	movl	$8, %eax
.LBB19_2:
	cmpb	$32, 8(%rdi)
	jne	.LBB19_3
# %bb.18:
	movb	$0, (%rsi,%rax)
	retq
.LBB19_3:
	movb	$46, (%rsi,%rax)
	movzbl	8(%rdi), %ecx
	cmpb	$32, %cl
	jne	.LBB19_13
# %bb.4:
	incq	%rax
	movb	$0, (%rsi,%rax)
	retq
.LBB19_13:
	movb	%cl, 1(%rsi,%rax)
	movzbl	9(%rdi), %ecx
	cmpb	$32, %cl
	jne	.LBB19_15
# %bb.14:
	addq	$2, %rax
	movb	$0, (%rsi,%rax)
	retq
.LBB19_15:
	movb	%cl, 2(%rsi,%rax)
	movzbl	10(%rdi), %ecx
	cmpb	$32, %cl
	jne	.LBB19_17
# %bb.16:
	addq	$3, %rax
	movb	$0, (%rsi,%rax)
	retq
.LBB19_17:
	movb	%cl, 3(%rsi,%rax)
	addq	$4, %rax
	movb	$0, (%rsi,%rax)
	retq
.Lfunc_end19:
	.size	format_fat_name, .Lfunc_end19-format_fat_name
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_directory
	.type	inspect_directory,@function
inspect_directory:                      # @inspect_directory
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$200, %rsp
                                        # kill: def $edx killed $edx def $rdx
	movq	%rdi, 8(%rsp)                   # 8-byte Spill
	movl	%ecx, 4(%rsp)                   # 4-byte Spill
	testl	%ecx, %ecx
	sete	%al
	leal	-64241(%rdx), %ecx
	cmpl	$-64239, %ecx                   # imm = 0xFFFF0511
	setb	%cl
	orb	%al, %cl
	je	.LBB20_1
.LBB20_9:
	addq	$200, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB20_1:
	movq	%rsi, %r14
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	(%rax), %rax
	shll	$10, %edx
	leaq	(%rax,%rdx), %r15
	addq	$1325568, %r15                  # imm = 0x143A00
	decl	4(%rsp)                         # 4-byte Folded Spill
	leaq	19(%rsp), %r12
	leaq	32(%rsp), %rbp
	xorl	%ebx, %ebx
	jmp	.LBB20_2
	.p2align	4
.LBB20_8:                               #   in Loop: Header=BB20_2 Depth=1
	addq	$32, %rbx
	cmpq	$1024, %rbx                     # imm = 0x400
	je	.LBB20_9
.LBB20_2:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%r15,%rbx), %eax
	cmpl	$46, %eax
	je	.LBB20_8
# %bb.3:                                #   in Loop: Header=BB20_2 Depth=1
	cmpl	$229, %eax
	je	.LBB20_8
# %bb.4:                                #   in Loop: Header=BB20_2 Depth=1
	testl	%eax, %eax
	je	.LBB20_9
# %bb.5:                                #   in Loop: Header=BB20_2 Depth=1
	leaq	(%r15,%rbx), %rdi
	movq	%r12, %rsi
	callq	format_fat_name
	movl	$160, %esi
	movq	%rbp, %rdi
	leaq	.L.str.144(%rip), %rdx
	movq	%r14, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$160, %eax
	jae	.LBB20_10
# %bb.6:                                #   in Loop: Header=BB20_2 Depth=1
	movzwl	26(%r15,%rbx), %r13d
	movl	28(%r15,%rbx), %r8d
	movzbl	11(%r15,%rbx), %edx
	leaq	.L.str.146(%rip), %rdi
	movq	%rbp, %rsi
	movl	%r13d, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	testb	$16, 11(%r15,%rbx)
	je	.LBB20_8
# %bb.7:                                #   in Loop: Header=BB20_2 Depth=1
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movq	%rbp, %rsi
	movl	%r13d, %edx
	movl	4(%rsp), %ecx                   # 4-byte Reload
	callq	inspect_directory
	jmp	.LBB20_8
.LBB20_10:
	callq	inspect_directory.cold.1
.Lfunc_end20:
	.size	inspect_directory, .Lfunc_end20-inspect_directory
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function inspect_pi4_manifest
.LCPI21_0:
	.byte	97                              # 0x61
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	45                              # 0x2d
	.byte	109                             # 0x6d
	.byte	97                              # 0x61
	.byte	110                             # 0x6e
	.byte	105                             # 0x69
	.byte	102                             # 0x66
	.byte	101                             # 0x65
	.byte	115                             # 0x73
	.byte	116                             # 0x74
	.byte	45                              # 0x2d
	.byte	118                             # 0x76
	.byte	49                              # 0x31
	.byte	0                               # 0x0
.LCPI21_1:
	.byte	118                             # 0x76
	.byte	105                             # 0x69
	.byte	98                              # 0x62
	.byte	101                             # 0x65
	.byte	45                              # 0x2d
	.byte	111                             # 0x6f
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	105                             # 0x69
	.byte	52                              # 0x34
	.byte	45                              # 0x2d
	.byte	105                             # 0x69
	.byte	109                             # 0x6d
	.byte	97                              # 0x61
	.byte	103                             # 0x67
.LCPI21_2:
	.byte	111                             # 0x6f
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	105                             # 0x69
	.byte	52                              # 0x34
	.byte	45                              # 0x2d
	.byte	102                             # 0x66
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	49                              # 0x31
	.byte	54                              # 0x36
	.byte	45                              # 0x2d
	.byte	118                             # 0x76
	.byte	49                              # 0x31
	.byte	0                               # 0x0
.LCPI21_3:
	.byte	118                             # 0x76
	.byte	105                             # 0x69
	.byte	98                              # 0x62
	.byte	101                             # 0x65
	.byte	45                              # 0x2d
	.byte	111                             # 0x6f
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	105                             # 0x69
	.byte	52                              # 0x34
	.byte	45                              # 0x2d
	.byte	102                             # 0x66
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	49                              # 0x31
.LCPI21_4:
	.byte	84                              # 0x54
	.byte	88                              # 0x58
	.byte	84                              # 0x54
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
.LCPI21_5:
	.byte	47                              # 0x2f
	.byte	80                              # 0x50
	.byte	82                              # 0x52
	.byte	79                              # 0x4f
	.byte	79                              # 0x4f
	.byte	70                              # 0x46
	.byte	47                              # 0x2f
	.byte	77                              # 0x4d
	.byte	65                              # 0x41
	.byte	78                              # 0x4e
	.byte	73                              # 0x49
	.byte	70                              # 0x46
	.byte	69                              # 0x45
	.byte	83                              # 0x53
	.byte	84                              # 0x54
	.byte	46                              # 0x2e
.LCPI21_6:
	.byte	45                              # 0x2d
	.byte	97                              # 0x61
	.byte	112                             # 0x70
	.byte	112                             # 0x70
	.byte	45                              # 0x2d
	.byte	105                             # 0x69
	.byte	110                             # 0x6e
	.byte	115                             # 0x73
	.byte	116                             # 0x74
	.byte	97                              # 0x61
	.byte	108                             # 0x6c
	.byte	108                             # 0x6c
	.byte	45                              # 0x2d
	.byte	118                             # 0x76
	.byte	49                              # 0x31
	.byte	0                               # 0x0
.LCPI21_7:
	.byte	118                             # 0x76
	.byte	105                             # 0x69
	.byte	98                              # 0x62
	.byte	101                             # 0x65
	.byte	45                              # 0x2d
	.byte	111                             # 0x6f
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	105                             # 0x69
	.byte	52                              # 0x34
	.byte	45                              # 0x2d
	.byte	97                              # 0x61
	.byte	112                             # 0x70
	.byte	112                             # 0x70
	.byte	45                              # 0x2d
.LCPI21_8:
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	108                             # 0x6c
	.byte	117                             # 0x75
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	97                              # 0x61
	.byte	112                             # 0x70
	.byte	112                             # 0x70
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	116                             # 0x74
	.byte	114                             # 0x72
	.byte	101                             # 0x65
	.byte	101                             # 0x65
	.byte	0                               # 0x0
.LCPI21_9:
	.byte	115                             # 0x73
	.byte	121                             # 0x79
	.byte	115                             # 0x73
	.byte	116                             # 0x74
	.byte	101                             # 0x65
	.byte	109                             # 0x6d
	.byte	45                              # 0x2d
	.byte	105                             # 0x69
	.byte	110                             # 0x6e
	.byte	105                             # 0x69
	.byte	116                             # 0x74
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	108                             # 0x6c
	.byte	117                             # 0x75
	.byte	115                             # 0x73
.LCPI21_10:
	.byte	99                              # 0x63
	.byte	45                              # 0x2d
	.byte	118                             # 0x76
	.byte	102                             # 0x66
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	104                             # 0x68
	.byte	45                              # 0x2d
	.byte	101                             # 0x65
	.byte	120                             # 0x78
	.byte	101                             # 0x65
	.byte	99                              # 0x63
	.byte	0                               # 0x0
.LCPI21_11:
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	110                             # 0x6e
	.byte	101                             # 0x65
	.byte	114                             # 0x72
	.byte	105                             # 0x69
	.byte	99                              # 0x63
	.byte	45                              # 0x2d
	.byte	118                             # 0x76
	.byte	102                             # 0x66
	.byte	115                             # 0x73
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	104                             # 0x68
.LCPI21_12:
	.byte	101                             # 0x65
	.byte	108                             # 0x6c
	.byte	48                              # 0x30
	.byte	45                              # 0x2d
	.byte	101                             # 0x65
	.byte	108                             # 0x6c
	.byte	102                             # 0x66
	.byte	45                              # 0x2d
	.byte	98                              # 0x62
	.byte	121                             # 0x79
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	104                             # 0x68
	.byte	0                               # 0x0
.LCPI21_13:
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	110                             # 0x6e
	.byte	101                             # 0x65
	.byte	114                             # 0x72
	.byte	105                             # 0x69
	.byte	99                              # 0x63
	.byte	45                              # 0x2d
	.byte	97                              # 0x61
	.byte	97                              # 0x61
	.byte	114                             # 0x72
	.byte	99                              # 0x63
	.byte	104                             # 0x68
	.byte	54                              # 0x36
	.byte	52                              # 0x34
	.byte	45                              # 0x2d
.LCPI21_14:
	.byte	69                              # 0x45
	.byte	77                              # 0x4d
	.byte	47                              # 0x2f
	.byte	65                              # 0x41
	.byte	66                              # 0x42
	.byte	73                              # 0x49
	.byte	80                              # 0x50
	.byte	82                              # 0x52
	.byte	79                              # 0x4f
	.byte	66                              # 0x42
	.byte	69                              # 0x45
	.byte	46                              # 0x2e
	.byte	69                              # 0x45
	.byte	76                              # 0x4c
	.byte	70                              # 0x46
	.byte	0                               # 0x0
.LCPI21_15:
	.byte	47                              # 0x2f
	.byte	83                              # 0x53
	.byte	89                              # 0x59
	.byte	83                              # 0x53
	.byte	84                              # 0x54
	.byte	69                              # 0x45
	.byte	77                              # 0x4d
	.byte	47                              # 0x2f
	.byte	65                              # 0x41
	.byte	66                              # 0x42
	.byte	73                              # 0x49
	.byte	80                              # 0x50
	.byte	82                              # 0x52
	.byte	79                              # 0x4f
	.byte	66                              # 0x42
	.byte	69                              # 0x45
.LCPI21_16:
	.byte	47                              # 0x2f
	.byte	65                              # 0x41
	.byte	80                              # 0x50
	.byte	80                              # 0x50
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	73                              # 0x49
	.byte	78                              # 0x4e
	.byte	68                              # 0x44
	.byte	69                              # 0x45
	.byte	88                              # 0x58
	.byte	46                              # 0x2e
	.byte	84                              # 0x54
	.byte	88                              # 0x58
	.byte	84                              # 0x54
	.byte	0                               # 0x0
.LCPI21_17:
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	110                             # 0x6e
	.byte	101                             # 0x65
	.byte	114                             # 0x72
	.byte	105                             # 0x69
	.byte	99                              # 0x63
	.byte	45                              # 0x2d
	.byte	112                             # 0x70
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	104                             # 0x68
	.byte	45                              # 0x2d
	.byte	101                             # 0x65
	.byte	120                             # 0x78
	.byte	101                             # 0x65
.LCPI21_18:
	.long	99                              # 0x63
	.long	0                               # 0x0
	.long	0                               # 0x0
	.long	0                               # 0x0
.LCPI21_19:
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	110                             # 0x6e
	.byte	101                             # 0x65
	.byte	114                             # 0x72
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	101                             # 0x65
	.byte	100                             # 0x64
	.byte	45                              # 0x2d
	.byte	102                             # 0x66
	.byte	105                             # 0x69
	.byte	120                             # 0x78
	.byte	116                             # 0x74
	.byte	117                             # 0x75
	.byte	114                             # 0x72
.LCPI21_20:
	.long	101                             # 0x65
	.long	0                               # 0x0
	.long	0                               # 0x0
	.long	0                               # 0x0
.LCPI21_21:
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	101                             # 0x65
	.byte	100                             # 0x64
	.byte	45                              # 0x2d
	.byte	98                              # 0x62
	.byte	121                             # 0x79
	.byte	45                              # 0x2d
	.byte	98                              # 0x62
	.byte	117                             # 0x75
	.byte	105                             # 0x69
	.byte	108                             # 0x6c
	.byte	100                             # 0x64
	.byte	101                             # 0x65
	.byte	114                             # 0x72
	.byte	0                               # 0x0
.LCPI21_22:
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	110                             # 0x6e
	.byte	101                             # 0x65
	.byte	114                             # 0x72
	.byte	97                              # 0x61
	.byte	116                             # 0x74
	.byte	101                             # 0x65
	.byte	100                             # 0x64
	.byte	45                              # 0x2d
	.byte	98                              # 0x62
	.byte	121                             # 0x79
	.byte	45                              # 0x2d
	.byte	98                              # 0x62
	.byte	117                             # 0x75
	.byte	105                             # 0x69
.LCPI21_23:
	.byte	107                             # 0x6b
	.byte	97                              # 0x61
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	100                             # 0x64
	.byte	45                              # 0x2d
	.byte	102                             # 0x66
	.byte	105                             # 0x69
	.byte	108                             # 0x6c
	.byte	101                             # 0x65
	.byte	45                              # 0x2d
	.byte	111                             # 0x6f
	.byte	110                             # 0x6e
	.byte	108                             # 0x6c
	.byte	121                             # 0x79
	.byte	0                               # 0x0
.LCPI21_24:
	.byte	112                             # 0x70
	.byte	97                              # 0x61
	.byte	99                              # 0x63
	.byte	107                             # 0x6b
	.byte	97                              # 0x61
	.byte	103                             # 0x67
	.byte	101                             # 0x65
	.byte	100                             # 0x64
	.byte	45                              # 0x2d
	.byte	102                             # 0x66
	.byte	105                             # 0x69
	.byte	108                             # 0x6c
	.byte	101                             # 0x65
	.byte	45                              # 0x2d
	.byte	111                             # 0x6f
	.byte	110                             # 0x6e
.LCPI21_25:
	.byte	83                              # 0x53
	.byte	69                              # 0x45
	.byte	84                              # 0x54
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	82                              # 0x52
	.byte	69                              # 0x45
	.byte	65                              # 0x41
	.byte	68                              # 0x44
	.byte	77                              # 0x4d
	.byte	69                              # 0x45
	.byte	46                              # 0x2e
	.byte	84                              # 0x54
	.byte	88                              # 0x58
	.byte	84                              # 0x54
	.byte	0                               # 0x0
.LCPI21_26:
	.byte	47                              # 0x2f
	.byte	65                              # 0x41
	.byte	83                              # 0x53
	.byte	83                              # 0x53
	.byte	69                              # 0x45
	.byte	84                              # 0x54
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	82                              # 0x52
	.byte	69                              # 0x45
	.byte	65                              # 0x41
	.byte	68                              # 0x44
	.byte	77                              # 0x4d
	.byte	69                              # 0x45
	.byte	46                              # 0x2e
	.byte	84                              # 0x54
.LCPI21_27:
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	77                              # 0x4d
	.byte	65                              # 0x41
	.byte	80                              # 0x50
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	69                              # 0x45
	.byte	49                              # 0x31
	.byte	77                              # 0x4d
	.byte	49                              # 0x31
	.byte	46                              # 0x2e
	.byte	77                              # 0x4d
	.byte	65                              # 0x41
	.byte	80                              # 0x50
	.byte	0                               # 0x0
.LCPI21_28:
	.byte	47                              # 0x2f
	.byte	65                              # 0x41
	.byte	83                              # 0x53
	.byte	83                              # 0x53
	.byte	69                              # 0x45
	.byte	84                              # 0x54
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	77                              # 0x4d
	.byte	65                              # 0x41
	.byte	80                              # 0x50
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	69                              # 0x45
	.byte	49                              # 0x31
	.byte	77                              # 0x4d
.LCPI21_29:
	.byte	88                              # 0x58
	.byte	84                              # 0x54
	.byte	85                              # 0x55
	.byte	82                              # 0x52
	.byte	69                              # 0x45
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	80                              # 0x50
	.byte	65                              # 0x41
	.byte	76                              # 0x4c
	.byte	48                              # 0x30
	.byte	46                              # 0x2e
	.byte	66                              # 0x42
	.byte	73                              # 0x49
	.byte	78                              # 0x4e
	.byte	0                               # 0x0
.LCPI21_30:
	.byte	47                              # 0x2f
	.byte	65                              # 0x41
	.byte	83                              # 0x53
	.byte	83                              # 0x53
	.byte	69                              # 0x45
	.byte	84                              # 0x54
	.byte	83                              # 0x53
	.byte	47                              # 0x2f
	.byte	84                              # 0x54
	.byte	69                              # 0x45
	.byte	88                              # 0x58
	.byte	84                              # 0x54
	.byte	85                              # 0x55
	.byte	82                              # 0x52
	.byte	69                              # 0x45
	.byte	83                              # 0x53
.LCPI21_31:
	.byte	112                             # 0x70
	.byte	117                             # 0x75
	.byte	116                             # 0x74
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
.LCPI21_32:
	.byte	101                             # 0x65
	.byte	120                             # 0x78
	.byte	116                             # 0x74
	.byte	101                             # 0x65
	.byte	114                             # 0x72
	.byte	110                             # 0x6e
	.byte	97                              # 0x61
	.byte	108                             # 0x6c
	.byte	45                              # 0x2d
	.byte	104                             # 0x68
	.byte	111                             # 0x6f
	.byte	115                             # 0x73
	.byte	116                             # 0x74
	.byte	45                              # 0x2d
	.byte	105                             # 0x69
	.byte	110                             # 0x6e
	.text
	.p2align	4
	.type	inspect_pi4_manifest,@function
inspect_pi4_manifest:                   # @inspect_pi4_manifest
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$16248, %rsp                    # imm = 0x3F78
	movl	%esi, %ebp
	movq	%rdi, %rbx
	movq	$0, 24(%rsp)
	leaq	PROOF_MANIFEST_PATH(%rip), %rsi
	leaq	416(%rsp), %rdx
	callq	inspect_find_path
	testl	%eax, %eax
	je	.LBB21_1
# %bb.3:
	leaq	PROOF_MANIFEST_PATH(%rip), %rdx
	leaq	416(%rsp), %rsi
	movq	%rbx, 32(%rsp)                  # 8-byte Spill
	movq	%rbx, %rdi
	callq	inspect_read_file_blob
	movq	%rax, %r15
	movq	%rax, (%rsp)
	movq	%rdx, 8(%rsp)
	leaq	.L.str.155(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_224
# %bb.4:
	movdqa	1072(%rsp), %xmm0
	movdqu	1086(%rsp), %xmm1
	pcmpeqb	.LCPI21_0(%rip), %xmm1
	pcmpeqb	.LCPI21_1(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_225
# %bb.5:
	leaq	.L.str.157(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_226
# %bb.6:
	movdqa	1072(%rsp), %xmm0
	movdqu	1077(%rsp), %xmm1
	pcmpeqb	.LCPI21_2(%rip), %xmm1
	pcmpeqb	.LCPI21_3(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_227
# %bb.7:
	leaq	.L.str.159(%rip), %rsi
	movq	%rsp, %rdi
	callq	manifest_require_u64
	cmpq	$2561, %rax                     # imm = 0xA01
	jne	.LBB21_228
# %bb.8:
	leaq	.L.str.160(%rip), %rsi
	movq	%rsp, %rdi
	callq	manifest_require_u64
	cmpq	$2593, %rax                     # imm = 0xA21
	jne	.LBB21_229
# %bb.9:
	leaq	.L.str.161(%rip), %rsi
	movq	%rsp, %rdi
	callq	manifest_require_u64
	cmpq	$512, %rax                      # imm = 0x200
	jne	.LBB21_230
# %bb.10:
	leaq	.L.str.162(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_231
# %bb.11:
	movdqa	1072(%rsp), %xmm0
	movd	1088(%rsp), %xmm1               # xmm1 = mem[0],zero,zero,zero
	pcmpeqb	.LCPI21_4(%rip), %xmm1
	pcmpeqb	.LCPI21_5(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_232
# %bb.12:
	movl	428(%rsp), %edx
	leaq	.L.str.163(%rip), %rdi
	leaq	PROOF_MANIFEST_PATH(%rip), %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.164(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_233
# %bb.13:
	movabsq	$3330495784990950731, %rax      # imm = 0x2E384C454E52454B
	xorq	1072(%rsp), %rax
	movl	1080(%rsp), %ecx
	xorq	$4672841, %rcx                  # imm = 0x474D49
	orq	%rax, %rcx
	jne	.LBB21_234
# %bb.14:
	leaq	.L.str.164(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_235
# %bb.15:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.164(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.165(%rip), %rdx
	leaq	.L.str.166(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.167(%rip), %rsi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_236
# %bb.16:
	movabsq	$6065864128152358723, %rax      # imm = 0x542E4749464E4F43
	xorq	1072(%rsp), %rax
	movabsq	$23741016620616006, %rcx        # imm = 0x5458542E474946
	xorq	1075(%rsp), %rcx
	orq	%rax, %rcx
	jne	.LBB21_237
# %bb.17:
	leaq	.L.str.167(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_238
# %bb.18:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.167(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.168(%rip), %rdx
	leaq	.L.str.169(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.170(%rip), %rsi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_239
# %bb.19:
	movdqa	1072(%rsp), %xmm0
	movdqu	1083(%rsp), %xmm1
	pcmpeqb	.LCPI21_6(%rip), %xmm1
	pcmpeqb	.LCPI21_7(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_240
# %bb.20:
	leaq	.L.str.170(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_241
# %bb.21:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.170(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.172(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_242
# %bb.22:
	movdqa	1072(%rsp), %xmm0
	movdqu	1083(%rsp), %xmm1
	pcmpeqb	.LCPI21_8(%rip), %xmm1
	pcmpeqb	.LCPI21_9(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_243
# %bb.23:
	leaq	.L.str.172(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_244
# %bb.24:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.172(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.173(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_245
# %bb.25:
	movabsq	$3274240491775026806, %rax      # imm = 0x2D7070612D736676
	xorq	1072(%rsp), %rax
	movabsq	$33888479228800368, %rcx        # imm = 0x7865646E692D70
	xorq	1078(%rsp), %rcx
	orq	%rax, %rcx
	jne	.LBB21_246
# %bb.26:
	leaq	.L.str.173(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_247
# %bb.27:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.173(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.174(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_248
# %bb.28:
	movdqa	1072(%rsp), %xmm0
	movdqu	1078(%rsp), %xmm1
	pcmpeqb	.LCPI21_10(%rip), %xmm1
	pcmpeqb	.LCPI21_11(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_249
# %bb.29:
	leaq	.L.str.174(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_250
# %bb.30:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.174(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.176(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_251
# %bb.31:
	movdqa	1072(%rsp), %xmm0
	movdqa	1088(%rsp), %xmm1
	pcmpeqb	.LCPI21_12(%rip), %xmm1
	pcmpeqb	.LCPI21_13(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_252
# %bb.32:
	leaq	.L.str.176(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_253
# %bb.33:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.176(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.177(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_254
# %bb.34:
	movabsq	$5065499746169867849, %rax      # imm = 0x464C452E54494E49
	xorq	1080(%rsp), %rax
	movabsq	$3408456721467265839, %rcx      # imm = 0x2F4D45545359532F
	xorq	1072(%rsp), %rcx
	movzbl	1088(%rsp), %edx
	orq	%rcx, %rdx
	orq	%rax, %rdx
	jne	.LBB21_255
# %bb.35:
	leaq	.L.str.177(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_256
# %bb.36:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.177(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	PI4_SYSTEM_INIT_PATH(%rip), %rdx
	leaq	.L.str.178(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.179(%rip), %rsi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_257
# %bb.37:
	movdqa	1072(%rsp), %xmm0
	movdqu	1077(%rsp), %xmm1
	pcmpeqb	.LCPI21_14(%rip), %xmm1
	pcmpeqb	.LCPI21_15(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_258
# %bb.38:
	leaq	.L.str.179(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_259
# %bb.39:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.179(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	PI4_SYSTEM_ABIPROBE_PATH(%rip), %rdx
	leaq	.L.str.180(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.181(%rip), %rsi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_260
# %bb.40:
	movdqa	1072(%rsp), %xmm0
	pcmpeqb	.LCPI21_16(%rip), %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_261
# %bb.41:
	leaq	.L.str.181(%rip), %rsi
	movq	%rsp, %rdi
	leaq	1072(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_262
# %bb.42:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.181(%rip), %rsi
	leaq	1072(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	PI4_APP_INDEX_PATH(%rip), %r14
	leaq	.L.str.182(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	32(%rsp), %r12                  # 8-byte Reload
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	inspect_manifest_require_file
	leaq	1072(%rsp), %rsi
	movq	%r12, %rdi
	movl	%ebp, %edx
	callq	load_pi4_app_catalog
	movq	1072(%rsp), %rdx
	leaq	.L.str.280(%rip), %rdi
	leaq	PI4_APP_DISCOVERY_MODEL(%rip), %rcx
	movq	%r14, %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	1072(%rsp), %rcx
	leaq	.L.str.183(%rip), %rdx
	leaq	592(%rsp), %rdi
	movl	$32, %esi
	xorl	%eax, %eax
	callq	snprintf@PLT
	leaq	PI4_APP_RECORD_COUNT_KEY(%rip), %rsi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_263
# %bb.43:
	leaq	48(%rsp), %rdi
	leaq	592(%rsp), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_264
# %bb.44:
	movl	%ebp, 236(%rsp)                 # 4-byte Spill
	movq	%r15, 376(%rsp)                 # 8-byte Spill
	leaq	PI4_APP_RECORD_COUNT_KEY(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_265
# %bb.45:
	leaq	.L.str.248(%rip), %rdi
	leaq	PI4_APP_RECORD_COUNT_KEY(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	cmpq	$0, 1072(%rsp)
	je	.LBB21_49
# %bb.46:
	movabsq	$3257288252468650337, %rcx      # imm = 0x2D34366863726161
	movabsq	$3270573694450034023, %rdx      # imm = 0x2D636972656E6567
	movabsq	$29401359420586338, %rax        # imm = 0x687461702D7962
	movabsq	$3271421361136888933, %rsi      # imm = 0x2D666C652D306C65
	leaq	PI4_APP_RECORD_PREFIX(%rip), %r12
	leaq	432(%rsp), %rbx
	movq	%rsp, %r13
	leaq	48(%rsp), %r15
	leaq	.L.str.248(%rip), %rbp
	movq	%rdx, %xmm1
	movq	%rcx, %xmm0
	movq	%rsi, %xmm2
	punpcklqdq	%xmm0, %xmm1            # xmm1 = xmm1[0],xmm0[0]
	movdqa	%xmm1, 256(%rsp)                # 16-byte Spill
	movq	%rax, %xmm0
	punpcklqdq	%xmm0, %xmm2            # xmm2 = xmm2[0],xmm0[0]
	movdqa	%xmm2, 240(%rsp)                # 16-byte Spill
	movq	$0, 40(%rsp)                    # 8-byte Folded Spill
	xorl	%r8d, %r8d
	jmp	.LBB21_47
	.p2align	4
.LBB21_117:                             #   in Loop: Header=BB21_47 Depth=1
	leaq	.L.str.292(%rip), %rdi
	movq	%r13, %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
.LBB21_118:                             #   in Loop: Header=BB21_47 Depth=1
	movq	16(%rsp), %r8                   # 8-byte Reload
	incq	%r8
	addq	$948, %rbp                      # imm = 0x3B4
	movq	%rbp, 40(%rsp)                  # 8-byte Spill
	cmpq	1072(%rsp), %r8
	leaq	PI4_APP_RECORD_PREFIX(%rip), %r12
	movq	%rsp, %r13
	leaq	48(%rsp), %r15
	leaq	.L.str.248(%rip), %rbp
	leaq	432(%rsp), %rbx
	jae	.LBB21_49
.LBB21_47:                              # =>This Inner Loop Header: Depth=1
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	%r8, 16(%rsp)                   # 8-byte Spill
	leaq	.L.str.259(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_48
# %bb.70:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	movq	40(%rsp), %r14                  # 8-byte Reload
	je	.LBB21_268
# %bb.71:                               #   in Loop: Header=BB21_47 Depth=1
	leaq	(%rsp,%r14), %rsi
	addq	$1080, %rsi                     # imm = 0x438
	movq	%r15, %rdi
	movq	%rsi, 216(%rsp)                 # 8-byte Spill
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_269
# %bb.72:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_270
# %bb.73:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.263(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_271
# %bb.74:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_272
# %bb.75:                               #   in Loop: Header=BB21_47 Depth=1
	leaq	(%rsp,%r14), %rsi
	addq	$1144, %rsi                     # imm = 0x478
	movq	%r15, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_273
# %bb.76:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_274
# %bb.77:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.260(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_275
# %bb.78:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_276
# %bb.79:                               #   in Loop: Header=BB21_47 Depth=1
	leaq	(%rsp,%r14), %rsi
	addq	$1240, %rsi                     # imm = 0x4D8
	movq	%r15, %rdi
	movq	%rsi, 320(%rsp)                 # 8-byte Spill
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_277
# %bb.80:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_278
# %bb.81:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.281(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_279
# %bb.82:                               #   in Loop: Header=BB21_47 Depth=1
	movl	1988(%rsp,%r14), %r14d
	movq	%r13, %rdi
	movq	%rbx, %rsi
	callq	manifest_require_u64
	cmpq	%r14, %rax
	jne	.LBB21_280
# %bb.83:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_281
# %bb.84:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.264(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	movq	40(%rsp), %r14                  # 8-byte Reload
	jae	.LBB21_282
# %bb.85:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_283
# %bb.86:                               #   in Loop: Header=BB21_47 Depth=1
	leaq	(%rsp,%r14), %rsi
	addq	$1400, %rsi                     # imm = 0x578
	movq	%r15, %rdi
	movq	%rsi, 304(%rsp)                 # 8-byte Spill
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_284
# %bb.87:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_285
# %bb.88:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.282(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_286
# %bb.89:                               #   in Loop: Header=BB21_47 Depth=1
	movl	2004(%rsp,%r14), %r14d
	movq	%r13, %rdi
	movq	%rbx, %rsi
	callq	manifest_require_u64
	cmpq	%r14, %rax
	jne	.LBB21_287
# %bb.90:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_288
# %bb.91:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.283(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	movq	40(%rsp), %r14                  # 8-byte Reload
	jae	.LBB21_289
# %bb.92:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_290
# %bb.93:                               #   in Loop: Header=BB21_47 Depth=1
	movzwl	64(%rsp), %eax
	movd	%eax, %xmm0
	pcmpeqb	.LCPI21_18(%rip), %xmm0
	movdqa	48(%rsp), %xmm1
	pcmpeqb	.LCPI21_17(%rip), %xmm1
	pand	%xmm0, %xmm1
	pmovmskb	%xmm1, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_291
# %bb.94:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_292
# %bb.95:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.284(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_293
# %bb.96:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_294
# %bb.97:                               #   in Loop: Header=BB21_47 Depth=1
	movdqa	64(%rsp), %xmm0
	pcmpeqb	240(%rsp), %xmm0                # 16-byte Folded Reload
	movdqa	48(%rsp), %xmm1
	pcmpeqb	256(%rsp), %xmm1                # 16-byte Folded Reload
	pand	%xmm0, %xmm1
	pmovmskb	%xmm1, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_295
# %bb.98:                               #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_296
# %bb.99:                               #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.285(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_297
# %bb.100:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_298
# %bb.101:                              #   in Loop: Header=BB21_47 Depth=1
	leaq	(%rsp,%r14), %rsi
	addq	$1560, %rsi                     # imm = 0x618
	movq	%r15, %rdi
	movq	%rsi, 224(%rsp)                 # 8-byte Spill
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_299
# %bb.102:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_300
# %bb.103:                              #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %r8                   # 8-byte Reload
	leaq	.L.str.220(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_301
# %bb.104:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_302
# %bb.105:                              #   in Loop: Header=BB21_47 Depth=1
	movq	%r15, %rdi
	movq	224(%rsp), %rsi                 # 8-byte Reload
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_303
# %bb.106:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%r13, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_304
# %bb.107:                              #   in Loop: Header=BB21_47 Depth=1
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	movq	%r12, %rcx
	movq	16(%rsp), %rbp                  # 8-byte Reload
	movq	%rbp, %r8
	leaq	.L.str.265(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_305
# %bb.108:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%rsp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_306
# %bb.109:                              #   in Loop: Header=BB21_47 Depth=1
	leaq	(%rsp,%r14), %r13
	addq	$1720, %r13                     # imm = 0x6B8
	movq	%r15, %rdi
	movq	%r13, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_307
# %bb.110:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%rsp, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_308
# %bb.111:                              #   in Loop: Header=BB21_47 Depth=1
	leaq	.L.str.248(%rip), %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$64, %esi
	movq	%rbx, %rdi
	leaq	.L.str.276(%rip), %rdx
	leaq	PI4_APP_RECORD_PREFIX(%rip), %rcx
	movq	%rbp, %r8
	leaq	.L.str.286(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_309
# %bb.112:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%rsp, %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_310
# %bb.113:                              #   in Loop: Header=BB21_47 Depth=1
	movq	48(%rsp), %rax
	movabsq	$7308613637443382901, %rcx      # imm = 0x656D69616C636E75
	xorq	%rcx, %rax
	movzwl	56(%rsp), %ecx
	xorq	$100, %rcx
	orq	%rax, %rcx
	jne	.LBB21_311
# %bb.114:                              #   in Loop: Header=BB21_47 Depth=1
	movl	$160, %ecx
	movq	%rsp, %rdi
	leaq	432(%rsp), %rbx
	movq	%rbx, %rsi
	leaq	48(%rsp), %r15
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_312
# %bb.115:                              #   in Loop: Header=BB21_47 Depth=1
	leaq	.L.str.248(%rip), %rdi
	movq	%rbx, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.287(%rip), %rdi
	leaq	PI4_APP_RECORD_PREFIX(%rip), %rsi
	movq	%rbp, %rdx
	movq	216(%rsp), %rbx                 # 8-byte Reload
	movq	%rbx, %rcx
	movq	320(%rsp), %r12                 # 8-byte Reload
	movq	%r12, %r8
	movq	304(%rsp), %r14                 # 8-byte Reload
	movq	%r14, %r9
	xorl	%eax, %eax
	leaq	PI4_APP_EXEC_MODEL(%rip), %r15
	pushq	%r15
	leaq	PI4_APP_LAUNCH_MODEL(%rip), %r10
	pushq	%r10
	pushq	%r13
	movq	%r13, %r15
	movq	248(%rsp), %r13                 # 8-byte Reload
	pushq	%r13
	callq	printf@PLT
	addq	$32, %rsp
	movq	40(%rsp), %rbp                  # 8-byte Reload
	leaq	(%rsp,%rbp), %r10
	addq	$1880, %r10                     # imm = 0x758
	subq	$8, %rsp
	leaq	.L.str.288(%rip), %rdi
	movq	%r12, %rsi
	movq	%rbx, %rdx
	movq	%r14, %rcx
	movq	%r15, %r8
	movq	%r13, %r9
	xorl	%eax, %eax
	pushq	%r10
	callq	printf@PLT
	addq	$16, %rsp
	movl	2000(%rsp,%rbp), %r9d
	movl	2004(%rsp,%rbp), %r8d
	leaq	.L.str.289(%rip), %rdi
	movq	%r14, %rsi
	leaq	PI4_APP_EXEC_MODEL(%rip), %rdx
	movq	%rbx, %rcx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.290(%rip), %rdi
	movq	%r15, %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	cmpl	$0, 2024(%rsp,%rbp)
	je	.LBB21_117
# %bb.116:                              #   in Loop: Header=BB21_47 Depth=1
	movl	2016(%rsp,%rbp), %r8d
	movl	2020(%rsp,%rbp), %ecx
	leaq	.L.str.291(%rip), %rdi
	movq	%r13, %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	jmp	.LBB21_118
.LBB21_49:
	leaq	.L.str.184(%rip), %rsi
	movq	%rsp, %rdi
	callq	manifest_require_u64
	cmpq	$257, %rax                      # imm = 0x101
	jae	.LBB21_266
# %bb.50:
	movq	%rax, %rbx
	leaq	.L.str.184(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	movq	32(%rsp), %rbp                  # 8-byte Reload
	je	.LBB21_267
# %bb.51:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.184(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	testq	%rbx, %rbx
	je	.LBB21_54
# %bb.52:
	xorl	%r14d, %r14d
	leaq	.L.str.185(%rip), %r15
	movq	%rsp, %r12
	leaq	24(%rsp), %r13
	.p2align	4
.LBB21_53:                              # =>This Inner Loop Header: Depth=1
	movq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	movq	%r14, %rcx
	movq	%r13, %r8
	callq	inspect_manifest_require_indexed_sized_file
	incq	%r14
	cmpq	%r14, %rbx
	jne	.LBB21_53
.LBB21_54:
	leaq	.L.str.186(%rip), %rsi
	movq	%rsp, %rdi
	callq	manifest_require_u64
	cmpq	$257, %rax                      # imm = 0x101
	jae	.LBB21_313
# %bb.55:
	movq	%rax, %rbx
	leaq	.L.str.186(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_314
# %bb.56:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.186(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	testq	%rbx, %rbx
	je	.LBB21_59
# %bb.57:
	xorl	%r14d, %r14d
	leaq	.L.str.187(%rip), %r15
	movq	%rsp, %r12
	leaq	24(%rsp), %r13
	.p2align	4
.LBB21_58:                              # =>This Inner Loop Header: Depth=1
	movq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	movq	%r14, %rcx
	movq	%r13, %r8
	callq	inspect_manifest_require_indexed_sized_file
	incq	%r14
	cmpq	%r14, %rbx
	jne	.LBB21_58
.LBB21_59:
	leaq	.L.str.188(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_315
# %bb.60:
	movabsq	$4708282724724461380, %rax      # imm = 0x41572E314D4F4F44
	xorq	48(%rsp), %rax
	movzwl	56(%rsp), %ecx
	xorq	$68, %rcx
	orq	%rax, %rcx
	jne	.LBB21_316
# %bb.61:
	leaq	.L.str.190(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_317
# %bb.62:
	movabsq	$7233193513526980452, %rax      # imm = 0x6461772D6D6F6F64
	xorq	48(%rsp), %rax
	movzbl	56(%rsp), %ecx
	orq	%rax, %rcx
	jne	.LBB21_318
# %bb.63:
	leaq	.L.str.192(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_319
# %bb.64:
	movabsq	$32772479305216624, %rax        # imm = 0x746E6573657270
	cmpq	%rax, 48(%rsp)
	jne	.LBB21_320
# %bb.65:
	leaq	.L.str.194(%rip), %rsi
	movq	%rsp, %rdi
	leaq	272(%rsp), %rdx
	movl	$32, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_321
# %bb.66:
	leaq	.L.str.196(%rip), %rsi
	movq	%rsp, %rdi
	leaq	336(%rsp), %rdx
	movl	$32, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_322
# %bb.67:
	movabsq	$7809644666444609637, %rcx      # imm = 0x6C616E7265747865
	movabsq	$3271131108425889135, %rdx      # imm = 0x2D6564697374756F
	movabsq	$31367303424468324, %rsi        # imm = 0x6F7065722D6564
	movq	272(%rsp), %rax
	xorq	%rcx, %rax
	movzbl	280(%rsp), %ecx
	orq	%rax, %rcx
	je	.LBB21_68
# %bb.119:
	movdqa	272(%rsp), %xmm0
	movzwl	288(%rsp), %eax
	movd	%eax, %xmm1
	pcmpeqb	.LCPI21_19(%rip), %xmm0
	pcmpeqb	.LCPI21_20(%rip), %xmm1
	pand	%xmm0, %xmm1
	pmovmskb	%xmm1, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_122
# %bb.120:
	movdqa	336(%rsp), %xmm0
	movdqu	341(%rsp), %xmm1
	pcmpeqb	.LCPI21_21(%rip), %xmm1
	pcmpeqb	.LCPI21_22(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	je	.LBB21_123
# %bb.121:
	callq	inspect_pi4_manifest.cold.68
.LBB21_1:
	testl	%ebp, %ebp
	je	.LBB21_223
# %bb.2:
	callq	inspect_pi4_manifest.cold.191
.LBB21_68:
	movq	336(%rsp), %rax
	xorq	%rdx, %rax
	movq	341(%rsp), %rcx
	xorq	%rsi, %rcx
	orq	%rax, %rcx
	jne	.LBB21_69
.LBB21_123:
	leaq	.L.str.205(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_323
# %bb.124:
	movdqa	48(%rsp), %xmm0
	movdqu	51(%rsp), %xmm1
	pcmpeqb	.LCPI21_23(%rip), %xmm1
	pcmpeqb	.LCPI21_24(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_324
# %bb.125:
	leaq	.L.str.207(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_325
# %bb.126:
	movq	48(%rsp), %rax
	movabsq	$7308613637443382901, %rcx      # imm = 0x656D69616C636E75
	xorq	%rcx, %rax
	movzwl	56(%rsp), %ecx
	xorq	$100, %rcx
	orq	%rax, %rcx
	jne	.LBB21_326
# %bb.127:
	leaq	.L.str.189(%rip), %rdx
	leaq	.L.str.209(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.188(%rip), %rsi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_327
# %bb.128:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.188(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.190(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_328
# %bb.129:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.190(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.192(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_329
# %bb.130:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.192(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.194(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_330
# %bb.131:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.194(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.196(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_331
# %bb.132:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.196(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.205(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_332
# %bb.133:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.205(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.207(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_333
# %bb.134:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.207(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.209(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_334
# %bb.135:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.209(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.210(%rip), %rdi
	leaq	272(%rsp), %rsi
	leaq	336(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.211(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_335
# %bb.136:
	cmpw	$51, 48(%rsp)
	jne	.LBB21_336
# %bb.137:
	leaq	.L.str.213(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_337
# %bb.138:
	movdqa	48(%rsp), %xmm0
	movdqu	51(%rsp), %xmm1
	pcmpeqb	.LCPI21_25(%rip), %xmm1
	pcmpeqb	.LCPI21_26(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_338
# %bb.139:
	leaq	DEFAULT_PI4_ASSET_README_PATH(%rip), %rdx
	leaq	.L.str.214(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.215(%rip), %rsi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_339
# %bb.140:
	movdqa	48(%rsp), %xmm0
	movdqu	54(%rsp), %xmm1
	pcmpeqb	.LCPI21_27(%rip), %xmm1
	pcmpeqb	.LCPI21_28(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_340
# %bb.141:
	leaq	DEFAULT_PI4_ASSET_MAP_PATH(%rip), %rdx
	leaq	.L.str.216(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.217(%rip), %rsi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_341
# %bb.142:
	movdqa	48(%rsp), %xmm0
	movdqu	58(%rsp), %xmm1
	pcmpeqb	.LCPI21_29(%rip), %xmm1
	pcmpeqb	.LCPI21_30(%rip), %xmm0
	pand	%xmm1, %xmm0
	pmovmskb	%xmm0, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_342
# %bb.143:
	leaq	DEFAULT_PI4_ASSET_PALETTE_PATH(%rip), %rdx
	leaq	.L.str.218(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.219(%rip), %rsi
	movq	%rbx, %rdi
	callq	manifest_require_u64
	movq	%rax, 216(%rsp)                 # 8-byte Spill
	cmpq	$257, %rax                      # imm = 0x101
	jae	.LBB21_343
# %bb.144:
	leaq	.L.str.219(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_344
# %bb.145:
	movabsq	$7957628980220749357, %rbx      # imm = 0x6E6F2D656C69662D
	movabsq	$7234302044551733616, %r15      # imm = 0x646567616B636170
	movabsq	$34177693749437804, %r12        # imm = 0x796C6E6F2D656C
	movabsq	$7594807730828173675, %r13      # imm = 0x69662D646567616B
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.219(%rip), %rsi
	xorl	%r14d, %r14d
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movq	%r15, %xmm0
	movdqa	%xmm0, 256(%rsp)                # 16-byte Spill
	movq	%rbx, %xmm0
	movdqa	%xmm0, 384(%rsp)                # 16-byte Spill
	movq	%r13, %xmm0
	movdqa	%xmm0, 240(%rsp)                # 16-byte Spill
	movq	%r12, %xmm0
	movdqa	%xmm0, 400(%rsp)                # 16-byte Spill
	cmpq	$0, 216(%rsp)                   # 8-byte Folded Reload
	je	.LBB21_150
# %bb.146:
	leaq	.L.str.220(%rip), %r15
	leaq	944(%rsp), %r12
	movq	%rsp, %r14
	leaq	1008(%rsp), %rbp
	movaps	256(%rsp), %xmm0                # 16-byte Reload
	unpcklpd	384(%rsp), %xmm0                # 16-byte Folded Reload
                                        # xmm0 = xmm0[0],mem[0]
	movaps	%xmm0, 320(%rsp)                # 16-byte Spill
	movdqa	240(%rsp), %xmm0                # 16-byte Reload
	punpcklqdq	400(%rsp), %xmm0        # 16-byte Folded Reload
                                        # xmm0 = xmm0[0],mem[0]
	movdqa	%xmm0, 304(%rsp)                # 16-byte Spill
	xorl	%r13d, %r13d
	xorl	%ebx, %ebx
	.p2align	4
.LBB21_147:                             # =>This Inner Loop Header: Depth=1
	movl	$64, %esi
	movq	%r12, %rdi
	leaq	.L.str.294(%rip), %rdx
	movq	%r15, %rcx
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_148
# %bb.156:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	880(%rsp), %rdi
	leaq	.L.str.296(%rip), %rdx
	movq	%r15, %rcx
	movq	%r13, 16(%rsp)                  # 8-byte Spill
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_349
# %bb.157:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%r12, %rsi
	leaq	432(%rsp), %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_350
# %bb.158:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	816(%rsp), %rdi
	leaq	.L.str.299(%rip), %rdx
	movq	%r15, %rcx
	movq	16(%rsp), %r13                  # 8-byte Reload
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	leaq	752(%rsp), %rdi
	leaq	624(%rsp), %r12
	jae	.LBB21_351
# %bb.159:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	.L.str.300(%rip), %rdx
	movq	%r15, %rcx
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_352
# %bb.160:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	leaq	688(%rsp), %rdi
	leaq	.L.str.301(%rip), %rdx
	movq	%r15, %rcx
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_353
# %bb.161:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$64, %esi
	movq	%rbp, %rdi
	leaq	.L.str.302(%rip), %rdx
	movq	%r15, %rcx
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_354
# %bb.162:                              #   in Loop: Header=BB21_147 Depth=1
	movl	%ebx, 40(%rsp)                  # 4-byte Spill
	movl	$64, %esi
	movq	%r12, %rdi
	leaq	.L.str.303(%rip), %rdx
	movq	%r15, %rcx
	movq	%r13, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB21_355
# %bb.163:                              #   in Loop: Header=BB21_147 Depth=1
	movq	432(%rsp), %rax
	movabsq	$5422703589951031599, %rcx      # imm = 0x4B41502F3144492F
	xorq	%rcx, %rax
	movq	438(%rsp), %rcx
	movabsq	$21182435881405249, %rdx        # imm = 0x4B41502E304B41
	xorq	%rdx, %rcx
	xorl	%r15d, %r15d
	orq	%rax, %rcx
	setne	%r12b
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	816(%rsp), %rsi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_356
# %bb.164:                              #   in Loop: Header=BB21_147 Depth=1
	movb	%r12b, %r15b
	testl	%r15d, %r15d
	leaq	.L.str.306(%rip), %rsi
	leaq	.L.str.305(%rip), %rax
	cmoveq	%rax, %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_357
# %bb.165:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	752(%rsp), %rsi
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_358
# %bb.166:                              #   in Loop: Header=BB21_147 Depth=1
	movd	64(%rsp), %xmm0                 # xmm0 = mem[0],zero,zero,zero
	pcmpeqb	.LCPI21_31(%rip), %xmm0
	movdqa	48(%rsp), %xmm1
	pcmpeqb	.LCPI21_32(%rip), %xmm1
	pand	%xmm0, %xmm1
	pmovmskb	%xmm1, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_359
# %bb.167:                              #   in Loop: Header=BB21_147 Depth=1
	movq	432(%rsp), %rax
	movabsq	$5422703589951031599, %rcx      # imm = 0x4B41502F3144492F
	xorq	%rcx, %rax
	movq	438(%rsp), %rcx
	movabsq	$21182435881405249, %rdx        # imm = 0x4B41502E304B41
	xorq	%rdx, %rcx
	xorl	%r15d, %r15d
	orq	%rax, %rcx
	setne	%r12b
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	688(%rsp), %rsi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_360
# %bb.168:                              #   in Loop: Header=BB21_147 Depth=1
	movb	%r12b, %r15b
	testl	%r15d, %r15d
	leaq	.L.str.307(%rip), %rsi
	leaq	.L.str.199(%rip), %rax
	cmoveq	%rax, %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB21_361
# %bb.169:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%rbp, %rsi
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	leaq	624(%rsp), %rsi
	je	.LBB21_362
# %bb.170:                              #   in Loop: Header=BB21_147 Depth=1
	movdqu	51(%rsp), %xmm0
	pcmpeqb	304(%rsp), %xmm0                # 16-byte Folded Reload
	movdqa	48(%rsp), %xmm1
	pcmpeqb	320(%rsp), %xmm1                # 16-byte Folded Reload
	pand	%xmm0, %xmm1
	pmovmskb	%xmm1, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_363
# %bb.171:                              #   in Loop: Header=BB21_147 Depth=1
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_364
# %bb.172:                              #   in Loop: Header=BB21_147 Depth=1
	movq	48(%rsp), %rax
	movabsq	$7308613637443382901, %rcx      # imm = 0x656D69616C636E75
	xorq	%rcx, %rax
	movzwl	56(%rsp), %ecx
	xorq	$100, %rcx
	orq	%rax, %rcx
	jne	.LBB21_365
# %bb.173:                              #   in Loop: Header=BB21_147 Depth=1
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%r14, %rsi
	leaq	432(%rsp), %rdx
	leaq	880(%rsp), %rcx
	leaq	24(%rsp), %r8
	callq	inspect_manifest_require_file
	movq	432(%rsp), %rax
	movabsq	$5422703589951031599, %rcx      # imm = 0x4B41502F3144492F
	xorq	%rcx, %rax
	movq	438(%rsp), %rcx
	movabsq	$21182435881405249, %rdx        # imm = 0x4B41502E304B41
	xorq	%rdx, %rcx
	orq	%rax, %rcx
	setne	%bpl
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	944(%rsp), %r13
	movq	%r13, %rsi
	leaq	48(%rsp), %r15
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_366
# %bb.174:                              #   in Loop: Header=BB21_147 Depth=1
	leaq	.L.str.248(%rip), %rbx
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	816(%rsp), %r13
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_367
# %bb.175:                              #   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	752(%rsp), %r13
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_368
# %bb.176:                              #   in Loop: Header=BB21_147 Depth=1
	movb	%bpl, 224(%rsp)                 # 1-byte Spill
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	688(%rsp), %r13
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_369
# %bb.177:                              #   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	1008(%rsp), %rbp
	movq	%rbp, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	leaq	624(%rsp), %r12
	je	.LBB21_370
# %bb.178:                              #   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$160, %ecx
	movq	%r14, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_371
# %bb.179:                              #   in Loop: Header=BB21_147 Depth=1
	movq	%rbx, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$160, %ecx
	movq	%r14, %rdi
	leaq	880(%rsp), %r12
	movq	%r12, %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_372
# %bb.180:                              #   in Loop: Header=BB21_147 Depth=1
	movq	%r15, %rdx
	xorl	%r15d, %r15d
	movzbl	224(%rsp), %eax                 # 1-byte Folded Reload
	movb	%al, %r15b
	movq	%rbx, %rdi
	movq	%r12, %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	testl	%r15d, %r15d
	movl	$1, %eax
	movl	40(%rsp), %ebx                  # 4-byte Reload
	cmovel	%eax, %ebx
	movq	16(%rsp), %r13                  # 8-byte Reload
	incq	%r13
	cmpq	%r13, 216(%rsp)                 # 8-byte Folded Reload
	leaq	.L.str.220(%rip), %r15
	leaq	944(%rsp), %r12
	jne	.LBB21_147
# %bb.149:
	testl	%ebx, %ebx
	setne	%r14b
.LBB21_150:
	leaq	.L.str.221(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_345
# %bb.151:
	movabsq	$5422703589951031599, %rax      # imm = 0x4B41502F3144492F
	xorq	48(%rsp), %rax
	movabsq	$21182435881405249, %rcx        # imm = 0x4B41502E304B41
	xorq	54(%rsp), %rcx
	orq	%rax, %rcx
	movabsq	$32772479305216624, %r15        # imm = 0x746E6573657270
	movabsq	$3271131108425889135, %r12      # imm = 0x2D6564697374756F
	movabsq	$31367303424468324, %r13        # imm = 0x6F7065722D6564
	jne	.LBB21_346
# %bb.152:
	leaq	.L.str.222(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_347
# %bb.153:
	movabsq	$7021161732687099249, %rax      # imm = 0x61702D656B617571
	xorq	48(%rsp), %rax
	movzwl	56(%rsp), %ecx
	xorq	$107, %rcx
	orq	%rax, %rcx
	jne	.LBB21_348
# %bb.154:
	leaq	.L.str.224(%rip), %rsi
	movq	%rsp, %rdi
	leaq	432(%rsp), %rdx
	movl	$32, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_155
# %bb.181:
	movl	$1702060641, %eax               # imm = 0x65736261
	xorl	432(%rsp), %eax
	movl	$7630437, %ebp                  # imm = 0x746E65
	xorl	435(%rsp), %ebp
	orl	%eax, %ebp
	je	.LBB21_182
# %bb.198:
	cmpq	%r15, 432(%rsp)
	jne	.LBB21_404
# %bb.199:
	leaq	.L.str.227(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_388
# %bb.200:
	movq	48(%rsp), %rax
	movabsq	$7809644666444609637, %rcx      # imm = 0x6C616E7265747865
	xorq	%rcx, %rax
	movzbl	56(%rsp), %ecx
	orq	%rax, %rcx
	jne	.LBB21_389
# %bb.201:
	leaq	.L.str.228(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_390
# %bb.202:
	movq	48(%rsp), %rax
	xorq	%r12, %rax
	movq	53(%rsp), %rcx
	xorq	%r13, %rcx
	orq	%rax, %rcx
	jne	.LBB21_391
# %bb.203:
	leaq	.L.str.229(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_392
# %bb.204:
	movdqa	256(%rsp), %xmm1                # 16-byte Reload
	punpcklqdq	384(%rsp), %xmm1        # 16-byte Folded Reload
                                        # xmm1 = xmm1[0],mem[0]
	movdqu	51(%rsp), %xmm0
	movdqa	240(%rsp), %xmm2                # 16-byte Reload
	punpcklqdq	400(%rsp), %xmm2        # 16-byte Folded Reload
                                        # xmm2 = xmm2[0],mem[0]
	pcmpeqb	48(%rsp), %xmm1
	pcmpeqb	%xmm0, %xmm2
	pand	%xmm2, %xmm1
	pmovmskb	%xmm1, %eax
	cmpl	$65535, %eax                    # imm = 0xFFFF
	jne	.LBB21_393
# %bb.205:
	leaq	.L.str.230(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_394
# %bb.206:
	movabsq	$7308613637443382901, %rcx      # imm = 0x656D69616C636E75
	xorq	48(%rsp), %rcx
	movzwl	56(%rsp), %eax
	xorq	$100, %rax
	orq	%rcx, %rax
	jne	.LBB21_395
# %bb.207:
	leaq	PROOF_QUAKE_PAK_PATH(%rip), %rdx
	leaq	.L.str.232(%rip), %rcx
	movq	%rsp, %rbx
	leaq	24(%rsp), %r8
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	inspect_manifest_require_file
	leaq	.L.str.221(%rip), %rsi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_396
# %bb.208:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.221(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.222(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_397
# %bb.209:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.222(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.224(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_398
# %bb.210:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.224(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.227(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_399
# %bb.211:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.227(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.228(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_400
# %bb.212:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.228(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.229(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_401
# %bb.213:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.229(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.230(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_402
# %bb.214:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.230(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.232(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_403
# %bb.215:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.232(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.233(%rip), %rdi
	leaq	PROOF_QUAKE_PAK_PATH(%rip), %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.206(%rip), %rcx
	jmp	.LBB21_216
.LBB21_182:
	leaq	.L.str.227(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_373
# %bb.183:
	movl	$1702060641, %eax               # imm = 0x65736261
	xorl	48(%rsp), %eax
	movl	$7630437, %ecx                  # imm = 0x746E65
	xorl	51(%rsp), %ecx
	orl	%eax, %ecx
	jne	.LBB21_374
# %bb.184:
	leaq	.L.str.228(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_375
# %bb.185:
	movl	$1702060641, %eax               # imm = 0x65736261
	xorl	48(%rsp), %eax
	movl	$7630437, %ecx                  # imm = 0x746E65
	xorl	51(%rsp), %ecx
	orl	%eax, %ecx
	jne	.LBB21_376
# %bb.186:
	leaq	.L.str.229(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_377
# %bb.187:
	movl	$1702060641, %eax               # imm = 0x65736261
	xorl	48(%rsp), %eax
	movl	$7630437, %ecx                  # imm = 0x746E65
	xorl	51(%rsp), %ecx
	orl	%eax, %ecx
	jne	.LBB21_378
# %bb.188:
	leaq	.L.str.230(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_379
# %bb.189:
	movabsq	$7308613637443382901, %rcx      # imm = 0x656D69616C636E75
	xorq	48(%rsp), %rcx
	movzwl	56(%rsp), %eax
	xorq	$100, %rax
	orq	%rcx, %rax
	jne	.LBB21_380
# %bb.190:
	leaq	.L.str.221(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_381
# %bb.191:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.221(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.222(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_382
# %bb.192:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.222(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.224(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_383
# %bb.193:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.224(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.227(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_384
# %bb.194:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.227(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.228(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_385
# %bb.195:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.228(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.229(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_386
# %bb.196:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.229(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.230(%rip), %rsi
	movq	%rsp, %rdi
	leaq	48(%rsp), %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB21_387
# %bb.197:
	leaq	.L.str.248(%rip), %rdi
	leaq	.L.str.230(%rip), %rsi
	leaq	48(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.231(%rip), %rdi
	leaq	PROOF_QUAKE_PAK_PATH(%rip), %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	cmpq	%r15, 432(%rsp)
	leaq	.L.str.206(%rip), %rax
	leaq	.L.str.226(%rip), %rcx
	cmoveq	%rax, %rcx
.LBB21_216:
	leaq	.L.str.235(%rip), %rdi
	leaq	272(%rsp), %rsi
	leaq	432(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	cmpl	$0, 236(%rsp)                   # 4-byte Folded Reload
	je	.LBB21_222
# %bb.217:
	movabsq	$7809644666444609637, %rcx      # imm = 0x6C616E7265747865
	xorq	272(%rsp), %rcx
	movzbl	280(%rsp), %eax
	orq	%rcx, %rax
	jne	.LBB21_405
# %bb.218:
	xorq	336(%rsp), %r12
	xorq	341(%rsp), %r13
	orq	%r12, %r13
	jne	.LBB21_405
# %bb.219:
	cmpq	%r15, 432(%rsp)
	jne	.LBB21_406
# %bb.220:
	testl	%ebp, %ebp
	setne	%al
	testb	%al, %r14b
	je	.LBB21_407
# %bb.221:
	leaq	.Lstr.516(%rip), %rdi
	callq	puts@PLT
.LBB21_222:
	movq	24(%rsp), %rsi
	leaq	.L.str.240(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	376(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
.LBB21_223:
	addq	$16248, %rsp                    # imm = 0x3F78
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB21_48:
	callq	inspect_pi4_manifest.cold.63
.LBB21_268:
	callq	inspect_pi4_manifest.cold.62
.LBB21_270:
	callq	inspect_pi4_manifest.cold.61
.LBB21_271:
	callq	inspect_pi4_manifest.cold.60
.LBB21_272:
	callq	inspect_pi4_manifest.cold.59
.LBB21_274:
	callq	inspect_pi4_manifest.cold.58
.LBB21_275:
	callq	inspect_pi4_manifest.cold.57
.LBB21_276:
	callq	inspect_pi4_manifest.cold.56
.LBB21_278:
	callq	inspect_pi4_manifest.cold.55
.LBB21_279:
	callq	inspect_pi4_manifest.cold.54
.LBB21_281:
	callq	inspect_pi4_manifest.cold.53
.LBB21_282:
	callq	inspect_pi4_manifest.cold.52
.LBB21_283:
	callq	inspect_pi4_manifest.cold.51
.LBB21_280:
	callq	inspect_pi4_manifest.cold.21
.LBB21_277:
	callq	inspect_pi4_manifest.cold.20
.LBB21_273:
	callq	inspect_pi4_manifest.cold.19
.LBB21_269:
	callq	inspect_pi4_manifest.cold.18
.LBB21_285:
	callq	inspect_pi4_manifest.cold.50
.LBB21_286:
	callq	inspect_pi4_manifest.cold.49
.LBB21_288:
	callq	inspect_pi4_manifest.cold.48
.LBB21_289:
	callq	inspect_pi4_manifest.cold.47
.LBB21_290:
	callq	inspect_pi4_manifest.cold.46
.LBB21_292:
	callq	inspect_pi4_manifest.cold.45
.LBB21_293:
	callq	inspect_pi4_manifest.cold.44
.LBB21_294:
	callq	inspect_pi4_manifest.cold.43
.LBB21_296:
	callq	inspect_pi4_manifest.cold.42
.LBB21_297:
	callq	inspect_pi4_manifest.cold.41
.LBB21_298:
	callq	inspect_pi4_manifest.cold.40
.LBB21_300:
	callq	inspect_pi4_manifest.cold.39
.LBB21_301:
	callq	inspect_pi4_manifest.cold.38
.LBB21_302:
	callq	inspect_pi4_manifest.cold.37
.LBB21_304:
	callq	inspect_pi4_manifest.cold.36
.LBB21_305:
	callq	inspect_pi4_manifest.cold.35
.LBB21_306:
	callq	inspect_pi4_manifest.cold.34
.LBB21_308:
	callq	inspect_pi4_manifest.cold.33
.LBB21_309:
	callq	inspect_pi4_manifest.cold.32
.LBB21_310:
	callq	inspect_pi4_manifest.cold.31
.LBB21_312:
	callq	inspect_pi4_manifest.cold.30
.LBB21_311:
	callq	inspect_pi4_manifest.cold.29
.LBB21_307:
	callq	inspect_pi4_manifest.cold.28
.LBB21_303:
	callq	inspect_pi4_manifest.cold.27
.LBB21_299:
	callq	inspect_pi4_manifest.cold.26
.LBB21_295:
	callq	inspect_pi4_manifest.cold.25
.LBB21_291:
	callq	inspect_pi4_manifest.cold.24
.LBB21_287:
	callq	inspect_pi4_manifest.cold.23
.LBB21_284:
	callq	inspect_pi4_manifest.cold.22
.LBB21_363:
	callq	inspect_pi4_manifest.cold.79
.LBB21_361:
	callq	inspect_pi4_manifest.cold.78
.LBB21_359:
	callq	inspect_pi4_manifest.cold.77
.LBB21_357:
	callq	inspect_pi4_manifest.cold.76
.LBB21_362:
	callq	inspect_pi4_manifest.cold.89
.LBB21_352:
	callq	inspect_pi4_manifest.cold.96
.LBB21_364:
	callq	inspect_pi4_manifest.cold.88
.LBB21_358:
	callq	inspect_pi4_manifest.cold.91
.LBB21_350:
	callq	inspect_pi4_manifest.cold.98
.LBB21_351:
	callq	inspect_pi4_manifest.cold.97
.LBB21_355:
	callq	inspect_pi4_manifest.cold.93
.LBB21_148:
	callq	inspect_pi4_manifest.cold.100
.LBB21_349:
	callq	inspect_pi4_manifest.cold.99
.LBB21_353:
	callq	inspect_pi4_manifest.cold.95
.LBB21_354:
	callq	inspect_pi4_manifest.cold.94
.LBB21_356:
	callq	inspect_pi4_manifest.cold.92
.LBB21_360:
	callq	inspect_pi4_manifest.cold.90
.LBB21_365:
	callq	inspect_pi4_manifest.cold.80
.LBB21_370:
	callq	inspect_pi4_manifest.cold.83
.LBB21_369:
	callq	inspect_pi4_manifest.cold.84
.LBB21_368:
	callq	inspect_pi4_manifest.cold.85
.LBB21_367:
	callq	inspect_pi4_manifest.cold.86
.LBB21_371:
	callq	inspect_pi4_manifest.cold.82
.LBB21_366:
	callq	inspect_pi4_manifest.cold.87
.LBB21_372:
	callq	inspect_pi4_manifest.cold.81
.LBB21_405:
	callq	inspect_pi4_manifest.cold.123
.LBB21_224:
	callq	inspect_pi4_manifest.cold.190
.LBB21_225:
	callq	inspect_pi4_manifest.cold.1
.LBB21_226:
	callq	inspect_pi4_manifest.cold.189
.LBB21_227:
	callq	inspect_pi4_manifest.cold.2
.LBB21_228:
	callq	inspect_pi4_manifest.cold.3
.LBB21_229:
	callq	inspect_pi4_manifest.cold.4
.LBB21_230:
	callq	inspect_pi4_manifest.cold.5
.LBB21_231:
	callq	inspect_pi4_manifest.cold.188
.LBB21_232:
	callq	inspect_pi4_manifest.cold.6
.LBB21_233:
	callq	inspect_pi4_manifest.cold.187
.LBB21_234:
	callq	inspect_pi4_manifest.cold.7
.LBB21_235:
	callq	inspect_pi4_manifest.cold.186
.LBB21_236:
	callq	inspect_pi4_manifest.cold.185
.LBB21_237:
	callq	inspect_pi4_manifest.cold.8
.LBB21_238:
	callq	inspect_pi4_manifest.cold.184
.LBB21_239:
	callq	inspect_pi4_manifest.cold.183
.LBB21_240:
	callq	inspect_pi4_manifest.cold.9
.LBB21_241:
	callq	inspect_pi4_manifest.cold.182
.LBB21_242:
	callq	inspect_pi4_manifest.cold.181
.LBB21_243:
	callq	inspect_pi4_manifest.cold.10
.LBB21_244:
	callq	inspect_pi4_manifest.cold.180
.LBB21_245:
	callq	inspect_pi4_manifest.cold.179
.LBB21_246:
	callq	inspect_pi4_manifest.cold.11
.LBB21_247:
	callq	inspect_pi4_manifest.cold.178
.LBB21_248:
	callq	inspect_pi4_manifest.cold.177
.LBB21_249:
	callq	inspect_pi4_manifest.cold.12
.LBB21_250:
	callq	inspect_pi4_manifest.cold.176
.LBB21_251:
	callq	inspect_pi4_manifest.cold.175
.LBB21_252:
	callq	inspect_pi4_manifest.cold.13
.LBB21_253:
	callq	inspect_pi4_manifest.cold.174
.LBB21_254:
	callq	inspect_pi4_manifest.cold.173
.LBB21_255:
	callq	inspect_pi4_manifest.cold.14
.LBB21_256:
	callq	inspect_pi4_manifest.cold.172
.LBB21_257:
	callq	inspect_pi4_manifest.cold.171
.LBB21_258:
	callq	inspect_pi4_manifest.cold.15
.LBB21_259:
	callq	inspect_pi4_manifest.cold.170
.LBB21_260:
	callq	inspect_pi4_manifest.cold.169
.LBB21_261:
	callq	inspect_pi4_manifest.cold.16
.LBB21_262:
	callq	inspect_pi4_manifest.cold.168
.LBB21_263:
	callq	inspect_pi4_manifest.cold.167
.LBB21_264:
	callq	inspect_pi4_manifest.cold.17
.LBB21_265:
	callq	inspect_pi4_manifest.cold.166
.LBB21_266:
	callq	inspect_pi4_manifest.cold.165
.LBB21_267:
	callq	inspect_pi4_manifest.cold.164
.LBB21_313:
	callq	inspect_pi4_manifest.cold.163
.LBB21_314:
	callq	inspect_pi4_manifest.cold.162
.LBB21_315:
	callq	inspect_pi4_manifest.cold.161
.LBB21_316:
	callq	inspect_pi4_manifest.cold.64
.LBB21_317:
	callq	inspect_pi4_manifest.cold.160
.LBB21_318:
	callq	inspect_pi4_manifest.cold.65
.LBB21_319:
	callq	inspect_pi4_manifest.cold.159
.LBB21_320:
	callq	inspect_pi4_manifest.cold.66
.LBB21_321:
	callq	inspect_pi4_manifest.cold.158
.LBB21_322:
	callq	inspect_pi4_manifest.cold.157
.LBB21_323:
	callq	inspect_pi4_manifest.cold.156
.LBB21_324:
	callq	inspect_pi4_manifest.cold.70
.LBB21_325:
	callq	inspect_pi4_manifest.cold.155
.LBB21_326:
	callq	inspect_pi4_manifest.cold.71
.LBB21_327:
	callq	inspect_pi4_manifest.cold.154
.LBB21_328:
	callq	inspect_pi4_manifest.cold.153
.LBB21_329:
	callq	inspect_pi4_manifest.cold.152
.LBB21_330:
	callq	inspect_pi4_manifest.cold.151
.LBB21_331:
	callq	inspect_pi4_manifest.cold.150
.LBB21_332:
	callq	inspect_pi4_manifest.cold.149
.LBB21_333:
	callq	inspect_pi4_manifest.cold.148
.LBB21_334:
	callq	inspect_pi4_manifest.cold.147
.LBB21_335:
	callq	inspect_pi4_manifest.cold.146
.LBB21_336:
	callq	inspect_pi4_manifest.cold.72
.LBB21_337:
	callq	inspect_pi4_manifest.cold.145
.LBB21_338:
	callq	inspect_pi4_manifest.cold.73
.LBB21_339:
	callq	inspect_pi4_manifest.cold.144
.LBB21_340:
	callq	inspect_pi4_manifest.cold.74
.LBB21_341:
	callq	inspect_pi4_manifest.cold.143
.LBB21_342:
	callq	inspect_pi4_manifest.cold.75
.LBB21_343:
	callq	inspect_pi4_manifest.cold.142
.LBB21_344:
	callq	inspect_pi4_manifest.cold.141
.LBB21_345:
	callq	inspect_pi4_manifest.cold.140
.LBB21_346:
	callq	inspect_pi4_manifest.cold.101
.LBB21_347:
	callq	inspect_pi4_manifest.cold.139
.LBB21_348:
	callq	inspect_pi4_manifest.cold.102
.LBB21_155:
	callq	inspect_pi4_manifest.cold.138
.LBB21_122:
	callq	inspect_pi4_manifest.cold.67
.LBB21_404:
	callq	inspect_pi4_manifest.cold.118
.LBB21_388:
	callq	inspect_pi4_manifest.cold.137
.LBB21_389:
	callq	inspect_pi4_manifest.cold.119
.LBB21_390:
	callq	inspect_pi4_manifest.cold.136
.LBB21_391:
	callq	inspect_pi4_manifest.cold.120
.LBB21_392:
	callq	inspect_pi4_manifest.cold.135
.LBB21_393:
	callq	inspect_pi4_manifest.cold.121
.LBB21_394:
	callq	inspect_pi4_manifest.cold.134
.LBB21_395:
	callq	inspect_pi4_manifest.cold.122
.LBB21_396:
	callq	inspect_pi4_manifest.cold.133
.LBB21_397:
	callq	inspect_pi4_manifest.cold.132
.LBB21_398:
	callq	inspect_pi4_manifest.cold.131
.LBB21_399:
	callq	inspect_pi4_manifest.cold.130
.LBB21_400:
	callq	inspect_pi4_manifest.cold.129
.LBB21_401:
	callq	inspect_pi4_manifest.cold.128
.LBB21_402:
	callq	inspect_pi4_manifest.cold.127
.LBB21_403:
	callq	inspect_pi4_manifest.cold.126
.LBB21_406:
	callq	inspect_pi4_manifest.cold.124
.LBB21_407:
	callq	inspect_pi4_manifest.cold.125
.LBB21_69:
	callq	inspect_pi4_manifest.cold.69
.LBB21_373:
	callq	inspect_pi4_manifest.cold.117
.LBB21_374:
	callq	inspect_pi4_manifest.cold.103
.LBB21_375:
	callq	inspect_pi4_manifest.cold.116
.LBB21_376:
	callq	inspect_pi4_manifest.cold.104
.LBB21_377:
	callq	inspect_pi4_manifest.cold.115
.LBB21_378:
	callq	inspect_pi4_manifest.cold.105
.LBB21_379:
	callq	inspect_pi4_manifest.cold.114
.LBB21_380:
	callq	inspect_pi4_manifest.cold.106
.LBB21_381:
	callq	inspect_pi4_manifest.cold.113
.LBB21_382:
	callq	inspect_pi4_manifest.cold.112
.LBB21_383:
	callq	inspect_pi4_manifest.cold.111
.LBB21_384:
	callq	inspect_pi4_manifest.cold.110
.LBB21_385:
	callq	inspect_pi4_manifest.cold.109
.LBB21_386:
	callq	inspect_pi4_manifest.cold.108
.LBB21_387:
	callq	inspect_pi4_manifest.cold.107
.Lfunc_end21:
	.size	inspect_pi4_manifest, .Lfunc_end21-inspect_pi4_manifest
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_find_path
	.type	inspect_find_path,@function
inspect_find_path:                      # @inspect_find_path
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$120, %rsp
	movq	(%rdi), %rax
	leaq	1311232(%rax), %rbp
	addq	$1325568, %rax                  # imm = 0x143A00
	movl	$16352, %r15d                   # imm = 0x3FE0
	movq	%rsi, %r14
	jmp	.LBB22_1
	.p2align	4
.LBB22_40:                              #   in Loop: Header=BB22_1 Depth=1
	incq	%r14
.LBB22_1:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB22_6 Depth 2
                                        #     Child Loop BB22_24 Depth 2
                                        #     Child Loop BB22_33 Depth 2
	movzbl	(%r14), %ecx
	cmpl	$47, %ecx
	je	.LBB22_40
# %bb.2:                                #   in Loop: Header=BB22_1 Depth=1
	cmpl	$92, %ecx
	je	.LBB22_40
# %bb.3:                                #   in Loop: Header=BB22_1 Depth=1
	testl	%ecx, %ecx
	je	.LBB22_30
# %bb.4:                                #   in Loop: Header=BB22_1 Depth=1
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	movq	%rsi, 8(%rsp)                   # 8-byte Spill
	movq	%rdx, 16(%rsp)                  # 8-byte Spill
	xorl	%eax, %eax
	testb	%cl, %cl
	je	.LBB22_22
.LBB22_6:                               #   Parent Loop BB22_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	%cl, %edx
	cmpl	$47, %edx
	je	.LBB22_22
# %bb.7:                                #   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %edx
	je	.LBB22_22
# %bb.8:                                #   in Loop: Header=BB22_6 Depth=2
	movb	%cl, 32(%rsp,%rax)
	movzbl	1(%r14,%rax), %ecx
	testl	%ecx, %ecx
	je	.LBB22_21
# %bb.9:                                #   in Loop: Header=BB22_6 Depth=2
	cmpl	$47, %ecx
	je	.LBB22_21
# %bb.10:                               #   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %ecx
	je	.LBB22_21
# %bb.11:                               #   in Loop: Header=BB22_6 Depth=2
	movb	%cl, 33(%rsp,%rax)
	movzbl	2(%r14,%rax), %ecx
	testl	%ecx, %ecx
	je	.LBB22_20
# %bb.12:                               #   in Loop: Header=BB22_6 Depth=2
	cmpl	$47, %ecx
	je	.LBB22_20
# %bb.13:                               #   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %ecx
	je	.LBB22_20
# %bb.14:                               #   in Loop: Header=BB22_6 Depth=2
	movb	%cl, 34(%rsp,%rax)
	movzbl	3(%r14,%rax), %ecx
	testl	%ecx, %ecx
	je	.LBB22_19
# %bb.15:                               #   in Loop: Header=BB22_6 Depth=2
	cmpl	$47, %ecx
	je	.LBB22_19
# %bb.16:                               #   in Loop: Header=BB22_6 Depth=2
	cmpl	$92, %ecx
	je	.LBB22_19
# %bb.17:                               #   in Loop: Header=BB22_6 Depth=2
	cmpq	$60, %rax
	je	.LBB22_41
# %bb.18:                               #   in Loop: Header=BB22_6 Depth=2
	movb	%cl, 35(%rsp,%rax)
	movzbl	4(%r14,%rax), %ecx
	addq	$4, %rax
	testb	%cl, %cl
	jne	.LBB22_6
.LBB22_22:                              #   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	jmp	.LBB22_23
.LBB22_21:                              #   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	incq	%r14
	incq	%rax
	jmp	.LBB22_23
.LBB22_20:                              #   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	addq	$2, %r14
	addq	$2, %rax
	jmp	.LBB22_23
.LBB22_19:                              #   in Loop: Header=BB22_1 Depth=1
	addq	%rax, %r14
	addq	$3, %r14
	addq	$3, %rax
.LBB22_23:                              #   in Loop: Header=BB22_1 Depth=1
	movb	$0, 32(%rsp,%rax)
	movl	$1, %r12d
	xorl	%r13d, %r13d
	jmp	.LBB22_24
	.p2align	4
.LBB22_29:                              #   in Loop: Header=BB22_24 Depth=2
	movl	%r12d, %r13d
	shlq	$5, %r13
	incl	%r12d
	cmpq	%r15, %r13
	ja	.LBB22_30
.LBB22_24:                              #   Parent Loop BB22_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	(%rbp,%r13), %eax
	cmpl	$46, %eax
	je	.LBB22_29
# %bb.25:                               #   in Loop: Header=BB22_24 Depth=2
	cmpl	$229, %eax
	je	.LBB22_29
# %bb.26:                               #   in Loop: Header=BB22_24 Depth=2
	testl	%eax, %eax
	je	.LBB22_31
# %bb.27:                               #   in Loop: Header=BB22_24 Depth=2
	addq	%rbp, %r13
	cmpb	$15, 11(%r13)
	je	.LBB22_29
# %bb.28:                               #   in Loop: Header=BB22_24 Depth=2
	movq	%r13, %rdi
	leaq	107(%rsp), %rbx
	movq	%rbx, %rsi
	callq	format_fat_name
	movq	%rbx, %rdi
	leaq	32(%rsp), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB22_29
# %bb.32:                               #   in Loop: Header=BB22_1 Depth=1
	movzbl	11(%r13), %eax
	movzwl	26(%r13), %ebp
	movl	28(%r13), %ecx
	movq	%r14, %rdx
	jmp	.LBB22_33
	.p2align	4
.LBB22_42:                              #   in Loop: Header=BB22_33 Depth=2
	incq	%rdx
.LBB22_33:                              #   Parent Loop BB22_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	(%rdx), %esi
	cmpl	$47, %esi
	je	.LBB22_42
# %bb.34:                               #   in Loop: Header=BB22_33 Depth=2
	cmpl	$92, %esi
	je	.LBB22_42
# %bb.35:                               #   in Loop: Header=BB22_1 Depth=1
	testl	%esi, %esi
	je	.LBB22_36
# %bb.37:                               #   in Loop: Header=BB22_1 Depth=1
	testb	$16, %al
	je	.LBB22_30
# %bb.38:                               #   in Loop: Header=BB22_1 Depth=1
	movl	%ebp, %eax
	addl	$1295, %eax                     # imm = 0x50F
	movzwl	%ax, %eax
	cmpl	$1296, %eax                     # imm = 0x510
	jbe	.LBB22_43
# %bb.39:                               #   in Loop: Header=BB22_1 Depth=1
	shll	$10, %ebp
	movq	24(%rsp), %rax                  # 8-byte Reload
	addq	%rax, %rbp
	movl	$992, %r15d                     # imm = 0x3E0
	movq	16(%rsp), %rdx                  # 8-byte Reload
	movq	8(%rsp), %rsi                   # 8-byte Reload
	jmp	.LBB22_1
.LBB22_30:
	xorl	%eax, %eax
.LBB22_31:
	addq	$120, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB22_36:
	movq	16(%rsp), %rdx                  # 8-byte Reload
	movl	$1, (%rdx)
	movb	%al, 4(%rdx)
	movw	$0, 5(%rdx)
	movb	$0, 7(%rdx)
	movl	%ebp, 8(%rdx)
	movl	%ecx, 12(%rdx)
	movl	$1, %eax
	jmp	.LBB22_31
.LBB22_41:
	callq	inspect_find_path.cold.1
.LBB22_43:
	leaq	.L.str.152(%rip), %rsi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	die_path
.Lfunc_end22:
	.size	inspect_find_path, .Lfunc_end22-inspect_find_path
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_read_file_blob
	.type	inspect_read_file_blob,@function
inspect_read_file_blob:                 # @inspect_read_file_blob
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
	movq	%rdx, (%rsp)                    # 8-byte Spill
	movq	%rsi, %r13
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	movl	12(%rsi), %r14d
	leaq	1(%r14), %rdi
	movl	$1, %esi
	callq	calloc@PLT
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	testq	%rax, %rax
	je	.LBB23_11
# %bb.1:
	testq	%r14, %r14
	je	.LBB23_10
# %bb.2:
	testb	$16, 4(%r13)
	jne	.LBB23_12
# %bb.3:
	movl	8(%r13), %ebp
	leal	-64241(%rbp), %eax
	cmpl	$-64239, %eax                   # imm = 0xFFFF0511
	jb	.LBB23_13
# %bb.4:
	movl	$64241, %ebx                    # imm = 0xFAF1
	xorl	%r15d, %r15d
	.p2align	4
.LBB23_5:                               # =>This Inner Loop Header: Depth=1
	leal	-64241(%rbp), %eax
	cmpl	$-64239, %eax                   # imm = 0xFFFF0511
	jb	.LBB23_14
# %bb.6:                                #   in Loop: Header=BB23_5 Depth=1
	decl	%ebx
	je	.LBB23_14
# %bb.7:                                #   in Loop: Header=BB23_5 Depth=1
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	(%rax), %r12
	movq	%r14, %r13
	subq	%r15, %r13
	cmpq	$1024, %r13                     # imm = 0x400
	movl	$1024, %eax                     # imm = 0x400
	cmovaeq	%rax, %r13
	movq	8(%rsp), %rax                   # 8-byte Reload
	leaq	(%rax,%r15), %rdi
	movl	%ebp, %eax
	shll	$10, %eax
	leaq	(%r12,%rax), %rsi
	addq	$1325568, %rsi                  # imm = 0x143A00
	movq	%r13, %rdx
	callq	memcpy@PLT
	addq	%r13, %r15
	cmpq	%r14, %r15
	jae	.LBB23_10
# %bb.8:                                #   in Loop: Header=BB23_5 Depth=1
	movl	%ebp, %eax
	movzwl	1049088(%r12,%rax,2), %ebp
	cmpl	$65528, %ebp                    # imm = 0xFFF8
	jb	.LBB23_5
# %bb.9:
	leaq	.L.str.75(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.LBB23_10:
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%r14, %rdx
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB23_14:
	leaq	.L.str.74(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.LBB23_11:
	callq	inspect_read_file_blob.cold.1
.LBB23_12:
	leaq	.L.str.241(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.LBB23_13:
	leaq	.L.str.73(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.Lfunc_end23:
	.size	inspect_read_file_blob, .Lfunc_end23-inspect_read_file_blob
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_file
	.type	inspect_manifest_require_file,@function
inspect_manifest_require_file:          # @inspect_manifest_require_file
# %bb.0:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$16, %rsp
	movq	%r8, %r14
	movq	%rcx, %r15
	movq	%rdx, %rbx
	movq	%rsi, %r12
	movq	%rsp, %rdx
	movq	%rbx, %rsi
	callq	inspect_find_path
	testl	%eax, %eax
	je	.LBB24_6
# %bb.1:
	testb	$16, 4(%rsp)
	jne	.LBB24_7
# %bb.2:
	movl	12(%rsp), %r13d
	testq	%r13, %r13
	je	.LBB24_8
# %bb.3:
	testq	%r15, %r15
	je	.LBB24_5
# %bb.4:
	movq	%r12, %rdi
	movq	%r15, %rsi
	callq	manifest_require_u64
	cmpq	%r13, %rax
	jne	.LBB24_9
.LBB24_5:
	movl	8(%rsp), %ecx
	leaq	.L.str.252(%rip), %rdi
	movq	%rbx, %rsi
	movl	%r13d, %edx
	xorl	%eax, %eax
	callq	printf@PLT
	incq	(%r14)
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	retq
.LBB24_6:
	leaq	.L.str.249(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB24_7:
	leaq	.L.str.250(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB24_8:
	leaq	.L.str.251(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB24_9:
	callq	inspect_manifest_require_file.cold.1
.Lfunc_end24:
	.size	inspect_manifest_require_file, .Lfunc_end24-inspect_manifest_require_file
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog
	.type	load_pi4_app_catalog,@function
load_pi4_app_catalog:                   # @load_pi4_app_catalog
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$232, %rsp
	movl	%edx, 44(%rsp)                  # 4-byte Spill
	movq	%rsi, %r14
	movq	%rdi, %rbp
	leaq	PI4_APP_INDEX_PATH(%rip), %rsi
	leaq	80(%rsp), %rdx
	callq	inspect_find_path
	testl	%eax, %eax
	je	.LBB25_42
# %bb.1:
	testb	$16, 84(%rsp)
	jne	.LBB25_43
# %bb.2:
	cmpl	$0, 92(%rsp)
	je	.LBB25_44
# %bb.3:
	leaq	PI4_APP_INDEX_PATH(%rip), %rbx
	leaq	80(%rsp), %rsi
	movq	%rbp, %rdi
	movq	%rbx, %rdx
	callq	inspect_read_file_blob
	movq	%rax, 64(%rsp)                  # 8-byte Spill
	movq	%rax, 48(%rsp)
	movq	%rdx, 56(%rsp)
	leaq	.L.str.255(%rip), %rdx
	leaq	48(%rsp), %r15
	movq	%r15, %rdi
	movq	%rbx, %rsi
	callq	text_manifest_require_value
	movq	$0, 160(%rsp)
	leaq	.L.str.256(%rip), %rsi
	leaq	96(%rsp), %rdx
	movl	$32, %ecx
	movq	%r15, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_45
# %bb.4:
	cmpb	$0, 96(%rsp)
	je	.LBB25_46
# %bb.5:
	callq	__errno_location@PLT
	movl	$0, (%rax)
	leaq	96(%rsp), %rdi
	leaq	160(%rsp), %rsi
	movl	$10, %edx
	callq	strtoull@PLT
	movq	%rax, %r13
	callq	__errno_location@PLT
	cmpl	$0, (%rax)
	jne	.LBB25_47
# %bb.6:
	movq	160(%rsp), %rax
	testq	%rax, %rax
	je	.LBB25_47
# %bb.7:
	cmpb	$0, (%rax)
	jne	.LBB25_47
# %bb.8:
	leaq	-17(%r13), %rax
	cmpq	$-17, %rax
	jbe	.LBB25_48
# %bb.9:
	leaq	8(%r14), %rdi
	movl	$15168, %edx                    # imm = 0x3B40
	xorl	%esi, %esi
	callq	memset@PLT
	movq	%r13, (%r14)
	leaq	.L.str.276(%rip), %rbx
	leaq	.L.str.258(%rip), %r12
	leaq	96(%rsp), %r15
	xorl	%r8d, %r8d
	jmp	.LBB25_10
	.p2align	4
.LBB25_39:                              #   in Loop: Header=BB25_10 Depth=1
	cmpl	$0, 44(%rsp)                    # 4-byte Folded Reload
	movq	16(%rsp), %r8                   # 8-byte Reload
	jne	.LBB25_73
.LBB25_40:                              #   in Loop: Header=BB25_10 Depth=1
	incq	%r8
	addq	$948, %r14                      # imm = 0x3B4
	cmpq	%r8, %r13
	leaq	96(%rsp), %r15
	je	.LBB25_41
.LBB25_10:                              # =>This Inner Loop Header: Depth=1
	movl	$64, %esi
	movq	%r15, %rdi
	movq	%rbx, %rdx
	movq	%r12, %rcx
	movq	%r8, 16(%rsp)                   # 8-byte Spill
	leaq	.L.str.259(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB25_49
# %bb.11:                               #   in Loop: Header=BB25_10 Depth=1
	movl	$64, %ecx
	leaq	48(%rsp), %rdi
	movq	%r15, %rsi
	leaq	160(%rsp), %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_50
# %bb.12:                               #   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, 160(%rsp)
	movq	16(%rsp), %r8                   # 8-byte Reload
	je	.LBB25_51
# %bb.13:                               #   in Loop: Header=BB25_10 Depth=1
	movl	$64, %esi
	movq	%r15, %rdi
	movq	%rbx, %rdx
	movq	%r12, %rcx
	leaq	.L.str.260(%rip), %r9
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB25_52
# %bb.14:                               #   in Loop: Header=BB25_10 Depth=1
	leaq	168(%r14), %r12
	movl	$160, %ecx
	leaq	48(%rsp), %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_53
# %bb.15:                               #   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%r12)
	je	.LBB25_54
# %bb.16:                               #   in Loop: Header=BB25_10 Depth=1
	leaq	904(%r14), %r15
	movq	%rbp, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	callq	inspect_find_path
	testl	%eax, %eax
	je	.LBB25_55
# %bb.17:                               #   in Loop: Header=BB25_10 Depth=1
	testb	$16, 908(%r14)
	jne	.LBB25_56
# %bb.18:                               #   in Loop: Header=BB25_10 Depth=1
	cmpl	$0, 916(%r14)
	je	.LBB25_57
# %bb.19:                               #   in Loop: Header=BB25_10 Depth=1
	leaq	8(%r14), %rbx
	movq	%rbp, %rdi
	movq	%r15, %rsi
	movq	%r12, %rdx
	callq	inspect_read_file_blob
	movq	%rax, 72(%rsp)                  # 8-byte Spill
	movq	%rax, 24(%rsp)
	movq	%rdx, 32(%rsp)
	leaq	24(%rsp), %r15
	movq	%r15, %rdi
	movq	%r12, %rsi
	leaq	.L.str.261(%rip), %rdx
	callq	text_manifest_require_value
	movl	$64, %ecx
	movq	%r15, %rdi
	leaq	.L.str.259(%rip), %rsi
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_58
# %bb.20:                               #   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%rbx)
	je	.LBB25_59
# %bb.21:                               #   in Loop: Header=BB25_10 Depth=1
	leaq	160(%rsp), %rdi
	movq	%rbx, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB25_60
# %bb.22:                               #   in Loop: Header=BB25_10 Depth=1
	leaq	72(%r14), %rbx
	movl	$96, %ecx
	leaq	24(%rsp), %rdi
	leaq	.L.str.263(%rip), %rsi
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_61
# %bb.23:                               #   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%rbx)
	je	.LBB25_62
# %bb.24:                               #   in Loop: Header=BB25_10 Depth=1
	leaq	328(%r14), %rbx
	movl	$160, %ecx
	leaq	24(%rsp), %rdi
	leaq	.L.str.264(%rip), %rsi
	movq	%rbx, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_63
# %bb.25:                               #   in Loop: Header=BB25_10 Depth=1
	movq	%r12, 8(%rsp)                   # 8-byte Spill
	cmpb	$0, (%rbx)
	je	.LBB25_64
# %bb.26:                               #   in Loop: Header=BB25_10 Depth=1
	movq	%r13, %r12
	leaq	488(%r14), %r15
	movl	$160, %ecx
	leaq	24(%rsp), %rdi
	leaq	.L.str.220(%rip), %rsi
	movq	%r15, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_65
# %bb.27:                               #   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%r15)
	je	.LBB25_66
# %bb.28:                               #   in Loop: Header=BB25_10 Depth=1
	movq	%rbp, %r13
	leaq	648(%r14), %rbp
	movl	$160, %ecx
	leaq	24(%rsp), %rdi
	leaq	.L.str.265(%rip), %rsi
	movq	%rbp, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_67
# %bb.29:                               #   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%rbp)
	je	.LBB25_68
# %bb.30:                               #   in Loop: Header=BB25_10 Depth=1
	leaq	808(%r14), %rbp
	movl	$96, %ecx
	leaq	24(%rsp), %rdi
	leaq	.L.str.266(%rip), %rsi
	movq	%rbp, %rdx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB25_69
# %bb.31:                               #   in Loop: Header=BB25_10 Depth=1
	cmpb	$0, (%rbp)
	je	.LBB25_70
# %bb.32:                               #   in Loop: Header=BB25_10 Depth=1
	movq	72(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	leaq	920(%r14), %rdx
	movq	%r13, %rbp
	movq	%r13, %rdi
	movq	%rbx, %rsi
	callq	inspect_find_path
	testl	%eax, %eax
	je	.LBB25_71
# %bb.33:                               #   in Loop: Header=BB25_10 Depth=1
	testb	$16, 924(%r14)
	jne	.LBB25_72
# %bb.34:                               #   in Loop: Header=BB25_10 Depth=1
	cmpl	$0, 932(%r14)
	je	.LBB25_72
# %bb.35:                               #   in Loop: Header=BB25_10 Depth=1
	movq	%r12, %r13
	leaq	936(%r14), %rdx
	movq	%rbp, %rdi
	movq	%r15, %rsi
	callq	inspect_find_path
	movl	%eax, 952(%r14)
	testl	%eax, %eax
	leaq	.L.str.276(%rip), %rbx
	leaq	.L.str.258(%rip), %r12
	je	.LBB25_39
# %bb.36:                               #   in Loop: Header=BB25_10 Depth=1
	testb	$16, 940(%r14)
	movq	16(%rsp), %r8                   # 8-byte Reload
	jne	.LBB25_38
# %bb.37:                               #   in Loop: Header=BB25_10 Depth=1
	cmpl	$0, 948(%r14)
	jne	.LBB25_40
.LBB25_38:
	leaq	.L.str.269(%rip), %rsi
	movq	%r15, %rdi
	callq	die_path
.LBB25_41:
	movq	64(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	addq	$232, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB25_72:
	leaq	.L.str.268(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB25_65:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	load_pi4_app_catalog.cold.9
.LBB25_62:
	movq	%r12, %rdi
	callq	load_pi4_app_catalog.cold.12
.LBB25_53:
	leaq	96(%rsp), %rdi
	callq	load_pi4_app_catalog.cold.17
.LBB25_63:
	movq	%r12, %rdi
	callq	load_pi4_app_catalog.cold.11
.LBB25_59:
	movq	%r12, %rdi
	callq	load_pi4_app_catalog.cold.14
.LBB25_51:
	leaq	96(%rsp), %rdi
	callq	load_pi4_app_catalog.cold.19
.LBB25_52:
	callq	load_pi4_app_catalog.cold.18
.LBB25_57:
	leaq	.L.str.273(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB25_49:
	callq	load_pi4_app_catalog.cold.21
.LBB25_50:
	leaq	96(%rsp), %rdi
	callq	load_pi4_app_catalog.cold.20
.LBB25_54:
	leaq	96(%rsp), %rdi
	callq	load_pi4_app_catalog.cold.16
.LBB25_64:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	load_pi4_app_catalog.cold.10
.LBB25_55:
	leaq	.L.str.271(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB25_58:
	movq	%r12, %rdi
	callq	load_pi4_app_catalog.cold.15
.LBB25_61:
	movq	%r12, %rdi
	callq	load_pi4_app_catalog.cold.13
.LBB25_60:
	movq	%r12, %rdi
	callq	load_pi4_app_catalog.cold.3
.LBB25_56:
	leaq	.L.str.272(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB25_70:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	load_pi4_app_catalog.cold.4
.LBB25_71:
	leaq	.L.str.267(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB25_66:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	load_pi4_app_catalog.cold.8
.LBB25_67:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	load_pi4_app_catalog.cold.7
.LBB25_68:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	load_pi4_app_catalog.cold.6
.LBB25_69:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	load_pi4_app_catalog.cold.5
.LBB25_73:
	leaq	.L.str.270(%rip), %rsi
	movq	%r15, %rdi
	callq	die_path
.LBB25_47:
	callq	load_pi4_app_catalog.cold.2
.LBB25_42:
	callq	load_pi4_app_catalog.cold.26
.LBB25_43:
	callq	load_pi4_app_catalog.cold.1
.LBB25_44:
	callq	load_pi4_app_catalog.cold.25
.LBB25_45:
	callq	load_pi4_app_catalog.cold.24
.LBB25_46:
	callq	load_pi4_app_catalog.cold.23
.LBB25_48:
	callq	load_pi4_app_catalog.cold.22
.Lfunc_end25:
	.size	load_pi4_app_catalog, .Lfunc_end25-load_pi4_app_catalog
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_indexed_sized_file
	.type	inspect_manifest_require_indexed_sized_file,@function
inspect_manifest_require_indexed_sized_file: # @inspect_manifest_require_indexed_sized_file
# %bb.0:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$416, %rsp                      # imm = 0x1A0
	movq	%r8, %r14
	movq	%rcx, %r12
	movq	%rdx, %r13
	movq	%rsi, %rbx
	movq	%rdi, %r15
	leaq	.L.str.294(%rip), %rdx
	leaq	64(%rsp), %rdi
	movl	$64, %esi
	movq	%r13, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB26_6
# %bb.1:
	leaq	.L.str.296(%rip), %rdx
	movq	%rsp, %rdi
	movl	$64, %esi
	movq	%r13, %rcx
	movq	%r12, %r8
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpl	$64, %eax
	jae	.LBB26_7
# %bb.2:
	leaq	64(%rsp), %rsi
	leaq	288(%rsp), %rdx
	movl	$128, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB26_8
# %bb.3:
	leaq	288(%rsp), %rdx
	movq	%rsp, %rcx
	movq	%r15, %rdi
	movq	%rbx, %rsi
	movq	%r14, %r8
	callq	inspect_manifest_require_file
	leaq	64(%rsp), %rsi
	leaq	128(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB26_9
# %bb.4:
	leaq	.L.str.248(%rip), %rdi
	leaq	64(%rsp), %rsi
	leaq	128(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	movq	%rsp, %rsi
	leaq	128(%rsp), %rdx
	movl	$160, %ecx
	movq	%rbx, %rdi
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB26_10
# %bb.5:
	leaq	.L.str.248(%rip), %rdi
	movq	%rsp, %rsi
	leaq	128(%rsp), %rdx
	xorl	%eax, %eax
	callq	printf@PLT
	addq	$416, %rsp                      # imm = 0x1A0
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	retq
.LBB26_6:
	callq	inspect_manifest_require_indexed_sized_file.cold.5
.LBB26_7:
	callq	inspect_manifest_require_indexed_sized_file.cold.4
.LBB26_8:
	callq	inspect_manifest_require_indexed_sized_file.cold.3
.LBB26_9:
	callq	inspect_manifest_require_indexed_sized_file.cold.2
.LBB26_10:
	callq	inspect_manifest_require_indexed_sized_file.cold.1
.Lfunc_end26:
	.size	inspect_manifest_require_indexed_sized_file, .Lfunc_end26-inspect_manifest_require_indexed_sized_file
                                        # -- End function
	.p2align	4                               # -- Begin function manifest_get_value
	.type	manifest_get_value,@function
manifest_get_value:                     # @manifest_get_value
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movq	%rcx, %r15
	movq	%rdx, %rbx
	movq	%rdi, %r13
	movq	(%rdi), %rbp
	movq	%rsi, 32(%rsp)                  # 8-byte Spill
	movq	%rsi, %rdi
	callq	strlen@PLT
	movq	8(%r13), %r14
	testq	%r14, %r14
	je	.LBB27_18
# %bb.1:
	movq	%rax, %rcx
	movq	%r15, 16(%rsp)                  # 8-byte Spill
	movq	%rbx, 8(%rsp)                   # 8-byte Spill
	xorl	%ebx, %ebx
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	jmp	.LBB27_2
	.p2align	4
.LBB27_17:                              #   in Loop: Header=BB27_2 Depth=1
	cmpq	%r14, %rbx
	jae	.LBB27_18
.LBB27_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB27_3 Depth 2
                                        #     Child Loop BB27_8 Depth 2
	movq	%rbx, %r15
	incq	%rbx
	cmpq	%rbx, %r14
	cmovaq	%r14, %rbx
	movq	%r15, %r13
	.p2align	4
.LBB27_3:                               #   Parent Loop BB27_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	(%rbp,%r13), %eax
	cmpl	$10, %eax
	je	.LBB27_7
# %bb.4:                                #   in Loop: Header=BB27_3 Depth=2
	cmpl	$13, %eax
	je	.LBB27_7
# %bb.5:                                #   in Loop: Header=BB27_3 Depth=2
	incq	%r13
	cmpq	%r14, %r13
	jb	.LBB27_3
# %bb.6:                                #   in Loop: Header=BB27_2 Depth=1
	movq	%rbx, %r13
	jmp	.LBB27_12
	.p2align	4
.LBB27_7:                               #   in Loop: Header=BB27_2 Depth=1
	movq	%r13, %rbx
	cmpq	%r14, %r13
	jb	.LBB27_8
	jmp	.LBB27_12
	.p2align	4
.LBB27_10:                              #   in Loop: Header=BB27_8 Depth=2
	incq	%rbx
	cmpq	%rbx, %r14
	je	.LBB27_11
.LBB27_8:                               #   Parent Loop BB27_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	(%rbp,%rbx), %eax
	cmpl	$13, %eax
	je	.LBB27_10
# %bb.9:                                #   in Loop: Header=BB27_8 Depth=2
	cmpl	$10, %eax
	je	.LBB27_10
	jmp	.LBB27_12
	.p2align	4
.LBB27_11:                              #   in Loop: Header=BB27_2 Depth=1
	movq	%r14, %rbx
.LBB27_12:                              #   in Loop: Header=BB27_2 Depth=1
	leaq	(%r15,%rcx), %r12
	subq	%r12, %r13
	jbe	.LBB27_17
# %bb.13:                               #   in Loop: Header=BB27_2 Depth=1
	addq	%rbp, %r15
	movq	%r15, %rdi
	movq	32(%rsp), %rsi                  # 8-byte Reload
	movq	%rcx, %rdx
	callq	bcmp@PLT
	movq	24(%rsp), %rcx                  # 8-byte Reload
	testl	%eax, %eax
	jne	.LBB27_17
# %bb.14:                               #   in Loop: Header=BB27_2 Depth=1
	cmpb	$61, (%rbp,%r12)
	jne	.LBB27_17
# %bb.15:
	cmpq	16(%rsp), %r13                  # 8-byte Folded Reload
	ja	.LBB27_20
# %bb.16:
	leaq	-1(%r13), %rdx
	leaq	(%r15,%rcx), %rsi
	incq	%rsi
	movq	8(%rsp), %rbx                   # 8-byte Reload
	movq	%rbx, %rdi
	callq	memcpy@PLT
	movb	$0, -1(%rbx,%r13)
	movl	$1, %eax
	jmp	.LBB27_19
.LBB27_18:
	xorl	%eax, %eax
.LBB27_19:
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB27_20:
	callq	manifest_get_value.cold.1
.Lfunc_end27:
	.size	manifest_get_value, .Lfunc_end27-manifest_get_value
                                        # -- End function
	.p2align	4                               # -- Begin function manifest_require_u64
	.type	manifest_require_u64,@function
manifest_require_u64:                   # @manifest_require_u64
# %bb.0:
	pushq	%rbx
	subq	$80, %rsp
	movq	$0, 8(%rsp)
	leaq	16(%rsp), %rdx
	movl	$64, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB28_5
# %bb.1:
	callq	__errno_location@PLT
	movl	$0, (%rax)
	leaq	16(%rsp), %rdi
	leaq	8(%rsp), %rsi
	movl	$10, %edx
	callq	strtoull@PLT
	movq	%rax, %rbx
	callq	__errno_location@PLT
	cmpl	$0, (%rax)
	jne	.LBB28_6
# %bb.2:
	movq	8(%rsp), %rax
	testq	%rax, %rax
	je	.LBB28_6
# %bb.3:
	cmpb	$0, (%rax)
	jne	.LBB28_6
# %bb.4:
	movq	%rbx, %rax
	addq	$80, %rsp
	popq	%rbx
	retq
.LBB28_6:
	callq	manifest_require_u64.cold.1
.LBB28_5:
	callq	manifest_require_u64.cold.2
.Lfunc_end28:
	.size	manifest_require_u64, .Lfunc_end28-manifest_require_u64
                                        # -- End function
	.p2align	4                               # -- Begin function text_manifest_require_value
	.type	text_manifest_require_value,@function
text_manifest_require_value:            # @text_manifest_require_value
# %bb.0:
	pushq	%r14
	pushq	%rbx
	subq	$168, %rsp
	movq	%rdx, %r14
	movq	%rsi, %rbx
	leaq	.L.str.155(%rip), %rsi
	movq	%rsp, %rdx
	movl	$160, %ecx
	callq	manifest_get_value
	testl	%eax, %eax
	je	.LBB29_4
# %bb.1:
	cmpb	$0, (%rsp)
	je	.LBB29_5
# %bb.2:
	movq	%rsp, %rdi
	movq	%r14, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB29_6
# %bb.3:
	addq	$168, %rsp
	popq	%rbx
	popq	%r14
	retq
.LBB29_4:
	movq	%rbx, %rdi
	callq	text_manifest_require_value.cold.3
.LBB29_5:
	movq	%rbx, %rdi
	callq	text_manifest_require_value.cold.2
.LBB29_6:
	movq	%rbx, %rdi
	callq	text_manifest_require_value.cold.1
.Lfunc_end29:
	.size	text_manifest_require_value, .Lfunc_end29-text_manifest_require_value
                                        # -- End function
	.p2align	4                               # -- Begin function reject_repo_local_external_asset
	.type	reject_repo_local_external_asset,@function
reject_repo_local_external_asset:       # @reject_repo_local_external_asset
# %bb.0:
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	subq	$8200, %rsp                     # imm = 0x2008
	movq	%rsi, %r14
	movq	%rdi, %rbx
	leaq	.L.str.120(%rip), %rdi
	leaq	4096(%rsp), %rsi
	callq	realpath@PLT
	testq	%rax, %rax
	je	.LBB30_6
# %bb.1:
	movq	%rsp, %rsi
	movq	%rbx, %rdi
	callq	realpath@PLT
	testq	%rax, %rax
	je	.LBB30_7
# %bb.2:
	leaq	4096(%rsp), %r12
	movq	%r12, %rdi
	callq	strlen@PLT
	movq	%rax, %r15
	movq	%rsp, %rdi
	movq	%r12, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB30_8
# %bb.3:
	movq	%rsp, %rdi
	leaq	4096(%rsp), %rsi
	movq	%r15, %rdx
	callq	strncmp@PLT
	testl	%eax, %eax
	jne	.LBB30_5
# %bb.4:
	cmpb	$47, (%rsp,%r15)
	je	.LBB30_8
.LBB30_5:
	addq	$8200, %rsp                     # imm = 0x2008
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	retq
.LBB30_8:
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	reject_repo_local_external_asset.cold.1
.LBB30_6:
	callq	reject_repo_local_external_asset.cold.3
.LBB30_7:
	movq	%rbx, %rdi
	callq	reject_repo_local_external_asset.cold.2
.Lfunc_end30:
	.size	reject_repo_local_external_asset, .Lfunc_end30-reject_repo_local_external_asset
                                        # -- End function
	.p2align	4                               # -- Begin function proof_manifest_require_root_file
	.type	proof_manifest_require_root_file,@function
proof_manifest_require_root_file:       # @proof_manifest_require_root_file
# %bb.0:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	movq	%rcx, %rbx
	movq	56(%rdi), %r13
	testq	%r13, %r13
	je	.LBB31_13
# %bb.1:
	movq	%rdx, %r14
	movq	%rsi, %r15
	movq	48(%rdi), %r12
	.p2align	4
.LBB31_3:                               # =>This Inner Loop Header: Depth=1
	movq	%r12, %rdi
	movq	%rbx, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB31_4
# %bb.2:                                #   in Loop: Header=BB31_3 Depth=1
	addq	$104, %r12
	decq	%r13
	jne	.LBB31_3
.LBB31_13:
	movq	%rbx, %rdi
	callq	proof_manifest_require_root_file.cold.3
.LBB31_4:
	movl	$1311232, %eax                  # imm = 0x140200
	addq	(%r15), %rax
	movq	$-28, %rcx
	jmp	.LBB31_5
	.p2align	4
.LBB31_8:                               #   in Loop: Header=BB31_5 Depth=1
	addq	$-32, %rcx
	addq	$32, %rax
	cmpq	$-16412, %rcx                   # imm = 0xBFE4
	je	.LBB31_9
.LBB31_5:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%rax), %edx
	cmpl	$229, %edx
	je	.LBB31_8
# %bb.6:                                #   in Loop: Header=BB31_5 Depth=1
	testl	%edx, %edx
	je	.LBB31_9
# %bb.7:                                #   in Loop: Header=BB31_5 Depth=1
	movq	(%rax), %rdx
	xorq	(%r14), %rdx
	movq	3(%rax), %rsi
	xorq	3(%r14), %rsi
	orq	%rdx, %rsi
	jne	.LBB31_8
# %bb.10:
	negq	%rcx
	cmpq	$16385, %rcx                    # imm = 0x4001
	jae	.LBB31_14
# %bb.11:
	cmpl	$0, 28(%rax)
	je	.LBB31_9
# %bb.12:
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	retq
.LBB31_9:
	movq	%rbx, %rdi
	callq	proof_manifest_require_root_file.cold.1
.LBB31_14:
	callq	proof_manifest_require_root_file.cold.2
.Lfunc_end31:
	.size	proof_manifest_require_root_file, .Lfunc_end31-proof_manifest_require_root_file
                                        # -- End function
	.p2align	4                               # -- Begin function text_appendf
	.type	text_appendf,@function
text_appendf:                           # @text_appendf
# %bb.0:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$216, %rsp
	movq	%rsi, %r14
	movq	%rdi, %rbx
	movq	%r9, 72(%rsp)
	testb	%al, %al
	je	.LBB32_17
# %bb.16:
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm1, 96(%rsp)
	movaps	%xmm2, 112(%rsp)
	movaps	%xmm3, 128(%rsp)
	movaps	%xmm4, 144(%rsp)
	movaps	%xmm5, 160(%rsp)
	movaps	%xmm6, 176(%rsp)
	movaps	%xmm7, 192(%rsp)
.LBB32_17:
	movq	%r8, 64(%rsp)
	movq	%rcx, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	(%rdi), %rax
	testq	%rax, %rax
	jne	.LBB32_3
# %bb.1:
	movq	$512, 16(%rbx)                  # imm = 0x200
	movl	$512, %edi                      # imm = 0x200
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB32_12
# %bb.2:
	movq	%rax, (%rbx)
.LBB32_3:
	leaq	32(%rsp), %r12
	leaq	272(%rsp), %r13
	movabsq	$206158430224, %rbp             # imm = 0x3000000010
	movq	%rsp, %r15
	.p2align	4
.LBB32_4:                               # =>This Inner Loop Header: Depth=1
	movq	16(%rbx), %rsi
	movq	%rsi, %rcx
	subq	8(%rbx), %rcx
	cmpq	$127, %rcx
	ja	.LBB32_7
# %bb.5:                                #   in Loop: Header=BB32_4 Depth=1
	addq	%rsi, %rsi
	movq	%rsi, 16(%rbx)
	movq	%rax, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB32_13
# %bb.6:                                #   in Loop: Header=BB32_4 Depth=1
	movq	%rax, (%rbx)
.LBB32_7:                               #   in Loop: Header=BB32_4 Depth=1
	movq	%r12, 16(%rsp)
	movq	%r13, 8(%rsp)
	movq	%rbp, (%rsp)
	movq	8(%rbx), %rax
	movq	16(%rbx), %rsi
	movq	(%rbx), %rdi
	addq	%rax, %rdi
	subq	%rax, %rsi
	movq	%r14, %rdx
	movq	%r15, %rcx
	callq	vsnprintf@PLT
	testl	%eax, %eax
	js	.LBB32_14
# %bb.8:                                #   in Loop: Header=BB32_4 Depth=1
	movl	%eax, %eax
	movq	8(%rbx), %rsi
	movq	16(%rbx), %rcx
	subq	%rsi, %rcx
	addq	%rax, %rsi
	cmpq	%rax, %rcx
	ja	.LBB32_11
# %bb.9:                                #   in Loop: Header=BB32_4 Depth=1
	incq	%rsi
	movq	%rsi, 16(%rbx)
	movq	(%rbx), %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB32_15
# %bb.10:                               #   in Loop: Header=BB32_4 Depth=1
	movq	%rax, (%rbx)
	jmp	.LBB32_4
.LBB32_11:
	movq	%rsi, 8(%rbx)
	addq	$216, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB32_14:
	callq	text_appendf.cold.2
.LBB32_15:
	callq	text_appendf.cold.1
.LBB32_13:
	callq	text_appendf.cold.3
.LBB32_12:
	callq	text_appendf.cold.4
.Lfunc_end32:
	.size	text_appendf, .Lfunc_end32-text_appendf
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function main.cold.1
	.type	main.cold.1,@function
main.cold.1:                            # @main.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end33:
	.size	main.cold.1, .Lfunc_end33-main.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.2
	.type	main.cold.2,@function
main.cold.2:                            # @main.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end34:
	.size	main.cold.2, .Lfunc_end34-main.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.3
	.type	main.cold.3,@function
main.cold.3:                            # @main.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.133(%rip), %rdi
	callq	die
.Lfunc_end35:
	.size	main.cold.3, .Lfunc_end35-main.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.4
	.type	main.cold.4,@function
main.cold.4:                            # @main.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.132(%rip), %rdi
	callq	die
.Lfunc_end36:
	.size	main.cold.4, .Lfunc_end36-main.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.5
	.type	main.cold.5,@function
main.cold.5:                            # @main.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end37:
	.size	main.cold.5, .Lfunc_end37-main.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.6
	.type	main.cold.6,@function
main.cold.6:                            # @main.cold.6
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end38:
	.size	main.cold.6, .Lfunc_end38-main.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.7
	.type	main.cold.7,@function
main.cold.7:                            # @main.cold.7
# %bb.0:
	pushq	%rax
	leaq	.L.str.131(%rip), %rdi
	callq	die
.Lfunc_end39:
	.size	main.cold.7, .Lfunc_end39-main.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.8
	.type	main.cold.8,@function
main.cold.8:                            # @main.cold.8
# %bb.0:
	pushq	%rax
	leaq	.L.str.23(%rip), %rdi
	callq	die
.Lfunc_end40:
	.size	main.cold.8, .Lfunc_end40-main.cold.8
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.9
	.type	main.cold.9,@function
main.cold.9:                            # @main.cold.9
# %bb.0:
	pushq	%rax
	leaq	.L.str.127(%rip), %rdi
	callq	die
.Lfunc_end41:
	.size	main.cold.9, .Lfunc_end41-main.cold.9
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.10
	.type	main.cold.10,@function
main.cold.10:                           # @main.cold.10
# %bb.0:
	pushq	%rax
	leaq	.L.str.130(%rip), %rdi
	callq	die
.Lfunc_end42:
	.size	main.cold.10, .Lfunc_end42-main.cold.10
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.11
	.type	main.cold.11,@function
main.cold.11:                           # @main.cold.11
# %bb.0:
	pushq	%rax
	leaq	.L.str.129(%rip), %rdi
	callq	die
.Lfunc_end43:
	.size	main.cold.11, .Lfunc_end43-main.cold.11
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.12
	.type	main.cold.12,@function
main.cold.12:                           # @main.cold.12
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end44:
	.size	main.cold.12, .Lfunc_end44-main.cold.12
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.13
	.type	main.cold.13,@function
main.cold.13:                           # @main.cold.13
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end45:
	.size	main.cold.13, .Lfunc_end45-main.cold.13
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.14
	.type	main.cold.14,@function
main.cold.14:                           # @main.cold.14
# %bb.0:
	pushq	%rax
	leaq	.L.str.113(%rip), %rdi
	callq	die
.Lfunc_end46:
	.size	main.cold.14, .Lfunc_end46-main.cold.14
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.15
	.type	main.cold.15,@function
main.cold.15:                           # @main.cold.15
# %bb.0:
	pushq	%rax
	leaq	.L.str.115(%rip), %rdi
	callq	die
.Lfunc_end47:
	.size	main.cold.15, .Lfunc_end47-main.cold.15
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.16
	.type	main.cold.16,@function
main.cold.16:                           # @main.cold.16
# %bb.0:
	pushq	%rax
	leaq	.L.str.21(%rip), %rdi
	callq	die
.Lfunc_end48:
	.size	main.cold.16, .Lfunc_end48-main.cold.16
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.17
	.type	main.cold.17,@function
main.cold.17:                           # @main.cold.17
# %bb.0:
	pushq	%rax
	leaq	.L.str.127(%rip), %rdi
	callq	die
.Lfunc_end49:
	.size	main.cold.17, .Lfunc_end49-main.cold.17
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.18
	.type	main.cold.18,@function
main.cold.18:                           # @main.cold.18
# %bb.0:
	pushq	%rax
	leaq	.L.str.112(%rip), %rdi
	callq	die
.Lfunc_end50:
	.size	main.cold.18, .Lfunc_end50-main.cold.18
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.19
	.type	main.cold.19,@function
main.cold.19:                           # @main.cold.19
# %bb.0:
	pushq	%rax
	leaq	.L.str.111(%rip), %rdi
	callq	die
.Lfunc_end51:
	.size	main.cold.19, .Lfunc_end51-main.cold.19
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.20
	.type	main.cold.20,@function
main.cold.20:                           # @main.cold.20
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end52:
	.size	main.cold.20, .Lfunc_end52-main.cold.20
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.21
	.type	main.cold.21,@function
main.cold.21:                           # @main.cold.21
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end53:
	.size	main.cold.21, .Lfunc_end53-main.cold.21
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.22
	.type	main.cold.22,@function
main.cold.22:                           # @main.cold.22
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end54:
	.size	main.cold.22, .Lfunc_end54-main.cold.22
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.23
	.type	main.cold.23,@function
main.cold.23:                           # @main.cold.23
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end55:
	.size	main.cold.23, .Lfunc_end55-main.cold.23
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.24
	.type	main.cold.24,@function
main.cold.24:                           # @main.cold.24
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end56:
	.size	main.cold.24, .Lfunc_end56-main.cold.24
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.25
	.type	main.cold.25,@function
main.cold.25:                           # @main.cold.25
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end57:
	.size	main.cold.25, .Lfunc_end57-main.cold.25
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.26
	.type	main.cold.26,@function
main.cold.26:                           # @main.cold.26
# %bb.0:
	pushq	%rax
	leaq	.L.str.25(%rip), %rdi
	callq	die
.Lfunc_end58:
	.size	main.cold.26, .Lfunc_end58-main.cold.26
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.27
	.type	main.cold.27,@function
main.cold.27:                           # @main.cold.27
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end59:
	.size	main.cold.27, .Lfunc_end59-main.cold.27
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.28
	.type	main.cold.28,@function
main.cold.28:                           # @main.cold.28
# %bb.0:
	pushq	%rax
	leaq	.L.str.27(%rip), %rdi
	callq	die
.Lfunc_end60:
	.size	main.cold.28, .Lfunc_end60-main.cold.28
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.29
	.type	main.cold.29,@function
main.cold.29:                           # @main.cold.29
# %bb.0:
	pushq	%rax
	leaq	.L.str.28(%rip), %rdi
	callq	die
.Lfunc_end61:
	.size	main.cold.29, .Lfunc_end61-main.cold.29
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.30
	.type	main.cold.30,@function
main.cold.30:                           # @main.cold.30
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end62:
	.size	main.cold.30, .Lfunc_end62-main.cold.30
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.31
	.type	main.cold.31,@function
main.cold.31:                           # @main.cold.31
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end63:
	.size	main.cold.31, .Lfunc_end63-main.cold.31
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.32
	.type	main.cold.32,@function
main.cold.32:                           # @main.cold.32
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end64:
	.size	main.cold.32, .Lfunc_end64-main.cold.32
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.33
	.type	main.cold.33,@function
main.cold.33:                           # @main.cold.33
# %bb.0:
	pushq	%rax
	leaq	.L.str.67(%rip), %rdi
	callq	die
.Lfunc_end65:
	.size	main.cold.33, .Lfunc_end65-main.cold.33
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.34
	.type	main.cold.34,@function
main.cold.34:                           # @main.cold.34
# %bb.0:
	pushq	%rax
	leaq	.L.str.68(%rip), %rdi
	callq	die
.Lfunc_end66:
	.size	main.cold.34, .Lfunc_end66-main.cold.34
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.35
	.type	main.cold.35,@function
main.cold.35:                           # @main.cold.35
# %bb.0:
	pushq	%rax
	leaq	.L.str.70(%rip), %rdi
	callq	die
.Lfunc_end67:
	.size	main.cold.35, .Lfunc_end67-main.cold.35
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.36
	.type	main.cold.36,@function
main.cold.36:                           # @main.cold.36
# %bb.0:
	pushq	%rax
	leaq	.L.str.69(%rip), %rdi
	callq	die
.Lfunc_end68:
	.size	main.cold.36, .Lfunc_end68-main.cold.36
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.37
	.type	main.cold.37,@function
main.cold.37:                           # @main.cold.37
# %bb.0:
	pushq	%rax
	leaq	.L.str.77(%rip), %rdi
	callq	die
.Lfunc_end69:
	.size	main.cold.37, .Lfunc_end69-main.cold.37
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.38
	.type	main.cold.38,@function
main.cold.38:                           # @main.cold.38
# %bb.0:
	pushq	%rax
	leaq	.L.str.78(%rip), %rdi
	callq	die
.Lfunc_end70:
	.size	main.cold.38, .Lfunc_end70-main.cold.38
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.39
	.type	main.cold.39,@function
main.cold.39:                           # @main.cold.39
# %bb.0:
	pushq	%rax
	leaq	.L.str.80(%rip), %rdi
	callq	die
.Lfunc_end71:
	.size	main.cold.39, .Lfunc_end71-main.cold.39
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.40
	.type	main.cold.40,@function
main.cold.40:                           # @main.cold.40
# %bb.0:
	pushq	%rax
	leaq	.L.str.81(%rip), %rdi
	callq	die
.Lfunc_end72:
	.size	main.cold.40, .Lfunc_end72-main.cold.40
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.41
	.type	main.cold.41,@function
main.cold.41:                           # @main.cold.41
# %bb.0:
	pushq	%rax
	leaq	.L.str.84(%rip), %rdi
	callq	die
.Lfunc_end73:
	.size	main.cold.41, .Lfunc_end73-main.cold.41
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.42
	.type	main.cold.42,@function
main.cold.42:                           # @main.cold.42
# %bb.0:
	pushq	%rax
	leaq	.L.str.83(%rip), %rdi
	callq	die
.Lfunc_end74:
	.size	main.cold.42, .Lfunc_end74-main.cold.42
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.43
	.type	main.cold.43,@function
main.cold.43:                           # @main.cold.43
# %bb.0:
	pushq	%rax
	leaq	.L.str.86(%rip), %rdi
	callq	die
.Lfunc_end75:
	.size	main.cold.43, .Lfunc_end75-main.cold.43
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.44
	.type	main.cold.44,@function
main.cold.44:                           # @main.cold.44
# %bb.0:
	pushq	%rax
	leaq	.L.str.79(%rip), %rdi
	callq	die
.Lfunc_end76:
	.size	main.cold.44, .Lfunc_end76-main.cold.44
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.45
	.type	main.cold.45,@function
main.cold.45:                           # @main.cold.45
# %bb.0:
	pushq	%rax
	leaq	.L.str.87(%rip), %rdi
	callq	die
.Lfunc_end77:
	.size	main.cold.45, .Lfunc_end77-main.cold.45
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.46
	.type	main.cold.46,@function
main.cold.46:                           # @main.cold.46
# %bb.0:
	pushq	%rax
	leaq	.L.str.96(%rip), %rdi
	callq	die
.Lfunc_end78:
	.size	main.cold.46, .Lfunc_end78-main.cold.46
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.47
	.type	main.cold.47,@function
main.cold.47:                           # @main.cold.47
# %bb.0:
	pushq	%rax
	leaq	.L.str.98(%rip), %rdi
	callq	die
.Lfunc_end79:
	.size	main.cold.47, .Lfunc_end79-main.cold.47
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.48
	.type	main.cold.48,@function
main.cold.48:                           # @main.cold.48
# %bb.0:
	pushq	%rax
	leaq	.L.str.53(%rip), %rdi
	callq	die
.Lfunc_end80:
	.size	main.cold.48, .Lfunc_end80-main.cold.48
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.49
	.type	main.cold.49,@function
main.cold.49:                           # @main.cold.49
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end81:
	.size	main.cold.49, .Lfunc_end81-main.cold.49
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker.cold.1
	.type	mutate_root_marker.cold.1,@function
mutate_root_marker.cold.1:              # @mutate_root_marker.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end82:
	.size	mutate_root_marker.cold.1, .Lfunc_end82-mutate_root_marker.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker.cold.2
	.type	mutate_root_marker.cold.2,@function
mutate_root_marker.cold.2:              # @mutate_root_marker.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.41(%rip), %rdi
	callq	die
.Lfunc_end83:
	.size	mutate_root_marker.cold.2, .Lfunc_end83-mutate_root_marker.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker.cold.3
	.type	mutate_root_marker.cold.3,@function
mutate_root_marker.cold.3:              # @mutate_root_marker.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.36(%rip), %rdi
	callq	die
.Lfunc_end84:
	.size	mutate_root_marker.cold.3, .Lfunc_end84-mutate_root_marker.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.1
	.type	install_bootable_layout.cold.1,@function
install_bootable_layout.cold.1:         # @install_bootable_layout.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.308(%rip), %rdi
	callq	die
.Lfunc_end85:
	.size	install_bootable_layout.cold.1, .Lfunc_end85-install_bootable_layout.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.2
	.type	install_bootable_layout.cold.2,@function
install_bootable_layout.cold.2:         # @install_bootable_layout.cold.2
# %bb.0:
	pushq	%rax
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.316(%rip), %rsi
	leaq	.L.str.314(%rip), %rdx
	movl	$163840, %r8d                   # imm = 0x28000
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end86:
	.size	install_bootable_layout.cold.2, .Lfunc_end86-install_bootable_layout.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.3
	.type	install_bootable_layout.cold.3,@function
install_bootable_layout.cold.3:         # @install_bootable_layout.cold.3
# %bb.0:
	pushq	%rax
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.316(%rip), %rsi
	leaq	.L.str.313(%rip), %rdx
	movl	$8192, %r8d                     # imm = 0x2000
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end87:
	.size	install_bootable_layout.cold.3, .Lfunc_end87-install_bootable_layout.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.4
	.type	install_bootable_layout.cold.4,@function
install_bootable_layout.cold.4:         # @install_bootable_layout.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end88:
	.size	install_bootable_layout.cold.4, .Lfunc_end88-install_bootable_layout.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.5
	.type	install_bootable_layout.cold.5,@function
install_bootable_layout.cold.5:         # @install_bootable_layout.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end89:
	.size	install_bootable_layout.cold.5, .Lfunc_end89-install_bootable_layout.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.6
	.type	install_bootable_layout.cold.6,@function
install_bootable_layout.cold.6:         # @install_bootable_layout.cold.6
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end90:
	.size	install_bootable_layout.cold.6, .Lfunc_end90-install_bootable_layout.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.7
	.type	install_bootable_layout.cold.7,@function
install_bootable_layout.cold.7:         # @install_bootable_layout.cold.7
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end91:
	.size	install_bootable_layout.cold.7, .Lfunc_end91-install_bootable_layout.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.8
	.type	install_bootable_layout.cold.8,@function
install_bootable_layout.cold.8:         # @install_bootable_layout.cold.8
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end92:
	.size	install_bootable_layout.cold.8, .Lfunc_end92-install_bootable_layout.cold.8
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.9
	.type	install_bootable_layout.cold.9,@function
install_bootable_layout.cold.9:         # @install_bootable_layout.cold.9
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end93:
	.size	install_bootable_layout.cold.9, .Lfunc_end93-install_bootable_layout.cold.9
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.10
	.type	install_bootable_layout.cold.10,@function
install_bootable_layout.cold.10:        # @install_bootable_layout.cold.10
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end94:
	.size	install_bootable_layout.cold.10, .Lfunc_end94-install_bootable_layout.cold.10
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.11
	.type	install_bootable_layout.cold.11,@function
install_bootable_layout.cold.11:        # @install_bootable_layout.cold.11
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end95:
	.size	install_bootable_layout.cold.11, .Lfunc_end95-install_bootable_layout.cold.11
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.12
	.type	install_bootable_layout.cold.12,@function
install_bootable_layout.cold.12:        # @install_bootable_layout.cold.12
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end96:
	.size	install_bootable_layout.cold.12, .Lfunc_end96-install_bootable_layout.cold.12
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.13
	.type	install_bootable_layout.cold.13,@function
install_bootable_layout.cold.13:        # @install_bootable_layout.cold.13
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end97:
	.size	install_bootable_layout.cold.13, .Lfunc_end97-install_bootable_layout.cold.13
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.14
	.type	install_bootable_layout.cold.14,@function
install_bootable_layout.cold.14:        # @install_bootable_layout.cold.14
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end98:
	.size	install_bootable_layout.cold.14, .Lfunc_end98-install_bootable_layout.cold.14
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.15
	.type	install_bootable_layout.cold.15,@function
install_bootable_layout.cold.15:        # @install_bootable_layout.cold.15
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end99:
	.size	install_bootable_layout.cold.15, .Lfunc_end99-install_bootable_layout.cold.15
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.16
	.type	install_bootable_layout.cold.16,@function
install_bootable_layout.cold.16:        # @install_bootable_layout.cold.16
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end100:
	.size	install_bootable_layout.cold.16, .Lfunc_end100-install_bootable_layout.cold.16
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.17
	.type	install_bootable_layout.cold.17,@function
install_bootable_layout.cold.17:        # @install_bootable_layout.cold.17
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end101:
	.size	install_bootable_layout.cold.17, .Lfunc_end101-install_bootable_layout.cold.17
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.18
	.type	install_bootable_layout.cold.18,@function
install_bootable_layout.cold.18:        # @install_bootable_layout.cold.18
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end102:
	.size	install_bootable_layout.cold.18, .Lfunc_end102-install_bootable_layout.cold.18
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.19
	.type	install_bootable_layout.cold.19,@function
install_bootable_layout.cold.19:        # @install_bootable_layout.cold.19
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end103:
	.size	install_bootable_layout.cold.19, .Lfunc_end103-install_bootable_layout.cold.19
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.20
	.type	install_bootable_layout.cold.20,@function
install_bootable_layout.cold.20:        # @install_bootable_layout.cold.20
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end104:
	.size	install_bootable_layout.cold.20, .Lfunc_end104-install_bootable_layout.cold.20
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.21
	.type	install_bootable_layout.cold.21,@function
install_bootable_layout.cold.21:        # @install_bootable_layout.cold.21
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end105:
	.size	install_bootable_layout.cold.21, .Lfunc_end105-install_bootable_layout.cold.21
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.22
	.type	install_bootable_layout.cold.22,@function
install_bootable_layout.cold.22:        # @install_bootable_layout.cold.22
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end106:
	.size	install_bootable_layout.cold.22, .Lfunc_end106-install_bootable_layout.cold.22
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.23
	.type	install_bootable_layout.cold.23,@function
install_bootable_layout.cold.23:        # @install_bootable_layout.cold.23
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end107:
	.size	install_bootable_layout.cold.23, .Lfunc_end107-install_bootable_layout.cold.23
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.24
	.type	install_bootable_layout.cold.24,@function
install_bootable_layout.cold.24:        # @install_bootable_layout.cold.24
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end108:
	.size	install_bootable_layout.cold.24, .Lfunc_end108-install_bootable_layout.cold.24
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.25
	.type	install_bootable_layout.cold.25,@function
install_bootable_layout.cold.25:        # @install_bootable_layout.cold.25
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end109:
	.size	install_bootable_layout.cold.25, .Lfunc_end109-install_bootable_layout.cold.25
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.26
	.type	install_bootable_layout.cold.26,@function
install_bootable_layout.cold.26:        # @install_bootable_layout.cold.26
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end110:
	.size	install_bootable_layout.cold.26, .Lfunc_end110-install_bootable_layout.cold.26
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.27
	.type	install_bootable_layout.cold.27,@function
install_bootable_layout.cold.27:        # @install_bootable_layout.cold.27
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end111:
	.size	install_bootable_layout.cold.27, .Lfunc_end111-install_bootable_layout.cold.27
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.28
	.type	install_bootable_layout.cold.28,@function
install_bootable_layout.cold.28:        # @install_bootable_layout.cold.28
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end112:
	.size	install_bootable_layout.cold.28, .Lfunc_end112-install_bootable_layout.cold.28
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.29
	.type	install_bootable_layout.cold.29,@function
install_bootable_layout.cold.29:        # @install_bootable_layout.cold.29
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end113:
	.size	install_bootable_layout.cold.29, .Lfunc_end113-install_bootable_layout.cold.29
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.30
	.type	install_bootable_layout.cold.30,@function
install_bootable_layout.cold.30:        # @install_bootable_layout.cold.30
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end114:
	.size	install_bootable_layout.cold.30, .Lfunc_end114-install_bootable_layout.cold.30
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.31
	.type	install_bootable_layout.cold.31,@function
install_bootable_layout.cold.31:        # @install_bootable_layout.cold.31
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end115:
	.size	install_bootable_layout.cold.31, .Lfunc_end115-install_bootable_layout.cold.31
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.32
	.type	install_bootable_layout.cold.32,@function
install_bootable_layout.cold.32:        # @install_bootable_layout.cold.32
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end116:
	.size	install_bootable_layout.cold.32, .Lfunc_end116-install_bootable_layout.cold.32
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.33
	.type	install_bootable_layout.cold.33,@function
install_bootable_layout.cold.33:        # @install_bootable_layout.cold.33
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end117:
	.size	install_bootable_layout.cold.33, .Lfunc_end117-install_bootable_layout.cold.33
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.34
	.type	install_bootable_layout.cold.34,@function
install_bootable_layout.cold.34:        # @install_bootable_layout.cold.34
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end118:
	.size	install_bootable_layout.cold.34, .Lfunc_end118-install_bootable_layout.cold.34
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.35
	.type	install_bootable_layout.cold.35,@function
install_bootable_layout.cold.35:        # @install_bootable_layout.cold.35
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end119:
	.size	install_bootable_layout.cold.35, .Lfunc_end119-install_bootable_layout.cold.35
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.36
	.type	install_bootable_layout.cold.36,@function
install_bootable_layout.cold.36:        # @install_bootable_layout.cold.36
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end120:
	.size	install_bootable_layout.cold.36, .Lfunc_end120-install_bootable_layout.cold.36
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.37
	.type	install_bootable_layout.cold.37,@function
install_bootable_layout.cold.37:        # @install_bootable_layout.cold.37
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end121:
	.size	install_bootable_layout.cold.37, .Lfunc_end121-install_bootable_layout.cold.37
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.38
	.type	install_bootable_layout.cold.38,@function
install_bootable_layout.cold.38:        # @install_bootable_layout.cold.38
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end122:
	.size	install_bootable_layout.cold.38, .Lfunc_end122-install_bootable_layout.cold.38
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.39
	.type	install_bootable_layout.cold.39,@function
install_bootable_layout.cold.39:        # @install_bootable_layout.cold.39
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end123:
	.size	install_bootable_layout.cold.39, .Lfunc_end123-install_bootable_layout.cold.39
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.40
	.type	install_bootable_layout.cold.40,@function
install_bootable_layout.cold.40:        # @install_bootable_layout.cold.40
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end124:
	.size	install_bootable_layout.cold.40, .Lfunc_end124-install_bootable_layout.cold.40
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.41
	.type	install_bootable_layout.cold.41,@function
install_bootable_layout.cold.41:        # @install_bootable_layout.cold.41
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end125:
	.size	install_bootable_layout.cold.41, .Lfunc_end125-install_bootable_layout.cold.41
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.42
	.type	install_bootable_layout.cold.42,@function
install_bootable_layout.cold.42:        # @install_bootable_layout.cold.42
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end126:
	.size	install_bootable_layout.cold.42, .Lfunc_end126-install_bootable_layout.cold.42
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.43
	.type	install_bootable_layout.cold.43,@function
install_bootable_layout.cold.43:        # @install_bootable_layout.cold.43
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end127:
	.size	install_bootable_layout.cold.43, .Lfunc_end127-install_bootable_layout.cold.43
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.44
	.type	install_bootable_layout.cold.44,@function
install_bootable_layout.cold.44:        # @install_bootable_layout.cold.44
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end128:
	.size	install_bootable_layout.cold.44, .Lfunc_end128-install_bootable_layout.cold.44
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.45
	.type	install_bootable_layout.cold.45,@function
install_bootable_layout.cold.45:        # @install_bootable_layout.cold.45
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end129:
	.size	install_bootable_layout.cold.45, .Lfunc_end129-install_bootable_layout.cold.45
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.46
	.type	install_bootable_layout.cold.46,@function
install_bootable_layout.cold.46:        # @install_bootable_layout.cold.46
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end130:
	.size	install_bootable_layout.cold.46, .Lfunc_end130-install_bootable_layout.cold.46
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.47
	.type	install_bootable_layout.cold.47,@function
install_bootable_layout.cold.47:        # @install_bootable_layout.cold.47
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end131:
	.size	install_bootable_layout.cold.47, .Lfunc_end131-install_bootable_layout.cold.47
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.48
	.type	install_bootable_layout.cold.48,@function
install_bootable_layout.cold.48:        # @install_bootable_layout.cold.48
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end132:
	.size	install_bootable_layout.cold.48, .Lfunc_end132-install_bootable_layout.cold.48
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.49
	.type	install_bootable_layout.cold.49,@function
install_bootable_layout.cold.49:        # @install_bootable_layout.cold.49
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end133:
	.size	install_bootable_layout.cold.49, .Lfunc_end133-install_bootable_layout.cold.49
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.50
	.type	install_bootable_layout.cold.50,@function
install_bootable_layout.cold.50:        # @install_bootable_layout.cold.50
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end134:
	.size	install_bootable_layout.cold.50, .Lfunc_end134-install_bootable_layout.cold.50
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.51
	.type	install_bootable_layout.cold.51,@function
install_bootable_layout.cold.51:        # @install_bootable_layout.cold.51
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end135:
	.size	install_bootable_layout.cold.51, .Lfunc_end135-install_bootable_layout.cold.51
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.52
	.type	install_bootable_layout.cold.52,@function
install_bootable_layout.cold.52:        # @install_bootable_layout.cold.52
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end136:
	.size	install_bootable_layout.cold.52, .Lfunc_end136-install_bootable_layout.cold.52
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.53
	.type	install_bootable_layout.cold.53,@function
install_bootable_layout.cold.53:        # @install_bootable_layout.cold.53
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end137:
	.size	install_bootable_layout.cold.53, .Lfunc_end137-install_bootable_layout.cold.53
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.54
	.type	install_bootable_layout.cold.54,@function
install_bootable_layout.cold.54:        # @install_bootable_layout.cold.54
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end138:
	.size	install_bootable_layout.cold.54, .Lfunc_end138-install_bootable_layout.cold.54
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.55
	.type	install_bootable_layout.cold.55,@function
install_bootable_layout.cold.55:        # @install_bootable_layout.cold.55
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end139:
	.size	install_bootable_layout.cold.55, .Lfunc_end139-install_bootable_layout.cold.55
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.56
	.type	install_bootable_layout.cold.56,@function
install_bootable_layout.cold.56:        # @install_bootable_layout.cold.56
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end140:
	.size	install_bootable_layout.cold.56, .Lfunc_end140-install_bootable_layout.cold.56
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.57
	.type	install_bootable_layout.cold.57,@function
install_bootable_layout.cold.57:        # @install_bootable_layout.cold.57
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end141:
	.size	install_bootable_layout.cold.57, .Lfunc_end141-install_bootable_layout.cold.57
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.58
	.type	install_bootable_layout.cold.58,@function
install_bootable_layout.cold.58:        # @install_bootable_layout.cold.58
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end142:
	.size	install_bootable_layout.cold.58, .Lfunc_end142-install_bootable_layout.cold.58
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.59
	.type	install_bootable_layout.cold.59,@function
install_bootable_layout.cold.59:        # @install_bootable_layout.cold.59
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end143:
	.size	install_bootable_layout.cold.59, .Lfunc_end143-install_bootable_layout.cold.59
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.60
	.type	install_bootable_layout.cold.60,@function
install_bootable_layout.cold.60:        # @install_bootable_layout.cold.60
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end144:
	.size	install_bootable_layout.cold.60, .Lfunc_end144-install_bootable_layout.cold.60
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.61
	.type	install_bootable_layout.cold.61,@function
install_bootable_layout.cold.61:        # @install_bootable_layout.cold.61
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end145:
	.size	install_bootable_layout.cold.61, .Lfunc_end145-install_bootable_layout.cold.61
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.62
	.type	install_bootable_layout.cold.62,@function
install_bootable_layout.cold.62:        # @install_bootable_layout.cold.62
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end146:
	.size	install_bootable_layout.cold.62, .Lfunc_end146-install_bootable_layout.cold.62
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.63
	.type	install_bootable_layout.cold.63,@function
install_bootable_layout.cold.63:        # @install_bootable_layout.cold.63
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end147:
	.size	install_bootable_layout.cold.63, .Lfunc_end147-install_bootable_layout.cold.63
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.64
	.type	install_bootable_layout.cold.64,@function
install_bootable_layout.cold.64:        # @install_bootable_layout.cold.64
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end148:
	.size	install_bootable_layout.cold.64, .Lfunc_end148-install_bootable_layout.cold.64
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.65
	.type	install_bootable_layout.cold.65,@function
install_bootable_layout.cold.65:        # @install_bootable_layout.cold.65
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end149:
	.size	install_bootable_layout.cold.65, .Lfunc_end149-install_bootable_layout.cold.65
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.66
	.type	install_bootable_layout.cold.66,@function
install_bootable_layout.cold.66:        # @install_bootable_layout.cold.66
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end150:
	.size	install_bootable_layout.cold.66, .Lfunc_end150-install_bootable_layout.cold.66
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.67
	.type	install_bootable_layout.cold.67,@function
install_bootable_layout.cold.67:        # @install_bootable_layout.cold.67
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end151:
	.size	install_bootable_layout.cold.67, .Lfunc_end151-install_bootable_layout.cold.67
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.68
	.type	install_bootable_layout.cold.68,@function
install_bootable_layout.cold.68:        # @install_bootable_layout.cold.68
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end152:
	.size	install_bootable_layout.cold.68, .Lfunc_end152-install_bootable_layout.cold.68
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.69
	.type	install_bootable_layout.cold.69,@function
install_bootable_layout.cold.69:        # @install_bootable_layout.cold.69
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end153:
	.size	install_bootable_layout.cold.69, .Lfunc_end153-install_bootable_layout.cold.69
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.70
	.type	install_bootable_layout.cold.70,@function
install_bootable_layout.cold.70:        # @install_bootable_layout.cold.70
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end154:
	.size	install_bootable_layout.cold.70, .Lfunc_end154-install_bootable_layout.cold.70
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.71
	.type	install_bootable_layout.cold.71,@function
install_bootable_layout.cold.71:        # @install_bootable_layout.cold.71
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end155:
	.size	install_bootable_layout.cold.71, .Lfunc_end155-install_bootable_layout.cold.71
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.72
	.type	install_bootable_layout.cold.72,@function
install_bootable_layout.cold.72:        # @install_bootable_layout.cold.72
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end156:
	.size	install_bootable_layout.cold.72, .Lfunc_end156-install_bootable_layout.cold.72
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.73
	.type	install_bootable_layout.cold.73,@function
install_bootable_layout.cold.73:        # @install_bootable_layout.cold.73
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end157:
	.size	install_bootable_layout.cold.73, .Lfunc_end157-install_bootable_layout.cold.73
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.74
	.type	install_bootable_layout.cold.74,@function
install_bootable_layout.cold.74:        # @install_bootable_layout.cold.74
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end158:
	.size	install_bootable_layout.cold.74, .Lfunc_end158-install_bootable_layout.cold.74
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.75
	.type	install_bootable_layout.cold.75,@function
install_bootable_layout.cold.75:        # @install_bootable_layout.cold.75
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end159:
	.size	install_bootable_layout.cold.75, .Lfunc_end159-install_bootable_layout.cold.75
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.76
	.type	install_bootable_layout.cold.76,@function
install_bootable_layout.cold.76:        # @install_bootable_layout.cold.76
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end160:
	.size	install_bootable_layout.cold.76, .Lfunc_end160-install_bootable_layout.cold.76
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.77
	.type	install_bootable_layout.cold.77,@function
install_bootable_layout.cold.77:        # @install_bootable_layout.cold.77
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end161:
	.size	install_bootable_layout.cold.77, .Lfunc_end161-install_bootable_layout.cold.77
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.78
	.type	install_bootable_layout.cold.78,@function
install_bootable_layout.cold.78:        # @install_bootable_layout.cold.78
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end162:
	.size	install_bootable_layout.cold.78, .Lfunc_end162-install_bootable_layout.cold.78
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.79
	.type	install_bootable_layout.cold.79,@function
install_bootable_layout.cold.79:        # @install_bootable_layout.cold.79
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end163:
	.size	install_bootable_layout.cold.79, .Lfunc_end163-install_bootable_layout.cold.79
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.80
	.type	install_bootable_layout.cold.80,@function
install_bootable_layout.cold.80:        # @install_bootable_layout.cold.80
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end164:
	.size	install_bootable_layout.cold.80, .Lfunc_end164-install_bootable_layout.cold.80
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.81
	.type	install_bootable_layout.cold.81,@function
install_bootable_layout.cold.81:        # @install_bootable_layout.cold.81
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end165:
	.size	install_bootable_layout.cold.81, .Lfunc_end165-install_bootable_layout.cold.81
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.82
	.type	install_bootable_layout.cold.82,@function
install_bootable_layout.cold.82:        # @install_bootable_layout.cold.82
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end166:
	.size	install_bootable_layout.cold.82, .Lfunc_end166-install_bootable_layout.cold.82
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.83
	.type	install_bootable_layout.cold.83,@function
install_bootable_layout.cold.83:        # @install_bootable_layout.cold.83
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end167:
	.size	install_bootable_layout.cold.83, .Lfunc_end167-install_bootable_layout.cold.83
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.84
	.type	install_bootable_layout.cold.84,@function
install_bootable_layout.cold.84:        # @install_bootable_layout.cold.84
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end168:
	.size	install_bootable_layout.cold.84, .Lfunc_end168-install_bootable_layout.cold.84
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.85
	.type	install_bootable_layout.cold.85,@function
install_bootable_layout.cold.85:        # @install_bootable_layout.cold.85
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end169:
	.size	install_bootable_layout.cold.85, .Lfunc_end169-install_bootable_layout.cold.85
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.86
	.type	install_bootable_layout.cold.86,@function
install_bootable_layout.cold.86:        # @install_bootable_layout.cold.86
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end170:
	.size	install_bootable_layout.cold.86, .Lfunc_end170-install_bootable_layout.cold.86
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.87
	.type	install_bootable_layout.cold.87,@function
install_bootable_layout.cold.87:        # @install_bootable_layout.cold.87
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end171:
	.size	install_bootable_layout.cold.87, .Lfunc_end171-install_bootable_layout.cold.87
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.88
	.type	install_bootable_layout.cold.88,@function
install_bootable_layout.cold.88:        # @install_bootable_layout.cold.88
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end172:
	.size	install_bootable_layout.cold.88, .Lfunc_end172-install_bootable_layout.cold.88
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.89
	.type	install_bootable_layout.cold.89,@function
install_bootable_layout.cold.89:        # @install_bootable_layout.cold.89
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end173:
	.size	install_bootable_layout.cold.89, .Lfunc_end173-install_bootable_layout.cold.89
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.90
	.type	install_bootable_layout.cold.90,@function
install_bootable_layout.cold.90:        # @install_bootable_layout.cold.90
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end174:
	.size	install_bootable_layout.cold.90, .Lfunc_end174-install_bootable_layout.cold.90
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.91
	.type	install_bootable_layout.cold.91,@function
install_bootable_layout.cold.91:        # @install_bootable_layout.cold.91
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end175:
	.size	install_bootable_layout.cold.91, .Lfunc_end175-install_bootable_layout.cold.91
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.92
	.type	install_bootable_layout.cold.92,@function
install_bootable_layout.cold.92:        # @install_bootable_layout.cold.92
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end176:
	.size	install_bootable_layout.cold.92, .Lfunc_end176-install_bootable_layout.cold.92
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.93
	.type	install_bootable_layout.cold.93,@function
install_bootable_layout.cold.93:        # @install_bootable_layout.cold.93
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end177:
	.size	install_bootable_layout.cold.93, .Lfunc_end177-install_bootable_layout.cold.93
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.94
	.type	install_bootable_layout.cold.94,@function
install_bootable_layout.cold.94:        # @install_bootable_layout.cold.94
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end178:
	.size	install_bootable_layout.cold.94, .Lfunc_end178-install_bootable_layout.cold.94
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.95
	.type	install_bootable_layout.cold.95,@function
install_bootable_layout.cold.95:        # @install_bootable_layout.cold.95
# %bb.0:
	pushq	%rax
	leaq	.L.str.394(%rip), %rdi
	callq	die
.Lfunc_end179:
	.size	install_bootable_layout.cold.95, .Lfunc_end179-install_bootable_layout.cold.95
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.96
	.type	install_bootable_layout.cold.96,@function
install_bootable_layout.cold.96:        # @install_bootable_layout.cold.96
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end180:
	.size	install_bootable_layout.cold.96, .Lfunc_end180-install_bootable_layout.cold.96
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.97
	.type	install_bootable_layout.cold.97,@function
install_bootable_layout.cold.97:        # @install_bootable_layout.cold.97
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end181:
	.size	install_bootable_layout.cold.97, .Lfunc_end181-install_bootable_layout.cold.97
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.98
	.type	install_bootable_layout.cold.98,@function
install_bootable_layout.cold.98:        # @install_bootable_layout.cold.98
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end182:
	.size	install_bootable_layout.cold.98, .Lfunc_end182-install_bootable_layout.cold.98
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.99
	.type	install_bootable_layout.cold.99,@function
install_bootable_layout.cold.99:        # @install_bootable_layout.cold.99
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end183:
	.size	install_bootable_layout.cold.99, .Lfunc_end183-install_bootable_layout.cold.99
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.100
	.type	install_bootable_layout.cold.100,@function
install_bootable_layout.cold.100:       # @install_bootable_layout.cold.100
# %bb.0:
	pushq	%rax
	leaq	.L.str.310(%rip), %rdi
	callq	die
.Lfunc_end184:
	.size	install_bootable_layout.cold.100, .Lfunc_end184-install_bootable_layout.cold.100
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.101
	.type	install_bootable_layout.cold.101,@function
install_bootable_layout.cold.101:       # @install_bootable_layout.cold.101
# %bb.0:
	pushq	%rax
	leaq	.L.str.428(%rip), %rdi
	callq	die
.Lfunc_end185:
	.size	install_bootable_layout.cold.101, .Lfunc_end185-install_bootable_layout.cold.101
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.102
	.type	install_bootable_layout.cold.102,@function
install_bootable_layout.cold.102:       # @install_bootable_layout.cold.102
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end186:
	.size	install_bootable_layout.cold.102, .Lfunc_end186-install_bootable_layout.cold.102
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.103
	.type	install_bootable_layout.cold.103,@function
install_bootable_layout.cold.103:       # @install_bootable_layout.cold.103
# %bb.0:
	pushq	%rax
	leaq	.L.str.428(%rip), %rdi
	callq	die
.Lfunc_end187:
	.size	install_bootable_layout.cold.103, .Lfunc_end187-install_bootable_layout.cold.103
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.104
	.type	install_bootable_layout.cold.104,@function
install_bootable_layout.cold.104:       # @install_bootable_layout.cold.104
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end188:
	.size	install_bootable_layout.cold.104, .Lfunc_end188-install_bootable_layout.cold.104
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.105
	.type	install_bootable_layout.cold.105,@function
install_bootable_layout.cold.105:       # @install_bootable_layout.cold.105
# %bb.0:
	pushq	%rax
	leaq	.L.str.428(%rip), %rdi
	callq	die
.Lfunc_end189:
	.size	install_bootable_layout.cold.105, .Lfunc_end189-install_bootable_layout.cold.105
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.106
	.type	install_bootable_layout.cold.106,@function
install_bootable_layout.cold.106:       # @install_bootable_layout.cold.106
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end190:
	.size	install_bootable_layout.cold.106, .Lfunc_end190-install_bootable_layout.cold.106
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.107
	.type	install_bootable_layout.cold.107,@function
install_bootable_layout.cold.107:       # @install_bootable_layout.cold.107
# %bb.0:
	pushq	%rax
	leaq	.L.str.36(%rip), %rdi
	callq	die
.Lfunc_end191:
	.size	install_bootable_layout.cold.107, .Lfunc_end191-install_bootable_layout.cold.107
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.108
	.type	install_bootable_layout.cold.108,@function
install_bootable_layout.cold.108:       # @install_bootable_layout.cold.108
# %bb.0:
	pushq	%rax
	leaq	.L.str.36(%rip), %rdi
	callq	die
.Lfunc_end192:
	.size	install_bootable_layout.cold.108, .Lfunc_end192-install_bootable_layout.cold.108
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.109
	.type	install_bootable_layout.cold.109,@function
install_bootable_layout.cold.109:       # @install_bootable_layout.cold.109
# %bb.0:
	pushq	%rax
	leaq	.L.str.429(%rip), %rdi
	callq	die
.Lfunc_end193:
	.size	install_bootable_layout.cold.109, .Lfunc_end193-install_bootable_layout.cold.109
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.110
	.type	install_bootable_layout.cold.110,@function
install_bootable_layout.cold.110:       # @install_bootable_layout.cold.110
# %bb.0:
	pushq	%rax
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	leaq	.L.str.438(%rip), %rdi
	pushq	$93
	popq	%rsi
	pushq	$1
	popq	%rdx
	callq	fwrite@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end194:
	.size	install_bootable_layout.cold.110, .Lfunc_end194-install_bootable_layout.cold.110
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.111
	.type	install_bootable_layout.cold.111,@function
install_bootable_layout.cold.111:       # @install_bootable_layout.cold.111
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.497(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end195:
	.size	install_bootable_layout.cold.111, .Lfunc_end195-install_bootable_layout.cold.111
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.112
	.type	install_bootable_layout.cold.112,@function
install_bootable_layout.cold.112:       # @install_bootable_layout.cold.112
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.497(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end196:
	.size	install_bootable_layout.cold.112, .Lfunc_end196-install_bootable_layout.cold.112
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.113
	.type	install_bootable_layout.cold.113,@function
install_bootable_layout.cold.113:       # @install_bootable_layout.cold.113
# %bb.0:
	pushq	%rax
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.497(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end197:
	.size	install_bootable_layout.cold.113, .Lfunc_end197-install_bootable_layout.cold.113
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.114
	.type	install_bootable_layout.cold.114,@function
install_bootable_layout.cold.114:       # @install_bootable_layout.cold.114
# %bb.0:
	pushq	%rax
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.497(%rip), %rsi
	leaq	PI4_SYSTEM_ABIPROBE_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end198:
	.size	install_bootable_layout.cold.114, .Lfunc_end198-install_bootable_layout.cold.114
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.115
	.type	install_bootable_layout.cold.115,@function
install_bootable_layout.cold.115:       # @install_bootable_layout.cold.115
# %bb.0:
	pushq	%rax
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.497(%rip), %rsi
	leaq	PI4_SYSTEM_INIT_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end199:
	.size	install_bootable_layout.cold.115, .Lfunc_end199-install_bootable_layout.cold.115
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.116
	.type	install_bootable_layout.cold.116,@function
install_bootable_layout.cold.116:       # @install_bootable_layout.cold.116
# %bb.0:
	pushq	%rax
	leaq	.L.str.311(%rip), %rdi
	callq	die
.Lfunc_end200:
	.size	install_bootable_layout.cold.116, .Lfunc_end200-install_bootable_layout.cold.116
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.117
	.type	install_bootable_layout.cold.117,@function
install_bootable_layout.cold.117:       # @install_bootable_layout.cold.117
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end201:
	.size	install_bootable_layout.cold.117, .Lfunc_end201-install_bootable_layout.cold.117
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.118
	.type	install_bootable_layout.cold.118,@function
install_bootable_layout.cold.118:       # @install_bootable_layout.cold.118
# %bb.0:
	pushq	%rax
	leaq	.L.str.426(%rip), %rdi
	callq	die
.Lfunc_end202:
	.size	install_bootable_layout.cold.118, .Lfunc_end202-install_bootable_layout.cold.118
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.119
	.type	install_bootable_layout.cold.119,@function
install_bootable_layout.cold.119:       # @install_bootable_layout.cold.119
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end203:
	.size	install_bootable_layout.cold.119, .Lfunc_end203-install_bootable_layout.cold.119
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.120
	.type	install_bootable_layout.cold.120,@function
install_bootable_layout.cold.120:       # @install_bootable_layout.cold.120
# %bb.0:
	pushq	%rax
	leaq	.L.str.426(%rip), %rdi
	callq	die
.Lfunc_end204:
	.size	install_bootable_layout.cold.120, .Lfunc_end204-install_bootable_layout.cold.120
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.121
	.type	install_bootable_layout.cold.121,@function
install_bootable_layout.cold.121:       # @install_bootable_layout.cold.121
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end205:
	.size	install_bootable_layout.cold.121, .Lfunc_end205-install_bootable_layout.cold.121
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.122
	.type	install_bootable_layout.cold.122,@function
install_bootable_layout.cold.122:       # @install_bootable_layout.cold.122
# %bb.0:
	pushq	%rax
	leaq	.L.str.426(%rip), %rdi
	callq	die
.Lfunc_end206:
	.size	install_bootable_layout.cold.122, .Lfunc_end206-install_bootable_layout.cold.122
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.123
	.type	install_bootable_layout.cold.123,@function
install_bootable_layout.cold.123:       # @install_bootable_layout.cold.123
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end207:
	.size	install_bootable_layout.cold.123, .Lfunc_end207-install_bootable_layout.cold.123
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.124
	.type	install_bootable_layout.cold.124,@function
install_bootable_layout.cold.124:       # @install_bootable_layout.cold.124
# %bb.0:
	pushq	%rax
	leaq	.L.str.426(%rip), %rdi
	callq	die
.Lfunc_end208:
	.size	install_bootable_layout.cold.124, .Lfunc_end208-install_bootable_layout.cold.124
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.125
	.type	install_bootable_layout.cold.125,@function
install_bootable_layout.cold.125:       # @install_bootable_layout.cold.125
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end209:
	.size	install_bootable_layout.cold.125, .Lfunc_end209-install_bootable_layout.cold.125
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.126
	.type	install_bootable_layout.cold.126,@function
install_bootable_layout.cold.126:       # @install_bootable_layout.cold.126
# %bb.0:
	pushq	%rax
	leaq	.L.str.426(%rip), %rdi
	callq	die
.Lfunc_end210:
	.size	install_bootable_layout.cold.126, .Lfunc_end210-install_bootable_layout.cold.126
                                        # -- End function
	.p2align	4                               # -- Begin function write_file.cold.1
	.type	write_file.cold.1,@function
write_file.cold.1:                      # @write_file.cold.1
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end211:
	.size	write_file.cold.1, .Lfunc_end211-write_file.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function read_file.cold.1
	.type	read_file.cold.1,@function
read_file.cold.1:                       # @read_file.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end212:
	.size	read_file.cold.1, .Lfunc_end212-read_file.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function read_file.cold.2
	.type	read_file.cold.2,@function
read_file.cold.2:                       # @read_file.cold.2
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end213:
	.size	read_file.cold.2, .Lfunc_end213-read_file.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.1
	.type	write_file_path.cold.1,@function
write_file_path.cold.1:                 # @write_file_path.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end214:
	.size	write_file_path.cold.1, .Lfunc_end214-write_file_path.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.2
	.type	write_file_path.cold.2,@function
write_file_path.cold.2:                 # @write_file_path.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.41(%rip), %rdi
	callq	die
.Lfunc_end215:
	.size	write_file_path.cold.2, .Lfunc_end215-write_file_path.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.3
	.type	write_file_path.cold.3,@function
write_file_path.cold.3:                 # @write_file_path.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end216:
	.size	write_file_path.cold.3, .Lfunc_end216-write_file_path.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.4
	.type	write_file_path.cold.4,@function
write_file_path.cold.4:                 # @write_file_path.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end217:
	.size	write_file_path.cold.4, .Lfunc_end217-write_file_path.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.1
	.type	ensure_child_directory.cold.1,@function
ensure_child_directory.cold.1:          # @ensure_child_directory.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.41(%rip), %rdi
	callq	die
.Lfunc_end218:
	.size	ensure_child_directory.cold.1, .Lfunc_end218-ensure_child_directory.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.2
	.type	ensure_child_directory.cold.2,@function
ensure_child_directory.cold.2:          # @ensure_child_directory.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end219:
	.size	ensure_child_directory.cold.2, .Lfunc_end219-ensure_child_directory.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.3
	.type	ensure_child_directory.cold.3,@function
ensure_child_directory.cold.3:          # @ensure_child_directory.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.41(%rip), %rdi
	callq	die
.Lfunc_end220:
	.size	ensure_child_directory.cold.3, .Lfunc_end220-ensure_child_directory.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.4
	.type	ensure_child_directory.cold.4,@function
ensure_child_directory.cold.4:          # @ensure_child_directory.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.47(%rip), %rdi
	callq	die
.Lfunc_end221:
	.size	ensure_child_directory.cold.4, .Lfunc_end221-ensure_child_directory.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.5
	.type	ensure_child_directory.cold.5,@function
ensure_child_directory.cold.5:          # @ensure_child_directory.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.36(%rip), %rdi
	callq	die
.Lfunc_end222:
	.size	ensure_child_directory.cold.5, .Lfunc_end222-ensure_child_directory.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.6
	.type	ensure_child_directory.cold.6,@function
ensure_child_directory.cold.6:          # @ensure_child_directory.cold.6
# %bb.0:
	pushq	%rax
	leaq	.L.str.43(%rip), %rdi
	callq	die
.Lfunc_end223:
	.size	ensure_child_directory.cold.6, .Lfunc_end223-ensure_child_directory.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain.cold.1
	.type	write_cluster_chain.cold.1,@function
write_cluster_chain.cold.1:             # @write_cluster_chain.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.46(%rip), %rdi
	callq	die
.Lfunc_end224:
	.size	write_cluster_chain.cold.1, .Lfunc_end224-write_cluster_chain.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain.cold.2
	.type	write_cluster_chain.cold.2,@function
write_cluster_chain.cold.2:             # @write_cluster_chain.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.41(%rip), %rdi
	callq	die
.Lfunc_end225:
	.size	write_cluster_chain.cold.2, .Lfunc_end225-write_cluster_chain.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain.cold.3
	.type	write_cluster_chain.cold.3,@function
write_cluster_chain.cold.3:             # @write_cluster_chain.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end226:
	.size	write_cluster_chain.cold.3, .Lfunc_end226-write_cluster_chain.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.1
	.type	check_write_status.cold.1,@function
check_write_status.cold.1:              # @check_write_status.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.96(%rip), %rdi
	callq	die
.Lfunc_end227:
	.size	check_write_status.cold.1, .Lfunc_end227-check_write_status.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.2
	.type	check_write_status.cold.2,@function
check_write_status.cold.2:              # @check_write_status.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.99(%rip), %rdi
	callq	die
.Lfunc_end228:
	.size	check_write_status.cold.2, .Lfunc_end228-check_write_status.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.3
	.type	check_write_status.cold.3,@function
check_write_status.cold.3:              # @check_write_status.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.98(%rip), %rdi
	callq	die
.Lfunc_end229:
	.size	check_write_status.cold.3, .Lfunc_end229-check_write_status.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.4
	.type	check_write_status.cold.4,@function
check_write_status.cold.4:              # @check_write_status.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.98(%rip), %rdi
	callq	die
.Lfunc_end230:
	.size	check_write_status.cold.4, .Lfunc_end230-check_write_status.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.5
	.type	check_write_status.cold.5,@function
check_write_status.cold.5:              # @check_write_status.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.99(%rip), %rdi
	callq	die
.Lfunc_end231:
	.size	check_write_status.cold.5, .Lfunc_end231-check_write_status.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.6
	.type	check_write_status.cold.6,@function
check_write_status.cold.6:              # @check_write_status.cold.6
# %bb.0:
	pushq	%rax
	leaq	.L.str.99(%rip), %rdi
	callq	die
.Lfunc_end232:
	.size	check_write_status.cold.6, .Lfunc_end232-check_write_status.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.7
	.type	check_write_status.cold.7,@function
check_write_status.cold.7:              # @check_write_status.cold.7
# %bb.0:
	pushq	%rax
	leaq	.L.str.98(%rip), %rdi
	callq	die
.Lfunc_end233:
	.size	check_write_status.cold.7, .Lfunc_end233-check_write_status.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.8
	.type	check_write_status.cold.8,@function
check_write_status.cold.8:              # @check_write_status.cold.8
# %bb.0:
	pushq	%rax
	leaq	.L.str.98(%rip), %rdi
	callq	die
.Lfunc_end234:
	.size	check_write_status.cold.8, .Lfunc_end234-check_write_status.cold.8
                                        # -- End function
	.p2align	4                               # -- Begin function check_dynamic_fat_status.cold.1
	.type	check_dynamic_fat_status.cold.1,@function
check_dynamic_fat_status.cold.1:        # @check_dynamic_fat_status.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.96(%rip), %rdi
	callq	die
.Lfunc_end235:
	.size	check_dynamic_fat_status.cold.1, .Lfunc_end235-check_dynamic_fat_status.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function check_dynamic_fat_status.cold.2
	.type	check_dynamic_fat_status.cold.2,@function
check_dynamic_fat_status.cold.2:        # @check_dynamic_fat_status.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.98(%rip), %rdi
	callq	die
.Lfunc_end236:
	.size	check_dynamic_fat_status.cold.2, .Lfunc_end236-check_dynamic_fat_status.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function read_root_file_blob.cold.1
	.type	read_root_file_blob.cold.1,@function
read_root_file_blob.cold.1:             # @read_root_file_blob.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end237:
	.size	read_root_file_blob.cold.1, .Lfunc_end237-read_root_file_blob.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part.cold.1
	.type	status_hex_tuple_part.cold.1,@function
status_hex_tuple_part.cold.1:           # @status_hex_tuple_part.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.97(%rip), %rdi
	callq	die
.Lfunc_end238:
	.size	status_hex_tuple_part.cold.1, .Lfunc_end238-status_hex_tuple_part.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part.cold.2
	.type	status_hex_tuple_part.cold.2,@function
status_hex_tuple_part.cold.2:           # @status_hex_tuple_part.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.98(%rip), %rdi
	callq	die
.Lfunc_end239:
	.size	status_hex_tuple_part.cold.2, .Lfunc_end239-status_hex_tuple_part.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part.cold.3
	.type	status_hex_tuple_part.cold.3,@function
status_hex_tuple_part.cold.3:           # @status_hex_tuple_part.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.96(%rip), %rdi
	callq	die
.Lfunc_end240:
	.size	status_hex_tuple_part.cold.3, .Lfunc_end240-status_hex_tuple_part.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.1
	.type	parse_path83.cold.1,@function
parse_path83.cold.1:                    # @parse_path83.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.119(%rip), %rdi
	callq	die
.Lfunc_end241:
	.size	parse_path83.cold.1, .Lfunc_end241-parse_path83.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.2
	.type	parse_path83.cold.2,@function
parse_path83.cold.2:                    # @parse_path83.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.117(%rip), %rdi
	callq	die
.Lfunc_end242:
	.size	parse_path83.cold.2, .Lfunc_end242-parse_path83.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.3
	.type	parse_path83.cold.3,@function
parse_path83.cold.3:                    # @parse_path83.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.119(%rip), %rdi
	callq	die
.Lfunc_end243:
	.size	parse_path83.cold.3, .Lfunc_end243-parse_path83.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.4
	.type	parse_path83.cold.4,@function
parse_path83.cold.4:                    # @parse_path83.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.117(%rip), %rdi
	callq	die
.Lfunc_end244:
	.size	parse_path83.cold.4, .Lfunc_end244-parse_path83.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.5
	.type	parse_path83.cold.5,@function
parse_path83.cold.5:                    # @parse_path83.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.122(%rip), %rdi
	callq	die
.Lfunc_end245:
	.size	parse_path83.cold.5, .Lfunc_end245-parse_path83.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.6
	.type	parse_path83.cold.6,@function
parse_path83.cold.6:                    # @parse_path83.cold.6
# %bb.0:
	pushq	%rax
	leaq	.L.str.121(%rip), %rdi
	callq	die
.Lfunc_end246:
	.size	parse_path83.cold.6, .Lfunc_end246-parse_path83.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.7
	.type	parse_path83.cold.7,@function
parse_path83.cold.7:                    # @parse_path83.cold.7
# %bb.0:
	pushq	%rax
	leaq	.L.str.116(%rip), %rdi
	callq	die
.Lfunc_end247:
	.size	parse_path83.cold.7, .Lfunc_end247-parse_path83.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.1
	.type	fat83_from_display_component.cold.1,@function
fat83_from_display_component.cold.1:    # @fat83_from_display_component.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.124(%rip), %rdi
	callq	die
.Lfunc_end248:
	.size	fat83_from_display_component.cold.1, .Lfunc_end248-fat83_from_display_component.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.2
	.type	fat83_from_display_component.cold.2,@function
fat83_from_display_component.cold.2:    # @fat83_from_display_component.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.125(%rip), %rdi
	callq	die
.Lfunc_end249:
	.size	fat83_from_display_component.cold.2, .Lfunc_end249-fat83_from_display_component.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.3
	.type	fat83_from_display_component.cold.3,@function
fat83_from_display_component.cold.3:    # @fat83_from_display_component.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.126(%rip), %rdi
	callq	die
.Lfunc_end250:
	.size	fat83_from_display_component.cold.3, .Lfunc_end250-fat83_from_display_component.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.4
	.type	fat83_from_display_component.cold.4,@function
fat83_from_display_component.cold.4:    # @fat83_from_display_component.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.123(%rip), %rdi
	callq	die
.Lfunc_end251:
	.size	fat83_from_display_component.cold.4, .Lfunc_end251-fat83_from_display_component.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_directory.cold.1
	.type	inspect_directory.cold.1,@function
inspect_directory.cold.1:               # @inspect_directory.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.145(%rip), %rdi
	callq	die
.Lfunc_end252:
	.size	inspect_directory.cold.1, .Lfunc_end252-inspect_directory.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.1
	.type	inspect_pi4_manifest.cold.1,@function
inspect_pi4_manifest.cold.1:            # @inspect_pi4_manifest.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end253:
	.size	inspect_pi4_manifest.cold.1, .Lfunc_end253-inspect_pi4_manifest.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.2
	.type	inspect_pi4_manifest.cold.2,@function
inspect_pi4_manifest.cold.2:            # @inspect_pi4_manifest.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end254:
	.size	inspect_pi4_manifest.cold.2, .Lfunc_end254-inspect_pi4_manifest.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.3
	.type	inspect_pi4_manifest.cold.3,@function
inspect_pi4_manifest.cold.3:            # @inspect_pi4_manifest.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.244(%rip), %rdi
	callq	die
.Lfunc_end255:
	.size	inspect_pi4_manifest.cold.3, .Lfunc_end255-inspect_pi4_manifest.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.4
	.type	inspect_pi4_manifest.cold.4,@function
inspect_pi4_manifest.cold.4:            # @inspect_pi4_manifest.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.244(%rip), %rdi
	callq	die
.Lfunc_end256:
	.size	inspect_pi4_manifest.cold.4, .Lfunc_end256-inspect_pi4_manifest.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.5
	.type	inspect_pi4_manifest.cold.5,@function
inspect_pi4_manifest.cold.5:            # @inspect_pi4_manifest.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.244(%rip), %rdi
	callq	die
.Lfunc_end257:
	.size	inspect_pi4_manifest.cold.5, .Lfunc_end257-inspect_pi4_manifest.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.6
	.type	inspect_pi4_manifest.cold.6,@function
inspect_pi4_manifest.cold.6:            # @inspect_pi4_manifest.cold.6
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end258:
	.size	inspect_pi4_manifest.cold.6, .Lfunc_end258-inspect_pi4_manifest.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.7
	.type	inspect_pi4_manifest.cold.7,@function
inspect_pi4_manifest.cold.7:            # @inspect_pi4_manifest.cold.7
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end259:
	.size	inspect_pi4_manifest.cold.7, .Lfunc_end259-inspect_pi4_manifest.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.8
	.type	inspect_pi4_manifest.cold.8,@function
inspect_pi4_manifest.cold.8:            # @inspect_pi4_manifest.cold.8
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end260:
	.size	inspect_pi4_manifest.cold.8, .Lfunc_end260-inspect_pi4_manifest.cold.8
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.9
	.type	inspect_pi4_manifest.cold.9,@function
inspect_pi4_manifest.cold.9:            # @inspect_pi4_manifest.cold.9
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end261:
	.size	inspect_pi4_manifest.cold.9, .Lfunc_end261-inspect_pi4_manifest.cold.9
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.10
	.type	inspect_pi4_manifest.cold.10,@function
inspect_pi4_manifest.cold.10:           # @inspect_pi4_manifest.cold.10
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end262:
	.size	inspect_pi4_manifest.cold.10, .Lfunc_end262-inspect_pi4_manifest.cold.10
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.11
	.type	inspect_pi4_manifest.cold.11,@function
inspect_pi4_manifest.cold.11:           # @inspect_pi4_manifest.cold.11
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end263:
	.size	inspect_pi4_manifest.cold.11, .Lfunc_end263-inspect_pi4_manifest.cold.11
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.12
	.type	inspect_pi4_manifest.cold.12,@function
inspect_pi4_manifest.cold.12:           # @inspect_pi4_manifest.cold.12
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end264:
	.size	inspect_pi4_manifest.cold.12, .Lfunc_end264-inspect_pi4_manifest.cold.12
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.13
	.type	inspect_pi4_manifest.cold.13,@function
inspect_pi4_manifest.cold.13:           # @inspect_pi4_manifest.cold.13
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end265:
	.size	inspect_pi4_manifest.cold.13, .Lfunc_end265-inspect_pi4_manifest.cold.13
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.14
	.type	inspect_pi4_manifest.cold.14,@function
inspect_pi4_manifest.cold.14:           # @inspect_pi4_manifest.cold.14
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end266:
	.size	inspect_pi4_manifest.cold.14, .Lfunc_end266-inspect_pi4_manifest.cold.14
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.15
	.type	inspect_pi4_manifest.cold.15,@function
inspect_pi4_manifest.cold.15:           # @inspect_pi4_manifest.cold.15
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end267:
	.size	inspect_pi4_manifest.cold.15, .Lfunc_end267-inspect_pi4_manifest.cold.15
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.16
	.type	inspect_pi4_manifest.cold.16,@function
inspect_pi4_manifest.cold.16:           # @inspect_pi4_manifest.cold.16
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end268:
	.size	inspect_pi4_manifest.cold.16, .Lfunc_end268-inspect_pi4_manifest.cold.16
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.17
	.type	inspect_pi4_manifest.cold.17,@function
inspect_pi4_manifest.cold.17:           # @inspect_pi4_manifest.cold.17
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end269:
	.size	inspect_pi4_manifest.cold.17, .Lfunc_end269-inspect_pi4_manifest.cold.17
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.18
	.type	inspect_pi4_manifest.cold.18,@function
inspect_pi4_manifest.cold.18:           # @inspect_pi4_manifest.cold.18
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end270:
	.size	inspect_pi4_manifest.cold.18, .Lfunc_end270-inspect_pi4_manifest.cold.18
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.19
	.type	inspect_pi4_manifest.cold.19,@function
inspect_pi4_manifest.cold.19:           # @inspect_pi4_manifest.cold.19
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end271:
	.size	inspect_pi4_manifest.cold.19, .Lfunc_end271-inspect_pi4_manifest.cold.19
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.20
	.type	inspect_pi4_manifest.cold.20,@function
inspect_pi4_manifest.cold.20:           # @inspect_pi4_manifest.cold.20
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end272:
	.size	inspect_pi4_manifest.cold.20, .Lfunc_end272-inspect_pi4_manifest.cold.20
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.21
	.type	inspect_pi4_manifest.cold.21,@function
inspect_pi4_manifest.cold.21:           # @inspect_pi4_manifest.cold.21
# %bb.0:
	pushq	%rax
	leaq	.L.str.253(%rip), %rdi
	callq	die
.Lfunc_end273:
	.size	inspect_pi4_manifest.cold.21, .Lfunc_end273-inspect_pi4_manifest.cold.21
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.22
	.type	inspect_pi4_manifest.cold.22,@function
inspect_pi4_manifest.cold.22:           # @inspect_pi4_manifest.cold.22
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end274:
	.size	inspect_pi4_manifest.cold.22, .Lfunc_end274-inspect_pi4_manifest.cold.22
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.23
	.type	inspect_pi4_manifest.cold.23,@function
inspect_pi4_manifest.cold.23:           # @inspect_pi4_manifest.cold.23
# %bb.0:
	pushq	%rax
	leaq	.L.str.253(%rip), %rdi
	callq	die
.Lfunc_end275:
	.size	inspect_pi4_manifest.cold.23, .Lfunc_end275-inspect_pi4_manifest.cold.23
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.24
	.type	inspect_pi4_manifest.cold.24,@function
inspect_pi4_manifest.cold.24:           # @inspect_pi4_manifest.cold.24
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end276:
	.size	inspect_pi4_manifest.cold.24, .Lfunc_end276-inspect_pi4_manifest.cold.24
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.25
	.type	inspect_pi4_manifest.cold.25,@function
inspect_pi4_manifest.cold.25:           # @inspect_pi4_manifest.cold.25
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end277:
	.size	inspect_pi4_manifest.cold.25, .Lfunc_end277-inspect_pi4_manifest.cold.25
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.26
	.type	inspect_pi4_manifest.cold.26,@function
inspect_pi4_manifest.cold.26:           # @inspect_pi4_manifest.cold.26
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end278:
	.size	inspect_pi4_manifest.cold.26, .Lfunc_end278-inspect_pi4_manifest.cold.26
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.27
	.type	inspect_pi4_manifest.cold.27,@function
inspect_pi4_manifest.cold.27:           # @inspect_pi4_manifest.cold.27
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end279:
	.size	inspect_pi4_manifest.cold.27, .Lfunc_end279-inspect_pi4_manifest.cold.27
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.28
	.type	inspect_pi4_manifest.cold.28,@function
inspect_pi4_manifest.cold.28:           # @inspect_pi4_manifest.cold.28
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end280:
	.size	inspect_pi4_manifest.cold.28, .Lfunc_end280-inspect_pi4_manifest.cold.28
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.29
	.type	inspect_pi4_manifest.cold.29,@function
inspect_pi4_manifest.cold.29:           # @inspect_pi4_manifest.cold.29
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end281:
	.size	inspect_pi4_manifest.cold.29, .Lfunc_end281-inspect_pi4_manifest.cold.29
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.30
	.type	inspect_pi4_manifest.cold.30,@function
inspect_pi4_manifest.cold.30:           # @inspect_pi4_manifest.cold.30
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end282:
	.size	inspect_pi4_manifest.cold.30, .Lfunc_end282-inspect_pi4_manifest.cold.30
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.31
	.type	inspect_pi4_manifest.cold.31,@function
inspect_pi4_manifest.cold.31:           # @inspect_pi4_manifest.cold.31
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end283:
	.size	inspect_pi4_manifest.cold.31, .Lfunc_end283-inspect_pi4_manifest.cold.31
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.32
	.type	inspect_pi4_manifest.cold.32,@function
inspect_pi4_manifest.cold.32:           # @inspect_pi4_manifest.cold.32
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end284:
	.size	inspect_pi4_manifest.cold.32, .Lfunc_end284-inspect_pi4_manifest.cold.32
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.33
	.type	inspect_pi4_manifest.cold.33,@function
inspect_pi4_manifest.cold.33:           # @inspect_pi4_manifest.cold.33
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end285:
	.size	inspect_pi4_manifest.cold.33, .Lfunc_end285-inspect_pi4_manifest.cold.33
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.34
	.type	inspect_pi4_manifest.cold.34,@function
inspect_pi4_manifest.cold.34:           # @inspect_pi4_manifest.cold.34
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end286:
	.size	inspect_pi4_manifest.cold.34, .Lfunc_end286-inspect_pi4_manifest.cold.34
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.35
	.type	inspect_pi4_manifest.cold.35,@function
inspect_pi4_manifest.cold.35:           # @inspect_pi4_manifest.cold.35
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end287:
	.size	inspect_pi4_manifest.cold.35, .Lfunc_end287-inspect_pi4_manifest.cold.35
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.36
	.type	inspect_pi4_manifest.cold.36,@function
inspect_pi4_manifest.cold.36:           # @inspect_pi4_manifest.cold.36
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end288:
	.size	inspect_pi4_manifest.cold.36, .Lfunc_end288-inspect_pi4_manifest.cold.36
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.37
	.type	inspect_pi4_manifest.cold.37,@function
inspect_pi4_manifest.cold.37:           # @inspect_pi4_manifest.cold.37
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end289:
	.size	inspect_pi4_manifest.cold.37, .Lfunc_end289-inspect_pi4_manifest.cold.37
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.38
	.type	inspect_pi4_manifest.cold.38,@function
inspect_pi4_manifest.cold.38:           # @inspect_pi4_manifest.cold.38
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end290:
	.size	inspect_pi4_manifest.cold.38, .Lfunc_end290-inspect_pi4_manifest.cold.38
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.39
	.type	inspect_pi4_manifest.cold.39,@function
inspect_pi4_manifest.cold.39:           # @inspect_pi4_manifest.cold.39
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end291:
	.size	inspect_pi4_manifest.cold.39, .Lfunc_end291-inspect_pi4_manifest.cold.39
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.40
	.type	inspect_pi4_manifest.cold.40,@function
inspect_pi4_manifest.cold.40:           # @inspect_pi4_manifest.cold.40
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end292:
	.size	inspect_pi4_manifest.cold.40, .Lfunc_end292-inspect_pi4_manifest.cold.40
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.41
	.type	inspect_pi4_manifest.cold.41,@function
inspect_pi4_manifest.cold.41:           # @inspect_pi4_manifest.cold.41
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end293:
	.size	inspect_pi4_manifest.cold.41, .Lfunc_end293-inspect_pi4_manifest.cold.41
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.42
	.type	inspect_pi4_manifest.cold.42,@function
inspect_pi4_manifest.cold.42:           # @inspect_pi4_manifest.cold.42
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end294:
	.size	inspect_pi4_manifest.cold.42, .Lfunc_end294-inspect_pi4_manifest.cold.42
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.43
	.type	inspect_pi4_manifest.cold.43,@function
inspect_pi4_manifest.cold.43:           # @inspect_pi4_manifest.cold.43
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end295:
	.size	inspect_pi4_manifest.cold.43, .Lfunc_end295-inspect_pi4_manifest.cold.43
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.44
	.type	inspect_pi4_manifest.cold.44,@function
inspect_pi4_manifest.cold.44:           # @inspect_pi4_manifest.cold.44
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end296:
	.size	inspect_pi4_manifest.cold.44, .Lfunc_end296-inspect_pi4_manifest.cold.44
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.45
	.type	inspect_pi4_manifest.cold.45,@function
inspect_pi4_manifest.cold.45:           # @inspect_pi4_manifest.cold.45
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end297:
	.size	inspect_pi4_manifest.cold.45, .Lfunc_end297-inspect_pi4_manifest.cold.45
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.46
	.type	inspect_pi4_manifest.cold.46,@function
inspect_pi4_manifest.cold.46:           # @inspect_pi4_manifest.cold.46
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end298:
	.size	inspect_pi4_manifest.cold.46, .Lfunc_end298-inspect_pi4_manifest.cold.46
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.47
	.type	inspect_pi4_manifest.cold.47,@function
inspect_pi4_manifest.cold.47:           # @inspect_pi4_manifest.cold.47
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end299:
	.size	inspect_pi4_manifest.cold.47, .Lfunc_end299-inspect_pi4_manifest.cold.47
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.48
	.type	inspect_pi4_manifest.cold.48,@function
inspect_pi4_manifest.cold.48:           # @inspect_pi4_manifest.cold.48
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end300:
	.size	inspect_pi4_manifest.cold.48, .Lfunc_end300-inspect_pi4_manifest.cold.48
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.49
	.type	inspect_pi4_manifest.cold.49,@function
inspect_pi4_manifest.cold.49:           # @inspect_pi4_manifest.cold.49
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end301:
	.size	inspect_pi4_manifest.cold.49, .Lfunc_end301-inspect_pi4_manifest.cold.49
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.50
	.type	inspect_pi4_manifest.cold.50,@function
inspect_pi4_manifest.cold.50:           # @inspect_pi4_manifest.cold.50
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end302:
	.size	inspect_pi4_manifest.cold.50, .Lfunc_end302-inspect_pi4_manifest.cold.50
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.51
	.type	inspect_pi4_manifest.cold.51,@function
inspect_pi4_manifest.cold.51:           # @inspect_pi4_manifest.cold.51
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end303:
	.size	inspect_pi4_manifest.cold.51, .Lfunc_end303-inspect_pi4_manifest.cold.51
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.52
	.type	inspect_pi4_manifest.cold.52,@function
inspect_pi4_manifest.cold.52:           # @inspect_pi4_manifest.cold.52
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end304:
	.size	inspect_pi4_manifest.cold.52, .Lfunc_end304-inspect_pi4_manifest.cold.52
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.53
	.type	inspect_pi4_manifest.cold.53,@function
inspect_pi4_manifest.cold.53:           # @inspect_pi4_manifest.cold.53
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end305:
	.size	inspect_pi4_manifest.cold.53, .Lfunc_end305-inspect_pi4_manifest.cold.53
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.54
	.type	inspect_pi4_manifest.cold.54,@function
inspect_pi4_manifest.cold.54:           # @inspect_pi4_manifest.cold.54
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end306:
	.size	inspect_pi4_manifest.cold.54, .Lfunc_end306-inspect_pi4_manifest.cold.54
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.55
	.type	inspect_pi4_manifest.cold.55,@function
inspect_pi4_manifest.cold.55:           # @inspect_pi4_manifest.cold.55
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end307:
	.size	inspect_pi4_manifest.cold.55, .Lfunc_end307-inspect_pi4_manifest.cold.55
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.56
	.type	inspect_pi4_manifest.cold.56,@function
inspect_pi4_manifest.cold.56:           # @inspect_pi4_manifest.cold.56
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end308:
	.size	inspect_pi4_manifest.cold.56, .Lfunc_end308-inspect_pi4_manifest.cold.56
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.57
	.type	inspect_pi4_manifest.cold.57,@function
inspect_pi4_manifest.cold.57:           # @inspect_pi4_manifest.cold.57
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end309:
	.size	inspect_pi4_manifest.cold.57, .Lfunc_end309-inspect_pi4_manifest.cold.57
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.58
	.type	inspect_pi4_manifest.cold.58,@function
inspect_pi4_manifest.cold.58:           # @inspect_pi4_manifest.cold.58
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end310:
	.size	inspect_pi4_manifest.cold.58, .Lfunc_end310-inspect_pi4_manifest.cold.58
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.59
	.type	inspect_pi4_manifest.cold.59,@function
inspect_pi4_manifest.cold.59:           # @inspect_pi4_manifest.cold.59
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end311:
	.size	inspect_pi4_manifest.cold.59, .Lfunc_end311-inspect_pi4_manifest.cold.59
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.60
	.type	inspect_pi4_manifest.cold.60,@function
inspect_pi4_manifest.cold.60:           # @inspect_pi4_manifest.cold.60
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end312:
	.size	inspect_pi4_manifest.cold.60, .Lfunc_end312-inspect_pi4_manifest.cold.60
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.61
	.type	inspect_pi4_manifest.cold.61,@function
inspect_pi4_manifest.cold.61:           # @inspect_pi4_manifest.cold.61
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end313:
	.size	inspect_pi4_manifest.cold.61, .Lfunc_end313-inspect_pi4_manifest.cold.61
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.62
	.type	inspect_pi4_manifest.cold.62,@function
inspect_pi4_manifest.cold.62:           # @inspect_pi4_manifest.cold.62
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end314:
	.size	inspect_pi4_manifest.cold.62, .Lfunc_end314-inspect_pi4_manifest.cold.62
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.63
	.type	inspect_pi4_manifest.cold.63,@function
inspect_pi4_manifest.cold.63:           # @inspect_pi4_manifest.cold.63
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end315:
	.size	inspect_pi4_manifest.cold.63, .Lfunc_end315-inspect_pi4_manifest.cold.63
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.64
	.type	inspect_pi4_manifest.cold.64,@function
inspect_pi4_manifest.cold.64:           # @inspect_pi4_manifest.cold.64
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end316:
	.size	inspect_pi4_manifest.cold.64, .Lfunc_end316-inspect_pi4_manifest.cold.64
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.65
	.type	inspect_pi4_manifest.cold.65,@function
inspect_pi4_manifest.cold.65:           # @inspect_pi4_manifest.cold.65
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end317:
	.size	inspect_pi4_manifest.cold.65, .Lfunc_end317-inspect_pi4_manifest.cold.65
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.66
	.type	inspect_pi4_manifest.cold.66,@function
inspect_pi4_manifest.cold.66:           # @inspect_pi4_manifest.cold.66
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end318:
	.size	inspect_pi4_manifest.cold.66, .Lfunc_end318-inspect_pi4_manifest.cold.66
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.67
	.type	inspect_pi4_manifest.cold.67,@function
inspect_pi4_manifest.cold.67:           # @inspect_pi4_manifest.cold.67
# %bb.0:
	pushq	%rax
	leaq	.L.str.204(%rip), %rdi
	callq	die
.Lfunc_end319:
	.size	inspect_pi4_manifest.cold.67, .Lfunc_end319-inspect_pi4_manifest.cold.67
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.68
	.type	inspect_pi4_manifest.cold.68,@function
inspect_pi4_manifest.cold.68:           # @inspect_pi4_manifest.cold.68
# %bb.0:
	pushq	%rax
	leaq	.L.str.203(%rip), %rdi
	callq	die
.Lfunc_end320:
	.size	inspect_pi4_manifest.cold.68, .Lfunc_end320-inspect_pi4_manifest.cold.68
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.69
	.type	inspect_pi4_manifest.cold.69,@function
inspect_pi4_manifest.cold.69:           # @inspect_pi4_manifest.cold.69
# %bb.0:
	pushq	%rax
	leaq	.L.str.200(%rip), %rdi
	callq	die
.Lfunc_end321:
	.size	inspect_pi4_manifest.cold.69, .Lfunc_end321-inspect_pi4_manifest.cold.69
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.70
	.type	inspect_pi4_manifest.cold.70,@function
inspect_pi4_manifest.cold.70:           # @inspect_pi4_manifest.cold.70
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end322:
	.size	inspect_pi4_manifest.cold.70, .Lfunc_end322-inspect_pi4_manifest.cold.70
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.71
	.type	inspect_pi4_manifest.cold.71,@function
inspect_pi4_manifest.cold.71:           # @inspect_pi4_manifest.cold.71
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end323:
	.size	inspect_pi4_manifest.cold.71, .Lfunc_end323-inspect_pi4_manifest.cold.71
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.72
	.type	inspect_pi4_manifest.cold.72,@function
inspect_pi4_manifest.cold.72:           # @inspect_pi4_manifest.cold.72
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end324:
	.size	inspect_pi4_manifest.cold.72, .Lfunc_end324-inspect_pi4_manifest.cold.72
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.73
	.type	inspect_pi4_manifest.cold.73,@function
inspect_pi4_manifest.cold.73:           # @inspect_pi4_manifest.cold.73
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end325:
	.size	inspect_pi4_manifest.cold.73, .Lfunc_end325-inspect_pi4_manifest.cold.73
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.74
	.type	inspect_pi4_manifest.cold.74,@function
inspect_pi4_manifest.cold.74:           # @inspect_pi4_manifest.cold.74
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end326:
	.size	inspect_pi4_manifest.cold.74, .Lfunc_end326-inspect_pi4_manifest.cold.74
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.75
	.type	inspect_pi4_manifest.cold.75,@function
inspect_pi4_manifest.cold.75:           # @inspect_pi4_manifest.cold.75
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end327:
	.size	inspect_pi4_manifest.cold.75, .Lfunc_end327-inspect_pi4_manifest.cold.75
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.76
	.type	inspect_pi4_manifest.cold.76,@function
inspect_pi4_manifest.cold.76:           # @inspect_pi4_manifest.cold.76
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end328:
	.size	inspect_pi4_manifest.cold.76, .Lfunc_end328-inspect_pi4_manifest.cold.76
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.77
	.type	inspect_pi4_manifest.cold.77,@function
inspect_pi4_manifest.cold.77:           # @inspect_pi4_manifest.cold.77
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end329:
	.size	inspect_pi4_manifest.cold.77, .Lfunc_end329-inspect_pi4_manifest.cold.77
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.78
	.type	inspect_pi4_manifest.cold.78,@function
inspect_pi4_manifest.cold.78:           # @inspect_pi4_manifest.cold.78
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end330:
	.size	inspect_pi4_manifest.cold.78, .Lfunc_end330-inspect_pi4_manifest.cold.78
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.79
	.type	inspect_pi4_manifest.cold.79,@function
inspect_pi4_manifest.cold.79:           # @inspect_pi4_manifest.cold.79
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end331:
	.size	inspect_pi4_manifest.cold.79, .Lfunc_end331-inspect_pi4_manifest.cold.79
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.80
	.type	inspect_pi4_manifest.cold.80,@function
inspect_pi4_manifest.cold.80:           # @inspect_pi4_manifest.cold.80
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end332:
	.size	inspect_pi4_manifest.cold.80, .Lfunc_end332-inspect_pi4_manifest.cold.80
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.81
	.type	inspect_pi4_manifest.cold.81,@function
inspect_pi4_manifest.cold.81:           # @inspect_pi4_manifest.cold.81
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end333:
	.size	inspect_pi4_manifest.cold.81, .Lfunc_end333-inspect_pi4_manifest.cold.81
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.82
	.type	inspect_pi4_manifest.cold.82,@function
inspect_pi4_manifest.cold.82:           # @inspect_pi4_manifest.cold.82
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end334:
	.size	inspect_pi4_manifest.cold.82, .Lfunc_end334-inspect_pi4_manifest.cold.82
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.83
	.type	inspect_pi4_manifest.cold.83,@function
inspect_pi4_manifest.cold.83:           # @inspect_pi4_manifest.cold.83
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end335:
	.size	inspect_pi4_manifest.cold.83, .Lfunc_end335-inspect_pi4_manifest.cold.83
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.84
	.type	inspect_pi4_manifest.cold.84,@function
inspect_pi4_manifest.cold.84:           # @inspect_pi4_manifest.cold.84
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end336:
	.size	inspect_pi4_manifest.cold.84, .Lfunc_end336-inspect_pi4_manifest.cold.84
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.85
	.type	inspect_pi4_manifest.cold.85,@function
inspect_pi4_manifest.cold.85:           # @inspect_pi4_manifest.cold.85
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end337:
	.size	inspect_pi4_manifest.cold.85, .Lfunc_end337-inspect_pi4_manifest.cold.85
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.86
	.type	inspect_pi4_manifest.cold.86,@function
inspect_pi4_manifest.cold.86:           # @inspect_pi4_manifest.cold.86
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end338:
	.size	inspect_pi4_manifest.cold.86, .Lfunc_end338-inspect_pi4_manifest.cold.86
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.87
	.type	inspect_pi4_manifest.cold.87,@function
inspect_pi4_manifest.cold.87:           # @inspect_pi4_manifest.cold.87
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end339:
	.size	inspect_pi4_manifest.cold.87, .Lfunc_end339-inspect_pi4_manifest.cold.87
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.88
	.type	inspect_pi4_manifest.cold.88,@function
inspect_pi4_manifest.cold.88:           # @inspect_pi4_manifest.cold.88
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end340:
	.size	inspect_pi4_manifest.cold.88, .Lfunc_end340-inspect_pi4_manifest.cold.88
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.89
	.type	inspect_pi4_manifest.cold.89,@function
inspect_pi4_manifest.cold.89:           # @inspect_pi4_manifest.cold.89
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end341:
	.size	inspect_pi4_manifest.cold.89, .Lfunc_end341-inspect_pi4_manifest.cold.89
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.90
	.type	inspect_pi4_manifest.cold.90,@function
inspect_pi4_manifest.cold.90:           # @inspect_pi4_manifest.cold.90
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end342:
	.size	inspect_pi4_manifest.cold.90, .Lfunc_end342-inspect_pi4_manifest.cold.90
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.91
	.type	inspect_pi4_manifest.cold.91,@function
inspect_pi4_manifest.cold.91:           # @inspect_pi4_manifest.cold.91
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end343:
	.size	inspect_pi4_manifest.cold.91, .Lfunc_end343-inspect_pi4_manifest.cold.91
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.92
	.type	inspect_pi4_manifest.cold.92,@function
inspect_pi4_manifest.cold.92:           # @inspect_pi4_manifest.cold.92
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end344:
	.size	inspect_pi4_manifest.cold.92, .Lfunc_end344-inspect_pi4_manifest.cold.92
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.93
	.type	inspect_pi4_manifest.cold.93,@function
inspect_pi4_manifest.cold.93:           # @inspect_pi4_manifest.cold.93
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end345:
	.size	inspect_pi4_manifest.cold.93, .Lfunc_end345-inspect_pi4_manifest.cold.93
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.94
	.type	inspect_pi4_manifest.cold.94,@function
inspect_pi4_manifest.cold.94:           # @inspect_pi4_manifest.cold.94
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end346:
	.size	inspect_pi4_manifest.cold.94, .Lfunc_end346-inspect_pi4_manifest.cold.94
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.95
	.type	inspect_pi4_manifest.cold.95,@function
inspect_pi4_manifest.cold.95:           # @inspect_pi4_manifest.cold.95
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end347:
	.size	inspect_pi4_manifest.cold.95, .Lfunc_end347-inspect_pi4_manifest.cold.95
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.96
	.type	inspect_pi4_manifest.cold.96,@function
inspect_pi4_manifest.cold.96:           # @inspect_pi4_manifest.cold.96
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end348:
	.size	inspect_pi4_manifest.cold.96, .Lfunc_end348-inspect_pi4_manifest.cold.96
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.97
	.type	inspect_pi4_manifest.cold.97,@function
inspect_pi4_manifest.cold.97:           # @inspect_pi4_manifest.cold.97
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end349:
	.size	inspect_pi4_manifest.cold.97, .Lfunc_end349-inspect_pi4_manifest.cold.97
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.98
	.type	inspect_pi4_manifest.cold.98,@function
inspect_pi4_manifest.cold.98:           # @inspect_pi4_manifest.cold.98
# %bb.0:
	pushq	%rax
	leaq	.L.str.297(%rip), %rdi
	callq	die
.Lfunc_end350:
	.size	inspect_pi4_manifest.cold.98, .Lfunc_end350-inspect_pi4_manifest.cold.98
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.99
	.type	inspect_pi4_manifest.cold.99,@function
inspect_pi4_manifest.cold.99:           # @inspect_pi4_manifest.cold.99
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end351:
	.size	inspect_pi4_manifest.cold.99, .Lfunc_end351-inspect_pi4_manifest.cold.99
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.100
	.type	inspect_pi4_manifest.cold.100,@function
inspect_pi4_manifest.cold.100:          # @inspect_pi4_manifest.cold.100
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end352:
	.size	inspect_pi4_manifest.cold.100, .Lfunc_end352-inspect_pi4_manifest.cold.100
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.101
	.type	inspect_pi4_manifest.cold.101,@function
inspect_pi4_manifest.cold.101:          # @inspect_pi4_manifest.cold.101
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end353:
	.size	inspect_pi4_manifest.cold.101, .Lfunc_end353-inspect_pi4_manifest.cold.101
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.102
	.type	inspect_pi4_manifest.cold.102,@function
inspect_pi4_manifest.cold.102:          # @inspect_pi4_manifest.cold.102
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end354:
	.size	inspect_pi4_manifest.cold.102, .Lfunc_end354-inspect_pi4_manifest.cold.102
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.103
	.type	inspect_pi4_manifest.cold.103,@function
inspect_pi4_manifest.cold.103:          # @inspect_pi4_manifest.cold.103
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end355:
	.size	inspect_pi4_manifest.cold.103, .Lfunc_end355-inspect_pi4_manifest.cold.103
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.104
	.type	inspect_pi4_manifest.cold.104,@function
inspect_pi4_manifest.cold.104:          # @inspect_pi4_manifest.cold.104
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end356:
	.size	inspect_pi4_manifest.cold.104, .Lfunc_end356-inspect_pi4_manifest.cold.104
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.105
	.type	inspect_pi4_manifest.cold.105,@function
inspect_pi4_manifest.cold.105:          # @inspect_pi4_manifest.cold.105
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end357:
	.size	inspect_pi4_manifest.cold.105, .Lfunc_end357-inspect_pi4_manifest.cold.105
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.106
	.type	inspect_pi4_manifest.cold.106,@function
inspect_pi4_manifest.cold.106:          # @inspect_pi4_manifest.cold.106
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end358:
	.size	inspect_pi4_manifest.cold.106, .Lfunc_end358-inspect_pi4_manifest.cold.106
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.107
	.type	inspect_pi4_manifest.cold.107,@function
inspect_pi4_manifest.cold.107:          # @inspect_pi4_manifest.cold.107
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end359:
	.size	inspect_pi4_manifest.cold.107, .Lfunc_end359-inspect_pi4_manifest.cold.107
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.108
	.type	inspect_pi4_manifest.cold.108,@function
inspect_pi4_manifest.cold.108:          # @inspect_pi4_manifest.cold.108
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end360:
	.size	inspect_pi4_manifest.cold.108, .Lfunc_end360-inspect_pi4_manifest.cold.108
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.109
	.type	inspect_pi4_manifest.cold.109,@function
inspect_pi4_manifest.cold.109:          # @inspect_pi4_manifest.cold.109
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end361:
	.size	inspect_pi4_manifest.cold.109, .Lfunc_end361-inspect_pi4_manifest.cold.109
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.110
	.type	inspect_pi4_manifest.cold.110,@function
inspect_pi4_manifest.cold.110:          # @inspect_pi4_manifest.cold.110
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end362:
	.size	inspect_pi4_manifest.cold.110, .Lfunc_end362-inspect_pi4_manifest.cold.110
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.111
	.type	inspect_pi4_manifest.cold.111,@function
inspect_pi4_manifest.cold.111:          # @inspect_pi4_manifest.cold.111
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end363:
	.size	inspect_pi4_manifest.cold.111, .Lfunc_end363-inspect_pi4_manifest.cold.111
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.112
	.type	inspect_pi4_manifest.cold.112,@function
inspect_pi4_manifest.cold.112:          # @inspect_pi4_manifest.cold.112
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end364:
	.size	inspect_pi4_manifest.cold.112, .Lfunc_end364-inspect_pi4_manifest.cold.112
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.113
	.type	inspect_pi4_manifest.cold.113,@function
inspect_pi4_manifest.cold.113:          # @inspect_pi4_manifest.cold.113
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end365:
	.size	inspect_pi4_manifest.cold.113, .Lfunc_end365-inspect_pi4_manifest.cold.113
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.114
	.type	inspect_pi4_manifest.cold.114,@function
inspect_pi4_manifest.cold.114:          # @inspect_pi4_manifest.cold.114
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end366:
	.size	inspect_pi4_manifest.cold.114, .Lfunc_end366-inspect_pi4_manifest.cold.114
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.115
	.type	inspect_pi4_manifest.cold.115,@function
inspect_pi4_manifest.cold.115:          # @inspect_pi4_manifest.cold.115
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end367:
	.size	inspect_pi4_manifest.cold.115, .Lfunc_end367-inspect_pi4_manifest.cold.115
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.116
	.type	inspect_pi4_manifest.cold.116,@function
inspect_pi4_manifest.cold.116:          # @inspect_pi4_manifest.cold.116
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end368:
	.size	inspect_pi4_manifest.cold.116, .Lfunc_end368-inspect_pi4_manifest.cold.116
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.117
	.type	inspect_pi4_manifest.cold.117,@function
inspect_pi4_manifest.cold.117:          # @inspect_pi4_manifest.cold.117
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end369:
	.size	inspect_pi4_manifest.cold.117, .Lfunc_end369-inspect_pi4_manifest.cold.117
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.118
	.type	inspect_pi4_manifest.cold.118,@function
inspect_pi4_manifest.cold.118:          # @inspect_pi4_manifest.cold.118
# %bb.0:
	pushq	%rax
	leaq	.L.str.234(%rip), %rdi
	callq	die
.Lfunc_end370:
	.size	inspect_pi4_manifest.cold.118, .Lfunc_end370-inspect_pi4_manifest.cold.118
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.119
	.type	inspect_pi4_manifest.cold.119,@function
inspect_pi4_manifest.cold.119:          # @inspect_pi4_manifest.cold.119
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end371:
	.size	inspect_pi4_manifest.cold.119, .Lfunc_end371-inspect_pi4_manifest.cold.119
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.120
	.type	inspect_pi4_manifest.cold.120,@function
inspect_pi4_manifest.cold.120:          # @inspect_pi4_manifest.cold.120
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end372:
	.size	inspect_pi4_manifest.cold.120, .Lfunc_end372-inspect_pi4_manifest.cold.120
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.121
	.type	inspect_pi4_manifest.cold.121,@function
inspect_pi4_manifest.cold.121:          # @inspect_pi4_manifest.cold.121
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end373:
	.size	inspect_pi4_manifest.cold.121, .Lfunc_end373-inspect_pi4_manifest.cold.121
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.122
	.type	inspect_pi4_manifest.cold.122,@function
inspect_pi4_manifest.cold.122:          # @inspect_pi4_manifest.cold.122
# %bb.0:
	pushq	%rax
	leaq	.L.str.243(%rip), %rdi
	callq	die
.Lfunc_end374:
	.size	inspect_pi4_manifest.cold.122, .Lfunc_end374-inspect_pi4_manifest.cold.122
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.123
	.type	inspect_pi4_manifest.cold.123,@function
inspect_pi4_manifest.cold.123:          # @inspect_pi4_manifest.cold.123
# %bb.0:
	pushq	%rax
	leaq	.L.str.236(%rip), %rdi
	callq	die
.Lfunc_end375:
	.size	inspect_pi4_manifest.cold.123, .Lfunc_end375-inspect_pi4_manifest.cold.123
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.124
	.type	inspect_pi4_manifest.cold.124,@function
inspect_pi4_manifest.cold.124:          # @inspect_pi4_manifest.cold.124
# %bb.0:
	pushq	%rax
	leaq	.L.str.237(%rip), %rdi
	callq	die
.Lfunc_end376:
	.size	inspect_pi4_manifest.cold.124, .Lfunc_end376-inspect_pi4_manifest.cold.124
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.125
	.type	inspect_pi4_manifest.cold.125,@function
inspect_pi4_manifest.cold.125:          # @inspect_pi4_manifest.cold.125
# %bb.0:
	pushq	%rax
	leaq	.L.str.238(%rip), %rdi
	callq	die
.Lfunc_end377:
	.size	inspect_pi4_manifest.cold.125, .Lfunc_end377-inspect_pi4_manifest.cold.125
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.126
	.type	inspect_pi4_manifest.cold.126,@function
inspect_pi4_manifest.cold.126:          # @inspect_pi4_manifest.cold.126
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end378:
	.size	inspect_pi4_manifest.cold.126, .Lfunc_end378-inspect_pi4_manifest.cold.126
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.127
	.type	inspect_pi4_manifest.cold.127,@function
inspect_pi4_manifest.cold.127:          # @inspect_pi4_manifest.cold.127
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end379:
	.size	inspect_pi4_manifest.cold.127, .Lfunc_end379-inspect_pi4_manifest.cold.127
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.128
	.type	inspect_pi4_manifest.cold.128,@function
inspect_pi4_manifest.cold.128:          # @inspect_pi4_manifest.cold.128
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end380:
	.size	inspect_pi4_manifest.cold.128, .Lfunc_end380-inspect_pi4_manifest.cold.128
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.129
	.type	inspect_pi4_manifest.cold.129,@function
inspect_pi4_manifest.cold.129:          # @inspect_pi4_manifest.cold.129
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end381:
	.size	inspect_pi4_manifest.cold.129, .Lfunc_end381-inspect_pi4_manifest.cold.129
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.130
	.type	inspect_pi4_manifest.cold.130,@function
inspect_pi4_manifest.cold.130:          # @inspect_pi4_manifest.cold.130
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end382:
	.size	inspect_pi4_manifest.cold.130, .Lfunc_end382-inspect_pi4_manifest.cold.130
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.131
	.type	inspect_pi4_manifest.cold.131,@function
inspect_pi4_manifest.cold.131:          # @inspect_pi4_manifest.cold.131
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end383:
	.size	inspect_pi4_manifest.cold.131, .Lfunc_end383-inspect_pi4_manifest.cold.131
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.132
	.type	inspect_pi4_manifest.cold.132,@function
inspect_pi4_manifest.cold.132:          # @inspect_pi4_manifest.cold.132
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end384:
	.size	inspect_pi4_manifest.cold.132, .Lfunc_end384-inspect_pi4_manifest.cold.132
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.133
	.type	inspect_pi4_manifest.cold.133,@function
inspect_pi4_manifest.cold.133:          # @inspect_pi4_manifest.cold.133
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end385:
	.size	inspect_pi4_manifest.cold.133, .Lfunc_end385-inspect_pi4_manifest.cold.133
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.134
	.type	inspect_pi4_manifest.cold.134,@function
inspect_pi4_manifest.cold.134:          # @inspect_pi4_manifest.cold.134
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end386:
	.size	inspect_pi4_manifest.cold.134, .Lfunc_end386-inspect_pi4_manifest.cold.134
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.135
	.type	inspect_pi4_manifest.cold.135,@function
inspect_pi4_manifest.cold.135:          # @inspect_pi4_manifest.cold.135
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end387:
	.size	inspect_pi4_manifest.cold.135, .Lfunc_end387-inspect_pi4_manifest.cold.135
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.136
	.type	inspect_pi4_manifest.cold.136,@function
inspect_pi4_manifest.cold.136:          # @inspect_pi4_manifest.cold.136
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end388:
	.size	inspect_pi4_manifest.cold.136, .Lfunc_end388-inspect_pi4_manifest.cold.136
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.137
	.type	inspect_pi4_manifest.cold.137,@function
inspect_pi4_manifest.cold.137:          # @inspect_pi4_manifest.cold.137
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end389:
	.size	inspect_pi4_manifest.cold.137, .Lfunc_end389-inspect_pi4_manifest.cold.137
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.138
	.type	inspect_pi4_manifest.cold.138,@function
inspect_pi4_manifest.cold.138:          # @inspect_pi4_manifest.cold.138
# %bb.0:
	pushq	%rax
	leaq	.L.str.225(%rip), %rdi
	callq	die
.Lfunc_end390:
	.size	inspect_pi4_manifest.cold.138, .Lfunc_end390-inspect_pi4_manifest.cold.138
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.139
	.type	inspect_pi4_manifest.cold.139,@function
inspect_pi4_manifest.cold.139:          # @inspect_pi4_manifest.cold.139
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end391:
	.size	inspect_pi4_manifest.cold.139, .Lfunc_end391-inspect_pi4_manifest.cold.139
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.140
	.type	inspect_pi4_manifest.cold.140,@function
inspect_pi4_manifest.cold.140:          # @inspect_pi4_manifest.cold.140
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end392:
	.size	inspect_pi4_manifest.cold.140, .Lfunc_end392-inspect_pi4_manifest.cold.140
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.141
	.type	inspect_pi4_manifest.cold.141,@function
inspect_pi4_manifest.cold.141:          # @inspect_pi4_manifest.cold.141
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end393:
	.size	inspect_pi4_manifest.cold.141, .Lfunc_end393-inspect_pi4_manifest.cold.141
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.142
	.type	inspect_pi4_manifest.cold.142,@function
inspect_pi4_manifest.cold.142:          # @inspect_pi4_manifest.cold.142
# %bb.0:
	pushq	%rax
	leaq	.L.str.293(%rip), %rdi
	callq	die
.Lfunc_end394:
	.size	inspect_pi4_manifest.cold.142, .Lfunc_end394-inspect_pi4_manifest.cold.142
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.143
	.type	inspect_pi4_manifest.cold.143,@function
inspect_pi4_manifest.cold.143:          # @inspect_pi4_manifest.cold.143
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end395:
	.size	inspect_pi4_manifest.cold.143, .Lfunc_end395-inspect_pi4_manifest.cold.143
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.144
	.type	inspect_pi4_manifest.cold.144,@function
inspect_pi4_manifest.cold.144:          # @inspect_pi4_manifest.cold.144
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end396:
	.size	inspect_pi4_manifest.cold.144, .Lfunc_end396-inspect_pi4_manifest.cold.144
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.145
	.type	inspect_pi4_manifest.cold.145,@function
inspect_pi4_manifest.cold.145:          # @inspect_pi4_manifest.cold.145
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end397:
	.size	inspect_pi4_manifest.cold.145, .Lfunc_end397-inspect_pi4_manifest.cold.145
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.146
	.type	inspect_pi4_manifest.cold.146,@function
inspect_pi4_manifest.cold.146:          # @inspect_pi4_manifest.cold.146
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end398:
	.size	inspect_pi4_manifest.cold.146, .Lfunc_end398-inspect_pi4_manifest.cold.146
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.147
	.type	inspect_pi4_manifest.cold.147,@function
inspect_pi4_manifest.cold.147:          # @inspect_pi4_manifest.cold.147
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end399:
	.size	inspect_pi4_manifest.cold.147, .Lfunc_end399-inspect_pi4_manifest.cold.147
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.148
	.type	inspect_pi4_manifest.cold.148,@function
inspect_pi4_manifest.cold.148:          # @inspect_pi4_manifest.cold.148
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end400:
	.size	inspect_pi4_manifest.cold.148, .Lfunc_end400-inspect_pi4_manifest.cold.148
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.149
	.type	inspect_pi4_manifest.cold.149,@function
inspect_pi4_manifest.cold.149:          # @inspect_pi4_manifest.cold.149
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end401:
	.size	inspect_pi4_manifest.cold.149, .Lfunc_end401-inspect_pi4_manifest.cold.149
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.150
	.type	inspect_pi4_manifest.cold.150,@function
inspect_pi4_manifest.cold.150:          # @inspect_pi4_manifest.cold.150
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end402:
	.size	inspect_pi4_manifest.cold.150, .Lfunc_end402-inspect_pi4_manifest.cold.150
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.151
	.type	inspect_pi4_manifest.cold.151,@function
inspect_pi4_manifest.cold.151:          # @inspect_pi4_manifest.cold.151
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end403:
	.size	inspect_pi4_manifest.cold.151, .Lfunc_end403-inspect_pi4_manifest.cold.151
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.152
	.type	inspect_pi4_manifest.cold.152,@function
inspect_pi4_manifest.cold.152:          # @inspect_pi4_manifest.cold.152
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end404:
	.size	inspect_pi4_manifest.cold.152, .Lfunc_end404-inspect_pi4_manifest.cold.152
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.153
	.type	inspect_pi4_manifest.cold.153,@function
inspect_pi4_manifest.cold.153:          # @inspect_pi4_manifest.cold.153
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end405:
	.size	inspect_pi4_manifest.cold.153, .Lfunc_end405-inspect_pi4_manifest.cold.153
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.154
	.type	inspect_pi4_manifest.cold.154,@function
inspect_pi4_manifest.cold.154:          # @inspect_pi4_manifest.cold.154
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end406:
	.size	inspect_pi4_manifest.cold.154, .Lfunc_end406-inspect_pi4_manifest.cold.154
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.155
	.type	inspect_pi4_manifest.cold.155,@function
inspect_pi4_manifest.cold.155:          # @inspect_pi4_manifest.cold.155
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end407:
	.size	inspect_pi4_manifest.cold.155, .Lfunc_end407-inspect_pi4_manifest.cold.155
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.156
	.type	inspect_pi4_manifest.cold.156,@function
inspect_pi4_manifest.cold.156:          # @inspect_pi4_manifest.cold.156
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end408:
	.size	inspect_pi4_manifest.cold.156, .Lfunc_end408-inspect_pi4_manifest.cold.156
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.157
	.type	inspect_pi4_manifest.cold.157,@function
inspect_pi4_manifest.cold.157:          # @inspect_pi4_manifest.cold.157
# %bb.0:
	pushq	%rax
	leaq	.L.str.197(%rip), %rdi
	callq	die
.Lfunc_end409:
	.size	inspect_pi4_manifest.cold.157, .Lfunc_end409-inspect_pi4_manifest.cold.157
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.158
	.type	inspect_pi4_manifest.cold.158,@function
inspect_pi4_manifest.cold.158:          # @inspect_pi4_manifest.cold.158
# %bb.0:
	pushq	%rax
	leaq	.L.str.195(%rip), %rdi
	callq	die
.Lfunc_end410:
	.size	inspect_pi4_manifest.cold.158, .Lfunc_end410-inspect_pi4_manifest.cold.158
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.159
	.type	inspect_pi4_manifest.cold.159,@function
inspect_pi4_manifest.cold.159:          # @inspect_pi4_manifest.cold.159
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end411:
	.size	inspect_pi4_manifest.cold.159, .Lfunc_end411-inspect_pi4_manifest.cold.159
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.160
	.type	inspect_pi4_manifest.cold.160,@function
inspect_pi4_manifest.cold.160:          # @inspect_pi4_manifest.cold.160
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end412:
	.size	inspect_pi4_manifest.cold.160, .Lfunc_end412-inspect_pi4_manifest.cold.160
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.161
	.type	inspect_pi4_manifest.cold.161,@function
inspect_pi4_manifest.cold.161:          # @inspect_pi4_manifest.cold.161
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end413:
	.size	inspect_pi4_manifest.cold.161, .Lfunc_end413-inspect_pi4_manifest.cold.161
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.162
	.type	inspect_pi4_manifest.cold.162,@function
inspect_pi4_manifest.cold.162:          # @inspect_pi4_manifest.cold.162
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end414:
	.size	inspect_pi4_manifest.cold.162, .Lfunc_end414-inspect_pi4_manifest.cold.162
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.163
	.type	inspect_pi4_manifest.cold.163,@function
inspect_pi4_manifest.cold.163:          # @inspect_pi4_manifest.cold.163
# %bb.0:
	pushq	%rax
	leaq	.L.str.293(%rip), %rdi
	callq	die
.Lfunc_end415:
	.size	inspect_pi4_manifest.cold.163, .Lfunc_end415-inspect_pi4_manifest.cold.163
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.164
	.type	inspect_pi4_manifest.cold.164,@function
inspect_pi4_manifest.cold.164:          # @inspect_pi4_manifest.cold.164
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end416:
	.size	inspect_pi4_manifest.cold.164, .Lfunc_end416-inspect_pi4_manifest.cold.164
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.165
	.type	inspect_pi4_manifest.cold.165,@function
inspect_pi4_manifest.cold.165:          # @inspect_pi4_manifest.cold.165
# %bb.0:
	pushq	%rax
	leaq	.L.str.293(%rip), %rdi
	callq	die
.Lfunc_end417:
	.size	inspect_pi4_manifest.cold.165, .Lfunc_end417-inspect_pi4_manifest.cold.165
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.166
	.type	inspect_pi4_manifest.cold.166,@function
inspect_pi4_manifest.cold.166:          # @inspect_pi4_manifest.cold.166
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end418:
	.size	inspect_pi4_manifest.cold.166, .Lfunc_end418-inspect_pi4_manifest.cold.166
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.167
	.type	inspect_pi4_manifest.cold.167,@function
inspect_pi4_manifest.cold.167:          # @inspect_pi4_manifest.cold.167
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end419:
	.size	inspect_pi4_manifest.cold.167, .Lfunc_end419-inspect_pi4_manifest.cold.167
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.168
	.type	inspect_pi4_manifest.cold.168,@function
inspect_pi4_manifest.cold.168:          # @inspect_pi4_manifest.cold.168
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end420:
	.size	inspect_pi4_manifest.cold.168, .Lfunc_end420-inspect_pi4_manifest.cold.168
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.169
	.type	inspect_pi4_manifest.cold.169,@function
inspect_pi4_manifest.cold.169:          # @inspect_pi4_manifest.cold.169
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end421:
	.size	inspect_pi4_manifest.cold.169, .Lfunc_end421-inspect_pi4_manifest.cold.169
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.170
	.type	inspect_pi4_manifest.cold.170,@function
inspect_pi4_manifest.cold.170:          # @inspect_pi4_manifest.cold.170
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end422:
	.size	inspect_pi4_manifest.cold.170, .Lfunc_end422-inspect_pi4_manifest.cold.170
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.171
	.type	inspect_pi4_manifest.cold.171,@function
inspect_pi4_manifest.cold.171:          # @inspect_pi4_manifest.cold.171
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end423:
	.size	inspect_pi4_manifest.cold.171, .Lfunc_end423-inspect_pi4_manifest.cold.171
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.172
	.type	inspect_pi4_manifest.cold.172,@function
inspect_pi4_manifest.cold.172:          # @inspect_pi4_manifest.cold.172
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end424:
	.size	inspect_pi4_manifest.cold.172, .Lfunc_end424-inspect_pi4_manifest.cold.172
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.173
	.type	inspect_pi4_manifest.cold.173,@function
inspect_pi4_manifest.cold.173:          # @inspect_pi4_manifest.cold.173
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end425:
	.size	inspect_pi4_manifest.cold.173, .Lfunc_end425-inspect_pi4_manifest.cold.173
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.174
	.type	inspect_pi4_manifest.cold.174,@function
inspect_pi4_manifest.cold.174:          # @inspect_pi4_manifest.cold.174
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end426:
	.size	inspect_pi4_manifest.cold.174, .Lfunc_end426-inspect_pi4_manifest.cold.174
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.175
	.type	inspect_pi4_manifest.cold.175,@function
inspect_pi4_manifest.cold.175:          # @inspect_pi4_manifest.cold.175
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end427:
	.size	inspect_pi4_manifest.cold.175, .Lfunc_end427-inspect_pi4_manifest.cold.175
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.176
	.type	inspect_pi4_manifest.cold.176,@function
inspect_pi4_manifest.cold.176:          # @inspect_pi4_manifest.cold.176
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end428:
	.size	inspect_pi4_manifest.cold.176, .Lfunc_end428-inspect_pi4_manifest.cold.176
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.177
	.type	inspect_pi4_manifest.cold.177,@function
inspect_pi4_manifest.cold.177:          # @inspect_pi4_manifest.cold.177
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end429:
	.size	inspect_pi4_manifest.cold.177, .Lfunc_end429-inspect_pi4_manifest.cold.177
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.178
	.type	inspect_pi4_manifest.cold.178,@function
inspect_pi4_manifest.cold.178:          # @inspect_pi4_manifest.cold.178
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end430:
	.size	inspect_pi4_manifest.cold.178, .Lfunc_end430-inspect_pi4_manifest.cold.178
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.179
	.type	inspect_pi4_manifest.cold.179,@function
inspect_pi4_manifest.cold.179:          # @inspect_pi4_manifest.cold.179
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end431:
	.size	inspect_pi4_manifest.cold.179, .Lfunc_end431-inspect_pi4_manifest.cold.179
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.180
	.type	inspect_pi4_manifest.cold.180,@function
inspect_pi4_manifest.cold.180:          # @inspect_pi4_manifest.cold.180
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end432:
	.size	inspect_pi4_manifest.cold.180, .Lfunc_end432-inspect_pi4_manifest.cold.180
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.181
	.type	inspect_pi4_manifest.cold.181,@function
inspect_pi4_manifest.cold.181:          # @inspect_pi4_manifest.cold.181
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end433:
	.size	inspect_pi4_manifest.cold.181, .Lfunc_end433-inspect_pi4_manifest.cold.181
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.182
	.type	inspect_pi4_manifest.cold.182,@function
inspect_pi4_manifest.cold.182:          # @inspect_pi4_manifest.cold.182
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end434:
	.size	inspect_pi4_manifest.cold.182, .Lfunc_end434-inspect_pi4_manifest.cold.182
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.183
	.type	inspect_pi4_manifest.cold.183,@function
inspect_pi4_manifest.cold.183:          # @inspect_pi4_manifest.cold.183
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end435:
	.size	inspect_pi4_manifest.cold.183, .Lfunc_end435-inspect_pi4_manifest.cold.183
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.184
	.type	inspect_pi4_manifest.cold.184,@function
inspect_pi4_manifest.cold.184:          # @inspect_pi4_manifest.cold.184
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end436:
	.size	inspect_pi4_manifest.cold.184, .Lfunc_end436-inspect_pi4_manifest.cold.184
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.185
	.type	inspect_pi4_manifest.cold.185,@function
inspect_pi4_manifest.cold.185:          # @inspect_pi4_manifest.cold.185
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end437:
	.size	inspect_pi4_manifest.cold.185, .Lfunc_end437-inspect_pi4_manifest.cold.185
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.186
	.type	inspect_pi4_manifest.cold.186,@function
inspect_pi4_manifest.cold.186:          # @inspect_pi4_manifest.cold.186
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end438:
	.size	inspect_pi4_manifest.cold.186, .Lfunc_end438-inspect_pi4_manifest.cold.186
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.187
	.type	inspect_pi4_manifest.cold.187,@function
inspect_pi4_manifest.cold.187:          # @inspect_pi4_manifest.cold.187
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end439:
	.size	inspect_pi4_manifest.cold.187, .Lfunc_end439-inspect_pi4_manifest.cold.187
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.188
	.type	inspect_pi4_manifest.cold.188,@function
inspect_pi4_manifest.cold.188:          # @inspect_pi4_manifest.cold.188
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end440:
	.size	inspect_pi4_manifest.cold.188, .Lfunc_end440-inspect_pi4_manifest.cold.188
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.189
	.type	inspect_pi4_manifest.cold.189,@function
inspect_pi4_manifest.cold.189:          # @inspect_pi4_manifest.cold.189
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end441:
	.size	inspect_pi4_manifest.cold.189, .Lfunc_end441-inspect_pi4_manifest.cold.189
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.190
	.type	inspect_pi4_manifest.cold.190,@function
inspect_pi4_manifest.cold.190:          # @inspect_pi4_manifest.cold.190
# %bb.0:
	pushq	%rax
	leaq	.L.str.242(%rip), %rdi
	callq	die
.Lfunc_end442:
	.size	inspect_pi4_manifest.cold.190, .Lfunc_end442-inspect_pi4_manifest.cold.190
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_pi4_manifest.cold.191
	.type	inspect_pi4_manifest.cold.191,@function
inspect_pi4_manifest.cold.191:          # @inspect_pi4_manifest.cold.191
# %bb.0:
	pushq	%rax
	leaq	.L.str.154(%rip), %rdi
	callq	die
.Lfunc_end443:
	.size	inspect_pi4_manifest.cold.191, .Lfunc_end443-inspect_pi4_manifest.cold.191
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_find_path.cold.1
	.type	inspect_find_path.cold.1,@function
inspect_find_path.cold.1:               # @inspect_find_path.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.153(%rip), %rdi
	callq	die
.Lfunc_end444:
	.size	inspect_find_path.cold.1, .Lfunc_end444-inspect_find_path.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_read_file_blob.cold.1
	.type	inspect_read_file_blob.cold.1,@function
inspect_read_file_blob.cold.1:          # @inspect_read_file_blob.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end445:
	.size	inspect_read_file_blob.cold.1, .Lfunc_end445-inspect_read_file_blob.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_file.cold.1
	.type	inspect_manifest_require_file.cold.1,@function
inspect_manifest_require_file.cold.1:   # @inspect_manifest_require_file.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.253(%rip), %rdi
	callq	die
.Lfunc_end446:
	.size	inspect_manifest_require_file.cold.1, .Lfunc_end446-inspect_manifest_require_file.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.1
	.type	load_pi4_app_catalog.cold.1,@function
load_pi4_app_catalog.cold.1:            # @load_pi4_app_catalog.cold.1
# %bb.0:
	pushq	%rax
	leaq	PI4_APP_INDEX_PATH(%rip), %rdi
	leaq	.L.str.272(%rip), %rsi
	callq	die_path
.Lfunc_end447:
	.size	load_pi4_app_catalog.cold.1, .Lfunc_end447-load_pi4_app_catalog.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.2
	.type	load_pi4_app_catalog.cold.2,@function
load_pi4_app_catalog.cold.2:            # @load_pi4_app_catalog.cold.2
# %bb.0:
	pushq	%rax
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.275(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	leaq	.L.str.256(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end448:
	.size	load_pi4_app_catalog.cold.2, .Lfunc_end448-load_pi4_app_catalog.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.3
	.type	load_pi4_app_catalog.cold.3,@function
load_pi4_app_catalog.cold.3:            # @load_pi4_app_catalog.cold.3
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.262(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end449:
	.size	load_pi4_app_catalog.cold.3, .Lfunc_end449-load_pi4_app_catalog.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.4
	.type	load_pi4_app_catalog.cold.4,@function
load_pi4_app_catalog.cold.4:            # @load_pi4_app_catalog.cold.4
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	.L.str.266(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end450:
	.size	load_pi4_app_catalog.cold.4, .Lfunc_end450-load_pi4_app_catalog.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.5
	.type	load_pi4_app_catalog.cold.5,@function
load_pi4_app_catalog.cold.5:            # @load_pi4_app_catalog.cold.5
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	.L.str.266(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end451:
	.size	load_pi4_app_catalog.cold.5, .Lfunc_end451-load_pi4_app_catalog.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.6
	.type	load_pi4_app_catalog.cold.6,@function
load_pi4_app_catalog.cold.6:            # @load_pi4_app_catalog.cold.6
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	.L.str.265(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end452:
	.size	load_pi4_app_catalog.cold.6, .Lfunc_end452-load_pi4_app_catalog.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.7
	.type	load_pi4_app_catalog.cold.7,@function
load_pi4_app_catalog.cold.7:            # @load_pi4_app_catalog.cold.7
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	.L.str.265(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end453:
	.size	load_pi4_app_catalog.cold.7, .Lfunc_end453-load_pi4_app_catalog.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.8
	.type	load_pi4_app_catalog.cold.8,@function
load_pi4_app_catalog.cold.8:            # @load_pi4_app_catalog.cold.8
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	.L.str.220(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end454:
	.size	load_pi4_app_catalog.cold.8, .Lfunc_end454-load_pi4_app_catalog.cold.8
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.9
	.type	load_pi4_app_catalog.cold.9,@function
load_pi4_app_catalog.cold.9:            # @load_pi4_app_catalog.cold.9
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	.L.str.220(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end455:
	.size	load_pi4_app_catalog.cold.9, .Lfunc_end455-load_pi4_app_catalog.cold.9
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.10
	.type	load_pi4_app_catalog.cold.10,@function
load_pi4_app_catalog.cold.10:           # @load_pi4_app_catalog.cold.10
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	.L.str.264(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end456:
	.size	load_pi4_app_catalog.cold.10, .Lfunc_end456-load_pi4_app_catalog.cold.10
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.11
	.type	load_pi4_app_catalog.cold.11,@function
load_pi4_app_catalog.cold.11:           # @load_pi4_app_catalog.cold.11
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	.L.str.264(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end457:
	.size	load_pi4_app_catalog.cold.11, .Lfunc_end457-load_pi4_app_catalog.cold.11
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.12
	.type	load_pi4_app_catalog.cold.12,@function
load_pi4_app_catalog.cold.12:           # @load_pi4_app_catalog.cold.12
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	.L.str.263(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end458:
	.size	load_pi4_app_catalog.cold.12, .Lfunc_end458-load_pi4_app_catalog.cold.12
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.13
	.type	load_pi4_app_catalog.cold.13,@function
load_pi4_app_catalog.cold.13:           # @load_pi4_app_catalog.cold.13
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	.L.str.263(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end459:
	.size	load_pi4_app_catalog.cold.13, .Lfunc_end459-load_pi4_app_catalog.cold.13
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.14
	.type	load_pi4_app_catalog.cold.14,@function
load_pi4_app_catalog.cold.14:           # @load_pi4_app_catalog.cold.14
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	.L.str.259(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end460:
	.size	load_pi4_app_catalog.cold.14, .Lfunc_end460-load_pi4_app_catalog.cold.14
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.15
	.type	load_pi4_app_catalog.cold.15,@function
load_pi4_app_catalog.cold.15:           # @load_pi4_app_catalog.cold.15
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	.L.str.259(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end461:
	.size	load_pi4_app_catalog.cold.15, .Lfunc_end461-load_pi4_app_catalog.cold.15
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.16
	.type	load_pi4_app_catalog.cold.16,@function
load_pi4_app_catalog.cold.16:           # @load_pi4_app_catalog.cold.16
# %bb.0:
	pushq	%rax
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end462:
	.size	load_pi4_app_catalog.cold.16, .Lfunc_end462-load_pi4_app_catalog.cold.16
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.17
	.type	load_pi4_app_catalog.cold.17,@function
load_pi4_app_catalog.cold.17:           # @load_pi4_app_catalog.cold.17
# %bb.0:
	pushq	%rax
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end463:
	.size	load_pi4_app_catalog.cold.17, .Lfunc_end463-load_pi4_app_catalog.cold.17
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.18
	.type	load_pi4_app_catalog.cold.18,@function
load_pi4_app_catalog.cold.18:           # @load_pi4_app_catalog.cold.18
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end464:
	.size	load_pi4_app_catalog.cold.18, .Lfunc_end464-load_pi4_app_catalog.cold.18
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.19
	.type	load_pi4_app_catalog.cold.19,@function
load_pi4_app_catalog.cold.19:           # @load_pi4_app_catalog.cold.19
# %bb.0:
	pushq	%rax
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end465:
	.size	load_pi4_app_catalog.cold.19, .Lfunc_end465-load_pi4_app_catalog.cold.19
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.20
	.type	load_pi4_app_catalog.cold.20,@function
load_pi4_app_catalog.cold.20:           # @load_pi4_app_catalog.cold.20
# %bb.0:
	pushq	%rax
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end466:
	.size	load_pi4_app_catalog.cold.20, .Lfunc_end466-load_pi4_app_catalog.cold.20
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.21
	.type	load_pi4_app_catalog.cold.21,@function
load_pi4_app_catalog.cold.21:           # @load_pi4_app_catalog.cold.21
# %bb.0:
	pushq	%rax
	leaq	.L.str.277(%rip), %rdi
	callq	die
.Lfunc_end467:
	.size	load_pi4_app_catalog.cold.21, .Lfunc_end467-load_pi4_app_catalog.cold.21
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.22
	.type	load_pi4_app_catalog.cold.22,@function
load_pi4_app_catalog.cold.22:           # @load_pi4_app_catalog.cold.22
# %bb.0:
	pushq	%rax
	leaq	.L.str.257(%rip), %rdi
	callq	die
.Lfunc_end468:
	.size	load_pi4_app_catalog.cold.22, .Lfunc_end468-load_pi4_app_catalog.cold.22
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.23
	.type	load_pi4_app_catalog.cold.23,@function
load_pi4_app_catalog.cold.23:           # @load_pi4_app_catalog.cold.23
# %bb.0:
	pushq	%rax
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	leaq	.L.str.256(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end469:
	.size	load_pi4_app_catalog.cold.23, .Lfunc_end469-load_pi4_app_catalog.cold.23
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.24
	.type	load_pi4_app_catalog.cold.24,@function
load_pi4_app_catalog.cold.24:           # @load_pi4_app_catalog.cold.24
# %bb.0:
	pushq	%rax
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	PI4_APP_INDEX_PATH(%rip), %rdx
	leaq	.L.str.256(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end470:
	.size	load_pi4_app_catalog.cold.24, .Lfunc_end470-load_pi4_app_catalog.cold.24
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.25
	.type	load_pi4_app_catalog.cold.25,@function
load_pi4_app_catalog.cold.25:           # @load_pi4_app_catalog.cold.25
# %bb.0:
	pushq	%rax
	leaq	PI4_APP_INDEX_PATH(%rip), %rdi
	leaq	.L.str.273(%rip), %rsi
	callq	die_path
.Lfunc_end471:
	.size	load_pi4_app_catalog.cold.25, .Lfunc_end471-load_pi4_app_catalog.cold.25
                                        # -- End function
	.p2align	4                               # -- Begin function load_pi4_app_catalog.cold.26
	.type	load_pi4_app_catalog.cold.26,@function
load_pi4_app_catalog.cold.26:           # @load_pi4_app_catalog.cold.26
# %bb.0:
	pushq	%rax
	leaq	PI4_APP_INDEX_PATH(%rip), %rdi
	leaq	.L.str.271(%rip), %rsi
	callq	die_path
.Lfunc_end472:
	.size	load_pi4_app_catalog.cold.26, .Lfunc_end472-load_pi4_app_catalog.cold.26
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_indexed_sized_file.cold.1
	.type	inspect_manifest_require_indexed_sized_file.cold.1,@function
inspect_manifest_require_indexed_sized_file.cold.1: # @inspect_manifest_require_indexed_sized_file.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end473:
	.size	inspect_manifest_require_indexed_sized_file.cold.1, .Lfunc_end473-inspect_manifest_require_indexed_sized_file.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_indexed_sized_file.cold.2
	.type	inspect_manifest_require_indexed_sized_file.cold.2,@function
inspect_manifest_require_indexed_sized_file.cold.2: # @inspect_manifest_require_indexed_sized_file.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.247(%rip), %rdi
	callq	die
.Lfunc_end474:
	.size	inspect_manifest_require_indexed_sized_file.cold.2, .Lfunc_end474-inspect_manifest_require_indexed_sized_file.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_indexed_sized_file.cold.3
	.type	inspect_manifest_require_indexed_sized_file.cold.3,@function
inspect_manifest_require_indexed_sized_file.cold.3: # @inspect_manifest_require_indexed_sized_file.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.297(%rip), %rdi
	callq	die
.Lfunc_end475:
	.size	inspect_manifest_require_indexed_sized_file.cold.3, .Lfunc_end475-inspect_manifest_require_indexed_sized_file.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_indexed_sized_file.cold.4
	.type	inspect_manifest_require_indexed_sized_file.cold.4,@function
inspect_manifest_require_indexed_sized_file.cold.4: # @inspect_manifest_require_indexed_sized_file.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end476:
	.size	inspect_manifest_require_indexed_sized_file.cold.4, .Lfunc_end476-inspect_manifest_require_indexed_sized_file.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function inspect_manifest_require_indexed_sized_file.cold.5
	.type	inspect_manifest_require_indexed_sized_file.cold.5,@function
inspect_manifest_require_indexed_sized_file.cold.5: # @inspect_manifest_require_indexed_sized_file.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.295(%rip), %rdi
	callq	die
.Lfunc_end477:
	.size	inspect_manifest_require_indexed_sized_file.cold.5, .Lfunc_end477-inspect_manifest_require_indexed_sized_file.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function manifest_get_value.cold.1
	.type	manifest_get_value.cold.1,@function
manifest_get_value.cold.1:              # @manifest_get_value.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.298(%rip), %rdi
	callq	die
.Lfunc_end478:
	.size	manifest_get_value.cold.1, .Lfunc_end478-manifest_get_value.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function manifest_require_u64.cold.1
	.type	manifest_require_u64.cold.1,@function
manifest_require_u64.cold.1:            # @manifest_require_u64.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.246(%rip), %rdi
	callq	die
.Lfunc_end479:
	.size	manifest_require_u64.cold.1, .Lfunc_end479-manifest_require_u64.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function manifest_require_u64.cold.2
	.type	manifest_require_u64.cold.2,@function
manifest_require_u64.cold.2:            # @manifest_require_u64.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.245(%rip), %rdi
	callq	die
.Lfunc_end480:
	.size	manifest_require_u64.cold.2, .Lfunc_end480-manifest_require_u64.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function text_manifest_require_value.cold.1
	.type	text_manifest_require_value.cold.1,@function
text_manifest_require_value.cold.1:     # @text_manifest_require_value.cold.1
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.274(%rip), %rsi
	leaq	.L.str.155(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end481:
	.size	text_manifest_require_value.cold.1, .Lfunc_end481-text_manifest_require_value.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function text_manifest_require_value.cold.2
	.type	text_manifest_require_value.cold.2,@function
text_manifest_require_value.cold.2:     # @text_manifest_require_value.cold.2
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.279(%rip), %rsi
	leaq	.L.str.155(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end482:
	.size	text_manifest_require_value.cold.2, .Lfunc_end482-text_manifest_require_value.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function text_manifest_require_value.cold.3
	.type	text_manifest_require_value.cold.3,@function
text_manifest_require_value.cold.3:     # @text_manifest_require_value.cold.3
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.278(%rip), %rsi
	leaq	.L.str.155(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end483:
	.size	text_manifest_require_value.cold.3, .Lfunc_end483-text_manifest_require_value.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function reject_repo_local_external_asset.cold.1
	.type	reject_repo_local_external_asset.cold.1,@function
reject_repo_local_external_asset.cold.1: # @reject_repo_local_external_asset.cold.1
# %bb.0:
	pushq	%rax
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.317(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end484:
	.size	reject_repo_local_external_asset.cold.1, .Lfunc_end484-reject_repo_local_external_asset.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function reject_repo_local_external_asset.cold.2
	.type	reject_repo_local_external_asset.cold.2,@function
reject_repo_local_external_asset.cold.2: # @reject_repo_local_external_asset.cold.2
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end485:
	.size	reject_repo_local_external_asset.cold.2, .Lfunc_end485-reject_repo_local_external_asset.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function reject_repo_local_external_asset.cold.3
	.type	reject_repo_local_external_asset.cold.3,@function
reject_repo_local_external_asset.cold.3: # @reject_repo_local_external_asset.cold.3
# %bb.0:
	pushq	%rax
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	leaq	.L.str.120(%rip), %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end486:
	.size	reject_repo_local_external_asset.cold.3, .Lfunc_end486-reject_repo_local_external_asset.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function proof_manifest_require_root_file.cold.1
	.type	proof_manifest_require_root_file.cold.1,@function
proof_manifest_require_root_file.cold.1: # @proof_manifest_require_root_file.cold.1
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.496(%rip), %rsi
	leaq	.L.str.494(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end487:
	.size	proof_manifest_require_root_file.cold.1, .Lfunc_end487-proof_manifest_require_root_file.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function proof_manifest_require_root_file.cold.2
	.type	proof_manifest_require_root_file.cold.2,@function
proof_manifest_require_root_file.cold.2: # @proof_manifest_require_root_file.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.36(%rip), %rdi
	callq	die
.Lfunc_end488:
	.size	proof_manifest_require_root_file.cold.2, .Lfunc_end488-proof_manifest_require_root_file.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function proof_manifest_require_root_file.cold.3
	.type	proof_manifest_require_root_file.cold.3,@function
proof_manifest_require_root_file.cold.3: # @proof_manifest_require_root_file.cold.3
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.495(%rip), %rsi
	leaq	.L.str.494(%rip), %rcx
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end489:
	.size	proof_manifest_require_root_file.cold.3, .Lfunc_end489-proof_manifest_require_root_file.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function text_appendf.cold.1
	.type	text_appendf.cold.1,@function
text_appendf.cold.1:                    # @text_appendf.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end490:
	.size	text_appendf.cold.1, .Lfunc_end490-text_appendf.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function text_appendf.cold.2
	.type	text_appendf.cold.2,@function
text_appendf.cold.2:                    # @text_appendf.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.498(%rip), %rdi
	callq	die
.Lfunc_end491:
	.size	text_appendf.cold.2, .Lfunc_end491-text_appendf.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function text_appendf.cold.3
	.type	text_appendf.cold.3,@function
text_appendf.cold.3:                    # @text_appendf.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end492:
	.size	text_appendf.cold.3, .Lfunc_end492-text_appendf.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function text_appendf.cold.4
	.type	text_appendf.cold.4,@function
text_appendf.cold.4:                    # @text_appendf.cold.4
# %bb.0:
	pushq	%rax
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end493:
	.size	text_appendf.cold.4, .Lfunc_end493-text_appendf.cold.4
                                        # -- End function
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"--write-root-marker"
	.size	.L.str, 20

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"--delete-root-marker"
	.size	.L.str.1, 21

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.zero	1
	.size	.L.str.2, 1

	.type	.L.str.3,@object                # @.str.3
.L.str.3:
	.asciz	"--check-persistence"
	.size	.L.str.3, 20

	.type	.L.str.4,@object                # @.str.4
.L.str.4:
	.asciz	"--baseline-image"
	.size	.L.str.4, 17

	.type	.L.str.5,@object                # @.str.5
.L.str.5:
	.asciz	"--reboot-baseline-image"
	.size	.L.str.5, 24

	.type	.L.str.6,@object                # @.str.6
.L.str.6:
	.asciz	"--write-status"
	.size	.L.str.6, 15

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"--save-write-status"
	.size	.L.str.7, 20

	.type	.L.str.8,@object                # @.str.8
.L.str.8:
	.asciz	"--load-status"
	.size	.L.str.8, 14

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"--reboot-status"
	.size	.L.str.9, 16

	.type	.L.str.10,@object               # @.str.10
.L.str.10:
	.asciz	"--require-default"
	.size	.L.str.10, 18

	.type	.L.str.11,@object               # @.str.11
.L.str.11:
	.asciz	"--require-dynamic-fat-proof"
	.size	.L.str.11, 28

	.type	.L.str.12,@object               # @.str.12
.L.str.12:
	.asciz	"--require-save-slot"
	.size	.L.str.12, 20

	.type	.L.str.13,@object               # @.str.13
.L.str.13:
	.asciz	"--require-save-description"
	.size	.L.str.13, 27

	.type	.L.str.14,@object               # @.str.14
.L.str.14:
	.asciz	"--primary-asset-wad"
	.size	.L.str.14, 20

	.type	.L.str.15,@object               # @.str.15
.L.str.15:
	.asciz	"--wad"
	.size	.L.str.15, 6

	.type	.L.str.16,@object               # @.str.16
.L.str.16:
	.asciz	"--proof-manifest"
	.size	.L.str.16, 17

	.type	.L.str.17,@object               # @.str.17
.L.str.17:
	.asciz	"--inspect"
	.size	.L.str.17, 10

	.type	.L.str.18,@object               # @.str.18
.L.str.18:
	.asciz	"--require-real-assets"
	.size	.L.str.18, 22

	.type	.L.str.19,@object               # @.str.19
.L.str.19:
	.asciz	"--require-file"
	.size	.L.str.19, 15

	.type	.L.str.20,@object               # @.str.20
.L.str.20:
	.asciz	"--root-elf"
	.size	.L.str.20, 11

	.type	.L.str.21,@object               # @.str.21
.L.str.21:
	.asciz	"duplicate --root-elf entry"
	.size	.L.str.21, 27

	.type	.L.str.22,@object               # @.str.22
.L.str.22:
	.asciz	"--root-file"
	.size	.L.str.22, 12

	.type	.L.str.23,@object               # @.str.23
.L.str.23:
	.asciz	"duplicate --root-file entry"
	.size	.L.str.23, 28

	.type	.L.str.24,@object               # @.str.24
.L.str.24:
	.asciz	"--asset"
	.size	.L.str.24, 8

	.type	.L.str.25,@object               # @.str.25
.L.str.25:
	.asciz	"duplicate --root-elf FAT16 name"
	.size	.L.str.25, 32

	.type	.L.str.26,@object               # @.str.26
.L.str.26:
	.asciz	"duplicate --root-file FAT16 name"
	.size	.L.str.26, 33

	.type	.L.str.27,@object               # @.str.27
.L.str.27:
	.asciz	"--root-file conflicts with --root-elf FAT16 name"
	.size	.L.str.27, 49

	.type	.L.str.28,@object               # @.str.28
.L.str.28:
	.asciz	"bootable image positional inputs are image, stage1, stage2, kernel, and user probe only"
	.size	.L.str.28, 88

	.type	.L.str.29,@object               # @.str.29
.L.str.29:
	.asciz	"out of memory"
	.size	.L.str.29, 14

	.type	.L.str.30,@object               # @.str.30
.L.str.30:
	.asciz	"unexpected disk image size"
	.size	.L.str.30, 27

	.type	.L.str.31,@object               # @.str.31
.L.str.31:
	.asciz	"rb"
	.size	.L.str.31, 3

	.type	.L.str.32,@object               # @.str.32
.L.str.32:
	.asciz	"seek failed"
	.size	.L.str.32, 12

	.type	.L.str.33,@object               # @.str.33
.L.str.33:
	.asciz	"tell failed"
	.size	.L.str.33, 12

	.type	.L.str.34,@object               # @.str.34
.L.str.34:
	.asciz	"read failed"
	.size	.L.str.34, 12

	.type	.L.str.35,@object               # @.str.35
.L.str.35:
	.asciz	"make_wad_image: %s: %s\n"
	.size	.L.str.35, 24

	.type	.L.str.36,@object               # @.str.36
.L.str.36:
	.asciz	"read past end"
	.size	.L.str.36, 14

	.type	.L.str.37,@object               # @.str.37
.L.str.37:
	.asciz	"PERSISTENCE_CHECKPOINT_NAME"
	.size	.L.str.37, 28

	.type	PERSISTENCE_CHECKPOINT_NAME,@object # @PERSISTENCE_CHECKPOINT_NAME
PERSISTENCE_CHECKPOINT_NAME:
	.asciz	"PERSIST CHK"
	.size	PERSISTENCE_CHECKPOINT_NAME, 12

	.type	.L.str.38,@object               # @.str.38
.L.str.38:
	.asciz	"SAVE_REQUEST_NAME"
	.size	.L.str.38, 18

	.type	SAVE_REQUEST_NAME,@object       # @SAVE_REQUEST_NAME
SAVE_REQUEST_NAME:
	.asciz	"SAVEREQ CHK"
	.size	SAVE_REQUEST_NAME, 12

	.type	.L.str.39,@object               # @.str.39
.L.str.39:
	.asciz	"LOAD_REQUEST_NAME"
	.size	.L.str.39, 18

	.type	LOAD_REQUEST_NAME,@object       # @LOAD_REQUEST_NAME
LOAD_REQUEST_NAME:
	.asciz	"LOADREQ CHK"
	.size	LOAD_REQUEST_NAME, 12

	.type	.L.str.40,@object               # @.str.40
.L.str.40:
	.asciz	"unknown root marker symbol"
	.size	.L.str.40, 27

	.type	.L.str.41,@object               # @.str.41
.L.str.41:
	.asciz	"cluster outside FAT16 data area"
	.size	.L.str.41, 32

	.type	.L.str.42,@object               # @.str.42
.L.str.42:
	.asciz	"FAT16 file path is empty"
	.size	.L.str.42, 25

	.type	.L.str.43,@object               # @.str.43
.L.str.43:
	.asciz	"FAT16 path component exists but is not a directory"
	.size	.L.str.43, 51

	.type	.L.str.44,@object               # @.str.44
.L.str.44:
	.asciz	".          "
	.size	.L.str.44, 12

	.type	.L.str.45,@object               # @.str.45
.L.str.45:
	.asciz	"..         "
	.size	.L.str.45, 12

	.type	.L.str.46,@object               # @.str.46
.L.str.46:
	.asciz	"file does not fit in FAT16 data area"
	.size	.L.str.46, 37

	.type	.L.str.47,@object               # @.str.47
.L.str.47:
	.asciz	"FAT16 directory is full"
	.size	.L.str.47, 24

	.type	.L.str.49,@object               # @.str.49
.L.str.49:
	.asciz	"usage: make_wad_image [--require-real-assets] [--require-file FAT_PATH] --inspect IMAGE\n       make_wad_image [--proof-manifest] [--primary-asset-wad PATH|--wad PATH] [--root-elf NAME.ELF=PATH] [--root-file NAME.EXT=PATH] [--asset IMAGE_8.3_PATH=HOST_PATH] OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF]]\n       make_wad_image --write-root-marker SYMBOL APP IMAGE\n       make_wad_image --delete-root-marker SYMBOL IMAGE\n       make_wad_image --check-persistence IMAGE [--baseline-image IMAGE] [--reboot-baseline-image IMAGE] [--write-status FILE] [--save-write-status FILE] [--load-status FILE] [--reboot-status FILE] [--require-default] [--require-dynamic-fat-proof] [--require-save-slot N] [--require-save-description N=TEXT]"
	.size	.L.str.49, 721

	.type	.L.str.50,@object               # @.str.50
.L.str.50:
	.asciz	"--require-save-slot expects slot 0..5"
	.size	.L.str.50, 38

	.type	.L.str.51,@object               # @.str.51
.L.str.51:
	.asciz	"too many save slots requested"
	.size	.L.str.51, 30

	.type	.L.str.52,@object               # @.str.52
.L.str.52:
	.asciz	"--require-save-description expects SLOT=TEXT with slot 0..5"
	.size	.L.str.52, 60

	.type	.L.str.53,@object               # @.str.53
.L.str.53:
	.asciz	"dynamic FAT proof was requested without a write status file"
	.size	.L.str.53, 60

	.type	.L.str.55,@object               # @.str.55
.L.str.55:
	.asciz	"image=%s\n"
	.size	.L.str.55, 10

	.type	.L.str.56,@object               # @.str.56
.L.str.56:
	.asciz	"default_cfg=%s\n"
	.size	.L.str.56, 16

	.type	.L.str.57,@object               # @.str.57
.L.str.57:
	.asciz	"checked"
	.size	.L.str.57, 8

	.type	.L.str.58,@object               # @.str.58
.L.str.58:
	.asciz	"not-requested"
	.size	.L.str.58, 14

	.type	.L.str.59,@object               # @.str.59
.L.str.59:
	.asciz	"save_slot_%d=checked\n"
	.size	.L.str.59, 22

	.type	.L.str.61,@object               # @.str.61
.L.str.61:
	.asciz	"unexpected image size"
	.size	.L.str.61, 22

	.type	.L.str.62,@object               # @.str.62
.L.str.62:
	.asciz	"missing MBR signature"
	.size	.L.str.62, 22

	.type	.L.str.63,@object               # @.str.63
.L.str.63:
	.asciz	"unexpected partition layout"
	.size	.L.str.63, 28

	.type	.L.str.64,@object               # @.str.64
.L.str.64:
	.asciz	"missing FAT boot signature"
	.size	.L.str.64, 27

	.type	.L.str.65,@object               # @.str.65
.L.str.65:
	.asciz	"unexpected FAT bytes per sector"
	.size	.L.str.65, 32

	.type	.L.str.66,@object               # @.str.66
.L.str.66:
	.asciz	"unexpected FAT sectors per cluster"
	.size	.L.str.66, 35

	.type	DEFAULT_CFG_NAME,@object        # @DEFAULT_CFG_NAME
	.section	.rodata,"a",@progbits
DEFAULT_CFG_NAME:
	.asciz	"DEFAULT CFG"
	.size	DEFAULT_CFG_NAME, 12

	.type	.L.str.67,@object               # @.str.67
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.67:
	.asciz	"DEFAULT.CFG is missing from the FAT root"
	.size	.L.str.67, 41

	.type	.L.str.68,@object               # @.str.68
.L.str.68:
	.asciz	"DEFAULT.CFG is a directory"
	.size	.L.str.68, 27

	.type	.L.str.69,@object               # @.str.69
.L.str.69:
	.asciz	"DEFAULT.CFG was not written"
	.size	.L.str.69, 28

	.type	.L.str.70,@object               # @.str.70
.L.str.70:
	.asciz	"DEFAULT.CFG did not change from the persistence baseline"
	.size	.L.str.70, 57

	.type	.L.str.71,@object               # @.str.71
.L.str.71:
	.asciz	"left image"
	.size	.L.str.71, 11

	.type	.L.str.72,@object               # @.str.72
.L.str.72:
	.asciz	"right image"
	.size	.L.str.72, 12

	.type	.L.str.73,@object               # @.str.73
.L.str.73:
	.asciz	"file has invalid first cluster"
	.size	.L.str.73, 31

	.type	.L.str.74,@object               # @.str.74
.L.str.74:
	.asciz	"file cluster chain is invalid"
	.size	.L.str.74, 30

	.type	.L.str.75,@object               # @.str.75
.L.str.75:
	.asciz	"file cluster chain ended early"
	.size	.L.str.75, 31

	.type	.L.str.77,@object               # @.str.77
.L.str.77:
	.asciz	"required save slot is missing from the FAT root"
	.size	.L.str.77, 48

	.type	.L.str.78,@object               # @.str.78
.L.str.78:
	.asciz	"required save slot is a directory"
	.size	.L.str.78, 34

	.type	.L.str.79,@object               # @.str.79
.L.str.79:
	.asciz	"required save slot is too small to prove persistence"
	.size	.L.str.79, 53

	.type	.L.str.80,@object               # @.str.80
.L.str.80:
	.asciz	"required save slot did not change from the persistence baseline"
	.size	.L.str.80, 64

	.type	.L.str.81,@object               # @.str.81
.L.str.81:
	.asciz	"required save slot changed across reboot/load proof"
	.size	.L.str.81, 52

	.type	.L.str.82,@object               # @.str.82
.L.str.82:
	.asciz	"save slot"
	.size	.L.str.82, 10

	.type	.L.str.83,@object               # @.str.83
.L.str.83:
	.asciz	"required save description is longer than Doom's save title field"
	.size	.L.str.83, 65

	.type	.L.str.84,@object               # @.str.84
.L.str.84:
	.asciz	"required save slot does not contain the requested description"
	.size	.L.str.84, 62

	.type	.L.str.85,@object               # @.str.85
.L.str.85:
	.asciz	"version "
	.size	.L.str.85, 9

	.type	.L.str.86,@object               # @.str.86
.L.str.86:
	.asciz	"required save slot does not contain the expected version header"
	.size	.L.str.86, 64

	.type	.L.str.87,@object               # @.str.87
.L.str.87:
	.asciz	"save slot must be 0..5"
	.size	.L.str.87, 23

	.type	PRIMARY_SAVE_SLOT_TEMPLATE_NAME,@object # @PRIMARY_SAVE_SLOT_TEMPLATE_NAME
PRIMARY_SAVE_SLOT_TEMPLATE_NAME:
	.asciz	"DOOMSAV DSG"
	.size	PRIMARY_SAVE_SLOT_TEMPLATE_NAME, 12

	.type	.L.str.88,@object               # @.str.88
.L.str.88:
	.asciz	"savewr"
	.size	.L.str.88, 7

	.type	.L.str.89,@object               # @.str.89
.L.str.89:
	.asciz	"save write status did not prove save slot bytes and calls"
	.size	.L.str.89, 58

	.type	.L.str.90,@object               # @.str.90
.L.str.90:
	.asciz	"saveclose"
	.size	.L.str.90, 10

	.type	.L.str.91,@object               # @.str.91
.L.str.91:
	.asciz	"save write status did not prove close"
	.size	.L.str.91, 38

	.type	.L.str.92,@object               # @.str.92
.L.str.92:
	.asciz	"doomwrite"
	.size	.L.str.92, 10

	.type	.L.str.93,@object               # @.str.93
.L.str.93:
	.asciz	"write status did not prove file writes"
	.size	.L.str.93, 39

	.type	.L.str.94,@object               # @.str.94
.L.str.94:
	.asciz	"doomclose"
	.size	.L.str.94, 10

	.type	.L.str.95,@object               # @.str.95
.L.str.95:
	.asciz	"write status did not prove closes"
	.size	.L.str.95, 34

	.type	.L.str.96,@object               # @.str.96
.L.str.96:
	.asciz	"required status tuple is missing"
	.size	.L.str.96, 33

	.type	.L.str.97,@object               # @.str.97
.L.str.97:
	.asciz	"status tuple has too few parts"
	.size	.L.str.97, 31

	.type	.L.str.98,@object               # @.str.98
.L.str.98:
	.asciz	"status field did not contain a hex value"
	.size	.L.str.98, 41

	.type	.L.str.99,@object               # @.str.99
.L.str.99:
	.asciz	"required status field is missing"
	.size	.L.str.99, 33

	.type	.L.str.100,@object              # @.str.100
.L.str.100:
	.asciz	"gameplay=OK"
	.size	.L.str.100, 12

	.type	.L.str.101,@object              # @.str.101
.L.str.101:
	.asciz	"load status did not return to gameplay"
	.size	.L.str.101, 39

	.type	.L.str.102,@object              # @.str.102
.L.str.102:
	.asciz	"saverd"
	.size	.L.str.102, 7

	.type	.L.str.103,@object              # @.str.103
.L.str.103:
	.asciz	"load status did not prove save slot reads"
	.size	.L.str.103, 42

	.type	.L.str.104,@object              # @.str.104
.L.str.104:
	.asciz	"panic="
	.size	.L.str.104, 7

	.type	.L.str.105,@object              # @.str.105
.L.str.105:
	.asciz	"panic=NONE"
	.size	.L.str.105, 11

	.type	.L.str.106,@object              # @.str.106
.L.str.106:
	.asciz	"load status reported a panic"
	.size	.L.str.106, 29

	.type	.L.str.107,@object              # @.str.107
.L.str.107:
	.asciz	"reboot status did not return to gameplay"
	.size	.L.str.107, 41

	.type	.L.str.108,@object              # @.str.108
.L.str.108:
	.asciz	"reboot status reported a panic"
	.size	.L.str.108, 31

	.type	.L.str.109,@object              # @.str.109
.L.str.109:
	.asciz	"fatdyn"
	.size	.L.str.109, 7

	.type	.L.str.110,@object              # @.str.110
.L.str.110:
	.asciz	"fatdyn status did not prove dynamic FAT activity"
	.size	.L.str.110, 49

	.type	.L.str.111,@object              # @.str.111
.L.str.111:
	.asciz	"--root-elf must be NAME.ELF=PATH"
	.size	.L.str.111, 33

	.type	.L.str.112,@object              # @.str.112
.L.str.112:
	.asciz	"--root-elf display name is too long"
	.size	.L.str.112, 36

	.type	.L.str.113,@object              # @.str.113
.L.str.113:
	.asciz	"--root-elf must be a root-level NAME.ELF"
	.size	.L.str.113, 41

	.type	.L.str.114,@object              # @.str.114
.L.str.114:
	.asciz	"ELF"
	.size	.L.str.114, 4

	.type	.L.str.115,@object              # @.str.115
.L.str.115:
	.asciz	"--root-elf name must use .ELF"
	.size	.L.str.115, 30

	.type	.L.str.116,@object              # @.str.116
.L.str.116:
	.asciz	"FAT16 path must not be empty"
	.size	.L.str.116, 29

	.type	.L.str.117,@object              # @.str.117
.L.str.117:
	.asciz	"FAT16 path is too deep"
	.size	.L.str.117, 23

	.type	.L.str.118,@object              # @.str.118
.L.str.118:
	.asciz	".."
	.size	.L.str.118, 3

	.type	.L.str.119,@object              # @.str.119
.L.str.119:
	.asciz	"FAT16 path must not use dot traversal"
	.size	.L.str.119, 38

	.type	.L.str.120,@object              # @.str.120
.L.str.120:
	.asciz	"."
	.size	.L.str.120, 2

	.type	.L.str.121,@object              # @.str.121
.L.str.121:
	.asciz	"FAT16 path component is too long"
	.size	.L.str.121, 33

	.type	.L.str.122,@object              # @.str.122
.L.str.122:
	.asciz	"FAT16 path must name at least one component"
	.size	.L.str.122, 44

	.type	.L.str.123,@object              # @.str.123
.L.str.123:
	.asciz	"FAT16 path component must fit 8.3"
	.size	.L.str.123, 34

	.type	.L.str.124,@object              # @.str.124
.L.str.124:
	.asciz	"FAT16 path component has too many dots"
	.size	.L.str.124, 39

	.type	.L.str.125,@object              # @.str.125
.L.str.125:
	.asciz	"FAT16 path component has unsupported characters"
	.size	.L.str.125, 48

	.type	.L.str.126,@object              # @.str.126
.L.str.126:
	.asciz	"FAT16 extension has unsupported characters"
	.size	.L.str.126, 43

	.type	PRIMARY_ASSET_WAD_NAME,@object  # @PRIMARY_ASSET_WAD_NAME
	.section	.rodata,"a",@progbits
PRIMARY_ASSET_WAD_NAME:
	.asciz	"DOOM1   WAD"
	.size	PRIMARY_ASSET_WAD_NAME, 12

	.type	KERNEL_ELF_NAME,@object         # @KERNEL_ELF_NAME
KERNEL_ELF_NAME:
	.asciz	"KERNEL  ELF"
	.size	KERNEL_ELF_NAME, 12

	.type	USER_PROBE_NAME,@object         # @USER_PROBE_NAME
USER_PROBE_NAME:
	.asciz	"USERPROBELF"
	.size	USER_PROBE_NAME, 12

	.type	.L.str.127,@object              # @.str.127
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.127:
	.asciz	"root file option tries to replace a protected boot entry"
	.size	.L.str.127, 57

	.type	.L.str.128,@object              # @.str.128
.L.str.128:
	.asciz	"make_wad_image: %s\n"
	.size	.L.str.128, 20

	.type	.L.str.129,@object              # @.str.129
.L.str.129:
	.asciz	"--root-file must be NAME.EXT=PATH"
	.size	.L.str.129, 34

	.type	.L.str.130,@object              # @.str.130
.L.str.130:
	.asciz	"--root-file display name is too long"
	.size	.L.str.130, 37

	.type	.L.str.131,@object              # @.str.131
.L.str.131:
	.asciz	"--root-file must be a root-level 8.3 file name"
	.size	.L.str.131, 47

	.type	.L.str.132,@object              # @.str.132
.L.str.132:
	.asciz	"--asset must be IMAGE_8.3_PATH=HOST_PATH"
	.size	.L.str.132, 41

	.type	.L.str.133,@object              # @.str.133
.L.str.133:
	.asciz	"--asset display path is too long"
	.size	.L.str.133, 33

	.type	.L.str.135,@object              # @.str.135
.L.str.135:
	.asciz	"image_path=%s\n"
	.size	.L.str.135, 15

	.type	.L.str.136,@object              # @.str.136
.L.str.136:
	.asciz	"image_size=%zu\n"
	.size	.L.str.136, 16

	.type	.L.str.137,@object              # @.str.137
.L.str.137:
	.asciz	"partition_lba=%u\n"
	.size	.L.str.137, 18

	.type	.L.str.138,@object              # @.str.138
.L.str.138:
	.asciz	"partition_sectors=%u\n"
	.size	.L.str.138, 22

	.type	.L.str.139,@object              # @.str.139
.L.str.139:
	.asciz	"root_lba=%u\n"
	.size	.L.str.139, 13

	.type	.L.str.140,@object              # @.str.140
.L.str.140:
	.asciz	"data_lba=%u\n"
	.size	.L.str.140, 13

	.type	.L.str.141,@object              # @.str.141
.L.str.141:
	.asciz	"root_entry_count=%u\n"
	.size	.L.str.141, 21

	.type	.L.str.142,@object              # @.str.142
.L.str.142:
	.asciz	"data_clusters=%u\n"
	.size	.L.str.142, 18

	.type	.L.str.143,@object              # @.str.143
.L.str.143:
	.asciz	"root[%u]=%s attr=0x%02X cluster=%u size=%u\n"
	.size	.L.str.143, 44

	.type	.L.str.144,@object              # @.str.144
.L.str.144:
	.asciz	"%s/%s"
	.size	.L.str.144, 6

	.type	.L.str.145,@object              # @.str.145
.L.str.145:
	.asciz	"inspect path is too long"
	.size	.L.str.145, 25

	.type	.L.str.146,@object              # @.str.146
.L.str.146:
	.asciz	"path=%s attr=0x%02X cluster=%u size=%u\n"
	.size	.L.str.146, 40

	.type	.L.str.147,@object              # @.str.147
.L.str.147:
	.asciz	"required FAT file is missing"
	.size	.L.str.147, 29

	.type	.L.str.148,@object              # @.str.148
.L.str.148:
	.asciz	"required FAT path is a directory"
	.size	.L.str.148, 33

	.type	.L.str.149,@object              # @.str.149
.L.str.149:
	.asciz	"required FAT file is empty"
	.size	.L.str.149, 27

	.type	.L.str.150,@object              # @.str.150
.L.str.150:
	.asciz	"required FAT file has invalid first cluster"
	.size	.L.str.150, 44

	.type	.L.str.151,@object              # @.str.151
.L.str.151:
	.asciz	"required_file=%s state=present size=%u cluster=%u\n"
	.size	.L.str.151, 51

	.type	.L.str.152,@object              # @.str.152
.L.str.152:
	.asciz	"directory has invalid first cluster"
	.size	.L.str.152, 36

	.type	.L.str.153,@object              # @.str.153
.L.str.153:
	.asciz	"inspect path component is too long"
	.size	.L.str.153, 35

	.type	PROOF_MANIFEST_PATH,@object     # @PROOF_MANIFEST_PATH
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PROOF_MANIFEST_PATH:
	.asciz	"/PROOF/MANIFEST.TXT"
	.size	PROOF_MANIFEST_PATH, 20

	.type	.L.str.154,@object              # @.str.154
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.154:
	.asciz	"Pi proof manifest is required for real asset proof"
	.size	.L.str.154, 51

	.type	.L.str.155,@object              # @.str.155
.L.str.155:
	.asciz	"schema"
	.size	.L.str.155, 7

	.type	.L.str.156,@object              # @.str.156
.L.str.156:
	.asciz	"vibe-os-pi4-image-manifest-v1"
	.size	.L.str.156, 30

	.type	.L.str.157,@object              # @.str.157
.L.str.157:
	.asciz	"layout"
	.size	.L.str.157, 7

	.type	.L.str.158,@object              # @.str.158
.L.str.158:
	.asciz	"vibe-os-pi4-fat16-v1"
	.size	.L.str.158, 21

	.type	.L.str.159,@object              # @.str.159
.L.str.159:
	.asciz	"root_lba"
	.size	.L.str.159, 9

	.type	.L.str.160,@object              # @.str.160
.L.str.160:
	.asciz	"data_lba"
	.size	.L.str.160, 9

	.type	.L.str.161,@object              # @.str.161
.L.str.161:
	.asciz	"root_entry_count"
	.size	.L.str.161, 17

	.type	.L.str.162,@object              # @.str.162
.L.str.162:
	.asciz	"manifest_path"
	.size	.L.str.162, 14

	.type	.L.str.163,@object              # @.str.163
.L.str.163:
	.asciz	"manifest_path=%s state=present size=%u\n"
	.size	.L.str.163, 40

	.type	.L.str.164,@object              # @.str.164
.L.str.164:
	.asciz	"kernel_file"
	.size	.L.str.164, 12

	.type	.L.str.165,@object              # @.str.165
.L.str.165:
	.asciz	"KERNEL8.IMG"
	.size	.L.str.165, 12

	.type	.L.str.166,@object              # @.str.166
.L.str.166:
	.asciz	"kernel_size"
	.size	.L.str.166, 12

	.type	.L.str.167,@object              # @.str.167
.L.str.167:
	.asciz	"config_file"
	.size	.L.str.167, 12

	.type	.L.str.168,@object              # @.str.168
.L.str.168:
	.asciz	"CONFIG.TXT"
	.size	.L.str.168, 11

	.type	.L.str.169,@object              # @.str.169
.L.str.169:
	.asciz	"config_size"
	.size	.L.str.169, 12

	.type	.L.str.170,@object              # @.str.170
.L.str.170:
	.asciz	"app_model_schema"
	.size	.L.str.170, 17

	.type	.L.str.171,@object              # @.str.171
.L.str.171:
	.asciz	"vibe-os-pi4-app-install-v1"
	.size	.L.str.171, 27

	.type	.L.str.172,@object              # @.str.172
.L.str.172:
	.asciz	"app_layout"
	.size	.L.str.172, 11

	.type	PI4_APP_LAYOUT,@object          # @PI4_APP_LAYOUT
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PI4_APP_LAYOUT:
	.asciz	"system-init-plus-apps-tree"
	.size	PI4_APP_LAYOUT, 27

	.type	.L.str.173,@object              # @.str.173
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.173:
	.asciz	"app_discovery_model"
	.size	.L.str.173, 20

	.type	PI4_APP_DISCOVERY_MODEL,@object # @PI4_APP_DISCOVERY_MODEL
	.section	.rodata,"a",@progbits
PI4_APP_DISCOVERY_MODEL:
	.asciz	"vfs-app-index"
	.size	PI4_APP_DISCOVERY_MODEL, 14

	.type	.L.str.174,@object              # @.str.174
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.174:
	.asciz	"app_launch_model"
	.size	.L.str.174, 17

	.type	.L.str.175,@object              # @.str.175
.L.str.175:
	.asciz	"generic-vfs-path-exec"
	.size	.L.str.175, 22

	.type	.L.str.176,@object              # @.str.176
.L.str.176:
	.asciz	"app_exec_model"
	.size	.L.str.176, 15

	.type	PI4_APP_EXEC_MODEL,@object      # @PI4_APP_EXEC_MODEL
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PI4_APP_EXEC_MODEL:
	.asciz	"generic-aarch64-el0-elf-by-path"
	.size	PI4_APP_EXEC_MODEL, 32

	.type	.L.str.177,@object              # @.str.177
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.177:
	.asciz	"system_init"
	.size	.L.str.177, 12

	.type	PI4_SYSTEM_INIT_PATH,@object    # @PI4_SYSTEM_INIT_PATH
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PI4_SYSTEM_INIT_PATH:
	.asciz	"/SYSTEM/INIT.ELF"
	.size	PI4_SYSTEM_INIT_PATH, 17

	.type	.L.str.178,@object              # @.str.178
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.178:
	.asciz	"system_init_size"
	.size	.L.str.178, 17

	.type	.L.str.179,@object              # @.str.179
.L.str.179:
	.asciz	"system_abiprobe"
	.size	.L.str.179, 16

	.type	PI4_SYSTEM_ABIPROBE_PATH,@object # @PI4_SYSTEM_ABIPROBE_PATH
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PI4_SYSTEM_ABIPROBE_PATH:
	.asciz	"/SYSTEM/ABIPROBE.ELF"
	.size	PI4_SYSTEM_ABIPROBE_PATH, 21

	.type	.L.str.180,@object              # @.str.180
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.180:
	.asciz	"system_abiprobe_size"
	.size	.L.str.180, 21

	.type	.L.str.181,@object              # @.str.181
.L.str.181:
	.asciz	"app_index"
	.size	.L.str.181, 10

	.type	PI4_APP_INDEX_PATH,@object      # @PI4_APP_INDEX_PATH
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PI4_APP_INDEX_PATH:
	.asciz	"/APPS/INDEX.TXT"
	.size	PI4_APP_INDEX_PATH, 16

	.type	.L.str.182,@object              # @.str.182
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.182:
	.asciz	"app_index_size"
	.size	.L.str.182, 15

	.type	.L.str.183,@object              # @.str.183
.L.str.183:
	.asciz	"%zu"
	.size	.L.str.183, 4

	.type	PI4_APP_RECORD_COUNT_KEY,@object # @PI4_APP_RECORD_COUNT_KEY
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PI4_APP_RECORD_COUNT_KEY:
	.asciz	"app_record_count"
	.size	PI4_APP_RECORD_COUNT_KEY, 17

	.type	PI4_APP_RECORD_PREFIX,@object   # @PI4_APP_RECORD_PREFIX
PI4_APP_RECORD_PREFIX:
	.asciz	"app_record"
	.size	PI4_APP_RECORD_PREFIX, 11

	.type	.L.str.184,@object              # @.str.184
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.184:
	.asciz	"root_file_count"
	.size	.L.str.184, 16

	.type	.L.str.185,@object              # @.str.185
.L.str.185:
	.asciz	"root_file"
	.size	.L.str.185, 10

	.type	.L.str.186,@object              # @.str.186
.L.str.186:
	.asciz	"root_elf_count"
	.size	.L.str.186, 15

	.type	.L.str.187,@object              # @.str.187
.L.str.187:
	.asciz	"root_elf"
	.size	.L.str.187, 9

	.type	.L.str.188,@object              # @.str.188
.L.str.188:
	.asciz	"primary_asset_file"
	.size	.L.str.188, 19

	.type	.L.str.189,@object              # @.str.189
.L.str.189:
	.asciz	"DOOM1.WAD"
	.size	.L.str.189, 10

	.type	.L.str.190,@object              # @.str.190
.L.str.190:
	.asciz	"primary_asset_kind"
	.size	.L.str.190, 19

	.type	.L.str.191,@object              # @.str.191
.L.str.191:
	.asciz	"doom-wad"
	.size	.L.str.191, 9

	.type	.L.str.192,@object              # @.str.192
.L.str.192:
	.asciz	"primary_asset_state"
	.size	.L.str.192, 20

	.type	.L.str.193,@object              # @.str.193
.L.str.193:
	.asciz	"present"
	.size	.L.str.193, 8

	.type	.L.str.194,@object              # @.str.194
.L.str.194:
	.asciz	"primary_asset_source"
	.size	.L.str.194, 21

	.type	.L.str.195,@object              # @.str.195
.L.str.195:
	.asciz	"Pi proof manifest is missing primary WAD source"
	.size	.L.str.195, 48

	.type	.L.str.196,@object              # @.str.196
.L.str.196:
	.asciz	"primary_asset_repo_state"
	.size	.L.str.196, 25

	.type	.L.str.197,@object              # @.str.197
.L.str.197:
	.asciz	"Pi proof manifest is missing primary WAD repo state"
	.size	.L.str.197, 52

	.type	.L.str.198,@object              # @.str.198
.L.str.198:
	.asciz	"external"
	.size	.L.str.198, 9

	.type	.L.str.199,@object              # @.str.199
.L.str.199:
	.asciz	"outside-repo"
	.size	.L.str.199, 13

	.type	.L.str.200,@object              # @.str.200
.L.str.200:
	.asciz	"Pi proof manifest external WAD must be marked outside-repo"
	.size	.L.str.200, 59

	.type	.L.str.201,@object              # @.str.201
.L.str.201:
	.asciz	"generated-fixture"
	.size	.L.str.201, 18

	.type	.L.str.202,@object              # @.str.202
.L.str.202:
	.asciz	"generated-by-builder"
	.size	.L.str.202, 21

	.type	.L.str.203,@object              # @.str.203
.L.str.203:
	.asciz	"Pi proof manifest generated WAD must be marked generated-by-builder"
	.size	.L.str.203, 68

	.type	.L.str.204,@object              # @.str.204
.L.str.204:
	.asciz	"Pi proof manifest primary WAD source must be external or generated-fixture"
	.size	.L.str.204, 75

	.type	.L.str.205,@object              # @.str.205
.L.str.205:
	.asciz	"primary_asset_evidence"
	.size	.L.str.205, 23

	.type	.L.str.206,@object              # @.str.206
.L.str.206:
	.asciz	"packaged-file-only"
	.size	.L.str.206, 19

	.type	.L.str.207,@object              # @.str.207
.L.str.207:
	.asciz	"primary_asset_hardware_proof"
	.size	.L.str.207, 29

	.type	.L.str.208,@object              # @.str.208
.L.str.208:
	.asciz	"unclaimed"
	.size	.L.str.208, 10

	.type	.L.str.209,@object              # @.str.209
.L.str.209:
	.asciz	"primary_asset_size"
	.size	.L.str.209, 19

	.type	.L.str.210,@object              # @.str.210
.L.str.210:
	.asciz	"manifest_asset=DOOM1.WAD kind=doom-wad source=%s repo_state=%s evidence=packaged-file-only hardware_proof=unclaimed state=present\n"
	.size	.L.str.210, 131

	.type	.L.str.211,@object              # @.str.211
.L.str.211:
	.asciz	"default_asset_count"
	.size	.L.str.211, 20

	.type	.L.str.213,@object              # @.str.213
.L.str.213:
	.asciz	"default_asset.0.file"
	.size	.L.str.213, 21

	.type	DEFAULT_PI4_ASSET_README_PATH,@object # @DEFAULT_PI4_ASSET_README_PATH
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
DEFAULT_PI4_ASSET_README_PATH:
	.asciz	"/ASSETS/README.TXT"
	.size	DEFAULT_PI4_ASSET_README_PATH, 19

	.type	.L.str.214,@object              # @.str.214
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.214:
	.asciz	"default_asset.0.size"
	.size	.L.str.214, 21

	.type	.L.str.215,@object              # @.str.215
.L.str.215:
	.asciz	"default_asset.1.file"
	.size	.L.str.215, 21

	.type	DEFAULT_PI4_ASSET_MAP_PATH,@object # @DEFAULT_PI4_ASSET_MAP_PATH
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
DEFAULT_PI4_ASSET_MAP_PATH:
	.asciz	"/ASSETS/MAPS/E1M1.MAP"
	.size	DEFAULT_PI4_ASSET_MAP_PATH, 22

	.type	.L.str.216,@object              # @.str.216
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.216:
	.asciz	"default_asset.1.size"
	.size	.L.str.216, 21

	.type	.L.str.217,@object              # @.str.217
.L.str.217:
	.asciz	"default_asset.2.file"
	.size	.L.str.217, 21

	.type	DEFAULT_PI4_ASSET_PALETTE_PATH,@object # @DEFAULT_PI4_ASSET_PALETTE_PATH
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
DEFAULT_PI4_ASSET_PALETTE_PATH:
	.asciz	"/ASSETS/TEXTURES/PAL0.BIN"
	.size	DEFAULT_PI4_ASSET_PALETTE_PATH, 26

	.type	.L.str.218,@object              # @.str.218
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.218:
	.asciz	"default_asset.2.size"
	.size	.L.str.218, 21

	.type	.L.str.219,@object              # @.str.219
.L.str.219:
	.asciz	"asset_count"
	.size	.L.str.219, 12

	.type	.L.str.220,@object              # @.str.220
.L.str.220:
	.asciz	"asset"
	.size	.L.str.220, 6

	.type	.L.str.221,@object              # @.str.221
.L.str.221:
	.asciz	"quake_pak_file"
	.size	.L.str.221, 15

	.type	PROOF_QUAKE_PAK_PATH,@object    # @PROOF_QUAKE_PAK_PATH
	.section	.rodata,"a",@progbits
PROOF_QUAKE_PAK_PATH:
	.asciz	"/ID1/PAK0.PAK"
	.size	PROOF_QUAKE_PAK_PATH, 14

	.type	.L.str.222,@object              # @.str.222
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.222:
	.asciz	"quake_pak_kind"
	.size	.L.str.222, 15

	.type	.L.str.223,@object              # @.str.223
.L.str.223:
	.asciz	"quake-pak"
	.size	.L.str.223, 10

	.type	.L.str.224,@object              # @.str.224
.L.str.224:
	.asciz	"quake_pak_state"
	.size	.L.str.224, 16

	.type	.L.str.225,@object              # @.str.225
.L.str.225:
	.asciz	"Pi proof manifest is missing Quake PAK state"
	.size	.L.str.225, 45

	.type	.L.str.226,@object              # @.str.226
.L.str.226:
	.asciz	"absent"
	.size	.L.str.226, 7

	.type	.L.str.227,@object              # @.str.227
.L.str.227:
	.asciz	"quake_pak_source"
	.size	.L.str.227, 17

	.type	.L.str.228,@object              # @.str.228
.L.str.228:
	.asciz	"quake_pak_repo_state"
	.size	.L.str.228, 21

	.type	.L.str.229,@object              # @.str.229
.L.str.229:
	.asciz	"quake_pak_evidence"
	.size	.L.str.229, 19

	.type	.L.str.230,@object              # @.str.230
.L.str.230:
	.asciz	"quake_pak_hardware_proof"
	.size	.L.str.230, 25

	.type	.L.str.231,@object              # @.str.231
.L.str.231:
	.asciz	"manifest_asset=%s kind=quake-pak source=absent repo_state=absent evidence=absent hardware_proof=unclaimed state=absent\n"
	.size	.L.str.231, 120

	.type	.L.str.232,@object              # @.str.232
.L.str.232:
	.asciz	"quake_pak_size"
	.size	.L.str.232, 15

	.type	.L.str.233,@object              # @.str.233
.L.str.233:
	.asciz	"manifest_asset=%s kind=quake-pak source=external repo_state=outside-repo evidence=packaged-file-only hardware_proof=unclaimed state=present\n"
	.size	.L.str.233, 141

	.type	.L.str.234,@object              # @.str.234
.L.str.234:
	.asciz	"Pi proof manifest Quake PAK state must be present or absent"
	.size	.L.str.234, 60

	.type	.L.str.235,@object              # @.str.235
.L.str.235:
	.asciz	"manifest_asset_handoff=OK primary_asset_state=present primary_asset_source=%s primary_asset_evidence=packaged-file-only primary_asset_hardware_proof=unclaimed quake_pak_state=%s quake_pak_evidence=%s quake_pak_hardware_proof=unclaimed\n"
	.size	.L.str.235, 236

	.type	.L.str.236,@object              # @.str.236
.L.str.236:
	.asciz	"real Pi asset proof requires an external outside-repo Doom WAD"
	.size	.L.str.236, 63

	.type	.L.str.237,@object              # @.str.237
.L.str.237:
	.asciz	"real Pi asset proof requires an external outside-repo Quake PAK"
	.size	.L.str.237, 64

	.type	.L.str.238,@object              # @.str.238
.L.str.238:
	.asciz	"real Pi asset proof requires checked_files to include /ID1/PAK0.PAK"
	.size	.L.str.238, 68

	.type	.L.str.240,@object              # @.str.240
.L.str.240:
	.asciz	"pi4_manifest=OK checked_files=%zu\n"
	.size	.L.str.240, 35

	.type	.L.str.241,@object              # @.str.241
.L.str.241:
	.asciz	"expected a file, found a directory"
	.size	.L.str.241, 35

	.type	.L.str.242,@object              # @.str.242
.L.str.242:
	.asciz	"Pi proof manifest is missing a required field"
	.size	.L.str.242, 46

	.type	.L.str.243,@object              # @.str.243
.L.str.243:
	.asciz	"Pi proof manifest field does not match the boot artifact"
	.size	.L.str.243, 57

	.type	.L.str.244,@object              # @.str.244
.L.str.244:
	.asciz	"Pi proof manifest numeric field does not match the boot artifact"
	.size	.L.str.244, 65

	.type	.L.str.245,@object              # @.str.245
.L.str.245:
	.asciz	"Pi proof manifest is missing a required size field"
	.size	.L.str.245, 51

	.type	.L.str.246,@object              # @.str.246
.L.str.246:
	.asciz	"Pi proof manifest size field is not decimal"
	.size	.L.str.246, 44

	.type	.L.str.247,@object              # @.str.247
.L.str.247:
	.asciz	"Pi proof manifest is missing a command-visible field"
	.size	.L.str.247, 53

	.type	.L.str.248,@object              # @.str.248
.L.str.248:
	.asciz	"%s=%s\n"
	.size	.L.str.248, 7

	.type	.L.str.249,@object              # @.str.249
.L.str.249:
	.asciz	"Pi proof manifest names a file missing from the FAT image"
	.size	.L.str.249, 58

	.type	.L.str.250,@object              # @.str.250
.L.str.250:
	.asciz	"Pi proof manifest expected a file, found a directory"
	.size	.L.str.250, 53

	.type	.L.str.251,@object              # @.str.251
.L.str.251:
	.asciz	"Pi proof manifest file is empty"
	.size	.L.str.251, 32

	.type	.L.str.252,@object              # @.str.252
.L.str.252:
	.asciz	"manifest_file=%s state=present size=%u cluster=%u\n"
	.size	.L.str.252, 51

	.type	.L.str.253,@object              # @.str.253
.L.str.253:
	.asciz	"Pi proof manifest file size does not match the FAT image"
	.size	.L.str.253, 57

	.type	.L.str.255,@object              # @.str.255
.L.str.255:
	.asciz	"vibe-os-app-index-v1"
	.size	.L.str.255, 21

	.type	.L.str.256,@object              # @.str.256
.L.str.256:
	.asciz	"app_count"
	.size	.L.str.256, 10

	.type	.L.str.257,@object              # @.str.257
.L.str.257:
	.asciz	"Pi app index app_count is outside the supported app catalog"
	.size	.L.str.257, 60

	.type	.L.str.258,@object              # @.str.258
.L.str.258:
	.asciz	"app"
	.size	.L.str.258, 4

	.type	.L.str.259,@object              # @.str.259
.L.str.259:
	.asciz	"id"
	.size	.L.str.259, 3

	.type	.L.str.260,@object              # @.str.260
.L.str.260:
	.asciz	"manifest"
	.size	.L.str.260, 9

	.type	.L.str.261,@object              # @.str.261
.L.str.261:
	.asciz	"vibe-os-app-v1"
	.size	.L.str.261, 15

	.type	.L.str.262,@object              # @.str.262
.L.str.262:
	.asciz	"make_wad_image: %s: app id does not match /APPS/INDEX.TXT\n"
	.size	.L.str.262, 59

	.type	.L.str.263,@object              # @.str.263
.L.str.263:
	.asciz	"name"
	.size	.L.str.263, 5

	.type	.L.str.264,@object              # @.str.264
.L.str.264:
	.asciz	"exec"
	.size	.L.str.264, 5

	.type	.L.str.265,@object              # @.str.265
.L.str.265:
	.asciz	"icon"
	.size	.L.str.265, 5

	.type	.L.str.266,@object              # @.str.266
.L.str.266:
	.asciz	"input"
	.size	.L.str.266, 6

	.type	.L.str.267,@object              # @.str.267
.L.str.267:
	.asciz	"Pi app manifest exec target is missing from the FAT image"
	.size	.L.str.267, 58

	.type	.L.str.268,@object              # @.str.268
.L.str.268:
	.asciz	"Pi app manifest exec target must be a nonempty file"
	.size	.L.str.268, 52

	.type	.L.str.269,@object              # @.str.269
.L.str.269:
	.asciz	"Pi app manifest resource must be a nonempty file"
	.size	.L.str.269, 49

	.type	.L.str.270,@object              # @.str.270
.L.str.270:
	.asciz	"real Pi app layout requires the manifest resource file"
	.size	.L.str.270, 55

	.type	.L.str.271,@object              # @.str.271
.L.str.271:
	.asciz	"Pi app layout names a file missing from the FAT image"
	.size	.L.str.271, 54

	.type	.L.str.272,@object              # @.str.272
.L.str.272:
	.asciz	"Pi app layout expected a file, found a directory"
	.size	.L.str.272, 49

	.type	.L.str.273,@object              # @.str.273
.L.str.273:
	.asciz	"Pi app layout file is empty"
	.size	.L.str.273, 28

	.type	.L.str.274,@object              # @.str.274
.L.str.274:
	.asciz	"make_wad_image: %s: app manifest field %s does not match image layout\n"
	.size	.L.str.274, 71

	.type	.L.str.275,@object              # @.str.275
.L.str.275:
	.asciz	"make_wad_image: %s: app manifest field %s is not decimal\n"
	.size	.L.str.275, 58

	.type	.L.str.276,@object              # @.str.276
.L.str.276:
	.asciz	"%s.%zu.%s"
	.size	.L.str.276, 10

	.type	.L.str.277,@object              # @.str.277
.L.str.277:
	.asciz	"manifest indexed key is too long"
	.size	.L.str.277, 33

	.type	.L.str.278,@object              # @.str.278
.L.str.278:
	.asciz	"make_wad_image: %s: missing app manifest field %s\n"
	.size	.L.str.278, 51

	.type	.L.str.279,@object              # @.str.279
.L.str.279:
	.asciz	"make_wad_image: %s: empty app manifest field %s\n"
	.size	.L.str.279, 49

	.type	.L.str.280,@object              # @.str.280
.L.str.280:
	.asciz	"app_index_manifest=%s state=present schema=vibe-os-app-index-v1 app_count=%zu discovery=%s\n"
	.size	.L.str.280, 92

	.type	.L.str.281,@object              # @.str.281
.L.str.281:
	.asciz	"manifest_size"
	.size	.L.str.281, 14

	.type	.L.str.282,@object              # @.str.282
.L.str.282:
	.asciz	"exec_size"
	.size	.L.str.282, 10

	.type	.L.str.283,@object              # @.str.283
.L.str.283:
	.asciz	"launch"
	.size	.L.str.283, 7

	.type	PI4_APP_LAUNCH_MODEL,@object    # @PI4_APP_LAUNCH_MODEL
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
PI4_APP_LAUNCH_MODEL:
	.asciz	"generic-path-exec"
	.size	PI4_APP_LAUNCH_MODEL, 18

	.type	.L.str.284,@object              # @.str.284
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.284:
	.asciz	"exec_model"
	.size	.L.str.284, 11

	.type	.L.str.285,@object              # @.str.285
.L.str.285:
	.asciz	"resource"
	.size	.L.str.285, 9

	.type	.L.str.286,@object              # @.str.286
.L.str.286:
	.asciz	"hardware_proof"
	.size	.L.str.286, 15

	.type	.L.str.287,@object              # @.str.287
.L.str.287:
	.asciz	"%s=%zu state=present id=%s manifest=%s exec=%s resource=%s icon=%s launch=%s exec_model=%s\n"
	.size	.L.str.287, 92

	.type	.L.str.288,@object              # @.str.288
.L.str.288:
	.asciz	"app_manifest=%s state=present id=%s exec=%s icon=%s resource=%s input=%s\n"
	.size	.L.str.288, 74

	.type	.L.str.289,@object              # @.str.289
.L.str.289:
	.asciz	"app_exec=%s state=present model=%s app=%s size=%u cluster=%u\n"
	.size	.L.str.289, 62

	.type	.L.str.290,@object              # @.str.290
.L.str.290:
	.asciz	"app_icon=%s state=manifest app=%s\n"
	.size	.L.str.290, 35

	.type	.L.str.291,@object              # @.str.291
.L.str.291:
	.asciz	"app_resource=%s state=present app=%s source=manifest size=%u cluster=%u\n"
	.size	.L.str.291, 73

	.type	.L.str.292,@object              # @.str.292
.L.str.292:
	.asciz	"app_resource=%s state=absent app=%s source=manifest\n"
	.size	.L.str.292, 53

	.type	.L.str.293,@object              # @.str.293
.L.str.293:
	.asciz	"Pi proof manifest count is too large"
	.size	.L.str.293, 37

	.type	.L.str.294,@object              # @.str.294
.L.str.294:
	.asciz	"%s.%zu.file"
	.size	.L.str.294, 12

	.type	.L.str.295,@object              # @.str.295
.L.str.295:
	.asciz	"Pi proof manifest key is too long"
	.size	.L.str.295, 34

	.type	.L.str.296,@object              # @.str.296
.L.str.296:
	.asciz	"%s.%zu.size"
	.size	.L.str.296, 12

	.type	.L.str.297,@object              # @.str.297
.L.str.297:
	.asciz	"Pi proof manifest is missing an indexed file"
	.size	.L.str.297, 45

	.type	.L.str.298,@object              # @.str.298
.L.str.298:
	.asciz	"Pi proof manifest value is too long"
	.size	.L.str.298, 36

	.type	.L.str.299,@object              # @.str.299
.L.str.299:
	.asciz	"%s.%zu.kind"
	.size	.L.str.299, 12

	.type	.L.str.300,@object              # @.str.300
.L.str.300:
	.asciz	"%s.%zu.source"
	.size	.L.str.300, 14

	.type	.L.str.301,@object              # @.str.301
.L.str.301:
	.asciz	"%s.%zu.repo_state"
	.size	.L.str.301, 18

	.type	.L.str.302,@object              # @.str.302
.L.str.302:
	.asciz	"%s.%zu.evidence"
	.size	.L.str.302, 16

	.type	.L.str.303,@object              # @.str.303
.L.str.303:
	.asciz	"%s.%zu.hardware_proof"
	.size	.L.str.303, 22

	.type	.L.str.304,@object              # @.str.304
.L.str.304:
	.asciz	"external-host-input"
	.size	.L.str.304, 20

	.type	.L.str.305,@object              # @.str.305
.L.str.305:
	.asciz	"quake-pak0"
	.size	.L.str.305, 11

	.type	.L.str.306,@object              # @.str.306
.L.str.306:
	.asciz	"generic-external-asset"
	.size	.L.str.306, 23

	.type	.L.str.307,@object              # @.str.307
.L.str.307:
	.asciz	"unchecked"
	.size	.L.str.307, 10

	.type	.L.str.308,@object              # @.str.308
.L.str.308:
	.asciz	"stage1, stage2, and kernel paths must be provided together"
	.size	.L.str.308, 59

	.type	.L.str.309,@object              # @.str.309
.L.str.309:
	.asciz	"external Doom WAD"
	.size	.L.str.309, 18

	.type	.L.str.310,@object              # @.str.310
.L.str.310:
	.asciz	"primary WAD asset (DOOM1.WAD) must start at cluster 2"
	.size	.L.str.310, 54

	.type	DEFAULT_CFG_CONTENT,@object     # @DEFAULT_CFG_CONTENT
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
DEFAULT_CFG_CONTENT:
	.asciz	"screenblocks\t\t11\n"
	.size	DEFAULT_CFG_CONTENT, 18

	.type	.L.str.311,@object              # @.str.311
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.311:
	.asciz	"FAT16 image does not leave enough OS-created file headroom"
	.size	.L.str.311, 59

	.type	.L.str.312,@object              # @.str.312
.L.str.312:
	.asciz	"stage1 must be exactly 512 bytes"
	.size	.L.str.312, 33

	.type	.L.str.313,@object              # @.str.313
.L.str.313:
	.asciz	"stage2"
	.size	.L.str.313, 7

	.type	.L.str.314,@object              # @.str.314
.L.str.314:
	.asciz	"kernel"
	.size	.L.str.314, 7

	.type	FAT_VOLUME_LABEL,@object        # @FAT_VOLUME_LABEL
FAT_VOLUME_LABEL:
	.asciz	"VIBEOS WAD "
	.size	FAT_VOLUME_LABEL, 12

	.type	.L.str.316,@object              # @.str.316
.L.str.316:
	.asciz	"make_wad_image: %s is %zu bytes, exceeds %zu bytes\n"
	.size	.L.str.316, 52

	.type	.L.str.317,@object              # @.str.317
.L.str.317:
	.asciz	"make_wad_image: %s: %s must stay outside the repo for Pi proof packaging\n"
	.size	.L.str.317, 74

	.type	.L.str.318,@object              # @.str.318
.L.str.318:
	.asciz	"WAD exceeds primary asset load limit"
	.size	.L.str.318, 37

	.type	.L.str.319,@object              # @.str.319
.L.str.319:
	.asciz	"too small to be a WAD"
	.size	.L.str.319, 22

	.type	.L.str.320,@object              # @.str.320
.L.str.320:
	.asciz	"IWAD"
	.size	.L.str.320, 5

	.type	.L.str.321,@object              # @.str.321
.L.str.321:
	.asciz	"PWAD"
	.size	.L.str.321, 5

	.type	.L.str.322,@object              # @.str.322
.L.str.322:
	.asciz	"does not start with IWAD or PWAD"
	.size	.L.str.322, 33

	.type	.L.str.323,@object              # @.str.323
.L.str.323:
	.asciz	"WAD has no lumps"
	.size	.L.str.323, 17

	.type	.L.str.324,@object              # @.str.324
.L.str.324:
	.asciz	"WAD directory is outside the file"
	.size	.L.str.324, 34

	.type	.L.str.325,@object              # @.str.325
.L.str.325:
	.asciz	"WAD marker lump points outside the file"
	.size	.L.str.325, 40

	.type	.L.str.326,@object              # @.str.326
.L.str.326:
	.asciz	"WAD lump data is outside the file"
	.size	.L.str.326, 34

	.type	.L.str.327,@object              # @.str.327
.L.str.327:
	.asciz	"F_SKY1"
	.size	.L.str.327, 7

	.type	.L.str.328,@object              # @.str.328
.L.str.328:
	.asciz	"PLAYPAL"
	.size	.L.str.328, 8

	.type	.L.str.330,@object              # @.str.330
.L.str.330:
	.asciz	"PNAMES"
	.size	.L.str.330, 7

	.type	.L.str.332,@object              # @.str.332
.L.str.332:
	.asciz	"F_START"
	.size	.L.str.332, 8

	.type	.L.str.333,@object              # @.str.333
.L.str.333:
	.asciz	"F_END"
	.size	.L.str.333, 6

	.type	.L.str.334,@object              # @.str.334
.L.str.334:
	.asciz	"S_START"
	.size	.L.str.334, 8

	.type	.L.str.335,@object              # @.str.335
.L.str.335:
	.asciz	"S_END"
	.size	.L.str.335, 6

	.type	.L.str.337,@object              # @.str.337
.L.str.337:
	.asciz	"D_INTRO"
	.size	.L.str.337, 8

	.type	FIXTURE_MUS_SCORE_END,@object   # @FIXTURE_MUS_SCORE_END
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
FIXTURE_MUS_SCORE_END:
	.ascii	"MUS\032\001\000\020\000\001\000\000\000\000\000\000\000`"
	.size	FIXTURE_MUS_SCORE_END, 17

	.type	.L.str.338,@object              # @.str.338
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.338:
	.asciz	"D_E1M1"
	.size	.L.str.338, 7

	.type	.L.str.340,@object              # @.str.340
.L.str.340:
	.asciz	"THINGS"
	.size	.L.str.340, 7

	.type	.L.str.346,@object              # @.str.346
.L.str.346:
	.asciz	"NODES"
	.size	.L.str.346, 6

	.type	.L.str.347,@object              # @.str.347
.L.str.347:
	.asciz	"SECTORS"
	.size	.L.str.347, 8

	.type	.L.str.348,@object              # @.str.348
.L.str.348:
	.asciz	"REJECT"
	.size	.L.str.348, 7

	.type	.L__const.build_generated_wad.pattern,@object # @__const.build_generated_wad.pattern
	.section	.rodata.str1.16,"aMS",@progbits,1
	.p2align	4, 0x0
.L__const.build_generated_wad.pattern:
	.asciz	"vibe-os hard-path IDE FAT16 WAD fixture\n"
	.size	.L__const.build_generated_wad.pattern, 41

	.type	switch_textures,@object         # @switch_textures
	.section	.data.rel.ro,"aw",@progbits
	.p2align	4, 0x0
switch_textures:
	.quad	.L.str.351
	.quad	.L.str.352
	.quad	.L.str.353
	.quad	.L.str.354
	.quad	.L.str.355
	.quad	.L.str.356
	.quad	.L.str.357
	.quad	.L.str.358
	.quad	.L.str.359
	.quad	.L.str.360
	.quad	.L.str.361
	.quad	.L.str.362
	.quad	.L.str.363
	.quad	.L.str.364
	.quad	.L.str.365
	.quad	.L.str.366
	.quad	.L.str.367
	.quad	.L.str.368
	.quad	.L.str.369
	.quad	.L.str.370
	.quad	.L.str.371
	.quad	.L.str.372
	.quad	.L.str.373
	.quad	.L.str.374
	.quad	.L.str.375
	.quad	.L.str.376
	.quad	.L.str.377
	.quad	.L.str.378
	.quad	.L.str.379
	.quad	.L.str.380
	.quad	.L.str.381
	.quad	.L.str.382
	.quad	.L.str.383
	.quad	.L.str.384
	.quad	.L.str.385
	.quad	.L.str.386
	.quad	.L.str.387
	.quad	.L.str.388
	.quad	.L.str.389
	.quad	.L.str.390
	.quad	.L.str.391
	.quad	.L.str.392
	.size	switch_textures, 336

	.type	.L.str.351,@object              # @.str.351
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.351:
	.asciz	"SW1BRCOM"
	.size	.L.str.351, 9

	.type	.L.str.352,@object              # @.str.352
.L.str.352:
	.asciz	"SW2BRCOM"
	.size	.L.str.352, 9

	.type	.L.str.353,@object              # @.str.353
.L.str.353:
	.asciz	"SW1BRN1"
	.size	.L.str.353, 8

	.type	.L.str.354,@object              # @.str.354
.L.str.354:
	.asciz	"SW2BRN1"
	.size	.L.str.354, 8

	.type	.L.str.355,@object              # @.str.355
.L.str.355:
	.asciz	"SW1BRN2"
	.size	.L.str.355, 8

	.type	.L.str.356,@object              # @.str.356
.L.str.356:
	.asciz	"SW2BRN2"
	.size	.L.str.356, 8

	.type	.L.str.357,@object              # @.str.357
.L.str.357:
	.asciz	"SW1BRNGN"
	.size	.L.str.357, 9

	.type	.L.str.358,@object              # @.str.358
.L.str.358:
	.asciz	"SW2BRNGN"
	.size	.L.str.358, 9

	.type	.L.str.359,@object              # @.str.359
.L.str.359:
	.asciz	"SW1BROWN"
	.size	.L.str.359, 9

	.type	.L.str.360,@object              # @.str.360
.L.str.360:
	.asciz	"SW2BROWN"
	.size	.L.str.360, 9

	.type	.L.str.361,@object              # @.str.361
.L.str.361:
	.asciz	"SW1COMM"
	.size	.L.str.361, 8

	.type	.L.str.362,@object              # @.str.362
.L.str.362:
	.asciz	"SW2COMM"
	.size	.L.str.362, 8

	.type	.L.str.363,@object              # @.str.363
.L.str.363:
	.asciz	"SW1COMP"
	.size	.L.str.363, 8

	.type	.L.str.364,@object              # @.str.364
.L.str.364:
	.asciz	"SW2COMP"
	.size	.L.str.364, 8

	.type	.L.str.365,@object              # @.str.365
.L.str.365:
	.asciz	"SW1DIRT"
	.size	.L.str.365, 8

	.type	.L.str.366,@object              # @.str.366
.L.str.366:
	.asciz	"SW2DIRT"
	.size	.L.str.366, 8

	.type	.L.str.367,@object              # @.str.367
.L.str.367:
	.asciz	"SW1EXIT"
	.size	.L.str.367, 8

	.type	.L.str.368,@object              # @.str.368
.L.str.368:
	.asciz	"SW2EXIT"
	.size	.L.str.368, 8

	.type	.L.str.369,@object              # @.str.369
.L.str.369:
	.asciz	"SW1GRAY"
	.size	.L.str.369, 8

	.type	.L.str.370,@object              # @.str.370
.L.str.370:
	.asciz	"SW2GRAY"
	.size	.L.str.370, 8

	.type	.L.str.371,@object              # @.str.371
.L.str.371:
	.asciz	"SW1GRAY1"
	.size	.L.str.371, 9

	.type	.L.str.372,@object              # @.str.372
.L.str.372:
	.asciz	"SW2GRAY1"
	.size	.L.str.372, 9

	.type	.L.str.373,@object              # @.str.373
.L.str.373:
	.asciz	"SW1METAL"
	.size	.L.str.373, 9

	.type	.L.str.374,@object              # @.str.374
.L.str.374:
	.asciz	"SW2METAL"
	.size	.L.str.374, 9

	.type	.L.str.375,@object              # @.str.375
.L.str.375:
	.asciz	"SW1PIPE"
	.size	.L.str.375, 8

	.type	.L.str.376,@object              # @.str.376
.L.str.376:
	.asciz	"SW2PIPE"
	.size	.L.str.376, 8

	.type	.L.str.377,@object              # @.str.377
.L.str.377:
	.asciz	"SW1SLAD"
	.size	.L.str.377, 8

	.type	.L.str.378,@object              # @.str.378
.L.str.378:
	.asciz	"SW2SLAD"
	.size	.L.str.378, 8

	.type	.L.str.379,@object              # @.str.379
.L.str.379:
	.asciz	"SW1STARG"
	.size	.L.str.379, 9

	.type	.L.str.380,@object              # @.str.380
.L.str.380:
	.asciz	"SW2STARG"
	.size	.L.str.380, 9

	.type	.L.str.381,@object              # @.str.381
.L.str.381:
	.asciz	"SW1STON1"
	.size	.L.str.381, 9

	.type	.L.str.382,@object              # @.str.382
.L.str.382:
	.asciz	"SW2STON1"
	.size	.L.str.382, 9

	.type	.L.str.383,@object              # @.str.383
.L.str.383:
	.asciz	"SW1STON2"
	.size	.L.str.383, 9

	.type	.L.str.384,@object              # @.str.384
.L.str.384:
	.asciz	"SW2STON2"
	.size	.L.str.384, 9

	.type	.L.str.385,@object              # @.str.385
.L.str.385:
	.asciz	"SW1STONE"
	.size	.L.str.385, 9

	.type	.L.str.386,@object              # @.str.386
.L.str.386:
	.asciz	"SW2STONE"
	.size	.L.str.386, 9

	.type	.L.str.387,@object              # @.str.387
.L.str.387:
	.asciz	"SW1STRTN"
	.size	.L.str.387, 9

	.type	.L.str.388,@object              # @.str.388
.L.str.388:
	.asciz	"SW2STRTN"
	.size	.L.str.388, 9

	.type	.L.str.389,@object              # @.str.389
.L.str.389:
	.asciz	"SKY1"
	.size	.L.str.389, 5

	.type	.L.str.390,@object              # @.str.390
.L.str.390:
	.asciz	"SKY2"
	.size	.L.str.390, 5

	.type	.L.str.391,@object              # @.str.391
.L.str.391:
	.asciz	"SKY3"
	.size	.L.str.391, 5

	.type	.L.str.392,@object              # @.str.392
.L.str.392:
	.asciz	"SKY4"
	.size	.L.str.392, 5

	.type	.L.str.394,@object              # @.str.394
.L.str.394:
	.asciz	"WAD lump name too long"
	.size	.L.str.394, 23

	.type	.L.str.396,@object              # @.str.396
.L.str.396:
	.asciz	"PUNGA0"
	.size	.L.str.396, 7

	.type	.L.str.397,@object              # @.str.397
.L.str.397:
	.asciz	"PUNGB0"
	.size	.L.str.397, 7

	.type	.L.str.398,@object              # @.str.398
.L.str.398:
	.asciz	"PUNGC0"
	.size	.L.str.398, 7

	.type	.L.str.399,@object              # @.str.399
.L.str.399:
	.asciz	"PUNGD0"
	.size	.L.str.399, 7

	.type	.L.str.400,@object              # @.str.400
.L.str.400:
	.asciz	"PISGA0"
	.size	.L.str.400, 7

	.type	.L.str.401,@object              # @.str.401
.L.str.401:
	.asciz	"PISGB0"
	.size	.L.str.401, 7

	.type	.L.str.402,@object              # @.str.402
.L.str.402:
	.asciz	"PISGC0"
	.size	.L.str.402, 7

	.type	.L.str.403,@object              # @.str.403
.L.str.403:
	.asciz	"PISFA0"
	.size	.L.str.403, 7

	.type	.L.str.404,@object              # @.str.404
.L.str.404:
	.asciz	"PLAYA0"
	.size	.L.str.404, 7

	.type	.L.str.405,@object              # @.str.405
.L.str.405:
	.asciz	"STCFN%03d"
	.size	.L.str.405, 10

	.type	.L.str.406,@object              # @.str.406
.L.str.406:
	.asciz	"STTNUM%d"
	.size	.L.str.406, 9

	.type	.L.str.408,@object              # @.str.408
.L.str.408:
	.asciz	"STYSNUM%d"
	.size	.L.str.408, 10

	.type	.L.str.410,@object              # @.str.410
.L.str.410:
	.asciz	"STKEYS%d"
	.size	.L.str.410, 9

	.type	.L.str.411,@object              # @.str.411
.L.str.411:
	.asciz	"STARMS"
	.size	.L.str.411, 7

	.type	.L.str.412,@object              # @.str.412
.L.str.412:
	.asciz	"STGNUM%d"
	.size	.L.str.412, 9

	.type	.L.str.413,@object              # @.str.413
.L.str.413:
	.asciz	"STFB0"
	.size	.L.str.413, 6

	.type	.L.str.414,@object              # @.str.414
.L.str.414:
	.asciz	"STBAR"
	.size	.L.str.414, 6

	.type	.L.str.415,@object              # @.str.415
.L.str.415:
	.asciz	"STFST%d%d"
	.size	.L.str.415, 10

	.type	.L.str.416,@object              # @.str.416
.L.str.416:
	.asciz	"STFTR%d0"
	.size	.L.str.416, 9

	.type	.L.str.417,@object              # @.str.417
.L.str.417:
	.asciz	"STFTL%d0"
	.size	.L.str.417, 9

	.type	.L.str.418,@object              # @.str.418
.L.str.418:
	.asciz	"STFOUCH%d"
	.size	.L.str.418, 10

	.type	.L.str.419,@object              # @.str.419
.L.str.419:
	.asciz	"STFEVL%d"
	.size	.L.str.419, 9

	.type	.L.str.420,@object              # @.str.420
.L.str.420:
	.asciz	"STFKILL%d"
	.size	.L.str.420, 10

	.type	.L.str.421,@object              # @.str.421
.L.str.421:
	.asciz	"STFGOD0"
	.size	.L.str.421, 8

	.type	.L.str.424,@object              # @.str.424
.L.str.424:
	.asciz	"CREDIT"
	.size	.L.str.424, 7

	.type	.L.str.425,@object              # @.str.425
.L.str.425:
	.asciz	"HELP2"
	.size	.L.str.425, 6

	.type	.L.str.426,@object              # @.str.426
.L.str.426:
	.asciz	"FAT16 root directory is full"
	.size	.L.str.426, 29

	.type	.L.str.427,@object              # @.str.427
.L.str.427:
	.asciz	"%s"
	.size	.L.str.427, 3

	.type	.L.str.428,@object              # @.str.428
.L.str.428:
	.asciz	"manifest file name is too long"
	.size	.L.str.428, 31

	.type	STATE_DIR_NAME,@object          # @STATE_DIR_NAME
STATE_DIR_NAME:
	.asciz	"STATE      "
	.size	STATE_DIR_NAME, 12

	.type	DEFAULT_PI4_ASSET_README,@object # @DEFAULT_PI4_ASSET_README
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
DEFAULT_PI4_ASSET_README:
	.asciz	"vibe-os FAT16 one-level asset file\n"
	.size	DEFAULT_PI4_ASSET_README, 36

	.type	DEFAULT_PI4_ASSET_MAP,@object   # @DEFAULT_PI4_ASSET_MAP
	.p2align	4, 0x0
DEFAULT_PI4_ASSET_MAP:
	.asciz	"name=E1M1\nmusic=D_E1M1\n"
	.size	DEFAULT_PI4_ASSET_MAP, 24

	.type	.L.str.429,@object              # @.str.429
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.429:
	.asciz	"--asset path must include a directory component"
	.size	.L.str.429, 48

	.type	.L.str.430,@object              # @.str.430
.L.str.430:
	.asciz	"external Quake PAK"
	.size	.L.str.430, 19

	.type	QUAKE_ID1_DIR_NAME,@object      # @QUAKE_ID1_DIR_NAME
	.section	.rodata,"a",@progbits
QUAKE_ID1_DIR_NAME:
	.asciz	"ID1        "
	.size	QUAKE_ID1_DIR_NAME, 12

	.type	QUAKE_PAK0_NAME,@object         # @QUAKE_PAK0_NAME
QUAKE_PAK0_NAME:
	.asciz	"PAK0    PAK"
	.size	QUAKE_PAK0_NAME, 12

	.type	.L.str.431,@object              # @.str.431
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.431:
	.asciz	"too small to be a Quake PAK"
	.size	.L.str.431, 28

	.type	.L.str.432,@object              # @.str.432
.L.str.432:
	.asciz	"PACK"
	.size	.L.str.432, 5

	.type	.L.str.433,@object              # @.str.433
.L.str.433:
	.asciz	"does not start with PACK"
	.size	.L.str.433, 25

	.type	.L.str.434,@object              # @.str.434
.L.str.434:
	.asciz	"PAK directory size is invalid"
	.size	.L.str.434, 30

	.type	.L.str.435,@object              # @.str.435
.L.str.435:
	.asciz	"PAK directory is outside the file"
	.size	.L.str.435, 34

	.type	.L.str.436,@object              # @.str.436
.L.str.436:
	.asciz	"PAK entry has an empty name"
	.size	.L.str.436, 28

	.type	.L.str.437,@object              # @.str.437
.L.str.437:
	.asciz	"PAK entry data is outside the file"
	.size	.L.str.437, 35

	.type	PI4_KERNEL8_IMG_NAME,@object    # @PI4_KERNEL8_IMG_NAME
	.section	.rodata,"a",@progbits
PI4_KERNEL8_IMG_NAME:
	.asciz	"KERNEL8 IMG"
	.size	PI4_KERNEL8_IMG_NAME, 12

	.type	PI4_CONFIG_TXT_NAME,@object     # @PI4_CONFIG_TXT_NAME
PI4_CONFIG_TXT_NAME:
	.asciz	"CONFIG  TXT"
	.size	PI4_CONFIG_TXT_NAME, 12

	.type	.L.str.438,@object              # @.str.438
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.438:
	.asciz	"make_wad_image: Pi proof manifest requires system ELFs under /SYSTEM, not root ELF fallbacks\n"
	.size	.L.str.438, 94

	.type	.L.str.439,@object              # @.str.439
.L.str.439:
	.asciz	"schema=vibe-os-pi4-image-manifest-v1\n"
	.size	.L.str.439, 38

	.type	.L.str.440,@object              # @.str.440
.L.str.440:
	.asciz	"layout=vibe-os-pi4-fat16-v1\n"
	.size	.L.str.440, 29

	.type	.L.str.441,@object              # @.str.441
.L.str.441:
	.asciz	"manifest_path=%s\n"
	.size	.L.str.441, 18

	.type	.L.str.442,@object              # @.str.442
.L.str.442:
	.asciz	"kernel_file=%s\n"
	.size	.L.str.442, 16

	.type	.L.str.443,@object              # @.str.443
.L.str.443:
	.asciz	"kernel_size=%zu\n"
	.size	.L.str.443, 17

	.type	.L.str.444,@object              # @.str.444
.L.str.444:
	.asciz	"kernel_file=absent\n"
	.size	.L.str.444, 20

	.type	.L.str.445,@object              # @.str.445
.L.str.445:
	.asciz	"config_file=%s\n"
	.size	.L.str.445, 16

	.type	.L.str.446,@object              # @.str.446
.L.str.446:
	.asciz	"config_size=%zu\n"
	.size	.L.str.446, 17

	.type	.L.str.447,@object              # @.str.447
.L.str.447:
	.asciz	"config_file=absent\n"
	.size	.L.str.447, 20

	.type	.L.str.448,@object              # @.str.448
.L.str.448:
	.asciz	"app_model_schema=vibe-os-pi4-app-install-v1\n"
	.size	.L.str.448, 45

	.type	.L.str.449,@object              # @.str.449
.L.str.449:
	.asciz	"app_layout=%s\n"
	.size	.L.str.449, 15

	.type	.L.str.450,@object              # @.str.450
.L.str.450:
	.asciz	"app_discovery_model=%s\n"
	.size	.L.str.450, 24

	.type	.L.str.451,@object              # @.str.451
.L.str.451:
	.asciz	"app_launch_model=generic-vfs-path-exec\n"
	.size	.L.str.451, 40

	.type	.L.str.452,@object              # @.str.452
.L.str.452:
	.asciz	"app_exec_model=%s\n"
	.size	.L.str.452, 19

	.type	.L.str.453,@object              # @.str.453
.L.str.453:
	.asciz	"%s=%zu\n"
	.size	.L.str.453, 8

	.type	.L.str.454,@object              # @.str.454
.L.str.454:
	.asciz	"primary_asset_file=DOOM1.WAD\n"
	.size	.L.str.454, 30

	.type	.L.str.455,@object              # @.str.455
.L.str.455:
	.asciz	"primary_asset_kind=doom-wad\n"
	.size	.L.str.455, 29

	.type	.L.str.456,@object              # @.str.456
.L.str.456:
	.asciz	"primary_asset_state=present\n"
	.size	.L.str.456, 29

	.type	.L.str.457,@object              # @.str.457
.L.str.457:
	.asciz	"primary_asset_source=%s\n"
	.size	.L.str.457, 25

	.type	.L.str.458,@object              # @.str.458
.L.str.458:
	.asciz	"primary_asset_repo_state=%s\n"
	.size	.L.str.458, 29

	.type	.L.str.459,@object              # @.str.459
.L.str.459:
	.asciz	"primary_asset_evidence=packaged-file-only\n"
	.size	.L.str.459, 43

	.type	.L.str.460,@object              # @.str.460
.L.str.460:
	.asciz	"primary_asset_hardware_proof=unclaimed\n"
	.size	.L.str.460, 40

	.type	.L.str.461,@object              # @.str.461
.L.str.461:
	.asciz	"primary_asset_size=%zu\n"
	.size	.L.str.461, 24

	.type	.L.str.462,@object              # @.str.462
.L.str.462:
	.asciz	"default_asset_count=%u\n"
	.size	.L.str.462, 24

	.type	.L.str.463,@object              # @.str.463
.L.str.463:
	.asciz	"default_asset.0.file=%s\n"
	.size	.L.str.463, 25

	.type	.L.str.464,@object              # @.str.464
.L.str.464:
	.asciz	"default_asset.0.size=%zu\n"
	.size	.L.str.464, 26

	.type	.L.str.465,@object              # @.str.465
.L.str.465:
	.asciz	"default_asset.1.file=%s\n"
	.size	.L.str.465, 25

	.type	.L.str.466,@object              # @.str.466
.L.str.466:
	.asciz	"default_asset.1.size=%zu\n"
	.size	.L.str.466, 26

	.type	.L.str.467,@object              # @.str.467
.L.str.467:
	.asciz	"default_asset.2.file=%s\n"
	.size	.L.str.467, 25

	.type	.L.str.468,@object              # @.str.468
.L.str.468:
	.asciz	"default_asset.2.size=%u\n"
	.size	.L.str.468, 25

	.type	.L.str.469,@object              # @.str.469
.L.str.469:
	.asciz	"quake_pak_file=%s\n"
	.size	.L.str.469, 19

	.type	.L.str.470,@object              # @.str.470
.L.str.470:
	.asciz	"quake_pak_kind=quake-pak\n"
	.size	.L.str.470, 26

	.type	.L.str.471,@object              # @.str.471
.L.str.471:
	.asciz	"quake_pak_state=%s\n"
	.size	.L.str.471, 20

	.type	.L.str.472,@object              # @.str.472
.L.str.472:
	.asciz	"quake_pak_source=external\n"
	.size	.L.str.472, 27

	.type	.L.str.473,@object              # @.str.473
.L.str.473:
	.asciz	"quake_pak_repo_state=outside-repo\n"
	.size	.L.str.473, 35

	.type	.L.str.474,@object              # @.str.474
.L.str.474:
	.asciz	"quake_pak_evidence=packaged-file-only\n"
	.size	.L.str.474, 39

	.type	.L.str.475,@object              # @.str.475
.L.str.475:
	.asciz	"quake_pak_hardware_proof=unclaimed\n"
	.size	.L.str.475, 36

	.type	.L.str.476,@object              # @.str.476
.L.str.476:
	.asciz	"quake_pak_size=%zu\n"
	.size	.L.str.476, 20

	.type	.L.str.477,@object              # @.str.477
.L.str.477:
	.asciz	"quake_pak_source=absent\n"
	.size	.L.str.477, 25

	.type	.L.str.478,@object              # @.str.478
.L.str.478:
	.asciz	"quake_pak_repo_state=absent\n"
	.size	.L.str.478, 29

	.type	.L.str.479,@object              # @.str.479
.L.str.479:
	.asciz	"quake_pak_evidence=absent\n"
	.size	.L.str.479, 27

	.type	.L.str.480,@object              # @.str.480
.L.str.480:
	.asciz	"root_file_count=%zu\n"
	.size	.L.str.480, 21

	.type	.L.str.481,@object              # @.str.481
.L.str.481:
	.asciz	"root_file.%zu.file=%s\n"
	.size	.L.str.481, 23

	.type	.L.str.482,@object              # @.str.482
.L.str.482:
	.asciz	"root_file.%zu.size=%zu\n"
	.size	.L.str.482, 24

	.type	.L.str.483,@object              # @.str.483
.L.str.483:
	.asciz	"root_elf_count=%zu\n"
	.size	.L.str.483, 20

	.type	.L.str.484,@object              # @.str.484
.L.str.484:
	.asciz	"root_elf.%zu.file=%s\n"
	.size	.L.str.484, 22

	.type	.L.str.485,@object              # @.str.485
.L.str.485:
	.asciz	"root_elf.%zu.size=%zu\n"
	.size	.L.str.485, 23

	.type	.L.str.486,@object              # @.str.486
.L.str.486:
	.asciz	"asset_count=%zu\n"
	.size	.L.str.486, 17

	.type	.L.str.487,@object              # @.str.487
.L.str.487:
	.asciz	"asset.%zu.file=%s\n"
	.size	.L.str.487, 19

	.type	.L.str.488,@object              # @.str.488
.L.str.488:
	.asciz	"asset.%zu.kind=%s\n"
	.size	.L.str.488, 19

	.type	.L.str.489,@object              # @.str.489
.L.str.489:
	.asciz	"asset.%zu.source=external-host-input\n"
	.size	.L.str.489, 38

	.type	.L.str.490,@object              # @.str.490
.L.str.490:
	.asciz	"asset.%zu.repo_state=%s\n"
	.size	.L.str.490, 25

	.type	.L.str.491,@object              # @.str.491
.L.str.491:
	.asciz	"asset.%zu.evidence=packaged-file-only\n"
	.size	.L.str.491, 39

	.type	.L.str.492,@object              # @.str.492
.L.str.492:
	.asciz	"asset.%zu.hardware_proof=unclaimed\n"
	.size	.L.str.492, 36

	.type	.L.str.493,@object              # @.str.493
.L.str.493:
	.asciz	"asset.%zu.size=%zu\n"
	.size	.L.str.493, 20

	.type	.L.str.494,@object              # @.str.494
.L.str.494:
	.asciz	"root file"
	.size	.L.str.494, 10

	.type	.L.str.495,@object              # @.str.495
.L.str.495:
	.asciz	"make_wad_image: Pi proof manifest requires %s %s\n"
	.size	.L.str.495, 50

	.type	.L.str.496,@object              # @.str.496
.L.str.496:
	.asciz	"make_wad_image: Pi proof manifest %s %s is missing or empty\n"
	.size	.L.str.496, 61

	.type	.L.str.497,@object              # @.str.497
.L.str.497:
	.asciz	"make_wad_image: Pi proof manifest requires installed app file %s\n"
	.size	.L.str.497, 66

	.type	.L.str.498,@object              # @.str.498
.L.str.498:
	.asciz	"manifest formatting failed"
	.size	.L.str.498, 27

	.type	.L.str.499,@object              # @.str.499
.L.str.499:
	.asciz	"%s_size=%zu\n"
	.size	.L.str.499, 13

	.type	.L.str.500,@object              # @.str.500
.L.str.500:
	.asciz	"%s.%zu.id=%s\n"
	.size	.L.str.500, 14

	.type	.L.str.501,@object              # @.str.501
.L.str.501:
	.asciz	"%s.%zu.name=%s\n"
	.size	.L.str.501, 16

	.type	.L.str.502,@object              # @.str.502
.L.str.502:
	.asciz	"%s.%zu.manifest=%s\n"
	.size	.L.str.502, 20

	.type	.L.str.503,@object              # @.str.503
.L.str.503:
	.asciz	"%s.%zu.manifest_size=%zu\n"
	.size	.L.str.503, 26

	.type	.L.str.504,@object              # @.str.504
.L.str.504:
	.asciz	"%s.%zu.exec=%s\n"
	.size	.L.str.504, 16

	.type	.L.str.505,@object              # @.str.505
.L.str.505:
	.asciz	"%s.%zu.exec_size=%zu\n"
	.size	.L.str.505, 22

	.type	.L.str.506,@object              # @.str.506
.L.str.506:
	.asciz	"%s.%zu.launch=%s\n"
	.size	.L.str.506, 18

	.type	.L.str.507,@object              # @.str.507
.L.str.507:
	.asciz	"%s.%zu.exec_model=%s\n"
	.size	.L.str.507, 22

	.type	.L.str.508,@object              # @.str.508
.L.str.508:
	.asciz	"%s.%zu.resource=%s\n"
	.size	.L.str.508, 20

	.type	.L.str.509,@object              # @.str.509
.L.str.509:
	.asciz	"%s.%zu.asset=%s\n"
	.size	.L.str.509, 17

	.type	.L.str.510,@object              # @.str.510
.L.str.510:
	.asciz	"%s.%zu.icon=%s\n"
	.size	.L.str.510, 16

	.type	.L.str.511,@object              # @.str.511
.L.str.511:
	.asciz	"%s.%zu.hardware_proof=unclaimed\n"
	.size	.L.str.511, 33

	.type	.L.str.512,@object              # @.str.512
.L.str.512:
	.asciz	"wb"
	.size	.L.str.512, 3

	.type	.L.str.513,@object              # @.str.513
.L.str.513:
	.asciz	"write failed"
	.size	.L.str.513, 13

	.type	.Lstr,@object                   # @str
.Lstr:
	.asciz	"schema=vibe-os-c-persistence-proof-v1"
	.size	.Lstr, 38

	.type	.Lstr.514,@object               # @str.514
.Lstr.514:
	.asciz	"result=ok"
	.size	.Lstr.514, 10

	.type	.Lstr.515,@object               # @str.515
.Lstr.515:
	.asciz	"schema=vibe-os-c-image-inspect-v1"
	.size	.Lstr.515, 34

	.type	.Lstr.516,@object               # @str.516
.Lstr.516:
	.asciz	"real_asset_manifest=OK primary_asset_source=external primary_asset_repo_state=outside-repo quake_pak_source=external quake_pak_repo_state=outside-repo checked_files_include_pak=true"
	.size	.Lstr.516, 182

	.ident	"Apple clang version 21.0.0 (clang-2100.1.1.101)"
	.section	".note.GNU-stack","",@progbits
