# Pinned gigi structural source excerpts
Full-file SHA256 identities are in source-manifest.json; LF numbering.
Excerpts expand tabs to eight columns and trim trailing whitespace.

## gcc/ada/checks.adb:7688–7730

```text
7688:
7689:       --  Force evaluation of the node, so that it does not get evaluated twice
7690:       --  (once for the check, once for the actual reference). Such a double
7691:       --  evaluation is always a potential source of inefficiency, and is
7692:       --  functionally incorrect in the volatile case.
7693:
7694:       --  We skip the evaluation of attribute references because, after these
7695:       --  runtime checks are generated, the expander may need to rewrite this
7696:       --  node (for example, see Attribute_Max_Size_In_Storage_Elements in
7697:       --  Expand_N_Attribute_Reference) and, in many cases, their return type
7698:       --  is universal integer, which is a very large type for a temporary.
7699:
7700:       if not Is_Single_Attribute_Reference (N)
7701:         and then (not Is_Entity_Name (N)
7702:                    or else Treat_As_Volatile (Entity (N)))
7703:       then
7704:          Force_Evaluation (N, Mode => Strict);
7705:       end if;
7706:
7707:       --  The easiest case is when Source_Base_Type and Target_Base_Type are
7708:       --  the same since in this case we can simply do a direct check of the
7709:       --  value of N against the bounds of Target_Type.
7710:
7711:       --    [constraint_error when N not in Target_Type]
7712:
7713:       --  Note: this is by far the most common case, for example all cases of
7714:       --  checks on the RHS of assignments are in this category, but not all
7715:       --  cases are like this. Notably conversions can involve two types.
7716:
7717:       if Source_Base_Type = Target_Base_Type then
7718:
7719:          --  Insert the explicit range check. Note that we suppress checks for
7720:          --  this code, since we don't want a recursive range check popping up.
7721:
7722:          Insert_Action (N,
7723:            Make_Raise_Constraint_Error (Loc,
7724:              Condition =>
7725:                Make_Not_In (Loc,
7726:                  Left_Opnd  => Duplicate_Subexpr (N),
7727:                  Right_Opnd => New_Occurrence_Of (Target_Type, Loc)),
7728:              Reason => Reason),
7729:            Suppress => All_Checks);
7730:
```

## gcc/ada/exp_ch4.adb:3367–3405

```text
3367:             ConstrT : constant Entity_Id := Make_Temporary (Loc, 'A');
3368:             Acc_Typ : constant Entity_Id := Make_Temporary (Loc, 'A');
3369:
3370:             Alloc : Node_Id;
3371:             Temp  : Entity_Id;
3372:
3373:          begin
3374:             Insert_Action (Cnode,
3375:               Make_Subtype_Declaration (Loc,
3376:                 Defining_Identifier => ConstrT,
3377:                 Subtype_Indication  => Subtyp_Ind),
3378:               Suppress => All_Checks);
3379:
3380:             Freeze_Itype (ConstrT, Cnode);
3381:
3382:             Insert_Action (Cnode,
3383:               Make_Full_Type_Declaration (Loc,
3384:                 Defining_Identifier => Acc_Typ,
3385:                 Type_Definition     =>
3386:                   Make_Access_To_Object_Definition (Loc,
3387:                     Subtype_Indication => New_Occurrence_Of (ConstrT, Loc))),
3388:               Suppress => All_Checks);
3389:
3390:             Mutate_Ekind (Acc_Typ, E_Access_Type);
3391:             Set_Associated_Storage_Pool (Acc_Typ, RTE (RE_SS_Pool));
3392:
3393:             Alloc :=
3394:               Make_Allocator (Loc,
3395:                 Expression => New_Occurrence_Of (ConstrT, Loc));
3396:
3397:             --  This is currently done only for type String, which normally
3398:             --  doesn't have default initialization, but we need to set the
3399:             --  No_Initialization flag in case of either Initialize_Scalars
3400:             --  or Normalize_Scalars.
3401:
3402:             Set_No_Initialization (Alloc);
3403:
3404:             Temp := Make_Temporary (Loc, 'R', Alloc);
3405:             Insert_Action (Cnode,
```

## gcc/ada/exp_ch4.adb:4639–4654

```text
4639:       --  Set the storage pool and find the appropriate version of Allocate to
4640:       --  call. Do not overwrite the storage pool if it is already set, which
4641:       --  can occur for BIP function returns (see Expand_N_Object_Declaration).
4642:
4643:       if No (Storage_Pool (N)) then
4644:          Pool := Associated_Storage_Pool (Root_Type (PtrT));
4645:
4646:          if Present (Pool) then
4647:             Set_Storage_Pool (N, Pool);
4648:
4649:             if Is_RTE (Pool, RE_RS_Pool) then
4650:                Set_Procedure_To_Call (N, RTE (RE_RS_Allocate));
4651:
4652:             elsif Is_RTE (Pool, RE_SS_Pool) then
4653:                Check_Restriction (No_Secondary_Stack, N);
4654:                Set_Procedure_To_Call (N, RTE (RE_SS_Allocate));
```

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

## gcc/ada/libgnat/s-secsta.ads:70–73

```text
70:    procedure SS_Allocate
71:      (Addr         : out Address;
72:       Storage_Size : SSE.Storage_Count;
73:       Alignment    : SSE.Storage_Count := Standard'Maximum_Alignment);
```

## gcc/ada/libgnat/s-secsta.ads:110–113

```text
110: private
111:    SS_Pool : Integer;
112:    --  Unused entity that is just present to ease the sharing of the pool
113:    --  mechanism for specific allocation/deallocation in the compiler.
```

## gcc/ada/libgnat/s-secsta.ads:300–308

```text
300:    type Stack_Pointer is record
301:       Byte : Memory_Index;
302:       --  The position of the first free byte within the memory storage of
303:       --  Chunk.all. Byte - 1 denotes the last occupied byte within Chunk.all.
304:
305:       Chunk : SS_Chunk_Ptr;
306:       --  Reference to the chunk that accommodated the most recent allocation.
307:       --  This could be the static or any dynamic chunk.
308:    end record;
```

## gcc/ada/libgnat/s-secsta.ads:335–341

```text
335:    type Mark_Id is record
336:       Stack : SS_Stack_Ptr;
337:       --  The secondary stack whose mark was taken
338:
339:       Top : Stack_Pointer;
340:       --  The value of Stack.Top at the point in time when the mark was taken
341:    end record;
```

## gcc/ada/libgnat/s-imgint.ads:37–76

```text
37:
38: package System.Img_Int
39:   with SPARK_Mode
40: is
41:    package Impl is new Image_I (Integer);
42:
43:    procedure Image_Integer
44:      (V : Integer;
45:       S : in out String;
46:       P : out Natural)
47:      renames Impl.Image_Integer;
48:    --  Computes Integer'Image (``V``) and stores the result in
49:    --  ``S`` (1 .. ``P``) setting the resulting value of ``P``.
50:    --  The caller guarantees that ``S`` is long enough to hold the result,
51:    --  and that ``S``'First is 1.
52:    --
53:    --  If ``V`` is not negative, the subprogram writes the leading blank in
54:    --  ``S``. It then calls *Set_Image_Integer* unconditionally.
55:
56:    procedure Set_Image_Integer
57:      (V : Integer;
58:       S : in out String;
59:       P : in out Natural)
60:      renames Impl.Set_Image_Integer;
61:    --  Stores the image of ``V`` in ``S`` starting at ``S`` (``P`` + 1), ``P``
62:    --  is updated to point to the last character stored. The value stored is
63:    --  identical to the value of Integer'Image (``V``) except that no leading
64:    --  space is stored when ``V`` is non-negative. The caller guarantees that
65:    --  ``S`` is long enough to hold the result. ``S`` need not have a lower
66:    --  bound of 1.
67:    --
68:    --  If ``V`` is negative, the subprogram writes the leading '-' character,
69:    --  otherwise work with -``V`` (always work with negative value to avoid
70:    --  overflow: the largest negative number is not a special case).
71:    --
72:    --  This subprogram then uses recursion: if the value is equal or less than
73:    --  -10, recurse with the value divided by 10. Then add the digit for the
74:    --  remainder.
75:
76: end System.Img_Int;
```

## gcc/ada/libgnat/s-imagei.ads:37–58

```text
37:    type Int is range <>;
38: package System.Image_I is
39:
40:    procedure Image_Integer
41:      (V : Int;
42:       S : in out String;
43:       P : out Natural);
44:    --  Computes Int'Image (V) and stores the result in S (1 .. P)
45:    --  setting the resulting value of P. The caller guarantees that S
46:    --  is long enough to hold the result, and that S'First is 1.
47:
48:    procedure Set_Image_Integer
49:      (V : Int;
50:       S : in out String;
51:       P : in out Natural);
52:    --  Stores the image of V in S starting at S (P + 1), P is updated to point
53:    --  to the last character stored. The value stored is identical to the value
54:    --  of Int'Image (V) except that no leading space is stored when V is
55:    --  non-negative. The caller guarantees that S is long enough to hold the
56:    --  result. S need not have a lower bound of 1.
57:
58: end System.Image_I;
```

## gcc/ada/libgnat/s-conca2.ads:32–43

```text
32: --  This package contains a procedure for runtime concatenation of two string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_2 is
36:
37:    procedure Str_Concat_2 (R : out String; S1, S2 : String);
38:    --  Performs the operation R := S1 & S2. The bounds of R are known to be
39:    --  sufficient so no bound checks are required, and it is known that none of
40:    --  the input operands overlaps R. No assumptions can be made about the
41:    --  lower bounds of any of the operands.
42:
43: end System.Concat_2;
```

## gcc/ada/libgnat/s-conca3.ads:32–43

```text
32: --  This package contains a procedure for runtime concatenation of three string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_3 is
36:
37:    procedure Str_Concat_3 (R : out String; S1, S2, S3 : String);
38:    --  Performs the operation R := S1 & S2 & S3. The bounds of R are known to
39:    --  be sufficient so no bound checks are required, and it is known that none
40:    --  of the input operands overlaps R. No assumptions can be made about the
41:    --  lower bounds of any of the operands.
42:
43: end System.Concat_3;
```

## gcc/ada/libgnat/s-conca4.ads:32–43

```text
32: --  This package contains a procedure for runtime concatenation of four string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_4 is
36:
37:    procedure Str_Concat_4 (R : out String; S1, S2, S3, S4 : String);
38:    --  Performs the operation R := S1 & S2 & S3 & S4. The bounds
39:    --  of R are known to be sufficient so no bound checks are required,
40:    --  and it is known that none of the input operands overlaps R. No
41:    --  assumptions can be made about the lower bounds of any of the operands.
42:
43: end System.Concat_4;
```

## gcc/ada/libgnat/s-conca5.ads:32–43

```text
32: --  This package contains a procedure for runtime concatenation of five string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_5 is
36:
37:    procedure Str_Concat_5 (R : out String; S1, S2, S3, S4, S5 : String);
38:    --  Performs the operation R := S1 & S2 & S3 & S4 & S5. The bounds
39:    --  of R are known to be sufficient so no bound checks are required,
40:    --  and it is known that none of the input operands overlaps R. No
41:    --  assumptions can be made about the lower bounds of any of the operands.
42:
43: end System.Concat_5;
```

## gcc/ada/libgnat/s-conca6.ads:32–43

```text
32: --  This package contains a procedure for runtime concatenation of six string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_6 is
36:
37:    procedure Str_Concat_6 (R : out String; S1, S2, S3, S4, S5, S6 : String);
38:    --  Performs the operation R := S1 & S2 & S3 & S4 & S5 & S6. The
39:    --  bounds of R are known to be sufficient so no bound checks are required,
40:    --  and it is known that none of the input operands overlaps R. No
41:    --  assumptions can be made about the lower bounds of any of the operands.
42:
43: end System.Concat_6;
```

## gcc/ada/libgnat/s-conca7.ads:32–45

```text
32: --  This package contains a procedure for runtime concatenation of seven string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_7 is
36:
37:    procedure Str_Concat_7
38:      (R                          : out String;
39:       S1, S2, S3, S4, S5, S6, S7 : String);
40:    --  Performs the operation R := S1 & S2 & S3 & S4 & S5 & S6 & S7. The
41:    --  bounds of R are known to be sufficient so no bound checks are required,
42:    --  and it is known that none of the input operands overlaps R. No
43:    --  assumptions can be made about the lower bounds of any of the operands.
44:
45: end System.Concat_7;
```

## gcc/ada/libgnat/s-conca8.ads:32–45

```text
32: --  This package contains a procedure for runtime concatenation of eight string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_8 is
36:
37:    procedure Str_Concat_8
38:      (R                              : out String;
39:       S1, S2, S3, S4, S5, S6, S7, S8 : String);
40:    --  Performs the operation R := S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8.
41:    --  The bounds of R are known to be sufficient so no bound checks are
42:    --  required and it is known that none of the input operands overlaps R. No
43:    --  assumptions can be made about the lower bounds of any of the operands.
44:
45: end System.Concat_8;
```

## gcc/ada/libgnat/s-conca9.ads:32–45

```text
32: --  This package contains a procedure for runtime concatenation of eight string
33: --  operands. It is used when we want to save space in the generated code.
34:
35: package System.Concat_9 is
36:
37:    procedure Str_Concat_9
38:      (R                                  : out String;
39:       S1, S2, S3, S4, S5, S6, S7, S8, S9 : String);
40:    --  Performs the operation R := S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & S9.
41:    --  The bounds of R are known to be sufficient so no bound checks are
42:    --  required, and it is known that none of the input operands overlaps R. No
43:    --  assumptions can be made about the lower bounds of any of the operands.
44:
45: end System.Concat_9;
```

## gcc/ada/gcc-interface/trans.cc:1047–1059

```text
1047: constant_decl_with_initializer_p (tree t)
1048: {
1049:   if (!TREE_CONSTANT (t) || !DECL_P (t) || !DECL_INITIAL (t))
1050:     return false;
1051:
1052:   /* Return false for aggregate types that contain a placeholder since
1053:      their initializers cannot be manipulated easily.  */
1054:   if (AGGREGATE_TYPE_P (TREE_TYPE (t))
1055:       && !TYPE_IS_FAT_POINTER_P (TREE_TYPE (t))
1056:       && type_contains_placeholder_p (TREE_TYPE (t)))
1057:     return false;
1058:
1059:   return true;
```

## gcc/ada/gcc-interface/trans.cc:1189–1380

```text
1189:   Entity_Id gnat_entity = (Nkind (gnat_node) == N_Defining_Identifier
1190:                            || Nkind (gnat_node) == N_Defining_Operator_Symbol)
1191:                           ? gnat_node : Entity (gnat_node);
1192:   Entity_Id gnat_result_type;
1193:   tree gnu_result, gnu_result_type;
1194:   /* If GNAT_NODE is a constant, whether we should use the initialization
1195:      value instead of the constant entity, typically for scalars with an
1196:      address clause when the parent doesn't require an lvalue.  */
1197:   bool use_constant_initializer;
1198:   /* Whether we should require an lvalue for GNAT_NODE.  Needed in
1199:      specific circumstances only, so evaluated lazily.  < 0 means
1200:      unknown, > 0 means known true, 0 means known false.  */
1201:   int require_lvalue;
1202:
1203:   /* If the Etype of this node is not the same as that of the Entity, then
1204:      something went wrong, probably in generic instantiation.  However, this
1205:      does not apply to types.  Since we sometime have strange Ekind's, just
1206:      do this test for objects, except for discriminants because their type
1207:      may have been changed to a subtype by Exp_Ch3.Adjust_Discriminants.  */
1208:   gcc_assert (!Is_Object (gnat_entity)
1209:               || Ekind (gnat_entity) == E_Discriminant
1210:               || Etype (gnat_node) == Etype (gnat_entity)
1211:               || Gigi_Types_Compatible (Etype (gnat_node),
1212:                                         Etype (gnat_entity)));
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
1226:          as we may be invoked precisely during its elaboration, otherwise
1227:          the Etype.  Avoid using it for packed arrays to simplify things,
1228:          except in a return statement because we need the actual size and
1229:          the front-end does not make it explicit in this case.  */
1230:       if ((Ekind (gnat_entity) == E_Constant
1231:            || Ekind (gnat_entity) == E_Variable
1232:            || Is_Formal (gnat_entity))
1233:           && !(Is_Array_Type (Etype (gnat_entity))
1234:                && Present (Packed_Array_Impl_Type (Etype (gnat_entity)))
1235:                && Nkind (Parent (gnat_node)) != N_Simple_Return_Statement)
1236:           && Present (Actual_Subtype (gnat_entity))
1237:           && present_gnu_tree (Actual_Subtype (gnat_entity)))
1238:         gnat_result_type = Actual_Subtype (gnat_entity);
1239:       else
1240:         gnat_result_type = Etype (gnat_node);
1241:     }
1242:
1243:   /* Expand the type of this identifier first if it is needed, in case it is an
1244:      enumeral literal, which only get made when the type is expanded.  There is
1245:      no order-of-elaboration issue here.  */
1246:   if (Is_Subprogram (gnat_entity))
1247:     gnu_result_type = NULL_TREE;
1248:   else if (Nkind (Original_Node (gnat_node)) == N_Explicit_Dereference
1249:            && Is_Extended_Access_Type
1250:               (Etype (Prefix (Original_Node (gnat_node)))))
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
1269:         = lvalue_required_p (gnat_node, gnu_result_type, true, false);
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
1282:          the full view.  */
1283:       if (Present (Full_View (gnat_entity)))
1284:         gnat_entity = Full_View (gnat_entity);
1285:
1286:       gnu_result = gnat_to_gnu (Expression (Declaration_Node (gnat_entity)));
1287:     }
1288:   else
1289:     gnu_result = gnat_to_gnu_entity (gnat_entity, NULL_TREE, false);
1290:
1291:   /* Some objects (such as parameters passed by reference, globals of
1292:      variable size, and renamed objects) actually represent the address
1293:      of the object.  In that case, we must do the dereference.  Likewise,
1294:      deal with parameters to foreign convention subprograms.  */
1295:   if (DECL_P (gnu_result)
1296:       && (DECL_BY_REF_P (gnu_result)
1297:           || (TREE_CODE (gnu_result) == PARM_DECL
1298:               && DECL_BY_COMPONENT_PTR_P (gnu_result))))
1299:     {
1300:       const bool read_only = DECL_POINTS_TO_READONLY_P (gnu_result);
1301:
1302:       /* If it's a PARM_DECL to foreign convention subprogram, convert it.  */
1303:       if (TREE_CODE (gnu_result) == PARM_DECL
1304:           && DECL_BY_COMPONENT_PTR_P (gnu_result))
1305:         gnu_result
1306:           = convert (build_pointer_type (gnu_result_type), gnu_result);
1307:
1308:       /* If it's a CONST_DECL, return the underlying constant like below.  */
1309:       else if (TREE_CODE (gnu_result) == CONST_DECL
1310:                && !(DECL_CONST_ADDRESS_P (gnu_result)
1311:                     && lvalue_required_p (gnat_node, gnu_result_type, true,
1312:                                           true)))
1313:         gnu_result = DECL_INITIAL (gnu_result);
1314:
1315:       /* Do the final dereference.  */
1316:       gnu_result = build_unary_op (INDIRECT_REF, NULL_TREE, gnu_result);
1317:
1318:       if ((INDIRECT_REF_P (gnu_result)
1319:            || TREE_CODE (gnu_result) == UNCONSTRAINED_ARRAY_REF)
1320:           && No (Address_Clause (gnat_entity)))
1321:         TREE_THIS_NOTRAP (gnu_result) = 1;
1322:
1323:       if (read_only)
1324:         TREE_READONLY (gnu_result) = 1;
1325:     }
1326:
1327:   /* If we have a constant declaration and its initializer, try to return the
1328:      latter to avoid the need to call fold in lots of places and the need for
1329:      elaboration code if this identifier is used as an initializer itself.  */
1330:   if (constant_decl_with_initializer_p (gnu_result))
1331:     {
1332:       bool constant_only = (TREE_CODE (gnu_result) == CONST_DECL
1333:                             && !DECL_CONST_CORRESPONDING_VAR (gnu_result));
1334:       bool address_of_constant = (TREE_CODE (gnu_result) == CONST_DECL
1335:                                   && DECL_CONST_ADDRESS_P (gnu_result));
1336:
1337:       /* If there is a (corresponding) variable or this is the address of a
1338:          constant, we only want to return the initializer if an lvalue isn't
1339:          required.  Evaluate this now if we have not already done so.  */
1340:       if ((!constant_only || address_of_constant) && require_lvalue < 0)
1341:         require_lvalue
1342:           = lvalue_required_p (gnat_node, gnu_result_type, true,
1343:                                address_of_constant)
1344:             || (AGGREGATE_TYPE_P (gnu_result_type)
1345:                 && lvalue_for_aggregate_p (gnat_node, gnu_result_type));
1346:
1347:       /* Finally retrieve the initializer if this is deemed valid.  */
1348:       if ((constant_only && !address_of_constant) || !require_lvalue)
1349:         gnu_result = DECL_INITIAL (gnu_result);
1350:     }
1351:
1352:   /* But for a constant renaming we couldn't do that incrementally for its
1353:      definition because of the need to return an lvalue so, if the present
1354:      context doesn't itself require an lvalue, we try again here.  */
1355:   else if (Ekind (gnat_entity) == E_Constant
1356:            && Is_Elementary_Type (gnat_result_type)
1357:            && Present (Renamed_Object (gnat_entity)))
1358:     {
1359:       if (require_lvalue < 0)
1360:         require_lvalue
1361:           = lvalue_required_p (gnat_node, gnu_result_type, true, false);
1362:       if (!require_lvalue)
1363:         gnu_result = fold_constant_decl_in_expr (gnu_result);
1364:     }
1365:
1366:   /* The GNAT tree has the type of a function set to its result type, so we
1367:      adjust here.  Also use the type of the result if the Etype is a subtype
1368:      that is nominally unconstrained.  Likewise if this is a deferred constant
1369:      of a discriminated type whose full view can be elaborated statically, to
1370:      avoid problematic conversions to the nominal subtype.  But remove any
1371:      padding from the resulting type.  */
1372:   if (FUNC_OR_METHOD_TYPE_P (TREE_TYPE (gnu_result))
1373:       || Is_Constr_Array_Subt_With_Bounds (gnat_result_type)
1374:       || (Ekind (gnat_entity) == E_Constant
1375:           && Present (Full_View (gnat_entity))
1376:           && Has_Discriminants (gnat_result_type)
1377:           && TREE_CODE (gnu_result) == CONSTRUCTOR))
1378:     {
1379:       gnu_result_type = TREE_TYPE (gnu_result);
1380:       if (TYPE_IS_PADDING_P (gnu_result_type))
```

## gcc/ada/gcc-interface/trans.cc:1741–1752

```text
1741: Attribute_to_gnu (Node_Id gnat_node, tree *gnu_result_type_p,
1742:                   Attribute_Id attribute)
1743: {
1744:   const Node_Id gnat_prefix = Prefix (gnat_node);
1745:   tree gnu_prefix = gnat_to_gnu (gnat_prefix);
1746:   tree gnu_type = TREE_TYPE (gnu_prefix);
1747:   tree gnu_expr, gnu_result_type, gnu_result = error_mark_node;
1748:   bool prefix_unused = false;
1749:   Entity_Id gnat_smo;
1750:
1751:   /* If the input is a NULL_EXPR, make a new one.  */
1752:   if (TREE_CODE (gnu_prefix) == NULL_EXPR)
```

## gcc/ada/gcc-interface/trans.cc:2141–2319

```text
2141:           if (attribute == Attr_First)
2142:             gnu_result = TYPE_MIN_VALUE (gnu_type);
2143:           else if (attribute == Attr_Last)
2144:             gnu_result = TYPE_MAX_VALUE (gnu_type);
2145:           else
2146:             gnu_result = get_type_length (gnu_type, gnu_result_type);
2147:           break;
2148:         }
2149:
2150:       /* ... fall through ... */
2151:
2152:     case Attr_Length:
2153:       {
2154:         int Dimension = (Present (Expressions (gnat_node))
2155:                          ? UI_To_Int (Intval (First (Expressions (gnat_node))))
2156:                          : 1), i;
2157:         struct parm_attr_d *pa = NULL;
2158:         Entity_Id gnat_param = Empty;
2159:         bool unconstrained_ptr_deref = false;
2160:
2161:         gnu_prefix = maybe_padded_object (gnu_prefix);
2162:         gnu_prefix = maybe_unconstrained_array (gnu_prefix);
2163:
2164:         /* We treat unconstrained array In parameters specially.  We also note
2165:            whether we are dereferencing a pointer to unconstrained array.  */
2166:         if (!Is_Constrained (Etype (gnat_prefix)))
2167:           switch (Nkind (gnat_prefix))
2168:             {
2169:             case N_Identifier:
2170:               /* This is the direct case.  */
2171:               if (Ekind (Entity (gnat_prefix)) == E_In_Parameter)
2172:                 gnat_param = Entity (gnat_prefix);
2173:               break;
2174:
2175:             case N_Explicit_Dereference:
2176:               /* This is the indirect case.  Note that we need to be sure that
2177:                  the access value cannot be null as we'll hoist the load.  */
2178:               if (Nkind (Prefix (gnat_prefix)) == N_Identifier
2179:                   && Ekind (Entity (Prefix (gnat_prefix))) == E_In_Parameter)
2180:                 {
2181:                   if (Can_Never_Be_Null (Entity (Prefix (gnat_prefix))))
2182:                     gnat_param = Entity (Prefix (gnat_prefix));
2183:                 }
2184:               else
2185:                 unconstrained_ptr_deref = true;
2186:               break;
2187:
2188:             default:
2189:               break;
2190:           }
2191:
2192:         /* If the prefix is the view conversion of a constrained array to an
2193:            unconstrained form, we retrieve the constrained array because we
2194:            might not be able to substitute the PLACEHOLDER_EXPR coming from
2195:            the conversion.  This can occur with the 'Old attribute applied
2196:            to a parameter with an unconstrained type, which gets rewritten
2197:            into a constrained local variable very late in the game.  */
2198:         if (TREE_CODE (gnu_prefix) == VIEW_CONVERT_EXPR
2199:             && CONTAINS_PLACEHOLDER_P (TYPE_SIZE (TREE_TYPE (gnu_prefix)))
2200:             && !CONTAINS_PLACEHOLDER_P
2201:                 (TYPE_SIZE (TREE_TYPE (TREE_OPERAND (gnu_prefix, 0)))))
2202:           gnu_type = TREE_TYPE (TREE_OPERAND (gnu_prefix, 0));
2203:         else
2204:           gnu_type = TREE_TYPE (gnu_prefix);
2205:
2206:         prefix_unused = true;
2207:         gnu_result_type = get_unpadded_type (Etype (gnat_node));
2208:
2209:         if (TYPE_CONVENTION_FORTRAN_P (gnu_type))
2210:           {
2211:             int ndim;
2212:             tree gnu_type_temp;
2213:
2214:             for (ndim = 1, gnu_type_temp = gnu_type;
2215:                  TREE_CODE (TREE_TYPE (gnu_type_temp)) == ARRAY_TYPE
2216:                  && TYPE_MULTI_ARRAY_P (TREE_TYPE (gnu_type_temp));
2217:                  ndim++, gnu_type_temp = TREE_TYPE (gnu_type_temp))
2218:               ;
2219:
2220:             Dimension = ndim + 1 - Dimension;
2221:           }
2222:
2223:         for (i = 1; i < Dimension; i++)
2224:           gnu_type = TREE_TYPE (gnu_type);
2225:
2226:         gcc_assert (TREE_CODE (gnu_type) == ARRAY_TYPE);
2227:
2228:         /* When not optimizing, look up the slot associated with the parameter
2229:            and the dimension in the cache and create a new one on failure.
2230:            Don't do this when the actual subtype needs debug info (this happens
2231:            with -gnatD): in elaborate_expression_1, we create variables that
2232:            hold the bounds, so caching attributes isn't very interesting and
2233:            causes dependency issues between these variables and cached
2234:            expressions.  */
2235:         if (!optimize
2236:             && Present (gnat_param)
2237:             && !(Present (Actual_Subtype (gnat_param))
2238:                  && Needs_Debug_Info (Actual_Subtype (gnat_param))))
2239:           {
2240:             FOR_EACH_VEC_SAFE_ELT (f_parm_attr_cache, i, pa)
2241:               if (pa->id == gnat_param && pa->dim == Dimension)
2242:                 break;
2243:
2244:             if (!pa)
2245:               {
2246:                 pa = ggc_cleared_alloc<parm_attr_d> ();
2247:                 pa->id = gnat_param;
2248:                 pa->dim = Dimension;
2249:                 vec_safe_push (f_parm_attr_cache, pa);
2250:               }
2251:           }
2252:
2253:         /* Return the cached expression or build a new one.  */
2254:         if (attribute == Attr_First)
2255:           {
2256:             if (pa && pa->first)
2257:               {
2258:                 gnu_result = pa->first;
2259:                 break;
2260:               }
2261:
2262:             gnu_result
2263:               = TYPE_MIN_VALUE (TYPE_INDEX_TYPE (TYPE_DOMAIN (gnu_type)));
2264:           }
2265:
2266:         else if (attribute == Attr_Last)
2267:           {
2268:             if (pa && pa->last)
2269:               {
2270:                 gnu_result = pa->last;
2271:                 break;
2272:               }
2273:
2274:             gnu_result
2275:               = TYPE_MAX_VALUE (TYPE_INDEX_TYPE (TYPE_DOMAIN (gnu_type)));
2276:           }
2277:
2278:         else /* attribute == Attr_Range_Length || attribute == Attr_Length  */
2279:           {
2280:             if (pa && pa->length)
2281:               {
2282:                 gnu_result = pa->length;
2283:                 break;
2284:               }
2285:
2286:             gnu_result
2287:               = get_type_length (TYPE_INDEX_TYPE (TYPE_DOMAIN (gnu_type)),
2288:                                  gnu_result_type);
2289:           }
2290:
2291:         /* If this has a PLACEHOLDER_EXPR, qualify it by the object we are
2292:            handling.  Note that these attributes could not have been used on
2293:            an unconstrained array type.  */
2294:         gnu_result = SUBSTITUTE_PLACEHOLDER_IN_EXPR (gnu_result, gnu_prefix);
2295:         if (Present (gnat_smo)
2296:             && Present (Storage_Model_Copy_From (gnat_smo)))
2297:           gnu_result = INSTANTIATE_LOAD_IN_EXPR (gnu_result, gnat_smo);
2298:
2299:         /* Cache the expression we have just computed.  Since we want to do it
2300:            at run time, we force the use of a SAVE_EXPR and let the gimplifier
2301:            create the temporary in the outermost binding level.  We will make
2302:            sure in Subprogram_Body_to_gnu that it is evaluated on all possible
2303:            paths by forcing its evaluation on entry of the function.  */
2304:         if (pa)
2305:           {
2306:             gnu_result
2307:               = build1 (SAVE_EXPR, TREE_TYPE (gnu_result), gnu_result);
2308:             switch (attribute)
2309:               {
2310:               case Attr_First:
2311:                 pa->first = gnu_result;
2312:                 break;
2313:
2314:               case Attr_Last:
2315:                 pa->last = gnu_result;
2316:                 break;
2317:
2318:               case Attr_Length:
2319:               case Attr_Range_Length:
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

## gcc/ada/gcc-interface/trans.cc:4680–5758

```text
4680: elaborate_profile (Entity_Id first_formal, Entity_Id result_type)
4681: {
4682:   Entity_Id formal;
4683:
4684:   for (formal = first_formal;
4685:        Present (formal);
4686:        formal = Next_Formal_With_Extras (formal))
4687:     (void) gnat_to_gnu_type (Etype (formal));
4688:
4689:   if (Present (result_type) && Ekind (result_type) != E_Void)
4690:     (void) gnat_to_gnu_type (result_type);
4691: }
4692:
4693: /* Subroutine of gnat_to_gnu to translate GNAT_NODE, an N_Function_Call
4694:    or an N_Procedure_Call_Statement, to a GCC tree, which is returned.
4695:    GNU_RESULT_TYPE_P is a pointer to where we should place the result type.
4696:    If GNU_TARGET is non-null, this must be a function call on the RHS of a
4697:    N_Assignment_Statement and the result is to be placed into that object.
4698:    ATOMIC_ACCESS is the type of atomic access to be used for the assignment
4699:    to GNU_TARGET.  If, in addition, ATOMIC_SYNC is true, then the assignment
4700:    to GNU_TARGET requires atomic synchronization.  GNAT_SMO is the storage
4701:    model object to be used for the assignment to GNU_TARGET or Empty if there
4702:    is none.  */
4703:
4704: static tree
4705: Call_to_gnu (Node_Id gnat_node, tree *gnu_result_type_p, tree gnu_target,
4706:              atomic_acces_t atomic_access, bool atomic_sync, Entity_Id gnat_smo)
4707: {
4708:   const bool function_call = (Nkind (gnat_node) == N_Function_Call);
4709:   const bool returning_value = (function_call && !gnu_target);
4710:   /* The GCC node corresponding to the GNAT subprogram name.  This can either
4711:      be a FUNCTION_DECL node if we are dealing with a standard subprogram call,
4712:      or an indirect reference expression (an INDIRECT_REF node) pointing to a
4713:      subprogram.  */
4714:   const Node_Id gnat_subprog = Name (gnat_node);
4715:   tree gnu_subprog = gnat_to_gnu (gnat_subprog);
4716:   /* The FUNCTION_TYPE node giving the GCC type of the subprogram.  */
4717:   tree gnu_subprog_type = TREE_TYPE (gnu_subprog);
4718:   /* The return type of the FUNCTION_TYPE.  */
4719:   tree gnu_result_type;
4720:   const bool frontend_builtin
4721:     = (TREE_CODE (gnu_subprog) == FUNCTION_DECL
4722:        && DECL_BUILT_IN_CLASS (gnu_subprog) == BUILT_IN_FRONTEND);
4723:   auto_vec<tree, 16> gnu_actual_vec;
4724:   tree gnu_name_list = NULL_TREE;
4725:   tree gnu_stmt_list = NULL_TREE;
4726:   tree gnu_after_list = NULL_TREE;
4727:   tree gnu_retval = NULL_TREE;
4728:   tree gnu_call, gnu_result;
4729:   bool went_into_elab_proc;
4730:   bool pushed_binding_level;
4731:   bool variadic;
4732:   bool by_descriptor;
4733:   Entity_Id gnat_formal;
4734:   Entity_Id gnat_result_type;
4735:   Node_Id gnat_actual;
4736:   atomic_acces_t aa_type;
4737:   bool aa_sync;
4738:
4739:   /* The only way we can make a call via an access type is if GNAT_NAME is an
4740:      explicit dereference.  In that case, get the list of formal args from the
4741:      type the access type is pointing to.  Otherwise, get the formals from the
4742:      entity being called.  */
4743:   if (Nkind (gnat_subprog) == N_Explicit_Dereference)
4744:     {
4745:       const Entity_Id gnat_prefix_type
4746:         = Underlying_Type (Etype (Prefix (gnat_subprog)));
4747:
4748:       gnat_formal = First_Formal_With_Extras (Etype (gnat_subprog));
4749:       gnat_result_type = Etype (Etype (gnat_subprog));
4750:       variadic = IN (Convention (gnat_prefix_type), Convention_C_Variadic);
4751:
4752:       /* If the access type doesn't require foreign-compatible representation,
4753:          be prepared for descriptors.  */
4754:       by_descriptor
4755:         = targetm.calls.custom_function_descriptors > 0
4756:           && Can_Use_Internal_Rep (gnat_prefix_type);
4757:     }
4758:
4759:   else if (Nkind (gnat_subprog) == N_Attribute_Reference)
4760:     {
4761:       /* Assume here that this must be 'Elab_Body or 'Elab_Spec.  */
4762:       gnat_formal = Empty;
4763:       gnat_result_type = Empty;
4764:       variadic = false;
4765:       by_descriptor = false;
4766:     }
4767:
4768:   else
4769:     {
4770:       gcc_checking_assert (Is_Entity_Name (gnat_subprog));
4771:
4772:       gnat_formal = First_Formal_With_Extras (Entity (gnat_subprog));
4773:       gnat_result_type = Etype (Entity_Id (gnat_subprog));
4774:       variadic = IN (Convention (Entity (gnat_subprog)), Convention_C_Variadic);
4775:       by_descriptor = false;
4776:
4777:       /* If we are calling a stubbed function, then raise Program_Error, but
4778:          elaborate all our args first.  */
4779:       if (Convention (Entity (gnat_subprog)) == Convention_Stubbed)
4780:         {
4781:           tree call_expr = build_call_raise (PE_Stubbed_Subprogram_Called,
4782:                                              gnat_node, N_Raise_Program_Error);
4783:
4784:           for (gnat_actual = First_Actual (gnat_node);
4785:                Present (gnat_actual);
4786:                gnat_actual = Next_Actual (gnat_actual))
4787:             add_stmt (gnat_to_gnu (gnat_actual));
4788:
4789:           if (returning_value)
4790:             {
4791:               gnu_result_type = TREE_TYPE (gnu_subprog_type);
4792:               *gnu_result_type_p = gnu_result_type;
4793:               return build1 (NULL_EXPR, gnu_result_type, call_expr);
4794:             }
4795:
4796:           return call_expr;
4797:         }
4798:     }
4799:
4800:   /* We must elaborate the entire profile now because, if it references types
4801:      that were initially incomplete, their elaboration changes the contents
4802:      of GNU_SUBPROG_TYPE and, in particular, may change the result type.  */
4803:   elaborate_profile (gnat_formal, gnat_result_type);
4804:
4805:   gcc_assert (FUNC_OR_METHOD_TYPE_P (gnu_subprog_type));
4806:   gnu_result_type = TREE_TYPE (gnu_subprog_type);
4807:
4808:   if (TREE_CODE (gnu_subprog) == FUNCTION_DECL)
4809:     {
4810:       /* For a call to a nested function, check the inlining status.  */
4811:       if (decl_function_context (gnu_subprog))
4812:         check_inlining_for_nested_subprog (gnu_subprog);
4813:
4814:       /* For a recursive call, avoid explosion due to recursive inlining.  */
4815:       if (gnu_subprog == current_function_decl)
4816:         DECL_DISREGARD_INLINE_LIMITS (gnu_subprog) = 0;
4817:     }
4818:
4819:   /* The lifetime of the temporaries created for the call ends right after the
4820:      return value is copied, so we can give them the scope of the elaboration
4821:      routine at top level.  */
4822:   if (!current_function_decl)
4823:     {
4824:       current_function_decl = get_elaboration_procedure ();
4825:       went_into_elab_proc = true;
4826:     }
4827:   else
4828:     went_into_elab_proc = false;
4829:
4830:   /* First, create the temporary for the return value when:
4831:
4832:        1. There is no target and the function has copy-in/copy-out parameters,
4833:           because we need to preserve the return value before copying back the
4834:           parameters.
4835:
4836:        2. There is no target and the call is made for neither the declaration
4837:           of an object (regular or renaming), nor a return statement, nor an
4838:           allocator, nor an aggregate, and the return type has variable size
4839:           because in this case the gimplifier cannot create the temporary, or
4840:           more generally is an aggregate type, because the gimplifier would
4841:           create the temporary in the outermost scope instead of locally here.
4842:           But there is an exception for an allocator of unconstrained record
4843:           type with default discriminant because we allocate the actual size
4844:           in this case, unlike in the other cases, so we need a temporary to
4845:           fetch the discriminant and we create it here.
4846:
4847:        3. There is a target and it is a slice or an array with fixed size,
4848:           and the return type has variable size, because the gimplifier
4849:           doesn't handle these cases.
4850:
4851:        4. There is a target which is a bit-field and the function returns an
4852:           unconstrained record type with default discriminant, because the
4853:           return may copy more data than the bit-field can contain.
4854:
4855:        5. There is a target which needs to be accessed with a storage model.
4856:
4857:        6. There is no target and we have misaligned In Out or Out parameters
4858:           passed by reference, because we need to preserve the return value
4859:           before copying back the parameters.  However, in this case, we'll
4860:           defer creating the temporary, see below.
4861:
4862:      This must be done before we push a binding level around the call, since
4863:      we will pop it before copying the return value.  */
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
4931:       /* In the In Out or Out case, we must suppress conversions that yield
4932:          an lvalue but can nevertheless cause the creation of a temporary,
4933:          because we need the real object in this case, either to pass its
4934:          address if it's passed by reference or as target of the back copy
4935:          done after the call if it uses the copy-in/copy-out mechanism.
4936:          We do it in the In case too, except for a formal passed by reference
4937:          and an actual which is an unchecked conversion to an elementary type
4938:          or constrained composite type because it itself can cause the actual
4939:          to be misaligned and the addressability test needs to be applied to
4940:          the real object.  */
4941:       const bool suppress_type_conversion
4942:         = ((Nkind (gnat_actual) == N_Unchecked_Type_Conversion
4943:             && (!in_param
4944:                 || !is_by_ref_formal_parm
4945:                 || (Is_Composite_Type (Underlying_Type (gnat_formal_type))
4946:                     && !Is_Constrained (Underlying_Type (gnat_formal_type)))))
4947:            || (Nkind (gnat_actual) == N_Type_Conversion
4948:                && Is_Composite_Type (Underlying_Type (gnat_formal_type))));
4949:       Node_Id gnat_name = suppress_type_conversion
4950:                           ? Expression (gnat_actual) : gnat_actual;
4951:       tree gnu_name = gnat_to_gnu (gnat_name), gnu_name_type;
4952:       bool aliasing = false;
4953:
4954:       /* If it's possible we may need to use this expression twice, make sure
4955:          that any side-effects are handled via SAVE_EXPRs; likewise if we need
4956:          to force side-effects before the call.  */
4957:       if (!in_param && !is_by_ref_formal_parm)
4958:         {
4959:           tree init = NULL_TREE;
4960:           gnu_name = gnat_stabilize_reference (gnu_name, true, &init);
4961:           if (init)
4962:             gnu_name
4963:               = build_compound_expr (TREE_TYPE (gnu_name), init, gnu_name);
4964:         }
4965:
4966:       /* If we are passing a non-addressable parameter by reference, pass the
4967:          address of a copy.  In the In Out or Out case, set up to copy back
4968:          out after the call.  Moreover, in the case of a conversion, if we
4969:          are passing a non-aliasable parameter, also pass the address of a
4970:          copy to avoid breaking strict aliasing rules.  */
4971:       if (is_by_ref_formal_parm
4972:           && (gnu_name_type = gnat_to_gnu_type (Etype (gnat_name)))
4973:           && (!addressable_p (gnu_name, gnu_name_type, is_init_proc)
4974:               || (node_is_type_conversion (gnat_actual)
4975:                   && (aliasing = !aliasable_p (gnu_name, gnu_actual_type)))))
4976:         {
4977:           tree gnu_orig = gnu_name, gnu_temp, gnu_stmt;
4978:
4979:           /* Do not issue warnings for CONSTRUCTORs since this is not a copy
4980:              but sort of an instantiation for them.  */
4981:           if (TREE_CODE (remove_conversions (gnu_name, true)) == CONSTRUCTOR)
4982:             ;
4983:
4984:           /* Likewise for an atomic type, which is defined to be by-reference
4985:              if it is not by-copy but actually behaves more like a scalar.  */
4986:           else if (TYPE_ATOMIC (gnu_formal_type))
4987:             ;
4988:
4989:           /* If the formal is passed by reference, a copy is not allowed.  */
4990:           else if (TYPE_IS_BY_REFERENCE_P (gnu_formal_type)
4991:                    || Is_Aliased (gnat_formal))
4992:             post_error ("misaligned actual cannot be passed by reference",
4993:                         gnat_actual);
4994:
4995:           /* If the mechanism was forced to by-ref, a copy is not allowed but
4996:              we issue only a warning because this case is not strict Ada.  */
4997:           else if (DECL_FORCED_BY_REF_P (gnu_formal))
4998:             post_error ("misaligned actual cannot be passed by reference??",
4999:                         gnat_actual);
5000:
5001:           /* If the copy needs to be made because of aliasing considerations,
5002:              issue a warning because this was historically not necessary.  */
5003:           else if (aliasing)
5004:             {
5005:               if (Nkind (gnat_actual) == N_Unchecked_Type_Conversion)
5006:                 {
5007:                   post_error
5008:                     ("unchecked conversion implemented by copy??",
5009:                      gnat_actual);
5010:                   post_error
5011:                     ("\\??use pragma Universal_Aliasing on either type",
5012:                      gnat_actual);
5013:                   post_error
5014:                     ("\\??to enable RM 13.9(12) implementation permission",
5015:                      gnat_actual);
5016:                 }
5017:
5018:               else
5019:                 {
5020:                   post_error
5021:                     ("value conversion implemented by copy??",
5022:                      gnat_actual);
5023:                   post_error
5024:                     ("\\??use pair of types with same root type",
5025:                      gnat_actual);
5026:                   post_error
5027:                     ("\\??to avoid new object in RM 4.6(58.5/5)",
5028:                      gnat_actual);
5029:                 }
5030:             }
5031:
5032:           /* If the actual type of the object is already the nominal type,
5033:              we have nothing to do, except if the size is self-referential
5034:              in which case we'll remove the unpadding below.  */
5035:           if (TREE_TYPE (gnu_name) == gnu_name_type
5036:               && !CONTAINS_PLACEHOLDER_P (TYPE_SIZE (gnu_name_type)))
5037:             ;
5038:
5039:           /* Otherwise remove the unpadding from all the objects.  */
5040:           else if (TREE_CODE (gnu_name) == COMPONENT_REF
5041:                    && TYPE_IS_PADDING_P
5042:                       (TREE_TYPE (TREE_OPERAND (gnu_name, 0))))
5043:             gnu_orig = gnu_name = TREE_OPERAND (gnu_name, 0);
5044:
5045:           /* Otherwise convert to the nominal type of the object if needed.
5046:              There are several cases in which we need to make the temporary
5047:              using this type instead of the actual type of the object when
5048:              they are distinct, because the expectations of the callee would
5049:              otherwise not be met:
5050:                - if it's a justified modular type,
5051:                - if the actual type is a smaller form of it,
5052:                - if it's a smaller form of the actual type.  */
5053:           else if ((TREE_CODE (gnu_name_type) == RECORD_TYPE
5054:                     && (TYPE_JUSTIFIED_MODULAR_P (gnu_name_type)
5055:                         || smaller_form_type_p (TREE_TYPE (gnu_name),
5056:                                                 gnu_name_type)))
5057:                    || (INTEGRAL_TYPE_P (gnu_name_type)
5058:                        && smaller_form_type_p (gnu_name_type,
5059:                                                TREE_TYPE (gnu_name))))
5060:             gnu_name = convert (gnu_name_type, gnu_name);
5061:
5062:           /* If the temporary is created because of aliasing considerations,
5063:              or would have been so created if the actual was addressable,
5064:              it must be in the target type of the (unchecked) conversion.  */
5065:           if (aliasing
5066:               || (node_is_type_conversion (gnat_actual)
5067:                   && !aliasable_p (gnu_name, gnu_actual_type)))
5068:             {
5069:               if (Nkind (gnat_actual) == N_Unchecked_Type_Conversion)
5070:                 gnu_name = unchecked_convert (gnu_actual_type, gnu_name,
5071:                                               No_Truncation (gnat_actual));
5072:               else
5073:                 gnu_name = convert (gnu_actual_type, gnu_name);
5074:             }
5075:
5076:           /* If this is an In Out or Out parameter and we're returning a value,
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
5111:
5112:           /* Set up to move the copy back to the original if needed.  */
5113:           if (!in_param)
5114:             {
5115:               /* If the original is a COND_EXPR whose first arm isn't meant to
5116:                  be further used, just deal with the second arm.  This is very
5117:                  likely the conditional expression built for a check.  */
5118:               if (TREE_CODE (gnu_orig) == COND_EXPR
5119:                   && TREE_CODE (TREE_OPERAND (gnu_orig, 1)) == COMPOUND_EXPR
5120:                   && integer_zerop
5121:                      (TREE_OPERAND (TREE_OPERAND (gnu_orig, 1), 1)))
5122:                 gnu_orig = TREE_OPERAND (gnu_orig, 2);
5123:
5124:               gnu_stmt
5125:                 = build_binary_op (MODIFY_EXPR, NULL_TREE, gnu_orig, gnu_temp);
5126:               set_expr_location_from_node (gnu_stmt, gnat_node);
5127:
5128:               append_to_statement_list (gnu_stmt, &gnu_after_list);
5129:             }
5130:         }
5131:
5132:       /* Start from the real object and build the actual.  */
5133:       tree gnu_unpadded_actual_type = get_unpadded_type (Etype (gnat_actual));
5134:       tree gnu_actual = gnu_name;
5135:
5136:       /* If atomic access is required for an In or In Out actual parameter,
5137:          build the atomic load.  */
5138:       if (is_true_formal_parm
5139:           && !is_by_ref_formal_parm
5140:           && Ekind (gnat_formal) != E_Out_Parameter
5141:           && simple_atomic_access_required_p (gnat_actual, &aa_sync))
5142:         gnu_actual = build_atomic_load (gnu_actual, aa_sync);
5143:
5144:       /* If this was a procedure call, we may not have removed any padding.
5145:          So do it here for the part we will use as an input, if any.  */
5146:       if (Ekind (gnat_formal) != E_Out_Parameter
5147:           && TYPE_IS_PADDING_P (TREE_TYPE (gnu_actual)))
5148:         gnu_actual = convert (gnu_unpadded_actual_type, gnu_actual);
5149:
5150:       /* Put back the conversion we suppressed above in the computation of the
5151:          real object.  And even if we didn't suppress any conversion there, we
5152:          may have suppressed a conversion to the Etype of the actual earlier,
5153:          since the parent is a procedure call, so put it back here.  Note that
5154:          we might have a dummy type here if the actual is the dereference of a
5155:          pointer to it, but that's OK when the formal is passed by reference.
5156:          We also do not put back a conversion between an actual and a formal
5157:          that are unconstrained array types to avoid creating local bounds.  */
5158:       if (TYPE_IS_DUMMY_P (gnu_unpadded_actual_type))
5159:         gcc_assert (is_true_formal_parm && DECL_BY_REF_P (gnu_formal));
5160:       else if (suppress_type_conversion
5161:                && Nkind (gnat_actual) == N_Unchecked_Type_Conversion)
5162:         gnu_actual = unchecked_convert (gnu_unpadded_actual_type, gnu_actual,
5163:                                         No_Truncation (gnat_actual));
5164:       else if ((TREE_CODE (TREE_TYPE (gnu_actual)) == UNCONSTRAINED_ARRAY_TYPE
5165:                 || (TREE_CODE (TREE_TYPE (gnu_actual)) == RECORD_TYPE
5166:                     && TYPE_CONTAINS_TEMPLATE_P (TREE_TYPE (gnu_actual))))
5167:                && TREE_CODE (gnu_formal_type) == UNCONSTRAINED_ARRAY_TYPE)
5168:         ;
5169:       else
5170:         gnu_actual = convert (gnu_unpadded_actual_type, gnu_actual);
5171:
5172:       /* If the formal parameter is passed by reference, check that building
5173:          the address of the actual parameter below will not end up violating
5174:          strict aliasing rules; that's the case for a VIEW_CONVERT_EXPR when
5175:          the source and target types may not alias each other.  */
5176:       if (is_by_ref_formal_parm
5177:           && TREE_CODE (gnu_actual) == VIEW_CONVERT_EXPR
5178:           && (flag_checking || flag_strict_aliasing))
5179:         gcc_assert (aliasable_p (gnu_actual, gnu_actual_type));
5180:
5181:       gigi_checking_assert (!Do_Range_Check (gnat_actual));
5182:
5183:       /* First see if the parameter is passed by reference.  */
5184:       if (is_true_formal_parm && DECL_BY_REF_P (gnu_formal))
5185:         {
5186:           if (!in_param)
5187:             {
5188:               /* In Out or Out parameters passed by reference don't use the
5189:                  copy-in/copy-out mechanism so the address of the real object
5190:                  must be passed to the function.  */
5191:               gnu_actual = gnu_name;
5192:
5193:               /* If we have a padded type, be sure we've removed padding.  */
5194:               if (TYPE_IS_PADDING_P (TREE_TYPE (gnu_actual)))
5195:                 gnu_actual = convert (gnu_unpadded_actual_type, gnu_actual);
5196:
5197:               /* If it is the constructed subtype of an array allocated with
5198:                  its bounds, the type of the actual includes the template,
5199:                  although it is formally constrained.  So we need to convert
5200:                  it back to the real constructed subtype to retrieve the
5201:                  constrained part and takes its address.  */
5202:               if (TREE_CODE (TREE_TYPE (gnu_actual)) == RECORD_TYPE
5203:                   && TYPE_CONTAINS_TEMPLATE_P (TREE_TYPE (gnu_actual))
5204:                   && Is_Constr_Array_Subt_With_Bounds (Etype (gnat_actual)))
5205:                 gnu_actual = convert (gnu_unpadded_actual_type, gnu_actual);
5206:             }
5207:
5208:           /* There is no need to convert the actual to the formal's type before
5209:              taking its address.  The only exception is for unconstrained array
5210:              types because of the way we build fat pointers.  */
5211:           if (TREE_CODE (gnu_formal_type) == UNCONSTRAINED_ARRAY_TYPE)
5212:             {
5213:               /* Put back the conversion we suppressed above for In Out or Out
5214:                  parameters, since it may set the bounds of the actual.  */
5215:               if (!in_param && suppress_type_conversion)
5216:                 gnu_actual = convert (gnu_unpadded_actual_type, gnu_actual);
5217:               gnu_actual = convert (gnu_formal_type, gnu_actual);
5218:             }
5219:
5220:           /* Take the address of the object and convert to the proper pointer
5221:              type.  */
5222:           gnu_formal_type = TREE_TYPE (gnu_formal);
5223:           gnu_actual = build_unary_op (ADDR_EXPR, gnu_formal_type, gnu_actual);
5224:         }
5225:
5226:       /* Then see if the parameter is an array passed to a foreign convention
5227:          subprogram.  */
5228:       else if (is_true_formal_parm && DECL_BY_COMPONENT_PTR_P (gnu_formal))
5229:         {
5230:           gnu_actual = maybe_padded_object (gnu_actual);
5231:           gnu_actual = maybe_unconstrained_array (gnu_actual);
5232:
5233:           /* Take the address of the object and convert to the proper pointer
5234:              type.  We'd like to actually compute the address of the beginning
5235:              of the array using an ADDR_EXPR of an ARRAY_REF, but there's a
5236:              possibility that the ARRAY_REF might return a constant and we'd be
5237:              getting the wrong address.  Neither approach is exactly correct,
5238:              but this is the most likely to work in all cases.  */
5239:           gnu_formal_type = TREE_TYPE (gnu_formal);
5240:           gnu_actual = build_unary_op (ADDR_EXPR, gnu_formal_type, gnu_actual);
5241:         }
5242:
5243:       /* Then see if the parameter is passed by copy.  */
5244:       else if (is_true_formal_parm)
5245:         {
5246:           if (!in_param)
5247:             gnu_name_list = tree_cons (NULL_TREE, gnu_name, gnu_name_list);
5248:
5249:           gnu_actual = convert (gnu_formal_type, gnu_actual);
5250:
5251:           /* If this is a front-end built-in function, there is no need to
5252:              convert to the type used to pass the argument.  */
5253:           if (!frontend_builtin)
5254:             gnu_actual = convert (DECL_ARG_TYPE (gnu_formal), gnu_actual);
5255:         }
5256:
5257:       /* Then see if this is an unnamed parameter in a variadic C function.  */
5258:       else if (variadic)
5259:         {
5260:           /* This is based on the processing done in gnat_to_gnu_param, but
5261:              we expect the mechanism to be set in (almost) all cases.  */
5262:           const Mechanism_Type mech = Mechanism (gnat_formal);
5263:
5264:           /* Strip off possible padding type.  */
5265:           if (TYPE_IS_PADDING_P (gnu_formal_type))
5266:             gnu_formal_type = TREE_TYPE (TYPE_FIELDS (gnu_formal_type));
5267:
5268:           /* Arrays are passed as pointers to element type.  First check for
5269:              unconstrained array and get the underlying array.  */
5270:           if (TREE_CODE (gnu_formal_type) == UNCONSTRAINED_ARRAY_TYPE)
5271:             gnu_formal_type
5272:               = TREE_TYPE
5273:                 (TREE_TYPE (TYPE_FIELDS (TREE_TYPE (gnu_formal_type))));
5274:
5275:           /* Arrays are passed as pointers to element type.  */
5276:           if (mech != By_Copy && TREE_CODE (gnu_formal_type) == ARRAY_TYPE)
5277:             {
5278:               gnu_actual = maybe_padded_object (gnu_actual);
5279:               gnu_actual = maybe_unconstrained_array (gnu_actual);
5280:
5281:               /* Strip off any multi-dimensional entries, then strip
5282:                  off the last array to get the component type.  */
5283:               while (TREE_CODE (TREE_TYPE (gnu_formal_type)) == ARRAY_TYPE
5284:                      && TYPE_MULTI_ARRAY_P (TREE_TYPE (gnu_formal_type)))
5285:                 gnu_formal_type = TREE_TYPE (gnu_formal_type);
5286:
5287:               gnu_formal_type = TREE_TYPE (gnu_formal_type);
5288:               gnu_formal_type = build_pointer_type (gnu_formal_type);
5289:               gnu_actual
5290:                 = build_unary_op (ADDR_EXPR, gnu_formal_type, gnu_actual);
5291:             }
5292:
5293:           /* Fat pointers are passed as thin pointers.  */
5294:           else if (TYPE_IS_FAT_POINTER_P (gnu_formal_type))
5295:             gnu_formal_type
5296:               = make_type_from_size (gnu_formal_type,
5297:                                      size_int (POINTER_SIZE), 0);
5298:
5299:           /* If we were requested or muss pass by reference, do so.
5300:              If we were requested to pass by copy, do so.
5301:              Otherwise, pass In Out or Out parameters or aggregates by
5302:              reference.  */
5303:           else if (mech == By_Reference
5304:                    || must_pass_by_ref (gnu_formal_type)
5305:                    || (mech != By_Copy
5306:                        && (!in_param || AGGREGATE_TYPE_P (gnu_formal_type))))
5307:             {
5308:               gnu_formal_type = build_reference_type (gnu_formal_type);
5309:               gnu_actual
5310:                 = build_unary_op (ADDR_EXPR, gnu_formal_type, gnu_actual);
5311:             }
5312:
5313:           /* Otherwise pass by copy after applying default C promotions.  */
5314:           else
5315:             {
5316:               if (INTEGRAL_TYPE_P (gnu_formal_type)
5317:                   && TYPE_PRECISION (gnu_formal_type)
5318:                      < TYPE_PRECISION (integer_type_node))
5319:                 gnu_formal_type = integer_type_node;
5320:
5321:               else if (SCALAR_FLOAT_TYPE_P (gnu_formal_type)
5322:                        && TYPE_PRECISION (gnu_formal_type)
5323:                           < TYPE_PRECISION (double_type_node))
5324:                 gnu_formal_type = double_type_node;
5325:             }
5326:
5327:           gnu_actual = convert (gnu_formal_type, gnu_actual);
5328:         }
5329:
5330:       /* If we didn't create a PARM_DECL for the formal, this means that
5331:          it is an Out parameter not passed by reference and that need not
5332:          be copied in.  In this case, the value of the actual need not be
5333:          read.  However, we still need to make sure that its side-effects
5334:          are evaluated before the call, so we evaluate its address.  */
5335:       else
5336:         {
5337:           if (!in_param)
5338:             gnu_name_list = tree_cons (NULL_TREE, gnu_name, gnu_name_list);
5339:
5340:           if (TREE_SIDE_EFFECTS (gnu_name))
5341:             {
5342:               tree addr = build_unary_op (ADDR_EXPR, NULL_TREE, gnu_name);
5343:               append_to_statement_list (addr, &gnu_stmt_list);
5344:             }
5345:
5346:           continue;
5347:         }
5348:
5349:       gnu_actual_vec.safe_push (gnu_actual);
5350:     }
5351:
5352:   if (frontend_builtin)
5353:     {
5354:       tree pred_cst = build_int_cst (integer_type_node, PRED_BUILTIN_EXPECT);
5355:       enum internal_fn icode = IFN_BUILTIN_EXPECT;
5356:
5357:       switch (DECL_FE_FUNCTION_CODE (gnu_subprog))
5358:         {
5359:         case BUILT_IN_EXPECT:
5360:           break;
5361:         case BUILT_IN_LIKELY:
5362:           gnu_actual_vec.safe_push (boolean_true_node);
5363:           break;
5364:         case BUILT_IN_UNLIKELY:
5365:           gnu_actual_vec.safe_push (boolean_false_node);
5366:           break;
5367:         default:
5368:           gcc_unreachable ();
5369:         }
5370:
5371:       gnu_actual_vec.safe_push (pred_cst);
5372:
5373:       gnu_call
5374:         = build_call_expr_internal_loc_array (UNKNOWN_LOCATION,
5375:                                               icode,
5376:                                               gnu_result_type,
5377:                                               gnu_actual_vec.length (),
5378:                                               gnu_actual_vec.begin ());
5379:     }
5380:   else
5381:     {
5382:       gnu_call
5383:         = build_call_array_loc (UNKNOWN_LOCATION,
5384:                                 gnu_result_type,
5385:                                 build_unary_op (ADDR_EXPR, NULL_TREE,
5386:                                                 gnu_subprog),
5387:                                 gnu_actual_vec.length (),
5388:                                 gnu_actual_vec.begin ());
5389:       CALL_EXPR_BY_DESCRIPTOR (gnu_call) = by_descriptor;
5390:     }
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
5428:         }
5429:
5430:       /* The first entry is for the actual return value if this is a
5431:          function, so skip it.  */
5432:       if (function_call)
5433:         gnu_cico_list = TREE_CHAIN (gnu_cico_list);
5434:
5435:       if (Nkind (gnat_subprog) == N_Explicit_Dereference)
5436:         gnat_formal = First_Formal_With_Extras (Etype (gnat_subprog));
5437:       else
5438:         gnat_formal = First_Formal_With_Extras (Entity (gnat_subprog));
5439:
5440:       for (gnat_actual = First_Actual (gnat_node);
5441:            Present (gnat_actual);
5442:            gnat_formal = Next_Formal_With_Extras (gnat_formal),
5443:            gnat_actual = Next_Actual (gnat_actual))
5444:         /* If we are dealing with a copy-in/copy-out parameter, we must
5445:            retrieve its value from the record returned in the call.  */
5446:         if (!(present_gnu_tree (gnat_formal)
5447:               && TREE_CODE (get_gnu_tree (gnat_formal)) == PARM_DECL
5448:               && (DECL_BY_REF_P (get_gnu_tree (gnat_formal))
5449:                   || DECL_BY_COMPONENT_PTR_P (get_gnu_tree (gnat_formal))))
5450:             && Ekind (gnat_formal) != E_In_Parameter)
5451:           {
5452:             /* Get the value to assign to this In Out or Out parameter.  It is
5453:                either the result of the function if there is only a single such
5454:                parameter or the appropriate field from the record returned.  */
5455:             tree gnu_result
5456:               = length == 1
5457:                 ? gnu_call
5458:                 : build_component_ref (gnu_call, TREE_PURPOSE (gnu_cico_list),
5459:                                        false);
5460:
5461:             /* If the actual is a conversion, get the inner expression, which
5462:                will be the real destination, and convert the result to the
5463:                type of the actual parameter.  */
5464:             tree gnu_actual
5465:               = maybe_unconstrained_array (TREE_VALUE (gnu_name_list));
5466:
5467:             /* If the result is padded, remove the padding.  */
5468:             gnu_result = maybe_padded_object (gnu_result);
5469:
5470:             /* If the actual is a type conversion, the real target object is
5471:                denoted by the inner Expression and we need to convert the
5472:                result to the associated type.
5473:                We also need to convert our gnu assignment target to this type
5474:                if the corresponding GNU_NAME was constructed from the GNAT
5475:                conversion node and not from the inner Expression.  */
5476:             if (Nkind (gnat_actual) == N_Type_Conversion)
5477:               {
5478:                 const Node_Id gnat_expr = Expression (gnat_actual);
5479:
5480:                 gigi_checking_assert (!Do_Range_Check (gnat_expr));
5481:
5482:                 gnu_result
5483:                   = convert_with_check (Etype (gnat_expr), gnu_result,
5484:                                         Do_Overflow_Check (gnat_actual),
5485:                                         Float_Truncate (gnat_actual),
5486:                                         gnat_actual);
5487:
5488:                 if (!Is_Composite_Type (Underlying_Type (Etype (gnat_formal))))
5489:                   gnu_actual = convert (TREE_TYPE (gnu_result), gnu_actual);
5490:               }
5491:
5492:             /* Unchecked conversions as actuals for Out parameters are not
5493:                allowed in user code because they are not variables, but do
5494:                occur in front-end expansions.  The associated GNU_NAME is
5495:                always obtained from the inner expression in such cases.  */
5496:             else if (Nkind (gnat_actual) == N_Unchecked_Type_Conversion)
5497:               gnu_result = unchecked_convert (TREE_TYPE (gnu_actual),
5498:                                               gnu_result,
5499:                                               No_Truncation (gnat_actual));
5500:             else
5501:               {
5502:                 gigi_checking_assert (!Do_Range_Check (gnat_actual));
5503:
5504:                 if (!(!TREE_CONSTANT (TYPE_SIZE (TREE_TYPE (gnu_actual)))
5505:                       && TREE_CONSTANT (TYPE_SIZE (TREE_TYPE (gnu_result)))))
5506:                   gnu_result = convert (TREE_TYPE (gnu_actual), gnu_result);
5507:               }
5508:
5509:             get_atomic_access (gnat_actual, &aa_type, &aa_sync);
5510:
5511:             /* If an outer atomic access is required for an actual parameter,
5512:                build the load-modify-store sequence.  */
5513:             if (aa_type == OUTER_ATOMIC)
5514:               gnu_result
5515:                 = build_load_modify_store (gnu_actual, gnu_result, gnat_node);
5516:
5517:             /* Or else, if a simple atomic access is required, build the atomic
5518:                store.  */
5519:             else if (aa_type == SIMPLE_ATOMIC)
5520:               gnu_result
5521:                 = build_atomic_store (gnu_actual, gnu_result, aa_sync);
5522:
5523:             /* Otherwise build a regular assignment.  */
5524:             else
5525:               gnu_result = build_binary_op (MODIFY_EXPR, NULL_TREE,
5526:                                             gnu_actual, gnu_result);
5527:
5528:             if (EXPR_P (gnu_result))
5529:               set_expr_location_from_node (gnu_result, gnat_node);
5530:             append_to_statement_list (gnu_result, &gnu_stmt_list);
5531:             gnu_cico_list = TREE_CHAIN (gnu_cico_list);
5532:             gnu_name_list = TREE_CHAIN (gnu_name_list);
5533:           }
5534:     }
5535:
5536:   /* If this is a function call, the result is the call expression unless a
5537:      target is specified, in which case we copy the result into the target
5538:      and return the assignment statement.  */
5539:   if (function_call)
5540:     {
5541:       /* If this is a function with copy-in/copy-out parameters, extract the
5542:          return value from it and update the return type.  */
5543:       if (TYPE_CI_CO_LIST (gnu_subprog_type))
5544:         {
5545:           tree gnu_elmt = TYPE_CI_CO_LIST (gnu_subprog_type);
5546:           gnu_call
5547:             = build_component_ref (gnu_call, TREE_PURPOSE (gnu_elmt), false);
5548:           gnu_result_type = TREE_TYPE (gnu_call);
5549:         }
5550:
5551:       /* If the function returns by direct reference, we have to dereference
5552:          the pointer.  */
5553:       if (TYPE_RETURN_BY_DIRECT_REF_P (gnu_subprog_type))
5554:         gnu_call = build_unary_op (INDIRECT_REF, NULL_TREE, gnu_call);
5555:
5556:       if (gnu_target)
5557:         {
5558:           Node_Id gnat_parent = Parent (gnat_node);
5559:           enum tree_code op_code;
5560:
5561:           gigi_checking_assert (!Do_Range_Check (gnat_node));
5562:
5563:           /* If the parent is an initialization statement, we can use the
5564:              return slot optimization.  */
5565:           if (Nkind (gnat_parent) == N_Assignment_Statement
5566:               && (No_Ctrl_Actions (gnat_parent)
5567:                   || No_Finalize_Actions (gnat_parent)))
5568:             op_code = INIT_EXPR;
5569:
5570:           /* ??? If the return type has variable size, then force the return
5571:              slot optimization as we would not be able to create a temporary.
5572:              That's what has been done historically.  */
5573:           else if (return_type_with_variable_size_p (gnu_result_type))
5574:             op_code = INIT_EXPR;
5575:
5576:           /* If this is a call to a pure function returning an array of scalar
5577:              type, try to apply the return slot optimization.  */
5578:           else if ((TYPE_READONLY (gnu_subprog_type)
5579:                     || TYPE_RESTRICT (gnu_subprog_type))
5580:                    && is_array_of_scalar_type (gnu_result_type)
5581:                    && TYPE_MODE (gnu_result_type) == BLKmode
5582:                    && aggregate_value_p (gnu_result_type, gnu_subprog_type)
5583:                    && return_slot_opt_for_pure_call_p (gnu_target, gnu_call))
5584:             op_code = INIT_EXPR;
5585:
5586:           /* If this is the initialization of a return object in a function
5587:              returning by invisible reference, we can always use the return
5588:              slot optimization.  */
5589:           else if (TREE_CODE (gnu_target) == INDIRECT_REF
5590:                    && TREE_CODE (TREE_OPERAND (gnu_target, 0)) == RESULT_DECL
5591:                    && current_function_decl
5592:                    && TREE_ADDRESSABLE (TREE_TYPE (current_function_decl)))
5593:             op_code = INIT_EXPR;
5594:
5595:           else
5596:             op_code = MODIFY_EXPR;
5597:
5598:           /* Use the required method to move the result to the target.  */
5599:           if (atomic_access == OUTER_ATOMIC)
5600:             gnu_call
5601:               = build_load_modify_store (gnu_target, gnu_call, gnat_node);
5602:           else if (atomic_access == SIMPLE_ATOMIC)
5603:             gnu_call = build_atomic_store (gnu_target, gnu_call, atomic_sync);
5604:           else if (Present (gnat_smo)
5605:                    && Present (Storage_Model_Copy_To (gnat_smo)))
5606:             gnu_call
5607:               = build_storage_model_store (gnat_smo, gnu_target, gnu_call);
5608:           else
5609:             gnu_call
5610:               = build_binary_op (op_code, NULL_TREE, gnu_target, gnu_call);
5611:
5612:           if (EXPR_P (gnu_call))
5613:             set_expr_location_from_node (gnu_call, gnat_parent);
5614:           append_to_statement_list (gnu_call, &gnu_stmt_list);
5615:         }
5616:       else
5617:         *gnu_result_type_p = get_unpadded_type (Etype (gnat_node));
5618:     }
5619:
5620:   /* Otherwise, if this is a procedure call statement without copy-in/copy-out
5621:      parameters, the result is just the call statement.  */
5622:   else if (!TYPE_CI_CO_LIST (gnu_subprog_type))
5623:     append_to_statement_list (gnu_call, &gnu_stmt_list);
5624:
5625:   /* Finally, add the copy back statements, if any.  */
5626:   append_to_statement_list (gnu_after_list, &gnu_stmt_list);
5627:
5628:   if (went_into_elab_proc)
5629:     current_function_decl = NULL_TREE;
5630:
5631:   /* If we have pushed a binding level, pop it and finish up the enclosing
5632:      statement group.  */
5633:   if (pushed_binding_level)
5634:     {
5635:       add_stmt (gnu_stmt_list);
5636:       gnat_poplevel ();
5637:       gnu_result = end_stmt_group ();
5638:     }
5639:
5640:   /* Otherwise, retrieve the statement list, if any.  */
5641:   else if (gnu_stmt_list)
5642:     gnu_result = gnu_stmt_list;
5643:
5644:   /* Otherwise, just return the call expression.  */
5645:   else
5646:     return gnu_call;
5647:
5648:   /* If we nevertheless need a value, make a COMPOUND_EXPR to return it.
5649:      But first simplify if we have only one statement in the list.  */
5650:   if (returning_value)
5651:     {
5652:       tree first = expr_first (gnu_result), last = expr_last (gnu_result);
5653:       if (first == last)
5654:         gnu_result = first;
5655:       gnu_result
5656:         = build_compound_expr (TREE_TYPE (gnu_call), gnu_result, gnu_call);
5657:     }
5658:
5659:   return gnu_result;
5660: }
5661:
5662: /* Subroutine of gnat_to_gnu to translate GNAT_NODE, an
5663:    N_Handled_Sequence_Of_Statements, to a GCC tree, which is returned.  */
5664:
5665: static tree
5666: Handled_Sequence_Of_Statements_to_gnu (Node_Id gnat_node)
5667: {
5668:   /* If just annotating, ignore all EH and cleanups.  */
5669:   const bool eh
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

## gcc/ada/gcc-interface/trans.cc:6031–6065

```text
6031:   /* Generate code for all the inlined subprograms.  */
6032:   for (gnat_entity = First_Inlined_Subprogram (gnat_node);
6033:        Present (gnat_entity);
6034:        gnat_entity = Next_Inlined_Subprogram (gnat_entity))
6035:     {
6036:       Node_Id gnat_body;
6037:
6038:       /* Without optimization, process only the required subprograms.  */
6039:       if (!optimize && !Has_Pragma_Inline_Always (gnat_entity))
6040:         continue;
6041:
6042:       /* The set of inlined subprograms is computed from data recorded early
6043:          during expansion and it can be a strict superset of the final set
6044:          computed after semantic analysis, for example if a call to such a
6045:          subprogram occurs in a pragma Assert and assertions are disabled.
6046:          In that case, semantic analysis resets Is_Public to false but the
6047:          entry for the subprogram in the inlining tables is stalled.  */
6048:       if (!Is_Public (gnat_entity))
6049:         continue;
6050:
6051:       gnat_body = Parent (Declaration_Node (gnat_entity));
6052:       if (Nkind (gnat_body) != N_Subprogram_Body)
6053:         {
6054:           /* ??? This happens when only the spec of a package is provided.  */
6055:           if (No (Corresponding_Body (gnat_body)))
6056:             continue;
6057:
6058:           gnat_body
6059:             = Parent (Declaration_Node (Corresponding_Body (gnat_body)));
6060:         }
6061:
6062:       /* Define the entity first so we set DECL_EXTERNAL.  */
6063:       gnat_to_gnu_entity (gnat_entity, NULL_TREE, false);
6064:       add_stmt (gnat_to_gnu (gnat_body));
6065:     }
```

## gcc/ada/gcc-interface/trans.cc:6076–6095

```text
6076:   gnat_compile_time_expr_list.release ();
6077:
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

## gcc/ada/gcc-interface/trans.cc:6118–6144

```text
6118: Range_to_gnu (Node_Id gnat_range, tree *gnu_low, tree *gnu_high)
6119: {
6120:   /* GNAT_RANGE is either an N_Range or an identifier denoting a subtype.  */
6121:   switch (Nkind (gnat_range))
6122:     {
6123:     case N_Range:
6124:       *gnu_low = gnat_to_gnu (Low_Bound (gnat_range));
6125:       *gnu_high = gnat_to_gnu (High_Bound (gnat_range));
6126:       break;
6127:
6128:     case N_Expanded_Name:
6129:     case N_Identifier:
6130:       {
6131:         tree gnu_range_type = get_unpadded_type (Entity (gnat_range));
6132:         tree gnu_range_base_type = get_base_type (gnu_range_type);
6133:
6134:         *gnu_low
6135:           = convert (gnu_range_base_type, TYPE_MIN_VALUE (gnu_range_type));
6136:         *gnu_high
6137:           = convert (gnu_range_base_type, TYPE_MAX_VALUE (gnu_range_type));
6138:       }
6139:       break;
6140:
6141:     default:
6142:       gcc_unreachable ();
6143:     }
6144: }
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

## gcc/ada/gcc-interface/trans.cc:6826–6917

```text
6826:         }
6827:
6828:       if (Present (Expression (gnat_node))
6829:           && !(kind == N_Object_Declaration && No_Initialization (gnat_node))
6830:           && (!type_annotate_only
6831:               || Compile_Time_Known_Value (Expression (gnat_node))))
6832:         {
6833:           gigi_checking_assert (!Do_Range_Check (Expression (gnat_node)));
6834:
6835:           gnu_expr = gnat_to_gnu (Expression (gnat_node));
6836:
6837:           /* First deal with erroneous expressions.  */
6838:           if (TREE_CODE (gnu_expr) == ERROR_MARK)
6839:             {
6840:               /* If this is a named number for which we cannot manipulate
6841:                  the value, just skip the declaration altogether.  */
6842:               if (kind == N_Number_Declaration)
6843:                 break;
6844:               else if (type_annotate_only)
6845:                 gnu_expr = NULL_TREE;
6846:             }
6847:
6848:           /* Then a special case: we do not want the SLOC of the expression
6849:              of the tag to pop up every time it is referenced somewhere.  */
6850:           else if (EXPR_P (gnu_expr) && Is_Tag (gnat_temp))
6851:             SET_EXPR_LOCATION (gnu_expr, UNKNOWN_LOCATION);
6852:         }
6853:       else
6854:         gnu_expr = NULL_TREE;
6855:
6856:       /* If this is a deferred constant with an address clause, we ignore the
6857:          full view since the clause is on the partial view and we cannot have
6858:          2 different GCC trees for the object.  The only bits of the full view
6859:          we will use is the initializer, but it will be directly fetched.  */
6860:       if (Ekind (gnat_temp) == E_Constant
6861:           && Present (Address_Clause (gnat_temp))
6862:           && Present (Full_View (gnat_temp)))
6863:         save_gnu_tree (Full_View (gnat_temp), error_mark_node, true);
6864:
6865:       /* If this object has its elaboration delayed, we must force evaluation
6866:          of GNU_EXPR now and save it for the freeze point.  Note that we need
6867:          not do anything special at the global level since the lifetime of the
6868:          temporary is fully contained within the elaboration routine.  */
6869:       if (Present (Freeze_Node (gnat_temp)))
6870:         {
6871:           if (gnu_expr)
6872:             {
6873:               gnu_result = gnat_save_expr (gnu_expr);
6874:               save_gnu_tree (gnat_node, gnu_result, true);
6875:             }
6876:         }
6877:       else
6878:         gnat_to_gnu_entity (gnat_temp, gnu_expr, true);
6879:       break;
6880:
6881:     case N_Object_Renaming_Declaration:
6882:       gnat_temp = Defining_Entity (gnat_node);
6883:       gnu_result = alloc_stmt_list ();
6884:
6885:       /* Don't do anything if this renaming is handled by the front end and it
6886:          does not need debug info.  Note that we consider renamings don't need
6887:          debug info when optimizing: our way to describe them has a
6888:          memory/elaboration footprint.
6889:
6890:          Don't do anything neither if we are just annotating types and this
6891:          object has a composite or task type, don't elaborate it.  */
6892:       if ((!Is_Renaming_Of_Object (gnat_temp)
6893:            || (Needs_Debug_Info (gnat_temp)
6894:                && !optimize
6895:                && can_materialize_object_renaming_p
6896:                     (Renamed_Object (gnat_temp))))
6897:           && ! (type_annotate_only
6898:                 && (Is_Array_Type (Etype (gnat_temp))
6899:                     || Is_Record_Type (Etype (gnat_temp))
6900:                     || Is_Concurrent_Type (Etype (gnat_temp)))))
6901:         {
6902:           gnu_expr = gnat_to_gnu (Renamed_Object (gnat_temp));
6903:
6904:           /* The elaboration of object renamings present in the source code
6905:              never needs to be deferred.  But regular objects may be turned
6906:              into renamings during expansion and their elaboration may need
6907:              to be deferred, in which case we expect the renamed references
6908:              to have been stabilized, so we do not do it again here.  */
6909:           if (Present (Freeze_Node (gnat_temp)))
6910:             {
6911:               gcc_assert (!Comes_From_Source (gnat_node));
6912:               save_gnu_tree (gnat_node, gnu_expr, true);
6913:             }
6914:           else
6915:             gnat_to_gnu_entity (gnat_temp, gnu_expr, true);
6916:         }
6917:       break;
```

## gcc/ada/gcc-interface/trans.cc:7086–7097

```text
7086:     case N_Slice:
7087:       {
7088:         const Entity_Id gnat_array_object = Prefix (gnat_node);
7089:         tree gnu_array_object = gnat_to_gnu (gnat_array_object);
7090:
7091:         /* Get the storage model of the array.  */
7092:         gnat_smo = get_storage_model (gnat_array_object);
7093:
7094:         gnu_array_object = maybe_padded_object (gnu_array_object);
7095:         gnu_array_object = maybe_unconstrained_array (gnu_array_object);
7096:
7097:         gnu_result_type = get_unpadded_type (Etype (gnat_node));
```

## gcc/ada/gcc-interface/trans.cc:7291–7655

```text
7291:     case N_Type_Conversion:
7292:     case N_Qualified_Expression:
7293:       gnu_expr = maybe_character_value (gnat_to_gnu (Expression (gnat_node)));
7294:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
7295:
7296:       /* If this is a qualified expression for a tagged type, we mark the type
7297:          as used.  Because of polymorphism, this might be the only reference to
7298:          the tagged type in the program while objects have it as dynamic type.
7299:          The debugger needs to see it to display these objects properly.  */
7300:       if (kind == N_Qualified_Expression && Is_Tagged_Type (Etype (gnat_node)))
7301:         used_types_insert (gnu_result_type);
7302:
7303:       gigi_checking_assert (!Do_Range_Check (Expression (gnat_node)));
7304:
7305:       gnu_result
7306:         = convert_with_check (Etype (gnat_node), gnu_expr,
7307:                               Do_Overflow_Check (gnat_node),
7308:                               kind == N_Type_Conversion
7309:                               && Float_Truncate (gnat_node), gnat_node);
7310:       break;
7311:
7312:     case N_Unchecked_Type_Conversion:
7313:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
7314:       gnu_expr = maybe_character_value (gnat_to_gnu (Expression (gnat_node)));
7315:
7316:       /* Skip further processing if the conversion is deemed a no-op.  */
7317:       if (unchecked_conversion_nop (gnat_node))
7318:         {
7319:           gnu_result = gnu_expr;
7320:           gnu_result_type = TREE_TYPE (gnu_result);
7321:           break;
7322:         }
7323:
7324:       /* If the result is a pointer type, see if we are improperly
7325:          converting to a stricter alignment.  */
7326:       if (STRICT_ALIGNMENT && POINTER_TYPE_P (gnu_result_type)
7327:           && Is_Access_Type (Etype (gnat_node)))
7328:         {
7329:           unsigned int align = known_alignment (gnu_expr);
7330:           tree gnu_obj_type = TREE_TYPE (gnu_result_type);
7331:           unsigned int oalign = TYPE_ALIGN (gnu_obj_type);
7332:
7333:           /* Skip tagged types because conversions to the class-wide type are
7334:              translated into conversions to the root type, which may be less
7335:              aligned than some of its derived types.  */
7336:           if (align != 0
7337:               && align < oalign
7338:               && !type_is_tagged_or_cw_equivalent (gnu_obj_type))
7339:             post_error_ne_tree_2
7340:               ("??source alignment (^) '< alignment of & (^)",
7341:                gnat_node, Designated_Type (Etype (gnat_node)),
7342:                size_int (align / BITS_PER_UNIT), oalign / BITS_PER_UNIT);
7343:         }
7344:
7345:       /* If we are converting a descriptor to a function pointer, first
7346:          build the pointer.  */
7347:       if (TARGET_VTABLE_USES_DESCRIPTORS
7348:           && TREE_TYPE (gnu_expr) == fdesc_type_node
7349:           && POINTER_TYPE_P (gnu_result_type))
7350:         gnu_expr = build_unary_op (ADDR_EXPR, NULL_TREE, gnu_expr);
7351:
7352:       gnu_result = unchecked_convert (gnu_result_type, gnu_expr,
7353:                                       No_Truncation (gnat_node));
7354:       break;
7355:
7356:     case N_In:
7357:     case N_Not_In:
7358:       {
7359:         tree gnu_obj = gnat_to_gnu (Left_Opnd (gnat_node));
7360:         tree gnu_low, gnu_high;
7361:
7362:         Range_to_gnu (Right_Opnd (gnat_node), &gnu_low, &gnu_high);
7363:         gnu_result_type = get_unpadded_type (Etype (gnat_node));
7364:
7365:         tree gnu_op_type = maybe_character_type (TREE_TYPE (gnu_obj));
7366:         if (TREE_TYPE (gnu_obj) != gnu_op_type)
7367:           {
7368:             gnu_obj = convert (gnu_op_type, gnu_obj);
7369:             gnu_low = convert (gnu_op_type, gnu_low);
7370:             gnu_high = convert (gnu_op_type, gnu_high);
7371:           }
7372:
7373:         /* If LOW and HIGH are identical, perform an equality test.  Otherwise,
7374:            ensure that GNU_OBJ is evaluated only once and perform a full range
7375:            test.  */
7376:         if (operand_equal_p (gnu_low, gnu_high, 0))
7377:           gnu_result
7378:             = build_binary_op (EQ_EXPR, gnu_result_type, gnu_obj, gnu_low);
7379:         else
7380:           {
7381:             tree t1, t2;
7382:             gnu_obj = gnat_protect_expr (gnu_obj);
7383:             t1 = build_binary_op (GE_EXPR, gnu_result_type, gnu_obj, gnu_low);
7384:             if (EXPR_P (t1))
7385:               set_expr_location_from_node (t1, gnat_node);
7386:             t2 = build_binary_op (LE_EXPR, gnu_result_type, gnu_obj, gnu_high);
7387:             if (EXPR_P (t2))
7388:               set_expr_location_from_node (t2, gnat_node);
7389:             gnu_result
7390:               = build_binary_op (TRUTH_ANDIF_EXPR, gnu_result_type, t1, t2);
7391:           }
7392:
7393:         if (kind == N_Not_In)
7394:           gnu_result
7395:             = invert_truthvalue_loc (EXPR_LOCATION (gnu_result), gnu_result);
7396:       }
7397:       break;
7398:
7399:     case N_Op_Divide:
7400:       gnu_lhs = gnat_to_gnu (Left_Opnd (gnat_node));
7401:       gnu_rhs = gnat_to_gnu (Right_Opnd (gnat_node));
7402:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
7403:       gnu_result = build_binary_op (FLOAT_TYPE_P (gnu_result_type)
7404:                                     ? RDIV_EXPR
7405:                                     : (Rounded_Result (gnat_node)
7406:                                        ? ROUND_DIV_EXPR : TRUNC_DIV_EXPR),
7407:                                     gnu_result_type, gnu_lhs, gnu_rhs);
7408:       /* If the result type is larger than a word, then declare the dependence
7409:          on the libgcc routine.  */
7410:       if (INTEGRAL_TYPE_P (gnu_result_type)
7411:           && TYPE_PRECISION (gnu_result_type) > BITS_PER_WORD)
7412:         Check_Restriction_No_Dependence_On_System (Name_Gcc, gnat_node);
7413:       break;
7414:
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
7437:         enum tree_code code = gnu_codes[kind];
7438:         bool ignore_lhs_overflow = false;
7439:         location_t saved_location = input_location;
7440:         tree gnu_type, gnu_max_shift = NULL_TREE;
7441:
7442:         /* Fix operations set up for boolean types in GNU_CODES above.  */
7443:         if (Is_Modular_Integer_Type (Underlying_Type (Etype (gnat_node))))
7444:           switch (kind)
7445:             {
7446:             case N_Op_And:
7447:               code = BIT_AND_EXPR;
7448:               break;
7449:             case N_Op_Or:
7450:               code = BIT_IOR_EXPR;
7451:               break;
7452:             case N_Op_Xor:
7453:               code = BIT_XOR_EXPR;
7454:               break;
7455:             default:
7456:               break;
7457:             }
7458:
7459:         gnu_lhs = gnat_to_gnu (Left_Opnd (gnat_node));
7460:         gnu_rhs = gnat_to_gnu (Right_Opnd (gnat_node));
7461:         gnu_type = gnu_result_type = get_unpadded_type (Etype (gnat_node));
7462:
7463:         /* If this is a shift, take the count as unsigned since that is what
7464:            most machines do and will generate simpler adjustments below.  */
7465:         if (IN (kind, N_Op_Shift))
7466:           {
7467:             tree gnu_count_type
7468:               = gnat_unsigned_type_for (get_base_type (TREE_TYPE (gnu_rhs)));
7469:             gnu_rhs = convert (gnu_count_type, gnu_rhs);
7470:             gnu_max_shift
7471:               = convert (TREE_TYPE (gnu_rhs), TYPE_SIZE (gnu_type));
7472:             /* If the result type is larger than a word, then declare the
7473:                dependence on the libgcc routine.  */
7474:             if (TYPE_PRECISION (gnu_type) > BITS_PER_WORD)
7475:               Check_Restriction_No_Dependence_On_System (Name_Gcc, gnat_node);
7476:           }
7477:
7478:         /* If this is a comparison between (potentially) large aggregates, then
7479:            declare the dependence on the memcmp routine.  */
7480:         else if ((kind == N_Op_Eq || kind == N_Op_Ne)
7481:                  && AGGREGATE_TYPE_P (TREE_TYPE (gnu_lhs))
7482:                  && (!TREE_CONSTANT (TYPE_SIZE (TREE_TYPE (gnu_lhs)))
7483:                      || compare_tree_int (TYPE_SIZE (TREE_TYPE (gnu_lhs)),
7484:                                           2 * BITS_PER_WORD) > 0))
7485:           Check_Restriction_No_Dependence_On_System (Name_Memory_Compare,
7486:                                                      gnat_node);
7487:
7488:         /* If this is a modulo/remainder and the result type is larger than a
7489:            word, then declare the dependence on the libgcc routine.  */
7490:         else if ((kind == N_Op_Mod ||kind == N_Op_Rem)
7491:                  && TYPE_PRECISION (gnu_type) > BITS_PER_WORD)
7492:           Check_Restriction_No_Dependence_On_System (Name_Gcc, gnat_node);
7493:
7494:         /* Pending generic support for efficient vector logical operations in
7495:            GCC, convert vectors to their representative array type view.  */
7496:         gnu_lhs = maybe_vector_array (gnu_lhs);
7497:         gnu_rhs = maybe_vector_array (gnu_rhs);
7498:
7499:         /* If this is a comparison operator, convert any references to an
7500:            unconstrained array value into a reference to the actual array.  */
7501:         if (TREE_CODE_CLASS (code) == tcc_comparison)
7502:           {
7503:             gnu_lhs = maybe_unconstrained_array (gnu_lhs);
7504:             gnu_rhs = maybe_unconstrained_array (gnu_rhs);
7505:
7506:             tree gnu_op_type = maybe_character_type (TREE_TYPE (gnu_lhs));
7507:             if (TREE_TYPE (gnu_lhs) != gnu_op_type)
7508:               {
7509:                 gnu_lhs = convert (gnu_op_type, gnu_lhs);
7510:                 gnu_rhs = convert (gnu_op_type, gnu_rhs);
7511:               }
7512:           }
7513:
7514:         /* If this is a shift whose count is not guaranteed to be correct,
7515:            we need to adjust the shift count.  */
7516:         if ((kind == N_Op_Rotate_Left || kind == N_Op_Rotate_Right)
7517:             && !Shift_Count_OK (gnat_node))
7518:           gnu_rhs = build_binary_op (TRUNC_MOD_EXPR, TREE_TYPE (gnu_rhs),
7519:                                      gnu_rhs, gnu_max_shift);
7520:         else if (kind == N_Op_Shift_Right_Arithmetic
7521:                  && !Shift_Count_OK (gnat_node))
7522:           gnu_rhs
7523:             = build_binary_op (MIN_EXPR, TREE_TYPE (gnu_rhs),
7524:                                build_binary_op (MINUS_EXPR,
7525:                                                 TREE_TYPE (gnu_rhs),
7526:                                                 gnu_max_shift,
7527:                                                 build_int_cst
7528:                                                 (TREE_TYPE (gnu_rhs), 1)),
7529:                                gnu_rhs);
7530:
7531:         /* For right shifts, the type says what kind of shift to do,
7532:            so we may need to choose a different type.  In this case,
7533:            we have to ignore integer overflow lest it propagates all
7534:            the way down and causes a CE to be explicitly raised.  */
7535:         if (kind == N_Op_Shift_Right && !TYPE_UNSIGNED (gnu_type))
7536:           {
7537:             gnu_type = gnat_unsigned_type_for (gnu_type);
7538:             ignore_lhs_overflow = true;
7539:           }
7540:         else if (kind == N_Op_Shift_Right_Arithmetic
7541:                  && TYPE_UNSIGNED (gnu_type))
7542:           {
7543:             gnu_type = gnat_signed_type_for (gnu_type);
7544:             ignore_lhs_overflow = true;
7545:           }
7546:
7547:         if (gnu_type != gnu_result_type)
7548:           {
7549:             tree gnu_old_lhs = gnu_lhs;
7550:             gnu_lhs = convert (gnu_type, gnu_lhs);
7551:             if (TREE_CODE (gnu_lhs) == INTEGER_CST && ignore_lhs_overflow)
7552:               TREE_OVERFLOW (gnu_lhs) = TREE_OVERFLOW (gnu_old_lhs);
7553:             gnu_rhs = convert (gnu_type, gnu_rhs);
7554:             if (gnu_max_shift)
7555:               gnu_max_shift = convert (gnu_type, gnu_max_shift);
7556:           }
7557:
7558:         /* For integer addition, subtraction and multiplication, perform an
7559:            overflow check if required.  */
7560:         if ((code == PLUS_EXPR || code == MINUS_EXPR || code == MULT_EXPR)
7561:             && !FLOAT_TYPE_P (gnu_type)
7562:             && Do_Overflow_Check (gnat_node))
7563:           gnu_result
7564:             = build_binary_op_trapv (code, gnu_type, gnu_lhs, gnu_rhs,
7565:                                      gnat_node);
7566:
7567:           /* For an unsigned modulo operation with nonbinary constant modulus,
7568:              we first try to do a reduction by means of a (multiplier, shifter)
7569:              pair in the needed precision up to the word size.  But not when
7570:              optimizing for size, because it will be longer than a div+mul+sub
7571:              sequence.  */
7572:         else if (!optimize_size
7573:                  && (code == FLOOR_MOD_EXPR || code == TRUNC_MOD_EXPR)
7574:                  && TYPE_UNSIGNED (gnu_type)
7575:                  && TYPE_PRECISION (gnu_type) <= BITS_PER_WORD
7576:                  && TREE_CODE (gnu_rhs) == INTEGER_CST
7577:                  && !integer_pow2p (gnu_rhs)
7578:                  && (gnu_expr
7579:                      = fast_modulo_reduction (gnu_lhs, gnu_rhs,
7580:                                               TYPE_PRECISION (gnu_type))))
7581:           gnu_result = gnu_expr;
7582:
7583:         else
7584:           {
7585:             /* Some operations, e.g. comparisons of arrays, generate complex
7586:                trees that need to be annotated while they are being built.  */
7587:             input_location = saved_location;
7588:             gnu_result = build_binary_op (code, gnu_type, gnu_lhs, gnu_rhs);
7589:           }
7590:
7591:         /* If this is a logical shift with the shift count not verified,
7592:            we must return zero if it is too large.  We cannot compensate
7593:            beforehand in this case.  */
7594:         if ((kind == N_Op_Shift_Left || kind == N_Op_Shift_Right)
7595:             && !Shift_Count_OK (gnat_node))
7596:           gnu_result
7597:             = build_cond_expr (gnu_type,
7598:                                build_binary_op (GE_EXPR, boolean_type_node,
7599:                                                 gnu_rhs, gnu_max_shift),
7600:                                build_int_cst (gnu_type, 0),
7601:                                gnu_result);
7602:       }
7603:       break;
7604:
7605:     case N_If_Expression:
7606:       {
7607:         tree gnu_cond = gnat_to_gnu (First (Expressions (gnat_node)));
7608:         tree gnu_true = gnat_to_gnu (Next (First (Expressions (gnat_node))));
7609:         tree gnu_false
7610:           = gnat_to_gnu (Next (Next (First (Expressions (gnat_node)))));
7611:
7612:         gnu_result_type = get_unpadded_type (Etype (gnat_node));
7613:         gnu_result
7614:           = build_cond_expr (gnu_result_type, gnu_cond, gnu_true, gnu_false);
7615:       }
7616:       break;
7617:
7618:     case N_Op_Plus:
7619:       gnu_result = gnat_to_gnu (Right_Opnd (gnat_node));
7620:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
7621:       break;
7622:
7623:     case N_Op_Not:
7624:       /* This case can apply to a boolean or a modular type.
7625:          Fall through for a boolean operand since GNU_CODES is set
7626:          up to handle this.  */
7627:       if (Is_Modular_Integer_Type (Underlying_Type (Etype (gnat_node))))
7628:         {
7629:           gnu_expr = gnat_to_gnu (Right_Opnd (gnat_node));
7630:           gnu_result_type = get_unpadded_type (Etype (gnat_node));
7631:           gnu_result = build_unary_op (BIT_NOT_EXPR, gnu_result_type,
7632:                                        gnu_expr);
7633:           break;
7634:         }
7635:
7636:       /* ... fall through ... */
7637:
7638:     case N_Op_Minus:
7639:     case N_Op_Abs:
7640:       gnu_expr = gnat_to_gnu (Right_Opnd (gnat_node));
7641:       gnu_result_type = get_unpadded_type (Etype (gnat_node));
7642:
7643:       /* For integer negation and absolute value, perform an overflow check
7644:          if required.  */
7645:       if ((gnu_codes[kind] == NEGATE_EXPR || gnu_codes[kind] == ABS_EXPR)
7646:           && !FLOAT_TYPE_P (gnu_result_type)
7647:           && Do_Overflow_Check (gnat_node))
7648:         gnu_result
7649:           = build_unary_op_trapv (gnu_codes[kind], gnu_result_type, gnu_expr,
7650:                                   gnat_node);
7651:       else
7652:         gnu_result
7653:           = build_unary_op (gnu_codes[kind], gnu_result_type, gnu_expr);
7654:       break;
7655:
```

## gcc/ada/gcc-interface/trans.cc:7656–7725

```text
7656:     case N_Allocator:
7657:       {
7658:         const Entity_Id gnat_desig_type
7659:           = Designated_Type (Underlying_Type (Etype (gnat_node)));
7660:         const Entity_Id gnat_pool = Storage_Pool (gnat_node);
7661:
7662:         tree gnu_type, gnu_init;
7663:         bool ignore_init_type;
7664:
7665:         gnat_temp = Expression (gnat_node);
7666:
7667:         /* The expression can be either an N_Identifier or an Expanded_Name,
7668:            which must represent a type, or a N_Qualified_Expression, which
7669:            contains both the type and an initial value for the object.  */
7670:         if (Nkind (gnat_temp) == N_Identifier
7671:             || Nkind (gnat_temp) == N_Expanded_Name)
7672:           {
7673:             ignore_init_type = false;
7674:             gnu_init = NULL_TREE;
7675:             gnu_type = gnat_to_gnu_type (Entity (gnat_temp));
7676:           }
7677:
7678:         else if (Nkind (gnat_temp) == N_Qualified_Expression)
7679:           {
7680:             ignore_init_type = Has_Constrained_Partial_View (gnat_desig_type);
7681:
7682:             gnu_init = gnat_to_gnu (Expression (gnat_temp));
7683:             gnu_init = maybe_unconstrained_array (gnu_init);
7684:
7685:             gigi_checking_assert (!Do_Range_Check (Expression (gnat_temp)));
7686:
7687:             if (Is_Elementary_Type (gnat_desig_type)
7688:                 || Is_Constrained (gnat_desig_type))
7689:               gnu_type = gnat_to_gnu_type (gnat_desig_type);
7690:             else
7691:               {
7692:                 gnu_type = gnat_to_gnu_type (Etype (Expression (gnat_temp)));
7693:                 if (TREE_CODE (gnu_type) == UNCONSTRAINED_ARRAY_TYPE)
7694:                   gnu_type = TREE_TYPE (gnu_init);
7695:               }
7696:
7697:             /* See the N_Qualified_Expression case for the rationale.  */
7698:             if (Is_Tagged_Type (gnat_desig_type))
7699:               used_types_insert (gnu_type);
7700:
7701:             gnu_init = convert (gnu_type, gnu_init);
7702:           }
7703:         else
7704:           gcc_unreachable ();
7705:
7706:         /* If this is an array allocated with its bounds, use the thin pointer
7707:            as the result type to trigger the machinery in build_allocator, but
7708:            make sure not to do it for allocations on the return and secondary
7709:            stacks (see build_call_alloc_dealloc_proc for more details).  */
7710:         if (Is_Constr_Array_Subt_With_Bounds (gnat_desig_type)
7711:             && Is_Record_Type (Underlying_Type (Etype (gnat_pool)))
7712:             && !type_annotate_only)
7713:           {
7714:             tree gnu_array = gnat_to_gnu_type (Base_Type (gnat_desig_type));
7715:             gnu_result_type
7716:               = build_pointer_type (TYPE_OBJECT_RECORD_TYPE (gnu_array));
7717:           }
7718:         else
7719:           gnu_result_type = get_unpadded_type (Etype (gnat_node));
7720:
7721:         return build_allocator (gnu_type, gnu_init, gnu_result_type,
7722:                                 Procedure_To_Call (gnat_node),
7723:                                 gnat_pool, gnat_node, ignore_init_type);
7724:       }
7725:       break;
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

## gcc/ada/gcc-interface/trans.cc:9378–9406

```text
9378:       op = DECL_EXPR_DECL (expr);
9379:
9380:       /* The expressions for the RM bounds must be gimplified to ensure that
9381:          they are properly elaborated.  See gimplify_decl_expr.  */
9382:       if ((TREE_CODE (op) == TYPE_DECL || VAR_P (op))
9383:           && !TYPE_SIZES_GIMPLIFIED (TREE_TYPE (op))
9384:           && (INTEGRAL_TYPE_P (TREE_TYPE (op))
9385:               || SCALAR_FLOAT_TYPE_P (TREE_TYPE (op))))
9386:         {
9387:           tree type = TYPE_MAIN_VARIANT (TREE_TYPE (op)), t, val;
9388:
9389:           val = TYPE_RM_MIN_VALUE (type);
9390:           if (val)
9391:             {
9392:               gimplify_one_sizepos (&val, pre_p);
9393:               for (t = type; t; t = TYPE_NEXT_VARIANT (t))
9394:                 SET_TYPE_RM_MIN_VALUE (t, val);
9395:             }
9396:
9397:           val = TYPE_RM_MAX_VALUE (type);
9398:           if (val)
9399:             {
9400:               gimplify_one_sizepos (&val, pre_p);
9401:               for (t = type; t; t = TYPE_NEXT_VARIANT (t))
9402:                 SET_TYPE_RM_MAX_VALUE (t, val);
9403:             }
9404:         }
9405:       break;
9406:
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

## gcc/ada/gcc-interface/trans.cc:9846–9856

```text
9846:       /* For an object whose elaboration is deferred, the GCC tree of the
9847:          declaration, if any, is the initialization expression.  */
9848:       const Node_Id gnat_decl = Declaration_Node (gnat_entity);
9849:       tree gnu_init
9850:         = (Nkind (gnat_decl) == N_Object_Declaration
9851:            || Nkind (gnat_decl) == N_Object_Renaming_Declaration)
9852:           && Present (Freeze_Node (gnat_entity))
9853:           && present_gnu_tree (gnat_decl)
9854:           ? get_gnu_tree (gnat_decl) : NULL_TREE;
9855:
9856:       gnu_new = gnat_to_gnu_entity (gnat_entity, gnu_init, true);
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

## gcc/ada/gcc-interface/utils.cc:894–1062

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
1019:           TYPE_NAME (tt) = decl;
1020:           defer_or_set_type_context (tt,
1021:                                      DECL_CONTEXT (decl),
1022:                                      deferred_decl_context);
1023:           TREE_TYPE (decl) = tt;
1024:           if (TYPE_NAME (t)
1025:               && TREE_CODE (TYPE_NAME (t)) == TYPE_DECL
1026:               && DECL_ORIGINAL_TYPE (TYPE_NAME (t)))
1027:             DECL_ORIGINAL_TYPE (decl) = DECL_ORIGINAL_TYPE (TYPE_NAME (t));
1028:           else
1029:             DECL_ORIGINAL_TYPE (decl) = t;
1030:           /* Remark the canonical fat or extended pointer type as artificial.  */
1031:           if (TYPE_IS_FAT_POINTER_P (t) || TYPE_IS_EXTENDED_POINTER_P (t))
1032:             TYPE_ARTIFICIAL (t) = 1;
1033:           t = NULL_TREE;
1034:         }
1035:       else if (TYPE_NAME (t)
1036:                && TREE_CODE (TYPE_NAME (t)) == TYPE_DECL
1037:                && DECL_ARTIFICIAL (TYPE_NAME (t)) && !DECL_ARTIFICIAL (decl))
1038:         ;
1039:       else
1040:         t = NULL_TREE;
1041:
1042:       /* Propagate the name to all the variants, this is needed for the type
1043:          qualifiers machinery to work properly (see check_qualified_type).
1044:          Also propagate the context to them.  Note that it will be propagated
1045:          to all parallel types too thanks to gnat_set_type_context.  */
1046:       if (t)
1047:         for (t = TYPE_MAIN_VARIANT (t); t; t = TYPE_NEXT_VARIANT (t))
1048:           /* Skip it for pointer types to preserve the typedef.  */
1049:           if (!(TYPE_IS_POINTER_P (t)
1050:                 && TYPE_NAME (t)
1051:                 && TREE_CODE (TYPE_NAME (t)) == TYPE_DECL))
1052:             {
1053:               TYPE_NAME (t) = decl;
1054:               defer_or_set_type_context (t,
1055:                                          DECL_CONTEXT (decl),
1056:                                          deferred_decl_context);
1057:             }
1058:     }
1059:
1060: #undef TYPE_IS_POINTER_P
1061: }
1062:
```

## gcc/ada/gcc-interface/utils.cc:1522–1613

```text
1522: make_type_from_size (tree type, tree size_tree, bool for_biased)
1523: {
1524:   unsigned HOST_WIDE_INT size;
1525:   bool biased_p;
1526:   tree new_type;
1527:
1528:   /* If size indicates an error, just return TYPE to avoid propagating
1529:      the error.  Likewise if it's too large to represent.  */
1530:   if (!size_tree || !tree_fits_uhwi_p (size_tree))
1531:     return type;
1532:
1533:   size = tree_to_uhwi (size_tree);
1534:
1535:   switch (TREE_CODE (type))
1536:     {
1537:     case BOOLEAN_TYPE:
1538:       /* Do not mess with boolean types that have foreign convention.  */
1539:       if (TYPE_PRECISION (type) == 1 && TYPE_SIZE (type) == size_tree)
1540:         break;
1541:
1542:       /* ... fall through ... */
1543:
1544:     case INTEGER_TYPE:
1545:     case ENUMERAL_TYPE:
1546:       biased_p = (TREE_CODE (type) == INTEGER_TYPE
1547:                   && TYPE_BIASED_REPRESENTATION_P (type));
1548:
1549:       /* FOR_BIASED initially refers to the entity's representation,
1550:          not to its type's.  The type we're to return must take both
1551:          into account.  */
1552:       for_biased |= biased_p;
1553:
1554:       /* Integer types with precision 0 are forbidden.  */
1555:       if (size == 0)
1556:         size = 1;
1557:
1558:       /* Only do something if the type is not a bit-packed array type and does
1559:          not already have the proper size and the size is not too large.  */
1560:       if (BIT_PACKED_ARRAY_TYPE_P (type)
1561:           || (TYPE_PRECISION (type) == size && biased_p == for_biased)
1562:           || size > (Enable_128bit_Types ? 128 : LONG_LONG_TYPE_SIZE))
1563:         break;
1564:
1565:       /* The type should be an unsigned type if the original type is unsigned
1566:          or if the lower bound is constant and non-negative or if the type is
1567:          biased, see E_Signed_Integer_Subtype case of gnat_to_gnu_entity.  */
1568:       if (type_unsigned_for_rm (type) || for_biased)
1569:         new_type = make_unsigned_type (size);
1570:       else
1571:         new_type = make_signed_type (size);
1572:       TREE_TYPE (new_type) = TREE_TYPE (type) ? TREE_TYPE (type) : type;
1573:       SET_TYPE_RM_MIN_VALUE (new_type, TYPE_MIN_VALUE (type));
1574:       SET_TYPE_RM_MAX_VALUE (new_type, TYPE_MAX_VALUE (type));
1575:       /* Copy the name to show that it's essentially the same type and
1576:          not a subrange type.  */
1577:       TYPE_NAME (new_type) = TYPE_NAME (type);
1578:       TYPE_BIASED_REPRESENTATION_P (new_type) = for_biased;
1579:       SET_TYPE_RM_SIZE (new_type, bitsize_int (size));
1580:
1581:       return (TYPE_NAME (new_type)
1582:               ? canonicalize_sized_type (new_type)
1583:               : new_type);
1584:
1585:     case RECORD_TYPE:
1586:       /* Do something if this is a fat pointer, in which case we
1587:          may need to return the thin pointer.  */
1588:       if (TYPE_FAT_POINTER_P (type) && size < POINTER_SIZE * 2)
1589:         {
1590:           scalar_int_mode p_mode;
1591:           if (!int_mode_for_size (size, 0).exists (&p_mode)
1592:               || !targetm.valid_pointer_mode (p_mode))
1593:             p_mode = ptr_mode;
1594:           return
1595:             build_pointer_type_for_mode
1596:               (TYPE_OBJECT_RECORD_TYPE (TYPE_UNCONSTRAINED_ARRAY (type)),
1597:                p_mode, 0);
1598:         }
1599:       break;
1600:
1601:     case POINTER_TYPE:
1602:       /* Only do something if this is a thin pointer, in which case we
1603:          may need to return the fat pointer.  */
1604:       if (TYPE_IS_THIN_POINTER_P (type) && size >= POINTER_SIZE * 2)
1605:         return
1606:           build_pointer_type (TYPE_UNCONSTRAINED_ARRAY (TREE_TYPE (type)));
1607:       break;
1608:
1609:     default:
1610:       break;
1611:     }
1612:
1613:   return type;
```

## gcc/ada/gcc-interface/utils.cc:1691–1935

```text
1691:    an alignment of ALIGN, provided that it's larger than the alignment of the
1692:    element type.  This ensures that the size of the type is a multiple of its
1693:    alignment as required by the GCC type system, and alleviates the oddity of
1694:    the larger alignment, which is used to implement alignment clauses present
1695:    on unconstrained array types.  */
1696:
1697: tree
1698: maybe_pad_type (tree type, tree size, unsigned int align,
1699:                 Entity_Id gnat_entity, bool is_component_type,
1700:                 bool definition, bool set_rm_size)
1701: {
1702:   tree orig_size = TYPE_SIZE (type);
1703:   unsigned int orig_align
1704:     = TREE_CODE (type) == ARRAY_TYPE
1705:       ? TYPE_ALIGN (TREE_TYPE (type))
1706:       : TYPE_ALIGN (type);
1707:   tree record, field;
1708:
1709:   /* If TYPE is a padded type, see if it agrees with any size and alignment
1710:      we were given.  If so, return the original type.  Otherwise, strip
1711:      off the padding, since we will either be returning the inner type
1712:      or repadding it.  If no size or alignment is specified, use that of
1713:      the original padded type.  */
1714:   if (TYPE_IS_PADDING_P (type))
1715:     {
1716:       if ((!size
1717:            || operand_equal_p (round_up (size, orig_align), orig_size, 0))
1718:           && (align == 0 || align == orig_align))
1719:         return type;
1720:
1721:       if (!size)
1722:         size = orig_size;
1723:       if (align == 0)
1724:         align = orig_align;
1725:
1726:       type = TREE_TYPE (TYPE_FIELDS (type));
1727:       orig_size = TYPE_SIZE (type);
1728:       orig_align
1729:         = TREE_CODE (type) == ARRAY_TYPE
1730:           ? TYPE_ALIGN (TREE_TYPE (type))
1731:           : TYPE_ALIGN (type);
1732:     }
1733:
1734:   /* If the size is either not being changed or is being made smaller (which
1735:      is not done here and is only valid for bitfields anyway), show the size
1736:      isn't changing.  Likewise, clear the alignment if it isn't being
1737:      changed.  Then return if we aren't doing anything.  */
1738:   if (size
1739:       && (operand_equal_p (size, orig_size, 0)
1740:           || (TREE_CODE (orig_size) == INTEGER_CST
1741:               && tree_int_cst_lt (size, orig_size))))
1742:     size = NULL_TREE;
1743:
1744:   if (align == orig_align)
1745:     align = 0;
1746:
1747:   if (align == 0 && !size)
1748:     return type;
1749:
1750:   /* We used to modify the record in place in some cases, but that could
1751:      generate incorrect debugging information.  So make a new record
1752:      type and name.  */
1753:   record = make_node (RECORD_TYPE);
1754:   TYPE_PADDING_P (record) = 1;
1755:
1756:   if (Present (gnat_entity))
1757:     TYPE_NAME (record) = create_concat_name (gnat_entity, "PAD");
1758:
1759:   SET_TYPE_ALIGN (record, align ? align : orig_align);
1760:   TYPE_SIZE (record) = size ? size : orig_size;
1761:   TYPE_SIZE_UNIT (record)
1762:     = convert (sizetype,
1763:                size_binop (EXACT_DIV_EXPR, TYPE_SIZE (record),
1764:                            bitsize_unit_node));
1765:
1766:   /* If we are changing the alignment and the input type is a record with
1767:      BLKmode and a small constant size, try to make a form that has an
1768:      integral mode.  This might allow the padding record to also have an
1769:      integral mode, which will be much more efficient.  There is no point
1770:      in doing so if a size is specified unless it is also a small constant
1771:      size and it is incorrect to do so if we cannot guarantee that the mode
1772:      will be naturally aligned since the field must always be addressable.
1773:
1774:      ??? This might not always be a win when done for a stand-alone object:
1775:      since the nominal and the effective type of the object will now have
1776:      different modes, a VIEW_CONVERT_EXPR will be required for converting
1777:      between them and it might be hard to overcome afterwards, including
1778:      at the RTL level when the stand-alone object is accessed as a whole.  */
1779:   if (align > 0
1780:       && RECORD_OR_UNION_TYPE_P (type)
1781:       && !TYPE_IS_FAT_POINTER_P (type)
1782:       && !TYPE_IS_EXTENDED_POINTER_P (type)
1783:       && TYPE_MODE (type) == BLKmode
1784:       && !TYPE_BY_REFERENCE_P (type)
1785:       && TREE_CODE (orig_size) == INTEGER_CST
1786:       && !TREE_OVERFLOW (orig_size)
1787:       && compare_tree_int (orig_size, MAX_FIXED_MODE_SIZE) <= 0
1788:       && (!size
1789:           || (TREE_CODE (size) == INTEGER_CST
1790:               && compare_tree_int (size, MAX_FIXED_MODE_SIZE) <= 0)))
1791:     {
1792:       tree packable_type = make_packable_type (type, true, align);
1793:       if (TYPE_MODE (packable_type) != BLKmode
1794:           && compare_tree_int (TYPE_SIZE (packable_type), align) <= 0)
1795:         type = packable_type;
1796:     }
1797:
1798:   /* Now create the field with the original size.  */
1799:   field = create_field_decl (get_identifier ("F"), type, record, orig_size,
1800:                              bitsize_zero_node, 0, 1);
1801:   DECL_INTERNAL_P (field) = 1;
1802:
1803:   /* We will output additional debug info manually below.  */
1804:   finish_record_type (record, field, 1, false);
1805:
1806:   /* Set the RM size if requested.  */
1807:   if (set_rm_size)
1808:     {
1809:       SET_TYPE_ADA_SIZE (record, size ? size : orig_size);
1810:
1811:       /* If the padded type is complete and has constant size, we canonicalize
1812:          it by means of the hash table.  This is consistent with the language
1813:          semantics and ensures that gigi and the middle-end have a common view
1814:          of these padded types.  */
1815:       if (TREE_CONSTANT (TYPE_SIZE (record)))
1816:         {
1817:           tree canonical = canonicalize_pad_type (record);
1818:           if (canonical != record)
1819:             {
1820:               record = canonical;
1821:               goto built;
1822:             }
1823:         }
1824:     }
1825:
1826:   /* Make the inner type the debug type of the padded type.  */
1827:   if (gnat_encodings != DWARF_GNAT_ENCODINGS_ALL)
1828:     SET_TYPE_DEBUG_TYPE (record, maybe_debug_type (type));
1829:
1830:   /* Unless debugging information isn't being written for the input type,
1831:      write a record that shows what we are a subtype of and also make a
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
1860:          few encodings as possible: regular debugging infomation makes this
1861:          redundant.  */
1862:       if (gnat_encodings == DWARF_GNAT_ENCODINGS_ALL)
1863:         {
1864:           tree marker = make_node (RECORD_TYPE);
1865:           tree orig_name = TYPE_IDENTIFIER (type);
1866:
1867:           TYPE_NAME (marker) = concat_name (name, "XVS");
1868:           finish_record_type (marker,
1869:                               create_field_decl (orig_name,
1870:                                                  build_reference_type (type),
1871:                                                  marker, NULL_TREE, NULL_TREE,
1872:                                                  0, 0),
1873:                               0, true);
1874:           TYPE_SIZE_UNIT (marker) = size_unit;
1875:
1876:           add_parallel_type (record, marker);
1877:         }
1878:     }
1879:
1880: built:
1881:   /* If a simple size was explicitly given, maybe issue a warning.  */
1882:   if (!size
1883:       || TREE_CODE (size) == COND_EXPR
1884:       || TREE_CODE (size) == MAX_EXPR
1885:       || No (gnat_entity))
1886:     return record;
1887:
1888:   /* But don't do it if we are just annotating types and the type is tagged or
1889:      concurrent, since these types aren't fully laid out in this mode.  */
1890:   if (type_annotate_only)
1891:     {
1892:       Entity_Id gnat_type
1893:         = is_component_type
1894:           ? Component_Type (gnat_entity) : Etype (gnat_entity);
1895:
1896:       if (Is_Tagged_Type (gnat_type) || Is_Concurrent_Type (gnat_type))
1897:         return record;
1898:     }
1899:
1900:   /* Take the original size as the maximum size of the input if there was an
1901:      unconstrained record involved and round it up to the specified alignment,
1902:      if one was specified, but only for aggregate types.  */
1903:   if (CONTAINS_PLACEHOLDER_P (orig_size))
1904:     orig_size = max_size (orig_size, true);
1905:
1906:   if (align && AGGREGATE_TYPE_P (type))
1907:     orig_size = round_up (orig_size, align);
1908:
1909:   if (!operand_equal_p (size, orig_size, 0)
1910:       && !(TREE_CODE (size) == INTEGER_CST
1911:            && TREE_CODE (orig_size) == INTEGER_CST
1912:            && (TREE_OVERFLOW (size)
1913:                || TREE_OVERFLOW (orig_size)
1914:                || tree_int_cst_lt (size, orig_size))))
1915:     {
1916:       Node_Id gnat_error_node;
1917:
1918:       /* For a packed array, post the message on the original array type.  */
1919:       if (Is_Packed_Array_Impl_Type (gnat_entity))
1920:         gnat_entity = Original_Array_Type (gnat_entity);
1921:
1922:       if ((Ekind (gnat_entity) == E_Component
1923:            || Ekind (gnat_entity) == E_Discriminant)
1924:           && Present (Component_Clause (gnat_entity)))
1925:         gnat_error_node = Last_Bit (Component_Clause (gnat_entity));
1926:       else if (Has_Size_Clause (gnat_entity))
1927:         gnat_error_node = Expression (Size_Clause (gnat_entity));
1928:       else if (Has_Object_Size_Clause (gnat_entity))
1929:         gnat_error_node = Expression (Object_Size_Clause (gnat_entity));
1930:       else
1931:         gnat_error_node = Empty;
1932:
1933:       /* Generate message only for entities that come from source, since
1934:          if we have an entity created by expansion, the message will be
1935:          generated for some other corresponding source entity.  */
```

## gcc/ada/gcc-interface/utils.cc:2861–2894

```text
2861: create_index_type (tree min, tree max, tree index, Node_Id gnat_node)
2862: {
2863:   /* First build a type for the desired range.  */
2864:   tree type = build_nonshared_range_type (sizetype, min, max);
2865:
2866:   /* Then set the index type.  */
2867:   SET_TYPE_INDEX_TYPE (type, index);
2868:   create_type_decl (NULL_TREE, type, true, false, gnat_node);
2869:
2870:   return type;
2871: }
2872:
2873: /* Return a subtype of TYPE with range MIN to MAX.  If TYPE is NULL,
2874:    sizetype is used.  */
2875:
2876: tree
2877: create_range_type (tree type, tree min, tree max)
2878: {
2879:   tree range_type;
2880:
2881:   if (!type)
2882:     type = sizetype;
2883:
2884:   /* First build a type with the base range.  */
2885:   range_type = build_nonshared_range_type (type, TYPE_MIN_VALUE (type),
2886:                                                  TYPE_MAX_VALUE (type));
2887:
2888:   /* Then set the actual range.  */
2889:   SET_TYPE_RM_MIN_VALUE (range_type, min);
2890:   SET_TYPE_RM_MAX_VALUE (range_type, max);
2891:
2892:   return range_type;
2893: }
2894:
```

## gcc/ada/gcc-interface/utils.cc:2918–3133

```text
2918: {
2919:   tree type_decl = build_decl (input_location, TYPE_DECL, name, type);
2920:   DECL_ARTIFICIAL (type_decl) = 1;
2921:   DECL_NAMELESS (type_decl) = gnat_encodings != DWARF_GNAT_ENCODINGS_ALL;
2922:   TYPE_ARTIFICIAL (type) = 1;
2923:   return type_decl;
2924: }
2925:
2926: /* Return a TYPE_DECL node for TYPE.  NAME gives the name of the type to be
2927:    used in the declaration.  ARTIFICIAL_P is true if the declaration was
2928:    generated by the compiler.  DEBUG_INFO_P is true if we need to write
2929:    debug information about this type.  GNAT_NODE is used for the position
2930:    of the decl.  Normally, an artificial type might be marked as
2931:    nameless.  However, if CAN_BE_NAMELESS is false, this marking is
2932:    disabled and the name will always be attached for the type.  */
2933:
2934: tree
2935: create_type_decl (tree name, tree type, bool artificial_p, bool debug_info_p,
2936:                   Node_Id gnat_node, bool can_be_nameless)
2937: {
2938:   enum tree_code code = TREE_CODE (type);
2939:   bool is_named
2940:     = TYPE_NAME (type) && TREE_CODE (TYPE_NAME (type)) == TYPE_DECL;
2941:   tree type_decl;
2942:
2943:   /* Only the builtin TYPE_STUB_DECL should be used for dummy types.  */
2944:   gcc_assert (!TYPE_IS_DUMMY_P (type));
2945:
2946:   /* If the type hasn't been named yet, we're naming it; preserve an existing
2947:      TYPE_STUB_DECL that has been attached to it for some purpose.  */
2948:   if (!is_named && TYPE_STUB_DECL (type))
2949:     {
2950:       type_decl = TYPE_STUB_DECL (type);
2951:       DECL_NAME (type_decl) = name;
2952:     }
2953:   else
2954:     type_decl = build_decl (input_location, TYPE_DECL, name, type);
2955:
2956:   DECL_ARTIFICIAL (type_decl) = artificial_p;
2957:   TYPE_ARTIFICIAL (type) = artificial_p;
2958:   DECL_NAMELESS (type_decl) = (artificial_p
2959:                                && can_be_nameless
2960:                                && gnat_encodings != DWARF_GNAT_ENCODINGS_ALL);
2961:
2962:   /* Add this decl to the current binding level.  */
2963:   gnat_pushdecl (type_decl, gnat_node);
2964:
2965:   /* If we're naming the type, equate the TYPE_STUB_DECL to the name.  This
2966:      causes the name to be also viewed as a "tag" by the debug back-end, with
2967:      the advantage that no DW_TAG_typedef is emitted for artificial "tagged"
2968:      types in DWARF.
2969:
2970:      Note that if "type" is used as a DECL_ORIGINAL_TYPE, it may be referenced
2971:      from multiple contexts, and "type_decl" references a copy of it: in such a
2972:      case, do not mess TYPE_STUB_DECL: we do not want to re-use the TYPE_DECL
2973:      with the mechanism above.  */
2974:   if (!is_named && type != DECL_ORIGINAL_TYPE (type_decl))
2975:     TYPE_STUB_DECL (type) = type_decl;
2976:
2977:   /* Do not generate debug info for UNCONSTRAINED_ARRAY_TYPE that the
2978:      back-end doesn't support, and for others if we don't need to.  */
2979:   if (code == UNCONSTRAINED_ARRAY_TYPE || !debug_info_p)
2980:     DECL_IGNORED_P (type_decl) = 1;
2981:
2982:   return type_decl;
2983: }
2984:
2985: /* Return a VAR_DECL or CONST_DECL node.
2986:
2987:    NAME gives the name of the variable.  ASM_NAME is its assembler name
2988:    (if provided).  TYPE is its data type (a GCC ..._TYPE node).  INIT is
2989:    the GCC tree for an optional initial expression; NULL_TREE if none.
2990:
2991:    CONST_FLAG is true if this variable is constant, in which case we might
2992:    return a CONST_DECL node unless CONST_DECL_ALLOWED_P is false.
2993:
2994:    PUBLIC_FLAG is true if this is for a reference to a public entity or for a
2995:    definition to be made visible outside of the current compilation unit, for
2996:    instance variable definitions in a package specification.
2997:
2998:    LINKONCE_FLAG is true if the entity can be defined in multiple compilation
2999:    units without generating a linker error.
3000:
3001:    EXTERN_FLAG is true when processing an external variable declaration (as
3002:    opposed to a definition: no storage is to be allocated for the variable).
3003:
3004:    STATIC_FLAG is only relevant when not at top level and indicates whether
3005:    to always allocate storage to the variable.
3006:
3007:    VOLATILE_FLAG is true if this variable is declared as volatile.
3008:
3009:    ARTIFICIAL_P is true if the variable was generated by the compiler.
3010:
3011:    DEBUG_INFO_P is true if we need to write debug information for it.
3012:
3013:    ATTR_LIST is the list of attributes to be attached to the variable.
3014:
3015:    GNAT_NODE is used for the position of the decl.  */
3016:
3017: tree
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
3058:   /* Detect constants created by the front-end to hold 'reference to function
3059:      calls for stabilization purposes.  This is needed for renaming.  */
3060:   if (const_flag && init && POINTER_TYPE_P (type))
3061:     {
3062:       tree inner = init;
3063:       if (TREE_CODE (inner) == COMPOUND_EXPR)
3064:         inner = TREE_OPERAND (inner, 1);
3065:       inner = remove_conversions (inner, true);
3066:       if (TREE_CODE (inner) == ADDR_EXPR
3067:           && ((TREE_CODE (TREE_OPERAND (inner, 0)) == CALL_EXPR
3068:                && !call_is_atomic_load (TREE_OPERAND (inner, 0)))
3069:               || (VAR_P (TREE_OPERAND (inner, 0))
3070:                   && DECL_RETURN_VALUE_P (TREE_OPERAND (inner, 0)))))
3071:         DECL_RETURN_VALUE_P (var_decl) = 1;
3072:     }
3073:
3074:   /* If this is external, throw away any initializations (they will be done
3075:      elsewhere) unless this is a constant for which we would like to remain
3076:      able to get the initializer.  If we are defining a global here, leave a
3077:      constant initialization and save any variable elaborations for the
3078:      elaboration routine.  If we are just annotating types, throw away the
3079:      initialization if it isn't a constant.  */
3080:   if ((extern_flag && !constant_p)
3081:       || (type_annotate_only && init && !TREE_CONSTANT (init)))
3082:     init = NULL_TREE;
3083:
3084:   /* At the global level, a non-constant initializer generates elaboration
3085:      statements.  Check that such statements are allowed, that is to say,
3086:      not violating a No_Elaboration_Code restriction.  */
3087:   if (init && !init_const && global_bindings_p ())
3088:     Check_Elaboration_Code_Allowed (gnat_node);
3089:
3090:   /* Attach the initializer, if any.  */
3091:   DECL_INITIAL (var_decl) = init;
3092:
3093:   /* Directly set some flags.  */
3094:   DECL_ARTIFICIAL (var_decl) = artificial_p;
3095:   DECL_EXTERNAL (var_decl) = extern_flag;
3096:
3097:   TREE_CONSTANT (var_decl) = constant_p;
3098:   TREE_READONLY (var_decl) = const_flag;
3099:
3100:   /* The object is public if it is external or if it is declared public
3101:      and has static storage duration.  */
3102:   TREE_PUBLIC (var_decl) = extern_flag || (public_flag && static_storage);
3103:
3104:   /* We need to allocate static storage for an object with static storage
3105:      duration if it isn't external.  */
3106:   TREE_STATIC (var_decl) = !extern_flag && static_storage;
3107:
3108:   TREE_SIDE_EFFECTS (var_decl)
3109:     = TREE_THIS_VOLATILE (var_decl)
3110:     = TYPE_VOLATILE (type) | volatile_flag;
3111:
3112:   if (TREE_SIDE_EFFECTS (var_decl))
3113:     TREE_ADDRESSABLE (var_decl) = 1;
3114:
3115:   /* Ada doesn't feature Fortran-like COMMON variables so we shouldn't
3116:      try to fiddle with DECL_COMMON.  However, on platforms that don't
3117:      support global BSS sections, uninitialized global variables would
3118:      go in DATA instead, thus increasing the size of the executable.  */
3119:   if (!flag_no_common
3120:       && VAR_P (var_decl)
3121:       && TREE_PUBLIC (var_decl)
3122:       && !have_global_bss_p ())
3123:     DECL_COMMON (var_decl) = 1;
3124:
3125:   /* Do not emit debug info if not requested, or for an external constant whose
3126:      initializer is not absolute because this would require a global relocation
3127:      in a read-only section which runs afoul of the PE-COFF run-time relocation
3128:      mechanism.  */
3129:   if (!debug_info_p
3130:       || (extern_flag
3131:           && constant_p
3132:           && init
3133:           && initializer_constant_valid_p (init, TREE_TYPE (init))
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

## gcc/ada/gcc-interface/utils.cc:4401–4460

```text
4401: build_template (tree template_type, tree array_type, tree expr)
4402: {
4403:   vec<constructor_elt, va_gc> *template_elts = NULL;
4404:   tree bound_list = NULL_TREE;
4405:   tree field;
4406:
4407:   while (TREE_CODE (array_type) == RECORD_TYPE
4408:          && (TYPE_PADDING_P (array_type)
4409:              || TYPE_JUSTIFIED_MODULAR_P (array_type)))
4410:     array_type = TREE_TYPE (TYPE_FIELDS (array_type));
4411:
4412:   if (TREE_CODE (array_type) == ARRAY_TYPE
4413:       || (TREE_CODE (array_type) == INTEGER_TYPE
4414:           && TYPE_HAS_ACTUAL_BOUNDS_P (array_type)))
4415:     bound_list = TYPE_ACTUAL_BOUNDS (array_type);
4416:
4417:   /* First make the list for a CONSTRUCTOR for the template.  Go down
4418:      the field list of the template instead of the type chain because
4419:      this array might be an Ada array of array and we can't tell where
4420:      the nested array stop being the underlying object.  */
4421:   for (field = TYPE_FIELDS (template_type);
4422:        field;
4423:        field = DECL_CHAIN (DECL_CHAIN (field)))
4424:     {
4425:       tree bounds, min, max;
4426:
4427:       /* If we have a bound list, get the bounds from there.  Likewise
4428:          for an ARRAY_TYPE.  Otherwise, if expr is a PARM_DECL with
4429:          DECL_BY_COMPONENT_PTR_P, use the bounds of the field in the
4430:          template, but this will only give us a maximum range.  */
4431:       if (bound_list)
4432:         {
4433:           bounds = TREE_VALUE (bound_list);
4434:           bound_list = TREE_CHAIN (bound_list);
4435:         }
4436:       else if (TREE_CODE (array_type) == ARRAY_TYPE)
4437:         {
4438:           bounds = TYPE_INDEX_TYPE (TYPE_DOMAIN (array_type));
4439:           array_type = TREE_TYPE (array_type);
4440:         }
4441:       else if (expr && TREE_CODE (expr) == PARM_DECL
4442:                && DECL_BY_COMPONENT_PTR_P (expr))
4443:         bounds = TREE_TYPE (field);
4444:       else
4445:         gcc_unreachable ();
4446:
4447:       min = convert (TREE_TYPE (field), TYPE_MIN_VALUE (bounds));
4448:       max = convert (TREE_TYPE (DECL_CHAIN (field)), TYPE_MAX_VALUE (bounds));
4449:
4450:       /* If either MIN or MAX involve a PLACEHOLDER_EXPR, we must
4451:          substitute it from OBJECT.  */
4452:       min = SUBSTITUTE_PLACEHOLDER_IN_EXPR (min, expr);
4453:       max = SUBSTITUTE_PLACEHOLDER_IN_EXPR (max, expr);
4454:
4455:       CONSTRUCTOR_APPEND_ELT (template_elts, field, min);
4456:       CONSTRUCTOR_APPEND_ELT (template_elts, DECL_CHAIN (field), max);
4457:     }
4458:
4459:   return gnat_build_constructor (template_type, template_elts);
4460: }
```

## gcc/ada/gcc-interface/utils.cc:4794–4905

```text
4794: convert_to_fat_pointer (tree type, tree expr)
4795: {
4796:   tree template_type = TREE_TYPE (TREE_TYPE (DECL_CHAIN (TYPE_FIELDS (type))));
4797:   tree p_array_type = TREE_TYPE (TYPE_FIELDS (type));
4798:   tree etype = TREE_TYPE (expr);
4799:   tree template_addr;
4800:   vec<constructor_elt, va_gc> *v;
4801:   vec_alloc (v, 2);
4802:
4803:   /* We don't allow conversion from extended to fat pointers.  */
4804:   gcc_assert (!TYPE_IS_EXTENDED_POINTER_P (etype));
4805:
4806:   /* If EXPR is null, make a fat pointer that contains a null pointer to the
4807:      array (compare_fat_pointers ensures that this is the full discriminant)
4808:      and a valid pointer to the bounds.  This latter property is necessary
4809:      since the compiler can hoist the load of the bounds done through it.  */
4810:   if (integer_zerop (expr))
4811:     {
4812:       tree ptr_template_type = TREE_TYPE (DECL_CHAIN (TYPE_FIELDS (type)));
4813:       tree null_bounds, t;
4814:
4815:       if (TYPE_NULL_BOUNDS (ptr_template_type))
4816:         null_bounds = TYPE_NULL_BOUNDS (ptr_template_type);
4817:       else
4818:         {
4819:           /* The template type can still be dummy at this point so we build an
4820:              empty constructor.  The middle-end will fill it in with zeros.  */
4821:           t = build_constructor (template_type, NULL);
4822:           TREE_CONSTANT (t) = TREE_STATIC (t) = 1;
4823:           null_bounds = build_unary_op (ADDR_EXPR, NULL_TREE, t);
4824:           SET_TYPE_NULL_BOUNDS (ptr_template_type, null_bounds);
4825:         }
4826:
4827:       CONSTRUCTOR_APPEND_ELT (v, TYPE_FIELDS (type),
4828:                               fold_convert (p_array_type, null_pointer_node));
4829:       CONSTRUCTOR_APPEND_ELT (v, DECL_CHAIN (TYPE_FIELDS (type)), null_bounds);
4830:       t = build_constructor (type, v);
4831:       /* Do not set TREE_CONSTANT so as to force T to static memory.  */
4832:       TREE_CONSTANT (t) = 0;
4833:       TREE_STATIC (t) = 1;
4834:
4835:       return t;
4836:     }
4837:
4838:   /* If EXPR is a thin pointer, make template and data from the record.  */
4839:   if (TYPE_IS_THIN_POINTER_P (etype))
4840:     {
4841:       tree field = TYPE_FIELDS (TREE_TYPE (etype));
4842:
4843:       expr = gnat_protect_expr (expr);
4844:
4845:       /* If we have a TYPE_UNCONSTRAINED_ARRAY attached to the RECORD_TYPE,
4846:          the thin pointer value has been shifted so we shift it back to get
4847:          the template address.  */
4848:       if (TYPE_UNCONSTRAINED_ARRAY (TREE_TYPE (etype)))
4849:         {
4850:           template_addr
4851:             = build_binary_op (POINTER_PLUS_EXPR, etype, expr,
4852:                                fold_build1 (NEGATE_EXPR, sizetype,
4853:                                             byte_position
4854:                                             (DECL_CHAIN (field))));
4855:           template_addr
4856:             = fold_convert (TREE_TYPE (DECL_CHAIN (TYPE_FIELDS (type))),
4857:                             template_addr);
4858:         }
4859:
4860:       /* Otherwise we explicitly take the address of the fields.  */
4861:       else
4862:         {
4863:           expr = build_unary_op (INDIRECT_REF, NULL_TREE, expr);
4864:           template_addr
4865:             = build_unary_op (ADDR_EXPR, NULL_TREE,
4866:                               build_component_ref (expr, field, false));
4867:           expr = build_unary_op (ADDR_EXPR, NULL_TREE,
4868:                                  build_component_ref (expr, DECL_CHAIN (field),
4869:                                                       false));
4870:         }
4871:     }
4872:
4873:   /* Otherwise, build the constructor for the template.  */
4874:   else
4875:     template_addr
4876:       = build_unary_op (ADDR_EXPR, NULL_TREE,
4877:                         build_template (template_type, TREE_TYPE (etype),
4878:                                         expr));
4879:
4880:   /* The final result is a constructor for the fat pointer.
4881:
4882:      If EXPR is an argument of a foreign convention subprogram, the type it
4883:      points to is directly the component type.  In this case, the expression
4884:      type may not match the corresponding FIELD_DECL type at this point, so we
4885:      call "convert" here to fix that up if necessary.  This type consistency is
4886:      required, for instance because it ensures that possible later folding of
4887:      COMPONENT_REFs against this constructor always yields something of the
4888:      same type as the initial reference.
4889:
4890:      Note that the call to "build_template" above is still fine because it
4891:      will only refer to the provided TEMPLATE_TYPE in this case.  */
4892:   CONSTRUCTOR_APPEND_ELT (v, TYPE_FIELDS (type), convert (p_array_type, expr));
4893:   CONSTRUCTOR_APPEND_ELT (v, DECL_CHAIN (TYPE_FIELDS (type)), template_addr);
4894:   return gnat_build_constructor (type, v);
4895: }
4896:
4897: /* Convert EXPR, a pointer to a constrained array, into a pointer to an
4898:    unconstrained one using an extended access.  This involves making or
4899:    finding a template. */
4900:
4901: static tree
4902: convert_to_extended_pointer (tree type, tree expr)
4903: {
4904:   tree template_type = TREE_TYPE (DECL_CHAIN (TYPE_FIELDS (type)));
4905:   tree p_array_type = TREE_TYPE (TYPE_FIELDS (type));
```

## gcc/ada/gcc-interface/utils.cc:5009–5635

```text
5009:   /* If both input and output have padding and are of variable size, do this
5010:      as an unchecked conversion.  Likewise if one is a mere variant of the
5011:      other, so we avoid a pointless unpad/repad sequence.  */
5012:   else if (code == RECORD_TYPE && ecode == RECORD_TYPE
5013:            && TYPE_PADDING_P (type) && TYPE_PADDING_P (etype)
5014:            && (!TREE_CONSTANT (TYPE_SIZE (type))
5015:                || !TREE_CONSTANT (TYPE_SIZE (etype))
5016:                || TYPE_MAIN_VARIANT (type) == TYPE_MAIN_VARIANT (etype)
5017:                || TYPE_NAME (TREE_TYPE (TYPE_FIELDS (type)))
5018:                   == TYPE_NAME (TREE_TYPE (TYPE_FIELDS (etype)))))
5019:     ;
5020:
5021:   /* If the output type has padding, convert to the inner type and make a
5022:      constructor to build the record, unless a variable size is involved.  */
5023:   else if (code == RECORD_TYPE && TYPE_PADDING_P (type))
5024:     {
5025:       /* If we previously converted from another type and our type is
5026:          of variable size, remove the conversion to avoid the need for
5027:          variable-sized temporaries.  Likewise for a conversion between
5028:          original and packable version.  */
5029:       if (TREE_CODE (expr) == VIEW_CONVERT_EXPR
5030:           && (!TREE_CONSTANT (TYPE_SIZE (type))
5031:               || (ecode == RECORD_TYPE
5032:                   && TYPE_NAME (etype)
5033:                      == TYPE_NAME (TREE_TYPE (TREE_OPERAND (expr, 0))))))
5034:         expr = TREE_OPERAND (expr, 0);
5035:
5036:       /* If we are just removing the padding from expr, convert the original
5037:          object if we have variable size in order to avoid the need for some
5038:          variable-sized temporaries.  Likewise if the padding is a variant
5039:          of the other, so we avoid a pointless unpad/repad sequence.  */
5040:       if (TREE_CODE (expr) == COMPONENT_REF
5041:           && TYPE_IS_PADDING_P (TREE_TYPE (TREE_OPERAND (expr, 0)))
5042:           && (!TREE_CONSTANT (TYPE_SIZE (type))
5043:               || TYPE_MAIN_VARIANT (type)
5044:                  == TYPE_MAIN_VARIANT (TREE_TYPE (TREE_OPERAND (expr, 0)))
5045:               || (ecode == RECORD_TYPE
5046:                   && TYPE_NAME (etype)
5047:                      == TYPE_NAME (TREE_TYPE (TYPE_FIELDS (type))))))
5048:         return convert (type, TREE_OPERAND (expr, 0));
5049:
5050:       /* If the inner type is of self-referential size and the expression type
5051:          is a record, do this as an unchecked conversion unless both types are
5052:          essentially the same.  */
5053:       if (ecode == RECORD_TYPE
5054:           && CONTAINS_PLACEHOLDER_P (DECL_SIZE (TYPE_FIELDS (type)))
5055:           && TYPE_MAIN_VARIANT (etype)
5056:              != TYPE_MAIN_VARIANT (TREE_TYPE (TYPE_FIELDS (type))))
5057:         return unchecked_convert (type, expr, false);
5058:
5059:       /* If we are converting between array types with variable size, do the
5060:          final conversion as an unchecked conversion, again to avoid the need
5061:          for some variable-sized temporaries.  If valid, this conversion is
5062:          very likely purely technical and without real effects.  */
5063:       if (ecode == ARRAY_TYPE
5064:           && TREE_CODE (TREE_TYPE (TYPE_FIELDS (type))) == ARRAY_TYPE
5065:           && !TREE_CONSTANT (TYPE_SIZE (etype))
5066:           && !TREE_CONSTANT (TYPE_SIZE (type)))
5067:         return unchecked_convert (type,
5068:                                   convert (TREE_TYPE (TYPE_FIELDS (type)),
5069:                                            expr),
5070:                                   false);
5071:
5072:       tree t = convert (TREE_TYPE (TYPE_FIELDS (type)), expr);
5073:
5074:       /* If converting to the inner type has already created a CONSTRUCTOR with
5075:          the right size, then reuse it instead of creating another one.  This
5076:          can happen for the padding type built to overalign local variables.  */
5077:       if (TREE_CODE (t) == VIEW_CONVERT_EXPR
5078:           && TREE_CODE (TREE_OPERAND (t, 0)) == CONSTRUCTOR
5079:           && TREE_CONSTANT (TYPE_SIZE (TREE_TYPE (TREE_OPERAND (t, 0))))
5080:           && tree_int_cst_equal (TYPE_SIZE (type),
5081:                                  TYPE_SIZE (TREE_TYPE (TREE_OPERAND (t, 0)))))
5082:         return build1 (VIEW_CONVERT_EXPR, type, TREE_OPERAND (t, 0));
5083:
5084:       vec<constructor_elt, va_gc> *v;
5085:       vec_alloc (v, 1);
5086:       CONSTRUCTOR_APPEND_ELT (v, TYPE_FIELDS (type), t);
5087:       return gnat_build_constructor (type, v);
5088:     }
5089:
5090:   /* If the input type has padding, remove it and convert to the output type.
5091:      The conditions ordering is arranged to ensure that the output type is not
5092:      a padding type here, as it is not clear whether the conversion would
5093:      always be correct if this was to happen.  */
5094:   else if (ecode == RECORD_TYPE && TYPE_PADDING_P (etype))
5095:     {
5096:       tree unpadded;
5097:
5098:       /* If we have just converted to this padded type, just get the
5099:          inner expression.  */
5100:       if (TREE_CODE (expr) == CONSTRUCTOR)
5101:         unpadded = CONSTRUCTOR_ELT (expr, 0)->value;
5102:
5103:       /* Otherwise, build an explicit component reference.  */
5104:       else
5105:         unpadded = build_component_ref (expr, TYPE_FIELDS (etype), false);
5106:
5107:       return convert (type, unpadded);
5108:     }
5109:
5110:   /* If the input is a biased type, convert first to the base type and add
5111:      the bias.  Note that the bias must go through a full conversion to the
5112:      base type, lest it is itself a biased value; this happens for subtypes
5113:      of biased types.  */
5114:   if (ecode == INTEGER_TYPE && TYPE_BIASED_REPRESENTATION_P (etype))
5115:     return convert (type, fold_build2 (PLUS_EXPR, TREE_TYPE (etype),
5116:                                        fold_convert (TREE_TYPE (etype), expr),
5117:                                        convert (TREE_TYPE (etype),
5118:                                                 TYPE_MIN_VALUE (etype))));
5119:
5120:   /* If the input is a justified modular type, we need to extract the actual
5121:      object before converting it to an other type with the exceptions of an
5122:      [unconstrained] array or a mere type variant.  It is useful to avoid
5123:      the extraction and conversion in these cases because it could end up
5124:      replacing a VAR_DECL by a constructor and we might be about the take
5125:      the address of the result.  */
5126:   if (ecode == RECORD_TYPE && TYPE_JUSTIFIED_MODULAR_P (etype)
5127:       && code != ARRAY_TYPE
5128:       && code != UNCONSTRAINED_ARRAY_TYPE
5129:       && TYPE_MAIN_VARIANT (type) != TYPE_MAIN_VARIANT (etype))
5130:     return
5131:       convert (type, build_component_ref (expr, TYPE_FIELDS (etype), false));
5132:
5133:   /* If converting to a type that contains a template, convert to the data
5134:      type and then build the template. */
5135:   if (code == RECORD_TYPE && TYPE_CONTAINS_TEMPLATE_P (type))
5136:     {
5137:       tree obj_type = TREE_TYPE (DECL_CHAIN (TYPE_FIELDS (type)));
5138:       vec<constructor_elt, va_gc> *v;
5139:       vec_alloc (v, 2);
5140:
5141:       /* If the source already has a template, get a reference to the
5142:          associated array only, as we are going to rebuild a template
5143:          for the target type anyway.  */
5144:       expr = maybe_unconstrained_array (expr);
5145:
5146:       CONSTRUCTOR_APPEND_ELT (v, TYPE_FIELDS (type),
5147:                               build_template (TREE_TYPE (TYPE_FIELDS (type)),
5148:                                               obj_type, NULL_TREE));
5149:       if (expr)
5150:         CONSTRUCTOR_APPEND_ELT (v, DECL_CHAIN (TYPE_FIELDS (type)),
5151:                                 convert (obj_type, expr));
5152:       return gnat_build_constructor (type, v);
5153:     }
5154:
5155:   /* There are some cases of expressions that we process specially.  */
5156:   switch (TREE_CODE (expr))
5157:     {
5158:     case ERROR_MARK:
5159:       return expr;
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
5185:       if (code == ecode && gnat_types_compatible_p (type, etype))
5186:         {
5187:           expr = copy_node (expr);
5188:           TREE_TYPE (expr) = type;
5189:           return expr;
5190:         }
5191:       break;
5192:
5193:     case CONSTRUCTOR:
5194:       /* If we are converting a CONSTRUCTOR to a mere type variant, or to
5195:          another padding type around the same type, just make a new one in
5196:          the proper type.  */
5197:       if (code == ecode
5198:           && (gnat_types_compatible_p (type, etype)
5199:               || (code == RECORD_TYPE
5200:                   && TYPE_PADDING_P (type) && TYPE_PADDING_P (etype)
5201:                   && TREE_TYPE (TYPE_FIELDS (type))
5202:                      == TREE_TYPE (TYPE_FIELDS (etype)))))
5203:         {
5204:           expr = copy_node (expr);
5205:           TREE_TYPE (expr) = type;
5206:           CONSTRUCTOR_ELTS (expr) = vec_safe_copy (CONSTRUCTOR_ELTS (expr));
5207:           return expr;
5208:         }
5209:
5210:       /* Likewise for a conversion between original and packable version, or
5211:          conversion between types of the same size and with the same list of
5212:          fields, but we have to work harder to preserve type consistency.  */
5213:       if (code == ecode
5214:           && code == RECORD_TYPE
5215:           && (TYPE_NAME (type) == TYPE_NAME (etype)
5216:               || tree_int_cst_equal (TYPE_SIZE (type), TYPE_SIZE (etype))))
5217:
5218:         {
5219:           vec<constructor_elt, va_gc> *e = CONSTRUCTOR_ELTS (expr);
5220:           unsigned HOST_WIDE_INT len = vec_safe_length (e);
5221:           vec<constructor_elt, va_gc> *v;
5222:           vec_alloc (v, len);
5223:           tree efield = TYPE_FIELDS (etype), field = TYPE_FIELDS (type);
5224:           unsigned HOST_WIDE_INT idx;
5225:           tree index, value;
5226:
5227:           /* Whether we need to clear TREE_CONSTANT et al. on the output
5228:              constructor when we convert in place.  */
5229:           bool clear_constant = false;
5230:
5231:           FOR_EACH_CONSTRUCTOR_ELT(e, idx, index, value)
5232:             {
5233:               /* Skip the missing fields in the CONSTRUCTOR.  */
5234:               while (efield && field && !SAME_FIELD_P (efield, index))
5235:                 {
5236:                   efield = DECL_CHAIN (efield);
5237:                   field = DECL_CHAIN (field);
5238:                 }
5239:               /* The field must be the same.  */
5240:               if (!(efield && field && SAME_FIELD_P (efield, field)))
5241:                 break;
5242:               constructor_elt elt
5243:                 = {field, convert (TREE_TYPE (field), value)};
5244:               v->quick_push (elt);
5245:
5246:               /* If packing has made this field a bitfield and the input
5247:                  value couldn't be emitted statically any more, we need to
5248:                  clear TREE_CONSTANT on our output.  */
5249:               if (!clear_constant
5250:                   && TREE_CONSTANT (expr)
5251:                   && !CONSTRUCTOR_BITFIELD_P (efield)
5252:                   && CONSTRUCTOR_BITFIELD_P (field)
5253:                   && !initializer_constant_valid_for_bitfield_p (value))
5254:                 clear_constant = true;
5255:
5256:               efield = DECL_CHAIN (efield);
5257:               field = DECL_CHAIN (field);
5258:             }
5259:
5260:           /* If we have been able to match and convert all the input fields
5261:              to their output type, convert in place now.  We'll fallback to a
5262:              view conversion downstream otherwise.  */
5263:           if (idx == len)
5264:             {
5265:               expr = copy_node (expr);
5266:               TREE_TYPE (expr) = type;
5267:               CONSTRUCTOR_ELTS (expr) = v;
5268:               if (clear_constant)
5269:                 TREE_CONSTANT (expr) = TREE_STATIC (expr) = 0;
5270:               return expr;
5271:             }
5272:         }
5273:
5274:       /* Likewise for a conversion between array type and vector type with a
5275:          compatible representative array.  */
5276:       else if (code == VECTOR_TYPE
5277:                && ecode == ARRAY_TYPE
5278:                && gnat_types_compatible_p (TYPE_REPRESENTATIVE_ARRAY (type),
5279:                                            etype))
5280:         {
5281:           vec<constructor_elt, va_gc> *e = CONSTRUCTOR_ELTS (expr);
5282:           unsigned HOST_WIDE_INT len = vec_safe_length (e);
5283:           vec<constructor_elt, va_gc> *v;
5284:           unsigned HOST_WIDE_INT ix;
5285:           tree value;
5286:
5287:           /* Build a VECTOR_CST from a *constant* array constructor.  */
5288:           if (TREE_CONSTANT (expr))
5289:             {
5290:               bool constant_p = true;
5291:
5292:               /* Iterate through elements and check if all constructor
5293:                  elements are *_CSTs.  */
5294:               FOR_EACH_CONSTRUCTOR_VALUE (e, ix, value)
5295:                 if (!CONSTANT_CLASS_P (value))
5296:                   {
5297:                     constant_p = false;
5298:                     break;
5299:                   }
5300:
5301:               if (constant_p)
5302:                 return build_vector_from_ctor (type,
5303:                                                CONSTRUCTOR_ELTS (expr));
5304:             }
5305:
5306:           /* Otherwise, build a regular vector constructor.  */
5307:           vec_alloc (v, len);
5308:           FOR_EACH_CONSTRUCTOR_VALUE (e, ix, value)
5309:             {
5310:               constructor_elt elt = {NULL_TREE, value};
5311:               v->quick_push (elt);
5312:             }
5313:           expr = copy_node (expr);
5314:           TREE_TYPE (expr) = type;
5315:           CONSTRUCTOR_ELTS (expr) = v;
5316:           return expr;
5317:         }
5318:       break;
5319:
5320:     case UNCONSTRAINED_ARRAY_REF:
5321:       /* First retrieve the underlying array.  */
5322:       expr = maybe_unconstrained_array (expr);
5323:       etype = TREE_TYPE (expr);
5324:       ecode = TREE_CODE (etype);
5325:       break;
5326:
5327:     case VIEW_CONVERT_EXPR:
5328:       {
5329:         /* GCC 4.x is very sensitive to type consistency overall, and view
5330:            conversions thus are very frequent.  Even though just "convert"ing
5331:            the inner operand to the output type is fine in most cases, it
5332:            might expose unexpected input/output type mismatches in special
5333:            circumstances so we avoid such recursive calls when we can.  */
5334:         tree op0 = TREE_OPERAND (expr, 0);
5335:
5336:         /* If we are converting back to the original type, we can just
5337:            lift the input conversion.  This is a common occurrence with
5338:            switches back-and-forth amongst type variants.  */
5339:         if (type == TREE_TYPE (op0))
5340:           return op0;
5341:
5342:         /* Otherwise, if we're converting between two aggregate or vector
5343:            types, we might be allowed to substitute the VIEW_CONVERT_EXPR
5344:            target type in place or to just convert the inner expression.  */
5345:         if ((AGGREGATE_TYPE_P (type) && AGGREGATE_TYPE_P (etype))
5346:             || (VECTOR_TYPE_P (type) && VECTOR_TYPE_P (etype)))
5347:           {
5348:             /* If we are converting between mere variants, we can just
5349:                substitute the VIEW_CONVERT_EXPR in place.  */
5350:             if (gnat_types_compatible_p (type, etype))
5351:               return build1 (VIEW_CONVERT_EXPR, type, op0);
5352:
5353:             /* Otherwise, we may just bypass the input view conversion unless
5354:                one of the types is a fat pointer,  which is handled by
5355:                specialized code below which relies on exact type matching.  */
5356:             else if (!TYPE_IS_FAT_POINTER_P (type)
5357:                      && !TYPE_IS_FAT_POINTER_P (etype))
5358:               return convert (type, op0);
5359:           }
5360:
5361:         break;
5362:       }
5363:
5364:     default:
5365:       break;
5366:     }
5367:
5368:   /* Check for converting to a pointer to an unconstrained array.  */
5369:   if (TYPE_IS_FAT_POINTER_P (type) && !TYPE_IS_FAT_POINTER_P (etype))
5370:     return convert_to_fat_pointer (type, expr);
5371:   if (TYPE_IS_EXTENDED_POINTER_P (type) && !TYPE_IS_EXTENDED_POINTER_P (etype))
5372:     return convert_to_extended_pointer (type, expr);
5373:
5374:   /* If we are converting between two aggregate or vector types that are mere
5375:      variants, just make a VIEW_CONVERT_EXPR.  Likewise when we are converting
5376:      to a vector type from its representative array type.  */
5377:   else if ((code == ecode
5378:             && (AGGREGATE_TYPE_P (type) || VECTOR_TYPE_P (type))
5379:             && gnat_types_compatible_p (type, etype))
5380:            || (code == VECTOR_TYPE
5381:                && ecode == ARRAY_TYPE
5382:                && gnat_types_compatible_p (TYPE_REPRESENTATIVE_ARRAY (type),
5383:                                            etype)))
5384:     return build1 (VIEW_CONVERT_EXPR, type, expr);
5385:
5386:   /* If we are converting between tagged types, try to upcast properly.
5387:      But don't do it if we are just annotating types since tagged types
5388:      aren't fully laid out in this mode.  */
5389:   else if (ecode == RECORD_TYPE && code == RECORD_TYPE
5390:            && type_is_tagged_or_cw_equivalent (etype)
5391:            && type_is_tagged_or_cw_equivalent (type)
5392:            && !type_annotate_only)
5393:     {
5394:       tree child_etype = etype;
5395:       /* Loop through the nested _Parent fields until we find one with either
5396:          directly the right type (simple record case), or only the right size
5397:          (discriminated record case), and extract it to be the new expression.
5398:          Note that build_component_ref will automatically build the chain of
5399:          COMPONENT_REFs in the case where it is not the immediate parent.  */
5400:       do {
5401:         tree field = TYPE_FIELDS (child_etype);
5402:         if (DECL_NAME (field) == parent_name_id)
5403:           {
5404:             if (TREE_TYPE (field) == type)
5405:               return build_component_ref (expr, field, false);
5406:             if (operand_equal_p (DECL_SIZE (field), TYPE_SIZE (type), 0))
5407:               return convert (type, build_component_ref (expr, field, false));
5408:          }
5409:         child_etype = TREE_TYPE (field);
5410:       } while (TREE_CODE (child_etype) == RECORD_TYPE);
5411:     }
5412:
5413:   /* If we are converting from a smaller form of record type back to it, just
5414:      make a VIEW_CONVERT_EXPR.  But first pad the expression to have the same
5415:      size on both sides.  */
5416:   else if (ecode == RECORD_TYPE && code == RECORD_TYPE
5417:            && smaller_form_type_p (etype, type))
5418:     {
5419:       expr = convert (maybe_pad_type (etype, TYPE_SIZE (type), 0, Empty,
5420:                                       false, false, true),
5421:                       expr);
5422:       return build1 (VIEW_CONVERT_EXPR, type, expr);
5423:     }
5424:
5425:   /* In all other cases of related types, make a NOP_EXPR.  */
5426:   else if (TYPE_MAIN_VARIANT (type) == TYPE_MAIN_VARIANT (etype))
5427:     return fold_convert (type, expr);
5428:
5429:   switch (code)
5430:     {
5431:     case VOID_TYPE:
5432:       return fold_build1 (CONVERT_EXPR, type, expr);
5433:
5434:     case INTEGER_TYPE:
5435:       if (TYPE_HAS_ACTUAL_BOUNDS_P (type)
5436:           && (ecode == ARRAY_TYPE || ecode == UNCONSTRAINED_ARRAY_TYPE
5437:               || (ecode == RECORD_TYPE && TYPE_CONTAINS_TEMPLATE_P (etype))))
5438:         return unchecked_convert (type, expr, false);
5439:
5440:       /* If the output is a biased type, convert first to the base type and
5441:          subtract the bias.  Note that the bias itself must go through a full
5442:          conversion to the base type, lest it is a biased value; this happens
5443:          for subtypes of biased types.  */
5444:       if (TYPE_BIASED_REPRESENTATION_P (type))
5445:         return fold_convert (type,
5446:                              fold_build2 (MINUS_EXPR, TREE_TYPE (type),
5447:                                           convert (TREE_TYPE (type), expr),
5448:                                           convert (TREE_TYPE (type),
5449:                                                    TYPE_MIN_VALUE (type))));
5450:
5451:       /* If we are converting an additive expression to an integer type
5452:          with lower precision, be wary of the optimization that can be
5453:          applied by convert_to_integer.  There are 2 problematic cases:
5454:            - if the first operand was originally of a biased type,
5455:              because we could be recursively called to convert it
5456:              to an intermediate type and thus rematerialize the
5457:              additive operator endlessly,
5458:            - if the expression contains a placeholder, because an
5459:              intermediate conversion that changes the sign could
5460:              be inserted and thus introduce an artificial overflow
5461:              at compile time when the placeholder is substituted.  */
5462:       if (ecode == INTEGER_TYPE
5463:           && TYPE_PRECISION (type) < TYPE_PRECISION (etype)
5464:           && (TREE_CODE (expr) == PLUS_EXPR || TREE_CODE (expr) == MINUS_EXPR))
5465:         {
5466:           tree op0 = get_unwidened (TREE_OPERAND (expr, 0), type);
5467:
5468:           if ((TREE_CODE (TREE_TYPE (op0)) == INTEGER_TYPE
5469:                && TYPE_BIASED_REPRESENTATION_P (TREE_TYPE (op0)))
5470:               || CONTAINS_PLACEHOLDER_P (expr))
5471:             return fold_convert (type, expr);
5472:         }
5473:
5474:       if (TREE_CODE (expr) == INTEGER_CST)
5475:         return int_const_convert (type, expr,
5476:                                   type == sizetype || type == bitsizetype
5477:                                   ? -1 : !POINTER_TYPE_P (etype));
5478:
5479:       /* ... fall through ... */
5480:
5481:     case ENUMERAL_TYPE:
5482:       return fold (convert_to_integer (type, expr));
5483:
5484:     case BOOLEAN_TYPE:
5485:       /* Do not use convert_to_integer with boolean types.  */
5486:       return fold_convert_loc (EXPR_LOCATION (expr), type, expr);
5487:
5488:     case POINTER_TYPE:
5489:     case REFERENCE_TYPE:
5490:       /* If converting between two thin pointers, adjust if needed to account
5491:          for differing offsets from the base pointer, depending on whether
5492:          there is a TYPE_UNCONSTRAINED_ARRAY attached to the record type.  */
5493:       if (TYPE_IS_THIN_POINTER_P (etype) && TYPE_IS_THIN_POINTER_P (type))
5494:         {
5495:           tree etype_pos
5496:             = TYPE_UNCONSTRAINED_ARRAY (TREE_TYPE (etype))
5497:               ? byte_position (DECL_CHAIN (TYPE_FIELDS (TREE_TYPE (etype))))
5498:               : size_zero_node;
5499:           tree type_pos
5500:             = TYPE_UNCONSTRAINED_ARRAY (TREE_TYPE (type))
5501:               ? byte_position (DECL_CHAIN (TYPE_FIELDS (TREE_TYPE (type))))
5502:               : size_zero_node;
5503:           tree byte_diff = size_diffop (type_pos, etype_pos);
5504:
5505:           expr = fold_convert (type, expr);
5506:           if (integer_zerop (byte_diff))
5507:             return expr;
5508:
5509:           return build_binary_op (POINTER_PLUS_EXPR, type, expr,
5510:                                   fold_convert (sizetype, byte_diff));
5511:         }
5512:
5513:       /* If converting from a thin pointer with zero offset from the base to
5514:          a pointer to the array, add the offset of the array field.  */
5515:       if (TYPE_IS_THIN_POINTER_P (etype)
5516:           && !TYPE_UNCONSTRAINED_ARRAY (TREE_TYPE (etype)))
5517:         {
5518:           tree arr_field = DECL_CHAIN (TYPE_FIELDS (TREE_TYPE (etype)));
5519:
5520:           if (TREE_TYPE (type) == TREE_TYPE (arr_field))
5521:             {
5522:               expr = fold_convert (type, expr);
5523:               return build_binary_op (POINTER_PLUS_EXPR, type, expr,
5524:                                       byte_position (arr_field));
5525:             }
5526:         }
5527:
5528:       /* If converting fat pointer to normal or thin pointer, get the pointer
5529:          to the array and then convert it.  */
5530:       if (TYPE_IS_FAT_POINTER_P (etype) || TYPE_IS_EXTENDED_POINTER_P (etype))
5531:         expr = build_component_ref (expr, TYPE_FIELDS (etype), false);
5532:
5533:       return fold (convert_to_pointer (type, expr));
5534:
5535:     case REAL_TYPE:
5536:       return fold (convert_to_real (type, expr));
5537:
5538:     case RECORD_TYPE:
5539:       /* Do a normal conversion between scalar and justified modular type.  */
5540:       if (TYPE_JUSTIFIED_MODULAR_P (type) && !AGGREGATE_TYPE_P (etype))
5541:         {
5542:           vec<constructor_elt, va_gc> *v;
5543:           vec_alloc (v, 1);
5544:
5545:           CONSTRUCTOR_APPEND_ELT (v, TYPE_FIELDS (type),
5546:                                   convert (TREE_TYPE (TYPE_FIELDS (type)),
5547:                                            expr));
5548:           return gnat_build_constructor (type, v);
5549:         }
5550:
5551:       /* In these cases, assume the front-end has validated the conversion.
5552:          If the conversion is valid, it will be a bit-wise conversion, so
5553:          it can be viewed as an unchecked conversion.  */
5554:       return unchecked_convert (type, expr, false);
5555:
5556:     case ARRAY_TYPE:
5557:       /* Do a normal conversion between unconstrained and constrained array
5558:          type, assuming the latter is a constrained version of the former.  */
5559:       if (TREE_CODE (expr) == INDIRECT_REF
5560:           && ecode == ARRAY_TYPE
5561:           && TREE_TYPE (etype) == TREE_TYPE (type))
5562:         {
5563:           tree ptr_type = build_pointer_type (type);
5564:           tree t = build_unary_op (INDIRECT_REF, NULL_TREE,
5565:                                    fold_convert (ptr_type,
5566:                                                  TREE_OPERAND (expr, 0)));
5567:           TREE_READONLY (t) = TREE_READONLY (expr);
5568:           TREE_THIS_NOTRAP (t) = TREE_THIS_NOTRAP (expr);
5569:           return t;
5570:         }
5571:
5572:       /* In these cases, assume the front-end has validated the conversion.
5573:          If the conversion is valid, it will be a bit-wise conversion, so
5574:          it can be viewed as an unchecked conversion.  */
5575:       return unchecked_convert (type, expr, false);
5576:
5577:     case UNION_TYPE:
5578:       /* This is a either a conversion between a tagged type and some
5579:          subtype, which we have to mark as a UNION_TYPE because of
5580:          overlapping fields or a conversion of an Unchecked_Union.  */
5581:       return unchecked_convert (type, expr, false);
5582:
5583:     case UNCONSTRAINED_ARRAY_TYPE:
5584:       /* If the input is a VECTOR_TYPE, convert to the representative
5585:          array type first.  */
5586:       if (ecode == VECTOR_TYPE)
5587:         {
5588:           expr = convert (TYPE_REPRESENTATIVE_ARRAY (etype), expr);
5589:           etype = TREE_TYPE (expr);
5590:           ecode = TREE_CODE (etype);
5591:         }
5592:
5593:       /* If EXPR is a constrained array, take its address, convert it to a
5594:          fat or extended pointer, and then dereference it.  Likewise if
5595:          EXPR is a record containing both a template and a constrained
5596:          array.  Note that a record representing a justified modular type
5597:          always represents a packed constrained array. */
5598:       if (ecode == ARRAY_TYPE
5599:           || (ecode == INTEGER_TYPE && TYPE_HAS_ACTUAL_BOUNDS_P (etype))
5600:           || (ecode == RECORD_TYPE && TYPE_CONTAINS_TEMPLATE_P (etype))
5601:           || (ecode == RECORD_TYPE && TYPE_JUSTIFIED_MODULAR_P (etype)))
5602:         {
5603:           if (TYPE_IS_EXTENDED_POINTER_P (TREE_TYPE (type)))
5604:             return
5605:               build_unary_op
5606:               (INDIRECT_REF, NULL_TREE,
5607:                convert_to_extended_pointer (TREE_TYPE (type),
5608:                                             build_unary_op (ADDR_EXPR,
5609:                                                             NULL_TREE, expr)));
5610:           else
5611:             return
5612:               build_unary_op
5613:               (INDIRECT_REF, NULL_TREE,
5614:                convert_to_fat_pointer (TREE_TYPE (type),
5615:                                        build_unary_op (ADDR_EXPR,
5616:                                                        NULL_TREE, expr)));
5617:         }
5618:
5619:       /* Do something very similar for converting one unconstrained
5620:          array to another.  */
5621:       else if (ecode == UNCONSTRAINED_ARRAY_TYPE)
5622:         return
5623:           build_unary_op (INDIRECT_REF, NULL_TREE,
5624:                           convert (TREE_TYPE (type),
5625:                                    build_unary_op (ADDR_EXPR,
5626:                                                    NULL_TREE, expr)));
5627:       else
5628:         gcc_unreachable ();
5629:
5630:     case COMPLEX_TYPE:
5631:       return fold (convert_to_complex (type, expr));
5632:
5633:     default:
5634:       gcc_unreachable ();
5635:     }
```

## gcc/ada/gcc-interface/utils.cc:5764–5851

```text
5764: maybe_unconstrained_array (tree exp)
5765: {
5766:   enum tree_code code = TREE_CODE (exp);
5767:   tree type = TREE_TYPE (exp);
5768:
5769:   switch (TREE_CODE (type))
5770:     {
5771:     case UNCONSTRAINED_ARRAY_TYPE:
5772:       if (code == UNCONSTRAINED_ARRAY_REF)
5773:         {
5774:           const bool read_only = TREE_READONLY (exp);
5775:           const bool no_trap = TREE_THIS_NOTRAP (exp);
5776:
5777:           exp = TREE_OPERAND (exp, 0);
5778:           type = TREE_TYPE (exp);
5779:
5780:           if (TREE_CODE (exp) == COND_EXPR)
5781:             {
5782:               tree op1
5783:                 = build_unary_op (INDIRECT_REF, NULL_TREE,
5784:                                   build_component_ref (TREE_OPERAND (exp, 1),
5785:                                                        TYPE_FIELDS (type),
5786:                                                        false));
5787:               tree op2
5788:                 = build_unary_op (INDIRECT_REF, NULL_TREE,
5789:                                   build_component_ref (TREE_OPERAND (exp, 2),
5790:                                                        TYPE_FIELDS (type),
5791:                                                        false));
5792:
5793:               exp = build3 (COND_EXPR,
5794:                             TREE_TYPE (TREE_TYPE (TYPE_FIELDS (type))),
5795:                             TREE_OPERAND (exp, 0), op1, op2);
5796:             }
5797:           else
5798:             {
5799:               exp = build_unary_op (INDIRECT_REF, NULL_TREE,
5800:                                     build_component_ref (exp,
5801:                                                          TYPE_FIELDS (type),
5802:                                                          false));
5803:               TREE_READONLY (exp) = read_only;
5804:               TREE_THIS_NOTRAP (exp) = no_trap;
5805:             }
5806:         }
5807:
5808:       else if (code == LOAD_EXPR)
5809:         {
5810:           const Entity_Id gnat_smo = tree_to_shwi (TREE_OPERAND (exp, 1));
5811:           tree t = maybe_unconstrained_array (TREE_OPERAND (exp, 0));
5812:           exp = build_storage_model_load (gnat_smo, t);
5813:         }
5814:
5815:       else if (code == NULL_EXPR)
5816:         exp = build1 (NULL_EXPR,
5817:                       TREE_TYPE (TREE_TYPE (TYPE_FIELDS (TREE_TYPE (type)))),
5818:                       TREE_OPERAND (exp, 0));
5819:       break;
5820:
5821:     case RECORD_TYPE:
5822:       /* If this is a padded type and it contains a template, convert to the
5823:          unpadded type first.  */
5824:       if (TYPE_PADDING_P (type)
5825:           && TREE_CODE (TREE_TYPE (TYPE_FIELDS (type))) == RECORD_TYPE
5826:           && TYPE_CONTAINS_TEMPLATE_P (TREE_TYPE (TYPE_FIELDS (type))))
5827:         {
5828:           exp = convert (TREE_TYPE (TYPE_FIELDS (type)), exp);
5829:           code = TREE_CODE (exp);
5830:           type = TREE_TYPE (exp);
5831:         }
5832:
5833:       if (TYPE_CONTAINS_TEMPLATE_P (type))
5834:         {
5835:           /* If the array initializer is a box, return NULL_TREE.  */
5836:           if (code == CONSTRUCTOR && CONSTRUCTOR_NELTS (exp) < 2)
5837:             return NULL_TREE;
5838:
5839:           exp = build_component_ref (exp, DECL_CHAIN (TYPE_FIELDS (type)),
5840:                                      false);
5841:
5842:           /* If the array is padded, remove the padding.  */
5843:           exp = maybe_padded_object (exp);
5844:         }
5845:       break;
5846:
5847:     default:
5848:       break;
5849:     }
5850:
5851:   return exp;
```

## gcc/ada/gcc-interface/utils.cc:5911–6250

```text
5911: unchecked_convert (tree type, tree expr, bool notrunc_p)
5912: {
5913:   tree etype = TREE_TYPE (expr);
5914:   enum tree_code ecode = TREE_CODE (etype);
5915:   enum tree_code code = TREE_CODE (type);
5916:   const bool ebiased
5917:     = (ecode == INTEGER_TYPE && TYPE_BIASED_REPRESENTATION_P (etype));
5918:   const bool biased
5919:     = (code == INTEGER_TYPE && TYPE_BIASED_REPRESENTATION_P (type));
5920:   const bool ereverse
5921:     = (AGGREGATE_TYPE_P (etype) && TYPE_REVERSE_STORAGE_ORDER (etype));
5922:   const bool reverse
5923:     = (AGGREGATE_TYPE_P (type) && TYPE_REVERSE_STORAGE_ORDER (type));
5924:   tree tem;
5925:   int c = 0;
5926:
5927:   /* If the expression is already of the right type, we are done.  */
5928:   if (etype == type)
5929:     return expr;
5930:
5931:   /* If both types are integral or regular pointer, then just do a normal
5932:      conversion.  Likewise for a conversion to an unconstrained array.  */
5933:   if (((INTEGRAL_TYPE_P (type)
5934:         || (POINTER_TYPE_P (type) && !TYPE_IS_THIN_POINTER_P (type))
5935:         || (code == RECORD_TYPE && TYPE_JUSTIFIED_MODULAR_P (type)))
5936:        && (INTEGRAL_TYPE_P (etype)
5937:            || (POINTER_TYPE_P (etype) && !TYPE_IS_THIN_POINTER_P (etype))
5938:            || (ecode == RECORD_TYPE && TYPE_JUSTIFIED_MODULAR_P (etype))))
5939:       || code == UNCONSTRAINED_ARRAY_TYPE)
5940:     {
5941:       if (ebiased)
5942:         {
5943:           tree ntype = copy_type (etype);
5944:           TYPE_BIASED_REPRESENTATION_P (ntype) = 0;
5945:           TYPE_MAIN_VARIANT (ntype) = ntype;
5946:           expr = build1 (NOP_EXPR, ntype, expr);
5947:         }
5948:
5949:       if (biased)
5950:         {
5951:           tree rtype = copy_type (type);
5952:           TYPE_BIASED_REPRESENTATION_P (rtype) = 0;
5953:           TYPE_MAIN_VARIANT (rtype) = rtype;
5954:           expr = convert (rtype, expr);
5955:           expr = build1 (NOP_EXPR, type, expr);
5956:         }
5957:       else
5958:         expr = convert (type, expr);
5959:     }
5960:
5961:   /* If we are converting to an integral type whose precision is not equal
5962:      to its size, first unchecked convert to a record type that contains a
5963:      field of the given precision.  Then extract the result from the field.
5964:
5965:      There is a subtlety if the source type is an aggregate type with reverse
5966:      storage order because its representation is not contiguous in the native
5967:      storage order, i.e. a direct unchecked conversion to an integral type
5968:      with N bits of precision cannot read the first N bits of the aggregate
5969:      type.  To overcome it, we do an unchecked conversion to an integral type
5970:      with reverse storage order and return the resulting value.  This also
5971:      ensures that the result of the unchecked conversion doesn't depend on
5972:      the endianness of the target machine, but only on the storage order of
5973:      the aggregate type.
5974:
5975:      Finally, for the sake of consistency, we do the unchecked conversion
5976:      to an integral type with reverse storage order as soon as the source
5977:      type is an aggregate type with reverse storage order, even if there
5978:      are no considerations of precision or size involved.  Ultimately, we
5979:      further extend this processing to any scalar type.  */
5980:   else if ((INTEGRAL_TYPE_P (type)
5981:             && TYPE_RM_SIZE (type)
5982:             && ((c = tree_int_cst_compare (TYPE_RM_SIZE (type),
5983:                                            TYPE_SIZE (type))) < 0
5984:                 || ereverse))
5985:            || (SCALAR_FLOAT_TYPE_P (type) && ereverse))
5986:     {
5987:       tree rec_type = make_node (RECORD_TYPE);
5988:       tree field_type, field;
5989:
5990:       TYPE_REVERSE_STORAGE_ORDER (rec_type) = ereverse;
5991:
5992:       if (c < 0)
5993:         {
5994:           const unsigned HOST_WIDE_INT prec
5995:             = TREE_INT_CST_LOW (TYPE_RM_SIZE (type));
5996:           if (type_unsigned_for_rm (type))
5997:             field_type = make_unsigned_type (prec);
5998:           else
5999:             field_type = make_signed_type (prec);
6000:           SET_TYPE_RM_SIZE (field_type, TYPE_RM_SIZE (type));
6001:         }
6002:       else
6003:         field_type = type;
6004:
6005:       field = create_field_decl (get_identifier ("OBJ"), field_type, rec_type,
6006:                                  NULL_TREE, bitsize_zero_node, c < 0, 0);
6007:
6008:       finish_record_type (rec_type, field, 1, false);
6009:
6010:       expr = unchecked_convert (rec_type, expr, notrunc_p);
6011:       expr = build_component_ref (expr, field, false);
6012:       expr = fold_build1 (NOP_EXPR, type, expr);
6013:     }
6014:
6015:   /* Similarly if we are converting from an integral type whose precision is
6016:      not equal to its size, first copy into a field of the given precision
6017:      and unchecked convert the record type.
6018:
6019:      The same considerations as above apply if the target type is an aggregate
6020:      type with reverse storage order and we also proceed similarly.  */
6021:   else if ((INTEGRAL_TYPE_P (etype)
6022:             && TYPE_RM_SIZE (etype)
6023:             && ((c = tree_int_cst_compare (TYPE_RM_SIZE (etype),
6024:                                            TYPE_SIZE (etype))) < 0
6025:                 || reverse))
6026:            || (SCALAR_FLOAT_TYPE_P (etype) && reverse))
6027:     {
6028:       tree rec_type = make_node (RECORD_TYPE);
6029:       vec<constructor_elt, va_gc> *v;
6030:       vec_alloc (v, 1);
6031:       tree field_type, field;
6032:
6033:       TYPE_REVERSE_STORAGE_ORDER (rec_type) = reverse;
6034:
6035:       if (c < 0)
6036:         {
6037:           const unsigned HOST_WIDE_INT prec
6038:             = TREE_INT_CST_LOW (TYPE_RM_SIZE (etype));
6039:           if (type_unsigned_for_rm (etype))
6040:             field_type = make_unsigned_type (prec);
6041:           else
6042:             field_type = make_signed_type (prec);
6043:           SET_TYPE_RM_SIZE (field_type, TYPE_RM_SIZE (etype));
6044:         }
6045:       else
6046:         field_type = etype;
6047:
6048:       field = create_field_decl (get_identifier ("OBJ"), field_type, rec_type,
6049:                                  NULL_TREE, bitsize_zero_node, c < 0, 0);
6050:
6051:       finish_record_type (rec_type, field, 1, false);
6052:
6053:       expr = fold_build1 (NOP_EXPR, field_type, expr);
6054:       CONSTRUCTOR_APPEND_ELT (v, field, expr);
6055:       expr = gnat_build_constructor (rec_type, v);
6056:       expr = unchecked_convert (type, expr, notrunc_p);
6057:     }
6058:
6059:   /* If we are converting between fixed-size types with different sizes, we
6060:      need to pad to have the same size on both sides.
6061:
6062:      ??? We cannot do it unconditionally because unchecked conversions are
6063:      used liberally by the front-end to implement interface thunks:
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
6112:         }
6113:       else
6114:         {
6115:           tree rec_type = maybe_pad_type (type, TYPE_SIZE (etype), 0, Empty,
6116:                                           false, false, true);
6117:           expr = unchecked_convert (rec_type, expr, notrunc_p);
6118:           expr = build3 (COMPONENT_REF, type, expr, TYPE_FIELDS (rec_type),
6119:                          NULL_TREE);
6120:         }
6121:     }
6122:
6123:   /* We have a special case when we are converting between two unconstrained
6124:      array types.  In that case, take the address, convert the fat pointer
6125:      types, and dereference.  */
6126:   else if (ecode == code && code == UNCONSTRAINED_ARRAY_TYPE)
6127:     expr = build_unary_op (INDIRECT_REF, NULL_TREE,
6128:                            build1 (VIEW_CONVERT_EXPR, TREE_TYPE (type),
6129:                                    build_unary_op (ADDR_EXPR, NULL_TREE,
6130:                                                    expr)));
6131:
6132:   /* Another special case is when we are converting to a vector type from its
6133:      representative array type; this a regular conversion.  */
6134:   else if (code == VECTOR_TYPE
6135:            && ecode == ARRAY_TYPE
6136:            && gnat_types_compatible_p (TYPE_REPRESENTATIVE_ARRAY (type),
6137:                                        etype))
6138:     expr = convert (type, expr);
6139:
6140:   /* And, if the array type is not the representative, we try to build an
6141:      intermediate vector type of which the array type is the representative
6142:      and to do the unchecked conversion between the vector types, in order
6143:      to enable further simplifications in the middle-end.  */
6144:   else if (code == VECTOR_TYPE
6145:            && ecode == ARRAY_TYPE
6146:            && (tem = build_vector_type_for_array (etype, NULL_TREE)))
6147:     {
6148:       expr = convert (tem, expr);
6149:       return unchecked_convert (type, expr, notrunc_p);
6150:     }
6151:
6152:   /* If we are converting a CONSTRUCTOR to a more aligned aggregate type, bump
6153:      the alignment of the CONSTRUCTOR to speed up the copy operation.  But do
6154:      not do it for a conversion between original and packable version to avoid
6155:      an infinite recursion.  */
6156:   else if (TREE_CODE (expr) == CONSTRUCTOR
6157:            && AGGREGATE_TYPE_P (type)
6158:            && TYPE_NAME (type) != TYPE_NAME (etype)
6159:            && TYPE_ALIGN (etype) < TYPE_ALIGN (type))
6160:     {
6161:       expr = convert (maybe_pad_type (etype, NULL_TREE, TYPE_ALIGN (type),
6162:                                       Empty, false, false, true),
6163:                       expr);
6164:       return unchecked_convert (type, expr, notrunc_p);
6165:     }
6166:
6167:   /* If we are converting a CONSTRUCTOR to a larger aggregate type, bump the
6168:      size of the CONSTRUCTOR to make sure there are enough allocated bytes.
6169:      But do not do it for a conversion between original and packable version
6170:      to avoid an infinite recursion.  */
6171:   else if (TREE_CODE (expr) == CONSTRUCTOR
6172:            && AGGREGATE_TYPE_P (type)
6173:            && TYPE_NAME (type) != TYPE_NAME (etype)
6174:            && TREE_CONSTANT (TYPE_SIZE (type))
6175:            && (!TREE_CONSTANT (TYPE_SIZE (etype))
6176:                || tree_int_cst_lt (TYPE_SIZE (etype), TYPE_SIZE (type))))
6177:     {
6178:       expr = convert (maybe_pad_type (etype, TYPE_SIZE (type), 0,
6179:                                       Empty, false, false, true),
6180:                       expr);
6181:       return unchecked_convert (type, expr, notrunc_p);
6182:     }
6183:
6184:   /* If we are converting a string constant to a pointer to character, make
6185:      sure that the string is not folded into an integer constant.  */
6186:   else if (TREE_CODE (expr) == STRING_CST
6187:            && POINTER_TYPE_P (type)
6188:            && TYPE_STRING_FLAG (TREE_TYPE (type)))
6189:     expr = build1 (VIEW_CONVERT_EXPR, type, expr);
6190:
6191:   /* Otherwise, just build a VIEW_CONVERT_EXPR of the expression.  */
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
6205:      if the input is also an integral type and both are unsigned or both are
6206:      signed and have the same precision.  */
6207:   tree type_rm_size;
6208:   if (!notrunc_p
6209:       && !biased
6210:       && INTEGRAL_TYPE_P (type)
6211:       && (type_rm_size = TYPE_RM_SIZE (type))
6212:       && tree_int_cst_compare (type_rm_size, TYPE_SIZE (type)) < 0
6213:       && !(INTEGRAL_TYPE_P (etype)
6214:            && type_unsigned_for_rm (type) == type_unsigned_for_rm (etype)
6215:            && (type_unsigned_for_rm (type)
6216:                || tree_int_cst_compare (type_rm_size,
6217:                                         TYPE_RM_SIZE (etype)
6218:                                         ? TYPE_RM_SIZE (etype)
6219:                                         : TYPE_SIZE (etype)) == 0)))
6220:     {
6221:       if (integer_zerop (type_rm_size))
6222:         expr = build_int_cst (type, 0);
6223:       else
6224:         {
6225:           tree base_type
6226:             = gnat_type_for_size (TREE_INT_CST_LOW (TYPE_SIZE (type)),
6227:                                   type_unsigned_for_rm (type));
6228:           tree shift_expr
6229:             = convert (base_type,
6230:                        size_binop (MINUS_EXPR,
6231:                                    TYPE_SIZE (type), type_rm_size));
6232:           expr
6233:             = convert (type,
6234:                        build_binary_op (RSHIFT_EXPR, base_type,
6235:                                         build_binary_op (LSHIFT_EXPR, base_type,
6236:                                                          convert (base_type,
6237:                                                                   expr),
6238:                                                          shift_expr),
6239:                                         shift_expr));
6240:         }
6241:     }
6242:
6243:   /* An unchecked conversion should never raise Constraint_Error.  The code
6244:      below assumes that GCC's conversion routines overflow the same way that
6245:      the underlying hardware does.  This is probably true.  In the rare case
6246:      when it is false, we can rely on the fact that such conversions are
6247:      erroneous anyway.  */
6248:   if (TREE_CODE (expr) == INTEGER_CST)
6249:     TREE_OVERFLOW (expr) = 0;
6250:
```

## gcc/ada/gcc-interface/utils.cc:3700–3755

```text
3700:                      enum inline_status_t inline_status, bool public_flag,
3701:                      bool linkonce_flag, bool extern_flag, bool artificial_p,
3702:                      bool debug_info_p, bool definition,
3703:                      struct attrib *attr_list, Node_Id gnat_node)
3704: {
3705:   tree subprog_decl = build_decl (input_location, FUNCTION_DECL, name, type);
3706:   DECL_ARGUMENTS (subprog_decl) = param_decl_list;
3707:
3708:   DECL_ARTIFICIAL (subprog_decl) = artificial_p;
3709:   DECL_EXTERNAL (subprog_decl) = extern_flag;
3710:   DECL_FUNCTION_IS_DEF (subprog_decl) = definition;
3711:   DECL_IGNORED_P (subprog_decl) = !debug_info_p;
3712:   TREE_PUBLIC (subprog_decl) = public_flag;
3713:
3714:   switch (inline_status)
3715:     {
3716:     case is_suppressed:
3717:       DECL_UNINLINABLE (subprog_decl) = 1;
3718:       break;
3719:
3720:     case is_default:
3721:       break;
3722:
3723:     case is_required:
3724:       if (Back_End_Inlining)
3725:         {
3726:           decl_attributes (&subprog_decl,
3727:                            tree_cons (get_identifier ("always_inline"),
3728:                                       NULL_TREE, NULL_TREE),
3729:                            ATTR_FLAG_TYPE_IN_PLACE);
3730:
3731:           /* Inline_Always guarantees that every direct call is inlined and
3732:              that there is no indirect reference to the subprogram, so the
3733:              instance in the original package (as well as its clones in the
3734:              client packages created for inter-unit inlining) can be made
3735:              private, which causes the out-of-line body to be eliminated.  */
3736:           TREE_PUBLIC (subprog_decl) = 0;
3737:         }
3738:
3739:       /* ... fall through ... */
3740:
3741:     case is_prescribed:
3742:       DECL_DISREGARD_INLINE_LIMITS (subprog_decl) = 1;
3743:
3744:       /* ... fall through ... */
3745:
3746:     case is_requested:
3747:       DECL_DECLARED_INLINE_P (subprog_decl) = 1;
3748:       if (!Debug_Generated_Code)
3749:         DECL_NO_INLINE_WARNING_P (subprog_decl) = artificial_p;
3750:       break;
3751:
3752:     default:
3753:       gcc_unreachable ();
3754:     }
3755:
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

## gcc/ada/gcc-interface/decl.cc:1278–1291

```text
1278:            either get the address expression from the saved GCC tree for the
1279:            object if it has a Freeze node, or elaborate the address expression
1280:            here since the front-end has guaranteed that the elaboration has no
1281:            effects in this case.  */
1282:         if (definition && Present (Address_Clause (gnat_entity)))
1283:           {
1284:             const Node_Id gnat_clause = Address_Clause (gnat_entity);
1285:             const Node_Id gnat_address = Expression (gnat_clause);
1286:             tree gnu_address = present_gnu_tree (gnat_entity)
1287:                                ? TREE_OPERAND (get_gnu_tree (gnat_entity), 0)
1288:                                : gnat_to_gnu (gnat_address);
1289:
1290:             save_gnu_tree (gnat_entity, NULL_TREE, false);
1291:
```

## gcc/ada/gcc-interface/decl.cc:1507–1713

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
1593:
1594:                 used_by_ref = true;
1595:                 const_flag = true;
1596:                 volatile_flag = false;
1597:                 inner_const_flag = TREE_READONLY (gnu_unc_var);
1598:                 gnu_size = NULL_TREE;
1599:               }
1600:
1601:             tree gnu_array = gnat_to_gnu_type (Base_Type (gnat_type));
1602:             gnu_type
1603:               = build_reference_type (TYPE_OBJECT_RECORD_TYPE (gnu_array));
1604:           }
1605:
1606:         /* Convert the expression to the type of the object if need be.  */
1607:         if (gnu_expr && initial_value_needs_conversion (gnu_type, gnu_expr))
1608:           gnu_expr = convert (gnu_type, gnu_expr);
1609:
1610:         /* If this name is external or a name was specified, use it, but don't
1611:            use the Interface_Name with an address clause (see cd30005).  */
1612:         if ((Is_Public (gnat_entity) && !imported_p)
1613:             || (Present (Interface_Name (gnat_entity))
1614:                 && No (Address_Clause (gnat_entity))))
1615:           gnu_ext_name = create_concat_name (gnat_entity, NULL);
1616:
1617:         /* Deal with a pragma Linker_Section on a constant or variable.  */
1618:         if ((kind == E_Constant || kind == E_Variable)
1619:             && Present (Linker_Section_Pragma (gnat_entity)))
1620:           prepend_one_attribute_pragma (&attr_list,
1621:                                         Linker_Section_Pragma (gnat_entity));
1622:
1623:         /* Do not initialize Out parameters with -ftrivial-auto-var-init.  */
1624:         if (kind == E_Out_Parameter)
1625:           prepend_one_attribute
1626:             (&attr_list, ATTR_MACHINE_ATTRIBUTE,
1627:              get_identifier ("uninitialized"), NULL_TREE,
1628:              gnat_entity);
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

## gcc/ada/gcc-interface/decl.cc:1901–2005

```text
1901:     case E_Signed_Integer_Subtype:
1902:     case E_Enumeration_Subtype:
1903:     case E_Modular_Integer_Subtype:
1904:     case E_Ordinary_Fixed_Point_Subtype:
1905:     case E_Decimal_Fixed_Point_Subtype:
1906:       gnat_cloned_subtype = Gigi_Cloned_Subtype (gnat_entity);
1907:       if (Present (gnat_cloned_subtype))
1908:         break;
1909:
1910:       /* For integral subtypes, we make a new INTEGER_TYPE.  Note that we do
1911:          not want to call create_range_type since we would like each subtype
1912:          node to be distinct.  ??? Historically this was in preparation for
1913:          when memory aliasing is implemented, but that's obsolete now given
1914:          the call to relate_alias_sets below.
1915:
1916:          The TREE_TYPE field of the INTEGER_TYPE points to the base type;
1917:          this fact is used by the arithmetic conversion functions.
1918:
1919:          We elaborate the Ancestor_Subtype if it is not in the current unit
1920:          and one of our bounds is non-static.  We do this to ensure consistent
1921:          naming in the case where several subtypes share the same bounds, by
1922:          elaborating the first such subtype first, thus using its name.  */
1923:
1924:       if (!definition
1925:           && Present (Ancestor_Subtype (gnat_entity))
1926:           && !In_Extended_Main_Code_Unit (Ancestor_Subtype (gnat_entity))
1927:           && (!Compile_Time_Known_Value (Type_Low_Bound (gnat_entity))
1928:               || !Compile_Time_Known_Value (Type_High_Bound (gnat_entity))))
1929:         gnat_to_gnu_entity (Ancestor_Subtype (gnat_entity), gnu_expr, false);
1930:
1931:       /* Set the precision to the Esize except for bit-packed arrays.  */
1932:       if (Is_Packed_Array_Impl_Type (gnat_entity))
1933:         esize = UI_To_Int (RM_Size (gnat_entity));
1934:
1935:       /* Boolean types with foreign convention have precision 1.  */
1936:       if (Is_Boolean_Type (gnat_entity) && foreign)
1937:         {
1938:           gnu_type = make_node (BOOLEAN_TYPE);
1939:           TYPE_PRECISION (gnu_type) = 1;
1940:           TYPE_UNSIGNED (gnu_type) = 1;
1941:           set_min_and_max_values_for_integral_type (gnu_type, 1, UNSIGNED);
1942:           layout_type (gnu_type);
1943:         }
1944:       /* First subtypes of Character are treated as Character; otherwise
1945:          this should be an unsigned type if the base type is unsigned or
1946:          if the lower bound is constant and non-negative or if the type
1947:          is biased.  However, even if the lower bound is constant and
1948:          non-negative, we use a signed type for a subtype with the same
1949:          size as its signed base type, because this eliminates useless
1950:          conversions to it and gives more leeway to the optimizer; but
1951:          this means that we will need to explicitly test for this case
1952:          when we change the representation based on the RM size.  */
1953:       else if (kind == E_Enumeration_Subtype
1954:           && No (First_Literal (Etype (gnat_entity)))
1955:           && Esize (gnat_entity) == RM_Size (gnat_entity)
1956:           && esize == CHAR_TYPE_SIZE
1957:           && flag_signed_char)
1958:         gnu_type = make_signed_type (CHAR_TYPE_SIZE);
1959:       else if (Is_Unsigned_Type (Underlying_Type (Etype (gnat_entity)))
1960:                || (Esize (Etype (gnat_entity)) != Esize (gnat_entity)
1961:                    && Is_Unsigned_Type (gnat_entity))
1962:                || Has_Biased_Representation (gnat_entity))
1963:         gnu_type = make_unsigned_type (esize);
1964:       else
1965:         gnu_type = make_signed_type (esize);
1966:       TREE_TYPE (gnu_type) = get_unpadded_type (Etype (gnat_entity));
1967:
1968:       SET_TYPE_RM_MIN_VALUE
1969:         (gnu_type, elaborate_expression (Type_Low_Bound (gnat_entity),
1970:                                          gnat_entity, "L", definition, true,
1971:                                          debug_info_p));
1972:
1973:       SET_TYPE_RM_MAX_VALUE
1974:         (gnu_type, elaborate_expression (Type_High_Bound (gnat_entity),
1975:                                          gnat_entity, "U", definition, true,
1976:                                          debug_info_p));
1977:
1978:       if (TREE_CODE (gnu_type) == INTEGER_TYPE)
1979:         TYPE_BIASED_REPRESENTATION_P (gnu_type)
1980:           = Has_Biased_Representation (gnat_entity);
1981:
1982:       /* Do the same processing for Character subtypes as for types.  */
1983:       if (TREE_CODE (TREE_TYPE (gnu_type)) == INTEGER_TYPE
1984:           && TYPE_STRING_FLAG (TREE_TYPE (gnu_type)))
1985:         {
1986:           TYPE_NAME (gnu_type) = gnu_entity_name;
1987:           TYPE_STRING_FLAG (gnu_type) = 1;
1988:           TYPE_ARTIFICIAL (gnu_type) = artificial_p;
1989:           finish_character_type (gnu_type);
1990:         }
1991:
1992:       /* Inherit our alias set from what we're a subtype of.  Subtypes
1993:          are not different types and a pointer can designate any instance
1994:          within a subtype hierarchy.  */
1995:       relate_alias_sets (gnu_type, TREE_TYPE (gnu_type), ALIAS_SET_COPY);
1996:
1997:       /* One of the above calls might have caused us to be elaborated,
1998:          so don't blow up if so.  */
1999:       if (present_gnu_tree (gnat_entity))
2000:         {
2001:           maybe_present = true;
2002:           break;
2003:         }
2004:
2005:       /* Attach the TYPE_STUB_DECL in case we have a parallel type.  */
```

## gcc/ada/gcc-interface/decl.cc:2577–3193

```text
2577:     case E_Array_Subtype:
2578:       gnat_cloned_subtype = Gigi_Cloned_Subtype (gnat_entity);
2579:       if (Present (gnat_cloned_subtype))
2580:         break;
2581:
2582:       /* This is the actual data type for array variables.  Multidimensional
2583:          arrays are implemented as arrays of arrays.  Note that arrays which
2584:          have sparse enumeration subtypes as index components create sparse
2585:          arrays, which is obviously space inefficient but so much easier to
2586:          code for now.
2587:
2588:          Also note that the subtype never refers to the unconstrained array
2589:          type, which is somewhat at variance with Ada semantics.
2590:
2591:          First check to see if this is simply a renaming of the array type.
2592:          If so, the result is the array type.  */
2593:
2594:       gnu_type = TYPE_MAIN_VARIANT (gnat_to_gnu_type (Etype (gnat_entity)));
2595:       if (!Is_Constrained (gnat_entity))
2596:         ;
2597:       else
2598:         {
2599:           const Entity_Id PAT = Packed_Array_Impl_Type (gnat_entity);
2600:           Entity_Id gnat_index, gnat_base_index;
2601:           const bool convention_fortran_p
2602:             = (Convention (gnat_entity) == Convention_Fortran);
2603:           const int ndim = Number_Dimensions (gnat_entity);
2604:           tree gnu_base_type = gnu_type;
2605:           tree *gnu_index_types = XALLOCAVEC (tree, ndim);
2606:           bool *gnu_null_ranges = XALLOCAVEC (bool, ndim);
2607:           tree gnu_max_size = size_one_node;
2608:           bool need_index_type_struct = false;
2609:           int index;
2610:
2611:           /* First create the GCC type for each index and find out whether
2612:              special types are needed for debugging information.  */
2613:           for (index = (convention_fortran_p ? ndim - 1 : 0),
2614:                gnat_index = First_Index (gnat_entity),
2615:                gnat_base_index
2616:                  = First_Index (Implementation_Base_Type (gnat_entity));
2617:                IN_RANGE (index, 0, ndim - 1);
2618:                index += (convention_fortran_p ? - 1 : 1),
2619:                gnat_index = Next_Index (gnat_index),
2620:                gnat_base_index = Next_Index (gnat_base_index))
2621:             {
2622:               const Entity_Id gnat_index_type = Etype (gnat_index);
2623:               tree gnu_index_type = get_unpadded_type (gnat_index_type);
2624:               tree gnu_orig_min = TYPE_MIN_VALUE (gnu_index_type);
2625:               tree gnu_orig_max = TYPE_MAX_VALUE (gnu_index_type);
2626:               tree gnu_index_base_type = get_base_type (gnu_index_type);
2627:               tree gnu_base_index_type
2628:                 = get_unpadded_type (Etype (gnat_base_index));
2629:               tree gnu_base_orig_min = TYPE_MIN_VALUE (gnu_base_index_type);
2630:               tree gnu_base_orig_max = TYPE_MAX_VALUE (gnu_base_index_type);
2631:               tree gnu_min, gnu_max, gnu_high;
2632:
2633:               /* We try to create subtypes for discriminants used as bounds
2634:                  that are more restrictive than those declared, by using the
2635:                  bounds of the index type of the base array type.  This will
2636:                  make it possible to calculate the maximum size of the record
2637:                  type more conservatively.  This may have already been done by
2638:                  the front-end (Exp_Ch3.Adjust_Discriminants), in which case
2639:                  there will be a conversion that needs to be removed first.  */
2640:               if (CONTAINS_PLACEHOLDER_P (gnu_orig_min)
2641:                   && TYPE_RM_SIZE (gnu_base_index_type)
2642:                   && tree_int_cst_lt (TYPE_RM_SIZE (gnu_base_index_type),
2643:                                       TYPE_RM_SIZE (gnu_index_type)))
2644:                 {
2645:                   gnu_orig_min = remove_conversions (gnu_orig_min, false);
2646:                   TREE_TYPE (gnu_orig_min)
2647:                     = create_extra_subtype (TREE_TYPE (gnu_orig_min),
2648:                                             gnu_base_orig_min,
2649:                                             gnu_base_orig_max);
2650:                 }
2651:
2652:               if (CONTAINS_PLACEHOLDER_P (gnu_orig_max)
2653:                   && TYPE_RM_SIZE (gnu_base_index_type)
2654:                   && tree_int_cst_lt (TYPE_RM_SIZE (gnu_base_index_type),
2655:                                       TYPE_RM_SIZE (gnu_index_type)))
2656:                 {
2657:                   gnu_orig_max = remove_conversions (gnu_orig_max, false);
2658:                   TREE_TYPE (gnu_orig_max)
2659:                     = create_extra_subtype (TREE_TYPE (gnu_orig_max),
2660:                                             gnu_base_orig_min,
2661:                                             gnu_base_orig_max);
2662:                 }
2663:
2664:               /* Update the maximum size of the array in elements.  Here we
2665:                  see if any constraint on the index type of the base type
2666:                  can be used in the case of self-referential bounds on the
2667:                  index type of the array type. We look for a non-"infinite"
2668:                  and non-self-referential bound from any type involved and
2669:                  handle each bound separately.  */
2670:               if (gnu_max_size)
2671:                 {
2672:                   if (CONTAINS_PLACEHOLDER_P (gnu_orig_min))
2673:                     gnu_min = gnu_base_orig_min;
2674:                   else
2675:                     gnu_min = gnu_orig_min;
2676:
2677:                   if (DECL_P (gnu_min)
2678:                       && DECL_INITIAL (gnu_min) != NULL_TREE
2679:                       && (TREE_CODE (gnu_min) != INTEGER_CST
2680:                           || TREE_OVERFLOW (gnu_min)))
2681:                     {
2682:                       tree tmp = max_value (DECL_INITIAL(gnu_min), false);
2683:                       if (TREE_CODE (tmp) == INTEGER_CST
2684:                           && !TREE_OVERFLOW (tmp))
2685:                         gnu_min = tmp;
2686:                     }
2687:
2688:                   if (TREE_CODE (gnu_min) != INTEGER_CST
2689:                       || TREE_OVERFLOW (gnu_min))
2690:                     gnu_min = TYPE_MIN_VALUE (TREE_TYPE (gnu_min));
2691:
2692:                   if (CONTAINS_PLACEHOLDER_P (gnu_orig_max))
2693:                     gnu_max = gnu_base_orig_max;
2694:                   else
2695:                     gnu_max = gnu_orig_max;
2696:
2697:                   if (DECL_P (gnu_max)
2698:                       && DECL_INITIAL (gnu_max) != NULL_TREE
2699:                       && (TREE_CODE (gnu_max) != INTEGER_CST
2700:                           || TREE_OVERFLOW (gnu_max)))
2701:                     {
2702:                       tree tmp = max_value (DECL_INITIAL(gnu_max), true);
2703:                       if (TREE_CODE (tmp) == INTEGER_CST
2704:                           && !TREE_OVERFLOW (tmp))
2705:                         gnu_max = tmp;
2706:                     }
2707:
2708:                   if (TREE_CODE (gnu_max) != INTEGER_CST
2709:                       || TREE_OVERFLOW (gnu_max))
2710:                     gnu_max = TYPE_MAX_VALUE (TREE_TYPE (gnu_max));
2711:
2712:                   gnu_max_size
2713:                     = update_n_elem (gnu_max_size, gnu_min, gnu_max);
2714:                 }
2715:
2716:               /* Convert the bounds to the base type for consistency below.  */
2717:               gnu_index_base_type = maybe_character_type (gnu_index_base_type);
2718:               gnu_orig_min = convert (gnu_index_base_type, gnu_orig_min);
2719:               gnu_orig_max = convert (gnu_index_base_type, gnu_orig_max);
2720:
2721:               gnu_min = convert (sizetype, gnu_orig_min);
2722:               gnu_max = convert (sizetype, gnu_orig_max);
2723:
2724:               /* See if the base array type is already flat.  If it is, we
2725:                  are probably compiling an ACATS test but it will cause the
2726:                  code below to malfunction if we don't handle it specially.  */
2727:               if (TREE_CODE (gnu_base_orig_min) == INTEGER_CST
2728:                   && TREE_CODE (gnu_base_orig_max) == INTEGER_CST
2729:                   && tree_int_cst_lt (gnu_base_orig_max, gnu_base_orig_min))
2730:                 {
2731:                   gnu_min = size_one_node;
2732:                   gnu_max = size_zero_node;
2733:                   gnu_high = gnu_max;
2734:                 }
2735:
2736:               /* Similarly, if one of the values overflows in sizetype and the
2737:                  range is null, use 1..0 for the sizetype bounds.  */
2738:               else if (TREE_CODE (gnu_min) == INTEGER_CST
2739:                        && TREE_CODE (gnu_max) == INTEGER_CST
2740:                        && (TREE_OVERFLOW (gnu_min) || TREE_OVERFLOW (gnu_max))
2741:                        && tree_int_cst_lt (gnu_orig_max, gnu_orig_min))
2742:                 {
2743:                   gnu_min = size_one_node;
2744:                   gnu_max = size_zero_node;
2745:                   gnu_high = gnu_max;
2746:                 }
2747:
2748:               /* If the minimum and maximum values both overflow in sizetype,
2749:                  but the difference in the original type does not overflow in
2750:                  sizetype, ignore the overflow indication.  */
2751:               else if (TREE_CODE (gnu_min) == INTEGER_CST
2752:                        && TREE_CODE (gnu_max) == INTEGER_CST
2753:                        && TREE_OVERFLOW (gnu_min) && TREE_OVERFLOW (gnu_max)
2754:                        && !TREE_OVERFLOW
2755:                            (convert (sizetype,
2756:                                      fold_build2 (MINUS_EXPR,
2757:                                                   gnu_index_base_type,
2758:                                                   gnu_orig_max,
2759:                                                   gnu_orig_min))))
2760:                 {
2761:                   TREE_OVERFLOW (gnu_min) = 0;
2762:                   TREE_OVERFLOW (gnu_max) = 0;
2763:                   gnu_high = gnu_max;
2764:                 }
2765:
2766:               /* Compute the size of this dimension in the general case.  We
2767:                  need to provide GCC with an upper bound to use but have to
2768:                  deal with the "superflat" case.  There are three ways to do
2769:                  this.  If we can prove that the array can never be superflat,
2770:                  we can just use the high bound of the index type.  */
2771:               else if ((Nkind (gnat_index) == N_Range
2772:                         && range_cannot_be_superflat (gnat_index))
2773:                        /* Bit-Packed Array Impl. Types are never superflat.  */
2774:                        || (Is_Packed_Array_Impl_Type (gnat_entity)
2775:                            && Is_Bit_Packed_Array
2776:                               (Original_Array_Type (gnat_entity))))
2777:                 gnu_high = gnu_max;
2778:
2779:               /* Otherwise, if the high bound is constant but the low bound is
2780:                  not, we use the expression (hb >= lb) ? lb : hb + 1 for the
2781:                  lower bound.  Note that the comparison must be done in the
2782:                  original type to avoid any overflow during the conversion.  */
2783:               else if (TREE_CODE (gnu_max) == INTEGER_CST
2784:                        && TREE_CODE (gnu_min) != INTEGER_CST)
2785:                 {
2786:                   gnu_high = gnu_max;
2787:                   gnu_min
2788:                     = build_cond_expr (sizetype,
2789:                                        build_binary_op (GE_EXPR,
2790:                                                         boolean_type_node,
2791:                                                         gnu_orig_max,
2792:                                                         gnu_orig_min),
2793:                                        gnu_min,
2794:                                        int_const_binop (PLUS_EXPR, gnu_max,
2795:                                                         size_one_node));
2796:                 }
2797:
2798:               /* Finally we use (hb >= lb) ? hb : lb - 1 for the upper bound
2799:                  in all the other cases.  Note that we use int_const_binop for
2800:                  the shift by 1 if the bound is constant to avoid any unwanted
2801:                  overflow.  */
2802:               else
2803:                 gnu_high
2804:                   = build_cond_expr (sizetype,
2805:                                      build_binary_op (GE_EXPR,
2806:                                                       boolean_type_node,
2807:                                                       gnu_orig_max,
2808:                                                       gnu_orig_min),
2809:                                      gnu_max,
2810:                                      TREE_CODE (gnu_min) == INTEGER_CST
2811:                                      ? int_const_binop (MINUS_EXPR, gnu_min,
2812:                                                         size_one_node)
2813:                                      : size_binop (MINUS_EXPR, gnu_min,
2814:                                                    size_one_node));
2815:
2816:               /* Reuse the index type for the range type.  Then make an index
2817:                  type with the size range in sizetype.  */
2818:               gnu_index_types[index]
2819:                 = create_index_type (gnu_min, gnu_high, gnu_index_type,
2820:                                      gnat_entity);
2821:
2822:               /* Record whether the range is known to be null at compile time
2823:                  to disambiguate it from too large ranges.  */
2824:               const Entity_Id gnat_ui_type = Underlying_Type (gnat_index_type);
2825:               gnu_null_ranges[index]
2826:                 = Is_Null_Range (Type_Low_Bound (gnat_ui_type),
2827:                                  Type_High_Bound (gnat_ui_type));
2828:
2829:               /* We need special types for debugging information to point to
2830:                  the index types if they have variable bounds, are not integer
2831:                  types, are biased or are wider than sizetype.  These are GNAT
2832:                  encodings, so we have to include them only when all encodings
2833:                  are requested.  */
2834:               if ((TREE_CODE (gnu_orig_min) != INTEGER_CST
2835:                    || TREE_CODE (gnu_orig_max) != INTEGER_CST
2836:                    || TREE_CODE (gnu_index_type) != INTEGER_TYPE
2837:                    || (TREE_TYPE (gnu_index_type)
2838:                        && TREE_CODE (TREE_TYPE (gnu_index_type))
2839:                           != INTEGER_TYPE)
2840:                    || TYPE_BIASED_REPRESENTATION_P (gnu_index_type))
2841:                   && gnat_encodings == DWARF_GNAT_ENCODINGS_ALL)
2842:                 need_index_type_struct = true;
2843:             }
2844:
2845:           /* Then flatten: create the array of arrays.  For an array type
2846:              used to implement a packed array, get the component type from
2847:              the original array type since the representation clauses that
2848:              can affect it are on the latter.  */
2849:           if (Is_Packed_Array_Impl_Type (gnat_entity)
2850:               && !Is_Bit_Packed_Array (Original_Array_Type (gnat_entity)))
2851:             {
2852:               gnu_type = gnat_to_gnu_type (Original_Array_Type (gnat_entity));
2853:               for (index = ndim - 1; index >= 0; index--)
2854:                 gnu_type = TREE_TYPE (gnu_type);
2855:
2856:               /* One of the above calls might have caused us to be elaborated,
2857:                  so don't blow up if so.  */
2858:               if (present_gnu_tree (gnat_entity))
2859:                 {
2860:                   maybe_present = true;
2861:                   break;
2862:                 }
2863:             }
2864:           else
2865:             {
2866:               gnu_type = gnat_to_gnu_component_type (gnat_entity, definition,
2867:                                                      debug_info_p);
2868:
2869:               /* One of the above calls might have caused us to be elaborated,
2870:                  so don't blow up if so.  */
2871:               if (present_gnu_tree (gnat_entity))
2872:                 {
2873:                   maybe_present = true;
2874:                   break;
2875:                 }
2876:             }
2877:
2878:           /* Compute the maximum size of the array in units.  */
2879:           if (gnu_max_size)
2880:             gnu_max_size
2881:               = size_binop (MULT_EXPR, gnu_max_size, TYPE_SIZE_UNIT (gnu_type));
2882:
2883:           /* Now build the array type.  */
2884:           for (index = ndim - 1; index >= 0; index --)
2885:             {
2886:               gnu_type = build_nonshared_array_type (gnu_type,
2887:                                                      gnu_index_types[index]);
2888:               TYPE_MULTI_ARRAY_P (gnu_type) = (index > 0);
2889:               TYPE_CONVENTION_FORTRAN_P (gnu_type) = convention_fortran_p;
2890:               if (index == ndim - 1 && Reverse_Storage_Order (gnat_entity))
2891:                 set_reverse_storage_order_on_array_type (gnu_type);
2892:               if (array_type_has_nonaliased_component (gnu_type, gnat_entity))
2893:                 set_nonaliased_component_on_array_type (gnu_type);
2894:               if (Universal_Aliasing (gnat_entity)
2895:                   || Universal_Aliasing (Component_Type (gnat_entity)))
2896:                 set_typeless_storage_on_aggregate_type (gnu_type);
2897:
2898:               /* Clear the TREE_OVERFLOW flag, if any, for null arrays.  */
2899:               if (gnu_null_ranges[index])
2900:                 {
2901:                   TYPE_SIZE (gnu_type) = bitsize_zero_node;
2902:                   TYPE_SIZE_UNIT (gnu_type) = size_zero_node;
2903:                 }
2904:
2905:               /* Kludge to clear the TREE_OVERFLOW flag for the sake of LTO
2906:                  on maximally-sized array types designed by access types.  */
2907:               if (integer_zerop (TYPE_SIZE (gnu_type))
2908:                   && TREE_OVERFLOW (TYPE_SIZE (gnu_type))
2909:                   && Is_Itype (gnat_entity)
2910:                   && (gnat_temp = Associated_Node_For_Itype (gnat_entity))
2911:                   && IN (Nkind (gnat_temp), N_Declaration)
2912:                   && Is_Access_Type (Defining_Entity (gnat_temp))
2913:                   && Is_Entity_Name (First_Index (gnat_entity))
2914:                   && UI_To_Int (RM_Size (Entity (First_Index (gnat_entity))))
2915:                      == BITS_PER_WORD)
2916:                 {
2917:                   TYPE_SIZE (gnu_type) = bitsize_zero_node;
2918:                   TYPE_SIZE_UNIT (gnu_type) = size_zero_node;
2919:                 }
2920:             }
2921:
2922:           /* Attach the TYPE_STUB_DECL in case we have a parallel type.  */
2923:           TYPE_STUB_DECL (gnu_type)
2924:             = create_type_stub_decl (gnu_entity_name, gnu_type);
2925:
2926:           /* If this is a multi-dimensional array and we are at global level,
2927:              we need to make a variable corresponding to the stride of the
2928:              inner dimensions.   */
2929:           if (ndim > 1 && global_bindings_p ())
2930:             {
2931:               tree gnu_arr_type;
2932:
2933:               for (gnu_arr_type = TREE_TYPE (gnu_type), index = 1;
2934:                    TREE_CODE (gnu_arr_type) == ARRAY_TYPE;
2935:                    gnu_arr_type = TREE_TYPE (gnu_arr_type), index++)
2936:                 {
2937:                   tree eltype = TREE_TYPE (gnu_arr_type);
2938:                   char stride_name[32];
2939:
2940:                   sprintf (stride_name, "ST%d", index);
2941:                   TYPE_SIZE (gnu_arr_type)
2942:                     = elaborate_expression_1 (TYPE_SIZE (gnu_arr_type),
2943:                                               gnat_entity, stride_name,
2944:                                               definition, false);
2945:
2946:                   /* ??? For now, store the size as a multiple of the
2947:                      alignment of the element type in bytes so that we
2948:                      can see the alignment from the tree.  */
2949:                   sprintf (stride_name, "ST%d_A_UNIT", index);
2950:                   TYPE_SIZE_UNIT (gnu_arr_type)
2951:                     = elaborate_expression_2 (TYPE_SIZE_UNIT (gnu_arr_type),
2952:                                               gnat_entity, stride_name,
2953:                                               definition, false,
2954:                                               TYPE_ALIGN (eltype));
2955:
2956:                   /* ??? create_type_decl is not invoked on the inner types so
2957:                      the MULT_EXPR node built above will never be marked.  */
2958:                   MARK_VISITED (TYPE_SIZE_UNIT (gnu_arr_type));
2959:                 }
2960:             }
2961:
2962:           /* Set the TYPE_PACKED flag on packed array types and also on their
2963:              implementation types, so that the DWARF back-end can output the
2964:              appropriate description for them.  */
2965:           TYPE_PACKED (gnu_type)
2966:             = (Is_Packed (gnat_entity)
2967:                || Is_Packed_Array_Impl_Type (gnat_entity));
2968:
2969:           TYPE_BIT_PACKED_ARRAY_TYPE_P (gnu_type)
2970:             = (Is_Packed_Array_Impl_Type (gnat_entity)
2971:                ? Is_Bit_Packed_Array (Original_Array_Type (gnat_entity))
2972:                : Is_Bit_Packed_Array (gnat_entity));
2973:
2974:           /* If the maximum size doesn't overflow, use it.  */
2975:           if (gnu_max_size
2976:               && TREE_CODE (gnu_max_size) == INTEGER_CST
2977:               && !TREE_OVERFLOW (gnu_max_size)
2978:               && compare_tree_int (gnu_max_size, TYPE_ARRAY_SIZE_LIMIT) <= 0)
2979:             TYPE_ARRAY_MAX_SIZE (gnu_type) = gnu_max_size;
2980:
2981:           /* If we need to write out a record type giving the names of the
2982:              bounds for debugging purposes, do it now and make the record
2983:              type a parallel type.  This is not needed for a packed array
2984:              since the bounds are conveyed by the original array type.  */
2985:           if (need_index_type_struct
2986:               && debug_info_p
2987:               && !Is_Packed_Array_Impl_Type (gnat_entity))
2988:             {
2989:               tree gnu_bound_rec = make_node (RECORD_TYPE);
2990:               tree gnu_field_list = NULL_TREE;
2991:               tree gnu_field;
2992:
2993:               TYPE_NAME (gnu_bound_rec)
2994:                 = create_concat_name (gnat_entity, "XA");
2995:
2996:               for (index = ndim - 1; index >= 0; index--)
2997:                 {
2998:                   tree gnu_index = TYPE_INDEX_TYPE (gnu_index_types[index]);
2999:                   tree gnu_index_name = TYPE_IDENTIFIER (gnu_index);
3000:
3001:                   /* Make sure to reference the types themselves, and not just
3002:                      their names, as the debugger may fall back on them.  */
3003:                   gnu_field = create_field_decl (gnu_index_name, gnu_index,
3004:                                                  gnu_bound_rec, NULL_TREE,
3005:                                                  NULL_TREE, 0, 0);
3006:                   DECL_CHAIN (gnu_field) = gnu_field_list;
3007:                   gnu_field_list = gnu_field;
3008:                 }
3009:
3010:               finish_record_type (gnu_bound_rec, gnu_field_list, 0, true);
3011:               add_parallel_type (gnu_type, gnu_bound_rec);
3012:             }
3013:
3014:           /* If this is a packed array type, make the original array type a
3015:              parallel/debug type.  Otherwise, if GNAT encodings are used, do
3016:              it for the base array type if it is not artificial to make sure
3017:              that it is kept in the debug info.  */
3018:           if (debug_info_p)
3019:             {
3020:               if (Is_Packed_Array_Impl_Type (gnat_entity))
3021:                 {
3022:                   tree gnu_name
3023:                     = associate_original_type_to_packed_array (gnu_type,
3024:                                                                gnat_entity);
3025:                   if (gnu_name)
3026:                     gnu_entity_name = gnu_name;
3027:                 }
3028:
3029:               else if (gnat_encodings == DWARF_GNAT_ENCODINGS_ALL)
3030:                 {
3031:                   tree gnu_base_decl
3032:                     = gnat_to_gnu_entity (Etype (gnat_entity), NULL_TREE,
3033:                                           false);
3034:
3035:                   if (!DECL_ARTIFICIAL (gnu_base_decl))
3036:                     add_parallel_type (gnu_type,
3037:                                        TREE_TYPE (TREE_TYPE (gnu_base_decl)));
3038:                 }
3039:             }
3040:
3041:           /* Set our alias set to that of our base type.  This gives all
3042:              array subtypes the same alias set.  */
3043:           relate_alias_sets (gnu_type, gnu_base_type, ALIAS_SET_COPY);
3044:
3045:           /* If this is a packed type implemented specially, then replace our
3046:              type with the implementation type.  */
3047:           if (Present (PAT))
3048:             {
3049:               /* First finish the type we had been making so that we output
3050:                  debugging information for it.  */
3051:               process_attributes (&gnu_type, &attr_list, false, gnat_entity);
3052:               if (Treat_As_Volatile (gnat_entity))
3053:                 {
3054:                   const int quals
3055:                     = TYPE_QUAL_VOLATILE
3056:                       | (Is_Full_Access (gnat_entity) ? TYPE_QUAL_ATOMIC : 0);
3057:                   gnu_type = change_qualified_type (gnu_type, quals);
3058:                 }
3059:               /* Make it artificial only if the base type was artificial too.
3060:                  That's sort of "morally" true and will make it possible for
3061:                  the debugger to look it up by name in DWARF, which is needed
3062:                  in order to decode the packed array type.  */
3063:               tree gnu_tmp_decl
3064:                 = create_type_decl (gnu_entity_name, gnu_type,
3065:                                     is_artificial (Etype (gnat_entity))
3066:                                     && artificial_p, debug_info_p,
3067:                                     gnat_entity, false);
3068:               /* Save it as our equivalent in case the call below elaborates
3069:                  this type again.  */
3070:               save_gnu_tree (gnat_entity, gnu_tmp_decl, false);
3071:
3072:               gnu_type = gnat_to_gnu_type (PAT);
3073:               save_gnu_tree (gnat_entity, NULL_TREE, false);
3074:
3075:               /* Set the ___XP suffix for GNAT encodings.  */
3076:               if (gnat_encodings == DWARF_GNAT_ENCODINGS_ALL)
3077:                 gnu_entity_name = DECL_NAME (TYPE_NAME (gnu_type));
3078:
3079:               tree gnu_inner = gnu_type;
3080:               while (TREE_CODE (gnu_inner) == RECORD_TYPE
3081:                      && (TYPE_JUSTIFIED_MODULAR_P (gnu_inner)
3082:                          || TYPE_PADDING_P (gnu_inner)))
3083:                 gnu_inner = TREE_TYPE (TYPE_FIELDS (gnu_inner));
3084:
3085:               /* We need to attach the index type to the type we just made so
3086:                  that the actual bounds can later be put into a template.  */
3087:               if ((TREE_CODE (gnu_inner) == ARRAY_TYPE
3088:                    && !TYPE_ACTUAL_BOUNDS (gnu_inner))
3089:                   || (TREE_CODE (gnu_inner) == INTEGER_TYPE
3090:                       && !TYPE_HAS_ACTUAL_BOUNDS_P (gnu_inner)))
3091:                 {
3092:                   if (TREE_CODE (gnu_inner) == INTEGER_TYPE)
3093:                     {
3094:                       /* The TYPE_ACTUAL_BOUNDS field is overloaded with the
3095:                          TYPE_MODULUS for modular types so we make an extra
3096:                          subtype if necessary.  */
3097:                       if (TYPE_MODULAR_P (gnu_inner))
3098:                         gnu_inner
3099:                           = create_extra_subtype (gnu_inner,
3100:                                                   TYPE_MIN_VALUE (gnu_inner),
3101:                                                   TYPE_MAX_VALUE (gnu_inner));
3102:
3103:                       TYPE_HAS_ACTUAL_BOUNDS_P (gnu_inner) = 1;
3104:
3105:                       /* Check for other cases of overloading.  */
3106:                       gcc_checking_assert (!TYPE_ACTUAL_BOUNDS (gnu_inner));
3107:                     }
3108:
3109:                   for (Entity_Id gnat_index = First_Index (gnat_entity);
3110:                        Present (gnat_index);
3111:                        gnat_index = Next_Index (gnat_index))
3112:                     SET_TYPE_ACTUAL_BOUNDS
3113:                       (gnu_inner,
3114:                        tree_cons (NULL_TREE,
3115:                                   get_unpadded_type (Etype (gnat_index)),
3116:                                   TYPE_ACTUAL_BOUNDS (gnu_inner)));
3117:
3118:                   if (Convention (gnat_entity) != Convention_Fortran)
3119:                     SET_TYPE_ACTUAL_BOUNDS
3120:                       (gnu_inner, nreverse (TYPE_ACTUAL_BOUNDS (gnu_inner)));
3121:
3122:                   if (TREE_CODE (gnu_type) == RECORD_TYPE
3123:                       && TYPE_JUSTIFIED_MODULAR_P (gnu_type))
3124:                     TREE_TYPE (TYPE_FIELDS (gnu_type)) = gnu_inner;
3125:                 }
3126:             }
3127:
3128:           /* Otherwise, if an alignment is specified, use it if valid and, if
3129:              the alignment was requested with an explicit clause, state so.  */
3130:           else if (Known_Alignment (gnat_entity))
3131:             {
3132:               SET_TYPE_ALIGN (gnu_type,
3133:                               validate_alignment (Alignment (gnat_entity),
3134:                                                   gnat_entity,
3135:                                                   TYPE_ALIGN (gnu_type)));
3136:               if (Present (Alignment_Clause (gnat_entity)))
3137:                 TYPE_USER_ALIGN (gnu_type) = 1;
3138:             }
3139:         }
3140:       break;
3141:
3142:     case E_String_Literal_Subtype:
3143:       /* Create the type for a string literal.  */
3144:       {
3145:         Entity_Id gnat_full_type
3146:           = (Is_Private_Type (Etype (gnat_entity))
3147:              && Present (Full_View (Etype (gnat_entity)))
3148:              ? Full_View (Etype (gnat_entity)) : Etype (gnat_entity));
3149:         tree gnu_string_type = get_unpadded_type (gnat_full_type);
3150:         tree gnu_string_array_type
3151:           = TREE_TYPE (TREE_TYPE (TYPE_FIELDS (TREE_TYPE (gnu_string_type))));
3152:         tree gnu_string_index_type
3153:           = get_base_type (TREE_TYPE (TYPE_INDEX_TYPE
3154:                                       (TYPE_DOMAIN (gnu_string_array_type))));
3155:
3156:         /* For a null string literal we set the bounds to 1 .. 0, to
3157:            avoid a possible overflow when calculating the upper bound
3158:            as LOWER_BOUND + LENGTH - 1.  */
3159:         const bool is_null_string
3160:           = String_Literal_Length (gnat_entity) == Uint_0;
3161:         tree gnu_lower_bound
3162:           = is_null_string ?
3163:             build_int_cst (gnu_string_index_type, 1) :
3164:             convert (gnu_string_index_type,
3165:                      gnat_to_gnu (String_Literal_Low_Bound (gnat_entity)));
3166:         tree gnu_length
3167:           = UI_To_gnu (String_Literal_Length (gnat_entity),
3168:                        gnu_string_index_type);
3169:         tree gnu_upper_bound
3170:           = is_null_string ?
3171:             build_int_cst (gnu_string_index_type, 0) :
3172:             build_binary_op (PLUS_EXPR, gnu_string_index_type,
3173:                              gnu_lower_bound,
3174:                              int_const_binop (MINUS_EXPR, gnu_length,
3175:                                               convert (gnu_string_index_type,
3176:                                                        integer_one_node)));
3177:         tree gnu_index_type
3178:           = create_index_type (convert (sizetype, gnu_lower_bound),
3179:                                convert (sizetype, gnu_upper_bound),
3180:                                create_range_type (gnu_string_index_type,
3181:                                                   gnu_lower_bound,
3182:                                                   gnu_upper_bound),
3183:                                gnat_entity);
3184:
3185:         gnu_type
3186:           = build_nonshared_array_type (gnat_to_gnu_type
3187:                                         (Component_Type (gnat_entity)),
3188:                                         gnu_index_type);
3189:         if (array_type_has_nonaliased_component (gnu_type, gnat_entity))
3190:           set_nonaliased_component_on_array_type (gnu_type);
3191:         relate_alias_sets (gnu_type, gnu_string_type, ALIAS_SET_COPY);
3192:       }
3193:       break;
```

## gcc/ada/gcc-interface/decl.cc:3810–4056

```text
3810:     case E_Access_Attribute_Type:
3811:     case E_Anonymous_Access_Type:
3812:     case E_General_Access_Type:
3813:       {
3814:         /* The designated type and its equivalent type for gigi.  */
3815:         Entity_Id gnat_desig_type = Directly_Designated_Type (gnat_entity);
3816:         Entity_Id gnat_desig_equiv = Gigi_Equivalent_Type (gnat_desig_type);
3817:         /* Whether it comes from a limited with.  */
3818:         const bool is_from_limited_with
3819:           = (Is_Incomplete_Type (gnat_desig_equiv)
3820:              && From_Limited_With (gnat_desig_equiv));
3821:         /* Whether it is a completed Taft Amendment type.  Such a type is to
3822:            be treated as coming from a limited with clause if it is not in
3823:            the main unit, i.e. we break potential circularities here in case
3824:            the body of an external unit is loaded for inter-unit inlining.  */
3825:         const bool is_completed_taft_type
3826:           = (Is_Incomplete_Type (gnat_desig_equiv)
3827:              && Has_Completion_In_Body (gnat_desig_equiv)
3828:              && Present (Full_View (gnat_desig_equiv)));
3829:         /* The "full view" of the designated type.  If this is an incomplete
3830:            entity from a limited with, treat its non-limited view as the full
3831:            view.  Otherwise, if this is an incomplete or private type, use the
3832:            full view.  In the former case, we might point to a private type,
3833:            in which case, we need its full view.  Also, we want to look at the
3834:            actual type used for the representation, so this takes a total of
3835:            three steps.  */
3836:         Entity_Id gnat_desig_full_direct_first
3837:           = (is_from_limited_with
3838:              ? Non_Limited_View (gnat_desig_equiv)
3839:              : (Is_Incomplete_Or_Private_Type (gnat_desig_equiv)
3840:                 ? Full_View (gnat_desig_equiv) : Empty));
3841:         Entity_Id gnat_desig_full_direct
3842:           = ((is_from_limited_with
3843:               && Present (gnat_desig_full_direct_first)
3844:               && Is_Private_Type (gnat_desig_full_direct_first))
3845:              ? Full_View (gnat_desig_full_direct_first)
3846:              : gnat_desig_full_direct_first);
3847:         Entity_Id gnat_desig_full
3848:           = Gigi_Equivalent_Type (gnat_desig_full_direct);
3849:         /* The type actually used to represent the designated type, either
3850:            gnat_desig_full or gnat_desig_equiv.  */
3851:         Entity_Id gnat_desig_rep;
3852:         /* We want to know if we'll be seeing the freeze node for any
3853:            incomplete type we may be pointing to.  */
3854:         const bool in_main_unit
3855:           = (Present (gnat_desig_full)
3856:              ? In_Extended_Main_Code_Unit (gnat_desig_full)
3857:              : In_Extended_Main_Code_Unit (gnat_desig_type));
3858:         /* True if we make a dummy type here.  */
3859:         bool made_dummy = false;
3860:         /* The mode to be used for the pointer type.  */
3861:         scalar_int_mode p_mode;
3862:         /* The GCC type used for the designated type.  */
3863:         tree gnu_desig_type = NULL_TREE;
3864:
3865:         if (!int_mode_for_size (esize, 0).exists (&p_mode)
3866:             || !targetm.valid_pointer_mode (p_mode))
3867:           p_mode = ptr_mode;
3868:
3869:         /* If either the designated type or its full view is an unconstrained
3870:            array subtype, replace it with the type it's a subtype of.  This
3871:            avoids problems with multiple copies of unconstrained array types.
3872:            Likewise, if the designated type is a subtype of an incomplete
3873:            record type, use the parent type to avoid order of elaboration
3874:            issues.  This can lose some code efficiency, but there is no
3875:            alternative.  */
3876:         if (Ekind (gnat_desig_equiv) == E_Array_Subtype
3877:             && !Is_Constrained (gnat_desig_equiv))
3878:           gnat_desig_equiv = Etype (gnat_desig_equiv);
3879:         if (Present (gnat_desig_full)
3880:             && ((Ekind (gnat_desig_full) == E_Array_Subtype
3881:                  && !Is_Constrained (gnat_desig_full))
3882:                 || (Ekind (gnat_desig_full) == E_Record_Subtype
3883:                     && Ekind (Etype (gnat_desig_full)) == E_Record_Type)))
3884:           gnat_desig_full = Etype (gnat_desig_full);
3885:
3886:         /* Set the type that's the representation of the designated type.  */
3887:         gnat_desig_rep
3888:           = Present (gnat_desig_full) ? gnat_desig_full : gnat_desig_equiv;
3889:
3890:         /* If we already know what the full type is, use it.  */
3891:         if (Present (gnat_desig_full) && present_gnu_tree (gnat_desig_full))
3892:           gnu_desig_type = TREE_TYPE (get_gnu_tree (gnat_desig_full));
3893:
3894:         /* Get the type of the thing we are to point to and build a pointer to
3895:            it.  If it is a reference to an incomplete or private type with a
3896:            full view that is a record, an array or an access, make a dummy type
3897:            and get the actual type later when we have verified it is safe.  */
3898:         else if ((!in_main_unit
3899:                   && !present_gnu_tree (gnat_desig_equiv)
3900:                   && Present (gnat_desig_full)
3901:                   && (Is_Record_Type (gnat_desig_full)
3902:                       || Is_Array_Type (gnat_desig_full)
3903:                       || Is_Access_Type (gnat_desig_full)))
3904:                  /* Likewise if this is a reference to a record, an array or a
3905:                     subprogram type and we are to defer elaborating incomplete
3906:                     types.  We do this because this access type may be the full
3907:                     view of a private type.  */
3908:                  || ((!in_main_unit || imported_p)
3909:                      && defer_incomplete_level != 0
3910:                      && !present_gnu_tree (gnat_desig_equiv)
3911:                      && (Is_Record_Type (gnat_desig_rep)
3912:                          || Is_Array_Type (gnat_desig_rep)
3913:                          || Ekind (gnat_desig_rep) == E_Subprogram_Type))
3914:                  /* If this is a reference from a limited_with type back to our
3915:                     main unit and there's a freeze node for it, either we have
3916:                     already processed the declaration and made the dummy type,
3917:                     in which case we just reuse the latter, or we have not yet,
3918:                     in which case we make the dummy type and it will be reused
3919:                     when the declaration is finally processed.  In both cases,
3920:                     the pointer eventually created below will be automatically
3921:                     adjusted when the freeze node is processed.  */
3922:                  || (in_main_unit
3923:                      && is_from_limited_with
3924:                      && Present (Freeze_Node (gnat_desig_rep))))
3925:           {
3926:             gnu_desig_type = make_dummy_type (gnat_desig_equiv);
3927:             made_dummy = true;
3928:           }
3929:
3930:         /* Otherwise handle the case of a pointer to itself.  */
3931:         else if (gnat_desig_equiv == gnat_entity)
3932:           {
3933:             gnu_type
3934:               = build_pointer_type_for_mode (void_type_node, p_mode,
3935:                                              No_Strict_Aliasing (gnat_entity));
3936:             TREE_TYPE (gnu_type) = TYPE_POINTER_TO (gnu_type) = gnu_type;
3937:           }
3938:
3939:         /* If expansion is disabled, the equivalent type of a concurrent type
3940:            is absent, so we use the void pointer type.  */
3941:         else if (type_annotate_only && No (gnat_desig_equiv))
3942:           gnu_type = ptr_type_node;
3943:
3944:         /* If the ultimately designated type is an incomplete type with no full
3945:            view, we use the void pointer type in LTO mode to avoid emitting a
3946:            dummy type in the GIMPLE IR.  We cannot do that in regular mode as
3947:            the name of the dummy type in used by GDB for a global lookup.  */
3948:         else if (Ekind (gnat_desig_rep) == E_Incomplete_Type
3949:                  && No (Full_View (gnat_desig_rep))
3950:                  && flag_generate_lto)
3951:           gnu_type = ptr_type_node;
3952:
3953:         /* Finally, handle the default case where we can just elaborate our
3954:            designated type.  */
3955:         else
3956:           gnu_desig_type = gnat_to_gnu_type (gnat_desig_equiv);
3957:
3958:         /* It is possible that a call to gnat_to_gnu_type above resolved our
3959:            type.  If so, just return it.  */
3960:         if (present_gnu_tree (gnat_entity))
3961:           {
3962:             maybe_present = true;
3963:             break;
3964:           }
3965:
3966:         /* Access-to-unconstrained-array types need a special treatment.  */
3967:         if (Is_Array_Type (gnat_desig_rep)
3968:             && !Is_Constrained (gnat_desig_rep)
3969:             && !Is_Extended_Access_Type (gnat_entity))
3970:           {
3971:             /* If the processing above got something that has a pointer, then
3972:                we are done.  This could have happened either because the type
3973:                was elaborated or because somebody else executed the code.  */
3974:             if (!TYPE_POINTER_TO (gnu_desig_type))
3975:               build_dummy_unc_pointer_types (gnat_desig_equiv, gnu_desig_type);
3976:
3977:             gnu_type = TYPE_POINTER_TO (gnu_desig_type);
3978:           }
3979:
3980:         else if (Is_Array_Type (gnat_desig_rep)
3981:                  && !Is_Constrained (gnat_desig_rep)
3982:                  && Is_Extended_Access_Type (gnat_entity))
3983:           {
3984:             if (TYPE_IS_DUMMY_P (gnu_desig_type))
3985:               gnu_type
3986:                 = build_dummy_unc_pointer_types_ext (gnat_desig_rep,
3987:                                                      gnu_desig_type);
3988:             else
3989:               {
3990:                 tree gnu_extended_type
3991:                   = get_extended_unconstrained_array (gnat_desig_rep,
3992:                                                       gnu_desig_type);
3993:
3994:                 /* We should not get a dummy type.  */
3995:                 gnu_type = TYPE_POINTER_TO (gnu_extended_type);
3996:                 gcc_assert (gnu_type);
3997:               }
3998:           }
3999:
4000:         /* If we haven't done it yet, build the pointer type the usual way.  */
4001:         else if (!gnu_type)
4002:           {
4003:             /* Modify the designated type if we are pointing only to constant
4004:                objects, but don't do it for a dummy type.  */
4005:             if (Is_Access_Constant (gnat_entity)
4006:                 && !TYPE_IS_DUMMY_P (gnu_desig_type))
4007:               gnu_desig_type
4008:                 = change_qualified_type (gnu_desig_type, TYPE_QUAL_CONST);
4009:
4010:             gnu_type
4011:               = build_pointer_type_for_mode (gnu_desig_type, p_mode,
4012:                                              No_Strict_Aliasing (gnat_entity));
4013:           }
4014:
4015:         /* If the designated type is not declared in the main unit and we made
4016:            a dummy node for it, save our definition, elaborate the actual type
4017:            and replace the dummy type we made with the actual one.  But if we
4018:            are to defer actually looking up the actual type, make an entry in
4019:            the deferred list instead.  If this is from a limited with, we may
4020:            have to defer until the end of the current unit.  */
4021:         if (!in_main_unit && made_dummy)
4022:           {
4023:             if (TYPE_IS_FAT_POINTER_P (gnu_type) && esize == POINTER_SIZE)
4024:               gnu_type
4025:                 = build_pointer_type (TYPE_OBJECT_RECORD_TYPE (gnu_desig_type));
4026:
4027:             process_attributes (&gnu_type, &attr_list, false, gnat_entity);
4028:             gnu_decl = create_type_decl (gnu_entity_name, gnu_type,
4029:                                          artificial_p, debug_info_p,
4030:                                          gnat_entity);
4031:             this_made_decl = true;
4032:             gnu_type = TREE_TYPE (gnu_decl);
4033:             save_gnu_tree (gnat_entity, gnu_decl, false);
4034:             saved = true;
4035:
4036:             if (defer_incomplete_level == 0
4037:                 && !is_from_limited_with
4038:                 && !is_completed_taft_type)
4039:               {
4040:                 update_pointer_to (TYPE_MAIN_VARIANT (gnu_desig_type),
4041:                                    gnat_to_gnu_type (gnat_desig_equiv));
4042:               }
4043:             else
4044:               {
4045:                 struct incomplete *p = XNEW (struct incomplete);
4046:                 struct incomplete **head
4047:                   = (is_from_limited_with || is_completed_taft_type
4048:                      ? &defer_limited_with_list : &defer_incomplete_list);
4049:
4050:                 p->old_type = gnu_desig_type;
4051:                 p->full_type = gnat_desig_equiv;
4052:                 p->next = *head;
4053:                 *head = p;
4054:               }
4055:           }
4056:       }
```

## gcc/ada/gcc-interface/decl.cc:4530–5022

```text
4530:   /* If we are processing a type and there is either no DECL for it or
4531:      we just made one, do some common processing for the type, such as
4532:      handling alignment and possible padding.  */
4533:   if (is_type && (!gnu_decl || this_made_decl))
4534:     {
4535:       const bool is_by_ref = Is_By_Reference_Type (gnat_entity);
4536:
4537:       gcc_assert (!TYPE_IS_DUMMY_P (gnu_type));
4538:
4539:       /* Process the attributes, if not already done.  Note that the type is
4540:          already defined so we cannot pass true for IN_PLACE here.  */
4541:       process_attributes (&gnu_type, &attr_list, false, gnat_entity);
4542:
4543:       /* See if a size was specified, by means of either an Object_Size or
4544:          a regular Size clause, and validate it if so.  */
4545:       if (!gnu_size)
4546:         {
4547:           const char *size_s = "size for %s too small{, minimum allowed is ^}";
4548:           const char *type_s = is_by_ref ? "by-reference type &" : "&";
4549:
4550:           if (Known_Esize (gnat_entity))
4551:             gnu_size
4552:               = validate_size (Esize (gnat_entity), gnu_type, gnat_entity,
4553:                                VAR_DECL, false, false, NULL, NULL);
4554:
4555:           /* ??? The test on Has_Size_Clause must be removed when "unknown" is
4556:              no longer represented as Uint_0 (i.e. Use_New_Unknown_Rep).  */
4557:           else if (Known_RM_Size (gnat_entity)
4558:                    || Has_Size_Clause (gnat_entity))
4559:             gnu_size
4560:               = validate_size (RM_Size (gnat_entity), gnu_type, gnat_entity,
4561:                                TYPE_DECL, false, Has_Size_Clause (gnat_entity),
4562:                                size_s, type_s);
4563:         }
4564:
4565:       /* If a size was specified, see if we can make a new type of that size
4566:          by rearranging the type, for example from a fat to a thin pointer.  */
4567:       if (gnu_size)
4568:         {
4569:           gnu_type
4570:             = make_type_from_size (gnu_type, gnu_size,
4571:                                    Has_Biased_Representation (gnat_entity));
4572:
4573:           if (operand_equal_p (TYPE_SIZE (gnu_type), gnu_size, 0)
4574:               && operand_equal_p (rm_size (gnu_type), gnu_size, 0))
4575:             gnu_size = NULL_TREE;
4576:         }
4577:
4578:       /* If the alignment has not already been processed and this is not
4579:          an unconstrained array type, see if an alignment is specified.
4580:          If not, we pick a default alignment for atomic objects.  */
4581:       if (align > 0 || TREE_CODE (gnu_type) == UNCONSTRAINED_ARRAY_TYPE)
4582:         ;
4583:       else if (Known_Alignment (gnat_entity))
4584:         {
4585:           align = validate_alignment (Alignment (gnat_entity), gnat_entity,
4586:                                       TYPE_ALIGN (gnu_type));
4587:
4588:           /* Warn on suspiciously large alignments.  This should catch
4589:              errors about the (alignment,byte)/(size,bit) discrepancy.  */
4590:           if (align > BIGGEST_ALIGNMENT && Has_Alignment_Clause (gnat_entity))
4591:             {
4592:               tree size;
4593:
4594:               /* If a size was specified, take it into account.  Otherwise
4595:                  use the RM size for records or unions as the type size has
4596:                  already been adjusted to the alignment.  */
4597:               if (gnu_size)
4598:                 size = gnu_size;
4599:               else if (RECORD_OR_UNION_TYPE_P (gnu_type)
4600:                        && !TYPE_FAT_POINTER_P (gnu_type)
4601:                        && !TYPE_EXTENDED_POINTER_P (gnu_type))
4602:                 size = rm_size (gnu_type);
4603:               else
4604:                 size = TYPE_SIZE (gnu_type);
4605:
4606:               /* Consider an alignment as suspicious if the alignment/size
4607:                  ratio is greater or equal to the byte/bit ratio.  */
4608:               if (tree_fits_uhwi_p (size)
4609:                   && align >= tree_to_uhwi (size) * BITS_PER_UNIT)
4610:                 post_error_ne ("??suspiciously large alignment specified for&",
4611:                                Expression (Alignment_Clause (gnat_entity)),
4612:                                gnat_entity);
4613:             }
4614:         }
4615:       else if (Is_Full_Access (gnat_entity) && !gnu_size
4616:                && tree_fits_uhwi_p (TYPE_SIZE (gnu_type))
4617:                && integer_pow2p (TYPE_SIZE (gnu_type)))
4618:         align = MIN (BIGGEST_ALIGNMENT,
4619:                      tree_to_uhwi (TYPE_SIZE (gnu_type)));
4620:       else if (Is_Full_Access (gnat_entity) && gnu_size
4621:                && tree_fits_uhwi_p (gnu_size)
4622:                && integer_pow2p (gnu_size))
4623:         align = MIN (BIGGEST_ALIGNMENT, tree_to_uhwi (gnu_size));
4624:
4625:       /* See if we need to pad the type.  If we did and built a new type,
4626:          then create a stripped-down declaration for the original type,
4627:          mainly for debugging, unless there was already one.  */
4628:       if (gnu_size || align > 0)
4629:         {
4630:           tree orig_type = gnu_type;
4631:
4632:           gnu_type = maybe_pad_type (gnu_type, gnu_size, align, gnat_entity,
4633:                                      false, definition, false);
4634:
4635:           if (gnu_type != orig_type && !gnu_decl)
4636:             create_type_decl (gnu_entity_name, orig_type, artificial_p,
4637:                               debug_info_p, gnat_entity);
4638:         }
4639:
4640:       /* Now set the RM size of the type.  We cannot do it before padding
4641:          because we need to accept arbitrary RM sizes on integral types.  */
4642:       if (Known_RM_Size (gnat_entity))
4643:         set_rm_size (RM_Size (gnat_entity), gnu_type, gnat_entity);
4644:
4645:       /* Back-annotate the alignment of the type if not already set.  */
4646:       if (!Known_Alignment (gnat_entity))
4647:         {
4648:           unsigned int double_align, align;
4649:           bool is_capped_double, align_clause;
4650:
4651:           /* If the default alignment of "double" or larger scalar types is
4652:              specifically capped and this is not an array with an alignment
4653:              clause on the component type, return the cap.  */
4654:           if ((double_align = double_float_alignment) > 0)
4655:             is_capped_double
4656:               = is_double_float_or_array (gnat_entity, &align_clause);
4657:           else if ((double_align = double_scalar_alignment) > 0)
4658:             is_capped_double
4659:               = is_double_scalar_or_array (gnat_entity, &align_clause);
4660:           else
4661:             is_capped_double = align_clause = false;
4662:
4663:           if (is_capped_double && !align_clause)
4664:             align = double_align;
4665:           else
4666:             align = TYPE_ALIGN (gnu_type) / BITS_PER_UNIT;
4667:
4668:           Set_Alignment (gnat_entity, UI_From_Int (align));
4669:         }
4670:
4671:       /* Likewise for the size, if any.  */
4672:       if (!Known_Esize (gnat_entity) && TYPE_SIZE (gnu_type))
4673:         {
4674:           tree size = TYPE_SIZE (gnu_type);
4675:
4676:           /* If the size is self-referential, annotate the maximum value
4677:              after saturating it, if need be, to avoid a No_Uint value.
4678:              But do not do it for cases where Analyze_Object_Declaration
4679:              in Sem_Ch3 would build a default subtype for objects.  */
4680:           if (CONTAINS_PLACEHOLDER_P (size)
4681:               && !Is_Limited_Record (gnat_entity)
4682:               && !Is_Concurrent_Type (gnat_entity))
4683:             {
4684:               const unsigned int align
4685:                 = UI_To_Int (Alignment (gnat_entity)) * BITS_PER_UNIT;
4686:               size = maybe_saturate_size (max_size (size, true), align);
4687:             }
4688:
4689:           /* If we are just annotating types and the type is tagged, the tag
4690:              and the parent components are not generated by the front-end so
4691:              alignment and sizes must be adjusted.  */
4692:           if (type_annotate_only && Is_Tagged_Type (gnat_entity))
4693:             {
4694:               const bool derived_p = Is_Derived_Type (gnat_entity);
4695:               const Entity_Id gnat_parent
4696:                 = derived_p ? Etype (Base_Type (gnat_entity)) : Empty;
4697:               /* The following test for Known_Alignment preserves the old behavior,
4698:                  but is probably wrong. */
4699:               const unsigned int inherited_align
4700:                 = derived_p
4701:                   ? (Known_Alignment (gnat_parent)
4702:                      ? UI_To_Int (Alignment (gnat_parent)) * BITS_PER_UNIT
4703:                      : 0)
4704:                   : POINTER_SIZE;
4705:               const unsigned int align
4706:                 = MAX (TYPE_ALIGN (gnu_type), inherited_align);
4707:
4708:               Set_Alignment (gnat_entity, UI_From_Int (align / BITS_PER_UNIT));
4709:
4710:               /* If there is neither size clause nor representation clause, the
4711:                  sizes need to be adjusted.  */
4712:               if (!Known_RM_Size (gnat_entity)
4713:                   && !VOID_TYPE_P (gnu_type)
4714:                   && (!TYPE_FIELDS (gnu_type)
4715:                       || integer_zerop (bit_position (TYPE_FIELDS (gnu_type)))))
4716:                 {
4717:                   tree offset
4718:                     = derived_p
4719:                       ? UI_To_gnu (Esize (gnat_parent), bitsizetype)
4720:                       : bitsize_int (POINTER_SIZE);
4721:                   if (TYPE_FIELDS (gnu_type))
4722:                     offset
4723:                       = round_up (offset, DECL_ALIGN (TYPE_FIELDS (gnu_type)));
4724:                   size = size_binop (PLUS_EXPR, size, offset);
4725:                 }
4726:
4727:               size = maybe_saturate_size (round_up (size, align), align);
4728:               Set_Esize (gnat_entity, annotate_value (size));
4729:
4730:               /* Tagged types are Strict_Alignment so RM_Size = Esize.  */
4731:               if (!Known_RM_Size (gnat_entity))
4732:                 Set_RM_Size (gnat_entity, Esize (gnat_entity));
4733:             }
4734:
4735:           /* Otherwise no adjustment is needed.  */
4736:           else
4737:             Set_Esize (gnat_entity, No_Uint_To_0 (annotate_value (size)));
4738:         }
4739:
4740:       /* Likewise for the RM size, if any.  */
4741:       if (!Known_RM_Size (gnat_entity) && TYPE_SIZE (gnu_type))
4742:         Set_RM_Size (gnat_entity,
4743:                      annotate_value (rm_size (gnu_type)));
4744:
4745:       /* If we are at global level, GCC applied variable_size to the size but
4746:          this has done nothing.  So, if it's not constant or self-referential,
4747:          call elaborate_expression_1 to make a variable for it rather than
4748:          calculating it each time.  */
4749:       if (TYPE_SIZE (gnu_type)
4750:           && !TREE_CONSTANT (TYPE_SIZE (gnu_type))
4751:           && !CONTAINS_PLACEHOLDER_P (TYPE_SIZE (gnu_type))
4752:           && global_bindings_p ())
4753:         {
4754:           tree orig_size = TYPE_SIZE (gnu_type);
4755:
4756:           TYPE_SIZE (gnu_type)
4757:             = elaborate_expression_1 (TYPE_SIZE (gnu_type), gnat_entity,
4758:                                       "SIZE", definition, false);
4759:
4760:           /* ??? For now, store the size as a multiple of the alignment in
4761:              bytes so that we can see the alignment from the tree.  */
4762:           TYPE_SIZE_UNIT (gnu_type)
4763:             = elaborate_expression_2 (TYPE_SIZE_UNIT (gnu_type), gnat_entity,
4764:                                       "SIZE_A_UNIT", definition, false,
4765:                                       TYPE_ALIGN (gnu_type));
4766:
4767:           /* ??? gnu_type may come from an existing type so the MULT_EXPR node
4768:              may not be marked by the call to create_type_decl below.  */
4769:           MARK_VISITED (TYPE_SIZE_UNIT (gnu_type));
4770:
4771:           /* For a record type, deal with the variant part, if any, and handle
4772:              the Ada size as well.  */
4773:           if (RECORD_OR_UNION_TYPE_P (gnu_type))
4774:             {
4775:               tree variant_part = get_variant_part (gnu_type);
4776:               tree ada_size = TYPE_ADA_SIZE (gnu_type);
4777:
4778:               if (variant_part)
4779:                 {
4780:                   tree union_type = TREE_TYPE (variant_part);
4781:                   tree offset = DECL_FIELD_OFFSET (variant_part);
4782:
4783:                   /* If the position of the variant part is constant, subtract
4784:                      it from the size of the type of the parent to get the new
4785:                      size.  This manual CSE reduces the data size.  */
4786:                   if (TREE_CODE (offset) == INTEGER_CST)
4787:                     {
4788:                       tree bitpos = DECL_FIELD_BIT_OFFSET (variant_part);
4789:                       TYPE_SIZE (union_type)
4790:                         = size_binop (MINUS_EXPR, TYPE_SIZE (gnu_type),
4791:                                       bit_from_pos (offset, bitpos));
4792:                       TYPE_SIZE_UNIT (union_type)
4793:                         = size_binop (MINUS_EXPR, TYPE_SIZE_UNIT (gnu_type),
4794:                                       byte_from_pos (offset, bitpos));
4795:                     }
4796:                   else
4797:                     {
4798:                       TYPE_SIZE (union_type)
4799:                         = elaborate_expression_1 (TYPE_SIZE (union_type),
4800:                                                   gnat_entity, "VSIZE",
4801:                                                   definition, false);
4802:
4803:                       /* ??? For now, store the size as a multiple of the
4804:                          alignment in bytes so that we can see the alignment
4805:                          from the tree.  */
4806:                       TYPE_SIZE_UNIT (union_type)
4807:                         = elaborate_expression_2 (TYPE_SIZE_UNIT (union_type),
4808:                                                   gnat_entity, "VSIZE_A_UNIT",
4809:                                                   definition, false,
4810:                                                   TYPE_ALIGN (union_type));
4811:
4812:                       /* ??? For now, store the offset as a multiple of the
4813:                          alignment in bytes so that we can see the alignment
4814:                          from the tree.  */
4815:                       DECL_FIELD_OFFSET (variant_part)
4816:                         = elaborate_expression_2 (offset, gnat_entity,
4817:                                                   "VOFFSET", definition, false,
4818:                                                   DECL_OFFSET_ALIGN
4819:                                                   (variant_part));
4820:                     }
4821:
4822:                   DECL_SIZE (variant_part) = TYPE_SIZE (union_type);
4823:                   DECL_SIZE_UNIT (variant_part) = TYPE_SIZE_UNIT (union_type);
4824:                 }
4825:
4826:               if (operand_equal_p (ada_size, orig_size, 0))
4827:                 ada_size = TYPE_SIZE (gnu_type);
4828:               else
4829:                 ada_size
4830:                   = elaborate_expression_1 (ada_size, gnat_entity, "RM_SIZE",
4831:                                             definition, false);
4832:               SET_TYPE_ADA_SIZE (gnu_type, ada_size);
4833:             }
4834:         }
4835:
4836:       /* Similarly, if this is a record type or subtype at global level, call
4837:          elaborate_expression_2 on any field position.  Skip any fields that
4838:          we haven't made trees for to avoid problems with class-wide types.  */
4839:       if (Is_In_Record_Kind (kind) && global_bindings_p ())
4840:         for (gnat_temp = First_Entity (gnat_entity); Present (gnat_temp);
4841:              gnat_temp = Next_Entity (gnat_temp))
4842:           if (Ekind (gnat_temp) == E_Component && present_gnu_tree (gnat_temp))
4843:             {
4844:               tree gnu_field = get_gnu_tree (gnat_temp);
4845:
4846:               /* ??? For now, store the offset as a multiple of the alignment
4847:                  in bytes so that we can see the alignment from the tree.  */
4848:               if (!TREE_CONSTANT (DECL_FIELD_OFFSET (gnu_field))
4849:                   && !CONTAINS_PLACEHOLDER_P (DECL_FIELD_OFFSET (gnu_field)))
4850:                 {
4851:                   DECL_FIELD_OFFSET (gnu_field)
4852:                     = elaborate_expression_2 (DECL_FIELD_OFFSET (gnu_field),
4853:                                               gnat_temp, "OFFSET", definition,
4854:                                               false,
4855:                                               DECL_OFFSET_ALIGN (gnu_field));
4856:
4857:                   /* ??? The context of gnu_field is not necessarily gnu_type
4858:                      so the MULT_EXPR node built above may not be marked by
4859:                      the call to create_type_decl below.  */
4860:                   MARK_VISITED (DECL_FIELD_OFFSET (gnu_field));
4861:                 }
4862:             }
4863:
4864:       /* Now check if the type allows atomic access.  */
4865:       if (Is_Full_Access (gnat_entity))
4866:         check_ok_for_atomic_type (gnu_type, gnat_entity, false);
4867:
4868:       /* If this is not an unconstrained array type, set some flags.  */
4869:       if (TREE_CODE (gnu_type) != UNCONSTRAINED_ARRAY_TYPE)
4870:         {
4871:           bool align_clause;
4872:
4873:           /* Record whether the type is passed by reference.  */
4874:           if (is_by_ref && !VOID_TYPE_P (gnu_type))
4875:             TYPE_BY_REFERENCE_P (gnu_type) = 1;
4876:
4877:           /* Record whether an alignment clause was specified.  At this point
4878:              scalar types with a non-confirming clause have been wrapped into
4879:              a record type, so only scalar types with a confirming clause are
4880:              left untouched; we do not set the flag on them except if they are
4881:              types whose default alignment is specifically capped in order not
4882:              to lose the specified alignment.  */
4883:           if ((AGGREGATE_TYPE_P (gnu_type)
4884:                && Present (Alignment_Clause (gnat_entity)))
4885:               || (double_float_alignment > 0
4886:                   && is_double_float_or_array (gnat_entity, &align_clause)
4887:                   && align_clause)
4888:               || (double_scalar_alignment > 0
4889:                   && is_double_scalar_or_array (gnat_entity, &align_clause)
4890:                   && align_clause))
4891:             TYPE_USER_ALIGN (gnu_type) = 1;
4892:
4893:           /* Record whether a pragma Universal_Aliasing was specified.  Also
4894:              consider that it is always present on interface types because,
4895:              while they are abstract tagged types and thus no object of these
4896:              types exists anywhere, they are used to access objects of types
4897:              that implement them.  */
4898:           if ((Universal_Aliasing (gnat_entity) || Is_Interface (gnat_entity))
4899:               && !TYPE_IS_DUMMY_P (gnu_type))
4900:             {
4901:               /* Set TYPE_TYPELESS_STORAGE if this is an aggregate type and
4902:                  TYPE_UNIVERSAL_ALIASING_P otherwise, since the former is not
4903:                  available in the latter case  Both will effectively put alias
4904:                  set 0 on the type, but the former is more robust because it
4905:                  will be streamed in LTO mode.  */
4906:               if (AGGREGATE_TYPE_P (gnu_type))
4907:                 set_typeless_storage_on_aggregate_type (gnu_type);
4908:               else
4909:                 set_universal_aliasing_on_type (gnu_type);
4910:             }
4911:
4912:           /* If it is passed by reference, force BLKmode to ensure that
4913:              objects of this type will always be put in memory.  */
4914:           if (AGGREGATE_TYPE_P (gnu_type) && TYPE_BY_REFERENCE_P (gnu_type))
4915:             SET_TYPE_MODE (gnu_type, BLKmode);
4916:         }
4917:
4918:       /* If this is a derived type, relate its alias set to that of its parent
4919:          to avoid troubles when a call to an inherited primitive is inlined in
4920:          a context where a derived object is accessed.  The inlined code works
4921:          on the parent view so the resulting code may access the same object
4922:          using both the parent and the derived alias sets, which thus have to
4923:          conflict.  As the same issue arises with component references, the
4924:          parent alias set also has to conflict with composite types enclosing
4925:          derived components.  For instance, if we have:
4926:
4927:             type D is new T;
4928:             type R is record
4929:                Component : D;
4930:             end record;
4931:
4932:          we want T to conflict with both D and R, in addition to R being a
4933:          superset of D by record/component construction.
4934:
4935:          One way to achieve this is to perform an alias set copy from the
4936:          parent to the derived type.  This is not quite appropriate, though,
4937:          as we don't want separate derived types to conflict with each other:
4938:
4939:             type I1 is new Integer;
4940:             type I2 is new Integer;
4941:
4942:          We want I1 and I2 to both conflict with Integer but we do not want
4943:          I1 to conflict with I2, and an alias set copy on derivation would
4944:          have that effect.
4945:
4946:          The option chosen is to make the alias set of the derived type a
4947:          superset of that of its parent type.  It trivially fulfills the
4948:          simple requirement for the Integer derivation example above, and
4949:          the component case as well by superset transitivity:
4950:
4951:                    superset      superset
4952:                 R ----------> D ----------> T
4953:
4954:          However, for composite types, conversions between derived types are
4955:          translated into VIEW_CONVERT_EXPRs so a sequence like:
4956:
4957:             type Comp1 is new Comp;
4958:             type Comp2 is new Comp;
4959:             procedure Proc (C : Comp1);
4960:
4961:             C : Comp2;
4962:             Proc (Comp1 (C));
4963:
4964:          is translated into:
4965:
4966:             C : Comp2;
4967:             Proc ((Comp1 &) &VIEW_CONVERT_EXPR <Comp1> (C));
4968:
4969:          and gimplified into:
4970:
4971:             C : Comp2;
4972:             Comp1 *C.0;
4973:             C.0 = (Comp1 *) &C;
4974:             Proc (C.0);
4975:
4976:          i.e. generates code involving type punning.  Therefore, Comp1 needs
4977:          to conflict with Comp2 and an alias set copy is required.
4978:
4979:          The language rules ensure the parent type is already frozen here.  */
4980:       if (kind != E_Subprogram_Type
4981:           && Is_Derived_Type (gnat_entity)
4982:           && !type_annotate_only)
4983:         {
4984:           Entity_Id gnat_parent_type = Underlying_Type (Etype (gnat_entity));
4985:           /* For constrained packed array subtypes, the implementation type is
4986:              used instead of the nominal type.  */
4987:           if (kind == E_Array_Subtype
4988:               && Is_Constrained (gnat_entity)
4989:               && Present (Packed_Array_Impl_Type (gnat_parent_type)))
4990:             gnat_parent_type = Packed_Array_Impl_Type (gnat_parent_type);
4991:           relate_alias_sets (gnu_type, gnat_to_gnu_type (gnat_parent_type),
4992:                              Is_Composite_Type (gnat_entity)
4993:                              ? ALIAS_SET_COPY : ALIAS_SET_SUPERSET);
4994:         }
4995:
4996:       /* Finally get to the appropriate variant, except for the implementation
4997:          type of a packed array because the GNU type might be further adjusted
4998:          when the original array type is itself processed.  */
4999:       if (Treat_As_Volatile (gnat_entity)
5000:           && !Is_Packed_Array_Impl_Type (gnat_entity))
5001:         {
5002:           const int quals
5003:             = TYPE_QUAL_VOLATILE
5004:               | (Is_Full_Access (gnat_entity) ? TYPE_QUAL_ATOMIC : 0);
5005:           /* This is required by free_lang_data_in_type to disable the ODR.  */
5006:           if (TREE_CODE (gnu_type) == ENUMERAL_TYPE)
5007:             TYPE_STUB_DECL (gnu_type)
5008:               = create_type_stub_decl (TYPE_NAME (gnu_type), gnu_type);
5009:           gnu_type = change_qualified_type (gnu_type, quals);
5010:         }
5011:
5012:       /* If we already made a decl, just set the type, otherwise create it.  */
5013:       if (gnu_decl)
5014:         {
5015:           TREE_TYPE (gnu_decl) = gnu_type;
5016:           TYPE_STUB_DECL (gnu_type) = gnu_decl;
5017:         }
5018:       else
5019:         gnu_decl = create_type_decl (gnu_entity_name, gnu_type, artificial_p,
5020:                                      debug_info_p, gnat_entity);
5021:     }
5022:
```

## gcc/ada/gcc-interface/decl.cc:5538–5691

```text
5538: gnat_to_gnu_component_type (Entity_Id gnat_array, bool definition,
5539:                             bool debug_info_p)
5540: {
5541:   const Entity_Id gnat_type = Component_Type (gnat_array);
5542:   const bool is_bit_packed = Is_Bit_Packed_Array (gnat_array);
5543:   tree gnu_type = gnat_to_gnu_type (gnat_type);
5544:   tree gnu_comp_size;
5545:   bool has_packed_component;
5546:   unsigned int max_align;
5547:
5548:   /* If an alignment is specified, use it as a cap on the component type
5549:      so that it can be honored for the whole type, but ignore it for the
5550:      original type of packed array types.  */
5551:   if (No (Packed_Array_Impl_Type (gnat_array))
5552:       && Known_Alignment (gnat_array))
5553:     max_align = validate_alignment (Alignment (gnat_array), gnat_array, 0);
5554:   else
5555:     max_align = 0;
5556:
5557:   /* Try to get a packable form of the component if needed.  */
5558:   if ((Is_Packed (gnat_array) || Has_Component_Size_Clause (gnat_array))
5559:       && !is_bit_packed
5560:       && !Has_Aliased_Components (gnat_array)
5561:       && !Strict_Alignment (gnat_type)
5562:       && RECORD_OR_UNION_TYPE_P (gnu_type)
5563:       && !TYPE_FAT_POINTER_P (gnu_type)
5564:       && !TYPE_EXTENDED_POINTER_P (gnu_type)
5565:       && tree_fits_uhwi_p (TYPE_SIZE (gnu_type)))
5566:     {
5567:       tree gnu_packable_type = make_packable_type (gnu_type, false, max_align);
5568:       if (gnu_packable_type != gnu_type)
5569:         {
5570:           gnu_type = gnu_packable_type;
5571:           has_packed_component = true;
5572:         }
5573:       else
5574:         has_packed_component = false;
5575:     }
5576:   else
5577:     has_packed_component = is_bit_packed;
5578:
5579:   /* Get and validate any specified Component_Size.  */
5580:   gnu_comp_size
5581:     = validate_size (Component_Size (gnat_array), gnu_type, gnat_array,
5582:                      has_packed_component ? TYPE_DECL : VAR_DECL, true,
5583:                      Has_Component_Size_Clause (gnat_array), NULL, NULL);
5584:
5585:   /* If the component type is a RECORD_TYPE that has a self-referential size,
5586:      then use the maximum size for the component size.  */
5587:   if (!gnu_comp_size
5588:       && TREE_CODE (gnu_type) == RECORD_TYPE
5589:       && CONTAINS_PLACEHOLDER_P (TYPE_SIZE (gnu_type)))
5590:     gnu_comp_size = max_size (TYPE_SIZE (gnu_type), true);
5591:
5592:   /* If the array has aliased components and the component size is zero, force
5593:      the unit size to ensure that the components have distinct addresses.  */
5594:   if (!gnu_comp_size
5595:       && Has_Aliased_Components (gnat_array)
5596:       && integer_zerop (TYPE_SIZE (gnu_type)))
5597:     gnu_comp_size = bitsize_unit_node;
5598:
5599:   /* Honor the component size.  This is not needed for bit-packed arrays.  */
5600:   if (gnu_comp_size && !is_bit_packed)
5601:     {
5602:       tree orig_type = gnu_type;
5603:       unsigned int gnu_comp_align;
5604:
5605:       gnu_type = make_type_from_size (gnu_type, gnu_comp_size, false);
5606:       if (max_align > 0 && TYPE_ALIGN (gnu_type) > max_align)
5607:         gnu_type = orig_type;
5608:       else
5609:         orig_type = gnu_type;
5610:
5611:       /* We need to make sure that the size is a multiple of the alignment.
5612:          But we do not misalign the component type because of the alignment
5613:          of the array type here; this either must have been done earlier in
5614:          the packed case or should be rejected in the non-packed case.  */
5615:       if (TREE_CODE (gnu_comp_size) == INTEGER_CST)
5616:         {
5617:           const unsigned HOST_WIDE_INT int_size = tree_to_uhwi (gnu_comp_size);
5618:           gnu_comp_align = int_size & -int_size;
5619:           if (gnu_comp_align > TYPE_ALIGN (gnu_type))
5620:             gnu_comp_align = 0;
5621:         }
5622:       else
5623:         gnu_comp_align = 0;
5624:
5625:       gnu_type = maybe_pad_type (gnu_type, gnu_comp_size, gnu_comp_align,
5626:                                  gnat_array, true, definition, true);
5627:
5628:       /* If a padding record was made, declare it now since it will never be
5629:          declared otherwise.  This is necessary to ensure that its subtrees
5630:          are properly marked.  */
5631:       if (gnu_type != orig_type && !DECL_P (TYPE_NAME (gnu_type)))
5632:         create_type_decl (TYPE_NAME (gnu_type), gnu_type, true, debug_info_p,
5633:                           gnat_array);
5634:     }
5635:
5636:   /* This is a very special case where the array has aliased components and the
5637:      component size might be zero at run time.  As explained above, we force at
5638:      least the unit size but we don't want to build a distinct padding type for
5639:      each invocation (they are not canonicalized if they have variable size) so
5640:      we cache this special padding type as TYPE_PADDING_FOR_COMPONENT.  */
5641:   else if (Has_Aliased_Components (gnat_array)
5642:            && TREE_CODE (gnu_type) == ARRAY_TYPE
5643:            && !TREE_CONSTANT (TYPE_SIZE (gnu_type)))
5644:     {
5645:       if (TYPE_PADDING_FOR_COMPONENT (gnu_type))
5646:         gnu_type = TYPE_PADDING_FOR_COMPONENT (gnu_type);
5647:       else
5648:         {
5649:           gnu_comp_size
5650:             = size_binop (MAX_EXPR, TYPE_SIZE (gnu_type), bitsize_unit_node);
5651:           TYPE_PADDING_FOR_COMPONENT (gnu_type)
5652:             = maybe_pad_type (gnu_type, gnu_comp_size, 0, gnat_array,
5653:                               true, definition, true);
5654:           gnu_type = TYPE_PADDING_FOR_COMPONENT (gnu_type);
5655:           create_type_decl (TYPE_NAME (gnu_type), gnu_type, true, debug_info_p,
5656:                             gnat_array);
5657:         }
5658:     }
5659:
5660:   /* Now check if the type of the component allows atomic access.  */
5661:   if (Has_Atomic_Components (gnat_array) || Is_Full_Access (gnat_type))
5662:     check_ok_for_atomic_type (gnu_type, gnat_array, true);
5663:
5664:   /* If the component type is a padded type made for a non-bit-packed array
5665:      of scalars with reverse storage order, we need to propagate the reverse
5666:      storage order to the padding type since it is the innermost enclosing
5667:      aggregate type around the scalar.  */
5668:   if (TYPE_IS_PADDING_P (gnu_type)
5669:       && !is_bit_packed
5670:       && Reverse_Storage_Order (gnat_array)
5671:       && Is_Scalar_Type (gnat_type))
5672:     gnu_type = set_reverse_storage_order_on_pad_type (gnu_type);
5673:
5674:   if (Has_Volatile_Components (gnat_array))
5675:     {
5676:       const int quals
5677:         = TYPE_QUAL_VOLATILE
5678:           | (Has_Atomic_Components (gnat_array) ? TYPE_QUAL_ATOMIC : 0);
5679:       gnu_type = change_qualified_type (gnu_type, quals);
5680:     }
5681:
5682:   return gnu_type;
5683: }
5684:
5685: /* Return whether TYPE requires that formal parameters of TYPE be initialized
5686:    when they are Out parameters passed by copy.
5687:
5688:    This just implements the set of conditions listed in RM 6.4.1(12).  */
5689:
5690: static bool
5691: type_requires_init_of_formal (Entity_Id type)
```

## gcc/ada/gcc-interface/decl.cc:7116–7128

```text
7116: allocatable_size_p (tree gnu_size, bool static_p)
7117: {
7118:   /* We can allocate a fixed size if it is a valid for the middle-end but, for
7119:      a static allocation, we do not allocate more than 2 GB because this would
7120:      very likely be unintended and problematic for usual code models.  */
7121:   if (TREE_CODE (gnu_size) == INTEGER_CST)
7122:     return valid_constant_size_p (gnu_size)
7123:            && (!static_p || tree_to_uhwi (gnu_size) <= INT_MAX);
7124:
7125:   /* We can allocate a variable size if this isn't a static allocation.  */
7126:   else
7127:     return !static_p;
7128: }
```

## gcc/ada/gcc-interface/decl.cc:7169–7228

```text
7169: update_n_elem (tree n_elem, tree min, tree max)
7170: {
7171:   /* First deal with the empty case.  */
7172:   if (TREE_CODE (min) == INTEGER_CST
7173:       && TREE_CODE (max) == INTEGER_CST
7174:       && tree_int_cst_lt (max, min))
7175:     return size_zero_node;
7176:
7177:   min = convert (sizetype, min);
7178:   max = convert (sizetype, max);
7179:
7180:   /* Compute the number of elements in this dimension.  */
7181:   tree this_n_elem
7182:     = size_binop (PLUS_EXPR, size_one_node, size_binop (MINUS_EXPR, max, min));
7183:
7184:   if (TREE_CODE (this_n_elem) == INTEGER_CST && TREE_OVERFLOW (this_n_elem))
7185:     return NULL_TREE;
7186:
7187:   /* Multiply the current number of elements by the result.  */
7188:   n_elem = size_binop (MULT_EXPR, n_elem, this_n_elem);
7189:
7190:   if (TREE_CODE (n_elem) == INTEGER_CST && TREE_OVERFLOW (n_elem))
7191:     return NULL_TREE;
7192:
7193:   return n_elem;
7194: }
7195:
7196: /* Given GNAT_ENTITY, elaborate all expressions that are required to
7197:    be elaborated at the point of its definition, but do nothing else.  */
7198:
7199: void
7200: elaborate_entity (Entity_Id gnat_entity)
7201: {
7202:   switch (Ekind (gnat_entity))
7203:     {
7204:     case E_Signed_Integer_Subtype:
7205:     case E_Modular_Integer_Subtype:
7206:     case E_Enumeration_Subtype:
7207:     case E_Ordinary_Fixed_Point_Subtype:
7208:     case E_Decimal_Fixed_Point_Subtype:
7209:     case E_Floating_Point_Subtype:
7210:       {
7211:         Node_Id gnat_lb = Type_Low_Bound (gnat_entity);
7212:         Node_Id gnat_hb = Type_High_Bound (gnat_entity);
7213:
7214:         /* ??? Tests to avoid Constraint_Error in static expressions
7215:            are needed until after the front stops generating bogus
7216:            conversions on bounds of real types.  */
7217:         if (!Raises_Constraint_Error (gnat_lb))
7218:           elaborate_expression (gnat_lb, gnat_entity, "L", true, false,
7219:                                 Needs_Debug_Info (gnat_entity));
7220:         if (!Raises_Constraint_Error (gnat_hb))
7221:           elaborate_expression (gnat_hb, gnat_entity, "U", true, false,
7222:                                 Needs_Debug_Info (gnat_entity));
7223:       break;
7224:       }
7225:
7226:     case E_Record_Subtype:
7227:     case E_Private_Subtype:
7228:     case E_Limited_Private_Subtype:
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

## gcc/ada/gcc-interface/utils2.cc:216–456

```text
216: find_common_type (tree t1, tree t2)
217: {
218:   /* ??? As of today, various constructs lead to here with types of different
219:      sizes even when both constants (e.g. tagged types, packable vs regular
220:      component types, padded vs unpadded types, ...).  While some of these
221:      would better be handled upstream (types should be made consistent before
222:      calling into build_binary_op), some others are really expected and we
223:      have to be careful.  */
224:
225:   const bool variable_record_on_lhs
226:     = (TREE_CODE (t1) == RECORD_TYPE
227:        && TREE_CODE (t2) == RECORD_TYPE
228:        && get_variant_part (t1)
229:        && !get_variant_part (t2));
230:
231:   const bool variable_array_on_lhs
232:     = (TREE_CODE (t1) == ARRAY_TYPE
233:        && TREE_CODE (t2) == ARRAY_TYPE
234:        && !TREE_CONSTANT (TYPE_MIN_VALUE (TYPE_DOMAIN (t1)))
235:        && TREE_CONSTANT (TYPE_MIN_VALUE (TYPE_DOMAIN (t2))));
236:
237:   /* We must avoid writing more than what the target can hold if this is for
238:      an assignment and the case of tagged types is handled in build_binary_op
239:      so we use the lhs type if it is known to be smaller or of constant size
240:      and the rhs type is not, whatever the modes.  We also force t1 in case of
241:      constant size equality to minimize occurrences of view conversions on the
242:      lhs of an assignment, except for the case of types with a variable part
243:      on the lhs but not on the rhs to make the conversion simpler.  */
244:   if (TREE_CONSTANT (TYPE_SIZE (t1))
245:       && (!TREE_CONSTANT (TYPE_SIZE (t2))
246:           || tree_int_cst_lt (TYPE_SIZE (t1), TYPE_SIZE (t2))
247:           || (TYPE_SIZE (t1) == TYPE_SIZE (t2)
248:               && !variable_record_on_lhs
249:               && !variable_array_on_lhs)))
250:     return t1;
251:
252:   /* Otherwise, if the lhs type is non-BLKmode, use it, except for the case of
253:      a non-BLKmode rhs and array types with a variable part on the lhs but not
254:      on the rhs to make sure the conversion is preserved during gimplification.
255:      Note that we know that we will not have any alignment problems since, if
256:      we did, the non-BLKmode type could not have been used.  */
257:   if (TYPE_MODE (t1) != BLKmode
258:       && (TYPE_MODE (t2) == BLKmode || !variable_array_on_lhs))
259:     return t1;
260:
261:   /* If the rhs type is of constant size, use it whatever the modes.  At
262:      this point it is known to be smaller, or of constant size and the
263:      lhs type is not.  */
264:   if (TREE_CONSTANT (TYPE_SIZE (t2)))
265:     return t2;
266:
267:   /* Otherwise, if the rhs type is non-BLKmode, use it.  */
268:   if (TYPE_MODE (t2) != BLKmode)
269:     return t2;
270:
271:   /* In this case, both types have variable size and BLKmode.  It's
272:      probably best to leave the "type mismatch" because changing it
273:      could cause a bad self-referential reference.  */
274:   return NULL_TREE;
275: }
276:
277: /* Return an expression tree representing an equality comparison of A1 and A2,
278:    two objects of type ARRAY_TYPE.  The result should be of type RESULT_TYPE.
279:
280:    Two arrays are equal in one of two ways: (1) if both have zero length in
281:    some dimension (not necessarily the same dimension) or (2) if the lengths
282:    in each dimension are equal and the data is equal.  We perform the length
283:    tests in as efficient a manner as possible.  */
284:
285: static tree
286: compare_arrays_for_equality (location_t loc, tree result_type, tree a1, tree a2)
287: {
288:   tree result = convert (result_type, boolean_true_node);
289:   tree a1_is_null = convert (result_type, boolean_false_node);
290:   tree a2_is_null = convert (result_type, boolean_false_node);
291:   tree t1 = TREE_TYPE (a1);
292:   tree t2 = TREE_TYPE (a2);
293:   bool a1_side_effects_p = TREE_SIDE_EFFECTS (a1);
294:   bool a2_side_effects_p = TREE_SIDE_EFFECTS (a2);
295:   bool length_zero_p = false;
296:
297:   /* If the operands have side-effects, they need to be evaluated only once
298:      in spite of the multiple references in the comparison.  */
299:   if (a1_side_effects_p)
300:     a1 = gnat_protect_expr (a1);
301:
302:   if (a2_side_effects_p)
303:     a2 = gnat_protect_expr (a2);
304:
305:   /* Process each dimension separately and compare the lengths.  If any
306:      dimension has a length known to be zero, set LENGTH_ZERO_P to true
307:      in order to suppress the comparison of the data at the end.  */
308:   while (TREE_CODE (t1) == ARRAY_TYPE && TREE_CODE (t2) == ARRAY_TYPE)
309:     {
310:       tree dom1 = TYPE_DOMAIN (t1);
311:       tree dom2 = TYPE_DOMAIN (t2);
312:       tree length1 = size_binop (PLUS_EXPR,
313:                                  size_binop (MINUS_EXPR,
314:                                              TYPE_MAX_VALUE (dom1),
315:                                              TYPE_MIN_VALUE (dom1)),
316:                                  size_one_node);
317:       tree length2 = size_binop (PLUS_EXPR,
318:                                  size_binop (MINUS_EXPR,
319:                                              TYPE_MAX_VALUE (dom2),
320:                                              TYPE_MIN_VALUE (dom2)),
321:                                  size_one_node);
322:       tree ind1 = TYPE_INDEX_TYPE (dom1);
323:       tree ind2 = TYPE_INDEX_TYPE (dom2);
324:       tree base_type = maybe_character_type (get_base_type (ind1));
325:       tree lb1 = convert (base_type, TYPE_MIN_VALUE (ind1));
326:       tree ub1 = convert (base_type, TYPE_MAX_VALUE (ind1));
327:       tree lb2 = convert (base_type, TYPE_MIN_VALUE (ind2));
328:       tree ub2 = convert (base_type, TYPE_MAX_VALUE (ind2));
329:       tree comparison, this_a1_is_null, this_a2_is_null;
330:
331:       /* If the length of the first array is a constant and that of the second
332:          array is not, swap our operands to have the constant second.  */
333:       if (TREE_CODE (length1) == INTEGER_CST
334:           && TREE_CODE (length2) != INTEGER_CST)
335:         {
336:           tree tem;
337:           bool btem;
338:
339:           tem = a1, a1 = a2, a2 = tem;
340:           tem = t1, t1 = t2, t2 = tem;
341:           tem = lb1, lb1 = lb2, lb2 = tem;
342:           tem = ub1, ub1 = ub2, ub2 = tem;
343:           tem = length1, length1 = length2, length2 = tem;
344:           tem = a1_is_null, a1_is_null = a2_is_null, a2_is_null = tem;
345:           btem = a1_side_effects_p, a1_side_effects_p = a2_side_effects_p,
346:           a2_side_effects_p = btem;
347:         }
348:
349:       /* If the length of the second array is the constant zero, we can just
350:          use the original stored bounds for the first array and see whether
351:          last < first holds.  */
352:       if (integer_zerop (length2))
353:         {
354:           length_zero_p = true;
355:
356:           lb1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (lb1, a1);
357:           ub1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (ub1, a1);
358:
359:           comparison = fold_build2_loc (loc, LT_EXPR, result_type, ub1, lb1);
360:
361:           this_a1_is_null = comparison;
362:           this_a2_is_null = convert (result_type, boolean_true_node);
363:         }
364:
365:       /* Otherwise, if the length is some other constant value, we know that
366:          this dimension in the second array cannot be superflat, so we can
367:          just use its length computed from the actual stored bounds.  */
368:       else if (TREE_CODE (length2) == INTEGER_CST)
369:         {
370:           /* Note that we know that LB2 and UB2 are constant and hence
371:              cannot contain a PLACEHOLDER_EXPR.  */
372:           lb1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (lb1, a1);
373:           ub1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (ub1, a1);
374:
375:           comparison
376:             = fold_build2_loc (loc, EQ_EXPR, result_type,
377:                                build_binary_op (MINUS_EXPR, base_type,
378:                                                 ub1, lb1),
379:                                build_binary_op (MINUS_EXPR, base_type,
380:                                                 ub2, lb2));
381:           this_a1_is_null
382:             = fold_build2_loc (loc, LT_EXPR, result_type, ub1, lb1);
383:
384:           this_a2_is_null = convert (result_type, boolean_false_node);
385:         }
386:
387:       /* Otherwise, compare the computed lengths.  */
388:       else
389:         {
390:           length1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (length1, a1);
391:           length2 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (length2, a2);
392:
393:           comparison
394:             = fold_build2_loc (loc, EQ_EXPR, result_type, length1, length2);
395:
396:           lb1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (lb1, a1);
397:           ub1 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (ub1, a1);
398:
399:           this_a1_is_null
400:             = fold_build2_loc (loc, LT_EXPR, result_type, ub1, lb1);
401:
402:           lb2 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (lb2, a2);
403:           ub2 = SUBSTITUTE_PLACEHOLDER_IN_EXPR (ub2, a2);
404:
405:           this_a2_is_null
406:             = fold_build2_loc (loc, LT_EXPR, result_type, ub2, lb2);
407:         }
408:
409:       /* Append expressions for this dimension to the final expressions.  */
410:       result = build_binary_op (TRUTH_ANDIF_EXPR, result_type,
411:                                 result, comparison);
412:
413:       a1_is_null = build_binary_op (TRUTH_ORIF_EXPR, result_type,
414:                                     this_a1_is_null, a1_is_null);
415:
416:       a2_is_null = build_binary_op (TRUTH_ORIF_EXPR, result_type,
417:                                     this_a2_is_null, a2_is_null);
418:
419:       t1 = TREE_TYPE (t1);
420:       t2 = TREE_TYPE (t2);
421:     }
422:
423:   /* Unless the length of some dimension is known to be zero, compare the
424:      data in the array.  */
425:   if (!length_zero_p)
426:     {
427:       tree type = find_common_type (TREE_TYPE (a1), TREE_TYPE (a2));
428:       tree comparison;
429:
430:       if (type)
431:         {
432:           a1 = convert (type, a1),
433:           a2 = convert (type, a2);
434:         }
435:
436:       comparison = fold_build2_loc (loc, EQ_EXPR, result_type, a1, a2);
437:
438:       result
439:         = build_binary_op (TRUTH_ANDIF_EXPR, result_type, result, comparison);
440:     }
441:
442:   /* The result is also true if both sizes are zero.  */
443:   result = build_binary_op (TRUTH_ORIF_EXPR, result_type,
444:                             build_binary_op (TRUTH_ANDIF_EXPR, result_type,
445:                                              a1_is_null, a2_is_null),
446:                             result);
447:
448:   /* If the operands have side-effects, they need to be evaluated before
449:      doing the tests above since the place they otherwise would end up
450:      being evaluated at run time could be wrong.  */
451:   if (a1_side_effects_p)
452:     result = build2 (COMPOUND_EXPR, result_type, a1, result);
453:
454:   if (a2_side_effects_p)
455:     result = build2 (COMPOUND_EXPR, result_type, a2, result);
456:
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

## gcc/ada/gcc-interface/utils2.cc:2166–2435

```text
2166: tree
2167: gnat_build_constructor (tree type, vec<constructor_elt, va_gc> *v)
2168: {
2169:   bool allconstant = (TREE_CODE (TYPE_SIZE (type)) == INTEGER_CST);
2170:   bool read_only = true;
2171:   bool side_effects = false;
2172:   tree result, obj, val;
2173:   unsigned int n_elmts;
2174:
2175:   /* Scan the elements to see if they are all constant or if any has side
2176:      effects, to let us set global flags on the resulting constructor.  Count
2177:      the elements along the way for possible sorting purposes below.  */
2178:   FOR_EACH_CONSTRUCTOR_ELT (v, n_elmts, obj, val)
2179:     {
2180:       /* The predicate must be in keeping with output_constructor and, unlike
2181:          initializer_constant_valid_p, we accept "&{...}" because we'll put
2182:          the CONSTRUCTOR into the constant pool during gimplification.  */
2183:       if ((!TREE_CONSTANT (val) && !TREE_STATIC (val))
2184:           || (TREE_CODE (type) == RECORD_TYPE
2185:               && CONSTRUCTOR_BITFIELD_P (obj)
2186:               && !initializer_constant_valid_for_bitfield_p (val))
2187:           || (!initializer_constant_valid_p (val,
2188:                                              TREE_TYPE (val),
2189:                                              TYPE_REVERSE_STORAGE_ORDER (type))
2190:               && !(TREE_CODE (val) == ADDR_EXPR
2191:                    && TREE_CODE (TREE_OPERAND (val, 0)) == CONSTRUCTOR
2192:                    && TREE_CONSTANT (TREE_OPERAND (val, 0)))))
2193:         allconstant = false;
2194:
2195:       if (!TREE_READONLY (val))
2196:         read_only = false;
2197:
2198:       if (TREE_SIDE_EFFECTS (val))
2199:         side_effects = true;
2200:     }
2201:
2202:   /* For record types with constant components only, sort field list
2203:      by increasing bit position.  This is necessary to ensure the
2204:      constructor can be output as static data.  */
2205:   if (allconstant && TREE_CODE (type) == RECORD_TYPE && n_elmts > 1)
2206:     v->qsort (compare_elmt_bitpos);
2207:
2208:   result = build_constructor (type, v);
2209:   CONSTRUCTOR_NO_CLEARING (result) = 1;
2210:   TREE_CONSTANT (result) = TREE_STATIC (result) = allconstant;
2211:   TREE_SIDE_EFFECTS (result) = side_effects;
2212:   TREE_READONLY (result) = TYPE_READONLY (type) || read_only || allconstant;
2213:   return result;
2214: }
2215:
2216: /* Return a COMPONENT_REF to access FIELD in RECORD, or NULL_TREE if the field
2217:    is not found in the record.  Don't fold the result if NO_FOLD is true.  */
2218:
2219: static tree
2220: build_simple_component_ref (tree record, tree field, bool no_fold)
2221: {
2222:   tree type = TYPE_MAIN_VARIANT (TREE_TYPE (record));
2223:   tree ref;
2224:
2225:   /* The failure of this assertion will very likely come from a missing
2226:      insertion of an explicit dereference.  */
2227:   gcc_assert (RECORD_OR_UNION_TYPE_P (type));
2228:
2229:   /* The type must be frozen at this point.  */
2230:   gcc_assert (COMPLETE_TYPE_P (type));
2231:
2232:   /* Try to fold a conversion from another record or union type unless the type
2233:      contains a placeholder as it might be needed for a later substitution.  */
2234:   if (TREE_CODE (record) == VIEW_CONVERT_EXPR
2235:       && RECORD_OR_UNION_TYPE_P (TREE_TYPE (TREE_OPERAND (record, 0)))
2236:       && !type_contains_placeholder_p (type))
2237:     {
2238:       tree op = TREE_OPERAND (record, 0);
2239:
2240:       /* If this is an unpadding operation, convert the underlying object to
2241:          the unpadded type directly.  */
2242:       if (TYPE_IS_PADDING_P (type) && field == TYPE_FIELDS (type))
2243:         return convert (TREE_TYPE (field), op);
2244:
2245:       /* Otherwise try to access FIELD directly in the underlying type, but
2246:          make sure that the form of the reference doesn't change too much;
2247:          this can happen for an unconstrained bit-packed array type whose
2248:          constrained form can be an integer type.  */
2249:       ref = build_simple_component_ref (op, field, no_fold);
2250:       if (ref && TREE_CODE (TREE_TYPE (ref)) == TREE_CODE (TREE_TYPE (field)))
2251:         return ref;
2252:     }
2253:
2254:   /* If this field is not in the specified record, see if we can find a field
2255:      in the specified record whose original field is the same as this one.  */
2256:   if (DECL_CONTEXT (field) != type)
2257:     {
2258:       tree new_field;
2259:
2260:       /* First loop through normal components.  */
2261:       for (new_field = TYPE_FIELDS (type);
2262:            new_field;
2263:            new_field = DECL_CHAIN (new_field))
2264:         if (SAME_FIELD_P (field, new_field))
2265:           break;
2266:
2267:       /* Next, loop through DECL_INTERNAL_P components if we haven't found the
2268:          component in the first search.  Doing this search in two steps is
2269:          required to avoid hidden homonymous fields in the _Parent field.  */
2270:       if (!new_field)
2271:         for (new_field = TYPE_FIELDS (type);
2272:              new_field;
2273:              new_field = DECL_CHAIN (new_field))
2274:           if (DECL_INTERNAL_P (new_field)
2275:               && RECORD_OR_UNION_TYPE_P (TREE_TYPE (new_field)))
2276:             {
2277:               tree field_ref
2278:                 = build_simple_component_ref (record, new_field, no_fold);
2279:               ref = build_simple_component_ref (field_ref, field, no_fold);
2280:               if (ref)
2281:                 return ref;
2282:             }
2283:
2284:       field = new_field;
2285:     }
2286:
2287:   if (!field)
2288:     return NULL_TREE;
2289:
2290:   /* If the field's offset has overflowed, do not try to access it, as doing
2291:      so may trigger sanity checks deeper in the back-end.  Note that we don't
2292:      need to warn since this will be done on trying to declare the object.  */
2293:   if (TREE_CODE (DECL_FIELD_OFFSET (field)) == INTEGER_CST
2294:       && TREE_OVERFLOW (DECL_FIELD_OFFSET (field)))
2295:     return build1 (NULL_EXPR, TREE_TYPE (field),
2296:                    build_call_raise (SE_Object_Too_Large, Empty,
2297:                                      N_Raise_Storage_Error));
2298:
2299:   ref = build3 (COMPONENT_REF, TREE_TYPE (field), record, field, NULL_TREE);
2300:
2301:   if (TREE_READONLY (record)
2302:       || TREE_READONLY (field)
2303:       || TYPE_READONLY (type))
2304:     TREE_READONLY (ref) = 1;
2305:
2306:   if (TREE_THIS_VOLATILE (record)
2307:       || TREE_THIS_VOLATILE (field)
2308:       || TYPE_VOLATILE (type))
2309:     TREE_THIS_VOLATILE (ref) = 1;
2310:
2311:   if (no_fold)
2312:     return ref;
2313:
2314:   /* The generic folder may punt in this case because the inner array type
2315:      can be self-referential, but folding is in fact not problematic.  */
2316:   if (TREE_CODE (record) == CONSTRUCTOR
2317:       && TYPE_CONTAINS_TEMPLATE_P (TREE_TYPE (record)))
2318:     {
2319:       vec<constructor_elt, va_gc> *elts = CONSTRUCTOR_ELTS (record);
2320:       unsigned HOST_WIDE_INT idx;
2321:       tree index, value;
2322:       FOR_EACH_CONSTRUCTOR_ELT (elts, idx, index, value)
2323:        if (index == field)
2324:         return value;
2325:       return ref;
2326:     }
2327:
2328:   return fold (ref);
2329: }
2330:
2331: /* Likewise, but return NULL_EXPR and generate a Program_Error if the
2332:    field is not found in the record.  */
2333:
2334: tree
2335: build_component_ref (tree record, tree field, bool no_fold)
2336: {
2337:   tree ref = build_simple_component_ref (record, field, no_fold);
2338:   if (ref)
2339:     return ref;
2340:
2341:   /* The missing field should have been detected in the front-end.  */
2342:   gigi_checking_assert (false);
2343:
2344:   /* Assume this is an invalid user field so raise Program_Error.  */
2345:   return build1 (NULL_EXPR, TREE_TYPE (field),
2346:                  build_call_raise (PE_Explicit_Raise, Empty,
2347:                                    N_Raise_Program_Error));
2348: }
2349:
2350: /* Helper for build_call_alloc_dealloc, with arguments to be interpreted
2351:    identically.  Process the case where a GNAT_PROC to call is provided.  */
2352:
2353: static inline tree
2354: build_call_alloc_dealloc_proc (tree gnu_obj, tree gnu_size, tree gnu_type,
2355:                                Entity_Id gnat_proc, Entity_Id gnat_pool)
2356: {
2357:   tree gnu_proc = gnat_to_gnu (gnat_proc);
2358:   tree gnu_align = size_int (TYPE_ALIGN (gnu_type) / BITS_PER_UNIT);
2359:
2360:   tree gnu_call;
2361:
2362:   /* A storage pool's underlying type is a record type for both predefined
2363:      storage pools and GNAT simple storage pools.  The return and secondary
2364:      stacks use the same mechanism, but their pool object is an integer.  */
2365:   if (Is_Record_Type (Underlying_Type (Etype (gnat_pool))))
2366:     {
2367:       /* The size is the third parameter; the alignment is the
2368:          same type.  */
2369:       Entity_Id gnat_size_type
2370:         = Etype (Next_Formal (Next_Formal (First_Formal (gnat_proc))));
2371:       tree gnu_size_type = gnat_to_gnu_type (gnat_size_type);
2372:
2373:       tree gnu_pool = gnat_to_gnu (gnat_pool);
2374:       tree gnu_pool_addr = build_unary_op (ADDR_EXPR, NULL_TREE, gnu_pool);
2375:
2376:       gnu_size = convert (gnu_size_type, gnu_size);
2377:       gnu_align = convert (gnu_size_type, gnu_align);
2378:
2379:       /* The first arg is always the address of the storage pool; next
2380:          comes the address of the object, for a deallocator, then the
2381:          size and alignment.  */
2382:       if (gnu_obj)
2383:         gnu_call = build_call_n_expr (gnu_proc, 4, gnu_pool_addr, gnu_obj,
2384:                                       gnu_size, gnu_align);
2385:       else
2386:         gnu_call = build_call_n_expr (gnu_proc, 3, gnu_pool_addr,
2387:                                       gnu_size, gnu_align);
2388:     }
2389:
2390:   else
2391:     {
2392:       /* The size is the second parameter.  */
2393:       Entity_Id gnat_size_type
2394:         = Etype (Next_Formal (First_Formal (gnat_proc)));
2395:       tree gnu_size_type = gnat_to_gnu_type (gnat_size_type);
2396:
2397:       /* Deallocation is not supported for return and secondary stacks.  */
2398:       gcc_assert (!gnu_obj);
2399:
2400:       gnu_size = convert (gnu_size_type, gnu_size);
2401:       gnu_align = convert (gnu_size_type, gnu_align);
2402:
2403:       if (DECL_BUILT_IN_CLASS (gnu_proc) == BUILT_IN_FRONTEND
2404:           && DECL_FE_FUNCTION_CODE (gnu_proc) == BUILT_IN_RETURN_SLOT)
2405:         {
2406:           /* This must be a function that returns by invisible reference.  */
2407:           gcc_assert (current_function_decl
2408:                       && TREE_ADDRESSABLE (TREE_TYPE (current_function_decl)));
2409:           tree gnu_ret_size;
2410:
2411:           gnu_call = DECL_RESULT (current_function_decl);
2412:
2413:           /* The allocation has already been done by the caller so we check that
2414:              we are not going to overflow the return slot.  */
2415:           if (TYPE_CI_CO_LIST (TREE_TYPE (current_function_decl)))
2416:             gnu_ret_size
2417:               = TYPE_SIZE_UNIT
2418:                 (TREE_TYPE (TYPE_FIELDS (TREE_TYPE (TREE_TYPE (gnu_call)))));
2419:           else
2420:             gnu_ret_size = TYPE_SIZE_UNIT (TREE_TYPE (TREE_TYPE (gnu_call)));
2421:
2422:           gnu_call
2423:             = fold_build3 (COND_EXPR, TREE_TYPE (gnu_call),
2424:                            fold_build2 (LE_EXPR, boolean_type_node,
2425:                                         fold_convert (sizetype, gnu_size),
2426:                                         gnu_ret_size),
2427:                            gnu_call,
2428:                            build_call_raise (PE_Explicit_Raise, Empty,
2429:                                              N_Raise_Program_Error));
2430:         }
2431:
2432:       else
2433:         gnu_call = build_call_n_expr (gnu_proc, 2, gnu_size, gnu_align);
2434:     }
2435:
```

## gcc/ada/gcc-interface/utils2.cc:2564–2761

```text
2564: build_call_alloc_dealloc (tree gnu_obj, tree gnu_size, tree gnu_type,
2565:                           Entity_Id gnat_proc, Entity_Id gnat_pool,
2566:                           Node_Id gnat_node)
2567: {
2568:   /* Explicit proc to call ?  This one is assumed to deal with the type
2569:      alignment constraints.  */
2570:   if (Present (gnat_proc))
2571:     return build_call_alloc_dealloc_proc (gnu_obj, gnu_size, gnu_type,
2572:                                           gnat_proc, gnat_pool);
2573:
2574:   /* Otherwise, object to "free" or "malloc" with possible special processing
2575:      for alignments stricter than what the default allocator honors.  */
2576:   else if (gnu_obj)
2577:     return maybe_wrap_free (gnu_obj, gnu_type, gnat_node);
2578:   else
2579:     {
2580:       /* Assert that we no longer can be called with this special pool.  */
2581:       gcc_assert (gnat_pool != -1);
2582:
2583:       /* Check that we aren't violating the associated restriction.  */
2584:       if (!(Nkind (gnat_node) == N_Allocator && Comes_From_Source (gnat_node)))
2585:         {
2586:           Check_No_Implicit_Heap_Alloc (gnat_node);
2587:           if (Has_Task (Etype (gnat_node)))
2588:             Check_No_Implicit_Task_Alloc (gnat_node);
2589:           if (Has_Protected (Etype (gnat_node)))
2590:             Check_No_Implicit_Protected_Alloc (gnat_node);
2591:         }
2592:       return maybe_wrap_malloc (gnu_size, gnu_type, gnat_node);
2593:     }
2594: }
2595:
2596: /* Build a GCC tree that corresponds to allocating an object of TYPE whose
2597:    initial value is INIT, if INIT is nonzero.  Convert the expression to
2598:    RESULT_TYPE, which must be some pointer type, and return the result.
2599:
2600:    GNAT_PROC and GNAT_POOL optionally give the procedure to call and
2601:    the storage pool to use.  GNAT_NODE is used to provide an error
2602:    location for restriction violation messages.  If IGNORE_INIT_TYPE is
2603:    true, ignore the type of INIT for the purpose of determining the size;
2604:    this will cause the maximum size to be allocated if TYPE is of
2605:    self-referential size.  */
2606:
2607: tree
2608: build_allocator (tree type, tree init, tree result_type, Entity_Id gnat_proc,
2609:                  Entity_Id gnat_pool, Node_Id gnat_node, bool ignore_init_type)
2610: {
2611:   const bool pool_is_storage_model
2612:     = Present (gnat_pool)
2613:       && Has_Storage_Model_Type_Aspect (Etype (gnat_pool))
2614:       && Present (Storage_Model_Copy_To (gnat_pool));
2615:   tree size, storage, storage_deref, storage_init;
2616:
2617:   /* If the initializer, if present, is a NULL_EXPR, just return a new one.  */
2618:   if (init && TREE_CODE (init) == NULL_EXPR)
2619:     return build1 (NULL_EXPR, result_type, TREE_OPERAND (init, 0));
2620:
2621:   /* If we are just annotating types, also return a NULL_EXPR.  */
2622:   else if (type_annotate_only)
2623:     return build1 (NULL_EXPR, result_type,
2624:                    build_call_raise (CE_Range_Check_Failed, gnat_node,
2625:                                      N_Raise_Constraint_Error));
2626:
2627:   /* If the initializer, if present, is a COND_EXPR, deal with each branch.  */
2628:   else if (init && TREE_CODE (init) == COND_EXPR)
2629:     return build3 (COND_EXPR, result_type, TREE_OPERAND (init, 0),
2630:                    build_allocator (type, TREE_OPERAND (init, 1), result_type,
2631:                                     gnat_proc, gnat_pool, gnat_node,
2632:                                     ignore_init_type),
2633:                    build_allocator (type, TREE_OPERAND (init, 2), result_type,
2634:                                     gnat_proc, gnat_pool, gnat_node,
2635:                                     ignore_init_type));
2636:
2637:   /* If RESULT_TYPE is a fat or thin pointer, set SIZE to be the sum of the
2638:      sizes of the object and its template.  Allocate the whole thing and
2639:      fill in the parts that are known.  */
2640:   else if (TYPE_IS_FAT_OR_THIN_POINTER_P (result_type)
2641:            || TYPE_IS_EXTENDED_POINTER_P (result_type))
2642:     {
2643:       tree storage_type
2644:         = build_unc_object_type_from_ptr (result_type, type,
2645:                                           get_identifier ("ALLOC"), false);
2646:       tree template_type = TREE_TYPE (TYPE_FIELDS (storage_type));
2647:       tree storage_ptr_type = build_pointer_type (storage_type);
2648:       tree lhs, rhs;
2649:
2650:       size = TYPE_SIZE_UNIT (storage_type);
2651:       size = SUBSTITUTE_PLACEHOLDER_IN_EXPR (size, init);
2652:
2653:       /* If the size overflows, pass -1 so Storage_Error will be raised.  */
2654:       if (TREE_CODE (size) == INTEGER_CST && !valid_constant_size_p (size))
2655:         size = size_int (-1);
2656:
2657:       storage = build_call_alloc_dealloc (NULL_TREE, size, storage_type,
2658:                                           gnat_proc, gnat_pool, gnat_node);
2659:       storage = convert (storage_ptr_type, gnat_protect_expr (storage));
2660:       storage_deref = build_unary_op (INDIRECT_REF, NULL_TREE, storage);
2661:       TREE_THIS_NOTRAP (storage_deref) = 1;
2662:
2663:       /* If there is an initializing expression, then make a constructor for
2664:          the entire object including the bounds and copy it into the object.
2665:          If there is no initializing expression, just set the bounds.  Note
2666:          that, if we have a storage model, we need to copy the initializing
2667:          expression separately from the bounds.  */
2668:       if (init && !pool_is_storage_model)
2669:         {
2670:           vec<constructor_elt, va_gc> *v;
2671:           vec_alloc (v, 2);
2672:
2673:           CONSTRUCTOR_APPEND_ELT (v, TYPE_FIELDS (storage_type),
2674:                                   build_template (template_type, type, init));
2675:           CONSTRUCTOR_APPEND_ELT (v, DECL_CHAIN (TYPE_FIELDS (storage_type)),
2676:                                   init);
2677:
2678:           lhs = storage_deref;
2679:           rhs = gnat_build_constructor (storage_type, v);
2680:         }
2681:       else
2682:         {
2683:           lhs = build_component_ref (storage_deref, TYPE_FIELDS (storage_type),
2684:                                      false);
2685:           rhs = build_template (template_type, type, init);
2686:         }
2687:
2688:       if (pool_is_storage_model)
2689:         {
2690:           storage_init = build_storage_model_store (gnat_pool, lhs, rhs);
2691:           if (init)
2692:             {
2693:               start_stmt_group ();
2694:               add_stmt (storage_init);
2695:               lhs
2696:                 = build_component_ref (storage_deref,
2697:                                        DECL_CHAIN (TYPE_FIELDS (storage_type)),
2698:                                        false);
2699:               rhs = init;
2700:               size = TYPE_SIZE_UNIT (TREE_TYPE (lhs));
2701:               size = SUBSTITUTE_PLACEHOLDER_IN_EXPR (size, init);
2702:               tree t = build_storage_model_store (gnat_pool, lhs, rhs, size);
2703:               add_stmt (t);
2704:               storage_init = end_stmt_group ();
2705:             }
2706:         }
2707:       else
2708:         storage_init = build_binary_op (INIT_EXPR, NULL_TREE, lhs, rhs);
2709:
2710:       return build2 (COMPOUND_EXPR, result_type,
2711:                      storage_init, convert (result_type, storage));
2712:     }
2713:
2714:   size = TYPE_SIZE_UNIT (type);
2715:
2716:   /* If we have an initializing expression, see if its size is simpler
2717:      than the size from the type.  */
2718:   if (!ignore_init_type && init && TYPE_SIZE_UNIT (TREE_TYPE (init))
2719:       && (TREE_CODE (TYPE_SIZE_UNIT (TREE_TYPE (init))) == INTEGER_CST
2720:           || CONTAINS_PLACEHOLDER_P (size)))
2721:     size = TYPE_SIZE_UNIT (TREE_TYPE (init));
2722:
2723:   /* If the size is still self-referential, reference the initializing
2724:      expression, if it is present.  If not, this must have been a call
2725:      to allocate a library-level object, in which case we just use the
2726:      maximum size.  */
2727:   if (!ignore_init_type && init)
2728:     size = SUBSTITUTE_PLACEHOLDER_IN_EXPR (size, init);
2729:   else if (CONTAINS_PLACEHOLDER_P (size))
2730:     size = max_size (size, true);
2731:
2732:   /* If the size overflows, pass -1 so Storage_Error will be raised.  */
2733:   if (TREE_CODE (size) == INTEGER_CST && !valid_constant_size_p (size))
2734:     size = size_int (-1);
2735:
2736:   storage = convert (result_type,
2737:                      build_call_alloc_dealloc (NULL_TREE, size, type,
2738:                                                gnat_proc, gnat_pool,
2739:                                                gnat_node));
2740:
2741:   /* If we have an initial value, protect the new address, assign the value
2742:      and return the address with a COMPOUND_EXPR.  */
2743:   if (init)
2744:     {
2745:       storage = gnat_protect_expr (storage);
2746:       storage_deref = build_unary_op (INDIRECT_REF, NULL_TREE, storage);
2747:       TREE_THIS_NOTRAP (storage_deref) = 1;
2748:       if (pool_is_storage_model)
2749:         storage_init
2750:           = build_storage_model_store (gnat_pool, storage_deref, init, size);
2751:       else
2752:         storage_init
2753:           = build_binary_op (INIT_EXPR, NULL_TREE, storage_deref, init);
2754:       return build2 (COMPOUND_EXPR, result_type, storage_init, storage);
2755:     }
2756:
2757:   return storage;
2758: }
2759:
2760: /* Build a call to a copy procedure of a storage model given by an object.
2761:    DEST, SRC and SIZE are as for a call to memcpy.  GNAT_SMO is the entity
```

## gcc/ada/gcc-interface/utils2.cc:3009–3380

```text
3009: gnat_mark_addressable (tree t)
3010: {
3011:   while (true)
3012:     switch (TREE_CODE (t))
3013:       {
3014:       case ADDR_EXPR:
3015:       case COMPONENT_REF:
3016:       case ARRAY_REF:
3017:       case ARRAY_RANGE_REF:
3018:       case REALPART_EXPR:
3019:       case IMAGPART_EXPR:
3020:       case VIEW_CONVERT_EXPR:
3021:       case NON_LVALUE_EXPR:
3022:       CASE_CONVERT:
3023:         t = TREE_OPERAND (t, 0);
3024:         break;
3025:
3026:       case COMPOUND_EXPR:
3027:         t = TREE_OPERAND (t, 1);
3028:         break;
3029:
3030:       case CONSTRUCTOR:
3031:         TREE_ADDRESSABLE (t) = 1;
3032:         return true;
3033:
3034:       case VAR_DECL:
3035:       case PARM_DECL:
3036:       case RESULT_DECL:
3037:         TREE_ADDRESSABLE (t) = 1;
3038:         return true;
3039:
3040:       case FUNCTION_DECL:
3041:         TREE_ADDRESSABLE (t) = 1;
3042:         return true;
3043:
3044:       case CONST_DECL:
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
3180: static tree
3181: gnat_stabilize_reference_1 (tree e, void *data)
3182: {
3183:   const bool force = *(bool *)data;
3184:   enum tree_code code = TREE_CODE (e);
3185:   tree type = TREE_TYPE (e);
3186:   tree result;
3187:
3188:   if (gnat_stable_expr_p (e))
3189:     return e;
3190:
3191:   switch (TREE_CODE_CLASS (code))
3192:     {
3193:     case tcc_exceptional:
3194:     case tcc_declaration:
3195:     case tcc_comparison:
3196:     case tcc_expression:
3197:     case tcc_reference:
3198:     case tcc_vl_exp:
3199:       /* If this is a COMPONENT_REF of a fat pointer, save the entire
3200:          fat pointer.  This may be more efficient, but will also allow
3201:          us to more easily find the match for the PLACEHOLDER_EXPR.  */
3202:       if (code == COMPONENT_REF
3203:           && (TYPE_IS_FAT_POINTER_P (TREE_TYPE (TREE_OPERAND (e, 0)))
3204:               || TYPE_IS_EXTENDED_POINTER_P (TREE_TYPE (TREE_OPERAND (e, 0)))))
3205:         result
3206:           = build3 (code, type,
3207:                     gnat_stabilize_reference_1 (TREE_OPERAND (e, 0), data),
3208:                     TREE_OPERAND (e, 1), NULL_TREE);
3209:       /* If the expression has side-effects, then encase it in a SAVE_EXPR
3210:          so that it will only be evaluated once.  */
3211:       /* The tcc_reference and tcc_comparison classes could be handled as
3212:          below, but it is generally faster to only evaluate them once.  */
3213:       else if (TREE_SIDE_EFFECTS (e) || force)
3214:         return save_expr (e);
3215:       else
3216:         return e;
3217:       break;
3218:
3219:     case tcc_binary:
3220:       /* Recursively stabilize each operand.  */
3221:       result
3222:         = build2 (code, type,
3223:                   gnat_stabilize_reference_1 (TREE_OPERAND (e, 0), data),
3224:                   gnat_stabilize_reference_1 (TREE_OPERAND (e, 1), data));
3225:       break;
3226:
3227:     case tcc_unary:
3228:       /* Recursively stabilize each operand.  */
3229:       result
3230:         = build1 (code, type,
3231:                   gnat_stabilize_reference_1 (TREE_OPERAND (e, 0), data));
3232:       break;
3233:
3234:     default:
3235:       gcc_unreachable ();
3236:     }
3237:
3238:   /* See gnat_rewrite_reference below for the rationale.  */
3239:   TREE_READONLY (result) = TREE_READONLY (e);
3240:   TREE_THIS_VOLATILE (result) = TREE_THIS_VOLATILE (e);
3241:
3242:   if (TREE_SIDE_EFFECTS (e))
3243:     TREE_SIDE_EFFECTS (result) = 1;
3244:
3245:   return result;
3246: }
3247:
3248: /* This is equivalent to stabilize_reference in tree.cc but we know how to
3249:    handle our own nodes and we take extra arguments.  FORCE says whether to
3250:    force evaluation of everything in REF.  INIT is set to the first arm of
3251:    a COMPOUND_EXPR present in REF, if any.  */
3252:
3253: tree
3254: gnat_stabilize_reference (tree ref, bool force, tree *init)
3255: {
3256:   return
3257:     gnat_rewrite_reference (ref, gnat_stabilize_reference_1, &force, init);
3258: }
3259:
3260: /* Rewrite reference REF and call FUNC on each expression within REF in the
3261:    process.  DATA is passed unmodified to FUNC.  INIT is set to the first
3262:    arm of a COMPOUND_EXPR present in REF, if any.  */
3263:
3264: tree
3265: gnat_rewrite_reference (tree ref, rewrite_fn func, void *data, tree *init)
3266: {
3267:   tree type = TREE_TYPE (ref);
3268:   enum tree_code code = TREE_CODE (ref);
3269:   tree result;
3270:
3271:   switch (code)
3272:     {
3273:     case CONST_DECL:
3274:     case VAR_DECL:
3275:     case PARM_DECL:
3276:     case RESULT_DECL:
3277:       /* No action is needed in this case.  */
3278:       return ref;
3279:
3280:     CASE_CONVERT:
3281:     case FLOAT_EXPR:
3282:     case FIX_TRUNC_EXPR:
3283:     case REALPART_EXPR:
3284:     case IMAGPART_EXPR:
3285:     case VIEW_CONVERT_EXPR:
3286:       result
3287:         = build1 (code, type,
3288:                   gnat_rewrite_reference (TREE_OPERAND (ref, 0), func, data,
3289:                                           init));
3290:       break;
3291:
3292:     case INDIRECT_REF:
3293:     case UNCONSTRAINED_ARRAY_REF:
3294:       result = build1 (code, type, func (TREE_OPERAND (ref, 0), data));
3295:       break;
3296:
3297:     case COMPONENT_REF:
3298:       result = build3 (COMPONENT_REF, type,
3299:                        gnat_rewrite_reference (TREE_OPERAND (ref, 0), func,
3300:                                                data, init),
3301:                        TREE_OPERAND (ref, 1), NULL_TREE);
3302:       break;
3303:
3304:     case BIT_FIELD_REF:
3305:       result = build3 (BIT_FIELD_REF, type,
3306:                        gnat_rewrite_reference (TREE_OPERAND (ref, 0), func,
3307:                                                data, init),
3308:                        TREE_OPERAND (ref, 1), TREE_OPERAND (ref, 2));
3309:       REF_REVERSE_STORAGE_ORDER (result) = REF_REVERSE_STORAGE_ORDER (ref);
3310:       break;
3311:
3312:     case ARRAY_REF:
3313:     case ARRAY_RANGE_REF:
3314:       result
3315:         = build4 (code, type,
3316:                   gnat_rewrite_reference (TREE_OPERAND (ref, 0), func, data,
3317:                                           init),
3318:                   func (TREE_OPERAND (ref, 1), data),
3319:                   TREE_OPERAND (ref, 2), TREE_OPERAND (ref, 3));
3320:       break;
3321:
3322:     case COMPOUND_EXPR:
3323:       gcc_assert (!*init);
3324:       *init = TREE_OPERAND (ref, 0);
3325:       /* We expect only the pattern built in Call_to_gnu.  */
3326:       gcc_assert (DECL_P (TREE_OPERAND (ref, 1))
3327:                   || (TREE_CODE (TREE_OPERAND (ref, 1)) == COMPONENT_REF
3328:                       && DECL_P (TREE_OPERAND (TREE_OPERAND (ref, 1), 0))));
3329:       return TREE_OPERAND (ref, 1);
3330:
3331:     case CALL_EXPR:
3332:       {
3333:         /* This can only be an atomic load.  */
3334:         gcc_assert (call_is_atomic_load (ref));
3335:
3336:         /* An atomic load is an INDIRECT_REF of its first argument.  */
3337:         tree t = CALL_EXPR_ARG (ref, 0);
3338:         if (TREE_CODE (t) == NOP_EXPR)
3339:           t = TREE_OPERAND (t, 0);
3340:         if (TREE_CODE (t) == ADDR_EXPR)
3341:           t = build1 (ADDR_EXPR, TREE_TYPE (t),
3342:                       gnat_rewrite_reference (TREE_OPERAND (t, 0), func, data,
3343:                                               init));
3344:         else
3345:           t = func (t, data);
3346:         t = fold_convert (TREE_TYPE (CALL_EXPR_ARG (ref, 0)), t);
3347:
3348:         result = build_call_expr (TREE_OPERAND (CALL_EXPR_FN (ref), 0), 2,
3349:                                   t, CALL_EXPR_ARG (ref, 1));
3350:       }
3351:       break;
3352:
3353:     case ERROR_MARK:
3354:     case NULL_EXPR:
3355:       return ref;
3356:
3357:     default:
3358:       gcc_unreachable ();
3359:     }
3360:
3361:   /* TREE_READONLY and TREE_THIS_VOLATILE set on the initial expression may
3362:      not be sustained across some paths, such as the one for INDIRECT_REF.
3363:
3364:      Special care should be taken regarding TREE_SIDE_EFFECTS, because some
3365:      paths introduce side-effects where there was none initially (e.g. if a
3366:      SAVE_EXPR is built) and we also want to keep track of that.  */
3367:   TREE_READONLY (result) = TREE_READONLY (ref);
3368:   TREE_THIS_VOLATILE (result) = TREE_THIS_VOLATILE (ref);
3369:
3370:   if (TREE_SIDE_EFFECTS (ref))
3371:     TREE_SIDE_EFFECTS (result) = 1;
3372:
3373:   if (code == INDIRECT_REF
3374:       || code == UNCONSTRAINED_ARRAY_REF
3375:       || code == ARRAY_REF
3376:       || code == ARRAY_RANGE_REF)
3377:     TREE_THIS_NOTRAP (result) = TREE_THIS_NOTRAP (ref);
3378:
3379:   return result;
3380: }
```

## gcc/ada/gcc-interface/gigi.h:1299–1307

```text
1299: maybe_padded_object (tree expr)
1300: {
1301:   tree type = TREE_TYPE (expr);
1302:
1303:   if (TYPE_IS_PADDING_P (type))
1304:     expr = convert (TREE_TYPE (TYPE_FIELDS (type)), expr);
1305:
1306:   return expr;
1307: }
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

## gcc/tree.cc:4080–4106

```text
4080:
4081:   STRIP_ANY_LOCATION_WRAPPER (t);
4082:   return CONSTANT_CLASS_P (t) || decl_address_invariant_p (t);
4083: }
4084:
4085:
4086: /* Return true if T is function-invariant (internal function, does
4087:    not handle arithmetic; that's handled in skip_simple_arithmetic and
4088:    tree_invariant_p).  */
4089:
4090: static bool
4091: tree_invariant_p_1 (tree t)
4092: {
4093:   if (TREE_CONSTANT (t) || (TREE_READONLY (t) && !TREE_SIDE_EFFECTS (t)))
4094:     return true;
4095:
4096:   switch (TREE_CODE (t))
4097:     {
4098:     case SAVE_EXPR:
4099:     case TARGET_EXPR:
4100:       return true;
4101:
4102:     case ADDR_EXPR:
4103:       return address_invariant_p (TREE_OPERAND (t, 0));
4104:
4105:     default:
4106:       break;
```

## gcc/tree.cc:4132–4223

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
4165:      and some variable since it would then need to be both evaluated once and
4166:      evaluated more than once.  Front-ends must assure this case cannot
4167:      happen by surrounding any such subexpressions in their own SAVE_EXPR
4168:      and forcing evaluation at the proper time.  */
4169:   if (contains_placeholder_p (inner))
4170:     return expr;
4171:
4172:   expr = build1_loc (EXPR_LOCATION (expr), SAVE_EXPR, TREE_TYPE (expr), expr);
4173:
4174:   /* This expression might be placed ahead of a jump to ensure that the
4175:      value was computed on both sides of the jump.  So make sure it isn't
4176:      eliminated as dead.  */
4177:   TREE_SIDE_EFFECTS (expr) = 1;
4178:   return expr;
4179: }
4180:
4181: /* Look inside EXPR into any simple arithmetic operations.  Return the
4182:    outermost non-arithmetic or non-invariant node.  */
4183:
4184: tree
4185: skip_simple_arithmetic (tree expr)
4186: {
4187:   /* We don't care about whether this can be used as an lvalue in this
4188:      context.  */
4189:   while (TREE_CODE (expr) == NON_LVALUE_EXPR)
4190:     expr = TREE_OPERAND (expr, 0);
4191:
4192:   /* If we have simple operations applied to a SAVE_EXPR or to a SAVE_EXPR and
4193:      a constant, it will be more efficient to not make another SAVE_EXPR since
4194:      it will allow better simplification and GCSE will be able to merge the
4195:      computations if they actually occur.  */
4196:   while (true)
4197:     {
4198:       if (UNARY_CLASS_P (expr))
4199:         expr = TREE_OPERAND (expr, 0);
4200:       else if (BINARY_CLASS_P (expr))
4201:         {
4202:           /* Before commutative binary operands are canonicalized,
4203:              it is quite common to have constants in the first operand.
4204:              Check for that common case first so that we don't walk
4205:              large expressions with tree_invariant_p unnecessarily.
4206:              This can still have terrible compile time complexity,
4207:              we should limit the depth of the tree_invariant_p and
4208:              skip_simple_arithmetic recursion.  */
4209:           if ((TREE_CONSTANT (TREE_OPERAND (expr, 0))
4210:                || (TREE_READONLY (TREE_OPERAND (expr, 0))
4211:                    && !TREE_SIDE_EFFECTS (TREE_OPERAND (expr, 0))))
4212:               && tree_invariant_p (TREE_OPERAND (expr, 0)))
4213:             expr = TREE_OPERAND (expr, 1);
4214:           else if (tree_invariant_p (TREE_OPERAND (expr, 1)))
4215:             expr = TREE_OPERAND (expr, 0);
4216:           else if (tree_invariant_p (TREE_OPERAND (expr, 0)))
4217:             expr = TREE_OPERAND (expr, 1);
4218:           else
4219:             break;
4220:         }
4221:       else
4222:         break;
4223:     }
```

## gcc/tree.cc:6982–7023

```text
6982: compare_tree_int (const_tree t, unsigned HOST_WIDE_INT u)
6983: {
6984:   if (tree_int_cst_sgn (t) < 0)
6985:     return -1;
6986:   else if (!tree_fits_uhwi_p (t))
6987:     return 1;
6988:   else if (TREE_INT_CST_LOW (t) == u)
6989:     return 0;
6990:   else if (TREE_INT_CST_LOW (t) < u)
6991:     return -1;
6992:   else
6993:     return 1;
6994: }
6995:
6996: /* Return true if SIZE represents a constant size that is in bounds of
6997:    what the middle-end and the backend accepts (covering not more than
6998:    half of the address-space).
6999:    When PERR is non-null, set *PERR on failure to the description of
7000:    why SIZE is not valid.  */
7001:
7002: bool
7003: valid_constant_size_p (const_tree size, cst_size_error *perr /* = NULL */)
7004: {
7005:   if (POLY_INT_CST_P (size))
7006:     {
7007:       if (TREE_OVERFLOW (size))
7008:         return false;
7009:       for (unsigned int i = 0; i < NUM_POLY_INT_COEFFS; ++i)
7010:         if (!valid_constant_size_p (POLY_INT_CST_COEFF (size, i)))
7011:           return false;
7012:       return true;
7013:     }
7014:
7015:   cst_size_error error;
7016:   if (!perr)
7017:     perr = &error;
7018:
7019:   if (TREE_CODE (size) != INTEGER_CST)
7020:     {
7021:       *perr = cst_size_not_constant;
7022:       return false;
7023:     }
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

## gcc/gimplify.cc:83–124

```text
83: static unsigned nextconduid = 1;
84:
85: /* Annotated gconds so that basic conditions in the same expression map to
86:    the same uid.  This is used for condition coverage.  */
87: static hash_map <tree, unsigned> *cond_uids;
88:
89: /* Get a fresh identifier for a new condition expression.  This is used for
90:    condition coverage.  */
91: static unsigned
92: next_cond_uid ()
93: {
94:   return nextconduid++;
95: }
96:
97: /* Reset the condition uid to the value it should have when compiling a new
98:    function.  0 is already the default/untouched value, so start at non-zero.
99:    A valid and set id should always be > 0.  This is used for condition
100:    coverage.  */
101: static void
102: reset_cond_uid ()
103: {
104:   nextconduid = 1;
105: }
106:
107: /* Associate the condition STMT with the discriminator UID.  STMTs that are
108:    broken down with ANDIF/ORIF from the same Boolean expression should be given
109:    the same UID; 'if (a && b && c) { if (d || e) ... } ...' should yield the
110:    { a: 1, b: 1, c: 1, d: 2, e: 2 } when gimplification is done.  This is used
111:    for condition coverage.  */
112: static void
113: tree_associate_condition_with_expr (tree stmt, unsigned uid)
114: {
115:   if (!condition_coverage_flag)
116:     return;
117:
118:   if (!cond_uids)
119:     cond_uids = new hash_map <tree, unsigned> ();
120:
121:   cond_uids->put (stmt, uid);
122: }
123:
124: /* Hash set of poisoned variables in a bind expr.  */
```

## gcc/gimplify.cc:387–395

```text
387: push_gimplify_context (bool in_ssa, bool rhs_cond_ok)
388: {
389:   struct gimplify_ctx *c = ctx_alloc ();
390:
391:   c->prev_context = gimplify_ctxp;
392:   gimplify_ctxp = c;
393:   gimplify_ctxp->into_ssa = in_ssa;
394:   gimplify_ctxp->allow_rhs_cond_expr = rhs_cond_ok;
395: }
```

## gcc/gimplify.cc:460–488

```text
460: static bool
461: gimple_conditional_context (void)
462: {
463:   return gimplify_ctxp->conditions > 0;
464: }
465:
466: /* Note that we've entered a COND_EXPR.  */
467:
468: static void
469: gimple_push_condition (void)
470: {
471: #ifdef ENABLE_GIMPLE_CHECKING
472:   if (gimplify_ctxp->conditions == 0)
473:     gcc_assert (gimple_seq_empty_p (gimplify_ctxp->conditional_cleanups));
474: #endif
475:   ++(gimplify_ctxp->conditions);
476: }
477:
478: /* Note that we've left a COND_EXPR.  If we're back at unconditional scope
479:    now, add any conditional cleanups we've seen to the prequeue.  */
480:
481: static void
482: gimple_pop_condition (gimple_seq *pre_p)
483: {
484:   int conds = --(gimplify_ctxp->conditions);
485:
486:   gcc_assert (conds >= 0);
487:   if (conds == 0)
488:     {
```

## gcc/gimplify.cc:619–721

```text
619: }
620:
621: /* Create a temporary with a name derived from VAL.  Subroutine of
622:    lookup_tmp_var; nobody else should call this function.  */
623:
624: static inline tree
625: create_tmp_from_val (tree val)
626: {
627:   /* Drop all qualifiers and address-space information from the value type.  */
628:   tree type = TYPE_MAIN_VARIANT (TREE_TYPE (val));
629:   tree var = create_tmp_var (type, get_name (val));
630:   return var;
631: }
632:
633: /* Create a temporary to hold the value of VAL.  If IS_FORMAL, try to reuse
634:    an existing expression temporary.  If NOT_GIMPLE_REG, mark it as such.  */
635:
636: static tree
637: lookup_tmp_var (tree val, bool is_formal, bool not_gimple_reg)
638: {
639:   tree ret;
640:
641:   /* We cannot mark a formal temporary with DECL_NOT_GIMPLE_REG_P.  */
642:   gcc_assert (!is_formal || !not_gimple_reg);
643:
644:   /* If not optimizing, never really reuse a temporary.  local-alloc
645:      won't allocate any variable that is used in more than one basic
646:      block, which means it will go into memory, causing much extra
647:      work in reload and final and poorer code generation, outweighing
648:      the extra memory allocation here.  */
649:   if (!optimize || !is_formal || TREE_SIDE_EFFECTS (val))
650:     {
651:       ret = create_tmp_from_val (val);
652:       DECL_NOT_GIMPLE_REG_P (ret) = not_gimple_reg;
653:     }
654:   else
655:     {
656:       elt_t elt, *elt_p;
657:       elt_t **slot;
658:
659:       elt.val = val;
660:       if (!gimplify_ctxp->temp_htab)
661:         gimplify_ctxp->temp_htab = new hash_table<gimplify_hasher> (1000);
662:       slot = gimplify_ctxp->temp_htab->find_slot (&elt, INSERT);
663:       if (*slot == NULL)
664:         {
665:           elt_p = XNEW (elt_t);
666:           elt_p->val = val;
667:           elt_p->temp = ret = create_tmp_from_val (val);
668:           *slot = elt_p;
669:         }
670:       else
671:         {
672:           elt_p = *slot;
673:           ret = elt_p->temp;
674:         }
675:     }
676:
677:   return ret;
678: }
679:
680: /* Helper for get_formal_tmp_var and get_initialized_tmp_var.  */
681:
682: static tree
683: internal_get_tmp_var (tree val, gimple_seq *pre_p, gimple_seq *post_p,
684:                       bool is_formal, bool allow_ssa, bool not_gimple_reg)
685: {
686:   tree t, mod;
687:
688:   /* Notice that we explicitly allow VAL to be a CALL_EXPR so that we
689:      can create an INIT_EXPR and convert it into a GIMPLE_CALL below.  */
690:   gimplify_expr (&val, pre_p, post_p, is_gimple_reg_rhs_or_call,
691:                  fb_rvalue);
692:
693:   if (allow_ssa
694:       && gimplify_ctxp->into_ssa
695:       && is_gimple_reg_type (TREE_TYPE (val)))
696:     {
697:       t = make_ssa_name (TYPE_MAIN_VARIANT (TREE_TYPE (val)));
698:       if (! gimple_in_ssa_p (cfun))
699:         {
700:           const char *name = get_name (val);
701:           if (name)
702:             SET_SSA_NAME_VAR_OR_IDENTIFIER (t, create_tmp_var_name (name));
703:         }
704:     }
705:   else
706:     t = lookup_tmp_var (val, is_formal, not_gimple_reg);
707:
708:   mod = build2 (INIT_EXPR, TREE_TYPE (t), t, unshare_expr (val));
709:
710:   SET_EXPR_LOCATION (mod, EXPR_LOC_OR_LOC (val, input_location));
711:
712:   /* gimplify_modify_expr might want to reduce this further.  */
713:   gimplify_and_add (mod, pre_p);
714:   ggc_free (mod);
715:
716:   /* If we failed to gimplify VAL then we can end up with the temporary
717:      SSA name not having a definition.  In this case return a decl.  */
718:   if (TREE_CODE (t) == SSA_NAME && ! SSA_NAME_DEF_STMT (t))
719:     return lookup_tmp_var (val, is_formal, not_gimple_reg);
720:
721:   return t;
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

## gcc/gimplify.cc:1971–2008

```text
1971:
1972: static void
1973: gimplify_vla_decl (tree decl, gimple_seq *seq_p)
1974: {
1975:   /* This is a variable-sized decl.  Simplify its size and mark it
1976:      for deferred expansion.  */
1977:   tree t, addr, ptr_type;
1978:
1979:   gimplify_one_sizepos (&DECL_SIZE (decl), seq_p);
1980:   gimplify_one_sizepos (&DECL_SIZE_UNIT (decl), seq_p);
1981:
1982:   /* Don't mess with a DECL_VALUE_EXPR set by the front-end.  */
1983:   if (DECL_HAS_VALUE_EXPR_P (decl))
1984:     return;
1985:
1986:   /* All occurrences of this decl in final gimplified code will be
1987:      replaced by indirection.  Setting DECL_VALUE_EXPR does two
1988:      things: First, it lets the rest of the gimplifier know what
1989:      replacement to use.  Second, it lets the debug info know
1990:      where to find the value.  */
1991:   ptr_type = build_pointer_type (TREE_TYPE (decl));
1992:   addr = create_tmp_var (ptr_type, get_name (decl));
1993:   DECL_IGNORED_P (addr) = 0;
1994:   t = build_fold_indirect_ref (addr);
1995:   TREE_THIS_NOTRAP (t) = 1;
1996:   SET_DECL_VALUE_EXPR (decl, t);
1997:   DECL_HAS_VALUE_EXPR_P (decl) = 1;
1998:
1999:   t = build_alloca_call_expr (DECL_SIZE_UNIT (decl), DECL_ALIGN (decl),
2000:                               max_int_size_in_bytes (TREE_TYPE (decl)));
2001:   /* The call has been built for a variable-sized object.  */
2002:   CALL_ALLOCA_FOR_VAR_P (t) = 1;
2003:   t = fold_convert (ptr_type, t);
2004:   t = build2 (MODIFY_EXPR, TREE_TYPE (addr), addr, t);
2005:
2006:   gimplify_and_add (t, seq_p);
2007:
2008:   /* Record the dynamic allocation associated with DECL if requested.  */
```

## gcc/gimplify.cc:2124–2157

```text
2124:
2125: static enum gimplify_status
2126: gimplify_decl_expr (tree *stmt_p, gimple_seq *seq_p)
2127: {
2128:   tree stmt = *stmt_p;
2129:   tree decl = DECL_EXPR_DECL (stmt);
2130:
2131:   *stmt_p = NULL_TREE;
2132:
2133:   if (TREE_TYPE (decl) == error_mark_node)
2134:     return GS_ERROR;
2135:
2136:   if ((TREE_CODE (decl) == TYPE_DECL
2137:        || VAR_P (decl))
2138:       && !TYPE_SIZES_GIMPLIFIED (TREE_TYPE (decl)))
2139:     {
2140:       gimplify_type_sizes (TREE_TYPE (decl), seq_p);
2141:       if (TREE_CODE (TREE_TYPE (decl)) == REFERENCE_TYPE)
2142:         gimplify_type_sizes (TREE_TYPE (TREE_TYPE (decl)), seq_p);
2143:     }
2144:
2145:   /* ??? DECL_ORIGINAL_TYPE is streamed for LTO so it needs to be gimplified
2146:      in case its size expressions contain problematic nodes like CALL_EXPR.  */
2147:   if (TREE_CODE (decl) == TYPE_DECL
2148:       && DECL_ORIGINAL_TYPE (decl)
2149:       && !TYPE_SIZES_GIMPLIFIED (DECL_ORIGINAL_TYPE (decl)))
2150:     {
2151:       gimplify_type_sizes (DECL_ORIGINAL_TYPE (decl), seq_p);
2152:       if (TREE_CODE (DECL_ORIGINAL_TYPE (decl)) == REFERENCE_TYPE)
2153:         gimplify_type_sizes (TREE_TYPE (DECL_ORIGINAL_TYPE (decl)), seq_p);
2154:     }
2155:
2156:   if (VAR_P (decl) && !DECL_EXTERNAL (decl))
2157:     {
```

## gcc/gimplify.cc:2198–2225

```text
2198:
2199:       /* Some front ends do not explicitly declare all anonymous
2200:          artificial variables.  We compensate here by declaring the
2201:          variables, though it would be better if the front ends would
2202:          explicitly declare them.  */
2203:       if (!DECL_SEEN_IN_BIND_EXPR_P (decl)
2204:           && DECL_ARTIFICIAL (decl) && DECL_NAME (decl) == NULL_TREE)
2205:         gimple_add_tmp_var (decl);
2206:
2207:       if (init && init != error_mark_node)
2208:         {
2209:           if (!TREE_STATIC (decl))
2210:             {
2211:               DECL_INITIAL (decl) = NULL_TREE;
2212:               init = build2 (INIT_EXPR, void_type_node, decl, init);
2213:               gimplify_and_add (init, seq_p);
2214:               ggc_free (init);
2215:               /* Clear TREE_READONLY if we really have an initialization.  */
2216:               if (!DECL_INITIAL (decl)
2217:                   && !omp_privatize_by_reference (decl))
2218:                 TREE_READONLY (decl) = 0;
2219:             }
2220:           else
2221:             /* We must still examine initializers for static variables
2222:                as they may contain a label address.  */
2223:             walk_tree (&init, force_labels_r, NULL, NULL);
2224:         }
2225:       /* When there is no explicit initializer, if the user requested,
```

## gcc/gimplify.cc:3221–3235

```text
3221:    if necessary.  */
3222:
3223: tree
3224: build_and_jump (tree *label_p)
3225: {
3226:   if (label_p == NULL)
3227:     /* If there's nowhere to jump, just fall through.  */
3228:     return NULL_TREE;
3229:
3230:   if (*label_p == NULL_TREE)
3231:     {
3232:       tree label = create_artificial_label (UNKNOWN_LOCATION);
3233:       *label_p = label;
3234:     }
3235:
```

## gcc/gimplify.cc:5036–5137

```text
5036:
5037:    shortcut_cond_r should only be called by shortcut_cond_expr.  */
5038:
5039: static tree
5040: shortcut_cond_r (tree pred, tree *true_label_p, tree *false_label_p,
5041:                  location_t locus, unsigned condition_uid)
5042: {
5043:   tree local_label = NULL_TREE;
5044:   tree t, expr = NULL;
5045:
5046:   /* OK, it's not a simple case; we need to pull apart the COND_EXPR to
5047:      retain the shortcut semantics.  Just insert the gotos here;
5048:      shortcut_cond_expr will append the real blocks later.  */
5049:   if (TREE_CODE (pred) == TRUTH_ANDIF_EXPR)
5050:     {
5051:       location_t new_locus;
5052:
5053:       /* Turn if (a && b) into
5054:
5055:          if (a); else goto no;
5056:          if (b) goto yes; else goto no;
5057:          (no:) */
5058:
5059:       if (false_label_p == NULL)
5060:         false_label_p = &local_label;
5061:
5062:       /* Keep the original source location on the first 'if'.  */
5063:       t = shortcut_cond_r (TREE_OPERAND (pred, 0), NULL, false_label_p, locus,
5064:                            condition_uid);
5065:       append_to_statement_list (t, &expr);
5066:
5067:       /* Set the source location of the && on the second 'if'.  */
5068:       new_locus = rexpr_location (pred, locus);
5069:       t = shortcut_cond_r (TREE_OPERAND (pred, 1), true_label_p, false_label_p,
5070:                            new_locus, condition_uid);
5071:       append_to_statement_list (t, &expr);
5072:     }
5073:   else if (TREE_CODE (pred) == TRUTH_ORIF_EXPR)
5074:     {
5075:       location_t new_locus;
5076:
5077:       /* Turn if (a || b) into
5078:
5079:          if (a) goto yes;
5080:          if (b) goto yes; else goto no;
5081:          (yes:) */
5082:
5083:       if (true_label_p == NULL)
5084:         true_label_p = &local_label;
5085:
5086:       /* Keep the original source location on the first 'if'.  */
5087:       t = shortcut_cond_r (TREE_OPERAND (pred, 0), true_label_p, NULL, locus,
5088:                            condition_uid);
5089:       append_to_statement_list (t, &expr);
5090:
5091:       /* Set the source location of the || on the second 'if'.  */
5092:       new_locus = rexpr_location (pred, locus);
5093:       t = shortcut_cond_r (TREE_OPERAND (pred, 1), true_label_p, false_label_p,
5094:                            new_locus, condition_uid);
5095:       append_to_statement_list (t, &expr);
5096:     }
5097:   else if (TREE_CODE (pred) == COND_EXPR
5098:            && !VOID_TYPE_P (TREE_TYPE (TREE_OPERAND (pred, 1)))
5099:            && !VOID_TYPE_P (TREE_TYPE (TREE_OPERAND (pred, 2))))
5100:     {
5101:       location_t new_locus;
5102:
5103:       /* As long as we're messing with gotos, turn if (a ? b : c) into
5104:          if (a)
5105:            if (b) goto yes; else goto no;
5106:          else
5107:            if (c) goto yes; else goto no;
5108:
5109:          Don't do this if one of the arms has void type, which can happen
5110:          in C++ when the arm is throw.  */
5111:
5112:       /* Keep the original source location on the first 'if'.  Set the source
5113:          location of the ? on the second 'if'.  */
5114:       new_locus = rexpr_location (pred, locus);
5115:       expr = build3 (COND_EXPR, void_type_node, TREE_OPERAND (pred, 0),
5116:                      shortcut_cond_r (TREE_OPERAND (pred, 1), true_label_p,
5117:                                       false_label_p, locus, condition_uid),
5118:                      shortcut_cond_r (TREE_OPERAND (pred, 2), true_label_p,
5119:                                       false_label_p, new_locus,
5120:                                       condition_uid));
5121:       tree_associate_condition_with_expr (expr, condition_uid);
5122:     }
5123:   else
5124:     {
5125:       expr = build3 (COND_EXPR, void_type_node, pred,
5126:                      build_and_jump (true_label_p),
5127:                      build_and_jump (false_label_p));
5128:       SET_EXPR_LOCATION (expr, locus);
5129:       tree_associate_condition_with_expr (expr, condition_uid);
5130:     }
5131:
5132:   if (local_label)
5133:     {
5134:       t = build1 (LABEL_EXPR, void_type_node, local_label);
5135:       append_to_statement_list (t, &expr);
5136:     }
5137:
```

## gcc/gimplify.cc:5184–5809

```text
5184:    used by the condition coverage.  Doing this as an explicit step makes for a
5185:    simpler implementation than weaving it into the splitting code as the
5186:    splitting code eventually calls the entry point gimplfiy_expr which makes
5187:    bookkeeping complicated.  */
5188: static void
5189: tag_shortcut_cond (tree pred, unsigned condition_uid)
5190: {
5191:   if (TREE_CODE (pred) == TRUTH_ANDIF_EXPR
5192:       || TREE_CODE (pred) == TRUTH_ORIF_EXPR)
5193:     {
5194:       tree fst = TREE_OPERAND (pred, 0);
5195:       tree lst = TREE_OPERAND (pred, 1);
5196:
5197:       if (TREE_CODE (fst) == TRUTH_ANDIF_EXPR
5198:           || TREE_CODE (fst) == TRUTH_ORIF_EXPR)
5199:         tag_shortcut_cond (fst, condition_uid);
5200:       else if (TREE_CODE (fst) == COND_EXPR)
5201:         tree_associate_condition_with_expr (fst, condition_uid);
5202:
5203:       if (TREE_CODE (lst) == TRUTH_ANDIF_EXPR
5204:           || TREE_CODE (lst) == TRUTH_ORIF_EXPR)
5205:         tag_shortcut_cond (lst, condition_uid);
5206:       else if (TREE_CODE (lst) == COND_EXPR)
5207:         tree_associate_condition_with_expr (lst, condition_uid);
5208:     }
5209: }
5210:
5211: /* Given a conditional expression EXPR with short-circuit boolean
5212:    predicates using TRUTH_ANDIF_EXPR or TRUTH_ORIF_EXPR, break the
5213:    predicate apart into the equivalent sequence of conditionals.  CONDITION_UID
5214:    is a the tag/discriminator for this EXPR - all basic conditions in the
5215:    expression will be given the same CONDITION_UID.  */
5216: static tree
5217: shortcut_cond_expr (tree expr, unsigned condition_uid)
5218: {
5219:   tree pred = TREE_OPERAND (expr, 0);
5220:   tree then_ = TREE_OPERAND (expr, 1);
5221:   tree else_ = TREE_OPERAND (expr, 2);
5222:   tree true_label, false_label, end_label, t;
5223:   tree *true_label_p;
5224:   tree *false_label_p;
5225:   bool emit_end, emit_false, jump_over_else;
5226:   bool then_se = then_ && TREE_SIDE_EFFECTS (then_);
5227:   bool else_se = else_ && TREE_SIDE_EFFECTS (else_);
5228:
5229:   tag_shortcut_cond (pred, condition_uid);
5230:
5231:   /* First do simple transformations.  */
5232:   if (!else_se)
5233:     {
5234:       /* If there is no 'else', turn
5235:            if (a && b) then c
5236:          into
5237:            if (a) if (b) then c.  */
5238:       while (TREE_CODE (pred) == TRUTH_ANDIF_EXPR)
5239:         {
5240:           /* Keep the original source location on the first 'if'.  */
5241:           location_t locus = EXPR_LOC_OR_LOC (expr, input_location);
5242:           TREE_OPERAND (expr, 0) = TREE_OPERAND (pred, 1);
5243:           /* Set the source location of the && on the second 'if'.  */
5244:           if (rexpr_has_location (pred))
5245:             SET_EXPR_LOCATION (expr, rexpr_location (pred));
5246:           then_ = shortcut_cond_expr (expr, condition_uid);
5247:           then_se = then_ && TREE_SIDE_EFFECTS (then_);
5248:           pred = TREE_OPERAND (pred, 0);
5249:           expr = build3 (COND_EXPR, void_type_node, pred, then_, NULL_TREE);
5250:           SET_EXPR_LOCATION (expr, locus);
5251:         }
5252:     }
5253:
5254:   if (!then_se)
5255:     {
5256:       /* If there is no 'then', turn
5257:            if (a || b); else d
5258:          into
5259:            if (a); else if (b); else d.  */
5260:       while (TREE_CODE (pred) == TRUTH_ORIF_EXPR)
5261:         {
5262:           /* Keep the original source location on the first 'if'.  */
5263:           location_t locus = EXPR_LOC_OR_LOC (expr, input_location);
5264:           TREE_OPERAND (expr, 0) = TREE_OPERAND (pred, 1);
5265:           /* Set the source location of the || on the second 'if'.  */
5266:           if (rexpr_has_location (pred))
5267:             SET_EXPR_LOCATION (expr, rexpr_location (pred));
5268:           else_ = shortcut_cond_expr (expr, condition_uid);
5269:           else_se = else_ && TREE_SIDE_EFFECTS (else_);
5270:           pred = TREE_OPERAND (pred, 0);
5271:           expr = build3 (COND_EXPR, void_type_node, pred, NULL_TREE, else_);
5272:           SET_EXPR_LOCATION (expr, locus);
5273:         }
5274:     }
5275:
5276:   /* The expr tree should also have the expression id set.  */
5277:   tree_associate_condition_with_expr (expr, condition_uid);
5278:
5279:   /* If we're done, great.  */
5280:   if (TREE_CODE (pred) != TRUTH_ANDIF_EXPR
5281:       && TREE_CODE (pred) != TRUTH_ORIF_EXPR)
5282:     return expr;
5283:
5284:   /* Otherwise we need to mess with gotos.  Change
5285:        if (a) c; else d;
5286:      to
5287:        if (a); else goto no;
5288:        c; goto end;
5289:        no: d; end:
5290:      and recursively gimplify the condition.  */
5291:
5292:   true_label = false_label = end_label = NULL_TREE;
5293:
5294:   /* If our arms just jump somewhere, hijack those labels so we don't
5295:      generate jumps to jumps.  */
5296:
5297:   if (tree then_goto = find_goto_label (then_))
5298:     {
5299:       true_label = GOTO_DESTINATION (then_goto);
5300:       then_ = NULL;
5301:       then_se = false;
5302:     }
5303:
5304:   if (tree else_goto = find_goto_label (else_))
5305:     {
5306:       false_label = GOTO_DESTINATION (else_goto);
5307:       else_ = NULL;
5308:       else_se = false;
5309:     }
5310:
5311:   /* If we aren't hijacking a label for the 'then' branch, it falls through.  */
5312:   if (true_label)
5313:     true_label_p = &true_label;
5314:   else
5315:     true_label_p = NULL;
5316:
5317:   /* The 'else' branch also needs a label if it contains interesting code.  */
5318:   if (false_label || else_se)
5319:     false_label_p = &false_label;
5320:   else
5321:     false_label_p = NULL;
5322:
5323:   /* If there was nothing else in our arms, just forward the label(s).  */
5324:   if (!then_se && !else_se)
5325:     return shortcut_cond_r (pred, true_label_p, false_label_p,
5326:                             EXPR_LOC_OR_LOC (expr, input_location), condition_uid);
5327:
5328:   /* If our last subexpression already has a terminal label, reuse it.  */
5329:   if (else_se)
5330:     t = expr_last (else_);
5331:   else if (then_se)
5332:     t = expr_last (then_);
5333:   else
5334:     t = NULL;
5335:   if (t && TREE_CODE (t) == LABEL_EXPR)
5336:     end_label = LABEL_EXPR_LABEL (t);
5337:
5338:   /* If we don't care about jumping to the 'else' branch, jump to the end
5339:      if the condition is false.  */
5340:   if (!false_label_p)
5341:     false_label_p = &end_label;
5342:
5343:   /* We only want to emit these labels if we aren't hijacking them.  */
5344:   emit_end = (end_label == NULL_TREE);
5345:   emit_false = (false_label == NULL_TREE);
5346:
5347:   /* We only emit the jump over the else clause if we have to--if the
5348:      then clause may fall through.  Otherwise we can wind up with a
5349:      useless jump and a useless label at the end of gimplified code,
5350:      which will cause us to think that this conditional as a whole
5351:      falls through even if it doesn't.  If we then inline a function
5352:      which ends with such a condition, that can cause us to issue an
5353:      inappropriate warning about control reaching the end of a
5354:      non-void function.  */
5355:   jump_over_else = block_may_fallthru (then_);
5356:
5357:   pred = shortcut_cond_r (pred, true_label_p, false_label_p,
5358:                           EXPR_LOC_OR_LOC (expr, input_location),
5359:                           condition_uid);
5360:
5361:   expr = NULL;
5362:   append_to_statement_list (pred, &expr);
5363:
5364:   append_to_statement_list (then_, &expr);
5365:   if (else_se)
5366:     {
5367:       if (jump_over_else)
5368:         {
5369:           tree last = expr_last (expr);
5370:           t = build_and_jump (&end_label);
5371:           if (rexpr_has_location (last))
5372:             SET_EXPR_LOCATION (t, rexpr_location (last));
5373:           append_to_statement_list (t, &expr);
5374:         }
5375:       if (emit_false)
5376:         {
5377:           t = build1 (LABEL_EXPR, void_type_node, false_label);
5378:           append_to_statement_list (t, &expr);
5379:         }
5380:       append_to_statement_list (else_, &expr);
5381:     }
5382:   if (emit_end && end_label)
5383:     {
5384:       t = build1 (LABEL_EXPR, void_type_node, end_label);
5385:       append_to_statement_list (t, &expr);
5386:     }
5387:
5388:   return expr;
5389: }
5390:
5391: /* EXPR is used in a boolean context; make sure it has BOOLEAN_TYPE.  */
5392:
5393: tree
5394: gimple_boolify (tree expr)
5395: {
5396:   tree type = TREE_TYPE (expr);
5397:   location_t loc = EXPR_LOCATION (expr);
5398:
5399:   if (TREE_CODE (expr) == NE_EXPR
5400:       && TREE_CODE (TREE_OPERAND (expr, 0)) == CALL_EXPR
5401:       && integer_zerop (TREE_OPERAND (expr, 1)))
5402:     {
5403:       tree call = TREE_OPERAND (expr, 0);
5404:       tree fn = get_callee_fndecl (call);
5405:
5406:       /* For __builtin_expect ((long) (x), y) recurse into x as well
5407:          if x is truth_value_p.  */
5408:       if (fn
5409:           && fndecl_built_in_p (fn, BUILT_IN_EXPECT)
5410:           && call_expr_nargs (call) == 2)
5411:         {
5412:           tree arg = CALL_EXPR_ARG (call, 0);
5413:           if (arg)
5414:             {
5415:               if (TREE_CODE (arg) == NOP_EXPR
5416:                   && TREE_TYPE (arg) == TREE_TYPE (call))
5417:                 arg = TREE_OPERAND (arg, 0);
5418:               if (truth_value_p (TREE_CODE (arg)))
5419:                 {
5420:                   arg = gimple_boolify (arg);
5421:                   CALL_EXPR_ARG (call, 0)
5422:                     = fold_convert_loc (loc, TREE_TYPE (call), arg);
5423:                 }
5424:             }
5425:         }
5426:     }
5427:
5428:   switch (TREE_CODE (expr))
5429:     {
5430:     case TRUTH_AND_EXPR:
5431:     case TRUTH_OR_EXPR:
5432:     case TRUTH_XOR_EXPR:
5433:     case TRUTH_ANDIF_EXPR:
5434:     case TRUTH_ORIF_EXPR:
5435:       /* Also boolify the arguments of truth exprs.  */
5436:       TREE_OPERAND (expr, 1) = gimple_boolify (TREE_OPERAND (expr, 1));
5437:       /* FALLTHRU */
5438:
5439:     case TRUTH_NOT_EXPR:
5440:       TREE_OPERAND (expr, 0) = gimple_boolify (TREE_OPERAND (expr, 0));
5441:
5442:       /* These expressions always produce boolean results.  */
5443:       if (TREE_CODE (type) != BOOLEAN_TYPE)
5444:         TREE_TYPE (expr) = boolean_type_node;
5445:       return expr;
5446:
5447:     case ANNOTATE_EXPR:
5448:       switch ((enum annot_expr_kind) TREE_INT_CST_LOW (TREE_OPERAND (expr, 1)))
5449:         {
5450:         case annot_expr_ivdep_kind:
5451:         case annot_expr_unroll_kind:
5452:         case annot_expr_no_vector_kind:
5453:         case annot_expr_vector_kind:
5454:         case annot_expr_parallel_kind:
5455:         case annot_expr_maybe_infinite_kind:
5456:           TREE_OPERAND (expr, 0) = gimple_boolify (TREE_OPERAND (expr, 0));
5457:           if (TREE_CODE (type) != BOOLEAN_TYPE)
5458:             TREE_TYPE (expr) = boolean_type_node;
5459:           return expr;
5460:         default:
5461:           gcc_unreachable ();
5462:         }
5463:
5464:     default:
5465:       if (COMPARISON_CLASS_P (expr))
5466:         {
5467:           /* These expressions always produce boolean results.  */
5468:           if (TREE_CODE (type) != BOOLEAN_TYPE)
5469:             TREE_TYPE (expr) = boolean_type_node;
5470:           return expr;
5471:         }
5472:       /* Other expressions that get here must have boolean values, but
5473:          might need to be converted to the appropriate mode.  */
5474:       if (TREE_CODE (type) == BOOLEAN_TYPE)
5475:         return expr;
5476:       return fold_convert_loc (loc, boolean_type_node, expr);
5477:     }
5478: }
5479:
5480: /* Given a conditional expression *EXPR_P without side effects, gimplify
5481:    its operands.  New statements are inserted to PRE_P.  */
5482:
5483: static enum gimplify_status
5484: gimplify_pure_cond_expr (tree *expr_p, gimple_seq *pre_p)
5485: {
5486:   tree expr = *expr_p, cond;
5487:   enum gimplify_status ret, tret;
5488:   enum tree_code code;
5489:
5490:   cond = gimple_boolify (COND_EXPR_COND (expr));
5491:
5492:   /* We need to handle && and || specially, as their gimplification
5493:      creates pure cond_expr, thus leading to an infinite cycle otherwise.  */
5494:   code = TREE_CODE (cond);
5495:   if (code == TRUTH_ANDIF_EXPR)
5496:     TREE_SET_CODE (cond, TRUTH_AND_EXPR);
5497:   else if (code == TRUTH_ORIF_EXPR)
5498:     TREE_SET_CODE (cond, TRUTH_OR_EXPR);
5499:   ret = gimplify_expr (&cond, pre_p, NULL, is_gimple_val, fb_rvalue);
5500:   COND_EXPR_COND (*expr_p) = cond;
5501:
5502:   tret = gimplify_expr (&COND_EXPR_THEN (expr), pre_p, NULL,
5503:                         is_gimple_val, fb_rvalue);
5504:   ret = MIN (ret, tret);
5505:   tret = gimplify_expr (&COND_EXPR_ELSE (expr), pre_p, NULL,
5506:                         is_gimple_val, fb_rvalue);
5507:
5508:   return MIN (ret, tret);
5509: }
5510:
5511: /* Return true if evaluating EXPR could trap.
5512:    EXPR is GENERIC, while tree_could_trap_p can be called
5513:    only on GIMPLE.  */
5514:
5515: bool
5516: generic_expr_could_trap_p (tree expr)
5517: {
5518:   unsigned i, n;
5519:
5520:   if (!expr || is_gimple_val (expr))
5521:     return false;
5522:
5523:   if (!EXPR_P (expr) || tree_could_trap_p (expr))
5524:     return true;
5525:
5526:   n = TREE_OPERAND_LENGTH (expr);
5527:   for (i = 0; i < n; i++)
5528:     if (generic_expr_could_trap_p (TREE_OPERAND (expr, i)))
5529:       return true;
5530:
5531:   return false;
5532: }
5533:
5534: /* Associate the condition STMT with the discriminator UID.  STMTs that are
5535:    broken down with ANDIF/ORIF from the same Boolean expression should be given
5536:    the same UID; 'if (a && b && c) { if (d || e) ... } ...' should yield the
5537:    { a: 1, b: 1, c: 1, d: 2, e: 2 } when gimplification is done.  This is used
5538:    for condition coverage.  */
5539: static void
5540: gimple_associate_condition_with_expr (struct function *fn, gcond *stmt,
5541:                                       unsigned uid)
5542: {
5543:   if (!condition_coverage_flag)
5544:     return;
5545:
5546:   if (!fn->cond_uids)
5547:     fn->cond_uids = new hash_map <gcond*, unsigned> ();
5548:
5549:   fn->cond_uids->put (stmt, uid);
5550: }
5551:
5552: /*  Convert the conditional expression pointed to by EXPR_P '(p) ? a : b;'
5553:     into
5554:
5555:     if (p)                      if (p)
5556:       t1 = a;                     a;
5557:     else                or      else
5558:       t1 = b;                     b;
5559:     t1;
5560:
5561:     The second form is used when *EXPR_P is of type void.
5562:
5563:     PRE_P points to the list where side effects that must happen before
5564:       *EXPR_P should be stored.  */
5565:
5566: static enum gimplify_status
5567: gimplify_cond_expr (tree *expr_p, gimple_seq *pre_p, fallback_t fallback)
5568: {
5569:   tree expr = *expr_p;
5570:   tree type = TREE_TYPE (expr);
5571:   location_t loc = EXPR_LOCATION (expr);
5572:   tree tmp, arm1, arm2;
5573:   enum gimplify_status ret;
5574:   tree label_true, label_false, label_cont;
5575:   bool have_then_clause_p, have_else_clause_p;
5576:   gcond *cond_stmt;
5577:   enum tree_code pred_code;
5578:   gimple_seq seq = NULL;
5579:
5580:   /* If this COND_EXPR has a value, copy the values into a temporary within
5581:      the arms.  */
5582:   if (!VOID_TYPE_P (type))
5583:     {
5584:       tree then_ = TREE_OPERAND (expr, 1), else_ = TREE_OPERAND (expr, 2);
5585:       tree result;
5586:
5587:       /* If either an rvalue is ok or we do not require an lvalue, create the
5588:          temporary.  But we cannot do that if the type is addressable.  */
5589:       if (((fallback & fb_rvalue) || !(fallback & fb_lvalue))
5590:           && !TREE_ADDRESSABLE (type))
5591:         {
5592:           if (gimplify_ctxp->allow_rhs_cond_expr
5593:               /* If either branch has side effects or could trap, it can't be
5594:                  evaluated unconditionally.  */
5595:               && !TREE_SIDE_EFFECTS (then_)
5596:               && !generic_expr_could_trap_p (then_)
5597:               && !TREE_SIDE_EFFECTS (else_)
5598:               && !generic_expr_could_trap_p (else_))
5599:             return gimplify_pure_cond_expr (expr_p, pre_p);
5600:
5601:           tmp = create_tmp_var (type, "iftmp");
5602:           result = tmp;
5603:         }
5604:
5605:       /* Otherwise, only create and copy references to the values.  */
5606:       else
5607:         {
5608:           type = build_pointer_type (type);
5609:
5610:           if (!VOID_TYPE_P (TREE_TYPE (then_)))
5611:             then_ = build_fold_addr_expr_loc (loc, then_);
5612:
5613:           if (!VOID_TYPE_P (TREE_TYPE (else_)))
5614:             else_ = build_fold_addr_expr_loc (loc, else_);
5615:
5616:           expr
5617:             = build3 (COND_EXPR, type, TREE_OPERAND (expr, 0), then_, else_);
5618:
5619:           tmp = create_tmp_var (type, "iftmp");
5620:           result = build_simple_mem_ref_loc (loc, tmp);
5621:         }
5622:
5623:       /* Build the new then clause, `tmp = then_;'.  But don't build the
5624:          assignment if the value is void; in C++ it can be if it's a throw.  */
5625:       if (!VOID_TYPE_P (TREE_TYPE (then_)))
5626:         TREE_OPERAND (expr, 1) = build2 (INIT_EXPR, type, tmp, then_);
5627:
5628:       /* Similarly, build the new else clause, `tmp = else_;'.  */
5629:       if (!VOID_TYPE_P (TREE_TYPE (else_)))
5630:         TREE_OPERAND (expr, 2) = build2 (INIT_EXPR, type, tmp, else_);
5631:
5632:       TREE_TYPE (expr) = void_type_node;
5633:       recalculate_side_effects (expr);
5634:
5635:       /* Move the COND_EXPR to the prequeue.  */
5636:       gimplify_stmt (&expr, pre_p);
5637:
5638:       *expr_p = result;
5639:       return GS_ALL_DONE;
5640:     }
5641:
5642:   /* Remove any COMPOUND_EXPR so the following cases will be caught.  */
5643:   STRIP_TYPE_NOPS (TREE_OPERAND (expr, 0));
5644:   if (TREE_CODE (TREE_OPERAND (expr, 0)) == COMPOUND_EXPR)
5645:     gimplify_compound_expr (&TREE_OPERAND (expr, 0), pre_p, true);
5646:
5647:   /* Make sure the condition has BOOLEAN_TYPE.  */
5648:   TREE_OPERAND (expr, 0) = gimple_boolify (TREE_OPERAND (expr, 0));
5649:
5650:   /* Break apart && and || conditions.  */
5651:   if (TREE_CODE (TREE_OPERAND (expr, 0)) == TRUTH_ANDIF_EXPR
5652:       || TREE_CODE (TREE_OPERAND (expr, 0)) == TRUTH_ORIF_EXPR)
5653:     {
5654:       expr = shortcut_cond_expr (expr, next_cond_uid ());
5655:
5656:       if (expr != *expr_p)
5657:         {
5658:           *expr_p = expr;
5659:
5660:           /* We can't rely on gimplify_expr to re-gimplify the expanded
5661:              form properly, as cleanups might cause the target labels to be
5662:              wrapped in a TRY_FINALLY_EXPR.  To prevent that, we need to
5663:              set up a conditional context.  */
5664:           gimple_push_condition ();
5665:           gimplify_stmt (expr_p, &seq);
5666:           gimple_pop_condition (pre_p);
5667:           gimple_seq_add_seq (pre_p, seq);
5668:
5669:           return GS_ALL_DONE;
5670:         }
5671:     }
5672:
5673:   /* Now do the normal gimplification.  */
5674:
5675:   /* Gimplify condition.  */
5676:   ret = gimplify_expr (&TREE_OPERAND (expr, 0), pre_p, NULL,
5677:                        is_gimple_condexpr_for_cond, fb_rvalue);
5678:   if (ret == GS_ERROR)
5679:     return GS_ERROR;
5680:   gcc_assert (TREE_OPERAND (expr, 0) != NULL_TREE);
5681:
5682:   gimple_push_condition ();
5683:
5684:   have_then_clause_p = have_else_clause_p = false;
5685:   label_true = find_goto_label (TREE_OPERAND (expr, 1));
5686:   if (label_true
5687:       && DECL_CONTEXT (GOTO_DESTINATION (label_true)) == current_function_decl
5688:       /* For -O0 avoid this optimization if the COND_EXPR and GOTO_EXPR
5689:          have different locations, otherwise we end up with incorrect
5690:          location information on the branches.  */
5691:       && (optimize
5692:           || !EXPR_HAS_LOCATION (expr)
5693:           || !rexpr_has_location (label_true)
5694:           || EXPR_LOCATION (expr) == rexpr_location (label_true)))
5695:     {
5696:       have_then_clause_p = true;
5697:       label_true = GOTO_DESTINATION (label_true);
5698:     }
5699:   else
5700:     label_true = create_artificial_label (UNKNOWN_LOCATION);
5701:   label_false = find_goto_label (TREE_OPERAND (expr, 2));
5702:   if (label_false
5703:       && DECL_CONTEXT (GOTO_DESTINATION (label_false)) == current_function_decl
5704:       /* For -O0 avoid this optimization if the COND_EXPR and GOTO_EXPR
5705:          have different locations, otherwise we end up with incorrect
5706:          location information on the branches.  */
5707:       && (optimize
5708:           || !EXPR_HAS_LOCATION (expr)
5709:           || !rexpr_has_location (label_false)
5710:           || EXPR_LOCATION (expr) == rexpr_location (label_false)))
5711:     {
5712:       have_else_clause_p = true;
5713:       label_false = GOTO_DESTINATION (label_false);
5714:     }
5715:   else
5716:     label_false = create_artificial_label (UNKNOWN_LOCATION);
5717:
5718:   unsigned cond_uid = 0;
5719:   if (cond_uids)
5720:     if (unsigned *v = cond_uids->get (expr))
5721:       cond_uid = *v;
5722:   if (cond_uid == 0)
5723:     cond_uid = next_cond_uid ();
5724:
5725:   gimple_cond_get_ops_from_tree (COND_EXPR_COND (expr), &pred_code, &arm1,
5726:                                  &arm2);
5727:   cond_stmt = gimple_build_cond (pred_code, arm1, arm2, label_true,
5728:                                  label_false);
5729:   gimple_set_location (cond_stmt, EXPR_LOCATION (expr));
5730:   gimple_associate_condition_with_expr (cfun, cond_stmt, cond_uid);
5731:   copy_warning (cond_stmt, COND_EXPR_COND (expr));
5732:   gimplify_seq_add_stmt (&seq, cond_stmt);
5733:   gimple_stmt_iterator gsi = gsi_last (seq);
5734:   maybe_fold_stmt (&gsi);
5735:
5736:   label_cont = NULL_TREE;
5737:   if (!have_then_clause_p)
5738:     {
5739:       /* For if (...) {} else { code; } put label_true after
5740:          the else block.  */
5741:       if (TREE_OPERAND (expr, 1) == NULL_TREE
5742:           && !have_else_clause_p
5743:           && TREE_OPERAND (expr, 2) != NULL_TREE)
5744:         {
5745:           /* For if (0) {} else { code; } tell -Wimplicit-fallthrough
5746:              handling that label_cont == label_true can be only reached
5747:              through fallthrough from { code; }.  */
5748:           if (integer_zerop (COND_EXPR_COND (expr)))
5749:             UNUSED_LABEL_P (label_true) = 1;
5750:           label_cont = label_true;
5751:         }
5752:       else
5753:         {
5754:           bool then_side_effects
5755:             = (TREE_OPERAND (expr, 1)
5756:                && TREE_SIDE_EFFECTS (TREE_OPERAND (expr, 1)));
5757:           gimplify_seq_add_stmt (&seq, gimple_build_label (label_true));
5758:           have_then_clause_p = gimplify_stmt (&TREE_OPERAND (expr, 1), &seq);
5759:           /* For if (...) { code; } else {} or
5760:              if (...) { code; } else goto label; or
5761:              if (...) { code; return; } else { ... }
5762:              label_cont isn't needed.  */
5763:           if (!have_else_clause_p
5764:               && TREE_OPERAND (expr, 2) != NULL_TREE
5765:               && gimple_seq_may_fallthru (seq))
5766:             {
5767:               gimple *g;
5768:               label_cont = create_artificial_label (UNKNOWN_LOCATION);
5769:
5770:               /* For if (0) { non-side-effect-code } else { code }
5771:                  tell -Wimplicit-fallthrough handling that label_cont can
5772:                  be only reached through fallthrough from { code }.  */
5773:               if (integer_zerop (COND_EXPR_COND (expr)))
5774:                 {
5775:                   UNUSED_LABEL_P (label_true) = 1;
5776:                   if (!then_side_effects)
5777:                     UNUSED_LABEL_P (label_cont) = 1;
5778:                 }
5779:
5780:               g = gimple_build_goto (label_cont);
5781:
5782:               /* GIMPLE_COND's are very low level; they have embedded
5783:                  gotos.  This particular embedded goto should not be marked
5784:                  with the location of the original COND_EXPR, as it would
5785:                  correspond to the COND_EXPR's condition, not the ELSE or the
5786:                  THEN arms.  To avoid marking it with the wrong location, flag
5787:                  it as "no location".  */
5788:               gimple_set_do_not_emit_location (g);
5789:
5790:               gimplify_seq_add_stmt (&seq, g);
5791:             }
5792:         }
5793:     }
5794:   if (!have_else_clause_p)
5795:     {
5796:       /* For if (1) { code } or if (1) { code } else { non-side-effect-code }
5797:          tell -Wimplicit-fallthrough handling that label_false can be only
5798:          reached through fallthrough from { code }.  */
5799:       if (integer_nonzerop (COND_EXPR_COND (expr))
5800:           && (TREE_OPERAND (expr, 2) == NULL_TREE
5801:               || !TREE_SIDE_EFFECTS (TREE_OPERAND (expr, 2))))
5802:         UNUSED_LABEL_P (label_false) = 1;
5803:       gimplify_seq_add_stmt (&seq, gimple_build_label (label_false));
5804:       have_else_clause_p = gimplify_stmt (&TREE_OPERAND (expr, 2), &seq);
5805:     }
5806:   if (label_cont)
5807:     gimplify_seq_add_stmt (&seq, gimple_build_label (label_cont));
5808:
5809:   gimple_pop_condition (pre_p);
```

## gcc/gimplify.cc:6288–6307

```text
6288: /* Return the appropriate RHS predicate for this LHS.  */
6289:
6290: gimple_predicate
6291: rhs_predicate_for (tree lhs)
6292: {
6293:   if (is_gimple_reg (lhs))
6294:     return is_gimple_reg_rhs_or_call;
6295:   else
6296:     return is_gimple_mem_rhs_or_call;
6297: }
6298:
6299: /* Return the initial guess for an appropriate RHS predicate for this LHS,
6300:    before the LHS has been gimplified.  */
6301:
6302: static gimple_predicate
6303: initial_rhs_predicate_for (tree lhs)
6304: {
6305:   if (is_gimple_reg_type (TREE_TYPE (lhs)))
6306:     return is_gimple_reg_rhs_or_call;
6307:   else
```

## gcc/gimplify.cc:7002–7048

```text
7002:                                            false);
7003:           return ret;
7004:
7005:         case COND_EXPR:
7006:           /* If we're assigning to a non-register type, push the assignment
7007:              down into the branches.  This is mandatory for ADDRESSABLE types,
7008:              since we cannot generate temporaries for such, but it saves a
7009:              copy in other cases as well.
7010:              Also avoid an extra temporary and copy when assigning to
7011:              a register.  */
7012:           if (!is_gimple_reg_type (TREE_TYPE (*from_p))
7013:               || (is_gimple_reg (*to_p) && !gimplify_ctxp->allow_rhs_cond_expr))
7014:             {
7015:               /* This code should mirror the code in gimplify_cond_expr. */
7016:               enum tree_code code = TREE_CODE (*expr_p);
7017:               tree cond = *from_p;
7018:               tree result = *to_p;
7019:
7020:               ret = gimplify_expr (&result, pre_p, post_p,
7021:                                    is_gimple_lvalue, fb_lvalue);
7022:               if (ret != GS_ERROR)
7023:                 ret = GS_OK;
7024:
7025:               /* If we are going to write RESULT more than once, clear
7026:                  TREE_READONLY flag, otherwise we might incorrectly promote
7027:                  the variable to static const and initialize it at compile
7028:                  time in one of the branches.  */
7029:               if (VAR_P (result)
7030:                   && TREE_TYPE (TREE_OPERAND (cond, 1)) != void_type_node
7031:                   && TREE_TYPE (TREE_OPERAND (cond, 2)) != void_type_node)
7032:                 TREE_READONLY (result) = 0;
7033:               if (TREE_TYPE (TREE_OPERAND (cond, 1)) != void_type_node)
7034:                 TREE_OPERAND (cond, 1)
7035:                   = build2 (code, void_type_node, result,
7036:                             TREE_OPERAND (cond, 1));
7037:               if (TREE_TYPE (TREE_OPERAND (cond, 2)) != void_type_node)
7038:                 TREE_OPERAND (cond, 2)
7039:                   = build2 (code, void_type_node, unshare_expr (result),
7040:                             TREE_OPERAND (cond, 2));
7041:
7042:               TREE_TYPE (cond) = void_type_node;
7043:               recalculate_side_effects (cond);
7044:
7045:               if (want_value)
7046:                 {
7047:                   gimplify_and_add (cond, pre_p);
7048:                   *expr_p = unshare_expr (result);
```

## gcc/gimplify.cc:7430–7470

```text
7430:      Instead, we need to create the tuple GIMPLE_CALL <a, foo>.  To
7431:      prevent gimplify_expr from trying to create a new temporary for
7432:      foo's LHS, we tell it that it should only gimplify until it
7433:      reaches the CALL_EXPR.  On return from gimplify_expr, the newly
7434:      created GIMPLE_CALL <foo> will be the last statement in *PRE_P
7435:      and all we need to do here is set 'a' to be its LHS.  */
7436:
7437:   /* Gimplify the RHS first for C++17 and bug 71104.  */
7438:   gimple_predicate initial_pred = initial_rhs_predicate_for (*to_p);
7439:   ret = gimplify_expr (from_p, pre_p, post_p, initial_pred, fb_rvalue);
7440:   if (ret == GS_ERROR)
7441:     return ret;
7442:
7443:   /* Then gimplify the LHS.  */
7444:   /* If we gimplified the RHS to a CALL_EXPR and that call may return
7445:      twice we have to make sure to gimplify into non-SSA as otherwise
7446:      the abnormal edge added later will make those defs not dominate
7447:      their uses.
7448:      ???  Technically this applies only to the registers used in the
7449:      resulting non-register *TO_P.  */
7450:   bool saved_into_ssa = gimplify_ctxp->into_ssa;
7451:   if (saved_into_ssa
7452:       && TREE_CODE (*from_p) == CALL_EXPR
7453:       && call_expr_flags (*from_p) & ECF_RETURNS_TWICE)
7454:     gimplify_ctxp->into_ssa = false;
7455:   ret = gimplify_expr (to_p, pre_p, post_p, is_gimple_lvalue, fb_lvalue);
7456:   gimplify_ctxp->into_ssa = saved_into_ssa;
7457:   if (ret == GS_ERROR)
7458:     return ret;
7459:
7460:   /* Now that the LHS is gimplified, re-gimplify the RHS if our initial
7461:      guess for the predicate was wrong.  */
7462:   gimple_predicate final_pred = rhs_predicate_for (*to_p);
7463:   if (final_pred != initial_pred)
7464:     {
7465:       ret = gimplify_expr (from_p, pre_p, post_p, final_pred, fb_rvalue);
7466:       if (ret == GS_ERROR)
7467:         return ret;
7468:     }
7469:
7470:   /* In case of va_arg internal fn wrappped in a WITH_SIZE_EXPR, add the type
```

## gcc/gimplify.cc:7599–7625

```text
7599:   else
7600:     {
7601:       assign = gimple_build_assign (*to_p, *from_p);
7602:       gimple_set_location (assign, EXPR_LOCATION (*expr_p));
7603:       if (COMPARISON_CLASS_P (*from_p))
7604:         copy_warning (assign, *from_p);
7605:     }
7606:
7607:   if (gimplify_ctxp->into_ssa && is_gimple_reg (*to_p))
7608:     {
7609:       /* We should have got an SSA name from the start.  */
7610:       gcc_assert (TREE_CODE (*to_p) == SSA_NAME
7611:                   || ! gimple_in_ssa_p (cfun));
7612:     }
7613:
7614:   gimplify_seq_add_stmt (pre_p, assign);
7615:   gsi = gsi_last (*pre_p);
7616:   maybe_fold_stmt (&gsi);
7617:
7618:   if (want_value)
7619:     {
7620:       *expr_p = TREE_THIS_VOLATILE (*to_p) ? *from_p : unshare_expr (*to_p);
7621:       return GS_OK;
7622:     }
7623:   else
7624:     *expr_p = NULL;
7625:
```

## gcc/gimplify.cc:7723–7799

```text
7723:    WANT_VALUE is true when the result of the last COMPOUND_EXPR is used.  */
7724:
7725: static enum gimplify_status
7726: gimplify_compound_expr (tree *expr_p, gimple_seq *pre_p, bool want_value)
7727: {
7728:   tree t = *expr_p;
7729:
7730:   do
7731:     {
7732:       tree *sub_p = &TREE_OPERAND (t, 0);
7733:
7734:       if (TREE_CODE (*sub_p) == COMPOUND_EXPR)
7735:         gimplify_compound_expr (sub_p, pre_p, false);
7736:       else
7737:         gimplify_stmt (sub_p, pre_p);
7738:
7739:       t = TREE_OPERAND (t, 1);
7740:     }
7741:   while (TREE_CODE (t) == COMPOUND_EXPR);
7742:
7743:   *expr_p = t;
7744:   if (want_value)
7745:     return GS_OK;
7746:   else
7747:     {
7748:       gimplify_stmt (expr_p, pre_p);
7749:       return GS_ALL_DONE;
7750:     }
7751: }
7752:
7753: /* Gimplify a SAVE_EXPR node.  EXPR_P points to the expression to
7754:    gimplify.  After gimplification, EXPR_P will point to a new temporary
7755:    that holds the original value of the SAVE_EXPR node.
7756:
7757:    PRE_P points to the list where side effects that must happen before
7758:    *EXPR_P should be stored.  */
7759:
7760: static enum gimplify_status
7761: gimplify_save_expr (tree *expr_p, gimple_seq *pre_p, gimple_seq *post_p)
7762: {
7763:   enum gimplify_status ret = GS_ALL_DONE;
7764:   tree val;
7765:
7766:   gcc_assert (TREE_CODE (*expr_p) == SAVE_EXPR);
7767:   val = TREE_OPERAND (*expr_p, 0);
7768:
7769:   if (val && TREE_TYPE (val) == error_mark_node)
7770:     return GS_ERROR;
7771:
7772:   /* If the SAVE_EXPR has not been resolved, then evaluate it once.  */
7773:   if (!SAVE_EXPR_RESOLVED_P (*expr_p))
7774:     {
7775:       /* The operand may be a void-valued expression.  It is
7776:          being executed only for its side-effects.  */
7777:       if (TREE_TYPE (val) == void_type_node)
7778:         {
7779:           ret = gimplify_expr (&TREE_OPERAND (*expr_p, 0), pre_p, post_p,
7780:                                is_gimple_stmt, fb_none);
7781:           val = NULL;
7782:         }
7783:       else
7784:         /* The temporary may not be an SSA name as later abnormal and EH
7785:            control flow may invalidate use/def domination.  When in SSA
7786:            form then assume there are no such issues and SAVE_EXPRs only
7787:            appear via GENERIC foldings.  */
7788:         val = get_initialized_tmp_var (val, pre_p, post_p,
7789:                                        gimple_in_ssa_p (cfun));
7790:
7791:       TREE_OPERAND (*expr_p, 0) = val;
7792:       SAVE_EXPR_RESOLVED_P (*expr_p) = 1;
7793:     }
7794:
7795:   *expr_p = val;
7796:
7797:   return ret;
7798: }
7799:
```

## gcc/gimplify.cc:19462–19467

```text
19462:           gimplify_and_add (t, pre_p);
19463:           rhs = tmp_store;
19464:         }
19465:       bool save_allow_rhs_cond_expr = gimplify_ctxp->allow_rhs_cond_expr;
19466:       if (TREE_CODE (rhs) == COND_EXPR)
19467:         gimplify_ctxp->allow_rhs_cond_expr = true;
```

## gcc/gimplify.cc:20483–20500

```text
20483:                                       fallback != fb_none);
20484:           break;
20485:
20486:         case TRUTH_ANDIF_EXPR:
20487:         case TRUTH_ORIF_EXPR:
20488:           {
20489:             /* Preserve the original type of the expression and the
20490:                source location of the outer expression.  */
20491:             tree org_type = TREE_TYPE (*expr_p);
20492:             *expr_p = gimple_boolify (*expr_p);
20493:             *expr_p = build3_loc (input_location, COND_EXPR,
20494:                                   org_type, *expr_p,
20495:                                   fold_convert_loc
20496:                                     (input_location,
20497:                                      org_type, boolean_true_node),
20498:                                   fold_convert_loc
20499:                                     (input_location,
20500:                                      org_type, boolean_false_node));
```

## gcc/gimplify.cc:21295–21348

```text
21295:             /* If *EXPR_P does not need to be special-cased, handle it
21296:                according to its class.  */
21297:             case tcc_unary:
21298:               ret = gimplify_expr (&TREE_OPERAND (*expr_p, 0), pre_p,
21299:                                    post_p, is_gimple_val, fb_rvalue);
21300:               break;
21301:
21302:             case tcc_binary:
21303:             expr_2:
21304:               {
21305:                 enum gimplify_status r0, r1;
21306:
21307:                 r0 = gimplify_expr (&TREE_OPERAND (*expr_p, 0), pre_p,
21308:                                     post_p, is_gimple_val, fb_rvalue);
21309:                 r1 = gimplify_expr (&TREE_OPERAND (*expr_p, 1), pre_p,
21310:                                     post_p, is_gimple_val, fb_rvalue);
21311:
21312:                 ret = MIN (r0, r1);
21313:                 break;
21314:               }
21315:
21316:             expr_3:
21317:               {
21318:                 enum gimplify_status r0, r1, r2;
21319:
21320:                 r0 = gimplify_expr (&TREE_OPERAND (*expr_p, 0), pre_p,
21321:                                     post_p, is_gimple_val, fb_rvalue);
21322:                 r1 = gimplify_expr (&TREE_OPERAND (*expr_p, 1), pre_p,
21323:                                     post_p, is_gimple_val, fb_rvalue);
21324:                 r2 = gimplify_expr (&TREE_OPERAND (*expr_p, 2), pre_p,
21325:                                     post_p, is_gimple_val, fb_rvalue);
21326:
21327:                 ret = MIN (MIN (r0, r1), r2);
21328:                 break;
21329:               }
21330:
21331:             case tcc_declaration:
21332:             case tcc_constant:
21333:               ret = GS_ALL_DONE;
21334:               goto dont_recalculate;
21335:
21336:             default:
21337:               gcc_unreachable ();
21338:             }
21339:
21340:           recalculate_side_effects (*expr_p);
21341:
21342:         dont_recalculate:
21343:           break;
21344:         }
21345:
21346:       gcc_assert (*expr_p || ret != GS_OK);
21347:     }
21348:   while (ret == GS_OK);
```

## gcc/gimplify.cc:21502–21558

```text
21502:                   && code != OMP_SCOPE
21503:                   && code != OMP_DISPATCH);
21504:     }
21505: #endif
21506:
21507:   /* Otherwise we're gimplifying a subexpression, so the resulting
21508:      value is interesting.  If it's a valid operand that matches
21509:      GIMPLE_TEST_F, we're done. Unless we are handling some
21510:      post-effects internally; if that's the case, we need to copy into
21511:      a temporary before adding the post-effects to POST_P.  */
21512:   if (gimple_seq_empty_p (internal_post) && (*gimple_test_f) (*expr_p))
21513:     goto out;
21514:
21515:   /* Otherwise, we need to create a new temporary for the gimplified
21516:      expression.  */
21517:
21518:   /* We can't return an lvalue if we have an internal postqueue.  The
21519:      object the lvalue refers to would (probably) be modified by the
21520:      postqueue; we need to copy the value out first, which means an
21521:      rvalue.  */
21522:   if ((fallback & fb_lvalue)
21523:       && gimple_seq_empty_p (internal_post)
21524:       && is_gimple_addressable (*expr_p))
21525:     {
21526:       /* An lvalue will do.  Take the address of the expression, store it
21527:          in a temporary, and replace the expression with an INDIRECT_REF of
21528:          that temporary.  */
21529:       tree ref_alias_type = reference_alias_ptr_type (*expr_p);
21530:       unsigned int ref_align = get_object_alignment (*expr_p);
21531:       tree ref_type = TREE_TYPE (*expr_p);
21532:       tmp = build_fold_addr_expr_loc (input_location, *expr_p);
21533:       gimplify_expr (&tmp, pre_p, post_p, is_gimple_reg, fb_rvalue);
21534:       if (TYPE_ALIGN (ref_type) != ref_align)
21535:         ref_type = build_aligned_type (ref_type, ref_align);
21536:       *expr_p = build2 (MEM_REF, ref_type,
21537:                         tmp, build_zero_cst (ref_alias_type));
21538:     }
21539:   else if ((fallback & fb_rvalue) && is_gimple_reg_rhs_or_call (*expr_p))
21540:     {
21541:       /* An rvalue will do.  Assign the gimplified expression into a
21542:          new temporary TMP and replace the original expression with
21543:          TMP.  First, make sure that the expression has a type so that
21544:          it can be assigned into a temporary.  */
21545:       gcc_assert (!VOID_TYPE_P (TREE_TYPE (*expr_p)));
21546:       *expr_p = get_formal_tmp_var (*expr_p, pre_p);
21547:     }
21548:   else
21549:     {
21550: #ifdef ENABLE_GIMPLE_CHECKING
21551:       if (!(fallback & fb_mayfail))
21552:         {
21553:           fprintf (stderr, "gimplification failed:\n");
21554:           print_generic_expr (stderr, *expr_p);
21555:           debug_tree (*expr_p);
21556:           internal_error ("gimplification failed");
21557:         }
21558: #endif
```

## gcc/gimplify.cc:21584–21761

```text
21584:    evaluating *EXPR_P may be still SSA names.  */
21585:
21586: static enum gimplify_status
21587: gimplify_expr (tree *expr_p, gimple_seq *pre_p, gimple_seq *post_p,
21588:                bool (*gimple_test_f) (tree), fallback_t fallback,
21589:                bool allow_ssa)
21590: {
21591:   enum gimplify_status ret = gimplify_expr (expr_p, pre_p, post_p,
21592:                                             gimple_test_f, fallback);
21593:   if (! allow_ssa
21594:       && TREE_CODE (*expr_p) == SSA_NAME)
21595:     *expr_p = get_initialized_tmp_var (*expr_p, pre_p, NULL, false);
21596:   return ret;
21597: }
21598:
21599: /* Look through TYPE for variable-sized objects and gimplify each such
21600:    size that we find.  Add to LIST_P any statements generated.  */
21601:
21602: void
21603: gimplify_type_sizes (tree type, gimple_seq *list_p)
21604: {
21605:   if (type == NULL || type == error_mark_node)
21606:     return;
21607:
21608:   const bool ignored_p
21609:     = TYPE_NAME (type)
21610:       && TREE_CODE (TYPE_NAME (type)) == TYPE_DECL
21611:       && DECL_IGNORED_P (TYPE_NAME (type));
21612:   tree t;
21613:
21614:   /* We first do the main variant, then copy into any other variants.  */
21615:   type = TYPE_MAIN_VARIANT (type);
21616:
21617:   /* Avoid infinite recursion.  */
21618:   if (TYPE_SIZES_GIMPLIFIED (type))
21619:     return;
21620:
21621:   TYPE_SIZES_GIMPLIFIED (type) = 1;
21622:
21623:   switch (TREE_CODE (type))
21624:     {
21625:     case INTEGER_TYPE:
21626:     case ENUMERAL_TYPE:
21627:     case BOOLEAN_TYPE:
21628:     case REAL_TYPE:
21629:     case FIXED_POINT_TYPE:
21630:       gimplify_one_sizepos (&TYPE_MIN_VALUE (type), list_p);
21631:       gimplify_one_sizepos (&TYPE_MAX_VALUE (type), list_p);
21632:
21633:       for (t = TYPE_NEXT_VARIANT (type); t; t = TYPE_NEXT_VARIANT (t))
21634:         {
21635:           TYPE_MIN_VALUE (t) = TYPE_MIN_VALUE (type);
21636:           TYPE_MAX_VALUE (t) = TYPE_MAX_VALUE (type);
21637:         }
21638:       break;
21639:
21640:     case ARRAY_TYPE:
21641:       /* These types may not have declarations, so handle them here.  */
21642:       gimplify_type_sizes (TREE_TYPE (type), list_p);
21643:       gimplify_type_sizes (TYPE_DOMAIN (type), list_p);
21644:       /* Ensure VLA bounds aren't removed, for -O0 they should be variables
21645:          with assigned stack slots, for -O1+ -g they should be tracked
21646:          by VTA.  */
21647:       if (!ignored_p
21648:           && TYPE_DOMAIN (type)
21649:           && INTEGRAL_TYPE_P (TYPE_DOMAIN (type)))
21650:         {
21651:           t = TYPE_MIN_VALUE (TYPE_DOMAIN (type));
21652:           if (t && VAR_P (t) && DECL_ARTIFICIAL (t))
21653:             DECL_IGNORED_P (t) = 0;
21654:           t = TYPE_MAX_VALUE (TYPE_DOMAIN (type));
21655:           if (t && VAR_P (t) && DECL_ARTIFICIAL (t))
21656:             DECL_IGNORED_P (t) = 0;
21657:         }
21658:       break;
21659:
21660:     case RECORD_TYPE:
21661:     case UNION_TYPE:
21662:     case QUAL_UNION_TYPE:
21663:       for (tree field = TYPE_FIELDS (type); field; field = DECL_CHAIN (field))
21664:         if (TREE_CODE (field) == FIELD_DECL)
21665:           {
21666:             gimplify_one_sizepos (&DECL_FIELD_OFFSET (field), list_p);
21667:             /* Likewise, ensure variable offsets aren't removed.  */
21668:             if (!ignored_p
21669:                 && (t = DECL_FIELD_OFFSET (field))
21670:                 && VAR_P (t)
21671:                 && DECL_ARTIFICIAL (t))
21672:               DECL_IGNORED_P (t) = 0;
21673:             gimplify_one_sizepos (&DECL_SIZE (field), list_p);
21674:             gimplify_one_sizepos (&DECL_SIZE_UNIT (field), list_p);
21675:             gimplify_type_sizes (TREE_TYPE (field), list_p);
21676:           }
21677:       break;
21678:
21679:     case POINTER_TYPE:
21680:     case REFERENCE_TYPE:
21681:         /* We used to recurse on the pointed-to type here, which turned out to
21682:            be incorrect because its definition might refer to variables not
21683:            yet initialized at this point if a forward declaration is involved.
21684:
21685:            It was actually useful for anonymous pointed-to types to ensure
21686:            that the sizes evaluation dominates every possible later use of the
21687:            values.  Restricting to such types here would be safe since there
21688:            is no possible forward declaration around, but would introduce an
21689:            undesirable middle-end semantic to anonymity.  We then defer to
21690:            front-ends the responsibility of ensuring that the sizes are
21691:            evaluated both early and late enough, e.g. by attaching artificial
21692:            type declarations to the tree.  */
21693:       break;
21694:
21695:     default:
21696:       break;
21697:     }
21698:
21699:   gimplify_one_sizepos (&TYPE_SIZE (type), list_p);
21700:   gimplify_one_sizepos (&TYPE_SIZE_UNIT (type), list_p);
21701:
21702:   for (t = TYPE_NEXT_VARIANT (type); t; t = TYPE_NEXT_VARIANT (t))
21703:     {
21704:       TYPE_SIZE (t) = TYPE_SIZE (type);
21705:       TYPE_SIZE_UNIT (t) = TYPE_SIZE_UNIT (type);
21706:       TYPE_SIZES_GIMPLIFIED (t) = 1;
21707:     }
21708: }
21709:
21710: /* A subroutine of gimplify_type_sizes to make sure that *EXPR_P,
21711:    a size or position, has had all of its SAVE_EXPRs evaluated.
21712:    We add any required statements to *STMT_P.  */
21713:
21714: void
21715: gimplify_one_sizepos (tree *expr_p, gimple_seq *stmt_p)
21716: {
21717:   tree expr = *expr_p;
21718:
21719:   /* We don't do anything if the value isn't there, is constant, or contains
21720:      A PLACEHOLDER_EXPR.  We also don't want to do anything if it's already
21721:      a VAR_DECL.  If it's a VAR_DECL from another function, the gimplifier
21722:      will want to replace it with a new variable, but that will cause problems
21723:      if this type is from outside the function.  It's OK to have that here.  */
21724:   if (expr == NULL_TREE
21725:       || is_gimple_constant (expr)
21726:       || VAR_P (expr)
21727:       || CONTAINS_PLACEHOLDER_P (expr))
21728:     return;
21729:
21730:   *expr_p = unshare_expr (expr);
21731:
21732:   /* SSA names in decl/type fields are a bad idea - they'll get reclaimed
21733:      if the def vanishes.  */
21734:   gimplify_expr (expr_p, stmt_p, NULL, is_gimple_val, fb_rvalue, false);
21735:
21736:   /* If expr wasn't already is_gimple_sizepos or is_gimple_constant from the
21737:      FE, ensure that it is a VAR_DECL, otherwise we might handle some decls
21738:      as gimplify_vla_decl even when they would have all sizes INTEGER_CSTs.  */
21739:   if (is_gimple_constant (*expr_p))
21740:     *expr_p = get_initialized_tmp_var (*expr_p, stmt_p, NULL, false);
21741: }
21742:
21743: /* Gimplify the body of statements of FNDECL and return a GIMPLE_BIND node
21744:    containing the sequence of corresponding GIMPLE statements.  If DO_PARMS
21745:    is true, also gimplify the parameters.  */
21746:
21747: gbind *
21748: gimplify_body (tree fndecl, bool do_parms)
21749: {
21750:   location_t saved_location = input_location;
21751:   gimple_seq parm_stmts, parm_cleanup = NULL, seq;
21752:   gimple *outer_stmt;
21753:   gbind *outer_bind;
21754:
21755:   timevar_push (TV_TREE_GIMPLIFY);
21756:
21757:   init_tree_ssa (cfun);
21758:
21759:   /* Initialize for optimize_insn_for_s{ize,peed}_p possibly called during
21760:      gimplification.  */
21761:   default_rtl_profile ();
```

## gcc/gimplify.h:53–54

```text
53: extern void push_gimplify_context (bool in_ssa = false,
54:                                    bool rhs_cond_ok = false);
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

## gcc/tree-inline.cc:6667–6720

```text
6667: tree
6668: maybe_inline_call_in_expr (tree exp)
6669: {
6670:   tree fn = get_callee_fndecl (exp);
6671:
6672:   /* We can only try to inline "const" functions.  */
6673:   if (fn && TREE_READONLY (fn) && DECL_SAVED_TREE (fn))
6674:     {
6675:       call_expr_arg_iterator iter;
6676:       copy_body_data id;
6677:       tree param, arg, t;
6678:       hash_map<tree, tree> decl_map;
6679:
6680:       /* Remap the parameters.  */
6681:       for (param = DECL_ARGUMENTS (fn), arg = first_call_expr_arg (exp, &iter);
6682:            param;
6683:            param = DECL_CHAIN (param), arg = next_call_expr_arg (&iter))
6684:         decl_map.put (param, arg);
6685:
6686:       memset (&id, 0, sizeof (id));
6687:       id.src_fn = fn;
6688:       id.dst_fn = current_function_decl;
6689:       id.src_cfun = DECL_STRUCT_FUNCTION (fn);
6690:       id.decl_map = &decl_map;
6691:
6692:       id.copy_decl = copy_decl_no_change;
6693:       id.transform_call_graph_edges = CB_CGE_DUPLICATE;
6694:       id.transform_new_cfg = false;
6695:       id.transform_return_to_modify = true;
6696:       id.transform_parameter = true;
6697:
6698:       /* Make sure not to unshare trees behind the front-end's back
6699:          since front-end specific mechanisms may rely on sharing.  */
6700:       id.regimplify = false;
6701:       id.do_not_unshare = true;
6702:
6703:       /* We're not inside any EH region.  */
6704:       id.eh_lp_nr = 0;
6705:
6706:       t = copy_tree_body (&id);
6707:
6708:       /* We can only return something suitable for use in a GENERIC
6709:          expression tree.  */
6710:       if (TREE_CODE (t) == MODIFY_EXPR)
6711:         return TREE_OPERAND (t, 1);
6712:     }
6713:
6714:    return NULL_TREE;
6715: }
6716:
6717: /* Duplicate a type, fields and all.  */
6718:
6719: tree
6720: build_duplicate_type (tree type)
```

## src/silver_arguments.ads (selected Silver API, complete)

```text
1: with Ada.Text_IO;
2: with Silver_IO;
3:
4: package Silver_Arguments with SPARK_Mode => On is
5:    --  Both queries observe the immutable GNAT argument vector. An absent
6:    --  argument selects Default; one valid argument preserves its exact bytes,
7:    --  including the empty String. Invalid input is handled by the caller's
8:    --  required validity guard and Reject branch, never printed as a fallback.
9:    function Input_Is_Valid return Boolean with Global => null;
10:
11:    --  Return canonical one-based bounds while preserving the selected bytes.
12:    --  This also applies to shifted and null-range Default values.
13:    function First_Or_Default (Default : String) return String
14:      with Global => null,
15:           Post => First_Or_Default'Result'First = 1
16:             and then First_Or_Default'Result'Length <= Silver_IO.Max_Length
17:             and then (Input_Is_Valid or else First_Or_Default'Result'Length = 0)
18:             and then (for all Ch of First_Or_Default'Result =>
19:               Character'Pos (Ch) in 32 .. 126);
20:
21:    procedure Reject
22:      with Global => (In_Out => Ada.Text_IO.File_System), Always_Terminates;
23: end Silver_Arguments;
```

## src/silver_io.ads (selected Silver API, complete)

```text
1: with Ada.Text_IO;
2: package Silver_IO with SPARK_Mode => On is
3:    --  Application membership restricts literals separately. The executable
4:    --  guard makes this implementation safe for every String argument.
5:    Max_Length : constant Positive := 4_096;
6:    --  Static observations record bytes only after successful libc calls.
7:    --  GNAT erases this verification state and its assertions from execution.
8:    Written_Bytes : String (1 .. Max_Length + 1) := (others => Character'Val (0))
9:      with Ghost => Static;
10:    Written_Count : Natural range 0 .. Max_Length + 1 := 0 with Ghost => Static;
11:    Flushed : Boolean := False with Ghost => Static;
12:    Succeeded : Boolean := False with Ghost => Static;
13:    --  Succeeded records acceptance of every input byte and LF followed by a
14:    --  successful fflush(NULL). On detected failure, set process exit status 1
15:    --  and return normally with Succeeded False. The admitted Main then returns
16:    --  with that status. Success leaves the startup success status unchanged.
17:    --  Environmental blocking is modeled by Always_Terminates => False.
18:    procedure Put_Line (Item : String)
19:      with Global => (In_Out => Ada.Text_IO.File_System,
20:                      Output => (Written_Bytes, Written_Count, Flushed, Succeeded)),
21:           Always_Terminates => False,
22:           Post => (Static => Succeeded = Flushed
23:             and then (if Succeeded then Item'Length <= Max_Length
24:               and then Written_Count = Item'Length + 1
25:               and then Written_Bytes (1 .. Item'Length) = Item
26:               and then Written_Bytes (Written_Count) = Character'Val (10)));
27:    --  Put has the same completion/failure behavior without appending LF.
28:    --  Even an empty Item requests a flush; later success never clears failure.
29:    procedure Put (Item : String)
30:      with Global => (In_Out => Ada.Text_IO.File_System,
31:                      Output => (Written_Bytes, Written_Count, Flushed, Succeeded)),
32:           Always_Terminates => False,
33:           Post => (Static => Succeeded = Flushed
34:             and then (if Succeeded then Item'Length <= Max_Length
35:               and then Written_Count = Item'Length
36:               and then Written_Bytes (1 .. Item'Length) = Item));
37: end Silver_IO;
```
