# Frontend invocation excerpts

GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; full files hash-verified against the retained complete source manifest.

## checks.adb:3509–3561

```ada
  3509    procedure Apply_Selected_Length_Checks
  3510      (Expr       : Node_Id;
  3511       Target_Typ : Entity_Id;
  3512       Source_Typ : Entity_Id;
  3513       Do_Static  : Boolean)
  3514    is
  3515       Checks_On : constant Boolean :=
  3516                     not Index_Checks_Suppressed (Target_Typ)
  3517                       or else
  3518                     not Length_Checks_Suppressed (Target_Typ);
  3519
  3520       Loc : constant Source_Ptr := Sloc (Expr);
  3521
  3522       Cond     : Node_Id;
  3523       R_Cno    : Node_Id;
  3524       R_Result : Check_Result;
  3525
  3526    begin
  3527       --  Only apply checks when generating code
  3528
  3529       --  Note: this means that we lose some useful warnings if the expander
  3530       --  is not active.
  3531
  3532       if not Expander_Active then
  3533          return;
  3534       end if;
  3535
  3536       R_Result :=
  3537         Selected_Length_Checks (Expr, Target_Typ, Source_Typ, Empty);
  3538
  3539       for J in 1 .. 2 loop
  3540          R_Cno := R_Result (J);
  3541          exit when No (R_Cno);
  3542
  3543          --  A length check may mention an Itype which is attached to a
  3544          --  subsequent node. At the top level in a package this can cause
  3545          --  an order-of-elaboration problem, so we make sure that the itype
  3546          --  is referenced now.
  3547
  3548          if Ekind (Current_Scope) = E_Package
  3549            and then Is_Compilation_Unit (Current_Scope)
  3550          then
  3551             Ensure_Defined (Target_Typ, Expr);
  3552
  3553             if Present (Source_Typ) then
  3554                Ensure_Defined (Source_Typ, Expr);
  3555
  3556             elsif Is_Itype (Etype (Expr)) then
  3557                Ensure_Defined (Etype (Expr), Expr);
  3558             end if;
  3559          end if;
  3560
  3561          if Nkind (R_Cno) = N_Raise_Constraint_Error
```

## checks.adb:10308–10337

```ada
 10308                   L_Index  : Node_Id;
 10309                   R_Index  : Node_Id;
 10310                   L_Bounds : Range_Nodes;
 10311                   R_Bounds : Range_Nodes;
 10312                   L_Length : Uint;
 10313                   R_Length : Uint;
 10314                   Ref_Node : Node_Id;
 10315
 10316                begin
 10317                   --  At the library level, we need to ensure that the type of
 10318                   --  the object is elaborated before the check itself is
 10319                   --  emitted. This is only done if the object is in the
 10320                   --  current compilation unit, otherwise the type is frozen
 10321                   --  and elaborated in its unit.
 10322
 10323                   if Is_Itype (Exptyp)
 10324                     and then
 10325                       Ekind (Cunit_Entity (Current_Sem_Unit)) = E_Package
 10326                     and then
 10327                       not In_Package_Body (Cunit_Entity (Current_Sem_Unit))
 10328                     and then In_Open_Scopes (Scope (Exptyp))
 10329                   then
 10330                      Ref_Node := Make_Itype_Reference (Sloc (Expr));
 10331                      Set_Itype (Ref_Node, Exptyp);
 10332                      Insert_Action (Expr, Ref_Node);
 10333                   end if;
 10334
 10335                   L_Index := First_Index (T_Typ);
 10336                   R_Index := First_Index (Exptyp);
 10337
```

## exp_aggr.adb:4339–4381

```ada
  4339          Parent_Node := Parent (Parent_Node);
  4340       end if;
  4341
  4342       --  If the context is an assignment and the aggregate is limited, this
  4343       --  is a subaggregate of an enclosing aggregate being expanded; it must
  4344       --  be built in place, so use the target of the current assignment.
  4345
  4346       if Nkind (Parent_Node) = N_Assignment_Statement
  4347         and then Is_Limited_Type (Typ)
  4348       then
  4349          Target_Expr := New_Copy_Tree (Name (Parent_Node));
  4350          Ensure_Defined (Typ, Parent_Node);
  4351          Insert_Actions (Parent_Node,
  4352            Build_Record_Aggr_Code (N, Typ, Target_Expr));
  4353          Rewrite (Parent_Node, Make_Null_Statement (Loc));
  4354
  4355       --  Do not declare a temporary to initialize an aggregate assigned to
  4356       --  a target when in-place assignment is possible, i.e. preserving the
  4357       --  by-copy semantics of aggregates. This avoids large stack usage and
  4358       --  generates more efficient code.
  4359
  4360       elsif Nkind (Parent_Node) = N_Assignment_Statement
  4361         and then In_Place_Assign_OK (N, Get_Base_Object (Name (Parent_Node)))
  4362       then
  4363          declare
  4364             Lhs : constant Node_Id := Name (Parent_Node);
  4365          begin
  4366             --  Apply discriminant check if required
  4367
  4368             if Has_Discriminants (Etype (N)) then
  4369                Apply_Discriminant_Check (N, Etype (Lhs), Lhs);
  4370             end if;
  4371
  4372             --  The check just above may have replaced the aggregate with a CE
  4373
  4374             if Nkind (N) in N_Aggregate | N_Extension_Aggregate then
  4375                Target_Expr := New_Copy_Tree (Lhs);
  4376                Ensure_Defined (Typ, Parent_Node);
  4377                Insert_Actions (Parent_Node,
  4378                  Build_Record_Aggr_Code (N, Typ, Target_Expr));
  4379                Rewrite (Parent_Node, Make_Null_Statement (Loc));
  4380             end if;
  4381          end;
```

## exp_ch3.adb:4851–4862

```ada
  4851       if Is_Concurrent_Record_Type (Rec_Type)
  4852         and then Has_Discriminants (Rec_Type)
  4853       then
  4854          declare
  4855             Disc : Entity_Id;
  4856          begin
  4857             Disc := First_Discriminant (Rec_Type);
  4858             while Present (Disc) loop
  4859                Append_Elmt (Disc, Discr_Map);
  4860                Append_Elmt (Discriminal (Disc), Discr_Map);
  4861                Next_Discriminant (Disc);
  4862             end loop;
```

## exp_ch3.adb:4890–4899

```ada
  4890
  4891          --  If No_Default_Initialization restriction is active, then we don't
  4892          --  want to build an init_proc, but we need to mark that an init_proc
  4893          --  would be needed if this restriction was not active (so that we can
  4894          --  detect attempts to call it), so set a dummy init_proc in place.
  4895
  4896          if Restriction_Active (No_Default_Initialization) then
  4897             Set_Init_Proc (Rec_Type, Proc_Id);
  4898             return;
  4899          end if;
```

## exp_ch3.adb:4918–4951

```ada
  4918
  4919             procedure Collect_Itypes (Comp : Node_Id);
  4920             --  Generate references to itypes in the aggregate, because
  4921             --  the first use of the aggregate may be in a nested scope.
  4922
  4923             --------------------
  4924             -- Collect_Itypes --
  4925             --------------------
  4926
  4927             procedure Collect_Itypes (Comp : Node_Id) is
  4928                Ref      : Node_Id;
  4929                Sub_Aggr : Node_Id;
  4930                Typ      : constant Entity_Id := Etype (Comp);
  4931
  4932             begin
  4933                if Is_Array_Type (Typ) and then Is_Itype (Typ) then
  4934                   Ref := Make_Itype_Reference (Loc);
  4935                   Set_Itype (Ref, Typ);
  4936                   Append_Freeze_Action (Rec_Type, Ref);
  4937
  4938                   Ref := Make_Itype_Reference (Loc);
  4939                   Set_Itype (Ref, Etype (First_Index (Typ)));
  4940                   Append_Freeze_Action (Rec_Type, Ref);
  4941
  4942                   --  Recurse on nested arrays
  4943
  4944                   Sub_Aggr := First (Expressions (Comp));
  4945                   while Present (Sub_Aggr) loop
  4946                      Collect_Itypes (Sub_Aggr);
  4947                      Next (Sub_Aggr);
  4948                   end loop;
  4949                end if;
  4950             end Collect_Itypes;
  4951
```

## exp_ch4.adb:2046–2088

```ada
  2046    -- Expand_Boolean_Operator --
  2047    -----------------------------
  2048
  2049    --  Note that we first get the actual subtypes of the operands, since we
  2050    --  always want to deal with types that have bounds.
  2051
  2052    procedure Expand_Boolean_Operator (N : Node_Id) is
  2053       Typ : constant Entity_Id  := Etype (N);
  2054
  2055    begin
  2056       --  Special case of bit packed array where both operands are known to be
  2057       --  properly aligned. In this case we use an efficient run time routine
  2058       --  to carry out the operation (see System.Bit_Ops).
  2059
  2060       if Is_Bit_Packed_Array (Typ)
  2061         and then not Is_Possibly_Unaligned_Object (Left_Opnd (N))
  2062         and then not Is_Possibly_Unaligned_Object (Right_Opnd (N))
  2063       then
  2064          Expand_Packed_Boolean_Operator (N);
  2065          return;
  2066       end if;
  2067
  2068       --  For the normal non-packed case, the general expansion is to build
  2069       --  function for carrying out the comparison (use Make_Boolean_Array_Op)
  2070       --  and then inserting it into the tree. The original operator node is
  2071       --  then rewritten as a call to this function. We also use this in the
  2072       --  packed case if either operand is a possibly unaligned object.
  2073
  2074       declare
  2075          Loc       : constant Source_Ptr := Sloc (N);
  2076          L         : constant Node_Id    := Relocate_Node (Left_Opnd  (N));
  2077          R         : Node_Id             := Relocate_Node (Right_Opnd (N));
  2078          Func_Body : Node_Id;
  2079          Func_Name : Entity_Id;
  2080
  2081       begin
  2082          Convert_To_Actual_Subtype (L);
  2083          Convert_To_Actual_Subtype (R);
  2084          Ensure_Defined (Etype (L), N);
  2085          Ensure_Defined (Etype (R), N);
  2086          Apply_Length_Check (R, Etype (L));
  2087
  2088          if Nkind (N) = N_Op_Xor then
```

## exp_ch4.adb:10162–10259

```ada
 10162    procedure Expand_N_Op_Ne (N : Node_Id) is
 10163       Typ : constant Entity_Id := Etype (Left_Opnd (N));
 10164
 10165    begin
 10166       --  Case of elementary type with standard operator. But if unnesting,
 10167       --  handle elementary types whose Equivalent_Types are records because
 10168       --  there may be padding or undefined fields.
 10169
 10170       if Is_Elementary_Type (Typ)
 10171         and then Sloc (Entity (N)) = Standard_Location
 10172         and then not (Ekind (Typ) in E_Class_Wide_Type
 10173                               | E_Class_Wide_Subtype
 10174                               | E_Access_Subprogram_Type
 10175                               | E_Access_Protected_Subprogram_Type
 10176                               | E_Anonymous_Access_Protected_Subprogram_Type
 10177                               | E_Exception_Type
 10178                         and then Present (Equivalent_Type (Typ))
 10179                         and then Is_Record_Type (Equivalent_Type (Typ)))
 10180       then
 10181          Binary_Op_Validity_Checks (N);
 10182
 10183          --  Deal with overflow checks in MINIMIZED/ELIMINATED mode and if
 10184          --  means we no longer have a /= operation, we are all done.
 10185
 10186          if Minimized_Eliminated_Overflow_Check (Left_Opnd (N)) then
 10187             Expand_Compare_Minimize_Eliminate_Overflow (N);
 10188          end if;
 10189
 10190          if Nkind (N) /= N_Op_Ne then
 10191             return;
 10192          end if;
 10193
 10194          --  Boolean types (requiring handling of non-standard case)
 10195
 10196          if Is_Boolean_Type (Typ) then
 10197             Adjust_Condition (Left_Opnd (N));
 10198             Adjust_Condition (Right_Opnd (N));
 10199             Set_Etype (N, Standard_Boolean);
 10200             Adjust_Result_Type (N, Typ);
 10201          end if;
 10202
 10203          Rewrite_Comparison (N);
 10204
 10205          --  Try to narrow the operation
 10206
 10207          if Typ = Universal_Integer and then Nkind (N) = N_Op_Ne then
 10208             Narrow_Large_Operation (N);
 10209          end if;
 10210
 10211       --  For all cases other than elementary types, we rewrite node as the
 10212       --  negation of an equality operation, and reanalyze. The equality to be
 10213       --  used is defined in the same scope and has the same signature. This
 10214       --  signature must be set explicitly since in an instance it may not have
 10215       --  the same visibility as in the generic unit. This avoids duplicating
 10216       --  or factoring the complex code for record/array equality tests etc.
 10217
 10218       --  This case is also used for the minimal expansion performed in
 10219       --  GNATprove mode.
 10220
 10221       else
 10222          declare
 10223             Loc : constant Source_Ptr := Sloc (N);
 10224             Neg : Node_Id;
 10225             Ne  : constant Entity_Id := Entity (N);
 10226
 10227          begin
 10228             Binary_Op_Validity_Checks (N);
 10229
 10230             Neg :=
 10231               Make_Op_Not (Loc,
 10232                 Right_Opnd =>
 10233                   Make_Op_Eq (Loc,
 10234                     Left_Opnd  => Left_Opnd (N),
 10235                     Right_Opnd => Right_Opnd (N)));
 10236
 10237             if Scope (Ne) /= Standard_Standard then
 10238                Set_Entity (Right_Opnd (Neg), Corresponding_Equality (Ne));
 10239             end if;
 10240
 10241             --  For navigation purposes, we want to treat the inequality as an
 10242             --  implicit reference to the corresponding equality. Preserve the
 10243             --  Comes_From_ source flag to generate proper Xref entries.
 10244
 10245             Preserve_Comes_From_Source (Neg, N);
 10246             Preserve_Comes_From_Source (Right_Opnd (Neg), N);
 10247             Rewrite (N, Neg);
 10248             Analyze_And_Resolve (N, Standard_Boolean);
 10249          end;
 10250       end if;
 10251
 10252       --  No need for optimization in GNATprove mode, where we would rather see
 10253       --  the original source expression.
 10254
 10255       if not GNATprove_Mode then
 10256          Optimize_Length_Comparison (N);
 10257       end if;
 10258    end Expand_N_Op_Ne;
 10259
```

## exp_ch4.adb:10290–10345

```ada
 10290    procedure Expand_N_Op_Not (N : Node_Id) is
 10291       Loc  : constant Source_Ptr := Sloc (N);
 10292       Typ  : constant Entity_Id  := Etype (Right_Opnd (N));
 10293       Opnd : Node_Id;
 10294       Arr  : Entity_Id;
 10295       A    : Entity_Id;
 10296       B    : Entity_Id;
 10297       J    : Entity_Id;
 10298       A_J  : Node_Id;
 10299       B_J  : Node_Id;
 10300
 10301       Func_Name      : Entity_Id;
 10302       Loop_Statement : Node_Id;
 10303
 10304    begin
 10305       Unary_Op_Validity_Checks (N);
 10306
 10307       --  For boolean operand, deal with non-standard booleans
 10308
 10309       if Is_Boolean_Type (Typ) then
 10310          Adjust_Condition (Right_Opnd (N));
 10311          Set_Etype (N, Standard_Boolean);
 10312          Adjust_Result_Type (N, Typ);
 10313          return;
 10314       end if;
 10315
 10316       --  Only array types need any other processing
 10317
 10318       if not Is_Array_Type (Typ) then
 10319          return;
 10320       end if;
 10321
 10322       --  Case of array operand. If bit packed with a component size of 1,
 10323       --  handle it in Exp_Pakd if the operand is known to be aligned.
 10324
 10325       if Is_Bit_Packed_Array (Typ)
 10326         and then Component_Size (Typ) = 1
 10327         and then not Is_Possibly_Unaligned_Object (Right_Opnd (N))
 10328       then
 10329          Expand_Packed_Not (N);
 10330          return;
 10331       end if;
 10332
 10333       --  Case of array operand which is not bit-packed. If the context is
 10334       --  a safe assignment, call in-place operation, If context is a larger
 10335       --  boolean expression in the context of a safe assignment, expansion is
 10336       --  done by enclosing operation.
 10337
 10338       Opnd := Relocate_Node (Right_Opnd (N));
 10339       Convert_To_Actual_Subtype (Opnd);
 10340       Arr := Etype (Opnd);
 10341       Ensure_Defined (Arr, N);
 10342       Silly_Boolean_Array_Not_Test (N, Arr);
 10343
 10344       if Nkind (Parent (N)) = N_Assignment_Statement then
 10345          if Safe_In_Place_Array_Op (Name (Parent (N)), N, Empty) then
```

## exp_ch5.adb:1014–1029

```ada
  1014             end;
  1015
  1016          --  Case of both are false with implicit conditionals allowed
  1017
  1018          else
  1019             --  Before we generate this code, we must ensure that the left and
  1020             --  right side array types are defined. They may be itypes, and we
  1021             --  cannot let them be defined inside the if, since the first use
  1022             --  in the then may not be executed.
  1023
  1024             Ensure_Defined (L_Type, N);
  1025             Ensure_Defined (R_Type, N);
  1026
  1027             --  We normally compare addresses to find out which way round to
  1028             --  do the loop, since this is reliable, and handles the cases of
  1029             --  parameters, conversions etc. But we can't do that in the bit
```

## exp_ch9.adb:14218–14245

```ada
 14218       end if;
 14219
 14220       --  State parameter. This is a pointer to the task body procedure. The
 14221       --  required value is obtained by taking 'Unrestricted_Access of the task
 14222       --  body procedure and converting it (with an unchecked conversion) to
 14223       --  the type required by the task kernel. For further details, see the
 14224       --  description of Expand_N_Task_Body. We use 'Unrestricted_Access rather
 14225       --  than 'Address in order to avoid creating trampolines.
 14226
 14227       declare
 14228          Body_Proc    : constant Node_Id := Get_Task_Body_Procedure (Ttyp);
 14229          Subp_Ptr_Typ : constant Node_Id :=
 14230                           Create_Itype (E_Access_Subprogram_Type, Tdec);
 14231          Ref          : constant Node_Id := Make_Itype_Reference (Loc);
 14232
 14233       begin
 14234          Set_Directly_Designated_Type (Subp_Ptr_Typ, Body_Proc);
 14235          Set_Etype (Subp_Ptr_Typ, Subp_Ptr_Typ);
 14236
 14237          --  Be sure to freeze a reference to the access-to-subprogram type,
 14238          --  otherwise gigi will complain that it's in the wrong scope, because
 14239          --  it's actually inside the init procedure for the record type that
 14240          --  corresponds to the task type.
 14241
 14242          Set_Itype (Ref, Subp_Ptr_Typ);
 14243          Append_Freeze_Action (Task_Rec, Ref);
 14244
 14245          Append_To (Args,
```

## exp_pakd.adb:1583–1610

```ada
  1583    ------------------------------------
  1584
  1585    --  This routine expands "a op b" for the packed cases
  1586
  1587    procedure Expand_Packed_Boolean_Operator (N : Node_Id) is
  1588       Loc : constant Source_Ptr := Sloc (N);
  1589       Typ : constant Entity_Id  := Etype (N);
  1590       L   : constant Node_Id    := Relocate_Node (Left_Opnd  (N));
  1591       R   :          Node_Id    := Relocate_Node (Right_Opnd (N));
  1592
  1593       Ltyp : Entity_Id;
  1594       Rtyp : Entity_Id;
  1595       PAT  : Entity_Id;
  1596
  1597    begin
  1598       if CodePeer_Mode then
  1599          return;
  1600       end if;
  1601
  1602       Convert_To_Actual_Subtype (L);
  1603       Convert_To_Actual_Subtype (R);
  1604
  1605       Ensure_Defined (Etype (L), N);
  1606       Ensure_Defined (Etype (R), N);
  1607
  1608       Apply_Length_Check (R, Etype (L));
  1609
  1610       Ltyp := Etype (L);
```

## exp_spark.adb:120–213

```ada
   120    begin
   121       case Nkind (N) is
   122
   123          --  Qualification of entity names in formal verification mode
   124          --  is limited to the addition of a suffix for homonyms (see
   125          --  Exp_Dbug.Qualify_Entity_Name). We used to qualify entity names
   126          --  as full expansion does, but this was removed as this prevents the
   127          --  verification back-end from using a short name for debugging and
   128          --  user interaction. The verification back-end already takes care
   129          --  of qualifying names when needed.
   130
   131          when N_Block_Statement
   132             | N_Entry_Declaration
   133             | N_Package_Body
   134             | N_Package_Declaration
   135             | N_Protected_Type_Declaration
   136             | N_Subprogram_Body
   137             | N_Task_Type_Declaration
   138          =>
   139             Qualify_Entity_Names (N);
   140
   141          --  Replace occurrences of System'To_Address by calls to
   142          --  System.Storage_Elements.To_Address.
   143
   144          when N_Attribute_Reference =>
   145             Expand_SPARK_N_Attribute_Reference (N);
   146
   147          when N_Delta_Aggregate =>
   148             Expand_SPARK_N_Delta_Aggregate (N);
   149
   150          when N_Aggregate =>
   151             Expand_SPARK_N_Aggregate (N);
   152
   153          when N_Expanded_Name
   154             | N_Identifier
   155          =>
   156             Expand_SPARK_Potential_Renaming (N);
   157
   158          --  Loop iterations over arrays need to be expanded, to avoid getting
   159          --  two names referring to the same object in memory (the array and
   160          --  the iterator) in GNATprove, especially since both can be written
   161          --  (thus possibly leading to interferences due to aliasing). No such
   162          --  problem arises with quantified expressions over arrays, which are
   163          --  dealt with specially in GNATprove.
   164
   165          when N_Loop_Statement =>
   166             Expand_SPARK_N_Loop_Statement (N);
   167
   168          when N_Object_Declaration =>
   169             Expand_SPARK_N_Object_Declaration (N);
   170
   171          when N_Object_Renaming_Declaration =>
   172             Expand_SPARK_N_Object_Renaming_Declaration (N);
   173
   174          when N_Op_Ne =>
   175             Expand_SPARK_N_Op_Ne (N);
   176
   177          --  Resolution of type conversion relies on minimal expansion of
   178          --  fixedpoint operations to insert the range check on their result.
   179
   180          when N_Op_Multiply | N_Op_Divide =>
   181             if Etype (N) = Universal_Fixed then
   182                Exp_Ch4.Fixup_Universal_Fixed_Operation (N);
   183             end if;
   184
   185          when N_Freeze_Entity =>
   186             --  Currently we only expand type freeze entities, so ignore other
   187             --  freeze entites, because it is expensive to create a suitable
   188             --  freezing environment.
   189
   190             if Is_Type (Entity (N)) then
   191                Expand_SPARK_N_Freeze_Entity (N);
   192             end if;
   193
   194          --  In SPARK mode, no other constructs require expansion
   195
   196          when N_Continue_Statement =>
   197             Expand_SPARK_N_Continue_Statement (N);
   198
   199          when others =>
   200             null;
   201       end case;
   202    end Expand_SPARK;
   203
   204    ----------------------------------
   205    -- Expand_SPARK_Delta_Or_Update --
   206    ----------------------------------
   207
   208    procedure Expand_SPARK_Delta_Or_Update
   209      (Typ  : Entity_Id;
   210       Aggr : Node_Id)
   211    is
   212       procedure Apply_Range_Checks (Choice : Node_Id);
   213       --  Apply range checks on indexes from a deep choice
```

## exp_spark.adb:1008–1023

```ada
  1008    procedure Expand_SPARK_N_Op_Ne (N : Node_Id) is
  1009       Typ : constant Entity_Id := Etype (Left_Opnd (N));
  1010
  1011    begin
  1012       --  Case of elementary type with standard operator
  1013
  1014       if Is_Elementary_Type (Typ)
  1015         and then Sloc (Entity (N)) = Standard_Location
  1016       then
  1017          null;
  1018
  1019       else
  1020          Exp_Ch4.Expand_N_Op_Ne (N);
  1021       end if;
  1022    end Expand_SPARK_N_Op_Ne;
  1023
```

## exp_util.adb:5397–5412

```ada
  5397    -- Ensure_Defined --
  5398    --------------------
  5399
  5400    procedure Ensure_Defined (Typ : Entity_Id; N : Node_Id) is
  5401       IR : Node_Id;
  5402
  5403    begin
  5404       --  An itype reference must only be created if this is a local itype, so
  5405       --  that gigi can elaborate it on the proper objstack.
  5406
  5407       if Is_Itype (Typ) and then Scope (Typ) = Current_Scope then
  5408          IR := Make_Itype_Reference (Sloc (N));
  5409          Set_Itype (IR, Typ);
  5410          Insert_Action (N, IR);
  5411       end if;
  5412    end Ensure_Defined;
```

## exp_util.adb:8159–8182

```ada
  8159                   Kill_Current_Values;
  8160
  8161                   --  If P has already been expanded, we can't park new actions
  8162                   --  on it, so we need to expand them immediately, introducing
  8163                   --  an Expression_With_Actions. N can't be an expression
  8164                   --  with actions, or else then the actions would have been
  8165                   --  inserted at an inner level.
  8166
  8167                   if Analyzed (P) then
  8168                      pragma Assert (Nkind (N) /= N_Expression_With_Actions);
  8169                      Rewrite (N,
  8170                        Make_Expression_With_Actions (Sloc (N),
  8171                          Actions    => Ins_Actions,
  8172                          Expression => Relocate_Node (N)));
  8173                      Analyze_And_Resolve (N);
  8174
  8175                   elsif Present (Actions (P)) then
  8176                      Insert_List_After_And_Analyze
  8177                        (Last (Actions (P)), Ins_Actions);
  8178                   else
  8179                      Set_Actions (P, Ins_Actions);
  8180                      Analyze_List (Actions (P));
  8181                   end if;
  8182
```

## exp_util.adb:8289–8470

```ada
  8289
  8290             when N_Elsif_Part
  8291                | N_Iteration_Scheme
  8292             =>
  8293                if Present (Condition (P)) and then N = Condition (P) then
  8294                   if Present (Condition_Actions (P)) then
  8295                      Insert_List_After_And_Analyze
  8296                        (Last (Condition_Actions (P)), Ins_Actions);
  8297                   else
  8298                      Set_Condition_Actions (P, Ins_Actions);
  8299
  8300                      --  Set the parent of the insert actions explicitly. This
  8301                      --  is not a syntactic field, but we need the parent field
  8302                      --  set, in particular so that freeze can understand that
  8303                      --  it is dealing with condition actions, and properly
  8304                      --  insert the freezing actions.
  8305
  8306                      Set_Parent (Ins_Actions, P);
  8307                      Analyze_List (Condition_Actions (P));
  8308                   end if;
  8309
  8310                   return;
  8311                end if;
  8312
  8313             --  Statements, declarations, pragmas, representation clauses
  8314
  8315             when
  8316                --  Statements
  8317
  8318                  N_Procedure_Call_Statement
  8319                | N_Statement_Other_Than_Procedure_Call
  8320
  8321                --  Pragmas
  8322
  8323                | N_Pragma
  8324
  8325                --  Representation_Clause
  8326
  8327                | N_At_Clause
  8328                | N_Attribute_Definition_Clause
  8329                | N_Enumeration_Representation_Clause
  8330                | N_Record_Representation_Clause
  8331
  8332                --  Declarations
  8333
  8334                | N_Abstract_Subprogram_Declaration
  8335                | N_Entry_Body
  8336                | N_Exception_Declaration
  8337                | N_Exception_Renaming_Declaration
  8338                | N_Expression_Function
  8339                | N_Formal_Abstract_Subprogram_Declaration
  8340                | N_Formal_Concrete_Subprogram_Declaration
  8341                | N_Formal_Object_Declaration
  8342                | N_Formal_Type_Declaration
  8343                | N_Full_Type_Declaration
  8344                | N_Function_Instantiation
  8345                | N_Generic_Function_Renaming_Declaration
  8346                | N_Generic_Package_Declaration
  8347                | N_Generic_Package_Renaming_Declaration
  8348                | N_Generic_Procedure_Renaming_Declaration
  8349                | N_Generic_Subprogram_Declaration
  8350                | N_Implicit_Label_Declaration
  8351                | N_Incomplete_Type_Declaration
  8352                | N_Number_Declaration
  8353                | N_Object_Declaration
  8354                | N_Object_Renaming_Declaration
  8355                | N_Package_Body
  8356                | N_Package_Body_Stub
  8357                | N_Package_Declaration
  8358                | N_Package_Instantiation
  8359                | N_Package_Renaming_Declaration
  8360                | N_Private_Extension_Declaration
  8361                | N_Private_Type_Declaration
  8362                | N_Procedure_Instantiation
  8363                | N_Protected_Body
  8364                | N_Protected_Body_Stub
  8365                | N_Single_Task_Declaration
  8366                | N_Subprogram_Body
  8367                | N_Subprogram_Body_Stub
  8368                | N_Subprogram_Declaration
  8369                | N_Subprogram_Renaming_Declaration
  8370                | N_Subtype_Declaration
  8371                | N_Task_Body
  8372                | N_Task_Body_Stub
  8373
  8374                --  Other things that can occur in stmt or decl lists
  8375
  8376                | N_Itype_Reference
  8377
  8378                --  Use clauses can appear in lists of declarations
  8379
  8380                | N_Use_Package_Clause
  8381                | N_Use_Type_Clause
  8382
  8383                --  Freeze entity behaves like a declaration or statement
  8384
  8385                | N_Freeze_Entity
  8386                | N_Freeze_Generic_Entity
  8387             =>
  8388                --  Do not insert here if the item is not a list member (this
  8389                --  happens for example with a triggering statement, and the
  8390                --  proper approach is to insert before the entire select).
  8391
  8392                if not Is_List_Member (P) then
  8393                   null;
  8394
  8395                --  Do not insert if parent of P is an N_Component_Association
  8396                --  node (i.e. we are in the context of an N_Aggregate or
  8397                --  N_Extension_Aggregate node. In this case we want to insert
  8398                --  before the entire aggregate.
  8399
  8400                elsif Nkind (Parent (P)) = N_Component_Association then
  8401                   null;
  8402
  8403                --  Do not insert if the parent of P is either an N_Variant node
  8404                --  or an N_Record_Definition node, meaning in either case that
  8405                --  P is a member of a component list, and that therefore the
  8406                --  actions should be inserted outside the complete record
  8407                --  declaration.
  8408
  8409                elsif Nkind (Parent (P)) in N_Variant | N_Record_Definition then
  8410                   null;
  8411
  8412                --  Do not insert freeze nodes within a block or loop generated
  8413                --  for an aggregate, because they may be elaborated too late
  8414                --  for subsequent use in the back end: within a package spec,
  8415                --  the block or loop is part of the elaboration procedure and
  8416                --  is only elaborated during the second pass.
  8417
  8418                --  If the block or loop comes from source, or the entity is
  8419                --  local to the block or loop itself, it must remain within.
  8420
  8421                elsif ((Nkind (Parent (P)) = N_Handled_Sequence_Of_Statements
  8422                         and then
  8423                           Nkind (Parent (Parent (P))) = N_Block_Statement
  8424                         and then not Comes_From_Source (Parent (Parent (P))))
  8425                       or else (Nkind (Parent (P)) = N_Loop_Statement
  8426                                 and then not Comes_From_Source (Parent (P))))
  8427                  and then Nkind (First (Ins_Actions)) = N_Freeze_Entity
  8428                  and then not
  8429                    Within_Scope (Entity (First (Ins_Actions)), Current_Scope)
  8430                then
  8431                   null;
  8432
  8433                --  Otherwise we can go ahead and do the insertion
  8434
  8435                elsif P = Wrapped_Node then
  8436                   Store_Before_Actions_In_Scope (Ins_Actions);
  8437                   return;
  8438
  8439                else
  8440                   Insert_List_Before_And_Analyze (P, Ins_Actions);
  8441                   return;
  8442                end if;
  8443
  8444             --  The expansion of task and protected type declarations can
  8445             --  create declarations for temporaries which, like other actions
  8446             --  are inserted and analyzed before the current declaration.
  8447             --  However, in some cases, the current scope is the synchronized
  8448             --  type, and for unnesting it is critical that the proper scope
  8449             --  for these generated entities be the enclosing one.
  8450
  8451             when N_Task_Type_Declaration
  8452                | N_Protected_Type_Declaration =>
  8453
  8454                declare
  8455                   Skip_Scope : constant Boolean :=
  8456                     Ekind (Current_Scope) in Concurrent_Kind;
  8457                begin
  8458                   if Skip_Scope then
  8459                      Push_Scope (Scope (Current_Scope));
  8460                   end if;
  8461
  8462                   Insert_List_Before_And_Analyze (P, Ins_Actions);
  8463
  8464                   if Skip_Scope then
  8465                      Pop_Scope;
  8466                   end if;
  8467                end;
  8468
  8469                return;
  8470
```

## exp_util.adb:12761–12824

```ada
 12761       elsif (Is_Elementary_Type (Und_Typ)
 12762               or else (Is_Record_Type (Und_Typ)
 12763                         and then Known_Static_RM_Size (Und_Typ)
 12764                         and then RM_Size (Und_Typ) <= System_Max_Integer_Size
 12765                         and then not Has_Discriminants (Und_Typ)
 12766                         and then not Is_By_Reference_Type (Und_Typ)))
 12767         and then (Variable_Ref
 12768                    or else (not Is_Name_Reference (Exp)
 12769                              and then Nkind (Exp) /= N_Type_Conversion)
 12770                    or else (not Name_Req
 12771                              and then Is_Volatile_Reference (Exp)))
 12772       then
 12773          Def_Id := Build_Temporary (Loc, 'R', Exp);
 12774          Set_Etype (Def_Id, Typ);
 12775          Res := New_Occurrence_Of (Def_Id, Loc);
 12776
 12777          --  If the expression is a packed reference, it must be reanalyzed and
 12778          --  expanded, depending on context. This is the case for actuals where
 12779          --  a constraint check may capture the actual before expansion of the
 12780          --  call is complete.
 12781
 12782          if Nkind (Exp) = N_Indexed_Component
 12783            and then Is_Packed (Etype (Prefix (Exp)))
 12784          then
 12785             Set_Analyzed (Exp, False);
 12786             Set_Analyzed (Prefix (Exp), False);
 12787          end if;
 12788
 12789          --  Generate:
 12790          --    Rnn : Typ renames Expr;
 12791
 12792          --  In GNATprove mode, we prefer to use renamings for intermediate
 12793          --  variables to definition of constants, due to the implicit move
 12794          --  operation that such a constant definition causes as part of the
 12795          --  support in GNATprove for ownership pointers. Hence, we generate
 12796          --  a renaming for a reference to an object of a nonscalar type.
 12797
 12798          if Renaming_Req
 12799            or else (GNATprove_Mode
 12800                      and then Is_Object_Reference (Exp)
 12801                      and then not Is_Scalar_Type (Und_Typ))
 12802          then
 12803             E :=
 12804               Make_Object_Renaming_Declaration (Loc,
 12805                 Defining_Identifier => Def_Id,
 12806                 Subtype_Mark        => New_Occurrence_Of (Typ, Loc),
 12807                 Name                => Relocate_Node (Exp));
 12808
 12809          --  Generate:
 12810          --    Rnn : constant Typ := Expr;
 12811
 12812          else
 12813             E :=
 12814               Make_Object_Declaration (Loc,
 12815                 Defining_Identifier => Def_Id,
 12816                 Object_Definition   => New_Occurrence_Of (Typ, Loc),
 12817                 Constant_Present    => True,
 12818                 Expression          => Relocate_Node (Exp));
 12819
 12820             Set_Assignment_OK (E);
 12821          end if;
 12822
 12823          Insert_Action (Exp, E);
 12824
```

## expander.adb:105–127

```ada
   105       --  The GNATprove_Mode flag indicates that a light expansion for formal
   106       --  verification should be used. This expansion is never done inside
   107       --  generics, because otherwise, this breaks the name resolution
   108       --  mechanism for generic instances.
   109
   110       if GNATprove_Mode then
   111          if not Inside_A_Generic then
   112             Expand_SPARK (N);
   113          end if;
   114
   115          --  Do not reset the Analyzed flag if it has been set on purpose
   116          --  during preanalysis.
   117
   118          if Full_Analysis then
   119             Set_Analyzed (N);
   120          end if;
   121
   122          --  Regular expansion is normally followed by special handling for
   123          --  transient scopes for unconstrained results, etc. but this is not
   124          --  needed, and in general cannot be done correctly, in this mode, so
   125          --  we are all done.
   126
   127          goto Leave;
```

## freeze.adb:4303–4368

```ada
  4303          -- Check_Large_Modular_Array --
  4304          -------------------------------
  4305
  4306          procedure Check_Large_Modular_Array (Typ : Entity_Id) is
  4307             Obj_Loc : constant Source_Ptr := Sloc (E);
  4308             Idx_Typ : Entity_Id;
  4309
  4310          begin
  4311             --  Nothing to do when expansion is disabled because this routine
  4312             --  generates a runtime check.
  4313
  4314             if not Expander_Active then
  4315                return;
  4316
  4317             --  Nothing to do for String literal subtypes because their index
  4318             --  cannot be a modular type.
  4319
  4320             elsif Ekind (Typ) = E_String_Literal_Subtype then
  4321                return;
  4322
  4323             --  Nothing to do for an imported object because the object will
  4324             --  be created on the exporting side.
  4325
  4326             elsif Is_Imported (E) then
  4327                return;
  4328
  4329             --  Nothing to do for unconstrained array types. This case arises
  4330             --  when the object declaration is illegal.
  4331
  4332             elsif not Is_Constrained (Typ) then
  4333                return;
  4334             end if;
  4335
  4336             Idx_Typ := Etype (First_Index (Typ));
  4337
  4338             --  To prevent arithmetic overflow with large values, we raise
  4339             --  Storage_Error under the following guard:
  4340             --
  4341             --    (Arr'Last / 2 - Arr'First / 2) > (2 ** 30)
  4342             --
  4343             --  This takes care of the boundary case, but it is preferable to
  4344             --  use a smaller limit, because even on 64-bit architectures an
  4345             --  array of more than 2 ** 30 bytes is likely to raise
  4346             --  Storage_Error.
  4347
  4348             if Is_Modular_Integer_Type (Idx_Typ)
  4349               and then RM_Size (Idx_Typ) = Standard_Long_Long_Integer_Size
  4350             then
  4351                --  Ensure that the type of the object is elaborated before
  4352                --  the check itself is emitted to avoid elaboration issues
  4353                --  in the code generator at the library level.
  4354
  4355                if Is_Itype (Etype (E))
  4356                  and then In_Open_Scopes (Scope (Etype (E)))
  4357                then
  4358                   declare
  4359                      Ref_Node : constant Node_Id :=
  4360                                   Make_Itype_Reference (Obj_Loc);
  4361                   begin
  4362                      Set_Itype (Ref_Node, Etype (E));
  4363                      Insert_Action (Decl, Ref_Node);
  4364                   end;
  4365                end if;
  4366
  4367                Insert_Action (Decl,
  4368                  Make_Raise_Storage_Error (Obj_Loc,
```

## freeze.adb:5181–5215

```ada
  5181          -----------------
  5182
  5183          procedure Check_Itype (Typ : Entity_Id) is
  5184             Desig : constant Entity_Id := Designated_Type (Typ);
  5185
  5186          begin
  5187             if not Is_Frozen (Desig)
  5188               and then Is_Frozen (Base_Type (Desig))
  5189             then
  5190                Set_Is_Frozen (Desig);
  5191
  5192                --  In addition, add an Itype_Reference to ensure that the
  5193                --  access subtype is elaborated early enough. This cannot be
  5194                --  done if the subtype may depend on discriminants.
  5195
  5196                if Ekind (Comp) = E_Component
  5197                  and then Is_Itype (Etype (Comp))
  5198                  and then not Has_Discriminants (Rec)
  5199                then
  5200                   IR := Make_Itype_Reference (Sloc (Comp));
  5201                   Set_Itype (IR, Desig);
  5202                   Add_To_Result (IR);
  5203                end if;
  5204
  5205             elsif Ekind (Typ) = E_Anonymous_Access_Subprogram_Type
  5206               and then Convention (Desig) /= Convention_Protected
  5207             then
  5208                Set_Is_Frozen (Desig);
  5209                Create_Extra_Formals (Desig, Related_Nod => Rec);
  5210             end if;
  5211          end Check_Itype;
  5212
  5213          ------------------------------------
  5214          -- Freeze_Choices_In_Variant_Part --
  5215          ------------------------------------
```

## freeze.adb:7343–7393

```ada
  7343          if Is_Class_Wide_Type (E) then
  7344             Freeze_And_Append (Root_Type (E), N, Result);
  7345
  7346             --  If the base type of the class-wide type is still incomplete,
  7347             --  the class-wide remains unfrozen as well. This is legal when
  7348             --  E is the formal of a primitive operation of some other type
  7349             --  which is being frozen.
  7350
  7351             if not Is_Frozen (Root_Type (E)) then
  7352                Set_Is_Frozen (E, False);
  7353                goto Leave;
  7354             end if;
  7355
  7356             --  The equivalent type associated with a class-wide subtype needs
  7357             --  to be frozen to ensure that its layout is done.
  7358
  7359             if Ekind (E) = E_Class_Wide_Subtype
  7360               and then Present (Equivalent_Type (E))
  7361             then
  7362                Freeze_And_Append (Equivalent_Type (E), N, Result);
  7363             end if;
  7364
  7365             --  Generate an itype reference for a library-level class-wide type
  7366             --  at the freeze point. Otherwise the first explicit reference to
  7367             --  the type may appear in an inner scope which will be rejected by
  7368             --  the back-end.
  7369
  7370             if Is_Itype (E)
  7371               and then Is_Compilation_Unit (Scope (E))
  7372             then
  7373                declare
  7374                   Ref : constant Node_Id := Make_Itype_Reference (Loc);
  7375
  7376                begin
  7377                   Set_Itype (Ref, E);
  7378
  7379                   --  From a gigi point of view, a class-wide subtype derives
  7380                   --  from its record equivalent type. As a result, the itype
  7381                   --  reference must appear after the freeze node of the
  7382                   --  equivalent type or gigi will reject the reference.
  7383
  7384                   if Ekind (E) = E_Class_Wide_Subtype
  7385                     and then Present (Equivalent_Type (E))
  7386                   then
  7387                      Insert_After (Freeze_Node (Equivalent_Type (E)), Ref);
  7388                   else
  7389                      Add_To_Result (Ref);
  7390                   end if;
  7391                end;
  7392             end if;
  7393
```

## freeze.adb:8293–8322

```ada
  8293          --  need an itype reference.
  8294
  8295          if Ekind (E) = E_Record_Type and then Has_Discriminants (E) then
  8296             declare
  8297                Comp : Entity_Id;
  8298                IR   : Node_Id;
  8299                Typ  : Entity_Id;
  8300
  8301             begin
  8302                Comp := First_Component (E);
  8303                while Present (Comp) loop
  8304                   Typ := Etype (Comp);
  8305
  8306                   if Is_Access_Type (Typ)
  8307                     and then Scope (Typ) /= E
  8308                     and then Base_Type (Designated_Type (Typ)) = E
  8309                     and then Is_Itype (Designated_Type (Typ))
  8310                   then
  8311                      IR := Make_Itype_Reference (Sloc (Comp));
  8312                      Set_Itype (IR, Designated_Type (Typ));
  8313                      Append (IR, Result);
  8314                   end if;
  8315
  8316                   Next_Component (Comp);
  8317                end loop;
  8318             end;
  8319          end if;
  8320       end if;
  8321
  8322       --  When a type is frozen, the first subtype of the type is frozen as
```

## libgnat/system-linux-x86.ads:104–112

```ada
   104
   105    Max_Priority           : constant Positive := 97;
   106    Max_Interrupt_Priority : constant Positive := 98;
   107
   108    subtype Any_Priority       is Integer      range  0 .. 98;
   109    subtype Priority           is Any_Priority range  0 .. 97;
   110    subtype Interrupt_Priority is Any_Priority range 98 .. 98;
   111
   112    Default_Priority : constant Priority := 48;
```

## par-ch5.adb:1101–1127

```ada
  1101    --  (not an OPERATOR_SYMBOL)
  1102
  1103    --  The caller has already checked that the current token is <<
  1104
  1105    --  Error recovery: can raise Error_Resync
  1106
  1107    function P_Label return Node_Id is
  1108       Label_Node : Node_Id;
  1109
  1110    begin
  1111       Label_Node := New_Node (N_Label, Token_Ptr);
  1112       Scan; -- past <<
  1113       Set_Identifier (Label_Node, P_Identifier (C_Greater_Greater));
  1114       T_Greater_Greater;
  1115       Append_Elmt (Label_Node, Label_List);
  1116       return Label_Node;
  1117    end P_Label;
  1118
  1119    -------------------------------
  1120    -- 5.1  Statement Identifier --
  1121    -------------------------------
  1122
  1123    --  Statement label is parsed by P_Label (5.1)
  1124
  1125    --  Loop label is parsed by P_Loop_Statement (5.5), P_For_Statement (5.5)
  1126    --   or P_While_Statement (5.5)
  1127
```

## par-labl.adb:496–525

```ada
   496       --  If we didn't find a parent, then the label in question never got
   497       --  hooked into a reasonable declarative part. This happens only in
   498       --  error situations, and we simply ignore the entry (we aren't going
   499       --  to get into the semantics in any case given the error).
   500
   501       if Present (Enclosing_Body_Or_Block) then
   502          Check_Distinct_Labels;
   503
   504          --  Now create the implicit label declaration node and its
   505          --  corresponding defining identifier. Note that the defining
   506          --  occurrence of a label is the implicit label declaration that
   507          --  we are creating. The label itself is an applied occurrence.
   508
   509          Label_Decl_Node :=
   510            New_Node (N_Implicit_Label_Declaration, Sloc (Label_Node));
   511          Defining_Ident_Node :=
   512            New_Entity (N_Defining_Identifier, Sloc (Identifier (Label_Node)));
   513          Set_Chars (Defining_Ident_Node, Chars (Identifier (Label_Node)));
   514          Set_Defining_Identifier (Label_Decl_Node, Defining_Ident_Node);
   515          Set_Label_Construct (Label_Decl_Node, Label_Node);
   516
   517          --  The following makes sure that Comes_From_Source is appropriately
   518          --  set for the entity, depending on whether the label appeared in
   519          --  the source explicitly or not.
   520
   521          Set_Comes_From_Source
   522           (Defining_Ident_Node, Comes_From_Source (Identifier (Label_Node)));
   523
   524          --  Now attach the implicit label declaration to the appropriate
   525          --  declarative region, creating a declaration list if none exists
```

## sem_ch3.adb:852–895

```ada
   852       end if;
   853
   854       Anon_Type :=
   855         Create_Itype
   856           (E_Anonymous_Access_Type, Related_Nod, Scope_Id => Anon_Scope);
   857
   858       if All_Present (N)
   859         and then Ada_Version >= Ada_2005
   860       then
   861          Error_Msg_N ("ALL not permitted for anonymous access types", N);
   862       end if;
   863
   864       --  Ada 2005 (AI-254): In case of anonymous access to subprograms call
   865       --  the corresponding semantic routine
   866
   867       if Present (Access_To_Subprogram_Definition (N)) then
   868          Access_Subprogram_Declaration
   869            (T_Name => Anon_Type,
   870             T_Def  => Access_To_Subprogram_Definition (N));
   871
   872          if Ekind (Anon_Type) = E_Access_Protected_Subprogram_Type then
   873             Mutate_Ekind
   874               (Anon_Type, E_Anonymous_Access_Protected_Subprogram_Type);
   875          else
   876             Mutate_Ekind (Anon_Type, E_Anonymous_Access_Subprogram_Type);
   877          end if;
   878
   879          --  If the anonymous access is associated with a protected operation,
   880          --  create a reference to it after the enclosing protected definition
   881          --  because the itype will be used in the subsequent bodies.
   882
   883          --  If the anonymous access itself is protected, a full type
   884          --  declaratiton will be created for it, so that the equivalent
   885          --  record type can be constructed. For further details, see
   886          --  Replace_Anonymous_Access_To_Protected-Subprogram.
   887
   888          if Ekind (Current_Scope) = E_Protected_Type
   889            and then not Protected_Present (Access_To_Subprogram_Definition (N))
   890          then
   891             Build_Itype_Reference (Anon_Type, Parent (Current_Scope));
   892          end if;
   893
   894          return Anon_Type;
   895       end if;
```

## sem_ch3.adb:968–1017

```ada
   968             Build_Master_Entity (Defining_Identifier (Related_Nod));
   969             Build_Master_Renaming (Anon_Type);
   970          end if;
   971       end if;
   972
   973       --  For a private component of a protected type, it is imperative that
   974       --  the back-end elaborate the type immediately after the protected
   975       --  declaration, because this type will be used in the declarations
   976       --  created for the component within each protected body, so we must
   977       --  create an itype reference for it now.
   978
   979       if Nkind (Parent (Related_Nod)) = N_Protected_Definition then
   980          Build_Itype_Reference (Anon_Type, Parent (Parent (Related_Nod)));
   981
   982       --  Similarly, if the access definition is the return result of a
   983       --  function, create an itype reference for it because it will be used
   984       --  within the function body. For a regular function that is not a
   985       --  compilation unit, insert reference after the declaration. For a
   986       --  protected operation, insert it after the enclosing protected type
   987       --  declaration. In either case, do not create a reference for a type
   988       --  obtained through a limited_with clause, because this would introduce
   989       --  semantic dependencies.
   990
   991       --  Similarly, do not create a reference if the designated type is a
   992       --  generic formal, because no use of it will reach the backend.
   993
   994       elsif Nkind (Related_Nod) = N_Function_Specification
   995         and then not From_Limited_With (Desig_Type)
   996         and then not Is_Generic_Type (Desig_Type)
   997       then
   998          if Present (Enclosing_Prot_Type) then
   999             Build_Itype_Reference (Anon_Type, Parent (Enclosing_Prot_Type));
  1000
  1001          elsif Is_List_Member (Parent (Related_Nod))
  1002            and then Nkind (Parent (N)) /= N_Parameter_Specification
  1003          then
  1004             Build_Itype_Reference (Anon_Type, Parent (Related_Nod));
  1005          end if;
  1006
  1007       --  Finally, create an itype reference for an object declaration of an
  1008       --  anonymous access type. This is strictly necessary only for deferred
  1009       --  constants, but in any case will avoid out-of-scope problems in the
  1010       --  back-end.
  1011
  1012       elsif Nkind (Related_Nod) = N_Object_Declaration then
  1013          Build_Itype_Reference (Anon_Type, Related_Nod);
  1014       end if;
  1015
  1016       return Anon_Type;
  1017    end Access_Definition;
```

## sem_ch3.adb:8617–8642

```ada
  8617
  8618                --  If the derived type has access discriminants, create
  8619                --  references to their anonymous types now, to prevent
  8620                --  back-end problems when their first use is in generated
  8621                --  bodies of primitives.
  8622
  8623                declare
  8624                   E : Entity_Id;
  8625
  8626                begin
  8627                   E := First_Entity (Full_Der);
  8628
  8629                   while Present (E) loop
  8630                      if Ekind (E) = E_Discriminant
  8631                        and then Ekind (Etype (E)) = E_Anonymous_Access_Type
  8632                      then
  8633                         Build_Itype_Reference (Etype (E), Decl);
  8634                      end if;
  8635
  8636                      Next_Entity (E);
  8637                   end loop;
  8638                end;
  8639
  8640                --  Set up links between real entity and underlying record view
  8641
  8642                Set_Underlying_Record_View (Derived_Type, Base_Type (Full_Der));
```

## sem_ch3.adb:11262–11294

```ada
 11262    -- Build_Itype_Reference --
 11263    ---------------------------
 11264
 11265    procedure Build_Itype_Reference
 11266      (Ityp : Entity_Id;
 11267       Nod  : Node_Id)
 11268    is
 11269       IR : constant Node_Id := Make_Itype_Reference (Sloc (Nod));
 11270    begin
 11271       --  Itype references are only created for use by the back-end
 11272
 11273       if Inside_A_Generic then
 11274          return;
 11275       else
 11276          Set_Itype (IR, Ityp);
 11277
 11278          --  If Nod is a library unit entity, then Insert_After won't work,
 11279          --  because Nod is not a member of any list. Therefore, we use
 11280          --  Add_Global_Declaration in this case. This can happen if we have a
 11281          --  build-in-place library function, child unit or not.
 11282
 11283          if (Nkind (Nod) in N_Entity and then Is_Compilation_Unit (Nod))
 11284            or else (Nkind (Nod) in
 11285                       N_Defining_Program_Unit_Name | N_Subprogram_Declaration
 11286                      and then Is_Compilation_Unit (Defining_Entity (Nod)))
 11287          then
 11288             Add_Global_Declaration (IR);
 11289          else
 11290             Insert_After (Nod, IR);
 11291          end if;
 11292       end if;
 11293    end Build_Itype_Reference;
 11294
```

## sem_ch3.adb:14882–14921

```ada
 14882    --  For concurrent types, the associated record value type carries the same
 14883    --  discriminants, so when we constrain a concurrent type, we must constrain
 14884    --  the corresponding record type as well.
 14885
 14886    procedure Constrain_Concurrent
 14887      (Def_Id      : in out Entity_Id;
 14888       SI          : Node_Id;
 14889       Related_Nod : Node_Id;
 14890       Related_Id  : Entity_Id;
 14891       Suffix      : Character)
 14892    is
 14893       --  Retrieve Base_Type to ensure getting to the concurrent type in the
 14894       --  case of a private subtype (needed when only doing semantic analysis).
 14895
 14896       T_Ent : Entity_Id := Base_Type (Entity (Subtype_Mark (SI)));
 14897       T_Val : Entity_Id;
 14898
 14899    begin
 14900       if Is_Access_Type (T_Ent) then
 14901          T_Ent := Designated_Type (T_Ent);
 14902       end if;
 14903
 14904       T_Val := Corresponding_Record_Type (T_Ent);
 14905
 14906       if Present (T_Val) then
 14907
 14908          if No (Def_Id) then
 14909             Def_Id := Create_Itype (E_Void, Related_Nod, Related_Id, Suffix);
 14910
 14911             --  Elaborate itype now, as it may be used in a subsequent
 14912             --  synchronized operation in another scope.
 14913
 14914             if Nkind (Related_Nod) = N_Full_Type_Declaration then
 14915                Build_Itype_Reference (Def_Id, Related_Nod);
 14916             end if;
 14917          end if;
 14918
 14919          Constrain_Discriminated_Type (Def_Id, SI, Related_Nod);
 14920          Set_First_Private_Entity (Def_Id, First_Private_Entity (T_Ent));
 14921
```

## sem_ch3.adb:16595–16640

```ada
 16595
 16596                if Base_Type (Desig_Typ) = Base_Type (Parent_Type)
 16597
 16598                   --  Ada 2005 (AI-251): Handle also derivations of abstract
 16599                   --  interface primitives.
 16600
 16601                  or else (Is_Interface (Desig_Typ)
 16602                            and then not Is_Class_Wide_Type (Desig_Typ))
 16603                then
 16604                   Acc_Type := New_Copy (Id_Type);
 16605                   Set_Etype (Acc_Type, Acc_Type);
 16606                   Set_Scope (Acc_Type, New_Subp);
 16607
 16608                   --  Set size of anonymous access type. If we have an access
 16609                   --  to an unconstrained array, this is a fat pointer, so it
 16610                   --  is sizes at twice addtress size.
 16611
 16612                   if Is_Array_Type (Desig_Typ)
 16613                     and then not Is_Constrained (Desig_Typ)
 16614                   then
 16615                      Init_Size (Acc_Type, 2 * System_Address_Size);
 16616
 16617                   --  Other cases use a thin pointer
 16618
 16619                   else
 16620                      Init_Size (Acc_Type, System_Address_Size);
 16621                   end if;
 16622
 16623                   --  Set remaining characterstics of anonymous access type
 16624
 16625                   Reinit_Alignment (Acc_Type);
 16626                   Set_Directly_Designated_Type (Acc_Type, Derived_Type);
 16627
 16628                   Set_Etype (New_Id, Acc_Type);
 16629                   Set_Scope (New_Id, New_Subp);
 16630
 16631                   --  Create a reference to it
 16632
 16633                   Build_Itype_Reference (Acc_Type, Parent (Derived_Type));
 16634
 16635                else
 16636                   Set_Etype (New_Id, Id_Type);
 16637                end if;
 16638             end;
 16639
 16640          --  In Ada2012, a formal may have an incomplete type but the type
```

## sem_ch3.adb:23073–23113

```ada
 23073          case Ekind (Base_Type (Subtype_Mark_Id)) is
 23074             when Access_Kind =>
 23075
 23076                --  If this is a constraint on a class-wide type, discard it.
 23077                --  There is currently no way to express a partial discriminant
 23078                --  constraint on a type with unknown discriminants. This is
 23079                --  a pathology that the ACATS wisely decides not to test.
 23080
 23081                if Is_Class_Wide_Type (Designated_Type (Subtype_Mark_Id)) then
 23082                   if Comes_From_Source (S) then
 23083                      Error_Msg_N
 23084                        ("constraint on class-wide type ignored??",
 23085                         Constraint (S));
 23086                   else
 23087                      pragma Assert (False);
 23088                   end if;
 23089
 23090                   if Nkind (P) = N_Subtype_Declaration then
 23091                      Set_Subtype_Indication (P,
 23092                         New_Occurrence_Of (Subtype_Mark_Id, Sloc (S)));
 23093                   end if;
 23094
 23095                   return Subtype_Mark_Id;
 23096                end if;
 23097
 23098                Constrain_Access (Def_Id, S, Related_Nod);
 23099
 23100                if Expander_Active
 23101                  and then Is_Itype (Designated_Type (Def_Id))
 23102                  and then Nkind (Related_Nod) = N_Subtype_Declaration
 23103                  and then not Is_Incomplete_Type (Designated_Type (Def_Id))
 23104                then
 23105                   Build_Itype_Reference
 23106                     (Designated_Type (Def_Id), Related_Nod);
 23107                end if;
 23108
 23109             when Array_Kind =>
 23110                Constrain_Array (Def_Id, S, Related_Nod, Related_Id, Suffix);
 23111
 23112             when Decimal_Fixed_Point_Kind =>
 23113                Constrain_Decimal (Def_Id, S);
```

## sem_ch3.adb:23168–23204

```ada
 23168                end if;
 23169
 23170                --  If the full view is that of a task with discriminants,
 23171                --  we must constrain both the concurrent type and its
 23172                --  corresponding record type. Otherwise we will just propagate
 23173                --  the constraint to the full view, if available.
 23174
 23175                if Present (Full_View (Subtype_Mark_Id))
 23176                  and then Has_Discriminants (Subtype_Mark_Id)
 23177                  and then Is_Concurrent_Type (Full_View (Subtype_Mark_Id))
 23178                then
 23179                   Full_View_Id :=
 23180                     Create_Itype (E_Void, Related_Nod, Related_Id, Suffix);
 23181
 23182                   Set_Entity (Subtype_Mark (S), Full_View (Subtype_Mark_Id));
 23183                   Constrain_Concurrent (Full_View_Id, S,
 23184                     Related_Nod, Related_Id, Suffix);
 23185                   Set_Entity (Subtype_Mark (S), Subtype_Mark_Id);
 23186                   Set_Full_View (Def_Id, Full_View_Id);
 23187
 23188                   --  Introduce an explicit reference to the private subtype,
 23189                   --  to prevent scope anomalies in gigi if first use appears
 23190                   --  in a nested context, e.g. a later function body.
 23191                   --  Should this be generated in other contexts than a full
 23192                   --  type declaration?
 23193
 23194                   if Is_Itype (Def_Id)
 23195                     and then
 23196                       Nkind (Parent (P)) = N_Full_Type_Declaration
 23197                   then
 23198                      Build_Itype_Reference (Def_Id, Parent (P));
 23199                   end if;
 23200
 23201                else
 23202                   Prepare_Private_Subtype_Completion (Def_Id, Related_Nod);
 23203                end if;
 23204
```

## sem_ch6.adb:2141–2177

```ada
  2141
  2142             if Is_Access_Type (Typ) and then Null_Exclusion_Present (N) then
  2143                Set_Etype  (Designator,
  2144                  Create_Null_Excluding_Itype
  2145                   (T           => Typ,
  2146                    Related_Nod => N,
  2147                    Scope_Id    => Scope (Current_Scope)));
  2148
  2149                --  The new subtype must be elaborated before use because
  2150                --  it is visible outside of the function. However its base
  2151                --  type may not be frozen yet, so the reference that will
  2152                --  force elaboration must be attached to the freezing of
  2153                --  the base type.
  2154
  2155                --  If the return specification appears on a proper body,
  2156                --  the subtype will have been created already on the spec.
  2157
  2158                if Is_Frozen (Typ) then
  2159                   if Nkind (Parent (N)) = N_Subprogram_Body
  2160                     and then Nkind (Parent (Parent (N))) = N_Subunit
  2161                   then
  2162                      null;
  2163                   else
  2164                      Build_Itype_Reference (Etype (Designator), Parent (N));
  2165                   end if;
  2166
  2167                else
  2168                   declare
  2169                      IR : constant Node_Id := Make_Itype_Reference (Sloc (N));
  2170                   begin
  2171                      Set_Itype (IR, Etype (Designator));
  2172                      Append_Freeze_Action (Typ, IR);
  2173                   end;
  2174                end if;
  2175
  2176             else
  2177                Set_Etype (Designator, Typ);
```

## sem_ch6.adb:9494–9540

```ada
  9494             --  returns Result_Subt.
  9495
  9496             Set_Directly_Designated_Type
  9497               (Formal_Typ, Incomplete_View_From_Limited_With (Result_Subt));
  9498             Set_Etype (Formal_Typ, Formal_Typ);
  9499             Set_Depends_On_Private
  9500               (Formal_Typ, Has_Private_Component (Formal_Typ));
  9501             Set_Is_Public (Formal_Typ, Is_Public (Scope (Formal_Typ)));
  9502             Set_Is_Access_Constant (Formal_Typ, False);
  9503
  9504             --  Ada 2005 (AI-50217): Propagate the attribute that indicates
  9505             --  the designated type comes from the limited view (for back-end
  9506             --  purposes).
  9507
  9508             Set_From_Limited_With
  9509               (Formal_Typ, From_Limited_With (Result_Subt));
  9510
  9511             Layout_Type (Formal_Typ);
  9512
  9513             --  Force the definition of the Itype in case of internal function
  9514             --  calls within the same or nested scope.
  9515
  9516             if Is_Subprogram_Or_Generic_Subprogram (E)
  9517               and then not Is_Compilation_Unit (E)
  9518             then
  9519                Subp_Decl := Parent (E);
  9520
  9521                --  The insertion point for an Itype reference should be after
  9522                --  the unit declaration node of the subprogram. An exception
  9523                --  to this are inherited operations from a parent type in which
  9524                --  case the derived type acts as their parent.
  9525
  9526                if Nkind (Subp_Decl) in N_Function_Specification
  9527                                      | N_Procedure_Specification
  9528                then
  9529                   Subp_Decl := Parent (Subp_Decl);
  9530                end if;
  9531
  9532                Build_Itype_Reference (Formal_Typ, Subp_Decl);
  9533             end if;
  9534
  9535             Discard :=
  9536               Add_Extra_Formal
  9537                 (E, Formal_Typ, E, BIP_Formal_Suffix (BIP_Object_Access));
  9538          end;
  9539       end if;
  9540
```

## sem_ch7.adb:2097–2137

```ada
  2097    end Analyze_Private_Type_Declaration;
  2098
  2099    ----------------------------------
  2100    -- Check_Anonymous_Access_Types --
  2101    ----------------------------------
  2102
  2103    procedure Check_Anonymous_Access_Types
  2104      (Spec_Id : Entity_Id;
  2105       P_Body  : Node_Id)
  2106    is
  2107       E  : Entity_Id;
  2108       IR : Node_Id;
  2109
  2110    begin
  2111       --  Itype references are only needed by gigi, to force elaboration of
  2112       --  itypes. In the absence of code generation, they are not needed.
  2113
  2114       if not Expander_Active then
  2115          return;
  2116       end if;
  2117
  2118       E := First_Entity (Spec_Id);
  2119       while Present (E) loop
  2120          if Ekind (E) = E_Anonymous_Access_Type
  2121            and then From_Limited_With (E)
  2122          then
  2123             IR := Make_Itype_Reference (Sloc (P_Body));
  2124             Set_Itype (IR, E);
  2125
  2126             if No (Declarations (P_Body)) then
  2127                Set_Declarations (P_Body, New_List (IR));
  2128             else
  2129                Prepend (IR, Declarations (P_Body));
  2130             end if;
  2131          end if;
  2132
  2133          Next_Entity (E);
  2134       end loop;
  2135    end Check_Anonymous_Access_Types;
  2136
  2137    -------------------------------------------
```

## sem_res.adb:13180–13200

```ada
 13180       Set_Etype (N, Slice_Subtype);
 13181
 13182       --  For bit-packed slice subtypes, freeze immediately (except in the case
 13183       --  of being in a "spec expression" where we never freeze when we first
 13184       --  see the expression).
 13185
 13186       if Is_Bit_Packed_Array (Slice_Subtype) and not In_Spec_Expression then
 13187          Freeze_Itype (Slice_Subtype, N);
 13188
 13189       --  For all other cases insert an itype reference in the slice's actions
 13190       --  so that the itype is frozen at the proper place in the tree (i.e. at
 13191       --  the point where actions for the slice are analyzed). Note that this
 13192       --  is different from freezing the itype immediately, which might be
 13193       --  premature (e.g. if the slice is within a transient scope). This needs
 13194       --  to be done only if expansion is enabled.
 13195
 13196       elsif Expander_Active then
 13197          Ensure_Defined (Typ => Slice_Subtype, N => N);
 13198       end if;
 13199    end Set_Slice_Subtype;
 13200
```
