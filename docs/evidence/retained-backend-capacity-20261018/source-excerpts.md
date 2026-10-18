# Pinned native backend source excerpts
LF line numbering; complete file identities checked.

## gcc/ada/back_end.adb:123–130
```text
123:       --  The back end needs to know the maximum line number that can appear
124:       --  in a Sloc, in other words the maximum logical line number.
125:
126:       for J in 1 .. Last_Source_File loop
127:          File_Info_Array (J).File_Name        := Full_Debug_Name (J);
128:          File_Info_Array (J).Instance         := Instance (J);
129:          File_Info_Array (J).Num_Source_Lines :=
130:            Nat (Physical_To_Logical (Last_Source_Line (J), J));
```

## gcc/ada/back_end.adb:155–175
```text
155:       --  The actual call to the back end
156:
157:       gigi
158:         (gnat_root          => Int (Cunit (Main_Unit)),
159:          max_gnat_node      => Int (Last_Node_Id - First_Node_Id + 1),
160:          number_name        => Name_Entries_Count,
161:          node_offsets_ptr   => Node_Offsets_Address,
162:          slots_ptr          => Slots_Address,
163:
164:          next_node_ptr      => Next_Node_Address,
165:          prev_node_ptr      => Prev_Node_Address,
166:          elists_ptr         => Elists_Address,
167:          elmts_ptr          => Elmts_Address,
168:
169:          strings_ptr        => Strings_Address,
170:          string_chars_ptr   => String_Chars_Address,
171:          list_headers_ptr   => Lists_Address,
172:          number_file        => Num_Source_Files,
173:
174:          file_info_ptr                 => File_Info_Array'Address,
175:          gigi_standard_address         => Standard_Address,
```

## gcc/ada/gcc-interface/trans.cc:87–91
```text
87: /* We should avoid allocating more than ALLOCA_THRESHOLD bytes via alloca,
88:    for fear of running out of stack space.  If we need more, we use xmalloc
89:    instead.  */
90: #define ALLOCA_THRESHOLD 1000
91:
```

## gcc/ada/gcc-interface/trans.cc:346–363
```text
346:   for (i = 0; i < number_file; i++)
347:     {
348:       /* We rely on the order isomorphism between files and line maps.  */
349:       if ((int) LINEMAPS_ORDINARY_USED (line_table) != i)
350: 	{
351: 	  gcc_assert (i > 0);
352: 	  error ("%s contains too many lines",
353: 		 File_Name_to_gnu (file_info_ptr[i - 1].File_Name));
354: 	}
355:
356:       /* We create the line map for a source file at once, with a fixed number
357: 	 of columns chosen to avoid jumping over the next power of 2.  */
358:       linemap_add (line_table, LC_ENTER, 0,
359: 		   File_Name_to_gnu (file_info_ptr[i].File_Name), 1);
360:       linemap_line_start (line_table, file_info_ptr[i].Num_Source_Lines, 252);
361:       linemap_position_for_column (line_table, 252 - 1);
362:       linemap_add (line_table, LC_LEAVE, 0, NULL, 0);
363:     }
```

## gcc/ada/gcc-interface/trans.cc:6705–6732
```text
6705:     case N_String_Literal:
6706:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
6707:       if (TYPE_PRECISION (TREE_TYPE (gnu_result_type)) == HOST_BITS_PER_CHAR)
6708: 	{
6709: 	  String_Id gnat_string = Strval (gnat_node);
6710: 	  int length = String_Length (gnat_string);
6711: 	  int i;
6712: 	  char *string;
6713: 	  if (length >= ALLOCA_THRESHOLD)
6714: 	    string = XNEWVEC (char, length);
6715: 	  else
6716: 	    string = (char *) alloca (length);
6717:
6718: 	  /* Build the string with the characters in the literal.  Note
6719: 	     that Ada strings are 1-origin.  */
6720: 	  for (i = 0; i < length; i++)
6721: 	    string[i] = Get_String_Char (gnat_string, i + 1);
6722:
6723: 	  gnu_result = build_string (length, string);
6724:
6725: 	  /* Strings in GCC don't normally have types, but we want
6726: 	     this to not be converted to the array type.  */
6727: 	  TREE_TYPE (gnu_result) = gnu_result_type;
6728:
6729: 	  if (length >= ALLOCA_THRESHOLD)
6730: 	    free (string);
6731: 	}
6732:       else
```

## gcc/ada/gcc-interface/trans.cc:11006–11030
```text
11006: Sloc_to_locus (Source_Ptr Sloc, location_t *locus, bool clear_column,
11007: 	       const_tree decl)
11008: {
11009:   if (Sloc == No_Location)
11010:     return false;
11011:
11012:   if (Sloc <= Standard_Location)
11013:     {
11014:       *locus = BUILTINS_LOCATION;
11015:       return false;
11016:     }
11017:
11018:   Source_File_Index file = Get_Source_File_Index (Sloc);
11019:   Line_Number_Type line = Get_Logical_Line_Number (Sloc);
11020:   Column_Number_Type column = (clear_column ? 0 : Get_Column_Number (Sloc));
11021:   line_map_ordinary *map = LINEMAPS_ORDINARY_MAP_AT (line_table, file - 1);
11022:
11023:   /* We can have zero if pragma Source_Reference is in effect.  */
11024:   if (line < 1)
11025:     line = 1;
11026:
11027:   /* Translate the location.  */
11028:   *locus
11029:     = linemap_position_for_line_and_column (line_table, map, line, column);
11030:
```

## gcc/ada/gcc-interface/misc.cc:376–377
```text
376:   /* In Ada, we do not use location ranges.  */
377:   line_table->default_range_bits = 0;
```

## gcc/tree.cc:2616–2636
```text
2616: build_string (unsigned len, const char *str /*= NULL */)
2617: {
2618:   /* Do not waste bytes provided by padding of struct tree_string.  */
2619:   unsigned size = len + offsetof (struct tree_string, str) + 1;
2620:
2621:   record_node_allocation_statistics (STRING_CST, size);
2622:
2623:   tree s = (tree) ggc_internal_alloc (size);
2624:
2625:   memset (s, 0, sizeof (struct tree_typed));
2626:   TREE_SET_CODE (s, STRING_CST);
2627:   TREE_CONSTANT (s) = 1;
2628:   TREE_STRING_LENGTH (s) = len;
2629:   if (str)
2630:     memcpy (s->string.str, str, len);
2631:   else
2632:     memset (s->string.str, 0, len);
2633:   s->string.str[len] = '\0';
2634:
2635:   return s;
2636: }
```

## gcc/tree-core.h:1138–1253
```text
1138: struct GTY(()) tree_base {
1139:   ENUM_BITFIELD(tree_code) code : 16;
1140:
1141:   unsigned side_effects_flag : 1;
1142:   unsigned constant_flag : 1;
1143:   unsigned addressable_flag : 1;
1144:   unsigned volatile_flag : 1;
1145:   unsigned readonly_flag : 1;
1146:   unsigned asm_written_flag: 1;
1147:   unsigned nowarning_flag : 1;
1148:   unsigned visited : 1;
1149:
1150:   unsigned used_flag : 1;
1151:   unsigned nothrow_flag : 1;
1152:   unsigned static_flag : 1;
1153:   unsigned public_flag : 1;
1154:   unsigned private_flag : 1;
1155:   unsigned protected_flag : 1;
1156:   unsigned deprecated_flag : 1;
1157:   unsigned default_def_flag : 1;
1158:
1159:   union {
1160:     /* The bits in the following structure should only be used with
1161:        accessor macros that constrain inputs with tree checking.  */
1162:     struct {
1163:       unsigned lang_flag_0 : 1;
1164:       unsigned lang_flag_1 : 1;
1165:       unsigned lang_flag_2 : 1;
1166:       unsigned lang_flag_3 : 1;
1167:       unsigned lang_flag_4 : 1;
1168:       unsigned lang_flag_5 : 1;
1169:       unsigned lang_flag_6 : 1;
1170:       unsigned saturating_flag : 1;
1171:
1172:       unsigned unsigned_flag : 1;
1173:       unsigned packed_flag : 1;
1174:       unsigned user_align : 1;
1175:       unsigned nameless_flag : 1;
1176:       unsigned atomic_flag : 1;
1177:       unsigned unavailable_flag : 1;
1178:       unsigned spare0 : 2;
1179:
1180:       unsigned spare1 : 8;
1181:
1182:       /* For _TYPE nodes, this is TYPE_ADDR_SPACE; the reason it is
1183: 	 present in tree_base instead of tree_type is to save space.  The size
1184: 	 of the field must be large enough to hold addr_space_t values.
1185: 	 For CONSTRUCTOR nodes this holds the clobber_kind enum.
1186: 	 The C++ front-end uses this in IDENTIFIER_NODE, REFLECT_EXPR, and
1187: 	 NAMESPACE_DECL.  */
1188:       unsigned address_space : 8;
1189:     } bits;
1190:
1191:     /* The following fields are present in tree_base to save space.  The
1192:        nodes using them do not require any of the flags above and so can
1193:        make better use of the 4-byte sized word.  */
1194:
1195:     /* The number of HOST_WIDE_INTs in an INTEGER_CST.  */
1196:     struct {
1197:       /* The number of HOST_WIDE_INTs if the INTEGER_CST is accessed in
1198: 	 its native precision.  */
1199:       unsigned short unextended;
1200:
1201:       /* The number of HOST_WIDE_INTs if the INTEGER_CST is extended to
1202: 	 wider precisions based on its TYPE_SIGN.  */
1203:       unsigned short extended;
1204:     } int_length;
1205:
1206:     /* VEC length.  This field is only used with TREE_VEC.  */
1207:     int length;
1208:
1209:     /* This field is only used with VECTOR_CST.  */
1210:     struct {
1211:       /* The value of VECTOR_CST_LOG2_NPATTERNS.  */
1212:       unsigned int log2_npatterns : 8;
1213:
1214:       /* The value of VECTOR_CST_NELTS_PER_PATTERN.  */
1215:       unsigned int nelts_per_pattern : 8;
1216:
1217:       /* For future expansion.  */
1218:       unsigned int unused : 16;
1219:     } vector_cst;
1220:
1221:     /* SSA version number.  This field is only used with SSA_NAME.  */
1222:     unsigned int version;
1223:
1224:     /* CHREC_VARIABLE.  This field is only used with POLYNOMIAL_CHREC.  */
1225:     unsigned int chrec_var;
1226:
1227:     /* Internal function code.  */
1228:     enum internal_fn ifn;
1229:
1230:     /* OMP_ATOMIC* memory order.  */
1231:     enum omp_memory_order omp_atomic_memory_order;
1232:
1233:     /* The following two fields are used for MEM_REF and TARGET_MEM_REF
1234:        expression trees and specify known data non-dependences.  For
1235:        two memory references in a function they are known to not
1236:        alias if dependence_info.clique are equal and dependence_info.base
1237:        are distinct.  Clique number zero means there is no information,
1238:        clique number one is populated from function global information
1239:        and thus needs no remapping on transforms like loop unrolling.  */
1240:     struct {
1241:       unsigned short clique;
1242:       unsigned short base;
1243:     } dependence_info;
1244:   } GTY((skip(""))) u;
1245: };
1246:
1247: /* The following table lists the uses of each of the above flags and
1248:    for which types of nodes they are defined.
1249:
1250:    addressable_flag:
1251:
1252:        TREE_ADDRESSABLE in
1253:            VAR_DECL, PARM_DECL, RESULT_DECL, FUNCTION_DECL, LABEL_DECL
```

## gcc/tree-core.h:1565–1595
```text
1565: struct GTY(()) tree_typed {
1566:   struct tree_base base;
1567:   tree type;
1568: };
1569:
1570: struct GTY(()) tree_common {
1571:   struct tree_typed typed;
1572:   tree chain;
1573: };
1574:
1575: struct GTY(()) tree_int_cst {
1576:   struct tree_typed typed;
1577:   HOST_WIDE_INT val[1];
1578: };
1579:
1580:
1581: struct GTY(()) tree_real_cst {
1582:   struct tree_typed typed;
1583:   struct real_value value;
1584: };
1585:
1586: struct GTY(()) tree_fixed_cst {
1587:   struct tree_typed typed;
1588:   struct fixed_value * fixed_cst_ptr;
1589: };
1590:
1591: struct GTY(()) tree_string {
1592:   struct tree_typed typed;
1593:   int length;
1594:   char str[1];
1595: };
```

## gcc/varasm.cc:870–920
```text
870:
871:   if (HAVE_GAS_SHF_MERGE && flag_merge_constants
872:       && TREE_CODE (decl) == STRING_CST
873:       && TREE_CODE (TREE_TYPE (decl)) == ARRAY_TYPE
874:       && align <= MAX_MERGEABLE_BITSIZE
875:       && (len = int_size_in_bytes (TREE_TYPE (decl))) > 0
876:       && TREE_STRING_LENGTH (decl) == len)
877:     {
878:       scalar_int_mode mode;
879:       unsigned int modesize;
880:       const char *str;
881:       HOST_WIDE_INT i;
882:       int j, unit;
883:       const char *prefix = function_mergeable_rodata_prefix ();
884:       char *name = (char *) alloca (strlen (prefix) + 30);
885:
886:       mode = SCALAR_INT_TYPE_MODE (TREE_TYPE (TREE_TYPE (decl)));
887:       modesize = GET_MODE_BITSIZE (mode);
888:       if (modesize >= 8 && modesize <= MAX_MERGEABLE_BITSIZE
889: 	  && (modesize & (modesize - 1)) == 0)
890: 	{
891: 	  if (align < modesize)
892: 	    align = modesize;
893:
894: 	  str = TREE_STRING_POINTER (decl);
895: 	  unit = GET_MODE_SIZE (mode);
896:
897: 	  /* Check for embedded NUL characters.  */
898: 	  for (i = 0; i < len; i += unit)
899: 	    {
900: 	      for (j = 0; j < unit; j++)
901: 		if (str[i + j] != '\0')
902: 		  break;
903: 	      if (j == unit)
904: 		break;
905: 	    }
906: 	  if (i == len - unit || (unit == 1 && i == len))
907: 	    {
908: 	      sprintf (name, "%s.str%d.%d", prefix,
909: 		       modesize / BITS_PER_UNIT, (int) (align / BITS_PER_UNIT));
910: 	      flags |= (modesize / BITS_PER_UNIT) | SECTION_MERGE | SECTION_STRINGS;
911: 	      return get_section (name, flags, NULL);
912: 	    }
913: 	}
914:     }
915:
916:   return readonly_data_section;
917: }
918:
919: /* Return the section to use for constant merging.  */
920:
```

## gcc/varasm.cc:2304–2335
```text
2304: void
2305: assemble_string (const char *p, int size)
2306: {
2307:   int pos = 0;
2308: #if defined(BASE64_ASM_OP) \
2309:     && BITS_PER_UNIT == 8 \
2310:     && CHAR_BIT == 8 \
2311:     && 'A' == 65 \
2312:     && 'a' == 97 \
2313:     && '0' == 48 \
2314:     && '+' == 43 \
2315:     && '/' == 47 \
2316:     && '=' == 61
2317:   int maximum = 16384;
2318: #else
2319:   int maximum = 2000;
2320: #endif
2321:
2322:   /* If the string is very long, split it up.  */
2323:
2324:   while (pos < size)
2325:     {
2326:       int thissize = size - pos;
2327:       if (thissize > maximum)
2328: 	thissize = maximum;
2329:
2330:       ASM_OUTPUT_ASCII (asm_out_file, p, thissize);
2331:
2332:       pos += thissize;
2333:       p += thissize;
2334:     }
2335: }
```

## gcc/varasm.cc:2665–2667
```text
2665:       assemble_variable_contents (decl, name, dont_output_data,
2666: 				  (sect->common.flags & SECTION_MERGE)
2667: 				  && (sect->common.flags & SECTION_STRINGS));
```

## gcc/varasm.cc:3953–3965
```text
3953:       switch_to_section (sect);
3954:       if (align > BITS_PER_UNIT)
3955: 	ASM_OUTPUT_ALIGN (asm_out_file, floor_log2 (align / BITS_PER_UNIT));
3956:       assemble_constant_contents (exp, XSTR (symbol, 0), align,
3957: 				  (sect->common.flags & SECTION_MERGE)
3958: 				  && (sect->common.flags & SECTION_STRINGS));
3959:       if (asan_protected)
3960: 	{
3961: 	  HOST_WIDE_INT size = get_constant_size (exp);
3962: 	  assemble_zeros (asan_red_zone_size (size));
3963: 	}
3964:     }
3965: }
```

## gcc/varasm.cc:5627–5635
```text
5627: 	  return output_constructor (exp, size, align, reverse, NULL);
5628: 	case STRING_CST:
5629: 	  thissize = (unsigned HOST_WIDE_INT)TREE_STRING_LENGTH (exp);
5630: 	  if (merge_strings
5631: 	      && (thissize == 0
5632: 		  || TREE_STRING_POINTER (exp) [thissize - 1] != '\0'))
5633: 	    thissize++;
5634: 	  gcc_checking_assert (check_string_literal (exp, size));
5635: 	  assemble_string (TREE_STRING_POINTER (exp), thissize);
```

## gcc/varasm.cc:8518–8527
```text
8518: 	    }
8519: 	}
8520:       else
8521: 	{
8522: 	  HOST_WIDE_INT size;
8523: 	  decl = SYMBOL_REF_DECL (symbol);
8524: 	  assemble_variable_contents (decl, XSTR (symbol, 0), false, false);
8525: 	  size = tree_to_uhwi (DECL_SIZE_UNIT (decl));
8526: 	  offset += size;
8527: 	  if ((flag_sanitize & SANITIZE_ADDRESS)
```

## gcc/opts.cc:470–560
```text
470: static void
471: maybe_default_option (struct gcc_options *opts,
472: 		      struct gcc_options *opts_set,
473: 		      const struct default_options *default_opt,
474: 		      int level, bool size, bool fast, bool debug,
475: 		      unsigned int lang_mask,
476: 		      const struct cl_option_handlers *handlers,
477: 		      location_t loc,
478: 		      diagnostics::context *dc)
479: {
480:   const struct cl_option *option = &cl_options[default_opt->opt_index];
481:   bool enabled;
482:
483:   if (size)
484:     gcc_assert (level == 2);
485:   if (fast)
486:     gcc_assert (level == 3);
487:   if (debug)
488:     gcc_assert (level == 1);
489:
490:   switch (default_opt->levels)
491:     {
492:     case OPT_LEVELS_ALL:
493:       enabled = true;
494:       break;
495:
496:     case OPT_LEVELS_0_ONLY:
497:       enabled = (level == 0);
498:       break;
499:
500:     case OPT_LEVELS_1_PLUS:
501:       enabled = (level >= 1);
502:       break;
503:
504:     case OPT_LEVELS_1_PLUS_SPEED_ONLY:
505:       enabled = (level >= 1 && !size && !debug);
506:       break;
507:
508:     case OPT_LEVELS_1_PLUS_NOT_DEBUG:
509:       enabled = (level >= 1 && !debug);
510:       break;
511:
512:     case OPT_LEVELS_2_PLUS:
513:       enabled = (level >= 2);
514:       break;
515:
516:     case OPT_LEVELS_2_PLUS_SPEED_ONLY:
517:       enabled = (level >= 2 && !size && !debug);
518:       break;
519:
520:     case OPT_LEVELS_3_PLUS:
521:       enabled = (level >= 3);
522:       break;
523:
524:     case OPT_LEVELS_3_PLUS_AND_SIZE:
525:       enabled = (level >= 3 || size);
526:       break;
527:
528:     case OPT_LEVELS_SIZE:
529:       enabled = size;
530:       break;
531:
532:     case OPT_LEVELS_FAST:
533:       enabled = fast;
534:       break;
535:
536:     case OPT_LEVELS_NONE:
537:     default:
538:       gcc_unreachable ();
539:     }
540:
541:   if (enabled)
542:     handle_generated_option (opts, opts_set, default_opt->opt_index,
543: 			     default_opt->arg, default_opt->value,
544: 			     lang_mask,
545: 			     static_cast<int> (diagnostics::kind::unspecified),
546: 			     loc,
547: 			     handlers, true, dc);
548:   else if (default_opt->arg == NULL
549: 	   && !option->cl_reject_negative
550: 	   && !(option->flags & CL_PARAMS))
551:     handle_generated_option (opts, opts_set, default_opt->opt_index,
552: 			     default_opt->arg, !default_opt->value,
553: 			     lang_mask,
554: 			     static_cast<int> (diagnostics::kind::unspecified),
555: 			     loc,
556: 			     handlers, true, dc);
557: }
558:
559: /* As indicated by the optimization level LEVEL (-Os if SIZE is set,
560:    -Ofast if FAST is set), apply the options in array DEFAULT_OPTS to
```

## gcc/opts.cc:596–605
```text
596:     { OPT_LEVELS_1_PLUS, OPT_fguess_branch_probability, NULL, 1 },
597:     { OPT_LEVELS_1_PLUS, OPT_fipa_profile, NULL, 1 },
598:     { OPT_LEVELS_1_PLUS, OPT_fipa_pure_const, NULL, 1 },
599:     { OPT_LEVELS_1_PLUS, OPT_fipa_reference, NULL, 1 },
600:     { OPT_LEVELS_1_PLUS, OPT_fipa_reference_addressable, NULL, 1 },
601:     { OPT_LEVELS_1_PLUS, OPT_fjump_tables, NULL, 1 },
602:     { OPT_LEVELS_1_PLUS, OPT_fmerge_constants, NULL, 1 },
603:     { OPT_LEVELS_1_PLUS, OPT_fomit_frame_pointer, NULL, 1 },
604:     { OPT_LEVELS_1_PLUS, OPT_freorder_blocks, NULL, 1 },
605:     { OPT_LEVELS_1_PLUS, OPT_fshrink_wrap, NULL, 1 },
```

## gcc/opts.cc:819–825
```text
819:
820: 	default:
821: 	  /* Ignore other options in this prescan.  */
822: 	  break;
823: 	}
824:     }
825:
```

## gcc/common.opt:2411–2420
```text
2411: ; This will attempt to merge constant section constants, if 1 only
2412: ; string constants and constants from constant pool, if 2 also constant
2413: ; variables.
2414: fmerge-all-constants
2415: Common Var(flag_merge_constants,2) Init(1)
2416: Attempt to merge identical constants and constant variables.
2417:
2418: fmerge-constants
2419: Common Var(flag_merge_constants,1)
2420: Attempt to merge identical constants across compilation units.
```

## gcc/config/i386/i386-options.cc:2275–2286
```text
2275:     {
2276:       /* For TARGET_64BIT and MS_ABI, force pic on, in order to enable the
2277: 	 use of rip-relative addressing.  This eliminates fixups that
2278: 	 would otherwise be needed if this object is to be placed in a
2279: 	 DLL, and is essentially just as efficient as direct addressing.  */
2280:       if (TARGET_64BIT_P (opts->x_ix86_isa_flags)
2281: 	  && (TARGET_RDOS || TARGET_PECOFF))
2282: 	opts->x_ix86_cmodel = CM_MEDIUM_PIC, opts->x_flag_pic = 1;
2283:       else if (TARGET_64BIT_P (opts->x_ix86_isa_flags))
2284: 	opts->x_ix86_cmodel = opts->x_flag_pic ? CM_SMALL_PIC : CM_SMALL;
2285:       else
2286: 	opts->x_ix86_cmodel = CM_32;
```

## gcc/common/config/i386/i386-common.cc:2033–2059
```text
2033: static const struct default_options ix86_option_optimization_table[] =
2034:   {
2035:     /* Enable redundant extension instructions removal at -O2 and higher.  */
2036:     { OPT_LEVELS_2_PLUS, OPT_free, NULL, 1 },
2037:     /* Enable function splitting at -O2 and higher.  */
2038:     { OPT_LEVELS_2_PLUS, OPT_freorder_blocks_and_partition, NULL, 1 },
2039:     /* The STC algorithm produces the smallest code at -Os, for x86.  */
2040:     { OPT_LEVELS_2_PLUS, OPT_freorder_blocks_algorithm_, NULL,
2041:       REORDER_BLOCKS_ALGORITHM_STC },
2042:
2043:     /* Turn on -funroll-loops with -munroll-only-small-loops to enable small
2044:        loop unrolling at -O2.  */
2045:     { OPT_LEVELS_2_PLUS_SPEED_ONLY, OPT_funroll_loops, NULL, 1 },
2046:     { OPT_LEVELS_2_PLUS_SPEED_ONLY, OPT_munroll_only_small_loops, NULL, 1 },
2047:     /* Turns off -frename-registers and -fweb which are enabled by
2048:        funroll-loops.  */
2049:     { OPT_LEVELS_ALL, OPT_frename_registers, NULL, 0 },
2050:     { OPT_LEVELS_ALL, OPT_fweb, NULL, 0 },
2051:     /* Turn off -fschedule-insns by default.  It tends to make the
2052:        problem with not enough registers even worse.  */
2053:     { OPT_LEVELS_ALL, OPT_fschedule_insns, NULL, 0 },
2054:
2055: #ifdef SUBTARGET_OPTIMIZATION_OPTIONS
2056:     SUBTARGET_OPTIMIZATION_OPTIONS,
2057: #endif
2058:     { OPT_LEVELS_NONE, 0, NULL, 0 }
2059:   };
```

## libcpp/include/line-map.h:48–55
```text
48:
49:    i.e. "3:1:" in GCC corresponds to "(3, 0)" in Emacs.  */
50:
51: /* The type of line numbers.  */
52: typedef unsigned int linenum_type;
53:
54: /* A type for doing arithmetic on line numbers.  */
55: typedef long long linenum_arith_t;
```

## libcpp/include/line-map.h:295–324
```text
295: /* A 64-bit type to represent a location.  We only use 63 of the 64 bits, so
296:    that two location_t can be safely subtracted and stored in an int64_t.  */
297: typedef uint64_t location_t;
298: typedef int64_t location_diff_t;
299:
300: /* Sometimes we need a type that has the same size as location_t but that does
301:    not represent a location.  This typedef provides more clarity in those
302:    cases.  */
303: typedef location_t line_map_uint_t;
304:
305: /* Do not track column numbers higher than this one.  As a result, the
306:    range of column_bits is [12, 18] (or 0 if column numbers are
307:    disabled).  */
308: const unsigned int LINE_MAP_MAX_COLUMN_NUMBER = (1U << 31) - 1;
309:
310: /* Do not pack ranges if locations get higher than this.
311:    If you change this, update:
312:      gcc.dg/plugin/location-overflow-test-*.c.  */
313: const location_t LINE_MAP_MAX_LOCATION_WITH_PACKED_RANGES
314:   = location_t (0x50000000) << 31;
315:
316: /* Do not track column numbers if locations get higher than this.
317:    If you change this, update:
318:      gcc.dg/plugin/location-overflow-test-*.c.  */
319: const location_t LINE_MAP_MAX_LOCATION_WITH_COLS
320:   = location_t (0x60000000) << 31;
321:
322: /* Highest possible source location encoded within an ordinary map.  Higher
323:    values up to MAX_LOCATION_T represent macro virtual locations.  */
324: const location_t LINE_MAP_MAX_LOCATION = location_t (0x70000000) << 31;
```

## libcpp/include/line-map.h:425–471
```text
425: struct GTY((tag ("1"))) line_map_ordinary : public line_map {
426:   /* Base class is 8 bytes.  */
427:
428:   /* 4 bytes of integers, each 1 byte for easy extraction/insertion.  */
429:
430:   /* The reason for creation of this line map.  */
431:   ENUM_BITFIELD (lc_reason) reason : 8;
432:
433:   /* SYSP is one for a system header, two for a C system header file
434:      that therefore needs to be extern "C" protected in C++, and zero
435:      otherwise.  This field isn't really needed now that it's in
436:      cpp_buffer.  */
437:   unsigned char sysp;
438:
439:   /* Number of the low-order location_t bits used for column numbers
440:      and ranges.  */
441:   unsigned int m_column_and_range_bits : 8;
442:
443:   /* Number of the low-order "column" bits used for storing short ranges
444:      inline, rather than in the ad-hoc table.
445:      MSB                                                                 LSB
446:      31                                                                    0
447:      +-------------------------+-------------------------------------------+
448:      |                         |<---map->column_and_range_bits (e.g. 12)-->|
449:      +-------------------------+-----------------------+-------------------+
450:      |                         | column_and_range_bits | map->range_bits   |
451:      |                         |   - range_bits        |                   |
452:      +-------------------------+-----------------------+-------------------+
453:      | row bits                | effective column bits | short range bits  |
454:      |                         |    (e.g. 7)           |   (e.g. 5)        |
455:      +-------------------------+-----------------------+-------------------+ */
456:   unsigned int m_range_bits : 8;
457:
458:   /* 32-bit int even in 64-bit mode.  */
459:   linenum_type to_line;
460:
461:   /* Location from whence this line map was included.  For regular
462:      #includes, this location will be the last location of a map.  For
463:      outermost file, this is 0.  For modules it could be anywhere
464:      within a map.  */
465:   location_t included_from;
466:
467:   /* Pointer alignment boundary, whether 32-bit or 64-bit mode.  */
468:   const char *to_file;
469:
470:   /* Size is 28 (32) bytes for 32-bit (64-bit) arch.  */
471: };
```

## libcpp/include/line-map.h:747–777
```text
747:      (e.g. when a new preprocessing unit starts or ends).  */
748:   line_map_ordinary * GTY ((length ("%h.used"))) maps;
749:
750:   /* The total number of allocated maps.  */
751:   line_map_uint_t allocated;
752:
753:   /* The number of elements used in maps. This number is smaller
754:      or equal to ALLOCATED.  */
755:   line_map_uint_t used;
756:
757:   /* The index of the last ordinary map that was looked up with
758:      linemap_lookup.  */
759:   mutable line_map_uint_t m_cache;
760: };
761:
762: struct GTY(()) maps_info_macro {
763:   /* This array contains the macro line maps.
764:      A macro line map is created whenever a macro expansion occurs.  */
765:   line_map_macro * GTY ((length ("%h.used"))) maps;
766:
767:   /* The total number of allocated maps.  */
768:   line_map_uint_t allocated;
769:
770:   /* The number of elements used in maps. This number is smaller
771:      or equal to ALLOCATED.  */
772:   line_map_uint_t used;
773:
774:   /* The index of the last macro map that was looked up with
775:      linemap_lookup.  */
776:   mutable line_map_uint_t m_cache;
777: };
```

## libcpp/line-map.cc:469–543
```text
469: line_map *
470: line_map_new_raw (line_maps *set, bool macro_p, line_map_uint_t num)
471: {
472:   auto num_maps_allocated = LINEMAPS_ALLOCATED (set, macro_p);
473:   auto num_maps_used = LINEMAPS_USED (set, macro_p);
474:
475:   if (num > num_maps_allocated - num_maps_used)
476:     {
477:       /* We need more space!  */
478:       if (!num_maps_allocated)
479: 	num_maps_allocated = 128;
480:       if (num_maps_allocated < num_maps_used + num)
481: 	num_maps_allocated = num_maps_used + num;
482:       num_maps_allocated *= 2;
483:
484:       size_t size_of_a_map;
485:       void *buffer;
486:       if (macro_p)
487: 	{
488: 	  size_of_a_map = sizeof (line_map_macro);
489: 	  buffer = set->info_macro.maps;
490: 	}
491:       else
492: 	{
493: 	  size_of_a_map = sizeof (line_map_ordinary);
494: 	  buffer = set->info_ordinary.maps;
495: 	}
496:
497:       /* We are going to execute some dance to try to reduce the
498: 	 overhead of the memory allocator, in case we are using the
499: 	 ggc-page.cc one.
500:
501: 	 The actual size of memory we are going to get back from the
502: 	 allocator may well be larger than what we ask for.  Use this
503: 	 hook to find what that size is.  */
504:       size_t alloc_size
505: 	= set->m_round_alloc_size (num_maps_allocated * size_of_a_map);
506:
507:       /* Now alloc_size contains the exact memory size we would get if
508: 	 we have asked for the initial alloc_size amount of memory.
509: 	 Let's get back to the number of map that amounts to.  */
510:       line_map_uint_t num_maps = alloc_size / size_of_a_map;
511:       buffer = set->m_reallocator (buffer, num_maps * size_of_a_map);
512:       memset ((char *)buffer + num_maps_used * size_of_a_map, 0,
513: 	      (num_maps - num_maps_used) * size_of_a_map);
514:       if (macro_p)
515: 	set->info_macro.maps = (line_map_macro *)buffer;
516:       else
517: 	set->info_ordinary.maps = (line_map_ordinary *)buffer;
518:       LINEMAPS_ALLOCATED (set, macro_p) = num_maps;
519:     }
520:
521:   line_map *result = (macro_p ? (line_map *)&set->info_macro.maps[num_maps_used]
522: 		      : (line_map *)&set->info_ordinary.maps[num_maps_used]);
523:   LINEMAPS_USED (set, macro_p) += num;
524:
525:   return result;
526: }
527:
528: /* Create a new line map in the line map set SET, and return it.
529:    REASON is the reason of creating the map. It determines the type
530:    of map created (ordinary or macro map). Note that ordinary maps and
531:    macro maps are allocated in different memory location.  */
532:
533: static struct line_map *
534: new_linemap (line_maps *set, location_t start_location)
535: {
536:   line_map *result = line_map_new_raw (set,
537: 				       start_location >= LINE_MAP_MAX_LOCATION,
538: 				       1);
539:
540:   result->start_location = start_location;
541:
542:   return result;
543: }
```

## libcpp/line-map.cc:570–608
```text
570: linemap_add (line_maps *set, enum lc_reason reason,
571: 	     unsigned int sysp, const char *to_file, linenum_type to_line)
572: {
573:   /* Generate a start_location above the current highest_location.
574:      If possible, make the low range bits be zero.  */
575:   location_t start_location = set->highest_location + 1;
576:   unsigned range_bits = 0;
577:   if (start_location < LINE_MAP_MAX_LOCATION_WITH_COLS)
578:     range_bits = set->default_range_bits;
579:   start_location += (loc_one << range_bits) - 1;
580:   start_location &=  ~((loc_one << range_bits) - 1);
581:
582:   linemap_assert (!LINEMAPS_ORDINARY_USED (set)
583: 		  || (start_location
584: 		      >= MAP_START_LOCATION (LINEMAPS_LAST_ORDINARY_MAP (set))));
585:
586:   /* When we enter the file for the first time reason cannot be
587:      LC_RENAME.  */
588:   linemap_assert (!(set->depth == 0 && reason == LC_RENAME));
589:
590:   /* If we are leaving the main file, return a NULL map.  */
591:   if (reason == LC_LEAVE
592:       && MAIN_FILE_P (LINEMAPS_LAST_ORDINARY_MAP (set))
593:       && to_file == NULL)
594:     {
595:       set->depth--;
596:       return NULL;
597:     }
598:
599:   linemap_assert (reason != LC_ENTER_MACRO);
600:
601:   if (start_location >= LINE_MAP_MAX_LOCATION)
602:     /* We ran out of line map space.   */
603:     start_location = 0;
604:
605:   line_map_ordinary *map
606:     = linemap_check_ordinary (new_linemap (set, start_location));
607:   map->reason = reason;
608:
```

## libcpp/line-map.cc:662–680
```text
662:   /* Do not store range_bits here.  That's readjusted in
663:      linemap_line_start.  */
664:   map->m_range_bits = map->m_column_and_range_bits = 0;
665:   set->highest_location = start_location;
666:   set->highest_line = start_location;
667:   set->max_column_hint = 0;
668:
669:   /* This assertion is placed after set->highest_location has
670:      been updated, since the latter affects
671:      linemap_location_from_macro_expansion_p, which ultimately affects
672:      pure_location_p.  */
673:   linemap_assert (pure_location_p (set, start_location));
674:
675:   if (reason == LC_ENTER)
676:     {
677:       if (set->depth == 0)
678: 	map->included_from = 0;
679:       else
680: 	{
```

## libcpp/line-map.cc:890–999
```text
890: linemap_line_start (line_maps *set, linenum_type to_line,
891: 		    unsigned int max_column_hint)
892: {
893:   line_map_ordinary *map = LINEMAPS_LAST_ORDINARY_MAP (set);
894:   location_t highest = set->highest_location;
895:   location_t r;
896:   linenum_type last_line =
897:     SOURCE_LINE (map, set->highest_line);
898:   auto line_delta = (linenum_arith_t) to_line - (linenum_arith_t) last_line;
899:   bool add_map = false;
900:   linemap_assert (map->m_column_and_range_bits >= map->m_range_bits);
901:   int effective_column_bits = map->m_column_and_range_bits - map->m_range_bits;
902:
903:   if (line_delta < 0
904:       || (line_delta > 10
905: 	  && line_delta * map->m_column_and_range_bits > 1000)
906:       || (max_column_hint >= (1U << effective_column_bits))
907:       || (max_column_hint <= 80 && effective_column_bits >= 10)
908:       || (highest > LINE_MAP_MAX_LOCATION_WITH_PACKED_RANGES
909: 	  && map->m_range_bits > 0)
910:       || (highest > LINE_MAP_MAX_LOCATION_WITH_COLS
911: 	  && (set->max_column_hint || highest >= LINE_MAP_MAX_LOCATION)))
912:     add_map = true;
913:   else
914:     max_column_hint = set->max_column_hint;
915:   if (add_map)
916:     {
917:       int column_bits;
918:       int range_bits;
919:       if (max_column_hint > LINE_MAP_MAX_COLUMN_NUMBER
920: 	  || highest > LINE_MAP_MAX_LOCATION_WITH_COLS)
921: 	{
922: 	  /* If the column number is ridiculous or we've allocated a huge
923: 	     number of location_ts, give up on column numbers
924: 	     (and on packed ranges).  */
925: 	  max_column_hint = 1;
926: 	  column_bits = 0;
927: 	  range_bits = 0;
928: 	  if (highest >= LINE_MAP_MAX_LOCATION)
929: 	    goto overflowed;
930: 	}
931:       else
932: 	{
933: 	  column_bits = 7;
934: 	  if (highest <= LINE_MAP_MAX_LOCATION_WITH_PACKED_RANGES)
935: 	    range_bits = set->default_range_bits;
936: 	  else
937: 	    range_bits = 0;
938: 	  while (max_column_hint >= (1U << column_bits))
939: 	    column_bits++;
940: 	  max_column_hint = 1U << column_bits;
941: 	  column_bits += range_bits;
942: 	}
943:
944:       /* Allocate the new line_map.  However, if the current map only has a
945: 	 single line we can sometimes just increase its column_bits instead. */
946:       if (line_delta < 0
947: 	  || last_line != ORDINARY_MAP_STARTING_LINE_NUMBER (map)
948: 	  || SOURCE_COLUMN (map, highest) >= (loc_one
949: 					      << (column_bits - range_bits))
950: 	  || ( /* We can't reuse the map if the line offset is sufficiently
951: 		  large to cause overflow when computing location_t values.  */
952: 	      (to_line - ORDINARY_MAP_STARTING_LINE_NUMBER (map))
953: 	      >= (((uint64_t) 1)
954: 		  << (CHAR_BIT * sizeof (linenum_type) - column_bits)))
955: 	  || range_bits < map->m_range_bits)
956: 	map = linemap_check_ordinary
957: 	        (const_cast <line_map *>
958: 		  (linemap_add (set, LC_RENAME,
959: 				ORDINARY_MAP_IN_SYSTEM_HEADER_P (map),
960: 				ORDINARY_MAP_FILE_NAME (map),
961: 				to_line)));
962:       map->m_column_and_range_bits = column_bits;
963:       map->m_range_bits = range_bits;
964:       r = (MAP_START_LOCATION (map)
965: 	   + (location_t (to_line - ORDINARY_MAP_STARTING_LINE_NUMBER (map))
966: 	      << column_bits));
967:     }
968:   else
969:     r = set->highest_line + (location_t (line_delta)
970: 			     << map->m_column_and_range_bits);
971:
972:   /* Locations of ordinary tokens are always lower than locations of
973:      macro tokens.  */
974:   if (r >= LINE_MAP_MAX_LOCATION)
975:     {
976:     overflowed:
977:       /* Remember we overflowed.  */
978:       set->highest_line = set->highest_location = LINE_MAP_MAX_LOCATION - 1;
979:       /* No column numbers!  */
980:       set->max_column_hint = 1;
981:       return 0;
982:     }
983:
984:   set->highest_line = r;
985:   if (r > set->highest_location)
986:     set->highest_location = r;
987:   set->max_column_hint = max_column_hint;
988:
989:   /* At this point, we expect one of:
990:      (a) the normal case: a "pure" location with 0 range bits, or
991:      (b) we've gone past LINE_MAP_MAX_LOCATION_WITH_COLS so can't track
992:         columns anymore (or ranges), or
993:      (c) we're in a region with a column hint exceeding
994:         LINE_MAP_MAX_COLUMN_NUMBER, so column-tracking is off,
995: 	with column_bits == 0.  */
996:   linemap_assert (pure_location_p (set, r)
997: 		  || r >= LINE_MAP_MAX_LOCATION_WITH_COLS
998: 		  || map->m_column_and_range_bits == 0);
999:   linemap_assert (SOURCE_LINE (map, r) == to_line);
```

## libcpp/line-map.cc:1009–1077
```text
1009: linemap_position_for_column (line_maps *set, unsigned int to_column)
1010: {
1011:   location_t r = set->highest_line;
1012:
1013:   linemap_assert
1014:     (!linemap_macro_expansion_map_p (LINEMAPS_LAST_ORDINARY_MAP (set)));
1015:
1016:   if (to_column >= set->max_column_hint)
1017:     {
1018:       if (r > LINE_MAP_MAX_LOCATION_WITH_COLS
1019: 	  || to_column > LINE_MAP_MAX_COLUMN_NUMBER)
1020: 	{
1021: 	  /* Running low on location_ts - disable column numbers.  */
1022: 	  return r;
1023: 	}
1024:       else
1025: 	{
1026: 	  /* Otherwise, attempt to start a new line that can hold TO_COLUMN,
1027: 	     with some space to spare.  This may or may not lead to a new
1028: 	     linemap being created.  */
1029: 	  line_map_ordinary *map = LINEMAPS_LAST_ORDINARY_MAP (set);
1030: 	  r = linemap_line_start (set, SOURCE_LINE (map, r), to_column + 50);
1031: 	  map = LINEMAPS_LAST_ORDINARY_MAP (set);
1032: 	  if (map->m_column_and_range_bits == 0)
1033: 	    {
1034: 	      /* ...then the linemap has column-tracking disabled,
1035: 		 presumably due to exceeding either
1036: 		 LINE_MAP_MAX_LOCATION_WITH_COLS (overall) or
1037: 		 LINE_MAP_MAX_COLUMN_NUMBER (within this line).
1038: 		 Return the start of the linemap, which encodes column 0, for
1039: 		 the whole line.  */
1040: 	      return r;
1041: 	    }
1042: 	}
1043:     }
1044:   line_map_ordinary *map = LINEMAPS_LAST_ORDINARY_MAP (set);
1045:   r = r + (location_t (to_column) << map->m_range_bits);
1046:   if (r >= set->highest_location)
1047:     set->highest_location = r;
1048:   return r;
1049: }
1050:
1051: /* Encode and return a source location from a given line and
1052:    column.  */
1053:
1054: location_t
1055: linemap_position_for_line_and_column (line_maps *set,
1056: 				      const line_map_ordinary *ord_map,
1057: 				      linenum_type line,
1058: 				      unsigned column)
1059: {
1060:   linemap_assert (ORDINARY_MAP_STARTING_LINE_NUMBER (ord_map) <= line);
1061:
1062:   location_t r = MAP_START_LOCATION (ord_map);
1063:   r += (location_t (line - ORDINARY_MAP_STARTING_LINE_NUMBER (ord_map))
1064: 	<< ord_map->m_column_and_range_bits);
1065:   if (r <= LINE_MAP_MAX_LOCATION_WITH_COLS)
1066:     r += ((column & ((loc_one << ord_map->m_column_and_range_bits) - 1))
1067: 	  << ord_map->m_range_bits);
1068:   location_t upper_limit = LINEMAPS_MACRO_LOWEST_LOCATION (set);
1069:   if (r >= upper_limit)
1070:     r = upper_limit - 1;
1071:   if (r > set->highest_location)
1072:     set->highest_location = r;
1073:   return r;
1074: }
1075:
1076: /* Encode and return a location_t starting from location LOC and
1077:    shifting it by COLUMN_OFFSET columns.  This function does not support
```

## gcc/toplev.cc:761–767
```text
761: /* A helper function; used as the reallocator function for cpp's line
762:    table.  */
763: static void *
764: realloc_for_line_map (void *ptr, size_t len)
765: {
766:   return ggc_realloc (ptr, len);
767: }
```

## gcc/toplev.cc:1141–1150
```text
1141:      table.  */
1142:   init_ggc ();
1143:   init_stringpool ();
1144:   input_location = UNKNOWN_LOCATION;
1145:   line_table = ggc_alloc<line_maps> ();
1146:   linemap_init (line_table, BUILTINS_LOCATION);
1147:   line_table->m_reallocator = realloc_for_line_map;
1148:   line_table->m_round_alloc_size = ggc_round_alloc_size;
1149:   line_table->default_range_bits = line_map_suggested_range_bits;
1150:   init_ttree ();
```

## gcc/ggc-page.cc:1292–1327
```text
1292: ggc_round_alloc_size_1 (size_t requested_size,
1293: 			size_t *size_order,
1294: 			size_t *alloced_size)
1295: {
1296:   size_t order, object_size;
1297:
1298:   if (requested_size < NUM_SIZE_LOOKUP)
1299:     {
1300:       order = size_lookup[requested_size];
1301:       object_size = OBJECT_SIZE (order);
1302:     }
1303:   else
1304:     {
1305:       order = 10;
1306:       while (requested_size > (object_size = OBJECT_SIZE (order)))
1307:         order++;
1308:     }
1309:
1310:   if (size_order)
1311:     *size_order = order;
1312:   if (alloced_size)
1313:     *alloced_size = object_size;
1314: }
1315:
1316: /* For a given size of memory requested for allocation, return the
1317:    actual size that is going to be allocated.  */
1318:
1319: size_t
1320: ggc_round_alloc_size (size_t requested_size)
1321: {
1322:   size_t size = 0;
1323:
1324:   ggc_round_alloc_size_1 (requested_size, NULL, &size);
1325:   return size;
1326: }
1327:
```

## gcc/ggc-page.cc:1883–1905
```text
1883:
1884:   /* Initialize the object size table.  */
1885:   for (order = 0; order < HOST_BITS_PER_PTR; ++order)
1886:     object_size_table[order] = (size_t) 1 << order;
1887:   for (order = HOST_BITS_PER_PTR; order < NUM_ORDERS; ++order)
1888:     {
1889:       size_t s = extra_order_size_table[order - HOST_BITS_PER_PTR];
1890:
1891:       /* If S is not a multiple of the MAX_ALIGNMENT, then round it up
1892: 	 so that we're sure of getting aligned memory.  */
1893:       s = ROUND_UP (s, MAX_ALIGNMENT);
1894:       object_size_table[order] = s;
1895:     }
1896:
1897:   /* Initialize the objects-per-page and inverse tables.  */
1898:   for (order = 0; order < NUM_ORDERS; ++order)
1899:     {
1900:       objects_per_page_table[order] = G.pagesize / OBJECT_SIZE (order);
1901:       if (objects_per_page_table[order] == 0)
1902: 	objects_per_page_table[order] = 1;
1903:       compute_inverse (order);
1904:     }
1905:
```

## gcc/ggc.h:230–258
```text
230: inline T *
231: ggc_vec_alloc (size_t c CXX_MEM_STAT_INFO)
232: {
233:   if (need_finalization_p<T> ())
234:     return static_cast<T *> (ggc_internal_alloc (c * sizeof (T), finalize<T>,
235: 						 sizeof (T), c PASS_MEM_STAT));
236:   else
237:     return static_cast<T *> (ggc_internal_alloc_no_dtor (c * sizeof (T),
238: 							 NULL, 0, 0
239: 							 PASS_MEM_STAT));
240: }
241:
242: template<typename T>
243: inline T *
244: ggc_cleared_vec_alloc (size_t c CXX_MEM_STAT_INFO)
245: {
246:   if (need_finalization_p<T> ())
247:     return static_cast<T *> (ggc_internal_cleared_alloc (c * sizeof (T),
248: 							 finalize<T>,
249: 							 sizeof (T), c
250: 							 PASS_MEM_STAT));
251:   else
252:     return static_cast<T *> (ggc_internal_cleared_alloc_no_dtor (c
253: 								 * sizeof (T),
254: 								 NULL, 0, 0
255: 								 PASS_MEM_STAT));
256: }
257:
258: inline void *
```

## gcc/ada/gcc-interface/utils.cc:259–280
```text
259: /* Associates a GNAT tree node to a GCC tree node. It is used in
260:    `save_gnu_tree', `get_gnu_tree' and `present_gnu_tree'. See documentation
261:    of `save_gnu_tree' for more info.  */
262: static GTY((length ("max_gnat_nodes"))) tree *associate_gnat_to_gnu;
263:
264: #define GET_GNU_TREE(GNAT_ENTITY)	\
265:   associate_gnat_to_gnu[(GNAT_ENTITY) - First_Node_Id]
266:
267: #define SET_GNU_TREE(GNAT_ENTITY,VAL)	\
268:   associate_gnat_to_gnu[(GNAT_ENTITY) - First_Node_Id] = (VAL)
269:
270: #define PRESENT_GNU_TREE(GNAT_ENTITY)	\
271:   (associate_gnat_to_gnu[(GNAT_ENTITY) - First_Node_Id] != NULL_TREE)
272:
273: /* Associates a GNAT entity to a GCC tree node used as a dummy, if any.  */
274: static GTY((length ("max_gnat_nodes"))) tree *dummy_node_table;
275:
276: #define GET_DUMMY_NODE(GNAT_ENTITY)	\
277:   dummy_node_table[(GNAT_ENTITY) - First_Node_Id]
278:
279: #define SET_DUMMY_NODE(GNAT_ENTITY,VAL)	\
280:   dummy_node_table[(GNAT_ENTITY) - First_Node_Id] = (VAL)
```

## gcc/ada/gcc-interface/utils.cc:430–450
```text
430: /* Initialize data structures of the utils.cc module.  */
431:
432: void
433: init_gnat_utils (void)
434: {
435:   /* Initialize the association of GNAT nodes to GCC trees.  */
436:   associate_gnat_to_gnu = ggc_cleared_vec_alloc<tree> (max_gnat_nodes);
437:
438:   /* Initialize the association of GNAT nodes to GCC trees as dummies.  */
439:   dummy_node_table = ggc_cleared_vec_alloc<tree> (max_gnat_nodes);
440:
441:   /* Initialize the hash table of packable types.  */
442:   packable_type_hash_table = hash_table<packable_type_hasher>::create_ggc (512);
443:
444:   /* Initialize the hash table of padded types.  */
445:   pad_type_hash_table = hash_table<pad_type_hasher>::create_ggc (512);
446:
447:   /* Initialize the hash table of sized types.  */
448:   sized_type_hash_table = hash_table<sized_type_hasher>::create_ggc (512);
449: }
450:
```
