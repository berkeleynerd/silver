
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

00000000009a84e0 <gigi@@Base>:
  9a84e0:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  9a84e7:	89 35 d7 64 c4 02    	mov    %esi,0x2c464d7(%rip)        # 35ee9c4 <max_gnat_nodes@@Base>
  9a84ed:	48 8b 84 24 a0 00 00 	mov    0xa0(%rsp),%rax
  9a84f4:	00 
  9a84f5:	83 bc 24 10 01 00 00 	cmpl   $0x1,0x110(%rsp)
  9a84fc:	01 
  9a84fd:	48 89 5c 24 70       	mov    %rbx,0x70(%rsp)
  9a8502:	0f 94 05 b7 64 c4 02 	sete   0x2c464b7(%rip)        # 35ee9c0 <type_annotate_only@@Base>
  9a8509:	80 3d a4 1e c3 02 00 	cmpb   $0x0,0x2c31ea4(%rip)        # 35da3b4 <opt__generate_sco_instance_table@@Base>
  9a8510:	8b 9c 24 d0 00 00 00 	mov    0xd0(%rsp),%ebx
  9a8517:	48 89 05 d2 64 c4 02 	mov    %rax,0x2c464d2(%rip)        # 35ee9f0 <Prev_Node_Ptr@@Base>
  9a851e:	48 8b 84 24 a8 00 00 	mov    0xa8(%rsp),%rax
  9a8525:	00 
  9a8526:	48 89 6c 24 78       	mov    %rbp,0x78(%rsp)
  9a852b:	89 fd                	mov    %edi,%ebp
  9a852d:	48 89 05 b4 64 c4 02 	mov    %rax,0x2c464b4(%rip)        # 35ee9e8 <Elists_Ptr@@Base>
  9a8534:	48 8b 84 24 b0 00 00 	mov    0xb0(%rsp),%rax
  9a853b:	00 
  9a853c:	4c 89 a4 24 80 00 00 	mov    %r12,0x80(%rsp)
  9a8543:	00 
  9a8544:	48 89 05 95 64 c4 02 	mov    %rax,0x2c46495(%rip)        # 35ee9e0 <Elmts_Ptr@@Base>
  9a854b:	48 8b 84 24 b8 00 00 	mov    0xb8(%rsp),%rax
  9a8552:	00 
  9a8553:	4c 89 ac 24 88 00 00 	mov    %r13,0x88(%rsp)
  9a855a:	00 
  9a855b:	48 89 05 76 64 c4 02 	mov    %rax,0x2c46476(%rip)        # 35ee9d8 <Strings_Ptr@@Base>
  9a8562:	48 8b 84 24 c0 00 00 	mov    0xc0(%rsp),%rax
  9a8569:	00 
  9a856a:	48 89 0d 97 64 c4 02 	mov    %rcx,0x2c46497(%rip)        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a8571:	48 89 05 58 64 c4 02 	mov    %rax,0x2c46458(%rip)        # 35ee9d0 <String_Chars_Ptr@@Base>
  9a8578:	48 8b 84 24 c8 00 00 	mov    0xc8(%rsp),%rax
  9a857f:	00 
  9a8580:	4c 89 05 79 64 c4 02 	mov    %r8,0x2c46479(%rip)        # 35eea00 <Slots_Ptr@@Base>
  9a8587:	4c 89 0d 6a 64 c4 02 	mov    %r9,0x2c4646a(%rip)        # 35ee9f8 <Next_Node_Ptr@@Base>
  9a858e:	48 89 05 33 64 c4 02 	mov    %rax,0x2c46433(%rip)        # 35ee9c8 <List_Headers_Ptr@@Base>
  9a8595:	0f 85 dd 10 00 00    	jne    9a9678 <gigi@@Base+0x1198>
  9a859b:	85 db                	test   %ebx,%ebx
  9a859d:	0f 8e 02 01 00 00    	jle    9a86a5 <gigi@@Base+0x1c5>
  9a85a3:	4c 8b a4 24 d8 00 00 	mov    0xd8(%rsp),%r12
  9a85aa:	00 
  9a85ab:	89 db                	mov    %ebx,%ebx
  9a85ad:	45 31 ed             	xor    %r13d,%r13d
  9a85b0:	48 8b 05 89 2c 37 03 	mov    0x3372c89(%rip),%rax        # 3d1b240 <line_table@@Base>
  9a85b7:	44 39 68 10          	cmp    %r13d,0x10(%rax)
  9a85bb:	74 4c                	je     9a8609 <gigi@@Base+0x129>
  9a85bd:	4d 85 ed             	test   %r13,%r13
  9a85c0:	0f 84 95 21 f3 ff    	je     8da75b <calloc@plt+0x12db>
  9a85c6:	41 8b 44 24 f4       	mov    -0xc(%r12),%eax
  9a85cb:	05 fd 83 d7 17       	add    $0x17d783fd,%eax
  9a85d0:	48 98                	cltq
  9a85d2:	48 c1 e0 04          	shl    $0x4,%rax
  9a85d6:	48 03 05 23 1b c3 02 	add    0x2c31b23(%rip),%rax        # 35da100 <namet__name_entries__table@@Base>
  9a85dd:	8b 38                	mov    (%rax),%edi
  9a85df:	83 c7 01             	add    $0x1,%edi
  9a85e2:	48 63 ff             	movslq %edi,%rdi
  9a85e5:	48 03 3d 1c 1b c3 02 	add    0x2c31b1c(%rip),%rdi        # 35da108 <namet__name_chars__table@@Base>
  9a85ec:	e8 ef 38 00 00       	call   9abee0 <__gnat_to_canonical_file_spec@@Base>
  9a85f1:	48 89 c7             	mov    %rax,%rdi
  9a85f4:	e8 a7 81 9a 00       	call   13507a0 <_Z14get_identifierPKc@@Base>
  9a85f9:	bf 7d 03 9f 02       	mov    $0x29f037d,%edi
  9a85fe:	48 8b 70 18          	mov    0x18(%rax),%rsi
  9a8602:	31 c0                	xor    %eax,%eax
  9a8604:	e8 47 cf ca 01       	call   2655550 <_Z5errorPKcz@@Base>
  9a8609:	41 8b 04 24          	mov    (%r12),%eax
  9a860d:	49 83 c5 01          	add    $0x1,%r13
  9a8611:	49 83 c4 0c          	add    $0xc,%r12
  9a8615:	05 fd 83 d7 17       	add    $0x17d783fd,%eax
  9a861a:	48 98                	cltq
  9a861c:	48 c1 e0 04          	shl    $0x4,%rax
  9a8620:	48 03 05 d9 1a c3 02 	add    0x2c31ad9(%rip),%rax        # 35da100 <namet__name_entries__table@@Base>
  9a8627:	8b 38                	mov    (%rax),%edi
  9a8629:	83 c7 01             	add    $0x1,%edi
  9a862c:	48 63 ff             	movslq %edi,%rdi
  9a862f:	48 03 3d d2 1a c3 02 	add    0x2c31ad2(%rip),%rdi        # 35da108 <namet__name_chars__table@@Base>
  9a8636:	e8 a5 38 00 00       	call   9abee0 <__gnat_to_canonical_file_spec@@Base>
  9a863b:	48 89 c7             	mov    %rax,%rdi
  9a863e:	e8 5d 81 9a 00       	call   13507a0 <_Z14get_identifierPKc@@Base>
  9a8643:	48 8b 3d f6 2b 37 03 	mov    0x3372bf6(%rip),%rdi        # 3d1b240 <line_table@@Base>
  9a864a:	31 d2                	xor    %edx,%edx
  9a864c:	31 f6                	xor    %esi,%esi
  9a864e:	48 8b 48 18          	mov    0x18(%rax),%rcx
  9a8652:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8658:	e8 f3 b9 d3 01       	call   26e4050 <_Z11linemap_addP9line_maps9lc_reasonjPKcj@@Base>
  9a865d:	41 8b 74 24 fc       	mov    -0x4(%r12),%esi
  9a8662:	ba fc 00 00 00       	mov    $0xfc,%edx
  9a8667:	48 8b 3d d2 2b 37 03 	mov    0x3372bd2(%rip),%rdi        # 3d1b240 <line_table@@Base>
  9a866e:	e8 2d bf d3 01       	call   26e45a0 <_Z18linemap_line_startP9line_mapsjj@@Base>
  9a8673:	48 8b 3d c6 2b 37 03 	mov    0x3372bc6(%rip),%rdi        # 3d1b240 <line_table@@Base>
  9a867a:	be fb 00 00 00       	mov    $0xfb,%esi
  9a867f:	e8 6c c3 d3 01       	call   26e49f0 <_Z27linemap_position_for_columnP9line_mapsj@@Base>
  9a8684:	48 8b 3d b5 2b 37 03 	mov    0x3372bb5(%rip),%rdi        # 3d1b240 <line_table@@Base>
  9a868b:	31 c9                	xor    %ecx,%ecx
  9a868d:	31 d2                	xor    %edx,%edx
  9a868f:	45 31 c0             	xor    %r8d,%r8d
  9a8692:	be 01 00 00 00       	mov    $0x1,%esi
  9a8697:	e8 b4 b9 d3 01       	call   26e4050 <_Z11linemap_addP9line_maps9lc_reasonjPKcj@@Base>
  9a869c:	4c 39 eb             	cmp    %r13,%rbx
  9a869f:	0f 85 0b ff ff ff    	jne    9a85b0 <gigi@@Base+0xd0>
  9a86a5:	48 63 c5             	movslq %ebp,%rax
  9a86a8:	48 c1 e0 04          	shl    $0x4,%rax
  9a86ac:	48 03 05 55 63 c4 02 	add    0x2c46355(%rip),%rax        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a86b3:	80 38 b4             	cmpb   $0xb4,(%rax)
  9a86b6:	0f 85 f3 20 f3 ff    	jne    8da7af <calloc@plt+0x132f>
  9a86bc:	48 63 50 0c          	movslq 0xc(%rax),%rdx
  9a86c0:	48 8b 05 39 63 c4 02 	mov    0x2c46339(%rip),%rax        # 35eea00 <Slots_Ptr@@Base>
  9a86c7:	8b 7c 90 1c          	mov    0x1c(%rax,%rdx,4),%edi
  9a86cb:	e8 30 95 36 00       	call   d11c00 <sem_util__defining_entity@@Base>
  9a86d0:	31 f6                	xor    %esi,%esi
  9a86d2:	89 c7                	mov    %eax,%edi
  9a86d4:	e8 97 a7 f8 ff       	call   932e70 <_Z18create_concat_nameiPKc@@Base>
  9a86d9:	be ff ff ff ff       	mov    $0xffffffff,%esi
  9a86de:	48 8b 78 18          	mov    0x18(%rax),%rdi
  9a86e2:	e8 49 80 9a 00       	call   1350730 <_Z16ggc_alloc_stringPKci@@Base>
  9a86e7:	66 0f 6f 05 21 9c 25 	movdqa 0x2259c21(%rip),%xmm0        # 2c02310 <gt_ggc_r_gt_ada_trans_h@@Base+0x190>
  9a86ee:	02 
  9a86ef:	c7 05 8b 63 c4 02 49 	movl   $0x49,0x2c4638b(%rip)        # 35eea84 <Node_Offsets_Ptr@@Base+0x7c>
  9a86f6:	00 00 00 
  9a86f9:	48 89 05 e0 53 34 03 	mov    %rax,0x33453e0(%rip)        # 3cedae0 <first_global_object_name@@Base>
  9a8700:	48 b8 68 00 00 00 69 	movabs $0x6900000068,%rax
  9a8707:	00 00 00 
  9a870a:	0f 11 05 87 63 c4 02 	movups %xmm0,0x2c46387(%rip)        # 35eea98 <Node_Offsets_Ptr@@Base+0x90>
  9a8711:	66 0f 6f 05 07 9c 25 	movdqa 0x2259c07(%rip),%xmm0        # 2c02320 <gt_ggc_r_gt_ada_trans_h@@Base+0x1a0>
  9a8718:	02 
  9a8719:	48 89 05 d8 63 c4 02 	mov    %rax,0x2c463d8(%rip)        # 35eeaf8 <Node_Offsets_Ptr@@Base+0xf0>
  9a8720:	0f 11 05 81 63 c4 02 	movups %xmm0,0x2c46381(%rip)        # 35eeaa8 <Node_Offsets_Ptr@@Base+0xa0>
  9a8727:	66 0f 6f 05 01 9c 25 	movdqa 0x2259c01(%rip),%xmm0        # 2c02330 <gt_ggc_r_gt_ada_trans_h@@Base+0x1b0>
  9a872e:	02 
  9a872f:	c7 05 57 63 c4 02 4a 	movl   $0x4a,0x2c46357(%rip)        # 35eea90 <Node_Offsets_Ptr@@Base+0x88>
  9a8736:	00 00 00 
  9a8739:	0f 11 05 78 63 c4 02 	movups %xmm0,0x2c46378(%rip)        # 35eeab8 <Node_Offsets_Ptr@@Base+0xb0>
  9a8740:	66 0f 6f 05 f8 9b 25 	movdqa 0x2259bf8(%rip),%xmm0        # 2c02340 <gt_ggc_r_gt_ada_trans_h@@Base+0x1c0>
  9a8747:	02 
  9a8748:	0f 11 05 79 63 c4 02 	movups %xmm0,0x2c46379(%rip)        # 35eeac8 <Node_Offsets_Ptr@@Base+0xc0>
  9a874f:	66 0f 6f 05 f9 9b 25 	movdqa 0x2259bf9(%rip),%xmm0        # 2c02350 <gt_ggc_r_gt_ada_trans_h@@Base+0x1d0>
  9a8756:	02 
  9a8757:	0f 11 05 7a 63 c4 02 	movups %xmm0,0x2c4637a(%rip)        # 35eead8 <Node_Offsets_Ptr@@Base+0xd0>
  9a875e:	e8 7d b5 f8 ff       	call   933ce0 <_Z14init_gnat_declv@@Base>
  9a8763:	e8 e8 9e fc ff       	call   972650 <_Z15init_gnat_utilsv@@Base>
  9a8768:	80 3d 51 62 c4 02 00 	cmpb   $0x0,0x2c46251(%rip)        # 35ee9c0 <type_annotate_only@@Base>
  9a876f:	74 24                	je     9a8795 <gigi@@Base+0x2b5>
  9a8771:	48 8b 05 f8 42 34 03 	mov    0x33442f8(%rip),%rax        # 3ceca70 <global_trees@@Base+0x1f0>
  9a8778:	48 8b 15 d9 41 34 03 	mov    0x33441d9(%rip),%rdx        # 3cec958 <global_trees@@Base+0xd8>
  9a877f:	48 89 50 18          	mov    %rdx,0x18(%rax)
  9a8783:	48 8b 05 e6 42 34 03 	mov    0x33442e6(%rip),%rax        # 3ceca70 <global_trees@@Base+0x1f0>
  9a878a:	48 8b 15 b7 41 34 03 	mov    0x33441b7(%rip),%rdx        # 3cec948 <global_trees@@Base+0xc8>
  9a8791:	48 89 50 20          	mov    %rdx,0x20(%rax)
  9a8795:	80 3d 92 3d c3 02 00 	cmpb   $0x0,0x2c33d92(%rip)        # 35dc52e <targparm__stack_check_probes_on_target@@Base>
  9a879c:	0f 84 49 10 00 00    	je     9a97eb <gigi@@Base+0x130b>
  9a87a2:	e8 49 1b 00 00       	call   9aa2f0 <get_target_double_float_alignment@@Base>
  9a87a7:	89 05 07 3c c4 02    	mov    %eax,0x2c43c07(%rip)        # 35ec3b4 <double_float_alignment@@Base>
  9a87ad:	e8 4e 1b 00 00       	call   9aa300 <get_target_double_scalar_alignment@@Base>
  9a87b2:	48 8b 35 37 43 34 03 	mov    0x3344337(%rip),%rsi        # 3cecaf0 <global_trees@@Base+0x270>
  9a87b9:	31 d2                	xor    %edx,%edx
  9a87bb:	bf 19 30 a1 02       	mov    $0x2a13019,%edi
  9a87c0:	89 05 ea 3b c4 02    	mov    %eax,0x2c43bea(%rip)        # 35ec3b0 <double_scalar_alignment@@Base>
  9a87c6:	e8 f5 b4 fc ff       	call   973cc0 <_Z19record_builtin_typePKcP9tree_nodeb@@Base>
  9a87cb:	48 8b 35 36 40 34 03 	mov    0x3344036(%rip),%rsi        # 3cec808 <integer_types@@Base+0x28>
  9a87d2:	31 d2                	xor    %edx,%edx
  9a87d4:	bf bd 76 9f 02       	mov    $0x29f76bd,%edi
  9a87d9:	e8 e2 b4 fc ff       	call   973cc0 <_Z19record_builtin_typePKcP9tree_nodeb@@Base>
  9a87de:	48 8b 35 fb 3f 34 03 	mov    0x3343ffb(%rip),%rsi        # 3cec7e0 <integer_types@@Base>
  9a87e5:	31 d2                	xor    %edx,%edx
  9a87e7:	bf 6c 4c 9f 02       	mov    $0x29f4c6c,%edi
  9a87ec:	e8 cf b4 fc ff       	call   973cc0 <_Z19record_builtin_typePKcP9tree_nodeb@@Base>
  9a87f1:	48 8b 35 c0 42 34 03 	mov    0x33442c0(%rip),%rsi        # 3cecab8 <global_trees@@Base+0x238>
  9a87f8:	31 d2                	xor    %edx,%edx
  9a87fa:	bf 6d c4 a9 02       	mov    $0x2a9c46d,%edi
  9a87ff:	e8 bc b4 fc ff       	call   973cc0 <_Z19record_builtin_typePKcP9tree_nodeb@@Base>
  9a8804:	48 8b 35 65 42 34 03 	mov    0x3344265(%rip),%rsi        # 3ceca70 <global_trees@@Base+0x1f0>
  9a880b:	31 d2                	xor    %edx,%edx
  9a880d:	bf 3b 48 a0 02       	mov    $0x2a0483b,%edi
  9a8812:	e8 a9 b4 fc ff       	call   973cc0 <_Z19record_builtin_typePKcP9tree_nodeb@@Base>
  9a8817:	48 8b 05 d2 42 34 03 	mov    0x33442d2(%rip),%rax        # 3cecaf0 <global_trees@@Base+0x270>
  9a881e:	8b bc 24 e0 00 00 00 	mov    0xe0(%rsp),%edi
  9a8825:	48 8b 58 78          	mov    0x78(%rax),%rbx
  9a8829:	e8 62 d6 04 00       	call   9f5e90 <einfo__utils__base_type@@Base>
  9a882e:	31 d2                	xor    %edx,%edx
  9a8830:	48 89 de             	mov    %rbx,%rsi
  9a8833:	89 c7                	mov    %eax,%edi
  9a8835:	e8 66 a3 fc ff       	call   972ba0 <_Z13save_gnu_treeiP9tree_nodeb@@Base>
  9a883a:	48 8b 05 c7 3f 34 03 	mov    0x3343fc7(%rip),%rax        # 3cec808 <integer_types@@Base+0x28>
  9a8841:	8b bc 24 00 01 00 00 	mov    0x100(%rsp),%edi
  9a8848:	48 8b 58 78          	mov    0x78(%rax),%rbx
  9a884c:	e8 3f d6 04 00       	call   9f5e90 <einfo__utils__base_type@@Base>
  9a8851:	31 d2                	xor    %edx,%edx
  9a8853:	48 89 de             	mov    %rbx,%rsi
  9a8856:	89 c7                	mov    %eax,%edi
  9a8858:	e8 43 a3 fc ff       	call   972ba0 <_Z13save_gnu_treeiP9tree_nodeb@@Base>
  9a885d:	48 8b 3d 7c 3f 34 03 	mov    0x3343f7c(%rip),%rdi        # 3cec7e0 <integer_types@@Base>
  9a8864:	e8 97 16 fd ff       	call   979f00 <_Z21finish_character_typeP9tree_node@@Base>
  9a8869:	48 8b 05 70 3f 34 03 	mov    0x3343f70(%rip),%rax        # 3cec7e0 <integer_types@@Base>
  9a8870:	8b bc 24 f0 00 00 00 	mov    0xf0(%rsp),%edi
  9a8877:	48 8b 58 78          	mov    0x78(%rax),%rbx
  9a887b:	e8 10 d6 04 00       	call   9f5e90 <einfo__utils__base_type@@Base>
  9a8880:	31 d2                	xor    %edx,%edx
  9a8882:	48 89 de             	mov    %rbx,%rsi
  9a8885:	89 c7                	mov    %eax,%edi
  9a8887:	e8 14 a3 fc ff       	call   972ba0 <_Z13save_gnu_treeiP9tree_nodeb@@Base>
  9a888c:	48 8b 05 25 42 34 03 	mov    0x3344225(%rip),%rax        # 3cecab8 <global_trees@@Base+0x238>
  9a8893:	8b bc 24 e8 00 00 00 	mov    0xe8(%rsp),%edi
  9a889a:	48 8b 58 78          	mov    0x78(%rax),%rbx
  9a889e:	e8 ed d5 04 00       	call   9f5e90 <einfo__utils__base_type@@Base>
  9a88a3:	31 d2                	xor    %edx,%edx
  9a88a5:	48 89 de             	mov    %rbx,%rsi
  9a88a8:	89 c7                	mov    %eax,%edi
  9a88aa:	e8 f1 a2 fc ff       	call   972ba0 <_Z13save_gnu_treeiP9tree_nodeb@@Base>
  9a88af:	8b bc 24 e8 00 00 00 	mov    0xe8(%rsp),%edi
  9a88b6:	e8 d5 d5 04 00       	call   9f5e90 <einfo__utils__base_type@@Base>
  9a88bb:	48 8b 0d 46 61 c4 02 	mov    0x2c46146(%rip),%rcx        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a88c2:	48 8b 15 37 61 c4 02 	mov    0x2c46137(%rip),%rdx        # 35eea00 <Slots_Ptr@@Base>
  9a88c9:	48 98                	cltq
  9a88cb:	48 8b 35 e6 41 34 03 	mov    0x33441e6(%rip),%rsi        # 3cecab8 <global_trees@@Base+0x238>
  9a88d2:	48 c1 e0 04          	shl    $0x4,%rax
  9a88d6:	48 63 44 01 0c       	movslq 0xc(%rcx,%rax,1),%rax
  9a88db:	48 63 84 82 b4 00 00 	movslq 0xb4(%rdx,%rax,4),%rax
  9a88e2:	00 
  9a88e3:	48 89 c3             	mov    %rax,%rbx
  9a88e6:	48 c1 e0 04          	shl    $0x4,%rax
  9a88ea:	48 63 44 01 0c       	movslq 0xc(%rcx,%rax,1),%rax
  9a88ef:	8b 7c 82 68          	mov    0x68(%rdx,%rax,4),%edi
  9a88f3:	e8 78 67 f8 ff       	call   92f070 <UI_To_gnu@@Base>
  9a88f8:	48 39 05 89 40 34 03 	cmp    %rax,0x3344089(%rip)        # 3cec988 <global_trees@@Base+0x108>
  9a88ff:	49 89 c5             	mov    %rax,%r13
  9a8902:	0f 85 8b 1e f3 ff    	jne    8da793 <calloc@plt+0x1313>
  9a8908:	89 df                	mov    %ebx,%edi
  9a890a:	4c 8b 25 a7 41 34 03 	mov    0x33441a7(%rip),%r12        # 3cecab8 <global_trees@@Base+0x238>
  9a8911:	e8 3a a5 f8 ff       	call   932e50 <_Z15get_entity_namei@@Base>
  9a8916:	48 83 ec 08          	sub    $0x8,%rsp
  9a891a:	45 31 c9             	xor    %r9d,%r9d
  9a891d:	4c 89 e9             	mov    %r13,%rcx
  9a8920:	6a 01                	push   $0x1
  9a8922:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8928:	31 f6                	xor    %esi,%esi
  9a892a:	4c 89 e2             	mov    %r12,%rdx
  9a892d:	53                   	push   %rbx
  9a892e:	48 89 c7             	mov    %rax,%rdi
  9a8931:	6a 00                	push   $0x0
  9a8933:	6a 00                	push   $0x0
  9a8935:	6a 01                	push   $0x1
  9a8937:	6a 00                	push   $0x0
  9a8939:	6a 00                	push   $0x0
  9a893b:	6a 00                	push   $0x0
  9a893d:	6a 00                	push   $0x0
  9a893f:	e8 ec 2b fd ff       	call   97b530 <_Z15create_var_declP9tree_nodeS0_S0_S0_bbbbbbbbP6attribib@@Base>
  9a8944:	48 83 c4 50          	add    $0x50,%rsp
  9a8948:	31 d2                	xor    %edx,%edx
  9a894a:	89 df                	mov    %ebx,%edi
  9a894c:	48 89 c6             	mov    %rax,%rsi
  9a894f:	e8 4c a2 fc ff       	call   972ba0 <_Z13save_gnu_treeiP9tree_nodeb@@Base>
  9a8954:	89 df                	mov    %ebx,%edi
  9a8956:	e8 b5 ec 04 00       	call   9f7610 <einfo__utils__next_literal@@Base>
  9a895b:	48 8b 35 56 41 34 03 	mov    0x3344156(%rip),%rsi        # 3cecab8 <global_trees@@Base+0x238>
  9a8962:	89 c3                	mov    %eax,%ebx
  9a8964:	48 98                	cltq
  9a8966:	48 c1 e0 04          	shl    $0x4,%rax
  9a896a:	48 03 05 97 60 c4 02 	add    0x2c46097(%rip),%rax        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a8971:	48 63 50 0c          	movslq 0xc(%rax),%rdx
  9a8975:	48 8b 05 84 60 c4 02 	mov    0x2c46084(%rip),%rax        # 35eea00 <Slots_Ptr@@Base>
  9a897c:	8b 7c 90 68          	mov    0x68(%rax,%rdx,4),%edi
  9a8980:	e8 eb 66 f8 ff       	call   92f070 <UI_To_gnu@@Base>
  9a8985:	48 39 05 04 40 34 03 	cmp    %rax,0x3344004(%rip)        # 3cec990 <global_trees@@Base+0x110>
  9a898c:	49 89 c5             	mov    %rax,%r13
  9a898f:	0f 85 e2 1d f3 ff    	jne    8da777 <calloc@plt+0x12f7>
  9a8995:	89 df                	mov    %ebx,%edi
  9a8997:	4c 8b 25 1a 41 34 03 	mov    0x334411a(%rip),%r12        # 3cecab8 <global_trees@@Base+0x238>
  9a899e:	e8 ad a4 f8 ff       	call   932e50 <_Z15get_entity_namei@@Base>
  9a89a3:	48 83 ec 08          	sub    $0x8,%rsp
  9a89a7:	45 31 c9             	xor    %r9d,%r9d
  9a89aa:	4c 89 e9             	mov    %r13,%rcx
  9a89ad:	6a 01                	push   $0x1
  9a89af:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a89b5:	31 f6                	xor    %esi,%esi
  9a89b7:	4c 89 e2             	mov    %r12,%rdx
  9a89ba:	53                   	push   %rbx
  9a89bb:	48 89 c7             	mov    %rax,%rdi
  9a89be:	6a 00                	push   $0x0
  9a89c0:	6a 00                	push   $0x0
  9a89c2:	6a 01                	push   $0x1
  9a89c4:	6a 00                	push   $0x0
  9a89c6:	6a 00                	push   $0x0
  9a89c8:	6a 00                	push   $0x0
  9a89ca:	6a 00                	push   $0x0
  9a89cc:	e8 5f 2b fd ff       	call   97b530 <_Z15create_var_declP9tree_nodeS0_S0_S0_bbbbbbbbP6attribib@@Base>
  9a89d1:	48 83 c4 50          	add    $0x50,%rsp
  9a89d5:	31 d2                	xor    %edx,%edx
  9a89d7:	89 df                	mov    %ebx,%edi
  9a89d9:	48 89 c6             	mov    %rax,%rsi
  9a89dc:	e8 bf a1 fc ff       	call   972ba0 <_Z13save_gnu_treeiP9tree_nodeb@@Base>
  9a89e1:	48 8b 3d 88 40 34 03 	mov    0x3344088(%rip),%rdi        # 3ceca70 <global_trees@@Base+0x1f0>
  9a89e8:	31 f6                	xor    %esi,%esi
  9a89ea:	31 c0                	xor    %eax,%eax
  9a89ec:	e8 0f 05 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a89f1:	48 89 c7             	mov    %rax,%rdi
  9a89f4:	48 89 05 f5 38 c4 02 	mov    %rax,0x2c438f5(%rip)        # 35ec2f0 <gnat_std_decls@@Base+0x10>
  9a89fb:	e8 60 52 cf 00       	call   169dc60 <_Z18build_pointer_typeP9tree_node@@Base>
  9a8a00:	48 8b 35 79 bd 33 03 	mov    0x333bd79(%rip),%rsi        # 3ce4780 <sizetype_tab@@Base>
  9a8a07:	48 8b 3d 6a 40 34 03 	mov    0x334406a(%rip),%rdi        # 3ceca78 <global_trees@@Base+0x1f8>
  9a8a0e:	31 d2                	xor    %edx,%edx
  9a8a10:	48 89 05 e1 38 c4 02 	mov    %rax,0x2c438e1(%rip)        # 35ec2f8 <gnat_std_decls@@Base+0x18>
  9a8a17:	31 c0                	xor    %eax,%eax
  9a8a19:	e8 e2 04 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8a1e:	be 0d 00 00 00       	mov    $0xd,%esi
  9a8a23:	bf ab 03 9f 02       	mov    $0x29f03ab,%edi
  9a8a28:	48 89 c3             	mov    %rax,%rbx
  9a8a2b:	e8 a0 7d 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8a30:	48 83 ec 08          	sub    $0x8,%rsp
  9a8a34:	31 c9                	xor    %ecx,%ecx
  9a8a36:	48 89 da             	mov    %rbx,%rdx
  9a8a39:	6a 00                	push   $0x0
  9a8a3b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8a41:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8a47:	31 f6                	xor    %esi,%esi
  9a8a49:	6a 00                	push   $0x0
  9a8a4b:	48 89 c7             	mov    %rax,%rdi
  9a8a4e:	6a 00                	push   $0x0
  9a8a50:	6a 00                	push   $0x0
  9a8a52:	6a 01                	push   $0x1
  9a8a54:	6a 01                	push   $0x1
  9a8a56:	6a 00                	push   $0x0
  9a8a58:	e8 f3 c0 fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8a5d:	48 83 c4 40          	add    $0x40,%rsp
  9a8a61:	31 d2                	xor    %edx,%edx
  9a8a63:	48 89 05 b6 38 c4 02 	mov    %rax,0x2c438b6(%rip)        # 35ec320 <gnat_std_decls@@Base+0x40>
  9a8a6a:	80 88 dd 00 00 00 01 	orb    $0x1,0xdd(%rax)
  9a8a71:	48 8b 35 00 40 34 03 	mov    0x3344000(%rip),%rsi        # 3ceca78 <global_trees@@Base+0x1f8>
  9a8a78:	31 c0                	xor    %eax,%eax
  9a8a7a:	48 8b 3d ef 3f 34 03 	mov    0x3343fef(%rip),%rdi        # 3ceca70 <global_trees@@Base+0x1f0>
  9a8a81:	e8 7a 04 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8a86:	be 0b 00 00 00       	mov    $0xb,%esi
  9a8a8b:	bf b9 03 9f 02       	mov    $0x29f03b9,%edi
  9a8a90:	48 89 c3             	mov    %rax,%rbx
  9a8a93:	e8 38 7d 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8a98:	48 83 ec 08          	sub    $0x8,%rsp
  9a8a9c:	31 c9                	xor    %ecx,%ecx
  9a8a9e:	48 89 da             	mov    %rbx,%rdx
  9a8aa1:	6a 00                	push   $0x0
  9a8aa3:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8aa9:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8aaf:	31 f6                	xor    %esi,%esi
  9a8ab1:	6a 00                	push   $0x0
  9a8ab3:	48 89 c7             	mov    %rax,%rdi
  9a8ab6:	6a 00                	push   $0x0
  9a8ab8:	6a 00                	push   $0x0
  9a8aba:	6a 01                	push   $0x1
  9a8abc:	6a 01                	push   $0x1
  9a8abe:	6a 00                	push   $0x0
  9a8ac0:	e8 8b c0 fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8ac5:	48 8b 3d ac 3f 34 03 	mov    0x3343fac(%rip),%rdi        # 3ceca78 <global_trees@@Base+0x1f8>
  9a8acc:	48 8b 15 ad bc 33 03 	mov    0x333bcad(%rip),%rdx        # 3ce4780 <sizetype_tab@@Base>
  9a8ad3:	31 c9                	xor    %ecx,%ecx
  9a8ad5:	48 83 c4 40          	add    $0x40,%rsp
  9a8ad9:	48 89 05 48 38 c4 02 	mov    %rax,0x2c43848(%rip)        # 35ec328 <gnat_std_decls@@Base+0x48>
  9a8ae0:	31 c0                	xor    %eax,%eax
  9a8ae2:	48 89 fe             	mov    %rdi,%rsi
  9a8ae5:	e8 16 04 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8aea:	be 0e 00 00 00       	mov    $0xe,%esi
  9a8aef:	bf c5 03 9f 02       	mov    $0x29f03c5,%edi
  9a8af4:	48 89 c3             	mov    %rax,%rbx
  9a8af7:	e8 d4 7c 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8afc:	48 83 ec 08          	sub    $0x8,%rsp
  9a8b00:	31 c9                	xor    %ecx,%ecx
  9a8b02:	48 89 da             	mov    %rbx,%rdx
  9a8b05:	6a 00                	push   $0x0
  9a8b07:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8b0d:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8b13:	31 f6                	xor    %esi,%esi
  9a8b15:	6a 00                	push   $0x0
  9a8b17:	48 89 c7             	mov    %rax,%rdi
  9a8b1a:	6a 00                	push   $0x0
  9a8b1c:	6a 00                	push   $0x0
  9a8b1e:	6a 01                	push   $0x1
  9a8b20:	6a 01                	push   $0x1
  9a8b22:	6a 00                	push   $0x0
  9a8b24:	e8 27 c0 fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8b29:	48 83 c4 40          	add    $0x40,%rsp
  9a8b2d:	31 f6                	xor    %esi,%esi
  9a8b2f:	bf 40 00 00 00       	mov    $0x40,%edi
  9a8b34:	48 89 05 f5 37 c4 02 	mov    %rax,0x2c437f5(%rip)        # 35ec330 <gnat_std_decls@@Base+0x50>
  9a8b3b:	e8 20 c3 fc ff       	call   974e60 <_Z18gnat_type_for_sizeji@@Base>
  9a8b40:	31 c9                	xor    %ecx,%ecx
  9a8b42:	48 89 c2             	mov    %rax,%rdx
  9a8b45:	48 89 c6             	mov    %rax,%rsi
  9a8b48:	48 89 c7             	mov    %rax,%rdi
  9a8b4b:	31 c0                	xor    %eax,%eax
  9a8b4d:	e8 ae 03 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8b52:	be 0d 00 00 00       	mov    $0xd,%esi
  9a8b57:	bf d4 03 9f 02       	mov    $0x29f03d4,%edi
  9a8b5c:	48 89 c3             	mov    %rax,%rbx
  9a8b5f:	e8 6c 7c 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8b64:	48 83 ec 08          	sub    $0x8,%rsp
  9a8b68:	31 c9                	xor    %ecx,%ecx
  9a8b6a:	48 89 da             	mov    %rbx,%rdx
  9a8b6d:	6a 00                	push   $0x0
  9a8b6f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8b75:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8b7b:	31 f6                	xor    %esi,%esi
  9a8b7d:	6a 00                	push   $0x0
  9a8b7f:	48 89 c7             	mov    %rax,%rdi
  9a8b82:	6a 00                	push   $0x0
  9a8b84:	6a 00                	push   $0x0
  9a8b86:	6a 01                	push   $0x1
  9a8b88:	6a 01                	push   $0x1
  9a8b8a:	6a 00                	push   $0x0
  9a8b8c:	e8 bf bf fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8b91:	48 83 c4 40          	add    $0x40,%rsp
  9a8b95:	48 89 c7             	mov    %rax,%rdi
  9a8b98:	48 89 05 99 37 c4 02 	mov    %rax,0x2c43799(%rip)        # 35ec338 <gnat_std_decls@@Base+0x58>
  9a8b9f:	e8 fc 4b 76 00       	call   110d7a0 <_Z19strub_make_callableP9tree_node@@Base>
  9a8ba4:	be 01 00 00 00       	mov    $0x1,%esi
  9a8ba9:	bf 40 00 00 00       	mov    $0x40,%edi
  9a8bae:	e8 ad c2 fc ff       	call   974e60 <_Z18gnat_type_for_sizeji@@Base>
  9a8bb3:	31 c9                	xor    %ecx,%ecx
  9a8bb5:	48 89 c2             	mov    %rax,%rdx
  9a8bb8:	48 89 c6             	mov    %rax,%rsi
  9a8bbb:	48 89 c7             	mov    %rax,%rdi
  9a8bbe:	31 c0                	xor    %eax,%eax
  9a8bc0:	e8 3b 03 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8bc5:	be 11 00 00 00       	mov    $0x11,%esi
  9a8bca:	bf e2 03 9f 02       	mov    $0x29f03e2,%edi
  9a8bcf:	48 89 c3             	mov    %rax,%rbx
  9a8bd2:	e8 f9 7b 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8bd7:	48 83 ec 08          	sub    $0x8,%rsp
  9a8bdb:	31 c9                	xor    %ecx,%ecx
  9a8bdd:	31 f6                	xor    %esi,%esi
  9a8bdf:	6a 00                	push   $0x0
  9a8be1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8be7:	48 89 da             	mov    %rbx,%rdx
  9a8bea:	48 89 c7             	mov    %rax,%rdi
  9a8bed:	6a 00                	push   $0x0
  9a8bef:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8bf5:	6a 00                	push   $0x0
  9a8bf7:	6a 00                	push   $0x0
  9a8bf9:	6a 01                	push   $0x1
  9a8bfb:	6a 01                	push   $0x1
  9a8bfd:	6a 00                	push   $0x0
  9a8bff:	e8 4c bf fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8c04:	48 83 c4 40          	add    $0x40,%rsp
  9a8c08:	48 89 c7             	mov    %rax,%rdi
  9a8c0b:	48 89 05 2e 37 c4 02 	mov    %rax,0x2c4372e(%rip)        # 35ec340 <gnat_std_decls@@Base+0x60>
  9a8c12:	e8 89 4b 76 00       	call   110d7a0 <_Z19strub_make_callableP9tree_node@@Base>
  9a8c17:	80 3d b8 17 c3 02 00 	cmpb   $0x0,0x2c317b8(%rip)        # 35da3d6 <opt__enable_128bit_types@@Base>
  9a8c1e:	0f 85 df 0a 00 00    	jne    9a9703 <gigi@@Base+0x1223>
  9a8c24:	48 8b 05 d5 14 c3 02 	mov    0x2c314d5(%rip),%rax        # 35da100 <namet__name_entries__table@@Base>
  9a8c2b:	8b b8 00 10 00 00    	mov    0x1000(%rax),%edi
  9a8c31:	83 c7 01             	add    $0x1,%edi
  9a8c34:	48 63 ff             	movslq %edi,%rdi
  9a8c37:	48 03 3d ca 14 c3 02 	add    0x2c314ca(%rip),%rdi        # 35da108 <namet__name_chars__table@@Base>
  9a8c3e:	e8 5d 7b 9a 00       	call   13507a0 <_Z14get_identifierPKc@@Base>
  9a8c43:	48 89 05 0e 37 c4 02 	mov    %rax,0x2c4370e(%rip)        # 35ec358 <gnat_std_decls@@Base+0x78>
  9a8c4a:	48 8b 05 af 14 c3 02 	mov    0x2c314af(%rip),%rax        # 35da100 <namet__name_entries__table@@Base>
  9a8c51:	8b b8 10 10 00 00    	mov    0x1010(%rax),%edi
  9a8c57:	83 c7 01             	add    $0x1,%edi
  9a8c5a:	48 63 ff             	movslq %edi,%rdi
  9a8c5d:	48 03 3d a4 14 c3 02 	add    0x2c314a4(%rip),%rdi        # 35da108 <namet__name_chars__table@@Base>
  9a8c64:	e8 37 7b 9a 00       	call   13507a0 <_Z14get_identifierPKc@@Base>
  9a8c69:	be 15 00 00 00       	mov    $0x15,%esi
  9a8c6e:	bf 16 04 9f 02       	mov    $0x29f0416,%edi
  9a8c73:	48 89 05 e6 36 c4 02 	mov    %rax,0x2c436e6(%rip)        # 35ec360 <gnat_std_decls@@Base+0x80>
  9a8c7a:	e8 51 7b 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8c7f:	8b bc 24 f8 00 00 00 	mov    0xf8(%rsp),%edi
  9a8c86:	48 89 05 db 36 c4 02 	mov    %rax,0x2c436db(%rip)        # 35ec368 <gnat_std_decls@@Base+0x88>
  9a8c8d:	e8 fe d1 04 00       	call   9f5e90 <einfo__utils__base_type@@Base>
  9a8c92:	89 c7                	mov    %eax,%edi
  9a8c94:	e8 87 94 f9 ff       	call   942120 <_Z16gnat_to_gnu_typei@@Base>
  9a8c99:	48 8b 35 d8 3d 34 03 	mov    0x3343dd8(%rip),%rsi        # 3ceca78 <global_trees@@Base+0x1f8>
  9a8ca0:	48 8b 3d c9 3d 34 03 	mov    0x3343dc9(%rip),%rdi        # 3ceca70 <global_trees@@Base+0x1f0>
  9a8ca7:	31 c9                	xor    %ecx,%ecx
  9a8ca9:	48 89 05 38 36 c4 02 	mov    %rax,0x2c43638(%rip)        # 35ec2e8 <gnat_std_decls@@Base+0x8>
  9a8cb0:	31 c0                	xor    %eax,%eax
  9a8cb2:	48 89 f2             	mov    %rsi,%rdx
  9a8cb5:	e8 46 02 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8cba:	be 1e 00 00 00       	mov    $0x1e,%esi
  9a8cbf:	bf 20 3c aa 02       	mov    $0x2aa3c20,%edi
  9a8cc4:	48 89 c3             	mov    %rax,%rbx
  9a8cc7:	e8 04 7b 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8ccc:	48 83 ec 08          	sub    $0x8,%rsp
  9a8cd0:	31 c9                	xor    %ecx,%ecx
  9a8cd2:	48 89 da             	mov    %rbx,%rdx
  9a8cd5:	6a 00                	push   $0x0
  9a8cd7:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8cdd:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8ce3:	31 f6                	xor    %esi,%esi
  9a8ce5:	6a 00                	push   $0x0
  9a8ce7:	48 89 c7             	mov    %rax,%rdi
  9a8cea:	6a 00                	push   $0x0
  9a8cec:	6a 00                	push   $0x0
  9a8cee:	6a 01                	push   $0x1
  9a8cf0:	6a 01                	push   $0x1
  9a8cf2:	6a 00                	push   $0x0
  9a8cf4:	e8 57 be fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8cf9:	48 8b 3d 78 3d 34 03 	mov    0x3343d78(%rip),%rdi        # 3ceca78 <global_trees@@Base+0x1f8>
  9a8d00:	48 83 c4 40          	add    $0x40,%rsp
  9a8d04:	31 d2                	xor    %edx,%edx
  9a8d06:	48 89 05 6b 36 c4 02 	mov    %rax,0x2c4366b(%rip)        # 35ec378 <gnat_std_decls@@Base+0x98>
  9a8d0d:	31 c0                	xor    %eax,%eax
  9a8d0f:	48 89 fe             	mov    %rdi,%rsi
  9a8d12:	e8 e9 01 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8d17:	be 17 00 00 00       	mov    $0x17,%esi
  9a8d1c:	bf 2c 04 9f 02       	mov    $0x29f042c,%edi
  9a8d21:	48 89 c3             	mov    %rax,%rbx
  9a8d24:	e8 a7 7a 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8d29:	48 83 ec 08          	sub    $0x8,%rsp
  9a8d2d:	31 c9                	xor    %ecx,%ecx
  9a8d2f:	48 89 da             	mov    %rbx,%rdx
  9a8d32:	6a 00                	push   $0x0
  9a8d34:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8d3a:	31 f6                	xor    %esi,%esi
  9a8d3c:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8d42:	6a 00                	push   $0x0
  9a8d44:	48 89 c7             	mov    %rax,%rdi
  9a8d47:	6a 00                	push   $0x0
  9a8d49:	6a 00                	push   $0x0
  9a8d4b:	6a 01                	push   $0x1
  9a8d4d:	6a 01                	push   $0x1
  9a8d4f:	6a 00                	push   $0x0
  9a8d51:	e8 fa bd fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8d56:	45 31 c0             	xor    %r8d,%r8d
  9a8d59:	48 83 c4 40          	add    $0x40,%rsp
  9a8d5d:	48 89 05 1c 36 c4 02 	mov    %rax,0x2c4361c(%rip)        # 35ec380 <gnat_std_decls@@Base+0xa0>
  9a8d64:	80 48 03 02          	orb    $0x2,0x3(%rax)
  9a8d68:	48 8b 3d 09 3d 34 03 	mov    0x3343d09(%rip),%rdi        # 3ceca78 <global_trees@@Base+0x1f8>
  9a8d6f:	31 c0                	xor    %eax,%eax
  9a8d71:	48 89 f9             	mov    %rdi,%rcx
  9a8d74:	48 89 fa             	mov    %rdi,%rdx
  9a8d77:	48 89 fe             	mov    %rdi,%rsi
  9a8d7a:	e8 81 01 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8d7f:	be 15 00 00 00       	mov    $0x15,%esi
  9a8d84:	bf 44 04 9f 02       	mov    $0x29f0444,%edi
  9a8d89:	48 89 c3             	mov    %rax,%rbx
  9a8d8c:	e8 3f 7a 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8d91:	48 83 ec 08          	sub    $0x8,%rsp
  9a8d95:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8d9b:	31 c9                	xor    %ecx,%ecx
  9a8d9d:	6a 00                	push   $0x0
  9a8d9f:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8da5:	48 89 da             	mov    %rbx,%rdx
  9a8da8:	31 f6                	xor    %esi,%esi
  9a8daa:	6a 00                	push   $0x0
  9a8dac:	48 89 c7             	mov    %rax,%rdi
  9a8daf:	6a 00                	push   $0x0
  9a8db1:	6a 00                	push   $0x0
  9a8db3:	6a 01                	push   $0x1
  9a8db5:	6a 01                	push   $0x1
  9a8db7:	6a 00                	push   $0x0
  9a8db9:	e8 92 bd fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8dbe:	48 8b 35 b3 3c 34 03 	mov    0x3343cb3(%rip),%rsi        # 3ceca78 <global_trees@@Base+0x1f8>
  9a8dc5:	48 8b 3d a4 3c 34 03 	mov    0x3343ca4(%rip),%rdi        # 3ceca70 <global_trees@@Base+0x1f0>
  9a8dcc:	31 d2                	xor    %edx,%edx
  9a8dce:	48 83 c4 40          	add    $0x40,%rsp
  9a8dd2:	48 89 05 af 35 c4 02 	mov    %rax,0x2c435af(%rip)        # 35ec388 <gnat_std_decls@@Base+0xa8>
  9a8dd9:	31 c0                	xor    %eax,%eax
  9a8ddb:	e8 20 01 d0 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a8de0:	be 1f 00 00 00       	mov    $0x1f,%esi
  9a8de5:	bf 40 3c aa 02       	mov    $0x2aa3c40,%edi
  9a8dea:	48 89 c3             	mov    %rax,%rbx
  9a8ded:	e8 de 79 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8df2:	48 83 ec 08          	sub    $0x8,%rsp
  9a8df6:	31 c9                	xor    %ecx,%ecx
  9a8df8:	48 89 da             	mov    %rbx,%rdx
  9a8dfb:	6a 00                	push   $0x0
  9a8dfd:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8e03:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8e09:	31 f6                	xor    %esi,%esi
  9a8e0b:	6a 00                	push   $0x0
  9a8e0d:	48 89 c7             	mov    %rax,%rdi
  9a8e10:	6a 00                	push   $0x0
  9a8e12:	6a 00                	push   $0x0
  9a8e14:	6a 01                	push   $0x1
  9a8e16:	6a 01                	push   $0x1
  9a8e18:	6a 00                	push   $0x0
  9a8e1a:	e8 31 bd fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8e1f:	48 83 c4 40          	add    $0x40,%rsp
  9a8e23:	48 89 df             	mov    %rbx,%rdi
  9a8e26:	be 02 00 00 00       	mov    $0x2,%esi
  9a8e2b:	48 89 05 5e 35 c4 02 	mov    %rax,0x2c4355e(%rip)        # 35ec390 <gnat_std_decls@@Base+0xb0>
  9a8e32:	e8 c9 bb cf 00       	call   16a4a00 <_Z20build_qualified_typeP9tree_nodei@@Base>
  9a8e37:	be 12 00 00 00       	mov    $0x12,%esi
  9a8e3c:	bf 5a 04 9f 02       	mov    $0x29f045a,%edi
  9a8e41:	48 89 c3             	mov    %rax,%rbx
  9a8e44:	e8 87 79 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8e49:	48 83 ec 08          	sub    $0x8,%rsp
  9a8e4d:	31 c9                	xor    %ecx,%ecx
  9a8e4f:	48 89 da             	mov    %rbx,%rdx
  9a8e52:	6a 00                	push   $0x0
  9a8e54:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a8e5a:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8e60:	31 f6                	xor    %esi,%esi
  9a8e62:	6a 00                	push   $0x0
  9a8e64:	48 89 c7             	mov    %rax,%rdi
  9a8e67:	6a 00                	push   $0x0
  9a8e69:	6a 00                	push   $0x0
  9a8e6b:	6a 01                	push   $0x1
  9a8e6d:	6a 01                	push   $0x1
  9a8e6f:	6a 00                	push   $0x0
  9a8e71:	e8 da bc fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a8e76:	48 83 c4 40          	add    $0x40,%rsp
  9a8e7a:	be 08 00 01 00       	mov    $0x10008,%esi
  9a8e7f:	48 89 c7             	mov    %rax,%rdi
  9a8e82:	48 89 05 e7 34 c4 02 	mov    %rax,0x2c434e7(%rip)        # 35ec370 <gnat_std_decls@@Base+0x90>
  9a8e89:	e8 52 1f cf 00       	call   169ade0 <_Z19set_call_expr_flagsP9tree_nodei@@Base>
  9a8e8e:	be 13 00 00 00       	mov    $0x13,%esi
  9a8e93:	bf 6d 04 9f 02       	mov    $0x29f046d,%edi
  9a8e98:	4c 8b 25 41 39 34 03 	mov    0x3343941(%rip),%r12        # 3cec7e0 <integer_types@@Base>
  9a8e9f:	e8 2c 79 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8ea4:	be 06 00 00 00       	mov    $0x6,%esi
  9a8ea9:	bf f8 36 9f 02       	mov    $0x29f36f8,%edi
  9a8eae:	48 89 c3             	mov    %rax,%rbx
  9a8eb1:	e8 1a 79 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8eb6:	48 83 ec 08          	sub    $0x8,%rsp
  9a8eba:	31 c9                	xor    %ecx,%ecx
  9a8ebc:	4c 89 e2             	mov    %r12,%rdx
  9a8ebf:	6a 01                	push   $0x1
  9a8ec1:	45 31 c9             	xor    %r9d,%r9d
  9a8ec4:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8eca:	48 89 de             	mov    %rbx,%rsi
  9a8ecd:	6a 00                	push   $0x0
  9a8ecf:	48 89 c7             	mov    %rax,%rdi
  9a8ed2:	6a 00                	push   $0x0
  9a8ed4:	6a 00                	push   $0x0
  9a8ed6:	6a 01                	push   $0x1
  9a8ed8:	6a 00                	push   $0x0
  9a8eda:	6a 00                	push   $0x0
  9a8edc:	6a 01                	push   $0x1
  9a8ede:	6a 00                	push   $0x0
  9a8ee0:	e8 4b 26 fd ff       	call   97b530 <_Z15create_var_declP9tree_nodeS0_S0_S0_bbbbbbbbP6attribib@@Base>
  9a8ee5:	48 83 c4 50          	add    $0x50,%rsp
  9a8ee9:	be 17 00 00 00       	mov    $0x17,%esi
  9a8eee:	bf 81 04 9f 02       	mov    $0x29f0481,%edi
  9a8ef3:	4c 8b 25 e6 38 34 03 	mov    0x33438e6(%rip),%r12        # 3cec7e0 <integer_types@@Base>
  9a8efa:	48 89 05 97 34 c4 02 	mov    %rax,0x2c43497(%rip)        # 35ec398 <gnat_std_decls@@Base+0xb8>
  9a8f01:	e8 ca 78 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8f06:	be 0a 00 00 00       	mov    $0xa,%esi
  9a8f0b:	bf 99 04 9f 02       	mov    $0x29f0499,%edi
  9a8f10:	48 89 c3             	mov    %rax,%rbx
  9a8f13:	e8 b8 78 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8f18:	48 83 ec 08          	sub    $0x8,%rsp
  9a8f1c:	4c 89 e2             	mov    %r12,%rdx
  9a8f1f:	45 31 c9             	xor    %r9d,%r9d
  9a8f22:	6a 01                	push   $0x1
  9a8f24:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8f2a:	31 c9                	xor    %ecx,%ecx
  9a8f2c:	48 89 de             	mov    %rbx,%rsi
  9a8f2f:	6a 00                	push   $0x0
  9a8f31:	48 89 c7             	mov    %rax,%rdi
  9a8f34:	6a 00                	push   $0x0
  9a8f36:	6a 00                	push   $0x0
  9a8f38:	6a 01                	push   $0x1
  9a8f3a:	6a 00                	push   $0x0
  9a8f3c:	6a 00                	push   $0x0
  9a8f3e:	6a 01                	push   $0x1
  9a8f40:	6a 00                	push   $0x0
  9a8f42:	e8 e9 25 fd ff       	call   97b530 <_Z15create_var_declP9tree_nodeS0_S0_S0_bbbbbbbbP6attribib@@Base>
  9a8f47:	48 83 c4 50          	add    $0x50,%rsp
  9a8f4b:	be 1d 00 00 00       	mov    $0x1d,%esi
  9a8f50:	bf a4 04 9f 02       	mov    $0x29f04a4,%edi
  9a8f55:	4c 8b 25 84 38 34 03 	mov    0x3343884(%rip),%r12        # 3cec7e0 <integer_types@@Base>
  9a8f5c:	48 89 05 3d 34 c4 02 	mov    %rax,0x2c4343d(%rip)        # 35ec3a0 <gnat_std_decls@@Base+0xc0>
  9a8f63:	e8 68 78 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8f68:	be 10 00 00 00       	mov    $0x10,%esi
  9a8f6d:	bf c2 04 9f 02       	mov    $0x29f04c2,%edi
  9a8f72:	48 89 c3             	mov    %rax,%rbx
  9a8f75:	e8 56 78 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a8f7a:	48 83 ec 08          	sub    $0x8,%rsp
  9a8f7e:	48 89 de             	mov    %rbx,%rsi
  9a8f81:	45 31 c9             	xor    %r9d,%r9d
  9a8f84:	6a 01                	push   $0x1
  9a8f86:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a8f8c:	31 c9                	xor    %ecx,%ecx
  9a8f8e:	4c 89 e2             	mov    %r12,%rdx
  9a8f91:	6a 00                	push   $0x0
  9a8f93:	48 89 c7             	mov    %rax,%rdi
  9a8f96:	31 db                	xor    %ebx,%ebx
  9a8f98:	6a 00                	push   $0x0
  9a8f9a:	6a 00                	push   $0x0
  9a8f9c:	6a 01                	push   $0x1
  9a8f9e:	6a 00                	push   $0x0
  9a8fa0:	6a 00                	push   $0x0
  9a8fa2:	6a 01                	push   $0x1
  9a8fa4:	6a 00                	push   $0x0
  9a8fa6:	e8 85 25 fd ff       	call   97b530 <_Z15create_var_declP9tree_nodeS0_S0_S0_bbbbbbbbP6attribib@@Base>
  9a8fab:	48 83 c4 50          	add    $0x50,%rsp
  9a8faf:	48 89 05 f2 33 c4 02 	mov    %rax,0x2c433f2(%rip)        # 35ec3a8 <gnat_std_decls@@Base+0xc8>
  9a8fb6:	e8 b5 8f 1c 00       	call   b71f70 <restrict__no_exception_handlers_set@@Base>
  9a8fbb:	84 c0                	test   %al,%al
  9a8fbd:	0f 85 f2 05 00 00    	jne    9a95b5 <gigi@@Base+0x10d5>
  9a8fc3:	66 90                	xchg   %ax,%ax
  9a8fc5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  9a8fcc:	00 00 00 00 
  9a8fd0:	89 df                	mov    %ebx,%edi
  9a8fd2:	31 f6                	xor    %esi,%esi
  9a8fd4:	e8 97 73 fe ff       	call   990370 <_Z31gt_pch_p_20vec_loop_info_va_gc_PvS_PFvS_S_S_ES_@@Base+0x60>
  9a8fd9:	48 89 04 dd a0 c1 5e 	mov    %rax,0x35ec1a0(,%rbx,8)
  9a8fe0:	03 
  9a8fe1:	48 83 c3 01          	add    $0x1,%rbx
  9a8fe5:	48 83 fb 28          	cmp    $0x28,%rbx
  9a8fe9:	75 e5                	jne    9a8fd0 <gigi@@Base+0xaf0>
  9a8feb:	45 31 e4             	xor    %r12d,%r12d
  9a8fee:	66 90                	xchg   %ax,%ax
  9a8ff0:	44 89 e1             	mov    %r12d,%ecx
  9a8ff3:	b8 60 10 00 00       	mov    $0x1060,%eax
  9a8ff8:	be 02 00 00 00       	mov    $0x2,%esi
  9a8ffd:	44 89 e7             	mov    %r12d,%edi
  9a9000:	48 d3 e8             	shr    %cl,%rax
  9a9003:	83 e0 01             	and    $0x1,%eax
  9a9006:	29 c6                	sub    %eax,%esi
  9a9008:	e8 63 73 fe ff       	call   990370 <_Z31gt_pch_p_20vec_loop_info_va_gc_PvS_PFvS_S_S_ES_@@Base+0x60>
  9a900d:	4a 89 04 e5 60 c0 5e 	mov    %rax,0x35ec060(,%r12,8)
  9a9014:	03 
  9a9015:	49 83 c4 01          	add    $0x1,%r12
  9a9019:	49 83 fc 28          	cmp    $0x28,%r12
  9a901d:	75 d1                	jne    9a8ff0 <gigi@@Base+0xb10>
  9a901f:	8b bc 24 08 01 00 00 	mov    0x108(%rsp),%edi
  9a9026:	e8 65 ce 04 00       	call   9f5e90 <einfo__utils__base_type@@Base>
  9a902b:	89 c7                	mov    %eax,%edi
  9a902d:	e8 be e1 f9 ff       	call   9471f0 <_Z17get_unpadded_typei@@Base>
  9a9032:	be 04 00 00 00       	mov    $0x4,%esi
  9a9037:	bf 3b 05 a3 02       	mov    $0x2a3053b,%edi
  9a903c:	48 89 05 9d 32 c4 02 	mov    %rax,0x2c4329d(%rip)        # 35ec2e0 <gnat_std_decls@@Base>
  9a9043:	e8 88 77 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a9048:	48 89 05 d1 3a 34 03 	mov    %rax,0x3343ad1(%rip)        # 3cecb20 <global_trees@@Base+0x2a0>
  9a904f:	e8 5c 44 fa ff       	call   94d4b0 <_Z16gnat_init_gcc_ehv@@Base>
  9a9054:	e8 f7 44 fa ff       	call   94d550 <_Z16gnat_init_gcc_fpv@@Base>
  9a9059:	e8 12 36 fd ff       	call   97c670 <_Z21gnat_install_builtinsv@@Base>
  9a905e:	48 8b 05 e3 5d c4 02 	mov    0x2c45de3(%rip),%rax        # 35eee48 <Node_Offsets_Ptr@@Base+0x440>
  9a9065:	48 85 c0             	test   %rax,%rax
  9a9068:	0f 84 df 07 00 00    	je     9a984d <gigi@@Base+0x136d>
  9a906e:	8b 38                	mov    (%rax),%edi
  9a9070:	8b 50 04             	mov    0x4(%rax),%edx
  9a9073:	81 e7 ff ff ff 7f    	and    $0x7fffffff,%edi
  9a9079:	8d 5a 01             	lea    0x1(%rdx),%ebx
  9a907c:	39 d7                	cmp    %edx,%edi
  9a907e:	0f 84 29 08 00 00    	je     9a98ad <gigi@@Base+0x13cd>
  9a9084:	4c 8d 24 d5 08 00 00 	lea    0x8(,%rdx,8),%r12
  9a908b:	00 
  9a908c:	89 58 04             	mov    %ebx,0x4(%rax)
  9a908f:	48 8b 1d 82 5d c4 02 	mov    0x2c45d82(%rip),%rbx        # 35eee18 <Node_Offsets_Ptr@@Base+0x410>
  9a9096:	4a c7 04 20 00 00 00 	movq   $0x0,(%rax,%r12,1)
  9a909d:	00 
  9a909e:	48 85 db             	test   %rbx,%rbx
  9a90a1:	0f 84 93 07 00 00    	je     9a983a <gigi@@Base+0x135a>
  9a90a7:	8b 03                	mov    (%rbx),%eax
  9a90a9:	44 8b 63 04          	mov    0x4(%rbx),%r12d
  9a90ad:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  9a90b2:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  9a90b7:	44 39 e0             	cmp    %r12d,%eax
  9a90ba:	0f 85 c9 00 00 00    	jne    9a9189 <gigi@@Base+0xca9>
  9a90c0:	80 7b 03 00          	cmpb   $0x0,0x3(%rbx)
  9a90c4:	79 74                	jns    9a913a <gigi@@Base+0xc5a>
  9a90c6:	48 c7 05 47 5d c4 02 	movq   $0x0,0x2c45d47(%rip)        # 35eee18 <Node_Offsets_Ptr@@Base+0x410>
  9a90cd:	00 00 00 00 
  9a90d1:	ba 04 00 00 00       	mov    $0x4,%edx
  9a90d6:	41 39 d5             	cmp    %edx,%r13d
  9a90d9:	41 0f 43 d5          	cmovae %r13d,%edx
  9a90dd:	31 ff                	xor    %edi,%edi
  9a90df:	8d 72 02             	lea    0x2(%rdx),%esi
  9a90e2:	89 54 24 08          	mov    %edx,0x8(%rsp)
  9a90e6:	48 c1 e6 02          	shl    $0x2,%rsi
  9a90ea:	e8 b1 36 d9 01       	call   273c7a0 <xrealloc@@Base>
  9a90ef:	8b 54 24 08          	mov    0x8(%rsp),%edx
  9a90f3:	44 89 e1             	mov    %r12d,%ecx
  9a90f6:	48 89 05 1b 5d c4 02 	mov    %rax,0x2c45d1b(%rip)        # 35eee18 <Node_Offsets_Ptr@@Base+0x410>
  9a90fd:	48 89 c6             	mov    %rax,%rsi
  9a9100:	81 e2 ff ff ff 7f    	and    $0x7fffffff,%edx
  9a9106:	89 d0                	mov    %edx,%eax
  9a9108:	48 89 06             	mov    %rax,(%rsi)
  9a910b:	31 c0                	xor    %eax,%eax
  9a910d:	45 85 e4             	test   %r12d,%r12d
  9a9110:	74 1f                	je     9a9131 <gigi@@Base+0xc51>
  9a9112:	0f 1f 00             	nopl   (%rax)
  9a9115:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  9a911c:	00 00 00 00 
  9a9120:	8b 54 83 08          	mov    0x8(%rbx,%rax,4),%edx
  9a9124:	89 54 86 08          	mov    %edx,0x8(%rsi,%rax,4)
  9a9128:	48 83 c0 01          	add    $0x1,%rax
  9a912c:	48 39 c8             	cmp    %rcx,%rax
  9a912f:	75 ef                	jne    9a9120 <gigi@@Base+0xc40>
  9a9131:	44 89 66 04          	mov    %r12d,0x4(%rsi)
  9a9135:	48 89 f3             	mov    %rsi,%rbx
  9a9138:	eb 52                	jmp    9a918c <gigi@@Base+0xcac>
  9a913a:	44 89 ee             	mov    %r13d,%esi
  9a913d:	44 89 e7             	mov    %r12d,%edi
  9a9140:	e8 bb 33 ca 01       	call   264c500 <_ZN10vec_prefix22calculate_allocation_1Ejj@@Base>
  9a9145:	48 8b 1d cc 5c c4 02 	mov    0x2c45ccc(%rip),%rbx        # 35eee18 <Node_Offsets_Ptr@@Base+0x410>
  9a914c:	89 c2                	mov    %eax,%edx
  9a914e:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  9a9153:	48 8d 34 95 08 00 00 	lea    0x8(,%rdx,4),%rsi
  9a915a:	00 
  9a915b:	41 89 c5             	mov    %eax,%r13d
  9a915e:	48 85 db             	test   %rbx,%rbx
  9a9161:	0f 84 de 06 00 00    	je     9a9845 <gigi@@Base+0x1365>
  9a9167:	44 8b 63 04          	mov    0x4(%rbx),%r12d
  9a916b:	48 89 df             	mov    %rbx,%rdi
  9a916e:	e8 2d 36 d9 01       	call   273c7a0 <xrealloc@@Base>
  9a9173:	48 89 05 9e 5c c4 02 	mov    %rax,0x2c45c9e(%rip)        # 35eee18 <Node_Offsets_Ptr@@Base+0x410>
  9a917a:	48 89 c3             	mov    %rax,%rbx
  9a917d:	44 89 60 04          	mov    %r12d,0x4(%rax)
  9a9181:	44 89 28             	mov    %r13d,(%rax)
  9a9184:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  9a9189:	44 89 e1             	mov    %r12d,%ecx
  9a918c:	44 89 6b 04          	mov    %r13d,0x4(%rbx)
  9a9190:	c7 44 8b 08 00 00 00 	movl   $0x0,0x8(%rbx,%rcx,4)
  9a9197:	00 
  9a9198:	48 8b 1d 71 5c c4 02 	mov    0x2c45c71(%rip),%rbx        # 35eee10 <Node_Offsets_Ptr@@Base+0x408>
  9a919f:	48 85 db             	test   %rbx,%rbx
  9a91a2:	0f 84 7f 06 00 00    	je     9a9827 <gigi@@Base+0x1347>
  9a91a8:	8b 03                	mov    (%rbx),%eax
  9a91aa:	44 8b 63 04          	mov    0x4(%rbx),%r12d
  9a91ae:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  9a91b3:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  9a91b8:	44 39 e0             	cmp    %r12d,%eax
  9a91bb:	0f 85 c8 00 00 00    	jne    9a9289 <gigi@@Base+0xda9>
  9a91c1:	80 7b 03 00          	cmpb   $0x0,0x3(%rbx)
  9a91c5:	79 73                	jns    9a923a <gigi@@Base+0xd5a>
  9a91c7:	48 c7 05 3e 5c c4 02 	movq   $0x0,0x2c45c3e(%rip)        # 35eee10 <Node_Offsets_Ptr@@Base+0x408>
  9a91ce:	00 00 00 00 
  9a91d2:	ba 04 00 00 00       	mov    $0x4,%edx
  9a91d7:	41 39 d5             	cmp    %edx,%r13d
  9a91da:	41 0f 43 d5          	cmovae %r13d,%edx
  9a91de:	31 ff                	xor    %edi,%edi
  9a91e0:	8d 72 02             	lea    0x2(%rdx),%esi
  9a91e3:	89 54 24 08          	mov    %edx,0x8(%rsp)
  9a91e7:	48 c1 e6 02          	shl    $0x2,%rsi
  9a91eb:	e8 b0 35 d9 01       	call   273c7a0 <xrealloc@@Base>
  9a91f0:	8b 54 24 08          	mov    0x8(%rsp),%edx
  9a91f4:	44 89 e1             	mov    %r12d,%ecx
  9a91f7:	48 89 05 12 5c c4 02 	mov    %rax,0x2c45c12(%rip)        # 35eee10 <Node_Offsets_Ptr@@Base+0x408>
  9a91fe:	48 89 c6             	mov    %rax,%rsi
  9a9201:	81 e2 ff ff ff 7f    	and    $0x7fffffff,%edx
  9a9207:	89 d0                	mov    %edx,%eax
  9a9209:	48 89 06             	mov    %rax,(%rsi)
  9a920c:	31 c0                	xor    %eax,%eax
  9a920e:	45 85 e4             	test   %r12d,%r12d
  9a9211:	74 1e                	je     9a9231 <gigi@@Base+0xd51>
  9a9213:	66 90                	xchg   %ax,%ax
  9a9215:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  9a921c:	00 00 00 00 
  9a9220:	8b 54 83 08          	mov    0x8(%rbx,%rax,4),%edx
  9a9224:	89 54 86 08          	mov    %edx,0x8(%rsi,%rax,4)
  9a9228:	48 83 c0 01          	add    $0x1,%rax
  9a922c:	48 39 c1             	cmp    %rax,%rcx
  9a922f:	75 ef                	jne    9a9220 <gigi@@Base+0xd40>
  9a9231:	44 89 66 04          	mov    %r12d,0x4(%rsi)
  9a9235:	48 89 f3             	mov    %rsi,%rbx
  9a9238:	eb 52                	jmp    9a928c <gigi@@Base+0xdac>
  9a923a:	44 89 ee             	mov    %r13d,%esi
  9a923d:	44 89 e7             	mov    %r12d,%edi
  9a9240:	e8 bb 32 ca 01       	call   264c500 <_ZN10vec_prefix22calculate_allocation_1Ejj@@Base>
  9a9245:	48 8b 1d c4 5b c4 02 	mov    0x2c45bc4(%rip),%rbx        # 35eee10 <Node_Offsets_Ptr@@Base+0x408>
  9a924c:	89 c2                	mov    %eax,%edx
  9a924e:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  9a9253:	48 8d 34 95 08 00 00 	lea    0x8(,%rdx,4),%rsi
  9a925a:	00 
  9a925b:	41 89 c5             	mov    %eax,%r13d
  9a925e:	48 85 db             	test   %rbx,%rbx
  9a9261:	0f 84 cb 05 00 00    	je     9a9832 <gigi@@Base+0x1352>
  9a9267:	44 8b 63 04          	mov    0x4(%rbx),%r12d
  9a926b:	48 89 df             	mov    %rbx,%rdi
  9a926e:	e8 2d 35 d9 01       	call   273c7a0 <xrealloc@@Base>
  9a9273:	48 89 05 96 5b c4 02 	mov    %rax,0x2c45b96(%rip)        # 35eee10 <Node_Offsets_Ptr@@Base+0x408>
  9a927a:	48 89 c3             	mov    %rax,%rbx
  9a927d:	44 89 60 04          	mov    %r12d,0x4(%rax)
  9a9281:	44 89 28             	mov    %r13d,(%rax)
  9a9284:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  9a9289:	44 89 e1             	mov    %r12d,%ecx
  9a928c:	44 89 6b 04          	mov    %r13d,0x4(%rbx)
  9a9290:	c7 44 8b 08 00 00 00 	movl   $0x0,0x8(%rbx,%rcx,4)
  9a9297:	00 
  9a9298:	48 8b 1d 69 5b c4 02 	mov    0x2c45b69(%rip),%rbx        # 35eee08 <Node_Offsets_Ptr@@Base+0x400>
  9a929f:	48 85 db             	test   %rbx,%rbx
  9a92a2:	0f 84 6c 05 00 00    	je     9a9814 <gigi@@Base+0x1334>
  9a92a8:	8b 03                	mov    (%rbx),%eax
  9a92aa:	44 8b 63 04          	mov    0x4(%rbx),%r12d
  9a92ae:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  9a92b3:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  9a92b8:	44 39 e0             	cmp    %r12d,%eax
  9a92bb:	0f 85 c8 00 00 00    	jne    9a9389 <gigi@@Base+0xea9>
  9a92c1:	80 7b 03 00          	cmpb   $0x0,0x3(%rbx)
  9a92c5:	79 73                	jns    9a933a <gigi@@Base+0xe5a>
  9a92c7:	48 c7 05 36 5b c4 02 	movq   $0x0,0x2c45b36(%rip)        # 35eee08 <Node_Offsets_Ptr@@Base+0x400>
  9a92ce:	00 00 00 00 
  9a92d2:	ba 04 00 00 00       	mov    $0x4,%edx
  9a92d7:	41 39 d5             	cmp    %edx,%r13d
  9a92da:	41 0f 43 d5          	cmovae %r13d,%edx
  9a92de:	31 ff                	xor    %edi,%edi
  9a92e0:	8d 72 02             	lea    0x2(%rdx),%esi
  9a92e3:	89 54 24 08          	mov    %edx,0x8(%rsp)
  9a92e7:	48 c1 e6 02          	shl    $0x2,%rsi
  9a92eb:	e8 b0 34 d9 01       	call   273c7a0 <xrealloc@@Base>
  9a92f0:	8b 54 24 08          	mov    0x8(%rsp),%edx
  9a92f4:	44 89 e1             	mov    %r12d,%ecx
  9a92f7:	48 89 05 0a 5b c4 02 	mov    %rax,0x2c45b0a(%rip)        # 35eee08 <Node_Offsets_Ptr@@Base+0x400>
  9a92fe:	48 89 c6             	mov    %rax,%rsi
  9a9301:	81 e2 ff ff ff 7f    	and    $0x7fffffff,%edx
  9a9307:	89 d0                	mov    %edx,%eax
  9a9309:	48 89 06             	mov    %rax,(%rsi)
  9a930c:	31 c0                	xor    %eax,%eax
  9a930e:	45 85 e4             	test   %r12d,%r12d
  9a9311:	74 1e                	je     9a9331 <gigi@@Base+0xe51>
  9a9313:	66 90                	xchg   %ax,%ax
  9a9315:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  9a931c:	00 00 00 00 
  9a9320:	8b 54 83 08          	mov    0x8(%rbx,%rax,4),%edx
  9a9324:	89 54 86 08          	mov    %edx,0x8(%rsi,%rax,4)
  9a9328:	48 83 c0 01          	add    $0x1,%rax
  9a932c:	48 39 c8             	cmp    %rcx,%rax
  9a932f:	75 ef                	jne    9a9320 <gigi@@Base+0xe40>
  9a9331:	44 89 66 04          	mov    %r12d,0x4(%rsi)
  9a9335:	48 89 f3             	mov    %rsi,%rbx
  9a9338:	eb 52                	jmp    9a938c <gigi@@Base+0xeac>
  9a933a:	44 89 ee             	mov    %r13d,%esi
  9a933d:	44 89 e7             	mov    %r12d,%edi
  9a9340:	e8 bb 31 ca 01       	call   264c500 <_ZN10vec_prefix22calculate_allocation_1Ejj@@Base>
  9a9345:	48 8b 1d bc 5a c4 02 	mov    0x2c45abc(%rip),%rbx        # 35eee08 <Node_Offsets_Ptr@@Base+0x400>
  9a934c:	89 c2                	mov    %eax,%edx
  9a934e:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  9a9353:	48 8d 34 95 08 00 00 	lea    0x8(,%rdx,4),%rsi
  9a935a:	00 
  9a935b:	41 89 c5             	mov    %eax,%r13d
  9a935e:	48 85 db             	test   %rbx,%rbx
  9a9361:	0f 84 b8 04 00 00    	je     9a981f <gigi@@Base+0x133f>
  9a9367:	44 8b 63 04          	mov    0x4(%rbx),%r12d
  9a936b:	48 89 df             	mov    %rbx,%rdi
  9a936e:	e8 2d 34 d9 01       	call   273c7a0 <xrealloc@@Base>
  9a9373:	48 89 05 8e 5a c4 02 	mov    %rax,0x2c45a8e(%rip)        # 35eee08 <Node_Offsets_Ptr@@Base+0x400>
  9a937a:	48 89 c3             	mov    %rax,%rbx
  9a937d:	44 89 60 04          	mov    %r12d,0x4(%rax)
  9a9381:	44 89 28             	mov    %r13d,(%rax)
  9a9384:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  9a9389:	44 89 e1             	mov    %r12d,%ecx
  9a938c:	44 89 6b 04          	mov    %r13d,0x4(%rbx)
  9a9390:	31 ff                	xor    %edi,%edi
  9a9392:	c7 44 8b 08 00 00 00 	movl   $0x0,0x8(%rbx,%rcx,4)
  9a9399:	00 
  9a939a:	e8 31 65 17 00       	call   b1f8d0 <lib__ident_string@@Base>
  9a939f:	85 c0                	test   %eax,%eax
  9a93a1:	0f 85 b1 02 00 00    	jne    9a9658 <gigi@@Base+0x1178>
  9a93a7:	80 3d a6 0f c3 02 00 	cmpb   $0x0,0x2c30fa6(%rip)        # 35da354 <opt__no_strict_aliasing@@Base>
  9a93ae:	74 0a                	je     9a93ba <gigi@@Base+0xeda>
  9a93b0:	c7 05 6a 16 37 03 00 	movl   $0x0,0x337166a(%rip)        # 3d1aa24 <global_options@@Base+0x1744>
  9a93b7:	00 00 00 
  9a93ba:	be a0 77 d1 03       	mov    $0x3d177a0,%esi
  9a93bf:	bf e0 92 d1 03       	mov    $0x3d192e0,%edi
  9a93c4:	e8 47 85 d0 00       	call   16b1910 <_Z23build_optimization_nodeP11gcc_optionsS0_@@Base>
  9a93c9:	89 ef                	mov    %ebp,%edi
  9a93cb:	48 89 05 7e 39 34 03 	mov    %rax,0x334397e(%rip)        # 3cecd50 <global_trees@@Base+0x4d0>
  9a93d2:	48 89 05 7f 39 34 03 	mov    %rax,0x334397f(%rip)        # 3cecd58 <global_trees@@Base+0x4d8>
  9a93d9:	e8 52 eb ff ff       	call   9a7f30 <_Z20gnat_to_gnu_externali@@Base+0xc0>
  9a93de:	48 8b 3d 8b 5a c4 02 	mov    0x2c45a8b(%rip),%rdi        # 35eee70 <Node_Offsets_Ptr@@Base+0x468>
  9a93e5:	48 85 ff             	test   %rdi,%rdi
  9a93e8:	74 66                	je     9a9450 <gigi@@Base+0xf70>
  9a93ea:	45 31 ed             	xor    %r13d,%r13d
  9a93ed:	44 3b 6f 04          	cmp    0x4(%rdi),%r13d
  9a93f1:	0f 83 39 01 00 00    	jae    9a9530 <gigi@@Base+0x1050>
  9a93f7:	4a 63 5c af 08       	movslq 0x8(%rdi,%r13,4),%rbx
  9a93fc:	48 8b 05 05 56 c4 02 	mov    0x2c45605(%rip),%rax        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a9403:	48 89 dd             	mov    %rbx,%rbp
  9a9406:	48 c1 e3 04          	shl    $0x4,%rbx
  9a940a:	8b 7c 18 04          	mov    0x4(%rax,%rbx,1),%edi
  9a940e:	e8 0d 8d f9 ff       	call   942120 <_Z16gnat_to_gnu_typei@@Base>
  9a9413:	49 89 c4             	mov    %rax,%r12
  9a9416:	48 8b 05 eb 55 c4 02 	mov    0x2c455eb(%rip),%rax        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a941d:	8b 7c 18 08          	mov    0x8(%rax,%rbx,1),%edi
  9a9421:	e8 fa 8c f9 ff       	call   942120 <_Z16gnat_to_gnu_typei@@Base>
  9a9426:	0f b7 10             	movzwl (%rax),%edx
  9a9429:	8d 4a f5             	lea    -0xb(%rdx),%ecx
  9a942c:	66 83 f9 01          	cmp    $0x1,%cx
  9a9430:	0f 86 21 01 00 00    	jbe    9a9557 <gigi@@Base+0x1077>
  9a9436:	66 83 fa 12          	cmp    $0x12,%dx
  9a943a:	0f 84 c3 04 00 00    	je     9a9903 <gigi@@Base+0x1423>
  9a9440:	48 8b 3d 29 5a c4 02 	mov    0x2c45a29(%rip),%rdi        # 35eee70 <Node_Offsets_Ptr@@Base+0x468>
  9a9447:	49 83 c5 01          	add    $0x1,%r13
  9a944b:	48 85 ff             	test   %rdi,%rdi
  9a944e:	75 9d                	jne    9a93ed <gigi@@Base+0xf0d>
  9a9450:	48 8b 1d f9 59 c4 02 	mov    0x2c459f9(%rip),%rbx        # 35eee50 <Node_Offsets_Ptr@@Base+0x448>
  9a9457:	48 85 db             	test   %rbx,%rbx
  9a945a:	74 6d                	je     9a94c9 <gigi@@Base+0xfe9>
  9a945c:	0f 1f 40 00          	nopl   0x0(%rax)
  9a9460:	48 8b 7b 08          	mov    0x8(%rbx),%rdi
  9a9464:	48 8b af c8 00 00 00 	mov    0xc8(%rdi),%rbp
  9a946b:	48 89 e8             	mov    %rbp,%rax
  9a946e:	66 83 7d 00 44       	cmpw   $0x44,0x0(%rbp)
  9a9473:	0f 84 97 00 00 00    	je     9a9510 <gigi@@Base+0x1030>
  9a9479:	48 8b 40 10          	mov    0x10(%rax),%rax
  9a947d:	48 85 c0             	test   %rax,%rax
  9a9480:	75 1e                	jne    9a94a0 <gigi@@Base+0xfc0>
  9a9482:	e9 96 00 00 00       	jmp    9a951d <gigi@@Base+0x103d>
  9a9487:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  9a948e:	00 00 
  9a9490:	48 83 7a 18 00       	cmpq   $0x0,0x18(%rdx)
  9a9495:	75 14                	jne    9a94ab <gigi@@Base+0xfcb>
  9a9497:	48 8b 40 08          	mov    0x8(%rax),%rax
  9a949b:	48 85 c0             	test   %rax,%rax
  9a949e:	74 7d                	je     9a951d <gigi@@Base+0x103d>
  9a94a0:	48 8b 50 10          	mov    0x10(%rax),%rdx
  9a94a4:	66 81 3a 0d 01       	cmpw   $0x10d,(%rdx)
  9a94a9:	74 e5                	je     9a9490 <gigi@@Base+0xfb0>
  9a94ab:	e8 c0 b8 fc ff       	call   974d70 <_Z18begin_subprog_bodyP9tree_node@@Base>
  9a94b0:	48 89 ef             	mov    %rbp,%rdi
  9a94b3:	e8 e8 b8 fc ff       	call   974da0 <_Z16end_subprog_bodyP9tree_node@@Base>
  9a94b8:	48 8b 7b 08          	mov    0x8(%rbx),%rdi
  9a94bc:	e8 3f b9 fc ff       	call   974e00 <_Z32rest_of_subprog_body_compilationP9tree_node@@Base>
  9a94c1:	48 8b 1b             	mov    (%rbx),%rbx
  9a94c4:	48 85 db             	test   %rbx,%rbx
  9a94c7:	75 97                	jne    9a9460 <gigi@@Base+0xf80>
  9a94c9:	48 c7 05 44 55 c4 02 	movq   $0x0,0x2c45544(%rip)        # 35eea18 <Node_Offsets_Ptr@@Base+0x10>
  9a94d0:	00 00 00 00 
  9a94d4:	e8 17 a9 f8 ff       	call   933df0 <_Z17destroy_gnat_declv@@Base>
  9a94d9:	e8 32 93 fc ff       	call   972810 <_Z18destroy_gnat_utilsv@@Base>
  9a94de:	48 8b 5c 24 70       	mov    0x70(%rsp),%rbx
  9a94e3:	c7 05 8f 03 c3 02 00 	movl   $0x0,0x2c3038f(%rip)        # 35d987c <atree__current_error_node@@Base>
  9a94ea:	00 00 00 
  9a94ed:	48 8b 6c 24 78       	mov    0x78(%rsp),%rbp
  9a94f2:	4c 8b a4 24 80 00 00 	mov    0x80(%rsp),%r12
  9a94f9:	00 
  9a94fa:	4c 8b ac 24 88 00 00 	mov    0x88(%rsp),%r13
  9a9501:	00 
  9a9502:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  9a9509:	c3                   	ret
  9a950a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  9a9510:	48 8b 45 20          	mov    0x20(%rbp),%rax
  9a9514:	48 85 c0             	test   %rax,%rax
  9a9517:	0f 85 5c ff ff ff    	jne    9a9479 <gigi@@Base+0xf99>
  9a951d:	8b 7b 10             	mov    0x10(%rbx),%edi
  9a9520:	be 01 00 00 00       	mov    $0x1,%esi
  9a9525:	e8 86 18 3a 00       	call   d4adb0 <sinfo__nodes__set_has_no_elaboration_code@@Base>
  9a952a:	eb 95                	jmp    9a94c1 <gigi@@Base+0xfe1>
  9a952c:	0f 1f 40 00          	nopl   0x0(%rax)
  9a9530:	80 7f 03 00          	cmpb   $0x0,0x3(%rdi)
  9a9534:	79 0c                	jns    9a9542 <gigi@@Base+0x1062>
  9a9536:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%rdi)
  9a953d:	e9 0e ff ff ff       	jmp    9a9450 <gigi@@Base+0xf70>
  9a9542:	e8 a9 f3 f2 ff       	call   8d88f0 <free@plt>
  9a9547:	48 c7 05 1e 59 c4 02 	movq   $0x0,0x2c4591e(%rip)        # 35eee70 <Node_Offsets_Ptr@@Base+0x468>
  9a954e:	00 00 00 00 
  9a9552:	e9 f9 fe ff ff       	jmp    9a9450 <gigi@@Base+0xf70>
  9a9557:	f6 40 03 04          	testb  $0x4,0x3(%rax)
  9a955b:	0f 85 df fe ff ff    	jne    9a9440 <gigi@@Base+0xf60>
  9a9561:	4c 89 b4 24 90 00 00 	mov    %r14,0x90(%rsp)
  9a9568:	00 
  9a9569:	41 0f b7 0c 24       	movzwl (%r12),%ecx
  9a956e:	45 31 f6             	xor    %r14d,%r14d
  9a9571:	8d 51 f5             	lea    -0xb(%rcx),%edx
  9a9574:	66 83 fa 01          	cmp    $0x1,%dx
  9a9578:	77 05                	ja     9a957f <gigi@@Base+0x109f>
  9a957a:	4d 8b 74 24 08       	mov    0x8(%r12),%r14
  9a957f:	48 8b 78 08          	mov    0x8(%rax),%rdi
  9a9583:	e8 38 27 40 00       	call   dabcc0 <_Z13get_alias_setP9tree_node@@Base>
  9a9588:	89 c6                	mov    %eax,%esi
  9a958a:	85 c0                	test   %eax,%eax
  9a958c:	74 1a                	je     9a95a8 <gigi@@Base+0x10c8>
  9a958e:	41 0f b7 04 24       	movzwl (%r12),%eax
  9a9593:	83 e8 0b             	sub    $0xb,%eax
  9a9596:	66 83 f8 01          	cmp    $0x1,%ax
  9a959a:	0f 86 c7 04 00 00    	jbe    9a9a67 <gigi@@Base+0x1587>
  9a95a0:	85 ed                	test   %ebp,%ebp
  9a95a2:	0f 85 28 04 00 00    	jne    9a99d0 <gigi@@Base+0x14f0>
  9a95a8:	4c 8b b4 24 90 00 00 	mov    0x90(%rsp),%r14
  9a95af:	00 
  9a95b0:	e9 8b fe ff ff       	jmp    9a9440 <gigi@@Base+0xf60>
  9a95b5:	48 8b 3d 24 32 34 03 	mov    0x3343224(%rip),%rdi        # 3cec7e0 <integer_types@@Base>
  9a95bc:	48 8b 1d 45 32 34 03 	mov    0x3343245(%rip),%rbx        # 3cec808 <integer_types@@Base+0x28>
  9a95c3:	e8 98 46 cf 00       	call   169dc60 <_Z18build_pointer_typeP9tree_node@@Base>
  9a95c8:	48 8b 3d a1 34 34 03 	mov    0x33434a1(%rip),%rdi        # 3ceca70 <global_trees@@Base+0x1f0>
  9a95cf:	48 89 da             	mov    %rbx,%rdx
  9a95d2:	31 c9                	xor    %ecx,%ecx
  9a95d4:	48 89 c6             	mov    %rax,%rsi
  9a95d7:	31 c0                	xor    %eax,%eax
  9a95d9:	e8 22 f9 cf 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a95de:	be 02 00 00 00       	mov    $0x2,%esi
  9a95e3:	48 89 c7             	mov    %rax,%rdi
  9a95e6:	e8 15 b4 cf 00       	call   16a4a00 <_Z20build_qualified_typeP9tree_nodei@@Base>
  9a95eb:	be 1a 00 00 00       	mov    $0x1a,%esi
  9a95f0:	bf d3 04 9f 02       	mov    $0x29f04d3,%edi
  9a95f5:	48 89 c3             	mov    %rax,%rbx
  9a95f8:	e8 d3 71 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a95fd:	48 83 ec 08          	sub    $0x8,%rsp
  9a9601:	48 89 da             	mov    %rbx,%rdx
  9a9604:	31 c9                	xor    %ecx,%ecx
  9a9606:	6a 00                	push   $0x0
  9a9608:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a960e:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a9614:	31 f6                	xor    %esi,%esi
  9a9616:	6a 00                	push   $0x0
  9a9618:	48 89 c7             	mov    %rax,%rdi
  9a961b:	6a 00                	push   $0x0
  9a961d:	6a 00                	push   $0x0
  9a961f:	6a 01                	push   $0x1
  9a9621:	6a 01                	push   $0x1
  9a9623:	6a 00                	push   $0x0
  9a9625:	e8 26 b5 fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a962a:	48 83 c4 40          	add    $0x40,%rsp
  9a962e:	48 89 c2             	mov    %rax,%rdx
  9a9631:	b8 a0 c1 5e 03       	mov    $0x35ec1a0,%eax
  9a9636:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  9a963d:	00 00 00 
  9a9640:	48 89 10             	mov    %rdx,(%rax)
  9a9643:	48 83 c0 10          	add    $0x10,%rax
  9a9647:	48 89 50 f8          	mov    %rdx,-0x8(%rax)
  9a964b:	48 3d e0 c2 5e 03    	cmp    $0x35ec2e0,%rax
  9a9651:	75 ed                	jne    9a9640 <gigi@@Base+0x1160>
  9a9653:	e9 c7 f9 ff ff       	jmp    9a901f <gigi@@Base+0xb3f>
  9a9658:	31 ff                	xor    %edi,%edi
  9a965a:	48 8b 1d 17 a9 c3 02 	mov    0x2c3a917(%rip),%rbx        # 35e3f78 <targetm@@Base+0x218>
  9a9661:	e8 6a 62 17 00       	call   b1f8d0 <lib__ident_string@@Base>
  9a9666:	89 c7                	mov    %eax,%edi
  9a9668:	e8 73 e1 fe ff       	call   9977e0 <_Z11gnat_to_gnui@@Base>
  9a966d:	48 8d 78 14          	lea    0x14(%rax),%rdi
  9a9671:	ff d3                	call   *%rbx
  9a9673:	e9 2f fd ff ff       	jmp    9a93a7 <gigi@@Base+0xec7>
  9a9678:	48 8b 84 24 d8 00 00 	mov    0xd8(%rsp),%rax
  9a967f:	00 
  9a9680:	48 83 3d 90 0c 1d 03 	cmpq   $0x0,0x31d0c90(%rip)        # 3b7a318 <decl_to_instance_map@@Base>
  9a9687:	00 
  9a9688:	48 89 05 89 53 c4 02 	mov    %rax,0x2c45389(%rip)        # 35eea18 <Node_Offsets_Ptr@@Base+0x10>
  9a968f:	0f 85 06 ef ff ff    	jne    9a859b <gigi@@Base+0xbb>
  9a9695:	bf 30 00 00 00       	mov    $0x30,%edi
  9a969a:	e8 e1 cb 01 02       	call   29c6280 <_Znwm@@Base>
  9a969f:	ba 00 01 00 00       	mov    $0x100,%edx
  9a96a4:	66 0f ef c0          	pxor   %xmm0,%xmm0
  9a96a8:	48 63 fb             	movslq %ebx,%rdi
  9a96ab:	66 89 50 2c          	mov    %dx,0x2c(%rax)
  9a96af:	49 89 c4             	mov    %rax,%r12
  9a96b2:	48 c7 40 20 00 00 00 	movq   $0x0,0x20(%rax)
  9a96b9:	00 
  9a96ba:	0f 11 40 10          	movups %xmm0,0x10(%rax)
  9a96be:	e8 bd 56 ca 01       	call   264ed80 <_Z29hash_table_higher_prime_indexm@@Base>
  9a96c3:	be 10 00 00 00       	mov    $0x10,%esi
  9a96c8:	41 89 c5             	mov    %eax,%r13d
  9a96cb:	89 c0                	mov    %eax,%eax
  9a96cd:	48 c1 e0 04          	shl    $0x4,%rax
  9a96d1:	8b 90 40 d5 12 03    	mov    0x312d540(%rax),%edx
  9a96d7:	48 89 d7             	mov    %rdx,%rdi
  9a96da:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
  9a96df:	e8 6c 30 d9 01       	call   273c750 <xcalloc@@Base>
  9a96e4:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
  9a96e9:	45 89 6c 24 28       	mov    %r13d,0x28(%r12)
  9a96ee:	49 89 04 24          	mov    %rax,(%r12)
  9a96f2:	49 89 54 24 08       	mov    %rdx,0x8(%r12)
  9a96f7:	4c 89 25 1a 0c 1d 03 	mov    %r12,0x31d0c1a(%rip)        # 3b7a318 <decl_to_instance_map@@Base>
  9a96fe:	e9 98 ee ff ff       	jmp    9a859b <gigi@@Base+0xbb>
  9a9703:	31 f6                	xor    %esi,%esi
  9a9705:	bf 80 00 00 00       	mov    $0x80,%edi
  9a970a:	e8 51 b7 fc ff       	call   974e60 <_Z18gnat_type_for_sizeji@@Base>
  9a970f:	31 c9                	xor    %ecx,%ecx
  9a9711:	48 89 c2             	mov    %rax,%rdx
  9a9714:	48 89 c6             	mov    %rax,%rsi
  9a9717:	48 89 c7             	mov    %rax,%rdi
  9a971a:	31 c0                	xor    %eax,%eax
  9a971c:	e8 df f7 cf 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a9721:	be 0e 00 00 00       	mov    $0xe,%esi
  9a9726:	bf f4 03 9f 02       	mov    $0x29f03f4,%edi
  9a972b:	48 89 c3             	mov    %rax,%rbx
  9a972e:	e8 9d 70 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a9733:	48 83 ec 08          	sub    $0x8,%rsp
  9a9737:	31 c9                	xor    %ecx,%ecx
  9a9739:	48 89 da             	mov    %rbx,%rdx
  9a973c:	6a 00                	push   $0x0
  9a973e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a9744:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a974a:	31 f6                	xor    %esi,%esi
  9a974c:	6a 00                	push   $0x0
  9a974e:	48 89 c7             	mov    %rax,%rdi
  9a9751:	6a 00                	push   $0x0
  9a9753:	6a 00                	push   $0x0
  9a9755:	6a 01                	push   $0x1
  9a9757:	6a 01                	push   $0x1
  9a9759:	6a 00                	push   $0x0
  9a975b:	e8 f0 b3 fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a9760:	48 83 c4 40          	add    $0x40,%rsp
  9a9764:	48 89 c7             	mov    %rax,%rdi
  9a9767:	48 89 05 da 2b c4 02 	mov    %rax,0x2c42bda(%rip)        # 35ec348 <gnat_std_decls@@Base+0x68>
  9a976e:	e8 2d 40 76 00       	call   110d7a0 <_Z19strub_make_callableP9tree_node@@Base>
  9a9773:	be 01 00 00 00       	mov    $0x1,%esi
  9a9778:	bf 80 00 00 00       	mov    $0x80,%edi
  9a977d:	e8 de b6 fc ff       	call   974e60 <_Z18gnat_type_for_sizeji@@Base>
  9a9782:	31 c9                	xor    %ecx,%ecx
  9a9784:	48 89 c2             	mov    %rax,%rdx
  9a9787:	48 89 c6             	mov    %rax,%rsi
  9a978a:	48 89 c7             	mov    %rax,%rdi
  9a978d:	31 c0                	xor    %eax,%eax
  9a978f:	e8 6c f7 cf 00       	call   16a8f00 <_Z24build_function_type_listP9tree_nodez@@Base>
  9a9794:	be 12 00 00 00       	mov    $0x12,%esi
  9a9799:	bf 03 04 9f 02       	mov    $0x29f0403,%edi
  9a979e:	48 89 c3             	mov    %rax,%rbx
  9a97a1:	e8 2a 70 9a 00       	call   13507d0 <_Z26get_identifier_with_lengthPKcm@@Base>
  9a97a6:	48 83 ec 08          	sub    $0x8,%rsp
  9a97aa:	31 c9                	xor    %ecx,%ecx
  9a97ac:	48 89 da             	mov    %rbx,%rdx
  9a97af:	6a 00                	push   $0x0
  9a97b1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  9a97b7:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  9a97bd:	31 f6                	xor    %esi,%esi
  9a97bf:	6a 00                	push   $0x0
  9a97c1:	48 89 c7             	mov    %rax,%rdi
  9a97c4:	6a 00                	push   $0x0
  9a97c6:	6a 00                	push   $0x0
  9a97c8:	6a 01                	push   $0x1
  9a97ca:	6a 01                	push   $0x1
  9a97cc:	6a 00                	push   $0x0
  9a97ce:	e8 7d b3 fc ff       	call   974b50 <_Z19create_subprog_declP9tree_nodeS0_S0_S0_15inline_status_tbbbbbbP6attribi@@Base>
  9a97d3:	48 83 c4 40          	add    $0x40,%rsp
  9a97d7:	48 89 c7             	mov    %rax,%rdi
  9a97da:	48 89 05 6f 2b c4 02 	mov    %rax,0x2c42b6f(%rip)        # 35ec350 <gnat_std_decls@@Base+0x70>
  9a97e1:	e8 ba 3f 76 00       	call   110d7a0 <_Z19strub_make_callableP9tree_node@@Base>
  9a97e6:	e9 39 f4 ff ff       	jmp    9a8c24 <gigi@@Base+0x744>
  9a97eb:	bf 98 03 9f 02       	mov    $0x29f0398,%edi
  9a97f0:	e8 1b 1d 54 00       	call   eeb510 <_Z23set_stack_check_libfuncPKc@@Base>
  9a97f5:	8b 05 8d fb 36 03    	mov    0x336fb8d(%rip),%eax        # 3d19388 <global_options@@Base+0xa8>
  9a97fb:	85 c0                	test   %eax,%eax
  9a97fd:	0f 84 9f ef ff ff    	je     9a87a2 <gigi@@Base+0x2c2>
  9a9803:	89 ee                	mov    %ebp,%esi
  9a9805:	bf 74 7d 28 e8       	mov    $0xe8287d74,%edi
  9a980a:	e8 71 80 1c 00       	call   b71880 <restrict__check_restriction_no_dependence_on_system@@Base>
  9a980f:	e9 8e ef ff ff       	jmp    9a87a2 <gigi@@Base+0x2c2>
  9a9814:	41 bd 04 00 00 00    	mov    $0x4,%r13d
  9a981a:	be 18 00 00 00       	mov    $0x18,%esi
  9a981f:	45 31 e4             	xor    %r12d,%r12d
  9a9822:	e9 44 fb ff ff       	jmp    9a936b <gigi@@Base+0xe8b>
  9a9827:	41 bd 04 00 00 00    	mov    $0x4,%r13d
  9a982d:	be 18 00 00 00       	mov    $0x18,%esi
  9a9832:	45 31 e4             	xor    %r12d,%r12d
  9a9835:	e9 31 fa ff ff       	jmp    9a926b <gigi@@Base+0xd8b>
  9a983a:	41 bd 04 00 00 00    	mov    $0x4,%r13d
  9a9840:	be 18 00 00 00       	mov    $0x18,%esi
  9a9845:	45 31 e4             	xor    %r12d,%r12d
  9a9848:	e9 1e f9 ff ff       	jmp    9a916b <gigi@@Base+0xc8b>
  9a984d:	bf 28 00 00 00       	mov    $0x28,%edi
  9a9852:	e8 09 ab 3f 00       	call   da4360 <_Z20ggc_round_alloc_sizem@@Base>
  9a9857:	48 8b 3d ea 55 c4 02 	mov    0x2c455ea(%rip),%rdi        # 35eee48 <Node_Offsets_Ptr@@Base+0x440>
  9a985e:	4c 8d 68 f8          	lea    -0x8(%rax),%r13
  9a9862:	49 c1 ed 03          	shr    $0x3,%r13
  9a9866:	44 89 e8             	mov    %r13d,%eax
  9a9869:	48 8d 34 c5 08 00 00 	lea    0x8(,%rax,8),%rsi
  9a9870:	00 
  9a9871:	48 85 ff             	test   %rdi,%rdi
  9a9874:	74 7e                	je     9a98f4 <gigi@@Base+0x1414>
  9a9876:	8b 47 04             	mov    0x4(%rdi),%eax
  9a9879:	48 89 c2             	mov    %rax,%rdx
  9a987c:	8d 58 01             	lea    0x1(%rax),%ebx
  9a987f:	4c 8d 24 c5 08 00 00 	lea    0x8(,%rax,8),%r12
  9a9886:	00 
  9a9887:	89 54 24 08          	mov    %edx,0x8(%rsp)
  9a988b:	41 81 e5 ff ff ff 7f 	and    $0x7fffffff,%r13d
  9a9892:	e8 e9 69 5d 00       	call   f80280 <_Z11ggc_reallocPvm@@Base>
  9a9897:	8b 54 24 08          	mov    0x8(%rsp),%edx
  9a989b:	48 89 05 a6 55 c4 02 	mov    %rax,0x2c455a6(%rip)        # 35eee48 <Node_Offsets_Ptr@@Base+0x440>
  9a98a2:	44 89 28             	mov    %r13d,(%rax)
  9a98a5:	89 50 04             	mov    %edx,0x4(%rax)
  9a98a8:	e9 df f7 ff ff       	jmp    9a908c <gigi@@Base+0xbac>
  9a98ad:	89 de                	mov    %ebx,%esi
  9a98af:	e8 4c 2c ca 01       	call   264c500 <_ZN10vec_prefix22calculate_allocation_1Ejj@@Base>
  9a98b4:	85 c0                	test   %eax,%eax
  9a98b6:	74 0c                	je     9a98c4 <gigi@@Base+0x13e4>
  9a98b8:	89 c0                	mov    %eax,%eax
  9a98ba:	48 8d 3c c5 08 00 00 	lea    0x8(,%rax,8),%rdi
  9a98c1:	00 
  9a98c2:	eb 8e                	jmp    9a9852 <gigi@@Base+0x1372>
  9a98c4:	48 8b 3d 7d 55 c4 02 	mov    0x2c4557d(%rip),%rdi        # 35eee48 <Node_Offsets_Ptr@@Base+0x440>
  9a98cb:	e8 80 b7 3f 00       	call   da5050 <_Z8ggc_freePv@@Base>
  9a98d0:	48 c7 05 6d 55 c4 02 	movq   $0x0,0x2c4556d(%rip)        # 35eee48 <Node_Offsets_Ptr@@Base+0x440>
  9a98d7:	00 00 00 00 
  9a98db:	8b 04 25 04 00 00 00 	mov    0x4,%eax
  9a98e2:	8d 58 01             	lea    0x1(%rax),%ebx
  9a98e5:	4c 8d 24 c5 08 00 00 	lea    0x8(,%rax,8),%r12
  9a98ec:	00 
  9a98ed:	31 c0                	xor    %eax,%eax
  9a98ef:	e9 98 f7 ff ff       	jmp    9a908c <gigi@@Base+0xbac>
  9a98f4:	41 bc 08 00 00 00    	mov    $0x8,%r12d
  9a98fa:	bb 01 00 00 00       	mov    $0x1,%ebx
  9a98ff:	31 d2                	xor    %edx,%edx
  9a9901:	eb 84                	jmp    9a9887 <gigi@@Base+0x13a7>
  9a9903:	f6 40 38 01          	testb  $0x1,0x38(%rax)
  9a9907:	0f 84 33 fb ff ff    	je     9a9440 <gigi@@Base+0xf60>
  9a990d:	66 41 83 3c 24 12    	cmpw   $0x12,(%r12)
  9a9913:	0f 84 96 00 00 00    	je     9a99af <gigi@@Base+0x14cf>
  9a9919:	31 d2                	xor    %edx,%edx
  9a991b:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
  9a9922:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
  9a9927:	48 8b 40 08          	mov    0x8(%rax),%rax
  9a992b:	48 8b 78 08          	mov    0x8(%rax),%rdi
  9a992f:	e8 8c 23 40 00       	call   dabcc0 <_Z13get_alias_setP9tree_node@@Base>
  9a9934:	85 c0                	test   %eax,%eax
  9a9936:	0f 84 04 fb ff ff    	je     9a9440 <gigi@@Base+0xf60>
  9a993c:	66 41 83 3c 24 12    	cmpw   $0x12,(%r12)
  9a9942:	0f 84 43 01 00 00    	je     9a9a8b <gigi@@Base+0x15ab>
  9a9948:	85 ed                	test   %ebp,%ebp
  9a994a:	0f 84 f0 fa ff ff    	je     9a9440 <gigi@@Base+0xf60>
  9a9950:	48 8b 05 b1 50 c4 02 	mov    0x2c450b1(%rip),%rax        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a9957:	89 ea                	mov    %ebp,%edx
  9a9959:	bf 60 3c aa 02       	mov    $0x2aa3c60,%edi
  9a995e:	8b 4c 18 08          	mov    0x8(%rax,%rbx,1),%ecx
  9a9962:	48 8d 5c 24 68       	lea    0x68(%rsp),%rbx
  9a9967:	48 b8 01 00 00 00 25 	movabs $0x2500000001,%rax
  9a996e:	00 00 00 
  9a9971:	48 89 5c 24 48       	mov    %rbx,0x48(%rsp)
  9a9976:	48 8b 74 24 48       	mov    0x48(%rsp),%rsi
  9a997b:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
  9a9980:	e8 0b cf 05 00       	call   a06890 <errout__error_msg_ne_gigi@@Base>
  9a9985:	48 89 5c 24 58       	mov    %rbx,0x58(%rsp)
  9a998a:	48 8b 74 24 58       	mov    0x58(%rsp),%rsi
  9a998f:	48 b8 01 00 00 00 31 	movabs $0x3100000001,%rax
  9a9996:	00 00 00 
  9a9999:	89 ea                	mov    %ebp,%edx
  9a999b:	bf 88 3c aa 02       	mov    $0x2aa3c88,%edi
  9a99a0:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
  9a99a5:	e8 b6 cf 05 00       	call   a06960 <errout__error_msg_n_gigi@@Base>
  9a99aa:	e9 91 fa ff ff       	jmp    9a9440 <gigi@@Base+0xf60>
  9a99af:	41 f6 44 24 38 01    	testb  $0x1,0x38(%r12)
  9a99b5:	0f 84 5e ff ff ff    	je     9a9919 <gigi@@Base+0x1439>
  9a99bb:	49 8b 94 24 88 00 00 	mov    0x88(%r12),%rdx
  9a99c2:	00 
  9a99c3:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  9a99c7:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  9a99cb:	e9 4b ff ff ff       	jmp    9a991b <gigi@@Base+0x143b>
  9a99d0:	48 8b 05 31 50 c4 02 	mov    0x2c45031(%rip),%rax        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a99d7:	4c 8d 64 24 68       	lea    0x68(%rsp),%r12
  9a99dc:	89 ea                	mov    %ebp,%edx
  9a99de:	bf 60 3c aa 02       	mov    $0x2aa3c60,%edi
  9a99e3:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
  9a99e8:	48 8b 74 24 18       	mov    0x18(%rsp),%rsi
  9a99ed:	8b 4c 18 08          	mov    0x8(%rax,%rbx,1),%ecx
  9a99f1:	48 b8 01 00 00 00 25 	movabs $0x2500000001,%rax
  9a99f8:	00 00 00 
  9a99fb:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
  9a9a00:	e8 8b ce 05 00       	call   a06890 <errout__error_msg_ne_gigi@@Base>
  9a9a05:	4c 89 64 24 28       	mov    %r12,0x28(%rsp)
  9a9a0a:	48 8b 74 24 28       	mov    0x28(%rsp),%rsi
  9a9a0f:	48 b8 01 00 00 00 31 	movabs $0x3100000001,%rax
  9a9a16:	00 00 00 
  9a9a19:	89 ea                	mov    %ebp,%edx
  9a9a1b:	bf 88 3c aa 02       	mov    $0x2aa3c88,%edi
  9a9a20:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
  9a9a25:	e8 36 cf 05 00       	call   a06960 <errout__error_msg_n_gigi@@Base>
  9a9a2a:	48 8b 05 d7 4f c4 02 	mov    0x2c44fd7(%rip),%rax        # 35eea08 <Node_Offsets_Ptr@@Base>
  9a9a31:	4c 89 64 24 38       	mov    %r12,0x38(%rsp)
  9a9a36:	89 ea                	mov    %ebp,%edx
  9a9a38:	48 8b 74 24 38       	mov    0x38(%rsp),%rsi
  9a9a3d:	bf c0 3c aa 02       	mov    $0x2aa3cc0,%edi
  9a9a42:	8b 4c 18 08          	mov    0x8(%rax,%rbx,1),%ecx
  9a9a46:	48 b8 01 00 00 00 2a 	movabs $0x2a00000001,%rax
  9a9a4d:	00 00 00 
  9a9a50:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
  9a9a55:	e8 36 ce 05 00       	call   a06890 <errout__error_msg_ne_gigi@@Base>
  9a9a5a:	4c 8b b4 24 90 00 00 	mov    0x90(%rsp),%r14
  9a9a61:	00 
  9a9a62:	e9 d9 f9 ff ff       	jmp    9a9440 <gigi@@Base+0xf60>
  9a9a67:	4c 89 f7             	mov    %r14,%rdi
  9a9a6a:	89 74 24 08          	mov    %esi,0x8(%rsp)
  9a9a6e:	e8 4d 22 40 00       	call   dabcc0 <_Z13get_alias_setP9tree_node@@Base>
  9a9a73:	8b 74 24 08          	mov    0x8(%rsp),%esi
  9a9a77:	89 c7                	mov    %eax,%edi
  9a9a79:	e8 42 e7 3f 00       	call   da81c0 <_Z21alias_sets_conflict_pii@@Base>
  9a9a7e:	84 c0                	test   %al,%al
  9a9a80:	0f 85 22 fb ff ff    	jne    9a95a8 <gigi@@Base+0x10c8>
  9a9a86:	e9 15 fb ff ff       	jmp    9a95a0 <gigi@@Base+0x10c0>
  9a9a8b:	41 f6 44 24 38 01    	testb  $0x1,0x38(%r12)
  9a9a91:	0f 84 b1 fe ff ff    	je     9a9948 <gigi@@Base+0x1468>
  9a9a97:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  9a9a9c:	89 44 24 08          	mov    %eax,0x8(%rsp)
  9a9aa0:	e8 1b 22 40 00       	call   dabcc0 <_Z13get_alias_setP9tree_node@@Base>
  9a9aa5:	8b 74 24 08          	mov    0x8(%rsp),%esi
  9a9aa9:	89 c7                	mov    %eax,%edi
  9a9aab:	e8 10 e7 3f 00       	call   da81c0 <_Z21alias_sets_conflict_pii@@Base>
  9a9ab0:	84 c0                	test   %al,%al
  9a9ab2:	0f 85 88 f9 ff ff    	jne    9a9440 <gigi@@Base+0xf60>
  9a9ab8:	e9 8b fe ff ff       	jmp    9a9948 <gigi@@Base+0x1468>

Disassembly of section .fini:
