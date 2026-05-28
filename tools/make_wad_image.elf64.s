	.file	"make_wad_image.elf64.s"
	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$131288, %rsp                   # imm = 0x200D8
	.cfi_def_cfa_offset 131344
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %r12
	movl	%edi, %r13d
	movslq	%edi, %rdi
	movl	$8, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_272
# %bb.1:
	movq	%rax, %r14
	cmpl	$4, %r13d
	movq	%r12, 32(%rsp)                  # 8-byte Spill
	movl	%r13d, 40(%rsp)                 # 4-byte Spill
	je	.LBB0_5
# %bb.2:
	cmpl	$5, %r13d
	jne	.LBB0_8
# %bb.3:
	movq	8(%r12), %rbx
	leaq	.L.str(%rip), %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_10
# %bb.4:
	movq	32(%r12), %rdi
	movq	16(%r12), %rsi
	movq	24(%r12), %rdx
	movl	$1, %ecx
	jmp	.LBB0_7
.LBB0_5:
	movq	8(%r12), %rbx
	leaq	.L.str.1(%rip), %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_10
# %bb.6:
	movq	16(%r12), %rsi
	movq	24(%r12), %rdi
	leaq	.L.str.2(%rip), %rdx
	xorl	%ecx, %ecx
.LBB0_7:
	callq	mutate_root_marker
	movq	%r14, %rdi
	jmp	.LBB0_236
.LBB0_8:
	cmpl	$3, %r13d
	jl	.LBB0_13
# %bb.9:
	movq	8(%r12), %rbx
.LBB0_10:
	leaq	.L.str.3(%rip), %rsi
	movq	%rbx, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_14
# %bb.11:
	movq	%r14, 64(%rsp)                  # 8-byte Spill
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 304(%rsp)
	movaps	%xmm0, 288(%rsp)
	movaps	%xmm0, 272(%rsp)
	movaps	%xmm0, 256(%rsp)
	movaps	%xmm0, 240(%rsp)
	movaps	%xmm0, 224(%rsp)
	movaps	%xmm0, 208(%rsp)
	movaps	%xmm0, 192(%rsp)
	movq	$0, 320(%rsp)
	movq	16(%r12), %rbx
	cmpl	$4, %r13d
	movq	%rbx, 48(%rsp)                  # 8-byte Spill
	jb	.LBB0_98
# %bb.12:
	movq	$0, 56(%rsp)                    # 8-byte Folded Spill
	movq	232(%rsp), %rax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	movq	224(%rsp), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	movq	208(%rsp), %rax
	movq	%rax, (%rsp)                    # 8-byte Spill
	movq	216(%rsp), %rax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movl	$3, %r15d
	leaq	.L.str.4(%rip), %rbx
	leaq	.L.str.5(%rip), %r12
	movl	$0, 76(%rsp)                    # 4-byte Folded Spill
	xorl	%r13d, %r13d
	xorl	%ebp, %ebp
	jmp	.LBB0_104
.LBB0_13:
	cmpl	$2, %r13d
	jne	.LBB0_284
.LBB0_14:
	movq	%r14, 64(%rsp)                  # 8-byte Spill
	movl	$1, %ebp
	movq	$0, (%rsp)                      # 8-byte Folded Spill
	movq	$0, 24(%rsp)                    # 8-byte Folded Spill
	movq	$0, 48(%rsp)                    # 8-byte Folded Spill
	xorl	%r15d, %r15d
	movq	$0, 16(%rsp)                    # 8-byte Folded Spill
	movq	$0, 8(%rsp)                     # 8-byte Folded Spill
	xorl	%r14d, %r14d
	jmp	.LBB0_17
.LBB0_15:                               #   in Loop: Header=BB0_17 Depth=1
	movl	$1, %r15d
	.p2align	4
.LBB0_16:                               #   in Loop: Header=BB0_17 Depth=1
	incl	%ebp
	cmpl	%r13d, %ebp
	jge	.LBB0_51
.LBB0_17:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_41 Depth 2
	movslq	%ebp, %rax
	movq	(%r12,%rax,8), %rbx
	movq	%rbx, %rdi
	leaq	.L.str.14(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_24
# %bb.18:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.15(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_24
# %bb.19:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.16(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_26
# %bb.20:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.17(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_28
# %bb.21:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.19(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_44
# %bb.22:                               #   in Loop: Header=BB0_17 Depth=1
	cmpb	$45, (%rbx)
	je	.LBB0_266
# %bb.23:                               #   in Loop: Header=BB0_17 Depth=1
	movq	64(%rsp), %rax                  # 8-byte Reload
	movq	8(%rsp), %rcx                   # 8-byte Reload
	movq	%rbx, (%rax,%rcx,8)
	incq	%rcx
	movq	%rcx, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB0_16
	.p2align	4
.LBB0_24:                               #   in Loop: Header=BB0_17 Depth=1
	incl	%ebp
	cmpl	%r13d, %ebp
	jge	.LBB0_251
# %bb.25:                               #   in Loop: Header=BB0_17 Depth=1
	movslq	%ebp, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, (%rsp)                    # 8-byte Spill
	jmp	.LBB0_16
.LBB0_26:                               #   in Loop: Header=BB0_17 Depth=1
	incl	%ebp
	cmpl	%r13d, %ebp
	jge	.LBB0_264
# %bb.27:                               #   in Loop: Header=BB0_17 Depth=1
	movslq	%ebp, %rax
	movq	(%r12,%rax,8), %rax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	jmp	.LBB0_16
.LBB0_28:                               #   in Loop: Header=BB0_17 Depth=1
	incl	%ebp
	cmpl	%r13d, %ebp
	jge	.LBB0_269
# %bb.29:                               #   in Loop: Header=BB0_17 Depth=1
	leaq	8(,%r15,8), %rax
	leaq	(%rax,%rax,2), %rsi
	movq	48(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_268
# %bb.30:                               #   in Loop: Header=BB0_17 Depth=1
	movslq	%ebp, %rax
	movq	(%r12,%rax,8), %r13
	movq	%r13, %rdi
	movl	$61, %esi
	callq	strchr@PLT
	testq	%rax, %rax
	je	.LBB0_260
# %bb.31:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%rax, %rbx
	movq	%rax, %r12
	subq	%r13, %r12
	je	.LBB0_260
# %bb.32:                               #   in Loop: Header=BB0_17 Depth=1
	cmpb	$0, 1(%rbx)
	je	.LBB0_260
# %bb.33:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%r14, 56(%rsp)                  # 8-byte Spill
	cmpq	$64, %r12
	jae	.LBB0_267
# %bb.34:                               #   in Loop: Header=BB0_17 Depth=1
	leaq	192(%rsp), %r14
	movq	%r14, %rdi
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	memcpy@PLT
	movb	$0, 192(%rsp,%r12)
	movq	$0, 96(%rsp)
	movl	$4, %ecx
	movq	%r14, %rdi
	leaq	112(%rsp), %rsi
	leaq	96(%rsp), %rdx
	callq	parse_path83
	cmpq	$1, 96(%rsp)
	jne	.LBB0_270
# %bb.35:                               #   in Loop: Header=BB0_17 Depth=1
	movl	120(%rsp), %eax
	movl	$19525, %ecx                    # imm = 0x4C45
	xorl	%ecx, %eax
	movzbl	122(%rsp), %ecx
	xorl	$70, %ecx
	orw	%ax, %cx
	movq	32(%rsp), %r12                  # 8-byte Reload
	movl	40(%rsp), %r13d                 # 4-byte Reload
	movq	56(%rsp), %r14                  # 8-byte Reload
	jne	.LBB0_271
# %bb.36:                               #   in Loop: Header=BB0_17 Depth=1
	leaq	(%r15,%r15,2), %rax
	movq	48(%rsp), %rcx                  # 8-byte Reload
	leaq	(%rcx,%rax,8), %rax
	movl	119(%rsp), %ecx
	movl	%ecx, 7(%rax)
	movq	112(%rsp), %rcx
	movq	%rcx, (%rax)
	movq	(%rax), %rcx
	movabsq	$2314885604590964548, %rdx      # imm = 0x202020314D4F4F44
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$4918308063554842957, %rsi      # imm = 0x444157202020314D
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_255
# %bb.37:                               #   in Loop: Header=BB0_17 Depth=1
	movq	(%rax), %rcx
	movabsq	$2314934069018903883, %rdx      # imm = 0x20204C454E52454B
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499685168104782, %rsi      # imm = 0x464C4520204C454E
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_255
# %bb.38:                               #   in Loop: Header=BB0_17 Depth=1
	movq	(%rax), %rcx
	movabsq	$4778128234594521941, %rdx      # imm = 0x424F525052455355
	xorq	%rdx, %rcx
	movq	3(%rax), %rdx
	movabsq	$5065499831985918034, %rsi      # imm = 0x464C45424F525052
	xorq	%rsi, %rdx
	orq	%rcx, %rdx
	je	.LBB0_255
# %bb.39:                               #   in Loop: Header=BB0_17 Depth=1
	incq	%rbx
	movq	%rbx, 16(%rax)
	testq	%r15, %r15
	je	.LBB0_15
# %bb.40:                               #   in Loop: Header=BB0_17 Depth=1
	leaq	1(%r15), %rcx
	movq	48(%rsp), %rdx                  # 8-byte Reload
	.p2align	4
.LBB0_41:                               #   Parent Loop BB0_17 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	(%rdx), %rsi
	xorq	(%rax), %rsi
	movq	3(%rdx), %rdi
	xorq	3(%rax), %rdi
	orq	%rsi, %rdi
	je	.LBB0_249
# %bb.42:                               #   in Loop: Header=BB0_41 Depth=2
	addq	$24, %rdx
	decq	%r15
	jne	.LBB0_41
# %bb.43:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%rcx, %r15
	jmp	.LBB0_16
.LBB0_44:                               #   in Loop: Header=BB0_17 Depth=1
	incl	%ebp
	cmpl	%r13d, %ebp
	jge	.LBB0_273
# %bb.45:                               #   in Loop: Header=BB0_17 Depth=1
	leaq	1(%r14), %rax
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	imulq	$104, %rax, %rsi
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_275
# %bb.46:                               #   in Loop: Header=BB0_17 Depth=1
	movslq	%ebp, %rax
	movq	(%r12,%rax,8), %rbx
	movq	%rbx, %rdi
	movl	$61, %esi
	callq	strchr@PLT
	testq	%rax, %rax
	je	.LBB0_265
# %bb.47:                               #   in Loop: Header=BB0_17 Depth=1
	movq	%rax, %r12
	movq	%rax, %r13
	subq	%rbx, %r13
	je	.LBB0_265
# %bb.48:                               #   in Loop: Header=BB0_17 Depth=1
	cmpb	$0, 1(%r12)
	je	.LBB0_265
# %bb.49:                               #   in Loop: Header=BB0_17 Depth=1
	cmpq	$96, %r13
	jae	.LBB0_274
# %bb.50:                               #   in Loop: Header=BB0_17 Depth=1
	imulq	$104, %r14, %r14
	addq	16(%rsp), %r14                  # 8-byte Folded Reload
	incq	%r12
	movq	%r14, %rdi
	movq	%rbx, %rsi
	movq	%r13, %rdx
	callq	memcpy@PLT
	movb	$0, (%r14,%r13)
	movq	%r12, 96(%r14)
	movq	56(%rsp), %r14                  # 8-byte Reload
	movq	32(%rsp), %r12                  # 8-byte Reload
	movl	40(%rsp), %r13d                 # 4-byte Reload
	jmp	.LBB0_16
.LBB0_51:
	movq	24(%rsp), %r12                  # 8-byte Reload
	testq	%r12, %r12
	je	.LBB0_85
# %bb.52:
	cmpq	$0, 8(%rsp)                     # 8-byte Folded Reload
	movq	64(%rsp), %rbp                  # 8-byte Reload
	jne	.LBB0_276
# %bb.53:
	cmpq	$0, (%rsp)                      # 8-byte Folded Reload
	jne	.LBB0_276
# %bb.54:
	testq	%r15, %r15
	jne	.LBB0_276
# %bb.55:
	testq	%r14, %r14
	jne	.LBB0_276
# %bb.56:
	movq	%r12, %rdi
	callq	read_file
	cmpq	$67108864, %rdx                 # imm = 0x4000000
	jne	.LBB0_277
# %bb.57:
	movq	%rax, %rbx
	cmpw	$-21931, 510(%rax)              # imm = 0xAA55
	jne	.LBB0_278
# %bb.58:
	cmpl	$2048, 454(%rbx)                # imm = 0x800
	jne	.LBB0_279
# %bb.59:
	cmpl	$129024, 458(%rbx)              # imm = 0x1F800
	jne	.LBB0_279
# %bb.60:
	cmpw	$-21931, 1049086(%rbx)          # imm = 0xAA55
	jne	.LBB0_280
# %bb.61:
	cmpw	$512, 1048587(%rbx)             # imm = 0x200
	jne	.LBB0_281
# %bb.62:
	cmpb	$2, 1048589(%rbx)
	jne	.LBB0_282
# %bb.63:
	leaq	.Lstr.233(%rip), %rdi
	callq	puts@PLT
	leaq	.L.str.125(%rip), %rdi
	movl	$67108864, %esi                 # imm = 0x4000000
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.126(%rip), %rdi
	movl	$2048, %esi                     # imm = 0x800
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.127(%rip), %rdi
	movl	$129024, %esi                   # imm = 0x1F800
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.128(%rip), %rdi
	movl	$2561, %esi                     # imm = 0xA01
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.129(%rip), %rdi
	movl	$2593, %esi                     # imm = 0xA21
	xorl	%eax, %eax
	callq	printf@PLT
	leaq	.L.str.130(%rip), %rdi
	movl	$64239, %esi                    # imm = 0xFAEF
	xorl	%eax, %eax
	callq	printf@PLT
	movq	%rbx, %r12
	addq	$1311232, %r12                  # imm = 0x140200
	leaq	.L.str.131(%rip), %r14
	leaq	192(%rsp), %r15
	xorl	%r13d, %r13d
	jmp	.LBB0_67
.LBB0_64:                               #   in Loop: Header=BB0_67 Depth=1
	addq	$2, %rax
.LBB0_65:                               #   in Loop: Header=BB0_67 Depth=1
	movb	$0, 192(%rsp,%rax)
	movzbl	11(%r12), %ecx
	movzwl	26(%r12), %r8d
	movl	28(%r12), %r9d
	movq	%r14, %rdi
	movl	%r13d, %esi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	printf@PLT
.LBB0_66:                               #   in Loop: Header=BB0_67 Depth=1
	incq	%r13
	addq	$32, %r12
	cmpq	$512, %r13                      # imm = 0x200
	je	.LBB0_84
.LBB0_67:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%r12), %eax
	cmpl	$229, %eax
	je	.LBB0_66
# %bb.68:                               #   in Loop: Header=BB0_67 Depth=1
	testl	%eax, %eax
	je	.LBB0_84
# %bb.69:                               #   in Loop: Header=BB0_67 Depth=1
	cmpb	$32, %al
	jne	.LBB0_71
# %bb.70:                               #   in Loop: Header=BB0_67 Depth=1
	xorl	%eax, %eax
	jmp	.LBB0_79
	.p2align	4
.LBB0_71:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%al, 192(%rsp)
	movzbl	1(%r12), %ecx
	movl	$1, %eax
	cmpb	$32, %cl
	je	.LBB0_79
# %bb.72:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 193(%rsp)
	movzbl	2(%r12), %ecx
	movl	$2, %eax
	cmpb	$32, %cl
	je	.LBB0_79
# %bb.73:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 194(%rsp)
	movzbl	3(%r12), %ecx
	movl	$3, %eax
	cmpb	$32, %cl
	je	.LBB0_79
# %bb.74:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 195(%rsp)
	movzbl	4(%r12), %ecx
	movl	$4, %eax
	cmpb	$32, %cl
	je	.LBB0_79
# %bb.75:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 196(%rsp)
	movzbl	5(%r12), %ecx
	movl	$5, %eax
	cmpb	$32, %cl
	je	.LBB0_79
# %bb.76:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 197(%rsp)
	movzbl	6(%r12), %ecx
	movl	$6, %eax
	cmpb	$32, %cl
	je	.LBB0_79
# %bb.77:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 198(%rsp)
	movzbl	7(%r12), %ecx
	movl	$7, %eax
	cmpb	$32, %cl
	je	.LBB0_79
# %bb.78:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 199(%rsp)
	movl	$8, %eax
	.p2align	4
.LBB0_79:                               #   in Loop: Header=BB0_67 Depth=1
	movzbl	8(%r12), %ecx
	cmpb	$32, %cl
	je	.LBB0_65
# %bb.80:                               #   in Loop: Header=BB0_67 Depth=1
	movb	$46, 192(%rsp,%rax)
	movb	%cl, 193(%rsp,%rax)
	movzbl	9(%r12), %ecx
	cmpb	$32, %cl
	je	.LBB0_64
# %bb.81:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 194(%rsp,%rax)
	movzbl	10(%r12), %ecx
	cmpb	$32, %cl
	jne	.LBB0_83
# %bb.82:                               #   in Loop: Header=BB0_67 Depth=1
	addq	$3, %rax
	jmp	.LBB0_65
.LBB0_83:                               #   in Loop: Header=BB0_67 Depth=1
	movb	%cl, 195(%rsp,%rax)
	addq	$4, %rax
	jmp	.LBB0_65
.LBB0_84:
	movq	%rbx, %rdi
	callq	free@PLT
	movq	48(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	%rbp, %rdi
	jmp	.LBB0_236
.LBB0_85:
	movq	8(%rsp), %r12                   # 8-byte Reload
	leaq	-4(%r12), %rax
	cmpq	$3, %rax
	movq	64(%rsp), %r13                  # 8-byte Reload
	jb	.LBB0_87
# %bb.86:
	cmpq	$1, %r12
	jne	.LBB0_284
.LBB0_87:
	testq	%r15, %r15
	je	.LBB0_94
# %bb.88:
	xorl	%eax, %eax
	jmp	.LBB0_90
	.p2align	4
.LBB0_89:                               #   in Loop: Header=BB0_90 Depth=1
	incq	%rax
	cmpq	%r15, %rax
	je	.LBB0_94
.LBB0_90:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_92 Depth 2
	testq	%rax, %rax
	je	.LBB0_89
# %bb.91:                               #   in Loop: Header=BB0_90 Depth=1
	leaq	(%rax,%rax,2), %rcx
	movq	48(%rsp), %rdx                  # 8-byte Reload
	leaq	(%rdx,%rcx,8), %rcx
	movq	%rax, %rsi
	.p2align	4
.LBB0_92:                               #   Parent Loop BB0_90 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	(%rcx), %rdi
	xorq	(%rdx), %rdi
	movq	3(%rcx), %r8
	xorq	3(%rdx), %r8
	orq	%rdi, %r8
	je	.LBB0_248
# %bb.93:                               #   in Loop: Header=BB0_92 Depth=2
	addq	$24, %rdx
	decq	%rsi
	jne	.LBB0_92
	jmp	.LBB0_89
.LBB0_94:
	movq	$67108864, 200(%rsp)            # imm = 0x4000000
	movl	$67108864, %edi                 # imm = 0x4000000
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_285
# %bb.95:
	movq	%rax, 192(%rsp)
	leaq	208(%rsp), %rdi
	xorl	%ebx, %ebx
	movl	$131072, %edx                   # imm = 0x20000
	xorl	%esi, %esi
	callq	memset@PLT
	cmpq	$3, %r12
	jbe	.LBB0_99
# %bb.96:
	movq	8(%r13), %rdx
	movq	16(%r13), %rcx
	movq	24(%r13), %r8
	cmpq	$4, %r12
	jne	.LBB0_206
# %bb.97:
	xorl	%ebx, %ebx
	jmp	.LBB0_100
.LBB0_98:
	xorl	%ebp, %ebp
	jmp	.LBB0_143
.LBB0_99:
	xorl	%r8d, %r8d
	xorl	%edx, %edx
	xorl	%ecx, %ecx
.LBB0_100:
	xorl	%r9d, %r9d
.LBB0_101:
	subq	$8, %rsp
	.cfi_adjust_cfa_offset 8
	leaq	200(%rsp), %rdi
	movq	8(%rsp), %rsi                   # 8-byte Reload
	pushq	%r14
	.cfi_adjust_cfa_offset 8
	movq	32(%rsp), %r14                  # 8-byte Reload
	pushq	%r14
	.cfi_adjust_cfa_offset 8
	pushq	%r15
	.cfi_adjust_cfa_offset 8
	movq	80(%rsp), %r15                  # 8-byte Reload
	pushq	%r15
	.cfi_adjust_cfa_offset 8
	pushq	%rbx
	.cfi_adjust_cfa_offset 8
	callq	install_bootable_layout
	addq	$48, %rsp
	.cfi_adjust_cfa_offset -48
	movq	(%r13), %rdi
	movq	192(%rsp), %rbx
	movq	200(%rsp), %rdx
	movq	%rbx, %rsi
	callq	write_file
	movq	%rbx, %rdi
	callq	free@PLT
	movq	%r15, %rdi
	callq	free@PLT
	movq	%r14, %rdi
	callq	free@PLT
	movq	%r13, %rdi
	jmp	.LBB0_236
.LBB0_102:                              #   in Loop: Header=BB0_104 Depth=1
	movl	$1, %eax
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	.p2align	4
.LBB0_103:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_142
.LBB0_104:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_138 Depth 2
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %r14
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_119
# %bb.105:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	movq	%r12, %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_121
# %bb.106:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.6(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_123
# %bb.107:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.7(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_125
# %bb.108:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.8(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_127
# %bb.109:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.9(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_129
# %bb.110:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.10(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_102
# %bb.111:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.11(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_131
# %bb.112:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.12(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_132
# %bb.113:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r14, %rdi
	leaq	.L.str.13(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_259
# %bb.114:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.115:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %r14
	movq	$0, 112(%rsp)
	movq	%r14, %rdi
	leaq	112(%rsp), %rsi
	movl	$10, %edx
	callq	strtol@PLT
	movq	112(%rsp), %rcx
	cmpq	%r14, %rcx
	je	.LBB0_291
# %bb.116:                              #   in Loop: Header=BB0_104 Depth=1
	cmpb	$61, (%rcx)
	jne	.LBB0_291
# %bb.117:                              #   in Loop: Header=BB0_104 Depth=1
	cmpq	$6, %rax
	jae	.LBB0_291
# %bb.118:                              #   in Loop: Header=BB0_104 Depth=1
	incq	%rcx
	movq	%rcx, 280(%rsp,%rax,8)
	jmp	.LBB0_103
	.p2align	4
.LBB0_119:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.120:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %rbp
	jmp	.LBB0_103
	.p2align	4
.LBB0_121:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.122:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, 200(%rsp)
	jmp	.LBB0_103
.LBB0_123:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.124:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, (%rsp)                    # 8-byte Spill
	jmp	.LBB0_103
.LBB0_125:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.126:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB0_103
.LBB0_127:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.128:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	jmp	.LBB0_103
.LBB0_129:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.130:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %rax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	jmp	.LBB0_103
.LBB0_131:                              #   in Loop: Header=BB0_104 Depth=1
	movl	$1, 76(%rsp)                    # 4-byte Folded Spill
	jmp	.LBB0_103
.LBB0_132:                              #   in Loop: Header=BB0_104 Depth=1
	incl	%r15d
	cmpl	40(%rsp), %r15d                 # 4-byte Folded Reload
	jge	.LBB0_259
# %bb.133:                              #   in Loop: Header=BB0_104 Depth=1
	movslq	%r15d, %rax
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	(%rcx,%rax,8), %r14
	movq	$0, 112(%rsp)
	movq	%r14, %rdi
	leaq	112(%rsp), %rsi
	movl	$10, %edx
	callq	strtol@PLT
	movq	112(%rsp), %rcx
	cmpq	%r14, %rcx
	je	.LBB0_293
# %bb.134:                              #   in Loop: Header=BB0_104 Depth=1
	cmpb	$0, (%rcx)
	jne	.LBB0_293
# %bb.135:                              #   in Loop: Header=BB0_104 Depth=1
	cmpq	$5, %rax
	ja	.LBB0_293
# %bb.136:                              #   in Loop: Header=BB0_104 Depth=1
	testq	%r13, %r13
	je	.LBB0_141
# %bb.137:                              #   in Loop: Header=BB0_104 Depth=1
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_138:                              #   Parent Loop BB0_104 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	%eax, 248(%rsp,%rcx,4)
	je	.LBB0_103
# %bb.139:                              #   in Loop: Header=BB0_138 Depth=2
	incq	%rcx
	cmpq	%rcx, %r13
	jne	.LBB0_138
# %bb.140:                              #   in Loop: Header=BB0_104 Depth=1
	cmpq	$6, %r13
	jae	.LBB0_294
.LBB0_141:                              #   in Loop: Header=BB0_104 Depth=1
	movl	%eax, 248(%rsp,%r13,4)
	incq	%r13
	jmp	.LBB0_103
.LBB0_142:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 232(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 224(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 216(%rsp)
	movq	(%rsp), %rax                    # 8-byte Reload
	movq	%rax, 208(%rsp)
	movq	%r13, 272(%rsp)
	movl	76(%rsp), %eax                  # 4-byte Reload
	movl	%eax, 244(%rsp)
	movq	56(%rsp), %rax                  # 8-byte Reload
	movl	%eax, 240(%rsp)
	movq	48(%rsp), %rbx                  # 8-byte Reload
.LBB0_143:
	movq	%rbp, 192(%rsp)
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, %r15
	movq	%rax, 96(%rsp)
	movq	%rdx, 104(%rsp)
	leaq	96(%rsp), %rdi
	movq	%rbx, %rsi
	callq	validate_image_layout
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 160(%rsp)
	movaps	%xmm0, 176(%rsp)
	movq	192(%rsp), %rbx
	testq	%rbx, %rbx
	je	.LBB0_145
# %bb.144:
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, (%rsp)                    # 8-byte Spill
	movq	%rax, 160(%rsp)
	movq	%rdx, 168(%rsp)
	leaq	160(%rsp), %rdi
	movq	%rbx, %rsi
	callq	validate_image_layout
	jmp	.LBB0_146
.LBB0_145:
	movq	$0, (%rsp)                      # 8-byte Folded Spill
.LBB0_146:
	movq	200(%rsp), %rbx
	testq	%rbx, %rbx
	je	.LBB0_148
# %bb.147:
	movq	%rbx, %rdi
	callq	read_file
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	movq	%rax, 176(%rsp)
	movq	%rdx, 184(%rsp)
	leaq	176(%rsp), %rdi
	movq	%rbx, %rsi
	callq	validate_image_layout
	jmp	.LBB0_149
.LBB0_148:
	movq	$0, 32(%rsp)                    # 8-byte Folded Spill
.LBB0_149:
	movl	240(%rsp), %ebx
	testl	%ebx, %ebx
	je	.LBB0_159
# %bb.150:
	xorl	%eax, %eax
	movabsq	$2329570836308444484, %rcx      # imm = 0x20544C5541464544
	movabsq	$5135866231194932545, %rdx      # imm = 0x47464320544C5541
	jmp	.LBB0_152
	.p2align	4
.LBB0_151:                              #   in Loop: Header=BB0_152 Depth=1
	addq	$32, %rax
	cmpq	$16384, %rax                    # imm = 0x4000
	je	.LBB0_250
.LBB0_152:                              # =>This Inner Loop Header: Depth=1
	movzbl	1311232(%r15,%rax), %esi
	cmpl	$229, %esi
	je	.LBB0_151
# %bb.153:                              #   in Loop: Header=BB0_152 Depth=1
	testl	%esi, %esi
	je	.LBB0_250
# %bb.154:                              #   in Loop: Header=BB0_152 Depth=1
	movq	1311232(%r15,%rax), %rsi
	xorq	%rcx, %rsi
	movq	1311235(%r15,%rax), %rdi
	xorq	%rdx, %rdi
	orq	%rsi, %rdi
	jne	.LBB0_151
# %bb.155:
	testb	$16, 1311243(%r15,%rax)
	jne	.LBB0_287
# %bb.156:
	cmpl	$0, 1311260(%r15,%rax)
	je	.LBB0_288
# %bb.157:
	cmpq	$0, (%rsp)                      # 8-byte Folded Reload
	je	.LBB0_159
# %bb.158:
	leaq	DEFAULT_CFG_NAME(%rip), %rdx
	leaq	96(%rsp), %rdi
	leaq	160(%rsp), %rsi
	callq	root_file_equal
	testl	%eax, %eax
	jne	.LBB0_292
.LBB0_159:
	movl	%ebx, 8(%rsp)                   # 4-byte Spill
	movq	272(%rsp), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_180
# %bb.160:
	xorl	%r13d, %r13d
	leaq	96(%rsp), %r14
	.p2align	4
.LBB0_161:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_164 Depth 2
	movslq	248(%rsp,%r13,4), %rax
	cmpq	$6, %rax
	jae	.LBB0_256
# %bb.162:                              #   in Loop: Header=BB0_161 Depth=1
	movq	280(%rsp,%rax,8), %r12
	movabsq	$2330121683245944644, %rcx      # imm = 0x205641534D4F4F44
	movq	%rcx, 80(%rsp)
	movl	$1196639264, 87(%rsp)           # imm = 0x47534420
	orb	$48, %al
	movb	%al, 87(%rsp)
	xorl	%eax, %eax
	jmp	.LBB0_164
	.p2align	4
.LBB0_163:                              #   in Loop: Header=BB0_164 Depth=2
	addq	$32, %rax
	cmpq	$16384, %rax                    # imm = 0x4000
	je	.LBB0_247
.LBB0_164:                              #   Parent Loop BB0_161 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	1311232(%r15,%rax), %ecx
	cmpl	$229, %ecx
	je	.LBB0_163
# %bb.165:                              #   in Loop: Header=BB0_164 Depth=2
	testl	%ecx, %ecx
	je	.LBB0_247
# %bb.166:                              #   in Loop: Header=BB0_164 Depth=2
	movq	1311232(%r15,%rax), %rcx
	xorq	80(%rsp), %rcx
	movq	1311235(%r15,%rax), %rdx
	xorq	83(%rsp), %rdx
	orq	%rcx, %rdx
	jne	.LBB0_163
# %bb.167:                              #   in Loop: Header=BB0_161 Depth=1
	movzbl	1311243(%r15,%rax), %ecx
	movzwl	1311258(%r15,%rax), %edx
	movl	1311260(%r15,%rax), %eax
	movq	%rax, %rsi
	shlq	$32, %rsi
	orq	%rdx, %rsi
	movq	%rcx, %rdx
	shlq	$32, %rdx
	incq	%rdx
	movq	%rdx, 112(%rsp)
	movq	%rsi, 120(%rsp)
	testb	$16, %cl
	jne	.LBB0_257
# %bb.168:                              #   in Loop: Header=BB0_161 Depth=1
	cmpl	$63, %eax
	jbe	.LBB0_258
# %bb.169:                              #   in Loop: Header=BB0_161 Depth=1
	cmpq	$0, (%rsp)                      # 8-byte Folded Reload
	je	.LBB0_171
# %bb.170:                              #   in Loop: Header=BB0_161 Depth=1
	movq	%r14, %rdi
	leaq	160(%rsp), %rsi
	leaq	80(%rsp), %rdx
	callq	root_file_equal
	testl	%eax, %eax
	jne	.LBB0_262
.LBB0_171:                              #   in Loop: Header=BB0_161 Depth=1
	cmpq	$0, 32(%rsp)                    # 8-byte Folded Reload
	je	.LBB0_173
# %bb.172:                              #   in Loop: Header=BB0_161 Depth=1
	movq	%r14, %rdi
	leaq	176(%rsp), %rsi
	leaq	80(%rsp), %rdx
	callq	root_file_equal
	testl	%eax, %eax
	je	.LBB0_261
.LBB0_173:                              #   in Loop: Header=BB0_161 Depth=1
	movq	%r14, %rdi
	leaq	112(%rsp), %rsi
	leaq	.L.str.75(%rip), %rdx
	callq	read_root_file_blob
	movq	%rax, %rbx
	movq	%rdx, %rbp
	testq	%r12, %r12
	je	.LBB0_177
# %bb.174:                              #   in Loop: Header=BB0_161 Depth=1
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$25, %rax
	jae	.LBB0_263
# %bb.175:                              #   in Loop: Header=BB0_161 Depth=1
	cmpq	$24, %rbp
	jb	.LBB0_254
# %bb.176:                              #   in Loop: Header=BB0_161 Depth=1
	movq	%rbx, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	bcmp@PLT
	testl	%eax, %eax
	jne	.LBB0_254
.LBB0_177:                              #   in Loop: Header=BB0_161 Depth=1
	cmpq	$40, %rbp
	jb	.LBB0_252
# %bb.178:                              #   in Loop: Header=BB0_161 Depth=1
	movabsq	$2336927755350992246, %rax      # imm = 0x206E6F6973726576
	cmpq	%rax, 24(%rbx)
	jne	.LBB0_252
# %bb.179:                              #   in Loop: Header=BB0_161 Depth=1
	movq	%rbx, %rdi
	callq	free@PLT
	incq	%r13
	cmpq	40(%rsp), %r13                  # 8-byte Folded Reload
	jne	.LBB0_161
.LBB0_180:
	movq	208(%rsp), %r13
	movq	%r13, %rdi
	xorl	%esi, %esi
	callq	check_write_status
	movq	216(%rsp), %r12
	movq	%r12, %rdi
	movl	$1, %esi
	callq	check_write_status
	movq	224(%rsp), %rbp
	testq	%rbp, %rbp
	je	.LBB0_219
# %bb.181:
	movq	%rbp, %rdi
	callq	read_file
	movq	%rax, 112(%rsp)
	movq	%rdx, 120(%rsp)
	testq	%rax, %rax
	je	.LBB0_219
# %bb.182:
	movq	%rdx, %r14
	cmpq	$11, %rdx
	jb	.LBB0_186
# %bb.183:
	movq	%rax, %rbx
	movabsq	$8746391181324018023, %rax      # imm = 0x79616C70656D6167
	movl	$11, %ecx
	movabsq	$5426623667539570789, %rdx      # imm = 0x4B4F3D79616C7065
	.p2align	4
.LBB0_184:                              # =>This Inner Loop Header: Depth=1
	movq	-11(%rbx,%rcx), %rsi
	xorq	%rax, %rsi
	movq	-8(%rbx,%rcx), %rdi
	xorq	%rdx, %rdi
	orq	%rsi, %rdi
	je	.LBB0_187
# %bb.185:                              #   in Loop: Header=BB0_184 Depth=1
	incq	%rcx
	cmpq	%r14, %rcx
	jbe	.LBB0_184
.LBB0_186:
	leaq	.L.str.94(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_187:
	movl	$1702257011, %ecx               # imm = 0x65766173
	movl	(%rbx), %eax
	xorl	%ecx, %eax
	movzwl	4(%rbx), %edx
	xorl	$25714, %edx                    # imm = 0x6472
	orl	%eax, %edx
	jne	.LBB0_189
# %bb.188:
	cmpb	$61, 6(%rbx)
	movq	%rbx, %rax
	je	.LBB0_196
.LBB0_189:
	leaq	-7(%r14), %rdx
	xorl	%eax, %eax
	movabsq	$4294976512, %rsi               # imm = 0x100002400
	jmp	.LBB0_191
	.p2align	4
.LBB0_190:                              #   in Loop: Header=BB0_191 Depth=1
	incq	%rax
	cmpq	%rax, %rdx
	je	.LBB0_253
.LBB0_191:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%rbx,%rax), %edi
	cmpq	$32, %rdi
	ja	.LBB0_190
# %bb.192:                              #   in Loop: Header=BB0_191 Depth=1
	btq	%rdi, %rsi
	jae	.LBB0_190
# %bb.193:                              #   in Loop: Header=BB0_191 Depth=1
	movl	1(%rbx,%rax), %edi
	xorl	%ecx, %edi
	movzwl	5(%rbx,%rax), %r8d
	xorl	$25714, %r8d                    # imm = 0x6472
	orl	%edi, %r8d
	jne	.LBB0_190
# %bb.194:                              #   in Loop: Header=BB0_191 Depth=1
	cmpb	$61, 7(%rbx,%rax)
	jne	.LBB0_190
# %bb.195:
	addq	%rbx, %rax
	incq	%rax
.LBB0_196:
	movzbl	7(%rax), %edi
	testb	%dil, %dil
	je	.LBB0_290
# %bb.197:
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_198:                              # =>This Inner Loop Header: Depth=1
	movsbl	%dil, %esi
	leal	-48(%rsi), %r8d
	cmpb	$9, %r8b
	ja	.LBB0_200
# %bb.199:                              #   in Loop: Header=BB0_198 Depth=1
	addl	$-48, %esi
	jmp	.LBB0_204
	.p2align	4
.LBB0_200:                              #   in Loop: Header=BB0_198 Depth=1
	leal	-97(%rdi), %r8d
	cmpb	$5, %r8b
	ja	.LBB0_202
# %bb.201:                              #   in Loop: Header=BB0_198 Depth=1
	addl	$-87, %esi
	jmp	.LBB0_204
	.p2align	4
.LBB0_202:                              #   in Loop: Header=BB0_198 Depth=1
	addb	$-65, %dil
	cmpb	$5, %dil
	ja	.LBB0_212
# %bb.203:                              #   in Loop: Header=BB0_198 Depth=1
	addl	$-55, %esi
.LBB0_204:                              #   in Loop: Header=BB0_198 Depth=1
	testl	%esi, %esi
	js	.LBB0_212
# %bb.205:                              #   in Loop: Header=BB0_198 Depth=1
	shll	$4, %ecx
	orl	%esi, %ecx
	movzbl	8(%rax,%rdx), %edi
	incq	%rdx
	testb	%dil, %dil
	jne	.LBB0_198
	jmp	.LBB0_213
.LBB0_206:
	movq	32(%r13), %r9
	cmpq	$6, %r12
	jne	.LBB0_246
# %bb.207:
	movq	40(%r13), %rbx
	testq	%rbx, %rbx
	je	.LBB0_246
# %bb.208:
	testq	%r15, %r15
	je	.LBB0_101
# %bb.209:
	movabsq	$3477976621076005200, %rax      # imm = 0x3044414F4C594150
	movabsq	$5065499754490842956, %rsi      # imm = 0x464C453044414F4C
	movq	48(%rsp), %rdi                  # 8-byte Reload
	movq	%r15, %r10
	.p2align	4
.LBB0_210:                              # =>This Inner Loop Header: Depth=1
	movq	(%rdi), %r11
	xorq	%rax, %r11
	movq	3(%rdi), %r12
	xorq	%rsi, %r12
	orq	%r11, %r12
	je	.LBB0_283
# %bb.211:                              #   in Loop: Header=BB0_210 Depth=1
	addq	$24, %rdi
	decq	%r10
	jne	.LBB0_210
	jmp	.LBB0_101
.LBB0_212:
	testl	%edx, %edx
	je	.LBB0_290
.LBB0_213:
	testl	%ecx, %ecx
	je	.LBB0_286
# %bb.214:
	leaq	.L.str.95(%rip), %rsi
	leaq	112(%rsp), %rdi
	movl	$1, %edx
	callq	status_hex_tuple_part
	testl	%eax, %eax
	je	.LBB0_286
# %bb.215:
	movl	$6, %eax
	movl	$1768841584, %ecx               # imm = 0x696E6170
	.p2align	4
.LBB0_216:                              # =>This Inner Loop Header: Depth=1
	movl	-6(%rbx,%rax), %edx
	xorl	%ecx, %edx
	movzwl	-2(%rbx,%rax), %esi
	xorl	$15715, %esi                    # imm = 0x3D63
	orl	%edx, %esi
	je	.LBB0_241
# %bb.217:                              #   in Loop: Header=BB0_216 Depth=1
	incq	%rax
	cmpq	%r14, %rax
	jbe	.LBB0_216
.LBB0_218:
	movq	%rbx, %rdi
	callq	free@PLT
.LBB0_219:
	movq	%r12, %r14
	movq	232(%rsp), %rbx
	testq	%rbx, %rbx
	movq	64(%rsp), %r12                  # 8-byte Reload
	movl	8(%rsp), %ebp                   # 4-byte Reload
	je	.LBB0_230
# %bb.220:
	movq	%rbx, %rdi
	callq	read_file
	testq	%rax, %rax
	je	.LBB0_230
# %bb.221:
	cmpq	$11, %rdx
	jb	.LBB0_225
# %bb.222:
	movabsq	$8746391181324018023, %rcx      # imm = 0x79616C70656D6167
	movl	$11, %esi
	movabsq	$5426623667539570789, %rdi      # imm = 0x4B4F3D79616C7065
	.p2align	4
.LBB0_223:                              # =>This Inner Loop Header: Depth=1
	movq	-11(%rax,%rsi), %r8
	xorq	%rcx, %r8
	movq	-8(%rax,%rsi), %r9
	xorq	%rdi, %r9
	orq	%r8, %r9
	je	.LBB0_226
# %bb.224:                              #   in Loop: Header=BB0_223 Depth=1
	incq	%rsi
	cmpq	%rdx, %rsi
	jbe	.LBB0_223
.LBB0_225:
	leaq	.L.str.100(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_226:
	movl	$6, %ecx
	movl	$1768841584, %esi               # imm = 0x696E6170
	.p2align	4
.LBB0_227:                              # =>This Inner Loop Header: Depth=1
	movl	-6(%rax,%rcx), %edi
	xorl	%esi, %edi
	movzwl	-2(%rax,%rcx), %r8d
	xorl	$15715, %r8d                    # imm = 0x3D63
	orl	%edi, %r8d
	je	.LBB0_237
# %bb.228:                              #   in Loop: Header=BB0_227 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	.LBB0_227
.LBB0_229:
	movq	%rax, %rdi
	callq	free@PLT
.LBB0_230:
	cmpl	$0, 244(%rsp)
	je	.LBB0_232
# %bb.231:
	movq	%r13, %rdi
	callq	check_dynamic_fat_status
	movl	%eax, %ebx
	movq	%r14, %rdi
	callq	check_dynamic_fat_status
	orl	%ebx, %eax
	je	.LBB0_289
.LBB0_232:
	leaq	.Lstr(%rip), %rdi
	callq	puts@PLT
	leaq	.L.str.48(%rip), %rdi
	movq	48(%rsp), %rsi                  # 8-byte Reload
	xorl	%eax, %eax
	callq	printf@PLT
	testl	%ebp, %ebp
	leaq	.L.str.51(%rip), %rax
	leaq	.L.str.50(%rip), %rsi
	cmoveq	%rax, %rsi
	leaq	.L.str.49(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	40(%rsp), %r13                  # 8-byte Reload
	testq	%r13, %r13
	je	.LBB0_235
# %bb.233:
	leaq	.L.str.52(%rip), %rbx
	xorl	%r14d, %r14d
	.p2align	4
.LBB0_234:                              # =>This Inner Loop Header: Depth=1
	movl	248(%rsp,%r14,4), %esi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	incq	%r14
	cmpq	%r14, %r13
	jne	.LBB0_234
.LBB0_235:
	leaq	.Lstr.232(%rip), %rdi
	callq	puts@PLT
	movq	%r15, %rdi
	callq	free@PLT
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	free@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	%r12, %rdi
.LBB0_236:
	callq	free@PLT
	xorl	%eax, %eax
	addq	$131288, %rsp                   # imm = 0x200D8
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB0_237:
	.cfi_def_cfa_offset 131344
	movl	$10, %ecx
	movabsq	$5714572474359636336, %rsi      # imm = 0x4F4E3D63696E6170
	.p2align	4
.LBB0_238:                              # =>This Inner Loop Header: Depth=1
	movq	-10(%rax,%rcx), %rdi
	xorq	%rsi, %rdi
	movzwl	-2(%rax,%rcx), %r8d
	xorq	$17742, %r8                     # imm = 0x454E
	orq	%rdi, %r8
	je	.LBB0_229
# %bb.239:                              #   in Loop: Header=BB0_238 Depth=1
	incq	%rcx
	cmpq	%rdx, %rcx
	jbe	.LBB0_238
# %bb.240:
	leaq	.L.str.101(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB0_241:
	movl	$10, %eax
	movabsq	$5714572474359636336, %rcx      # imm = 0x4F4E3D63696E6170
	.p2align	4
.LBB0_242:                              # =>This Inner Loop Header: Depth=1
	movq	-10(%rbx,%rax), %rdx
	xorq	%rcx, %rdx
	movzwl	-2(%rbx,%rax), %esi
	xorq	$17742, %rsi                    # imm = 0x454E
	orq	%rdx, %rsi
	je	.LBB0_218
# %bb.243:                              #   in Loop: Header=BB0_242 Depth=1
	incq	%rax
	cmpq	%r14, %rax
	jbe	.LBB0_242
# %bb.244:
	leaq	.L.str.99(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_246:
	xorl	%ebx, %ebx
	jmp	.LBB0_101
.LBB0_247:
	callq	main.cold.25
.LBB0_248:
	callq	main.cold.17
.LBB0_249:
	callq	main.cold.9
.LBB0_250:
	callq	main.cold.21
.LBB0_251:
	callq	main.cold.15
.LBB0_252:
	callq	main.cold.31
.LBB0_253:
	callq	main.cold.34
.LBB0_254:
	callq	main.cold.29
.LBB0_255:
	callq	main.cold.10
.LBB0_256:
	callq	main.cold.33
.LBB0_257:
	callq	main.cold.26
.LBB0_258:
	callq	main.cold.32
.LBB0_259:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 232(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 224(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 216(%rsp)
	movq	(%rsp), %rax                    # 8-byte Reload
	movq	%rax, 208(%rsp)
	leaq	.L.str.42(%rip), %rdi
	callq	die
.LBB0_260:
	callq	main.cold.12
.LBB0_261:
	callq	main.cold.28
.LBB0_262:
	callq	main.cold.27
.LBB0_263:
	callq	main.cold.30
.LBB0_264:
	callq	main.cold.14
.LBB0_265:
	callq	main.cold.4
.LBB0_266:
	callq	main.cold.1
.LBB0_267:
	callq	main.cold.11
.LBB0_268:
	callq	main.cold.13
.LBB0_269:
	callq	main.cold.6
.LBB0_270:
	callq	main.cold.7
.LBB0_271:
	callq	main.cold.8
.LBB0_272:
	callq	main.cold.37
.LBB0_273:
	callq	main.cold.2
.LBB0_274:
	callq	main.cold.3
.LBB0_275:
	callq	main.cold.5
.LBB0_276:
	callq	main.cold.16
.LBB0_277:
	leaq	.L.str.54(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB0_278:
	leaq	.L.str.55(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB0_279:
	leaq	.L.str.56(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB0_280:
	leaq	.L.str.57(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB0_281:
	leaq	.L.str.58(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB0_282:
	leaq	.L.str.59(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB0_283:
	callq	main.cold.18
.LBB0_284:
	callq	main.cold.20
.LBB0_285:
	callq	main.cold.19
.LBB0_286:
	leaq	.L.str.96(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_287:
	callq	main.cold.22
.LBB0_288:
	callq	main.cold.24
.LBB0_289:
	callq	main.cold.36
.LBB0_290:
	callq	main.cold.35
.LBB0_291:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 232(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 224(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 216(%rsp)
	movq	(%rsp), %rax                    # 8-byte Reload
	movq	%rax, 208(%rsp)
	leaq	.L.str.45(%rip), %rdi
	callq	die
.LBB0_292:
	callq	main.cold.23
.LBB0_293:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 232(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 224(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 216(%rsp)
	movq	(%rsp), %rax                    # 8-byte Reload
	movq	%rax, 208(%rsp)
	leaq	.L.str.43(%rip), %rdi
	callq	die
.LBB0_294:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 232(%rsp)
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 224(%rsp)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, 216(%rsp)
	movq	(%rsp), %rax                    # 8-byte Reload
	movq	%rax, 208(%rsp)
	leaq	.L.str.44(%rip), %rdi
	callq	die
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker
	.type	mutate_root_marker,@function
mutate_root_marker:                     # @mutate_root_marker
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$131112, %rsp                   # imm = 0x20028
	.cfi_def_cfa_offset 131168
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	leaq	.L.str.30(%rip), %rsi
	movq	%r12, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB1_2
# %bb.8:
	leaq	.L.str.31(%rip), %rsi
	movq	%r12, %rdi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB1_9
# %bb.10:
	leaq	.L.str.32(%rip), %rsi
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	free@PLT                        # TAILCALL
.LBB1_29:
	.cfi_def_cfa_offset 131168
	callq	mutate_root_marker.cold.2
.LBB1_27:
	leaq	.L.str.23(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB1_12:
	callq	mutate_root_marker.cold.1
.LBB1_28:
	callq	mutate_root_marker.cold.3
.Lfunc_end1:
	.size	mutate_root_marker, .Lfunc_end1-mutate_root_marker
	.cfi_endproc
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function die
	.type	die,@function
die:                                    # @die
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.121(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	.cfi_adjust_cfa_offset 8
	popq	%rdi
	.cfi_adjust_cfa_offset -8
	callq	exit@PLT
.Lfunc_end2:
	.size	die, .Lfunc_end2-die
	.cfi_endproc
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
.LCPI3_13:
	.long	1                               # 0x1
	.long	1                               # 0x1
	.long	1                               # 0x1
	.long	1                               # 0x1
	.text
	.p2align	4
	.type	install_bootable_layout,@function
install_bootable_layout:                # @install_bootable_layout
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$248, %rsp
	.cfi_def_cfa_offset 304
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rcx, %r15
	movq	%rsi, %rbx
	movq	%rdi, %rbp
	testq	%rdx, %rdx
	setne	%al
	testq	%rcx, %rcx
	setne	%cl
	xorl	%esi, %esi
	movq	%rdx, %rdi
	orq	%r15, %rdi
	sete	%sil
	andb	%al, %cl
	testq	%r8, %r8
	movzbl	%cl, %eax
	cmovel	%esi, %eax
	testb	%al, %al
	je	.LBB3_380
# %bb.1:
	cmpq	$0, 304(%rsp)
	sete	%al
	testq	%r9, %r9
	setne	%cl
	orb	%al, %cl
	je	.LBB3_381
# %bb.2:
	movq	%r8, 168(%rsp)                  # 8-byte Spill
	movq	%r9, 192(%rsp)                  # 8-byte Spill
	movq	(%rbp), %r14
	testq	%rdx, %rdx
	je	.LBB3_7
# %bb.3:
	movq	%rdx, %r12
	movq	%rdx, %rdi
	callq	read_file
	cmpq	$512, %rdx                      # imm = 0x200
	jne	.LBB3_382
# %bb.4:
	movq	%rax, %r13
	movl	$512, %r12d                     # imm = 0x200
	movl	$512, %edx                      # imm = 0x200
	movq	%r14, %rdi
	movq	%rax, %rsi
	callq	memcpy@PLT
	movq	%r13, %rdi
	callq	free@PLT
	movq	%r15, %rdi
	callq	read_file
	cmpq	$8193, %rdx                     # imm = 0x2001
	jae	.LBB3_383
# %bb.5:
	movq	%rax, %r15
	addq	(%rbp), %r12
	movq	%r12, %rdi
	movq	%rax, %rsi
	callq	memcpy@PLT
	movq	%r15, %rdi
	callq	free@PLT
	movq	168(%rsp), %rdi                 # 8-byte Reload
	callq	read_file
	cmpq	$163841, %rdx                   # imm = 0x28001
	jae	.LBB3_384
# %bb.6:
	movq	%rax, %r15
	movl	$8704, %edi                     # imm = 0x2200
	addq	(%rbp), %rdi
	movq	%rax, %rsi
	callq	memcpy@PLT
	movq	%r15, %rdi
	callq	free@PLT
	jmp	.LBB3_8
.LBB3_7:
	movw	$15595, (%r14)                  # imm = 0x3CEB
	movb	$-112, 2(%r14)
.LBB3_8:
	movl	$1146310486, 440(%r14)          # imm = 0x44534F56
	movaps	.LCPI3_0(%rip), %xmm0           # xmm0 = [128,1,1,0,6,254,255,255,0,8,0,0,0,248,1,0]
	movups	%xmm0, 446(%r14)
	movw	$-21931, 510(%r14)              # imm = 0xAA55
	movq	(%rbp), %rax
	movw	$15595, 1048576(%rax)           # imm = 0x3CEB
	movb	$-112, 1048578(%rax)
	movabsq	$2314941808397928790, %rcx      # imm = 0x2020534F45424956
	movq	%rcx, 1048579(%rax)
	movdqa	.LCPI3_1(%rip), %xmm0           # xmm0 = [0,2,2,1,0,2,0,2,0,0,248,0,1,63,0,16]
	movdqu	%xmm0, 1048587(%rax)
	movabsq	$141863388262694912, %rcx       # imm = 0x1F8000000080000
	movq	%rcx, 1048603(%rax)
	movw	$-32768, 1048611(%rax)          # imm = 0x8000
	movl	$218104105, 1048614(%rax)       # imm = 0xD000129
	movb	$-48, 1048618(%rax)
	movabsq	$6278109480483965270, %rcx      # imm = 0x5720534F45424956
	movq	%rcx, 1048619(%rax)
	movl	$541344087, 1048626(%rax)       # imm = 0x20444157
	movabsq	$2314885625596363078, %rcx      # imm = 0x2020203631544146
	movq	%rcx, 1048630(%rax)
	movw	$-21931, 1049086(%rax)          # imm = 0xAA55
	testq	%rbx, %rbx
	movq	%rbp, 40(%rsp)                  # 8-byte Spill
	je	.LBB3_15
# %bb.9:
	movq	%rbx, %rdi
	callq	read_file
	cmpq	$5242881, %rdx                  # imm = 0x500001
	jae	.LBB3_385
# %bb.10:
	cmpq	$11, %rdx
	jbe	.LBB3_386
# %bb.11:
	movq	%rax, %r14
	cmpl	$1145132873, (%rax)             # imm = 0x44415749
	je	.LBB3_13
# %bb.12:
	cmpl	$1145132880, (%r14)             # imm = 0x44415750
	jne	.LBB3_387
.LBB3_13:
	movl	4(%r14), %eax
	movl	8(%r14), %ecx
	shlq	$4, %rax
	addq	%rcx, %rax
	cmpq	%rdx, %rax
	jbe	.LBB3_230
# %bb.14:
	leaq	.L.str.146(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_15:
	movl	$1048576, %edi                  # imm = 0x100000
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_388
# %bb.16:
	movq	%rax, %rbx
	movl	$18, %edi
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_389
# %bb.17:
	movq	%rax, %r14
	movq	%rbx, 24(%rsp)                  # 8-byte Spill
	movb	$1, (%rax)
	movb	$1, 2(%rax)
	movb	$12, 8(%rax)
	movb	$1, 13(%rax)
	movb	$-1, 17(%rax)
	movl	$12, %edi
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_390
# %bb.18:
	movq	%r14, 8(%rsp)                   # 8-byte Spill
	movabsq	$5207093865752713555, %rcx      # imm = 0x48435048544E5953
	movb	$1, (%rax)
	movq	%rax, 160(%rsp)                 # 8-byte Spill
	movq	%rcx, 4(%rax)
	movl	$1516, %edi                     # imm = 0x5EC
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_391
# %bb.19:
	movb	$42, (%rax)
	movq	%rax, 144(%rsp)                 # 8-byte Spill
	movq	%rax, %r13
	addq	$172, %r13
	leaq	switch_textures(%rip), %r15
	movl	$7, %ebp
	xorl	%r12d, %r12d
	.p2align	4
.LBB3_20:                               # =>This Inner Loop Header: Depth=1
	leaq	172(%r12), %rax
	movq	144(%rsp), %rcx                 # 8-byte Reload
	movb	%al, -3(%rcx,%rbp)
	movb	%ah, -2(%rcx,%rbp)
	movw	$0, -1(%rcx,%rbp)
	movq	(%r15), %rbx
	movq	$0, 172(%rcx,%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_392
# %bb.21:                               #   in Loop: Header=BB3_20 Depth=1
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
	jne	.LBB3_20
# %bb.22:
	movl	$10752, %edi                    # imm = 0x2A00
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_393
# %bb.23:
	movq	%rax, %r15
	movl	$8704, %edi                     # imm = 0x2200
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB3_394
# %bb.24:
	movq	%rax, %rbp
	movdqa	.LCPI3_2(%rip), %xmm4           # xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$80, %eax
	movdqa	.LCPI3_3(%rip), %xmm0           # xmm0 = [16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16]
	movdqa	.LCPI3_4(%rip), %xmm5           # xmm5 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
	movdqa	.LCPI3_5(%rip), %xmm1           # xmm1 = [48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48]
	movdqa	.LCPI3_6(%rip), %xmm2           # xmm2 = [32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32]
	movdqa	.LCPI3_7(%rip), %xmm3           # xmm3 = [96,96,96,96,96,96,96,96,96,96,96,96,96,96,96,96]
	.p2align	4
.LBB3_25:                               # =>This Inner Loop Header: Depth=1
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
	jne	.LBB3_25
# %bb.26:
	movdqa	.LCPI3_2(%rip), %xmm4           # xmm4 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movl	$112, %eax
	movdqa	.LCPI3_8(%rip), %xmm5           # xmm5 = [64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64]
	movdqa	.LCPI3_9(%rip), %xmm6           # xmm6 = [80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80]
	movdqa	.LCPI3_10(%rip), %xmm7          # xmm7 = [112,112,112,112,112,112,112,112,112,112,112,112,112,112,112,112]
	movdqa	.LCPI3_11(%rip), %xmm8          # xmm8 = [128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128]
	.p2align	4
.LBB3_27:                               # =>This Inner Loop Header: Depth=1
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
	jne	.LBB3_27
# %bb.28:
	movabsq	$5207093865752713555, %r12      # imm = 0x48435048544E5953
	movl	$2048, %edi                     # imm = 0x800
	callq	malloc@PLT
	testq	%rax, %rax
	je	.LBB3_395
# %bb.29:
	movabsq	$46179488366604, %rcx           # imm = 0x2A000000000C
	movq	%rcx, (%rax)
	movq	$0, 8(%rax)
	movl	$1497451600, 8(%rax)            # imm = 0x59414C50
	movl	$1279348825, 11(%rax)           # imm = 0x4C415059
	movq	24(%rsp), %rbx                  # 8-byte Reload
	movq	%rax, %r14
	leaq	12(%rbx), %rdi
	movl	$10752, %edx                    # imm = 0x2A00
	movq	%r15, 184(%rsp)                 # 8-byte Spill
	movq	%r15, %rsi
	callq	memcpy@PLT
	movabsq	$37383395355148, %rax           # imm = 0x220000002A0C
	movq	%rax, 16(%r14)
	movabsq	$5782988412433485635, %rax      # imm = 0x50414D524F4C4F43
	movq	%rax, 24(%r14)
	leaq	10764(%rbx), %rdi
	movl	$8704, %edx                     # imm = 0x2200
	movq	%rbp, 176(%rsp)                 # 8-byte Spill
	movq	%rbp, %rsi
	callq	memcpy@PLT
	movabsq	$51539627020, %rax              # imm = 0xC00004C0C
	movq	%rax, 32(%r14)
	movq	$0, 40(%r14)
	movl	$1296125520, 40(%r14)           # imm = 0x4D414E50
	movw	$21317, 44(%r14)                # imm = 0x5345
	movq	160(%rsp), %rcx                 # 8-byte Reload
	movl	8(%rcx), %eax
	movl	%eax, 19476(%rbx)
	movq	(%rcx), %rax
	movq	%rax, 19468(%rbx)
	movabsq	$6511170440216, %rax            # imm = 0x5EC00004C18
	movq	%rax, 48(%r14)
	movabsq	$3550334407692272980, %rax      # imm = 0x3145525554584554
	movq	%rax, 56(%r14)
	leaq	19480(%rbx), %rdi
	movl	$1516, %edx                     # imm = 0x5EC
	movq	144(%rsp), %rsi                 # 8-byte Reload
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
	leaq	20996(%rbx), %rdi
	movl	$4096, %edx                     # imm = 0x1000
	xorl	%esi, %esi
	callq	memset@PLT
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, 96(%r14)
	movl	$1313169222, 104(%r14)          # imm = 0x4E455F46
	movb	$68, 108(%r14)
	movdqu	%xmm0, 112(%r14)
	movl	$1414676820, 123(%r14)          # imm = 0x54524154
	movl	$1414750035, 120(%r14)          # imm = 0x54535F53
	movdqu	%xmm0, 128(%r14)
	pxor	%xmm1, %xmm1
	movb	$68, 140(%r14)
	movl	$1313169235, 136(%r14)          # imm = 0x4E455F53
	movabsq	$77309436420, %rax              # imm = 0x1200006204
	movq	%rax, 144(%r14)
	movq	%r12, 152(%r14)
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movups	%xmm0, 25092(%rbx)
	movzwl	16(%rax), %eax
	movw	%ax, 25108(%rbx)
	movdqu	%xmm1, 160(%r14)
	movl	$1330795598, 171(%r14)          # imm = 0x4F52544E
	movl	$1313431364, 168(%r14)          # imm = 0x4E495F44
	movdqu	%xmm1, 176(%r14)
	movl	$827142469, 184(%r14)           # imm = 0x314D3145
	movabsq	$42949698070, %rax              # imm = 0xA00006216
	movq	%rax, 192(%r14)
	movq	$0, 200(%r14)
	movl	$1313425492, 200(%r14)          # imm = 0x4E494854
	movq	%r14, 32(%rsp)                  # 8-byte Spill
	movw	$21319, 204(%r14)               # imm = 0x5347
	movw	$0, 25118(%rbx)
	movq	$0, 25110(%rbx)
	movl	$128, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
	movl	$13, %r13d
	movl	$25120, %ebp                    # imm = 0x6220
	movl	$416, %ebx                      # imm = 0x1A0
	movl	$26, %r14d
	leaq	48(%rsp), %rdi
	.p2align	4
.LBB3_30:                               # =>This Inner Loop Header: Depth=1
	leal	20(%r13), %ecx
	movl	$16, %esi
	leaq	.L.str.205(%rip), %rdx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	(%rsp), %r13                    # 8-byte Folded Reload
	jne	.LBB3_31
# %bb.32:                               #   in Loop: Header=BB3_30 Depth=1
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	realloc@PLT
	movq	%rax, %r12
	movq	%r14, (%rsp)                    # 8-byte Spill
	testq	%rax, %rax
	jne	.LBB3_33
	jmp	.LBB3_396
	.p2align	4
.LBB3_31:                               #   in Loop: Header=BB3_30 Depth=1
	movq	32(%rsp), %r12                  # 8-byte Reload
.LBB3_33:                               #   in Loop: Header=BB3_30 Depth=1
	movl	%ebp, (%r12,%r14,8)
	movl	$18, 4(%r12,%r14,8)
	movq	$0, 8(%r12,%r14,8)
	leaq	48(%rsp), %r15
	movq	%r15, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_397
# %bb.34:                               #   in Loop: Header=BB3_30 Depth=1
	movq	%r12, 32(%rsp)                  # 8-byte Spill
	leaq	(%r12,%r14,8), %rdi
	addq	$8, %rdi
	incq	%r13
	movq	%r15, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, (%rcx,%rbp)
	movzwl	16(%rax), %eax
	movw	%ax, 16(%rcx,%rbp)
	addq	$18, %rbp
	addq	$32, %rbx
	addq	$2, %r14
	cmpl	$152, %r14d
	movq	%r15, %rdi
	jne	.LBB3_30
# %bb.35:
	leaq	.L.str.206(%rip), %rdx
	leaq	48(%rsp), %rdi
	movl	$16, %esi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$76, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_36
# %bb.37:
	movl	$2432, %esi                     # imm = 0x980
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	testq	%rax, %rax
	movq	24(%rsp), %r14                  # 8-byte Reload
	movq	8(%rsp), %rbp                   # 8-byte Reload
	je	.LBB3_398
# %bb.38:
	movq	%rax, %r12
	movl	$152, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
	jmp	.LBB3_39
.LBB3_36:
	movq	24(%rsp), %r14                  # 8-byte Reload
	movq	8(%rsp), %rbp                   # 8-byte Reload
	movq	32(%rsp), %r12                  # 8-byte Reload
.LBB3_39:
	movabsq	$77309437582, %rax              # imm = 0x120000668E
	movq	%rax, 1216(%r12)
	movq	$0, 1224(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_399
# %bb.40:
	leaq	1224(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26254(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26270(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	movabsq	$77309437600, %rax              # imm = 0x12000066A0
	movq	%rax, 1232(%r12)
	movq	$0, 1240(%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_400
# %bb.41:
	leaq	1240(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26272(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26288(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$78, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_44
# %bb.42:
	movl	$2496, %esi                     # imm = 0x9C0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_401
# %bb.43:
	movq	%rax, %r12
	movl	$156, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_44:
	movabsq	$77309437618, %rax              # imm = 0x12000066B2
	movq	%rax, 1248(%r12)
	movq	$0, 1256(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_402
# %bb.45:
	leaq	1256(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26290(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26306(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	movabsq	$77309437636, %rax              # imm = 0x12000066C4
	movq	%rax, 1264(%r12)
	movq	$0, 1272(%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_403
# %bb.46:
	leaq	1272(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26308(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26324(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$80, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_49
# %bb.47:
	movl	$2560, %esi                     # imm = 0xA00
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_404
# %bb.48:
	movq	%rax, %r12
	movl	$160, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_49:
	movabsq	$77309437654, %rax              # imm = 0x12000066D6
	movq	%rax, 1280(%r12)
	movq	$0, 1288(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_405
# %bb.50:
	leaq	1288(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26326(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26342(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	movabsq	$77309437672, %rax              # imm = 0x12000066E8
	movq	%rax, 1296(%r12)
	movq	$0, 1304(%r12)
	movq	%rbx, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_406
# %bb.51:
	leaq	1304(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26344(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26360(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$82, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_54
# %bb.52:
	movl	$2624, %esi                     # imm = 0xA40
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_407
# %bb.53:
	movq	%rax, %r12
	movl	$164, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_54:
	movabsq	$77309437690, %rax              # imm = 0x12000066FA
	movq	%rax, 1312(%r12)
	movq	$0, 1320(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_408
# %bb.55:
	leaq	1320(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26362(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26378(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$83, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_58
# %bb.56:
	movl	$2656, %esi                     # imm = 0xA60
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_409
# %bb.57:
	movq	%rax, %r12
	movl	$166, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_58:
	movabsq	$77309437708, %rax              # imm = 0x120000670C
	movq	%rax, 1328(%r12)
	movq	$0, 1336(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_410
# %bb.59:
	leaq	1336(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26380(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26396(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$84, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_62
# %bb.60:
	movl	$2688, %esi                     # imm = 0xA80
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_411
# %bb.61:
	movq	%rax, %r12
	movl	$168, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_62:
	movabsq	$77309437726, %rax              # imm = 0x120000671E
	movq	%rax, 1344(%r12)
	movq	$0, 1352(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_412
# %bb.63:
	leaq	1352(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26398(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26414(%r14)
	leaq	.L.str.206(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$85, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_66
# %bb.64:
	movl	$2720, %esi                     # imm = 0xAA0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_413
# %bb.65:
	movq	%rax, %r12
	movl	$170, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_66:
	movabsq	$77309437744, %rax              # imm = 0x1200006730
	movq	%rax, 1360(%r12)
	movq	$0, 1368(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_414
# %bb.67:
	leaq	1368(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26416(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26432(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$86, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_70
# %bb.68:
	movl	$2752, %esi                     # imm = 0xAC0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_415
# %bb.69:
	movq	%rax, %r12
	movl	$172, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_70:
	movabsq	$77309437762, %rax              # imm = 0x1200006742
	movq	%rax, 1376(%r12)
	movq	$0, 1384(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_416
# %bb.71:
	leaq	1384(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26434(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26450(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$87, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_74
# %bb.72:
	movl	$2784, %esi                     # imm = 0xAE0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_417
# %bb.73:
	movq	%rax, %r12
	movl	$174, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_74:
	movabsq	$77309437780, %rax              # imm = 0x1200006754
	movq	%rax, 1392(%r12)
	movq	$0, 1400(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_418
# %bb.75:
	leaq	1400(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26452(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26468(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$88, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_78
# %bb.76:
	movl	$2816, %esi                     # imm = 0xB00
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_419
# %bb.77:
	movq	%rax, %r12
	movl	$176, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_78:
	movabsq	$77309437798, %rax              # imm = 0x1200006766
	movq	%rax, 1408(%r12)
	movq	$0, 1416(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_420
# %bb.79:
	leaq	1416(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26470(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26486(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$89, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_82
# %bb.80:
	movl	$2848, %esi                     # imm = 0xB20
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_421
# %bb.81:
	movq	%rax, %r12
	movl	$178, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_82:
	movabsq	$77309437816, %rax              # imm = 0x1200006778
	movq	%rax, 1424(%r12)
	movq	$0, 1432(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_422
# %bb.83:
	leaq	1432(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26488(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26504(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$90, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_86
# %bb.84:
	movl	$2880, %esi                     # imm = 0xB40
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_423
# %bb.85:
	movq	%rax, %r12
	movl	$180, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_86:
	movabsq	$77309437834, %rax              # imm = 0x120000678A
	movq	%rax, 1440(%r12)
	movq	$0, 1448(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_424
# %bb.87:
	leaq	1448(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26506(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26522(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$91, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_90
# %bb.88:
	movl	$2912, %esi                     # imm = 0xB60
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_425
# %bb.89:
	movq	%rax, %r12
	movl	$182, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_90:
	movabsq	$77309437852, %rax              # imm = 0x120000679C
	movq	%rax, 1456(%r12)
	movq	$0, 1464(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_426
# %bb.91:
	leaq	1464(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26524(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26540(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$92, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_94
# %bb.92:
	movl	$2944, %esi                     # imm = 0xB80
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_427
# %bb.93:
	movq	%rax, %r12
	movl	$184, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_94:
	movabsq	$77309437870, %rax              # imm = 0x12000067AE
	movq	%rax, 1472(%r12)
	movq	$0, 1480(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_428
# %bb.95:
	leaq	1480(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26542(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26558(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$93, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_98
# %bb.96:
	movl	$2976, %esi                     # imm = 0xBA0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_429
# %bb.97:
	movq	%rax, %r12
	movl	$186, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_98:
	movabsq	$77309437888, %rax              # imm = 0x12000067C0
	movq	%rax, 1488(%r12)
	movq	$0, 1496(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_430
# %bb.99:
	leaq	1496(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26560(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26576(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$8, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$94, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_102
# %bb.100:
	movl	$3008, %esi                     # imm = 0xBC0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_431
# %bb.101:
	movq	%rax, %r12
	movl	$188, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_102:
	movabsq	$77309437906, %rax              # imm = 0x12000067D2
	movq	%rax, 1504(%r12)
	movq	$0, 1512(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_432
# %bb.103:
	leaq	1512(%r12), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26578(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26594(%r14)
	leaq	.L.str.207(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$9, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$95, (%rsp)                     # 8-byte Folded Reload
	jne	.LBB3_106
# %bb.104:
	movl	$3040, %esi                     # imm = 0xBE0
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_433
# %bb.105:
	movq	%rax, %r12
	movl	$190, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
.LBB3_106:
	movabsq	$77309437924, %rax              # imm = 0x12000067E4
	movq	%rax, 1520(%r12)
	movq	$0, 1528(%r12)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_434
# %bb.107:
	leaq	1528(%r12), %rdi
	leaq	48(%rsp), %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26596(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26612(%r14)
	movq	(%rsp), %rbx                    # 8-byte Reload
	cmpq	$96, %rbx
	jne	.LBB3_108
# %bb.109:
	movl	$3072, %esi                     # imm = 0xC00
	movq	%r12, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_435
# %bb.110:
	movq	%rax, %r13
	movl	$192, %ebx
	jmp	.LBB3_111
.LBB3_108:
	movq	%r12, %r13
.LBB3_111:
	movabsq	$77309437942, %rax              # imm = 0x12000067F6
	movq	%rax, 1536(%r13)
	movabsq	$6074866968183460947, %rax      # imm = 0x544E435250545453
	movq	%rax, 1544(%r13)
	movzwl	16(%rbp), %eax
	movw	%ax, 26630(%r14)
	movups	(%rbp), %xmm0
	movups	%xmm0, 26614(%r14)
	leaq	.L.str.209(%rip), %rdx
	leaq	48(%rsp), %rdi
	movl	$16, %esi
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$97, %rbx
	jne	.LBB3_112
# %bb.113:
	movl	$3104, %esi                     # imm = 0xC20
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_436
# %bb.114:
	movq	%rax, %r13
	movl	$194, %r12d
	jmp	.LBB3_115
.LBB3_112:
	movq	%rbx, %r12
.LBB3_115:
	movabsq	$77309437960, %rax              # imm = 0x1200006808
	movq	%rax, 1552(%r13)
	movq	$0, 1560(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_437
# %bb.116:
	leaq	1560(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26632(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26648(%r14)
	leaq	.L.str.209(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$1, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$98, %r12
	jne	.LBB3_119
# %bb.117:
	movl	$3136, %esi                     # imm = 0xC40
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_438
# %bb.118:
	movq	%rax, %r13
	movl	$196, %r12d
.LBB3_119:
	movabsq	$77309437978, %rax              # imm = 0x120000681A
	movq	%rax, 1568(%r13)
	movq	$0, 1576(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_439
# %bb.120:
	leaq	1576(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26650(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26666(%r14)
	leaq	.L.str.209(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$99, %r12
	jne	.LBB3_123
# %bb.121:
	movl	$3168, %esi                     # imm = 0xC60
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_440
# %bb.122:
	movq	%rax, %r13
	movl	$198, %r12d
.LBB3_123:
	movabsq	$77309437996, %rax              # imm = 0x120000682C
	movq	%rax, 1584(%r13)
	movq	$0, 1592(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_441
# %bb.124:
	leaq	1592(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26668(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26684(%r14)
	leaq	.L.str.209(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$100, %r12
	jne	.LBB3_127
# %bb.125:
	movl	$3200, %esi                     # imm = 0xC80
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_442
# %bb.126:
	movq	%rax, %r13
	movl	$200, %r12d
.LBB3_127:
	movabsq	$77309438014, %rax              # imm = 0x120000683E
	movq	%rax, 1600(%r13)
	movq	$0, 1608(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_443
# %bb.128:
	leaq	1608(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26686(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26702(%r14)
	leaq	.L.str.209(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$101, %r12
	jne	.LBB3_131
# %bb.129:
	movl	$3232, %esi                     # imm = 0xCA0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_444
# %bb.130:
	movq	%rax, %r13
	movl	$202, %r12d
.LBB3_131:
	movabsq	$77309438032, %rax              # imm = 0x1200006850
	movq	%rax, 1616(%r13)
	movq	$0, 1624(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_445
# %bb.132:
	leaq	1624(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26704(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26720(%r14)
	leaq	.L.str.209(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$102, %r12
	jne	.LBB3_135
# %bb.133:
	movl	$3264, %esi                     # imm = 0xCC0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_446
# %bb.134:
	movq	%rax, %r13
	movl	$204, %r12d
.LBB3_135:
	movabsq	$77309438050, %rax              # imm = 0x1200006862
	movq	%rax, 1632(%r13)
	movq	$0, 1640(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_447
# %bb.136:
	leaq	1640(%r13), %rdi
	leaq	48(%rsp), %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26722(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26738(%r14)
	cmpq	$103, %r12
	jne	.LBB3_137
# %bb.138:
	movl	$3296, %esi                     # imm = 0xCE0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_448
# %bb.139:
	movq	%rax, %r13
	movl	$206, %ebx
	jmp	.LBB3_140
.LBB3_137:
	movq	%r12, %rbx
.LBB3_140:
	movabsq	$77309438068, %rax              # imm = 0x1200006874
	movq	%rax, 1648(%r13)
	movq	$0, 1656(%r13)
	movl	$1380013139, 1656(%r13)         # imm = 0x52415453
	movw	$21325, 1660(%r13)              # imm = 0x534D
	movzwl	16(%rbp), %eax
	movw	%ax, 26756(%r14)
	movups	(%rbp), %xmm0
	movups	%xmm0, 26740(%r14)
	leaq	.L.str.211(%rip), %rdx
	leaq	48(%rsp), %rdi
	movl	$16, %esi
	movl	$2, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$104, %rbx
	jne	.LBB3_141
# %bb.142:
	movl	$3328, %esi                     # imm = 0xD00
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_449
# %bb.143:
	movq	%rax, %r13
	movl	$208, %r12d
	jmp	.LBB3_144
.LBB3_141:
	movq	%rbx, %r12
.LBB3_144:
	movabsq	$77309438086, %rax              # imm = 0x1200006886
	movq	%rax, 1664(%r13)
	movq	$0, 1672(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_450
# %bb.145:
	leaq	1672(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26758(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26774(%r14)
	leaq	.L.str.211(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$3, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$105, %r12
	jne	.LBB3_148
# %bb.146:
	movl	$3360, %esi                     # imm = 0xD20
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_451
# %bb.147:
	movq	%rax, %r13
	movl	$210, %r12d
.LBB3_148:
	movabsq	$77309438104, %rax              # imm = 0x1200006898
	movq	%rax, 1680(%r13)
	movq	$0, 1688(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_452
# %bb.149:
	leaq	1688(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26776(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26792(%r14)
	leaq	.L.str.211(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$4, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$106, %r12
	jne	.LBB3_152
# %bb.150:
	movl	$3392, %esi                     # imm = 0xD40
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_453
# %bb.151:
	movq	%rax, %r13
	movl	$212, %r12d
.LBB3_152:
	movabsq	$77309438122, %rax              # imm = 0x12000068AA
	movq	%rax, 1696(%r13)
	movq	$0, 1704(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_454
# %bb.153:
	leaq	1704(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26794(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26810(%r14)
	leaq	.L.str.211(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$5, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$107, %r12
	jne	.LBB3_156
# %bb.154:
	movl	$3424, %esi                     # imm = 0xD60
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_455
# %bb.155:
	movq	%rax, %r13
	movl	$214, %r12d
.LBB3_156:
	movabsq	$77309438140, %rax              # imm = 0x12000068BC
	movq	%rax, 1712(%r13)
	movq	$0, 1720(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_456
# %bb.157:
	leaq	1720(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26812(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26828(%r14)
	leaq	.L.str.211(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$6, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$108, %r12
	jne	.LBB3_160
# %bb.158:
	movl	$3456, %esi                     # imm = 0xD80
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_457
# %bb.159:
	movq	%rax, %r13
	movl	$216, %r12d
.LBB3_160:
	movabsq	$77309438158, %rax              # imm = 0x12000068CE
	movq	%rax, 1728(%r13)
	movq	$0, 1736(%r13)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_458
# %bb.161:
	leaq	1736(%r13), %rdi
	leaq	48(%rsp), %rbx
	movq	%rbx, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26830(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26846(%r14)
	leaq	.L.str.211(%rip), %rdx
	movl	$16, %esi
	movq	%rbx, %rdi
	movl	$7, %ecx
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	$109, %r12
	jne	.LBB3_162
# %bb.163:
	movl	$3488, %esi                     # imm = 0xDA0
	movq	%r13, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_459
# %bb.164:
	movq	%rax, %rbx
	movl	$218, %r12d
	jmp	.LBB3_165
.LBB3_162:
	movq	%r13, %rbx
.LBB3_165:
	movabsq	$77309438176, %rax              # imm = 0x12000068E0
	movq	%rax, 1744(%rbx)
	movq	$0, 1752(%rbx)
	leaq	48(%rsp), %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_460
# %bb.166:
	leaq	1752(%rbx), %rdi
	leaq	48(%rsp), %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movups	(%rbp), %xmm0
	movups	%xmm0, 26848(%r14)
	movzwl	16(%rbp), %eax
	movw	%ax, 26864(%r14)
	cmpq	$110, %r12
	jne	.LBB3_169
# %bb.167:
	movl	$3520, %esi                     # imm = 0xDC0
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_461
# %bb.168:
	movq	%rax, %rbx
	movl	$220, %r12d
.LBB3_169:
	movabsq	$77309438194, %rax              # imm = 0x12000068F2
	movq	%rax, 1760(%rbx)
	movq	$0, 1768(%rbx)
	movl	$1111905363, 1768(%rbx)         # imm = 0x42465453
	movb	$48, 1772(%rbx)
	movzwl	16(%rbp), %eax
	movw	%ax, 26882(%r14)
	movups	(%rbp), %xmm0
	movups	%xmm0, 26866(%r14)
	cmpq	$111, %r12
	jne	.LBB3_170
# %bb.171:
	movl	$3552, %esi                     # imm = 0xDE0
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_462
# %bb.172:
	movq	%rax, %rbx
	movl	$222, %eax
	movq	%rax, (%rsp)                    # 8-byte Spill
	jmp	.LBB3_173
.LBB3_170:
	movq	%r12, (%rsp)                    # 8-byte Spill
.LBB3_173:
	movabsq	$77309438212, %rax              # imm = 0x1200006904
	movq	%rax, 1776(%rbx)
	movq	$0, 1784(%rbx)
	movl	$1094866003, 1784(%rbx)         # imm = 0x41425453
	movq	%rbx, 32(%rsp)                  # 8-byte Spill
	movb	$82, 1788(%rbx)
	movzwl	16(%rbp), %eax
	movw	%ax, 26900(%r14)
	movups	(%rbp), %xmm0
	movups	%xmm0, 26884(%r14)
	movl	$112, %r13d
	movl	$26902, %r14d                   # imm = 0x6916
	movl	$3584, %ebx                     # imm = 0xE00
	movl	$224, %ebp
	leaq	48(%rsp), %r12
	xorl	%r15d, %r15d
	.p2align	4
.LBB3_174:                              # =>This Inner Loop Header: Depth=1
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.214(%rip), %rdx
	movl	%r15d, %ecx
	xorl	%r8d, %r8d
	xorl	%eax, %eax
	callq	snprintf@PLT
	cmpq	(%rsp), %r13                    # 8-byte Folded Reload
	movq	%rbx, 200(%rsp)                 # 8-byte Spill
	jne	.LBB3_175
# %bb.176:                              #   in Loop: Header=BB3_174 Depth=1
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rbx, %rsi
	callq	realloc@PLT
	movq	%rax, %rbx
	movq	%rbp, (%rsp)                    # 8-byte Spill
	testq	%rax, %rax
	jne	.LBB3_177
	jmp	.LBB3_463
	.p2align	4
.LBB3_175:                              #   in Loop: Header=BB3_174 Depth=1
	movq	32(%rsp), %rbx                  # 8-byte Reload
.LBB3_177:                              #   in Loop: Header=BB3_174 Depth=1
	movl	%r14d, (%rbx,%rbp,8)
	movl	$18, 4(%rbx,%rbp,8)
	movq	$0, 8(%rbx,%rbp,8)
	leaq	48(%rsp), %r12
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_464
# %bb.178:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	(%rbx,%rbp,8), %rdi
	addq	$8, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, (%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 16(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.214(%rip), %rdx
	movl	%r15d, 20(%rsp)                 # 4-byte Spill
	movl	%r15d, %ecx
	movl	$1, %r8d
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%r13
	movq	(%rsp), %rax                    # 8-byte Reload
	cmpq	%rax, %r13
	jne	.LBB3_181
# %bb.179:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %r15
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_465
# %bb.180:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %rbx
	addq	%r15, %r15
	movq	%r15, (%rsp)                    # 8-byte Spill
.LBB3_181:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	18(%r14), %r15
	movl	%r15d, 16(%rbx,%rbp,8)
	movl	$18, 20(%rbx,%rbp,8)
	movq	$0, 24(%rbx,%rbp,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_466
# %bb.182:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	(%rbx,%rbp,8), %rdi
	addq	$24, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 18(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 34(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.214(%rip), %rdx
	movl	20(%rsp), %ecx                  # 4-byte Reload
	movl	$2, %r8d
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%r13
	movq	(%rsp), %rax                    # 8-byte Reload
	cmpq	%rax, %r13
	jne	.LBB3_185
# %bb.183:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_467
# %bb.184:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %rbx
	addq	%r12, %r12
	movq	%r12, (%rsp)                    # 8-byte Spill
	leaq	48(%rsp), %r12
.LBB3_185:                              #   in Loop: Header=BB3_174 Depth=1
	addq	$18, %r15
	movl	%r15d, 32(%rbx,%rbp,8)
	movl	$18, 36(%rbx,%rbp,8)
	movq	$0, 40(%rbx,%rbp,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_468
# %bb.186:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	(%rbx,%rbp,8), %rdi
	addq	$40, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 36(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 52(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.215(%rip), %rdx
	movl	20(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%r13
	movq	(%rsp), %rax                    # 8-byte Reload
	cmpq	%rax, %r13
	jne	.LBB3_189
# %bb.187:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_469
# %bb.188:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %rbx
	addq	%r12, %r12
	movq	%r12, (%rsp)                    # 8-byte Spill
	leaq	48(%rsp), %r12
.LBB3_189:                              #   in Loop: Header=BB3_174 Depth=1
	addq	$18, %r15
	movl	%r15d, 48(%rbx,%rbp,8)
	movl	$18, 52(%rbx,%rbp,8)
	movq	$0, 56(%rbx,%rbp,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_470
# %bb.190:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	(%rbx,%rbp,8), %rdi
	addq	$56, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 54(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 70(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.216(%rip), %rdx
	movl	20(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%r13
	movq	(%rsp), %rax                    # 8-byte Reload
	cmpq	%rax, %r13
	jne	.LBB3_193
# %bb.191:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_471
# %bb.192:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %rbx
	addq	%r12, %r12
	movq	%r12, (%rsp)                    # 8-byte Spill
	leaq	48(%rsp), %r12
.LBB3_193:                              #   in Loop: Header=BB3_174 Depth=1
	addq	$18, %r15
	movl	%r15d, 64(%rbx,%rbp,8)
	movl	$18, 68(%rbx,%rbp,8)
	movq	$0, 72(%rbx,%rbp,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_472
# %bb.194:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	(%rbx,%rbp,8), %rdi
	addq	$72, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 72(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 88(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.217(%rip), %rdx
	movl	20(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%r13
	movq	(%rsp), %rax                    # 8-byte Reload
	cmpq	%rax, %r13
	jne	.LBB3_197
# %bb.195:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_473
# %bb.196:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %rbx
	addq	%r12, %r12
	movq	%r12, (%rsp)                    # 8-byte Spill
	leaq	48(%rsp), %r12
.LBB3_197:                              #   in Loop: Header=BB3_174 Depth=1
	addq	$18, %r15
	movl	%r15d, 80(%rbx,%rbp,8)
	movl	$18, 84(%rbx,%rbp,8)
	movq	$0, 88(%rbx,%rbp,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_474
# %bb.198:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	(%rbx,%rbp,8), %rdi
	addq	$88, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 90(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 106(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.218(%rip), %rdx
	movl	20(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%r13
	movq	(%rsp), %rax                    # 8-byte Reload
	cmpq	%rax, %r13
	jne	.LBB3_201
# %bb.199:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_475
# %bb.200:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %rbx
	addq	%r12, %r12
	movq	%r12, (%rsp)                    # 8-byte Spill
	leaq	48(%rsp), %r12
.LBB3_201:                              #   in Loop: Header=BB3_174 Depth=1
	addq	$18, %r15
	movl	%r15d, 96(%rbx,%rbp,8)
	movl	$18, 100(%rbx,%rbp,8)
	movq	$0, 104(%rbx,%rbp,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_476
# %bb.202:                              #   in Loop: Header=BB3_174 Depth=1
	leaq	(%rbx,%rbp,8), %rdi
	addq	$104, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 108(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 124(%rcx,%r14)
	movl	$16, %esi
	movq	%r12, %rdi
	leaq	.L.str.219(%rip), %rdx
	movl	20(%rsp), %ecx                  # 4-byte Reload
	xorl	%eax, %eax
	callq	snprintf@PLT
	incq	%r13
	movq	(%rsp), %rax                    # 8-byte Reload
	cmpq	%rax, %r13
	jne	.LBB3_205
# %bb.203:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %r12
	movq	%rax, %rsi
	shlq	$5, %rsi
	movq	%rbx, %rdi
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_477
# %bb.204:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rax, %rbx
	addq	%r12, %r12
	movq	%r12, (%rsp)                    # 8-byte Spill
	leaq	48(%rsp), %r12
.LBB3_205:                              #   in Loop: Header=BB3_174 Depth=1
	addq	$18, %r15
	movl	%r15d, 112(%rbx,%rbp,8)
	movl	$18, 116(%rbx,%rbp,8)
	movq	$0, 120(%rbx,%rbp,8)
	movq	%r12, %rdi
	callq	strlen@PLT
	cmpq	$9, %rax
	jae	.LBB3_478
# %bb.206:                              #   in Loop: Header=BB3_174 Depth=1
	movq	%rbx, 32(%rsp)                  # 8-byte Spill
	leaq	(%rbx,%rbp,8), %rdi
	addq	$120, %rdi
	movq	%r12, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	8(%rsp), %rax                   # 8-byte Reload
	movups	(%rax), %xmm0
	movq	24(%rsp), %rcx                  # 8-byte Reload
	movups	%xmm0, 126(%rcx,%r14)
	movzwl	16(%rax), %eax
	movw	%ax, 142(%rcx,%r14)
	movl	20(%rsp), %eax                  # 4-byte Reload
	incl	%eax
	movq	200(%rsp), %rbx                 # 8-byte Reload
	addq	$256, %rbx                      # imm = 0x100
	addq	$16, %rbp
	incq	%r13
	addq	$18, %r15
	movq	%r15, %r14
	movl	%eax, %r15d
	cmpl	$304, %ebp                      # imm = 0x130
	jne	.LBB3_174
# %bb.207:
	movq	(%rsp), %rcx                    # 8-byte Reload
	cmpq	$152, %rcx
	jne	.LBB3_208
# %bb.209:
	movl	$4864, %esi                     # imm = 0x1300
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	realloc@PLT
	testq	%rax, %rax
	movq	24(%rsp), %rbp                  # 8-byte Reload
	movq	8(%rsp), %r15                   # 8-byte Reload
	je	.LBB3_479
# %bb.210:
	movq	%rax, %rdi
	movl	$304, %ecx                      # imm = 0x130
	jmp	.LBB3_211
.LBB3_208:
	movq	24(%rsp), %rbp                  # 8-byte Reload
	movq	8(%rsp), %r15                   # 8-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
.LBB3_211:
	movabsq	$77309438950, %rax              # imm = 0x1200006BE6
	movq	%rax, 2432(%rdi)
	movq	$0, 2440(%rdi)
	movl	$1195791443, 2440(%rdi)         # imm = 0x47465453
	movl	$809783111, 2443(%rdi)          # imm = 0x30444F47
	movzwl	16(%r15), %eax
	movw	%ax, 27638(%rbp)
	movups	(%r15), %xmm0
	movups	%xmm0, 27622(%rbp)
	cmpq	$153, %rcx
	jne	.LBB3_215
# %bb.212:
	movl	$4896, %esi                     # imm = 0x1320
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_214
# %bb.213:
	movq	%rax, %rdi
	movabsq	$77309438968, %rax              # imm = 0x1200006BF8
	movq	%rax, 2448(%rdi)
	movabsq	$3477976577990874195, %rax      # imm = 0x3044414544465453
	movq	%rax, 2456(%rdi)
	movzwl	16(%r15), %eax
	movw	%ax, 27656(%rbp)
	movups	(%r15), %xmm0
	movups	%xmm0, 27640(%rbp)
	movl	$306, %ecx                      # imm = 0x132
	jmp	.LBB3_218
.LBB3_215:
	movabsq	$77309438968, %rax              # imm = 0x1200006BF8
	movq	%rax, 2448(%rdi)
	movabsq	$3477976577990874195, %rax      # imm = 0x3044414544465453
	movq	%rax, 2456(%rdi)
	movzwl	16(%r15), %eax
	movw	%ax, 27656(%rbp)
	movups	(%r15), %xmm0
	movups	%xmm0, 27640(%rbp)
	cmpq	$154, %rcx
	jne	.LBB3_219
# %bb.216:
	movl	$4928, %esi                     # imm = 0x1340
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_480
# %bb.217:
	movq	%rax, %rdi
	movl	$308, %ecx                      # imm = 0x134
.LBB3_218:
	movabsq	$77309438986, %rax              # imm = 0x1200006C0A
	movq	%rax, 2464(%rdi)
	movabsq	$4848494732404607316, %rax      # imm = 0x434950454C544954
	movq	%rax, 2472(%rdi)
	movzwl	16(%r15), %eax
	movw	%ax, 27674(%rbp)
	movups	(%r15), %xmm0
	movups	%xmm0, 27658(%rbp)
.LBB3_222:
	movabsq	$77309439004, %rax              # imm = 0x1200006C1C
	movq	%rax, 2480(%rdi)
	movq	$0, 2488(%rdi)
	movl	$1145393731, 2488(%rdi)         # imm = 0x44455243
	movw	$21577, 2492(%rdi)              # imm = 0x5449
	movzwl	16(%r15), %eax
	movw	%ax, 27692(%rbp)
	movups	(%r15), %xmm0
	movups	%xmm0, 27676(%rbp)
	cmpq	$156, %rcx
	jne	.LBB3_224
# %bb.223:
	movl	$4992, %esi                     # imm = 0x1380
	callq	realloc@PLT
	movq	%rax, %rdi
	testq	%rax, %rax
	je	.LBB3_482
.LBB3_224:
	movabsq	$77309439022, %rax              # imm = 0x1200006C2E
	movq	%rax, 2496(%rdi)
	movq	$0, 2504(%rdi)
	movl	$1347175752, 2504(%rdi)         # imm = 0x504C4548
	movb	$50, 2508(%rdi)
	movzwl	16(%r15), %eax
	movw	%ax, 27710(%rbp)
	movdqu	(%r15), %xmm0
	movdqu	%xmm0, 27694(%rbp)
	movl	$27720, %eax                    # imm = 0x6C48
	.p2align	4
.LBB3_225:                              # =>This Inner Loop Header: Depth=1
	movl	-27720(%rdi,%rax), %ecx
	movl	%ecx, -8(%rbp,%rax)
	movl	-27716(%rdi,%rax), %ecx
	movl	%ecx, -4(%rbp,%rax)
	movq	-27712(%rdi,%rax), %rcx
	movq	%rcx, (%rbp,%rax)
	addq	$16, %rax
	cmpq	$30232, %rax                    # imm = 0x7618
	jne	.LBB3_225
# %bb.226:
	movq	%rdi, %r12
	movl	$1145132873, (%rbp)             # imm = 0x44415749
	movabsq	$119022133706909, %rax          # imm = 0x6C400000009D
	movq	%rax, 4(%rbp)
	movl	$30224, %r15d                   # imm = 0x7610
	movq	$-30184, %r13                   # imm = 0x8A18
	leaq	.L__const.build_generated_wad.pattern(%rip), %rbx
	.p2align	4
.LBB3_227:                              # =>This Inner Loop Header: Depth=1
	cmpq	$1048496, %r15                  # imm = 0xFFFB0
	movl	$1048496, %r14d                 # imm = 0xFFFB0
	cmovbq	%r15, %r14
	cmpq	$1048536, %r15                  # imm = 0xFFFD8
	movl	$1048536, %edx                  # imm = 0xFFFD8
	cmovbq	%r15, %rdx
	addq	%r13, %rdx
	leaq	(%r15,%rbp), %rdi
	movq	%rbx, %rsi
	callq	memcpy@PLT
	cmpq	$1048535, %r15                  # imm = 0xFFFD7
	ja	.LBB3_229
# %bb.228:                              #   in Loop: Header=BB3_227 Depth=1
	addq	%r13, %r14
	leaq	(%r15,%rbp), %rdi
	addq	$40, %rdi
	addq	$80, %r15
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	memcpy@PLT
	addq	$-80, %r13
	jmp	.LBB3_227
.LBB3_229:
	movq	%r12, %rdi
	callq	free@PLT
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	free@PLT
	movq	160(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movq	144(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movq	184(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movq	176(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movl	$1048576, %edx                  # imm = 0x100000
	movq	%rbp, %r14
	movq	40(%rsp), %rbp                  # 8-byte Reload
.LBB3_230:
	movl	$0, 156(%rsp)
	leaq	156(%rsp), %rcx
	movq	%rbp, %rdi
	movq	%r14, %rsi
	movq	%rdx, %r15
	callq	write_cluster_chain
	cmpl	$2, %eax
	jne	.LBB3_483
# %bb.231:
	movq	%rbp, %rax
	movq	336(%rsp), %rbp
	movq	328(%rsp), %rbx
	movq	320(%rsp), %r12
	movq	312(%rsp), %r13
	movq	(%rax), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_232:                              # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_234
# %bb.233:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	jne	.LBB3_235
.LBB3_234:                              #   in Loop: Header=BB3_232 Depth=1
	movl	%esi, %ecx
.LBB3_235:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	je	.LBB3_254
# %bb.236:                              #   in Loop: Header=BB3_232 Depth=1
	cmpl	$229, %edi
	je	.LBB3_254
# %bb.237:                              #   in Loop: Header=BB3_232 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_239
# %bb.238:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	jne	.LBB3_240
.LBB3_239:                              #   in Loop: Header=BB3_232 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_240:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	je	.LBB3_254
# %bb.241:                              #   in Loop: Header=BB3_232 Depth=1
	cmpl	$229, %edi
	je	.LBB3_254
# %bb.242:                              #   in Loop: Header=BB3_232 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_244
# %bb.243:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	jne	.LBB3_245
.LBB3_244:                              #   in Loop: Header=BB3_232 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_245:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	je	.LBB3_254
# %bb.246:                              #   in Loop: Header=BB3_232 Depth=1
	cmpl	$229, %edi
	je	.LBB3_254
# %bb.247:                              #   in Loop: Header=BB3_232 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_249
# %bb.248:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	jne	.LBB3_250
.LBB3_249:                              #   in Loop: Header=BB3_232 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_250:                              #   in Loop: Header=BB3_232 Depth=1
	testl	%edi, %edi
	je	.LBB3_254
# %bb.251:                              #   in Loop: Header=BB3_232 Depth=1
	cmpl	$229, %edi
	je	.LBB3_254
# %bb.252:                              #   in Loop: Header=BB3_232 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_232
# %bb.253:
	callq	install_bootable_layout.cold.19
.LBB3_254:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_484
# %bb.255:
	shll	$5, %ecx
	pxor	%xmm0, %xmm0
	movdqu	%xmm0, 12(%rax,%rcx)
	movl	$0, 28(%rax,%rcx)
	movabsq	$2314885604590964548, %rdx      # imm = 0x202020314D4F4F44
	movq	%rdx, (%rax,%rcx)
	movl	$1145132832, 7(%rax,%rcx)       # imm = 0x44415720
	movb	$32, 11(%rax,%rcx)
	movw	$2, 26(%rax,%rcx)
	movq	%r15, %rdx
	movb	%dl, 28(%rax,%rcx)
	movb	%dh, 29(%rax,%rcx)
	shrl	$16, %edx
	movb	%dl, 30(%rax,%rcx)
	movb	$0, 31(%rax,%rcx)
	movq	%r14, %rdi
	callq	free@PLT
	movq	168(%rsp), %rdi                 # 8-byte Reload
	testq	%rdi, %rdi
	je	.LBB3_257
# %bb.256:
	callq	read_file
	movq	%rax, %r14
	movq	%rdx, %r8
	leaq	KERNEL_ELF_NAME(%rip), %rsi
	movl	$1, %edx
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	write_file_path
	movq	%r14, %rdi
	callq	free@PLT
.LBB3_257:
	movq	192(%rsp), %rdi                 # 8-byte Reload
	testq	%rdi, %rdi
	je	.LBB3_260
# %bb.258:
	callq	read_file
	movq	%rax, %r14
	movq	%rdx, %r8
	leaq	USER_PROBE_NAME(%rip), %rsi
	movl	$1, %edx
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	write_file_path
	movq	%r14, %rdi
	callq	free@PLT
	cmpq	$0, 304(%rsp)
	je	.LBB3_260
# %bb.259:
	movq	304(%rsp), %rdi
	callq	read_file
	movq	%rax, %r14
	movq	%rdx, %r8
	leaq	LEGACY_PAYLOAD_ELF_NAME(%rip), %rsi
	movl	$1, %edx
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rcx
	movl	$32, %r9d
	callq	write_file_path
	movq	%r14, %rdi
	callq	free@PLT
.LBB3_260:
	testq	%r12, %r12
	movq	40(%rsp), %r14                  # 8-byte Reload
	je	.LBB3_263
# %bb.261:
	addq	$16, %r13
	.p2align	4
.LBB3_262:                              # =>This Inner Loop Header: Depth=1
	movq	(%r13), %rdi
	callq	read_file
	movq	%rax, %r15
	movq	%rdx, %r8
	movl	-9(%r13), %eax
	movl	%eax, 55(%rsp)
	movq	-16(%r13), %rax
	movq	%rax, 48(%rsp)
	movl	$1, %edx
	movq	%r14, %rdi
	leaq	48(%rsp), %rsi
	movq	%r15, %rcx
	movl	$32, %r9d
	callq	write_file_path
	movq	%r15, %rdi
	callq	free@PLT
	addq	$24, %r13
	decq	%r12
	jne	.LBB3_262
.LBB3_263:
	movq	$0, 136(%rsp)
	leaq	STATE_DIR_NAME(%rip), %rdx
	xorl	%r15d, %r15d
	movq	%r14, %rdi
	xorl	%esi, %esi
	movl	$16, %ecx
	callq	ensure_child_directory
	leaq	.L.str.226(%rip), %rdi
	leaq	48(%rsp), %r13
	leaq	136(%rsp), %r12
	movl	$4, %ecx
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	parse_path83
	movq	136(%rsp), %rdx
	leaq	package_default_assets.readme(%rip), %rcx
	movl	$35, %r8d
	movq	%r14, %rdi
	movq	%r13, %rsi
	movl	$33, %r9d
	callq	write_file_path
	leaq	.L.str.227(%rip), %rdi
	movl	$4, %ecx
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	parse_path83
	movq	136(%rsp), %rdx
	leaq	package_default_assets.map(%rip), %rcx
	movl	$23, %r8d
	movq	%r14, %rdi
	movq	%r13, %rsi
	movl	$33, %r9d
	callq	write_file_path
	movaps	.LCPI3_2(%rip), %xmm0           # xmm0 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	movaps	%xmm0, 208(%rsp)
	movdqa	.LCPI3_12(%rip), %xmm0          # xmm0 = [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
	movdqa	%xmm0, 224(%rsp)
	leaq	.L.str.228(%rip), %rdi
	movl	$4, %ecx
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	parse_path83
	movq	136(%rsp), %rdx
	leaq	208(%rsp), %rcx
	movl	$32, %r8d
	movq	%r14, %rdi
	movq	%r13, %rsi
	movl	$33, %r9d
	callq	write_file_path
	testq	%rbp, %rbp
	je	.LBB3_267
# %bb.264:
	leaq	48(%rsp), %r14
	.p2align	4
.LBB3_265:                              # =>This Inner Loop Header: Depth=1
	movq	96(%rbx), %r12
	movq	$0, 208(%rsp)
	movl	$8, %ecx
	movq	%rbx, %rdi
	movq	%r14, %rsi
	leaq	208(%rsp), %rdx
	callq	parse_path83
	movq	208(%rsp), %r13
	cmpq	$1, %r13
	jbe	.LBB3_485
# %bb.266:                              #   in Loop: Header=BB3_265 Depth=1
	movq	%r12, %rdi
	callq	read_file
	movq	%rax, %r12
	movq	%rdx, %r8
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%r14, %rsi
	movq	%r13, %rdx
	movq	%rax, %rcx
	movl	$33, %r9d
	callq	write_file_path
	movq	%r12, %rdi
	callq	free@PLT
	addq	$104, %rbx
	decq	%rbp
	jne	.LBB3_265
.LBB3_267:
	leaq	DEFAULT_CFG_NAME(%rip), %rsi
	leaq	DEFAULT_CFG_CONTENT(%rip), %rcx
	movl	$1, %edx
	movl	$17, %r8d
	movq	40(%rsp), %rbx                  # 8-byte Reload
	movq	%rbx, %rdi
	movl	$32, %r9d
	callq	write_file_path
	.p2align	4
.LBB3_268:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_269 Depth 2
	movl	%r15d, %eax
	orb	$48, %al
	movq	(%rbx), %rsi
	leaq	1311232(%rsi), %rcx
	addq	$1311328, %rsi                  # imm = 0x140260
	xorl	%edi, %edi
                                        # implicit-def: $edx
.LBB3_269:                              #   Parent Loop BB3_268 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	-96(%rsi), %r8d
	cmpl	$229, %r8d
	je	.LBB3_271
# %bb.270:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	jne	.LBB3_272
.LBB3_271:                              #   in Loop: Header=BB3_269 Depth=2
	movl	%edi, %edx
.LBB3_272:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	je	.LBB3_366
# %bb.273:                              #   in Loop: Header=BB3_269 Depth=2
	cmpl	$229, %r8d
	je	.LBB3_366
# %bb.274:                              #   in Loop: Header=BB3_269 Depth=2
	movzbl	-64(%rsi), %r8d
	cmpl	$229, %r8d
	je	.LBB3_276
# %bb.275:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	jne	.LBB3_277
.LBB3_276:                              #   in Loop: Header=BB3_269 Depth=2
	leaq	1(%rdi), %rdx
.LBB3_277:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	je	.LBB3_366
# %bb.278:                              #   in Loop: Header=BB3_269 Depth=2
	cmpl	$229, %r8d
	je	.LBB3_366
# %bb.279:                              #   in Loop: Header=BB3_269 Depth=2
	movzbl	-32(%rsi), %r8d
	cmpl	$229, %r8d
	je	.LBB3_281
# %bb.280:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	jne	.LBB3_282
.LBB3_281:                              #   in Loop: Header=BB3_269 Depth=2
	leaq	2(%rdi), %rdx
.LBB3_282:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	je	.LBB3_366
# %bb.283:                              #   in Loop: Header=BB3_269 Depth=2
	cmpl	$229, %r8d
	je	.LBB3_366
# %bb.284:                              #   in Loop: Header=BB3_269 Depth=2
	movzbl	(%rsi), %r8d
	cmpl	$229, %r8d
	je	.LBB3_286
# %bb.285:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	jne	.LBB3_287
.LBB3_286:                              #   in Loop: Header=BB3_269 Depth=2
	leaq	3(%rdi), %rdx
.LBB3_287:                              #   in Loop: Header=BB3_269 Depth=2
	testl	%r8d, %r8d
	je	.LBB3_366
# %bb.288:                              #   in Loop: Header=BB3_269 Depth=2
	cmpl	$229, %r8d
	je	.LBB3_366
# %bb.289:                              #   in Loop: Header=BB3_269 Depth=2
	addq	$4, %rdi
	subq	$-128, %rsi
	cmpq	$512, %rdi                      # imm = 0x200
	jne	.LBB3_269
	jmp	.LBB3_290
	.p2align	4
.LBB3_366:                              #   in Loop: Header=BB3_268 Depth=1
	cmpl	$512, %edx                      # imm = 0x200
	jae	.LBB3_489
# %bb.367:                              #   in Loop: Header=BB3_268 Depth=1
	shll	$5, %edx
	movq	$0, 18(%rcx,%rdx)
	movq	$0, 12(%rcx,%rdx)
	movl	$1297043268, (%rcx,%rdx)        # imm = 0x4D4F4F44
	movl	$1447121741, 3(%rcx,%rdx)       # imm = 0x5641534D
	movb	%al, 7(%rcx,%rdx)
	movl	$541545284, 8(%rcx,%rdx)        # imm = 0x20475344
	movl	$0, 26(%rcx,%rdx)
	movw	$0, 30(%rcx,%rdx)
	incl	%r15d
	cmpl	$6, %r15d
	jne	.LBB3_268
# %bb.291:
	movq	(%rbx), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_292:                              # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_294
# %bb.293:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	jne	.LBB3_295
.LBB3_294:                              #   in Loop: Header=BB3_292 Depth=1
	movl	%esi, %ecx
.LBB3_295:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	je	.LBB3_314
# %bb.296:                              #   in Loop: Header=BB3_292 Depth=1
	cmpl	$229, %edi
	je	.LBB3_314
# %bb.297:                              #   in Loop: Header=BB3_292 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_299
# %bb.298:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	jne	.LBB3_300
.LBB3_299:                              #   in Loop: Header=BB3_292 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_300:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	je	.LBB3_314
# %bb.301:                              #   in Loop: Header=BB3_292 Depth=1
	cmpl	$229, %edi
	je	.LBB3_314
# %bb.302:                              #   in Loop: Header=BB3_292 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_304
# %bb.303:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	jne	.LBB3_305
.LBB3_304:                              #   in Loop: Header=BB3_292 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_305:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	je	.LBB3_314
# %bb.306:                              #   in Loop: Header=BB3_292 Depth=1
	cmpl	$229, %edi
	je	.LBB3_314
# %bb.307:                              #   in Loop: Header=BB3_292 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_309
# %bb.308:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	jne	.LBB3_310
.LBB3_309:                              #   in Loop: Header=BB3_292 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_310:                              #   in Loop: Header=BB3_292 Depth=1
	testl	%edi, %edi
	je	.LBB3_314
# %bb.311:                              #   in Loop: Header=BB3_292 Depth=1
	cmpl	$229, %edi
	je	.LBB3_314
# %bb.312:                              #   in Loop: Header=BB3_292 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_292
# %bb.313:
	callq	install_bootable_layout.cold.15
.LBB3_314:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_486
# %bb.315:
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
	movq	(%rbx), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_316:                              # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_318
# %bb.317:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	jne	.LBB3_319
.LBB3_318:                              #   in Loop: Header=BB3_316 Depth=1
	movl	%esi, %ecx
.LBB3_319:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	je	.LBB3_338
# %bb.320:                              #   in Loop: Header=BB3_316 Depth=1
	cmpl	$229, %edi
	je	.LBB3_338
# %bb.321:                              #   in Loop: Header=BB3_316 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_323
# %bb.322:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	jne	.LBB3_324
.LBB3_323:                              #   in Loop: Header=BB3_316 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_324:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	je	.LBB3_338
# %bb.325:                              #   in Loop: Header=BB3_316 Depth=1
	cmpl	$229, %edi
	je	.LBB3_338
# %bb.326:                              #   in Loop: Header=BB3_316 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_328
# %bb.327:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	jne	.LBB3_329
.LBB3_328:                              #   in Loop: Header=BB3_316 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_329:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	je	.LBB3_338
# %bb.330:                              #   in Loop: Header=BB3_316 Depth=1
	cmpl	$229, %edi
	je	.LBB3_338
# %bb.331:                              #   in Loop: Header=BB3_316 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_333
# %bb.332:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	jne	.LBB3_334
.LBB3_333:                              #   in Loop: Header=BB3_316 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_334:                              #   in Loop: Header=BB3_316 Depth=1
	testl	%edi, %edi
	je	.LBB3_338
# %bb.335:                              #   in Loop: Header=BB3_316 Depth=1
	cmpl	$229, %edi
	je	.LBB3_338
# %bb.336:                              #   in Loop: Header=BB3_316 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_316
# %bb.337:
	callq	install_bootable_layout.cold.13
.LBB3_338:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_487
# %bb.339:
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
	movq	(%rbx), %rdx
	leaq	1311232(%rdx), %rax
	addq	$1311328, %rdx                  # imm = 0x140260
	xorl	%esi, %esi
                                        # implicit-def: $ecx
.LBB3_340:                              # =>This Inner Loop Header: Depth=1
	movzbl	-96(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_342
# %bb.341:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	jne	.LBB3_343
.LBB3_342:                              #   in Loop: Header=BB3_340 Depth=1
	movl	%esi, %ecx
.LBB3_343:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	je	.LBB3_362
# %bb.344:                              #   in Loop: Header=BB3_340 Depth=1
	cmpl	$229, %edi
	je	.LBB3_362
# %bb.345:                              #   in Loop: Header=BB3_340 Depth=1
	movzbl	-64(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_347
# %bb.346:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	jne	.LBB3_348
.LBB3_347:                              #   in Loop: Header=BB3_340 Depth=1
	leaq	1(%rsi), %rcx
.LBB3_348:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	je	.LBB3_362
# %bb.349:                              #   in Loop: Header=BB3_340 Depth=1
	cmpl	$229, %edi
	je	.LBB3_362
# %bb.350:                              #   in Loop: Header=BB3_340 Depth=1
	movzbl	-32(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_352
# %bb.351:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	jne	.LBB3_353
.LBB3_352:                              #   in Loop: Header=BB3_340 Depth=1
	leaq	2(%rsi), %rcx
.LBB3_353:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	je	.LBB3_362
# %bb.354:                              #   in Loop: Header=BB3_340 Depth=1
	cmpl	$229, %edi
	je	.LBB3_362
# %bb.355:                              #   in Loop: Header=BB3_340 Depth=1
	movzbl	(%rdx), %edi
	cmpl	$229, %edi
	je	.LBB3_357
# %bb.356:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	jne	.LBB3_358
.LBB3_357:                              #   in Loop: Header=BB3_340 Depth=1
	leaq	3(%rsi), %rcx
.LBB3_358:                              #   in Loop: Header=BB3_340 Depth=1
	testl	%edi, %edi
	je	.LBB3_362
# %bb.359:                              #   in Loop: Header=BB3_340 Depth=1
	cmpl	$229, %edi
	je	.LBB3_362
# %bb.360:                              #   in Loop: Header=BB3_340 Depth=1
	addq	$4, %rsi
	subq	$-128, %rdx
	cmpq	$512, %rsi                      # imm = 0x200
	jne	.LBB3_340
# %bb.361:
	callq	install_bootable_layout.cold.11
.LBB3_362:
	cmpl	$512, %ecx                      # imm = 0x200
	jae	.LBB3_488
# %bb.363:
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
	leaq	16(%rbx), %rax
	movl	$22, %ecx
	movdqa	.LCPI3_13(%rip), %xmm1          # xmm1 = [1,1,1,1]
	pxor	%xmm5, %xmm5
	pxor	%xmm4, %xmm4
	.p2align	4
.LBB3_364:                              # =>This Inner Loop Header: Depth=1
	movq	-24(%rbx,%rcx,2), %xmm3         # xmm3 = mem[0],zero
	movq	-16(%rbx,%rcx,2), %xmm2         # xmm2 = mem[0],zero
	pcmpeqw	%xmm0, %xmm3
	punpcklwd	%xmm3, %xmm3            # xmm3 = xmm3[0,0,1,1,2,2,3,3]
	pand	%xmm1, %xmm3
	paddd	%xmm5, %xmm3
	pcmpeqw	%xmm0, %xmm2
	punpcklwd	%xmm2, %xmm2            # xmm2 = xmm2[0,0,1,1,2,2,3,3]
	pand	%xmm1, %xmm2
	paddd	%xmm4, %xmm2
	cmpq	$64246, %rcx                    # imm = 0xFAF6
	je	.LBB3_368
# %bb.365:                              #   in Loop: Header=BB3_364 Depth=1
	movq	-8(%rbx,%rcx,2), %xmm4          # xmm4 = mem[0],zero
	movq	(%rbx,%rcx,2), %xmm5            # xmm5 = mem[0],zero
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
	jmp	.LBB3_364
.LBB3_368:
	paddd	%xmm3, %xmm2
	pshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	paddd	%xmm2, %xmm0
	pshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	paddd	%xmm0, %xmm1
	movd	%xmm1, %ecx
	cmpw	$1, 128484(%rbx)
	adcl	$0, %ecx
	xorl	%edx, %edx
	cmpw	$0, 128486(%rbx)
	sete	%dl
	cmpw	$1, 128488(%rbx)
	adcl	%ecx, %edx
	xorl	%ecx, %ecx
	cmpw	$0, 128490(%rbx)
	sete	%cl
	cmpw	$1, 128492(%rbx)
	adcl	%edx, %ecx
	xorl	%edx, %edx
	cmpw	$0, 128494(%rbx)
	sete	%dl
	cmpw	$1, 128496(%rbx)
	adcl	%ecx, %edx
	cmpl	$4095, %edx                     # imm = 0xFFF
	jbe	.LBB3_490
# %bb.369:
	movl	$-8, 16(%rbx)
	movq	(%rbx), %rdx
	leaq	1049088(%rdx), %rsi
	leaq	1180160(%rdx), %rdi
	leaq	131088(%rbx), %rcx
	cmpq	%rcx, %rsi
	setae	%r8b
	cmpq	%rdi, %rax
	setae	%dil
	orb	%r8b, %dil
	jne	.LBB3_372
# %bb.370:
	xorl	%esi, %esi
	.p2align	4
.LBB3_371:                              # =>This Inner Loop Header: Depth=1
	movzwl	16(%rbx,%rsi,2), %edi
	movw	%di, 1049088(%rdx,%rsi,2)
	movzwl	18(%rbx,%rsi,2), %edi
	movw	%di, 1049090(%rdx,%rsi,2)
	addq	$2, %rsi
	cmpq	$65536, %rsi                    # imm = 0x10000
	jne	.LBB3_371
	jmp	.LBB3_374
.LBB3_372:
	xorl	%edx, %edx
	.p2align	4
.LBB3_373:                              # =>This Inner Loop Header: Depth=1
	movdqu	16(%rbx,%rdx,2), %xmm0
	movdqu	32(%rbx,%rdx,2), %xmm1
	movdqu	%xmm0, (%rsi,%rdx,2)
	movdqu	%xmm1, 16(%rsi,%rdx,2)
	addq	$16, %rdx
	cmpq	$65536, %rdx                    # imm = 0x10000
	jne	.LBB3_373
.LBB3_374:
	movq	(%rbx), %rdx
	leaq	1180160(%rdx), %rsi
	leaq	1311232(%rdx), %rdi
	cmpq	%rcx, %rsi
	setae	%cl
	cmpq	%rdi, %rax
	setae	%al
	orb	%cl, %al
	jne	.LBB3_377
# %bb.375:
	xorl	%eax, %eax
	.p2align	4
.LBB3_376:                              # =>This Inner Loop Header: Depth=1
	movzwl	16(%rbx,%rax,2), %ecx
	movw	%cx, 1180160(%rdx,%rax,2)
	movzwl	18(%rbx,%rax,2), %ecx
	movw	%cx, 1180162(%rdx,%rax,2)
	addq	$2, %rax
	cmpq	$65536, %rax                    # imm = 0x10000
	jne	.LBB3_376
	jmp	.LBB3_379
.LBB3_377:
	xorl	%eax, %eax
	.p2align	4
.LBB3_378:                              # =>This Inner Loop Header: Depth=1
	movdqu	16(%rbx,%rax,2), %xmm0
	movdqu	32(%rbx,%rax,2), %xmm1
	movdqu	%xmm0, (%rsi,%rax,2)
	movdqu	%xmm1, 16(%rsi,%rax,2)
	addq	$16, %rax
	cmpq	$65536, %rax                    # imm = 0x10000
	jne	.LBB3_378
.LBB3_379:
	addq	$248, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB3_219:
	.cfi_def_cfa_offset 304
	movabsq	$77309438986, %rax              # imm = 0x1200006C0A
	movq	%rax, 2464(%rdi)
	movabsq	$4848494732404607316, %rax      # imm = 0x434950454C544954
	movq	%rax, 2472(%rdi)
	movzwl	16(%r15), %eax
	movw	%ax, 27674(%rbp)
	movups	(%r15), %xmm0
	movups	%xmm0, 27658(%rbp)
	cmpq	$155, %rcx
	jne	.LBB3_222
# %bb.220:
	movl	$4960, %esi                     # imm = 0x1360
	callq	realloc@PLT
	testq	%rax, %rax
	je	.LBB3_481
# %bb.221:
	movq	%rax, %rdi
	movl	$310, %ecx                      # imm = 0x136
	jmp	.LBB3_222
.LBB3_290:
	callq	install_bootable_layout.cold.17
.LBB3_489:
	callq	install_bootable_layout.cold.16
.LBB3_485:
	callq	install_bootable_layout.cold.8
.LBB3_392:
	callq	install_bootable_layout.cold.109
.LBB3_397:
	callq	install_bootable_layout.cold.104
.LBB3_478:
	callq	install_bootable_layout.cold.23
.LBB3_466:
	callq	install_bootable_layout.cold.35
.LBB3_464:
	callq	install_bootable_layout.cold.37
.LBB3_472:
	callq	install_bootable_layout.cold.29
.LBB3_468:
	callq	install_bootable_layout.cold.33
.LBB3_470:
	callq	install_bootable_layout.cold.31
.LBB3_474:
	callq	install_bootable_layout.cold.27
.LBB3_476:
	callq	install_bootable_layout.cold.25
.LBB3_396:
	callq	install_bootable_layout.cold.105
.LBB3_463:
	callq	install_bootable_layout.cold.38
.LBB3_469:
	callq	install_bootable_layout.cold.32
.LBB3_471:
	callq	install_bootable_layout.cold.30
.LBB3_465:
	callq	install_bootable_layout.cold.36
.LBB3_467:
	callq	install_bootable_layout.cold.34
.LBB3_473:
	callq	install_bootable_layout.cold.28
.LBB3_475:
	callq	install_bootable_layout.cold.26
.LBB3_477:
	callq	install_bootable_layout.cold.24
.LBB3_380:
	callq	install_bootable_layout.cold.1
.LBB3_381:
	callq	install_bootable_layout.cold.2
.LBB3_483:
	callq	install_bootable_layout.cold.7
.LBB3_484:
	callq	install_bootable_layout.cold.18
.LBB3_486:
	callq	install_bootable_layout.cold.14
.LBB3_487:
	callq	install_bootable_layout.cold.12
.LBB3_488:
	callq	install_bootable_layout.cold.10
.LBB3_490:
	callq	install_bootable_layout.cold.9
.LBB3_382:
	leaq	.L.str.136(%rip), %rsi
	movq	%r12, %rdi
	callq	die_path
.LBB3_383:
	movq	%rdx, %rdi
	callq	install_bootable_layout.cold.4
.LBB3_385:
	leaq	.L.str.141(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_384:
	movq	%rdx, %rdi
	callq	install_bootable_layout.cold.3
.LBB3_386:
	leaq	.L.str.142(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_387:
	leaq	.L.str.145(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB3_388:
	callq	install_bootable_layout.cold.113
.LBB3_389:
	callq	install_bootable_layout.cold.112
.LBB3_390:
	callq	install_bootable_layout.cold.111
.LBB3_391:
	callq	install_bootable_layout.cold.110
.LBB3_393:
	callq	install_bootable_layout.cold.108
.LBB3_394:
	callq	install_bootable_layout.cold.107
.LBB3_395:
	callq	install_bootable_layout.cold.106
.LBB3_399:
	callq	install_bootable_layout.cold.102
.LBB3_400:
	callq	install_bootable_layout.cold.101
.LBB3_402:
	callq	install_bootable_layout.cold.99
.LBB3_403:
	callq	install_bootable_layout.cold.98
.LBB3_405:
	callq	install_bootable_layout.cold.96
.LBB3_406:
	callq	install_bootable_layout.cold.95
.LBB3_408:
	callq	install_bootable_layout.cold.93
.LBB3_410:
	callq	install_bootable_layout.cold.91
.LBB3_412:
	callq	install_bootable_layout.cold.89
.LBB3_414:
	callq	install_bootable_layout.cold.87
.LBB3_416:
	callq	install_bootable_layout.cold.85
.LBB3_418:
	callq	install_bootable_layout.cold.83
.LBB3_420:
	callq	install_bootable_layout.cold.81
.LBB3_422:
	callq	install_bootable_layout.cold.79
.LBB3_424:
	callq	install_bootable_layout.cold.77
.LBB3_426:
	callq	install_bootable_layout.cold.75
.LBB3_428:
	callq	install_bootable_layout.cold.73
.LBB3_430:
	callq	install_bootable_layout.cold.71
.LBB3_432:
	callq	install_bootable_layout.cold.69
.LBB3_434:
	callq	install_bootable_layout.cold.67
.LBB3_437:
	callq	install_bootable_layout.cold.64
.LBB3_439:
	callq	install_bootable_layout.cold.62
.LBB3_441:
	callq	install_bootable_layout.cold.60
.LBB3_443:
	callq	install_bootable_layout.cold.58
.LBB3_445:
	callq	install_bootable_layout.cold.56
.LBB3_447:
	callq	install_bootable_layout.cold.54
.LBB3_450:
	callq	install_bootable_layout.cold.51
.LBB3_452:
	callq	install_bootable_layout.cold.49
.LBB3_454:
	callq	install_bootable_layout.cold.47
.LBB3_456:
	callq	install_bootable_layout.cold.45
.LBB3_458:
	callq	install_bootable_layout.cold.43
.LBB3_460:
	callq	install_bootable_layout.cold.41
.LBB3_398:
	callq	install_bootable_layout.cold.103
.LBB3_401:
	callq	install_bootable_layout.cold.100
.LBB3_404:
	callq	install_bootable_layout.cold.97
.LBB3_407:
	callq	install_bootable_layout.cold.94
.LBB3_409:
	callq	install_bootable_layout.cold.92
.LBB3_411:
	callq	install_bootable_layout.cold.90
.LBB3_413:
	callq	install_bootable_layout.cold.88
.LBB3_415:
	callq	install_bootable_layout.cold.86
.LBB3_417:
	callq	install_bootable_layout.cold.84
.LBB3_419:
	callq	install_bootable_layout.cold.82
.LBB3_421:
	callq	install_bootable_layout.cold.80
.LBB3_423:
	callq	install_bootable_layout.cold.78
.LBB3_425:
	callq	install_bootable_layout.cold.76
.LBB3_427:
	callq	install_bootable_layout.cold.74
.LBB3_429:
	callq	install_bootable_layout.cold.72
.LBB3_431:
	callq	install_bootable_layout.cold.70
.LBB3_433:
	callq	install_bootable_layout.cold.68
.LBB3_435:
	callq	install_bootable_layout.cold.66
.LBB3_436:
	callq	install_bootable_layout.cold.65
.LBB3_438:
	callq	install_bootable_layout.cold.63
.LBB3_440:
	callq	install_bootable_layout.cold.61
.LBB3_442:
	callq	install_bootable_layout.cold.59
.LBB3_444:
	callq	install_bootable_layout.cold.57
.LBB3_446:
	callq	install_bootable_layout.cold.55
.LBB3_448:
	callq	install_bootable_layout.cold.53
.LBB3_449:
	callq	install_bootable_layout.cold.52
.LBB3_451:
	callq	install_bootable_layout.cold.50
.LBB3_453:
	callq	install_bootable_layout.cold.48
.LBB3_455:
	callq	install_bootable_layout.cold.46
.LBB3_457:
	callq	install_bootable_layout.cold.44
.LBB3_459:
	callq	install_bootable_layout.cold.42
.LBB3_461:
	callq	install_bootable_layout.cold.40
.LBB3_462:
	callq	install_bootable_layout.cold.39
.LBB3_479:
	callq	install_bootable_layout.cold.22
.LBB3_214:
	callq	install_bootable_layout.cold.21
.LBB3_482:
	callq	install_bootable_layout.cold.20
.LBB3_480:
	callq	install_bootable_layout.cold.6
.LBB3_481:
	callq	install_bootable_layout.cold.5
.Lfunc_end3:
	.size	install_bootable_layout, .Lfunc_end3-install_bootable_layout
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_file
	.type	write_file,@function
write_file:                             # @write_file
	.cfi_startproc
# %bb.0:
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rdx, %r14
	movq	%rsi, %r12
	movq	%rdi, %rbx
	leaq	.L.str.230(%rip), %rsi
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
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	fclose@PLT                      # TAILCALL
.LBB4_4:
	.cfi_def_cfa_offset 48
	movq	%rbx, %rdi
	callq	write_file.cold.1
.LBB4_5:
	leaq	.L.str.231(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end4:
	.size	write_file, .Lfunc_end4-write_file
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function read_file
	.type	read_file,@function
read_file:                              # @read_file
	.cfi_startproc
# %bb.0:
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rdi, %rbx
	leaq	.L.str.24(%rip), %rsi
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
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.LBB5_9:
	.cfi_def_cfa_offset 48
	leaq	.L.str.25(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB5_8:
	movq	%rbx, %rdi
	callq	read_file.cold.2
.LBB5_10:
	leaq	.L.str.26(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB5_11:
	callq	read_file.cold.1
.LBB5_12:
	leaq	.L.str.27(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end5:
	.size	read_file, .Lfunc_end5-read_file
	.cfi_endproc
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function die_path
	.type	die_path,@function
die_path:                               # @die_path
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.28(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	.cfi_adjust_cfa_offset 8
	popq	%rdi
	.cfi_adjust_cfa_offset -8
	callq	exit@PLT
.Lfunc_end6:
	.size	die_path, .Lfunc_end6-die_path
	.cfi_endproc
                                        # -- End function
	.text
	.p2align	4                               # -- Begin function write_file_path
	.type	write_file_path,@function
write_file_path:                        # @write_file_path
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB7_14:
	.cfi_def_cfa_offset 80
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
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory
	.type	ensure_child_directory,@function
ensure_child_directory:                 # @ensure_child_directory
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB8_29:
	.cfi_def_cfa_offset 80
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
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain
	.type	write_cluster_chain,@function
write_cluster_chain:                    # @write_cluster_chain
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB9_26:
	.cfi_def_cfa_offset 96
	callq	write_cluster_chain.cold.2
.LBB9_25:
	callq	write_cluster_chain.cold.3
.LBB9_10:
	callq	write_cluster_chain.cold.1
.Lfunc_end9:
	.size	write_cluster_chain, .Lfunc_end9-write_cluster_chain
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function validate_image_layout
	.type	validate_image_layout,@function
validate_image_layout:                  # @validate_image_layout
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
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
	.cfi_def_cfa_offset 8
	retq
.LBB10_1:
	.cfi_def_cfa_offset 16
	leaq	.L.str.54(%rip), %rax
	jmp	.LBB10_2
.LBB10_4:
	leaq	.L.str.55(%rip), %rax
	jmp	.LBB10_2
.LBB10_7:
	leaq	.L.str.56(%rip), %rax
	jmp	.LBB10_2
.LBB10_9:
	leaq	.L.str.57(%rip), %rax
	jmp	.LBB10_2
.LBB10_11:
	leaq	.L.str.58(%rip), %rax
	jmp	.LBB10_2
.LBB10_13:
	leaq	.L.str.59(%rip), %rax
.LBB10_2:
	movq	%rsi, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end10:
	.size	validate_image_layout, .Lfunc_end10-validate_image_layout
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status
	.type	check_write_status,@function
check_write_status:                     # @check_write_status
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$16, %rsp
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB11_53:
	.cfi_def_cfa_offset 64
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
	leaq	.L.str.81(%rip), %rsi
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
	leaq	.L.str.84(%rip), %rsi
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
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	free@PLT                        # TAILCALL
.LBB11_13:
	.cfi_def_cfa_offset 64
	callq	check_write_status.cold.1
.LBB11_38:
	callq	check_write_status.cold.2
.LBB11_63:
	callq	check_write_status.cold.5
.LBB11_86:
	callq	check_write_status.cold.6
.LBB11_103:
	leaq	.L.str.82(%rip), %rsi
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
	leaq	.L.str.86(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.LBB11_108:
	leaq	.L.str.88(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end11:
	.size	check_write_status, .Lfunc_end11-check_write_status
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_dynamic_fat_status
	.type	check_dynamic_fat_status,@function
check_dynamic_fat_status:               # @check_dynamic_fat_status
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	leaq	.L.str.102(%rip), %r14
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB12_36:
	.cfi_def_cfa_offset 96
	movq	16(%rsp), %rax                  # 8-byte Reload
	jmp	.LBB12_41
.LBB12_22:
	callq	check_dynamic_fat_status.cold.1
.LBB12_43:
	callq	check_dynamic_fat_status.cold.2
.LBB12_44:
	leaq	.L.str.103(%rip), %rsi
	movq	%rbx, %rdi
	callq	die_path
.Lfunc_end12:
	.size	check_dynamic_fat_status, .Lfunc_end12-check_dynamic_fat_status
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function root_file_equal
	.type	root_file_equal,@function
root_file_equal:                        # @root_file_equal
	.cfi_startproc
# %bb.0:
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	subq	$32, %rsp
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
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
	leaq	.L.str.64(%rip), %rdx
	leaq	16(%rsp), %rax
	movq	%rsi, %r14
	movq	%rax, %rsi
	callq	read_root_file_blob
	movq	%rax, %rbx
	movq	%rdx, %r15
	leaq	.L.str.65(%rip), %rdx
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
	.cfi_def_cfa_offset 32
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end13:
	.size	root_file_equal, .Lfunc_end13-root_file_equal
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function read_root_file_blob
	.type	read_root_file_blob,@function
read_root_file_blob:                    # @read_root_file_blob
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	leaq	.L.str.68(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.LBB14_9:
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%r14, %rdx
	addq	$24, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB14_12:
	.cfi_def_cfa_offset 80
	leaq	.L.str.67(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.LBB14_10:
	callq	read_root_file_blob.cold.1
.LBB14_11:
	leaq	.L.str.66(%rip), %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	die_path
.Lfunc_end14:
	.size	read_root_file_blob, .Lfunc_end14-read_root_file_blob
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part
	.type	status_hex_tuple_part,@function
status_hex_tuple_part:                  # @status_hex_tuple_part
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
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
	.cfi_def_cfa_offset 8
	retq
	.p2align	4
.LBB15_36:                              # =>This Inner Loop Header: Depth=1
	.cfi_def_cfa_offset 16
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
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function status_find_field
	.type	status_find_field,@function
status_find_field:                      # @status_find_field
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	pushq	%rax
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB16_8:
	.cfi_def_cfa_offset 64
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
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83
	.type	parse_path83,@function
parse_path83:                           # @parse_path83
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$88, %rsp
	.cfi_def_cfa_offset 144
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB17_22:
	.cfi_def_cfa_offset 144
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
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component
	.type	fat83_from_display_component,@function
fat83_from_display_component:           # @fat83_from_display_component
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	pushq	%rax
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
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
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB18_18:
	.cfi_def_cfa_offset 64
	callq	fat83_from_display_component.cold.4
.Lfunc_end18:
	.size	fat83_from_display_component, .Lfunc_end18-fat83_from_display_component
	.cfi_endproc
                                        # -- End function
	.section	.text.unlikely.,"ax",@progbits
	.p2align	4                               # -- Begin function main.cold.1
	.type	main.cold.1,@function
main.cold.1:                            # @main.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end19:
	.size	main.cold.1, .Lfunc_end19-main.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.2
	.type	main.cold.2,@function
main.cold.2:                            # @main.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end20:
	.size	main.cold.2, .Lfunc_end20-main.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.3
	.type	main.cold.3,@function
main.cold.3:                            # @main.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.123(%rip), %rdi
	callq	die
.Lfunc_end21:
	.size	main.cold.3, .Lfunc_end21-main.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.4
	.type	main.cold.4,@function
main.cold.4:                            # @main.cold.4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.122(%rip), %rdi
	callq	die
.Lfunc_end22:
	.size	main.cold.4, .Lfunc_end22-main.cold.4
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.5
	.type	main.cold.5,@function
main.cold.5:                            # @main.cold.5
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end23:
	.size	main.cold.5, .Lfunc_end23-main.cold.5
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.6
	.type	main.cold.6,@function
main.cold.6:                            # @main.cold.6
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end24:
	.size	main.cold.6, .Lfunc_end24-main.cold.6
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.7
	.type	main.cold.7,@function
main.cold.7:                            # @main.cold.7
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.106(%rip), %rdi
	callq	die
.Lfunc_end25:
	.size	main.cold.7, .Lfunc_end25-main.cold.7
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.8
	.type	main.cold.8,@function
main.cold.8:                            # @main.cold.8
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.108(%rip), %rdi
	callq	die
.Lfunc_end26:
	.size	main.cold.8, .Lfunc_end26-main.cold.8
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.9
	.type	main.cold.9,@function
main.cold.9:                            # @main.cold.9
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.18(%rip), %rdi
	callq	die
.Lfunc_end27:
	.size	main.cold.9, .Lfunc_end27-main.cold.9
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.10
	.type	main.cold.10,@function
main.cold.10:                           # @main.cold.10
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.120(%rip), %rdi
	callq	die
.Lfunc_end28:
	.size	main.cold.10, .Lfunc_end28-main.cold.10
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.11
	.type	main.cold.11,@function
main.cold.11:                           # @main.cold.11
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.105(%rip), %rdi
	callq	die
.Lfunc_end29:
	.size	main.cold.11, .Lfunc_end29-main.cold.11
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.12
	.type	main.cold.12,@function
main.cold.12:                           # @main.cold.12
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.104(%rip), %rdi
	callq	die
.Lfunc_end30:
	.size	main.cold.12, .Lfunc_end30-main.cold.12
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.13
	.type	main.cold.13,@function
main.cold.13:                           # @main.cold.13
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end31:
	.size	main.cold.13, .Lfunc_end31-main.cold.13
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.14
	.type	main.cold.14,@function
main.cold.14:                           # @main.cold.14
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end32:
	.size	main.cold.14, .Lfunc_end32-main.cold.14
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.15
	.type	main.cold.15,@function
main.cold.15:                           # @main.cold.15
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end33:
	.size	main.cold.15, .Lfunc_end33-main.cold.15
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.16
	.type	main.cold.16,@function
main.cold.16:                           # @main.cold.16
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end34:
	.size	main.cold.16, .Lfunc_end34-main.cold.16
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.17
	.type	main.cold.17,@function
main.cold.17:                           # @main.cold.17
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.20(%rip), %rdi
	callq	die
.Lfunc_end35:
	.size	main.cold.17, .Lfunc_end35-main.cold.17
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.18
	.type	main.cold.18,@function
main.cold.18:                           # @main.cold.18
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.21(%rip), %rdi
	callq	die
.Lfunc_end36:
	.size	main.cold.18, .Lfunc_end36-main.cold.18
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.19
	.type	main.cold.19,@function
main.cold.19:                           # @main.cold.19
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end37:
	.size	main.cold.19, .Lfunc_end37-main.cold.19
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.20
	.type	main.cold.20,@function
main.cold.20:                           # @main.cold.20
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.42(%rip), %rdi
	callq	die
.Lfunc_end38:
	.size	main.cold.20, .Lfunc_end38-main.cold.20
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.21
	.type	main.cold.21,@function
main.cold.21:                           # @main.cold.21
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.60(%rip), %rdi
	callq	die
.Lfunc_end39:
	.size	main.cold.21, .Lfunc_end39-main.cold.21
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.22
	.type	main.cold.22,@function
main.cold.22:                           # @main.cold.22
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.61(%rip), %rdi
	callq	die
.Lfunc_end40:
	.size	main.cold.22, .Lfunc_end40-main.cold.22
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.23
	.type	main.cold.23,@function
main.cold.23:                           # @main.cold.23
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.63(%rip), %rdi
	callq	die
.Lfunc_end41:
	.size	main.cold.23, .Lfunc_end41-main.cold.23
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.24
	.type	main.cold.24,@function
main.cold.24:                           # @main.cold.24
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.62(%rip), %rdi
	callq	die
.Lfunc_end42:
	.size	main.cold.24, .Lfunc_end42-main.cold.24
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.25
	.type	main.cold.25,@function
main.cold.25:                           # @main.cold.25
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.70(%rip), %rdi
	callq	die
.Lfunc_end43:
	.size	main.cold.25, .Lfunc_end43-main.cold.25
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.26
	.type	main.cold.26,@function
main.cold.26:                           # @main.cold.26
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.71(%rip), %rdi
	callq	die
.Lfunc_end44:
	.size	main.cold.26, .Lfunc_end44-main.cold.26
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.27
	.type	main.cold.27,@function
main.cold.27:                           # @main.cold.27
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.73(%rip), %rdi
	callq	die
.Lfunc_end45:
	.size	main.cold.27, .Lfunc_end45-main.cold.27
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.28
	.type	main.cold.28,@function
main.cold.28:                           # @main.cold.28
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.74(%rip), %rdi
	callq	die
.Lfunc_end46:
	.size	main.cold.28, .Lfunc_end46-main.cold.28
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.29
	.type	main.cold.29,@function
main.cold.29:                           # @main.cold.29
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.77(%rip), %rdi
	callq	die
.Lfunc_end47:
	.size	main.cold.29, .Lfunc_end47-main.cold.29
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.30
	.type	main.cold.30,@function
main.cold.30:                           # @main.cold.30
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.76(%rip), %rdi
	callq	die
.Lfunc_end48:
	.size	main.cold.30, .Lfunc_end48-main.cold.30
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.31
	.type	main.cold.31,@function
main.cold.31:                           # @main.cold.31
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.79(%rip), %rdi
	callq	die
.Lfunc_end49:
	.size	main.cold.31, .Lfunc_end49-main.cold.31
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.32
	.type	main.cold.32,@function
main.cold.32:                           # @main.cold.32
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.72(%rip), %rdi
	callq	die
.Lfunc_end50:
	.size	main.cold.32, .Lfunc_end50-main.cold.32
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.33
	.type	main.cold.33,@function
main.cold.33:                           # @main.cold.33
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.80(%rip), %rdi
	callq	die
.Lfunc_end51:
	.size	main.cold.33, .Lfunc_end51-main.cold.33
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.34
	.type	main.cold.34,@function
main.cold.34:                           # @main.cold.34
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.89(%rip), %rdi
	callq	die
.Lfunc_end52:
	.size	main.cold.34, .Lfunc_end52-main.cold.34
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.35
	.type	main.cold.35,@function
main.cold.35:                           # @main.cold.35
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.91(%rip), %rdi
	callq	die
.Lfunc_end53:
	.size	main.cold.35, .Lfunc_end53-main.cold.35
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.36
	.type	main.cold.36,@function
main.cold.36:                           # @main.cold.36
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.46(%rip), %rdi
	callq	die
.Lfunc_end54:
	.size	main.cold.36, .Lfunc_end54-main.cold.36
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.37
	.type	main.cold.37,@function
main.cold.37:                           # @main.cold.37
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end55:
	.size	main.cold.37, .Lfunc_end55-main.cold.37
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker.cold.1
	.type	mutate_root_marker.cold.1,@function
mutate_root_marker.cold.1:              # @mutate_root_marker.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.33(%rip), %rdi
	callq	die
.Lfunc_end56:
	.size	mutate_root_marker.cold.1, .Lfunc_end56-mutate_root_marker.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker.cold.2
	.type	mutate_root_marker.cold.2,@function
mutate_root_marker.cold.2:              # @mutate_root_marker.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.34(%rip), %rdi
	callq	die
.Lfunc_end57:
	.size	mutate_root_marker.cold.2, .Lfunc_end57-mutate_root_marker.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function mutate_root_marker.cold.3
	.type	mutate_root_marker.cold.3,@function
mutate_root_marker.cold.3:              # @mutate_root_marker.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end58:
	.size	mutate_root_marker.cold.3, .Lfunc_end58-mutate_root_marker.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.1
	.type	install_bootable_layout.cold.1,@function
install_bootable_layout.cold.1:         # @install_bootable_layout.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.132(%rip), %rdi
	callq	die
.Lfunc_end59:
	.size	install_bootable_layout.cold.1, .Lfunc_end59-install_bootable_layout.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.2
	.type	install_bootable_layout.cold.2,@function
install_bootable_layout.cold.2:         # @install_bootable_layout.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.133(%rip), %rdi
	callq	die
.Lfunc_end60:
	.size	install_bootable_layout.cold.2, .Lfunc_end60-install_bootable_layout.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.3
	.type	install_bootable_layout.cold.3,@function
install_bootable_layout.cold.3:         # @install_bootable_layout.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.140(%rip), %rsi
	leaq	.L.str.138(%rip), %rdx
	movl	$163840, %r8d                   # imm = 0x28000
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	.cfi_adjust_cfa_offset 8
	popq	%rdi
	.cfi_adjust_cfa_offset -8
	callq	exit@PLT
.Lfunc_end61:
	.size	install_bootable_layout.cold.3, .Lfunc_end61-install_bootable_layout.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.4
	.type	install_bootable_layout.cold.4,@function
install_bootable_layout.cold.4:         # @install_bootable_layout.cold.4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, %rcx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.140(%rip), %rsi
	leaq	.L.str.137(%rip), %rdx
	movl	$8192, %r8d                     # imm = 0x2000
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	.cfi_adjust_cfa_offset 8
	popq	%rdi
	.cfi_adjust_cfa_offset -8
	callq	exit@PLT
.Lfunc_end62:
	.size	install_bootable_layout.cold.4, .Lfunc_end62-install_bootable_layout.cold.4
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.5
	.type	install_bootable_layout.cold.5,@function
install_bootable_layout.cold.5:         # @install_bootable_layout.cold.5
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end63:
	.size	install_bootable_layout.cold.5, .Lfunc_end63-install_bootable_layout.cold.5
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.6
	.type	install_bootable_layout.cold.6,@function
install_bootable_layout.cold.6:         # @install_bootable_layout.cold.6
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end64:
	.size	install_bootable_layout.cold.6, .Lfunc_end64-install_bootable_layout.cold.6
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.7
	.type	install_bootable_layout.cold.7,@function
install_bootable_layout.cold.7:         # @install_bootable_layout.cold.7
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.134(%rip), %rdi
	callq	die
.Lfunc_end65:
	.size	install_bootable_layout.cold.7, .Lfunc_end65-install_bootable_layout.cold.7
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.8
	.type	install_bootable_layout.cold.8,@function
install_bootable_layout.cold.8:         # @install_bootable_layout.cold.8
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.229(%rip), %rdi
	callq	die
.Lfunc_end66:
	.size	install_bootable_layout.cold.8, .Lfunc_end66-install_bootable_layout.cold.8
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.9
	.type	install_bootable_layout.cold.9,@function
install_bootable_layout.cold.9:         # @install_bootable_layout.cold.9
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.135(%rip), %rdi
	callq	die
.Lfunc_end67:
	.size	install_bootable_layout.cold.9, .Lfunc_end67-install_bootable_layout.cold.9
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.10
	.type	install_bootable_layout.cold.10,@function
install_bootable_layout.cold.10:        # @install_bootable_layout.cold.10
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end68:
	.size	install_bootable_layout.cold.10, .Lfunc_end68-install_bootable_layout.cold.10
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.11
	.type	install_bootable_layout.cold.11,@function
install_bootable_layout.cold.11:        # @install_bootable_layout.cold.11
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.225(%rip), %rdi
	callq	die
.Lfunc_end69:
	.size	install_bootable_layout.cold.11, .Lfunc_end69-install_bootable_layout.cold.11
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.12
	.type	install_bootable_layout.cold.12,@function
install_bootable_layout.cold.12:        # @install_bootable_layout.cold.12
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end70:
	.size	install_bootable_layout.cold.12, .Lfunc_end70-install_bootable_layout.cold.12
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.13
	.type	install_bootable_layout.cold.13,@function
install_bootable_layout.cold.13:        # @install_bootable_layout.cold.13
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.225(%rip), %rdi
	callq	die
.Lfunc_end71:
	.size	install_bootable_layout.cold.13, .Lfunc_end71-install_bootable_layout.cold.13
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.14
	.type	install_bootable_layout.cold.14,@function
install_bootable_layout.cold.14:        # @install_bootable_layout.cold.14
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end72:
	.size	install_bootable_layout.cold.14, .Lfunc_end72-install_bootable_layout.cold.14
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.15
	.type	install_bootable_layout.cold.15,@function
install_bootable_layout.cold.15:        # @install_bootable_layout.cold.15
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.225(%rip), %rdi
	callq	die
.Lfunc_end73:
	.size	install_bootable_layout.cold.15, .Lfunc_end73-install_bootable_layout.cold.15
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.16
	.type	install_bootable_layout.cold.16,@function
install_bootable_layout.cold.16:        # @install_bootable_layout.cold.16
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end74:
	.size	install_bootable_layout.cold.16, .Lfunc_end74-install_bootable_layout.cold.16
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.17
	.type	install_bootable_layout.cold.17,@function
install_bootable_layout.cold.17:        # @install_bootable_layout.cold.17
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.225(%rip), %rdi
	callq	die
.Lfunc_end75:
	.size	install_bootable_layout.cold.17, .Lfunc_end75-install_bootable_layout.cold.17
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.18
	.type	install_bootable_layout.cold.18,@function
install_bootable_layout.cold.18:        # @install_bootable_layout.cold.18
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end76:
	.size	install_bootable_layout.cold.18, .Lfunc_end76-install_bootable_layout.cold.18
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.19
	.type	install_bootable_layout.cold.19,@function
install_bootable_layout.cold.19:        # @install_bootable_layout.cold.19
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.225(%rip), %rdi
	callq	die
.Lfunc_end77:
	.size	install_bootable_layout.cold.19, .Lfunc_end77-install_bootable_layout.cold.19
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.20
	.type	install_bootable_layout.cold.20,@function
install_bootable_layout.cold.20:        # @install_bootable_layout.cold.20
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end78:
	.size	install_bootable_layout.cold.20, .Lfunc_end78-install_bootable_layout.cold.20
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.21
	.type	install_bootable_layout.cold.21,@function
install_bootable_layout.cold.21:        # @install_bootable_layout.cold.21
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end79:
	.size	install_bootable_layout.cold.21, .Lfunc_end79-install_bootable_layout.cold.21
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.22
	.type	install_bootable_layout.cold.22,@function
install_bootable_layout.cold.22:        # @install_bootable_layout.cold.22
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end80:
	.size	install_bootable_layout.cold.22, .Lfunc_end80-install_bootable_layout.cold.22
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.23
	.type	install_bootable_layout.cold.23,@function
install_bootable_layout.cold.23:        # @install_bootable_layout.cold.23
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end81:
	.size	install_bootable_layout.cold.23, .Lfunc_end81-install_bootable_layout.cold.23
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.24
	.type	install_bootable_layout.cold.24,@function
install_bootable_layout.cold.24:        # @install_bootable_layout.cold.24
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end82:
	.size	install_bootable_layout.cold.24, .Lfunc_end82-install_bootable_layout.cold.24
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.25
	.type	install_bootable_layout.cold.25,@function
install_bootable_layout.cold.25:        # @install_bootable_layout.cold.25
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end83:
	.size	install_bootable_layout.cold.25, .Lfunc_end83-install_bootable_layout.cold.25
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.26
	.type	install_bootable_layout.cold.26,@function
install_bootable_layout.cold.26:        # @install_bootable_layout.cold.26
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end84:
	.size	install_bootable_layout.cold.26, .Lfunc_end84-install_bootable_layout.cold.26
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.27
	.type	install_bootable_layout.cold.27,@function
install_bootable_layout.cold.27:        # @install_bootable_layout.cold.27
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end85:
	.size	install_bootable_layout.cold.27, .Lfunc_end85-install_bootable_layout.cold.27
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.28
	.type	install_bootable_layout.cold.28,@function
install_bootable_layout.cold.28:        # @install_bootable_layout.cold.28
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end86:
	.size	install_bootable_layout.cold.28, .Lfunc_end86-install_bootable_layout.cold.28
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.29
	.type	install_bootable_layout.cold.29,@function
install_bootable_layout.cold.29:        # @install_bootable_layout.cold.29
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end87:
	.size	install_bootable_layout.cold.29, .Lfunc_end87-install_bootable_layout.cold.29
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.30
	.type	install_bootable_layout.cold.30,@function
install_bootable_layout.cold.30:        # @install_bootable_layout.cold.30
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end88:
	.size	install_bootable_layout.cold.30, .Lfunc_end88-install_bootable_layout.cold.30
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.31
	.type	install_bootable_layout.cold.31,@function
install_bootable_layout.cold.31:        # @install_bootable_layout.cold.31
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end89:
	.size	install_bootable_layout.cold.31, .Lfunc_end89-install_bootable_layout.cold.31
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.32
	.type	install_bootable_layout.cold.32,@function
install_bootable_layout.cold.32:        # @install_bootable_layout.cold.32
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end90:
	.size	install_bootable_layout.cold.32, .Lfunc_end90-install_bootable_layout.cold.32
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.33
	.type	install_bootable_layout.cold.33,@function
install_bootable_layout.cold.33:        # @install_bootable_layout.cold.33
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end91:
	.size	install_bootable_layout.cold.33, .Lfunc_end91-install_bootable_layout.cold.33
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.34
	.type	install_bootable_layout.cold.34,@function
install_bootable_layout.cold.34:        # @install_bootable_layout.cold.34
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end92:
	.size	install_bootable_layout.cold.34, .Lfunc_end92-install_bootable_layout.cold.34
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.35
	.type	install_bootable_layout.cold.35,@function
install_bootable_layout.cold.35:        # @install_bootable_layout.cold.35
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end93:
	.size	install_bootable_layout.cold.35, .Lfunc_end93-install_bootable_layout.cold.35
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.36
	.type	install_bootable_layout.cold.36,@function
install_bootable_layout.cold.36:        # @install_bootable_layout.cold.36
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end94:
	.size	install_bootable_layout.cold.36, .Lfunc_end94-install_bootable_layout.cold.36
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.37
	.type	install_bootable_layout.cold.37,@function
install_bootable_layout.cold.37:        # @install_bootable_layout.cold.37
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end95:
	.size	install_bootable_layout.cold.37, .Lfunc_end95-install_bootable_layout.cold.37
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.38
	.type	install_bootable_layout.cold.38,@function
install_bootable_layout.cold.38:        # @install_bootable_layout.cold.38
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end96:
	.size	install_bootable_layout.cold.38, .Lfunc_end96-install_bootable_layout.cold.38
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.39
	.type	install_bootable_layout.cold.39,@function
install_bootable_layout.cold.39:        # @install_bootable_layout.cold.39
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end97:
	.size	install_bootable_layout.cold.39, .Lfunc_end97-install_bootable_layout.cold.39
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.40
	.type	install_bootable_layout.cold.40,@function
install_bootable_layout.cold.40:        # @install_bootable_layout.cold.40
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end98:
	.size	install_bootable_layout.cold.40, .Lfunc_end98-install_bootable_layout.cold.40
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.41
	.type	install_bootable_layout.cold.41,@function
install_bootable_layout.cold.41:        # @install_bootable_layout.cold.41
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end99:
	.size	install_bootable_layout.cold.41, .Lfunc_end99-install_bootable_layout.cold.41
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.42
	.type	install_bootable_layout.cold.42,@function
install_bootable_layout.cold.42:        # @install_bootable_layout.cold.42
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end100:
	.size	install_bootable_layout.cold.42, .Lfunc_end100-install_bootable_layout.cold.42
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.43
	.type	install_bootable_layout.cold.43,@function
install_bootable_layout.cold.43:        # @install_bootable_layout.cold.43
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end101:
	.size	install_bootable_layout.cold.43, .Lfunc_end101-install_bootable_layout.cold.43
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.44
	.type	install_bootable_layout.cold.44,@function
install_bootable_layout.cold.44:        # @install_bootable_layout.cold.44
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end102:
	.size	install_bootable_layout.cold.44, .Lfunc_end102-install_bootable_layout.cold.44
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.45
	.type	install_bootable_layout.cold.45,@function
install_bootable_layout.cold.45:        # @install_bootable_layout.cold.45
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end103:
	.size	install_bootable_layout.cold.45, .Lfunc_end103-install_bootable_layout.cold.45
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.46
	.type	install_bootable_layout.cold.46,@function
install_bootable_layout.cold.46:        # @install_bootable_layout.cold.46
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end104:
	.size	install_bootable_layout.cold.46, .Lfunc_end104-install_bootable_layout.cold.46
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.47
	.type	install_bootable_layout.cold.47,@function
install_bootable_layout.cold.47:        # @install_bootable_layout.cold.47
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end105:
	.size	install_bootable_layout.cold.47, .Lfunc_end105-install_bootable_layout.cold.47
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.48
	.type	install_bootable_layout.cold.48,@function
install_bootable_layout.cold.48:        # @install_bootable_layout.cold.48
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end106:
	.size	install_bootable_layout.cold.48, .Lfunc_end106-install_bootable_layout.cold.48
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.49
	.type	install_bootable_layout.cold.49,@function
install_bootable_layout.cold.49:        # @install_bootable_layout.cold.49
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end107:
	.size	install_bootable_layout.cold.49, .Lfunc_end107-install_bootable_layout.cold.49
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.50
	.type	install_bootable_layout.cold.50,@function
install_bootable_layout.cold.50:        # @install_bootable_layout.cold.50
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end108:
	.size	install_bootable_layout.cold.50, .Lfunc_end108-install_bootable_layout.cold.50
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.51
	.type	install_bootable_layout.cold.51,@function
install_bootable_layout.cold.51:        # @install_bootable_layout.cold.51
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end109:
	.size	install_bootable_layout.cold.51, .Lfunc_end109-install_bootable_layout.cold.51
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.52
	.type	install_bootable_layout.cold.52,@function
install_bootable_layout.cold.52:        # @install_bootable_layout.cold.52
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end110:
	.size	install_bootable_layout.cold.52, .Lfunc_end110-install_bootable_layout.cold.52
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.53
	.type	install_bootable_layout.cold.53,@function
install_bootable_layout.cold.53:        # @install_bootable_layout.cold.53
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end111:
	.size	install_bootable_layout.cold.53, .Lfunc_end111-install_bootable_layout.cold.53
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.54
	.type	install_bootable_layout.cold.54,@function
install_bootable_layout.cold.54:        # @install_bootable_layout.cold.54
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end112:
	.size	install_bootable_layout.cold.54, .Lfunc_end112-install_bootable_layout.cold.54
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.55
	.type	install_bootable_layout.cold.55,@function
install_bootable_layout.cold.55:        # @install_bootable_layout.cold.55
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end113:
	.size	install_bootable_layout.cold.55, .Lfunc_end113-install_bootable_layout.cold.55
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.56
	.type	install_bootable_layout.cold.56,@function
install_bootable_layout.cold.56:        # @install_bootable_layout.cold.56
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end114:
	.size	install_bootable_layout.cold.56, .Lfunc_end114-install_bootable_layout.cold.56
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.57
	.type	install_bootable_layout.cold.57,@function
install_bootable_layout.cold.57:        # @install_bootable_layout.cold.57
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end115:
	.size	install_bootable_layout.cold.57, .Lfunc_end115-install_bootable_layout.cold.57
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.58
	.type	install_bootable_layout.cold.58,@function
install_bootable_layout.cold.58:        # @install_bootable_layout.cold.58
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end116:
	.size	install_bootable_layout.cold.58, .Lfunc_end116-install_bootable_layout.cold.58
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.59
	.type	install_bootable_layout.cold.59,@function
install_bootable_layout.cold.59:        # @install_bootable_layout.cold.59
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end117:
	.size	install_bootable_layout.cold.59, .Lfunc_end117-install_bootable_layout.cold.59
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.60
	.type	install_bootable_layout.cold.60,@function
install_bootable_layout.cold.60:        # @install_bootable_layout.cold.60
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end118:
	.size	install_bootable_layout.cold.60, .Lfunc_end118-install_bootable_layout.cold.60
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.61
	.type	install_bootable_layout.cold.61,@function
install_bootable_layout.cold.61:        # @install_bootable_layout.cold.61
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end119:
	.size	install_bootable_layout.cold.61, .Lfunc_end119-install_bootable_layout.cold.61
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.62
	.type	install_bootable_layout.cold.62,@function
install_bootable_layout.cold.62:        # @install_bootable_layout.cold.62
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end120:
	.size	install_bootable_layout.cold.62, .Lfunc_end120-install_bootable_layout.cold.62
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.63
	.type	install_bootable_layout.cold.63,@function
install_bootable_layout.cold.63:        # @install_bootable_layout.cold.63
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end121:
	.size	install_bootable_layout.cold.63, .Lfunc_end121-install_bootable_layout.cold.63
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.64
	.type	install_bootable_layout.cold.64,@function
install_bootable_layout.cold.64:        # @install_bootable_layout.cold.64
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end122:
	.size	install_bootable_layout.cold.64, .Lfunc_end122-install_bootable_layout.cold.64
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.65
	.type	install_bootable_layout.cold.65,@function
install_bootable_layout.cold.65:        # @install_bootable_layout.cold.65
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end123:
	.size	install_bootable_layout.cold.65, .Lfunc_end123-install_bootable_layout.cold.65
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.66
	.type	install_bootable_layout.cold.66,@function
install_bootable_layout.cold.66:        # @install_bootable_layout.cold.66
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end124:
	.size	install_bootable_layout.cold.66, .Lfunc_end124-install_bootable_layout.cold.66
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.67
	.type	install_bootable_layout.cold.67,@function
install_bootable_layout.cold.67:        # @install_bootable_layout.cold.67
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end125:
	.size	install_bootable_layout.cold.67, .Lfunc_end125-install_bootable_layout.cold.67
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.68
	.type	install_bootable_layout.cold.68,@function
install_bootable_layout.cold.68:        # @install_bootable_layout.cold.68
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end126:
	.size	install_bootable_layout.cold.68, .Lfunc_end126-install_bootable_layout.cold.68
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.69
	.type	install_bootable_layout.cold.69,@function
install_bootable_layout.cold.69:        # @install_bootable_layout.cold.69
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end127:
	.size	install_bootable_layout.cold.69, .Lfunc_end127-install_bootable_layout.cold.69
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.70
	.type	install_bootable_layout.cold.70,@function
install_bootable_layout.cold.70:        # @install_bootable_layout.cold.70
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end128:
	.size	install_bootable_layout.cold.70, .Lfunc_end128-install_bootable_layout.cold.70
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.71
	.type	install_bootable_layout.cold.71,@function
install_bootable_layout.cold.71:        # @install_bootable_layout.cold.71
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end129:
	.size	install_bootable_layout.cold.71, .Lfunc_end129-install_bootable_layout.cold.71
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.72
	.type	install_bootable_layout.cold.72,@function
install_bootable_layout.cold.72:        # @install_bootable_layout.cold.72
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end130:
	.size	install_bootable_layout.cold.72, .Lfunc_end130-install_bootable_layout.cold.72
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.73
	.type	install_bootable_layout.cold.73,@function
install_bootable_layout.cold.73:        # @install_bootable_layout.cold.73
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end131:
	.size	install_bootable_layout.cold.73, .Lfunc_end131-install_bootable_layout.cold.73
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.74
	.type	install_bootable_layout.cold.74,@function
install_bootable_layout.cold.74:        # @install_bootable_layout.cold.74
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end132:
	.size	install_bootable_layout.cold.74, .Lfunc_end132-install_bootable_layout.cold.74
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.75
	.type	install_bootable_layout.cold.75,@function
install_bootable_layout.cold.75:        # @install_bootable_layout.cold.75
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end133:
	.size	install_bootable_layout.cold.75, .Lfunc_end133-install_bootable_layout.cold.75
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.76
	.type	install_bootable_layout.cold.76,@function
install_bootable_layout.cold.76:        # @install_bootable_layout.cold.76
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end134:
	.size	install_bootable_layout.cold.76, .Lfunc_end134-install_bootable_layout.cold.76
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.77
	.type	install_bootable_layout.cold.77,@function
install_bootable_layout.cold.77:        # @install_bootable_layout.cold.77
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end135:
	.size	install_bootable_layout.cold.77, .Lfunc_end135-install_bootable_layout.cold.77
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.78
	.type	install_bootable_layout.cold.78,@function
install_bootable_layout.cold.78:        # @install_bootable_layout.cold.78
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end136:
	.size	install_bootable_layout.cold.78, .Lfunc_end136-install_bootable_layout.cold.78
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.79
	.type	install_bootable_layout.cold.79,@function
install_bootable_layout.cold.79:        # @install_bootable_layout.cold.79
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end137:
	.size	install_bootable_layout.cold.79, .Lfunc_end137-install_bootable_layout.cold.79
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.80
	.type	install_bootable_layout.cold.80,@function
install_bootable_layout.cold.80:        # @install_bootable_layout.cold.80
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end138:
	.size	install_bootable_layout.cold.80, .Lfunc_end138-install_bootable_layout.cold.80
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.81
	.type	install_bootable_layout.cold.81,@function
install_bootable_layout.cold.81:        # @install_bootable_layout.cold.81
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end139:
	.size	install_bootable_layout.cold.81, .Lfunc_end139-install_bootable_layout.cold.81
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.82
	.type	install_bootable_layout.cold.82,@function
install_bootable_layout.cold.82:        # @install_bootable_layout.cold.82
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end140:
	.size	install_bootable_layout.cold.82, .Lfunc_end140-install_bootable_layout.cold.82
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.83
	.type	install_bootable_layout.cold.83,@function
install_bootable_layout.cold.83:        # @install_bootable_layout.cold.83
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end141:
	.size	install_bootable_layout.cold.83, .Lfunc_end141-install_bootable_layout.cold.83
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.84
	.type	install_bootable_layout.cold.84,@function
install_bootable_layout.cold.84:        # @install_bootable_layout.cold.84
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end142:
	.size	install_bootable_layout.cold.84, .Lfunc_end142-install_bootable_layout.cold.84
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.85
	.type	install_bootable_layout.cold.85,@function
install_bootable_layout.cold.85:        # @install_bootable_layout.cold.85
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end143:
	.size	install_bootable_layout.cold.85, .Lfunc_end143-install_bootable_layout.cold.85
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.86
	.type	install_bootable_layout.cold.86,@function
install_bootable_layout.cold.86:        # @install_bootable_layout.cold.86
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end144:
	.size	install_bootable_layout.cold.86, .Lfunc_end144-install_bootable_layout.cold.86
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.87
	.type	install_bootable_layout.cold.87,@function
install_bootable_layout.cold.87:        # @install_bootable_layout.cold.87
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end145:
	.size	install_bootable_layout.cold.87, .Lfunc_end145-install_bootable_layout.cold.87
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.88
	.type	install_bootable_layout.cold.88,@function
install_bootable_layout.cold.88:        # @install_bootable_layout.cold.88
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end146:
	.size	install_bootable_layout.cold.88, .Lfunc_end146-install_bootable_layout.cold.88
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.89
	.type	install_bootable_layout.cold.89,@function
install_bootable_layout.cold.89:        # @install_bootable_layout.cold.89
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end147:
	.size	install_bootable_layout.cold.89, .Lfunc_end147-install_bootable_layout.cold.89
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.90
	.type	install_bootable_layout.cold.90,@function
install_bootable_layout.cold.90:        # @install_bootable_layout.cold.90
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end148:
	.size	install_bootable_layout.cold.90, .Lfunc_end148-install_bootable_layout.cold.90
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.91
	.type	install_bootable_layout.cold.91,@function
install_bootable_layout.cold.91:        # @install_bootable_layout.cold.91
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end149:
	.size	install_bootable_layout.cold.91, .Lfunc_end149-install_bootable_layout.cold.91
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.92
	.type	install_bootable_layout.cold.92,@function
install_bootable_layout.cold.92:        # @install_bootable_layout.cold.92
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end150:
	.size	install_bootable_layout.cold.92, .Lfunc_end150-install_bootable_layout.cold.92
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.93
	.type	install_bootable_layout.cold.93,@function
install_bootable_layout.cold.93:        # @install_bootable_layout.cold.93
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end151:
	.size	install_bootable_layout.cold.93, .Lfunc_end151-install_bootable_layout.cold.93
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.94
	.type	install_bootable_layout.cold.94,@function
install_bootable_layout.cold.94:        # @install_bootable_layout.cold.94
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end152:
	.size	install_bootable_layout.cold.94, .Lfunc_end152-install_bootable_layout.cold.94
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.95
	.type	install_bootable_layout.cold.95,@function
install_bootable_layout.cold.95:        # @install_bootable_layout.cold.95
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end153:
	.size	install_bootable_layout.cold.95, .Lfunc_end153-install_bootable_layout.cold.95
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.96
	.type	install_bootable_layout.cold.96,@function
install_bootable_layout.cold.96:        # @install_bootable_layout.cold.96
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end154:
	.size	install_bootable_layout.cold.96, .Lfunc_end154-install_bootable_layout.cold.96
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.97
	.type	install_bootable_layout.cold.97,@function
install_bootable_layout.cold.97:        # @install_bootable_layout.cold.97
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end155:
	.size	install_bootable_layout.cold.97, .Lfunc_end155-install_bootable_layout.cold.97
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.98
	.type	install_bootable_layout.cold.98,@function
install_bootable_layout.cold.98:        # @install_bootable_layout.cold.98
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end156:
	.size	install_bootable_layout.cold.98, .Lfunc_end156-install_bootable_layout.cold.98
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.99
	.type	install_bootable_layout.cold.99,@function
install_bootable_layout.cold.99:        # @install_bootable_layout.cold.99
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end157:
	.size	install_bootable_layout.cold.99, .Lfunc_end157-install_bootable_layout.cold.99
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.100
	.type	install_bootable_layout.cold.100,@function
install_bootable_layout.cold.100:       # @install_bootable_layout.cold.100
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end158:
	.size	install_bootable_layout.cold.100, .Lfunc_end158-install_bootable_layout.cold.100
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.101
	.type	install_bootable_layout.cold.101,@function
install_bootable_layout.cold.101:       # @install_bootable_layout.cold.101
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end159:
	.size	install_bootable_layout.cold.101, .Lfunc_end159-install_bootable_layout.cold.101
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.102
	.type	install_bootable_layout.cold.102,@function
install_bootable_layout.cold.102:       # @install_bootable_layout.cold.102
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end160:
	.size	install_bootable_layout.cold.102, .Lfunc_end160-install_bootable_layout.cold.102
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.103
	.type	install_bootable_layout.cold.103,@function
install_bootable_layout.cold.103:       # @install_bootable_layout.cold.103
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end161:
	.size	install_bootable_layout.cold.103, .Lfunc_end161-install_bootable_layout.cold.103
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.104
	.type	install_bootable_layout.cold.104,@function
install_bootable_layout.cold.104:       # @install_bootable_layout.cold.104
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end162:
	.size	install_bootable_layout.cold.104, .Lfunc_end162-install_bootable_layout.cold.104
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.105
	.type	install_bootable_layout.cold.105,@function
install_bootable_layout.cold.105:       # @install_bootable_layout.cold.105
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end163:
	.size	install_bootable_layout.cold.105, .Lfunc_end163-install_bootable_layout.cold.105
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.106
	.type	install_bootable_layout.cold.106,@function
install_bootable_layout.cold.106:       # @install_bootable_layout.cold.106
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end164:
	.size	install_bootable_layout.cold.106, .Lfunc_end164-install_bootable_layout.cold.106
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.107
	.type	install_bootable_layout.cold.107,@function
install_bootable_layout.cold.107:       # @install_bootable_layout.cold.107
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end165:
	.size	install_bootable_layout.cold.107, .Lfunc_end165-install_bootable_layout.cold.107
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.108
	.type	install_bootable_layout.cold.108,@function
install_bootable_layout.cold.108:       # @install_bootable_layout.cold.108
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end166:
	.size	install_bootable_layout.cold.108, .Lfunc_end166-install_bootable_layout.cold.108
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.109
	.type	install_bootable_layout.cold.109,@function
install_bootable_layout.cold.109:       # @install_bootable_layout.cold.109
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.161(%rip), %rdi
	callq	die
.Lfunc_end167:
	.size	install_bootable_layout.cold.109, .Lfunc_end167-install_bootable_layout.cold.109
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.110
	.type	install_bootable_layout.cold.110,@function
install_bootable_layout.cold.110:       # @install_bootable_layout.cold.110
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end168:
	.size	install_bootable_layout.cold.110, .Lfunc_end168-install_bootable_layout.cold.110
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.111
	.type	install_bootable_layout.cold.111,@function
install_bootable_layout.cold.111:       # @install_bootable_layout.cold.111
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end169:
	.size	install_bootable_layout.cold.111, .Lfunc_end169-install_bootable_layout.cold.111
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.112
	.type	install_bootable_layout.cold.112,@function
install_bootable_layout.cold.112:       # @install_bootable_layout.cold.112
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end170:
	.size	install_bootable_layout.cold.112, .Lfunc_end170-install_bootable_layout.cold.112
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function install_bootable_layout.cold.113
	.type	install_bootable_layout.cold.113,@function
install_bootable_layout.cold.113:       # @install_bootable_layout.cold.113
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end171:
	.size	install_bootable_layout.cold.113, .Lfunc_end171-install_bootable_layout.cold.113
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_file.cold.1
	.type	write_file.cold.1,@function
write_file.cold.1:                      # @write_file.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end172:
	.size	write_file.cold.1, .Lfunc_end172-write_file.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function read_file.cold.1
	.type	read_file.cold.1,@function
read_file.cold.1:                       # @read_file.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end173:
	.size	read_file.cold.1, .Lfunc_end173-read_file.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function read_file.cold.2
	.type	read_file.cold.2,@function
read_file.cold.2:                       # @read_file.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end174:
	.size	read_file.cold.2, .Lfunc_end174-read_file.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.1
	.type	write_file_path.cold.1,@function
write_file_path.cold.1:                 # @write_file_path.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.35(%rip), %rdi
	callq	die
.Lfunc_end175:
	.size	write_file_path.cold.1, .Lfunc_end175-write_file_path.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.2
	.type	write_file_path.cold.2,@function
write_file_path.cold.2:                 # @write_file_path.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.34(%rip), %rdi
	callq	die
.Lfunc_end176:
	.size	write_file_path.cold.2, .Lfunc_end176-write_file_path.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.3
	.type	write_file_path.cold.3,@function
write_file_path.cold.3:                 # @write_file_path.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end177:
	.size	write_file_path.cold.3, .Lfunc_end177-write_file_path.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_file_path.cold.4
	.type	write_file_path.cold.4,@function
write_file_path.cold.4:                 # @write_file_path.cold.4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end178:
	.size	write_file_path.cold.4, .Lfunc_end178-write_file_path.cold.4
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.1
	.type	ensure_child_directory.cold.1,@function
ensure_child_directory.cold.1:          # @ensure_child_directory.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.34(%rip), %rdi
	callq	die
.Lfunc_end179:
	.size	ensure_child_directory.cold.1, .Lfunc_end179-ensure_child_directory.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.2
	.type	ensure_child_directory.cold.2,@function
ensure_child_directory.cold.2:          # @ensure_child_directory.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end180:
	.size	ensure_child_directory.cold.2, .Lfunc_end180-ensure_child_directory.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.3
	.type	ensure_child_directory.cold.3,@function
ensure_child_directory.cold.3:          # @ensure_child_directory.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.34(%rip), %rdi
	callq	die
.Lfunc_end181:
	.size	ensure_child_directory.cold.3, .Lfunc_end181-ensure_child_directory.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.4
	.type	ensure_child_directory.cold.4,@function
ensure_child_directory.cold.4:          # @ensure_child_directory.cold.4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.40(%rip), %rdi
	callq	die
.Lfunc_end182:
	.size	ensure_child_directory.cold.4, .Lfunc_end182-ensure_child_directory.cold.4
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.5
	.type	ensure_child_directory.cold.5,@function
ensure_child_directory.cold.5:          # @ensure_child_directory.cold.5
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.29(%rip), %rdi
	callq	die
.Lfunc_end183:
	.size	ensure_child_directory.cold.5, .Lfunc_end183-ensure_child_directory.cold.5
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function ensure_child_directory.cold.6
	.type	ensure_child_directory.cold.6,@function
ensure_child_directory.cold.6:          # @ensure_child_directory.cold.6
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.36(%rip), %rdi
	callq	die
.Lfunc_end184:
	.size	ensure_child_directory.cold.6, .Lfunc_end184-ensure_child_directory.cold.6
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain.cold.1
	.type	write_cluster_chain.cold.1,@function
write_cluster_chain.cold.1:             # @write_cluster_chain.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.39(%rip), %rdi
	callq	die
.Lfunc_end185:
	.size	write_cluster_chain.cold.1, .Lfunc_end185-write_cluster_chain.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain.cold.2
	.type	write_cluster_chain.cold.2,@function
write_cluster_chain.cold.2:             # @write_cluster_chain.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.34(%rip), %rdi
	callq	die
.Lfunc_end186:
	.size	write_cluster_chain.cold.2, .Lfunc_end186-write_cluster_chain.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function write_cluster_chain.cold.3
	.type	write_cluster_chain.cold.3,@function
write_cluster_chain.cold.3:             # @write_cluster_chain.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end187:
	.size	write_cluster_chain.cold.3, .Lfunc_end187-write_cluster_chain.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.1
	.type	check_write_status.cold.1,@function
check_write_status.cold.1:              # @check_write_status.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.89(%rip), %rdi
	callq	die
.Lfunc_end188:
	.size	check_write_status.cold.1, .Lfunc_end188-check_write_status.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.2
	.type	check_write_status.cold.2,@function
check_write_status.cold.2:              # @check_write_status.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.92(%rip), %rdi
	callq	die
.Lfunc_end189:
	.size	check_write_status.cold.2, .Lfunc_end189-check_write_status.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.3
	.type	check_write_status.cold.3,@function
check_write_status.cold.3:              # @check_write_status.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.91(%rip), %rdi
	callq	die
.Lfunc_end190:
	.size	check_write_status.cold.3, .Lfunc_end190-check_write_status.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.4
	.type	check_write_status.cold.4,@function
check_write_status.cold.4:              # @check_write_status.cold.4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.91(%rip), %rdi
	callq	die
.Lfunc_end191:
	.size	check_write_status.cold.4, .Lfunc_end191-check_write_status.cold.4
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.5
	.type	check_write_status.cold.5,@function
check_write_status.cold.5:              # @check_write_status.cold.5
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.92(%rip), %rdi
	callq	die
.Lfunc_end192:
	.size	check_write_status.cold.5, .Lfunc_end192-check_write_status.cold.5
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.6
	.type	check_write_status.cold.6,@function
check_write_status.cold.6:              # @check_write_status.cold.6
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.92(%rip), %rdi
	callq	die
.Lfunc_end193:
	.size	check_write_status.cold.6, .Lfunc_end193-check_write_status.cold.6
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.7
	.type	check_write_status.cold.7,@function
check_write_status.cold.7:              # @check_write_status.cold.7
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.91(%rip), %rdi
	callq	die
.Lfunc_end194:
	.size	check_write_status.cold.7, .Lfunc_end194-check_write_status.cold.7
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_write_status.cold.8
	.type	check_write_status.cold.8,@function
check_write_status.cold.8:              # @check_write_status.cold.8
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.91(%rip), %rdi
	callq	die
.Lfunc_end195:
	.size	check_write_status.cold.8, .Lfunc_end195-check_write_status.cold.8
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_dynamic_fat_status.cold.1
	.type	check_dynamic_fat_status.cold.1,@function
check_dynamic_fat_status.cold.1:        # @check_dynamic_fat_status.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.89(%rip), %rdi
	callq	die
.Lfunc_end196:
	.size	check_dynamic_fat_status.cold.1, .Lfunc_end196-check_dynamic_fat_status.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function check_dynamic_fat_status.cold.2
	.type	check_dynamic_fat_status.cold.2,@function
check_dynamic_fat_status.cold.2:        # @check_dynamic_fat_status.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.91(%rip), %rdi
	callq	die
.Lfunc_end197:
	.size	check_dynamic_fat_status.cold.2, .Lfunc_end197-check_dynamic_fat_status.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function read_root_file_blob.cold.1
	.type	read_root_file_blob.cold.1,@function
read_root_file_blob.cold.1:             # @read_root_file_blob.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.22(%rip), %rdi
	callq	die
.Lfunc_end198:
	.size	read_root_file_blob.cold.1, .Lfunc_end198-read_root_file_blob.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part.cold.1
	.type	status_hex_tuple_part.cold.1,@function
status_hex_tuple_part.cold.1:           # @status_hex_tuple_part.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.90(%rip), %rdi
	callq	die
.Lfunc_end199:
	.size	status_hex_tuple_part.cold.1, .Lfunc_end199-status_hex_tuple_part.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part.cold.2
	.type	status_hex_tuple_part.cold.2,@function
status_hex_tuple_part.cold.2:           # @status_hex_tuple_part.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.91(%rip), %rdi
	callq	die
.Lfunc_end200:
	.size	status_hex_tuple_part.cold.2, .Lfunc_end200-status_hex_tuple_part.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function status_hex_tuple_part.cold.3
	.type	status_hex_tuple_part.cold.3,@function
status_hex_tuple_part.cold.3:           # @status_hex_tuple_part.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.89(%rip), %rdi
	callq	die
.Lfunc_end201:
	.size	status_hex_tuple_part.cold.3, .Lfunc_end201-status_hex_tuple_part.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.1
	.type	parse_path83.cold.1,@function
parse_path83.cold.1:                    # @parse_path83.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.112(%rip), %rdi
	callq	die
.Lfunc_end202:
	.size	parse_path83.cold.1, .Lfunc_end202-parse_path83.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.2
	.type	parse_path83.cold.2,@function
parse_path83.cold.2:                    # @parse_path83.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.110(%rip), %rdi
	callq	die
.Lfunc_end203:
	.size	parse_path83.cold.2, .Lfunc_end203-parse_path83.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.3
	.type	parse_path83.cold.3,@function
parse_path83.cold.3:                    # @parse_path83.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.112(%rip), %rdi
	callq	die
.Lfunc_end204:
	.size	parse_path83.cold.3, .Lfunc_end204-parse_path83.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.4
	.type	parse_path83.cold.4,@function
parse_path83.cold.4:                    # @parse_path83.cold.4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.110(%rip), %rdi
	callq	die
.Lfunc_end205:
	.size	parse_path83.cold.4, .Lfunc_end205-parse_path83.cold.4
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.5
	.type	parse_path83.cold.5,@function
parse_path83.cold.5:                    # @parse_path83.cold.5
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.115(%rip), %rdi
	callq	die
.Lfunc_end206:
	.size	parse_path83.cold.5, .Lfunc_end206-parse_path83.cold.5
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.6
	.type	parse_path83.cold.6,@function
parse_path83.cold.6:                    # @parse_path83.cold.6
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.114(%rip), %rdi
	callq	die
.Lfunc_end207:
	.size	parse_path83.cold.6, .Lfunc_end207-parse_path83.cold.6
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function parse_path83.cold.7
	.type	parse_path83.cold.7,@function
parse_path83.cold.7:                    # @parse_path83.cold.7
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.109(%rip), %rdi
	callq	die
.Lfunc_end208:
	.size	parse_path83.cold.7, .Lfunc_end208-parse_path83.cold.7
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.1
	.type	fat83_from_display_component.cold.1,@function
fat83_from_display_component.cold.1:    # @fat83_from_display_component.cold.1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.117(%rip), %rdi
	callq	die
.Lfunc_end209:
	.size	fat83_from_display_component.cold.1, .Lfunc_end209-fat83_from_display_component.cold.1
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.2
	.type	fat83_from_display_component.cold.2,@function
fat83_from_display_component.cold.2:    # @fat83_from_display_component.cold.2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.118(%rip), %rdi
	callq	die
.Lfunc_end210:
	.size	fat83_from_display_component.cold.2, .Lfunc_end210-fat83_from_display_component.cold.2
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.3
	.type	fat83_from_display_component.cold.3,@function
fat83_from_display_component.cold.3:    # @fat83_from_display_component.cold.3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.119(%rip), %rdi
	callq	die
.Lfunc_end211:
	.size	fat83_from_display_component.cold.3, .Lfunc_end211-fat83_from_display_component.cold.3
	.cfi_endproc
                                        # -- End function
	.p2align	4                               # -- Begin function fat83_from_display_component.cold.4
	.type	fat83_from_display_component.cold.4,@function
fat83_from_display_component.cold.4:    # @fat83_from_display_component.cold.4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.116(%rip), %rdi
	callq	die
.Lfunc_end212:
	.size	fat83_from_display_component.cold.4, .Lfunc_end212-fat83_from_display_component.cold.4
	.cfi_endproc
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
	.asciz	"--inspect"
	.size	.L.str.16, 10

	.type	.L.str.17,@object               # @.str.17
.L.str.17:
	.asciz	"--root-elf"
	.size	.L.str.17, 11

	.type	.L.str.18,@object               # @.str.18
.L.str.18:
	.asciz	"duplicate --root-elf entry"
	.size	.L.str.18, 27

	.type	.L.str.19,@object               # @.str.19
.L.str.19:
	.asciz	"--asset"
	.size	.L.str.19, 8

	.type	.L.str.20,@object               # @.str.20
.L.str.20:
	.asciz	"duplicate --root-elf FAT16 name"
	.size	.L.str.20, 32

	.type	LEGACY_PAYLOAD_ELF_NAME,@object # @LEGACY_PAYLOAD_ELF_NAME
	.section	.rodata,"a",@progbits
LEGACY_PAYLOAD_ELF_NAME:
	.asciz	"PAYLOAD0ELF"
	.size	LEGACY_PAYLOAD_ELF_NAME, 12

	.type	.L.str.21,@object               # @.str.21
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.21:
	.asciz	"legacy payload ELF conflicts with --root-elf"
	.size	.L.str.21, 45

	.type	.L.str.22,@object               # @.str.22
.L.str.22:
	.asciz	"out of memory"
	.size	.L.str.22, 14

	.type	.L.str.23,@object               # @.str.23
.L.str.23:
	.asciz	"unexpected disk image size"
	.size	.L.str.23, 27

	.type	.L.str.24,@object               # @.str.24
.L.str.24:
	.asciz	"rb"
	.size	.L.str.24, 3

	.type	.L.str.25,@object               # @.str.25
.L.str.25:
	.asciz	"seek failed"
	.size	.L.str.25, 12

	.type	.L.str.26,@object               # @.str.26
.L.str.26:
	.asciz	"tell failed"
	.size	.L.str.26, 12

	.type	.L.str.27,@object               # @.str.27
.L.str.27:
	.asciz	"read failed"
	.size	.L.str.27, 12

	.type	.L.str.28,@object               # @.str.28
.L.str.28:
	.asciz	"make_wad_image: %s: %s\n"
	.size	.L.str.28, 24

	.type	.L.str.29,@object               # @.str.29
.L.str.29:
	.asciz	"read past end"
	.size	.L.str.29, 14

	.type	.L.str.30,@object               # @.str.30
.L.str.30:
	.asciz	"PERSISTENCE_CHECKPOINT_NAME"
	.size	.L.str.30, 28

	.type	PERSISTENCE_CHECKPOINT_NAME,@object # @PERSISTENCE_CHECKPOINT_NAME
PERSISTENCE_CHECKPOINT_NAME:
	.asciz	"PERSIST CHK"
	.size	PERSISTENCE_CHECKPOINT_NAME, 12

	.type	.L.str.31,@object               # @.str.31
.L.str.31:
	.asciz	"SAVE_REQUEST_NAME"
	.size	.L.str.31, 18

	.type	SAVE_REQUEST_NAME,@object       # @SAVE_REQUEST_NAME
SAVE_REQUEST_NAME:
	.asciz	"SAVEREQ CHK"
	.size	SAVE_REQUEST_NAME, 12

	.type	.L.str.32,@object               # @.str.32
.L.str.32:
	.asciz	"LOAD_REQUEST_NAME"
	.size	.L.str.32, 18

	.type	LOAD_REQUEST_NAME,@object       # @LOAD_REQUEST_NAME
LOAD_REQUEST_NAME:
	.asciz	"LOADREQ CHK"
	.size	LOAD_REQUEST_NAME, 12

	.type	.L.str.33,@object               # @.str.33
.L.str.33:
	.asciz	"unknown root marker symbol"
	.size	.L.str.33, 27

	.type	.L.str.34,@object               # @.str.34
.L.str.34:
	.asciz	"cluster outside FAT16 data area"
	.size	.L.str.34, 32

	.type	.L.str.35,@object               # @.str.35
.L.str.35:
	.asciz	"FAT16 file path is empty"
	.size	.L.str.35, 25

	.type	.L.str.36,@object               # @.str.36
.L.str.36:
	.asciz	"FAT16 path component exists but is not a directory"
	.size	.L.str.36, 51

	.type	.L.str.37,@object               # @.str.37
.L.str.37:
	.asciz	".          "
	.size	.L.str.37, 12

	.type	.L.str.38,@object               # @.str.38
.L.str.38:
	.asciz	"..         "
	.size	.L.str.38, 12

	.type	.L.str.39,@object               # @.str.39
.L.str.39:
	.asciz	"file does not fit in FAT16 data area"
	.size	.L.str.39, 37

	.type	.L.str.40,@object               # @.str.40
.L.str.40:
	.asciz	"FAT16 directory is full"
	.size	.L.str.40, 24

	.type	.L.str.42,@object               # @.str.42
.L.str.42:
	.asciz	"usage: make_wad_image [--inspect IMAGE] [--primary-asset-wad PATH|--wad PATH] [--root-elf NAME.ELF=PATH] [--asset IMAGE_8.3_PATH=HOST_PATH] OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF [LEGACY_PAYLOAD_ELF]]]\n       make_wad_image --write-root-marker SYMBOL PAYLOAD IMAGE\n       make_wad_image --delete-root-marker SYMBOL IMAGE\n       make_wad_image --check-persistence IMAGE [--baseline-image IMAGE] [--reboot-baseline-image IMAGE] [--write-status FILE] [--save-write-status FILE] [--load-status FILE] [--reboot-status FILE] [--require-default] [--require-dynamic-fat-proof] [--require-save-slot N] [--require-save-description N=TEXT]"
	.size	.L.str.42, 629

	.type	.L.str.43,@object               # @.str.43
.L.str.43:
	.asciz	"--require-save-slot expects slot 0..5"
	.size	.L.str.43, 38

	.type	.L.str.44,@object               # @.str.44
.L.str.44:
	.asciz	"too many save slots requested"
	.size	.L.str.44, 30

	.type	.L.str.45,@object               # @.str.45
.L.str.45:
	.asciz	"--require-save-description expects SLOT=TEXT with slot 0..5"
	.size	.L.str.45, 60

	.type	.L.str.46,@object               # @.str.46
.L.str.46:
	.asciz	"dynamic FAT proof was requested without a write status file"
	.size	.L.str.46, 60

	.type	.L.str.48,@object               # @.str.48
.L.str.48:
	.asciz	"image=%s\n"
	.size	.L.str.48, 10

	.type	.L.str.49,@object               # @.str.49
.L.str.49:
	.asciz	"default_cfg=%s\n"
	.size	.L.str.49, 16

	.type	.L.str.50,@object               # @.str.50
.L.str.50:
	.asciz	"checked"
	.size	.L.str.50, 8

	.type	.L.str.51,@object               # @.str.51
.L.str.51:
	.asciz	"not-requested"
	.size	.L.str.51, 14

	.type	.L.str.52,@object               # @.str.52
.L.str.52:
	.asciz	"save_slot_%d=checked\n"
	.size	.L.str.52, 22

	.type	.L.str.54,@object               # @.str.54
.L.str.54:
	.asciz	"unexpected image size"
	.size	.L.str.54, 22

	.type	.L.str.55,@object               # @.str.55
.L.str.55:
	.asciz	"missing MBR signature"
	.size	.L.str.55, 22

	.type	.L.str.56,@object               # @.str.56
.L.str.56:
	.asciz	"unexpected partition layout"
	.size	.L.str.56, 28

	.type	.L.str.57,@object               # @.str.57
.L.str.57:
	.asciz	"missing FAT boot signature"
	.size	.L.str.57, 27

	.type	.L.str.58,@object               # @.str.58
.L.str.58:
	.asciz	"unexpected FAT bytes per sector"
	.size	.L.str.58, 32

	.type	.L.str.59,@object               # @.str.59
.L.str.59:
	.asciz	"unexpected FAT sectors per cluster"
	.size	.L.str.59, 35

	.type	DEFAULT_CFG_NAME,@object        # @DEFAULT_CFG_NAME
	.section	.rodata,"a",@progbits
DEFAULT_CFG_NAME:
	.asciz	"DEFAULT CFG"
	.size	DEFAULT_CFG_NAME, 12

	.type	.L.str.60,@object               # @.str.60
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.60:
	.asciz	"DEFAULT.CFG is missing from the FAT root"
	.size	.L.str.60, 41

	.type	.L.str.61,@object               # @.str.61
.L.str.61:
	.asciz	"DEFAULT.CFG is a directory"
	.size	.L.str.61, 27

	.type	.L.str.62,@object               # @.str.62
.L.str.62:
	.asciz	"DEFAULT.CFG was not written"
	.size	.L.str.62, 28

	.type	.L.str.63,@object               # @.str.63
.L.str.63:
	.asciz	"DEFAULT.CFG did not change from the persistence baseline"
	.size	.L.str.63, 57

	.type	.L.str.64,@object               # @.str.64
.L.str.64:
	.asciz	"left image"
	.size	.L.str.64, 11

	.type	.L.str.65,@object               # @.str.65
.L.str.65:
	.asciz	"right image"
	.size	.L.str.65, 12

	.type	.L.str.66,@object               # @.str.66
.L.str.66:
	.asciz	"file has invalid first cluster"
	.size	.L.str.66, 31

	.type	.L.str.67,@object               # @.str.67
.L.str.67:
	.asciz	"file cluster chain is invalid"
	.size	.L.str.67, 30

	.type	.L.str.68,@object               # @.str.68
.L.str.68:
	.asciz	"file cluster chain ended early"
	.size	.L.str.68, 31

	.type	.L.str.70,@object               # @.str.70
.L.str.70:
	.asciz	"required save slot is missing from the FAT root"
	.size	.L.str.70, 48

	.type	.L.str.71,@object               # @.str.71
.L.str.71:
	.asciz	"required save slot is a directory"
	.size	.L.str.71, 34

	.type	.L.str.72,@object               # @.str.72
.L.str.72:
	.asciz	"required save slot is too small to prove persistence"
	.size	.L.str.72, 53

	.type	.L.str.73,@object               # @.str.73
.L.str.73:
	.asciz	"required save slot did not change from the persistence baseline"
	.size	.L.str.73, 64

	.type	.L.str.74,@object               # @.str.74
.L.str.74:
	.asciz	"required save slot changed across reboot/load proof"
	.size	.L.str.74, 52

	.type	.L.str.75,@object               # @.str.75
.L.str.75:
	.asciz	"save slot"
	.size	.L.str.75, 10

	.type	.L.str.76,@object               # @.str.76
.L.str.76:
	.asciz	"required save description is longer than Doom's save title field"
	.size	.L.str.76, 65

	.type	.L.str.77,@object               # @.str.77
.L.str.77:
	.asciz	"required save slot does not contain the requested description"
	.size	.L.str.77, 62

	.type	.L.str.78,@object               # @.str.78
.L.str.78:
	.asciz	"version "
	.size	.L.str.78, 9

	.type	.L.str.79,@object               # @.str.79
.L.str.79:
	.asciz	"required save slot does not contain the expected version header"
	.size	.L.str.79, 64

	.type	.L.str.80,@object               # @.str.80
.L.str.80:
	.asciz	"save slot must be 0..5"
	.size	.L.str.80, 23

	.type	PRIMARY_SAVE_SLOT_TEMPLATE_NAME,@object # @PRIMARY_SAVE_SLOT_TEMPLATE_NAME
PRIMARY_SAVE_SLOT_TEMPLATE_NAME:
	.asciz	"DOOMSAV DSG"
	.size	PRIMARY_SAVE_SLOT_TEMPLATE_NAME, 12

	.type	.L.str.81,@object               # @.str.81
.L.str.81:
	.asciz	"savewr"
	.size	.L.str.81, 7

	.type	.L.str.82,@object               # @.str.82
.L.str.82:
	.asciz	"save write status did not prove save slot bytes and calls"
	.size	.L.str.82, 58

	.type	.L.str.83,@object               # @.str.83
.L.str.83:
	.asciz	"saveclose"
	.size	.L.str.83, 10

	.type	.L.str.84,@object               # @.str.84
.L.str.84:
	.asciz	"save write status did not prove close"
	.size	.L.str.84, 38

	.type	.L.str.85,@object               # @.str.85
.L.str.85:
	.asciz	"doomwrite"
	.size	.L.str.85, 10

	.type	.L.str.86,@object               # @.str.86
.L.str.86:
	.asciz	"write status did not prove file writes"
	.size	.L.str.86, 39

	.type	.L.str.87,@object               # @.str.87
.L.str.87:
	.asciz	"doomclose"
	.size	.L.str.87, 10

	.type	.L.str.88,@object               # @.str.88
.L.str.88:
	.asciz	"write status did not prove closes"
	.size	.L.str.88, 34

	.type	.L.str.89,@object               # @.str.89
.L.str.89:
	.asciz	"required status tuple is missing"
	.size	.L.str.89, 33

	.type	.L.str.90,@object               # @.str.90
.L.str.90:
	.asciz	"status tuple has too few parts"
	.size	.L.str.90, 31

	.type	.L.str.91,@object               # @.str.91
.L.str.91:
	.asciz	"status field did not contain a hex value"
	.size	.L.str.91, 41

	.type	.L.str.92,@object               # @.str.92
.L.str.92:
	.asciz	"required status field is missing"
	.size	.L.str.92, 33

	.type	.L.str.93,@object               # @.str.93
.L.str.93:
	.asciz	"gameplay=OK"
	.size	.L.str.93, 12

	.type	.L.str.94,@object               # @.str.94
.L.str.94:
	.asciz	"load status did not return to gameplay"
	.size	.L.str.94, 39

	.type	.L.str.95,@object               # @.str.95
.L.str.95:
	.asciz	"saverd"
	.size	.L.str.95, 7

	.type	.L.str.96,@object               # @.str.96
.L.str.96:
	.asciz	"load status did not prove save slot reads"
	.size	.L.str.96, 42

	.type	.L.str.97,@object               # @.str.97
.L.str.97:
	.asciz	"panic="
	.size	.L.str.97, 7

	.type	.L.str.98,@object               # @.str.98
.L.str.98:
	.asciz	"panic=NONE"
	.size	.L.str.98, 11

	.type	.L.str.99,@object               # @.str.99
.L.str.99:
	.asciz	"load status reported a panic"
	.size	.L.str.99, 29

	.type	.L.str.100,@object              # @.str.100
.L.str.100:
	.asciz	"reboot status did not return to gameplay"
	.size	.L.str.100, 41

	.type	.L.str.101,@object              # @.str.101
.L.str.101:
	.asciz	"reboot status reported a panic"
	.size	.L.str.101, 31

	.type	.L.str.102,@object              # @.str.102
.L.str.102:
	.asciz	"fatdyn"
	.size	.L.str.102, 7

	.type	.L.str.103,@object              # @.str.103
.L.str.103:
	.asciz	"fatdyn status did not prove dynamic FAT activity"
	.size	.L.str.103, 49

	.type	.L.str.104,@object              # @.str.104
.L.str.104:
	.asciz	"--root-elf must be NAME.ELF=PATH"
	.size	.L.str.104, 33

	.type	.L.str.105,@object              # @.str.105
.L.str.105:
	.asciz	"--root-elf display name is too long"
	.size	.L.str.105, 36

	.type	.L.str.106,@object              # @.str.106
.L.str.106:
	.asciz	"--root-elf must be a root-level NAME.ELF"
	.size	.L.str.106, 41

	.type	.L.str.107,@object              # @.str.107
.L.str.107:
	.asciz	"ELF"
	.size	.L.str.107, 4

	.type	.L.str.108,@object              # @.str.108
.L.str.108:
	.asciz	"--root-elf name must use .ELF"
	.size	.L.str.108, 30

	.type	.L.str.109,@object              # @.str.109
.L.str.109:
	.asciz	"FAT16 path must not be empty"
	.size	.L.str.109, 29

	.type	.L.str.110,@object              # @.str.110
.L.str.110:
	.asciz	"FAT16 path is too deep"
	.size	.L.str.110, 23

	.type	.L.str.111,@object              # @.str.111
.L.str.111:
	.asciz	".."
	.size	.L.str.111, 3

	.type	.L.str.112,@object              # @.str.112
.L.str.112:
	.asciz	"FAT16 path must not use dot traversal"
	.size	.L.str.112, 38

	.type	.L.str.114,@object              # @.str.114
.L.str.114:
	.asciz	"FAT16 path component is too long"
	.size	.L.str.114, 33

	.type	.L.str.115,@object              # @.str.115
.L.str.115:
	.asciz	"FAT16 path must name at least one component"
	.size	.L.str.115, 44

	.type	.L.str.116,@object              # @.str.116
.L.str.116:
	.asciz	"FAT16 path component must fit 8.3"
	.size	.L.str.116, 34

	.type	.L.str.117,@object              # @.str.117
.L.str.117:
	.asciz	"FAT16 path component has too many dots"
	.size	.L.str.117, 39

	.type	.L.str.118,@object              # @.str.118
.L.str.118:
	.asciz	"FAT16 path component has unsupported characters"
	.size	.L.str.118, 48

	.type	.L.str.119,@object              # @.str.119
.L.str.119:
	.asciz	"FAT16 extension has unsupported characters"
	.size	.L.str.119, 43

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

	.type	.L.str.120,@object              # @.str.120
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.120:
	.asciz	"--root-elf tries to replace a protected boot entry"
	.size	.L.str.120, 51

	.type	.L.str.121,@object              # @.str.121
.L.str.121:
	.asciz	"make_wad_image: %s\n"
	.size	.L.str.121, 20

	.type	.L.str.122,@object              # @.str.122
.L.str.122:
	.asciz	"--asset must be IMAGE_8.3_PATH=HOST_PATH"
	.size	.L.str.122, 41

	.type	.L.str.123,@object              # @.str.123
.L.str.123:
	.asciz	"--asset display path is too long"
	.size	.L.str.123, 33

	.type	.L.str.125,@object              # @.str.125
.L.str.125:
	.asciz	"image_size=%zu\n"
	.size	.L.str.125, 16

	.type	.L.str.126,@object              # @.str.126
.L.str.126:
	.asciz	"partition_lba=%u\n"
	.size	.L.str.126, 18

	.type	.L.str.127,@object              # @.str.127
.L.str.127:
	.asciz	"partition_sectors=%u\n"
	.size	.L.str.127, 22

	.type	.L.str.128,@object              # @.str.128
.L.str.128:
	.asciz	"root_lba=%u\n"
	.size	.L.str.128, 13

	.type	.L.str.129,@object              # @.str.129
.L.str.129:
	.asciz	"data_lba=%u\n"
	.size	.L.str.129, 13

	.type	.L.str.130,@object              # @.str.130
.L.str.130:
	.asciz	"data_clusters=%u\n"
	.size	.L.str.130, 18

	.type	.L.str.131,@object              # @.str.131
.L.str.131:
	.asciz	"root[%u]=%s attr=0x%02X cluster=%u size=%u\n"
	.size	.L.str.131, 44

	.type	.L.str.132,@object              # @.str.132
.L.str.132:
	.asciz	"stage1, stage2, and kernel paths must be provided together"
	.size	.L.str.132, 59

	.type	.L.str.133,@object              # @.str.133
.L.str.133:
	.asciz	"legacy root payload ELF packaging requires a user probe ELF path"
	.size	.L.str.133, 65

	.type	.L.str.134,@object              # @.str.134
.L.str.134:
	.asciz	"primary WAD asset (DOOM1.WAD) must start at cluster 2"
	.size	.L.str.134, 54

	.type	DEFAULT_CFG_CONTENT,@object     # @DEFAULT_CFG_CONTENT
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
DEFAULT_CFG_CONTENT:
	.asciz	"screenblocks\t\t11\n"
	.size	DEFAULT_CFG_CONTENT, 18

	.type	.L.str.135,@object              # @.str.135
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.135:
	.asciz	"FAT16 image does not leave enough OS-created file headroom"
	.size	.L.str.135, 59

	.type	.L.str.136,@object              # @.str.136
.L.str.136:
	.asciz	"stage1 must be exactly 512 bytes"
	.size	.L.str.136, 33

	.type	.L.str.137,@object              # @.str.137
.L.str.137:
	.asciz	"stage2"
	.size	.L.str.137, 7

	.type	.L.str.138,@object              # @.str.138
.L.str.138:
	.asciz	"kernel"
	.size	.L.str.138, 7

	.type	FAT_VOLUME_LABEL,@object        # @FAT_VOLUME_LABEL
FAT_VOLUME_LABEL:
	.asciz	"VIBEOS WAD "
	.size	FAT_VOLUME_LABEL, 12

	.type	.L.str.140,@object              # @.str.140
.L.str.140:
	.asciz	"make_wad_image: %s is %zu bytes, exceeds %zu bytes\n"
	.size	.L.str.140, 52

	.type	.L.str.141,@object              # @.str.141
.L.str.141:
	.asciz	"WAD exceeds primary asset load limit"
	.size	.L.str.141, 37

	.type	.L.str.142,@object              # @.str.142
.L.str.142:
	.asciz	"too small to be a WAD"
	.size	.L.str.142, 22

	.type	.L.str.143,@object              # @.str.143
.L.str.143:
	.asciz	"IWAD"
	.size	.L.str.143, 5

	.type	.L.str.144,@object              # @.str.144
.L.str.144:
	.asciz	"PWAD"
	.size	.L.str.144, 5

	.type	.L.str.145,@object              # @.str.145
.L.str.145:
	.asciz	"does not start with IWAD or PWAD"
	.size	.L.str.145, 33

	.type	.L.str.146,@object              # @.str.146
.L.str.146:
	.asciz	"WAD directory is outside the file"
	.size	.L.str.146, 34

	.type	.L.str.147,@object              # @.str.147
.L.str.147:
	.asciz	"PLAYPAL"
	.size	.L.str.147, 8

	.type	.L.str.149,@object              # @.str.149
.L.str.149:
	.asciz	"PNAMES"
	.size	.L.str.149, 7

	.type	.L.str.151,@object              # @.str.151
.L.str.151:
	.asciz	"F_START"
	.size	.L.str.151, 8

	.type	.L.str.152,@object              # @.str.152
.L.str.152:
	.asciz	"F_SKY1"
	.size	.L.str.152, 7

	.type	.L.str.153,@object              # @.str.153
.L.str.153:
	.asciz	"F_END"
	.size	.L.str.153, 6

	.type	.L.str.154,@object              # @.str.154
.L.str.154:
	.asciz	"S_START"
	.size	.L.str.154, 8

	.type	.L.str.155,@object              # @.str.155
.L.str.155:
	.asciz	"S_END"
	.size	.L.str.155, 6

	.type	.L.str.157,@object              # @.str.157
.L.str.157:
	.asciz	"D_INTRO"
	.size	.L.str.157, 8

	.type	.L.str.159,@object              # @.str.159
.L.str.159:
	.asciz	"THINGS"
	.size	.L.str.159, 7

	.type	.L__const.build_generated_wad.pattern,@object # @__const.build_generated_wad.pattern
	.section	.rodata.str1.16,"aMS",@progbits,1
	.p2align	4, 0x0
.L__const.build_generated_wad.pattern:
	.asciz	"vibe-os hard-path IDE FAT16 WAD fixture\n"
	.size	.L__const.build_generated_wad.pattern, 41

	.type	.L.str.161,@object              # @.str.161
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.161:
	.asciz	"WAD lump name too long"
	.size	.L.str.161, 23

	.type	switch_textures,@object         # @switch_textures
	.section	.data.rel.ro,"aw",@progbits
	.p2align	4, 0x0
switch_textures:
	.quad	.L.str.162
	.quad	.L.str.163
	.quad	.L.str.164
	.quad	.L.str.165
	.quad	.L.str.166
	.quad	.L.str.167
	.quad	.L.str.168
	.quad	.L.str.169
	.quad	.L.str.170
	.quad	.L.str.171
	.quad	.L.str.172
	.quad	.L.str.173
	.quad	.L.str.174
	.quad	.L.str.175
	.quad	.L.str.176
	.quad	.L.str.177
	.quad	.L.str.178
	.quad	.L.str.179
	.quad	.L.str.180
	.quad	.L.str.181
	.quad	.L.str.182
	.quad	.L.str.183
	.quad	.L.str.184
	.quad	.L.str.185
	.quad	.L.str.186
	.quad	.L.str.187
	.quad	.L.str.188
	.quad	.L.str.189
	.quad	.L.str.190
	.quad	.L.str.191
	.quad	.L.str.192
	.quad	.L.str.193
	.quad	.L.str.194
	.quad	.L.str.195
	.quad	.L.str.196
	.quad	.L.str.197
	.quad	.L.str.198
	.quad	.L.str.199
	.quad	.L.str.200
	.quad	.L.str.201
	.quad	.L.str.202
	.quad	.L.str.203
	.size	switch_textures, 336

	.type	.L.str.162,@object              # @.str.162
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.162:
	.asciz	"SW1BRCOM"
	.size	.L.str.162, 9

	.type	.L.str.163,@object              # @.str.163
.L.str.163:
	.asciz	"SW2BRCOM"
	.size	.L.str.163, 9

	.type	.L.str.164,@object              # @.str.164
.L.str.164:
	.asciz	"SW1BRN1"
	.size	.L.str.164, 8

	.type	.L.str.165,@object              # @.str.165
.L.str.165:
	.asciz	"SW2BRN1"
	.size	.L.str.165, 8

	.type	.L.str.166,@object              # @.str.166
.L.str.166:
	.asciz	"SW1BRN2"
	.size	.L.str.166, 8

	.type	.L.str.167,@object              # @.str.167
.L.str.167:
	.asciz	"SW2BRN2"
	.size	.L.str.167, 8

	.type	.L.str.168,@object              # @.str.168
.L.str.168:
	.asciz	"SW1BRNGN"
	.size	.L.str.168, 9

	.type	.L.str.169,@object              # @.str.169
.L.str.169:
	.asciz	"SW2BRNGN"
	.size	.L.str.169, 9

	.type	.L.str.170,@object              # @.str.170
.L.str.170:
	.asciz	"SW1BROWN"
	.size	.L.str.170, 9

	.type	.L.str.171,@object              # @.str.171
.L.str.171:
	.asciz	"SW2BROWN"
	.size	.L.str.171, 9

	.type	.L.str.172,@object              # @.str.172
.L.str.172:
	.asciz	"SW1COMM"
	.size	.L.str.172, 8

	.type	.L.str.173,@object              # @.str.173
.L.str.173:
	.asciz	"SW2COMM"
	.size	.L.str.173, 8

	.type	.L.str.174,@object              # @.str.174
.L.str.174:
	.asciz	"SW1COMP"
	.size	.L.str.174, 8

	.type	.L.str.175,@object              # @.str.175
.L.str.175:
	.asciz	"SW2COMP"
	.size	.L.str.175, 8

	.type	.L.str.176,@object              # @.str.176
.L.str.176:
	.asciz	"SW1DIRT"
	.size	.L.str.176, 8

	.type	.L.str.177,@object              # @.str.177
.L.str.177:
	.asciz	"SW2DIRT"
	.size	.L.str.177, 8

	.type	.L.str.178,@object              # @.str.178
.L.str.178:
	.asciz	"SW1EXIT"
	.size	.L.str.178, 8

	.type	.L.str.179,@object              # @.str.179
.L.str.179:
	.asciz	"SW2EXIT"
	.size	.L.str.179, 8

	.type	.L.str.180,@object              # @.str.180
.L.str.180:
	.asciz	"SW1GRAY"
	.size	.L.str.180, 8

	.type	.L.str.181,@object              # @.str.181
.L.str.181:
	.asciz	"SW2GRAY"
	.size	.L.str.181, 8

	.type	.L.str.182,@object              # @.str.182
.L.str.182:
	.asciz	"SW1GRAY1"
	.size	.L.str.182, 9

	.type	.L.str.183,@object              # @.str.183
.L.str.183:
	.asciz	"SW2GRAY1"
	.size	.L.str.183, 9

	.type	.L.str.184,@object              # @.str.184
.L.str.184:
	.asciz	"SW1METAL"
	.size	.L.str.184, 9

	.type	.L.str.185,@object              # @.str.185
.L.str.185:
	.asciz	"SW2METAL"
	.size	.L.str.185, 9

	.type	.L.str.186,@object              # @.str.186
.L.str.186:
	.asciz	"SW1PIPE"
	.size	.L.str.186, 8

	.type	.L.str.187,@object              # @.str.187
.L.str.187:
	.asciz	"SW2PIPE"
	.size	.L.str.187, 8

	.type	.L.str.188,@object              # @.str.188
.L.str.188:
	.asciz	"SW1SLAD"
	.size	.L.str.188, 8

	.type	.L.str.189,@object              # @.str.189
.L.str.189:
	.asciz	"SW2SLAD"
	.size	.L.str.189, 8

	.type	.L.str.190,@object              # @.str.190
.L.str.190:
	.asciz	"SW1STARG"
	.size	.L.str.190, 9

	.type	.L.str.191,@object              # @.str.191
.L.str.191:
	.asciz	"SW2STARG"
	.size	.L.str.191, 9

	.type	.L.str.192,@object              # @.str.192
.L.str.192:
	.asciz	"SW1STON1"
	.size	.L.str.192, 9

	.type	.L.str.193,@object              # @.str.193
.L.str.193:
	.asciz	"SW2STON1"
	.size	.L.str.193, 9

	.type	.L.str.194,@object              # @.str.194
.L.str.194:
	.asciz	"SW1STON2"
	.size	.L.str.194, 9

	.type	.L.str.195,@object              # @.str.195
.L.str.195:
	.asciz	"SW2STON2"
	.size	.L.str.195, 9

	.type	.L.str.196,@object              # @.str.196
.L.str.196:
	.asciz	"SW1STONE"
	.size	.L.str.196, 9

	.type	.L.str.197,@object              # @.str.197
.L.str.197:
	.asciz	"SW2STONE"
	.size	.L.str.197, 9

	.type	.L.str.198,@object              # @.str.198
.L.str.198:
	.asciz	"SW1STRTN"
	.size	.L.str.198, 9

	.type	.L.str.199,@object              # @.str.199
.L.str.199:
	.asciz	"SW2STRTN"
	.size	.L.str.199, 9

	.type	.L.str.200,@object              # @.str.200
.L.str.200:
	.asciz	"SKY1"
	.size	.L.str.200, 5

	.type	.L.str.201,@object              # @.str.201
.L.str.201:
	.asciz	"SKY2"
	.size	.L.str.201, 5

	.type	.L.str.202,@object              # @.str.202
.L.str.202:
	.asciz	"SKY3"
	.size	.L.str.202, 5

	.type	.L.str.203,@object              # @.str.203
.L.str.203:
	.asciz	"SKY4"
	.size	.L.str.203, 5

	.type	.L.str.205,@object              # @.str.205
.L.str.205:
	.asciz	"STCFN%03d"
	.size	.L.str.205, 10

	.type	.L.str.206,@object              # @.str.206
.L.str.206:
	.asciz	"STTNUM%d"
	.size	.L.str.206, 9

	.type	.L.str.207,@object              # @.str.207
.L.str.207:
	.asciz	"STYSNUM%d"
	.size	.L.str.207, 10

	.type	.L.str.209,@object              # @.str.209
.L.str.209:
	.asciz	"STKEYS%d"
	.size	.L.str.209, 9

	.type	.L.str.210,@object              # @.str.210
.L.str.210:
	.asciz	"STARMS"
	.size	.L.str.210, 7

	.type	.L.str.211,@object              # @.str.211
.L.str.211:
	.asciz	"STGNUM%d"
	.size	.L.str.211, 9

	.type	.L.str.212,@object              # @.str.212
.L.str.212:
	.asciz	"STFB0"
	.size	.L.str.212, 6

	.type	.L.str.213,@object              # @.str.213
.L.str.213:
	.asciz	"STBAR"
	.size	.L.str.213, 6

	.type	.L.str.214,@object              # @.str.214
.L.str.214:
	.asciz	"STFST%d%d"
	.size	.L.str.214, 10

	.type	.L.str.215,@object              # @.str.215
.L.str.215:
	.asciz	"STFTR%d0"
	.size	.L.str.215, 9

	.type	.L.str.216,@object              # @.str.216
.L.str.216:
	.asciz	"STFTL%d0"
	.size	.L.str.216, 9

	.type	.L.str.217,@object              # @.str.217
.L.str.217:
	.asciz	"STFOUCH%d"
	.size	.L.str.217, 10

	.type	.L.str.218,@object              # @.str.218
.L.str.218:
	.asciz	"STFEVL%d"
	.size	.L.str.218, 9

	.type	.L.str.219,@object              # @.str.219
.L.str.219:
	.asciz	"STFKILL%d"
	.size	.L.str.219, 10

	.type	.L.str.220,@object              # @.str.220
.L.str.220:
	.asciz	"STFGOD0"
	.size	.L.str.220, 8

	.type	.L.str.223,@object              # @.str.223
.L.str.223:
	.asciz	"CREDIT"
	.size	.L.str.223, 7

	.type	.L.str.224,@object              # @.str.224
.L.str.224:
	.asciz	"HELP2"
	.size	.L.str.224, 6

	.type	.L.str.225,@object              # @.str.225
.L.str.225:
	.asciz	"FAT16 root directory is full"
	.size	.L.str.225, 29

	.type	package_default_assets.readme,@object # @package_default_assets.readme
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
package_default_assets.readme:
	.asciz	"vibe-os FAT16 one-level asset file\n"
	.size	package_default_assets.readme, 36

	.type	package_default_assets.map,@object # @package_default_assets.map
	.p2align	4, 0x0
package_default_assets.map:
	.asciz	"name=E1M1\nmusic=D_E1M1\n"
	.size	package_default_assets.map, 24

	.type	STATE_DIR_NAME,@object          # @STATE_DIR_NAME
	.section	.rodata.str1.1,"aMS",@progbits,1
STATE_DIR_NAME:
	.asciz	"STATE      "
	.size	STATE_DIR_NAME, 12

	.type	.L.str.226,@object              # @.str.226
.L.str.226:
	.asciz	"/assets/readme.txt"
	.size	.L.str.226, 19

	.type	.L.str.227,@object              # @.str.227
.L.str.227:
	.asciz	"/assets/maps/e1m1.map"
	.size	.L.str.227, 22

	.type	.L.str.228,@object              # @.str.228
.L.str.228:
	.asciz	"/assets/textures/pal0.bin"
	.size	.L.str.228, 26

	.type	.L.str.229,@object              # @.str.229
.L.str.229:
	.asciz	"--asset path must include a directory component"
	.size	.L.str.229, 48

	.type	.L.str.230,@object              # @.str.230
.L.str.230:
	.asciz	"wb"
	.size	.L.str.230, 3

	.type	.L.str.231,@object              # @.str.231
.L.str.231:
	.asciz	"write failed"
	.size	.L.str.231, 13

	.type	.Lstr,@object                   # @str
.Lstr:
	.asciz	"schema=vibe-os-c-persistence-proof-v1"
	.size	.Lstr, 38

	.type	.Lstr.232,@object               # @str.232
.Lstr.232:
	.asciz	"result=ok"
	.size	.Lstr.232, 10

	.type	.Lstr.233,@object               # @str.233
.Lstr.233:
	.asciz	"schema=vibe-os-c-image-inspect-v1"
	.size	.Lstr.233, 34

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
	.addrsig_sym mutate_root_marker.cold.1
	.addrsig_sym mutate_root_marker.cold.2
	.addrsig_sym mutate_root_marker.cold.3
	.addrsig_sym install_bootable_layout.cold.1
	.addrsig_sym install_bootable_layout.cold.2
	.addrsig_sym install_bootable_layout.cold.3
	.addrsig_sym install_bootable_layout.cold.4
	.addrsig_sym install_bootable_layout.cold.5
	.addrsig_sym install_bootable_layout.cold.6
	.addrsig_sym install_bootable_layout.cold.7
	.addrsig_sym install_bootable_layout.cold.8
	.addrsig_sym install_bootable_layout.cold.9
	.addrsig_sym install_bootable_layout.cold.10
	.addrsig_sym install_bootable_layout.cold.11
	.addrsig_sym install_bootable_layout.cold.12
	.addrsig_sym install_bootable_layout.cold.13
	.addrsig_sym install_bootable_layout.cold.14
	.addrsig_sym install_bootable_layout.cold.15
	.addrsig_sym install_bootable_layout.cold.16
	.addrsig_sym install_bootable_layout.cold.17
	.addrsig_sym install_bootable_layout.cold.18
	.addrsig_sym install_bootable_layout.cold.19
	.addrsig_sym install_bootable_layout.cold.20
	.addrsig_sym install_bootable_layout.cold.21
	.addrsig_sym install_bootable_layout.cold.22
	.addrsig_sym install_bootable_layout.cold.23
	.addrsig_sym install_bootable_layout.cold.24
	.addrsig_sym install_bootable_layout.cold.25
	.addrsig_sym install_bootable_layout.cold.26
	.addrsig_sym install_bootable_layout.cold.27
	.addrsig_sym install_bootable_layout.cold.28
	.addrsig_sym install_bootable_layout.cold.29
	.addrsig_sym install_bootable_layout.cold.30
	.addrsig_sym install_bootable_layout.cold.31
	.addrsig_sym install_bootable_layout.cold.32
	.addrsig_sym install_bootable_layout.cold.33
	.addrsig_sym install_bootable_layout.cold.34
	.addrsig_sym install_bootable_layout.cold.35
	.addrsig_sym install_bootable_layout.cold.36
	.addrsig_sym install_bootable_layout.cold.37
	.addrsig_sym install_bootable_layout.cold.38
	.addrsig_sym install_bootable_layout.cold.39
	.addrsig_sym install_bootable_layout.cold.40
	.addrsig_sym install_bootable_layout.cold.41
	.addrsig_sym install_bootable_layout.cold.42
	.addrsig_sym install_bootable_layout.cold.43
	.addrsig_sym install_bootable_layout.cold.44
	.addrsig_sym install_bootable_layout.cold.45
	.addrsig_sym install_bootable_layout.cold.46
	.addrsig_sym install_bootable_layout.cold.47
	.addrsig_sym install_bootable_layout.cold.48
	.addrsig_sym install_bootable_layout.cold.49
	.addrsig_sym install_bootable_layout.cold.50
	.addrsig_sym install_bootable_layout.cold.51
	.addrsig_sym install_bootable_layout.cold.52
	.addrsig_sym install_bootable_layout.cold.53
	.addrsig_sym install_bootable_layout.cold.54
	.addrsig_sym install_bootable_layout.cold.55
	.addrsig_sym install_bootable_layout.cold.56
	.addrsig_sym install_bootable_layout.cold.57
	.addrsig_sym install_bootable_layout.cold.58
	.addrsig_sym install_bootable_layout.cold.59
	.addrsig_sym install_bootable_layout.cold.60
	.addrsig_sym install_bootable_layout.cold.61
	.addrsig_sym install_bootable_layout.cold.62
	.addrsig_sym install_bootable_layout.cold.63
	.addrsig_sym install_bootable_layout.cold.64
	.addrsig_sym install_bootable_layout.cold.65
	.addrsig_sym install_bootable_layout.cold.66
	.addrsig_sym install_bootable_layout.cold.67
	.addrsig_sym install_bootable_layout.cold.68
	.addrsig_sym install_bootable_layout.cold.69
	.addrsig_sym install_bootable_layout.cold.70
	.addrsig_sym install_bootable_layout.cold.71
	.addrsig_sym install_bootable_layout.cold.72
	.addrsig_sym install_bootable_layout.cold.73
	.addrsig_sym install_bootable_layout.cold.74
	.addrsig_sym install_bootable_layout.cold.75
	.addrsig_sym install_bootable_layout.cold.76
	.addrsig_sym install_bootable_layout.cold.77
	.addrsig_sym install_bootable_layout.cold.78
	.addrsig_sym install_bootable_layout.cold.79
	.addrsig_sym install_bootable_layout.cold.80
	.addrsig_sym install_bootable_layout.cold.81
	.addrsig_sym install_bootable_layout.cold.82
	.addrsig_sym install_bootable_layout.cold.83
	.addrsig_sym install_bootable_layout.cold.84
	.addrsig_sym install_bootable_layout.cold.85
	.addrsig_sym install_bootable_layout.cold.86
	.addrsig_sym install_bootable_layout.cold.87
	.addrsig_sym install_bootable_layout.cold.88
	.addrsig_sym install_bootable_layout.cold.89
	.addrsig_sym install_bootable_layout.cold.90
	.addrsig_sym install_bootable_layout.cold.91
	.addrsig_sym install_bootable_layout.cold.92
	.addrsig_sym install_bootable_layout.cold.93
	.addrsig_sym install_bootable_layout.cold.94
	.addrsig_sym install_bootable_layout.cold.95
	.addrsig_sym install_bootable_layout.cold.96
	.addrsig_sym install_bootable_layout.cold.97
	.addrsig_sym install_bootable_layout.cold.98
	.addrsig_sym install_bootable_layout.cold.99
	.addrsig_sym install_bootable_layout.cold.100
	.addrsig_sym install_bootable_layout.cold.101
	.addrsig_sym install_bootable_layout.cold.102
	.addrsig_sym install_bootable_layout.cold.103
	.addrsig_sym install_bootable_layout.cold.104
	.addrsig_sym install_bootable_layout.cold.105
	.addrsig_sym install_bootable_layout.cold.106
	.addrsig_sym install_bootable_layout.cold.107
	.addrsig_sym install_bootable_layout.cold.108
	.addrsig_sym install_bootable_layout.cold.109
	.addrsig_sym install_bootable_layout.cold.110
	.addrsig_sym install_bootable_layout.cold.111
	.addrsig_sym install_bootable_layout.cold.112
	.addrsig_sym install_bootable_layout.cold.113
	.addrsig_sym write_file.cold.1
	.addrsig_sym read_file.cold.1
	.addrsig_sym read_file.cold.2
	.addrsig_sym write_file_path.cold.1
	.addrsig_sym write_file_path.cold.2
	.addrsig_sym write_file_path.cold.3
	.addrsig_sym write_file_path.cold.4
	.addrsig_sym ensure_child_directory.cold.1
	.addrsig_sym ensure_child_directory.cold.2
	.addrsig_sym ensure_child_directory.cold.3
	.addrsig_sym ensure_child_directory.cold.4
	.addrsig_sym ensure_child_directory.cold.5
	.addrsig_sym ensure_child_directory.cold.6
	.addrsig_sym write_cluster_chain.cold.1
	.addrsig_sym write_cluster_chain.cold.2
	.addrsig_sym write_cluster_chain.cold.3
	.addrsig_sym check_write_status.cold.1
	.addrsig_sym check_write_status.cold.2
	.addrsig_sym check_write_status.cold.3
	.addrsig_sym check_write_status.cold.4
	.addrsig_sym check_write_status.cold.5
	.addrsig_sym check_write_status.cold.6
	.addrsig_sym check_write_status.cold.7
	.addrsig_sym check_write_status.cold.8
	.addrsig_sym check_dynamic_fat_status.cold.1
	.addrsig_sym check_dynamic_fat_status.cold.2
	.addrsig_sym read_root_file_blob.cold.1
	.addrsig_sym status_hex_tuple_part.cold.1
	.addrsig_sym status_hex_tuple_part.cold.2
	.addrsig_sym status_hex_tuple_part.cold.3
	.addrsig_sym parse_path83.cold.1
	.addrsig_sym parse_path83.cold.2
	.addrsig_sym parse_path83.cold.3
	.addrsig_sym parse_path83.cold.4
	.addrsig_sym parse_path83.cold.5
	.addrsig_sym parse_path83.cold.6
	.addrsig_sym parse_path83.cold.7
	.addrsig_sym fat83_from_display_component.cold.1
	.addrsig_sym fat83_from_display_component.cold.2
	.addrsig_sym fat83_from_display_component.cold.3
	.addrsig_sym fat83_from_display_component.cold.4
	.addrsig_sym LEGACY_PAYLOAD_ELF_NAME
	.addrsig_sym DEFAULT_CFG_NAME
	.addrsig_sym PRIMARY_ASSET_WAD_NAME
	.addrsig_sym KERNEL_ELF_NAME
	.addrsig_sym USER_PROBE_NAME
	.addrsig_sym DEFAULT_CFG_CONTENT
	.addrsig_sym package_default_assets.readme
	.addrsig_sym package_default_assets.map
