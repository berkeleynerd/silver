
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000da43b0 <_Z18ggc_internal_allocmPFvPvEmm@@Base>:
  da43b0:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  da43b7:	48 89 5c 24 68       	mov    %rbx,0x68(%rsp)
  da43bc:	48 89 6c 24 70       	mov    %rbp,0x70(%rsp)
  da43c1:	4c 89 64 24 78       	mov    %r12,0x78(%rsp)
  da43c6:	4c 89 ac 24 80 00 00 	mov    %r13,0x80(%rsp)
  da43cd:	00 
  da43ce:	4c 89 bc 24 90 00 00 	mov    %r15,0x90(%rsp)
  da43d5:	00 
  da43d6:	48 89 34 24          	mov    %rsi,(%rsp)
  da43da:	48 89 54 24 10       	mov    %rdx,0x10(%rsp)
  da43df:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  da43e4:	48 81 ff ff 01 00 00 	cmp    $0x1ff,%rdi
  da43eb:	0f 86 e7 02 00 00    	jbe    da46d8 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x328>
  da43f1:	48 8b 2d 58 40 d9 02 	mov    0x2d94058(%rip),%rbp        # 3b38450 <system__soft_links__library_exception@@Base+0x3f30>
  da43f8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  da43fd:	48 39 fd             	cmp    %rdi,%rbp
  da4400:	73 2f                	jae    da4431 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x81>
  da4402:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  da4409:	00 
  da440a:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  da4411:	00 00 00 00 
  da4415:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  da441c:	00 00 00 00 
  da4420:	48 83 c3 01          	add    $0x1,%rbx
  da4424:	48 8b 2c dd 00 84 b3 	mov    0x3b38400(,%rbx,8),%rbp
  da442b:	03 
  da442c:	48 39 fd             	cmp    %rdi,%rbp
  da442f:	72 ef                	jb     da4420 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x70>
  da4431:	4c 8b 2c dd e0 72 b3 	mov    0x3b372e0(,%rbx,8),%r13
  da4438:	03 
  da4439:	4d 85 ed             	test   %r13,%r13
  da443c:	0f 84 9e 00 00 00    	je     da44e0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x130>
  da4442:	41 0f b7 7d 32       	movzwl 0x32(%r13),%edi
  da4447:	66 85 ff             	test   %di,%di
  da444a:	0f 84 90 00 00 00    	je     da44e0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x130>
  da4450:	41 0f b7 55 34       	movzwl 0x34(%r13),%edx
  da4455:	89 d6                	mov    %edx,%esi
  da4457:	89 d1                	mov    %edx,%ecx
  da4459:	41 89 d0             	mov    %edx,%r8d
  da445c:	c1 ee 06             	shr    $0x6,%esi
  da445f:	83 e1 3f             	and    $0x3f,%ecx
  da4462:	48 83 c6 06          	add    $0x6,%rsi
  da4466:	49 8b 44 f5 08       	mov    0x8(%r13,%rsi,8),%rax
  da446b:	48 0f a3 d0          	bt     %rdx,%rax
  da446f:	73 4b                	jae    da44bc <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x10c>
  da4471:	49 8b 45 38          	mov    0x38(%r13),%rax
  da4475:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  da4479:	0f 85 01 08 00 00    	jne    da4c80 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x8d0>
  da447f:	31 f6                	xor    %esi,%esi
  da4481:	0f 1f 40 00          	nopl   0x0(%rax)
  da4485:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  da448c:	00 00 00 00 
  da4490:	48 83 c6 01          	add    $0x1,%rsi
  da4494:	49 8b 44 f5 38       	mov    0x38(%r13,%rsi,8),%rax
  da4499:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  da449d:	74 f1                	je     da4490 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0xe0>
  da449f:	89 f2                	mov    %esi,%edx
  da44a1:	c1 e2 06             	shl    $0x6,%edx
  da44a4:	49 89 c0             	mov    %rax,%r8
  da44a7:	48 83 c6 06          	add    $0x6,%rsi
  da44ab:	49 f7 d0             	not    %r8
  da44ae:	f3 4d 0f bc c0       	tzcnt  %r8,%r8
  da44b3:	44 01 c2             	add    %r8d,%edx
  da44b6:	44 89 c1             	mov    %r8d,%ecx
  da44b9:	41 89 d0             	mov    %edx,%r8d
  da44bc:	41 83 c0 01          	add    $0x1,%r8d
  da44c0:	89 d2                	mov    %edx,%edx
  da44c2:	4d 89 ef             	mov    %r13,%r15
  da44c5:	66 45 89 45 34       	mov    %r8w,0x34(%r13)
  da44ca:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  da44d0:	48 0f af d5          	imul   %rbp,%rdx
  da44d4:	49 d3 e0             	shl    %cl,%r8
  da44d7:	4c 89 c1             	mov    %r8,%rcx
  da44da:	e9 58 02 00 00       	jmp    da4737 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x387>
  da44df:	90                   	nop
  da44e0:	89 de                	mov    %ebx,%esi
  da44e2:	48 8b 15 3f 33 d9 02 	mov    0x2d9333f(%rip),%rdx        # 3b37828 <system__soft_links__library_exception@@Base+0x3308>
  da44e9:	4c 89 b4 24 88 00 00 	mov    %r14,0x88(%rsp)
  da44f0:	00 
  da44f1:	89 d9                	mov    %ebx,%ecx
  da44f3:	8b 04 b5 a0 86 b3 03 	mov    0x3b386a0(,%rsi,4),%eax
  da44fa:	4c 8b 34 f5 20 70 b3 	mov    0x3b37020(,%rsi,8),%r14
  da4501:	03 
  da4502:	49 89 d4             	mov    %rdx,%r12
  da4505:	48 89 c7             	mov    %rax,%rdi
  da4508:	89 44 24 2c          	mov    %eax,0x2c(%rsp)
  da450c:	48 0f af 04 f5 00 84 	imul   0x3b38400(,%rsi,8),%rax
  da4513:	b3 03 
  da4515:	48 c1 ef 06          	shr    $0x6,%rdi
  da4519:	48 89 7c 24 30       	mov    %rdi,0x30(%rsp)
  da451e:	48 8d 3c fd 40 00 00 	lea    0x40(,%rdi,8),%rdi
  da4525:	00 
  da4526:	48 39 d0             	cmp    %rdx,%rax
  da4529:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  da452e:	48 0f 42 c2          	cmovb  %rdx,%rax
  da4532:	49 f7 dc             	neg    %r12
  da4535:	48 8d 44 02 ff       	lea    -0x1(%rdx,%rax,1),%rax
  da453a:	49 21 c4             	and    %rax,%r12
  da453d:	4d 85 f6             	test   %r14,%r14
  da4540:	0f 84 ea 03 00 00    	je     da4930 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x580>
  da4546:	4d 8b 5e 08          	mov    0x8(%r14),%r11
  da454a:	4d 85 db             	test   %r11,%r11
  da454d:	0f 84 7d 04 00 00    	je     da49d0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x620>
  da4553:	49 8d 46 08          	lea    0x8(%r14),%rax
  da4557:	4d 89 df             	mov    %r11,%r15
  da455a:	eb 13                	jmp    da456f <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x1bf>
  da455c:	0f 1f 40 00          	nopl   0x0(%rax)
  da4560:	4c 89 f8             	mov    %r15,%rax
  da4563:	4d 8b 3f             	mov    (%r15),%r15
  da4566:	4d 85 ff             	test   %r15,%r15
  da4569:	0f 84 61 04 00 00    	je     da49d0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x620>
  da456f:	4d 3b 67 10          	cmp    0x10(%r15),%r12
  da4573:	75 eb                	jne    da4560 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x1b0>
  da4575:	41 80 7f 37 00       	cmpb   $0x0,0x37(%r15)
  da457a:	74 07                	je     da4583 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x1d3>
  da457c:	4c 01 25 c5 32 d9 02 	add    %r12,0x2d932c5(%rip)        # 3b37848 <system__soft_links__library_exception@@Base+0x3328>
  da4583:	49 8b 17             	mov    (%r15),%rdx
  da4586:	41 c6 47 37 00       	movb   $0x0,0x37(%r15)
  da458b:	88 5c 24 38          	mov    %bl,0x38(%rsp)
  da458f:	48 89 10             	mov    %rdx,(%rax)
  da4592:	49 8b 47 20          	mov    0x20(%r15),%rax
  da4596:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
  da459b:	41 0f b6 47 36       	movzbl 0x36(%r15),%eax
  da45a0:	39 c1                	cmp    %eax,%ecx
  da45a2:	0f 84 80 04 00 00    	je     da4a28 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x678>
  da45a8:	4c 89 ff             	mov    %r15,%rdi
  da45ab:	e8 40 43 b3 ff       	call   8d88f0 <free@plt>
  da45b0:	48 8b 74 24 20       	mov    0x20(%rsp),%rsi
  da45b5:	bf 01 00 00 00       	mov    $0x1,%edi
  da45ba:	e8 91 81 99 01       	call   273c750 <xcalloc@@Base>
  da45bf:	49 89 c7             	mov    %rax,%r15
  da45c2:	0f b6 44 24 38       	movzbl 0x38(%rsp),%eax
  da45c7:	0f b7 0d 92 32 d9 02 	movzwl 0x2d93292(%rip),%ecx        # 3b37860 <system__soft_links__library_exception@@Base+0x3340>
  da45ce:	ba 01 00 00 00       	mov    $0x1,%edx
  da45d3:	4d 89 67 10          	mov    %r12,0x10(%r15)
  da45d7:	8b 74 24 2c          	mov    0x2c(%rsp),%esi
  da45db:	48 8b 7c 24 18       	mov    0x18(%rsp),%rdi
  da45e0:	66 41 89 57 34       	mov    %dx,0x34(%r15)
  da45e5:	41 88 47 36          	mov    %al,0x36(%r15)
  da45e9:	b8 01 00 00 00       	mov    $0x1,%eax
  da45ee:	48 89 c2             	mov    %rax,%rdx
  da45f1:	66 41 89 4f 30       	mov    %cx,0x30(%r15)
  da45f6:	48 d3 e2             	shl    %cl,%rdx
  da45f9:	89 f1                	mov    %esi,%ecx
  da45fb:	66 41 89 77 32       	mov    %si,0x32(%r15)
  da4600:	4c 89 fe             	mov    %r15,%rsi
  da4603:	48 d3 e0             	shl    %cl,%rax
  da4606:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
  da460b:	4d 89 77 18          	mov    %r14,0x18(%r15)
  da460f:	49 89 7f 20          	mov    %rdi,0x20(%r15)
  da4613:	48 09 15 36 32 d9 02 	or     %rdx,0x2d93236(%rip)        # 3b37850 <system__soft_links__library_exception@@Base+0x3330>
  da461a:	49 89 44 cf 38       	mov    %rax,0x38(%r15,%rcx,8)
  da461f:	e8 9c f3 ff ff       	call   da39c0 <_Z25init_adjust_machine_modesv@@Base+0x90>
  da4624:	8b 0d d6 32 d9 02    	mov    0x2d932d6(%rip),%ecx        # 3b37900 <system__soft_links__library_exception@@Base+0x33e0>
  da462a:	8b 05 d4 32 d9 02    	mov    0x2d932d4(%rip),%eax        # 3b37904 <system__soft_links__library_exception@@Base+0x33e4>
  da4630:	49 89 4f 28          	mov    %rcx,0x28(%r15)
  da4634:	48 89 ca             	mov    %rcx,%rdx
  da4637:	39 c1                	cmp    %eax,%ecx
  da4639:	0f 83 39 03 00 00    	jae    da4978 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x5c8>
  da463f:	48 8b 05 ca 32 d9 02 	mov    0x2d932ca(%rip),%rax        # 3b37910 <system__soft_links__library_exception@@Base+0x33f0>
  da4646:	48 8b 35 bb 32 d9 02 	mov    0x2d932bb(%rip),%rsi        # 3b37908 <system__soft_links__library_exception@@Base+0x33e8>
  da464d:	83 c2 01             	add    $0x1,%edx
  da4650:	4c 89 3c ce          	mov    %r15,(%rsi,%rcx,8)
  da4654:	89 15 a6 32 d9 02    	mov    %edx,0x2d932a6(%rip)        # 3b37900 <system__soft_links__library_exception@@Base+0x33e0>
  da465a:	48 c7 04 c8 00 00 00 	movq   $0x0,(%rax,%rcx,8)
  da4661:	00 
  da4662:	8b 05 88 32 d9 02    	mov    0x2d93288(%rip),%eax        # 3b378f0 <system__soft_links__library_exception@@Base+0x33d0>
  da4668:	41 0f b7 4f 30       	movzwl 0x30(%r15),%ecx
  da466d:	39 c1                	cmp    %eax,%ecx
  da466f:	72 7f                	jb     da46f0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x340>
  da4671:	48 8b 3d 80 32 d9 02 	mov    0x2d93280(%rip),%rdi        # 3b378f8 <system__soft_links__library_exception@@Base+0x33d8>
  da4678:	41 89 d4             	mov    %edx,%r12d
  da467b:	eb 21                	jmp    da469e <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x2ee>
  da467d:	0f 1f 00             	nopl   (%rax)
  da4680:	8d 50 01             	lea    0x1(%rax),%edx
  da4683:	89 15 67 32 d9 02    	mov    %edx,0x2d93267(%rip)        # 3b378f0 <system__soft_links__library_exception@@Base+0x33d0>
  da4689:	44 89 24 87          	mov    %r12d,(%rdi,%rax,4)
  da468d:	8b 05 5d 32 d9 02    	mov    0x2d9325d(%rip),%eax        # 3b378f0 <system__soft_links__library_exception@@Base+0x33d0>
  da4693:	39 c1                	cmp    %eax,%ecx
  da4695:	72 59                	jb     da46f0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x340>
  da4697:	44 8b 25 62 32 d9 02 	mov    0x2d93262(%rip),%r12d        # 3b37900 <system__soft_links__library_exception@@Base+0x33e0>
  da469e:	8b 35 50 32 d9 02    	mov    0x2d93250(%rip),%esi        # 3b378f4 <system__soft_links__library_exception@@Base+0x33d4>
  da46a4:	41 83 ec 01          	sub    $0x1,%r12d
  da46a8:	39 f0                	cmp    %esi,%eax
  da46aa:	72 d4                	jb     da4680 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x2d0>
  da46ac:	01 f6                	add    %esi,%esi
  da46ae:	89 35 40 32 d9 02    	mov    %esi,0x2d93240(%rip)        # 3b378f4 <system__soft_links__library_exception@@Base+0x33d4>
  da46b4:	48 c1 e6 02          	shl    $0x2,%rsi
  da46b8:	e8 e3 80 99 01       	call   273c7a0 <xrealloc@@Base>
  da46bd:	41 0f b7 4f 30       	movzwl 0x30(%r15),%ecx
  da46c2:	48 89 05 2f 32 d9 02 	mov    %rax,0x2d9322f(%rip)        # 3b378f8 <system__soft_links__library_exception@@Base+0x33d8>
  da46c9:	48 89 c7             	mov    %rax,%rdi
  da46cc:	8b 05 1e 32 d9 02    	mov    0x2d9321e(%rip),%eax        # 3b378f0 <system__soft_links__library_exception@@Base+0x33d0>
  da46d2:	eb ac                	jmp    da4680 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x2d0>
  da46d4:	0f 1f 40 00          	nopl   0x0(%rax)
  da46d8:	0f b6 9f c0 d1 5d 03 	movzbl 0x35dd1c0(%rdi),%ebx
  da46df:	48 8b 2c dd 00 84 b3 	mov    0x3b38400(,%rbx,8),%rbp
  da46e6:	03 
  da46e7:	e9 45 fd ff ff       	jmp    da4431 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x81>
  da46ec:	0f 1f 40 00          	nopl   0x0(%rax)
  da46f0:	4d 85 ed             	test   %r13,%r13
  da46f3:	0f 84 1f 03 00 00    	je     da4a18 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x668>
  da46f9:	4d 89 7d 08          	mov    %r15,0x8(%r13)
  da46fd:	b8 01 00 00 00       	mov    $0x1,%eax
  da4702:	4d 89 2f             	mov    %r13,(%r15)
  da4705:	41 0f b7 7f 32       	movzwl 0x32(%r15),%edi
  da470a:	31 d2                	xor    %edx,%edx
  da470c:	49 c7 47 08 00 00 00 	movq   $0x0,0x8(%r15)
  da4713:	00 
  da4714:	b9 01 00 00 00       	mov    $0x1,%ecx
  da4719:	be 06 00 00 00       	mov    $0x6,%esi
  da471e:	4c 8b b4 24 88 00 00 	mov    0x88(%rsp),%r14
  da4725:	00 
  da4726:	4c 89 3c dd e0 72 b3 	mov    %r15,0x3b372e0(,%rbx,8)
  da472d:	03 
  da472e:	66 41 89 47 34       	mov    %ax,0x34(%r15)
  da4733:	49 8b 47 38          	mov    0x38(%r15),%rax
  da4737:	48 09 c8             	or     %rcx,%rax
  da473a:	66 83 ef 01          	sub    $0x1,%di
  da473e:	49 89 44 f7 08       	mov    %rax,0x8(%r15,%rsi,8)
  da4743:	66 41 89 7f 32       	mov    %di,0x32(%r15)
  da4748:	75 16                	jne    da4760 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x3b0>
  da474a:	49 8b 07             	mov    (%r15),%rax
  da474d:	48 85 c0             	test   %rax,%rax
  da4750:	74 0e                	je     da4760 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x3b0>
  da4752:	66 83 78 32 00       	cmpw   $0x0,0x32(%rax)
  da4757:	0f 85 9b 01 00 00    	jne    da48f8 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x548>
  da475d:	0f 1f 00             	nopl   (%rax)
  da4760:	49 03 57 20          	add    0x20(%r15),%rdx
  da4764:	48 01 2d fd 00 f4 02 	add    %rbp,0x2f400fd(%rip)        # 3ce4868 <timevar_ggc_mem_total@@Base>
  da476b:	48 01 2d c6 30 d9 02 	add    %rbp,0x2d930c6(%rip)        # 3b37838 <system__soft_links__library_exception@@Base+0x3318>
  da4772:	49 89 d4             	mov    %rdx,%r12
  da4775:	48 83 3c 24 00       	cmpq   $0x0,(%rsp)
  da477a:	0f 84 48 01 00 00    	je     da48c8 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x518>
  da4780:	0f b7 05 d9 30 d9 02 	movzwl 0x2d930d9(%rip),%eax        # 3b37860 <system__soft_links__library_exception@@Base+0x3340>
  da4787:	4c 89 b4 24 88 00 00 	mov    %r14,0x88(%rsp)
  da478e:	00 
  da478f:	4c 8d 2c c5 08 00 00 	lea    0x8(,%rax,8),%r13
  da4796:	00 
  da4797:	48 83 7c 24 08 01    	cmpq   $0x1,0x8(%rsp)
  da479d:	0f 84 9d 02 00 00    	je     da4a40 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x690>
  da47a3:	4c 03 2d 76 31 d9 02 	add    0x2d93176(%rip),%r13        # 3b37920 <system__soft_links__library_exception@@Base+0x3400>
  da47aa:	49 8b 6d 00          	mov    0x0(%r13),%rbp
  da47ae:	48 85 ed             	test   %rbp,%rbp
  da47b1:	0f 84 b9 00 00 00    	je     da4870 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x4c0>
  da47b7:	8b 45 00             	mov    0x0(%rbp),%eax
  da47ba:	8b 5d 04             	mov    0x4(%rbp),%ebx
  da47bd:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  da47c2:	44 8d 73 01          	lea    0x1(%rbx),%r14d
  da47c6:	39 d8                	cmp    %ebx,%eax
  da47c8:	0f 85 c8 00 00 00    	jne    da4896 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x4e6>
  da47ce:	80 7d 03 00          	cmpb   $0x0,0x3(%rbp)
  da47d2:	0f 89 90 03 00 00    	jns    da4b68 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x7b8>
  da47d8:	41 bf 04 00 00 00    	mov    $0x4,%r15d
  da47de:	49 c7 45 00 00 00 00 	movq   $0x0,0x0(%r13)
  da47e5:	00 
  da47e6:	45 39 fe             	cmp    %r15d,%r14d
  da47e9:	45 0f 43 fe          	cmovae %r14d,%r15d
  da47ed:	31 ff                	xor    %edi,%edi
  da47ef:	44 89 fe             	mov    %r15d,%esi
  da47f2:	41 81 e7 ff ff ff 7f 	and    $0x7fffffff,%r15d
  da47f9:	48 c1 e6 05          	shl    $0x5,%rsi
  da47fd:	48 83 c6 08          	add    $0x8,%rsi
  da4801:	e8 9a 7f 99 01       	call   273c7a0 <xrealloc@@Base>
  da4806:	49 89 45 00          	mov    %rax,0x0(%r13)
  da480a:	48 89 c6             	mov    %rax,%rsi
  da480d:	44 89 f8             	mov    %r15d,%eax
  da4810:	48 89 06             	mov    %rax,(%rsi)
  da4813:	85 db                	test   %ebx,%ebx
  da4815:	74 47                	je     da485e <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x4ae>
  da4817:	8d 53 ff             	lea    -0x1(%rbx),%edx
  da481a:	48 8d 45 08          	lea    0x8(%rbp),%rax
  da481e:	48 c1 e2 05          	shl    $0x5,%rdx
  da4822:	48 8d 4e 08          	lea    0x8(%rsi),%rcx
  da4826:	48 8d 54 15 28       	lea    0x28(%rbp,%rdx,1),%rdx
  da482b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  da4832:	00 00 00 
  da4835:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  da483c:	00 00 00 00 
  da4840:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  da4844:	48 83 c0 20          	add    $0x20,%rax
  da4848:	48 83 c1 20          	add    $0x20,%rcx
  da484c:	0f 11 41 e0          	movups %xmm0,-0x20(%rcx)
  da4850:	f3 0f 6f 40 f0       	movdqu -0x10(%rax),%xmm0
  da4855:	0f 11 41 f0          	movups %xmm0,-0x10(%rcx)
  da4859:	48 39 d0             	cmp    %rdx,%rax
  da485c:	75 e2                	jne    da4840 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x490>
  da485e:	89 5e 04             	mov    %ebx,0x4(%rsi)
  da4861:	48 89 f5             	mov    %rsi,%rbp
  da4864:	eb 30                	jmp    da4896 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x4e6>
  da4866:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  da486d:	00 00 00 
  da4870:	41 be 04 00 00 00    	mov    $0x4,%r14d
  da4876:	be 88 00 00 00       	mov    $0x88,%esi
  da487b:	31 db                	xor    %ebx,%ebx
  da487d:	48 89 ef             	mov    %rbp,%rdi
  da4880:	e8 1b 7f 99 01       	call   273c7a0 <xrealloc@@Base>
  da4885:	49 89 45 00          	mov    %rax,0x0(%r13)
  da4889:	48 89 c5             	mov    %rax,%rbp
  da488c:	89 58 04             	mov    %ebx,0x4(%rax)
  da488f:	44 89 30             	mov    %r14d,(%rax)
  da4892:	44 8d 73 01          	lea    0x1(%rbx),%r14d
  da4896:	48 c1 e3 05          	shl    $0x5,%rbx
  da489a:	44 89 75 04          	mov    %r14d,0x4(%rbp)
  da489e:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
  da48a3:	48 8d 44 1d 08       	lea    0x8(%rbp,%rbx,1),%rax
  da48a8:	48 8b 1c 24          	mov    (%rsp),%rbx
  da48ac:	4c 8b b4 24 88 00 00 	mov    0x88(%rsp),%r14
  da48b3:	00 
  da48b4:	4c 89 20             	mov    %r12,(%rax)
  da48b7:	48 89 58 08          	mov    %rbx,0x8(%rax)
  da48bb:	48 8b 5c 24 08       	mov    0x8(%rsp),%rbx
  da48c0:	48 89 48 10          	mov    %rcx,0x10(%rax)
  da48c4:	48 89 58 18          	mov    %rbx,0x18(%rax)
  da48c8:	4c 89 e0             	mov    %r12,%rax
  da48cb:	48 8b 5c 24 68       	mov    0x68(%rsp),%rbx
  da48d0:	48 8b 6c 24 70       	mov    0x70(%rsp),%rbp
  da48d5:	4c 8b 64 24 78       	mov    0x78(%rsp),%r12
  da48da:	4c 8b ac 24 80 00 00 	mov    0x80(%rsp),%r13
  da48e1:	00 
  da48e2:	4c 8b bc 24 90 00 00 	mov    0x90(%rsp),%r15
  da48e9:	00 
  da48ea:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  da48f1:	c3                   	ret
  da48f2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  da48f8:	48 89 04 dd e0 72 b3 	mov    %rax,0x3b372e0(,%rbx,8)
  da48ff:	03 
  da4900:	48 83 c3 54          	add    $0x54,%rbx
  da4904:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
  da490b:	00 
  da490c:	48 8b 04 dd e0 72 b3 	mov    0x3b372e0(,%rbx,8),%rax
  da4913:	03 
  da4914:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
  da491b:	49 89 47 08          	mov    %rax,0x8(%r15)
  da491f:	4c 89 38             	mov    %r15,(%rax)
  da4922:	4c 89 3c dd e0 72 b3 	mov    %r15,0x3b372e0(,%rbx,8)
  da4929:	03 
  da492a:	e9 31 fe ff ff       	jmp    da4760 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x3b0>
  da492f:	90                   	nop
  da4930:	b8 01 00 00 00       	mov    $0x1,%eax
  da4935:	48 89 c6             	mov    %rax,%rsi
  da4938:	48 c1 e6 04          	shl    $0x4,%rsi
  da493c:	48 8b b6 68 78 b3 03 	mov    0x3b37868(%rsi),%rsi
  da4943:	49 39 f4             	cmp    %rsi,%r12
  da4946:	0f 84 9a 03 00 00    	je     da4ce6 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x936>
  da494c:	48 85 f6             	test   %rsi,%rsi
  da494f:	0f 84 a4 03 00 00    	je     da4cf9 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x949>
  da4955:	48 83 c0 01          	add    $0x1,%rax
  da4959:	48 83 f8 08          	cmp    $0x8,%rax
  da495d:	75 d6                	jne    da4935 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x585>
  da495f:	41 be 68 78 b3 03    	mov    $0x3b37868,%r14d
  da4965:	89 c8                	mov    %ecx,%eax
  da4967:	4c 89 34 c5 20 70 b3 	mov    %r14,0x3b37020(,%rax,8)
  da496e:	03 
  da496f:	e9 d2 fb ff ff       	jmp    da4546 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x196>
  da4974:	0f 1f 40 00          	nopl   0x0(%rax)
  da4978:	01 c0                	add    %eax,%eax
  da497a:	48 8b 3d 87 2f d9 02 	mov    0x2d92f87(%rip),%rdi        # 3b37908 <system__soft_links__library_exception@@Base+0x33e8>
  da4981:	48 8d 34 c5 00 00 00 	lea    0x0(,%rax,8),%rsi
  da4988:	00 
  da4989:	89 05 75 2f d9 02    	mov    %eax,0x2d92f75(%rip)        # 3b37904 <system__soft_links__library_exception@@Base+0x33e4>
  da498f:	e8 0c 7e 99 01       	call   273c7a0 <xrealloc@@Base>
  da4994:	8b 35 6a 2f d9 02    	mov    0x2d92f6a(%rip),%esi        # 3b37904 <system__soft_links__library_exception@@Base+0x33e4>
  da499a:	48 8b 3d 6f 2f d9 02 	mov    0x2d92f6f(%rip),%rdi        # 3b37910 <system__soft_links__library_exception@@Base+0x33f0>
  da49a1:	48 89 05 60 2f d9 02 	mov    %rax,0x2d92f60(%rip)        # 3b37908 <system__soft_links__library_exception@@Base+0x33e8>
  da49a8:	48 c1 e6 03          	shl    $0x3,%rsi
  da49ac:	e8 ef 7d 99 01       	call   273c7a0 <xrealloc@@Base>
  da49b1:	8b 0d 49 2f d9 02    	mov    0x2d92f49(%rip),%ecx        # 3b37900 <system__soft_links__library_exception@@Base+0x33e0>
  da49b7:	48 89 05 52 2f d9 02 	mov    %rax,0x2d92f52(%rip)        # 3b37910 <system__soft_links__library_exception@@Base+0x33f0>
  da49be:	48 89 ca             	mov    %rcx,%rdx
  da49c1:	e9 80 fc ff ff       	jmp    da4646 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x296>
  da49c6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  da49cd:	00 00 00 
  da49d0:	4c 39 e2             	cmp    %r12,%rdx
  da49d3:	0f 84 c7 01 00 00    	je     da4ba0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x7f0>
  da49d9:	45 31 c9             	xor    %r9d,%r9d
  da49dc:	41 b8 ff ff ff ff    	mov    $0xffffffff,%r8d
  da49e2:	b9 22 00 00 00       	mov    $0x22,%ecx
  da49e7:	31 ff                	xor    %edi,%edi
  da49e9:	ba 03 00 00 00       	mov    $0x3,%edx
  da49ee:	4c 89 e6             	mov    %r12,%rsi
  da49f1:	e8 ea 47 b3 ff       	call   8d91e0 <mmap@plt>
  da49f6:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
  da49fb:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  da49ff:	0f 84 ca 02 00 00    	je     da4ccf <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x91f>
  da4a05:	4c 01 25 3c 2e d9 02 	add    %r12,0x2d92e3c(%rip)        # 3b37848 <system__soft_links__library_exception@@Base+0x3328>
  da4a0c:	88 5c 24 38          	mov    %bl,0x38(%rsp)
  da4a10:	e9 9b fb ff ff       	jmp    da45b0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x200>
  da4a15:	0f 1f 00             	nopl   (%rax)
  da4a18:	4c 89 3c dd 80 75 b3 	mov    %r15,0x3b37580(,%rbx,8)
  da4a1f:	03 
  da4a20:	e9 d8 fc ff ff       	jmp    da46fd <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x34d>
  da4a25:	0f 1f 00             	nopl   (%rax)
  da4a28:	48 8b 54 24 20       	mov    0x20(%rsp),%rdx
  da4a2d:	31 f6                	xor    %esi,%esi
  da4a2f:	4c 89 ff             	mov    %r15,%rdi
  da4a32:	e8 69 40 b3 ff       	call   8d8aa0 <memset@plt>
  da4a37:	e9 86 fb ff ff       	jmp    da45c2 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x212>
  da4a3c:	0f 1f 40 00          	nopl   0x0(%rax)
  da4a40:	4c 03 2d d1 2e d9 02 	add    0x2d92ed1(%rip),%r13        # 3b37918 <system__soft_links__library_exception@@Base+0x33f8>
  da4a47:	49 8b 5d 00          	mov    0x0(%r13),%rbx
  da4a4b:	48 85 db             	test   %rbx,%rbx
  da4a4e:	0f 84 80 02 00 00    	je     da4cd4 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x924>
  da4a54:	8b 03                	mov    (%rbx),%eax
  da4a56:	8b 6b 04             	mov    0x4(%rbx),%ebp
  da4a59:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  da4a5e:	44 8d 75 01          	lea    0x1(%rbp),%r14d
  da4a62:	39 e8                	cmp    %ebp,%eax
  da4a64:	0f 85 91 00 00 00    	jne    da4afb <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x74b>
  da4a6a:	80 7b 03 00          	cmpb   $0x0,0x3(%rbx)
  da4a6e:	0f 89 aa 00 00 00    	jns    da4b1e <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x76e>
  da4a74:	41 bf 04 00 00 00    	mov    $0x4,%r15d
  da4a7a:	49 c7 45 00 00 00 00 	movq   $0x0,0x0(%r13)
  da4a81:	00 
  da4a82:	45 39 fe             	cmp    %r15d,%r14d
  da4a85:	45 0f 43 fe          	cmovae %r14d,%r15d
  da4a89:	31 ff                	xor    %edi,%edi
  da4a8b:	44 89 fe             	mov    %r15d,%esi
  da4a8e:	41 81 e7 ff ff ff 7f 	and    $0x7fffffff,%r15d
  da4a95:	48 c1 e6 04          	shl    $0x4,%rsi
  da4a99:	48 83 c6 08          	add    $0x8,%rsi
  da4a9d:	e8 fe 7c 99 01       	call   273c7a0 <xrealloc@@Base>
  da4aa2:	49 89 45 00          	mov    %rax,0x0(%r13)
  da4aa6:	48 89 c6             	mov    %rax,%rsi
  da4aa9:	44 89 f8             	mov    %r15d,%eax
  da4aac:	48 89 06             	mov    %rax,(%rsi)
  da4aaf:	85 ed                	test   %ebp,%ebp
  da4ab1:	74 42                	je     da4af5 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x745>
  da4ab3:	8d 4d ff             	lea    -0x1(%rbp),%ecx
  da4ab6:	48 8d 43 08          	lea    0x8(%rbx),%rax
  da4aba:	48 c1 e1 04          	shl    $0x4,%rcx
  da4abe:	48 8d 56 08          	lea    0x8(%rsi),%rdx
  da4ac2:	48 8d 4c 0b 18       	lea    0x18(%rbx,%rcx,1),%rcx
  da4ac7:	0f 1f 00             	nopl   (%rax)
  da4aca:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  da4ad1:	00 00 00 00 
  da4ad5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  da4adc:	00 00 00 00 
  da4ae0:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  da4ae4:	48 83 c0 10          	add    $0x10,%rax
  da4ae8:	48 83 c2 10          	add    $0x10,%rdx
  da4aec:	0f 11 42 f0          	movups %xmm0,-0x10(%rdx)
  da4af0:	48 39 c8             	cmp    %rcx,%rax
  da4af3:	75 eb                	jne    da4ae0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x730>
  da4af5:	89 6e 04             	mov    %ebp,0x4(%rsi)
  da4af8:	48 89 f3             	mov    %rsi,%rbx
  da4afb:	48 8b 0c 24          	mov    (%rsp),%rcx
  da4aff:	48 c1 e5 04          	shl    $0x4,%rbp
  da4b03:	44 89 73 04          	mov    %r14d,0x4(%rbx)
  da4b07:	4c 89 64 2b 08       	mov    %r12,0x8(%rbx,%rbp,1)
  da4b0c:	4c 8b b4 24 88 00 00 	mov    0x88(%rsp),%r14
  da4b13:	00 
  da4b14:	48 89 4c 2b 10       	mov    %rcx,0x10(%rbx,%rbp,1)
  da4b19:	e9 aa fd ff ff       	jmp    da48c8 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x518>
  da4b1e:	44 89 f6             	mov    %r14d,%esi
  da4b21:	89 ef                	mov    %ebp,%edi
  da4b23:	e8 d8 79 8a 01       	call   264c500 <_ZN10vec_prefix22calculate_allocation_1Ejj@@Base>
  da4b28:	49 8b 5d 00          	mov    0x0(%r13),%rbx
  da4b2c:	89 c6                	mov    %eax,%esi
  da4b2e:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  da4b33:	48 c1 e6 04          	shl    $0x4,%rsi
  da4b37:	41 89 c6             	mov    %eax,%r14d
  da4b3a:	48 83 c6 08          	add    $0x8,%rsi
  da4b3e:	48 85 db             	test   %rbx,%rbx
  da4b41:	0f 84 98 01 00 00    	je     da4cdf <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x92f>
  da4b47:	8b 6b 04             	mov    0x4(%rbx),%ebp
  da4b4a:	48 89 df             	mov    %rbx,%rdi
  da4b4d:	e8 4e 7c 99 01       	call   273c7a0 <xrealloc@@Base>
  da4b52:	49 89 45 00          	mov    %rax,0x0(%r13)
  da4b56:	48 89 c3             	mov    %rax,%rbx
  da4b59:	44 89 30             	mov    %r14d,(%rax)
  da4b5c:	44 8d 75 01          	lea    0x1(%rbp),%r14d
  da4b60:	89 68 04             	mov    %ebp,0x4(%rax)
  da4b63:	eb 96                	jmp    da4afb <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x74b>
  da4b65:	0f 1f 00             	nopl   (%rax)
  da4b68:	44 89 f6             	mov    %r14d,%esi
  da4b6b:	89 df                	mov    %ebx,%edi
  da4b6d:	e8 8e 79 8a 01       	call   264c500 <_ZN10vec_prefix22calculate_allocation_1Ejj@@Base>
  da4b72:	49 8b 6d 00          	mov    0x0(%r13),%rbp
  da4b76:	89 c6                	mov    %eax,%esi
  da4b78:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  da4b7d:	48 c1 e6 05          	shl    $0x5,%rsi
  da4b81:	41 89 c6             	mov    %eax,%r14d
  da4b84:	48 83 c6 08          	add    $0x8,%rsi
  da4b88:	48 85 ed             	test   %rbp,%rbp
  da4b8b:	0f 84 ea fc ff ff    	je     da487b <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x4cb>
  da4b91:	8b 5d 04             	mov    0x4(%rbp),%ebx
  da4b94:	e9 e4 fc ff ff       	jmp    da487d <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x4cd>
  da4b99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  da4ba0:	4d 89 e7             	mov    %r12,%r15
  da4ba3:	45 31 c9             	xor    %r9d,%r9d
  da4ba6:	31 ff                	xor    %edi,%edi
  da4ba8:	41 b8 ff ff ff ff    	mov    $0xffffffff,%r8d
  da4bae:	49 c1 e7 09          	shl    $0x9,%r15
  da4bb2:	b9 22 00 00 00       	mov    $0x22,%ecx
  da4bb7:	ba 03 00 00 00       	mov    $0x3,%edx
  da4bbc:	4c 89 5c 24 38       	mov    %r11,0x38(%rsp)
  da4bc1:	4c 89 fe             	mov    %r15,%rsi
  da4bc4:	e8 17 46 b3 ff       	call   8d91e0 <mmap@plt>
  da4bc9:	4c 8b 5c 24 38       	mov    0x38(%rsp),%r11
  da4bce:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  da4bd2:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
  da4bd7:	0f 84 ac 00 00 00    	je     da4c89 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x8d9>
  da4bdd:	4c 01 3d 64 2c d9 02 	add    %r15,0x2d92c64(%rip)        # 3b37848 <system__soft_links__library_exception@@Base+0x3328>
  da4be4:	88 5c 24 38          	mov    %bl,0x38(%rsp)
  da4be8:	48 85 c0             	test   %rax,%rax
  da4beb:	0f 84 98 00 00 00    	je     da4c89 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x8d9>
  da4bf1:	4c 89 64 24 58       	mov    %r12,0x58(%rsp)
  da4bf6:	44 0f b6 7c 24 38    	movzbl 0x38(%rsp),%r15d
  da4bfc:	4c 89 d8             	mov    %r11,%rax
  da4bff:	4c 89 6c 24 40       	mov    %r13,0x40(%rsp)
  da4c04:	4c 8b 6c 24 18       	mov    0x18(%rsp),%r13
  da4c09:	48 89 5c 24 48       	mov    %rbx,0x48(%rsp)
  da4c0e:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
  da4c13:	48 89 6c 24 50       	mov    %rbp,0x50(%rsp)
  da4c18:	bd ff 01 00 00       	mov    $0x1ff,%ebp
  da4c1d:	0f 1f 00             	nopl   (%rax)
  da4c20:	48 89 de             	mov    %rbx,%rsi
  da4c23:	bf 01 00 00 00       	mov    $0x1,%edi
  da4c28:	49 89 c4             	mov    %rax,%r12
  da4c2b:	e8 20 7b 99 01       	call   273c750 <xcalloc@@Base>
  da4c30:	48 8b 15 f1 2b d9 02 	mov    0x2d92bf1(%rip),%rdx        # 3b37828 <system__soft_links__library_exception@@Base+0x3308>
  da4c37:	48 8b 0d f2 2b d9 02 	mov    0x2d92bf2(%rip),%rcx        # 3b37830 <system__soft_links__library_exception@@Base+0x3310>
  da4c3e:	44 88 78 36          	mov    %r15b,0x36(%rax)
  da4c42:	48 89 50 10          	mov    %rdx,0x10(%rax)
  da4c46:	89 ea                	mov    %ebp,%edx
  da4c48:	d3 e2                	shl    %cl,%edx
  da4c4a:	4c 89 70 18          	mov    %r14,0x18(%rax)
  da4c4e:	48 63 d2             	movslq %edx,%rdx
  da4c51:	4c 89 20             	mov    %r12,(%rax)
  da4c54:	4c 01 ea             	add    %r13,%rdx
  da4c57:	48 89 50 20          	mov    %rdx,0x20(%rax)
  da4c5b:	83 ed 01             	sub    $0x1,%ebp
  da4c5e:	75 c0                	jne    da4c20 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x870>
  da4c60:	4c 8b 6c 24 40       	mov    0x40(%rsp),%r13
  da4c65:	48 8b 5c 24 48       	mov    0x48(%rsp),%rbx
  da4c6a:	49 89 c3             	mov    %rax,%r11
  da4c6d:	48 8b 6c 24 50       	mov    0x50(%rsp),%rbp
  da4c72:	4c 8b 64 24 58       	mov    0x58(%rsp),%r12
  da4c77:	4d 89 5e 08          	mov    %r11,0x8(%r14)
  da4c7b:	e9 30 f9 ff ff       	jmp    da45b0 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x200>
  da4c80:	31 d2                	xor    %edx,%edx
  da4c82:	31 f6                	xor    %esi,%esi
  da4c84:	e9 1b f8 ff ff       	jmp    da44a4 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0xf4>
  da4c89:	45 31 c9             	xor    %r9d,%r9d
  da4c8c:	31 ff                	xor    %edi,%edi
  da4c8e:	41 b8 ff ff ff ff    	mov    $0xffffffff,%r8d
  da4c94:	b9 22 00 00 00       	mov    $0x22,%ecx
  da4c99:	4c 8b 3d 88 2b d9 02 	mov    0x2d92b88(%rip),%r15        # 3b37828 <system__soft_links__library_exception@@Base+0x3308>
  da4ca0:	ba 03 00 00 00       	mov    $0x3,%edx
  da4ca5:	4c 89 5c 24 38       	mov    %r11,0x38(%rsp)
  da4caa:	4c 89 fe             	mov    %r15,%rsi
  da4cad:	e8 2e 45 b3 ff       	call   8d91e0 <mmap@plt>
  da4cb2:	4c 8b 5c 24 38       	mov    0x38(%rsp),%r11
  da4cb7:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  da4cbb:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
  da4cc0:	74 0d                	je     da4ccf <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x91f>
  da4cc2:	4c 01 3d 7f 2b d9 02 	add    %r15,0x2d92b7f(%rip)        # 3b37848 <system__soft_links__library_exception@@Base+0x3328>
  da4cc9:	88 5c 24 38          	mov    %bl,0x38(%rsp)
  da4ccd:	eb a8                	jmp    da4c77 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x8c7>
  da4ccf:	e8 fc f5 ff ff       	call   da42d0 <_Z25init_adjust_machine_modesv@@Base+0x9a0>
  da4cd4:	41 be 04 00 00 00    	mov    $0x4,%r14d
  da4cda:	be 48 00 00 00       	mov    $0x48,%esi
  da4cdf:	31 ed                	xor    %ebp,%ebp
  da4ce1:	e9 64 fe ff ff       	jmp    da4b4a <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x79a>
  da4ce6:	41 89 c2             	mov    %eax,%r10d
  da4ce9:	49 c1 e2 04          	shl    $0x4,%r10
  da4ced:	4d 8d b2 68 78 b3 03 	lea    0x3b37868(%r10),%r14
  da4cf4:	e9 6c fc ff ff       	jmp    da4965 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x5b5>
  da4cf9:	89 c0                	mov    %eax,%eax
  da4cfb:	48 c1 e0 04          	shl    $0x4,%rax
  da4cff:	4c 89 a0 68 78 b3 03 	mov    %r12,0x3b37868(%rax)
  da4d06:	4c 8d b0 68 78 b3 03 	lea    0x3b37868(%rax),%r14
  da4d0d:	e9 53 fc ff ff       	jmp    da4965 <_Z18ggc_internal_allocmPFvPvEmm@@Base+0x5b5>

Disassembly of section .fini:
