# Pinned gigi structural source excerpts
Full-file SHA256 identities are in source-manifest.json; LF numbering.
Excerpts expand tabs to eight columns and trim trailing whitespace.

## gcc/ada/exp_ch6.adb:6180–6209

```text
6180:
6181:    --  Add return statement if last statement in body is not a return statement
6182:    --  (this makes things easier on Gigi which does not want to have to handle
6183:    --  a missing return).
6184:
6185:    --  Deal with possible detection of infinite recursion
6186:
6187:    --  Eliminate body completely if convention stubbed
6188:
6189:    --  Encode entity names within body, since we will not need to reference
6190:    --  these entities any longer in the front end.
6191:
6192:    --  Initialize scalar out parameters if Initialize/Normalize_Scalars
6193:
6194:    --  Reset Pure indication if any parameter has root type System.Address
6195:    --  or has any parameters of limited types, where limited means that the
6196:    --  run-time view is limited (i.e. the full type is limited).
6197:
6198:    --  Apply raise check
6199:
6200:    procedure Expand_N_Subprogram_Body (N : Node_Id) is
6201:       Body_Id  : constant Entity_Id  := Defining_Entity (N);
6202:       HSS      : constant Node_Id    := Handled_Statement_Sequence (N);
6203:       Loc      : constant Source_Ptr := Sloc (N);
6204:
6205:       procedure Add_Return (Spec_Id : Entity_Id; Stmts : List_Id);
6206:       --  Append a return statement to the statement sequence Stmts if the last
6207:       --  statement is not already a return or a goto statement. Note that the
6208:       --  latter test is not critical, it does not matter if we add a few extra
6209:       --  returns, since they get eliminated anyway later on. Spec_Id denotes
```

## gcc/ada/exp_ch6.adb:6224–6290

```text
6224:       procedure Add_Return (Spec_Id : Entity_Id; Stmts : List_Id) is
6225:          Last_Stmt : Node_Id;
6226:          Loc       : Source_Ptr;
6227:          Stmt      : Node_Id;
6228:
6229:       begin
6230:          --  Get last statement, ignoring any Pop_xxx_Label nodes, which are
6231:          --  not relevant in this context since they are not executable.
6232:
6233:          Last_Stmt := Last (Stmts);
6234:          while Nkind (Last_Stmt) in N_Pop_xxx_Label loop
6235:             Prev (Last_Stmt);
6236:          end loop;
6237:
6238:          --  Now insert return unless last statement is a transfer
6239:
6240:          if not Is_Transfer (Last_Stmt) then
6241:
6242:             --  The source location for the return is the end label of the
6243:             --  procedure if present. Otherwise use the sloc of the last
6244:             --  statement in the list. If the list comes from a generated
6245:             --  exception handler and we are not debugging generated code,
6246:             --  all the statements within the handler are made invisible
6247:             --  to the debugger.
6248:
6249:             if Nkind (Parent (Stmts)) = N_Exception_Handler
6250:               and then not Comes_From_Source (Parent (Stmts))
6251:             then
6252:                Loc := Sloc (Last_Stmt);
6253:             elsif Present (End_Label (HSS)) then
6254:                Loc := Sloc (End_Label (HSS));
6255:             else
6256:                Loc := Sloc (Last_Stmt);
6257:             end if;
6258:
6259:             --  Append return statement, and set analyzed manually. We can't
6260:             --  call Analyze on this return since the scope is wrong.
6261:
6262:             --  Note: it almost works to push the scope and then do the Analyze
6263:             --  call, but something goes wrong in some weird cases and it is
6264:             --  not worth worrying about ???
6265:
6266:             Stmt := Make_Simple_Return_Statement (Loc);
6267:
6268:             --  The return statement is handled properly, and the call to the
6269:             --  postcondition, inserted below, does not require information
6270:             --  from the body either. However, that call is analyzed in the
6271:             --  enclosing scope, and an elaboration check might improperly be
6272:             --  added to it. A guard in Sem_Elab is needed to prevent that
6273:             --  spurious check, see Check_Elab_Call.
6274:
6275:             Append_To (Stmts, Stmt);
6276:             Set_Analyzed (Stmt);
6277:
6278:             --  Ada 2022 (AI12-0279): append the call to 'Yield unless this is
6279:             --  a generic subprogram (since in such case it will be added to
6280:             --  the instantiations).
6281:
6282:             if Has_Yield_Aspect (Spec_Id)
6283:               and then Ekind (Spec_Id) /= E_Generic_Procedure
6284:               and then RTE_Available (RE_Yield)
6285:             then
6286:                Insert_Action (Stmt,
6287:                  Make_Procedure_Call_Statement (Loc,
6288:                    New_Occurrence_Of (RTE (RE_Yield), Loc)));
6289:             end if;
6290:          end if;
```

## gcc/ada/exp_ch6.adb:6734–6745

```text
6734:       --  For a procedure, we add a return for all possible syntactic ends of
6735:       --  the subprogram.
6736:
6737:       if Ekind (Spec_Id) in E_Procedure | E_Generic_Procedure then
6738:          Add_Return (Spec_Id, Statements (HSS));
6739:
6740:          if Present (Exception_Handlers (HSS)) then
6741:             Except_H := First_Non_Pragma (Exception_Handlers (HSS));
6742:             while Present (Except_H) loop
6743:                Add_Return (Spec_Id, Statements (Except_H));
6744:                Next_Non_Pragma (Except_H);
6745:             end loop;
```

## gcc/ada/exp_ch7.adb:4780–4821

```text
4780:          if Is_Master then
4781:             Establish_Task_Master (N);
4782:          end if;
4783:
4784:          --  If secondary stack is in use, generate:
4785:          --
4786:          --    Mnn : constant Mark_Id := SS_Mark;
4787:
4788:          if Needs_Sec_Stack_Mark then
4789:             Set_Uses_Sec_Stack (Scop, False); -- avoid duplicate SS marks
4790:             Mark := Make_Temporary (Loc, 'M');
4791:
4792:             declare
4793:                Mark_Call : constant Node_Id := Build_SS_Mark_Call (Loc, Mark);
4794:             begin
4795:                Prepend_To (Declarations (N), Mark_Call);
4796:                Analyze (Mark_Call);
4797:             end;
4798:          end if;
4799:
4800:          --  Generate finalization calls for all controlled objects appearing
4801:          --  in the statements of N. Add context specific cleanup for various
4802:          --  constructs.
4803:
4804:          Build_Finalizer
4805:            (N           => N,
4806:             Clean_Stmts => Build_Cleanup_Statements (N, Cln),
4807:             Mark_Id     => Mark,
4808:             Defer_Abort => Nkind (Original_Node (N)) = N_Task_Body
4809:                              or else Is_Master,
4810:             Fin_Id      => Fin_Id);
4811:
4812:          if Present (Fin_Id) then
4813:             pragma Assert (No (At_End_Proc (N)));
4814:             Set_At_End_Proc (N, New_Occurrence_Of (Fin_Id, Sloc (N)));
4815:             --  Attach reference to finalizer to tree for LLVM
4816:             Set_Parent (At_End_Proc (N), N);
4817:             Analyze (At_End_Proc (N));
4818:             Expand_At_End_Handler (N, Empty);
4819:          end if;
4820:       end;
4821:    end Expand_Cleanup_Actions;
```

## gcc/ada/sem_res.adb:13249–13335

```text
13249:             Array_Subtype : Entity_Id;
13250:             Drange        : Node_Id;
13251:             High_Bound    : Node_Id;
13252:             Index         : Node_Id;
13253:             Index_Subtype : Entity_Id;
13254:
13255:          begin
13256:             if Length = 1 then
13257:                High_Bound := New_Copy_Tree (Low_Bound);
13258:
13259:             elsif Has_Overflow_Operations (Index_Type) then
13260:                High_Bound :=
13261:                  Make_Op_Add (Loc,
13262:                    Left_Opnd  => New_Copy_Tree (Low_Bound),
13263:                    Right_Opnd => Make_Integer_Literal (Loc, Length - 1));
13264:
13265:             else
13266:                High_Bound :=
13267:                  Make_Attribute_Reference (Loc,
13268:                    Attribute_Name => Name_Val,
13269:                    Prefix         =>
13270:                      New_Occurrence_Of (Index_Type, Loc),
13271:                    Expressions    => New_List (
13272:                      Make_Op_Add (Loc,
13273:                        Left_Opnd  =>
13274:                          Make_Attribute_Reference (Loc,
13275:                            Attribute_Name => Name_Pos,
13276:                            Prefix         =>
13277:                              New_Occurrence_Of (Index_Type, Loc),
13278:                            Expressions    =>
13279:                              New_List (New_Copy_Tree (Low_Bound))),
13280:                        Right_Opnd =>
13281:                          Make_Integer_Literal (Loc, Length - 1))));
13282:             end if;
13283:
13284:             if Is_Integer_Type (Index_Type) then
13285:                Set_String_Literal_Low_Bound
13286:                  (Subtype_Id, Make_Integer_Literal (Loc, 1));
13287:
13288:             else
13289:                --  If the index type is an enumeration type, build bounds
13290:                --  expression with attributes.
13291:
13292:                Set_String_Literal_Low_Bound
13293:                  (Subtype_Id,
13294:                   Make_Attribute_Reference (Loc,
13295:                     Attribute_Name => Name_First,
13296:                     Prefix         =>
13297:                       New_Occurrence_Of (Base_Type (Index_Type), Loc)));
13298:             end if;
13299:
13300:             Analyze_And_Resolve
13301:               (String_Literal_Low_Bound (Subtype_Id), Base_Type (Index_Type));
13302:
13303:             --  Build bona fide subtype for the string, and wrap it in an
13304:             --  unchecked conversion, because the back end expects the
13305:             --  String_Literal_Subtype to have a static lower bound.
13306:
13307:             Index_Subtype :=
13308:               Create_Itype (Subtype_Kind (Ekind (Index_Type)), N);
13309:             Drange := Make_Range (Loc, New_Copy_Tree (Low_Bound), High_Bound);
13310:             Set_Scalar_Range (Index_Subtype, Drange);
13311:             Set_Parent (Drange, N);
13312:             Analyze_And_Resolve (Drange, Index_Type);
13313:
13314:             --  In this context, the Index_Type may already have a constraint,
13315:             --  so use common base type on string subtype. The base type may
13316:             --  be used when generating attributes of the string, for example
13317:             --  in the context of a slice assignment.
13318:
13319:             Set_Etype     (Index_Subtype, Base_Type (Index_Type));
13320:             Set_Size_Info (Index_Subtype, Index_Type);
13321:             Set_RM_Size   (Index_Subtype, RM_Size (Index_Type));
13322:
13323:             Array_Subtype := Create_Itype (E_Array_Subtype, N);
13324:
13325:             Index := New_Occurrence_Of (Index_Subtype, Loc);
13326:             Set_Etype (Index, Index_Subtype);
13327:             Append (Index, Index_List);
13328:
13329:             Set_First_Index    (Array_Subtype, Index);
13330:             Set_Etype          (Array_Subtype, Base_Type (Typ));
13331:             Set_Is_Constrained (Array_Subtype, True);
13332:
13333:             Rewrite (N, Unchecked_Convert_To (Array_Subtype, N));
13334:             Set_Etype (N, Array_Subtype);
13335:          end;
```

## gcc/ada/gcc-interface/trans.cc:3026–3306

```text
3026: Loop_Statement_to_gnu (Node_Id gnat_node)
3027: {
3028:   const Node_Id gnat_iter_scheme = Iteration_Scheme (gnat_node);
3029:   struct loop_info_d *gnu_loop_info = ggc_cleared_alloc<loop_info_d> ();
3030:   tree gnu_loop_stmt = build4 (LOOP_STMT, void_type_node, NULL_TREE,
3031:                                NULL_TREE, NULL_TREE, NULL_TREE);
3032:   tree gnu_loop_label = create_artificial_label (input_location);
3033:   tree gnu_cond_expr = NULL_TREE, gnu_low = NULL_TREE, gnu_high = NULL_TREE;
3034:   tree gnu_result;
3035:
3036:   /* Push the loop_info structure associated with the LOOP_STMT.  */
3037:   gnu_loop_info->fndecl = current_function_decl;
3038:   gnu_loop_info->stmt = gnu_loop_stmt;
3039:   vec_safe_push (gnu_loop_stack, gnu_loop_info);
3040:
3041:   /* Set location information for statement and end label.  */
3042:   set_expr_location_from_node (gnu_loop_stmt, gnat_node);
3043:   Sloc_to_locus (Sloc (End_Label (gnat_node)),
3044:                  &DECL_SOURCE_LOCATION (gnu_loop_label));
3045:   LOOP_STMT_LABEL (gnu_loop_stmt) = gnu_loop_label;
3046:
3047:   /* Set the condition under which the loop must keep going.  If we have an
3048:      explicit condition, use it to set the location information throughout
3049:      the translation of the loop statement to avoid having multiple SLOCs.
3050:
3051:      For the case "LOOP .... END LOOP;" the condition is always true.  */
3052:   if (No (gnat_iter_scheme))
3053:     ;
3054:
3055:   /* For the case "WHILE condition LOOP ..... END LOOP;" it's immediate.  */
3056:   else if (Present (Condition (gnat_iter_scheme)))
3057:     {
3058:       LOOP_STMT_COND (gnu_loop_stmt)
3059:         = gnat_to_gnu (Condition (gnat_iter_scheme));
3060:
3061:       set_expr_location_from_node (gnu_loop_stmt, gnat_iter_scheme);
3062:     }
3063:
3064:   /* Otherwise we have an iteration scheme and the condition is given by the
3065:      bounds of the subtype of the iteration variable.  */
3066:   else
3067:     {
3068:       Node_Id gnat_loop_spec = Loop_Parameter_Specification (gnat_iter_scheme);
3069:       Entity_Id gnat_loop_var = Defining_Entity (gnat_loop_spec);
3070:       Entity_Id gnat_type = Etype (gnat_loop_var);
3071:       tree gnu_type = get_unpadded_type (gnat_type);
3072:       tree gnu_base_type = maybe_character_type (get_base_type (gnu_type));
3073:       tree gnu_one_node = build_int_cst (gnu_base_type, 1);
3074:       tree gnu_loop_var, gnu_loop_iv, gnu_first, gnu_last, gnu_stmt;
3075:       enum tree_code update_code, test_code, shift_code;
3076:       bool reverse = Reverse_Present (gnat_loop_spec), use_iv = false;
3077:
3078:       gnu_low = convert (gnu_base_type, TYPE_MIN_VALUE (gnu_type));
3079:       gnu_high = convert (gnu_base_type, TYPE_MAX_VALUE (gnu_type));
3080:
3081:       /* We must disable modulo reduction for the iteration variable, if any,
3082:          in order for the loop comparison to be effective.  */
3083:       if (reverse)
3084:         {
3085:           gnu_first = gnu_high;
3086:           gnu_last = gnu_low;
3087:           update_code = MINUS_NOMOD_EXPR;
3088:           test_code = GE_EXPR;
3089:           shift_code = PLUS_NOMOD_EXPR;
3090:         }
3091:       else
3092:         {
3093:           gnu_first = gnu_low;
3094:           gnu_last = gnu_high;
3095:           update_code = PLUS_NOMOD_EXPR;
3096:           test_code = LE_EXPR;
3097:           shift_code = MINUS_NOMOD_EXPR;
3098:         }
3099:
3100:       /* We use two different strategies to translate the loop, depending on
3101:          whether optimization is enabled, except for the very peculiar case
3102:          of a loop running over a boolean type where we use the simpler form
3103:          in order to avoid manipulating negative values in a boolean context.
3104:
3105:          If it is, we generate the canonical loop form expected by the loop
3106:          optimizer and the loop vectorizer, which is the do-while form:
3107:
3108:              ENTRY_COND
3109:            loop:
3110:              TOP_UPDATE
3111:              BODY
3112:              BOTTOM_COND
3113:              GOTO loop
3114:
3115:          This avoids an implicit dependency on loop header copying and makes
3116:          it possible to turn BOTTOM_COND into an inequality test.
3117:
3118:          If optimization is disabled, loop header copying doesn't come into
3119:          play and we try to generate the loop form with the fewer conditional
3120:          branches.  First, the default form, which is:
3121:
3122:            loop:
3123:              TOP_COND
3124:              BODY
3125:              BOTTOM_UPDATE
3126:              GOTO loop
3127:
3128:          It should catch most loops with constant ending point.  Then, if we
3129:          cannot, we try to generate the shifted form:
3130:
3131:            loop:
3132:              TOP_COND
3133:              TOP_UPDATE
3134:              BODY
3135:              GOTO loop
3136:
3137:          which should catch loops with constant starting point.  Otherwise, if
3138:          we cannot, we generate the fallback form:
3139:
3140:              ENTRY_COND
3141:            loop:
3142:              BODY
3143:              BOTTOM_COND
3144:              BOTTOM_UPDATE
3145:              GOTO loop
3146:
3147:          which works in all cases.  */
3148:
3149:       if (optimize
3150:           && !optimize_debug
3151:           && TREE_CODE (gnu_base_type) != BOOLEAN_TYPE)
3152:         {
3153:           /* We can use the do-while form directly if GNU_FIRST-1 doesn't
3154:              overflow.  */
3155:           if (!can_equal_min_val_p (gnu_first, gnu_base_type, reverse))
3156:             ;
3157:
3158:           /* Otherwise, use the do-while form with the help of a special
3159:              induction variable in the unsigned version of the base type
3160:              or the unsigned version of the size type, whichever is the
3161:              largest, in order to have wrap-around arithmetics for it.  */
3162:           else
3163:             {
3164:               if (TYPE_PRECISION (gnu_base_type)
3165:                   > TYPE_PRECISION (size_type_node))
3166:                 gnu_base_type
3167:                   = gnat_type_for_size (TYPE_PRECISION (gnu_base_type), 1);
3168:               else
3169:                 gnu_base_type = size_type_node;
3170:
3171:               gnu_first = convert (gnu_base_type, gnu_first);
3172:               gnu_last = convert (gnu_base_type, gnu_last);
3173:               gnu_one_node = build_int_cst (gnu_base_type, 1);
3174:               use_iv = true;
3175:             }
3176:
3177:           gnu_first
3178:             = build_binary_op (shift_code, gnu_base_type, gnu_first,
3179:                                gnu_one_node);
3180:           LOOP_STMT_TOP_UPDATE_P (gnu_loop_stmt) = 1;
3181:           LOOP_STMT_BOTTOM_COND_P (gnu_loop_stmt) = 1;
3182:         }
3183:       else
3184:         {
3185:           /* We can use the default form if GNU_LAST+1 doesn't overflow.  */
3186:           if (!can_equal_max_val_p (gnu_last, gnu_base_type, reverse))
3187:             ;
3188:
3189:           /* Otherwise, we can use the shifted form if neither GNU_FIRST-1 nor
3190:              GNU_LAST-1 does.  */
3191:           else if (!can_equal_min_val_p (gnu_first, gnu_base_type, reverse)
3192:                    && !can_equal_min_val_p (gnu_last, gnu_base_type, reverse))
3193:             {
3194:               gnu_first
3195:                 = build_binary_op (shift_code, gnu_base_type, gnu_first,
3196:                                    gnu_one_node);
3197:               gnu_last
3198:                 = build_binary_op (shift_code, gnu_base_type, gnu_last,
3199:                                    gnu_one_node);
3200:               LOOP_STMT_TOP_UPDATE_P (gnu_loop_stmt) = 1;
3201:             }
3202:
3203:           /* Otherwise, use the fallback form.  */
3204:           else
3205:             LOOP_STMT_BOTTOM_COND_P (gnu_loop_stmt) = 1;
3206:         }
3207:
3208:       /* If we use the BOTTOM_COND, we can turn the test into an inequality
3209:          test but we have to add ENTRY_COND to protect the empty loop.  */
3210:       if (LOOP_STMT_BOTTOM_COND_P (gnu_loop_stmt))
3211:         {
3212:           test_code = NE_EXPR;
3213:           gnu_cond_expr
3214:             = build3 (COND_EXPR, void_type_node,
3215:                       build_binary_op (LE_EXPR, boolean_type_node,
3216:                                        gnu_low, gnu_high),
3217:                       NULL_TREE, alloc_stmt_list ());
3218:           set_expr_location_from_node (gnu_cond_expr, gnat_iter_scheme);
3219:         }
3220:
3221:       /* Open a new nesting level that will surround the loop to declare the
3222:          iteration variable.  */
3223:       start_stmt_group ();
3224:       gnat_pushlevel ();
3225:
3226:       /* If we use the special induction variable, create it and set it to
3227:          its initial value.  Morever, the regular iteration variable cannot
3228:          itself be initialized, lest the initial value wrapped around.  */
3229:       if (use_iv)
3230:         {
3231:           gnu_loop_iv
3232:             = create_init_temporary ("I", gnu_first, &gnu_stmt, gnat_loop_var);
3233:           add_stmt (gnu_stmt);
3234:           gnu_first = NULL_TREE;
3235:         }
3236:       else
3237:         gnu_loop_iv = NULL_TREE;
3238:
3239:       /* Declare the iteration variable and set it to its initial value.  */
3240:       gnu_loop_var = gnat_to_gnu_entity (gnat_loop_var, gnu_first, true);
3241:       if (DECL_BY_REF_P (gnu_loop_var))
3242:         gnu_loop_var = build_unary_op (INDIRECT_REF, NULL_TREE, gnu_loop_var);
3243:       else if (use_iv)
3244:         {
3245:           gcc_assert (DECL_LOOP_PARM_P (gnu_loop_var));
3246:           SET_DECL_INDUCTION_VAR (gnu_loop_var, gnu_loop_iv);
3247:         }
3248:       gnu_loop_info->loop_var = gnu_loop_var;
3249:       gnu_loop_info->low_bound = gnu_low;
3250:       gnu_loop_info->high_bound = gnu_high;
3251:
3252:       /* Do all the arithmetics in the base type.  */
3253:       gnu_loop_var = convert (gnu_base_type, gnu_loop_var);
3254:
3255:       /* Set either the top or bottom exit condition.  */
3256:       if (use_iv)
3257:         LOOP_STMT_COND (gnu_loop_stmt)
3258:           = build_binary_op (test_code, boolean_type_node, gnu_loop_iv,
3259:                              gnu_last);
3260:       else
3261:         LOOP_STMT_COND (gnu_loop_stmt)
3262:           = build_binary_op (test_code, boolean_type_node, gnu_loop_var,
3263:                              gnu_last);
3264:
3265:       /* Set either the top or bottom update statement and give it the source
3266:          location of the iteration for better coverage info.  */
3267:       if (use_iv)
3268:         {
3269:           gnu_stmt
3270:             = build_binary_op (MODIFY_EXPR, NULL_TREE, gnu_loop_iv,
3271:                                build_binary_op (update_code, gnu_base_type,
3272:                                                 gnu_loop_iv, gnu_one_node));
3273:           set_expr_location_from_node (gnu_stmt, gnat_iter_scheme);
3274:           append_to_statement_list (gnu_stmt,
3275:                                     &LOOP_STMT_UPDATE (gnu_loop_stmt));
3276:           gnu_stmt
3277:             = build_binary_op (MODIFY_EXPR, NULL_TREE, gnu_loop_var,
3278:                                gnu_loop_iv);
3279:           set_expr_location_from_node (gnu_stmt, gnat_iter_scheme);
3280:           append_to_statement_list (gnu_stmt,
3281:                                     &LOOP_STMT_UPDATE (gnu_loop_stmt));
3282:         }
3283:       else
3284:         {
3285:           gnu_stmt
3286:             = build_binary_op (MODIFY_EXPR, NULL_TREE, gnu_loop_var,
3287:                                build_binary_op (update_code, gnu_base_type,
3288:                                                 gnu_loop_var, gnu_one_node));
3289:           set_expr_location_from_node (gnu_stmt, gnat_iter_scheme);
3290:           LOOP_STMT_UPDATE (gnu_loop_stmt) = gnu_stmt;
3291:         }
3292:
3293:       set_expr_location_from_node (gnu_loop_stmt, gnat_iter_scheme);
3294:     }
3295:
3296:   /* If the loop was named, have the name point to this loop.  In this case,
3297:      the association is not a DECL node, but the end label of the loop.  */
3298:   if (Present (Identifier (gnat_node)))
3299:     save_gnu_tree (Entity (Identifier (gnat_node)), gnu_loop_label, true);
3300:
3301:   /* Make the loop body into its own block, so any allocated storage will be
3302:      released every iteration.  This is needed for stack allocation.  */
3303:   LOOP_STMT_BODY (gnu_loop_stmt)
3304:     = build_stmt_group (Statements (gnat_node), true);
3305:   TREE_SIDE_EFFECTS (gnu_loop_stmt) = 1;
3306:
```

## gcc/ada/gcc-interface/trans.cc:3313–3400

```text
3313:          be evaluated to false at compile time; otherwise, if there are not
3314:          too many of them, combine them with the original checks.  If loop
3315:          unswitching is enabled, do not require the loop bounds to be also
3316:          invariant, as their evaluation will still be ahead of the loop.  */
3317:       if (vec_safe_length (gnu_loop_info->checks) > 0
3318:          && (make_invariant (&gnu_low, &gnu_high) || optimize >= 3))
3319:         {
3320:           struct range_check_info_d *rci;
3321:           unsigned int i, n_remaining_checks = 0;
3322:
3323:           FOR_EACH_VEC_ELT (*gnu_loop_info->checks, i, rci)
3324:             {
3325:               tree low_ok, high_ok;
3326:
3327:               if (rci->low_bound)
3328:                 {
3329:                   tree gnu_adjusted_low = convert (rci->type, gnu_low);
3330:                   if (rci->disp)
3331:                     gnu_adjusted_low
3332:                       = fold_build2 (rci->neg_p ? MINUS_EXPR : PLUS_EXPR,
3333:                                      rci->type, gnu_adjusted_low, rci->disp);
3334:                   low_ok
3335:                     = build_binary_op (GE_EXPR, boolean_type_node,
3336:                                        gnu_adjusted_low, rci->low_bound);
3337:                 }
3338:               else
3339:                 low_ok = boolean_true_node;
3340:
3341:               if (rci->high_bound)
3342:                 {
3343:                   tree gnu_adjusted_high = convert (rci->type, gnu_high);
3344:                   if (rci->disp)
3345:                     gnu_adjusted_high
3346:                       = fold_build2 (rci->neg_p ? MINUS_EXPR : PLUS_EXPR,
3347:                                      rci->type, gnu_adjusted_high, rci->disp);
3348:                   high_ok
3349:                     = build_binary_op (LE_EXPR, boolean_type_node,
3350:                                        gnu_adjusted_high, rci->high_bound);
3351:                 }
3352:               else
3353:                 high_ok = boolean_true_node;
3354:
3355:               tree range_ok
3356:                 = build_binary_op (TRUTH_ANDIF_EXPR, boolean_type_node,
3357:                                    low_ok, high_ok);
3358:
3359:               rci->invariant_cond
3360:                 = build_unary_op (TRUTH_NOT_EXPR, boolean_type_node, range_ok);
3361:
3362:               if (rci->invariant_cond == boolean_false_node)
3363:                 TREE_OPERAND (rci->inserted_cond, 0) = rci->invariant_cond;
3364:               else
3365:                 n_remaining_checks++;
3366:             }
3367:
3368:           /* Note that loop unswitching can only be applied a small number of
3369:              times to a given loop (PARAM_MAX_UNSWITCH_LEVEL default to 3).  */
3370:           if (IN_RANGE (n_remaining_checks, 1, 3)
3371:               && optimize >= 2
3372:               && !optimize_size)
3373:             FOR_EACH_VEC_ELT (*gnu_loop_info->checks, i, rci)
3374:               if (rci->invariant_cond != boolean_false_node)
3375:                 {
3376:                   TREE_OPERAND (rci->inserted_cond, 0) = rci->invariant_cond;
3377:
3378:                   if (optimize >= 3)
3379:                     add_stmt_with_node_force (rci->inserted_cond, gnat_node);
3380:                 }
3381:         }
3382:
3383:       /* Second, if we have recorded invariants to be hoisted, emit them.  */
3384:       if (vec_safe_length (gnu_loop_info->invariants) > 0)
3385:         {
3386:           tree *iter;
3387:           unsigned int i;
3388:           FOR_EACH_VEC_ELT (*gnu_loop_info->invariants, i, iter)
3389:             add_stmt_with_node_force (*iter, gnat_node);
3390:         }
3391:
3392:       /* Third, if loop vectorization is enabled and the iterations of the
3393:          loop can easily be proved as independent, mark the loop.  */
3394:       if (optimize >= 3
3395:           && independent_iterations_p (LOOP_STMT_BODY (gnu_loop_stmt)))
3396:         LOOP_STMT_IVDEP (gnu_loop_stmt) = 1;
3397:
3398:       add_stmt (gnu_loop_stmt);
3399:       gnat_poplevel ();
3400:       gnu_loop_stmt = end_stmt_group ();
```

## gcc/ada/gcc-interface/trans.cc:3843–3941

```text
3843: /* Build a RETURN_EXPR.  If RET_VAL is non-null, build a RETURN_EXPR around
3844:    the assignment of RET_VAL to RET_OBJ.  Otherwise build a bare RETURN_EXPR
3845:    around RESULT_OBJ, which may be null in this case.  */
3846:
3847: static tree
3848: build_return_expr (tree ret_obj, tree ret_val)
3849: {
3850:   tree result_expr;
3851:
3852:   if (ret_val)
3853:     {
3854:       /* The gimplifier explicitly enforces the following invariant:
3855:
3856:               RETURN_EXPR
3857:                   |
3858:                INIT_EXPR
3859:               /        \
3860:              /          \
3861:          RET_OBJ        ...
3862:
3863:          As a consequence, type consistency dictates that we use the type
3864:          of the RET_OBJ as the operation type.  */
3865:       tree operation_type = TREE_TYPE (ret_obj);
3866:
3867:       /* Convert the right operand to the operation type.  Note that this is
3868:          the transformation applied in the INIT_EXPR case of build_binary_op,
3869:          with the assumption that the type cannot involve a placeholder.  */
3870:       if (operation_type != TREE_TYPE (ret_val))
3871:         ret_val = convert (operation_type, ret_val);
3872:
3873:       /* We always can use an INIT_EXPR for the return object.  */
3874:       result_expr = build2 (INIT_EXPR, void_type_node, ret_obj, ret_val);
3875:
3876:       /* If the function returns an aggregate type, find out whether this is
3877:          a candidate for Named Return Value.  If so, record it.  Otherwise,
3878:          if this is an expression of some kind, record it elsewhere.  */
3879:       if (optimize
3880:           && !optimize_debug
3881:           && AGGREGATE_TYPE_P (operation_type)
3882:           && !TYPE_IS_FAT_POINTER_P (operation_type)
3883:           && TYPE_MODE (operation_type) == BLKmode
3884:           && aggregate_value_p (operation_type, current_function_decl))
3885:         {
3886:           /* Strip useless conversions around the return value.  */
3887:           if (gnat_useless_type_conversion (ret_val))
3888:             ret_val = TREE_OPERAND (ret_val, 0);
3889:
3890:           /* Now apply the test to the return value.  */
3891:           if (return_value_ok_for_nrv_p (ret_obj, ret_val))
3892:             {
3893:               if (!f_named_ret_val)
3894:                 f_named_ret_val = BITMAP_GGC_ALLOC ();
3895:               bitmap_set_bit (f_named_ret_val, DECL_UID (ret_val));
3896:             }
3897:
3898:           /* Note that we need not care about CONSTRUCTORs here, as they are
3899:              totally transparent given the read-compose-write semantics of
3900:              assignments from CONSTRUCTORs.  */
3901:           else if (EXPR_P (ret_val))
3902:             vec_safe_push (f_other_ret_val, ret_val);
3903:         }
3904:     }
3905:   else
3906:     result_expr = ret_obj;
3907:
3908:   return build1 (RETURN_EXPR, void_type_node, result_expr);
3909: }
3910:
3911: /* Subroutine of gnat_to_gnu to translate the At_End_Proc of GNAT_NODE, an
3912:    N_Block_Statement or N_Handled_Sequence_Of_Statements or N_*_Body node.
3913:
3914:    To invoked the GCC mechanism, we call add_cleanup and when we leave the
3915:    group, end_stmt_group will create the TRY_FINALLY_EXPR construct.  */
3916:
3917: static void
3918: At_End_Proc_to_gnu (Node_Id gnat_node)
3919: {
3920:   tree proc_decl = gnat_to_gnu (At_End_Proc (gnat_node));
3921:   Node_Id gnat_end_label;
3922:
3923:   /* When not optimizing, disable inlining of finalizers as this can
3924:      create a more complex CFG in the parent function.  */
3925:   if (!optimize || optimize_debug)
3926:     DECL_DECLARED_INLINE_P (proc_decl) = 0;
3927:
3928:   /* Retrieve the end label attached to the node, if any.  */
3929:   if (Nkind (gnat_node) == N_Handled_Sequence_Of_Statements)
3930:     gnat_end_label = End_Label (gnat_node);
3931:   else if (Present (Handled_Statement_Sequence (gnat_node)))
3932:     gnat_end_label = End_Label (Handled_Statement_Sequence (gnat_node));
3933:   else
3934:     gnat_end_label = Empty;
3935:
3936:   /* If there is no end label attached, we use the location of the At_End
3937:      procedure because Expand_Cleanup_Actions might reset the location of
3938:      the enclosing construct to that of an inner statement.  */
3939:   add_cleanup (build_call_n_expr (proc_decl, 0),
3940:                Present (gnat_end_label)
3941:                ? gnat_end_label : At_End_Proc (gnat_node));
```

## gcc/ada/gcc-interface/trans.cc:4028–4126

```text
4028:   set_cfun (NULL);
4029:
4030:   begin_subprog_body (gnu_subprog);
4031:
4032:   /* If there are copy-in/copy-out parameters, we need to ensure that they are
4033:      properly copied out by the return statement.  We do this by making a new
4034:      block and converting any return into a goto to a label at the end of the
4035:      block.  */
4036:   if (gnu_cico_list)
4037:     {
4038:       tree gnu_return_var;
4039:
4040:       vec_safe_push (gnu_return_label_stack,
4041:                      create_artificial_label (input_location));
4042:
4043:       start_stmt_group ();
4044:       gnat_pushlevel ();
4045:
4046:       /* If this is a function with copy-in/copy-out parameters and which does
4047:          not return by invisible reference, we also need a variable for the
4048:          return value to be placed.  */
4049:       if (gnu_return_var_elmt && !TREE_ADDRESSABLE (gnu_subprog_type))
4050:         {
4051:           tree gnu_return_type
4052:             = TREE_TYPE (TREE_PURPOSE (gnu_return_var_elmt));
4053:
4054:           gnu_return_var
4055:             = create_var_decl (get_identifier ("RETVAL"), NULL_TREE,
4056:                                gnu_return_type, NULL_TREE,
4057:                                false, false, false, false, false, false,
4058:                                true, false, NULL, gnat_subprog);
4059:           TREE_VALUE (gnu_return_var_elmt) = gnu_return_var;
4060:         }
4061:       else
4062:         gnu_return_var = NULL_TREE;
4063:
4064:       vec_safe_push (gnu_return_var_stack, gnu_return_var);
4065:
4066:       /* See whether there are parameters for which we don't have a GCC tree
4067:          yet.  These must be Out parameters.  Make a VAR_DECL for them and
4068:          put it into TYPE_CI_CO_LIST, which must contain an empty entry too.
4069:          We can match up the entries because TYPE_CI_CO_LIST is in the order
4070:          of the parameters.  */
4071:       for (Entity_Id gnat_param = First_Formal_With_Extras (gnat_subprog);
4072:            Present (gnat_param);
4073:            gnat_param = Next_Formal_With_Extras (gnat_param))
4074:         if (!present_gnu_tree (gnat_param))
4075:           {
4076:             tree gnu_cico_entry = gnu_cico_list;
4077:             tree gnu_decl;
4078:
4079:             /* Skip any entries that have been already filled in; they must
4080:                correspond to In Out parameters or previous Out parameters.  */
4081:             while (gnu_cico_entry && TREE_VALUE (gnu_cico_entry))
4082:               gnu_cico_entry = TREE_CHAIN (gnu_cico_entry);
4083:
4084:             /* Do any needed dereferences for by-ref objects.  */
4085:             gnu_decl = gnat_to_gnu_entity (gnat_param, NULL_TREE, true);
4086:             gcc_assert (DECL_P (gnu_decl));
4087:             if (DECL_BY_REF_P (gnu_decl))
4088:               gnu_decl = build_unary_op (INDIRECT_REF, NULL_TREE, gnu_decl);
4089:
4090:             TREE_VALUE (gnu_cico_entry) = gnu_decl;
4091:           }
4092:
4093:       /* Finally, ensure type consistency between TREE_PURPOSE and TREE_VALUE
4094:          so that the assignment of the latter to the former can be done.  */
4095:       tree gnu_cico_entry = gnu_cico_list;
4096:       while (gnu_cico_entry)
4097:         {
4098:           if (!VOID_TYPE_P (TREE_VALUE (gnu_cico_entry)))
4099:             TREE_VALUE (gnu_cico_entry)
4100:               = convert (TREE_TYPE (TREE_PURPOSE (gnu_cico_entry)),
4101:                          TREE_VALUE (gnu_cico_entry));
4102:           gnu_cico_entry = TREE_CHAIN (gnu_cico_entry);
4103:         }
4104:     }
4105:
4106:   else
4107:     vec_safe_push (gnu_return_label_stack, NULL_TREE);
4108:
4109:   /* Get a tree corresponding to the code for the subprogram.  */
4110:   start_stmt_group ();
4111:   gnat_pushlevel ();
4112:
4113:   /* First translate the declarations of the subprogram.  */
4114:   process_decls (Declarations (gnat_node), Empty, true, true);
4115:
4116:   /* Then generate the code of the subprogram itself.  A return statement will
4117:      be present and any Out parameters will be handled there.  */
4118:   add_stmt (gnat_to_gnu (Handled_Statement_Sequence (gnat_node)));
4119:
4120:   /* Process the At_End_Proc, if any.  */
4121:   if (Present (At_End_Proc (gnat_node)))
4122:     At_End_Proc_to_gnu (gnat_node);
4123:
4124:   gnat_poplevel ();
4125:   tree gnu_result = end_stmt_group ();
4126:
```

## gcc/ada/gcc-interface/trans.cc:4228–4249

```text
4228:   gnu_return_label_stack->pop ();
4229:
4230:   /* On SEH targets, install an exception handler around the main entry
4231:      point to catch unhandled exceptions.  */
4232:   if (DECL_NAME (gnu_subprog) == main_identifier_node
4233:       && targetm_common.except_unwind_info (&global_options) == UI_SEH)
4234:     {
4235:       tree t;
4236:       tree etype;
4237:
4238:       t = build_call_expr (builtin_decl_explicit (BUILT_IN_EH_POINTER),
4239:                            1, integer_zero_node);
4240:       t = build_call_n_expr (unhandled_except_decl, 1, t);
4241:
4242:       etype = build_unary_op (ADDR_EXPR, NULL_TREE, unhandled_others_decl);
4243:       etype = tree_cons (NULL_TREE, etype, NULL_TREE);
4244:
4245:       t = build2 (CATCH_EXPR, void_type_node, etype, t);
4246:       gnu_result = build2 (TRY_CATCH_EXPR, TREE_TYPE (gnu_result),
4247:                            gnu_result, t);
4248:     }
4249:
```

## gcc/ada/gcc-interface/trans.cc:4582–4613

```text
4582: /* Create a temporary variable with PREFIX and TYPE, and return it.  */
4583:
4584: static tree
4585: create_temporary (const char *prefix, tree type)
4586: {
4587:   if (CONTAINS_PLACEHOLDER_P (TYPE_SIZE (type)))
4588:     type = maybe_pad_type (type, max_size (TYPE_SIZE (type), true), 0,
4589:                            Empty, false, false, true);
4590:   tree gnu_temp
4591:     = create_var_decl (create_tmp_var_name (prefix), NULL_TREE,
4592:                       type, NULL_TREE,
4593:                       false, false, false, false, false, false,
4594:                       true, false, NULL, Empty);
4595:   return gnu_temp;
4596: }
4597:
4598: /* Create a temporary variable with PREFIX and initialize it with GNU_INIT.
4599:    Put the initialization statement into GNU_INIT_STMT and annotate it with
4600:    the SLOC of GNAT_NODE.  Return the temporary variable.  */
4601:
4602: static tree
4603: create_init_temporary (const char *prefix, tree gnu_init, tree *gnu_init_stmt,
4604:                        Node_Id gnat_node)
4605: {
4606:   tree gnu_temp = create_temporary (prefix, TREE_TYPE (gnu_init));
4607:
4608:   *gnu_init_stmt = build_binary_op (INIT_EXPR, NULL_TREE, gnu_temp, gnu_init);
4609:   set_expr_location_from_node (*gnu_init_stmt, gnat_node);
4610:
4611:   return gnu_temp;
4612: }
4613:
```

## gcc/ada/gcc-interface/trans.cc:4864–4930

```text
4864:   if (function_call
4865:       && ((!gnu_target && TYPE_CI_CO_LIST (gnu_subprog_type))
4866:           || (!gnu_target
4867:               && Nkind (Parent (gnat_node)) != N_Object_Declaration
4868:               && Nkind (Parent (gnat_node)) != N_Object_Renaming_Declaration
4869:               && Nkind (Parent (gnat_node)) != N_Simple_Return_Statement
4870:               && (!(Nkind (Parent (gnat_node)) == N_Qualified_Expression
4871:                     && Nkind (Parent (Parent (gnat_node))) == N_Allocator)
4872:                   || type_is_padding_self_referential (gnu_result_type))
4873:               && Nkind (Parent (gnat_node)) != N_Aggregate
4874:               && AGGREGATE_TYPE_P (gnu_result_type)
4875:               && !TYPE_IS_FAT_POINTER_P (gnu_result_type))
4876:           || (gnu_target
4877:               && (TREE_CODE (gnu_target) == ARRAY_RANGE_REF
4878:                   || (TREE_CODE (TREE_TYPE (gnu_target)) == ARRAY_TYPE
4879:                       && TREE_CODE (TYPE_SIZE (TREE_TYPE (gnu_target)))
4880:                          == INTEGER_CST))
4881:               && TREE_CODE (TYPE_SIZE (gnu_result_type)) != INTEGER_CST)
4882:           || (gnu_target
4883:               && TREE_CODE (gnu_target) == COMPONENT_REF
4884:               && DECL_BIT_FIELD (TREE_OPERAND (gnu_target, 1))
4885:               && DECL_SIZE (TREE_OPERAND (gnu_target, 1))
4886:                  != TYPE_SIZE (TREE_TYPE (gnu_target))
4887:               && type_is_padding_self_referential (gnu_result_type))
4888:           || (gnu_target
4889:               && Present (gnat_smo)
4890:               && Present (Storage_Model_Copy_To (gnat_smo)))))
4891:     {
4892:       gnu_retval = create_temporary ("R", gnu_result_type);
4893:       DECL_RETURN_VALUE_P (gnu_retval) = 1;
4894:     }
4895:
4896:   /* If we don't need a value or have already created it, push a binding level
4897:      around the call.  This will narrow the lifetime of the temporaries we may
4898:      need to make when translating the parameters as much as possible.  */
4899:   if (!returning_value || gnu_retval)
4900:     {
4901:       start_stmt_group ();
4902:       gnat_pushlevel ();
4903:       pushed_binding_level = true;
4904:     }
4905:   else
4906:     pushed_binding_level = false;
4907:
4908:   /* Create the list of the actual parameters as GCC expects it, namely a
4909:      chain of TREE_LIST nodes in which the TREE_VALUE field of each node
4910:      is an expression and the TREE_PURPOSE field is null.  But skip Out
4911:      parameters not passed by reference and that need not be copied in.  */
4912:   for (gnat_actual = First_Actual (gnat_node);
4913:        Present (gnat_actual);
4914:        gnat_formal = Next_Formal_With_Extras (gnat_formal),
4915:        gnat_actual = Next_Actual (gnat_actual))
4916:     {
4917:       const Entity_Id gnat_formal_type = Etype (gnat_formal);
4918:       tree gnu_formal_type = gnat_to_gnu_type (gnat_formal_type);
4919:       tree gnu_formal = present_gnu_tree (gnat_formal)
4920:                         ? get_gnu_tree (gnat_formal) : NULL_TREE;
4921:       tree gnu_actual_type = gnat_to_gnu_type (Etype (gnat_actual));
4922:       const bool is_init_proc
4923:         = Is_Entity_Name (gnat_subprog) && Is_Init_Proc (Entity (gnat_subprog));
4924:       const bool in_param = (Ekind (gnat_formal) == E_In_Parameter);
4925:       const bool is_true_formal_parm
4926:         = gnu_formal && TREE_CODE (gnu_formal) == PARM_DECL;
4927:       const bool is_by_ref_formal_parm
4928:         = is_true_formal_parm
4929:           && (DECL_BY_REF_P (gnu_formal)
4930:               || DECL_BY_COMPONENT_PTR_P (gnu_formal));
```

## gcc/ada/gcc-interface/trans.cc:5077–5110

```text
5077:              we need to create a temporary for the return value because we must
5078:              preserve it before copying back at the very end.  */
5079:           if (!in_param && returning_value && !gnu_retval)
5080:             {
5081:               gnu_retval = create_temporary ("R", gnu_result_type);
5082:               DECL_RETURN_VALUE_P (gnu_retval) = 1;
5083:             }
5084:
5085:           /* If we haven't pushed a binding level, push it now.  This will
5086:              narrow the lifetime of the temporary we are about to make as
5087:              much as possible.  */
5088:           if (!pushed_binding_level && (!returning_value || gnu_retval))
5089:             {
5090:               start_stmt_group ();
5091:               gnat_pushlevel ();
5092:               pushed_binding_level = true;
5093:             }
5094:
5095:           /* Create an explicit temporary holding the copy.  */
5096:
5097:           /* Do not initialize it for the _Init parameter of an initialization
5098:              procedure since no data is meant to be passed in.  */
5099:           if (Ekind (gnat_formal) == E_Out_Parameter && is_init_proc)
5100:             gnu_name = gnu_temp = create_temporary ("A", TREE_TYPE (gnu_name));
5101:
5102:           /* Initialize it on the fly like for an implicit temporary in the
5103:              other cases, as we don't necessarily have a statement list.  */
5104:           else
5105:             {
5106:               gnu_temp = create_init_temporary ("A", gnu_name, &gnu_stmt,
5107:                                                 gnat_actual);
5108:               gnu_name = build_compound_expr (TREE_TYPE (gnu_name), gnu_stmt,
5109:                                               gnu_temp);
5110:             }
```

## gcc/ada/gcc-interface/trans.cc:5391–5427

```text
5391:
5392:   set_expr_location_from_node (gnu_call, gnat_node);
5393:
5394:   /* If we have created a temporary for the return value, initialize it.  */
5395:   if (gnu_retval)
5396:     {
5397:       tree gnu_stmt
5398:         = build_binary_op (INIT_EXPR, NULL_TREE, gnu_retval, gnu_call);
5399:       set_expr_location_from_node (gnu_stmt, gnat_node);
5400:       append_to_statement_list (gnu_stmt, &gnu_stmt_list);
5401:       gnu_call = gnu_retval;
5402:     }
5403:
5404:   /* If this is a subprogram with copy-in/copy-out parameters, we need to
5405:      unpack the valued returned from the function into the In Out or Out
5406:      parameters.  We deal with the function return (if this is an Ada
5407:      function) below.  */
5408:   if (TYPE_CI_CO_LIST (gnu_subprog_type))
5409:     {
5410:       /* List of FIELD_DECLs associated with the PARM_DECLs of the copy-in/
5411:          copy-out parameters.  */
5412:       tree gnu_cico_list = TYPE_CI_CO_LIST (gnu_subprog_type);
5413:       const int length = list_length (gnu_cico_list);
5414:
5415:       /* The call sequence must contain one and only one call, even though the
5416:          function is pure.  Save the result into a temporary if needed.  */
5417:       if (length > 1)
5418:         {
5419:           if (!gnu_retval)
5420:             {
5421:               tree gnu_stmt;
5422:               gnu_call
5423:                 = create_init_temporary ("P", gnu_call, &gnu_stmt, gnat_node);
5424:               append_to_statement_list (gnu_stmt, &gnu_stmt_list);
5425:             }
5426:
5427:           gnu_name_list = nreverse (gnu_name_list);
```

## gcc/ada/gcc-interface/trans.cc:5670–5758

```text
5670:     = !type_annotate_only && Present (Exception_Handlers (gnat_node));
5671:   const bool at_end = !type_annotate_only && Present (At_End_Proc (gnat_node));
5672:   tree gnu_result;
5673:   Node_Id gnat_temp;
5674:
5675:   /* The exception handling mechanism can handle both ZCX and SJLJ schemes, and
5676:      is exposed through the TRY_CATCH_EXPR construct that we build manually.
5677:
5678:      ??? The region level calls down there have been specifically put in place
5679:      for a ZCX context and currently the order in which things are emitted
5680:      (region/handlers) is different from the SJLJ case.  Instead of putting
5681:      other calls with different conditions at other places for the SJLJ case,
5682:      it seems cleaner to reorder things for the SJLJ case and generalize the
5683:      condition to make it not ZCX specific.  */
5684:
5685:   /* First build the tree for the statements inside the sequence.  */
5686:   start_stmt_group ();
5687:
5688:   for (gnat_temp = First (Statements (gnat_node));
5689:        Present (gnat_temp);
5690:        gnat_temp = Next (gnat_temp))
5691:     add_stmt (gnat_to_gnu (gnat_temp));
5692:
5693:   gnu_result = end_stmt_group ();
5694:
5695:   /* Then process the exception handlers, if any.  */
5696:   if (eh)
5697:     {
5698:       tree gnu_handlers;
5699:       location_t locus;
5700:
5701:       /* First make a group containing the handlers.  */
5702:       start_stmt_group ();
5703:       for (gnat_temp = First_Non_Pragma (Exception_Handlers (gnat_node));
5704:            Present (gnat_temp);
5705:            gnat_temp = Next_Non_Pragma (gnat_temp))
5706:         add_stmt (gnat_to_gnu (gnat_temp));
5707:       gnu_handlers = end_stmt_group ();
5708:
5709:       /* Now make the TRY_CATCH_EXPR for the group.  */
5710:       gnu_result
5711:         = build2 (TRY_CATCH_EXPR, void_type_node, gnu_result, gnu_handlers);
5712:
5713:       /* Set a location.  We need to find a unique location for the dispatching
5714:          code, otherwise we can get coverage or debugging issues.  Try with
5715:          the location of the end label.  */
5716:       if (Present (End_Label (gnat_node))
5717:           && Sloc_to_locus (Sloc (End_Label (gnat_node)), &locus))
5718:         SET_EXPR_LOCATION (gnu_result, locus);
5719:       else
5720:         /* Clear column information so that the exception handler of an
5721:            implicit transient block does not incorrectly inherit the slocs
5722:            of a decision, which would otherwise confuse control flow based
5723:            coverage analysis tools.  */
5724:         set_expr_location_from_node (gnu_result, gnat_node, true);
5725:     }
5726:
5727:   if (Present (Finally_Statements (gnat_node)))
5728:     {
5729:       tree finally_stmts;
5730:       location_t locus;
5731:
5732:       start_stmt_group ();
5733:       for (gnat_temp = First_Non_Pragma (Finally_Statements (gnat_node));
5734:            Present (gnat_temp);
5735:            gnat_temp = Next_Non_Pragma (gnat_temp))
5736:         add_stmt (gnat_to_gnu (gnat_temp));
5737:       finally_stmts = end_stmt_group ();
5738:
5739:       gnu_result
5740:         = build2 (TRY_FINALLY_EXPR, void_type_node, gnu_result, finally_stmts);
5741:
5742:       /* Do as above for the TRY_CATCH_EXPR case.  */
5743:       if (Present (End_Label (gnat_node))
5744:           && Sloc_to_locus (Sloc (End_Label (gnat_node)), &locus))
5745:         SET_EXPR_LOCATION (gnu_result, locus);
5746:       else
5747:         set_expr_location_from_node (gnu_result, gnat_node, true);
5748:     }
5749:
5750:   /* Process the At_End_Proc, if any.  */
5751:   if (at_end)
5752:     {
5753:       start_stmt_group ();
5754:       add_stmt (gnu_result);
5755:       At_End_Proc_to_gnu (gnat_node);
5756:       gnu_result = end_stmt_group ();
5757:     }
5758:
```

## gcc/ada/gcc-interface/trans.cc:5990–6003

```text
5990:   vec_safe_push (gnu_elab_proc_stack, gnu_elab_proc_decl);
5991:   DECL_ELABORATION_PROC_P (gnu_elab_proc_decl) = 1;
5992:
5993:   /* Initialize the information structure for the function.  */
5994:   allocate_struct_function (gnu_elab_proc_decl, false);
5995:   set_cfun (NULL);
5996:
5997:   current_function_decl = NULL_TREE;
5998:
5999:   start_stmt_group ();
6000:   gnat_pushlevel ();
6001:
6002:   /* For a body, first process the spec if there is one.  */
6003:   if (Nkind (gnat_unit) == N_Package_Body
```

## gcc/ada/gcc-interface/trans.cc:6078–6095

```text
6078:   /* Save away what we've made so far and finish it up.  */
6079:   set_current_block_context (gnu_elab_proc_decl);
6080:   gnat_poplevel ();
6081:   DECL_SAVED_TREE (gnu_elab_proc_decl) = end_stmt_group ();
6082:   set_end_locus_from_node (gnu_elab_proc_decl, gnat_unit);
6083:   gnu_elab_proc_stack->pop ();
6084:
6085:   /* Record this potential elaboration procedure for later processing.  */
6086:   info = ggc_alloc<elab_info> ();
6087:   info->next = elab_info_list;
6088:   info->elab_proc = gnu_elab_proc_decl;
6089:   info->gnat_node = gnat_node;
6090:   elab_info_list = info;
6091:
6092:   /* Force the processing for all nodes that remain in the queue.  */
6093:   process_deferred_decl_context (true);
6094: }
6095:
```

## gcc/ada/gcc-interface/trans.cc:6150–6318

```text
6150: static tree
6151: Raise_Error_to_gnu (Node_Id gnat_node, tree *gnu_result_type_p)
6152: {
6153:   const Node_Kind kind = Nkind (gnat_node);
6154:   const Node_Id gnat_cond = Condition (gnat_node);
6155:   const int reason = UI_To_Int (Reason (gnat_node));
6156:   const bool with_extra_info
6157:     = Exception_Extra_Info
6158:       && !No_Exception_Handlers_Set ()
6159:       && No (get_exception_label (kind));
6160:   tree gnu_result = NULL_TREE, gnu_cond = NULL_TREE;
6161:   Node_Id gnat_rcond;
6162:
6163:   /* The following processing is not required for correctness.  Its purpose is
6164:      to give more precise error messages and to record some information.  */
6165:   switch (reason)
6166:     {
6167:     case CE_Access_Check_Failed:
6168:       if (with_extra_info)
6169:         gnu_result = build_call_raise_column (reason, gnat_node, kind);
6170:       break;
6171:
6172:     case CE_Index_Check_Failed:
6173:     case CE_Range_Check_Failed:
6174:     case CE_Invalid_Data:
6175:       if (No (gnat_cond) || Nkind (gnat_cond) != N_Op_Not)
6176:         break;
6177:       gnat_rcond = Right_Opnd (gnat_cond);
6178:       if (Nkind (gnat_rcond) == N_In
6179:           || Nkind (gnat_rcond) == N_Op_Ge
6180:           || Nkind (gnat_rcond) == N_Op_Le)
6181:         {
6182:           const Node_Id gnat_index = Left_Opnd (gnat_rcond);
6183:           const Node_Id gnat_type = Etype (gnat_index);
6184:           tree gnu_index = gnat_to_gnu (gnat_index);
6185:           tree gnu_type = get_unpadded_type (gnat_type);
6186:           tree gnu_low_bound, gnu_high_bound, disp;
6187:           struct loop_info_d *loop;
6188:           bool neg_p;
6189:
6190:           switch (Nkind (gnat_rcond))
6191:             {
6192:             case N_In:
6193:               Range_to_gnu (Right_Opnd (gnat_rcond),
6194:                             &gnu_low_bound, &gnu_high_bound);
6195:               break;
6196:
6197:             case N_Op_Ge:
6198:               gnu_low_bound = gnat_to_gnu (Right_Opnd (gnat_rcond));
6199:               gnu_high_bound = TYPE_MAX_VALUE (gnu_type);
6200:               break;
6201:
6202:             case N_Op_Le:
6203:               gnu_low_bound = TYPE_MIN_VALUE (gnu_type);
6204:               gnu_high_bound = gnat_to_gnu (Right_Opnd (gnat_rcond));
6205:               break;
6206:
6207:             default:
6208:               gcc_unreachable ();
6209:             }
6210:
6211:           gnu_type = maybe_character_type (gnu_type);
6212:           if (TREE_TYPE (gnu_index) != gnu_type)
6213:             {
6214:               gnu_low_bound = convert (gnu_type, gnu_low_bound);
6215:               gnu_high_bound = convert (gnu_type, gnu_high_bound);
6216:               gnu_index = convert (gnu_type, gnu_index);
6217:             }
6218:
6219:           /* Do not print the range information for an enumeration type with
6220:              holes since it is meaningless.  */
6221:           if (with_extra_info
6222:               && !(Nkind (gnat_index) == N_Function_Call
6223:                    && Is_Entity_Name (Name (gnat_index))
6224:                    && Is_Rep_To_Pos (Entity (Name (gnat_index))))
6225:               && Known_Esize (gnat_type)
6226:               && UI_To_Int (Esize (gnat_type)) <= 32)
6227:             gnu_result
6228:               = build_call_raise_range (reason, gnat_node, kind, gnu_index,
6229:                                         gnu_low_bound, gnu_high_bound);
6230:
6231:           /* If optimization is enabled and we are inside a loop, we try to
6232:              compute invariant conditions for checks applied to the iteration
6233:              variable, i.e. conditions that are independent of the variable
6234:              and necessary in order for the checks to fail in the course of
6235:              some iteration.  If we succeed, we consider an alternative:
6236:
6237:                1. If loop unswitching is enabled, we prepend these conditions
6238:                   to the original conditions of the checks.  This will make it
6239:                   possible for the loop unswitching pass to replace the loop
6240:                   with two loops, one of which has the checks eliminated and
6241:                   the other has the original checks reinstated, and a prologue
6242:                   implementing a run-time selection.  The former loop will be
6243:                   for example suitable for vectorization.
6244:
6245:                2. Otherwise, we instead append the conditions to the original
6246:                   conditions of the checks.  At worse, if the conditions cannot
6247:                   be evaluated at compile time, they will be evaluated as true
6248:                   at run time only when the checks have already failed, thus
6249:                   contributing negatively only to the size of the executable.
6250:                   But the hope is that these invariant conditions be evaluated
6251:                   at compile time to false, thus taking away the entire checks
6252:                   with them.  */
6253:           if (optimize
6254:               && inside_loop_p ()
6255:               && (!gnu_low_bound
6256:                   || (gnu_low_bound = gnat_invariant_expr (gnu_low_bound)))
6257:               && (!gnu_high_bound
6258:                   || (gnu_high_bound = gnat_invariant_expr (gnu_high_bound)))
6259:               && (loop = find_loop_for (gnu_index, &disp, &neg_p)))
6260:             {
6261:               struct range_check_info_d *rci = ggc_alloc<range_check_info_d> ();
6262:               rci->low_bound = gnu_low_bound;
6263:               rci->high_bound = gnu_high_bound;
6264:               rci->disp = disp;
6265:               rci->neg_p = neg_p;
6266:               rci->type = gnu_type;
6267:               rci->inserted_cond
6268:                 = build1 (SAVE_EXPR, boolean_type_node, boolean_true_node);
6269:               vec_safe_push (loop->checks, rci);
6270:               gnu_cond = build_noreturn_cond (gnat_to_gnu (gnat_cond));
6271:               if (optimize >= 3)
6272:                 gnu_cond = build_binary_op (TRUTH_ANDIF_EXPR,
6273:                                             boolean_type_node,
6274:                                             rci->inserted_cond,
6275:                                             gnu_cond);
6276:               else
6277:                 gnu_cond = build_binary_op (TRUTH_ANDIF_EXPR,
6278:                                             boolean_type_node,
6279:                                             gnu_cond,
6280:                                             rci->inserted_cond);
6281:             }
6282:         }
6283:       break;
6284:
6285:     default:
6286:       break;
6287:     }
6288:
6289:   /* The following processing does the real work, but we must nevertheless make
6290:      sure not to override the result of the previous processing.  */
6291:   if (!gnu_result)
6292:     gnu_result = build_call_raise (reason, gnat_node, kind);
6293:   set_expr_location_from_node (gnu_result, gnat_node);
6294:
6295:   *gnu_result_type_p = get_unpadded_type (Etype (gnat_node));
6296:
6297:   /* If the type is VOID, this is a statement, so we need to generate the code
6298:      for the call.  Handle a condition, if there is one.  */
6299:   if (VOID_TYPE_P (*gnu_result_type_p))
6300:     {
6301:       if (Present (gnat_cond))
6302:         {
6303:           if (!gnu_cond)
6304:             gnu_cond = gnat_to_gnu (gnat_cond);
6305:           if (integer_zerop (gnu_cond))
6306:             return alloc_stmt_list ();
6307:           gnu_result = build3 (COND_EXPR, void_type_node, gnu_cond, gnu_result,
6308:                                alloc_stmt_list ());
6309:         }
6310:     }
6311:   else
6312:     {
6313:       /* The condition field must not be present when the node is used as an
6314:          expression form.  */
6315:       gigi_checking_assert (No (gnat_cond));
6316:       gnu_result = build1 (NULL_EXPR, *gnu_result_type_p, gnu_result);
6317:     }
6318:
```

## gcc/ada/gcc-interface/trans.cc:7944–8003

```text
7944:     case N_If_Statement:
7945:       {
7946:         tree *gnu_else_ptr; /* Point to put next "else if" or "else".  */
7947:
7948:         /* Make the outer COND_EXPR.  Avoid non-determinism.  */
7949:         gnu_result = build3 (COND_EXPR, void_type_node,
7950:                              gnat_to_gnu (Condition (gnat_node)),
7951:                              NULL_TREE, NULL_TREE);
7952:         COND_EXPR_THEN (gnu_result)
7953:           = build_stmt_group (Then_Statements (gnat_node), false);
7954:         TREE_SIDE_EFFECTS (gnu_result) = 1;
7955:         gnu_else_ptr = &COND_EXPR_ELSE (gnu_result);
7956:
7957:         /* Now make a COND_EXPR for each of the "else if" parts.  Put each
7958:            into the previous "else" part and point to where to put any
7959:            outer "else".  Also avoid non-determinism.  */
7960:         if (Present (Elsif_Parts (gnat_node)))
7961:           for (gnat_temp = First (Elsif_Parts (gnat_node));
7962:                Present (gnat_temp); gnat_temp = Next (gnat_temp))
7963:             {
7964:               gnu_expr = build3 (COND_EXPR, void_type_node,
7965:                                  gnat_to_gnu (Condition (gnat_temp)),
7966:                                  NULL_TREE, NULL_TREE);
7967:               COND_EXPR_THEN (gnu_expr)
7968:                 = build_stmt_group (Then_Statements (gnat_temp), false);
7969:               TREE_SIDE_EFFECTS (gnu_expr) = 1;
7970:               set_expr_location_from_node (gnu_expr, gnat_temp);
7971:               *gnu_else_ptr = gnu_expr;
7972:               gnu_else_ptr = &COND_EXPR_ELSE (gnu_expr);
7973:             }
7974:
7975:         *gnu_else_ptr = build_stmt_group (Else_Statements (gnat_node), false);
7976:       }
7977:       break;
7978:
7979:     case N_Case_Statement:
7980:       gnu_result = Case_Statement_to_gnu (gnat_node);
7981:       break;
7982:
7983:     case N_Loop_Statement:
7984:       gnu_result = Loop_Statement_to_gnu (gnat_node);
7985:       break;
7986:
7987:     case N_Block_Statement:
7988:       /* The only way to enter the block is to fall through to it.  */
7989:       if (stmt_group_may_fallthru ())
7990:         {
7991:           start_stmt_group ();
7992:           gnat_pushlevel ();
7993:           process_decls (Declarations (gnat_node), Empty, true, true);
7994:           add_stmt (gnat_to_gnu (Handled_Statement_Sequence (gnat_node)));
7995:           if (Present (At_End_Proc (gnat_node)))
7996:             At_End_Proc_to_gnu (gnat_node);
7997:           gnat_poplevel ();
7998:           gnu_result = end_stmt_group ();
7999:         }
8000:       else
8001:         gnu_result = alloc_stmt_list ();
8002:       break;
8003:
```

## gcc/ada/gcc-interface/trans.cc:8118–8146

```text
8118:               }
8119:           }
8120:
8121:         else
8122:           gnu_ret_obj = gnu_ret_val = NULL_TREE;
8123:
8124:         /* If we have a return label defined, convert this into a branch to
8125:            that label.  The return proper will be handled elsewhere.  */
8126:         if (gnu_return_label_stack->last ())
8127:           {
8128:             if (gnu_ret_val)
8129:               add_stmt_with_node (build_binary_op (MODIFY_EXPR,
8130:                                                    NULL_TREE, gnu_ret_obj,
8131:                                                    gnu_ret_val),
8132:                                   gnat_node);
8133:
8134:             gnu_result = build1 (GOTO_EXPR, void_type_node,
8135:                                  gnu_return_label_stack->last ());
8136:
8137:             /* When not optimizing, make sure the return is preserved.  */
8138:             if (!optimize && Comes_From_Source (gnat_node))
8139:               DECL_ARTIFICIAL (gnu_return_label_stack->last ()) = 0;
8140:           }
8141:
8142:         /* Otherwise, build a regular return.  */
8143:         else
8144:           gnu_result = build_return_expr (gnu_ret_obj, gnu_ret_val);
8145:       }
8146:       break;
```

## gcc/ada/gcc-interface/trans.cc:8603–8622

```text
8603:     case N_Expression_With_Actions:
8604:       /* This construct doesn't define a scope so we don't push a binding
8605:          level around the statement list, but we wrap it in a SAVE_EXPR to
8606:          protect it from unsharing.  Elaborate the expression as part of the
8607:          same statement group as the actions so that the type declaration
8608:          gets inserted there as well.  This ensures that the type elaboration
8609:          code is issued past the actions computing values on which it might
8610:          depend.  */
8611:       start_stmt_group ();
8612:       add_stmt_list (Actions (gnat_node));
8613:       gnu_expr = gnat_to_gnu (Expression (gnat_node));
8614:       gnu_result = end_stmt_group ();
8615:
8616:       gnu_result = build1 (SAVE_EXPR, void_type_node, gnu_result);
8617:       TREE_SIDE_EFFECTS (gnu_result) = 1;
8618:
8619:       gnu_result
8620:         = build_compound_expr (TREE_TYPE (gnu_expr), gnu_result, gnu_expr);
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

## gcc/ada/gcc-interface/trans.cc:9104–9185

```text
9104: {
9105:   tree type = TREE_TYPE (gnu_decl);
9106:   tree gnu_stmt, gnu_init;
9107:
9108:   /* If this is a variable that Gigi is to ignore, we may have been given
9109:      an ERROR_MARK.  So test for it.  We also might have been given a
9110:      reference for a renaming.  So only do something for a decl.  Also
9111:      ignore a TYPE_DECL for an UNCONSTRAINED_ARRAY_TYPE.  */
9112:   if (!DECL_P (gnu_decl)
9113:       || (TREE_CODE (gnu_decl) == TYPE_DECL
9114:           && TREE_CODE (type) == UNCONSTRAINED_ARRAY_TYPE))
9115:     return;
9116:
9117:   gnu_stmt = build1 (DECL_EXPR, void_type_node, gnu_decl);
9118:
9119:   /* If we are external or global, we don't want to output the DECL_EXPR for
9120:      this DECL node since we already have evaluated the expressions in the
9121:      sizes and positions as globals and doing it again would be wrong.  */
9122:   if (DECL_EXTERNAL (gnu_decl) || global_bindings_p ())
9123:     {
9124:       /* Mark everything as used to prevent node sharing with subprograms.
9125:          Note that walk_tree knows how to deal with TYPE_DECL, but neither
9126:          VAR_DECL nor CONST_DECL.  This appears to be somewhat arbitrary.  */
9127:       MARK_VISITED (gnu_stmt);
9128:       if (VAR_P (gnu_decl)
9129:           || TREE_CODE (gnu_decl) == CONST_DECL)
9130:         {
9131:           MARK_VISITED (DECL_SIZE (gnu_decl));
9132:           MARK_VISITED (DECL_SIZE_UNIT (gnu_decl));
9133:           MARK_VISITED (DECL_INITIAL (gnu_decl));
9134:         }
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
9148:          valid for the context.  Similar to init_const in create_var_decl.  */
9149:       if (!gnat_types_compatible_p (type, TREE_TYPE (gnu_init))
9150:           || (TREE_STATIC (gnu_decl)
9151:               && !initializer_constant_valid_p (gnu_init,
9152:                                                 TREE_TYPE (gnu_init))))
9153:         {
9154:           DECL_INITIAL (gnu_decl) = NULL_TREE;
9155:           if (TREE_READONLY (gnu_decl))
9156:             {
9157:               TREE_READONLY (gnu_decl) = 0;
9158:               DECL_READONLY_ONCE_ELAB (gnu_decl) = 1;
9159:             }
9160:
9161:           /* Remove any padding so the assignment is done properly.  */
9162:           gnu_decl = maybe_padded_object (gnu_decl);
9163:
9164:           gnu_stmt
9165:             = build_binary_op (INIT_EXPR, NULL_TREE, gnu_decl, gnu_init);
9166:           add_stmt_with_node (gnu_stmt, gnat_node);
9167:         }
9168:
9169:       /* If this is the initialization of a (potentially) large aggregate, then
9170:          declare the dependence on the memcpy routine.  */
9171:       if (AGGREGATE_TYPE_P (type)
9172:           && (!TREE_CONSTANT (TYPE_SIZE (type))
9173:               || compare_tree_int (TYPE_SIZE (type), 2 * BITS_PER_WORD) > 0))
9174:         Check_Restriction_No_Dependence_On_System (Name_Memory_Copy,
9175:                                                    gnat_node);
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
```

## gcc/ada/gcc-interface/trans.cc:9217–9278

```text
9217: add_cleanup (tree gnu_cleanup, Node_Id gnat_node)
9218: {
9219:   if (Present (gnat_node))
9220:     set_expr_location_from_node (gnu_cleanup, gnat_node, true);
9221:
9222:   /* An EH_ELSE_EXPR must be by itself, and that's all we need when we
9223:      use it.  The assert below makes sure that is so.  Should we ever
9224:      need more than that, we could combine EH_ELSE_EXPRs, and copy
9225:      non-EH_ELSE_EXPR stmts into both cleanup paths of an
9226:      EH_ELSE_EXPR.  */
9227:   if (TREE_CODE (gnu_cleanup) == EH_ELSE_EXPR)
9228:     {
9229:       gcc_assert (!current_stmt_group->cleanups);
9230:       current_stmt_group->cleanups = gnu_cleanup;
9231:     }
9232:   else
9233:     {
9234:       gcc_assert (!current_stmt_group->cleanups
9235:                   || (TREE_CODE (current_stmt_group->cleanups)
9236:                       != EH_ELSE_EXPR));
9237:       append_to_statement_list (gnu_cleanup, &current_stmt_group->cleanups);
9238:     }
9239: }
9240:
9241: /* Set the BLOCK node corresponding to the current code group to GNU_BLOCK.  */
9242:
9243: void
9244: set_block_for_group (tree gnu_block)
9245: {
9246:   gcc_assert (!current_stmt_group->block);
9247:   current_stmt_group->block = gnu_block;
9248: }
9249:
9250: /* Return code corresponding to the current code group.  It is normally
9251:    a STATEMENT_LIST, but may also be a BIND_EXPR or TRY_FINALLY_EXPR if
9252:    BLOCK or cleanups were set.  */
9253:
9254: tree
9255: end_stmt_group (void)
9256: {
9257:   struct stmt_group *group = current_stmt_group;
9258:   tree gnu_retval = group->stmt_list;
9259:
9260:   /* If this is a null list, allocate a new STATEMENT_LIST.  Then, if there
9261:      are cleanups, make a TRY_FINALLY_EXPR.  Last, if there is a BLOCK,
9262:      make a BIND_EXPR.  Note that we nest in that because the cleanup may
9263:      reference variables in the block.  */
9264:   if (!gnu_retval)
9265:     gnu_retval = alloc_stmt_list ();
9266:
9267:   if (group->cleanups)
9268:     gnu_retval = build2 (TRY_FINALLY_EXPR, void_type_node, gnu_retval,
9269:                          group->cleanups);
9270:
9271:   if (current_stmt_group->block)
9272:     gnu_retval = build3 (BIND_EXPR, void_type_node, BLOCK_VARS (group->block),
9273:                          gnu_retval, group->block);
9274:
9275:   /* Remove this group from the stack and add it to the free list.  */
9276:   current_stmt_group = group->previous;
9277:   group->previous = stmt_group_free_list;
9278:   stmt_group_free_list = group;
```

## gcc/ada/gcc-interface/trans.cc:9298–9325

```text
9298: add_stmt_list (List_Id gnat_list)
9299: {
9300:   Node_Id gnat_node;
9301:
9302:   if (Present (gnat_list))
9303:     for (gnat_node = First (gnat_list); Present (gnat_node);
9304:          gnat_node = Next (gnat_node))
9305:       add_stmt (gnat_to_gnu (gnat_node));
9306: }
9307:
9308: /* Build a tree from GNAT_LIST, a possibly-empty list of statements.
9309:    If BINDING_P is true, push and pop a binding level around the list.  */
9310:
9311: static tree
9312: build_stmt_group (List_Id gnat_list, bool binding_p)
9313: {
9314:   start_stmt_group ();
9315:
9316:   if (binding_p)
9317:     gnat_pushlevel ();
9318:
9319:   add_stmt_list (gnat_list);
9320:
9321:   if (binding_p)
9322:     gnat_poplevel ();
9323:
9324:   return end_stmt_group ();
9325: }
```

## gcc/ada/gcc-interface/trans.cc:9492–9582

```text
9492: gnat_gimplify_stmt (tree *stmt_p)
9493: {
9494:   tree stmt = *stmt_p;
9495:
9496:   switch (TREE_CODE (stmt))
9497:     {
9498:     case STMT_STMT:
9499:       *stmt_p = STMT_STMT_STMT (stmt);
9500:       return GS_OK;
9501:
9502:     case LOOP_STMT:
9503:       {
9504:         tree gnu_start_label = create_artificial_label (input_location);
9505:         tree gnu_cond = LOOP_STMT_COND (stmt);
9506:         tree gnu_update = LOOP_STMT_UPDATE (stmt);
9507:         tree gnu_end_label = LOOP_STMT_LABEL (stmt);
9508:
9509:         /* Build the condition expression from the test, if any.  */
9510:         if (gnu_cond)
9511:           {
9512:             /* Deal with the optimization hints.  */
9513:             if (LOOP_STMT_IVDEP (stmt))
9514:               gnu_cond = build3 (ANNOTATE_EXPR, TREE_TYPE (gnu_cond), gnu_cond,
9515:                                  build_int_cst (integer_type_node,
9516:                                                 annot_expr_ivdep_kind),
9517:                                  integer_zero_node);
9518:             if (LOOP_STMT_NO_UNROLL (stmt))
9519:               gnu_cond = build3 (ANNOTATE_EXPR, TREE_TYPE (gnu_cond), gnu_cond,
9520:                                  build_int_cst (integer_type_node,
9521:                                                 annot_expr_unroll_kind),
9522:                                  integer_one_node);
9523:             if (LOOP_STMT_UNROLL (stmt))
9524:               gnu_cond = build3 (ANNOTATE_EXPR, TREE_TYPE (gnu_cond), gnu_cond,
9525:                                  build_int_cst (integer_type_node,
9526:                                                 annot_expr_unroll_kind),
9527:                                  build_int_cst (NULL_TREE, USHRT_MAX));
9528:             if (LOOP_STMT_NO_VECTOR (stmt))
9529:               gnu_cond = build3 (ANNOTATE_EXPR, TREE_TYPE (gnu_cond), gnu_cond,
9530:                                  build_int_cst (integer_type_node,
9531:                                                 annot_expr_no_vector_kind),
9532:                                  integer_zero_node);
9533:             if (LOOP_STMT_VECTOR (stmt))
9534:               gnu_cond = build3 (ANNOTATE_EXPR, TREE_TYPE (gnu_cond), gnu_cond,
9535:                                  build_int_cst (integer_type_node,
9536:                                                 annot_expr_vector_kind),
9537:                                  integer_zero_node);
9538:
9539:             gnu_cond
9540:               = build3 (COND_EXPR, void_type_node, gnu_cond, NULL_TREE,
9541:                         build1 (GOTO_EXPR, void_type_node, gnu_end_label));
9542:           }
9543:
9544:         /* Set to emit the statements of the loop.  */
9545:         *stmt_p = NULL_TREE;
9546:
9547:         /* We first emit the start label and then a conditional jump to the
9548:            end label if there's a top condition, then the update if it's at
9549:            the top, then the body of the loop, then a conditional jump to
9550:            the end label if there's a bottom condition, then the update if
9551:            it's at the bottom, and finally a jump to the start label and the
9552:            definition of the end label.  */
9553:         append_to_statement_list (build1 (LABEL_EXPR, void_type_node,
9554:                                           gnu_start_label),
9555:                                   stmt_p);
9556:
9557:         if (gnu_cond && !LOOP_STMT_BOTTOM_COND_P (stmt))
9558:           append_to_statement_list (gnu_cond, stmt_p);
9559:
9560:         if (gnu_update && LOOP_STMT_TOP_UPDATE_P (stmt))
9561:           append_to_statement_list (gnu_update, stmt_p);
9562:
9563:         append_to_statement_list (LOOP_STMT_BODY (stmt), stmt_p);
9564:
9565:         if (gnu_cond && LOOP_STMT_BOTTOM_COND_P (stmt))
9566:           append_to_statement_list (gnu_cond, stmt_p);
9567:
9568:         if (gnu_update && !LOOP_STMT_TOP_UPDATE_P (stmt))
9569:           append_to_statement_list (gnu_update, stmt_p);
9570:
9571:         tree t = build1 (GOTO_EXPR, void_type_node, gnu_start_label);
9572:         SET_EXPR_LOCATION (t, DECL_SOURCE_LOCATION (gnu_end_label));
9573:         append_to_statement_list (t, stmt_p);
9574:
9575:         append_to_statement_list (build1 (LABEL_EXPR, void_type_node,
9576:                                           gnu_end_label),
9577:                                   stmt_p);
9578:         return GS_OK;
9579:       }
9580:
9581:     case EXIT_STMT:
9582:       /* Build a statement to jump to the corresponding end label, then
```

## gcc/ada/gcc-interface/trans.cc:9889–10025

```text
9889: process_decls (List_Id gnat_decls, List_Id gnat_decls2,
9890:                bool pass1p, bool pass2p)
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
9901:         for (gnat_decl = First (gnat_decl_array[i]);
9902:              Present (gnat_decl);
9903:              gnat_decl = Next (gnat_decl))
9904:           {
9905:             /* For package specs, we recurse inside the declarations,
9906:                thus taking the two pass approach inside the boundary.  */
9907:             if (Nkind (gnat_decl) == N_Package_Declaration)
9908:               process_decls (Visible_Declarations (Specification (gnat_decl)),
9909:                              Private_Declarations (Specification (gnat_decl)),
9910:                              true, false);
9911:
9912:             /* Similarly for any declarations in the actions of a
9913:                freeze node.  */
9914:             else if (Nkind (gnat_decl) == N_Freeze_Entity)
9915:               {
9916:                 process_freeze_entity (gnat_decl);
9917:                 process_decls (Actions (gnat_decl), Empty, true, false);
9918:               }
9919:
9920:             /* Package bodies with freeze nodes get their elaboration deferred
9921:                until the freeze node, but the code must be placed in the right
9922:                place, so record the code position now.  */
9923:             else if (Nkind (gnat_decl) == N_Package_Body
9924:                      && Present (Freeze_Node (Corresponding_Spec (gnat_decl))))
9925:               record_code_position (gnat_decl);
9926:
9927:             else if (Nkind (gnat_decl) == N_Package_Body_Stub
9928:                      && Present (Library_Unit (gnat_decl))
9929:                      && Present (Freeze_Node
9930:                                  (Corresponding_Spec
9931:                                   (Proper_Body (Unit
9932:                                                 (Library_Unit (gnat_decl)))))))
9933:               record_code_position
9934:                 (Proper_Body (Unit (Library_Unit (gnat_decl))));
9935:
9936:             /* We defer most subprogram bodies to the second pass.  For bodies
9937:                that act as their own specs and stubs, the entity itself must be
9938:                elaborated in the first pass, because it may be used in other
9939:                declarations.  */
9940:             else if (Nkind (gnat_decl) == N_Subprogram_Body)
9941:               {
9942:                 if (Acts_As_Spec (gnat_decl))
9943:                   {
9944:                     Entity_Id gnat_subprog = Defining_Entity (gnat_decl);
9945:
9946:                     if (!Is_Generic_Subprogram (gnat_subprog))
9947:                       gnat_to_gnu_entity (gnat_subprog, NULL_TREE, true);
9948:                   }
9949:               }
9950:
9951:             else if (Nkind (gnat_decl) == N_Subprogram_Body_Stub)
9952:               {
9953:                 Entity_Id gnat_subprog
9954:                   = Defining_Entity (Specification (gnat_decl));
9955:
9956:                 if (!Is_Generic_Subprogram (gnat_subprog)
9957:                     && Ekind (gnat_subprog) != E_Subprogram_Body)
9958:                   gnat_to_gnu_entity (gnat_subprog, NULL_TREE, true);
9959:               }
9960:
9961:             /* Concurrent stubs stand for the corresponding subprogram bodies,
9962:                which are deferred like other bodies.  */
9963:             else if (Nkind (gnat_decl) == N_Task_Body_Stub
9964:                      || Nkind (gnat_decl) == N_Protected_Body_Stub)
9965:               ;
9966:
9967:             /* Renamed subprograms may not be elaborated yet at this point
9968:                since renamings do not trigger freezing.  Wait for the second
9969:                pass to take care of them.  */
9970:             else if (Nkind (gnat_decl) == N_Subprogram_Renaming_Declaration)
9971:               ;
9972:
9973:             else
9974:               add_stmt (gnat_to_gnu (gnat_decl));
9975:           }
9976:
9977:   /* Here we elaborate everything we deferred above except for package bodies,
9978:      which are elaborated at their freeze nodes.  Note that we must also
9979:      go inside things (package specs and freeze nodes) the first pass did.  */
9980:   if (pass2p)
9981:     for (i = 0; i <= 1; i++)
9982:       if (Present (gnat_decl_array[i]))
9983:         for (gnat_decl = First (gnat_decl_array[i]);
9984:              Present (gnat_decl);
9985:              gnat_decl = Next (gnat_decl))
9986:           {
9987:             if (Nkind (gnat_decl) == N_Subprogram_Body
9988:                 || Nkind (gnat_decl) == N_Subprogram_Body_Stub
9989:                 || Nkind (gnat_decl) == N_Task_Body_Stub
9990:                 || Nkind (gnat_decl) == N_Protected_Body_Stub)
9991:               add_stmt (gnat_to_gnu (gnat_decl));
9992:
9993:             else if (Nkind (gnat_decl) == N_Package_Declaration)
9994:               process_decls (Visible_Declarations (Specification (gnat_decl)),
9995:                              Private_Declarations (Specification (gnat_decl)),
9996:                              false, true);
9997:
9998:             else if (Nkind (gnat_decl) == N_Freeze_Entity)
9999:               process_decls (Actions (gnat_decl), Empty, false, true);
10000:
10001:             else if (Nkind (gnat_decl) == N_Subprogram_Renaming_Declaration)
10002:               add_stmt (gnat_to_gnu (gnat_decl));
10003:           }
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
10015:                       Node_Id gnat_node)
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

## gcc/ada/gcc-interface/trans.cc:10014–10494

```text
10014: build_unary_op_trapv (enum tree_code code, tree gnu_type, tree operand,
10015:                       Node_Id gnat_node)
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
10026:     {
10027:       if (code == ABS_EXPR)
10028:         return gnu_expr;
10029:       else
10030:         check = build_binary_op (NE_EXPR, boolean_type_node,
10031:                                  operand, TYPE_MIN_VALUE (gnu_type));
10032:     }
10033:   else
10034:     check = build_binary_op (EQ_EXPR, boolean_type_node,
10035:                              operand, TYPE_MIN_VALUE (gnu_type));
10036:
10037:   return emit_check (check, gnu_expr, CE_Overflow_Check_Failed, gnat_node);
10038: }
10039:
10040: /* Make a binary operation of kind CODE using build_binary_op, but guard
10041:    the operation by an overflow check.  CODE can be one of PLUS_EXPR,
10042:    MINUS_EXPR or MULT_EXPR.  GNU_TYPE is the type desired for the result.
10043:    Usually the operation is to be performed in that type.  GNAT_NODE is
10044:    the GNAT node conveying the source location for which the error should
10045:    be signaled.  */
10046:
10047: static tree
10048: build_binary_op_trapv (enum tree_code code, tree gnu_type, tree left,
10049:                        tree right, Node_Id gnat_node)
10050: {
10051:   const unsigned int precision = TYPE_PRECISION (gnu_type);
10052:   tree lhs = gnat_protect_expr (left);
10053:   tree rhs = gnat_protect_expr (right);
10054:   tree type_max = TYPE_MAX_VALUE (gnu_type);
10055:   tree type_min = TYPE_MIN_VALUE (gnu_type);
10056:   tree gnu_expr, check;
10057:   int sgn;
10058:
10059:   /* Assert that the precision is a power of 2.  */
10060:   gcc_assert ((precision & (precision - 1)) == 0);
10061:
10062:   /* Prefer a constant on the RHS to simplify checks.  */
10063:   if (TREE_CODE (rhs) != INTEGER_CST
10064:       && TREE_CODE (lhs) == INTEGER_CST
10065:       && (code == PLUS_EXPR || code == MULT_EXPR))
10066:     {
10067:       tree tmp = lhs;
10068:       lhs = rhs;
10069:       rhs = tmp;
10070:     }
10071:
10072:   gnu_expr = build_binary_op (code, gnu_type, lhs, rhs);
10073:
10074:   /* If we can fold the expression to a constant, just return it.
10075:      The caller will deal with overflow, no need to generate a check.  */
10076:   if (TREE_CODE (gnu_expr) == INTEGER_CST)
10077:     return gnu_expr;
10078:
10079:   /* If no operand is a constant, we use the generic implementation.  */
10080:   if (TREE_CODE (lhs) != INTEGER_CST && TREE_CODE (rhs) != INTEGER_CST)
10081:     {
10082:       /* First convert the operands to the result type like build_binary_op.
10083:          This is where the bias is made explicit for biased types.  */
10084:       lhs = convert (gnu_type, lhs);
10085:       rhs = convert (gnu_type, rhs);
10086:
10087:       /* Never inline a 64-bit mult for a 32-bit target, it's way too long.  */
10088:       if (code == MULT_EXPR && precision == 64 && BITS_PER_WORD < 64)
10089:         {
10090:           tree int64 = gnat_type_for_size (64, TYPE_UNSIGNED (gnu_type));
10091:           Check_Restriction_No_Dependence_On_System (Name_Arith_64, gnat_node);
10092:           return
10093:             convert (gnu_type, build_call_n_expr (TYPE_UNSIGNED (gnu_type)
10094:                                                   ? uns_mulv64_decl
10095:                                                   : mulv64_decl,
10096:                                                   2,
10097:                                                   convert (int64, lhs),
10098:                                                   convert (int64, rhs)));
10099:         }
10100:
10101:       /* Likewise for a 128-bit mult and a 64-bit target.  */
10102:       else if (code == MULT_EXPR && precision == 128 && BITS_PER_WORD < 128)
10103:         {
10104:           tree int128 = gnat_type_for_size (128, TYPE_UNSIGNED (gnu_type));
10105:           Check_Restriction_No_Dependence_On_System (Name_Arith_128, gnat_node);
10106:           return
10107:             convert (gnu_type, build_call_n_expr (TYPE_UNSIGNED (gnu_type)
10108:                                                   ? uns_mulv128_decl
10109:                                                   : mulv128_decl,
10110:                                                   2,
10111:                                                   convert (int128, lhs),
10112:                                                   convert (int128, rhs)));
10113:         }
10114:
10115:       enum internal_fn icode;
10116:
10117:       switch (code)
10118:         {
10119:         case PLUS_EXPR:
10120:           icode = IFN_ADD_OVERFLOW;
10121:           break;
10122:         case MINUS_EXPR:
10123:           icode = IFN_SUB_OVERFLOW;
10124:           break;
10125:         case MULT_EXPR:
10126:           icode = IFN_MUL_OVERFLOW;
10127:           break;
10128:         default:
10129:           gcc_unreachable ();
10130:         }
10131:
10132:       tree gnu_ctype = build_complex_type (gnu_type);
10133:       tree call
10134:         = build_call_expr_internal_loc (UNKNOWN_LOCATION, icode, gnu_ctype, 2,
10135:                                         lhs, rhs);
10136:       tree tgt = save_expr (call);
10137:       gnu_expr = build1 (REALPART_EXPR, gnu_type, tgt);
10138:       check = fold_build2 (NE_EXPR, boolean_type_node,
10139:                            build1 (IMAGPART_EXPR, gnu_type, tgt),
10140:                            build_int_cst (gnu_type, 0));
10141:       return
10142:         emit_check (check, gnu_expr, CE_Overflow_Check_Failed, gnat_node);
10143:    }
10144:
10145:   /* If one operand is a constant, we expose the overflow condition to enable
10146:      a subsequent simplification or even elimination.  */
10147:   switch (code)
10148:     {
10149:     case PLUS_EXPR:
10150:       sgn = tree_int_cst_sgn (rhs);
10151:       if (sgn > 0)
10152:         /* When rhs > 0, overflow when lhs > type_max - rhs.  */
10153:         check = build_binary_op (GT_EXPR, boolean_type_node, lhs,
10154:                                  build_binary_op (MINUS_EXPR, gnu_type,
10155:                                                   type_max, rhs));
10156:       else if (sgn < 0)
10157:         /* When rhs < 0, overflow when lhs < type_min - rhs.  */
10158:         check = build_binary_op (LT_EXPR, boolean_type_node, lhs,
10159:                                  build_binary_op (MINUS_EXPR, gnu_type,
10160:                                                   type_min, rhs));
10161:       else
10162:         return gnu_expr;
10163:       break;
10164:
10165:     case MINUS_EXPR:
10166:       if (TREE_CODE (lhs) == INTEGER_CST && TYPE_UNSIGNED (gnu_type))
10167:         /* In the unsigned case, overflow when rhs > lhs - type_min.  */
10168:         check = build_binary_op (GT_EXPR, boolean_type_node, rhs,
10169:                                  build_binary_op (MINUS_EXPR, gnu_type,
10170:                                                   lhs, type_min));
10171:       else if (TREE_CODE (lhs) == INTEGER_CST)
10172:         {
10173:           sgn = tree_int_cst_sgn (lhs);
10174:           if (sgn >= 0)
10175:             /* When lhs >= 0, overflow when rhs < lhs - type_max.  */
10176:             check = build_binary_op (LT_EXPR, boolean_type_node, rhs,
10177:                                      build_binary_op (MINUS_EXPR, gnu_type,
10178:                                                       lhs, type_max));
10179:           else
10180:             /* When lhs < 0, overflow when rhs > lhs - type_min.  */
10181:             check = build_binary_op (GT_EXPR, boolean_type_node, rhs,
10182:                                      build_binary_op (MINUS_EXPR, gnu_type,
10183:                                                       lhs, type_min));
10184:         }
10185:       else
10186:         {
10187:           sgn = tree_int_cst_sgn (rhs);
10188:           if (sgn > 0)
10189:             /* When rhs > 0, overflow when lhs < type_min + rhs.  */
10190:             check = build_binary_op (LT_EXPR, boolean_type_node, lhs,
10191:                                      build_binary_op (PLUS_EXPR, gnu_type,
10192:                                                       type_min, rhs));
10193:           else if (sgn < 0)
10194:             /* When rhs < 0, overflow when lhs > type_max + rhs.  */
10195:             check = build_binary_op (GT_EXPR, boolean_type_node, lhs,
10196:                                      build_binary_op (PLUS_EXPR, gnu_type,
10197:                                                       type_max, rhs));
10198:           else
10199:             return gnu_expr;
10200:         }
10201:       break;
10202:
10203:     case MULT_EXPR:
10204:       sgn = tree_int_cst_sgn (rhs);
10205:       if (sgn > 0)
10206:         {
10207:           if (integer_onep (rhs))
10208:             return gnu_expr;
10209:
10210:           tree lb = build_binary_op (TRUNC_DIV_EXPR, gnu_type, type_min, rhs);
10211:           tree ub = build_binary_op (TRUNC_DIV_EXPR, gnu_type, type_max, rhs);
10212:
10213:           /* When rhs > 1, overflow outside [type_min/rhs; type_max/rhs].  */
10214:           check
10215:             = build_binary_op (TRUTH_ORIF_EXPR, boolean_type_node,
10216:                                build_binary_op (LT_EXPR, boolean_type_node,
10217:                                                 lhs, lb),
10218:                                build_binary_op (GT_EXPR, boolean_type_node,
10219:                                                 lhs, ub));
10220:         }
10221:       else if (sgn < 0)
10222:         {
10223:           tree lb = build_binary_op (TRUNC_DIV_EXPR, gnu_type, type_max, rhs);
10224:           tree ub = build_binary_op (TRUNC_DIV_EXPR, gnu_type, type_min, rhs);
10225:
10226:           if (integer_minus_onep (rhs))
10227:             /* When rhs == -1, overflow if lhs == type_min.  */
10228:             check
10229:               = build_binary_op (EQ_EXPR, boolean_type_node, lhs, type_min);
10230:           else
10231:             /* When rhs < -1, overflow outside [type_max/rhs; type_min/rhs].  */
10232:             check
10233:               = build_binary_op (TRUTH_ORIF_EXPR, boolean_type_node,
10234:                                  build_binary_op (LT_EXPR, boolean_type_node,
10235:                                                   lhs, lb),
10236:                                  build_binary_op (GT_EXPR, boolean_type_node,
10237:                                                   lhs, ub));
10238:         }
10239:       else
10240:         return gnu_expr;
10241:       break;
10242:
10243:     default:
10244:       gcc_unreachable ();
10245:     }
10246:
10247:   return emit_check (check, gnu_expr, CE_Overflow_Check_Failed, gnat_node);
10248: }
10249:
10250: /* GNU_COND contains the condition corresponding to an index, overflow or
10251:    range check of value GNU_EXPR.  Build a COND_EXPR that returns GNU_EXPR
10252:    if GNU_COND is false and raises a CONSTRAINT_ERROR if GNU_COND is true.
10253:    REASON is the code that says why the exception is raised.  GNAT_NODE is
10254:    the node conveying the source location for which the error should be
10255:    signaled.
10256:
10257:    We used to propagate TREE_SIDE_EFFECTS from GNU_EXPR to the COND_EXPR,
10258:    overwriting the setting inherited from the call statement, on the ground
10259:    that the expression need not be evaluated just for the check.  However
10260:    that's incorrect because, in the GCC type system, its value is presumed
10261:    to be valid so its comparison against the type bounds always yields true
10262:    and, therefore, could be done without evaluating it; given that it can
10263:    be a computation that overflows the bounds, the language may require the
10264:    check to fail and thus the expression to be evaluated in this case.  */
10265:
10266: static tree
10267: emit_check (tree gnu_cond, tree gnu_expr, int reason, Node_Id gnat_node)
10268: {
10269:   tree gnu_call
10270:     = build_call_raise (reason, gnat_node, N_Raise_Constraint_Error);
10271:   return
10272:     fold_build3 (COND_EXPR, TREE_TYPE (gnu_expr), gnu_cond,
10273:                  build2 (COMPOUND_EXPR, TREE_TYPE (gnu_expr), gnu_call,
10274:                          SCALAR_FLOAT_TYPE_P (TREE_TYPE (gnu_expr))
10275:                          ? build_real (TREE_TYPE (gnu_expr), dconst0)
10276:                          : build_int_cst (TREE_TYPE (gnu_expr), 0)),
10277:                  gnu_expr);
10278: }
10279:
10280: /* Return an expression that converts GNU_EXPR to GNAT_TYPE, doing overflow
10281:    checks if OVERFLOW_P is true.  If TRUNCATE_P is true, do a fp-to-integer
10282:    conversion with truncation, otherwise round.  GNAT_NODE is the GNAT node
10283:    conveying the source location for which the error should be signaled.  */
10284:
10285: static tree
10286: convert_with_check (Entity_Id gnat_type, tree gnu_expr, bool overflow_p,
10287:                     bool truncate_p, Node_Id gnat_node)
10288: {
10289:   tree gnu_type = get_unpadded_type (gnat_type);
10290:   tree gnu_base_type = get_base_type (gnu_type);
10291:   tree gnu_in_type = TREE_TYPE (gnu_expr);
10292:   tree gnu_in_base_type = get_base_type (gnu_in_type);
10293:   tree gnu_result = gnu_expr;
10294:
10295:   /* If we are not doing any checks, the output is an integral type and the
10296:      input is not a floating-point type, just do the conversion.  This is
10297:      required for packed array types and is simpler in all cases anyway.   */
10298:   if (!overflow_p
10299:       && INTEGRAL_TYPE_P (gnu_base_type)
10300:       && !FLOAT_TYPE_P (gnu_in_base_type))
10301:     return convert (gnu_type, gnu_expr);
10302:
10303:   /* If the mode of the input base type is larger, then converting to it below
10304:      may pessimize the final conversion step, for example generate a libcall
10305:      instead of a simple instruction, so use a narrower type in this case.  */
10306:   if (TYPE_MODE (gnu_in_base_type) != TYPE_MODE (gnu_in_type)
10307:       && !(TREE_CODE (gnu_in_type) == INTEGER_TYPE
10308:            && TYPE_BIASED_REPRESENTATION_P (gnu_in_type)))
10309:     gnu_in_base_type = gnat_type_for_mode (TYPE_MODE (gnu_in_type),
10310:                                            TYPE_UNSIGNED (gnu_in_type));
10311:
10312:   /* First convert the expression to the base type.  This will never generate
10313:      code, but makes the tests below simpler.  But don't do this if converting
10314:      from an integer type to an unconstrained array type since then we need to
10315:      get the bounds from the original (unpacked) type.  */
10316:   if (TREE_CODE (gnu_type) != UNCONSTRAINED_ARRAY_TYPE)
10317:     gnu_result = convert (gnu_in_base_type, gnu_result);
10318:
10319:   /* If overflow checks are requested,  we need to be sure the result will fit
10320:      in the output base type.  But don't do this if the input is integer and
10321:      the output floating-point.  */
10322:   if (overflow_p
10323:       && !(FLOAT_TYPE_P (gnu_base_type) && INTEGRAL_TYPE_P (gnu_in_base_type)))
10324:     {
10325:       /* Ensure GNU_EXPR only gets evaluated once.  */
10326:       tree gnu_input = gnat_protect_expr (gnu_result);
10327:       tree gnu_cond = boolean_false_node;
10328:       tree gnu_in_lb = TYPE_MIN_VALUE (gnu_in_base_type);
10329:       tree gnu_in_ub = TYPE_MAX_VALUE (gnu_in_base_type);
10330:       tree gnu_out_lb = TYPE_MIN_VALUE (gnu_base_type);
10331:       tree gnu_out_ub
10332:         = (TREE_CODE (gnu_base_type) == INTEGER_TYPE
10333:            && TYPE_MODULAR_P (gnu_base_type))
10334:           ? fold_build2 (MINUS_EXPR, gnu_base_type,
10335:                          TYPE_MODULUS (gnu_base_type),
10336:                          build_int_cst (gnu_base_type, 1))
10337:           : TYPE_MAX_VALUE (gnu_base_type);
10338:
10339:       /* Convert the lower bounds to signed types, so we're sure we're
10340:          comparing them properly.  Likewise, convert the upper bounds
10341:          to unsigned types.  */
10342:       if (INTEGRAL_TYPE_P (gnu_in_base_type)
10343:           && TYPE_UNSIGNED (gnu_in_base_type))
10344:         gnu_in_lb
10345:           = convert (gnat_signed_type_for (gnu_in_base_type), gnu_in_lb);
10346:
10347:       if (INTEGRAL_TYPE_P (gnu_in_base_type)
10348:           && !TYPE_UNSIGNED (gnu_in_base_type))
10349:         gnu_in_ub
10350:           = convert (gnat_unsigned_type_for (gnu_in_base_type), gnu_in_ub);
10351:
10352:       if (INTEGRAL_TYPE_P (gnu_base_type) && TYPE_UNSIGNED (gnu_base_type))
10353:         gnu_out_lb
10354:           = convert (gnat_signed_type_for (gnu_base_type), gnu_out_lb);
10355:
10356:       if (INTEGRAL_TYPE_P (gnu_base_type) && !TYPE_UNSIGNED (gnu_base_type))
10357:         gnu_out_ub
10358:           = convert (gnat_unsigned_type_for (gnu_base_type), gnu_out_ub);
10359:
10360:       /* Check each bound separately and only if the result bound
10361:          is tighter than the bound on the input type.  Note that all the
10362:          types are base types, so the bounds must be constant. Also,
10363:          the comparison is done in the base type of the input, which
10364:          always has the proper signedness.  First check for input
10365:          integer (which means output integer), output float (which means
10366:          both float), or mixed, in which case we always compare.
10367:          Note that we have to do the comparison which would *fail* in the
10368:          case of an error since if it's an FP comparison and one of the
10369:          values is a NaN or Inf, the comparison will fail.  */
10370:       if (INTEGRAL_TYPE_P (gnu_in_base_type)
10371:           ? tree_int_cst_lt (gnu_in_lb, gnu_out_lb)
10372:           : (FLOAT_TYPE_P (gnu_base_type)
10373:              ? real_less (&TREE_REAL_CST (gnu_in_lb),
10374:                           &TREE_REAL_CST (gnu_out_lb))
10375:              : 1))
10376:         gnu_cond
10377:           = invert_truthvalue
10378:             (build_binary_op (GE_EXPR, boolean_type_node,
10379:                               gnu_input, convert (gnu_in_base_type,
10380:                                                   gnu_out_lb)));
10381:
10382:       if (INTEGRAL_TYPE_P (gnu_in_base_type)
10383:           ? tree_int_cst_lt (gnu_out_ub, gnu_in_ub)
10384:           : (FLOAT_TYPE_P (gnu_base_type)
10385:              ? real_less (&TREE_REAL_CST (gnu_out_ub),
10386:                           &TREE_REAL_CST (gnu_in_ub))
10387:              : 1))
10388:         gnu_cond
10389:           = build_binary_op (TRUTH_ORIF_EXPR, boolean_type_node, gnu_cond,
10390:                              invert_truthvalue
10391:                              (build_binary_op (LE_EXPR, boolean_type_node,
10392:                                                gnu_input,
10393:                                                convert (gnu_in_base_type,
10394:                                                         gnu_out_ub))));
10395:
10396:       if (!integer_zerop (gnu_cond))
10397:         gnu_result = emit_check (gnu_cond, gnu_input,
10398:                                  CE_Overflow_Check_Failed, gnat_node);
10399:     }
10400:
10401:   /* Now convert to the result base type.  If this is a non-truncating
10402:      float-to-integer conversion, round.  */
10403:   if (INTEGRAL_TYPE_P (gnu_base_type)
10404:       && FLOAT_TYPE_P (gnu_in_base_type)
10405:       && !truncate_p)
10406:     {
10407:       REAL_VALUE_TYPE half_minus_pred_half, pred_half;
10408:       tree gnu_conv, gnu_zero, gnu_comp, calc_type;
10409:       tree gnu_pred_half, gnu_add_pred_half, gnu_subtract_pred_half;
10410:       const struct real_format *fmt;
10411:
10412:       /* The following calculations depend on proper rounding to even
10413:          of each arithmetic operation.  In order to prevent excess
10414:          precision from spoiling this property, use the widest hardware
10415:          floating-point type if FP_ARITH_MAY_WIDEN is true.  */
10416:       calc_type
10417:         = fp_arith_may_widen ? longest_float_type_node : gnu_in_base_type;
10418:
10419:       /* Compute the exact value calc_type'Pred (0.5) at compile time.  */
10420:       fmt = REAL_MODE_FORMAT (TYPE_MODE (calc_type));
10421:       real_2expN (&half_minus_pred_half, -(fmt->p) - 1, TYPE_MODE (calc_type));
10422:       real_arithmetic (&pred_half, MINUS_EXPR, &dconsthalf,
10423:                        &half_minus_pred_half);
10424:       gnu_pred_half = build_real (calc_type, pred_half);
10425:
10426:       /* If the input is strictly negative, subtract this value
10427:          and otherwise add it from the input.  For 0.5, the result
10428:          is exactly between 1.0 and the machine number preceding 1.0
10429:          (for calc_type).  Since the last bit of 1.0 is even, this 0.5
10430:          will round to 1.0, while all other number with an absolute
10431:          value less than 0.5 round to 0.0.  For larger numbers exactly
10432:          halfway between integers, rounding will always be correct as
10433:          the true mathematical result will be closer to the higher
10434:          integer compared to the lower one.  So, this constant works
10435:          for all floating-point numbers.
10436:
10437:          The reason to use the same constant with subtract/add instead
10438:          of a positive and negative constant is to allow the comparison
10439:          to be scheduled in parallel with retrieval of the constant and
10440:          conversion of the input to the calc_type (if necessary).  */
10441:
10442:       gnu_zero = build_real (gnu_in_base_type, dconst0);
10443:       gnu_result = gnat_protect_expr (gnu_result);
10444:       gnu_conv = convert (calc_type, gnu_result);
10445:       gnu_comp
10446:         = fold_build2 (GE_EXPR, boolean_type_node, gnu_result, gnu_zero);
10447:       gnu_add_pred_half
10448:         = fold_build2 (PLUS_EXPR, calc_type, gnu_conv, gnu_pred_half);
10449:       gnu_subtract_pred_half
10450:         = fold_build2 (MINUS_EXPR, calc_type, gnu_conv, gnu_pred_half);
10451:       gnu_result = fold_build3 (COND_EXPR, calc_type, gnu_comp,
10452:                                 gnu_add_pred_half, gnu_subtract_pred_half);
10453:     }
10454:
10455:   if (TREE_CODE (gnu_base_type) == INTEGER_TYPE
10456:       && TYPE_HAS_ACTUAL_BOUNDS_P (gnu_base_type)
10457:       && TREE_CODE (gnu_result) == UNCONSTRAINED_ARRAY_REF)
10458:     gnu_result = unchecked_convert (gnu_base_type, gnu_result, false);
10459:   else
10460:     gnu_result = convert (gnu_base_type, gnu_result);
10461:
10462:   /* If this is a conversion between an integer type larger than a word and a
10463:      floating-point type, then declare the dependence on the libgcc routine.  */
10464:   if ((INTEGRAL_TYPE_P (gnu_in_base_type)
10465:        && TYPE_PRECISION (gnu_in_base_type) > BITS_PER_WORD
10466:        && FLOAT_TYPE_P (gnu_base_type))
10467:       || (FLOAT_TYPE_P (gnu_in_base_type)
10468:           && INTEGRAL_TYPE_P (gnu_base_type)
10469:           && TYPE_PRECISION (gnu_base_type) > BITS_PER_WORD))
10470:     Check_Restriction_No_Dependence_On_System (Name_Gcc, gnat_node);
10471:
10472:   return convert (gnu_type, gnu_result);
10473: }
10474:
10475: /* Return true if GNU_EXPR may be directly addressed.  This is the case
10476:    unless it is an expression involving computation or if it involves a
10477:    reference to a bitfield or to an object not sufficiently aligned for
10478:    its type.  If GNU_TYPE is non-null, return true only if GNU_EXPR can
10479:    be directly addressed as an object of this type.  COMPG is true when
10480:    the predicate is invoked for compiler-generated code.
10481:
10482:    *** Notes on addressability issues in the Ada compiler ***
10483:
10484:    This predicate is necessary in order to bridge the gap between Gigi
10485:    and the middle-end about addressability of GENERIC trees.  A tree
10486:    is said to be addressable if it can be directly addressed, i.e. if
10487:    its address can be taken, is a multiple of the type's alignment on
10488:    strict-alignment architectures and returns the first storage unit
10489:    assigned to the object represented by the tree.
10490:
10491:    In the C family of languages, everything is in practice addressable
10492:    at the language level, except for bit-fields.  This means that these
10493:    compilers will take the address of any tree that doesn't represent
10494:    a bit-field reference and expect the result to be the first storage
```

## gcc/ada/gcc-interface/utils.cc:682–783

```text
682: gnat_pushlevel (void)
683: {
684:   struct gnat_binding_level *newlevel = NULL;
685:
686:   /* Reuse a struct for this binding level, if there is one.  */
687:   if (free_binding_level)
688:     {
689:       newlevel = free_binding_level;
690:       free_binding_level = free_binding_level->chain;
691:     }
692:   else
693:     newlevel = ggc_alloc<gnat_binding_level> ();
694:
695:   /* Use a free BLOCK, if any; otherwise, allocate one.  */
696:   if (free_block_chain)
697:     {
698:       newlevel->block = free_block_chain;
699:       free_block_chain = BLOCK_CHAIN (free_block_chain);
700:       BLOCK_CHAIN (newlevel->block) = NULL_TREE;
701:     }
702:   else
703:     newlevel->block = make_node (BLOCK);
704:
705:   /* Point the BLOCK we just made to its parent.  */
706:   if (current_binding_level)
707:     BLOCK_SUPERCONTEXT (newlevel->block) = current_binding_level->block;
708:
709:   BLOCK_VARS (newlevel->block) = NULL_TREE;
710:   BLOCK_SUBBLOCKS (newlevel->block) = NULL_TREE;
711:   TREE_USED (newlevel->block) = 1;
712:
713:   /* Add this level to the front of the chain (stack) of active levels.  */
714:   newlevel->chain = current_binding_level;
715:   current_binding_level = newlevel;
716: }
717:
718: /* Set SUPERCONTEXT of the BLOCK for the current binding level to FNDECL
719:    and point FNDECL to this BLOCK.  */
720:
721: void
722: set_current_block_context (tree fndecl)
723: {
724:   BLOCK_SUPERCONTEXT (current_binding_level->block) = fndecl;
725:   DECL_INITIAL (fndecl) = current_binding_level->block;
726:   set_block_for_group (current_binding_level->block);
727: }
728:
729: /* Exit a binding level.  Set any BLOCK into the current code group.  */
730:
731: void
732: gnat_poplevel (void)
733: {
734:   struct gnat_binding_level *level = current_binding_level;
735:   tree block = level->block;
736:
737:   BLOCK_VARS (block) = nreverse (BLOCK_VARS (block));
738:   BLOCK_SUBBLOCKS (block) = blocks_nreverse (BLOCK_SUBBLOCKS (block));
739:
740:   /* If this is a function-level BLOCK don't do anything.  Otherwise, if there
741:      are no variables free the block and merge its subblocks into those of its
742:      parent block.  Otherwise, add it to the list of its parent.  */
743:   if (TREE_CODE (BLOCK_SUPERCONTEXT (block)) == FUNCTION_DECL)
744:     ;
745:   else if (!BLOCK_VARS (block))
746:     {
747:       BLOCK_SUBBLOCKS (level->chain->block)
748:         = block_chainon (BLOCK_SUBBLOCKS (block),
749:                          BLOCK_SUBBLOCKS (level->chain->block));
750:       BLOCK_CHAIN (block) = free_block_chain;
751:       free_block_chain = block;
752:     }
753:   else
754:     {
755:       BLOCK_CHAIN (block) = BLOCK_SUBBLOCKS (level->chain->block);
756:       BLOCK_SUBBLOCKS (level->chain->block) = block;
757:       TREE_USED (block) = 1;
758:       set_block_for_group (block);
759:     }
760:
761:   /* Free this binding structure.  */
762:   current_binding_level = level->chain;
763:   level->chain = free_binding_level;
764:   free_binding_level = level;
765: }
766:
767: /* Exit a binding level and discard the associated BLOCK.  */
768:
769: void
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

## gcc/ada/gcc-interface/utils.cc:894–1018

```text
894: gnat_pushdecl (tree decl, Node_Id gnat_node)
895: {
896:   tree context = NULL_TREE;
897:   struct deferred_decl_context_node *deferred_decl_context = NULL;
898:
899:   /* If explicitly asked to make DECL global or if it's an imported nested
900:      object, short-circuit the regular Scope-based context computation.  */
901:   if (!((TREE_PUBLIC (decl) && DECL_EXTERNAL (decl)) || force_global == 1))
902:     {
903:       /* Rely on the GNAT scope, or fallback to the current_function_decl if
904:          the GNAT scope reached the global scope, if it reached a subprogram
905:          or the declaration is a subprogram or a variable (for them we skip
906:          intermediate context types because the subprogram body elaboration
907:          machinery and the inliner both expect a subprogram context).
908:
909:          Falling back to current_function_decl is necessary for implicit
910:          subprograms created by gigi, such as the elaboration subprograms.  */
911:       bool context_is_subprogram = false;
912:       const Entity_Id gnat_scope
913:         = get_debug_scope (gnat_node, &context_is_subprogram);
914:
915:       if (Present (gnat_scope)
916:           && !context_is_subprogram
917:           && TREE_CODE (decl) != FUNCTION_DECL
918:           && TREE_CODE (decl) != VAR_DECL)
919:         /* Always assume the scope has not been elaborated, thus defer the
920:            context propagation to the time its elaboration will be
921:            available.  */
922:         deferred_decl_context
923:           = add_deferred_decl_context (decl, gnat_scope, force_global);
924:
925:       /* External declarations (when force_global > 0) may not be in a
926:          local context.  */
927:       else if (current_function_decl && force_global == 0)
928:         context = current_function_decl;
929:     }
930:
931:   /* If either we are forced to be in global mode or if both the GNAT scope and
932:      the current_function_decl did not help in determining the context, use the
933:      global scope.  */
934:   if (!deferred_decl_context && !context)
935:     context = get_global_context ();
936:
937:   /* Mark functions really nested in another function, that is to say defined
938:      there as opposed to imported from elsewhere, as initially needing a static
939:      chain for the sake of uniformity (lower_nested_functions will recompute it
940:      exacly later) and as private to the translation unit (the static chain may
941:      be clobbered by calling conventions used across translation units).  */
942:   if (TREE_CODE (decl) == FUNCTION_DECL
943:       && !DECL_EXTERNAL (decl)
944:       && context
945:       && (TREE_CODE (context) == FUNCTION_DECL
946:           || decl_function_context (context)))
947:     {
948:       DECL_STATIC_CHAIN (decl) = 1;
949:       TREE_PUBLIC (decl) = 0;
950:     }
951:
952:   if (!deferred_decl_context)
953:     DECL_CONTEXT (decl) = context;
954:
955:   /* Disable warnings for compiler-generated entities or explicit request.  */
956:   if (No (gnat_node)
957:       || !Comes_From_Source (gnat_node)
958:       || Warnings_Off (gnat_node))
959:     suppress_warning (decl);
960:
961:   /* Set the location of DECL and emit a declaration for it.  */
962:   if (Present (gnat_node) && !renaming_from_instantiation_p (gnat_node))
963:     Sloc_to_locus (Sloc (gnat_node), &DECL_SOURCE_LOCATION (decl));
964:
965:   add_decl_expr (decl, gnat_node);
966:
967:   /* Put the declaration on the list.  The list of declarations is in reverse
968:      order.  The list will be reversed later.  Put global declarations in the
969:      globals list and local ones in the current block.  But skip TYPE_DECLs
970:      for UNCONSTRAINED_ARRAY_TYPE in both cases, as they will cause trouble
971:      with the debugger and aren't needed anyway.  */
972:   if (!(TREE_CODE (decl) == TYPE_DECL
973:         && TREE_CODE (TREE_TYPE (decl)) == UNCONSTRAINED_ARRAY_TYPE))
974:     {
975:       /* External declarations must go to the binding level they belong to.
976:          This will make corresponding imported entities are available in the
977:          debugger at the proper time.  */
978:       if (DECL_EXTERNAL (decl)
979:           && TREE_CODE (decl) == FUNCTION_DECL
980:           && fndecl_built_in_p (decl))
981:         vec_safe_push (builtin_decls, decl);
982:       else if (global_bindings_p ())
983:         vec_safe_push (global_decls, decl);
984:       else
985:         {
986:           DECL_CHAIN (decl) = BLOCK_VARS (current_binding_level->block);
987:           BLOCK_VARS (current_binding_level->block) = decl;
988:         }
989:     }
990:
991: /* Pointer types aren't named types in the C sense so we need to generate a
992:    typedef in DWARF for them.  Also do that for fat and extended pointer types
993:    because, even though they are named types in the C sense, they are still
994:    the XUP[EA] types created for the base array type at this point.  */
995: #define TYPE_IS_POINTER_P(NODE)                                                \
996:   (TREE_CODE (NODE) == POINTER_TYPE                                            \
997:    || TYPE_IS_FAT_POINTER_P (NODE)                                             \
998:    || TYPE_IS_EXTENDED_POINTER_P (NODE))
999:
1000:   /* For the declaration of a type, set its name either if it isn't already
1001:      set or if the previous type name was not derived from a source name.
1002:      We'd rather have the type named with a real name and all the pointer
1003:      types to the same object have the same node, except when the names are
1004:      both derived from source names.  */
1005:   if (TREE_CODE (decl) == TYPE_DECL && DECL_NAME (decl))
1006:     {
1007:       tree t = TREE_TYPE (decl);
1008:
1009:       /* For pointer types, make sure the typedef is generated and preserved
1010:          in DWARF, unless the type is artificial.  */
1011:       if (!(TYPE_NAME (t) && TREE_CODE (TYPE_NAME (t)) == TYPE_DECL)
1012:           && (!TYPE_IS_POINTER_P (t) || DECL_ARTIFICIAL (decl)))
1013:         ;
1014:       /* For pointer types, create the DECL_ORIGINAL_TYPE that will generate
1015:          the typedef in DWARF.  */
1016:       else if (TYPE_IS_POINTER_P (t) && !DECL_ARTIFICIAL (decl))
1017:         {
1018:           tree tt = build_variant_type_copy (t);
```

## gcc/ada/gcc-interface/utils.cc:1832–1859

```text
1832:      variable that indicates our size, if still variable.  */
1833:   if (TREE_CODE (orig_size) != INTEGER_CST
1834:       && TYPE_NAME (record)
1835:       && TYPE_NAME (type)
1836:       && !(TREE_CODE (TYPE_NAME (type)) == TYPE_DECL
1837:            && DECL_IGNORED_P (TYPE_NAME (type))))
1838:     {
1839:       tree name = TYPE_IDENTIFIER (record);
1840:       tree size_unit = TYPE_SIZE_UNIT (record);
1841:
1842:       /* A variable that holds the size is required even with no encoding since
1843:          it will be referenced by debugging information attributes.  At global
1844:          level, we need a single variable across all translation units.  */
1845:       if (size
1846:           && TREE_CODE (size) != INTEGER_CST
1847:           && (definition || global_bindings_p ()))
1848:         {
1849:           /* Whether or not gnat_entity comes from source, this XVZ variable is
1850:              is a compilation artifact.  */
1851:           size_unit
1852:             = create_var_decl (concat_name (name, "XVZ"), NULL_TREE, sizetype,
1853:                               size_unit, true, global_bindings_p (), false,
1854:                               !definition && global_bindings_p (), false,
1855:                               false, true, true, NULL, gnat_entity, false);
1856:           TYPE_SIZE_UNIT (record) = size_unit;
1857:         }
1858:
1859:       /* There is no need to show what we are a subtype of when outputting as
```

## gcc/ada/gcc-interface/utils.cc:3018–3057

```text
3018: create_var_decl (tree name, tree asm_name, tree type, tree init,
3019:                  bool const_flag, bool public_flag, bool linkonce_flag,
3020:                  bool extern_flag, bool static_flag, bool volatile_flag,
3021:                  bool artificial_p, bool debug_info_p,
3022:                  struct attrib *attr_list, Node_Id gnat_node,
3023:                  bool const_decl_allowed_p)
3024: {
3025:   /* Whether the object has static storage duration, either explicitly or by
3026:      virtue of being declared at the global level.  */
3027:   const bool static_storage = static_flag || global_bindings_p ();
3028:
3029:   /* Whether the initializer is constant: for an external object or an object
3030:      with static storage duration, we check that the initializer is a valid
3031:      constant expression for initializing a static variable; otherwise, we
3032:      only check that it is constant.  */
3033:   const bool init_const
3034:     = (init
3035:        && gnat_types_compatible_p (type, TREE_TYPE (init))
3036:        && (extern_flag || static_storage
3037:            ? initializer_constant_valid_p (init, TREE_TYPE (init))
3038:              != NULL_TREE
3039:            : TREE_CONSTANT (init)));
3040:
3041:   /* Whether we will make TREE_CONSTANT the DECL we produce here, in which
3042:      case the initializer may be used in lieu of the DECL node (as done in
3043:      Identifier_to_gnu).  This is useful to prevent the need of elaboration
3044:      code when an identifier for which such a DECL is made is in turn used
3045:      as an initializer.  We used to rely on CONST_DECL vs VAR_DECL for this,
3046:      but extra constraints apply to this choice (see below) and they are not
3047:      relevant to the distinction we wish to make.  */
3048:   const bool constant_p = const_flag && init_const;
3049:
3050:   /* The actual DECL node.  CONST_DECL was initially intended for enumerals
3051:      and may be used for scalars in general but not for aggregates.  */
3052:   tree var_decl
3053:     = build_decl (input_location,
3054:                   constant_p && const_decl_allowed_p && !AGGREGATE_TYPE_P (type)
3055:                   ? CONST_DECL : VAR_DECL,
3056:                   name, type);
3057:
```

## gcc/ada/gcc-interface/utils.cc:3137–3162

```text
3137:   /* Note that make_decl_one_only forces TREE_PUBLIC on the DECL.  */
3138:   if (linkonce_flag && VAR_P (var_decl))
3139:     {
3140:       gcc_checking_assert (TREE_PUBLIC (var_decl));
3141:       make_decl_one_only (var_decl, var_decl);
3142:     }
3143:
3144:   /* ??? Some attributes cannot be applied to CONST_DECLs.  */
3145:   if (VAR_P (var_decl))
3146:     process_attributes (&var_decl, &attr_list, true, gnat_node);
3147:
3148:   /* Add this decl to the current binding level.  */
3149:   gnat_pushdecl (var_decl, gnat_node);
3150:
3151:   if (VAR_P (var_decl) && asm_name)
3152:     {
3153:       /* Let the target mangle the name if this isn't a verbatim asm.  */
3154:       if (*IDENTIFIER_POINTER (asm_name) != '*')
3155:         asm_name = targetm.mangle_decl_assembler_name (var_decl, asm_name);
3156:
3157:       SET_DECL_ASSEMBLER_NAME (var_decl, asm_name);
3158:     }
3159:
3160:   return var_decl;
3161: }
3162:
```

## gcc/ada/gcc-interface/utils.cc:3830–3875

```text
3830: {
3831:   announce_function (subprog_decl);
3832:
3833:   /* This function is being defined.  */
3834:   TREE_STATIC (subprog_decl) = 1;
3835:
3836:   /* The failure of this assertion will likely come from a wrong context for
3837:      the subprogram body, e.g. another procedure for a procedure declared at
3838:      library level.  */
3839:   gcc_assert (current_function_decl == decl_function_context (subprog_decl));
3840:
3841:   current_function_decl = subprog_decl;
3842:
3843:   /* Enter a new binding level and show that all the parameters belong to
3844:      this function.  */
3845:   gnat_pushlevel ();
3846: }
3847:
3848: /* Finish translating the current subprogram and set its BODY.  */
3849:
3850: void
3851: end_subprog_body (tree body)
3852: {
3853:   tree fndecl = current_function_decl;
3854:
3855:   /* Attach the BLOCK for this level to the function and pop the level.  */
3856:   BLOCK_SUPERCONTEXT (current_binding_level->block) = fndecl;
3857:   DECL_INITIAL (fndecl) = current_binding_level->block;
3858:   gnat_poplevel ();
3859:
3860:   /* The body should be a BIND_EXPR whose BLOCK is the top-level one.  */
3861:   if (TREE_CODE (body) == BIND_EXPR)
3862:     {
3863:       BLOCK_SUPERCONTEXT (BIND_EXPR_BLOCK (body)) = fndecl;
3864:       DECL_INITIAL (fndecl) = BIND_EXPR_BLOCK (body);
3865:     }
3866:
3867:   DECL_SAVED_TREE (fndecl) = body;
3868:
3869:   current_function_decl = decl_function_context (fndecl);
3870: }
3871:
3872: /* Wrap up compilation of SUBPROG_DECL, a subprogram body.  */
3873:
3874: void
3875: rest_of_subprog_body_compilation (tree subprog_decl)
```

## gcc/ada/gcc-interface/utils.cc:5160–5184

```text
5160:
5161:     case NULL_EXPR:
5162:       /* Just set its type here.  For TRANSFORM_EXPR, we will do the actual
5163:          conversion in gnat_expand_expr.  NULL_EXPR does not represent
5164:          and actual value, so no conversion is needed.  */
5165:       expr = copy_node (expr);
5166:       TREE_TYPE (expr) = type;
5167:       return expr;
5168:
5169:     case STRING_CST:
5170:       /* If we are converting a STRING_CST to another constrained array type,
5171:          just make a new one in the proper type.  */
5172:       if (code == ecode
5173:           && !(TREE_CONSTANT (TYPE_SIZE (etype))
5174:                && !TREE_CONSTANT (TYPE_SIZE (type))))
5175:         {
5176:           expr = copy_node (expr);
5177:           TREE_TYPE (expr) = type;
5178:           return expr;
5179:         }
5180:       break;
5181:
5182:     case VECTOR_CST:
5183:       /* If we are converting a VECTOR_CST to a mere type variant, just make
5184:          a new one in the proper type.  */
```

## gcc/ada/gcc-interface/utils.cc:6064–6111

```text
6064:
6065:        type ada__tags__addr_ptr is access system.address;
6066:        S191s : constant ada__tags__addr_ptr := ada__tags__addr_ptr!(S190s);
6067:        return p___size__4 (p__object!(S191s.all));
6068:
6069:      so we need to skip dereferences.  */
6070:   else if (!INDIRECT_REF_P (expr)
6071:            && TREE_CODE (expr) != STRING_CST
6072:            && !(AGGREGATE_TYPE_P (etype) && AGGREGATE_TYPE_P (type))
6073:            && ecode != UNCONSTRAINED_ARRAY_TYPE
6074:            && TREE_CONSTANT (TYPE_SIZE (etype))
6075:            && TREE_CONSTANT (TYPE_SIZE (type))
6076:            && (c = tree_int_cst_compare (TYPE_SIZE (etype), TYPE_SIZE (type))))
6077:     {
6078:       if (c < 0)
6079:         {
6080:           expr = convert (maybe_pad_type (etype, TYPE_SIZE (type), 0, Empty,
6081:                                           false, false, true),
6082:                           expr);
6083:           expr = unchecked_convert (type, expr, notrunc_p);
6084:         }
6085:       else
6086:         {
6087:           tree rec_type = maybe_pad_type (type, TYPE_SIZE (etype), 0, Empty,
6088:                                           false, false, true);
6089:           expr = unchecked_convert (rec_type, expr, notrunc_p);
6090:           expr = build3 (COMPONENT_REF, type, expr, TYPE_FIELDS (rec_type),
6091:                          NULL_TREE);
6092:         }
6093:     }
6094:
6095:   /* Likewise if we are converting from a fixed-size type to a type with self-
6096:      referential size.  We use the max size to do the padding in this case.  */
6097:   else if (!INDIRECT_REF_P (expr)
6098:            && TREE_CODE (expr) != STRING_CST
6099:            && !(AGGREGATE_TYPE_P (etype) && AGGREGATE_TYPE_P (type))
6100:            && ecode != UNCONSTRAINED_ARRAY_TYPE
6101:            && TREE_CONSTANT (TYPE_SIZE (etype))
6102:            && CONTAINS_PLACEHOLDER_P (TYPE_SIZE (type)))
6103:     {
6104:       tree new_size = max_size (TYPE_SIZE (type), true);
6105:       c = tree_int_cst_compare (TYPE_SIZE (etype), new_size);
6106:       if (c < 0)
6107:         {
6108:           expr = convert (maybe_pad_type (etype, new_size, 0, Empty,
6109:                                           false, false, true),
6110:                           expr);
6111:           expr = unchecked_convert (type, expr, notrunc_p);
```

## gcc/ada/gcc-interface/utils.cc:6192–6204

```text
6192:   else
6193:     {
6194:       expr = maybe_unconstrained_array (expr);
6195:       etype = TREE_TYPE (expr);
6196:       ecode = TREE_CODE (etype);
6197:       if (can_fold_for_view_convert_p (expr))
6198:         expr = fold_build1 (VIEW_CONVERT_EXPR, type, expr);
6199:       else
6200:         expr = build1 (VIEW_CONVERT_EXPR, type, expr);
6201:     }
6202:
6203:   /* If the result is a non-biased integral type whose precision is not equal
6204:      to its size, sign- or zero-extend the result.  But we need not do this
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
417:           && TYPE_IS_DUMMY_P (TREE_TYPE (gnu_decl))
418:           && IN (kind, Incomplete_Or_Private_Kind)
419:           && Present (Full_View (gnat_entity))
420:           && (present_gnu_tree (Full_View (gnat_entity))
421:               || No (Freeze_Node (Full_View (gnat_entity)))))
422:         {
423:           gnu_decl
424:             = gnat_to_gnu_entity (Full_View (gnat_entity), NULL_TREE,
425:                                   false);
426:           save_gnu_tree (gnat_entity, NULL_TREE, false);
427:           save_gnu_tree (gnat_entity, gnu_decl, false);
428:         }
429:
430:       if (TREE_CODE (gnu_decl) == TYPE_DECL
431:           && TYPE_IS_DUMMY_P (TREE_TYPE (gnu_decl))
432:           && Ekind (gnat_entity) == E_Record_Subtype
433:           && No (Freeze_Node (gnat_entity))
434:           && Present (Cloned_Subtype (gnat_entity))
435:           && (present_gnu_tree (Cloned_Subtype (gnat_entity))
436:               || No (Freeze_Node (Cloned_Subtype (gnat_entity)))))
437:         {
438:           gnu_decl
439:             = gnat_to_gnu_entity (Cloned_Subtype (gnat_entity), NULL_TREE,
440:                                   false);
441:           save_gnu_tree (gnat_entity, NULL_TREE, false);
442:           save_gnu_tree (gnat_entity, gnu_decl, false);
443:         }
444:
445:       return gnu_decl;
```

## gcc/ada/gcc-interface/decl.cc:697–718

```text
697:
698:       /* If we have a constant that we are not defining, get the expression it
699:          was defined to represent.  This is necessary to avoid generating dumb
700:          elaboration code in simple cases, and we may throw it away later if it
701:          is not a constant.  But do not do it for dispatch tables because they
702:          are only referenced indirectly and we need to have a consistent view
703:          of the exported and of the imported declarations of the tables from
704:          external units for them to be properly merged in LTO mode.  Moreover
705:          simply do not retrieve the expression if it is an allocator because
706:          the designated type might still be dummy at this point.  Note that we
707:          invoke gnat_to_gnu_external and not gnat_to_gnu because the expression
708:          may contain N_Expression_With_Actions nodes and thus declarations of
709:          objects from other units that we need to discard.  Note also that we
710:          need to do it even if we are only annotating types, so as to be able
711:          to validate representation clauses using constants.  */
712:       if (!definition
713:           && !No_Initialization (gnat_decl)
714:           && !Is_Dispatch_Table_Entity (gnat_entity)
715:           && Present (gnat_temp = Expression (gnat_decl))
716:           && Nkind (gnat_temp) != N_Allocator
717:           && (Is_Elementary_Type (Etype (gnat_entity)) || !type_annotate_only))
718:         gnu_expr = gnat_to_gnu_external (gnat_temp);
```

## gcc/ada/gcc-interface/decl.cc:754–766

```text
754:            referencing the renaming.  But it may contain a call for which
755:            we'll generate a temporary to hold the return value and which
756:            is part of the definition of the renaming, so discard it.  */
757:         if (Present (gnat_renamed_obj) && !definition)
758:           {
759:             if (kind == E_Exception)
760:               gnu_expr = gnat_to_gnu_entity (Renamed_Entity (gnat_entity),
761:                                              NULL_TREE, false);
762:             else
763:               gnu_expr = gnat_to_gnu_external (gnat_renamed_obj);
764:           }
765:
766:         /* Get the type after elaborating the renamed object.  */
```

## gcc/ada/gcc-interface/decl.cc:1177–1205

```text
1177:                 /* If it needs to be materialized for debugging purposes, build
1178:                    the entity as indirect reference to the renamed object.  */
1179:                 if (Materialize_Entity (gnat_entity))
1180:                   {
1181:                     /* If this is an array allocated with its bounds, we make
1182:                        its type a thin reference, the reference counterpart of
1183:                        a thin pointer, exactly as we would have done in the
1184:                        non-renaming case below.  */
1185:                     if (Is_Constr_Array_Subt_With_Bounds (gnat_type)
1186:                         && !type_annotate_only)
1187:                       {
1188:                         tree gnu_array
1189:                           = gnat_to_gnu_type (Base_Type (gnat_type));
1190:                         gnu_type = TYPE_OBJECT_RECORD_TYPE (gnu_array);
1191:                       }
1192:                     gnu_type = build_reference_type (gnu_type);
1193:                     const_flag = true;
1194:                     volatile_flag = false;
1195:
1196:                     gnu_expr = build_unary_op (ADDR_EXPR, gnu_type, gnu_expr);
1197:
1198:                     create_var_decl (gnu_entity_name, NULL_TREE,
1199:                                      TREE_TYPE (gnu_expr), gnu_expr,
1200:                                      const_flag, Is_Public (gnat_entity),
1201:                                      Is_Link_Once (gnat_entity),
1202:                                      imported_p, static_flag, volatile_flag,
1203:                                      artificial_p, debug_info_p, attr_list,
1204:                                      gnat_entity, false);
1205:                   }
```

## gcc/ada/gcc-interface/decl.cc:1507–1592

```text
1507:            than the largest stack alignment the back-end can honor, resort to
1508:            a variable of "aligning type".  */
1509:         if (definition
1510:             && TYPE_ALIGN (gnu_type) > BIGGEST_ALIGNMENT
1511:             && !imported_p
1512:             && !static_flag
1513:             && !global_bindings_p ())
1514:           {
1515:             /* Create the new variable.  No need for extra room before the
1516:                aligned field as this is in automatic storage.  */
1517:             tree gnu_new_type
1518:               = make_aligning_type (gnu_type, TYPE_ALIGN (gnu_type),
1519:                                     TYPE_SIZE_UNIT (gnu_type),
1520:                                     BIGGEST_ALIGNMENT, 0, gnat_entity);
1521:             tree gnu_new_var
1522:               = create_var_decl (create_concat_name (gnat_entity, "ALIGN"),
1523:                                  NULL_TREE, gnu_new_type, NULL_TREE,
1524:                                  false, false, false, false, false, false,
1525:                                  true, debug_info_p && definition, NULL,
1526:                                  gnat_entity);
1527:
1528:             /* Initialize the aligned field if we have an initializer.  */
1529:             if (gnu_expr)
1530:               add_stmt_with_node
1531:                 (build_binary_op (INIT_EXPR, NULL_TREE,
1532:                                   build_component_ref
1533:                                   (gnu_new_var, TYPE_FIELDS (gnu_new_type),
1534:                                    false),
1535:                                   gnu_expr),
1536:                  gnat_entity);
1537:
1538:             /* And setup this entity as a reference to the aligned field.  */
1539:             gnu_type = build_reference_type (gnu_type);
1540:             gnu_expr
1541:               = build_unary_op
1542:                 (ADDR_EXPR, NULL_TREE,
1543:                  build_component_ref (gnu_new_var, TYPE_FIELDS (gnu_new_type),
1544:                                       false));
1545:             TREE_CONSTANT (gnu_expr) = 1;
1546:
1547:             used_by_ref = true;
1548:             const_flag = true;
1549:             volatile_flag = false;
1550:             gnu_size = NULL_TREE;
1551:           }
1552:
1553:         /* If this is an aggregate constant initialized to a constant, force it
1554:            to be statically allocated.  This saves an initialization copy.  */
1555:         if (!static_flag
1556:             && const_flag
1557:             && gnu_expr
1558:             && TREE_CONSTANT (gnu_expr)
1559:             && AGGREGATE_TYPE_P (gnu_type)
1560:             && tree_fits_uhwi_p (TYPE_SIZE_UNIT (gnu_type))
1561:             && !(TYPE_IS_PADDING_P (gnu_type)
1562:                  && !tree_fits_uhwi_p (TYPE_SIZE_UNIT
1563:                                        (TREE_TYPE (TYPE_FIELDS (gnu_type))))))
1564:           static_flag = true;
1565:
1566:         /* If this is an array allocated with its bounds, we make its type a
1567:            thin reference, i.e. the reference counterpart of a thin pointer,
1568:            so that it points to the array part.  This is aimed at making it
1569:            easier for the debugger to decode the object.  Note that we have
1570:            to do it this late because of the couple of allocation adjustments
1571:            that might be made above.  */
1572:         if (Is_Constr_Array_Subt_With_Bounds (gnat_type)
1573:             && !type_annotate_only)
1574:           {
1575:             /* In case the object with the template has already been allocated
1576:                just above, we have nothing to do here.  */
1577:             if (!TYPE_IS_THIN_POINTER_P (gnu_type))
1578:               {
1579:                 /* This variable is a GNAT encoding used by Workbench: let it
1580:                    go through the debugging information but mark it as
1581:                    artificial: users are not interested in it.  */
1582:                 tree gnu_unc_var
1583:                    = create_var_decl (concat_name (gnu_entity_name, "UNC"),
1584:                                       NULL_TREE, gnu_type, gnu_expr,
1585:                                       const_flag, Is_Public (gnat_entity),
1586:                                       Is_Link_Once (gnat_entity),
1587:                                       imported_p || !definition,
1588:                                       static_flag, volatile_flag, true,
1589:                                       debug_info_p && definition,
1590:                                       NULL, gnat_entity);
1591:                 gnu_expr = build_unary_op (ADDR_EXPR, NULL_TREE, gnu_unc_var);
1592:                 TREE_CONSTANT (gnu_expr) = 1;
```

## gcc/ada/gcc-interface/decl.cc:1629–1713

```text
1629:
1630:         /* Now create the variable or the constant and set various flags.  */
1631:         gnu_decl
1632:           = create_var_decl (gnu_entity_name, gnu_ext_name, gnu_type,
1633:                              gnu_expr, const_flag, Is_Public (gnat_entity),
1634:                              Is_Link_Once (gnat_entity),
1635:                              imported_p || !definition,
1636:                              static_flag, volatile_flag, artificial_p,
1637:                              debug_info_p && definition, attr_list,
1638:                              gnat_entity);
1639:         DECL_BY_REF_P (gnu_decl) = used_by_ref;
1640:         DECL_POINTS_TO_READONLY_P (gnu_decl) = used_by_ref && inner_const_flag;
1641:         DECL_CAN_NEVER_BE_NULL_P (gnu_decl) = Can_Never_Be_Null (gnat_entity);
1642:
1643:         /* If we are defining an Out parameter and optimization isn't enabled,
1644:            create a fake PARM_DECL for debugging purposes and make it point to
1645:            the VAR_DECL.  Suppress debug info for the latter but make sure it
1646:            will live in memory so that it can be accessed from within the
1647:            debugger through the PARM_DECL.  */
1648:         if (kind == E_Out_Parameter
1649:             && definition
1650:             && debug_info_p
1651:             && !optimize
1652:             && !flag_generate_lto)
1653:           {
1654:             tree param = create_param_decl (gnu_entity_name, gnu_type);
1655:             gnat_pushdecl (param, gnat_entity);
1656:             SET_DECL_VALUE_EXPR (param, gnu_decl);
1657:             DECL_HAS_VALUE_EXPR_P (param) = 1;
1658:             DECL_IGNORED_P (gnu_decl) = 1;
1659:             TREE_ADDRESSABLE (gnu_decl) = 1;
1660:           }
1661:
1662:         /* If this is a loop parameter, set the corresponding flag.  */
1663:         else if (kind == E_Loop_Parameter)
1664:           DECL_LOOP_PARM_P (gnu_decl) = 1;
1665:
1666:         /* If this is a constant and we are defining it or it generates a real
1667:            symbol at the object level and we are referencing it, we may want
1668:            or need to have a true variable to represent it:
1669:              - if the constant is public and not overlaid on something else,
1670:              - if its address is taken,
1671:              - if it is aliased,
1672:              - if optimization isn't enabled, for debugging purposes.  */
1673:         if (TREE_CODE (gnu_decl) == CONST_DECL
1674:             && (definition || Sloc (gnat_entity) > Standard_Location)
1675:             && ((Is_Public (gnat_entity) && No (Address_Clause (gnat_entity)))
1676:                 || Address_Taken (gnat_entity)
1677:                 || Is_Aliased (gnat_entity)
1678:                 || (!optimize && debug_info_p)))
1679:           {
1680:             tree gnu_corr_var
1681:               = create_var_decl (gnu_entity_name, gnu_ext_name, gnu_type,
1682:                                  gnu_expr, true, Is_Public (gnat_entity),
1683:                                  Is_Link_Once (gnat_entity),
1684:                                  !definition, static_flag, volatile_flag,
1685:                                  artificial_p, debug_info_p && definition,
1686:                                  attr_list, gnat_entity, false);
1687:
1688:             SET_DECL_CONST_CORRESPONDING_VAR (gnu_decl, gnu_corr_var);
1689:             DECL_IGNORED_P (gnu_decl) = 1;
1690:           }
1691:
1692:         /* If this is a constant, even if we don't need a true variable, we
1693:            may need to avoid returning the initializer in every case.  That
1694:            can happen for the address of a (constant) constructor because,
1695:            upon dereferencing it, the constructor will be reinjected in the
1696:            tree, which may not be valid in every case; see lvalue_required_p
1697:            for more details.  */
1698:         if (TREE_CODE (gnu_decl) == CONST_DECL)
1699:           DECL_CONST_ADDRESS_P (gnu_decl) = constructor_address_p (gnu_expr);
1700:
1701:         /* If this is a local variable with non-BLKmode and aggregate type,
1702:            and optimization isn't enabled, then force it in memory so that
1703:            a register won't be allocated to it with possible subparts left
1704:            uninitialized and reaching the register allocator.  */
1705:         else if (VAR_P (gnu_decl)
1706:                  && !DECL_EXTERNAL (gnu_decl)
1707:                  && !TREE_STATIC (gnu_decl)
1708:                  && DECL_MODE (gnu_decl) != BLKmode
1709:                  && AGGREGATE_TYPE_P (TREE_TYPE (gnu_decl))
1710:                  && !TYPE_IS_FAT_POINTER_P (TREE_TYPE (gnu_decl))
1711:                  && !optimize)
1712:           TREE_ADDRESSABLE (gnu_decl) = 1;
1713:
```

## gcc/ada/gcc-interface/decl.cc:7532–7688

```text
7532: elaborate_expression (Node_Id gnat_expr, Entity_Id gnat_entity, const char *s,
7533:                       bool definition, bool need_value, bool need_for_debug)
7534: {
7535:   tree gnu_expr;
7536:
7537:   /* If we already elaborated this expression (e.g. it was involved
7538:      in the definition of a private type), use the old value.  */
7539:   if (present_gnu_tree (gnat_expr))
7540:     return get_gnu_tree (gnat_expr);
7541:
7542:   /* If we don't need a value and this is static or a discriminant,
7543:      we don't need to do anything.  */
7544:   if (!need_value
7545:       && (Compile_Time_Known_Value (gnat_expr)
7546:           || (Nkind (gnat_expr) == N_Identifier
7547:               && Ekind (Entity (gnat_expr)) == E_Discriminant)))
7548:     return NULL_TREE;
7549:
7550:   /* If it's a static expression, we don't need a variable for debugging.  */
7551:   if (need_for_debug && Compile_Time_Known_Value (gnat_expr))
7552:     need_for_debug = false;
7553:
7554:   /* Otherwise, convert this tree to its GCC equivalent and elaborate it.  */
7555:   gnu_expr = elaborate_expression_1 (gnat_to_gnu (gnat_expr), gnat_entity, s,
7556:                                      definition, need_for_debug);
7557:
7558:   /* Save the expression in case we try to elaborate this entity again.  Since
7559:      it's not a DECL, don't check it.  Don't save if it's a discriminant.  */
7560:   if (!CONTAINS_PLACEHOLDER_P (gnu_expr))
7561:     save_gnu_tree (gnat_expr, gnu_expr, true);
7562:
7563:   return need_value ? gnu_expr : error_mark_node;
7564: }
7565:
7566: /* Similar, but take a GNU expression and always return a result.  */
7567:
7568: static tree
7569: elaborate_expression_1 (tree gnu_expr, Entity_Id gnat_entity, const char *s,
7570:                         bool definition, bool need_for_debug)
7571: {
7572:   const bool expr_global_p = Is_Public (gnat_entity) || global_bindings_p ();
7573:   bool expr_variable_p, use_variable;
7574:
7575:   /* If GNU_EXPR contains a placeholder, just return it.  We rely on the fact
7576:      that an expression cannot contain both a discriminant and a variable.  */
7577:   if (CONTAINS_PLACEHOLDER_P (gnu_expr))
7578:     return gnu_expr;
7579:
7580:   /* If GNU_EXPR is neither a constant nor based on a read-only variable, make
7581:      a variable that is initialized to contain the expression when the package
7582:      containing the definition is elaborated.  If this entity is defined at top
7583:      level, replace the expression by the variable; otherwise use a SAVE_EXPR
7584:      if this is necessary.  */
7585:   if (TREE_CONSTANT (gnu_expr))
7586:     expr_variable_p = false;
7587:   else
7588:     {
7589:       /* Skip any conversions and simple constant arithmetics to see if the
7590:          expression is based on a read-only variable.  */
7591:       tree inner = remove_conversions (gnu_expr, true);
7592:
7593:       inner = skip_simple_constant_arithmetic (inner);
7594:
7595:       if (handled_component_p (inner))
7596:         inner = get_inner_constant_reference (inner);
7597:
7598:       expr_variable_p
7599:         = !(inner
7600:             && VAR_P (inner)
7601:             && (TREE_READONLY (inner) || DECL_READONLY_ONCE_ELAB (inner)));
7602:     }
7603:
7604:   /* We only need to use the variable if we are in a global context since GCC
7605:      can do the right thing in the local case.  However, when not optimizing,
7606:      use it for bounds of loop iteration scheme to avoid code duplication.  */
7607:   use_variable = expr_variable_p
7608:                  && (expr_global_p
7609:                      || (!optimize
7610:                          && definition
7611:                          && Is_Itype (gnat_entity)
7612:                          && Nkind (Associated_Node_For_Itype (gnat_entity))
7613:                             == N_Loop_Parameter_Specification));
7614:
7615:   /* If the GNAT encodings are not used, we don't need a variable for debug
7616:      info purposes if the expression is a constant or another variable, but
7617:      we must be careful because we do not generate debug info for external
7618:      variables so DECL_IGNORED_P is not stable across units.  */
7619:   if (need_for_debug
7620:       && gnat_encodings != DWARF_GNAT_ENCODINGS_ALL
7621:       && (TREE_CONSTANT (gnu_expr)
7622:           || (!Is_Public (gnat_entity)
7623:               && DECL_P (gnu_expr)
7624:               && !DECL_IGNORED_P (gnu_expr))))
7625:     need_for_debug = false;
7626:
7627:   /* Now create it, possibly only for debugging purposes.  */
7628:   if (use_variable || need_for_debug)
7629:     {
7630:       /* The following variable creation can happen when processing the body
7631:          of subprograms that are defined outside of the extended main unit and
7632:          inlined.  In this case, we are not at the global scope, and thus the
7633:          new variable must not be tagged "external", as we used to do here as
7634:          soon as DEFINITION was false.  And note that we test Needs_Debug_Info
7635:          here instead of NEED_FOR_DEBUG because, once the variable is created,
7636:          whether or not debug information is generated for it is orthogonal to
7637:          the reason why it was created in the first place.  */
7638:       tree gnu_decl
7639:         = create_var_decl (create_concat_name (gnat_entity, s), NULL_TREE,
7640:                            TREE_TYPE (gnu_expr), gnu_expr, true,
7641:                            Is_Public (gnat_entity), Is_Link_Once (gnat_entity),
7642:                            !definition && expr_global_p,
7643:                            expr_global_p, false, true,
7644:                            Needs_Debug_Info (gnat_entity),
7645:                            NULL, gnat_entity, false);
7646:
7647:       /* Using this variable for debug (if need_for_debug is true) requires
7648:          a proper location.  The back-end will compute a location for this
7649:          variable only if the variable is used by the generated code.
7650:          Returning the variable ensures the caller will use it in generated
7651:          code.  Note that there is no need for a location if the debug info
7652:          contains an integer constant.  */
7653:       if (use_variable || (need_for_debug && !TREE_CONSTANT (gnu_expr)))
7654:         return gnu_decl;
7655:     }
7656:
7657:   return expr_variable_p ? gnat_save_expr (gnu_expr) : gnu_expr;
7658: }
7659:
7660: /* Similar, but take an alignment factor and make it explicit in the tree.  */
7661:
7662: static tree
7663: elaborate_expression_2 (tree gnu_expr, Entity_Id gnat_entity, const char *s,
7664:                         bool definition, bool need_for_debug, unsigned int align)
7665: {
7666:   /* Nothing more to do if the factor is already explicit in the tree.  */
7667:   if (TREE_CODE (gnu_expr) == MULT_EXPR
7668:       && TREE_CONSTANT (TREE_OPERAND (gnu_expr, 1))
7669:       && value_factor_p (TREE_OPERAND (gnu_expr, 1), align / BITS_PER_UNIT))
7670:     return
7671:       size_binop (MULT_EXPR,
7672:                   elaborate_expression_1 (TREE_OPERAND (gnu_expr, 0),
7673:                                           gnat_entity, s, definition,
7674:                                           need_for_debug),
7675:                   TREE_OPERAND (gnu_expr, 1));
7676:
7677:   /* Otherwise divide by the factor, elaborate the result and multiply back.  */
7678:   else
7679:     {
7680:       tree unit_align = size_int (align / BITS_PER_UNIT);
7681:       return
7682:         size_binop (MULT_EXPR,
7683:                     elaborate_expression_1 (size_binop (EXACT_DIV_EXPR,
7684:                                                         gnu_expr,
7685:                                                         unit_align),
7686:                                             gnat_entity, s, definition,
7687:                                             need_for_debug),
7688:                     unit_align);
```

## gcc/ada/gcc-interface/utils2.cc:984–1520

```text
984: tree
985: build_binary_op (enum tree_code op_code, tree result_type,
986:                  tree left_operand, tree right_operand,
987:                  bool no_fold)
988: {
989:   tree left_type = TREE_TYPE (left_operand);
990:   tree right_type = TREE_TYPE (right_operand);
991:   tree left_base_type = get_base_type (left_type);
992:   tree right_base_type = get_base_type (right_type);
993:   tree operation_type = result_type;
994:   tree best_type = NULL_TREE;
995:   tree modulus, result, t1, t2;
996:   bool has_side_effects = false;
997:
998:   if (operation_type
999:       && TREE_CODE (operation_type) == RECORD_TYPE
1000:       && TYPE_JUSTIFIED_MODULAR_P (operation_type))
1001:     operation_type = TREE_TYPE (TYPE_FIELDS (operation_type));
1002:
1003:   if (operation_type && TYPE_IS_EXTRA_SUBTYPE_P (operation_type))
1004:     operation_type = get_base_type (operation_type);
1005:
1006:   modulus = (operation_type
1007:              && TREE_CODE (operation_type) == INTEGER_TYPE
1008:              && TYPE_MODULAR_P (operation_type)
1009:              ? TYPE_MODULUS (operation_type) : NULL_TREE);
1010:
1011:   switch (op_code)
1012:     {
1013:     case INIT_EXPR:
1014:     case MODIFY_EXPR:
1015:       gcc_checking_assert (!result_type);
1016:
1017:       /* If there were integral or pointer conversions on the LHS, remove
1018:          them; we'll be putting them back below if needed.  Likewise for
1019:          conversions between record types, except for justified modular types.
1020:          But don't do this if the right operand is not BLKmode (for packed
1021:          arrays) unless we are not changing the mode, or if both ooperands
1022:          are view conversions to the same type.  */
1023:       while ((CONVERT_EXPR_P (left_operand)
1024:               || TREE_CODE (left_operand) == VIEW_CONVERT_EXPR)
1025:              && (((INTEGRAL_TYPE_P (left_type)
1026:                    || POINTER_TYPE_P (left_type))
1027:                   && (INTEGRAL_TYPE_P (operand_type (left_operand))
1028:                       || POINTER_TYPE_P (operand_type (left_operand))))
1029:                  || (TREE_CODE (left_type) == RECORD_TYPE
1030:                      && !TYPE_JUSTIFIED_MODULAR_P (left_type)
1031:                      && TREE_CODE (operand_type (left_operand)) == RECORD_TYPE
1032:                      && (TYPE_MODE (right_type) == BLKmode
1033:                          || TYPE_MODE (left_type)
1034:                             == TYPE_MODE (operand_type (left_operand)))
1035:                      && !(TREE_CODE (left_operand) == VIEW_CONVERT_EXPR
1036:                           && TREE_CODE (right_operand) == VIEW_CONVERT_EXPR
1037:                           && left_type == right_type))))
1038:         {
1039:           left_operand = TREE_OPERAND (left_operand, 0);
1040:           left_type = TREE_TYPE (left_operand);
1041:         }
1042:
1043:       /* If a class-wide type may be involved, force use of the RHS type.  */
1044:       if (type_is_tagged_or_cw_equivalent (right_type))
1045:         operation_type = right_type;
1046:
1047:       /* If we are copying between padded objects with compatible types, use
1048:          the padded view of the objects, this is very likely more efficient.
1049:          Likewise for a padded object that is assigned a constructor, if we
1050:          can convert the constructor to the inner type, to avoid putting a
1051:          VIEW_CONVERT_EXPR on the LHS.  But don't do so if we wouldn't have
1052:          actually copied anything.  */
1053:       else if (TYPE_IS_PADDING_P (left_type)
1054:                && TREE_CONSTANT (TYPE_SIZE (left_type))
1055:                && ((TREE_CODE (right_operand) == COMPONENT_REF
1056:                     && TYPE_MAIN_VARIANT (left_type)
1057:                        == TYPE_MAIN_VARIANT (operand_type (right_operand)))
1058:                    || (TREE_CODE (right_operand) == CONSTRUCTOR
1059:                        && !CONTAINS_PLACEHOLDER_P
1060:                            (DECL_SIZE (TYPE_FIELDS (left_type)))))
1061:                && !integer_zerop (TYPE_SIZE (right_type)))
1062:         {
1063:           /* We make an exception for a BLKmode type padding a non-BLKmode
1064:              inner type and do the conversion of the LHS right away, since
1065:              unchecked_convert wouldn't do it properly.  */
1066:           if (TYPE_MODE (left_type) == BLKmode
1067:               && TYPE_MODE (right_type) != BLKmode
1068:               && TREE_CODE (right_operand) != CONSTRUCTOR)
1069:             {
1070:               operation_type = right_type;
1071:               left_operand = convert (operation_type, left_operand);
1072:               left_type = operation_type;
1073:             }
1074:           else
1075:             operation_type = left_type;
1076:         }
1077:
1078:       /* If we are copying between small padded objects of the same type with
1079:          self-referential size, and the padded size is the same constant size,
1080:          use the padded view of the objects, this will be more efficient.  */
1081:       else if (left_type == right_type
1082:                && CONTAINS_PLACEHOLDER_P (TYPE_SIZE (left_type))
1083:                && TREE_CODE (left_operand) == COMPONENT_REF
1084:                && TREE_CODE (right_operand) == COMPONENT_REF
1085:                && (t1 = operand_type (left_operand))
1086:                && (t2 = operand_type (right_operand))
1087:                && TYPE_IS_PADDING_P (t1)
1088:                && TYPE_IS_PADDING_P (t2)
1089:                && TYPE_SIZE_UNIT (t1) == TYPE_SIZE_UNIT (t2)
1090:                && TREE_CODE (TYPE_SIZE_UNIT (t1)) == INTEGER_CST
1091:                && compare_tree_int (TYPE_SIZE_UNIT (t1), MOVE_MAX_PIECES) <= 0)
1092:         {
1093:           left_operand = convert (t1, left_operand);
1094:           right_operand = convert (t2, right_operand);
1095:           operation_type = t1;
1096:         }
1097:
1098:       /* If we have a call to a function that returns with variable size, use
1099:          the RHS type in case we want to use the return slot optimization.  */
1100:       else if (TREE_CODE (right_operand) == CALL_EXPR
1101:                && return_type_with_variable_size_p (right_type))
1102:         operation_type = right_type;
1103:
1104:       /* Find the best type to use for copying between aggregate types.  */
1105:       else if (((TREE_CODE (left_type) == ARRAY_TYPE
1106:                  && TREE_CODE (right_type) == ARRAY_TYPE)
1107:                 || (TREE_CODE (left_type) == RECORD_TYPE
1108:                     && TREE_CODE (right_type) == RECORD_TYPE))
1109:                && (best_type = find_common_type (left_type, right_type)))
1110:         operation_type = best_type;
1111:
1112:       /* Otherwise use the LHS type.  */
1113:       else
1114:         operation_type = left_type;
1115:
1116:       /* Ensure everything on the LHS is valid.  If we have a field reference,
1117:          strip anything that get_inner_reference can handle.  Then remove any
1118:          conversions between types having the same code and mode.  And mark
1119:          VIEW_CONVERT_EXPRs with TREE_ADDRESSABLE.  When done, we must have
1120:          either an INDIRECT_REF, a NULL_EXPR, a SAVE_EXPR or a DECL node.  */
1121:       result = left_operand;
1122:       while (true)
1123:         {
1124:           tree restype = TREE_TYPE (result);
1125:
1126:           if (TREE_CODE (result) == COMPONENT_REF
1127:               || TREE_CODE (result) == ARRAY_REF
1128:               || TREE_CODE (result) == ARRAY_RANGE_REF)
1129:             while (handled_component_p (result))
1130:               result = TREE_OPERAND (result, 0);
1131:
1132:           else if (TREE_CODE (result) == REALPART_EXPR
1133:                    || TREE_CODE (result) == IMAGPART_EXPR
1134:                    || (CONVERT_EXPR_P (result)
1135:                        && (((TREE_CODE (restype)
1136:                              == TREE_CODE (operand_type (result))
1137:                              && TYPE_MODE (restype)
1138:                                 == TYPE_MODE (operand_type (result))))
1139:                            || type_is_tagged_or_cw_equivalent (restype))))
1140:             result = TREE_OPERAND (result, 0);
1141:
1142:           else if (TREE_CODE (result) == VIEW_CONVERT_EXPR)
1143:             {
1144:               TREE_ADDRESSABLE (result) = 1;
1145:               result = TREE_OPERAND (result, 0);
1146:             }
1147:
1148:           else
1149:             break;
1150:         }
1151:
1152:       gcc_assert (INDIRECT_REF_P (result)
1153:                   || TREE_CODE (result) == NULL_EXPR
1154:                   || TREE_CODE (result) == SAVE_EXPR
1155:                   || DECL_P (result));
1156:
1157:       /* Convert the right operand to the operation type unless it is
1158:          either already of the correct type or if the type involves a
1159:          placeholder, since the RHS may not have the same record type.  */
1160:       if (operation_type != right_type
1161:           && !CONTAINS_PLACEHOLDER_P (TYPE_SIZE (operation_type)))
1162:         {
1163:           right_operand = convert (operation_type, right_operand);
1164:           right_type = operation_type;
1165:         }
1166:
1167:       /* If the left operand is not of the same type as the operation
1168:          type, wrap it up in a VIEW_CONVERT_EXPR.  */
1169:       if (left_type != operation_type)
1170:         left_operand = unchecked_convert (operation_type, left_operand, false);
1171:
1172:       has_side_effects = true;
1173:       modulus = NULL_TREE;
1174:       break;
1175:
1176:     case ARRAY_REF:
1177:       if (!operation_type)
1178:         operation_type = TREE_TYPE (left_type);
1179:
1180:       /* ... fall through ... */
1181:
1182:     case ARRAY_RANGE_REF:
1183:       /* First look through conversion between type variants.  Note that
1184:          this changes neither the operation type nor the type domain.  */
1185:       if (TREE_CODE (left_operand) == VIEW_CONVERT_EXPR
1186:           && TYPE_MAIN_VARIANT (TREE_TYPE (TREE_OPERAND (left_operand, 0)))
1187:              == TYPE_MAIN_VARIANT (left_type))
1188:         {
1189:           left_operand = TREE_OPERAND (left_operand, 0);
1190:           left_type = TREE_TYPE (left_operand);
1191:         }
1192:
1193:       /* For a range, make sure the element type is consistent.  */
1194:       if (op_code == ARRAY_RANGE_REF
1195:           && TREE_TYPE (operation_type) != TREE_TYPE (left_type))
1196:         {
1197:           operation_type = copy_type (operation_type);
1198:           TREE_TYPE (operation_type) = TREE_TYPE (left_type);
1199:
1200:           /* Declare it now since it will never be declared otherwise.  This
1201:              is necessary to ensure that its subtrees are properly marked.  */
1202:           create_type_decl (TYPE_NAME (operation_type), operation_type, true,
1203:                             false, Empty);
1204:         }
1205:
1206:       /* Then convert the right operand to its base type.  This will prevent
1207:          unneeded sign conversions when sizetype is wider than integer.  */
1208:       right_operand = convert (right_base_type, right_operand);
1209:       right_operand = convert_to_index_type (right_operand);
1210:       modulus = NULL_TREE;
1211:       break;
1212:
1213:     case TRUTH_ANDIF_EXPR:
1214:     case TRUTH_ORIF_EXPR:
1215:     case TRUTH_AND_EXPR:
1216:     case TRUTH_OR_EXPR:
1217:     case TRUTH_XOR_EXPR:
1218:       gcc_checking_assert
1219:         (TREE_CODE (get_base_type (result_type)) == BOOLEAN_TYPE);
1220:       operation_type = left_base_type;
1221:       left_operand = convert (operation_type, left_operand);
1222:       right_operand = convert (operation_type, right_operand);
1223:       break;
1224:
1225:     case GE_EXPR:
1226:     case LE_EXPR:
1227:     case GT_EXPR:
1228:     case LT_EXPR:
1229:     case EQ_EXPR:
1230:     case NE_EXPR:
1231:       gcc_checking_assert
1232:         (TREE_CODE (get_base_type (result_type)) == BOOLEAN_TYPE);
1233:       /* If either operand is a NULL_EXPR, just return a new one.  */
1234:       if (TREE_CODE (left_operand) == NULL_EXPR)
1235:         return build2 (op_code, result_type,
1236:                        build1 (NULL_EXPR, integer_type_node,
1237:                                TREE_OPERAND (left_operand, 0)),
1238:                        integer_zero_node);
1239:
1240:       else if (TREE_CODE (right_operand) == NULL_EXPR)
1241:         return build2 (op_code, result_type,
1242:                        build1 (NULL_EXPR, integer_type_node,
1243:                                TREE_OPERAND (right_operand, 0)),
1244:                        integer_zero_node);
1245:
1246:       /* If either object is a justified modular types, get the
1247:          fields from within.  */
1248:       if (TREE_CODE (left_type) == RECORD_TYPE
1249:           && TYPE_JUSTIFIED_MODULAR_P (left_type))
1250:         {
1251:           left_operand = convert (TREE_TYPE (TYPE_FIELDS (left_type)),
1252:                                   left_operand);
1253:           left_type = TREE_TYPE (left_operand);
1254:           left_base_type = get_base_type (left_type);
1255:         }
1256:
1257:       if (TREE_CODE (right_type) == RECORD_TYPE
1258:           && TYPE_JUSTIFIED_MODULAR_P (right_type))
1259:         {
1260:           right_operand = convert (TREE_TYPE (TYPE_FIELDS (right_type)),
1261:                                   right_operand);
1262:           right_type = TREE_TYPE (right_operand);
1263:           right_base_type = get_base_type (right_type);
1264:         }
1265:
1266:       /* If both objects are arrays, compare them specially.  */
1267:       if ((TREE_CODE (left_type) == ARRAY_TYPE
1268:            || (TREE_CODE (left_type) == INTEGER_TYPE
1269:                && TYPE_HAS_ACTUAL_BOUNDS_P (left_type)))
1270:           && (TREE_CODE (right_type) == ARRAY_TYPE
1271:               || (TREE_CODE (right_type) == INTEGER_TYPE
1272:                   && TYPE_HAS_ACTUAL_BOUNDS_P (right_type))))
1273:         {
1274:           if (op_code == EQ_EXPR || op_code == NE_EXPR)
1275:             {
1276:               result
1277:                 = compare_arrays_for_equality (input_location, result_type,
1278:                                                left_operand, right_operand);
1279:               if (op_code == NE_EXPR)
1280:                 result = invert_truthvalue_loc (input_location, result);
1281:             }
1282:
1283:           else
1284:             {
1285:               /* Swap the operands to canonicalize to LT_EXPR or GE_EXPR.  */
1286:               if (op_code == GT_EXPR || op_code == LE_EXPR)
1287:                 result
1288:                   = compare_arrays_for_ordering (input_location, result_type,
1289:                                                  right_operand, left_operand);
1290:
1291:               else
1292:                 result
1293:                   = compare_arrays_for_ordering (input_location, result_type,
1294:                                                  left_operand, right_operand);
1295:
1296:               /* GE_EXPR is (not LT_EXPR) for discrete array types.  */
1297:               if (op_code == GE_EXPR || op_code == LE_EXPR)
1298:                 result = invert_truthvalue_loc (input_location, result);
1299:             }
1300:
1301:           return result;
1302:         }
1303:
1304:       /* Otherwise, the base types must be the same, unless they are both (fat)
1305:          pointer types or record types.  In the latter case, use the best type
1306:          and convert both operands to that type.  */
1307:       if (left_base_type != right_base_type)
1308:         {
1309:           if (TYPE_IS_FAT_POINTER_P (left_base_type)
1310:               && TYPE_IS_FAT_POINTER_P (right_base_type))
1311:             {
1312:               gcc_assert (TYPE_MAIN_VARIANT (left_base_type)
1313:                           == TYPE_MAIN_VARIANT (right_base_type));
1314:               best_type = left_base_type;
1315:             }
1316:
1317:           else if (TYPE_IS_EXTENDED_POINTER_P (left_base_type)
1318:                    && TYPE_IS_EXTENDED_POINTER_P (right_base_type))
1319:             {
1320:               gcc_assert (TYPE_MAIN_VARIANT (left_base_type)
1321:                           == TYPE_MAIN_VARIANT (right_base_type));
1322:               best_type = left_base_type;
1323:             }
1324:
1325:           else if (POINTER_TYPE_P (left_base_type)
1326:                    && POINTER_TYPE_P (right_base_type))
1327:             {
1328:               tree left_ref_type = TREE_TYPE (left_base_type);
1329:               tree right_ref_type = TREE_TYPE (right_base_type);
1330:
1331:               /* Anonymous access types in Ada 2005 may point to compatible
1332:                  object subtypes or function types in the language sense.  */
1333:               gcc_assert (FUNCTION_POINTER_TYPE_P (left_ref_type)
1334:                           == FUNCTION_POINTER_TYPE_P (right_ref_type));
1335:               best_type = left_base_type;
1336:             }
1337:
1338:           else if (TREE_CODE (left_base_type) == RECORD_TYPE
1339:                    && TREE_CODE (right_base_type) == RECORD_TYPE)
1340:             {
1341:               /* The only way this is permitted is if both types have the same
1342:                  name.  In that case, one of them must not be self-referential.
1343:                  Use it as the best type.  Even better with a fixed size.  */
1344:               gcc_assert (TYPE_NAME (left_base_type)
1345:                           && TYPE_NAME (left_base_type)
1346:                              == TYPE_NAME (right_base_type));
1347:
1348:               if (TREE_CONSTANT (TYPE_SIZE (left_base_type)))
1349:                 best_type = left_base_type;
1350:               else if (TREE_CONSTANT (TYPE_SIZE (right_base_type)))
1351:                 best_type = right_base_type;
1352:               else if (!CONTAINS_PLACEHOLDER_P (TYPE_SIZE (left_base_type)))
1353:                 best_type = left_base_type;
1354:               else if (!CONTAINS_PLACEHOLDER_P (TYPE_SIZE (right_base_type)))
1355:                 best_type = right_base_type;
1356:               else
1357:                 gcc_unreachable ();
1358:             }
1359:
1360:           else
1361:             gcc_unreachable ();
1362:
1363:           left_operand = convert (best_type, left_operand);
1364:           right_operand = convert (best_type, right_operand);
1365:         }
1366:       else
1367:         {
1368:           left_operand = convert (left_base_type, left_operand);
1369:           right_operand = convert (right_base_type, right_operand);
1370:         }
1371:
1372:       /* If both objects are fat pointers, compare them specially.  */
1373:       if (TYPE_IS_FAT_POINTER_P (left_base_type))
1374:         {
1375:           result
1376:             = compare_fat_pointers (input_location,
1377:                                     result_type, left_operand, right_operand);
1378:           if (op_code == NE_EXPR)
1379:             result = invert_truthvalue_loc (EXPR_LOCATION (result), result);
1380:           else
1381:             gcc_assert (op_code == EQ_EXPR);
1382:
1383:           return result;
1384:         }
1385:
1386:       modulus = NULL_TREE;
1387:       break;
1388:
1389:     case LSHIFT_EXPR:
1390:     case RSHIFT_EXPR:
1391:     case LROTATE_EXPR:
1392:     case RROTATE_EXPR:
1393:        /* The RHS of a shift can be any type.  Also, ignore any modulus
1394:          (we used to abort, but this is needed for unchecked conversion
1395:          to modular types).  Otherwise, processing is the same as normal.  */
1396:       gcc_assert (operation_type == left_base_type);
1397:       modulus = NULL_TREE;
1398:       left_operand = convert (operation_type, left_operand);
1399:       break;
1400:
1401:     case BIT_AND_EXPR:
1402:     case BIT_IOR_EXPR:
1403:     case BIT_XOR_EXPR:
1404:       /* For binary modulus, if the inputs are in range, so are the
1405:          outputs.  */
1406:       if (modulus && integer_pow2p (modulus))
1407:         modulus = NULL_TREE;
1408:       goto common;
1409:
1410:     case COMPLEX_EXPR:
1411:       gcc_assert (TREE_TYPE (result_type) == left_base_type
1412:                   && TREE_TYPE (result_type) == right_base_type);
1413:       left_operand = convert (left_base_type, left_operand);
1414:       right_operand = convert (right_base_type, right_operand);
1415:       break;
1416:
1417:     case TRUNC_DIV_EXPR:   case TRUNC_MOD_EXPR:
1418:     case CEIL_DIV_EXPR:    case CEIL_MOD_EXPR:
1419:     case FLOOR_DIV_EXPR:   case FLOOR_MOD_EXPR:
1420:     case ROUND_DIV_EXPR:   case ROUND_MOD_EXPR:
1421:       /* These always produce results lower than either operand.  */
1422:       modulus = NULL_TREE;
1423:       goto common;
1424:
1425:     case POINTER_PLUS_EXPR:
1426:       gcc_assert (operation_type == left_base_type
1427:                   && sizetype == right_base_type);
1428:       left_operand = convert (operation_type, left_operand);
1429:       right_operand = convert (sizetype, right_operand);
1430:       break;
1431:
1432:     case PLUS_NOMOD_EXPR:
1433:     case MINUS_NOMOD_EXPR:
1434:       if (op_code == PLUS_NOMOD_EXPR)
1435:         op_code = PLUS_EXPR;
1436:       else
1437:         op_code = MINUS_EXPR;
1438:       modulus = NULL_TREE;
1439:
1440:       /* ... fall through ... */
1441:
1442:     case PLUS_EXPR:
1443:     case MINUS_EXPR:
1444:       /* Avoid doing arithmetics in ENUMERAL_TYPE or BOOLEAN_TYPE like the
1445:          other compilers.  Contrary to C, Ada doesn't allow arithmetics in
1446:          these types but can generate addition/subtraction for Succ/Pred.  */
1447:       if (operation_type
1448:           && (TREE_CODE (operation_type) == ENUMERAL_TYPE
1449:               || TREE_CODE (operation_type) == BOOLEAN_TYPE))
1450:         operation_type = left_base_type = right_base_type
1451:           = gnat_type_for_mode (TYPE_MODE (operation_type),
1452:                                 TYPE_UNSIGNED (operation_type));
1453:
1454:       /* ... fall through ... */
1455:
1456:     default:
1457:     common:
1458:       /* The result type should be the same as the base types of the
1459:          both operands (and they should be the same).  Convert
1460:          everything to the result type.  */
1461:
1462:       gcc_assert (operation_type == left_base_type
1463:                   && left_base_type == right_base_type);
1464:       left_operand = convert (operation_type, left_operand);
1465:       right_operand = convert (operation_type, right_operand);
1466:     }
1467:
1468:   if (modulus && !integer_pow2p (modulus))
1469:     {
1470:       result = nonbinary_modular_operation (op_code, operation_type,
1471:                                             left_operand, right_operand);
1472:       modulus = NULL_TREE;
1473:     }
1474:   /* If either operand is a NULL_EXPR, just return a new one.  */
1475:   else if (TREE_CODE (left_operand) == NULL_EXPR)
1476:     return build1 (NULL_EXPR, operation_type, TREE_OPERAND (left_operand, 0));
1477:   else if (TREE_CODE (right_operand) == NULL_EXPR)
1478:     return build1 (NULL_EXPR, operation_type, TREE_OPERAND (right_operand, 0));
1479:   else if (op_code == ARRAY_REF || op_code == ARRAY_RANGE_REF)
1480:     {
1481:       result = build4 (op_code, operation_type, left_operand, right_operand,
1482:                        NULL_TREE, NULL_TREE);
1483:       if (!no_fold)
1484:         result = fold (result);
1485:     }
1486:   else if (op_code == INIT_EXPR || op_code == MODIFY_EXPR)
1487:     result = build2 (op_code, void_type_node, left_operand, right_operand);
1488:   else if (no_fold)
1489:     result = build2 (op_code, operation_type, left_operand, right_operand);
1490:   else
1491:     result
1492:       = fold_build2 (op_code, operation_type, left_operand, right_operand);
1493:
1494:   if (TREE_CONSTANT (result))
1495:     ;
1496:   else if (op_code == ARRAY_REF || op_code == ARRAY_RANGE_REF)
1497:     {
1498:       if (TYPE_VOLATILE (operation_type))
1499:         TREE_THIS_VOLATILE (result) = 1;
1500:     }
1501:   else if (TREE_CONSTANT (left_operand) && TREE_CONSTANT (right_operand))
1502:     TREE_CONSTANT (result) = 1;
1503:
1504:   if (has_side_effects)
1505:     TREE_SIDE_EFFECTS (result) = 1;
1506:
1507:   /* If we are working with modular types, perform the MOD operation
1508:      if something above hasn't eliminated the need for it.  */
1509:   if (modulus)
1510:     {
1511:       modulus = convert (operation_type, modulus);
1512:       if (no_fold)
1513:         result = build2 (FLOOR_MOD_EXPR, operation_type, result, modulus);
1514:       else
1515:         result = fold_build2 (FLOOR_MOD_EXPR, operation_type, result, modulus);
1516:     }
1517:
1518:   if (result_type && result_type != operation_type)
1519:     result = convert (result_type, result);
1520:
```

## gcc/ada/gcc-interface/utils2.cc:1530–1984

```text
1530:   tree base_type = get_base_type (type);
1531:   tree operation_type = result_type;
1532:   tree result;
1533:
1534:   if (operation_type
1535:       && TREE_CODE (operation_type) == RECORD_TYPE
1536:       && TYPE_JUSTIFIED_MODULAR_P (operation_type))
1537:     operation_type = TREE_TYPE (TYPE_FIELDS (operation_type));
1538:
1539:   if (operation_type
1540:       && TREE_CODE (operation_type) == INTEGER_TYPE
1541:       && TYPE_EXTRA_SUBTYPE_P (operation_type))
1542:     operation_type = get_base_type (operation_type);
1543:
1544:   switch (op_code)
1545:     {
1546:     case REALPART_EXPR:
1547:     case IMAGPART_EXPR:
1548:       if (!operation_type)
1549:         result_type = operation_type = TREE_TYPE (type);
1550:       else
1551:         gcc_assert (result_type == TREE_TYPE (type));
1552:
1553:       result = fold_build1 (op_code, operation_type, operand);
1554:       break;
1555:
1556:     case TRUTH_NOT_EXPR:
1557:       gcc_checking_assert
1558:         (TREE_CODE (get_base_type (result_type)) == BOOLEAN_TYPE);
1559:       result = invert_truthvalue_loc (EXPR_LOCATION (operand), operand);
1560:       /* When not optimizing, fold the result as invert_truthvalue_loc
1561:          doesn't fold the result of comparisons.  This is intended to undo
1562:          the trick used for boolean rvalues in gnat_to_gnu.  */
1563:       if (!optimize)
1564:         result = fold (result);
1565:       break;
1566:
1567:     case ATTR_ADDR_EXPR:
1568:     case ADDR_EXPR:
1569:       switch (TREE_CODE (operand))
1570:         {
1571:         case INDIRECT_REF:
1572:         case UNCONSTRAINED_ARRAY_REF:
1573:           result = TREE_OPERAND (operand, 0);
1574:
1575:           /* Make sure the type here is a pointer, not a reference.
1576:              GCC wants pointer types for function addresses.  */
1577:           if (!result_type)
1578:             result_type = build_pointer_type (type);
1579:
1580:           /* If the underlying object can alias everything, propagate the
1581:              property since we are effectively retrieving the object.  */
1582:           if (POINTER_TYPE_P (TREE_TYPE (result))
1583:               && TYPE_REF_CAN_ALIAS_ALL (TREE_TYPE (result)))
1584:             {
1585:               if (TREE_CODE (result_type) == POINTER_TYPE
1586:                   && !TYPE_REF_CAN_ALIAS_ALL (result_type))
1587:                 result_type
1588:                   = build_pointer_type_for_mode (TREE_TYPE (result_type),
1589:                                                  TYPE_MODE (result_type),
1590:                                                  true);
1591:               else if (TREE_CODE (result_type) == REFERENCE_TYPE
1592:                        && !TYPE_REF_CAN_ALIAS_ALL (result_type))
1593:                 result_type
1594:                   = build_reference_type_for_mode (TREE_TYPE (result_type),
1595:                                                    TYPE_MODE (result_type),
1596:                                                    true);
1597:             }
1598:           break;
1599:
1600:         case NULL_EXPR:
1601:           result = operand;
1602:           TREE_TYPE (result) = type = build_pointer_type (type);
1603:           break;
1604:
1605:         case COMPOUND_EXPR:
1606:           /* Fold a compound expression if it has unconstrained array type
1607:              since the middle-end cannot handle it.  But we don't it in the
1608:              general case because it may introduce aliasing issues if the
1609:              first operand is an indirect assignment and the second operand
1610:              the corresponding address, e.g. for an allocator.  However do
1611:              it for a return value to expose it for later recognition.  */
1612:           if (TREE_CODE (type) == UNCONSTRAINED_ARRAY_TYPE
1613:               || (VAR_P (TREE_OPERAND (operand, 1))
1614:                   && DECL_RETURN_VALUE_P (TREE_OPERAND (operand, 1))))
1615:             {
1616:               result = build_unary_op (ADDR_EXPR, result_type,
1617:                                        TREE_OPERAND (operand, 1));
1618:               result = build2 (COMPOUND_EXPR, TREE_TYPE (result),
1619:                                TREE_OPERAND (operand, 0), result);
1620:               break;
1621:             }
1622:           goto common;
1623:
1624:         case ARRAY_REF:
1625:         case ARRAY_RANGE_REF:
1626:         case COMPONENT_REF:
1627:         case BIT_FIELD_REF:
1628:             /* If this is for 'Address, find the address of the prefix and add
1629:                the offset to the field.  Otherwise, do this the normal way.  */
1630:           if (op_code == ATTR_ADDR_EXPR)
1631:             {
1632:               poly_int64 bitsize;
1633:               poly_int64 bitpos;
1634:               tree offset, inner;
1635:               machine_mode mode;
1636:               int unsignedp, reversep, volatilep;
1637:
1638:               inner = get_inner_reference (operand, &bitsize, &bitpos, &offset,
1639:                                            &mode, &unsignedp, &reversep,
1640:                                            &volatilep);
1641:
1642:               /* If INNER is a padding type whose field has a self-referential
1643:                  size, convert to that inner type.  We know the offset is zero
1644:                  and we need to have that type visible.  */
1645:               if (type_is_padding_self_referential (TREE_TYPE (inner)))
1646:                 inner = convert (TREE_TYPE (TYPE_FIELDS (TREE_TYPE (inner))),
1647:                                  inner);
1648:
1649:               /* Compute the offset as a byte offset from INNER.  */
1650:               if (!offset)
1651:                 offset = size_zero_node;
1652:
1653:               offset
1654:                 = size_binop (PLUS_EXPR, offset,
1655:                               size_int (bits_to_bytes_round_down (bitpos)));
1656:
1657:               /* Take the address of INNER, formally convert it to a pointer
1658:                  to the operand type, and finally add the offset.  */
1659:               inner = build_unary_op (ADDR_EXPR, NULL_TREE, inner);
1660:               inner
1661:                 = fold_convert (build_pointer_type (TREE_TYPE (operand)),
1662:                                 inner);
1663:               result = build_binary_op (POINTER_PLUS_EXPR, TREE_TYPE (inner),
1664:                                         inner, offset);
1665:               break;
1666:             }
1667:           goto common;
1668:
1669:         case CONSTRUCTOR:
1670:           /* If this is just a constructor for a padded record, we can
1671:              just take the address of the single field and convert it to
1672:              a pointer to our type.  */
1673:           if (TYPE_IS_PADDING_P (type))
1674:             {
1675:               result
1676:                 = build_unary_op (ADDR_EXPR,
1677:                                   build_pointer_type (TREE_TYPE (operand)),
1678:                                   CONSTRUCTOR_ELT (operand, 0)->value);
1679:               break;
1680:             }
1681:           goto common;
1682:
1683:         case NOP_EXPR:
1684:           if (AGGREGATE_TYPE_P (type)
1685:               && AGGREGATE_TYPE_P (TREE_TYPE (TREE_OPERAND (operand, 0))))
1686:             return build_unary_op (ADDR_EXPR, result_type,
1687:                                    TREE_OPERAND (operand, 0));
1688:
1689:           /* ... fallthru ... */
1690:
1691:         case VIEW_CONVERT_EXPR:
1692:           /* If this just a variant conversion or if the conversion doesn't
1693:              change the mode, get the result type from this type and go down.
1694:              This is needed for conversions of CONST_DECLs, to eventually get
1695:              to the address of their CORRESPONDING_VARs.  */
1696:           if ((TYPE_MAIN_VARIANT (type)
1697:                == TYPE_MAIN_VARIANT (TREE_TYPE (TREE_OPERAND (operand, 0))))
1698:               || (TYPE_MODE (type) != BLKmode
1699:                   && (TYPE_MODE (type)
1700:                       == TYPE_MODE (TREE_TYPE (TREE_OPERAND (operand, 0))))))
1701:             return build_unary_op (ADDR_EXPR,
1702:                                    (result_type ? result_type
1703:                                     : build_pointer_type (type)),
1704:                                    TREE_OPERAND (operand, 0));
1705:           goto common;
1706:
1707:         case CONST_DECL:
1708:           operand = DECL_CONST_CORRESPONDING_VAR (operand);
1709:
1710:           /* ... fall through ... */
1711:
1712:         default:
1713:         common:
1714:
1715:           /* If we are taking the address of a padded record whose field
1716:              contains a template, take the address of the field.  */
1717:           if (TYPE_IS_PADDING_P (type)
1718:               && TREE_CODE (TREE_TYPE (TYPE_FIELDS (type))) == RECORD_TYPE
1719:               && TYPE_CONTAINS_TEMPLATE_P (TREE_TYPE (TYPE_FIELDS (type))))
1720:             {
1721:               type = TREE_TYPE (TYPE_FIELDS (type));
1722:               operand = convert (type, operand);
1723:             }
1724:
1725:           gnat_mark_addressable (operand);
1726:           result = build_fold_addr_expr (operand);
1727:         }
1728:
1729:       if (TREE_CONSTANT (operand) || staticp (operand))
1730:         TREE_CONSTANT (result) = 1;
1731:
1732:       break;
1733:
1734:     case INDIRECT_REF:
1735:       {
1736:         tree t = remove_conversions (operand, false);
1737:         bool can_never_be_null = DECL_P (t) && DECL_CAN_NEVER_BE_NULL_P (t);
1738:
1739:         /* If TYPE is a thin pointer, either first retrieve the base if this
1740:            is an expression with an offset built for the initialization of an
1741:            object with an unconstrained nominal subtype, or else convert to
1742:            the fat pointer.  */
1743:         if (TYPE_IS_THIN_POINTER_P (type))
1744:           {
1745:             tree rec_type = TREE_TYPE (type);
1746:
1747:             if (TREE_CODE (operand) == POINTER_PLUS_EXPR
1748:                 && TREE_OPERAND (operand, 1)
1749:                    == byte_position (DECL_CHAIN (TYPE_FIELDS (rec_type)))
1750:                 && TREE_CODE (TREE_OPERAND (operand, 0)) == NOP_EXPR)
1751:               {
1752:                 operand = TREE_OPERAND (TREE_OPERAND (operand, 0), 0);
1753:                 type = TREE_TYPE (operand);
1754:               }
1755:             else if (TYPE_UNCONSTRAINED_ARRAY (rec_type))
1756:               {
1757:                 operand
1758:                   = convert (TREE_TYPE (TYPE_UNCONSTRAINED_ARRAY (rec_type)),
1759:                              operand);
1760:                 type = TREE_TYPE (operand);
1761:               }
1762:           }
1763:
1764:         /* If we want to refer to an unconstrained array, use the appropriate
1765:            expression.  But this will never survive down to the back-end.  */
1766:         if (TYPE_IS_FAT_POINTER_P (type) || TYPE_IS_EXTENDED_POINTER_P (type))
1767:           {
1768:             result = build1 (UNCONSTRAINED_ARRAY_REF,
1769:                              TYPE_UNCONSTRAINED_ARRAY (type), operand);
1770:             TREE_READONLY (result)
1771:               = TYPE_READONLY (TYPE_UNCONSTRAINED_ARRAY (type));
1772:           }
1773:
1774:         /* If we are dereferencing an ADDR_EXPR, return its operand.  */
1775:         else if (TREE_CODE (operand) == ADDR_EXPR)
1776:           result = TREE_OPERAND (operand, 0);
1777:
1778:         /* Otherwise, build and fold the indirect reference.  */
1779:         else
1780:           {
1781:             result = build_fold_indirect_ref (operand);
1782:             TREE_READONLY (result) = TYPE_READONLY (TREE_TYPE (type));
1783:           }
1784:
1785:         if (!TYPE_IS_FAT_POINTER_P (type)
1786:             && !TYPE_IS_EXTENDED_POINTER_P (type)
1787:             && TYPE_VOLATILE (TREE_TYPE (type)))
1788:           {
1789:             TREE_SIDE_EFFECTS (result) = 1;
1790:             if (INDIRECT_REF_P (result))
1791:               TREE_THIS_VOLATILE (result) = TYPE_VOLATILE (TREE_TYPE (result));
1792:           }
1793:
1794:         if ((INDIRECT_REF_P (result)
1795:              || TREE_CODE (result) == UNCONSTRAINED_ARRAY_REF)
1796:             && can_never_be_null)
1797:           TREE_THIS_NOTRAP (result) = 1;
1798:
1799:         break;
1800:       }
1801:
1802:     case NEGATE_EXPR:
1803:     case BIT_NOT_EXPR:
1804:       {
1805:         tree modulus = ((operation_type
1806:                          && TREE_CODE (operation_type) == INTEGER_TYPE
1807:                          && TYPE_MODULAR_P (operation_type))
1808:                         ? TYPE_MODULUS (operation_type) : NULL_TREE);
1809:         int mod_pow2 = modulus && integer_pow2p (modulus);
1810:
1811:         /* If this is a modular type, there are various possibilities
1812:            depending on the operation and whether the modulus is a
1813:            power of two or not.  */
1814:
1815:         if (modulus)
1816:           {
1817:             gcc_assert (operation_type == base_type);
1818:             operand = convert (operation_type, operand);
1819:
1820:             /* The fastest in the negate case for binary modulus is
1821:                the straightforward code; the TRUNC_MOD_EXPR below
1822:                is an AND operation.  */
1823:             if (op_code == NEGATE_EXPR && mod_pow2)
1824:               result = fold_build2 (TRUNC_MOD_EXPR, operation_type,
1825:                                     fold_build1 (NEGATE_EXPR, operation_type,
1826:                                                  operand),
1827:                                     modulus);
1828:
1829:             /* For nonbinary negate case, return zero for zero operand,
1830:                else return the modulus minus the operand.  If the modulus
1831:                is a power of two minus one, we can do the subtraction
1832:                as an XOR since it is equivalent and faster on most machines. */
1833:             else if (op_code == NEGATE_EXPR && !mod_pow2)
1834:               {
1835:                 if (integer_pow2p (fold_build2 (PLUS_EXPR, operation_type,
1836:                                                 modulus,
1837:                                                 build_int_cst (operation_type,
1838:                                                                1))))
1839:                   result = fold_build2 (BIT_XOR_EXPR, operation_type,
1840:                                         operand, modulus);
1841:                 else
1842:                   result = fold_build2 (MINUS_EXPR, operation_type,
1843:                                         modulus, operand);
1844:
1845:                 result = fold_build3 (COND_EXPR, operation_type,
1846:                                       fold_build2 (NE_EXPR,
1847:                                                    boolean_type_node,
1848:                                                    operand,
1849:                                                    build_int_cst
1850:                                                    (operation_type, 0)),
1851:                                       result, operand);
1852:               }
1853:             else
1854:               {
1855:                 /* For the NOT cases, we need a constant equal to
1856:                    the modulus minus one.  For a binary modulus, we
1857:                    XOR against the constant and subtract the operand from
1858:                    that constant for nonbinary modulus.  */
1859:
1860:                 tree cnst = fold_build2 (MINUS_EXPR, operation_type, modulus,
1861:                                          build_int_cst (operation_type, 1));
1862:
1863:                 if (mod_pow2)
1864:                   result = fold_build2 (BIT_XOR_EXPR, operation_type,
1865:                                         operand, cnst);
1866:                 else
1867:                   result = fold_build2 (MINUS_EXPR, operation_type,
1868:                                         cnst, operand);
1869:               }
1870:
1871:             break;
1872:           }
1873:       }
1874:
1875:       /* ... fall through ... */
1876:
1877:     default:
1878:       gcc_assert (operation_type == base_type);
1879:       result = fold_build1 (op_code, operation_type,
1880:                             convert (operation_type, operand));
1881:     }
1882:
1883:   if (result_type && TREE_TYPE (result) != result_type)
1884:     result = convert (result_type, result);
1885:
1886:   return result;
1887: }
1888:
1889: /* Similar, but for COND_EXPR.  */
1890:
1891: tree
1892: build_cond_expr (tree result_type, tree condition_operand,
1893:                  tree true_operand, tree false_operand)
1894: {
1895:   bool addr_p = false;
1896:   tree result;
1897:
1898:   /* The front-end verified that result, true and false operands have
1899:      same base type.  Convert everything to the result type.  */
1900:   true_operand = convert (result_type, true_operand);
1901:   false_operand = convert (result_type, false_operand);
1902:
1903:   /* If the result type is unconstrained or variable-sized, take the address
1904:      of the operands and then dereference the result.  Likewise if the result
1905:      type is passed by reference, because creating a temporary of this type is
1906:      not allowed.  */
1907:   if (TREE_CODE (result_type) == UNCONSTRAINED_ARRAY_TYPE
1908:       || type_contains_placeholder_p (result_type)
1909:       || !TREE_CONSTANT (TYPE_SIZE (result_type))
1910:       || TYPE_IS_BY_REFERENCE_P (result_type))
1911:     {
1912:       result_type = build_pointer_type (result_type);
1913:       true_operand = build_unary_op (ADDR_EXPR, result_type, true_operand);
1914:       false_operand = build_unary_op (ADDR_EXPR, result_type, false_operand);
1915:       addr_p = true;
1916:     }
1917:
1918:   result = fold_build3 (COND_EXPR, result_type, condition_operand,
1919:                         true_operand, false_operand);
1920:
1921:   /* If we have a common SAVE_EXPR (possibly surrounded by arithmetics)
1922:      in both arms, make sure it gets evaluated by moving it ahead of the
1923:      conditional expression.  This is necessary because it is evaluated
1924:      in only one place at run time and would otherwise be uninitialized
1925:      in one of the arms.  */
1926:   true_operand = skip_simple_arithmetic (true_operand);
1927:   false_operand = skip_simple_arithmetic (false_operand);
1928:
1929:   if (true_operand == false_operand && TREE_CODE (true_operand) == SAVE_EXPR)
1930:     result = build2 (COMPOUND_EXPR, result_type, true_operand, result);
1931:
1932:   if (addr_p)
1933:     result = build_unary_op (INDIRECT_REF, NULL_TREE, result);
1934:
1935:   return result;
1936: }
1937:
1938: /* Similar, but for COMPOUND_EXPR.  */
1939:
1940: tree
1941: build_compound_expr (tree result_type, tree stmt_operand, tree expr_operand)
1942: {
1943:   bool addr_p = false;
1944:   tree result;
1945:
1946:   /* If the result type is unconstrained, take the address of the operand and
1947:      then dereference the result.  Likewise if the result type is passed by
1948:      reference, but this is natively handled in the gimplifier.  */
1949:   if (TREE_CODE (result_type) == UNCONSTRAINED_ARRAY_TYPE
1950:       || CONTAINS_PLACEHOLDER_P (TYPE_SIZE (result_type)))
1951:     {
1952:       result_type = build_pointer_type (result_type);
1953:       expr_operand = build_unary_op (ADDR_EXPR, result_type, expr_operand);
1954:       addr_p = true;
1955:     }
1956:
1957:   result = fold_build2 (COMPOUND_EXPR, result_type, stmt_operand,
1958:                         expr_operand);
1959:
1960:   if (addr_p)
1961:     result = build_unary_op (INDIRECT_REF, NULL_TREE, result);
1962:
1963:   return result;
1964: }
1965:
1966: /* Conveniently construct a function call expression.  FNDECL names the
1967:    function to be called, N is the number of arguments, and the "..."
1968:    parameters are the argument expressions.  Unlike build_call_expr
1969:    this doesn't fold the call, hence it will always return a CALL_EXPR.  */
1970:
1971: tree
1972: build_call_n_expr (tree fndecl, int n, ...)
1973: {
1974:   va_list ap;
1975:   tree fntype = TREE_TYPE (fndecl);
1976:   tree fn = build1 (ADDR_EXPR, build_pointer_type (fntype), fndecl);
1977:
1978:   va_start (ap, n);
1979:   fn = build_call_valist (TREE_TYPE (fntype), fn, n, ap);
1980:   va_end (ap);
1981:   return fn;
1982: }
1983:
1984: /* Build a goto to LABEL for a raise, with an optional call to Local_Raise.
```

## gcc/ada/gcc-interface/utils2.cc:2018–2130

```text
2018: expand_sloc (Node_Id gnat_node, tree *filename, tree *line, tree *col)
2019: {
2020:   const char *str;
2021:   int line_number, column_number;
2022:
2023:   if (Debug_Flag_NN || Exception_Locations_Suppressed)
2024:     {
2025:       str = "";
2026:       line_number = 0;
2027:       column_number = 0;
2028:     }
2029:   else if (Present (gnat_node) && Sloc (gnat_node) != No_Location)
2030:     {
2031:       str = Get_Name_String
2032:             (Debug_Source_Name (Get_Source_File_Index (Sloc (gnat_node))));
2033:       line_number = Get_Logical_Line_Number (Sloc (gnat_node));
2034:       column_number = Get_Column_Number (Sloc (gnat_node));
2035:     }
2036:   else
2037:     {
2038:       str = lbasename (LOCATION_FILE (input_location));
2039:       line_number = LOCATION_LINE (input_location);
2040:       column_number = LOCATION_COLUMN (input_location);
2041:     }
2042:
2043:   const int len = strlen (str);
2044:   *filename = build_string (len, str);
2045:   TREE_TYPE (*filename) = build_array_type (char_type_node,
2046:                                             build_index_type (size_int (len)));
2047:   *line = build_int_cst (NULL_TREE, line_number);
2048:   if (col)
2049:     *col = build_int_cst (NULL_TREE, column_number);
2050: }
2051:
2052: /* Build a call to a function that raises an exception and passes file name
2053:    and line number, if requested.  MSG says which exception function to call.
2054:    GNAT_NODE is the node conveying the source location for which the error
2055:    should be signaled, or Empty in which case the error is signaled for the
2056:    current location.  KIND says which kind of exception node this is for,
2057:    among N_Raise_{Constraint,Storage,Program}_Error.  */
2058:
2059: tree
2060: build_call_raise (int msg, Node_Id gnat_node, char kind)
2061: {
2062:   Entity_Id gnat_label = get_exception_label (kind);
2063:   tree fndecl = gnat_raise_decls[msg];
2064:   tree filename, line;
2065:
2066:   /* If this is to be done as a goto, handle that case.  */
2067:   if (Present (gnat_label))
2068:     return build_goto_raise (gnat_label, msg);
2069:
2070:   expand_sloc (gnat_node, &filename, &line, NULL);
2071:
2072:   return
2073:     build_call_n_expr (fndecl, 2,
2074:                        build1 (ADDR_EXPR,
2075:                                build_pointer_type (char_type_node),
2076:                                filename),
2077:                        line);
2078: }
2079:
2080: /* Similar to build_call_raise, with extra information about the column
2081:    where the check failed.  */
2082:
2083: tree
2084: build_call_raise_column (int msg, Node_Id gnat_node, char kind)
2085: {
2086:   Entity_Id gnat_label = get_exception_label (kind);
2087:   tree fndecl = gnat_raise_decls_ext[msg];
2088:   tree filename, line, col;
2089:
2090:   /* If this is to be done as a goto, handle that case.  */
2091:   if (Present (gnat_label))
2092:     return build_goto_raise (gnat_label, msg);
2093:
2094:   expand_sloc (gnat_node, &filename, &line, &col);
2095:
2096:   return
2097:     build_call_n_expr (fndecl, 3,
2098:                        build1 (ADDR_EXPR,
2099:                                build_pointer_type (char_type_node),
2100:                                filename),
2101:                        line, col);
2102: }
2103:
2104: /* Similar to build_call_raise_column, for an index or range check exception ,
2105:    with extra information of the form "INDEX out of range FIRST..LAST".  */
2106:
2107: tree
2108: build_call_raise_range (int msg, Node_Id gnat_node, char kind,
2109:                         tree index, tree first, tree last)
2110: {
2111:   Entity_Id gnat_label = get_exception_label (kind);
2112:   tree fndecl = gnat_raise_decls_ext[msg];
2113:   tree filename, line, col;
2114:
2115:   /* If this is to be done as a goto, handle that case.  */
2116:   if (Present (gnat_label))
2117:     return build_goto_raise (gnat_label, msg);
2118:
2119:   expand_sloc (gnat_node, &filename, &line, &col);
2120:
2121:   return
2122:     build_call_n_expr (fndecl, 6,
2123:                        build1 (ADDR_EXPR,
2124:                                build_pointer_type (char_type_node),
2125:                                filename),
2126:                        line, col,
2127:                        convert (integer_type_node, index),
2128:                        convert (integer_type_node, first),
2129:                        convert (integer_type_node, last));
2130: }
```

## gcc/ada/gcc-interface/utils2.cc:3045–3179

```text
3045:         return DECL_CONST_CORRESPONDING_VAR (t)
3046:                && gnat_mark_addressable (DECL_CONST_CORRESPONDING_VAR (t));
3047:
3048:       default:
3049:         return true;
3050:     }
3051: }
3052:
3053: /* Return true if EXP is a stable expression for the purpose of the functions
3054:    below and, therefore, can be returned unmodified by them.  We accept things
3055:    that are actual constants or that have already been handled.  */
3056:
3057: static bool
3058: gnat_stable_expr_p (tree exp)
3059: {
3060:   enum tree_code code = TREE_CODE (exp);
3061:   return TREE_CONSTANT (exp) || code == NULL_EXPR || code == SAVE_EXPR;
3062: }
3063:
3064: /* Save EXP for later use or reuse.  This is equivalent to save_expr in tree.cc
3065:    but we know how to handle our own nodes.  */
3066:
3067: tree
3068: gnat_save_expr (tree exp)
3069: {
3070:   tree type = TREE_TYPE (exp);
3071:   enum tree_code code = TREE_CODE (exp);
3072:
3073:   if (gnat_stable_expr_p (exp))
3074:     return exp;
3075:
3076:   if (code == UNCONSTRAINED_ARRAY_REF)
3077:     {
3078:       tree t = build1 (code, type, gnat_save_expr (TREE_OPERAND (exp, 0)));
3079:       TREE_READONLY (t) = TYPE_READONLY (type);
3080:       return t;
3081:     }
3082:
3083:   /* If this is a COMPONENT_REF of a fat pointer, save the entire fat pointer.
3084:      This may be more efficient, but will also allow us to more easily find
3085:      the match for the PLACEHOLDER_EXPR.  */
3086:   if (code == COMPONENT_REF
3087:       && (TYPE_IS_FAT_POINTER_P (TREE_TYPE (TREE_OPERAND (exp, 0)))
3088:           || TYPE_IS_EXTENDED_POINTER_P (TREE_TYPE (TREE_OPERAND (exp, 0)))))
3089:     return build3 (code, type, gnat_save_expr (TREE_OPERAND (exp, 0)),
3090:                    TREE_OPERAND (exp, 1), NULL_TREE);
3091:
3092:   return save_expr (exp);
3093: }
3094:
3095: /* Protect EXP for immediate reuse.  This is a variant of gnat_save_expr that
3096:    is optimized under the assumption that EXP's value doesn't change before
3097:    its subsequent reuse(s) except potentially through its reevaluation.
3098:
3099:    gnat_protect_expr guarantees that multiple evaluations of the expression
3100:    will not generate multiple side effects, whereas gnat_save_expr further
3101:    guarantees that all evaluations will yield the same result.  */
3102:
3103: tree
3104: gnat_protect_expr (tree exp)
3105: {
3106:   tree type = TREE_TYPE (exp);
3107:   enum tree_code code = TREE_CODE (exp);
3108:
3109:   if (gnat_stable_expr_p (exp))
3110:     return exp;
3111:
3112:   /* If EXP has no side effects, we theoretically don't need to do anything.
3113:      However, we may be recursively passed more and more complex expressions
3114:      involving checks which will be reused multiple times and eventually be
3115:      unshared for gimplification; in order to avoid a complexity explosion
3116:      at that point, we protect any expressions more complex than a simple
3117:      arithmetic expression.  */
3118:   if (!TREE_SIDE_EFFECTS (exp))
3119:     {
3120:       tree inner = skip_simple_arithmetic (exp);
3121:       if (!EXPR_P (inner) || REFERENCE_CLASS_P (inner))
3122:         return exp;
3123:     }
3124:
3125:   /* If this is a conversion, protect what's inside the conversion.  */
3126:   if (code == NON_LVALUE_EXPR
3127:       || CONVERT_EXPR_CODE_P (code)
3128:       || code == VIEW_CONVERT_EXPR)
3129:     return build1 (code, type, gnat_protect_expr (TREE_OPERAND (exp, 0)));
3130:
3131:   /* If we're indirectly referencing something, we only need to protect the
3132:      address since the data itself can't change in these situations.  */
3133:   if (code == INDIRECT_REF || code == UNCONSTRAINED_ARRAY_REF)
3134:     {
3135:       tree t = build1 (code, type, gnat_protect_expr (TREE_OPERAND (exp, 0)));
3136:       TREE_READONLY (t) = TYPE_READONLY (type);
3137:       return t;
3138:     }
3139:
3140:   /* Likewise if we're indirectly referencing part of something.  */
3141:   if (code == COMPONENT_REF
3142:       && INDIRECT_REF_P (TREE_OPERAND (exp, 0)))
3143:     return build3 (code, type, gnat_protect_expr (TREE_OPERAND (exp, 0)),
3144:                    TREE_OPERAND (exp, 1), NULL_TREE);
3145:
3146:   /* An atomic load is an INDIRECT_REF of its first argument, so apply the
3147:      same transformation as in the INDIRECT_REF case above.  */
3148:   if (code == CALL_EXPR && call_is_atomic_load (exp))
3149:     return build_call_expr (TREE_OPERAND (CALL_EXPR_FN (exp), 0), 2,
3150:                             gnat_protect_expr (CALL_EXPR_ARG (exp, 0)),
3151:                             CALL_EXPR_ARG (exp, 1));
3152:
3153:   /* If this is a COMPONENT_REF of a fat pointer, save the entire fat pointer.
3154:      This may be more efficient, but will also allow us to more easily find
3155:      the match for the PLACEHOLDER_EXPR.  */
3156:   if (code == COMPONENT_REF
3157:       && (TYPE_IS_FAT_POINTER_P (TREE_TYPE (TREE_OPERAND (exp, 0)))
3158:           || TYPE_IS_EXTENDED_POINTER_P (TREE_TYPE (TREE_OPERAND (exp, 0)))))
3159:     return build3 (code, type, gnat_protect_expr (TREE_OPERAND (exp, 0)),
3160:                    TREE_OPERAND (exp, 1), NULL_TREE);
3161:
3162:   /* If this is a fat pointer or a scalar, just make a SAVE_EXPR.  Likewise
3163:      for a CALL_EXPR as large objects are returned via invisible reference
3164:      in most ABIs so the temporary will directly be filled by the callee.  */
3165:   if (TYPE_IS_FAT_POINTER_P (type)
3166:       || TYPE_IS_EXTENDED_POINTER_P (type)
3167:       || !AGGREGATE_TYPE_P (type)
3168:       || code == CALL_EXPR)
3169:     return save_expr (exp);
3170:
3171:   /* Otherwise reference, protect the address and dereference.  */
3172:   return
3173:     build_unary_op (INDIRECT_REF, type,
3174:                     save_expr (build_unary_op (ADDR_EXPR, NULL_TREE, exp)));
3175: }
3176:
3177: /* This is equivalent to stabilize_reference_1 in tree.cc but we take an extra
3178:    argument to force evaluation of everything.  */
3179:
```

## gcc/tree.cc:1212–1230

```text
1212:     case TREE_BINFO:
1213:       return (offsetof (struct tree_binfo, base_binfos)
1214:               + vec<tree, va_gc>
1215:                   ::embedded_size (BINFO_N_BASE_BINFOS (node)));
1216:
1217:     case TREE_VEC:
1218:       return (sizeof (struct tree_vec)
1219:               + (TREE_VEC_LENGTH (node) - 1) * sizeof (tree));
1220:
1221:     case VECTOR_CST:
1222:       return (sizeof (struct tree_vector)
1223:               + (vector_cst_encoded_nelts (node) - 1) * sizeof (tree));
1224:
1225:     case STRING_CST:
1226:       return TREE_STRING_LENGTH (node) + offsetof (struct tree_string, str) + 1;
1227:
1228:     case OMP_CLAUSE:
1229:       return (sizeof (struct tree_omp_clause)
1230:               + (omp_clause_num_ops[OMP_CLAUSE_CODE (node)] - 1)
```

## gcc/tree.cc:1468–1479

```text
1468:
1469: tree
1470: copy_node (tree node MEM_STAT_DECL)
1471: {
1472:   tree t;
1473:   enum tree_code code = TREE_CODE (node);
1474:   size_t length;
1475:
1476:   gcc_assert (code != STATEMENT_LIST);
1477:
1478:   length = tree_size (node);
1479:   record_node_allocation_statistics (code, length);
```

## gcc/tree.cc:4132–4164

```text
4132:    *at compile time* generate code to use the saved value.
4133:    This produces correct result provided that *at run time* control
4134:    always flows through the insns made by the first expand_expr
4135:    before reaching the other places where the save_expr was evaluated.
4136:    You, the caller of save_expr, must make sure this is so.
4137:
4138:    Constants, and certain read-only nodes, are returned with no
4139:    SAVE_EXPR because that is safe.  Expressions containing placeholders
4140:    are not touched; see tree.def for an explanation of what these
4141:    are used for.  */
4142:
4143: tree
4144: save_expr (tree expr)
4145: {
4146:   tree inner;
4147:
4148:   /* If the tree evaluates to a constant, then we don't want to hide that
4149:      fact (i.e. this allows further folding, and direct checks for constants).
4150:      However, a read-only object that has side effects cannot be bypassed.
4151:      Since it is no problem to reevaluate literals, we just return the
4152:      literal node.  */
4153:   inner = skip_simple_arithmetic (expr);
4154:   if (TREE_CODE (inner) == ERROR_MARK)
4155:     return inner;
4156:
4157:   if (tree_invariant_p_1 (inner))
4158:     return expr;
4159:
4160:   /* If INNER contains a PLACEHOLDER_EXPR, we must evaluate it each time, since
4161:      it means that the size or offset of some field of an object depends on
4162:      the value within another field.
4163:
4164:      Note that it must not be the case that EXPR contains both a PLACEHOLDER_EXPR
```

## gcc/tree.cc:11020–11077

```text
11020:
11021:
11022: /* Build an OMP clause with code CODE.  LOC is the location of the
11023:    clause.  */
11024:
11025: tree
11026: build_omp_clause (location_t loc, enum omp_clause_code code)
11027: {
11028:   tree t;
11029:   int size, length;
11030:
11031:   length = omp_clause_num_ops[code];
11032:   size = (sizeof (struct tree_omp_clause) + (length - 1) * sizeof (tree));
11033:
11034:   record_node_allocation_statistics (OMP_CLAUSE, size);
11035:
11036:   t = (tree) ggc_internal_alloc (size);
11037:   memset (t, 0, size);
11038:   TREE_SET_CODE (t, OMP_CLAUSE);
11039:   OMP_CLAUSE_SET_CODE (t, code);
11040:   OMP_CLAUSE_LOCATION (t) = loc;
11041:
11042:   return t;
11043: }
11044:
11045: /* Build a tcc_vl_exp object with code CODE and room for LEN operands.  LEN
11046:    includes the implicit operand count in TREE_OPERAND 0, and so must be >= 1.
11047:    Except for the CODE and operand count field, other storage for the
11048:    object is initialized to zeros.  */
11049:
11050: tree
11051: build_vl_exp (enum tree_code code, int len MEM_STAT_DECL)
11052: {
11053:   tree t;
11054:   int length = (len - 1) * sizeof (tree) + sizeof (struct tree_exp);
11055:
11056:   gcc_assert (TREE_CODE_CLASS (code) == tcc_vl_exp);
11057:   gcc_assert (len >= 1);
11058:
11059:   record_node_allocation_statistics (code, length);
11060:
11061:   t = ggc_alloc_cleared_tree_node_stat (length PASS_MEM_STAT);
11062:
11063:   TREE_SET_CODE (t, code);
11064:
11065:   /* Can't use TREE_OPERAND to store the length because if checking is
11066:      enabled, it will try to check the length before we store it.  :-P  */
11067:   t->exp.operands[0] = build_int_cst (sizetype, len);
11068:
11069:   return t;
11070: }
11071:
11072: /* Helper function for build_call_* functions; build a CALL_EXPR with
11073:    indicated RETURN_TYPE, FN, and NARGS, but do not initialize any of
11074:    the argument slots.  */
11075:
11076: static tree
11077: build_call_1 (tree return_type, tree fn, int nargs)
```

## gcc/tree.cc:11194–11224

```text
11194:   for (i = 0; i < n; i++)
11195:     argarray[i] = va_arg (ap, tree);
11196:   va_end (ap);
11197:   return build_call_expr_loc_array (loc, fndecl, n, argarray);
11198: }
11199:
11200: /* Like build_call_expr_loc (UNKNOWN_LOCATION, ...).  Duplicated because
11201:    varargs macros aren't supported by all bootstrap compilers.  */
11202:
11203: tree
11204: build_call_expr (tree fndecl, int n, ...)
11205: {
11206:   va_list ap;
11207:   tree *argarray = XALLOCAVEC (tree, n);
11208:   int i;
11209:
11210:   va_start (ap, n);
11211:   for (i = 0; i < n; i++)
11212:     argarray[i] = va_arg (ap, tree);
11213:   va_end (ap);
11214:   return build_call_expr_loc_array (UNKNOWN_LOCATION, fndecl, n, argarray);
11215: }
11216:
11217: /* Build an internal call to IFN, with arguments ARGS[0:N-1] and with return
11218:    type TYPE.  This is just like CALL_EXPR, except its CALL_EXPR_FN is NULL.
11219:    It will get gimplified later into an ordinary internal function.  */
11220:
11221: tree
11222: build_call_expr_internal_loc_array (location_t loc, internal_fn ifn,
11223:                                     tree type, int n, const tree *args)
11224: {
```

## gcc/passes.def:27–42

```text
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
134:               && gimple_code (gimple_seq_first_stmt (body)) == GIMPLE_BIND);
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
157:          most certainly be.  */
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
168:           || (gimple_return_retval (data.return_statements.last().stmt)
169:               != NULL)))
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
187:         {
188:           /* Remove the line number from the representative return statement.
189:              It now fills in for the fallthru too.  Failure to remove this
190:              will result in incorrect results for coverage analysis.  */
191:           gimple_set_location (t.stmt, UNKNOWN_LOCATION);
192:           may_fallthru = false;
193:         }
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
1195:         {
1196:           /* Remove the line number from the representative return statement.
1197:              It now fills in for many such returns.  Failure to remove this
1198:              will result in incorrect results for coverage analysis.  */
1199:           gimple_set_location (tmp_rs.stmt, UNKNOWN_LOCATION);
1200:
1201:           goto found;
1202:         }
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

## gcc/gimplify.cc:1270–1282

```text
1270:
1271: static void
1272: build_stack_save_restore (gcall **save, gcall **restore)
1273: {
1274:   tree tmp_var;
1275:
1276:   *save = gimple_build_call (builtin_decl_implicit (BUILT_IN_STACK_SAVE), 0);
1277:   tmp_var = create_tmp_var (ptr_type_node, "saved_stack");
1278:   gimple_call_set_lhs (*save, tmp_var);
1279:
1280:   *restore
1281:     = gimple_build_call (builtin_decl_implicit (BUILT_IN_STACK_RESTORE),
1282:                          1, tmp_var);
```

## gcc/gimplify.cc:1677–1845

```text
1677:           if (DECL_HARD_REGISTER (t) && !is_global_var (t) && cfun)
1678:             cfun->has_local_explicit_reg_vars = true;
1679:         }
1680:     }
1681:
1682:   bind_stmt = gimple_build_bind (BIND_EXPR_VARS (bind_expr), NULL,
1683:                                  BIND_EXPR_BLOCK (bind_expr));
1684:   gimple_push_bind_expr (bind_stmt);
1685:
1686:   gimplify_ctxp->keep_stack = false;
1687:   gimplify_ctxp->save_stack = false;
1688:
1689:   /* Gimplify the body into the GIMPLE_BIND tuple's body.  */
1690:   body = NULL;
1691:   gimplify_stmt (&BIND_EXPR_BODY (bind_expr), &body);
1692:   gimple_bind_set_body (bind_stmt, body);
1693:
1694:   /* Source location wise, the cleanup code (stack_restore and clobbers)
1695:      belongs to the end of the block, so propagate what we have.  The
1696:      stack_save operation belongs to the beginning of block, which we can
1697:      infer from the bind_expr directly if the block has no explicit
1698:      assignment.  */
1699:   if (BIND_EXPR_BLOCK (bind_expr))
1700:     {
1701:       end_locus = BLOCK_SOURCE_END_LOCATION (BIND_EXPR_BLOCK (bind_expr));
1702:       start_locus = BLOCK_SOURCE_LOCATION (BIND_EXPR_BLOCK (bind_expr));
1703:     }
1704:   if (start_locus == 0)
1705:     start_locus = EXPR_LOCATION (bind_expr);
1706:
1707:   cleanup = NULL;
1708:   stack_save = NULL;
1709:
1710:   /* Add clobbers for all variables that go out of scope.  */
1711:   for (t = BIND_EXPR_VARS (bind_expr); t ; t = DECL_CHAIN (t))
1712:     {
1713:       if (VAR_P (t)
1714:           && !is_global_var (t)
1715:           && DECL_CONTEXT (t) == current_function_decl)
1716:         {
1717:           if (flag_openmp
1718:               && DECL_HAS_VALUE_EXPR_P (t)
1719:               && TREE_USED (t)
1720:               && lookup_attribute ("omp allocate", DECL_ATTRIBUTES (t)))
1721:             {
1722:               /* For Fortran, TREE_CHAIN (TREE_VALUE (attr)) is set, which
1723:                  causes that the GOMP_free call is already added above;
1724:                  and "omp allocate" is removed from DECL_ATTRIBUTES.  */
1725:               tree v = TREE_OPERAND (DECL_VALUE_EXPR (t), 0);
1726:               tree tmp = builtin_decl_explicit (BUILT_IN_GOMP_FREE);
1727:               tmp = build_call_expr_loc (end_locus, tmp, 2, v,
1728:                                          build_zero_cst (ptr_type_node));
1729:               gimplify_and_add (tmp, &cleanup);
1730:               gimple *clobber_stmt;
1731:               tmp = build_clobber (TREE_TYPE (v), CLOBBER_STORAGE_END);
1732:               clobber_stmt = gimple_build_assign (v, tmp);
1733:               gimple_set_location (clobber_stmt, end_locus);
1734:               gimplify_seq_add_stmt (&cleanup, clobber_stmt);
1735:             }
1736:           if (!DECL_HARD_REGISTER (t)
1737:               && !TREE_THIS_VOLATILE (t)
1738:               && !DECL_HAS_VALUE_EXPR_P (t)
1739:               /* Only care for variables that have to be in memory.  Others
1740:                  will be rewritten into SSA names, hence moved to the
1741:                  top-level.  */
1742:               && !is_gimple_reg (t)
1743:               && flag_stack_reuse != SR_NONE)
1744:             {
1745:               tree clobber = build_clobber (TREE_TYPE (t), CLOBBER_STORAGE_END);
1746:               gimple *clobber_stmt;
1747:               clobber_stmt = gimple_build_assign (t, clobber);
1748:               gimple_set_location (clobber_stmt, end_locus);
1749:               gimplify_seq_add_stmt (&cleanup, clobber_stmt);
1750:             }
1751:
1752:           if (flag_openacc && oacc_declare_returns != NULL)
1753:             {
1754:               tree key = t;
1755:               if (DECL_HAS_VALUE_EXPR_P (key))
1756:                 {
1757:                   key = DECL_VALUE_EXPR (key);
1758:                   if (INDIRECT_REF_P (key))
1759:                     key = TREE_OPERAND (key, 0);
1760:                 }
1761:               tree *c = oacc_declare_returns->get (key);
1762:               if (c != NULL)
1763:                 {
1764:                   if (ret_clauses)
1765:                     OMP_CLAUSE_CHAIN (*c) = ret_clauses;
1766:
1767:                   ret_clauses = unshare_expr (*c);
1768:
1769:                   oacc_declare_returns->remove (key);
1770:
1771:                   if (oacc_declare_returns->is_empty ())
1772:                     {
1773:                       delete oacc_declare_returns;
1774:                       oacc_declare_returns = NULL;
1775:                     }
1776:                 }
1777:             }
1778:         }
1779:
1780:       if (asan_poisoned_variables != NULL
1781:           && asan_poisoned_variables->contains (t))
1782:         {
1783:           asan_poisoned_variables->remove (t);
1784:           asan_poison_variable (t, true, &cleanup);
1785:         }
1786:
1787:       if (gimplify_ctxp->live_switch_vars != NULL
1788:           && gimplify_ctxp->live_switch_vars->contains (t))
1789:         gimplify_ctxp->live_switch_vars->remove (t);
1790:     }
1791:
1792:   /* If the code both contains VLAs and calls alloca, then we cannot reclaim
1793:      the stack space allocated to the VLAs.  */
1794:   if (gimplify_ctxp->save_stack && !gimplify_ctxp->keep_stack)
1795:     {
1796:       gcall *stack_restore;
1797:
1798:       /* Save stack on entry and restore it on exit.  Add a try_finally
1799:          block to achieve this.  */
1800:       build_stack_save_restore (&stack_save, &stack_restore);
1801:
1802:       gimple_set_location (stack_save, start_locus);
1803:       gimple_set_location (stack_restore, end_locus);
1804:
1805:       gimplify_seq_add_stmt (&cleanup, stack_restore);
1806:     }
1807:
1808:   if (ret_clauses)
1809:     {
1810:       gomp_target *stmt;
1811:       gimple_stmt_iterator si = gsi_start (cleanup);
1812:
1813:       stmt = gimple_build_omp_target (NULL, GF_OMP_TARGET_KIND_OACC_DECLARE,
1814:                                       ret_clauses);
1815:       gsi_insert_seq_before_without_update (&si, stmt, GSI_NEW_STMT);
1816:     }
1817:
1818:   if (cleanup)
1819:     {
1820:       gtry *gs;
1821:       gimple_seq new_body;
1822:
1823:       new_body = NULL;
1824:       gs = gimple_build_try (gimple_bind_body (bind_stmt), cleanup,
1825:                              GIMPLE_TRY_FINALLY);
1826:
1827:       if (stack_save)
1828:         gimplify_seq_add_stmt (&new_body, stack_save);
1829:       gimplify_seq_add_stmt (&new_body, gs);
1830:       gimple_bind_set_body (bind_stmt, new_body);
1831:     }
1832:
1833:   /* keep_stack propagates all the way up to the outermost BIND_EXPR.  */
1834:   if (!gimplify_ctxp->keep_stack)
1835:     gimplify_ctxp->keep_stack = old_keep_stack;
1836:   gimplify_ctxp->save_stack = old_save_stack;
1837:
1838:   gimple_pop_bind_expr ();
1839:
1840:   gimplify_seq_add_stmt (pre_p, bind_stmt);
1841:
1842:   if (temp)
1843:     {
1844:       *expr_p = temp;
1845:       return GS_OK;
```

## gcc/calls.cc:590–630

```text
590: static int
591: special_function_p (const_tree fndecl, int flags)
592: {
593:   tree name_decl = DECL_NAME (fndecl);
594:
595:   if (maybe_special_function_p (fndecl)
596:       && IDENTIFIER_LENGTH (name_decl) <= 11)
597:     {
598:       const char *name = IDENTIFIER_POINTER (name_decl);
599:       const char *tname = name;
600:
601:       /* We assume that alloca will always be called by name.  It
602:          makes no sense to pass it as a pointer-to-function to
603:          anything that does not understand its behavior.  */
604:       if (IDENTIFIER_LENGTH (name_decl) == 6
605:           && name[0] == 'a'
606:           && ! strcmp (name, "alloca"))
607:         flags |= ECF_MAY_BE_ALLOCA;
608:
609:       /* Disregard prefix _ or __.  */
610:       if (name[0] == '_')
611:         {
612:           if (name[1] == '_')
613:             tname += 2;
614:           else
615:             tname += 1;
616:         }
617:
618:       /* ECF_RETURNS_TWICE is safe even for -ffreestanding.  */
619:       if (! strcmp (tname, "setjmp")
620:           || ! strcmp (tname, "sigsetjmp")
621:           || ! strcmp (name, "savectx")
622:           || ! strcmp (name, "vfork")
623:           || ! strcmp (name, "getcontext"))
624:         flags |= ECF_RETURNS_TWICE;
625:     }
626:
627:   if (DECL_BUILT_IN_CLASS (fndecl) == BUILT_IN_NORMAL
628:       && ALLOCA_FUNCTION_CODE_P (DECL_FUNCTION_CODE (fndecl)))
629:     flags |= ECF_MAY_BE_ALLOCA;
630:
```

## gcc/calls.cc:807–824

```text
807: /* Detect flags (function attributes) from the function decl or type node.  */
808:
809: int
810: flags_from_decl_or_type (const_tree exp)
811: {
812:   int flags = 0;
813:
814:   if (DECL_P (exp))
815:     {
816:       /* The function exp may have the `malloc' attribute.  */
817:       if (DECL_IS_MALLOC (exp))
818:         flags |= ECF_MALLOC;
819:
820:       /* The function exp may have the `returns_twice' attribute.  */
821:       if (DECL_IS_RETURNS_TWICE (exp))
822:         flags |= ECF_RETURNS_TWICE;
823:
824:       /* Process the pure and const attributes.  */
```

## gcc/tree-cfg.cc:2185–2200

```text
2185: /* T is CALL_EXPR.  Set current_function_calls_* flags.  */
2186:
2187: void
2188: notice_special_calls (gcall *call)
2189: {
2190:   int flags = gimple_call_flags (call);
2191:
2192:   if (flags & ECF_MAY_BE_ALLOCA)
2193:     cfun->calls_alloca = true;
2194:   if (flags & ECF_RETURNS_TWICE)
2195:     cfun->calls_setjmp = true;
2196:   if (gimple_call_must_tail_p (call))
2197:     cfun->has_musttail = true;
2198: }
2199:
2200:
```

## gcc/tree-cfg.cc:2628–2652

```text
2628:
2629: /* Return true if T, a GIMPLE_CALL, can make an abnormal transfer of control
2630:    flow.  Transfers of control flow associated with EH are excluded.  */
2631:
2632: static bool
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
```

## gcc/tree-nested.cc:2656–2719

```text
2656: /* Called via walk_function+walk_gimple_stmt, rewrite all GIMPLE_GOTOs
2657:    that reference labels from outer functions.  The rewrite will be a
2658:    call to __builtin_nonlocal_goto.  */
2659:
2660: static tree
2661: convert_nl_goto_reference (gimple_stmt_iterator *gsi, bool *handled_ops_p,
2662:                            struct walk_stmt_info *wi)
2663: {
2664:   struct nesting_info *const info = (struct nesting_info *) wi->info, *i;
2665:   tree label, new_label, target_context, x, field;
2666:   gcall *call;
2667:   gimple *stmt = gsi_stmt (*gsi);
2668:
2669:   if (gimple_code (stmt) != GIMPLE_GOTO)
2670:     {
2671:       *handled_ops_p = false;
2672:       return NULL_TREE;
2673:     }
2674:
2675:   label = gimple_goto_dest (stmt);
2676:   if (TREE_CODE (label) != LABEL_DECL)
2677:     {
2678:       *handled_ops_p = false;
2679:       return NULL_TREE;
2680:     }
2681:
2682:   target_context = decl_function_context (label);
2683:   if (target_context == info->context)
2684:     {
2685:       *handled_ops_p = false;
2686:       return NULL_TREE;
2687:     }
2688:
2689:   for (i = info->outer; target_context != i->context; i = i->outer)
2690:     continue;
2691:
2692:   /* The original user label may also be use for a normal goto, therefore
2693:      we must create a new label that will actually receive the abnormal
2694:      control transfer.  This new label will be marked LABEL_NONLOCAL; this
2695:      mark will trigger proper behavior in the cfg, as well as cause the
2696:      (hairy target-specific) non-local goto receiver code to be generated
2697:      when we expand rtl.  Enter this association into var_map so that we
2698:      can insert the new label into the IL during a second pass.  */
2699:   tree *slot = &i->var_map->get_or_insert (label);
2700:   if (*slot == NULL)
2701:     {
2702:       new_label = create_artificial_label (UNKNOWN_LOCATION);
2703:       DECL_NONLOCAL (new_label) = 1;
2704:       DECL_CONTEXT (new_label) = target_context;
2705:       *slot = new_label;
2706:     }
2707:   else
2708:     new_label = *slot;
2709:
2710:   /* Build: __builtin_nl_goto(new_label, &chain->nl_goto_field).  */
2711:   field = get_nl_goto_field (i);
2712:   x = get_frame_field (info, target_context, field, gsi);
2713:   x = build_addr (x);
2714:   x = gsi_gimplify_val (info, x, gsi);
2715:   call = gimple_build_call (builtin_decl_implicit (BUILT_IN_NONLOCAL_GOTO),
2716:                             2, build_addr (new_label), x);
2717:   gsi_replace (gsi, call, false);
2718:
2719:   /* We have handled all of STMT's operands, no need to keep going.  */
```

## gcc/tree-nested.cc:3668–3690

```text
3668:   /* If a chain_decl was created, then it needs to be registered with
3669:      struct function so that it gets initialized from the static chain
3670:      register at the beginning of the function.  */
3671:   sf = DECL_STRUCT_FUNCTION (root->context);
3672:   sf->static_chain_decl = root->chain_decl;
3673:
3674:   /* Similarly for the non-local goto save area.  */
3675:   if (root->nl_goto_field)
3676:     {
3677:       sf->nonlocal_goto_save_area
3678:         = get_frame_field (root, context, root->nl_goto_field, NULL);
3679:       sf->has_nonlocal_label = 1;
3680:     }
3681:
3682:   /* Make sure all new local variables get inserted into the
3683:      proper BIND_EXPR.  */
3684:   if (root->new_local_var_chain)
3685:     declare_vars (root->new_local_var_chain,
3686:                   gimple_seq_first_stmt (gimple_body (root->context)),
3687:                   false);
3688:
3689:   if (root->debug_var_chain)
3690:     {
```
