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

## gcc/ada/gcc-interface/trans.cc:9119–9212
```text
9119:   /* If we are external or global, we don't want to output the DECL_EXPR for
9120:      this DECL node since we already have evaluated the expressions in the
9121:      sizes and positions as globals and doing it again would be wrong.  */
9122:   if (DECL_EXTERNAL (gnu_decl) || global_bindings_p ())
9123:     {
9124:       /* Mark everything as used to prevent node sharing with subprograms.
9125: 	 Note that walk_tree knows how to deal with TYPE_DECL, but neither
9126: 	 VAR_DECL nor CONST_DECL.  This appears to be somewhat arbitrary.  */
9127:       MARK_VISITED (gnu_stmt);
9128:       if (VAR_P (gnu_decl)
9129: 	  || TREE_CODE (gnu_decl) == CONST_DECL)
9130: 	{
9131: 	  MARK_VISITED (DECL_SIZE (gnu_decl));
9132: 	  MARK_VISITED (DECL_SIZE_UNIT (gnu_decl));
9133: 	  MARK_VISITED (DECL_INITIAL (gnu_decl));
9134: 	}
9135:     }
9136:   else
9137:     add_stmt_with_node (gnu_stmt, gnat_node);
9138:
9139:   /* Mark our TYPE_ADA_SIZE field now since it will not be gimplified.  */
9140:   if (TREE_CODE (gnu_decl) == TYPE_DECL
9141:       && RECORD_OR_UNION_TYPE_P (type)
9142:       && !TYPE_FAT_POINTER_P (type))
9143:     MARK_VISITED (TYPE_ADA_SIZE (type));
9144:
9145:   if (VAR_P (gnu_decl) && (gnu_init = DECL_INITIAL (gnu_decl)))
9146:     {
9147:       /* If this is a variable and an initializer is attached to it, it must be
9148: 	 valid for the context.  Similar to init_const in create_var_decl.  */
9149:       if (!gnat_types_compatible_p (type, TREE_TYPE (gnu_init))
9150: 	  || (TREE_STATIC (gnu_decl)
9151: 	      && !initializer_constant_valid_p (gnu_init,
9152: 						TREE_TYPE (gnu_init))))
9153: 	{
9154: 	  DECL_INITIAL (gnu_decl) = NULL_TREE;
9155: 	  if (TREE_READONLY (gnu_decl))
9156: 	    {
9157: 	      TREE_READONLY (gnu_decl) = 0;
9158: 	      DECL_READONLY_ONCE_ELAB (gnu_decl) = 1;
9159: 	    }
9160:
9161: 	  /* Remove any padding so the assignment is done properly.  */
9162: 	  gnu_decl = maybe_padded_object (gnu_decl);
9163:
9164: 	  gnu_stmt
9165: 	    = build_binary_op (INIT_EXPR, NULL_TREE, gnu_decl, gnu_init);
9166: 	  add_stmt_with_node (gnu_stmt, gnat_node);
9167: 	}
9168:
9169:       /* If this is the initialization of a (potentially) large aggregate, then
9170: 	 declare the dependence on the memcpy routine.  */
9171:       if (AGGREGATE_TYPE_P (type)
9172: 	  && (!TREE_CONSTANT (TYPE_SIZE (type))
9173: 	      || compare_tree_int (TYPE_SIZE (type), 2 * BITS_PER_WORD) > 0))
9174: 	Check_Restriction_No_Dependence_On_System (Name_Memory_Copy,
9175: 						   gnat_node);
9176:     }
9177: }
9178:
9179: /* Callback for walk_tree to mark the visited trees rooted at *TP.  */
9180:
9181: static tree
9182: mark_visited_r (tree *tp, int *walk_subtrees, void *data ATTRIBUTE_UNUSED)
9183: {
9184:   tree t = *tp;
9185:
9186:   if (TREE_VISITED (t))
9187:     *walk_subtrees = 0;
9188:
9189:   /* Don't mark a dummy type as visited because we want to mark its sizes
9190:      and fields once it's filled in.  */
9191:   else if (!TYPE_IS_DUMMY_P (t))
9192:     TREE_VISITED (t) = 1;
9193:
9194:   /* The test in gimplify_type_sizes is on the main variant.  */
9195:   if (TYPE_P (t))
9196:     TYPE_SIZES_GIMPLIFIED (TYPE_MAIN_VARIANT (t)) = 1;
9197:
9198:   return NULL_TREE;
9199: }
9200:
9201: /* Mark nodes rooted at T with TREE_VISITED and types as having their
9202:    sized gimplified.  We use this to indicate all variable sizes and
9203:    positions in global types may not be shared by any subprogram.  */
9204:
9205: void
9206: mark_visited (tree t)
9207: {
9208:   walk_tree (&t, mark_visited_r, NULL, NULL);
9209: }
9210:
9211: /* Add GNU_CLEANUP, a cleanup action, to the current code group and
9212:    set its location to that of GNAT_NODE if present, but with column info
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

## gcc/ada/gcc-interface/misc.cc:1475–1476
```text
1475: #undef  LANG_HOOKS_DEEP_UNSHARING
1476: #define LANG_HOOKS_DEEP_UNSHARING	true
```

## gcc/tree.cc:142–156
```text
142: static GTY(()) unsigned next_type_uid = 1;
143: /* Unique id for next debug decl created.  Use negative numbers,
144:    to catch erroneous uses.  */
145: static GTY(()) int next_debug_decl_uid;
146:
147: /* Since we cannot rehash a type after it is in the table, we have to
148:    keep the hash code.  */
149:
150: struct GTY((for_user)) type_hash {
151:   unsigned long hash;
152:   tree type;
153: };
154:
155: /* Initial size of the hash table (rounded to next prime).  */
156: #define TYPE_HASH_INITIAL_SIZE 1000
```

## gcc/tree.cc:770–785
```text
770: {
771:   /* Initialize the hash table of types.  */
772:   type_hash_table
773:     = hash_table<type_cache_hasher>::create_ggc (TYPE_HASH_INITIAL_SIZE);
774:
775:   debug_expr_for_decl
776:     = hash_table<tree_decl_map_cache_hasher>::create_ggc (512);
777:
778:   value_expr_for_decl
779:     = hash_table<tree_decl_map_cache_hasher>::create_ggc (512);
780:
781:   int_cst_hash_table = hash_table<int_cst_hasher>::create_ggc (1024);
782:
783:   poly_int_cst_hash_table = hash_table<poly_int_cst_hasher>::create_ggc (64);
784:
785:   int_cst_node = make_int_cst (1, 1);
```

## gcc/tree.cc:1089–1143
```text
1089: tree_code_size (enum tree_code code)
1090: {
1091:   switch (TREE_CODE_CLASS (code))
1092:     {
1093:     case tcc_declaration:  /* A decl node */
1094:       switch (code)
1095: 	{
1096: 	case FIELD_DECL:	return sizeof (tree_field_decl);
1097: 	case PARM_DECL:		return sizeof (tree_parm_decl);
1098: 	case VAR_DECL:		return sizeof (tree_var_decl);
1099: 	case LABEL_DECL:	return sizeof (tree_label_decl);
1100: 	case RESULT_DECL:	return sizeof (tree_result_decl);
1101: 	case CONST_DECL:	return sizeof (tree_const_decl);
1102: 	case TYPE_DECL:		return sizeof (tree_type_decl);
1103: 	case FUNCTION_DECL:	return sizeof (tree_function_decl);
1104: 	case DEBUG_EXPR_DECL:	return sizeof (tree_decl_with_rtl);
1105: 	case TRANSLATION_UNIT_DECL: return sizeof (tree_translation_unit_decl);
1106: 	case NAMESPACE_DECL:
1107: 	case IMPORTED_DECL:
1108: 	case NAMELIST_DECL:	return sizeof (tree_decl_non_common);
1109: 	default:
1110: 	  gcc_checking_assert (code >= NUM_TREE_CODES);
1111: 	  return lang_hooks.tree_size (code);
1112: 	}
1113:
1114:     case tcc_type:  /* a type node */
1115:       switch (code)
1116: 	{
1117: 	case OFFSET_TYPE:
1118: 	case ENUMERAL_TYPE:
1119: 	case BOOLEAN_TYPE:
1120: 	case INTEGER_TYPE:
1121: 	case REAL_TYPE:
1122: 	case OPAQUE_TYPE:
1123: 	case POINTER_TYPE:
1124: 	case REFERENCE_TYPE:
1125: 	case NULLPTR_TYPE:
1126: 	case FIXED_POINT_TYPE:
1127: 	case COMPLEX_TYPE:
1128: 	case VECTOR_TYPE:
1129: 	case ARRAY_TYPE:
1130: 	case RECORD_TYPE:
1131: 	case UNION_TYPE:
1132: 	case QUAL_UNION_TYPE:
1133: 	case VOID_TYPE:
1134: 	case FUNCTION_TYPE:
1135: 	case METHOD_TYPE:
1136: 	case BITINT_TYPE:
1137: 	case LANG_TYPE:		return sizeof (tree_type_non_common);
1138: 	default:
1139: 	  gcc_checking_assert (code >= NUM_TREE_CODES);
1140: 	  return lang_hooks.tree_size (code);
1141: 	}
1142:
1143:     case tcc_reference:   /* a reference */
```

## gcc/tree.cc:1368–1383
```text
1368:     case tcc_type:
1369:       TYPE_UID (t) = next_type_uid++;
1370:       SET_TYPE_ALIGN (t, BITS_PER_UNIT);
1371:       TYPE_USER_ALIGN (t) = 0;
1372:       TYPE_MAIN_VARIANT (t) = t;
1373:       TYPE_CANONICAL (t) = t;
1374:
1375:       /* Default to no attributes for type, but let target change that.  */
1376:       TYPE_ATTRIBUTES (t) = NULL_TREE;
1377:       targetm.set_default_type_attributes (t);
1378:
1379:       /* We have not yet computed the alias set for this type.  */
1380:       TYPE_ALIAS_SET (t) = -1;
1381:       break;
1382:
1383:     case tcc_constant:
```

## gcc/tree.cc:1468–1547
```text
1468: copy_node (tree node MEM_STAT_DECL)
1469: {
1470:   tree t;
1471:   enum tree_code code = TREE_CODE (node);
1472:   size_t length;
1473:
1474:   gcc_assert (code != STATEMENT_LIST);
1475:
1476:   length = tree_size (node);
1477:   record_node_allocation_statistics (code, length);
1478:   t = ggc_alloc_tree_node_stat (length PASS_MEM_STAT);
1479:   memcpy (t, node, length);
1480:
1481:   if (CODE_CONTAINS_STRUCT (code, TS_COMMON))
1482:     TREE_CHAIN (t) = 0;
1483:   TREE_ASM_WRITTEN (t) = 0;
1484:   TREE_VISITED (t) = 0;
1485:
1486:   if (TREE_CODE_CLASS (code) == tcc_declaration)
1487:     {
1488:       if (code == DEBUG_EXPR_DECL)
1489: 	DECL_UID (t) = --next_debug_decl_uid;
1490:       else
1491: 	{
1492: 	  DECL_UID (t) = allocate_decl_uid ();
1493: 	  if (DECL_PT_UID_SET_P (node))
1494: 	    SET_DECL_PT_UID (t, DECL_PT_UID (node));
1495: 	}
1496:       if ((TREE_CODE (node) == PARM_DECL || VAR_P (node))
1497: 	  && DECL_HAS_VALUE_EXPR_P (node))
1498: 	{
1499: 	  SET_DECL_VALUE_EXPR (t, DECL_VALUE_EXPR (node));
1500: 	  DECL_HAS_VALUE_EXPR_P (t) = 1;
1501: 	}
1502:       /* DECL_DEBUG_EXPR is copied explicitly by callers.  */
1503:       if (VAR_P (node))
1504: 	{
1505: 	  DECL_HAS_DEBUG_EXPR_P (t) = 0;
1506: 	  t->decl_with_vis.symtab_node = NULL;
1507: 	}
1508:       if (VAR_P (node) && DECL_HAS_INIT_PRIORITY_P (node))
1509: 	{
1510: 	  SET_DECL_INIT_PRIORITY (t, DECL_INIT_PRIORITY (node));
1511: 	  DECL_HAS_INIT_PRIORITY_P (t) = 1;
1512: 	}
1513:       if (TREE_CODE (node) == FUNCTION_DECL)
1514: 	{
1515: 	  DECL_STRUCT_FUNCTION (t) = NULL;
1516: 	  t->decl_with_vis.symtab_node = NULL;
1517: 	}
1518:     }
1519:   else if (TREE_CODE_CLASS (code) == tcc_type)
1520:     {
1521:       TYPE_UID (t) = next_type_uid++;
1522:       /* The following is so that the debug code for
1523: 	 the copy is different from the original type.
1524: 	 The two statements usually duplicate each other
1525: 	 (because they clear fields of the same union),
1526: 	 but the optimizer should catch that.  */
1527:       TYPE_SYMTAB_ADDRESS (t) = 0;
1528:       TYPE_SYMTAB_DIE (t) = 0;
1529:
1530:       /* Do not copy the values cache.  */
1531:       if (TYPE_CACHED_VALUES_P (t))
1532: 	{
1533: 	  TYPE_CACHED_VALUES_P (t) = 0;
1534: 	  TYPE_CACHED_VALUES (t) = NULL_TREE;
1535: 	}
1536:     }
1537:     else if (code == TARGET_OPTION_NODE)
1538:       {
1539: 	TREE_TARGET_OPTION (t) = ggc_alloc<struct cl_target_option>();
1540: 	memcpy (TREE_TARGET_OPTION (t), TREE_TARGET_OPTION (node),
1541: 		sizeof (struct cl_target_option));
1542:       }
1543:     else if (code == OPTIMIZATION_NODE)
1544:       {
1545: 	TREE_OPTIMIZATION (t) = ggc_alloc<struct cl_optimization>();
1546: 	memcpy (TREE_OPTIMIZATION (t), TREE_OPTIMIZATION (node),
1547: 		sizeof (struct cl_optimization));
```

## gcc/tree.cc:1581–1616
```text
1581: get_int_cst_ext_nunits (tree type, const wide_int &cst)
1582: {
1583:   gcc_checking_assert (cst.get_precision () == TYPE_PRECISION (type));
1584:   /* We need extra HWIs if CST is an unsigned integer with its
1585:      upper bit set.  */
1586:   if (TYPE_UNSIGNED (type) && wi::neg_p (cst))
1587:     return cst.get_precision () / HOST_BITS_PER_WIDE_INT + 1;
1588:   return cst.get_len ();
1589: }
1590:
1591: /* Return a new INTEGER_CST with value CST and type TYPE.  */
1592:
1593: static tree
1594: build_new_int_cst (tree type, const wide_int &cst)
1595: {
1596:   unsigned int len = cst.get_len ();
1597:   unsigned int ext_len = get_int_cst_ext_nunits (type, cst);
1598:   tree nt = make_int_cst (len, ext_len);
1599:
1600:   if (len < ext_len)
1601:     {
1602:       --ext_len;
1603:       TREE_INT_CST_ELT (nt, ext_len)
1604: 	= zext_hwi (-1, cst.get_precision () % HOST_BITS_PER_WIDE_INT);
1605:       for (unsigned int i = len; i < ext_len; ++i)
1606: 	TREE_INT_CST_ELT (nt, i) = -1;
1607:     }
1608:   else if (TYPE_UNSIGNED (type)
1609: 	   && cst.get_precision () < len * HOST_BITS_PER_WIDE_INT)
1610:     {
1611:       len--;
1612:       TREE_INT_CST_ELT (nt, len)
1613: 	= zext_hwi (cst.elt (len),
1614: 		    cst.get_precision () % HOST_BITS_PER_WIDE_INT);
1615:     }
1616:
```

## gcc/tree.cc:1696–1729
```text
1696: force_fit_type (tree type, const poly_wide_int_ref &cst,
1697: 		int overflowable, bool overflowed)
1698: {
1699:   signop sign = TYPE_SIGN (type);
1700:
1701:   /* If we need to set overflow flags, return a new unshared node.  */
1702:   if (overflowed || !wi::fits_to_tree_p (cst, type))
1703:     {
1704:       if (overflowed
1705: 	  || overflowable < 0
1706: 	  || (overflowable > 0 && sign == SIGNED))
1707: 	{
1708: 	  poly_wide_int tmp = poly_wide_int::from (cst, TYPE_PRECISION (type),
1709: 						   sign);
1710: 	  tree t;
1711: 	  if (tmp.is_constant ())
1712: 	    t = build_new_int_cst (type, tmp.coeffs[0]);
1713: 	  else
1714: 	    {
1715: 	      tree coeffs[NUM_POLY_INT_COEFFS];
1716: 	      for (unsigned int i = 0; i < NUM_POLY_INT_COEFFS; ++i)
1717: 		{
1718: 		  coeffs[i] = build_new_int_cst (type, tmp.coeffs[i]);
1719: 		  TREE_OVERFLOW (coeffs[i]) = 1;
1720: 		}
1721: 	      t = build_new_poly_int_cst (type, coeffs);
1722: 	    }
1723: 	  TREE_OVERFLOW (t) = 1;
1724: 	  return t;
1725: 	}
1726:     }
1727:
1728:   /* Else build a shared node.  */
1729:   return wide_int_to_tree (type, cst);
```

## gcc/tree.cc:1776–1953
```text
1776: cache_wide_int_in_type_cache (tree type, const wide_int &cst,
1777: 			      int slot, int max_slots)
1778: {
1779:   gcc_checking_assert (slot >= 0);
1780:   /* Initialize cache.  */
1781:   if (!TYPE_CACHED_VALUES_P (type))
1782:     {
1783:       TYPE_CACHED_VALUES_P (type) = 1;
1784:       TYPE_CACHED_VALUES (type) = make_tree_vec (max_slots);
1785:     }
1786:   tree t = TREE_VEC_ELT (TYPE_CACHED_VALUES (type), slot);
1787:   if (!t)
1788:     {
1789:       /* Create a new shared int.  */
1790:       t = build_new_int_cst (type, cst);
1791:       TREE_VEC_ELT (TYPE_CACHED_VALUES (type), slot) = t;
1792:     }
1793:   return t;
1794: }
1795:
1796: /* Create an INT_CST node of TYPE and value CST.
1797:    The returned node is always shared.  For small integers we use a
1798:    per-type vector cache, for larger ones we use a single hash table.
1799:    The value is extended from its precision according to the sign of
1800:    the type to be a multiple of HOST_BITS_PER_WIDE_INT.  This defines
1801:    the upper bits and ensures that hashing and value equality based
1802:    upon the underlying HOST_WIDE_INTs works without masking.  */
1803:
1804: static tree
1805: wide_int_to_tree_1 (tree type, const wide_int_ref &pcst)
1806: {
1807:   tree t;
1808:   int ix = -1;
1809:   int limit = 0;
1810:
1811:   gcc_assert (type);
1812:   unsigned int prec = TYPE_PRECISION (type);
1813:   signop sgn = TYPE_SIGN (type);
1814:
1815:   /* Verify that everything is canonical.  */
1816:   int l = pcst.get_len ();
1817:   if (l > 1)
1818:     {
1819:       if (pcst.elt (l - 1) == 0)
1820: 	gcc_checking_assert (pcst.elt (l - 2) < 0);
1821:       if (pcst.elt (l - 1) == HOST_WIDE_INT_M1)
1822: 	gcc_checking_assert (pcst.elt (l - 2) >= 0);
1823:     }
1824:
1825:   wide_int cst = wide_int::from (pcst, prec, sgn);
1826:   unsigned int ext_len = get_int_cst_ext_nunits (type, cst);
1827:
1828:   enum tree_code code = TREE_CODE (type);
1829:   if (code == POINTER_TYPE || code == REFERENCE_TYPE)
1830:     {
1831:       /* Cache NULL pointer and zero bounds.  */
1832:       if (cst == 0)
1833: 	ix = 0;
1834:       /* Cache upper bounds of pointers.  */
1835:       else if (cst == wi::max_value (prec, sgn))
1836: 	ix = 1;
1837:       /* Cache 1 which is used for a non-zero range.  */
1838:       else if (cst == 1)
1839: 	ix = 2;
1840:
1841:       if (ix >= 0)
1842: 	{
1843: 	  t = cache_wide_int_in_type_cache (type, cst, ix, 3);
1844: 	  /* Make sure no one is clobbering the shared constant.  */
1845: 	  gcc_checking_assert (TREE_TYPE (t) == type
1846: 			       && cst == wi::to_wide (t));
1847: 	  return t;
1848: 	}
1849:     }
1850:   if (ext_len == 1)
1851:     {
1852:       /* We just need to store a single HOST_WIDE_INT.  */
1853:       HOST_WIDE_INT hwi;
1854:       if (TYPE_UNSIGNED (type))
1855: 	hwi = cst.to_uhwi ();
1856:       else
1857: 	hwi = cst.to_shwi ();
1858:
1859:       switch (code)
1860: 	{
1861: 	case NULLPTR_TYPE:
1862: 	  gcc_assert (hwi == 0);
1863: 	  /* Fallthru.  */
1864:
1865: 	case POINTER_TYPE:
1866: 	case REFERENCE_TYPE:
1867: 	  /* Ignore pointers, as they were already handled above.  */
1868: 	  break;
1869:
1870: 	case BOOLEAN_TYPE:
1871: 	  /* Cache false or true.  */
1872: 	  limit = 2;
1873: 	  if (IN_RANGE (hwi, 0, 1))
1874: 	    ix = hwi;
1875: 	  break;
1876:
1877: 	case INTEGER_TYPE:
1878: 	case OFFSET_TYPE:
1879: 	case BITINT_TYPE:
1880: 	  if (TYPE_SIGN (type) == UNSIGNED)
1881: 	    {
1882: 	      /* Cache [0, N).  */
1883: 	      limit = param_integer_share_limit;
1884: 	      if (IN_RANGE (hwi, 0, param_integer_share_limit - 1))
1885: 		ix = hwi;
1886: 	    }
1887: 	  else
1888: 	    {
1889: 	      /* Cache [-1, N).  */
1890: 	      limit = param_integer_share_limit + 1;
1891: 	      if (IN_RANGE (hwi, -1, param_integer_share_limit - 1))
1892: 		ix = hwi + 1;
1893: 	    }
1894: 	  break;
1895:
1896: 	case ENUMERAL_TYPE:
1897: 	  break;
1898:
1899: 	default:
1900: 	  gcc_unreachable ();
1901: 	}
1902:
1903:       if (ix >= 0)
1904: 	{
1905: 	  t = cache_wide_int_in_type_cache (type, cst, ix, limit);
1906: 	  /* Make sure no one is clobbering the shared constant.  */
1907: 	  gcc_checking_assert (TREE_TYPE (t) == type
1908: 			       && TREE_INT_CST_NUNITS (t) == 1
1909: 			       && TREE_INT_CST_EXT_NUNITS (t) == 1
1910: 			       && TREE_INT_CST_ELT (t, 0) == hwi);
1911: 	  return t;
1912: 	}
1913:       else
1914: 	{
1915: 	  /* Use the cache of larger shared ints, using int_cst_node as
1916: 	     a temporary.  */
1917:
1918: 	  TREE_INT_CST_ELT (int_cst_node, 0) = hwi;
1919: 	  TREE_TYPE (int_cst_node) = type;
1920:
1921: 	  tree *slot = int_cst_hash_table->find_slot (int_cst_node, INSERT);
1922: 	  t = *slot;
1923: 	  if (!t)
1924: 	    {
1925: 	      /* Insert this one into the hash table.  */
1926: 	      t = int_cst_node;
1927: 	      *slot = t;
1928: 	      /* Make a new node for next time round.  */
1929: 	      int_cst_node = make_int_cst (1, 1);
1930: 	    }
1931: 	}
1932:     }
1933:   else
1934:     {
1935:       /* The value either hashes properly or we drop it on the floor
1936: 	 for the gc to take care of.  There will not be enough of them
1937: 	 to worry about.  */
1938:
1939:       tree nt = build_new_int_cst (type, cst);
1940:       tree *slot = int_cst_hash_table->find_slot (nt, INSERT);
1941:       t = *slot;
1942:       if (!t)
1943: 	{
1944: 	  /* Insert this one into the hash table.  */
1945: 	  t = nt;
1946: 	  *slot = t;
1947: 	}
1948:       else
1949: 	ggc_free (nt);
1950:     }
1951:
1952:   return t;
1953: }
```

## gcc/tree.cc:2008–2013
```text
2008: wide_int_to_tree (tree type, const poly_wide_int_ref &value)
2009: {
2010:   if (value.is_constant ())
2011:     return wide_int_to_tree_1 (type, value.coeffs[0]);
2012:   return build_poly_int_cst (type, value);
2013: }
```

## gcc/tree.cc:2482–2488
```text
2482: build_clobber (tree type, enum clobber_kind kind)
2483: {
2484:   tree clobber = build_constructor (type, NULL);
2485:   TREE_THIS_VOLATILE (clobber) = true;
2486:   CLOBBER_KIND (clobber) = kind;
2487:   return clobber;
2488: }
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

## gcc/tree.cc:2926–2960
```text
2926: make_int_cst (int len, int ext_len MEM_STAT_DECL)
2927: {
2928:   tree t;
2929:   int length = ((ext_len - 1) * sizeof (HOST_WIDE_INT)
2930: 		+ sizeof (struct tree_int_cst));
2931:
2932:   gcc_assert (len);
2933:   record_node_allocation_statistics (INTEGER_CST, length);
2934:
2935:   t = ggc_alloc_cleared_tree_node_stat (length PASS_MEM_STAT);
2936:
2937:   TREE_SET_CODE (t, INTEGER_CST);
2938:   TREE_INT_CST_NUNITS (t) = len;
2939:   TREE_INT_CST_EXT_NUNITS (t) = ext_len;
2940:   TREE_CONSTANT (t) = 1;
2941:
2942:   return t;
2943: }
2944:
2945: /* Build a newly constructed TREE_VEC node of length LEN.  */
2946:
2947: tree
2948: make_tree_vec (int len MEM_STAT_DECL)
2949: {
2950:   tree t;
2951:   size_t length = (len - 1) * sizeof (tree) + sizeof (struct tree_vec);
2952:
2953:   record_node_allocation_statistics (TREE_VEC, length);
2954:
2955:   t = ggc_alloc_cleared_tree_node_stat (length PASS_MEM_STAT);
2956:
2957:   TREE_SET_CODE (t, TREE_VEC);
2958:   TREE_VEC_LENGTH (t) = len;
2959:
2960:   return t;
```

## gcc/tree.cc:3834–3872
```text
3834: }
3835:
3836: /* Return, as a tree node, the number of elements for TYPE (which is an
3837:    ARRAY_TYPE) minus one.  This counts only elements of the top array.  */
3838:
3839: tree
3840: array_type_nelts_minus_one (const_tree type)
3841: {
3842:   tree index_type, min, max;
3843:
3844:   /* If they did it with unspecified bounds, then we should have already
3845:      given an error about it before we got here.  */
3846:   if (! TYPE_DOMAIN (type))
3847:     return error_mark_node;
3848:
3849:   index_type = TYPE_DOMAIN (type);
3850:   min = TYPE_MIN_VALUE (index_type);
3851:   max = TYPE_MAX_VALUE (index_type);
3852:
3853:   /* TYPE_MAX_VALUE may not be set if the array has unknown length.  */
3854:   if (!max)
3855:     {
3856:       /* zero sized arrays are represented from C FE as complete types with
3857: 	 NULL TYPE_MAX_VALUE and zero TYPE_SIZE, while C++ FE represents
3858: 	 them as min 0, max -1.  */
3859:       if (COMPLETE_TYPE_P (type)
3860: 	  && integer_zerop (TYPE_SIZE (type))
3861: 	  && integer_zerop (min))
3862: 	return build_int_cst (TREE_TYPE (min), -1);
3863:
3864:       return error_mark_node;
3865:     }
3866:
3867:   return (integer_zerop (min)
3868: 	  ? max
3869: 	  : fold_build2 (MINUS_EXPR, TREE_TYPE (max), max, min));
3870: }
3871:
3872: /* Return, as an INTEGER_CST node, the number of elements for TYPE
```

## gcc/tree.cc:4132–4170
```text
4132: save_expr (tree expr)
4133: {
4134:   tree inner;
4135:
4136:   /* If the tree evaluates to a constant, then we don't want to hide that
4137:      fact (i.e. this allows further folding, and direct checks for constants).
4138:      However, a read-only object that has side effects cannot be bypassed.
4139:      Since it is no problem to reevaluate literals, we just return the
4140:      literal node.  */
4141:   inner = skip_simple_arithmetic (expr);
4142:   if (TREE_CODE (inner) == ERROR_MARK)
4143:     return inner;
4144:
4145:   if (tree_invariant_p_1 (inner))
4146:     return expr;
4147:
4148:   /* If INNER contains a PLACEHOLDER_EXPR, we must evaluate it each time, since
4149:      it means that the size or offset of some field of an object depends on
4150:      the value within another field.
4151:
4152:      Note that it must not be the case that EXPR contains both a PLACEHOLDER_EXPR
4153:      and some variable since it would then need to be both evaluated once and
4154:      evaluated more than once.  Front-ends must assure this case cannot
4155:      happen by surrounding any such subexpressions in their own SAVE_EXPR
4156:      and forcing evaluation at the proper time.  */
4157:   if (contains_placeholder_p (inner))
4158:     return expr;
4159:
4160:   expr = build1_loc (EXPR_LOCATION (expr), SAVE_EXPR, TREE_TYPE (expr), expr);
4161:
4162:   /* This expression might be placed ahead of a jump to ensure that the
4163:      value was computed on both sides of the jump.  So make sure it isn't
4164:      eliminated as dead.  */
4165:   TREE_SIDE_EFFECTS (expr) = 1;
4166:   return expr;
4167: }
4168:
4169: /* Look inside EXPR into any simple arithmetic operations.  Return the
4170:    outermost non-arithmetic or non-invariant node.  */
```

## gcc/tree.cc:4220–4243
```text
4220: skip_simple_constant_arithmetic (tree expr)
4221: {
4222:   while (TREE_CODE (expr) == NON_LVALUE_EXPR)
4223:     expr = TREE_OPERAND (expr, 0);
4224:
4225:   while (true)
4226:     {
4227:       if (UNARY_CLASS_P (expr))
4228: 	expr = TREE_OPERAND (expr, 0);
4229:       else if (BINARY_CLASS_P (expr))
4230: 	{
4231: 	  if (TREE_CONSTANT (TREE_OPERAND (expr, 1)))
4232: 	    expr = TREE_OPERAND (expr, 0);
4233: 	  else if (TREE_CONSTANT (TREE_OPERAND (expr, 0)))
4234: 	    expr = TREE_OPERAND (expr, 1);
4235: 	  else
4236: 	    break;
4237: 	}
4238:       else
4239: 	break;
4240:     }
4241:
4242:   return expr;
4243: }
```

## gcc/tree.cc:4257–4377
```text
4257: process_call_operands (tree t)
4258: {
4259:   bool side_effects = TREE_SIDE_EFFECTS (t);
4260:   bool read_only = false;
4261:   int i = call_expr_flags (t);
4262:
4263:   /* Calls have side-effects, except those to const or pure functions.  */
4264:   if ((i & ECF_LOOPING_CONST_OR_PURE) || !(i & (ECF_CONST | ECF_PURE)))
4265:     side_effects = true;
4266:   /* Propagate TREE_READONLY of arguments for const functions.  */
4267:   if (i & ECF_CONST)
4268:     read_only = true;
4269:
4270:   if (!side_effects || read_only)
4271:     for (i = 1; i < TREE_OPERAND_LENGTH (t); i++)
4272:       {
4273: 	tree op = TREE_OPERAND (t, i);
4274: 	if (op && TREE_SIDE_EFFECTS (op))
4275: 	  side_effects = true;
4276: 	if (op && !TREE_READONLY (op) && !CONSTANT_CLASS_P (op))
4277: 	  read_only = false;
4278:       }
4279:
4280:   TREE_SIDE_EFFECTS (t) = side_effects;
4281:   TREE_READONLY (t) = read_only;
4282: }
4283:
4284: /* Return true if EXP contains a PLACEHOLDER_EXPR, i.e. if it represents a
4285:    size or offset that depends on a field within a record.  */
4286:
4287: bool
4288: contains_placeholder_p (const_tree exp)
4289: {
4290:   enum tree_code code;
4291:
4292:   if (!exp)
4293:     return false;
4294:
4295:   code = TREE_CODE (exp);
4296:   if (code == PLACEHOLDER_EXPR)
4297:     return true;
4298:
4299:   switch (TREE_CODE_CLASS (code))
4300:     {
4301:     case tcc_reference:
4302:       /* Don't look at any PLACEHOLDER_EXPRs that might be in index or bit
4303: 	 position computations since they will be converted into a
4304: 	 WITH_RECORD_EXPR involving the reference, which will assume
4305: 	 here will be valid.  */
4306:       return CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 0));
4307:
4308:     case tcc_exceptional:
4309:       if (code == TREE_LIST)
4310: 	return (CONTAINS_PLACEHOLDER_P (TREE_VALUE (exp))
4311: 		|| CONTAINS_PLACEHOLDER_P (TREE_CHAIN (exp)));
4312:       break;
4313:
4314:     case tcc_unary:
4315:     case tcc_binary:
4316:     case tcc_comparison:
4317:     case tcc_expression:
4318:       switch (code)
4319: 	{
4320: 	case COMPOUND_EXPR:
4321: 	  /* Ignoring the first operand isn't quite right, but works best.  */
4322: 	  return CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 1));
4323:
4324: 	case COND_EXPR:
4325: 	  return (CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 0))
4326: 		  || CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 1))
4327: 		  || CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 2)));
4328:
4329: 	case SAVE_EXPR:
4330: 	  /* The save_expr function never wraps anything containing
4331: 	     a PLACEHOLDER_EXPR. */
4332: 	  return false;
4333:
4334: 	default:
4335: 	  break;
4336: 	}
4337:
4338:       switch (TREE_CODE_LENGTH (code))
4339: 	{
4340: 	case 1:
4341: 	  return CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 0));
4342: 	case 2:
4343: 	  return (CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 0))
4344: 		  || CONTAINS_PLACEHOLDER_P (TREE_OPERAND (exp, 1)));
4345: 	default:
4346: 	  return false;
4347: 	}
4348:
4349:     case tcc_vl_exp:
4350:       switch (code)
4351: 	{
4352: 	case CALL_EXPR:
4353: 	  {
4354: 	    const_tree arg;
4355: 	    const_call_expr_arg_iterator iter;
4356: 	    FOR_EACH_CONST_CALL_EXPR_ARG (arg, iter, exp)
4357: 	      if (CONTAINS_PLACEHOLDER_P (arg))
4358: 		return true;
4359: 	    return false;
4360: 	  }
4361: 	default:
4362: 	  return false;
4363: 	}
4364:
4365:     default:
4366:       return false;
4367:     }
4368:   return false;
4369: }
4370:
4371: /* Return true if any part of the structure of TYPE involves a PLACEHOLDER_EXPR
4372:    directly.  This includes size, bounds, qualifiers (for QUAL_UNION_TYPE) and
4373:    field positions.  */
4374:
4375: static bool
4376: type_contains_placeholder_1 (const_tree type)
4377: {
```

## gcc/tree.cc:4480–4740
```text
4480: }
4481:
4482: /* Given a tree EXP, find all occurrences of references to fields
4483:    in a PLACEHOLDER_EXPR and place them in vector REFS without
4484:    duplicates.  Also record VAR_DECLs and CONST_DECLs.  Note that
4485:    we assume here that EXP contains only arithmetic expressions
4486:    or CALL_EXPRs with PLACEHOLDER_EXPRs occurring only in their
4487:    argument list.  */
4488:
4489: void
4490: find_placeholder_in_expr (tree exp, vec<tree> *refs)
4491: {
4492:   enum tree_code code = TREE_CODE (exp);
4493:   tree inner;
4494:   int i;
4495:
4496:   /* We handle TREE_LIST and COMPONENT_REF separately.  */
4497:   if (code == TREE_LIST)
4498:     {
4499:       FIND_PLACEHOLDER_IN_EXPR (TREE_CHAIN (exp), refs);
4500:       FIND_PLACEHOLDER_IN_EXPR (TREE_VALUE (exp), refs);
4501:     }
4502:   else if (code == COMPONENT_REF)
4503:     {
4504:       for (inner = TREE_OPERAND (exp, 0);
4505: 	   REFERENCE_CLASS_P (inner);
4506: 	   inner = TREE_OPERAND (inner, 0))
4507: 	;
4508:
4509:       if (TREE_CODE (inner) == PLACEHOLDER_EXPR)
4510: 	push_without_duplicates (exp, refs);
4511:       else
4512: 	FIND_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 0), refs);
4513:    }
4514:   else
4515:     switch (TREE_CODE_CLASS (code))
4516:       {
4517:       case tcc_constant:
4518: 	break;
4519:
4520:       case tcc_declaration:
4521: 	/* Variables allocated to static storage can stay.  */
4522:         if (!TREE_STATIC (exp))
4523: 	  push_without_duplicates (exp, refs);
4524: 	break;
4525:
4526:       case tcc_expression:
4527: 	/* This is the pattern built in ada/make_aligning_type.  */
4528: 	if (code == ADDR_EXPR
4529: 	    && TREE_CODE (TREE_OPERAND (exp, 0)) == PLACEHOLDER_EXPR)
4530: 	  {
4531: 	    push_without_duplicates (exp, refs);
4532: 	    break;
4533: 	  }
4534:
4535:         /* Fall through.  */
4536:
4537:       case tcc_exceptional:
4538:       case tcc_unary:
4539:       case tcc_binary:
4540:       case tcc_comparison:
4541:       case tcc_reference:
4542: 	for (i = 0; i < TREE_CODE_LENGTH (code); i++)
4543: 	  FIND_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, i), refs);
4544: 	break;
4545:
4546:       case tcc_vl_exp:
4547: 	for (i = 1; i < TREE_OPERAND_LENGTH (exp); i++)
4548: 	  FIND_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, i), refs);
4549: 	break;
4550:
4551:       default:
4552: 	gcc_unreachable ();
4553:       }
4554: }
4555:
4556: /* Given a tree EXP, a FIELD_DECL F, and a replacement value R,
4557:    return a tree with all occurrences of references to F in a
4558:    PLACEHOLDER_EXPR replaced by R.  Also handle VAR_DECLs and
4559:    CONST_DECLs.  Note that we assume here that EXP contains only
4560:    arithmetic expressions or CALL_EXPRs with PLACEHOLDER_EXPRs
4561:    occurring only in their argument list.  */
4562:
4563: tree
4564: substitute_in_expr (tree exp, tree f, tree r)
4565: {
4566:   enum tree_code code = TREE_CODE (exp);
4567:   tree op0, op1, op2, op3;
4568:   tree new_tree;
4569:
4570:   /* We handle TREE_LIST and COMPONENT_REF separately.  */
4571:   if (code == TREE_LIST)
4572:     {
4573:       op0 = SUBSTITUTE_IN_EXPR (TREE_CHAIN (exp), f, r);
4574:       op1 = SUBSTITUTE_IN_EXPR (TREE_VALUE (exp), f, r);
4575:       if (op0 == TREE_CHAIN (exp) && op1 == TREE_VALUE (exp))
4576: 	return exp;
4577:
4578:       return tree_cons (TREE_PURPOSE (exp), op1, op0);
4579:     }
4580:   else if (code == COMPONENT_REF)
4581:     {
4582:       tree inner;
4583:
4584:       /* If this expression is getting a value from a PLACEHOLDER_EXPR
4585: 	 and it is the right field, replace it with R.  */
4586:       for (inner = TREE_OPERAND (exp, 0);
4587: 	   REFERENCE_CLASS_P (inner);
4588: 	   inner = TREE_OPERAND (inner, 0))
4589: 	;
4590:
4591:       /* The field.  */
4592:       op1 = TREE_OPERAND (exp, 1);
4593:
4594:       if (TREE_CODE (inner) == PLACEHOLDER_EXPR && op1 == f)
4595: 	return r;
4596:
4597:       /* If this expression hasn't been completed let, leave it alone.  */
4598:       if (TREE_CODE (inner) == PLACEHOLDER_EXPR && !TREE_TYPE (inner))
4599: 	return exp;
4600:
4601:       op0 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 0), f, r);
4602:       if (op0 == TREE_OPERAND (exp, 0))
4603: 	return exp;
4604:
4605:       new_tree
4606: 	= fold_build3 (COMPONENT_REF, TREE_TYPE (exp), op0, op1, NULL_TREE);
4607:    }
4608:   else
4609:     switch (TREE_CODE_CLASS (code))
4610:       {
4611:       case tcc_constant:
4612: 	return exp;
4613:
4614:       case tcc_declaration:
4615: 	if (exp == f)
4616: 	  return r;
4617: 	else
4618: 	  return exp;
4619:
4620:       case tcc_expression:
4621: 	if (exp == f)
4622: 	  return r;
4623:
4624:         /* Fall through.  */
4625:
4626:       case tcc_exceptional:
4627:       case tcc_unary:
4628:       case tcc_binary:
4629:       case tcc_comparison:
4630:       case tcc_reference:
4631: 	switch (TREE_CODE_LENGTH (code))
4632: 	  {
4633: 	  case 0:
4634: 	    return exp;
4635:
4636: 	  case 1:
4637: 	    op0 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 0), f, r);
4638: 	    if (op0 == TREE_OPERAND (exp, 0))
4639: 	      return exp;
4640:
4641: 	    new_tree = fold_build1 (code, TREE_TYPE (exp), op0);
4642: 	    break;
4643:
4644: 	  case 2:
4645: 	    op0 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 0), f, r);
4646: 	    op1 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 1), f, r);
4647:
4648: 	    if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1))
4649: 	      return exp;
4650:
4651: 	    new_tree = fold_build2 (code, TREE_TYPE (exp), op0, op1);
4652: 	    break;
4653:
4654: 	  case 3:
4655: 	    op0 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 0), f, r);
4656: 	    op1 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 1), f, r);
4657: 	    op2 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 2), f, r);
4658:
4659: 	    if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1)
4660: 		&& op2 == TREE_OPERAND (exp, 2))
4661: 	      return exp;
4662:
4663: 	    new_tree = fold_build3 (code, TREE_TYPE (exp), op0, op1, op2);
4664: 	    break;
4665:
4666: 	  case 4:
4667: 	    op0 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 0), f, r);
4668: 	    op1 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 1), f, r);
4669: 	    op2 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 2), f, r);
4670: 	    op3 = SUBSTITUTE_IN_EXPR (TREE_OPERAND (exp, 3), f, r);
4671:
4672: 	    if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1)
4673: 		&& op2 == TREE_OPERAND (exp, 2)
4674: 		&& op3 == TREE_OPERAND (exp, 3))
4675: 	      return exp;
4676:
4677: 	    new_tree
4678: 	      = fold (build4 (code, TREE_TYPE (exp), op0, op1, op2, op3));
4679: 	    break;
4680:
4681: 	  default:
4682: 	    gcc_unreachable ();
4683: 	  }
4684: 	break;
4685:
4686:       case tcc_vl_exp:
4687: 	{
4688: 	  int i;
4689:
4690: 	  new_tree = NULL_TREE;
4691:
4692: 	  /* If we are trying to replace F with a constant or with another
4693: 	     instance of one of the arguments of the call, inline back
4694: 	     functions which do nothing else than computing a value from
4695: 	     the arguments they are passed.  This makes it possible to
4696: 	     fold partially or entirely the replacement expression.  */
4697: 	  if (code == CALL_EXPR)
4698: 	    {
4699: 	      bool maybe_inline = false;
4700: 	      if (CONSTANT_CLASS_P (r))
4701: 		maybe_inline = true;
4702: 	      else
4703: 		for (i = 3; i < TREE_OPERAND_LENGTH (exp); i++)
4704: 		  if (operand_equal_p (TREE_OPERAND (exp, i), r, 0))
4705: 		    {
4706: 		      maybe_inline = true;
4707: 		      break;
4708: 		    }
4709: 	      if (maybe_inline)
4710: 		{
4711: 		  tree t = maybe_inline_call_in_expr (exp);
4712: 		  if (t)
4713: 		    return SUBSTITUTE_IN_EXPR (t, f, r);
4714: 		}
4715: 	    }
4716:
4717: 	  for (i = 1; i < TREE_OPERAND_LENGTH (exp); i++)
4718: 	    {
4719: 	      tree op = TREE_OPERAND (exp, i);
4720: 	      tree new_op = SUBSTITUTE_IN_EXPR (op, f, r);
4721: 	      if (new_op != op)
4722: 		{
4723: 		  if (!new_tree)
4724: 		    new_tree = copy_node (exp);
4725: 		  TREE_OPERAND (new_tree, i) = new_op;
4726: 		}
4727: 	    }
4728:
4729: 	  if (new_tree)
4730: 	    {
4731: 	      new_tree = fold (new_tree);
4732: 	      if (TREE_CODE (new_tree) == CALL_EXPR)
4733: 		process_call_operands (new_tree);
4734: 	    }
4735: 	  else
4736: 	    return exp;
4737: 	}
4738: 	break;
4739:
4740:       default:
```

## gcc/tree.cc:4756–4932
```text
4756: substitute_placeholder_in_expr (tree exp, tree obj)
4757: {
4758:   enum tree_code code = TREE_CODE (exp);
4759:   tree op0, op1, op2, op3;
4760:   tree new_tree;
4761:
4762:   /* If this is a PLACEHOLDER_EXPR, see if we find a corresponding type
4763:      in the chain of OBJ.  */
4764:   if (code == PLACEHOLDER_EXPR)
4765:     {
4766:       tree need_type = TYPE_MAIN_VARIANT (TREE_TYPE (exp));
4767:       tree elt;
4768:
4769:       for (elt = obj; elt != 0;
4770: 	   elt = ((TREE_CODE (elt) == COMPOUND_EXPR
4771: 		   || TREE_CODE (elt) == COND_EXPR)
4772: 		  ? TREE_OPERAND (elt, 1)
4773: 		  : (REFERENCE_CLASS_P (elt)
4774: 		     || UNARY_CLASS_P (elt)
4775: 		     || BINARY_CLASS_P (elt)
4776: 		     || VL_EXP_CLASS_P (elt)
4777: 		     || EXPRESSION_CLASS_P (elt))
4778: 		  ? TREE_OPERAND (elt, 0) : 0))
4779: 	if (TYPE_MAIN_VARIANT (TREE_TYPE (elt)) == need_type)
4780: 	  return elt;
4781:
4782:       for (elt = obj; elt != 0;
4783: 	   elt = ((TREE_CODE (elt) == COMPOUND_EXPR
4784: 		   || TREE_CODE (elt) == COND_EXPR)
4785: 		  ? TREE_OPERAND (elt, 1)
4786: 		  : (REFERENCE_CLASS_P (elt)
4787: 		     || UNARY_CLASS_P (elt)
4788: 		     || BINARY_CLASS_P (elt)
4789: 		     || VL_EXP_CLASS_P (elt)
4790: 		     || EXPRESSION_CLASS_P (elt))
4791: 		  ? TREE_OPERAND (elt, 0) : 0))
4792: 	if (POINTER_TYPE_P (TREE_TYPE (elt))
4793: 	    && (TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (elt)))
4794: 		== need_type))
4795: 	  return fold_build1 (INDIRECT_REF, need_type, elt);
4796:
4797:       /* If we didn't find it, return the original PLACEHOLDER_EXPR.  If it
4798: 	 survives until RTL generation, there will be an error.  */
4799:       return exp;
4800:     }
4801:
4802:   /* TREE_LIST is special because we need to look at TREE_VALUE
4803:      and TREE_CHAIN, not TREE_OPERANDS.  */
4804:   else if (code == TREE_LIST)
4805:     {
4806:       op0 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_CHAIN (exp), obj);
4807:       op1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_VALUE (exp), obj);
4808:       if (op0 == TREE_CHAIN (exp) && op1 == TREE_VALUE (exp))
4809: 	return exp;
4810:
4811:       return tree_cons (TREE_PURPOSE (exp), op1, op0);
4812:     }
4813:   else
4814:     switch (TREE_CODE_CLASS (code))
4815:       {
4816:       case tcc_constant:
4817:       case tcc_declaration:
4818: 	return exp;
4819:
4820:       case tcc_exceptional:
4821:       case tcc_unary:
4822:       case tcc_binary:
4823:       case tcc_comparison:
4824:       case tcc_expression:
4825:       case tcc_reference:
4826:       case tcc_statement:
4827: 	switch (TREE_CODE_LENGTH (code))
4828: 	  {
4829: 	  case 0:
4830: 	    return exp;
4831:
4832: 	  case 1:
4833: 	    op0 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 0), obj);
4834: 	    if (op0 == TREE_OPERAND (exp, 0))
4835: 	      return exp;
4836:
4837: 	    new_tree = fold_build1 (code, TREE_TYPE (exp), op0);
4838: 	    break;
4839:
4840: 	  case 2:
4841: 	    op0 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 0), obj);
4842: 	    op1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 1), obj);
4843:
4844: 	    if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1))
4845: 	      return exp;
4846:
4847: 	    new_tree = fold_build2 (code, TREE_TYPE (exp), op0, op1);
4848: 	    break;
4849:
4850: 	  case 3:
4851: 	    op0 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 0), obj);
4852: 	    op1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 1), obj);
4853: 	    op2 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 2), obj);
4854:
4855: 	    if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1)
4856: 		&& op2 == TREE_OPERAND (exp, 2))
4857: 	      return exp;
4858:
4859: 	    new_tree = fold_build3 (code, TREE_TYPE (exp), op0, op1, op2);
4860: 	    break;
4861:
4862: 	  case 4:
4863: 	    op0 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 0), obj);
4864: 	    op1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 1), obj);
4865: 	    op2 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 2), obj);
4866: 	    op3 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (TREE_OPERAND (exp, 3), obj);
4867:
4868: 	    if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1)
4869: 		&& op2 == TREE_OPERAND (exp, 2)
4870: 		&& op3 == TREE_OPERAND (exp, 3))
4871: 	      return exp;
4872:
4873: 	    new_tree
4874: 	      = fold (build4 (code, TREE_TYPE (exp), op0, op1, op2, op3));
4875: 	    break;
4876:
4877: 	  default:
4878: 	    gcc_unreachable ();
4879: 	  }
4880: 	break;
4881:
4882:       case tcc_vl_exp:
4883: 	{
4884: 	  int i;
4885:
4886: 	  new_tree = NULL_TREE;
4887:
4888: 	  for (i = 1; i < TREE_OPERAND_LENGTH (exp); i++)
4889: 	    {
4890: 	      tree op = TREE_OPERAND (exp, i);
4891: 	      tree new_op = SUBSTITUTE_PLACEHOLDER_IN_EXPR (op, obj);
4892: 	      if (new_op != op)
4893: 		{
4894: 		  if (!new_tree)
4895: 		    new_tree = copy_node (exp);
4896: 		  TREE_OPERAND (new_tree, i) = new_op;
4897: 		}
4898: 	    }
4899:
4900: 	  if (new_tree)
4901: 	    {
4902: 	      new_tree = fold (new_tree);
4903: 	      if (TREE_CODE (new_tree) == CALL_EXPR)
4904: 		process_call_operands (new_tree);
4905: 	    }
4906: 	  else
4907: 	    return exp;
4908: 	}
4909: 	break;
4910:
4911:       default:
4912: 	gcc_unreachable ();
4913:       }
4914:
4915:   TREE_READONLY (new_tree) |= TREE_READONLY (exp);
4916:
4917:   if (code == INDIRECT_REF || code == ARRAY_REF || code == ARRAY_RANGE_REF)
4918:     TREE_THIS_NOTRAP (new_tree) |= TREE_THIS_NOTRAP (exp);
4919:
4920:   return new_tree;
4921: }
4922:
4923:
4924: /* Subroutine of stabilize_reference; this is called for subtrees of
4925:    references.  Any expression with side-effects must be put in a SAVE_EXPR
4926:    to ensure that it is only evaluated once.
4927:
4928:    We don't put SAVE_EXPR nodes around everything, because assigning very
4929:    simple expressions to temporaries causes us to miss good opportunities
4930:    for optimizations.  Among other things, the opportunity to fold in the
4931:    addition of a constant into an addressing mode often gets lost, e.g.
4932:    "y[i+1] += x;".  In general, we take the approach that we should not make
```

## gcc/tree.cc:5567–5587
```text
5567: build_decl (location_t loc, enum tree_code code, tree name,
5568:     		 tree type MEM_STAT_DECL)
5569: {
5570:   tree t;
5571:
5572:   t = make_node (code PASS_MEM_STAT);
5573:   DECL_SOURCE_LOCATION (t) = loc;
5574:
5575: /*  if (type == error_mark_node)
5576:     type = integer_type_node; */
5577: /* That is not done, deliberately, so that having error_mark_node
5578:    as the type can suppress useless errors in the use of this variable.  */
5579:
5580:   DECL_NAME (t) = name;
5581:   TREE_TYPE (t) = type;
5582:
5583:   if (code == VAR_DECL || code == PARM_DECL || code == RESULT_DECL)
5584:     layout_decl (t, 0);
5585:
5586:   return t;
5587: }
```

## gcc/tree.cc:5840–5965
```text
5840: build_qualified_type (tree type, int type_quals MEM_STAT_DECL)
5841: {
5842:   tree t;
5843:
5844:   /* See if we already have the appropriate qualified variant.  */
5845:   t = get_qualified_type (type, type_quals);
5846:
5847:   /* If not, build it.  */
5848:   if (!t)
5849:     {
5850:       t = build_variant_type_copy (type PASS_MEM_STAT);
5851:       set_type_quals (t, type_quals);
5852:
5853:       if (((type_quals & TYPE_QUAL_ATOMIC) == TYPE_QUAL_ATOMIC))
5854: 	{
5855: 	  /* See if this object can map to a basic atomic type.  */
5856: 	  tree atomic_type = find_atomic_core_type (type);
5857: 	  if (atomic_type)
5858: 	    {
5859: 	      /* Ensure the alignment of this type is compatible with
5860: 		 the required alignment of the atomic type.  */
5861: 	      if (TYPE_ALIGN (atomic_type) > TYPE_ALIGN (t))
5862: 		SET_TYPE_ALIGN (t, TYPE_ALIGN (atomic_type));
5863: 	    }
5864: 	}
5865:
5866:       if (TYPE_STRUCTURAL_EQUALITY_P (type))
5867: 	/* Propagate structural equality. */
5868: 	SET_TYPE_STRUCTURAL_EQUALITY (t);
5869:       else if (TYPE_CANONICAL (type) != type)
5870: 	/* Build the underlying canonical type, since it is different
5871: 	   from TYPE. */
5872: 	{
5873: 	  tree c = build_qualified_type (TYPE_CANONICAL (type), type_quals);
5874: 	  TYPE_CANONICAL (t) = TYPE_CANONICAL (c);
5875: 	}
5876:       else
5877: 	/* T is its own canonical type. */
5878: 	TYPE_CANONICAL (t) = t;
5879:
5880:     }
5881:
5882:   return t;
5883: }
5884:
5885: /* Create a variant of type T with alignment ALIGN which
5886:    is measured in bits.  */
5887:
5888: tree
5889: build_aligned_type (tree type, unsigned int align)
5890: {
5891:   tree t;
5892:
5893:   if (TYPE_PACKED (type)
5894:       || TYPE_ALIGN (type) == align)
5895:     return type;
5896:
5897:   for (t = TYPE_MAIN_VARIANT (type); t; t = TYPE_NEXT_VARIANT (t))
5898:     if (check_aligned_type (t, type, align))
5899:       return t;
5900:
5901:   t = build_variant_type_copy (type);
5902:   SET_TYPE_ALIGN (t, align);
5903:   TYPE_USER_ALIGN (t) = 1;
5904:
5905:   return t;
5906: }
5907:
5908: /* Create a new distinct copy of TYPE.  The new type is made its own
5909:    MAIN_VARIANT. If TYPE requires structural equality checks, the
5910:    resulting type requires structural equality checks; otherwise, its
5911:    TYPE_CANONICAL points to itself. */
5912:
5913: tree
5914: build_distinct_type_copy (tree type MEM_STAT_DECL)
5915: {
5916:   tree t = copy_node (type PASS_MEM_STAT);
5917:
5918:   TYPE_POINTER_TO (t) = 0;
5919:   TYPE_REFERENCE_TO (t) = 0;
5920:
5921:   /* Set the canonical type either to a new equivalence class, or
5922:      propagate the need for structural equality checks. */
5923:   if (TYPE_STRUCTURAL_EQUALITY_P (type))
5924:     SET_TYPE_STRUCTURAL_EQUALITY (t);
5925:   else
5926:     TYPE_CANONICAL (t) = t;
5927:
5928:   /* Make it its own variant.  */
5929:   TYPE_MAIN_VARIANT (t) = t;
5930:   TYPE_NEXT_VARIANT (t) = 0;
5931:
5932:   /* Note that it is now possible for TYPE_MIN_VALUE to be a value
5933:      whose TREE_TYPE is not t.  This can also happen in the Ada
5934:      frontend when using subtypes.  */
5935:
5936:   return t;
5937: }
5938:
5939: /* Create a new variant of TYPE, equivalent but distinct.  This is so
5940:    the caller can modify it. TYPE_CANONICAL for the return type will
5941:    be equivalent to TYPE_CANONICAL of TYPE, indicating that the types
5942:    are considered equal by the language itself (or that both types
5943:    require structural equality checks). */
5944:
5945: tree
5946: build_variant_type_copy (tree type MEM_STAT_DECL)
5947: {
5948:   tree t, m = TYPE_MAIN_VARIANT (type);
5949:
5950:   t = build_distinct_type_copy (type PASS_MEM_STAT);
5951:
5952:   /* Since we're building a variant, assume that it is a non-semantic
5953:      variant.  This also propagates TYPE_STRUCTURAL_EQUALITY_P. */
5954:   TYPE_CANONICAL (t) = TYPE_CANONICAL (type);
5955:   /* Type variants have no alias set defined.  */
5956:   TYPE_ALIAS_SET (t) = -1;
5957:
5958:   /* Add the new type to the chain of variants of TYPE.  */
5959:   TYPE_NEXT_VARIANT (t) = TYPE_NEXT_VARIANT (m);
5960:   TYPE_NEXT_VARIANT (m) = t;
5961:   TYPE_MAIN_VARIANT (t) = m;
5962:
5963:   return t;
5964: }
5965:
```

## gcc/tree.cc:6433–6492
```text
6433: type_hash_canon (unsigned int hashcode, tree type)
6434: {
6435:   type_hash in;
6436:   type_hash **loc;
6437:
6438:   /* The hash table only contains main variants, so ensure that's what we're
6439:      being passed.  */
6440:   gcc_assert (TYPE_MAIN_VARIANT (type) == type);
6441:
6442:   /* The TYPE_ALIGN field of a type is set by layout_type(), so we
6443:      must call that routine before comparing TYPE_ALIGNs.  */
6444:   layout_type (type);
6445:
6446:   in.hash = hashcode;
6447:   in.type = type;
6448:
6449:   loc = type_hash_table->find_slot_with_hash (&in, hashcode, INSERT);
6450:   if (*loc)
6451:     {
6452:       tree t1 = ((type_hash *) *loc)->type;
6453:       gcc_assert (TYPE_MAIN_VARIANT (t1) == t1
6454: 		  && t1 != type);
6455:       if (TYPE_UID (type) + 1 == next_type_uid)
6456: 	--next_type_uid;
6457:       /* Free also min/max values and the cache for integer
6458: 	 types.  This can't be done in free_node, as LTO frees
6459: 	 those on its own.  */
6460:       if (TREE_CODE (type) == INTEGER_TYPE || TREE_CODE (type) == BITINT_TYPE)
6461: 	{
6462: 	  if (TYPE_MIN_VALUE (type)
6463: 	      && TREE_TYPE (TYPE_MIN_VALUE (type)) == type)
6464: 	    {
6465: 	      /* Zero is always in TYPE_CACHED_VALUES.  */
6466: 	      if (! TYPE_UNSIGNED (type))
6467: 		int_cst_hash_table->remove_elt (TYPE_MIN_VALUE (type));
6468: 	      ggc_free (TYPE_MIN_VALUE (type));
6469: 	    }
6470: 	  if (TYPE_MAX_VALUE (type)
6471: 	      && TREE_TYPE (TYPE_MAX_VALUE (type)) == type)
6472: 	    {
6473: 	      int_cst_hash_table->remove_elt (TYPE_MAX_VALUE (type));
6474: 	      ggc_free (TYPE_MAX_VALUE (type));
6475: 	    }
6476: 	  if (TYPE_CACHED_VALUES_P (type))
6477: 	    ggc_free (TYPE_CACHED_VALUES (type));
6478: 	}
6479:       free_node (type);
6480:       return t1;
6481:     }
6482:   else
6483:     {
6484:       struct type_hash *h;
6485:
6486:       h = ggc_alloc<type_hash> ();
6487:       h->hash = hashcode;
6488:       h->type = type;
6489:       *loc = h;
6490:
6491:       return type;
6492:     }
```

## gcc/tree.cc:7198–7385
```text
7198: build_pointer_type_for_mode (tree to_type, machine_mode mode,
7199: 			     bool can_alias_all)
7200: {
7201:   tree t;
7202:   bool could_alias = can_alias_all;
7203:
7204:   if (to_type == error_mark_node)
7205:     return error_mark_node;
7206:
7207:   if (mode == VOIDmode)
7208:     {
7209:       addr_space_t as = TYPE_ADDR_SPACE (to_type);
7210:       mode = targetm.addr_space.pointer_mode (as);
7211:     }
7212:
7213:   /* If the pointed-to type has the may_alias attribute set, force
7214:      a TYPE_REF_CAN_ALIAS_ALL pointer to be generated.  */
7215:   if (lookup_attribute ("may_alias", TYPE_ATTRIBUTES (to_type)))
7216:     can_alias_all = true;
7217:
7218:   /* In some cases, languages will have things that aren't a POINTER_TYPE
7219:      (such as a RECORD_TYPE for fat pointers in Ada) as TYPE_POINTER_TO.
7220:      In that case, return that type without regard to the rest of our
7221:      operands.
7222:
7223:      ??? This is a kludge, but consistent with the way this function has
7224:      always operated and there doesn't seem to be a good way to avoid this
7225:      at the moment.  */
7226:   if (TYPE_POINTER_TO (to_type) != 0
7227:       && TREE_CODE (TYPE_POINTER_TO (to_type)) != POINTER_TYPE)
7228:     return TYPE_POINTER_TO (to_type);
7229:
7230:   /* First, if we already have a type for pointers to TO_TYPE and it's
7231:      the proper mode, use it.  */
7232:   for (t = TYPE_POINTER_TO (to_type); t; t = TYPE_NEXT_PTR_TO (t))
7233:     if (TYPE_MODE (t) == mode && TYPE_REF_CAN_ALIAS_ALL (t) == can_alias_all)
7234:       return t;
7235:
7236:   t = make_node (POINTER_TYPE);
7237:
7238:   TREE_TYPE (t) = to_type;
7239:   SET_TYPE_MODE (t, mode);
7240:   TYPE_REF_CAN_ALIAS_ALL (t) = can_alias_all;
7241:   TYPE_NEXT_PTR_TO (t) = TYPE_POINTER_TO (to_type);
7242:   TYPE_POINTER_TO (to_type) = t;
7243:
7244:   /* During LTO we do not set TYPE_CANONICAL of pointers and references.  */
7245:   if (TYPE_STRUCTURAL_EQUALITY_P (to_type) || in_lto_p)
7246:     SET_TYPE_STRUCTURAL_EQUALITY (t);
7247:   else if (TYPE_CANONICAL (to_type) != to_type || could_alias)
7248:     TYPE_CANONICAL (t)
7249:       = build_pointer_type_for_mode (TYPE_CANONICAL (to_type),
7250: 				     mode, false);
7251:
7252:   /* Lay out the type.  This function has many callers that are concerned
7253:      with expression-construction, and this simplifies them all.  */
7254:   layout_type (t);
7255:
7256:   return t;
7257: }
7258:
7259: /* By default build pointers in ptr_mode.  */
7260:
7261: tree
7262: build_pointer_type (tree to_type)
7263: {
7264:   return build_pointer_type_for_mode (to_type, VOIDmode, false);
7265: }
7266:
7267: /* Same as build_pointer_type_for_mode, but for REFERENCE_TYPE.  */
7268:
7269: tree
7270: build_reference_type_for_mode (tree to_type, machine_mode mode,
7271: 			       bool can_alias_all)
7272: {
7273:   tree t;
7274:   bool could_alias = can_alias_all;
7275:
7276:   if (to_type == error_mark_node)
7277:     return error_mark_node;
7278:
7279:   if (mode == VOIDmode)
7280:     {
7281:       addr_space_t as = TYPE_ADDR_SPACE (to_type);
7282:       mode = targetm.addr_space.pointer_mode (as);
7283:     }
7284:
7285:   /* If the pointed-to type has the may_alias attribute set, force
7286:      a TYPE_REF_CAN_ALIAS_ALL pointer to be generated.  */
7287:   if (lookup_attribute ("may_alias", TYPE_ATTRIBUTES (to_type)))
7288:     can_alias_all = true;
7289:
7290:   /* In some cases, languages will have things that aren't a REFERENCE_TYPE
7291:      (such as a RECORD_TYPE for fat pointers in Ada) as TYPE_REFERENCE_TO.
7292:      In that case, return that type without regard to the rest of our
7293:      operands.
7294:
7295:      ??? This is a kludge, but consistent with the way this function has
7296:      always operated and there doesn't seem to be a good way to avoid this
7297:      at the moment.  */
7298:   if (TYPE_REFERENCE_TO (to_type) != 0
7299:       && TREE_CODE (TYPE_REFERENCE_TO (to_type)) != REFERENCE_TYPE)
7300:     return TYPE_REFERENCE_TO (to_type);
7301:
7302:   /* First, if we already have a type for pointers to TO_TYPE and it's
7303:      the proper mode, use it.  */
7304:   for (t = TYPE_REFERENCE_TO (to_type); t; t = TYPE_NEXT_REF_TO (t))
7305:     if (TYPE_MODE (t) == mode && TYPE_REF_CAN_ALIAS_ALL (t) == can_alias_all)
7306:       return t;
7307:
7308:   t = make_node (REFERENCE_TYPE);
7309:
7310:   TREE_TYPE (t) = to_type;
7311:   SET_TYPE_MODE (t, mode);
7312:   TYPE_REF_CAN_ALIAS_ALL (t) = can_alias_all;
7313:   TYPE_NEXT_REF_TO (t) = TYPE_REFERENCE_TO (to_type);
7314:   TYPE_REFERENCE_TO (to_type) = t;
7315:
7316:   /* During LTO we do not set TYPE_CANONICAL of pointers and references.  */
7317:   if (TYPE_STRUCTURAL_EQUALITY_P (to_type) || in_lto_p)
7318:     SET_TYPE_STRUCTURAL_EQUALITY (t);
7319:   else if (TYPE_CANONICAL (to_type) != to_type || could_alias)
7320:     TYPE_CANONICAL (t)
7321:       = build_reference_type_for_mode (TYPE_CANONICAL (to_type),
7322: 				       mode, false);
7323:
7324:   layout_type (t);
7325:
7326:   return t;
7327: }
7328:
7329:
7330: /* Build the node for the type of references-to-TO_TYPE by default
7331:    in ptr_mode.  */
7332:
7333: tree
7334: build_reference_type (tree to_type)
7335: {
7336:   return build_reference_type_for_mode (to_type, VOIDmode, false);
7337: }
7338:
7339: #define MAX_INT_CACHED_PREC \
7340:   (HOST_BITS_PER_WIDE_INT > 64 ? HOST_BITS_PER_WIDE_INT : 64)
7341: static GTY(()) tree nonstandard_integer_type_cache[2 * MAX_INT_CACHED_PREC + 2];
7342:
7343: static void
7344: clear_nonstandard_integer_type_cache (void)
7345: {
7346:   for (size_t i = 0 ; i < 2 * MAX_INT_CACHED_PREC + 2 ; i++)
7347:   {
7348:     nonstandard_integer_type_cache[i] = NULL;
7349:   }
7350: }
7351:
7352: /* Builds a signed or unsigned integer type of precision PRECISION.
7353:    Used for C bitfields whose precision does not match that of
7354:    built-in target types.  */
7355: tree
7356: build_nonstandard_integer_type (unsigned HOST_WIDE_INT precision,
7357: 				int unsignedp)
7358: {
7359:   tree itype, ret;
7360:
7361:   if (unsignedp)
7362:     unsignedp = MAX_INT_CACHED_PREC + 1;
7363:
7364:   if (precision <= MAX_INT_CACHED_PREC)
7365:     {
7366:       itype = nonstandard_integer_type_cache[precision + unsignedp];
7367:       if (itype)
7368: 	return itype;
7369:     }
7370:
7371:   itype = make_node (INTEGER_TYPE);
7372:   TYPE_PRECISION (itype) = precision;
7373:
7374:   if (unsignedp)
7375:     fixup_unsigned_type (itype);
7376:   else
7377:     fixup_signed_type (itype);
7378:
7379:   inchash::hash hstate;
7380:   inchash::add_expr (TYPE_MAX_VALUE (itype), hstate);
7381:   ret = type_hash_canon (hstate.end (), itype);
7382:   if (precision <= MAX_INT_CACHED_PREC)
7383:     nonstandard_integer_type_cache[precision + unsignedp] = ret;
7384:
7385:   return ret;
```

## gcc/tree.cc:7460–7511
```text
7460: build_range_type_1 (tree type, tree lowval, tree highval, bool shared)
7461: {
7462:   tree itype = make_node (INTEGER_TYPE);
7463:
7464:   TREE_TYPE (itype) = type;
7465:
7466:   TYPE_MIN_VALUE (itype) = fold_convert (type, lowval);
7467:   TYPE_MAX_VALUE (itype) = highval ? fold_convert (type, highval) : NULL;
7468:
7469:   TYPE_PRECISION (itype) = TYPE_PRECISION (type);
7470:   SET_TYPE_MODE (itype, TYPE_MODE (type));
7471:   TYPE_SIZE (itype) = TYPE_SIZE (type);
7472:   TYPE_SIZE_UNIT (itype) = TYPE_SIZE_UNIT (type);
7473:   SET_TYPE_ALIGN (itype, TYPE_ALIGN (type));
7474:   TYPE_USER_ALIGN (itype) = TYPE_USER_ALIGN (type);
7475:   SET_TYPE_WARN_IF_NOT_ALIGN (itype, TYPE_WARN_IF_NOT_ALIGN (type));
7476:
7477:   if (!shared)
7478:     return itype;
7479:
7480:   if ((TYPE_MIN_VALUE (itype)
7481:        && TREE_CODE (TYPE_MIN_VALUE (itype)) != INTEGER_CST)
7482:       || (TYPE_MAX_VALUE (itype)
7483: 	  && TREE_CODE (TYPE_MAX_VALUE (itype)) != INTEGER_CST))
7484:     {
7485:       /* Since we cannot reliably merge this type, we need to compare it using
7486: 	 structural equality checks.  */
7487:       SET_TYPE_STRUCTURAL_EQUALITY (itype);
7488:       return itype;
7489:     }
7490:
7491:   hashval_t hash = type_hash_canon_hash (itype);
7492:   itype = type_hash_canon (hash, itype);
7493:
7494:   return itype;
7495: }
7496:
7497: /* Wrapper around build_range_type_1 with SHARED set to true.  */
7498:
7499: tree
7500: build_range_type (tree type, tree lowval, tree highval)
7501: {
7502:   return build_range_type_1 (type, lowval, highval, true);
7503: }
7504:
7505: /* Wrapper around build_range_type_1 with SHARED set to false.  */
7506:
7507: tree
7508: build_nonshared_range_type (tree type, tree lowval, tree highval)
7509: {
7510:   return build_range_type_1 (type, lowval, highval, false);
7511: }
```

## gcc/tree.cc:7576–7668
```text
7576: 		    bool shared, bool set_canonical)
7577: {
7578:   tree t;
7579:
7580:   if (TREE_CODE (elt_type) == FUNCTION_TYPE)
7581:     {
7582:       error ("arrays of functions are not meaningful");
7583:       elt_type = integer_type_node;
7584:     }
7585:
7586:   t = make_node (ARRAY_TYPE);
7587:   TREE_TYPE (t) = elt_type;
7588:   TYPE_DOMAIN (t) = index_type;
7589:   TYPE_ADDR_SPACE (t) = TYPE_ADDR_SPACE (elt_type);
7590:   TYPE_TYPELESS_STORAGE (t) = typeless_storage;
7591:
7592:   /* Set TYPE_STRUCTURAL_EQUALITY_P.  */
7593:   if (set_canonical
7594:       && (TYPE_STRUCTURAL_EQUALITY_P (elt_type)
7595: 	  || (index_type && TYPE_STRUCTURAL_EQUALITY_P (index_type))
7596: 	  || in_lto_p))
7597:     SET_TYPE_STRUCTURAL_EQUALITY (t);
7598:
7599:   layout_type (t);
7600:
7601:   if (shared)
7602:     {
7603:       hashval_t hash = type_hash_canon_hash (t);
7604:       tree probe_type = t;
7605:       t = type_hash_canon (hash, t);
7606:       if (t != probe_type)
7607: 	return t;
7608:     }
7609:
7610:   if (TYPE_CANONICAL (t) == t && set_canonical)
7611:     {
7612:       if (TYPE_STRUCTURAL_EQUALITY_P (elt_type)
7613: 	  || (index_type && TYPE_STRUCTURAL_EQUALITY_P (index_type))
7614: 	  || in_lto_p)
7615: 	gcc_unreachable ();
7616:       else if (TYPE_CANONICAL (elt_type) != elt_type
7617: 	       || (index_type && TYPE_CANONICAL (index_type) != index_type))
7618: 	TYPE_CANONICAL (t)
7619: 	  = build_array_type_1 (TYPE_CANONICAL (elt_type),
7620: 				index_type
7621: 				? TYPE_CANONICAL (index_type) : NULL_TREE,
7622: 				typeless_storage, shared, set_canonical);
7623:     }
7624:
7625:   return t;
7626: }
7627:
7628: /* Wrapper around build_array_type_1 with SHARED set to true.  */
7629:
7630: tree
7631: build_array_type (tree elt_type, tree index_type, bool typeless_storage)
7632: {
7633:   return
7634:     build_array_type_1 (elt_type, index_type, typeless_storage, true, true);
7635: }
7636:
7637: /* Wrapper around build_array_type_1 with SHARED set to false.  */
7638:
7639: tree
7640: build_nonshared_array_type (tree elt_type, tree index_type)
7641: {
7642:   return build_array_type_1 (elt_type, index_type, false, false, true);
7643: }
7644:
7645: /* Return a representation of ELT_TYPE[NELTS], using indices of type
7646:    sizetype.  */
7647:
7648: tree
7649: build_array_type_nelts (tree elt_type, poly_uint64 nelts)
7650: {
7651:   return build_array_type (elt_type, build_index_type (size_int (nelts - 1)));
7652: }
7653:
7654: /* Computes the canonical argument types from the argument type list
7655:    ARGTYPES.
7656:
7657:    Upon return, *ANY_STRUCTURAL_P will be true iff either it was true
7658:    on entry to this function, or if any of the ARGTYPES are
7659:    structural.
7660:
7661:    Upon return, *ANY_NONCANONICAL_P will be true iff either it was
7662:    true on entry to this function, or if any of the ARGTYPES are
7663:    non-canonical.
7664:
7665:    Returns a canonical argument list, which may be ARGTYPES when the
7666:    canonical argument list is unneeded (i.e., *ANY_STRUCTURAL_P is
7667:    true) or would not differ from ARGTYPES.  */
7668:
```

## gcc/tree.cc:8025–8088
```text
8025: build_complex_type (tree component_type, bool named)
8026: {
8027:   gcc_assert (INTEGRAL_TYPE_P (component_type)
8028: 	      || SCALAR_FLOAT_TYPE_P (component_type)
8029: 	      || FIXED_POINT_TYPE_P (component_type));
8030:
8031:   /* Make a node of the sort we want.  */
8032:   tree probe = make_node (COMPLEX_TYPE);
8033:
8034:   TREE_TYPE (probe) = TYPE_MAIN_VARIANT (component_type);
8035:   if (TYPE_STRUCTURAL_EQUALITY_P (TREE_TYPE (probe)))
8036:     SET_TYPE_STRUCTURAL_EQUALITY (probe);
8037:
8038:   /* If we already have such a type, use the old one.  */
8039:   hashval_t hash = type_hash_canon_hash (probe);
8040:   tree t = type_hash_canon (hash, probe);
8041:
8042:   if (t == probe)
8043:     {
8044:       /* We created a new type.  The hash insertion will have laid
8045: 	 out the type.  We need to check the canonicalization and
8046: 	 maybe set the name.  */
8047:       gcc_checking_assert (COMPLETE_TYPE_P (t)
8048: 			   && !TYPE_NAME (t));
8049:
8050:       if (TYPE_STRUCTURAL_EQUALITY_P (TREE_TYPE (t)))
8051: 	;
8052:       else if (TYPE_CANONICAL (TREE_TYPE (t)) != TREE_TYPE (t))
8053: 	TYPE_CANONICAL (t)
8054: 	  = build_complex_type (TYPE_CANONICAL (TREE_TYPE (t)), named);
8055:
8056:       /* We need to create a name, since complex is a fundamental type.  */
8057:       if (named)
8058: 	{
8059: 	  const char *name = NULL;
8060:
8061: 	  if (TREE_TYPE (t) == char_type_node)
8062: 	    name = "complex char";
8063: 	  else if (TREE_TYPE (t) == signed_char_type_node)
8064: 	    name = "complex signed char";
8065: 	  else if (TREE_TYPE (t) == unsigned_char_type_node)
8066: 	    name = "complex unsigned char";
8067: 	  else if (TREE_TYPE (t) == short_integer_type_node)
8068: 	    name = "complex short int";
8069: 	  else if (TREE_TYPE (t) == short_unsigned_type_node)
8070: 	    name = "complex short unsigned int";
8071: 	  else if (TREE_TYPE (t) == integer_type_node)
8072: 	    name = "complex int";
8073: 	  else if (TREE_TYPE (t) == unsigned_type_node)
8074: 	    name = "complex unsigned int";
8075: 	  else if (TREE_TYPE (t) == long_integer_type_node)
8076: 	    name = "complex long int";
8077: 	  else if (TREE_TYPE (t) == long_unsigned_type_node)
8078: 	    name = "complex long unsigned int";
8079: 	  else if (TREE_TYPE (t) == long_long_integer_type_node)
8080: 	    name = "complex long long int";
8081: 	  else if (TREE_TYPE (t) == long_long_unsigned_type_node)
8082: 	    name = "complex long long unsigned int";
8083:
8084: 	  if (name != NULL)
8085: 	    TYPE_NAME (t) = build_decl (UNKNOWN_LOCATION, TYPE_DECL,
8086: 					get_identifier (name), t);
8087: 	}
8088:     }
```

## gcc/tree.cc:11024–11113
```text
11024: build_vl_exp (enum tree_code code, int len MEM_STAT_DECL)
11025: {
11026:   tree t;
11027:   int length = (len - 1) * sizeof (tree) + sizeof (struct tree_exp);
11028:
11029:   gcc_assert (TREE_CODE_CLASS (code) == tcc_vl_exp);
11030:   gcc_assert (len >= 1);
11031:
11032:   record_node_allocation_statistics (code, length);
11033:
11034:   t = ggc_alloc_cleared_tree_node_stat (length PASS_MEM_STAT);
11035:
11036:   TREE_SET_CODE (t, code);
11037:
11038:   /* Can't use TREE_OPERAND to store the length because if checking is
11039:      enabled, it will try to check the length before we store it.  :-P  */
11040:   t->exp.operands[0] = build_int_cst (sizetype, len);
11041:
11042:   return t;
11043: }
11044:
11045: /* Helper function for build_call_* functions; build a CALL_EXPR with
11046:    indicated RETURN_TYPE, FN, and NARGS, but do not initialize any of
11047:    the argument slots.  */
11048:
11049: static tree
11050: build_call_1 (tree return_type, tree fn, int nargs)
11051: {
11052:   tree t;
11053:
11054:   t = build_vl_exp (CALL_EXPR, nargs + 3);
11055:   TREE_TYPE (t) = return_type;
11056:   CALL_EXPR_FN (t) = fn;
11057:   CALL_EXPR_STATIC_CHAIN (t) = NULL;
11058:
11059:   return t;
11060: }
11061:
11062: /* Build a CALL_EXPR of class tcc_vl_exp with the indicated RETURN_TYPE and
11063:    FN and a null static chain slot.  NARGS is the number of call arguments
11064:    which are specified as a va_list ARGS.  */
11065:
11066: tree
11067: build_call_valist (tree return_type, tree fn, int nargs, va_list args)
11068: {
11069:   tree t;
11070:   int i;
11071:
11072:   t = build_call_1 (return_type, fn, nargs);
11073:   for (i = 0; i < nargs; i++)
11074:     CALL_EXPR_ARG (t, i) = va_arg (args, tree);
11075:   process_call_operands (t);
11076:   return t;
11077: }
11078:
11079: /* Build a CALL_EXPR of class tcc_vl_exp with the indicated RETURN_TYPE and
11080:    FN and a null static chain slot.  ARGS specifies the call arguments.  */
11081:
11082: tree
11083: build_call (tree return_type, tree fn, std::initializer_list<tree> args)
11084: {
11085:   tree t;
11086:   int i;
11087:   int nargs = args.size();
11088:
11089:   t = build_call_1 (return_type, fn, nargs);
11090:   for (i = 0; i < nargs; i++)
11091:     CALL_EXPR_ARG (t, i) = args.begin()[i];
11092:   process_call_operands (t);
11093:   return t;
11094: }
11095:
11096: /* Build a CALL_EXPR of class tcc_vl_exp with the indicated RETURN_TYPE and
11097:    FN and a null static chain slot.  NARGS is the number of call arguments
11098:    which are specified as a tree array ARGS.  */
11099:
11100: tree
11101: build_call_array_loc (location_t loc, tree return_type, tree fn,
11102: 		      int nargs, const tree *args)
11103: {
11104:   tree t;
11105:   int i;
11106:
11107:   t = build_call_1 (return_type, fn, nargs);
11108:   for (i = 0; i < nargs; i++)
11109:     CALL_EXPR_ARG (t, i) = args[i];
11110:   process_call_operands (t);
11111:   SET_EXPR_LOCATION (t, loc);
11112:   return t;
11113: }
```

## gcc/tree.cc:11637–12013
```text
11637: walk_type_fields (tree type, walk_tree_fn func, void *data,
11638: 		  hash_set<tree> *pset, walk_tree_lh lh)
11639: {
11640:   tree result = NULL_TREE;
11641:
11642:   switch (TREE_CODE (type))
11643:     {
11644:     case POINTER_TYPE:
11645:     case REFERENCE_TYPE:
11646:     case VECTOR_TYPE:
11647:       /* We have to worry about mutually recursive pointers.  These can't
11648: 	 be written in C.  They can in Ada.  It's pathological, but
11649: 	 there's an ACATS test (c38102a) that checks it.  Deal with this
11650: 	 by checking if we're pointing to another pointer, that one
11651: 	 points to another pointer, that one does too, and we have no htab.
11652: 	 If so, get a hash table.  We check three levels deep to avoid
11653: 	 the cost of the hash table if we don't need one.  */
11654:       if (POINTER_TYPE_P (TREE_TYPE (type))
11655: 	  && POINTER_TYPE_P (TREE_TYPE (TREE_TYPE (type)))
11656: 	  && POINTER_TYPE_P (TREE_TYPE (TREE_TYPE (TREE_TYPE (type))))
11657: 	  && !pset)
11658: 	{
11659: 	  result = walk_tree_without_duplicates (&TREE_TYPE (type),
11660: 						 func, data);
11661: 	  if (result)
11662: 	    return result;
11663:
11664: 	  break;
11665: 	}
11666:
11667:       /* fall through */
11668:
11669:     case COMPLEX_TYPE:
11670:       WALK_SUBTREE (TREE_TYPE (type));
11671:       break;
11672:
11673:     case METHOD_TYPE:
11674:       WALK_SUBTREE (TYPE_METHOD_BASETYPE (type));
11675:
11676:       /* Fall through.  */
11677:
11678:     case FUNCTION_TYPE:
11679:       WALK_SUBTREE (TREE_TYPE (type));
11680:       {
11681: 	tree arg;
11682:
11683: 	/* We never want to walk into default arguments.  */
11684: 	for (arg = TYPE_ARG_TYPES (type); arg; arg = TREE_CHAIN (arg))
11685: 	  WALK_SUBTREE (TREE_VALUE (arg));
11686:       }
11687:       break;
11688:
11689:     case ARRAY_TYPE:
11690:       /* Don't follow this nodes's type if a pointer for fear that
11691: 	 we'll have infinite recursion.  If we have a PSET, then we
11692: 	 need not fear.  */
11693:       if (pset
11694: 	  || (!POINTER_TYPE_P (TREE_TYPE (type))
11695: 	      && TREE_CODE (TREE_TYPE (type)) != OFFSET_TYPE))
11696: 	WALK_SUBTREE (TREE_TYPE (type));
11697:       WALK_SUBTREE (TYPE_DOMAIN (type));
11698:       break;
11699:
11700:     case OFFSET_TYPE:
11701:       WALK_SUBTREE (TREE_TYPE (type));
11702:       WALK_SUBTREE (TYPE_OFFSET_BASETYPE (type));
11703:       break;
11704:
11705:     default:
11706:       break;
11707:     }
11708:
11709:   return NULL_TREE;
11710: }
11711:
11712: /* Apply FUNC to all the sub-trees of TP in a pre-order traversal.  FUNC is
11713:    called with the DATA and the address of each sub-tree.  If FUNC returns a
11714:    non-NULL value, the traversal is stopped, and the value returned by FUNC
11715:    is returned.  If PSET is non-NULL it is used to record the nodes visited,
11716:    and to avoid visiting a node more than once.  */
11717:
11718: tree
11719: walk_tree_1 (tree *tp, walk_tree_fn func, void *data,
11720: 	     hash_set<tree> *pset, walk_tree_lh lh)
11721: {
11722: #define WALK_SUBTREE_TAIL(NODE)				\
11723:   do							\
11724:     {							\
11725:        tp = & (NODE);					\
11726:        goto tail_recurse;				\
11727:     }							\
11728:   while (0)
11729:
11730:  tail_recurse:
11731:   /* Skip empty subtrees.  */
11732:   if (!*tp)
11733:     return NULL_TREE;
11734:
11735:   /* Don't walk the same tree twice, if the user has requested
11736:      that we avoid doing so.  */
11737:   if (pset && pset->add (*tp))
11738:     return NULL_TREE;
11739:
11740:   /* Call the function.  */
11741:   int walk_subtrees = 1;
11742:   tree result = (*func) (tp, &walk_subtrees, data);
11743:
11744:   /* If we found something, return it.  */
11745:   if (result)
11746:     return result;
11747:
11748:   tree t = *tp;
11749:   tree_code code = TREE_CODE (t);
11750:
11751:   /* Even if we didn't, FUNC may have decided that there was nothing
11752:      interesting below this point in the tree.  */
11753:   if (!walk_subtrees)
11754:     {
11755:       /* But we still need to check our siblings.  */
11756:       if (code == TREE_LIST)
11757: 	WALK_SUBTREE_TAIL (TREE_CHAIN (t));
11758:       else if (code == OMP_CLAUSE)
11759: 	WALK_SUBTREE_TAIL (OMP_CLAUSE_CHAIN (t));
11760:       else
11761: 	return NULL_TREE;
11762:     }
11763:
11764:   if (lh)
11765:     {
11766:       result = (*lh) (tp, &walk_subtrees, func, data, pset);
11767:       if (result || !walk_subtrees)
11768:         return result;
11769:     }
11770:
11771:   switch (code)
11772:     {
11773:     case ERROR_MARK:
11774:     case IDENTIFIER_NODE:
11775:     case INTEGER_CST:
11776:     case REAL_CST:
11777:     case FIXED_CST:
11778:     case STRING_CST:
11779:     case BLOCK:
11780:     case PLACEHOLDER_EXPR:
11781:     case SSA_NAME:
11782:     case FIELD_DECL:
11783:     case RESULT_DECL:
11784:       /* None of these have subtrees other than those already walked
11785: 	 above.  */
11786:       break;
11787:
11788:     case TREE_LIST:
11789:       WALK_SUBTREE (TREE_VALUE (t));
11790:       WALK_SUBTREE_TAIL (TREE_CHAIN (t));
11791:
11792:     case TREE_VEC:
11793:       {
11794: 	int len = TREE_VEC_LENGTH (t);
11795:
11796: 	if (len == 0)
11797: 	  break;
11798:
11799: 	/* Walk all elements but the last.  */
11800: 	for (int i = 0; i < len - 1; ++i)
11801: 	  WALK_SUBTREE (TREE_VEC_ELT (t, i));
11802:
11803: 	/* Now walk the last one as a tail call.  */
11804: 	WALK_SUBTREE_TAIL (TREE_VEC_ELT (t, len - 1));
11805:       }
11806:
11807:     case VECTOR_CST:
11808:       {
11809: 	unsigned len = vector_cst_encoded_nelts (t);
11810: 	if (len == 0)
11811: 	  break;
11812: 	/* Walk all elements but the last.  */
11813: 	for (unsigned i = 0; i < len - 1; ++i)
11814: 	  WALK_SUBTREE (VECTOR_CST_ENCODED_ELT (t, i));
11815: 	/* Now walk the last one as a tail call.  */
11816: 	WALK_SUBTREE_TAIL (VECTOR_CST_ENCODED_ELT (t, len - 1));
11817:       }
11818:
11819:     case COMPLEX_CST:
11820:       WALK_SUBTREE (TREE_REALPART (t));
11821:       WALK_SUBTREE_TAIL (TREE_IMAGPART (t));
11822:
11823:     case CONSTRUCTOR:
11824:       {
11825: 	unsigned HOST_WIDE_INT idx;
11826: 	constructor_elt *ce;
11827:
11828: 	for (idx = 0; vec_safe_iterate (CONSTRUCTOR_ELTS (t), idx, &ce);
11829: 	     idx++)
11830: 	  WALK_SUBTREE (ce->value);
11831:       }
11832:       break;
11833:
11834:     case SAVE_EXPR:
11835:       WALK_SUBTREE_TAIL (TREE_OPERAND (t, 0));
11836:
11837:     case BIND_EXPR:
11838:       {
11839: 	tree decl;
11840: 	for (decl = BIND_EXPR_VARS (t); decl; decl = DECL_CHAIN (decl))
11841: 	  {
11842: 	    /* Walk the DECL_INITIAL and DECL_SIZE.  We don't want to walk
11843: 	       into declarations that are just mentioned, rather than
11844: 	       declared; they don't really belong to this part of the tree.
11845: 	       And, we can see cycles: the initializer for a declaration
11846: 	       can refer to the declaration itself.  */
11847: 	    WALK_SUBTREE (DECL_INITIAL (decl));
11848: 	    WALK_SUBTREE (DECL_SIZE (decl));
11849: 	    WALK_SUBTREE (DECL_SIZE_UNIT (decl));
11850: 	  }
11851: 	WALK_SUBTREE_TAIL (BIND_EXPR_BODY (t));
11852:       }
11853:
11854:     case STATEMENT_LIST:
11855:       {
11856: 	tree_stmt_iterator i;
11857: 	for (i = tsi_start (t); !tsi_end_p (i); tsi_next (&i))
11858: 	  WALK_SUBTREE (*tsi_stmt_ptr (i));
11859:       }
11860:       break;
11861:
11862:     case OMP_CLAUSE:
11863:       {
11864: 	int len = omp_clause_num_ops[OMP_CLAUSE_CODE (t)];
11865: 	/* Do not walk the iterator operand of OpenMP MAP clauses.  */
11866: 	if (OMP_CLAUSE_HAS_ITERATORS (t))
11867: 	  len--;
11868: 	for (int i = 0; i < len; i++)
11869: 	  WALK_SUBTREE (OMP_CLAUSE_OPERAND (t, i));
11870: 	WALK_SUBTREE_TAIL (OMP_CLAUSE_CHAIN (t));
11871:       }
11872:
11873:     case TARGET_EXPR:
11874:       {
11875: 	int i, len;
11876:
11877: 	/* TARGET_EXPRs are peculiar: operands 1 and 3 can be the same.
11878: 	   But, we only want to walk once.  */
11879: 	len = (TREE_OPERAND (t, 3) == TREE_OPERAND (t, 1)) ? 2 : 3;
11880: 	for (i = 0; i < len; ++i)
11881: 	  WALK_SUBTREE (TREE_OPERAND (t, i));
11882: 	WALK_SUBTREE_TAIL (TREE_OPERAND (t, len));
11883:       }
11884:
11885:     case DECL_EXPR:
11886:       /* If this is a TYPE_DECL, walk into the fields of the type that it's
11887: 	 defining.  We only want to walk into these fields of a type in this
11888: 	 case and not in the general case of a mere reference to the type.
11889:
11890: 	 The criterion is as follows: if the field can be an expression, it
11891: 	 must be walked only here.  This should be in keeping with the fields
11892: 	 that are directly gimplified in gimplify_type_sizes in order for the
11893: 	 mark/copy-if-shared/unmark machinery of the gimplifier to work with
11894: 	 variable-sized types.
11895:
11896: 	 Note that DECLs get walked as part of processing the BIND_EXPR.  */
11897:       if (TREE_CODE (DECL_EXPR_DECL (t)) == TYPE_DECL)
11898: 	{
11899: 	  /* Call the function for the decl so e.g. copy_tree_body_r can
11900: 	     replace it with the remapped one.  */
11901: 	  result = (*func) (&DECL_EXPR_DECL (t), &walk_subtrees, data);
11902: 	  if (result || !walk_subtrees)
11903: 	    return result;
11904:
11905: 	  tree *type_p = &TREE_TYPE (DECL_EXPR_DECL (t));
11906: 	  if (TREE_CODE (*type_p) == ERROR_MARK)
11907: 	    return NULL_TREE;
11908:
11909: 	  /* Call the function for the type.  See if it returns anything or
11910: 	     doesn't want us to continue.  If we are to continue, walk both
11911: 	     the normal fields and those for the declaration case.  */
11912: 	  result = (*func) (type_p, &walk_subtrees, data);
11913: 	  if (result || !walk_subtrees)
11914: 	    return result;
11915:
11916: 	  tree type = *type_p;
11917:
11918: 	  /* But do not walk a pointed-to type since it may itself need to
11919: 	     be walked in the declaration case if it isn't anonymous.  */
11920: 	  if (!POINTER_TYPE_P (type))
11921: 	    {
11922: 	      result = walk_type_fields (type, func, data, pset, lh);
11923: 	      if (result)
11924: 		return result;
11925: 	    }
11926:
11927: 	  /* If this is a record type, also walk the fields.  */
11928: 	  if (RECORD_OR_UNION_TYPE_P (type))
11929: 	    {
11930: 	      tree field;
11931:
11932: 	      for (field = TYPE_FIELDS (type); field;
11933: 		   field = DECL_CHAIN (field))
11934: 		{
11935: 		  /* We'd like to look at the type of the field, but we can
11936: 		     easily get infinite recursion.  So assume it's pointed
11937: 		     to elsewhere in the tree.  Also, ignore things that
11938: 		     aren't fields.  */
11939: 		  if (TREE_CODE (field) != FIELD_DECL)
11940: 		    continue;
11941:
11942: 		  WALK_SUBTREE (DECL_FIELD_OFFSET (field));
11943: 		  WALK_SUBTREE (DECL_SIZE (field));
11944: 		  WALK_SUBTREE (DECL_SIZE_UNIT (field));
11945: 		  if (TREE_CODE (type) == QUAL_UNION_TYPE)
11946: 		    WALK_SUBTREE (DECL_QUALIFIER (field));
11947: 		}
11948: 	    }
11949:
11950: 	  /* Same for scalar types.  */
11951: 	  else if (TREE_CODE (type) == BOOLEAN_TYPE
11952: 		   || TREE_CODE (type) == ENUMERAL_TYPE
11953: 		   || TREE_CODE (type) == INTEGER_TYPE
11954: 		   || TREE_CODE (type) == FIXED_POINT_TYPE
11955: 		   || TREE_CODE (type) == REAL_TYPE)
11956: 	    {
11957: 	      WALK_SUBTREE (TYPE_MIN_VALUE (type));
11958: 	      WALK_SUBTREE (TYPE_MAX_VALUE (type));
11959: 	    }
11960:
11961: 	  WALK_SUBTREE (TYPE_SIZE (type));
11962: 	  WALK_SUBTREE_TAIL (TYPE_SIZE_UNIT (type));
11963: 	}
11964:       /* FALLTHRU */
11965:
11966:     default:
11967:       if (IS_EXPR_CODE_CLASS (TREE_CODE_CLASS (code)))
11968: 	{
11969: 	  int i, len;
11970:
11971: 	  /* Walk over all the sub-trees of this operand.  */
11972: 	  len = TREE_OPERAND_LENGTH (t);
11973:
11974: 	  /* Go through the subtrees.  We need to do this in forward order so
11975: 	     that the scope of a FOR_EXPR is handled properly.  */
11976: 	  if (len)
11977: 	    {
11978: 	      for (i = 0; i < len - 1; ++i)
11979: 		WALK_SUBTREE (TREE_OPERAND (t, i));
11980: 	      WALK_SUBTREE_TAIL (TREE_OPERAND (t, len - 1));
11981: 	    }
11982: 	}
11983:       /* If this is a type, walk the needed fields in the type.  */
11984:       else if (TYPE_P (t))
11985: 	return walk_type_fields (t, func, data, pset, lh);
11986:       break;
11987:     }
11988:
11989:   /* We didn't find what we were looking for.  */
11990:   return NULL_TREE;
11991:
11992: #undef WALK_SUBTREE_TAIL
11993: }
11994: #undef WALK_SUBTREE
11995:
11996: /* Like walk_tree, but does not walk duplicate nodes more than once.  */
11997:
11998: tree
11999: walk_tree_without_duplicates_1 (tree *tp, walk_tree_fn func, void *data,
12000: 				walk_tree_lh lh)
12001: {
12002:   tree result;
12003:
12004:   hash_set<tree> pset;
12005:   result = walk_tree_1 (tp, func, data, &pset, lh);
12006:   return result;
12007: }
12008:
12009:
12010: tree
12011: tree_block (tree t)
12012: {
12013:   const enum tree_code_class c = TREE_CODE_CLASS (TREE_CODE (t));
```

## gcc/tree.cc:15095–15129
```text
15095: is_empty_type (const_tree type)
15096: {
15097:   if (RECORD_OR_UNION_TYPE_P (type))
15098:     {
15099:       for (tree field = TYPE_FIELDS (type); field; field = DECL_CHAIN (field))
15100: 	if (TREE_CODE (field) == FIELD_DECL
15101: 	    && !DECL_PADDING_P (field)
15102: 	    && !is_empty_type (TREE_TYPE (field)))
15103: 	  return false;
15104:       return true;
15105:     }
15106:   else if (TREE_CODE (type) == ARRAY_TYPE)
15107:     return (integer_minus_onep (array_type_nelts_minus_one (type))
15108: 	    || TYPE_DOMAIN (type) == NULL_TREE
15109: 	    || is_empty_type (TREE_TYPE (type)));
15110:   return false;
15111: }
15112:
15113: /* Implement TARGET_EMPTY_RECORD_P.  Return true if TYPE is an empty type
15114:    that shouldn't be passed via stack.  */
15115:
15116: bool
15117: default_is_empty_record (const_tree type)
15118: {
15119:   if (!abi_version_at_least (12))
15120:     return false;
15121:
15122:   if (type == error_mark_node)
15123:     return false;
15124:
15125:   if (TREE_ADDRESSABLE (type))
15126:     return false;
15127:
15128:   return is_empty_type (TYPE_MAIN_VARIANT (type));
15129: }
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

## gcc/tree-core.h:1631–1648
```text
1631: struct GTY(()) tree_vec {
1632:   struct tree_common common;
1633:   tree GTY ((length ("TREE_VEC_LENGTH ((tree)&%h)"))) a[1];
1634: };
1635:
1636: /* A single element of a CONSTRUCTOR. VALUE holds the actual value of the
1637:    element. INDEX can optionally design the position of VALUE: in arrays,
1638:    it is the index where VALUE has to be placed; in structures, it is the
1639:    FIELD_DECL of the member.  */
1640: struct GTY(()) constructor_elt {
1641:   tree index;
1642:   tree value;
1643: };
1644:
1645: struct GTY(()) tree_constructor {
1646:   struct tree_typed typed;
1647:   vec<constructor_elt, va_gc> *elts;
1648: };
```

## gcc/tree-core.h:1696–1700
```text
1696: struct GTY(()) tree_exp {
1697:   struct tree_typed typed;
1698:   location_t locus;
1699:   tree GTY ((length ("TREE_OPERAND_LENGTH ((tree)&%h)"))) operands[1];
1700: };
```

## gcc/tree-core.h:1801–1871
```text
1801: struct GTY(()) tree_type_common {
1802:   struct tree_common common;
1803:   tree size;
1804:   tree size_unit;
1805:   tree attributes;
1806:   unsigned int uid;
1807:
1808:   ENUM_BITFIELD(machine_mode) mode : MACHINE_MODE_BITSIZE;
1809:
1810:   unsigned int precision : 16;
1811:   unsigned lang_flag_0 : 1;
1812:   unsigned lang_flag_1 : 1;
1813:   unsigned lang_flag_2 : 1;
1814:   unsigned lang_flag_3 : 1;
1815:   unsigned lang_flag_4 : 1;
1816:   unsigned lang_flag_5 : 1;
1817:   unsigned lang_flag_6 : 1;
1818:   unsigned lang_flag_7 : 1;
1819:
1820:   /* TYPE_ALIGN in log2; this has to be large enough to hold values
1821:      of the maximum of BIGGEST_ALIGNMENT and MAX_OFILE_ALIGNMENT,
1822:      the latter being usually the larger.  For ELF it is 8<<28,
1823:      so we need to store the value 32 (not 31, as we need the zero
1824:      as well), hence six bits.  */
1825:   unsigned align : 6;
1826:   /* TYPE_STRING_FLAG for INTEGER_TYPE and ARRAY_TYPE.
1827:      TYPE_CXX_ODR_P for RECORD_TYPE and UNION_TYPE.  */
1828:   unsigned string_flag : 1;
1829:   unsigned no_force_blk_flag : 1;
1830:
1831:   unsigned warn_if_not_align : 6;
1832:   unsigned needs_constructing_flag : 1;
1833:   unsigned transparent_aggr_flag : 1;
1834:
1835:   unsigned contains_placeholder_bits : 2;
1836:   unsigned restrict_flag : 1;
1837:   unsigned typeless_storage : 1;
1838:   unsigned empty_flag : 1;
1839:   unsigned indivisible_p : 1;
1840:   /* TYPE_NO_NAMED_ARGS_STDARG_P for a stdarg function.
1841:      Or TYPE_INCLUDES_FLEXARRAY for RECORD_TYPE and UNION_TYPE.  */
1842:   unsigned no_named_args_stdarg_p : 1;
1843:   unsigned spare : 1;
1844:
1845:   alias_set_type alias_set;
1846:   tree pointer_to;
1847:   tree reference_to;
1848:   union tree_type_symtab {
1849:     int GTY ((tag ("TYPE_SYMTAB_IS_ADDRESS"))) address;
1850:     struct die_struct * GTY ((tag ("TYPE_SYMTAB_IS_DIE"))) die;
1851:   } GTY ((desc ("debug_hooks->tree_type_symtab_field"))) symtab;
1852:   tree canonical;
1853:   tree next_variant;
1854:   tree main_variant;
1855:   tree context;
1856:   tree name;
1857: };
1858:
1859: struct GTY(()) tree_type_with_lang_specific {
1860:   struct tree_type_common common;
1861:   /* Points to a structure whose details depend on the language in use.  */
1862:   struct lang_type *lang_specific;
1863: };
1864:
1865: struct GTY(()) tree_type_non_common {
1866:   struct tree_type_with_lang_specific with_lang_specific;
1867:   tree values;
1868:   tree minval;
1869:   tree maxval;
1870:   tree lang_1;
1871: };
```

## gcc/tree-core.h:2336–2358
```text
2336: struct GTY(()) tree_map_base {
2337:   tree from;
2338: };
2339:
2340: /* Map from a tree to another tree.  */
2341:
2342: struct GTY((for_user)) tree_map {
2343:   struct tree_map_base base;
2344:   unsigned int hash;
2345:   tree to;
2346: };
2347:
2348: /* Map from a decl tree to another tree.  */
2349: struct GTY((for_user)) tree_decl_map {
2350:   struct tree_map_base base;
2351:   tree to;
2352: };
2353:
2354: /* Map from a tree to an int.  */
2355: struct GTY((for_user)) tree_int_map {
2356:   struct tree_map_base base;
2357:   unsigned int to;
2358: };
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

## libcpp/include/line-map.h:747–805
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
778:
779: /* Data structure to associate a source_range together with an arbitrary
780:    data pointer with a source location.  */
781: struct GTY(()) location_adhoc_data {
782:   location_t locus;
783:   source_range src_range;
784:   void * GTY((skip)) data;
785:   unsigned discriminator;
786: };
787:
788: struct htab;
789:
790: /* The following data structure encodes a location with some adhoc data
791:    and maps it to a new unsigned integer (called an adhoc location)
792:    that replaces the original location to represent the mapping.
793:
794:    The new adhoc_loc uses the highest bit as the enabling bit, i.e. if the
795:    highest bit is 1, then the number is adhoc_loc. Otherwise, it serves as
796:    the original location.  Once identified as the adhoc_loc, the lower 62
797:    bits of the integer is used to index the location_adhoc_data array,
798:    in which the locus and associated data is stored.  */
799:
800: struct GTY(()) location_adhoc_data_map {
801:   struct htab * GTY((skip)) htab;
802:   location_t curr_loc;
803:   line_map_uint_t allocated;
804:   struct location_adhoc_data GTY((length ("%h.allocated"))) *data;
805: };
```

## libcpp/line-map.cc:63–125
```text
63: /* Hash function for location_adhoc_data hashtable.  */
64:
65: static hashval_t
66: location_adhoc_data_hash (const void *l)
67: {
68:   const struct location_adhoc_data *lb =
69:       (const struct location_adhoc_data *) l;
70:   return lb->locus
71:     + lb->src_range.m_start
72:     + lb->src_range.m_finish
73:     + (size_t) lb->data
74:     + lb->discriminator;
75: }
76:
77: /* Compare function for location_adhoc_data hashtable.  */
78:
79: static int
80: location_adhoc_data_eq (const void *l1, const void *l2)
81: {
82:   const struct location_adhoc_data *lb1 =
83:       (const struct location_adhoc_data *) l1;
84:   const struct location_adhoc_data *lb2 =
85:       (const struct location_adhoc_data *) l2;
86:   return (lb1->locus == lb2->locus
87: 	  && lb1->src_range.m_start == lb2->src_range.m_start
88: 	  && lb1->src_range.m_finish == lb2->src_range.m_finish
89: 	  && lb1->data == lb2->data
90: 	  && lb1->discriminator == lb2->discriminator);
91: }
92:
93: /* Update the hashtable when location_adhoc_data_map::data is reallocated.
94:    The param is an array of two pointers, the previous value of the data
95:    pointer, and then the new value.  The pointers stored in the hash map
96:    are then rebased to be relative to the new data pointer instead of the
97:    old one.  */
98:
99: static int
100: location_adhoc_data_update (void **slot_v, void *param_v)
101: {
102:   const auto slot = reinterpret_cast<location_adhoc_data **> (slot_v);
103:   const auto param = static_cast<location_adhoc_data **> (param_v);
104:   *slot = (*slot - param[0]) + param[1];
105:   return 1;
106: }
107:
108: /* The adhoc data hash table is not part of the GGC infrastructure, so it was
109:    not initialized when SET was reconstructed from PCH; take care of that by
110:    rebuilding it from scratch.  */
111:
112: void
113: rebuild_location_adhoc_htab (line_maps *set)
114: {
115:   set->m_location_adhoc_data_map.htab =
116:       htab_create (100, location_adhoc_data_hash, location_adhoc_data_eq, NULL);
117:   for (auto p = set->m_location_adhoc_data_map.data,
118: 	    end = p + set->m_location_adhoc_data_map.curr_loc;
119:       p != end; ++p)
120:     {
121:       const auto slot = reinterpret_cast<location_adhoc_data **>
122: 	(htab_find_slot (set->m_location_adhoc_data_map.htab, p, INSERT));
123:       *slot = p;
124:     }
125: }
```

## libcpp/line-map.cc:175–261
```text
175: location_t
176: line_maps::get_or_create_combined_loc (location_t locus,
177: 				       source_range src_range,
178: 				       void *data,
179: 				       unsigned discriminator)
180: {
181:   struct location_adhoc_data lb;
182:   struct location_adhoc_data **slot;
183:
184:   if (IS_ADHOC_LOC (locus))
185:     locus = get_location_from_adhoc_loc (this, locus);
186:   if (locus == 0 && data == NULL)
187:     return 0;
188:
189:   /* Any ordinary locations ought to be "pure" at this point: no
190:      compressed ranges.  */
191:   linemap_assert (locus < RESERVED_LOCATION_COUNT
192: 		  || locus >= LINE_MAP_MAX_LOCATION_WITH_PACKED_RANGES
193: 		  || locus >= LINEMAPS_MACRO_LOWEST_LOCATION (this)
194: 		  || pure_location_p (locus));
195:
196:   /* Consider short-range optimization.  */
197:   if (can_be_stored_compactly_p (locus, src_range, data, discriminator))
198:     {
199:       /* The low bits ought to be clear.  */
200:       linemap_assert (pure_location_p (locus));
201:       const line_map *map = linemap_lookup (this, locus);
202:       const line_map_ordinary *ordmap = linemap_check_ordinary (map);
203:       auto int_diff = src_range.m_finish - src_range.m_start;
204:       auto col_diff = (int_diff >> ordmap->m_range_bits);
205:       if (col_diff < (loc_one << ordmap->m_range_bits))
206: 	{
207: 	  location_t packed = locus | col_diff;
208: 	  m_num_optimized_ranges++;
209: 	  return packed;
210: 	}
211:     }
212:
213:   /* We can also compactly store locations
214:      when locus == start == finish (and data is NULL).  */
215:   if (locus == src_range.m_start
216:       && locus == src_range.m_finish
217:       && !data && discriminator == 0)
218:     return locus;
219:
220:   if (!data && discriminator == 0)
221:     m_num_unoptimized_ranges++;
222:
223:   lb.locus = locus;
224:   lb.src_range = src_range;
225:   lb.data = data;
226:   lb.discriminator = discriminator;
227:   slot = (struct location_adhoc_data **)
228:       htab_find_slot (m_location_adhoc_data_map.htab, &lb, INSERT);
229:   if (*slot == NULL)
230:     {
231:       if (m_location_adhoc_data_map.curr_loc >=
232: 	  m_location_adhoc_data_map.allocated)
233: 	{
234: 	  const auto orig_data = m_location_adhoc_data_map.data;
235: 	  /* Cast away extern "C" from the type of xrealloc.  */
236: 	  line_map_realloc reallocator = (m_reallocator
237: 					  ? m_reallocator
238: 					  : (line_map_realloc) xrealloc);
239:
240: 	  if (m_location_adhoc_data_map.allocated == 0)
241: 	    m_location_adhoc_data_map.allocated = 128;
242: 	  else
243: 	    m_location_adhoc_data_map.allocated *= 2;
244: 	  m_location_adhoc_data_map.data = (struct location_adhoc_data *)
245: 	      reallocator (m_location_adhoc_data_map.data,
246: 			   m_location_adhoc_data_map.allocated
247: 			   * sizeof (struct location_adhoc_data));
248: 	  if (m_location_adhoc_data_map.allocated > 128)
249: 	    {
250: 	      location_adhoc_data *param[2]
251: 		= {orig_data, m_location_adhoc_data_map.data};
252: 	      htab_traverse (m_location_adhoc_data_map.htab,
253: 			     location_adhoc_data_update, param);
254: 	    }
255: 	}
256:       *slot = m_location_adhoc_data_map.data
257: 	      + m_location_adhoc_data_map.curr_loc;
258:       m_location_adhoc_data_map.data[m_location_adhoc_data_map.curr_loc++]
259: 	= lb;
260:     }
261:   return ((*slot) - m_location_adhoc_data_map.data) | (1 + MAX_LOCATION_T);
```

## libcpp/line-map.cc:437–443
```text
437:   set->highest_location = RESERVED_LOCATION_COUNT - 1;
438:   set->highest_line = RESERVED_LOCATION_COUNT - 1;
439:   set->m_location_adhoc_data_map.htab =
440:       htab_create (100, location_adhoc_data_hash, location_adhoc_data_eq, NULL);
441:   set->builtin_location = builtin_location;
442: }
443:
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

## gcc/ada/gcc-interface/utils.cc:2410–2426
```text
2410:       const unsigned int align = TYPE_ALIGN (record_type);
2411:
2412:       /* If this is a padding record, we never want to make the size smaller
2413: 	 than what was specified in it, if any.  */
2414:       if (TYPE_IS_PADDING_P (record_type) && had_size)
2415: 	size = round_up (TYPE_SIZE (record_type), BITS_PER_UNIT);
2416:       else
2417: 	size = round_up (size, BITS_PER_UNIT);
2418:
2419:       TYPE_SIZE (record_type) = variable_size (round_up (size, align));
2420:
2421:       tree size_unit
2422: 	= convert (sizetype,
2423: 		   size_binop (EXACT_DIV_EXPR, size, bitsize_unit_node));
2424:       TYPE_SIZE_UNIT (record_type)
2425: 	= variable_size (round_up (size_unit, align / BITS_PER_UNIT));
2426:     }
```

## gcc/ada/gcc-interface/utils.cc:4095–4390
```text
4095: max_value (tree exp, bool max_p)
4096: {
4097:   enum tree_code code = TREE_CODE (exp);
4098:   tree type = TREE_TYPE (exp);
4099:   tree op0, op1, op2;
4100:
4101:   switch (TREE_CODE_CLASS (code))
4102:     {
4103:     case tcc_declaration:
4104:       if (VAR_P (exp))
4105:         return fold_convert (type,
4106:                              max_p
4107:                              ? TYPE_MAX_VALUE (type) : TYPE_MIN_VALUE (type));
4108:       break;
4109:
4110:     case tcc_vl_exp:
4111:       if (code == CALL_EXPR)
4112: 	{
4113:           tree t;
4114:
4115:           t = maybe_inline_call_in_expr (exp);
4116:           if (t)
4117:             return max_value (t, max_p);
4118:         }
4119:       break;
4120:
4121:     case tcc_comparison:
4122:       return build_int_cst (type, max_p ? 1 : 0);
4123:
4124:     case tcc_unary:
4125:       op0 = TREE_OPERAND (exp, 0);
4126:
4127:       if (code == NON_LVALUE_EXPR)
4128:         return max_value (op0, max_p);
4129:
4130:       if (code == NEGATE_EXPR)
4131:         return max_value (op0, !max_p);
4132:
4133:       if (code == NOP_EXPR)
4134: 	return fold_convert (type, max_value (op0, max_p));
4135:
4136:       break;
4137:
4138:     case tcc_binary:
4139:       op0 = TREE_OPERAND (exp, 0);
4140:       op1 = TREE_OPERAND (exp, 1);
4141:
4142:       switch (code) {
4143:       case PLUS_EXPR:
4144:       case MULT_EXPR:
4145:         return fold_build2 (code, type, max_value(op0, max_p),
4146:                             max_value (op1, max_p));
4147:       case MINUS_EXPR:
4148:       case TRUNC_DIV_EXPR:
4149:         return fold_build2 (code, type, max_value(op0, max_p),
4150:                             max_value (op1, !max_p));
4151:       default:
4152:         break;
4153:       }
4154:       break;
4155:
4156:     case tcc_expression:
4157:       if (code == COND_EXPR)
4158:         {
4159:           op0 = TREE_OPERAND (exp, 0);
4160:           op1 = TREE_OPERAND (exp, 1);
4161:           op2 = TREE_OPERAND (exp, 2);
4162:
4163:           if (!op1 || !op2)
4164:             break;
4165:
4166:           op1 = max_value (op1, max_p);
4167:           op2 = max_value (op2, max_p);
4168:
4169:           if (op1 == TREE_OPERAND (exp, 1) && op2 == TREE_OPERAND (exp, 2))
4170:             break;
4171:
4172:           return fold_build2 (max_p ? MAX_EXPR : MIN_EXPR, type, op1, op2);
4173: 	}
4174:       break;
4175:
4176:     default:
4177:       break;
4178:     }
4179:   return exp;
4180: }
4181:
4182:
4183: /* EXP is an expression for the size of an object.  If this size contains
4184:    discriminant references, replace them with the maximum (if MAX_P) or
4185:    minimum (if !MAX_P) possible value of the discriminant.
4186:
4187:    Note that the expression may have already been gimplified,in which case
4188:    COND_EXPRs have VOID_TYPE and no operands, and this must be handled.  */
4189:
4190: tree
4191: max_size (tree exp, bool max_p)
4192: {
4193:   enum tree_code code = TREE_CODE (exp);
4194:   tree type = TREE_TYPE (exp);
4195:   tree op0, op1, op2;
4196:
4197:   switch (TREE_CODE_CLASS (code))
4198:     {
4199:     case tcc_declaration:
4200:     case tcc_constant:
4201:       return exp;
4202:
4203:     case tcc_exceptional:
4204:       gcc_assert (code == SSA_NAME);
4205:       return exp;
4206:
4207:     case tcc_vl_exp:
4208:       if (code == CALL_EXPR)
4209: 	{
4210: 	  tree t, *argarray;
4211: 	  int n, i;
4212:
4213: 	  t = maybe_inline_call_in_expr (exp);
4214: 	  if (t)
4215: 	    return max_size (t, max_p);
4216:
4217: 	  n = call_expr_nargs (exp);
4218: 	  gcc_assert (n > 0);
4219: 	  argarray = XALLOCAVEC (tree, n);
4220: 	  /* This is used to remove possible placeholder in call args.  */
4221: 	  for (i = 0; i < n; i++)
4222: 	    argarray[i] = max_size (CALL_EXPR_ARG (exp, i), max_p);
4223: 	  return build_call_array (type, CALL_EXPR_FN (exp), n, argarray);
4224: 	}
4225:       break;
4226:
4227:     case tcc_reference:
4228:       /* If this contains a PLACEHOLDER_EXPR, it is the thing we want to
4229: 	 modify.  Otherwise, we treat it like a variable.  */
4230:       if (CONTAINS_PLACEHOLDER_P (exp))
4231: 	{
4232: 	  tree base_type = get_base_type (TREE_TYPE (TREE_OPERAND (exp, 1)));
4233: 	  tree val
4234: 	    = fold_convert (base_type,
4235: 			    max_p
4236: 			    ? TYPE_MAX_VALUE (type) : TYPE_MIN_VALUE (type));
4237:
4238: 	  /* Walk down the extra subtypes to get more restrictive bounds.  */
4239: 	  while (TYPE_IS_EXTRA_SUBTYPE_P (type))
4240: 	    {
4241: 	      type = TREE_TYPE (type);
4242: 	      if (max_p)
4243: 		val = fold_build2 (MIN_EXPR, base_type, val,
4244: 				   fold_convert (base_type,
4245: 						 TYPE_MAX_VALUE (type)));
4246: 	      else
4247: 		val = fold_build2 (MAX_EXPR, base_type, val,
4248: 				   fold_convert (base_type,
4249: 						 TYPE_MIN_VALUE (type)));
4250: 	    }
4251:
4252: 	  return fold_convert (type, max_size (val, max_p));
4253: 	}
4254:
4255:       return exp;
4256:
4257:     case tcc_comparison:
4258:       return build_int_cst (type, max_p ? 1 : 0);
4259:
4260:     case tcc_unary:
4261:       op0 = TREE_OPERAND (exp, 0);
4262:
4263:       if (code == NON_LVALUE_EXPR)
4264: 	return max_size (op0, max_p);
4265:
4266:       if (VOID_TYPE_P (TREE_TYPE (op0)))
4267: 	return max_p ? TYPE_MAX_VALUE (type) : TYPE_MIN_VALUE (type);
4268:
4269:       op0 = max_size (op0, code == NEGATE_EXPR ? !max_p : max_p);
4270:
4271:       if (op0 == TREE_OPERAND (exp, 0))
4272: 	return exp;
4273:
4274:       return fold_build1 (code, type, op0);
4275:
4276:     case tcc_binary:
4277:       op0 = TREE_OPERAND (exp, 0);
4278:       op1 = TREE_OPERAND (exp, 1);
4279:
4280:       /* If we have a multiply-add with a "negative" value in an unsigned
4281: 	 type, do a multiply-subtract with the negated value, in order to
4282: 	 avoid creating a spurious overflow below.  */
4283:       if (code == PLUS_EXPR
4284: 	  && TREE_CODE (op0) == MULT_EXPR
4285: 	  && TYPE_UNSIGNED (type)
4286: 	  && TREE_CODE (TREE_OPERAND (op0, 1)) == INTEGER_CST
4287: 	  && !TREE_OVERFLOW (TREE_OPERAND (op0, 1))
4288: 	  && tree_int_cst_sign_bit (TREE_OPERAND (op0, 1)))
4289: 	{
4290: 	  tree tmp = op1;
4291: 	  op1 = build2 (MULT_EXPR, type, TREE_OPERAND (op0, 0),
4292: 			fold_build1 (NEGATE_EXPR, type,
4293: 				    TREE_OPERAND (op0, 1)));
4294: 	  op0 = tmp;
4295: 	  code = MINUS_EXPR;
4296: 	}
4297:
4298:       op0 = max_size (op0, max_p);
4299:       op1 = max_size (op1, code == MINUS_EXPR ? !max_p : max_p);
4300:
4301:       if ((code == MINUS_EXPR || code == PLUS_EXPR))
4302: 	{
4303: 	  /* If the op0 has overflowed and the op1 is a variable,
4304: 	     propagate the overflow by returning the op0.  */
4305: 	  if (TREE_CODE (op0) == INTEGER_CST
4306: 	      && TREE_OVERFLOW (op0)
4307: 	      && TREE_CODE (op1) != INTEGER_CST)
4308: 	    return op0;
4309:
4310: 	  /* If we have a "negative" value in an unsigned type, do the
4311: 	     opposite operation on the negated value, in order to avoid
4312: 	     creating a spurious overflow below.  */
4313: 	  if (TYPE_UNSIGNED (type)
4314: 	      && TREE_CODE (op1) == INTEGER_CST
4315: 	      && !TREE_OVERFLOW (op1)
4316: 	      && tree_int_cst_sign_bit (op1))
4317: 	    {
4318: 	      op1 = fold_build1 (NEGATE_EXPR, type, op1);
4319: 	      code = (code == MINUS_EXPR ? PLUS_EXPR : MINUS_EXPR);
4320: 	    }
4321: 	}
4322:
4323:       if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1))
4324: 	return exp;
4325:
4326:       /* We need to detect overflows so we call size_binop here.  */
4327:       return size_binop (code, op0, op1);
4328:
4329:     case tcc_expression:
4330:       switch (TREE_CODE_LENGTH (code))
4331: 	{
4332: 	case 1:
4333: 	  if (code == SAVE_EXPR)
4334: 	    return exp;
4335:
4336: 	  op0 = max_size (TREE_OPERAND (exp, 0),
4337: 			  code == TRUTH_NOT_EXPR ? !max_p : max_p);
4338:
4339: 	  if (op0 == TREE_OPERAND (exp, 0))
4340: 	    return exp;
4341:
4342: 	  return fold_build1 (code, type, op0);
4343:
4344: 	case 2:
4345: 	  if (code == COMPOUND_EXPR)
4346: 	    return max_size (TREE_OPERAND (exp, 1), max_p);
4347:
4348: 	  op0 = max_size (TREE_OPERAND (exp, 0), max_p);
4349: 	  op1 = max_size (TREE_OPERAND (exp, 1), max_p);
4350:
4351: 	  if (op0 == TREE_OPERAND (exp, 0) && op1 == TREE_OPERAND (exp, 1))
4352: 	    return exp;
4353:
4354: 	  return fold_build2 (code, type, op0, op1);
4355:
4356: 	case 3:
4357: 	  if (code == COND_EXPR)
4358: 	    {
4359: 	      op0 = TREE_OPERAND (exp, 0);
4360: 	      op1 = TREE_OPERAND (exp, 1);
4361: 	      op2 = TREE_OPERAND (exp, 2);
4362:
4363: 	      if (!op1 || !op2)
4364: 		return exp;
4365:
4366: 	      op1 = max_size (op1, max_p);
4367: 	      op2 = max_size (op2, max_p);
4368:
4369: 	      /* If we have the MAX of a "negative" value in an unsigned type
4370: 		 and zero for a length expression, just return zero.  */
4371: 	      if (max_p
4372: 		  && TREE_CODE (op0) == LE_EXPR
4373: 		  && TYPE_UNSIGNED (type)
4374: 		  && TREE_CODE (op1) == INTEGER_CST
4375: 		  && !TREE_OVERFLOW (op1)
4376: 		  && tree_int_cst_sign_bit (op1)
4377: 		  && integer_zerop (op2))
4378: 		return op2;
4379:
4380: 	      return fold_build2 (max_p ? MAX_EXPR : MIN_EXPR, type, op1, op2);
4381: 	    }
4382: 	  break;
4383:
4384: 	default:
4385: 	  break;
4386: 	}
4387:
4388:       /* Other tree classes cannot happen.  */
4389:     default:
4390:       break;
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

## include/hashtab.h:94–137
```text
94:
95: struct htab {
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

## gcc/ada/gcc-interface/decl.cc:2370–2380
```text
2370: 	       with languages for which the regular fields are addressable.  */
2371: 	    fld
2372: 	      = create_field_decl (get_identifier ("P_ARRAY"),
2373: 				   ptr_type_node, gnu_fat_type,
2374: 				   NULL_TREE, NULL_TREE, 0, 1);
2375: 	    DECL_CHAIN (fld)
2376: 	      = create_field_decl (get_identifier ("P_BOUNDS"),
2377: 				   gnu_ptr_template, gnu_fat_type,
2378: 				   NULL_TREE, NULL_TREE, 0, 1);
2379: 	    finish_fat_pointer_type (gnu_fat_type, fld);
2380: 	    SET_TYPE_UNCONSTRAINED_ARRAY (gnu_fat_type, gnu_type);
```

## gcc/ada/gcc-interface/decl.cc:2664–2712
```text
2664: 	      /* Update the maximum size of the array in elements.  Here we
2665: 		 see if any constraint on the index type of the base type
2666: 		 can be used in the case of self-referential bounds on the
2667: 		 index type of the array type. We look for a non-"infinite"
2668: 		 and non-self-referential bound from any type involved and
2669: 		 handle each bound separately.  */
2670: 	      if (gnu_max_size)
2671: 		{
2672: 		  if (CONTAINS_PLACEHOLDER_P (gnu_orig_min))
2673: 		    gnu_min = gnu_base_orig_min;
2674: 		  else
2675: 		    gnu_min = gnu_orig_min;
2676:
2677: 		  if (DECL_P (gnu_min)
2678: 		      && DECL_INITIAL (gnu_min) != NULL_TREE
2679: 		      && (TREE_CODE (gnu_min) != INTEGER_CST
2680: 			  || TREE_OVERFLOW (gnu_min)))
2681: 		    {
2682: 		      tree tmp = max_value (DECL_INITIAL(gnu_min), false);
2683: 		      if (TREE_CODE (tmp) == INTEGER_CST
2684: 			  && !TREE_OVERFLOW (tmp))
2685: 			gnu_min = tmp;
2686: 		    }
2687:
2688: 		  if (TREE_CODE (gnu_min) != INTEGER_CST
2689: 		      || TREE_OVERFLOW (gnu_min))
2690: 		    gnu_min = TYPE_MIN_VALUE (TREE_TYPE (gnu_min));
2691:
2692: 		  if (CONTAINS_PLACEHOLDER_P (gnu_orig_max))
2693: 		    gnu_max = gnu_base_orig_max;
2694: 		  else
2695: 		    gnu_max = gnu_orig_max;
2696:
2697: 		  if (DECL_P (gnu_max)
2698: 		      && DECL_INITIAL (gnu_max) != NULL_TREE
2699: 		      && (TREE_CODE (gnu_max) != INTEGER_CST
2700: 			  || TREE_OVERFLOW (gnu_max)))
2701: 		    {
2702: 		      tree tmp = max_value (DECL_INITIAL(gnu_max), true);
2703: 		      if (TREE_CODE (tmp) == INTEGER_CST
2704: 			  && !TREE_OVERFLOW (tmp))
2705: 			gnu_max = tmp;
2706: 		    }
2707:
2708: 		  if (TREE_CODE (gnu_max) != INTEGER_CST
2709: 		      || TREE_OVERFLOW (gnu_max))
2710: 		    gnu_max = TYPE_MAX_VALUE (TREE_TYPE (gnu_max));
2711:
2712: 		  gnu_max_size
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

## gcc/ada/gcc-interface/decl.cc:7265–7402
```text
7265: build_template_type (Entity_Id gnat_entity, tree gnu_template_type,
7266: 		     tree gnu_template_reference,
7267: 		     tree *gnu_index_types, tree &gnu_max_size,
7268: 		     bool debug_info_p)
7269: {
7270:   const bool convention_fortran_p
7271:     = (Convention (gnat_entity) == Convention_Fortran);
7272:   const int ndim = Number_Dimensions (gnat_entity);
7273:   tree *gnu_temp_fields = XALLOCAVEC (tree, ndim);
7274:   Entity_Id gnat_index;
7275:   int index;
7276:
7277:   tree template_fields = TYPE_FIELDS (gnu_template_type);
7278:   const bool template_exists_p = template_fields != NULL_TREE;
7279:
7280:   /* Now create the GCC type for each index and add the fields for that
7281:      index to the template.  */
7282:   for (index = (convention_fortran_p ? ndim - 1 : 0),
7283:        gnat_index = First_Index (gnat_entity);
7284:        IN_RANGE (index, 0, ndim - 1);
7285:        index += (convention_fortran_p ? - 1 : 1),
7286:        gnat_index = Next_Index (gnat_index))
7287:     {
7288:       const Entity_Id gnat_index_type = Etype (gnat_index);
7289:       const bool is_flb = Is_Fixed_Lower_Bound_Index_Subtype (gnat_index_type);
7290:       tree gnu_index_type = get_unpadded_type (gnat_index_type);
7291:       tree gnu_orig_min = TYPE_MIN_VALUE (gnu_index_type);
7292:       tree gnu_orig_max = TYPE_MAX_VALUE (gnu_index_type);
7293:       tree gnu_index_base_type = get_base_type (gnu_index_type);
7294:       tree gnu_lb_field, gnu_hb_field;
7295:       tree gnu_min, gnu_max, gnu_high;
7296:       char field_name[16];
7297:
7298:       /* Update the maximum size of the array in elements.  */
7299:       if (gnu_max_size)
7300: 	gnu_max_size
7301: 	  = update_n_elem (gnu_max_size, gnu_orig_min, gnu_orig_max);
7302:
7303:       /* Now build the self-referential bounds of the index type.  */
7304:       gnu_index_type = maybe_character_type (gnu_index_type);
7305:       gnu_index_base_type = maybe_character_type (gnu_index_base_type);
7306:
7307:       if (template_fields != NULL_TREE)
7308: 	{
7309: 	  gnu_lb_field = template_fields;
7310: 	  template_fields = DECL_CHAIN (template_fields);
7311: 	  gnu_hb_field = template_fields;
7312: 	  template_fields = DECL_CHAIN (template_fields);
7313: 	}
7314:       else
7315: 	{
7316: 	  /* Make the FIELD_DECLs for the low and high bounds of this
7317: 	     type and then make extractions of these fields from the
7318: 	     template.  */
7319: 	  sprintf (field_name, "LB%d", index);
7320: 	  gnu_lb_field = create_field_decl (get_identifier (field_name),
7321: 					    gnu_index_type,
7322: 					    gnu_template_type, NULL_TREE,
7323: 					    NULL_TREE, 0, 0);
7324: 	  /* Mark the field specifically for INSTANTIATE_LOAD_IN_EXPR.  */
7325: 	  DECL_DISCRIMINANT_NUMBER (gnu_lb_field) = integer_minus_one_node;
7326: 	  Sloc_to_locus (Sloc (gnat_entity), &DECL_SOURCE_LOCATION (gnu_lb_field));
7327:
7328: 	  field_name[0] = 'U';
7329: 	  gnu_hb_field = create_field_decl (get_identifier (field_name),
7330: 					    gnu_index_type,
7331: 					    gnu_template_type, NULL_TREE,
7332: 					    NULL_TREE, 0, 0);
7333: 	  /* Mark the field specifically for INSTANTIATE_LOAD_IN_EXPR.  */
7334: 	  DECL_DISCRIMINANT_NUMBER (gnu_hb_field) = integer_minus_one_node;
7335: 	  Sloc_to_locus (Sloc (gnat_entity), &DECL_SOURCE_LOCATION (gnu_hb_field));
7336:
7337: 	  gnu_temp_fields[index] = chainon (gnu_lb_field, gnu_hb_field);
7338: 	}
7339:
7340:       if (gnu_index_types)
7341: 	{
7342: 	  /* We can't use build_component_ref here since the template type
7343: 	     isn't complete yet.  */
7344: 	  if (!is_flb)
7345: 	    {
7346: 	      gnu_orig_min
7347: 		= build3 (COMPONENT_REF, TREE_TYPE (gnu_lb_field),
7348: 			  gnu_template_reference, gnu_lb_field,
7349: 			  NULL_TREE);
7350: 	      TREE_READONLY (gnu_orig_min) = 1;
7351: 	    }
7352:
7353: 	  gnu_orig_max = build3 (COMPONENT_REF, TREE_TYPE (gnu_hb_field),
7354: 				 gnu_template_reference, gnu_hb_field,
7355: 				 NULL_TREE);
7356: 	  TREE_READONLY (gnu_orig_max) = 1;
7357:
7358: 	  gnu_min = convert (sizetype, gnu_orig_min);
7359: 	  gnu_max = convert (sizetype, gnu_orig_max);
7360:
7361: 	  /* Compute the size of this dimension.  See the E_Array_Subtype
7362: 	     case of gnat_to_gnu_entity for the rationale.  */
7363: 	  if (is_flb
7364: 	      && Nkind (gnat_index) == N_Subtype_Indication
7365: 	      && flb_cannot_be_superflat (gnat_index))
7366: 	    gnu_high = gnu_max;
7367:
7368: 	  else
7369: 	    gnu_high
7370: 	      = build3 (COND_EXPR, sizetype,
7371: 			build2 (GE_EXPR, boolean_type_node,
7372: 				gnu_orig_max, gnu_orig_min),
7373: 			gnu_max,
7374: 			TREE_CODE (gnu_min) == INTEGER_CST
7375: 			? int_const_binop (MINUS_EXPR, gnu_min, size_one_node)
7376: 			: size_binop (MINUS_EXPR, gnu_min, size_one_node));
7377:
7378: 	  /* Make a range type with the new range in the Ada base type.
7379: 	     Then make an index type with the size range in sizetype.  */
7380: 	  gnu_index_types[index]
7381: 	    = create_index_type (gnu_min, gnu_high,
7382: 				 create_range_type (gnu_index_base_type,
7383: 						    gnu_orig_min,
7384: 						    gnu_orig_max),
7385: 				 gnat_entity);
7386:
7387: 	  TYPE_NAME (gnu_index_types[index])
7388: 	    = create_concat_name (gnat_entity, field_name);
7389: 	}
7390:     }
7391:
7392:   if (!template_exists_p)
7393:     {
7394:       TYPE_NAMELESS (gnu_template_type)
7395: 	= gnat_encodings != DWARF_GNAT_ENCODINGS_ALL;
7396:
7397:       tree gnu_template_fields = NULL_TREE;
7398:       for (index = 0; index < ndim; index++)
7399: 	gnu_template_fields
7400: 	  = chainon (gnu_template_fields, gnu_temp_fields[index]);
7401:       finish_record_type (gnu_template_type, gnu_template_fields, 0, debug_info_p);
7402:     }
```

## gcc/ada/gcc-interface/decl.cc:9322–9520
```text
9322: annotate_value (tree gnu_size)
9323: {
9324:   static int var_count = 0;
9325:   TCode tcode;
9326:   Node_Ref_Or_Val ops[3] = { No_Uint, No_Uint, No_Uint };
9327:   struct tree_int_map in;
9328:
9329:   /* See if we've already saved the value for this node.  */
9330:   if (EXPR_P (gnu_size) || DECL_P (gnu_size))
9331:     {
9332:       struct tree_int_map *e;
9333:
9334:       in.base.from = gnu_size;
9335:       e = annotate_value_cache->find (&in);
9336:
9337:       if (e)
9338: 	return (Node_Ref_Or_Val) e->to;
9339:     }
9340:   else
9341:     in.base.from = NULL_TREE;
9342:
9343:   /* If we do not return inside this switch, TCODE will be set to the
9344:      code to be used in a call to Create_Node.  */
9345:   switch (TREE_CODE (gnu_size))
9346:     {
9347:     case INTEGER_CST:
9348:       /* For negative values, build NEGATE_EXPR of the opposite.  Such values
9349: 	 can appear for discriminants in expressions for variants.  */
9350:       if (tree_int_cst_sgn (gnu_size) < 0)
9351: 	{
9352: 	  tree t = wide_int_to_tree (sizetype, -wi::to_wide (gnu_size));
9353: 	  tcode = Negate_Expr;
9354: 	  ops[0] = UI_From_gnu (t);
9355: 	}
9356:       else
9357: 	return TREE_OVERFLOW (gnu_size) ? No_Uint : UI_From_gnu (gnu_size);
9358:       break;
9359:
9360:     case COMPONENT_REF:
9361:       /* The only case we handle here is a simple discriminant reference.  */
9362:       if (DECL_DISCRIMINANT_NUMBER (TREE_OPERAND (gnu_size, 1)))
9363: 	{
9364: 	  tree ref = gnu_size;
9365: 	  gnu_size = TREE_OPERAND (ref, 1);
9366:
9367: 	  /* Climb up the chain of successive extensions, if any.  */
9368: 	  while (TREE_CODE (TREE_OPERAND (ref, 0)) == COMPONENT_REF
9369: 		 && DECL_NAME (TREE_OPERAND (TREE_OPERAND (ref, 0), 1))
9370: 		    == parent_name_id)
9371: 	    ref = TREE_OPERAND (ref, 0);
9372:
9373: 	  if (TREE_CODE (TREE_OPERAND (ref, 0)) == PLACEHOLDER_EXPR)
9374: 	    {
9375: 	      /* Fall through to common processing as a FIELD_DECL.  */
9376: 	      tcode = Discrim_Val;
9377: 	      ops[0] = UI_From_gnu (DECL_DISCRIMINANT_NUMBER (gnu_size));
9378: 	    }
9379: 	  else
9380: 	    return No_Uint;
9381: 	}
9382:       else
9383: 	return No_Uint;
9384:       break;
9385:
9386:     case PARM_DECL:
9387:     case VAR_DECL:
9388:       tcode = Dynamic_Val;
9389:       ops[0] = UI_From_Int (++var_count);
9390:       break;
9391:
9392:     CASE_CONVERT:
9393:     case NON_LVALUE_EXPR:
9394:       return annotate_value (TREE_OPERAND (gnu_size, 0));
9395:
9396:       /* Now just list the operations we handle.  */
9397:     case COND_EXPR:		tcode = Cond_Expr; break;
9398:     case MINUS_EXPR:		tcode = Minus_Expr; break;
9399:     case TRUNC_DIV_EXPR:	tcode = Trunc_Div_Expr; break;
9400:     case CEIL_DIV_EXPR:		tcode = Ceil_Div_Expr; break;
9401:     case FLOOR_DIV_EXPR:	tcode = Floor_Div_Expr; break;
9402:     case TRUNC_MOD_EXPR:	tcode = Trunc_Mod_Expr; break;
9403:     case CEIL_MOD_EXPR:		tcode = Ceil_Mod_Expr; break;
9404:     case FLOOR_MOD_EXPR:	tcode = Floor_Mod_Expr; break;
9405:     case EXACT_DIV_EXPR:	tcode = Exact_Div_Expr; break;
9406:     case NEGATE_EXPR:		tcode = Negate_Expr; break;
9407:     case MIN_EXPR:		tcode = Min_Expr; break;
9408:     case MAX_EXPR:		tcode = Max_Expr; break;
9409:     case ABS_EXPR:		tcode = Abs_Expr; break;
9410:     case TRUTH_ANDIF_EXPR:
9411:     case TRUTH_AND_EXPR:	tcode = Truth_And_Expr; break;
9412:     case TRUTH_ORIF_EXPR:
9413:     case TRUTH_OR_EXPR:		tcode = Truth_Or_Expr; break;
9414:     case TRUTH_XOR_EXPR:	tcode = Truth_Xor_Expr; break;
9415:     case TRUTH_NOT_EXPR:	tcode = Truth_Not_Expr; break;
9416:     case LT_EXPR:		tcode = Lt_Expr; break;
9417:     case LE_EXPR:		tcode = Le_Expr; break;
9418:     case GT_EXPR:		tcode = Gt_Expr; break;
9419:     case GE_EXPR:		tcode = Ge_Expr; break;
9420:     case EQ_EXPR:		tcode = Eq_Expr; break;
9421:     case NE_EXPR:		tcode = Ne_Expr; break;
9422:
9423:     case PLUS_EXPR:
9424:       /* Turn addition of negative constant into subtraction.  */
9425:       if (TREE_CODE (TREE_OPERAND (gnu_size, 1)) == INTEGER_CST
9426: 	  && tree_int_cst_sign_bit (TREE_OPERAND (gnu_size, 1)))
9427: 	{
9428: 	  tcode = Minus_Expr;
9429: 	  wide_int wop1 = -wi::to_wide (TREE_OPERAND (gnu_size, 1));
9430: 	  ops[1] = annotate_value (wide_int_to_tree (sizetype, wop1));
9431: 	  break;
9432: 	}
9433:
9434:       /* ... fall through ... */
9435:
9436:     case MULT_EXPR:
9437:       tcode = (TREE_CODE (gnu_size) == MULT_EXPR ? Mult_Expr : Plus_Expr);
9438:       /* Fold conversions from bytes to bits into inner operations.  */
9439:       if (TREE_CODE (TREE_OPERAND (gnu_size, 1)) == INTEGER_CST
9440: 	  && CONVERT_EXPR_P (TREE_OPERAND (gnu_size, 0)))
9441: 	{
9442: 	  tree inner_op = TREE_OPERAND (TREE_OPERAND (gnu_size, 0), 0);
9443: 	  if (TREE_CODE (inner_op) == TREE_CODE (gnu_size)
9444: 	      && TREE_CODE (TREE_OPERAND (inner_op, 1)) == INTEGER_CST)
9445: 	    {
9446: 	      ops[0] = annotate_value (TREE_OPERAND (inner_op, 0));
9447: 	      tree inner_op_op1 = TREE_OPERAND (inner_op, 1);
9448: 	      tree gnu_size_op1 = TREE_OPERAND (gnu_size, 1);
9449: 	      widest_int op1;
9450: 	      if (TREE_CODE (gnu_size) == MULT_EXPR)
9451: 		op1 = (wi::to_widest (inner_op_op1)
9452: 		       * wi::to_widest (gnu_size_op1));
9453: 	      else
9454: 		{
9455: 		  op1 = (wi::to_widest (inner_op_op1)
9456: 			 + wi::to_widest (gnu_size_op1));
9457: 		  if (wi::zext (op1, TYPE_PRECISION (sizetype)) == 0)
9458: 		    return ops[0];
9459: 		}
9460: 	      ops[1] = annotate_value (wide_int_to_tree (sizetype, op1));
9461: 	    }
9462: 	}
9463:       break;
9464:
9465:     case BIT_AND_EXPR:
9466:       tcode = Bit_And_Expr;
9467:       /* For negative values in sizetype, build NEGATE_EXPR of the opposite.
9468: 	 Such values can appear in expressions with aligning patterns.  */
9469:       if (TREE_CODE (TREE_OPERAND (gnu_size, 1)) == INTEGER_CST)
9470: 	{
9471: 	  wide_int wop1 = -wi::to_wide (TREE_OPERAND (gnu_size, 1));
9472: 	  tree op1 = wide_int_to_tree (sizetype, wop1);
9473: 	  ops[1] = annotate_value (build1 (NEGATE_EXPR, sizetype, op1));
9474: 	}
9475:       break;
9476:
9477:     case CALL_EXPR:
9478:       /* In regular mode, inline back only if symbolic annotation is requested
9479: 	 in order to avoid memory explosion on big discriminated record types.
9480: 	 But not in ASIS mode, as symbolic annotation is required for DDA.  */
9481:       if (List_Representation_Info >= 3 || type_annotate_only)
9482: 	{
9483: 	  tree t = maybe_inline_call_in_expr (gnu_size);
9484: 	  return t ? annotate_value (t) : No_Uint;
9485: 	}
9486:       else
9487: 	return Uint_Minus_1;
9488:
9489:     default:
9490:       return No_Uint;
9491:     }
9492:
9493:   /* Now get each of the operands that's relevant for this code.  If any
9494:      cannot be expressed as a repinfo node, say we can't.  */
9495:   for (int i = 0; i < TREE_CODE_LENGTH (TREE_CODE (gnu_size)); i++)
9496:     if (ops[i] == No_Uint)
9497:       {
9498: 	ops[i] = annotate_value (TREE_OPERAND (gnu_size, i));
9499: 	if (ops[i] == No_Uint)
9500: 	  return No_Uint;
9501:       }
9502:
9503:   Node_Ref_Or_Val ret = Create_Node (tcode, ops[0], ops[1], ops[2]);
9504:
9505:   /* Save the result in the cache.  */
9506:   if (in.base.from)
9507:     {
9508:       struct tree_int_map **h;
9509:       /* We can't assume the hash table data hasn't moved since the initial
9510: 	 look up, so we have to search again.  Allocating and inserting an
9511: 	 entry at that point would be an alternative, but then we'd better
9512: 	 discard the entry if we decided not to cache it.  */
9513:       h = annotate_value_cache->find_slot (&in, INSERT);
9514:       gcc_assert (!*h);
9515:       *h = ggc_alloc<tree_int_map> ();
9516:       (*h)->base.from = in.base.from;
9517:       (*h)->to = ret;
9518:     }
9519:
9520:   return ret;
```

## gcc/ada/gcc-interface/decl.cc:10460–10501
```text
10460: create_field_decl_from (tree old_field, tree field_type, tree record_type,
10461: 			tree size, tree pos_list,
10462: 			vec<subst_pair> subst_list)
10463: {
10464:   tree t = TREE_VALUE (purpose_member (old_field, pos_list));
10465:   tree pos = TREE_VEC_ELT (t, 0), bitpos = TREE_VEC_ELT (t, 2);
10466:   unsigned int offset_align = tree_to_uhwi (TREE_VEC_ELT (t, 1));
10467:   tree new_pos, new_field;
10468:   unsigned int i;
10469:   subst_pair *s;
10470:
10471:   if (CONTAINS_PLACEHOLDER_P (pos))
10472:     FOR_EACH_VEC_ELT (subst_list, i, s)
10473:       pos = SUBSTITUTE_IN_EXPR (pos, s->discriminant, s->replacement);
10474:
10475:   /* If the position is now a constant, we can set it as the position of the
10476:      field when we make it.  Otherwise, we need to deal with it specially.  */
10477:   if (TREE_CONSTANT (pos))
10478:     new_pos = bit_from_pos (pos, bitpos);
10479:   else
10480:     new_pos = NULL_TREE;
10481:
10482:   new_field
10483:     = create_field_decl (DECL_NAME (old_field), field_type, record_type,
10484: 			 size, new_pos, DECL_PACKED (old_field),
10485: 			 !DECL_NONADDRESSABLE_P (old_field));
10486:
10487:   if (!new_pos)
10488:     {
10489:       normalize_offset (&pos, &bitpos, offset_align);
10490:       /* Finalize the position.  */
10491:       DECL_FIELD_OFFSET (new_field) = variable_size (pos);
10492:       DECL_FIELD_BIT_OFFSET (new_field) = bitpos;
10493:       SET_DECL_OFFSET_ALIGN (new_field, offset_align);
10494:       DECL_SIZE (new_field) = size;
10495:       DECL_SIZE_UNIT (new_field)
10496: 	= convert (sizetype,
10497: 		   size_binop (CEIL_DIV_EXPR, size, bitsize_unit_node));
10498:       layout_decl (new_field, DECL_OFFSET_ALIGN (new_field));
10499:     }
10500:
10501:   DECL_INTERNAL_P (new_field) = DECL_INTERNAL_P (old_field);
```

## gcc/ada/gcc-interface/decl.cc:10685–10723
```text
10685: /* Copy the size (and alignment and alias set) from OLD_TYPE to NEW_TYPE,
10686:    which are both RECORD_TYPE, after applying the substitutions described
10687:    in SUBST_LIST.  */
10688:
10689: static void
10690: copy_and_substitute_in_size (tree new_type, tree old_type,
10691: 			     vec<subst_pair> subst_list)
10692: {
10693:   unsigned int i;
10694:   subst_pair *s;
10695:
10696:   TYPE_SIZE (new_type) = TYPE_SIZE (old_type);
10697:   TYPE_SIZE_UNIT (new_type) = TYPE_SIZE_UNIT (old_type);
10698:   SET_TYPE_ADA_SIZE (new_type, TYPE_ADA_SIZE (old_type));
10699:   SET_TYPE_ALIGN (new_type, TYPE_ALIGN (old_type));
10700:   relate_alias_sets (new_type, old_type, ALIAS_SET_COPY);
10701:
10702:   if (CONTAINS_PLACEHOLDER_P (TYPE_SIZE (new_type)))
10703:     FOR_EACH_VEC_ELT (subst_list, i, s)
10704:       TYPE_SIZE (new_type)
10705: 	= SUBSTITUTE_IN_EXPR (TYPE_SIZE (new_type),
10706: 			      s->discriminant, s->replacement);
10707:
10708:   if (CONTAINS_PLACEHOLDER_P (TYPE_SIZE_UNIT (new_type)))
10709:     FOR_EACH_VEC_ELT (subst_list, i, s)
10710:       TYPE_SIZE_UNIT (new_type)
10711: 	= SUBSTITUTE_IN_EXPR (TYPE_SIZE_UNIT (new_type),
10712: 			      s->discriminant, s->replacement);
10713:
10714:   if (CONTAINS_PLACEHOLDER_P (TYPE_ADA_SIZE (new_type)))
10715:     FOR_EACH_VEC_ELT (subst_list, i, s)
10716:       SET_TYPE_ADA_SIZE
10717: 	(new_type, SUBSTITUTE_IN_EXPR (TYPE_ADA_SIZE (new_type),
10718: 				       s->discriminant, s->replacement));
10719:
10720:   /* Finalize the size.  */
10721:   TYPE_SIZE (new_type) = variable_size (TYPE_SIZE (new_type));
10722:   TYPE_SIZE_UNIT (new_type) = variable_size (TYPE_SIZE_UNIT (new_type));
10723: }
```

## gcc/ada/gcc-interface/decl.cc:11324–11343
```text
11324: void
11325: init_gnat_decl (void)
11326: {
11327:   /* Initialize the cache of annotated values.  */
11328:   annotate_value_cache = hash_table<value_annotation_hasher>::create_ggc (512);
11329:
11330:   /* Initialize the association of dummy types with subprograms.  */
11331:   dummy_to_subprog_map = hash_table<dummy_type_hasher>::create_ggc (512);
11332: }
11333:
11334: /* Destroy the data structures of the decl.cc module.  */
11335:
11336: void
11337: destroy_gnat_decl (void)
11338: {
11339:   /* Destroy the cache of annotated values.  */
11340:   annotate_value_cache->empty ();
11341:   annotate_value_cache = NULL;
11342:
11343:   /* Destroy the association of dummy types with subprograms.  */
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

## gcc/vec.h:731–740
```text
731: /* Allocate GC memory for V with space for NELEMS slots.  If NELEMS
732:    is 0, V is initialized to NULL.  */
733:
734: template<typename T, typename A>
735: inline void
736: vec_alloc (vec<T, A, vl_embed> *&v, unsigned nelems CXX_MEM_STAT_INFO)
737: {
738:   v = NULL;
739:   vec_safe_reserve (v, nelems, false PASS_MEM_STAT);
740: }
```

## gcc/vec.h:863–868
```text
863: template<typename T, typename A>
864: inline vec<T, A, vl_embed> *
865: vec_safe_copy (vec<T, A, vl_embed> *src CXX_MEM_STAT_INFO)
866: {
867:   return src ? src->copy (ALONE_PASS_MEM_STAT) : NULL;
868: }
```

## gcc/vec.h:999–1016
```text
999: /* Return a pointer to a copy of this vector.  */
1000:
1001: template<typename T, typename A>
1002: inline vec<T, A, vl_embed> *
1003: vec<T, A, vl_embed>::copy (ALONE_MEM_STAT_DECL) const
1004: {
1005:   vec<T, A, vl_embed> *new_vec = NULL;
1006:   unsigned len = length ();
1007:   if (len)
1008:     {
1009:       vec_alloc (new_vec, len PASS_MEM_STAT);
1010:       new_vec->embedded_init (len, len);
1011:       vec_copy_construct (new_vec->address (), address (), len);
1012:     }
1013:   return new_vec;
1014: }
1015:
1016:
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

## gcc/config/i386/i386.cc:4434–4441
```text
4434: ix86_member_type_forces_blk (const_tree field, machine_mode mode)
4435: {
4436:   /* Union with XFmode must be in BLKmode.  */
4437:   return (mode == XFmode
4438: 	  && (TREE_CODE (DECL_FIELD_CONTEXT (field)) == UNION_TYPE
4439: 	      || TREE_CODE (DECL_FIELD_CONTEXT (field)) == QUAL_UNION_TYPE));
4440: }
4441:
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

## gcc/config/i386/i386.cc:18489–18497
```text
18489: /* Implement TARGET_EMPTY_RECORD_P.  */
18490:
18491: static bool
18492: ix86_is_empty_record (const_tree type)
18493: {
18494:   if (!TARGET_64BIT)
18495:     return false;
18496:   return default_is_empty_record (type);
18497: }
```

## gcc/config/i386/i386.cc:28520–28521
```text
28520: #undef TARGET_MEMBER_TYPE_FORCES_BLK
28521: #define TARGET_MEMBER_TYPE_FORCES_BLK ix86_member_type_forces_blk
```

## gcc/config/i386/i386.cc:28726–28727
```text
28726: #undef TARGET_EMPTY_RECORD_P
28727: #define TARGET_EMPTY_RECORD_P ix86_is_empty_record
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

## gcc/passes.def:25–47
```text
25:
26:  /* All passes needed to lower the function into shape optimizers can
27:     operate on.  These passes are always run first on the function, but
28:     backend might produce already lowered functions that are not processed
29:     by these passes.  */
30:   INSERT_PASSES_AFTER (all_lowering_passes)
31:   NEXT_PASS (pass_warn_unused_result);
32:   NEXT_PASS (pass_diagnose_omp_blocks);
33:   NEXT_PASS (pass_diagnose_tm_blocks);
34:   NEXT_PASS (pass_omp_oacc_kernels_decompose);
35:   NEXT_PASS (pass_lower_omp);
36:   NEXT_PASS (pass_lower_cf);
37:   NEXT_PASS (pass_lower_tm);
38:   NEXT_PASS (pass_refactor_eh);
39:   NEXT_PASS (pass_lower_eh);
40:   NEXT_PASS (pass_coroutine_lower_builtins);
41:   NEXT_PASS (pass_build_cfg);
42:   NEXT_PASS (pass_warn_function_return);
43:   NEXT_PASS (pass_coroutine_early_expand_ifns);
44:   NEXT_PASS (pass_expand_omp);
45:   NEXT_PASS (pass_build_cgraph_edges);
46:   TERMINATE_PASS_LIST (all_lowering_passes)
47:
```

## gcc/gimple-low.cc:122–214
```text
122: lower_function_body (void)
123: {
124:   struct lower_data data;
125:   gimple_seq body = gimple_body (current_function_decl);
126:   gimple_seq lowered_body;
127:   gimple_stmt_iterator i;
128:   gimple *bind;
129:   gimple *x;
130:
131:   /* The gimplifier should've left a body of exactly one statement,
132:      namely a GIMPLE_BIND.  */
133:   gcc_assert (gimple_seq_first (body) == gimple_seq_last (body)
134: 	      && gimple_code (gimple_seq_first_stmt (body)) == GIMPLE_BIND);
135:
136:   memset (&data, 0, sizeof (data));
137:   data.block = DECL_INITIAL (current_function_decl);
138:   BLOCK_SUBBLOCKS (data.block) = NULL_TREE;
139:   BLOCK_CHAIN (data.block) = NULL_TREE;
140:   TREE_ASM_WRITTEN (data.block) = 1;
141:   data.return_statements.create (8);
142:
143:   bind = gimple_seq_first_stmt (body);
144:   lowered_body = NULL;
145:   gimple_seq_add_stmt (&lowered_body, bind);
146:   i = gsi_start (lowered_body);
147:   lower_gimple_bind (&i, &data);
148:
149:   i = gsi_last (lowered_body);
150:
151:   /* If we had begin stmt markers from e.g. PCH, but this compilation
152:      doesn't want them, lower_stmt will have cleaned them up; we can
153:      now clear the flag that indicates we had them.  */
154:   if (!MAY_HAVE_DEBUG_MARKER_STMTS && cfun->debug_nonbind_markers)
155:     {
156:       /* This counter needs not be exact, but before lowering it will
157: 	 most certainly be.  */
158:       gcc_assert (cfun->debug_marker_count == 0);
159:       cfun->debug_nonbind_markers = false;
160:     }
161:
162:   /* If the function falls off the end, we need a null return statement.
163:      If we've already got one in the return_statements vector, we don't
164:      need to do anything special.  Otherwise build one by hand.  */
165:   bool may_fallthru = gimple_seq_may_fallthru (lowered_body);
166:   if (may_fallthru
167:       && (data.return_statements.is_empty ()
168: 	  || (gimple_return_retval (data.return_statements.last().stmt)
169: 	      != NULL)))
170:     {
171:       x = gimple_build_return (NULL);
172:       gimple_set_location (x, cfun->function_end_locus);
173:       gimple_set_block (x, DECL_INITIAL (current_function_decl));
174:       gsi_insert_after (&i, x, GSI_CONTINUE_LINKING);
175:       may_fallthru = false;
176:     }
177:
178:   /* If we lowered any return statements, emit the representative
179:      at the end of the function.  */
180:   while (!data.return_statements.is_empty ())
181:     {
182:       return_statements_t t = data.return_statements.pop ();
183:       x = gimple_build_label (t.label);
184:       gsi_insert_after (&i, x, GSI_CONTINUE_LINKING);
185:       gsi_insert_after (&i, t.stmt, GSI_CONTINUE_LINKING);
186:       if (may_fallthru)
187: 	{
188: 	  /* Remove the line number from the representative return statement.
189: 	     It now fills in for the fallthru too.  Failure to remove this
190: 	     will result in incorrect results for coverage analysis.  */
191: 	  gimple_set_location (t.stmt, UNKNOWN_LOCATION);
192: 	  may_fallthru = false;
193: 	}
194:     }
195:
196:   /* Once the old body has been lowered, replace it with the new
197:      lowered sequence.  */
198:   gimple_set_body (current_function_decl, lowered_body);
199:
200:   if (assume_labels)
201:     {
202:       struct walk_stmt_info wi;
203:
204:       memset (&wi, 0, sizeof (wi));
205:       walk_gimple_seq (lowered_body, NULL, diagnose_assume_labels, &wi);
206:       BITMAP_FREE (assume_labels);
207:     }
208:
209:   gcc_assert (data.block == DECL_INITIAL (current_function_decl));
210:   BLOCK_SUBBLOCKS (data.block)
211:     = blocks_nreverse (BLOCK_SUBBLOCKS (data.block));
212:
213:   clear_block_marks (data.block);
214:   data.return_statements.release ();
```

## gcc/gimple-low.cc:1178–1223
```text
1178: /* Lower a GIMPLE_RETURN GSI.  DATA is passed through the recursion.  */
1179:
1180: static void
1181: lower_gimple_return (gimple_stmt_iterator *gsi, struct lower_data *data)
1182: {
1183:   greturn *stmt = as_a <greturn *> (gsi_stmt (*gsi));
1184:   gimple *t;
1185:   int i;
1186:   return_statements_t tmp_rs;
1187:
1188:   /* Match this up with an existing return statement that's been created.  */
1189:   for (i = data->return_statements.length () - 1;
1190:        i >= 0; i--)
1191:     {
1192:       tmp_rs = data->return_statements[i];
1193:
1194:       if (gimple_return_retval (stmt) == gimple_return_retval (tmp_rs.stmt))
1195: 	{
1196: 	  /* Remove the line number from the representative return statement.
1197: 	     It now fills in for many such returns.  Failure to remove this
1198: 	     will result in incorrect results for coverage analysis.  */
1199: 	  gimple_set_location (tmp_rs.stmt, UNKNOWN_LOCATION);
1200:
1201: 	  goto found;
1202: 	}
1203:     }
1204:
1205:   /* Not found.  Create a new label and record the return statement.  */
1206:   tmp_rs.label = create_artificial_label (cfun->function_end_locus);
1207:   tmp_rs.stmt = stmt;
1208:   data->return_statements.safe_push (tmp_rs);
1209:
1210:   /* Generate a goto statement and remove the return statement.  */
1211:  found:
1212:   /* When not optimizing, make sure user returns are preserved.  */
1213:   if (!optimize && gimple_has_location (stmt))
1214:     DECL_ARTIFICIAL (tmp_rs.label) = 0;
1215:   t = gimple_build_goto (tmp_rs.label);
1216:   /* location includes block.  */
1217:   gimple_set_location (t, gimple_location (stmt));
1218:   gsi_insert_before (gsi, t, GSI_SAME_STMT);
1219:   gsi_remove (gsi, false);
1220: }
1221:
1222: /* Lower a __builtin_setjmp GSI.
1223:
```

## gcc/gimplify.cc:944–1089
```text
944: mostly_copy_tree_r (tree *tp, int *walk_subtrees, void *data)
945: {
946:   tree t = *tp;
947:   enum tree_code code = TREE_CODE (t);
948:
949:   /* Do not copy SAVE_EXPR, TARGET_EXPR or BIND_EXPR nodes themselves, but
950:      copy their subtrees if we can make sure to do it only once.  */
951:   if (code == SAVE_EXPR || code == TARGET_EXPR || code == BIND_EXPR)
952:     {
953:       if (data && !((hash_set<tree> *)data)->add (t))
954: 	;
955:       else
956: 	*walk_subtrees = 0;
957:     }
958:
959:   /* Stop at types, decls, constants like copy_tree_r.  */
960:   else if (TREE_CODE_CLASS (code) == tcc_type
961: 	   || TREE_CODE_CLASS (code) == tcc_declaration
962: 	   || TREE_CODE_CLASS (code) == tcc_constant)
963:     *walk_subtrees = 0;
964:
965:   /* Cope with the statement expression extension.  */
966:   else if (code == STATEMENT_LIST)
967:     ;
968:
969:   /* Leave the bulk of the work to copy_tree_r itself.  */
970:   else
971:     copy_tree_r (tp, walk_subtrees, NULL);
972:
973:   return NULL_TREE;
974: }
975:
976: /* Callback for walk_tree to unshare most of the shared trees rooted at *TP.
977:    If *TP has been visited already, then *TP is deeply copied by calling
978:    mostly_copy_tree_r.  DATA is passed to mostly_copy_tree_r unmodified.  */
979:
980: static tree
981: copy_if_shared_r (tree *tp, int *walk_subtrees, void *data)
982: {
983:   tree t = *tp;
984:   enum tree_code code = TREE_CODE (t);
985:
986:   /* Skip types, decls, and constants.  But we do want to look at their
987:      types and the bounds of types.  Mark them as visited so we properly
988:      unmark their subtrees on the unmark pass.  If we've already seen them,
989:      don't look down further.  */
990:   if (TREE_CODE_CLASS (code) == tcc_type
991:       || TREE_CODE_CLASS (code) == tcc_declaration
992:       || TREE_CODE_CLASS (code) == tcc_constant)
993:     {
994:       if (TREE_VISITED (t))
995: 	*walk_subtrees = 0;
996:       else
997: 	TREE_VISITED (t) = 1;
998:     }
999:
1000:   /* If this node has been visited already, unshare it and don't look
1001:      any deeper.  */
1002:   else if (TREE_VISITED (t))
1003:     {
1004:       walk_tree (tp, mostly_copy_tree_r, data, NULL);
1005:       *walk_subtrees = 0;
1006:     }
1007:
1008:   /* Otherwise, mark the node as visited and keep looking.  */
1009:   else
1010:     TREE_VISITED (t) = 1;
1011:
1012:   return NULL_TREE;
1013: }
1014:
1015: /* Unshare most of the shared trees rooted at *TP.  DATA is passed to the
1016:    copy_if_shared_r callback unmodified.  */
1017:
1018: void
1019: copy_if_shared (tree *tp, void *data)
1020: {
1021:   walk_tree (tp, copy_if_shared_r, data, NULL);
1022: }
1023:
1024: /* Unshare all the trees in the body of FNDECL, as well as in the bodies of
1025:    any nested functions.  */
1026:
1027: static void
1028: unshare_body (tree fndecl)
1029: {
1030:   struct cgraph_node *cgn = cgraph_node::get (fndecl);
1031:   /* If the language requires deep unsharing, we need a pointer set to make
1032:      sure we don't repeatedly unshare subtrees of unshareable nodes.  */
1033:   hash_set<tree> *visited
1034:     = lang_hooks.deep_unsharing ? new hash_set<tree> : NULL;
1035:
1036:   copy_if_shared (&DECL_SAVED_TREE (fndecl), visited);
1037:   copy_if_shared (&DECL_SIZE (DECL_RESULT (fndecl)), visited);
1038:   copy_if_shared (&DECL_SIZE_UNIT (DECL_RESULT (fndecl)), visited);
1039:
1040:   delete visited;
1041:
1042:   if (cgn)
1043:     for (cgn = first_nested_function (cgn); cgn;
1044: 	 cgn = next_nested_function (cgn))
1045:       unshare_body (cgn->decl);
1046: }
1047:
1048: /* Callback for walk_tree to unmark the visited trees rooted at *TP.
1049:    Subtrees are walked until the first unvisited node is encountered.  */
1050:
1051: static tree
1052: unmark_visited_r (tree *tp, int *walk_subtrees, void *data ATTRIBUTE_UNUSED)
1053: {
1054:   tree t = *tp;
1055:
1056:   /* If this node has been visited, unmark it and keep looking.  */
1057:   if (TREE_VISITED (t))
1058:     TREE_VISITED (t) = 0;
1059:
1060:   /* Otherwise, don't look any deeper.  */
1061:   else
1062:     *walk_subtrees = 0;
1063:
1064:   return NULL_TREE;
1065: }
1066:
1067: /* Unmark the visited trees rooted at *TP.  */
1068:
1069: static inline void
1070: unmark_visited (tree *tp)
1071: {
1072:   walk_tree (tp, unmark_visited_r, NULL, NULL);
1073: }
1074:
1075: /* Likewise, but mark all trees as not visited.  */
1076:
1077: static void
1078: unvisit_body (tree fndecl)
1079: {
1080:   struct cgraph_node *cgn = cgraph_node::get (fndecl);
1081:
1082:   unmark_visited (&DECL_SAVED_TREE (fndecl));
1083:   unmark_visited (&DECL_SIZE (DECL_RESULT (fndecl)));
1084:   unmark_visited (&DECL_SIZE_UNIT (DECL_RESULT (fndecl)));
1085:
1086:   if (cgn)
1087:     for (cgn = first_nested_function (cgn);
1088: 	 cgn; cgn = next_nested_function (cgn))
1089:       unvisit_body (cgn->decl);
```

## gcc/gimplify.cc:1096–1126
```text
1096: tree
1097: unshare_expr (tree expr)
1098: {
1099:   walk_tree (&expr, mostly_copy_tree_r, NULL, NULL);
1100:   return expr;
1101: }
1102:
1103: /* Worker for unshare_expr_without_location.  */
1104:
1105: static tree
1106: prune_expr_location (tree *tp, int *walk_subtrees, void *)
1107: {
1108:   if (EXPR_P (*tp))
1109:     SET_EXPR_LOCATION (*tp, UNKNOWN_LOCATION);
1110:   else
1111:     *walk_subtrees = 0;
1112:   return NULL_TREE;
1113: }
1114:
1115: /* Similar to unshare_expr but also prune all expression locations
1116:    from EXPR.  */
1117:
1118: tree
1119: unshare_expr_without_location (tree expr)
1120: {
1121:   walk_tree (&expr, mostly_copy_tree_r, NULL, NULL);
1122:   if (EXPR_P (expr))
1123:     walk_tree (&expr, prune_expr_location, NULL, NULL);
1124:   return expr;
1125: }
1126:
```

## gcc/gimplify.cc:1270–1282
```text
1270: build_stack_save_restore (gcall **save, gcall **restore)
1271: {
1272:   tree tmp_var;
1273:
1274:   *save = gimple_build_call (builtin_decl_implicit (BUILT_IN_STACK_SAVE), 0);
1275:   tmp_var = create_tmp_var (ptr_type_node, "saved_stack");
1276:   gimple_call_set_lhs (*save, tmp_var);
1277:
1278:   *restore
1279:     = gimple_build_call (builtin_decl_implicit (BUILT_IN_STACK_RESTORE),
1280: 			 1, tmp_var);
1281: }
1282:
```

## gcc/gimplify.cc:1699–1830
```text
1699:       end_locus = BLOCK_SOURCE_END_LOCATION (BIND_EXPR_BLOCK (bind_expr));
1700:       start_locus = BLOCK_SOURCE_LOCATION (BIND_EXPR_BLOCK (bind_expr));
1701:     }
1702:   if (start_locus == 0)
1703:     start_locus = EXPR_LOCATION (bind_expr);
1704:
1705:   cleanup = NULL;
1706:   stack_save = NULL;
1707:
1708:   /* Add clobbers for all variables that go out of scope.  */
1709:   for (t = BIND_EXPR_VARS (bind_expr); t ; t = DECL_CHAIN (t))
1710:     {
1711:       if (VAR_P (t)
1712: 	  && !is_global_var (t)
1713: 	  && DECL_CONTEXT (t) == current_function_decl)
1714: 	{
1715: 	  if (flag_openmp
1716: 	      && DECL_HAS_VALUE_EXPR_P (t)
1717: 	      && TREE_USED (t)
1718: 	      && lookup_attribute ("omp allocate", DECL_ATTRIBUTES (t)))
1719: 	    {
1720: 	      /* For Fortran, TREE_CHAIN (TREE_VALUE (attr)) is set, which
1721: 		 causes that the GOMP_free call is already added above;
1722: 		 and "omp allocate" is removed from DECL_ATTRIBUTES.  */
1723: 	      tree v = TREE_OPERAND (DECL_VALUE_EXPR (t), 0);
1724: 	      tree tmp = builtin_decl_explicit (BUILT_IN_GOMP_FREE);
1725: 	      tmp = build_call_expr_loc (end_locus, tmp, 2, v,
1726: 					 build_zero_cst (ptr_type_node));
1727: 	      gimplify_and_add (tmp, &cleanup);
1728: 	      gimple *clobber_stmt;
1729: 	      tmp = build_clobber (TREE_TYPE (v), CLOBBER_STORAGE_END);
1730: 	      clobber_stmt = gimple_build_assign (v, tmp);
1731: 	      gimple_set_location (clobber_stmt, end_locus);
1732: 	      gimplify_seq_add_stmt (&cleanup, clobber_stmt);
1733: 	    }
1734: 	  if (!DECL_HARD_REGISTER (t)
1735: 	      && !TREE_THIS_VOLATILE (t)
1736: 	      && !DECL_HAS_VALUE_EXPR_P (t)
1737: 	      /* Only care for variables that have to be in memory.  Others
1738: 		 will be rewritten into SSA names, hence moved to the
1739: 		 top-level.  */
1740: 	      && !is_gimple_reg (t)
1741: 	      && flag_stack_reuse != SR_NONE)
1742: 	    {
1743: 	      tree clobber = build_clobber (TREE_TYPE (t), CLOBBER_STORAGE_END);
1744: 	      gimple *clobber_stmt;
1745: 	      clobber_stmt = gimple_build_assign (t, clobber);
1746: 	      gimple_set_location (clobber_stmt, end_locus);
1747: 	      gimplify_seq_add_stmt (&cleanup, clobber_stmt);
1748: 	    }
1749:
1750: 	  if (flag_openacc && oacc_declare_returns != NULL)
1751: 	    {
1752: 	      tree key = t;
1753: 	      if (DECL_HAS_VALUE_EXPR_P (key))
1754: 		{
1755: 		  key = DECL_VALUE_EXPR (key);
1756: 		  if (INDIRECT_REF_P (key))
1757: 		    key = TREE_OPERAND (key, 0);
1758: 		}
1759: 	      tree *c = oacc_declare_returns->get (key);
1760: 	      if (c != NULL)
1761: 		{
1762: 		  if (ret_clauses)
1763: 		    OMP_CLAUSE_CHAIN (*c) = ret_clauses;
1764:
1765: 		  ret_clauses = unshare_expr (*c);
1766:
1767: 		  oacc_declare_returns->remove (key);
1768:
1769: 		  if (oacc_declare_returns->is_empty ())
1770: 		    {
1771: 		      delete oacc_declare_returns;
1772: 		      oacc_declare_returns = NULL;
1773: 		    }
1774: 		}
1775: 	    }
1776: 	}
1777:
1778:       if (asan_poisoned_variables != NULL
1779: 	  && asan_poisoned_variables->contains (t))
1780: 	{
1781: 	  asan_poisoned_variables->remove (t);
1782: 	  asan_poison_variable (t, true, &cleanup);
1783: 	}
1784:
1785:       if (gimplify_ctxp->live_switch_vars != NULL
1786: 	  && gimplify_ctxp->live_switch_vars->contains (t))
1787: 	gimplify_ctxp->live_switch_vars->remove (t);
1788:     }
1789:
1790:   /* If the code both contains VLAs and calls alloca, then we cannot reclaim
1791:      the stack space allocated to the VLAs.  */
1792:   if (gimplify_ctxp->save_stack && !gimplify_ctxp->keep_stack)
1793:     {
1794:       gcall *stack_restore;
1795:
1796:       /* Save stack on entry and restore it on exit.  Add a try_finally
1797: 	 block to achieve this.  */
1798:       build_stack_save_restore (&stack_save, &stack_restore);
1799:
1800:       gimple_set_location (stack_save, start_locus);
1801:       gimple_set_location (stack_restore, end_locus);
1802:
1803:       gimplify_seq_add_stmt (&cleanup, stack_restore);
1804:     }
1805:
1806:   if (ret_clauses)
1807:     {
1808:       gomp_target *stmt;
1809:       gimple_stmt_iterator si = gsi_start (cleanup);
1810:
1811:       stmt = gimple_build_omp_target (NULL, GF_OMP_TARGET_KIND_OACC_DECLARE,
1812: 				      ret_clauses);
1813:       gsi_insert_seq_before_without_update (&si, stmt, GSI_NEW_STMT);
1814:     }
1815:
1816:   if (cleanup)
1817:     {
1818:       gtry *gs;
1819:       gimple_seq new_body;
1820:
1821:       new_body = NULL;
1822:       gs = gimple_build_try (gimple_bind_body (bind_stmt), cleanup,
1823: 	  		     GIMPLE_TRY_FINALLY);
1824:
1825:       if (stack_save)
1826: 	gimplify_seq_add_stmt (&new_body, stack_save);
1827:       gimplify_seq_add_stmt (&new_body, gs);
1828:       gimple_bind_set_body (bind_stmt, new_body);
1829:     }
1830:
```

## gcc/gimplify.cc:21755–21785
```text
21755:
21756:   /* Initialize for optimize_insn_for_s{ize,peed}_p possibly called during
21757:      gimplification.  */
21758:   default_rtl_profile ();
21759:
21760:   gcc_assert (gimplify_ctxp == NULL);
21761:   push_gimplify_context (true);
21762:
21763:   if (flag_openacc || flag_openmp)
21764:     {
21765:       gcc_assert (gimplify_omp_ctxp == NULL);
21766:       if (lookup_attribute ("omp declare target", DECL_ATTRIBUTES (fndecl)))
21767: 	gimplify_omp_ctxp = new_omp_context (ORT_IMPLICIT_TARGET);
21768:     }
21769:
21770:   /* Unshare most shared trees in the body and in that of any nested functions.
21771:      It would seem we don't have to do this for nested functions because
21772:      they are supposed to be output and then the outer function gimplified
21773:      first, but the g++ front end doesn't always do it that way.  */
21774:   unshare_body (fndecl);
21775:   unvisit_body (fndecl);
21776:
21777:   /* Make sure input_location isn't set to something weird.  */
21778:   input_location = DECL_SOURCE_LOCATION (fndecl);
21779:
21780:   /* Resolve callee-copies.  This has to be done before processing
21781:      the body so that DECL_VALUE_EXPR gets processed correctly.  */
21782:   parm_stmts = do_parms ? gimplify_parameters (&parm_cleanup) : NULL;
21783:
21784:   /* Gimplify the function's body.  */
21785:   seq = NULL;
```

## gcc/tree-eh.cc:618–655
```text
618:
619: /* Add a new record to the goto queue contained in TF. NEW_STMT is the
620:    data to be added, IS_LABEL indicates whether NEW_STMT is a label or
621:    a gimple return. */
622:
623: static void
624: record_in_goto_queue (struct leh_tf_state *tf,
625:                       treemple new_stmt,
626:                       int index,
627:                       bool is_label,
628: 		      location_t location)
629: {
630:   size_t active, size;
631:   struct goto_queue_node *q;
632:
633:   gcc_assert (!tf->goto_queue_map);
634:
635:   active = tf->goto_queue_active;
636:   size = tf->goto_queue_size;
637:   if (active >= size)
638:     {
639:       size = (size ? size * 2 : 32);
640:       tf->goto_queue_size = size;
641:       tf->goto_queue
642:          = XRESIZEVEC (struct goto_queue_node, tf->goto_queue, size);
643:     }
644:
645:   q = &tf->goto_queue[active];
646:   tf->goto_queue_active = active + 1;
647:
648:   memset (q, 0, sizeof (*q));
649:   q->stmt = new_stmt;
650:   q->index = index;
651:   q->location = location;
652:   q->is_label = is_label;
653: }
654:
655: /* Record the LABEL label in the goto queue contained in TF.
```

## gcc/tree-eh.cc:710–877
```text
710:   treemple new_stmt;
711:
712:   if (!tf)
713:     return;
714:
715:   switch (gimple_code (stmt))
716:     {
717:     case GIMPLE_COND:
718:       {
719: 	gcond *cond_stmt = as_a <gcond *> (stmt);
720: 	new_stmt.tp = gimple_op_ptr (cond_stmt, 2);
721: 	record_in_goto_queue_label (tf, new_stmt,
722: 				    gimple_cond_true_label (cond_stmt),
723: 				    EXPR_LOCATION (*new_stmt.tp));
724: 	new_stmt.tp = gimple_op_ptr (cond_stmt, 3);
725: 	record_in_goto_queue_label (tf, new_stmt,
726: 				    gimple_cond_false_label (cond_stmt),
727: 				    EXPR_LOCATION (*new_stmt.tp));
728:       }
729:       break;
730:
731:     case GIMPLE_GOTO:
732:       new_stmt.g = stmt;
733:       record_in_goto_queue_label (tf, new_stmt, gimple_goto_dest (stmt),
734: 				  gimple_location (stmt));
735:       break;
736:
737:     case GIMPLE_ASM:
738:       if (int n = gimple_asm_nlabels (as_a <gasm *> (stmt)))
739: 	{
740: 	  new_stmt.g = stmt;
741: 	  gasm *asm_stmt = as_a <gasm *> (stmt);
742: 	  for (int i = 0; i < n; ++i)
743: 	    {
744: 	      tree elt = gimple_asm_label_op (asm_stmt, i);
745: 	      new_stmt.tp = &TREE_VALUE (elt);
746: 	      record_in_goto_queue_label (tf, new_stmt, TREE_VALUE (elt),
747: 					  gimple_location (stmt));
748: 	    }
749: 	}
750:       break;
751:
752:     case GIMPLE_RETURN:
753:       tf->may_return = true;
754:       new_stmt.g = stmt;
755:       record_in_goto_queue (tf, new_stmt, -1, false, gimple_location (stmt));
756:       break;
757:
758:     default:
759:       gcc_unreachable ();
760:     }
761: }
762:
763:
764: #if CHECKING_P
765: /* We do not process GIMPLE_SWITCHes for now.  As long as the original source
766:    was in fact structured, and we've not yet done jump threading, then none
767:    of the labels will leave outer GIMPLE_TRY_FINALLY nodes. Verify this.  */
768:
769: static void
770: verify_norecord_switch_expr (struct leh_state *state,
771: 			     gswitch *switch_expr)
772: {
773:   struct leh_tf_state *tf = state->tf;
774:   size_t i, n;
775:
776:   if (!tf)
777:     return;
778:
779:   n = gimple_switch_num_labels (switch_expr);
780:
781:   for (i = 0; i < n; ++i)
782:     {
783:       treemple temp;
784:       tree lab = CASE_LABEL (gimple_switch_label (switch_expr, i));
785:       temp.t = lab;
786:       gcc_assert (!outside_finally_tree (temp, tf->try_finally_expr));
787:     }
788: }
789: #else
790: #define verify_norecord_switch_expr(state, switch_expr)
791: #endif
792:
793: /* Redirect a RETURN_EXPR pointed to by Q to FINLAB.  If MOD is
794:    non-null, insert it before the new branch.  */
795:
796: static void
797: do_return_redirection (struct goto_queue_node *q, tree finlab, gimple_seq mod)
798: {
799:   gimple *x;
800:
801:   /* In the case of a return, the queue node must be a gimple statement.  */
802:   gcc_assert (!q->is_label);
803:
804:   /* Note that the return value may have already been computed, e.g.,
805:
806: 	int x;
807: 	int foo (void)
808: 	{
809: 	  x = 0;
810: 	  try {
811: 	    return x;
812: 	  } finally {
813: 	    x++;
814: 	  }
815: 	}
816:
817:      should return 0, not 1.  We don't have to do anything to make
818:      this happens because the return value has been placed in the
819:      RESULT_DECL already.  */
820:
821:   q->cont_stmt = q->stmt.g;
822:
823:   if (mod)
824:     gimple_seq_add_seq (&q->repl_stmt, mod);
825:
826:   x = gimple_build_goto (finlab);
827:   gimple_set_location (x, q->location);
828:   gimple_seq_add_stmt (&q->repl_stmt, x);
829: }
830:
831: /* Similar, but easier, for GIMPLE_GOTO.  */
832:
833: static void
834: do_goto_redirection (struct goto_queue_node *q, tree finlab, gimple_seq mod,
835: 		     struct leh_tf_state *tf)
836: {
837:   ggoto *x;
838:
839:   gcc_assert (q->is_label);
840:
841:   q->cont_stmt = gimple_build_goto (tf->dest_array[q->index]);
842:
843:   if (mod)
844:     gimple_seq_add_seq (&q->repl_stmt, mod);
845:
846:   x = gimple_build_goto (finlab);
847:   gimple_set_location (x, q->location);
848:   gimple_seq_add_stmt (&q->repl_stmt, x);
849: }
850:
851: /* Emit a standard landing pad sequence into SEQ for REGION.  */
852:
853: static void
854: emit_post_landing_pad (gimple_seq *seq, eh_region region)
855: {
856:   eh_landing_pad lp = region->landing_pads;
857:   glabel *x;
858:
859:   if (lp == NULL)
860:     lp = gen_eh_landing_pad (region);
861:
862:   lp->post_landing_pad = create_artificial_label (UNKNOWN_LOCATION);
863:   EH_LANDING_PAD_NR (lp->post_landing_pad) = lp->index;
864:
865:   x = gimple_build_label (lp->post_landing_pad);
866:   gimple_seq_add_stmt (seq, x);
867: }
868:
869: /* Emit a RESX statement into SEQ for REGION.  */
870:
871: static void
872: emit_resx (gimple_seq *seq, eh_region region)
873: {
874:   gresx *x = gimple_build_resx (region->index);
875:   gimple_seq_add_stmt (seq, x);
876:   if (region->outer)
877:     record_stmt_eh_region (region->outer, x);
```

## gcc/tree-eh.cc:940–1095
```text
940:     }
941:   gimple_seq_add_seq (&eh_seq, cleanup);
942:
943:   if (over)
944:     {
945:       x = gimple_build_label (over);
946:       gimple_seq_add_stmt (&result, x);
947:     }
948:   return result;
949: }
950:
951: /* A subroutine of lower_try_finally.  Duplicate the tree rooted at T.
952:    Make sure to record all new labels found.  */
953:
954: static gimple_seq
955: lower_try_finally_dup_block (gimple_seq seq, struct leh_state *outer_state,
956: 			     location_t loc)
957: {
958:   gtry *region = NULL;
959:   gimple_seq new_seq;
960:   gimple_stmt_iterator gsi;
961:
962:   new_seq = copy_gimple_seq_and_replace_locals (seq);
963:
964:   for (gsi = gsi_start (new_seq); !gsi_end_p (gsi); gsi_next (&gsi))
965:     {
966:       gimple *stmt = gsi_stmt (gsi);
967:       if (LOCATION_LOCUS (gimple_location (stmt)) == UNKNOWN_LOCATION)
968: 	{
969: 	  tree block = gimple_block (stmt);
970: 	  gimple_set_location (stmt, loc);
971: 	  gimple_set_block (stmt, block);
972: 	}
973:     }
974:
975:   if (outer_state->tf)
976:     region = outer_state->tf->try_finally_expr;
977:   collect_finally_tree_1 (new_seq, region);
978:
979:   return new_seq;
980: }
981:
982: /* A subroutine of lower_try_finally.  Create a fallthru label for
983:    the given try_finally state.  The only tricky bit here is that
984:    we have to make sure to record the label in our outer context.  */
985:
986: static tree
987: lower_try_finally_fallthru_label (struct leh_tf_state *tf)
988: {
989:   tree label = tf->fallthru_label;
990:   treemple temp;
991:
992:   if (!label)
993:     {
994:       label = create_artificial_label (gimple_location (tf->try_finally_expr));
995:       tf->fallthru_label = label;
996:       if (tf->outer->tf)
997:         {
998:           temp.t = label;
999:           record_in_finally_tree (temp, tf->outer->tf->try_finally_expr);
1000:         }
1001:     }
1002:   return label;
1003: }
1004:
1005: /* A subroutine of lower_try_finally.  If FINALLY consits of a
1006:    GIMPLE_EH_ELSE node, return it.  */
1007:
1008: static inline geh_else *
1009: get_eh_else (gimple_seq finally)
1010: {
1011:   gimple *x = gimple_seq_first_stmt (finally);
1012:   if (x && gimple_code (x) == GIMPLE_EH_ELSE)
1013:     {
1014:       gcc_assert (gimple_seq_singleton_p (finally));
1015:       return as_a <geh_else *> (x);
1016:     }
1017:   return NULL;
1018: }
1019:
1020: /* A subroutine of lower_try_finally.  If the eh_protect_cleanup_actions
1021:    langhook returns non-null, then the language requires that the exception
1022:    path out of a try_finally be treated specially.  To wit: the code within
1023:    the finally block may not itself throw an exception.  We have two choices
1024:    here. First we can duplicate the finally block and wrap it in a
1025:    must_not_throw region.  Second, we can generate code like
1026:
1027: 	try {
1028: 	  finally_block;
1029: 	} catch {
1030: 	  if (fintmp == eh_edge)
1031: 	    protect_cleanup_actions;
1032: 	}
1033:
1034:    where "fintmp" is the temporary used in the switch statement generation
1035:    alternative considered below.  For the nonce, we always choose the first
1036:    option.
1037:
1038:    THIS_STATE may be null if this is a try-cleanup, not a try-finally.  */
1039:
1040: static void
1041: honor_protect_cleanup_actions (struct leh_state *outer_state,
1042: 			       struct leh_state *this_state,
1043: 			       struct leh_tf_state *tf)
1044: {
1045:   gimple_seq finally = gimple_try_cleanup (tf->top_p);
1046:
1047:   /* EH_ELSE doesn't come from user code; only compiler generated stuff.
1048:      It does need to be handled here, so as to separate the (different)
1049:      EH path from the normal path.  But we should not attempt to wrap
1050:      it with a must-not-throw node (which indeed gets in the way).  */
1051:   if (geh_else *eh_else = get_eh_else (finally))
1052:     {
1053:       gimple_try_set_cleanup (tf->top_p, gimple_eh_else_n_body (eh_else));
1054:       finally = gimple_eh_else_e_body (eh_else);
1055:
1056:       /* Let the ELSE see the exception that's being processed, but
1057: 	 since the cleanup is outside the try block, process it with
1058: 	 outer_state, otherwise it may be used as a cleanup for
1059: 	 itself, and Bad Things (TM) ensue.  */
1060:       eh_region save_ehp = outer_state->ehp_region;
1061:       outer_state->ehp_region = this_state->cur_region;
1062:       lower_eh_constructs_1 (outer_state, &finally);
1063:       outer_state->ehp_region = save_ehp;
1064:     }
1065:   else
1066:     {
1067:       /* First check for nothing to do.  */
1068:       if (lang_hooks.eh_protect_cleanup_actions == NULL)
1069: 	return;
1070:       tree actions = lang_hooks.eh_protect_cleanup_actions ();
1071:       if (actions == NULL)
1072: 	return;
1073:
1074:       if (this_state)
1075: 	finally = lower_try_finally_dup_block (finally, outer_state,
1076: 	  gimple_location (tf->try_finally_expr));
1077:
1078:       /* If this cleanup consists of a TRY_CATCH_EXPR with TRY_CATCH_IS_CLEANUP
1079: 	 set, the handler of the TRY_CATCH_EXPR is another cleanup which ought
1080: 	 to be in an enclosing scope, but needs to be implemented at this level
1081: 	 to avoid a nesting violation (see wrap_temporary_cleanups in
1082: 	 cp/decl.cc).  Since it's logically at an outer level, we should call
1083: 	 terminate before we get to it, so strip it away before adding the
1084: 	 MUST_NOT_THROW filter.  */
1085:       gimple_stmt_iterator gsi = gsi_start (finally);
1086:       gimple *x = !gsi_end_p (gsi) ? gsi_stmt (gsi) : NULL;
1087:       if (x
1088: 	  && gimple_code (x) == GIMPLE_TRY
1089: 	  && gimple_try_kind (x) == GIMPLE_TRY_CATCH
1090: 	  && gimple_try_catch_is_cleanup (x))
1091: 	{
1092: 	  gsi_insert_seq_before (&gsi, gimple_try_eval (x), GSI_SAME_STMT);
1093: 	  gsi_remove (&gsi, false);
1094: 	}
1095:
```

## gcc/tree-eh.cc:1107–1283
```text
1107:   if (gimple_seq_may_fallthru (finally))
1108:     emit_resx (&eh_seq, tf->region);
1109:
1110:   /* Having now been handled, EH isn't to be considered with
1111:      the rest of the outgoing edges.  */
1112:   tf->may_throw = false;
1113: }
1114:
1115: /* A subroutine of lower_try_finally.  We have determined that there is
1116:    no fallthru edge out of the finally block.  This means that there is
1117:    no outgoing edge corresponding to any incoming edge.  Restructure the
1118:    try_finally node for this special case.  */
1119:
1120: static void
1121: lower_try_finally_nofallthru (struct leh_state *state,
1122: 			      struct leh_tf_state *tf)
1123: {
1124:   tree lab;
1125:   gimple *x;
1126:   geh_else *eh_else;
1127:   gimple_seq finally;
1128:   struct goto_queue_node *q, *qe;
1129:
1130:   lab = create_artificial_label (gimple_location (tf->try_finally_expr));
1131:
1132:   /* We expect that tf->top_p is a GIMPLE_TRY. */
1133:   finally = gimple_try_cleanup (tf->top_p);
1134:   tf->top_p_seq = gimple_try_eval (tf->top_p);
1135:
1136:   x = gimple_build_label (lab);
1137:   gimple_seq_add_stmt (&tf->top_p_seq, x);
1138:
1139:   q = tf->goto_queue;
1140:   qe = q + tf->goto_queue_active;
1141:   for (; q < qe; ++q)
1142:     if (q->index < 0)
1143:       do_return_redirection (q, lab, NULL);
1144:     else
1145:       do_goto_redirection (q, lab, NULL, tf);
1146:
1147:   replace_goto_queue (tf);
1148:
1149:   /* Emit the finally block into the stream.  Lower EH_ELSE at this time.  */
1150:   eh_else = get_eh_else (finally);
1151:   if (eh_else)
1152:     {
1153:       finally = gimple_eh_else_n_body (eh_else);
1154:       lower_eh_constructs_1 (state, &finally);
1155:       gimple_seq_add_seq (&tf->top_p_seq, finally);
1156:
1157:       if (tf->may_throw)
1158: 	{
1159: 	  finally = gimple_eh_else_e_body (eh_else);
1160: 	  lower_eh_constructs_1 (state, &finally);
1161:
1162: 	  emit_post_landing_pad (&eh_seq, tf->region);
1163: 	  gimple_seq_add_seq (&eh_seq, finally);
1164: 	}
1165:     }
1166:   else
1167:     {
1168:       lower_eh_constructs_1 (state, &finally);
1169:       gimple_seq_add_seq (&tf->top_p_seq, finally);
1170:
1171:       if (tf->may_throw)
1172: 	{
1173: 	  emit_post_landing_pad (&eh_seq, tf->region);
1174:
1175: 	  x = gimple_build_goto (lab);
1176: 	  gimple_set_location (x, gimple_location (tf->try_finally_expr));
1177: 	  gimple_seq_add_stmt (&eh_seq, x);
1178: 	}
1179:     }
1180: }
1181:
1182: /* A subroutine of lower_try_finally.  We have determined that there is
1183:    exactly one destination of the finally block.  Restructure the
1184:    try_finally node for this special case.  */
1185:
1186: static void
1187: lower_try_finally_onedest (struct leh_state *state, struct leh_tf_state *tf)
1188: {
1189:   struct goto_queue_node *q, *qe;
1190:   geh_else *eh_else;
1191:   glabel *label_stmt;
1192:   gimple *x;
1193:   gimple_seq finally;
1194:   gimple_stmt_iterator gsi;
1195:   tree finally_label;
1196:   location_t loc = gimple_location (tf->try_finally_expr);
1197:
1198:   finally = gimple_try_cleanup (tf->top_p);
1199:   tf->top_p_seq = gimple_try_eval (tf->top_p);
1200:
1201:   /* Since there's only one destination, and the destination edge can only
1202:      either be EH or non-EH, that implies that all of our incoming edges
1203:      are of the same type.  Therefore we can lower EH_ELSE immediately.  */
1204:   eh_else = get_eh_else (finally);
1205:   if (eh_else)
1206:     {
1207:       if (tf->may_throw)
1208: 	finally = gimple_eh_else_e_body (eh_else);
1209:       else
1210: 	finally = gimple_eh_else_n_body (eh_else);
1211:     }
1212:
1213:   lower_eh_constructs_1 (state, &finally);
1214:
1215:   for (gsi = gsi_start (finally); !gsi_end_p (gsi); gsi_next (&gsi))
1216:     {
1217:       gimple *stmt = gsi_stmt (gsi);
1218:       if (LOCATION_LOCUS (gimple_location (stmt)) == UNKNOWN_LOCATION)
1219: 	{
1220: 	  tree block = gimple_block (stmt);
1221: 	  gimple_set_location (stmt, gimple_location (tf->try_finally_expr));
1222: 	  gimple_set_block (stmt, block);
1223: 	}
1224:     }
1225:
1226:   if (tf->may_throw)
1227:     {
1228:       /* Only reachable via the exception edge.  Add the given label to
1229:          the head of the FINALLY block.  Append a RESX at the end.  */
1230:       emit_post_landing_pad (&eh_seq, tf->region);
1231:       gimple_seq_add_seq (&eh_seq, finally);
1232:       emit_resx (&eh_seq, tf->region);
1233:       return;
1234:     }
1235:
1236:   if (tf->may_fallthru)
1237:     {
1238:       /* Only reachable via the fallthru edge.  Do nothing but let
1239: 	 the two blocks run together; we'll fall out the bottom.  */
1240:       gimple_seq_add_seq (&tf->top_p_seq, finally);
1241:       return;
1242:     }
1243:
1244:   finally_label = create_artificial_label (loc);
1245:   label_stmt = gimple_build_label (finally_label);
1246:   gimple_seq_add_stmt (&tf->top_p_seq, label_stmt);
1247:
1248:   gimple_seq_add_seq (&tf->top_p_seq, finally);
1249:
1250:   q = tf->goto_queue;
1251:   qe = q + tf->goto_queue_active;
1252:
1253:   if (tf->may_return)
1254:     {
1255:       /* Reachable by return expressions only.  Redirect them.  */
1256:       for (; q < qe; ++q)
1257: 	do_return_redirection (q, finally_label, NULL);
1258:       replace_goto_queue (tf);
1259:     }
1260:   else
1261:     {
1262:       /* Reachable by goto expressions only.  Redirect them.  */
1263:       for (; q < qe; ++q)
1264: 	do_goto_redirection (q, finally_label, NULL, tf);
1265:       replace_goto_queue (tf);
1266:
1267:       if (tf->dest_array[0] == tf->fallthru_label)
1268: 	{
1269: 	  /* Reachable by goto to fallthru label only.  Redirect it
1270: 	     to the new label (already created, sadly), and do not
1271: 	     emit the final branch out, or the fallthru label.  */
1272: 	  tf->fallthru_label = NULL;
1273: 	  return;
1274: 	}
1275:     }
1276:
1277:   /* Place the original return/goto to the original destination
1278:      immediately after the finally block. */
1279:   x = tf->goto_queue[0].cont_stmt;
1280:   gimple_seq_add_stmt (&tf->top_p_seq, x);
1281:   maybe_record_in_goto_queue (state, x);
1282: }
1283:
```

## gcc/tree-eh.cc:1289–1800
```text
1289: lower_try_finally_copy (struct leh_state *state, struct leh_tf_state *tf)
1290: {
1291:   gimple_seq finally;
1292:   gimple_seq new_stmt;
1293:   gimple_seq seq;
1294:   gimple *x;
1295:   geh_else *eh_else;
1296:   tree tmp;
1297:   location_t tf_loc = gimple_location (tf->try_finally_expr);
1298:
1299:   finally = gimple_try_cleanup (tf->top_p);
1300:
1301:   /* Notice EH_ELSE, and simplify some of the remaining code
1302:      by considering FINALLY to be the normal return path only.  */
1303:   eh_else = get_eh_else (finally);
1304:   if (eh_else)
1305:     finally = gimple_eh_else_n_body (eh_else);
1306:
1307:   tf->top_p_seq = gimple_try_eval (tf->top_p);
1308:   new_stmt = NULL;
1309:
1310:   if (tf->may_fallthru)
1311:     {
1312:       seq = lower_try_finally_dup_block (finally, state, tf_loc);
1313:       lower_eh_constructs_1 (state, &seq);
1314:       gimple_seq_add_seq (&new_stmt, seq);
1315:
1316:       tmp = lower_try_finally_fallthru_label (tf);
1317:       x = gimple_build_goto (tmp);
1318:       gimple_set_location (x, tf_loc);
1319:       gimple_seq_add_stmt (&new_stmt, x);
1320:     }
1321:
1322:   if (tf->may_throw)
1323:     {
1324:       /* We don't need to copy the EH path of EH_ELSE,
1325: 	 since it is only emitted once.  */
1326:       if (eh_else)
1327: 	seq = gimple_eh_else_e_body (eh_else);
1328:       else
1329: 	seq = lower_try_finally_dup_block (finally, state, tf_loc);
1330:       lower_eh_constructs_1 (state, &seq);
1331:
1332:       emit_post_landing_pad (&eh_seq, tf->region);
1333:       gimple_seq_add_seq (&eh_seq, seq);
1334:       emit_resx (&eh_seq, tf->region);
1335:     }
1336:
1337:   if (tf->goto_queue)
1338:     {
1339:       struct goto_queue_node *q, *qe;
1340:       int return_index, index;
1341:       struct labels_s
1342:       {
1343: 	struct goto_queue_node *q;
1344: 	tree label;
1345:       } *labels;
1346:
1347:       return_index = tf->dest_array.length ();
1348:       labels = XCNEWVEC (struct labels_s, return_index + 1);
1349:
1350:       q = tf->goto_queue;
1351:       qe = q + tf->goto_queue_active;
1352:       for (; q < qe; q++)
1353: 	{
1354: 	  index = q->index < 0 ? return_index : q->index;
1355:
1356: 	  if (!labels[index].q)
1357: 	    labels[index].q = q;
1358: 	}
1359:
1360:       for (index = 0; index < return_index + 1; index++)
1361: 	{
1362: 	  tree lab;
1363:
1364: 	  q = labels[index].q;
1365: 	  if (! q)
1366: 	    continue;
1367:
1368: 	  lab = labels[index].label
1369: 	    = create_artificial_label (tf_loc);
1370:
1371: 	  if (index == return_index)
1372: 	    do_return_redirection (q, lab, NULL);
1373: 	  else
1374: 	    do_goto_redirection (q, lab, NULL, tf);
1375:
1376: 	  x = gimple_build_label (lab);
1377:           gimple_seq_add_stmt (&new_stmt, x);
1378:
1379: 	  seq = lower_try_finally_dup_block (finally, state, q->location);
1380: 	  lower_eh_constructs_1 (state, &seq);
1381:           gimple_seq_add_seq (&new_stmt, seq);
1382:
1383:           gimple_seq_add_stmt (&new_stmt, q->cont_stmt);
1384: 	  maybe_record_in_goto_queue (state, q->cont_stmt);
1385: 	}
1386:
1387:       for (q = tf->goto_queue; q < qe; q++)
1388: 	{
1389: 	  tree lab;
1390:
1391: 	  index = q->index < 0 ? return_index : q->index;
1392:
1393: 	  if (labels[index].q == q)
1394: 	    continue;
1395:
1396: 	  lab = labels[index].label;
1397:
1398: 	  if (index == return_index)
1399: 	    do_return_redirection (q, lab, NULL);
1400: 	  else
1401: 	    do_goto_redirection (q, lab, NULL, tf);
1402: 	}
1403:
1404:       replace_goto_queue (tf);
1405:       free (labels);
1406:     }
1407:
1408:   /* Need to link new stmts after running replace_goto_queue due
1409:      to not wanting to process the same goto stmts twice.  */
1410:   gimple_seq_add_seq (&tf->top_p_seq, new_stmt);
1411: }
1412:
1413: /* A subroutine of lower_try_finally.  There are multiple edges incoming
1414:    and outgoing from the finally block.  Implement this by instrumenting
1415:    each incoming edge and creating a switch statement at the end of the
1416:    finally block that branches to the appropriate destination.  */
1417:
1418: static void
1419: lower_try_finally_switch (struct leh_state *state, struct leh_tf_state *tf)
1420: {
1421:   struct goto_queue_node *q, *qe;
1422:   tree finally_tmp, finally_label;
1423:   int return_index, eh_index, fallthru_index;
1424:   int nlabels, ndests, j, last_case_index;
1425:   tree last_case;
1426:   auto_vec<tree> case_label_vec;
1427:   gimple_seq switch_body = NULL;
1428:   gimple *x;
1429:   geh_else *eh_else;
1430:   tree tmp;
1431:   gimple *switch_stmt;
1432:   gimple_seq finally;
1433:   hash_map<tree, gimple *> *cont_map = NULL;
1434:   /* The location of the TRY_FINALLY stmt.  */
1435:   location_t tf_loc = gimple_location (tf->try_finally_expr);
1436:   /* The location of the finally block.  */
1437:   location_t finally_loc;
1438:
1439:   finally = gimple_try_cleanup (tf->top_p);
1440:   eh_else = get_eh_else (finally);
1441:
1442:   /* Mash the TRY block to the head of the chain.  */
1443:   tf->top_p_seq = gimple_try_eval (tf->top_p);
1444:
1445:   /* The location of the finally is either the last stmt in the finally
1446:      block or the location of the TRY_FINALLY itself.  */
1447:   x = gimple_seq_last_stmt (finally);
1448:   finally_loc = x ? gimple_location (x) : tf_loc;
1449:
1450:   /* Prepare for switch statement generation.  */
1451:   nlabels = tf->dest_array.length ();
1452:   return_index = nlabels;
1453:   eh_index = return_index + tf->may_return;
1454:   fallthru_index = eh_index + (tf->may_throw && !eh_else);
1455:   ndests = fallthru_index + tf->may_fallthru;
1456:
1457:   finally_tmp = create_tmp_var (integer_type_node, "finally_tmp");
1458:   finally_label = create_artificial_label (finally_loc);
1459:
1460:   /* We use vec::quick_push on case_label_vec throughout this function,
1461:      since we know the size in advance and allocate precisely as muce
1462:      space as needed.  */
1463:   case_label_vec.create (ndests);
1464:   last_case = NULL;
1465:   last_case_index = 0;
1466:
1467:   /* Begin inserting code for getting to the finally block.  Things
1468:      are done in this order to correspond to the sequence the code is
1469:      laid out.  */
1470:
1471:   if (tf->may_fallthru)
1472:     {
1473:       x = gimple_build_assign (finally_tmp,
1474: 			       build_int_cst (integer_type_node,
1475: 					      fallthru_index));
1476:       gimple_set_location (x, finally_loc);
1477:       gimple_seq_add_stmt (&tf->top_p_seq, x);
1478:
1479:       tmp = build_int_cst (integer_type_node, fallthru_index);
1480:       last_case = build_case_label (tmp, NULL,
1481: 				    create_artificial_label (finally_loc));
1482:       case_label_vec.quick_push (last_case);
1483:       last_case_index++;
1484:
1485:       x = gimple_build_label (CASE_LABEL (last_case));
1486:       gimple_seq_add_stmt (&switch_body, x);
1487:
1488:       tmp = lower_try_finally_fallthru_label (tf);
1489:       x = gimple_build_goto (tmp);
1490:       gimple_set_location (x, finally_loc);
1491:       gimple_seq_add_stmt (&switch_body, x);
1492:     }
1493:
1494:   /* For EH_ELSE, emit the exception path (plus resx) now, then
1495:      subsequently we only need consider the normal path.  */
1496:   if (eh_else)
1497:     {
1498:       if (tf->may_throw)
1499: 	{
1500: 	  finally = gimple_eh_else_e_body (eh_else);
1501: 	  lower_eh_constructs_1 (state, &finally);
1502:
1503: 	  emit_post_landing_pad (&eh_seq, tf->region);
1504: 	  gimple_seq_add_seq (&eh_seq, finally);
1505: 	  emit_resx (&eh_seq, tf->region);
1506: 	}
1507:
1508:       finally = gimple_eh_else_n_body (eh_else);
1509:     }
1510:   else if (tf->may_throw)
1511:     {
1512:       emit_post_landing_pad (&eh_seq, tf->region);
1513:
1514:       x = gimple_build_assign (finally_tmp,
1515: 			       build_int_cst (integer_type_node, eh_index));
1516:       gimple_seq_add_stmt (&eh_seq, x);
1517:
1518:       x = gimple_build_goto (finally_label);
1519:       gimple_set_location (x, tf_loc);
1520:       gimple_seq_add_stmt (&eh_seq, x);
1521:
1522:       tmp = build_int_cst (integer_type_node, eh_index);
1523:       last_case = build_case_label (tmp, NULL,
1524: 				    create_artificial_label (tf_loc));
1525:       case_label_vec.quick_push (last_case);
1526:       last_case_index++;
1527:
1528:       x = gimple_build_label (CASE_LABEL (last_case));
1529:       gimple_seq_add_stmt (&eh_seq, x);
1530:       emit_resx (&eh_seq, tf->region);
1531:     }
1532:
1533:   x = gimple_build_label (finally_label);
1534:   gimple_seq_add_stmt (&tf->top_p_seq, x);
1535:
1536:   lower_eh_constructs_1 (state, &finally);
1537:   gimple_seq_add_seq (&tf->top_p_seq, finally);
1538:
1539:   /* Redirect each incoming goto edge.  */
1540:   q = tf->goto_queue;
1541:   qe = q + tf->goto_queue_active;
1542:   j = last_case_index + tf->may_return;
1543:   /* Prepare the assignments to finally_tmp that are executed upon the
1544:      entrance through a particular edge. */
1545:   for (; q < qe; ++q)
1546:     {
1547:       gimple_seq mod = NULL;
1548:       int switch_id;
1549:       unsigned int case_index;
1550:
1551:       if (q->index < 0)
1552: 	{
1553: 	  x = gimple_build_assign (finally_tmp,
1554: 				   build_int_cst (integer_type_node,
1555: 						  return_index));
1556: 	  gimple_seq_add_stmt (&mod, x);
1557: 	  do_return_redirection (q, finally_label, mod);
1558: 	  switch_id = return_index;
1559: 	}
1560:       else
1561: 	{
1562: 	  x = gimple_build_assign (finally_tmp,
1563: 				   build_int_cst (integer_type_node, q->index));
1564: 	  gimple_seq_add_stmt (&mod, x);
1565: 	  do_goto_redirection (q, finally_label, mod, tf);
1566: 	  switch_id = q->index;
1567: 	}
1568:
1569:       case_index = j + q->index;
1570:       if (case_label_vec.length () <= case_index || !case_label_vec[case_index])
1571:         {
1572:           tree case_lab;
1573: 	  tmp = build_int_cst (integer_type_node, switch_id);
1574:           case_lab = build_case_label (tmp, NULL,
1575: 				       create_artificial_label (tf_loc));
1576:           /* We store the cont_stmt in the pointer map, so that we can recover
1577:              it in the loop below.  */
1578:           if (!cont_map)
1579: 	    cont_map = new hash_map<tree, gimple *>;
1580:           cont_map->put (case_lab, q->cont_stmt);
1581:           case_label_vec.quick_push (case_lab);
1582:         }
1583:     }
1584:   for (j = last_case_index; j < last_case_index + nlabels; j++)
1585:     {
1586:       gimple *cont_stmt;
1587:
1588:       last_case = case_label_vec[j];
1589:
1590:       gcc_assert (last_case);
1591:       gcc_assert (cont_map);
1592:
1593:       cont_stmt = *cont_map->get (last_case);
1594:
1595:       x = gimple_build_label (CASE_LABEL (last_case));
1596:       gimple_seq_add_stmt (&switch_body, x);
1597:       gimple_seq_add_stmt (&switch_body, cont_stmt);
1598:       maybe_record_in_goto_queue (state, cont_stmt);
1599:     }
1600:   if (cont_map)
1601:     delete cont_map;
1602:
1603:   replace_goto_queue (tf);
1604:
1605:   /* Make sure that the last case is the default label, as one is required.
1606:      Then sort the labels, which is also required in GIMPLE.  */
1607:   CASE_LOW (last_case) = NULL;
1608:   tree tem = case_label_vec.pop ();
1609:   gcc_assert (tem == last_case);
1610:   sort_case_labels (case_label_vec);
1611:
1612:   /* Build the switch statement, setting last_case to be the default
1613:      label.  */
1614:   switch_stmt = gimple_build_switch (finally_tmp, last_case,
1615: 				     case_label_vec);
1616:   gimple_set_location (switch_stmt, finally_loc);
1617:
1618:   /* Need to link SWITCH_STMT after running replace_goto_queue
1619:      due to not wanting to process the same goto stmts twice.  */
1620:   gimple_seq_add_stmt (&tf->top_p_seq, switch_stmt);
1621:   gimple_seq_add_seq (&tf->top_p_seq, switch_body);
1622: }
1623:
1624: /* Decide whether or not we are going to duplicate the finally block.
1625:    There are several considerations.
1626:
1627:    Second, we'd like to prevent egregious code growth.  One way to
1628:    do this is to estimate the size of the finally block, multiply
1629:    that by the number of copies we'd need to make, and compare against
1630:    the estimate of the size of the switch machinery we'd have to add.  */
1631:
1632: static bool
1633: decide_copy_try_finally (int ndests, bool may_throw, gimple_seq finally)
1634: {
1635:   int f_estimate, sw_estimate;
1636:   geh_else *eh_else;
1637:
1638:   /* If there's an EH_ELSE involved, the exception path is separate
1639:      and really doesn't come into play for this computation.  */
1640:   eh_else = get_eh_else (finally);
1641:   if (eh_else)
1642:     {
1643:       ndests -= may_throw;
1644:       finally = gimple_eh_else_n_body (eh_else);
1645:     }
1646:
1647:   if (!optimize)
1648:     {
1649:       gimple_stmt_iterator gsi;
1650:
1651:       if (ndests == 1)
1652:         return true;
1653:
1654:       for (gsi = gsi_start (finally); !gsi_end_p (gsi); gsi_next (&gsi))
1655: 	{
1656: 	  /* Duplicate __builtin_stack_restore in the hope of eliminating it
1657: 	     on the EH paths and, consequently, useless cleanups.  */
1658: 	  gimple *stmt = gsi_stmt (gsi);
1659: 	  if (!is_gimple_debug (stmt)
1660: 	      && !gimple_clobber_p (stmt)
1661: 	      && !gimple_call_builtin_p (stmt, BUILT_IN_STACK_RESTORE))
1662: 	    return false;
1663: 	}
1664:       return true;
1665:     }
1666:
1667:   /* Finally estimate N times, plus N gotos.  */
1668:   f_estimate = estimate_num_insns_seq (finally, &eni_size_weights);
1669:   f_estimate = (f_estimate + 1) * ndests;
1670:
1671:   /* Switch statement (cost 10), N variable assignments, N gotos.  */
1672:   sw_estimate = 10 + 2 * ndests;
1673:
1674:   /* Optimize for size clearly wants our best guess.  */
1675:   if (optimize_function_for_size_p (cfun))
1676:     return f_estimate < sw_estimate;
1677:
1678:   /* ??? These numbers are completely made up so far.  */
1679:   if (optimize > 1)
1680:     return f_estimate < 100 || f_estimate < sw_estimate * 2;
1681:   else
1682:     return f_estimate < 40 || f_estimate * 2 < sw_estimate * 3;
1683: }
1684:
1685: /* REG is current region of a LEH state.
1686:    is the enclosing region for a possible cleanup region, or the region
1687:    itself.  Returns TRUE if such a region would be unreachable.
1688:
1689:    Cleanup regions within a must-not-throw region aren't actually reachable
1690:    even if there are throwing stmts within them, because the personality
1691:    routine will call terminate before unwinding.  */
1692:
1693: static bool
1694: cleanup_is_dead_in (leh_state *state)
1695: {
1696:   if (flag_checking)
1697:     {
1698:       eh_region reg = state->cur_region;
1699:       while (reg && reg->type == ERT_CLEANUP)
1700: 	reg = reg->outer;
1701:
1702:       gcc_assert (reg == state->outer_non_cleanup);
1703:     }
1704:
1705:   eh_region reg = state->outer_non_cleanup;
1706:   return (reg && reg->type == ERT_MUST_NOT_THROW);
1707: }
1708:
1709: /* A subroutine of lower_eh_constructs_1.  Lower a GIMPLE_TRY_FINALLY nodes
1710:    to a sequence of labels and blocks, plus the exception region trees
1711:    that record all the magic.  This is complicated by the need to
1712:    arrange for the FINALLY block to be executed on all exits.  */
1713:
1714: static gimple_seq
1715: lower_try_finally (struct leh_state *state, gtry *tp)
1716: {
1717:   struct leh_tf_state this_tf;
1718:   struct leh_state this_state;
1719:   int ndests;
1720:   gimple_seq old_eh_seq;
1721:
1722:   /* Process the try block.  */
1723:
1724:   memset (&this_tf, 0, sizeof (this_tf));
1725:   this_tf.try_finally_expr = tp;
1726:   this_tf.top_p = tp;
1727:   this_tf.outer = state;
1728:   if (using_eh_for_cleanups_p () && !cleanup_is_dead_in (state))
1729:     {
1730:       this_tf.region = gen_eh_region_cleanup (state->cur_region);
1731:       this_state.cur_region = this_tf.region;
1732:     }
1733:   else
1734:     {
1735:       this_tf.region = NULL;
1736:       this_state.cur_region = state->cur_region;
1737:     }
1738:
1739:   this_state.outer_non_cleanup = state->outer_non_cleanup;
1740:   this_state.ehp_region = state->ehp_region;
1741:   this_state.tf = &this_tf;
1742:
1743:   old_eh_seq = eh_seq;
1744:   eh_seq = NULL;
1745:
1746:   lower_eh_constructs_1 (&this_state, gimple_try_eval_ptr (tp));
1747:
1748:   /* Determine if the try block is escaped through the bottom.  */
1749:   this_tf.may_fallthru = gimple_seq_may_fallthru (gimple_try_eval (tp));
1750:
1751:   /* Determine if any exceptions are possible within the try block.  */
1752:   if (this_tf.region)
1753:     this_tf.may_throw = eh_region_may_contain_throw (this_tf.region);
1754:   if (this_tf.may_throw)
1755:     honor_protect_cleanup_actions (state, &this_state, &this_tf);
1756:
1757:   /* Determine how many edges (still) reach the finally block.  Or rather,
1758:      how many destinations are reached by the finally block.  Use this to
1759:      determine how we process the finally block itself.  */
1760:
1761:   ndests = this_tf.dest_array.length ();
1762:   ndests += this_tf.may_fallthru;
1763:   ndests += this_tf.may_return;
1764:   ndests += this_tf.may_throw;
1765:
1766:   /* If the FINALLY block is not reachable, dike it out.  */
1767:   if (ndests == 0)
1768:     {
1769:       gimple_seq_add_seq (&this_tf.top_p_seq, gimple_try_eval (tp));
1770:       gimple_try_set_cleanup (tp, NULL);
1771:     }
1772:   /* If the finally block doesn't fall through, then any destination
1773:      we might try to impose there isn't reached either.  There may be
1774:      some minor amount of cleanup and redirection still needed.  */
1775:   else if (!gimple_seq_may_fallthru (gimple_try_cleanup (tp)))
1776:     lower_try_finally_nofallthru (state, &this_tf);
1777:
1778:   /* We can easily special-case redirection to a single destination.  */
1779:   else if (ndests == 1)
1780:     lower_try_finally_onedest (state, &this_tf);
1781:   else if (decide_copy_try_finally (ndests, this_tf.may_throw,
1782: 				    gimple_try_cleanup (tp)))
1783:     lower_try_finally_copy (state, &this_tf);
1784:   else
1785:     lower_try_finally_switch (state, &this_tf);
1786:
1787:   /* If someone requested we add a label at the end of the transformed
1788:      block, do so.  */
1789:   if (this_tf.fallthru_label)
1790:     {
1791:       /* This must be reached only if ndests == 0. */
1792:       gimple *x = gimple_build_label (this_tf.fallthru_label);
1793:       gimple_seq_add_stmt (&this_tf.top_p_seq, x);
1794:     }
1795:
1796:   this_tf.dest_array.release ();
1797:   free (this_tf.goto_queue);
1798:   if (this_tf.goto_queue_map)
1799:     delete this_tf.goto_queue_map;
1800:
```

## gcc/tree-eh.cc:2333–2356
```text
2333: }
2334:
2335: /* Create the single EH edge from STMT to its nearest landing pad,
2336:    if there is such a landing pad within the current function.  */
2337:
2338: edge
2339: make_eh_edge (gimple *stmt)
2340: {
2341:   basic_block src, dst;
2342:   eh_landing_pad lp;
2343:   int lp_nr;
2344:
2345:   lp_nr = lookup_stmt_eh_lp (stmt);
2346:   if (lp_nr <= 0)
2347:     return NULL;
2348:
2349:   lp = get_eh_landing_pad_from_number (lp_nr);
2350:   gcc_assert (lp != NULL);
2351:
2352:   src = gimple_bb (stmt);
2353:   dst = label_to_block (cfun, lp->post_landing_pad);
2354:   return make_edge (src, dst, EDGE_EH);
2355: }
2356:
```

## gcc/tree-eh.cc:3318–3349
```text
3318:
3319:    This occurs frequently in C++, where A is a local variable and B is a
3320:    temporary used in the initializer for A.  */
3321:
3322: static void
3323: optimize_double_finally (gtry *one, gtry *two)
3324: {
3325:   gimple *oneh;
3326:   gimple_stmt_iterator gsi;
3327:   gimple_seq cleanup;
3328:
3329:   cleanup = gimple_try_cleanup (one);
3330:   gsi = gsi_start (cleanup);
3331:   if (!gsi_one_before_end_p (gsi))
3332:     return;
3333:
3334:   oneh = gsi_stmt (gsi);
3335:   if (gimple_code (oneh) != GIMPLE_TRY
3336:       || gimple_try_kind (oneh) != GIMPLE_TRY_CATCH)
3337:     return;
3338:
3339:   if (same_handler_p (gimple_try_cleanup (oneh), gimple_try_cleanup (two)))
3340:     {
3341:       gimple_seq seq = gimple_try_eval (oneh);
3342:
3343:       gimple_try_set_cleanup (one, seq);
3344:       gimple_try_set_kind (one, GIMPLE_TRY_CATCH);
3345:       seq = copy_gimple_seq_and_replace_locals (seq);
3346:       gimple_seq_add_seq (&seq, gimple_try_eval (two));
3347:       gimple_try_set_eval (two, seq);
3348:     }
3349: }
```

## gcc/gimple.cc:251–263
```text
251: gimple_build_call_1 (tree fn, unsigned nargs)
252: {
253:   gcall *s
254:     = as_a <gcall *> (gimple_build_with_ops (GIMPLE_CALL, ERROR_MARK,
255: 					     nargs + 3));
256:   if (TREE_CODE (fn) == FUNCTION_DECL)
257:     fn = build_fold_addr_expr (fn);
258:   gimple_set_op (s, 1, fn);
259:   gimple_call_set_fntype (s, TREE_TYPE (TREE_TYPE (fn)));
260:   gimple_call_reset_alias_info (s);
261:   return s;
262: }
263:
```

## gcc/gimple.cc:1563–1577
```text
1563: gimple_seq_copy (gimple_seq src)
1564: {
1565:   gimple_stmt_iterator gsi;
1566:   gimple_seq new_seq = NULL;
1567:   gimple *stmt;
1568:
1569:   for (gsi = gsi_start (src); !gsi_end_p (gsi); gsi_next (&gsi))
1570:     {
1571:       stmt = gimple_copy (gsi_stmt (gsi));
1572:       gimple_seq_add_stmt (&new_seq, stmt);
1573:     }
1574:
1575:   return new_seq;
1576: }
1577:
```

## gcc/gimple.cc:1901–1931
```text
1901: /* Set BB to be the basic block holding G.  */
1902:
1903: void
1904: gimple_set_bb (gimple *stmt, basic_block bb)
1905: {
1906:   stmt->bb = bb;
1907:
1908:   if (gimple_code (stmt) != GIMPLE_LABEL)
1909:     return;
1910:
1911:   /* If the statement is a label, add the label to block-to-labels map
1912:      so that we can speed up edge creation for GIMPLE_GOTOs.  */
1913:   if (cfun->cfg)
1914:     {
1915:       tree t;
1916:       int uid;
1917:
1918:       t = gimple_label_label (as_a <glabel *> (stmt));
1919:       uid = LABEL_DECL_UID (t);
1920:       if (uid == -1)
1921: 	{
1922: 	  unsigned old_len =
1923: 	    vec_safe_length (label_to_block_map_for_fn (cfun));
1924: 	  LABEL_DECL_UID (t) = uid = cfun->cfg->last_label_uid++;
1925: 	  if (old_len <= (unsigned) uid)
1926: 	    vec_safe_grow_cleared (label_to_block_map_for_fn (cfun), uid + 1);
1927: 	}
1928:
1929:       (*label_to_block_map_for_fn (cfun))[uid] = bb;
1930:     }
1931: }
```

## gcc/gimple.cc:2045–2095
```text
2045: gimple_copy (gimple *stmt)
2046: {
2047:   enum gimple_code code = gimple_code (stmt);
2048:   unsigned num_ops = gimple_num_ops (stmt);
2049:   gimple *copy = gimple_alloc (code, num_ops);
2050:   unsigned i;
2051:
2052:   /* Shallow copy all the fields from STMT.  */
2053:   memcpy (copy, stmt, gimple_size (code));
2054:   gimple_init_singleton (copy);
2055:
2056:   /* If STMT has sub-statements, deep-copy them as well.  */
2057:   if (gimple_has_substatements (stmt))
2058:     {
2059:       gimple_seq new_seq;
2060:       tree t;
2061:
2062:       switch (gimple_code (stmt))
2063: 	{
2064: 	case GIMPLE_BIND:
2065: 	  {
2066: 	    gbind *bind_stmt = as_a <gbind *> (stmt);
2067: 	    gbind *bind_copy = as_a <gbind *> (copy);
2068: 	    new_seq = gimple_seq_copy (gimple_bind_body (bind_stmt));
2069: 	    gimple_bind_set_body (bind_copy, new_seq);
2070: 	    gimple_bind_set_vars (bind_copy,
2071: 				  unshare_expr (gimple_bind_vars (bind_stmt)));
2072: 	    gimple_bind_set_block (bind_copy, gimple_bind_block (bind_stmt));
2073: 	  }
2074: 	  break;
2075:
2076: 	case GIMPLE_CATCH:
2077: 	  {
2078: 	    gcatch *catch_stmt = as_a <gcatch *> (stmt);
2079: 	    gcatch *catch_copy = as_a <gcatch *> (copy);
2080: 	    new_seq = gimple_seq_copy (gimple_catch_handler (catch_stmt));
2081: 	    gimple_catch_set_handler (catch_copy, new_seq);
2082: 	    t = unshare_expr (gimple_catch_types (catch_stmt));
2083: 	    gimple_catch_set_types (catch_copy, t);
2084: 	  }
2085: 	  break;
2086:
2087: 	case GIMPLE_EH_FILTER:
2088: 	  {
2089: 	    geh_filter *eh_filter_stmt = as_a <geh_filter *> (stmt);
2090: 	    geh_filter *eh_filter_copy = as_a <geh_filter *> (copy);
2091: 	    new_seq
2092: 	      = gimple_seq_copy (gimple_eh_filter_failure (eh_filter_stmt));
2093: 	    gimple_eh_filter_set_failure (eh_filter_copy, new_seq);
2094: 	    t = unshare_expr (gimple_eh_filter_types (eh_filter_stmt));
2095: 	    gimple_eh_filter_set_types (eh_filter_copy, t);
```

## gcc/gimple.cc:2297–2333
```text
2297:     case GIMPLE_OMP_ATOMIC_STORE:
2298:       {
2299: 	gomp_atomic_store *g = as_a <gomp_atomic_store *> (copy);
2300: 	gimple_omp_atomic_store_set_val (g,
2301: 	  unshare_expr (gimple_omp_atomic_store_val (g)));
2302: 	break;
2303:       }
2304:     default:
2305:       break;
2306:     }
2307:
2308:   /* Make copy of operands.  */
2309:   for (i = 0; i < num_ops; i++)
2310:     gimple_set_op (copy, i, unshare_expr (gimple_op (stmt, i)));
2311:
2312:   if (gimple_has_mem_ops (stmt))
2313:     {
2314:       gimple_set_vdef (copy, gimple_vdef (stmt));
2315:       gimple_set_vuse (copy, gimple_vuse (stmt));
2316:     }
2317:
2318:   /* Clear out SSA operand vectors on COPY.  */
2319:   if (gimple_has_ops (stmt))
2320:     {
2321:       gimple_set_use_ops (copy, NULL);
2322:
2323:       /* SSA operands need to be updated.  */
2324:       gimple_set_modified (copy, true);
2325:     }
2326:
2327:   if (gimple_debug_nonbind_marker_p (stmt))
2328:     cfun->debug_marker_count++;
2329:
2330:   return copy;
2331: }
2332:
2333: /* Move OLD_STMT's vuse and vdef operands to NEW_STMT, on the assumption
```

## gcc/tree-inline.cc:5735–5795
```text
5735: copy_tree_r (tree *tp, int *walk_subtrees, void *data ATTRIBUTE_UNUSED)
5736: {
5737:   enum tree_code code = TREE_CODE (*tp);
5738:   enum tree_code_class cl = TREE_CODE_CLASS (code);
5739:
5740:   /* We make copies of most nodes.  */
5741:   if (IS_EXPR_CODE_CLASS (cl)
5742:       || code == TREE_LIST
5743:       || code == TREE_VEC
5744:       || code == TYPE_DECL
5745:       || code == OMP_CLAUSE)
5746:     {
5747:       /* Because the chain gets clobbered when we make a copy, we save it
5748: 	 here.  */
5749:       tree chain = NULL_TREE, new_tree;
5750:
5751:       if (CODE_CONTAINS_STRUCT (code, TS_COMMON))
5752: 	chain = TREE_CHAIN (*tp);
5753:
5754:       /* Copy the node.  */
5755:       new_tree = copy_node (*tp);
5756:
5757:       *tp = new_tree;
5758:
5759:       /* Now, restore the chain, if appropriate.  That will cause
5760: 	 walk_tree to walk into the chain as well.  */
5761:       if (code == PARM_DECL
5762: 	  || code == TREE_LIST
5763: 	  || code == OMP_CLAUSE)
5764: 	TREE_CHAIN (*tp) = chain;
5765:
5766:       /* For now, we don't update BLOCKs when we make copies.  So, we
5767: 	 have to nullify all BIND_EXPRs.  */
5768:       if (TREE_CODE (*tp) == BIND_EXPR)
5769: 	BIND_EXPR_BLOCK (*tp) = NULL_TREE;
5770:     }
5771:   else if (code == CONSTRUCTOR)
5772:     {
5773:       /* CONSTRUCTOR nodes need special handling because
5774:          we need to duplicate the vector of elements.  */
5775:       tree new_tree;
5776:
5777:       new_tree = copy_node (*tp);
5778:       CONSTRUCTOR_ELTS (new_tree) = vec_safe_copy (CONSTRUCTOR_ELTS (*tp));
5779:       *tp = new_tree;
5780:     }
5781:   else if (code == STATEMENT_LIST)
5782:     /* We used to just abort on STATEMENT_LIST, but we can run into them
5783:        with statement-expressions (c++/40975).  */
5784:     copy_statement_list (tp);
5785:   else if (TREE_CODE_CLASS (code) == tcc_type)
5786:     *walk_subtrees = 0;
5787:   else if (TREE_CODE_CLASS (code) == tcc_declaration)
5788:     *walk_subtrees = 0;
5789:   else if (TREE_CODE_CLASS (code) == tcc_constant)
5790:     *walk_subtrees = 0;
5791:   return NULL_TREE;
5792: }
5793:
5794: /* The SAVE_EXPR pointed to by TP is being copied.  If ST contains
5795:    information indicating to what new SAVE_EXPR this one should be mapped,
```

## gcc/tree-inline.cc:5861–6060
```text
5861: replace_locals_op (tree *tp, int *walk_subtrees, void *data)
5862: {
5863:   struct walk_stmt_info *wi = (struct walk_stmt_info*) data;
5864:   copy_body_data *id = (copy_body_data *) wi->info;
5865:   hash_map<tree, tree> *st = id->decl_map;
5866:   tree *n;
5867:   tree expr = *tp;
5868:
5869:   /* For recursive invocations this is no longer the LHS itself.  */
5870:   bool is_lhs = wi->is_lhs;
5871:   wi->is_lhs = false;
5872:
5873:   if (TREE_CODE (expr) == SSA_NAME)
5874:     {
5875:       *tp = remap_ssa_name (*tp, id);
5876:       *walk_subtrees = 0;
5877:       if (is_lhs)
5878: 	SSA_NAME_DEF_STMT (*tp) = gsi_stmt (wi->gsi);
5879:     }
5880:   /* Only a local declaration (variable or label).  */
5881:   else if ((VAR_P (expr) && !TREE_STATIC (expr))
5882: 	   || TREE_CODE (expr) == LABEL_DECL)
5883:     {
5884:       /* Lookup the declaration.  */
5885:       n = st->get (expr);
5886:
5887:       /* If it's there, remap it.  */
5888:       if (n)
5889: 	*tp = *n;
5890:       *walk_subtrees = 0;
5891:     }
5892:   else if (TREE_CODE (expr) == STATEMENT_LIST
5893: 	   || TREE_CODE (expr) == BIND_EXPR
5894: 	   || TREE_CODE (expr) == SAVE_EXPR)
5895:     gcc_unreachable ();
5896:   else if (TREE_CODE (expr) == TARGET_EXPR)
5897:     {
5898:       /* Don't mess with a TARGET_EXPR that hasn't been expanded.
5899:          It's OK for this to happen if it was part of a subtree that
5900:          isn't immediately expanded, such as operand 2 of another
5901:          TARGET_EXPR.  */
5902:       if (!TREE_OPERAND (expr, 1))
5903: 	{
5904: 	  TREE_OPERAND (expr, 1) = TREE_OPERAND (expr, 3);
5905: 	  TREE_OPERAND (expr, 3) = NULL_TREE;
5906: 	}
5907:     }
5908:   else if (TREE_CODE (expr) == OMP_CLAUSE)
5909:     {
5910:       /* Before the omplower pass completes, some OMP clauses can contain
5911: 	 sequences that are neither copied by gimple_seq_copy nor walked by
5912: 	 walk_gimple_seq.  To make copy_gimple_seq_and_replace_locals work even
5913: 	 in those situations, we have to copy and process them explicitly.  */
5914:
5915:       if (OMP_CLAUSE_CODE (expr) == OMP_CLAUSE_LASTPRIVATE)
5916: 	{
5917: 	  gimple_seq seq = OMP_CLAUSE_LASTPRIVATE_GIMPLE_SEQ (expr);
5918: 	  seq = duplicate_remap_omp_clause_seq (seq, wi);
5919: 	  OMP_CLAUSE_LASTPRIVATE_GIMPLE_SEQ (expr) = seq;
5920: 	}
5921:       else if (OMP_CLAUSE_CODE (expr) == OMP_CLAUSE_LINEAR)
5922: 	{
5923: 	  gimple_seq seq = OMP_CLAUSE_LINEAR_GIMPLE_SEQ (expr);
5924: 	  seq = duplicate_remap_omp_clause_seq (seq, wi);
5925: 	  OMP_CLAUSE_LINEAR_GIMPLE_SEQ (expr) = seq;
5926: 	}
5927:       else if (OMP_CLAUSE_CODE (expr) == OMP_CLAUSE_REDUCTION)
5928: 	{
5929: 	  gimple_seq seq = OMP_CLAUSE_REDUCTION_GIMPLE_INIT (expr);
5930: 	  seq = duplicate_remap_omp_clause_seq (seq, wi);
5931: 	  OMP_CLAUSE_REDUCTION_GIMPLE_INIT (expr) = seq;
5932: 	  seq = OMP_CLAUSE_REDUCTION_GIMPLE_MERGE (expr);
5933: 	  seq = duplicate_remap_omp_clause_seq (seq, wi);
5934: 	  OMP_CLAUSE_REDUCTION_GIMPLE_MERGE (expr) = seq;
5935: 	}
5936:     }
5937:
5938:   /* Keep iterating.  */
5939:   return NULL_TREE;
5940: }
5941:
5942:
5943: /* Called via walk_gimple_seq by copy_gimple_seq_and_replace_local.
5944:    Using the splay_tree pointed to by ST (which is really a `splay_tree'),
5945:    remaps all local declarations to appropriate replacements in gimple
5946:    statements. */
5947:
5948: static tree
5949: replace_locals_stmt (gimple_stmt_iterator *gsip,
5950: 		     bool *handled_ops_p ATTRIBUTE_UNUSED,
5951: 		     struct walk_stmt_info *wi)
5952: {
5953:   copy_body_data *id = (copy_body_data *) wi->info;
5954:   gimple *gs = gsi_stmt (*gsip);
5955:
5956:   if (gbind *stmt = dyn_cast <gbind *> (gs))
5957:     {
5958:       tree block = gimple_bind_block (stmt);
5959:
5960:       if (block)
5961: 	{
5962: 	  remap_block (&block, id);
5963: 	  gimple_bind_set_block (stmt, block);
5964: 	}
5965:
5966:       /* This will remap a lot of the same decls again, but this should be
5967: 	 harmless.  */
5968:       if (gimple_bind_vars (stmt))
5969: 	{
5970: 	  tree old_var, decls = gimple_bind_vars (stmt);
5971:
5972: 	  for (old_var = decls; old_var; old_var = DECL_CHAIN (old_var))
5973: 	    if (!can_be_nonlocal (old_var, id)
5974: 		&& ! variably_modified_type_p (TREE_TYPE (old_var), id->src_fn))
5975: 	      remap_decl (old_var, id);
5976:
5977: 	  gcc_checking_assert (!id->prevent_decl_creation_for_types);
5978: 	  id->prevent_decl_creation_for_types = true;
5979: 	  gimple_bind_set_vars (stmt, remap_decls (decls, NULL, id));
5980: 	  id->prevent_decl_creation_for_types = false;
5981: 	}
5982:     }
5983:
5984:   /* Keep iterating.  */
5985:   return NULL_TREE;
5986: }
5987:
5988: /* Create a copy of SEQ and remap all decls in it.  */
5989:
5990: static gimple_seq
5991: duplicate_remap_omp_clause_seq (gimple_seq seq, struct walk_stmt_info *wi)
5992: {
5993:   if (!seq)
5994:     return NULL;
5995:
5996:   /* If there are any labels in OMP sequences, they can be only referred to in
5997:      the sequence itself and therefore we can do both here.  */
5998:   walk_gimple_seq (seq, mark_local_labels_stmt, NULL, wi);
5999:   gimple_seq copy = gimple_seq_copy (seq);
6000:   walk_gimple_seq (copy, replace_locals_stmt, replace_locals_op, wi);
6001:   return copy;
6002: }
6003:
6004: /* Copies everything in SEQ and replaces variables and labels local to
6005:    current_function_decl.  */
6006:
6007: gimple_seq
6008: copy_gimple_seq_and_replace_locals (gimple_seq seq)
6009: {
6010:   copy_body_data id;
6011:   struct walk_stmt_info wi;
6012:   gimple_seq copy;
6013:
6014:   /* There's nothing to do for NULL_TREE.  */
6015:   if (seq == NULL)
6016:     return seq;
6017:
6018:   /* Set up ID.  */
6019:   memset (&id, 0, sizeof (id));
6020:   id.src_fn = current_function_decl;
6021:   id.dst_fn = current_function_decl;
6022:   id.src_cfun = cfun;
6023:   id.decl_map = new hash_map<tree, tree>;
6024:   id.debug_map = NULL;
6025:
6026:   id.copy_decl = copy_decl_no_change;
6027:   id.transform_call_graph_edges = CB_CGE_DUPLICATE;
6028:   id.transform_new_cfg = false;
6029:   id.transform_return_to_modify = false;
6030:   id.transform_parameter = false;
6031:
6032:   /* Walk the tree once to find local labels.  */
6033:   memset (&wi, 0, sizeof (wi));
6034:   hash_set<tree> visited;
6035:   wi.info = &id;
6036:   wi.pset = &visited;
6037:   walk_gimple_seq (seq, mark_local_labels_stmt, NULL, &wi);
6038:
6039:   copy = gimple_seq_copy (seq);
6040:
6041:   /* Walk the copy, remapping decls.  */
6042:   memset (&wi, 0, sizeof (wi));
6043:   wi.info = &id;
6044:   walk_gimple_seq (copy, replace_locals_stmt, replace_locals_op, &wi);
6045:
6046:   /* Clean up.  */
6047:   delete id.decl_map;
6048:   if (id.debug_map)
6049:     delete id.debug_map;
6050:   if (id.dependence_map)
6051:     {
6052:       delete id.dependence_map;
6053:       id.dependence_map = NULL;
6054:     }
6055:
6056:   return copy;
6057: }
6058:
6059:
6060: /* Declare the variables created by the inliner.  Add all the variables in
```

## gcc/tree-inline.cc:6667–6720
```text
6667: maybe_inline_call_in_expr (tree exp)
6668: {
6669:   tree fn = get_callee_fndecl (exp);
6670:
6671:   /* We can only try to inline "const" functions.  */
6672:   if (fn && TREE_READONLY (fn) && DECL_SAVED_TREE (fn))
6673:     {
6674:       call_expr_arg_iterator iter;
6675:       copy_body_data id;
6676:       tree param, arg, t;
6677:       hash_map<tree, tree> decl_map;
6678:
6679:       /* Remap the parameters.  */
6680:       for (param = DECL_ARGUMENTS (fn), arg = first_call_expr_arg (exp, &iter);
6681: 	   param;
6682: 	   param = DECL_CHAIN (param), arg = next_call_expr_arg (&iter))
6683: 	decl_map.put (param, arg);
6684:
6685:       memset (&id, 0, sizeof (id));
6686:       id.src_fn = fn;
6687:       id.dst_fn = current_function_decl;
6688:       id.src_cfun = DECL_STRUCT_FUNCTION (fn);
6689:       id.decl_map = &decl_map;
6690:
6691:       id.copy_decl = copy_decl_no_change;
6692:       id.transform_call_graph_edges = CB_CGE_DUPLICATE;
6693:       id.transform_new_cfg = false;
6694:       id.transform_return_to_modify = true;
6695:       id.transform_parameter = true;
6696:
6697:       /* Make sure not to unshare trees behind the front-end's back
6698: 	 since front-end specific mechanisms may rely on sharing.  */
6699:       id.regimplify = false;
6700:       id.do_not_unshare = true;
6701:
6702:       /* We're not inside any EH region.  */
6703:       id.eh_lp_nr = 0;
6704:
6705:       t = copy_tree_body (&id);
6706:
6707:       /* We can only return something suitable for use in a GENERIC
6708: 	 expression tree.  */
6709:       if (TREE_CODE (t) == MODIFY_EXPR)
6710: 	return TREE_OPERAND (t, 1);
6711:     }
6712:
6713:    return NULL_TREE;
6714: }
6715:
6716: /* Duplicate a type, fields and all.  */
6717:
6718: tree
6719: build_duplicate_type (tree type)
6720: {
```

## gcc/langhooks-def.h:145–158
```text
145: #define LANG_HOOKS_BUILTIN_FUNCTION_EXT_SCOPE	LANG_HOOKS_BUILTIN_FUNCTION
146: #define LANG_HOOKS_SIMULATE_BUILTIN_FUNCTION_DECL LANG_HOOKS_BUILTIN_FUNCTION
147: #define LANG_HOOKS_EXPR_TO_DECL		lhd_expr_to_decl
148: #define LANG_HOOKS_TO_TARGET_CHARSET	lhd_to_target_charset
149: #define LANG_HOOKS_INIT_TS		lhd_do_nothing
150: #define LANG_HOOKS_EH_PERSONALITY	lhd_gcc_personality
151: #define LANG_HOOKS_EH_RUNTIME_TYPE	lhd_pass_through_t
152: #define LANG_HOOKS_EH_PROTECT_CLEANUP_ACTIONS	NULL
153: #define LANG_HOOKS_BLOCK_MAY_FALLTHRU	hook_bool_const_tree_true
154: #define LANG_HOOKS_EH_USE_CXA_END_CLEANUP	false
155: #define LANG_HOOKS_DEEP_UNSHARING	false
156: #define LANG_HOOKS_CUSTOM_FUNCTION_DESCRIPTORS	false
157: #define LANG_HOOKS_EMITS_BEGIN_STMT	false
158: #define LANG_HOOKS_RUN_LANG_SELFTESTS   lhd_do_nothing
```

## gcc/tree-cfg.cc:72–79
```text
72:
73: /* Local declarations.  */
74:
75: /* Initial capacity for the basic block array.  */
76: static const int initial_cfg_capacity = 20;
77:
78: /* This hash table allows us to efficiently lookup all CASE_LABEL_EXPRs
79:    which use a particular edge.  The CASE_LABEL_EXPRs are chained together
```

## gcc/tree-cfg.cc:145–214
```text
145: init_empty_tree_cfg_for_function (struct function *fn)
146: {
147:   /* Initialize the basic block array.  */
148:   init_flow (fn);
149:   profile_status_for_fn (fn) = PROFILE_ABSENT;
150:   n_basic_blocks_for_fn (fn) = NUM_FIXED_BLOCKS;
151:   last_basic_block_for_fn (fn) = NUM_FIXED_BLOCKS;
152:   vec_safe_grow_cleared (basic_block_info_for_fn (fn),
153: 			 initial_cfg_capacity, true);
154:
155:   /* Build a mapping of labels to their associated blocks.  */
156:   vec_safe_grow_cleared (label_to_block_map_for_fn (fn),
157: 			 initial_cfg_capacity, true);
158:
159:   SET_BASIC_BLOCK_FOR_FN (fn, ENTRY_BLOCK, ENTRY_BLOCK_PTR_FOR_FN (fn));
160:   SET_BASIC_BLOCK_FOR_FN (fn, EXIT_BLOCK, EXIT_BLOCK_PTR_FOR_FN (fn));
161:
162:   ENTRY_BLOCK_PTR_FOR_FN (fn)->next_bb
163:     = EXIT_BLOCK_PTR_FOR_FN (fn);
164:   EXIT_BLOCK_PTR_FOR_FN (fn)->prev_bb
165:     = ENTRY_BLOCK_PTR_FOR_FN (fn);
166: }
167:
168: void
169: init_empty_tree_cfg (void)
170: {
171:   init_empty_tree_cfg_for_function (cfun);
172: }
173:
174: /*---------------------------------------------------------------------------
175: 			      Create basic blocks
176: ---------------------------------------------------------------------------*/
177:
178: /* Entry point to the CFG builder for trees.  SEQ is the sequence of
179:    statements to be added to the flowgraph.  */
180:
181: static void
182: build_gimple_cfg (gimple_seq seq)
183: {
184:   /* Register specific gimple functions.  */
185:   gimple_register_cfg_hooks ();
186:
187:   memset ((void *) &cfg_stats, 0, sizeof (cfg_stats));
188:
189:   init_empty_tree_cfg ();
190:
191:   make_blocks (seq);
192:
193:   /* Make sure there is always at least one block, even if it's empty.  */
194:   if (n_basic_blocks_for_fn (cfun) == NUM_FIXED_BLOCKS)
195:     create_empty_bb (ENTRY_BLOCK_PTR_FOR_FN (cfun));
196:
197:   /* Adjust the size of the array.  */
198:   if (basic_block_info_for_fn (cfun)->length ()
199:       < (size_t) n_basic_blocks_for_fn (cfun))
200:     vec_safe_grow_cleared (basic_block_info_for_fn (cfun),
201: 			   n_basic_blocks_for_fn (cfun));
202:
203:   /* To speed up statement iterator walks, we first purge dead labels.  */
204:   cleanup_dead_labels ();
205:
206:   /* Group case nodes to reduce the number of edges.
207:      We do this after cleaning up dead labels because otherwise we miss
208:      a lot of obvious case merging opportunities.  */
209:   group_case_labels ();
210:
211:   /* Create the edges of the flowgraph.  */
212:   make_edges ();
213:   assign_discriminators ();
214:   cleanup_dead_labels ();
```

## gcc/tree-cfg.cc:488–555
```text
488: make_blocks_1 (gimple_seq seq, basic_block bb)
489: {
490:   gimple_stmt_iterator i = gsi_start (seq);
491:   gimple *stmt = NULL;
492:   gimple *prev_stmt = NULL;
493:   bool start_new_block = true;
494:   bool first_stmt_of_seq = true;
495:
496:   while (!gsi_end_p (i))
497:     {
498:       /* PREV_STMT should only be set to a debug stmt if the debug
499: 	 stmt is before nondebug stmts.  Once stmt reaches a nondebug
500: 	 nonlabel, prev_stmt will be set to it, so that
501: 	 stmt_starts_bb_p will know to start a new block if a label is
502: 	 found.  However, if stmt was a label after debug stmts only,
503: 	 keep the label in prev_stmt even if we find further debug
504: 	 stmts, for there may be other labels after them, and they
505: 	 should land in the same block.  */
506:       if (!prev_stmt || !stmt || !is_gimple_debug (stmt))
507: 	prev_stmt = stmt;
508:       stmt = gsi_stmt (i);
509:
510:       if (stmt && is_gimple_call (stmt))
511: 	gimple_call_initialize_ctrl_altering (stmt);
512:
513:       /* If the statement starts a new basic block or if we have determined
514: 	 in a previous pass that we need to create a new block for STMT, do
515: 	 so now.  */
516:       if (start_new_block || stmt_starts_bb_p (stmt, prev_stmt))
517: 	{
518: 	  if (!first_stmt_of_seq)
519: 	    gsi_split_seq_before (&i, &seq);
520: 	  bb = create_basic_block (seq, bb);
521: 	  start_new_block = false;
522: 	  prev_stmt = NULL;
523: 	}
524:
525:       /* Now add STMT to BB and create the subgraphs for special statement
526: 	 codes.  */
527:       gimple_set_bb (stmt, bb);
528:
529:       /* If STMT is a basic block terminator, set START_NEW_BLOCK for the
530: 	 next iteration.  */
531:       if (stmt_ends_bb_p (stmt))
532: 	{
533: 	  /* If the stmt can make abnormal goto use a new temporary
534: 	     for the assignment to the LHS.  This makes sure the old value
535: 	     of the LHS is available on the abnormal edge.  Otherwise
536: 	     we will end up with overlapping life-ranges for abnormal
537: 	     SSA names.  */
538: 	  if (gimple_has_lhs (stmt)
539: 	      && stmt_can_make_abnormal_goto (stmt)
540: 	      && is_gimple_reg_type (TREE_TYPE (gimple_get_lhs (stmt))))
541: 	    {
542: 	      tree lhs = gimple_get_lhs (stmt);
543: 	      tree tmp = create_tmp_var (TREE_TYPE (lhs));
544: 	      gimple *s = gimple_build_assign (lhs, tmp);
545: 	      gimple_set_location (s, gimple_location (stmt));
546: 	      gimple_set_block (s, gimple_block (stmt));
547: 	      gimple_set_lhs (stmt, tmp);
548: 	      gsi_insert_after (&i, s, GSI_SAME_STMT);
549: 	    }
550: 	  start_new_block = true;
551: 	}
552:
553:       gsi_next (&i);
554:       first_stmt_of_seq = false;
555:     }
```

## gcc/tree-cfg.cc:631–666
```text
631: create_bb (void *h, void *e, basic_block after)
632: {
633:   basic_block bb;
634:
635:   gcc_assert (!e);
636:
637:   /* Create and initialize a new basic block.  Since alloc_block uses
638:      GC allocation that clears memory to allocate a basic block, we do
639:      not have to clear the newly allocated basic block here.  */
640:   bb = alloc_block ();
641:
642:   bb->index = last_basic_block_for_fn (cfun);
643:   bb->flags = BB_NEW;
644:   set_bb_seq (bb, h ? (gimple_seq) h : NULL);
645:
646:   /* Add the new block to the linked list of blocks.  */
647:   link_block (bb, after);
648:
649:   /* Grow the basic block array if needed.  */
650:   if ((size_t) last_basic_block_for_fn (cfun)
651:       == basic_block_info_for_fn (cfun)->length ())
652:     vec_safe_grow_cleared (basic_block_info_for_fn (cfun),
653: 			   last_basic_block_for_fn (cfun) + 1);
654:
655:   /* Add the newly created block to the array.  */
656:   SET_BASIC_BLOCK_FOR_FN (cfun, last_basic_block_for_fn (cfun), bb);
657:
658:   n_basic_blocks_for_fn (cfun)++;
659:   last_basic_block_for_fn (cfun)++;
660:
661:   return bb;
662: }
663:
664:
665: /*---------------------------------------------------------------------------
666: 				 Edge creation
```

## gcc/tree-cfg.cc:810–1024
```text
810: make_edges_bb (basic_block bb, struct omp_region **pcur_region, int *pomp_index)
811: {
812:   gimple *last = *gsi_last_bb (bb);
813:   bool fallthru = false;
814:   int ret = 0;
815:
816:   if (!last)
817:     return ret;
818:
819:   switch (gimple_code (last))
820:     {
821:     case GIMPLE_GOTO:
822:       if (make_goto_expr_edges (bb))
823: 	ret = 1;
824:       fallthru = false;
825:       break;
826:     case GIMPLE_RETURN:
827:       {
828: 	edge e = make_edge (bb, EXIT_BLOCK_PTR_FOR_FN (cfun), 0);
829: 	e->goto_locus = gimple_location (last);
830: 	fallthru = false;
831:       }
832:       break;
833:     case GIMPLE_COND:
834:       make_cond_expr_edges (bb);
835:       fallthru = false;
836:       break;
837:     case GIMPLE_SWITCH:
838:       make_gimple_switch_edges (as_a <gswitch *> (last), bb);
839:       fallthru = false;
840:       break;
841:     case GIMPLE_RESX:
842:       make_eh_edge (last);
843:       fallthru = false;
844:       break;
845:     case GIMPLE_EH_DISPATCH:
846:       fallthru = make_eh_dispatch_edges (as_a <geh_dispatch *> (last));
847:       break;
848:
849:     case GIMPLE_CALL:
850:       /* If this function receives a nonlocal goto, then we need to
851: 	 make edges from this call site to all the nonlocal goto
852: 	 handlers.  */
853:       if (stmt_can_make_abnormal_goto (last))
854: 	ret = 2;
855:
856:       /* If this statement has reachable exception handlers, then
857: 	 create abnormal edges to them.  */
858:       make_eh_edge (last);
859:
860:       /* BUILTIN_RETURN is really a return statement.  */
861:       if (gimple_call_builtin_p (last, BUILT_IN_RETURN))
862: 	{
863: 	  make_edge (bb, EXIT_BLOCK_PTR_FOR_FN (cfun), 0);
864: 	  fallthru = false;
865: 	}
866:       /* Some calls are known not to return.  */
867:       else
868: 	fallthru = !gimple_call_noreturn_p (last);
869:       break;
870:
871:     case GIMPLE_ASSIGN:
872:       /* A GIMPLE_ASSIGN may throw internally and thus be considered
873: 	 control-altering.  */
874:       if (is_ctrl_altering_stmt (last))
875: 	make_eh_edge (last);
876:       fallthru = true;
877:       break;
878:
879:     case GIMPLE_ASM:
880:       make_gimple_asm_edges (bb);
881:       fallthru = true;
882:       break;
883:
884:     CASE_GIMPLE_OMP:
885:       fallthru = omp_make_gimple_edges (bb, pcur_region, pomp_index);
886:       break;
887:
888:     case GIMPLE_TRANSACTION:
889:       {
890:         gtransaction *txn = as_a <gtransaction *> (last);
891: 	tree label1 = gimple_transaction_label_norm (txn);
892: 	tree label2 = gimple_transaction_label_uninst (txn);
893:
894: 	if (label1)
895: 	  make_edge (bb, label_to_block (cfun, label1), EDGE_FALLTHRU);
896: 	if (label2)
897: 	  make_edge (bb, label_to_block (cfun, label2),
898: 		     EDGE_TM_UNINSTRUMENTED | (label1 ? 0 : EDGE_FALLTHRU));
899:
900: 	tree label3 = gimple_transaction_label_over (txn);
901: 	if (gimple_transaction_subcode (txn)
902: 	    & (GTMA_HAVE_ABORT | GTMA_IS_OUTER))
903: 	  make_edge (bb, label_to_block (cfun, label3), EDGE_TM_ABORT);
904:
905: 	fallthru = false;
906:       }
907:       break;
908:
909:     default:
910:       gcc_assert (!stmt_ends_bb_p (last));
911:       fallthru = true;
912:       break;
913:     }
914:
915:   if (fallthru)
916:     make_edge (bb, bb->next_bb, EDGE_FALLTHRU);
917:
918:   return ret;
919: }
920:
921: /* Join all the blocks in the flowgraph.  */
922:
923: static void
924: make_edges (void)
925: {
926:   basic_block bb;
927:   struct omp_region *cur_region = NULL;
928:   auto_vec<basic_block> ab_edge_goto;
929:   auto_vec<basic_block> ab_edge_call;
930:   int cur_omp_region_idx = 0;
931:
932:   /* Create an edge from entry to the first block with executable
933:      statements in it.  */
934:   make_edge (ENTRY_BLOCK_PTR_FOR_FN (cfun),
935: 	     BASIC_BLOCK_FOR_FN (cfun, NUM_FIXED_BLOCKS),
936: 	     EDGE_FALLTHRU);
937:
938:   /* Traverse the basic block array placing edges.  */
939:   FOR_EACH_BB_FN (bb, cfun)
940:     {
941:       int mer;
942:
943:       if (!bb_to_omp_idx.is_empty ())
944: 	bb_to_omp_idx[bb->index] = cur_omp_region_idx;
945:
946:       mer = make_edges_bb (bb, &cur_region, &cur_omp_region_idx);
947:       if (mer == 1)
948: 	ab_edge_goto.safe_push (bb);
949:       else if (mer == 2)
950: 	ab_edge_call.safe_push (bb);
951:
952:       if (cur_region && bb_to_omp_idx.is_empty ())
953: 	bb_to_omp_idx.safe_grow_cleared (n_basic_blocks_for_fn (cfun), true);
954:     }
955:
956:   /* Computed gotos are hell to deal with, especially if there are
957:      lots of them with a large number of destinations.  So we factor
958:      them to a common computed goto location before we build the
959:      edge list.  After we convert back to normal form, we will un-factor
960:      the computed gotos since factoring introduces an unwanted jump.
961:      For non-local gotos and abnormal edges from calls to calls that return
962:      twice or forced labels, factor the abnormal edges too, by having all
963:      abnormal edges from the calls go to a common artificial basic block
964:      with ABNORMAL_DISPATCHER internal call and abnormal edges from that
965:      basic block to all forced labels and calls returning twice.
966:      We do this per-OpenMP structured block, because those regions
967:      are guaranteed to be single entry single exit by the standard,
968:      so it is not allowed to enter or exit such regions abnormally this way,
969:      thus all computed gotos, non-local gotos and setjmp/longjmp calls
970:      must not transfer control across SESE region boundaries.  */
971:   if (!ab_edge_goto.is_empty () || !ab_edge_call.is_empty ())
972:     {
973:       gimple_stmt_iterator gsi;
974:       basic_block dispatcher_bb_array[2] = { NULL, NULL };
975:       basic_block *dispatcher_bbs = dispatcher_bb_array;
976:       int count = n_basic_blocks_for_fn (cfun);
977:
978:       if (!bb_to_omp_idx.is_empty ())
979: 	dispatcher_bbs = XCNEWVEC (basic_block, 2 * count);
980:
981:       FOR_EACH_BB_FN (bb, cfun)
982: 	{
983: 	  for (gsi = gsi_start_bb (bb); !gsi_end_p (gsi); gsi_next (&gsi))
984: 	    {
985: 	      glabel *label_stmt = dyn_cast <glabel *> (gsi_stmt (gsi));
986: 	      tree target;
987:
988: 	      if (!label_stmt)
989: 		break;
990:
991: 	      target = gimple_label_label (label_stmt);
992:
993: 	      /* Make an edge to every label block that has been marked as a
994: 		 potential target for a computed goto or a non-local goto.  */
995: 	      if (FORCED_LABEL (target))
996: 		handle_abnormal_edges (dispatcher_bbs, bb, &ab_edge_goto,
997: 				       true);
998: 	      if (DECL_NONLOCAL (target))
999: 		{
1000: 		  handle_abnormal_edges (dispatcher_bbs, bb, &ab_edge_call,
1001: 					 false);
1002: 		  break;
1003: 		}
1004: 	    }
1005:
1006: 	  if (!gsi_end_p (gsi) && is_gimple_debug (gsi_stmt (gsi)))
1007: 	    gsi_next_nondebug (&gsi);
1008: 	  if (!gsi_end_p (gsi))
1009: 	    {
1010: 	      /* Make an edge to every setjmp-like call.  */
1011: 	      gimple *call_stmt = gsi_stmt (gsi);
1012: 	      if (is_gimple_call (call_stmt)
1013: 		  && ((gimple_call_flags (call_stmt) & ECF_RETURNS_TWICE)
1014: 		      || gimple_call_builtin_p (call_stmt,
1015: 						BUILT_IN_SETJMP_RECEIVER)))
1016: 		handle_abnormal_edges (dispatcher_bbs, bb, &ab_edge_call,
1017: 				       false);
1018: 	    }
1019: 	}
1020:
1021:       if (!bb_to_omp_idx.is_empty ())
1022: 	XDELETE (dispatcher_bbs);
1023:     }
1024:
```

## gcc/tree-cfg.cc:1085–1220
```text
1085: struct discrim_entry
1086: {
1087:   /* ID of basic block we saw line number last time.  */
1088:   unsigned int bb_id;
1089:   /* Discriminator we used.  */
1090:   unsigned int discrim;
1091: };
1092:
1093: /* Return updated LOC with discriminator for use in basic block BB_ID.
1094:    MAP keeps track of current values.  */
1095:
1096: location_t
1097: assign_discriminator (location_t loc, unsigned int bb_id,
1098: 		      hash_map<int_hash <unsigned, -1U, -2U>,
1099: 			       discrim_entry> &map)
1100: {
1101:   bool existed;
1102:   if ((unsigned) LOCATION_LINE (loc) >= -2U)
1103:     return loc;
1104:   discrim_entry &e
1105:     = map.get_or_insert ((unsigned) LOCATION_LINE (loc), &existed);
1106:   gcc_checking_assert (!has_discriminator (loc));
1107:   if (!existed)
1108:     {
1109:       e.bb_id = bb_id;
1110:       e.discrim = 0;
1111:       return loc;
1112:     }
1113:   if (e.bb_id != bb_id)
1114:     {
1115:       e.bb_id = bb_id;
1116:       e.discrim++;
1117:     }
1118:   if (e.discrim)
1119:     return location_with_discriminator (loc, e.discrim);
1120:   return loc;
1121: }
1122:
1123: /* Assign discriminators to statement locations.  */
1124:
1125: static void
1126: assign_discriminators (void)
1127: {
1128:   hash_map<int_hash <unsigned, -1U, -2U>, discrim_entry> map (13);
1129:   unsigned int bb_id = 0;
1130:   basic_block bb;
1131:   FOR_EACH_BB_FN (bb, cfun)
1132:     {
1133:       location_t prev_loc = UNKNOWN_LOCATION, prev_replacement = UNKNOWN_LOCATION;
1134:       /* Traverse the basic block, if two function calls within a basic block
1135: 	 are mapped to the same line, assign a new discriminator because a call
1136: 	 stmt could be a split point of a basic block.  */
1137:       for (gimple_stmt_iterator gsi = gsi_start_bb (bb);
1138: 	   !gsi_end_p (gsi); gsi_next (&gsi))
1139: 	{
1140: 	  gimple *stmt = gsi_stmt (gsi);
1141: 	  location_t loc = gimple_location (stmt);
1142: 	  if (loc == UNKNOWN_LOCATION)
1143: 	    continue;
1144: 	  if (loc == prev_loc)
1145: 	    gimple_set_location (stmt, prev_replacement);
1146: 	  else
1147: 	    {
1148: 	      prev_loc = loc;
1149: 	      prev_replacement = assign_discriminator (loc, bb_id, map);
1150: 	      gimple_set_location (stmt, prev_replacement);
1151: 	    }
1152: 	  /* Break basic blocks after each call.  This is required so each
1153: 	     call site has unique discriminator.
1154: 	     More correctly, we can break after each statement that can possibly
1155: 	     terinate execution of the basic block, but for auto-profile this
1156: 	     precision is probably not useful.  */
1157: 	  if (gimple_code (stmt) == GIMPLE_CALL)
1158: 	    {
1159: 	      prev_loc = UNKNOWN_LOCATION;
1160: 	      bb_id++;
1161: 	    }
1162: 	}
1163:       /* If basic block has multiple sucessors, consdier every edge as a
1164: 	 separate block.  */
1165:       if (!single_succ_p (bb))
1166: 	bb_id++;
1167:       for (edge e : bb->succs)
1168: 	{
1169: 	  if (e->goto_locus != UNKNOWN_LOCATION)
1170: 	    e->goto_locus = assign_discriminator (e->goto_locus, bb_id, map);
1171: 	  for (gphi_iterator gpi = gsi_start_phis (bb);
1172: 	       !gsi_end_p (gpi); gsi_next (&gpi))
1173: 	    {
1174: 	      gphi *phi = gpi.phi ();
1175: 	      location_t phi_loc
1176: 		= gimple_phi_arg_location_from_edge (phi, e);
1177: 	      if (phi_loc == UNKNOWN_LOCATION)
1178: 		continue;
1179: 	      gimple_phi_arg_set_location
1180: 		(phi, e->dest_idx, assign_discriminator (phi_loc, bb_id, map));
1181: 	    }
1182: 	   bb_id++;
1183: 	}
1184:       bb_id++;
1185:     }
1186:
1187: }
1188:
1189: /* Create the edges for a GIMPLE_COND starting at block BB.  */
1190:
1191: static void
1192: make_cond_expr_edges (basic_block bb)
1193: {
1194:   gcond *entry = as_a <gcond *> (*gsi_last_bb (bb));
1195:   gimple *then_stmt, *else_stmt;
1196:   basic_block then_bb, else_bb;
1197:   tree then_label, else_label;
1198:   edge e;
1199:
1200:   gcc_assert (entry);
1201:
1202:   /* Entry basic blocks for each component.  */
1203:   then_label = gimple_cond_true_label (entry);
1204:   else_label = gimple_cond_false_label (entry);
1205:   then_bb = label_to_block (cfun, then_label);
1206:   else_bb = label_to_block (cfun, else_label);
1207:   then_stmt = first_stmt (then_bb);
1208:   else_stmt = first_stmt (else_bb);
1209:
1210:   e = make_edge (bb, then_bb, EDGE_TRUE_VALUE);
1211:   e->goto_locus = gimple_location (then_stmt);
1212:   e = make_edge (bb, else_bb, EDGE_FALSE_VALUE);
1213:   if (e)
1214:     e->goto_locus = gimple_location (else_stmt);
1215:
1216:   /* We do not need the labels anymore.  */
1217:   gimple_cond_set_true_label (entry, NULL_TREE);
1218:   gimple_cond_set_false_label (entry, NULL_TREE);
1219: }
1220:
```

## gcc/tree-cfg.cc:1325–1405
```text
1325: /* Create the edges for a GIMPLE_SWITCH starting at block BB.  */
1326:
1327: static void
1328: make_gimple_switch_edges (gswitch *entry, basic_block bb)
1329: {
1330:   size_t i, n;
1331:
1332:   n = gimple_switch_num_labels (entry);
1333:
1334:   for (i = 0; i < n; ++i)
1335:     {
1336:       basic_block label_bb = gimple_switch_label_bb (cfun, entry, i);
1337:       make_edge (bb, label_bb, 0);
1338:     }
1339: }
1340:
1341:
1342: /* Return the basic block holding label DEST.  */
1343:
1344: basic_block
1345: label_to_block (struct function *ifun, tree dest)
1346: {
1347:   int uid = LABEL_DECL_UID (dest);
1348:
1349:   /* We would die hard when faced by an undefined label.  Emit a label to
1350:      the very first basic block.  This will hopefully make even the dataflow
1351:      and undefined variable warnings quite right.  */
1352:   if (seen_error () && uid < 0)
1353:     {
1354:       gimple_stmt_iterator gsi =
1355: 	gsi_start_bb (BASIC_BLOCK_FOR_FN (cfun, NUM_FIXED_BLOCKS));
1356:       gimple *stmt;
1357:
1358:       stmt = gimple_build_label (dest);
1359:       gsi_insert_before (&gsi, stmt, GSI_NEW_STMT);
1360:       uid = LABEL_DECL_UID (dest);
1361:     }
1362:   if (vec_safe_length (ifun->cfg->x_label_to_block_map) <= (unsigned int) uid)
1363:     return NULL;
1364:   return (*ifun->cfg->x_label_to_block_map)[uid];
1365: }
1366:
1367: /* Create edges for a goto statement at block BB.  Returns true
1368:    if abnormal edges should be created.  */
1369:
1370: static bool
1371: make_goto_expr_edges (basic_block bb)
1372: {
1373:   gimple_stmt_iterator last = gsi_last_bb (bb);
1374:   gimple *goto_t = gsi_stmt (last);
1375:
1376:   /* A simple GOTO creates normal edges.  */
1377:   if (simple_goto_p (goto_t))
1378:     {
1379:       tree dest = gimple_goto_dest (goto_t);
1380:       basic_block label_bb = label_to_block (cfun, dest);
1381:       edge e = make_edge (bb, label_bb, EDGE_FALLTHRU);
1382:       e->goto_locus = gimple_location (goto_t);
1383:       gsi_remove (&last, true);
1384:       return false;
1385:     }
1386:
1387:   /* A computed GOTO creates abnormal edges.  */
1388:   return true;
1389: }
1390:
1391: /* Create edges for an asm statement with labels at block BB.  */
1392:
1393: static void
1394: make_gimple_asm_edges (basic_block bb)
1395: {
1396:   gasm *stmt = as_a <gasm *> (*gsi_last_bb (bb));
1397:   int i, n = gimple_asm_nlabels (stmt);
1398:
1399:   for (i = 0; i < n; ++i)
1400:     {
1401:       tree label = TREE_VALUE (gimple_asm_label_op (stmt, i));
1402:       basic_block label_bb = label_to_block (cfun, label);
1403:       make_edge (bb, label_bb, 0);
1404:     }
1405: }
```

## gcc/tree-cfg.cc:1507–1698
```text
1507: cleanup_dead_labels (void)
1508: {
1509:   basic_block bb;
1510:   label_record *label_for_bb = XCNEWVEC (struct label_record,
1511: 					 last_basic_block_for_fn (cfun));
1512:
1513:   /* Find a suitable label for each block.  We use the first user-defined
1514:      label if there is one, or otherwise just the first label we see.  */
1515:   FOR_EACH_BB_FN (bb, cfun)
1516:     {
1517:       gimple_stmt_iterator i;
1518:
1519:       for (i = gsi_start_bb (bb); !gsi_end_p (i); gsi_next (&i))
1520: 	{
1521: 	  tree label;
1522: 	  glabel *label_stmt = dyn_cast <glabel *> (gsi_stmt (i));
1523:
1524: 	  if (!label_stmt)
1525: 	    break;
1526:
1527: 	  label = gimple_label_label (label_stmt);
1528:
1529: 	  /* If we have not yet seen a label for the current block,
1530: 	     remember this one and see if there are more labels.  */
1531: 	  if (!label_for_bb[bb->index].label)
1532: 	    {
1533: 	      label_for_bb[bb->index].label = label;
1534: 	      continue;
1535: 	    }
1536:
1537: 	  /* If we did see a label for the current block already, but it
1538: 	     is an artificially created label, replace it if the current
1539: 	     label is a user defined label.  */
1540: 	  if (!DECL_ARTIFICIAL (label)
1541: 	      && DECL_ARTIFICIAL (label_for_bb[bb->index].label))
1542: 	    {
1543: 	      label_for_bb[bb->index].label = label;
1544: 	      break;
1545: 	    }
1546: 	}
1547:     }
1548:
1549:   /* Now redirect all jumps/branches to the selected label.
1550:      First do so for each block ending in a control statement.  */
1551:   FOR_EACH_BB_FN (bb, cfun)
1552:     {
1553:       gimple *stmt = *gsi_last_bb (bb);
1554:       tree label, new_label;
1555:
1556:       if (!stmt)
1557: 	continue;
1558:
1559:       switch (gimple_code (stmt))
1560: 	{
1561: 	case GIMPLE_COND:
1562: 	  {
1563: 	    gcond *cond_stmt = as_a <gcond *> (stmt);
1564: 	    label = gimple_cond_true_label (cond_stmt);
1565: 	    if (label)
1566: 	      {
1567: 		new_label = main_block_label (label, label_for_bb);
1568: 		if (new_label != label)
1569: 		  gimple_cond_set_true_label (cond_stmt, new_label);
1570: 	      }
1571:
1572: 	    label = gimple_cond_false_label (cond_stmt);
1573: 	    if (label)
1574: 	      {
1575: 		new_label = main_block_label (label, label_for_bb);
1576: 		if (new_label != label)
1577: 		  gimple_cond_set_false_label (cond_stmt, new_label);
1578: 	      }
1579: 	  }
1580: 	  break;
1581:
1582: 	case GIMPLE_SWITCH:
1583: 	  {
1584: 	    gswitch *switch_stmt = as_a <gswitch *> (stmt);
1585: 	    size_t i, n = gimple_switch_num_labels (switch_stmt);
1586:
1587: 	    /* Replace all destination labels.  */
1588: 	    for (i = 0; i < n; ++i)
1589: 	      {
1590: 		tree case_label = gimple_switch_label (switch_stmt, i);
1591: 		label = CASE_LABEL (case_label);
1592: 		new_label = main_block_label (label, label_for_bb);
1593: 		if (new_label != label)
1594: 		  CASE_LABEL (case_label) = new_label;
1595: 	      }
1596: 	    break;
1597: 	  }
1598:
1599: 	case GIMPLE_ASM:
1600: 	  {
1601: 	    gasm *asm_stmt = as_a <gasm *> (stmt);
1602: 	    int i, n = gimple_asm_nlabels (asm_stmt);
1603:
1604: 	    for (i = 0; i < n; ++i)
1605: 	      {
1606: 		tree cons = gimple_asm_label_op (asm_stmt, i);
1607: 		tree label = main_block_label (TREE_VALUE (cons), label_for_bb);
1608: 		TREE_VALUE (cons) = label;
1609: 	      }
1610: 	    break;
1611: 	  }
1612:
1613: 	/* We have to handle gotos until they're removed, and we don't
1614: 	   remove them until after we've created the CFG edges.  */
1615: 	case GIMPLE_GOTO:
1616: 	  if (!computed_goto_p (stmt))
1617: 	    {
1618: 	      ggoto *goto_stmt = as_a <ggoto *> (stmt);
1619: 	      label = gimple_goto_dest (goto_stmt);
1620: 	      new_label = main_block_label (label, label_for_bb);
1621: 	      if (new_label != label)
1622: 		gimple_goto_set_dest (goto_stmt, new_label);
1623: 	    }
1624: 	  break;
1625:
1626: 	case GIMPLE_TRANSACTION:
1627: 	  {
1628: 	    gtransaction *txn = as_a <gtransaction *> (stmt);
1629:
1630: 	    label = gimple_transaction_label_norm (txn);
1631: 	    if (label)
1632: 	      {
1633: 		new_label = main_block_label (label, label_for_bb);
1634: 		if (new_label != label)
1635: 		  gimple_transaction_set_label_norm (txn, new_label);
1636: 	      }
1637:
1638: 	    label = gimple_transaction_label_uninst (txn);
1639: 	    if (label)
1640: 	      {
1641: 		new_label = main_block_label (label, label_for_bb);
1642: 		if (new_label != label)
1643: 		  gimple_transaction_set_label_uninst (txn, new_label);
1644: 	      }
1645:
1646: 	    label = gimple_transaction_label_over (txn);
1647: 	    if (label)
1648: 	      {
1649: 		new_label = main_block_label (label, label_for_bb);
1650: 		if (new_label != label)
1651: 		  gimple_transaction_set_label_over (txn, new_label);
1652: 	      }
1653: 	  }
1654: 	  break;
1655:
1656: 	default:
1657: 	  break;
1658:       }
1659:     }
1660:
1661:   /* Do the same for the exception region tree labels.  */
1662:   cleanup_dead_labels_eh (label_for_bb);
1663:
1664:   /* Finally, purge dead labels.  All user-defined labels and labels that
1665:      can be the target of non-local gotos and labels which have their
1666:      address taken are preserved.  */
1667:   FOR_EACH_BB_FN (bb, cfun)
1668:     {
1669:       gimple_stmt_iterator i;
1670:       tree label_for_this_bb = label_for_bb[bb->index].label;
1671:
1672:       if (!label_for_this_bb)
1673: 	continue;
1674:
1675:       /* If the main label of the block is unused, we may still remove it.  */
1676:       if (!label_for_bb[bb->index].used)
1677: 	label_for_this_bb = NULL;
1678:
1679:       for (i = gsi_start_bb (bb); !gsi_end_p (i); )
1680: 	{
1681: 	  tree label;
1682: 	  glabel *label_stmt = dyn_cast <glabel *> (gsi_stmt (i));
1683:
1684: 	  if (!label_stmt)
1685: 	    break;
1686:
1687: 	  label = gimple_label_label (label_stmt);
1688:
1689: 	  if (label == label_for_this_bb
1690: 	      || !DECL_ARTIFICIAL (label)
1691: 	      || DECL_NONLOCAL (label)
1692: 	      || FORCED_LABEL (label))
1693: 	    gsi_next (&i);
1694: 	  else
1695: 	    {
1696: 	      gcc_checking_assert (EH_LANDING_PAD_NR (label) == 0);
1697: 	      gsi_remove (&i, true);
1698: 	    }
```

## gcc/tree-cfg.cc:1710–1852
```text
1710: group_case_labels_stmt (gswitch *stmt)
1711: {
1712:   int old_size = gimple_switch_num_labels (stmt);
1713:   int i, next_index, new_size;
1714:   basic_block default_bb = NULL;
1715:   hash_set<tree> *removed_labels = NULL;
1716:
1717:   default_bb = gimple_switch_default_bb (cfun, stmt);
1718:
1719:   /* Look for possible opportunities to merge cases.  */
1720:   new_size = i = 1;
1721:   while (i < old_size)
1722:     {
1723:       tree base_case, base_high;
1724:       basic_block base_bb;
1725:
1726:       base_case = gimple_switch_label (stmt, i);
1727:
1728:       gcc_assert (base_case);
1729:       base_bb = label_to_block (cfun, CASE_LABEL (base_case));
1730:
1731:       /* Discard cases that have the same destination as the default case or
1732: 	 whose destination blocks have already been removed as unreachable.  */
1733:       if (base_bb == NULL
1734: 	  || base_bb == default_bb
1735: 	  || (removed_labels
1736: 	      && removed_labels->contains (CASE_LABEL (base_case))))
1737: 	{
1738: 	  i++;
1739: 	  continue;
1740: 	}
1741:
1742:       base_high = CASE_HIGH (base_case)
1743: 	  ? CASE_HIGH (base_case)
1744: 	  : CASE_LOW (base_case);
1745:       next_index = i + 1;
1746:
1747:       /* Try to merge case labels.  Break out when we reach the end
1748: 	 of the label vector or when we cannot merge the next case
1749: 	 label with the current one.  */
1750:       while (next_index < old_size)
1751: 	{
1752: 	  tree merge_case = gimple_switch_label (stmt, next_index);
1753: 	  basic_block merge_bb = label_to_block (cfun, CASE_LABEL (merge_case));
1754: 	  wide_int bhp1 = wi::to_wide (base_high) + 1;
1755:
1756: 	  /* Merge the cases if they jump to the same place,
1757: 	     and their ranges are consecutive.  */
1758: 	  if (merge_bb == base_bb
1759: 	      && (removed_labels == NULL
1760: 		  || !removed_labels->contains (CASE_LABEL (merge_case)))
1761: 	      && wi::to_wide (CASE_LOW (merge_case)) == bhp1)
1762: 	    {
1763: 	      base_high
1764: 		= (CASE_HIGH (merge_case)
1765: 		   ? CASE_HIGH (merge_case) : CASE_LOW (merge_case));
1766: 	      CASE_HIGH (base_case) = base_high;
1767: 	      next_index++;
1768: 	    }
1769: 	  else
1770: 	    break;
1771: 	}
1772:
1773:       /* Discard cases that have an unreachable destination block.  */
1774:       if (EDGE_COUNT (base_bb->succs) == 0
1775: 	  && gimple_seq_unreachable_p (bb_seq (base_bb))
1776: 	  /* Don't optimize this if __builtin_unreachable () is the
1777: 	     implicitly added one by the C++ FE too early, before
1778: 	     -Wreturn-type can be diagnosed.  We'll optimize it later
1779: 	     during switchconv pass or any other cfg cleanup.  */
1780: 	  && (gimple_in_ssa_p (cfun)
1781: 	      || (LOCATION_LOCUS (gimple_location (last_nondebug_stmt (base_bb)))
1782: 		  != BUILTINS_LOCATION)))
1783: 	{
1784: 	  edge base_edge = find_edge (gimple_bb (stmt), base_bb);
1785: 	  if (base_edge != NULL)
1786: 	    {
1787: 	      for (gimple_stmt_iterator gsi = gsi_start_bb (base_bb);
1788: 		   !gsi_end_p (gsi); gsi_next (&gsi))
1789: 		if (glabel *stmt = dyn_cast <glabel *> (gsi_stmt (gsi)))
1790: 		  {
1791: 		    if (FORCED_LABEL (gimple_label_label (stmt))
1792: 			|| DECL_NONLOCAL (gimple_label_label (stmt)))
1793: 		      {
1794: 			/* Forced/non-local labels aren't going to be removed,
1795: 			   but they will be moved to some neighbouring basic
1796: 			   block. If some later case label refers to one of
1797: 			   those labels, we should throw that case away rather
1798: 			   than keeping it around and referring to some random
1799: 			   other basic block without an edge to it.  */
1800: 			if (removed_labels == NULL)
1801: 			  removed_labels = new hash_set<tree>;
1802: 			removed_labels->add (gimple_label_label (stmt));
1803: 		      }
1804: 		  }
1805: 		else
1806: 		  break;
1807: 	      remove_edge_and_dominated_blocks (base_edge);
1808: 	    }
1809: 	  i = next_index;
1810: 	  continue;
1811: 	}
1812:
1813:       if (new_size < i)
1814: 	gimple_switch_set_label (stmt, new_size,
1815: 				 gimple_switch_label (stmt, i));
1816:       i = next_index;
1817:       new_size++;
1818:     }
1819:
1820:   gcc_assert (new_size <= old_size);
1821:
1822:   if (new_size < old_size)
1823:     gimple_switch_set_num_labels (stmt, new_size);
1824:
1825:   delete removed_labels;
1826:   return new_size < old_size;
1827: }
1828:
1829: /* Look for blocks ending in a multiway branch (a GIMPLE_SWITCH),
1830:    and scan the sorted vector of cases.  Combine the ones jumping to the
1831:    same label.  */
1832:
1833: bool
1834: group_case_labels (void)
1835: {
1836:   basic_block bb;
1837:   bool changed = false;
1838:
1839:   FOR_EACH_BB_FN (bb, cfun)
1840:     {
1841:       if (gswitch *stmt = safe_dyn_cast <gswitch *> (*gsi_last_bb (bb)))
1842: 	changed |= group_case_labels_stmt (stmt);
1843:     }
1844:
1845:   return changed;
1846: }
1847:
1848: /* Checks whether we can merge block B into block A.  */
1849:
1850: static bool
1851: gimple_can_merge_blocks_p (basic_block a, basic_block b)
1852: {
```

## gcc/tree-cfg.cc:2633–2666
```text
2633: call_can_make_abnormal_goto (gimple *t)
2634: {
2635:   /* If the function has no non-local labels, then a call cannot make an
2636:      abnormal transfer of control.  */
2637:   if (!cfun->has_nonlocal_label
2638:       && !cfun->calls_setjmp)
2639:    return false;
2640:
2641:   /* Likewise if the call has no side effects.  */
2642:   if (!gimple_has_side_effects (t))
2643:     return false;
2644:
2645:   /* Likewise if the called function is leaf.  */
2646:   if (gimple_call_flags (t) & ECF_LEAF)
2647:     return false;
2648:
2649:   return true;
2650: }
2651:
2652:
2653: /* Return true if T can make an abnormal transfer of control flow.
2654:    Transfers of control flow associated with EH are excluded.  */
2655:
2656: bool
2657: stmt_can_make_abnormal_goto (gimple *t)
2658: {
2659:   if (computed_goto_p (t))
2660:     return true;
2661:   if (is_gimple_call (t))
2662:     return call_can_make_abnormal_goto (t);
2663:   return false;
2664: }
2665:
2666:
```

## gcc/cfg.cc:65–83
```text
65: void
66: init_flow (struct function *the_fun)
67: {
68:   if (!the_fun->cfg)
69:     the_fun->cfg = ggc_cleared_alloc<control_flow_graph> ();
70:   n_edges_for_fn (the_fun) = 0;
71:   the_fun->cfg->count_max = profile_count::uninitialized ();
72:   ENTRY_BLOCK_PTR_FOR_FN (the_fun)
73:     = alloc_block ();
74:   ENTRY_BLOCK_PTR_FOR_FN (the_fun)->index = ENTRY_BLOCK;
75:   EXIT_BLOCK_PTR_FOR_FN (the_fun)
76:     = alloc_block ();
77:   EXIT_BLOCK_PTR_FOR_FN (the_fun)->index = EXIT_BLOCK;
78:   ENTRY_BLOCK_PTR_FOR_FN (the_fun)->next_bb
79:     = EXIT_BLOCK_PTR_FOR_FN (the_fun);
80:   EXIT_BLOCK_PTR_FOR_FN (the_fun)->prev_bb
81:     = ENTRY_BLOCK_PTR_FOR_FN (the_fun);
82:   the_fun->cfg->edge_flags_allocated = EDGE_ALL_FLAGS;
83:   the_fun->cfg->bb_flags_allocated = BB_ALL_FLAGS;
```

## gcc/cfg.cc:214–231
```text
214: static inline void
215: connect_src (edge e)
216: {
217:   vec_safe_push (e->src->succs, e);
218:   df_mark_solutions_dirty ();
219: }
220:
221: /* Connect E to E->dest.  */
222:
223: static inline void
224: connect_dest (edge e)
225: {
226:   basic_block dest = e->dest;
227:   vec_safe_push (dest->preds, e);
228:   e->dest_idx = EDGE_COUNT (dest->preds) - 1;
229:   df_mark_solutions_dirty ();
230: }
231:
```

## gcc/cfg.cc:278–342
```text
278: unchecked_make_edge (basic_block src, basic_block dst, int flags)
279: {
280:   edge e;
281:   e = ggc_cleared_alloc<edge_def> ();
282:   n_edges_for_fn (cfun)++;
283:
284:   e->probability = profile_probability::uninitialized ();
285:   e->src = src;
286:   e->dest = dst;
287:   e->flags = flags;
288:
289:   connect_src (e);
290:   connect_dest (e);
291:
292:   execute_on_growing_pred (e);
293:   return e;
294: }
295:
296: /* Create an edge connecting SRC and DST with FLAGS optionally using
297:    edge cache CACHE.  Return the new edge, NULL if already exist.  */
298:
299: edge
300: cached_make_edge (sbitmap edge_cache, basic_block src, basic_block dst, int flags)
301: {
302:   if (edge_cache == NULL
303:       || src == ENTRY_BLOCK_PTR_FOR_FN (cfun)
304:       || dst == EXIT_BLOCK_PTR_FOR_FN (cfun))
305:     return make_edge (src, dst, flags);
306:
307:   /* Does the requested edge already exist?  */
308:   if (! bitmap_bit_p (edge_cache, dst->index))
309:     {
310:       /* The edge does not exist.  Create one and update the
311: 	 cache.  */
312:       bitmap_set_bit (edge_cache, dst->index);
313:       return unchecked_make_edge (src, dst, flags);
314:     }
315:
316:   /* At this point, we know that the requested edge exists.  Adjust
317:      flags if necessary.  */
318:   if (flags)
319:     {
320:       edge e = find_edge (src, dst);
321:       e->flags |= flags;
322:     }
323:
324:   return NULL;
325: }
326:
327: /* Create an edge connecting SRC and DEST with flags FLAGS.  Return newly
328:    created edge or NULL if already exist.  */
329:
330: edge
331: make_edge (basic_block src, basic_block dest, int flags)
332: {
333:   edge e = find_edge (src, dest);
334:
335:   /* Make sure we don't add duplicate edges.  */
336:   if (e)
337:     {
338:       e->flags |= flags;
339:       return NULL;
340:     }
341:
342:   return unchecked_make_edge (src, dest, flags);
```

## gcc/cfg.h:38–70
```text
38: struct GTY(()) control_flow_graph {
39:   /* Block pointers for the exit and entry of a function.
40:      These are always the head and tail of the basic block list.  */
41:   basic_block x_entry_block_ptr;
42:   basic_block x_exit_block_ptr;
43:
44:   /* Index by basic block number, get basic block struct info.  */
45:   vec<basic_block, va_gc> *x_basic_block_info;
46:
47:   /* Number of basic blocks in this flow graph.  */
48:   int x_n_basic_blocks;
49:
50:   /* Number of edges in this flow graph.  */
51:   int x_n_edges;
52:
53:   /* The first free basic block number.  */
54:   int x_last_basic_block;
55:
56:   /* UIDs for LABEL_DECLs.  */
57:   int last_label_uid;
58:
59:   /* Mapping of labels to their associated blocks.  At present
60:      only used for the gimple CFG.  */
61:   vec<basic_block, va_gc> *x_label_to_block_map;
62:
63:   enum profile_status_d x_profile_status;
64:
65:   /* Whether the dominators and the postdominators are available.  */
66:   enum dom_state x_dom_computed[2];
67:
68:   /* Number of basic blocks in the dominance tree.  */
69:   unsigned x_n_bbs_in_dom_tree[2];
70:
```

## gcc/input.cc:1045–1059
```text
1045: /* Associate the DISCRIMINATOR with LOCUS, and return a new locus. */
1046:
1047: location_t
1048: location_with_discriminator (location_t locus, int discriminator)
1049: {
1050:   tree block = LOCATION_BLOCK (locus);
1051:   source_range src_range = get_range_from_loc (line_table, locus);
1052:   locus = get_pure_location (locus);
1053:
1054:   if (locus == UNKNOWN_LOCATION)
1055:     return locus;
1056:
1057:   return line_table->get_or_create_combined_loc (locus, src_range, block,
1058: 						 discriminator);
1059: }
```

## libiberty/hashtab.c:134–195
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
181: 	low = mid + 1;
182:       else
183: 	high = mid;
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
194: }
195:
```

## libiberty/hashtab.c:282–324
```text
282: htab_create_alloc (size_t size, htab_hash hash_f, htab_eq eq_f,
283:                    htab_del del_f, htab_alloc alloc_f, htab_free free_f)
284: {
285:   return htab_create_typed_alloc (size, hash_f, eq_f, del_f, alloc_f, alloc_f,
286: 				  free_f);
287: }
288:
289: /* As above, but uses the variants of ALLOC_F and FREE_F which accept
290:    an extra argument.  */
291:
292: htab_t
293: htab_create_alloc_ex (size_t size, htab_hash hash_f, htab_eq eq_f,
294: 		      htab_del del_f, void *alloc_arg,
295: 		      htab_alloc_with_arg alloc_f,
296: 		      htab_free_with_arg free_f)
297: {
298:   htab_t result;
299:   unsigned int size_prime_index;
300:
301:   size_prime_index = higher_prime_index (size);
302:   size = prime_tab[size_prime_index].prime;
303:
304:   result = (htab_t) (*alloc_f) (alloc_arg, 1, sizeof (struct htab));
305:   if (result == NULL)
306:     return NULL;
307:   result->entries = (void **) (*alloc_f) (alloc_arg, size, sizeof (void *));
308:   if (result->entries == NULL)
309:     {
310:       if (free_f != NULL)
311: 	(*free_f) (alloc_arg, result);
312:       return NULL;
313:     }
314:   result->size = size;
315:   result->size_prime_index = size_prime_index;
316:   result->hash_f = hash_f;
317:   result->eq_f = eq_f;
318:   result->del_f = del_f;
319:   result->alloc_arg = alloc_arg;
320:   result->alloc_with_arg_f = alloc_f;
321:   result->free_with_arg_f = free_f;
322:   return result;
323: }
324:
```

## libiberty/hashtab.c:464–510
```text
464:      htab->size = nsize;
465:      htab->size_prime_index = nindex;
466:     }
467:   else
468:     memset (entries, 0, size * sizeof (void *));
469:   htab->n_deleted = 0;
470:   htab->n_elements = 0;
471: }
472:
473: /* Similar to htab_find_slot, but without several unwanted side effects:
474:     - Does not call htab->eq_f when it finds an existing entry.
475:     - Does not change the count of elements/searches/collisions in the
476:       hash table.
477:    This function also assumes there are no deleted entries in the table.
478:    HASH is the hash value for the element to be inserted.  */
479:
480: static void **
481: find_empty_slot_for_expand (htab_t htab, hashval_t hash)
482: {
483:   hashval_t index = htab_mod (hash, htab);
484:   size_t size = htab_size (htab);
485:   void **slot = htab->entries + index;
486:   hashval_t hash2;
487:
488:   if (*slot == HTAB_EMPTY_ENTRY)
489:     return slot;
490:   else if (*slot == HTAB_DELETED_ENTRY)
491:     abort ();
492:
493:   hash2 = htab_mod_m2 (hash, htab);
494:   for (;;)
495:     {
496:       index += hash2;
497:       if (index >= size)
498: 	index -= size;
499:
500:       slot = htab->entries + index;
501:       if (*slot == HTAB_EMPTY_ENTRY)
502: 	return slot;
503:       else if (*slot == HTAB_DELETED_ENTRY)
504: 	abort ();
505:     }
506: }
507:
508: /* The following function changes size of memory allocated for the
509:    entries and repeatedly inserts the table elements.  The occupancy
510:    of the table after the call will be about 50%.  Naturally the hash
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
547: 						    sizeof (void *));
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
564: 	{
565: 	  void **q = find_empty_slot_for_expand (htab, (*htab->hash_f) (x));
566:
567: 	  *q = x;
568: 	}
569:
570:       p++;
571:     }
572:   while (p < olimit);
573:
574:   if (htab->free_f != NULL)
575:     (*htab->free_f) (oentries);
```

## libiberty/hashtab.c:633–705
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
645: 	return NULL;
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
668: 	index -= size;
669:
670:       entry = htab->entries[index];
671:       if (entry == HTAB_EMPTY_ENTRY)
672: 	goto empty_entry;
673:       else if (entry == HTAB_DELETED_ENTRY)
674: 	{
675: 	  if (!first_deleted_slot)
676: 	    first_deleted_slot = &htab->entries[index];
677: 	}
678:       else if ((*htab->eq_f) (entry, element))
679: 	return &htab->entries[index];
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
696:
697: /* Like htab_find_slot_with_hash, but compute the hash value from the
698:    element.  */
699:
700: void **
701: htab_find_slot (htab_t htab, const void *element, enum insert_option insert)
702: {
703:   return htab_find_slot_with_hash (htab, element, (*htab->hash_f) (element),
704: 				   insert);
705: }
```

## libiberty/hashtab.c:780–792
```text
780:
781: /* Like htab_traverse_noresize, but does resize the table when it is
782:    too empty to improve effectivity of subsequent calls.  */
783:
784: void
785: htab_traverse (htab_t htab, htab_trav callback, void *info)
786: {
787:   size_t size = htab_size (htab);
788:   if (htab_elements (htab) * 8 < size && size > 32)
789:     htab_expand (htab);
790:
791:   htab_traverse_noresize (htab, callback, info);
792: }
```

## gcc/fold-const.cc:646–669
```text
646: fold_negate_expr_1 (location_t loc, tree t)
647: {
648:   tree type = TREE_TYPE (t);
649:   tree tem;
650:
651:   switch (TREE_CODE (t))
652:     {
653:     /* Convert - (~A) to A + 1.  */
654:     case BIT_NOT_EXPR:
655:       if (INTEGRAL_TYPE_P (type))
656:         return fold_build2_loc (loc, PLUS_EXPR, type, TREE_OPERAND (t, 0),
657: 				build_one_cst (type));
658:       break;
659:
660:     case INTEGER_CST:
661:       tem = fold_negate_const (t, type);
662:       if (TREE_OVERFLOW (tem) == TREE_OVERFLOW (t)
663: 	  || (ANY_INTEGRAL_TYPE_P (type)
664: 	      && !TYPE_OVERFLOW_TRAPS (type)
665: 	      && TYPE_OVERFLOW_WRAPS (type))
666: 	  || (flag_sanitize & SANITIZE_SI_OVERFLOW) == 0)
667: 	return tem;
668:       break;
669:
```

## gcc/fold-const.cc:844–853
```text
844: fold_negate_expr (location_t loc, tree t)
845: {
846:   tree type = TREE_TYPE (t);
847:   STRIP_SIGN_NOPS (t);
848:   tree tem = fold_negate_expr_1 (loc, t);
849:   if (tem == NULL_TREE)
850:     return NULL_TREE;
851:   return fold_convert_loc (loc, type, tem);
852: }
853:
```

## gcc/fold-const.cc:1087–1225
```text
1087:    evaluate CODE at compile-time.  */
1088:
1089: bool
1090: wide_int_binop (wide_int &res,
1091: 		enum tree_code code, const wide_int &arg1, const wide_int &arg2,
1092: 		signop sign, wi::overflow_type *overflow)
1093: {
1094:   wide_int tmp;
1095:   *overflow = wi::OVF_NONE;
1096:   switch (code)
1097:     {
1098:     case BIT_IOR_EXPR:
1099:       res = wi::bit_or (arg1, arg2);
1100:       break;
1101:
1102:     case BIT_XOR_EXPR:
1103:       res = wi::bit_xor (arg1, arg2);
1104:       break;
1105:
1106:     case BIT_AND_EXPR:
1107:       res = wi::bit_and (arg1, arg2);
1108:       break;
1109:
1110:     case LSHIFT_EXPR:
1111:       if (wi::neg_p (arg2))
1112: 	return false;
1113:       res = wi::lshift (arg1, arg2);
1114:       break;
1115:
1116:     case RSHIFT_EXPR:
1117:       if (wi::neg_p (arg2))
1118: 	return false;
1119:       /* It's unclear from the C standard whether shifts can overflow.
1120: 	 The following code ignores overflow; perhaps a C standard
1121: 	 interpretation ruling is needed.  */
1122:       res = wi::rshift (arg1, arg2, sign);
1123:       break;
1124:
1125:     case RROTATE_EXPR:
1126:     case LROTATE_EXPR:
1127:       if (wi::neg_p (arg2))
1128: 	{
1129: 	  tmp = -arg2;
1130: 	  if (code == RROTATE_EXPR)
1131: 	    code = LROTATE_EXPR;
1132: 	  else
1133: 	    code = RROTATE_EXPR;
1134: 	}
1135:       else
1136:         tmp = arg2;
1137:
1138:       if (code == RROTATE_EXPR)
1139: 	res = wi::rrotate (arg1, tmp);
1140:       else
1141: 	res = wi::lrotate (arg1, tmp);
1142:       break;
1143:
1144:     case PLUS_EXPR:
1145:       res = wi::add (arg1, arg2, sign, overflow);
1146:       break;
1147:
1148:     case MINUS_EXPR:
1149:       res = wi::sub (arg1, arg2, sign, overflow);
1150:       break;
1151:
1152:     case MULT_EXPR:
1153:       res = wi::mul (arg1, arg2, sign, overflow);
1154:       break;
1155:
1156:     case MULT_HIGHPART_EXPR:
1157:       res = wi::mul_high (arg1, arg2, sign);
1158:       break;
1159:
1160:     case TRUNC_DIV_EXPR:
1161:     case EXACT_DIV_EXPR:
1162:       if (arg2 == 0)
1163: 	return false;
1164:       res = wi::div_trunc (arg1, arg2, sign, overflow);
1165:       break;
1166:
1167:     case FLOOR_DIV_EXPR:
1168:       if (arg2 == 0)
1169: 	return false;
1170:       res = wi::div_floor (arg1, arg2, sign, overflow);
1171:       break;
1172:
1173:     case CEIL_DIV_EXPR:
1174:       if (arg2 == 0)
1175: 	return false;
1176:       res = wi::div_ceil (arg1, arg2, sign, overflow);
1177:       break;
1178:
1179:     case ROUND_DIV_EXPR:
1180:       if (arg2 == 0)
1181: 	return false;
1182:       res = wi::div_round (arg1, arg2, sign, overflow);
1183:       break;
1184:
1185:     case TRUNC_MOD_EXPR:
1186:       if (arg2 == 0)
1187: 	return false;
1188:       res = wi::mod_trunc (arg1, arg2, sign, overflow);
1189:       break;
1190:
1191:     case FLOOR_MOD_EXPR:
1192:       if (arg2 == 0)
1193: 	return false;
1194:       res = wi::mod_floor (arg1, arg2, sign, overflow);
1195:       break;
1196:
1197:     case CEIL_MOD_EXPR:
1198:       if (arg2 == 0)
1199: 	return false;
1200:       res = wi::mod_ceil (arg1, arg2, sign, overflow);
1201:       break;
1202:
1203:     case ROUND_MOD_EXPR:
1204:       if (arg2 == 0)
1205: 	return false;
1206:       res = wi::mod_round (arg1, arg2, sign, overflow);
1207:       break;
1208:
1209:     case MIN_EXPR:
1210:       res = wi::min (arg1, arg2, sign);
1211:       break;
1212:
1213:     case MAX_EXPR:
1214:       res = wi::max (arg1, arg2, sign);
1215:       break;
1216:
1217:     default:
1218:       return false;
1219:     }
1220:   return true;
1221: }
1222:
1223: /* Returns true if we know who is smaller or equal, ARG1 or ARG2, and set the
1224:    min value to RES.  */
1225: bool
```

## gcc/fold-const.cc:1325–1342
```text
1325: int_const_binop (enum tree_code code, const_tree arg1, const_tree arg2,
1326: 		 int overflowable)
1327: {
1328:   poly_wide_int poly_res;
1329:   tree type = TREE_TYPE (arg1);
1330:   signop sign = TYPE_SIGN (type);
1331:   wi::overflow_type overflow = wi::OVF_NONE;
1332:
1333:   if (!poly_int_tree_p (arg1)
1334:       || !poly_int_tree_p (arg2)
1335:       || !poly_int_binop (poly_res, code, arg1, arg2, sign, &overflow))
1336:     return NULL_TREE;
1337:   return force_fit_type (type, poly_res, overflowable,
1338: 			 (((sign == SIGNED || overflowable == -1)
1339: 			   && overflow)
1340: 			  | TREE_OVERFLOW (arg1) | TREE_OVERFLOW (arg2)));
1341: }
1342:
```

## gcc/fold-const.cc:1477–1498
```text
1477: const_binop (enum tree_code code, tree arg1, tree arg2)
1478: {
1479:   /* Sanity check for the recursive cases.  */
1480:   if (!arg1 || !arg2)
1481:     return NULL_TREE;
1482:
1483:   STRIP_NOPS (arg1);
1484:   STRIP_NOPS (arg2);
1485:
1486:   if (poly_int_tree_p (arg1) && poly_int_tree_p (arg2))
1487:     {
1488:       if (code == POINTER_PLUS_EXPR)
1489: 	return int_const_binop (PLUS_EXPR,
1490: 				arg1, fold_convert (TREE_TYPE (arg1), arg2));
1491:
1492:       return int_const_binop (code, arg1, arg2);
1493:     }
1494:
1495:   if (TREE_CODE (arg1) == REAL_CST && TREE_CODE (arg2) == REAL_CST)
1496:     {
1497:       machine_mode mode;
1498:       REAL_VALUE_TYPE d1;
```

## gcc/fold-const.cc:1920–2011
```text
1920: const_unop (enum tree_code code, tree type, tree arg0)
1921: {
1922:   /* Don't perform the operation, other than NEGATE and ABS, if
1923:      flag_signaling_nans is on and the operand is a signaling NaN.  */
1924:   if (TREE_CODE (arg0) == REAL_CST
1925:       && HONOR_SNANS (arg0)
1926:       && REAL_VALUE_ISSIGNALING_NAN (TREE_REAL_CST (arg0))
1927:       && code != NEGATE_EXPR
1928:       && code != ABS_EXPR
1929:       && code != ABSU_EXPR)
1930:     return NULL_TREE;
1931:
1932:   switch (code)
1933:     {
1934:     CASE_CONVERT:
1935:     case FLOAT_EXPR:
1936:     case FIX_TRUNC_EXPR:
1937:     case FIXED_CONVERT_EXPR:
1938:       return fold_convert_const (code, type, arg0);
1939:
1940:     case ADDR_SPACE_CONVERT_EXPR:
1941:       /* If the source address is 0, and the source address space
1942: 	 cannot have a valid object at 0, fold to dest type null.  */
1943:       if (integer_zerop (arg0)
1944: 	  && !(targetm.addr_space.zero_address_valid
1945: 	       (TYPE_ADDR_SPACE (TREE_TYPE (TREE_TYPE (arg0))))))
1946: 	return fold_convert_const (code, type, arg0);
1947:       break;
1948:
1949:     case VIEW_CONVERT_EXPR:
1950:       return fold_view_convert_expr (type, arg0);
1951:
1952:     case NEGATE_EXPR:
1953:       {
1954: 	/* Can't call fold_negate_const directly here as that doesn't
1955: 	   handle all cases and we might not be able to negate some
1956: 	   constants.  */
1957: 	tree tem = fold_negate_expr (UNKNOWN_LOCATION, arg0);
1958: 	if (tem && CONSTANT_CLASS_P (tem))
1959: 	  return tem;
1960: 	break;
1961:       }
1962:
1963:     case ABS_EXPR:
1964:     case ABSU_EXPR:
1965:       if (TREE_CODE (arg0) == INTEGER_CST || TREE_CODE (arg0) == REAL_CST)
1966: 	return fold_abs_const (arg0, type);
1967:       break;
1968:
1969:     case CONJ_EXPR:
1970:       if (TREE_CODE (arg0) == COMPLEX_CST)
1971: 	{
1972: 	  tree ipart = fold_negate_const (TREE_IMAGPART (arg0),
1973: 					  TREE_TYPE (type));
1974: 	  return build_complex (type, TREE_REALPART (arg0), ipart);
1975: 	}
1976:       break;
1977:
1978:     case BIT_NOT_EXPR:
1979:       if (TREE_CODE (arg0) == INTEGER_CST)
1980: 	return fold_not_const (arg0, type);
1981:       else if (POLY_INT_CST_P (arg0))
1982: 	return wide_int_to_tree (type, ~poly_int_cst_value (arg0));
1983:       /* Perform BIT_NOT_EXPR on each element individually.  */
1984:       else if (TREE_CODE (arg0) == VECTOR_CST)
1985: 	{
1986: 	  tree elem;
1987:
1988: 	  /* This can cope with stepped encodings because ~x == -1 - x.  */
1989: 	  tree_vector_builder elements;
1990: 	  elements.new_unary_operation (type, arg0, true);
1991: 	  unsigned int i, count = elements.encoded_nelts ();
1992: 	  for (i = 0; i < count; ++i)
1993: 	    {
1994: 	      elem = VECTOR_CST_ELT (arg0, i);
1995: 	      elem = const_unop (BIT_NOT_EXPR, TREE_TYPE (type), elem);
1996: 	      if (elem == NULL_TREE)
1997: 		break;
1998: 	      elements.quick_push (elem);
1999: 	    }
2000: 	  if (i == count)
2001: 	    return elements.build ();
2002: 	}
2003:       break;
2004:
2005:     case TRUTH_NOT_EXPR:
2006:       if (TREE_CODE (arg0) == INTEGER_CST)
2007: 	return constant_boolean_node (integer_zerop (arg0), type);
2008:       break;
2009:
2010:     case REALPART_EXPR:
2011:       if (TREE_CODE (arg0) == COMPLEX_CST)
```

## gcc/fold-const.cc:2092–2137
```text
2092: size_binop_loc (location_t loc, enum tree_code code, tree arg0, tree arg1)
2093: {
2094:   tree type = TREE_TYPE (arg0);
2095:
2096:   if (arg0 == error_mark_node || arg1 == error_mark_node)
2097:     return error_mark_node;
2098:
2099:   gcc_assert (int_binop_types_match_p (code, TREE_TYPE (arg0),
2100:                                        TREE_TYPE (arg1)));
2101:
2102:   /* Handle the special case of two poly_int constants faster.  */
2103:   if (poly_int_tree_p (arg0) && poly_int_tree_p (arg1))
2104:     {
2105:       /* And some specific cases even faster than that.  */
2106:       if (code == PLUS_EXPR)
2107: 	{
2108: 	  if (integer_zerop (arg0)
2109: 	      && !TREE_OVERFLOW (tree_strip_any_location_wrapper (arg0)))
2110: 	    return arg1;
2111: 	  if (integer_zerop (arg1)
2112: 	      && !TREE_OVERFLOW (tree_strip_any_location_wrapper (arg1)))
2113: 	    return arg0;
2114: 	}
2115:       else if (code == MINUS_EXPR)
2116: 	{
2117: 	  if (integer_zerop (arg1)
2118: 	      && !TREE_OVERFLOW (tree_strip_any_location_wrapper (arg1)))
2119: 	    return arg0;
2120: 	}
2121:       else if (code == MULT_EXPR)
2122: 	{
2123: 	  if (integer_onep (arg0)
2124: 	      && !TREE_OVERFLOW (tree_strip_any_location_wrapper (arg0)))
2125: 	    return arg1;
2126: 	}
2127:
2128:       /* Handle general case of two integer constants.  For sizetype
2129:          constant calculations we always want to know about overflow,
2130: 	 even in the unsigned case.  */
2131:       tree res = int_const_binop (code, arg0, arg1, -1);
2132:       if (res != NULL_TREE)
2133: 	return res;
2134:     }
2135:
2136:   return fold_build2_loc (loc, code, type, arg0, arg1);
2137: }
```

## gcc/fold-const.cc:2192–2203
```text
2192: int_const_convert (tree type, const_tree arg1, int overflowable)
2193: {
2194:   /* Given an integer constant, make new constant with new type,
2195:      appropriately sign-extended or truncated.  Use widest_int
2196:      so that any extension is done according ARG1's type.  */
2197:   tree arg1_type = TREE_TYPE (arg1);
2198:   unsigned prec = MAX (TYPE_PRECISION (arg1_type), TYPE_PRECISION (type));
2199:   return force_fit_type (type, wide_int::from (wi::to_wide (arg1), prec,
2200: 					       TYPE_SIGN (arg1_type)),
2201: 			 overflowable,
2202: 			 TREE_OVERFLOW (arg1));
2203: }
```

## gcc/fold-const.cc:2484–2504
```text
2484: fold_convert_const (enum tree_code code, tree type, tree arg1)
2485: {
2486:   tree arg_type = TREE_TYPE (arg1);
2487:   if (arg_type == type)
2488:     return arg1;
2489:
2490:   /* We can't widen types, since the runtime value could overflow the
2491:      original type before being extended to the new type.  */
2492:   if (POLY_INT_CST_P (arg1)
2493:       && (POINTER_TYPE_P (type) || INTEGRAL_TYPE_P (type))
2494:       && TYPE_PRECISION (type) <= TYPE_PRECISION (arg_type))
2495:     return build_poly_int_cst (type,
2496: 			       poly_wide_int::from (poly_int_cst_value (arg1),
2497: 						    TYPE_PRECISION (type),
2498: 						    TYPE_SIGN (arg_type)));
2499:
2500:   if (POINTER_TYPE_P (type) || INTEGRAL_TYPE_P (type)
2501:       || TREE_CODE (type) == OFFSET_TYPE)
2502:     {
2503:       if (TREE_CODE (arg1) == INTEGER_CST)
2504: 	return int_const_convert (type, arg1, !POINTER_TYPE_P (arg_type));
```

## gcc/fold-const.cc:2626–2666
```text
2626:     }
2627: }
2628:
2629: /* Convert expression ARG to type TYPE.  Used by the middle-end for
2630:    simple conversions in preference to calling the front-end's convert.  */
2631:
2632: tree
2633: fold_convert_loc (location_t loc, tree type, tree arg)
2634: {
2635:   tree orig = TREE_TYPE (arg);
2636:   tree tem;
2637:
2638:   if (type == orig)
2639:     return arg;
2640:
2641:   if (TREE_CODE (arg) == ERROR_MARK
2642:       || TREE_CODE (type) == ERROR_MARK
2643:       || TREE_CODE (orig) == ERROR_MARK)
2644:     return error_mark_node;
2645:
2646:   switch (TREE_CODE (type))
2647:     {
2648:     case POINTER_TYPE:
2649:     case REFERENCE_TYPE:
2650:       /* Handle conversions between pointers to different address spaces.  */
2651:       if (POINTER_TYPE_P (orig)
2652: 	  && (TYPE_ADDR_SPACE (TREE_TYPE (type))
2653: 	      != TYPE_ADDR_SPACE (TREE_TYPE (orig))))
2654: 	return fold_build1_loc (loc, ADDR_SPACE_CONVERT_EXPR, type, arg);
2655:       /* fall through */
2656:
2657:     case INTEGER_TYPE: case ENUMERAL_TYPE: case BOOLEAN_TYPE:
2658:     case OFFSET_TYPE: case BITINT_TYPE:
2659:       if (TREE_CODE (arg) == INTEGER_CST)
2660: 	{
2661: 	  tem = fold_convert_const (NOP_EXPR, type, arg);
2662: 	  if (tem != NULL_TREE)
2663: 	    return tem;
2664: 	}
2665:       if (INTEGRAL_TYPE_P (orig) || POINTER_TYPE_P (orig)
2666: 	  || TREE_CODE (orig) == OFFSET_TYPE)
```

## gcc/fold-const.cc:6994–7007
```text
6994: constant_boolean_node (bool value, tree type)
6995: {
6996:   if (type == integer_type_node)
6997:     return value ? integer_one_node : integer_zero_node;
6998:   else if (type == boolean_type_node)
6999:     return value ? boolean_true_node : boolean_false_node;
7000:   else if (VECTOR_TYPE_P (type))
7001:     return build_vector_from_val (type,
7002: 				  build_int_cst (TREE_TYPE (type),
7003: 						 value ? -1 : 0));
7004:   else
7005:     return fold_convert (type, value ? integer_one_node : integer_zero_node);
7006: }
7007:
```

## gcc/fold-const.cc:9205–9254
```text
9205: {
9206:   tree tem;
9207:   tree arg0;
9208:   enum tree_code_class kind = TREE_CODE_CLASS (code);
9209:
9210:   gcc_assert (IS_EXPR_CODE_CLASS (kind)
9211: 	      && TREE_CODE_LENGTH (code) == 1);
9212:
9213:   arg0 = op0;
9214:   if (arg0)
9215:     {
9216:       if (CONVERT_EXPR_CODE_P (code)
9217: 	  || code == FLOAT_EXPR || code == ABS_EXPR || code == NEGATE_EXPR)
9218: 	{
9219: 	  /* Don't use STRIP_NOPS, because signedness of argument type
9220: 	     matters.  */
9221: 	  STRIP_SIGN_NOPS (arg0);
9222: 	}
9223:       else
9224: 	{
9225: 	  /* Strip any conversions that don't change the mode.  This
9226: 	     is safe for every expression, except for a comparison
9227: 	     expression because its signedness is derived from its
9228: 	     operands.
9229:
9230: 	     Note that this is done as an internal manipulation within
9231: 	     the constant folder, in order to find the simplest
9232: 	     representation of the arguments so that their form can be
9233: 	     studied.  In any cases, the appropriate type conversions
9234: 	     should be put back in the tree that will get out of the
9235: 	     constant folder.  */
9236: 	  STRIP_NOPS (arg0);
9237: 	}
9238:
9239:       if (CONSTANT_CLASS_P (arg0))
9240: 	{
9241: 	  tree tem = const_unop (code, type, arg0);
9242: 	  if (tem)
9243: 	    {
9244: 	      if (TREE_TYPE (tem) != type)
9245: 		tem = fold_convert_loc (loc, type, tem);
9246: 	      return tem;
9247: 	    }
9248: 	}
9249:     }
9250:
9251:   tem = generic_simplify (loc, code, type, op0);
9252:   if (tem)
9253:     return tem;
9254:
```

## gcc/fold-const.cc:10986–11056
```text
10986: fold_binary_loc (location_t loc, enum tree_code code, tree type,
10987: 		 tree op0, tree op1)
10988: {
10989:   enum tree_code_class kind = TREE_CODE_CLASS (code);
10990:   tree arg0, arg1, tem;
10991:   tree t1 = NULL_TREE;
10992:   bool strict_overflow_p;
10993:   unsigned int prec;
10994:
10995:   gcc_assert (IS_EXPR_CODE_CLASS (kind)
10996: 	      && TREE_CODE_LENGTH (code) == 2
10997: 	      && op0 != NULL_TREE
10998: 	      && op1 != NULL_TREE);
10999:
11000:   arg0 = op0;
11001:   arg1 = op1;
11002:
11003:   /* Strip any conversions that don't change the mode.  This is
11004:      safe for every expression, except for a comparison expression
11005:      because its signedness is derived from its operands.  So, in
11006:      the latter case, only strip conversions that don't change the
11007:      signedness.  MIN_EXPR/MAX_EXPR also need signedness of arguments
11008:      preserved.
11009:
11010:      Note that this is done as an internal manipulation within the
11011:      constant folder, in order to find the simplest representation
11012:      of the arguments so that their form can be studied.  In any
11013:      cases, the appropriate type conversions should be put back in
11014:      the tree that will get out of the constant folder.  */
11015:
11016:   if (kind == tcc_comparison || code == MIN_EXPR || code == MAX_EXPR)
11017:     {
11018:       STRIP_SIGN_NOPS (arg0);
11019:       STRIP_SIGN_NOPS (arg1);
11020:     }
11021:   else
11022:     {
11023:       STRIP_NOPS (arg0);
11024:       STRIP_NOPS (arg1);
11025:     }
11026:
11027:   /* Note that TREE_CONSTANT isn't enough: static var addresses are
11028:      constant but we can't do arithmetic on them.  */
11029:   if (CONSTANT_CLASS_P (arg0) && CONSTANT_CLASS_P (arg1))
11030:     {
11031:       tem = const_binop (code, type, arg0, arg1);
11032:       if (tem != NULL_TREE)
11033: 	{
11034: 	  if (TREE_TYPE (tem) != type)
11035: 	    tem = fold_convert_loc (loc, type, tem);
11036: 	  return tem;
11037: 	}
11038:     }
11039:
11040:   /* If this is a commutative operation, and ARG0 is a constant, move it
11041:      to ARG1 to reduce the number of tests below.  */
11042:   if (commutative_tree_code (code)
11043:       && tree_swap_operands_p (arg0, arg1))
11044:     return fold_build2_loc (loc, code, type, op1, op0);
11045:
11046:   /* Likewise if this is a comparison, and ARG0 is a constant, move it
11047:      to ARG1 to reduce the number of tests below.  */
11048:   if (kind == tcc_comparison
11049:       && tree_swap_operands_p (arg0, arg1))
11050:     return fold_build2_loc (loc, swap_tree_comparison (code), type, op1, op0);
11051:
11052:   tem = generic_simplify (loc, code, type, op0, op1);
11053:   if (tem)
11054:     return tem;
11055:
11056:   /* ARG0 is the first operand of EXPR, and ARG1 is the second operand.
```

## gcc/fold-const.cc:13886–14015
```text
13886: fold_build1_loc (location_t loc,
13887: 		 enum tree_code code, tree type, tree op0 MEM_STAT_DECL)
13888: {
13889:   tree tem;
13890: #ifdef ENABLE_FOLD_CHECKING
13891:   unsigned char checksum_before[16], checksum_after[16];
13892:   struct md5_ctx ctx;
13893:   hash_table<nofree_ptr_hash<const tree_node> > ht (32);
13894:
13895:   md5_init_ctx (&ctx);
13896:   fold_checksum_tree (op0, &ctx, &ht);
13897:   md5_finish_ctx (&ctx, checksum_before);
13898:   ht.empty ();
13899: #endif
13900:
13901:   tem = fold_unary_loc (loc, code, type, op0);
13902:   if (!tem)
13903:     tem = build1_loc (loc, code, type, op0 PASS_MEM_STAT);
13904:
13905: #ifdef ENABLE_FOLD_CHECKING
13906:   md5_init_ctx (&ctx);
13907:   fold_checksum_tree (op0, &ctx, &ht);
13908:   md5_finish_ctx (&ctx, checksum_after);
13909:
13910:   if (memcmp (checksum_before, checksum_after, 16))
13911:     fold_check_failed (op0, tem);
13912: #endif
13913:   return tem;
13914: }
13915:
13916: /* Fold a binary tree expression with code CODE of type TYPE with
13917:    operands OP0 and OP1.  LOC is the location of the resulting
13918:    expression.  Return a folded expression if successful.  Otherwise,
13919:    return a tree expression with code CODE of type TYPE with operands
13920:    OP0 and OP1.  */
13921:
13922: tree
13923: fold_build2_loc (location_t loc,
13924: 		      enum tree_code code, tree type, tree op0, tree op1
13925: 		      MEM_STAT_DECL)
13926: {
13927:   tree tem;
13928: #ifdef ENABLE_FOLD_CHECKING
13929:   unsigned char checksum_before_op0[16],
13930:                 checksum_before_op1[16],
13931: 		checksum_after_op0[16],
13932: 		checksum_after_op1[16];
13933:   struct md5_ctx ctx;
13934:   hash_table<nofree_ptr_hash<const tree_node> > ht (32);
13935:
13936:   md5_init_ctx (&ctx);
13937:   fold_checksum_tree (op0, &ctx, &ht);
13938:   md5_finish_ctx (&ctx, checksum_before_op0);
13939:   ht.empty ();
13940:
13941:   md5_init_ctx (&ctx);
13942:   fold_checksum_tree (op1, &ctx, &ht);
13943:   md5_finish_ctx (&ctx, checksum_before_op1);
13944:   ht.empty ();
13945: #endif
13946:
13947:   tem = fold_binary_loc (loc, code, type, op0, op1);
13948:   if (!tem)
13949:     tem = build2_loc (loc, code, type, op0, op1 PASS_MEM_STAT);
13950:
13951: #ifdef ENABLE_FOLD_CHECKING
13952:   md5_init_ctx (&ctx);
13953:   fold_checksum_tree (op0, &ctx, &ht);
13954:   md5_finish_ctx (&ctx, checksum_after_op0);
13955:   ht.empty ();
13956:
13957:   if (memcmp (checksum_before_op0, checksum_after_op0, 16))
13958:     fold_check_failed (op0, tem);
13959:
13960:   md5_init_ctx (&ctx);
13961:   fold_checksum_tree (op1, &ctx, &ht);
13962:   md5_finish_ctx (&ctx, checksum_after_op1);
13963:
13964:   if (memcmp (checksum_before_op1, checksum_after_op1, 16))
13965:     fold_check_failed (op1, tem);
13966: #endif
13967:   return tem;
13968: }
13969:
13970: /* Fold a ternary tree expression with code CODE of type TYPE with
13971:    operands OP0, OP1, and OP2.  Return a folded expression if
13972:    successful.  Otherwise, return a tree expression with code CODE of
13973:    type TYPE with operands OP0, OP1, and OP2.  */
13974:
13975: tree
13976: fold_build3_loc (location_t loc, enum tree_code code, tree type,
13977: 		      tree op0, tree op1, tree op2 MEM_STAT_DECL)
13978: {
13979:   tree tem;
13980: #ifdef ENABLE_FOLD_CHECKING
13981:   unsigned char checksum_before_op0[16],
13982:                 checksum_before_op1[16],
13983:                 checksum_before_op2[16],
13984: 		checksum_after_op0[16],
13985: 		checksum_after_op1[16],
13986: 		checksum_after_op2[16];
13987:   struct md5_ctx ctx;
13988:   hash_table<nofree_ptr_hash<const tree_node> > ht (32);
13989:
13990:   md5_init_ctx (&ctx);
13991:   fold_checksum_tree (op0, &ctx, &ht);
13992:   md5_finish_ctx (&ctx, checksum_before_op0);
13993:   ht.empty ();
13994:
13995:   md5_init_ctx (&ctx);
13996:   fold_checksum_tree (op1, &ctx, &ht);
13997:   md5_finish_ctx (&ctx, checksum_before_op1);
13998:   ht.empty ();
13999:
14000:   md5_init_ctx (&ctx);
14001:   fold_checksum_tree (op2, &ctx, &ht);
14002:   md5_finish_ctx (&ctx, checksum_before_op2);
14003:   ht.empty ();
14004: #endif
14005:
14006:   gcc_assert (TREE_CODE_CLASS (code) != tcc_vl_exp);
14007:   tem = fold_ternary_loc (loc, code, type, op0, op1, op2);
14008:   if (!tem)
14009:     tem = build3_loc (loc, code, type, op0, op1, op2 PASS_MEM_STAT);
14010:
14011: #ifdef ENABLE_FOLD_CHECKING
14012:   md5_init_ctx (&ctx);
14013:   fold_checksum_tree (op0, &ctx, &ht);
14014:   md5_finish_ctx (&ctx, checksum_after_op0);
14015:   ht.empty ();
```

## gcc/fold-const.cc:15842–15938
```text
15842: fold_negate_const (tree arg0, tree type)
15843: {
15844:   tree t = NULL_TREE;
15845:
15846:   switch (TREE_CODE (arg0))
15847:     {
15848:     case REAL_CST:
15849:       t = build_real (type, real_value_negate (&TREE_REAL_CST (arg0)));
15850:       break;
15851:
15852:     case FIXED_CST:
15853:       {
15854:         FIXED_VALUE_TYPE f;
15855:         bool overflow_p = fixed_arithmetic (&f, NEGATE_EXPR,
15856: 					    &(TREE_FIXED_CST (arg0)), NULL,
15857: 					    TYPE_SATURATING (type));
15858: 	t = build_fixed (type, f);
15859: 	/* Propagate overflow flags.  */
15860: 	if (overflow_p | TREE_OVERFLOW (arg0))
15861: 	  TREE_OVERFLOW (t) = 1;
15862: 	break;
15863:       }
15864:
15865:     default:
15866:       if (poly_int_tree_p (arg0))
15867: 	{
15868: 	  wi::overflow_type overflow;
15869: 	  poly_wide_int res = wi::neg (wi::to_poly_wide (arg0), &overflow);
15870: 	  t = force_fit_type (type, res, 1,
15871: 			      (overflow && ! TYPE_UNSIGNED (type))
15872: 			      || TREE_OVERFLOW (arg0));
15873: 	  break;
15874: 	}
15875:
15876:       gcc_unreachable ();
15877:     }
15878:
15879:   return t;
15880: }
15881:
15882: /* Return the tree for abs (ARG0) when ARG0 is known to be either
15883:    an integer constant or real constant.
15884:
15885:    TYPE is the type of the result.  */
15886:
15887: tree
15888: fold_abs_const (tree arg0, tree type)
15889: {
15890:   tree t = NULL_TREE;
15891:
15892:   switch (TREE_CODE (arg0))
15893:     {
15894:     case INTEGER_CST:
15895:       {
15896:         /* If the value is unsigned or non-negative, then the absolute value
15897: 	   is the same as the ordinary value.  */
15898: 	wide_int val = wi::to_wide (arg0);
15899: 	wi::overflow_type overflow = wi::OVF_NONE;
15900: 	if (!wi::neg_p (val, TYPE_SIGN (TREE_TYPE (arg0))))
15901: 	  ;
15902:
15903: 	/* If the value is negative, then the absolute value is
15904: 	   its negation.  */
15905: 	else
15906: 	  val = wi::neg (val, &overflow);
15907:
15908: 	/* Force to the destination type, set TREE_OVERFLOW for signed
15909: 	   TYPE only.  */
15910: 	t = force_fit_type (type, val, 1, overflow | TREE_OVERFLOW (arg0));
15911:       }
15912:     break;
15913:
15914:     case REAL_CST:
15915:       if (REAL_VALUE_NEGATIVE (TREE_REAL_CST (arg0)))
15916: 	t = build_real (type, real_value_negate (&TREE_REAL_CST (arg0)));
15917:       else
15918: 	t =  arg0;
15919:       break;
15920:
15921:     default:
15922:       gcc_unreachable ();
15923:     }
15924:
15925:   return t;
15926: }
15927:
15928: /* Return the tree for not (ARG0) when ARG0 is known to be an integer
15929:    constant.  TYPE is the type of the result.  */
15930:
15931: static tree
15932: fold_not_const (const_tree arg0, tree type)
15933: {
15934:   gcc_assert (TREE_CODE (arg0) == INTEGER_CST);
15935:
15936:   return force_fit_type (type, ~wi::to_wide (arg0), 0, TREE_OVERFLOW (arg0));
15937: }
15938:
```

## gcc/fold-const.cc:15945–16110
```text
15945: fold_relational_const (enum tree_code code, tree type, tree op0, tree op1)
15946: {
15947:   int result, invert;
15948:
15949:   /* From here on, the only cases we handle are when the result is
15950:      known to be a constant.  */
15951:
15952:   if (TREE_CODE (op0) == REAL_CST && TREE_CODE (op1) == REAL_CST)
15953:     {
15954:       const REAL_VALUE_TYPE *c0 = TREE_REAL_CST_PTR (op0);
15955:       const REAL_VALUE_TYPE *c1 = TREE_REAL_CST_PTR (op1);
15956:
15957:       /* Handle the cases where either operand is a NaN.  */
15958:       if (real_isnan (c0) || real_isnan (c1))
15959: 	{
15960: 	  switch (code)
15961: 	    {
15962: 	    case EQ_EXPR:
15963: 	    case ORDERED_EXPR:
15964: 	      result = 0;
15965: 	      break;
15966:
15967: 	    case NE_EXPR:
15968: 	    case UNORDERED_EXPR:
15969: 	    case UNLT_EXPR:
15970: 	    case UNLE_EXPR:
15971: 	    case UNGT_EXPR:
15972: 	    case UNGE_EXPR:
15973: 	    case UNEQ_EXPR:
15974:               result = 1;
15975: 	      break;
15976:
15977: 	    case LT_EXPR:
15978: 	    case LE_EXPR:
15979: 	    case GT_EXPR:
15980: 	    case GE_EXPR:
15981: 	    case LTGT_EXPR:
15982: 	      if (flag_trapping_math)
15983: 		return NULL_TREE;
15984: 	      result = 0;
15985: 	      break;
15986:
15987: 	    default:
15988: 	      gcc_unreachable ();
15989: 	    }
15990:
15991: 	  return constant_boolean_node (result, type);
15992: 	}
15993:
15994:       return constant_boolean_node (real_compare (code, c0, c1), type);
15995:     }
15996:
15997:   if (TREE_CODE (op0) == FIXED_CST && TREE_CODE (op1) == FIXED_CST)
15998:     {
15999:       const FIXED_VALUE_TYPE *c0 = TREE_FIXED_CST_PTR (op0);
16000:       const FIXED_VALUE_TYPE *c1 = TREE_FIXED_CST_PTR (op1);
16001:       return constant_boolean_node (fixed_compare (code, c0, c1), type);
16002:     }
16003:
16004:   /* Handle equality/inequality of complex constants.  */
16005:   if (TREE_CODE (op0) == COMPLEX_CST && TREE_CODE (op1) == COMPLEX_CST)
16006:     {
16007:       tree rcond = fold_relational_const (code, type,
16008: 					  TREE_REALPART (op0),
16009: 					  TREE_REALPART (op1));
16010:       tree icond = fold_relational_const (code, type,
16011: 					  TREE_IMAGPART (op0),
16012: 					  TREE_IMAGPART (op1));
16013:       if (code == EQ_EXPR)
16014: 	return fold_build2 (TRUTH_ANDIF_EXPR, type, rcond, icond);
16015:       else if (code == NE_EXPR)
16016: 	return fold_build2 (TRUTH_ORIF_EXPR, type, rcond, icond);
16017:       else
16018: 	return NULL_TREE;
16019:     }
16020:
16021:   if (TREE_CODE (op0) == VECTOR_CST && TREE_CODE (op1) == VECTOR_CST)
16022:     {
16023:       if (!VECTOR_TYPE_P (type))
16024: 	{
16025: 	  /* Have vector comparison with scalar boolean result.  */
16026: 	  gcc_assert ((code == EQ_EXPR || code == NE_EXPR)
16027: 		      && known_eq (VECTOR_CST_NELTS (op0),
16028: 				   VECTOR_CST_NELTS (op1)));
16029: 	  unsigned HOST_WIDE_INT nunits;
16030: 	  if (!VECTOR_CST_NELTS (op0).is_constant (&nunits))
16031: 	    return NULL_TREE;
16032: 	  for (unsigned i = 0; i < nunits; i++)
16033: 	    {
16034: 	      tree elem0 = VECTOR_CST_ELT (op0, i);
16035: 	      tree elem1 = VECTOR_CST_ELT (op1, i);
16036: 	      tree tmp = fold_relational_const (EQ_EXPR, type, elem0, elem1);
16037: 	      if (tmp == NULL_TREE)
16038: 		return NULL_TREE;
16039: 	      if (integer_zerop (tmp))
16040: 		return constant_boolean_node (code == NE_EXPR, type);
16041: 	    }
16042: 	  return constant_boolean_node (code == EQ_EXPR, type);
16043: 	}
16044:       tree_vector_builder elts;
16045:       if (!elts.new_binary_operation (type, op0, op1, false))
16046: 	return NULL_TREE;
16047:       unsigned int count = elts.encoded_nelts ();
16048:       for (unsigned i = 0; i < count; i++)
16049: 	{
16050: 	  tree elem_type = TREE_TYPE (type);
16051: 	  tree elem0 = VECTOR_CST_ELT (op0, i);
16052: 	  tree elem1 = VECTOR_CST_ELT (op1, i);
16053:
16054: 	  tree tem = fold_relational_const (code, elem_type,
16055: 					    elem0, elem1);
16056:
16057: 	  if (tem == NULL_TREE)
16058: 	    return NULL_TREE;
16059:
16060: 	  elts.quick_push (build_int_cst (elem_type,
16061: 					  integer_zerop (tem) ? 0 : -1));
16062: 	}
16063:
16064:       return elts.build ();
16065:     }
16066:
16067:   /* From here on we only handle LT, LE, GT, GE, EQ and NE.
16068:
16069:      To compute GT, swap the arguments and do LT.
16070:      To compute GE, do LT and invert the result.
16071:      To compute LE, swap the arguments, do LT and invert the result.
16072:      To compute NE, do EQ and invert the result.
16073:
16074:      Therefore, the code below must handle only EQ and LT.  */
16075:
16076:   if (code == LE_EXPR || code == GT_EXPR)
16077:     {
16078:       std::swap (op0, op1);
16079:       code = swap_tree_comparison (code);
16080:     }
16081:
16082:   /* Note that it is safe to invert for real values here because we
16083:      have already handled the one case that it matters.  */
16084:
16085:   invert = 0;
16086:   if (code == NE_EXPR || code == GE_EXPR)
16087:     {
16088:       invert = 1;
16089:       code = invert_tree_comparison (code, false);
16090:     }
16091:
16092:   /* Compute a result for LT or EQ if args permit;
16093:      Otherwise return T.  */
16094:   if (TREE_CODE (op0) == INTEGER_CST && TREE_CODE (op1) == INTEGER_CST)
16095:     {
16096:       if (code == EQ_EXPR)
16097: 	result = tree_int_cst_equal (op0, op1);
16098:       else
16099: 	result = tree_int_cst_lt (op0, op1);
16100:     }
16101:   else
16102:     return NULL_TREE;
16103:
16104:   if (invert)
16105:     result ^= 1;
16106:   return constant_boolean_node (result, type);
16107: }
16108:
16109: /* If necessary, return a CLEANUP_POINT_EXPR for EXPR with the
16110:    indicated TYPE.  If no CLEANUP_POINT_EXPR is necessary, return EXPR
```

## gcc/fold-const.cc:16378–16435
```text
16378: round_up_loc (location_t loc, tree value, unsigned int divisor)
16379: {
16380:   tree div = NULL_TREE;
16381:
16382:   if (divisor == 1)
16383:     return value;
16384:
16385:   /* See if VALUE is already a multiple of DIVISOR.  If so, we don't
16386:      have to do anything.  Only do this when we are not given a const,
16387:      because in that case, this check is more expensive than just
16388:      doing it.  */
16389:   if (TREE_CODE (value) != INTEGER_CST)
16390:     {
16391:       div = build_int_cst (TREE_TYPE (value), divisor);
16392:
16393:       if (multiple_of_p (TREE_TYPE (value), value, div))
16394: 	return value;
16395:     }
16396:
16397:   /* If divisor is a power of two, simplify this to bit manipulation.  */
16398:   if (pow2_or_zerop (divisor))
16399:     {
16400:       if (TREE_CODE (value) == INTEGER_CST)
16401: 	{
16402: 	  wide_int val = wi::to_wide (value);
16403: 	  bool overflow_p;
16404:
16405: 	  if ((val & (divisor - 1)) == 0)
16406: 	    return value;
16407:
16408: 	  overflow_p = TREE_OVERFLOW (value);
16409: 	  val += divisor - 1;
16410: 	  val &= (int) -divisor;
16411: 	  if (val == 0)
16412: 	    overflow_p = true;
16413:
16414: 	  return force_fit_type (TREE_TYPE (value), val, -1, overflow_p);
16415: 	}
16416:       else
16417: 	{
16418: 	  tree t;
16419:
16420: 	  t = build_int_cst (TREE_TYPE (value), divisor - 1);
16421: 	  value = size_binop_loc (loc, PLUS_EXPR, value, t);
16422: 	  t = build_int_cst (TREE_TYPE (value), - (int) divisor);
16423: 	  value = size_binop_loc (loc, BIT_AND_EXPR, value, t);
16424: 	}
16425:     }
16426:   else
16427:     {
16428:       if (!div)
16429: 	div = build_int_cst (TREE_TYPE (value), divisor);
16430:       value = size_binop_loc (loc, CEIL_DIV_EXPR, value, div);
16431:       value = size_binop_loc (loc, MULT_EXPR, value, div);
16432:     }
16433:
16434:   return value;
16435: }
```

## gcc/genmatch.cc:3259–3268
```text
3259: 		     int depth, const char *in_type, capture_info *cinfo,
3260: 		     dt_operand **indexes, int, const char *in_place)
3261: {
3262:   id_base *opr = operation;
3263:   /* When we delay operator substituting during lowering of fors we
3264:      make sure that for code-gen purposes the effects of each substitute
3265:      are the same.  Thus just look at that.  */
3266:   if (user_id *uid = dyn_cast <user_id *> (opr))
3267:     opr = uid->substitutes[0];
3268:
```

## gcc/genmatch.cc:3331–3348
```text
3331:     }
3332:   else
3333:     fprintf_indent (f, indent,
3334: 		    "tree _o%d[%u], _r%d;\n", depth, ops.length (), depth);
3335:   char op0type[64];
3336:   snprintf (op0type, sizeof (op0type), "TREE_TYPE (_o%d[0])", depth);
3337:   for (unsigned i = 0; i < ops.length (); ++i)
3338:     {
3339:       char dest1[32];
3340:       snprintf (dest1, sizeof (dest1), "_o%d[%u]", depth, i);
3341:       const char *optype1
3342: 	= get_operand_type (opr, i, in_type, expr_type,
3343: 			    i == 0 ? NULL : op0type);
3344:       ops[i]->gen_transform (f, indent, dest1, gimple, depth + 1, optype1,
3345: 			     cinfo, indexes,
3346: 			     *opr == COND_EXPR && i == 0 ? 1 : 2,
3347: 			     child_in_place ? "tem_op" : NULL);
3348:     }
```

## gcc/genmatch.cc:3445–3485
```text
3445:     {
3446:       if (possible_noop_convert (opr))
3447: 	{
3448: 	  fprintf_indent (f, indent, "if (TREE_TYPE (_o%d[0]) != %s)\n",
3449: 			  depth, type);
3450: 	  fprintf_indent (f, indent + 2, "{\n");
3451: 	  indent += 4;
3452: 	}
3453:       if (opr->kind == id_base::CODE)
3454: 	fprintf_indent (f, indent, "_r%d = fold_build%d_loc (loc, %s, %s",
3455: 			depth, ops.length(), opr_name, type);
3456:       else
3457: 	fprintf_indent (f, indent, "_r%d = maybe_build_call_expr_loc (loc, "
3458: 			"%s, %s, %d", depth, opr_name, type, ops.length());
3459:       for (unsigned i = 0; i < ops.length (); ++i)
3460: 	fprintf (f, ", _o%d[%u]", depth, i);
3461:       fprintf (f, ");\n");
3462:       if (opr->kind != id_base::CODE)
3463: 	{
3464: 	  fprintf_indent (f, indent, "if (!_r%d)\n", depth);
3465: 	  fprintf_indent (f, indent, "  goto %s;\n", fail_label);
3466: 	}
3467:       if (force_leaf)
3468: 	{
3469: 	  fprintf_indent (f, indent, "if (EXPR_P (_r%d))\n", depth);
3470: 	  fprintf_indent (f, indent, "  goto %s;\n", fail_label);
3471: 	}
3472:       if (possible_noop_convert (opr))
3473: 	{
3474: 	  fprintf_indent (f, indent - 2, "}\n");
3475: 	  indent -= 4;
3476: 	  fprintf_indent (f, indent, "else\n");
3477: 	  fprintf_indent (f, indent, "  _r%d = _o%d[0];\n", depth, depth);
3478: 	}
3479:     }
3480:   fprintf_indent (f, indent, "%s = _r%d;\n", dest, depth);
3481:   indent -= 2;
3482:   fprintf_indent (f, indent, "}\n");
3483: }
3484:
3485: /* Generate code for a c_expr which is either the expression inside
```

## gcc/params.opt:248–250
```text
248: -param=integer-share-limit=
249: Common Joined UInteger Var(param_integer_share_limit) Init(251) IntegerRange(2, 65536) Param
250: The upper bound for sharing integer constants.
```

## gcc/match.pd:1–41
```text
1: /* Match-and-simplify patterns for shared GENERIC and GIMPLE folding.
2:    This file is consumed by genmatch which produces gimple-match.cc
3:    and generic-match.cc from it.
4:
5:    Copyright (C) 2014-2026 Free Software Foundation, Inc.
6:    Contributed by Richard Biener <rguenther@suse.de>
7:    and Prathamesh Kulkarni  <bilbotheelffriend@gmail.com>
8:
9: This file is part of GCC.
10:
11: GCC is free software; you can redistribute it and/or modify it under
12: the terms of the GNU General Public License as published by the Free
13: Software Foundation; either version 3, or (at your option) any later
14: version.
15:
16: GCC is distributed in the hope that it will be useful, but WITHOUT ANY
17: WARRANTY; without even the implied warranty of MERCHANTABILITY or
18: FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
19: for more details.
20:
21: You should have received a copy of the GNU General Public License
22: along with GCC; see the file COPYING3.  If not see
23: <http://www.gnu.org/licenses/>.  */
24:
25:
26: /* Generic tree predicates we inherit.  */
27: (define_predicates
28:    integer_onep integer_zerop integer_all_onesp integer_minus_onep
29:    integer_each_onep integer_truep integer_nonzerop
30:    real_zerop real_onep real_minus_onep
31:    zerop
32:    initializer_each_zero_or_onep
33:    CONSTANT_CLASS_P
34:    poly_int_tree_p
35:    tree_expr_nonnegative_p
36:    tree_expr_nonzero_p
37:    integer_valued_real_p
38:    integer_pow2p
39:    uniform_integer_cst_p
40:    HONOR_NANS
41:    uniform_vector_p
```

## gcc/stor-layout.cc:67–292
```text
67: variable_size (tree size)
68: {
69:   /* Obviously.  */
70:   if (TREE_CONSTANT (size))
71:     return size;
72:
73:   /* If the size is self-referential, we can't make a SAVE_EXPR (see
74:      save_expr for the rationale).  But we can do something else.  */
75:   if (CONTAINS_PLACEHOLDER_P (size))
76:     return self_referential_size (size);
77:
78:   /* If we are in the global binding level, we can't make a SAVE_EXPR
79:      since it may end up being shared across functions, so it is up
80:      to the front-end to deal with this case.  */
81:   if (lang_hooks.decls.global_bindings_p ())
82:     return size;
83:
84:   return save_expr (size);
85: }
86:
87: /* An array of functions used for self-referential size computation.  */
88: static GTY(()) vec<tree, va_gc> *size_functions;
89:
90: /* Return true if T is a self-referential component reference.  */
91:
92: static bool
93: self_referential_component_ref_p (tree t)
94: {
95:   if (TREE_CODE (t) != COMPONENT_REF)
96:     return false;
97:
98:   while (REFERENCE_CLASS_P (t))
99:     t = TREE_OPERAND (t, 0);
100:
101:   return (TREE_CODE (t) == PLACEHOLDER_EXPR);
102: }
103:
104: /* Similar to copy_tree_r but do not copy component references involving
105:    PLACEHOLDER_EXPRs.  These nodes are spotted in find_placeholder_in_expr
106:    and substituted in substitute_in_expr.  */
107:
108: static tree
109: copy_self_referential_tree_r (tree *tp, int *walk_subtrees, void *data)
110: {
111:   enum tree_code code = TREE_CODE (*tp);
112:
113:   /* Stop at types, decls, constants like copy_tree_r.  */
114:   if (TREE_CODE_CLASS (code) == tcc_type
115:       || TREE_CODE_CLASS (code) == tcc_declaration
116:       || TREE_CODE_CLASS (code) == tcc_constant)
117:     {
118:       *walk_subtrees = 0;
119:       return NULL_TREE;
120:     }
121:
122:   /* This is the pattern built in ada/make_aligning_type.  */
123:   else if (code == ADDR_EXPR
124: 	   && TREE_CODE (TREE_OPERAND (*tp, 0)) == PLACEHOLDER_EXPR)
125:     {
126:       *walk_subtrees = 0;
127:       return NULL_TREE;
128:     }
129:
130:   /* Default case: the component reference.  */
131:   else if (self_referential_component_ref_p (*tp))
132:     {
133:       *walk_subtrees = 0;
134:       return NULL_TREE;
135:     }
136:
137:   /* We're not supposed to have them in self-referential size trees
138:      because we wouldn't properly control when they are evaluated.
139:      However, not creating superfluous SAVE_EXPRs requires accurate
140:      tracking of readonly-ness all the way down to here, which we
141:      cannot always guarantee in practice.  So punt in this case.  */
142:   else if (code == SAVE_EXPR)
143:     return error_mark_node;
144:
145:   else if (code == STATEMENT_LIST)
146:     gcc_unreachable ();
147:
148:   return copy_tree_r (tp, walk_subtrees, data);
149: }
150:
151: /* Given a SIZE expression that is self-referential, return an equivalent
152:    expression to serve as the actual size expression for a type.  */
153:
154: static tree
155: self_referential_size (tree size)
156: {
157:   static unsigned HOST_WIDE_INT fnno = 0;
158:   vec<tree> self_refs = vNULL;
159:   tree param_type_list = NULL, param_decl_list = NULL;
160:   tree t, ref, return_type, fntype, fnname, fndecl;
161:   unsigned int i;
162:   char buf[128];
163:   vec<tree, va_gc> *args = NULL;
164:
165:   /* Do not factor out simple operations.  */
166:   t = skip_simple_constant_arithmetic (size);
167:   if (TREE_CODE (t) == CALL_EXPR || self_referential_component_ref_p (t))
168:     return size;
169:
170:   /* Collect the list of self-references in the expression.  */
171:   find_placeholder_in_expr (size, &self_refs);
172:   gcc_assert (self_refs.length () > 0);
173:
174:   /* Obtain a private copy of the expression.  */
175:   t = size;
176:   if (walk_tree (&t, copy_self_referential_tree_r, NULL, NULL) != NULL_TREE)
177:     return size;
178:   size = t;
179:
180:   /* Build the parameter and argument lists in parallel; also
181:      substitute the former for the latter in the expression.  */
182:   vec_alloc (args, self_refs.length ());
183:   FOR_EACH_VEC_ELT (self_refs, i, ref)
184:     {
185:       tree subst, param_name, param_type, param_decl;
186:
187:       if (DECL_P (ref))
188: 	{
189: 	  /* We shouldn't have true variables here.  */
190: 	  gcc_assert (TREE_READONLY (ref));
191: 	  subst = ref;
192: 	}
193:       /* This is the pattern built in ada/make_aligning_type.  */
194:       else if (TREE_CODE (ref) == ADDR_EXPR)
195:         subst = ref;
196:       /* Default case: the component reference.  */
197:       else
198: 	subst = TREE_OPERAND (ref, 1);
199:
200:       sprintf (buf, "p%d", i);
201:       param_name = get_identifier (buf);
202:       param_type = TREE_TYPE (ref);
203:       param_decl
204: 	= build_decl (input_location, PARM_DECL, param_name, param_type);
205:       DECL_ARG_TYPE (param_decl) = param_type;
206:       DECL_ARTIFICIAL (param_decl) = 1;
207:       TREE_READONLY (param_decl) = 1;
208:
209:       size = substitute_in_expr (size, subst, param_decl);
210:
211:       param_type_list = tree_cons (NULL_TREE, param_type, param_type_list);
212:       param_decl_list = chainon (param_decl, param_decl_list);
213:       args->quick_push (ref);
214:     }
215:
216:   self_refs.release ();
217:
218:   /* Append 'void' to indicate that the number of parameters is fixed.  */
219:   param_type_list = tree_cons (NULL_TREE, void_type_node, param_type_list);
220:
221:   /* The 3 lists have been created in reverse order.  */
222:   param_type_list = nreverse (param_type_list);
223:   param_decl_list = nreverse (param_decl_list);
224:
225:   /* Build the function type.  */
226:   return_type = TREE_TYPE (size);
227:   fntype = build_function_type (return_type, param_type_list);
228:
229:   /* Build the function declaration.  */
230:   sprintf (buf, "SZ" HOST_WIDE_INT_PRINT_UNSIGNED, fnno++);
231:   fnname = get_file_function_name (buf);
232:   fndecl = build_decl (input_location, FUNCTION_DECL, fnname, fntype);
233:   for (t = param_decl_list; t; t = DECL_CHAIN (t))
234:     DECL_CONTEXT (t) = fndecl;
235:   DECL_ARGUMENTS (fndecl) = param_decl_list;
236:   DECL_RESULT (fndecl)
237:     = build_decl (input_location, RESULT_DECL, 0, return_type);
238:   DECL_CONTEXT (DECL_RESULT (fndecl)) = fndecl;
239:
240:   /* The function has been created by the compiler and we don't
241:      want to emit debug info for it.  */
242:   DECL_ARTIFICIAL (fndecl) = 1;
243:   DECL_IGNORED_P (fndecl) = 1;
244:
245:   /* It is supposed to be "const" and never throw.  */
246:   TREE_READONLY (fndecl) = 1;
247:   TREE_NOTHROW (fndecl) = 1;
248:
249:   /* We want it to be inlined when this is deemed profitable, as
250:      well as discarded if every call has been integrated.  */
251:   DECL_DECLARED_INLINE_P (fndecl) = 1;
252:
253:   /* It is made up of a unique return statement.  */
254:   DECL_INITIAL (fndecl) = make_node (BLOCK);
255:   BLOCK_SUPERCONTEXT (DECL_INITIAL (fndecl)) = fndecl;
256:   t = build2 (MODIFY_EXPR, return_type, DECL_RESULT (fndecl), size);
257:   DECL_SAVED_TREE (fndecl) = build1 (RETURN_EXPR, void_type_node, t);
258:   TREE_STATIC (fndecl) = 1;
259:
260:   /* Put it onto the list of size functions.  */
261:   vec_safe_push (size_functions, fndecl);
262:
263:   /* Replace the original expression with a call to the size function.  */
264:   return build_call_expr_loc_vec (UNKNOWN_LOCATION, fndecl, args);
265: }
266:
267: /* Take, queue and compile all the size functions.  It is essential that
268:    the size functions be gimplified at the very end of the compilation
269:    in order to guarantee transparent handling of self-referential sizes.
270:    Otherwise the GENERIC inliner would not be able to inline them back
271:    at each of their call sites, thus creating artificial non-constant
272:    size expressions which would trigger nasty problems later on.  */
273:
274: void
275: finalize_size_functions (void)
276: {
277:   unsigned int i;
278:   tree fndecl;
279:
280:   for (i = 0; size_functions && size_functions->iterate (i, &fndecl); i++)
281:     {
282:       allocate_struct_function (fndecl, false);
283:       set_cfun (NULL);
284:       dump_function (TDI_original, fndecl);
285:
286:       /* As these functions are used to describe the layout of variable-length
287:          structures, debug info generation needs their implementation.  */
288:       debug_hooks->size_function (fndecl);
289:       gimplify_function_tree (fndecl);
290:       cgraph_node::finalize_function (fndecl, false);
291:     }
292:
```

## gcc/stor-layout.cc:296–339
```text
296: /* Return a machine mode of class MCLASS with SIZE bits of precision,
297:    if one exists.  The mode may have padding bits as well the SIZE
298:    value bits.  If LIMIT is nonzero, disregard modes wider than
299:    MAX_FIXED_MODE_SIZE.  */
300:
301: opt_machine_mode
302: mode_for_size (poly_uint64 size, enum mode_class mclass, int limit)
303: {
304:   machine_mode mode;
305:   int i;
306:
307:   if (limit && maybe_gt (size, (unsigned int) MAX_FIXED_MODE_SIZE))
308:     return opt_machine_mode ();
309:
310:   /* Get the first mode which has this size, in the specified class.  */
311:   FOR_EACH_MODE_IN_CLASS (mode, mclass)
312:     if (known_eq (GET_MODE_PRECISION (mode), size))
313:       return mode;
314:
315:   if (mclass == MODE_INT || mclass == MODE_PARTIAL_INT)
316:     for (i = 0; i < NUM_INT_N_ENTS; i ++)
317:       if (known_eq (int_n_data[i].bitsize, size)
318: 	  && int_n_enabled_p[i])
319: 	return int_n_data[i].m;
320:
321:   return opt_machine_mode ();
322: }
323:
324: /* Similar, except passed a tree node.  */
325:
326: opt_machine_mode
327: mode_for_size_tree (const_tree size, enum mode_class mclass, int limit)
328: {
329:   unsigned HOST_WIDE_INT uhwi;
330:   unsigned int ui;
331:
332:   if (!tree_fits_uhwi_p (size))
333:     return opt_machine_mode ();
334:   uhwi = tree_to_uhwi (size);
335:   ui = uhwi;
336:   if (uhwi != ui)
337:     return opt_machine_mode ();
338:   return mode_for_size (ui, mclass, limit);
339: }
```

## gcc/stor-layout.cc:603–633
```text
603: mode_for_array (tree elem_type, tree size)
604: {
605:   tree elem_size;
606:   poly_uint64 int_size, int_elem_size;
607:   unsigned HOST_WIDE_INT num_elems;
608:   bool limit_p;
609:
610:   /* One-element arrays get the component type's mode.  */
611:   elem_size = TYPE_SIZE (elem_type);
612:   if (simple_cst_equal (size, elem_size))
613:     return TYPE_MODE (elem_type);
614:
615:   limit_p = true;
616:   if (poly_int_tree_p (size, &int_size)
617:       && poly_int_tree_p (elem_size, &int_elem_size)
618:       && maybe_ne (int_elem_size, 0U)
619:       && constant_multiple_p (int_size, int_elem_size, &num_elems))
620:     {
621:       machine_mode elem_mode = TYPE_MODE (elem_type);
622:       machine_mode mode;
623:       if (targetm.array_mode (elem_mode, num_elems).exists (&mode))
624: 	return mode;
625:       if (targetm.array_mode_supported_p (elem_mode, num_elems))
626: 	limit_p = false;
627:     }
628:   return mode_for_size_tree (size, MODE_INT, limit_p).else_blk ();
629: }
630:
631: /* Subroutine of layout_decl: Force alignment required for the data type.
632:    But if the decl itself wants greater alignment, don't override that.  */
633:
```

## gcc/stor-layout.cc:808–813
```text
808:   /* Evaluate nonconstant size only once, either now or as soon as safe.  */
809:   if (DECL_SIZE (decl) != 0 && TREE_CODE (DECL_SIZE (decl)) != INTEGER_CST)
810:     DECL_SIZE (decl) = variable_size (DECL_SIZE (decl));
811:   if (DECL_SIZE_UNIT (decl) != 0
812:       && TREE_CODE (DECL_SIZE_UNIT (decl)) != INTEGER_CST)
813:     DECL_SIZE_UNIT (decl) = variable_size (DECL_SIZE_UNIT (decl));
```

## gcc/stor-layout.cc:909–929
```text
909: /* Fold sizetype value X to bitsizetype, given that X represents a type
910:    size or offset.  */
911:
912: static tree
913: bits_from_bytes (tree x)
914: {
915:   if (POLY_INT_CST_P (x))
916:     /* The runtime calculation isn't allowed to overflow sizetype;
917:        increasing the runtime values must always increase the size
918:        or offset of the object.  This means that the object imposes
919:        a maximum value on the runtime parameters, but we don't record
920:        what that is.  */
921:     return build_poly_int_cst
922:       (bitsizetype,
923:        poly_wide_int::from (poly_int_cst_value (x),
924: 			    TYPE_PRECISION (bitsizetype),
925: 			    TYPE_SIGN (TREE_TYPE (x))));
926:   x = fold_convert (bitsizetype, x);
927:   gcc_checking_assert (x);
928:   return x;
929: }
```

## gcc/stor-layout.cc:1675–1680
```text
1675:   handle_warn_if_not_align (field, rli->record_align);
1676:
1677:   /* Evaluate nonconstant offsets only once, either now or as soon as safe.  */
1678:   if (TREE_CODE (DECL_FIELD_OFFSET (field)) != INTEGER_CST)
1679:     DECL_FIELD_OFFSET (field) = variable_size (DECL_FIELD_OFFSET (field));
1680:
```

## gcc/stor-layout.cc:1962–2067
```text
1962: finalize_type_size (tree type)
1963: {
1964:   /* Normally, use the alignment corresponding to the mode chosen.
1965:      However, where strict alignment is not required, avoid
1966:      over-aligning structures, since most compilers do not do this
1967:      alignment.  */
1968:   bool tua_cleared_p = false;
1969:   if (TYPE_MODE (type) != BLKmode
1970:       && TYPE_MODE (type) != VOIDmode
1971:       && (STRICT_ALIGNMENT || !AGGREGATE_TYPE_P (type)))
1972:     {
1973:       unsigned mode_align = GET_MODE_ALIGNMENT (TYPE_MODE (type));
1974:
1975:       /* Don't override a larger alignment requirement coming from a user
1976: 	 alignment of one of the fields.  */
1977:       if (mode_align >= TYPE_ALIGN (type))
1978: 	{
1979: 	  SET_TYPE_ALIGN (type, mode_align);
1980: 	  /* Remember that we're about to reset this flag.  */
1981: 	  tua_cleared_p = TYPE_USER_ALIGN (type);
1982: 	  TYPE_USER_ALIGN (type) = false;
1983: 	}
1984:     }
1985:
1986:   /* Do machine-dependent extra alignment.  */
1987: #ifdef ROUND_TYPE_ALIGN
1988:   SET_TYPE_ALIGN (type,
1989:                   ROUND_TYPE_ALIGN (type, TYPE_ALIGN (type), BITS_PER_UNIT));
1990: #endif
1991:
1992:   /* If we failed to find a simple way to calculate the unit size
1993:      of the type, find it by division.  */
1994:   if (TYPE_SIZE_UNIT (type) == 0 && TYPE_SIZE (type) != 0)
1995:     /* TYPE_SIZE (type) is computed in bitsizetype.  After the division, the
1996:        result will fit in sizetype.  We will get more efficient code using
1997:        sizetype, so we force a conversion.  */
1998:     TYPE_SIZE_UNIT (type)
1999:       = fold_convert (sizetype,
2000: 		      size_binop (FLOOR_DIV_EXPR, TYPE_SIZE (type),
2001: 				  bitsize_unit_node));
2002:
2003:   if (TYPE_SIZE (type) != 0)
2004:     {
2005:       TYPE_SIZE (type) = round_up (TYPE_SIZE (type), TYPE_ALIGN (type));
2006:       TYPE_SIZE_UNIT (type)
2007: 	= round_up (TYPE_SIZE_UNIT (type), TYPE_ALIGN_UNIT (type));
2008:     }
2009:
2010:   /* Evaluate nonconstant sizes only once, either now or as soon as safe.  */
2011:   if (TYPE_SIZE (type) != 0 && TREE_CODE (TYPE_SIZE (type)) != INTEGER_CST)
2012:     TYPE_SIZE (type) = variable_size (TYPE_SIZE (type));
2013:   if (TYPE_SIZE_UNIT (type) != 0
2014:       && TREE_CODE (TYPE_SIZE_UNIT (type)) != INTEGER_CST)
2015:     TYPE_SIZE_UNIT (type) = variable_size (TYPE_SIZE_UNIT (type));
2016:
2017:   /* Handle empty records as per the x86-64 psABI.  */
2018:   TYPE_EMPTY_P (type) = targetm.calls.empty_record_p (type);
2019:
2020:   /* Also layout any other variants of the type.  */
2021:   if (TYPE_NEXT_VARIANT (type)
2022:       || type != TYPE_MAIN_VARIANT (type))
2023:     {
2024:       tree variant;
2025:       /* Record layout info of this variant.  */
2026:       tree size = TYPE_SIZE (type);
2027:       tree size_unit = TYPE_SIZE_UNIT (type);
2028:       unsigned int align = TYPE_ALIGN (type);
2029:       unsigned int precision = TYPE_PRECISION (type);
2030:       unsigned int user_align = TYPE_USER_ALIGN (type);
2031:       machine_mode mode = TYPE_MODE (type);
2032:       bool empty_p = TYPE_EMPTY_P (type);
2033:       bool typeless = AGGREGATE_TYPE_P (type) && TYPE_TYPELESS_STORAGE (type);
2034:
2035:       /* Copy it into all variants.  */
2036:       for (variant = TYPE_MAIN_VARIANT (type);
2037: 	   variant != NULL_TREE;
2038: 	   variant = TYPE_NEXT_VARIANT (variant))
2039: 	{
2040: 	  TYPE_SIZE (variant) = size;
2041: 	  TYPE_SIZE_UNIT (variant) = size_unit;
2042: 	  unsigned valign = align;
2043: 	  if (TYPE_USER_ALIGN (variant))
2044: 	    {
2045: 	      valign = MAX (valign, TYPE_ALIGN (variant));
2046: 	      /* If we reset TYPE_USER_ALIGN on the main variant, we might
2047: 		 need to reset it on the variants too.  TYPE_MODE will be set
2048: 		 to MODE in this variant, so we can use that.  */
2049: 	      if (tua_cleared_p && GET_MODE_ALIGNMENT (mode) >= valign)
2050: 		TYPE_USER_ALIGN (variant) = false;
2051: 	    }
2052: 	  else
2053: 	    TYPE_USER_ALIGN (variant) = user_align;
2054: 	  SET_TYPE_ALIGN (variant, valign);
2055: 	  TYPE_PRECISION (variant) = precision;
2056: 	  SET_TYPE_MODE (variant, mode);
2057: 	  TYPE_EMPTY_P (variant) = empty_p;
2058: 	  if (AGGREGATE_TYPE_P (variant))
2059: 	    TYPE_TYPELESS_STORAGE (variant) = typeless;
2060: 	}
2061:     }
2062: }
2063:
2064: /* Return a new underlying object for a bitfield started with FIELD.  */
2065:
2066: static tree
2067: start_bitfield_representative (tree field)
```

## gcc/stor-layout.cc:2402–2427
```text
2402: void compute_array_mode (tree type)
2403: {
2404:   gcc_assert (TREE_CODE (type) == ARRAY_TYPE);
2405:
2406:   SET_TYPE_MODE (type, BLKmode);
2407:   if (TYPE_SIZE (type) != 0
2408:       && ! targetm.member_type_forces_blk (type, VOIDmode)
2409:       /* BLKmode elements force BLKmode aggregate;
2410: 	 else extract/store fields may lose.  */
2411:       && (TYPE_MODE (TREE_TYPE (type)) != BLKmode
2412: 	  || TYPE_NO_FORCE_BLK (TREE_TYPE (type))))
2413:     {
2414:       SET_TYPE_MODE (type, mode_for_array (TREE_TYPE (type),
2415: 					   TYPE_SIZE (type)));
2416:       if (TYPE_MODE (type) != BLKmode
2417: 	  && STRICT_ALIGNMENT && TYPE_ALIGN (type) < BIGGEST_ALIGNMENT
2418: 	  && TYPE_ALIGN (type) < GET_MODE_ALIGNMENT (TYPE_MODE (type)))
2419: 	{
2420: 	  TYPE_NO_FORCE_BLK (type) = 1;
2421: 	  SET_TYPE_MODE (type, BLKmode);
2422: 	}
2423:     }
2424: }
2425:
2426: /* Calculate the mode, size, and alignment for TYPE.
2427:    For an array type, calculate the element separation as well.
```

## gcc/stor-layout.cc:2437–2469
```text
2437: layout_type (tree type)
2438: {
2439:   gcc_assert (type);
2440:
2441:   if (type == error_mark_node)
2442:     return;
2443:
2444:   /* We don't want finalize_type_size to copy an alignment attribute to
2445:      variants that don't have it.  */
2446:   type = TYPE_MAIN_VARIANT (type);
2447:
2448:   /* Do nothing if type has been laid out before.  */
2449:   if (TYPE_SIZE (type))
2450:     return;
2451:
2452:   switch (TREE_CODE (type))
2453:     {
2454:     case LANG_TYPE:
2455:       /* This kind of type is the responsibility
2456: 	 of the language-specific code.  */
2457:       gcc_unreachable ();
2458:
2459:     case BOOLEAN_TYPE:
2460:     case INTEGER_TYPE:
2461:     case ENUMERAL_TYPE:
2462:       {
2463: 	scalar_int_mode mode
2464: 	  = smallest_int_mode_for_size (TYPE_PRECISION (type)).require ();
2465: 	SET_TYPE_MODE (type, mode);
2466: 	TYPE_SIZE (type) = bitsize_int (GET_MODE_BITSIZE (mode));
2467: 	/* Don't set TYPE_PRECISION here, as it may be set by a bitfield.  */
2468: 	TYPE_SIZE_UNIT (type) = size_int (GET_MODE_SIZE (mode));
2469: 	break;
```

## gcc/stor-layout.cc:2558–2576
```text
2558:       TYPE_UNSIGNED (type) = TYPE_UNSIGNED (TREE_TYPE (type));
2559:       if (TYPE_MODE (TREE_TYPE (type)) == BLKmode)
2560: 	{
2561: 	  gcc_checking_assert (TREE_CODE (TREE_TYPE (type)) == BITINT_TYPE);
2562: 	  SET_TYPE_MODE (type, BLKmode);
2563: 	  TYPE_SIZE (type)
2564: 	    = int_const_binop (MULT_EXPR, TYPE_SIZE (TREE_TYPE (type)),
2565: 			       bitsize_int (2));
2566: 	  TYPE_SIZE_UNIT (type)
2567: 	    = int_const_binop (MULT_EXPR, TYPE_SIZE_UNIT (TREE_TYPE (type)),
2568: 			       bitsize_int (2));
2569: 	  break;
2570: 	}
2571:       SET_TYPE_MODE (type,
2572: 		     GET_MODE_COMPLEX_MODE (TYPE_MODE (TREE_TYPE (type))));
2573:
2574:       TYPE_SIZE (type) = bitsize_int (GET_MODE_BITSIZE (TYPE_MODE (type)));
2575:       TYPE_SIZE_UNIT (type) = size_int (GET_MODE_SIZE (TYPE_MODE (type)));
2576:       break;
```

## gcc/stor-layout.cc:2651–2773
```text
2651:     case POINTER_TYPE:
2652:     case REFERENCE_TYPE:
2653:       {
2654: 	scalar_int_mode mode = SCALAR_INT_TYPE_MODE (type);
2655: 	TYPE_SIZE (type) = bitsize_int (GET_MODE_BITSIZE (mode));
2656: 	TYPE_SIZE_UNIT (type) = size_int (GET_MODE_SIZE (mode));
2657: 	TYPE_UNSIGNED (type) = 1;
2658: 	TYPE_PRECISION (type) = GET_MODE_PRECISION (mode);
2659:       }
2660:       break;
2661:
2662:     case ARRAY_TYPE:
2663:       {
2664: 	tree index = TYPE_DOMAIN (type);
2665: 	tree element = TREE_TYPE (type);
2666:
2667: 	/* We need to know both bounds in order to compute the size.  */
2668: 	if (index && TYPE_MAX_VALUE (index) && TYPE_MIN_VALUE (index)
2669: 	    && TYPE_SIZE (element))
2670: 	  {
2671: 	    tree ub = TYPE_MAX_VALUE (index);
2672: 	    tree lb = TYPE_MIN_VALUE (index);
2673: 	    tree element_size = TYPE_SIZE (element);
2674: 	    tree length;
2675:
2676: 	    /* Make sure that an array of zero-sized element is zero-sized
2677: 	       regardless of its extent.  */
2678: 	    if (integer_zerop (element_size))
2679: 	      length = size_zero_node;
2680:
2681: 	    /* The computation should happen in the original signedness so
2682: 	       that (possible) negative values are handled appropriately
2683: 	       when determining overflow.  */
2684: 	    else
2685: 	      {
2686: 		/* ???  When it is obvious that the range is signed
2687: 		   represent it using ssizetype.  */
2688: 		if (TREE_CODE (lb) == INTEGER_CST
2689: 		    && TREE_CODE (ub) == INTEGER_CST
2690: 		    && TYPE_UNSIGNED (TREE_TYPE (lb))
2691: 		    && tree_int_cst_lt (ub, lb))
2692: 		  {
2693: 		    lb = wide_int_to_tree (ssizetype,
2694: 					   offset_int::from (wi::to_wide (lb),
2695: 							     SIGNED));
2696: 		    ub = wide_int_to_tree (ssizetype,
2697: 					   offset_int::from (wi::to_wide (ub),
2698: 							     SIGNED));
2699: 		  }
2700: 		length
2701: 		  = fold_convert (sizetype,
2702: 				  size_binop (PLUS_EXPR,
2703: 					      build_int_cst (TREE_TYPE (lb), 1),
2704: 					      size_binop (MINUS_EXPR, ub, lb)));
2705: 	      }
2706:
2707: 	    /* ??? We have no way to distinguish a null-sized array from an
2708: 	       array spanning the whole sizetype range, so we arbitrarily
2709: 	       decide that [0, -1] is the only valid representation.  */
2710: 	    if (integer_zerop (length)
2711: 	        && TREE_OVERFLOW (length)
2712: 		&& integer_zerop (lb))
2713: 	      length = size_zero_node;
2714:
2715: 	    TYPE_SIZE (type) = size_binop (MULT_EXPR, element_size,
2716: 					   bits_from_bytes (length));
2717:
2718: 	    /* If we know the size of the element, calculate the total size
2719: 	       directly, rather than do some division thing below.  This
2720: 	       optimization helps Fortran assumed-size arrays (where the
2721: 	       size of the array is determined at runtime) substantially.  */
2722: 	    if (TYPE_SIZE_UNIT (element))
2723: 	      TYPE_SIZE_UNIT (type)
2724: 		= size_binop (MULT_EXPR, TYPE_SIZE_UNIT (element), length);
2725: 	  }
2726:
2727: 	/* Now round the alignment and size,
2728: 	   using machine-dependent criteria if any.  */
2729:
2730: 	unsigned align = TYPE_ALIGN (element);
2731: 	if (TYPE_USER_ALIGN (type))
2732: 	  align = MAX (align, TYPE_ALIGN (type));
2733: 	else
2734: 	  TYPE_USER_ALIGN (type) = TYPE_USER_ALIGN (element);
2735: 	if (!TYPE_WARN_IF_NOT_ALIGN (type))
2736: 	  SET_TYPE_WARN_IF_NOT_ALIGN (type,
2737: 				      TYPE_WARN_IF_NOT_ALIGN (element));
2738: #ifdef ROUND_TYPE_ALIGN
2739: 	align = ROUND_TYPE_ALIGN (type, align, BITS_PER_UNIT);
2740: #else
2741: 	align = MAX (align, BITS_PER_UNIT);
2742: #endif
2743: 	SET_TYPE_ALIGN (type, align);
2744: 	compute_array_mode (type);
2745: 	if (AGGREGATE_TYPE_P (element))
2746: 	  TYPE_TYPELESS_STORAGE (type) = TYPE_TYPELESS_STORAGE (element);
2747: 	/* When the element size is constant, check that it is at least as
2748: 	   large as the element alignment.  */
2749: 	if (TYPE_SIZE_UNIT (element)
2750: 	    && TREE_CODE (TYPE_SIZE_UNIT (element)) == INTEGER_CST
2751: 	    /* If TYPE_SIZE_UNIT overflowed, then it is certainly larger than
2752: 	       TYPE_ALIGN_UNIT.  */
2753: 	    && !TREE_OVERFLOW (TYPE_SIZE_UNIT (element))
2754: 	    && !integer_zerop (TYPE_SIZE_UNIT (element)))
2755: 	  {
2756: 	    if (compare_tree_int (TYPE_SIZE_UNIT (element),
2757: 				  TYPE_ALIGN_UNIT (element)) < 0)
2758: 	      error ("alignment of array elements is greater than "
2759: 		     "element size");
2760: 	    else if (TYPE_ALIGN_UNIT (element) > 1
2761: 		     && (wi::zext (wi::to_wide (TYPE_SIZE_UNIT (element)),
2762: 				  ffs_hwi (TYPE_ALIGN_UNIT (element)) - 1)
2763: 			 != 0))
2764: 	      error ("size of array element is not a multiple of its "
2765: 		     "alignment");
2766: 	  }
2767: 	break;
2768:       }
2769:
2770:     case RECORD_TYPE:
2771:     case UNION_TYPE:
2772:     case QUAL_UNION_TYPE:
2773:       {
```

## gcc/stor-layout.cc:2810–2821
```text
2810:   if (AGGREGATE_TYPE_P (type))
2811:     gcc_assert (!TYPE_ALIAS_SET_KNOWN_P (type));
2812: }
2813:
2814: /* Return the least alignment required for type TYPE.  */
2815:
2816: unsigned int
2817: min_align_of_type (tree type)
2818: {
2819:   unsigned int align = TYPE_ALIGN (type);
2820:   if (!TYPE_USER_ALIGN (type))
2821:     {
```

## gcc/stor-layout.cc:2838–2860
```text
2838: make_signed_type (int precision)
2839: {
2840:   tree type = make_node (INTEGER_TYPE);
2841:
2842:   TYPE_PRECISION (type) = precision;
2843:
2844:   fixup_signed_type (type);
2845:   return type;
2846: }
2847:
2848: /* Create and return a type for unsigned integers of PRECISION bits.  */
2849:
2850: tree
2851: make_unsigned_type (int precision)
2852: {
2853:   tree type = make_node (INTEGER_TYPE);
2854:
2855:   TYPE_PRECISION (type) = precision;
2856:
2857:   fixup_unsigned_type (type);
2858:   return type;
2859: }
2860:
```

## gcc/stor-layout.cc:2991–3040
```text
2991: set_min_and_max_values_for_integral_type (tree type,
2992: 					  int precision,
2993: 					  signop sgn)
2994: {
2995:   /* For bitfields with zero width we end up creating integer types
2996:      with zero precision.  Don't assign any minimum/maximum values
2997:      to those types, they don't have any valid value.  */
2998:   if (precision < 1)
2999:     return;
3000:
3001:   gcc_assert (precision <= WIDE_INT_MAX_PRECISION);
3002:
3003:   TYPE_MIN_VALUE (type)
3004:     = wide_int_to_tree (type, wi::min_value (precision, sgn));
3005:   TYPE_MAX_VALUE (type)
3006:     = wide_int_to_tree (type, wi::max_value (precision, sgn));
3007: }
3008:
3009: /* Set the extreme values of TYPE based on its precision in bits,
3010:    then lay it out.  Used when make_signed_type won't do
3011:    because the tree code is not INTEGER_TYPE.  */
3012:
3013: void
3014: fixup_signed_type (tree type)
3015: {
3016:   int precision = TYPE_PRECISION (type);
3017:
3018:   set_min_and_max_values_for_integral_type (type, precision, SIGNED);
3019:
3020:   /* Lay out the type: set its alignment, size, etc.  */
3021:   layout_type (type);
3022: }
3023:
3024: /* Set the extreme values of TYPE based on its precision in bits,
3025:    then lay it out.  This is used both in `make_unsigned_type'
3026:    and for enumeral types.  */
3027:
3028: void
3029: fixup_unsigned_type (tree type)
3030: {
3031:   int precision = TYPE_PRECISION (type);
3032:
3033:   TYPE_UNSIGNED (type) = 1;
3034:
3035:   set_min_and_max_values_for_integral_type (type, precision, UNSIGNED);
3036:
3037:   /* Lay out the type: set its alignment, size, etc.  */
3038:   layout_type (type);
3039: }
3040:
```

## gcc/target.def:2324–2330
```text
2324: /* Assign default attributes to the newly defined TYPE.  */
2325: DEFHOOK
2326: (set_default_type_attributes,
2327:  "If defined, this target hook is a function which assigns default attributes to\n\
2328: the newly defined @var{type}.",
2329:  void, (tree type),
2330:  hook_void_tree)
```

## gcc/target.def:3710–3763
```text
3710: DEFHOOK
3711: (array_mode,
3712:  "Return the mode that GCC should use for an array that has\n\
3713: @var{nelems} elements, with each element having mode @var{mode}.\n\
3714: Return no mode if the target has no special requirements.  In the\n\
3715: latter case, GCC looks for an integer mode of the appropriate size\n\
3716: if available and uses BLKmode otherwise.  Usually the search for the\n\
3717: integer mode is limited to @code{MAX_FIXED_MODE_SIZE}, but the\n\
3718: @code{TARGET_ARRAY_MODE_SUPPORTED_P} hook allows a larger mode to be\n\
3719: used in specific cases.\n\
3720: \n\
3721: The main use of this hook is to specify that an array of vectors should\n\
3722: also have a vector mode.  The default implementation returns no mode.",
3723:  opt_machine_mode, (machine_mode mode, unsigned HOST_WIDE_INT nelems),
3724:  hook_optmode_mode_uhwi_none)
3725:
3726: /* True if we should try to use a scalar mode to represent an array,
3727:    overriding the usual MAX_FIXED_MODE limit.  */
3728: DEFHOOK
3729: (array_mode_supported_p,
3730:  "Return true if GCC should try to use a scalar mode to store an array\n\
3731: of @var{nelems} elements, given that each element has mode @var{mode}.\n\
3732: Returning true here overrides the usual @code{MAX_FIXED_MODE} limit\n\
3733: and allows GCC to use any defined integer mode.\n\
3734: \n\
3735: One use of this hook is to support vector load and store operations\n\
3736: that operate on several homogeneous vectors.  For example, ARM NEON\n\
3737: has operations like:\n\
3738: \n\
3739: @smallexample\n\
3740: int8x8x3_t vld3_s8 (const int8_t *)\n\
3741: @end smallexample\n\
3742: \n\
3743: where the return type is defined as:\n\
3744: \n\
3745: @smallexample\n\
3746: typedef struct int8x8x3_t\n\
3747: @{\n\
3748:   int8x8_t val[3];\n\
3749: @} int8x8x3_t;\n\
3750: @end smallexample\n\
3751: \n\
3752: If this hook allows @code{val} to have a scalar mode, then\n\
3753: @code{int8x8x3_t} can have the same mode.  GCC can then store\n\
3754: @code{int8x8x3_t}s in registers rather than forcing them onto the stack.",
3755:  bool, (machine_mode mode, unsigned HOST_WIDE_INT nelems),
3756:  hook_bool_mode_uhwi_false)
3757:
3758: DEFHOOK
3759: (libgcc_floating_mode_supported_p,
3760:  "Define this to return nonzero if libgcc provides support for the \n\
3761: floating-point mode @var{mode}, which is known to pass \n\
3762: @code{TARGET_SCALAR_MODE_SUPPORTED_P}.  The default version of this \n\
3763: hook returns true for all of @code{SFmode}, @code{DFmode}, \n\
```

## gcc/coretypes.h:362–388
```text
362:    everything) and -1 (sometimes indicating that the alias set is
363:    unknown, sometimes indicating a memory barrier) and -2 (indicating
364:    that the alias set should be set to a unique value but has not been
365:    set yet).  */
366: typedef int alias_set_type;
367:
368: class edge_def;
369: typedef class edge_def *edge;
370: typedef const class edge_def *const_edge;
371: struct basic_block_def;
372: typedef struct basic_block_def *basic_block;
373: typedef const struct basic_block_def *const_basic_block;
374:
375: #if !defined (GENERATOR_FILE)
376: # define OBSTACK_CHUNK_SIZE     memory_block_pool::block_size
377: # define obstack_chunk_alloc    mempool_obstack_chunk_alloc
378: # define obstack_chunk_free     mempool_obstack_chunk_free
379: #else
380: # define OBSTACK_CHUNK_SIZE     0
381: # define obstack_chunk_alloc    xmalloc
382: # define obstack_chunk_free     free
383: #endif
384:
385: #define gcc_obstack_init(OBSTACK)				\
386:   obstack_specify_allocation ((OBSTACK), OBSTACK_CHUNK_SIZE, 0,	\
387: 			      obstack_chunk_alloc,		\
388: 			      obstack_chunk_free)
```

## gcc/hooks.cc:152–155
```text
152: hook_bool_mode_uhwi_false (machine_mode, unsigned HOST_WIDE_INT)
153: {
154:   return false;
155: }
```

## gcc/hooks.cc:293–298
```text
293:
294: void
295: hook_void_tree (tree)
296: {
297: }
298:
```

## gcc/hooks.cc:584–587
```text
584: hook_optmode_mode_uhwi_none (machine_mode, unsigned HOST_WIDE_INT)
585: {
586:   return opt_machine_mode ();
587: }
```

## gcc/tree.h:5460–5467
```text
5460: extern bool contains_placeholder_p (const_tree);
5461:
5462: /* This macro calls the above function but short-circuits the common
5463:    case of a constant to save time.  Also check for null.  */
5464:
5465: #define CONTAINS_PLACEHOLDER_P(EXP) \
5466:   ((EXP) != 0 && ! TREE_CONSTANT (EXP) && contains_placeholder_p (EXP))
5467:
```

## gcc/tree.h:5500–5517
```text
5500:
5501: /* This macro calls the above function but short-circuits the common
5502:    case of a constant to save time and also checks for NULL.  */
5503:
5504: #define SUBSTITUTE_IN_EXPR(EXP, F, R) \
5505:   ((EXP) == 0 || TREE_CONSTANT (EXP) ? (EXP) : substitute_in_expr (EXP, F, R))
5506:
5507: /* Similar, but look for a PLACEHOLDER_EXPR in EXP and find a replacement
5508:    for it within OBJ, a tree that is an object or a chain of references.  */
5509:
5510: extern tree substitute_placeholder_in_expr (tree, tree);
5511:
5512: /* This macro calls the above function but short-circuits the common
5513:    case of a constant to save time and also checks for NULL.  */
5514:
5515: #define SUBSTITUTE_PLACEHOLDER_IN_EXPR(EXP, OBJ) \
5516:   ((EXP) == 0 || TREE_CONSTANT (EXP) ? (EXP)	\
5517:    : substitute_placeholder_in_expr (EXP, OBJ))
```

## gcc/tree.h:5921–5929
```text
5921: extern void set_call_expr_flags (tree, int);
5922: extern tree walk_tree_1 (tree*, walk_tree_fn, void*, hash_set<tree>*,
5923: 			 walk_tree_lh);
5924: extern tree walk_tree_without_duplicates_1 (tree*, walk_tree_fn, void*,
5925: 					    walk_tree_lh);
5926: #define walk_tree(a,b,c,d) \
5927: 	walk_tree_1 (a, b, c, d, NULL)
5928: #define walk_tree_without_duplicates(a,b,c) \
5929: 	walk_tree_without_duplicates_1 (a, b, c, NULL)
```

## gcc/bitmap.h:279–366
```text
279: /* BITMAP_WORD_BITS needs to be unsigned, but cannot contain casts as
280:    it is used in preprocessor directives -- hence the 1u.  */
281: #define BITMAP_WORD_BITS (CHAR_BIT * SIZEOF_LONG * 1u)
282:
283: /* Number of words to use for each element in the linked list.  */
284:
285: #ifndef BITMAP_ELEMENT_WORDS
286: #define BITMAP_ELEMENT_WORDS ((128 + BITMAP_WORD_BITS - 1) / BITMAP_WORD_BITS)
287: #endif
288:
289: /* Number of bits in each actual element of a bitmap.  */
290:
291: #define BITMAP_ELEMENT_ALL_BITS (BITMAP_ELEMENT_WORDS * BITMAP_WORD_BITS)
292:
293: /* Obstack for allocating bitmaps and elements from.  */
294: struct bitmap_obstack {
295:   struct bitmap_element *elements;
296:   bitmap_head *heads;
297:   struct obstack obstack;
298: };
299:
300: /* Bitmap set element.  We use a linked list to hold only the bits that
301:    are set.  This allows for use to grow the bitset dynamically without
302:    having to realloc and copy a giant bit array.
303:
304:    The free list is implemented as a list of lists.  There is one
305:    outer list connected together by prev fields.  Each element of that
306:    outer is an inner list (that may consist only of the outer list
307:    element) that are connected by the next fields.  The prev pointer
308:    is undefined for interior elements.  This allows
309:    bitmap_elt_clear_from to be implemented in unit time rather than
310:    linear in the number of elements to be freed.  */
311:
312: struct GTY((chain_next ("%h.next"))) bitmap_element {
313:   /* In list form, the next element in the linked list;
314:      in tree form, the left child node in the tree.  */
315:   struct bitmap_element *next;
316:   /* In list form, the previous element in the linked list;
317:      in tree form, the right child node in the tree.  */
318:   struct bitmap_element *prev;
319:   /* regno/BITMAP_ELEMENT_ALL_BITS.  */
320:   unsigned int indx;
321:   /* Bits that are set, counting from INDX, inclusive  */
322:   BITMAP_WORD bits[BITMAP_ELEMENT_WORDS];
323: };
324:
325: /* Head of bitmap linked list.  The 'current' member points to something
326:    already pointed to by the chain started by first, so GTY((skip)) it.  */
327:
328: class GTY(()) bitmap_head {
329: public:
330:   static bitmap_obstack crashme;
331:   /* Poison obstack to not make it not a valid initialized GC bitmap.  */
332:   CONSTEXPR bitmap_head()
333:     : indx (0), tree_form (false), padding (0), alloc_descriptor (0), first (NULL),
334:       current (NULL), obstack (&crashme)
335:   {}
336:   /* Index of last element looked at.  */
337:   unsigned int indx;
338:   /* False if the bitmap is in list form; true if the bitmap is in tree form.
339:      Bitmap iterators only work on bitmaps in list form.  */
340:   unsigned tree_form: 1;
341:   /* Next integer is shifted, so padding is needed.  */
342:   unsigned padding: 2;
343:   /* Bitmap UID used for memory allocation statistics.  */
344:   unsigned alloc_descriptor: 29;
345:   /* In list form, the first element in the linked list;
346:      in tree form, the root of the tree.   */
347:   bitmap_element *first;
348:   /* Last element looked at.  */
349:   bitmap_element * GTY((skip(""))) current;
350:   /* Obstack to allocate elements from.  If NULL, then use GGC allocation.  */
351:   bitmap_obstack * GTY((skip(""))) obstack;
352:
353:   /* Dump bitmap.  */
354:   void dump ();
355:
356:   /* Get bitmap descriptor UID casted to an unsigned integer pointer.
357:      Shift the descriptor because pointer_hash<Type>::hash is
358:      doing >> 3 shift operation.  */
359:   unsigned *get_descriptor ()
360:   {
361:     return (unsigned *)(ptrdiff_t)(alloc_descriptor << 3);
362:   }
363: };
364:
365: /* Global data */
366: extern bitmap_element bitmap_zero_bits;	/* Zero bitmap element */
```

## gcc/bitmap.h:466–475
```text
466: inline void
467: bitmap_initialize (bitmap head, bitmap_obstack *obstack CXX_MEM_STAT_INFO)
468: {
469:   head->first = head->current = NULL;
470:   head->indx = head->tree_form = 0;
471:   head->padding = 0;
472:   head->alloc_descriptor = 0;
473:   head->obstack = obstack;
474:   if (GATHER_STATISTICS)
475:     bitmap_register (head PASS_MEM_STAT);
```

## gcc/bitmap.cc:35–69
```text
35: /* Register new bitmap.  */
36: void
37: bitmap_register (bitmap b MEM_STAT_DECL)
38: {
39:   static unsigned alloc_descriptor_max_uid = 1;
40:   gcc_assert (b->alloc_descriptor == 0);
41:   b->alloc_descriptor = alloc_descriptor_max_uid++;
42:
43:   bitmap_mem_desc.register_descriptor (b->get_descriptor (), BITMAP_ORIGIN,
44: 				       false FINAL_PASS_MEM_STAT);
45: }
46:
47: /* Account the overhead.  */
48: static void
49: register_overhead (bitmap b, size_t amount)
50: {
51:   unsigned *d = b->get_descriptor ();
52:   if (bitmap_mem_desc.contains_descriptor_for_instance (d))
53:     bitmap_mem_desc.register_instance_overhead (amount, d);
54: }
55:
56: /* Release the overhead.  */
57: static void
58: release_overhead (bitmap b, size_t amount, bool remove_from_map)
59: {
60:   unsigned *d = b->get_descriptor ();
61:   if (bitmap_mem_desc.contains_descriptor_for_instance (d))
62:     bitmap_mem_desc.release_instance_overhead (d, amount, remove_from_map);
63: }
64:
65:
66: /* Global data */
67: bitmap_element bitmap_zero_bits;  /* An element of all zero bits.  */
68: bitmap_obstack bitmap_default_obstack;    /* The default bitmap obstack.  */
69: static int bitmap_default_obstack_depth;
```

## gcc/bitmap.cc:102–148
```text
102: bitmap_element_allocate (bitmap head)
103: {
104:   bitmap_element *element;
105:   bitmap_obstack *bit_obstack = head->obstack;
106:
107:   if (bit_obstack)
108:     {
109:       element = bit_obstack->elements;
110:
111:       if (element)
112: 	/* Use up the inner list first before looking at the next
113: 	   element of the outer list.  */
114: 	if (element->next)
115: 	  {
116: 	    bit_obstack->elements = element->next;
117: 	    bit_obstack->elements->prev = element->prev;
118: 	  }
119: 	else
120: 	  /*  Inner list was just a singleton.  */
121: 	  bit_obstack->elements = element->prev;
122:       else
123: 	element = XOBNEW (&bit_obstack->obstack, bitmap_element);
124:     }
125:   else
126:     {
127:       element = bitmap_ggc_free;
128:       if (element)
129: 	/* Use up the inner list first before looking at the next
130: 	   element of the outer list.  */
131: 	if (element->next)
132: 	  {
133: 	    bitmap_ggc_free = element->next;
134: 	    bitmap_ggc_free->prev = element->prev;
135: 	  }
136: 	else
137: 	  /*  Inner list was just a singleton.  */
138: 	  bitmap_ggc_free = element->prev;
139:       else
140: 	element = ggc_alloc<bitmap_element> ();
141:     }
142:
143:   if (GATHER_STATISTICS)
144:     register_overhead (head, sizeof (bitmap_element));
145:
146:   memset (element->bits, 0, sizeof (element->bits));
147:
148:   return element;
```

## gcc/bitmap.cc:597–660
```text
597: bitmap_tree_listify_from (bitmap head, bitmap_element *e)
598: {
599:   bitmap_element *t, *erb;
600:
601:   /* Detach the right branch from E (all elements with indx > E->indx),
602:      and splay E to the root.  */
603:   erb = e->next;
604:   e->next = NULL;
605:   t = bitmap_tree_splay (head, head->first, e->indx);
606:   gcc_checking_assert (t == e);
607:
608:   /* Because E has no right branch, and we rotated it to the root,
609:      the left branch is the new root.  */
610:   t = e->prev;
611:   head->first = t;
612:   head->current = t;
613:   head->indx = (t != NULL) ? t->indx : 0;
614:
615:   /* Detach the tree from E, and re-attach the right branch of E.  */
616:   e->prev = NULL;
617:   e->next = erb;
618:
619:   /* The tree is now valid again.  Now we need to "un-tree" E.
620:      It is imperative that a non-recursive implementation is used
621:      for this, because splay trees have a worst case depth of O(N)
622:      for a tree with N nodes.  A recursive implementation could
623:      result in a stack overflow for a sufficiently large, unbalanced
624:      bitmap tree.  */
625:
626:   auto_vec<bitmap_element *, 32> stack;
627:   auto_vec<bitmap_element *, 32> sorted_elements;
628:   bitmap_element *n = e;
629:
630:   while (true)
631:     {
632:       while (n != NULL)
633: 	{
634: 	  stack.safe_push (n);
635: 	  n = n->prev;
636: 	}
637:
638:       if (stack.is_empty ())
639: 	break;
640:
641:       n = stack.pop ();
642:       sorted_elements.safe_push (n);
643:       n = n->next;
644:     }
645:
646:   gcc_assert (sorted_elements[0] == e);
647:
648:   bitmap_element *prev = NULL;
649:   unsigned ix;
650:   FOR_EACH_VEC_ELT (sorted_elements, ix, n)
651:     {
652:       if (prev != NULL)
653:         prev->next = n;
654:       n->prev = prev;
655:       n->next = NULL;
656:       prev = n;
657:     }
658:
659:   return e;
660: }
```

## gcc/bitmap.cc:732–812
```text
732: void
733: bitmap_obstack_initialize (bitmap_obstack *bit_obstack)
734: {
735:   if (!bit_obstack)
736:     {
737:       if (bitmap_default_obstack_depth++)
738: 	return;
739:       bit_obstack = &bitmap_default_obstack;
740:     }
741:
742: #if !defined(__GNUC__) || (__GNUC__ < 2)
743: #define __alignof__(type) 0
744: #endif
745:
746:   bit_obstack->elements = NULL;
747:   bit_obstack->heads = NULL;
748:   obstack_specify_allocation (&bit_obstack->obstack, OBSTACK_CHUNK_SIZE,
749: 			      __alignof__ (bitmap_element),
750: 			      obstack_chunk_alloc,
751: 			      obstack_chunk_free);
752: }
753:
754: /* Release the memory from a bitmap obstack.  If BIT_OBSTACK is NULL,
755:    release the default bitmap obstack.  */
756:
757: void
758: bitmap_obstack_release (bitmap_obstack *bit_obstack)
759: {
760:   if (!bit_obstack)
761:     {
762:       if (--bitmap_default_obstack_depth)
763: 	{
764: 	  gcc_assert (bitmap_default_obstack_depth > 0);
765: 	  return;
766: 	}
767:       bit_obstack = &bitmap_default_obstack;
768:     }
769:
770:   bit_obstack->elements = NULL;
771:   bit_obstack->heads = NULL;
772:   obstack_free (&bit_obstack->obstack, NULL);
773: }
774:
775: /* Create a new bitmap on an obstack.  If BIT_OBSTACK is NULL, create
776:    it on the default bitmap obstack.  */
777:
778: bitmap
779: bitmap_alloc (bitmap_obstack *bit_obstack MEM_STAT_DECL)
780: {
781:   bitmap map;
782:
783:   if (!bit_obstack)
784:     {
785:       gcc_assert (bitmap_default_obstack_depth > 0);
786:       bit_obstack = &bitmap_default_obstack;
787:     }
788:   map = bit_obstack->heads;
789:   if (map)
790:     bit_obstack->heads = (class bitmap_head *) map->first;
791:   else
792:     map = XOBNEW (&bit_obstack->obstack, bitmap_head);
793:   bitmap_initialize (map, bit_obstack PASS_MEM_STAT);
794:
795:   if (GATHER_STATISTICS)
796:     register_overhead (map, sizeof (bitmap_head));
797:
798:   return map;
799: }
800:
801: /* Create a new GCd bitmap.  */
802:
803: bitmap
804: bitmap_gc_alloc (ALONE_MEM_STAT_DECL)
805: {
806:   bitmap map;
807:
808:   map = ggc_alloc<bitmap_head> ();
809:   bitmap_initialize (map, NULL PASS_MEM_STAT);
810:
811:   if (GATHER_STATISTICS)
812:     register_overhead (map, sizeof (bitmap_head));
```

## gcc/bitmap.cc:1116–1147
```text
1116: bitmap_count_bits_in_word (const BITMAP_WORD *bits)
1117: {
1118:   unsigned long count = 0;
1119:
1120:   for (unsigned ix = 0; ix != BITMAP_ELEMENT_WORDS; ix++)
1121:     {
1122: #if GCC_VERSION >= 3400
1123:       /* Note that popcountl matches BITMAP_WORD in type, so the actual size
1124: 	 of BITMAP_WORD is not material.  */
1125:       count += __builtin_popcountl (bits[ix]);
1126: #else
1127:       count += bitmap_popcount (bits[ix]);
1128: #endif
1129:     }
1130:   return count;
1131: }
1132:
1133: /* Count the number of bits set in the bitmap, and return it.  */
1134:
1135: unsigned long
1136: bitmap_count_bits (const_bitmap a)
1137: {
1138:   unsigned long count = 0;
1139:   const bitmap_element *elt;
1140:
1141:   gcc_checking_assert (!a->tree_form);
1142:   for (elt = a->first; elt; elt = elt->next)
1143:     count += bitmap_count_bits_in_word (elt->bits);
1144:
1145:   return count;
1146: }
1147:
```

## gcc/bitmap.cc:1520–1616
```text
1520: bitmap_and_compl (bitmap dst, const_bitmap a, const_bitmap b)
1521: {
1522:   bitmap_element *dst_elt = dst->first;
1523:   const bitmap_element *a_elt = a->first;
1524:   const bitmap_element *b_elt = b->first;
1525:   bitmap_element *dst_prev = NULL;
1526:   bitmap_element **dst_prev_pnext = &dst->first;
1527:   bool changed = false;
1528:
1529:   gcc_checking_assert (!dst->tree_form && !a->tree_form && !b->tree_form);
1530:   gcc_assert (dst != a && dst != b);
1531:
1532:   if (a == b)
1533:     {
1534:       changed = !bitmap_empty_p (dst);
1535:       bitmap_clear (dst);
1536:       return changed;
1537:     }
1538:
1539:   while (a_elt)
1540:     {
1541:       while (b_elt && b_elt->indx < a_elt->indx)
1542: 	b_elt = b_elt->next;
1543:
1544:       if (!b_elt || b_elt->indx > a_elt->indx)
1545: 	{
1546: 	  changed = bitmap_elt_copy (dst, dst_elt, dst_prev, a_elt, changed);
1547: 	  dst_prev = *dst_prev_pnext;
1548: 	  dst_prev_pnext = &dst_prev->next;
1549: 	  dst_elt = *dst_prev_pnext;
1550: 	  a_elt = a_elt->next;
1551: 	}
1552:
1553:       else
1554: 	{
1555: 	  /* Matching elts, generate A & ~B.  */
1556: 	  unsigned ix;
1557: 	  BITMAP_WORD ior = 0;
1558:
1559: 	  if (!changed && dst_elt && dst_elt->indx == a_elt->indx)
1560: 	    {
1561: 	      for (ix = 0; ix < BITMAP_ELEMENT_WORDS; ix++)
1562: 		{
1563: 		  BITMAP_WORD r = a_elt->bits[ix] & ~b_elt->bits[ix];
1564:
1565: 		  if (dst_elt->bits[ix] != r)
1566: 		    {
1567: 		      changed = true;
1568: 		      dst_elt->bits[ix] = r;
1569: 		    }
1570: 		  ior |= r;
1571: 		}
1572: 	    }
1573: 	  else
1574: 	    {
1575: 	      bool new_element;
1576: 	      if (!dst_elt || dst_elt->indx > a_elt->indx)
1577: 		{
1578: 		  dst_elt = bitmap_list_insert_element_after (dst, dst_prev,
1579: 							      a_elt->indx);
1580: 		  new_element = true;
1581: 		}
1582: 	      else
1583: 		{
1584: 		  dst_elt->indx = a_elt->indx;
1585: 		  new_element = false;
1586: 		}
1587:
1588: 	      for (ix = 0; ix < BITMAP_ELEMENT_WORDS; ix++)
1589: 		{
1590: 		  BITMAP_WORD r = a_elt->bits[ix] & ~b_elt->bits[ix];
1591:
1592: 		  dst_elt->bits[ix] = r;
1593: 		  ior |= r;
1594: 		}
1595:
1596: 	      if (ior)
1597: 	        changed = true;
1598: 	      else
1599: 	        {
1600: 	          changed |= !new_element;
1601: 		  bitmap_list_unlink_element (dst, dst_elt);
1602: 		  dst_elt = *dst_prev_pnext;
1603: 		}
1604: 	    }
1605:
1606: 	  if (ior)
1607: 	    {
1608: 	      dst_prev = *dst_prev_pnext;
1609: 	      dst_prev_pnext = &dst_prev->next;
1610: 	      dst_elt = *dst_prev_pnext;
1611: 	    }
1612: 	  a_elt = a_elt->next;
1613: 	  b_elt = b_elt->next;
1614: 	}
1615:     }
1616:
```

## gcc/bitmap.cc:1690–1820
```text
1690: bitmap_set_range (bitmap head, unsigned int start, unsigned int count)
1691: {
1692:   unsigned int first_index, end_bit_plus1, last_index;
1693:   bitmap_element *elt, *elt_prev;
1694:   unsigned int i;
1695:
1696:   gcc_checking_assert (!head->tree_form);
1697:
1698:   if (!count)
1699:     return;
1700:
1701:   if (count == 1)
1702:     {
1703:       bitmap_set_bit (head, start);
1704:       return;
1705:     }
1706:
1707:   first_index = start / BITMAP_ELEMENT_ALL_BITS;
1708:   end_bit_plus1 = start + count;
1709:   last_index = (end_bit_plus1 - 1) / BITMAP_ELEMENT_ALL_BITS;
1710:   elt = bitmap_list_find_element (head, first_index);
1711:
1712:   /* If bitmap_list_find_element returns zero, the current is the closest block
1713:      to the result.  Otherwise, just use bitmap_element_allocate to
1714:      ensure ELT is set; in the loop below, ELT == NULL means "insert
1715:      at the end of the bitmap".  */
1716:   if (!elt)
1717:     {
1718:       elt = bitmap_element_allocate (head);
1719:       elt->indx = first_index;
1720:       bitmap_list_link_element (head, elt);
1721:     }
1722:
1723:   gcc_checking_assert (elt->indx == first_index);
1724:   elt_prev = elt->prev;
1725:   for (i = first_index; i <= last_index; i++)
1726:     {
1727:       unsigned elt_start_bit = i * BITMAP_ELEMENT_ALL_BITS;
1728:       unsigned elt_end_bit_plus1 = elt_start_bit + BITMAP_ELEMENT_ALL_BITS;
1729:
1730:       unsigned int first_word_to_mod;
1731:       BITMAP_WORD first_mask;
1732:       unsigned int last_word_to_mod;
1733:       BITMAP_WORD last_mask;
1734:       unsigned int ix;
1735:
1736:       if (!elt || elt->indx != i)
1737: 	elt = bitmap_list_insert_element_after (head, elt_prev, i);
1738:
1739:       if (elt_start_bit <= start)
1740: 	{
1741: 	  /* The first bit to turn on is somewhere inside this
1742: 	     elt.  */
1743: 	  first_word_to_mod = (start - elt_start_bit) / BITMAP_WORD_BITS;
1744:
1745: 	  /* This mask should have 1s in all bits >= start position. */
1746: 	  first_mask =
1747: 	    (((BITMAP_WORD) 1) << ((start % BITMAP_WORD_BITS))) - 1;
1748: 	  first_mask = ~first_mask;
1749: 	}
1750:       else
1751: 	{
1752: 	  /* The first bit to turn on is below this start of this elt.  */
1753: 	  first_word_to_mod = 0;
1754: 	  first_mask = ~(BITMAP_WORD) 0;
1755: 	}
1756:
1757:       if (elt_end_bit_plus1 <= end_bit_plus1)
1758: 	{
1759: 	  /* The last bit to turn on is beyond this elt.  */
1760: 	  last_word_to_mod = BITMAP_ELEMENT_WORDS - 1;
1761: 	  last_mask = ~(BITMAP_WORD) 0;
1762: 	}
1763:       else
1764: 	{
1765: 	  /* The last bit to turn on is inside to this elt.  */
1766: 	  last_word_to_mod =
1767: 	    (end_bit_plus1 - elt_start_bit) / BITMAP_WORD_BITS;
1768:
1769: 	  /* The last mask should have 1s below the end bit.  */
1770: 	  last_mask =
1771: 	    (((BITMAP_WORD) 1) << ((end_bit_plus1 % BITMAP_WORD_BITS))) - 1;
1772: 	}
1773:
1774:       if (first_word_to_mod == last_word_to_mod)
1775: 	{
1776: 	  BITMAP_WORD mask = first_mask & last_mask;
1777: 	  elt->bits[first_word_to_mod] |= mask;
1778: 	}
1779:       else
1780: 	{
1781: 	  elt->bits[first_word_to_mod] |= first_mask;
1782: 	  if (BITMAP_ELEMENT_WORDS > 2)
1783: 	    for (ix = first_word_to_mod + 1; ix < last_word_to_mod; ix++)
1784: 	      elt->bits[ix] = ~(BITMAP_WORD) 0;
1785: 	  elt->bits[last_word_to_mod] |= last_mask;
1786: 	}
1787:
1788:       elt_prev = elt;
1789:       elt = elt->next;
1790:     }
1791:
1792:   head->current = elt ? elt : elt_prev;
1793:   head->indx = head->current->indx;
1794: }
1795:
1796: /* Clear COUNT bits from START in HEAD.  */
1797: void
1798: bitmap_clear_range (bitmap head, unsigned int start, unsigned int count)
1799: {
1800:   unsigned int first_index, end_bit_plus1, last_index;
1801:   bitmap_element *elt;
1802:
1803:   gcc_checking_assert (!head->tree_form);
1804:
1805:   if (!count)
1806:     return;
1807:
1808:   if (count == 1)
1809:     {
1810:       bitmap_clear_bit (head, start);
1811:       return;
1812:     }
1813:
1814:   first_index = start / BITMAP_ELEMENT_ALL_BITS;
1815:   end_bit_plus1 = start + count;
1816:   last_index = (end_bit_plus1 - 1) / BITMAP_ELEMENT_ALL_BITS;
1817:   elt = bitmap_list_find_element (head, first_index);
1818:
1819:   /* If bitmap_list_find_element returns zero, the current is the closest block
1820:      to the result.  If the current is less than first index, find the
```

## gcc/bitmap.cc:2540–2562
```text
2540: bitmap_ior_and_compl_into (bitmap a, const_bitmap b, const_bitmap c)
2541: {
2542:   bitmap_element *a_elt = a->first;
2543:   const bitmap_element *b_elt = b->first;
2544:   const bitmap_element *c_elt = c->first;
2545:   bitmap_element and_elt;
2546:   bitmap_element *a_prev = NULL;
2547:   bitmap_element **a_prev_pnext = &a->first;
2548:   bool changed = false;
2549:   unsigned ix;
2550:
2551:   gcc_checking_assert (!a->tree_form && !b->tree_form && !c->tree_form);
2552:
2553:   if (a == b)
2554:     return false;
2555:   if (bitmap_empty_p (c))
2556:     return bitmap_ior_into (a, b);
2557:   else if (bitmap_empty_p (a))
2558:     return bitmap_and_compl (a, b, c);
2559:
2560:   and_elt.indx = -1;
2561:   while (b_elt)
2562:     {
```

## gcc/sbitmap.h:75–139
```text
75:    This set representation works well for relatively small data flow problems
76:    (there are special routines for that, see sbitmap_vector_*).  The set
77:    operations can be vectorized and there is almost no computating overhead,
78:    so that even sparse simple bitmap sets outperform dedicated sparse set
79:    representations like linked-list bitmaps.  For larger problems, the size
80:    overhead of simple bitmap sets gets too high and other set representations
81:    have to be used.  */
82:
83: #define SBITMAP_ELT_BITS (HOST_BITS_PER_WIDEST_FAST_INT * 1u)
84: #define SBITMAP_ELT_TYPE unsigned HOST_WIDEST_FAST_INT
85:
86: struct simple_bitmap_def
87: {
88:   unsigned int n_bits;		/* Number of bits.  */
89:   unsigned int size;		/* Size in elements.  */
90:   SBITMAP_ELT_TYPE elms[1];	/* The elements.  */
91: };
92:
93: /* Return the set size needed for N elements.  */
94: #define SBITMAP_SET_SIZE(N) (((N) + SBITMAP_ELT_BITS - 1) / SBITMAP_ELT_BITS)
95:
96: /* Return the number of bits in BITMAP.  */
97: #define SBITMAP_SIZE(BITMAP) ((BITMAP)->n_bits)
98:
99: /* Verify that access at INDEX in bitmap MAP is valid.  */
100:
101: inline void
102: bitmap_check_index (const_sbitmap map, int index)
103: {
104:   gcc_checking_assert (index >= 0);
105:   gcc_checking_assert ((unsigned int)index < map->n_bits);
106: }
107:
108: /* Verify that bitmaps A and B have same size.  */
109:
110: inline void
111: bitmap_check_sizes (const_sbitmap a, const_sbitmap b)
112: {
113:   gcc_checking_assert (a->n_bits == b->n_bits);
114: }
115:
116: /* Test if bit number bitno in the bitmap is set.  */
117: inline bool
118: bitmap_bit_p (const_sbitmap map, int bitno)
119: {
120:   bitmap_check_index (map, bitno);
121:
122:   size_t i = bitno / SBITMAP_ELT_BITS;
123:   unsigned int s = bitno % SBITMAP_ELT_BITS;
124:   return (map->elms[i] >> s) & (SBITMAP_ELT_TYPE) 1;
125: }
126:
127: /* Set bit number BITNO in the sbitmap MAP.
128:    Return true if the bit changed.  */
129:
130: inline bool
131: bitmap_set_bit (sbitmap map, int bitno)
132: {
133:   bitmap_check_index (map, bitno);
134:
135:   size_t i = bitno / SBITMAP_ELT_BITS;
136:   unsigned int s = bitno % SBITMAP_ELT_BITS;
137:   if (map->elms[i] & ((SBITMAP_ELT_TYPE) 1 << s))
138:     return false;
139:   map->elms[i] |= (SBITMAP_ELT_TYPE) 1 << s;
```

## gcc/sbitmap.cc:30–176
```text
30:
31: static inline unsigned int sbitmap_size_bytes (const_sbitmap map)
32: {
33:    return map->size * sizeof (SBITMAP_ELT_TYPE);
34: }
35:
36:
37: /* Bitmap manipulation routines.  */
38:
39: /* Allocate a simple bitmap of N_ELMS bits.  */
40:
41: sbitmap
42: sbitmap_alloc (unsigned int n_elms)
43: {
44:   unsigned int bytes, size, amt;
45:   sbitmap bmap;
46:
47:   size = SBITMAP_SET_SIZE (n_elms);
48:   bytes = size * sizeof (SBITMAP_ELT_TYPE);
49:   amt = (sizeof (struct simple_bitmap_def)
50: 	 + bytes - sizeof (SBITMAP_ELT_TYPE));
51:   bmap = (sbitmap) xmalloc (amt);
52:   bmap->n_bits = n_elms;
53:   bmap->size = size;
54:   return bmap;
55: }
56:
57: /* Resize a simple bitmap BMAP to N_ELMS bits.  If increasing the
58:    size of BMAP, clear the new bits to zero if the DEF argument
59:    is zero, and set them to one otherwise.  */
60:
61: sbitmap
62: sbitmap_resize (sbitmap bmap, unsigned int n_elms, int def)
63: {
64:   unsigned int bytes, size, amt;
65:   unsigned int last_bit;
66:
67:   size = SBITMAP_SET_SIZE (n_elms);
68:   bytes = size * sizeof (SBITMAP_ELT_TYPE);
69:   if (bytes > sbitmap_size_bytes (bmap))
70:     {
71:       amt = (sizeof (struct simple_bitmap_def)
72: 	    + bytes - sizeof (SBITMAP_ELT_TYPE));
73:       bmap = (sbitmap) xrealloc (bmap, amt);
74:     }
75:
76:   if (n_elms > bmap->n_bits)
77:     {
78:       if (def)
79: 	{
80: 	  memset (bmap->elms + bmap->size, -1,
81: 		  bytes - sbitmap_size_bytes (bmap));
82:
83: 	  /* Set the new bits if the original last element.  */
84: 	  last_bit = bmap->n_bits % SBITMAP_ELT_BITS;
85: 	  if (last_bit)
86: 	    bmap->elms[bmap->size - 1]
87: 	      |= ~((SBITMAP_ELT_TYPE)-1 >> (SBITMAP_ELT_BITS - last_bit));
88:
89: 	  /* Clear the unused bit in the new last element.  */
90: 	  last_bit = n_elms % SBITMAP_ELT_BITS;
91: 	  if (last_bit)
92: 	    bmap->elms[size - 1]
93: 	      &= (SBITMAP_ELT_TYPE)-1 >> (SBITMAP_ELT_BITS - last_bit);
94: 	}
95:       else
96: 	memset (bmap->elms + bmap->size, 0, bytes - sbitmap_size_bytes (bmap));
97:     }
98:   else if (n_elms < bmap->n_bits)
99:     {
100:       /* Clear the surplus bits in the last word.  */
101:       last_bit = n_elms % SBITMAP_ELT_BITS;
102:       if (last_bit)
103: 	bmap->elms[size - 1]
104: 	  &= (SBITMAP_ELT_TYPE)-1 >> (SBITMAP_ELT_BITS - last_bit);
105:     }
106:
107:   bmap->n_bits = n_elms;
108:   bmap->size = size;
109:   return bmap;
110: }
111:
112: /* Re-allocate a simple bitmap of N_ELMS bits. New storage is uninitialized.  */
113:
114: sbitmap
115: sbitmap_realloc (sbitmap src, unsigned int n_elms)
116: {
117:   unsigned int bytes, size, amt;
118:   sbitmap bmap;
119:
120:   size = SBITMAP_SET_SIZE (n_elms);
121:   bytes = size * sizeof (SBITMAP_ELT_TYPE);
122:   amt = (sizeof (struct simple_bitmap_def)
123: 	 + bytes - sizeof (SBITMAP_ELT_TYPE));
124:
125:   if (sbitmap_size_bytes (src)  >= bytes)
126:     {
127:       src->n_bits = n_elms;
128:       return src;
129:     }
130:
131:   bmap = (sbitmap) xrealloc (src, amt);
132:   bmap->n_bits = n_elms;
133:   bmap->size = size;
134:   return bmap;
135: }
136:
137: /* Allocate a vector of N_VECS bitmaps of N_ELMS bits.  */
138:
139: sbitmap *
140: sbitmap_vector_alloc (unsigned int n_vecs, unsigned int n_elms)
141: {
142:   unsigned int i, size;
143:   size_t amt, bytes, vector_bytes, elm_bytes, offset;
144:   sbitmap *bitmap_vector;
145:
146:   size = SBITMAP_SET_SIZE (n_elms);
147:   bytes = size * sizeof (SBITMAP_ELT_TYPE);
148:   elm_bytes = (sizeof (struct simple_bitmap_def)
149: 	       + bytes - sizeof (SBITMAP_ELT_TYPE));
150:   vector_bytes = n_vecs * sizeof (sbitmap *);
151:
152:   /* Round up `vector_bytes' to account for the alignment requirements
153:      of an sbitmap.  One could allocate the vector-table and set of sbitmaps
154:      separately, but that requires maintaining two pointers or creating
155:      a cover struct to hold both pointers (so our result is still just
156:      one pointer).  Neither is a bad idea, but this is simpler for now.  */
157:   {
158:     /* Based on DEFAULT_ALIGNMENT computation in obstack.c.  */
159:     struct { char x; SBITMAP_ELT_TYPE y; } align;
160:     int alignment = (char *) & align.y - & align.x;
161:     vector_bytes = (vector_bytes + alignment - 1) & ~ (alignment - 1);
162:   }
163:
164:   amt = vector_bytes + (n_vecs * elm_bytes);
165:   bitmap_vector = (sbitmap *) xmalloc (amt);
166:
167:   for (i = 0, offset = vector_bytes; i < n_vecs; i++, offset += elm_bytes)
168:     {
169:       sbitmap b = (sbitmap) ((char *) bitmap_vector + offset);
170:
171:       bitmap_vector[i] = b;
172:       b->n_bits = n_elms;
173:       b->size = size;
174:     }
175:
176:   return bitmap_vector;
```

## gcc/memory-block.h:26–82
```text
26: class memory_block_pool
27: {
28: public:
29:   /* Blocks have fixed size.  This is necessary for sharing.  */
30:   static const size_t block_size = 64 * 1024;
31:   /* Number of blocks we keep in the freelists.  */
32:   static const size_t freelist_size = 1024 * 1024 / block_size;
33:
34:   memory_block_pool ();
35:
36:   static inline void *allocate () ATTRIBUTE_MALLOC;
37:   static inline void release (void *);
38:   static void trim (int nblocks = freelist_size);
39:   void reduce_free_list (int);
40:
41: private:
42:   /* memory_block_pool singleton instance, defined in memory-block.cc.  */
43:   static memory_block_pool instance;
44:
45:   struct block_list
46:   {
47:     block_list *m_next;
48:   };
49:
50:   /* Free list.  */
51:   block_list *m_blocks;
52: };
53:
54: /* Allocate a single block.  Reuse a previously returned block, if possible.  */
55: inline void *
56: memory_block_pool::allocate ()
57: {
58:   if (instance.m_blocks == NULL)
59:     return XNEWVEC (char, block_size);
60:
61:   void *result = instance.m_blocks;
62:   instance.m_blocks = instance.m_blocks->m_next;
63:   VALGRIND_DISCARD (VALGRIND_MAKE_MEM_UNDEFINED (result, block_size));
64:   return result;
65: }
66:
67: /* Return UNCAST_BLOCK to the pool.  */
68: inline void
69: memory_block_pool::release (void *uncast_block)
70: {
71:   block_list *block = new (uncast_block) block_list;
72:   block->m_next = instance.m_blocks;
73:   instance.m_blocks = block;
74:
75:   VALGRIND_DISCARD (VALGRIND_MAKE_MEM_NOACCESS ((char *)uncast_block
76: 						+ sizeof (block_list),
77: 						block_size
78: 						- sizeof (block_list)));
79: }
80:
81: extern void *mempool_obstack_chunk_alloc (size_t) ATTRIBUTE_MALLOC;
82: extern void mempool_obstack_chunk_free (void *);
```

## gcc/memory-block.cc:33–77
```text
33: memory_block_pool::reduce_free_list (int num)
34: {
35:   block_list **blocks = &m_blocks;
36:
37:   /* First skip NUM blocks.  */
38:
39:   for (;num > 0 && *blocks; num--)
40:     blocks = &(*blocks)->m_next;
41:
42:   if (!*blocks)
43:     return;
44:
45:   /* And free the remainder of them.  */
46:
47:   block_list *to_free = *blocks;
48:   *blocks = NULL;
49:
50:   while (to_free)
51:     {
52:       block_list *next = to_free->m_next;
53:       XDELETEVEC (to_free);
54:       to_free = next;
55:     }
56: }
57:
58: /* Allocate a chunk for obstack.  Use the pool if requested chunk size matches
59:    the size of blocks in the pool.  */
60: void *
61: mempool_obstack_chunk_alloc (size_t size)
62: {
63:   if (size == memory_block_pool::block_size)
64:     return memory_block_pool::allocate ();
65:   else
66:     return XNEWVEC (char, size);
67: }
68:
69: /* Free previously allocated obstack chunk.  */
70: void
71: mempool_obstack_chunk_free (void *chunk)
72: {
73:   size_t size = (reinterpret_cast<_obstack_chunk *> (chunk)->limit
74: 		 - reinterpret_cast<char *> (chunk));
75:   if (size == memory_block_pool::block_size)
76:     memory_block_pool::release (chunk);
77:   else
```

## include/obstack.h:108–136
```text
108: # define _OBSTACK_INTERFACE_VERSION 2
109: #endif
110:
111: #include <stddef.h>             /* For size_t and ptrdiff_t.  */
112: #include <string.h>             /* For __GNU_LIBRARY__, and memcpy.  */
113:
114: #if _OBSTACK_INTERFACE_VERSION == 1
115: /* For binary compatibility with obstack version 1, which used "int"
116:    and "long" for these two types.  */
117: # define _OBSTACK_SIZE_T unsigned int
118: # define _CHUNK_SIZE_T unsigned long
119: # define _OBSTACK_CAST(type, expr) ((type) (expr))
120: #else
121: /* Version 2 with sane types, especially for 64-bit hosts.  */
122: # define _OBSTACK_SIZE_T size_t
123: # define _CHUNK_SIZE_T size_t
124: # define _OBSTACK_CAST(type, expr) (expr)
125: #endif
126:
127: /* If B is the base of an object addressed by P, return the result of
128:    aligning P to the next multiple of A + 1.  B and P must be of type
129:    char *.  A + 1 must be a power of 2.  */
130:
131: #define __BPTR_ALIGN(B, P, A) ((B) + (((P) - (B) + (A)) & ~(A)))
132:
133: /* Similar to __BPTR_ALIGN (B, P, A), except optimize the common case
134:    where pointers can be converted to integers, aligned as integers,
135:    and converted back again.  If ptrdiff_t is narrower than a
136:    pointer (e.g., the AS/400), play it safe and compute the alignment
```

## include/obstack.h:373–421
```text
373:        (void) 0; })
374:
375: # define obstack_blank(OBSTACK, length)					      \
376:   __extension__								      \
377:     ({ struct obstack *__o = (OBSTACK);					      \
378:        _OBSTACK_SIZE_T __len = (length);				      \
379:        if (obstack_room (__o) < __len)					      \
380:          _obstack_newchunk (__o, __len);				      \
381:        obstack_blank_fast (__o, __len); })
382:
383: # define obstack_alloc(OBSTACK, length)					      \
384:   __extension__								      \
385:     ({ struct obstack *__h = (OBSTACK);					      \
386:        obstack_blank (__h, (length));					      \
387:        obstack_finish (__h); })
388:
389: # define obstack_copy(OBSTACK, where, length)				      \
390:   __extension__								      \
391:     ({ struct obstack *__h = (OBSTACK);					      \
392:        obstack_grow (__h, (where), (length));				      \
393:        obstack_finish (__h); })
394:
395: # define obstack_copy0(OBSTACK, where, length)				      \
396:   __extension__								      \
397:     ({ struct obstack *__h = (OBSTACK);					      \
398:        obstack_grow0 (__h, (where), (length));				      \
399:        obstack_finish (__h); })
400:
401: /* The local variable is named __o1 to avoid a shadowed variable
402:    warning when invoked from other obstack macros, typically obstack_free.  */
403: # define obstack_finish(OBSTACK)					      \
404:   __extension__								      \
405:     ({ struct obstack *__o1 = (OBSTACK);				      \
406:        void *__value = (void *) __o1->object_base;			      \
407:        if (__o1->next_free == __value)					      \
408:          __o1->maybe_empty_object = 1;					      \
409:        __o1->next_free							      \
410:          = __PTR_ALIGN (__o1->object_base, __o1->next_free,		      \
411:                         __o1->alignment_mask);				      \
412:        if ((size_t) (__o1->next_free - (char *) __o1->chunk)		      \
413:            > (size_t) (__o1->chunk_limit - (char *) __o1->chunk))	      \
414:          __o1->next_free = __o1->chunk_limit;				      \
415:        __o1->object_base = __o1->next_free;				      \
416:        __value; })
417:
418: # define obstack_free(OBSTACK, OBJ)					      \
419:   __extension__								      \
420:     ({ struct obstack *__o = (OBSTACK);					      \
421:        void *__obj = (void *) (OBJ);					      \
```

## libiberty/obstack.c:115–150
```text
115:                        _OBSTACK_SIZE_T size, _OBSTACK_SIZE_T alignment)
116: {
117:   struct _obstack_chunk *chunk; /* points to new chunk */
118:
119:   if (alignment == 0)
120:     alignment = DEFAULT_ALIGNMENT;
121:   if (size == 0)
122:     /* Default size is what GNU malloc can fit in a 4096-byte block.  */
123:     {
124:       /* 12 is sizeof (mhead) and 4 is EXTRA from GNU malloc.
125:          Use the values for range checking, because if range checking is off,
126:          the extra bytes won't be missed terribly, but if range checking is on
127:          and we used a larger request, a whole extra 4096 bytes would be
128:          allocated.
129:
130:          These number are irrelevant to the new GNU malloc.  I suspect it is
131:          less sensitive to the size of the request.  */
132:       int extra = ((((12 + DEFAULT_ROUNDING - 1) & ~(DEFAULT_ROUNDING - 1))
133:                     + 4 + DEFAULT_ROUNDING - 1)
134:                    & ~(DEFAULT_ROUNDING - 1));
135:       size = 4096 - extra;
136:     }
137:
138:   h->chunk_size = size;
139:   h->alignment_mask = alignment - 1;
140:
141:   chunk = (struct _obstack_chunk *) call_chunkfun (h, h->chunk_size);
142:   if (!chunk)
143:     (*obstack_alloc_failed_handler) ();
144:   h->chunk = chunk;
145:   h->next_free = h->object_base = __PTR_ALIGN ((char *) chunk, chunk->contents,
146:                                                alignment - 1);
147:   h->chunk_limit = chunk->limit = (char *) chunk + h->chunk_size;
148:   chunk->prev = 0;
149:   /* The initial chunk now contains no empty object.  */
150:   h->maybe_empty_object = 0;
```

## libiberty/obstack.c:188–235
```text
188: _obstack_newchunk (struct obstack *h, _OBSTACK_SIZE_T length)
189: {
190:   struct _obstack_chunk *old_chunk = h->chunk;
191:   struct _obstack_chunk *new_chunk = 0;
192:   size_t obj_size = h->next_free - h->object_base;
193:   char *object_base;
194:
195:   /* Compute size for new chunk.  */
196:   size_t sum1 = obj_size + length;
197:   size_t sum2 = sum1 + h->alignment_mask;
198:   size_t new_size = sum2 + (obj_size >> 3) + 100;
199:   if (new_size < sum2)
200:     new_size = sum2;
201:   if (new_size < h->chunk_size)
202:     new_size = h->chunk_size;
203:
204:   /* Allocate and initialize the new chunk.  */
205:   if (obj_size <= sum1 && sum1 <= sum2)
206:     new_chunk = (struct _obstack_chunk *) call_chunkfun (h, new_size);
207:   if (!new_chunk)
208:     (*obstack_alloc_failed_handler)();
209:   h->chunk = new_chunk;
210:   new_chunk->prev = old_chunk;
211:   new_chunk->limit = h->chunk_limit = (char *) new_chunk + new_size;
212:
213:   /* Compute an aligned object_base in the new chunk */
214:   object_base =
215:     __PTR_ALIGN ((char *) new_chunk, new_chunk->contents, h->alignment_mask);
216:
217:   /* Move the existing object to the new chunk.  */
218:   memcpy (object_base, h->object_base, obj_size);
219:
220:   /* If the object just copied was the only data in OLD_CHUNK,
221:      free that chunk and remove it from the chain.
222:      But not if that chunk might contain an empty object.  */
223:   if (!h->maybe_empty_object
224:       && (h->object_base
225:           == __PTR_ALIGN ((char *) old_chunk, old_chunk->contents,
226:                           h->alignment_mask)))
227:     {
228:       new_chunk->prev = old_chunk->prev;
229:       call_freefun (h, old_chunk);
230:     }
231:
232:   h->object_base = object_base;
233:   h->next_free = h->object_base + obj_size;
234:   /* The new chunk certainly contains no empty object yet.  */
235:   h->maybe_empty_object = 0;
```

## gcc/hwint.h:139–156
```text
139: /* Define HOST_WIDEST_FAST_INT to the widest integer type supported
140:    efficiently in hardware.  (That is, the widest integer type that fits
141:    in a hardware register.)  Normally this is "long" but on some hosts it
142:    should be "long long" or "__int64".  This is no convenient way to
143:    autodetect this, so such systems must set a flag in config.host; see there
144:    for details.  */
145:
146: #ifdef USE_LONG_LONG_FOR_WIDEST_FAST_INT
147: #  ifdef HAVE_LONG_LONG
148: #    define HOST_WIDEST_FAST_INT long long
149: #    define HOST_BITS_PER_WIDEST_FAST_INT HOST_BITS_PER_LONGLONG
150: #  else
151: #    error "Your host said it wanted to use long long but that does not exist"
152: #  endif
153: #else
154: #  define HOST_WIDEST_FAST_INT long
155: #  define HOST_BITS_PER_WIDEST_FAST_INT HOST_BITS_PER_LONG
156: #endif
```

## gcc/ada/gcc-interface/cuintp.cc:163–213
```text
163: }
164:
165: /* Similar to UI_From_Int, but take a GCC INTEGER_CST.  We use UI_From_Int
166:    when possible, i.e. for a 32-bit signed value, to take advantage of its
167:    built-in caching mechanism.  For values of larger magnitude, we compute
168:    digits into a vector and call Vector_To_Uint.  */
169:
170: Uint
171: UI_From_gnu (tree Input)
172: {
173:   tree gnu_type = TREE_TYPE (Input), gnu_base, gnu_temp;
174:   /* UI_Base is defined so that 5 Uint digits is sufficient to hold the
175:      largest possible signed 64-bit value.  */
176:   const int Max_For_Dint = 5;
177:   int v[Max_For_Dint];
178:   Vector_Template temp;
179:   Int_Vector vec;
180:
181: #if HOST_BITS_PER_WIDE_INT < 64
182: #error unsupported HOST_BITS_PER_WIDE_INT setting
183: #endif
184:
185:   /* On 64-bit hosts, tree_fits_shwi_p tells whether the input fits in
186:      a signed 64-bit integer.  Then a truncation tells whether it fits
187:      in a signed 32-bit integer.  */
188:   if (tree_fits_shwi_p (Input))
189:     {
190:       HOST_WIDE_INT hw_input = tree_to_shwi (Input);
191:       if (hw_input == (int) hw_input)
192: 	return UI_From_Int (hw_input);
193:     }
194:   else
195:     return No_Uint;
196:
197:   gnu_base = build_int_cst (gnu_type, UI_Base);
198:   gnu_temp = Input;
199:
200:   for (int i = Max_For_Dint - 1; i >= 0; i--)
201:     {
202:       v[i] = tree_to_shwi (fold_build1 (ABS_EXPR, gnu_type,
203: 					fold_build2 (TRUNC_MOD_EXPR, gnu_type,
204: 						     gnu_temp, gnu_base)));
205:       gnu_temp = fold_build2 (TRUNC_DIV_EXPR, gnu_type, gnu_temp, gnu_base);
206:     }
207:
208:   temp.Low_Bound = 1;
209:   temp.High_Bound = Max_For_Dint;
210:   vec.Bounds = &temp;
211:   vec.Array = v;
212:   return Vector_To_Uint (vec, tree_int_cst_sgn (Input) < 0);
213: }
```

## gcc/ada/repinfo.adb:55–97
```text
55: with GNAT.HTable;
56:
57: package body Repinfo is
58:
59:    SSU : Pos renames Ttypes.System_Storage_Unit;
60:    --  Value for Storage_Unit
61:
62:    ---------------------------------------
63:    -- Representation of GCC Expressions --
64:    ---------------------------------------
65:
66:    --    A table internal to this unit is used to hold the values of back
67:    --    annotated expressions.
68:
69:    --    Node values are stored as Uint values using the negative of the node
70:    --    index in this table. Constants appear as non-negative Uint values.
71:
72:    type Exp_Node is record
73:       Expr : TCode;
74:       Op1  : Node_Ref_Or_Val;
75:       Op2  : Node_Ref_Or_Val;
76:       Op3  : Node_Ref_Or_Val;
77:    end record;
78:
79:    package Rep_Table is new Table.Table (
80:       Table_Component_Type => Exp_Node,
81:       Table_Index_Type     => Nat,
82:       Table_Low_Bound      => 1,
83:       Table_Initial        => Alloc.Rep_Table_Initial,
84:       Table_Increment      => Alloc.Rep_Table_Increment,
85:       Table_Name           => "BE_Rep_Table");
86:
87:    --------------------------------------------------------------
88:    -- Representation of Front-End Dynamic Size/Offset Entities --
89:    --------------------------------------------------------------
90:
91:    package Dynamic_SO_Entity_Table is new Table.Table (
92:       Table_Component_Type => Entity_Id,
93:       Table_Index_Type     => Nat,
94:       Table_Low_Bound      => 1,
95:       Table_Initial        => Alloc.Rep_Table_Initial,
96:       Table_Increment      => Alloc.Rep_Table_Increment,
97:       Table_Name           => "FE_Rep_Table");
```

## gcc/ada/repinfo.adb:233–246
```text
233:    function Create_Node
234:      (Expr : TCode;
235:       Op1  : Node_Ref_Or_Val;
236:       Op2  : Node_Ref_Or_Val := No_Uint;
237:       Op3  : Node_Ref_Or_Val := No_Uint) return Node_Ref
238:    is
239:    begin
240:       Rep_Table.Append (
241:         (Expr => Expr,
242:          Op1  => Op1,
243:          Op2  => Op2,
244:          Op3  => Op3));
245:       return UI_From_Int (-Rep_Table.Last);
246:    end Create_Node;
```

## gcc/ada/repinfo.ads:119–160
```text
119:    --  is set to Uint_Minus_1.
120:
121:    subtype Node_Ref is Unegative;
122:    --  Subtype used for negative Uint values used to represent nodes
123:
124:    subtype Node_Ref_Or_Val is Uint;
125:    --  Subtype used for values that can be a Node_Ref (negative) or a value
126:    --  (non-negative) or No_Uint.
127:
128:    type TCode is range 0 .. 27;
129:    --  Type used on Ada side to represent DEFTREECODE values defined in
130:    --  tree.def. Only a subset of these tree codes can actually appear.
131:    --  The names are the names from tree.def in Ada casing.
132:
133:    --  name                             code   description     operands  symbol
134:
135:    Cond_Expr        : constant TCode :=  1; -- conditional          3      ?<>
136:    Plus_Expr        : constant TCode :=  2; -- addition             2        +
137:    Minus_Expr       : constant TCode :=  3; -- subtraction          2        -
138:    Mult_Expr        : constant TCode :=  4; -- multiplication       2        *
139:    Trunc_Div_Expr   : constant TCode :=  5; -- truncating div       2       /t
140:    Ceil_Div_Expr    : constant TCode :=  6; -- div rounding up      2       /c
141:    Floor_Div_Expr   : constant TCode :=  7; -- div rounding down    2       /f
142:    Trunc_Mod_Expr   : constant TCode :=  8; -- mod for trunc_div    2     modt
143:    Ceil_Mod_Expr    : constant TCode :=  9; -- mod for ceil_div     2     modc
144:    Floor_Mod_Expr   : constant TCode := 10; -- mod for floor_div    2     modf
145:    Exact_Div_Expr   : constant TCode := 11; -- exact div            2       /e
146:    Negate_Expr      : constant TCode := 12; -- negation             1        -
147:    Min_Expr         : constant TCode := 13; -- minimum              2      min
148:    Max_Expr         : constant TCode := 14; -- maximum              2      max
149:    Abs_Expr         : constant TCode := 15; -- absolute value       1      abs
150:    Truth_And_Expr   : constant TCode := 16; -- boolean and          2      and
151:    Truth_Or_Expr    : constant TCode := 17; -- boolean or           2       or
152:    Truth_Xor_Expr   : constant TCode := 18; -- boolean xor          2      xor
153:    Truth_Not_Expr   : constant TCode := 19; -- boolean not          1      not
154:    Lt_Expr          : constant TCode := 20; -- comparison <         2        <
155:    Le_Expr          : constant TCode := 21; -- comparison <=        2       <=
156:    Gt_Expr          : constant TCode := 22; -- comparison >         2        >
157:    Ge_Expr          : constant TCode := 23; -- comparison >=        2       >=
158:    Eq_Expr          : constant TCode := 24; -- comparison =         2       ==
159:    Ne_Expr          : constant TCode := 25; -- comparison /=        2       !=
160:    Bit_And_Expr     : constant TCode := 26; -- bitwise and          2        &
```

## gcc/ada/alloc.ads:109–114
```text
109:    Pending_Instantiations_Initial   : constant := 10;         -- Inline
110:    Pending_Instantiations_Increment : constant := 100;
111:
112:    Rep_Table_Initial                : constant := 1000;       -- Repinfo
113:    Rep_Table_Increment              : constant := 200;
114:
```

## gcc/ada/uintp.adb:1466–1506
```text
1466:    function UI_From_Int (Input : Int) return Valid_Uint is
1467:       U : Uint;
1468:
1469:    begin
1470:       if Min_Direct <= Input and then Input <= Max_Direct then
1471:          return Valid_Uint (Int (Uint_Direct_Bias) + Input);
1472:       end if;
1473:
1474:       --  If already in the hash table, return entry
1475:
1476:       U := UI_Ints.Get (Input);
1477:
1478:       if Present (U) then
1479:          return U;
1480:       end if;
1481:
1482:       --  For values of larger magnitude, compute digits into a vector and call
1483:       --  Vector_To_Uint.
1484:
1485:       declare
1486:          Max_For_Int : constant := 3;
1487:          --  Base is defined so that 3 Uint digits is sufficient to hold the
1488:          --  largest possible Int value.
1489:
1490:          V : UI_Vector (1 .. Max_For_Int);
1491:
1492:          Temp_Integer : Int := Input;
1493:
1494:       begin
1495:          for J in reverse V'Range loop
1496:             V (J) := abs (Temp_Integer rem Base);
1497:             Temp_Integer := Temp_Integer / Base;
1498:          end loop;
1499:
1500:          U := Vector_To_Uint (V, Input < Int_0);
1501:          UI_Ints.Set (Input, U);
1502:          Uints_Min := Uints.Last;
1503:          Udigits_Min := Udigits.Last;
1504:          return U;
1505:       end;
1506:    end UI_From_Int;
```

## gcc/ada/uintp.adb:2361–2426
```text
2361:    function Vector_To_Uint
2362:      (In_Vec   : UI_Vector;
2363:       Negative : Boolean) return Valid_Uint
2364:    is
2365:       Size : Int;
2366:       Val  : Int;
2367:
2368:    begin
2369:       --  The vector can contain leading zeros. These are not stored in the
2370:       --  table, so loop through the vector looking for first non-zero digit
2371:
2372:       for J in In_Vec'Range loop
2373:          if In_Vec (J) /= Int_0 then
2374:
2375:             --  The length of the value is the length of the rest of the vector
2376:
2377:             Size := In_Vec'Last - J + 1;
2378:
2379:             --  One digit value can always be represented directly
2380:
2381:             if Size = Int_1 then
2382:                if Negative then
2383:                   return Valid_Uint (Int (Uint_Direct_Bias) - In_Vec (J));
2384:                else
2385:                   return Valid_Uint (Int (Uint_Direct_Bias) + In_Vec (J));
2386:                end if;
2387:
2388:             --  Positive two digit values may be in direct representation range
2389:
2390:             elsif Size = Int_2 and then not Negative then
2391:                Val := In_Vec (J) * Base + In_Vec (J + 1);
2392:
2393:                if Val <= Max_Direct then
2394:                   return Valid_Uint (Int (Uint_Direct_Bias) + Val);
2395:                end if;
2396:             end if;
2397:
2398:             --  The value is outside the direct representation range and must
2399:             --  therefore be stored in the table. Expand the table to contain
2400:             --  the count and digits. The index of the new table entry will be
2401:             --  returned as the result.
2402:
2403:             Uints.Append ((Length => Size, Loc => Udigits.Last + 1));
2404:
2405:             if Negative then
2406:                Val := -In_Vec (J);
2407:             else
2408:                Val := +In_Vec (J);
2409:             end if;
2410:
2411:             Udigits.Append (Val);
2412:
2413:             for K in 2 .. Size loop
2414:                Udigits.Append (In_Vec (J + K - 1));
2415:             end loop;
2416:
2417:             return Uints.Last;
2418:          end if;
2419:       end loop;
2420:
2421:       --  Dropped through loop only if vector contained all zeros
2422:
2423:       return Uint_0;
2424:    end Vector_To_Uint;
2425:
2426: end Uintp;
```
