# Pinned GAS source excerpts

Literal LF line numbering.

## gas/input-file.c:40–40

```text
40: #define BUFFER_SIZE (32 * 1024)
```

## gas/input-file.c:69–74

```text
69: /* Return BUFFER_SIZE.  */
70: size_t
71: input_file_buffer_size (void)
72: {
73:   return (BUFFER_SIZE);
74: }
```

## gas/input-scrub.c:50–74

```text
50:  *   to end of statement as you removed in the middle, to synch line numbers.
51:  */
52:
53: #define BEFORE_STRING ("\n")
54: #define AFTER_STRING ("\0")     /* memcpy of 0 chars might choke.  */
55: #define BEFORE_SIZE (1)
56: #define AFTER_SIZE  (1)
57:
58: #ifndef TC_EOL_IN_INSN
59: #define TC_EOL_IN_INSN(P) 0
60: #endif
61:
62: static char *buffer_start;      /*->1st char of full buffer area.  */
63: static char *partial_where;     /*->after last full line in buffer.  */
64: static size_t partial_size;     /* >=0. Number of chars in partial line in buffer.  */
65:
66: /* Because we need AFTER_STRING just after last full line, it clobbers
67:    1st part of partial line. So we preserve 1st part of partial line
68:    here.  */
69: static char save_source[AFTER_SIZE];
70:
71: /* The size of the input buffer we concatenate
72:    input_file_give_next_buffer chunks into.  Excludes the BEFORE and
73:    AFTER counts.  */
74: static size_t buffer_length;
```

## gas/input-scrub.c:141–151

```text
141: input_scrub_reinit (void)
142: {
143:   input_file_begin ();          /* Reinitialize! */
144:   logical_input_line = -1u;
145:   logical_input_file = NULL;
146:   sb_index = -1;
147:
148:   buffer_length = input_file_buffer_size () * 2;
149:   buffer_start = XNEWVEC (char, BEFORE_SIZE + AFTER_SIZE + 1 + buffer_length);
150:   memcpy (buffer_start, BEFORE_STRING, (int) BEFORE_SIZE);
151: }
```

## gas/input-scrub.c:380–438

```text
380:
381:   if (partial_size)
382:     {
383:       memmove (buffer_start + BEFORE_SIZE, partial_where, partial_size);
384:       memcpy (buffer_start + BEFORE_SIZE, save_source, AFTER_SIZE);
385:     }
386:
387:   while (1)
388:     {
389:       char *p;
390:       char *start = buffer_start + BEFORE_SIZE + partial_size;
391:
392:       *bufp = buffer_start + BEFORE_SIZE;
393:       limit = input_file_give_next_buffer (start);
394:       if (!limit)
395:         {
396:           if (!partial_size)
397:             /* End of this file.  */
398:             break;
399:
400:           as_warn (_("end of file not at end of a line; newline inserted"));
401:           p = buffer_start + BEFORE_SIZE + partial_size;
402:           *p++ = '\n';
403:           limit = p;
404:         }
405:       else
406:         {
407:           /* Terminate the buffer to avoid confusing TC_EOL_IN_INSN.  */
408:           *limit = '\0';
409:
410:           /* Find last newline.  */
411:           for (p = limit - 1; *p != '\n' || TC_EOL_IN_INSN (p); --p)
412:             if (p < start)
413:               goto read_more;
414:           ++p;
415:         }
416:
417:       /* We found a newline in the newly read chars.  */
418:       partial_where = p;
419:       partial_size = limit - p;
420:
421:       /* Save the fragment after that last newline.  */
422:       memcpy (save_source, partial_where, AFTER_SIZE);
423:       memcpy (partial_where, AFTER_STRING, AFTER_SIZE);
424:       return partial_where;
425:
426:     read_more:
427:       /* Didn't find a newline.  Read more text.  */
428:       partial_size = limit - (buffer_start + BEFORE_SIZE);
429:       if (buffer_length - input_file_buffer_size () < partial_size)
430:         {
431:           /* Increase the buffer when it doesn't have room for the
432:              next block of input.  */
433:           buffer_length *= 2;
434:           buffer_start = XRESIZEVEC (char, buffer_start,
435:                                      (buffer_length
436:                                       + BEFORE_SIZE + AFTER_SIZE + 1));
437:         }
438:     }
```

## gas/as.c:75–75

```text
75: enum debug_info_type debug_type = DEBUG_UNSPECIFIED;
```

## gas/as.c:105–123

```text
105: int flag_dwarf_cie_version = -1;
106:
107: /* The maximum level of DWARF DEBUG information we should manufacture.
108:    This defaults to 3 unless overridden by a command line option.  */
109: unsigned int dwarf_level = 3;
110:
111: #if defined OBJ_ELF || defined OBJ_MAYBE_ELF
112: int flag_use_elf_stt_common = DEFAULT_GENERATE_ELF_STT_COMMON;
113: bool flag_generate_build_notes = DEFAULT_GENERATE_BUILD_NOTES;
114: #endif
115:
116: /* If DEFAULT_SFRAME is 0 instead, flag_gen_sframe gets the default
117:    enum value GEN_SFRAME_DEFAULT_NONE.  */
118: #if DEFAULT_SFRAME
119: enum gen_sframe_option flag_gen_sframe = GEN_SFRAME_CONFIG_ENABLED;
120: #endif
121: /* Version of SFrame stack trace info to generate.  Default version is
122:    SFRAME_VERSION_3.  */
123: enum gen_sframe_version flag_gen_sframe_version = GEN_SFRAME_VERSION_3;
```

## gas/as.c:1012–1018

```text
1012:
1013: # if defined (TARGET_USE_SCFI) && defined (TARGET_USE_GINSN)
1014:         case OPTION_SCFI:
1015:           if (optarg && strcasecmp (optarg, "experimental") == 0)
1016:             flag_synth_cfi = SYNTH_CFI_EXPERIMENTAL;
1017:           else
1018:             as_fatal (_("Invalid --scfi= option: `%s'; suggested option: experimental"),
```

## gas/as.h:140–147

```text
140: /* These are assembler-wide concepts */
141:
142: extern bfd *stdoutput;
143: typedef bfd_vma addressT;
144: typedef bfd_signed_vma offsetT;
145:
146: /* Type of symbol value, etc.  For use in prototypes.  */
147: typedef addressT valueT;
```

## gas/as.h:331–337

```text
331: enum synth_cfi_type
332: {
333:   SYNTH_CFI_NONE = 0,
334:   SYNTH_CFI_EXPERIMENTAL,
335: };
336:
337: COMMON enum synth_cfi_type flag_synth_cfi;
```

## gas/dw2gencfi.c:47–91

```text
47: /* We re-use DWARF2_LINE_MIN_INSN_LENGTH for the code alignment field
48:    of the CIE.  Default to 1 if not otherwise specified.  */
49: #ifndef DWARF2_LINE_MIN_INSN_LENGTH
50: #define DWARF2_LINE_MIN_INSN_LENGTH 1
51: #endif
52:
53: /* By default, use 32-bit relocations from .eh_frame into .text.  */
54: #ifndef DWARF2_FDE_RELOC_SIZE
55: #define DWARF2_FDE_RELOC_SIZE 4
56: #endif
57:
58: /* By default, use a read-only .eh_frame section.  */
59: #ifndef DWARF2_EH_FRAME_READ_ONLY
60: #define DWARF2_EH_FRAME_READ_ONLY SEC_READONLY
61: #endif
62:
63: #ifndef EH_FRAME_ALIGNMENT
64: #define EH_FRAME_ALIGNMENT (bfd_get_arch_size (stdoutput) == 64 ? 3 : 2)
65: #endif
66:
67: #define EH_FRAME_LINKONCE (SUPPORT_FRAME_LINKONCE || compact_eh \
68:                            || TARGET_MULTIPLE_EH_FRAME_SECTIONS)
69:
70: #ifndef DWARF2_FORMAT
71: #define DWARF2_FORMAT(SEC) dwarf2_format_32bit
72: #endif
73:
74: #ifndef DWARF2_ADDR_SIZE
75: #define DWARF2_ADDR_SIZE(bfd) (bfd_arch_bits_per_address (bfd) / 8)
76: #endif
77:
78: #if MULTIPLE_FRAME_SECTIONS
79: #define CUR_SEG(structp) structp->cur_seg
80: #define SET_CUR_SEG(structp, seg) structp->cur_seg = seg
81: #define HANDLED(structp) structp->handled
82: #define SET_HANDLED(structp, val) structp->handled = val
83: #else
84: #define CUR_SEG(structp) NULL
85: #define SET_CUR_SEG(structp, seg) (void) (0 && seg)
86: #define HANDLED(structp) 0
87: #define SET_HANDLED(structp, val) (void) (0 && val)
88: #endif
89:
90: #ifndef tc_cfi_reloc_for_encoding
91: #define tc_cfi_reloc_for_encoding(e) BFD_RELOC_NONE
```

## gas/dw2gencfi.c:113–149

```text
113: out_one (int byte)
114: {
115:   FRAG_APPEND_1_CHAR (byte);
116: }
117:
118: /* Emit a two-byte word into the current segment.  */
119:
120: static inline void
121: out_two (int data)
122: {
123:   md_number_to_chars (frag_more (2), data, 2);
124: }
125:
126: /* Emit a four byte word into the current segment.  */
127:
128: static inline void
129: out_four (int data)
130: {
131:   md_number_to_chars (frag_more (4), data, 4);
132: }
133:
134: /* Emit an unsigned "little-endian base 128" number.  */
135:
136: static void
137: out_uleb128 (addressT value)
138: {
139:   output_leb128 (frag_more (sizeof_leb128 (value, 0)), value, 0);
140: }
141:
142: /* Emit an unsigned "little-endian base 128" number.  */
143:
144: static void
145: out_sleb128 (offsetT value)
146: {
147:   output_leb128 (frag_more (sizeof_leb128 (value, 1)), value, 1);
148: }
149:
```

## gas/dw2gencfi.c:393–459

```text
393: /* Construct a new FDE structure and add it to the end of the fde list.  */
394:
395: static struct fde_entry *
396: alloc_fde_entry (void)
397: {
398:   struct fde_entry *fde = notes_calloc (1, sizeof (*fde));
399:
400:   frchain_now->frch_cfi_data = notes_calloc (1, sizeof (struct frch_cfi_data));
401:   frchain_now->frch_cfi_data->cur_fde_data = fde;
402:   *last_fde_data = fde;
403:   last_fde_data = &fde->next;
404:   SET_CUR_SEG (fde, is_now_linkonce_segment ());
405:   SET_HANDLED (fde, 0);
406:   fde->last = &fde->data;
407:   fde->return_column = DWARF2_DEFAULT_RETURN_COLUMN;
408:   fde->per_encoding = DW_EH_PE_omit;
409:   fde->lsda_encoding = DW_EH_PE_omit;
410:   fde->eh_header_type = EH_COMPACT_UNKNOWN;
411: #ifdef tc_fde_entry_init_extra
412:   tc_fde_entry_init_extra (fde);
413: #endif
414:
415:   return fde;
416: }
417:
418: /* The following functions are available for a backend to construct its
419:    own unwind information, usually from legacy unwind directives.  */
420:
421: /* Construct a new INSN structure and add it to the end of the insn list
422:    for the currently active FDE.  */
423:
424: static bool cfi_sections_set = false;
425: static int cfi_sections = CFI_EMIT_eh_frame;
426: int all_cfi_sections = 0;
427: static struct fde_entry *last_fde;
428:
429: static struct cfi_insn_data *
430: alloc_cfi_insn_data (void)
431: {
432:   struct cfi_insn_data *insn = notes_calloc (1, sizeof (*insn));
433:   struct fde_entry *cur_fde_data = frchain_now->frch_cfi_data->cur_fde_data;
434:
435:   *cur_fde_data->last = insn;
436:   cur_fde_data->last = &insn->next;
437:   SET_CUR_SEG (insn, is_now_linkonce_segment ());
438: #ifndef NO_LISTING
439:   insn->listing_ctxt = cur_fde_data->listing_ctxt ? listing_tail : NULL;
440: #endif
441:   return insn;
442: }
443:
444: /* Construct a new FDE structure that begins at LABEL.  */
445:
446: void
447: cfi_new_fde (symbolS *label, bool do_listing)
448: {
449:   struct fde_entry *fde = alloc_fde_entry ();
450:   fde->start_address = label;
451:   if (do_listing)
452:     {
453: #ifndef NO_LISTING
454:       fde->listing_ctxt = listing_tail;
455: #endif
456:     }
457:   frchain_now->frch_cfi_data->last_address = label;
458: }
459:
```

## gas/dw2gencfi.c:499–553

```text
499: static void
500: cfi_add_CFA_insn (int insn)
501: {
502:   struct cfi_insn_data *insn_ptr = alloc_cfi_insn_data ();
503:
504:   insn_ptr->insn = insn;
505: }
506:
507: static void
508: cfi_add_CFA_insn_reg (int insn, unsigned regno)
509: {
510:   struct cfi_insn_data *insn_ptr = alloc_cfi_insn_data ();
511:
512:   insn_ptr->insn = insn;
513:   insn_ptr->u.r = regno;
514: }
515:
516: static void
517: cfi_add_CFA_insn_offset (int insn, offsetT offset)
518: {
519:   struct cfi_insn_data *insn_ptr = alloc_cfi_insn_data ();
520:
521:   insn_ptr->insn = insn;
522:   insn_ptr->u.i = offset;
523: }
524:
525: static void
526: cfi_add_CFA_insn_reg_reg (int insn, unsigned reg1, unsigned reg2)
527: {
528:   struct cfi_insn_data *insn_ptr = alloc_cfi_insn_data ();
529:
530:   insn_ptr->insn = insn;
531:   insn_ptr->u.rr.reg1 = reg1;
532:   insn_ptr->u.rr.reg2 = reg2;
533: }
534:
535: static void
536: cfi_add_CFA_insn_reg_offset (int insn, unsigned regno, offsetT offset)
537: {
538:   struct cfi_insn_data *insn_ptr = alloc_cfi_insn_data ();
539:
540:   insn_ptr->insn = insn;
541:   insn_ptr->u.ri.reg = regno;
542:   insn_ptr->u.ri.offset = offset;
543: }
544:
545: /* Add a CFI insn to advance the PC from the last address to LABEL.  */
546:
547: void
548: cfi_add_advance_loc (symbolS *label)
549: {
550:   struct cfi_insn_data *insn = alloc_cfi_insn_data ();
551:
552:   insn->insn = DW_CFA_advance_loc;
553:   insn->u.ll.lab1 = frchain_now->frch_cfi_data->last_address;
```

## gas/dw2gencfi.c:573–640

```text
573: cfi_add_CFA_offset (unsigned regno, offsetT offset)
574: {
575:   unsigned int abs_data_align;
576:
577:   gas_assert (DWARF2_CIE_DATA_ALIGNMENT != 0);
578:   cfi_add_CFA_insn_reg_offset (DW_CFA_offset, regno, offset);
579:
580:   abs_data_align = (DWARF2_CIE_DATA_ALIGNMENT < 0
581:                     ? -DWARF2_CIE_DATA_ALIGNMENT : DWARF2_CIE_DATA_ALIGNMENT);
582:   if (offset % abs_data_align)
583:     as_bad (_("register save offset not a multiple of %u"), abs_data_align);
584: }
585:
586: /* Add a DW_CFA_val_offset record to the CFI data.  */
587:
588: void
589: cfi_add_CFA_val_offset (unsigned regno, offsetT offset)
590: {
591:   unsigned int abs_data_align;
592:
593:   gas_assert (DWARF2_CIE_DATA_ALIGNMENT != 0);
594:   cfi_add_CFA_insn_reg_offset (DW_CFA_val_offset, regno, offset);
595:
596:   abs_data_align = (DWARF2_CIE_DATA_ALIGNMENT < 0
597:                     ? -DWARF2_CIE_DATA_ALIGNMENT : DWARF2_CIE_DATA_ALIGNMENT);
598:   if (offset % abs_data_align)
599:     as_bad (_("register save offset not a multiple of %u"), abs_data_align);
600: }
601:
602: /* Add a DW_CFA_def_cfa record to the CFI data.  */
603:
604: void
605: cfi_add_CFA_def_cfa (unsigned regno, offsetT offset)
606: {
607:   cfi_add_CFA_insn_reg_offset (DW_CFA_def_cfa, regno, offset);
608:   frchain_now->frch_cfi_data->cur_cfa_offset = offset;
609: }
610:
611: /* Add a DW_CFA_register record to the CFI data.  */
612:
613: void
614: cfi_add_CFA_register (unsigned reg1, unsigned reg2)
615: {
616:   cfi_add_CFA_insn_reg_reg (DW_CFA_register, reg1, reg2);
617: }
618:
619: /* Add a DW_CFA_def_cfa_register record to the CFI data.  */
620:
621: void
622: cfi_add_CFA_def_cfa_register (unsigned regno)
623: {
624:   cfi_add_CFA_insn_reg (DW_CFA_def_cfa_register, regno);
625: }
626:
627: /* Add a DW_CFA_def_cfa_offset record to the CFI data.  */
628:
629: void
630: cfi_add_CFA_def_cfa_offset (offsetT offset)
631: {
632:   cfi_add_CFA_insn_offset (DW_CFA_def_cfa_offset, offset);
633:   frchain_now->frch_cfi_data->cur_cfa_offset = offset;
634: }
635:
636: void
637: cfi_add_CFA_restore (unsigned regno)
638: {
639:   cfi_add_CFA_insn_reg (DW_CFA_restore, regno);
640: }
```

## gas/dw2gencfi.c:802–883

```text
802: static void
803: dot_cfi (int arg)
804: {
805:   offsetT offset;
806:   unsigned reg1, reg2;
807:
808:   if (frchain_now->frch_cfi_data == NULL)
809:     {
810:       as_bad (_("CFI instruction used without previous .cfi_startproc"));
811:       ignore_rest_of_line ();
812:       return;
813:     }
814:
815:   /* If the last address was not at the current PC, advance to current.  */
816:   if (symbol_get_frag (frchain_now->frch_cfi_data->last_address) != frag_now
817:       || (S_GET_VALUE (frchain_now->frch_cfi_data->last_address)
818:           != frag_now_fix ()))
819:     cfi_add_advance_loc (symbol_temp_new_now ());
820:
821:   switch (arg)
822:     {
823:     case DW_CFA_offset:
824:       reg1 = cfi_parse_reg ();
825:       cfi_parse_separator ();
826:       offset = cfi_parse_const ();
827:       cfi_add_CFA_offset (reg1, offset);
828:       break;
829:
830:     case DW_CFA_val_offset:
831:       reg1 = cfi_parse_reg ();
832:       cfi_parse_separator ();
833:       offset = cfi_parse_const ();
834:       cfi_add_CFA_val_offset (reg1, offset);
835:       break;
836:
837:     case CFI_rel_offset:
838:       reg1 = cfi_parse_reg ();
839:       cfi_parse_separator ();
840:       offset = cfi_parse_const ();
841:       cfi_add_CFA_offset (reg1,
842:                           offset - frchain_now->frch_cfi_data->cur_cfa_offset);
843:       break;
844:
845:     case DW_CFA_def_cfa:
846:       reg1 = cfi_parse_reg ();
847:       cfi_parse_separator ();
848:       offset = cfi_parse_const ();
849:       cfi_add_CFA_def_cfa (reg1, offset);
850:       break;
851:
852:     case DW_CFA_register:
853:       reg1 = cfi_parse_reg ();
854:       cfi_parse_separator ();
855:       reg2 = cfi_parse_reg ();
856:       cfi_add_CFA_register (reg1, reg2);
857:       break;
858:
859:     case DW_CFA_def_cfa_register:
860:       reg1 = cfi_parse_reg ();
861:       cfi_add_CFA_def_cfa_register (reg1);
862:       break;
863:
864:     case DW_CFA_def_cfa_offset:
865:       offset = cfi_parse_const ();
866:       cfi_add_CFA_def_cfa_offset (offset);
867:       break;
868:
869:     case CFI_adjust_cfa_offset:
870:       offset = cfi_parse_const ();
871:       cfi_add_CFA_def_cfa_offset (frchain_now->frch_cfi_data->cur_cfa_offset
872:                                   + offset);
873:       break;
874:
875:     case DW_CFA_restore:
876:       for (;;)
877:         {
878:           reg1 = cfi_parse_reg ();
879:           cfi_add_CFA_restore (reg1);
880:           SKIP_WHITESPACE ();
881:           if (*input_line_pointer != ',')
882:             break;
883:           ++input_line_pointer;
```

## gas/dw2gencfi.c:1337–1394

```text
1337: static void
1338: dot_cfi_startproc (int ignored ATTRIBUTE_UNUSED)
1339: {
1340:   int simple = 0;
1341:
1342:   if (frchain_now->frch_cfi_data != NULL)
1343:     {
1344:       as_bad (_("previous CFI entry not closed (missing .cfi_endproc)"));
1345:       ignore_rest_of_line ();
1346:       return;
1347:     }
1348:
1349:   cfi_new_fde (symbol_temp_new_now (), listing & LISTING_LISTING);
1350:
1351:   SKIP_WHITESPACE ();
1352:   if (is_name_beginner (*input_line_pointer) || *input_line_pointer == '"')
1353:     {
1354:       char * saved_ilp = input_line_pointer;
1355:       char *name, c;
1356:
1357:       c = get_symbol_name (& name);
1358:
1359:       if (strcmp (name, "simple") == 0)
1360:         {
1361:           simple = 1;
1362:           restore_line_pointer (c);
1363:         }
1364:       else
1365:         input_line_pointer = saved_ilp;
1366:     }
1367:   demand_empty_rest_of_line ();
1368:
1369:   cfi_set_sections ();
1370:
1371:   frchain_now->frch_cfi_data->cur_cfa_offset = 0;
1372:   if (!simple)
1373:     tc_cfi_frame_initial_instructions ();
1374:
1375:   if ((all_cfi_sections & CFI_EMIT_target) != 0)
1376:     tc_cfi_startproc ();
1377: }
1378:
1379: static void
1380: dot_cfi_endproc (int ignored ATTRIBUTE_UNUSED)
1381: {
1382:   if (frchain_now->frch_cfi_data == NULL)
1383:     {
1384:       as_bad (_(".cfi_endproc without corresponding .cfi_startproc"));
1385:       ignore_rest_of_line ();
1386:       return;
1387:     }
1388:
1389:   cfi_set_last_fde (frchain_now->frch_cfi_data->cur_fde_data);
1390:
1391:   cfi_end_fde (symbol_temp_new_now ());
1392:
1393:   demand_empty_rest_of_line ();
1394:
```

## gas/dw2gencfi.c:1658–1790

```text
1658: output_cfi_insn (struct cfi_insn_data *insn)
1659: {
1660:   offsetT offset;
1661:   unsigned int regno;
1662:
1663:   switch (insn->insn)
1664:     {
1665:     case DW_CFA_advance_loc:
1666:       {
1667:         symbolS *from = insn->u.ll.lab1;
1668:         symbolS *to = insn->u.ll.lab2;
1669:
1670:         if (symbol_get_frag (to) == symbol_get_frag (from))
1671:           {
1672:             addressT delta = S_GET_VALUE (to) - S_GET_VALUE (from);
1673:             addressT scaled = delta / DWARF2_LINE_MIN_INSN_LENGTH;
1674:
1675:             if (scaled == 0)
1676:               ;
1677:             else if (scaled <= 0x3F)
1678:               out_one (DW_CFA_advance_loc + scaled);
1679:             else if (scaled <= 0xFF)
1680:               {
1681:                 out_one (DW_CFA_advance_loc1);
1682:                 out_one (scaled);
1683:               }
1684:             else if (scaled <= 0xFFFF)
1685:               {
1686:                 out_one (DW_CFA_advance_loc2);
1687:                 out_two (scaled);
1688:               }
1689:             else
1690:               {
1691:                 out_one (DW_CFA_advance_loc4);
1692:                 out_four (scaled);
1693:               }
1694:           }
1695:         else
1696:           {
1697:             expressionS exp = {
1698:               .X_op = O_subtract,
1699:               .X_add_symbol = to,
1700:               .X_op_symbol = from,
1701:             };
1702:
1703:             /* The code in ehopt.c expects that one byte of the encoding
1704:                is already allocated to the frag.  This comes from the way
1705:                that it scans the .eh_frame section looking first for the
1706:                .byte DW_CFA_advance_loc4.  Call frag_grow with the sum of
1707:                room needed by frag_more and frag_var to preallocate space
1708:                ensuring that the DW_CFA_advance_loc4 is in the fixed part
1709:                of the rs_cfa frag, so that the relax machinery can remove
1710:                the advance_loc should it advance by zero.  */
1711:             frag_grow (5);
1712:             *frag_more (1) = DW_CFA_advance_loc4;
1713:
1714:             frag_var (rs_cfa, 4, 0, DWARF2_LINE_MIN_INSN_LENGTH << 3,
1715:                       make_expr_symbol (&exp), frag_now_fix () - 1,
1716:                       (char *) frag_now);
1717:           }
1718:       }
1719:       break;
1720:
1721:     case DW_CFA_def_cfa:
1722:       offset = insn->u.ri.offset;
1723:       if (offset < 0)
1724:         {
1725:           out_one (DW_CFA_def_cfa_sf);
1726:           out_uleb128 (insn->u.ri.reg);
1727:           out_sleb128 (offset / DWARF2_CIE_DATA_ALIGNMENT);
1728:         }
1729:       else
1730:         {
1731:           out_one (DW_CFA_def_cfa);
1732:           out_uleb128 (insn->u.ri.reg);
1733:           out_uleb128 (offset);
1734:         }
1735:       break;
1736:
1737:     case DW_CFA_def_cfa_register:
1738:     case DW_CFA_undefined:
1739:     case DW_CFA_same_value:
1740:       out_one (insn->insn);
1741:       out_uleb128 (insn->u.r);
1742:       break;
1743:
1744:     case DW_CFA_def_cfa_offset:
1745:       offset = insn->u.i;
1746:       if (offset < 0)
1747:         {
1748:           out_one (DW_CFA_def_cfa_offset_sf);
1749:           out_sleb128 (offset / DWARF2_CIE_DATA_ALIGNMENT);
1750:         }
1751:       else
1752:         {
1753:           out_one (DW_CFA_def_cfa_offset);
1754:           out_uleb128 (offset);
1755:         }
1756:       break;
1757:
1758:     case DW_CFA_restore:
1759:       regno = insn->u.r;
1760:       if (regno <= 0x3F)
1761:         {
1762:           out_one (DW_CFA_restore + regno);
1763:         }
1764:       else
1765:         {
1766:           out_one (DW_CFA_restore_extended);
1767:           out_uleb128 (regno);
1768:         }
1769:       break;
1770:
1771:     case DW_CFA_offset:
1772:       regno = insn->u.ri.reg;
1773:       offset = insn->u.ri.offset / DWARF2_CIE_DATA_ALIGNMENT;
1774:       if (offset < 0)
1775:         {
1776:           out_one (DW_CFA_offset_extended_sf);
1777:           out_uleb128 (regno);
1778:           out_sleb128 (offset);
1779:         }
1780:       else if (regno <= 0x3F)
1781:         {
1782:           out_one (DW_CFA_offset + regno);
1783:           out_uleb128 (offset);
1784:         }
1785:       else
1786:         {
1787:           out_one (DW_CFA_offset_extended);
1788:           out_uleb128 (regno);
1789:           out_uleb128 (offset);
1790:         }
```

## gas/dw2gencfi.c:1910–2154

```text
1910: output_cie (struct cie_entry *cie, bool eh_frame, int align)
1911: {
1912:   symbolS *after_size_address, *end_address;
1913:   expressionS exp;
1914:   struct cfi_insn_data *i;
1915:   offsetT augmentation_size;
1916:   int enc;
1917:   enum dwarf2_format fmt = DWARF2_FORMAT (now_seg);
1918:
1919:   cie->start_address = symbol_temp_new_now ();
1920:   after_size_address = symbol_temp_make ();
1921:   end_address = symbol_temp_make ();
1922:
1923:   exp.X_op = O_subtract;
1924:   exp.X_add_symbol = end_address;
1925:   exp.X_op_symbol = after_size_address;
1926:   exp.X_add_number = 0;
1927:
1928:   if (eh_frame || fmt == dwarf2_format_32bit)
1929:     emit_expr (&exp, 4);                        /* Length.  */
1930:   else
1931:     {
1932:       if (fmt == dwarf2_format_64bit)
1933:         out_four (-1);
1934:       emit_expr (&exp, 8);                      /* Length.  */
1935:     }
1936:   symbol_set_value_now (after_size_address);
1937:   if (eh_frame)
1938:     out_four (0);                               /* CIE id.  */
1939:   else
1940:     {
1941:       out_four (-1);                            /* CIE id.  */
1942:       if (fmt != dwarf2_format_32bit)
1943:         out_four (-1);
1944:     }
1945:   out_one (flag_dwarf_cie_version);             /* Version.  */
1946:   if (eh_frame)
1947:     {
1948:       out_one ('z');                            /* Augmentation.  */
1949:       if (cie->per_encoding != DW_EH_PE_omit)
1950:         out_one ('P');
1951:       if (cie->lsda_encoding != DW_EH_PE_omit)
1952:         out_one ('L');
1953:       out_one ('R');
1954: #ifdef tc_output_cie_extra
1955:       tc_output_cie_extra (cie);
1956: #endif
1957:     }
1958:   if (cie->signal_frame)
1959:     out_one ('S');
1960:   out_one (0);
1961:   if (flag_dwarf_cie_version >= 4)
1962:     {
1963:       /* For now we are assuming a flat address space with 4 or 8 byte
1964:          addresses.  */
1965:       int address_size = dwarf2_format_32bit ? 4 : 8;
1966:       out_one (address_size);                   /* Address size.  */
1967:       out_one (0);                              /* Segment size.  */
1968:     }
1969:   out_uleb128 (DWARF2_LINE_MIN_INSN_LENGTH);    /* Code alignment.  */
1970:   out_sleb128 (DWARF2_CIE_DATA_ALIGNMENT);      /* Data alignment.  */
1971:   if (flag_dwarf_cie_version == 1)              /* Return column.  */
1972:     {
1973:       if ((cie->return_column & 0xff) != cie->return_column)
1974:         as_bad (_("return column number %d overflows in CIE version 1"),
1975:                 cie->return_column);
1976:       out_one (cie->return_column);
1977:     }
1978:   else
1979:     out_uleb128 (cie->return_column);
1980:   if (eh_frame)
1981:     {
1982:       augmentation_size = 1 + (cie->lsda_encoding != DW_EH_PE_omit);
1983:       if (cie->per_encoding != DW_EH_PE_omit)
1984:         augmentation_size += 1 + encoding_size (cie->per_encoding);
1985:       out_uleb128 (augmentation_size);          /* Augmentation size.  */
1986:
1987:       emit_expr_encoded (&cie->personality, cie->per_encoding, true);
1988:
1989:       if (cie->lsda_encoding != DW_EH_PE_omit)
1990:         out_one (cie->lsda_encoding);
1991:     }
1992:
1993:   switch (DWARF2_FDE_RELOC_SIZE)
1994:     {
1995:     case 2:
1996:       enc = DW_EH_PE_sdata2;
1997:       break;
1998:     case 4:
1999:       enc = DW_EH_PE_sdata4;
2000:       break;
2001:     case 8:
2002:       enc = DW_EH_PE_sdata8;
2003:       break;
2004:     default:
2005:       abort ();
2006:     }
2007: #if CFI_DIFF_EXPR_OK || defined tc_cfi_emit_pcrel_expr
2008:   enc |= DW_EH_PE_pcrel;
2009: #endif
2010: #ifdef DWARF2_FDE_RELOC_ENCODING
2011:   /* Allow target to override encoding.  */
2012:   enc = DWARF2_FDE_RELOC_ENCODING (enc);
2013: #endif
2014:   cie->fde_encoding = enc;
2015:   if (eh_frame)
2016:     out_one (enc);
2017:
2018:   if (cie->first)
2019:     {
2020:       for (i = cie->first; i != cie->last; i = i->next)
2021:         {
2022:           if (CUR_SEG (i) != CUR_SEG (cie))
2023:             continue;
2024:           output_cfi_insn (i);
2025:         }
2026:     }
2027:
2028:   frag_align (align, DW_CFA_nop, 0);
2029:   symbol_set_value_now (end_address);
2030: }
2031:
2032: static void
2033: output_fde (struct fde_entry *fde, struct cie_entry *cie,
2034:             bool eh_frame, struct cfi_insn_data *first,
2035:             int align)
2036: {
2037:   symbolS *after_size_address, *end_address;
2038:   expressionS exp;
2039:   offsetT augmentation_size;
2040:   enum dwarf2_format fmt = DWARF2_FORMAT (now_seg);
2041:   unsigned int offset_size;
2042:   unsigned int addr_size;
2043:
2044:   after_size_address = symbol_temp_make ();
2045:   end_address = symbol_temp_make ();
2046:
2047:   exp.X_op = O_subtract;
2048:   exp.X_add_symbol = end_address;
2049:   exp.X_op_symbol = after_size_address;
2050:   exp.X_add_number = 0;
2051:   if (eh_frame || fmt == dwarf2_format_32bit)
2052:     offset_size = 4;
2053:   else
2054:     {
2055:       if (fmt == dwarf2_format_64bit)
2056:         out_four (-1);
2057:       offset_size = 8;
2058:     }
2059:   emit_expr (&exp, offset_size);                /* Length.  */
2060:   symbol_set_value_now (after_size_address);
2061:
2062:   if (eh_frame)
2063:     {
2064:       exp.X_op = O_subtract;
2065:       exp.X_add_symbol = after_size_address;
2066:       exp.X_op_symbol = cie->start_address;
2067:       exp.X_add_number = 0;
2068:       emit_expr (&exp, offset_size);            /* CIE offset.  */
2069:     }
2070:   else
2071:     {
2072:       TC_DWARF2_EMIT_OFFSET (cie->start_address, offset_size);
2073:     }
2074:
2075:   exp.X_op = O_symbol;
2076:   if (eh_frame)
2077:     {
2078:       bfd_reloc_code_real_type code
2079:         = tc_cfi_reloc_for_encoding (cie->fde_encoding);
2080:       addr_size = DWARF2_FDE_RELOC_SIZE;
2081:       if (code != BFD_RELOC_NONE)
2082:         {
2083:           reloc_howto_type *howto = bfd_reloc_type_lookup (stdoutput, code);
2084:           char *p = frag_more (addr_size);
2085:           gas_assert (addr_size == (unsigned) howto->bitsize / 8);
2086:           md_number_to_chars (p, 0, addr_size);
2087:           fix_new (frag_now, p - frag_now->fr_literal, addr_size,
2088:                    fde->start_address, 0, howto->pc_relative, code);
2089:         }
2090:       else
2091:         {
2092:           exp.X_op = O_subtract;
2093:           exp.X_add_number = 0;
2094: #if CFI_DIFF_EXPR_OK
2095:           exp.X_add_symbol = fde->start_address;
2096:           exp.X_op_symbol = symbol_temp_new_now ();
2097:           emit_expr (&exp, addr_size);  /* Code offset.  */
2098: #else
2099:           exp.X_op = O_symbol;
2100:           exp.X_add_symbol = fde->start_address;
2101:
2102: #if defined(tc_cfi_emit_pcrel_expr)
2103:           tc_cfi_emit_pcrel_expr (&exp, addr_size);      /* Code offset.  */
2104: #else
2105:           emit_expr (&exp, addr_size);  /* Code offset.  */
2106: #endif
2107: #endif
2108:         }
2109:     }
2110:   else
2111:     {
2112:       exp.X_add_number = 0;
2113:       exp.X_add_symbol = fde->start_address;
2114:       addr_size = DWARF2_ADDR_SIZE (stdoutput);
2115:       emit_expr (&exp, addr_size);
2116:     }
2117:
2118:   exp.X_op = O_subtract;
2119:   exp.X_add_symbol = fde->end_address;
2120:   exp.X_op_symbol = fde->start_address;         /* Code length.  */
2121:   exp.X_add_number = 0;
2122:   emit_expr (&exp, addr_size);
2123:
2124:   augmentation_size = encoding_size (fde->lsda_encoding);
2125:   if (eh_frame)
2126:     out_uleb128 (augmentation_size);            /* Augmentation size.  */
2127:
2128:   emit_expr_encoded (&fde->lsda, cie->lsda_encoding, false);
2129:
2130:   for (; first; first = first->next)
2131:     if (CUR_SEG (first) == CUR_SEG (fde))
2132:       {
2133: #ifndef NO_LISTING
2134:         if (eh_frame)
2135:           listing_override_tail (first->listing_ctxt);
2136: #endif
2137:         output_cfi_insn (first);
2138:       }
2139:
2140: #ifndef NO_LISTING
2141:   /* Associate any padding with .cfi_endproc.  */
2142:   if (eh_frame)
2143:     listing_override_tail (fde->listing_end);
2144: #endif
2145:
2146:   frag_align (align, DW_CFA_nop, 0);
2147:   symbol_set_value_now (end_address);
2148: }
2149:
2150: /* Allow these insns to be put in the initial sequence of a CIE.
2151:    If J is non-NULL, then compare I and J insns for a match.  */
2152:
2153: static inline bool
2154: initial_cie_insn (const struct cfi_insn_data *i, const struct cfi_insn_data *j)
```

## gas/dw2gencfi.c:2208–2290

```text
2208: select_cie_for_fde (struct fde_entry *fde, bool eh_frame,
2209:                     struct cfi_insn_data **pfirst, int align)
2210: {
2211:   struct cfi_insn_data *i, *j;
2212:   struct cie_entry *cie;
2213:
2214:   for (cie = cie_root; cie; cie = cie->next)
2215:     {
2216:       if (CUR_SEG (cie) != CUR_SEG (fde))
2217:         continue;
2218: #ifdef tc_cie_fde_equivalent_extra
2219:       if (!tc_cie_fde_equivalent_extra (cie, fde))
2220:         continue;
2221: #endif
2222:       if (cie->return_column != fde->return_column
2223:           || cie->signal_frame != fde->signal_frame
2224:           || cie->per_encoding != fde->per_encoding
2225:           || cie->lsda_encoding != fde->lsda_encoding)
2226:         continue;
2227:       if (cie->per_encoding != DW_EH_PE_omit)
2228:         {
2229:           if (cie->personality.X_op != fde->personality.X_op
2230:               || (cie->personality.X_add_number
2231:                   != fde->personality.X_add_number))
2232:             continue;
2233:           switch (cie->personality.X_op)
2234:             {
2235:             case O_constant:
2236:               if (cie->personality.X_unsigned != fde->personality.X_unsigned)
2237:                 continue;
2238:               break;
2239:             case O_symbol:
2240:               if (cie->personality.X_add_symbol
2241:                   != fde->personality.X_add_symbol)
2242:                 continue;
2243:               break;
2244:             default:
2245:               abort ();
2246:             }
2247:         }
2248:       for (i = cie->first, j = fde->data;
2249:            i != cie->last && j != NULL;
2250:            i = i->next, j = j->next)
2251:         {
2252:           if (!initial_cie_insn (i, j))
2253:             break;
2254:         }
2255:
2256:       if (i == cie->last)
2257:         {
2258:           *pfirst = j;
2259:           return cie;
2260:         }
2261:     }
2262:
2263:   cie = XNEW (struct cie_entry);
2264:   cie->next = cie_root;
2265:   cie_root = cie;
2266:   SET_CUR_SEG (cie, CUR_SEG (fde));
2267:   cie->return_column = fde->return_column;
2268:   cie->signal_frame = fde->signal_frame;
2269:   cie->per_encoding = fde->per_encoding;
2270:   cie->lsda_encoding = fde->lsda_encoding;
2271:   cie->personality = fde->personality;
2272:   cie->first = fde->data;
2273: #ifdef tc_cie_entry_init_extra
2274:   tc_cie_entry_init_extra (cie, fde);
2275: #endif
2276:
2277:   for (i = cie->first; i ; i = i->next)
2278:     if (!initial_cie_insn (i, NULL))
2279:       break;
2280:
2281:   cie->last = i;
2282:   *pfirst = i;
2283:
2284:   output_cie (cie, eh_frame, align);
2285:
2286:   return cie;
2287: }
2288:
2289: #ifdef md_reg_eh_frame_to_debug_frame
2290: static void
```

## gas/dw2gencfi.c:2385–2500

```text
2385: cfi_finish (void)
2386: {
2387:   struct cie_entry *cie, *cie_next;
2388:   segT cfi_seg, ccseg;
2389:   struct fde_entry *fde;
2390:   struct cfi_insn_data *first;
2391: #ifndef NO_LISTING
2392:   /* We may temporarily replace listing_tail, which otherwise isn't supposed
2393:      to be changing anymore.  Play safe and restore the original value
2394:      afterwards.  */
2395:   struct list_info_struct *saved_listing_tail = NULL;
2396: #endif
2397:   int save_flag_traditional_format, seek_next_seg;
2398:
2399:   if (all_fde_data == 0)
2400:     return;
2401:
2402:   if ((all_cfi_sections & CFI_EMIT_eh_frame) != 0
2403:       || (all_cfi_sections & CFI_EMIT_eh_frame_compact) != 0)
2404:     {
2405:       /* Make sure check_eh_frame doesn't do anything with our output.  */
2406:       save_flag_traditional_format = flag_traditional_format;
2407:       flag_traditional_format = 1;
2408:
2409:       if (!EH_FRAME_LINKONCE)
2410:         {
2411:           /* Open .eh_frame section.  */
2412:           cfi_seg = get_cfi_seg (NULL, ".eh_frame",
2413:                                  (SEC_ALLOC | SEC_LOAD | SEC_DATA
2414:                                   | DWARF2_EH_FRAME_READ_ONLY),
2415:                                  EH_FRAME_ALIGNMENT);
2416: #ifdef md_fix_up_eh_frame
2417:           md_fix_up_eh_frame (cfi_seg);
2418: #else
2419:           (void) cfi_seg;
2420: #endif
2421:         }
2422:
2423:       do
2424:         {
2425:           ccseg = NULL;
2426:           seek_next_seg = 0;
2427:
2428:           for (fde = all_fde_data; fde ; fde = fde->next)
2429:             {
2430:               if ((fde->sections & CFI_EMIT_eh_frame) == 0
2431:                   && (fde->sections & CFI_EMIT_eh_frame_compact) == 0)
2432:                 continue;
2433:
2434: #if SUPPORT_COMPACT_EH
2435:               /* Emit a LEGACY format header if we have processed all
2436:                  of the .cfi directives without encountering either inline or
2437:                  out-of-line compact unwinding opcodes.  */
2438:               if (fde->eh_header_type == EH_COMPACT_HAS_LSDA
2439:                   || fde->eh_header_type == EH_COMPACT_UNKNOWN)
2440:                 fde->eh_header_type = EH_COMPACT_LEGACY;
2441:
2442:               if (fde->eh_header_type != EH_COMPACT_LEGACY)
2443:                 continue;
2444: #endif
2445:               if (EH_FRAME_LINKONCE)
2446:                 {
2447:                   if (HANDLED (fde))
2448:                     continue;
2449:                   if (seek_next_seg && CUR_SEG (fde) != ccseg)
2450:                     {
2451:                       seek_next_seg = 2;
2452:                       continue;
2453:                     }
2454:                   if (!seek_next_seg)
2455:                     {
2456:                       ccseg = CUR_SEG (fde);
2457:                       /* Open .eh_frame section.  */
2458:                       cfi_seg = get_cfi_seg (ccseg, ".eh_frame",
2459:                                              (SEC_ALLOC | SEC_LOAD | SEC_DATA
2460:                                               | DWARF2_EH_FRAME_READ_ONLY),
2461:                                              EH_FRAME_ALIGNMENT);
2462: #ifdef md_fix_up_eh_frame
2463:                       md_fix_up_eh_frame (cfi_seg);
2464: #else
2465:                       (void) cfi_seg;
2466: #endif
2467:                       seek_next_seg = 1;
2468:                     }
2469:                   SET_HANDLED (fde, 1);
2470:                 }
2471:
2472:               if (fde->end_address == NULL)
2473:                 {
2474:                   as_bad (_("open CFI at the end of file; "
2475:                             "missing .cfi_endproc directive"));
2476:                   fde->end_address = fde->start_address;
2477:                 }
2478:
2479: #ifndef NO_LISTING
2480:               {
2481:                 struct list_info_struct *listing_prev
2482:                   = listing_override_tail (fde->listing_ctxt);
2483:
2484:                 if (!saved_listing_tail)
2485:                   saved_listing_tail = listing_prev;
2486:               }
2487: #endif
2488:
2489:               cie = select_cie_for_fde (fde, true, &first, 2);
2490:               fde->eh_loc = symbol_temp_new_now ();
2491:               output_fde (fde, cie, true, first,
2492:                           fde->next == NULL ? EH_FRAME_ALIGNMENT : 2);
2493:             }
2494:
2495:           for (cie = cie_root; cie; cie = cie_next)
2496:             {
2497:               cie_next = cie->next;
2498:               free (cie);
2499:             }
2500:           cie_root = NULL;
```

## gas/dw2gencfi.c:2598–2624

```text
2598:   /* Generate SFrame section if the user:
2599:         - enables via the command line option, or
2600:         - default-enabled at configure-time via --enable-default-sframe, or
2601:         - specifies .sframe in the .cfi_sections directive and does not disable
2602:           via the command line.  */
2603:   if (flag_gen_sframe == GEN_SFRAME_ENABLED
2604:       || flag_gen_sframe == GEN_SFRAME_CONFIG_ENABLED
2605:       || ((all_cfi_sections & CFI_EMIT_sframe) != 0
2606:           && flag_gen_sframe != GEN_SFRAME_DISABLED))
2607:     {
2608: #ifdef support_sframe_p
2609:       if (support_sframe_p () && !SUPPORT_FRAME_LINKONCE)
2610:         {
2611:           segT sframe_seg;
2612:           int alignment = ffs (DWARF2_ADDR_SIZE (stdoutput)) - 1;
2613:
2614:           sframe_seg = get_cfi_seg (NULL, ".sframe",
2615:                                     (SEC_ALLOC | SEC_LOAD | SEC_DATA
2616:                                      | DWARF2_EH_FRAME_READ_ONLY),
2617:                                     alignment);
2618:           elf_section_type (sframe_seg) = SHT_GNU_SFRAME;
2619:           output_sframe (sframe_seg);
2620:         }
2621:       else
2622: #endif
2623:         /* Avoid erroring with DEFAULT_SFRAME for non-default options, like
2624:            -32 on x86_64.  */
```

## gas/config/tc-i386.c:205–205

```text
205: static unsigned int x86_used_note = DEFAULT_X86_USED_NOTE;
```

## gas/config/tc-i386.c:728–749

```text
728: /* 1 if lfence should be inserted after every load.  */
729: static int lfence_after_load = 0;
730:
731: /* Non-zero if lfence should be inserted before indirect branch.  */
732: static enum lfence_before_indirect_branch_kind
733:   {
734:     lfence_branch_none = 0,
735:     lfence_branch_register,
736:     lfence_branch_memory,
737:     lfence_branch_all
738:   }
739: lfence_before_indirect_branch;
740:
741: /* Non-zero if lfence should be inserted before ret.  */
742: static enum lfence_before_ret_kind
743:   {
744:     lfence_before_ret_none = 0,
745:     lfence_before_ret_not,
746:     lfence_before_ret_or,
747:     lfence_before_ret_shl
748:   }
749: lfence_before_ret;
```

## gas/config/tc-i386.c:777–777

```text
777: static int align_branch_power = 0;
```

## gas/config/tc-i386.c:3744–3758

```text
3744:
3745:   if (object_64bit)
3746:     {
3747: #if defined (OBJ_COFF) && defined (TE_PE)
3748:       x86_dwarf2_return_column = 32;
3749: #else
3750:       x86_dwarf2_return_column = REG_RA;
3751: #endif
3752:       x86_cie_data_alignment = -8;
3753:     }
3754:   else
3755:     {
3756:       x86_dwarf2_return_column = 8;
3757:       x86_cie_data_alignment = -4;
3758:     }
```

## gas/config/tc-i386.c:4281–4287

```text
4281:   /* Note that for pseudo prefixes this produces a length of 1. But for them
4282:      the length isn't interesting at all.  */
4283:   for (l = 1; l < 4; ++l)
4284:     if (!(i.tm.base_opcode >> (8 * l)))
4285:       break;
4286:
4287:   i.opcode_length = l;
```

## gas/config/tc-i386.c:4837–4919

```text
4837:   /* For 8 bit RegRex64 registers without a prefix, we need an empty rex prefix.  */
4838:   if (((i.types[first].bitfield.class == Reg
4839:         && (i.op[first].regs->reg_flags & RegRex64) != 0)
4840:        || (i.types[last].bitfield.class == Reg
4841:            && (i.op[last].regs->reg_flags & RegRex64) != 0))
4842:       && !is_apx_rex2_encoding () && !is_any_vex_encoding (&i.tm))
4843:     i.rex |= REX_OPCODE;
4844:
4845:   /* For REX/REX2/EVEX prefix instructions, we need to convert old registers
4846:      (AL, CL, DL and BL) to new ones (AXL, CXL, DXL and BXL) and reject AH,
4847:      CH, DH and BH.  */
4848:   if (i.rex || i.rex2 || i.tm.opcode_modifier.evex)
4849:     {
4850:       for (unsigned int x = first; x <= last; x++)
4851:         {
4852:           /* Look for 8 bit operand that uses old registers.  */
4853:           if (i.types[x].bitfield.class == Reg && i.types[x].bitfield.byte
4854:               && !(i.op[x].regs->reg_flags & (RegRex | RegRex2 | RegRex64)))
4855:             {
4856:               /* In case it is "hi" register, give up.  */
4857:               if (i.op[x].regs->reg_num > 3)
4858:                 as_bad (_("can't encode register '%s%s' in an "
4859:                           "instruction requiring %s prefix"),
4860:                         register_prefix, i.op[x].regs->reg_name,
4861:                         i.tm.opcode_modifier.evex ? "EVEX" : "REX/REX2");
4862:
4863:               /* Otherwise it is equivalent to the extended register.
4864:                  Since the encoding doesn't change this is merely
4865:                  cosmetic cleanup for debug output.  */
4866:               i.op[x].regs += 8;
4867:             }
4868:         }
4869:     }
4870:
4871:   if (i.rex == 0 && i.rex2 == 0 && (pp.rex_encoding || pp.rex2_encoding))
4872:     {
4873:       /* Check if we can add a REX_OPCODE byte.  Look for 8 bit operand
4874:          that uses legacy register.  If it is "hi" register, don't add
4875:          rex and rex2 prefix.  */
4876:       unsigned int x;
4877:
4878:       for (x = first; x <= last; x++)
4879:         if (i.types[x].bitfield.class == Reg
4880:             && i.types[x].bitfield.byte
4881:             && !(i.op[x].regs->reg_flags & (RegRex | RegRex2 | RegRex64))
4882:             && i.op[x].regs->reg_num > 3)
4883:           {
4884:             pp.rex_encoding = false;
4885:             pp.rex2_encoding = false;
4886:             break;
4887:           }
4888:
4889:       if (pp.rex_encoding)
4890:         i.rex = REX_OPCODE;
4891:     }
4892:
4893:   if (is_apx_rex2_encoding ())
4894:     {
4895:       /* Most prefixes are not permitted with JMPABS.  */
4896:       if (i.tm.mnem_off == MN_jmpabs)
4897:         {
4898:           if (i.prefix[DATA_PREFIX] || (i.prefix[REX_PREFIX] & REX_W))
4899:             {
4900:               as_bad (_("size override not allowed with `%s'"),
4901:                       insn_name (&i.tm));
4902:               i.prefix[DATA_PREFIX] = 0;
4903:               i.prefix[REX_PREFIX] &= ~REX_W;
4904:             }
4905:           if (i.prefix[ADDR_PREFIX])
4906:             {
4907:               as_bad (_("address override not allowed with `%s'"),
4908:                       insn_name (&i.tm));
4909:               i.prefix[ADDR_PREFIX] = 0;
4910:             }
4911:         }
4912:
4913:       build_rex2_prefix ();
4914:       /* The individual REX.RXBW bits got consumed.  */
4915:       i.rex &= REX_OPCODE;
4916:       i.prefix[REX_PREFIX] = 0;
4917:     }
4918:   else if (i.rex != 0)
4919:     add_prefix (REX_OPCODE | i.rex);
```

## gas/config/tc-i386.c:6672–6674

```text
6672: insert_lfence_after (void)
6673: {
6674:   if (lfence_after_load && load_insn_p ())
```

## gas/config/tc-i386.c:6752–6754

```text
6752:   /* Output or/not/shl and lfence before near ret.  */
6753:   if (lfence_before_ret != lfence_before_ret_none
6754:       && (i.tm.base_opcode | 1) == 0xc3)
```

## gas/config/tc-i386.c:7780–7796

```text
7780:   insert_lfence_before (last_insn);
7781:
7782:   /* We are ready to output the insn.  */
7783:   output_insn (last_insn);
7784:
7785: #ifdef OBJ_ELF
7786:   /* PS: SCFI is enabled only for System V AMD64 ABI.  The ABI check has been
7787:      performed in i386_target_format.  */
7788:   if (flag_synth_cfi)
7789:     {
7790:       ginsnS *ginsn;
7791:       ginsn = x86_ginsn_new (symbol_temp_new_now (), frch_ginsn_gen_mode ());
7792:       frch_ginsn_data_append (ginsn);
7793:     }
7794: #endif
7795:
7796:   insert_lfence_after ();
```

## gas/config/tc-i386.c:10466–10507

```text
10466:   if (!i.tm.opcode_modifier.modrm && i.reg_operands && i.tm.operands < 3)
10467:     i.short_form = (i.tm.operand_types[0].bitfield.class == Reg)
10468:                    != (i.tm.operand_types[1].bitfield.class == Reg);
10469:
10470:   /* Change the opcode based on the operand size given by i.suffix.  */
10471:   switch (i.suffix)
10472:     {
10473:     /* Size floating point instruction.  */
10474:     case LONG_MNEM_SUFFIX:
10475:       if (i.tm.opcode_modifier.floatmf)
10476:         {
10477:           i.tm.base_opcode ^= 4;
10478:           break;
10479:         }
10480:     /* fall through */
10481:     case WORD_MNEM_SUFFIX:
10482:     case QWORD_MNEM_SUFFIX:
10483:       /* It's not a byte, select word/dword operation.  */
10484:       if (i.tm.opcode_modifier.w)
10485:         {
10486:           if (i.short_form)
10487:             i.tm.base_opcode |= 8;
10488:           else
10489:             i.tm.base_opcode |= 1;
10490:         }
10491:
10492:       /* Set mode64 for an operand.  */
10493:       if (i.suffix == QWORD_MNEM_SUFFIX)
10494:         {
10495:           if (flag_code == CODE_64BIT
10496:               && !i.tm.opcode_modifier.norex64
10497:               && !i.tm.opcode_modifier.vexw
10498:               /* Special case for xchg %rax,%rax.  It is NOP and doesn't
10499:                  need rex64. */
10500:               && ! (i.operands == 2
10501:                     && i.tm.base_opcode == 0x90
10502:                     && i.tm.opcode_space == SPACE_BASE
10503:                     && i.types[0].bitfield.instance == Accum
10504:                     && i.types[1].bitfield.instance == Accum))
10505:             i.rex |= REX_W;
10506:
10507:           break;
```

## gas/config/tc-i386.c:11581–11603

```text
11581:     else
11582:         {
11583:       i.rm.mode = 3;
11584:       i.rm.regmem = i.op[op].regs->reg_num;
11585:       set_rex_vrex (i.op[op].regs, REX_B, false);
11586:         }
11587:
11588:       if (op == dest)
11589:         dest = ~0;
11590:       if (op == source)
11591:         source = ~0;
11592:     }
11593:   else
11594:     {
11595:       i.rm.mode = 3;
11596:       if (!i.tm.opcode_modifier.regmem)
11597:         {
11598:           gas_assert (source < MAX_OPERANDS);
11599:           i.rm.regmem = i.op[source].regs->reg_num;
11600:           set_rex_vrex (i.op[source].regs, REX_B,
11601:                         dest >= MAX_OPERANDS && i.tm.opcode_modifier.sse2avx);
11602:           source = ~0;
11603:         }
```

## gas/config/tc-i386.c:12045–12185

```text
12045:   unsigned int padding;
12046:
12047:   if (!x86_used_note)
12048:     return;
12049:
12050:   x86_feature_2_used |= GNU_PROPERTY_X86_FEATURE_2_X86;
12051:
12052:   /* The .note.gnu.property section layout:
12053:
12054:      Field      Length          Contents
12055:      ----       ----            ----
12056:      n_namsz    4               4
12057:      n_descsz   4               The note descriptor size
12058:      n_type     4               NT_GNU_PROPERTY_TYPE_0
12059:      n_name     4               "GNU"
12060:      n_desc     n_descsz        The program property array
12061:      ....       ....            ....
12062:    */
12063:
12064:   /* Create the .note.gnu.property section.  */
12065:   sec = subseg_new (NOTE_GNU_PROPERTY_SECTION_NAME, 0);
12066:   bfd_set_section_flags (sec,
12067:                          (SEC_ALLOC
12068:                           | SEC_LOAD
12069:                           | SEC_DATA
12070:                           | SEC_HAS_CONTENTS
12071:                           | SEC_READONLY));
12072:
12073:   if (get_elf_backend_data (stdoutput)->s->elfclass == ELFCLASS64)
12074:     {
12075:       align_size_1 = 7;
12076:       alignment = 3;
12077:     }
12078:   else
12079:     {
12080:       align_size_1 = 3;
12081:       alignment = 2;
12082:     }
12083:
12084:   bfd_set_section_alignment (sec, alignment);
12085:   elf_section_type (sec) = SHT_NOTE;
12086:
12087:   /* GNU_PROPERTY_X86_ISA_1_USED: 4-byte type + 4-byte data size
12088:                                   + 4-byte data  */
12089:   isa_1_descsz_raw = 4 + 4 + 4;
12090:   /* Align GNU_PROPERTY_X86_ISA_1_USED.  */
12091:   isa_1_descsz = (isa_1_descsz_raw + align_size_1) & ~align_size_1;
12092:
12093:   feature_2_descsz_raw = isa_1_descsz;
12094:   /* GNU_PROPERTY_X86_FEATURE_2_USED: 4-byte type + 4-byte data size
12095:                                       + 4-byte data  */
12096:   feature_2_descsz_raw += 4 + 4 + 4;
12097:   /* Align GNU_PROPERTY_X86_FEATURE_2_USED.  */
12098:   feature_2_descsz = ((feature_2_descsz_raw + align_size_1)
12099:                       & ~align_size_1);
12100:
12101:   descsz = feature_2_descsz;
12102:   /* Section size: n_namsz + n_descsz + n_type + n_name + n_descsz.  */
12103:   p = frag_more (4 + 4 + 4 + 4 + descsz);
12104:
12105:   /* Write n_namsz.  */
12106:   md_number_to_chars (p, (valueT) 4, 4);
12107:
12108:   /* Write n_descsz.  */
12109:   md_number_to_chars (p + 4, (valueT) descsz, 4);
12110:
12111:   /* Write n_type.  */
12112:   md_number_to_chars (p + 4 * 2, (valueT) NT_GNU_PROPERTY_TYPE_0, 4);
12113:
12114:   /* Write n_name.  */
12115:   memcpy (p + 4 * 3, "GNU", 4);
12116:
12117:   /* Write 4-byte type.  */
12118:   md_number_to_chars (p + 4 * 4,
12119:                       (valueT) GNU_PROPERTY_X86_ISA_1_USED, 4);
12120:
12121:   /* Write 4-byte data size.  */
12122:   md_number_to_chars (p + 4 * 5, (valueT) 4, 4);
12123:
12124:   /* Write 4-byte data.  */
12125:   md_number_to_chars (p + 4 * 6, (valueT) x86_isa_1_used, 4);
12126:
12127:   /* Zero out paddings.  */
12128:   padding = isa_1_descsz - isa_1_descsz_raw;
12129:   if (padding)
12130:     memset (p + 4 * 7, 0, padding);
12131:
12132:   /* Write 4-byte type.  */
12133:   md_number_to_chars (p + isa_1_descsz + 4 * 4,
12134:                       (valueT) GNU_PROPERTY_X86_FEATURE_2_USED, 4);
12135:
12136:   /* Write 4-byte data size.  */
12137:   md_number_to_chars (p + isa_1_descsz + 4 * 5, (valueT) 4, 4);
12138:
12139:   /* Write 4-byte data.  */
12140:   md_number_to_chars (p + isa_1_descsz + 4 * 6,
12141:                       (valueT) x86_feature_2_used, 4);
12142:
12143:   /* Zero out paddings.  */
12144:   padding = feature_2_descsz - feature_2_descsz_raw;
12145:   if (padding)
12146:     memset (p + isa_1_descsz + 4 * 7, 0, padding);
12147:
12148:   /* We probably can't restore the current segment, for there likely
12149:      isn't one yet...  */
12150:   if (seg && subseg)
12151:     subseg_set (seg, subseg);
12152: }
12153:
12154: #include "tc-i386-ginsn.c"
12155:
12156: /* Whether SFrame stack trace info is supported.  */
12157: bool
12158: x86_support_sframe_p (void)
12159: {
12160:   /* At this time, SFrame stack trace is supported for AMD64 ABI only.  */
12161:   return (x86_elf_abi == X86_64_ABI);
12162: }
12163:
12164: /* The fixed offset from CFA for SFrame to recover the return address.
12165:    (useful only when SFrame RA tracking is not needed).  */
12166: offsetT
12167: x86_sframe_cfa_ra_offset (void)
12168: {
12169:   gas_assert (x86_elf_abi == X86_64_ABI);
12170:   return (offsetT) -8;
12171: }
12172:
12173: /* The abi/arch identifier for SFrame.  */
12174: unsigned char
12175: x86_sframe_get_abi_arch (void)
12176: {
12177:   unsigned char sframe_abi_arch = 0;
12178:
12179:   if (x86_support_sframe_p ())
12180:     {
12181:       gas_assert (!target_big_endian);
12182:       sframe_abi_arch = SFRAME_ABI_AMD64_ENDIAN_LITTLE;
12183:     }
12184:
12185:   return sframe_abi_arch;
```

## gas/config/tc-i386.c:12289–12357

```text
12289: static int
12290: add_fused_jcc_padding_frag_p (enum mf_cmp_kind *mf_cmp_p,
12291:                               const struct last_insn *last_insn)
12292: {
12293:   /* NB: Don't work with COND_JUMP86 without i386.  */
12294:   if (!align_branch_power
12295:       || now_seg == absolute_section
12296:       || !cpu_arch_flags.bitfield.cpui386
12297:       || !(align_branch & align_branch_fused_bit))
12298:     return 0;
12299:
12300:   if (maybe_fused_with_jcc_p (mf_cmp_p))
12301:     {
12302:       if (last_insn->kind == last_insn_other)
12303:         return 1;
12304:       if (flag_debug)
12305:         as_warn_where (last_insn->file, last_insn->line,
12306:                        _("`%s` skips -malign-branch-boundary on `%s`"),
12307:                        last_insn->name, insn_name (&i.tm));
12308:     }
12309:
12310:   return 0;
12311: }
12312:
12313: /* Return 1 if a BRANCH_PREFIX frag should be generated.  */
12314:
12315: static int
12316: add_branch_prefix_frag_p (const struct last_insn *last_insn)
12317: {
12318:   /* NB: Don't work with COND_JUMP86 without i386.  Don't add prefix
12319:      to PadLock instructions since they include prefixes in opcode.  */
12320:   if (!align_branch_power
12321:       || !align_branch_prefix_size
12322:       || now_seg == absolute_section
12323:       || is_padlock (&i.tm)
12324:       || !cpu_arch_flags.bitfield.cpui386)
12325:     return 0;
12326:
12327:   /* Don't add prefix if it is a prefix or there is no operand in case
12328:      that segment prefix is special.  */
12329:   if (!i.operands || i.tm.opcode_modifier.isprefix)
12330:     return 0;
12331:
12332:   if (last_insn->kind == last_insn_other)
12333:     return 1;
12334:
12335:   if (flag_debug)
12336:     as_warn_where (last_insn->file, last_insn->line,
12337:                    _("`%s` skips -malign-branch-boundary on `%s`"),
12338:                    last_insn->name, insn_name (&i.tm));
12339:
12340:   return 0;
12341: }
12342:
12343: /* Return 1 if a BRANCH_PADDING frag should be generated.  */
12344:
12345: static int
12346: add_branch_padding_frag_p (enum align_branch_kind *branch_p,
12347:                            enum mf_jcc_kind *mf_jcc_p,
12348:                            const struct last_insn *last_insn)
12349: {
12350:   int add_padding;
12351:
12352:   /* NB: Don't work with COND_JUMP86 without i386.  */
12353:   if (!align_branch_power
12354:       || now_seg == absolute_section
12355:       || !cpu_arch_flags.bitfield.cpui386
12356:       || i.tm.opcode_space != SPACE_BASE)
12357:     return 0;
```

## gas/config/tc-i386.c:12603–12640

```text
12603:   /* Output jumps.  */
12604:   if (i.tm.opcode_modifier.jump == JUMP)
12605:     output_branch ();
12606:   else if (i.tm.opcode_modifier.jump == JUMP_BYTE
12607:            || i.tm.opcode_modifier.jump == JUMP_DWORD)
12608:     output_jump ();
12609:   else if (i.tm.opcode_modifier.jump == JUMP_INTERSEGMENT)
12610:     output_interseg_jump ();
12611:   else
12612:     {
12613:       /* Output normal instructions here.  */
12614:       char *p;
12615:       unsigned char *q;
12616:       unsigned int j;
12617:       enum mf_cmp_kind mf_cmp;
12618:
12619:       if (avoid_fence
12620:           && (i.tm.base_opcode == 0xaee8
12621:               || i.tm.base_opcode == 0xaef0
12622:               || i.tm.base_opcode == 0xaef8))
12623:         {
12624:           /* Encode lfence, mfence, and sfence as
12625:              f0 83 04 24 00   lock addl $0x0, (%{re}sp).  */
12626:           if (flag_code == CODE_16BIT)
12627:             as_bad (_("Cannot convert `%s' in 16-bit mode"), insn_name (&i.tm));
12628:           else if (omit_lock_prefix)
12629:             as_bad (_("Cannot convert `%s' with `-momit-lock-prefix=yes' in effect"),
12630:                     insn_name (&i.tm));
12631:           else if (now_seg != absolute_section)
12632:             {
12633:               offsetT val = 0x240483f0ULL;
12634:
12635:               p = frag_more (5);
12636:               md_number_to_chars (p, val, 5);
12637:             }
12638:           else
12639:             abs_section_offset += 5;
12640:           return;
```

## gas/config/tc-i386.c:12689–12861

```text
12689:       /* Since the VEX/EVEX prefix contains the implicit prefix, we
12690:          don't need the explicit prefix.  */
12691:       if (!is_any_vex_encoding (&i.tm))
12692:         {
12693:           switch (i.tm.opcode_modifier.opcodeprefix)
12694:             {
12695:             case PREFIX_0X66:
12696:               add_prefix (0x66);
12697:               break;
12698:             case PREFIX_0XF2:
12699:               add_prefix (0xf2);
12700:               break;
12701:             case PREFIX_0XF3:
12702:               if (!is_padlock (&i.tm)
12703:                   || (i.prefix[REP_PREFIX] != 0xf3))
12704:                 add_prefix (0xf3);
12705:               break;
12706:             case PREFIX_NONE:
12707:               switch (i.opcode_length)
12708:                 {
12709:                 case 2:
12710:                   break;
12711:                 case 1:
12712:                   /* Check for pseudo prefixes.  */
12713:                   if (!i.tm.opcode_modifier.isprefix || i.tm.base_opcode)
12714:                     break;
12715:                   as_bad_where (insn_start_frag->fr_file,
12716:                                 insn_start_frag->fr_line,
12717:                                 _("pseudo prefix without instruction"));
12718:                   return;
12719:                 default:
12720:                   abort ();
12721:                 }
12722:               break;
12723:             default:
12724:               abort ();
12725:             }
12726:
12727: #ifdef OBJ_ELF
12728:           /* For x32, add a dummy REX_OPCODE prefix for mov/add with
12729:              R_X86_64_GOTTPOFF relocation so that linker can safely
12730:              perform IE->LE optimization.  A dummy REX_OPCODE prefix
12731:              is also needed for lea with R_X86_64_GOTPC32_TLSDESC
12732:              relocation for GDesc -> IE/LE optimization.  */
12733:           if (x86_elf_abi == X86_64_X32_ABI
12734:               && !is_apx_rex2_encoding ()
12735:               && (dot_insn () ? i.insn_opcode_space
12736:                               : i.tm.opcode_space) == SPACE_BASE
12737:               && i.operands == 2
12738:               && (i.reloc[0] == BFD_RELOC_X86_64_GOTTPOFF
12739:                   || i.reloc[0] == BFD_RELOC_X86_64_GOTPC32_TLSDESC)
12740:               && i.prefix[REX_PREFIX] == 0)
12741:             add_prefix (REX_OPCODE);
12742: #endif
12743:
12744:           /* The prefix bytes.  */
12745:           for (j = ARRAY_SIZE (i.prefix), q = i.prefix; j > 0; j--, q++)
12746:             if (*q)
12747:               frag_opcode_byte (*q);
12748:
12749:           if (is_apx_rex2_encoding ())
12750:             {
12751:               frag_opcode_byte (i.vex.bytes[0]);
12752:               frag_opcode_byte (i.vex.bytes[1]);
12753:             }
12754:         }
12755:       else
12756:         {
12757:           for (j = 0, q = i.prefix; j < ARRAY_SIZE (i.prefix); j++, q++)
12758:             if (*q)
12759:               switch (j)
12760:                 {
12761:                 case SEG_PREFIX:
12762:                 case ADDR_PREFIX:
12763:                   frag_opcode_byte (*q);
12764:                   break;
12765:                 default:
12766:                   /* There should be no other prefixes for instructions
12767:                      with VEX prefix.  */
12768:                   abort ();
12769:                 }
12770:
12771:           /* For EVEX instructions i.vrex should become 0 after
12772:              build_evex_prefix.  For VEX instructions upper 16 registers
12773:              aren't available, so VREX should be 0.  */
12774:           if (i.vrex)
12775:             abort ();
12776:           /* Now the VEX prefix.  */
12777:           if (now_seg != absolute_section)
12778:             {
12779:               p = frag_more (i.vex.length);
12780:               for (j = 0; j < i.vex.length; j++)
12781:                 p[j] = i.vex.bytes[j];
12782:             }
12783:           else
12784:             abs_section_offset += i.vex.length;
12785:         }
12786:
12787:       /* Now the opcode; be careful about word order here!  */
12788:       j = i.opcode_length;
12789:       if (!i.vex.length)
12790:         switch (i.tm.opcode_space)
12791:           {
12792:           case SPACE_BASE:
12793:             break;
12794:           case SPACE_0F:
12795:             ++j;
12796:             break;
12797:           case SPACE_0F38:
12798:           case SPACE_0F3A:
12799:             j += 2;
12800:             break;
12801:           default:
12802:             abort ();
12803:           }
12804:
12805:       if (now_seg == absolute_section)
12806:         abs_section_offset += j;
12807:       else if (j == 1)
12808:         {
12809:           FRAG_APPEND_1_CHAR (i.tm.base_opcode);
12810:         }
12811:       else
12812:         {
12813:           p = frag_more (j);
12814:           if (!i.vex.length
12815:               && i.tm.opcode_space != SPACE_BASE)
12816:             {
12817:               *p++ = 0x0f;
12818:               if (i.tm.opcode_space != SPACE_0F)
12819:                 *p++ = i.tm.opcode_space == SPACE_0F38
12820:                        ? 0x38 : 0x3a;
12821:             }
12822:
12823:           switch (i.opcode_length)
12824:             {
12825:             case 2:
12826:               /* Put out high byte first: can't use md_number_to_chars!  */
12827:               *p++ = (i.tm.base_opcode >> 8) & 0xff;
12828:               /* Fall through.  */
12829:             case 1:
12830:               *p = i.tm.base_opcode & 0xff;
12831:               break;
12832:             default:
12833:               abort ();
12834:               break;
12835:             }
12836:
12837:         }
12838:
12839:       /* Now the modrm byte and sib byte (if present).  */
12840:       if (i.tm.opcode_modifier.modrm)
12841:         {
12842:           frag_opcode_byte ((i.rm.regmem << 0)
12843:                              | (i.rm.reg << 3)
12844:                              | (i.rm.mode << 6));
12845:           /* If i.rm.regmem == ESP (4)
12846:              && i.rm.mode != (Register mode)
12847:              && not 16 bit
12848:              ==> need second modrm byte.  */
12849:           if (i.rm.regmem == ESCAPE_TO_TWO_BYTE_ADDRESSING
12850:               && i.rm.mode != 3
12851:               && !(i.base_reg && i.base_reg->reg_type.bitfield.word))
12852:             frag_opcode_byte ((i.sib.base << 0)
12853:                               | (i.sib.index << 3)
12854:                               | (i.sib.scale << 6));
12855:         }
12856:
12857:       if (i.disp_operands)
12858:         output_disp (insn_start_frag, insn_start_off);
12859:
12860:       if (i.imm_operands)
12861:         output_imm (insn_start_frag, insn_start_off);
```

## gas/config/tc-i386.c:18757–18762

```text
18757: void
18758: tc_x86_frame_initial_instructions (void)
18759: {
18760:   cfi_add_CFA_def_cfa (object_64bit ? REG_SP : 4, -x86_cie_data_alignment);
18761:   cfi_add_CFA_offset (x86_dwarf2_return_column, x86_cie_data_alignment);
18762: }
```

## gas/config/tc-i386.h:472–484

```text
472: #define sframe_ra_tracking_p() false
473:
474: /* The fixed offset from CFA for SFrame to recover the return address.
475:    (useful only when SFrame RA tracking is not needed).  */
476: extern offsetT x86_sframe_cfa_ra_offset (void);
477: #define sframe_cfa_ra_offset x86_sframe_cfa_ra_offset
478:
479: /* The abi/arch identifier for SFrame.  */
480: extern unsigned char x86_sframe_get_abi_arch (void);
481: #define sframe_get_abi_arch x86_sframe_get_abi_arch
482:
483: /* Whether SFrame FDE of type SFRAME_FDE_TYPE_FLEX be generated.  */
484: #define sframe_support_flex_fde_p() true
```

## gas/symbols.c:251–286

```text
251: void *
252: notes_alloc (size_t size)
253: {
254:   return obstack_alloc (&notes, size);
255: }
256:
257: void *
258: notes_calloc (size_t n, size_t size)
259: {
260:   size_t amt;
261:   void *ret;
262:   if (gas_mul_overflow (n, size, &amt))
263:     {
264:       obstack_alloc_failed_handler ();
265:       abort ();
266:     }
267:   ret = notes_alloc (amt);
268:   memset (ret, 0, amt);
269:   return ret;
270: }
271:
272: void *
273: notes_memdup (const void *src, size_t copy_size, size_t alloc_size)
274: {
275:   void *ret = obstack_alloc (&notes, alloc_size);
276:   memcpy (ret, src, copy_size);
277:   if (alloc_size > copy_size)
278:     memset ((char *) ret + copy_size, 0, alloc_size - copy_size);
279:   return ret;
280: }
281:
282: char *
283: notes_strdup (const char *str)
284: {
285:   size_t len = strlen (str) + 1;
286:   return notes_memdup (str, len, len);
```

## gas/symbols.c:903–924

```text
903: symbol_temp_new (segT seg, fragS *frag, valueT ofs)
904: {
905:   return symbol_new (FAKE_LABEL_NAME, seg, frag, ofs);
906: }
907:
908: symbolS *
909: symbol_temp_new_now (void)
910: {
911:   return symbol_temp_new (now_seg, frag_now, frag_now_fix ());
912: }
913:
914: symbolS *
915: symbol_temp_new_now_octets (void)
916: {
917:   return symbol_temp_new (now_seg, frag_now, frag_now_fix_octets ());
918: }
919:
920: symbolS *
921: symbol_temp_make (void)
922: {
923:   return symbol_make (FAKE_LABEL_NAME);
924: }
```

## gas/expr.c:57–100

```text
57: make_expr_symbol (const expressionS *expressionP)
58: {
59:   symbolS *symbolP;
60:   struct expr_symbol_line *n;
61:
62:   if (expressionP->X_op == O_symbol
63:       && expressionP->X_add_number == 0)
64:     return expressionP->X_add_symbol;
65:
66:   if (expressionP->X_op == O_big)
67:     {
68:       /* This won't work, because the actual value is stored in
69:          generic_floating_point_number or generic_bignum, and we are
70:          going to lose it if we haven't already.  */
71:       if (expressionP->X_add_number > 0)
72:         as_bad (_("bignum invalid"));
73:       else
74:         as_bad (_("floating point number invalid"));
75:       expressionP = &zero;
76:     }
77:
78:   /* Putting constant symbols in absolute_section rather than
79:      expr_section is convenient for the old a.out code, for which
80:      S_GET_SEGMENT does not always retrieve the value put in by
81:      S_SET_SEGMENT.  */
82:   symbolP = symbol_create (FAKE_LABEL_NAME,
83:                            (expressionP->X_op == O_constant
84:                             ? absolute_section
85:                             : expressionP->X_op == O_register
86:                               ? reg_section
87:                               : expr_section),
88:                            &zero_address_frag, 0);
89:   symbol_set_value_expression (symbolP, expressionP);
90:
91:   if (expressionP->X_op == O_constant)
92:     resolve_symbol_value (symbolP);
93:
94:   n = notes_alloc (sizeof (*n));
95:   n->sym = symbolP;
96:   n->file = as_where (&n->line);
97:   n->next = expr_symbol_lines;
98:   expr_symbol_lines = n;
99:
100:   return symbolP;
```

## gas/frags.c:28–41

```text
28: static unsigned int totalfrags;
29:
30: unsigned int
31: get_frag_count (void)
32: {
33:   return totalfrags;
34: }
35:
36: void
37: clear_frag_count (void)
38: {
39:   totalfrags = 0;
40: }
41:
```

## gas/frags.c:76–94

```text
76: frag_alloc (struct obstack *ob, size_t extra)
77: {
78:   fragS *ptr;
79:
80:   /* This will align the obstack so the next struct we allocate on it
81:      will begin at a correct boundary.  */
82:   (void) obstack_finish (ob);
83:   /* Do not use obstack_alloc here.  If you do, you'll need to turn
84:      off alignment as otherwise obstack_alloc will align the end of
85:      the frag (via obstack_finish adjusting obstack next_free
86:      pointer), making it seem like the frag already has contents in
87:      fr_literal.  */
88:   obstack_blank (ob, extra + SIZEOF_STRUCT_FRAG);
89:   ptr = obstack_base (ob);
90:   memset (ptr, 0, SIZEOF_STRUCT_FRAG);
91:   totalfrags++;
92:   return ptr;
93: }
94:
```

## gas/frags.h:73–84

```text
73:   unsigned int relax_marker:1;
74:
75:   /* Used to ensure that all insns are emitted on proper address
76:      boundaries.  */
77:   unsigned int has_code:1;
78:   unsigned int insn_addr:6;
79:
80:   /* What state is my tail in? */
81:   ENUM_BITFIELD (_relax_state) fr_type : 8;
82:   relax_substateT fr_subtype;
83:
84: #ifdef USING_CGEN
```

## gas/ehopt.c:480–582

```text
480: /* The function estimates the size of a rs_cfa variant frag based on
481:    the current values of the symbols.  It is called before the
482:    relaxation loop.  We set fr_subtype{0:2} to the expected length.  */
483:
484: int
485: eh_frame_estimate_size_before_relax (fragS *frag)
486: {
487:   offsetT diff;
488:   int ca = frag->fr_subtype >> 3;
489:   int ret;
490:
491:   diff = resolve_symbol_value (frag->fr_symbol);
492:
493:   gas_assert (ca > 0);
494:   diff /= ca;
495:   if (diff == 0)
496:     ret = -1;
497:   else if (diff < 0x40)
498:     ret = 0;
499:   else if (diff < 0x100)
500:     ret = 1;
501:   else if (diff < 0x10000)
502:     ret = 2;
503:   else
504:     ret = 4;
505:
506:   frag->fr_subtype = (frag->fr_subtype & ~7) | (ret & 7);
507:
508:   return ret;
509: }
510:
511: /* This function relaxes a rs_cfa variant frag based on the current
512:    values of the symbols.  fr_subtype{0:2} is the current length of
513:    the frag.  This returns the change in frag length.  */
514:
515: int
516: eh_frame_relax_frag (fragS *frag)
517: {
518:   int oldsize, newsize;
519:
520:   oldsize = frag->fr_subtype & 7;
521:   if (oldsize == 7)
522:     oldsize = -1;
523:   newsize = eh_frame_estimate_size_before_relax (frag);
524:   return newsize - oldsize;
525: }
526:
527: /* This function converts a rs_cfa variant frag into a normal fill
528:    frag.  This is called after all relaxation has been done.
529:    fr_subtype{0:2} will be the desired length of the frag.  */
530:
531: void
532: eh_frame_convert_frag (fragS *frag)
533: {
534:   offsetT diff;
535:   fragS *loc4_frag;
536:   int loc4_fix, ca;
537:
538:   loc4_frag = (fragS *) frag->fr_opcode;
539:   loc4_fix = frag->fr_offset;
540:
541:   diff = resolve_symbol_value (frag->fr_symbol);
542:
543:   ca = frag->fr_subtype >> 3;
544:   gas_assert (ca > 0);
545:   diff /= ca;
546:   switch (frag->fr_subtype & 7)
547:     {
548:     case 0:
549:       gas_assert (diff < 0x40);
550:       loc4_frag->fr_literal[loc4_fix] = DW_CFA_advance_loc | diff;
551:       break;
552:
553:     case 1:
554:       gas_assert (diff < 0x100);
555:       loc4_frag->fr_literal[loc4_fix] = DW_CFA_advance_loc1;
556:       frag->fr_literal[frag->fr_fix] = diff;
557:       break;
558:
559:     case 2:
560:       gas_assert (diff < 0x10000);
561:       loc4_frag->fr_literal[loc4_fix] = DW_CFA_advance_loc2;
562:       md_number_to_chars (frag->fr_literal + frag->fr_fix, diff, 2);
563:       break;
564:
565:     case 4:
566:       md_number_to_chars (frag->fr_literal + frag->fr_fix, diff, 4);
567:       break;
568:
569:     case 7:
570:       gas_assert (diff == 0);
571:       frag->fr_fix -= 8;
572:       break;
573:
574:     default:
575:       abort ();
576:     }
577:
578:   frag->fr_fix += frag->fr_subtype & 7;
579:   frag->fr_type = rs_fill;
580:   frag->fr_subtype = 0;
581:   frag->fr_offset = 0;
582: }
```

## gas/dwarf2dbg.c:1071–1082

```text
1071: dwarf2_emit_insn (int size)
1072: {
1073:   struct dwarf2_line_info loc;
1074:
1075:   seg_info (now_seg)->insn_seen = 1;
1076:
1077:   if (debug_type != DEBUG_DWARF2
1078:       ? !dwarf2_loc_directive_seen
1079:       : !seen_at_least_1_file ())
1080:     return;
1081:
1082:   dwarf2_where (&loc);
```

## gas/dwarf2dbg.c:3108–3118

```text
3108:
3109:   /* Select the default CIE version to produce here.  The global
3110:      starts with a value of -1 and will be modified to a valid value
3111:      either by the user providing a command line option, or some
3112:      targets will select their own default in md_after_parse_args.  If
3113:      we get here and the global still contains -1 then it is up to us
3114:      to pick a sane default.  The default we choose is 1, this is the
3115:      CIE version gas has produced for a long time, and there seems no
3116:      reason to change it yet.  */
3117:   if (flag_dwarf_cie_version == -1)
3118:     flag_dwarf_cie_version = 1;
```

## opcodes/i386-opc.tbl:192–192

```text
192: mov, 0x88, 0, D|W|CheckOperandSize|Modrm|No_sSuf|HLEPrefixRelease, { Reg8|Reg16|Reg32|Reg64, Reg8|Reg16|Reg32|Reg64|Unspecified|BaseIndex }
```

## opcodes/i386-opc.tbl:246–248

```text
246: push, 0x50, x64, ImplicitStackOp|No_bSuf|No_lSuf|No_sSuf|NoRex64, { Reg16|Reg64 }
247: pushp, 0x50, APX_F, ImplicitStackOp|No_bSuf|No_wSuf|No_lSuf|No_sSuf|Rex2, { Reg64 }
248: push, 0xff/6, x64, Modrm|ImplicitStackOp|DefaultSize|No_bSuf|No_lSuf|No_sSuf|NoRex64, { Reg16|Reg64|Unspecified|BaseIndex }
```

## opcodes/i386-opc.tbl:260–262

```text
260: pop, 0x58, x64, ImplicitStackOp|No_bSuf|No_lSuf|No_sSuf|NoRex64, { Reg16|Reg64 }
261: popp, 0x58, APX_F, ImplicitStackOp|No_bSuf|No_wSuf|No_lSuf|No_sSuf|Rex2, { Reg64 }
262: pop, 0x8f/0, x64, Modrm|ImplicitStackOp|DefaultSize|No_bSuf|No_lSuf|No_sSuf|NoRex64, { Reg16|Reg64|Unspecified|BaseIndex }
```

## opcodes/i386-opc.tbl:521–524

```text
521: ret, 0xc3, x64, Amd64|ImplicitStackOp|DefaultSize|No_bSuf|No_lSuf|No_sSuf|NoRex64|RepPrefixOk|BNDPrefixOk|IntelSuffix, {}
522: ret, 0xc2, x64, Amd64|ImplicitStackOp|DefaultSize|No_bSuf|No_lSuf|No_sSuf|NoRex64|RepPrefixOk|BNDPrefixOk|IntelSuffix, { Imm16 }
523: ret, 0xc3, x64, Intel64|ImplicitStackOp|Size64|No_bSuf|No_wSuf|No_lSuf|No_sSuf|NoRex64|RepPrefixOk|BNDPrefixOk|IntelSuffix, {}
524: ret, 0xc2, x64, Intel64|ImplicitStackOp|Size64|No_bSuf|No_wSuf|No_lSuf|No_sSuf|NoRex64|RepPrefixOk|BNDPrefixOk|IntelSuffix, { Imm16 }
```

## opcodes/i386-opc.tbl:636–636

```text
636: nop, 0x90, 0, NoSuf|RepPrefixOk, {}
```

## opcodes/i386-reg.tbl:135–136

```text
135: rsp, Class=Reg|Qword, 0, 4, Dw2Inval, 7
136: rbp, Class=Reg|Qword|BaseIndex, 0, 5, Dw2Inval, 6
```

## gas/gen-sframe.c:54–59

```text
54: #ifndef SFRAME_FRE_TYPE_SELECTION_OPT
55: # define SFRAME_FRE_TYPE_SELECTION_OPT 1
56: #endif
57:
58: /* gas emits SFrame Version 3 only at this time.  */
59: typedef sframe_func_desc_idx_v3 sframe_func_desc_idx;
```

## gas/gen-sframe.c:210–225

```text
210: static unsigned int
211: get_offset_size_in_bytes (offsetT value)
212: {
213:   unsigned int size = 0;
214:
215:   if (value == (int8_t)value)
216:     size = 1;
217:   else if (value == (int16_t)value)
218:     size = 2;
219:   else if (value == (int32_t)value)
220:     size = 4;
221:   else
222:     return 8;
223:
224:   return size;
225: }
```

## gas/gen-sframe.c:392–421

```text
392: get_fre_dataword_count (const struct sframe_row_entry *sframe_fre, bool flex_p)
393: {
394:   /* For SFRAME_FDE_TYPE_FLEX FDE type, each entity (CFA, FP, RA) may carry up
395:      to two data words.  */
396:   unsigned int count = flex_p ? 2 : 1;
397:
398:   /* CFA data word (or data words when flex_p) must always be present.  */
399:   unsigned int fre_dataword_count = count;
400:
401:   /* For flexible FDE type, there will be two data words for RA (if RA
402:      has a recovery rule applicable).  1 padding data word otherwise.  */
403:   if (flex_p)
404:     {
405:      if (sframe_fre->ra_loc != SFRAME_FRE_ELEM_LOC_NONE)
406:        fre_dataword_count += count;
407:      else if (sframe_fre->fp_loc != SFRAME_FRE_ELEM_LOC_NONE)
408:        fre_dataword_count += 1;
409:     }
410:   else if (sframe_ra_tracking_p ()
411:            && (sframe_fre->ra_loc != SFRAME_FRE_ELEM_LOC_NONE
412:                /* For s390x account padding RA data word, if FP without RA
413:                   saved.  */
414:                || (sframe_get_abi_arch () == SFRAME_ABI_S390X_ENDIAN_BIG
415:                    && sframe_fre->fp_loc != SFRAME_FRE_ELEM_LOC_NONE)))
416:     fre_dataword_count++;
417:
418:   if (sframe_fre->fp_loc != SFRAME_FRE_ELEM_LOC_NONE)
419:     fre_dataword_count += count;
420:
421:   return fre_dataword_count;
```

## gas/gen-sframe.c:428–506

```text
428: sframe_get_fre_dataword_size (const struct sframe_row_entry *sframe_fre,
429:                             bool flex_p)
430: {
431:   unsigned int max_dataword_size = 0;
432:   unsigned int cfa_offset_size = 0;
433:   unsigned int fp_offset_size = 0;
434:   unsigned int ra_offset_size = 0;
435:
436:   unsigned int fre_dataword_size = 0;
437:
438:   /* What size of data words appear in this frame row entry.  */
439:   cfa_offset_size = get_offset_size_in_bytes (sframe_fre->cfa_offset);
440:   if (sframe_fre->fp_loc == SFRAME_FRE_ELEM_LOC_STACK)
441:     fp_offset_size = get_offset_size_in_bytes (sframe_fre->fp_offset);
442:   if (sframe_ra_tracking_p ())
443:     {
444:       if (sframe_fre->ra_loc == SFRAME_FRE_ELEM_LOC_STACK)
445:         ra_offset_size = get_offset_size_in_bytes (sframe_fre->ra_offset);
446:       /* For s390x account padding RA offset, if FP without RA saved.  */
447:       else if (sframe_get_abi_arch () == SFRAME_ABI_S390X_ENDIAN_BIG
448:                && sframe_fre->fp_loc == SFRAME_FRE_ELEM_LOC_STACK)
449:         ra_offset_size = get_offset_size_in_bytes (SFRAME_FRE_RA_OFFSET_INVALID);
450:     }
451:
452:   /* Get the maximum size needed to represent the offsets.  */
453:   max_dataword_size = cfa_offset_size;
454:   if (fp_offset_size > max_dataword_size)
455:     max_dataword_size = fp_offset_size;
456:   if (ra_offset_size > max_dataword_size)
457:     max_dataword_size = ra_offset_size;
458:
459:   /* If flex FDE, account for reg data too.  */
460:   if (flex_p)
461:     {
462:       bool reg_p = (sframe_fre->cfa_base_reg != SFRAME_FRE_REG_INVALID);
463:       unsigned int data
464:         = SFRAME_V3_FLEX_FDE_CTRLWORD_ENCODE (sframe_fre->cfa_base_reg,
465:                                               sframe_fre->cfa_deref_p, reg_p);
466:       unsigned int cfa_control_word_size = get_udata_size_in_bytes (data);
467:       if (cfa_control_word_size > max_dataword_size)
468:         max_dataword_size = cfa_control_word_size;
469:
470:       if (sframe_fre->ra_loc == SFRAME_FRE_ELEM_LOC_REG)
471:         {
472:           data = SFRAME_V3_FLEX_FDE_CTRLWORD_ENCODE (sframe_fre->ra_reg,
473:                                                      sframe_fre->ra_deref_p,
474:                                                      1 /* reg_p.  */);
475:           unsigned ra_control_word_size = get_udata_size_in_bytes (data);
476:           if (ra_control_word_size > max_dataword_size)
477:             max_dataword_size = ra_control_word_size;
478:         }
479:
480:       if (sframe_fre->fp_loc == SFRAME_FRE_ELEM_LOC_REG)
481:         {
482:           data = SFRAME_V3_FLEX_FDE_CTRLWORD_ENCODE (sframe_fre->fp_reg,
483:                                                      sframe_fre->fp_deref_p,
484:                                                      1 /* reg_p.  */);
485:           unsigned fp_control_word_size = get_udata_size_in_bytes (data);
486:           if (fp_control_word_size > max_dataword_size)
487:             max_dataword_size = fp_control_word_size;
488:         }
489:     }
490:
491:   gas_assert (max_dataword_size);
492:
493:   switch (max_dataword_size)
494:     {
495:     case 1:
496:       fre_dataword_size = SFRAME_FRE_DATAWORD_1B;
497:       break;
498:     case 2:
499:       fre_dataword_size = SFRAME_FRE_DATAWORD_2B;
500:       break;
501:     case 4:
502:       fre_dataword_size = SFRAME_FRE_DATAWORD_4B;
503:       break;
504:     default:
505:       /* FRE data words of size 8 bytes is not supported in SFrame.  */
506:       as_fatal (_("SFrame unsupported FRE data word size\n"));
```

## gas/gen-sframe.c:526–627

```text
526: static void
527: create_fre_start_addr_exp (expressionS *cexp, symbolS *fre_pc_begin,
528:                            symbolS *fde_start_address,
529:                            symbolS *fde_end_address)
530: {
531:   /* val expression stores the FDE start address offset from the start PC
532:      of function.  */
533:   expressionS val = {
534:     .X_op = O_subtract,
535:     .X_add_symbol = fre_pc_begin,
536:     .X_op_symbol = fde_start_address,
537:   };
538:
539:   /* width expressions stores the size of the function.  This is used later
540:      to determine the number of bytes to be used to encode the FRE start
541:      address of each FRE of the function.  */
542:   expressionS width = {
543:     .X_op = O_subtract,
544:     .X_add_symbol = fde_end_address,
545:     .X_op_symbol = fde_start_address,
546:   };
547:
548:   *cexp = (expressionS) {
549:     .X_op = O_absent,
550:     .X_add_symbol = make_expr_symbol (&val),
551:     .X_op_symbol = make_expr_symbol (&width)
552:   };
553: }
554:
555: /* Create a composite expression CEXP (for SFrame FDE function info) such that:
556:
557:       exp = <rest_of_func_info> OP_modulus <width>, where,
558:
559:     - <rest_of_func_info> and <width> are themselves expressionS.
560:     - <rest_of_func_info> stores a constant expression where X_add_number is
561:     used to stash away the func_info.  The upper 4-bits of the func_info are copied
562:     back to the resulting byte by the fragment fixup logic.
563:     - <width> stores the expression when evaluated gives the size of the
564:     function in number of bytes.
565:
566:    The use of OP_modulus as the X_op_symbol helps identify this expression
567:    later when fragments are fixed up.  */
568:
569: static void
570: create_func_info_exp (expressionS *cexp, symbolS *dw_fde_end_addrS,
571:                       symbolS *dw_fde_start_addrS, uint8_t func_info)
572: {
573:   expressionS width = {
574:     .X_op = O_subtract,
575:     .X_add_symbol = dw_fde_end_addrS,
576:     .X_op_symbol = dw_fde_start_addrS
577:   };
578:
579:   expressionS rest_of_func_info = {
580:     .X_op = O_constant,
581:     .X_add_number = func_info
582:   };
583:
584:   *cexp = (expressionS) {
585:     .X_op = O_modulus,
586:     .X_add_symbol = make_expr_symbol (&rest_of_func_info),
587:     .X_op_symbol = make_expr_symbol (&width)
588:   };
589: }
590:
591: static struct sframe_row_entry*
592: sframe_row_entry_new (void)
593: {
594:   struct sframe_row_entry *fre = XCNEW (struct sframe_row_entry);
595:   /* Reset all regs to SFRAME_FRE_REG_INVALID.  A value of 0 may imply a
596:      valid register for a supported arch.  */
597:   fre->cfa_base_reg = SFRAME_FRE_REG_INVALID;
598:   fre->fp_reg = SFRAME_FRE_REG_INVALID;
599:   fre->ra_reg = SFRAME_FRE_REG_INVALID;
600:   fre->merge_candidate = true;
601:   /* Reset the mangled RA status bit to zero by default.  We will
602:      initialize it in sframe_row_entry_initialize () with the sticky
603:      bit if set.  */
604:   fre->mangled_ra_p = false;
605:   /* Reset the RA undefined status by to zero by default.  */
606:   fre->ra_undefined_p = false;
607:
608:   return fre;
609: }
610:
611: static void
612: sframe_row_entry_free (struct sframe_row_entry *fre)
613: {
614:   while (fre)
615:     {
616:       struct sframe_row_entry *fre_next = fre->next;
617:       XDELETE (fre);
618:       fre = fre_next;
619:     }
620: }
621:
622: /* Allocate an SFrame FDE.  */
623:
624: static struct sframe_func_entry*
625: sframe_fde_alloc (void)
626: {
627:   return XCNEW (struct sframe_func_entry);
```

## gas/gen-sframe.c:649–738

```text
649: output_sframe_row_entry_datawords (const struct sframe_func_entry *sframe_fde,
650:                                    const struct sframe_row_entry *sframe_fre,
651:                                    unsigned int fre_dataword_size)
652: {
653:   unsigned int fre_write_datawords = 0;
654:
655:   unsigned int idx = sframe_fre_dataword_func_map_index (fre_dataword_size);
656:   gas_assert (idx < SFRAME_FRE_DATAWORD_FUNC_MAP_INDEX_MAX);
657:
658:   if (sframe_fde->fde_flex_p)
659:     {
660:       /* SFrame FDE of type SFRAME_FDE_TYPE_FLEX.  */
661:       /* Output CFA related FRE data words.  */
662:       uint32_t reg = sframe_fre->cfa_base_reg;
663:       bool deref_p = sframe_fre->cfa_deref_p;
664:       uint32_t reg_data
665:         = SFRAME_V3_FLEX_FDE_CTRLWORD_ENCODE (reg, deref_p, 1 /* reg_p.  */);
666:       offsetT offset_data = sframe_fre->cfa_offset;
667:       dataword_func_map[idx].out_func (reg_data);
668:       dataword_func_map[idx].out_func (offset_data);
669:       fre_write_datawords += 2;
670:
671:       bool reg_p = false;
672:       if (sframe_fre->ra_loc != SFRAME_FRE_ELEM_LOC_NONE)
673:         {
674:           /* Output RA related FRE data words.  */
675:           reg_p = sframe_fre->ra_loc == SFRAME_FRE_ELEM_LOC_REG;
676:           reg = reg_p ? sframe_fre->ra_reg : 0;
677:           deref_p = sframe_fre->ra_deref_p;
678:           reg_data = SFRAME_V3_FLEX_FDE_CTRLWORD_ENCODE (reg, deref_p, reg_p);
679:
680:           offset_data = sframe_fre->ra_offset;
681:           dataword_func_map[idx].out_func (reg_data);
682:           dataword_func_map[idx].out_func (offset_data);
683:           fre_write_datawords += 2;
684:         }
685:       else if (sframe_fre->fp_loc != SFRAME_FRE_ELEM_LOC_NONE)
686:         {
687:           /* If RA is not in REG/STACK, emit RA padding if there are more
688:              data words to follow.  Note that, emitting
689:              SFRAME_FRE_RA_OFFSET_INVALID is equivalent to emitting
690:              SFRAME_V3_FLEX_FDE_CTRLWORD_ENCODE (0, 0, 0).  */
691:           dataword_func_map[idx].out_func (SFRAME_FRE_RA_OFFSET_INVALID);
692:           fre_write_datawords += 1;
693:         }
694:
695:       if (sframe_fre->fp_loc != SFRAME_FRE_ELEM_LOC_NONE)
696:         {
697:           /* Output FP related FRE data words.  */
698:           reg_p = sframe_fre->fp_loc == SFRAME_FRE_ELEM_LOC_REG;
699:           reg = reg_p ? sframe_fre->fp_reg : 0;
700:           deref_p = sframe_fre->fp_deref_p;
701:           reg_data = SFRAME_V3_FLEX_FDE_CTRLWORD_ENCODE (reg, deref_p, reg_p);
702:
703:           offset_data = sframe_fre->fp_offset;
704:           dataword_func_map[idx].out_func (reg_data);
705:           dataword_func_map[idx].out_func (offset_data);
706:           fre_write_datawords += 2;
707:         }
708:     }
709:   else
710:     {
711:       /* SFrame FDE of type SFRAME_FDE_TYPE_DEFAULT.  */
712:       /* Output CFA related FRE data words.  */
713:       dataword_func_map[idx].out_func (sframe_fre->cfa_offset);
714:       fre_write_datawords++;
715:
716:       if (sframe_ra_tracking_p ())
717:         {
718:           if (sframe_fre->ra_loc == SFRAME_FRE_ELEM_LOC_STACK)
719:             {
720:               dataword_func_map[idx].out_func (sframe_fre->ra_offset);
721:               fre_write_datawords++;
722:             }
723:           /* For s390x write padding RA offset, if FP without RA saved.  */
724:           else if (sframe_get_abi_arch () == SFRAME_ABI_S390X_ENDIAN_BIG
725:                    && sframe_fre->fp_loc == SFRAME_FRE_ELEM_LOC_STACK)
726:             {
727:               dataword_func_map[idx].out_func (SFRAME_FRE_RA_OFFSET_INVALID);
728:               fre_write_datawords++;
729:             }
730:         }
731:       if (sframe_fre->fp_loc == SFRAME_FRE_ELEM_LOC_STACK)
732:         {
733:           dataword_func_map[idx].out_func (sframe_fre->fp_offset);
734:           fre_write_datawords++;
735:         }
736:     }
737:
738:   return fre_write_datawords;
```

## gas/gen-sframe.c:742–1037

```text
742: output_sframe_row_entry (const struct sframe_func_entry *sframe_fde,
743:                          const struct sframe_row_entry *sframe_fre)
744: {
745:   unsigned char fre_info;
746:   unsigned int fre_dataword_count;
747:   unsigned int fre_dataword_size;
748:   unsigned int fre_base_reg;
749:   bool fre_mangled_ra_p;
750:   expressionS exp;
751:   unsigned int fre_addr_size;
752:
753:   unsigned int fre_write_datawords = 0;
754:   symbolS *fde_start_addr = get_dw_fde_start_addrS (sframe_fde->dw_fde);
755:   symbolS *fde_end_addr = get_dw_fde_end_addrS (sframe_fde->dw_fde);
756:   bool flex_p = sframe_fde->fde_flex_p;
757:
758:   fre_addr_size = 4; /* 4 bytes by default.   FIXME tie it to fre_type? */
759:
760:   /* SFrame FRE Start Address.  */
761:   if (SFRAME_FRE_TYPE_SELECTION_OPT)
762:     {
763:       create_fre_start_addr_exp (&exp, sframe_fre->pc_begin, fde_start_addr,
764:                                  fde_end_addr);
765:       frag_grow (fre_addr_size);
766:       frag_var (rs_sframe, fre_addr_size, 0, 0,
767:                 make_expr_symbol (&exp), 0, (char *) frag_now);
768:     }
769:   else
770:     {
771:       gas_assert (fde_end_addr);
772:       exp = (expressionS) {
773:         .X_op = O_subtract,
774:         .X_add_symbol = sframe_fre->pc_begin, /* to.  */
775:         .X_op_symbol = fde_start_addr /* from.  */
776:       };
777:       emit_expr (&exp, fre_addr_size);
778:     }
779:
780:   /* Create the fre_info using the CFA base register, number of data words and
781:      max size of a data word in this FRE.  Represent RA undefined as FRE
782:      without any data words and all FRE info word fields zeroed.  */
783:   if (sframe_fre->ra_undefined_p)
784:     {
785:       fre_base_reg = 0;
786:       fre_dataword_count = 0;
787:       fre_dataword_size = 0;
788:       fre_mangled_ra_p = 0;
789:     }
790:   else
791:     {
792:       fre_base_reg = get_fre_base_reg_id (sframe_fre);
793:       fre_dataword_count = get_fre_dataword_count (sframe_fre, flex_p);
794:       fre_dataword_size = sframe_get_fre_dataword_size (sframe_fre, flex_p);
795:       fre_mangled_ra_p = sframe_fre->mangled_ra_p;
796:     }
797:
798:   /* Unused for flex FDE.  Set to zero.  */
799:   if (flex_p)
800:     fre_base_reg = 0;
801:
802:   fre_info = sframe_set_fre_info (fre_base_reg, fre_dataword_count,
803:                                   fre_dataword_size, fre_mangled_ra_p);
804:   out_one (fre_info);
805:
806:   /* Represent RA undefined as FRE without any data words.  */
807:   if (sframe_fre->ra_undefined_p)
808:     return;
809:
810:   fre_write_datawords = output_sframe_row_entry_datawords (sframe_fde,
811:                                                            sframe_fre,
812:                                                            fre_dataword_size);
813:
814:   /* Check if the expected number data words have been written out
815:      in this FRE.  */
816:   gas_assert (fre_write_datawords == fre_dataword_count);
817: }
818:
819: static void
820: output_sframe_funcdesc_idx (symbolS *start_of_fre_section,
821:                             symbolS *fre_symbol,
822:                             const struct sframe_func_entry *sframe_fde)
823: {
824:   expressionS exp;
825:   symbolS *dw_fde_start_addrS, *dw_fde_end_addrS;
826:
827:   dw_fde_start_addrS = get_dw_fde_start_addrS (sframe_fde->dw_fde);
828:   dw_fde_end_addrS = get_dw_fde_end_addrS (sframe_fde->dw_fde);
829:
830:   /* Start address of the function.  gas always emits this value with encoding
831:      SFRAME_F_FDE_FUNC_START_PCREL.  See PR ld/32666.  */
832:   exp.X_op = O_subtract;
833:   exp.X_add_symbol = dw_fde_start_addrS; /* to location.  */
834:   exp.X_op_symbol = symbol_temp_new_now (); /* from location.  */
835:   exp.X_add_number = 0;
836:   emit_expr (&exp, sizeof_member (sframe_func_desc_idx,
837:                                   sfdi_func_start_offset));
838:
839:   /* Size of the function in bytes.  */
840:   exp.X_op = O_subtract;
841:   exp.X_add_symbol = dw_fde_end_addrS;
842:   exp.X_op_symbol = dw_fde_start_addrS;
843:   exp.X_add_number = 0;
844:   emit_expr (&exp, sizeof_member (sframe_func_desc_idx,
845:                                   sfdi_func_size));
846:
847:   /* Offset to the function data (attribtues, FREs) in the FRE subsection.  */
848:   exp.X_op = O_subtract;
849:   exp.X_add_symbol = fre_symbol; /* Minuend.  */
850:   exp.X_op_symbol = start_of_fre_section; /* Subtrahend.  */
851:   exp.X_add_number = 0;
852:   emit_expr (&exp, sizeof_member (sframe_func_desc_idx,
853:                                   sfdi_func_start_fre_off));
854: }
855:
856: static void
857: output_sframe_func_desc_attr (const struct sframe_func_entry *sframe_fde)
858: {
859:   symbolS *dw_fde_start_addrS, *dw_fde_end_addrS;
860:   unsigned int pauth_key;
861:   bool signal_p;
862:
863:   dw_fde_start_addrS = get_dw_fde_start_addrS (sframe_fde->dw_fde);
864:   dw_fde_end_addrS = get_dw_fde_end_addrS (sframe_fde->dw_fde);
865:
866:   /* Number of FREs must fit uint16_t.  */
867:   gas_assert (sframe_fde->num_fres <= UINT16_MAX);
868:   out_two (sframe_fde->num_fres);
869:
870:   /* SFrame FDE function info.  */
871:   unsigned char func_info;
872:   pauth_key = (get_dw_fde_pauth_b_key_p (sframe_fde->dw_fde)
873:                ? SFRAME_AARCH64_PAUTH_KEY_B : SFRAME_AARCH64_PAUTH_KEY_A);
874:   signal_p = get_dw_fde_signal_p (sframe_fde->dw_fde);
875:   func_info = sframe_set_func_info (SFRAME_V3_FDE_PCTYPE_INC,
876:                                     SFRAME_FRE_TYPE_ADDR4,
877:                                     pauth_key, signal_p);
878:   if (SFRAME_FRE_TYPE_SELECTION_OPT)
879:     {
880:       expressionS cexp;
881:       create_func_info_exp (&cexp, dw_fde_end_addrS, dw_fde_start_addrS,
882:                             func_info);
883:       frag_grow (1); /* Size of func info is unsigned char.  */
884:       frag_var (rs_sframe, 1, 0, 0, make_expr_symbol (&cexp), 0,
885:                 (char *) frag_now);
886:     }
887:   else
888:     out_one (func_info);
889:
890:   uint8_t finfo2 = 0;
891:   if (sframe_fde->fde_flex_p)
892:     finfo2 = SFRAME_V3_SET_FDE_TYPE (finfo2, SFRAME_FDE_TYPE_FLEX);
893:   out_one (finfo2);
894:
895:   /* Currently, GAS only emits SFrame FDE with PC Type
896:      SFRAME_V3_FDE_PCTYPE_INC.  Emit repetitive block size of 0.  */
897:   out_one (0);
898: }
899:
900: static void
901: output_sframe_internal (void)
902: {
903:   expressionS exp;
904:   unsigned int i = 0;
905:
906:   symbolS *end_of_frame_hdr;
907:   symbolS *end_of_frame_section;
908:   symbolS *start_of_func_desc_section;
909:   symbolS *start_of_fre_section;
910:   struct sframe_func_entry *sframe_fde, *sframe_fde_next;
911:   struct sframe_row_entry *sframe_fre;
912:   unsigned char abi_arch = 0;
913:   int fixed_fp_offset = SFRAME_CFA_FIXED_FP_INVALID;
914:   int fixed_ra_offset = SFRAME_CFA_FIXED_RA_INVALID;
915:
916:   /* The function descriptor entries as dumped by the assembler are not
917:      sorted on PCs.  Fix for PR ld/32666 requires setting of an additional
918:      flag in SFrame Version 2.  */
919:   unsigned char sframe_flags = SFRAME_F_FDE_FUNC_START_PCREL;
920:
921:   unsigned int num_fdes = get_num_sframe_fdes ();
922:   unsigned int num_fres = get_num_sframe_fres ();
923:   symbolS **fde_fre_symbols = XNEWVEC (symbolS *, num_fdes);
924:   for (i = 0; i < num_fdes; i++)
925:     fde_fre_symbols[i] = symbol_temp_make ();
926:
927:   end_of_frame_hdr = symbol_temp_make ();
928:   start_of_fre_section = symbol_temp_make ();
929:   start_of_func_desc_section = symbol_temp_make ();
930:   end_of_frame_section = symbol_temp_make ();
931:
932:   /* Output the preamble of SFrame section.  */
933:   out_two (SFRAME_MAGIC);
934:   out_one (SFRAME_VERSION);
935:   /* gas must ensure emitted SFrame sections have at least the required flags
936:      set.  */
937:   gas_assert ((sframe_flags & SFRAME_V2_GNU_AS_LD_ENCODING_FLAGS)
938:               == SFRAME_V2_GNU_AS_LD_ENCODING_FLAGS);
939:   out_one (sframe_flags);
940:   /* abi/arch.  */
941: #ifdef sframe_get_abi_arch
942:   abi_arch = sframe_get_abi_arch ();
943: #endif
944:   gas_assert (abi_arch);
945:   out_one (abi_arch);
946:
947:   /* Offset for the FP register from CFA.  Neither of the AMD64 or AAPCS64
948:      ABIs have a fixed offset for the FP register from the CFA.  This may be
949:      useful in future (but not without additional support in the toolchain)
950:      for specialized handling/encoding for cases where, for example,
951:      -fno-omit-frame-pointer is used.  */
952:   out_one (fixed_fp_offset);
953:
954:   /* All ABIs participating in SFrame generation must define
955:      sframe_ra_tracking_p.
956:      When RA tracking (in FREs) is not needed (e.g., AMD64), SFrame assumes
957:      the RA is going to be at a fixed offset from CFA.  Check that the fixed RA
958:      offset is appropriately defined in all cases.  */
959:   if (!sframe_ra_tracking_p ())
960:     {
961:       fixed_ra_offset = sframe_cfa_ra_offset ();
962:       gas_assert (fixed_ra_offset != SFRAME_CFA_FIXED_RA_INVALID);
963:     }
964:   out_one (fixed_ra_offset);
965:
966:   /* None of the AMD64, AARCH64, or s390x ABIs need the auxiliary header.
967:      When the need does arise to use this field, the appropriate backend
968:      must provide this information.  */
969:   out_one (0); /* Auxiliary SFrame header length.  */
970:
971:   out_four (num_fdes); /* Number of FDEs.  */
972:   out_four (num_fres); /* Number of FREs.  */
973:
974:   /* Size of FRE sub-section.  */
975:   exp.X_op = O_subtract;
976:   exp.X_add_symbol = end_of_frame_section;
977:   exp.X_op_symbol = start_of_fre_section;
978:   exp.X_add_number = 0;
979:   emit_expr (&exp, sizeof_member (sframe_header, sfh_fre_len));
980:
981:   /* Offset of FDE sub-section.  */
982:   exp.X_op = O_subtract;
983:   exp.X_add_symbol = end_of_frame_hdr;
984:   exp.X_op_symbol = start_of_func_desc_section;
985:   exp.X_add_number = 0;
986:   emit_expr (&exp, sizeof_member (sframe_header, sfh_fdeoff));
987:
988:   /* Offset of FRE sub-section.  */
989:   exp.X_op = O_subtract;
990:   exp.X_add_symbol = start_of_fre_section;
991:   exp.X_op_symbol = end_of_frame_hdr;
992:   exp.X_add_number = 0;
993:   emit_expr (&exp, sizeof_member (sframe_header, sfh_freoff));
994:
995:   symbol_set_value_now (end_of_frame_hdr);
996:   symbol_set_value_now (start_of_func_desc_section);
997:
998:   /* Output the SFrame function descriptor entries.  */
999:   i = 0;
1000:   for (sframe_fde = all_sframe_fdes; sframe_fde; sframe_fde = sframe_fde->next)
1001:     {
1002:       output_sframe_funcdesc_idx (start_of_fre_section, fde_fre_symbols[i],
1003:                                   sframe_fde);
1004:       i++;
1005:     }
1006:
1007:   symbol_set_value_now (start_of_fre_section);
1008:
1009:   /* Output the SFrame FREs.  */
1010:   i = 0;
1011:   sframe_fde = all_sframe_fdes;
1012:
1013:   for (sframe_fde = all_sframe_fdes; sframe_fde; sframe_fde = sframe_fde_next)
1014:     {
1015:       symbol_set_value_now (fde_fre_symbols[i]);
1016:
1017:       output_sframe_func_desc_attr (sframe_fde);
1018:
1019:       for (sframe_fre = sframe_fde->sframe_fres;
1020:            sframe_fre;
1021:            sframe_fre = sframe_fre->next)
1022:         {
1023:           output_sframe_row_entry (sframe_fde, sframe_fre);
1024:         }
1025:       i++;
1026:       sframe_fde_next = sframe_fde->next;
1027:       sframe_fde_free (sframe_fde);
1028:     }
1029:   all_sframe_fdes = NULL;
1030:   last_sframe_fde = &all_sframe_fdes;
1031:
1032:   symbol_set_value_now (end_of_frame_section);
1033:
1034:   gas_assert (i == num_fdes);
1035:
1036:   free (fde_fre_symbols);
1037:   fde_fre_symbols = NULL;
```

## gas/gen-sframe.c:1070–1117

```text
1070: static struct sframe_xlate_ctx*
1071: sframe_xlate_ctx_alloc (void)
1072: {
1073:   struct sframe_xlate_ctx* xlate_ctx = XCNEW (struct sframe_xlate_ctx);
1074:   return xlate_ctx;
1075: }
1076:
1077: /* Initialize the given SFrame translation context.  */
1078:
1079: static void
1080: sframe_xlate_ctx_init (struct sframe_xlate_ctx *xlate_ctx)
1081: {
1082:   xlate_ctx->dw_fde = NULL;
1083:   xlate_ctx->flex_p = false;
1084:   xlate_ctx->first_fre = NULL;
1085:   xlate_ctx->last_fre = NULL;
1086:   xlate_ctx->cur_fre = NULL;
1087:   xlate_ctx->remember_fre = NULL;
1088:   xlate_ctx->num_xlate_fres = 0;
1089: }
1090:
1091: /* Cleanup the given SFrame translation context.  */
1092:
1093: static void
1094: sframe_xlate_ctx_cleanup (struct sframe_xlate_ctx *xlate_ctx)
1095: {
1096:   sframe_row_entry_free (xlate_ctx->first_fre);
1097:   XDELETE (xlate_ctx->remember_fre);
1098:   xlate_ctx->remember_fre = NULL;
1099:   XDELETE (xlate_ctx->cur_fre);
1100:   xlate_ctx->cur_fre = NULL;
1101: }
1102:
1103: /* Transfer the state from the SFrame translation context to the SFrame FDE.  */
1104:
1105: static void
1106: sframe_xlate_ctx_finalize (struct sframe_xlate_ctx *xlate_ctx,
1107:                            struct sframe_func_entry *sframe_fde)
1108: {
1109:   sframe_fde->dw_fde = xlate_ctx->dw_fde;
1110:   sframe_fde->fde_flex_p = xlate_ctx->flex_p;
1111:   sframe_fde->sframe_fres = xlate_ctx->first_fre;
1112:   sframe_fde->num_fres = xlate_ctx->num_xlate_fres;
1113:   /* remember_fre is cloned copy of the applicable fre (where necessary).
1114:      Since this is not included in the list of sframe_fres, free it.  */
1115:   XDELETE (xlate_ctx->remember_fre);
1116:   xlate_ctx->remember_fre = NULL;
1117: }
```

## gas/gen-sframe.c:1204–1303

```text
1204: sframe_xlate_do_advance_loc (struct sframe_xlate_ctx *xlate_ctx,
1205:                              const struct cfi_insn_data *cfi_insn)
1206: {
1207:   struct sframe_row_entry *last_fre = xlate_ctx->last_fre;
1208:   /* Get the scratchpad FRE currently being updated as the cfi_insn's
1209:      get interpreted.  This FRE eventually gets linked in into the
1210:      list of FREs for the specific function.  */
1211:   struct sframe_row_entry *cur_fre = xlate_ctx->cur_fre;
1212:
1213:   if (cur_fre)
1214:     {
1215:       if (!cur_fre->merge_candidate)
1216:         {
1217:           sframe_fre_set_end_addr (cur_fre, cfi_insn->u.ll.lab2);
1218:
1219:           sframe_xlate_ctx_add_fre (xlate_ctx, cur_fre);
1220:           last_fre = xlate_ctx->last_fre;
1221:
1222:           xlate_ctx->cur_fre = sframe_row_entry_new ();
1223:           cur_fre = xlate_ctx->cur_fre;
1224:
1225:           if (last_fre)
1226:             sframe_row_entry_initialize (cur_fre, last_fre);
1227:         }
1228:       else
1229:         {
1230:           sframe_fre_set_end_addr (last_fre, cfi_insn->u.ll.lab2);
1231:           gas_assert (last_fre->merge_candidate == false);
1232:         }
1233:     }
1234:   else
1235:     {
1236:       xlate_ctx->cur_fre = sframe_row_entry_new ();
1237:       cur_fre = xlate_ctx->cur_fre;
1238:     }
1239:
1240:   gas_assert (cur_fre);
1241:   sframe_fre_set_begin_addr (cur_fre, cfi_insn->u.ll.lab2);
1242:
1243:   return SFRAME_XLATE_OK;
1244: }
1245:
1246: /* Translate DW_CFA_def_cfa into SFrame context.
1247:    Return SFRAME_XLATE_OK if success.  */
1248:
1249: static int
1250: sframe_xlate_do_def_cfa (struct sframe_xlate_ctx *xlate_ctx,
1251:                          const struct cfi_insn_data *cfi_insn)
1252:
1253: {
1254:   /* Get the scratchpad FRE.  This FRE will eventually get linked in.  */
1255:   struct sframe_row_entry *cur_fre = xlate_ctx->cur_fre;
1256:   if (!cur_fre)
1257:   {
1258:     xlate_ctx->cur_fre = sframe_row_entry_new ();
1259:     cur_fre = xlate_ctx->cur_fre;
1260:     sframe_fre_set_begin_addr (cur_fre,
1261:                                get_dw_fde_start_addrS (xlate_ctx->dw_fde));
1262:   }
1263:
1264:   offsetT offset = cfi_insn->u.ri.offset;
1265:   bool bound_p = sframe_fre_stack_offset_bound_p (offset, true);
1266:   if (!bound_p)
1267:     {
1268:       as_warn (_("no SFrame FDE emitted; "
1269:                  ".cfi_def_cfa with unsupported offset value"));
1270:       return SFRAME_XLATE_ERR_NOTREPRESENTED;
1271:     }
1272:
1273:   /* Define the current CFA rule to use the provided register and
1274:      offset.  Typically, the CFA rule uses SP/FP based CFA.  However, with
1275:      SFrame V3 specification, if the CFA register is not FP/SP, SFrame FDE type
1276:      SFRAME_FDE_TYPE_FLEX type may be used.
1277:
1278:      GAS uses the hook sframe_support_flex_fde_p () to determine if SFrame FDE
1279:      of type SFRAME_FDE_TYPE_FLEX can be emitted for the specific target.
1280:      Non-SP/FP based CFA may be seen for:
1281:        - AMD64 (e.g., DRAP, stack alignment), or
1282:        - s390x, where this may be seen for (GCC) generated code for static stack
1283:          clash protection.  */
1284:   if (cfi_insn->u.ri.reg != SFRAME_CFA_SP_REG
1285:       && cfi_insn->u.ri.reg != SFRAME_CFA_FP_REG)
1286:     {
1287:       if (!sframe_support_flex_fde_p ())
1288:         {
1289:           as_warn (_("no SFrame FDE emitted; "
1290:                      "non-SP/FP register %u in .cfi_def_cfa"),
1291:                    cfi_insn->u.ri.reg);
1292:           return SFRAME_XLATE_ERR_NOTREPRESENTED;
1293:         }
1294:       else
1295:         xlate_ctx->flex_p = true;
1296:     }
1297:
1298:   sframe_fre_set_cfa_base_reg (cur_fre, cfi_insn->u.ri.reg);
1299:   sframe_fre_set_cfa_offset (cur_fre, cfi_insn->u.ri.offset);
1300:   cur_fre->merge_candidate = false;
1301:   cur_fre->cfa_deref_p = false;
1302:
1303:   return SFRAME_XLATE_OK;
```

## gas/gen-sframe.c:1310–1454

```text
1310: sframe_xlate_do_def_cfa_register (struct sframe_xlate_ctx *xlate_ctx,
1311:                                   const struct cfi_insn_data *cfi_insn)
1312: {
1313:   const struct sframe_row_entry *last_fre = xlate_ctx->last_fre;
1314:   /* Get the scratchpad FRE.  This FRE will eventually get linked in.  */
1315:   struct sframe_row_entry *cur_fre = xlate_ctx->cur_fre;
1316:
1317:   gas_assert (cur_fre);
1318:   /* Define the current CFA rule to use the provided register (but to
1319:      keep the old offset).  However, if the register is not FP/SP,
1320:      skip creating SFrame stack trace info for the function.  */
1321:   if (cfi_insn->u.r != SFRAME_CFA_SP_REG
1322:       && cfi_insn->u.r != SFRAME_CFA_FP_REG)
1323:     {
1324:       if (!sframe_support_flex_fde_p ())
1325:         {
1326:           as_warn (_("no SFrame FDE emitted; "
1327:                      "non-SP/FP register %u in .cfi_def_cfa_register"),
1328:                    cfi_insn->u.ri.reg);
1329:           return SFRAME_XLATE_ERR_NOTREPRESENTED;
1330:         }
1331:       else
1332:         /* Currently, SFRAME_FDE_TYPE_FLEX is generated for AMD64 only.  */
1333:         xlate_ctx->flex_p = true;
1334:     }
1335:
1336:   sframe_fre_set_cfa_base_reg (cur_fre, cfi_insn->u.r);
1337:   if (last_fre)
1338:     sframe_fre_set_cfa_offset (cur_fre, sframe_fre_get_cfa_offset (last_fre));
1339:   cur_fre->cfa_deref_p = false;
1340:
1341:   cur_fre->merge_candidate = false;
1342:
1343:   return SFRAME_XLATE_OK;
1344: }
1345:
1346: /* Translate DW_CFA_def_cfa_offset into SFrame context.
1347:    Return SFRAME_XLATE_OK if success.  */
1348:
1349: static int
1350: sframe_xlate_do_def_cfa_offset (struct sframe_xlate_ctx *xlate_ctx,
1351:                                 const struct cfi_insn_data *cfi_insn)
1352: {
1353:   /* The scratchpad FRE currently being updated with each cfi_insn
1354:      being interpreted.  This FRE eventually gets linked in into the
1355:      list of FREs for the specific function.  */
1356:   struct sframe_row_entry *cur_fre = xlate_ctx->cur_fre;
1357:   unsigned int cur_cfa_reg = sframe_xlate_ctx_get_cur_cfa_reg (xlate_ctx);
1358:
1359:   gas_assert (cur_fre);
1360:   /*  Define the current CFA rule to use the provided offset (but to keep
1361:       the old register).  However, if the old register is not FP/SP,
1362:       skip creating SFrame stack trace info for the function.  */
1363:   if (cur_cfa_reg == SFRAME_CFA_FP_REG || cur_cfa_reg == SFRAME_CFA_SP_REG)
1364:     {
1365:       if (sframe_fre_stack_offset_bound_p (cfi_insn->u.i, true))
1366:         {
1367:           sframe_fre_set_cfa_offset (cur_fre, cfi_insn->u.i);
1368:           cur_fre->merge_candidate = false;
1369:         }
1370:       else
1371:         {
1372:           as_warn (_("no SFrame FDE emitted; "
1373:                      ".cfi_def_cfa_offset with unsupported offset value"));
1374:           return SFRAME_XLATE_ERR_NOTREPRESENTED;
1375:         }
1376:     }
1377:   else
1378:     {
1379:       /* No CFA base register in effect.  Non-SP/FP CFA base register should
1380:          not occur, as sframe_xlate_do_def_cfa[_register] would detect this.  */
1381:       as_warn (_("no SFrame FDE emitted; "
1382:                  ".cfi_def_cfa_offset without CFA base register in effect"));
1383:       return SFRAME_XLATE_ERR_NOTREPRESENTED;
1384:     }
1385:
1386:   return SFRAME_XLATE_OK;
1387: }
1388:
1389: /* Translate DW_CFA_offset into SFrame context.
1390:    Return SFRAME_XLATE_OK if success.  */
1391:
1392: static int
1393: sframe_xlate_do_offset (struct sframe_xlate_ctx *xlate_ctx,
1394:                         const struct cfi_insn_data *cfi_insn)
1395: {
1396:   /* The scratchpad FRE currently being updated with each cfi_insn
1397:      being interpreted.  This FRE eventually gets linked in into the
1398:      list of FREs for the specific function.  */
1399:   struct sframe_row_entry *cur_fre = xlate_ctx->cur_fre;
1400:   gas_assert (cur_fre);
1401:
1402:   /* For ABIs not tracking RA, the return address is expected to be in a
1403:      specific location.  Explicit manourvering to a different offset (than the
1404:      default offset) is non-representable in SFrame, unless flex FDE generation
1405:      is supported for the ABI.  */
1406:   if (!sframe_support_flex_fde_p () && !sframe_ra_tracking_p ()
1407:       && cfi_insn->u.ri.reg == SFRAME_CFA_RA_REG
1408:       && cfi_insn->u.ri.offset != sframe_cfa_ra_offset ())
1409:     {
1410:       as_warn (_("no SFrame FDE emitted; %s register %u in .cfi_offset"),
1411:                sframe_register_name (cfi_insn->u.ri.reg), cfi_insn->u.ri.reg);
1412:       return SFRAME_XLATE_ERR_NOTREPRESENTED;  /* Not represented.  */
1413:     }
1414:
1415:   /* Change the rule for the register indicated by the register number to
1416:      be the specified offset.  */
1417:   /* Ignore SP reg, as it can be recovered from the CFA tracking info.  */
1418:   if (cfi_insn->u.ri.reg == SFRAME_CFA_FP_REG)
1419:     {
1420:       sframe_fre_set_fp_track (cur_fre, cfi_insn->u.ri.offset);
1421:       cur_fre->fp_reg = SFRAME_FRE_REG_INVALID;
1422:       cur_fre->fp_deref_p = true;
1423:       cur_fre->merge_candidate = false;
1424:     }
1425:   /* Either the ABI has enabled RA tracking, in which case we must process the
1426:      DW_CFA_offset opcode for REG_RA like usual.  Or if the ABI has not enabled
1427:      RA tracking, but flex FDE generation is supported, distinguish between
1428:      whether its time to reset the RA tracking state or not.  */
1429:   else if (cfi_insn->u.ri.reg == SFRAME_CFA_RA_REG)
1430:     {
1431:       if (!sframe_ra_tracking_p ()
1432:           && cfi_insn->u.ri.offset == sframe_cfa_ra_offset ())
1433:         {
1434:           /* Reset RA tracking info, if fixed offset.  */
1435:           cur_fre->ra_reg = SFRAME_FRE_REG_INVALID;
1436:           cur_fre->ra_loc = SFRAME_FRE_ELEM_LOC_NONE;
1437:           cur_fre->ra_deref_p = false;
1438:           cur_fre->merge_candidate = false;
1439:         }
1440:       else
1441:         {
1442:           sframe_fre_set_ra_track (cur_fre, cfi_insn->u.ri.offset);
1443:           cur_fre->ra_reg = SFRAME_FRE_REG_INVALID;
1444:           cur_fre->ra_loc = SFRAME_FRE_ELEM_LOC_STACK;
1445:           cur_fre->ra_deref_p = true;
1446:           cur_fre->merge_candidate = false;
1447:
1448:           if (!sframe_ra_tracking_p () && sframe_support_flex_fde_p ())
1449:             xlate_ctx->flex_p = true;
1450:         }
1451:     }
1452:
1453:   /* Skip all other registers.  */
1454:   return SFRAME_XLATE_OK;
```

## gas/gen-sframe.c:1600–1637

```text
1600: sframe_xlate_do_restore (struct sframe_xlate_ctx *xlate_ctx,
1601:                          const struct cfi_insn_data *cfi_insn)
1602: {
1603:   struct sframe_row_entry *cie_fre = xlate_ctx->first_fre;
1604:   /* The scratchpad FRE currently being updated with each cfi_insn
1605:      being interpreted.  This FRE eventually gets linked in into the
1606:      list of FREs for the specific function.  */
1607:   struct sframe_row_entry *cur_fre = xlate_ctx->cur_fre;
1608:
1609:   /* PR gas/33170.  It is valid to have a:
1610:        .cfi_restore N
1611:     even at the entry of a function; in which case cie_fre is not yet setup.
1612:     Point cie_fre to cur_fre, and let the machinery proceed to update
1613:     merge_candidate as usual.  */
1614:   if (cie_fre == NULL)
1615:     cie_fre = cur_fre;
1616:
1617:   /* Change the rule for the indicated register to the rule assigned to
1618:      it by the initial_instructions in the CIE.  SFrame FREs track only CFA
1619:      and FP / RA for backtracing purposes; skip the other .cfi_restore
1620:      directives.  */
1621:   if (cfi_insn->u.r == SFRAME_CFA_FP_REG)
1622:     {
1623:       gas_assert (cur_fre);
1624:       cur_fre->fp_loc = cie_fre->fp_loc;
1625:       cur_fre->fp_offset = cie_fre->fp_offset;
1626:       cur_fre->merge_candidate = false;
1627:     }
1628:   else if (sframe_ra_tracking_p ()
1629:            && cfi_insn->u.r == SFRAME_CFA_RA_REG)
1630:     {
1631:       gas_assert (cur_fre);
1632:       cur_fre->ra_loc = cie_fre->ra_loc;
1633:       cur_fre->ra_offset = cie_fre->ra_offset;
1634:       cur_fre->ra_undefined_p = cie_fre->ra_undefined_p;
1635:       cur_fre->merge_candidate = false;
1636:     }
1637:   return SFRAME_XLATE_OK;
```

## gas/gen-sframe.c:2398–2437

```text
2398:   /* Iterate over the CFIs and create SFrame FREs.  */
2399:   for (cfi_insn = dw_fde->data; cfi_insn; cfi_insn = cfi_insn->next)
2400:     {
2401:       /* Translate each CFI, and buffer the state in translation context.  */
2402:       err = sframe_do_cfi_insn (xlate_ctx, cfi_insn);
2403:       if (err != SFRAME_XLATE_OK)
2404:         {
2405:           /* Skip generating SFrame stack trace info for the function if any
2406:              offending CFI is encountered by sframe_do_cfi_insn ().  Warning
2407:              message already printed by sframe_do_cfi_insn ().  */
2408:           return err; /* Return the error code.  */
2409:         }
2410:     }
2411:
2412:   /* Link in the scratchpad FRE that the last few CFI insns helped create.  */
2413:   if (xlate_ctx->cur_fre)
2414:     {
2415:       sframe_xlate_ctx_add_fre (xlate_ctx, xlate_ctx->cur_fre);
2416:       xlate_ctx->cur_fre = NULL;
2417:     }
2418:   /* Designate the end of the last SFrame FRE.  */
2419:   if (xlate_ctx->last_fre)
2420:     {
2421:       xlate_ctx->last_fre->pc_end
2422:         = get_dw_fde_end_addrS (xlate_ctx->dw_fde);
2423:     }
2424:
2425:   /* Number of FREs must fit uint16_t.  Check now, and do not emit the SFrame
2426:      FDE if it doesnt fit (although, it is not expected to happen for
2427:      real-world, useful programs).  The approach of truncating the FDE and
2428:      emitting multiple SFrame FDEs instead, is not a clearly preferable
2429:      handling either.  Its a divergence from the model where an SFrame FDE
2430:      encodes stack trace data between a .cfi_startproc and .cfi_endproc pair.
2431:      Further, some components (linkers, stack tracers) want to associate the
2432:      Start PC of a function to a known symbol in the file?  */
2433:   if (xlate_ctx->num_xlate_fres > UINT16_MAX)
2434:     {
2435:       as_warn (_("no SFrame FDE emitted; Number of FREs exceeds UINT16_MAX"));
2436:       return SFRAME_XLATE_ERR_NOTREPRESENTED;
2437:     }
```

## gas/gen-sframe.c:2467–2521

```text
2467: static void
2468: create_sframe_all (void)
2469: {
2470:   struct fde_entry *dw_fde = NULL;
2471:   struct sframe_func_entry *sframe_fde = NULL;
2472:
2473:   struct sframe_xlate_ctx *xlate_ctx = sframe_xlate_ctx_alloc ();
2474:
2475:   for (dw_fde = all_fde_data; dw_fde ; dw_fde = dw_fde->next)
2476:     {
2477:       sframe_fde = sframe_fde_alloc ();
2478:       /* Initialize the translation context with information anew.  */
2479:       sframe_xlate_ctx_init (xlate_ctx);
2480:
2481:       /* Process and link SFrame FDEs if no error.  */
2482:       int err = sframe_do_fde (xlate_ctx, dw_fde);
2483:       if (err && get_dw_fde_signal_p (dw_fde))
2484:         {
2485:           sframe_xlate_ctx_cleanup (xlate_ctx);
2486:           xlate_ctx->flex_p = false;
2487:           err = SFRAME_XLATE_OK;
2488:         }
2489:
2490:       if (err)
2491:         {
2492:           sframe_xlate_ctx_cleanup (xlate_ctx);
2493:           sframe_fde_free (sframe_fde);
2494:         }
2495:       else
2496:         {
2497:           /* All done.  Transfer the state from the SFrame translation
2498:              context to the SFrame FDE.  */
2499:           sframe_xlate_ctx_finalize (xlate_ctx, sframe_fde);
2500:           *last_sframe_fde = sframe_fde;
2501:           last_sframe_fde = &sframe_fde->next;
2502:         }
2503:     }
2504:
2505:   XDELETE (xlate_ctx);
2506: }
2507:
2508: void
2509: output_sframe (segT sframe_seg)
2510: {
2511:   (void) sframe_seg;
2512:
2513:   /* Currently only SFRAME_VERSION_3 can be emitted.  */
2514:   gas_assert (flag_gen_sframe_version == GEN_SFRAME_VERSION_3);
2515:   /* Setup the version specific access functions.  */
2516:   sframe_set_version (flag_gen_sframe_version);
2517:
2518:   /* Process all fdes and create SFrame stack trace information.  */
2519:   create_sframe_all ();
2520:
2521:   output_sframe_internal ();
```

## include/sframe.h:148–188

```text
148: typedef struct sframe_preamble
149: {
150:   uint16_t sfp_magic;   /* Magic number (SFRAME_MAGIC).  */
151:   uint8_t sfp_version;  /* Data format version number (SFRAME_VERSION).  */
152:   uint8_t sfp_flags;    /* Flags.  */
153: } ATTRIBUTE_PACKED sframe_preamble;
154:
155: typedef struct sframe_header
156: {
157:   sframe_preamble sfh_preamble;
158:   /* Information about the arch (endianness) and ABI.  */
159:   uint8_t sfh_abi_arch;
160:   /* Offset for the Frame Pointer (FP) from CFA may be fixed for some
161:      ABIs (e.g, in AMD64 when -fno-omit-frame-pointer is used).  When fixed,
162:      this field specifies the fixed stack frame offset and the individual
163:      FREs do not need to track it.  When not fixed, it is set to
164:      SFRAME_CFA_FIXED_FP_INVALID, and the individual FREs may provide
165:      the applicable stack frame offset, if any.  */
166:   int8_t sfh_cfa_fixed_fp_offset;
167:   /* Offset for the Return Address from CFA is fixed for some ABIs
168:      (e.g., AMD64 has it as CFA-8).  When fixed, the header specifies the
169:      fixed stack frame offset and the individual FREs do not track it.  When
170:      not fixed, it is set to SFRAME_CFA_FIXED_RA_INVALID, and individual
171:      FREs provide the applicable stack frame offset, if any.  */
172:   int8_t sfh_cfa_fixed_ra_offset;
173:   /* Number of bytes making up the auxiliary header, if any.
174:      Some ABI/arch, in the future, may use this space for extending the
175:      information in SFrame header.  Auxiliary header is contained in
176:      bytes sequentially following the sframe_header.  */
177:   uint8_t sfh_auxhdr_len;
178:   /* Number of SFrame FDEs in this SFrame section.  */
179:   uint32_t sfh_num_fdes;
180:   /* Number of SFrame Frame Row Entries.  */
181:   uint32_t sfh_num_fres;
182:   /* Number of bytes in the SFrame Frame Row Entry section. */
183:   uint32_t sfh_fre_len;
184:   /* Offset of SFrame Function Descriptor Entry section.  */
185:   uint32_t sfh_fdeoff;
186:   /* Offset of SFrame Frame Row Entry section.  */
187:   uint32_t sfh_freoff;
188: } ATTRIBUTE_PACKED sframe_header;
```

## include/sframe.h:279–319

```text
279: typedef struct sframe_func_desc_idx_v3
280: {
281:   /* Offset to the function start address.  Encoded as a signed offset,
282:      relative to the beginning of the current FDE.  */
283:   int64_t sfdi_func_start_offset;
284:   /* Size of the function in bytes.  */
285:   uint32_t sfdi_func_size;
286:   /* Offset of the first SFrame Frame Row Entry of the function, relative to the
287:      beginning of the SFrame Frame Row Entry sub-section.  */
288:   uint32_t sfdi_func_start_fre_off;
289: } ATTRIBUTE_PACKED sframe_func_desc_idx_v3;
290:
291: typedef struct sframe_func_desc_attr_v3
292: {
293:   /* Number of frame row entries for the function.  */
294:   uint16_t sfda_func_num_fres;
295:   /* Additional information for stack tracing from the function:
296:      - 4-bits: Identify the FRE type used for the function.
297:      - 1-bit: Identify the PC type of the function - mask or inc.
298:      - 1-bit: PAC authorization A/B key (aarch64).
299:      - 1-bits: Unused.
300:      - 1-bit: Signal frame.
301:      -------------------------------------------------------------------------------
302:      | Signal |   Unused    |  PAC auth A/B key (aarch64) |   FDE   |   FRE Type   |
303:      | frame  |             |        Unused (amd64)       | PC Type |              |
304:      -------------------------------------------------------------------------------
305:      8        7             6                             5         4              0     */
306:   uint8_t sfda_func_info;
307:   /* Additional information for stack tracing from the function:
308:      - 5-bits: FDE type.
309:      - 3-bits: Unused.
310:      ------------------------------------------------------------
311:      |                     Unused                 |  FDE Type   |
312:      |                                            |             |
313:      ------------------------------------------------------------
314:      8                7             6             5             0     */
315:   uint8_t sfda_func_info2;
316:   /* Size of the block of repeating insns.  Used for SFrame FDEs of type
317:      SFRAME_V3_FDE_PCTYPE_MASK.  */
318:   uint8_t sfda_func_rep_size;
319: } ATTRIBUTE_PACKED sframe_func_desc_attr_v3;
```

## gas/sframe-opt.c:34–190

```text
34: int
35: sframe_estimate_size_before_relax (fragS *frag)
36: {
37:   offsetT width;
38:   expressionS *exp;
39:   symbolS *widthS;
40:   int ret;
41:
42:   gas_assert (support_sframe_p ());
43:
44:   /* We are dealing with two different kind of fragments here which need
45:      to be fixed up:
46:        - first, FRE start address in each FRE, and
47:        - second, Function info in each FDE (function info stores the FRE type)
48:      The two kind of fragments can be differentiated based on the opcode
49:      of the symbol.  */
50:   exp = symbol_get_value_expression (frag->fr_symbol);
51:   gas_assert ((exp->X_op == O_modulus) || (exp->X_op == O_absent));
52:   /* Fragment for function info in an SFrame FDE will always write
53:      only one byte.  */
54:   if (exp->X_op == O_modulus)
55:     ret = 1;
56:   /* Fragment for the start address in an SFrame FRE may write out
57:      1/2/4 bytes depending on the value of the diff.  */
58:   else
59:     {
60:       /* Get the width expression from the symbol.  */
61:       widthS = exp->X_op_symbol;
62:       width = resolve_symbol_value (widthS);
63:
64:       if (width < (offsetT) SFRAME_FRE_TYPE_ADDR1_LIMIT)
65:         ret = 1;
66:       else if (width < (offsetT) SFRAME_FRE_TYPE_ADDR2_LIMIT)
67:         ret = 2;
68:       else
69:         ret = 4;
70:     }
71:
72:   frag->fr_subtype = (frag->fr_subtype & ~7) | (ret & 7);
73:
74:   return ret;
75: }
76:
77: /* This function relaxes a rs_sframe variant frag based on the current
78:    values of the symbols.  fr_subtype{0:2} is the current length of
79:    the frag.  This returns the change in frag length.  */
80:
81: int
82: sframe_relax_frag (fragS *frag)
83: {
84:   int oldsize, newsize;
85:
86:   gas_assert (support_sframe_p ());
87:
88:   oldsize = frag->fr_subtype & 7;
89:   if (oldsize == 7)
90:     oldsize = -1;
91:   newsize = sframe_estimate_size_before_relax (frag);
92:   return newsize - oldsize;
93: }
94:
95: /* This function converts a rs_sframe variant frag into a normal fill
96:    frag.  This is called after all relaxation has been done.
97:    fr_subtype{0:2} will be the desired length of the frag.  */
98:
99: void
100: sframe_convert_frag (fragS *frag)
101: {
102:   offsetT fsize;
103:   offsetT diff;
104:   offsetT value;
105:
106:   offsetT rest_of_data;
107:   uint8_t fde_pc_type, fre_type;
108:   uint8_t pauth_key;
109:   bool signal_p;
110:
111:   expressionS *exp;
112:   symbolS *dataS;
113:   symbolS *fsizeS, *diffS;
114:
115:   gas_assert (support_sframe_p ());
116:
117:   /* We are dealing with two different kind of fragments here which need
118:      to be fixed up:
119:        - first, FRE start address in each FRE, and
120:        - second, Function info in each FDE (function info stores the FRE type)
121:      The two kind of fragments can be differentiated based on the opcode
122:      of the symbol.  */
123:   exp = symbol_get_value_expression (frag->fr_symbol);
124:   gas_assert ((exp->X_op == O_modulus) || (exp->X_op == O_absent));
125:   /* Fragment for function info in an SFrame FDE.  */
126:   if (exp->X_op == O_modulus)
127:     {
128:       /* Gather the existing value of the rest of the data except
129:          the fre_type.  */
130:       dataS = exp->X_add_symbol;
131:       rest_of_data = (symbol_get_value_expression(dataS))->X_add_number;
132:       fde_pc_type = SFRAME_V3_FDE_PC_TYPE (rest_of_data);
133:       pauth_key = SFRAME_V3_AARCH64_FDE_PAUTH_KEY (rest_of_data);
134:       signal_p = SFRAME_V3_FDE_SIGNAL_P (rest_of_data);
135:       gas_assert (fde_pc_type == SFRAME_V3_FDE_PCTYPE_INC);
136:
137:       /* Calculate the applicable fre_type.  */
138:       fsizeS = exp->X_op_symbol;
139:       fsize = resolve_symbol_value (fsizeS);
140:       if (fsize < (offsetT) SFRAME_FRE_TYPE_ADDR1_LIMIT)
141:         fre_type = SFRAME_FRE_TYPE_ADDR1;
142:       else if (fsize < (offsetT) SFRAME_FRE_TYPE_ADDR2_LIMIT)
143:         fre_type = SFRAME_FRE_TYPE_ADDR2;
144:       else
145:         fre_type = SFRAME_FRE_TYPE_ADDR4;
146:
147:       /* Create the new function info.  */
148:       value = SFRAME_V3_FDE_FUNC_INFO (fde_pc_type, fre_type);
149:       value = SFRAME_V3_FDE_UPDATE_PAUTH_KEY (pauth_key, value);
150:       value = SFRAME_V3_FDE_UPDATE_SIGNAL_P (signal_p, value);
151:
152:       frag->fr_literal[frag->fr_fix] = value;
153:     }
154:   /* Fragment for the start address in an SFrame FRE.  */
155:   else
156:     {
157:       /* Get the fsize expression from the symbol.  */
158:       fsizeS = exp->X_op_symbol;
159:       fsize = resolve_symbol_value (fsizeS);
160:       /* Get the diff expression from the symbol.  */
161:       diffS= exp->X_add_symbol;
162:       diff = resolve_symbol_value (diffS);
163:       value = diff;
164:
165:       switch (frag->fr_subtype & 7)
166:         {
167:         case 1:
168:           gas_assert (fsize < (offsetT) SFRAME_FRE_TYPE_ADDR1_LIMIT);
169:           frag->fr_literal[frag->fr_fix] = diff;
170:           break;
171:         case 2:
172:           gas_assert (fsize < (offsetT) SFRAME_FRE_TYPE_ADDR2_LIMIT);
173:           md_number_to_chars (frag->fr_literal + frag->fr_fix, diff, 2);
174:           break;
175:         case 4:
176:           md_number_to_chars (frag->fr_literal + frag->fr_fix, diff, 4);
177:           break;
178:         default:
179:           abort ();
180:         }
181:     }
182:
183:   frag->fr_fix += frag->fr_subtype & 7;
184:   frag->fr_type = rs_fill;
185:   frag->fr_subtype = 0;
186:   frag->fr_offset = 0;
187:   /* FIXME do this now because we have evaluated and fixed up the fragments
188:      manually ?  */
189:   frag->fr_symbol = 0;
190: }
```
