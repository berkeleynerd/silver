# Selected GAS/BFD fixed startup source excerpts

Literal LF numbering.

## gas/as.c:459–473

```text
459:   static const char std_shortopts[] =
460:   {
461:     '-', 'J',
462: #ifndef WORKING_DOT_WORD
463:     /* -K is not meaningful if .word is not being hacked.  */
464:     'K',
465: #endif
466:     'L', 'M', 'R', 'W', 'Z', 'a', ':', ':', 'D', 'f', 'g', ':',':', 'I', ':',
467:     'o', ':', 'v', 'w', 'X',
468: #ifdef HAVE_ITBL_CPU
469:     /* New option for extending instruction set (see also --itbl below).  */
470:     't', ':',
471: #endif
472:     '\0'
473:   };
```

## gas/as.c:531–629

```text
531:   static const struct option std_longopts[] =
532:   {
533:     /* Note: commas are placed at the start of the line rather than
534:        the end of the preceding line so that it is simpler to
535:        selectively add and remove lines from this list.  */
536:     {"alternate", no_argument, NULL, OPTION_ALTERNATE}
537:     /* The entry for "a" is here to prevent getopt_long_only() from
538:        considering that -a is an abbreviation for --alternate.  This is
539:        necessary because -a=<FILE> is a valid switch but getopt would
540:        normally reject it since --alternate does not take an argument.  */
541:     ,{"a", optional_argument, NULL, 'a'}
542:     /* Handle -al=<FILE>.  */
543:     ,{"al", optional_argument, NULL, OPTION_AL}
544:     ,{"compress-debug-sections", optional_argument, NULL, OPTION_COMPRESS_DEBUG}
545:     ,{"nocompress-debug-sections", no_argument, NULL, OPTION_NOCOMPRESS_DEBUG}
546:     ,{"debug-prefix-map", required_argument, NULL, OPTION_DEBUG_PREFIX_MAP}
547:     ,{"defsym", required_argument, NULL, OPTION_DEFSYM}
548:     ,{"dump-config", no_argument, NULL, OPTION_DUMPCONFIG}
549:     ,{"emulation", required_argument, NULL, OPTION_EMULATION}
550: #if defined OBJ_ELF || defined OBJ_MAYBE_ELF
551:     ,{"execstack", no_argument, NULL, OPTION_EXECSTACK}
552:     ,{"noexecstack", no_argument, NULL, OPTION_NOEXECSTACK}
553:     ,{"size-check", required_argument, NULL, OPTION_SIZE_CHECK}
554:     ,{"elf-stt-common", required_argument, NULL, OPTION_ELF_STT_COMMON}
555:     ,{"sectname-subst", no_argument, NULL, OPTION_SECTNAME_SUBST}
556:     ,{"generate-missing-build-notes", required_argument, NULL, OPTION_ELF_BUILD_NOTES}
557:     ,{"gsframe", optional_argument, NULL, OPTION_SFRAME}
558:     ,{"gsframe-3", no_argument, NULL, OPTION_SFRAME_3}
559: # if defined (TARGET_USE_SCFI) && defined (TARGET_USE_GINSN)
560:     ,{"scfi", required_argument, NULL, OPTION_SCFI}
561: # endif
562: #endif /* OBJ_ELF || OBJ_MAYBE_ELF.  */
563:     ,{"fatal-warnings", no_argument, NULL, OPTION_WARN_FATAL}
564:     ,{"gdwarf-2", no_argument, NULL, OPTION_GDWARF_2}
565:     ,{"gdwarf-3", no_argument, NULL, OPTION_GDWARF_3}
566:     ,{"gdwarf-4", no_argument, NULL, OPTION_GDWARF_4}
567:     ,{"gdwarf-5", no_argument, NULL, OPTION_GDWARF_5}
568:     /* GCC uses --gdwarf-2 but GAS used to to use --gdwarf2,
569:        so we keep it here for backwards compatibility.  */
570:     ,{"gdwarf2", no_argument, NULL, OPTION_GDWARF_2}
571:     ,{"gdwarf-sections", no_argument, NULL, OPTION_GDWARF_SECTIONS}
572:     ,{"gdwarf-cie-version", required_argument, NULL, OPTION_GDWARF_CIE_VERSION}
573: #if defined (TE_PE) && defined (O_secrel)
574:     ,{"gcodeview", no_argument, NULL, OPTION_GCODEVIEW}
575: #endif
576:     ,{"gen-debug", no_argument, NULL, 'g'}
577:     ,{"gstabs", no_argument, NULL, OPTION_GSTABS}
578:     ,{"gstabs+", no_argument, NULL, OPTION_GSTABS_PLUS}
579:     ,{"hash-size", required_argument, NULL, OPTION_HASH_TABLE_SIZE}
580:     ,{"help", no_argument, NULL, OPTION_HELP}
581: #ifdef HAVE_ITBL_CPU
582:     /* New option for extending instruction set (see also -t above).
583:        The "-t file" or "--itbl file" option extends the basic set of
584:        valid instructions by reading "file", a text file containing a
585:        list of instruction formats.  The additional opcodes and their
586:        formats are added to the built-in set of instructions, and
587:        mnemonics for new registers may also be defined.  */
588:     ,{"itbl", required_argument, NULL, 't'}
589: #endif
590:     /* getopt allows abbreviations, so we do this to stop it from
591:        treating -k as an abbreviation for --keep-locals.  Some
592:        ports use -k to enable PIC assembly.  */
593:     ,{"keep-locals", no_argument, NULL, 'L'}
594:     ,{"keep-locals", no_argument, NULL, 'L'}
595: #ifndef NO_LISTING
596:     ,{"listing-lhs-width", required_argument, NULL, OPTION_LISTING_LHS_WIDTH}
597:     ,{"listing-lhs-width2", required_argument, NULL, OPTION_LISTING_LHS_WIDTH2}
598:     ,{"listing-rhs-width", required_argument, NULL, OPTION_LISTING_RHS_WIDTH}
599:     ,{"listing-cont-lines", required_argument, NULL, OPTION_LISTING_CONT_LINES}
600: #endif
601:     ,{"MD", required_argument, NULL, OPTION_DEPFILE}
602:     ,{"mri", no_argument, NULL, 'M'}
603:     ,{"nocpp", no_argument, NULL, OPTION_NOCPP}
604:     ,{"no-pad-sections", no_argument, NULL, OPTION_NO_PAD_SECTIONS}
605:     ,{"no-info", no_argument, NULL, OPTION_NOINFO}
606:     ,{"no-warn", no_argument, NULL, 'W'}
607:     ,{"reduce-memory-overheads", no_argument, NULL, OPTION_REDUCE_MEMORY_OVERHEADS}
608:     ,{"statistics", no_argument, NULL, OPTION_STATISTICS}
609:     ,{"strip-local-absolute", no_argument, NULL, OPTION_STRIP_LOCAL_ABSOLUTE}
610:     ,{"emit-local-absolute", no_argument, NULL, OPTION_EMIT_LOCAL_ABSOLUTE}
611:     ,{"version", no_argument, NULL, OPTION_VERSION}
612:     ,{"verbose", no_argument, NULL, 'v'}
613:     ,{"target-help", no_argument, NULL, OPTION_TARGET_HELP}
614:     ,{"traditional-format", no_argument, NULL, OPTION_TRADITIONAL_FORMAT}
615:     ,{"info", no_argument, NULL, OPTION_INFO}
616:     ,{"warn", no_argument, NULL, OPTION_WARN}
617:     ,{"multibyte-handling", required_argument, NULL, OPTION_MULTIBYTE_HANDLING}
618:   };
619:
620:   /* Construct the option lists from the standard list and the target
621:      dependent list.  Include space for an extra NULL option and
622:      always NULL terminate.  */
623:   shortopts = concat (std_shortopts, md_shortopts, (char *) NULL);
624:   longopts = (struct option *) xmalloc (sizeof (std_longopts)
625:                                         + md_longopts_size + sizeof (struct option));
626:   memcpy (longopts, std_longopts, sizeof (std_longopts));
627:   memcpy (((char *) longopts) + sizeof (std_longopts), md_longopts, md_longopts_size);
628:   memset (((char *) longopts) + sizeof (std_longopts) + md_longopts_size,
629:           0, sizeof (struct option));
```

## gas/as.c:1325–1341

```text
1325:
1326:   out_file_name = OBJ_DEFAULT_OUTPUT_FILE_NAME;
1327:
1328:   hex_init ();
1329:   if (bfd_init () != BFD_INIT_MAGIC)
1330:     as_fatal (_("libbfd ABI mismatch"));
1331:
1332:   obstack_begin (&notes, chunksize);
1333:   xatexit (free_notes);
1334:
1335:   myname = **argvp;
1336:   xmalloc_set_program_name (myname);
1337:   bfd_set_error_program_name (myname);
1338:
1339:   expandargv (argcp, argvp);
1340:
1341:   init_include_dir ();
```

## gas/as.c:1355–1402

```text
1355: static void
1356: bfd_std_section_init (const char *name)
1357: {
1358:   asection *sec = bfd_make_section_old_way (stdoutput, name);
1359:   gas_assert (BFD_SEND (stdoutput, _new_section_hook, (stdoutput, sec)));
1360:   subseg_new (name, 0);
1361: }
1362:
1363: /* The bulk of gas initialisation.  This is after args are parsed.  */
1364:
1365: static void
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
1379:
1380:   local_symbol_make (".gasversion.", absolute_section,
1381:                      &predefined_address_frag, BFD_VERSION / 10000UL);
1382:
1383:   /* Note: Put new initialisation calls that don't depend on stdoutput
1384:      being open above this point.  stdoutput must be open for anything
1385:      that might use stdoutput objalloc memory, eg. calling bfd_alloc
1386:      or creating global symbols (via bfd_make_empty_symbol).  */
1387:   xatexit (output_file_close);
1388:   output_file_create (out_file_name);
1389:   gas_assert (stdoutput != 0);
1390:
1391:   /* Must be called before output_file_close.  xexit calls the xatexit
1392:      list in reverse order.  */
1393:   if (flag_print_statistics)
1394:     xatexit (dump_statistics);
1395:
1396:   dot_symbol_init ();
1397:
1398: #ifdef tc_init_after_args
1399:   tc_init_after_args ();
1400: #endif
1401:
1402:   itbl_init ();
```

## gas/config/tc-i386.c:17204–17211

```text
17204: const char md_shortopts[] =
17205: #ifdef OBJ_ELF
17206:   "kVQ:"
17207: # ifdef TE_SOLARIS
17208:   "s"
17209: # endif
17210: #endif
17211:   "qnO::";
```

## gas/config/tc-i386.c:17250–17300

```text
17250: const struct option md_longopts[] =
17251: {
17252:   {"32", no_argument, NULL, OPTION_32},
17253: #if (defined (OBJ_ELF) || defined (TE_PE) || defined (OBJ_MACH_O)) \
17254:     && defined (BFD64)
17255:   {"64", no_argument, NULL, OPTION_64},
17256: #endif
17257: #ifdef OBJ_ELF
17258: # ifdef BFD64
17259:   {"x32", no_argument, NULL, OPTION_X32},
17260: # endif
17261:   {"mshared", no_argument, NULL, OPTION_MSHARED},
17262:   {"mx86-used-note", required_argument, NULL, OPTION_X86_USED_NOTE},
17263: #endif
17264:   {"divide", no_argument, NULL, OPTION_DIVIDE},
17265:   {"march", required_argument, NULL, OPTION_MARCH},
17266:   {"mtune", required_argument, NULL, OPTION_MTUNE},
17267:   {"mmnemonic", required_argument, NULL, OPTION_MMNEMONIC},
17268:   {"msyntax", required_argument, NULL, OPTION_MSYNTAX},
17269:   {"mindex-reg", no_argument, NULL, OPTION_MINDEX_REG},
17270:   {"mnaked-reg", no_argument, NULL, OPTION_MNAKED_REG},
17271:   {"msse2avx", no_argument, NULL, OPTION_MSSE2AVX},
17272:   {"muse-unaligned-vector-move", no_argument, NULL, OPTION_MUSE_UNALIGNED_VECTOR_MOVE},
17273:   {"msse-check", required_argument, NULL, OPTION_MSSE_CHECK},
17274:   {"moperand-check", required_argument, NULL, OPTION_MOPERAND_CHECK},
17275:   {"mavxscalar", required_argument, NULL, OPTION_MAVXSCALAR},
17276:   {"mvexwig", required_argument, NULL, OPTION_MVEXWIG},
17277:   {"madd-bnd-prefix", no_argument, NULL, OPTION_MADD_BND_PREFIX},
17278:   {"mevexlig", required_argument, NULL, OPTION_MEVEXLIG},
17279:   {"mevexwig", required_argument, NULL, OPTION_MEVEXWIG},
17280: # if defined (TE_PE) || defined (TE_PEP)
17281:   {"mbig-obj", no_argument, NULL, OPTION_MBIG_OBJ},
17282: #endif
17283:   {"momit-lock-prefix", required_argument, NULL, OPTION_MOMIT_LOCK_PREFIX},
17284:   {"mfence-as-lock-add", required_argument, NULL, OPTION_MFENCE_AS_LOCK_ADD},
17285:   {"mrelax-relocations", required_argument, NULL, OPTION_MRELAX_RELOCATIONS},
17286:   {"mevexrcig", required_argument, NULL, OPTION_MEVEXRCIG},
17287:   {"malign-branch-boundary", required_argument, NULL, OPTION_MALIGN_BRANCH_BOUNDARY},
17288:   {"malign-branch-prefix-size", required_argument, NULL, OPTION_MALIGN_BRANCH_PREFIX_SIZE},
17289:   {"malign-branch", required_argument, NULL, OPTION_MALIGN_BRANCH},
17290:   {"mbranches-within-32B-boundaries", no_argument, NULL, OPTION_MBRANCHES_WITH_32B_BOUNDARIES},
17291:   {"mlfence-after-load", required_argument, NULL, OPTION_MLFENCE_AFTER_LOAD},
17292:   {"mlfence-before-indirect-branch", required_argument, NULL,
17293:    OPTION_MLFENCE_BEFORE_INDIRECT_BRANCH},
17294:   {"mlfence-before-ret", required_argument, NULL, OPTION_MLFENCE_BEFORE_RET},
17295:   {"mamd64", no_argument, NULL, OPTION_MAMD64},
17296:   {"mintel64", no_argument, NULL, OPTION_MINTEL64},
17297:   {"mtls-check", required_argument, NULL, OPTION_MTLS_CHECK},
17298:   {NULL, no_argument, NULL, 0}
17299: };
17300: const size_t md_longopts_size = sizeof (md_longopts);
```

## gas/read.c:253–302

```text
253: read_begin (void)
254: {
255:   const char *p;
256:
257:   pobegin ();
258:   obj_read_begin_hook ();
259:
260:   obstack_begin (&cond_obstack, chunksize);
261:
262: #ifndef tc_line_separator_chars
263: #define tc_line_separator_chars line_separator_chars
264: #endif
265:   /* Use machine dependent syntax.  */
266:   for (p = tc_line_separator_chars; *p; p++)
267:     lex_type[(unsigned char) *p] = LEX_EOS;
268:
269:   if (flag_mri)
270:     lex_type['?'] = LEX_BEGIN_NAME | LEX_NAME;
271:
272:   stabs_begin ();
273:
274: #ifndef WORKING_DOT_WORD
275:   broken_words = NULL;
276:   new_broken_words = 0;
277: #endif
278:
279:   abs_section_offset = 0;
280:
281:   line_label = NULL;
282:   mri_common_symbol = NULL;
283:   mri_pending_align = 0;
284:
285:   current_name = NULL;
286:   current_label = NULL;
287:
288: #ifndef NO_LISTING
289: #ifdef OBJ_ELF
290:   dwarf_file = 0;
291:   dwarf_line = -1;
292:   dwarf_file_string = 0;
293: #endif
294: #endif
295:
296: #ifdef HANDLE_BUNDLE
297:   bundle_align_p2 = 0;
298:   bundle_lock_frag = NULL;
299:   bundle_lock_frchain = NULL;
300:   bundle_lock_depth = 0;
301: #endif
302: }
```

## gas/read.c:2012–2044

```text
2012: s_file_string (char *file)
2013: {
2014: #ifdef LISTING
2015:   if (listing)
2016:     listing_source_file (file);
2017: #endif
2018:   register_dependency (file);
2019: #ifdef obj_app_file
2020:   obj_app_file (file);
2021: #endif
2022: }
2023:
2024: void
2025: s_file (int ignore ATTRIBUTE_UNUSED)
2026: {
2027:   char *s;
2028:   int length;
2029:
2030:   /* Some assemblers tolerate immediately following '"'.  */
2031:   if ((s = demand_copy_string (&length)) != 0)
2032:     {
2033:       new_logical_line_flags (s, -1, 1);
2034:
2035:       /* In MRI mode, the preprocessor may have inserted an extraneous
2036:          backquote.  */
2037:       if (flag_m68k_mri
2038:           && *input_line_pointer == '\''
2039:           && is_end_of_stmt (input_line_pointer[1]))
2040:         ++input_line_pointer;
2041:
2042:       demand_empty_rest_of_line ();
2043:       s_file_string (s);
2044:     }
```

## gas/read.c:6598–6603

```text
6598: init_include_dir (void)
6599: {
6600:   include_dirs = XNEWVEC (const char *, 1);
6601:   include_dirs[0] = ".";        /* Current dir.  */
6602:   include_dir_count = 1;
6603:   include_dir_maxlen = 1;
```

## gas/depend.c:23–74

```text
23:
24: /* The file to write to, or NULL if no dependencies being kept.  */
25: static char * dep_file = NULL;
26:
27: struct dependency
28: {
29:   char * file;
30:   struct dependency * next;
31: };
32:
33: /* All the files we depend on.  */
34: static struct dependency * dep_chain = NULL;
35:
36: /* Current column in output file.  */
37: static int column = 0;
38:
39: static int quote_string_for_make (FILE *, const char *);
40: static void wrap_output (FILE *, const char *, int);
41:
42: /* Number of columns allowable.  */
43: #define MAX_COLUMNS 72
44:
45: /* Start saving dependencies, to be written to FILENAME.  If this is
46:    never called, then dependency tracking is simply skipped.  */
47:
48: void
49: start_dependencies (char *filename)
50: {
51:   dep_file = filename;
52: }
53:
54: /* Noticed a new filename, so try to register it.  */
55:
56: void
57: register_dependency (const char *filename)
58: {
59:   struct dependency *dep;
60:
61:   if (dep_file == NULL)
62:     return;
63:
64:   for (dep = dep_chain; dep != NULL; dep = dep->next)
65:     {
66:       if (!filename_cmp (filename, dep->file))
67:         return;
68:     }
69:
70:   dep = XNEW (struct dependency);
71:   dep->file = xstrdup (filename);
72:   dep->next = dep_chain;
73:   dep_chain = dep;
74: }
```

## gas/stabs.c:661–676

```text
661: stabs_begin (void)
662: {
663:   current_function_label = NULL;
664:   last_asm_file = NULL;
665:   file_label_count = 0;
666:   line_label_count = 0;
667:   prev_lineno = -1u;
668:   prev_line_file = NULL;
669:   void_emitted_p = false;
670:   endfunc_label_count = 0;
671: }
672:
673: void
674: stabs_end (void)
675: {
676:   free ((char *) current_function_label);
```

## gas/dwarf2dbg.c:1166–1180

```text
1166: dwarf2_directive_filename (void)
1167: {
1168:   bool with_md5 = false;
1169:   valueT num;
1170:   char *filename;
1171:   const char * dirname = NULL;
1172:   int filename_len;
1173:
1174:   /* Continue to accept a bare string and pass it off.  */
1175:   SKIP_WHITESPACE ();
1176:   if (*input_line_pointer == '"')
1177:     {
1178:       s_file (0);
1179:       return NULL;
1180:     }
```

## gas/dwarf2dbg.c:3082–3118

```text
3082: dwarf2_init (void)
3083: {
3084:   all_segs = NULL;
3085:   last_seg_ptr = &all_segs;
3086:   files = NULL;
3087:   files_in_use = 0;
3088:   files_allocated = 0;
3089:   dirs = NULL;
3090:   dirs_in_use = 0;
3091:   dirs_allocated = 0;
3092:   dwarf2_loc_directive_seen = false;
3093:   dwarf2_any_loc_directive_seen = false;
3094:   dwarf2_loc_mark_labels = false;
3095:   current.filenum = 1;
3096:   current.line = 1;
3097:   current.column = 0;
3098:   current.isa = 0;
3099:   current.flags = DWARF2_LINE_DEFAULT_IS_STMT ? DWARF2_FLAG_IS_STMT : 0;
3100:   current.discriminator = 0;
3101:   current.u.view = NULL;
3102:   force_reset_view = NULL;
3103:   view_assert_failed = NULL;
3104:   dw2_line = -1;
3105:   dw2_filename = NULL;
3106:   label_num = 0;
3107:   last_used = -1;
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

## gas/ehopt.c:584–589

```text
584: void
585: eh_begin (void)
586: {
587:   memset (&frame, 0, sizeof (frame));
588: }
589:
```

## gas/input-scrub.c:243–275

```text
243: input_scrub_begin (void)
244: {
245:   know (strlen (BEFORE_STRING) == BEFORE_SIZE);
246:   know (strlen (AFTER_STRING) == AFTER_SIZE
247:         || (AFTER_STRING[0] == '\0' && AFTER_SIZE == 1));
248:
249:   physical_input_file = NULL;   /* No file read yet.  */
250:   next_saved_file = NULL;       /* At EOF, don't pop to any other file */
251:   macro_nest = 0;
252:   input_scrub_reinit ();
253:   do_scrub_begin (flag_m68k_mri);
254: }
255:
256: void
257: input_scrub_end (void)
258: {
259:   while (next_saved_file != NULL)
260:     input_scrub_pop (next_saved_file);
261:   input_scrub_free ();
262: }
263:
264: /* Start reading input from a new file.
265:    Return start of caller's part of buffer.  */
266:
267: char *
268: input_scrub_new_file (const char *filename)
269: {
270:   input_file_open (filename, !flag_no_comments);
271:   physical_input_file = filename[0] ? filename : _("{standard input}");
272:   physical_input_line = 0;
273:
274:   partial_size = 0;
275:   return (buffer_start + BEFORE_SIZE);
```

## gas/symbols.c:2043–2064

```text
2043:
2044: #define FB_LABEL_SPECIAL (10)
2045:
2046: typedef unsigned int fb_ent;
2047: static fb_ent fb_low_counter[FB_LABEL_SPECIAL];
2048: static fb_ent *fb_labels;
2049: static fb_ent *fb_label_instances;
2050: static size_t fb_label_count;
2051: static size_t fb_label_max;
2052:
2053: /* This must be more than FB_LABEL_SPECIAL.  */
2054: #define FB_LABEL_BUMP_BY (FB_LABEL_SPECIAL + 6)
2055:
2056: static void
2057: fb_label_init (void)
2058: {
2059:   memset (fb_low_counter, 0, sizeof (fb_low_counter));
2060: }
2061:
2062: /* Add one to the instance number of this fb label.  */
2063:
2064: void
```

## libiberty/xatexit.c:45–85

```text
45: /* Pointer to function run by xexit.  */
46: extern void (*_xexit_cleanup) (void);
47:
48: #define XATEXIT_SIZE 32
49:
50: struct xatexit {
51:         struct  xatexit *next;          /* next in list */
52:         int     ind;                    /* next index in this table */
53:         void    (*fns[XATEXIT_SIZE]) (void);    /* the table itself */
54: };
55:
56: /* Allocate one struct statically to guarantee that we can register
57:    at least a few handlers.  */
58: static struct xatexit xatexit_first;
59:
60: /* Points to head of LIFO stack.  */
61: static struct xatexit *xatexit_head = &xatexit_first;
62:
63: /* Register function FN to be run by xexit.
64:    Return 0 if successful, -1 if not.  */
65:
66: int
67: xatexit (void (*fn) (void))
68: {
69:   register struct xatexit *p;
70:
71:   /* Tell xexit to call xatexit_cleanup.  */
72:   if (!_xexit_cleanup)
73:     _xexit_cleanup = xatexit_cleanup;
74:
75:   p = xatexit_head;
76:   if (p->ind >= XATEXIT_SIZE)
77:     {
78:       if ((p = (struct xatexit *) malloc (sizeof *p)) == NULL)
79:         return -1;
80:       p->ind = 0;
81:       p->next = xatexit_head;
82:       xatexit_head = p;
83:     }
84:   p->fns[p->ind++] = fn;
85:   return 0;
```

## libiberty/concat.c:104–121

```text
104: char *
105: concat_copy (char *dst, const char *first, ...)
106: {
107:   char *save_dst;
108:   va_list args;
109:
110:   va_start (args, first);
111:   vconcat_copy (dst, first, args);
112:   save_dst = dst; /* With K&R C, dst goes out of scope here.  */
113:   va_end (args);
114:
115:   return save_dst;
116: }
117:
118: #ifdef __cplusplus
119: extern "C" {
120: #endif /* __cplusplus */
121: char *libiberty_concat_ptr;
```

## include/getopt.h:81–93

```text
81: struct option
82: {
83: #if defined (__STDC__) && __STDC__
84:   const char *name;
85: #else
86:   char *name;
87: #endif
88:   /* has_arg can't be an enum because some compilers complain about
89:      type mismatches in all the code that assumes it is an int.  */
90:   int has_arg;
91:   int *flag;
92:   int val;
93: };
```

## bfd/opncls.c:50–99

```text
50: static unsigned int bfd_id_counter = 0;
51:
52: /* fdopen is a loser -- we should use stdio exclusively.  Unfortunately
53:    if we do that we can't use fcntl.  */
54:
55: /*
56: INTERNAL_FUNCTION
57:         _bfd_new_bfd
58:
59: SYNOPSIS
60:         bfd *_bfd_new_bfd (void);
61:
62: DESCRIPTION
63:         Return a new BFD.  All BFD's are allocated through this routine.
64: */
65:
66: bfd *
67: _bfd_new_bfd (void)
68: {
69:   bfd *nbfd;
70:
71:   nbfd = (bfd *) bfd_zmalloc (sizeof (bfd));
72:   if (nbfd == NULL)
73:     return NULL;
74:
75:   if (!bfd_lock ())
76:     goto loser;
77:   nbfd->id = bfd_id_counter++;
78:   if (!bfd_unlock ())
79:     goto loser;
80:
81:   nbfd->memory = objalloc_create ();
82:   if (nbfd->memory == NULL)
83:     {
84:       bfd_set_error (bfd_error_no_memory);
85:       goto loser;
86:     }
87:
88:   nbfd->arch_info = &bfd_default_arch_struct;
89:
90:   if (!bfd_hash_table_init_n (& nbfd->section_htab, bfd_section_hash_newfunc,
91:                               sizeof (struct section_hash_entry), 13))
92:     {
93:       objalloc_free (nbfd->memory);
94:       goto loser;
95:     }
96:
97:   nbfd->archive_plugin_fd = -1;
98:   return nbfd;
99:
```

## bfd/opncls.c:729–765

```text
729: bfd_openw (const char *filename, const char *target)
730: {
731:   bfd *nbfd;
732:   const bfd_target *target_vec;
733:
734:   /* nbfd has to point to head of malloc'ed block so that bfd_close may
735:      reclaim it correctly.  */
736:   nbfd = _bfd_new_bfd ();
737:   if (nbfd == NULL)
738:     return NULL;
739:
740:   target_vec = bfd_find_target (target, nbfd);
741:   if (target_vec == NULL)
742:     {
743:       _bfd_delete_bfd (nbfd);
744:       return NULL;
745:     }
746:
747:   /* PR 11983: Do not cache the original filename, but
748:      rather make a copy - the original might go away.  */
749:   if (!bfd_set_filename (nbfd, filename))
750:     {
751:       _bfd_delete_bfd (nbfd);
752:       return NULL;
753:     }
754:   nbfd->direction = write_direction;
755:
756:   if (bfd_open_file (nbfd) == NULL)
757:     {
758:       /* File not writeable, etc.  */
759:       bfd_set_error (bfd_error_system_call);
760:       _bfd_delete_bfd (nbfd);
761:       return NULL;
762:   }
763:
764:   return nbfd;
765: }
```

## bfd/opncls.c:1985–2010

```text
1985: bfd_set_filename (bfd *abfd, const char *filename)
1986: {
1987:   size_t len = strlen (filename) + 1;
1988:   char *n = bfd_alloc (abfd, len);
1989:
1990:   if (n == NULL)
1991:     return NULL;
1992:
1993:   if (abfd->filename != NULL)
1994:     {
1995:       /* PR 29389.  If we attempt to rename a file that has been closed due
1996:          to caching, then we will not be able to reopen it later on.  */
1997:       if (abfd->iostream == NULL && (abfd->flags & BFD_CLOSED_BY_CACHE))
1998:         {
1999:           bfd_set_error (bfd_error_invalid_operation);
2000:           return NULL;
2001:         }
2002:
2003:       /* Similarly if we attempt to close a renamed file because the
2004:          cache is now full, we will not be able to reopen it later on.  */
2005:       if (abfd->iostream != NULL)
2006:         abfd->cacheable = 0;
2007:     }
2008:
2009:   memcpy (n, filename, len);
2010:   abfd->filename = n;
```

## bfd/bfd-in2.h:337–374

```text
337: struct bfd_hash_entry
338: {
339:   /* Next entry for this hash code.  */
340:   struct bfd_hash_entry *next;
341:   /* String being hashed.  */
342:   const char *string;
343:   /* Hash code.  This is the full hash code, not the index into the
344:      table.  */
345:   unsigned long hash;
346: };
347:
348: /* A hash table.  */
349:
350: struct bfd_hash_table
351: {
352:   /* The hash array.  */
353:   struct bfd_hash_entry **table;
354:   /* A function used to create new elements in the hash table.  The
355:      first entry is itself a pointer to an element.  When this
356:      function is first invoked, this pointer will be NULL.  However,
357:      having the pointer permits a hierarchy of method functions to be
358:      built each of which calls the function in the superclass.  Thus
359:      each function should be written to allocate a new block of memory
360:      only if the argument is NULL.  */
361:   struct bfd_hash_entry *(*newfunc)
362:     (struct bfd_hash_entry *, struct bfd_hash_table *, const char *);
363:   /* An objalloc for this hash table.  This is a struct objalloc *,
364:      but we use void * to avoid requiring the inclusion of objalloc.h.  */
365:   void *memory;
366:   /* The number of slots in the hash table.  */
367:   unsigned int size;
368:   /* The number of entries in the hash table.  */
369:   unsigned int count;
370:   /* The size of elements.  */
371:   unsigned int entsize;
372:   /* If non-zero, don't grow the hash table.  */
373:   unsigned int frozen:1;
374: };
```

## bfd/bfd-in2.h:435–453

```text
435: typedef struct bfd_section
436: {
437:   /* The name of the section; the name isn't a copy, the pointer is
438:      the same as that passed to bfd_make_section.  */
439:   const char *name;
440:
441:   /* The next section in the list belonging to the BFD, or NULL.  */
442:   struct bfd_section *next;
443:
444:   /* The previous section in the list belonging to the BFD, or NULL.  */
445:   struct bfd_section *prev;
446:
447:   /* A unique sequence number.  */
448:   unsigned int id;
449:
450:   /* A unique section number which can be used by assembler to
451:      distinguish different sections with the same section name.  */
452:   unsigned int section_id;
453:
```

## bfd/bfd-in2.h:687–849

```text
687: #define SEC_INFO_TYPE_NONE      0
688: #define SEC_INFO_TYPE_STABS     1
689: #define SEC_INFO_TYPE_MERGE     2
690: #define SEC_INFO_TYPE_EH_FRAME  3
691: #define SEC_INFO_TYPE_JUST_SYMS 4
692: #define SEC_INFO_TYPE_TARGET    5
693: #define SEC_INFO_TYPE_EH_FRAME_ENTRY 6
694: #define SEC_INFO_TYPE_SFRAME  7
695:
696:   /* Nonzero if this section uses RELA relocations, rather than REL.  */
697:   unsigned int use_rela_p:1;
698:
699:   /* Nonzero if section contents are mmapped.  */
700:   unsigned int mmapped_p:1;
701:
702:   /* Nonzero if section contents should not be freed.  */
703:   unsigned int alloced:1;
704:
705:   /* Bits used by various backends.  The generic code doesn't touch
706:      these fields.  */
707:
708:   unsigned int sec_flg0:1;
709:   unsigned int sec_flg1:1;
710:   unsigned int sec_flg2:1;
711:   unsigned int sec_flg3:1;
712:   unsigned int sec_flg4:1;
713:   unsigned int sec_flg5:1;
714:
715:   /* End of internal packed boolean fields.  */
716:
717:   /*  The virtual memory address of the section - where it will be
718:       at run time.  The symbols are relocated against this.  The
719:       user_set_vma flag is maintained by bfd; if it's not set, the
720:       backend can assign addresses (for example, in <<a.out>>, where
721:       the default address for <<.data>> is dependent on the specific
722:       target and various flags).  */
723:   bfd_vma vma;
724:
725:   /*  The load address of the section - where it would be in a
726:       rom image; really only used for writing section header
727:       information.  */
728:   bfd_vma lma;
729:
730:   /* The size of the section in *octets*, as it will be output.
731:      Contains a value even if the section has no contents (e.g., the
732:      size of <<.bss>>).  */
733:   bfd_size_type size;
734:
735:   /* For input sections, the original size on disk of the section, in
736:      octets.  This field should be set for any section whose size is
737:      changed by linker relaxation.  It is required for sections where
738:      the linker relaxation scheme doesn't cache altered section and
739:      reloc contents (stabs, eh_frame, SEC_MERGE, some coff relaxing
740:      targets), and thus the original size needs to be kept to read the
741:      section multiple times.  For output sections, rawsize holds the
742:      section size calculated on a previous linker relaxation pass.  */
743:   bfd_size_type rawsize;
744:
745:   /* The compressed size of the section in octets.  */
746:   bfd_size_type compressed_size;
747:
748:   /* If this section is going to be output, then this value is the
749:      offset in *bytes* into the output section of the first byte in the
750:      input section (byte ==> smallest addressable unit on the
751:      target).  In most cases, if this was going to start at the
752:      100th octet (8-bit quantity) in the output section, this value
753:      would be 100.  However, if the target byte size is 16 bits
754:      (bfd_octets_per_byte is "2"), this value would be 50.  */
755:   bfd_vma output_offset;
756:
757:   /* The output section through which to map on output.  */
758:   struct bfd_section *output_section;
759:
760:   /* If an input section, a pointer to a vector of relocation
761:      records for the data in this section.  */
762:   struct reloc_cache_entry *relocation;
763:
764:   /* If an output section, a pointer to a vector of pointers to
765:      relocation records for the data in this section.  */
766:   struct reloc_cache_entry **orelocation;
767:
768:   /* The number of relocation records in one of the above.  */
769:   unsigned reloc_count;
770:
771:   /* The alignment requirement of the section, as an exponent of 2 -
772:      e.g., 3 aligns to 2^3 (or 8).  */
773:   unsigned int alignment_power;
774:
775:   /* Information below is back end specific - and not always used
776:      or updated.  */
777:
778:   /* File position of section data.  */
779:   file_ptr filepos;
780:
781:   /* File position of relocation info.  */
782:   file_ptr rel_filepos;
783:
784:   /* File position of line data.  */
785:   file_ptr line_filepos;
786:
787:   /* Pointer to data for applications.  */
788:   void *userdata;
789:
790:   /* If the SEC_IN_MEMORY flag is set, this points to the actual
791:      contents.  */
792:   bfd_byte *contents;
793:
794:   /* Attached line number information.  */
795:   alent *lineno;
796:
797:   /* Number of line number records.  */
798:   unsigned int lineno_count;
799:
800:   /* Entity size for merging purposes.  */
801:   unsigned int entsize;
802:
803:   /* Points to the kept section if this section is a link-once section,
804:      and is discarded.  */
805:   struct bfd_section *kept_section;
806:
807:   /* When a section is being output, this value changes as more
808:      linenumbers are written out.  */
809:   file_ptr moving_line_filepos;
810:
811:   /* What the section number is in the target world.  */
812:   int target_index;
813:
814:   void *used_by_bfd;
815:
816:   /* If this is a constructor section then here is a list of the
817:      relocations created to relocate items within it.  */
818:   struct relent_chain *constructor_chain;
819:
820:   /* The BFD which owns the section.  */
821:   bfd *owner;
822:
823:   /* A symbol which points at this section only.  */
824:   struct bfd_symbol *symbol;
825:
826:   /* Early in the link process, map_head and map_tail are used to build
827:      a list of input sections attached to an output section.  Later,
828:      output sections use these fields for a list of bfd_link_order
829:      structs.  The linked_to_symbol_name field is for ELF assembler
830:      internal use.  */
831:   union {
832:     struct bfd_link_order *link_order;
833:     struct bfd_section *s;
834:     const char *linked_to_symbol_name;
835:   } map_head, map_tail;
836:
837:   /* Points to the output section this section is already assigned to,
838:      if any.  This is used when support for non-contiguous memory
839:      regions is enabled.  */
840:   struct bfd_section *already_assigned;
841:
842:   /* A pointer used for various section optimizations.  sec_info_type
843:      qualifies which one it is.  */
844:   void *sec_info;
845:
846:   /* Explicitly specified section type, if non-zero.  */
847:   unsigned int type;
848:
849: } asection;
```

## bfd/bfd-in2.h:1947–1976

```text
1947: struct bfd
1948: {
1949:   /* The filename the application opened the BFD with.  */
1950:   const char *filename;
1951:
1952:   /* A pointer to the target jump table.  */
1953:   const struct bfd_target *xvec;
1954:
1955:   /* The IOSTREAM, and corresponding IO vector that provide access
1956:      to the file backing the BFD.  */
1957:   void *iostream;
1958:   const struct bfd_iovec *iovec;
1959:
1960:   /* The caching routines use these to maintain a
1961:      least-recently-used list of BFDs.  */
1962:   struct bfd *lru_prev, *lru_next;
1963:
1964:   /* Track current file position (or current buffer offset for
1965:      in-memory BFDs).  When a file is closed by the caching routines,
1966:      BFD retains state information on the file here.  */
1967:   ufile_ptr where;
1968:
1969:   /* File modified time, if mtime_set is TRUE.  */
1970:   long mtime;
1971:
1972:   /* A unique identifier of the BFD  */
1973:   unsigned int id;
1974:
1975:   /* Format_specific flags.  */
1976:   flagword flags;
```

## bfd/bfd-in2.h:2080–2288

```text
2080:   /* The format which belongs to the BFD. (object, core, etc.)  */
2081:   ENUM_BITFIELD (bfd_format) format : 3;
2082:
2083:   /* The direction with which the BFD was opened.  */
2084:   ENUM_BITFIELD (bfd_direction) direction : 2;
2085:
2086:   /* POSIX.1-2017 (IEEE Std 1003.1) says of fopen : "When a file is
2087:      opened with update mode ('+' as the second or third character in
2088:      the mode argument), both input and output may be performed on
2089:      the associated stream.  However, the application shall ensure
2090:      that output is not directly followed by input without an
2091:      intervening call to fflush() or to a file positioning function
2092:      (fseek(), fsetpos(), or rewind()), and input is not directly
2093:      followed by output without an intervening call to a file
2094:      positioning function, unless the input operation encounters
2095:      end-of-file."
2096:      This field tracks the last IO operation, so that bfd can insert
2097:      a seek when IO direction changes.  */
2098:   ENUM_BITFIELD (bfd_last_io) last_io : 2;
2099:
2100:   /* Is the file descriptor being cached?  That is, can it be closed as
2101:      needed, and re-opened when accessed later?  */
2102:   unsigned int cacheable : 1;
2103:
2104:   /* Marks whether there was a default target specified when the
2105:      BFD was opened. This is used to select which matching algorithm
2106:      to use to choose the back end.  */
2107:   unsigned int target_defaulted : 1;
2108:
2109:   /* ... and here: (``once'' means at least once).  */
2110:   unsigned int opened_once : 1;
2111:
2112:   /* Set if we have a locally maintained mtime value, rather than
2113:      getting it from the file each time.  */
2114:   unsigned int mtime_set : 1;
2115:
2116:   /* Flag set if symbols from this BFD should not be exported.  */
2117:   unsigned int no_export : 1;
2118:
2119:   /* Remember when output has begun, to stop strange things
2120:      from happening.  */
2121:   unsigned int output_has_begun : 1;
2122:
2123:   /* Have archive map.  */
2124:   unsigned int has_armap : 1;
2125:
2126:   /* Set if this is a thin archive.  */
2127:   unsigned int is_thin_archive : 1;
2128:
2129:   /* Set if this archive should not cache element positions.  */
2130:   unsigned int no_element_cache : 1;
2131:
2132:   /* Set if only required symbols should be added in the link hash table for
2133:      this object.  Used by VMS linkers.  */
2134:   unsigned int selective_search : 1;
2135:
2136:   /* Set if this is the linker output BFD.  */
2137:   unsigned int is_linker_output : 1;
2138:
2139:   /* Set if this is the linker input BFD.  */
2140:   unsigned int is_linker_input : 1;
2141:
2142:   /* If this is an input for a compiler plug-in library.  */
2143:   ENUM_BITFIELD (bfd_plugin_format) plugin_format : 2;
2144:
2145:   /* Set if this is a plugin output file.  */
2146:   unsigned int lto_output : 1;
2147:
2148:   /* Do not attempt to modify this file.  Set when detecting errors
2149:      that BFD is not prepared to handle for objcopy/strip.  */
2150:   unsigned int read_only : 1;
2151:
2152:   /* LTO object type.  */
2153:   ENUM_BITFIELD (bfd_lto_object_type) lto_type : 3;
2154:
2155:   /* Set if this BFD is currently being processed by
2156:      bfd_check_format_matches.  This is checked by the cache to
2157:      avoid closing the BFD in this case.  This should only be
2158:      examined or modified while the BFD lock is held.  */
2159:   unsigned int in_format_matches : 1;
2160:
2161:   /* Set to dummy BFD created when claimed by a compiler plug-in
2162:      library.  */
2163:   bfd *plugin_dummy_bfd;
2164:
2165:   /* The offset of this bfd in the file, typically 0 if it is not
2166:      contained in an archive.  */
2167:   ufile_ptr origin;
2168:
2169:   /* The origin in the archive of the proxy entry.  This will
2170:      normally be the same as origin, except for thin archives,
2171:      when it will contain the current offset of the proxy in the
2172:      thin archive rather than the offset of the bfd in its actual
2173:      container.  */
2174:   ufile_ptr proxy_origin;
2175:
2176:   /* A hash table for section names.  */
2177:   struct bfd_hash_table section_htab;
2178:
2179:   /* Pointer to linked list of sections.  */
2180:   struct bfd_section *sections;
2181:
2182:   /* The last section on the section list.  */
2183:   struct bfd_section *section_last;
2184:
2185:   /* The object-only section on the section list.  */
2186:   struct bfd_section *object_only_section;
2187:
2188:   /* The number of sections.  */
2189:   unsigned int section_count;
2190:
2191:   /* The archive plugin file descriptor.  */
2192:   int archive_plugin_fd;
2193:
2194:   /* The number of opens on the archive plugin file descriptor.  */
2195:   unsigned int archive_plugin_fd_open_count;
2196:
2197:   /* A field used by _bfd_generic_link_add_archive_symbols.  This will
2198:      be used only for archive elements.  */
2199:   int archive_pass;
2200:
2201:   /* The total size of memory from bfd_alloc.  */
2202:   bfd_size_type alloc_size;
2203:
2204:   /* Stuff only useful for object files:
2205:      The start address.  */
2206:   bfd_vma start_address;
2207:
2208:   /* Symbol table for output BFD (with symcount entries).
2209:      Also used by the linker to cache input BFD symbols.  */
2210:   struct bfd_symbol **outsymbols;
2211:
2212:   /* Used for input and output.  */
2213:   unsigned int symcount;
2214:
2215:   /* Used for slurped dynamic symbol tables.  */
2216:   unsigned int dynsymcount;
2217:
2218:   /* Pointer to structure which contains architecture information.  */
2219:   const struct bfd_arch_info *arch_info;
2220:
2221:   /* Cached length of file for bfd_get_size.  0 until bfd_get_size is
2222:      called, 1 if stat returns an error or the file size is too large to
2223:      return in ufile_ptr.  Both 0 and 1 should be treated as "unknown".  */
2224:   ufile_ptr size;
2225:
2226:   /* Stuff only useful for archives.  */
2227:   void *arelt_data;
2228:   struct bfd *my_archive;      /* The containing archive BFD.  */
2229:   struct bfd *archive_next;    /* The next BFD in the archive.  */
2230:   struct bfd *archive_head;    /* The first BFD in the archive.  */
2231:   struct bfd *nested_archives; /* List of nested archive in a flattened
2232:                                   thin archive.  */
2233:
2234:   union {
2235:     /* For input BFDs, a chain of BFDs involved in a link.  */
2236:     struct bfd *next;
2237:     /* For output BFD, the linker hash table.  */
2238:     struct bfd_link_hash_table *hash;
2239:   } link;
2240:
2241:   /* Used by the back end to hold private data.  */
2242:   union
2243:     {
2244:       struct aout_data_struct *aout_data;
2245:       struct artdata *aout_ar_data;
2246:       struct coff_tdata *coff_obj_data;
2247:       struct pe_tdata *pe_obj_data;
2248:       struct xcoff_tdata *xcoff_obj_data;
2249:       struct ecoff_tdata *ecoff_obj_data;
2250:       struct srec_data_struct *srec_data;
2251:       struct verilog_data_struct *verilog_data;
2252:       struct ihex_data_struct *ihex_data;
2253:       struct tekhex_data_struct *tekhex_data;
2254:       struct elf_obj_tdata *elf_obj_data;
2255:       struct mmo_data_struct *mmo_data;
2256:       struct trad_core_struct *trad_core_data;
2257:       struct som_data_struct *som_data;
2258:       struct hpux_core_struct *hpux_core_data;
2259:       struct hppabsd_core_struct *hppabsd_core_data;
2260:       struct sgi_core_struct *sgi_core_data;
2261:       struct lynx_core_struct *lynx_core_data;
2262:       struct osf_core_struct *osf_core_data;
2263:       struct cisco_core_struct *cisco_core_data;
2264:       struct netbsd_core_struct *netbsd_core_data;
2265:       struct mach_o_data_struct *mach_o_data;
2266:       struct mach_o_fat_data_struct *mach_o_fat_data;
2267:       struct plugin_data_struct *plugin_data;
2268:       struct bfd_pef_data_struct *pef_data;
2269:       struct bfd_pef_xlib_data_struct *pef_xlib_data;
2270:       struct bfd_sym_data_struct *sym_data;
2271:       void *any;
2272:     }
2273:   tdata;
2274:
2275:   /* Used by the application to hold private data.  */
2276:   void *usrdata;
2277:
2278:   /* Where all the allocated stuff under this BFD goes.  This is a
2279:      struct objalloc *, but we use void * to avoid requiring the inclusion
2280:      of objalloc.h.  */
2281:   void *memory;
2282:
2283:   /* For input BFDs, the build ID, if the object has one. */
2284:   const struct bfd_build_id *build_id;
2285:
2286:   /* For input BFDs, mmapped entries. */
2287:   struct bfd_mmapped *mmapped;
2288: };
```

## bfd/libbfd.h:56–60

```text
56: struct section_hash_entry
57: {
58:   struct bfd_hash_entry root;
59:   asection section;
60: };
```

## bfd/elfxx-x86.h:750–763

```text
750: struct elf_x86_obj_tdata
751: {
752:   struct elf_obj_tdata root;
753:
754:   /* tls_type for each local got entry.  */
755:   char *local_got_tls_type;
756:
757:   /* GOTPLT entries for TLS descriptors.  */
758:   bfd_vma *local_tlsdesc_gotent;
759:
760:   /* R_*_RELATIVE relocation in GOT for this local symbol has been
761:      processed.  */
762:   char *relative_reloc_done;
763: };
```

## bfd/elfxx-x86.h:963–966

```text
963: #define bfd_elf64_mkobject \
964:   _bfd_x86_elf_mkobject
965: #define bfd_elf32_mkobject \
966:   _bfd_x86_elf_mkobject
```

## bfd/elfxx-x86.c:40–44

```text
40: bool
41: _bfd_x86_elf_mkobject (bfd *abfd)
42: {
43:   return bfd_elf_allocate_object (abfd, sizeof (struct elf_x86_obj_tdata));
44: }
```

## bfd/elf.c:295–319

```text
295: bfd_elf_allocate_object (bfd *abfd,
296:                          size_t object_size)
297: {
298:   BFD_ASSERT (object_size >= sizeof (struct elf_obj_tdata));
299:   abfd->tdata.any = bfd_zalloc (abfd, object_size);
300:   if (abfd->tdata.any == NULL)
301:     return false;
302:
303:   elf_object_id (abfd) = get_elf_backend_data (abfd)->target_id;
304:   if (abfd->direction != read_direction)
305:     {
306:       struct output_elf_obj_tdata *o = bfd_zalloc (abfd, sizeof *o);
307:       if (o == NULL)
308:         return false;
309:       elf_tdata (abfd)->o = o;
310:       elf_program_header_size (abfd) = (bfd_size_type) -1;
311:     }
312:   return true;
313: }
314:
315:
316: bool
317: bfd_elf_make_object (bfd *abfd)
318: {
319:   return bfd_elf_allocate_object (abfd, sizeof (struct elf_obj_tdata));
```

## bfd/elf.c:3315–3344

```text
3315: _bfd_elf_new_section_hook (bfd *abfd, asection *sec)
3316: {
3317:   struct bfd_elf_section_data *sdata;
3318:   elf_backend_data *bed;
3319:   const struct bfd_elf_special_section *ssect;
3320:
3321:   sdata = (struct bfd_elf_section_data *) sec->used_by_bfd;
3322:   if (sdata == NULL)
3323:     {
3324:       sdata = (struct bfd_elf_section_data *) bfd_zalloc (abfd,
3325:                                                           sizeof (*sdata));
3326:       if (sdata == NULL)
3327:         return false;
3328:       sec->used_by_bfd = sdata;
3329:     }
3330:
3331:   /* Indicate whether or not this section should use RELA relocations.  */
3332:   bed = get_elf_backend_data (abfd);
3333:   sec->use_rela_p = bed->default_use_rela_p;
3334:
3335:   /* Set up ELF section type and flags for newly created sections, if
3336:      there is an ABI mandated section.  */
3337:   ssect = (*bed->get_sec_type_attr) (abfd, sec);
3338:   if (ssect != NULL)
3339:     {
3340:       elf_section_type (sec) = ssect->type;
3341:       elf_section_flags (sec) = ssect->attr;
3342:     }
3343:
3344:   return _bfd_generic_new_section_hook (abfd, sec);
```

## bfd/elf-bfd.h:1855–1947

```text
1855: /* Information about reloc sections associated with a bfd_elf_section_data
1856:    structure.  */
1857: struct bfd_elf_section_reloc_data
1858: {
1859:   /* The ELF header for the reloc section associated with this
1860:      section, if any.  */
1861:   Elf_Internal_Shdr *hdr;
1862:   /* The number of relocations currently assigned to HDR.  */
1863:   unsigned int count;
1864:   /* The ELF section number of the reloc section.  Only used for an
1865:      output file.  */
1866:   int idx;
1867:   /* Used by the backend linker to store the symbol hash table entries
1868:      associated with relocs against global symbols.  */
1869:   struct elf_link_hash_entry **hashes;
1870: };
1871:
1872: /* Information stored for each BFD section in an ELF file.  This
1873:    structure is allocated by elf_new_section_hook.  */
1874:
1875: struct bfd_elf_section_data
1876: {
1877:   /* The ELF header for this section.  */
1878:   Elf_Internal_Shdr this_hdr;
1879:
1880:   /* INPUT_SECTION_FLAGS if specified in the linker script.  */
1881:   struct flag_info *section_flag_info;
1882:
1883:   /* Information about the REL and RELA reloc sections associated
1884:      with this section, if any.  */
1885:   struct bfd_elf_section_reloc_data rel, rela;
1886:
1887:   /* The ELF section number of this section.  */
1888:   int this_idx;
1889:
1890:   /* Used by the backend linker when generating a shared library to
1891:      record the dynamic symbol index for a section symbol
1892:      corresponding to this section.  A value of 0 means that there is
1893:      no dynamic symbol for this section.  */
1894:   int dynindx;
1895:
1896:   /* A pointer to the linked-to section for SHF_LINK_ORDER.  */
1897:   asection *linked_to;
1898:
1899:   /* A pointer to the swapped relocs.  If the section uses REL relocs,
1900:      rather than RELA, all the r_addend fields will be zero.  This
1901:      pointer may be NULL.  It is used by the backend linker.  */
1902:   Elf_Internal_Rela *relocs;
1903:
1904:   /* A pointer to a linked list tracking dynamic relocs copied for
1905:      local symbols.  */
1906:   void *local_dynrel;
1907:
1908:   /* A pointer to the bfd section used for dynamic relocs.  */
1909:   asection *sreloc;
1910:
1911:   union {
1912:     /* Group name, if this section is a member of a group.  */
1913:     const char *name;
1914:
1915:     /* Group signature sym, if this is the SHT_GROUP section.  */
1916:     struct bfd_symbol *id;
1917:   } group;
1918:
1919:   /* For a member of a group, points to the SHT_GROUP section.
1920:      NULL for the SHT_GROUP section itself and non-group sections.  */
1921:   asection *sec_group;
1922:
1923:   /* A linked list of member sections in the group.  Circular when used by
1924:      the linker.  For the SHT_GROUP section, points at first member.  */
1925:   asection *next_in_group;
1926:
1927:   /* The FDEs associated with this section.  The u.fde.next_in_section
1928:      field acts as a chain pointer.  */
1929:   struct eh_cie_fde *fde_list;
1930:
1931:   /* Link from a text section to its .eh_frame_entry section.  */
1932:   asection *eh_frame_entry;
1933:
1934:   /* If the mmapped_p flag is set, this points to the actual mmapped
1935:      address of contents.  If it is set to NULL, contents isn't
1936:      mmapped.  */
1937:   void *contents_addr;
1938:
1939:   /* If the mmapped_p flag is set, this is the actual mmapped size of
1940:      contents.  */
1941:   size_t contents_size;
1942:
1943:   /* TRUE if the section has secondary reloc sections associated with it.
1944:      FIXME: In the future it might be better to change this into a list
1945:      of secondary reloc sections, making lookup easier and faster.  */
1946:   bool has_secondary_relocs;
1947: };
```

## bfd/elf-bfd.h:1970–1999

```text
1970: /* The least object attributes (within an attributes subsection) known
1971:    for any target.  Some code assumes that the value 0 is not used and
1972:    the field for that attribute can instead be used as a marker to
1973:    indicate that attributes have been initialized.  */
1974: #define LEAST_KNOWN_OBJ_ATTRIBUTE 2
1975:
1976: /* The maximum number of known object attributes for any target.  */
1977: #define NUM_KNOWN_OBJ_ATTRIBUTES 77
1978:
1979: /* The value of an object attribute.  The type indicates whether the attribute
1980:    holds and integer, a string, or both.  It can also indicate that there can
1981:    be no default (i.e. all values must be written to file, even zero), or
1982:    that the value is in error and should not be written to file.  */
1983:
1984: typedef struct obj_attribute
1985: {
1986: #define ATTR_TYPE_FLAG_INT_VAL    (1 << 0)
1987: #define ATTR_TYPE_FLAG_STR_VAL    (1 << 1)
1988: #define ATTR_TYPE_FLAG_NO_DEFAULT (1 << 2)
1989: #define ATTR_TYPE_FLAG_ERROR      (1 << 3)
1990:
1991: #define ATTR_TYPE_HAS_INT_VAL(TYPE)     ((TYPE) & ATTR_TYPE_FLAG_INT_VAL)
1992: #define ATTR_TYPE_HAS_STR_VAL(TYPE)     ((TYPE) & ATTR_TYPE_FLAG_STR_VAL)
1993: #define ATTR_TYPE_HAS_NO_DEFAULT(TYPE)  ((TYPE) & ATTR_TYPE_FLAG_NO_DEFAULT)
1994: #define ATTR_TYPE_HAS_ERROR(TYPE)       ((TYPE) & ATTR_TYPE_FLAG_ERROR)
1995:
1996:   int type;
1997:   unsigned int i;
1998:   char *s;
1999: } obj_attribute;
```

## bfd/elf-bfd.h:2049–2097

```text
2049: struct output_elf_obj_tdata
2050: {
2051:   struct elf_segment_map *seg_map;
2052:   struct elf_strtab_hash *strtab_ptr;
2053:
2054:   /* STT_SECTION symbols for each section */
2055:   asymbol **section_syms;
2056:
2057:   /* NT_GNU_BUILD_ID note type info.  */
2058:   struct
2059:   {
2060:     bool (*after_write_object_contents) (bfd *);
2061:     const char *style;
2062:     asection *sec;
2063:   } build_id;
2064:
2065:   /* FDO_PACKAGING_METADATA note type info.  */
2066:   struct
2067:   {
2068:     bool (*after_write_object_contents) (bfd *);
2069:     const char *json;
2070:     asection *sec;
2071:   } package_metadata;
2072:
2073:   /* Records the result of `get_program_header_size'.  */
2074:   bfd_size_type program_header_size;
2075:
2076:   /* Used when laying out sections.  */
2077:   file_ptr next_file_pos;
2078:
2079:   /* Linker information.  */
2080:   struct bfd_link_info *link_info;
2081:
2082:   unsigned int num_section_syms;
2083:   unsigned int shstrtab_section, strtab_section;
2084:
2085:   /* Segment flags for the PT_GNU_STACK segment.  */
2086:   unsigned int stack_flags;
2087:
2088:   /* Used to determine if PT_GNU_SFRAME segment header should be
2089:      created.  */
2090:   asection *sframe;
2091:
2092:   /* Holds the object attributes section if it exists.  */
2093:   asection *obj_object_attributes;
2094:
2095:   /* Used to determine if the e_flags field has been initialized */
2096:   bool flags_init;
2097: };
```

## bfd/elf-bfd.h:2128–2281

```text
2128: struct elf_obj_tdata
2129: {
2130:   Elf_Internal_Ehdr elf_header[1];      /* Actual data, but ref like ptr */
2131:   Elf_Internal_Shdr **elf_sect_ptr;
2132:   Elf_Internal_Phdr *phdr;
2133:   Elf_Internal_Shdr symtab_hdr;
2134:   Elf_Internal_Shdr shstrtab_hdr;
2135:   Elf_Internal_Shdr strtab_hdr;
2136:   Elf_Internal_Shdr dynsymtab_hdr;
2137:   Elf_Internal_Shdr dynstrtab_hdr;
2138:   Elf_Internal_Shdr dynversym_hdr;
2139:   Elf_Internal_Shdr dynverref_hdr;
2140:   Elf_Internal_Shdr dynverdef_hdr;
2141:   Elf_Internal_Sym *dt_symtab;
2142:   bfd_byte *dt_versym;
2143:   bfd_byte *dt_verdef;
2144:   bfd_byte *dt_verneed;
2145:   size_t dt_symtab_count;
2146:   size_t dt_verdef_count;
2147:   size_t dt_verneed_count;
2148:   char * dt_strtab;
2149:   size_t dt_strsz;
2150:   elf_section_list * symtab_shndx_list;
2151:   bfd_vma gp;                           /* The gp value */
2152:   unsigned int gp_size;                 /* The gp size */
2153:   unsigned int num_elf_sections;        /* elf_sect_ptr size */
2154:   unsigned char *being_created;
2155:
2156:   /* A mapping from external symbols to entries in the linker hash
2157:      table, used when linking.  This is indexed by the symbol index
2158:      minus the sh_info field of the symbol table header.  */
2159:   struct elf_link_hash_entry **sym_hashes;
2160:
2161:   /* Section indices of local symbols, used by gc-sections.  */
2162:   unsigned int *loc_shndx;
2163:
2164:   /* Track usage and final offsets of GOT entries for local symbols.
2165:      This array is indexed by symbol index.  Elements are used
2166:      identically to "got" in struct elf_link_hash_entry.  */
2167:   union
2168:     {
2169:       bfd_signed_vma *refcounts;
2170:       bfd_vma *offsets;
2171:       struct got_entry **ents;
2172:     } local_got;
2173:
2174:   /* The linker ELF emulation code needs to let the backend ELF linker
2175:      know what filename should be used for a dynamic object if the
2176:      dynamic object is found using a search.  The emulation code then
2177:      sometimes needs to know what name was actually used.  Until the
2178:      file has been added to the linker symbol table, this field holds
2179:      the name the linker wants.  After it has been added, it holds the
2180:      name actually used, which will be the DT_SONAME entry if there is
2181:      one.  */
2182:   const char *dt_name;
2183:
2184:   /* The linker emulation needs to know what audit libs
2185:      are used by a dynamic object.  */
2186:   const char *dt_audit;
2187:
2188:   /* Used by find_nearest_line entry point.  */
2189:   void *line_info;
2190:
2191:   /* A place to stash dwarf1 info for this bfd.  */
2192:   void *dwarf1_find_line_info;
2193:
2194:   /* A place to stash dwarf2 info for this bfd.  */
2195:   void *dwarf2_find_line_info;
2196:
2197:   /* Stash away info for yet another find line/function variant.  */
2198:   void *elf_find_function_cache;
2199:
2200:   /* Number of symbol version definitions we are about to emit.  */
2201:   unsigned int cverdefs;
2202:
2203:   /* Number of symbol version references we are about to emit.  */
2204:   unsigned int cverrefs;
2205:
2206:   /* Symbol version definitions in external objects.  */
2207:   Elf_Internal_Verdef *verdef;
2208:
2209:   /* Symbol version references to external objects.  */
2210:   Elf_Internal_Verneed *verref;
2211:
2212:   /* A pointer to the .eh_frame section.  */
2213:   asection *eh_frame_section;
2214:
2215:   /* A pointer to the .sframe section.  */
2216:   asection *sframe_section;
2217:
2218:   /* Symbol buffer.  */
2219:   void *symbuf;
2220:
2221:   /* List of GNU properties.  Will be updated by setup_gnu_properties
2222:      after all input GNU properties are merged for output.  */
2223:   elf_property_list *properties;
2224:
2225:   /* The version of object attributes for this object.
2226:      For an input object, the format version used to store the data.
2227:      For an output object, the targeted format version.  */
2228:   obj_attr_version_t obj_attr_version;
2229:
2230:   obj_attribute known_obj_attributes[2][NUM_KNOWN_OBJ_ATTRIBUTES];
2231:   obj_attribute_list *other_obj_attributes[2];
2232:
2233:   /* Object attributes v2: A subsection can only hold attributes with the
2234:      same data type (uleb128, NTBS, etc), so each type requires a separate
2235:      subsection.  */
2236:   obj_attr_subsection_list_t obj_attr_subsections;
2237:
2238:   /* Linked-list containing information about every Systemtap section
2239:      found in the object file.  Each section corresponds to one entry
2240:      in the list.  */
2241:   struct sdt_note *sdt_note_head;
2242:
2243:   unsigned int symtab_section, dynsymtab_section;
2244:   unsigned int dynversym_section, dynverdef_section, dynverref_section;
2245:
2246:   /* An identifier used to distinguish different target
2247:      specific extensions to this structure.  */
2248:   ENUM_BITFIELD (elf_target_id) object_id : 6;
2249:
2250:   /* Whether a dyanmic object was specified normally on the linker
2251:      command line, or was specified when --as-needed was in effect,
2252:      or was found via a DT_NEEDED entry.  */
2253:   ENUM_BITFIELD (dynamic_lib_link_class) dyn_lib_class : 4;
2254:
2255:   /* Whether the bfd uses OS specific bits that require ELFOSABI_GNU.  */
2256:   ENUM_BITFIELD (elf_gnu_osabi) has_gnu_osabi : 4;
2257:
2258:   /* Whether if the bfd contains the GNU_PROPERTY_NO_COPY_ON_PROTECTED
2259:      property.  */
2260:   unsigned int has_no_copy_on_protected : 1;
2261:
2262:   /* Whether if the bfd contains the
2263:      GNU_PROPERTY_1_NEEDED_INDIRECT_EXTERN_ACCESS property.  */
2264:   unsigned int has_indirect_extern_access : 1;
2265:
2266:   /* Irix 5 often screws up the symbol table, sorting local symbols
2267:      after global symbols.  This flag is set if the symbol table in
2268:      this BFD appears to be screwed up.  If it is, we ignore the
2269:      sh_info field in the symbol table header, and always read all the
2270:      symbols.  */
2271:   unsigned int bad_symtab : 1;
2272:
2273:   /* Set if DT_FLAGS_1 has DF_1_PIE set.  */
2274:   unsigned int is_pie : 1;
2275:
2276:   /* Information grabbed from an elf core file.  */
2277:   struct core_elf_obj_tdata *core;
2278:
2279:   /* More information held for output ELF BFDs.  */
2280:   struct output_elf_obj_tdata *o;
2281: };
```

## bfd/elf-attrs.h:145–155

```text
145: typedef struct obj_attr_subsection_list
146: {
147:   /* A pointer to the first node of the list.  */
148:   obj_attr_subsection_v2_t *first;
149:
150:   /* A pointer to the last node of the list.  */
151:   obj_attr_subsection_v2_t *last;
152:
153:   /* The size of the list.  */
154:   unsigned int size;
155: } obj_attr_subsection_list_t;
```

## include/elf/internal.h:65–82

```text
65: #define EI_NIDENT       16              /* Size of e_ident[] */
66:
67: typedef struct elf_internal_ehdr {
68:   unsigned char         e_ident[EI_NIDENT]; /* ELF "magic number" */
69:   bfd_vma               e_entry;        /* Entry point virtual address */
70:   bfd_size_type         e_phoff;        /* Program header table file offset */
71:   bfd_size_type         e_shoff;        /* Section header table file offset */
72:   unsigned long         e_version;      /* Identifies object file version */
73:   unsigned long         e_flags;        /* Processor-specific flags */
74:   unsigned short        e_type;         /* Identifies object file type */
75:   unsigned short        e_machine;      /* Specifies required architecture */
76:   unsigned int          e_ehsize;       /* ELF header size in bytes */
77:   unsigned int          e_phentsize;    /* Program header table entry size */
78:   unsigned int          e_phnum;        /* Program header table entry count */
79:   unsigned int          e_shentsize;    /* Section header table entry size */
80:   unsigned int          e_shnum;        /* Section header table entry count */
81:   unsigned int          e_shstrndx;     /* Section header string table index */
82: } Elf_Internal_Ehdr;
```

## include/elf/internal.h:102–118

```text
102: typedef struct elf_internal_shdr {
103:   unsigned int  sh_name;                /* Section name, index in string tbl */
104:   unsigned int  sh_type;                /* Type of section */
105:   bfd_vma       sh_flags;               /* Miscellaneous section attributes */
106:   bfd_vma       sh_addr;                /* Section virtual addr at execution in
107:                                            octets.  */
108:   file_ptr      sh_offset;              /* Section file offset in octets.  */
109:   bfd_size_type sh_size;                /* Size of section in octets.  */
110:   unsigned int  sh_link;                /* Index of another section */
111:   unsigned int  sh_info;                /* Additional section information */
112:   bfd_vma       sh_addralign;           /* Section alignment */
113:   bfd_size_type sh_entsize;             /* Entry size if section holds table */
114:
115:   /* The internal rep also has some cached info associated with it. */
116:   asection *    bfd_section;            /* Associated BFD section.  */
117:   unsigned char *contents;              /* Section contents.  */
118: } Elf_Internal_Shdr;
```

## bfd/section.c:790–809

```text
790: bfd_section_hash_newfunc (struct bfd_hash_entry *entry,
791:                           struct bfd_hash_table *table,
792:                           const char *string)
793: {
794:   /* Allocate the structure if it has not already been allocated by a
795:      subclass.  */
796:   if (entry == NULL)
797:     {
798:       entry = (struct bfd_hash_entry *)
799:         bfd_hash_allocate (table, sizeof (struct section_hash_entry));
800:       if (entry == NULL)
801:         return entry;
802:     }
803:
804:   /* Call the allocation method of the superclass.  */
805:   entry = bfd_hash_newfunc (entry, table, string);
806:   if (entry != NULL)
807:     memset (&((struct section_hash_entry *) entry)->section, 0,
808:             sizeof (asection));
809:
```

## bfd/section.c:1114–1152

```text
1114: bfd_make_section_old_way (bfd *abfd, const char *name)
1115: {
1116:   asection *newsect;
1117:
1118:   if (abfd->output_has_begun)
1119:     {
1120:       bfd_set_error (bfd_error_invalid_operation);
1121:       return NULL;
1122:     }
1123:
1124:   if (strcmp (name, BFD_ABS_SECTION_NAME) == 0)
1125:     newsect = bfd_abs_section_ptr;
1126:   else if (strcmp (name, BFD_COM_SECTION_NAME) == 0)
1127:     newsect = bfd_com_section_ptr;
1128:   else if (strcmp (name, BFD_UND_SECTION_NAME) == 0)
1129:     newsect = bfd_und_section_ptr;
1130:   else if (strcmp (name, BFD_IND_SECTION_NAME) == 0)
1131:     newsect = bfd_ind_section_ptr;
1132:   else
1133:     {
1134:       struct section_hash_entry *sh;
1135:
1136:       sh = section_hash_lookup (&abfd->section_htab, name, true, false);
1137:       if (sh == NULL)
1138:         return NULL;
1139:
1140:       newsect = &sh->section;
1141:       if (newsect->name != NULL)
1142:         {
1143:           /* Section already exists.  */
1144:           return newsect;
1145:         }
1146:
1147:       newsect->name = name;
1148:       return bfd_section_init (abfd, newsect);
1149:     }
1150:
1151:   return newsect;
1152: }
```

## bfd/hash.c:382–405

```text
382:       UINT32_C (536870909),
383:       UINT32_C (1073741789),
384:       UINT32_C (2147483647),
385:       UINT32_C (4294967291)
386:   };
387:
388:   const uint32_t *low = &primes[0];
389:   const uint32_t *high = &primes[sizeof (primes) / sizeof (primes[0])];
390:
391:   while (low != high)
392:     {
393:       const uint32_t *mid = low + (high - low) / 2;
394:       if (n >= *mid)
395:         low = mid + 1;
396:       else
397:         high = mid;
398:     }
399:
400:   if (n >= *low)
401:     return 0;
402:
403:   return *low;
404: }
405:
```

## bfd/hash.c:596–651

```text
596:            const char *,
597:            unsigned long {*hash*});
598:
599: DESCRIPTION
600:         Insert an entry in a hash table.
601: */
602:
603: struct bfd_hash_entry *
604: bfd_hash_insert (struct bfd_hash_table *table,
605:                  const char *string,
606:                  unsigned long hash)
607: {
608:   struct bfd_hash_entry *hashp;
609:   unsigned int _index;
610:
611:   hashp = (*table->newfunc) (NULL, table, string);
612:   if (hashp == NULL)
613:     return NULL;
614:   hashp->string = string;
615:   hashp->hash = hash;
616:   _index = hash % table->size;
617:   hashp->next = table->table[_index];
618:   table->table[_index] = hashp;
619:   table->count++;
620:
621:   if (!table->frozen && table->count > table->size * 3 / 4)
622:     {
623:       unsigned long newsize = higher_prime_number (table->size);
624:       struct bfd_hash_entry **newtable;
625:       unsigned int hi;
626:       unsigned long alloc = newsize * sizeof (struct bfd_hash_entry *);
627:
628:       /* If we can't find a higher prime, or we can't possibly alloc
629:          that much memory, don't try to grow the table.  */
630:       if (newsize == 0 || alloc / sizeof (struct bfd_hash_entry *) != newsize)
631:         {
632:           table->frozen = 1;
633:           return hashp;
634:         }
635:
636:       newtable = ((struct bfd_hash_entry **)
637:                   objalloc_alloc ((struct objalloc *) table->memory, alloc));
638:       if (newtable == NULL)
639:         {
640:           table->frozen = 1;
641:           return hashp;
642:         }
643:       memset (newtable, 0, alloc);
644:
645:       for (hi = 0; hi < table->size; hi ++)
646:         while (table->table[hi])
647:           {
648:             struct bfd_hash_entry *chain = table->table[hi];
649:             struct bfd_hash_entry *chain_end = chain;
650:
651:             while (chain_end->next && chain_end->next->hash == chain->hash)
```

## bfd/hash.c:726–748

```text
726:        pph = &(*pph)->next)
727:     {
728:       if (*pph == old)
729:         {
730:           *pph = nw;
731:           return;
732:         }
733:     }
734:
735:   abort ();
736: }
737:
738: /*
739: FUNCTION
740:         bfd_hash_allocate
741:
742: SYNOPSIS
743:         void *bfd_hash_allocate (struct bfd_hash_table *,
744:                                  unsigned int {*size*});
745:
746: DESCRIPTION
747:         Allocate space in a hash table.
748: */
```

## bfd/libbfd.c:434–481

```text
434: bfd_alloc (bfd *abfd, bfd_size_type size)
435: {
436:   void *ret;
437:   unsigned long ul_size = (unsigned long) size;
438:
439:   if (size != ul_size
440:       /* Note - although objalloc_alloc takes an unsigned long as its
441:          argument, internally the size is treated as a signed long.  This can
442:          lead to problems where, for example, a request to allocate -1 bytes
443:          can result in just 1 byte being allocated, rather than
444:          ((unsigned long) -1) bytes.  Also memory checkers will often
445:          complain about attempts to allocate a negative amount of memory.
446:          So to stop these problems we fail if the size is negative.  */
447:       || ((signed long) ul_size) < 0)
448:     {
449:       bfd_set_error (bfd_error_no_memory);
450:       return NULL;
451:     }
452:
453:   ret = objalloc_alloc ((struct objalloc *) abfd->memory, ul_size);
454:   if (ret == NULL)
455:     bfd_set_error (bfd_error_no_memory);
456:   else
457:     abfd->alloc_size += size;
458:   return ret;
459: }
460:
461: /*
462: FUNCTION
463:         bfd_zalloc
464:
465: SYNOPSIS
466:         void *bfd_zalloc (bfd *abfd, bfd_size_type wanted);
467:
468: DESCRIPTION
469:         Allocate a block of @var{wanted} bytes of zeroed memory
470:         attached to <<abfd>> and return a pointer to it.
471: */
472:
473: void *
474: bfd_zalloc (bfd *abfd, bfd_size_type size)
475: {
476:   void *res;
477:
478:   res = bfd_alloc (abfd, size);
479:   if (res)
480:     memset (res, 0, (size_t) size);
481:   return res;
```

## include/objalloc.h:44–63

```text
44: struct objalloc
45: {
46:   char *current_ptr;
47:   unsigned int current_space;
48:   void *chunks;
49: };
50:
51: /* Work out the required alignment.  */
52:
53: struct objalloc_align { char x; double d; };
54:
55: #if defined (__STDC__) && __STDC__
56: #ifndef offsetof
57: #include <stddef.h>
58: #endif
59: #endif
60: #ifndef offsetof
61: #define offsetof(TYPE, MEMBER) ((unsigned long) &((TYPE *)0)->MEMBER)
62: #endif
63: #define OBJALLOC_ALIGN offsetof (struct objalloc_align, d)
```

## include/objalloc.h:85–100

```text
85: #endif
86:
87: #define objalloc_alloc(o, l)                                            \
88:   __extension__                                                         \
89:   ({ struct objalloc *__o = (o);                                        \
90:      unsigned long __len = (l);                                         \
91:      if (__len == 0)                                                    \
92:        __len = 1;                                                       \
93:      __len = (__len + OBJALLOC_ALIGN - 1) &~ (OBJALLOC_ALIGN - 1);      \
94:      (__len != 0 && __len <= __o->current_space                         \
95:       ? (__o->current_ptr += __len,                                     \
96:          __o->current_space -= __len,                                   \
97:          (void *) (__o->current_ptr - __len))                           \
98:       : _objalloc_alloc (__o, __len)); })
99:
100: #else /* ! __GNUC__ */
```

## libiberty/objalloc.c:55–81

```text
55:
56: /* This structure appears at the start of each chunk.  */
57:
58: struct objalloc_chunk
59: {
60:   /* Next chunk.  */
61:   struct objalloc_chunk *next;
62:   /* If this chunk contains large objects, this is the value of
63:      current_ptr when this chunk was allocated.  If this chunk
64:      contains small objects, this is NULL.  */
65:   char *current_ptr;
66: };
67:
68: /* The aligned size of objalloc_chunk.  */
69:
70: #define CHUNK_HEADER_SIZE                                       \
71:   ((sizeof (struct objalloc_chunk) + OBJALLOC_ALIGN - 1)        \
72:    &~ (OBJALLOC_ALIGN - 1))
73:
74: /* We ask for this much memory each time we create a chunk which is to
75:    hold small objects.  */
76:
77: #define CHUNK_SIZE (4096 - 32)
78:
79: /* A request for this amount or more is just passed through to malloc.  */
80:
81: #define BIG_REQUEST (512)
```

## libiberty/objalloc.c:85–170

```text
85: struct objalloc *
86: objalloc_create (void)
87: {
88:   struct objalloc *ret;
89:   struct objalloc_chunk *chunk;
90:
91:   ret = (struct objalloc *) malloc (sizeof *ret);
92:   if (ret == NULL)
93:     return NULL;
94:
95:   ret->chunks = (void *) malloc (CHUNK_SIZE);
96:   if (ret->chunks == NULL)
97:     {
98:       free (ret);
99:       return NULL;
100:     }
101:
102:   chunk = (struct objalloc_chunk *) ret->chunks;
103:   chunk->next = NULL;
104:   chunk->current_ptr = NULL;
105:
106:   ret->current_ptr = (char *) chunk + CHUNK_HEADER_SIZE;
107:   ret->current_space = CHUNK_SIZE - CHUNK_HEADER_SIZE;
108:
109:   return ret;
110: }
111:
112: /* Allocate space from an objalloc structure.  */
113:
114: void *
115: _objalloc_alloc (struct objalloc *o, unsigned long original_len)
116: {
117:   unsigned long len = original_len;
118:
119:   /* We avoid confusion from zero sized objects by always allocating
120:      at least 1 byte.  */
121:   if (len == 0)
122:     len = 1;
123:
124:   len = (len + OBJALLOC_ALIGN - 1) &~ (OBJALLOC_ALIGN - 1);
125:
126:   /* Check for overflow in the alignment operation above and the
127:      malloc argument below. */
128:   if (len + CHUNK_HEADER_SIZE < original_len)
129:     return NULL;
130:
131:   if (len <= o->current_space)
132:     {
133:       o->current_ptr += len;
134:       o->current_space -= len;
135:       return (void *) (o->current_ptr - len);
136:     }
137:
138:   if (len >= BIG_REQUEST)
139:     {
140:       char *ret;
141:       struct objalloc_chunk *chunk;
142:
143:       ret = (char *) malloc (CHUNK_HEADER_SIZE + len);
144:       if (ret == NULL)
145:         return NULL;
146:
147:       chunk = (struct objalloc_chunk *) ret;
148:       chunk->next = (struct objalloc_chunk *) o->chunks;
149:       chunk->current_ptr = o->current_ptr;
150:
151:       o->chunks = (void *) chunk;
152:
153:       return (void *) (ret + CHUNK_HEADER_SIZE);
154:     }
155:   else
156:     {
157:       struct objalloc_chunk *chunk;
158:
159:       chunk = (struct objalloc_chunk *) malloc (CHUNK_SIZE);
160:       if (chunk == NULL)
161:         return NULL;
162:       chunk->next = (struct objalloc_chunk *) o->chunks;
163:       chunk->current_ptr = NULL;
164:
165:       o->current_ptr = (char *) chunk + CHUNK_HEADER_SIZE;
166:       o->current_space = CHUNK_SIZE - CHUNK_HEADER_SIZE;
167:
168:       o->chunks = (void *) chunk;
169:
170:       return objalloc_alloc (o, len);
```
