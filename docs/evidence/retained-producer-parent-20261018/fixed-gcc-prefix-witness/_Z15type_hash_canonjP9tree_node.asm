
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

00000000016a82a0 <_Z15type_hash_canonjP9tree_node@@Base>:
 16a82a0:	41 57                	push   %r15
 16a82a2:	41 56                	push   %r14
 16a82a4:	41 55                	push   %r13
 16a82a6:	41 54                	push   %r12
 16a82a8:	55                   	push   %rbp
 16a82a9:	53                   	push   %rbx
 16a82aa:	48 83 ec 38          	sub    $0x38,%rsp
 16a82ae:	48 39 76 68          	cmp    %rsi,0x68(%rsi)
 16a82b2:	0f 85 d0 1c 26 ff    	jne    909f88 <_Z24diagnose_versioned_declsP9tree_nodeS0_@@Base+0x22d>
 16a82b8:	89 fd                	mov    %edi,%ebp
 16a82ba:	48 89 f7             	mov    %rsi,%rdi
 16a82bd:	49 89 f4             	mov    %rsi,%r12
 16a82c0:	e8 db 18 ca ff       	call   1349ba0 <_Z11layout_typeP9tree_node@@Base>
 16a82c5:	4c 8b 35 74 52 64 02 	mov    0x2645274(%rip),%r14        # 3ced540 <tree_node_counts@@Base+0x720>
 16a82cc:	89 e8                	mov    %ebp,%eax
 16a82ce:	4c 89 64 24 28       	mov    %r12,0x28(%rsp)
 16a82d3:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
 16a82d8:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
 16a82dd:	4d 8b 46 08          	mov    0x8(%r14),%r8
 16a82e1:	49 8b 46 10          	mov    0x10(%r14),%rax
 16a82e5:	4b 8d 14 40          	lea    (%r8,%r8,2),%rdx
 16a82e9:	48 c1 e0 02          	shl    $0x2,%rax
 16a82ed:	48 39 d0             	cmp    %rdx,%rax
 16a82f0:	0f 83 8a 01 00 00    	jae    16a8480 <_Z15type_hash_canonjP9tree_node@@Base+0x1e0>
 16a82f6:	41 8b 76 28          	mov    0x28(%r14),%esi
 16a82fa:	41 83 46 20 01       	addl   $0x1,0x20(%r14)
 16a82ff:	89 e8                	mov    %ebp,%eax
 16a8301:	89 eb                	mov    %ebp,%ebx
 16a8303:	4d 8b 0e             	mov    (%r14),%r9
 16a8306:	48 c1 e6 04          	shl    $0x4,%rsi
 16a830a:	8b be 44 d5 12 03    	mov    0x312d544(%rsi),%edi
 16a8310:	48 0f af 7c 24 08    	imul   0x8(%rsp),%rdi
 16a8316:	8b 8e 4c d5 12 03    	mov    0x312d54c(%rsi),%ecx
 16a831c:	44 8b ae 40 d5 12 03 	mov    0x312d540(%rsi),%r13d
 16a8323:	48 c1 ef 20          	shr    $0x20,%rdi
 16a8327:	29 f8                	sub    %edi,%eax
 16a8329:	d1 e8                	shr    $1,%eax
 16a832b:	01 f8                	add    %edi,%eax
 16a832d:	d3 e8                	shr    %cl,%eax
 16a832f:	41 0f af c5          	imul   %r13d,%eax
 16a8333:	29 c3                	sub    %eax,%ebx
 16a8335:	41 89 da             	mov    %ebx,%r10d
 16a8338:	49 c1 e2 03          	shl    $0x3,%r10
 16a833c:	4f 8d 3c 11          	lea    (%r9,%r10,1),%r15
 16a8340:	49 8b 3f             	mov    (%r15),%rdi
 16a8343:	48 85 ff             	test   %rdi,%rdi
 16a8346:	0f 84 04 02 00 00    	je     16a8550 <_Z15type_hash_canonjP9tree_node@@Base+0x2b0>
 16a834c:	44 8b 9e 48 d5 12 03 	mov    0x312d548(%rsi),%r11d
 16a8353:	48 83 ff 01          	cmp    $0x1,%rdi
 16a8357:	74 3c                	je     16a8395 <_Z15type_hash_canonjP9tree_node@@Base+0xf5>
 16a8359:	48 8d 74 24 20       	lea    0x20(%rsp),%rsi
 16a835e:	89 4c 24 14          	mov    %ecx,0x14(%rsp)
 16a8362:	45 31 ff             	xor    %r15d,%r15d
 16a8365:	44 89 5c 24 10       	mov    %r11d,0x10(%rsp)
 16a836a:	4c 89 04 24          	mov    %r8,(%rsp)
 16a836e:	4c 89 54 24 18       	mov    %r10,0x18(%rsp)
 16a8373:	e8 18 71 ff ff       	call   169f490 <_ZN17type_cache_hasher5equalEP9type_hashS1_@@Base>
 16a8378:	4d 8b 0e             	mov    (%r14),%r9
 16a837b:	4c 8b 04 24          	mov    (%rsp),%r8
 16a837f:	84 c0                	test   %al,%al
 16a8381:	44 8b 5c 24 10       	mov    0x10(%rsp),%r11d
 16a8386:	8b 4c 24 14          	mov    0x14(%rsp),%ecx
 16a838a:	4c 8b 54 24 18       	mov    0x18(%rsp),%r10
 16a838f:	0f 85 9b 01 00 00    	jne    16a8530 <_Z15type_hash_canonjP9tree_node@@Base+0x290>
 16a8395:	44 89 de             	mov    %r11d,%esi
 16a8398:	48 0f af 74 24 08    	imul   0x8(%rsp),%rsi
 16a839e:	8d 45 01             	lea    0x1(%rbp),%eax
 16a83a1:	41 8d 55 fe          	lea    -0x2(%r13),%edx
 16a83a5:	48 c1 ee 20          	shr    $0x20,%rsi
 16a83a9:	29 f5                	sub    %esi,%ebp
 16a83ab:	d1 ed                	shr    $1,%ebp
 16a83ad:	01 f5                	add    %esi,%ebp
 16a83af:	d3 ed                	shr    %cl,%ebp
 16a83b1:	0f af ea             	imul   %edx,%ebp
 16a83b4:	41 8b 56 24          	mov    0x24(%r14),%edx
 16a83b8:	29 e8                	sub    %ebp,%eax
 16a83ba:	41 89 c5             	mov    %eax,%r13d
 16a83bd:	0f 1f 00             	nopl   (%rax)
 16a83c0:	42 8d 04 2b          	lea    (%rbx,%r13,1),%eax
 16a83c4:	83 c2 01             	add    $0x1,%edx
 16a83c7:	89 c6                	mov    %eax,%esi
 16a83c9:	48 89 c3             	mov    %rax,%rbx
 16a83cc:	41 89 56 24          	mov    %edx,0x24(%r14)
 16a83d0:	44 29 c6             	sub    %r8d,%esi
 16a83d3:	4c 39 c0             	cmp    %r8,%rax
 16a83d6:	0f 43 de             	cmovae %esi,%ebx
 16a83d9:	89 de                	mov    %ebx,%esi
 16a83db:	48 0f 43 c6          	cmovae %rsi,%rax
 16a83df:	48 8d 2c c5 00 00 00 	lea    0x0(,%rax,8),%rbp
 16a83e6:	00 
 16a83e7:	49 8d 04 29          	lea    (%r9,%rbp,1),%rax
 16a83eb:	48 8b 38             	mov    (%rax),%rdi
 16a83ee:	48 85 ff             	test   %rdi,%rdi
 16a83f1:	74 3d                	je     16a8430 <_Z15type_hash_canonjP9tree_node@@Base+0x190>
 16a83f3:	48 83 ff 01          	cmp    $0x1,%rdi
 16a83f7:	74 27                	je     16a8420 <_Z15type_hash_canonjP9tree_node@@Base+0x180>
 16a83f9:	48 8d 74 24 20       	lea    0x20(%rsp),%rsi
 16a83fe:	4c 89 04 24          	mov    %r8,(%rsp)
 16a8402:	e8 89 70 ff ff       	call   169f490 <_ZN17type_cache_hasher5equalEP9type_hashS1_@@Base>
 16a8407:	4d 8b 0e             	mov    (%r14),%r9
 16a840a:	84 c0                	test   %al,%al
 16a840c:	0f 85 86 00 00 00    	jne    16a8498 <_Z15type_hash_canonjP9tree_node@@Base+0x1f8>
 16a8412:	41 8b 56 24          	mov    0x24(%r14),%edx
 16a8416:	4c 8b 04 24          	mov    (%rsp),%r8
 16a841a:	eb a4                	jmp    16a83c0 <_Z15type_hash_canonjP9tree_node@@Base+0x120>
 16a841c:	0f 1f 40 00          	nopl   0x0(%rax)
 16a8420:	4d 85 ff             	test   %r15,%r15
 16a8423:	4c 0f 44 f8          	cmove  %rax,%r15
 16a8427:	eb 97                	jmp    16a83c0 <_Z15type_hash_canonjP9tree_node@@Base+0x120>
 16a8429:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 16a8430:	4d 85 ff             	test   %r15,%r15
 16a8433:	0f 84 a2 01 00 00    	je     16a85db <_Z15type_hash_canonjP9tree_node@@Base+0x33b>
 16a8439:	49 83 6e 18 01       	subq   $0x1,0x18(%r14)
 16a843e:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
 16a8445:	b9 01 00 00 00       	mov    $0x1,%ecx
 16a844a:	31 d2                	xor    %edx,%edx
 16a844c:	31 f6                	xor    %esi,%esi
 16a844e:	bf 10 00 00 00       	mov    $0x10,%edi
 16a8453:	e8 58 bf 6f ff       	call   da43b0 <_Z18ggc_internal_allocmPFvPvEmm@@Base>
 16a8458:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
 16a845d:	4c 89 e3             	mov    %r12,%rbx
 16a8460:	4c 89 60 08          	mov    %r12,0x8(%rax)
 16a8464:	48 89 08             	mov    %rcx,(%rax)
 16a8467:	49 89 07             	mov    %rax,(%r15)
 16a846a:	48 83 c4 38          	add    $0x38,%rsp
 16a846e:	48 89 d8             	mov    %rbx,%rax
 16a8471:	5b                   	pop    %rbx
 16a8472:	5d                   	pop    %rbp
 16a8473:	41 5c                	pop    %r12
 16a8475:	41 5d                	pop    %r13
 16a8477:	41 5e                	pop    %r14
 16a8479:	41 5f                	pop    %r15
 16a847b:	c3                   	ret
 16a847c:	0f 1f 40 00          	nopl   0x0(%rax)
 16a8480:	4c 89 f7             	mov    %r14,%rdi
 16a8483:	e8 78 a9 00 00       	call   16b2e00 <_ZN10hash_tableI17type_cache_hasherLb0E11xcallocatorE6expandEv@@Base>
 16a8488:	4d 8b 46 08          	mov    0x8(%r14),%r8
 16a848c:	e9 65 fe ff ff       	jmp    16a82f6 <_Z15type_hash_canonjP9tree_node@@Base+0x56>
 16a8491:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 16a8498:	4d 8d 3c 29          	lea    (%r9,%rbp,1),%r15
 16a849c:	49 8b 07             	mov    (%r15),%rax
 16a849f:	48 85 c0             	test   %rax,%rax
 16a84a2:	74 a1                	je     16a8445 <_Z15type_hash_canonjP9tree_node@@Base+0x1a5>
 16a84a4:	48 8b 58 08          	mov    0x8(%rax),%rbx
 16a84a8:	48 39 5b 68          	cmp    %rbx,0x68(%rbx)
 16a84ac:	0f 85 c2 1a 26 ff    	jne    909f74 <_Z24diagnose_versioned_declsP9tree_nodeS0_@@Base+0x219>
 16a84b2:	49 39 dc             	cmp    %rbx,%r12
 16a84b5:	0f 84 b9 1a 26 ff    	je     909f74 <_Z24diagnose_versioned_declsP9tree_nodeS0_@@Base+0x219>
 16a84bb:	41 8b 44 24 30       	mov    0x30(%r12),%eax
 16a84c0:	8d 50 01             	lea    0x1(%rax),%edx
 16a84c3:	3b 15 67 b8 f3 01    	cmp    0x1f3b867(%rip),%edx        # 35e3d30 <slp_patterns@@Base+0xd0>
 16a84c9:	75 06                	jne    16a84d1 <_Z15type_hash_canonjP9tree_node@@Base+0x231>
 16a84cb:	89 05 5f b8 f3 01    	mov    %eax,0x1f3b85f(%rip)        # 35e3d30 <slp_patterns@@Base+0xd0>
 16a84d1:	41 0f b7 04 24       	movzwl (%r12),%eax
 16a84d6:	83 e8 08             	sub    $0x8,%eax
 16a84d9:	66 83 f8 01          	cmp    $0x1,%ax
 16a84dd:	76 11                	jbe    16a84f0 <_Z15type_hash_canonjP9tree_node@@Base+0x250>
 16a84df:	4c 89 e7             	mov    %r12,%rdi
 16a84e2:	e8 09 bc fe ff       	call   16940f0 <_Z9free_nodeP9tree_node@@Base>
 16a84e7:	e9 7e ff ff ff       	jmp    16a846a <_Z15type_hash_canonjP9tree_node@@Base+0x1ca>
 16a84ec:	0f 1f 40 00          	nopl   0x0(%rax)
 16a84f0:	49 8b bc 24 90 00 00 	mov    0x90(%r12),%rdi
 16a84f7:	00 
 16a84f8:	48 85 ff             	test   %rdi,%rdi
 16a84fb:	74 06                	je     16a8503 <_Z15type_hash_canonjP9tree_node@@Base+0x263>
 16a84fd:	4c 39 67 08          	cmp    %r12,0x8(%rdi)
 16a8501:	74 39                	je     16a853c <_Z15type_hash_canonjP9tree_node@@Base+0x29c>
 16a8503:	49 8b bc 24 98 00 00 	mov    0x98(%r12),%rdi
 16a850a:	00 
 16a850b:	48 85 ff             	test   %rdi,%rdi
 16a850e:	74 06                	je     16a8516 <_Z15type_hash_canonjP9tree_node@@Base+0x276>
 16a8510:	4c 39 67 08          	cmp    %r12,0x8(%rdi)
 16a8514:	74 44                	je     16a855a <_Z15type_hash_canonjP9tree_node@@Base+0x2ba>
 16a8516:	41 f6 44 24 03 08    	testb  $0x8,0x3(%r12)
 16a851c:	74 c1                	je     16a84df <_Z15type_hash_canonjP9tree_node@@Base+0x23f>
 16a851e:	49 8b bc 24 88 00 00 	mov    0x88(%r12),%rdi
 16a8525:	00 
 16a8526:	e8 25 cb 6f ff       	call   da5050 <_Z8ggc_freePv@@Base>
 16a852b:	eb b2                	jmp    16a84df <_Z15type_hash_canonjP9tree_node@@Base+0x23f>
 16a852d:	0f 1f 00             	nopl   (%rax)
 16a8530:	4f 8d 3c 11          	lea    (%r9,%r10,1),%r15
 16a8534:	49 8b 07             	mov    (%r15),%rax
 16a8537:	e9 63 ff ff ff       	jmp    16a849f <_Z15type_hash_canonjP9tree_node@@Base+0x1ff>
 16a853c:	41 f6 44 24 05 01    	testb  $0x1,0x5(%r12)
 16a8542:	74 59                	je     16a859d <_Z15type_hash_canonjP9tree_node@@Base+0x2fd>
 16a8544:	e8 07 cb 6f ff       	call   da5050 <_Z8ggc_freePv@@Base>
 16a8549:	eb b8                	jmp    16a8503 <_Z15type_hash_canonjP9tree_node@@Base+0x263>
 16a854b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 16a8550:	49 83 46 10 01       	addq   $0x1,0x10(%r14)
 16a8555:	e9 eb fe ff ff       	jmp    16a8445 <_Z15type_hash_canonjP9tree_node@@Base+0x1a5>
 16a855a:	e8 a1 bc fe ff       	call   1694200 <_ZN14int_cst_hasher4hashEP9tree_node@@Base>
 16a855f:	48 8b 2d ca 4f 64 02 	mov    0x2644fca(%rip),%rbp        # 3ced530 <tree_node_counts@@Base+0x710>
 16a8566:	31 c9                	xor    %ecx,%ecx
 16a8568:	49 8d b4 24 98 00 00 	lea    0x98(%r12),%rsi
 16a856f:	00 
 16a8570:	89 c2                	mov    %eax,%edx
 16a8572:	48 89 ef             	mov    %rbp,%rdi
 16a8575:	e8 c6 ae 00 00       	call   16b3440 <_ZN10hash_tableI14int_cst_hasherLb0E11xcallocatorE19find_slot_with_hashERKP9tree_nodej13insert_option@@Base>
 16a857a:	48 85 c0             	test   %rax,%rax
 16a857d:	74 0c                	je     16a858b <_Z15type_hash_canonjP9tree_node@@Base+0x2eb>
 16a857f:	48 c7 00 01 00 00 00 	movq   $0x1,(%rax)
 16a8586:	48 83 45 18 01       	addq   $0x1,0x18(%rbp)
 16a858b:	49 8b bc 24 98 00 00 	mov    0x98(%r12),%rdi
 16a8592:	00 
 16a8593:	e8 b8 ca 6f ff       	call   da5050 <_Z8ggc_freePv@@Base>
 16a8598:	e9 79 ff ff ff       	jmp    16a8516 <_Z15type_hash_canonjP9tree_node@@Base+0x276>
 16a859d:	e8 5e bc fe ff       	call   1694200 <_ZN14int_cst_hasher4hashEP9tree_node@@Base>
 16a85a2:	48 8b 2d 87 4f 64 02 	mov    0x2644f87(%rip),%rbp        # 3ced530 <tree_node_counts@@Base+0x710>
 16a85a9:	31 c9                	xor    %ecx,%ecx
 16a85ab:	49 8d b4 24 90 00 00 	lea    0x90(%r12),%rsi
 16a85b2:	00 
 16a85b3:	89 c2                	mov    %eax,%edx
 16a85b5:	48 89 ef             	mov    %rbp,%rdi
 16a85b8:	e8 83 ae 00 00       	call   16b3440 <_ZN10hash_tableI14int_cst_hasherLb0E11xcallocatorE19find_slot_with_hashERKP9tree_nodej13insert_option@@Base>
 16a85bd:	48 85 c0             	test   %rax,%rax
 16a85c0:	74 0c                	je     16a85ce <_Z15type_hash_canonjP9tree_node@@Base+0x32e>
 16a85c2:	48 c7 00 01 00 00 00 	movq   $0x1,(%rax)
 16a85c9:	48 83 45 18 01       	addq   $0x1,0x18(%rbp)
 16a85ce:	49 8b bc 24 90 00 00 	mov    0x90(%r12),%rdi
 16a85d5:	00 
 16a85d6:	e9 69 ff ff ff       	jmp    16a8544 <_Z15type_hash_canonjP9tree_node@@Base+0x2a4>
 16a85db:	49 83 46 10 01       	addq   $0x1,0x10(%r14)
 16a85e0:	49 89 c7             	mov    %rax,%r15
 16a85e3:	e9 5d fe ff ff       	jmp    16a8445 <_Z15type_hash_canonjP9tree_node@@Base+0x1a5>

Disassembly of section .fini:
