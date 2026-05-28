	.file	"link_aarch64_flat.linux.c"
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
	subq	$184, %rsp
	cmpl	$2, %edi
	jl	.LBB0_23
# %bb.1:
	movq	%rsi, %r14
	movl	%edi, %ebp
	movq	$0, 24(%rsp)                    # 8-byte Folded Spill
	movl	$1, %r13d
	movq	$0, 56(%rsp)                    # 8-byte Folded Spill
	xorl	%r12d, %r12d
	movq	$0, 136(%rsp)                   # 8-byte Folded Spill
	movq	$0, 96(%rsp)                    # 8-byte Folded Spill
	jmp	.LBB0_2
.LBB0_5:                                #   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%ebp, %r13d
	jge	.LBB0_187
# %bb.6:                                #   in Loop: Header=BB0_2 Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rax
	movq	%rax, 96(%rsp)                  # 8-byte Spill
	.p2align	4
.LBB0_19:                               #   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%ebp, %r13d
	jge	.LBB0_20
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rbx
	movzbl	(%rbx), %r15d
	cmpb	$45, %r15b
	jne	.LBB0_7
# %bb.3:                                #   in Loop: Header=BB0_2 Depth=1
	cmpb	$111, 1(%rbx)
	jne	.LBB0_7
# %bb.4:                                #   in Loop: Header=BB0_2 Depth=1
	cmpb	$0, 2(%rbx)
	je	.LBB0_5
	.p2align	4
.LBB0_7:                                #   in Loop: Header=BB0_2 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.2(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_8
# %bb.13:                               #   in Loop: Header=BB0_2 Depth=1
	movq	%rbx, %rdi
	leaq	.L.str.4(%rip), %rsi
	callq	strcmp@PLT
	testl	%eax, %eax
	je	.LBB0_14
# %bb.16:                               #   in Loop: Header=BB0_2 Depth=1
	cmpb	$45, %r15b
	je	.LBB0_17
# %bb.18:                               #   in Loop: Header=BB0_2 Depth=1
	testq	%r12, %r12
	movq	%rbx, %r12
	je	.LBB0_19
	jmp	.LBB0_191
	.p2align	4
.LBB0_8:                                #   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%ebp, %r13d
	jge	.LBB0_188
# %bb.9:                                #   in Loop: Header=BB0_2 Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rbx
	movq	$0, 152(%rsp)
	callq	__errno_location@PLT
	movl	$0, (%rax)
	movq	%rbx, %rdi
	leaq	152(%rsp), %rsi
	xorl	%edx, %edx
	callq	strtoull@PLT
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	callq	__errno_location@PLT
	cmpl	$0, (%rax)
	jne	.LBB0_189
# %bb.10:                               #   in Loop: Header=BB0_2 Depth=1
	movq	152(%rsp), %rax
	testq	%rax, %rax
	je	.LBB0_189
# %bb.11:                               #   in Loop: Header=BB0_2 Depth=1
	cmpb	$0, (%rax)
	jne	.LBB0_189
# %bb.12:                               #   in Loop: Header=BB0_2 Depth=1
	movl	$1, %eax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	jmp	.LBB0_19
	.p2align	4
.LBB0_14:                               #   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%ebp, %r13d
	jge	.LBB0_190
# %bb.15:                               #   in Loop: Header=BB0_2 Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rax
	movq	%rax, 136(%rsp)                 # 8-byte Spill
	jmp	.LBB0_19
.LBB0_20:
	cmpq	$0, 96(%rsp)                    # 8-byte Folded Reload
	je	.LBB0_23
# %bb.21:
	cmpl	$0, 24(%rsp)                    # 4-byte Folded Reload
	je	.LBB0_23
# %bb.22:
	movq	%r12, %rbp
	testq	%r12, %r12
	je	.LBB0_23
# %bb.24:
	leaq	.L.str.11(%rip), %rsi
	movq	%rbp, %rdi
	callq	fopen@PLT
	testq	%rax, %rax
	je	.LBB0_192
# %bb.25:
	movq	%rax, %r15
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$2, %edx
	callq	fseek@PLT
	testl	%eax, %eax
	jne	.LBB0_193
# %bb.26:
	movq	%r15, %rdi
	callq	ftell@PLT
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	testq	%rax, %rax
	js	.LBB0_194
# %bb.27:
	movq	%r15, %rdi
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	fseek@PLT
	testl	%eax, %eax
	jne	.LBB0_193
# %bb.28:
	movq	40(%rsp), %rbx                  # 8-byte Reload
	cmpq	$1, %rbx
	movq	%rbx, %rdi
	adcq	$0, %rdi
	movl	$1, %esi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_195
# %bb.29:
	testq	%rbx, %rbx
	je	.LBB0_30
# %bb.32:
	movq	%rbx, %rdx
	movl	$1, %esi
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	movq	%rax, %rdi
	movq	%r15, %rcx
	callq	fread@PLT
	cmpq	%rbx, %rax
	jne	.LBB0_196
# %bb.33:
	movq	%r15, %rdi
	callq	fclose@PLT
	cmpq	$64, %rbx
	movq	32(%rsp), %rsi                  # 8-byte Reload
	jb	.LBB0_31
# %bb.34:
	cmpl	$1179403647, (%rsi)             # imm = 0x464C457F
	jne	.LBB0_31
# %bb.35:
	cmpb	$2, 4(%rsi)
	jne	.LBB0_197
# %bb.36:
	cmpb	$1, 5(%rsi)
	jne	.LBB0_197
# %bb.37:
	cmpw	$1, 16(%rsi)
	jne	.LBB0_198
# %bb.38:
	cmpw	$183, 18(%rsi)
	jne	.LBB0_198
# %bb.39:
	movzwl	58(%rsi), %r13d
	cmpq	$63, %r13
	jbe	.LBB0_199
# %bb.40:
	movzwl	60(%rsi), %r12d
	movzwl	62(%rsi), %eax
	cmpw	%r12w, %ax
	jae	.LBB0_200
# %bb.41:
	movq	%rbx, %rdi
	movl	40(%rsi), %ebx
	movl	44(%rsi), %r14d
	shlq	$32, %r14
	leaq	(%r14,%rbx), %rcx
	movq	%r12, %rdx
	imulq	%r13, %rdx
	addq	%rcx, %rdx
	cmpq	%rdi, %rdx
	ja	.LBB0_201
# %bb.42:
	imulq	%r13, %rax
	leaq	(%rax,%rcx), %rdx
	addq	$28, %rdx
	cmpq	%rdi, %rdx
	ja	.LBB0_202
# %bb.43:
	addq	%rcx, %rax
	leaq	32(%rax), %rcx
	cmpq	%rdi, %rcx
	ja	.LBB0_203
# %bb.44:
	leaq	36(%rax), %rcx
	cmpq	%rdi, %rcx
	ja	.LBB0_204
# %bb.45:
	movq	%rbp, 24(%rsp)                  # 8-byte Spill
	leaq	40(%rax), %rcx
	cmpq	%rdi, %rcx
	ja	.LBB0_205
# %bb.46:
	movq	24(%rsi,%rax), %r15
	movq	32(%rsi,%rax), %rbp
	leaq	(%r15,%rbp), %rax
	cmpq	%rdi, %rax
	ja	.LBB0_206
# %bb.47:
	movl	$88, %esi
	movq	%r12, %rdi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_207
# %bb.48:
	movq	32(%rsp), %r8                   # 8-byte Reload
	addq	%r8, %r15
	movq	%r12, 88(%rsp)                  # 8-byte Spill
	imulq	$88, %r12, %rdx
	leaq	(%r14,%rbx), %r12
	addq	$64, %r12
	xorl	%r14d, %r14d
	movq	40(%rsp), %r10                  # 8-byte Reload
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	movq	%rdx, 104(%rsp)                 # 8-byte Spill
	jmp	.LBB0_49
	.p2align	4
.LBB0_51:                               #   in Loop: Header=BB0_49 Depth=1
	addq	$88, %r14
	addq	%r13, %r12
	movq	104(%rsp), %rdx                 # 8-byte Reload
	cmpq	%r14, %rdx
	je	.LBB0_52
.LBB0_49:                               # =>This Inner Loop Header: Depth=1
	leaq	-60(%r12), %rcx
	cmpq	%r10, %rcx
	ja	.LBB0_50
# %bb.53:                               #   in Loop: Header=BB0_49 Depth=1
	movl	-64(%r8,%r12), %ebx
	movq	%rbp, %rdx
	subq	%rbx, %rdx
	jbe	.LBB0_208
# %bb.54:                               #   in Loop: Header=BB0_49 Depth=1
	addq	%r15, %rbx
	movq	%rbx, %rdi
	xorl	%esi, %esi
	callq	memchr@PLT
	testq	%rax, %rax
	je	.LBB0_209
# %bb.55:                               #   in Loop: Header=BB0_49 Depth=1
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rbx, (%rax,%r14)
	leaq	-56(%r12), %rcx
	movq	40(%rsp), %r10                  # 8-byte Reload
	cmpq	%r10, %rcx
	movq	32(%rsp), %r8                   # 8-byte Reload
	ja	.LBB0_210
# %bb.56:                               #   in Loop: Header=BB0_49 Depth=1
	movl	-60(%r8,%r12), %r9d
	movl	%r9d, 8(%rax,%r14)
	leaq	-52(%r12), %rcx
	cmpq	%r10, %rcx
	ja	.LBB0_211
# %bb.57:                               #   in Loop: Header=BB0_49 Depth=1
	leaq	-48(%r12), %rcx
	cmpq	%r10, %rcx
	ja	.LBB0_212
# %bb.58:                               #   in Loop: Header=BB0_49 Depth=1
	movl	-56(%r8,%r12), %ecx
	movl	-52(%r8,%r12), %edx
	shlq	$32, %rdx
	orq	%rcx, %rdx
	movq	%rdx, 16(%rax,%r14)
	leaq	-36(%r12), %rdx
	cmpq	%r10, %rdx
	ja	.LBB0_213
# %bb.59:                               #   in Loop: Header=BB0_49 Depth=1
	leaq	-32(%r12), %rdx
	cmpq	%r10, %rdx
	ja	.LBB0_214
# %bb.60:                               #   in Loop: Header=BB0_49 Depth=1
	movq	-40(%r8,%r12), %rdx
	movq	%rdx, 24(%rax,%r14)
	leaq	-28(%r12), %rsi
	cmpq	%r10, %rsi
	ja	.LBB0_215
# %bb.61:                               #   in Loop: Header=BB0_49 Depth=1
	leaq	-24(%r12), %rsi
	cmpq	%r10, %rsi
	ja	.LBB0_216
# %bb.62:                               #   in Loop: Header=BB0_49 Depth=1
	movq	-32(%r8,%r12), %rsi
	movq	%rsi, 32(%rax,%r14)
	leaq	-20(%r12), %rdi
	cmpq	%r10, %rdi
	ja	.LBB0_217
# %bb.63:                               #   in Loop: Header=BB0_49 Depth=1
	movl	-24(%r8,%r12), %edi
	movl	%edi, 40(%rax,%r14)
	leaq	-16(%r12), %rdi
	cmpq	%r10, %rdi
	ja	.LBB0_218
# %bb.64:                               #   in Loop: Header=BB0_49 Depth=1
	movl	-20(%r8,%r12), %edi
	movl	%edi, 44(%rax,%r14)
	leaq	-12(%r12), %rdi
	cmpq	%r10, %rdi
	ja	.LBB0_219
# %bb.65:                               #   in Loop: Header=BB0_49 Depth=1
	leaq	-8(%r12), %rdi
	cmpq	%r10, %rdi
	ja	.LBB0_220
# %bb.66:                               #   in Loop: Header=BB0_49 Depth=1
	movq	-16(%r8,%r12), %rdi
	movq	%rdi, 48(%rax,%r14)
	leaq	-4(%r12), %rdi
	cmpq	%r10, %rdi
	ja	.LBB0_221
# %bb.67:                               #   in Loop: Header=BB0_49 Depth=1
	cmpq	%r10, %r12
	ja	.LBB0_222
# %bb.68:                               #   in Loop: Header=BB0_49 Depth=1
	movq	-8(%r8,%r12), %rdi
	movq	%rdi, 56(%rax,%r14)
	shrl	%ecx
	andl	$1, %ecx
	movl	%ecx, 80(%rax,%r14)
	cmpl	$8, %r9d
	je	.LBB0_51
# %bb.69:                               #   in Loop: Header=BB0_49 Depth=1
	addq	%rdx, %rsi
	cmpq	%r10, %rsi
	jbe	.LBB0_51
# %bb.70:
	leaq	.L.str.25(%rip), %rsi
	movq	24(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB0_52:
	xorl	%ebx, %ebx
	movq	88(%rsp), %rcx                  # 8-byte Reload
	.p2align	4
.LBB0_72:                               # =>This Inner Loop Header: Depth=1
	cmpl	$2, 8(%rax,%rbx)
	je	.LBB0_73
# %bb.71:                               #   in Loop: Header=BB0_72 Depth=1
	addq	$88, %rbx
	cmpq	%rbx, %rdx
	jne	.LBB0_72
# %bb.235:
	leaq	.L.str.32(%rip), %rsi
	movq	24(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB0_73:
	movl	40(%rax,%rbx), %edx
	cmpl	%edx, %ecx
	jbe	.LBB0_223
# %bb.74:
	movq	56(%rax,%rbx), %r15
	testq	%r15, %r15
	je	.LBB0_224
# %bb.75:
	imulq	$88, %rdx, %rcx
	movq	24(%rax,%rcx), %r12
	movq	32(%rax,%rcx), %r14
	leaq	(%r14,%r12), %rcx
	cmpq	%r10, %rcx
	ja	.LBB0_225
# %bb.76:
	movq	32(%rax,%rbx), %r13
	movq	%r13, %rax
	orq	%r15, %rax
	shrq	$32, %rax
	je	.LBB0_77
# %bb.78:
	movq	%r13, %rax
	xorl	%edx, %edx
	divq	%r15
	jmp	.LBB0_79
.LBB0_77:
	movl	%r13d, %eax
	xorl	%edx, %edx
	divl	%r15d
                                        # kill: def $eax killed $eax def $rax
.LBB0_79:
	cmpq	%r13, %r15
	movl	$1, %edi
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	cmovbeq	%rax, %rdi
	movl	$40, %esi
	callq	calloc@PLT
	movq	%rax, 112(%rsp)                 # 8-byte Spill
	testq	%rax, %rax
	je	.LBB0_226
# %bb.80:
	movq	%r15, 144(%rsp)                 # 8-byte Spill
	movq	%r13, 168(%rsp)                 # 8-byte Spill
	cmpq	%r13, %r15
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	40(%rsp), %rdx                  # 8-byte Reload
	ja	.LBB0_91
# %bb.81:
	movq	%rcx, %r15
	addq	%r12, %r15
	movq	24(%r9,%rbx), %r12
	movq	112(%rsp), %rax                 # 8-byte Reload
	leaq	32(%rax), %r13
	addq	$24, %r12
	xorl	%ebp, %ebp
	.p2align	4
.LBB0_82:                               # =>This Inner Loop Header: Depth=1
	leaq	-20(%r12), %rax
	cmpq	%rdx, %rax
	ja	.LBB0_227
# %bb.83:                               #   in Loop: Header=BB0_82 Depth=1
	movl	-24(%rcx,%r12), %ebx
	movq	%r14, %rdx
	subq	%rbx, %rdx
	jbe	.LBB0_228
# %bb.84:                               #   in Loop: Header=BB0_82 Depth=1
	addq	%r15, %rbx
	movq	%rbx, %rdi
	xorl	%esi, %esi
	callq	memchr@PLT
	testq	%rax, %rax
	je	.LBB0_229
# %bb.85:                               #   in Loop: Header=BB0_82 Depth=1
	movq	%rbx, -32(%r13)
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movzbl	-20(%rcx,%r12), %eax
	movb	%al, (%r13)
	leaq	-16(%r12), %rax
	movq	40(%rsp), %rdx                  # 8-byte Reload
	cmpq	%rdx, %rax
	ja	.LBB0_230
# %bb.86:                               #   in Loop: Header=BB0_82 Depth=1
	movzwl	-18(%rcx,%r12), %eax
	movw	%ax, -24(%r13)
	leaq	-12(%r12), %rax
	cmpq	%rdx, %rax
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	48(%rsp), %rsi                  # 8-byte Reload
	ja	.LBB0_231
# %bb.87:                               #   in Loop: Header=BB0_82 Depth=1
	leaq	-8(%r12), %rax
	cmpq	%rdx, %rax
	ja	.LBB0_232
# %bb.88:                               #   in Loop: Header=BB0_82 Depth=1
	movq	-16(%rcx,%r12), %rax
	movq	%rax, -16(%r13)
	leaq	-4(%r12), %rax
	cmpq	%rdx, %rax
	ja	.LBB0_233
# %bb.89:                               #   in Loop: Header=BB0_82 Depth=1
	cmpq	%rdx, %r12
	ja	.LBB0_234
# %bb.90:                               #   in Loop: Header=BB0_82 Depth=1
	movq	-8(%rcx,%r12), %rax
	movq	%rax, -8(%r13)
	incq	%rbp
	addq	$40, %r13
	addq	144(%rsp), %r12                 # 8-byte Folded Reload
	cmpq	%rsi, %rbp
	jb	.LBB0_82
.LBB0_91:
	movq	88(%rsp), %rbx                  # 8-byte Reload
	cmpw	$2, %bx
	jb	.LBB0_92
# %bb.103:
	movq	104(%rsp), %rax                 # 8-byte Reload
	addq	$-88, %rax
	xorl	%ecx, %ecx
	movl	$1, %edx
	xorl	%r10d, %r10d
	xorl	%r15d, %r15d
	jmp	.LBB0_104
	.p2align	4
.LBB0_109:                              #   in Loop: Header=BB0_104 Depth=1
	movq	%r15, 152(%r9,%rcx)
	movq	56(%rsp), %rsi                  # 8-byte Reload
	addq	%r15, %rsi
	movq	%rsi, 160(%r9,%rcx)
	addq	120(%r9,%rcx), %r15
	cmpq	%r10, %r15
	cmovaq	%r15, %r10
.LBB0_110:                              #   in Loop: Header=BB0_104 Depth=1
	addq	$88, %rcx
	cmpq	%rcx, %rax
	je	.LBB0_111
.LBB0_104:                              # =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%r9,%rcx)
	je	.LBB0_110
# %bb.105:                              #   in Loop: Header=BB0_104 Depth=1
	cmpl	$8, 96(%r9,%rcx)
	je	.LBB0_110
# %bb.106:                              #   in Loop: Header=BB0_104 Depth=1
	movq	136(%r9,%rcx), %rsi
	cmpq	$2, %rsi
	cmovbq	%rdx, %rsi
	jb	.LBB0_109
# %bb.107:                              #   in Loop: Header=BB0_104 Depth=1
	leaq	-1(%rsi), %rdi
	testq	%rdi, %rsi
	jne	.LBB0_236
# %bb.108:                              #   in Loop: Header=BB0_104 Depth=1
	leaq	(%r15,%rsi), %rdi
	decq	%rdi
	negq	%rsi
	andq	%rdi, %rsi
	movq	%rsi, %r15
	jmp	.LBB0_109
.LBB0_92:
	xorl	%r10d, %r10d
	movq	56(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 64(%rsp)                  # 8-byte Spill
	xorl	%r15d, %r15d
	movq	%rax, 120(%rsp)                 # 8-byte Spill
	jmp	.LBB0_101
.LBB0_111:
	xorl	%ecx, %ecx
	movl	$1, %edx
	movq	$0, 64(%rsp)                    # 8-byte Folded Spill
	movq	$0, 80(%rsp)                    # 8-byte Folded Spill
	xorl	%esi, %esi
	jmp	.LBB0_93
	.p2align	4
.LBB0_98:                               #   in Loop: Header=BB0_93 Depth=1
	movq	%r15, 152(%r9,%rcx)
	movq	56(%rsp), %rdi                  # 8-byte Reload
	addq	%r15, %rdi
	movq	%rdi, 160(%r9,%rcx)
	testl	%esi, %esi
	movq	64(%rsp), %rsi                  # 8-byte Reload
	cmoveq	%rdi, %rsi
	movq	%rsi, 64(%rsp)                  # 8-byte Spill
	movq	120(%r9,%rcx), %rsi
	addq	%rsi, %rdi
	movq	%rdi, 80(%rsp)                  # 8-byte Spill
	addq	%rsi, %r15
	movl	$1, %esi
.LBB0_99:                               #   in Loop: Header=BB0_93 Depth=1
	addq	$88, %rcx
	cmpq	%rcx, %rax
	je	.LBB0_100
.LBB0_93:                               # =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%r9,%rcx)
	je	.LBB0_99
# %bb.94:                               #   in Loop: Header=BB0_93 Depth=1
	cmpl	$8, 96(%r9,%rcx)
	jne	.LBB0_99
# %bb.95:                               #   in Loop: Header=BB0_93 Depth=1
	movq	136(%r9,%rcx), %rdi
	cmpq	$2, %rdi
	cmovbq	%rdx, %rdi
	jb	.LBB0_98
# %bb.96:                               #   in Loop: Header=BB0_93 Depth=1
	leaq	-1(%rdi), %r8
	testq	%r8, %rdi
	jne	.LBB0_236
# %bb.97:                               #   in Loop: Header=BB0_93 Depth=1
	leaq	(%r15,%rdi), %r8
	decq	%r8
	negq	%rdi
	andq	%r8, %rdi
	movq	%rdi, %r15
	jmp	.LBB0_98
.LBB0_100:
	movq	56(%rsp), %rax                  # 8-byte Reload
	leaq	(%r15,%rax), %rcx
	testl	%esi, %esi
	movq	64(%rsp), %rax                  # 8-byte Reload
	cmoveq	%rcx, %rax
	movq	%rax, 64(%rsp)                  # 8-byte Spill
	movq	80(%rsp), %rax                  # 8-byte Reload
	movq	%rcx, 120(%rsp)                 # 8-byte Spill
	cmoveq	%rcx, %rax
.LBB0_101:
	movq	%rax, 80(%rsp)                  # 8-byte Spill
	testq	%r10, %r10
	je	.LBB0_102
# %bb.112:
	movl	$1, %esi
	movq	%r10, 72(%rsp)                  # 8-byte Spill
	movq	%r10, %rdi
	callq	calloc@PLT
	testq	%rax, %rax
	je	.LBB0_237
# %bb.113:
	movq	%rax, %rbp
	cmpw	$2, %bx
	movq	32(%rsp), %r8                   # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	48(%rsp), %r10                  # 8-byte Reload
	movq	72(%rsp), %r11                  # 8-byte Reload
	jb	.LBB0_120
# %bb.114:
	movq	104(%rsp), %rax                 # 8-byte Reload
	leaq	-88(%rax), %rbx
	xorl	%r14d, %r14d
	jmp	.LBB0_115
.LBB0_159:                              #   in Loop: Header=BB0_115 Depth=1
	addq	%rbp, %rdi
	movq	112(%r9,%r14), %rsi
	addq	%r8, %rsi
	callq	memcpy@PLT
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	32(%rsp), %r8                   # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	48(%rsp), %r10                  # 8-byte Reload
	movq	72(%rsp), %r11                  # 8-byte Reload
	.p2align	4
.LBB0_160:                              #   in Loop: Header=BB0_115 Depth=1
	addq	$88, %r14
	cmpq	%r14, %rbx
	je	.LBB0_120
.LBB0_115:                              # =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%r9,%r14)
	je	.LBB0_160
# %bb.116:                              #   in Loop: Header=BB0_115 Depth=1
	cmpl	$8, 96(%r9,%r14)
	je	.LBB0_160
# %bb.117:                              #   in Loop: Header=BB0_115 Depth=1
	movq	120(%r9,%r14), %rdx
	testq	%rdx, %rdx
	je	.LBB0_160
# %bb.118:                              #   in Loop: Header=BB0_115 Depth=1
	movq	152(%r9,%r14), %rdi
	leaq	(%rdi,%rdx), %rax
	cmpq	%r11, %rax
	jbe	.LBB0_159
# %bb.119:
	callq	main.cold.17
.LBB0_120:
	movq	%r15, 160(%rsp)                 # 8-byte Spill
	xorl	%eax, %eax
	movq	%rbp, 128(%rsp)                 # 8-byte Spill
	jmp	.LBB0_121
	.p2align	4
.LBB0_156:                              #   in Loop: Header=BB0_121 Depth=1
	movq	176(%rsp), %rax                 # 8-byte Reload
	incq	%rax
	movq	88(%rsp), %r12                  # 8-byte Reload
	cmpq	%r12, %rax
	je	.LBB0_157
.LBB0_121:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_128 Depth 2
	movq	%rax, 176(%rsp)                 # 8-byte Spill
	imulq	$88, %rax, %rsi
	cmpl	$4, 8(%r9,%rsi)
	jne	.LBB0_156
# %bb.122:                              #   in Loop: Header=BB0_121 Depth=1
	addq	%r9, %rsi
	movl	44(%rsi), %eax
	cmpl	%eax, 88(%rsp)                  # 4-byte Folded Reload
	jbe	.LBB0_238
# %bb.123:                              #   in Loop: Header=BB0_121 Depth=1
	imulq	$88, %rax, %rax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	cmpl	$0, 80(%r9,%rax)
	je	.LBB0_156
# %bb.124:                              #   in Loop: Header=BB0_121 Depth=1
	movq	56(%rsi), %rax
	testq	%rax, %rax
	je	.LBB0_126
# %bb.125:                              #   in Loop: Header=BB0_121 Depth=1
	cmpq	$24, %rax
	jne	.LBB0_239
.LBB0_126:                              #   in Loop: Header=BB0_121 Depth=1
	movq	32(%rsi), %rcx
	movq	%rcx, %rax
	movabsq	$-6148914691236517205, %rdx     # imm = 0xAAAAAAAAAAAAAAAB
	mulq	%rdx
	cmpq	$24, %rcx
	jb	.LBB0_156
# %bb.127:                              #   in Loop: Header=BB0_121 Depth=1
	movq	%rdx, %r12
	addq	%r9, 24(%rsp)                   # 8-byte Folded Spill
	shrq	$4, %r12
	movq	24(%rsi), %r14
	addq	$24, %r14
	jmp	.LBB0_128
	.p2align	4
.LBB0_151:                              #   in Loop: Header=BB0_128 Depth=2
	andl	$31, %edx
	movl	%ecx, %esi
	andl	$28, %esi
	leal	(%rdx,%rsi,8), %edx
	movb	%dl, (%rbp,%rax)
	movl	%ecx, %edx
	shrl	$5, %edx
	movb	%dl, 1(%rbp,%rax)
	movl	%ecx, %edx
	shrl	$13, %edx
	movb	%dl, 2(%rbp,%rax)
	shlb	$5, %cl
	andb	$96, %cl
	orb	$16, %cl
.LBB0_155:                              #   in Loop: Header=BB0_128 Depth=2
	movb	%cl, 3(%rbp,%rax)
	addq	$24, %r14
	decq	%r12
	je	.LBB0_156
.LBB0_128:                              #   Parent Loop BB0_121 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	leaq	-20(%r14), %rax
	cmpq	%rdi, %rax
	ja	.LBB0_240
# %bb.129:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	-16(%r14), %rax
	cmpq	%rdi, %rax
	ja	.LBB0_241
# %bb.130:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	-12(%r14), %rax
	cmpq	%rdi, %rax
	ja	.LBB0_242
# %bb.131:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	-8(%r14), %rax
	cmpq	%rdi, %rax
	ja	.LBB0_243
# %bb.132:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	-4(%r14), %rax
	cmpq	%rdi, %rax
	ja	.LBB0_244
# %bb.133:                              #   in Loop: Header=BB0_128 Depth=2
	cmpq	%rdi, %r14
	ja	.LBB0_245
# %bb.134:                              #   in Loop: Header=BB0_128 Depth=2
	movl	-12(%r8,%r14), %eax
	cmpq	%rax, %r10
	jbe	.LBB0_246
# %bb.135:                              #   in Loop: Header=BB0_128 Depth=2
	movq	-24(%r8,%r14), %r13
	movl	-16(%r8,%r14), %r15d
	movq	-8(%r8,%r14), %rbx
	leaq	(%rax,%rax,4), %rcx
	movq	112(%rsp), %rdx                 # 8-byte Reload
	leaq	(%rdx,%rcx,8), %rax
	movzwl	8(%rdx,%rcx,8), %ecx
	cmpl	$65521, %ecx                    # imm = 0xFFF1
	je	.LBB0_142
# %bb.136:                              #   in Loop: Header=BB0_128 Depth=2
	testl	%ecx, %ecx
	jne	.LBB0_143
# %bb.137:                              #   in Loop: Header=BB0_128 Depth=2
	movq	(%rax), %rbp
	movq	%rbp, %rdi
	leaq	.L.str.45(%rip), %rsi
	callq	strcmp@PLT
	movq	72(%rsp), %r11                  # 8-byte Reload
	movq	48(%rsp), %r10                  # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	32(%rsp), %r8                   # 8-byte Reload
	movq	64(%rsp), %rcx                  # 8-byte Reload
	testl	%eax, %eax
	je	.LBB0_146
# %bb.138:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rbp, %rdi
	leaq	.L.str.46(%rip), %rsi
	callq	strcmp@PLT
	movq	72(%rsp), %r11                  # 8-byte Reload
	movq	48(%rsp), %r10                  # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	32(%rsp), %r8                   # 8-byte Reload
	movq	80(%rsp), %rcx                  # 8-byte Reload
	testl	%eax, %eax
	je	.LBB0_146
# %bb.139:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rbp, %rdi
	leaq	.L.str.47(%rip), %rsi
	callq	strcmp@PLT
	movq	72(%rsp), %r11                  # 8-byte Reload
	movq	48(%rsp), %r10                  # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	32(%rsp), %r8                   # 8-byte Reload
	movq	56(%rsp), %rcx                  # 8-byte Reload
	testl	%eax, %eax
	je	.LBB0_146
# %bb.140:                              #   in Loop: Header=BB0_128 Depth=2
	movq	%rbp, %rdi
	leaq	.L.str.48(%rip), %rsi
	callq	strcmp@PLT
	movq	72(%rsp), %r11                  # 8-byte Reload
	movq	48(%rsp), %r10                  # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	16(%rsp), %r9                   # 8-byte Reload
	movq	32(%rsp), %r8                   # 8-byte Reload
	movq	120(%rsp), %rcx                 # 8-byte Reload
	testl	%eax, %eax
	je	.LBB0_146
	jmp	.LBB0_141
	.p2align	4
.LBB0_142:                              #   in Loop: Header=BB0_128 Depth=2
	movq	16(%rax), %rcx
	jmp	.LBB0_146
	.p2align	4
.LBB0_143:                              #   in Loop: Header=BB0_128 Depth=2
	cmpw	%cx, 88(%rsp)                   # 2-byte Folded Reload
	jbe	.LBB0_247
# %bb.144:                              #   in Loop: Header=BB0_128 Depth=2
	imulq	$88, %rcx, %rdx
	cmpl	$0, 80(%r9,%rdx)
	je	.LBB0_248
# %bb.145:                              #   in Loop: Header=BB0_128 Depth=2
	addq	%r9, %rdx
	movq	16(%rax), %rcx
	addq	72(%rdx), %rcx
.LBB0_146:                              #   in Loop: Header=BB0_128 Depth=2
	addq	%rbx, %rcx
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	64(%rax), %rax
	addq	%r13, %rax
	cmpl	$257, %r15d                     # imm = 0x101
	je	.LBB0_152
# %bb.147:                              #   in Loop: Header=BB0_128 Depth=2
	cmpl	$274, %r15d                     # imm = 0x112
	movq	128(%rsp), %rbp                 # 8-byte Reload
	jne	.LBB0_254
# %bb.148:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	4(%rax), %rdx
	cmpq	%r11, %rdx
	ja	.LBB0_249
# %bb.149:                              #   in Loop: Header=BB0_128 Depth=2
	movq	24(%rsp), %rdx                  # 8-byte Reload
	addq	72(%rdx), %r13
	subq	%r13, %rcx
	leaq	-1048576(%rcx), %rdx
	cmpq	$-2097153, %rdx                 # imm = 0xFFDFFFFF
	jbe	.LBB0_250
# %bb.150:                              #   in Loop: Header=BB0_128 Depth=2
	movl	(%rbp,%rax), %edx
	movl	%edx, %esi
	andl	$-1627389952, %esi              # imm = 0x9F000000
	cmpl	$268435456, %esi                # imm = 0x10000000
	je	.LBB0_151
	jmp	.LBB0_251
	.p2align	4
.LBB0_152:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	8(%rax), %rdx
	cmpq	%r11, %rdx
	movq	128(%rsp), %rbp                 # 8-byte Reload
	ja	.LBB0_252
# %bb.153:                              #   in Loop: Header=BB0_128 Depth=2
	leaq	4(%rax), %rdx
	cmpq	%r11, %rdx
	ja	.LBB0_253
# %bb.154:                              #   in Loop: Header=BB0_128 Depth=2
	movb	%cl, (%rbp,%rax)
	movb	%ch, 1(%rbp,%rax)
	movl	%ecx, %esi
	shrl	$16, %esi
	movb	%sil, 2(%rbp,%rax)
	movl	%ecx, %esi
	shrl	$24, %esi
	movb	%sil, 3(%rbp,%rax)
	movq	%rcx, %rsi
	shrq	$32, %rsi
	movb	%sil, 4(%rbp,%rax)
	movq	%rcx, %rsi
	shrq	$40, %rsi
	movb	%sil, 5(%rbp,%rax)
	movq	%rcx, %rsi
	shrq	$48, %rsi
	movb	%sil, 6(%rbp,%rax)
	shrq	$56, %rcx
	movq	%rdx, %rax
	jmp	.LBB0_155
.LBB0_157:
	leaq	.L.str.53(%rip), %rsi
	movq	96(%rsp), %rdi                  # 8-byte Reload
	callq	fopen@PLT
	testq	%rax, %rax
	je	.LBB0_158
# %bb.161:
	movq	%rax, %r15
	movl	$1, %esi
	movq	%rbp, %rdi
	movq	72(%rsp), %rbx                  # 8-byte Reload
	movq	%rbx, %rdx
	movq	%rax, %rcx
	callq	fwrite@PLT
	cmpq	%rbx, %rax
	movq	136(%rsp), %rbx                 # 8-byte Reload
	jne	.LBB0_255
# %bb.162:
	movq	%r15, %rdi
	callq	fclose@PLT
	testq	%rbx, %rbx
	je	.LBB0_185
# %bb.163:
	leaq	.L.str.55(%rip), %rsi
	movq	%rbx, %rdi
	callq	fopen@PLT
	testq	%rax, %rax
	je	.LBB0_256
# %bb.164:
	movq	%rax, %r13
	movq	56(%rsp), %rbx                  # 8-byte Reload
	movq	72(%rsp), %r14                  # 8-byte Reload
	leaq	(%r14,%rbx), %r15
	leaq	.L.str.56(%rip), %rdi
	movl	$30, %esi
	movl	$1, %edx
	movq	%rax, %rcx
	callq	fwrite@PLT
	leaq	.L.str.57(%rip), %rsi
	movq	%r13, %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	leaq	.L.str.58(%rip), %rsi
	movq	%r13, %rdi
	movq	%r14, %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	leaq	.L.str.59(%rip), %rsi
	movq	%r13, %rdi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	leaq	.L.str.60(%rip), %rsi
	movq	%r13, %rdi
	movq	160(%rsp), %rdx                 # 8-byte Reload
	xorl	%eax, %eax
	callq	fprintf@PLT
	leaq	.L.str.61(%rip), %rsi
	movq	%r13, %rdi
	movq	64(%rsp), %rbx                  # 8-byte Reload
	movq	%rbx, %rdx
	movq	80(%rsp), %rcx                  # 8-byte Reload
	xorl	%eax, %eax
	callq	fprintf@PLT
	cmpq	%r15, %rbx
	leaq	.L.str.64(%rip), %r14
	leaq	.L.str.63(%rip), %rbx
	movq	%rbx, %rdx
	cmovbq	%r14, %rdx
	leaq	.L.str.62(%rip), %rsi
	movq	%r13, %rdi
	xorl	%eax, %eax
	callq	fprintf@PLT
	cmpw	$2, %r12w
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	104(%rsp), %rcx                 # 8-byte Reload
	jb	.LBB0_175
# %bb.165:
	addq	$-88, %rcx
	leaq	.L.str.65(%rip), %r15
	xorl	%r12d, %r12d
	movq	%rcx, %rbp
	jmp	.LBB0_166
	.p2align	4
.LBB0_169:                              #   in Loop: Header=BB0_166 Depth=1
	addq	$88, %r12
	cmpq	%r12, %rcx
	je	.LBB0_170
.LBB0_166:                              # =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%rax,%r12)
	je	.LBB0_169
# %bb.167:                              #   in Loop: Header=BB0_166 Depth=1
	cmpl	$8, 96(%rax,%r12)
	je	.LBB0_169
# %bb.168:                              #   in Loop: Header=BB0_166 Depth=1
	movq	160(%rax,%r12), %rcx
	movq	152(%rax,%r12), %r8
	movq	88(%rax,%r12), %rdx
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	120(%rax,%r12), %r9
	movq	%rbx, (%rsp)
	movq	%r13, %rdi
	movq	%r15, %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	movq	%rbp, %rcx
	movq	16(%rsp), %rax                  # 8-byte Reload
	jmp	.LBB0_169
.LBB0_170:
	leaq	.L.str.65(%rip), %r15
	xorl	%ebx, %ebx
	jmp	.LBB0_171
	.p2align	4
.LBB0_174:                              #   in Loop: Header=BB0_171 Depth=1
	addq	$88, %rbx
	cmpq	%rbx, %rcx
	je	.LBB0_175
.LBB0_171:                              # =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%rax,%rbx)
	je	.LBB0_174
# %bb.172:                              #   in Loop: Header=BB0_171 Depth=1
	cmpl	$8, 96(%rax,%rbx)
	jne	.LBB0_174
# %bb.173:                              #   in Loop: Header=BB0_171 Depth=1
	movq	160(%rax,%rbx), %rcx
	movq	152(%rax,%rbx), %r8
	movq	88(%rax,%rbx), %rdx
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	120(%rax,%rbx), %r9
	movq	%r14, (%rsp)
	movq	%r13, %rdi
	movq	%r15, %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	movq	%rbp, %rcx
	movq	16(%rsp), %rax                  # 8-byte Reload
	jmp	.LBB0_174
.LBB0_175:
	leaq	.L.str.67(%rip), %r12
	leaq	.L.str.47(%rip), %rdx
	leaq	.L.str.66(%rip), %r15
	movq	%r13, %rdi
	movq	%r12, %rsi
	movq	56(%rsp), %rcx                  # 8-byte Reload
	movq	%r15, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	fprintf@PLT
	leaq	.L.str.48(%rip), %rdx
	movq	%r13, %rdi
	movq	%r12, %rsi
	movq	120(%rsp), %rcx                 # 8-byte Reload
	movq	%r15, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	fprintf@PLT
	leaq	.L.str.45(%rip), %rdx
	movq	%r13, %rdi
	movq	%r12, %rsi
	movq	64(%rsp), %rcx                  # 8-byte Reload
	movq	%r15, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	fprintf@PLT
	leaq	.L.str.46(%rip), %rdx
	movq	%r13, %rdi
	movq	%r12, %rsi
	movq	88(%rsp), %r12                  # 8-byte Reload
	movq	80(%rsp), %rcx                  # 8-byte Reload
	movq	%r15, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	fprintf@PLT
	movq	16(%rsp), %rcx                  # 8-byte Reload
	movq	168(%rsp), %rax                 # 8-byte Reload
	cmpq	%rax, 144(%rsp)                 # 8-byte Folded Reload
	movq	48(%rsp), %rsi                  # 8-byte Reload
	movq	128(%rsp), %rbp                 # 8-byte Reload
	jbe	.LBB0_176
.LBB0_184:
	movq	%r13, %rdi
	callq	fclose@PLT
.LBB0_185:
	movq	%rbp, %rdi
	callq	free@PLT
	movq	112(%rsp), %rdi                 # 8-byte Reload
	callq	free@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	xorl	%eax, %eax
.LBB0_186:
	addq	$184, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.LBB0_176:
	movq	112(%rsp), %rbx                 # 8-byte Reload
	addq	$24, %rbx
	leaq	.L.str.67(%rip), %r15
	xorl	%r14d, %r14d
	jmp	.LBB0_177
	.p2align	4
.LBB0_183:                              #   in Loop: Header=BB0_177 Depth=1
	incq	%r14
	addq	$40, %rbx
	cmpq	%rsi, %r14
	jae	.LBB0_184
.LBB0_177:                              # =>This Inner Loop Header: Depth=1
	movq	-24(%rbx), %rdx
	testq	%rdx, %rdx
	je	.LBB0_183
# %bb.178:                              #   in Loop: Header=BB0_177 Depth=1
	cmpb	$0, (%rdx)
	je	.LBB0_183
# %bb.179:                              #   in Loop: Header=BB0_177 Depth=1
	movzwl	-16(%rbx), %eax
	testq	%rax, %rax
	je	.LBB0_183
# %bb.180:                              #   in Loop: Header=BB0_177 Depth=1
	cmpw	%ax, %r12w
	jbe	.LBB0_183
# %bb.181:                              #   in Loop: Header=BB0_177 Depth=1
	imulq	$88, %rax, %rax
	cmpl	$0, 80(%rcx,%rax)
	je	.LBB0_183
# %bb.182:                              #   in Loop: Header=BB0_177 Depth=1
	addq	%rcx, %rax
	movq	-8(%rbx), %rcx
	movq	(%rbx), %r9
	addq	72(%rax), %rcx
	movq	(%rax), %r8
	movq	%r13, %rdi
	movq	%r15, %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	movq	48(%rsp), %rsi                  # 8-byte Reload
	movq	16(%rsp), %rcx                  # 8-byte Reload
	jmp	.LBB0_183
.LBB0_23:
	callq	main.cold.6
	movl	$1, %eax
	jmp	.LBB0_186
.LBB0_17:
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.6(%rip), %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	fprintf@PLT
	movl	$1, %eax
	jmp	.LBB0_186
.LBB0_240:
	callq	main.cold.34
.LBB0_241:
	callq	main.cold.33
.LBB0_242:
	callq	main.cold.32
.LBB0_243:
	callq	main.cold.31
.LBB0_244:
	callq	main.cold.30
.LBB0_245:
	callq	main.cold.29
.LBB0_246:
	callq	main.cold.19
.LBB0_252:
	callq	main.cold.23
.LBB0_249:
	callq	main.cold.26
.LBB0_251:
	callq	main.cold.24
.LBB0_253:
	callq	main.cold.22
.LBB0_250:
	callq	main.cold.25
.LBB0_254:
	movl	%r15d, %edi
	callq	main.cold.27
.LBB0_247:
	callq	main.cold.21
.LBB0_248:
	callq	main.cold.28
.LBB0_222:
	callq	main.cold.41
.LBB0_219:
	callq	main.cold.44
.LBB0_212:
	callq	main.cold.51
.LBB0_220:
	callq	main.cold.43
.LBB0_217:
	callq	main.cold.46
.LBB0_210:
	callq	main.cold.53
.LBB0_211:
	callq	main.cold.52
.LBB0_50:
	callq	main.cold.55
.LBB0_209:
	callq	main.cold.54
.LBB0_215:
	callq	main.cold.48
.LBB0_213:
	callq	main.cold.50
.LBB0_214:
	callq	main.cold.49
.LBB0_216:
	callq	main.cold.47
.LBB0_218:
	callq	main.cold.45
.LBB0_221:
	callq	main.cold.42
.LBB0_208:
	callq	main.cold.7
.LBB0_189:
	movq	%rbx, %rdi
	callq	main.cold.4
.LBB0_227:
	callq	main.cold.15
.LBB0_229:
	callq	main.cold.14
.LBB0_230:
	callq	main.cold.13
.LBB0_231:
	callq	main.cold.12
.LBB0_232:
	callq	main.cold.11
.LBB0_233:
	callq	main.cold.10
.LBB0_234:
	callq	main.cold.9
.LBB0_228:
	callq	main.cold.8
.LBB0_238:
	callq	main.cold.18
.LBB0_141:
	movq	%rbp, %rdi
	callq	main.cold.20
.LBB0_191:
	callq	main.cold.1
.LBB0_188:
	callq	main.cold.3
.LBB0_190:
	callq	main.cold.2
.LBB0_236:
	callq	main.cold.16
.LBB0_239:
	callq	main.cold.35
.LBB0_187:
	callq	main.cold.5
.LBB0_193:
	leaq	.L.str.12(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_197:
	leaq	.L.str.19(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_198:
	leaq	.L.str.20(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_192:
	movq	%rbp, %rdi
	callq	main.cold.62
.LBB0_194:
	leaq	.L.str.13(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_195:
	callq	main.cold.61
.LBB0_30:
	movq	%r15, %rdi
	callq	fclose@PLT
.LBB0_31:
	leaq	.L.str.18(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_196:
	leaq	.L.str.14(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_199:
	leaq	.L.str.21(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_200:
	leaq	.L.str.22(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_201:
	leaq	.L.str.23(%rip), %rsi
	movq	%rbp, %rdi
	callq	die_path
.LBB0_202:
	callq	main.cold.60
.LBB0_203:
	callq	main.cold.59
.LBB0_204:
	callq	main.cold.58
.LBB0_205:
	callq	main.cold.57
.LBB0_206:
	leaq	.L.str.24(%rip), %rsi
	movq	24(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB0_207:
	callq	main.cold.56
.LBB0_223:
	leaq	.L.str.29(%rip), %rsi
	movq	24(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB0_224:
	leaq	.L.str.30(%rip), %rsi
	movq	24(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB0_225:
	leaq	.L.str.31(%rip), %rsi
	movq	24(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB0_226:
	callq	main.cold.40
.LBB0_102:
	callq	main.cold.39
.LBB0_237:
	callq	main.cold.38
.LBB0_158:
	movq	96(%rsp), %rdi                  # 8-byte Reload
	callq	main.cold.37
.LBB0_255:
	leaq	.L.str.54(%rip), %rsi
	movq	96(%rsp), %rdi                  # 8-byte Reload
	callq	die_path
.LBB0_256:
	movq	%rbx, %rdi
	callq	main.cold.36
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
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
	leaq	.L.str.9(%rip), %rsi
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
	leaq	.L.str.15(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end2:
	.size	die_path, .Lfunc_end2-die_path
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.1
	.type	main.cold.1,@function
main.cold.1:                            # @main.cold.1
# %bb.0:
	pushq	%rax
	leaq	.L.str.7(%rip), %rdi
	callq	die
.Lfunc_end3:
	.size	main.cold.1, .Lfunc_end3-main.cold.1
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.2
	.type	main.cold.2,@function
main.cold.2:                            # @main.cold.2
# %bb.0:
	pushq	%rax
	leaq	.L.str.5(%rip), %rdi
	callq	die
.Lfunc_end4:
	.size	main.cold.2, .Lfunc_end4-main.cold.2
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.3
	.type	main.cold.3,@function
main.cold.3:                            # @main.cold.3
# %bb.0:
	pushq	%rax
	leaq	.L.str.3(%rip), %rdi
	callq	die
.Lfunc_end5:
	.size	main.cold.3, .Lfunc_end5-main.cold.3
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.4
	.type	main.cold.4,@function
main.cold.4:                            # @main.cold.4
# %bb.0:
	pushq	%rax
	movq	%rdi, %rdx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.10(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end6:
	.size	main.cold.4, .Lfunc_end6-main.cold.4
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.5
	.type	main.cold.5,@function
main.cold.5:                            # @main.cold.5
# %bb.0:
	pushq	%rax
	leaq	.L.str.1(%rip), %rdi
	callq	die
.Lfunc_end7:
	.size	main.cold.5, .Lfunc_end7-main.cold.5
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.6
	.type	main.cold.6,@function
main.cold.6:                            # @main.cold.6
# %bb.0:
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	leaq	.L.str.8(%rip), %rdi
	pushq	$69
	popq	%rsi
	pushq	$1
	popq	%rdx
	jmp	fwrite@PLT                      # TAILCALL
.Lfunc_end8:
	.size	main.cold.6, .Lfunc_end8-main.cold.6
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.7
	.type	main.cold.7,@function
main.cold.7:                            # @main.cold.7
# %bb.0:
	pushq	%rax
	leaq	.L.str.27(%rip), %rdi
	callq	die
.Lfunc_end9:
	.size	main.cold.7, .Lfunc_end9-main.cold.7
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.8
	.type	main.cold.8,@function
main.cold.8:                            # @main.cold.8
# %bb.0:
	pushq	%rax
	leaq	.L.str.27(%rip), %rdi
	callq	die
.Lfunc_end10:
	.size	main.cold.8, .Lfunc_end10-main.cold.8
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.9
	.type	main.cold.9,@function
main.cold.9:                            # @main.cold.9
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end11:
	.size	main.cold.9, .Lfunc_end11-main.cold.9
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.10
	.type	main.cold.10,@function
main.cold.10:                           # @main.cold.10
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end12:
	.size	main.cold.10, .Lfunc_end12-main.cold.10
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.11
	.type	main.cold.11,@function
main.cold.11:                           # @main.cold.11
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end13:
	.size	main.cold.11, .Lfunc_end13-main.cold.11
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.12
	.type	main.cold.12,@function
main.cold.12:                           # @main.cold.12
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end14:
	.size	main.cold.12, .Lfunc_end14-main.cold.12
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.13
	.type	main.cold.13,@function
main.cold.13:                           # @main.cold.13
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end15:
	.size	main.cold.13, .Lfunc_end15-main.cold.13
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.14
	.type	main.cold.14,@function
main.cold.14:                           # @main.cold.14
# %bb.0:
	pushq	%rax
	leaq	.L.str.28(%rip), %rdi
	callq	die
.Lfunc_end16:
	.size	main.cold.14, .Lfunc_end16-main.cold.14
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.15
	.type	main.cold.15,@function
main.cold.15:                           # @main.cold.15
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end17:
	.size	main.cold.15, .Lfunc_end17-main.cold.15
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.16
	.type	main.cold.16,@function
main.cold.16:                           # @main.cold.16
# %bb.0:
	pushq	%rax
	leaq	.L.str.33(%rip), %rdi
	callq	die
.Lfunc_end18:
	.size	main.cold.16, .Lfunc_end18-main.cold.16
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.17
	.type	main.cold.17,@function
main.cold.17:                           # @main.cold.17
# %bb.0:
	pushq	%rax
	leaq	.L.str.36(%rip), %rdi
	callq	die
.Lfunc_end19:
	.size	main.cold.17, .Lfunc_end19-main.cold.17
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.18
	.type	main.cold.18,@function
main.cold.18:                           # @main.cold.18
# %bb.0:
	pushq	%rax
	leaq	.L.str.37(%rip), %rdi
	callq	die
.Lfunc_end20:
	.size	main.cold.18, .Lfunc_end20-main.cold.18
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.19
	.type	main.cold.19,@function
main.cold.19:                           # @main.cold.19
# %bb.0:
	pushq	%rax
	leaq	.L.str.41(%rip), %rdi
	callq	die
.Lfunc_end21:
	.size	main.cold.19, .Lfunc_end21-main.cold.19
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.20
	.type	main.cold.20,@function
main.cold.20:                           # @main.cold.20
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
.Lfunc_end22:
	.size	main.cold.20, .Lfunc_end22-main.cold.20
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.21
	.type	main.cold.21,@function
main.cold.21:                           # @main.cold.21
# %bb.0:
	pushq	%rax
	leaq	.L.str.43(%rip), %rdi
	callq	die
.Lfunc_end23:
	.size	main.cold.21, .Lfunc_end23-main.cold.21
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.22
	.type	main.cold.22,@function
main.cold.22:                           # @main.cold.22
# %bb.0:
	pushq	%rax
	leaq	.L.str.52(%rip), %rdi
	callq	die
.Lfunc_end24:
	.size	main.cold.22, .Lfunc_end24-main.cold.22
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.23
	.type	main.cold.23,@function
main.cold.23:                           # @main.cold.23
# %bb.0:
	pushq	%rax
	leaq	.L.str.39(%rip), %rdi
	callq	die
.Lfunc_end25:
	.size	main.cold.23, .Lfunc_end25-main.cold.23
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.24
	.type	main.cold.24,@function
main.cold.24:                           # @main.cold.24
# %bb.0:
	pushq	%rax
	leaq	.L.str.51(%rip), %rdi
	callq	die
.Lfunc_end26:
	.size	main.cold.24, .Lfunc_end26-main.cold.24
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.25
	.type	main.cold.25,@function
main.cold.25:                           # @main.cold.25
# %bb.0:
	pushq	%rax
	leaq	.L.str.50(%rip), %rdi
	callq	die
.Lfunc_end27:
	.size	main.cold.25, .Lfunc_end27-main.cold.25
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.26
	.type	main.cold.26,@function
main.cold.26:                           # @main.cold.26
# %bb.0:
	pushq	%rax
	leaq	.L.str.49(%rip), %rdi
	callq	die
.Lfunc_end28:
	.size	main.cold.26, .Lfunc_end28-main.cold.26
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.27
	.type	main.cold.27,@function
main.cold.27:                           # @main.cold.27
# %bb.0:
	pushq	%rax
	movl	%edi, %edx
	movq	stderr@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	.L.str.40(%rip), %rsi
	xorl	%eax, %eax
	callq	fprintf@PLT
	pushq	$1
	popq	%rdi
	callq	exit@PLT
.Lfunc_end29:
	.size	main.cold.27, .Lfunc_end29-main.cold.27
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.28
	.type	main.cold.28,@function
main.cold.28:                           # @main.cold.28
# %bb.0:
	pushq	%rax
	leaq	.L.str.44(%rip), %rdi
	callq	die
.Lfunc_end30:
	.size	main.cold.28, .Lfunc_end30-main.cold.28
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.29
	.type	main.cold.29,@function
main.cold.29:                           # @main.cold.29
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end31:
	.size	main.cold.29, .Lfunc_end31-main.cold.29
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.30
	.type	main.cold.30,@function
main.cold.30:                           # @main.cold.30
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end32:
	.size	main.cold.30, .Lfunc_end32-main.cold.30
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.31
	.type	main.cold.31,@function
main.cold.31:                           # @main.cold.31
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end33:
	.size	main.cold.31, .Lfunc_end33-main.cold.31
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.32
	.type	main.cold.32,@function
main.cold.32:                           # @main.cold.32
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end34:
	.size	main.cold.32, .Lfunc_end34-main.cold.32
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.33
	.type	main.cold.33,@function
main.cold.33:                           # @main.cold.33
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end35:
	.size	main.cold.33, .Lfunc_end35-main.cold.33
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.34
	.type	main.cold.34,@function
main.cold.34:                           # @main.cold.34
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end36:
	.size	main.cold.34, .Lfunc_end36-main.cold.34
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.35
	.type	main.cold.35,@function
main.cold.35:                           # @main.cold.35
# %bb.0:
	pushq	%rax
	leaq	.L.str.38(%rip), %rdi
	callq	die
.Lfunc_end37:
	.size	main.cold.35, .Lfunc_end37-main.cold.35
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.36
	.type	main.cold.36,@function
main.cold.36:                           # @main.cold.36
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end38:
	.size	main.cold.36, .Lfunc_end38-main.cold.36
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.37
	.type	main.cold.37,@function
main.cold.37:                           # @main.cold.37
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end39:
	.size	main.cold.37, .Lfunc_end39-main.cold.37
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.38
	.type	main.cold.38,@function
main.cold.38:                           # @main.cold.38
# %bb.0:
	pushq	%rax
	leaq	.L.str.16(%rip), %rdi
	callq	die
.Lfunc_end40:
	.size	main.cold.38, .Lfunc_end40-main.cold.38
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.39
	.type	main.cold.39,@function
main.cold.39:                           # @main.cold.39
# %bb.0:
	pushq	%rax
	leaq	.L.str.34(%rip), %rdi
	callq	die
.Lfunc_end41:
	.size	main.cold.39, .Lfunc_end41-main.cold.39
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.40
	.type	main.cold.40,@function
main.cold.40:                           # @main.cold.40
# %bb.0:
	pushq	%rax
	leaq	.L.str.16(%rip), %rdi
	callq	die
.Lfunc_end42:
	.size	main.cold.40, .Lfunc_end42-main.cold.40
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.41
	.type	main.cold.41,@function
main.cold.41:                           # @main.cold.41
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end43:
	.size	main.cold.41, .Lfunc_end43-main.cold.41
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.42
	.type	main.cold.42,@function
main.cold.42:                           # @main.cold.42
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end44:
	.size	main.cold.42, .Lfunc_end44-main.cold.42
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.43
	.type	main.cold.43,@function
main.cold.43:                           # @main.cold.43
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end45:
	.size	main.cold.43, .Lfunc_end45-main.cold.43
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.44
	.type	main.cold.44,@function
main.cold.44:                           # @main.cold.44
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end46:
	.size	main.cold.44, .Lfunc_end46-main.cold.44
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.45
	.type	main.cold.45,@function
main.cold.45:                           # @main.cold.45
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end47:
	.size	main.cold.45, .Lfunc_end47-main.cold.45
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.46
	.type	main.cold.46,@function
main.cold.46:                           # @main.cold.46
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end48:
	.size	main.cold.46, .Lfunc_end48-main.cold.46
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.47
	.type	main.cold.47,@function
main.cold.47:                           # @main.cold.47
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end49:
	.size	main.cold.47, .Lfunc_end49-main.cold.47
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.48
	.type	main.cold.48,@function
main.cold.48:                           # @main.cold.48
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end50:
	.size	main.cold.48, .Lfunc_end50-main.cold.48
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.49
	.type	main.cold.49,@function
main.cold.49:                           # @main.cold.49
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end51:
	.size	main.cold.49, .Lfunc_end51-main.cold.49
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.50
	.type	main.cold.50,@function
main.cold.50:                           # @main.cold.50
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end52:
	.size	main.cold.50, .Lfunc_end52-main.cold.50
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.51
	.type	main.cold.51,@function
main.cold.51:                           # @main.cold.51
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end53:
	.size	main.cold.51, .Lfunc_end53-main.cold.51
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.52
	.type	main.cold.52,@function
main.cold.52:                           # @main.cold.52
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end54:
	.size	main.cold.52, .Lfunc_end54-main.cold.52
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.53
	.type	main.cold.53,@function
main.cold.53:                           # @main.cold.53
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end55:
	.size	main.cold.53, .Lfunc_end55-main.cold.53
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.54
	.type	main.cold.54,@function
main.cold.54:                           # @main.cold.54
# %bb.0:
	pushq	%rax
	leaq	.L.str.28(%rip), %rdi
	callq	die
.Lfunc_end56:
	.size	main.cold.54, .Lfunc_end56-main.cold.54
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.55
	.type	main.cold.55,@function
main.cold.55:                           # @main.cold.55
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end57:
	.size	main.cold.55, .Lfunc_end57-main.cold.55
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.56
	.type	main.cold.56,@function
main.cold.56:                           # @main.cold.56
# %bb.0:
	pushq	%rax
	leaq	.L.str.16(%rip), %rdi
	callq	die
.Lfunc_end58:
	.size	main.cold.56, .Lfunc_end58-main.cold.56
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.57
	.type	main.cold.57,@function
main.cold.57:                           # @main.cold.57
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end59:
	.size	main.cold.57, .Lfunc_end59-main.cold.57
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.58
	.type	main.cold.58,@function
main.cold.58:                           # @main.cold.58
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end60:
	.size	main.cold.58, .Lfunc_end60-main.cold.58
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.59
	.type	main.cold.59,@function
main.cold.59:                           # @main.cold.59
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end61:
	.size	main.cold.59, .Lfunc_end61-main.cold.59
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.60
	.type	main.cold.60,@function
main.cold.60:                           # @main.cold.60
# %bb.0:
	pushq	%rax
	leaq	.L.str.26(%rip), %rdi
	callq	die
.Lfunc_end62:
	.size	main.cold.60, .Lfunc_end62-main.cold.60
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.61
	.type	main.cold.61,@function
main.cold.61:                           # @main.cold.61
# %bb.0:
	pushq	%rax
	leaq	.L.str.16(%rip), %rdi
	callq	die
.Lfunc_end63:
	.size	main.cold.61, .Lfunc_end63-main.cold.61
                                        # -- End function
	.p2align	4                               # -- Begin function main.cold.62
	.type	main.cold.62,@function
main.cold.62:                           # @main.cold.62
# %bb.0:
	pushq	%rbx
	movq	%rdi, %rbx
	callq	__errno_location@PLT
	movl	(%rax), %edi
	callq	strerror@PLT
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	die_path
.Lfunc_end64:
	.size	main.cold.62, .Lfunc_end64-main.cold.62
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
	.asciz	"--map"
	.size	.L.str.4, 6

	.type	.L.str.5,@object                # @.str.5
.L.str.5:
	.asciz	"--map requires an output path"
	.size	.L.str.5, 30

	.type	.L.str.6,@object                # @.str.6
.L.str.6:
	.asciz	"link_aarch64_flat: unknown option %s\n"
	.size	.L.str.6, 38

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"only one input object is supported"
	.size	.L.str.7, 35

	.type	.L.str.8,@object                # @.str.8
.L.str.8:
	.asciz	"usage: link_aarch64_flat -o OUTPUT --base 0xADDR [--map MAP] INPUT.o\n"
	.size	.L.str.8, 70

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"link_aarch64_flat: %s\n"
	.size	.L.str.9, 23

	.type	.L.str.10,@object               # @.str.10
.L.str.10:
	.asciz	"link_aarch64_flat: invalid address: %s\n"
	.size	.L.str.10, 40

	.type	.L.str.11,@object               # @.str.11
.L.str.11:
	.asciz	"rb"
	.size	.L.str.11, 3

	.type	.L.str.12,@object               # @.str.12
.L.str.12:
	.asciz	"seek failed"
	.size	.L.str.12, 12

	.type	.L.str.13,@object               # @.str.13
.L.str.13:
	.asciz	"tell failed"
	.size	.L.str.13, 12

	.type	.L.str.14,@object               # @.str.14
.L.str.14:
	.asciz	"read failed"
	.size	.L.str.14, 12

	.type	.L.str.15,@object               # @.str.15
.L.str.15:
	.asciz	"link_aarch64_flat: %s: %s\n"
	.size	.L.str.15, 27

	.type	.L.str.16,@object               # @.str.16
.L.str.16:
	.asciz	"out of memory"
	.size	.L.str.16, 14

	.type	.L.str.17,@object               # @.str.17
.L.str.17:
	.asciz	"\177ELF"
	.size	.L.str.17, 5

	.type	.L.str.18,@object               # @.str.18
.L.str.18:
	.asciz	"not an ELF file"
	.size	.L.str.18, 16

	.type	.L.str.19,@object               # @.str.19
.L.str.19:
	.asciz	"expected ELF64 little-endian"
	.size	.L.str.19, 29

	.type	.L.str.20,@object               # @.str.20
.L.str.20:
	.asciz	"expected AArch64 relocatable ELF"
	.size	.L.str.20, 33

	.type	.L.str.21,@object               # @.str.21
.L.str.21:
	.asciz	"section header size too small"
	.size	.L.str.21, 30

	.type	.L.str.22,@object               # @.str.22
.L.str.22:
	.asciz	"section string table index out of range"
	.size	.L.str.22, 40

	.type	.L.str.23,@object               # @.str.23
.L.str.23:
	.asciz	"section headers out of range"
	.size	.L.str.23, 29

	.type	.L.str.24,@object               # @.str.24
.L.str.24:
	.asciz	"section string table out of range"
	.size	.L.str.24, 34

	.type	.L.str.25,@object               # @.str.25
.L.str.25:
	.asciz	"section data out of range"
	.size	.L.str.25, 26

	.type	.L.str.26,@object               # @.str.26
.L.str.26:
	.asciz	"unexpected end of file"
	.size	.L.str.26, 23

	.type	.L.str.27,@object               # @.str.27
.L.str.27:
	.asciz	"string table offset out of range"
	.size	.L.str.27, 33

	.type	.L.str.28,@object               # @.str.28
.L.str.28:
	.asciz	"unterminated string table entry"
	.size	.L.str.28, 32

	.type	.L.str.29,@object               # @.str.29
.L.str.29:
	.asciz	"symbol string table link out of range"
	.size	.L.str.29, 38

	.type	.L.str.30,@object               # @.str.30
.L.str.30:
	.asciz	"symbol table has zero entry size"
	.size	.L.str.30, 33

	.type	.L.str.31,@object               # @.str.31
.L.str.31:
	.asciz	"symbol string table out of range"
	.size	.L.str.31, 33

	.type	.L.str.32,@object               # @.str.32
.L.str.32:
	.asciz	"missing symbol table"
	.size	.L.str.32, 21

	.type	.L.str.33,@object               # @.str.33
.L.str.33:
	.asciz	"section alignment is not a power of two"
	.size	.L.str.33, 40

	.type	.L.str.34,@object               # @.str.34
.L.str.34:
	.asciz	"no allocated file-backed sections"
	.size	.L.str.34, 34

	.type	.L.str.36,@object               # @.str.36
.L.str.36:
	.asciz	"section output range is outside image"
	.size	.L.str.36, 38

	.type	.L.str.37,@object               # @.str.37
.L.str.37:
	.asciz	"relocation target section out of range"
	.size	.L.str.37, 39

	.type	.L.str.38,@object               # @.str.38
.L.str.38:
	.asciz	"unsupported RELA entry size"
	.size	.L.str.38, 28

	.type	.L.str.39,@object               # @.str.39
.L.str.39:
	.asciz	"ABS64 relocation target outside output"
	.size	.L.str.39, 39

	.type	.L.str.40,@object               # @.str.40
.L.str.40:
	.asciz	"link_aarch64_flat: unsupported AArch64 relocation %u\n"
	.size	.L.str.40, 54

	.type	.L.str.41,@object               # @.str.41
.L.str.41:
	.asciz	"relocation symbol index out of range"
	.size	.L.str.41, 37

	.type	.L.str.42,@object               # @.str.42
.L.str.42:
	.asciz	"link_aarch64_flat: unresolved symbol: %s\n"
	.size	.L.str.42, 42

	.type	.L.str.43,@object               # @.str.43
.L.str.43:
	.asciz	"symbol section out of range"
	.size	.L.str.43, 28

	.type	.L.str.44,@object               # @.str.44
.L.str.44:
	.asciz	"symbol is not in an allocated section"
	.size	.L.str.44, 38

	.type	.L.str.45,@object               # @.str.45
.L.str.45:
	.asciz	"__bss_start"
	.size	.L.str.45, 12

	.type	.L.str.46,@object               # @.str.46
.L.str.46:
	.asciz	"__bss_end"
	.size	.L.str.46, 10

	.type	.L.str.47,@object               # @.str.47
.L.str.47:
	.asciz	"__pi4_image_base"
	.size	.L.str.47, 17

	.type	.L.str.48,@object               # @.str.48
.L.str.48:
	.asciz	"__pi4_image_end"
	.size	.L.str.48, 16

	.type	.L.str.49,@object               # @.str.49
.L.str.49:
	.asciz	"ADR relocation target outside output"
	.size	.L.str.49, 37

	.type	.L.str.50,@object               # @.str.50
.L.str.50:
	.asciz	"ADR relocation is out of +/-1 MiB range"
	.size	.L.str.50, 40

	.type	.L.str.51,@object               # @.str.51
.L.str.51:
	.asciz	"ADR relocation target is not an ADR instruction"
	.size	.L.str.51, 48

	.type	.L.str.52,@object               # @.str.52
.L.str.52:
	.asciz	"write past output"
	.size	.L.str.52, 18

	.type	.L.str.53,@object               # @.str.53
.L.str.53:
	.asciz	"wb"
	.size	.L.str.53, 3

	.type	.L.str.54,@object               # @.str.54
.L.str.54:
	.asciz	"write failed"
	.size	.L.str.54, 13

	.type	.L.str.55,@object               # @.str.55
.L.str.55:
	.asciz	"w"
	.size	.L.str.55, 2

	.type	.L.str.56,@object               # @.str.56
.L.str.56:
	.asciz	"# vibe-os-aarch64-flat-map-v1\n"
	.size	.L.str.56, 31

	.type	.L.str.57,@object               # @.str.57
.L.str.57:
	.asciz	"base=0x%016llX\n"
	.size	.L.str.57, 16

	.type	.L.str.58,@object               # @.str.58
.L.str.58:
	.asciz	"file_size=0x%016llX\n"
	.size	.L.str.58, 21

	.type	.L.str.59,@object               # @.str.59
.L.str.59:
	.asciz	"file_end=0x%016llX\n"
	.size	.L.str.59, 20

	.type	.L.str.60,@object               # @.str.60
.L.str.60:
	.asciz	"mem_size=0x%016llX\n"
	.size	.L.str.60, 20

	.type	.L.str.61,@object               # @.str.61
.L.str.61:
	.asciz	"bss=0x%016llX/0x%016llX\n"
	.size	.L.str.61, 25

	.type	.L.str.62,@object               # @.str.62
.L.str.62:
	.asciz	"bss_after_file=%s\n"
	.size	.L.str.62, 19

	.type	.L.str.63,@object               # @.str.63
.L.str.63:
	.asciz	"YES"
	.size	.L.str.63, 4

	.type	.L.str.64,@object               # @.str.64
.L.str.64:
	.asciz	"NO"
	.size	.L.str.64, 3

	.type	.L.str.65,@object               # @.str.65
.L.str.65:
	.asciz	"section=%s addr=0x%016llX off=0x%016llX size=0x%016llX file=%s\n"
	.size	.L.str.65, 64

	.type	.L.str.66,@object               # @.str.66
.L.str.66:
	.asciz	"synthetic"
	.size	.L.str.66, 10

	.type	.L.str.67,@object               # @.str.67
.L.str.67:
	.asciz	"symbol=%s addr=0x%016llX section=%s size=0x%016llX\n"
	.size	.L.str.67, 52

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
