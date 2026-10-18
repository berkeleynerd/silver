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

## gcc/varasm.cc:76–85
```text
76: class constant_descriptor_rtx;
77: struct rtx_constant_pool;
78:
79: #define n_deferred_constants (crtl->varasm.deferred_constants)
80:
81: /* Number for making the label on the next
82:    constant that is stored in memory.  */
83:
84: static GTY(()) int const_labelno;
85:
```

## gcc/varasm.cc:2069–2086
```text
2069: assemble_start_function (tree decl, const char *fnname)
2070: {
2071:   int align;
2072:   char tmp_label[100];
2073:   bool hot_label_written = false;
2074:
2075:   if (crtl->has_bb_partition)
2076:     {
2077:       ASM_GENERATE_INTERNAL_LABEL (tmp_label, "LHOTB", const_labelno);
2078:       crtl->subsections.hot_section_label = ggc_strdup (tmp_label);
2079:       ASM_GENERATE_INTERNAL_LABEL (tmp_label, "LCOLDB", const_labelno);
2080:       crtl->subsections.cold_section_label = ggc_strdup (tmp_label);
2081:       ASM_GENERATE_INTERNAL_LABEL (tmp_label, "LHOTE", const_labelno);
2082:       crtl->subsections.hot_section_end_label = ggc_strdup (tmp_label);
2083:       ASM_GENERATE_INTERNAL_LABEL (tmp_label, "LCOLDE", const_labelno);
2084:       crtl->subsections.cold_section_end_label = ggc_strdup (tmp_label);
2085:       const_labelno++;
2086:       cold_function_name = NULL_TREE;
```

## gcc/varasm.cc:2976–2987
```text
2976: rtx
2977: assemble_static_space (unsigned HOST_WIDE_INT size)
2978: {
2979:   char name[17];
2980:   const char *namestring;
2981:   rtx x;
2982:
2983:   ASM_GENERATE_INTERNAL_LABEL (name, "LF", const_labelno);
2984:   ++const_labelno;
2985:   namestring = ggc_strdup (name);
2986:
2987:   x = gen_rtx_SYMBOL_REF (Pmode, namestring);
```

## gcc/varasm.cc:3537–3553
```text
3537:     case FIXED_CST:
3538:       /* Fixed constants are the same only if the same width of type.  */
3539:       if (TYPE_PRECISION (TREE_TYPE (t1)) != TYPE_PRECISION (TREE_TYPE (t2)))
3540: 	return false;
3541:
3542:       return FIXED_VALUES_IDENTICAL (TREE_FIXED_CST (t1), TREE_FIXED_CST (t2));
3543:
3544:     case STRING_CST:
3545:       if (TYPE_MODE (TREE_TYPE (t1)) != TYPE_MODE (TREE_TYPE (t2))
3546: 	  || int_size_in_bytes (TREE_TYPE (t1))
3547: 	     != int_size_in_bytes (TREE_TYPE (t2)))
3548: 	return false;
3549:
3550:       return (TREE_STRING_LENGTH (t1) == TREE_STRING_LENGTH (t2)
3551: 	      && ! memcmp (TREE_STRING_POINTER (t1), TREE_STRING_POINTER (t2),
3552: 			   TREE_STRING_LENGTH (t1)));
3553:
```

## gcc/varasm.cc:3720–3753
```text
3720: static struct constant_descriptor_tree *
3721: build_constant_desc (tree exp)
3722: {
3723:   struct constant_descriptor_tree *desc;
3724:   rtx symbol, rtl;
3725:   char label[256];
3726:   int labelno;
3727:   tree decl;
3728:
3729:   desc = ggc_alloc<constant_descriptor_tree> ();
3730:   desc->value = exp;
3731:
3732:   /* Create a string containing the label name, in LABEL.  */
3733:   labelno = const_labelno++;
3734:   ASM_GENERATE_INTERNAL_LABEL (label, "LC", labelno);
3735:
3736:   /* Construct the VAR_DECL associated with the constant.  */
3737:   decl = build_decl (UNKNOWN_LOCATION, VAR_DECL, get_identifier (label),
3738: 		     TREE_TYPE (exp));
3739:   DECL_ARTIFICIAL (decl) = 1;
3740:   DECL_IGNORED_P (decl) = 1;
3741:   TREE_READONLY (decl) = 1;
3742:   TREE_STATIC (decl) = 1;
3743:   TREE_ADDRESSABLE (decl) = 1;
3744:   /* We don't set the RTL yet as this would cause varpool to assume that the
3745:      variable is referenced.  Moreover, it would just be dropped in LTO mode.
3746:      Instead we set the flag that will be recognized in make_decl_rtl.  */
3747:   DECL_IN_CONSTANT_POOL (decl) = 1;
3748:   DECL_INITIAL (decl) = desc->value;
3749:   /* ??? targetm.constant_alignment hasn't been updated for vector types on
3750:      most architectures so use DATA_ALIGNMENT as well, except for strings.  */
3751:   if (TREE_CODE (exp) == STRING_CST)
3752:     SET_DECL_ALIGN (decl, targetm.constant_alignment (exp, DECL_ALIGN (decl)));
3753:   else
```

## gcc/varasm.cc:3804–3893
```text
3804: /* Subroutine of output_constant_def and tree_output_constant_def:
3805:    Add a constant to the hash table that tracks which constants
3806:    already have labels.  */
3807:
3808: static constant_descriptor_tree *
3809: add_constant_to_table (tree exp, int defer)
3810: {
3811:   /* The hash table methods may call output_constant_def for addressed
3812:      constants, so handle them first.  */
3813:   output_addressed_constants (exp, defer);
3814:
3815:   /* Sanity check to catch recursive insertion.  */
3816:   static bool inserting;
3817:   gcc_assert (!inserting);
3818:   inserting = true;
3819:
3820:   /* Look up EXP in the table of constant descriptors.  If we didn't
3821:      find it, create a new one.  */
3822:   struct constant_descriptor_tree key;
3823:   key.value = exp;
3824:   key.hash = const_hash_1 (exp);
3825:   constant_descriptor_tree **loc
3826:     = const_desc_htab->find_slot_with_hash (&key, key.hash, INSERT);
3827:
3828:   inserting = false;
3829:
3830:   struct constant_descriptor_tree *desc = *loc;
3831:   if (!desc)
3832:     {
3833:       desc = build_constant_desc (exp);
3834:       desc->hash = key.hash;
3835:       *loc = desc;
3836:     }
3837:
3838:   return desc;
3839: }
3840:
3841: /* Return an rtx representing a reference to constant data in memory
3842:    for the constant expression EXP.
3843:
3844:    If assembler code for such a constant has already been output,
3845:    return an rtx to refer to it.
3846:    Otherwise, output such a constant in memory
3847:    and generate an rtx for it.
3848:
3849:    If DEFER is nonzero, this constant can be deferred and output only
3850:    if referenced in the function after all optimizations.
3851:
3852:    `const_desc_table' records which constants already have label strings.  */
3853:
3854: rtx
3855: output_constant_def (tree exp, int defer)
3856: {
3857:   struct constant_descriptor_tree *desc = add_constant_to_table (exp, defer);
3858:   maybe_output_constant_def_contents (desc, defer);
3859:   return desc->rtl;
3860: }
3861:
3862: /* Subroutine of output_constant_def: Decide whether or not we need to
3863:    output the constant DESC now, and if so, do it.  */
3864: static void
3865: maybe_output_constant_def_contents (struct constant_descriptor_tree *desc,
3866: 				    int defer)
3867: {
3868:   rtx symbol = XEXP (desc->rtl, 0);
3869:   tree exp = desc->value;
3870:
3871:   if (flag_syntax_only)
3872:     return;
3873:
3874:   if (TREE_ASM_WRITTEN (exp))
3875:     /* Already output; don't do it again.  */
3876:     return;
3877:
3878:   /* We can always defer constants as long as the context allows
3879:      doing so.  */
3880:   if (defer)
3881:     {
3882:       /* Increment n_deferred_constants if it exists.  It needs to be at
3883: 	 least as large as the number of constants actually referred to
3884: 	 by the function.  If it's too small we'll stop looking too early
3885: 	 and fail to emit constants; if it's too large we'll only look
3886: 	 through the entire function when we could have stopped earlier.  */
3887:       if (cfun)
3888: 	n_deferred_constants++;
3889:       return;
3890:     }
3891:
3892:   output_constant_def_contents (symbol);
3893: }
```

## gcc/varasm.cc:4150–4168
```text
4150: {
4151:   struct rtx_constant_pool *pool;
4152:
4153:   pool = ggc_alloc<rtx_constant_pool> ();
4154:   pool->const_rtx_htab = hash_table<const_rtx_desc_hasher>::create_ggc (31);
4155:   pool->first = NULL;
4156:   pool->last = NULL;
4157:   pool->offset = 0;
4158:   return pool;
4159: }
4160:
4161: /* Initialize constant pool hashing for a new function.  */
4162:
4163: void
4164: init_varasm_status (void)
4165: {
4166:   crtl->varasm.pool = create_constant_pool ();
4167:   crtl->varasm.deferred_constants = 0;
4168: }
```

## gcc/varasm.cc:4212–4253
```text
4212:   /* Lookup the value in the hashtable.  */
4213:   tmp.constant = x;
4214:   tmp.mode = mode;
4215:   hash = const_rtx_hash (x);
4216:   slot = pool->const_rtx_htab->find_slot_with_hash (&tmp, hash, INSERT);
4217:   desc = *slot;
4218:
4219:   /* If the constant was already present, return its memory.  */
4220:   if (desc)
4221:     return copy_rtx (desc->mem);
4222:
4223:   /* Otherwise, create a new descriptor.  */
4224:   desc = ggc_alloc<constant_descriptor_rtx> ();
4225:   *slot = desc;
4226:
4227:   /* Align the location counter as required by EXP's data type.  */
4228:   machine_mode align_mode = (mode == VOIDmode ? word_mode : mode);
4229:   align = targetm.static_rtx_alignment (align_mode);
4230:
4231:   pool->offset += (align / BITS_PER_UNIT) - 1;
4232:   pool->offset &= ~ ((align / BITS_PER_UNIT) - 1);
4233:
4234:   desc->next = NULL;
4235:   desc->constant = copy_rtx (tmp.constant);
4236:   desc->offset = pool->offset;
4237:   desc->hash = hash;
4238:   desc->mode = mode;
4239:   desc->align = align;
4240:   desc->labelno = const_labelno;
4241:   desc->mark = 0;
4242:
4243:   pool->offset += GET_MODE_SIZE (mode);
4244:   if (pool->last)
4245:     pool->last->next = desc;
4246:   else
4247:     pool->first = pool->last = desc;
4248:   pool->last = desc;
4249:
4250:   /* Create a string containing the label name, in LABEL.  */
4251:   ASM_GENERATE_INTERNAL_LABEL (label, "LC", const_labelno);
4252:   ++const_labelno;
4253:
```

## gcc/varasm.cc:4476–4523
```text
4476: recompute_pool_offsets (struct rtx_constant_pool *pool)
4477: {
4478:   class constant_descriptor_rtx *desc;
4479:   pool->offset = 0;
4480:
4481:   for (desc = pool->first; desc ; desc = desc->next)
4482:     if (desc->mark)
4483:       {
4484: 	  /* Recalculate offset.  */
4485: 	unsigned int align = desc->align;
4486: 	pool->offset += (align / BITS_PER_UNIT) - 1;
4487: 	pool->offset &= ~ ((align / BITS_PER_UNIT) - 1);
4488: 	desc->offset = pool->offset;
4489: 	pool->offset += GET_MODE_SIZE (desc->mode);
4490:       }
4491: }
4492:
4493: /* Mark all constants that are referenced by SYMBOL_REFs in X.
4494:    Emit referenced deferred strings.  */
4495:
4496: static void
4497: mark_constants_in_pattern (rtx insn)
4498: {
4499:   subrtx_iterator::array_type array;
4500:   FOR_EACH_SUBRTX (iter, array, PATTERN (insn), ALL)
4501:     {
4502:       const_rtx x = *iter;
4503:       if (GET_CODE (x) == SYMBOL_REF)
4504: 	{
4505: 	  if (CONSTANT_POOL_ADDRESS_P (x))
4506: 	    {
4507: 	      class constant_descriptor_rtx *desc = SYMBOL_REF_CONSTANT (x);
4508: 	      if (desc->mark == 0)
4509: 		{
4510: 		  desc->mark = 1;
4511: 		  iter.substitute (desc->constant);
4512: 		}
4513: 	    }
4514: 	  else if (TREE_CONSTANT_POOL_ADDRESS_P (x))
4515: 	    {
4516: 	      tree decl = SYMBOL_REF_DECL (x);
4517: 	      if (!TREE_ASM_WRITTEN (DECL_INITIAL (decl)))
4518: 		{
4519: 		  n_deferred_constants--;
4520: 		  output_constant_def_contents (const_cast<rtx> (x));
4521: 		}
4522: 	    }
4523: 	}
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

## gcc/function.h:162–169
```text
162: struct GTY(()) varasm_status {
163:   /* If we're using a per-function constant pool, this is it.  */
164:   struct rtx_constant_pool *pool;
165:
166:   /* Number of tree-constants deferred during the expansion of this
167:      function.  */
168:   unsigned int deferred_constants;
169: };
```

## gcc/config/elfos.h:114–132
```text
114:    the symbol_ref name of an internal numbered label where
115:    PREFIX is the class of label and NUM is the number within the class.
116:    This is suitable for output with `assemble_name'.
117:
118:    For most svr4 systems, the convention is that any symbol which begins
119:    with a period is not put into the linker symbol table by the assembler.  */
120:
121: #undef  ASM_GENERATE_INTERNAL_LABEL
122: #define ASM_GENERATE_INTERNAL_LABEL(LABEL, PREFIX, NUM)		\
123:   do								\
124:     {								\
125:       char *__p;						\
126:       (LABEL)[0] = '*';						\
127:       (LABEL)[1] = '.';						\
128:       __p = stpcpy (&(LABEL)[2], PREFIX);			\
129:       sprint_ul (__p, (unsigned long) (NUM));			\
130:     }								\
131:   while (0)
132:
```

## gcc/hash-table.h:295–355
```text
295:   hashval_t inv_m2;     /* inverse of prime-2 */
296:   hashval_t shift;
297: };
298:
299: extern struct prime_ent const prime_tab[];
300:
301: /* Limit number of comparisons when calling hash_table<>::verify.  */
302: extern unsigned int hash_table_sanitize_eq_limit;
303:
304: /* Functions for computing hash table indexes.  */
305:
306: extern unsigned int hash_table_higher_prime_index (unsigned long n)
307:    ATTRIBUTE_PURE;
308:
309: extern ATTRIBUTE_NORETURN ATTRIBUTE_COLD void hashtab_chk_error ();
310:
311: /* Return X % Y using multiplicative inverse values INV and SHIFT.
312:
313:    The multiplicative inverses computed above are for 32-bit types,
314:    and requires that we be able to compute a highpart multiply.
315:
316:    FIX: I am not at all convinced that
317:      3 loads, 2 multiplications, 3 shifts, and 3 additions
318:    will be faster than
319:      1 load and 1 modulus
320:    on modern systems running a compiler.  */
321:
322: inline hashval_t
323: mul_mod (hashval_t x, hashval_t y, hashval_t inv, int shift)
324: {
325:    hashval_t t1, t2, t3, t4, q, r;
326:
327:    t1 = ((uint64_t)x * inv) >> 32;
328:    t2 = x - t1;
329:    t3 = t2 >> 1;
330:    t4 = t1 + t3;
331:    q  = t4 >> shift;
332:    r  = x - (q * y);
333:
334:    return r;
335: }
336:
337: /* Compute the primary table index for HASH given current prime index.  */
338:
339: inline hashval_t
340: hash_table_mod1 (hashval_t hash, unsigned int index)
341: {
342:   const struct prime_ent *p = &prime_tab[index];
343:   gcc_checking_assert (sizeof (hashval_t) * CHAR_BIT <= 32);
344:   return mul_mod (hash, p->prime, p->inv, p->shift);
345: }
346:
347: /* Compute the secondary table index for HASH given current prime index.  */
348:
349: inline hashval_t
350: hash_table_mod2 (hashval_t hash, unsigned int index)
351: {
352:   const struct prime_ent *p = &prime_tab[index];
353:   gcc_checking_assert (sizeof (hashval_t) * CHAR_BIT <= 32);
354:   return 1 + mul_mod (hash, p->prime - 2, p->inv_m2, p->shift);
355: }
```

## gcc/hash-table.h:599–617
```text
599:   size_t m_size;
600:
601:   /* Current number of elements including also deleted elements.  */
602:   size_t m_n_elements;
603:
604:   /* Current number of deleted elements in the table.  */
605:   size_t m_n_deleted;
606:
607:   /* The following member is used for debugging. Its value is number
608:      of all calls of `htab_find_slot' for the hash table. */
609:   unsigned int m_searches;
610:
611:   /* The following member is used for debugging.  Its value is number
612:      of collisions fixed for time of work with the hash table. */
613:   unsigned int m_collisions;
614:
615:   /* Current size (in entries) of the hash table, as an index into the
616:      table of primes.  */
617:   unsigned int m_size_prime_index;
```

## gcc/hash-table.h:656–679
```text
656:   m_ggc (ggc), m_sanitize_eq_and_hash (sanitize_eq_and_hash)
657: #if GATHER_STATISTICS
658:   , m_gather_mem_stats (gather_mem_stats)
659: #endif
660: {
661:   unsigned int size_prime_index;
662:
663:   size_prime_index = hash_table_higher_prime_index (size);
664:   size = prime_tab[size_prime_index].prime;
665:
666:   if (m_gather_mem_stats)
667:     hash_table_usage ().register_descriptor (this, origin, ggc
668: 					     FINAL_PASS_MEM_STAT);
669:
670:   if (Lazy)
671:     m_entries = NULL;
672:   else
673:     m_entries = alloc_entries (size PASS_MEM_STAT);
674:   m_size = size;
675:   m_size_prime_index = size_prime_index;
676: }
677:
678: template<typename Descriptor, bool Lazy,
679: 	 template<typename Type> class Allocator>
```

## gcc/hash-table.h:755–778
```text
755: inline typename hash_table<Descriptor, Lazy, Allocator>::value_type *
756: hash_table<Descriptor, Lazy,
757: 	   Allocator>::alloc_entries (size_t n MEM_STAT_DECL) const
758: {
759:   value_type *nentries;
760:
761:   if (m_gather_mem_stats)
762:     hash_table_usage ().register_instance_overhead (sizeof (value_type) * n, this);
763:
764:   if (!m_ggc)
765:     nentries = Allocator <value_type> ::data_alloc (n);
766:   else
767:     nentries = ::ggc_cleared_vec_alloc<value_type> (n PASS_MEM_STAT);
768:
769:   gcc_assert (nentries != NULL);
770:   if (!Descriptor::empty_zero_p)
771:     for (size_t i = 0; i < n; i++)
772:       mark_empty (nentries[i]);
773:
774:   return nentries;
775: }
776:
777: /* Similar to find_slot, but without several unwanted side effects:
778:     - Does not call equal when it finds an existing entry.
```

## gcc/hash-table.h:788–821
```text
788: 	   Allocator>::find_empty_slot_for_expand (hashval_t hash)
789: {
790:   hashval_t index = hash_table_mod1 (hash, m_size_prime_index);
791:   size_t size = m_size;
792:   value_type *slot = m_entries + index;
793:   hashval_t hash2;
794:
795:   if (is_empty (*slot))
796:     return slot;
797:   gcc_checking_assert (!is_deleted (*slot));
798:
799:   hash2 = hash_table_mod2 (hash, m_size_prime_index);
800:   for (;;)
801:     {
802:       index += hash2;
803:       if (index >= size)
804:         index -= size;
805:
806:       slot = m_entries + index;
807:       if (is_empty (*slot))
808:         return slot;
809:       gcc_checking_assert (!is_deleted (*slot));
810:     }
811: }
812:
813: /* Return true if the current table is excessively big for ELTS elements.  */
814:
815: template<typename Descriptor, bool Lazy,
816: 	 template<typename Type> class Allocator>
817: inline bool
818: hash_table<Descriptor, Lazy, Allocator>::too_empty_p (unsigned int elts)
819: {
820:   return elts * 8 < m_size && m_size > 32;
821: }
```

## gcc/hash-table.h:833–895
```text
833: hash_table<Descriptor, Lazy, Allocator>::expand ()
834: {
835:   check_complete_insertion ();
836:
837:   value_type *oentries = m_entries;
838:   unsigned int oindex = m_size_prime_index;
839:   size_t osize = size ();
840:   value_type *olimit = oentries + osize;
841:   size_t elts = elements ();
842:
843:   /* Resize only when table after removal of unused elements is either
844:      too full or too empty.  */
845:   unsigned int nindex;
846:   size_t nsize;
847:   if (elts * 2 > osize || too_empty_p (elts))
848:     {
849:       nindex = hash_table_higher_prime_index (elts * 2);
850:       nsize = prime_tab[nindex].prime;
851:     }
852:   else
853:     {
854:       nindex = oindex;
855:       nsize = osize;
856:     }
857:
858:   value_type *nentries = alloc_entries (nsize);
859:
860:   if (m_gather_mem_stats)
861:     hash_table_usage ().release_instance_overhead (this, sizeof (value_type)
862: 						    * osize);
863:
864:   size_t n_deleted = m_n_deleted;
865:
866:   m_entries = nentries;
867:   m_size = nsize;
868:   m_size_prime_index = nindex;
869:   m_n_elements -= m_n_deleted;
870:   m_n_deleted = 0;
871:
872:   size_t n_elements = m_n_elements;
873:
874:   value_type *p = oentries;
875:   do
876:     {
877:       value_type &x = *p;
878:
879:       if (is_empty (x))
880: 	;
881:       else if (is_deleted (x))
882: 	n_deleted--;
883:       else
884:         {
885: 	  n_elements--;
886:           value_type *q = find_empty_slot_for_expand (Descriptor::hash (x));
887: 	  new ((void*) q) value_type (std::move (x));
888: 	  /* After the resources of 'x' have been moved to a new object at 'q',
889: 	     we now have to destroy the 'x' object, to end its lifetime.  */
890: 	  x.~value_type ();
891:         }
892:
893:       p++;
894:     }
895:   while (p < olimit);
```

## gcc/hash-table.h:1026–1093
```text
1026: 	 template<typename Type> class Allocator>
1027: typename hash_table<Descriptor, Lazy, Allocator>::value_type *
1028: hash_table<Descriptor, Lazy, Allocator>
1029: ::find_slot_with_hash (const compare_type &comparable, hashval_t hash,
1030: 		       enum insert_option insert)
1031: {
1032:   if (Lazy && m_entries == NULL)
1033:     {
1034:       if (insert == INSERT)
1035: 	m_entries = alloc_entries (m_size);
1036:       else
1037: 	return NULL;
1038:     }
1039:   if (insert == INSERT && m_size * 3 <= m_n_elements * 4)
1040:     expand ();
1041:   else
1042:     check_complete_insertion ();
1043:
1044: #if CHECKING_P
1045:   if (m_sanitize_eq_and_hash)
1046:     verify (comparable, hash);
1047: #endif
1048:
1049:   m_searches++;
1050:   value_type *first_deleted_slot = NULL;
1051:   hashval_t index = hash_table_mod1 (hash, m_size_prime_index);
1052:   hashval_t hash2 = hash_table_mod2 (hash, m_size_prime_index);
1053:   value_type *entry = &m_entries[index];
1054:   size_t size = m_size;
1055:   if (is_empty (*entry))
1056:     goto empty_entry;
1057:   else if (is_deleted (*entry))
1058:     first_deleted_slot = &m_entries[index];
1059:   else if (Descriptor::equal (*entry, comparable))
1060:     return &m_entries[index];
1061:
1062:   for (;;)
1063:     {
1064:       m_collisions++;
1065:       index += hash2;
1066:       if (index >= size)
1067: 	index -= size;
1068:
1069:       entry = &m_entries[index];
1070:       if (is_empty (*entry))
1071: 	goto empty_entry;
1072:       else if (is_deleted (*entry))
1073: 	{
1074: 	  if (!first_deleted_slot)
1075: 	    first_deleted_slot = &m_entries[index];
1076: 	}
1077:       else if (Descriptor::equal (*entry, comparable))
1078: 	return &m_entries[index];
1079:     }
1080:
1081:  empty_entry:
1082:   if (insert == NO_INSERT)
1083:     return NULL;
1084:
1085:   if (first_deleted_slot)
1086:     {
1087:       m_n_deleted--;
1088:       mark_empty (*first_deleted_slot);
1089:       return check_insert_slot (first_deleted_slot);
1090:     }
1091:
1092:   m_n_elements++;
1093:   return check_insert_slot (&m_entries[index]);
```

## gcc/hash-table.cc:44–78
```text
44:   {          7, 0x24924925, 0x9999999b, 2 },
45:   {         13, 0x3b13b13c, 0x745d1747, 3 },
46:   {         31, 0x08421085, 0x1a7b9612, 4 },
47:   {         61, 0x0c9714fc, 0x15b1e5f8, 5 },
48:   {        127, 0x02040811, 0x0624dd30, 6 },
49:   {        251, 0x05197f7e, 0x073260a5, 7 },
50:   {        509, 0x01824366, 0x02864fc8, 8 },
51:   {       1021, 0x00c0906d, 0x014191f7, 9 },
52:   {       2039, 0x0121456f, 0x0161e69e, 10 },
53:   {       4093, 0x00300902, 0x00501908, 11 },
54:   {       8191, 0x00080041, 0x00180241, 12 },
55:   {      16381, 0x000c0091, 0x00140191, 13 },
56:   {      32749, 0x002605a5, 0x002a06e6, 14 },
57:   {      65521, 0x000f00e2, 0x00110122, 15 },
58:   {     131071, 0x00008001, 0x00018003, 16 },
59:   {     262139, 0x00014002, 0x0001c004, 17 },
60:   {     524287, 0x00002001, 0x00006001, 18 },
61:   {    1048573, 0x00003001, 0x00005001, 19 },
62:   {    2097143, 0x00004801, 0x00005801, 20 },
63:   {    4194301, 0x00000c01, 0x00001401, 21 },
64:   {    8388593, 0x00001e01, 0x00002201, 22 },
65:   {   16777213, 0x00000301, 0x00000501, 23 },
66:   {   33554393, 0x00001381, 0x00001481, 24 },
67:   {   67108859, 0x00000141, 0x000001c1, 25 },
68:   {  134217689, 0x000004e1, 0x00000521, 26 },
69:   {  268435399, 0x00000391, 0x000003b1, 27 },
70:   {  536870909, 0x00000019, 0x00000029, 28 },
71:   { 1073741789, 0x0000008d, 0x00000095, 29 },
72:   { 2147483647, 0x00000003, 0x00000007, 30 },
73:   /* Avoid "decimal constant so large it is unsigned" for 4294967291.  */
74:   { 0xfffffffb, 0x00000006, 0x00000008, 31 }
75: };
76:
77: /* Limit number of comparisons when calling hash_table<>::verify.  */
78: unsigned int hash_table_sanitize_eq_limit;
```

## gcc/hash-table.cc:87–110
```text
87:   unsigned int high = ARRAY_SIZE (prime_tab);
88:
89:   while (low != high)
90:     {
91:       unsigned int mid = low + (high - low) / 2;
92:       if (n > prime_tab[mid].prime)
93: 	low = mid + 1;
94:       else
95: 	high = mid;
96:     }
97:
98:   /* If we've run out of primes, abort.  */
99:   gcc_assert (n <= prime_tab[low].prime);
100:
101:   return low;
102: }
103:
104: /* Return a reference to the lazily initialized hash-table usage description.
105:    This needs to be a function rather than a simple global variable so that it
106:    is reliably initialized before hash table variables in other files such as
107:    sem_item::m_type_hash_cache.  */
108: mem_alloc_description<mem_usage>&
109: hash_table_usage ()
110: {
```

## include/hashtab.h:32–46
```text
32: #ifndef __HASHTAB_H__
33: #define __HASHTAB_H__
34:
35: #ifdef __cplusplus
36: extern "C" {
37: #endif /* __cplusplus */
38:
39: #include "ansidecl.h"
40:
41: /* The type for a hash code.  */
42: typedef unsigned int hashval_t;
43:
44: /* Callback function pointer types.  */
45:
46: /* Calculate hash of a table entry.  */
```
