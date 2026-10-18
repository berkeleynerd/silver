
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

00000000016a2e20 <_Z9copy_nodeP9tree_node@@Base>:
 16a2e20:	41 55                	push   %r13
 16a2e22:	41 54                	push   %r12
 16a2e24:	55                   	push   %rbp
 16a2e25:	53                   	push   %rbx
 16a2e26:	48 83 ec 18          	sub    $0x18,%rsp
 16a2e2a:	44 0f b7 27          	movzwl (%rdi),%r12d
 16a2e2e:	41 81 fc a1 00 00 00 	cmp    $0xa1,%r12d
 16a2e35:	0f 84 4f 6f 26 ff    	je     909d8a <_Z24diagnose_versioned_declsP9tree_nodeS0_@@Base+0x2f>
 16a2e3b:	48 89 fd             	mov    %rdi,%rbp
 16a2e3e:	e8 6d 06 ff ff       	call   16934b0 <_Z9tree_sizePK9tree_node@@Base>
 16a2e43:	b9 01 00 00 00       	mov    $0x1,%ecx
 16a2e48:	31 d2                	xor    %edx,%edx
 16a2e4a:	31 f6                	xor    %esi,%esi
 16a2e4c:	48 89 c7             	mov    %rax,%rdi
 16a2e4f:	49 89 c5             	mov    %rax,%r13
 16a2e52:	e8 59 15 70 ff       	call   da43b0 <_Z18ggc_internal_allocmPFvPvEmm@@Base>
 16a2e57:	4c 89 ea             	mov    %r13,%rdx
 16a2e5a:	48 89 ee             	mov    %rbp,%rsi
 16a2e5d:	48 89 c7             	mov    %rax,%rdi
 16a2e60:	48 89 c3             	mov    %rax,%rbx
 16a2e63:	e8 a8 59 23 ff       	call   8d8810 <memcpy@plt>
 16a2e68:	44 89 e0             	mov    %r12d,%eax
 16a2e6b:	48 89 c2             	mov    %rax,%rdx
 16a2e6e:	48 c1 e2 06          	shl    $0x6,%rdx
 16a2e72:	80 ba 82 66 ce 03 00 	cmpb   $0x0,0x3ce6682(%rdx)
 16a2e79:	74 08                	je     16a2e83 <_Z9copy_nodeP9tree_node@@Base+0x63>
 16a2e7b:	48 c7 43 10 00 00 00 	movq   $0x0,0x10(%rbx)
 16a2e82:	00 
 16a2e83:	8b 04 85 e0 e3 bf 02 	mov    0x2bfe3e0(,%rax,4),%eax
 16a2e8a:	80 63 02 5f          	andb   $0x5f,0x2(%rbx)
 16a2e8e:	83 f8 03             	cmp    $0x3,%eax
 16a2e91:	74 75                	je     16a2f08 <_Z9copy_nodeP9tree_node@@Base+0xe8>
 16a2e93:	83 f8 02             	cmp    $0x2,%eax
 16a2e96:	74 28                	je     16a2ec0 <_Z9copy_nodeP9tree_node@@Base+0xa0>
 16a2e98:	41 81 fc f3 00 00 00 	cmp    $0xf3,%r12d
 16a2e9f:	0f 84 6b 01 00 00    	je     16a3010 <_Z9copy_nodeP9tree_node@@Base+0x1f0>
 16a2ea5:	41 81 fc f2 00 00 00 	cmp    $0xf2,%r12d
 16a2eac:	0f 84 8e 01 00 00    	je     16a3040 <_Z9copy_nodeP9tree_node@@Base+0x220>
 16a2eb2:	48 83 c4 18          	add    $0x18,%rsp
 16a2eb6:	48 89 d8             	mov    %rbx,%rax
 16a2eb9:	5b                   	pop    %rbx
 16a2eba:	5d                   	pop    %rbp
 16a2ebb:	41 5c                	pop    %r12
 16a2ebd:	41 5d                	pop    %r13
 16a2ebf:	c3                   	ret
 16a2ec0:	8b 05 6a 0e f4 01    	mov    0x1f40e6a(%rip),%eax        # 35e3d30 <slp_patterns@@Base+0xd0>
 16a2ec6:	48 c7 43 50 00 00 00 	movq   $0x0,0x50(%rbx)
 16a2ecd:	00 
 16a2ece:	8d 50 01             	lea    0x1(%rax),%edx
 16a2ed1:	89 43 30             	mov    %eax,0x30(%rbx)
 16a2ed4:	0f b6 43 03          	movzbl 0x3(%rbx),%eax
 16a2ed8:	89 15 52 0e f4 01    	mov    %edx,0x1f40e52(%rip)        # 35e3d30 <slp_patterns@@Base+0xd0>
 16a2ede:	a8 08                	test   $0x8,%al
 16a2ee0:	74 d0                	je     16a2eb2 <_Z9copy_nodeP9tree_node@@Base+0x92>
 16a2ee2:	48 c7 83 88 00 00 00 	movq   $0x0,0x88(%rbx)
 16a2ee9:	00 00 00 00 
 16a2eed:	83 e0 f7             	and    $0xfffffff7,%eax
 16a2ef0:	88 43 03             	mov    %al,0x3(%rbx)
 16a2ef3:	48 83 c4 18          	add    $0x18,%rsp
 16a2ef7:	48 89 d8             	mov    %rbx,%rax
 16a2efa:	5b                   	pop    %rbx
 16a2efb:	5d                   	pop    %rbp
 16a2efc:	41 5c                	pop    %r12
 16a2efe:	41 5d                	pop    %r13
 16a2f00:	c3                   	ret
 16a2f01:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 16a2f08:	41 83 fc 2b          	cmp    $0x2b,%r12d
 16a2f0c:	0f 84 d6 00 00 00    	je     16a2fe8 <_Z9copy_nodeP9tree_node@@Base+0x1c8>
 16a2f12:	8b 05 34 a6 64 02    	mov    0x264a634(%rip),%eax        # 3ced54c <tree_node_counts@@Base+0x72c>
 16a2f18:	8d 50 01             	lea    0x1(%rax),%edx
 16a2f1b:	89 43 20             	mov    %eax,0x20(%rbx)
 16a2f1e:	8b 45 48             	mov    0x48(%rbp),%eax
 16a2f21:	89 15 25 a6 64 02    	mov    %edx,0x264a625(%rip)        # 3ced54c <tree_node_counts@@Base+0x72c>
 16a2f27:	83 f8 ff             	cmp    $0xffffffff,%eax
 16a2f2a:	74 03                	je     16a2f2f <_Z9copy_nodeP9tree_node@@Base+0x10f>
 16a2f2c:	89 43 48             	mov    %eax,0x48(%rbx)
 16a2f2f:	0f b7 45 00          	movzwl 0x0(%rbp),%eax
 16a2f33:	8d 50 da             	lea    -0x26(%rax),%edx
 16a2f36:	66 f7 c2 fd ff       	test   $0xfffd,%dx
 16a2f3b:	75 77                	jne    16a2fb4 <_Z9copy_nodeP9tree_node@@Base+0x194>
 16a2f3d:	f6 45 44 04          	testb  $0x4,0x44(%rbp)
 16a2f41:	0f 85 29 01 00 00    	jne    16a3070 <_Z9copy_nodeP9tree_node@@Base+0x250>
 16a2f47:	66 83 f8 26          	cmp    $0x26,%ax
 16a2f4b:	0f 85 61 ff ff ff    	jne    16a2eb2 <_Z9copy_nodeP9tree_node@@Base+0x92>
 16a2f51:	80 63 42 bf          	andb   $0xbf,0x42(%rbx)
 16a2f55:	48 c7 83 88 00 00 00 	movq   $0x0,0x88(%rbx)
 16a2f5c:	00 00 00 00 
 16a2f60:	f6 85 91 00 00 00 10 	testb  $0x10,0x91(%rbp)
 16a2f67:	0f 84 45 ff ff ff    	je     16a2eb2 <_Z9copy_nodeP9tree_node@@Base+0x92>
 16a2f6d:	48 8b bd 88 00 00 00 	mov    0x88(%rbp),%rdi
 16a2f74:	48 85 ff             	test   %rdi,%rdi
 16a2f77:	74 34                	je     16a2fad <_Z9copy_nodeP9tree_node@@Base+0x18d>
 16a2f79:	e8 82 5f 77 ff       	call   e18f00 <_ZN11symtab_node17get_init_priorityEv@@Base>
 16a2f7e:	41 89 c4             	mov    %eax,%r12d
 16a2f81:	66 83 f8 ff          	cmp    $0xffff,%ax
 16a2f85:	0f 84 26 01 00 00    	je     16a30b1 <_Z9copy_nodeP9tree_node@@Base+0x291>
 16a2f8b:	48 89 df             	mov    %rbx,%rdi
 16a2f8e:	66 83 3b 26          	cmpw   $0x26,(%rbx)
 16a2f92:	0f 84 38 01 00 00    	je     16a30d0 <_Z9copy_nodeP9tree_node@@Base+0x2b0>
 16a2f98:	e8 d3 e7 77 ff       	call   e21770 <_ZN11cgraph_node10get_createEP9tree_node@@Base>
 16a2f9d:	48 89 c7             	mov    %rax,%rdi
 16a2fa0:	41 0f b7 f4          	movzwl %r12w,%esi
 16a2fa4:	e8 f7 9d 77 ff       	call   e1cda0 <_ZN11symtab_node17set_init_priorityEt@@Base>
 16a2fa9:	0f b7 45 00          	movzwl 0x0(%rbp),%eax
 16a2fad:	80 8b 91 00 00 00 10 	orb    $0x10,0x91(%rbx)
 16a2fb4:	66 83 f8 23          	cmp    $0x23,%ax
 16a2fb8:	0f 85 f4 fe ff ff    	jne    16a2eb2 <_Z9copy_nodeP9tree_node@@Base+0x92>
 16a2fbe:	48 c7 83 a0 00 00 00 	movq   $0x0,0xa0(%rbx)
 16a2fc5:	00 00 00 00 
 16a2fc9:	48 89 d8             	mov    %rbx,%rax
 16a2fcc:	48 c7 83 88 00 00 00 	movq   $0x0,0x88(%rbx)
 16a2fd3:	00 00 00 00 
 16a2fd7:	48 83 c4 18          	add    $0x18,%rsp
 16a2fdb:	5b                   	pop    %rbx
 16a2fdc:	5d                   	pop    %rbp
 16a2fdd:	41 5c                	pop    %r12
 16a2fdf:	41 5d                	pop    %r13
 16a2fe1:	c3                   	ret
 16a2fe2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 16a2fe8:	8b 05 5a a5 64 02    	mov    0x264a55a(%rip),%eax        # 3ced548 <tree_node_counts@@Base+0x728>
 16a2fee:	83 e8 01             	sub    $0x1,%eax
 16a2ff1:	89 05 51 a5 64 02    	mov    %eax,0x264a551(%rip)        # 3ced548 <tree_node_counts@@Base+0x728>
 16a2ff7:	89 43 20             	mov    %eax,0x20(%rbx)
 16a2ffa:	0f b7 45 00          	movzwl 0x0(%rbp),%eax
 16a2ffe:	8d 50 da             	lea    -0x26(%rax),%edx
 16a3001:	66 f7 c2 fd ff       	test   $0xfffd,%dx
 16a3006:	0f 84 31 ff ff ff    	je     16a2f3d <_Z9copy_nodeP9tree_node@@Base+0x11d>
 16a300c:	eb a6                	jmp    16a2fb4 <_Z9copy_nodeP9tree_node@@Base+0x194>
 16a300e:	66 90                	xchg   %ax,%ax
 16a3010:	31 d2                	xor    %edx,%edx
 16a3012:	31 f6                	xor    %esi,%esi
 16a3014:	b9 01 00 00 00       	mov    $0x1,%ecx
 16a3019:	bf 18 01 00 00       	mov    $0x118,%edi
 16a301e:	e8 8d 13 70 ff       	call   da43b0 <_Z18ggc_internal_allocmPFvPvEmm@@Base>
 16a3023:	48 8b 75 10          	mov    0x10(%rbp),%rsi
 16a3027:	ba 18 01 00 00       	mov    $0x118,%edx
 16a302c:	48 89 43 10          	mov    %rax,0x10(%rbx)
 16a3030:	48 89 c7             	mov    %rax,%rdi
 16a3033:	e8 d8 57 23 ff       	call   8d8810 <memcpy@plt>
 16a3038:	e9 75 fe ff ff       	jmp    16a2eb2 <_Z9copy_nodeP9tree_node@@Base+0x92>
 16a303d:	0f 1f 00             	nopl   (%rax)
 16a3040:	31 d2                	xor    %edx,%edx
 16a3042:	31 f6                	xor    %esi,%esi
 16a3044:	b9 01 00 00 00       	mov    $0x1,%ecx
 16a3049:	bf e8 05 00 00       	mov    $0x5e8,%edi
 16a304e:	e8 5d 13 70 ff       	call   da43b0 <_Z18ggc_internal_allocmPFvPvEmm@@Base>
 16a3053:	48 8b 75 08          	mov    0x8(%rbp),%rsi
 16a3057:	ba e8 05 00 00       	mov    $0x5e8,%edx
 16a305c:	48 89 43 08          	mov    %rax,0x8(%rbx)
 16a3060:	48 89 c7             	mov    %rax,%rdi
 16a3063:	e8 a8 57 23 ff       	call   8d8810 <memcpy@plt>
 16a3068:	e9 45 fe ff ff       	jmp    16a2eb2 <_Z9copy_nodeP9tree_node@@Base+0x92>
 16a306d:	0f 1f 00             	nopl   (%rax)
 16a3070:	8b 55 20             	mov    0x20(%rbp),%edx
 16a3073:	48 8b 3d 86 a4 64 02 	mov    0x264a486(%rip),%rdi        # 3ced500 <tree_node_counts@@Base+0x6e0>
 16a307a:	48 89 e6             	mov    %rsp,%rsi
 16a307d:	48 89 2c 24          	mov    %rbp,(%rsp)
 16a3081:	e8 fa f9 fe ff       	call   1692a80 <_Z39gt_pch_nx_hash_table_type_cache_hasher_Pv@@Base+0x3b0>
 16a3086:	48 8b 30             	mov    (%rax),%rsi
 16a3089:	48 85 f6             	test   %rsi,%rsi
 16a308c:	74 04                	je     16a3092 <_Z9copy_nodeP9tree_node@@Base+0x272>
 16a308e:	48 8b 76 08          	mov    0x8(%rsi),%rsi
 16a3092:	48 89 df             	mov    %rbx,%rdi
 16a3095:	e8 26 fd ff ff       	call   16a2dc0 <_Z22decl_value_expr_insertP9tree_nodeS0_@@Base>
 16a309a:	80 4b 44 04          	orb    $0x4,0x44(%rbx)
 16a309e:	0f b7 45 00          	movzwl 0x0(%rbp),%eax
 16a30a2:	66 83 f8 26          	cmp    $0x26,%ax
 16a30a6:	0f 84 a5 fe ff ff    	je     16a2f51 <_Z9copy_nodeP9tree_node@@Base+0x131>
 16a30ac:	e9 03 ff ff ff       	jmp    16a2fb4 <_Z9copy_nodeP9tree_node@@Base+0x194>
 16a30b1:	48 8b bb 88 00 00 00 	mov    0x88(%rbx),%rdi
 16a30b8:	48 85 ff             	test   %rdi,%rdi
 16a30bb:	0f 85 df fe ff ff    	jne    16a2fa0 <_Z9copy_nodeP9tree_node@@Base+0x180>
 16a30c1:	e9 e3 fe ff ff       	jmp    16a2fa9 <_Z9copy_nodeP9tree_node@@Base+0x189>
 16a30c6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 16a30cd:	00 00 00 
 16a30d0:	e8 cb 2e 06 00       	call   1705fa0 <_ZN12varpool_node10get_createEP9tree_node@@Base>
 16a30d5:	48 89 c7             	mov    %rax,%rdi
 16a30d8:	e9 c3 fe ff ff       	jmp    16a2fa0 <_Z9copy_nodeP9tree_node@@Base+0x180>

Disassembly of section .fini:
