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

## gas/config/tc-i386.c:7785–7795

```text
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
