# Indexed GAS invocation and subsidiary-storage source excerpts

Literal LF numbering.

## gcc/gcc.cc:712–722

```text
712: /* config.h can define ASM_FINAL_SPEC to run a post processor after
713:    the assembler has run.  */
714: #ifndef ASM_FINAL_SPEC
715: #define ASM_FINAL_SPEC \
716:   "%{gsplit-dwarf: \n\
717:        objcopy --extract-dwo \
718:          %{c:%{o*:%*}%{!o*:%w%b%O}}%{!c:%U%O} \
719:          %b.dwo \n\
720:        objcopy --strip-dwo \
721:          %{c:%{o*:%*}%{!o*:%w%b%O}}%{!c:%U%O} \
722:     }"
```

## gcc/gcc.cc:981–999

```text
981: /* Define ASM_DEBUG_OPTION_SPEC to be a spec suitable for translating '-g'
982:    to the assembler when compiling all sources.  */
983: #ifndef ASM_DEBUG_OPTION_SPEC
984: # if defined(HAVE_AS_GDWARF_5_DEBUG_FLAG) && defined(HAVE_AS_WORKING_DWARF_N_FLAG)
985: #  define ASM_DEBUG_OPTION_DWARF_OPT                                    \
986:         "%{%:dwarf-version-gt(4):--gdwarf-5 ;"                          \
987:         "%:dwarf-version-gt(3):--gdwarf-4 ;"                            \
988:         "%:dwarf-version-gt(2):--gdwarf-3 ;"                            \
989:         ":--gdwarf2 }"
990: # if defined(DWARF2_DEBUGGING_INFO)
991: #   define ASM_DEBUG_OPTION_SPEC "%{g*:%{%:debug-level-gt(0):" \
992:         ASM_DEBUG_OPTION_DWARF_OPT "}}"
993: #  endif
994: # endif
995: #endif
996: #ifndef ASM_DEBUG_OPTION_SPEC
997: # define ASM_DEBUG_OPTION_SPEC ""
998: #endif
999:
```

## gcc/gcc.cc:1328–1350

```text
1328: static const char *asm_options =
1329: "%{-target-help:%:print-asm-header()} "
1330: #if HAVE_GNU_AS
1331: /* If GNU AS is used, then convert -w (no warnings), -I, and -v
1332:    to the assembler equivalents.  */
1333: "%{v} %{w:-W} %{I*} "
1334: #endif
1335: "%(asm_debug_option)"
1336: ASM_COMPRESS_DEBUG_SPEC
1337: "%a %Y %{c:%W{o*}%{!o*:-o %w%b%O}}%{!c:-o %d%w%u%O}";
1338:
1339: static const char *invoke_as =
1340: #ifdef AS_NEEDS_DASH_FOR_PIPED_INPUT
1341: "%{!fwpa*:\
1342:    %{fcompare-debug=*|fdump-final-insns=*:%:compare-debug-dump-opt()}\
1343:    %{!S:-o %|.s |\n as %(asm_options) %|.s %A }\
1344:   }";
1345: #else
1346: "%{!fwpa*:\
1347:    %{fcompare-debug=*|fdump-final-insns=*:%:compare-debug-dump-opt()}\
1348:    %{!S:-o %|.s |\n as %(asm_options) %m.s %A }\
1349:   }";
1350: #endif
```

## gcc/gcc.cc:8354–8367

```text
8354: /* Expand any @ files within the command-line args,
8355:    setting at_file_supplied if any were expanded.  */
8356:
8357: void
8358: driver::expand_at_files (int *argc, char ***argv) const
8359: {
8360:   char **old_argv = *argv;
8361:
8362:   expandargv (argc, argv);
8363:
8364:   /* Determine if any expansions were made.  */
8365:   if (*argv != old_argv)
8366:     at_file_supplied = true;
8367: }
```

## gcc/gcc.cc:11142–11163

```text
11142: /* Returns "" if debug_info_level is greater than ARGV[ARGC-1].
11143:    Otherwise, return NULL.  */
11144:
11145: static const char *
11146: debug_level_greater_than_spec_func (int argc, const char **argv)
11147: {
11148:   char *converted;
11149:
11150:   if (argc != 1)
11151:     fatal_error (input_location,
11152:                  "wrong number of arguments to %%:debug-level-gt");
11153:
11154:   long arg = strtol (argv[0], &converted, 10);
11155:   gcc_assert (converted != argv[0]);
11156:
11157:   if (debug_info_level > arg)
11158:     return "";
11159:
11160:   return NULL;
11161: }
11162:
11163: /* Returns "" if dwarf_version is greater than ARGV[ARGC-1].
```

## gcc/common.opt:105–114

```text
105: ; Type(s) of debugging information we are producing (if any).  See
106: ; flag-types.h for the definitions of the different possible types of
107: ; debugging information.
108: Variable
109: uint32_t write_symbols = NO_DEBUG
110:
111: ; Level of debugging information we are producing.  See flag-types.h
112: ; for the definitions of the different possible levels.
113: Variable
114: enum debug_info_levels debug_info_level = DINFO_LEVEL_NONE
```

## gcc/config.gcc:2123–2130

```text
2123: x86_64-*-linux* | x86_64-*-kfreebsd*-gnu | x86_64-*-gnu*)
2124:         tm_file="${tm_file} i386/unix.h i386/att.h elfos.h gnu-user.h glibc-stdint.h \
2125:                  i386/x86-64.h i386/gnu-user-common.h i386/gnu-user64.h"
2126:         case ${target} in
2127:         x86_64-*-linux*)
2128:                 tm_file="${tm_file} linux.h linux-android.h i386/linux-common.h i386/linux64.h"
2129:                 extra_options="${extra_options} linux-android.opt"
2130:                 ;;
```

## gcc/config/i386/gnu-user64.h:34–53

```text
34: #if TARGET_64BIT_DEFAULT
35: #define SPEC_32 "m16|m32"
36: #if TARGET_BI_ARCH == 2
37: #define SPEC_64 "m64"
38: #define SPEC_X32 "m16|m32|m64:;"
39: #else
40: #define SPEC_64 "m16|m32|mx32:;"
41: #define SPEC_X32 "mx32"
42: #endif
43: #else
44: #define SPEC_32 "m64|mx32:;"
45: #define SPEC_64 "m64"
46: #define SPEC_X32 "mx32"
47: #endif
48:
49: #undef ASM_SPEC
50: #define ASM_SPEC "%{" SPEC_32 ":--32} \
51:  %{" SPEC_64 ":--64} \
52:  %{" SPEC_X32 ":--x32} \
53:  %{msse2avx:%{!mavx:-msse2avx}}"
```

## gcc/ada/gcc-interface/lang-specs.h:35–52

```text
35:   {"@ada",
36:    "\
37:  %{pg:%{fomit-frame-pointer:%e-pg and -fomit-frame-pointer are incompatible}}\
38:  %{!S:%{!c:%e-c or -S required for Ada}}\
39:  gnat1 %{I*} %{k8:-gnatk8} %{!Q:-quiet}\
40:     %{nostdinc} %{nostdlib}\
41:     %{fcompare-debug-second:-gnatd_A} \
42:     %{O*} %{W*} %{w} %{p} %{pg:-p} " ADA_DUMPS_OPTIONS " \
43:     %{coverage:-fprofile-arcs -ftest-coverage} "
44: #if defined(TARGET_VXWORKS_RTP)
45:    "%{fRTS=rtp|fRTS=rtp-smp|fRTS=ravenscar-cert-rtp:-mrtp} "
46: #endif
47:    "%{Wall:-gnatwa} %{Werror:-gnatwe} %{w:-gnatws} \
48:     %{gnatea:-gnatez} %{g*&m*&f*} \
49:     %1 %{!S:%{o*:%w%*-gnatO}} \
50:     %i %{S:%W{o*}%{!o*:-o %w%b.s}} \
51:     %{gnatc*|gnats*: -o %j} %{-param*} \
52:     %{!gnatc*:%{!gnats*:%(invoke_as)}}", 0, 0, 0},
```

## gcc/ada/gcc-interface/lang.opt:95–101

```text
95: gnatO
96: Ada AdaWhy AdaSCIL Driver Separate RejectNegative
97: Set name of output ALI file (internal switch).
98:
99: gnat
100: Ada AdaWhy AdaSCIL Driver Joined RejectNegative
101: -gnat<options>  Specify options to GNAT.
```

## gas/as.c:630–639

```text
630:
631:   /* Make a local copy of the old argv.  */
632:   old_argc = *pargc;
633:   old_argv = *pargv;
634:
635:   /* Initialize a new argv that contains no options.  */
636:   new_argv = notes_alloc (sizeof (char *) * (old_argc + 1));
637:   new_argv[0] = old_argv[0];
638:   new_argc = 1;
639:   new_argv[new_argc] = NULL;
```

## gas/as.c:1013–1020

```text
1013: # if defined (TARGET_USE_SCFI) && defined (TARGET_USE_GINSN)
1014:         case OPTION_SCFI:
1015:           if (optarg && strcasecmp (optarg, "experimental") == 0)
1016:             flag_synth_cfi = SYNTH_CFI_EXPERIMENTAL;
1017:           else
1018:             as_fatal (_("Invalid --scfi= option: `%s'; suggested option: experimental"),
1019:                       optarg);
1020:           break;
```

## gas/as.c:1173–1175

```text
1173:         case 'o':
1174:           out_file_name = notes_strdup (optarg);
1175:           break;
```

## gas/as.c:1425–1441

```text
1425: #ifndef OBJ_MACH_O
1426:   /* Create the standard sections, and those the assembler uses
1427:      internally.  */
1428:   text_section = subseg_new (TEXT_SECTION_NAME, 0);
1429:   data_section = subseg_new (DATA_SECTION_NAME, 0);
1430:   bss_section = subseg_new (BSS_SECTION_NAME, 0);
1431:   /* @@ FIXME -- we're setting the RELOC flag so that sections are assumed
1432:      to have relocs, otherwise we don't find out in time.  */
1433:   flagword applicable = bfd_applicable_section_flags (stdoutput);
1434:   bfd_set_section_flags (text_section,
1435:                          applicable & (SEC_ALLOC | SEC_LOAD | SEC_RELOC
1436:                                        | SEC_CODE | SEC_READONLY));
1437:   bfd_set_section_flags (data_section,
1438:                          applicable & (SEC_ALLOC | SEC_LOAD | SEC_RELOC
1439:                                        | SEC_DATA));
1440:   bfd_set_section_flags (bss_section, applicable & SEC_ALLOC);
1441:   seg_info (bss_section)->bss = 1;
```

## gas/as.h:330–337

```text
330:
331: enum synth_cfi_type
332: {
333:   SYNTH_CFI_NONE = 0,
334:   SYNTH_CFI_EXPERIMENTAL,
335: };
336:
337: COMMON enum synth_cfi_type flag_synth_cfi;
```

## gas/read.c:1718–1785

```text
1718: read_symbol_name (void)
1719: {
1720:   char * name;
1721:   char * start;
1722:   char c;
1723:
1724:   c = *input_line_pointer++;
1725:
1726:   if (c == '"')
1727:     {
1728: #define SYM_NAME_CHUNK_LEN 128
1729:       ptrdiff_t len = SYM_NAME_CHUNK_LEN;
1730:       char * name_end;
1731:       unsigned int C;
1732:
1733:       start = name = XNEWVEC (char, len + 1);
1734:
1735:       name_end = name + SYM_NAME_CHUNK_LEN;
1736:
1737:       while (is_a_char (C = next_char_of_string ()))
1738:         {
1739:           if (name >= name_end)
1740:             {
1741:               ptrdiff_t sofar;
1742:
1743:               sofar = name - start;
1744:               len += SYM_NAME_CHUNK_LEN;
1745:               start = XRESIZEVEC (char, start, len + 1);
1746:               name_end = start + len;
1747:               name = start + sofar;
1748:             }
1749:
1750:           *name++ = (char) C;
1751:         }
1752:       *name = 0;
1753:
1754:       /* Since quoted symbol names can contain non-ASCII characters,
1755:          check the string and warn if it cannot be recognised by the
1756:          current character set.  */
1757:       /* PR 29447: mbstowcs ignores the third (length) parameter when
1758:          the first (destination) parameter is NULL.  For clarity sake
1759:          therefore we pass 0 rather than 'len' as the third parameter.  */
1760:       if (mbstowcs (NULL, name, 0) == (size_t) -1)
1761:         as_warn (_("symbol name not recognised in the current locale"));
1762:     }
1763:   else if (is_name_beginner (c) || (input_from_string && c == FAKE_LABEL_CHAR))
1764:     {
1765:       ptrdiff_t len;
1766:
1767:       name = input_line_pointer - 1;
1768:
1769:       /* We accept FAKE_LABEL_CHAR in a name in case this is
1770:          being called with a constructed string.  */
1771:       while (is_part_of_name (c = *input_line_pointer++)
1772:              || (input_from_string && c == FAKE_LABEL_CHAR))
1773:         ;
1774:
1775:       len = (input_line_pointer - name) - 1;
1776:       start = XNEWVEC (char, len + 1);
1777:
1778:       memcpy (start, name, len);
1779:       start[len] = 0;
1780:
1781:       /* Skip a name ender char if one is present.  */
1782:       if (! is_name_ender (c))
1783:         --input_line_pointer;
1784:     }
1785:   else
```

## gas/read.c:2252–2278

```text
2252: static struct deferred_diag {
2253:   struct deferred_diag *next;
2254:   const char *file;
2255:   unsigned int lineno;
2256:   bool err;
2257:   expressionS exp;
2258: } *deferred_diag_head, **deferred_diag_tail = &deferred_diag_head;
2259:
2260: static void
2261: s_errwarn_if (int err)
2262: {
2263:   struct deferred_diag *diag = XNEW (struct deferred_diag);
2264:   int errcnt = had_errors ();
2265:
2266:   deferred_expression (&diag->exp);
2267:   if (errcnt != had_errors ())
2268:     {
2269:       ignore_rest_of_line ();
2270:       free (diag);
2271:       return;
2272:     }
2273:
2274:   diag->err = err;
2275:   diag->file = as_where (&diag->lineno);
2276:   diag->next = NULL;
2277:   *deferred_diag_tail = diag;
2278:   deferred_diag_tail = &diag->next;
```

## gas/read.c:2454–2488

```text
2454: void
2455: s_globl (int ignore ATTRIBUTE_UNUSED)
2456: {
2457:   char *name;
2458:   int c;
2459:   symbolS *symbolP;
2460:   char *stop = NULL;
2461:   char stopc = 0;
2462:
2463:   if (flag_mri)
2464:     stop = mri_comment_field (&stopc);
2465:
2466:   do
2467:     {
2468:       if ((name = read_symbol_name ()) == NULL)
2469:         return;
2470:
2471:       symbolP = symbol_find_or_make (name);
2472:       S_SET_EXTERNAL (symbolP);
2473:
2474:       SKIP_WHITESPACE ();
2475:       c = *input_line_pointer;
2476:       if (c == ',')
2477:         {
2478:           input_line_pointer++;
2479:           SKIP_WHITESPACE ();
2480:           if (is_end_of_stmt (*input_line_pointer))
2481:             c = '\n';
2482:         }
2483:
2484:       free (name);
2485:     }
2486:   while (c == ',');
2487:
2488:   demand_empty_rest_of_line ();
```

## gas/read.c:6670–6729

```text
6670: {
6671:   if (end_p)
6672:     {
6673:       if (current_name == NULL)
6674:         {
6675:           as_bad (_("missing .func"));
6676:           ignore_rest_of_line ();
6677:           return;
6678:         }
6679:
6680:       if (debug_type == DEBUG_STABS)
6681:         stabs_generate_asm_endfunc (current_name, current_label);
6682:
6683:       free (current_name);
6684:       free (current_label);
6685:       current_name = current_label = NULL;
6686:     }
6687:   else /* ! end_p */
6688:     {
6689:       char *name, *label;
6690:       char delim1, delim2;
6691:
6692:       if (current_name != NULL)
6693:         {
6694:           as_bad (_(".endfunc missing for previous .func"));
6695:           ignore_rest_of_line ();
6696:           return;
6697:         }
6698:
6699:       delim1 = get_symbol_name (& name);
6700:       name = xstrdup (name);
6701:       restore_line_pointer (delim1);
6702:       SKIP_WHITESPACE ();
6703:       if (*input_line_pointer != ',')
6704:         {
6705:           if (default_prefix)
6706:             label = xasprintf ("%s%s", default_prefix, name);
6707:           else
6708:             {
6709:               char leading_char = bfd_get_symbol_leading_char (stdoutput);
6710:               /* Missing entry point, use function's name with the leading
6711:                  char prepended.  */
6712:               if (leading_char)
6713:                 label = xasprintf ("%c%s", leading_char, name);
6714:               else
6715:                 label = xstrdup (name);
6716:             }
6717:         }
6718:       else
6719:         {
6720:           ++input_line_pointer;
6721:           SKIP_WHITESPACE ();
6722:           delim2 = get_symbol_name (& label);
6723:           label = xstrdup (label);
6724:           restore_line_pointer (delim2);
6725:         }
6726:
6727:       if (debug_type == DEBUG_STABS)
6728:         stabs_generate_asm_func (name, label);
6729:
```

## gas/config/tc-i386.c:2187–2193

```text
2187:       copy = xstrdup (suffix_string);
2188:       /* No need to save/restore input_line_pointer; that's done in the
2189:          caller already.  */
2190:       input_line_pointer = copy;
2191:       val = get_absolute_expression ();
2192:       suffix_string += input_line_pointer - copy;
2193:       free (copy);
```

## gas/config/tc-i386.c:3333–3377

```text
3333:     const struct arch_stack_entry *prev;
3334:     const char *name;
3335:     char *sub_name;
3336:     i386_cpu_flags flags;
3337:     i386_cpu_flags isa_flags;
3338:     enum processor_type isa;
3339:     enum flag_code flag_code;
3340:     unsigned int vector_size;
3341:     char stackop_size;
3342:     bool no_cond_jump_promotion;
3343:   } arch_stack_entry;
3344:   static const arch_stack_entry *arch_stack_top;
3345:   char *s;
3346:   int e;
3347:   const char *string;
3348:   unsigned int j = 0;
3349:
3350:   SKIP_WHITESPACE ();
3351:
3352:   if (is_end_of_stmt (*input_line_pointer))
3353:     {
3354:       as_bad (_("missing cpu architecture"));
3355:       input_line_pointer++;
3356:       return;
3357:     }
3358:
3359:   e = get_symbol_name (&s);
3360:   string = s;
3361:
3362:   if (strcmp (string, "push") == 0)
3363:     {
3364:       arch_stack_entry *top = XNEW (arch_stack_entry);
3365:
3366:       top->name = cpu_arch_name;
3367:       if (cpu_sub_arch_name)
3368:         top->sub_name = xstrdup (cpu_sub_arch_name);
3369:       else
3370:         top->sub_name = NULL;
3371:       top->flags = cpu_arch_flags;
3372:       top->isa = cpu_arch_isa;
3373:       top->isa_flags = cpu_arch_isa_flags;
3374:       top->flag_code = flag_code;
3375:       top->vector_size = vector_size;
3376:       top->stackop_size = stackop_size;
3377:       top->no_cond_jump_promotion = no_cond_jump_promotion;
```

## gas/config/tc-i386.c:7253–7257

```text
7253:   if (xstrdup_copy != line && may_need_pass2 (t))
7254:     {
7255:       /* Make a copy of the full line in case we need to retry.  */
7256:       xstrdup_copy = xstrdup (line);
7257:       copy = xstrdup_copy;
```

## gas/config/tc-i386.c:13365–13447

```text
13365: #if (defined (OBJ_ELF) || defined (OBJ_MACH_O) || defined (TE_PE))
13366: /* Parse operands of the form
13367:    <symbol>@GOTOFF+<nnn>
13368:    and similar .plt or .got references.
13369:
13370:    If we find one, set up the correct relocation in RELOC and copy the
13371:    input string, minus the `@GOTOFF' into a malloc'd buffer for
13372:    parsing by the calling routine.  Return this buffer, and if ADJUST
13373:    is non-null set it to the length of the string we removed from the
13374:    input line.  Otherwise return NULL.  */
13375: static char *
13376: lex_got (enum bfd_reloc_code_real *rel,
13377:          int *adjust,
13378:          i386_operand_type *types)
13379: {
13380:   /* Some of the relocations depend on the size of what field is to
13381:      be relocated.  But in our callers i386_immediate and i386_displacement
13382:      we don't yet know the operand size (this will be set by insn
13383:      matching).  Hence we record the word32 relocation here,
13384:      and adjust the reloc according to the real size in reloc().  */
13385:   char *cp;
13386:   unsigned int j;
13387:
13388:   for (cp = input_line_pointer; *cp != '@'; cp++)
13389:     if (is_end_of_stmt (*cp) || *cp == ',')
13390:       return NULL;
13391:
13392:   for (j = 0; j < ARRAY_SIZE (gotrel); j++)
13393:     {
13394:       int len = gotrel[j].len;
13395:       if (strncasecmp (cp + 1, gotrel[j].str, len) == 0)
13396:         {
13397:           if (gotrel[j].rel[object_64bit] != 0)
13398:             {
13399:               int first, second;
13400:               char *tmpbuf, *past_reloc;
13401:
13402:               i.has_gotrel = true;
13403:               *rel = gotrel[j].rel[object_64bit];
13404:
13405:               if (types)
13406:                 {
13407:                   if (flag_code != CODE_64BIT)
13408:                     {
13409:                       types->bitfield.imm32 = 1;
13410:                       types->bitfield.disp32 = 1;
13411:                     }
13412:                   else
13413:                     *types = gotrel[j].types64;
13414:                 }
13415:
13416:               if (gotrel[j].need_GOT_symbol && GOT_symbol == NULL)
13417:                 GOT_symbol = symbol_find_or_make (GLOBAL_OFFSET_TABLE_NAME);
13418:
13419:               /* The length of the first part of our input line.  */
13420:               first = cp - input_line_pointer;
13421:
13422:               /* The second part goes from after the reloc token until
13423:                  (and including) an end_of_line char or comma.  */
13424:               past_reloc = cp + 1 + len;
13425:               cp = past_reloc;
13426:               while (!is_end_of_stmt (*cp) && *cp != ',')
13427:                 ++cp;
13428:               second = cp + 1 - past_reloc;
13429:
13430:               /* Allocate and copy string.  The trailing NUL shouldn't
13431:                  be necessary, but be safe.  */
13432:               tmpbuf = XNEWVEC (char, first + second + 2);
13433:               memcpy (tmpbuf, input_line_pointer, first);
13434:               if (second != 0 && !is_whitespace (*past_reloc))
13435:                 /* Replace the relocation token with ' ', so that
13436:                    errors like foo@GOTOFF1 will be detected.  */
13437:                 tmpbuf[first++] = ' ';
13438:               else
13439:                 /* Increment length by 1 if the relocation token is
13440:                    removed.  */
13441:                 len++;
13442:               if (adjust)
13443:                 *adjust = len;
13444:               memcpy (tmpbuf + first, past_reloc, second);
13445:               tmpbuf[first + second] = '\0';
13446:               return tmpbuf;
13447:             }
```

## gas/config/tc-i386.c:17049–17091

```text
17049: parse_register (const char *reg_string, char **end_op)
17050: {
17051:   const reg_entry *r;
17052:
17053:   if (*reg_string == REGISTER_PREFIX || allow_naked_reg)
17054:     r = parse_real_register (reg_string, end_op);
17055:   else
17056:     r = NULL;
17057:   if (!r)
17058:     {
17059:       char *save = input_line_pointer;
17060:       char *buf = xstrdup (reg_string), *name;
17061:       symbolS *symbolP;
17062:
17063:       input_line_pointer = buf;
17064:       get_symbol_name (&name);
17065:       symbolP = symbol_find (name);
17066:       while (symbolP && symbol_equated_p (symbolP))
17067:         {
17068:           const expressionS *e = symbol_get_value_expression(symbolP);
17069:
17070:           if (e->X_add_number)
17071:             break;
17072:           symbolP = e->X_add_symbol;
17073:         }
17074:       if (symbolP && S_GET_SEGMENT (symbolP) == reg_section)
17075:         {
17076:           const expressionS *e = symbol_get_value_expression (symbolP);
17077:
17078:           if (e->X_op == O_register)
17079:             {
17080:               know ((valueT) e->X_add_number < i386_regtab_size);
17081:               r = i386_regtab + e->X_add_number;
17082:               *end_op = (char *) reg_string + (input_line_pointer - buf);
17083:             }
17084:           if (r && !check_register (r))
17085:             {
17086:               as_bad (_("register '%s%s' cannot be used here"),
17087:                       register_prefix, r->reg_name);
17088:               r = &bad_reg;
17089:             }
17090:         }
17091:       input_line_pointer = save;
```

## gas/config/obj-elf.c:598–610

```text
598: #endif
599:
600:   /* Switch to the section, creating it if necessary.  */
601:   if (push)
602:     {
603:       struct section_stack *elt;
604:       elt = XNEW (struct section_stack);
605:       elt->next = section_stack;
606:       elt->seg = now_seg;
607:       elt->prev_seg = previous_section;
608:       elt->subseg = now_subseg;
609:       elt->prev_subseg = previous_subsection;
610:       section_stack = elt;
```

## gas/symbols.c:216–216

```text
216: int symbols_case_sensitive = 1;
```

## gas/symbols.c:959–989

```text
959: symbolS *
960: symbol_find_noref (const char *name, int noref)
961: {
962:   symbolS * result;
963:   char * copy = NULL;
964:
965: #ifdef tc_canonicalize_symbol_name
966:   {
967:     copy = xstrdup (name);
968:     name = tc_canonicalize_symbol_name (copy);
969:   }
970: #endif
971:
972:   if (! symbols_case_sensitive)
973:     {
974:       const char *orig;
975:       char *copy2 = NULL;
976:       unsigned char c;
977:
978:       orig = name;
979:       if (copy != NULL)
980:         copy2 = copy;
981:       name = copy = XNEWVEC (char, strlen (name) + 1);
982:
983:       while ((c = *orig++) != '\0')
984:         *copy++ = TOUPPER (c);
985:       *copy = '\0';
986:
987:       free (copy2);
988:       copy = (char *) name;
989:     }
```

## gas/expr.c:125–170

```text
125: /* Look up a previously used .startof. / .sizeof. symbol, or make a fresh
126:    one.  */
127: static symbolS **seen[2];
128: static unsigned int nr_seen[2];
129:
130: static symbolS *
131: symbol_lookup_or_make (const char *name, bool start)
132: {
133:   char *buf = concat (start ? ".startof." : ".sizeof.", name, (char *) NULL);
134:   symbolS *symbolP;
135:   unsigned int i;
136:
137:   for (i = 0; i < nr_seen[start]; ++i)
138:     {
139:     symbolP = seen[start][i];
140:
141:     if (! symbolP)
142:       break;
143:
144:     name = S_GET_NAME (symbolP);
145:     if ((symbols_case_sensitive
146:          ? strcmp (buf, name)
147:          : strcasecmp (buf, name)) == 0)
148:       {
149:         free (buf);
150:         return symbolP;
151:       }
152:     }
153:
154:   symbolP = symbol_make (buf);
155:   free (buf);
156:
157:   if (i >= nr_seen[start])
158:     {
159:       unsigned int nr = (i + 1) * 2;
160:
161:       seen[start] = XRESIZEVEC (symbolS *, seen[start], nr);
162:       nr_seen[start] = nr;
163:       memset (&seen[start][i + 1], 0, (nr - i - 1) * sizeof(seen[0][0]));
164:     }
165:
166:   seen[start][i] = symbolP;
167:
168:   return symbolP;
169: }
170:
```

## gas/write.c:2156–2184

```text
2156:   rsi.pass = 0;
2157:   while (1)
2158:     {
2159: #ifndef WORKING_DOT_WORD
2160:       /* We need to reset the markers in the broken word list and
2161:          associated frags between calls to relax_segment (via
2162:          relax_seg).  Since the broken word list is global, we do it
2163:          once per round, rather than locally in relax_segment for each
2164:          segment.  */
2165:       struct broken_word *brokp;
2166:
2167:       for (brokp = broken_words;
2168:            brokp != NULL;
2169:            brokp = brokp->next_broken_word)
2170:         {
2171:           brokp->added = 0;
2172:
2173:           if (brokp->dispfrag != NULL
2174:               && brokp->dispfrag->fr_type == rs_broken_word)
2175:             brokp->dispfrag->fr_subtype = 0;
2176:         }
2177: #endif
2178:
2179:       rsi.changed = 0;
2180:       bfd_map_over_sections (stdoutput, relax_seg, &rsi);
2181:       rsi.pass++;
2182:       if (!rsi.changed)
2183:         break;
2184:     }
```

## gas/write.c:2681–2784

```text
2681: relax_segment (struct frag *segment_frag_root, segT segment, int pass)
2682: {
2683:   unsigned long frag_count;
2684:   struct frag *fragP;
2685:   relax_addressT address;
2686:   int region;
2687:   int ret;
2688:
2689:   /* In case md_estimate_size_before_relax() wants to make fixSs.  */
2690:   subseg_change (segment, 0);
2691:
2692:   /* For each frag in segment: count and store  (a 1st guess of)
2693:      fr_address.  */
2694:   address = 0;
2695:   region = 0;
2696:   for (frag_count = 0, fragP = segment_frag_root;
2697:        fragP;
2698:        fragP = fragP->fr_next, frag_count ++)
2699:     {
2700:       fragP->region = region;
2701:       fragP->relax_marker = 0;
2702:       fragP->fr_address = address;
2703:       address += fragP->fr_fix;
2704:
2705:       switch (fragP->fr_type)
2706:         {
2707:         case rs_fill:
2708:           address += fragP->fr_offset * fragP->fr_var;
2709:           break;
2710:
2711:         case rs_align:
2712:         case rs_align_code:
2713:         case rs_align_test:
2714:           {
2715:             addressT offset = relax_align (address, (int) fragP->fr_offset);
2716:
2717:             if (fragP->fr_subtype != 0 && offset > fragP->fr_subtype)
2718:               offset = 0;
2719:
2720:             if (offset % fragP->fr_var != 0)
2721:               {
2722:                 as_bad_where (fragP->fr_file, fragP->fr_line,
2723:                               ngettext ("alignment padding (%lu byte) "
2724:                                         "not a multiple of %ld",
2725:                                         "alignment padding (%lu bytes) "
2726:                                         "not a multiple of %ld",
2727:                                         (unsigned long) offset),
2728:                               (unsigned long) offset, (long) fragP->fr_var);
2729:                 offset -= (offset % fragP->fr_var);
2730:               }
2731:
2732:             address += offset;
2733:             region += 1;
2734:           }
2735:           break;
2736:
2737:         case rs_org:
2738:           /* Assume .org is nugatory. It will grow with 1st relax.  */
2739:           region += 1;
2740:           break;
2741:
2742:         case rs_space:
2743:         case rs_space_nop:
2744:           break;
2745:
2746:         case rs_machine_dependent:
2747:           /* If fr_symbol is an expression, this call to
2748:              resolve_symbol_value sets up the correct segment, which will
2749:              likely be needed in md_estimate_size_before_relax.  */
2750:           if (fragP->fr_symbol)
2751:             resolve_symbol_value (fragP->fr_symbol);
2752:
2753:           address += md_estimate_size_before_relax (fragP, segment);
2754:           break;
2755:
2756: #ifndef WORKING_DOT_WORD
2757:           /* Broken words don't concern us yet.  */
2758:         case rs_broken_word:
2759:           break;
2760: #endif
2761:
2762:         case rs_leb128:
2763: #if defined (TE_PE) && defined (O_secrel)
2764:         case rs_cv_comp:
2765: #endif
2766:           /* Initial guess is always 1; doing otherwise can result in
2767:              stable solutions that are larger than the minimum.  */
2768:           address += fragP->fr_offset = 1;
2769:           break;
2770:
2771:         case rs_cfa:
2772:           address += eh_frame_estimate_size_before_relax (fragP);
2773:           break;
2774:
2775:         case rs_dwarf2dbg:
2776:           address += dwarf2dbg_estimate_size_before_relax (fragP);
2777:           break;
2778:
2779:         case rs_sframe:
2780:           /* Initial estimate can be set to atleast 1 byte.  */
2781:           address += sframe_estimate_size_before_relax (fragP);
2782:           break;
2783:
2784:         default:
```

## gas/write.c:2834–2859

```text
2834:        So we dictate that this algorithm can be at most O2.  */
2835:     max_iterations = frag_count * frag_count;
2836:     /* Check for overflow.  */
2837:     if (max_iterations < frag_count)
2838:       max_iterations = frag_count;
2839:
2840:     ret = 0;
2841:     do
2842:       {
2843:         stretch = 0;
2844:         stretched = 0;
2845:
2846:         for (fragP = segment_frag_root; fragP; fragP = fragP->fr_next)
2847:           {
2848:             offsetT growth = 0;
2849:             addressT was_address;
2850:             offsetT offset;
2851:             symbolS *symbolP;
2852:
2853:             fragP->relax_marker ^= 1;
2854:             was_address = fragP->fr_address;
2855:             address = fragP->fr_address += stretch;
2856:             symbolP = fragP->fr_symbol;
2857:             offset = fragP->fr_offset;
2858:
2859:             switch (fragP->fr_type)
```

## gas/write.c:2955–2995

```text
2955:                   /* If this align happens to follow a leb128 and
2956:                      we have determined that the leb128 is bouncing
2957:                      in size, then break the cycle by inserting an
2958:                      extra alignment.  */
2959:                   if (growth < 0
2960:                       && (rs_leb128_fudge & 16) != 0
2961:                       && (rs_leb128_fudge & 15) >= 2)
2962:                     {
2963:                       segment_info_type *seginfo = seg_info (segment);
2964:                       struct obstack *ob = &seginfo->frchainP->frch_obstack;
2965:                       struct frag *newf;
2966:
2967:                       newf = frag_alloc (ob, fragP->fr_var);
2968:                       memcpy (newf, fragP, SIZEOF_STRUCT_FRAG);
2969:                       memcpy (newf->fr_literal,
2970:                               fragP->fr_literal + fragP->fr_fix,
2971:                               fragP->fr_var);
2972:                       newf->fr_type = rs_fill;
2973:                       newf->fr_address = address + fragP->fr_fix + newoff;
2974:                       newf->fr_fix = 0;
2975:                       newf->fr_offset = (((offsetT) 1 << fragP->fr_offset)
2976:                                          / fragP->fr_var);
2977:                       if (newf->fr_offset * newf->fr_var
2978:                           != (offsetT) 1 << fragP->fr_offset)
2979:                         {
2980:                           newf->fr_offset = (offsetT) 1 << fragP->fr_offset;
2981:                           newf->fr_var = 1;
2982:                         }
2983:                       /* Include size of new frag in GROWTH.  */
2984:                       growth += newf->fr_offset * newf->fr_var;
2985:                       /* Adjust the new frag address for the amount
2986:                          we'll add when we process the new frag.  */
2987:                       newf->fr_address -= stretch + growth;
2988:                       newf->relax_marker ^= 1;
2989:                       fragP->fr_next = newf;
2990: #ifdef DEBUG
2991:                       as_warn (_("padding added"));
2992: #endif
2993:                     }
2994:                 }
2995:                 break;
```

## gas/write.c:3145–3183

```text
3145:               }
3146:             if (growth)
3147:               {
3148:                 stretch += growth;
3149:                 stretched = 1;
3150:                 if (fragP->fr_type == rs_leb128)
3151:                   rs_leb128_fudge += 16;
3152:                 else if (fragP->fr_type == rs_align
3153:                          && (rs_leb128_fudge & 16) != 0
3154:                          && stretch == 0)
3155:                   rs_leb128_fudge += 16;
3156:                 else
3157:                   rs_leb128_fudge = 0;
3158:               }
3159:           }
3160:
3161:         if (stretch == 0
3162:             && (rs_leb128_fudge & 16) == 0
3163:             && (rs_leb128_fudge & -16) != 0)
3164:           rs_leb128_fudge += 1;
3165:         else
3166:           rs_leb128_fudge = 0;
3167:       }
3168:     /* Until nothing further to relax.  */
3169:     while (stretched && -- max_iterations);
3170:
3171:     if (stretched)
3172:       as_fatal (_("Infinite loop encountered whilst attempting to compute the addresses of symbols in section %s"),
3173:                 segment_name (segment));
3174:   }
3175:
3176:   for (fragP = segment_frag_root; fragP; fragP = fragP->fr_next)
3177:     if (fragP->last_fr_address != fragP->fr_address)
3178:       {
3179:         fragP->last_fr_address = fragP->fr_address;
3180:         ret = 1;
3181:       }
3182:   return ret;
3183: }
```

## gas/ehopt.c:480–525

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
```

## gas/sframe-opt.c:34–108

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
```
