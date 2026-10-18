
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

00000000016935a0 <_Z9make_node9tree_code@@Base>:
 16935a0:	48 83 ec 28          	sub    $0x28,%rsp
 16935a4:	4c 89 64 24 20       	mov    %r12,0x20(%rsp)
 16935a9:	4c 63 e7             	movslq %edi,%r12
 16935ac:	44 89 e7             	mov    %r12d,%edi
 16935af:	48 89 6c 24 18       	mov    %rbp,0x18(%rsp)
 16935b4:	42 8b 2c a5 e0 e3 bf 	mov    0x2bfe3e0(,%r12,4),%ebp
 16935bb:	02 
 16935bc:	e8 0f fd ff ff       	call   16932d0 <_Z14tree_code_size9tree_code@@Base>
 16935c1:	b9 01 00 00 00       	mov    $0x1,%ecx
 16935c6:	31 d2                	xor    %edx,%edx
 16935c8:	31 f6                	xor    %esi,%esi
 16935ca:	48 89 c7             	mov    %rax,%rdi
 16935cd:	e8 8e cc 8e ff       	call   f80260 <_Z26ggc_internal_cleared_allocmPFvPvEmm@@Base>
 16935d2:	66 44 89 20          	mov    %r12w,(%rax)
 16935d6:	49 89 c0             	mov    %rax,%r8
 16935d9:	83 fd 0a             	cmp    $0xa,%ebp
 16935dc:	77 37                	ja     1693615 <_Z9make_node9tree_code@@Base+0x75>
 16935de:	48 89 5c 24 10       	mov    %rbx,0x10(%rsp)
 16935e3:	4c 89 e3             	mov    %r12,%rbx
 16935e6:	ff 24 ed 40 f0 cb 02 	jmp    *0x2cbf040(,%rbp,8)
 16935ed:	0f 1f 00             	nopl   (%rax)
 16935f0:	41 81 fc f2 00 00 00 	cmp    $0xf2,%r12d
 16935f7:	0f 84 43 02 00 00    	je     1693840 <_Z9make_node9tree_code@@Base+0x2a0>
 16935fd:	41 81 fc f3 00 00 00 	cmp    $0xf3,%r12d
 1693604:	0f 84 6e 01 00 00    	je     1693778 <_Z9make_node9tree_code@@Base+0x1d8>
 169360a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 1693610:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 1693615:	48 8b 6c 24 18       	mov    0x18(%rsp),%rbp
 169361a:	4c 8b 64 24 20       	mov    0x20(%rsp),%r12
 169361f:	4c 89 c0             	mov    %r8,%rax
 1693622:	48 83 c4 28          	add    $0x28,%rsp
 1693626:	c3                   	ret
 1693627:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
 169362e:	00 00 
 1693630:	41 83 fc 3d          	cmp    $0x3d,%r12d
 1693634:	0f 87 26 01 00 00    	ja     1693760 <_Z9make_node9tree_code@@Base+0x1c0>
 169363a:	41 83 fc 3b          	cmp    $0x3b,%r12d
 169363e:	0f 87 06 01 00 00    	ja     169374a <_Z9make_node9tree_code@@Base+0x1aa>
 1693644:	eb ca                	jmp    1693610 <_Z9make_node9tree_code@@Base+0x70>
 1693646:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 169364d:	00 00 00 
 1693650:	80 48 02 02          	orb    $0x2,0x2(%rax)
 1693654:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 1693659:	eb ba                	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 169365b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 1693660:	8b 05 ca 06 f5 01    	mov    0x1f506ca(%rip),%eax        # 35e3d30 <slp_patterns@@Base+0xd0>
 1693666:	4d 89 40 68          	mov    %r8,0x68(%r8)
 169366a:	4c 89 c7             	mov    %r8,%rdi
 169366d:	4d 89 40 58          	mov    %r8,0x58(%r8)
 1693671:	8d 50 01             	lea    0x1(%rax),%edx
 1693674:	41 89 40 30          	mov    %eax,0x30(%r8)
 1693678:	89 15 b2 06 f5 01    	mov    %edx,0x1f506b2(%rip)        # 35e3d30 <slp_patterns@@Base+0xd0>
 169367e:	41 0f b6 40 39       	movzbl 0x39(%r8),%eax
 1693683:	41 80 60 05 fb       	andb   $0xfb,0x5(%r8)
 1693688:	83 e0 c0             	and    $0xffffffc0,%eax
 169368b:	49 c7 40 28 00 00 00 	movq   $0x0,0x28(%r8)
 1693692:	00 
 1693693:	83 c8 04             	or     $0x4,%eax
 1693696:	41 88 40 39          	mov    %al,0x39(%r8)
 169369a:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
 169369f:	ff 15 33 0c f5 01    	call   *0x1f50c33(%rip)        # 35e42d8 <targetm@@Base+0x578>
 16936a5:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
 16936aa:	41 c7 40 3c ff ff ff 	movl   $0xffffffff,0x3c(%r8)
 16936b1:	ff 
 16936b2:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 16936b7:	e9 59 ff ff ff       	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 16936bc:	0f 1f 40 00          	nopl   0x0(%rax)
 16936c0:	49 c1 e4 06          	shl    $0x6,%r12
 16936c4:	41 80 bc 24 8d 66 ce 	cmpb   $0x0,0x3ce668d(%r12)
 16936cb:	03 00 
 16936cd:	74 18                	je     16936e7 <_Z9make_node9tree_code@@Base+0x147>
 16936cf:	83 fb 23             	cmp    $0x23,%ebx
 16936d2:	0f 84 d0 00 00 00    	je     16937a8 <_Z9make_node9tree_code@@Base+0x208>
 16936d8:	8b 40 44             	mov    0x44(%rax),%eax
 16936db:	25 ff 3f f0 ff       	and    $0xfff03fff,%eax
 16936e0:	80 cc 40             	or     $0x40,%ah
 16936e3:	41 89 40 44          	mov    %eax,0x44(%r8)
 16936e7:	48 8b 05 5a 7b 68 02 	mov    0x2687b5a(%rip),%rax        # 3d1b248 <input_location@@Base>
 16936ee:	49 89 40 18          	mov    %rax,0x18(%r8)
 16936f2:	66 83 fb 2b          	cmp    $0x2b,%bx
 16936f6:	0f 84 24 01 00 00    	je     1693820 <_Z9make_node9tree_code@@Base+0x280>
 16936fc:	8b 05 4a 9e 65 02    	mov    0x2659e4a(%rip),%eax        # 3ced54c <tree_node_counts@@Base+0x72c>
 1693702:	41 c7 40 48 ff ff ff 	movl   $0xffffffff,0x48(%r8)
 1693709:	ff 
 169370a:	8d 50 01             	lea    0x1(%rax),%edx
 169370d:	41 89 40 20          	mov    %eax,0x20(%r8)
 1693711:	89 15 35 9e 65 02    	mov    %edx,0x2659e35(%rip)        # 3ced54c <tree_node_counts@@Base+0x72c>
 1693717:	66 83 fb 24          	cmp    $0x24,%bx
 169371b:	0f 85 ef fe ff ff    	jne    1693610 <_Z9make_node9tree_code@@Base+0x70>
 1693721:	41 c7 80 80 00 00 00 	movl   $0xffffffff,0x80(%r8)
 1693728:	ff ff ff ff 
 169372c:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 1693731:	e9 df fe ff ff       	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 1693736:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 169373d:	00 00 00 
 1693740:	41 83 fc 2c          	cmp    $0x2c,%r12d
 1693744:	0f 84 c6 fe ff ff    	je     1693610 <_Z9make_node9tree_code@@Base+0x70>
 169374a:	41 80 48 02 01       	orb    $0x1,0x2(%r8)
 169374f:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 1693754:	e9 bc fe ff ff       	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 1693759:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 1693760:	81 eb 8a 00 00 00    	sub    $0x8a,%ebx
 1693766:	83 fb 04             	cmp    $0x4,%ebx
 1693769:	0f 87 a1 fe ff ff    	ja     1693610 <_Z9make_node9tree_code@@Base+0x70>
 169376f:	eb d9                	jmp    169374a <_Z9make_node9tree_code@@Base+0x1aa>
 1693771:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 1693778:	b9 01 00 00 00       	mov    $0x1,%ecx
 169377d:	31 d2                	xor    %edx,%edx
 169377f:	31 f6                	xor    %esi,%esi
 1693781:	bf 18 01 00 00       	mov    $0x118,%edi
 1693786:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
 169378b:	e8 d0 ca 8e ff       	call   f80260 <_Z26ggc_internal_cleared_allocmPFvPvEmm@@Base>
 1693790:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
 1693795:	49 89 40 10          	mov    %rax,0x10(%r8)
 1693799:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 169379e:	e9 72 fe ff ff       	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 16937a3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 16937a8:	80 3d bb 22 f4 01 00 	cmpb   $0x0,0x1f422bb(%rip)        # 35d5a6a <lang_hooks@@Base+0x3ca>
 16937af:	0f 84 bb 00 00 00    	je     1693870 <_Z9make_node9tree_code@@Base+0x2d0>
 16937b5:	8b 05 a5 11 f5 01    	mov    0x1f511a5(%rip),%eax        # 35e4960 <targetm@@Base+0xc00>
 16937bb:	85 c0                	test   %eax,%eax
 16937bd:	0f 8e ad 00 00 00    	jle    1693870 <_Z9make_node9tree_code@@Base+0x2d0>
 16937c3:	c1 e0 04             	shl    $0x4,%eax
 16937c6:	f3 0f bc c0          	tzcnt  %eax,%eax
 16937ca:	83 c0 01             	add    $0x1,%eax
 16937cd:	83 e0 3f             	and    $0x3f,%eax
 16937d0:	48 8b 15 71 7a 68 02 	mov    0x2687a71(%rip),%rdx        # 3d1b248 <input_location@@Base>
 16937d7:	0f b6 c0             	movzbl %al,%eax
 16937da:	41 c7 40 48 ff ff ff 	movl   $0xffffffff,0x48(%r8)
 16937e1:	ff 
 16937e2:	48 c1 e0 2e          	shl    $0x2e,%rax
 16937e6:	49 89 50 18          	mov    %rdx,0x18(%r8)
 16937ea:	8b 15 5c 9d 65 02    	mov    0x2659d5c(%rip),%edx        # 3ced54c <tree_node_counts@@Base+0x72c>
 16937f0:	48 83 c8 0f          	or     $0xf,%rax
 16937f4:	41 89 50 20          	mov    %edx,0x20(%r8)
 16937f8:	8d 4a 01             	lea    0x1(%rdx),%ecx
 16937fb:	48 ba 00 00 ff ff ff 	movabs $0xfff03fffffff0000,%rdx
 1693802:	3f f0 ff 
 1693805:	49 23 50 40          	and    0x40(%r8),%rdx
 1693809:	48 09 d0             	or     %rdx,%rax
 169380c:	89 0d 3a 9d 65 02    	mov    %ecx,0x2659d3a(%rip)        # 3ced54c <tree_node_counts@@Base+0x72c>
 1693812:	49 89 40 40          	mov    %rax,0x40(%r8)
 1693816:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 169381b:	e9 f5 fd ff ff       	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 1693820:	8b 05 22 9d 65 02    	mov    0x2659d22(%rip),%eax        # 3ced548 <tree_node_counts@@Base+0x728>
 1693826:	83 e8 01             	sub    $0x1,%eax
 1693829:	41 89 40 20          	mov    %eax,0x20(%r8)
 169382d:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 1693832:	89 05 10 9d 65 02    	mov    %eax,0x2659d10(%rip)        # 3ced548 <tree_node_counts@@Base+0x728>
 1693838:	e9 d8 fd ff ff       	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 169383d:	0f 1f 00             	nopl   (%rax)
 1693840:	b9 01 00 00 00       	mov    $0x1,%ecx
 1693845:	31 d2                	xor    %edx,%edx
 1693847:	31 f6                	xor    %esi,%esi
 1693849:	bf e8 05 00 00       	mov    $0x5e8,%edi
 169384e:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
 1693853:	e8 08 ca 8e ff       	call   f80260 <_Z26ggc_internal_cleared_allocmPFvPvEmm@@Base>
 1693858:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
 169385d:	49 89 40 08          	mov    %rax,0x8(%r8)
 1693861:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 1693866:	e9 aa fd ff ff       	jmp    1693615 <_Z9make_node9tree_code@@Base+0x75>
 169386b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 1693870:	b8 04 00 00 00       	mov    $0x4,%eax
 1693875:	e9 56 ff ff ff       	jmp    16937d0 <_Z9make_node9tree_code@@Base+0x230>

Disassembly of section .fini:
