# GAS predefinition and entry/exit source excerpts

Literal LF numbering.

## gas/as.c:50–59

```text
50: #ifdef HAVE_ITBL_CPU
51: #include "itbl-ops.h"
52: #else
53: #define itbl_init()
54: #endif
55:
56: #ifdef USING_CGEN
57: /* Perform any cgen specific initialisation for gas.  */
58: extern void gas_cgen_begin (void);
59: #endif
```

## gas/as.c:70–75

```text
70:
71: /* True if a listing is wanted.  */
72: int listing;
73:
74: /* Type of debugging to generate.  */
75: enum debug_info_type debug_type = DEBUG_UNSPECIFIED;
```

## gas/as.c:132–132

```text
132: static char *listing_filename = NULL;
```

## gas/as.c:705–711

```text
705:         case OPTION_STRIP_LOCAL_ABSOLUTE:
706:           flag_strip_local_absolute = 1;
707:           break;
708:
709:         case OPTION_EMIT_LOCAL_ABSOLUTE:
710:           flag_strip_local_absolute = -1;
711:           break;
```

## gas/as.c:1203–1220

```text
1203: /* Pre-define a symbol with its name derived from TMPL (wrapping in
1204:    GAS(...)), to value VAL.  */
1205:
1206: void
1207: predefine_symbol (const char *tmpl, valueT val)
1208: {
1209:   char *name = xasprintf ("GAS(%s)", tmpl);
1210:   symbolS *s;
1211:
1212:   /* Also put the symbol in the symbol table, if requested.  */
1213:   if (flag_strip_local_absolute < 0)
1214:     s = symbol_new (name, absolute_section, &zero_address_frag, val);
1215:   else
1216:     s = symbol_create (name, absolute_section, &zero_address_frag, val);
1217:   S_CLEAR_EXTERNAL (s);
1218:   symbol_table_insert (s);
1219:
1220:   xfree (name);
```

## gas/as.c:1254–1295

```text
1254: static void
1255: perform_an_assembly_pass (int argc, char ** argv)
1256: {
1257:   int saw_a_file = 0;
1258:
1259:   need_pass_2 = 0;
1260:
1261: #ifndef OBJ_MACH_O
1262:   subseg_set (text_section, 0);
1263: #endif
1264:
1265:   predefine_symbol ("version", BFD_VERSION);
1266:   if (strstr (BFD_VERSION_STRING, "." XSTRING (BFD_VERSION_DATE)) != NULL)
1267:     predefine_symbol ("date", BFD_VERSION_DATE);
1268:
1269: #ifdef obj_begin
1270:   obj_begin ();
1271: #endif
1272:
1273:   /* This may add symbol table entries, which requires having an open BFD,
1274:      and sections already created.  */
1275:   md_begin ();
1276: #ifdef USING_CGEN
1277:   gas_cgen_begin ();
1278: #endif
1279:
1280:   /* Skip argv[0].  */
1281:   argv++;
1282:   argc--;
1283:
1284:   while (argc--)
1285:     {
1286:       if (*argv)
1287:         {                       /* Is it a file-name argument?  */
1288:           saw_a_file++;
1289:           /* argv->"" if stdin desired, else->filename.  */
1290:           read_a_source_file (*argv);
1291:         }
1292:       argv++;                   /* Completed that argv.  */
1293:     }
1294:   if (!saw_a_file)
1295:     read_a_source_file ("");
```

## gas/as.c:1304–1349

```text
1304: /* Early initialisation, before gas prints messages.  */
1305:
1306: static void
1307: gas_early_init (int *argcp, char ***argvp)
1308: {
1309:   start_time = get_run_time ();
1310:   signal_init ();
1311:
1312: #ifdef HAVE_LC_MESSAGES
1313:   setlocale (LC_MESSAGES, "");
1314: #endif
1315:   setlocale (LC_CTYPE, "");
1316:   bindtextdomain (PACKAGE, LOCALEDIR);
1317:   textdomain (PACKAGE);
1318:
1319:   if (debug_memory)
1320:     chunksize = 64;
1321:
1322: #ifndef OBJ_DEFAULT_OUTPUT_FILE_NAME
1323: #define OBJ_DEFAULT_OUTPUT_FILE_NAME "a.out"
1324: #endif
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
1342:
1343: #ifdef HOST_SPECIAL_INIT
1344:   HOST_SPECIAL_INIT (*argcp, *argvp);
1345: #endif
1346:
1347: #ifdef USE_EMULATIONS
1348:   select_emulation_mode (*argcp, *argvp);
1349: #endif
```

## gas/as.c:1363–1447

```text
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
1403:
1404:   /* Now that we have fully initialized, and have created the output
1405:      file, define any symbols requested by --defsym command line
1406:      arguments.  */
1407:   while (defsyms != NULL)
1408:     {
1409:       symbolS *sym;
1410:       struct defsym_list *next;
1411:
1412:       sym = symbol_new (defsyms->name, absolute_section,
1413:                         &zero_address_frag, defsyms->value);
1414:       /* Make symbols defined on the command line volatile, so that they
1415:          can be redefined inside a source file.  This makes this assembler's
1416:          behaviour compatible with earlier versions, but it may not be
1417:          completely intuitive.  */
1418:       S_SET_VOLATILE (sym);
1419:       symbol_table_insert (sym);
1420:       next = defsyms->next;
1421:       free (defsyms);
1422:       defsyms = next;
1423:     }
1424:
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
1442: #endif
1443:   bfd_std_section_init (BFD_ABS_SECTION_NAME);
1444:   bfd_std_section_init (BFD_UND_SECTION_NAME);
1445:   reg_section = subseg_new ("*GAS `reg' section*", 0);
1446:   expr_section = subseg_new ("*GAS `expr' section*", 0);
1447: }
```

## gas/as.c:1457–1465

```text
1457:   gas_early_init (&argc, &argv);
1458:
1459:   /* Call parse_args before gas_init so that switches like
1460:      --hash-size can be honored.  */
1461:   parse_args (&argc, &argv);
1462:
1463:   if (argc > 1 && stat (out_file_name, &sob) == 0)
1464:     {
1465:       int i;
```

## gas/as.c:1502–1587

```text
1502:   gas_init ();
1503:
1504:   /* Assemble it.  */
1505:   perform_an_assembly_pass (argc, argv);
1506:
1507:   cond_finish_check (-1);
1508:
1509: #ifdef md_finish
1510:   md_finish ();
1511: #endif
1512:
1513: #if defined OBJ_ELF || defined OBJ_MAYBE_ELF
1514:   if ((flag_execstack || flag_noexecstack)
1515:       && OUTPUT_FLAVOR == bfd_target_elf_flavour)
1516:     {
1517:       segT gnustack;
1518:
1519:       gnustack = subseg_new (".note.GNU-stack", 0);
1520:       bfd_set_section_flags (gnustack,
1521:                              SEC_READONLY | (flag_execstack ? SEC_CODE : 0));
1522:
1523:     }
1524: #endif
1525:
1526:   codeview_finish ();
1527:
1528:   /* If we've been collecting dwarf2 .debug_line info, either for
1529:      assembly debugging or on behalf of the compiler, emit it now.  */
1530:   dwarf2_finish ();
1531:
1532:   /* If we constructed dwarf2 .eh_frame info, either via .cfi
1533:      directives from the user or by the backend, emit it now.  */
1534:   cfi_finish ();
1535:
1536:   keep_it = 0;
1537:   if (seen_at_least_1_file ())
1538:     {
1539:       int n_warns, n_errs;
1540:       char warn_msg[50];
1541:       char err_msg[50];
1542:
1543:       write_object_file ();
1544:
1545:       n_warns = had_warnings ();
1546:       n_errs = had_errors ();
1547:
1548:       sprintf (warn_msg,
1549:                ngettext ("%d warning", "%d warnings", n_warns), n_warns);
1550:       sprintf (err_msg,
1551:                ngettext ("%d error", "%d errors", n_errs), n_errs);
1552:       if (flag_fatal_warnings && n_warns != 0)
1553:         {
1554:           if (n_errs == 0)
1555:             as_bad (_("%s, treating warnings as errors"), warn_msg);
1556:           n_errs += n_warns;
1557:         }
1558:
1559:       if (n_errs == 0)
1560:         keep_it = 1;
1561:       else if (flag_always_generate_output)
1562:         {
1563:           /* The -Z flag indicates that an object file should be generated,
1564:              regardless of warnings and errors.  */
1565:           keep_it = 1;
1566:           fprintf (stderr, _("%s, %s, generating bad object file\n"),
1567:                    err_msg, warn_msg);
1568:         }
1569:     }
1570:
1571:   fflush (stderr);
1572:
1573: #ifndef NO_LISTING
1574:   listing_print (listing_filename, argv_orig);
1575: #endif
1576:
1577:   input_scrub_end ();
1578:
1579:   /* Use xexit instead of return, because under VMS environments they
1580:      may not place the same interpretation on the value given.  */
1581:   if (had_errors () != 0)
1582:     xexit (EXIT_FAILURE);
1583:
1584:   /* Only generate dependency file if assembler was successful.  */
1585:   print_dependencies ();
1586:
1587:   xexit (EXIT_SUCCESS);
```

## gas/as.h:344–344

```text
344: COMMON int flag_strip_local_absolute;
```

## gas/symbols.c:330–424

```text
330: symbolS *
331: symbol_new (const char *name, segT segment, fragS *frag, valueT valu)
332: {
333:   symbolS *symbolP = symbol_create (name, segment, frag, valu);
334:
335:   /* Link to end of symbol chain.  */
336:   symbol_append (symbolP, symbol_lastP, &symbol_rootP, &symbol_lastP);
337:
338:   return symbolP;
339: }
340:
341: /* Save a symbol name on a permanent obstack, and convert it according
342:    to the object file format.  */
343:
344: static const char *
345: save_symbol_name (const char *name)
346: {
347:   char *ret;
348:
349:   gas_assert (name != NULL);
350:   ret = notes_strdup (name);
351:
352: #ifdef tc_canonicalize_symbol_name
353:   ret = tc_canonicalize_symbol_name (ret);
354: #endif
355:
356:   if (! symbols_case_sensitive)
357:     {
358:       char *s;
359:
360:       for (s = ret; *s != '\0'; s++)
361:         *s = TOUPPER (*s);
362:     }
363:
364:   return ret;
365: }
366:
367: static void
368: symbol_init (symbolS *symbolP, const char *name, asection *sec,
369:              fragS *frag, valueT valu)
370: {
371:   symbolP->frag = frag;
372:   symbolP->bsym = bfd_make_empty_symbol (stdoutput);
373:   if (symbolP->bsym == NULL)
374:     as_fatal ("bfd_make_empty_symbol: %s", bfd_errmsg (bfd_get_error ()));
375:   symbolP->bsym->name = name;
376:   symbolP->bsym->section = sec;
377:
378:   if (multibyte_handling == multibyte_warn_syms
379:       && ! symbolP->flags.local_symbol
380:       && sec != undefined_section
381:       && ! symbolP->flags.multibyte_warned
382:       && scan_for_multibyte_characters ((const unsigned char *) name,
383:                                         (const unsigned char *) name + strlen (name),
384:                                         false /* Do not warn.  */))
385:     {
386:       as_warn (_("symbol '%s' contains multibyte characters"), name);
387:       symbolP->flags.multibyte_warned = 1;
388:     }
389:
390:   S_SET_VALUE (symbolP, valu);
391:   if (sec == reg_section)
392:     symbolP->x->value.X_op = O_register;
393:
394:   symbol_clear_list_pointers (symbolP);
395:
396:   obj_symbol_new_hook (symbolP);
397:
398: #ifdef tc_symbol_new_hook
399:   tc_symbol_new_hook (symbolP);
400: #endif
401: }
402:
403: /* Create a symbol.  NAME is copied, the caller can destroy/modify.  */
404:
405: symbolS *
406: symbol_create (const char *name, segT segment, fragS *frag, valueT valu)
407: {
408:   const char *preserved_copy_of_name;
409:   symbolS *symbolP;
410:   size_t size;
411:
412:   preserved_copy_of_name = save_symbol_name (name);
413:
414:   size = sizeof (symbolS) + sizeof (struct xsymbol);
415:   symbolP = notes_alloc (size);
416:
417:   /* symbol must be born in some fixed state.  This seems as good as any.  */
418:   memset (symbolP, 0, size);
419:   symbolP->name = preserved_copy_of_name;
420:   symbolP->x = (struct xsymbol *) (symbolP + 1);
421:
422:   symbol_init (symbolP, preserved_copy_of_name, segment, frag, valu);
423:
424:   return symbolP;
```

## gas/symbols.c:714–719

```text
714: symbol_table_insert (symbolS *symbolP)
715: {
716:   know (symbolP);
717:
718:   htab_insert (sy_hash, symbolP, 1);
719: }
```

## gas/symbols.c:1805–1823

```text
1805: /* A static function passed to hash_traverse.  */
1806:
1807: static int
1808: resolve_local_symbol (void **slot, void *arg ATTRIBUTE_UNUSED)
1809: {
1810:   symbol_entry_t *entry = *((symbol_entry_t **) slot);
1811:   if (entry->sy.flags.local_symbol)
1812:     resolve_symbol_value (&entry->sy);
1813:
1814:   return 1;
1815: }
1816:
1817: /* Resolve all local symbols.  */
1818:
1819: void
1820: resolve_local_symbol_values (void)
1821: {
1822:   htab_traverse_noresize (sy_hash, resolve_local_symbol, NULL);
1823: }
```

## gas/config/obj-elf.c:2076–2098

```text
2076: void
2077: elf_obj_read_begin_hook (void)
2078: {
2079: #ifdef NEED_ECOFF_DEBUG
2080:   if (ECOFF_DEBUGGING)
2081:     ecoff_read_begin_hook ();
2082: #endif
2083: }
2084:
2085: void
2086: elf_obj_symbol_new_hook (symbolS *symbolP)
2087: {
2088:   struct elf_obj_sy *sy_obj;
2089:
2090:   sy_obj = symbol_get_obj (symbolP);
2091:   sy_obj->size = NULL;
2092:   sy_obj->versioned_name = NULL;
2093:
2094: #ifdef NEED_ECOFF_DEBUG
2095:   if (ECOFF_DEBUGGING)
2096:     ecoff_symbol_new_hook (symbolP);
2097: #endif
2098: }
```

## gas/config/obj-elf.c:2467–2494

```text
2467: #ifdef INIT_STAB_SECTION
2468:
2469: /* The first entry in a .stabs section is special.  */
2470:
2471: void
2472: obj_elf_init_stab_section (segT stab, segT stabstr)
2473: {
2474:   char *file;
2475:   char *p;
2476:   unsigned int stroff;
2477:
2478:   /* Force the section to align to a longword boundary.  Without this,
2479:      UnixWare ar crashes.  */
2480:   bfd_set_section_alignment (stab, 2);
2481:
2482:   /* Make space for this first symbol.  */
2483:   p = frag_more (12);
2484:   /* Zero it out.  */
2485:   memset (p, 0, 12);
2486:   file = remap_debug_filename (as_where (NULL));
2487:   stroff = get_stab_string_offset (file, stabstr);
2488:   know (stroff == 1 || (stroff == 0 && file[0] == '\0'));
2489:   md_number_to_chars (p, stroff, 4);
2490:   seg_info (stab)->stabu.p = p;
2491:   free (file);
2492: }
2493:
2494: #endif
```

## gas/config/obj-elf.c:2989–3036

```text
2989: elf_begin (void)
2990: {
2991:   asection *s;
2992:
2993:   /* Add symbols for the known sections to the symbol table.  */
2994:   s = bfd_get_section_by_name (stdoutput, TEXT_SECTION_NAME);
2995:   symbol_table_insert (section_symbol (s));
2996:   s = bfd_get_section_by_name (stdoutput, DATA_SECTION_NAME);
2997:   symbol_table_insert (section_symbol (s));
2998:   s = bfd_get_section_by_name (stdoutput, BSS_SECTION_NAME);
2999:   symbol_table_insert (section_symbol (s));
3000:   elf_com_section_ptr = bfd_com_section_ptr;
3001:   previous_section = NULL;
3002:   previous_subsection = 0;
3003:   comment_section = NULL;
3004:   memset (&groups, 0, sizeof (groups));
3005:
3006: #ifdef TC_OBJ_ATTR
3007:   /* Set the object attribute version for the output object to the default
3008:      value supported by the backend.  */
3009:   elf_obj_attr_version (stdoutput)
3010:     = get_elf_backend_data (stdoutput)->default_obj_attr_version;
3011:
3012: #if TC_OBJ_ATTR_v1
3013:   oav1_attr_info_init ();
3014: #endif /* TC_OBJ_ATTR_v1 */
3015: #endif /* TC_OBJ_ATTR */
3016: }
3017:
3018: void
3019: elf_end (void)
3020: {
3021:   while (section_stack)
3022:     {
3023:       struct section_stack *top = section_stack;
3024:       section_stack = top->next;
3025:       free (top);
3026:     }
3027:   if (groups.indexes)
3028:     {
3029:       htab_delete (groups.indexes);
3030:       free (groups.head);
3031:     }
3032:
3033: #if TC_OBJ_ATTR_v1
3034:   oav1_attr_info_exit ();
3035: #endif /* TC_OBJ_ATTR_v1 */
3036: }
```

## gas/config/tc-i386.c:3644–3655

```text
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
```

## gas/config/tc-i386.c:3744–3779

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
3759:
3760:   /* NB: FUSED_JCC_PADDING frag must have sufficient room so that it
3761:      can be turned into BRANCH_PREFIX frag.  */
3762:   if (align_branch_prefix_size > MAX_FUSED_JCC_PADDING_SIZE)
3763:     abort ();
3764: }
3765:
3766: void
3767: i386_print_statistics (FILE *file)
3768: {
3769:   htab_print_statistics (file, "i386 opcode", op_hash);
3770:   htab_print_statistics (file, "i386 register", reg_hash);
3771: }
3772:
3773: void
3774: i386_md_end (void)
3775: {
3776:   htab_delete (op_hash);
3777:   htab_delete (reg_hash);
3778:   GOT_symbol = NULL;
3779: }
```

## gas/config/tc-i386.h:240–242

```text
240:
241: void i386_md_end (void);
242: #define md_end i386_md_end
```

## gas/listing.c:285–295

```text
285: void
286: listing_newline (char *ps)
287: {
288:   const char *file;
289:   unsigned int line;
290:   static unsigned int last_line = 0xffff;
291:   static const char *last_file = NULL;
292:   list_info_type *new_i = NULL;
293:
294:   if (listing == 0)
295:     return;
```

## gas/listing.c:1426–1472

```text
1426: void
1427: listing_print (char *name, char **argv)
1428: {
1429:   int using_stdout;
1430:
1431:   title = "";
1432:   subtitle = "";
1433:
1434:   if (name == NULL)
1435:     {
1436:       list_file = stdout;
1437:       using_stdout = 1;
1438:     }
1439:   else
1440:     {
1441:       list_file = fopen (name, FOPEN_WT);
1442:       if (list_file != NULL)
1443:         using_stdout = 0;
1444:       else
1445:         {
1446:           as_warn (_("can't open %s: %s"), name, xstrerror (errno));
1447:           list_file = stdout;
1448:           using_stdout = 1;
1449:         }
1450:     }
1451:
1452:   if (listing & LISTING_NOFORM)
1453:     paper_height = 0;
1454:
1455:   if (listing & LISTING_GENERAL)
1456:     listing_general_info (argv);
1457:
1458:   if (listing & LISTING_LISTING)
1459:     listing_listing (name);
1460:
1461:   if (listing & LISTING_SYMBOLS)
1462:     list_symbol_table ();
1463:
1464:   if (! using_stdout)
1465:     {
1466:       if (fclose (list_file) == EOF)
1467:         as_warn (_("can't close %s: %s"), name, xstrerror (errno));
1468:     }
1469:
1470:   if (last_open_file)
1471:     fclose (last_open_file);
1472: }
```

## gas/cond.c:547–565

```text
547: void
548: cond_finish_check (int nest)
549: {
550:   if (current_cframe != NULL && current_cframe->macro_nest >= nest)
551:     {
552:       if (nest >= 0)
553:         as_bad (_("end of macro inside conditional"));
554:       else
555:         as_bad (_("end of file inside conditional"));
556:
557:       as_bad_where (current_cframe->if_file_line.file,
558:                     current_cframe->if_file_line.line,
559:                     _("here is the start of the unterminated conditional"));
560:       if (current_cframe->else_seen)
561:         as_bad_where (current_cframe->else_file_line.file,
562:                       current_cframe->else_file_line.line,
563:                       _("here is the \"else\" of the unterminated conditional"));
564:       cond_exit_macro (nest);
565:     }
```

## gas/codeview.c:620–632

```text
620: #else
621:
622: void
623: codeview_finish (void)
624: {
625: }
626:
627: void
628: codeview_generate_asm_lineno (void)
629: {
630: }
631:
632: #endif /* TE_PE && O_secrel */
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

## gas/read.c:947–1036

```text
947: #ifndef NO_LISTING
948:           /* If listing is on, and we are expanding a macro, then give
949:              the listing code the contents of the expanded line.  */
950:           if (listing)
951:             {
952:               if ((listing & LISTING_MACEXP) && macro_nest > 0)
953:                 {
954:                   /* Find the end of the current expanded macro line.  */
955:                   s = find_end_of_line (input_line_pointer, flag_m68k_mri);
956:
957:                   if (s != last_eol
958:                       && !startswith (input_line_pointer,
959:                                       !flag_m68k_mri ? " .linefile "
960:                                                      : " linefile "))
961:                     {
962:                       char *copy;
963:                       size_t len;
964:
965:                       last_eol = s;
966:                       /* Copy it for safe keeping.  Also give an indication of
967:                          how much macro nesting is involved at this point.  */
968:                       len = s - input_line_pointer;
969:                       copy = XNEWVEC (char, len + macro_nest + 2);
970:                       memset (copy, '>', macro_nest);
971:                       copy[macro_nest] = ' ';
972:                       memcpy (copy + macro_nest + 1, input_line_pointer, len);
973:                       copy[macro_nest + 1 + len] = '\0';
974:
975:                       /* Install the line with the listing facility.  */
976:                       listing_newline (copy);
977:                     }
978:                 }
979:               else
980:                 listing_newline (NULL);
981:             }
982: #endif
983:
984:           next_char = *input_line_pointer;
985:           if ((was_new_line & LEX_EOL)
986:              && (strchr (line_comment_chars, '#')
987:                   ? next_char == '#'
988:                   : next_char && strchr (line_comment_chars, next_char)))
989:             {
990:               /* Its a comment.  Check for APP followed by NO_APP.  */
991:               sb sbuf;
992:               char *ends;
993:               size_t len;
994:
995:               s = input_line_pointer + 1;
996:               if (!startswith (s, "APP") || !is_end_of_line (s[3]))
997:                 {
998:                   /* We ignore it.  Note: Not ignore_rest_of_line ()!  */
999:                   while (s <= buffer_limit)
1000:                     if (is_end_of_line (*s++))
1001:                       break;
1002:                   input_line_pointer = s;
1003:                   continue;
1004:                 }
1005:               s += 4;
1006:
1007:               ends = find_no_app (s, next_char);
1008:               len = ends ? ends - s : buffer_limit - s;
1009:
1010:               sb_build (&sbuf, len + 100);
1011:               sb_add_buffer (&sbuf, s, len);
1012:               if (!ends)
1013:                 {
1014:                   /* The end of the #APP wasn't in this buffer.  We
1015:                      keep reading in buffers until we find the #NO_APP
1016:                      that goes with this #APP  There is one.  The specs
1017:                      guarantee it...  */
1018:                   do
1019:                     {
1020:                       buffer_limit = input_scrub_next_buffer (&buffer);
1021:                       if (!buffer_limit)
1022:                         break;
1023:                       ends = find_no_app (buffer, next_char);
1024:                       len = ends ? ends - buffer : buffer_limit - buffer;
1025:                       sb_add_buffer (&sbuf, buffer, len);
1026:                     }
1027:                   while (!ends);
1028:                 }
1029:               sb_add_char (&sbuf, '\n');
1030:
1031:               input_line_pointer = ends ? ends + 8 : NULL;
1032:               input_scrub_include_sb (&sbuf, input_line_pointer, expanding_app);
1033:               sb_kill (&sbuf);
1034:               buffer_limit = input_scrub_next_buffer (&input_line_pointer);
1035:               continue;
1036:             }
```

## gas/input-file.c:79–95

```text
79: char *
80: input_file_push (void)
81: {
82:   struct saved_file *saved;
83:
84:   saved = XNEW (struct saved_file);
85:
86:   saved->f_in = f_in;
87:   saved->file_name = file_name;
88:   saved->preprocess = preprocess;
89:   if (preprocess)
90:     saved->app_save = app_push ();
91:
92:   /* Initialize for new file.  */
93:   input_file_begin ();
94:
95:   return (char *) saved;
```

## gas/input-scrub.c:141–169

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
152:
153: /* Finish off old buffers.  */
154:
155: static void
156: input_scrub_free (void)
157: {
158:   if (sb_index != (size_t) -1)
159:     {
160:       sb_kill (&from_sb);
161:       sb_index = -1;
162:     }
163:   free (buffer_start);
164:   buffer_start = NULL;
165:   input_file_end ();
166: }
167:
168: /* Push the state of input reading and scrubbing so that we can #include.
169:    The return value is a 'void *' (fudged for old compilers) to a save
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

## gas/app.c:169–269

```text
169: do_scrub_begin (int m68k_mri ATTRIBUTE_UNUSED)
170: {
171:   const char *p;
172:
173:   /* Latch this once at start.  xtensa uses a hook function, yet context isn't
174:      meaningful for scrubbing (or else we'd need to sync scrubber behavior as
175:      state changes).  */
176:   if (lex['/'] == 0)
177:     no_pseudo_dot = NO_PSEUDO_DOT;
178:
179: #ifdef TC_M68K
180:   scrub_m68k_mri = m68k_mri;
181:
182:   if (! m68k_mri)
183: #endif
184:     {
185:       lex['"'] = LEX_IS_STRINGQUOTE;
186:
187: #if ! defined (TC_HPPA)
188:       lex['\''] = LEX_IS_ONECHAR_QUOTE;
189: #endif
190:
191: #ifdef SINGLE_QUOTE_STRINGS
192:       lex['\''] = LEX_IS_STRINGQUOTE;
193: #endif
194:     }
195:
196:   /* Note: if any other character can be LEX_IS_STRINGQUOTE, the loop
197:      in state 5 of do_scrub_chars must be changed.  */
198:
199:   /* Note that these override the previous defaults, e.g. if ';' is a
200:      comment char, then it isn't a line separator.  */
201:
202: #ifdef tc_symbol_chars
203:   /* This macro permits the processor to specify all characters which
204:      may appears in an operand.  This will prevent the scrubber from
205:      discarding meaningful whitespace in certain cases.  The i386
206:      backend uses this to support prefixes, which can confuse the
207:      scrubber as to whether it is parsing operands or opcodes.  */
208:   for (p = tc_symbol_chars; *p; ++p)
209:     lex[(unsigned char) *p] = LEX_IS_SYMBOL_COMPONENT;
210: #endif
211:
212:   /* The m68k backend wants to be able to change comment_chars.  */
213: #ifndef tc_comment_chars
214: #define tc_comment_chars comment_chars
215: #endif
216:   for (p = tc_comment_chars; *p; p++)
217:     lex[(unsigned char) *p] = LEX_IS_COMMENT_START;
218:
219:   /* While counter intuitive to have more special purpose line comment chars
220:      override more general purpose ordinary ones, logic in do_scrub_chars()
221:      depends on this ordering.   */
222:   for (p = line_comment_chars; *p; p++)
223:     lex[(unsigned char) *p] = LEX_IS_LINE_COMMENT_START;
224:
225: #ifndef tc_line_separator_chars
226: #define tc_line_separator_chars line_separator_chars
227: #endif
228:   for (p = tc_line_separator_chars; *p; p++)
229:     lex[(unsigned char) *p] = LEX_IS_LINE_SEPARATOR;
230:
231: #ifdef tc_parallel_separator_chars
232:   /* This macro permits the processor to specify all characters which
233:      separate parallel insns on the same line.  */
234:   for (p = tc_parallel_separator_chars; *p; p++)
235:     lex[(unsigned char) *p] = LEX_IS_PARALLEL_SEPARATOR;
236: #endif
237:
238:   /* Only allow slash-star comments if slash is not in use.  Certain
239:      other cases are dealt with in LEX_IS_LINE_COMMENT_START handling.
240:      FIXME: This isn't right.  We should always permit them.  */
241:   if (lex['/'] == 0)
242:     lex['/'] = LEX_IS_TWOCHAR_COMMENT_1ST;
243:
244: #ifdef TC_M68K
245:   if (m68k_mri)
246:     {
247:       lex['\''] = LEX_IS_STRINGQUOTE;
248:       lex[';'] = LEX_IS_COMMENT_START;
249:       lex['*'] = LEX_IS_LINE_COMMENT_START;
250:       /* The MRI documentation says '!' is LEX_IS_COMMENT_START, but
251:          then it can't be used in an expression.  */
252:       lex['!'] = LEX_IS_LINE_COMMENT_START;
253:     }
254: #endif
255:
256: #ifdef TC_V850
257:   lex['-'] = LEX_IS_DOUBLEDASH_1ST;
258: #endif
259: #ifdef DOUBLEBAR_PARALLEL
260:   lex['|'] = LEX_IS_DOUBLEBAR_1ST;
261: #endif
262:
263: #ifdef H_TICK_HEX
264:   if (enable_h_tick_hex)
265:     {
266:       lex['h'] = LEX_IS_H;
267:       lex['H'] = LEX_IS_H;
268:     }
269: #endif
```

## gas/app.c:307–326

```text
307:
308: char *
309: app_push (void)
310: {
311:   struct app_save *saved;
312:
313:   saved = XNEW (struct app_save);
314:   saved->state = state;
315:   saved->old_state = old_state;
316:   saved->out_string = out_string;
317:   memcpy (saved->out_buf, out_buf, sizeof (out_buf));
318:   saved->add_newlines = add_newlines;
319:   if (saved_input == NULL)
320:     saved->saved_input = NULL;
321:   else
322:     {
323:       saved->saved_input = XNEWVEC (char, saved_input_len);
324:       memcpy (saved->saved_input, saved_input, saved_input_len);
325:       saved->saved_input_len = saved_input_len;
326:     }
```

## gas/remap.c:73–85

```text
73: remap_debug_filename (const char *filename)
74: {
75:   debug_prefix_map *map;
76:
77:   for (map = debug_prefix_maps; map; map = map->next)
78:     if (filename_ncmp (filename, map->old_prefix, map->old_len) == 0)
79:       {
80:         const char *name = filename + map->old_len;
81:         return concat (map->new_prefix, name, (const char *) NULL);
82:       }
83:
84:   return xstrdup (filename);
85: }
```

## gas/depend.c:57–74

```text
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

## gas/depend.c:183–190

```text
183: print_dependencies (void)
184: {
185:   FILE *f;
186:   struct dependency *dep;
187:
188:   if (dep_file == NULL)
189:     return;
190:
```

## gas/output-file.c:33–53

```text
33: void
34: output_file_create (const char *name)
35: {
36:   if (name[0] == '-' && name[1] == '\0')
37:     as_fatal (_("can't open a bfd on stdout %s"), name);
38:
39:   else if (!(stdoutput = bfd_openw (name, TARGET_FORMAT)))
40:     {
41:       bfd_error_type err = bfd_get_error ();
42:
43:       if (err == bfd_error_invalid_target)
44:         as_fatal (_("selected target format '%s' unknown"), TARGET_FORMAT);
45:       else
46:         as_fatal (_("can't create %s: %s"), name, bfd_errmsg (err));
47:     }
48:
49:   bfd_set_format (stdoutput, bfd_object);
50:   bfd_set_arch_mach (stdoutput, TARGET_ARCH, TARGET_MACH);
51:   if (flag_traditional_format)
52:     stdoutput->flags |= BFD_TRADITIONAL_FORMAT;
53: }
```

## gas/output-file.c:69–124

```text
69: output_file_close (void)
70: {
71:   bool res;
72:   bfd *obfd = stdoutput;
73:   struct obstack **obs;
74:   asection *sec;
75:   const char *filename;
76:
77:   if (obfd == NULL)
78:     return;
79:
80:   /* Prevent an infinite loop - if the close failed we will call as_fatal
81:      which will call xexit() which may call this function again...  */
82:   stdoutput = NULL;
83:
84:   /* We can't free obstacks attached to the output bfd sections before
85:      closing the output bfd since data in those obstacks may need to
86:      be accessed, but we can't access anything in the output bfd after
87:      it is closed..  */
88:   for (sec = obfd->sections; sec; sec = sec->next)
89:     stash_frchain_obs (sec);
90:   stash_frchain_obs (reg_section);
91:   stash_frchain_obs (expr_section);
92:   stash_frchain_obs (bfd_abs_section_ptr);
93:   stash_frchain_obs (bfd_und_section_ptr);
94:   obstack_ptr_grow (&notes, NULL);
95:   obs = obstack_finish (&notes);
96:
97:   /* Close the bfd.  */
98:   if (!flag_always_generate_output && had_errors ())
99:     res = bfd_close_all_done (obfd);
100:   else
101:     res = bfd_close (obfd);
102:   now_seg = NULL;
103:   now_subseg = 0;
104:
105:   filename = out_file_name;
106:   out_file_name = NULL;
107:   if (!keep_it && filename)
108:     unlink_if_ordinary (filename);
109:
110: #ifdef md_end
111:   md_end ();
112: #endif
113: #ifdef obj_end
114:   obj_end ();
115: #endif
116:   macro_end ();
117:   expr_end ();
118:   read_end ();
119:   symbol_end ();
120:   subsegs_end (obs);
121:
122:   if (!res)
123:     as_fatal ("%s: %s", filename, bfd_errmsg (bfd_get_error ()));
124: }
```

## libiberty/argv.c:359–396

```text
359: expandargv (int *argcp, char ***argvp)
360: {
361:   /* The argument we are currently processing.  */
362:   int i = 0;
363:   /* To check if ***argvp has been dynamically allocated.  */
364:   char ** const original_argv = *argvp;
365:   /* Limit the number of response files that we parse in order
366:      to prevent infinite recursion.  */
367:   unsigned int iteration_limit = 2000;
368:   /* Loop over the arguments, handling response files.  We always skip
369:      ARGVP[0], as that is the name of the program being run.  */
370:   while (++i < *argcp)
371:     {
372:       /* The name of the response file.  */
373:       const char *filename;
374:       /* The response file.  */
375:       FILE *f;
376:       /* An upper bound on the number of characters in the response
377:          file.  */
378:       long pos;
379:       /* The number of characters in the response file, when actually
380:          read.  */
381:       size_t len;
382:       /* A dynamically allocated buffer used to hold options read from a
383:          response file.  */
384:       char *buffer;
385:       /* Dynamically allocated storage for the options read from the
386:          response file.  */
387:       char **file_argv;
388:       /* The number of options read from the response file, if any.  */
389:       size_t file_argc;
390: #ifdef S_ISDIR
391:       struct stat sb;
392: #endif
393:       /* We are only interested in options of the form "@file".  */
394:       filename = (*argvp)[i];
395:       if (filename[0] != '@')
396:         continue;
```

## libiberty/xasprintf.c:41–51

```text
41: char *
42: xasprintf (const char *fmt, ...)
43: {
44:   char *buf;
45:   va_list ap;
46:   va_start (ap, fmt);
47:   buf = xvasprintf (fmt, ap);
48:   va_end (ap);
49:   return buf;
50: }
51:
```

## libiberty/xvasprintf.c:48–61

```text
48: char *
49: xvasprintf (const char *format,
50: #if defined (_BSD_VA_LIST_) && defined (__FreeBSD__)
51:            _BSD_VA_LIST_ args)
52: #else
53:            va_list args)
54: #endif
55: {
56:   char *result;
57:   int total_width = libiberty_vprintf_buffer_size (format, args);
58:   result = (char *) xmalloc (total_width);
59:   vsprintf (result, format, args);
60:   return result;
61: }
```

## libiberty/vprintf-support.c:40–68

```text
40: int
41: libiberty_vprintf_buffer_size (const char *format, va_list args)
42: {
43:   const char *p = format;
44:   /* Add one to make sure that it is never zero, which might cause malloc
45:      to return NULL.  */
46:   int total_width = strlen (format) + 1;
47:   va_list ap;
48:
49: #ifdef va_copy
50:   va_copy (ap, args);
51: #else
52:   memcpy ((void *) &ap, (void *) &args, sizeof (va_list));
53: #endif
54:
55:   while (*p != '\0')
56:     {
57:       if (*p++ == '%')
58:         {
59:           int prec = 0;
60:           while (strchr ("-+ #0", *p))
61:             ++p;
62:           if (*p == '*')
63:             {
64:               ++p;
65:               total_width += abs (va_arg (ap, int));
66:             }
67:           else
68:             total_width += strtoul (p, (char **) &p, 10);
```

## libiberty/vprintf-support.c:117–119

```text
117:           /* Should be big enough for any format specifier except %s and floats.  */
118:           total_width += 30;
119:           switch (*p)
```

## libiberty/vprintf-support.c:157–159

```text
157:             case 's':
158:               total_width += strlen (va_arg (ap, char *));
159:               break;
```

## bfd/bfd.c:818–829

```text
818: static THREAD_LOCAL bfd_error_type bfd_error;
819: static THREAD_LOCAL char *_bfd_error_buf;
820:
821: /* Free any data associated with the BFD error.  */
822:
823: static void
824: _bfd_clear_error_data (void)
825: {
826:   bfd_error = bfd_error_no_error;
827:   free (_bfd_error_buf);
828:   _bfd_error_buf = NULL;
829: }
```

## bfd/bfd.c:1962–1969

```text
1962: unsigned int
1963: bfd_init (void)
1964: {
1965:   _bfd_clear_error_data ();
1966:   _bfd_error_internal = error_handler_fprintf;
1967:   _bfd_assert_handler = _bfd_default_assert_handler;
1968:
1969:   return BFD_INIT_MAGIC;
```

## bfd/targets.c:1473–1497

```text
1473: static const bfd_target *
1474: find_target (const char *name)
1475: {
1476:   const bfd_target * const *target;
1477:   const struct targmatch *match;
1478:
1479:   for (target = &bfd_target_vector[0]; *target != NULL; target++)
1480:     if (strcmp (name, (*target)->name) == 0)
1481:       return *target;
1482:
1483:   /* If we couldn't match on the exact name, try matching on the
1484:      configuration triplet.  FIXME: We should run the triplet through
1485:      config.sub first, but that is hard.  */
1486:   for (match = &bfd_target_match[0]; match->triplet != NULL; match++)
1487:     {
1488:       if (fnmatch (match->triplet, name, 0) == 0)
1489:         {
1490:           while (match->vector == NULL)
1491:             ++match;
1492:           return match->vector;
1493:         }
1494:     }
1495:
1496:   bfd_set_error (bfd_error_invalid_target);
1497:   return NULL;
```

## bfd/targets.c:1551–1586

```text
1551: bfd_find_target (const char *target_name, bfd *abfd)
1552: {
1553:   const char *targname;
1554:   const bfd_target *target;
1555:
1556:   if (target_name != NULL)
1557:     targname = target_name;
1558:   else
1559:     targname = getenv ("GNUTARGET");
1560:
1561:   /* This is safe; the vector cannot be null.  */
1562:   if (targname == NULL || strcmp (targname, "default") == 0)
1563:     {
1564:       if (bfd_default_vector[0] != NULL)
1565:         target = bfd_default_vector[0];
1566:       else
1567:         target = bfd_target_vector[0];
1568:       if (abfd)
1569:         {
1570:           abfd->xvec = target;
1571:           abfd->target_defaulted = true;
1572:         }
1573:       return target;
1574:     }
1575:
1576:   if (abfd)
1577:     abfd->target_defaulted = false;
1578:
1579:   target = find_target (targname);
1580:   if (target == NULL)
1581:     return NULL;
1582:
1583:   if (abfd)
1584:     abfd->xvec = target;
1585:   return target;
1586: }
```

## bfd/cache.c:556–591

```text
556: static bool
557: _bfd_cache_init_unlocked (bfd *abfd)
558: {
559:   BFD_ASSERT (abfd->iostream != NULL);
560:   if (open_files >= bfd_cache_max_open ())
561:     {
562:       if (! close_one ())
563:         return false;
564:     }
565:   abfd->iovec = &cache_iovec;
566:   insert (abfd);
567:   abfd->flags &= ~BFD_CLOSED_BY_CACHE;
568:   ++open_files;
569:   return true;
570: }
571:
572: /*
573: INTERNAL_FUNCTION
574:         bfd_cache_init
575:
576: SYNOPSIS
577:         bool bfd_cache_init (bfd *abfd);
578:
579: DESCRIPTION
580:         Add a newly opened BFD to the cache.
581: */
582:
583: bool
584: bfd_cache_init (bfd *abfd)
585: {
586:   if (!bfd_lock ())
587:     return false;
588:   bool result = _bfd_cache_init_unlocked (abfd);
589:   if (!bfd_unlock ())
590:     return false;
591:   return result;
```
