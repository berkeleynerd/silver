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

## gcc/ada/gcc-interface/trans.cc:1201–1289
```text
1201:   int require_lvalue;
1202:
1203:   /* If the Etype of this node is not the same as that of the Entity, then
1204:      something went wrong, probably in generic instantiation.  However, this
1205:      does not apply to types.  Since we sometime have strange Ekind's, just
1206:      do this test for objects, except for discriminants because their type
1207:      may have been changed to a subtype by Exp_Ch3.Adjust_Discriminants.  */
1208:   gcc_assert (!Is_Object (gnat_entity)
1209: 	      || Ekind (gnat_entity) == E_Discriminant
1210: 	      || Etype (gnat_node) == Etype (gnat_entity)
1211: 	      || Gigi_Types_Compatible (Etype (gnat_node),
1212: 					Etype (gnat_entity)));
1213:
1214:   /* If this is a reference to a deferred constant whose partial view is of
1215:      unconstrained private type, the proper type is on the full view of the
1216:      constant, not on the full view of the type which may be unconstrained.  */
1217:   const Entity_Id gnat_full_view = Full_View_Of_Private_Constant (gnat_entity);
1218:   if (Present (gnat_full_view))
1219:     {
1220:       gnat_entity = gnat_full_view;
1221:       gnat_result_type = Etype (gnat_entity);
1222:     }
1223:   else
1224:     {
1225:       /* We use the Actual_Subtype only if it has already been elaborated,
1226: 	 as we may be invoked precisely during its elaboration, otherwise
1227: 	 the Etype.  Avoid using it for packed arrays to simplify things,
1228: 	 except in a return statement because we need the actual size and
1229: 	 the front-end does not make it explicit in this case.  */
1230:       if ((Ekind (gnat_entity) == E_Constant
1231: 	   || Ekind (gnat_entity) == E_Variable
1232: 	   || Is_Formal (gnat_entity))
1233: 	  && !(Is_Array_Type (Etype (gnat_entity))
1234: 	       && Present (Packed_Array_Impl_Type (Etype (gnat_entity)))
1235: 	       && Nkind (Parent (gnat_node)) != N_Simple_Return_Statement)
1236: 	  && Present (Actual_Subtype (gnat_entity))
1237: 	  && present_gnu_tree (Actual_Subtype (gnat_entity)))
1238: 	gnat_result_type = Actual_Subtype (gnat_entity);
1239:       else
1240: 	gnat_result_type = Etype (gnat_node);
1241:     }
1242:
1243:   /* Expand the type of this identifier first if it is needed, in case it is an
1244:      enumeral literal, which only get made when the type is expanded.  There is
1245:      no order-of-elaboration issue here.  */
1246:   if (Is_Subprogram (gnat_entity))
1247:     gnu_result_type = NULL_TREE;
1248:   else if (Nkind (Original_Node (gnat_node)) == N_Explicit_Dereference
1249: 	   && Is_Extended_Access_Type
1250: 	      (Etype (Prefix (Original_Node (gnat_node)))))
1251:     gnu_result_type = get_unpadded_extended_type (gnat_result_type);
1252:   else
1253:     gnu_result_type = get_unpadded_type (gnat_result_type);
1254:
1255:   /* If this is a non-imported elementary constant with an address clause,
1256:      retrieve the value instead of a pointer to be dereferenced unless
1257:      an lvalue is required.  This is generally more efficient and actually
1258:      required if this is a static expression because it might be used
1259:      in a context where a dereference is inappropriate, such as a case
1260:      statement alternative or a record discriminant.  There is no possible
1261:      volatile-ness short-circuit here since Volatile constants must be
1262:      imported per C.6.  */
1263:   if (Ekind (gnat_entity) == E_Constant
1264:       && Is_Elementary_Type (gnat_result_type)
1265:       && !Is_Imported (gnat_entity)
1266:       && Present (Address_Clause (gnat_entity)))
1267:     {
1268:       require_lvalue
1269: 	= lvalue_required_p (gnat_node, gnu_result_type, true, false);
1270:       use_constant_initializer = !require_lvalue;
1271:     }
1272:   else
1273:     {
1274:       require_lvalue = -1;
1275:       use_constant_initializer = false;
1276:     }
1277:
1278:   /* Fetch the initialization value of a constant if requested.  */
1279:   if (use_constant_initializer)
1280:     {
1281:       /* If this is a deferred constant, the initializer is attached to
1282: 	 the full view.  */
1283:       if (Present (Full_View (gnat_entity)))
1284: 	gnat_entity = Full_View (gnat_entity);
1285:
1286:       gnu_result = gnat_to_gnu (Expression (Declaration_Node (gnat_entity)));
1287:     }
1288:   else
1289:     gnu_result = gnat_to_gnu_entity (gnat_entity, NULL_TREE, false);
```

## gcc/ada/gcc-interface/trans.cc:1330–1369
```text
1330:   if (constant_decl_with_initializer_p (gnu_result))
1331:     {
1332:       bool constant_only = (TREE_CODE (gnu_result) == CONST_DECL
1333: 			    && !DECL_CONST_CORRESPONDING_VAR (gnu_result));
1334:       bool address_of_constant = (TREE_CODE (gnu_result) == CONST_DECL
1335: 				  && DECL_CONST_ADDRESS_P (gnu_result));
1336:
1337:       /* If there is a (corresponding) variable or this is the address of a
1338: 	 constant, we only want to return the initializer if an lvalue isn't
1339: 	 required.  Evaluate this now if we have not already done so.  */
1340:       if ((!constant_only || address_of_constant) && require_lvalue < 0)
1341: 	require_lvalue
1342: 	  = lvalue_required_p (gnat_node, gnu_result_type, true,
1343: 			       address_of_constant)
1344: 	    || (AGGREGATE_TYPE_P (gnu_result_type)
1345: 		&& lvalue_for_aggregate_p (gnat_node, gnu_result_type));
1346:
1347:       /* Finally retrieve the initializer if this is deemed valid.  */
1348:       if ((constant_only && !address_of_constant) || !require_lvalue)
1349: 	gnu_result = DECL_INITIAL (gnu_result);
1350:     }
1351:
1352:   /* But for a constant renaming we couldn't do that incrementally for its
1353:      definition because of the need to return an lvalue so, if the present
1354:      context doesn't itself require an lvalue, we try again here.  */
1355:   else if (Ekind (gnat_entity) == E_Constant
1356: 	   && Is_Elementary_Type (gnat_result_type)
1357: 	   && Present (Renamed_Object (gnat_entity)))
1358:     {
1359:       if (require_lvalue < 0)
1360: 	require_lvalue
1361: 	  = lvalue_required_p (gnat_node, gnu_result_type, true, false);
1362:       if (!require_lvalue)
1363: 	gnu_result = fold_constant_decl_in_expr (gnu_result);
1364:     }
1365:
1366:   /* The GNAT tree has the type of a function set to its result type, so we
1367:      adjust here.  Also use the type of the result if the Etype is a subtype
1368:      that is nominally unconstrained.  Likewise if this is a deferred constant
1369:      of a discriminated type whose full view can be elaborated statically, to
```

## gcc/ada/gcc-interface/trans.cc:4911–5015
```text
4911:      parameters not passed by reference and that need not be copied in.  */
4912:   for (gnat_actual = First_Actual (gnat_node);
4913:        Present (gnat_actual);
4914:        gnat_formal = Next_Formal_With_Extras (gnat_formal),
4915:        gnat_actual = Next_Actual (gnat_actual))
4916:     {
4917:       const Entity_Id gnat_formal_type = Etype (gnat_formal);
4918:       tree gnu_formal_type = gnat_to_gnu_type (gnat_formal_type);
4919:       tree gnu_formal = present_gnu_tree (gnat_formal)
4920: 			? get_gnu_tree (gnat_formal) : NULL_TREE;
4921:       tree gnu_actual_type = gnat_to_gnu_type (Etype (gnat_actual));
4922:       const bool is_init_proc
4923: 	= Is_Entity_Name (gnat_subprog) && Is_Init_Proc (Entity (gnat_subprog));
4924:       const bool in_param = (Ekind (gnat_formal) == E_In_Parameter);
4925:       const bool is_true_formal_parm
4926: 	= gnu_formal && TREE_CODE (gnu_formal) == PARM_DECL;
4927:       const bool is_by_ref_formal_parm
4928: 	= is_true_formal_parm
4929: 	  && (DECL_BY_REF_P (gnu_formal)
4930: 	      || DECL_BY_COMPONENT_PTR_P (gnu_formal));
4931:       /* In the In Out or Out case, we must suppress conversions that yield
4932: 	 an lvalue but can nevertheless cause the creation of a temporary,
4933: 	 because we need the real object in this case, either to pass its
4934: 	 address if it's passed by reference or as target of the back copy
4935: 	 done after the call if it uses the copy-in/copy-out mechanism.
4936: 	 We do it in the In case too, except for a formal passed by reference
4937: 	 and an actual which is an unchecked conversion to an elementary type
4938: 	 or constrained composite type because it itself can cause the actual
4939: 	 to be misaligned and the addressability test needs to be applied to
4940: 	 the real object.  */
4941:       const bool suppress_type_conversion
4942: 	= ((Nkind (gnat_actual) == N_Unchecked_Type_Conversion
4943: 	    && (!in_param
4944: 		|| !is_by_ref_formal_parm
4945: 		|| (Is_Composite_Type (Underlying_Type (gnat_formal_type))
4946: 		    && !Is_Constrained (Underlying_Type (gnat_formal_type)))))
4947: 	   || (Nkind (gnat_actual) == N_Type_Conversion
4948: 	       && Is_Composite_Type (Underlying_Type (gnat_formal_type))));
4949:       Node_Id gnat_name = suppress_type_conversion
4950: 			  ? Expression (gnat_actual) : gnat_actual;
4951:       tree gnu_name = gnat_to_gnu (gnat_name), gnu_name_type;
4952:       bool aliasing = false;
4953:
4954:       /* If it's possible we may need to use this expression twice, make sure
4955: 	 that any side-effects are handled via SAVE_EXPRs; likewise if we need
4956: 	 to force side-effects before the call.  */
4957:       if (!in_param && !is_by_ref_formal_parm)
4958: 	{
4959: 	  tree init = NULL_TREE;
4960: 	  gnu_name = gnat_stabilize_reference (gnu_name, true, &init);
4961: 	  if (init)
4962: 	    gnu_name
4963: 	      = build_compound_expr (TREE_TYPE (gnu_name), init, gnu_name);
4964: 	}
4965:
4966:       /* If we are passing a non-addressable parameter by reference, pass the
4967: 	 address of a copy.  In the In Out or Out case, set up to copy back
4968: 	 out after the call.  Moreover, in the case of a conversion, if we
4969: 	 are passing a non-aliasable parameter, also pass the address of a
4970: 	 copy to avoid breaking strict aliasing rules.  */
4971:       if (is_by_ref_formal_parm
4972: 	  && (gnu_name_type = gnat_to_gnu_type (Etype (gnat_name)))
4973: 	  && (!addressable_p (gnu_name, gnu_name_type, is_init_proc)
4974: 	      || (node_is_type_conversion (gnat_actual)
4975: 		  && (aliasing = !aliasable_p (gnu_name, gnu_actual_type)))))
4976: 	{
4977: 	  tree gnu_orig = gnu_name, gnu_temp, gnu_stmt;
4978:
4979: 	  /* Do not issue warnings for CONSTRUCTORs since this is not a copy
4980: 	     but sort of an instantiation for them.  */
4981: 	  if (TREE_CODE (remove_conversions (gnu_name, true)) == CONSTRUCTOR)
4982: 	    ;
4983:
4984: 	  /* Likewise for an atomic type, which is defined to be by-reference
4985: 	     if it is not by-copy but actually behaves more like a scalar.  */
4986: 	  else if (TYPE_ATOMIC (gnu_formal_type))
4987: 	    ;
4988:
4989: 	  /* If the formal is passed by reference, a copy is not allowed.  */
4990: 	  else if (TYPE_IS_BY_REFERENCE_P (gnu_formal_type)
4991: 		   || Is_Aliased (gnat_formal))
4992: 	    post_error ("misaligned actual cannot be passed by reference",
4993: 		        gnat_actual);
4994:
4995: 	  /* If the mechanism was forced to by-ref, a copy is not allowed but
4996: 	     we issue only a warning because this case is not strict Ada.  */
4997: 	  else if (DECL_FORCED_BY_REF_P (gnu_formal))
4998: 	    post_error ("misaligned actual cannot be passed by reference??",
4999: 			gnat_actual);
5000:
5001: 	  /* If the copy needs to be made because of aliasing considerations,
5002: 	     issue a warning because this was historically not necessary.  */
5003: 	  else if (aliasing)
5004: 	    {
5005: 	      if (Nkind (gnat_actual) == N_Unchecked_Type_Conversion)
5006: 		{
5007: 		  post_error
5008: 		    ("unchecked conversion implemented by copy??",
5009: 		     gnat_actual);
5010: 		  post_error
5011: 		    ("\\??use pragma Universal_Aliasing on either type",
5012: 		     gnat_actual);
5013: 		  post_error
5014: 		    ("\\??to enable RM 13.9(12) implementation permission",
5015: 		     gnat_actual);
```

## gcc/ada/gcc-interface/trans.cc:5688–5691
```text
5688:   for (gnat_temp = First (Statements (gnat_node));
5689:        Present (gnat_temp);
5690:        gnat_temp = Next (gnat_temp))
5691:     add_stmt (gnat_to_gnu (gnat_temp));
```

## gcc/ada/gcc-interface/trans.cc:6779–6881
```text
6779:       gnu_result = alloc_stmt_list ();
6780:
6781:       /* If we are just annotating types and this object has an unconstrained
6782: 	 or task type, don't elaborate it.   */
6783:       if (type_annotate_only
6784: 	  && (((Is_Array_Type (Etype (gnat_temp))
6785: 		|| Is_Record_Type (Etype (gnat_temp)))
6786: 	       && !Is_Constrained (Etype (gnat_temp)))
6787: 	      || Is_Concurrent_Type (Etype (gnat_temp))))
6788: 	break;
6789:
6790:       /* If this is a constant related to a return initialized by a reference
6791: 	 to a function call in a function returning by invisible reference:
6792:
6793: 	   type Ann is access all Result_Type;
6794: 	   Rnn : constant Ann := Func'reference;
6795: 	   [...]
6796: 	   return Rnn.all;
6797:
6798: 	 then elide the temporary by forwarding the return object to Func:
6799:
6800: 	   result_type *Rnn = (result_type *) <retval>;
6801: 	   *<retval> = Func (); [return slot optimization]
6802: 	   [...]
6803: 	   return Rnn;
6804:
6805: 	 That's necessary if the result type needs finalization because the
6806: 	 temporary would never be adjusted as Expand_Simple_Function_Return
6807: 	 also elides the temporary in this case.  */
6808:       if (Ekind (gnat_temp) == E_Constant
6809: 	  && Is_Related_To_Func_Return (gnat_temp)
6810: 	  && Nkind (Expression (gnat_node)) == N_Reference
6811: 	  && Nkind (Prefix (Expression (gnat_node))) == N_Function_Call
6812: 	  && current_function_decl
6813: 	  && TREE_ADDRESSABLE (TREE_TYPE (current_function_decl)))
6814: 	{
6815: 	  gnat_to_gnu_entity (gnat_temp,
6816: 			      DECL_RESULT (current_function_decl),
6817: 			      true);
6818: 	  gnu_result
6819: 	    = build_unary_op (INDIRECT_REF, NULL_TREE,
6820: 			      DECL_RESULT (current_function_decl));
6821: 	  gnu_result
6822: 	    = Call_to_gnu (Prefix (Expression (gnat_node)),
6823: 			   &gnu_result_type, gnu_result,
6824: 			   NOT_ATOMIC, false, Empty);
6825: 	  break;
6826: 	}
6827:
6828:       if (Present (Expression (gnat_node))
6829: 	  && !(kind == N_Object_Declaration && No_Initialization (gnat_node))
6830: 	  && (!type_annotate_only
6831: 	      || Compile_Time_Known_Value (Expression (gnat_node))))
6832: 	{
6833: 	  gigi_checking_assert (!Do_Range_Check (Expression (gnat_node)));
6834:
6835: 	  gnu_expr = gnat_to_gnu (Expression (gnat_node));
6836:
6837: 	  /* First deal with erroneous expressions.  */
6838: 	  if (TREE_CODE (gnu_expr) == ERROR_MARK)
6839: 	    {
6840: 	      /* If this is a named number for which we cannot manipulate
6841: 		 the value, just skip the declaration altogether.  */
6842: 	      if (kind == N_Number_Declaration)
6843: 		break;
6844: 	      else if (type_annotate_only)
6845: 		gnu_expr = NULL_TREE;
6846: 	    }
6847:
6848: 	  /* Then a special case: we do not want the SLOC of the expression
6849: 	     of the tag to pop up every time it is referenced somewhere.  */
6850: 	  else if (EXPR_P (gnu_expr) && Is_Tag (gnat_temp))
6851: 	    SET_EXPR_LOCATION (gnu_expr, UNKNOWN_LOCATION);
6852: 	}
6853:       else
6854: 	gnu_expr = NULL_TREE;
6855:
6856:       /* If this is a deferred constant with an address clause, we ignore the
6857: 	 full view since the clause is on the partial view and we cannot have
6858: 	 2 different GCC trees for the object.  The only bits of the full view
6859: 	 we will use is the initializer, but it will be directly fetched.  */
6860:       if (Ekind (gnat_temp) == E_Constant
6861: 	  && Present (Address_Clause (gnat_temp))
6862: 	  && Present (Full_View (gnat_temp)))
6863: 	save_gnu_tree (Full_View (gnat_temp), error_mark_node, true);
6864:
6865:       /* If this object has its elaboration delayed, we must force evaluation
6866: 	 of GNU_EXPR now and save it for the freeze point.  Note that we need
6867: 	 not do anything special at the global level since the lifetime of the
6868: 	 temporary is fully contained within the elaboration routine.  */
6869:       if (Present (Freeze_Node (gnat_temp)))
6870: 	{
6871: 	  if (gnu_expr)
6872: 	    {
6873: 	      gnu_result = gnat_save_expr (gnu_expr);
6874: 	      save_gnu_tree (gnat_node, gnu_result, true);
6875: 	    }
6876: 	}
6877:       else
6878: 	gnat_to_gnu_entity (gnat_temp, gnu_expr, true);
6879:       break;
6880:
6881:     case N_Object_Renaming_Declaration:
```

## gcc/ada/gcc-interface/trans.cc:7086–7116
```text
7086:     case N_Slice:
7087:       {
7088: 	const Entity_Id gnat_array_object = Prefix (gnat_node);
7089: 	tree gnu_array_object = gnat_to_gnu (gnat_array_object);
7090:
7091: 	/* Get the storage model of the array.  */
7092: 	gnat_smo = get_storage_model (gnat_array_object);
7093:
7094: 	gnu_array_object = maybe_padded_object (gnu_array_object);
7095: 	gnu_array_object = maybe_unconstrained_array (gnu_array_object);
7096:
7097: 	gnu_result_type = get_unpadded_type (Etype (gnat_node));
7098:
7099: 	gnu_expr = TYPE_MIN_VALUE (TYPE_DOMAIN (gnu_result_type));
7100: 	gnu_expr = maybe_character_value (gnu_expr);
7101:
7102: 	/* If this is a slice with non-constant size of an array with constant
7103: 	   size, set the maximum size for the allocation of temporaries.  */
7104: 	if (!TREE_CONSTANT (TYPE_SIZE_UNIT (gnu_result_type))
7105: 	    && TREE_CONSTANT (TYPE_SIZE_UNIT (TREE_TYPE (gnu_array_object))))
7106: 	  TYPE_ARRAY_MAX_SIZE (gnu_result_type)
7107: 	    = TYPE_SIZE_UNIT (TREE_TYPE (gnu_array_object));
7108:
7109: 	gnu_result = build_binary_op (ARRAY_RANGE_REF, gnu_result_type,
7110: 				      gnu_array_object, gnu_expr);
7111:
7112: 	if (Present (gnat_smo)
7113: 	    && Present (Storage_Model_Copy_From (gnat_smo)))
7114: 	  instantiate_load_in_array_ref (gnu_result, gnat_smo);
7115:
7116: 	/* If storage model access is required on the RHS, build the load.  */
```

## gcc/ada/gcc-interface/trans.cc:7291–7342
```text
7291:     case N_Type_Conversion:
7292:     case N_Qualified_Expression:
7293:       gnu_expr = maybe_character_value (gnat_to_gnu (Expression (gnat_node)));
7294:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
7295:
7296:       /* If this is a qualified expression for a tagged type, we mark the type
7297: 	 as used.  Because of polymorphism, this might be the only reference to
7298: 	 the tagged type in the program while objects have it as dynamic type.
7299: 	 The debugger needs to see it to display these objects properly.  */
7300:       if (kind == N_Qualified_Expression && Is_Tagged_Type (Etype (gnat_node)))
7301: 	used_types_insert (gnu_result_type);
7302:
7303:       gigi_checking_assert (!Do_Range_Check (Expression (gnat_node)));
7304:
7305:       gnu_result
7306: 	= convert_with_check (Etype (gnat_node), gnu_expr,
7307: 			      Do_Overflow_Check (gnat_node),
7308: 			      kind == N_Type_Conversion
7309: 			      && Float_Truncate (gnat_node), gnat_node);
7310:       break;
7311:
7312:     case N_Unchecked_Type_Conversion:
7313:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
7314:       gnu_expr = maybe_character_value (gnat_to_gnu (Expression (gnat_node)));
7315:
7316:       /* Skip further processing if the conversion is deemed a no-op.  */
7317:       if (unchecked_conversion_nop (gnat_node))
7318: 	{
7319: 	  gnu_result = gnu_expr;
7320: 	  gnu_result_type = TREE_TYPE (gnu_result);
7321: 	  break;
7322: 	}
7323:
7324:       /* If the result is a pointer type, see if we are improperly
7325: 	 converting to a stricter alignment.  */
7326:       if (STRICT_ALIGNMENT && POINTER_TYPE_P (gnu_result_type)
7327: 	  && Is_Access_Type (Etype (gnat_node)))
7328: 	{
7329: 	  unsigned int align = known_alignment (gnu_expr);
7330: 	  tree gnu_obj_type = TREE_TYPE (gnu_result_type);
7331: 	  unsigned int oalign = TYPE_ALIGN (gnu_obj_type);
7332:
7333: 	  /* Skip tagged types because conversions to the class-wide type are
7334: 	     translated into conversions to the root type, which may be less
7335: 	     aligned than some of its derived types.  */
7336: 	  if (align != 0
7337: 	      && align < oalign
7338: 	      && !type_is_tagged_or_cw_equivalent (gnu_obj_type))
7339: 	    post_error_ne_tree_2
7340: 	      ("??source alignment (^) '< alignment of & (^)",
7341: 	       gnat_node, Designated_Type (Etype (gnat_node)),
7342: 	       size_int (align / BITS_PER_UNIT), oalign / BITS_PER_UNIT);
```

## gcc/ada/gcc-interface/trans.cc:7415–7470
```text
7415:     case N_Op_Eq:
7416:     case N_Op_Ne:
7417:     case N_Op_Lt:
7418:     case N_Op_Le:
7419:     case N_Op_Gt:
7420:     case N_Op_Ge:
7421:     case N_Op_Add:
7422:     case N_Op_Subtract:
7423:     case N_Op_Multiply:
7424:     case N_Op_Mod:
7425:     case N_Op_Rem:
7426:     case N_Op_Rotate_Left:
7427:     case N_Op_Rotate_Right:
7428:     case N_Op_Shift_Left:
7429:     case N_Op_Shift_Right:
7430:     case N_Op_Shift_Right_Arithmetic:
7431:     case N_Op_And:
7432:     case N_Op_Or:
7433:     case N_Op_Xor:
7434:     case N_And_Then:
7435:     case N_Or_Else:
7436:       {
7437: 	enum tree_code code = gnu_codes[kind];
7438: 	bool ignore_lhs_overflow = false;
7439: 	location_t saved_location = input_location;
7440: 	tree gnu_type, gnu_max_shift = NULL_TREE;
7441:
7442: 	/* Fix operations set up for boolean types in GNU_CODES above.  */
7443: 	if (Is_Modular_Integer_Type (Underlying_Type (Etype (gnat_node))))
7444: 	  switch (kind)
7445: 	    {
7446: 	    case N_Op_And:
7447: 	      code = BIT_AND_EXPR;
7448: 	      break;
7449: 	    case N_Op_Or:
7450: 	      code = BIT_IOR_EXPR;
7451: 	      break;
7452: 	    case N_Op_Xor:
7453: 	      code = BIT_XOR_EXPR;
7454: 	      break;
7455: 	    default:
7456: 	      break;
7457: 	    }
7458:
7459: 	gnu_lhs = gnat_to_gnu (Left_Opnd (gnat_node));
7460: 	gnu_rhs = gnat_to_gnu (Right_Opnd (gnat_node));
7461: 	gnu_type = gnu_result_type = get_unpadded_type (Etype (gnat_node));
7462:
7463: 	/* If this is a shift, take the count as unsigned since that is what
7464: 	   most machines do and will generate simpler adjustments below.  */
7465: 	if (IN (kind, N_Op_Shift))
7466: 	  {
7467: 	    tree gnu_count_type
7468: 	      = gnat_unsigned_type_for (get_base_type (TREE_TYPE (gnu_rhs)));
7469: 	    gnu_rhs = convert (gnu_count_type, gnu_rhs);
7470: 	    gnu_max_shift
```

## gcc/ada/gcc-interface/trans.cc:7605–7616
```text
7605:     case N_If_Expression:
7606:       {
7607: 	tree gnu_cond = gnat_to_gnu (First (Expressions (gnat_node)));
7608: 	tree gnu_true = gnat_to_gnu (Next (First (Expressions (gnat_node))));
7609: 	tree gnu_false
7610: 	  = gnat_to_gnu (Next (Next (First (Expressions (gnat_node)))));
7611:
7612: 	gnu_result_type = get_unpadded_type (Etype (gnat_node));
7613: 	gnu_result
7614: 	  = build_cond_expr (gnu_result_type, gnu_cond, gnu_true, gnu_false);
7615:       }
7616:       break;
```

## gcc/ada/gcc-interface/trans.cc:7756–7821
```text
7756:     case N_Assignment_Statement:
7757:       /* First get the LHS of the statement and convert any reference to an
7758: 	 unconstrained array into a reference to the underlying array.  */
7759:       gnu_lhs = maybe_unconstrained_array (gnat_to_gnu (Name (gnat_node)));
7760:
7761:       /* If the type has a size that overflows, convert this into raise of
7762: 	 Storage_Error: execution shouldn't have gotten here anyway.  */
7763:       if (TREE_CODE (TYPE_SIZE_UNIT (TREE_TYPE (gnu_lhs))) == INTEGER_CST
7764: 	   && !valid_constant_size_p (TYPE_SIZE_UNIT (TREE_TYPE (gnu_lhs))))
7765: 	gnu_result = build_call_raise (SE_Object_Too_Large, gnat_node,
7766: 				       N_Raise_Storage_Error);
7767:
7768:       /* If the RHS is a function call, let Call_to_gnu do the entire work.  */
7769:       else if (Nkind (Expression (gnat_node)) == N_Function_Call)
7770: 	{
7771: 	  get_atomic_access (Name (gnat_node), &aa_type, &aa_sync);
7772: 	  get_storage_model_access (Name (gnat_node), &gnat_smo);
7773: 	  gnu_result
7774: 	    = Call_to_gnu (Expression (gnat_node), &gnu_result_type, gnu_lhs,
7775: 			   aa_type, aa_sync, gnat_smo);
7776: 	}
7777:
7778:       /* Otherwise we need to build the assignment statement manually.  */
7779:       else
7780: 	{
7781: 	  const Node_Id gnat_name = Name (gnat_node);
7782: 	  const Node_Id gnat_expr = Expression (gnat_node);
7783: 	  const Node_Id gnat_inner
7784: 	    = Nkind (gnat_expr) == N_Qualified_Expression
7785: 	      ? Expression (gnat_expr)
7786: 	      : gnat_expr;
7787: 	  const Entity_Id gnat_type = Underlying_Type (Etype (gnat_name));
7788: 	  const bool use_memset_p
7789: 	    = Is_Array_Type (gnat_type)
7790: 	      && Nkind (gnat_inner) == N_Aggregate
7791: 	      && Is_Single_Aggregate (gnat_inner);
7792:
7793: 	  /* If we use memset, we need to find the innermost expression.  */
7794: 	  if (use_memset_p)
7795: 	    {
7796: 	      gnat_temp = gnat_inner;
7797: 	      do {
7798: 		gnat_temp
7799: 		  = Expression (First (Component_Associations (gnat_temp)));
7800: 	      } while (Nkind (gnat_temp) == N_Aggregate
7801: 		       && Is_Single_Aggregate (gnat_temp));
7802: 	      gnu_rhs = gnat_to_gnu (gnat_temp);
7803: 	    }
7804:
7805: 	  /* Otherwise get the RHS of the statement and do the same processing
7806: 	     as for the LHS above.  */
7807: 	  else
7808: 	    gnu_rhs = maybe_unconstrained_array (gnat_to_gnu (gnat_expr));
7809:
7810: 	  gigi_checking_assert (!Do_Range_Check (gnat_expr));
7811:
7812: 	  get_atomic_access (gnat_name, &aa_type, &aa_sync);
7813: 	  get_storage_model_access (gnat_name, &gnat_smo);
7814:
7815: 	  /* If an outer atomic access is required on the LHS, build the load-
7816: 	     modify-store sequence.  */
7817: 	  if (aa_type == OUTER_ATOMIC)
7818: 	    gnu_result = build_load_modify_store (gnu_lhs, gnu_rhs, gnat_node);
7819:
7820: 	  /* Or else, if a simple atomic access is required, build the atomic
7821: 	     store.  */
```

## gcc/ada/gcc-interface/trans.cc:7944–7974
```text
7944:     case N_If_Statement:
7945:       {
7946: 	tree *gnu_else_ptr; /* Point to put next "else if" or "else".  */
7947:
7948: 	/* Make the outer COND_EXPR.  Avoid non-determinism.  */
7949: 	gnu_result = build3 (COND_EXPR, void_type_node,
7950: 			     gnat_to_gnu (Condition (gnat_node)),
7951: 			     NULL_TREE, NULL_TREE);
7952: 	COND_EXPR_THEN (gnu_result)
7953: 	  = build_stmt_group (Then_Statements (gnat_node), false);
7954: 	TREE_SIDE_EFFECTS (gnu_result) = 1;
7955: 	gnu_else_ptr = &COND_EXPR_ELSE (gnu_result);
7956:
7957: 	/* Now make a COND_EXPR for each of the "else if" parts.  Put each
7958: 	   into the previous "else" part and point to where to put any
7959: 	   outer "else".  Also avoid non-determinism.  */
7960: 	if (Present (Elsif_Parts (gnat_node)))
7961: 	  for (gnat_temp = First (Elsif_Parts (gnat_node));
7962: 	       Present (gnat_temp); gnat_temp = Next (gnat_temp))
7963: 	    {
7964: 	      gnu_expr = build3 (COND_EXPR, void_type_node,
7965: 				 gnat_to_gnu (Condition (gnat_temp)),
7966: 				 NULL_TREE, NULL_TREE);
7967: 	      COND_EXPR_THEN (gnu_expr)
7968: 		= build_stmt_group (Then_Statements (gnat_temp), false);
7969: 	      TREE_SIDE_EFFECTS (gnu_expr) = 1;
7970: 	      set_expr_location_from_node (gnu_expr, gnat_temp);
7971: 	      *gnu_else_ptr = gnu_expr;
7972: 	      gnu_else_ptr = &COND_EXPR_ELSE (gnu_expr);
7973: 	    }
7974:
```

## gcc/ada/gcc-interface/trans.cc:8603–8622
```text
8603:     case N_Expression_With_Actions:
8604:       /* This construct doesn't define a scope so we don't push a binding
8605: 	 level around the statement list, but we wrap it in a SAVE_EXPR to
8606: 	 protect it from unsharing.  Elaborate the expression as part of the
8607: 	 same statement group as the actions so that the type declaration
8608: 	 gets inserted there as well.  This ensures that the type elaboration
8609: 	 code is issued past the actions computing values on which it might
8610: 	 depend.  */
8611:       start_stmt_group ();
8612:       add_stmt_list (Actions (gnat_node));
8613:       gnu_expr = gnat_to_gnu (Expression (gnat_node));
8614:       gnu_result = end_stmt_group ();
8615:
8616:       gnu_result = build1 (SAVE_EXPR, void_type_node, gnu_result);
8617:       TREE_SIDE_EFFECTS (gnu_result) = 1;
8618:
8619:       gnu_result
8620: 	= build_compound_expr (TREE_TYPE (gnu_expr), gnu_result, gnu_expr);
8621:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
8622:       break;
```

## gcc/ada/gcc-interface/trans.cc:8968–8996
```text
8968: gnat_to_gnu_external (Node_Id gnat_node)
8969: {
8970:   const int save_force_global = force_global;
8971:   bool went_into_elab_proc;
8972:
8973:   /* Force the local context and create a fake scope that we zap
8974:      at the end so declarations will not be stuck either in the
8975:      global varpool or in the current scope.  */
8976:   if (!current_function_decl)
8977:     {
8978:       current_function_decl = get_elaboration_procedure ();
8979:       went_into_elab_proc = true;
8980:     }
8981:   else
8982:     went_into_elab_proc = false;
8983:   force_global = 0;
8984:   gnat_pushlevel ();
8985:
8986:   tree gnu_result = gnat_to_gnu (gnat_node);
8987:
8988:   gnat_zaplevel ();
8989:   force_global = save_force_global;
8990:   if (went_into_elab_proc)
8991:     current_function_decl = NULL_TREE;
8992:
8993:   /* Do not import locations from external units.  */
8994:   if (CAN_HAVE_LOCATION_P (gnu_result))
8995:     SET_EXPR_LOCATION (gnu_result, UNKNOWN_LOCATION);
8996:
```

## gcc/ada/gcc-interface/trans.cc:9298–9305
```text
9298: add_stmt_list (List_Id gnat_list)
9299: {
9300:   Node_Id gnat_node;
9301:
9302:   if (Present (gnat_list))
9303:     for (gnat_node = First (gnat_list); Present (gnat_node);
9304: 	 gnat_node = Next (gnat_node))
9305:       add_stmt (gnat_to_gnu (gnat_node));
```

## gcc/ada/gcc-interface/trans.cc:3301–3306
```text
3301:   /* Make the loop body into its own block, so any allocated storage will be
3302:      released every iteration.  This is needed for stack allocation.  */
3303:   LOOP_STMT_BODY (gnu_loop_stmt)
3304:     = build_stmt_group (Statements (gnat_node), true);
3305:   TREE_SIDE_EFFECTS (gnu_loop_stmt) = 1;
3306:
```

## gcc/ada/gcc-interface/trans.cc:9889–10025
```text
9889: process_decls (List_Id gnat_decls, List_Id gnat_decls2,
9890: 	       bool pass1p, bool pass2p)
9891: {
9892:   List_Id gnat_decl_array[2];
9893:   Node_Id gnat_decl;
9894:   int i;
9895:
9896:   gnat_decl_array[0] = gnat_decls, gnat_decl_array[1] = gnat_decls2;
9897:
9898:   if (pass1p)
9899:     for (i = 0; i <= 1; i++)
9900:       if (Present (gnat_decl_array[i]))
9901: 	for (gnat_decl = First (gnat_decl_array[i]);
9902: 	     Present (gnat_decl);
9903: 	     gnat_decl = Next (gnat_decl))
9904: 	  {
9905: 	    /* For package specs, we recurse inside the declarations,
9906: 	       thus taking the two pass approach inside the boundary.  */
9907: 	    if (Nkind (gnat_decl) == N_Package_Declaration)
9908: 	      process_decls (Visible_Declarations (Specification (gnat_decl)),
9909: 			     Private_Declarations (Specification (gnat_decl)),
9910: 			     true, false);
9911:
9912: 	    /* Similarly for any declarations in the actions of a
9913: 	       freeze node.  */
9914: 	    else if (Nkind (gnat_decl) == N_Freeze_Entity)
9915: 	      {
9916: 		process_freeze_entity (gnat_decl);
9917: 		process_decls (Actions (gnat_decl), Empty, true, false);
9918: 	      }
9919:
9920: 	    /* Package bodies with freeze nodes get their elaboration deferred
9921: 	       until the freeze node, but the code must be placed in the right
9922: 	       place, so record the code position now.  */
9923: 	    else if (Nkind (gnat_decl) == N_Package_Body
9924: 		     && Present (Freeze_Node (Corresponding_Spec (gnat_decl))))
9925: 	      record_code_position (gnat_decl);
9926:
9927: 	    else if (Nkind (gnat_decl) == N_Package_Body_Stub
9928: 		     && Present (Library_Unit (gnat_decl))
9929: 		     && Present (Freeze_Node
9930: 				 (Corresponding_Spec
9931: 				  (Proper_Body (Unit
9932: 						(Library_Unit (gnat_decl)))))))
9933: 	      record_code_position
9934: 		(Proper_Body (Unit (Library_Unit (gnat_decl))));
9935:
9936: 	    /* We defer most subprogram bodies to the second pass.  For bodies
9937: 	       that act as their own specs and stubs, the entity itself must be
9938: 	       elaborated in the first pass, because it may be used in other
9939: 	       declarations.  */
9940: 	    else if (Nkind (gnat_decl) == N_Subprogram_Body)
9941: 	      {
9942: 		if (Acts_As_Spec (gnat_decl))
9943: 		  {
9944: 		    Entity_Id gnat_subprog = Defining_Entity (gnat_decl);
9945:
9946: 		    if (!Is_Generic_Subprogram (gnat_subprog))
9947: 		      gnat_to_gnu_entity (gnat_subprog, NULL_TREE, true);
9948: 		  }
9949: 	      }
9950:
9951: 	    else if (Nkind (gnat_decl) == N_Subprogram_Body_Stub)
9952: 	      {
9953: 		Entity_Id gnat_subprog
9954: 		  = Defining_Entity (Specification (gnat_decl));
9955:
9956: 		if (!Is_Generic_Subprogram (gnat_subprog)
9957: 		    && Ekind (gnat_subprog) != E_Subprogram_Body)
9958: 		  gnat_to_gnu_entity (gnat_subprog, NULL_TREE, true);
9959: 	      }
9960:
9961: 	    /* Concurrent stubs stand for the corresponding subprogram bodies,
9962: 	       which are deferred like other bodies.  */
9963: 	    else if (Nkind (gnat_decl) == N_Task_Body_Stub
9964: 		     || Nkind (gnat_decl) == N_Protected_Body_Stub)
9965: 	      ;
9966:
9967: 	    /* Renamed subprograms may not be elaborated yet at this point
9968: 	       since renamings do not trigger freezing.  Wait for the second
9969: 	       pass to take care of them.  */
9970: 	    else if (Nkind (gnat_decl) == N_Subprogram_Renaming_Declaration)
9971: 	      ;
9972:
9973: 	    else
9974: 	      add_stmt (gnat_to_gnu (gnat_decl));
9975: 	  }
9976:
9977:   /* Here we elaborate everything we deferred above except for package bodies,
9978:      which are elaborated at their freeze nodes.  Note that we must also
9979:      go inside things (package specs and freeze nodes) the first pass did.  */
9980:   if (pass2p)
9981:     for (i = 0; i <= 1; i++)
9982:       if (Present (gnat_decl_array[i]))
9983: 	for (gnat_decl = First (gnat_decl_array[i]);
9984: 	     Present (gnat_decl);
9985: 	     gnat_decl = Next (gnat_decl))
9986: 	  {
9987: 	    if (Nkind (gnat_decl) == N_Subprogram_Body
9988: 		|| Nkind (gnat_decl) == N_Subprogram_Body_Stub
9989: 		|| Nkind (gnat_decl) == N_Task_Body_Stub
9990: 		|| Nkind (gnat_decl) == N_Protected_Body_Stub)
9991: 	      add_stmt (gnat_to_gnu (gnat_decl));
9992:
9993: 	    else if (Nkind (gnat_decl) == N_Package_Declaration)
9994: 	      process_decls (Visible_Declarations (Specification (gnat_decl)),
9995: 			     Private_Declarations (Specification (gnat_decl)),
9996: 			     false, true);
9997:
9998: 	    else if (Nkind (gnat_decl) == N_Freeze_Entity)
9999: 	      process_decls (Actions (gnat_decl), Empty, false, true);
10000:
10001: 	    else if (Nkind (gnat_decl) == N_Subprogram_Renaming_Declaration)
10002: 	      add_stmt (gnat_to_gnu (gnat_decl));
10003: 	  }
10004: }
10005:
10006: /* Make a unary operation of kind CODE using build_unary_op, but guard
10007:    the operation by an overflow check.  CODE can be one of NEGATE_EXPR
10008:    or ABS_EXPR.  GNU_TYPE is the type desired for the result.  Usually
10009:    the operation is to be performed in that type.  GNAT_NODE is the gnat
10010:    node conveying the source location for which the error should be
10011:    signaled.  */
10012:
10013: static tree
10014: build_unary_op_trapv (enum tree_code code, tree gnu_type, tree operand,
10015: 		      Node_Id gnat_node)
10016: {
10017:   gcc_assert (code == NEGATE_EXPR || code == ABS_EXPR);
10018:
10019:   tree gnu_expr, check;
10020:
10021:   operand = gnat_protect_expr (operand);
10022:
10023:   gnu_expr = build_unary_op (code, gnu_type, operand);
10024:
10025:   if (TYPE_UNSIGNED (gnu_type))
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

## gcc/varasm.cc:4001–4038
```text
4001:   rtx sym;
4002:   rtx constant;
4003:   HOST_WIDE_INT offset;
4004:   hashval_t hash;
4005:   fixed_size_mode mode;
4006:   unsigned int align;
4007:   int labelno;
4008:   int mark;
4009: };
4010:
4011: struct const_rtx_desc_hasher : ggc_ptr_hash<constant_descriptor_rtx>
4012: {
4013:   static hashval_t hash (constant_descriptor_rtx *);
4014:   static bool equal (constant_descriptor_rtx *, constant_descriptor_rtx *);
4015: };
4016:
4017: /* Used in the hash tables to avoid outputting the same constant
4018:    twice.  Unlike 'struct constant_descriptor_tree', RTX constants
4019:    are output once per function, not once per file.  */
4020: /* ??? Only a few targets need per-function constant pools.  Most
4021:    can use one per-file pool.  Should add a targetm bit to tell the
4022:    difference.  */
4023:
4024: struct GTY(()) rtx_constant_pool {
4025:   /* Pointers to first and last constant in pool, as ordered by offset.  */
4026:   class constant_descriptor_rtx *first;
4027:   class constant_descriptor_rtx *last;
4028:
4029:   /* Hash facility for making memory-constants from constant rtl-expressions.
4030:      It is used on RISC machines where immediate integer arguments and
4031:      constant addresses are restricted so that such constants must be stored
4032:      in memory.  */
4033:   hash_table<const_rtx_desc_hasher> *const_rtx_htab;
4034:
4035:   /* Current offset in constant pool (does not include any
4036:      machine-specific header).  */
4037:   HOST_WIDE_INT offset;
4038: };
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

## gcc/varasm.cc:4184–4253
```text
4184: rtx
4185: force_const_mem (machine_mode in_mode, rtx x)
4186: {
4187:   class constant_descriptor_rtx *desc, tmp;
4188:   struct rtx_constant_pool *pool;
4189:   char label[256];
4190:   rtx def, symbol;
4191:   hashval_t hash;
4192:   unsigned int align;
4193:   constant_descriptor_rtx **slot;
4194:   fixed_size_mode mode;
4195:
4196:   /* We can't force variable-sized objects to memory.  */
4197:   if (!is_a <fixed_size_mode> (in_mode, &mode))
4198:     return NULL_RTX;
4199:
4200:   /* If we're not allowed to drop X into the constant pool, don't.  */
4201:   if (targetm.cannot_force_const_mem (mode, x))
4202:     return NULL_RTX;
4203:
4204:   /* Record that this function has used a constant pool entry.  */
4205:   crtl->uses_const_pool = 1;
4206:
4207:   /* Decide which pool to use.  */
4208:   pool = (targetm.use_blocks_for_constant_p (mode, x)
4209: 	  ? shared_constant_pool
4210: 	  : crtl->varasm.pool);
4211:
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

## gcc/common.opt:2080–2094
```text
2080: -finline-limit=<number>	Limit the size of inlined functions to <number>.
2081:
2082: finline-atomics
2083: Common Var(flag_inline_atomics) Init(1) Optimization
2084: Inline __atomic operations when a lock free instruction sequence is available.
2085:
2086: finline-stringops
2087: Common RejectNegative Enum(ilsop_fn) Var(flag_inline_stringops, ILSOP_ALL) Enum(ilsop_fn) Init(ILSOP_NONE) Optimization Undocumented
2088:
2089: fno-inline-stringops
2090: Common RejectNegative Enum(ilsop_fn) Var(flag_inline_stringops, ILSOP_NONE) Enum(ilsop_fn) Optimization Undocumented
2091:
2092: finline-stringops=
2093: Common Joined Var(flag_inline_stringops) EnumSet Enum(ilsop_fn) Optimization
2094: -finline-stringops[=memcmp|memcpy|memmove|memset]
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

## gcc/ggc-page.cc:1250–1290
```text
1250: #define NUM_SIZE_LOOKUP 512
1251: static unsigned char size_lookup[NUM_SIZE_LOOKUP] =
1252: {
1253:   3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4,
1254:   4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
1255:   5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
1256:   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
1257:   6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
1258:   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
1259:   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
1260:   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
1261:   7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1262:   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1263:   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1264:   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1265:   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1266:   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1267:   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1268:   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
1269:   8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1270:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1271:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1272:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1273:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1274:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1275:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1276:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1277:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1278:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1279:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1280:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1281:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1282:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1283:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
1284:   9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
1285: };
1286:
1287: /* For a given size of memory requested for allocation, return the
1288:    actual size that is going to be allocated, as well as the size
1289:    order.  */
1290:
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

## gcc/ggc-page.cc:1883–1922
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
1906:   /* Reset the size_lookup array to put appropriately sized objects in
1907:      the special orders.  All objects bigger than the previous power
1908:      of two, but no greater than the special size, should go in the
1909:      new order.  */
1910:   for (order = HOST_BITS_PER_PTR; order < NUM_ORDERS; ++order)
1911:     {
1912:       int o;
1913:       int i;
1914:
1915:       i = OBJECT_SIZE (order);
1916:       if (i >= NUM_SIZE_LOOKUP)
1917: 	continue;
1918:
1919:       for (o = size_lookup[i]; o == size_lookup [i]; --i)
1920: 	size_lookup[i] = order;
1921:     }
1922:
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

## gcc/ada/gcc-interface/utils.cc:770–783
```text
770: gnat_zaplevel (void)
771: {
772:   struct gnat_binding_level *level = current_binding_level;
773:   tree block = level->block;
774:
775:   BLOCK_CHAIN (block) = free_block_chain;
776:   free_block_chain = block;
777:
778:   /* Free this binding structure.  */
779:   current_binding_level = level->chain;
780:   level->chain = free_binding_level;
781:   free_binding_level = level;
782: }
783:
```

## gcc/function.h:34–70
```text
34: };
35:
36: struct GTY(()) emit_status {
37:   void ensure_regno_capacity ();
38:
39:   /* This is reset to LAST_VIRTUAL_REGISTER + 1 at the start of each function.
40:      After rtl generation, it is 1 plus the largest register number used.  */
41:   int x_reg_rtx_no;
42:
43:   /* Lowest label number in current function.  */
44:   int x_first_label_num;
45:
46:   /* seq.first and seq.last are the ends of the doubly-linked chain of
47:      rtl for the current function.  Both are reset to null at the
48:      start of rtl generation for the function.
49:
50:      start_sequence saves both of these on seq.next and then starts
51:      a new, nested sequence of insns.
52:
53:      seq.next is a stack of pending (incomplete) sequences saved by
54:      start_sequence.  Each element describes one pending sequence.
55:      The main insn-chain is the last element of the chain.  */
56:   struct sequence_stack seq;
57:
58:   /* INSN_UID for next insn emitted.
59:      Reset to 1 for each function compiled.  */
60:   int x_cur_insn_uid;
61:
62:   /* INSN_UID for next debug insn emitted.  Only used if
63:      --param min-nondebug-insn-uid=<value> is given with nonzero value.  */
64:   int x_cur_debug_insn_uid;
65:
66:   /* The length of the regno_pointer_align, regno_decl, and x_regno_reg_rtx
67:      vectors.  Since these vectors are needed during the expansion phase when
68:      the total number of registers in the function is not yet known, the
69:      vectors are copied and made bigger when necessary.  */
70:   int regno_pointer_align_length;
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

## gcc/genmodes.cc:828–845
```text
828: static int bits_per_unit;
829: static int max_bitsize_mode_any_int;
830: static int max_bitsize_mode_any_mode;
831:
832: static void
833: create_modes (void)
834: {
835: #include "machmode.def"
836:
837:   /* So put the default value unless the target needs a non standard
838:      value. */
839: #ifdef BITS_PER_UNIT
840:   bits_per_unit = BITS_PER_UNIT;
841: #else
842:   bits_per_unit = 8;
843: #endif
844:
845: #ifdef MAX_BITSIZE_MODE_ANY_INT
```

## gcc/genmodes.cc:1012–1023
```text
1012: static void
1013: emit_max_int (void)
1014: {
1015:   unsigned int max, mmax;
1016:   struct mode_data *i;
1017:   int j;
1018:
1019:   puts ("");
1020:
1021:   printf ("#define BITS_PER_UNIT (%d)\n", bits_per_unit);
1022:
1023:   if (max_bitsize_mode_any_int == 0)
```

## gcc/ada/gcc-interface/decl.cc:400–445
```text
400:       gcc_unreachable ();
401:     }
402:
403:   /* If we've already processed this entity, return what we got last time.
404:      If we are defining the node, we should not have already processed it.
405:      In that case, we will abort below when we try to save a new GCC tree
406:      for this object.  We also need to handle the case of getting a dummy
407:      type when a Full_View exists but be careful so as not to trigger its
408:      premature elaboration.  Likewise for a cloned subtype without its own
409:      freeze node, which typically happens when a generic gets instantiated
410:      on an incomplete or private type.  */
411:   if ((!definition || (is_type && imported_p))
412:       && present_gnu_tree (gnat_entity))
413:     {
414:       gnu_decl = get_gnu_tree (gnat_entity);
415:
416:       if (TREE_CODE (gnu_decl) == TYPE_DECL
417: 	  && TYPE_IS_DUMMY_P (TREE_TYPE (gnu_decl))
418: 	  && IN (kind, Incomplete_Or_Private_Kind)
419: 	  && Present (Full_View (gnat_entity))
420: 	  && (present_gnu_tree (Full_View (gnat_entity))
421: 	      || No (Freeze_Node (Full_View (gnat_entity)))))
422: 	{
423: 	  gnu_decl
424: 	    = gnat_to_gnu_entity (Full_View (gnat_entity), NULL_TREE,
425: 				  false);
426: 	  save_gnu_tree (gnat_entity, NULL_TREE, false);
427: 	  save_gnu_tree (gnat_entity, gnu_decl, false);
428: 	}
429:
430:       if (TREE_CODE (gnu_decl) == TYPE_DECL
431: 	  && TYPE_IS_DUMMY_P (TREE_TYPE (gnu_decl))
432: 	  && Ekind (gnat_entity) == E_Record_Subtype
433: 	  && No (Freeze_Node (gnat_entity))
434: 	  && Present (Cloned_Subtype (gnat_entity))
435: 	  && (present_gnu_tree (Cloned_Subtype (gnat_entity))
436: 	      || No (Freeze_Node (Cloned_Subtype (gnat_entity)))))
437: 	{
438: 	  gnu_decl
439: 	    = gnat_to_gnu_entity (Cloned_Subtype (gnat_entity), NULL_TREE,
440: 				  false);
441: 	  save_gnu_tree (gnat_entity, NULL_TREE, false);
442: 	  save_gnu_tree (gnat_entity, gnu_decl, false);
443: 	}
444:
445:       return gnu_decl;
```

## gcc/ada/gcc-interface/decl.cc:697–718
```text
697:
698:       /* If we have a constant that we are not defining, get the expression it
699: 	 was defined to represent.  This is necessary to avoid generating dumb
700: 	 elaboration code in simple cases, and we may throw it away later if it
701: 	 is not a constant.  But do not do it for dispatch tables because they
702: 	 are only referenced indirectly and we need to have a consistent view
703: 	 of the exported and of the imported declarations of the tables from
704: 	 external units for them to be properly merged in LTO mode.  Moreover
705: 	 simply do not retrieve the expression if it is an allocator because
706: 	 the designated type might still be dummy at this point.  Note that we
707: 	 invoke gnat_to_gnu_external and not gnat_to_gnu because the expression
708: 	 may contain N_Expression_With_Actions nodes and thus declarations of
709: 	 objects from other units that we need to discard.  Note also that we
710: 	 need to do it even if we are only annotating types, so as to be able
711: 	 to validate representation clauses using constants.  */
712:       if (!definition
713: 	  && !No_Initialization (gnat_decl)
714: 	  && !Is_Dispatch_Table_Entity (gnat_entity)
715: 	  && Present (gnat_temp = Expression (gnat_decl))
716: 	  && Nkind (gnat_temp) != N_Allocator
717: 	  && (Is_Elementary_Type (Etype (gnat_entity)) || !type_annotate_only))
718: 	gnu_expr = gnat_to_gnu_external (gnat_temp);
```

## gcc/ada/gcc-interface/decl.cc:754–766
```text
754: 	   referencing the renaming.  But it may contain a call for which
755: 	   we'll generate a temporary to hold the return value and which
756: 	   is part of the definition of the renaming, so discard it.  */
757: 	if (Present (gnat_renamed_obj) && !definition)
758: 	  {
759: 	    if (kind == E_Exception)
760: 	      gnu_expr = gnat_to_gnu_entity (Renamed_Entity (gnat_entity),
761: 					     NULL_TREE, false);
762: 	    else
763: 	      gnu_expr = gnat_to_gnu_external (gnat_renamed_obj);
764: 	  }
765:
766: 	/* Get the type after elaborating the renamed object.  */
```

## gcc/ada/gcc-interface/decl.cc:1278–1291
```text
1278: 	   either get the address expression from the saved GCC tree for the
1279: 	   object if it has a Freeze node, or elaborate the address expression
1280: 	   here since the front-end has guaranteed that the elaboration has no
1281: 	   effects in this case.  */
1282: 	if (definition && Present (Address_Clause (gnat_entity)))
1283: 	  {
1284: 	    const Node_Id gnat_clause = Address_Clause (gnat_entity);
1285: 	    const Node_Id gnat_address = Expression (gnat_clause);
1286: 	    tree gnu_address = present_gnu_tree (gnat_entity)
1287: 			       ? TREE_OPERAND (get_gnu_tree (gnat_entity), 0)
1288: 			       : gnat_to_gnu (gnat_address);
1289:
1290: 	    save_gnu_tree (gnat_entity, NULL_TREE, false);
1291:
```

## gcc/ada/gcc-interface/decl.cc:3142–3177
```text
3142:     case E_String_Literal_Subtype:
3143:       /* Create the type for a string literal.  */
3144:       {
3145: 	Entity_Id gnat_full_type
3146: 	  = (Is_Private_Type (Etype (gnat_entity))
3147: 	     && Present (Full_View (Etype (gnat_entity)))
3148: 	     ? Full_View (Etype (gnat_entity)) : Etype (gnat_entity));
3149: 	tree gnu_string_type = get_unpadded_type (gnat_full_type);
3150: 	tree gnu_string_array_type
3151: 	  = TREE_TYPE (TREE_TYPE (TYPE_FIELDS (TREE_TYPE (gnu_string_type))));
3152: 	tree gnu_string_index_type
3153: 	  = get_base_type (TREE_TYPE (TYPE_INDEX_TYPE
3154: 				      (TYPE_DOMAIN (gnu_string_array_type))));
3155:
3156:         /* For a null string literal we set the bounds to 1 .. 0, to
3157:            avoid a possible overflow when calculating the upper bound
3158:            as LOWER_BOUND + LENGTH - 1.  */
3159:         const bool is_null_string
3160:           = String_Literal_Length (gnat_entity) == Uint_0;
3161: 	tree gnu_lower_bound
3162: 	  = is_null_string ?
3163: 	    build_int_cst (gnu_string_index_type, 1) :
3164: 	    convert (gnu_string_index_type,
3165: 		     gnat_to_gnu (String_Literal_Low_Bound (gnat_entity)));
3166: 	tree gnu_length
3167: 	  = UI_To_gnu (String_Literal_Length (gnat_entity),
3168: 		       gnu_string_index_type);
3169: 	tree gnu_upper_bound
3170: 	  = is_null_string ?
3171: 	    build_int_cst (gnu_string_index_type, 0) :
3172: 	    build_binary_op (PLUS_EXPR, gnu_string_index_type,
3173: 			     gnu_lower_bound,
3174: 			     int_const_binop (MINUS_EXPR, gnu_length,
3175: 					      convert (gnu_string_index_type,
3176: 						       integer_one_node)));
3177: 	tree gnu_index_type
```

## gcc/vec.h:220–260
```text
220: {
221:   /* FIXME - These fields should be private, but we need to cater to
222: 	     compilers that have stricter notions of PODness for types.  */
223:
224:   /* Memory allocation support routines in vec.cc.  */
225:   void register_overhead (void *, size_t, size_t CXX_MEM_STAT_INFO);
226:   void release_overhead (void *, size_t, size_t, bool CXX_MEM_STAT_INFO);
227:   static unsigned calculate_allocation (vec_prefix *, unsigned, bool);
228:   static unsigned calculate_allocation_1 (unsigned, unsigned);
229:
230:   /* Note that vec_prefix should be a base class for vec, but we use
231:      offsetof() on vector fields of tree structures (e.g.,
232:      tree_binfo::base_binfos), and offsetof only supports base types.
233:
234:      To compensate, we make vec_prefix a field inside vec and make
235:      vec a friend class of vec_prefix so it can access its fields.  */
236:   template <typename, typename, typename> friend struct vec;
237:
238:   /* The allocator types also need access to our internals.  */
239:   friend struct va_gc;
240:   friend struct va_gc_atomic;
241:   friend struct va_heap;
242:
243:   unsigned m_alloc : 31;
244:   unsigned m_using_auto_storage : 1;
245:   unsigned m_num;
246: };
247:
248: /* Calculate the number of slots to reserve a vector, making sure that
249:    RESERVE slots are free.  If EXACT grow exactly, otherwise grow
250:    exponentially.  PFX is the control data for the vector.  */
251:
252: inline unsigned
253: vec_prefix::calculate_allocation (vec_prefix *pfx, unsigned reserve,
254: 				  bool exact)
255: {
256:   if (exact)
257:     return (pfx ? pfx->m_num : 0) + reserve;
258:   else if (!pfx)
259:     return MAX (4, reserve);
260:   return calculate_allocation_1 (pfx->m_alloc, pfx->m_num + reserve);
```

## gcc/vec.h:302–325
```text
302: template<typename T>
303: inline void
304: va_heap::reserve (vec<T, va_heap, vl_embed> *&v, unsigned reserve, bool exact
305: 		  MEM_STAT_DECL)
306: {
307:   size_t elt_size = sizeof (T);
308:   unsigned alloc
309:     = vec_prefix::calculate_allocation (v ? &v->m_vecpfx : 0, reserve, exact);
310:   gcc_checking_assert (alloc);
311:
312:   if (GATHER_STATISTICS && v)
313:     v->m_vecpfx.release_overhead (v, elt_size * v->allocated (),
314: 				  v->allocated (), false);
315:
316:   size_t size = vec<T, va_heap, vl_embed>::embedded_size (alloc);
317:   unsigned nelem = v ? v->length () : 0;
318:   v = static_cast <vec<T, va_heap, vl_embed> *> (xrealloc (v, size));
319:   v->embedded_init (alloc, nelem);
320:
321:   if (GATHER_STATISTICS)
322:     v->m_vecpfx.register_overhead (v, alloc, elt_size PASS_MEM_STAT);
323: }
324:
325:
```

## gcc/vec.h:393–425
```text
393: void
394: va_gc::reserve (vec<T, A, vl_embed> *&v, unsigned reserve, bool exact
395: 		MEM_STAT_DECL)
396: {
397:   unsigned alloc
398:     = vec_prefix::calculate_allocation (v ? &v->m_vecpfx : 0, reserve, exact);
399:   if (!alloc)
400:     {
401:       ::ggc_free (v);
402:       v = NULL;
403:       return;
404:     }
405:
406:   /* Calculate the amount of space we want.  */
407:   size_t size = vec<T, A, vl_embed>::embedded_size (alloc);
408:
409:   /* Ask the allocator how much space it will really give us.  */
410:   size = ::ggc_round_alloc_size (size);
411:
412:   /* Adjust the number of slots accordingly.  */
413:   size_t vec_offset = sizeof (vec_prefix);
414:   size_t elt_size = sizeof (T);
415:   alloc = (size - vec_offset) / elt_size;
416:
417:   /* And finally, recalculate the amount of space we ask for.  */
418:   size = vec_offset + alloc * elt_size;
419:
420:   unsigned nelem = v ? v->length () : 0;
421:   v = static_cast <vec<T, A, vl_embed> *> (::ggc_realloc (v, size
422: 							       PASS_MEM_STAT));
423:   v->embedded_init (alloc, nelem);
424: }
425:
```

## gcc/vec.h:599–660
```text
599: struct GTY((user)) vec<T, A, vl_embed>
600: {
601: public:
602:   unsigned allocated (void) const { return m_vecpfx.m_alloc; }
603:   unsigned length (void) const { return m_vecpfx.m_num; }
604:   bool is_empty (void) const { return m_vecpfx.m_num == 0; }
605:   T *address (void) { return reinterpret_cast <T *> (this + 1); }
606:   const T *address (void) const
607:     { return reinterpret_cast <const T *> (this + 1); }
608:   T *begin () { return address (); }
609:   const T *begin () const { return address (); }
610:   T *end () { return address () + length (); }
611:   const T *end () const { return address () + length (); }
612:   const T &operator[] (unsigned) const;
613:   T &operator[] (unsigned);
614:   const T &last (void) const;
615:   T &last (void);
616:   bool space (unsigned) const;
617:   bool iterate (unsigned, T *) const;
618:   bool iterate (unsigned, T **) const;
619:   vec *copy (ALONE_CXX_MEM_STAT_INFO) const;
620:   void splice (const vec &);
621:   void splice (const vec *src);
622:   T *quick_push (const T &);
623:   using pop_ret_type
624:     = typename std::conditional <std::is_trivially_destructible <T>::value,
625: 				 T &, void>::type;
626:   pop_ret_type pop (void);
627:   void truncate (unsigned);
628:   void quick_insert (unsigned, const T &);
629:   void ordered_remove (unsigned);
630:   void unordered_remove (unsigned);
631:   void block_remove (unsigned, unsigned);
632:   void qsort (int (*) (const void *, const void *));
633:   void sort (int (*) (const void *, const void *, void *), void *);
634:   void stablesort (int (*) (const void *, const void *, void *), void *);
635:   T *bsearch (const void *key, int (*compar) (const void *, const void *));
636:   T *bsearch (const void *key,
637: 	      int (*compar)(const void *, const void *, void *), void *);
638:   unsigned lower_bound (const T &, bool (*) (const T &, const T &)) const;
639:   bool contains (const T &search) const;
640:   static size_t embedded_size (unsigned);
641:   void embedded_init (unsigned, unsigned = 0, unsigned = 0);
642:   void quick_grow (unsigned len);
643:   void quick_grow_cleared (unsigned len);
644:
645:   /* vec class can access our internal data and functions.  */
646:   template <typename, typename, typename> friend struct vec;
647:
648:   /* The allocator types also need access to our internals.  */
649:   friend struct va_gc;
650:   friend struct va_gc_atomic;
651:   friend struct va_heap;
652:
653:   /* FIXME - This field should be private, but we need to cater to
654: 	     compilers that have stricter notions of PODness for types.  */
655:   /* Align m_vecpfx to simplify address ().  */
656:   alignas (T) alignas (vec_prefix) vec_prefix m_vecpfx;
657: };
658:
659:
660: /* Convenience wrapper functions to use when dealing with pointers to
```

## gcc/vec.h:1394–1415
```text
1394: vec<T, A, vl_embed>::embedded_size (unsigned alloc)
1395: {
1396:   struct alignas (T) U { char data[sizeof (T)]; };
1397:   typedef vec<U, A, vl_embed> vec_embedded;
1398:   typedef typename std::conditional<std::is_standard_layout<T>::value,
1399: 				    vec, vec_embedded>::type vec_stdlayout;
1400:   static_assert (sizeof (vec_stdlayout) == sizeof (vec), "");
1401:   static_assert (alignof (vec_stdlayout) == alignof (vec), "");
1402:   return sizeof (vec_stdlayout) + alloc * sizeof (T);
1403: }
1404:
1405:
1406: /* Initialize the vector to contain room for ALLOC elements and
1407:    NUM active elements.  */
1408:
1409: template<typename T, typename A>
1410: inline void
1411: vec<T, A, vl_embed>::embedded_init (unsigned alloc, unsigned num, unsigned aut)
1412: {
1413:   m_vecpfx.m_alloc = alloc;
1414:   m_vecpfx.m_using_auto_storage = aut;
1415:   m_vecpfx.m_num = num;
```

## gcc/vec.cc:150–169
```text
150: vec_prefix::calculate_allocation_1 (unsigned alloc, unsigned desired)
151: {
152:   /* We must have run out of room.  */
153:   gcc_assert (alloc < desired);
154:
155:   /* Exponential growth. */
156:   if (!alloc)
157:     alloc = 4;
158:   else if (alloc < 16)
159:     /* Double when small.  */
160:     alloc = alloc * 2;
161:   else
162:     /* Grow slower when large.  */
163:     alloc = (alloc * 3 / 2);
164:
165:   /* If this is still too small, set it to the right size. */
166:   if (alloc < desired)
167:     alloc = desired;
168:   return alloc;
169: }
```

## gcc/emit-rtl.cc:80–85
```text
80: scalar_int_mode ptr_mode;	/* Mode whose width is POINTER_SIZE.  */
81:
82: /* Datastructures maintained for currently processed function in RTL form.  */
83:
84: struct rtl_data x_rtl;
85:
```

## gcc/emit-rtl.cc:1184–1232
```text
1184: /* Generate a REG rtx for a new pseudo register of mode MODE.
1185:    This pseudo is assigned the next sequential register number.  */
1186:
1187: rtx
1188: gen_reg_rtx (machine_mode mode)
1189: {
1190:   rtx val;
1191:   unsigned int align = GET_MODE_ALIGNMENT (mode);
1192:
1193:   gcc_assert (can_create_pseudo_p ());
1194:
1195:   /* If a virtual register with bigger mode alignment is generated,
1196:      increase stack alignment estimation because it might be spilled
1197:      to stack later.  */
1198:   if (SUPPORTS_STACK_ALIGNMENT
1199:       && crtl->stack_alignment_estimated < align
1200:       && !crtl->stack_realign_processed)
1201:     {
1202:       unsigned int min_align = MINIMUM_ALIGNMENT (NULL, mode, align);
1203:       if (crtl->stack_alignment_estimated < min_align)
1204: 	crtl->stack_alignment_estimated = min_align;
1205:     }
1206:
1207:   if (generating_concat_p
1208:       && (GET_MODE_CLASS (mode) == MODE_COMPLEX_FLOAT
1209: 	  || GET_MODE_CLASS (mode) == MODE_COMPLEX_INT))
1210:     {
1211:       /* For complex modes, don't make a single pseudo.
1212: 	 Instead, make a CONCAT of two pseudos.
1213: 	 This allows noncontiguous allocation of the real and imaginary parts,
1214: 	 which makes much better code.  Besides, allocating DCmode
1215: 	 pseudos overstrains reload on some machines like the 386.  */
1216:       rtx realpart, imagpart;
1217:       machine_mode partmode = GET_MODE_INNER (mode);
1218:
1219:       realpart = gen_reg_rtx (partmode);
1220:       imagpart = gen_reg_rtx (partmode);
1221:       return gen_rtx_CONCAT (mode, realpart, imagpart);
1222:     }
1223:
1224:   /* Do not call gen_reg_rtx with uninitialized crtl.  */
1225:   gcc_assert (crtl->emit.regno_pointer_align_length);
1226:
1227:   crtl->emit.ensure_regno_capacity ();
1228:   gcc_assert (reg_rtx_no < crtl->emit.regno_pointer_align_length);
1229:
1230:   val = gen_raw_REG (mode, reg_rtx_no);
1231:   regno_reg_rtx[reg_rtx_no++] = val;
1232:   return val;
```

## gcc/emit-rtl.cc:1239–1262
```text
1239: emit_status::ensure_regno_capacity ()
1240: {
1241:   int old_size = regno_pointer_align_length;
1242:
1243:   if (reg_rtx_no < old_size)
1244:     return;
1245:
1246:   int new_size = old_size * 2;
1247:   while (reg_rtx_no >= new_size)
1248:     new_size *= 2;
1249:
1250:   char *tmp = XRESIZEVEC (char, regno_pointer_align, new_size);
1251:   memset (tmp + old_size, 0, new_size - old_size);
1252:   regno_pointer_align = (unsigned char *) tmp;
1253:
1254:   rtx *new1 = GGC_RESIZEVEC (rtx, regno_reg_rtx, new_size);
1255:   memset (new1 + old_size, 0, (new_size - old_size) * sizeof (rtx));
1256:   regno_reg_rtx = new1;
1257:
1258:   crtl->emit.regno_pointer_align_length = new_size;
1259: }
1260:
1261: /* Return TRUE if REG is a PARM_DECL, FALSE otherwise.  */
1262:
```

## gcc/emit-rtl.cc:5980–6005
```text
5980: {
5981:   set_first_insn (NULL);
5982:   set_last_insn (NULL);
5983:   if (param_min_nondebug_insn_uid)
5984:     cur_insn_uid = param_min_nondebug_insn_uid;
5985:   else
5986:     cur_insn_uid = 1;
5987:   cur_debug_insn_uid = 1;
5988:   reg_rtx_no = LAST_VIRTUAL_REGISTER + 1;
5989:   first_label_num = label_num;
5990:   get_current_sequence ()->next = NULL;
5991:
5992:   /* Init the tables that describe all the pseudo regs.  */
5993:
5994:   crtl->emit.regno_pointer_align_length = LAST_VIRTUAL_REGISTER + 101;
5995:
5996:   crtl->emit.regno_pointer_align
5997:     = XCNEWVEC (unsigned char, crtl->emit.regno_pointer_align_length);
5998:
5999:   regno_reg_rtx
6000:     = ggc_cleared_vec_alloc<rtx> (crtl->emit.regno_pointer_align_length);
6001:
6002:   /* Put copies of all the hard registers into regno_reg_rtx.  */
6003:   memcpy (regno_reg_rtx,
6004: 	  initial_regno_reg_rtx,
6005: 	  FIRST_PSEUDO_REGISTER * sizeof (rtx));
```

## gcc/rtl.h:4091–4146
```text
4091: #define FIRST_VIRTUAL_REGISTER	(FIRST_PSEUDO_REGISTER)
4092:
4093: /* This points to the first word of the incoming arguments passed on the stack,
4094:    either by the caller or by the callee when pretending it was passed by the
4095:    caller.  */
4096:
4097: #define virtual_incoming_args_rtx       (global_rtl[GR_VIRTUAL_INCOMING_ARGS])
4098:
4099: #define VIRTUAL_INCOMING_ARGS_REGNUM	(FIRST_VIRTUAL_REGISTER)
4100:
4101: /* If FRAME_GROWS_DOWNWARD, this points to immediately above the first
4102:    variable on the stack.  Otherwise, it points to the first variable on
4103:    the stack.  */
4104:
4105: #define virtual_stack_vars_rtx	        (global_rtl[GR_VIRTUAL_STACK_ARGS])
4106:
4107: #define VIRTUAL_STACK_VARS_REGNUM	((FIRST_VIRTUAL_REGISTER) + 1)
4108:
4109: /* This points to the location of dynamically-allocated memory on the stack
4110:    immediately after the stack pointer has been adjusted by the amount
4111:    desired.  */
4112:
4113: #define virtual_stack_dynamic_rtx	(global_rtl[GR_VIRTUAL_STACK_DYNAMIC])
4114:
4115: #define VIRTUAL_STACK_DYNAMIC_REGNUM	((FIRST_VIRTUAL_REGISTER) + 2)
4116:
4117: /* This points to the location in the stack at which outgoing arguments should
4118:    be written when the stack is pre-pushed (arguments pushed using push
4119:    insns always use sp).  */
4120:
4121: #define virtual_outgoing_args_rtx	(global_rtl[GR_VIRTUAL_OUTGOING_ARGS])
4122:
4123: #define VIRTUAL_OUTGOING_ARGS_REGNUM	((FIRST_VIRTUAL_REGISTER) + 3)
4124:
4125: /* This points to the Canonical Frame Address of the function.  This
4126:    should correspond to the CFA produced by INCOMING_FRAME_SP_OFFSET,
4127:    but is calculated relative to the arg pointer for simplicity; the
4128:    frame pointer nor stack pointer are necessarily fixed relative to
4129:    the CFA until after reload.  */
4130:
4131: #define virtual_cfa_rtx			(global_rtl[GR_VIRTUAL_CFA])
4132:
4133: #define VIRTUAL_CFA_REGNUM		((FIRST_VIRTUAL_REGISTER) + 4)
4134:
4135: #define LAST_VIRTUAL_POINTER_REGISTER	((FIRST_VIRTUAL_REGISTER) + 4)
4136:
4137: /* This is replaced by crtl->preferred_stack_boundary / BITS_PER_UNIT
4138:    when finalized.  */
4139:
4140: #define virtual_preferred_stack_boundary_rtx \
4141: 	(global_rtl[GR_VIRTUAL_PREFERRED_STACK_BOUNDARY])
4142:
4143: #define VIRTUAL_PREFERRED_STACK_BOUNDARY_REGNUM \
4144: 					((FIRST_VIRTUAL_REGISTER) + 5)
4145:
4146: #define LAST_VIRTUAL_REGISTER		((FIRST_VIRTUAL_REGISTER) + 5)
```

## gcc/function.cc:203–218
```text
203: /* Clear out all parts of the state in F that can safely be discarded
204:    after the function has been compiled, to let garbage collection
205:    reclaim the memory.  */
206:
207: void
208: free_after_compilation (struct function *f)
209: {
210:   prologue_insn_hash = NULL;
211:   epilogue_insn_hash = NULL;
212:
213:   free (crtl->emit.regno_pointer_align);
214:
215:   memset (crtl, 0, sizeof (struct rtl_data));
216:   f->eh = NULL;
217:   f->machine = NULL;
218:   f->cfg = NULL;
```

## gcc/function.cc:5133–5144
```text
5133:       rtx value_address = 0;
5134:
5135: #ifdef PCC_STATIC_STRUCT_RETURN
5136:       if (cfun->returns_pcc_struct)
5137: 	{
5138: 	  int size = int_size_in_bytes (TREE_TYPE (res));
5139: 	  value_address = assemble_static_space (size);
5140: 	}
5141:       else
5142: #endif
5143: 	{
5144: 	  rtx sv = targetm.calls.struct_value_rtx (TREE_TYPE (subr), 2);
```

## gcc/bb-reorder.cc:2616–2641
```text
2616: insert_section_boundary_note (void)
2617: {
2618:   basic_block bb;
2619:   bool switched_sections = false;
2620:   int current_partition = 0;
2621:
2622:   if (!crtl->has_bb_partition)
2623:     return;
2624:
2625:   FOR_EACH_BB_FN (bb, cfun)
2626:     {
2627:       if (!current_partition)
2628: 	current_partition = BB_PARTITION (bb);
2629:       if (BB_PARTITION (bb) != current_partition)
2630: 	{
2631: 	  gcc_assert (!switched_sections);
2632:           switched_sections = true;
2633:           emit_note_before (NOTE_INSN_SWITCH_TEXT_SECTIONS, BB_HEAD (bb));
2634:           current_partition = BB_PARTITION (bb);
2635: 	}
2636:     }
2637:
2638:   /* Make sure crtl->has_bb_partition matches reality even if bbpart finds
2639:      some hot and some cold basic blocks, but later one of those kinds is
2640:      optimized away.  */
2641:   crtl->has_bb_partition = switched_sections;
```

## gcc/bb-reorder.cc:2665–2672
```text
2665:
2666:   /* opt_pass methods: */
2667:   bool gate (function *) final override
2668:     {
2669:       if (targetm.cannot_modify_jumps_p ())
2670: 	return false;
2671:       return (optimize > 0
2672: 	      && (flag_reorder_blocks || flag_reorder_blocks_and_partition));
```

## gcc/bb-reorder.cc:2977–3011
```text
2977: pass_partition_blocks::gate (function *fun)
2978: {
2979:   /* The optimization to partition hot/cold basic blocks into separate
2980:      sections of the .o file does not work well with linkonce or with
2981:      user defined section attributes or with naked attribute.  Don't call
2982:      it if either case arises.  */
2983:   return (flag_reorder_blocks_and_partition
2984: 	  && optimize
2985: 	  /* See pass_reorder_blocks::gate.  We should not partition if
2986: 	     we are going to omit the reordering.  */
2987: 	  && optimize_function_for_speed_p (fun)
2988: 	  && !DECL_COMDAT_GROUP (current_function_decl)
2989: 	  && !lookup_attribute ("section", DECL_ATTRIBUTES (fun->decl))
2990: 	  && !lookup_attribute ("naked", DECL_ATTRIBUTES (fun->decl))
2991: 	  /* Workaround a bug in GDB where read_partial_die doesn't cope
2992: 	     with DIEs with DW_AT_ranges, see PR81115.  */
2993: 	  && !(in_lto_p && MAIN_NAME_P (DECL_NAME (fun->decl))));
2994: }
2995:
2996: unsigned
2997: pass_partition_blocks::execute (function *fun)
2998: {
2999:   vec<edge> crossing_edges;
3000:
3001:   if (n_basic_blocks_for_fn (fun) <= NUM_FIXED_BLOCKS + 1)
3002:     return 0;
3003:
3004:   df_set_flags (DF_DEFER_INSN_RESCAN);
3005:
3006:   crossing_edges = find_rarely_executed_basic_blocks_and_crossing_edges ();
3007:   if (!crossing_edges.exists ())
3008:     /* Make sure to process deferred rescans and clear changeable df flags.  */
3009:     return TODO_df_finish;
3010:
3011:   crtl->has_bb_partition = true;
```

## gcc/config/i386/i386.md:500–515
```text
500:    (R21_REG			81)
501:    (R22_REG			82)
502:    (R23_REG			83)
503:    (R24_REG			84)
504:    (R25_REG			85)
505:    (R26_REG			86)
506:    (R27_REG			87)
507:    (R28_REG			88)
508:    (R29_REG			89)
509:    (R30_REG			90)
510:    (R31_REG			91)
511:    (FIRST_PSEUDO_REG		92)
512:   ])
513:
514: ;; Insn callee abi index.
515: (define_constants
```

## gcc/config/i386/i386.md:25924–25962
```text
25924: (define_expand "movmem<mode>"
25925:   [(use (match_operand:BLK 0 "memory_operand"))
25926:    (use (match_operand:BLK 1 "memory_operand"))
25927:    (use (match_operand:SWI48 2 "nonmemory_operand"))
25928:    (use (match_operand:SWI48 3 "const_int_operand"))
25929:    (use (match_operand:SI 4 "const_int_operand"))
25930:    (use (match_operand:SI 5 "const_int_operand"))
25931:    (use (match_operand:SI 6 ""))
25932:    (use (match_operand:SI 7 ""))
25933:    (use (match_operand:SI 8 ""))]
25934:   ""
25935: {
25936:   if (ix86_expand_movmem (operands))
25937:     DONE;
25938:   FAIL;
25939: })
25940:
25941: (define_expand "cpymem<mode>"
25942:   [(use (match_operand:BLK 0 "memory_operand"))
25943:    (use (match_operand:BLK 1 "memory_operand"))
25944:    (use (match_operand:SWI48 2 "nonmemory_operand"))
25945:    (use (match_operand:SWI48 3 "const_int_operand"))
25946:    (use (match_operand:SI 4 "const_int_operand"))
25947:    (use (match_operand:SI 5 "const_int_operand"))
25948:    (use (match_operand:SI 6 ""))
25949:    (use (match_operand:SI 7 ""))
25950:    (use (match_operand:SI 8 ""))]
25951:   ""
25952: {
25953:  if (ix86_expand_set_or_cpymem (operands[0], operands[1],
25954: 			        operands[2], NULL, operands[3],
25955: 			        operands[4], operands[5],
25956: 				operands[6], operands[7],
25957: 				operands[8], false))
25958:    DONE;
25959:  else
25960:    FAIL;
25961: })
25962:
```

## gcc/read-rtl-function.cc:1435–1450
```text
1435:
1436: /* Ensure that the backend can cope with a REG with regno REGNO.
1437:    Normally REG instances are created by gen_reg_rtx which updates
1438:    regno_reg_rtx, growing it as necessary.
1439:    The REG instances created from the dumpfile weren't created this
1440:    way, so we need to manually update regno_reg_rtx.  */
1441:
1442: static void
1443: ensure_regno (int regno)
1444: {
1445:   if (reg_rtx_no < regno + 1)
1446:     reg_rtx_no = regno + 1;
1447:
1448:   crtl->emit.ensure_regno_capacity ();
1449:   gcc_assert (regno < crtl->emit.regno_pointer_align_length);
1450: }
```

## gcc/expr.cc:1096–1176
```text
1096:
1097: /* Determine whether an operation OP on LEN bytes with alignment ALIGN can
1098:    and should be performed piecewise.  */
1099:
1100: static bool
1101: can_do_by_pieces (unsigned HOST_WIDE_INT len, unsigned int align,
1102: 		  enum by_pieces_operation op)
1103: {
1104:   return targetm.use_by_pieces_infrastructure_p (len, align, op,
1105: 						 optimize_insn_for_speed_p ());
1106: }
1107:
1108: /* Determine whether the LEN bytes can be moved by using several move
1109:    instructions.  Return nonzero if a call to move_by_pieces should
1110:    succeed.  */
1111:
1112: bool
1113: can_move_by_pieces (unsigned HOST_WIDE_INT len, unsigned int align)
1114: {
1115:   return can_do_by_pieces (len, align, MOVE_BY_PIECES);
1116: }
1117:
1118: /* Return number of insns required to perform operation OP by pieces
1119:    for L bytes.  ALIGN (in bits) is maximum alignment we can assume.  */
1120:
1121: unsigned HOST_WIDE_INT
1122: by_pieces_ninsns (unsigned HOST_WIDE_INT l, unsigned int align,
1123: 		  unsigned int max_size, by_pieces_operation op)
1124: {
1125:   unsigned HOST_WIDE_INT n_insns = 0;
1126:   fixed_size_mode mode;
1127:
1128:   if (targetm.overlap_op_by_pieces_p ())
1129:     {
1130:       /* NB: Round up L and ALIGN to the widest integer mode for
1131: 	 MAX_SIZE.  */
1132:       mode = widest_fixed_size_mode_for_size (max_size, op);
1133:       gcc_assert (optab_handler (mov_optab, mode) != CODE_FOR_nothing);
1134:       unsigned HOST_WIDE_INT up = ROUND_UP (l, GET_MODE_SIZE (mode));
1135:       if (up > l)
1136: 	l = up;
1137:       align = GET_MODE_ALIGNMENT (mode);
1138:     }
1139:
1140:   align = alignment_for_piecewise_move (MOVE_MAX_PIECES, align);
1141:
1142:   while (max_size > 1 && l > 0)
1143:     {
1144:       mode = widest_fixed_size_mode_for_size (max_size, op);
1145:       gcc_assert (optab_handler (mov_optab, mode) != CODE_FOR_nothing);
1146:
1147:       unsigned int modesize = GET_MODE_SIZE (mode);
1148:
1149:       if (align >= GET_MODE_ALIGNMENT (mode))
1150: 	{
1151: 	  unsigned HOST_WIDE_INT n_pieces = l / modesize;
1152: 	  l %= modesize;
1153: 	  switch (op)
1154: 	    {
1155: 	    default:
1156: 	      n_insns += n_pieces;
1157: 	      break;
1158:
1159: 	    case COMPARE_BY_PIECES:
1160: 	      int batch = targetm.compare_by_pieces_branch_ratio (mode);
1161: 	      int batch_ops = 4 * batch - 1;
1162: 	      unsigned HOST_WIDE_INT full = n_pieces / batch;
1163: 	      n_insns += full * batch_ops;
1164: 	      if (n_pieces % batch != 0)
1165: 		n_insns++;
1166: 	      break;
1167:
1168: 	    }
1169: 	}
1170:       max_size = modesize;
1171:     }
1172:
1173:   gcc_assert (!l);
1174:   return n_insns;
1175: }
1176:
```

## gcc/expr.cc:1506–1590
```text
1506: op_by_pieces_d::run ()
1507: {
1508:   if (m_len == 0)
1509:     return;
1510:
1511:   unsigned HOST_WIDE_INT length = m_len;
1512:
1513:   /* widest_fixed_size_mode_for_size checks M_MAX_SIZE > 1.  */
1514:   fixed_size_mode mode
1515:     = widest_fixed_size_mode_for_size (m_max_size, m_op);
1516:   mode = get_usable_mode (mode, length);
1517:
1518:   by_pieces_prev to_prev = { nullptr, mode };
1519:   by_pieces_prev from_prev = { nullptr, mode };
1520:
1521:   do
1522:     {
1523:       unsigned int size = GET_MODE_SIZE (mode);
1524:       rtx to1 = NULL_RTX, from1;
1525:
1526:       while (length >= size)
1527: 	{
1528: 	  if (m_reverse)
1529: 	    m_offset -= size;
1530:
1531: 	  to1 = m_to.adjust (mode, m_offset, &to_prev);
1532: 	  to_prev.data = to1;
1533: 	  to_prev.mode = mode;
1534: 	  from1 = m_from.adjust (mode, m_offset, &from_prev);
1535: 	  from_prev.data = from1;
1536: 	  from_prev.mode = mode;
1537:
1538: 	  m_to.maybe_predec (-(HOST_WIDE_INT)size);
1539: 	  m_from.maybe_predec (-(HOST_WIDE_INT)size);
1540:
1541: 	  generate (to1, from1, mode);
1542:
1543: 	  m_to.maybe_postinc (size);
1544: 	  m_from.maybe_postinc (size);
1545:
1546: 	  if (!m_reverse)
1547: 	    m_offset += size;
1548:
1549: 	  length -= size;
1550: 	}
1551:
1552:       finish_mode (mode);
1553:
1554:       if (length == 0)
1555: 	return;
1556:
1557:       if (!m_push && m_overlap_op_by_pieces)
1558: 	{
1559: 	  /* NB: Generate overlapping operations if it is not a stack
1560: 	     push since stack push must not overlap.  Get the smallest
1561: 	     fixed size mode for M_LEN bytes.  */
1562: 	  mode = smallest_fixed_size_mode_for_size (length);
1563: 	  mode = get_usable_mode (mode, GET_MODE_SIZE (mode));
1564: 	  int gap = GET_MODE_SIZE (mode) - length;
1565: 	  if (gap > 0)
1566: 	    {
1567: 	      /* If size of MODE > M_LEN, generate the last operation
1568: 		 in MODE for the remaining bytes with ovelapping memory
1569: 		 from the previois operation.  */
1570: 	      if (m_reverse)
1571: 		m_offset += gap;
1572: 	      else
1573: 		m_offset -= gap;
1574: 	      length += gap;
1575: 	    }
1576: 	}
1577:       else
1578: 	{
1579: 	  /* widest_fixed_size_mode_for_size checks SIZE > 1.  */
1580: 	  mode = widest_fixed_size_mode_for_size (size, m_op);
1581: 	  mode = get_usable_mode (mode, length);
1582: 	}
1583:     }
1584:   while (1);
1585: }
1586:
1587: /* Derived class from op_by_pieces_d, providing support for block move
1588:    operations.  */
1589:
1590: #ifdef PUSH_ROUNDING
```

## gcc/expr.cc:2024–2169
```text
2024: emit_block_move_hints (rtx x, rtx y, rtx size, enum block_op_methods method,
2025: 		       unsigned int expected_align, HOST_WIDE_INT expected_size,
2026: 		       unsigned HOST_WIDE_INT min_size,
2027: 		       unsigned HOST_WIDE_INT max_size,
2028: 		       unsigned HOST_WIDE_INT probable_max_size,
2029: 		       bool bail_out_libcall, bool *is_move_done,
2030: 		       bool might_overlap, unsigned ctz_size)
2031: {
2032:   int may_use_call;
2033:   rtx retval = 0;
2034:   unsigned int align;
2035:
2036:   if (is_move_done)
2037:     *is_move_done = true;
2038:
2039:   gcc_assert (size);
2040:   if (CONST_INT_P (size) && INTVAL (size) == 0)
2041:     return 0;
2042:
2043:   switch (method)
2044:     {
2045:     case BLOCK_OP_NORMAL:
2046:     case BLOCK_OP_TAILCALL:
2047:       may_use_call = 1;
2048:       break;
2049:
2050:     case BLOCK_OP_CALL_PARM:
2051:       may_use_call = block_move_libcall_safe_for_call_parm ();
2052:
2053:       /* Make inhibit_defer_pop nonzero around the library call
2054: 	 to force it to pop the arguments right away.  */
2055:       NO_DEFER_POP;
2056:       break;
2057:
2058:     case BLOCK_OP_NO_LIBCALL:
2059:       may_use_call = 0;
2060:       break;
2061:
2062:     case BLOCK_OP_NO_LIBCALL_RET:
2063:       may_use_call = -1;
2064:       break;
2065:
2066:     default:
2067:       gcc_unreachable ();
2068:     }
2069:
2070:   gcc_assert (MEM_P (x) && MEM_P (y));
2071:   align = MIN (MEM_ALIGN (x), MEM_ALIGN (y));
2072:   gcc_assert (align >= BITS_PER_UNIT);
2073:
2074:   /* Make sure we've got BLKmode addresses; store_one_arg can decide that
2075:      block copy is more efficient for other large modes, e.g. DCmode.  */
2076:   x = adjust_address (x, BLKmode, 0);
2077:   y = adjust_address (y, BLKmode, 0);
2078:
2079:   /* If source and destination are the same, no need to copy anything.  */
2080:   if (rtx_equal_p (x, y)
2081:       && !MEM_VOLATILE_P (x)
2082:       && !MEM_VOLATILE_P (y))
2083:     return 0;
2084:
2085:   /* Set MEM_SIZE as appropriate for this block copy.  The main place this
2086:      can be incorrect is coming from __builtin_memcpy.  */
2087:   poly_int64 const_size;
2088:   if (poly_int_rtx_p (size, &const_size))
2089:     {
2090:       x = shallow_copy_rtx (x);
2091:       y = shallow_copy_rtx (y);
2092:       set_mem_size (x, const_size);
2093:       set_mem_size (y, const_size);
2094:     }
2095:
2096:   bool pieces_ok = CONST_INT_P (size)
2097:     && can_move_by_pieces (INTVAL (size), align);
2098:   bool pattern_ok = false;
2099:
2100:   if (!pieces_ok || might_overlap)
2101:     {
2102:       pattern_ok
2103: 	= emit_block_move_via_pattern (x, y, size, align,
2104: 				       expected_align, expected_size,
2105: 				       min_size, max_size, probable_max_size,
2106: 				       might_overlap);
2107:       if (!pattern_ok && might_overlap)
2108: 	{
2109: 	  /* Do not try any of the other methods below as they are not safe
2110: 	     for overlapping moves.  */
2111: 	  *is_move_done = false;
2112: 	  return retval;
2113: 	}
2114:     }
2115:
2116:   bool dynamic_direction = false;
2117:   if (!pattern_ok && !pieces_ok && may_use_call
2118:       && (flag_inline_stringops & (might_overlap ? ILSOP_MEMMOVE : ILSOP_MEMCPY)))
2119:     {
2120:       may_use_call = 0;
2121:       dynamic_direction = might_overlap;
2122:     }
2123:
2124:   if (pattern_ok)
2125:     ;
2126:   else if (pieces_ok)
2127:     move_by_pieces (x, y, INTVAL (size), align, RETURN_BEGIN);
2128:   else if (may_use_call && !might_overlap
2129: 	   && ADDR_SPACE_GENERIC_P (MEM_ADDR_SPACE (x))
2130: 	   && ADDR_SPACE_GENERIC_P (MEM_ADDR_SPACE (y)))
2131:     {
2132:       if (bail_out_libcall)
2133: 	{
2134: 	  if (is_move_done)
2135: 	    *is_move_done = false;
2136: 	  return retval;
2137: 	}
2138:
2139:       if (may_use_call < 0)
2140: 	return pc_rtx;
2141:
2142:       retval = emit_block_copy_via_libcall (x, y, size,
2143: 					    method == BLOCK_OP_TAILCALL);
2144:     }
2145:   else if (dynamic_direction)
2146:     emit_block_move_via_oriented_loop (x, y, size, align, ctz_size);
2147:   else if (might_overlap)
2148:     *is_move_done = false;
2149:   else
2150:     emit_block_move_via_sized_loop (x, y, size, align, ctz_size);
2151:
2152:   if (method == BLOCK_OP_CALL_PARM)
2153:     OK_DEFER_POP;
2154:
2155:   return retval;
2156: }
2157:
2158: rtx
2159: emit_block_move (rtx x, rtx y, rtx size, enum block_op_methods method,
2160: 		 unsigned int ctz_size)
2161: {
2162:   unsigned HOST_WIDE_INT max, min = 0;
2163:   if (GET_CODE (size) == CONST_INT)
2164:     min = max = UINTVAL (size);
2165:   else
2166:     max = GET_MODE_MASK (GET_MODE (size));
2167:   return emit_block_move_hints (x, y, size, method, 0, -1,
2168: 				min, max, max,
2169: 				false, NULL, false, ctz_size);
```

## gcc/expr.cc:2237–2329
```text
2237: emit_block_move_via_pattern (rtx x, rtx y, rtx size, unsigned int align,
2238: 			     unsigned int expected_align,
2239: 			     HOST_WIDE_INT expected_size,
2240: 			     unsigned HOST_WIDE_INT min_size,
2241: 			     unsigned HOST_WIDE_INT max_size,
2242: 			     unsigned HOST_WIDE_INT probable_max_size,
2243: 			     bool might_overlap)
2244: {
2245:   if (expected_align < align)
2246:     expected_align = align;
2247:   if (expected_size != -1)
2248:     {
2249:       if ((unsigned HOST_WIDE_INT)expected_size > probable_max_size)
2250: 	expected_size = probable_max_size;
2251:       if ((unsigned HOST_WIDE_INT)expected_size < min_size)
2252: 	expected_size = min_size;
2253:     }
2254:
2255:   /* Since this is a move insn, we don't care about volatility.  */
2256:   temporary_volatile_ok v (true);
2257:
2258:   /* Try the most limited insn first, because there's no point
2259:      including more than one in the machine description unless
2260:      the more limited one has some advantage.  */
2261:
2262:   opt_scalar_int_mode mode_iter;
2263:   FOR_EACH_MODE_IN_CLASS (mode_iter, MODE_INT)
2264:     {
2265:       scalar_int_mode mode = mode_iter.require ();
2266:       enum insn_code code;
2267:       if (might_overlap)
2268: 	code = direct_optab_handler (movmem_optab, mode);
2269:       else
2270: 	code = direct_optab_handler (cpymem_optab, mode);
2271:
2272:       if (code != CODE_FOR_nothing
2273: 	  /* We don't need MODE to be narrower than BITS_PER_HOST_WIDE_INT
2274: 	     here because if SIZE is less than the mode mask, as it is
2275: 	     returned by the macro, it will definitely be less than the
2276: 	     actual mode mask.  Since SIZE is within the Pmode address
2277: 	     space, we limit MODE to Pmode.  */
2278: 	  && ((CONST_INT_P (size)
2279: 	       && ((unsigned HOST_WIDE_INT) INTVAL (size)
2280: 		   <= (GET_MODE_MASK (mode) >> 1)))
2281: 	      || max_size <= (GET_MODE_MASK (mode) >> 1)
2282: 	      || GET_MODE_BITSIZE (mode) >= GET_MODE_BITSIZE (Pmode)))
2283: 	{
2284: 	  class expand_operand ops[9];
2285: 	  unsigned int nops;
2286:
2287: 	  /* ??? When called via emit_block_move_for_call, it'd be
2288: 	     nice if there were some way to inform the backend, so
2289: 	     that it doesn't fail the expansion because it thinks
2290: 	     emitting the libcall would be more efficient.  */
2291: 	  nops = insn_data[(int) code].n_generator_args;
2292: 	  gcc_assert (nops == 4 || nops == 6 || nops == 8 || nops == 9);
2293:
2294: 	  create_fixed_operand (&ops[0], x);
2295: 	  create_fixed_operand (&ops[1], y);
2296: 	  /* The check above guarantees that this size conversion is valid.  */
2297: 	  create_convert_operand_to (&ops[2], size, mode, true);
2298: 	  create_integer_operand (&ops[3], align / BITS_PER_UNIT);
2299: 	  if (nops >= 6)
2300: 	    {
2301: 	      create_integer_operand (&ops[4], expected_align / BITS_PER_UNIT);
2302: 	      create_integer_operand (&ops[5], expected_size);
2303: 	    }
2304: 	  if (nops >= 8)
2305: 	    {
2306: 	      create_integer_operand (&ops[6], min_size);
2307: 	      /* If we cannot represent the maximal size,
2308: 		 make parameter NULL.  */
2309: 	      if ((HOST_WIDE_INT) max_size != -1)
2310: 	        create_integer_operand (&ops[7], max_size);
2311: 	      else
2312: 		create_fixed_operand (&ops[7], NULL);
2313: 	    }
2314: 	  if (nops == 9)
2315: 	    {
2316: 	      /* If we cannot represent the maximal size,
2317: 		 make parameter NULL.  */
2318: 	      if ((HOST_WIDE_INT) probable_max_size != -1)
2319: 	        create_integer_operand (&ops[8], probable_max_size);
2320: 	      else
2321: 		create_fixed_operand (&ops[8], NULL);
2322: 	    }
2323: 	  if (maybe_expand_insn (code, nops, ops))
2324: 	    return true;
2325: 	}
2326:     }
2327:
2328:   return false;
2329: }
```

## gcc/expr.cc:2540–2579
```text
2540: {
2541:   rtx dst_addr, src_addr;
2542:   tree call_expr, dst_tree, src_tree, size_tree;
2543:   machine_mode size_mode;
2544:
2545:   /* Since dst and src are passed to a libcall, mark the corresponding
2546:      tree EXPR as addressable.  */
2547:   tree dst_expr = MEM_EXPR (dst);
2548:   tree src_expr = MEM_EXPR (src);
2549:   if (dst_expr)
2550:     mark_addressable (dst_expr);
2551:   if (src_expr)
2552:     mark_addressable (src_expr);
2553:
2554:   dst_addr = copy_addr_to_reg (XEXP (dst, 0));
2555:   dst_addr = convert_memory_address (ptr_mode, dst_addr);
2556:   dst_tree = make_tree (ptr_type_node, dst_addr);
2557:
2558:   src_addr = copy_addr_to_reg (XEXP (src, 0));
2559:   src_addr = convert_memory_address (ptr_mode, src_addr);
2560:   src_tree = make_tree (ptr_type_node, src_addr);
2561:
2562:   size_mode = TYPE_MODE (sizetype);
2563:   size = convert_to_mode (size_mode, size, 1);
2564:   size = copy_to_mode_reg (size_mode, size);
2565:   size_tree = make_tree (sizetype, size);
2566:
2567:   /* It is incorrect to use the libcall calling conventions for calls to
2568:      memcpy/memmove/memcmp because they can be provided by the user.  */
2569:   tree fn = builtin_decl_implicit (fncode);
2570:   call_expr = build_call_expr (fn, 3, dst_tree, src_tree, size_tree);
2571:   CALL_EXPR_TAILCALL (call_expr) = tailcall;
2572:
2573:   return expand_call (call_expr, NULL_RTX, false);
2574: }
2575:
2576: /* Try to expand cmpstrn or cmpmem operation ICODE with the given operands.
2577:    ARG3_TYPE is the type of ARG3_RTX.  Return the result rtx on success,
2578:    otherwise return null.  */
2579:
```

## gcc/expr.h:85–105
```text
85: /* Expand a call to memcpy or memmove or memcmp, and return the result.  */
86: extern rtx emit_block_op_via_libcall (enum built_in_function, rtx, rtx, rtx,
87: 				      bool);
88:
89: inline rtx
90: emit_block_copy_via_libcall (rtx dst, rtx src, rtx size, bool tailcall = false)
91: {
92:   return emit_block_op_via_libcall (BUILT_IN_MEMCPY, dst, src, size, tailcall);
93: }
94:
95: inline rtx
96: emit_block_move_via_libcall (rtx dst, rtx src, rtx size, bool tailcall = false)
97: {
98:   return emit_block_op_via_libcall (BUILT_IN_MEMMOVE, dst, src, size, tailcall);
99: }
100:
101: inline rtx
102: emit_block_comp_via_libcall (rtx dst, rtx src, rtx size, bool tailcall = false)
103: {
104:   return emit_block_op_via_libcall (BUILT_IN_MEMCMP, dst, src, size, tailcall);
105: }
```

## gcc/targhooks.cc:2156–2220
```text
2156: /* For hooks which use the MOVE_RATIO macro, this gives the legacy default
2157:    behavior.  SPEED_P is true if we are compiling for speed.  */
2158:
2159: unsigned int
2160: get_move_ratio (bool speed_p ATTRIBUTE_UNUSED)
2161: {
2162:   unsigned int move_ratio;
2163: #ifdef MOVE_RATIO
2164:   move_ratio = (unsigned int) MOVE_RATIO (speed_p);
2165: #else
2166: #if defined (HAVE_cpymemqi) || defined (HAVE_cpymemhi) || defined (HAVE_cpymemsi) || defined (HAVE_cpymemdi) || defined (HAVE_cpymemti)
2167:   move_ratio = 2;
2168: #else /* No cpymem patterns, pick a default.  */
2169:   move_ratio = ((speed_p) ? 15 : 3);
2170: #endif
2171: #endif
2172:   return move_ratio;
2173: }
2174:
2175: /* Return TRUE if the move_by_pieces/set_by_pieces infrastructure should be
2176:    used; return FALSE if the cpymem/setmem optab should be expanded, or
2177:    a call to memcpy emitted.  */
2178:
2179: bool
2180: default_use_by_pieces_infrastructure_p (unsigned HOST_WIDE_INT size,
2181: 					unsigned int alignment,
2182: 					enum by_pieces_operation op,
2183: 					bool speed_p)
2184: {
2185:   unsigned int max_size = 0;
2186:   unsigned int ratio = 0;
2187:
2188:   switch (op)
2189:     {
2190:     case CLEAR_BY_PIECES:
2191:       max_size = STORE_MAX_PIECES;
2192:       ratio = CLEAR_RATIO (speed_p);
2193:       break;
2194:     case MOVE_BY_PIECES:
2195:       max_size = MOVE_MAX_PIECES;
2196:       ratio = get_move_ratio (speed_p);
2197:       break;
2198:     case SET_BY_PIECES:
2199:       max_size = STORE_MAX_PIECES;
2200:       ratio = SET_RATIO (speed_p);
2201:       break;
2202:     case STORE_BY_PIECES:
2203:       max_size = STORE_MAX_PIECES;
2204:       ratio = get_move_ratio (speed_p);
2205:       break;
2206:     case COMPARE_BY_PIECES:
2207:       max_size = COMPARE_MAX_PIECES;
2208:       /* Pick a likely default, just as in get_move_ratio.  */
2209:       ratio = speed_p ? 15 : 3;
2210:       break;
2211:     }
2212:
2213:   return by_pieces_ninsns (size, alignment, max_size + 1, op) < ratio;
2214: }
2215:
2216: /* This hook controls code generation for expanding a memcmp operation by
2217:    pieces.  Return 1 for the normal pattern of compare/jump after each pair
2218:    of loads, or a higher number to reduce the number of branches.  */
2219:
2220: int
```

## gcc/config/i386/i386.h:1916–1966
```text
1916:    locations.  */
1917: #define MAX_MOVE_MAX 64
1918:
1919: /* Max number of bytes we can move from memory to memory in one
1920:    reasonably fast instruction, as opposed to MOVE_MAX_PIECES which
1921:    is the number of bytes at a time which we can move efficiently.
1922:    MOVE_MAX_PIECES defaults to MOVE_MAX.  */
1923:
1924: #define MOVE_MAX \
1925:   ((TARGET_AVX512F && ix86_move_max == PVW_AVX512) \
1926:    ? 64 \
1927:    : ((TARGET_AVX && ix86_move_max >= PVW_AVX256) \
1928:       ? 32 \
1929:       : ((TARGET_SSE2 \
1930: 	  && TARGET_SSE_UNALIGNED_LOAD_OPTIMAL \
1931: 	  && TARGET_SSE_UNALIGNED_STORE_OPTIMAL) \
1932: 	 ? 16 : UNITS_PER_WORD)))
1933:
1934: /* STORE_MAX_PIECES is the number of bytes at a time that we can store
1935:    efficiently.  Allow 16/32/64 bytes only if inter-unit move is enabled
1936:    since vec_duplicate enabled by inter-unit move is used to implement
1937:    store_by_pieces of 16/32/64 bytes.  */
1938: #define STORE_MAX_PIECES \
1939:   (TARGET_INTER_UNIT_MOVES_TO_VEC \
1940:    ? ((TARGET_AVX512F && ix86_move_max == PVW_AVX512) \
1941:       ? 64 \
1942:       : ((TARGET_AVX && ix86_move_max >= PVW_AVX256) \
1943: 	  ? 32 \
1944: 	  : ((TARGET_SSE2 \
1945: 	      && TARGET_SSE_UNALIGNED_STORE_OPTIMAL) \
1946: 	     ? 16 : UNITS_PER_WORD)))		     \
1947:       : UNITS_PER_WORD)
1948:
1949: /* If a memory-to-memory move would take MOVE_RATIO or more simple
1950:    move-instruction pairs, we will do a cpymem or libcall instead.
1951:    Increasing the value will always make code faster, but eventually
1952:    incurs high cost in increased code size.
1953:
1954:    If you don't define this, a reasonable default is used.  */
1955:
1956: #define MOVE_RATIO(speed) ((speed) ? ix86_cost->move_ratio : 3)
1957:
1958: /* If a clear memory operation would take CLEAR_RATIO or more simple
1959:    move-instruction sequences, we will do a clrmem or libcall instead.  */
1960:
1961: #define CLEAR_RATIO(speed) ((speed) ? ix86_cost->clear_ratio : 2)
1962:
1963: /* Define if shifts truncate the shift count which implies one can
1964:    omit a sign-extension or zero-extension of a shift count.
1965:
1966:    On i386, shifts do truncate the count.  But bit test instructions
```

## gcc/config/i386/i386.cc:11580–11596
```text
11580: /* Implement TARGET_USE_BY_PIECES_INFRASTRUCTURE_P.  */
11581:
11582: bool
11583: ix86_use_by_pieces_infrastructure_p (unsigned HOST_WIDE_INT size,
11584: 				     unsigned int align,
11585: 				     enum by_pieces_operation op,
11586: 				     bool speed_p)
11587: {
11588:   /* Return true when we are currently expanding memcpy/memset epilogue
11589:      with move_by_pieces or store_by_pieces.  */
11590:   if (cfun->machine->by_pieces_in_use)
11591:     return true;
11592:
11593:   return default_use_by_pieces_infrastructure_p (size, align, op,
11594: 						 speed_p);
11595: }
11596:
```

## gcc/config/i386/i386-expand.cc:9135–9294
```text
9135: decide_alg (HOST_WIDE_INT count, HOST_WIDE_INT expected_size,
9136: 	    unsigned HOST_WIDE_INT min_size, unsigned HOST_WIDE_INT max_size,
9137: 	    bool memset, bool zero_memset, addr_space_t dst_as,
9138: 	    addr_space_t src_as, int *dynamic_check, bool *noalign, bool recur)
9139: {
9140:   const struct stringop_algs *algs;
9141:   bool optimize_for_speed;
9142:   int max = 0;
9143:   const struct processor_costs *cost;
9144:   int i;
9145:   bool any_alg_usable_p = false;
9146:
9147:   *noalign = false;
9148:   *dynamic_check = -1;
9149:
9150:   /* Even if the string operation call is cold, we still might spend a lot
9151:      of time processing large blocks.  */
9152:   if (optimize_function_for_size_p (cfun)
9153:       || (optimize_insn_for_size_p ()
9154:  	  && (max_size < 256
9155:               || (expected_size != -1 && expected_size < 256))))
9156:     optimize_for_speed = false;
9157:   else
9158:     optimize_for_speed = true;
9159:
9160:   cost = optimize_for_speed ? ix86_cost : &ix86_size_cost;
9161:   if (memset)
9162:     algs = &cost->memset[TARGET_64BIT != 0];
9163:   else
9164:     algs = &cost->memcpy[TARGET_64BIT != 0];
9165:
9166:   /* See maximal size for user defined algorithm.  */
9167:   for (i = 0; i < MAX_STRINGOP_ALGS; i++)
9168:     {
9169:       enum stringop_alg candidate = algs->size[i].alg;
9170:       bool usable = alg_usable_p (candidate, memset, dst_as, src_as);
9171:       any_alg_usable_p |= usable;
9172:
9173:       if (candidate != libcall && candidate && usable)
9174: 	max = algs->size[i].max;
9175:     }
9176:
9177:   /* If expected size is not known but max size is small enough
9178:      so inline version is a win, set expected size into
9179:      the range.  */
9180:   if (((max > 1 && (unsigned HOST_WIDE_INT) max >= max_size) || max == -1)
9181:       && expected_size == -1)
9182:     expected_size = min_size / 2 + max_size / 2;
9183:
9184:   /* If user specified the algorithm, honor it if possible.  */
9185:   if (ix86_stringop_alg != no_stringop
9186:       && alg_usable_p (ix86_stringop_alg, memset, dst_as, src_as))
9187:     return ix86_stringop_alg;
9188:   /* rep; movq or rep; movl is the smallest variant.  */
9189:   else if (!optimize_for_speed)
9190:     {
9191:       *noalign = true;
9192:       if (!count || (count & 3) || (memset && !zero_memset))
9193: 	return alg_usable_p (rep_prefix_1_byte, memset, dst_as, src_as)
9194: 	       ? rep_prefix_1_byte : loop_1_byte;
9195:       else
9196: 	return alg_usable_p (rep_prefix_4_byte, memset, dst_as, src_as)
9197: 	       ? rep_prefix_4_byte : loop;
9198:     }
9199:   /* Very tiny blocks are best handled via the loop, REP is expensive to
9200:      setup.  */
9201:   else if (expected_size != -1 && expected_size < 4)
9202:     return loop_1_byte;
9203:   else if (expected_size != -1)
9204:     {
9205:       enum stringop_alg alg = libcall;
9206:       bool alg_noalign = false;
9207:       for (i = 0; i < MAX_STRINGOP_ALGS; i++)
9208: 	{
9209: 	  /* We get here if the algorithms that were not libcall-based
9210: 	     were rep-prefix based and we are unable to use rep prefixes
9211: 	     based on global register usage.  Break out of the loop and
9212: 	     use the heuristic below.  */
9213: 	  if (algs->size[i].max == 0)
9214: 	    break;
9215: 	  if (algs->size[i].max >= expected_size || algs->size[i].max == -1)
9216: 	    {
9217: 	      enum stringop_alg candidate = algs->size[i].alg;
9218:
9219: 	      if (candidate != libcall
9220: 		  && alg_usable_p (candidate, memset, dst_as, src_as))
9221: 		{
9222: 		  alg = candidate;
9223: 		  alg_noalign = algs->size[i].noalign;
9224: 		}
9225: 	      /* Honor TARGET_INLINE_ALL_STRINGOPS by picking
9226: 		 last non-libcall inline algorithm.  */
9227: 	      if (TARGET_INLINE_ALL_STRINGOPS)
9228: 		{
9229: 		  /* When the current size is best to be copied by a libcall,
9230: 		     but we are still forced to inline, run the heuristic below
9231: 		     that will pick code for medium sized blocks.  */
9232: 		  if (alg != libcall)
9233: 		    {
9234: 		      *noalign = alg_noalign;
9235: 		      return alg;
9236: 		    }
9237: 		  else if (!any_alg_usable_p)
9238: 		    break;
9239: 		}
9240: 	      else if (alg_usable_p (candidate, memset, dst_as, src_as)
9241: 		       && !(TARGET_PREFER_KNOWN_REP_MOVSB_STOSB
9242: 			    && candidate == rep_prefix_1_byte
9243: 			    /* NB: If min_size != max_size, size is
9244: 			       unknown.  */
9245: 			    && min_size != max_size))
9246: 		{
9247: 		  *noalign = algs->size[i].noalign;
9248: 		  return candidate;
9249: 		}
9250: 	    }
9251: 	}
9252:     }
9253:   /* When asked to inline the call anyway, try to pick meaningful choice.
9254:      We look for maximal size of block that is faster to copy by hand and
9255:      take blocks of at most of that size guessing that average size will
9256:      be roughly half of the block.
9257:
9258:      If this turns out to be bad, we might simply specify the preferred
9259:      choice in ix86_costs.  */
9260:   if ((TARGET_INLINE_ALL_STRINGOPS || TARGET_INLINE_STRINGOPS_DYNAMICALLY)
9261:       && (algs->unknown_size == libcall
9262: 	  || !alg_usable_p (algs->unknown_size, memset, dst_as, src_as)))
9263:     {
9264:       enum stringop_alg alg;
9265:       HOST_WIDE_INT new_expected_size = (max > 0 ? max : 4096) / 2;
9266:
9267:       /* If there aren't any usable algorithms or if recursing already,
9268: 	 then recursing on smaller sizes or same size isn't going to
9269: 	 find anything.  Just return the simple byte-at-a-time copy loop.  */
9270:       if (!any_alg_usable_p || recur)
9271: 	{
9272: 	  /* Pick something reasonable.  */
9273: 	  if (TARGET_INLINE_STRINGOPS_DYNAMICALLY && !recur)
9274: 	    *dynamic_check = 128;
9275: 	  return loop_1_byte;
9276: 	}
9277:       alg = decide_alg (count, new_expected_size, min_size, max_size,
9278: 			memset, zero_memset, dst_as, src_as,
9279: 			dynamic_check, noalign, true);
9280:       gcc_assert (*dynamic_check == -1);
9281:       if (TARGET_INLINE_STRINGOPS_DYNAMICALLY)
9282: 	*dynamic_check = max;
9283:       else
9284: 	gcc_assert (alg != libcall);
9285:       return alg;
9286:     }
9287:
9288:   /* Try to use some reasonable fallback algorithm.  Note that for
9289:      non-default address spaces we default to a loop instead of
9290:      a libcall.  */
9291:
9292:   bool have_as = !(ADDR_SPACE_GENERIC_P (dst_as)
9293: 		   && ADDR_SPACE_GENERIC_P (src_as));
9294:
```

## gcc/config/i386/i386-expand.cc:9510–9586
```text
9510:   rtx srcreg = NULL;
9511:   rtx_code_label *label = NULL;
9512:   rtx tmp;
9513:   rtx_code_label *jump_around_label = NULL;
9514:   HOST_WIDE_INT align = 1;
9515:   unsigned HOST_WIDE_INT count = 0;
9516:   HOST_WIDE_INT expected_size = -1;
9517:   int size_needed = 0, epilogue_size_needed;
9518:   int desired_align = 0, align_bytes = 0;
9519:   enum stringop_alg alg;
9520:   rtx promoted_val = NULL;
9521:   rtx vec_promoted_val = NULL;
9522:   bool force_loopy_epilogue = false;
9523:   int dynamic_check;
9524:   bool need_zero_guard = false;
9525:   bool noalign;
9526:   machine_mode move_mode = VOIDmode;
9527:   int unroll_factor = 1;
9528:   /* TODO: Once value ranges are available, fill in proper data.  */
9529:   unsigned HOST_WIDE_INT min_size = HOST_WIDE_INT_0U;
9530:   unsigned HOST_WIDE_INT max_size = HOST_WIDE_INT_M1U;
9531:   unsigned HOST_WIDE_INT probable_max_size = HOST_WIDE_INT_M1U;
9532:   bool misaligned_prologue_used = false;
9533:   addr_space_t dst_as, src_as = ADDR_SPACE_GENERIC;
9534:
9535:   if (CONST_INT_P (align_exp))
9536:     align = INTVAL (align_exp);
9537:   /* i386 can do misaligned access on reasonably increased cost.  */
9538:   if (CONST_INT_P (expected_align_exp)
9539:       && INTVAL (expected_align_exp) > align)
9540:     align = INTVAL (expected_align_exp);
9541:   /* ALIGN is the minimum of destination and source alignment, but we care here
9542:      just about destination alignment.  */
9543:   else if (!issetmem
9544: 	   && MEM_ALIGN (dst) > (unsigned HOST_WIDE_INT) align * BITS_PER_UNIT)
9545:     align = MEM_ALIGN (dst) / BITS_PER_UNIT;
9546:
9547:   if (CONST_INT_P (count_exp))
9548:     {
9549:       min_size = max_size = probable_max_size = count = expected_size
9550: 	= INTVAL (count_exp);
9551:       /* When COUNT is 0, there is nothing to do.  */
9552:       if (!count)
9553: 	return true;
9554:     }
9555:   else
9556:     {
9557:       if (min_size_exp)
9558: 	min_size = INTVAL (min_size_exp);
9559:       if (max_size_exp)
9560: 	max_size = INTVAL (max_size_exp);
9561:       if (probable_max_size_exp)
9562: 	probable_max_size = INTVAL (probable_max_size_exp);
9563:       if (CONST_INT_P (expected_size_exp))
9564: 	expected_size = INTVAL (expected_size_exp);
9565:      }
9566:
9567:   /* Make sure we don't need to care about overflow later on.  */
9568:   if (count > (HOST_WIDE_INT_1U << 30))
9569:     return false;
9570:
9571:   dst_as = MEM_ADDR_SPACE (dst);
9572:   if (!issetmem)
9573:     src_as = MEM_ADDR_SPACE (src);
9574:
9575:   /* Step 0: Decide on preferred algorithm, desired alignment and
9576:      size of chunks to be copied by main loop.  */
9577:   alg = decide_alg (count, expected_size, min_size, probable_max_size,
9578: 		    issetmem, issetmem && val_exp == const0_rtx,
9579: 		    dst_as, src_as, &dynamic_check, &noalign, false);
9580:
9581:   if (dump_file)
9582:     fprintf (dump_file, "Selected stringop expansion strategy: %s\n",
9583: 	     stringop_alg_names[alg]);
9584:
9585:   if (alg == libcall)
9586:     return false;
```

## gcc/config/i386/i386-expand.cc:10010–10715
```text
10010:
10011: static bool
10012: ix86_expand_unroll_movmem (rtx dst, rtx src, rtx destreg, rtx srcreg,
10013: 			   unsigned HOST_WIDE_INT count,
10014: 			   machine_mode mode)
10015: {
10016:   /* If 8 registers registers can cover all memory, load them into
10017:      registers and store them together to avoid possible address
10018:      overlap between source and destination.  */
10019:   unsigned HOST_WIDE_INT moves = count / GET_MODE_SIZE (mode);
10020:   if (moves == 0)
10021:     {
10022:       mode = smallest_int_mode_for_size
10023: 	(count * BITS_PER_UNIT).require ();
10024:       if (count == GET_MODE_SIZE (mode))
10025: 	moves = 1;
10026:       else
10027: 	{
10028: 	  /* Reduce the smallest move size by half so that MOVES == 1.  */
10029: 	  mode = smallest_int_mode_for_size
10030: 	    (GET_MODE_BITSIZE (mode) / 2).require ();
10031: 	  moves = count / GET_MODE_SIZE (mode);
10032: 	  gcc_assert (moves == 1);
10033: 	}
10034:     }
10035:   else if (moves > 8)
10036:     return false;
10037:
10038:   unsigned int i;
10039:   rtx tmp[9];
10040:
10041:   for (i = 0; i < moves; i++)
10042:     tmp[i] = gen_reg_rtx (mode);
10043:
10044:   rtx srcmem = change_address (src, mode, srcreg);
10045:   for (i = 0; i < moves; i++)
10046:     {
10047:       emit_move_insn (tmp[i], srcmem);
10048:       srcmem = offset_address (srcmem,
10049: 			       GEN_INT (GET_MODE_SIZE (mode)),
10050: 			       GET_MODE_SIZE (mode));
10051:     }
10052:
10053:   unsigned int epilogue_size = count & (GET_MODE_SIZE (mode) - 1);
10054:   machine_mode epilogue_mode = VOIDmode;
10055:   if (epilogue_size)
10056:     {
10057:       /* Handle the remaining bytes with overlapping move.  */
10058:       epilogue_mode = smallest_int_mode_for_size
10059: 	(epilogue_size * BITS_PER_UNIT).require ();
10060:       tmp[8] = gen_reg_rtx (epilogue_mode);
10061:       srcmem = adjust_address (srcmem, epilogue_mode, 0);
10062:       srcmem = offset_address (srcmem, GEN_INT (epilogue_size), 1);
10063:       srcmem = offset_address (srcmem,
10064: 			       GEN_INT (-GET_MODE_SIZE (epilogue_mode)),
10065: 			       GET_MODE_SIZE (epilogue_mode));
10066:       emit_move_insn (tmp[8], srcmem);
10067:     }
10068:
10069:   rtx destmem = change_address (dst, mode, destreg);
10070:   for (i = 0; i < moves; i++)
10071:     {
10072:       emit_move_insn (destmem, tmp[i]);
10073:       destmem = offset_address (destmem,
10074: 				GEN_INT (GET_MODE_SIZE (mode)),
10075: 				GET_MODE_SIZE (mode));
10076:     }
10077:
10078:   if (epilogue_size)
10079:     {
10080:       /* Use overlapping move.  */
10081:       destmem = adjust_address (destmem, epilogue_mode, 0);
10082:       destmem = offset_address (destmem, GEN_INT (epilogue_size), 1);
10083:       destmem = offset_address (destmem,
10084: 				GEN_INT (-GET_MODE_SIZE (epilogue_mode)),
10085: 				GET_MODE_SIZE (epilogue_mode));
10086:       emit_move_insn (destmem, tmp[8]);
10087:     }
10088:
10089:   return true;
10090: }
10091:
10092: /* Expand memmove of size with MOVES * mode size and MOVES <= 4.  If
10093:    FORWARD is true, copy forward.  Otherwise copy backward.  */
10094:
10095: static void
10096: ix86_expand_n_move_movmem (rtx destmem, rtx srcmem, machine_mode mode,
10097: 			   unsigned int moves, bool forward)
10098: {
10099:   gcc_assert (moves <= 4);
10100:
10101:   unsigned int i;
10102:   rtx tmp[8];
10103:
10104:   for (i = 0; i < moves; i++)
10105:     tmp[i] = gen_reg_rtx (mode);
10106:
10107:   rtx step;
10108:   if (forward)
10109:     step = GEN_INT (GET_MODE_SIZE (mode));
10110:   else
10111:     step = GEN_INT (-GET_MODE_SIZE (mode));
10112:
10113:   /* Load MOVES.  */
10114:   for (i = 0; i < moves - 1; i++)
10115:     {
10116:       emit_move_insn (tmp[i], srcmem);
10117:       srcmem = offset_address (srcmem, step, GET_MODE_SIZE (mode));
10118:     }
10119:   emit_move_insn (tmp[i], srcmem);
10120:
10121:   /* Store MOVES.  */
10122:   for (i = 0; i < moves - 1; i++)
10123:     {
10124:       emit_move_insn (destmem, tmp[i]);
10125:       destmem = offset_address (destmem, step, GET_MODE_SIZE (mode));
10126:     }
10127:   emit_move_insn (destmem, tmp[i]);
10128: }
10129:
10130: /* Load MOVES of mode size into REGS.  If LAST is true, load the
10131:    last MOVES.  Otherwise, load the first MOVES.  */
10132:
10133: static void
10134: ix86_expand_load_movmem (rtx src, rtx srcreg, rtx count_exp,
10135: 			 machine_mode mode, unsigned int moves,
10136: 			 rtx regs[], bool last)
10137: {
10138:   unsigned int i;
10139:
10140:   for (i = 0; i < moves; i++)
10141:     regs[i] = gen_reg_rtx (mode);
10142:
10143:   rtx srcmem = change_address (src, mode, srcreg);
10144:   rtx step;
10145:   if (last)
10146:     {
10147:       srcmem = offset_address (srcmem, count_exp, 1);
10148:       step = GEN_INT (-GET_MODE_SIZE (mode));
10149:       srcmem = offset_address (srcmem, step, GET_MODE_SIZE (mode));
10150:     }
10151:   else
10152:     step = GEN_INT (GET_MODE_SIZE (mode));
10153:
10154:   for (i = 0; i < moves - 1; i++)
10155:     {
10156:       emit_move_insn (regs[i], srcmem);
10157:       srcmem = offset_address (srcmem, step, GET_MODE_SIZE (mode));
10158:     }
10159:   emit_move_insn (regs[i], srcmem);
10160: }
10161:
10162: /* Store MOVES of mode size into REGS.  If LAST is true, store the
10163:    last MOVES.  Otherwise, store the first MOVES.  */
10164:
10165: static void
10166: ix86_expand_store_movmem (rtx dst, rtx destreg, rtx count_exp,
10167: 			  machine_mode mode, unsigned int moves,
10168: 			  rtx regs[], bool last)
10169: {
10170:   unsigned int i;
10171:
10172:   rtx destmem = change_address (dst, mode, destreg);
10173:   rtx step;
10174:   if (last)
10175:     {
10176:       destmem = offset_address (destmem, count_exp, 1);
10177:       step = GEN_INT (-GET_MODE_SIZE (mode));
10178:       destmem = offset_address (destmem, step, GET_MODE_SIZE (mode));
10179:     }
10180:   else
10181:     step = GEN_INT (GET_MODE_SIZE (mode));
10182:
10183:   for (i = 0; i < moves - 1; i++)
10184:     {
10185:       emit_move_insn (destmem, regs[i]);
10186:       destmem = offset_address (destmem, step, GET_MODE_SIZE (mode));
10187:     }
10188:   emit_move_insn (destmem, regs[i]);
10189: }
10190:
10191: /* Expand memmove of size between (MOVES / 2) * mode size and
10192:    MOVES * mode size with overlapping load and store.  MOVES is even.
10193:    MOVES >= 2 and MOVES <= 8.  */
10194:
10195: static void
10196: ix86_expand_n_overlapping_move_movmem (rtx dst, rtx src, rtx destreg,
10197: 				       rtx srcreg, rtx count_exp,
10198: 				       machine_mode mode,
10199: 				       unsigned int moves)
10200: {
10201:   gcc_assert (moves >= 2 && moves <= 8 && (moves & 1) == 0);
10202:
10203:   unsigned int half_moves = moves / 2;
10204:   unsigned int i, j;
10205:   rtx tmp[8];
10206:
10207:   for (i = 0; i < moves; i++)
10208:     tmp[i] = gen_reg_rtx (mode);
10209:
10210:   rtx base_srcmem = change_address (src, mode, srcreg);
10211:
10212:   /* Load the first half.  */
10213:   rtx srcmem = base_srcmem;
10214:   for (i = 0; i < half_moves - 1; i++)
10215:     {
10216:       emit_move_insn (tmp[i], srcmem);
10217:       srcmem = offset_address (srcmem,
10218: 			       GEN_INT (GET_MODE_SIZE (mode)),
10219: 			       GET_MODE_SIZE (mode));
10220:     }
10221:   emit_move_insn (tmp[i], srcmem);
10222:
10223:   /* Load the second half.  */
10224:   srcmem = offset_address (base_srcmem, count_exp, 1);
10225:   srcmem = offset_address (srcmem,
10226: 			   GEN_INT (-GET_MODE_SIZE (mode)),
10227: 			   GET_MODE_SIZE (mode));
10228:   for (j = half_moves, i = 0; i < half_moves - 1; i++, j++)
10229:     {
10230:       emit_move_insn (tmp[j], srcmem);
10231:       srcmem = offset_address (srcmem,
10232: 			       GEN_INT (-GET_MODE_SIZE (mode)),
10233: 			       GET_MODE_SIZE (mode));
10234:     }
10235:   emit_move_insn (tmp[j], srcmem);
10236:
10237:   rtx base_destmem = change_address (dst, mode, destreg);
10238:
10239:   /* Store the first half.  */
10240:   rtx destmem = base_destmem;
10241:   for (i = 0; i < half_moves - 1; i++)
10242:     {
10243:       emit_move_insn (destmem, tmp[i]);
10244:       destmem = offset_address (destmem,
10245: 				GEN_INT (GET_MODE_SIZE (mode)),
10246: 				GET_MODE_SIZE (mode));
10247:     }
10248:   emit_move_insn (destmem, tmp[i]);
10249:
10250:   /* Store the second half.  */
10251:   destmem = offset_address (base_destmem, count_exp, 1);
10252:   destmem = offset_address (destmem, GEN_INT (-GET_MODE_SIZE (mode)),
10253: 			    GET_MODE_SIZE (mode));
10254:   for (j = half_moves, i = 0; i < half_moves - 1; i++, j++)
10255:     {
10256:       emit_move_insn (destmem, tmp[j]);
10257:       destmem = offset_address (destmem, GEN_INT (-GET_MODE_SIZE (mode)),
10258: 				GET_MODE_SIZE (mode));
10259:     }
10260:   emit_move_insn (destmem, tmp[j]);
10261: }
10262:
10263: /* Expand memmove of size < mode size which is <= 64.  */
10264:
10265: static void
10266: ix86_expand_less_move_movmem (rtx dst, rtx src, rtx destreg,
10267: 			      rtx srcreg, rtx count_exp,
10268: 			      unsigned HOST_WIDE_INT min_size,
10269: 			      machine_mode mode,
10270: 			      rtx_code_label *done_label)
10271: {
10272:   bool skip = false;
10273:   machine_mode count_mode = counter_mode (count_exp);
10274:
10275:   rtx_code_label *between_32_63_label
10276:     = GET_MODE_SIZE (mode) > 32 ? gen_label_rtx () : nullptr;
10277:   /* Jump to BETWEEN_32_64_LABEL if size >= 32 and size < 64.  */
10278:   if (between_32_63_label)
10279:     {
10280:       if (min_size && min_size >= 32)
10281: 	{
10282: 	  emit_jump_insn (gen_jump (between_32_63_label));
10283: 	  emit_barrier ();
10284: 	  skip = true;
10285: 	}
10286:       else
10287: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (32), GEU,
10288: 				 nullptr, count_mode, 1,
10289: 				 between_32_63_label);
10290:     }
10291:
10292:   rtx_code_label *between_16_31_label
10293:     = (!skip && GET_MODE_SIZE (mode) > 16) ? gen_label_rtx () : nullptr;
10294:   /* Jump to BETWEEN_16_31_LABEL if size >= 16 and size < 31.  */
10295:   if (between_16_31_label)
10296:     {
10297:       if (min_size && min_size >= 16)
10298: 	{
10299: 	  emit_jump_insn (gen_jump (between_16_31_label));
10300: 	  emit_barrier ();
10301: 	  skip = true;
10302: 	}
10303:       else
10304: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (16), GEU,
10305: 				 nullptr, count_mode, 1,
10306: 				 between_16_31_label);
10307:     }
10308:
10309:   rtx_code_label *between_8_15_label
10310:     = (!skip && GET_MODE_SIZE (mode) > 8) ? gen_label_rtx () : nullptr;
10311:   /* Jump to BETWEEN_8_15_LABEL if size >= 8 and size < 15.  */
10312:   if (between_8_15_label)
10313:     {
10314:       if (min_size && min_size >= 8)
10315: 	{
10316: 	  emit_jump_insn (gen_jump (between_8_15_label));
10317: 	  emit_barrier ();
10318: 	  skip = true;
10319: 	}
10320:       else
10321: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (8), GEU,
10322: 				 nullptr, count_mode, 1,
10323: 				 between_8_15_label);
10324:     }
10325:
10326:   rtx_code_label *between_4_7_label
10327:     = (!skip && GET_MODE_SIZE (mode) > 4) ? gen_label_rtx () : nullptr;
10328:   /* Jump to BETWEEN_4_7_LABEL if size >= 4 and size < 7.  */
10329:   if (between_4_7_label)
10330:     {
10331:       if (min_size && min_size >= 4)
10332: 	{
10333: 	  emit_jump_insn (gen_jump (between_4_7_label));
10334: 	  emit_barrier ();
10335: 	  skip = true;
10336: 	}
10337:       else
10338: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (4), GEU,
10339: 				 nullptr, count_mode, 1,
10340: 				 between_4_7_label);
10341:     }
10342:
10343:   rtx_code_label *between_2_3_label
10344:     = (!skip && GET_MODE_SIZE (mode) > 2) ? gen_label_rtx () : nullptr;
10345:   /* Jump to BETWEEN_2_3_LABEL if size >= 2 and size < 3.  */
10346:   if (between_2_3_label)
10347:     {
10348:       if (min_size && min_size >= 2)
10349: 	{
10350: 	  emit_jump_insn (gen_jump (between_2_3_label));
10351: 	  emit_barrier ();
10352: 	  skip = true;
10353: 	}
10354:       else
10355: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (1), GT,
10356: 				 nullptr, count_mode, 1,
10357: 				 between_2_3_label);
10358:     }
10359:
10360:   if (!skip)
10361:     {
10362:       rtx_code_label *zero_label
10363: 	= min_size == 0 ? gen_label_rtx () : nullptr;
10364:       /* Skip if size == 0.  */
10365:       if (zero_label)
10366: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (1), LT,
10367: 				 nullptr, count_mode, 1,
10368: 				 zero_label,
10369: 				 profile_probability::unlikely ());
10370:
10371:       /* Move 1 byte.  */
10372:       rtx tmp0 = gen_reg_rtx (QImode);
10373:       rtx srcmem = change_address (src, QImode, srcreg);
10374:       emit_move_insn (tmp0, srcmem);
10375:       rtx destmem = change_address (dst, QImode, destreg);
10376:       emit_move_insn (destmem, tmp0);
10377:
10378:       if (zero_label)
10379: 	emit_label (zero_label);
10380:
10381:       emit_jump_insn (gen_jump (done_label));
10382:       emit_barrier ();
10383:     }
10384:
10385:   if (between_32_63_label)
10386:     {
10387:       emit_label (between_32_63_label);
10388:       ix86_expand_n_overlapping_move_movmem (dst, src, destreg, srcreg,
10389: 					     count_exp, OImode, 2);
10390:       emit_jump_insn (gen_jump (done_label));
10391:       emit_barrier ();
10392:     }
10393:
10394:   if (between_16_31_label)
10395:     {
10396:       emit_label (between_16_31_label);
10397:       ix86_expand_n_overlapping_move_movmem (dst, src, destreg, srcreg,
10398: 					     count_exp, TImode, 2);
10399:       emit_jump_insn (gen_jump (done_label));
10400:       emit_barrier ();
10401:     }
10402:
10403:   if (between_8_15_label)
10404:     {
10405:       emit_label (between_8_15_label);
10406:       ix86_expand_n_overlapping_move_movmem (dst, src, destreg, srcreg,
10407: 					     count_exp, DImode, 2);
10408:       emit_jump_insn (gen_jump (done_label));
10409:       emit_barrier ();
10410:     }
10411:
10412:   if (between_4_7_label)
10413:     {
10414:       emit_label (between_4_7_label);
10415:       ix86_expand_n_overlapping_move_movmem (dst, src, destreg, srcreg,
10416: 					     count_exp, SImode, 2);
10417:       emit_jump_insn (gen_jump (done_label));
10418:       emit_barrier ();
10419:     }
10420:
10421:   if (between_2_3_label)
10422:     {
10423:       emit_label (between_2_3_label);
10424:       ix86_expand_n_overlapping_move_movmem (dst, src, destreg, srcreg,
10425: 					     count_exp, HImode, 2);
10426:       emit_jump_insn (gen_jump (done_label));
10427:       emit_barrier ();
10428:     }
10429: }
10430:
10431: /* Expand movmem with overlapping unaligned loads and stores:
10432:    1. Load all sources into registers and store them together to avoid
10433:       possible address overlap between source and destination.
10434:    2. For known size, first try to fully unroll with 8 registers.
10435:    3. For size <= 2 * MOVE_MAX, load all sources into 2 registers first
10436:       and then store them together.
10437:    4. For size > 2 * MOVE_MAX and size <= 4 * MOVE_MAX, load all sources
10438:       into 4 registers first and then store them together.
10439:    5. For size > 4 * MOVE_MAX and size <= 8 * MOVE_MAX, load all sources
10440:       into 8 registers first and then store them together.
10441:    6. For size > 8 * MOVE_MAX,
10442:       a. If address of destination > address of source, copy backward
10443: 	 with a 4 * MOVE_MAX loop with unaligned loads and stores.  Load
10444: 	 the first 4 * MOVE_MAX into 4 registers before the loop and
10445: 	 store them after the loop to support overlapping addresses.
10446:       b. Otherwise, copy forward with a 4 * MOVE_MAX loop with unaligned
10447: 	 loads and stores.  Load the last 4 * MOVE_MAX into 4 registers
10448: 	 before the loop and store them after the loop to support
10449: 	 overlapping addresses.
10450:  */
10451:
10452: bool
10453: ix86_expand_movmem (rtx operands[])
10454: {
10455:   /* Since there are much less registers available in 32-bit mode, don't
10456:      inline movmem in 32-bit mode.  */
10457:   if (!TARGET_64BIT)
10458:     return false;
10459:
10460:   rtx dst = operands[0];
10461:   rtx src = operands[1];
10462:   rtx count_exp = operands[2];
10463:   rtx expected_size_exp = operands[5];
10464:   rtx min_size_exp = operands[6];
10465:   rtx probable_max_size_exp = operands[8];
10466:   unsigned HOST_WIDE_INT count = HOST_WIDE_INT_0U;
10467:   HOST_WIDE_INT expected_size = HOST_WIDE_INT_M1U;
10468:   unsigned HOST_WIDE_INT min_size = HOST_WIDE_INT_0U;
10469:   unsigned HOST_WIDE_INT probable_max_size = HOST_WIDE_INT_M1U;
10470:
10471:   if (CONST_INT_P (count_exp))
10472:     {
10473:       min_size = probable_max_size = count = expected_size
10474: 	= INTVAL (count_exp);
10475:       /* When COUNT is 0, there is nothing to do.  */
10476:       if (!count)
10477: 	return true;
10478:     }
10479:   else
10480:     {
10481:       if (min_size_exp)
10482: 	min_size = INTVAL (min_size_exp);
10483:       if (probable_max_size_exp)
10484: 	probable_max_size = INTVAL (probable_max_size_exp);
10485:       if (CONST_INT_P (expected_size_exp))
10486: 	expected_size = INTVAL (expected_size_exp);
10487:      }
10488:
10489:   /* Make sure we don't need to care about overflow later on.  */
10490:   if (count > (HOST_WIDE_INT_1U << 30))
10491:     return false;
10492:
10493:   addr_space_t dst_as = MEM_ADDR_SPACE (dst);
10494:   addr_space_t src_as = MEM_ADDR_SPACE (src);
10495:   int dynamic_check;
10496:   bool noalign;
10497:   enum stringop_alg alg = decide_alg (count, expected_size, min_size,
10498: 				      probable_max_size, false, false,
10499: 				      dst_as, src_as, &dynamic_check,
10500: 				      &noalign, false);
10501:   if (alg == libcall)
10502:     return false;
10503:
10504:   rtx destreg = ix86_copy_addr_to_reg (XEXP (dst, 0));
10505:   rtx srcreg = ix86_copy_addr_to_reg (XEXP (src, 0));
10506:
10507:   unsigned int move_max = MOVE_MAX;
10508:   machine_mode mode = smallest_int_mode_for_size
10509:     (move_max * BITS_PER_UNIT).require ();
10510:   if (probable_max_size && probable_max_size < move_max)
10511:     {
10512:       /* Get a usable MOVE_MAX.  */
10513:       mode = smallest_int_mode_for_size
10514: 	(probable_max_size * BITS_PER_UNIT).require ();
10515:       /* Reduce MOVE_MAX by half so that MOVE_MAX can be used.  */
10516:       if (GET_MODE_SIZE (mode) > probable_max_size)
10517: 	mode = smallest_int_mode_for_size
10518: 	  (GET_MODE_BITSIZE (mode) / 2).require ();
10519:       move_max = GET_MODE_SIZE (mode);
10520:     }
10521:
10522:   /* Try to fully unroll memmove of known size first.  */
10523:   if (count
10524:       && ix86_expand_unroll_movmem (dst, src, destreg, srcreg, count,
10525: 				    mode))
10526:     return true;
10527:
10528:   rtx_code_label *done_label = gen_label_rtx ();
10529:
10530:   rtx_code_label *less_vec_label = nullptr;
10531:   if (min_size == 0 || min_size < move_max)
10532:     less_vec_label = gen_label_rtx ();
10533:
10534:   machine_mode count_mode = counter_mode (count_exp);
10535:
10536:   /* Jump to LESS_VEC_LABEL if size < MOVE_MAX.  */
10537:   if (less_vec_label)
10538:     emit_cmp_and_jump_insns (count_exp, GEN_INT (move_max), LTU,
10539: 			     nullptr, count_mode, 1,
10540: 			     less_vec_label);
10541:
10542:   rtx_code_label *more_2x_vec_label = nullptr;
10543:   if (probable_max_size == 0 || probable_max_size > 2 * move_max)
10544:     more_2x_vec_label = gen_label_rtx ();
10545:
10546:   /* Jump to MORE_2X_VEC_LABEL if size > 2 * MOVE_MAX.  */
10547:   if (more_2x_vec_label)
10548:     emit_cmp_and_jump_insns (count_exp, GEN_INT (2 * move_max), GTU,
10549: 			     nullptr, count_mode, 1,
10550: 			     more_2x_vec_label);
10551:
10552:   if (min_size == 0 || min_size <= 2 * move_max)
10553:     {
10554:       /* Size >= MOVE_MAX and size <= 2 * MOVE_MAX.  */
10555:       ix86_expand_n_overlapping_move_movmem (dst, src, destreg, srcreg,
10556: 					     count_exp, mode, 2);
10557:       emit_jump_insn (gen_jump (done_label));
10558:       emit_barrier ();
10559:     }
10560:
10561:   if (less_vec_label)
10562:     {
10563:       /* Size < MOVE_MAX.  */
10564:       emit_label (less_vec_label);
10565:       ix86_expand_less_move_movmem (dst, src, destreg, srcreg,
10566: 				    count_exp, min_size, mode,
10567: 				    done_label);
10568:       emit_jump_insn (gen_jump (done_label));
10569:       emit_barrier ();
10570:     }
10571:
10572:   if (more_2x_vec_label)
10573:     {
10574:       /* Size > 2 * MOVE_MAX and destination may overlap with source.  */
10575:       emit_label (more_2x_vec_label);
10576:
10577:       rtx_code_label *more_8x_vec_label = nullptr;
10578:       if (probable_max_size == 0 || probable_max_size > 8 * move_max)
10579: 	more_8x_vec_label = gen_label_rtx ();
10580:
10581:       /* Jump to MORE_8X_VEC_LABEL if size > 8 * MOVE_MAX.  */
10582:       if (more_8x_vec_label)
10583: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (8 * move_max), GTU,
10584: 				 nullptr, count_mode, 1,
10585: 				 more_8x_vec_label);
10586:
10587:       rtx_code_label *last_4x_vec_label = nullptr;
10588:       if (min_size == 0 || min_size < 4 * move_max)
10589: 	last_4x_vec_label = gen_label_rtx ();
10590:
10591:       /* Jump to LAST_4X_VEC_LABEL if size < 4 * MOVE_MAX.  */
10592:       if (last_4x_vec_label)
10593: 	emit_cmp_and_jump_insns (count_exp, GEN_INT (4 * move_max), LTU,
10594: 				 nullptr, count_mode, 1,
10595: 				 last_4x_vec_label);
10596:
10597:       if (probable_max_size == 0 || probable_max_size > 4 * move_max)
10598: 	{
10599: 	  /* Size > 4 * MOVE_MAX and size <= 8 * MOVE_MAX.  */
10600: 	  ix86_expand_n_overlapping_move_movmem (dst, src, destreg,
10601: 						 srcreg, count_exp,
10602: 						 mode, 8);
10603: 	  emit_jump_insn (gen_jump (done_label));
10604: 	  emit_barrier ();
10605: 	}
10606:
10607:       if (last_4x_vec_label)
10608: 	{
10609: 	  /* Size > 2 * MOVE_MAX and size <= 4 * MOVE_MAX.  */
10610: 	  emit_label (last_4x_vec_label);
10611: 	  ix86_expand_n_overlapping_move_movmem (dst, src, destreg,
10612: 						 srcreg, count_exp,
10613: 						 mode, 4);
10614: 	  emit_jump_insn (gen_jump (done_label));
10615: 	  emit_barrier ();
10616: 	}
10617:
10618:       if (more_8x_vec_label)
10619: 	{
10620: 	  /* Size > 8 * MOVE_MAX.  */
10621: 	  emit_label (more_8x_vec_label);
10622:
10623: 	  rtx loop_count = gen_reg_rtx (count_mode);
10624: 	  emit_move_insn (loop_count, count_exp);
10625:
10626: 	  /* Jump to MORE_8X_VEC_BACKWARD_LABEL if source address is
10627: 	     lower than destination address.  */
10628: 	  rtx_code_label *more_8x_vec_backward_label = gen_label_rtx ();
10629: 	  emit_cmp_and_jump_insns (srcreg, destreg, LTU, nullptr,
10630: 				   GET_MODE (destreg), 1,
10631: 				   more_8x_vec_backward_label);
10632:
10633: 	  /* Skip if source == destination which is less common.  */
10634: 	  emit_cmp_and_jump_insns (srcreg, destreg, EQ, nullptr,
10635: 				   GET_MODE (destreg), 1, done_label,
10636: 				   profile_probability::unlikely ());
10637:
10638: 	  rtx base_destreg = gen_reg_rtx (GET_MODE (destreg));
10639: 	  emit_move_insn (base_destreg, destreg);
10640:
10641: 	  /* Load the last 4 * MOVE_MAX.  */
10642: 	  rtx regs[4];
10643: 	  ix86_expand_load_movmem (src, srcreg, count_exp, mode,
10644: 				   ARRAY_SIZE (regs), regs, true);
10645:
10646: 	  rtx srcmem = change_address (src, mode, srcreg);
10647: 	  rtx destmem = change_address (dst, mode, destreg);
10648:
10649: 	  /* Copy forward with a 4 * MOVE_MAX loop.  */
10650: 	  rtx_code_label *loop_4x_vec_forward_label = gen_label_rtx ();
10651: 	  emit_label (loop_4x_vec_forward_label);
10652:
10653: 	  ix86_expand_n_move_movmem (destmem, srcmem, mode, 4, true);
10654:
10655: 	  rtx tmp;
10656: 	  rtx delta = GEN_INT (4 * MOVE_MAX);
10657:
10658: 	  /* Decrement LOOP_COUNT by 4 * MOVE_MAX.  */
10659: 	  tmp = expand_simple_binop (GET_MODE (loop_count), MINUS,
10660: 				     loop_count, delta, nullptr, 1,
10661: 				     OPTAB_DIRECT);
10662: 	  if (tmp != loop_count)
10663: 	    emit_move_insn (loop_count, tmp);
10664:
10665: 	  /* Increment DESTREG and SRCREG by 4 * MOVE_MAX.  */
10666: 	  tmp = expand_simple_binop (GET_MODE (destreg), PLUS,
10667: 				     destreg, delta, nullptr, 1,
10668: 				     OPTAB_DIRECT);
10669: 	  if (tmp != destreg)
10670: 	    emit_move_insn (destreg, tmp);
10671: 	  tmp = expand_simple_binop (GET_MODE (srcreg), PLUS, srcreg,
10672: 				     delta, nullptr, 1, OPTAB_DIRECT);
10673: 	  if (tmp != srcreg)
10674: 	    emit_move_insn (srcreg, tmp);
10675:
10676: 	  /* Stop if LOOP_EXP <= 4 * MOVE_MAX.  */
10677: 	  emit_cmp_and_jump_insns (loop_count, delta, GTU, nullptr,
10678: 				   GET_MODE (loop_count), 1,
10679: 				   loop_4x_vec_forward_label);
10680:
10681: 	  /* Store the last 4 * MOVE_MAX.  */
10682: 	  ix86_expand_store_movmem (dst, base_destreg, count_exp, mode,
10683: 				    ARRAY_SIZE (regs), regs, true);
10684:
10685: 	  emit_jump_insn (gen_jump (done_label));
10686: 	  emit_barrier ();
10687:
10688: 	  /* Copy backward with a 4 * MOVE_MAX loop.  */
10689: 	  emit_label (more_8x_vec_backward_label);
10690:
10691: 	  base_destreg = gen_reg_rtx (GET_MODE (destreg));
10692: 	  emit_move_insn (base_destreg, destreg);
10693:
10694: 	  /* Load the first 4 * MOVE_MAX.  */
10695: 	  ix86_expand_load_movmem (src, srcreg, count_exp, mode,
10696: 				   ARRAY_SIZE (regs), regs, false);
10697:
10698: 	  /* Increment DESTREG and SRCREG by COUNT_EXP.  */
10699: 	  tmp = expand_simple_binop (GET_MODE (destreg), PLUS,
10700: 				     destreg, count_exp, nullptr, 1,
10701: 				     OPTAB_DIRECT);
10702: 	  if (tmp != destreg)
10703: 	    emit_move_insn (destreg, tmp);
10704: 	  tmp = expand_simple_binop (GET_MODE (srcreg), PLUS, srcreg,
10705: 				     count_exp, nullptr, 1, OPTAB_DIRECT);
10706: 	  if (tmp != srcreg)
10707: 	    emit_move_insn (srcreg, tmp);
10708:
10709: 	  srcmem = change_address (src, mode, srcreg);
10710: 	  destmem = change_address (dst, mode, destreg);
10711: 	  rtx step = GEN_INT (-GET_MODE_SIZE (mode));
10712: 	  srcmem = offset_address (srcmem, step, GET_MODE_SIZE (mode));
10713: 	  destmem = offset_address (destmem, step, GET_MODE_SIZE (mode));
10714:
10715: 	  rtx_code_label *loop_4x_vec_backward_label = gen_label_rtx ();
```

## gcc/config/i386/x86-tune-costs.h:4139–4157
```text
4139: static stringop_algs generic_memcpy[2] = {
4140:   {libcall,
4141:    {{256, vector_loop, true},
4142:     {256, unrolled_loop, true},
4143:     {-1, libcall, true}}},
4144:   {libcall,
4145:    {{256, vector_loop, true},
4146:     {256, unrolled_loop, true},
4147:     {-1, libcall, true}}}};
4148: static stringop_algs generic_memset[2] = {
4149:   {libcall,
4150:    {{256, vector_loop, true},
4151:     {256, unrolled_loop, true},
4152:     {-1, libcall, true}}},
4153:   {libcall,
4154:    {{256, vector_loop, true},
4155:     {256, unrolled_loop, true},
4156:     {-1, libcall, true}}}};
4157: static const
```

## gcc/config/i386/x86-tune-costs.h:4208–4220
```text
4208:    COSTS_N_INSNS (74)},			/*			    other */
4209:   COSTS_N_INSNS (1),			/* cost of movsx */
4210:   COSTS_N_INSNS (1),			/* cost of movzx */
4211:   8,					/* "large" insn */
4212:   17,					/* MOVE_RATIO */
4213:   10,					/* CLEAR_RATIO */
4214:   {6, 6, 6},				/* cost of loading integer registers
4215: 					   in QImode, HImode and SImode.
4216: 					   Relative to reg-reg move (2).  */
4217:   {6, 6, 6},				/* cost of storing integer registers */
4218:   {6, 6, 6, 10, 15},			/* cost of loading SSE register
4219: 					   in 32bit, 64bit, 128bit, 256bit and 512bit */
4220:   {6, 6, 6, 10, 15},			/* cost of storing SSE register
```

## gcc/defaults.h:977–995
```text
977: /* This macro is used to determine what the largest unit size that
978:    move_by_pieces can use is.  */
979:
980: /* MOVE_MAX_PIECES is the number of bytes at a time which we can
981:    move efficiently, as opposed to  MOVE_MAX which is the maximum
982:    number of bytes we can move with a single instruction.  */
983:
984: #ifndef MOVE_MAX_PIECES
985: #define MOVE_MAX_PIECES   MOVE_MAX
986: #endif
987:
988: /* STORE_MAX_PIECES is the number of bytes at a time that we can
989:    store efficiently.  Due to internal GCC limitations, this is
990:    MOVE_MAX_PIECES limited by the number of bytes GCC can represent
991:    for an immediate constant.  */
992:
993: #ifndef STORE_MAX_PIECES
994: #define STORE_MAX_PIECES  MIN (MOVE_MAX_PIECES, 2 * sizeof (HOST_WIDE_INT))
995: #endif
```
