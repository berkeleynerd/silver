# Frozen frontend source excerpts
GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. LF line numbering; full files hash-verified against the retained complete source manifest.

## checks.adb:3509–3538

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
```

## checks.adb:11491–11508

```ada
 11491    procedure Validity_Check_Range
 11492      (N          : Node_Id;
 11493       Related_Id : Entity_Id := Empty) is
 11494    begin
 11495       if Validity_Checks_On and Validity_Check_Operands then
 11496          if Nkind (N) = N_Range then
 11497             Ensure_Valid
 11498               (Expr          => Low_Bound (N),
 11499                Related_Id    => Related_Id,
 11500                Is_Low_Bound  => True);
 11501
 11502             Ensure_Valid
 11503               (Expr          => High_Bound (N),
 11504                Related_Id    => Related_Id,
 11505                Is_High_Bound => True);
 11506          end if;
 11507       end if;
 11508    end Validity_Check_Range;
```

## exp_ch4.adb:10162–10258

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

## exp_spark.adb:772–881

```ada
   772    procedure Expand_SPARK_N_Attribute_Reference (N : Node_Id) is
   773       Aname   : constant Name_Id      := Attribute_Name (N);
   774       Attr_Id : constant Attribute_Id := Get_Attribute_Id (Aname);
   775       Loc     : constant Source_Ptr   := Sloc (N);
   776       Pref    : constant Node_Id      := Prefix (N);
   777       Typ     : constant Entity_Id    := Etype (N);
   778       Expr    : Node_Id;
   779
   780    begin
   781       case Attr_Id is
   782          when Attribute_To_Address =>
   783
   784             --  Extract and convert argument to expected type for call
   785
   786             Expr :=
   787               Make_Type_Conversion (Loc,
   788                 Subtype_Mark =>
   789                   New_Occurrence_Of (RTE (RE_Integer_Address), Loc),
   790                 Expression   => Relocate_Node (First (Expressions (N))));
   791
   792             --  Replace attribute reference with call
   793
   794             Rewrite
   795               (N,
   796                Make_Function_Call (Loc,
   797                  Name                   =>
   798                    New_Occurrence_Of (RTE (RE_To_Address), Loc),
   799                  Parameter_Associations => New_List (Expr)));
   800             Analyze_And_Resolve (N, Typ);
   801
   802          when Attribute_Object_Size
   803             | Attribute_Size
   804             | Attribute_Value_Size
   805             | Attribute_VADS_Size
   806          =>
   807             Exp_Attr.Expand_Size_Attribute (N);
   808
   809          --  For attributes which return Universal_Integer, introduce a
   810          --  conversion to the expected type with the appropriate check flags
   811          --  set.
   812
   813          when Attribute_Aft
   814             | Attribute_Alignment
   815             | Attribute_Bit
   816             | Attribute_Bit_Position
   817             | Attribute_Descriptor_Size
   818             | Attribute_First_Bit
   819             | Attribute_Last_Bit
   820             | Attribute_Length
   821             | Attribute_Max_Alignment_For_Allocation
   822             | Attribute_Max_Size_In_Storage_Elements
   823             | Attribute_Pos
   824             | Attribute_Position
   825             | Attribute_Range_Length
   826          =>
   827             --  If the expected type is Long_Long_Integer, there will be no
   828             --  check flag as the compiler assumes attributes always fit in
   829             --  this type. Since in SPARK_Mode we do not take Storage_Error
   830             --  into account, we cannot make this assumption and need to
   831             --  produce a check. ??? It should be enough to add this check for
   832             --  attributes 'Length, 'Range_Length and 'Pos when the type is as
   833             --  big as Long_Long_Integer.
   834
   835             declare
   836                Typ : Entity_Id;
   837             begin
   838                if Attr_Id in Attribute_Pos | Attribute_Range_Length then
   839                   Typ := Etype (Prefix (N));
   840
   841                elsif Attr_Id = Attribute_Length then
   842                   Typ := Get_Index_Subtype (N);
   843
   844                else
   845                   Typ := Empty;
   846                end if;
   847
   848                Apply_Universal_Integer_Attribute_Checks (N);
   849
   850                if Present (Typ)
   851                  and then Known_RM_Size (Typ)
   852                  and then RM_Size (Typ) = RM_Size (Standard_Long_Long_Integer)
   853                then
   854                   --  ??? This should rather be a range check, but this would
   855                   --  crash GNATprove which somehow recovers the proper kind
   856                   --  of check anyway.
   857                   Set_Do_Overflow_Check (N);
   858                end if;
   859             end;
   860
   861          when Attribute_Constrained =>
   862
   863             --  If the prefix is an access to object, the attribute applies to
   864             --  the designated object, so rewrite with an explicit dereference.
   865
   866             if Is_Access_Type (Etype (Pref))
   867               and then
   868               (not Is_Entity_Name (Pref) or else Is_Object (Entity (Pref)))
   869             then
   870                Rewrite (Pref,
   871                         Make_Explicit_Dereference (Loc, Relocate_Node (Pref)));
   872                Analyze_And_Resolve (N, Standard_Boolean);
   873             end if;
   874
   875          when Attribute_Update =>
   876             Expand_SPARK_Delta_Or_Update (Typ, First (Expressions (N)));
   877
   878          when others =>
   879             null;
   880       end case;
   881    end Expand_SPARK_N_Attribute_Reference;
```

## exp_spark.adb:896–946

```ada
   896    procedure Expand_SPARK_N_Loop_Statement (N : Node_Id) is
   897       Scheme : constant Node_Id := Iteration_Scheme (N);
   898
   899    begin
   900       --  Loop iterations over arrays need to be expanded, to avoid getting
   901       --  two names referring to the same object in memory (the array and the
   902       --  iterator) in GNATprove, especially since both can be written (thus
   903       --  possibly leading to interferences due to aliasing). No such problem
   904       --  arises with quantified expressions over arrays, which are dealt with
   905       --  specially in GNATprove.
   906
   907       if Present (Scheme)
   908         and then Present (Iterator_Specification (Scheme))
   909         and then Is_Iterator_Over_Array (Iterator_Specification (Scheme))
   910       then
   911          Expand_Iterator_Loop_Over_Array (N);
   912       end if;
   913    end Expand_SPARK_N_Loop_Statement;
   914
   915    ---------------------------------------
   916    -- Expand_SPARK_N_Object_Declaration --
   917    ---------------------------------------
   918
   919    procedure Expand_SPARK_N_Object_Declaration (N : Node_Id) is
   920       Loc    : constant Source_Ptr := Sloc (N);
   921       Obj_Id : constant Entity_Id  := Defining_Identifier (N);
   922       Typ    : constant Entity_Id  := Etype (Obj_Id);
   923
   924       Call : Node_Id;
   925
   926    begin
   927       --  If the object declaration denotes a variable without initialization
   928       --  whose type is subject to pragma Default_Initial_Condition, create
   929       --  and analyze a dummy call to the DIC procedure of the type in order
   930       --  to detect potential elaboration issues.
   931
   932       if Comes_From_Source (Obj_Id)
   933         and then Ekind (Obj_Id) = E_Variable
   934         and then Has_DIC (Typ)
   935         and then Present (DIC_Procedure (Typ))
   936         and then not Has_Init_Expression (N)
   937       then
   938          Call := Build_DIC_Call (Loc, New_Occurrence_Of (Obj_Id, Loc), Typ);
   939
   940          --  Partially insert the call into the tree by setting its parent
   941          --  pointer.
   942
   943          Set_Parent (Call, N);
   944          Analyze (Call);
   945       end if;
   946    end Expand_SPARK_N_Object_Declaration;
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

## exp_spark.adb:1073–1106

```ada
  1073       if Present (Obj_Id)
  1074         and then Is_Object (Obj_Id)
  1075       then
  1076          Ren := Renamed_Object (Obj_Id);
  1077
  1078          if Present (Ren) then
  1079
  1080             --  Do not process a reference when it appears within a pragma of
  1081             --  no significance to SPARK. It is assumed that the replacement
  1082             --  will violate the semantics of the pragma and cause a spurious
  1083             --  error.
  1084
  1085             if In_Insignificant_Pragma (N) then
  1086                return;
  1087
  1088             --  Instantiations and inlining of subprograms employ "prologues"
  1089             --  which map actual to formal parameters by means of renamings.
  1090             --  Replace a reference to a formal by the corresponding actual
  1091             --  parameter.
  1092
  1093             elsif Nkind (Ren) in N_Entity then
  1094                Rewrite (N, New_Occurrence_Of (Ren, Loc));
  1095
  1096             --  Otherwise the renamed object denotes a name
  1097
  1098             else
  1099                Rewrite (N, New_Copy_Tree (Ren, New_Sloc => Loc));
  1100                Reset_Analyzed_Flags (N);
  1101             end if;
  1102
  1103             Analyze_And_Resolve (N, Typ);
  1104          end if;
  1105       end if;
  1106    end Expand_SPARK_Potential_Renaming;
```

## exp_spark.adb:1138–1254

```ada
  1138
  1139       --  Generate the [spec and] body of the invariant procedure tasked with
  1140       --  the runtime verification of all invariants that pertain to the type.
  1141       --  This includes invariants on the partial and full view, inherited
  1142       --  class-wide invariants from parent types or interfaces, and invariants
  1143       --  on array elements or record components. But skip internal types.
  1144
  1145       if Is_Itype (Typ) then
  1146          null;
  1147
  1148       elsif Is_Interface (Typ) then
  1149
  1150          --  Interfaces are treated as the partial view of a private type in
  1151          --  order to achieve uniformity with the general case. As a result, an
  1152          --  interface receives only a "partial" invariant procedure which is
  1153          --  never called.
  1154
  1155          if Has_Own_Invariants (Typ) then
  1156             Build_Invariant_Procedure_Body
  1157               (Typ               => Typ,
  1158                Partial_Invariant => Is_Interface (Typ));
  1159          end if;
  1160
  1161       --  Non-interface types
  1162
  1163       --  Do not generate invariant procedure within other assertion
  1164       --  subprograms, which may involve local declarations of local
  1165       --  subtypes to which these checks do not apply.
  1166
  1167       else
  1168          if Has_Invariants (Typ) then
  1169             if not Predicate_Check_In_Scope (Typ)
  1170               or else (Ekind (Current_Scope) = E_Function
  1171                         and then Is_Predicate_Function (Current_Scope))
  1172             then
  1173                null;
  1174             else
  1175                Build_Invariant_Procedure_Body (Typ);
  1176             end if;
  1177          end if;
  1178
  1179          --  Generate the [spec and] body of the procedure tasked with the
  1180          --  run-time verification of pragma Default_Initial_Condition's
  1181          --  expression.
  1182
  1183          if Has_DIC (Typ) then
  1184             Build_DIC_Procedure_Body (Typ);
  1185          end if;
  1186       end if;
  1187
  1188       if Ekind (Typ) = E_Record_Type
  1189         and then Is_Tagged_Type (Typ)
  1190         and then not Is_Interface (Typ)
  1191         and then not Is_Limited_Type (Typ)
  1192       then
  1193          if Is_CPP_Class (Root_Type (Typ))
  1194            and then Convention (Typ) = Convention_CPP
  1195          then
  1196             null;
  1197
  1198          --  Do not add the spec of the predefined primitives if we are
  1199          --  compiling under restriction No_Dispatching_Calls.
  1200
  1201          elsif not Restriction_Active (No_Dispatching_Calls) then
  1202             Set_Is_Frozen (Typ, False);
  1203
  1204             Predef_List := New_List;
  1205             Exp_Ch3.Make_Predefined_Primitive_Eq_Spec
  1206               (Typ, Predef_List, Renamed_Eq);
  1207             Eq_Spec := First (Predef_List);
  1208             Insert_List_Before_And_Analyze (N, Predef_List);
  1209
  1210             Set_Is_Frozen (Typ);
  1211
  1212             --  Remove link from the parent list to the spec and body of
  1213             --  the dispatching equality, but keep the link in the opposite
  1214             --  direction, to allow up-traversal of the AST.
  1215
  1216             if Present (Eq_Spec) then
  1217                Decl := Parent (Eq_Spec);
  1218                Remove (Eq_Spec);
  1219                Set_Parent (Eq_Spec, Decl);
  1220             end if;
  1221          end if;
  1222       end if;
  1223
  1224       if Ekind (Typ) = E_Record_Type
  1225         and then Is_Tagged_Type (Typ)
  1226         and then not Is_CPP_Class (Typ)
  1227       then
  1228          --  Ada 2005 (AI-391): For a nonabstract null extension, create
  1229          --  wrapper functions for each nonoverridden inherited function
  1230          --  with a controlling result of the type. The wrapper for such
  1231          --  a function returns an extension aggregate that invokes the
  1232          --  parent function.
  1233
  1234          if Ada_Version >= Ada_2005
  1235            and then not Is_Abstract_Type (Typ)
  1236            and then Is_Null_Extension (Typ)
  1237          then
  1238             Exp_Ch3.Make_Controlling_Function_Wrappers
  1239               (Typ, Wrapper_Decl_List, Wrapper_Body_List);
  1240             Insert_List_Before_And_Analyze (N, Wrapper_Decl_List);
  1241          end if;
  1242
  1243          --  Ada 2005 (AI-391): If any wrappers were created for nonoverridden
  1244          --  inherited functions, then add their bodies to the AST, so they
  1245          --  will be processed like ordinary subprogram bodies (even though the
  1246          --  compiler adds them into the freezing action).
  1247
  1248          if not Is_Interface (Typ) then
  1249             Insert_List_Before_And_Analyze (N, Wrapper_Body_List);
  1250          end if;
  1251       end if;
  1252
  1253       Restore_Ghost_Region (Saved_Ghost_Config);
  1254    end SPARK_Freeze_Type;
```

## exp_util.adb:5864–6012

```ada
  5864    procedure Expand_Subtype_From_Expr
  5865      (N             : Node_Id;
  5866       Unc_Type      : Entity_Id;
  5867       Subtype_Indic : Node_Id;
  5868       Exp           : Node_Id;
  5869       Related_Id    : Entity_Id := Empty)
  5870    is
  5871       Loc     : constant Source_Ptr := Sloc (N);
  5872       Exp_Typ : constant Entity_Id  := Etype (Exp);
  5873       T       : Entity_Id;
  5874
  5875    begin
  5876       --  In general we cannot build the subtype if expansion is disabled,
  5877       --  because internal entities may not have been defined. However, to
  5878       --  avoid some cascaded errors, we try to continue when the expression is
  5879       --  an array (or string), because it is safe to compute the bounds. It is
  5880       --  in fact required to do so even in a generic context, because there
  5881       --  may be constants that depend on the bounds of a string literal, both
  5882       --  standard string types and more generally arrays of characters.
  5883
  5884       --  In GNATprove mode, these extra subtypes are not needed, unless Exp is
  5885       --  a static expression. In that case, the subtype will be constrained
  5886       --  while the original type might be unconstrained, so expanding the type
  5887       --  is necessary both for passing legality checks in GNAT and for precise
  5888       --  analysis in GNATprove.
  5889
  5890       if GNATprove_Mode and then not Is_Static_Expression (Exp) then
  5891          return;
  5892       end if;
  5893
  5894       if not Expander_Active
  5895         and then (No (Etype (Exp)) or else not Is_String_Type (Etype (Exp)))
  5896       then
  5897          return;
  5898       end if;
  5899
  5900       if Nkind (Exp) = N_Slice then
  5901          declare
  5902             Slice_Type : constant Entity_Id := Etype (First_Index (Exp_Typ));
  5903
  5904          begin
  5905             Rewrite (Subtype_Indic,
  5906               Make_Subtype_Indication (Loc,
  5907                 Subtype_Mark => New_Occurrence_Of (Unc_Type, Loc),
  5908                 Constraint =>
  5909                   Make_Index_Or_Discriminant_Constraint (Loc,
  5910                     Constraints => New_List
  5911                       (New_Occurrence_Of (Slice_Type, Loc)))));
  5912
  5913             --  This subtype indication may be used later for constraint checks
  5914             --  we better make sure that if a variable was used as a bound of
  5915             --  the original slice, its value is frozen.
  5916
  5917             Evaluate_Slice_Bounds (Exp);
  5918          end;
  5919
  5920       elsif Ekind (Exp_Typ) = E_String_Literal_Subtype then
  5921          Rewrite (Subtype_Indic,
  5922            Make_Subtype_Indication (Loc,
  5923              Subtype_Mark => New_Occurrence_Of (Unc_Type, Loc),
  5924              Constraint =>
  5925                Make_Index_Or_Discriminant_Constraint (Loc,
  5926                  Constraints => New_List (
  5927                    Make_Literal_Range (Loc,
  5928                      Literal_Typ => Exp_Typ)))));
  5929
  5930       --  If the type of the expression is an internally generated type it
  5931       --  may not be necessary to create a new subtype. However there are two
  5932       --  exceptions: references to the current instances, and aliased array
  5933       --  object declarations for which the back end has to create a template.
  5934
  5935       elsif Is_Constrained (Exp_Typ)
  5936         and then not Is_Class_Wide_Type (Unc_Type)
  5937         and then
  5938           (Nkind (N) /= N_Object_Declaration
  5939             or else not Is_Entity_Name (Expression (N))
  5940             or else not Comes_From_Source (Entity (Expression (N)))
  5941             or else not Is_Array_Type (Exp_Typ)
  5942             or else not Aliased_Present (N))
  5943       then
  5944          if Is_Itype (Exp_Typ)
  5945
  5946            --  When this is for an object declaration, the caller may want to
  5947            --  set Is_Constr_Subt_For_U_Nominal on the subtype, so we must make
  5948            --  sure that either the subtype has been built for the expression,
  5949            --  typically for an aggregate, or the flag is already set on it;
  5950            --  otherwise it could end up being set on the nominal constrained
  5951            --  subtype of an object and thus later cause the failure to detect
  5952            --  non-statically-matching subtypes on 'Access of this object.
  5953
  5954            and then (Nkind (N) /= N_Object_Declaration
  5955                       or else Nkind (Original_Node (Exp)) = N_Aggregate
  5956                       or else Is_Constr_Subt_For_U_Nominal (Exp_Typ))
  5957          then
  5958             --  Within an initialization procedure, a selected component
  5959             --  denotes a component of the enclosing record, and it appears as
  5960             --  an actual in a call to its own initialization procedure. If
  5961             --  this component depends on the outer discriminant, we must
  5962             --  generate the proper actual subtype for it.
  5963
  5964             if Nkind (Exp) = N_Selected_Component
  5965               and then Within_Init_Proc
  5966             then
  5967                declare
  5968                   Decl : constant Node_Id :=
  5969                            Build_Actual_Subtype_Of_Component (Exp_Typ, Exp);
  5970                begin
  5971                   if Present (Decl) then
  5972                      Insert_Action (N, Decl);
  5973                      T := Defining_Identifier (Decl);
  5974                   else
  5975                      T := Exp_Typ;
  5976                   end if;
  5977                end;
  5978
  5979             --  No need to generate a new subtype
  5980
  5981             else
  5982                T := Exp_Typ;
  5983             end if;
  5984
  5985          else
  5986             T := Make_Temporary (Loc, 'T');
  5987
  5988             Insert_Action (N,
  5989               Make_Subtype_Declaration (Loc,
  5990                 Defining_Identifier => T,
  5991                 Subtype_Indication  => New_Occurrence_Of (Exp_Typ, Loc)));
  5992
  5993             --  This type is marked as an itype even though it has an explicit
  5994             --  declaration since otherwise Is_Generic_Actual_Type can get
  5995             --  set, resulting in the generation of spurious errors. (See
  5996             --  sem_ch8.Analyze_Package_Renaming and Sem_Type.Covers.)
  5997
  5998             Set_Is_Itype (T);
  5999             Set_Associated_Node_For_Itype (T, Exp);
  6000          end if;
  6001
  6002          Rewrite (Subtype_Indic, New_Occurrence_Of (T, Loc));
  6003
  6004       --  Nothing needs to be done for private types with unknown discriminants
  6005       --  if the underlying type is not an unconstrained composite type or it
  6006       --  is an unchecked union.
  6007
  6008       elsif Is_Private_Type (Unc_Type)
  6009         and then Has_Unknown_Discriminants (Unc_Type)
  6010         and then (not Is_Composite_Type (Underlying_Type (Unc_Type))
  6011                    or else Is_Constrained (Underlying_Type (Unc_Type))
  6012                    or else Is_Unchecked_Union (Underlying_Type (Unc_Type)))
```

## exp_util.adb:7221–7243

```ada
  7221    procedure Force_Evaluation
  7222      (Exp           : Node_Id;
  7223       Name_Req      : Boolean   := False;
  7224       Related_Id    : Entity_Id := Empty;
  7225       Is_Low_Bound  : Boolean   := False;
  7226       Is_High_Bound : Boolean   := False;
  7227       Discr_Number  : Int       := 0;
  7228       Mode          : Force_Evaluation_Mode := Relaxed)
  7229    is
  7230    begin
  7231       Remove_Side_Effects
  7232         (Exp                => Exp,
  7233          Name_Req           => Name_Req,
  7234          Variable_Ref       => True,
  7235          Renaming_Req       => False,
  7236          Related_Id         => Related_Id,
  7237          Is_Low_Bound       => Is_Low_Bound,
  7238          Is_High_Bound      => Is_High_Bound,
  7239          Discr_Number       => Discr_Number,
  7240          Check_Side_Effects =>
  7241            Is_Static_Expression (Exp)
  7242              or else Mode = Relaxed);
  7243    end Force_Evaluation;
```

## exp_util.adb:12619–12723

```ada
 12619       begin
 12620          --  Side-effect removal in SPARK should only occur when not inside a
 12621          --  generic and not doing a preanalysis, inside an object renaming or
 12622          --  a type declaration or a for-loop iteration scheme.
 12623
 12624          if not Inside_A_Generic
 12625            and then Full_Analysis
 12626          then
 12627
 12628             case Nkind (Enclosing_Declaration (Exp)) is
 12629                when N_Component_Declaration
 12630                   | N_Full_Type_Declaration
 12631                   | N_Iterator_Specification
 12632                   | N_Loop_Parameter_Specification
 12633                   | N_Object_Renaming_Declaration
 12634                =>
 12635                   return True;
 12636
 12637                --  If the expression belongs to an itype declaration, then
 12638                --  check if side effects are allowed in the original
 12639                --  associated node.
 12640
 12641                when N_Subtype_Declaration =>
 12642                   declare
 12643                      Subt : constant Entity_Id :=
 12644                        Defining_Identifier (Enclosing_Declaration (Exp));
 12645                   begin
 12646                      if Is_Itype (Subt) then
 12647
 12648                         --  When this routine is called while the itype
 12649                         --  is being created, the entity might not yet be
 12650                         --  decorated with the associated node, but will
 12651                         --  have the related expression.
 12652
 12653                         if Present (Associated_Node_For_Itype (Subt)) then
 12654                            return
 12655                              Possible_Side_Effect_In_SPARK
 12656                                (Associated_Node_For_Itype (Subt));
 12657
 12658                         else
 12659                            return
 12660                              Possible_Side_Effect_In_SPARK
 12661                                (Related_Expression (Subt));
 12662                         end if;
 12663                      else
 12664                         return True;
 12665                      end if;
 12666                   end;
 12667
 12668                when others =>
 12669                   return False;
 12670             end case;
 12671          else
 12672             return False;
 12673          end if;
 12674       end Possible_Side_Effect_In_SPARK;
 12675
 12676       --  Local variables
 12677
 12678       Loc          : constant Source_Ptr      := Sloc (Exp);
 12679       Svg_Suppress : constant Suppress_Record := Scope_Suppress;
 12680       Typ          : constant Entity_Id       := Etype (Exp);
 12681       Und_Typ      : constant Entity_Id       :=
 12682         (if Present (Typ) then Underlying_Type (Typ) else Typ);
 12683       --  The underlying type that drives part of the processing
 12684
 12685       Def_Id       : Entity_Id;
 12686       E            : Node_Id;
 12687       New_Exp      : Node_Id;
 12688       Ptr_Typ_Decl : Node_Id;
 12689       Ref_Type     : Entity_Id;
 12690       Res          : Node_Id;
 12691
 12692    --  Start of processing for Remove_Side_Effects
 12693
 12694    begin
 12695       --  Handle cases in which there is nothing to do. In GNATprove mode,
 12696       --  removal of side effects is useful for the light expansion of
 12697       --  renamings.
 12698
 12699       if not Expander_Active
 12700         and then not
 12701           (GNATprove_Mode and then Possible_Side_Effect_In_SPARK (Exp))
 12702       then
 12703          return;
 12704
 12705       --  Cannot generate temporaries if the invocation to remove side effects
 12706       --  was issued too early and the type of the expression is not resolved
 12707       --  (this happens because routines Duplicate_Subexpr_XX implicitly invoke
 12708       --  Remove_Side_Effects).
 12709
 12710       elsif No (Typ)
 12711         or else No (Und_Typ)
 12712         or else Ekind (Und_Typ) = E_Access_Attribute_Type
 12713       then
 12714          return;
 12715
 12716       --  No action needed for side-effect-free expressions
 12717
 12718       elsif Check_Side_Effects
 12719         and then Side_Effect_Free (Exp, Name_Req, Variable_Ref)
 12720       then
 12721          return;
 12722       end if;
 12723
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

## exp_util.adb:13102–13116

```ada
 13102
 13103       Set_Assignment_OK (Res, Assignment_OK (Exp));
 13104
 13105       --  Preserve the Do_Range_Check flag in all copies
 13106
 13107       Set_Do_Range_Check (Res, Do_Range_Check (Exp));
 13108
 13109       --  Finally rewrite the original expression and we are done
 13110
 13111       Rewrite (Exp, Res);
 13112       Analyze_And_Resolve (Exp, Typ);
 13113
 13114    <<Leave>>
 13115       Scope_Suppress := Svg_Suppress;
 13116    end Remove_Side_Effects;
```

## exp_util.adb:14429–14457

```ada
 14429
 14430          --  A type reference is always side-effect-free
 14431
 14432          if Is_Type (Entity (N)) then
 14433             return True;
 14434
 14435          --  Variables are considered to be a side effect if Variable_Ref
 14436          --  is set or if we have a volatile reference and Name_Req is off.
 14437          --  If Name_Req is True then we can't help returning a name which
 14438          --  effectively allows multiple references in any case.
 14439
 14440          elsif Is_Variable (N, Use_Original_Node => False) then
 14441             return not Variable_Ref
 14442               and then (not Is_Volatile_Reference (N) or else Name_Req);
 14443
 14444          --  Any other entity (e.g. a subtype name) is definitely side
 14445          --  effect free.
 14446
 14447          else
 14448             return True;
 14449          end if;
 14450
 14451       --  A value known at compile time is always side-effect-free
 14452
 14453       elsif Compile_Time_Known_Value (N) then
 14454          return True;
 14455
 14456       --  A variable renaming is not side-effect-free, because the renaming
 14457       --  will function like a macro in the front-end in some cases, and an
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

## gnat1drv.adb:511–516

```ada
   511          --  Disable validity checks, since it generates code raising
   512          --  exceptions for invalid data, which confuses GNATprove. Invalid
   513          --  data is directly detected by GNATprove's flow analysis.
   514
   515          Validity_Checks_On := False;
   516          Check_Validity_Of_Parameters := False;
```

## inline.adb:1950–1993

```ada
  1950    --  Start of processing for Can_Be_Inlined_In_GNATprove_Mode
  1951
  1952    begin
  1953       pragma Assert (Present (Spec_Id) or else Present (Body_Id));
  1954
  1955       if Present (Spec_Id) then
  1956          Id := Spec_Id;
  1957       else
  1958          Id := Body_Id;
  1959       end if;
  1960
  1961       --  Only local subprograms without contracts are inlined in GNATprove
  1962       --  mode, as these are the subprograms which a user is not interested in
  1963       --  analyzing in isolation, but rather in the context of their call. This
  1964       --  is a convenient convention, that could be changed for an explicit
  1965       --  pragma/aspect one day.
  1966
  1967       --  In a number of special cases, inlining is not desirable or not
  1968       --  possible, see below.
  1969
  1970       --  Do not inline unit-level subprograms
  1971
  1972       if Is_Unit_Subprogram (Id) then
  1973          return False;
  1974
  1975       --  Do not inline subprograms declared in package specs, because they are
  1976       --  not local, i.e. can be called either from anywhere (if declared in
  1977       --  visible part) or from the child units (if declared in private part).
  1978
  1979       elsif In_Package_Spec (Id) then
  1980          return False;
  1981
  1982       --  Do not inline subprograms declared in other units. This is important
  1983       --  in particular for subprograms defined in the private part of a
  1984       --  package spec, when analyzing one of its child packages, as otherwise
  1985       --  we issue spurious messages about the impossibility to inline such
  1986       --  calls.
  1987
  1988       elsif not In_Extended_Main_Code_Unit (Id) then
  1989          return False;
  1990
  1991       --  Do not inline dispatching operations, as only their static calls
  1992       --  can be analyzed in context, and not their dispatching calls.
  1993
```

## itypes.adb:45–85

```ada
    45    is
    46       Typ : Entity_Id;
    47
    48    begin
    49       --  Should comment setting of Public_Status here ???
    50
    51       if Related_Id = Empty then
    52          Typ := New_Internal_Entity (Ekind, Scope_Id, Sloc (Related_Nod), 'T');
    53          Set_Public_Status (Typ);
    54
    55       else
    56          Typ :=
    57            New_External_Entity
    58              (Ekind, Scope_Id, Sloc (Related_Nod), Related_Id, Suffix,
    59               Suffix_Index, 'T');
    60       end if;
    61
    62       --  Make sure Esize (Typ) was properly initialized, it should be since
    63       --  New_Internal_Entity/New_External_Entity call Reinit_Size_Align.
    64
    65       pragma Assert (not Known_Esize (Typ));
    66
    67       Set_Etype (Typ, Any_Type);
    68       Set_Is_Itype (Typ);
    69       Set_Associated_Node_For_Itype (Typ, Related_Nod);
    70
    71       if In_Deleted_Code then
    72          Set_Is_Frozen (Typ);
    73       end if;
    74
    75       if Ekind in Access_Subprogram_Kind then
    76          Set_Can_Use_Internal_Rep (Typ, not Always_Compatible_Rep_On_Target);
    77       end if;
    78
    79       return Typ;
    80    end Create_Itype;
    81
    82    ---------------------------------
    83    -- Create_Null_Excluding_Itype --
    84    ---------------------------------
    85
```

## par-ch4.adb:2561–2660

```ada
  2561             Num_Concats_Threshold : constant Positive := 1000;
  2562             --  Arbitrary threshold value to enable optimization
  2563
  2564             First_Node : constant Node_Id := Node1;
  2565             Is_Strlit_Concat : Boolean;
  2566             --  True iff we've parsed a sequence of concatenations of string
  2567             --  literals, with nothing else mixed in.
  2568
  2569             Num_Concats : Natural;
  2570             --  Number of "&" operators if Is_Strlit_Concat is True
  2571
  2572          begin
  2573             Is_Strlit_Concat :=
  2574               Nkind (Node1) = N_String_Literal
  2575                 and then Token = Tok_Ampersand;
  2576             Num_Concats := 0;
  2577
  2578             --  Scan out sequence of terms separated by binary adding operators
  2579
  2580             loop
  2581                exit when Token not in Token_Class_Binary_Addop;
  2582                Tokptr := Token_Ptr;
  2583                Node2 := New_Op_Node (P_Binary_Adding_Operator, Tokptr);
  2584
  2585                if Style_Check and then not Debug_Flag_Dot_QQ then
  2586                   Style.Check_Binary_Operator;
  2587                end if;
  2588
  2589                Scan; -- past operator
  2590                Set_Left_Opnd (Node2, Node1);
  2591                Node1 := P_Term;
  2592                Set_Right_Opnd (Node2, Node1);
  2593
  2594                --  Check if we're still concatenating string literals
  2595
  2596                Is_Strlit_Concat :=
  2597                  Is_Strlit_Concat
  2598                    and then Nkind (Node2) = N_Op_Concat
  2599                  and then Nkind (Node1) = N_String_Literal;
  2600
  2601                if Is_Strlit_Concat then
  2602                   Num_Concats := Num_Concats + 1;
  2603                end if;
  2604
  2605                Node1 := Node2;
  2606             end loop;
  2607
  2608             --  If we have an enormous series of concatenations of string
  2609             --  literals, rewrite as explained above. The Is_Folded_In_Parser
  2610             --  flag tells semantic analysis that if the "&" is not predefined,
  2611             --  the folded value is wrong.
  2612
  2613             if Is_Strlit_Concat
  2614               and then Num_Concats >= Num_Concats_Threshold
  2615             then
  2616                declare
  2617                   Strlit_Concat_Val : String_Id;
  2618                   --  Contains the folded value (which will be correct if the
  2619                   --  "&" operators are the predefined ones).
  2620
  2621                   Cur_Node : Node_Id;
  2622                   --  For walking up the tree
  2623
  2624                   New_Node : Node_Id;
  2625                   --  Folded node to replace Node1
  2626
  2627                   Loc : constant Source_Ptr := Sloc (First_Node);
  2628
  2629                begin
  2630                   --  Walk up the tree starting at the leftmost string literal
  2631                   --  (First_Node), building up the Strlit_Concat_Val as we
  2632                   --  go. Note that we do not use recursion here -- the whole
  2633                   --  point is to avoid recursively walking that enormous tree.
  2634
  2635                   Start_String;
  2636                   Store_String_Chars (Strval (First_Node));
  2637
  2638                   Cur_Node := Parent (First_Node);
  2639                   while Present (Cur_Node) loop
  2640                      pragma Assert (Nkind (Cur_Node) = N_Op_Concat and then
  2641                         Nkind (Right_Opnd (Cur_Node)) = N_String_Literal);
  2642
  2643                      Store_String_Chars (Strval (Right_Opnd (Cur_Node)));
  2644                      Cur_Node := Parent (Cur_Node);
  2645                   end loop;
  2646
  2647                   Strlit_Concat_Val := End_String;
  2648
  2649                   --  Create new folded node, and rewrite result with a concat-
  2650                   --  enation of an empty string literal and the folded node.
  2651
  2652                   New_Node :=
  2653                     Make_Op_Concat (Loc,
  2654                       Make_String_Literal (Loc, Null_String_Id),
  2655                       Make_String_Literal (Loc, Strlit_Concat_Val,
  2656                         Is_Folded_In_Parser => True));
  2657                   Rewrite (Node1, New_Node);
  2658                end;
  2659             end if;
  2660          end;
```

## sem_attr.adb:1571–1618

```ada
  1571       --  Start of processing for Analyze_Image_Attribute
  1572
  1573       begin
  1574          --  AI12-0124: The ARG has adopted the GNAT semantics of 'Img for
  1575          --  scalar types, so that the prefix can be an object, a named value,
  1576          --  or a type. If the prefix is an object, there is no argument.
  1577
  1578          if Is_Object_Prefix (P) then
  1579             Check_E0;
  1580             Set_Etype (N, Str_Typ);
  1581             Check_Image_Type (Etype (P));
  1582
  1583             if Attr_Id /= Attribute_Img then
  1584                Error_Msg_Ada_2012_Feature ("|Object''Image", Sloc (P));
  1585             end if;
  1586          else
  1587             Check_E1;
  1588             Set_Etype (N, Str_Typ);
  1589
  1590             pragma Assert (Is_Entity_Name (P) and then Is_Type (Entity (P)));
  1591
  1592             if Ekind (Entity (P)) = E_Incomplete_Type
  1593               and then Present (Full_View (Entity (P)))
  1594             then
  1595                P_Type := Full_View (Entity (P));
  1596                P_Base_Type := Base_Type (P_Type);
  1597                Set_Entity (P, P_Type);
  1598             end if;
  1599
  1600             Check_Image_Type (P_Type);
  1601             Resolve (E1, P_Base_Type);
  1602             Validate_Non_Static_Attribute_Function_Call;
  1603          end if;
  1604
  1605          Check_Enum_Image (Check_Enumeration_Maps => True);
  1606
  1607          --  Check restriction No_Fixed_IO. Note the check of Comes_From_Source
  1608          --  to avoid giving a duplicate message for when Image attributes
  1609          --  applied to object references get expanded into type-based Image
  1610          --  attributes.
  1611
  1612          if Restriction_Check_Required (No_Fixed_IO)
  1613            and then Comes_From_Source (N)
  1614            and then Is_Fixed_Point_Type (P_Type)
  1615          then
  1616             Check_Restriction (No_Fixed_IO, P);
  1617          end if;
  1618       end Analyze_Image_Attribute;
```

## sem_attr.adb:8724–8745

```ada
  8724          --  For First, Last and Length, the prefix is an array object, and we
  8725          --  apply the attribute to its type, but we need a constrained type
  8726          --  for this, so we use the actual subtype if available.
  8727
  8728          elsif Id = Attribute_First
  8729            or else Id = Attribute_Last
  8730            or else Id = Attribute_Length
  8731          then
  8732             declare
  8733                AS : constant Entity_Id := Get_Actual_Subtype_If_Available (P);
  8734
  8735             begin
  8736                if Present (AS) and then Is_Constrained (AS) then
  8737                   P_Entity := AS;
  8738
  8739                --  If we have an unconstrained type we cannot fold
  8740
  8741                else
  8742                   Check_Expressions;
  8743                   return;
  8744                end if;
  8745             end;
```

## sem_attr.adb:9717–9748

```ada
  9717       -----------
  9718
  9719       --  Image is a scalar attribute, but is never static, because it is
  9720       --  not a static function (having a non-scalar argument (RM 4.9(22)).
  9721       --  However, we can constant-fold the image of an enumeration literal
  9722       --  if names are available and default Image implementation has not
  9723       --  been overridden.
  9724
  9725       when Attribute_Image =>
  9726          if Is_Entity_Name (E1)
  9727            and then Ekind (Entity (E1)) = E_Enumeration_Literal
  9728            and then not Discard_Names (First_Subtype (Etype (E1)))
  9729            and then not Global_Discard_Names
  9730            and then not Has_Aspect (Etype (E1), Aspect_Put_Image)
  9731          then
  9732             declare
  9733                Lit : constant Entity_Id := Entity (E1);
  9734                Str : String_Id;
  9735             begin
  9736                Start_String;
  9737                Get_Unqualified_Decoded_Name_String (Chars (Lit));
  9738                Set_Casing (All_Upper_Case);
  9739                Store_String_Chars (Name_Buffer (1 .. Name_Len));
  9740                Str := End_String;
  9741                Rewrite (N, Make_String_Literal (Loc, Strval => Str));
  9742                Analyze_And_Resolve (N, Standard_String);
  9743                Set_Is_Static_Expression (N, False);
  9744             end;
  9745          end if;
  9746
  9747       -------------------
  9748       -- Integer_Value --
```

## sem_ch3.adb:4823–4829

```ada
  4823          elsif Is_Scalar_Type (T)
  4824            and then Is_Entity_Name (E)
  4825            and then Is_Known_Valid (Entity (E))
  4826            and then In_Subrange_Of (Etype (Entity (E)), T)
  4827          then
  4828             Set_Is_Known_Valid (Id);
  4829             Set_Actual_Subtype (Id, Etype (Entity (E)));
```

## sem_ch3.adb:5138–5145

```ada
  5138                Expand_Subtype_From_Expr
  5139                  (N             => N,
  5140                   Unc_Type      => T,
  5141                   Subtype_Indic => Object_Definition (N),
  5142                   Exp           => E,
  5143                   Related_Id    => Related_Id);
  5144
  5145                Act_T := Find_Type_Of_Object (Object_Definition (N), N);
```

## sem_ch3.adb:5320–5336

```ada
  5320          --  object is constrained by the defaults, so it is worthwhile
  5321          --  building the corresponding subtype.
  5322
  5323          --  Ada 2005 (AI-363): If the aliased object is discriminated and
  5324          --  unconstrained, then only establish an actual subtype if the
  5325          --  nominal subtype is indefinite. In definite cases the object is
  5326          --  unconstrained in Ada 2005.
  5327
  5328          if No (E)
  5329            and then Is_Record_Type (T)
  5330            and then not Is_Constrained (T)
  5331            and then Has_Discriminants (T)
  5332            and then (Ada_Version < Ada_2005
  5333                       or else not Is_Definite_Subtype (T))
  5334          then
  5335             Set_Actual_Subtype (Id, Build_Default_Subtype (T, N));
  5336          end if;
```

## sem_ch3.adb:14339–14477

```ada
 14339    procedure Constrain_Array
 14340      (Def_Id      : Entity_Id;
 14341       SI          : Node_Id;
 14342       Related_Nod : Node_Id;
 14343       Related_Id  : Entity_Id;
 14344       Suffix      : Character)
 14345    is
 14346       C                     : constant Node_Id := Constraint (SI);
 14347       Number_Of_Constraints : constant Nat := List_Length (Constraints (C));
 14348       Index                 : Node_Id;
 14349       S, T                  : Entity_Id;
 14350       Constraint_OK         : Boolean := True;
 14351       Is_FLB_Array_Subtype  : Boolean := False;
 14352
 14353    begin
 14354       T := Entity (Subtype_Mark (SI));
 14355
 14356       if Is_Access_Type (T) then
 14357          T := Designated_Type (T);
 14358       end if;
 14359
 14360       T := Underlying_Type (T);
 14361
 14362       --  If an index constraint follows a subtype mark in a subtype indication
 14363       --  then the type or subtype denoted by the subtype mark must not already
 14364       --  impose an index constraint. The subtype mark must denote either an
 14365       --  unconstrained array type or an access type whose designated type
 14366       --  is such an array type... (RM 3.6.1)
 14367
 14368       if Is_Constrained (T) then
 14369          Error_Msg_N ("array type is already constrained", Subtype_Mark (SI));
 14370          Constraint_OK := False;
 14371
 14372       else
 14373          --  In either case, the index constraint must provide a discrete
 14374          --  range for each index of the array type and the type of each
 14375          --  discrete range must be the same as that of the corresponding
 14376          --  index. (RM 3.6.1)
 14377
 14378          if Number_Of_Constraints /= Number_Dimensions (T) then
 14379             Error_Msg_NE ("incorrect number of index constraints for }", C, T);
 14380             Constraint_OK := False;
 14381
 14382          else
 14383             S := First (Constraints (C));
 14384             Index := First_Index (T);
 14385             Analyze (Index);
 14386
 14387             --  Apply constraints to each index type
 14388
 14389             for J in 1 .. Number_Of_Constraints loop
 14390                Constrain_Index (Index, S, Related_Nod, Related_Id, Suffix, J);
 14391
 14392                --  If the subtype of the index has been set to indicate that
 14393                --  it has a fixed lower bound, then record that the subtype's
 14394                --  entity will need to be marked as being a fixed-lower-bound
 14395                --  array subtype.
 14396
 14397                if S = First (Constraints (C)) then
 14398                   Is_FLB_Array_Subtype :=
 14399                     Is_Fixed_Lower_Bound_Index_Subtype (Etype (S));
 14400
 14401                   --  If the parent subtype (or should this be Etype of that?)
 14402                   --  is an FLB array subtype, we flag an error, because we
 14403                   --  don't currently allow subtypes of such subtypes to
 14404                   --  specify a fixed lower bound for any of their indexes,
 14405                   --  even if the index of the parent subtype is a "range <>"
 14406                   --  index.
 14407
 14408                   if Is_FLB_Array_Subtype
 14409                     and then Is_Fixed_Lower_Bound_Array_Subtype (T)
 14410                   then
 14411                      Error_Msg_NE
 14412                        ("index with fixed lower bound not allowed for subtype "
 14413                           & "of fixed-lower-bound }", S, T);
 14414
 14415                      Is_FLB_Array_Subtype := False;
 14416                   end if;
 14417
 14418                elsif Is_FLB_Array_Subtype
 14419                  and then not Is_Fixed_Lower_Bound_Index_Subtype (Etype (S))
 14420                then
 14421                   Error_Msg_NE
 14422                     ("constrained index not allowed for fixed-lower-bound "
 14423                        & "subtype of}", S, T);
 14424
 14425                elsif not Is_FLB_Array_Subtype
 14426                  and then Is_Fixed_Lower_Bound_Index_Subtype (Etype (S))
 14427                then
 14428                   Error_Msg_NE
 14429                     ("index with fixed lower bound not allowed for "
 14430                        & "constrained subtype of}", S, T);
 14431                end if;
 14432
 14433                Next (Index);
 14434                Next (S);
 14435             end loop;
 14436
 14437          end if;
 14438       end if;
 14439
 14440       Mutate_Ekind (Def_Id, E_Array_Subtype);
 14441
 14442       Set_Size_Info      (Def_Id,                (T));
 14443       Set_First_Rep_Item (Def_Id, First_Rep_Item (T));
 14444       Set_Etype          (Def_Id, Base_Type      (T));
 14445
 14446       if Constraint_OK then
 14447          Set_First_Index (Def_Id, First (Constraints (C)));
 14448       else
 14449          Set_First_Index (Def_Id, First_Index (T));
 14450       end if;
 14451
 14452       Set_Is_Constrained     (Def_Id, not Is_FLB_Array_Subtype);
 14453       Set_Is_Fixed_Lower_Bound_Array_Subtype
 14454                              (Def_Id, Is_FLB_Array_Subtype);
 14455       Set_Is_Aliased         (Def_Id, Is_Aliased (T));
 14456       Set_Is_Independent     (Def_Id, Is_Independent (T));
 14457       Set_Depends_On_Private (Def_Id, Has_Private_Component (Def_Id));
 14458
 14459       Set_Is_Private_Composite (Def_Id, Is_Private_Composite (T));
 14460       Set_Is_Limited_Composite (Def_Id, Is_Limited_Composite (T));
 14461
 14462       --  A subtype does not inherit the Packed_Array_Impl_Type of is parent.
 14463       --  We need to initialize the attribute because if Def_Id is previously
 14464       --  analyzed through a limited_with clause, it will have the attributes
 14465       --  of an incomplete type, one of which is an Elist that overlaps the
 14466       --  Packed_Array_Impl_Type field.
 14467
 14468       Set_Packed_Array_Impl_Type (Def_Id, Empty);
 14469
 14470       --  Build a freeze node if parent still needs one. Also make sure that
 14471       --  the Depends_On_Private status is set because the subtype will need
 14472       --  reprocessing at the time the base type does, and also we must set a
 14473       --  conditional delay.
 14474
 14475       Set_Depends_On_Private (Def_Id, Depends_On_Private (T));
 14476       Conditional_Delay (Def_Id, T);
 14477    end Constrain_Array;
```

## sem_ch3.adb:15317–15498

```ada
 15317      (Index        : Node_Id;
 15318       S            : Node_Id;
 15319       Related_Nod  : Node_Id;
 15320       Related_Id   : Entity_Id;
 15321       Suffix       : Character;
 15322       Suffix_Index : Pos)
 15323    is
 15324       Def_Id : Entity_Id;
 15325       R      : Node_Id := Empty;
 15326       T      : constant Entity_Id := Etype (Index);
 15327       Is_FLB_Index : Boolean := False;
 15328       Is_Range     : constant Boolean :=
 15329         Nkind (S) = N_Range
 15330         or else (Nkind (S) = N_Attribute_Reference
 15331                  and then Attribute_Name (S) = Name_Range);
 15332       Is_Indic     : constant Boolean := Nkind (S) = N_Subtype_Indication;
 15333       K            : constant Entity_Kind :=
 15334         (if Is_Modular_Integer_Type (T) then E_Modular_Integer_Subtype
 15335          elsif Is_Integer_Type (T) then E_Signed_Integer_Subtype
 15336          else E_Enumeration_Subtype);
 15337
 15338    begin
 15339       if Is_Range or else Is_Indic then
 15340          Def_Id :=
 15341            Create_Itype (K, Related_Nod, Related_Id, Suffix, Suffix_Index);
 15342          Set_Etype (Def_Id, Base_Type (T));
 15343       end if;
 15344
 15345       if Is_Range then
 15346          --  A Range attribute will be transformed into N_Range by Resolve
 15347
 15348          --  If a range has an Empty upper bound, then remember that for later
 15349          --  setting of the index subtype's Is_Fixed_Lower_Bound_Index_Subtype
 15350          --  flag, and also set the upper bound of the range to the index
 15351          --  subtype's upper bound rather than leaving it Empty. In truth,
 15352          --  that upper bound corresponds to a box ("<>"), but it's convenient
 15353          --  to set it to the upper bound to avoid needing to add special tests
 15354          --  in various places for an Empty upper bound, and in any case it
 15355          --  accurately characterizes the index's range of values.
 15356
 15357          if Nkind (S) = N_Range and then No (High_Bound (S)) then
 15358             Is_FLB_Index := True;
 15359             Set_High_Bound (S, Type_High_Bound (T));
 15360          end if;
 15361
 15362          R := S;
 15363
 15364          Process_Range_Expr_In_Decl (R, T);
 15365
 15366          if not Error_Posted (S)
 15367            and then
 15368              (Nkind (S) /= N_Range
 15369                or else not Covers (T, (Etype (Low_Bound (S))))
 15370                or else not Covers (T, (Etype (High_Bound (S)))))
 15371          then
 15372             if Base_Type (T) /= Any_Type
 15373               and then Etype (Low_Bound (S)) /= Any_Type
 15374               and then Etype (High_Bound (S)) /= Any_Type
 15375             then
 15376                Error_Msg_N ("range expected", S);
 15377             end if;
 15378          end if;
 15379
 15380       elsif Is_Indic then
 15381
 15382          --  The parser has verified that this is a discrete indication
 15383
 15384          Resolve_Discrete_Subtype_Indication (S, T);
 15385          Bad_Predicated_Subtype_Use
 15386            ("subtype& has predicate, not allowed in index constraint",
 15387             S, Entity (Subtype_Mark (S)));
 15388
 15389          R := Range_Expression (Constraint (S));
 15390
 15391          --  Capture values of bounds and generate temporaries for them if
 15392          --  needed, since checks may cause duplication of the expressions
 15393          --  which must not be reevaluated.
 15394
 15395          --  The forced evaluation removes side effects from expressions, which
 15396          --  should occur also in GNATprove mode. Otherwise, we end up with
 15397          --  unexpected insertions of actions at places where this is not
 15398          --  supposed to occur, e.g. on default parameters of a call.
 15399
 15400          if Expander_Active or GNATprove_Mode then
 15401             Force_Evaluation
 15402               (Low_Bound (R),  Related_Id => Def_Id, Is_Low_Bound  => True);
 15403             Force_Evaluation
 15404               (High_Bound (R), Related_Id => Def_Id, Is_High_Bound => True);
 15405          end if;
 15406
 15407       elsif Nkind (S) = N_Discriminant_Association then
 15408
 15409          --  Syntactically valid in subtype indication
 15410
 15411          Error_Msg_N ("invalid index constraint", S);
 15412          Rewrite (S, New_Occurrence_Of (T, Sloc (S)));
 15413          return;
 15414
 15415       --  Subtype_Mark case, no anonymous subtypes to construct
 15416
 15417       else
 15418          Analyze (S);
 15419
 15420          if Is_Entity_Name (S) then
 15421             if not Is_Type (Entity (S)) then
 15422                Error_Msg_N ("expect subtype mark for index constraint", S);
 15423
 15424             elsif Base_Type (Entity (S)) /= Base_Type (T) then
 15425                Wrong_Type (S, Base_Type (T));
 15426
 15427             --  Check error of subtype with predicate in index constraint
 15428
 15429             else
 15430                Bad_Predicated_Subtype_Use
 15431                  ("subtype& has predicate, not allowed in index constraint",
 15432                   S, Entity (S));
 15433             end if;
 15434
 15435          else
 15436             Error_Msg_N ("invalid index constraint", S);
 15437             Rewrite (S, New_Occurrence_Of (T, Sloc (S)));
 15438          end if;
 15439
 15440          return;
 15441       end if;
 15442
 15443       --  Complete construction of the Itype
 15444
 15445       if K = E_Enumeration_Subtype then
 15446          Set_Is_Character_Type (Def_Id, Is_Character_Type (T));
 15447          Set_First_Literal (Def_Id, First_Literal (T));
 15448       end if;
 15449
 15450       Set_Size_Info      (Def_Id,                (T));
 15451       Copy_RM_Size       (To => Def_Id, From => T);
 15452       Set_First_Rep_Item (Def_Id, First_Rep_Item (T));
 15453
 15454       --  If this is a range for a fixed-lower-bound subtype, then set the
 15455       --  index itype's low bound to the FLB and the index itype's upper bound
 15456       --  to the high bound of the parent array type's index subtype. Also,
 15457       --  set the Etype of the new scalar range and mark the itype as an FLB
 15458       --  index subtype.
 15459
 15460       if Nkind (S) = N_Range and then Is_FLB_Index then
 15461          Set_Scalar_Range
 15462            (Def_Id,
 15463             Make_Range (Sloc (S),
 15464               Low_Bound  => Low_Bound (S),
 15465               High_Bound => Type_High_Bound (T)));
 15466          Set_Etype (Scalar_Range (Def_Id), Etype (Index));
 15467          Set_Is_Fixed_Lower_Bound_Index_Subtype (Def_Id);
 15468
 15469       else
 15470          Set_Scalar_Range (Def_Id, R);
 15471       end if;
 15472
 15473       Set_Etype (S, Def_Id);
 15474       Set_Discrete_RM_Size (Def_Id);
 15475    end Constrain_Index;
 15476
 15477    -----------------------
 15478    -- Constrain_Integer --
 15479    -----------------------
 15480
 15481    procedure Constrain_Integer (Def_Id : Entity_Id; S : Node_Id) is
 15482       T : constant Entity_Id := Entity (Subtype_Mark (S));
 15483       C : constant Node_Id   := Constraint (S);
 15484
 15485    begin
 15486       Set_Scalar_Range_For_Subtype (Def_Id, Range_Expression (C), T);
 15487
 15488       if Is_Modular_Integer_Type (T) then
 15489          Mutate_Ekind (Def_Id, E_Modular_Integer_Subtype);
 15490       else
 15491          Mutate_Ekind (Def_Id, E_Signed_Integer_Subtype);
 15492       end if;
 15493
 15494       Set_Etype            (Def_Id, Base_Type      (T));
 15495       Set_Size_Info        (Def_Id,                (T));
 15496       Set_First_Rep_Item   (Def_Id, First_Rep_Item (T));
 15497       Set_Discrete_RM_Size (Def_Id);
 15498    end Constrain_Integer;
```

## sem_ch3.adb:19080–19214

```ada
 19080    function Find_Type_Of_Object
 19081      (Obj_Def     : Node_Id;
 19082       Related_Nod : Node_Id) return Entity_Id
 19083    is
 19084       Def_Kind : constant Node_Kind := Nkind (Obj_Def);
 19085       P        : Node_Id := Parent (Obj_Def);
 19086       T        : Entity_Id;
 19087       Nam      : Name_Id;
 19088
 19089    begin
 19090       --  If the parent is a component_definition node we climb to the
 19091       --  component_declaration node.
 19092
 19093       if Nkind (P) = N_Component_Definition then
 19094          P := Parent (P);
 19095       end if;
 19096
 19097       --  Case of an anonymous array subtype
 19098
 19099       if Def_Kind in N_Array_Type_Definition then
 19100          T := Empty;
 19101          Array_Type_Declaration (T, Obj_Def);
 19102
 19103       --  Create an explicit subtype whenever possible
 19104
 19105       elsif Nkind (P) /= N_Component_Declaration
 19106         and then Def_Kind = N_Subtype_Indication
 19107       then
 19108          --  Base name of subtype on object name, which will be unique in
 19109          --  the current scope.
 19110
 19111          --  If this is a duplicate declaration, return base type, to avoid
 19112          --  generating duplicate anonymous types.
 19113
 19114          if Error_Posted (P) then
 19115             Analyze (Subtype_Mark (Obj_Def));
 19116             return Entity (Subtype_Mark (Obj_Def));
 19117          end if;
 19118
 19119          Nam :=
 19120             New_External_Name
 19121              (Chars (Defining_Identifier (Related_Nod)), 'S', 0, 'T');
 19122
 19123          T := Make_Defining_Identifier (Sloc (P), Nam);
 19124
 19125          --  If In_Spec_Expression, for example within a pre/postcondition,
 19126          --  provide enough information for use of the subtype without
 19127          --  depending on full analysis and freezing, which will happen when
 19128          --  building the corresponding subprogram.
 19129
 19130          if In_Spec_Expression then
 19131             Analyze (Subtype_Mark (Obj_Def));
 19132
 19133             declare
 19134                Base_T  : constant Entity_Id := Entity (Subtype_Mark (Obj_Def));
 19135                New_Def : constant Node_Id   := New_Copy_Tree (Obj_Def);
 19136                Decl    : constant Node_Id   :=
 19137                  Make_Subtype_Declaration (Sloc (P),
 19138                    Defining_Identifier => T,
 19139                    Subtype_Indication  => New_Def);
 19140
 19141             begin
 19142                Set_Etype  (T, Base_T);
 19143                Mutate_Ekind  (T, Subtype_Kind (Ekind (Base_T)));
 19144                Set_Parent (T, Decl);
 19145                Set_Scope (T, Current_Scope);
 19146
 19147                if Ekind (T) = E_Array_Subtype then
 19148                   Constrain_Array (T, New_Def, Related_Nod, T, 'P');
 19149
 19150                elsif Ekind (T) = E_Record_Subtype then
 19151                   Set_First_Entity (T, First_Entity (Base_T));
 19152                   Set_Has_Discriminants (T, Has_Discriminants (Base_T));
 19153                   Set_Is_Constrained (T);
 19154                end if;
 19155
 19156                Insert_Before (Related_Nod, Decl);
 19157             end;
 19158
 19159             return T;
 19160          end if;
 19161
 19162          --  When generating code, insert subtype declaration ahead of
 19163          --  declaration that generated it. Similar behavior required under
 19164          --  preanalysis (including strict preanalysis) to perform the
 19165          --  minimum decoration, and avoid reporting spurious errors.
 19166
 19167          Insert_Action (Obj_Def,
 19168            Make_Subtype_Declaration (Sloc (P),
 19169              Defining_Identifier => T,
 19170              Subtype_Indication  => Relocate_Node (Obj_Def)));
 19171
 19172          --  This subtype may need freezing, and this will not be done
 19173          --  automatically if the object declaration is not in declarative
 19174          --  part. Since this is an object declaration, the type cannot always
 19175          --  be frozen here. Deferred constants do not freeze their type
 19176          --  (which often enough will be private).
 19177
 19178          if Nkind (P) = N_Object_Declaration
 19179            and then Constant_Present (P)
 19180            and then No (Expression (P))
 19181          then
 19182             null;
 19183
 19184          --  Here we freeze the base type of object type to catch premature use
 19185          --  of discriminated private type without a full view.
 19186
 19187          else
 19188             Insert_Actions (Obj_Def, Freeze_Entity (Base_Type (T), P));
 19189          end if;
 19190
 19191       --  Ada 2005 AI-406: the object definition in an object declaration
 19192       --  can be an access definition.
 19193
 19194       elsif Def_Kind = N_Access_Definition then
 19195          T := Access_Definition (Related_Nod, Obj_Def);
 19196
 19197          Set_Is_Local_Anonymous_Access
 19198            (T, Ada_Version < Ada_2012
 19199                    or else Nkind (P) /= N_Object_Declaration
 19200                    or else Is_Library_Level_Entity (Defining_Identifier (P)));
 19201
 19202       --  Otherwise, either the object definition is just a subtype_mark or we
 19203       --  are analyzing a component declaration.
 19204
 19205       else
 19206          T :=
 19207            Process_Subtype
 19208              (Obj_Def,
 19209               Related_Nod,
 19210               Excludes_Null => Null_Exclusion_Present (Parent (Obj_Def)));
 19211       end if;
 19212
 19213       return T;
 19214    end Find_Type_Of_Object;
```

## sem_ch3.adb:20712–20761

```ada
 20712       if No (Def_Id) then
 20713          Def_Id :=
 20714            Create_Itype
 20715              ((if Is_Signed_Integer_Type (T) then E_Signed_Integer_Subtype
 20716                elsif Is_Modular_Integer_Type (T) then E_Modular_Integer_Subtype
 20717                else E_Enumeration_Subtype),
 20718               Related_Nod,
 20719               Related_Id,
 20720               'D',
 20721               Suffix_Index);
 20722          Set_Etype (Def_Id, Base_Type (T));
 20723
 20724          if Ekind (Def_Id) = E_Enumeration_Subtype then
 20725             Set_Is_Character_Type (Def_Id, Is_Character_Type (T));
 20726             Set_First_Literal     (Def_Id, First_Literal (T));
 20727          end if;
 20728
 20729          Set_Size_Info      (Def_Id,                (T));
 20730          Set_RM_Size        (Def_Id, RM_Size        (T));
 20731          Set_First_Rep_Item (Def_Id, First_Rep_Item (T));
 20732
 20733          Set_Scalar_Range   (Def_Id, R);
 20734          Conditional_Delay  (Def_Id, T);
 20735
 20736          --  In the subtype indication case inherit properties of the parent
 20737
 20738          if Nkind (N) = N_Subtype_Indication then
 20739
 20740             --  It is enough to inherit predicate flags and not the predicate
 20741             --  functions, because predicates on an index type are illegal
 20742             --  anyway and the flags are enough to detect them.
 20743
 20744             Inherit_Predicate_Flags (Def_Id, Entity (Subtype_Mark (N)));
 20745
 20746             --  If the immediate parent of the new subtype is nonstatic, then
 20747             --  the subtype we create is nonstatic as well, even if its bounds
 20748             --  are static.
 20749
 20750             if not Is_OK_Static_Subtype (Entity (Subtype_Mark (N))) then
 20751                Set_Is_Non_Static_Subtype (Def_Id);
 20752             end if;
 20753          end if;
 20754
 20755          Set_Parent (Def_Id, N);
 20756       end if;
 20757
 20758       --  Final step is to label the index with this constructed type
 20759
 20760       Set_Etype (N, Def_Id);
 20761    end Make_Index;
```

## sem_ch3.adb:22704–22719

```ada
 22704          if Expander_Active or GNATprove_Mode then
 22705
 22706             --  Call Force_Evaluation to create declarations as needed
 22707             --  to deal with side effects, and also create typ_FIRST/LAST
 22708             --  entities for bounds if we have a subtype name.
 22709
 22710             --  Note: we do this transformation even if expansion is not
 22711             --  active if we are in GNATprove_Mode since the transformation
 22712             --  is in general required to ensure that the resulting tree has
 22713             --  proper Ada semantics.
 22714
 22715             Force_Evaluation
 22716               (Lo, Related_Id => Subtyp, Is_Low_Bound  => True);
 22717             Force_Evaluation
 22718               (Hi, Related_Id => Subtyp, Is_High_Bound => True);
 22719          end if;
```

## sem_ch3.adb:23008–23038

```ada
 23008          --  Explicit subtype declaration case
 23009
 23010          if Nkind (P) = N_Subtype_Declaration then
 23011             Def_Id := Defining_Identifier (P);
 23012
 23013          --  Explicit derived type definition case
 23014
 23015          elsif Nkind (P) = N_Derived_Type_Definition then
 23016             Def_Id := Defining_Identifier (Parent (P));
 23017
 23018          --  Implicit case, the Def_Id must be created as an implicit type.
 23019          --  The one exception arises in the case of concurrent types, array
 23020          --  and access types, where other subsidiary implicit types may be
 23021          --  created and must appear before the main implicit type. In these
 23022          --  cases we leave Def_Id set to Empty as a signal that Create_Itype
 23023          --  has not yet been called to create Def_Id.
 23024
 23025          else
 23026             if Is_Concurrent_Type (Subtype_Mark_Id)
 23027               or else Is_Access_Type (Subtype_Mark_Id)
 23028             then
 23029                Def_Id := Empty;
 23030
 23031             --  For the other cases, we create a new unattached Itype,
 23032             --  and set the indication to ensure it gets attached later.
 23033
 23034             else
 23035                Def_Id :=
 23036                  Create_Itype (E_Void, Related_Nod, Related_Id, Suffix);
 23037             end if;
 23038          end if;
```

## sem_ch3.adb:23110–23133

```ada
 23110                Constrain_Array (Def_Id, S, Related_Nod, Related_Id, Suffix);
 23111
 23112             when Decimal_Fixed_Point_Kind =>
 23113                Constrain_Decimal (Def_Id, S);
 23114
 23115             when Enumeration_Kind =>
 23116                Constrain_Enumeration (Def_Id, S);
 23117
 23118             when Ordinary_Fixed_Point_Kind =>
 23119                Constrain_Ordinary_Fixed (Def_Id, S);
 23120
 23121             when Float_Kind =>
 23122                Constrain_Float (Def_Id, S);
 23123
 23124             when Integer_Kind =>
 23125                Constrain_Integer (Def_Id, S);
 23126
 23127             when Class_Wide_Kind
 23128                | E_Incomplete_Type
 23129                | E_Record_Subtype
 23130                | E_Record_Type
 23131             =>
 23132                Constrain_Discriminated_Type (Def_Id, S, Related_Nod);
 23133
```

## sem_ch4.adb:1916–1965

```ada
  1916    procedure Analyze_Concatenation (N : Node_Id) is
  1917
  1918       --  We wish to avoid deep recursion, because concatenations are often
  1919       --  deeply nested, as in A&B&...&Z. Therefore, we walk down the left
  1920       --  operands nonrecursively until we find something that is not a
  1921       --  concatenation (A in this case), or has already been analyzed. We
  1922       --  analyze that, and then walk back up the tree following Parent
  1923       --  pointers, calling Analyze_Concatenation_Rest to do the rest of the
  1924       --  work at each level. The Parent pointers allow us to avoid recursion,
  1925       --  and thus avoid running out of memory.
  1926
  1927       NN : Node_Id := N;
  1928       L  : Node_Id;
  1929
  1930    begin
  1931       Candidate_Type := Empty;
  1932
  1933       --  The following code is equivalent to:
  1934
  1935       --    Set_Etype (N, Any_Type);
  1936       --    Analyze_Expression (Left_Opnd (N));
  1937       --    Analyze_Concatenation_Rest (N);
  1938
  1939       --  where the Analyze_Expression call recurses back here if the left
  1940       --  operand is a concatenation.
  1941
  1942       --  Walk down left operands
  1943
  1944       loop
  1945          Set_Etype (NN, Any_Type);
  1946          L := Left_Opnd (NN);
  1947          exit when Nkind (L) /= N_Op_Concat or else Analyzed (L);
  1948          NN := L;
  1949       end loop;
  1950
  1951       --  Now (given the above example) NN is A&B and L is A
  1952
  1953       --  First analyze L ...
  1954
  1955       Analyze_Expression (L);
  1956
  1957       --  ... then walk NN back up until we reach N (where we started), calling
  1958       --  Analyze_Concatenation_Rest along the way.
  1959
  1960       loop
  1961          Analyze_Concatenation_Rest (NN);
  1962          exit when NN = N;
  1963          NN := Parent (NN);
  1964       end loop;
  1965    end Analyze_Concatenation;
```

## sem_ch4.adb:2067–2141

```ada
  2067    ------------------------------------
  2068
  2069    procedure Analyze_Comparison_Equality_Op (N : Node_Id) is
  2070       Loc : constant Source_Ptr := Sloc (N);
  2071       L   : constant Node_Id    := Left_Opnd (N);
  2072       R   : constant Node_Id    := Right_Opnd (N);
  2073
  2074       Op_Id : Entity_Id;
  2075
  2076    begin
  2077       Set_Etype (N, Any_Type);
  2078       Candidate_Type := Empty;
  2079
  2080       Analyze_Expression (L);
  2081       Analyze_Expression (R);
  2082
  2083       --  If the entity is set, the node is a generic instance with a non-local
  2084       --  reference to the predefined operator or to a user-defined function.
  2085       --  It can also be an inequality that is expanded into the negation of a
  2086       --  call to a user-defined equality operator.
  2087
  2088       --  For the predefined case, the result is Boolean, regardless of the
  2089       --  type of the operands. The operands may even be limited, if they are
  2090       --  generic actuals. If they are overloaded, label the operands with the
  2091       --  compare type if it is present, typically because it is a global type
  2092       --  in a generic instance, or with the common type that must be present,
  2093       --  or with the type of the formal of the user-defined function.
  2094
  2095       if Present (Entity (N)) then
  2096          Op_Id := Entity (N);
  2097
  2098          if Ekind (Op_Id) = E_Operator then
  2099             Add_One_Interp (N, Op_Id, Standard_Boolean);
  2100          else
  2101             Add_One_Interp (N, Op_Id, Etype (Op_Id));
  2102          end if;
  2103
  2104          if Is_Overloaded (L) then
  2105             if Ekind (Op_Id) = E_Operator then
  2106                Set_Etype (L,
  2107                  (if Present (Compare_Type (N))
  2108                   then Compare_Type (N)
  2109                   else Intersect_Types (L, R)));
  2110             else
  2111                Set_Etype (L, Etype (First_Formal (Op_Id)));
  2112             end if;
  2113          end if;
  2114
  2115          if Is_Overloaded (R) then
  2116             if Ekind (Op_Id) = E_Operator then
  2117                Set_Etype (R,
  2118                  (if Present (Compare_Type (N))
  2119                   then Compare_Type (N)
  2120                   else Intersect_Types (L, R)));
  2121             else
  2122                Set_Etype (R, Etype (Next_Formal (First_Formal (Op_Id))));
  2123             end if;
  2124          end if;
  2125
  2126       else
  2127          Op_Id := Get_Name_Entity_Id (Chars (N));
  2128
  2129          while Present (Op_Id) loop
  2130             if Ekind (Op_Id) = E_Operator then
  2131                Find_Comparison_Equality_Types (L, R, Op_Id, N);
  2132             else
  2133                Analyze_User_Defined_Binary_Op (N, Op_Id);
  2134             end if;
  2135
  2136             Op_Id := Homonym (Op_Id);
  2137          end loop;
  2138       end if;
  2139
  2140       --  If there was no match and the operator is inequality, this may be
  2141       --  a case where inequality has not been made explicit, as for tagged
```

## sem_ch5.adb:300–365

```ada
   300          --  operand is the actual in an entry declaration, then within the
   301          --  accept statement it is replaced with a local renaming, which may
   302          --  also have an actual subtype. Likewise for a return object that
   303          --  lives on the secondary stack.
   304
   305          if Is_Entity_Name (Opnd)
   306            and then (Ekind (Entity (Opnd)) in E_Out_Parameter
   307                                             | E_In_Out_Parameter
   308                                             | E_Generic_In_Out_Parameter
   309                       or else
   310                         (Ekind (Entity (Opnd)) = E_Variable
   311                           and then Nkind (Parent (Entity (Opnd))) =
   312                                      N_Object_Renaming_Declaration
   313                           and then Nkind (Parent (Parent (Entity (Opnd)))) =
   314                                      N_Accept_Statement)
   315                       or else Is_Secondary_Stack_Return_Object (Entity (Opnd)))
   316          then
   317             Opnd_Type := Get_Actual_Subtype (Opnd);
   318
   319          --  If the assignment operand is a component reference, then we build
   320          --  the actual subtype of the component for the unconstrained case,
   321          --  unless there is already one or the type is an unchecked union.
   322
   323          elsif (Nkind (Opnd) = N_Selected_Component
   324                  or else (Nkind (Opnd) = N_Explicit_Dereference
   325                            and then No (Actual_Designated_Subtype (Opnd))))
   326            and then not Is_Unchecked_Union (Opnd_Type)
   327          then
   328             --  If the right-hand side contains target names, expansion has
   329             --  been disabled to prevent expansion that might move target
   330             --  names out of the context of the assignment statement. Restore
   331             --  temporarily the current compilation mode so that the actual
   332             --  subtype can be built.
   333
   334             if Nkind (N) = N_Assignment_Statement
   335               and then Has_Target_Names (N)
   336               and then Present (Current_Assignment)
   337             then
   338                Expander_Mode_Restore;
   339                Full_Analysis := Save_Full_Analysis;
   340                Decl := Build_Actual_Subtype_Of_Component (Opnd_Type, Opnd);
   341                Expander_Mode_Save_And_Set (False);
   342                Full_Analysis := False;
   343             else
   344                Decl := Build_Actual_Subtype_Of_Component (Opnd_Type, Opnd);
   345             end if;
   346
   347             if Present (Decl) then
   348                Insert_Action (N, Decl);
   349                Mark_Rewrite_Insertion (Decl);
   350                Analyze (Decl);
   351                Opnd_Type := Defining_Identifier (Decl);
   352                Set_Etype (Opnd, Opnd_Type);
   353                Freeze_Itype (Opnd_Type, N);
   354
   355             elsif Is_Constrained (Etype (Opnd)) then
   356                Opnd_Type := Etype (Opnd);
   357             end if;
   358
   359          --  For slice, use the constrained subtype created for the slice
   360
   361          elsif Nkind (Opnd) = N_Slice then
   362             Opnd_Type := Etype (Opnd);
   363          end if;
   364       end Set_Assignment_Type;
   365
```

## sem_ch5.adb:3259–3265

```ada
  3259       --  Local variables
  3260
  3261       DS : constant Node_Id   := Discrete_Subtype_Definition (N);
  3262       Id : constant Entity_Id := Defining_Identifier (N);
  3263
  3264       DS_Copy : Node_Id;
  3265
```

## sem_ch5.adb:3295–3315

```ada
  3295       --  because bounds expressed as function calls with side effects will be
  3296       --  incorrectly replicated.
  3297
  3298       if Nkind (DS) = N_Range
  3299         and then Expander_Active
  3300         and then Nkind (Parent (N)) /= N_Quantified_Expression
  3301       then
  3302          Process_Bounds (DS);
  3303
  3304       --  Either the expander not active or the range of iteration is a subtype
  3305       --  indication, an entity, or a function call that yields an aggregate or
  3306       --  a container.
  3307
  3308       else
  3309          DS_Copy := New_Copy_Tree (DS);
  3310          Set_Parent (DS_Copy, Parent (DS));
  3311          Preanalyze_Range (DS_Copy);
  3312
  3313          --  Ada 2012: If the domain of iteration is:
  3314
  3315          --  a)  a function call,
```

## sem_ch5.adb:3434–3438

```ada
  3434          Make_Index (DS, N);
  3435       end if;
  3436
  3437       Set_Etype (Id, Etype (DS));
  3438
```

## sem_ch5.adb:3901–3990

```ada
  3901
  3902          procedure Prepare_Param_Spec_Loop
  3903            (Param_Spec      : Node_Id;
  3904             Stop_Processing : out Boolean)
  3905          is
  3906             High     : Node_Id;
  3907             Low      : Node_Id;
  3908             Rng      : Node_Id;
  3909             Rng_Copy : Node_Id;
  3910             Rng_Typ  : Entity_Id;
  3911
  3912          begin
  3913             Stop_Processing := False;
  3914             Rng := Discrete_Subtype_Definition (Param_Spec);
  3915
  3916             --  Nothing to do when the loop is already wrapped in a block
  3917
  3918             if Is_Wrapped_In_Block (N) then
  3919                null;
  3920
  3921             --  The parameter specification appears in the form
  3922             --
  3923             --    for Def_Id in Subtype_Mark Constraint loop
  3924
  3925             elsif Nkind (Rng) = N_Subtype_Indication
  3926               and then Nkind (Range_Expression (Constraint (Rng))) = N_Range
  3927             then
  3928                Rng := Range_Expression (Constraint (Rng));
  3929
  3930                --  Preanalyze the bounds of the range constraint, setting
  3931                --  parent fields to associate the copied bounds with the range,
  3932                --  allowing proper tree climbing during preanalysis.
  3933
  3934                Low  := New_Copy_Tree (Low_Bound  (Rng));
  3935                High := New_Copy_Tree (High_Bound (Rng));
  3936
  3937                Set_Parent (Low, Rng);
  3938                Set_Parent (High, Rng);
  3939
  3940                Preanalyze (Low);
  3941                Preanalyze (High);
  3942
  3943                --  The bounds contain at least one function call that returns
  3944                --  on the secondary stack. Note that the loop must be wrapped
  3945                --  only when such a call exists.
  3946
  3947                if Has_Sec_Stack_Call (Low) or else Has_Sec_Stack_Call (High)
  3948                then
  3949                   Wrap_Loop_Statement (Manage_Sec_Stack => True);
  3950                   Stop_Processing := True;
  3951                end if;
  3952
  3953             --  Otherwise the parameter specification appears in the form
  3954             --
  3955             --    for Def_Id in Range loop
  3956
  3957             else
  3958                --  Prepare a copy of the discrete range for preanalysis. The
  3959                --  copy is semi inserted into the tree by setting its Parent
  3960                --  pointer.
  3961
  3962                Rng_Copy := New_Copy_Tree (Rng);
  3963                Set_Parent (Rng_Copy, Parent (Rng));
  3964
  3965                --  Determine what the loop is iterating on
  3966
  3967                Preanalyze_Range (Rng_Copy);
  3968                Rng_Typ := Etype (Rng_Copy);
  3969
  3970                --  Wrap the loop statement within a block in order to manage
  3971                --  the secondary stack when the discrete range:
  3972                --
  3973                --    * is either a Forward_Iterator or a Reverse_Iterator
  3974                --  or
  3975                --
  3976                --    * contains a function call that returns on the secondary
  3977                --      stack.
  3978
  3979                if Is_Iterator (Rng_Typ)
  3980                  or else Has_Sec_Stack_Call (Rng_Copy)
  3981                then
  3982                   Wrap_Loop_Statement (Manage_Sec_Stack => True);
  3983                   Stop_Processing := True;
  3984                end if;
  3985             end if;
  3986          end Prepare_Param_Spec_Loop;
  3987
  3988          -------------------------
  3989          -- Wrap_Loop_Statement --
  3990          -------------------------
```

## sem_ch5.adb:4104–4116

```ada
  4104       --  loop statement for use as a scope and as a reference for later
  4105       --  expansions. Indicate that the label does not come from source,
  4106       --  and attach it to the loop statement so it is part of the tree,
  4107       --  even without a full declaration.
  4108
  4109       else
  4110          Ent := New_Internal_Entity (E_Loop, Current_Scope, Loc, 'L');
  4111          Set_Etype  (Ent, Standard_Void_Type);
  4112          Set_Identifier (N, New_Occurrence_Of (Ent, Loc));
  4113          Set_Parent (Ent, N);
  4114          Set_Has_Created_Identifier (N);
  4115       end if;
  4116
```

## sem_ch5.adb:4868–4886

```ada
  4868    procedure Preanalyze_Range (R_Copy : Node_Id) is
  4869       Save_Analysis : constant Boolean := Full_Analysis;
  4870       Typ           : Entity_Id;
  4871
  4872    begin
  4873       Full_Analysis := False;
  4874       Expander_Mode_Save_And_Set (False);
  4875
  4876       --  In addition to the above we must explicitly suppress the generation
  4877       --  of freeze nodes that might otherwise be generated during resolution
  4878       --  of the range (e.g. if given by an attribute that will freeze its
  4879       --  prefix).
  4880
  4881       Set_Must_Not_Freeze (R_Copy);
  4882
  4883       if Nkind (R_Copy) = N_Attribute_Reference then
  4884          Set_Must_Not_Freeze (Prefix (R_Copy));
  4885       end if;
  4886
```

## sem_ch6.adb:3738–3768

```ada
  3738                if No (Spec_Id) and then GNATprove_Mode
  3739
  3740                  --  Inlining does not apply during preanalysis of code
  3741
  3742                  and then Full_Analysis
  3743
  3744                  --  Inlining only applies to full bodies, not stubs
  3745
  3746                  and then Nkind (N) /= N_Subprogram_Body_Stub
  3747
  3748                  --  Inlining only applies to bodies in the source code, not to
  3749                  --  those generated by the compiler. In particular, expression
  3750                  --  functions, whose body is generated by the compiler, are
  3751                  --  treated specially by GNATprove.
  3752
  3753                  and then Comes_From_Source (Body_Id)
  3754
  3755                  --  This cannot be done for a compilation unit, which is not
  3756                  --  in a context where we can insert a new spec.
  3757
  3758                  and then Is_List_Member (N)
  3759
  3760                  --  Inlining only applies to subprograms without contracts,
  3761                  --  as a contract is a sign that GNATprove should perform a
  3762                  --  modular analysis of the subprogram instead of a contextual
  3763                  --  analysis at each call site. The same test is performed in
  3764                  --  Inline.Can_Be_Inlined_In_GNATprove_Mode. It is repeated
  3765                  --  here in another form (because the contract has not been
  3766                  --  attached to the body) to avoid front-end errors in case
  3767                  --  pragmas are used instead of aspects, because the
  3768                  --  corresponding pragmas in the body would not be transferred
```

## sem_ch6.adb:5442–5500

```ada
  5442    --  Start of processing for Analyze_Subprogram_Specification
  5443
  5444    begin
  5445       --  Proceed with analysis. Do not emit a cross-reference entry if the
  5446       --  specification comes from an expression function, because it may be
  5447       --  the completion of a previous declaration. If it is not, the cross-
  5448       --  reference entry will be emitted for the new subprogram declaration.
  5449
  5450       if Nkind (Parent (N)) /= N_Expression_Function then
  5451          Generate_Definition (Designator);
  5452       end if;
  5453
  5454       if Nkind (N) = N_Function_Specification then
  5455          Mutate_Ekind (Designator, E_Function);
  5456          Set_Mechanism (Designator, Default_Mechanism);
  5457       else
  5458          Mutate_Ekind (Designator, E_Procedure);
  5459          Set_Etype (Designator, Standard_Void_Type);
  5460       end if;
  5461
  5462       Set_Is_Not_Self_Hidden (Designator);
  5463
  5464       --  Flag Is_Inlined_Always is True by default, and reversed to False for
  5465       --  those subprograms which could be inlined in GNATprove mode (because
  5466       --  Body_To_Inline is non-Empty) but should not be inlined. Flag
  5467       --  Is_Inlined is True by default and reversed to False when inlining
  5468       --  fails because the subprogram is detected to be recursive.
  5469
  5470       if GNATprove_Mode then
  5471          Set_Is_Inlined_Always (Designator);
  5472          Set_Is_Inlined (Designator);
  5473       end if;
  5474
  5475       --  Introduce new scope for analysis of the formals and the return type
  5476
  5477       Set_Scope (Designator, Current_Scope);
  5478
  5479       if Present (Formals) then
  5480          Push_Scope (Designator);
  5481          Process_Formals (Formals, N);
  5482
  5483          --  Check dimensions in N for formals with default expression
  5484
  5485          Analyze_Dimension_Formals (N, Formals);
  5486
  5487          --  Ada 2005 (AI-345): If this is an overriding operation of an
  5488          --  inherited interface operation, and the controlling type is
  5489          --  a synchronized type, replace the type with its corresponding
  5490          --  record, to match the proper signature of an overriding operation.
  5491          --  Same processing for an access parameter whose designated type is
  5492          --  derived from a synchronized interface.
  5493
  5494          --  This modification is not done for invariant procedures because
  5495          --  the corresponding record may not necessarely be visible when the
  5496          --  concurrent type acts as the full view of a private type.
  5497
  5498          --    package Pack is
  5499          --       type Prot is private with Type_Invariant => ...;
  5500          --       procedure ConcInvariant (Obj : Prot);
```

## sem_ch6.adb:5565–5623

```ada
  5565          Analyze_Return_Type (N);
  5566          End_Scope;
  5567       end if;
  5568
  5569       --  Handle subprogram specification directly referencing an attribute
  5570
  5571       if Is_Direct_Attribute_Subp_Spec (N) then
  5572          Analyze_Direct_Attribute_Definition (Designator);
  5573       end if;
  5574
  5575       --  Function case
  5576
  5577       if Nkind (N) = N_Function_Specification then
  5578
  5579          --  Deal with operator symbol case
  5580
  5581          if Nkind (Designator) = N_Defining_Operator_Symbol then
  5582             Valid_Operator_Definition (Designator);
  5583          end if;
  5584
  5585          May_Need_Actuals (Designator);
  5586
  5587          --  Ada 2005 (AI-251): If the return type is abstract, verify that
  5588          --  the subprogram is abstract also. This does not apply to renaming
  5589          --  declarations, where abstractness is inherited, and to subprogram
  5590          --  bodies generated for stream operations, which become renamings as
  5591          --  bodies. We also skip the check for thunks.
  5592
  5593          --  In case of primitives associated with abstract interface types
  5594          --  the check is applied later (see Analyze_Subprogram_Declaration).
  5595
  5596          if Nkind (Original_Node (Parent (N))) not in
  5597               N_Abstract_Subprogram_Declaration        |
  5598               N_Formal_Abstract_Subprogram_Declaration |
  5599               N_Subprogram_Renaming_Declaration
  5600            and then not Is_Thunk (Designator)
  5601          then
  5602             if Is_Abstract_Type (Etype (Designator)) then
  5603                Error_Msg_N
  5604                  ("function that returns abstract type must be abstract", N);
  5605
  5606             --  Ada 2012 (AI-0073): Extend this test to subprograms with an
  5607             --  access result whose designated type is abstract.
  5608
  5609             elsif Ada_Version >= Ada_2012
  5610               and then Nkind (Result_Definition (N)) = N_Access_Definition
  5611               and then
  5612                 not Is_Class_Wide_Type (Designated_Type (Etype (Designator)))
  5613               and then Is_Abstract_Type (Designated_Type (Etype (Designator)))
  5614             then
  5615                Error_Msg_N
  5616                  ("function whose access result designates abstract type "
  5617                   & "must be abstract", N);
  5618             end if;
  5619          end if;
  5620       end if;
  5621
  5622       return Designator;
  5623    end Analyze_Subprogram_Specification;
```

## sem_eval.adb:2342–2443

```ada
  2342    procedure Eval_Concatenation (N : Node_Id) is
  2343       Left  : constant Node_Id   := Left_Opnd (N);
  2344       Right : constant Node_Id   := Right_Opnd (N);
  2345       C_Typ : constant Entity_Id := Root_Type (Component_Type (Etype (N)));
  2346       Stat  : Boolean;
  2347       Fold  : Boolean;
  2348
  2349    begin
  2350       --  Concatenation is never static in Ada 83, so if Ada 83 check operand
  2351       --  non-static context.
  2352
  2353       if Ada_Version = Ada_83
  2354         and then Comes_From_Source (N)
  2355       then
  2356          Check_Non_Static_Context (Left);
  2357          Check_Non_Static_Context (Right);
  2358          return;
  2359       end if;
  2360
  2361       --  If not foldable we are done. In principle concatenation that yields
  2362       --  any string type is static (i.e. an array type of character types).
  2363       --  However, character types can include enumeration literals, and
  2364       --  concatenation in that case cannot be described by a literal, so we
  2365       --  only consider the operation static if the result is an array of
  2366       --  (a descendant of) a predefined character type.
  2367
  2368       Test_Expression_Is_Foldable (N, Left, Right, Stat, Fold);
  2369
  2370       if not (Is_Standard_Character_Type (C_Typ) and then Fold) then
  2371          Set_Is_Static_Expression (N, False);
  2372          return;
  2373       end if;
  2374
  2375       --  Compile time string concatenation
  2376
  2377       --  ??? Note that operands that are aggregates can be marked as static,
  2378       --  so we should attempt at a later stage to fold concatenations with
  2379       --  such aggregates.
  2380
  2381       declare
  2382          Left_Str   : constant Node_Id := Get_String_Val (Left);
  2383          Left_Len   : Nat;
  2384          Right_Str  : constant Node_Id := Get_String_Val (Right);
  2385          Folded_Val : String_Id        := No_String;
  2386
  2387       begin
  2388          --  Establish new string literal, and store left operand. We make
  2389          --  sure to use the special Start_String that takes an operand if
  2390          --  the left operand is a string literal. Since this is optimized
  2391          --  in the case where that is the most recently created string
  2392          --  literal, we ensure efficient time/space behavior for the
  2393          --  case of a concatenation of a series of string literals.
  2394
  2395          if Nkind (Left_Str) = N_String_Literal then
  2396             Left_Len := String_Length (Strval (Left_Str));
  2397
  2398             --  If the left operand is the empty string, and the right operand
  2399             --  is a string literal (the case of "" & "..."), the result is the
  2400             --  value of the right operand. This optimization is important when
  2401             --  Is_Folded_In_Parser, to avoid copying an enormous right
  2402             --  operand.
  2403
  2404             if Left_Len = 0 and then Nkind (Right_Str) = N_String_Literal then
  2405                Folded_Val := Strval (Right_Str);
  2406             else
  2407                Start_String (Strval (Left_Str));
  2408             end if;
  2409
  2410          else
  2411             Start_String;
  2412             Store_String_Char (UI_To_CC (Char_Literal_Value (Left_Str)));
  2413             Left_Len := 1;
  2414          end if;
  2415
  2416          --  Now append the characters of the right operand, unless we
  2417          --  optimized the "" & "..." case above.
  2418
  2419          if Nkind (Right_Str) = N_String_Literal then
  2420             if Left_Len /= 0 then
  2421                Store_String_Chars (Strval (Right_Str));
  2422                Folded_Val := End_String;
  2423             end if;
  2424          else
  2425             Store_String_Char (UI_To_CC (Char_Literal_Value (Right_Str)));
  2426             Folded_Val := End_String;
  2427          end if;
  2428
  2429          Set_Is_Static_Expression (N, Stat);
  2430
  2431          --  If left operand is the empty string, the result is the
  2432          --  right operand, including its bounds if anomalous.
  2433
  2434          if Left_Len = 0
  2435            and then Is_Array_Type (Etype (Right))
  2436            and then Etype (Right) /= Any_String
  2437          then
  2438             Set_Etype (N, Etype (Right));
  2439          end if;
  2440
  2441          Fold_Str (N, Folded_Val, Static => Stat);
  2442       end;
  2443    end Eval_Concatenation;
```

## sem_eval.adb:2454–2534

```ada
  2454    procedure Eval_Entity_Name (N : Node_Id) is
  2455       Def_Id : constant Entity_Id := Entity (N);
  2456       Val    : Node_Id;
  2457
  2458    begin
  2459       --  Enumeration literals are always considered to be constants
  2460       --  and cannot raise Constraint_Error (RM 4.9(22)).
  2461
  2462       if Ekind (Def_Id) = E_Enumeration_Literal then
  2463          Set_Is_Static_Expression (N);
  2464          return;
  2465
  2466       --  A name is static if it denotes a static constant (RM 4.9(5)), and
  2467       --  we also copy Raise_Constraint_Error. Notice that even if non-static,
  2468       --  it does not violate 10.2.1(8) here, since this is not a variable.
  2469
  2470       elsif Ekind (Def_Id) = E_Constant then
  2471
  2472          --  Deferred constants must always be treated as nonstatic outside the
  2473          --  scope of their full view.
  2474
  2475          if Present (Full_View (Def_Id))
  2476            and then not In_Open_Scopes (Scope (Def_Id))
  2477          then
  2478             Val := Empty;
  2479          else
  2480             Val := Constant_Value (Def_Id);
  2481          end if;
  2482
  2483          if Present (Val) then
  2484             Set_Is_Static_Expression
  2485               (N, Is_Static_Expression (Val)
  2486                     and then Is_Static_Subtype (Etype (Def_Id)));
  2487             Set_Raises_Constraint_Error (N, Raises_Constraint_Error (Val));
  2488
  2489             if not Is_Static_Expression (N)
  2490               and then not Is_Generic_Type (Etype (N))
  2491             then
  2492                Validate_Static_Object_Name (N);
  2493             end if;
  2494
  2495             --  Mark constant condition in SCOs
  2496
  2497             if Generate_SCO
  2498               and then Comes_From_Source (N)
  2499               and then Is_Boolean_Type (Etype (Def_Id))
  2500               and then Compile_Time_Known_Value (N)
  2501             then
  2502                Set_SCO_Condition (N, Expr_Value_E (N) = Standard_True);
  2503             end if;
  2504
  2505             return;
  2506          end if;
  2507
  2508       --  Ada 2022 (AI12-0075): If checking for potentially static expressions
  2509       --  is enabled and we have a reference to a formal parameter of mode in,
  2510       --  substitute a static value for the reference, to allow folding the
  2511       --  expression. This supports checking the requirement of RM 6.8(5.3/5)
  2512       --  in Analyze_Expression_Function.
  2513
  2514       elsif Ekind (Def_Id) = E_In_Parameter
  2515         and then Checking_Potentially_Static_Expression
  2516         and then Is_Static_Function (Scope (Def_Id))
  2517       then
  2518          Fold_Dummy (N, Etype (Def_Id));
  2519       end if;
  2520
  2521       --  Fall through if the name is not static
  2522
  2523       Validate_Static_Object_Name (N);
  2524    end Eval_Entity_Name;
  2525
  2526    ------------------------
  2527    -- Eval_If_Expression --
  2528    ------------------------
  2529
  2530    --  We can fold to a static expression if the condition and both dependent
  2531    --  expressions are static. Otherwise, the only required processing is to do
  2532    --  the check for non-static context for the then and else expressions.
  2533
  2534    procedure Eval_If_Expression (N : Node_Id) is
```

## sem_eval.adb:5118–5144

```ada
  5118    procedure Fold_Str (N : Node_Id; Val : String_Id; Static : Boolean) is
  5119       Loc : constant Source_Ptr := Sloc (N);
  5120       Typ : constant Entity_Id  := Etype (N);
  5121
  5122    begin
  5123       if Raises_Constraint_Error (N) then
  5124          Set_Is_Static_Expression (N, Static);
  5125          return;
  5126       end if;
  5127
  5128       Rewrite (N, Make_String_Literal (Loc, Strval => Val));
  5129
  5130       --  We now have the literal with the right value, both the actual type
  5131       --  and the expected type of this literal are taken from the expression
  5132       --  that was evaluated. So now we do the Analyze and Resolve.
  5133
  5134       --  Note that we have to reset Is_Static_Expression both after the
  5135       --  analyze step (because Resolve will evaluate the literal, which
  5136       --  will cause semantic errors if it is marked as static), and after
  5137       --  the Resolve step (since Resolve in some cases resets this flag).
  5138
  5139       Analyze (N);
  5140       Set_Is_Static_Expression (N, Static);
  5141       Set_Etype (N, Typ);
  5142       Resolve (N);
  5143       Set_Is_Static_Expression (N, Static);
  5144    end Fold_Str;
```

## sem_eval.adb:5293–5308

```ada
  5293    function Get_String_Val (N : Node_Id) return Node_Id is
  5294    begin
  5295       if Nkind (N) in N_String_Literal | N_Character_Literal then
  5296          return N;
  5297       elsif Is_Entity_Name (N) then
  5298          return Get_String_Val (Constant_Value (Entity (N)));
  5299       elsif Nkind (N) = N_Integer_Literal then
  5300          pragma Assert (Serious_Errors_Detected /= 0);
  5301          return
  5302            Make_Character_Literal (Sloc (N),
  5303              Chars              => Error_Name,
  5304              Char_Literal_Value => Intval (N));
  5305       else
  5306          raise Program_Error;
  5307       end if;
  5308    end Get_String_Val;
```

## sem_res.adb:2545–2551

```ada
  2545       --  Return if already analyzed
  2546
  2547       if Analyzed (N) then
  2548          Debug_A_Exit ("resolving  ", N, "  (done, already analyzed)");
  2549          Analyze_Dimension (N);
  2550          return;
  2551
```

## sem_res.adb:4861–4879

```ada
  4861                --  that it might be more consistent to apply these only when
  4862                --  expansion is active (in Exp_Ch6.Expand_Actuals), as we do
  4863                --  for the outbound predicate tests ??? In any case indicate
  4864                --  the function being called, for better warnings if the call
  4865                --  leads to an infinite recursion.
  4866
  4867                if Predicate_Tests_On_Arguments (Nam) then
  4868                   Apply_Predicate_Check (A, F_Typ, Fun => Nam);
  4869                end if;
  4870
  4871                --  Apply required constraint checks
  4872
  4873                if Is_Scalar_Type (A_Typ) then
  4874                   Apply_Scalar_Range_Check (A, F_Typ);
  4875
  4876                elsif Is_Array_Type (A_Typ) then
  4877                   Apply_Length_Check (A, F_Typ);
  4878
  4879                elsif Is_Record_Type (F_Typ)
```

## sem_res.adb:9360–9368

```ada
  9360       --  subtypes directly if they are needed).
  9361
  9362       if Is_Packed_Array (Etype (N))
  9363         and then not Is_Constrained (Etype (N))
  9364         and then Nkind (Parent (N)) /= N_Attribute_Reference
  9365         and then Comes_From_Source (N)
  9366       then
  9367          Set_Etype (N, Get_Actual_Subtype (N));
  9368       end if;
```

## sem_res.adb:9732–9745

```ada
  9732             end loop;
  9733          end;
  9734
  9735       else
  9736          Array_Type := Etype (Pref);
  9737       end if;
  9738
  9739       Resolve (Pref, Array_Type);
  9740       Array_Type := Get_Actual_Subtype_If_Available (Pref);
  9741
  9742       --  If the prefix's type is an access type, get to the real array type.
  9743       --  Note: we do not apply an access check because an explicit dereference
  9744       --  will be introduced later, and the check will happen there.
  9745
```

## sem_res.adb:10570–10619

```ada
 10570    procedure Resolve_Op_Concat (N : Node_Id; Typ : Entity_Id) is
 10571
 10572       --  We wish to avoid deep recursion, because concatenations are often
 10573       --  deeply nested, as in A&B&...&Z. Therefore, we walk down the left
 10574       --  operands nonrecursively until we find something that is not a simple
 10575       --  concatenation (A in this case). We resolve that, and then walk back
 10576       --  up the tree following Parent pointers, calling Resolve_Op_Concat_Rest
 10577       --  to do the rest of the work at each level. The Parent pointers allow
 10578       --  us to avoid recursion, and thus avoid running out of memory. See also
 10579       --  Sem_Ch4.Analyze_Concatenation, where a similar approach is used.
 10580
 10581       NN  : Node_Id := N;
 10582       Op1 : Node_Id;
 10583
 10584    begin
 10585       --  The following code is equivalent to:
 10586
 10587       --    Resolve_Op_Concat_First (NN, Typ);
 10588       --    Resolve_Op_Concat_Arg (N, ...);
 10589       --    Resolve_Op_Concat_Rest (N, Typ);
 10590
 10591       --  where the Resolve_Op_Concat_Arg call recurses back here if the left
 10592       --  operand is a concatenation.
 10593
 10594       --  Walk down left operands
 10595
 10596       loop
 10597          Resolve_Op_Concat_First (NN, Typ);
 10598          Op1 := Left_Opnd (NN);
 10599          exit when not (Nkind (Op1) = N_Op_Concat
 10600                          and then not Is_Array_Type (Component_Type (Typ))
 10601                          and then Entity (Op1) = Entity (NN));
 10602          NN := Op1;
 10603       end loop;
 10604
 10605       --  Now (given the above example) NN is A&B and Op1 is A
 10606
 10607       --  First resolve Op1 ...
 10608
 10609       Resolve_Op_Concat_Arg (NN, Op1, Typ, Is_Component_Left_Opnd  (NN));
 10610
 10611       --  ... then walk NN back up until we reach N (where we started), calling
 10612       --  Resolve_Op_Concat_Rest along the way.
 10613
 10614       loop
 10615          Resolve_Op_Concat_Rest (NN, Typ);
 10616          exit when NN = N;
 10617          NN := Parent (NN);
 10618       end loop;
 10619    end Resolve_Op_Concat;
```

## sem_res.adb:10767–10832

```ada
 10767    -- Resolve_Op_Concat_First --
 10768    -----------------------------
 10769
 10770    procedure Resolve_Op_Concat_First (N : Node_Id; Typ : Entity_Id) is
 10771       Btyp : constant Entity_Id := Base_Type (Typ);
 10772       Op1  : constant Node_Id := Left_Opnd (N);
 10773       Op2  : constant Node_Id := Right_Opnd (N);
 10774
 10775    begin
 10776       --  The parser folds an enormous sequence of concatenations of string
 10777       --  literals into "" & "...", where the Is_Folded_In_Parser flag is set
 10778       --  in the right operand. If the expression resolves to a predefined "&"
 10779       --  operator, all is well. Otherwise, the parser's folding is wrong, so
 10780       --  we give an error. See P_Simple_Expression in Par.Ch4.
 10781
 10782       if Nkind (Op2) = N_String_Literal
 10783         and then Is_Folded_In_Parser (Op2)
 10784         and then Ekind (Entity (N)) = E_Function
 10785       then
 10786          pragma Assert (Nkind (Op1) = N_String_Literal  --  should be ""
 10787                and then String_Length (Strval (Op1)) = 0);
 10788          Error_Msg_N ("too many user-defined concatenations", N);
 10789          return;
 10790       end if;
 10791
 10792       Set_Etype (N, Btyp);
 10793
 10794       if Is_Limited_Composite (Btyp) then
 10795          Error_Msg_N ("concatenation not available for limited array", N);
 10796          Explain_Limited_Type (Btyp, N);
 10797       end if;
 10798    end Resolve_Op_Concat_First;
 10799
 10800    ----------------------------
 10801    -- Resolve_Op_Concat_Rest --
 10802    ----------------------------
 10803
 10804    procedure Resolve_Op_Concat_Rest (N : Node_Id; Typ : Entity_Id) is
 10805       Op1  : constant Node_Id := Left_Opnd (N);
 10806       Op2  : constant Node_Id := Right_Opnd (N);
 10807
 10808    begin
 10809       Resolve_Op_Concat_Arg (N, Op2, Typ, Is_Component_Right_Opnd  (N));
 10810
 10811       Generate_Operator_Reference (N, Typ);
 10812
 10813       if Is_String_Type (Typ) then
 10814          Eval_Concatenation (N);
 10815       end if;
 10816
 10817       --  If this is not a static concatenation, but the result is a string
 10818       --  type (and not an array of strings) ensure that static string operands
 10819       --  have their subtypes properly constructed.
 10820
 10821       if Nkind (N) /= N_String_Literal
 10822         and then Is_Character_Type (Component_Type (Typ))
 10823       then
 10824          Set_String_Literal_Subtype (Op1, Typ);
 10825
 10826          --  See Resolve_String_Literal for the asymmetry
 10827
 10828          if Ekind (Etype (Op2)) /= E_String_Literal_Subtype then
 10829             Set_String_Literal_Subtype (Op2, Typ);
 10830          end if;
 10831       end if;
 10832    end Resolve_Op_Concat_Rest;
```

## sem_res.adb:11875–11929

```ada
 11875          --  object denoted by the prefix is implicit in the node, so we build
 11876          --  an explicit representation for it in order to compute the actual
 11877          --  subtype.
 11878
 11879          if not Is_Constrained (Array_Type) then
 11880             Remove_Side_Effects (Pref);
 11881
 11882             declare
 11883                Obj : constant Node_Id :=
 11884                        Make_Explicit_Dereference (Sloc (N),
 11885                          Prefix => New_Copy_Tree (Pref));
 11886             begin
 11887                Set_Etype (Obj, Array_Type);
 11888                Set_Parent (Obj, Parent (N));
 11889                Array_Type := Get_Actual_Subtype (Obj);
 11890             end;
 11891          end if;
 11892
 11893       --  In CodePeer mode the attribute Image is not expanded, so when it
 11894       --  acts as a prefix of a slice, we handle it like a call to function
 11895       --  returning an unconstrained string. Same for the Wide variants of
 11896       --  attribute Image.
 11897
 11898       elsif Is_Entity_Name (Pref)
 11899         or else Nkind (Pref) = N_Explicit_Dereference
 11900         or else (Nkind (Pref) = N_Function_Call
 11901                   and then not Is_Constrained (Etype (Pref)))
 11902         or else (CodePeer_Mode
 11903                   and then Nkind (Pref) = N_Attribute_Reference
 11904                   and then Attribute_Name (Pref) in Name_Image
 11905                                                   | Name_Wide_Image
 11906                                                   | Name_Wide_Wide_Image)
 11907       then
 11908          Array_Type := Get_Actual_Subtype (Pref);
 11909
 11910       --  If the name is a selected component that depends on discriminants,
 11911       --  build an actual subtype for it. This can happen only when the name
 11912       --  itself is overloaded; otherwise the actual subtype is created when
 11913       --  the selected component is analyzed.
 11914
 11915       elsif Nkind (Pref) = N_Selected_Component
 11916         and then Full_Analysis
 11917         and then Depends_On_Discriminant (First_Index (Array_Type))
 11918       then
 11919          declare
 11920             Act_Decl : constant Node_Id :=
 11921                          Build_Actual_Subtype_Of_Component (Array_Type, Pref);
 11922          begin
 11923             Insert_Action (N, Act_Decl);
 11924             Array_Type := Defining_Identifier (Act_Decl);
 11925          end;
 11926
 11927       --  Maybe this should just be "else", instead of checking for the
 11928       --  specific case of slice??? This is needed for the case where the
 11929       --  prefix is an Image attribute, which gets expanded to a slice, and so
```

## sem_res.adb:12039–12120

```ada
 12039    procedure Resolve_String_Literal (N : Node_Id; Typ : Entity_Id) is
 12040       C_Typ      : constant Entity_Id  := Component_Type (Typ);
 12041       R_Typ      : constant Entity_Id  := Root_Type (C_Typ);
 12042       Loc        : constant Source_Ptr := Sloc (N);
 12043       Str        : constant String_Id  := Strval (N);
 12044       Strlen     : constant Nat        := String_Length (Str);
 12045       Subtype_Id : Entity_Id;
 12046       Need_Check : Boolean;
 12047
 12048    begin
 12049       --  For a string appearing in a concatenation, defer creation of the
 12050       --  string_literal_subtype until the end of the resolution of the
 12051       --  concatenation, because the literal may be constant-folded away.
 12052       --  This is a useful optimization for long concatenation expressions,
 12053       --  but it cannot be done if the string is the right operand and the
 12054       --  left operand may be null, because 4.5.3(5) says that the result is
 12055       --  the right operand and, in particular, has its original subtype.
 12056
 12057       --  If the string is an aggregate built for a single character (which
 12058       --  happens in a non-static context) or is a null string to which special
 12059       --  checks may apply, we build the subtype. Wide strings must also get a
 12060       --  string subtype if they come from a one character aggregate. Strings
 12061       --  generated by attributes might be static, but it is often hard to
 12062       --  determine whether the enclosing context is static, so we generate
 12063       --  subtypes for them as well, thus losing some rarer optimizations ???
 12064       --  Same for strings that come from a static conversion.
 12065
 12066       Need_Check :=
 12067         (Strlen = 0 and then Typ /= Standard_String)
 12068           or else Nkind (Parent (N)) /= N_Op_Concat
 12069           or else (N /= Left_Opnd (Parent (N))
 12070                     and then N /= Right_Opnd (Parent (N)))
 12071           or else (N = Right_Opnd (Parent (N))
 12072                     and then
 12073                       (Nkind (Left_Opnd (Parent (N))) /= N_String_Literal
 12074                         or else
 12075                           String_Length (Strval (Left_Opnd (Parent (N)))) = 0))
 12076           or else ((Typ = Standard_Wide_String
 12077                       or else Typ = Standard_Wide_Wide_String)
 12078                     and then Nkind (Original_Node (N)) /= N_String_Literal);
 12079
 12080       --  If the resolving type is itself a string literal subtype, we can just
 12081       --  reuse it, since there is no point in creating another.
 12082
 12083       if Ekind (Typ) = E_String_Literal_Subtype then
 12084          Subtype_Id := Typ;
 12085
 12086       elsif Nkind (Parent (N)) = N_Op_Concat
 12087         and then not Need_Check
 12088         and then Nkind (Original_Node (N)) not in N_Character_Literal
 12089                                                 | N_Attribute_Reference
 12090                                                 | N_Qualified_Expression
 12091                                                 | N_Type_Conversion
 12092       then
 12093          Subtype_Id := Typ;
 12094
 12095       --  Do not generate a string literal subtype for the default expression
 12096       --  of a formal parameter in GNATprove mode. This is because the string
 12097       --  subtype is associated with the freezing actions of the subprogram,
 12098       --  however freezing is disabled in GNATprove mode and as a result the
 12099       --  subtype is unavailable.
 12100
 12101       elsif GNATprove_Mode
 12102         and then Nkind (Parent (N)) = N_Parameter_Specification
 12103       then
 12104          Subtype_Id := Typ;
 12105
 12106       --  Otherwise we must create a string literal subtype. Note that the
 12107       --  whole idea of string literal subtypes is simply to avoid the need
 12108       --  for building a full fledged array subtype for each literal.
 12109
 12110       else
 12111          Set_String_Literal_Subtype (N, Typ);
 12112          Subtype_Id := Etype (N);
 12113       end if;
 12114
 12115       if Nkind (Parent (N)) /= N_Op_Concat
 12116         or else Need_Check
 12117       then
 12118          Set_Etype (N, Subtype_Id);
 12119          Eval_String_Literal (N);
 12120       end if;
```

## sem_res.adb:13145–13170

```ada
 13145          Index_Subtype := Create_Itype (Subtype_Kind (Ekind (Index_Type)), N);
 13146
 13147          --  Take a new copy of Drange (where bounds have been rewritten to
 13148          --  reference side-effect-free names). Using a separate tree ensures
 13149          --  that further expansion (e.g. while rewriting a slice assignment
 13150          --  into a FOR loop) does not attempt to remove side effects on the
 13151          --  bounds again (which would cause the bounds in the index subtype
 13152          --  definition to refer to temporaries before they are defined) (the
 13153          --  reason is that some names are considered side effect free here
 13154          --  for the subtype, but not in the context of a loop iteration
 13155          --  scheme).
 13156
 13157          Set_Scalar_Range   (Index_Subtype, New_Copy_Tree (Drange));
 13158          Set_Parent         (Scalar_Range (Index_Subtype), Index_Subtype);
 13159          Set_Etype          (Index_Subtype, Index_Type);
 13160          Set_Size_Info      (Index_Subtype, Index_Type);
 13161          Set_RM_Size        (Index_Subtype, RM_Size (Index_Type));
 13162          Set_Is_Constrained (Index_Subtype);
 13163       end if;
 13164
 13165       Slice_Subtype := Create_Itype (E_Array_Subtype, N);
 13166
 13167       Index := New_Occurrence_Of (Index_Subtype, Loc);
 13168       Set_Etype (Index, Index_Subtype);
 13169       Append (Index, Index_List);
 13170
```

## sem_res.adb:13205–13337

```ada
 13205    procedure Set_String_Literal_Subtype (N : Node_Id; Typ : Entity_Id) is
 13206       Loc        : constant Source_Ptr := Sloc (N);
 13207       Low_Bound  : constant Node_Id :=
 13208                      Type_Low_Bound (Etype (First_Index (Typ)));
 13209       Length     : constant Nat :=
 13210         (case Nkind (N) is
 13211           when N_String_Literal => String_Length (Strval (N)),
 13212           --  Sinput.Source_Last points to an EOF character that's not in the
 13213           --  original file and we do not include that character.
 13214           when N_External_Initializer => Nat (
 13215             Source_Last (File_Index (N)) - Source_First (File_Index (N))),
 13216           when others => 0);
 13217       Subtype_Id : Entity_Id;
 13218
 13219    begin
 13220       if Nkind (N) not in N_String_Literal | N_External_Initializer then
 13221          return;
 13222       end if;
 13223
 13224       Subtype_Id := Create_Itype (E_String_Literal_Subtype, N);
 13225       Set_String_Literal_Length (Subtype_Id, UI_From_Int (Length));
 13226       Set_Etype          (Subtype_Id, Base_Type (Typ));
 13227       Set_Is_Constrained (Subtype_Id);
 13228       Set_Etype          (N, Subtype_Id);
 13229
 13230       --  The low bound is set from the low bound of the corresponding index
 13231       --  type. Note that we do not store the high bound in the string literal
 13232       --  subtype, but it can be deduced if necessary from the length and the
 13233       --  low bound.
 13234
 13235       if Is_OK_Static_Expression (Low_Bound) then
 13236          Set_String_Literal_Low_Bound (Subtype_Id, Low_Bound);
 13237
 13238       --  If the lower bound is not static we create a range for the string
 13239       --  literal, using the index type and the known length of the literal.
 13240       --  If the length is 1, then the upper bound is set to a mere copy of
 13241       --  the lower bound; or else, if the index type is a signed integer,
 13242       --  then the upper bound is computed as Low_Bound + L - 1; otherwise,
 13243       --  the upper bound is computed as T'Val (T'Pos (Low_Bound) + L - 1).
 13244
 13245       else
 13246          declare
 13247             Index_List    : constant List_Id   := New_List;
 13248             Index_Type    : constant Entity_Id := Etype (First_Index (Typ));
 13249             Array_Subtype : Entity_Id;
 13250             Drange        : Node_Id;
 13251             High_Bound    : Node_Id;
 13252             Index         : Node_Id;
 13253             Index_Subtype : Entity_Id;
 13254
 13255          begin
 13256             if Length = 1 then
 13257                High_Bound := New_Copy_Tree (Low_Bound);
 13258
 13259             elsif Has_Overflow_Operations (Index_Type) then
 13260                High_Bound :=
 13261                  Make_Op_Add (Loc,
 13262                    Left_Opnd  => New_Copy_Tree (Low_Bound),
 13263                    Right_Opnd => Make_Integer_Literal (Loc, Length - 1));
 13264
 13265             else
 13266                High_Bound :=
 13267                  Make_Attribute_Reference (Loc,
 13268                    Attribute_Name => Name_Val,
 13269                    Prefix         =>
 13270                      New_Occurrence_Of (Index_Type, Loc),
 13271                    Expressions    => New_List (
 13272                      Make_Op_Add (Loc,
 13273                        Left_Opnd  =>
 13274                          Make_Attribute_Reference (Loc,
 13275                            Attribute_Name => Name_Pos,
 13276                            Prefix         =>
 13277                              New_Occurrence_Of (Index_Type, Loc),
 13278                            Expressions    =>
 13279                              New_List (New_Copy_Tree (Low_Bound))),
 13280                        Right_Opnd =>
 13281                          Make_Integer_Literal (Loc, Length - 1))));
 13282             end if;
 13283
 13284             if Is_Integer_Type (Index_Type) then
 13285                Set_String_Literal_Low_Bound
 13286                  (Subtype_Id, Make_Integer_Literal (Loc, 1));
 13287
 13288             else
 13289                --  If the index type is an enumeration type, build bounds
 13290                --  expression with attributes.
 13291
 13292                Set_String_Literal_Low_Bound
 13293                  (Subtype_Id,
 13294                   Make_Attribute_Reference (Loc,
 13295                     Attribute_Name => Name_First,
 13296                     Prefix         =>
 13297                       New_Occurrence_Of (Base_Type (Index_Type), Loc)));
 13298             end if;
 13299
 13300             Analyze_And_Resolve
 13301               (String_Literal_Low_Bound (Subtype_Id), Base_Type (Index_Type));
 13302
 13303             --  Build bona fide subtype for the string, and wrap it in an
 13304             --  unchecked conversion, because the back end expects the
 13305             --  String_Literal_Subtype to have a static lower bound.
 13306
 13307             Index_Subtype :=
 13308               Create_Itype (Subtype_Kind (Ekind (Index_Type)), N);
 13309             Drange := Make_Range (Loc, New_Copy_Tree (Low_Bound), High_Bound);
 13310             Set_Scalar_Range (Index_Subtype, Drange);
 13311             Set_Parent (Drange, N);
 13312             Analyze_And_Resolve (Drange, Index_Type);
 13313
 13314             --  In this context, the Index_Type may already have a constraint,
 13315             --  so use common base type on string subtype. The base type may
 13316             --  be used when generating attributes of the string, for example
 13317             --  in the context of a slice assignment.
 13318
 13319             Set_Etype     (Index_Subtype, Base_Type (Index_Type));
 13320             Set_Size_Info (Index_Subtype, Index_Type);
 13321             Set_RM_Size   (Index_Subtype, RM_Size (Index_Type));
 13322
 13323             Array_Subtype := Create_Itype (E_Array_Subtype, N);
 13324
 13325             Index := New_Occurrence_Of (Index_Subtype, Loc);
 13326             Set_Etype (Index, Index_Subtype);
 13327             Append (Index, Index_List);
 13328
 13329             Set_First_Index    (Array_Subtype, Index);
 13330             Set_Etype          (Array_Subtype, Base_Type (Typ));
 13331             Set_Is_Constrained (Array_Subtype, True);
 13332
 13333             Rewrite (N, Unchecked_Convert_To (Array_Subtype, N));
 13334             Set_Etype (N, Array_Subtype);
 13335          end;
 13336       end if;
 13337    end Set_String_Literal_Subtype;
```

## sem_util.adb:10380–10408

```ada
 10380    function Get_Actual_Subtype_If_Available (N : Node_Id) return Entity_Id is
 10381    begin
 10382       --  If what we have is an identifier that references a subprogram
 10383       --  formal, or a variable or constant object, then we get the actual
 10384       --  subtype from the referenced entity if one has been built.
 10385
 10386       if Nkind (N) in N_Identifier | N_Expanded_Name
 10387         and then
 10388           (Is_Formal (Entity (N))
 10389             or else Ekind (Entity (N)) = E_Constant
 10390             or else Ekind (Entity (N)) = E_Variable)
 10391         and then Present (Actual_Subtype (Entity (N)))
 10392       then
 10393          return Actual_Subtype (Entity (N));
 10394
 10395       --  Similarly, if we have an explicit dereference, then we get the
 10396       --  actual subtype from the node itself if one has been built.
 10397
 10398       elsif Nkind (N) = N_Explicit_Dereference
 10399         and then Present (Actual_Designated_Subtype (N))
 10400       then
 10401          return Actual_Designated_Subtype (N);
 10402
 10403       --  Otherwise the Etype of N is returned unchanged
 10404
 10405       else
 10406          return Etype (N);
 10407       end if;
 10408    end Get_Actual_Subtype_If_Available;
```
