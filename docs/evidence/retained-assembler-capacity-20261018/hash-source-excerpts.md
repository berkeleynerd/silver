# Selected GAS hash source excerpts

Literal LF numbering.

## gas/as.c:1366–1378

```text
1366: gas_init (void)
1367: {
1368:   symbol_begin ();
1369:   frag_init ();
1370:   subsegs_begin ();
1371:   read_begin ();
1372:   input_scrub_begin ();
1373:   expr_begin ();
1374:   eh_begin ();
1375:
1376:   macro_init ();
1377:
1378:   dwarf2_init ();
```

## gas/symbols.c:3132–3137

```text
3132: symbol_begin (void)
3133: {
3134:   symbol_lastP = NULL;
3135:   symbol_rootP = NULL;          /* In case we have 0 symbols (!!)  */
3136:   sy_hash = htab_create_alloc (1024, hash_symbol_entry, eq_symbol_entry,
3137:                                NULL, xcalloc, free);
```

## gas/hash.h:24–28

```text
24: struct string_tuple
25: {
26:   const char *key;
27:   intptr_t value;
28: };
```

## gas/hash.h:52–58

```text
52: static inline string_tuple_t *
53: string_tuple_alloc (htab_t table, const char *key, intptr_t value)
54: {
55:   string_tuple_t *tuple = table->alloc_f (1, sizeof (*tuple));
56:   tuple->key = key;
57:   tuple->value = value;
58:   return tuple;
```

## gas/hash.h:96–117

```text
96: static inline void **
97: str_hash_insert_int (htab_t table, const char *key, intptr_t value, int replace)
98: {
99:   string_tuple_t *elt = string_tuple_alloc (table, key, value);
100:   void **slot = htab_insert (table, elt, replace);
101:   if (slot && !replace && table->free_f)
102:     table->free_f (elt);
103:   return slot;
104: }
105:
106: static inline void **
107: str_hash_insert (htab_t table, const char *key, const void *value, int replace)
108: {
109:   return str_hash_insert_int (table, key, (intptr_t) value, replace);
110: }
111:
112: static inline htab_t
113: str_htab_create (void)
114: {
115:   return htab_create_alloc (16, hash_string_tuple, eq_string_tuple,
116:                             NULL, notes_calloc, NULL);
117: }
```

## gas/hash.c:47–63

```text
47: void **
48: htab_insert (htab_t htab, void *element, int replace)
49: {
50:   void **slot = htab_find_slot (htab, element, INSERT);
51:   if (*slot != NULL)
52:     {
53:       if (replace)
54:         {
55:           if (htab->del_f)
56:             (*htab->del_f) (*slot);
57:           *slot = element;
58:         }
59:       return slot;
60:     }
61:   *slot = element;
62:   return NULL;
63: }
```

## gas/macro.c:59–65

```text
59: void
60: macro_init (void)
61: {
62:   macro_hash = htab_create_alloc (16, hash_string_tuple, eq_string_tuple,
63:                                   macro_del_f, notes_calloc, NULL);
64:   macro_defined = 0;
65: }
```

## gas/read.c:335–520

```text
335: static const pseudo_typeS potable[] = {
336:   {"abort", s_abort, 0},
337:   {"align", s_align_ptwo, 0},
338:   {"altmacro", s_altmacro, 1},
339:   {"ascii", stringer, 8+0},
340:   {"asciz", stringer, 8+1},
341:   {"balign", s_align_bytes, 0},
342:   {"balignw", s_align_bytes, -2},
343:   {"balignl", s_align_bytes, -4},
344:   {"base64", s_base64, 0},
345: /* block  */
346: #ifdef HANDLE_BUNDLE
347:   {"bundle_align_mode", s_bundle_align_mode, 0},
348:   {"bundle_lock", s_bundle_lock, 0},
349:   {"bundle_unlock", s_bundle_unlock, 0},
350: #endif
351:   {"byte", cons, 1},
352:   {"comm", s_comm, 0},
353:   {"common", s_mri_common, 0},
354:   {"common.s", s_mri_common, 1},
355: #if defined (TE_PE) && defined (O_secrel)
356:   {"cv_scomp", s_cv_comp, 1},
357:   {"cv_ucomp", s_cv_comp, 0},
358: #endif
359:   {"data", s_data, 0},
360:   {"dc", cons, 2},
361:   {"dc.a", cons, 0},
362:   {"dc.b", cons, 1},
363:   {"dc.d", float_cons, 'd'},
364:   {"dc.l", cons, 4},
365:   {"dc.s", float_cons, 'f'},
366:   {"dc.w", cons, 2},
367:   {"dc.x", float_cons, 'x'},
368:   {"dcb", s_space, 2},
369:   {"dcb.b", s_space, 1},
370:   {"dcb.d", s_float_space, 'd'},
371:   {"dcb.l", s_space, 4},
372:   {"dcb.s", s_float_space, 'f'},
373:   {"dcb.w", s_space, 2},
374:   {"dcb.x", s_float_space, 'x'},
375:   {"ds", s_space, 2},
376:   {"ds.b", s_space, 1},
377:   {"ds.d", s_space, 8},
378:   {"ds.l", s_space, 4},
379:   {"ds.p", s_space, 'p'},
380:   {"ds.s", s_space, 4},
381:   {"ds.w", s_space, 2},
382:   {"ds.x", s_space, 'x'},
383:   {"debug", s_ignore, 0},
384: #ifdef S_SET_DESC
385:   {"desc", s_desc, 0},
386: #endif
387: /* dim  */
388:   {"double", float_cons, 'd'},
389: /* dsect  */
390:   {"eject", listing_eject, 0},  /* Formfeed listing.  */
391:   {"else", s_else, 0},
392:   {"elsec", s_else, 0},
393:   {"elseif", s_elseif, (int) O_ne},
394:   {"end", s_end, 0},
395:   {"endc", s_endif, 0},
396:   {"endfunc", s_func, 1},
397:   {"endif", s_endif, 0},
398:   {"endm", s_bad_end, 0},
399:   {"endr", s_bad_end, 1},
400: /* endef  */
401:   {"equ", s_set, 0},
402:   {"equiv", s_set, 1},
403:   {"eqv", s_set, -1},
404:   {"err", s_err, 0},
405:   {"errif", s_errwarn_if, 1},
406:   {"error", s_errwarn, 1},
407:   {"exitm", s_mexit, 0},
408: /* extend  */
409:   {"extern", s_ignore, 0},      /* We treat all undef as ext.  */
410:   {"fail", s_fail, 0},
411:   {"file", s_file, 0},
412:   {"fill", s_fill, 0},
413:   {"float", float_cons, 'f'},
414:   {"format", s_ignore, 0},
415:   {"func", s_func, 0},
416:   {"global", s_globl, 0},
417:   {"globl", s_globl, 0},
418:   {"hword", cons, 2},
419:   {"if", s_if, (int) O_ne},
420:   {"ifb", s_ifb, 1},
421:   {"ifc", s_ifc, 0},
422:   {"ifdef", s_ifdef, 0},
423:   {"ifeq", s_if, (int) O_eq},
424:   {"ifeqs", s_ifeqs, 0},
425:   {"ifge", s_if, (int) O_ge},
426:   {"ifgt", s_if, (int) O_gt},
427:   {"ifle", s_if, (int) O_le},
428:   {"iflt", s_if, (int) O_lt},
429:   {"ifnb", s_ifb, 0},
430:   {"ifnc", s_ifc, 1},
431:   {"ifndef", s_ifdef, 1},
432:   {"ifne", s_if, (int) O_ne},
433:   {"ifnes", s_ifeqs, 1},
434:   {"ifnotdef", s_ifdef, 1},
435:   {"incbin", s_incbin, 0},
436:   {"include", s_include, 0},
437:   {"int", cons, 4},
438:   {"irp", s_irp, 0},
439:   {"irep", s_irp, 0},
440:   {"irpc", s_irp, 1},
441:   {"irepc", s_irp, 1},
442:   {"lcomm", s_lcomm, 0},
443:   {"lflags", s_ignore, 0},      /* Listing flags.  */
444:   {"linefile", s_linefile, 0},
445:   {"linkonce", s_linkonce, 0},
446:   {"list", listing_list, 1},    /* Turn listing on.  */
447:   {"llen", listing_psize, 1},
448:   {"long", cons, 4},
449:   {"lsym", s_lsym, 0},
450:   {"macro", s_macro, 0},
451:   {"mexit", s_mexit, 0},
452:   {"mri", s_mri, 0},
453:   {".mri", s_mri, 0},   /* Special case so .mri works in MRI mode.  */
454:   {"name", s_ignore, 0},
455:   {"noaltmacro", s_altmacro, 0},
456:   {"noformat", s_ignore, 0},
457:   {"nolist", listing_list, 0},  /* Turn listing off.  */
458:   {"nopage", listing_nopage, 0},
459:   {"nop", s_nop, 0},
460:   {"nops", s_nops, 0},
461:   {"octa", cons, 16},
462:   {"offset", s_struct, 0},
463:   {"org", s_org, 0},
464:   {"p2align", s_align_ptwo, 0},
465:   {"p2alignw", s_align_ptwo, -2},
466:   {"p2alignl", s_align_ptwo, -4},
467:   {"page", listing_eject, 0},
468:   {"plen", listing_psize, 0},
469:   {"print", s_print, 0},
470:   {"psize", listing_psize, 0},  /* Set paper size.  */
471:   {"purgem", s_purgem, 0},
472:   {"quad", cons, 8},
473:   {"reloc", s_reloc, 0},
474:   {"rep", s_rept, 0},
475:   {"rept", s_rept, 1},
476:   {"rva", s_rva, 4},
477:   {"sbttl", listing_title, 1},  /* Subtitle of listing.  */
478: /* scl  */
479: /* sect  */
480:   {"set", s_set, 0},
481:   {"short", cons, 2},
482:   {"single", float_cons, 'f'},
483: /* size  */
484:   {"space", s_space, 0},
485:   {"skip", s_space, 0},
486:   {"sleb128", s_leb128, 1},
487:   {"spc", s_ignore, 0},
488:   {"stabd", s_stab, 'd'},
489:   {"stabn", s_stab, 'n'},
490:   {"stabs", s_stab, 's'},
491:   {"string", stringer, 8+1},
492:   {"string8", stringer, 8+1},
493:   {"string16", stringer, 16+1},
494:   {"string32", stringer, 32+1},
495:   {"string64", stringer, 64+1},
496:   {"struct", s_struct, 0},
497: /* tag  */
498:   {"text", s_text, 0},
499:
500:   /* This is for gcc to use.  It's only just been added (2/94), so gcc
501:      won't be able to use it for a while -- probably a year or more.
502:      But once this has been released, check with gcc maintainers
503:      before deleting it or even changing the spelling.  */
504:   {"this_GCC_requires_the_GNU_assembler", s_ignore, 0},
505:   /* If we're folding case -- done for some targets, not necessarily
506:      all -- the above string in an input file will be converted to
507:      this one.  Match it either way...  */
508:   {"this_gcc_requires_the_gnu_assembler", s_ignore, 0},
509:
510:   {"title", listing_title, 0},  /* Listing title.  */
511:   {"ttl", listing_title, 0},
512: /* type  */
513:   {"uleb128", s_leb128, 0},
514: /* use  */
515: /* val  */
516:   {"xcom", s_comm, 0},
517:   {"xdef", s_globl, 0},
518:   {"xref", s_ignore, 0},
519:   {"xstabs", s_xstab, 's'},
520:   {"warnif", s_errwarn_if, 0},
```

## gas/read.c:556–615

```text
556: void
557: pop_insert (const pseudo_typeS *table)
558: {
559:   const pseudo_typeS *pop;
560:   for (pop = table; pop->poc_name; pop++)
561:     {
562:       if (str_hash_insert (po_hash, pop->poc_name, pop, 0) != NULL)
563:         {
564:           if (!pop_override_ok)
565:             as_fatal (_("error constructing %s pseudo-op table"),
566:                       pop_table_name);
567:         }
568:     }
569: }
570:
571: #ifndef md_pop_insert
572: #define md_pop_insert()         pop_insert(md_pseudo_table)
573: #endif
574:
575: #ifndef obj_pop_insert
576: #define obj_pop_insert()        pop_insert(obj_pseudo_table)
577: #endif
578:
579: #ifndef cfi_pop_insert
580: #define cfi_pop_insert()        pop_insert(cfi_pseudo_table)
581: #endif
582:
583: #ifndef scfi_pop_insert
584: #define scfi_pop_insert()       pop_insert(scfi_pseudo_table)
585: #endif
586:
587: static void
588: pobegin (void)
589: {
590:   po_hash = str_htab_create ();
591:
592:   /* Do the target-specific pseudo ops.  */
593:   pop_table_name = "md";
594:   pop_override_ok = 0;
595:   md_pop_insert ();
596:
597:   /* Now object specific.  Skip any that were in the target table.  */
598:   pop_table_name = "obj";
599:   pop_override_ok = 1;
600:   obj_pop_insert ();
601:
602:   /* Now portable ones.  Skip any that we've seen already.  */
603:   pop_table_name = "standard";
604:   pop_insert (potable);
605:
606:   /* Now CFI ones.  */
607: #if defined (TARGET_USE_SCFI) && defined (TARGET_USE_GINSN)
608:   if (flag_synth_cfi)
609:     {
610:       pop_table_name = "scfi";
611:       scfi_pop_insert ();
612:     }
613:   else
614: #endif
615:     {
```

## gas/config/tc-i386.c:1310–1361

```text
1310: const pseudo_typeS md_pseudo_table[] =
1311: {
1312: #if !defined(OBJ_AOUT) && !defined(USE_ALIGN_PTWO)
1313:   {"align", s_align_bytes, 0},
1314: #else
1315:   {"align", s_align_ptwo, 0},
1316: #endif
1317:   {"arch", set_cpu_arch, 0},
1318: #ifdef OBJ_AOUT
1319:   {"bss", s_bss, 0},
1320: #endif
1321: #ifdef I386COFF
1322:   {"lcomm", pe_lcomm, 1},
1323: #endif
1324:   {"ffloat", float_cons, 'f'},
1325:   {"dfloat", float_cons, 'd'},
1326:   {"tfloat", float_cons, 'x'},
1327:   {"hfloat", float_cons, 'h'},
1328:   {"bfloat16", float_cons, 'b'},
1329:   {"value", cons, 2},
1330:   {"slong", signed_cons, 4},
1331:   {"insn", s_insn, 0},
1332:   {"noopt", s_noopt, 0},
1333:   {"optim", s_ignore, 0},
1334:   {"code16gcc", set_16bit_gcc_code_flag, CODE_16BIT},
1335:   {"code16", set_code_flag, CODE_16BIT},
1336:   {"code32", set_code_flag, CODE_32BIT},
1337: #ifdef BFD64
1338:   {"code64", set_code_flag, CODE_64BIT},
1339: #endif
1340:   {"intel_syntax", set_intel_syntax, 1},
1341:   {"att_syntax", set_intel_syntax, 0},
1342:   {"intel_mnemonic", set_intel_mnemonic, 1},
1343:   {"att_mnemonic", set_intel_mnemonic, 0},
1344:   {"allow_index_reg", set_allow_index_reg, 1},
1345:   {"disallow_index_reg", set_allow_index_reg, 0},
1346:   {"sse_check", set_check, 0},
1347:   {"operand_check", set_check, 1},
1348: #ifdef OBJ_ELF
1349:   {"largecomm", handle_large_common, 0},
1350: #else
1351:   {"file", dwarf2_directive_file, 0},
1352:   {"loc", dwarf2_directive_loc, 0},
1353:   {"loc_mark_labels", dwarf2_directive_loc_mark_labels, 0},
1354: #endif
1355: #ifdef TE_PE
1356:   {"secrel32", pe_directive_secrel, 0},
1357:   {"secidx", pe_directive_secidx, 0},
1358: #endif
1359:   {0, 0, 0}
1360: };
1361:
```

## gas/config/tc-i386.c:3643–3704

```text
3643: void
3644: md_begin (void)
3645: {
3646:   /* Make sure possible padding space is clear.  */
3647:   memset (&pp, 0, sizeof (pp));
3648:
3649:   /* Initialize op_hash hash table.  */
3650:   op_hash = str_htab_create ();
3651:
3652:   {
3653:     const i386_op_off_t *cur = i386_op_sets;
3654:     const i386_op_off_t *end = cur + ARRAY_SIZE (i386_op_sets) - 1;
3655:
3656:     for (; cur < end; ++cur)
3657:       if (str_hash_insert (op_hash, insn_name (&i386_optab[*cur]), cur, 0))
3658:         as_fatal (_("duplicate %s"), insn_name (&i386_optab[*cur]));
3659:   }
3660:
3661:   /* Initialize reg_hash hash table.  */
3662:   reg_hash = str_htab_create ();
3663:   {
3664:     const reg_entry *regtab;
3665:     unsigned int regtab_size = i386_regtab_size;
3666:
3667:     for (regtab = i386_regtab; regtab_size--; regtab++)
3668:       {
3669:         switch (regtab->reg_type.bitfield.class)
3670:           {
3671:           case Reg:
3672:             if (regtab->reg_type.bitfield.dword)
3673:               {
3674:                 if (regtab->reg_type.bitfield.instance == Accum)
3675:                   reg_eax = regtab;
3676:               }
3677:             break;
3678:
3679:           case RegFP:
3680:             /* There's no point inserting st(<N>) in the hash table, as
3681:                parentheses aren't included in register_chars[] anyway.  */
3682:             if (regtab->reg_type.bitfield.instance != Accum)
3683:               continue;
3684:             reg_st0 = regtab;
3685:             break;
3686:
3687:           case SReg:
3688:             switch (regtab->reg_num)
3689:               {
3690:               case 0: reg_es = regtab; break;
3691:               case 2: reg_ss = regtab; break;
3692:               case 3: reg_ds = regtab; break;
3693:               }
3694:             break;
3695:
3696:           case RegMask:
3697:             if (!regtab->reg_num)
3698:               reg_k0 = regtab;
3699:             break;
3700:           }
3701:
3702:         if (str_hash_insert (reg_hash, regtab->reg_name, regtab, 0) != NULL)
3703:           as_fatal (_("duplicate %s"), regtab->reg_name);
3704:       }
```

## gas/config/obj-elf.c:73–200

```text
73: static void obj_elf_popsection (int);
74: static void obj_elf_tls_common (int);
75: static void obj_elf_lcomm (int);
76: static void obj_elf_struct (int);
77: static void obj_elf_attach_to_group (int);
78:
79: static const pseudo_typeS elf_pseudo_table[] =
80: {
81:   {"attach_to_group", obj_elf_attach_to_group, 0},
82:   {"comm", obj_elf_common, 0},
83:   {"common", obj_elf_common, 1},
84:   {"ident", obj_elf_ident, 0},
85:   {"lcomm", obj_elf_lcomm, 0},
86:   {"local", obj_elf_local, 0},
87:   {"previous", obj_elf_previous, 0},
88:   {"section", obj_elf_section, 0},
89:   {"section.s", obj_elf_section, 0},
90:   {"sect", obj_elf_section, 0},
91:   {"sect.s", obj_elf_section, 0},
92:   {"pushsection", obj_elf_section, 1},
93:   {"popsection", obj_elf_popsection, 0},
94:   {"size", obj_elf_size, 0},
95:   {"type", obj_elf_type, 0},
96:   {"version", obj_elf_version, 0},
97:   {"weak", obj_elf_weak, 0},
98:
99:   /* These define symbol visibility.  */
100:   {"internal", obj_elf_visibility, STV_INTERNAL},
101:   {"hidden", obj_elf_visibility, STV_HIDDEN},
102:   {"protected", obj_elf_visibility, STV_PROTECTED},
103:
104:   /* These are used for stabs-in-elf configurations.  */
105:   {"line", obj_elf_line, 0},
106:
107:   /* This is a GNU extension to handle symbol versions.  */
108:   {"symver", obj_elf_symver, 0},
109:
110:   /* A GNU extension to change subsection only.  */
111:   {"subsection", obj_elf_subsection, 0},
112:
113:   /* These are GNU extensions to aid in garbage collecting C++ vtables.  */
114:   {"vtable_inherit", obj_elf_vtable_inherit, 0},
115:   {"vtable_entry", obj_elf_vtable_entry, 0},
116:
117:   /* A GNU extension for object attributes.  */
118: #ifdef TC_OBJ_ATTR
119:   {"gnu_attribute", obj_elf_gnu_attribute, 0},
120: #if TC_OBJ_ATTR_v2
121:   {"gnu_subsection", obj_elf_gnu_subsection, 0},
122: #endif /* TC_OBJ_ATTR_v2 */
123: #endif /* TC_OBJ_ATTR */
124:
125:   /* These are used for dwarf2.  */
126:   { "file", dwarf2_directive_file, 0 },
127:   { "loc",  dwarf2_directive_loc,  0 },
128:   { "loc_mark_labels", dwarf2_directive_loc_mark_labels, 0 },
129:
130:   /* We need to trap the section changing calls to handle .previous.  */
131:   {"data", obj_elf_data, 0},
132:   {"offset", obj_elf_struct, 0},
133:   {"struct", obj_elf_struct, 0},
134:   {"text", obj_elf_text, 0},
135:   {"bss", obj_elf_bss, 0},
136:
137:   {"tls_common", obj_elf_tls_common, 0},
138:
139:   /* End sentinel.  */
140:   {NULL, NULL, 0},
141: };
142:
143: static const pseudo_typeS ecoff_debug_pseudo_table[] =
144: {
145: #ifdef NEED_ECOFF_DEBUG
146:   /* COFF style debugging information for ECOFF. .ln is not used; .loc
147:      is used instead.  */
148:   { "def",      ecoff_directive_def,    0 },
149:   { "dim",      ecoff_directive_dim,    0 },
150:   { "endef",    ecoff_directive_endef,  0 },
151:   { "file",     ecoff_directive_file,   0 },
152:   { "scl",      ecoff_directive_scl,    0 },
153:   { "tag",      ecoff_directive_tag,    0 },
154:   { "val",      ecoff_directive_val,    0 },
155:
156:   /* COFF debugging requires pseudo-ops .size and .type, but ELF
157:      already has meanings for those.  We use .esize and .etype
158:      instead.  These are only generated by gcc anyhow.  */
159:   { "esize",    ecoff_directive_size,   0 },
160:   { "etype",    ecoff_directive_type,   0 },
161:
162:   /* ECOFF specific debugging information.  */
163:   { "aent",     ecoff_directive_ent,    1 },
164:   { "begin",    ecoff_directive_begin,  0 },
165:   { "bend",     ecoff_directive_bend,   0 },
166:   { "end",      ecoff_directive_end,    0 },
167:   { "ent",      ecoff_directive_ent,    0 },
168:   { "fmask",    ecoff_directive_fmask,  0 },
169:   { "frame",    ecoff_directive_frame,  0 },
170:   { "loc",      ecoff_directive_loc,    0 },
171:   { "mask",     ecoff_directive_mask,   0 },
172:
173:   /* Other ECOFF directives.  */
174:   { "extern",   ecoff_directive_extern, 0 },
175:
176:   /* These are used on Irix.  I don't know how to implement them.  */
177:   { "alias",    s_ignore,               0 },
178:   { "bgnb",     s_ignore,               0 },
179:   { "endb",     s_ignore,               0 },
180:   { "lab",      s_ignore,               0 },
181:   { "noalias",  s_ignore,               0 },
182:   { "verstamp", s_ignore,               0 },
183:   { "vreg",     s_ignore,               0 },
184: #endif
185:
186:   {NULL, NULL, 0}                       /* end sentinel */
187: };
188:
189: #undef NO_RELOC
190: #include "aout/aout64.h"
191:
192: asection *elf_com_section_ptr;
193:
194: void
195: elf_pop_insert (void)
196: {
197:   pop_insert (elf_pseudo_table);
198:   if (ECOFF_DEBUGGING)
199:     pop_insert (ecoff_debug_pseudo_table);
200: }
```

## gas/dw2gencfi.c:699–731

```text
699: const pseudo_typeS cfi_pseudo_table[] =
700:   {
701:     { "cfi_sections", dot_cfi_sections, 0 },
702:     { "cfi_startproc", dot_cfi_startproc, 0 },
703:     { "cfi_endproc", dot_cfi_endproc, 0 },
704:     { "cfi_fde_data", dot_cfi_fde_data, 0 },
705:     { "cfi_def_cfa", dot_cfi, DW_CFA_def_cfa },
706:     { "cfi_def_cfa_register", dot_cfi, DW_CFA_def_cfa_register },
707:     { "cfi_def_cfa_offset", dot_cfi, DW_CFA_def_cfa_offset },
708:     { "cfi_adjust_cfa_offset", dot_cfi, CFI_adjust_cfa_offset },
709:     { "cfi_offset", dot_cfi, DW_CFA_offset },
710:     { "cfi_rel_offset", dot_cfi, CFI_rel_offset },
711:     { "cfi_register", dot_cfi, DW_CFA_register },
712:     { "cfi_return_column", dot_cfi, CFI_return_column },
713:     { "cfi_restore", dot_cfi, DW_CFA_restore },
714:     { "cfi_undefined", dot_cfi, DW_CFA_undefined },
715:     { "cfi_same_value", dot_cfi, DW_CFA_same_value },
716:     { "cfi_remember_state", dot_cfi, DW_CFA_remember_state },
717:     { "cfi_restore_state", dot_cfi, DW_CFA_restore_state },
718:     { "cfi_window_save", dot_cfi, DW_CFA_GNU_window_save },
719:     { "cfi_negate_ra_state", dot_cfi, DW_CFA_AARCH64_negate_ra_state },
720:     { "cfi_negate_ra_state_with_pc", dot_cfi, DW_CFA_AARCH64_negate_ra_state_with_pc },
721:     { "cfi_escape", dot_cfi_escape, 0 },
722:     { "cfi_signal_frame", dot_cfi, CFI_signal_frame },
723:     { "cfi_personality", dot_cfi_personality, 0 },
724:     { "cfi_personality_id", dot_cfi_personality_id, 0 },
725:     { "cfi_lsda", dot_cfi_lsda, 0 },
726:     { "cfi_val_encoded_addr", dot_cfi_val_encoded_addr, 0 },
727:     { "cfi_inline_lsda", dot_cfi_inline_lsda, 0 },
728:     { "cfi_label", dot_cfi_label, 0 },
729:     { "cfi_val_offset", dot_cfi, DW_CFA_val_offset },
730:     { NULL, NULL, 0 }
731:   };
```

## gas/dw2gencfi.c:2723–2755

```text
2723: const pseudo_typeS cfi_pseudo_table[] =
2724:   {
2725:     { "cfi_sections", dot_cfi_dummy, 0 },
2726:     { "cfi_startproc", dot_cfi_dummy, 0 },
2727:     { "cfi_endproc", dot_cfi_dummy, 0 },
2728:     { "cfi_fde_data", dot_cfi_dummy, 0 },
2729:     { "cfi_def_cfa", dot_cfi_dummy, 0 },
2730:     { "cfi_def_cfa_register", dot_cfi_dummy, 0 },
2731:     { "cfi_def_cfa_offset", dot_cfi_dummy, 0 },
2732:     { "cfi_adjust_cfa_offset", dot_cfi_dummy, 0 },
2733:     { "cfi_offset", dot_cfi_dummy, 0 },
2734:     { "cfi_rel_offset", dot_cfi_dummy, 0 },
2735:     { "cfi_register", dot_cfi_dummy, 0 },
2736:     { "cfi_return_column", dot_cfi_dummy, 0 },
2737:     { "cfi_restore", dot_cfi_dummy, 0 },
2738:     { "cfi_undefined", dot_cfi_dummy, 0 },
2739:     { "cfi_same_value", dot_cfi_dummy, 0 },
2740:     { "cfi_remember_state", dot_cfi_dummy, 0 },
2741:     { "cfi_restore_state", dot_cfi_dummy, 0 },
2742:     { "cfi_window_save", dot_cfi_dummy, 0 },
2743:     { "cfi_negate_ra_state", dot_cfi_dummy, 0 },
2744:     { "cfi_negate_ra_state_with_pc", dot_cfi_dummy, 0 },
2745:     { "cfi_escape", dot_cfi_dummy, 0 },
2746:     { "cfi_signal_frame", dot_cfi_dummy, 0 },
2747:     { "cfi_personality", dot_cfi_dummy, 0 },
2748:     { "cfi_personality_id", dot_cfi_dummy, 0 },
2749:     { "cfi_lsda", dot_cfi_dummy, 0 },
2750:     { "cfi_val_encoded_addr", dot_cfi_dummy, 0 },
2751:     { "cfi_inline_lsda", dot_cfi_dummy, 0 },
2752:     { "cfi_label", dot_cfi_dummy, 0 },
2753:     { "cfi_val_offset", dot_cfi_dummy, 0 },
2754:     { NULL, NULL, 0 }
2755:   };
```

## opcodes/i386-tbl.h:47951–48282

```text
47951: typedef unsigned short i386_op_off_t;
47952: static const i386_op_off_t i386_op_sets[] =
47953: {
47954:      0,   14,   16,   18,   19,   20,   21,   22,
47955:     24,   27,   28,   29,   30,   40,   41,   42,
47956:     48,   49,   50,   52,   56,   60,   61,   62,
47957:     63,   65,   67,   69,   70,   71,   72,   73,
47958:     74,   76,   78,   80,   82,   83,   84,   85,
47959:     95,  105,  115,  125,  135,  145,  155,  157,
47960:    164,  167,  170,  173,  176,  179,  182,  185,
47961:    188,  191,  194,  197,  200,  203,  206,  209,
47962:    212,  215,  218,  221,  224,  227,  230,  233,
47963:    236,  239,  242,  245,  248,  253,  255,  257,
47964:    259,  261,  263,  265,  267,  269,  271,  273,
47965:    275,  277,  279,  281,  283,  285,  287,  289,
47966:    291,  293,  295,  297,  299,  301,  303,  305,
47967:    307,  309,  313,  317,  320,  323,  324,  325,
47968:    326,  327,  329,  331,  332,  333,  334,  335,
47969:    336,  337,  338,  339,  340,  341,  342,  343,
47970:    345,  358,  362,  366,  370,  380,  390,  400,
47971:    410,  420,  430,  440,  450,  457,  464,  473,
47972:    476,  484,  487,  489,  495,  497,  499,  501,
47973:    503,  504,  505,  506,  507,  508,  509,  510,
47974:    511,  512,  513,  514,  515,  516,  517,  518,
47975:    519,  520,  521,  522,  523,  524,  525,  526,
47976:    527,  528,  529,  530,  531,  532,  533,  534,
47977:    535,  536,  538,  540,  542,  544,  546,  549,
47978:    552,  555,  558,  561,  564,  567,  570,  573,
47979:    576,  579,  582,  585,  588,  591,  594,  597,
47980:    600,  603,  606,  609,  612,  615,  618,  621,
47981:    624,  627,  630,  633,  636,  637,  638,  639,
47982:    640,  641,  642,  643,  644,  645,  646,  647,
47983:    648,  649,  650,  651,  652,  653,  654,  655,
47984:    656,  657,  658,  659,  660,  661,  662,  663,
47985:    664,  665,  666,  667,  669,  671,  673,  675,
47986:    678,  681,  683,  685,  688,  691,  694,  697,
47987:    699,  700,  701,  703,  705,  707,  709,  710,
47988:    711,  712,  713,  714,  715,  716,  717,  719,
47989:    721,  723,  725,  727,  729,  730,  732,  734,
47990:    736,  738,  740,  742,  744,  746,  748,  752,
47991:    754,  755,  756,  757,  760,  761,  765,  767,
47992:    768,  769,  770,  772,  776,  777,  781,  782,
47993:    783,  785,  787,  788,  789,  790,  791,  792,
47994:    793,  794,  795,  796,  797,  801,  802,  805,
47995:    809,  810,  816,  820,  821,  827,  831,  832,
47996:    835,  839,  840,  846,  850,  851,  857,  858,
47997:    859,  860,  861,  862,  863,  864,  865,  866,
47998:    867,  868,  869,  870,  871,  872,  873,  874,
47999:    875,  876,  877,  878,  879,  880,  883,  886,
48000:    887,  888,  889,  890,  891,  892,  893,  894,
48001:    895,  896,  897,  898,  899,  900,  901,  902,
48002:    903,  904,  905,  906,  907,  908,  909,  910,
48003:    911,  912,  913,  914,  915,  916,  917,  918,
48004:    919,  920,  921,  922,  923,  924,  925,  926,
48005:    927,  928,  929,  930,  931,  932,  933,  934,
48006:    935,  936,  937,  938,  939,  940,  941,  942,
48007:    943,  944,  945,  946,  947,  948,  949,  950,
48008:    951,  952,  953,  954,  955,  956,  957,  958,
48009:    959,  960,  961,  962,  963,  964,  965,  966,
48010:    967,  968,  969,  970,  971,  972,  973,  974,
48011:    975,  976,  977,  978,  979,  980,  981,  983,
48012:    984,  986,  988,  989,  990,  991,  992,  993,
48013:    994,  995,  997,  999, 1001, 1002, 1004, 1006,
48014:   1008, 1010, 1012, 1014, 1016, 1018, 1020, 1022,
48015:   1024, 1026, 1028, 1030, 1032, 1034, 1036, 1038,
48016:   1040, 1042, 1044, 1046, 1048, 1050, 1052, 1054,
48017:   1056, 1058, 1060, 1062, 1064, 1066, 1068, 1070,
48018:   1072, 1074, 1076, 1078, 1080, 1082, 1084, 1086,
48019:   1088, 1090, 1092, 1094, 1096, 1098, 1100, 1102,
48020:   1104, 1106, 1108, 1110, 1112, 1114, 1116, 1118,
48021:   1120, 1122, 1123, 1124, 1125, 1126, 1127, 1128,
48022:   1129, 1130, 1131, 1132, 1133, 1134, 1137, 1140,
48023:   1143, 1146, 1149, 1152, 1153, 1154, 1155, 1156,
48024:   1157, 1158, 1164, 1174, 1178, 1182, 1186, 1190,
48025:   1194, 1197, 1201, 1205, 1209, 1213, 1217, 1220,
48026:   1223, 1226, 1229, 1232, 1235, 1238, 1241, 1245,
48027:   1249, 1253, 1256, 1264, 1270, 1278, 1286, 1292,
48028:   1300, 1306, 1314, 1318, 1322, 1325, 1329, 1333,
48029:   1337, 1341, 1345, 1349, 1353, 1356, 1360, 1364,
48030:   1367, 1370, 1372, 1374, 1376, 1378, 1380, 1382,
48031:   1384, 1386, 1388, 1390, 1392, 1394, 1397, 1400,
48032:   1403, 1406, 1408, 1410, 1412, 1414, 1416, 1418,
48033:   1420, 1422, 1424, 1426, 1428, 1430, 1432, 1434,
48034:   1436, 1438, 1440, 1442, 1444, 1445, 1446, 1452,
48035:   1454, 1455, 1457, 1459, 1460, 1462, 1464, 1467,
48036:   1469, 1472, 1474, 1476, 1477, 1479, 1482, 1484,
48037:   1488, 1492, 1501, 1507, 1511, 1515, 1519, 1523,
48038:   1526, 1530, 1531, 1532, 1533, 1534, 1538, 1539,
48039:   1542, 1545, 1548, 1551, 1552, 1554, 1556, 1558,
48040:   1560, 1562, 1564, 1566, 1569, 1572, 1575, 1578,
48041:   1581, 1584, 1587, 1590, 1593, 1596, 1599, 1602,
48042:   1605, 1608, 1611, 1614, 1616, 1618, 1620, 1622,
48043:   1624, 1626, 1628, 1630, 1632, 1634, 1636, 1638,
48044:   1640, 1642, 1644, 1646, 1648, 1650, 1653, 1656,
48045:   1662, 1665, 1670, 1675, 1677, 1680, 1685, 1688,
48046:   1691, 1694, 1697, 1700, 1703, 1706, 1708, 1711,
48047:   1713, 1714, 1717, 1719, 1721, 1723, 1726, 1728,
48048:   1729, 1731, 1734, 1736, 1738, 1740, 1742, 1743,
48049:   1744, 1748, 1750, 1753, 1756, 1759, 1762, 1765,
48050:   1768, 1770, 1772, 1774, 1776, 1778, 1780, 1783,
48051:   1786, 1788, 1790, 1792, 1793, 1794, 1797, 1799,
48052:   1800, 1801, 1802, 1803, 1804, 1805, 1807, 1809,
48053:   1810, 1811, 1812, 1813, 1816, 1819, 1822, 1825,
48054:   1828, 1831, 1834, 1837, 1840, 1844, 1848, 1852,
48055:   1855, 1858, 1861, 1865, 1869, 1873, 1876, 1878,
48056:   1880, 1884, 1888, 1890, 1892, 1896, 1898, 1900,
48057:   1902, 1905, 1909, 1911, 1913, 1919, 1922, 1925,
48058:   1927, 1933, 1936, 1939, 1942, 1944, 1946, 1949,
48059:   1952, 1954, 1956, 1959, 1962, 1965, 1967, 1969,
48060:   1971, 1973, 1975, 1977, 1979, 1981, 1983, 1985,
48061:   1988, 1990, 1992, 1995, 1997, 2000, 2002, 2004,
48062:   2008, 2012, 2014, 2016, 2020, 2021, 2022, 2023,
48063:   2024, 2025, 2026, 2027, 2028, 2030, 2032, 2034,
48064:   2036, 2038, 2040, 2042, 2044, 2046, 2048, 2050,
48065:   2052, 2054, 2056, 2058, 2060, 2062, 2064, 2066,
48066:   2068, 2070, 2072, 2074, 2076, 2078, 2080, 2082,
48067:   2084, 2086, 2088, 2090, 2092, 2094, 2096, 2098,
48068:   2100, 2102, 2104, 2105, 2106, 2108, 2110, 2112,
48069:   2114, 2116, 2118, 2120, 2122, 2123, 2124, 2125,
48070:   2126, 2127, 2130, 2132, 2134, 2136, 2138, 2140,
48071:   2142, 2144, 2146, 2148, 2150, 2152, 2154, 2156,
48072:   2158, 2160, 2162, 2164, 2166, 2168, 2170, 2172,
48073:   2174, 2176, 2178, 2180, 2182, 2184, 2186, 2188,
48074:   2190, 2192, 2194, 2196, 2198, 2200, 2202, 2204,
48075:   2206, 2208, 2210, 2212, 2214, 2216, 2218, 2220,
48076:   2222, 2224, 2226, 2228, 2230, 2232, 2234, 2236,
48077:   2238, 2240, 2242, 2244, 2246, 2248, 2250, 2252,
48078:   2254, 2256, 2258, 2260, 2262, 2264, 2266, 2268,
48079:   2270, 2272, 2274, 2276, 2278, 2280, 2282, 2284,
48080:   2286, 2288, 2290, 2292, 2294, 2296, 2298, 2300,
48081:   2302, 2304, 2306, 2308, 2310, 2312, 2314, 2316,
48082:   2318, 2320, 2322, 2324, 2326, 2328, 2330, 2332,
48083:   2334, 2336, 2338, 2340, 2342, 2344, 2346, 2348,
48084:   2350, 2352, 2354, 2356, 2358, 2360, 2362, 2364,
48085:   2366, 2368, 2370, 2372, 2374, 2376, 2378, 2380,
48086:   2382, 2384, 2386, 2388, 2390, 2392, 2394, 2396,
48087:   2398, 2400, 2402, 2404, 2406, 2408, 2410, 2412,
48088:   2414, 2416, 2418, 2420, 2422, 2424, 2426, 2428,
48089:   2430, 2432, 2434, 2436, 2438, 2440, 2442, 2444,
48090:   2446, 2448, 2450, 2452, 2454, 2456, 2458, 2460,
48091:   2462, 2464, 2466, 2468, 2470, 2472, 2474, 2476,
48092:   2478, 2480, 2482, 2484, 2486, 2488, 2490, 2492,
48093:   2494, 2496, 2498, 2500, 2502, 2504, 2506, 2508,
48094:   2510, 2512, 2517, 2519, 2524, 2526, 2528, 2533,
48095:   2535, 2537, 2539, 2544, 2546, 2548, 2550, 2554,
48096:   2560, 2562, 2567, 2569, 2571, 2573, 2575, 2577,
48097:   2578, 2579, 2580, 2582, 2583, 2584, 2585, 2586,
48098:   2587, 2589, 2590, 2591, 2592, 2594, 2596, 2598,
48099:   2600, 2604, 2608, 2609, 2610, 2612, 2616, 2620,
48100:   2622, 2626, 2630, 2631, 2632, 2634, 2636, 2638,
48101:   2640, 2645, 2649, 2653, 2655, 2657, 2659, 2661,
48102:   2663, 2665, 2667, 2669, 2671, 2673, 2675, 2677,
48103:   2679, 2681, 2683, 2685, 2687, 2689, 2691, 2693,
48104:   2695, 2696, 2697, 2699, 2701, 2702, 2703, 2706,
48105:   2709, 2712, 2715, 2717, 2719, 2721, 2723, 2725,
48106:   2727, 2728, 2729, 2730, 2732, 2736, 2738, 2740,
48107:   2746, 2750, 2751, 2752, 2753, 2754, 2755, 2756,
48108:   2757, 2761, 2763, 2765, 2769, 2771, 2773, 2775,
48109:   2777, 2779, 2781, 2783, 2785, 2787, 2789, 2791,
48110:   2793, 2795, 2797, 2798, 2801, 2804, 2807, 2810,
48111:   2815, 2820, 2825, 2830, 2833, 2836, 2839, 2842,
48112:   2844, 2846, 2848, 2850, 2852, 2854, 2856, 2857,
48113:   2859, 2861, 2863, 2865, 2867, 2868, 2869, 2870,
48114:   2874, 2878, 2880, 2884, 2888, 2892, 2896, 2900,
48115:   2902, 2906, 2908, 2910, 2912, 2914, 2916, 2918,
48116:   2920, 2922, 2923, 2925, 2927, 2929, 2931, 2933,
48117:   2935, 2937, 2939, 2940, 2941, 2942, 2943, 2944,
48118:   2945, 2946, 2947, 2948, 2950, 2952, 2954, 2956,
48119:   2958, 2960, 2961, 2962, 2963, 2965, 2967, 2969,
48120:   2971, 2973, 2975, 2976, 2977, 2978, 2979, 2982,
48121:   2985, 2987, 2990, 2991, 2992, 2994, 2995, 2997,
48122:   2998, 2999, 3001, 3003, 3004, 3005, 3006, 3007,
48123:   3008, 3011, 3016, 3021, 3026, 3031, 3034, 3039,
48124:   3044, 3046, 3048, 3050, 3052, 3053, 3054, 3056,
48125:   3058, 3060, 3062, 3064, 3066, 3068, 3069, 3070,
48126:   3071, 3072, 3073, 3074, 3079, 3084, 3085, 3086,
48127:   3087, 3088, 3089, 3090, 3091, 3092, 3093, 3094,
48128:   3095, 3096, 3097, 3098, 3099, 3100, 3101, 3102,
48129:   3103, 3104, 3105, 3106, 3107, 3108, 3109, 3110,
48130:   3111, 3112, 3113, 3114, 3115, 3116, 3117, 3118,
48131:   3119, 3120, 3121, 3122, 3123, 3124, 3125, 3126,
48132:   3127, 3128, 3129, 3130, 3131, 3132, 3133, 3134,
48133:   3135, 3136, 3137, 3138, 3139, 3140, 3141, 3142,
48134:   3143, 3144, 3145, 3146, 3147, 3148, 3149, 3150,
48135:   3151, 3152, 3153, 3154, 3155, 3156, 3157, 3158,
48136:   3159, 3160, 3161, 3162, 3163, 3164, 3165, 3166,
48137:   3167, 3168, 3169, 3170, 3171, 3172, 3173, 3174,
48138:   3175, 3176, 3177, 3178, 3179, 3180, 3181, 3182,
48139:   3183, 3184, 3185, 3186, 3187, 3188, 3189, 3190,
48140:   3191, 3192, 3193, 3194, 3195, 3196, 3197, 3198,
48141:   3199, 3200, 3201, 3202, 3203, 3204, 3205, 3206,
48142:   3207, 3208, 3209, 3210, 3211, 3212, 3213, 3214,
48143:   3215, 3216, 3217, 3218, 3219, 3220, 3221, 3222,
48144:   3223, 3224, 3225, 3226, 3227, 3228, 3229, 3230,
48145:   3231, 3232, 3233, 3234, 3235, 3236, 3237, 3238,
48146:   3239, 3240, 3241, 3242, 3243, 3244, 3245, 3246,
48147:   3247, 3248, 3249, 3250, 3251, 3252, 3253, 3254,
48148:   3255, 3256, 3257, 3258, 3259, 3260, 3261, 3262,
48149:   3263, 3264, 3265, 3266, 3267, 3268, 3269, 3270,
48150:   3271, 3272, 3273, 3274, 3275, 3276, 3277, 3278,
48151:   3279, 3280, 3281, 3282, 3283, 3284, 3285, 3287,
48152:   3289, 3290, 3291, 3292, 3293, 3294, 3295, 3296,
48153:   3297, 3298, 3299, 3300, 3301, 3302, 3303, 3304,
48154:   3305, 3306, 3307, 3308, 3309, 3310, 3311, 3312,
48155:   3313, 3314, 3315, 3316, 3317, 3319, 3321, 3323,
48156:   3325, 3326, 3327, 3328, 3329, 3330, 3331, 3332,
48157:   3333, 3334, 3335, 3336, 3337, 3338, 3340, 3341,
48158:   3342, 3343, 3345, 3346, 3347, 3348, 3349, 3350,
48159:   3351, 3352, 3353, 3354, 3355, 3356, 3357, 3358,
48160:   3359, 3360, 3361, 3362, 3363, 3364, 3365, 3366,
48161:   3367, 3368, 3369, 3370, 3371, 3372, 3373, 3374,
48162:   3375, 3376, 3377, 3378, 3379, 3380, 3381, 3382,
48163:   3383, 3384, 3385, 3386, 3388, 3390, 3391, 3392,
48164:   3394, 3395, 3397, 3399, 3400, 3401, 3403, 3405,
48165:   3407, 3409, 3410, 3411, 3412, 3413, 3414, 3415,
48166:   3416, 3417, 3418, 3419, 3420, 3421, 3422, 3423,
48167:   3424, 3425, 3426, 3427, 3428, 3429, 3430, 3431,
48168:   3432, 3433, 3436, 3439, 3440, 3441, 3442, 3443,
48169:   3444, 3445, 3447, 3449, 3451, 3452, 3453, 3454,
48170:   3455, 3456, 3457, 3459, 3460, 3461, 3462, 3463,
48171:   3464, 3465, 3466, 3467, 3469, 3471, 3472, 3473,
48172:   3474, 3475, 3476, 3477, 3478, 3479, 3480, 3481,
48173:   3484, 3487, 3488, 3489, 3490, 3491, 3492, 3493,
48174:   3494, 3495, 3496, 3497, 3498, 3499, 3500, 3501,
48175:   3502, 3503, 3504, 3505, 3506, 3507, 3508, 3509,
48176:   3510, 3511, 3512, 3513, 3514, 3515, 3516, 3517,
48177:   3518, 3519, 3520, 3521, 3522, 3523, 3524, 3525,
48178:   3526, 3527, 3528, 3529, 3530, 3531, 3532, 3533,
48179:   3534, 3535, 3536, 3537, 3538, 3539, 3540, 3541,
48180:   3542, 3543, 3544, 3545, 3548, 3550, 3553, 3556,
48181:   3558, 3561, 3564, 3567, 3570, 3571, 3574, 3575,
48182:   3576, 3577, 3578, 3579, 3583, 3585, 3588, 3589,
48183:   3590, 3591, 3592, 3593, 3594, 3595, 3596, 3597,
48184:   3598, 3599, 3600, 3601, 3602, 3603, 3604, 3605,
48185:   3606, 3607, 3608, 3609, 3610, 3611, 3612, 3613,
48186:   3614, 3615, 3616, 3617, 3618, 3619, 3620, 3621,
48187:   3622, 3623, 3624, 3625, 3626, 3627, 3628, 3629,
48188:   3630, 3631, 3632, 3633, 3634, 3635, 3636, 3637,
48189:   3638, 3639, 3641, 3642, 3643, 3644, 3645, 3646,
48190:   3647, 3648, 3649, 3650, 3651, 3652, 3653, 3654,
48191:   3655, 3656, 3657, 3658, 3659, 3660, 3661, 3662,
48192:   3663, 3664, 3665, 3666, 3667, 3668, 3669, 3670,
48193:   3671, 3672, 3673, 3674, 3675, 3676, 3677, 3678,
48194:   3679, 3680, 3683, 3686, 3689, 3692, 3695, 3698,
48195:   3701, 3704, 3707, 3710, 3713, 3716, 3719, 3722,
48196:   3725, 3726, 3727, 3728, 3729, 3731, 3732, 3733,
48197:   3734, 3735, 3736, 3737, 3738, 3739, 3740, 3741,
48198:   3742, 3743, 3744, 3745, 3746, 3747, 3748, 3749,
48199:   3750, 3751, 3752, 3753, 3754, 3755, 3756, 3757,
48200:   3758, 3759, 3760, 3761, 3762, 3763, 3764, 3765,
48201:   3766, 3767, 3768, 3769, 3770, 3771, 3772, 3773,
48202:   3774, 3775, 3776, 3777, 3778, 3779, 3780, 3781,
48203:   3782, 3783, 3784, 3785, 3786, 3787, 3788, 3789,
48204:   3790, 3791, 3792, 3795, 3798, 3799, 3800, 3801,
48205:   3802, 3803, 3804, 3805, 3806, 3807, 3808, 3809,
48206:   3810, 3811, 3812, 3813, 3814, 3815, 3816, 3817,
48207:   3818, 3819, 3820, 3821, 3822, 3823, 3824, 3825,
48208:   3826, 3827, 3828, 3829, 3830, 3831, 3832, 3833,
48209:   3834, 3835, 3836, 3837, 3838, 3839, 3840, 3841,
48210:   3842, 3843, 3844, 3845, 3846, 3847, 3848, 3849,
48211:   3850, 3851, 3852, 3853, 3854, 3855, 3856, 3857,
48212:   3858, 3859, 3860, 3863, 3866, 3869, 3870, 3871,
48213:   3872, 3873, 3874, 3875, 3876, 3877, 3878, 3879,
48214:   3880, 3881, 3882, 3883, 3884, 3885, 3888, 3891,
48215:   3892, 3893, 3896, 3897, 3898, 3899, 3900, 3903,
48216:   3906, 3909, 3910, 3911, 3912, 3913, 3914, 3915,
48217:   3916, 3917, 3918, 3919, 3921, 3922, 3923, 3924,
48218:   3926, 3927, 3928, 3929, 3930, 3931, 3932, 3933,
48219:   3934, 3935, 3936, 3937, 3938, 3939, 3940, 3941,
48220:   3942, 3943, 3944, 3945, 3946, 3947, 3948, 3950,
48221:   3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959,
48222:   3960, 3961, 3962, 3963, 3964, 3965, 3966, 3967,
48223:   3968, 3969, 3970, 3971, 3972, 3973, 3974, 3975,
48224:   3976, 3977, 3979, 3981, 3983, 3985, 3987, 3989,
48225:   3991, 3993, 3995, 3997, 3999, 4001, 4003, 4005,
48226:   4007, 4009, 4010, 4011, 4012, 4014, 4015, 4017,
48227:   4020, 4022, 4023, 4024, 4026, 4028, 4029, 4030,
48228:   4031, 4032, 4033, 4034, 4036, 4038, 4040, 4042,
48229:   4043, 4044, 4045, 4046, 4047, 4048, 4049, 4050,
48230:   4051, 4053, 4055, 4056, 4058, 4060, 4061, 4066,
48231:   4068, 4070, 4071, 4072, 4073, 4074, 4075, 4076,
48232:   4077, 4078, 4079, 4080, 4082, 4084, 4085, 4086,
48233:   4087, 4089, 4092, 4096, 4099, 4101, 4102, 4103,
48234:   4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111,
48235:   4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119,
48236:   4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127,
48237:   4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135,
48238:   4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143,
48239:   4144, 4146, 4148, 4150, 4152, 4154, 4156, 4157,
48240:   4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165,
48241:   4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173,
48242:   4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181,
48243:   4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189,
48244:   4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197,
48245:   4198, 4199, 4200, 4201, 4202, 4203, 4204, 4205,
48246:   4206, 4207, 4208, 4209, 4210, 4211, 4212, 4213,
48247:   4214, 4215, 4216, 4217, 4218, 4219, 4220, 4221,
48248:   4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229,
48249:   4230, 4231, 4232, 4233, 4234, 4235, 4236, 4237,
48250:   4238, 4239, 4240, 4241, 4242, 4243, 4244, 4245,
48251:   4246, 4247, 4248, 4249, 4250, 4251, 4252, 4253,
48252:   4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261,
48253:   4262, 4263, 4264, 4265, 4266, 4267, 4268, 4269,
48254:   4270, 4271, 4272, 4273, 4274, 4275, 4276, 4277,
48255:   4278, 4279, 4282, 4283, 4284, 4287, 4288, 4289,
48256:   4291, 4292, 4293, 4294, 4296, 4297, 4298, 4299,
48257:   4301, 4302, 4303, 4304, 4307, 4308, 4309, 4310,
48258:   4311, 4314, 4317, 4320, 4323, 4326, 4327, 4328,
48259:   4329, 4330, 4332, 4334, 4335, 4336, 4337, 4340,
48260:   4343, 4346, 4349, 4352, 4353, 4354, 4355, 4357,
48261:   4358, 4359, 4360, 4363, 4364, 4365, 4366, 4367,
48262:   4368, 4369, 4370, 4371, 4372, 4373, 4374, 4375,
48263:   4376, 4377, 4378, 4379, 4380, 4381, 4382, 4383,
48264:   4384, 4385, 4386, 4387, 4388, 4389, 4390, 4391,
48265:   4392, 4393, 4394, 4395, 4396, 4397, 4398, 4399,
48266:   4401, 4402, 4403, 4405, 4407, 4409, 4411, 4413,
48267:   4414, 4415, 4418, 4421, 4422, 4423, 4424, 4425,
48268:   4426, 4427, 4429, 4431, 4433, 4435, 4436, 4437,
48269:   4438, 4439, 4442, 4443, 4444, 4447, 4448, 4449,
48270:   4452, 4453, 4454, 4457, 4458, 4459, 4462, 4463,
48271:   4464, 4465, 4466, 4467, 4468, 4469, 4470, 4471,
48272:   4472, 4473, 4474, 4475, 4476, 4477, 4478, 4479,
48273:   4480, 4481, 4482, 4483, 4484, 4485, 4486, 4487,
48274:   4488, 4489, 4490, 4491, 4492, 4493, 4494, 4495,
48275:   4496, 4497, 4498, 4499, 4500, 4501, 4502, 4503,
48276:   4504, 4505, 4506, 4509, 4510, 4511, 4514, 4515,
48277:   4516, 4517, 4518, 4519, 4520, 4523, 4526, 4527,
48278:   4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535,
48279:   4536, 4537, 4538, 4539, 4540, 4541, 4542, 4543,
48280:   4544, 4546, 4547, 4548, 4549, 4550
48281: };
48282:
```

## opcodes/i386-tbl.h:50514–50521

```text
50514: static const reg_entry i386_regtab[] =
50515: {
50516:   { "al",
50517:     { { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
50518:         0, 0, 0, 0, 0, 0 } },
50519:     0, 0, { Dw2Inval, Dw2Inval } },
50520:   { "cl",
50521:     { { 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
```

## opcodes/i386-tbl.h:51912–51926

```text
51912:   { "fcw",
51913:     { { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
51914:         0, 0, 0, 0, 0, 0 } },
51915:     0, 0, { 37, 65 } },
51916:   { "fsw",
51917:     { { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
51918:         0, 0, 0, 0, 0, 0 } },
51919:     0, 0, { 38, 66 } },
51920:   { "mxcsr",
51921:     { { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
51922:         0, 0, 0, 0, 0, 0 } },
51923:     0, 0, { 39, 64 } },
51924: };
51925:
51926: static const unsigned int i386_regtab_size = ARRAY_SIZE (i386_regtab);
```

## include/hashtab.h:96–141

```text
96:   /* Pointer to hash function.  */
97:   htab_hash hash_f;
98:
99:   /* Pointer to comparison function.  */
100:   htab_eq eq_f;
101:
102:   /* Pointer to cleanup function.  */
103:   htab_del del_f;
104:
105:   /* Table itself.  */
106:   void **entries;
107:
108:   /* Current size (in entries) of the hash table.  */
109:   size_t size;
110:
111:   /* Current number of elements including also deleted elements.  */
112:   size_t n_elements;
113:
114:   /* Current number of deleted elements in the table.  */
115:   size_t n_deleted;
116:
117:   /* The following member is used for debugging. Its value is number
118:      of all calls of `htab_find_slot' for the hash table. */
119:   unsigned int searches;
120:
121:   /* The following member is used for debugging.  Its value is number
122:      of collisions fixed for time of work with the hash table. */
123:   unsigned int collisions;
124:
125:   /* Pointers to allocate/free functions.  */
126:   htab_alloc alloc_f;
127:   htab_free free_f;
128:
129:   /* Alternate allocate/free functions, which take an extra argument.  */
130:   void *alloc_arg;
131:   htab_alloc_with_arg alloc_with_arg_f;
132:   htab_free_with_arg free_with_arg_f;
133:
134:   /* Current size (in entries) of the hash table, as an index into the
135:      table of primes.  */
136:   unsigned int size_prime_index;
137: };
138:
139: typedef struct htab *htab_t;
140:
141: /* An enum saying whether we insert into the hash table or not.  */
```

## libiberty/hashtab.c:134–193

```text
134: static struct prime_ent const prime_tab[] = {
135:   {          7, 0x24924925, 0x9999999b, 2 },
136:   {         13, 0x3b13b13c, 0x745d1747, 3 },
137:   {         31, 0x08421085, 0x1a7b9612, 4 },
138:   {         61, 0x0c9714fc, 0x15b1e5f8, 5 },
139:   {        127, 0x02040811, 0x0624dd30, 6 },
140:   {        251, 0x05197f7e, 0x073260a5, 7 },
141:   {        509, 0x01824366, 0x02864fc8, 8 },
142:   {       1021, 0x00c0906d, 0x014191f7, 9 },
143:   {       2039, 0x0121456f, 0x0161e69e, 10 },
144:   {       4093, 0x00300902, 0x00501908, 11 },
145:   {       8191, 0x00080041, 0x00180241, 12 },
146:   {      16381, 0x000c0091, 0x00140191, 13 },
147:   {      32749, 0x002605a5, 0x002a06e6, 14 },
148:   {      65521, 0x000f00e2, 0x00110122, 15 },
149:   {     131071, 0x00008001, 0x00018003, 16 },
150:   {     262139, 0x00014002, 0x0001c004, 17 },
151:   {     524287, 0x00002001, 0x00006001, 18 },
152:   {    1048573, 0x00003001, 0x00005001, 19 },
153:   {    2097143, 0x00004801, 0x00005801, 20 },
154:   {    4194301, 0x00000c01, 0x00001401, 21 },
155:   {    8388593, 0x00001e01, 0x00002201, 22 },
156:   {   16777213, 0x00000301, 0x00000501, 23 },
157:   {   33554393, 0x00001381, 0x00001481, 24 },
158:   {   67108859, 0x00000141, 0x000001c1, 25 },
159:   {  134217689, 0x000004e1, 0x00000521, 26 },
160:   {  268435399, 0x00000391, 0x000003b1, 27 },
161:   {  536870909, 0x00000019, 0x00000029, 28 },
162:   { 1073741789, 0x0000008d, 0x00000095, 29 },
163:   { 2147483647, 0x00000003, 0x00000007, 30 },
164:   /* Avoid "decimal constant so large it is unsigned" for 4294967291.  */
165:   { 0xfffffffb, 0x00000006, 0x00000008, 31 }
166: };
167:
168: /* The following function returns an index into the above table of the
169:    nearest prime number which is greater than N, and near a power of two. */
170:
171: static unsigned int
172: higher_prime_index (unsigned long n)
173: {
174:   unsigned int low = 0;
175:   unsigned int high = sizeof(prime_tab) / sizeof(prime_tab[0]);
176:
177:   while (low != high)
178:     {
179:       unsigned int mid = low + (high - low) / 2;
180:       if (n > prime_tab[mid].prime)
181:         low = mid + 1;
182:       else
183:         high = mid;
184:     }
185:
186:   /* If we've run out of primes, abort.  */
187:   if (n > prime_tab[low].prime)
188:     {
189:       fprintf (stderr, "Cannot find prime bigger than %lu\n", n);
190:       abort ();
191:     }
192:
193:   return low;
```

## libiberty/hashtab.c:282–286

```text
282: htab_create_alloc (size_t size, htab_hash hash_f, htab_eq eq_f,
283:                    htab_del del_f, htab_alloc alloc_f, htab_free free_f)
284: {
285:   return htab_create_typed_alloc (size, hash_f, eq_f, del_f, alloc_f, alloc_f,
286:                                   free_f);
```

## libiberty/hashtab.c:339–374

```text
339: The function returns the created hash table, or @code{NULL} if memory
340: allocation fails.
341:
342: @end deftypefn
343:
344: */
345:
346: htab_t
347: htab_create_typed_alloc (size_t size, htab_hash hash_f, htab_eq eq_f,
348:                          htab_del del_f, htab_alloc alloc_tab_f,
349:                          htab_alloc alloc_f, htab_free free_f)
350: {
351:   htab_t result;
352:   unsigned int size_prime_index;
353:
354:   size_prime_index = higher_prime_index (size);
355:   size = prime_tab[size_prime_index].prime;
356:
357:   result = (htab_t) (*alloc_tab_f) (1, sizeof (struct htab));
358:   if (result == NULL)
359:     return NULL;
360:   result->entries = (void **) (*alloc_f) (size, sizeof (void *));
361:   if (result->entries == NULL)
362:     {
363:       if (free_f != NULL)
364:         (*free_f) (result);
365:       return NULL;
366:     }
367:   result->size = size;
368:   result->size_prime_index = size_prime_index;
369:   result->hash_f = hash_f;
370:   result->eq_f = eq_f;
371:   result->del_f = del_f;
372:   result->alloc_f = alloc_f;
373:   result->free_f = free_f;
374:   return result;
```

## libiberty/hashtab.c:517–575

```text
517: htab_expand (htab_t htab)
518: {
519:   void **oentries;
520:   void **olimit;
521:   void **p;
522:   void **nentries;
523:   size_t nsize, osize, elts;
524:   unsigned int oindex, nindex;
525:
526:   oentries = htab->entries;
527:   oindex = htab->size_prime_index;
528:   osize = htab->size;
529:   olimit = oentries + osize;
530:   elts = htab_elements (htab);
531:
532:   /* Resize only when table after removal of unused elements is either
533:      too full or too empty.  */
534:   if (elts * 2 > osize || (elts * 8 < osize && osize > 32))
535:     {
536:       nindex = higher_prime_index (elts * 2);
537:       nsize = prime_tab[nindex].prime;
538:     }
539:   else
540:     {
541:       nindex = oindex;
542:       nsize = osize;
543:     }
544:
545:   if (htab->alloc_with_arg_f != NULL)
546:     nentries = (void **) (*htab->alloc_with_arg_f) (htab->alloc_arg, nsize,
547:                                                     sizeof (void *));
548:   else
549:     nentries = (void **) (*htab->alloc_f) (nsize, sizeof (void *));
550:   if (nentries == NULL)
551:     return 0;
552:   htab->entries = nentries;
553:   htab->size = nsize;
554:   htab->size_prime_index = nindex;
555:   htab->n_elements -= htab->n_deleted;
556:   htab->n_deleted = 0;
557:
558:   p = oentries;
559:   do
560:     {
561:       void *x = *p;
562:
563:       if (x != HTAB_EMPTY_ENTRY && x != HTAB_DELETED_ENTRY)
564:         {
565:           void **q = find_empty_slot_for_expand (htab, (*htab->hash_f) (x));
566:
567:           *q = x;
568:         }
569:
570:       p++;
571:     }
572:   while (p < olimit);
573:
574:   if (htab->free_f != NULL)
575:     (*htab->free_f) (oentries);
```

## libiberty/hashtab.c:633–695

```text
633: htab_find_slot_with_hash (htab_t htab, const void *element,
634:                           hashval_t hash, enum insert_option insert)
635: {
636:   void **first_deleted_slot;
637:   hashval_t index, hash2;
638:   size_t size;
639:   void *entry;
640:
641:   size = htab_size (htab);
642:   if (insert == INSERT && size * 3 <= htab->n_elements * 4)
643:     {
644:       if (htab_expand (htab) == 0)
645:         return NULL;
646:       size = htab_size (htab);
647:     }
648:
649:   index = htab_mod (hash, htab);
650:
651:   htab->searches++;
652:   first_deleted_slot = NULL;
653:
654:   entry = htab->entries[index];
655:   if (entry == HTAB_EMPTY_ENTRY)
656:     goto empty_entry;
657:   else if (entry == HTAB_DELETED_ENTRY)
658:     first_deleted_slot = &htab->entries[index];
659:   else if ((*htab->eq_f) (entry, element))
660:     return &htab->entries[index];
661:
662:   hash2 = htab_mod_m2 (hash, htab);
663:   for (;;)
664:     {
665:       htab->collisions++;
666:       index += hash2;
667:       if (index >= size)
668:         index -= size;
669:
670:       entry = htab->entries[index];
671:       if (entry == HTAB_EMPTY_ENTRY)
672:         goto empty_entry;
673:       else if (entry == HTAB_DELETED_ENTRY)
674:         {
675:           if (!first_deleted_slot)
676:             first_deleted_slot = &htab->entries[index];
677:         }
678:       else if ((*htab->eq_f) (entry, element))
679:         return &htab->entries[index];
680:     }
681:
682:  empty_entry:
683:   if (insert == NO_INSERT)
684:     return NULL;
685:
686:   if (first_deleted_slot)
687:     {
688:       htab->n_deleted--;
689:       *first_deleted_slot = HTAB_EMPTY_ENTRY;
690:       return first_deleted_slot;
691:     }
692:
693:   htab->n_elements++;
694:   return &htab->entries[index];
695: }
```
