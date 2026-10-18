
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000da5740 <_Z11ggc_collect11ggc_collect@@Base>:
  da5740:	48 83 ec 58          	sub    $0x58,%rsp
  da5744:	4c 89 64 24 38       	mov    %r12,0x38(%rsp)
  da5749:	41 89 fc             	mov    %edi,%r12d
  da574c:	bf 10 00 00 00       	mov    $0x10,%edi
  da5751:	48 89 5c 24 28       	mov    %rbx,0x28(%rsp)
  da5756:	8b 1d 78 3d f7 02    	mov    0x2f73d78(%rip),%ebx        # 3d194d4 <global_options@@Base+0x1f4>
  da575c:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
  da5761:	48 8b 2d d8 20 d9 02 	mov    0x2d920d8(%rip),%rbp        # 3b37840 <system__soft_links__library_exception@@Base+0x3320>
  da5768:	e8 33 e4 90 01       	call   26b3ba0 <_ZN17memory_block_pool4trimEi@@Base>
  da576d:	45 85 e4             	test   %r12d,%r12d
  da5770:	75 6e                	jne    da57e0 <_Z11ggc_collect11ggc_collect@@Base+0xa0>
  da5772:	48 63 c3             	movslq %ebx,%rax
  da5775:	48 c1 e0 0a          	shl    $0xa,%rax
  da5779:	48 39 e8             	cmp    %rbp,%rax
  da577c:	48 0f 42 c5          	cmovb  %rbp,%rax
  da5780:	48 85 c0             	test   %rax,%rax
  da5783:	0f 88 54 03 00 00    	js     da5add <_Z11ggc_collect11ggc_collect@@Base+0x39d>
  da5789:	66 0f ef c9          	pxor   %xmm1,%xmm1
  da578d:	f3 48 0f 2a c8       	cvtsi2ss %rax,%xmm1
  da5792:	48 8b 05 9f 20 d9 02 	mov    0x2d9209f(%rip),%rax        # 3b37838 <system__soft_links__library_exception@@Base+0x3318>
  da5799:	48 85 c0             	test   %rax,%rax
  da579c:	0f 88 64 03 00 00    	js     da5b06 <_Z11ggc_collect11ggc_collect@@Base+0x3c6>
  da57a2:	66 0f ef d2          	pxor   %xmm2,%xmm2
  da57a6:	f3 48 0f 2a d0       	cvtsi2ss %rax,%xmm2
  da57ab:	66 0f ef c0          	pxor   %xmm0,%xmm0
  da57af:	f3 0f 2a 05 19 3d f7 	cvtsi2ssl 0x2f73d19(%rip),%xmm0        # 3d194d0 <global_options@@Base+0x1f0>
  da57b6:	02 
  da57b7:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  da57bb:	f3 0f 5e 05 01 20 c4 	divss  0x1c42001(%rip),%xmm0        # 29e77c4 <_IO_stdin_used@@Base+0x4>
  da57c2:	01 
  da57c3:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  da57c7:	0f 2f c2             	comiss %xmm2,%xmm0
  da57ca:	76 14                	jbe    da57e0 <_Z11ggc_collect11ggc_collect@@Base+0xa0>
  da57cc:	48 8b 5c 24 28       	mov    0x28(%rsp),%rbx
  da57d1:	48 8b 6c 24 30       	mov    0x30(%rsp),%rbp
  da57d6:	4c 8b 64 24 38       	mov    0x38(%rsp),%r12
  da57db:	48 83 c4 58          	add    $0x58,%rsp
  da57df:	c3                   	ret
  da57e0:	48 8b 3d 89 f0 f3 02 	mov    0x2f3f089(%rip),%rdi        # 3ce4870 <g_timer@@Base>
  da57e7:	4c 89 6c 24 40       	mov    %r13,0x40(%rsp)
  da57ec:	48 85 ff             	test   %rdi,%rdi
  da57ef:	74 0a                	je     da57fb <_Z11ggc_collect11ggc_collect@@Base+0xbb>
  da57f1:	be 0d 00 00 00       	mov    $0xd,%esi
  da57f6:	e8 a5 f3 5a 00       	call   1354ba0 <_ZN5timer4pushE12timevar_id_t@@Base>
  da57fb:	48 8b 1d 36 20 d9 02 	mov    0x2d92036(%rip),%rbx        # 3b37838 <system__soft_links__library_exception@@Base+0x3318>
  da5802:	48 c7 05 2b 20 d9 02 	movq   $0x0,0x2d9202b(%rip)        # 3b37838 <system__soft_links__library_exception@@Base+0x3318>
  da5809:	00 00 00 00 
  da580d:	e8 ee e5 ff ff       	call   da3e00 <_Z25init_adjust_machine_modesv@@Base+0x4d0>
  da5812:	8b 35 80 55 f7 02    	mov    0x2f75580(%rip),%esi        # 3d1ad98 <global_options@@Base+0x1ab8>
  da5818:	85 f6                	test   %esi,%esi
  da581a:	75 3a                	jne    da5856 <_Z11ggc_collect11ggc_collect@@Base+0x116>
  da581c:	b9 20 00 00 00       	mov    $0x20,%ecx
  da5821:	48 81 fb ff 27 00 00 	cmp    $0x27ff,%rbx
  da5828:	76 16                	jbe    da5840 <_Z11ggc_collect11ggc_collect@@Base+0x100>
  da582a:	48 81 fb ff ff 9f 00 	cmp    $0x9fffff,%rbx
  da5831:	0f 87 f4 03 00 00    	ja     da5c2b <_Z11ggc_collect11ggc_collect@@Base+0x4eb>
  da5837:	48 c1 eb 0a          	shr    $0xa,%rbx
  da583b:	b9 6b 00 00 00       	mov    $0x6b,%ecx
  da5840:	48 8b 3d 79 67 84 02 	mov    0x2846779(%rip),%rdi        # 35ebfc0 <stderr@GLIBC_2.2.5>
  da5847:	48 89 da             	mov    %rbx,%rdx
  da584a:	be 7f a7 9f 02       	mov    $0x29fa77f,%esi
  da584f:	31 c0                	xor    %eax,%eax
  da5851:	e8 ca 30 b3 ff       	call   8d8920 <fprintf@plt>
  da5856:	0f b7 0d 03 20 d9 02 	movzwl 0x2d92003(%rip),%ecx        # 3b37860 <system__soft_links__library_exception@@Base+0x3340>
  da585d:	b8 01 00 00 00       	mov    $0x1,%eax
  da5862:	83 c1 01             	add    $0x1,%ecx
  da5865:	48 d3 e0             	shl    %cl,%rax
  da5868:	48 83 e8 01          	sub    $0x1,%rax
  da586c:	80 3d ad 9b e7 02 00 	cmpb   $0x0,0x2e79bad(%rip)        # 3c1f420 <flag_plugin_added@@Base>
  da5873:	48 89 05 de 1f d9 02 	mov    %rax,0x2d91fde(%rip)        # 3b37858 <system__soft_links__library_exception@@Base+0x3338>
  da587a:	0f 85 4c 02 00 00    	jne    da5acc <_Z11ggc_collect11ggc_collect@@Base+0x38c>
  da5880:	c6 05 39 1a d9 02 01 	movb   $0x1,0x2d91a39(%rip)        # 3b372c0 <system__soft_links__library_exception@@Base+0x2da0>
  da5887:	e8 04 e9 ff ff       	call   da4190 <_Z25init_adjust_machine_modesv@@Base+0x860>
  da588c:	e8 bf a8 1d 00       	call   f80150 <_Z14ggc_mark_rootsv@@Base>
  da5891:	4c 8b 2d 80 20 d9 02 	mov    0x2d92080(%rip),%r13        # 3b37918 <system__soft_links__library_exception@@Base+0x33f8>
  da5898:	4d 85 ed             	test   %r13,%r13
  da589b:	0f 84 54 03 00 00    	je     da5bf5 <_Z11ggc_collect11ggc_collect@@Base+0x4b5>
  da58a1:	41 8b 75 04          	mov    0x4(%r13),%esi
  da58a5:	0f b7 0d b4 1f d9 02 	movzwl 0x2d91fb4(%rip),%ecx        # 3b37860 <system__soft_links__library_exception@@Base+0x3340>
  da58ac:	4c 89 74 24 48       	mov    %r14,0x48(%rsp)
  da58b1:	4c 89 7c 24 50       	mov    %r15,0x50(%rsp)
  da58b6:	89 74 24 18          	mov    %esi,0x18(%rsp)
  da58ba:	39 f1                	cmp    %esi,%ecx
  da58bc:	0f 83 62 02 00 00    	jae    da5b24 <_Z11ggc_collect11ggc_collect@@Base+0x3e4>
  da58c2:	48 8d 14 cd 08 00 00 	lea    0x8(,%rcx,8),%rdx
  da58c9:	00 
  da58ca:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
  da58cf:	8d 56 ff             	lea    -0x1(%rsi),%edx
  da58d2:	29 ca                	sub    %ecx,%edx
  da58d4:	4c 8d 7c 11 02       	lea    0x2(%rcx,%rdx,1),%r15
  da58d9:	4a 8d 04 fd 00 00 00 	lea    0x0(,%r15,8),%rax
  da58e0:	00 
  da58e1:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
  da58e6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  da58ed:	00 00 00 
  da58f0:	4c 03 6c 24 08       	add    0x8(%rsp),%r13
  da58f5:	49 8b 45 00          	mov    0x0(%r13),%rax
  da58f9:	48 85 c0             	test   %rax,%rax
  da58fc:	74 64                	je     da5962 <_Z11ggc_collect11ggc_collect@@Base+0x222>
  da58fe:	44 8b 60 04          	mov    0x4(%rax),%r12d
  da5902:	45 85 e4             	test   %r12d,%r12d
  da5905:	74 5b                	je     da5962 <_Z11ggc_collect11ggc_collect@@Base+0x222>
  da5907:	31 ed                	xor    %ebp,%ebp
  da5909:	eb 35                	jmp    da5940 <_Z11ggc_collect11ggc_collect@@Base+0x200>
  da590b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  da5910:	4c 89 f7             	mov    %r14,%rdi
  da5913:	41 83 ec 01          	sub    $0x1,%r12d
  da5917:	41 ff 57 08          	call   *0x8(%r15)
  da591b:	49 8b 55 00          	mov    0x0(%r13),%rdx
  da591f:	8b 42 04             	mov    0x4(%rdx),%eax
  da5922:	83 e8 01             	sub    $0x1,%eax
  da5925:	89 42 04             	mov    %eax,0x4(%rdx)
  da5928:	48 c1 e0 04          	shl    $0x4,%rax
  da592c:	f3 0f 6f 44 02 08    	movdqu 0x8(%rdx,%rax,1),%xmm0
  da5932:	0f 11 44 1a 08       	movups %xmm0,0x8(%rdx,%rbx,1)
  da5937:	44 39 e5             	cmp    %r12d,%ebp
  da593a:	73 26                	jae    da5962 <_Z11ggc_collect11ggc_collect@@Base+0x222>
  da593c:	49 8b 45 00          	mov    0x0(%r13),%rax
  da5940:	89 eb                	mov    %ebp,%ebx
  da5942:	48 c1 e3 04          	shl    $0x4,%rbx
  da5946:	4c 8d 7c 18 08       	lea    0x8(%rax,%rbx,1),%r15
  da594b:	4d 8b 37             	mov    (%r15),%r14
  da594e:	4c 89 f7             	mov    %r14,%rdi
  da5951:	e8 da f5 ff ff       	call   da4f30 <_Z12ggc_marked_pPKv@@Base>
  da5956:	84 c0                	test   %al,%al
  da5958:	74 b6                	je     da5910 <_Z11ggc_collect11ggc_collect@@Base+0x1d0>
  da595a:	83 c5 01             	add    $0x1,%ebp
  da595d:	44 39 e5             	cmp    %r12d,%ebp
  da5960:	72 da                	jb     da593c <_Z11ggc_collect11ggc_collect@@Base+0x1fc>
  da5962:	48 83 44 24 08 08    	addq   $0x8,0x8(%rsp)
  da5968:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
  da596d:	48 39 44 24 10       	cmp    %rax,0x10(%rsp)
  da5972:	74 0c                	je     da5980 <_Z11ggc_collect11ggc_collect@@Base+0x240>
  da5974:	4c 8b 2d 9d 1f d9 02 	mov    0x2d91f9d(%rip),%r13        # 3b37918 <system__soft_links__library_exception@@Base+0x33f8>
  da597b:	e9 70 ff ff ff       	jmp    da58f0 <_Z11ggc_collect11ggc_collect@@Base+0x1b0>
  da5980:	4c 8b 2d 99 1f d9 02 	mov    0x2d91f99(%rip),%r13        # 3b37920 <system__soft_links__library_exception@@Base+0x3400>
  da5987:	4d 85 ed             	test   %r13,%r13
  da598a:	0f 84 ae 02 00 00    	je     da5c3e <_Z11ggc_collect11ggc_collect@@Base+0x4fe>
  da5990:	8b 44 24 18          	mov    0x18(%rsp),%eax
  da5994:	41 3b 45 04          	cmp    0x4(%r13),%eax
  da5998:	0f 85 1e 8e b3 ff    	jne    8de7bc <calloc@plt+0x533c>
  da599e:	0f b7 15 bb 1e d9 02 	movzwl 0x2d91ebb(%rip),%edx        # 3b37860 <system__soft_links__library_exception@@Base+0x3340>
  da59a5:	8b 74 24 18          	mov    0x18(%rsp),%esi
  da59a9:	48 89 d0             	mov    %rdx,%rax
  da59ac:	39 f2                	cmp    %esi,%edx
  da59ae:	0f 83 8c 01 00 00    	jae    da5b40 <_Z11ggc_collect11ggc_collect@@Base+0x400>
  da59b4:	48 8d 0c d5 08 00 00 	lea    0x8(,%rdx,8),%rcx
  da59bb:	00 
  da59bc:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  da59c1:	89 f1                	mov    %esi,%ecx
  da59c3:	29 d1                	sub    %edx,%ecx
  da59c5:	8d 51 ff             	lea    -0x1(%rcx),%edx
  da59c8:	4c 8d 7c 10 02       	lea    0x2(%rax,%rdx,1),%r15
  da59cd:	4a 8d 04 fd 00 00 00 	lea    0x0(,%r15,8),%rax
  da59d4:	00 
  da59d5:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
  da59da:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  da59e0:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
  da59e5:	4c 01 e8             	add    %r13,%rax
  da59e8:	4c 8b 38             	mov    (%rax),%r15
  da59eb:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
  da59f0:	4d 85 ff             	test   %r15,%r15
  da59f3:	0f 84 b1 00 00 00    	je     da5aaa <_Z11ggc_collect11ggc_collect@@Base+0x36a>
  da59f9:	45 8b 67 04          	mov    0x4(%r15),%r12d
  da59fd:	45 85 e4             	test   %r12d,%r12d
  da5a00:	0f 84 a4 00 00 00    	je     da5aaa <_Z11ggc_collect11ggc_collect@@Base+0x36a>
  da5a06:	31 ed                	xor    %ebp,%ebp
  da5a08:	eb 1a                	jmp    da5a24 <_Z11ggc_collect11ggc_collect@@Base+0x2e4>
  da5a0a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  da5a10:	83 c5 01             	add    $0x1,%ebp
  da5a13:	44 39 e5             	cmp    %r12d,%ebp
  da5a16:	0f 83 8e 00 00 00    	jae    da5aaa <_Z11ggc_collect11ggc_collect@@Base+0x36a>
  da5a1c:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
  da5a21:	4c 8b 38             	mov    (%rax),%r15
  da5a24:	89 eb                	mov    %ebp,%ebx
  da5a26:	48 c1 e3 05          	shl    $0x5,%rbx
  da5a2a:	4d 8d 74 1f 08       	lea    0x8(%r15,%rbx,1),%r14
  da5a2f:	4d 8b 2e             	mov    (%r14),%r13
  da5a32:	4c 89 ef             	mov    %r13,%rdi
  da5a35:	e8 f6 f4 ff ff       	call   da4f30 <_Z12ggc_marked_pPKv@@Base>
  da5a3a:	84 c0                	test   %al,%al
  da5a3c:	75 d2                	jne    da5a10 <_Z11ggc_collect11ggc_collect@@Base+0x2d0>
  da5a3e:	49 83 7e 18 00       	cmpq   $0x0,0x18(%r14)
  da5a43:	74 2f                	je     da5a74 <_Z11ggc_collect11ggc_collect@@Base+0x334>
  da5a45:	45 31 ff             	xor    %r15d,%r15d
  da5a48:	eb 09                	jmp    da5a53 <_Z11ggc_collect11ggc_collect@@Base+0x313>
  da5a4a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  da5a50:	4d 8b 2e             	mov    (%r14),%r13
  da5a53:	49 8b 7e 10          	mov    0x10(%r14),%rdi
  da5a57:	49 0f af ff          	imul   %r15,%rdi
  da5a5b:	49 83 c7 01          	add    $0x1,%r15
  da5a5f:	4c 01 ef             	add    %r13,%rdi
  da5a62:	41 ff 56 08          	call   *0x8(%r14)
  da5a66:	4d 3b 7e 18          	cmp    0x18(%r14),%r15
  da5a6a:	72 e4                	jb     da5a50 <_Z11ggc_collect11ggc_collect@@Base+0x310>
  da5a6c:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
  da5a71:	4c 8b 38             	mov    (%rax),%r15
  da5a74:	41 8b 47 04          	mov    0x4(%r15),%eax
  da5a78:	41 83 ec 01          	sub    $0x1,%r12d
  da5a7c:	83 e8 01             	sub    $0x1,%eax
  da5a7f:	41 89 47 04          	mov    %eax,0x4(%r15)
  da5a83:	48 c1 e0 05          	shl    $0x5,%rax
  da5a87:	49 8d 44 07 08       	lea    0x8(%r15,%rax,1),%rax
  da5a8c:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  da5a90:	41 0f 11 44 1f 08    	movups %xmm0,0x8(%r15,%rbx,1)
  da5a96:	f3 0f 6f 40 10       	movdqu 0x10(%rax),%xmm0
  da5a9b:	41 0f 11 44 1f 18    	movups %xmm0,0x18(%r15,%rbx,1)
  da5aa1:	44 39 e5             	cmp    %r12d,%ebp
  da5aa4:	0f 82 72 ff ff ff    	jb     da5a1c <_Z11ggc_collect11ggc_collect@@Base+0x2dc>
  da5aaa:	48 83 44 24 10 08    	addq   $0x8,0x10(%rsp)
  da5ab0:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
  da5ab5:	48 39 44 24 18       	cmp    %rax,0x18(%rsp)
  da5aba:	0f 84 80 00 00 00    	je     da5b40 <_Z11ggc_collect11ggc_collect@@Base+0x400>
  da5ac0:	4c 8b 2d 59 1e d9 02 	mov    0x2d91e59(%rip),%r13        # 3b37920 <system__soft_links__library_exception@@Base+0x3400>
  da5ac7:	e9 14 ff ff ff       	jmp    da59e0 <_Z11ggc_collect11ggc_collect@@Base+0x2a0>
  da5acc:	31 f6                	xor    %esi,%esi
  da5ace:	bf 09 00 00 00       	mov    $0x9,%edi
  da5ad3:	e8 88 86 49 00       	call   123e160 <_Z28invoke_plugin_callbacks_fulliPv@@Base>
  da5ad8:	e9 a3 fd ff ff       	jmp    da5880 <_Z11ggc_collect11ggc_collect@@Base+0x140>
  da5add:	48 89 c2             	mov    %rax,%rdx
  da5ae0:	83 e0 01             	and    $0x1,%eax
  da5ae3:	66 0f ef c9          	pxor   %xmm1,%xmm1
  da5ae7:	48 d1 ea             	shr    $1,%rdx
  da5aea:	48 09 c2             	or     %rax,%rdx
  da5aed:	48 8b 05 44 1d d9 02 	mov    0x2d91d44(%rip),%rax        # 3b37838 <system__soft_links__library_exception@@Base+0x3318>
  da5af4:	f3 48 0f 2a ca       	cvtsi2ss %rdx,%xmm1
  da5af9:	f3 0f 58 c9          	addss  %xmm1,%xmm1
  da5afd:	48 85 c0             	test   %rax,%rax
  da5b00:	0f 89 9c fc ff ff    	jns    da57a2 <_Z11ggc_collect11ggc_collect@@Base+0x62>
  da5b06:	48 89 c2             	mov    %rax,%rdx
  da5b09:	83 e0 01             	and    $0x1,%eax
  da5b0c:	66 0f ef d2          	pxor   %xmm2,%xmm2
  da5b10:	48 d1 ea             	shr    $1,%rdx
  da5b13:	48 09 c2             	or     %rax,%rdx
  da5b16:	f3 48 0f 2a d2       	cvtsi2ss %rdx,%xmm2
  da5b1b:	f3 0f 58 d2          	addss  %xmm2,%xmm2
  da5b1f:	e9 87 fc ff ff       	jmp    da57ab <_Z11ggc_collect11ggc_collect@@Base+0x6b>
  da5b24:	4c 8b 2d f5 1d d9 02 	mov    0x2d91df5(%rip),%r13        # 3b37920 <system__soft_links__library_exception@@Base+0x3400>
  da5b2b:	4d 85 ed             	test   %r13,%r13
  da5b2e:	0f 85 5c fe ff ff    	jne    da5990 <_Z11ggc_collect11ggc_collect@@Base+0x250>
  da5b34:	8b 4c 24 18          	mov    0x18(%rsp),%ecx
  da5b38:	85 c9                	test   %ecx,%ecx
  da5b3a:	0f 85 f9 00 00 00    	jne    da5c39 <_Z11ggc_collect11ggc_collect@@Base+0x4f9>
  da5b40:	4c 8b 74 24 48       	mov    0x48(%rsp),%r14
  da5b45:	4c 8b 7c 24 50       	mov    0x50(%rsp),%r15
  da5b4a:	e8 81 df ff ff       	call   da3ad0 <_Z25init_adjust_machine_modesv@@Base+0x1a0>
  da5b4f:	48 8b 05 e2 1c d9 02 	mov    0x2d91ce2(%rip),%rax        # 3b37838 <system__soft_links__library_exception@@Base+0x3318>
  da5b56:	80 3d c3 98 e7 02 00 	cmpb   $0x0,0x2e798c3(%rip)        # 3c1f420 <flag_plugin_added@@Base>
  da5b5d:	c6 05 5c 17 d9 02 00 	movb   $0x0,0x2d9175c(%rip)        # 3b372c0 <system__soft_links__library_exception@@Base+0x2da0>
  da5b64:	48 89 05 d5 1c d9 02 	mov    %rax,0x2d91cd5(%rip)        # 3b37840 <system__soft_links__library_exception@@Base+0x3320>
  da5b6b:	74 0c                	je     da5b79 <_Z11ggc_collect11ggc_collect@@Base+0x439>
  da5b6d:	31 f6                	xor    %esi,%esi
  da5b6f:	bf 0b 00 00 00       	mov    $0xb,%edi
  da5b74:	e8 e7 85 49 00       	call   123e160 <_Z28invoke_plugin_callbacks_fulliPv@@Base>
  da5b79:	48 8b 3d f0 ec f3 02 	mov    0x2f3ecf0(%rip),%rdi        # 3ce4870 <g_timer@@Base>
  da5b80:	48 85 ff             	test   %rdi,%rdi
  da5b83:	74 0a                	je     da5b8f <_Z11ggc_collect11ggc_collect@@Base+0x44f>
  da5b85:	be 0d 00 00 00       	mov    $0xd,%esi
  da5b8a:	e8 11 0d 5b 00       	call   13568a0 <_ZN5timer3popE12timevar_id_t@@Base>
  da5b8f:	8b 05 03 52 f7 02    	mov    0x2f75203(%rip),%eax        # 3d1ad98 <global_options@@Base+0x1ab8>
  da5b95:	85 c0                	test   %eax,%eax
  da5b97:	75 52                	jne    da5beb <_Z11ggc_collect11ggc_collect@@Base+0x4ab>
  da5b99:	48 8b 15 98 1c d9 02 	mov    0x2d91c98(%rip),%rdx        # 3b37838 <system__soft_links__library_exception@@Base+0x3318>
  da5ba0:	b9 20 00 00 00       	mov    $0x20,%ecx
  da5ba5:	48 81 fa ff 27 00 00 	cmp    $0x27ff,%rdx
  da5bac:	76 12                	jbe    da5bc0 <_Z11ggc_collect11ggc_collect@@Base+0x480>
  da5bae:	48 81 fa ff ff 9f 00 	cmp    $0x9fffff,%rdx
  da5bb5:	77 69                	ja     da5c20 <_Z11ggc_collect11ggc_collect@@Base+0x4e0>
  da5bb7:	48 c1 ea 0a          	shr    $0xa,%rdx
  da5bbb:	b9 6b 00 00 00       	mov    $0x6b,%ecx
  da5bc0:	48 8b 3d f9 63 84 02 	mov    0x28463f9(%rip),%rdi        # 35ebfc0 <stderr@GLIBC_2.2.5>
  da5bc7:	4c 8b 6c 24 40       	mov    0x40(%rsp),%r13
  da5bcc:	be 5c b5 a0 02       	mov    $0x2a0b55c,%esi
  da5bd1:	31 c0                	xor    %eax,%eax
  da5bd3:	48 8b 5c 24 28       	mov    0x28(%rsp),%rbx
  da5bd8:	48 8b 6c 24 30       	mov    0x30(%rsp),%rbp
  da5bdd:	4c 8b 64 24 38       	mov    0x38(%rsp),%r12
  da5be2:	48 83 c4 58          	add    $0x58,%rsp
  da5be6:	e9 35 2d b3 ff       	jmp    8d8920 <fprintf@plt>
  da5beb:	4c 8b 6c 24 40       	mov    0x40(%rsp),%r13
  da5bf0:	e9 d7 fb ff ff       	jmp    da57cc <_Z11ggc_collect11ggc_collect@@Base+0x8c>
  da5bf5:	48 8b 05 24 1d d9 02 	mov    0x2d91d24(%rip),%rax        # 3b37920 <system__soft_links__library_exception@@Base+0x3400>
  da5bfc:	48 85 c0             	test   %rax,%rax
  da5bff:	0f 84 45 ff ff ff    	je     da5b4a <_Z11ggc_collect11ggc_collect@@Base+0x40a>
  da5c05:	8b 50 04             	mov    0x4(%rax),%edx
  da5c08:	85 d2                	test   %edx,%edx
  da5c0a:	0f 84 3a ff ff ff    	je     da5b4a <_Z11ggc_collect11ggc_collect@@Base+0x40a>
  da5c10:	4c 89 74 24 48       	mov    %r14,0x48(%rsp)
  da5c15:	4c 89 7c 24 50       	mov    %r15,0x50(%rsp)
  da5c1a:	e9 9d 8b b3 ff       	jmp    8de7bc <calloc@plt+0x533c>
  da5c1f:	90                   	nop
  da5c20:	48 c1 ea 14          	shr    $0x14,%rdx
  da5c24:	b9 4d 00 00 00       	mov    $0x4d,%ecx
  da5c29:	eb 95                	jmp    da5bc0 <_Z11ggc_collect11ggc_collect@@Base+0x480>
  da5c2b:	48 c1 eb 14          	shr    $0x14,%rbx
  da5c2f:	b9 4d 00 00 00       	mov    $0x4d,%ecx
  da5c34:	e9 07 fc ff ff       	jmp    da5840 <_Z11ggc_collect11ggc_collect@@Base+0x100>
  da5c39:	e9 7e 8b b3 ff       	jmp    8de7bc <calloc@plt+0x533c>
  da5c3e:	e9 79 8b b3 ff       	jmp    8de7bc <calloc@plt+0x533c>

Disassembly of section .fini:
