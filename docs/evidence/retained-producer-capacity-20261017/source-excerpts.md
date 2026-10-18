## src/flow/flow_generated_globals-phase_2.adb:4793-4875

```ada
  4793:    function Expand_Abstract_State (F : Flow_Id) return Flow_Id_Sets.Set is
  4794:    begin
  4795:       --  Abstract state is expanded as much as possible using refinement
  4796:       --  recorded in the ALI file.
  4797:
  4798:       if Is_Abstract_State (F) then
  4799:          declare
  4800:             State : constant Entity_Name :=
  4801:               (if F.Kind = Direct_Mapping
  4802:                then To_Entity_Name (F.Node)
  4803:                else F.Name);
  4804:
  4805:             Expanded : Flow_Id_Sets.Set;
  4806:
  4807:          begin
  4808:             if State_Comp_Map.Contains (State) then
  4809:                for C of State_Comp_Map (State) loop
  4810:                   Expanded.Union (Expand_Abstract_State (Get_Flow_Id (C)));
  4811:                end loop;
  4812:             elsif State_Part_Map.Contains (State) then
  4813:                for C of State_Part_Map (State) loop
  4814:                   Expanded.Union (Expand_Abstract_State (Get_Flow_Id (C)));
  4815:                end loop;
  4816:
  4817:                Expanded.Insert (Magic_String_Id (State));
  4818:             else
  4819:                --  Expand Part_Of constituents that are not known to "generated
  4820:                --  globals" machinery, e.g. because they appear in the (down
  4821:                --  projected) Pre/Post of subprograms from external units.
  4822:
  4823:                if F.Kind = Direct_Mapping then
  4824:                   for C of Iter (Part_Of_Constituents (F.Node)) loop
  4825:                      Expanded.Union
  4826:                        (Expand_Abstract_State (Direct_Mapping_Id (C)));
  4827:                   end loop;
  4828:                end if;
  4829:
  4830:                Expanded.Insert (Magic_String_Id (State));
  4831:             end if;
  4832:
  4833:             return Expanded;
  4834:          end;
  4835:
  4836:       --  Other objects are merely converted to the proof view convention
  4837:
  4838:       else
  4839:          case F.Kind is
  4840:             when Direct_Mapping =>
  4841:                declare
  4842:                   Aliases : Flow_Id_Sets.Set;
  4843:
  4844:                   E : constant Entity_Id := Get_Direct_Mapping_Id (F);
  4845:
  4846:                begin
  4847:                   --  Proof expects objects that are not in SPARK to be
  4848:                   --  represented as Magic_Strings. Deferred constants which
  4849:                   --  only have partial view in SPARK will be represented by
  4850:                   --  this partial view.
  4851:
  4852:                   Aliases.Insert
  4853:                     (if Entity_In_SPARK (E)
  4854:                      then Change_Variant (F, Normal_Use)
  4855:                      elsif Present (Partial_View (E))
  4856:                        and then Entity_In_SPARK (Partial_View (E))
  4857:                      then
  4858:                        Change_Variant
  4859:                          (Direct_Mapping_Id (Partial_View (E)), Normal_Use)
  4860:                      else Magic_String_Id (To_Entity_Name (E)));
  4861:
  4862:                   return Aliases;
  4863:                end;
  4864:
  4865:             when Magic_String   =>
  4866:                return Flow_Id_Sets.To_Set (Change_Variant (F, Normal_Use));
  4867:
  4868:             when Null_Value     =>
  4869:                return Flow_Id_Sets.Empty_Set;
  4870:
  4871:             when others         =>
  4872:                raise Program_Error;
  4873:          end case;
  4874:       end if;
  4875:    end Expand_Abstract_State;
```

## src/flow/flow_utility.adb:966-1000

```ada
   966:    function Expand_Abstract_States
   967:      (Vars : Flow_Id_Sets.Set) return Flow_Id_Sets.Set
   968:    is
   969:       Expanded : Flow_Id_Sets.Set;
   970:
   971:    begin
   972:       for Var of Vars loop
   973:          Expanded.Union (Expand_Abstract_State (Var));
   974:       end loop;
   975:
   976:       return Expanded;
   977:    end Expand_Abstract_States;
   978:
   979:    ------------------------
   980:    -- Extensions_Visible --
   981:    ------------------------
   982:
   983:    function Extensions_Visible
   984:      (E : Entity_Id; Scope : Flow_Scope) return Boolean
   985:    is
   986:       T : constant Entity_Id := Get_Type (E, Scope);
   987:    begin
   988:       return
   989:         Is_Formal (E)
   990:         and then Is_Tagged_Type (T)
   991:         and then not Is_Class_Wide_Type (T)
   992:         and then Has_Extensions_Visible (Sinfo.Nodes.Scope (E));
   993:    end Extensions_Visible;
   994:
   995:    function Extensions_Visible (F : Flow_Id; Scope : Flow_Scope) return Boolean
   996:    is
   997:    begin
   998:       case F.Kind is
   999:          when Direct_Mapping                                    =>
  1000:             return Extensions_Visible (Get_Direct_Mapping_Id (F), Scope);
```

## src/flow/flow_utility.adb:2035-2062

```ada
  2035:
  2036:          declare
  2037:             ---------------------------------------------------------------
  2038:             --  Step 1: Process global annotation
  2039:             ---------------------------------------------------------------
  2040:
  2041:             Raw_Globals : constant Raw_Global_Nodes :=
  2042:               Parse_Global_Contract
  2043:                 (Subprogram => Subprogram, Global_Node => Global_Node);
  2044:
  2045:          begin
  2046:             ---------------------------------------------------------------
  2047:             --  Step 2: Expand any abstract state that might be too refined for
  2048:             --  our given scope; also, convert to Flow_Ids in preparation for
  2049:             --  the next step, where objects only known by Magic_String might
  2050:             --  appear.
  2051:             ---------------------------------------------------------------
  2052:
  2053:             Globals :=
  2054:               (Proof_Ins =>
  2055:                  To_Flow_Id_Set
  2056:                    (Down_Project (Raw_Globals.Proof_Ins, Scope), In_View),
  2057:                Inputs    =>
  2058:                  To_Flow_Id_Set
  2059:                    (Down_Project (Raw_Globals.Inputs, Scope), In_View),
  2060:                Outputs   =>
  2061:                  To_Flow_Id_Set
  2062:                    (Down_Project (Raw_Globals.Outputs, Scope), Out_View));
```

## src/flow/flow_utility.adb:2519-2681

```ada
  2519:    procedure Get_Proof_Globals
  2520:      (Subprogram      : Runnable_Kind_Id;
  2521:       Reads           : out Flow_Id_Sets.Set;
  2522:       Writes          : out Flow_Id_Sets.Set;
  2523:       Erase_Constants : Boolean;
  2524:       Scop            : Flow_Scope := Null_Flow_Scope)
  2525:    is
  2526:
  2527:       function Only_Mutable
  2528:         (Objects : Flow_Id_Sets.Set) return Flow_Id_Sets.Set
  2529:       with
  2530:         Pre  => Erase_Constants,
  2531:         Post =>
  2532:           Flow_Id_Sets.Is_Subset
  2533:             (Subset => Only_Mutable'Result, Of_Set => Objects);
  2534:       --  Returns those of Objects that are mutable in Why3
  2535:
  2536:       ------------------
  2537:       -- Only_Mutable --
  2538:       ------------------
  2539:
  2540:       function Only_Mutable
  2541:         (Objects : Flow_Id_Sets.Set) return Flow_Id_Sets.Set
  2542:       is
  2543:          Mutable : Flow_Id_Sets.Set;
  2544:
  2545:       begin
  2546:          for Object of Objects loop
  2547:             if Object.Kind = Direct_Mapping then
  2548:                --  Entities translated as constants in Why3 should not
  2549:                --  be considered as effects for proof. This includes,
  2550:                --  in particular, formal parameters of mode IN.
  2551:
  2552:                --  Otherwise the effect is significant for proof, keep it
  2553:
  2554:                if Gnat2Why.Util.Is_Mutable_In_Why
  2555:                     (Get_Direct_Mapping_Id (Object))
  2556:                then
  2557:                   Mutable.Insert (Object);
  2558:                end if;
  2559:
  2560:             --  ??? Entities not in SPARK are represented as Magic_String;
  2561:             --  for now, consider them as mutable. The only other objects
  2562:             --  represented as Magic_String are abstract, which are always
  2563:             --  mutable.
  2564:
  2565:             else
  2566:                pragma Assert (Object.Kind = Magic_String);
  2567:                Mutable.Insert (Object);
  2568:             end if;
  2569:          end loop;
  2570:
  2571:          return Mutable;
  2572:       end Only_Mutable;
  2573:
  2574:       E : Entity_Id;
  2575:       --  The entity whose Global contract will be queried from the flow
  2576:       --  analysis; typically this is the same as Subprogram, except for
  2577:       --  derived task types, which can't have a Global contracts (so flow
  2578:       --  analysis do not provide it). For them, proof expects the Global
  2579:       --  contract of the root type (which should also be a task type and also
  2580:       --  be in SPARK).
  2581:
  2582:       Globals : Global_Flow_Ids;
  2583:       Scope   : Flow_Scope;
  2584:
  2585:       --  Start of processing for Get_Proof_Globals
  2586:
  2587:    begin
  2588:       --  We currently have no way to annotate subprogram types with globals,
  2589:       --  assume that they have none.
  2590:
  2591:       if Ekind (Subprogram) = E_Subprogram_Type then
  2592:          return;
  2593:       end if;
  2594:
  2595:       if Is_Derived_Type (Subprogram) then
  2596:          E := Root_Type (Subprogram);
  2597:
  2598:          if Is_Private_Type (E) then
  2599:             E := Full_View (E);
  2600:             pragma Assert (Present (E));
  2601:          end if;
  2602:
  2603:          pragma
  2604:            Assert
  2605:              (Ekind (E) = E_Task_Type
  2606:               and then not Is_Derived_Type (E)
  2607:               and then Entity_In_SPARK (E));
  2608:       else
  2609:          E := Subprogram;
  2610:       end if;
  2611:
  2612:       --  For predicate functions we generate globals on the fly as any objects
  2613:       --  referenced in the predicate expression (except for the predicate type
  2614:       --  itself, which is represented by the formal parameter of a predicate
  2615:       --  function).
  2616:
  2617:       if Ekind (E) = E_Function and then Is_Predicate_Function (E) then
  2618:          declare
  2619:             Param : constant Entity_Id := First_Formal (E);
  2620:
  2621:          begin
  2622:             for V of
  2623:               Get_Variables_For_Proof
  2624:                 (Expr_N => Get_Expr_From_Return_Only_Func (E), Scope_N => E)
  2625:             loop
  2626:                if V.Kind = Direct_Mapping and then V.Node = Param then
  2627:                   null;
  2628:                else
  2629:                   Reads.Include (V);
  2630:                end if;
  2631:             end loop;
  2632:          end;
  2633:
  2634:          Writes := Flow_Id_Sets.Empty_Set;
  2635:
  2636:       elsif Is_Tagged_Predefined_Eq (E) then
  2637:          null;
  2638:
  2639:       --  Otherwise, we rely on the flow analysis
  2640:
  2641:       else
  2642:
  2643:          --  If explicit visibility scope is provided, then use it; for
  2644:          --  access-to-subprograms use the visibility of their declaration;
  2645:          --  otherwise use "the most precise globals" that make sense,
  2646:          --  i.e. Refined_Global if subprogram body is in SPARK and
  2647:          --  Global otherwise.
  2648:
  2649:          Scope :=
  2650:            (if Present (Scop)
  2651:             then Scop
  2652:             else
  2653:               (Ent  => E,
  2654:                Part =>
  2655:                  (if Entity_Body_In_SPARK (E)
  2656:                   then Body_Part
  2657:                   else Visible_Part)));
  2658:
  2659:          Get_Globals
  2660:            (Subprogram          => E,
  2661:             Scope               => Scope,
  2662:             Classwide           => True,
  2663:             Globals             => Globals,
  2664:             Use_Deduced_Globals => True);
  2665:
  2666:          --  Expand all variables; it is more efficent to process Proof_Ins and
  2667:          --  Reads separaterly, because they are disjoint and there is no point
  2668:          --  in computing their union.
  2669:          Reads :=
  2670:            Flow_Id_Sets.Union
  2671:              (Expand_Abstract_States (Globals.Proof_Ins),
  2672:               Expand_Abstract_States (Globals.Inputs));
  2673:
  2674:          Writes := Expand_Abstract_States (Globals.Outputs);
  2675:       end if;
  2676:
  2677:       if Erase_Constants then
  2678:          Reads := Only_Mutable (Reads);
  2679:          Writes := Only_Mutable (Writes);
  2680:       end if;
  2681:    end Get_Proof_Globals;
```

## src/flow/flow_utility.adb:6352-6359

```ada
  6352:    function Rely_On_Generated_Global
  6353:      (E : Entity_Id; Scope : Flow_Scope) return Boolean is
  6354:    begin
  6355:       return
  6356:         Entity_Body_In_SPARK (E)
  6357:         and then Is_Visible (Get_Body (E), Scope)
  6358:         and then Refinement_Needed (E);
  6359:    end Rely_On_Generated_Global;
```

## src/spark/spark_definition.adb:248-263

```ada
   248:    --  initialization to a flag which is true if the type has relaxed
   249:    --  initialization itself.
   250:
   251:    Unused_Records : Hashed_Node_Sets.Set;
   252:    --  Record types which can be abstracted away (their fields are unused)
   253:
   254:    Potentially_Invalid : Hashed_Node_Sets.Set;
   255:    --  Base types of potentially invalid values
   256:
   257:    function Entity_In_SPARK (E : Entity_Id) return Boolean
   258:    renames Entities_In_SPARK.Contains;
   259:
   260:    function Entity_Marked (E : Entity_Id) return Boolean
   261:    renames Entity_Set.Contains;
   262:
   263:    function Entity_Body_In_SPARK (E : Entity_Id) return Boolean
```

## src/spark/spark_definition.adb:11836-11895

```ada
 11836:    begin
 11837:       --  Ignore functions generated by the frontend for aspects Type_Invariant
 11838:       --  and Default_Initial_Condition. This does not include the functions
 11839:       --  generated for Predicate aspects, as these functions are translated
 11840:       --  to check absence of RTE in the predicate in the most general context.
 11841:
 11842:       if Is_Subprogram (E) and then Subprogram_Is_Ignored_For_Proof (E) then
 11843:          return;
 11844:       end if;
 11845:
 11846:       --  Nothing to do if the entity E was already marked
 11847:
 11848:       if Entity_Marked (E) then
 11849:          return;
 11850:       end if;
 11851:
 11852:       --  Store entities defined in actions in Actions_Entity_Set
 11853:
 11854:       if Inside_Actions then
 11855:          Actions_Entity_Set.Insert (E);
 11856:       end if;
 11857:
 11858:       if Ekind (E) in E_Protected_Type | E_Task_Type then
 11859:
 11860:          --  The System unit must be already loaded; see calls to
 11861:          --  SPARK_Implicit_Load in Analyze_Protected_Type_Declaration and
 11862:          --  Analyze_Task_Type_Declaration.
 11863:
 11864:          pragma Assert (RTU_Loaded (System));
 11865:
 11866:          Mark_Entity (RTE (RE_Priority));
 11867:          Mark_Entity (RTE (RE_Interrupt_Priority));
 11868:       end if;
 11869:
 11870:       Current_SPARK_Pragma := SPARK_Pragma_Of_Entity (E);
 11871:       Current_Delayed_Aspect_Type := Empty;
 11872:       Current_Incomplete_Type := Empty;
 11873:
 11874:       --  Fill in the map between classwide types and their corresponding
 11875:       --  specific type, in the case of the implicitly declared classwide type
 11876:       --  T'Class. Also fill in the map between primitive operations and their
 11877:       --  corresponding tagged type.
 11878:
 11879:       if Ekind (E) in E_Record_Type | E_Record_Subtype
 11880:         and then Is_Tagged_Type (E)
 11881:         and then (if Ekind (E) = E_Record_Subtype then No (Cloned_Subtype (E)))
 11882:         and then not Is_Class_Wide_Type (E)
 11883:         and then not Is_Itype (E)
 11884:       then
 11885:          Set_Specific_Tagged (Class_Wide_Type (E), E);
 11886:       end if;
 11887:
 11888:       --  Include entity E in the set of marked entities
 11889:
 11890:       Entity_Set.Insert (E);
 11891:
 11892:       --  If the entity is declared in the scope of SPARK_Mode => Off, then do
 11893:       --  not consider whether it could be in SPARK or not. Restore SPARK_Mode
 11894:       --  pragma before returning.
 11895:
```

## src/spark/spark_definition.adb:12186-12248

```ada
 12186:       else
 12187:
 12188:          case Ekind (E) is
 12189:             --  Concurrent types go before their visible declarations
 12190:             --  (because declarations reference them as implicit inputs).
 12191:
 12192:             when E_Protected_Type | E_Task_Type =>
 12193:                pragma
 12194:                  Assert
 12195:                    (Current_Concurrent_Insert_Pos /= Node_Lists.No_Element);
 12196:
 12197:                Node_Lists.Next (Current_Concurrent_Insert_Pos);
 12198:
 12199:                --  If there were no entities defined within concurrent types
 12200:                --  then Next will advance the cursor to No_Element and
 12201:                --  Insert will be equivalent to Append. This is precisely
 12202:                --  what we need.
 12203:                Entity_List.Insert
 12204:                  (Before => Current_Concurrent_Insert_Pos, New_Item => E);
 12205:
 12206:             --  Abstract states are not translated like other entities; they
 12207:             --  are either fully expanded into constituents (if their
 12208:             --  refinement is not hidden behind a SPARK_Mode => Off) or
 12209:             --  translated just to represent their hidden constituents.
 12210:             --
 12211:             --  Named numbers also do not require any translation.
 12212:
 12213:             when E_Abstract_State | Named_Kind  =>
 12214:                null;
 12215:
 12216:             when E_Record_Type                  =>
 12217:
 12218:                Entity_List.Append (E);
 12219:
 12220:                --  Insert record types into the Unused_Records set
 12221:
 12222:                if not Is_In_Analyzed_Files (E)
 12223:                  and then (Is_Tagged_Type (E) or else Retysp (Etype (E)) = E)
 12224:                then
 12225:
 12226:                   --  Do not attempt to abstract away types which might not
 12227:                   --  have components nor deep types which might happen to
 12228:                   --  be shallow. This ensures that proof of initialization
 12229:                   --  (when relaxed initialization is used) and absence of
 12230:                   --  leaks (for deep types) is done precisely.
 12231:
 12232:                   if not Has_Empty_Variants (E)
 12233:                     and then
 12234:                       (not Is_Deep (E) or else not Has_Shallow_Variants (E))
 12235:                   then
 12236:                      Unused_Records.Insert (E);
 12237:                   end if;
 12238:                end if;
 12239:
 12240:             when others                         =>
 12241:
 12242:                --  Do not translate objects from declare expressions. They
 12243:                --  are handled as local objects.
 12244:
 12245:                if not Comes_From_Declare_Expr (E) then
 12246:                   Entity_List.Append (E);
 12247:                end if;
 12248:          end case;
```

## src/spark/spark_definition.adb:14999-15035

```ada
 14999:    function First_Cursor (Kind : Entity_Collection) return Cursor is
 15000:       pragma Unreferenced (Kind);
 15001:    begin
 15002:       return Cursor (Entity_List.First);
 15003:    end First_Cursor;
 15004:
 15005:    -----------------
 15006:    -- Next_Cursor --
 15007:    -----------------
 15008:
 15009:    function Next_Cursor (Kind : Entity_Collection; C : Cursor) return Cursor is
 15010:       pragma Unreferenced (Kind);
 15011:    begin
 15012:       return Cursor (Node_Lists.Next (Node_Lists.Cursor (C)));
 15013:    end Next_Cursor;
 15014:
 15015:    -----------------
 15016:    -- Has_Element --
 15017:    -----------------
 15018:
 15019:    function Has_Element (Kind : Entity_Collection; C : Cursor) return Boolean
 15020:    is
 15021:       pragma Unreferenced (Kind);
 15022:    begin
 15023:       return Node_Lists.Has_Element (Node_Lists.Cursor (C));
 15024:    end Has_Element;
 15025:
 15026:    -----------------
 15027:    -- Get_Element --
 15028:    -----------------
 15029:
 15030:    function Get_Element (Kind : Entity_Collection; C : Cursor) return Entity_Id
 15031:    is
 15032:       pragma Unreferenced (Kind);
 15033:    begin
 15034:       return Node_Lists.Element (Node_Lists.Cursor (C));
 15035:    end Get_Element;
```

## src/spark/spark_definition.ads:215-232

```ada
   215:    type Entity_Collection is (Entities_To_Translate)
   216:    with
   217:      Iterable =>
   218:        (First       => First_Cursor,
   219:         Next        => Next_Cursor,
   220:         Has_Element => Has_Element,
   221:         Element     => Get_Element);
   222:
   223:    type Cursor is private;
   224:
   225:    function First_Cursor (Kind : Entity_Collection) return Cursor;
   226:
   227:    function Next_Cursor (Kind : Entity_Collection; C : Cursor) return Cursor;
   228:
   229:    function Has_Element (Kind : Entity_Collection; C : Cursor) return Boolean;
   230:
   231:    function Get_Element
   232:      (Kind : Entity_Collection; C : Cursor) return Entity_Id;
```

## src/spark/spark_util-types.adb:1521-1620

```ada
  1521:    function Invariant_Check_Needed
  1522:      (Ty : Type_Kind_Id; Subp : Entity_Id := Empty; Scop : Entity_Id := Empty)
  1523:       return Boolean
  1524:    is
  1525:       Rep_Ty  : constant Type_Kind_Id := Retysp (Ty);
  1526:       Current : Type_Kind_Id := Rep_Ty;
  1527:       Parent  : Type_Kind_Id;
  1528:
  1529:    begin
  1530:       --  Check for invariants on the type and its ancestors. Do not consider
  1531:       --  invariants which are assumed, globally or in Scop, and invariant
  1532:       --  relaxed for Subp.
  1533:
  1534:       loop
  1535:          if Has_Invariants_In_SPARK (Current)
  1536:            and then not Invariant_Assumed_In_Main (Current)
  1537:            and then
  1538:              (No (Scop) or else not Invariant_Assumed_In_Scope (Current, Scop))
  1539:            and then
  1540:              (No (Subp)
  1541:               or else not Invariant_Relaxed_For_Subprogram (Current, Subp))
  1542:          then
  1543:             return True;
  1544:          end if;
  1545:
  1546:          Parent := Retysp (Etype (Current));
  1547:          exit when Current = Parent;
  1548:          Current := Parent;
  1549:       end loop;
  1550:
  1551:       --  Check for invariants on components
  1552:
  1553:       if Is_Array_Type (Rep_Ty) then
  1554:          return
  1555:            Invariant_Check_Needed
  1556:              (Component_Type (Rep_Ty), Subp => Subp, Scop => Scop);
  1557:
  1558:       elsif Is_Incomplete_Or_Private_Type (Rep_Ty)
  1559:         or else Is_Record_Type (Rep_Ty)
  1560:         or else Is_Concurrent_Type (Rep_Ty)
  1561:       then
  1562:          if Has_Discriminants (Rep_Ty) then
  1563:             declare
  1564:                Discr : Opt_E_Discriminant_Id := First_Discriminant (Rep_Ty);
  1565:             begin
  1566:                while Present (Discr) loop
  1567:                   if Invariant_Check_Needed
  1568:                        (Etype (Discr), Subp => Subp, Scop => Scop)
  1569:                   then
  1570:                      return True;
  1571:                   end if;
  1572:
  1573:                   Discr := Next_Discriminant (Discr);
  1574:                end loop;
  1575:             end;
  1576:          end if;
  1577:
  1578:          declare
  1579:             Comp : Node_Id := First_Component (Rep_Ty);
  1580:          begin
  1581:             while Present (Comp) loop
  1582:                if Ekind (Comp) = E_Component
  1583:                  and then Entity_In_SPARK (Etype (Comp))
  1584:                  and then
  1585:                    Invariant_Check_Needed
  1586:                      (Etype (Comp), Subp => Subp, Scop => Scop)
  1587:                then
  1588:                   return True;
  1589:                end if;
  1590:                Next_Component (Comp);
  1591:             end loop;
  1592:          end;
  1593:
  1594:       --  We stop the search at access-to-incomplete types, as they might
  1595:       --  not be marked yet. This is possible because there is a tool
  1596:       --  limitation which disallows access to incomplete types if they need
  1597:       --  an invariant check.
  1598:
  1599:       elsif Is_Access_Type (Rep_Ty)
  1600:         and then not Is_Access_Subprogram_Type (Rep_Ty)
  1601:       then
  1602:          declare
  1603:             Des_Ty : constant Entity_Id :=
  1604:               Directly_Designated_Type (Base_Retysp (Rep_Ty));
  1605:             --  Use the base type as some subtypes of access to incomplete
  1606:             --  types introduced by the frontend designate record subtypes
  1607:             --  instead.
  1608:          begin
  1609:             return
  1610:               not Acts_As_Incomplete_Type (Des_Ty)
  1611:               and then
  1612:                 Invariant_Check_Needed (Des_Ty, Subp => Subp, Scop => Scop);
  1613:          end;
  1614:       end if;
  1615:       return False;
  1616:    end Invariant_Check_Needed;
  1617:
  1618:    ---------------------------------------
  1619:    --  Invariant_Relaxed_For_Subprogram --
  1620:    ---------------------------------------
```

## src/spark/spark_util-types.adb:3050-3064

```ada
  3050:    function Use_Predefined_Equality_For_Type
  3051:      (Typ : Type_Kind_Id) return Boolean
  3052:    is (not (
  3053:         --  Exclude the case of a record type with only limited views, as in
  3054:         --  that case the user-defined equality cannot be called implicitly
  3055:         --  from SPARK code: either the full view of the type is limited, of
  3056:         --  it is not in SPARK and its partial view is limited.
  3057:         (Is_Record_Type (Unchecked_Full_Type (Typ))
  3058:          and then not Is_Limited_Type (Retysp (Typ)))
  3059:         --  Types that are inherently limited do not have a predefined
  3060:         --  equality.
  3061:         or else Is_Inherently_Limited_Type (Typ))
  3062:        --  Check for the presence of a user-defined primitive equality
  3063:        or else No (Get_User_Defined_Eq (Base_Type (Typ))));
  3064:
```

## src/spark/spark_util-types.ads:128-146

```ada
   128:    -------------------------------
   129:    -- General Queries For Types --
   130:    -------------------------------
   131:
   132:    function Can_Be_Default_Initialized (Typ : Type_Kind_Id) return Boolean
   133:    is ((not Has_Array_Type (Typ) or else Is_Constrained (Typ))
   134:        and then
   135:          (Retysp_Kind (Typ)
   136:           not in Record_Kind | Incomplete_Or_Private_Kind | Concurrent_Kind
   137:           or else not Has_Discriminants (Typ)
   138:           or else Is_Constrained (Typ)
   139:           or else Has_Defaulted_Discriminants (Typ))
   140:        and then not Is_Class_Wide_Type (Typ));
   141:    --  Determine whether there can be default initialized variables of a type.
   142:    --  @param Typ any type
   143:    --  @return False if Typ is unconstrained.
   144:
   145:    function Check_Needed_On_Conversion
   146:      (From, To : Type_Kind_Id) return Boolean;
```

## src/why/gnat2why-decls.adb:66-382

```ada
    66:       B  : constant Item_Type := Ada_Ent_To_Why.Element (Symbol_Table, E);
    67:       pragma Assert (B.Kind = Regular and then not B.Main.Mutable);
    68:       Th : Theory_UC;
    69:    begin
    70:       --  Start with opening the theory to define, as the creation of a
    71:       --  function for the logic term needs the current theory to insert an
    72:       --  include declaration.
    73:
    74:       Th :=
    75:         Open_Theory
    76:           (WF_Context,
    77:            E_Module (E),
    78:            Comment =>
    79:              "Module for defining the constant "
    80:              & """"
    81:              & Get_Name_String (Chars (E))
    82:              & """"
    83:              & (if Sloc (E) > 0
    84:                 then " defined at " & Build_Location_String (Sloc (E))
    85:                 else "")
    86:              & ", created in "
    87:              & GNAT.Source_Info.Enclosing_Entity);
    88:
    89:       --  We generate a "logic", whose axiom will be given in a completion
    90:
    91:       Emit
    92:         (Th,
    93:          Why.Atree.Builders.New_Function_Decl
    94:            (Domain      => EW_Pterm,
    95:             Name        => To_Local (B.Main.B_Name),
    96:             Binders     => (1 .. 0 => <>),
    97:             Labels      => Get_Counterexample_Labels (E),
    98:             Location    => Safe_First_Sloc (E),
    99:             Return_Type => Get_Typ (B.Main.B_Name)));
   100:
   101:       --  Generate a constant for the validity flag
   102:
   103:       if B.Valid.Present then
   104:          Emit
   105:            (Th,
   106:             Why.Atree.Builders.New_Function_Decl
   107:               (Domain      => EW_Pterm,
   108:                Name        => To_Local (B.Valid.Id),
   109:                Binders     => (1 .. 0 => <>),
   110:                Labels      => Get_Counterexample_Labels (E, "'" & Valid_Label),
   111:                Location    => Safe_First_Sloc (E),
   112:                Return_Type => Get_Typ (B.Valid.Id)));
   113:       end if;
   114:
   115:       Close_Theory (Th, Kind => Definition_Theory, Defined_Entity => E);
   116:    end Translate_Constant;
   117:
   118:    ------------------------------
   119:    -- Translate_Constant_Value --
   120:    ------------------------------
   121:
   122:    procedure Translate_Constant_Value (E : E_Constant_Id) is
   123:
   124:       function Can_Be_Translated_As_Value (Expr : Node_Id) return Boolean
   125:       is (not Expression_Contains_Old_Or_Loop_Entry (Expr)
   126:           and then not Contains_Volatile_Function_Call (Expr)
   127:           and then not Is_Function_Call_With_Side_Effects (Expr)
   128:           and then not Contains_Allocator (Expr)
   129:           and then
   130:             (not Within_Protected_Type (E)
   131:              or else Is_Static_Expression (Expr)));
   132:       --  Return True if Expr can be used in the definition axiom of the
   133:       --  constant generated for E. References to Loop_Entry and Old might
   134:       --  occur in constants generated by the frontend.
   135:       --  We also check for the presence of calls to volatile functions,
   136:       --  functions with side effects and allocators which we can't handle in
   137:       --  axioms.
   138:       --  Finally we check if we are in a protected object, as in that case the
   139:       --  expression may require the "self" object, but it's not set up here.
   140:       --  Static expressions can't reference "self", so they are fine.
   141:
   142:       Decl : constant N_Object_Declaration_Id := Enclosing_Declaration (E);
   143:       Expr : constant Opt_N_Subexpr_Id := Expression (Decl);
   144:
   145:       --  Always use the Ada type for the equality between the constant result
   146:       --  and the translation of its initialization expression. Using "int"
   147:       --  instead is tempting to facilitate the job of automatic provers, but
   148:       --  it is potentially incorrect. For example for:
   149:
   150:       --    C : constant Natural := Largest_Int + 1;
   151:
   152:       --  we should *not* generate the incorrect axiom:
   153:
   154:       --    axiom c__def:
   155:       --      to_int(c) = to_int(largest_int) + 1
   156:
   157:       --  but the correct one:
   158:
   159:       --    axiom c__def:
   160:       --      c = of_int (to_int(largest_int) + 1)
   161:
   162:       Th : Theory_UC;
   163:    begin
   164:       --  Start with opening the theory to define, as the creation of a
   165:       --  function for the logic term needs the current theory to insert an
   166:       --  include declaration.
   167:
   168:       Th :=
   169:         Open_Theory
   170:           (WF_Context,
   171:            E_Module (E, Axiom),
   172:            Comment =>
   173:              "Module for defining the value of constant "
   174:              & """"
   175:              & Get_Name_String (Chars (E))
   176:              & """"
   177:              & (if Sloc (E) > 0
   178:                 then " defined at " & Build_Location_String (Sloc (E))
   179:                 else "")
   180:              & ", created in "
   181:              & GNAT.Source_Info.Enclosing_Entity);
   182:
   183:       --  If the constant is hardcoded, get its definition
   184:
   185:       if Is_Hardcoded_Entity (E) then
   186:          declare
   187:             B   : constant Item_Type :=
   188:               Ada_Ent_To_Why.Element (Symbol_Table, E);
   189:             pragma Assert (B.Kind = Regular and then not B.Main.Mutable);
   190:             Def : constant W_Term_Id := Hardcoded_Constant_Value (E);
   191:
   192:          begin
   193:             if Def /= Why_Empty then
   194:                Emit
   195:                  (Th,
   196:                   New_Defining_Axiom
   197:                     (Ada_Node => E,
   198:                      Name     => B.Main.B_Name,
   199:                      Binders  => (1 .. 0 => <>),
   200:                      Def      => Def));
   201:
   202:             end if;
   203:          end;
   204:
   205:       --  If E has an expression, we try to generate a defining axiom for E
   206:
   207:       elsif Present (Expr) and then Can_Be_Translated_As_Value (Expr) then
   208:          declare
   209:             B      : constant Item_Type :=
   210:               Ada_Ent_To_Why.Element (Symbol_Table, E);
   211:             pragma Assert (B.Kind = Regular and then not B.Main.Mutable);
   212:             Params : constant Transformation_Params :=
   213:               (Logic_Params with delta Ref_Allowed => True);
   214:             Def    : W_Term_Id;
   215:
   216:             --  Context and validity flag to handle potantially invalid values
   217:
   218:             Valid_Flag : W_Expr_Id :=
   219:               (if B.Valid.Present
   220:                then +New_Valid_Value_For_Type (Etype (E))
   221:                else Why_Empty);
   222:             Context    : Ref_Context;
   223:
   224:          begin
   225:             --  Handle the potential propagation of invalid values
   226:
   227:             if Propagates_Validity_Flag (Decl) then
   228:                pragma Assert (B.Valid.Present);
   229:                Def :=
   230:                  +Transform_Potentially_Invalid_Expr
   231:                     (Expr          => Expr,
   232:                      Expected_Type => Get_Typ (B.Main.B_Name),
   233:                      Domain        => EW_Term,
   234:                      Params        => Params,
   235:                      Context       => Context,
   236:                      Valid_Flag    => Valid_Flag);
   237:             else
   238:                Def := Transform_Term (Expr, Get_Typ (B.Main.B_Name), Params);
   239:             end if;
   240:
   241:             --  We will generate separate defining axioms, so insert the
   242:             --  context inside Def and Valid_Flag.
   243:
   244:             if B.Valid.Present then
   245:                Def :=
   246:                  +Bindings_For_Ref_Context
   247:                     (Expr => +Def, Context => Context, Domain => EW_Term);
   248:
   249:                if Propagates_Validity_Flag (Decl)
   250:                  and then Is_Potentially_Invalid_Expr (Expr)
   251:                then
   252:                   Valid_Flag :=
   253:                     Bindings_For_Ref_Context
   254:                       (Expr    => Valid_Flag,
   255:                        Context => Context,
   256:                        Domain  => EW_Term);
   257:                end if;
   258:             end if;
   259:
   260:             --  Emit an axiom for the definition of B.Main if Def does not
   261:             --  contain any dereferences.
   262:
   263:             if not Has_Dereference_Or_Any_Or_Self (Def) then
   264:                Emit
   265:                  (Th,
   266:                   New_Defining_Axiom
   267:                     (Ada_Node => E,
   268:                      Name     => B.Main.B_Name,
   269:                      Binders  => (1 .. 0 => <>),
   270:                      Def      => Def));
   271:             end if;
   272:
   273:             --  Also add an axioms of B.Valid.Id if any
   274:
   275:             if B.Valid.Present
   276:               and then not Has_Dereference_Or_Any_Or_Self (+Valid_Flag)
   277:             then
   278:                Emit
   279:                  (Th,
   280:                   New_Defining_Axiom
   281:                     (Ada_Node => E,
   282:                      Name     => B.Valid.Id,
   283:                      Binders  => (1 .. 0 => <>),
   284:                      Def      => +Valid_Flag));
   285:             end if;
   286:          end;
   287:
   288:       --  Constant overlays are always imported. Use a UC function to compute
   289:       --  their value.
   290:
   291:       elsif Present (Overlaid_Entity (E)) then
   292:          declare
   293:             Obj_Ty  : constant Type_Kind_Id := Type_Of_Node (E);
   294:             Pref    : constant Node_Id := Prefix (Get_Address_Expr (Decl));
   295:             Pref_Ty : constant Type_Kind_Id := Type_Of_Node (Pref);
   296:             Params  : constant Transformation_Params :=
   297:               (Logic_Params with delta Ref_Allowed => True);
   298:             W_Pref  : constant W_Term_Id :=
   299:               Transform_Term (Pref, Type_Of_Node (Pref_Ty), Params);
   300:
   301:          begin
   302:             pragma Assert (Is_Overlay_Handled_As_UC (E).Ok);
   303:
   304:             --  Generate UC modules for the translation of E and emit the
   305:             --  defining axiom.
   306:
   307:             Create_Module_For_UC_If_Needed
   308:               (Pref_Ty, Obj_Ty, Is_Potentially_Invalid (E));
   309:
   310:             --  Emit an axiom for the definition of E if W_Pref does not
   311:             --  contain any dereferences.
   312:
   313:             if not Has_Dereference_Or_Any_Or_Self (W_Pref) then
   314:                declare
   315:                   B     : constant Item_Type :=
   316:                     Ada_Ent_To_Why.Element (Symbol_Table, E);
   317:                   UC_Id : constant W_Identifier_Id :=
   318:                     Get_UC_Function
   319:                       (Pref_Ty,
   320:                        Obj_Ty,
   321:                        Potentially_Invalid => B.Valid.Present);
   322:                   Def   : W_Term_Id :=
   323:                     New_Call
   324:                       (Name => UC_Id,
   325:                        Args => (1 => +W_Pref),
   326:                        Typ  => Get_Typ (UC_Id));
   327:
   328:                begin
   329:                   if B.Valid.Present then
   330:                      Emit
   331:                        (Th,
   332:                         New_Defining_Axiom
   333:                           (Ada_Node => E,
   334:                            Name     => B.Valid.Id,
   335:                            Binders  => (1 .. 0 => <>),
   336:                            Def      =>
   337:                              +New_Function_Valid_Flag_Access (Obj_Ty, +Def)));
   338:                      Def :=
   339:                        +New_Function_Valid_Value_Access
   340:                           (Ty => Obj_Ty, Name => +Def);
   341:                   end if;
   342:
   343:                   Emit
   344:                     (Th,
   345:                      New_Defining_Axiom
   346:                        (Ada_Node => E,
   347:                         Name     => B.Main.B_Name,
   348:                         Binders  => (1 .. 0 => <>),
   349:                         Def      => Def));
   350:                end;
   351:             end if;
   352:
   353:             --  Output information on reason for imprecise handling of overlay
   354:
   355:             declare
   356:                Precise_Overlay : constant True_Or_Explain :=
   357:                  Is_UC_With_Precise_Definition
   358:                    (Pref_Ty, Obj_Ty, Is_Potentially_Invalid (E));
   359:
   360:             begin
   361:                if not Precise_Overlay.Ok then
   362:                   Warning_Msg_N
   363:                     (Warn_Imprecise_Overlay,
   364:                      E,
   365:                      Msg =>
   366:                        Create_N
   367:                          (Warn_Imprecise_Overlay,
   368:                           Names => [To_String (Precise_Overlay.Explanation)]));
   369:                end if;
   370:             end;
   371:          end;
   372:       end if;
   373:
   374:       --  No filtering is necessary here, as the theory should on the
   375:       --  contrary use the previously defined theory for the partial
   376:       --  view. Attach the newly created theory as a completion of the
   377:       --  existing one.
   378:
   379:       Close_Theory
   380:         (Th,
   381:          Kind           => Axiom_Theory,
   382:          Defined_Entity => (if Is_Full_View (E) then Partial_View (E) else E));
```

## src/why/gnat2why-decls.adb:451-490

```ada
   451:       Close_Theory (Th, Kind => Standalone_Theory);
   452:    end Translate_External_Object;
   453:
   454:    ---------------------------
   455:    -- Translate_Loop_Entity --
   456:    ---------------------------
   457:
   458:    procedure Translate_Loop_Entity (E : E_Loop_Id) is
   459:       Th : Theory_UC;
   460:    begin
   461:       Th :=
   462:         Open_Theory
   463:           (WF_Context,
   464:            E_Module (E),
   465:            Comment =>
   466:              "Module for defining "
   467:              & "the loop exit exception for the loop "
   468:              & """"
   469:              & Get_Name_String (Chars (E))
   470:              & """"
   471:              & (if Sloc (E) > 0
   472:                 then " defined at " & Build_Location_String (Sloc (E))
   473:                 else "")
   474:              & ", created in "
   475:              & GNAT.Source_Info.Enclosing_Entity);
   476:
   477:       Emit
   478:         (Th,
   479:          New_Exception_Declaration
   480:            (Name =>
   481:               Loop_Exception_Name (E, Is_Continue => False, Local => True),
   482:             Arg  => Why_Empty));
   483:       Emit
   484:         (Th,
   485:          New_Exception_Declaration
   486:            (Name =>
   487:               Loop_Exception_Name (E, Is_Continue => True, Local => True),
   488:             Arg  => Why_Empty));
   489:
   490:       Close_Theory (Th, Kind => Standalone_Theory);
```

## src/why/gnat2why-decls.adb:496-812

```ada
   496:
   497:    procedure Translate_Variable (E : Object_Kind_Id) is
   498:       Var      : constant Item_Type := Mk_Item_Of_Entity (E);
   499:       Alias    : constant Opt_Object_Kind_Id := Ultimate_Overlaid_Entity (E);
   500:       Alias_Id : constant W_Identifier_Id :=
   501:         (if Present (Alias)
   502:          then
   503:            New_Temp_Identifier
   504:              (Base_Name => "overlaid", Typ => Type_Of_Node (Alias))
   505:          else Why_Empty);
   506:       Call     : W_Expr_Id := Why_Empty;
   507:       --  Call to the UC function if we are translating an overlay as a UC
   508:       Th       : Theory_UC;
   509:
   510:       procedure Emit_Global_Ref_Or_Function
   511:         (Name    : W_Identifier_Id;
   512:          Mutable : Boolean;
   513:          Labels  : Symbol_Sets.Set;
   514:          Def     : W_Expr_Id := Why_Empty)
   515:       with Pre => (if Present (Def) then Mutable and then Present (Alias));
   516:       --  Declare a part of the object E. Emit a constant declaration if the
   517:       --  object is not mutable, a global reference if it is mutable but not
   518:       --  an overlay, and a function taking the overlaid object as a parameter
   519:       --  for mutable parts of overlays. If Def is supplied, use it for the
   520:       --  definition of the function.
   521:
   522:       ---------------------------------
   523:       -- Emit_Global_Ref_Or_Function --
   524:       ---------------------------------
   525:
   526:       procedure Emit_Global_Ref_Or_Function
   527:         (Name    : W_Identifier_Id;
   528:          Mutable : Boolean;
   529:          Labels  : Symbol_Sets.Set;
   530:          Def     : W_Expr_Id := Why_Empty) is
   531:       begin
   532:          --  For non-mutable objects, always generate a constant
   533:
   534:          if not Mutable then
   535:             Emit
   536:               (Th,
   537:                Why.Atree.Builders.New_Function_Decl
   538:                  (Domain      => EW_Pterm,
   539:                   Name        => To_Local (Name),
   540:                   Binders     => (1 .. 0 => <>),
   541:                   Labels      => Labels,
   542:                   Location    => Safe_First_Sloc (E),
   543:                   Return_Type => Get_Typ (Name)));
   544:
   545:          --  If the object is not aliased, generate a global ref
   546:
   547:          elsif No (Alias) then
   548:             Emit
   549:               (Th,
   550:                New_Global_Ref_Declaration
   551:                  (Name     => To_Local (Name),
   552:                   Labels   => Labels,
   553:                   Location => Safe_First_Sloc (E),
   554:                   Ref_Type => Get_Typ (Name)));
   555:
   556:          --  Otherwise, generate a function that takes Alias_Id as a parameter
   557:
   558:          else
   559:             Emit
   560:               (Th,
   561:                Why.Atree.Builders.New_Function_Decl
   562:                  (Domain      => EW_Pterm,
   563:                   Name        => To_Local (Name),
   564:                   Binders     =>
   565:                     (1 =>
   566:                        New_Binder
   567:                          (Domain   => EW_Pterm,
   568:                           Name     => Alias_Id,
   569:                           Arg_Type => Get_Typ (Alias_Id))),
   570:                   Labels      => Labels,
   571:                   Location    => Safe_First_Sloc (E),
   572:                   Return_Type => Get_Typ (Name),
   573:                   Def         => Def));
   574:          end if;
   575:       end Emit_Global_Ref_Or_Function;
   576:
   577:    begin
   578:       --  For overlays, generate the UC modules needed for the translation
   579:       --  and use it to initialize Call.
   580:
   581:       if Present (Alias) then
   582:          declare
   583:             Obj_Ty          : constant Type_Kind_Id := Type_Of_Node (E);
   584:             Root_Ty         : constant Type_Kind_Id := Type_Of_Node (Alias);
   585:             Precise_Overlay : True_Or_Explain := Is_Overlay_Handled_As_UC (E);
   586:          begin
   587:             if Precise_Overlay.Ok then
   588:                pragma Assert (not Is_Potentially_Invalid (E));
   589:
   590:                Create_Module_For_UC_If_Needed
   591:                  (Root_Ty, Obj_Ty, Potentially_Invalid => False);
   592:
   593:                Create_Module_For_UC_If_Needed
   594:                  (Obj_Ty, Root_Ty, Potentially_Invalid => False);
   595:
   596:                Precise_Overlay :=
   597:                  Is_UC_With_Precise_Definition
   598:                    (Root_Ty, Obj_Ty, Potentially_Invalid => False);
   599:
   600:                declare
   601:                   UC_Id : constant W_Identifier_Id :=
   602:                     Get_UC_Function
   603:                       (Root_Ty, Obj_Ty, Potentially_Invalid => False);
   604:                begin
   605:                   Call :=
   606:                     New_Call
   607:                       (Domain => EW_Term,
   608:                        Name   => UC_Id,
   609:                        Args   => (1 => +Alias_Id),
   610:                        Typ    => Get_Typ (UC_Id));
   611:                end;
   612:             end if;
   613:
   614:             --  Output information on reason for imprecise handling of overlay
   615:
   616:             if not Precise_Overlay.Ok then
   617:                Warning_Msg_N
   618:                  (Warn_Imprecise_Overlay,
   619:                   E,
   620:                   Msg =>
   621:                     Create_N
   622:                       (Warn_Imprecise_Overlay,
   623:                        Names => [To_String (Precise_Overlay.Explanation)]));
   624:             end if;
   625:          end;
   626:       end if;
   627:
   628:       Th :=
   629:         Open_Theory
   630:           (WF_Context,
   631:            E_Module (E),
   632:            Comment =>
   633:              "Module for defining a ref holding the value of variable "
   634:              & """"
   635:              & Get_Name_String (Chars (E))
   636:              & """"
   637:              & (if Sloc (E) > 0
   638:                 then " defined at " & Build_Location_String (Sloc (E))
   639:                 else "")
   640:              & ", created in "
   641:              & GNAT.Source_Info.Enclosing_Entity);
   642:
   643:       --  If E is not in SPARK, only declare an object of type __private for
   644:       --  use in effects of program functions in Why3.
   645:
   646:       case Var.Kind is
   647:          when DRecord                =>
   648:             if Var.Fields.Present then
   649:
   650:                --  Generate a global ref for the fields
   651:
   652:                Emit_Global_Ref_Or_Function
   653:                  (Name    => Var.Fields.Binder.B_Name,
   654:                   Labels  =>
   655:                     Get_Counterexample_Labels
   656:                       (E, Append_To_Name => "'" & Field_Label),
   657:                   Mutable => True,
   658:                   Def     =>
   659:                     (if Call /= Why_Empty
   660:                      then New_Fields_Access (Name => Call, Ty => Var.Typ)
   661:                      else Why_Empty));
   662:             end if;
   663:
   664:             if Var.Discrs.Present then
   665:
   666:                --  Generate a global ref or constant for the fields
   667:
   668:                Emit_Global_Ref_Or_Function
   669:                  (Name    => Var.Discrs.Binder.B_Name,
   670:                   Labels  =>
   671:                     Get_Counterexample_Labels
   672:                       (E, Append_To_Name => "'" & Discr_Label),
   673:                   Mutable => Var.Discrs.Binder.Mutable);
   674:             end if;
   675:
   676:             if Var.Constr.Present then
   677:
   678:                --  Generate a constant for 'Constrained attribute
   679:
   680:                Emit_Global_Ref_Or_Function
   681:                  (Name    => Var.Constr.Id,
   682:                   Labels  =>
   683:                     Get_Counterexample_Labels (E, "'" & Constrained_Label),
   684:                   Mutable => False);
   685:             end if;
   686:
   687:             if Var.Tag.Present then
   688:
   689:                --  Generate a constant for 'Tag attribute
   690:
   691:                Emit_Global_Ref_Or_Function
   692:                  (Name    => Var.Tag.Id,
   693:                   Labels  => Symbol_Sets.Empty_Set,
   694:                   Mutable => False);
   695:             end if;
   696:
   697:          when UCArray                =>
   698:
   699:             --  Generate a global ref for the content
   700:
   701:             Emit_Global_Ref_Or_Function
   702:               (Name    => Var.Content.B_Name,
   703:                Labels  => Get_Counterexample_Labels (E),
   704:                Mutable => True,
   705:                Def     =>
   706:                  (if Call /= Why_Empty
   707:                   then Array_Convert_To_Base (EW_Term, Call)
   708:                   else Why_Empty));
   709:
   710:             for D in 1 .. Var.Dim loop
   711:                declare
   712:                   function Bound_Dimension_To_Str
   713:                     (Total_Dim, Num_Dim : Integer; Bound_Name : String)
   714:                      return String
   715:                   is (if Total_Dim = 1
   716:                       then Bound_Name
   717:                       else
   718:                         Bound_Name
   719:                         & " ("
   720:                         & Trim (Integer'Image (Num_Dim), Both)
   721:                         & ")");
   722:
   723:                begin
   724:                   --  Generate constants for bounds
   725:
   726:                   Emit_Global_Ref_Or_Function
   727:                     (Name    => Var.Bounds (D).First,
   728:                      Labels  =>
   729:                        Get_Counterexample_Labels
   730:                          (E,
   731:                           Bound_Dimension_To_Str
   732:                             (Var.Dim, D, "'" & First_Label)),
   733:                      Mutable => False);
   734:
   735:                   Emit_Global_Ref_Or_Function
   736:                     (Name    => Var.Bounds (D).Last,
   737:                      Labels  =>
   738:                        Get_Counterexample_Labels
   739:                          (E,
   740:                           Bound_Dimension_To_Str
   741:                             (Var.Dim, D, "'" & Last_Label)),
   742:                      Mutable => False);
   743:                end;
   744:             end loop;
   745:
   746:          when Pointer                =>
   747:
   748:             --  Generate a global ref for the value
   749:
   750:             Emit_Global_Ref_Or_Function
   751:               (Name    => Var.Value.B_Name,
   752:                Labels  => Get_Counterexample_Labels (E, "'" & All_Label),
   753:                Mutable => True);
   754:
   755:             --  Generate a global ref for the is_null if the pointer is mutable
   756:
   757:             Emit_Global_Ref_Or_Function
   758:               (Name    => Var.Is_Null,
   759:                Labels  => Get_Counterexample_Labels (E, "'" & Is_Null_Label),
   760:                Mutable => Var.Mutable);
   761:
   762:          when Regular                =>
   763:             begin
   764:                --  Currently only generate values for scalar variables in
   765:                --  counterexamples, which are always of the Regular kind.
   766:
   767:                --  generate a global ref
   768:
   769:                Emit_Global_Ref_Or_Function
   770:                  (Name    => Var.Main.B_Name,
   771:                   Labels  => Get_Counterexample_Labels (E),
   772:                   Mutable => True,
   773:                   Def     => Call);
   774:             end;
   775:
   776:          when Subp | Concurrent_Self =>
   777:             raise Program_Error;
   778:       end case;
   779:
   780:       --  generate a global ref for the initialization flag if any
   781:
   782:       if Var.Init.Present then
   783:          Emit_Global_Ref_Or_Function
   784:            (Name    => Var.Init.Id,
   785:             Labels  => Get_Counterexample_Labels (E, "'" & Initialized_Label),
   786:             Mutable => True);
   787:       end if;
   788:
   789:       --  Generate a variable for the move tree
   790:
   791:       if Var.Is_Moved.Present then
   792:          Emit_Global_Ref_Or_Function
   793:            (Name    => Var.Is_Moved.Id,
   794:             Labels  => Symbol_Sets.Empty_Set,
   795:             Mutable => True);
   796:       end if;
   797:
   798:       --  Generate a variable for the validity flag
   799:
   800:       if Var.Valid.Present then
   801:          Emit_Global_Ref_Or_Function
   802:            (Name    => Var.Valid.Id,
   803:             Labels  => Get_Counterexample_Labels (E, "'" & Valid_Label),
   804:             Mutable => True);
   805:       end if;
   806:
   807:       --  Declare the variable for the value at end of E
   808:
   809:       if Is_Local_Borrower (E) then
   810:          Declare_At_End_Ref (Th, E);
   811:       end if;
   812:
```

## src/why/gnat2why-driver.adb:274-310

```ada
   274:    procedure Complete_Declaration (E : Entity_Id) is
   275:    begin
   276:       --  Check that the global variables are cleared before and after this
   277:       --  routine; this is an assertion rather than a pre/post condition,
   278:       --  because the caller shouldn't really care about it.
   279:
   280:       pragma Assert (No (Current_Subp));
   281:       Current_Subp := E;
   282:
   283:       case Ekind (E) is
   284:          when E_Entry | E_Function | E_Procedure =>
   285:             if Is_Translated_Subprogram (E) then
   286:                if Is_Expression_Function_Or_Completion (E)
   287:                  and then Entity_Body_Compatible_With_SPARK (E)
   288:                then
   289:                   Translate_Expression_Function_Body (E);
   290:                else
   291:                   Generate_Subprogram_Completion (E);
   292:                end if;
   293:             end if;
   294:
   295:          when Type_Kind                          =>
   296:             pragma Assert (Entity_In_SPARK (E));
   297:
   298:             if Retysp (E) = E
   299:               and then not Is_Standard_Boolean_Type (E)
   300:               and then E /= Universal_Fixed
   301:             then
   302:                Generate_Type_Completion (E);
   303:             end if;
   304:
   305:          when others                             =>
   306:             null;
   307:       end case;
   308:
   309:       Current_Subp := Empty;
   310:    end Complete_Declaration;
```

## src/why/gnat2why-driver.adb:507-610

```ada
   507:    procedure Do_Generate_VCs (E : Entity_Id) is
   508:       Old_Num : constant Natural := Num_Registered_VCs_In_Why3;
   509:    begin
   510:       if Has_Skip_Proof_Annotation (E) then
   511:          Skipped_Proof.Insert (E);
   512:          return;
   513:       end if;
   514:
   515:       --  Check that the global variables are cleared before and after this
   516:       --  routine; this is an assertion rather than a pre/post condition,
   517:       --  because the caller shouldn't really care about it.
   518:
   519:       pragma Assert (No (Current_Subp));
   520:       Current_Subp := E;
   521:
   522:       --  Delete all theories in main so that we start this file with no other
   523:       --  VCs.
   524:
   525:       Why_Sections (WF_Main).Clear;
   526:
   527:       --  Process Hide_Info and Unhide_Info annotations for E
   528:
   529:       Process_Info_Hiding_For_VCs (E);
   530:
   531:       case Ekind (E) is
   532:          when Entry_Kind | E_Function | E_Procedure =>
   533:             if Entity_Spec_In_SPARK (E)
   534:
   535:               --  Ignore hardcoded subprograms
   536:               and then not Is_Hardcoded_Entity (E)
   537:
   538:               --  Ignore invariant procedures and default initial conditions
   539:               and then not Subprogram_Is_Ignored_For_Proof (E)
   540:             then
   541:                declare
   542:                   LSP_Applies : constant Boolean :=
   543:                     Is_Dispatching_Operation (E)
   544:                     and then Present (Find_Dispatching_Type (E));
   545:                begin
   546:                   if LSP_Applies then
   547:                      Ada_Ent_To_Why.Push_Scope (Symbol_Table);
   548:                      Update_Symbol_Table_For_Inherited_Contracts (E);
   549:                   end if;
   550:
   551:                   --  Generate Why3 code to check absence of run-time errors in
   552:                   --  contracts and body.
   553:
   554:                   Generate_VCs_For_Subprogram (E);
   555:
   556:                   --  Generate Why3 code to check LSP for primitive of tagged
   557:                   --  types.
   558:
   559:                   if LSP_Applies then
   560:                      Generate_VCs_For_LSP (E);
   561:                      Ada_Ent_To_Why.Pop_Scope (Symbol_Table);
   562:                   end if;
   563:                end;
   564:             end if;
   565:             Timing_Phase_Completed
   566:               (Timing,
   567:                Entity_To_Subp_Assumption (E),
   568:                "gnat2why.vc_generation");
   569:
   570:          when E_Package                             =>
   571:             Generate_VCs_For_Package_Elaboration (E);
   572:
   573:          when Type_Kind                             =>
   574:
   575:             if Ekind (E) in E_Protected_Type | E_Task_Type
   576:               and then Entity_Spec_In_SPARK (E)
   577:               and then not Is_Derived_Type (E)
   578:             then
   579:                case Ekind (E) is
   580:                   when E_Protected_Type =>
   581:                      Generate_VCs_For_Protected_Type (E);
   582:
   583:                   when E_Task_Type      =>
   584:                      Generate_VCs_For_Task_Type (E);
   585:
   586:                   when others           =>
   587:                      raise Program_Error;
   588:                end case;
   589:             elsif Entity_Spec_In_SPARK (Enclosing_Unit (E))
   590:               and then E = Retysp (E)
   591:             then
   592:                Generate_VCs_For_Type (E);
   593:             end if;
   594:
   595:          when others                                =>
   596:             raise Program_Error;
   597:       end case;
   598:       if Num_Registered_VCs_In_Why3 > Old_Num then
   599:          declare
   600:             File_Name : constant String :=
   601:               Compute_Why3_File_Name (E, ".gnat-json");
   602:          begin
   603:             Print_GNAT_Json_File (File_Name);
   604:             Run_Gnatwhy3 (E, File_Name);
   605:          end;
   606:       end if;
   607:
   608:       Reset_Info_Hiding_For_VCs (E);
   609:       Current_Subp := Empty;
   610:    end Do_Generate_VCs;
```

## src/why/gnat2why-driver.adb:1195-1225

```ada
  1195:        and then Is_Simple_Shift_Or_Rotate (E) not in N_Op_Shift
  1196:
  1197:        --  Ignore hardcoded subprograms
  1198:
  1199:        and then not Is_Hardcoded_Entity (E));
  1200:
  1201:    --------------------------
  1202:    -- Print_GNAT_Json_File --
  1203:    --------------------------
  1204:
  1205:    procedure Print_GNAT_Json_File (Filename : String) is
  1206:       Modules : constant Why_Node_Lists.List := Build_Printing_Plan;
  1207:    begin
  1208:       Open_Current_File (Filename);
  1209:       P (Current_File, "{ ""theory_declarations"" : ");
  1210:       Why_Node_Lists_List_To_Json (Current_File, Modules);
  1211:       P (Current_File, "}");
  1212:       Close_Current_File;
  1213:    end Print_GNAT_Json_File;
  1214:
  1215:    ------------------
  1216:    -- Run_Gnatwhy3 --
  1217:    ------------------
  1218:
  1219:    procedure Run_Gnatwhy3 (E : Entity_Id; Filename : String) is
  1220:       use Ada.Directories;
  1221:       use Ada.Containers;
  1222:       Fn        : constant String := Compose (Current_Directory, Filename);
  1223:       Old_Dir   : constant String := Current_Directory;
  1224:       Why3_Args : String_Lists.List := Gnat2Why_Args.Why3_Args;
  1225:       Command   : GNAT.OS_Lib.String_Access :=
```

## src/why/gnat2why-driver.adb:1318-1355

```ada
  1318:       --  upfront, so that we do not depend too much on the order of the list
  1319:       --  of entities.
  1320:
  1321:       ----------------------
  1322:       -- For_All_Entities --
  1323:       ----------------------
  1324:
  1325:       procedure For_All_Entities
  1326:         (Process : not null access procedure (E : Entity_Id)) is
  1327:       begin
  1328:          for E of Entities_To_Translate loop
  1329:
  1330:             --  Set error node so that bugbox information will be correct
  1331:
  1332:             Current_Error_Node := E;
  1333:             Process (E);
  1334:          end loop;
  1335:       end For_All_Entities;
  1336:
  1337:       ------------------
  1338:       -- Generate_VCs --
  1339:       ------------------
  1340:
  1341:       procedure Generate_VCs (E : Entity_Id) is
  1342:       begin
  1343:          if Ekind (E)
  1344:             in Entry_Kind | E_Function | E_Package | E_Procedure | Type_Kind
  1345:          then
  1346:             case Analysis_Status'
  1347:                 (Analysis_Requested (E, With_Inlined => False))
  1348:             is
  1349:                when Analyzed                                            =>
  1350:                   Do_Generate_VCs (E);
  1351:
  1352:                --  This subprogram is only analyzed contextually. In the case
  1353:                --  that it is referenced without being called (by taking its
  1354:                --  address for example) or if all calls are in non-SPARK code,
  1355:                --  the subprogram may not be analyzed at all.
```

## src/why/gnat2why-driver.adb:1415-1457

```ada
  1415:       --  Translation of the __HEAP is hardcoded into the
  1416:       --  _gnatprove_standard.Main module.
  1417:       Translated_Object_Names.Insert
  1418:         (To_Entity_Name (SPARK_Xrefs.Name_Of_Heap_Variable));
  1419:
  1420:       --  Store information for entities
  1421:
  1422:       For_All_Entities (Store_Information_For_Entity'Access);
  1423:
  1424:       For_All_Entities (Register_Symbol'Access);
  1425:
  1426:       --  Declare distinct constants for all Ada exceptions
  1427:
  1428:       Translate_Exceptions;
  1429:
  1430:       --  Translate Ada entities into Why3
  1431:
  1432:       For_All_Entities (Translate_Entity'Access);
  1433:
  1434:       --  For all objects whose declaration is not visible (has not been
  1435:       --  translated to Why), we generate a dummy declaration. This must
  1436:       --  be done after translating above entities.
  1437:
  1438:       For_All_Entities (Translate_Hidden_Globals'Access);
  1439:
  1440:       For_All_Entities (Complete_Declaration'Access);
  1441:
  1442:       --  Generate VCs for entities of unit. This must follow the generation of
  1443:       --  modules for entities, so that all completions for deferred constants
  1444:       --  and expression functions are defined.
  1445:
  1446:       For_All_Entities (Generate_VCs'Access);
  1447:       Check_Safe_Guard_Cycles;
  1448:
  1449:       --  Clear global data that is no longer be needed to leave more memory
  1450:       --  for solvers.
  1451:       Translated_Object_Names.Clear;
  1452:       Translated_Object_Names.Reserve_Capacity (0);
  1453:
  1454:       Why.Gen.Names.Free;
  1455:       Why.Atree.Free;
  1456:    end Translate_CUnit;
  1457:
```

## src/why/gnat2why-driver.adb:1462-1590

```ada
  1462:    procedure Translate_Entity (E : Entity_Id) is
  1463:
  1464:       procedure Generate_Empty_Axiom_Theory (E : Entity_Id);
  1465:       --  Generates an empty theory for the axiom related to E. This is done
  1466:       --  for every entity for which there is no axiom theory generated, so
  1467:       --  that modules for VC generation can consistently include the axiom
  1468:       --  theory of all they entities they use.
  1469:
  1470:       ---------------------------------
  1471:       -- Generate_Empty_Axiom_Theory --
  1472:       ---------------------------------
  1473:
  1474:       procedure Generate_Empty_Axiom_Theory (E : Entity_Id) is
  1475:          Th : Theory_UC;
  1476:       begin
  1477:          Th :=
  1478:            Open_Theory
  1479:              (WF_Context,
  1480:               E_Module (E, Axiom),
  1481:               Comment =>
  1482:                 "Module giving an empty axiom for the entity "
  1483:                 & """"
  1484:                 & Get_Name_String (Chars (E))
  1485:                 & """"
  1486:                 & (if Sloc (E) > 0
  1487:                    then " defined at " & Build_Location_String (Sloc (E))
  1488:                    else "")
  1489:                 & ", created in "
  1490:                 & GNAT.Source_Info.Enclosing_Entity);
  1491:          Close_Theory (Th, Kind => Standalone_Theory);
  1492:       end Generate_Empty_Axiom_Theory;
  1493:
  1494:       --  Start of processing for Translate_Entity
  1495:
  1496:    begin
  1497:       --  Check that the global variables are cleared before and after this
  1498:       --  routine; this is an assertion rather than a pre/post condition,
  1499:       --  because the caller shouldn't really care about it.
  1500:
  1501:       pragma Assert (No (Current_Subp));
  1502:       Current_Subp := E;
  1503:
  1504:       case Ekind (E) is
  1505:          when Type_Kind                          =>
  1506:
  1507:             --  For a type with partial and full view, both entities will be
  1508:             --  encountered here, but only one should be translated. We pick
  1509:             --  the one with the most information that's still in SPARK.
  1510:
  1511:             if Retysp (E) = E then
  1512:                --  Partial views of private types should not be
  1513:                --  translated if the underlying type is not in SPARK,
  1514:                --  otherwise we end up with two definitions for the same
  1515:                --  private type.
  1516:
  1517:                Translate_Type (E);
  1518:             end if;
  1519:
  1520:          when Object_Kind                        =>
  1521:
  1522:             --  Ignore discriminals, i.e. objects that occur for discriminants
  1523:             --  of record types, protected types, and task types.
  1524:
  1525:             if Is_Discriminal (E) then
  1526:                Current_Subp := Empty;
  1527:                return;
  1528:             end if;
  1529:
  1530:             --  Variables that are part of a protected object are not
  1531:             --  translated separately.
  1532:
  1533:             if Is_Protected_Component_Or_Discr_Or_Part_Of (E) then
  1534:                null;
  1535:
  1536:             --  Constants and variables are translated differently
  1537:
  1538:             elsif not Is_Mutable_In_Why (E) then
  1539:                if Ekind (E) = E_Constant then
  1540:                   if Is_Partial_View (E) then
  1541:                      Translate_Constant (E);
  1542:                      if not Entity_In_SPARK (Full_View (E)) then
  1543:                         Translate_Constant_Value (E);
  1544:                      end if;
  1545:                   elsif Is_Full_View (E) then
  1546:                      Translate_Constant_Value (E);
  1547:                   else
  1548:                      Translate_Constant (E);
  1549:                      Translate_Constant_Value (E);
  1550:                   end if;
  1551:                else
  1552:                   Translate_Constant (E);
  1553:                   Generate_Empty_Axiom_Theory (E);
  1554:                end if;
  1555:
  1556:             --  We translate private constants of access type in the partial
  1557:             --  declaration. This should avoid translating them twice (in the
  1558:             --  partial and full view). The following case represents these
  1559:             --  objects because they are considered as mutable while they are
  1560:             --  constants and may have a partial and full view. We chose the
  1561:             --  partial view bacause the full view may not be in SPARK.
  1562:
  1563:             elsif Is_Full_View (E) then
  1564:                pragma Assert (Ekind (E) = E_Constant);
  1565:
  1566:             else
  1567:                Translate_Variable (E);
  1568:                Generate_Empty_Axiom_Theory (E);
  1569:             end if;
  1570:
  1571:          --  Generate a logic function for Ada subprograms
  1572:
  1573:          when E_Entry | E_Function | E_Procedure =>
  1574:             if Is_Translated_Subprogram (E) then
  1575:                Translate_Subprogram_Spec (E);
  1576:             end if;
  1577:
  1578:          when E_Loop                             =>
  1579:             Translate_Loop_Entity (E);
  1580:             Generate_Empty_Axiom_Theory (E);
  1581:
  1582:          when E_Package                          =>
  1583:             null;
  1584:
  1585:          when others                             =>
  1586:             raise Program_Error;
  1587:       end case;
  1588:
  1589:       Current_Subp := Empty;
  1590:    end Translate_Entity;
```

## src/why/gnat2why-driver.adb:1381-1445

```ada
  1381:       procedure Register_Symbol (E : Entity_Id) is
  1382:       begin
  1383:          case Ekind (E) is
  1384:             when E_Entry | E_Function | E_Procedure =>
  1385:                if Is_Translated_Subprogram (E) then
  1386:                   Ada_Ent_To_Why.Insert
  1387:                     (Symbol_Table,
  1388:                      E,
  1389:                      Mk_Item_Of_Entity
  1390:                        (E, Hide_Info => Expr_Fun_Hidden_By_Default (E)));
  1391:                end if;
  1392:
  1393:             when Object_Kind                        =>
  1394:
  1395:                if Is_Discriminal (E)
  1396:                  or else Is_Protected_Component_Or_Discr_Or_Part_Of (E)
  1397:                  or else
  1398:                    (Ekind (E) = E_Constant
  1399:                     and then Is_Partial_View (E)
  1400:                     and then Entity_In_SPARK (Full_View (E)))
  1401:                then
  1402:                   return;
  1403:                end if;
  1404:
  1405:                Insert_Item (E, Mk_Item_Of_Entity (E));
  1406:
  1407:             when others                             =>
  1408:                null;
  1409:          end case;
  1410:       end Register_Symbol;
  1411:
  1412:       --  Start of processing for Translate_CUnit
  1413:
  1414:    begin
  1415:       --  Translation of the __HEAP is hardcoded into the
  1416:       --  _gnatprove_standard.Main module.
  1417:       Translated_Object_Names.Insert
  1418:         (To_Entity_Name (SPARK_Xrefs.Name_Of_Heap_Variable));
  1419:
  1420:       --  Store information for entities
  1421:
  1422:       For_All_Entities (Store_Information_For_Entity'Access);
  1423:
  1424:       For_All_Entities (Register_Symbol'Access);
  1425:
  1426:       --  Declare distinct constants for all Ada exceptions
  1427:
  1428:       Translate_Exceptions;
  1429:
  1430:       --  Translate Ada entities into Why3
  1431:
  1432:       For_All_Entities (Translate_Entity'Access);
  1433:
  1434:       --  For all objects whose declaration is not visible (has not been
  1435:       --  translated to Why), we generate a dummy declaration. This must
  1436:       --  be done after translating above entities.
  1437:
  1438:       For_All_Entities (Translate_Hidden_Globals'Access);
  1439:
  1440:       For_All_Entities (Complete_Declaration'Access);
  1441:
  1442:       --  Generate VCs for entities of unit. This must follow the generation of
  1443:       --  modules for entities, so that all completions for deferred constants
  1444:       --  and expression functions are defined.
  1445:
```

## src/why/gnat2why-driver.adb:1593-1638

```ada
  1593:    -- Translate_Hidden_Globals --
  1594:    ------------------------------
  1595:
  1596:    procedure Translate_Hidden_Globals (E : Entity_Id) is
  1597:    begin
  1598:       --  For packages we don't translate objects from the RHS of their
  1599:       --  (generated) Initializes contract, because such objects are either
  1600:       --  visible (and thus translated anyway) or are pulled by subprograms
  1601:       --  called from the Initial_Condition (and thus already translated).
  1602:       if (case Ekind (E) is
  1603:             when Entry_Kind | E_Task_Type => True,
  1604:             when E_Function | E_Procedure => Is_Translated_Subprogram (E),
  1605:             when others                   => False)
  1606:       then
  1607:          declare
  1608:             Reads       : Flow_Types.Flow_Id_Sets.Set;
  1609:             Writes      : Flow_Types.Flow_Id_Sets.Set;
  1610:             Unused_Name : Name_Sets.Cursor;
  1611:             Inserted    : Boolean;
  1612:          begin
  1613:             --  Collect global variables potentially read and written
  1614:             Flow_Utility.Get_Proof_Globals
  1615:               (Subprogram      => E,
  1616:                Reads           => Reads,
  1617:                Writes          => Writes,
  1618:                Erase_Constants => True);
  1619:
  1620:             Reads.Union (Writes);
  1621:
  1622:             for G of Reads loop
  1623:                if G.Kind = Magic_String then
  1624:                   pragma Assert (Is_Opaque_For_Proof (G));
  1625:
  1626:                   Translated_Object_Names.Insert
  1627:                     (New_Item => G.Name,
  1628:                      Position => Unused_Name,
  1629:                      Inserted => Inserted);
  1630:
  1631:                   if Inserted then
  1632:                      Translate_External_Object (G.Name);
  1633:                   end if;
  1634:                end if;
  1635:             end loop;
  1636:          end;
  1637:       end if;
  1638:    end Translate_Hidden_Globals;
```

## src/why/gnat2why-expr-loops-inv.adb:175-198

```ada
   175:    use Write_Trees;
   176:
   177:    ------------------------
   178:    --  Local Subprograms --
   179:    ------------------------
   180:
   181:    function Equality_Of_Preserved_Components
   182:      (Loop_Idx  : Opt_E_Loop_Parameter_Id;
   183:       Low_Id    : W_Expr_Id;
   184:       High_Id   : W_Expr_Id;
   185:       Is_Rev    : Boolean;
   186:       Loop_Vars : Flow_Id_Sets.Set;
   187:       Expr      : W_Expr_Id;
   188:       At_Entry  : W_Expr_Id;
   189:       Expr_Ty   : Type_Kind_Id;
   190:       Status    : Write_Status_Access;
   191:       Only_Vars : Boolean := True;
   192:       For_Valid : Boolean := False) return W_Pred_Id
   193:    with
   194:      Pre =>
   195:        Status /= null
   196:        and then Status.Kind /= Discard
   197:        and then (if For_Valid then Only_Vars);
   198:    --  Compute a predicate which assumes preservation of every unmodified
```

## src/why/gnat2why-expr-loops-inv.adb:775-815

```ada
   775:          when Discard           =>
   776:             raise Program_Error;
   777:
   778:          when Not_Written       =>
   779:
   780:             Preserved_Components :=
   781:               +New_And_Expr
   782:                  (Left   => +Preserved_Components,
   783:                   Right  =>
   784:                     +New_Comparison
   785:                        (Symbol => Why_Eq,
   786:                         Left   => Expr,
   787:                         Right  => At_Entry,
   788:                         Domain => EW_Pred),
   789:                   Domain => EW_Pred);
   790:
   791:          when Entire_Object     =>
   792:
   793:             --  Even when the entire object is written, the bounds of arrays
   794:             --  and the values of immutable discriminants are preserved.
   795:             --  Assume it if Only_Vars is False.
   796:
   797:             if not Only_Vars
   798:               and then
   799:                 (not Has_Discriminants (Expr_Ty)
   800:                  or else not Has_Defaulted_Discriminants (Expr_Ty))
   801:             then
   802:                Preserved_Components := Preserve_Bounds_Or_Discriminants;
   803:             else
   804:                Preserved_Components := True_Pred;
   805:             end if;
   806:
   807:          when Record_Components =>
   808:
   809:             --  As discriminants may occur in bounds of types of other fields,
   810:             --  store them in the Symbol_Table.
   811:
   812:             Ada_Ent_To_Why.Push_Scope (Symbol_Table);
   813:
   814:             declare
   815:                Discrs : constant Natural :=
```

## src/why/gnat2why-expr-loops-inv.adb:1079-1398

```ada
  1079:    function Generate_Frame_Condition
  1080:      (Loop_Stmt       : N_Loop_Statement_Id;
  1081:       Low_Id          : W_Expr_Id;
  1082:       High_Id         : W_Expr_Id;
  1083:       Frame_Constants : Entity_Sets.Set) return W_Pred_Id
  1084:    is
  1085:       use Write_Status_Maps;
  1086:       Loop_Id         : constant E_Loop_Id := Entity (Identifier (Loop_Stmt));
  1087:       Param_Spec      : constant Opt_N_Loop_Parameter_Specification_Id :=
  1088:         (if Present (Iteration_Scheme (Loop_Stmt))
  1089:          then Loop_Parameter_Specification (Iteration_Scheme (Loop_Stmt))
  1090:          else Types.Empty);
  1091:       Loop_Index      : constant Opt_E_Loop_Parameter_Id :=
  1092:         (if Present (Param_Spec)
  1093:          then Defining_Identifier (Param_Spec)
  1094:          else Types.Empty);
  1095:       Is_Reverse      : constant Boolean :=
  1096:         Present (Param_Spec) and then Reverse_Present (Param_Spec);
  1097:       Scope           : constant Unit_Kind_Id := Enclosing_Unit (Loop_Id);
  1098:       Modified        : constant Flow_Id_Sets.Set :=
  1099:         Flow_Utility.Get_Loop_Writes (Loop_Id);
  1100:       N               : Node_Id;
  1101:       Dyn_Types_Inv   : W_Pred_Id := True_Pred;
  1102:       Loop_Writes     : Map;
  1103:       Invalid_Objects : Node_Sets.Set;
  1104:
  1105:    begin
  1106:       Get_Loop_Writes (Loop_Stmt, Loop_Writes, Invalid_Objects);
  1107:
  1108:       --  Sanity checking:
  1109:       --  Check that we have at least every variable modified in the loop.
  1110:
  1111:       for F of Modified loop
  1112:
  1113:          --  We do not care about Magic_Strings which are translated as
  1114:          --  private in Why.
  1115:
  1116:          if F.Kind = Direct_Mapping then
  1117:
  1118:             --  We don't care about constant objects and objects
  1119:             --  with asynchronous readers as we don't want to assume
  1120:             --  anything on them. We also don't consider abstract
  1121:             --  states.
  1122:             --  For loops inside a single task, flow analysis returns the
  1123:             --  task object as written. We don't care as single
  1124:             --  tasks can't have (mutable) discriminants and thus cannot
  1125:             --  be modified from a proof point of view. We still want to
  1126:             --  issue an error if flow analysis returns a task with
  1127:             --  mutable discriminants that we did not find.
  1128:
  1129:             declare
  1130:                E : constant Entity_Id := Get_Direct_Mapping_Id (F);
  1131:             begin
  1132:                if not Loop_Writes.Contains (E)
  1133:                  and then Is_Object (E)
  1134:                  and then Is_Mutable_In_Why (E)
  1135:                  and then not Has_Async_Writers (F)
  1136:                  and then
  1137:                    (not Is_Task_Type (Etype (E))
  1138:                     or else Has_Discriminants (Etype (E)))
  1139:                then
  1140:                   Ada.Text_IO.Put_Line
  1141:                     ("error in computation of loop frame condition for "
  1142:                      & Full_Name (Get_Direct_Mapping_Id (F)));
  1143:                   raise Program_Error;
  1144:                end if;
  1145:             end;
  1146:          end if;
  1147:       end loop;
  1148:
  1149:       --  Assume the dynamic invariant and frame condition of every variable in
  1150:       --  Loop_Writes if it was not discarded.
  1151:       --  Dynamic invariant is omitted for Not_Written variables, as
  1152:       --  it falls out from complete preservation.
  1153:
  1154:       for C in Loop_Writes.Iterate loop
  1155:          N := Key (C);
  1156:
  1157:          declare
  1158:             Status : Write_Status_Access := Element (C);
  1159:          begin
  1160:
  1161:             if Status.Kind /= Discard then
  1162:
  1163:                pragma
  1164:                  Assert
  1165:                    (Nkind (N) in N_Entity
  1166:                     and then Is_Object (N)
  1167:                     and then Is_Mutable_In_Why (N));
  1168:
  1169:                declare
  1170:                   Expr        : constant W_Term_Id :=
  1171:                     +Transform_Identifier (Body_Params, N, N, EW_Term);
  1172:                   Init_Id     : constant W_Expr_Id :=
  1173:                     Get_Init_Id_From_Object (N, Ref_Allowed => True);
  1174:                   Initialized : constant Boolean :=
  1175:                     (if Is_Declared_In_Unit (N, Scope)
  1176:                      then Is_Initialized_At_Decl (N)
  1177:                      else Is_Initialized_In_Scope (N, Scope));
  1178:                   Brower_Id   : constant W_Identifier_Id :=
  1179:                     (if Is_Local_Borrower (N)
  1180:                      then Get_Brower_At_End (N)
  1181:                      else Why_Empty);
  1182:
  1183:                begin
  1184:                   Dyn_Types_Inv :=
  1185:                     New_And_Pred
  1186:                       (Conjuncts =>
  1187:                          (1 => Dyn_Types_Inv,
  1188:
  1189:                           --  Compute the dynamic property of Expr, taking into
  1190:                           --  account its initialization if it corresponds to a
  1191:                           --  variable taken as input in the current
  1192:                           --  subprogram.
  1193:
  1194:                           2 =>
  1195:                             (if Status.Kind = Not_Written
  1196:                              then True_Pred
  1197:                              else
  1198:                                Compute_Dynamic_Inv_And_Initialization
  1199:                                  (Expr        => Expr,
  1200:                                   Ty          => Etype (N),
  1201:                                   Params      => Body_Params,
  1202:                                   Initialized =>
  1203:                                     (if Init_Id /= Why_Empty
  1204:                                      then +Init_Id
  1205:                                      elsif Initialized
  1206:                                      then True_Term
  1207:                                      else False_Term),
  1208:                                   Valid       =>
  1209:                                     Get_Valid_Id_From_Object
  1210:                                       (N, Ref_Allowed => True))),
  1211:
  1212:                           --  If N is a local borrower and it is modified at
  1213:                           --  top-level in the loop (we have a reborrow), also
  1214:                           --  assume the dynamic invariant of its value at the
  1215:                           --  end of the borrow and link the values of their
  1216:                           --  is_null fields.
  1217:                           --  The address of the borrower is necessarily
  1218:                           --  initialized at the end of the borrow.
  1219:
  1220:                           3 =>
  1221:                             (if Is_Local_Borrower (N)
  1222:                                and then Status.Kind = Entire_Object
  1223:                              then
  1224:                                New_And_Pred
  1225:                                  (Conjuncts =>
  1226:                                     (1 =>
  1227:                                        Compute_Dynamic_Inv_And_Initialization
  1228:                                          (Expr        =>
  1229:                                             New_Deref
  1230:                                               (Right => Brower_Id,
  1231:                                                Typ   => Get_Typ (Brower_Id)),
  1232:                                           Ty          => Etype (N),
  1233:                                           Params      => Body_Params,
  1234:                                           Initialized => True_Term),
  1235:                                      2 =>
  1236:                                        New_Comparison
  1237:                                          (Symbol => Why_Eq,
  1238:                                           Left   =>
  1239:                                             New_Pointer_Is_Null_Access
  1240:                                               (Etype (N),
  1241:                                                New_Deref
  1242:                                                  (Right => Brower_Id,
  1243:                                                   Typ   =>
  1244:                                                     Get_Typ (Brower_Id))),
  1245:                                           Right  =>
  1246:                                             New_Pointer_Is_Null_Access
  1247:                                               (Etype (N), Expr)),
  1248:                                      3 =>
  1249:                                        (if Obj_Has_Relaxed_Init (N)
  1250:                                         then
  1251:                                           Pred_Of_Boolean_Term
  1252:                                             (New_Init_Attribute_Access
  1253:                                                (Name =>
  1254:                                                   New_Deref
  1255:                                                     (Right => Brower_Id,
  1256:                                                      Typ   =>
  1257:                                                        Get_Typ (Brower_Id)),
  1258:                                                 E    => Etype (N)))
  1259:                                         else True_Pred)))
  1260:                              else True_Pred),
  1261:
  1262:                           --  Unmodified fields are preserved. Use
  1263:                           --  No_Checks to avoid spurious checks on values with
  1264:                           --  Relaxed_Initialization.
  1265:                           --  ??? We could preserve the move tree of preserved
  1266:                           --  components (is_moved_or_reclaimed before the loop
  1267:                           --  should imply is_moved_or_reclaimed in the loop).
  1268:
  1269:                           4 =>
  1270:                             (Equality_Of_Preserved_Components
  1271:                                (Loop_Idx  => Loop_Index,
  1272:                                 Low_Id    => Low_Id,
  1273:                                 High_Id   => High_Id,
  1274:                                 Is_Rev    => Is_Reverse,
  1275:                                 Loop_Vars => Modified,
  1276:                                 Expr      => +Expr,
  1277:                                 At_Entry  =>
  1278:                                   +Name_For_Loop_Entry
  1279:                                      (Expr      => N,
  1280:                                       Loop_Id   => Loop_Id,
  1281:                                       No_Checks => True),
  1282:                                 Expr_Ty   => Retysp (Etype (N)),
  1283:                                 Status    => Status)),
  1284:
  1285:                           --  If Loop_Id has a validity flag, generate
  1286:                           --  preservation of validity flags.
  1287:                           --
  1288:                           --  If Loop_Id cannot become invalid in the loop,
  1289:                           --  also add:
  1290:                           --
  1291:                           --    is_valid Loop_Id_valid_flag'Loop_Entry
  1292:                           --       -> is_valid Loop_Id'Valid
  1293:                           --
  1294:                           --  It is useful to avoid the need for loop
  1295:                           --  invariants to preserve the validity of already
  1296:                           --  entirely valid objects.
  1297:
  1298:                           5 =>
  1299:                             (if Object_Has_Valid_Id (N)
  1300:                              then
  1301:                                New_And_Pred
  1302:                                  (Left  =>
  1303:                                     Equality_Of_Preserved_Components
  1304:                                       (Loop_Idx  => Loop_Index,
  1305:                                        Low_Id    => Low_Id,
  1306:                                        High_Id   => High_Id,
  1307:                                        Is_Rev    => Is_Reverse,
  1308:                                        Loop_Vars => Modified,
  1309:                                        Expr      =>
  1310:                                          +Get_Valid_Id_From_Object
  1311:                                             (N, Body_Params.Ref_Allowed),
  1312:                                        At_Entry  =>
  1313:                                          +Get_Valid_Flag_For_Id
  1314:                                             (Name_For_Loop_Entry
  1315:                                                (Expr      => N,
  1316:                                                 Loop_Id   => Loop_Id,
  1317:                                                 No_Checks => True),
  1318:                                              Etype (N)),
  1319:                                        Expr_Ty   => Retysp (Etype (N)),
  1320:                                        Status    => Status,
  1321:                                        For_Valid => True),
  1322:                                   Right =>
  1323:                                     (if Status.Kind
  1324:                                         not in Not_Written | Discard
  1325:                                        and then
  1326:                                          not Invalid_Objects.Contains
  1327:                                                (Unique_Entity (N))
  1328:                                      then
  1329:                                        New_Conditional
  1330:                                          (Condition =>
  1331:                                             +New_Is_Valid_Call_For_Expr
  1332:                                                (Tree   =>
  1333:                                                   +Get_Valid_Flag_For_Id
  1334:                                                      (Name_For_Loop_Entry
  1335:                                                         (Expr      => N,
  1336:                                                          Loop_Id   => Loop_Id,
  1337:                                                          No_Checks => True),
  1338:                                                       Etype (N)),
  1339:                                                 Ty     => Etype (N),
  1340:                                                 Expr   =>
  1341:                                                   +Name_For_Loop_Entry
  1342:                                                      (Expr      => N,
  1343:                                                       Loop_Id   => Loop_Id,
  1344:                                                       No_Checks => True),
  1345:                                                 Domain => EW_Pred),
  1346:                                           Then_Part =>
  1347:                                             +New_Is_Valid_Call_For_Expr
  1348:                                                (Tree   =>
  1349:                                                   +Get_Valid_Id_From_Object
  1350:                                                      (N,
  1351:                                                       Body_Params.Ref_Allowed),
  1352:                                                 Ty     => Etype (N),
  1353:                                                 Expr   => +Expr,
  1354:                                                 Domain => EW_Pred))
  1355:                                      else True_Pred))
  1356:                              else True_Pred)));
  1357:                end;
  1358:             end if;
  1359:
  1360:             Finalize (Status);
  1361:          end;
  1362:       end loop;
  1363:
  1364:       --  Assume value of scalar constants declared just before the invariant
  1365:
  1366:       for E of Frame_Constants loop
  1367:          pragma Assert (Has_Scalar_Type (Etype (E)));
  1368:
  1369:          declare
  1370:             Typ  : constant W_Type_Id := Why_Type_Of_Entity (E);
  1371:             Decl : constant N_Object_Declaration_Id :=
  1372:               Enclosing_Declaration (E);
  1373:             Expr : constant W_Expr_Id :=
  1374:               +Transform_Expr
  1375:                  (Expression (Decl), Typ, EW_Pterm, Params => Body_Params);
  1376:             L_Id : constant W_Expr_Id :=
  1377:               Transform_Identifier
  1378:                 (Params => Body_Params,
  1379:                  Expr   => E,
  1380:                  Ent    => E,
  1381:                  Domain => EW_Term);
  1382:
  1383:          begin
  1384:
  1385:             Dyn_Types_Inv :=
  1386:               New_And_Pred
  1387:                 (Conjuncts =>
  1388:                    (1 => Dyn_Types_Inv,
  1389:                     2 =>
  1390:                       New_Call
  1391:                         (Name => Why_Eq,
  1392:                          Typ  => EW_Bool_Type,
  1393:                          Args => (Expr, L_Id))));
  1394:          end;
  1395:       end loop;
  1396:
  1397:       return Dyn_Types_Inv;
  1398:    end Generate_Frame_Condition;
```

## src/why/gnat2why-expr-loops-inv.adb:1704-1745

```ada
  1704:    procedure Process_Statement
  1705:      (N                 : Node_Id;
  1706:       Loop_Writes       : in out Write_Status_Maps.Map;
  1707:       Invalid_Objects   : in out Node_Sets.Set;
  1708:       Relevant_Vertices : Local_CFG.Vertex_Sets.Set;
  1709:       After_Inv         : Boolean;
  1710:       In_Nested         : Boolean) is
  1711:    begin
  1712:       case Nkind (N) is
  1713:          when N_Assignment_Statement                              =>
  1714:             declare
  1715:                Lvalue   : constant Entity_Id := SPARK_Atree.Name (N);
  1716:                Rvalue   : constant Node_Id := SPARK_Atree.Expression (N);
  1717:                Relevant : constant Boolean :=
  1718:                  Relevant_Vertices.Contains (Local_CFG.Starting_Vertex (N));
  1719:             begin
  1720:                Write_Expr
  1721:                  (New_Write     => Lvalue,
  1722:                   Loop_Writes   => Loop_Writes,
  1723:                   After_Inv     => After_Inv,
  1724:                   Relevant_Path => Relevant);
  1725:
  1726:                --  If the validity flag of the Rvalue is transfered to Lvalue,
  1727:                --  add the root object to Invalid_Objects.
  1728:
  1729:                if Propagates_Validity_Flag (N)
  1730:                  and then Is_Potentially_Invalid_Expr (Rvalue)
  1731:                then
  1732:                   Invalid_Objects.Include
  1733:                     (Unique_Entity (Get_Root_Object (Lvalue)));
  1734:                end if;
  1735:
  1736:                if Nkind (Rvalue) = N_Function_Call then
  1737:                   Process_Call
  1738:                     (Call            => Rvalue,
  1739:                      Loop_Writes     => Loop_Writes,
  1740:                      Invalid_Objects => Invalid_Objects,
  1741:                      Relevant_Path   => Relevant,
  1742:                      After_Inv       => After_Inv);
  1743:                end if;
  1744:
  1745:             end;
```

## src/why/gnat2why-expr-loops-inv.adb:1940-1976

```ada
  1940:                In_Nested);
  1941:
  1942:          when N_Loop_Statement                                    =>
  1943:
  1944:             --  Discard the loop index of nested loops if any
  1945:
  1946:             declare
  1947:                Scheme : constant Opt_N_Iteration_Scheme_Id :=
  1948:                  Iteration_Scheme (N);
  1949:                Spec   : constant Node_Id :=
  1950:                  (if No (Scheme) or else Present (Condition (Scheme))
  1951:                   then Types.Empty
  1952:                   elsif Present (Loop_Parameter_Specification (Scheme))
  1953:                   then Loop_Parameter_Specification (Scheme)
  1954:                   else Iterator_Specification (Scheme));
  1955:
  1956:             begin
  1957:                if Present (Spec) then
  1958:                   Write_Entity
  1959:                     (New_Write      => Defining_Identifier (Spec),
  1960:                      Loop_Writes    => Loop_Writes,
  1961:                      Discard_Writes => True,
  1962:                      Relevant_Path  => True); --  Do not care since we discard
  1963:
  1964:                end if;
  1965:             end;
  1966:
  1967:             Process_Statement_List
  1968:               (Statements (N),
  1969:                Loop_Writes,
  1970:                Invalid_Objects,
  1971:                Relevant_Vertices,
  1972:                After_Inv,
  1973:                In_Nested => True);
  1974:
  1975:          --  Discard writes to variables local to a block statement
  1976:
```

## src/why/gnat2why-expr-loops-inv.adb:2291-2350

```ada
  2291:       ----------------------
  2292:
  2293:       procedure One_Level_Update
  2294:         (New_Write      : Object_Kind_Id;
  2295:          Writes         : in out Write_Status_Maps.Map;
  2296:          Expected_Kind  : Write_Kind;
  2297:          Updated_Status : out Write_Status_Access)
  2298:       is
  2299:          Inserted : Boolean;
  2300:          C        : Cursor := Writes.Find (New_Write);
  2301:       begin
  2302:          if C = No_Element then
  2303:
  2304:             --  New_Write does not exist in Writes; create it.
  2305:
  2306:             Writes.Insert
  2307:               (Key      => New_Write,
  2308:                New_Item => New_Status (New_Write, Expected_Kind),
  2309:                Inserted => Inserted,
  2310:                Position => C);
  2311:
  2312:             pragma Assert (Inserted);
  2313:
  2314:          --  Old status if larger for implicit ordering, nothing to do
  2315:
  2316:          elsif Expected_Kind = Not_Written
  2317:            or else Element (C).Kind = Discard
  2318:            or else
  2319:              (Expected_Kind /= Discard and Element (C).Kind = Entire_Object)
  2320:            or else Expected_Kind = Element (C).Kind
  2321:          then
  2322:             null;
  2323:
  2324:          --  New status if strictly larger for implicit ordering, update it
  2325:
  2326:          elsif Expected_Kind in Entire_Object | Discard
  2327:            or else Element (C).Kind = Not_Written
  2328:          then
  2329:
  2330:             declare
  2331:                Old_Status : Write_Status_Access renames Writes (C);
  2332:             begin
  2333:                Finalize (Old_Status);
  2334:             end;
  2335:
  2336:             Writes.Replace_Element
  2337:               (Position => C,
  2338:                New_Item => New_Status (New_Write, Expected_Kind));
  2339:
  2340:          --  Sanity check: the kind of a variable cannot change between
  2341:          --  type-specific kinds (equivalent to being incomparable for implicit
  2342:          --  ordering).
  2343:
  2344:          else
  2345:             pragma Assert (Element (C).Kind = Expected_Kind);
  2346:          end if;
  2347:
  2348:          Updated_Status := Element (C);
  2349:       end One_Level_Update;
  2350:
```

## src/why/gnat2why-expr-loops-inv.adb:2398-2408

```ada
  2398:             --  For identifiers, update the corresponding status.
  2399:
  2400:             when N_Identifier | N_Expanded_Name                  =>
  2401:                One_Level_Update
  2402:                  (New_Write      => Entity (New_Write),
  2403:                   Writes         => Writes,
  2404:                   Expected_Kind  => Expected_Kind,
  2405:                   Updated_Status => Updated_Status);
  2406:
  2407:                Expected_Type := Retysp (Etype (New_Write));
  2408:
```

## src/why/gnat2why-expr-loops-inv.adb:327-343

```ada
   327:    function Equality_Of_Preserved_Components
   328:      (Loop_Idx  : Opt_E_Loop_Parameter_Id;
   329:       Low_Id    : W_Expr_Id;
   330:       High_Id   : W_Expr_Id;
   331:       Is_Rev    : Boolean;
   332:       Loop_Vars : Flow_Id_Sets.Set;
   333:       Expr      : W_Expr_Id;
   334:       At_Entry  : W_Expr_Id;
   335:       Expr_Ty   : Type_Kind_Id;
   336:       Status    : Write_Status_Access;
   337:       Only_Vars : Boolean := True;
   338:       For_Valid : Boolean := False) return W_Pred_Id
   339:    is
   340:       Preserved_Components : W_Pred_Id := True_Pred;
   341:
   342:       function Build_Array_Constraints
   343:         (Updates : Array_Constraints_Maps.Map; Indices : W_Expr_Array)
```

## src/why/gnat2why-expr-loops-inv.adb:1404-1460

```ada
  1404:    procedure Get_Loop_Writes
  1405:      (Loop_Stmt       : N_Loop_Statement_Id;
  1406:       Loop_Writes     : out Write_Status_Maps.Map;
  1407:       Invalid_Objects : out Node_Sets.Set)
  1408:    is
  1409:       Stmts     : constant List_Id := Statements (Loop_Stmt);
  1410:       Scheme    : constant Opt_N_Iteration_Scheme_Id :=
  1411:         Iteration_Scheme (Loop_Stmt);
  1412:       After_Inv : Boolean := True;
  1413:       --  Only try to keep variables declared inside the loop as completely
  1414:       --  written instead of discarded if there is a loop invariant (and this
  1415:       --  will only impact variables declared before the loop invariant).
  1416:       --  Otherwise, there is no meaningful use for these variables in the
  1417:       --  frame condition.
  1418:
  1419:       Flat_Body : constant Node_Lists.List :=
  1420:         Get_Flat_Statement_And_Declaration_List (Stmts);
  1421:       --  Flattened loop body.
  1422:
  1423:       Relevant_Vertices : Local_CFG.Vertex_Sets.Set;
  1424:       --  To store vertices of loop's local CFG that can lead back to
  1425:       --  invariant. This let us detect which writes can actually happen
  1426:       --  before the invariant is reached (again). Other writes are
  1427:       --  not actually relevant modifications of variables
  1428:       --  for computing the frame condition.
  1429:
  1430:    begin
  1431:       --  The loop index is completely written
  1432:
  1433:       if Present (Scheme) and then No (Condition (Scheme)) then
  1434:          declare
  1435:             Loop_Param_Ent : E_Loop_Parameter_Id;
  1436:          begin
  1437:             if Present (Loop_Parameter_Specification (Scheme)) then
  1438:                Loop_Param_Ent :=
  1439:                  Defining_Identifier (Loop_Parameter_Specification (Scheme));
  1440:             else
  1441:                pragma Assert (Present (Iterator_Specification (Scheme)));
  1442:                Loop_Param_Ent :=
  1443:                  Defining_Identifier (Iterator_Specification (Scheme));
  1444:             end if;
  1445:
  1446:             --  For the loop index of the top-level loop, consider the variable
  1447:             --  as completely written instead of discarded, as this allows
  1448:             --  stating the dynamic property of the loop index in the frame
  1449:             --  condition.
  1450:
  1451:             Write_Entity
  1452:               (New_Write      => Loop_Param_Ent,
  1453:                Loop_Writes    => Loop_Writes,
  1454:                Discard_Writes => After_Inv,
  1455:                Relevant_Path  => True);
  1456:
  1457:          end;
  1458:       end if;
  1459:
  1460:       --  Find relevant vertices.
```

## src/why/gnat2why-expr-loops-inv.adb:1641-1689

```ada
  1641:       declare
  1642:          Read_Ids  : Flow_Types.Flow_Id_Sets.Set;
  1643:          Write_Ids : Flow_Types.Flow_Id_Sets.Set;
  1644:
  1645:       begin
  1646:          Flow_Utility.Get_Proof_Globals
  1647:            (Subprogram      => Subp,
  1648:             Reads           => Read_Ids,
  1649:             Writes          => Write_Ids,
  1650:             Erase_Constants => True,
  1651:             Scop            => Get_Flow_Scope (Call));
  1652:
  1653:          for F of Write_Ids loop
  1654:             pragma Assert (F.Kind in Direct_Mapping | Magic_String);
  1655:
  1656:             --  Magic_String are global state with no attached entities. As
  1657:             --  such state is translated as private in Why3, we do not need
  1658:             --  to assume any invariant for it.
  1659:
  1660:             if F.Kind = Direct_Mapping then
  1661:                declare
  1662:                   Entity : constant Entity_Id := Get_Direct_Mapping_Id (F);
  1663:
  1664:                begin
  1665:                   if Is_Object (Entity) and then Is_Mutable_In_Why (Entity)
  1666:                   then
  1667:                      Write_Entity
  1668:                        (Entity,
  1669:                         Loop_Writes,
  1670:                         Discard_Writes => False,
  1671:                         Relevant_Path  => Relevant_Path);
  1672:
  1673:                      --  If Entity has a validity flag, add it to
  1674:                      --  Invalid_Objects.
  1675:
  1676:                      if Object_Has_Valid_Id (Entity) then
  1677:                         Invalid_Objects.Include (Unique_Entity (Entity));
  1678:                      end if;
  1679:                   end if;
  1680:                end;
  1681:             end if;
  1682:          end loop;
  1683:       end;
  1684:
  1685:       --  Record write to the protected object for protected procedure or entry
  1686:
  1687:       if Is_Protected_Operation (Subp) and then Is_External_Call (Call) then
  1688:          Write_Expr
  1689:            (New_Write     => SPARK_Atree.Name (Call),
```

## src/why/gnat2why-expr-loops.adb:500-575

```ada
   500:                   Initial_Stmts.Append (N);
   501:                end if;
   502:
   503:             when Past_Selected_Block   =>
   504:                pragma Assert (not Is_Pragma_Check (N, Name_Loop_Invariant));
   505:                pragma Assert (not Is_Pragma (N, Pragma_Loop_Variant));
   506:                Final_Stmts.Append (N);
   507:          end case;
   508:       end loop;
   509:
   510:       --  If no loop (in)variant was found, put all statements and declarations
   511:       --  in the list Final_Stmts, leaving the list Initial_Stmts empty. Also
   512:       --  clear the Frame_Constants and Imprecise_Constants sets.
   513:
   514:       if Cur_State = Before_Selected_Block then
   515:          Final_Stmts.Move (Source => Initial_Stmts);
   516:          Frame_Constants.Clear;
   517:          Imprecise_Constants.Clear;
   518:       end if;
   519:    end Get_Loop_Invariant;
   520:
   521:    function Get_Loop_Invariant
   522:      (Loop_Stmt : N_Loop_Statement_Id) return Node_Lists.List
   523:    is
   524:       Loop_Body           : constant List_Id := Statements (Loop_Stmt);
   525:       Loop_Stmts          : Node_Lists.List;
   526:       Initial_Stmts       : Node_Lists.List;
   527:       Final_Stmts         : Node_Lists.List;
   528:       Loop_Invariants     : Node_Lists.List;
   529:       Loop_Variants       : Node_Lists.List;
   530:       Frame_Constants     : Entity_Sets.Set;
   531:       Imprecise_Constants : Entity_Sets.Set;
   532:    begin
   533:       Loop_Stmts := Get_Flat_Statement_And_Declaration_List (Loop_Body);
   534:       Get_Loop_Invariant
   535:         (Loop_Stmts          => Loop_Stmts,
   536:          Initial_Stmts       => Initial_Stmts,
   537:          Loop_Invariants     => Loop_Invariants,
   538:          Loop_Variants       => Loop_Variants,
   539:          Final_Stmts         => Final_Stmts,
   540:          Frame_Constants     => Frame_Constants,
   541:          Imprecise_Constants => Imprecise_Constants);
   542:       return Loop_Invariants;
   543:    end Get_Loop_Invariant;
   544:
   545:    --------------------------------------
   546:    -- Imprecise_Constant_Value_In_Loop --
   547:    --------------------------------------
   548:
   549:    function Imprecise_Constant_Value_In_Loop (E : Entity_Id) return Boolean
   550:    is (Imprecise_Constants.Contains (E));
   551:
   552:    ------------------------------------
   553:    -- Transform_Loop_Body_Statements --
   554:    ------------------------------------
   555:
   556:    function Transform_Loop_Body_Statements
   557:      (Instrs : Node_Lists.List; Params : Transformation_Params)
   558:       return W_Prog_Id
   559:    is
   560:       Body_Prog : W_Statement_Sequence_Id := Void_Sequence;
   561:    begin
   562:       for Instr of Instrs loop
   563:
   564:          --  Loop variants should not occur here anymore
   565:
   566:          pragma Assert (not Is_Pragma (Instr, Pragma_Loop_Variant));
   567:
   568:          Transform_Statement_Or_Declaration_In_List
   569:            (Stmt_Or_Decl => Instr, Params => Params, Seq => Body_Prog);
   570:       end loop;
   571:
   572:       return +Body_Prog;
   573:    end Transform_Loop_Body_Statements;
   574:
   575:    -----------------------------------
```

## src/why/gnat2why-expr-loops.adb:787-816

```ada
   787:            W_Pred_Array (1 .. Integer (Loop_Invariants.Length));
   788:          Save_Loop_Init       : constant Boolean := In_Loop_Initial_Statements
   789:          with Ghost;
   790:          Save_Imprecise_Const : Entity_Sets.Set := Imprecise_Constants;
   791:
   792:       begin
   793:          --  Transform statements before and after the loop invariants
   794:
   795:          In_Loop_Initial_Statements := True;
   796:          Initial_Prog :=
   797:            Transform_Loop_Body_Statements (Initial_Stmts, Params);
   798:          In_Loop_Initial_Statements := Save_Loop_Init;
   799:
   800:          Save_Imprecise_Const := Imprecise_Constants;
   801:          Imprecise_Constants.Union (Other_Constants);
   802:          Final_Prog := Transform_Loop_Body_Statements (Final_Stmts, Params);
   803:          Imprecise_Constants.Move (Save_Imprecise_Const);
   804:
   805:          --  Generate the implicit invariant for the dynamic properties of
   806:          --  objects modified in the loop.
   807:
   808:          Dyn_Types_Inv :=
   809:            Generate_Frame_Condition
   810:              (Stmt,
   811:               Low_Id          => +Low_Id,
   812:               High_Id         => +High_Id,
   813:               Frame_Constants => Frame_Constants);
   814:
   815:          --  Generate the loop invariants VCs
   816:
```

## src/why/gnat2why-expr-loops.adb:1292-1343

```ada
  1292:                function Construct_Cond return W_Prog_Id is
  1293:                begin
  1294:                   if Over_Range then
  1295:
  1296:                      --  Low_Id <= Index_Deref <= High_Id
  1297:
  1298:                      return
  1299:                        +New_Range_Expr
  1300:                           (Domain => EW_Prog,
  1301:                            Low    => +Low_Id,
  1302:                            High   => +High_Id,
  1303:                            Expr   => +Index_Deref);
  1304:                   else
  1305:
  1306:                      --  Has_Element (W_Container, Iter_Deref)
  1307:
  1308:                      return +Constraint_For_Iterable (EW_Prog);
  1309:                   end if;
  1310:                end Construct_Cond;
  1311:
  1312:                -------------------------
  1313:                -- Construct_Exit_Cond --
  1314:                -------------------------
  1315:
  1316:                function Construct_Exit_Cond return W_Prog_Id is
  1317:                begin
  1318:                   if Over_Range then
  1319:
  1320:                      --  Index_Deref = Low_Id if Is_Reverse
  1321:                      --  Index_Deref = High_Id otherwise
  1322:
  1323:                      declare
  1324:                         Is_Reverse : constant Boolean :=
  1325:                           Reverse_Present (LParam_Spec);
  1326:                         Exit_Index : constant W_Expr_Id :=
  1327:                           (if Is_Reverse then +Low_Id else +High_Id);
  1328:                         Eq_Symb    : constant W_Identifier_Id :=
  1329:                           (if Why_Type_Is_BitVector (Loop_Index_Type)
  1330:                            then MF_BVs (Loop_Index_Type).Prog_Eq
  1331:                            else Why_Eq);
  1332:                         Exit_Cond  : constant W_Expr_Id :=
  1333:                           New_Call
  1334:                             (Domain => EW_Prog,
  1335:                              Name   => Eq_Symb,
  1336:                              Typ    => EW_Bool_Type,
  1337:                              Args   => (+Index_Deref, +Exit_Index));
  1338:                      begin
  1339:                         return +Exit_Cond;
  1340:                      end;
  1341:                   else
  1342:
  1343:                      --  not (Has_Element (W_Container, Next (Iter_Deref)));
```

## src/why/gnat2why-expr-loops.adb:1398-1415

```ada
  1398:                function Construct_Inv_For_Index return W_Pred_Id is
  1399:                begin
  1400:                   if Over_Range then
  1401:
  1402:                      --  In the range expression of the invariant, explicitly
  1403:                      --  set T_Type to handle the special case of
  1404:                      --  Standard.Boolean, where bounds and index are of
  1405:                      --  different base types (bool for bounds, int for index).
  1406:
  1407:                      return
  1408:                        +Range_Expr
  1409:                           (Over_Node,
  1410:                            New_Deref
  1411:                              (Right => Loop_Index, Typ => Loop_Index_Type),
  1412:                            EW_Pred,
  1413:                            Params => Params,
  1414:                            T_Type => Loop_Index_Type);
  1415:
```

## src/why/gnat2why-expr-loops.adb:1458-1505

```ada
  1458:                function Construct_Update_Stmt return W_Prog_Id is
  1459:                begin
  1460:                   if Over_Range then
  1461:
  1462:                      --  Loop_Index := Index_Deref - 1 if Is_Reverse
  1463:                      --  Loop_Index := Index_Deref + 1 otherwise
  1464:
  1465:                      declare
  1466:                         Is_Reverse  : constant Boolean :=
  1467:                           Reverse_Present (LParam_Spec);
  1468:                         Update_Op   : constant W_Identifier_Id :=
  1469:                           (if Why_Type_Is_BitVector (Loop_Index_Type)
  1470:                            then
  1471:                              (if Is_Reverse
  1472:                               then MF_BVs (Loop_Index_Type).Sub
  1473:                               else MF_BVs (Loop_Index_Type).Add)
  1474:                            else
  1475:                              (if Is_Reverse
  1476:                               then Int_Infix_Subtr
  1477:                               else Int_Infix_Add));
  1478:                         One_Expr    : constant W_Expr_Id :=
  1479:                           (if Why_Type_Is_BitVector (Loop_Index_Type)
  1480:                            then
  1481:                              New_Modular_Constant
  1482:                                (Ada_Node => Stmt,
  1483:                                 Value    => Uint_1,
  1484:                                 Typ      => Loop_Index_Type)
  1485:                            else
  1486:                              New_Integer_Constant
  1487:                                (Ada_Node => Stmt, Value => Uint_1));
  1488:                         Update_Expr : constant W_Prog_Id :=
  1489:                           New_Call
  1490:                             (Ada_Node => Stmt,
  1491:                              Name     => Update_Op,
  1492:                              Args     => (1 => +Index_Deref, 2 => +One_Expr),
  1493:                              Typ      => Loop_Index_Type);
  1494:                      begin
  1495:                         return
  1496:                           New_Assignment
  1497:                             (Ada_Node => Stmt,
  1498:                              Name     => Loop_Index,
  1499:                              Labels   => Symbol_Sets.Empty_Set,
  1500:                              Value    => +Update_Expr,
  1501:                              Typ      => Loop_Index_Type);
  1502:                      end;
  1503:                   else
  1504:                      declare
  1505:                         Next      : constant E_Function_Id :=
```

## src/why/gnat2why-expr-loops.adb:1800-1825

```ada
  1800:                --  static range, which can be unrolled for every value of the
  1801:                --  loop index.
  1802:
  1803:                Candidate_For_Loop_Unrolling
  1804:                  (Loop_Stmt   => Stmt,
  1805:                   Output_Info =>
  1806:                     Warning_Status (Warn_Info_Unrolling_Inlining) = WS_Enabled
  1807:                     and then not Gnat2Why_Args.No_Loop_Unrolling,
  1808:                   Result      => Unroll,
  1809:                   Low_Val     => Low_Val,
  1810:                   High_Val    => High_Val);
  1811:
  1812:                if not Gnat2Why_Args.No_Loop_Unrolling
  1813:                  and then Unroll /= No_Unrolling
  1814:                then
  1815:                   --  If the loop has an iterator filter, we need to add
  1816:                   --  the filtering expression as a guard for each loop
  1817:                   --  unrolling.
  1818:
  1819:                   if Present (Iterator_Filter (LParam_Spec)) then
  1820:                      Final_Prog :=
  1821:                        New_Conditional
  1822:                          (Condition =>
  1823:                             Transform_Prog
  1824:                               (Expr          => Iterator_Filter (LParam_Spec),
  1825:                                Expected_Type => EW_Bool_Type,
```

## src/why/gnat2why-expr-loops.adb:1882-1978

```ada
  1882:
  1883:                   Entire_Loop :=
  1884:                     Wrap_Loop
  1885:                       (Loop_Id            => Loop_Id,
  1886:                        Loop_Start         => Initial_Prog,
  1887:                        Loop_End           => Final_Prog,
  1888:                        Enter_Condition    => Cond_Prog,
  1889:                        Exit_Condition     => Exit_Cond,
  1890:                        Implicit_Invariant => Impl_Inv,
  1891:                        User_Invariants    => Why_Invariants,
  1892:                        Invariant_Check    => Inv_Check,
  1893:                        Variants           =>
  1894:                          Transform_Loop_Variants (Loop_Variants),
  1895:                        Variant_Check      =>
  1896:                          Check_Loop_Variants (Loop_Variants),
  1897:                        Update_Stmt        => Update_Stmt,
  1898:                        First_Stmt         => Loop_Stmts.First_Element,
  1899:                        Next_Stmt          => Next_Stmt,
  1900:                        Last_Inv           =>
  1901:                          (if Loop_Invariants.Is_Empty
  1902:                           then Empty
  1903:                           else Loop_Invariants.Last_Element),
  1904:                        Params             => Params);
  1905:
  1906:                   Prepend (Construct_Init_Prog, Entire_Loop);
  1907:                end if;
  1908:
  1909:                --  Create new variable for iterator if needed
  1910:
  1911:                if Need_Iter then
  1912:                   Entire_Loop :=
  1913:                     New_Binding_Ref
  1914:                       (Name    => Nam_For_Iter,
  1915:                        Def     => Init_Iter,
  1916:                        Context => Entire_Loop,
  1917:                        Typ     => EW_Unit_Type);
  1918:                end if;
  1919:
  1920:                --  Bind the temporary variable used for the container
  1921:                --  expression if any.
  1922:
  1923:                if W_Container /= Why_Empty then
  1924:                   Entire_Loop :=
  1925:                     +Binding_For_Temp
  1926:                        (Ada_Node => Loop_Id,
  1927:                         Domain   => EW_Prog,
  1928:                         Tmp      => W_Container,
  1929:                         Context  => +Entire_Loop);
  1930:                end if;
  1931:
  1932:                --  Add let bindings for bounds
  1933:
  1934:                if Over_Range then
  1935:                   declare
  1936:                      Actual_Range : constant Node_Id := Get_Range (Over_Node);
  1937:                      High_Expr    : constant W_Prog_Id :=
  1938:                        Transform_Prog
  1939:                          (High_Bound (Actual_Range),
  1940:                           Loop_Index_Type,
  1941:                           Params => Params);
  1942:                      Low_Expr     : constant W_Prog_Id :=
  1943:                        Transform_Prog
  1944:                          (Low_Bound (Actual_Range),
  1945:                           Loop_Index_Type,
  1946:                           Params => Params);
  1947:                   begin
  1948:                      --  Insert assignment to high bound first, so that
  1949:                      --  assignment to low bound is done prior to assignment to
  1950:                      --  high bound in generated Why3 code. This ensures that a
  1951:                      --  common error is detected on low bound rather than high
  1952:                      --  bound, which is more intuitive.
  1953:
  1954:                      Entire_Loop :=
  1955:                        New_Typed_Binding
  1956:                          (Stmt, High_Id, High_Expr, Entire_Loop);
  1957:                      Entire_Loop :=
  1958:                        New_Typed_Binding (Stmt, Low_Id, Low_Expr, Entire_Loop);
  1959:                   end;
  1960:                end if;
  1961:
  1962:                --  For loop_parameter_specification whose
  1963:                --  discrete_subtype_definition is a subtype_indication,
  1964:                --  we generate a check that the range_constraint of the
  1965:                --  subtype_indication is compatible with the given subtype.
  1966:
  1967:                if Nkind (Over_Node) = N_Subtype_Indication then
  1968:                   Prepend
  1969:                     (Check_Subtype_Indication
  1970:                        (Params   => Params,
  1971:                         N        => Over_Node,
  1972:                         Sub_Type => Etype (Defining_Identifier (LParam_Spec))),
  1973:                      Entire_Loop);
  1974:                end if;
  1975:
  1976:                return Entire_Loop;
  1977:             end For_Loop;
  1978:          end if;
```

## src/why/gnat2why-expr-loops.adb:2080-2115

```ada
  2080:                 2
  2081:                 * (Integer (UI_To_Int (High_Val) - UI_To_Int (Low_Val) + 1)));
  2082:          Cur_Idx   : Positive;
  2083:
  2084:       begin
  2085:          Cur_Val := First_Val;
  2086:          Cur_Idx := 1;
  2087:          loop
  2088:             Cur_Cst :=
  2089:               (if Why_Type_Is_BitVector (Loop_Index_Type)
  2090:                then
  2091:                  New_Modular_Constant
  2092:                    (Value => Cur_Val, Typ => Loop_Index_Type)
  2093:                else New_Integer_Constant (Value => Cur_Val));
  2094:             Stmt_List (Cur_Idx) :=
  2095:               New_Assignment
  2096:                 (Name   => Loop_Index,
  2097:                  Value  => Cur_Cst,
  2098:                  Labels => Symbol_Sets.Empty_Set,
  2099:                  Typ    => Loop_Index_Type);
  2100:             Cur_Idx := Cur_Idx + 1;
  2101:             Stmt_List (Cur_Idx) := Loop_Body;
  2102:             Cur_Idx := Cur_Idx + 1;
  2103:
  2104:             exit when Cur_Val = Last_Val;
  2105:
  2106:             if Reversed then
  2107:                Cur_Val := Cur_Val - 1;
  2108:             else
  2109:                Cur_Val := Cur_Val + 1;
  2110:             end if;
  2111:          end loop;
  2112:
  2113:          return Sequence (Stmt_List);
  2114:       end Repeat_Loop;
  2115:
```

## src/why/gnat2why-expr-loops.adb:2194-2334

```ada
  2194:    function Wrap_Loop
  2195:      (Loop_Id            : E_Loop_Id;
  2196:       Loop_Start         : W_Prog_Id;
  2197:       Loop_End           : W_Prog_Id;
  2198:       Enter_Condition    : W_Prog_Id;
  2199:       Exit_Condition     : W_Prog_Id;
  2200:       Implicit_Invariant : W_Pred_Id;
  2201:       User_Invariants    : W_Pred_Array;
  2202:       Invariant_Check    : W_Prog_Id;
  2203:       Variants           : W_Variants_Array;
  2204:       Variant_Check      : W_Prog_Id;
  2205:       Update_Stmt        : W_Prog_Id := Why_Empty;
  2206:       First_Stmt         : Node_Id;
  2207:       Next_Stmt          : Node_Id := Empty;
  2208:       Last_Inv           : Opt_N_Pragma_Id := Empty;
  2209:       Params             : Transformation_Params) return W_Prog_Id
  2210:    is
  2211:       Exit_Ident  : constant W_Name_Id :=
  2212:         Loop_Exception_Name (Loop_Id, Is_Continue => False);
  2213:       Cont_Ident  : constant W_Name_Id :=
  2214:         Loop_Exception_Name (Loop_Id, Is_Continue => True);
  2215:       Loop_Before : constant W_Prog_Id :=
  2216:         Sequence
  2217:           ((1 => Loop_Start,
  2218:             2 =>
  2219:               New_Comment
  2220:                 (Comment =>
  2221:                    NID
  2222:                      ("Check for absence of RTE in the loop"
  2223:                       & " invariant and variant")),
  2224:             3 => Invariant_Check,
  2225:             4 => Variant_Check));
  2226:       Loop_After  : constant W_Prog_Id :=
  2227:         Sequence
  2228:           ((1 =>
  2229:               New_Comment
  2230:                 (Comment =>
  2231:                    NID
  2232:                      ("Assume implicit invariants from the loop"
  2233:                       & (if Sloc (Loop_Id) > 0
  2234:                          then " " & Build_Location_String (Sloc (Loop_Id))
  2235:                          else ""))),
  2236:             2 => New_Assume_Statement (Pred => Implicit_Invariant),
  2237:             3 =>
  2238:               New_Comment
  2239:                 (Comment =>
  2240:                    NID
  2241:                      ("Continuation of loop after loop"
  2242:                       & " invariant and variant")),
  2243:             4 =>
  2244:               New_Try_Block
  2245:                 (Prog    => Loop_End,
  2246:                  Handler =>
  2247:                    (1 => New_Handler (Name => Cont_Ident, Def => +Void))),
  2248:             5 =>
  2249:               New_Comment
  2250:                 (Comment =>
  2251:                    NID
  2252:                      ("Check for the exit condition and loop"
  2253:                       & " statements appearing before the loop invariant"
  2254:                       & (if Sloc (Loop_Id) > 0
  2255:                          then
  2256:                            " of loop " & Build_Location_String (Sloc (Loop_Id))
  2257:                          else ""))),
  2258:             6 =>
  2259:               New_Conditional
  2260:                 (Condition => +Exit_Condition,
  2261:                  Then_Part => New_Raise (Name => Exit_Ident)),
  2262:             7 => (if Update_Stmt = Why_Empty then +Void else Update_Stmt)));
  2263:
  2264:       Loop_Stmt : constant W_Prog_Id :=
  2265:         +Insert_Cnt_Loc_Label
  2266:            (Ada_Node     => (if Present (Last_Inv) then Last_Inv else Loop_Id),
  2267:             E            =>
  2268:               New_Loop
  2269:                 (Ada_Node    => Loop_Id,
  2270:                  Code_Before => Loop_Before,
  2271:                  Invariants  => User_Invariants,
  2272:                  Variants    => Variants,
  2273:                  Code_After  => Loop_After),
  2274:             Is_Loop_Head => True);
  2275:
  2276:       Try_Body : constant W_Prog_Id :=
  2277:         Bind_From_Mapping_In_Prog
  2278:           (Params => Params,
  2279:            Map    => Map_For_Loop_Entry (Loop_Id),
  2280:            Expr   =>
  2281:              Sequence
  2282:                ((1 =>
  2283:                    New_Comment
  2284:                      (Comment =>
  2285:                         NID
  2286:                           ("While loop translating the Ada loop"
  2287:                            & (if Sloc (Loop_Id) > 0
  2288:                               then
  2289:                                 " from "
  2290:                                 & Build_Location_String (Sloc (Loop_Id))
  2291:                               else ""))),
  2292:                  2 => Loop_Stmt)));
  2293:
  2294:       Loop_Try       : W_Prog_Id;
  2295:       Warn_Dead_Code : W_Prog_Id := +Void;
  2296:
  2297:    begin
  2298:       --  Now wrap the resulting program in the try-catch block for the
  2299:       --  loop, catching the exception corresponding to exiting the loop.
  2300:
  2301:       Loop_Try :=
  2302:         New_Try_Block
  2303:           (Prog    => Try_Body,
  2304:            Handler => (1 => New_Handler (Name => Exit_Ident, Def => +Void)));
  2305:
  2306:       --  Possibly warn on dead code, both when entering the loop and after the
  2307:       --  loop. Do not try to check whether the loop condition is statically
  2308:       --  disabled if any, it should not happen in practice.
  2309:
  2310:       Loop_Try :=
  2311:         Warn_On_Dead_Code
  2312:           (First_Stmt, Loop_Try, Params.Phase, Params.Warn_On_Dead);
  2313:
  2314:       if Present (Next_Stmt) then
  2315:          Warn_Dead_Code :=
  2316:            Warn_On_Dead_Code
  2317:              (Next_Stmt, +Void, Params.Phase, Params.Warn_On_Dead);
  2318:       end if;
  2319:
  2320:       return
  2321:         Sequence
  2322:           ((1 =>
  2323:               New_Comment
  2324:                 (Comment =>
  2325:                    NID
  2326:                      ("Translation of an Ada loop"
  2327:                       & (if Sloc (Loop_Id) > 0
  2328:                          then " from " & Build_Location_String (Sloc (Loop_Id))
  2329:                          else ""))),
  2330:             2 =>
  2331:               New_Conditional
  2332:                 (Condition => +Enter_Condition, Then_Part => +Loop_Try),
  2333:             3 => Warn_Dead_Code));
  2334:    end Wrap_Loop;
```

## src/why/gnat2why-expr-loops.adb:619-651

```ada
   619:       function Check_Loop_Variants (List : Node_Lists.List) return W_Prog_Id is
   620:          Stmts   : W_Prog_Array (1 .. Natural (List.Length));
   621:          Counter : Positive := 1;
   622:       begin
   623:          if List.Is_Empty then
   624:             return +Void;
   625:          end if;
   626:
   627:          for Variant of List loop
   628:             Stmts (Counter) := Check_Loop_Variant (Variant, Params);
   629:             Counter := Counter + 1;
   630:          end loop;
   631:
   632:          return Sequence (Stmts);
   633:       end Check_Loop_Variants;
   634:
   635:       -----------------------------
   636:       -- Transform_Loop_Variants --
   637:       -----------------------------
   638:
   639:       function Transform_Loop_Variants
   640:         (List : Node_Lists.List) return W_Variants_Array
   641:       is
   642:          Variants_Ar : W_Variants_Array (1 .. Natural (List.Length));
   643:          Count       : Natural := 0;
   644:       begin
   645:          for Loop_Variant of List loop
   646:
   647:             --  Structural variants are checked statically
   648:
   649:             if Chars (First (Pragma_Argument_Associations (Loop_Variant)))
   650:               = Name_Structural
   651:             then
```

## src/why/gnat2why-expr-loops.adb:690-787

```ada
   690:
   691:       Loop_Body : constant List_Id := Statements (Stmt);
   692:       Scheme    : constant Opt_N_Iteration_Scheme_Id :=
   693:         Iteration_Scheme (Stmt);
   694:       Loop_Id   : constant E_Loop_Id := Entity (Identifier (Stmt));
   695:       Next_Stmt : constant Node_Id := Next (Stmt);
   696:
   697:       Loop_Stmts      : Node_Lists.List;
   698:       Initial_Stmts   : Node_Lists.List;
   699:       Final_Stmts     : Node_Lists.List;
   700:       Loop_Invariants : Node_Lists.List;
   701:       Loop_Variants   : Node_Lists.List;
   702:       Frame_Constants : Entity_Sets.Set;
   703:       Other_Constants : Entity_Sets.Set;
   704:
   705:       Initial_Prog : W_Prog_Id;
   706:       Final_Prog   : W_Prog_Id;
   707:
   708:       --  Variables for the selected loop invariants, default initialized to
   709:       --  the proper values when the loop does not have an invariant.
   710:
   711:       Inv_Check : W_Prog_Id := +Void;
   712:
   713:       --  Variable for the implicit invariant for dynamic properties of
   714:       --  modified objects.
   715:
   716:       Dyn_Types_Inv : W_Pred_Id := True_Pred;
   717:
   718:       Loop_Param_Ent  : Opt_E_Loop_Parameter_Id := Empty;
   719:       Loop_Index      : W_Identifier_Id := Why_Empty;
   720:       Loop_Index_Type : W_Type_Id := EW_Int_Type;
   721:       --  These three variables hold the loop parameter in Ada and Why, if any
   722:
   723:       --  Constants specific to range quantification
   724:
   725:       Low_Id  : W_Identifier_Id := Why_Empty;
   726:       High_Id : W_Identifier_Id := Why_Empty;
   727:
   728:       --  Start of processing for Transform_Loop_Statement
   729:
   730:    begin
   731:       --  Add the loop index to the entity table
   732:
   733:       if Present (Scheme) and then No (Condition (Scheme)) then
   734:          if Present (Loop_Parameter_Specification (Scheme)) then
   735:             Loop_Param_Ent :=
   736:               Defining_Identifier (Loop_Parameter_Specification (Scheme));
   737:
   738:             Ada_Ent_To_Why.Push_Scope (Symbol_Table);
   739:
   740:             declare
   741:                Index_Item : constant Item_Type :=
   742:                  Mk_Item_Of_Entity (Loop_Param_Ent);
   743:             begin
   744:                pragma Assert (Index_Item.Kind = Regular);
   745:
   746:                Loop_Index := Index_Item.Main.B_Name;
   747:                Loop_Index_Type := Base_Why_Type (Get_Typ (Loop_Index));
   748:                Insert_Item (Loop_Param_Ent, Index_Item);
   749:             end;
   750:          else
   751:             pragma Assert (Present (Iterator_Specification (Scheme)));
   752:             Loop_Param_Ent :=
   753:               Defining_Identifier (Iterator_Specification (Scheme));
   754:
   755:             Ada_Ent_To_Why.Push_Scope (Symbol_Table);
   756:
   757:             declare
   758:                Index_Item : constant Item_Type :=
   759:                  Mk_Item_Of_Entity (Loop_Param_Ent);
   760:             begin
   761:                pragma Assert (Index_Item.Kind = Regular);
   762:
   763:                Loop_Index := Index_Item.Main.B_Name;
   764:                Loop_Index_Type := Get_Typ (Loop_Index);
   765:                Insert_Item (Loop_Param_Ent, Index_Item);
   766:             end;
   767:          end if;
   768:
   769:          Low_Id := New_Temp_Identifier (Typ => Loop_Index_Type);
   770:          High_Id := New_Temp_Identifier (Typ => Loop_Index_Type);
   771:       end if;
   772:
   773:       --  Retrieve the different parts of the loop
   774:
   775:       Loop_Stmts := Get_Flat_Statement_And_Declaration_List (Loop_Body);
   776:       Get_Loop_Invariant
   777:         (Loop_Stmts          => Loop_Stmts,
   778:          Initial_Stmts       => Initial_Stmts,
   779:          Loop_Invariants     => Loop_Invariants,
   780:          Loop_Variants       => Loop_Variants,
   781:          Final_Stmts         => Final_Stmts,
   782:          Frame_Constants     => Frame_Constants,
   783:          Imprecise_Constants => Other_Constants);
   784:
   785:       declare
   786:          Why_Invariants       :
   787:            W_Pred_Array (1 .. Integer (Loop_Invariants.Length));
```

## src/why/gnat2why-expr-loops.adb:970-1050

```ada
   970:             pragma Assert (Present (Loop_Index));
   971:
   972:             For_Loop : declare
   973:                Over_Range : constant Boolean :=
   974:                  Present (Loop_Parameter_Specification (Scheme));
   975:                --  For loops my iterate either on a range or on an iterator.
   976:
   977:                LParam_Spec : constant Node_Id :=
   978:                  (if Over_Range
   979:                   then Loop_Parameter_Specification (Scheme)
   980:                   else Iterator_Specification (Scheme));
   981:                Over_Node   : constant Node_Id :=
   982:                  (if Over_Range
   983:                   then Discrete_Subtype_Definition (LParam_Spec)
   984:                   else Get_Container_In_Iterator_Specification (LParam_Spec));
   985:                Index_Deref : constant W_Prog_Id :=
   986:                  New_Deref
   987:                    (Ada_Node => Stmt,
   988:                     Right    => +Loop_Index,
   989:                     Typ      => Loop_Index_Type);
   990:
   991:                --  Constants specific to iterator specification
   992:
   993:                Typ_For_Cont  : constant W_Type_Id :=
   994:                  (if Over_Range
   995:                   then EW_Int_Type
   996:                   else
   997:                     Type_Of_Node
   998:                       (Etype
   999:                          (First_Formal
  1000:                             (Get_Iterable_Type_Primitive
  1001:                                (Etype (Over_Node), Name_First)))));
  1002:                W_Container   : constant W_Expr_Id :=
  1003:                  (if Over_Range
  1004:                   then Why_Empty
  1005:                   else
  1006:                     New_Temp_For_Expr
  1007:                       (Insert_Simple_Conversion
  1008:                          (Domain => EW_Prog,
  1009:                           Expr   =>
  1010:                             Transform_Expr (Over_Node, EW_Prog, Params),
  1011:                           To     => Typ_For_Cont),
  1012:                        Need_Temp => not SPARK_Atree.Is_Variable (Over_Node)));
  1013:                --  Introduce a temporary variable for the container expression
  1014:                --  except if it is a variable.
  1015:                W_Container_T : constant W_Expr_Id :=
  1016:                  (if Over_Range
  1017:                   then Why_Empty
  1018:                   elsif SPARK_Atree.Is_Variable (Over_Node)
  1019:                   then
  1020:                     Insert_Simple_Conversion
  1021:                       (Domain => EW_Term,
  1022:                        Expr   => Transform_Expr (Over_Node, EW_Term, Params),
  1023:                        To     => Typ_For_Cont)
  1024:                   else W_Container);
  1025:                --  Container expression in the term domain
  1026:
  1027:                --  For for of loops, we need an identifier for the additional
  1028:                --  variable holding the iterator.
  1029:
  1030:                Need_Iter    : constant Boolean :=
  1031:                  not Over_Range and then Of_Present (LParam_Spec);
  1032:                Typ_For_Iter : constant W_Type_Id :=
  1033:                  (if Need_Iter
  1034:                   then
  1035:                     Type_Of_Node
  1036:                       (Get_Iterable_Type_Primitive
  1037:                          (Typ => Etype (Over_Node), Nam => Name_First))
  1038:                   else Loop_Index_Type);
  1039:                Nam_For_Iter : constant W_Identifier_Id :=
  1040:                  (if not Need_Iter
  1041:                   then Loop_Index
  1042:                   else
  1043:                     New_Temp_Identifier
  1044:                       (Ada_Node => Empty, Typ => Typ_For_Iter));
  1045:                Iter_Deref   : constant W_Prog_Id :=
  1046:                  New_Deref
  1047:                    (Ada_Node => Stmt,
  1048:                     Right    => +Nam_For_Iter,
  1049:                     Typ      => Typ_For_Iter);
  1050:
```

## src/why/gnat2why-expr-loops.adb:1292-1416

```ada
  1292:                function Construct_Cond return W_Prog_Id is
  1293:                begin
  1294:                   if Over_Range then
  1295:
  1296:                      --  Low_Id <= Index_Deref <= High_Id
  1297:
  1298:                      return
  1299:                        +New_Range_Expr
  1300:                           (Domain => EW_Prog,
  1301:                            Low    => +Low_Id,
  1302:                            High   => +High_Id,
  1303:                            Expr   => +Index_Deref);
  1304:                   else
  1305:
  1306:                      --  Has_Element (W_Container, Iter_Deref)
  1307:
  1308:                      return +Constraint_For_Iterable (EW_Prog);
  1309:                   end if;
  1310:                end Construct_Cond;
  1311:
  1312:                -------------------------
  1313:                -- Construct_Exit_Cond --
  1314:                -------------------------
  1315:
  1316:                function Construct_Exit_Cond return W_Prog_Id is
  1317:                begin
  1318:                   if Over_Range then
  1319:
  1320:                      --  Index_Deref = Low_Id if Is_Reverse
  1321:                      --  Index_Deref = High_Id otherwise
  1322:
  1323:                      declare
  1324:                         Is_Reverse : constant Boolean :=
  1325:                           Reverse_Present (LParam_Spec);
  1326:                         Exit_Index : constant W_Expr_Id :=
  1327:                           (if Is_Reverse then +Low_Id else +High_Id);
  1328:                         Eq_Symb    : constant W_Identifier_Id :=
  1329:                           (if Why_Type_Is_BitVector (Loop_Index_Type)
  1330:                            then MF_BVs (Loop_Index_Type).Prog_Eq
  1331:                            else Why_Eq);
  1332:                         Exit_Cond  : constant W_Expr_Id :=
  1333:                           New_Call
  1334:                             (Domain => EW_Prog,
  1335:                              Name   => Eq_Symb,
  1336:                              Typ    => EW_Bool_Type,
  1337:                              Args   => (+Index_Deref, +Exit_Index));
  1338:                      begin
  1339:                         return +Exit_Cond;
  1340:                      end;
  1341:                   else
  1342:
  1343:                      --  not (Has_Element (W_Container, Next (Iter_Deref)));
  1344:
  1345:                      return +Exit_Condition_For_Iterable;
  1346:                   end if;
  1347:                end Construct_Exit_Cond;
  1348:
  1349:                -------------------------
  1350:                -- Construct_Init_Prog --
  1351:                -------------------------
  1352:
  1353:                function Construct_Init_Prog return W_Prog_Id is
  1354:                begin
  1355:                   if Over_Range then
  1356:
  1357:                      --  Loop_Index := High_Id if Is_Reverse
  1358:                      --  Loop_Index := Low_Id otherwise
  1359:
  1360:                      declare
  1361:                         Is_Reverse : constant Boolean :=
  1362:                           Reverse_Present (LParam_Spec);
  1363:                         Init_Index : constant W_Expr_Id :=
  1364:                           (if Is_Reverse then +High_Id else +Low_Id);
  1365:                      begin
  1366:                         return
  1367:                           New_Assignment
  1368:                             (Name   => Loop_Index,
  1369:                              Value  => +Init_Index,
  1370:                              Labels => Symbol_Sets.Empty_Set,
  1371:                              Typ    => Loop_Index_Type);
  1372:                      end;
  1373:                   else
  1374:                      if Need_Iter then
  1375:
  1376:                         --  if Has_Element (W_Container, Iter_Deref) then
  1377:                         --    Loop_Index := Element (W_Container, Iter_Deref)
  1378:
  1379:                         return Update_Index;
  1380:                      else
  1381:
  1382:                         --  Loop_Index := First (W_Container)
  1383:
  1384:                         return
  1385:                           New_Assignment
  1386:                             (Name   => Nam_For_Iter,
  1387:                              Value  => Init_Iter,
  1388:                              Labels => Symbol_Sets.Empty_Set,
  1389:                              Typ    => Typ_For_Iter);
  1390:                      end if;
  1391:                   end if;
  1392:                end Construct_Init_Prog;
  1393:
  1394:                -----------------------------
  1395:                -- Construct_Inv_For_Index --
  1396:                -----------------------------
  1397:
  1398:                function Construct_Inv_For_Index return W_Pred_Id is
  1399:                begin
  1400:                   if Over_Range then
  1401:
  1402:                      --  In the range expression of the invariant, explicitly
  1403:                      --  set T_Type to handle the special case of
  1404:                      --  Standard.Boolean, where bounds and index are of
  1405:                      --  different base types (bool for bounds, int for index).
  1406:
  1407:                      return
  1408:                        +Range_Expr
  1409:                           (Over_Node,
  1410:                            New_Deref
  1411:                              (Right => Loop_Index, Typ => Loop_Index_Type),
  1412:                            EW_Pred,
  1413:                            Params => Params,
  1414:                            T_Type => Loop_Index_Type);
  1415:
  1416:                   else
```

## src/why/gnat2why-expr-loops.adb:1763-1989

```ada
  1763:                                                   New_Or_Pred
  1764:                                                     (Left  => Exit_Cond,
  1765:                                                      Right => Last_Filter))),
  1766:                                         Return_Type => EW_Unit_Type,
  1767:                                         Labels      => Symbol_Sets.Empty_Set),
  1768:                                    2 => Check_Filter,
  1769:                                    3 => Exit_Stmt))));
  1770:                end Skip_Empty_Iterations;
  1771:
  1772:                ---------------------
  1773:                -- Local Variables --
  1774:                ---------------------
  1775:
  1776:                Index_Inv   : constant W_Pred_Id := Construct_Inv_For_Index;
  1777:                Cond_Prog   : constant W_Prog_Id := Construct_Cond;
  1778:                Update_Stmt : constant W_Prog_Id :=
  1779:                  +Insert_Cnt_Loc_Label (Stmt, +Construct_Update_Stmt);
  1780:                Exit_Cond   : constant W_Prog_Id := Construct_Exit_Cond;
  1781:                Impl_Inv    : W_Pred_Id :=
  1782:                  +New_And_Expr
  1783:                     (Left   => +Dyn_Types_Inv,
  1784:                      Right  => +Index_Inv,
  1785:                      Domain => EW_Prog);
  1786:
  1787:                Entire_Loop : W_Prog_Id;
  1788:
  1789:                --  Variables used in loop unrolling
  1790:                Low_Val  : Uint;
  1791:                High_Val : Uint;
  1792:                Unroll   : Unrolling_Type;
  1793:
  1794:                --  Start of processing for For_Loop
  1795:
  1796:             begin
  1797:                Ada_Ent_To_Why.Pop_Scope (Symbol_Table);
  1798:
  1799:                --  Special case of a FOR loop without loop (in)variant on a
  1800:                --  static range, which can be unrolled for every value of the
  1801:                --  loop index.
  1802:
  1803:                Candidate_For_Loop_Unrolling
  1804:                  (Loop_Stmt   => Stmt,
  1805:                   Output_Info =>
  1806:                     Warning_Status (Warn_Info_Unrolling_Inlining) = WS_Enabled
  1807:                     and then not Gnat2Why_Args.No_Loop_Unrolling,
  1808:                   Result      => Unroll,
  1809:                   Low_Val     => Low_Val,
  1810:                   High_Val    => High_Val);
  1811:
  1812:                if not Gnat2Why_Args.No_Loop_Unrolling
  1813:                  and then Unroll /= No_Unrolling
  1814:                then
  1815:                   --  If the loop has an iterator filter, we need to add
  1816:                   --  the filtering expression as a guard for each loop
  1817:                   --  unrolling.
  1818:
  1819:                   if Present (Iterator_Filter (LParam_Spec)) then
  1820:                      Final_Prog :=
  1821:                        New_Conditional
  1822:                          (Condition =>
  1823:                             Transform_Prog
  1824:                               (Expr          => Iterator_Filter (LParam_Spec),
  1825:                                Expected_Type => EW_Bool_Type,
  1826:                                Params        => Params),
  1827:                           Then_Part => Final_Prog);
  1828:                   end if;
  1829:
  1830:                   declare
  1831:                      Inlined_Body : constant W_Prog_Id :=
  1832:                        (if Unroll = Unrolling_With_Condition
  1833:                         then
  1834:                           New_Conditional
  1835:                             (Condition => +Cond_Prog, Then_Part => +Final_Prog)
  1836:                         else Final_Prog);
  1837:                   begin
  1838:                      Entire_Loop :=
  1839:                        Unroll_Loop
  1840:                          (Loop_Id         => Loop_Id,
  1841:                           Loop_Index      => Loop_Index,
  1842:                           Loop_Index_Type => Loop_Index_Type,
  1843:                           Low_Val         => Low_Val,
  1844:                           High_Val        => High_Val,
  1845:                           Reversed        => Reverse_Present (LParam_Spec),
  1846:                           Body_Prog       => Inlined_Body,
  1847:                           Params          => Params);
  1848:                   end;
  1849:
  1850:                --  Regular case of a FOR loop with a loop (in)variant, or no
  1851:                --  static bounds, requiring a proof by induction.
  1852:
  1853:                else
  1854:                   --  If the loop has an iterator filter, add a statement at
  1855:                   --  the begining of the loop to skip iterations which are
  1856:                   --  filtered out. We cannot simply wrap the loop body inside
  1857:                   --  a conditionnal like for unrolled loops because the loop
  1858:                   --  invariant is only supposed to hold on enabled iterations.
  1859:
  1860:                   if Present (Iterator_Filter (LParam_Spec)) then
  1861:
  1862:                      --  If the Loop_Assertion pragma comes first in the loop
  1863:                      --  body (possibly inside nested block statements), then
  1864:                      --  we can use the filter expression as an implicit
  1865:                      --  invariant of the generated Why loop. In other cases,
  1866:                      --  we cannot, as this would not be always correct.
  1867:
  1868:                      if Is_Essentially_Void (Initial_Prog) then
  1869:                         Impl_Inv :=
  1870:                           +New_And_Expr
  1871:                              (Left   => +Impl_Inv,
  1872:                               Right  =>
  1873:                                 +Transform_Expr
  1874:                                    (Expr   => Iterator_Filter (LParam_Spec),
  1875:                                     Domain => EW_Pred,
  1876:                                     Params => Params),
  1877:                               Domain => EW_Prog);
  1878:                      end if;
  1879:
  1880:                      Prepend (Skip_Empty_Iterations, Initial_Prog);
  1881:                   end if;
  1882:
  1883:                   Entire_Loop :=
  1884:                     Wrap_Loop
  1885:                       (Loop_Id            => Loop_Id,
  1886:                        Loop_Start         => Initial_Prog,
  1887:                        Loop_End           => Final_Prog,
  1888:                        Enter_Condition    => Cond_Prog,
  1889:                        Exit_Condition     => Exit_Cond,
  1890:                        Implicit_Invariant => Impl_Inv,
  1891:                        User_Invariants    => Why_Invariants,
  1892:                        Invariant_Check    => Inv_Check,
  1893:                        Variants           =>
  1894:                          Transform_Loop_Variants (Loop_Variants),
  1895:                        Variant_Check      =>
  1896:                          Check_Loop_Variants (Loop_Variants),
  1897:                        Update_Stmt        => Update_Stmt,
  1898:                        First_Stmt         => Loop_Stmts.First_Element,
  1899:                        Next_Stmt          => Next_Stmt,
  1900:                        Last_Inv           =>
  1901:                          (if Loop_Invariants.Is_Empty
  1902:                           then Empty
  1903:                           else Loop_Invariants.Last_Element),
  1904:                        Params             => Params);
  1905:
  1906:                   Prepend (Construct_Init_Prog, Entire_Loop);
  1907:                end if;
  1908:
  1909:                --  Create new variable for iterator if needed
  1910:
  1911:                if Need_Iter then
  1912:                   Entire_Loop :=
  1913:                     New_Binding_Ref
  1914:                       (Name    => Nam_For_Iter,
  1915:                        Def     => Init_Iter,
  1916:                        Context => Entire_Loop,
  1917:                        Typ     => EW_Unit_Type);
  1918:                end if;
  1919:
  1920:                --  Bind the temporary variable used for the container
  1921:                --  expression if any.
  1922:
  1923:                if W_Container /= Why_Empty then
  1924:                   Entire_Loop :=
  1925:                     +Binding_For_Temp
  1926:                        (Ada_Node => Loop_Id,
  1927:                         Domain   => EW_Prog,
  1928:                         Tmp      => W_Container,
  1929:                         Context  => +Entire_Loop);
  1930:                end if;
  1931:
  1932:                --  Add let bindings for bounds
  1933:
  1934:                if Over_Range then
  1935:                   declare
  1936:                      Actual_Range : constant Node_Id := Get_Range (Over_Node);
  1937:                      High_Expr    : constant W_Prog_Id :=
  1938:                        Transform_Prog
  1939:                          (High_Bound (Actual_Range),
  1940:                           Loop_Index_Type,
  1941:                           Params => Params);
  1942:                      Low_Expr     : constant W_Prog_Id :=
  1943:                        Transform_Prog
  1944:                          (Low_Bound (Actual_Range),
  1945:                           Loop_Index_Type,
  1946:                           Params => Params);
  1947:                   begin
  1948:                      --  Insert assignment to high bound first, so that
  1949:                      --  assignment to low bound is done prior to assignment to
  1950:                      --  high bound in generated Why3 code. This ensures that a
  1951:                      --  common error is detected on low bound rather than high
  1952:                      --  bound, which is more intuitive.
  1953:
  1954:                      Entire_Loop :=
  1955:                        New_Typed_Binding
  1956:                          (Stmt, High_Id, High_Expr, Entire_Loop);
  1957:                      Entire_Loop :=
  1958:                        New_Typed_Binding (Stmt, Low_Id, Low_Expr, Entire_Loop);
  1959:                   end;
  1960:                end if;
  1961:
  1962:                --  For loop_parameter_specification whose
  1963:                --  discrete_subtype_definition is a subtype_indication,
  1964:                --  we generate a check that the range_constraint of the
  1965:                --  subtype_indication is compatible with the given subtype.
  1966:
  1967:                if Nkind (Over_Node) = N_Subtype_Indication then
  1968:                   Prepend
  1969:                     (Check_Subtype_Indication
  1970:                        (Params   => Params,
  1971:                         N        => Over_Node,
  1972:                         Sub_Type => Etype (Defining_Identifier (LParam_Spec))),
  1973:                      Entire_Loop);
  1974:                end if;
  1975:
  1976:                return Entire_Loop;
  1977:             end For_Loop;
  1978:          end if;
  1979:       end;
  1980:    end Transform_Loop_Statement;
  1981:
  1982:    ----------------------------
  1983:    -- Transform_Loop_Variant --
  1984:    ----------------------------
  1985:
  1986:    function Transform_Loop_Variant
  1987:      (Stmt : N_Pragma_Id; Params : Transformation_Params) return W_Variants_Id
  1988:    is
  1989:       Variant       : Opt_N_Pragma_Argument_Association_Id;
```

## src/why/gnat2why-expr.adb:1384-1460

```ada
  1384:    function Assignment_Of_Obj_Decl
  1385:      (N : N_Object_Declaration_Id) return W_Prog_Id
  1386:    is
  1387:       Lvalue   : Entity_Id := Defining_Identifier (N);
  1388:       Do_Valid : constant Boolean := Object_Has_Valid_Id (Lvalue);
  1389:       Rexpr    : constant Node_Id := Expression (N);
  1390:    begin
  1391:       --  We ignore part_of objects as a first approximation
  1392:
  1393:       if Is_Part_Of_Protected_Object (Lvalue) then
  1394:          return +Void;
  1395:       end if;
  1396:
  1397:       --  In our Why translation, all objects are declared at top-level.
  1398:       --  Object declarations in Ada inside Subprograms are therefore
  1399:       --  translated to assignments to initialize these objects.
  1400:       --  We can only generate an assignment when the Lvalue is mutable; if it
  1401:       --  is not, there are two cases. If the expression is static, we already
  1402:       --  have generated an axiom upon declaration of the object, and we are
  1403:       --  done. If it is not, we replace the assignment by an assumption of
  1404:       --  the following form:
  1405:
  1406:       --  let var_name__assume = <rexpr> in
  1407:       --    assume (var_name = var_name_assume);
  1408:
  1409:       --  Some objects have two declarations, i.e. the partial and full view of
  1410:       --  a package level object. In this case, we always use the type of the
  1411:       --  partial view.
  1412:
  1413:       if Is_Full_View (Lvalue) then
  1414:          Lvalue := Partial_View (Lvalue);
  1415:       end if;
  1416:
  1417:       if Present (Rexpr) then
  1418:          declare
  1419:             Binder   : constant Item_Type :=
  1420:               Ada_Ent_To_Why.Element (Symbol_Table, Lvalue);
  1421:             Why_Ty   : constant W_Type_Id := Why_Type_Of_Entity (Lvalue);
  1422:             Why_Expr : W_Prog_Id;
  1423:             L_Name   : constant String := Full_Name (Lvalue);
  1424:
  1425:             --  Context and validity flag to handle potentially invalid values
  1426:
  1427:             Valid_Flag : W_Expr_Id :=
  1428:               (if Do_Valid
  1429:                then +New_Valid_Value_For_Type (Etype (Lvalue))
  1430:                else Why_Empty);
  1431:             Context    : Ref_Context;
  1432:
  1433:             Res   : W_Prog_Id := +Void;
  1434:             Dummy : Boolean;
  1435:
  1436:          begin
  1437:             --  Handle the potential propagation of invalid values
  1438:
  1439:             if Propagates_Validity_Flag (N) then
  1440:                pragma Assert (Do_Valid);
  1441:                Why_Expr :=
  1442:                  +Transform_Potentially_Invalid_Expr
  1443:                     (Expr          => Rexpr,
  1444:                      Expected_Type => Why_Ty,
  1445:                      Domain        => EW_Prog,
  1446:                      Params        => Body_Params,
  1447:                      Context       => Context,
  1448:                      Valid_Flag    => Valid_Flag);
  1449:             else
  1450:                Why_Expr := Transform_Prog (Rexpr, Why_Ty, Body_Params);
  1451:             end if;
  1452:
  1453:             Insert_Move_Of_Deep_Parts
  1454:               (Rhs     => Rexpr,
  1455:                Lhs_Typ => Etype (Lvalue),
  1456:                Expr    => Why_Expr,
  1457:                Do_Move => Dummy);
  1458:
  1459:             --  Initializing an overlay havocs the overlaid object
  1460:
```

## src/why/gnat2why-expr.adb:1621-1831

```ada
  1621:
  1622:                   when UCArray                   =>
  1623:
  1624:                      --  For objects in array split form, we produce:
  1625:                      --  let <v_name>__assume = <init_value> in
  1626:                      --    <v> := of_array (<v_name>__assume);
  1627:                      --    assume (<v__first> = <v_name>__assume.first);
  1628:                      --    assume (<v__last> = <v_name>__assume.last);
  1629:
  1630:                      declare
  1631:                         Tmp_Var : constant W_Identifier_Id :=
  1632:                           New_Identifier
  1633:                             (Name => L_Name & "__assume", Typ => Why_Ty);
  1634:                      begin
  1635:                         Append
  1636:                           (Res,
  1637:                            New_Assignment
  1638:                              (Ada_Node => N,
  1639:                               Name     => Binder.Content.B_Name,
  1640:                               Labels   => Symbol_Sets.Empty_Set,
  1641:                               Value    =>
  1642:                                 +Array_Convert_To_Base (EW_Prog, +Tmp_Var),
  1643:                               Typ      => Get_Typ (Binder.Content.B_Name)));
  1644:
  1645:                         for I in 1 .. Binder.Dim loop
  1646:                            Append
  1647:                              (Res,
  1648:                               New_Assume_Statement
  1649:                                 (Ada_Node => N,
  1650:                                  Pred     =>
  1651:                                    New_Call
  1652:                                      (Name => Why_Eq,
  1653:                                       Typ  => EW_Bool_Type,
  1654:                                       Args =>
  1655:                                         (1 =>
  1656:                                            +Insert_Conversion_To_Rep_No_Bool
  1657:                                               (+Binder.Bounds (I).First),
  1658:                                          2 =>
  1659:                                            +Insert_Conversion_To_Rep_No_Bool
  1660:                                               (Get_Array_Attr
  1661:                                                  (Expr => +Tmp_Var,
  1662:                                                   Attr => Attribute_First,
  1663:                                                   Dim  => I))))),
  1664:                               New_Assume_Statement
  1665:                                 (Ada_Node => N,
  1666:                                  Pred     =>
  1667:                                    New_Call
  1668:                                      (Name => Why_Eq,
  1669:                                       Typ  => EW_Bool_Type,
  1670:                                       Args =>
  1671:                                         (1 =>
  1672:                                            +Insert_Conversion_To_Rep_No_Bool
  1673:                                               (+Binder.Bounds (I).Last),
  1674:                                          2 =>
  1675:                                            +Insert_Conversion_To_Rep_No_Bool
  1676:                                               (Get_Array_Attr
  1677:                                                  (Expr => +Tmp_Var,
  1678:                                                   Attr => Attribute_Last,
  1679:                                                   Dim  => I))))));
  1680:                         end loop;
  1681:
  1682:                         Res :=
  1683:                           New_Typed_Binding
  1684:                             (Ada_Node => N,
  1685:                              Name     => Tmp_Var,
  1686:                              Def      => Why_Expr,
  1687:                              Context  => Res);
  1688:                      end;
  1689:
  1690:                   when Pointer                   =>
  1691:
  1692:                      --  For objects in access split form, we produce:
  1693:                      --  let <v_name>__assume = <init_value> in
  1694:                      --    <v> := <v_name>__assume.value;
  1695:                      --  and either:
  1696:                      --    assume (<v__is_null> = <v_name>__assume.is_null);
  1697:                      --  if the pointer is not mutable, or:
  1698:                      --    <v__is_null> := <v_name>__assume.is_null;
  1699:                      --  otherwise.
  1700:
  1701:                      declare
  1702:                         Tmp_Var : constant W_Identifier_Id :=
  1703:                           New_Identifier
  1704:                             (Name => L_Name & "__assume", Typ => Why_Ty);
  1705:                      begin
  1706:                         Append
  1707:                           (Res,
  1708:                            New_Assignment
  1709:                              (Ada_Node => N,
  1710:                               Name     => Binder.Value.B_Name,
  1711:                               Labels   => Symbol_Sets.Empty_Set,
  1712:                               Value    =>
  1713:                                 +New_Pointer_Value_Access
  1714:                                    (Ada_Node => Empty,
  1715:                                     Domain   => EW_Term,
  1716:                                     Name     => +Tmp_Var,
  1717:                                     E        => Etype (Lvalue)),
  1718:                               Typ      => Get_Typ (Binder.Value.B_Name)));
  1719:
  1720:                         if Binder.Mutable then
  1721:                            Append
  1722:                              (Res,
  1723:                               New_Assignment
  1724:                                 (Ada_Node => N,
  1725:                                  Name     => Binder.Is_Null,
  1726:                                  Labels   => Symbol_Sets.Empty_Set,
  1727:                                  Value    =>
  1728:                                    New_Pointer_Is_Null_Access
  1729:                                      (E => Etype (Lvalue), Name => +Tmp_Var),
  1730:                                  Typ      => EW_Bool_Type));
  1731:                         else
  1732:                            Append
  1733:                              (Res,
  1734:                               New_Assume_Statement
  1735:                                 (Ada_Node => N,
  1736:                                  Pred     =>
  1737:                                    New_Call
  1738:                                      (Name => Why_Eq,
  1739:                                       Typ  => EW_Bool_Type,
  1740:                                       Args =>
  1741:                                         (1 => +Binder.Is_Null,
  1742:                                          2 =>
  1743:                                            New_Pointer_Is_Null_Access
  1744:                                              (E    => Etype (Lvalue),
  1745:                                               Name => +Tmp_Var)))));
  1746:                         end if;
  1747:
  1748:                         Res :=
  1749:                           New_Typed_Binding
  1750:                             (Ada_Node => N,
  1751:                              Name     => Tmp_Var,
  1752:                              Def      => Why_Expr,
  1753:                              Context  => Res);
  1754:                      end;
  1755:
  1756:                   when Regular | Concurrent_Self =>
  1757:                      declare
  1758:                         L_Id : constant W_Identifier_Id := Binder.Main.B_Name;
  1759:                      begin
  1760:                         if Is_Mutable_In_Why (Lvalue) then
  1761:
  1762:                            --  Attributes of record objects have the default
  1763:                            --  values of their type.
  1764:
  1765:                            Append
  1766:                              (Res,
  1767:                               New_Assignment
  1768:                                 (Ada_Node => N,
  1769:                                  Name     => L_Id,
  1770:                                  Labels   => Symbol_Sets.Empty_Set,
  1771:                                  Value    =>
  1772:                                    (if Has_Record_Type (Etype (Lvalue))
  1773:                                       or else
  1774:                                         Full_View_Not_In_SPARK (Etype (Lvalue))
  1775:                                     then
  1776:                                       New_Tag_And_Ext_Update
  1777:                                         (Ada_Node => N,
  1778:                                          Name     => Why_Expr,
  1779:                                          Ty       => Etype (Lvalue))
  1780:                                     else Why_Expr),
  1781:                                  Typ      => Why_Ty));
  1782:
  1783:                         else
  1784:                            declare
  1785:                               Tmp_Var : constant W_Identifier_Id :=
  1786:                                 New_Identifier
  1787:                                   (Name => L_Name & "__assume", Typ => Why_Ty);
  1788:                               Eq      : constant W_Pred_Id :=
  1789:                                 New_Call
  1790:                                   (Name => Why_Eq,
  1791:                                    Typ  => EW_Bool_Type,
  1792:                                    Args =>
  1793:                                      (New_Tag_And_Ext_Update
  1794:                                         (Ada_Node => N,
  1795:                                          Domain   => EW_Prog,
  1796:                                          Name     => +Tmp_Var,
  1797:                                          Ty       => Etype (Lvalue)),
  1798:                                       +L_Id));
  1799:                            begin
  1800:                               Append
  1801:                                 (Res,
  1802:                                  New_Typed_Binding
  1803:                                    (Ada_Node => N,
  1804:                                     Name     => Tmp_Var,
  1805:                                     Def      => Why_Expr,
  1806:                                     Context  =>
  1807:                                       New_Assume_Statement
  1808:                                         (Ada_Node => N, Pred => Eq)));
  1809:                            end;
  1810:                         end if;
  1811:                      end;
  1812:
  1813:                   when Subp                      =>
  1814:                      raise Program_Error;
  1815:                end case;
  1816:
  1817:                --  Add bindings for the validity wrapper if any
  1818:
  1819:                Res :=
  1820:                  +Bindings_For_Ref_Context
  1821:                     (Expr => +Res, Context => Context, Domain => EW_Prog);
  1822:
  1823:                --  Init value at end of local borrowers. This assumes the
  1824:                --  dynamic invariant of the value of the borrowed object at the
  1825:                --  end of the borrow, so it should be done after all checks at
  1826:                --  performed for the assignment so that we do not create an
  1827:                --  inconsistency.
  1828:
  1829:                if Is_Local_Borrower (Lvalue) then
  1830:                   Append
  1831:                     (Res,
```

## src/why/gnat2why-expr.adb:2329-2360

```ada
  2329:    function Assume_Dynamic_Invariant
  2330:      (Expr          : W_Term_Id;
  2331:       Ty            : Type_Kind_Id;
  2332:       Initialized   : Boolean := True;
  2333:       Valid         : W_Term_Id := Why_Empty;
  2334:       Only_Var      : Boolean := True;
  2335:       Top_Predicate : Boolean := True) return W_Prog_Id
  2336:    is
  2337:       Init  : constant W_Term_Id :=
  2338:         (if Initialized then True_Term else False_Term);
  2339:       O_Var : constant W_Term_Id :=
  2340:         (if Only_Var then True_Term else False_Term);
  2341:       T     : constant W_Pred_Id :=
  2342:         Compute_Dynamic_Inv_And_Initialization
  2343:           (Expr          => Expr,
  2344:            Ty            => Ty,
  2345:            Valid         => Valid,
  2346:            Initialized   => Init,
  2347:            Only_Var      => O_Var,
  2348:            Top_Predicate => Top_Predicate,
  2349:            Params        => Body_Params);
  2350:    begin
  2351:       if T /= True_Pred then
  2352:          return New_Assume_Statement (Ada_Node => Ty, Pred => T);
  2353:       else
  2354:          return +Void;
  2355:       end if;
  2356:    end Assume_Dynamic_Invariant;
  2357:
  2358:    --------------------------------------------
  2359:    -- Assume_Dynamic_Invariant_For_Variables --
  2360:    --------------------------------------------
```

## src/why/gnat2why-expr.adb:2669-2805

```ada
  2669:    procedure Assume_Value_Of_Constants
  2670:      (Why_Expr : in out W_Prog_Id;
  2671:       Scope    : Entity_Id;
  2672:       Params   : Transformation_Params)
  2673:    is
  2674:       Include : constant Node_Sets.Set := Compute_Ada_Node_Set (+Why_Expr);
  2675:       Assumes : W_Prog_Id := +Void;
  2676:    begin
  2677:       for N of Include loop
  2678:          if Nkind (N) in N_Entity
  2679:            and then
  2680:              ((Ekind (N) = E_Constant
  2681:                and then not Is_Access_Variable (Etype (N))
  2682:                and then not Has_Variable_Input (N)
  2683:                and then not Is_Declared_In_Unit (N, Scope))
  2684:
  2685:               --  We only consider here parameters of enclosing
  2686:               --  subprograms. Parameters of Scope are handled
  2687:               --  specifically.
  2688:
  2689:               or else
  2690:                 (Ekind (N) in Formal_Kind
  2691:                  and then Enclosing_Unit (N) /= Scope))
  2692:          then
  2693:             Assume_Declaration_Of_Entity
  2694:               (E             => N,
  2695:                Params        => Params,
  2696:                Initialized   => True,
  2697:                Top_Predicate => True,
  2698:                Context       => Assumes);
  2699:          end if;
  2700:       end loop;
  2701:
  2702:       Prepend (Assumes, Why_Expr);
  2703:    end Assume_Value_Of_Constants;
  2704:
  2705:    -------------------------------
  2706:    -- Bind_From_Mapping_In_Expr --
  2707:    -------------------------------
  2708:
  2709:    function Bind_From_Mapping_In_Expr
  2710:      (Params : Transformation_Params;
  2711:       Expr   : W_Expr_Id;
  2712:       N      : Node_Id;
  2713:       Name   : W_Identifier_Id;
  2714:       Domain : EW_Domain;
  2715:       As_Old : Boolean := False) return W_Expr_Id
  2716:    is
  2717:       Res : W_Expr_Id := Expr;
  2718:    begin
  2719:
  2720:       --  For potentially invalid expressions, also declare a binding for the
  2721:       --  validity flag.
  2722:
  2723:       if Nkind (N) = N_Defining_Identifier and then Object_Has_Valid_Id (N)
  2724:       then
  2725:          Res :=
  2726:            New_Typed_Binding
  2727:              (Name    => Name,
  2728:               Domain  => Domain,
  2729:               Def     =>
  2730:                 Insert_Simple_Conversion
  2731:                   (Domain => Prog_Or_Term_Domain (Domain),
  2732:                    Expr   =>
  2733:                      (if As_Old
  2734:                       then Transform_Attribute_Old (N, Domain, Params)
  2735:                       else
  2736:                         Transform_Identifier
  2737:                           (Params, N, N, Prog_Or_Term_Domain (Domain))),
  2738:                    To     => Get_Typ (Name)),
  2739:               Context => Res);
  2740:
  2741:          Res :=
  2742:            New_Typed_Binding
  2743:              (Name    => Get_Valid_Flag_For_Id (Name, Etype (N)),
  2744:               Domain  => Domain,
  2745:               Def     => +Get_Valid_Id_From_Object (N, Params.Ref_Allowed),
  2746:               Context => Res);
  2747:
  2748:       elsif Is_Potentially_Invalid_Expr (N)
  2749:         and then not Has_Scalar_Type (Etype (N))
  2750:       then
  2751:          declare
  2752:             Def        : W_Expr_Id;
  2753:             Valid_Flag : W_Expr_Id;
  2754:             Context    : Ref_Context;
  2755:          begin
  2756:             Transform_Potentially_Invalid_Expr
  2757:               (Expr       => N,
  2758:                Domain     => Prog_Or_Term_Domain (Domain),
  2759:                Params     => Params,
  2760:                Context    => Context,
  2761:                W_Expr     => Def,
  2762:                Valid_Flag => Valid_Flag,
  2763:                As_Old     => As_Old);
  2764:
  2765:             Res :=
  2766:               New_Typed_Binding
  2767:                 (Name    => Name,
  2768:                  Domain  => Domain,
  2769:                  Def     =>
  2770:                    Insert_Simple_Conversion
  2771:                      (Domain => Prog_Or_Term_Domain (Domain),
  2772:                       Expr   => Def,
  2773:                       To     => Get_Typ (Name)),
  2774:                  Context => Res);
  2775:
  2776:             Res :=
  2777:               New_Typed_Binding
  2778:                 (Name    => Get_Valid_Flag_For_Id (Name, Etype (N)),
  2779:                  Domain  => Domain,
  2780:                  Def     => +Valid_Flag,
  2781:                  Context => Res);
  2782:
  2783:             Res :=
  2784:               Bindings_For_Ref_Context
  2785:                 (Expr => Res, Context => Context, Domain => Domain);
  2786:          end;
  2787:       else
  2788:          Res :=
  2789:            New_Typed_Binding
  2790:              (Name    => Name,
  2791:               Domain  => Domain,
  2792:               Def     =>
  2793:                 Insert_Simple_Conversion
  2794:                   (Domain => Prog_Or_Term_Domain (Domain),
  2795:                    Expr   =>
  2796:                      (if As_Old
  2797:                       then Transform_Attribute_Old (N, Domain, Params)
  2798:                       else
  2799:                         Transform_Expr_Or_Identifier
  2800:                           (N, Prog_Or_Term_Domain (Domain), Params)),
  2801:                    To     => Get_Typ (Name)),
  2802:               Context => Res);
  2803:       end if;
  2804:
  2805:       return Res;
```

## src/why/gnat2why-expr.adb:6396-6824

```ada
  6396:    function Compute_Dynamic_Inv_And_Initialization
  6397:      (Expr           : W_Term_Id;
  6398:       Ty             : Type_Kind_Id;
  6399:       Params         : Transformation_Params;
  6400:       Initialized    : W_Term_Id := True_Term;
  6401:       Valid          : W_Term_Id := Why_Empty;
  6402:       Only_Var       : W_Term_Id := True_Term;
  6403:       Top_Predicate  : Boolean := True;
  6404:       All_Global_Inv : Boolean := True) return W_Pred_Id
  6405:    is
  6406:       Dyn_Pred : W_Pred_Id :=
  6407:         Compute_Dynamic_Invariant
  6408:           (Expr           => Expr,
  6409:            Ty             => Ty,
  6410:            Valid          => Valid,
  6411:            Initialized    => Initialized,
  6412:            Params         => Params,
  6413:            Only_Var       => Only_Var,
  6414:            Top_Predicate  => (if Top_Predicate then True_Term else False_Term),
  6415:            All_Global_Inv => All_Global_Inv);
  6416:
  6417:    begin
  6418:       --  If Expr has relaxed initialization and Initialized is True, assume
  6419:       --  the initialization of objects which are ultimately scalar and the
  6420:       --  predicate of Ty if any.
  6421:       --  For now, objects with relaxed initialization are always valid.
  6422:
  6423:       if Is_Init_Wrapper_Type (Get_Type (+Expr)) then
  6424:          declare
  6425:             Init_Pred : W_Pred_Id := True_Pred;
  6426:          begin
  6427:             if Has_Scalar_Full_View (Ty) then
  6428:
  6429:                --  Inputs of scalar types do not use the init wrapper
  6430:                pragma Assert (Top_Predicate);
  6431:
  6432:                Init_Pred :=
  6433:                  +Compute_Is_Initialized
  6434:                     (Ty,
  6435:                      +Expr,
  6436:                      Params,
  6437:                      EW_Pred,
  6438:                      Exclude_Components => Relaxed);
  6439:             elsif Has_Predicates (Ty) then
  6440:                Init_Pred :=
  6441:                  Compute_Dynamic_Predicate
  6442:                    (Expr          => Expr,
  6443:                     Ty            => Ty,
  6444:                     Top_Predicate =>
  6445:                       (if Top_Predicate then True_Term else False_Term));
  6446:             end if;
  6447:
  6448:             if Has_Mutable_Discriminants (Ty) or else Is_Access_Type (Ty) then
  6449:                Init_Pred :=
  6450:                  New_And_Pred
  6451:                    (Left  => Init_Pred,
  6452:                     Right =>
  6453:                       Pred_Of_Boolean_Term
  6454:                         (New_Init_Attribute_Access (Ty, +Expr)));
  6455:             end if;
  6456:
  6457:             if not Is_True_Boolean (+Init_Pred) then
  6458:                Dyn_Pred :=
  6459:                  New_And_Pred
  6460:                    (Dyn_Pred,
  6461:                     New_Conditional
  6462:                       (Condition => Pred_Of_Boolean_Term (Initialized),
  6463:                        Then_Part => Init_Pred));
  6464:             end if;
  6465:          end;
  6466:       end if;
  6467:
  6468:       return Dyn_Pred;
  6469:    end Compute_Dynamic_Inv_And_Initialization;
  6470:
  6471:    -------------------------------
  6472:    -- Compute_Dynamic_Invariant --
  6473:    -------------------------------
  6474:
  6475:    function Compute_Dynamic_Invariant
  6476:      (Expr           : W_Term_Id;
  6477:       Ty             : Type_Kind_Id;
  6478:       Params         : Transformation_Params;
  6479:       Initialized    : W_Term_Id := True_Term;
  6480:       Valid          : W_Term_Id := Why_Empty;
  6481:       Only_Var       : W_Term_Id := True_Term;
  6482:       Top_Predicate  : W_Term_Id := True_Term;
  6483:       All_Global_Inv : Boolean := True;
  6484:       Use_Pred       : Boolean := True) return W_Pred_Id
  6485:    is
  6486:       T                 : W_Pred_Id;
  6487:       New_Incompl_Acc   : Ada_To_Why_Ident.Map;
  6488:       New_Incompl_Acc_R : Ada_To_Why_Ident.Map;
  6489:    begin
  6490:       --  Current_Subp is used as a scope to determine which local invariants
  6491:       --  should be included in the dynamic invariant. It should be set.
  6492:
  6493:       pragma Assert (Present (Current_Subp));
  6494:
  6495:       Compute_Dynamic_Invariant
  6496:         (Expr              => Expr,
  6497:          Ty                => Ty,
  6498:          Params            => Params,
  6499:          Initialized       => Initialized,
  6500:          Valid             => Valid,
  6501:          Only_Var          => Only_Var,
  6502:          Top_Predicate     => Top_Predicate,
  6503:          All_Global_Inv    =>
  6504:            (if All_Global_Inv then True_Term else False_Term),
  6505:          Inv_Scop          => Current_Subp,
  6506:          Inv_Subp          => (if All_Global_Inv then Empty else Current_Subp),
  6507:          Use_Pred          => Use_Pred,
  6508:          New_Preds_Module  => Why_Empty,
  6509:          T                 => T,
  6510:          Loc_Incompl_Acc   => Ada_To_Why_Ident.Empty_Map,
  6511:          New_Incompl_Acc   => New_Incompl_Acc,
  6512:          Loc_Incompl_Acc_R => Ada_To_Why_Ident.Empty_Map,
  6513:          New_Incompl_Acc_R => New_Incompl_Acc_R,
  6514:          Expand_Incompl    => True);
  6515:
  6516:       pragma Assert (New_Incompl_Acc.Is_Empty);
  6517:       pragma Assert (New_Incompl_Acc_R.Is_Empty);
  6518:       return T;
  6519:    end Compute_Dynamic_Invariant;
  6520:
  6521:    procedure Compute_Dynamic_Invariant
  6522:      (Expr              : W_Term_Id;
  6523:       Ty                : Type_Kind_Id;
  6524:       Params            : Transformation_Params;
  6525:       Initialized       : W_Term_Id;
  6526:       Valid             : W_Term_Id;
  6527:       Only_Var          : W_Term_Id;
  6528:       Top_Predicate     : W_Term_Id;
  6529:       All_Global_Inv    : W_Term_Id;
  6530:       Inv_Scop          : Node_Id;
  6531:       Inv_Subp          : Node_Id;
  6532:       Use_Pred          : Boolean;
  6533:       New_Preds_Module  : W_Module_Id;
  6534:       T                 : out W_Pred_Id;
  6535:       Loc_Incompl_Acc   : Ada_To_Why_Ident.Map;
  6536:       New_Incompl_Acc   : in out Ada_To_Why_Ident.Map;
  6537:       Loc_Incompl_Acc_R : Ada_To_Why_Ident.Map;
  6538:       New_Incompl_Acc_R : in out Ada_To_Why_Ident.Map;
  6539:       Expand_Incompl    : Boolean)
  6540:    is
  6541:
  6542:       function Invariant_For_Access
  6543:         (Expr : W_Term_Id; Ty : Entity_Id) return W_Pred_Id;
  6544:       --  Generates:
  6545:       --  (not <Expr>.is_null -> Dynamic_Invariant <Expr>.value)
  6546:
  6547:       function Invariant_For_Comp
  6548:         (C_Expr : W_Term_Id;
  6549:          C_Ty   : Entity_Id;
  6550:          E      : Entity_Id;
  6551:          Idx    : W_Expr_Array) return W_Pred_Id
  6552:       with Pre => No (E) or Idx'Length = 0;
  6553:       --  @param C_Expr expression for a component
  6554:       --  @param C_Ty component type
  6555:       --  @param E record field for record component
  6556:       --  @param Idx array indices for array component
  6557:       --  @return predicate for individual components
  6558:       --          Dynamic_Invariant <C_Expr>
  6559:       --              /\ C_Expr.rec__constrained = <Is_Constrained (C_Ty)>
  6560:
  6561:       function Invariant_For_Absent_Comp
  6562:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id;
  6563:       --  Assume that components not present in discriminated records have a
  6564:       --  dummy value.
  6565:
  6566:       function Invariant_For_Comp
  6567:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; Idx : W_Expr_Array)
  6568:          return W_Pred_Id
  6569:       is (Invariant_For_Comp (C_Expr, C_Ty, Empty, Idx));
  6570:
  6571:       function Invariant_For_Comp
  6572:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id
  6573:       is (Invariant_For_Comp (C_Expr, C_Ty, E, (1 .. 0 => <>)));
  6574:
  6575:       -------------------------------
  6576:       -- Invariant_For_Absent_Comp --
  6577:       -------------------------------
  6578:
  6579:       function Invariant_For_Absent_Comp
  6580:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id
  6581:       is
  6582:          pragma Unreferenced (E);
  6583:          Dummy_Expr : W_Term_Id := +Why_Default_Value (EW_Term, C_Ty);
  6584:
  6585:       begin
  6586:          if Is_Init_Wrapper_Type (Get_Type (+C_Expr)) then
  6587:             Dummy_Expr :=
  6588:               Insert_Simple_Conversion
  6589:                 (Expr => Dummy_Expr, To => Get_Type (+C_Expr));
  6590:          end if;
  6591:
  6592:          return
  6593:            New_Comparison
  6594:              (Symbol => Why_Eq, Left => C_Expr, Right => Dummy_Expr);
  6595:       end Invariant_For_Absent_Comp;
  6596:
  6597:       --------------------------
  6598:       -- Invariant_For_Access --
  6599:       --------------------------
  6600:
  6601:       function Invariant_For_Access
  6602:         (Expr : W_Term_Id; Ty : Entity_Id) return W_Pred_Id
  6603:       is
  6604:          Value_Dyn_Inv : W_Pred_Id;
  6605:       begin
  6606:          --  ??? we can assume the value of constrained attribute if any
  6607:
  6608:          Compute_Dynamic_Invariant
  6609:            (Expr              =>
  6610:               New_Pointer_Value_Access
  6611:                 (Ada_Node => Empty, E => Ty, Name => Expr),
  6612:             Ty                => Directly_Designated_Type (Ty),
  6613:             Only_Var          => False_Term,
  6614:             Top_Predicate     => True_Term,
  6615:             All_Global_Inv    => All_Global_Inv,
  6616:             Inv_Scop          => Inv_Scop,
  6617:             Inv_Subp          => Inv_Subp,
  6618:             Initialized       => True_Term,
  6619:             Valid             => Why_Empty,
  6620:             Params            => Params,
  6621:             Use_Pred          => Use_Pred,
  6622:             New_Preds_Module  => New_Preds_Module,
  6623:             T                 => Value_Dyn_Inv,
  6624:             Loc_Incompl_Acc   => Loc_Incompl_Acc,
  6625:             New_Incompl_Acc   => New_Incompl_Acc,
  6626:             Loc_Incompl_Acc_R => Loc_Incompl_Acc_R,
  6627:             New_Incompl_Acc_R => New_Incompl_Acc_R,
  6628:             Expand_Incompl    => False);
  6629:          --  Do not expand incomplete types inside access types to avoid
  6630:          --  hitting circularity.
  6631:
  6632:          if Value_Dyn_Inv /= True_Pred then
  6633:             return
  6634:               New_Conditional
  6635:                 (Condition =>
  6636:                    New_Not
  6637:                      (Right =>
  6638:                         Pred_Of_Boolean_Term
  6639:                           (New_Pointer_Is_Null_Access
  6640:                              (E => Ty, Name => +Expr))),
  6641:                  Then_Part => Value_Dyn_Inv);
  6642:          else
  6643:             return True_Pred;
  6644:          end if;
  6645:       end Invariant_For_Access;
  6646:
  6647:       ------------------------
  6648:       -- Invariant_For_Comp --
  6649:       ------------------------
  6650:
  6651:       function Invariant_For_Comp
  6652:         (C_Expr : W_Term_Id;
  6653:          C_Ty   : Entity_Id;
  6654:          E      : Entity_Id;
  6655:          Idx    : W_Expr_Array) return W_Pred_Id
  6656:       is
  6657:          C_Valid : constant W_Term_Id :=
  6658:            (if No (Valid)
  6659:             then Why_Empty
  6660:             elsif No (E)
  6661:             then
  6662:               +New_Validity_Tree_Array_Access
  6663:                  (+Valid, Idx, Retysp (Ty), EW_Term)
  6664:             elsif Ekind (E) = E_Discriminant
  6665:               or else Comp_Has_Only_Valid_Values (E, Retysp (Ty)).Ok
  6666:             then Why_Empty
  6667:             else +New_Validity_Tree_Record_Access (+Valid, E, Retysp (Ty)));
  6668:          T_Comp  : W_Pred_Id;
  6669:       begin
  6670:          --  Recursively call Compute_Dynamic_Invariant on the composite type's
  6671:          --  components. Additional parameters are unchanged expect for
  6672:          --  Only_Var set to false (as a constant subcomponent of a variable
  6673:          --  toplevel object needs to be considered as variable too) and
  6674:          --  Top_Predicate set to true (as the decision to include or not
  6675:          --  the top predicate does not apply to subcomponents).
  6676:          --  Also discriminants and components of protected types are always
  6677:          --  initialized.
  6678:
  6679:          Compute_Dynamic_Invariant
  6680:            (Expr              => C_Expr,
  6681:             Ty                => C_Ty,
  6682:             Initialized       =>
  6683:               (if (Present (E) and then Ekind (E) = E_Discriminant)
  6684:                  or else Is_Protected_Type (Retysp (Ty))
  6685:                then True_Term
  6686:                else Initialized),
  6687:             Valid             => C_Valid,
  6688:             Only_Var          => False_Term,
  6689:             Top_Predicate     => True_Term,
  6690:             All_Global_Inv    => All_Global_Inv,
  6691:             Inv_Scop          => Inv_Scop,
  6692:             Inv_Subp          => Inv_Subp,
  6693:             Params            => Params,
  6694:             Use_Pred          => Use_Pred,
  6695:             New_Preds_Module  => New_Preds_Module,
  6696:             T                 => T_Comp,
  6697:             Loc_Incompl_Acc   => Loc_Incompl_Acc,
  6698:             New_Incompl_Acc   => New_Incompl_Acc,
  6699:             Loc_Incompl_Acc_R => Loc_Incompl_Acc_R,
  6700:             New_Incompl_Acc_R => New_Incompl_Acc_R,
  6701:             Expand_Incompl    => Expand_Incompl);
  6702:
  6703:          --  Components necessarily have the tag of their type
  6704:
  6705:          if Is_Tagged_Type (Retysp (C_Ty)) then
  6706:             pragma Assert (not Is_Class_Wide_Type (Retysp (C_Ty)));
  6707:             T_Comp :=
  6708:               New_And_Pred
  6709:                 (T_Comp,
  6710:                  New_Comparison
  6711:                    (Symbol => Why_Eq,
  6712:                     Left   =>
  6713:                       +New_Tag_Access
  6714:                          (Domain => EW_Term,
  6715:                           Name   => +C_Expr,
  6716:                           Ty     => Retysp (C_Ty)),
  6717:                     Right  => +E_Symb (E => C_Ty, S => WNE_Tag)));
  6718:          end if;
  6719:
  6720:          return T_Comp;
  6721:       end Invariant_For_Comp;
  6722:
  6723:       function Invariant_For_Array is new
  6724:         Build_Predicate_For_Array (Invariant_For_Comp);
  6725:
  6726:       function Invariant_For_Record is new
  6727:         Build_Predicate_For_Record
  6728:           (Invariant_For_Comp,
  6729:            Invariant_For_Comp,
  6730:            Invariant_For_Absent_Comp);
  6731:
  6732:       --  If Ty's fullview is in SPARK, go to its underlying type to check its
  6733:       --  kind.
  6734:
  6735:       Ty_Spec      : constant Entity_Id :=
  6736:         (if Is_Class_Wide_Type (Ty)
  6737:          then Get_Specific_Type_From_Classwide (Ty)
  6738:          else Ty);
  6739:       Ty_Ext       : constant Entity_Id := Retysp (Ty_Spec);
  6740:       Relaxed_Init : constant Boolean := Get_Relaxed_Init (Get_Type (+Expr));
  6741:       Pred_Main_Ty : constant W_Type_Id :=
  6742:         (if Relaxed_Init
  6743:          then EW_Abstract (Ty_Ext, Relaxed_Init => True)
  6744:          else Type_Of_Node (Ty_Ext));
  6745:
  6746:       Variables : Flow_Id_Sets.Set;
  6747:
  6748:       --  Start of processing for Compute_Dynamic_Invariant
  6749:
  6750:    begin
  6751:       --  If Use_Pred is true, then we already have generated a predicate
  6752:       --  for the dynamic invariant of elements of type Ty_Ext, except if the
  6753:       --  type is an itype or if it is standard boolean. We also avoid using
  6754:       --  the predicate for objects in split form as it would introduce an
  6755:       --  unnecessary conversion harmful to provers.
  6756:       --  Never use the predicate if there is a validity flag.
  6757:
  6758:       if Use_Pred
  6759:         and then not Is_Itype (Ty_Ext)
  6760:         and then not Is_Standard_Boolean_Type (Ty_Ext)
  6761:         and then Eq_Base (Pred_Main_Ty, Get_Type (+Expr))
  6762:         and then No (Valid)
  6763:       then
  6764:
  6765:          --  The generated predicate uses an empty scope for type invariants
  6766:
  6767:          Variables_In_Dynamic_Invariant (Ty_Ext, Variables, Scop => Empty);
  6768:
  6769:          declare
  6770:             Vars  : constant W_Expr_Array :=
  6771:               Get_Args_From_Variables (Variables, Params.Ref_Allowed);
  6772:             Num_B : constant Positive := 5 + Vars'Length;
  6773:             Args  : W_Expr_Array (1 .. Num_B);
  6774:
  6775:          begin
  6776:             Args (1) := +Expr;
  6777:             Args (2) := +Initialized;
  6778:             Args (3) := +Only_Var;
  6779:             Args (4) := +Top_Predicate;
  6780:             Args (5) := +All_Global_Inv;
  6781:             Args (6 .. Num_B) := Vars;
  6782:
  6783:             T :=
  6784:               New_Call
  6785:                 (Name =>
  6786:                    E_Symb
  6787:                      (E            => Ty_Ext,
  6788:                       S            => WNE_Dynamic_Invariant,
  6789:                       Relaxed_Init => Relaxed_Init),
  6790:                  Args => Args,
  6791:                  Typ  => EW_Bool_Type);
  6792:
  6793:             --  If Inv_Scop is set, add possible locally assumed type
  6794:             --  invariants. If Inv_Subp is also set, add globally assumed type
  6795:             --  invariants as they won't be included in the predicate (as
  6796:             --  All_Global_Inv is False). Include components as the traversal
  6797:             --  stops here.
  6798:
  6799:             if Present (Inv_Scop) then
  6800:                T :=
  6801:                  New_And_Pred
  6802:                    (Left  => T,
  6803:                     Right =>
  6804:                       Compute_Type_Invariant
  6805:                         (Expr,
  6806:                          Ty_Ext,
  6807:                          Locally_Assumed,
  6808:                          Params,
  6809:                          Use_Pred => Use_Pred,
  6810:                          Scop     => Inv_Scop,
  6811:                          Subp     => Inv_Subp));
  6812:             end if;
  6813:
  6814:             return;
  6815:          end;
  6816:       end if;
  6817:
  6818:       --  Dynamic property of the type itself
  6819:
  6820:       if Type_Is_Modeled_As_Base (Ty_Ext)
  6821:         or else
  6822:           (Use_Split_Form_For_Type (Ty_Ext)
  6823:            and then Get_Type_Kind (Get_Type (+Expr)) /= EW_Abstract)
  6824:       then
```

## src/why/gnat2why-expr.adb:7080-7230

```ada
  7080:       --  initialization so it can be assumed to always hold. Otherwise, the
  7081:       --  predicate is only valid for initialized data. In all cases, only
  7082:       --  assume the predicate of the type itself when the top predicate should
  7083:       --  be included. Otherwise, assume the predicate of the first ancestor
  7084:       --  only.
  7085:       --  Do not assume the predicate on composite initialization wrappers.
  7086:       --  It will be part of the 'Initialized attribute instead.
  7087:
  7088:       if not Is_Init_Wrapper_Type (Get_Type (+Expr))
  7089:         or else Has_Scalar_Full_View (Ty_Ext)
  7090:       then
  7091:          declare
  7092:             Relaxed_Init          : constant Boolean :=
  7093:               Is_Init_Wrapper_Type (Get_Type (+Expr));
  7094:             Typ_Pred              : constant W_Pred_Id :=
  7095:               Compute_Dynamic_Predicate (Expr, Ty_Ext, Params, Top_Predicate);
  7096:             Pred_Check_At_Default : constant Boolean :=
  7097:               Needs_Default_Predicate_Checks (Ty_Ext);
  7098:             Init_Flag             : constant W_Pred_Id :=
  7099:               Pred_Of_Boolean_Term
  7100:                 (if Relaxed_Init
  7101:                  then
  7102:                    +Compute_Is_Initialized
  7103:                       (Ty_Ext,
  7104:                        +Expr,
  7105:                        Params,
  7106:                        EW_Term,
  7107:                        No_Predicate_Check => True,
  7108:                        Exclude_Components => Relaxed)
  7109:                  else Initialized);
  7110:             Check_Pred            : constant W_Pred_Id :=
  7111:               (if Pred_Check_At_Default and then not Relaxed_Init
  7112:                then Typ_Pred
  7113:                else
  7114:                  New_Conditional
  7115:                    (Condition => Init_Flag,
  7116:                     Then_Part => Typ_Pred,
  7117:                     Typ       => EW_Bool_Type));
  7118:
  7119:          begin
  7120:             if not Is_True_Boolean (+Typ_Pred) then
  7121:
  7122:                --  For now, types with predicates cannot be potentially invalid
  7123:
  7124:                pragma Assert (No (Valid));
  7125:
  7126:                T := New_And_Pred (Left => T, Right => Check_Pred);
  7127:             end if;
  7128:          end;
  7129:       end if;
  7130:
  7131:       --  Add possible globally assumed type invariant. Only deal with the
  7132:       --  top-level invariants as invariants of components will be added in
  7133:       --  recursive calls.
  7134:
  7135:       if not Is_False_Boolean (+All_Global_Inv) then
  7136:          declare
  7137:             Type_Inv : W_Pred_Id :=
  7138:               Compute_Type_Invariant
  7139:                 (Expr,
  7140:                  Ty_Ext,
  7141:                  Globally_Assumed,
  7142:                  Params,
  7143:                  Include_Comp => False,
  7144:                  Use_Pred     => Use_Pred);
  7145:          begin
  7146:             if not Is_True_Boolean (+Type_Inv) then
  7147:                if not Is_True_Boolean (+All_Global_Inv) then
  7148:                   Type_Inv :=
  7149:                     New_Conditional
  7150:                       (Condition => Pred_Of_Boolean_Term (All_Global_Inv),
  7151:                        Then_Part => Type_Inv,
  7152:                        Typ       => EW_Bool_Type);
  7153:                end if;
  7154:
  7155:                T := New_And_Pred (Left => T, Right => Type_Inv);
  7156:             end if;
  7157:          end;
  7158:       end if;
  7159:
  7160:       --  If Inv_Scop is set, add possible locally assumed type invariants. If
  7161:       --  Inv_Subp is also set, add globally assumed type invariants as they
  7162:       --  won't be included in the predicate (as All_Global_Inv is False).
  7163:       --  Only deal with the top-level invariants as invariants of components
  7164:       --  will be added in recursive calls.
  7165:
  7166:       if Present (Inv_Scop) then
  7167:          T :=
  7168:            New_And_Pred
  7169:              (Left  => T,
  7170:               Right =>
  7171:                 Compute_Type_Invariant
  7172:                   (Expr,
  7173:                    Ty_Ext,
  7174:                    Locally_Assumed,
  7175:                    Params,
  7176:                    Include_Comp => False,
  7177:                    Use_Pred     => Use_Pred,
  7178:                    Scop         => Inv_Scop,
  7179:                    Subp         => Inv_Subp));
  7180:       end if;
  7181:
  7182:       --  If Ty_Ext is tagged, assume that objects of dynamic type Ty_Ext have
  7183:       --  an empty extension.
  7184:
  7185:       if Is_Tagged_Type (Ty_Ext) then
  7186:          T :=
  7187:            New_And_Pred
  7188:              (Left  => T,
  7189:               Right =>
  7190:                 New_Conditional
  7191:                   (Condition =>
  7192:                      New_Comparison
  7193:                        (Symbol => Why_Eq,
  7194:                         Left   =>
  7195:                           +New_Tag_Access
  7196:                              (Domain => EW_Term, Name => +Expr, Ty => Ty_Ext),
  7197:                         Right  => +E_Symb (Ty_Ext, WNE_Tag)),
  7198:                    Then_Part =>
  7199:                      New_Comparison
  7200:                        (Symbol => Why_Eq,
  7201:                         Left   =>
  7202:                           +New_Ext_Access
  7203:                              (Name =>
  7204:                                 New_Fields_Access
  7205:                                   (Name => +Expr, Ty => Ty_Ext),
  7206:                               Ty   => Ty_Ext),
  7207:                         Right  => +E_Symb (Ty_Ext, WNE_Null_Extension))));
  7208:       end if;
  7209:
  7210:       --  Compute dynamic invariant for its components
  7211:
  7212:       if Is_Array_Type (Ty_Ext)
  7213:         and then Ekind (Ty_Ext) /= E_String_Literal_Subtype
  7214:       then
  7215:          --  Add the well_formed property of the array type
  7216:
  7217:          T := New_And_Pred (Left => T, Right => New_Well_Formed_Pred (Expr));
  7218:
  7219:          --  Generates:
  7220:          --  forall i1 .. in : int. in_range i1 /\ .. /\ in_range in ->
  7221:          --    Dynamic_Invariant (get <Expr> i1 .. in)
  7222:
  7223:          T :=
  7224:            New_And_Pred
  7225:              (Left => T, Right => Invariant_For_Array (Expr, Ty_Ext));
  7226:
  7227:       elsif Is_Record_Type (Ty_Ext)
  7228:         or else Is_Incomplete_Or_Private_Type (Ty_Ext)
  7229:         or else Is_Concurrent_Type (Ty_Ext)
  7230:       then
```

## src/why/gnat2why-expr.adb:7503-7600

```ada
  7503:    function Compute_Dynamic_Predicate
  7504:      (Expr          : W_Term_Id;
  7505:       Ty            : Type_Kind_Id;
  7506:       Params        : Transformation_Params := Body_Params;
  7507:       Top_Predicate : W_Term_Id := True_Term) return W_Pred_Id
  7508:    is
  7509:       Res : W_Pred_Id := True_Pred;
  7510:
  7511:       procedure Add_One_Dynamic_Predicate
  7512:         (Type_Instance : Formal_Kind_Id; Pred_Expression : Node_Id);
  7513:       --  Add the current dynamic predicate as a conjuct in Res
  7514:
  7515:       -------------------------------
  7516:       -- Add_One_Dynamic_Predicate --
  7517:       -------------------------------
  7518:
  7519:       procedure Add_One_Dynamic_Predicate
  7520:         (Type_Instance : Formal_Kind_Id; Pred_Expression : Node_Id)
  7521:       is
  7522:          Dyn_Pred  : W_Pred_Id;
  7523:          My_Params : Transformation_Params := Params;
  7524:       begin
  7525:          --  We set the Gen_Marker param to GM_Toplevel to instruct
  7526:          --  the translation to generate pretty-printing labels for
  7527:          --  the parts of the predicate. We also indicate that the
  7528:          --  predicate is effectively inlined here by using the
  7529:          --  GP_Inlined_Marker (this last part avoids using the
  7530:          --  location of the predicate to place the error message,
  7531:          --  which is not desired here).
  7532:
  7533:          My_Params.Gen_Marker := GM_Toplevel;
  7534:          Dyn_Pred :=
  7535:            Dynamic_Predicate_Expression
  7536:              (Expr       => Expr,
  7537:               Pred_Param => Type_Instance,
  7538:               Pred_Expr  => Pred_Expression,
  7539:               Params     => My_Params);
  7540:
  7541:          --  Ignore the top-level predicate if needed
  7542:
  7543:          if Is_False_Boolean (+Top_Predicate)
  7544:            and then Retysp (Etype (Type_Instance)) = Retysp (Ty)
  7545:          then
  7546:             return;
  7547:          elsif not Is_True_Boolean (+Top_Predicate)
  7548:            and then Retysp (Etype (Type_Instance)) = Retysp (Ty)
  7549:          then
  7550:             Dyn_Pred :=
  7551:               New_Conditional
  7552:                 (Condition => Pred_Of_Boolean_Term (Top_Predicate),
  7553:                  Then_Part => Dyn_Pred);
  7554:          end if;
  7555:
  7556:          Res :=
  7557:            New_Label
  7558:              (Labels => Symbol_Sets.To_Set (NID (GP_Inlined_Marker)),
  7559:               Def    => New_And_Pred (Left => Dyn_Pred, Right => Res));
  7560:       end Add_One_Dynamic_Predicate;
  7561:
  7562:       procedure Add_All_Dynamic_Predicates is new
  7563:         Iterate_Applicable_Predicates (Add_One_Dynamic_Predicate);
  7564:
  7565:       Rep_Ty : constant Entity_Id := Retysp (Ty);
  7566:    begin
  7567:       Add_All_Dynamic_Predicates (Rep_Ty);
  7568:
  7569:       --  Assume that the object is initialized if it is necessary to check the
  7570:       --  predicate.
  7571:
  7572:       if Has_Predicates (Rep_Ty)
  7573:         and then Predicate_Requires_Initialization (Rep_Ty)
  7574:         and then Is_Init_Wrapper_Type (Get_Type (+Expr))
  7575:       then
  7576:          Res :=
  7577:            New_And_Pred
  7578:              (Left  =>
  7579:                 +Compute_Is_Initialized
  7580:                    (E                  => Rep_Ty,
  7581:                     Name               => +Expr,
  7582:                     Params             => Params,
  7583:                     Domain             => EW_Pred,
  7584:                     Exclude_Components => Relaxed,
  7585:                     No_Predicate_Check => True),
  7586:               Right => Res);
  7587:       end if;
  7588:
  7589:       return Res;
  7590:    end Compute_Dynamic_Predicate;
  7591:
  7592:    -------------------------------
  7593:    -- Compute_Exceptional_Store --
  7594:    -------------------------------
  7595:
  7596:    procedure Compute_Exceptional_Store
  7597:      (Formal         : Formal_Kind_Id;
  7598:       Pattern        : Item_Type;
  7599:       Actual         : N_Subexpr_Id;
  7600:       Need_Store     : Boolean;
```

## src/why/gnat2why-expr.adb:8782-8999

```ada
  8782:    function Compute_Type_Invariant
  8783:      (Expr         : W_Term_Id;
  8784:       Ty           : Type_Kind_Id;
  8785:       Kind         : Invariant_Kind;
  8786:       Params       : Transformation_Params := Body_Params;
  8787:       Scop         : Entity_Id := Empty;
  8788:       Subp         : Entity_Id := Empty;
  8789:       Include_Comp : Boolean := True;
  8790:       Use_Pred     : Boolean := True) return W_Pred_Id
  8791:    is
  8792:       function Include_Inv (Ty : Type_Kind_Id) return Boolean
  8793:       with Pre => Has_Invariants_In_SPARK (Ty);
  8794:       --  Return True if the top-level invariant of Ty shall be considered
  8795:
  8796:       function Comp_Has_Included_Inv (Ty : Type_Kind_Id) return Test_Result;
  8797:       --  Return Pass if Ty or one of its ancestors has a considered invariant
  8798:
  8799:       function Invariant_For_Comp
  8800:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id;
  8801:       --  @param C_Expr expression for a component
  8802:       --  @param C_Ty component type
  8803:       --  @param E not referenced
  8804:       --  @return predicate for individual components
  8805:
  8806:       function Invariant_For_Comp
  8807:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; Dummy : W_Expr_Array)
  8808:          return W_Pred_Id
  8809:       is (Invariant_For_Comp (C_Expr, C_Ty, Empty));
  8810:
  8811:       ---------------------------
  8812:       -- Comp_Has_Included_Inv --
  8813:       ---------------------------
  8814:
  8815:       function Comp_Has_Included_Inv (Ty : Type_Kind_Id) return Test_Result is
  8816:          Current : Entity_Id := Ty;
  8817:          Parent  : Entity_Id;
  8818:       begin
  8819:          loop
  8820:             if Has_Invariants_In_SPARK (Current) and then Include_Inv (Current)
  8821:             then
  8822:                return Pass;
  8823:             end if;
  8824:
  8825:             Parent := Retysp (Etype (Current));
  8826:             exit when Current = Parent;
  8827:             Current := Parent;
  8828:          end loop;
  8829:          return Continue;
  8830:       end Comp_Has_Included_Inv;
  8831:
  8832:       -----------------
  8833:       -- Include_Inv --
  8834:       -----------------
  8835:
  8836:       function Include_Inv (Ty : Type_Kind_Id) return Boolean
  8837:       is (if Invariant_Assumed_In_Main (Ty)
  8838:           then
  8839:             Kind = Globally_Assumed
  8840:             or else
  8841:               (Present (Subp)
  8842:                and then Kind = Locally_Assumed
  8843:                and then not Invariant_Relaxed_For_Subprogram (Ty, Subp))
  8844:           elsif Present (Scop) and then Invariant_Assumed_In_Scope (Ty, Scop)
  8845:           then Kind = Locally_Assumed
  8846:           else
  8847:             Kind = For_Check
  8848:             and then
  8849:               (No (Subp)
  8850:                or else not Invariant_Relaxed_For_Subprogram (Ty, Subp)));
  8851:
  8852:       ------------------------
  8853:       -- Invariant_For_Comp --
  8854:       ------------------------
  8855:
  8856:       function Invariant_For_Comp
  8857:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id
  8858:       is (Compute_Type_Invariant
  8859:             (C_Expr, C_Ty, Kind, Params, Scop => Scop, Subp => Subp));
  8860:
  8861:       function Invariant_For_Array is new
  8862:         Build_Predicate_For_Array (Invariant_For_Comp);
  8863:
  8864:       function Invariant_For_Record is new
  8865:         Build_Predicate_For_Record (Invariant_For_Comp, Invariant_For_Comp);
  8866:
  8867:       function Type_Contains_Included_Inv is new
  8868:         Traverse_Subcomponents (Comp_Has_Included_Inv);
  8869:
  8870:       Rep_Ty : constant Entity_Id := Retysp (Ty);
  8871:       --  If Ty's fullview is in SPARK, go to its underlying type to check its
  8872:       --  kind.
  8873:
  8874:       Pred : W_Pred_Id := True_Pred;
  8875:
  8876:       --  Start of processing for Compute_Type_Invariant
  8877:
  8878:    begin
  8879:       --  Check for invariants on the type and its ancestors
  8880:
  8881:       declare
  8882:          Current : Entity_Id := Rep_Ty;
  8883:          Parent  : Entity_Id;
  8884:       begin
  8885:          loop
  8886:             if Has_Invariants_In_SPARK (Current) and then Include_Inv (Current)
  8887:             then
  8888:                Pred :=
  8889:                  New_And_Pred
  8890:                    (Left  => Pred,
  8891:                     Right =>
  8892:                       Compute_Top_Level_Type_Invariant
  8893:                         (Insert_Simple_Conversion
  8894:                            (Expr => Expr, To => Type_Of_Node (Current)),
  8895:                          Current,
  8896:                          Params,
  8897:                          Use_Pred => Use_Pred));
  8898:             end if;
  8899:
  8900:             Parent := Retysp (Etype (Current));
  8901:             exit when Current = Parent;
  8902:             Current := Parent;
  8903:          end loop;
  8904:       end;
  8905:
  8906:       --  Check for invariants on components
  8907:
  8908:       if Include_Comp then
  8909:
  8910:          --  For array types, produce:
  8911:          --  (forall i1, i2 .... in_range1 (i1) /\ inrange2 (i2) /\ ... ->
  8912:          --      invariant (a (i1, i2, ...)))
  8913:
  8914:          if Is_Array_Type (Rep_Ty) then
  8915:
  8916:             Pred :=
  8917:               New_And_Pred
  8918:                 (Left => Pred, Right => Invariant_For_Array (Expr, Rep_Ty));
  8919:
  8920:          --  For record types, produce:
  8921:          --  invariant (r.d1) /\ ...
  8922:          --      /\ (check_for_f1 (r) -> invariant (r.f1)) /\ ...
  8923:
  8924:          elsif Is_Incomplete_Or_Private_Type (Rep_Ty)
  8925:            or else Is_Record_Type (Rep_Ty)
  8926:            or else Is_Concurrent_Type (Rep_Ty)
  8927:          then
  8928:
  8929:             Pred :=
  8930:               New_And_Pred
  8931:                 (Left => Pred, Right => Invariant_For_Record (Expr, Rep_Ty));
  8932:
  8933:          --  For access types, produce:
  8934:          --      not r.is_null -> invariant (r.pointer_value)
  8935:          --
  8936:          --  We do not consider access to incomplete types. Indeed, these
  8937:          --  access types cannot contain types for which an invariant check
  8938:          --  is needed (see tool limitations). Supporting access to incomplete
  8939:          --  type here would require either disallowing or handling recursive
  8940:          --  structures.
  8941:
  8942:          elsif Is_Access_Type (Rep_Ty)
  8943:            and then not Is_Access_Subprogram_Type (Rep_Ty)
  8944:          then
  8945:
  8946:             --  Introduce a sanity checking to make sure that we are not
  8947:             --  missing any invariant on access-to-incomplete types.
  8948:
  8949:             if Designates_Incomplete_Type (Rep_Ty) then
  8950:
  8951:                if Type_Contains_Included_Inv
  8952:                     (Directly_Designated_Type (Rep_Ty))
  8953:                then
  8954:                   pragma
  8955:                     Assert (Kind = Locally_Assumed and then Present (Subp));
  8956:                   Error_Msg_N
  8957:                     ("& cannot be used in SPARK",
  8958:                      Subp,
  8959:                      Names         => [Rep_Ty],
  8960:                      Kind          => Error_Kind,
  8961:                      Continuations =>
  8962:                        ["access to incomplete or private type which needs"
  8963:                         & " an invariant check is not yet supported"]);
  8964:                end if;
  8965:
  8966:             else
  8967:                declare
  8968:                   C_Expr   : constant W_Term_Id :=
  8969:                     New_Pointer_Value_Access
  8970:                       (Ada_Node => Empty, E => Rep_Ty, Name => Expr);
  8971:                   Comp_Inv : constant W_Pred_Id :=
  8972:                     Invariant_For_Comp
  8973:                       (C_Expr, Directly_Designated_Type (Rep_Ty), Empty);
  8974:                begin
  8975:                   if Comp_Inv /= True_Pred then
  8976:                      Pred :=
  8977:                        New_And_Pred
  8978:                          (Left  => Pred,
  8979:                           Right =>
  8980:                             New_Conditional
  8981:                               (Condition =>
  8982:                                  New_Not
  8983:                                    (Right =>
  8984:                                       Pred_Of_Boolean_Term
  8985:                                         (New_Pointer_Is_Null_Access
  8986:                                            (E => Rep_Ty, Name => +Expr))),
  8987:                                Then_Part => Comp_Inv));
  8988:                   end if;
  8989:                end;
  8990:             end if;
  8991:          end if;
  8992:       end if;
  8993:
  8994:       return Pred;
  8995:    end Compute_Type_Invariant;
  8996:
  8997:    ------------------------------
  8998:    -- Count_Numerical_Variants --
  8999:    ------------------------------
```

## src/why/gnat2why-expr.adb:11736-11778

```ada
 11736:             pragma Assert (Has_Scalar_Type (Typ));
 11737:             return True_Pred;
 11738:          end if;
 11739:       end Compute_Type_Invariant_For_Eq;
 11740:
 11741:       --  Start of processing for Insert_Invariant_Check_For_Eq
 11742:
 11743:    begin
 11744:       if Domain /= EW_Prog
 11745:         or else not Invariant_Check_Needed (Typ, Scop => Current_Subp)
 11746:       then
 11747:          return W_Expr;
 11748:
 11749:       else
 11750:          declare
 11751:             W_Tmp : constant W_Expr_Id := New_Temp_For_Expr (+W_Expr);
 11752:             Inv   : constant W_Pred_Id :=
 11753:               Compute_Type_Invariant_For_Eq
 11754:                 (Retysp (Typ), +W_Tmp, Skip_Top_Level => Force_Predefined);
 11755:          begin
 11756:             if Is_True_Boolean (+Inv) then
 11757:                return W_Expr;
 11758:             else
 11759:                return
 11760:                  +Binding_For_Temp
 11761:                     (Ada_Node => Ada_Node,
 11762:                      Tmp      => +W_Tmp,
 11763:                      Context  =>
 11764:                        Sequence
 11765:                          (New_Ignore
 11766:                             (Prog =>
 11767:                                New_Assert
 11768:                                  (Pred        =>
 11769:                                     New_VC_Pred
 11770:                                       (Ada_Node, Inv, VC_Invariant_Check),
 11771:                                   Assert_Kind => EW_Assert)),
 11772:                           +W_Tmp));
 11773:             end if;
 11774:          end;
 11775:       end if;
 11776:    end Insert_Invariant_Check_For_Eq;
 11777:
 11778:    -------------------------------
```

## src/why/gnat2why-expr.adb:11961-12034

```ada
 11961:       end Collect_Moved_Objects;
 11962:
 11963:       -----------------
 11964:       -- Tmp_Of_Expr --
 11965:       -----------------
 11966:
 11967:       function Tmp_Of_Expr (Expr : W_Expr_Id) return W_Identifier_Id is
 11968:          Typ : constant W_Type_Id := Get_Type (+Expr);
 11969:       begin
 11970:          return New_Temp_Identifier (Typ => Typ, Base_Name => "for_move");
 11971:       end Tmp_Of_Expr;
 11972:
 11973:       --  Local variables
 11974:
 11975:       Nested_Moved : Node_Sets.Set;
 11976:       Checks       : W_Prog_Id := +Void;
 11977:       Tmp          : constant W_Identifier_Id := Tmp_Of_Expr (+Expr);
 11978:       Init         : constant W_Prog_Id := Expr;
 11979:
 11980:       --  Start of processing for Insert_Move_Of_Deep_Parts
 11981:
 11982:    begin
 11983:       --  There is no move at all for a borrow or observe
 11984:
 11985:       if Is_Anonymous_Access_Type (Lhs_Typ) then
 11986:          Do_Move := False;
 11987:
 11988:       --  If Rhs can be moved, do it
 11989:
 11990:       elsif Can_Be_Moved (Rhs) then
 11991:          Do_Move := True;
 11992:          Expr := Sequence (Move_Expression (Rhs, Tmp), +Tmp);
 11993:
 11994:       --  Otherwise, collect all deep objects potentially moved inside an
 11995:       --  aggregate.
 11996:
 11997:       else
 11998:          Collect_Moved_Objects (Rhs, Set => Nested_Moved, Checks => Checks);
 11999:          Do_Move := not Nested_Moved.Is_Empty;
 12000:
 12001:          if Do_Move then
 12002:             Expr := +Tmp;
 12003:
 12004:             for Obj of Nested_Moved loop
 12005:                declare
 12006:                   Obj_Expr : constant W_Expr_Id :=
 12007:                     Transform_Expr (Obj, EW_Term, Body_Params);
 12008:                   Obj_Tmp  : constant W_Identifier_Id :=
 12009:                     Tmp_Of_Expr (Obj_Expr);
 12010:                begin
 12011:                   Expr :=
 12012:                     New_Binding
 12013:                       (Name    => +Obj_Tmp,
 12014:                        Def     => +Obj_Expr,
 12015:                        Context =>
 12016:                          Sequence (Move_Expression (Obj, Obj_Tmp), Expr),
 12017:                        Typ     => Get_Type (+Expr));
 12018:                end;
 12019:             end loop;
 12020:          end if;
 12021:
 12022:          Expr := Sequence (Checks, Expr);
 12023:       end if;
 12024:
 12025:       if Do_Move then
 12026:          Expr :=
 12027:            New_Binding
 12028:              (Name    => Tmp,
 12029:               Def     => Init,
 12030:               Context => Expr,
 12031:               Typ     => Get_Type (+Expr));
 12032:       end if;
 12033:    end Insert_Move_Of_Deep_Parts;
 12034:
```

## src/why/gnat2why-expr.adb:2864-2894

```ada
  2864:    function Bind_From_Mapping_In_Prog
  2865:      (Params : Transformation_Params;
  2866:       Map    : Loop_Entry_Values;
  2867:       Expr   : W_Prog_Id) return W_Prog_Id
  2868:    is
  2869:       Result : W_Prog_Id := Expr;
  2870:
  2871:    begin
  2872:       for C in Map.No_Checks.Iterate loop
  2873:          Result :=
  2874:            +Bind_From_Mapping_In_Expr
  2875:               (Params => Params,
  2876:                Expr   => +Result,
  2877:                N      => Ada_To_Why_Ident.Key (C),
  2878:                Name   => Ada_To_Why_Ident.Element (C),
  2879:                Domain => EW_Pterm,
  2880:                As_Old => False);
  2881:       end loop;
  2882:
  2883:       for C in Map.Regular.Iterate loop
  2884:          Result :=
  2885:            +Bind_From_Mapping_In_Expr
  2886:               (Params => Params,
  2887:                Expr   => +Result,
  2888:                N      => Ada_To_Why_Ident.Key (C),
  2889:                Name   => Ada_To_Why_Ident.Element (C),
  2890:                Domain => EW_Prog,
  2891:                As_Old => False);
  2892:       end loop;
  2893:
  2894:       return Result;
```

## src/why/gnat2why-expr.adb:12039-12056

```ada
 12039:    function Insert_Overflow_Check
 12040:      (Ada_Node : Node_Id;
 12041:       T        : W_Expr_Id;
 12042:       In_Type  : Type_Kind_Id;
 12043:       Is_Float : Boolean) return W_Prog_Id
 12044:    is
 12045:       Base : constant Entity_Id := Base_Type (In_Type);
 12046:
 12047:    begin
 12048:       return
 12049:         New_VC_Call
 12050:           (Ada_Node => Ada_Node,
 12051:            Name     => E_Symb (Base, WNE_Range_Check_Fun),
 12052:            Progs    => (1 => T),
 12053:            Reason   =>
 12054:              (if Is_Float then VC_FP_Overflow_Check else VC_Overflow_Check),
 12055:            Typ      => Get_Type (T));
 12056:    end Insert_Overflow_Check;
```

## src/why/gnat2why-expr.adb:12286-12368

```ada
 12286:    function New_Assignment
 12287:      (Ada_Node    : Node_Id := Empty;
 12288:       Lvalue      : N_Subexpr_Id;
 12289:       Expr        : W_Prog_Id;
 12290:       Do_Check    : Do_Check_Kind := All_Checks;
 12291:       Preserv_Tag : Boolean := True;
 12292:       Index_Map   : Ada_Node_To_Why_Id.Map := Ada_Node_To_Why_Id.Empty_Map)
 12293:       return W_Prog_Id
 12294:    is
 12295:       --  Here, we deal with assignment statements. In SPARK, the general form
 12296:       --  of an assignment is
 12297:       --
 12298:       --    Lvalue := Expr;
 12299:       --
 12300:       --  where Lvalue is a mix of array and record accesses. If we adopt the
 12301:       --  same notation for both, we obtain the general form
 12302:       --
 12303:       --    Prefix.Acc1.Acc2.(...).Accn := Expr;
 12304:       --
 12305:       --  where the Acc(i) are either array accesses using an index (or
 12306:       --  several indices in the multidimensional case) or record accesses
 12307:       --  using a field name.
 12308:       --
 12309:       --  Here, we generate Why code of the form
 12310:       --
 12311:       --    Prefix := Upd (Prefix, Acc1,
 12312:       --                   (Upd (Prefix.Acc1, Acc2,
 12313:       --                         Upd (..., Accn, Expr))));
 12314:
 12315:       Left_Side   : Node_Id := Lvalue;
 12316:       Right_Side  : W_Expr_Id := +Expr;
 12317:       Last_Access : Node_Id := Empty;
 12318:       Result      : W_Prog_Id := +Void;
 12319:       Domain      : constant EW_Domain :=
 12320:         (if Do_Check = No_Checks then EW_Pterm else EW_Prog);
 12321:
 12322:       --  Start of processing for New_Assignment
 12323:
 12324:    begin
 12325:       --  If Preserv_Tag is set, preserve the tag and extension of objects if
 12326:       --  they have a specific tagged type.
 12327:
 12328:       if Preserv_Tag
 12329:         and then Is_Tagged_Type (Etype (Left_Side))
 12330:         and then not Is_Class_Wide_Type (Etype (Left_Side))
 12331:       then
 12332:          declare
 12333:             Typ      : constant Entity_Id := Etype (Left_Side);
 12334:             Old_Left : constant W_Expr_Id :=
 12335:               Transform_Expr (Left_Side, EW_Pterm, Body_Params);
 12336:          begin
 12337:             Right_Side :=
 12338:               New_Tag_And_Ext_Update
 12339:                 (Ada_Node  => Ada_Node,
 12340:                  Domain    => Domain,
 12341:                  Name      => Right_Side,
 12342:                  From_Expr => Old_Left,
 12343:                  Ty        => Typ);
 12344:          end;
 12345:       end if;
 12346:
 12347:       while not (Nkind (Left_Side) in N_Identifier | N_Expanded_Name) loop
 12348:          Shift_Rvalue
 12349:            (Left_Side,
 12350:             Right_Side,
 12351:             Last_Access,
 12352:             Domain,
 12353:             Check_Prefix => Do_Check = All_Checks,
 12354:             Index_Map    => Index_Map);
 12355:       end loop;
 12356:
 12357:       --  In those cases where the left-hand side is type converted, the type
 12358:       --  of the Left_Side and Right_Side may not coincide here. Convert the
 12359:       --  Right_Side to the type of the Left_Side. Possible checks were taken
 12360:       --  into account before.
 12361:
 12362:       Right_Side :=
 12363:         Insert_Simple_Conversion
 12364:           (Domain => EW_Pterm,
 12365:            To     => Type_Of_Node (Left_Side),
 12366:            Expr   => Right_Side);
 12367:
 12368:       --  In the case of protected components, we have to generate the record
```

## src/why/gnat2why-expr.adb:12402-12440

```ada
 12402:               Ada_Ent_To_Why.Element (Symbol_Table, Entity (Left_Side));
 12403:          begin
 12404:             case Binder.Kind is
 12405:                when Regular                =>
 12406:                   Append
 12407:                     (Result,
 12408:                      New_Assignment
 12409:                        (Ada_Node => Ada_Node,
 12410:                         Name     => Binder.Main.B_Name,
 12411:                         Labels   => Symbol_Sets.Empty_Set,
 12412:                         Value    => +Right_Side,
 12413:                         Typ      => Get_Typ (Binder.Main.B_Name)));
 12414:
 12415:                when UCArray                =>
 12416:                   Append
 12417:                     (Result,
 12418:                      New_Assignment
 12419:                        (Ada_Node => Ada_Node,
 12420:                         Name     => Binder.Content.B_Name,
 12421:                         Labels   => Symbol_Sets.Empty_Set,
 12422:                         Value    =>
 12423:                           +Array_Convert_To_Base
 12424:                              (Ar => Right_Side, Domain => EW_Prog),
 12425:                         Typ      => Get_Typ (Binder.Content.B_Name)));
 12426:
 12427:                when DRecord                =>
 12428:                   declare
 12429:                      Tmp : constant W_Prog_Id :=
 12430:                        New_Temp_For_Expr (+Right_Side);
 12431:
 12432:                   begin
 12433:                      pragma
 12434:                        Assert
 12435:                          (No (Last_Access)
 12436:                           or else
 12437:                             (Nkind (Last_Access) = N_Selected_Component
 12438:                              and then
 12439:                                Ekind (Entity (Selector_Name (Last_Access)))
 12440:                                /= E_Discriminant));
```

## src/why/gnat2why-expr.adb:14857-14920

```ada
 14857:    function Range_Expr
 14858:      (N      : Node_Id;
 14859:       T      : W_Expr_Id;
 14860:       Domain : EW_Domain;
 14861:       Params : Transformation_Params;
 14862:       T_Type : W_Type_OId := Why_Empty) return W_Expr_Id
 14863:    is
 14864:       Subdomain  : constant EW_Domain :=
 14865:         (if Domain = EW_Pred then EW_Term else Domain);
 14866:       Range_Node : constant Node_Id := Get_Range (N);
 14867:       Low        : constant Node_Id := Low_Bound (Range_Node);
 14868:       High       : constant Node_Id := High_Bound (Range_Node);
 14869:       Base_Type  : W_Type_Id := Base_Why_Type (Low, High);
 14870:
 14871:       R : W_Expr_Id;
 14872:
 14873:    begin
 14874:       if T_Type /= Why_Empty then
 14875:          Base_Type := Base_Why_Type (T_Type, Base_Type);
 14876:       end if;
 14877:
 14878:       --  Another special case for booleans: The above base type computations
 14879:       --  return "bool" for Standard_Boolean, but in fact for a boolean range
 14880:       --  we still want to have "int" here.
 14881:
 14882:       if Base_Type = EW_Bool_Type then
 14883:          Base_Type := EW_Int_Type;
 14884:       end if;
 14885:
 14886:       declare
 14887:          Low_Expr  : constant W_Expr_Id :=
 14888:            Transform_Expr (Low, Base_Type, Subdomain, Params);
 14889:          High_Expr : constant W_Expr_Id :=
 14890:            Transform_Expr (High, Base_Type, Subdomain, Params);
 14891:       begin
 14892:          R :=
 14893:            New_Range_Expr
 14894:              (Domain => Domain,
 14895:               Low    => Low_Expr,
 14896:               High   => High_Expr,
 14897:               Expr   =>
 14898:                 Insert_Simple_Conversion
 14899:                   (Domain => Subdomain, Expr => T, To => Base_Type));
 14900:       end;
 14901:
 14902:       --  In programs, we generate a check that the range_constraint of a
 14903:       --  subtype_indication is compatible with the given subtype.
 14904:
 14905:       if Domain = EW_Prog and then Nkind (N) = N_Subtype_Indication then
 14906:          Prepend
 14907:            (Check_Subtype_Indication
 14908:               (Params => Params, N => N, Sub_Type => Etype (N)),
 14909:             R);
 14910:       end if;
 14911:
 14912:       return R;
 14913:    end Range_Expr;
 14914:
 14915:    ----------------------------------
 14916:    -- Reconstruct_Actual_From_Item --
 14917:    ----------------------------------
 14918:
 14919:    function Reconstruct_Actual_From_Item
 14920:      (Pattern   : Item_Type;
```

## src/why/gnat2why-expr.adb:18547-18735

```ada
 18547:    function Transform_Array_Comparison
 18548:      (Op       : N_Op_Compare;
 18549:       Left     : W_Expr_Id;
 18550:       Right    : W_Expr_Id;
 18551:       Domain   : EW_Domain;
 18552:       Ada_Node : Node_Id) return W_Expr_Id
 18553:    is
 18554:       Subdomain : constant EW_Domain :=
 18555:         (if Domain = EW_Pred then EW_Term else Domain);
 18556:       Args      : W_Expr_Array (1 .. 6);
 18557:       T         : W_Expr_Id;
 18558:
 18559:       --  Check that operands are initialized
 18560:
 18561:       Left_Type  : constant Entity_Id := Etype (Left_Opnd (Ada_Node));
 18562:       Left_Expr  : constant W_Expr_Id :=
 18563:         New_Temp_For_Expr
 18564:           (Insert_Initialization_Check
 18565:              (Left_Opnd (Ada_Node),
 18566:               Left_Type,
 18567:               Left,
 18568:               Domain,
 18569:               Exclude_Components => None));
 18570:       Right_Expr : constant W_Expr_Id :=
 18571:         New_Temp_For_Expr
 18572:           (Insert_Initialization_Check
 18573:              (Right_Opnd (Ada_Node),
 18574:               Etype (Right_Opnd (Ada_Node)),
 18575:               Right,
 18576:               Domain,
 18577:               Exclude_Components => None));
 18578:       Arg_Ind    : Positive := 1;
 18579:    begin
 18580:       Add_Array_Arg (Subdomain, Args, Left_Expr, Arg_Ind);
 18581:       Add_Array_Arg (Subdomain, Args, Right_Expr, Arg_Ind);
 18582:
 18583:       --  Add conversions from wrapper types if needed. Initialization checks
 18584:       --  are inserted earlier.
 18585:
 18586:       if Is_Init_Wrapper_Type (Get_Type (Left_Expr)) then
 18587:          Args (1) :=
 18588:            New_Call
 18589:              (Ada_Node => Ada_Node,
 18590:               Domain   => Subdomain,
 18591:               Name     => Get_Array_Of_Wrapper_Name (Left_Type),
 18592:               Args     => (1 => Args (1)),
 18593:               Typ      => EW_Split (Left_Type));
 18594:       end if;
 18595:       if Is_Init_Wrapper_Type (Get_Type (Right_Expr)) then
 18596:          Args (4) :=
 18597:            New_Call
 18598:              (Ada_Node => Ada_Node,
 18599:               Domain   => Subdomain,
 18600:               Name     => Get_Array_Of_Wrapper_Name (Left_Type),
 18601:               Args     => (1 => Args (4)),
 18602:               Typ      => EW_Split (Left_Type));
 18603:       end if;
 18604:
 18605:       T :=
 18606:         New_Call
 18607:           (Ada_Node => Ada_Node,
 18608:            Domain   => Subdomain,
 18609:            Name     => Get_Array_Theory_1_Comp (Left_Type).Compare,
 18610:            Args     => Args,
 18611:            Typ      => EW_Int_Type);
 18612:       T := Binding_For_Temp (Domain => Domain, Tmp => Left_Expr, Context => T);
 18613:       T :=
 18614:         Binding_For_Temp (Domain => Domain, Tmp => Right_Expr, Context => T);
 18615:       T :=
 18616:         New_Comparison
 18617:           (Symbol => Transform_Compare_Op (Op, EW_Int_Type, Domain),
 18618:            Left   => T,
 18619:            Right  => New_Integer_Constant (Value => Uint_0),
 18620:            Domain => Domain);
 18621:       return T;
 18622:    end Transform_Array_Comparison;
 18623:
 18624:    ------------------------------
 18625:    -- Transform_Array_Equality --
 18626:    ------------------------------
 18627:
 18628:    function Transform_Array_Equality
 18629:      (Op        : N_Op_Compare;
 18630:       Left      : W_Expr_Id;
 18631:       Right     : W_Expr_Id;
 18632:       Left_Type : Type_Kind_Id;
 18633:       Domain    : EW_Domain;
 18634:       Ada_Node  : Node_Id) return W_Expr_Id
 18635:    is
 18636:       Dim        : constant Positive :=
 18637:         Positive (Number_Dimensions (Retysp (Left_Type)));
 18638:       Subdomain  : constant EW_Domain :=
 18639:         (if Domain = EW_Pred then EW_Term else Domain);
 18640:       Args       : W_Expr_Array (1 .. 4 * Dim + 2);
 18641:       T          : W_Expr_Id;
 18642:       Left_Expr  : W_Expr_Id;
 18643:       Right_Expr : W_Expr_Id;
 18644:       Arg_Ind    : Positive := 1;
 18645:    begin
 18646:
 18647:       --  Check that operands are initialized
 18648:
 18649:       Left_Expr :=
 18650:         Insert_Initialization_Check
 18651:           (Left_Opnd (Ada_Node),
 18652:            Left_Type,
 18653:            Left,
 18654:            Domain,
 18655:            Exclude_Components => For_Eq);
 18656:       Right_Expr :=
 18657:         Insert_Initialization_Check
 18658:           (Right_Opnd (Ada_Node),
 18659:            Etype (Right_Opnd (Ada_Node)),
 18660:            Right,
 18661:            Domain,
 18662:            Exclude_Components => For_Eq);
 18663:
 18664:       --  Potentially check invariants if subcomponents of the array type have
 18665:       --  a user-defined equality.
 18666:
 18667:       Left_Expr :=
 18668:         Insert_Invariant_Check_For_Eq
 18669:           (Left_Opnd (Ada_Node), Left_Type, Left_Expr, Domain);
 18670:       Right_Expr :=
 18671:         Insert_Invariant_Check_For_Eq
 18672:           (Right_Opnd (Ada_Node),
 18673:            Etype (Right_Opnd (Ada_Node)),
 18674:            Right_Expr,
 18675:            Domain);
 18676:
 18677:       Left_Expr := New_Temp_For_Expr (Left_Expr);
 18678:       Right_Expr := New_Temp_For_Expr (Right_Expr);
 18679:
 18680:       Add_Array_Arg (Subdomain, Args, Left_Expr, Arg_Ind);
 18681:       Add_Array_Arg (Subdomain, Args, Right_Expr, Arg_Ind);
 18682:
 18683:       --  Add conversions from wrapper types if needed. Initialization checks
 18684:       --  are inserted earlier.
 18685:
 18686:       if Is_Init_Wrapper_Type (Get_Type (Left_Expr)) then
 18687:          Args (1) :=
 18688:            New_Call
 18689:              (Ada_Node => Ada_Node,
 18690:               Domain   => Subdomain,
 18691:               Name     => Get_Array_Of_Wrapper_Name (Left_Type),
 18692:               Args     => (1 => Args (1)),
 18693:               Typ      => EW_Split (Left_Type));
 18694:       end if;
 18695:       if Is_Init_Wrapper_Type (Get_Type (Right_Expr)) then
 18696:          Args (2 + 2 * Dim) :=
 18697:            New_Call
 18698:              (Ada_Node => Ada_Node,
 18699:               Domain   => Subdomain,
 18700:               Name     => Get_Array_Of_Wrapper_Name (Left_Type),
 18701:               Args     => (1 => Args (2 + 2 * Dim)),
 18702:               Typ      => EW_Split (Left_Type));
 18703:       end if;
 18704:
 18705:       T :=
 18706:         New_Call
 18707:           (Ada_Node => Ada_Node,
 18708:            Domain   => Subdomain,
 18709:            Name     => Get_Array_Theory (Etype (Left_Opnd (Ada_Node))).Bool_Eq,
 18710:            Args     => Args,
 18711:            Typ      => EW_Bool_Type);
 18712:       T := Binding_For_Temp (Domain => Domain, Tmp => Left_Expr, Context => T);
 18713:       T :=
 18714:         Binding_For_Temp (Domain => Domain, Tmp => Right_Expr, Context => T);
 18715:       if Domain = EW_Pred then
 18716:          T :=
 18717:            New_Comparison
 18718:              (Symbol => Transform_Compare_Op (Op, EW_Bool_Type, Domain),
 18719:               Left   => T,
 18720:               Right  => New_Literal (Domain => Subdomain, Value => EW_True),
 18721:               Domain => Domain);
 18722:       elsif Op = N_Op_Ne then
 18723:          pragma
 18724:            Annotate (Xcov, Exempt_On, "A /= B is expanded into not (A = B)");
 18725:          T :=
 18726:            New_Call
 18727:              (Domain => Domain,
 18728:               Name   => M_Boolean.Notb,
 18729:               Args   => (1 => T),
 18730:               Typ    => EW_Bool_Type);
 18731:          pragma Annotate (Xcov, Exempt_Off);
 18732:       end if;
 18733:       return T;
 18734:    end Transform_Array_Equality;
 18735:
```

## src/why/gnat2why-expr.adb:19042-19146

```ada
 19042:    function Transform_Assignment_Statement
 19043:      (Stmt : N_Assignment_Statement_Id; Params : Transformation_Params)
 19044:       return W_Prog_Id
 19045:    is
 19046:       Lvalue : constant Node_Id := SPARK_Atree.Name (Stmt);
 19047:       Typ    : constant Entity_Id := Retysp (Etype (Lvalue));
 19048:       L_Type : constant W_Type_Id :=
 19049:         (if Expr_Has_Relaxed_Init (Lvalue, No_Eval => False)
 19050:          then EW_Init_Wrapper (Type_Of_Node (Typ))
 19051:          else Type_Of_Node (Typ));
 19052:       --  We go to the wrapper type if lvalue has relaxed initialization
 19053:       --  except for scalar types for which a copy is a read.
 19054:
 19055:       T : W_Prog_Id;
 19056:
 19057:       Do_Valid : constant Boolean := Is_Potentially_Invalid_Expr (Lvalue);
 19058:       --  Whether we need to assign the validity flag of Lvalue
 19059:
 19060:       --  Context and validity flag to handle potentially invalid values
 19061:
 19062:       Valid_Flag : W_Expr_Id :=
 19063:         (if Do_Valid then +New_Valid_Value_For_Type (Typ) else Why_Empty);
 19064:       Context    : Ref_Context;
 19065:
 19066:       --  For length checks and discriminant checks, look through conversions
 19067:       --  to get the object which is actually modified.
 19068:
 19069:       Exp_Ty     : constant Entity_Id := Expected_Type_Of_Prefix (Lvalue);
 19070:       Lgth_Check : constant Boolean :=
 19071:         (Is_Array_Type (Exp_Ty) and then not Is_Static_Array_Type (Exp_Ty));
 19072:       --  Length check needed for assignment into a non-static array type
 19073:
 19074:       Disc_Check : constant Boolean :=
 19075:         (if Is_Access_Type (Exp_Ty)
 19076:          then
 19077:            Has_Discriminants (Directly_Designated_Type (Exp_Ty))
 19078:            and then not Is_Constrained (Directly_Designated_Type (Exp_Ty))
 19079:          else Has_Discriminants (Exp_Ty) and then not Is_Constrained (Exp_Ty));
 19080:       --  Discriminant check needed for assignment into a non-constrained
 19081:       --  record type. Constrained record type are handled by the
 19082:       --  conversion.
 19083:
 19084:       --  Tag checks are only necessary if the LHS is classwide
 19085:
 19086:       Tag_Check : constant Boolean :=
 19087:         Is_Class_Wide_Type (Etype (Lvalue))
 19088:         and then not Is_Tag_Indeterminate (Expression (Stmt));
 19089:
 19090:       Tmp : W_Expr_Id;
 19091:
 19092:    begin
 19093:       --  Handle the potential propagation of invalid values
 19094:
 19095:       if Propagates_Validity_Flag (Stmt) then
 19096:          T :=
 19097:            +Transform_Potentially_Invalid_Expr
 19098:               (Expr          => Expression (Stmt),
 19099:                Expected_Type => L_Type,
 19100:                Domain        => EW_Prog,
 19101:                Params        => Params,
 19102:                Context       => Context,
 19103:                Valid_Flag    => Valid_Flag);
 19104:       else
 19105:          T := Transform_Prog (Expression (Stmt), L_Type, Params);
 19106:       end if;
 19107:
 19108:       Tmp :=
 19109:         New_Temp_For_Expr
 19110:           (+T,
 19111:            Lgth_Check or else Disc_Check or else Tag_Check or else Do_Valid);
 19112:       --  The Exp_Entity type is in fact the type that is expected in Why.
 19113:       --  The L_Type is a more precise type entity in Ada. We have to
 19114:       --  respect both constraints here, so we first convert to the Ada type
 19115:       --  (to get checks), and then convert to Why (without checks) to get the
 19116:       --  types right.
 19117:
 19118:       if Lgth_Check then
 19119:          declare
 19120:             Lval  : constant W_Term_Id :=
 19121:               New_Temp_For_Expr
 19122:                 (Transform_Expr
 19123:                    (Lvalue, EW_Prog, Params, No_Validity_Check => True));
 19124:             Dim   : constant Positive :=
 19125:               Positive (Number_Dimensions (Get_Ada_Node (+L_Type)));
 19126:             Check : constant W_Pred_Id :=
 19127:               New_Length_Equality
 19128:                 (Left_Arr => +Tmp, Right_Arr => Lval, Dim => Dim);
 19129:
 19130:          begin
 19131:             T :=
 19132:               Sequence
 19133:                 (New_Located_Assert (Stmt, Check, VC_Length_Check, EW_Assert),
 19134:                  +Tmp);
 19135:             T :=
 19136:               +Binding_For_Temp
 19137:                  (Ada_Node => Empty,
 19138:                   Domain   => EW_Prog,
 19139:                   Tmp      => +Lval,
 19140:                   Context  => +T);
 19141:          end;
 19142:
 19143:       elsif Disc_Check then
 19144:
 19145:          --  Discriminants should be preserved by assignment except if the
 19146:          --  object is not constrained.
```

## src/why/gnat2why-expr.adb:19238-19345

```ada
 19238:               +Binding_For_Temp
 19239:                  (Ada_Node => Empty,
 19240:                   Domain   => EW_Prog,
 19241:                   Tmp      => Lval,
 19242:                   Context  => +T);
 19243:          end;
 19244:       end if;
 19245:
 19246:       --  T might not have type Type_Of_Node (Lvalue) for several reasons:
 19247:       --    * Type_Of_Node (Lvalue) uses the Actual_Subtype
 19248:       --    * Type_Of_Node (Lvalue) may have relaxed init even though T is
 19249:       --      a scalar.
 19250:       --  In both cases, the conversion can be done without checks.
 19251:
 19252:       if Do_Valid then
 19253:
 19254:          --  For array types, it might be necessary to slide the validity
 19255:          --  tree.
 19256:
 19257:          if Has_Array_Type (Etype (Lvalue))
 19258:            and then Needs_Slide (Typ, Get_Ada_Node (+Type_Of_Node (Lvalue)))
 19259:          then
 19260:             Valid_Flag :=
 19261:               +New_Validity_Tree_Slide
 19262:                  (Tree   => +Valid_Flag,
 19263:                   Expr   => Tmp,
 19264:                   To     => Type_Of_Node (Lvalue),
 19265:                   Domain => EW_Prog,
 19266:                   Params => Params);
 19267:          end if;
 19268:       end if;
 19269:
 19270:       T :=
 19271:         +Binding_For_Temp
 19272:            (Empty,
 19273:             EW_Prog,
 19274:             Tmp,
 19275:             Insert_Simple_Conversion
 19276:               (Domain => EW_Pterm, Expr => +T, To => Type_Of_Node (Lvalue)));
 19277:
 19278:       declare
 19279:          Do_Move : Boolean;
 19280:       begin
 19281:          Insert_Move_Of_Deep_Parts
 19282:            (Rhs     => Expression (Stmt),
 19283:             Lhs_Typ => Typ,
 19284:             Expr    => T,
 19285:             Do_Move => Do_Move);
 19286:
 19287:          --  If a move may be needed, force the use of a temporary to hold
 19288:          --  the value of the expression including any moves. This is because
 19289:          --  New_Assignment does not expect the rhs expression to modify the
 19290:          --  target of the assignment.
 19291:
 19292:          declare
 19293:             Tmp : constant W_Expr_Id := New_Temp_For_Expr (+T, Do_Move);
 19294:          begin
 19295:             T :=
 19296:               Gnat2Why.Expr.New_Assignment
 19297:                 (Ada_Node => Stmt,
 19298:                  Lvalue   => Lvalue,
 19299:                  Expr     => +Tmp,
 19300:                  Do_Check =>
 19301:                    (if Has_Target_Names (Stmt)
 19302:                     then Only_Vars
 19303:                     else All_Checks));
 19304:
 19305:             --  Check that the assignment does not cause a resource leak. This
 19306:             --  is done after moves, so that we properly handle the case where
 19307:             --  the target of the assignment is moved by the expression of the
 19308:             --  assignment, e.g. an aggregate with the target as element. This
 19309:             --  also deals with the special case X:=X so that we avoid issuing
 19310:             --  a message here.
 19311:
 19312:             if Is_Deep (Typ) and then not Is_Anonymous_Access_Type (Typ) then
 19313:                T := +Sequence (Check_No_Memory_Leaks (Stmt, Lvalue), T);
 19314:             end if;
 19315:
 19316:             T := +Binding_For_Temp (Empty, EW_Prog, Tmp, +T);
 19317:          end;
 19318:       end;
 19319:
 19320:       --  Handle the propagation of the validity flag if any
 19321:
 19322:       if Do_Valid then
 19323:          declare
 19324:             Index_Map : Ada_Node_To_Why_Id.Map;
 19325:
 19326:          begin
 19327:             --  Collect indexes for Lvalue before the assignment. No need to
 19328:             --  generate checks.
 19329:
 19330:             Collect_Index_Expressions
 19331:               (Lvalue, EW_Pterm, Params, Context, Index_Map);
 19332:
 19333:             T :=
 19334:               Sequence
 19335:                 (T,
 19336:                  New_Validity_Tree_Assignment
 19337:                    (LHS       => Lvalue,
 19338:                     New_Tree  => +Valid_Flag,
 19339:                     Params    => Params,
 19340:                     Index_Map => Index_Map));
 19341:
 19342:             T := +Bindings_For_Ref_Context (+T, Context, EW_Prog);
 19343:          end;
 19344:       end if;
 19345:
```

## src/why/gnat2why-expr.adb:19903-20101

```ada
 19903:          when Attribute_First | Attribute_Last | Attribute_Length           =>
 19904:             declare
 19905:                Ty_Ent : constant Entity_Id := Retysp (Etype (Var));
 19906:             begin
 19907:
 19908:                case Ekind (Ty_Ent) is
 19909:                   when Array_Kind                =>
 19910:                      declare
 19911:                         Arr_Ty    : constant Entity_Id :=
 19912:                           (if Nkind (Var) in N_Identifier | N_Expanded_Name
 19913:                              and then Is_Type (Entity (Var))
 19914:                            then Entity (Var)
 19915:                            else Etype (Var));
 19916:                         Dim       : constant Positive :=
 19917:                           (if Present (Expressions (Expr))
 19918:                            then
 19919:                              Positive
 19920:                                (UI_To_Int
 19921:                                   (Intval (First (Expressions (Expr)))))
 19922:                            else 1);
 19923:                         B_Exp     : constant W_Type_Id :=
 19924:                           Base_Why_Type_No_Bool (Expected_Typ);
 19925:                         Index_Rng : constant Type_Kind_Id :=
 19926:                           Nth_Index_Type (Retysp (Arr_Ty), Dim);
 19927:                         B_Rng     : constant W_Type_Id :=
 19928:                           Base_Why_Type_No_Bool (Index_Rng);
 19929:                         Typ       : constant W_Type_Id :=
 19930:                           (if not Why_Type_Is_BitVector (B_Rng)
 19931:                              or else not Why_Type_Is_BitVector (B_Exp)
 19932:                            then EW_Int_Type
 19933:                            elsif BitVector_Type_Size (B_Rng)
 19934:                              <= BitVector_Type_Size (B_Exp)
 19935:                            then B_Exp
 19936:                            else B_Rng);
 19937:                         --  Typ is only used for the computation of 'Length.
 19938:                         --  Do computation on bitvectors only if the array
 19939:                         --  ranges over bitvectors, as otherwise the conversion
 19940:                         --  of 'First and 'Last to Typ may be incorrect. We
 19941:                         --  also use the widest of B_Rng and B_Exp for
 19942:                         --  bitvector computation. We cannot use B_Exp
 19943:                         --  systematically as it may be too short, producing
 19944:                         --  unexpected overflows.
 19945:
 19946:                         Modular_Range_Check : constant Boolean :=
 19947:                           Domain = EW_Prog
 19948:                           and then Attr_Id = Attribute_Length
 19949:                           and then Why_Type_Is_BitVector (Typ)
 19950:                           and then
 19951:                             UI_Expon (2, BitVector_Type_Size (Typ))
 19952:                             = Modulus (Index_Rng);
 19953:                         --  If attribute is length, computation on plain
 19954:                         --  bitvectors may already overflow. This can only
 19955:                         --  happen when 'First = 0 and 'Last is the maximum
 19956:                         --  bitvector value. Furthermore, since additionally
 19957:                         --  Last < Modulus (range), we can use modulus value
 19958:                         --  to remove the check entirely in cases where
 19959:                         --  bitvector maximum value exceeds modulus.
 19960:
 19961:                         pragma
 19962:                           Assert
 19963:                             (if Why_Type_Is_BitVector (Typ)
 19964:                              then
 19965:                                Modulus (Index_Rng)
 19966:                                <= UI_Expon (2, BitVector_Type_Size (Typ)));
 19967:
 19968:                         function Prepend_Modular_Range_Check
 19969:                           (Src   : W_Prog_Id;
 19970:                            First : W_Term_Id;
 19971:                            Last  : W_Term_Id) return W_Prog_Id
 19972:                         is (Sequence
 19973:                               (Left  =>
 19974:                                  New_Located_Assert
 19975:                                    (Ada_Node => Expr,
 19976:                                     Reason   => VC_Range_Check,
 19977:                                     Kind     => EW_Assert,
 19978:                                     Pred     =>
 19979:                                       New_Or_Pred
 19980:                                         (New_Comparison
 19981:                                            (Symbol => Why_Neq,
 19982:                                             Left   =>
 19983:                                               Insert_Simple_Conversion
 19984:                                                 (Expr => First, To => Typ),
 19985:                                             Right  =>
 19986:                                               New_Discrete_Constant
 19987:                                                 (Value => Uint_0, Typ => Typ)),
 19988:                                          New_Comparison
 19989:                                            (Symbol => Why_Neq,
 19990:                                             Left   =>
 19991:                                               Insert_Simple_Conversion
 19992:                                                 (Expr => Last, To => Typ),
 19993:                                             Right  =>
 19994:                                               New_Discrete_Constant
 19995:                                                 (Value =>
 19996:                                                    UI_Sub
 19997:                                                      (Modulus (Index_Rng),
 19998:                                                       Uint_1),
 19999:                                                  Typ   => Typ)))),
 20000:                                Right => Src))
 20001:                         with Pre => Modular_Range_Check;
 20002:                         --  Prepend additional check. While this looks like an
 20003:                         --  overflow, this should be a range check as this
 20004:                         --  comes from the length not being representable in
 20005:                         --  the modular type.
 20006:
 20007:                      begin
 20008:                         --  Array_Type'First/Last/Length
 20009:
 20010:                         if Nkind (Var) in N_Identifier | N_Expanded_Name
 20011:                           and then Is_Type (Entity (Var))
 20012:                         then
 20013:                            T :=
 20014:                              +Get_Array_Attr
 20015:                                 (Domain => Term_Domain (Domain),
 20016:                                  Ty     => Entity (Var),
 20017:                                  Attr   => Attr_Id,
 20018:                                  Dim    => Dim,
 20019:                                  Typ    => Typ);
 20020:                            if Modular_Range_Check then
 20021:                               T :=
 20022:                                 +Prepend_Modular_Range_Check
 20023:                                    (+T,
 20024:                                     +Get_Array_Attr
 20025:                                        (Domain => EW_Term,
 20026:                                         Ty     => Entity (Var),
 20027:                                         Attr   => Attribute_First,
 20028:                                         Dim    => Dim),
 20029:                                     +Get_Array_Attr
 20030:                                        (Domain => EW_Term,
 20031:                                         Ty     => Entity (Var),
 20032:                                         Attr   => Attribute_Last,
 20033:                                         Dim    => Dim));
 20034:                            end if;
 20035:
 20036:                         --  Object'First/Last/Length
 20037:
 20038:                         else
 20039:                            declare
 20040:                               Why_Expr  : constant W_Expr_Id :=
 20041:                                 Transform_Expr
 20042:                                   (Var,
 20043:                                    Domain,
 20044:                                    Params,
 20045:                                    No_Validity_Check => True);
 20046:                               Tmp       : constant W_Term_Id :=
 20047:                                 New_Temp_For_Expr (Why_Expr);
 20048:                               Simpl_Var : constant Boolean :=
 20049:                                 Nkind (Var) in N_Identifier | N_Expanded_Name;
 20050:                               Item      : Item_Type;
 20051:
 20052:                            begin
 20053:                               if Simpl_Var then
 20054:                                  Item :=
 20055:                                    Ada_Ent_To_Why.Element
 20056:                                      (Symbol_Table, Entity (Var));
 20057:                                  T :=
 20058:                                    +Get_Array_Attr
 20059:                                       (Item, Attr_Id, Dim, Typ => Typ);
 20060:                                  if Modular_Range_Check then
 20061:                                     T :=
 20062:                                       +Prepend_Modular_Range_Check
 20063:                                          (+T,
 20064:                                           +Get_Array_Attr
 20065:                                              (Item, Attribute_First, Dim),
 20066:                                           +Get_Array_Attr
 20067:                                              (Item, Attribute_Last, Dim));
 20068:                                  end if;
 20069:                               else
 20070:                                  T :=
 20071:                                    +Get_Array_Attr
 20072:                                       (Tmp, Attr_Id, Dim, Typ => Typ);
 20073:                                  if Modular_Range_Check then
 20074:                                     T :=
 20075:                                       +Prepend_Modular_Range_Check
 20076:                                          (+T,
 20077:                                           +Get_Array_Attr
 20078:                                              (Tmp, Attribute_First, Dim),
 20079:                                           +Get_Array_Attr
 20080:                                              (Tmp, Attribute_Last, Dim));
 20081:                                  end if;
 20082:                               end if;
 20083:
 20084:                               if not Simpl_Var or else Domain = EW_Prog then
 20085:                                  T :=
 20086:                                    Binding_For_Temp
 20087:                                      (Domain  => Domain,
 20088:                                       Tmp     => +Tmp,
 20089:                                       Context => T);
 20090:                               end if;
 20091:                            end;
 20092:                         end if;
 20093:                      end;
 20094:
 20095:                   when Discrete_Kind | Real_Kind =>
 20096:                      T :=
 20097:                        New_Attribute_Expr
 20098:                          (Etype (Var), Domain, Attr_Id, Params);
 20099:
 20100:                   when others                    =>
 20101:
```

## src/why/gnat2why-expr.adb:20256-20300

```ada
 20256:          when Attribute_Image | Attribute_Img                               =>
 20257:             declare
 20258:                Arg : constant Node_Id :=
 20259:                  (if Present (Expressions (Expr))
 20260:                   then First (Expressions (Expr))
 20261:                   else Var);
 20262:             begin
 20263:                T :=
 20264:                  New_Call
 20265:                    (Ada_Node => Expr,
 20266:                     Domain   => Domain,
 20267:                     Name     =>
 20268:                       +New_Attribute_Expr
 20269:                          (Etype (Var), Domain, Attribute_Image),
 20270:                     Args     =>
 20271:                       (1 =>
 20272:                          Transform_Expr
 20273:                            (Arg, Base_Why_Type (Var), Domain, Params)));
 20274:
 20275:                --  To_string takes as a second argument the maximum size of the
 20276:                --  image of the corresponding type.
 20277:
 20278:                T :=
 20279:                  New_Call
 20280:                    (Ada_Node => Expr,
 20281:                     Domain   => Domain,
 20282:                     Name     => To_String_Id,
 20283:                     Args     =>
 20284:                       (1 => T,
 20285:                        2 =>
 20286:                          New_Integer_Constant
 20287:                            (Value =>
 20288:                               Max_Size_Of_Img_Attr (Retysp (Etype (Var))))),
 20289:                     Typ      => EW_Abstract (Standard_String));
 20290:
 20291:                Warning_Msg_N
 20292:                  (Warn_Imprecise_Image,
 20293:                   Expr,
 20294:                   Create_N
 20295:                     (Warn_Imprecise_Image,
 20296:                      Names => [To_String (Aname, Sloc (Expr))]));
 20297:             end;
 20298:
 20299:          when Attribute_Size | Attribute_Value_Size | Attribute_Object_Size =>
 20300:
```

## src/why/gnat2why-expr.adb:21817-21972

```ada
 21817:       --  Special case for equality between Booleans in predicates
 21818:
 21819:       if Domain = EW_Pred
 21820:         and then Nkind (Expr) = N_Op_Eq
 21821:         and then Is_Standard_Boolean_Type (Left_Type)
 21822:       then
 21823:          declare
 21824:             Left_Expr  : constant W_Expr_Id :=
 21825:               Transform_Expr (Left, EW_Bool_Type, EW_Pred, Params);
 21826:             Right_Expr : constant W_Expr_Id :=
 21827:               Transform_Expr (Right, EW_Bool_Type, EW_Pred, Params);
 21828:          begin
 21829:             T :=
 21830:               New_Connection
 21831:                 (Domain => EW_Pred,
 21832:                  Left   => Left_Expr,
 21833:                  Right  => Right_Expr,
 21834:                  Op     => EW_Equivalent);
 21835:          end;
 21836:
 21837:       elsif Has_Array_Type (Left_Type) then
 21838:
 21839:          --  If Expr is of the form Id = Id'Old'Update (...) and equality is
 21840:          --  not redefined on the array type, we can translate it as
 21841:          --  (for all Idx in Id'Range =>
 21842:          --     Id (Idx) = (if Idx ... then ... else Id'Old (Idx)))
 21843:
 21844:          if not Is_Deep_Delta_Aggregate (Expr)
 21845:            and then Is_Equal_Of_Update (Expr)
 21846:          then
 21847:             T := Transform_Equal_Of_Update (Expr, Domain, Params);
 21848:
 21849:          --  Normal translation
 21850:
 21851:          else
 21852:             declare
 21853:                Left_Expr  : constant W_Expr_Id :=
 21854:                  Transform_Expr
 21855:                    (Left,
 21856:                     (if Domain = EW_Pred then EW_Term else Domain),
 21857:                     Params);
 21858:                Right_Expr : constant W_Expr_Id :=
 21859:                  Transform_Expr
 21860:                    (Right,
 21861:                     (if Domain = EW_Pred then EW_Term else Domain),
 21862:                     Params);
 21863:
 21864:             begin
 21865:                if Nkind (Expr) in N_Op_Eq | N_Op_Ne then
 21866:                   T :=
 21867:                     Transform_Array_Equality
 21868:                       (Op        => Nkind (Expr),
 21869:                        Left      => Left_Expr,
 21870:                        Right     => Right_Expr,
 21871:                        Left_Type => Left_Type,
 21872:                        Domain    => Domain,
 21873:                        Ada_Node  => Expr);
 21874:                else
 21875:                   T :=
 21876:                     Transform_Array_Comparison
 21877:                       (Op       => Nkind (Expr),
 21878:                        Left     => Left_Expr,
 21879:                        Right    => Right_Expr,
 21880:                        Domain   => Domain,
 21881:                        Ada_Node => Expr);
 21882:                end if;
 21883:             end;
 21884:          end if;
 21885:
 21886:       elsif Has_Access_Type (Left_Type) then
 21887:
 21888:          --  For access types, there might not be a type which can act as
 21889:          --  a base type of both operands (imagine one is a named access type
 21890:          --  with a predicate and the other an anonymous type with a null
 21891:          --  exclusion). Fortunately, the root of both types should really be
 21892:          --  the same Why type, so we don't really need such a base.
 21893:
 21894:          declare
 21895:             Op         : constant Node_Kind := Nkind (Expr);
 21896:             Right_Type : constant Entity_Id := Etype (Right);
 21897:             Subdomain  : constant EW_Domain :=
 21898:               (if Domain = EW_Pred then EW_Term else Domain);
 21899:
 21900:             Relaxed_Init : constant Boolean :=
 21901:               Expr_Has_Relaxed_Init (Left) or Expr_Has_Relaxed_Init (Right);
 21902:             --  An access comparison does not consider the designated value. It
 21903:             --  is OK to compare partially intialized values.
 21904:
 21905:             W_Left_Ty  : constant W_Type_Id :=
 21906:               EW_Abstract (Root_Retysp (Left_Type), Relaxed_Init);
 21907:             W_Right_Ty : constant W_Type_Id :=
 21908:               EW_Abstract (Root_Retysp (Right_Type), Relaxed_Init);
 21909:             Left_Expr  : constant W_Expr_Id :=
 21910:               Transform_Expr (Left, W_Left_Ty, Subdomain, Params);
 21911:             Right_Expr : constant W_Expr_Id :=
 21912:               Transform_Expr (Right, W_Right_Ty, Subdomain, Params);
 21913:          begin
 21914:             T :=
 21915:               New_Call
 21916:                 (Ada_Node => Expr,
 21917:                  Domain   => Subdomain,
 21918:                  Name     =>
 21919:                    E_Symb (Root_Retysp (Left_Type), WNE_Bool_Eq, Relaxed_Init),
 21920:                  Args     => (1 => Left_Expr, 2 => Right_Expr),
 21921:                  Typ      => EW_Bool_Type);
 21922:
 21923:             if Domain = EW_Pred then
 21924:                T :=
 21925:                  New_Comparison
 21926:                    (Symbol => Transform_Compare_Op (Op, EW_Bool_Type, Domain),
 21927:                     Left   => T,
 21928:                     Right  =>
 21929:                       New_Literal (Domain => Subdomain, Value => EW_True),
 21930:                     Domain => Domain);
 21931:
 21932:             elsif Op = N_Op_Ne then
 21933:                T :=
 21934:                  New_Call
 21935:                    (Domain => Domain,
 21936:                     Name   => M_Boolean.Notb,
 21937:                     Args   => (1 => T),
 21938:                     Typ    => EW_Bool_Type);
 21939:             end if;
 21940:          end;
 21941:
 21942:       elsif Is_Record_Type_In_Why (Left_Type) then
 21943:          T := Transform_Record_Equality (Expr, Left, Right, Domain, Params);
 21944:
 21945:       else
 21946:          pragma Assert (Has_Scalar_Type (Left_Type));
 21947:          declare
 21948:             Op         : constant Node_Kind := Nkind (Expr);
 21949:             Right_Type : constant Entity_Id := Etype (Right);
 21950:             Subdomain  : constant EW_Domain :=
 21951:               (if Domain = EW_Pred then EW_Term else Domain);
 21952:
 21953:             BT         : constant W_Type_Id :=
 21954:               Base_Why_Type (Left_Type, Right_Type);
 21955:             Left_Expr  : constant W_Expr_Id :=
 21956:               Transform_Expr (Left, BT, Subdomain, Params);
 21957:             Right_Expr : constant W_Expr_Id :=
 21958:               Transform_Expr (Right, BT, Subdomain, Params);
 21959:          begin
 21960:             T :=
 21961:               New_Comparison
 21962:                 (Symbol => Transform_Compare_Op (Op, BT, Domain),
 21963:                  Left   => Left_Expr,
 21964:                  Right  => Right_Expr,
 21965:                  Domain => Domain);
 21966:          end;
 21967:       end if;
 21968:
 21969:       return T;
 21970:    end Transform_Comparison;
 21971:
 21972:    -----------------------------
```

## src/why/gnat2why-expr.adb:21976-22351

```ada
 21976:    function Transform_Concatenation
 21977:      (Left               : W_Expr_Id;
 21978:       Right              : W_Expr_Id;
 21979:       Left_Type          : Type_Kind_Id;
 21980:       Right_Type         : Type_Kind_Id;
 21981:       Return_Type        : Type_Kind_Id;
 21982:       Is_Component_Left  : Boolean;
 21983:       Is_Component_Right : Boolean;
 21984:       Domain             : EW_Domain;
 21985:       Ada_Node           : Node_Id) return W_Expr_Id
 21986:    is
 21987:       Relaxed_Init        : constant Boolean :=
 21988:         Expr_Has_Relaxed_Init (Ada_Node, No_Eval => False);
 21989:       Left_Expr           : W_Expr_Id := Left;
 21990:       Right_Expr          : W_Expr_Id := Right;
 21991:       Args_Len            : constant Positive :=
 21992:         (if Is_Component_Left then 2 else 3)
 21993:         + (if Is_Component_Right then 1 else 3);
 21994:       Args                : W_Expr_Array (1 .. Args_Len);
 21995:       Arg_Ind             : Positive := 1;
 21996:       T                   : W_Expr_Id;
 21997:       First_Expr          : W_Expr_Id;
 21998:       Low_Type            : Entity_Id;
 21999:       Comp_Type           : constant W_Type_Id :=
 22000:         EW_Abstract
 22001:           (Component_Type (Return_Type),
 22002:            Relaxed_Init =>
 22003:              Relaxed_Init
 22004:              or else Has_Relaxed_Init (Component_Type (Return_Type)));
 22005:       Need_Reconstruction : Boolean := True;
 22006:       --  If we need to reconstruct the array after the concatenation
 22007:
 22008:       function Build_Last_Expr return W_Expr_Id;
 22009:       --  build the expression that yields the value of the 'Last attribute
 22010:       --  of the concatenation. It is simply
 22011:       --    first + length of left opnd + length of right_opnd - 1
 22012:       --  Last is always computed with integer (even when dealing with modular)
 22013:       --  in order to be coherent with length which is always an integer.
 22014:
 22015:       function Build_Last_No_Slide return W_Expr_Id;
 22016:       --  build the expression that yields the value of the 'Last attribute
 22017:       --  of the call to concat. It is simply
 22018:       --    last left opnd + length of right_opnd
 22019:
 22020:       ---------------------
 22021:       -- Build_Last_Expr --
 22022:       ---------------------
 22023:
 22024:       function Build_Last_Expr return W_Expr_Id is
 22025:          One_Term     : constant W_Expr_Id :=
 22026:            New_Discrete_Constant (Value => Uint_1, Typ => EW_Int_Type);
 22027:          Left_Length  : constant W_Expr_Id :=
 22028:            (if Is_Component_Left
 22029:             then One_Term
 22030:             else
 22031:               Build_Length_Expr
 22032:                 (Domain => Domain,
 22033:                  First  => +Get_Array_Attr (+Left_Expr, Attribute_First, 1),
 22034:                  Last   => +Get_Array_Attr (+Left_Expr, Attribute_Last, 1)));
 22035:          Right_Length : constant W_Expr_Id :=
 22036:            (if Is_Component_Right
 22037:             then One_Term
 22038:             else
 22039:               Build_Length_Expr
 22040:                 (Domain => Domain,
 22041:                  First  => +Get_Array_Attr (+Right_Expr, Attribute_First, 1),
 22042:                  Last   => +Get_Array_Attr (+Right_Expr, Attribute_Last, 1)));
 22043:       begin
 22044:          return
 22045:            +New_Discrete_Substract
 22046:               (Domain,
 22047:                New_Discrete_Add
 22048:                  (Domain,
 22049:                   First_Expr,
 22050:                   New_Discrete_Add (Domain, Left_Length, Right_Length),
 22051:                   EW_Int_Type),
 22052:                One_Term);
 22053:       end Build_Last_Expr;
 22054:
 22055:       -------------------------
 22056:       -- Build_Last_No_Slide --
 22057:       -------------------------
 22058:
 22059:       function Build_Last_No_Slide return W_Expr_Id is
 22060:          Typ          : constant W_Type_Id :=
 22061:            Nth_Index_Rep_Type_No_Bool (Return_Type, 1);
 22062:          One_Term     : constant W_Expr_Id :=
 22063:            New_Discrete_Constant (Value => Uint_1, Typ => Typ);
 22064:          Left_Last    : constant W_Expr_Id :=
 22065:            (if Is_Component_Left
 22066:             then First_Expr
 22067:             else
 22068:               New_Attribute_Expr
 22069:                 (Nth_Index_Type (Return_Type, 1),
 22070:                  Domain,
 22071:                  Attribute_Last,
 22072:                  Body_Params));
 22073:          Right_Length : constant W_Expr_Id :=
 22074:            (if Is_Component_Right
 22075:             then One_Term
 22076:             else
 22077:               Build_Length_Expr
 22078:                 (Domain => Domain,
 22079:                  First  => +Get_Array_Attr (+Right_Expr, Attribute_First, 1),
 22080:                  Last   => +Get_Array_Attr (+Right_Expr, Attribute_Last, 1)));
 22081:       begin
 22082:          return +New_Discrete_Add (Domain, Left_Last, Right_Length, Typ);
 22083:       end Build_Last_No_Slide;
 22084:
 22085:       --  Start of processing for Transform_Concatenation
 22086:
 22087:    begin
 22088:       --  Step 1: introduce temps for left and right
 22089:
 22090:       Left_Expr := New_Temp_For_Expr (Left_Expr);
 22091:       Right_Expr := New_Temp_For_Expr (Right_Expr);
 22092:
 22093:       --  Step 2: compute the lower bound of the concatenation
 22094:       --  See RM 4.5.3(6-7) for the rules. The test here is taken from
 22095:       --  Expand_Concatenate in exp_ch4.adb.
 22096:
 22097:       Low_Type := Ultimate_Ancestor (Return_Type);
 22098:
 22099:       if Is_Constrained (Low_Type) then
 22100:          First_Expr :=
 22101:            +Get_Array_Attr
 22102:               (Term_Domain (Domain), Low_Type, Attribute_First, 1);
 22103:
 22104:       elsif Is_Component_Left then
 22105:          First_Expr :=
 22106:            New_Attribute_Expr
 22107:              (Nth_Index_Type (Return_Type, 1),
 22108:               Domain,
 22109:               Attribute_First,
 22110:               Body_Params);
 22111:
 22112:       else
 22113:          First_Expr := +Get_Array_Attr (+Left_Expr, Attribute_First, 1);
 22114:       end if;
 22115:
 22116:       --  Step 3: build the actual concatenation expression.
 22117:       --  Step 3.1: if Left is empty then concatenate returns Right. If the
 22118:       --  length of Left is known statically, return Right.
 22119:
 22120:       if not Is_Component_Left
 22121:         and then Is_Static_Array_Type (Left_Type)
 22122:         and then Static_Array_Length (Left_Type, 1) = Uint_0
 22123:       then
 22124:          declare
 22125:             Right_First : constant W_Expr_Id :=
 22126:               (if Is_Component_Right
 22127:                then
 22128:                  New_Attribute_Expr
 22129:                    (Nth_Index_Type (Return_Type, 1),
 22130:                     Domain,
 22131:                     Attribute_First,
 22132:                     Body_Params)
 22133:                else +Get_Array_Attr (+Right_Expr, Attribute_First, 1));
 22134:          begin
 22135:             if Is_Component_Right then
 22136:                T :=
 22137:                  New_Singleton_Call
 22138:                    (Domain,
 22139:                     Insert_Simple_Conversion
 22140:                       (Domain => Domain, Expr => Right_Expr, To => Comp_Type),
 22141:                     Right_First,
 22142:                     Type_Of_Node (Ada_Node));
 22143:             else
 22144:                Need_Reconstruction := False;
 22145:                T := Right_Expr;
 22146:             end if;
 22147:          end;
 22148:
 22149:       --  Step 3.2: Left is not statically empty, do the actual concatenation
 22150:
 22151:       else
 22152:          --  We prepare the arguments to the concat call. If one of the sides
 22153:          --  is a component, need to possibly convert it to the right type
 22154:          --  (think of integer literals, need to convert to Standard__Integer).
 22155:
 22156:          if Is_Component_Left then
 22157:             Args (1) :=
 22158:               Insert_Simple_Conversion
 22159:                 (Ada_Node => Ada_Node,
 22160:                  Domain   => Domain,
 22161:                  Expr     => Left_Expr,
 22162:                  To       => Comp_Type);
 22163:             Args (2) := First_Expr;
 22164:             Arg_Ind := 3;
 22165:          else
 22166:             Add_Array_Arg (Domain, Args, Left_Expr, Arg_Ind);
 22167:
 22168:             --  If we are expecting a partially initialized type, convert Left
 22169:
 22170:             if Relaxed_Init and then not Is_Init_Wrapper_Type (Get_Type (Left))
 22171:             then
 22172:                Args (1) :=
 22173:                  New_Call
 22174:                    (Ada_Node => Ada_Node,
 22175:                     Domain   => Domain,
 22176:                     Name     => Get_Array_To_Wrapper_Name (Left_Type),
 22177:                     Args     => (1 => Args (1)),
 22178:                     Typ      => EW_Split (Left_Type, Relaxed_Init => True));
 22179:             end if;
 22180:          end if;
 22181:
 22182:          if Is_Component_Right then
 22183:             Args (Arg_Ind) :=
 22184:               Insert_Simple_Conversion
 22185:                 (Domain => Domain, Expr => Right_Expr, To => Comp_Type);
 22186:
 22187:             Arg_Ind := Arg_Ind + 1;
 22188:          else
 22189:             Add_Array_Arg (Domain, Args, Right_Expr, Arg_Ind);
 22190:
 22191:             --  If we are expecting a partially initialized type, convert Right
 22192:
 22193:             if Relaxed_Init
 22194:               and then not Is_Init_Wrapper_Type (Get_Type (Right))
 22195:             then
 22196:                Args (Arg_Ind - 3) :=
 22197:                  New_Call
 22198:                    (Ada_Node => Ada_Node,
 22199:                     Domain   => Domain,
 22200:                     Name     => Get_Array_To_Wrapper_Name (Right_Type),
 22201:                     Args     => (1 => Args (Arg_Ind - 3)),
 22202:                     Typ      => EW_Split (Left_Type, Relaxed_Init => True));
 22203:             end if;
 22204:          end if;
 22205:
 22206:          --  We build the call to concat
 22207:
 22208:          T :=
 22209:            New_Concat_Call
 22210:              (Domain,
 22211:               Args & Build_Last_No_Slide,
 22212:               Type_Of_Node (Ada_Node),
 22213:               Is_Component_Left  => Is_Component_Left,
 22214:               Is_Component_Right => Is_Component_Right);
 22215:
 22216:          --  Depending on the lower bound of the concat, the object may not be
 22217:          --  slided correctly, because the concat operator in Why assumes that
 22218:          --  the new low bound is the one of the left opnd. Correct that.
 22219:
 22220:          if not Is_Component_Left and then Is_Constrained (Low_Type) then
 22221:             T :=
 22222:               New_Call
 22223:                 (Domain => Domain,
 22224:                  Name   => Get_Array_Theory (Return_Type, Relaxed_Init).Slide,
 22225:                  Args   =>
 22226:                    (1 => T,
 22227:                     2 => +Get_Array_Attr (+Left_Expr, Attribute_First, 1),
 22228:                     3 => First_Expr),
 22229:                  Typ    => Type_Of_Node (Ada_Node));
 22230:          end if;
 22231:       end if;
 22232:
 22233:       --  Step 4: the expression T is of the Why array type. We need to convert
 22234:       --  it to the type of the concatenation expression. This type is always
 22235:       --  unconstrained. Therefore, we need to convert to the unconstrained
 22236:       --  representation. This situation also requires a range check.
 22237:
 22238:       pragma Assert (not Is_Constrained (Return_Type));
 22239:
 22240:       if Need_Reconstruction then
 22241:          declare
 22242:             Target    : constant Entity_Id := Nth_Index_Type (Return_Type, 1);
 22243:             Last_Expr : W_Expr_Id := Build_Last_Expr;
 22244:          begin
 22245:             Last_Expr :=
 22246:               Insert_Simple_Conversion
 22247:                 (Domain => EW_Prog,
 22248:                  Expr   =>
 22249:                    (if Domain = EW_Prog
 22250:                     then
 22251:                       +Do_Range_Check
 22252:                          (Ada_Node   => Ada_Node,
 22253:                           Ty         => Target,
 22254:                           W_Expr     => Last_Expr,
 22255:                           Check_Kind => RCK_Range)
 22256:                     else Last_Expr),
 22257:                  To     => Get_Type (First_Expr));
 22258:
 22259:             T :=
 22260:               Array_Convert_From_Base
 22261:                 (Domain => Domain,
 22262:                  Ty     => Return_Type,
 22263:                  Ar     => T,
 22264:                  First  => First_Expr,
 22265:                  Last   => Last_Expr);
 22266:          end;
 22267:       end if;
 22268:
 22269:       --  Step 5: if the Left operand is not static, it may still be a null
 22270:       --  array. Generate a conditional for this case.
 22271:
 22272:       if not Is_Component_Left and then not Is_Static_Array_Type (Left_Type)
 22273:       then
 22274:          declare
 22275:             Right_First : constant W_Expr_Id :=
 22276:               (if Is_Component_Right
 22277:                then
 22278:                  New_Attribute_Expr
 22279:                    (Nth_Index_Type (Return_Type, 1),
 22280:                     Domain,
 22281:                     Attribute_First,
 22282:                     Body_Params)
 22283:                else +Get_Array_Attr (+Right_Expr, Attribute_First, 1));
 22284:             Right_Last  : constant W_Expr_Id :=
 22285:               (if Is_Component_Right
 22286:                then Right_First
 22287:                else +Get_Array_Attr (+Right_Expr, Attribute_Last, 1));
 22288:             Right_Op    : W_Expr_Id :=
 22289:               (if Is_Component_Right
 22290:                then
 22291:                  New_Singleton_Call
 22292:                    (Domain,
 22293:                     Insert_Simple_Conversion
 22294:                       (Domain => Domain, Expr => Right_Expr, To => Comp_Type),
 22295:                     Right_First,
 22296:                     Type_Of_Node (Ada_Node))
 22297:                elsif Is_Static_Array_Type (Right_Type)
 22298:                then Right_Expr
 22299:                else
 22300:                  Array_Convert_To_Base (Domain => Domain, Ar => Right_Expr));
 22301:             Condition   : constant W_Expr_Id :=
 22302:               New_Call
 22303:                 (Domain => EW_Pred,
 22304:                  Typ    => EW_Bool_Type,
 22305:                  Name   => Why_Eq,
 22306:                  Args   =>
 22307:                    (1 => +Get_Array_Attr (+Left_Expr, Attribute_Length, 1),
 22308:                     2 => New_Integer_Constant (Value => Uint_0)));
 22309:
 22310:          begin
 22311:             --  If we are expecting a partially initialized type, convert Right
 22312:
 22313:             if Relaxed_Init
 22314:               and then not Is_Init_Wrapper_Type (Get_Type (Right_Op))
 22315:             then
 22316:                Right_Op :=
 22317:                  New_Call
 22318:                    (Ada_Node => Ada_Node,
 22319:                     Domain   => Domain,
 22320:                     Name     => Get_Array_To_Wrapper_Name (Right_Type),
 22321:                     Args     => (1 => Right_Op),
 22322:                     Typ      => EW_Split (Right_Type, Relaxed_Init => True));
 22323:             end if;
 22324:
 22325:             if not Is_Static_Array_Type (Return_Type) then
 22326:                Right_Op :=
 22327:                  Array_Convert_From_Base
 22328:                    (Domain => Domain,
 22329:                     Ty     => Return_Type,
 22330:                     Ar     => Right_Op,
 22331:                     First  => Right_First,
 22332:                     Last   => Right_Last);
 22333:             end if;
 22334:
 22335:             T :=
 22336:               New_Conditional
 22337:                 (Domain    => Domain,
 22338:                  Condition => Condition,
 22339:                  Then_Part => Right_Op,
 22340:                  Else_Part => T,
 22341:                  Typ       => Get_Type (T));
 22342:          end;
 22343:       end if;
 22344:
 22345:       --  Step 6: bind the introduced names if any, and return
 22346:
 22347:       T := Binding_For_Temp (Domain => Domain, Tmp => Left_Expr, Context => T);
 22348:       T :=
 22349:         Binding_For_Temp (Domain => Domain, Tmp => Right_Expr, Context => T);
 22350:       return T;
 22351:    end Transform_Concatenation;
```

## src/why/gnat2why-expr.adb:22591-22638

```ada
 22591:          when N_Object_Declaration                            =>
 22592:             declare
 22593:                Obj      : constant Entity_Id := Defining_Identifier (Decl);
 22594:                Obj_Type : constant Entity_Id := Etype (Obj);
 22595:
 22596:                Lvalue : constant Entity_Id :=
 22597:                  (if Is_Full_View (Obj) then Partial_View (Obj) else Obj);
 22598:             begin
 22599:                --  Non-scalar object declaration should not appear before the
 22600:                --  loop invariant in a loop.
 22601:
 22602:                pragma
 22603:                  Assert
 22604:                    (not Is_In_Loop_Initial_Statements
 22605:                     or else
 22606:                       (Is_Scalar_Type (Obj_Type) and then Is_Loop_Entity (Obj))
 22607:                     or else Is_Actions_Entity (Obj));
 22608:
 22609:                R := Assignment_Of_Obj_Decl (Decl);
 22610:
 22611:                --  Assume dynamic invariant of the object
 22612:
 22613:                if not Is_Partial_View (Obj) then
 22614:                   declare
 22615:                      Obj_Expr    : constant W_Term_Id :=
 22616:                        +Transform_Identifier
 22617:                           (Expr   => Lvalue,
 22618:                            Ent    => Lvalue,
 22619:                            Domain => EW_Term,
 22620:                            Params => Params);
 22621:                      Initialized : constant Boolean :=
 22622:                        Present (Expression (Decl))
 22623:                        or else Ekind (Obj) = E_Constant
 22624:                        or else Is_Imported (Obj);
 22625:                   begin
 22626:                      Append
 22627:                        (R,
 22628:                         Assume_Dynamic_Invariant
 22629:                           (Expr        => Obj_Expr,
 22630:                            Ty          => Etype (Lvalue),
 22631:                            Valid       =>
 22632:                              Get_Valid_Id_From_Object
 22633:                                (Obj, Ref_Allowed => True),
 22634:                            Initialized => Initialized,
 22635:                            Only_Var    => False));
 22636:
 22637:                      --  For mutable overlays, assume the dynamic invariant
 22638:                      --  of the overlay for all values of the root object.
```

## src/why/gnat2why-expr.adb:23187-23215

```ada
 23187:                begin
 23188:                   R := +Sequence (New_Ignore (Prog => +Why_Expr), R);
 23189:                end;
 23190:             end if;
 23191:          end;
 23192:       end if;
 23193:
 23194:       return +Insert_Cnt_Loc_Label (Decl, +R);
 23195:    end Transform_Declaration;
 23196:
 23197:    ----------------------------
 23198:    -- Transform_Declarations --
 23199:    ----------------------------
 23200:
 23201:    function Transform_Declarations
 23202:      (L : List_Id; Params : Transformation_Params) return W_Prog_Id
 23203:    is
 23204:       Cur_Decl : Node_Id := First (L);
 23205:       Result   : W_Statement_Sequence_Id := Void_Sequence;
 23206:
 23207:    begin
 23208:       while Present (Cur_Decl) loop
 23209:          Append (Result, Transform_Declaration (Cur_Decl, Params));
 23210:          Next (Cur_Decl);
 23211:       end loop;
 23212:       return +Result;
 23213:    end Transform_Declarations;
 23214:
 23215:    ----------------------------------
```

## src/why/gnat2why-expr.adb:23600-23647

```ada
 23600:    -- Transform_Expr --
 23601:    --------------------
 23602:
 23603:    function Transform_Expr
 23604:      (Expr              : N_Subexpr_Id;
 23605:       Expected_Type     : W_Type_Id;
 23606:       Domain            : EW_Domain;
 23607:       Params            : Transformation_Params;
 23608:       No_Init_Check     : Boolean := False;
 23609:       No_Validity_Check : Boolean := False) return W_Expr_Id
 23610:    is
 23611:       Expr_Type    : constant Entity_Id := Retysp (Etype (Expr));
 23612:       T            : W_Expr_Id;
 23613:       Pretty_Label : Symbol := No_Symbol;
 23614:       Local_Params : Transformation_Params := Params;
 23615:
 23616:    begin
 23617:       --  We check whether we need to generate a pretty printing label. If we
 23618:       --  do, we set the corresponding flag to "GM_None" so that the label is
 23619:       --  not printed for subterms.
 23620:       --  Our intention is to skip printing pretty-printing labels when not
 23621:       --  needed (predicate is just a single item, without conjunction,
 23622:       --  quantification, etc). So we skip the printing at the top level of the
 23623:       --  term, and set label generation for subterms, unless we are already at
 23624:       --  a terminal node.
 23625:
 23626:       if Domain = EW_Pred then
 23627:          case Local_Params.Gen_Marker is
 23628:             when GM_Label    =>
 23629:                if Is_Terminal_Node (Expr) then
 23630:                   Pretty_Label := New_Sub_VC_Marker (Expr);
 23631:                   Local_Params.Gen_Marker := GM_None;
 23632:                end if;
 23633:
 23634:             when GM_Toplevel =>
 23635:                if Is_Terminal_Node (Expr) then
 23636:                   Local_Params.Gen_Marker := GM_None;
 23637:                else
 23638:                   Local_Params.Gen_Marker := GM_Label;
 23639:                end if;
 23640:
 23641:             when GM_None     =>
 23642:                null;
 23643:          end case;
 23644:       end if;
 23645:
 23646:       --  Special case for Standard.True and Standard.False as predicates
 23647:
```

## src/why/gnat2why-expr.adb:23688-23712

```ada
 23688:                and then
 23689:                  Is_Hardcoded_Comparison (Get_Called_Entity_For_Proof (Expr)))
 23690:         and then
 23691:           not (Nkind (Expr) = N_Function_Call
 23692:                and then Ekind (Get_Called_Entity_For_Proof (Expr)) = E_Function
 23693:                and then
 23694:                  Has_Logical_Eq_Annotation
 23695:                    (Get_Called_Entity_For_Proof (Expr)))
 23696:       then
 23697:          T :=
 23698:            +Pred_Of_Boolean_Term
 23699:               (Transform_Term (Expr, EW_Bool_Type, Local_Params));
 23700:
 23701:       --  Optimization: if we have a discrete value that is statically known,
 23702:       --  use the static value.
 23703:
 23704:       elsif Domain /= EW_Pred
 23705:         and then Is_Discrete_Type (Expr_Type)
 23706:         and then Compile_Time_Known_Value (Expr)
 23707:       then
 23708:          T :=
 23709:            New_Discrete_Constant
 23710:              (Value => Expr_Value (Expr), Typ => Base_Why_Type (Expr_Type));
 23711:
 23712:       --  Intrinsic operators should be translated as function calls in SPARK
```

## src/why/gnat2why-expr.adb:24012-24205

```ada
 24012:             when N_Op_Minus                             =>
 24013:                --  unary minus
 24014:                declare
 24015:                   Right : constant N_Subexpr_Id := Right_Opnd (Expr);
 24016:                   Typ   : constant W_Type_Id := Base_Why_Type (Right);
 24017:
 24018:                   Minus_Ident : constant W_Identifier_Id :=
 24019:                     (if Typ = EW_Int_Type
 24020:                      then Int_Unary_Minus
 24021:                      elsif Why_Type_Is_BitVector (Typ)
 24022:                      then MF_BVs (Typ).Neg
 24023:                      elsif Why_Type_Is_Fixed (Typ)
 24024:                      then Fixed_Unary_Minus
 24025:                      else MF_Floats (Typ).Unary_Minus);
 24026:
 24027:                   Right_Rep : constant W_Expr_Id :=
 24028:                     Transform_Expr (Right, Typ, Domain, Local_Params);
 24029:
 24030:                   Check_No_Wrap_Around : constant Boolean :=
 24031:                     Domain = EW_Prog
 24032:                     and then Has_No_Wrap_Around_Annotation (Expr_Type);
 24033:
 24034:                begin
 24035:                   if Has_Modular_Integer_Type (Expr_Type)
 24036:                     and then Non_Binary_Modulus (Expr_Type)
 24037:                     and then
 24038:                       not Has_No_Bitwise_Operations_Annotation (Expr_Type)
 24039:                   then
 24040:                      T :=
 24041:                        Transform_Non_Binary_Modular_Operation
 24042:                          (Ada_Node   => Expr,
 24043:                           Ada_Type   => Expr_Type,
 24044:                           Domain     => Domain,
 24045:                           Op         => N_Op_Minus,
 24046:                           Right_Opnd => Right_Rep,
 24047:                           Rep_Type   => Typ,
 24048:                           Modulus    => Modulus (Expr_Type));
 24049:                   else
 24050:                      T :=
 24051:                        New_Call
 24052:                          (Domain   => Domain,
 24053:                           Ada_Node => Expr,
 24054:                           Name     => Minus_Ident,
 24055:                           Args     => (1 => Right_Rep),
 24056:                           Typ      => Typ);
 24057:
 24058:                      if not Check_No_Wrap_Around then
 24059:                         T := Apply_Modulus (N_Op_Minus, Expr_Type, T, Domain);
 24060:                      end if;
 24061:                   end if;
 24062:
 24063:                   --  If the type is subject to No_Wrap_Around annotation and
 24064:                   --  we need to insert a check, there are two cases:
 24065:                   --
 24066:                   --  . The type is also subject to No_Bitwise_Operations
 24067:                   --    annotation, hence its base type in Why is "int" and we
 24068:                   --    can check the absence of wrap around on the result of
 24069:                   --    the operation, provided we did not apply modulo on the
 24070:                   --    result.
 24071:                   --
 24072:                   --  . Otherwise, we need to check the absence of wrap around
 24073:                   --    before evaluating the operation in bitvectors.
 24074:
 24075:                   if Check_No_Wrap_Around then
 24076:                      if Has_No_Bitwise_Operations_Annotation (Expr_Type) then
 24077:                         T :=
 24078:                           +Do_Range_Check
 24079:                              (Ada_Node   => Expr,
 24080:                               Ty         => Expr_Type,
 24081:                               W_Expr     => T,
 24082:                               Check_Kind => RCK_Overflow);
 24083:                      else
 24084:                         declare
 24085:                            Check : constant W_Prog_Id :=
 24086:                              Check_No_Wrap_Around_Modular_Operation
 24087:                                (Ada_Node   => Expr,
 24088:                                 Ada_Type   => Expr_Type,
 24089:                                 Op         => N_Op_Minus,
 24090:                                 Right_Opnd => Right_Rep,
 24091:                                 Rep_Type   => Typ,
 24092:                                 Modulus    => Modulus (Expr_Type));
 24093:                         begin
 24094:                            Prepend (Check, T);
 24095:                         end;
 24096:                      end if;
 24097:                   end if;
 24098:                end;
 24099:
 24100:             when N_Op_Plus                              =>
 24101:                --  unary plus
 24102:                declare
 24103:                   Right : constant N_Subexpr_Id := Right_Opnd (Expr);
 24104:                begin
 24105:                   T :=
 24106:                     Transform_Expr
 24107:                       (Right, Base_Why_Type (Right), Domain, Local_Params);
 24108:                end;
 24109:
 24110:             when N_Op_Abs                               =>
 24111:                declare
 24112:                   Right : constant N_Subexpr_Id := Right_Opnd (Expr);
 24113:                   Typ   : constant W_Type_Id := Base_Why_Type (Right);
 24114:
 24115:                   Right_Rep : constant W_Expr_Id :=
 24116:                     Transform_Expr (Right, Typ, Domain, Local_Params);
 24117:                begin
 24118:                   T :=
 24119:                     New_Call
 24120:                       (Ada_Node => Expr,
 24121:                        Domain   => Domain,
 24122:                        Name     => New_Abs (Typ),
 24123:                        Args     => (1 => Right_Rep),
 24124:                        Typ      => Typ);
 24125:                end;
 24126:
 24127:             when N_Op_Add | N_Op_Subtract               =>
 24128:                declare
 24129:                   Left       : constant N_Subexpr_Id := Left_Opnd (Expr);
 24130:                   Right      : constant N_Subexpr_Id := Right_Opnd (Expr);
 24131:                   Base       : constant W_Type_Id :=
 24132:                     Base_Why_Type (Left, Right);
 24133:                   Left_Expr  : constant W_Expr_Id :=
 24134:                     Transform_Expr (Left, Base, Domain, Local_Params);
 24135:                   Right_Expr : constant W_Expr_Id :=
 24136:                     Transform_Expr (Right, Base, Domain, Local_Params);
 24137:                begin
 24138:                   T :=
 24139:                     New_Binary_Op_Expr
 24140:                       (Op          => Nkind (Expr),
 24141:                        Left        => Left_Expr,
 24142:                        Right       => Right_Expr,
 24143:                        Left_Type   => Etype (Left),
 24144:                        Right_Type  => Etype (Right),
 24145:                        Return_Type => Expr_Type,
 24146:                        Domain      => Domain,
 24147:                        Ada_Node    => Expr);
 24148:                end;
 24149:
 24150:             when N_Op_Multiply | N_Op_Divide            =>
 24151:                declare
 24152:                   Left           : constant N_Subexpr_Id := Left_Opnd (Expr);
 24153:                   Right          : constant N_Subexpr_Id := Right_Opnd (Expr);
 24154:                   L_Type, R_Type : W_Type_Id;
 24155:                   L_Why, R_Why   : W_Expr_Id;
 24156:                begin
 24157:                   if Has_Fixed_Point_Type (Etype (Left))
 24158:                     and then Has_Fixed_Point_Type (Etype (Right))
 24159:                   then
 24160:                      --  Multiplication/division between fixed-point types
 24161:                      --  requires the creation of a specific module.
 24162:
 24163:                      Create_Fixed_Point_Mult_Div_Theory_If_Needed
 24164:                        (Typ_Left   => Etype (Left),
 24165:                         Typ_Right  => Etype (Right),
 24166:                         Typ_Result => Expr_Type,
 24167:                         Expr       => Expr);
 24168:
 24169:                      L_Type := Base_Why_Type (Etype (Left));
 24170:                      R_Type := Base_Why_Type (Etype (Right));
 24171:
 24172:                   elsif Has_Fixed_Point_Type (Etype (Left)) then
 24173:                      L_Type := Base_Why_Type (Etype (Left));
 24174:                      R_Type := EW_Int_Type;
 24175:
 24176:                   elsif Nkind (Expr) = N_Op_Multiply
 24177:                     and then Has_Fixed_Point_Type (Etype (Right))
 24178:                   then
 24179:                      L_Type := EW_Int_Type;
 24180:                      R_Type := Base_Why_Type (Etype (Right));
 24181:
 24182:                   else
 24183:                      L_Type := Base_Why_Type (Left, Right);
 24184:                      R_Type := Base_Why_Type (Left, Right);
 24185:                   end if;
 24186:
 24187:                   L_Why := Transform_Expr (Left, L_Type, Domain, Local_Params);
 24188:                   R_Why :=
 24189:                     Transform_Expr (Right, R_Type, Domain, Local_Params);
 24190:
 24191:                   T :=
 24192:                     New_Binary_Op_Expr
 24193:                       (Op          => Nkind (Expr),
 24194:                        Left        => L_Why,
 24195:                        Right       => R_Why,
 24196:                        Left_Type   => Etype (Left),
 24197:                        Right_Type  => Etype (Right),
 24198:                        Return_Type => Expr_Type,
 24199:                        Domain      => Domain,
 24200:                        Ada_Node    => Expr);
 24201:                end;
 24202:
 24203:             when N_Op_Rem | N_Op_Mod                    =>
 24204:                declare
 24205:                   Left  : constant N_Subexpr_Id := Left_Opnd (Expr);
```

## src/why/gnat2why-expr.adb:24547-24570

```ada
 24547:                else
 24548:                   declare
 24549:                      Right : constant W_Expr_Id :=
 24550:                        Transform_Expr
 24551:                          (Right_Opnd (Expr),
 24552:                           EW_Bool_Type,
 24553:                           Domain,
 24554:                           Local_Params);
 24555:                   begin
 24556:                      if Domain = EW_Term then
 24557:                         T :=
 24558:                           New_Call
 24559:                             (Ada_Node => Expr,
 24560:                              Domain   => Domain,
 24561:                              Name     => M_Boolean.Notb,
 24562:                              Args     => (1 => Right),
 24563:                              Typ      => EW_Bool_Type);
 24564:                      else
 24565:                         T := New_Not (Right => Right, Domain => Domain);
 24566:                      end if;
 24567:                   end;
 24568:                end if;
 24569:
 24570:             when N_Op_And | N_Op_Or | N_Op_Xor          =>
```

## src/why/gnat2why-expr.adb:24630-24731

```ada
 24630:                end if;
 24631:
 24632:             when N_Short_Circuit                        =>
 24633:                Short_Circuit : declare
 24634:
 24635:                   function New_Short_Circuit_Expr
 24636:                     (Left, Right : W_Expr_Id; Domain : EW_Domain)
 24637:                      return W_Expr_Id;
 24638:                   --  Dispatch over functions to create a short-circuit Why
 24639:                   --  expr
 24640:
 24641:                   ----------------------------
 24642:                   -- New_Short_Circuit_Expr --
 24643:                   ----------------------------
 24644:
 24645:                   function New_Short_Circuit_Expr
 24646:                     (Left, Right : W_Expr_Id; Domain : EW_Domain)
 24647:                      return W_Expr_Id is
 24648:                   begin
 24649:                      if Nkind (Expr) = N_And_Then then
 24650:                         return New_And_Then_Expr (Left, Right, Domain);
 24651:                      else
 24652:                         return New_Or_Else_Expr (Left, Right, Domain);
 24653:                      end if;
 24654:                   end New_Short_Circuit_Expr;
 24655:
 24656:                   Left_N : constant Node_Id := Left_Opnd (Expr);
 24657:                   Left   : constant W_Expr_Id :=
 24658:                     Transform_Expr
 24659:                       (Left_N, EW_Bool_Type, Domain, Local_Params);
 24660:                   Right  : W_Expr_Id;
 24661:
 24662:                   Warn_On_Right : constant Boolean :=
 24663:                     Local_Params.Warn_On_Dead
 24664:                     and then
 24665:                       (if Nkind (Expr) = N_And_Then
 24666:                        then
 24667:                          not Exp_Util.Is_Statically_Disabled
 24668:                                (Left_N, False, Include_Valid => True)
 24669:                        else
 24670:                          not Exp_Util.Is_Statically_Disabled
 24671:                                (Left_N, True, Include_Valid => True));
 24672:                   Right_Params  : constant Transformation_Params :=
 24673:                     (Local_Params with delta Warn_On_Dead => Warn_On_Right);
 24674:                   --  Do not emit dead branch warnings in Right if Left is
 24675:                   --  statically disabled.
 24676:
 24677:                   --  Start of processing for Short_Circuit
 24678:
 24679:                begin
 24680:                   Ada_Ent_To_Why.Push_Scope (Symbol_Table);
 24681:
 24682:                   if Present (Actions (Expr)) then
 24683:                      Transform_Actions_Preparation (Actions (Expr));
 24684:                   end if;
 24685:
 24686:                   Right :=
 24687:                     Transform_Expr
 24688:                       (Right_Opnd (Expr), EW_Bool_Type, Domain, Right_Params);
 24689:
 24690:                   --  Possibly warn on an unreachable right branch
 24691:
 24692:                   if Domain = EW_Prog then
 24693:                      Right :=
 24694:                        +Warn_On_Dead_Branch
 24695:                           (Right_Opnd (Expr),
 24696:                            +Right,
 24697:                            Local_Params.Phase,
 24698:                            Warn_On_Right);
 24699:                   end if;
 24700:
 24701:                   if Present (Actions (Expr)) then
 24702:                      Right :=
 24703:                        Transform_Actions
 24704:                          (Actions (Expr), Right, Domain, Local_Params);
 24705:                   end if;
 24706:
 24707:                   T :=
 24708:                     New_Short_Circuit_Expr
 24709:                       (Left => Left, Right => Right, Domain => Domain);
 24710:
 24711:                   Ada_Ent_To_Why.Pop_Scope (Symbol_Table);
 24712:                end Short_Circuit;
 24713:
 24714:             when N_Op_Concat                            =>
 24715:                T :=
 24716:                  Transform_Concatenation
 24717:                    (Left               =>
 24718:                       Transform_Expr (Left_Opnd (Expr), Domain, Params),
 24719:                     Right              =>
 24720:                       Transform_Expr (Right_Opnd (Expr), Domain, Params),
 24721:                     Left_Type          => Etype (Left_Opnd (Expr)),
 24722:                     Right_Type         => Etype (Right_Opnd (Expr)),
 24723:                     Return_Type        => Etype (Expr),
 24724:                     Is_Component_Left  => Is_Component_Left_Opnd (Expr),
 24725:                     Is_Component_Right => Is_Component_Right_Opnd (Expr),
 24726:                     Domain             => Domain,
 24727:                     Ada_Node           => Expr);
 24728:
 24729:             when N_Membership_Test                      =>
 24730:                T :=
 24731:                  Transform_Membership_Expression (Local_Params, Domain, Expr);
```

## src/why/gnat2why-expr.adb:25500-25573

```ada
 25500:       --  This label will be used for pretty printing the expression
 25501:
 25502:       if Pretty_Label /= No_Symbol then
 25503:          T :=
 25504:            New_Label
 25505:              (Labels => Symbol_Sets.To_Set (Pretty_Label),
 25506:               Def    => T,
 25507:               Domain => Domain,
 25508:               Typ    => Get_Type (T));
 25509:       end if;
 25510:
 25511:       --  Insert an overflow check if flag Do_Overflow_Check is set. No
 25512:       --  conversion should be needed, as overflow checks are only set on
 25513:       --  intermediate expressions, whose transformation into Why should
 25514:       --  always have type "int" or "real". We start by checking that Expr has
 25515:       --  a kind on which we can call Do_Overflow_Check, otherwise there is
 25516:       --  nothing to do.
 25517:
 25518:       --  Note that N_Type_Conversions *may* have a Do_Overflow_Check flag, but
 25519:       --  they are actually for range checks and are checked elsewhere. See the
 25520:       --  documentation of sinfo.ads.
 25521:
 25522:       if Domain = EW_Prog
 25523:         and then
 25524:           Nkind (Expr)
 25525:           in N_Attribute_Reference | N_Case_Expression | N_If_Expression | N_Op
 25526:         and then Do_Overflow_Check (Expr)
 25527:       then
 25528:          --  Depending on the current mode for integer overflow checks, the
 25529:          --  operation is either done in the base type (Strict mode), or in
 25530:          --  Long_Long_Integer (Minimized mode) if needed, or in arbitrary
 25531:          --  precision if needed (Eliminated mode). A check may only be
 25532:          --  generated in the Strict and Minimized modes, and the type
 25533:          --  used for the bounds is the base type in the first case, and
 25534:          --  Long_Long_Integer in the second case (which is its own base type).
 25535:
 25536:          --  Use Sem.Scope_Suppress which takes into account the default from
 25537:          --  switches and configuration pragma files as defined in
 25538:          --  Opt.Suppress_Options, as well as possible configuration pragmas
 25539:          --  in the main unit, as done in SPARK_Definition.Mark_Pragma.
 25540:
 25541:          if Is_Signed_Integer_Type (Expr_Type) then
 25542:             declare
 25543:                Mode : Overflow_Mode_Type;
 25544:             begin
 25545:                case Params.Phase is
 25546:                   when Generate_VCs_For_Body      =>
 25547:                      Mode := Sem.Scope_Suppress.Overflow_Mode_General;
 25548:
 25549:                   when Generate_VCs_For_Assertion =>
 25550:                      Mode := Sem.Scope_Suppress.Overflow_Mode_Assertions;
 25551:
 25552:                   when others                     =>
 25553:                      raise Program_Error;
 25554:                end case;
 25555:
 25556:                case Mode is
 25557:                   when Strict     =>
 25558:                      T :=
 25559:                        +Insert_Overflow_Check
 25560:                           (Expr, T, Expr_Type, Is_Float => False);
 25561:
 25562:                   when Minimized  =>
 25563:                      T :=
 25564:                        +Insert_Overflow_Check
 25565:                           (Expr, T, Standard_Integer_64, Is_Float => False);
 25566:
 25567:                   when Eliminated =>
 25568:                      null;
 25569:
 25570:                   when Not_Set    =>
 25571:                      raise Program_Error;
 25572:                end case;
 25573:             end;
```

## src/why/gnat2why-expr.adb:25635-25724

```ada
 25635:
 25636:       --  Convert the expression to the expected type, if needed. This is
 25637:       --  intertwined with inserting range checks, and Insert_Conversion does
 25638:       --  both. This is because range checks need to be done on the Why "int"
 25639:       --  type, so they may trigger a conversion, or if a conversion is already
 25640:       --  needed, must be done on the "right side" of the conversion.
 25641:       --  Note that Insert_Conversion is smart enough to not insert any
 25642:       --  conversion when it's not needed.
 25643:
 25644:       --  A range check is needed only in programs (Domain EW_Prog), and on
 25645:       --  nodes that have the range check flag. For type conversions, the
 25646:       --  Do_Overflow_Check actually means that a range check is needed,
 25647:       --  instead of an overflow check (see sinfo.ads and the discussion of
 25648:       --  range checks and overflow checks there). Because range checks are
 25649:       --  determined by looking at the parent node, in that special case we go
 25650:       --  one step down for the Range_Check_Node.
 25651:
 25652:       --  In predicate domain, only the Boolean type is used, no conversion is
 25653:       --  needed.
 25654:
 25655:       if Domain in EW_Pred then
 25656:          null;
 25657:       else
 25658:          T :=
 25659:            Insert_Checked_Conversion
 25660:              (Ada_Node => Expr,
 25661:               Domain   => Domain,
 25662:               Expr     => T,
 25663:               To       => Expected_Type);
 25664:       end if;
 25665:
 25666:       return T;
 25667:    end Transform_Expr;
 25668:
 25669:    function Transform_Expr
 25670:      (Expr              : N_Subexpr_Id;
 25671:       Domain            : EW_Domain;
 25672:       Params            : Transformation_Params;
 25673:       No_Init_Check     : Boolean := False;
 25674:       No_Validity_Check : Boolean := False) return W_Expr_Id
 25675:    is
 25676:       Expected_Type : W_Type_Id := Why_Empty;
 25677:
 25678:    begin
 25679:       --  For record fields, use the type of the field access (that is, the
 25680:       --  type of the field in the Retyps of the record type) to avoid
 25681:       --  conversions.
 25682:       --  Note that this type may depend on discriminants, so it is in general
 25683:       --  a bad idea to try to convert to such a type. Converting from it
 25684:       --  should be OK though as it is never in split form.
 25685:
 25686:       if Nkind (Expr) = N_Selected_Component then
 25687:          declare
 25688:             Field : constant Entity_Id := Entity (Selector_Name (Expr));
 25689:             Ty    : constant Entity_Id := Retysp (Etype (Prefix (Expr)));
 25690:          begin
 25691:             Expected_Type :=
 25692:               (if Is_Part_Of_Protected_Object (Field)
 25693:                then
 25694:                  EW_Abstract
 25695:                    (Etype (Field),
 25696:                     Relaxed_Init => Expr_Has_Relaxed_Init (Expr))
 25697:                else
 25698:                  EW_Abstract
 25699:                    (Etype (Search_Component_In_Type (Ty, Field)),
 25700:                     Relaxed_Init => Expr_Has_Relaxed_Init (Expr)));
 25701:             --  If the component may have relaxed initialization, use the
 25702:             --  associated wrapper type.
 25703:          end;
 25704:
 25705:       else
 25706:          Expected_Type := Type_Of_Node (Expr);
 25707:       end if;
 25708:
 25709:       --  Set error node so that bugbox information will be correct
 25710:
 25711:       Current_Error_Node := Expr;
 25712:
 25713:       return
 25714:         Transform_Expr
 25715:           (Expr,
 25716:            Expected_Type,
 25717:            Domain,
 25718:            Params,
 25719:            No_Init_Check,
 25720:            No_Validity_Check);
 25721:    end Transform_Expr;
 25722:
 25723:    ---------------------------------
 25724:    -- Transform_Expr_With_Actions --
```

## src/why/gnat2why-expr.adb:26847-27088

```ada
 26847:    function Transform_Identifier
 26848:      (Params            : Transformation_Params;
 26849:       Expr              : Node_Id;
 26850:       Ent               : Entity_Id;
 26851:       Domain            : EW_Domain;
 26852:       Selector          : Selection_Kind := Why.Inter.Standard;
 26853:       No_Init_Check     : Boolean := False;
 26854:       No_Validity_Check : Boolean := False) return W_Expr_Id
 26855:    is
 26856:       C : constant Ada_Ent_To_Why.Cursor :=
 26857:         Ada_Ent_To_Why.Find (Symbol_Table, Ent);
 26858:       T : W_Expr_Id;
 26859:
 26860:    begin
 26861:       --  Emit warning on constants declared before the loop invariant if their
 26862:       --  value might not be known precisely at the current program point.
 26863:
 26864:       if Imprecise_Constant_Value_In_Loop (Ent) then
 26865:          pragma Assert (Is_Loop_Entity (Ent));
 26866:          Warning_Msg_N (Warn_Loop_Entity, Expr, Names => [Ent]);
 26867:       end if;
 26868:
 26869:       --  The special cases of this function are:
 26870:       --  * parameters, whose names are stored in Params.Name_Map (these can
 26871:       --    also be refs)
 26872:       --    ??? Params has no Name_Map component
 26873:       --  * quantified variables (use local name instead of global name)
 26874:       --  * fields of protected objects
 26875:
 26876:       if Ada_Ent_To_Why.Has_Element (C) then
 26877:          declare
 26878:             E : constant Item_Type := Ada_Ent_To_Why.Element (C);
 26879:
 26880:          begin
 26881:             pragma
 26882:               Assert (if Selector /= Why.Inter.Standard then E.Kind = Subp);
 26883:
 26884:             --  If E is a subprogram, use tha appropriate symbol depending on
 26885:             --  the domain and the selector.
 26886:
 26887:             if E.Kind = Subp then
 26888:                case Selector is
 26889:                   when Why.Inter.Standard =>
 26890:                      if Domain = EW_Prog then
 26891:                         T := +E.For_Prog;
 26892:                      else
 26893:                         T := +E.For_Logic.Id;
 26894:                      end if;
 26895:
 26896:                   when Why.Inter.Dispatch =>
 26897:                      if Domain = EW_Prog then
 26898:                         T := +E.Dispatch_Prog.Id;
 26899:                      else
 26900:                         T := +E.Dispatch_Logic.Id;
 26901:                      end if;
 26902:
 26903:                   when Why.Inter.Refine   =>
 26904:                      if Domain = EW_Prog then
 26905:                         T := +E.Refine_Prog.Id;
 26906:                      else
 26907:                         T := +E.For_Logic.Id;
 26908:                      end if;
 26909:                end case;
 26910:             else
 26911:                declare
 26912:                   Alias : constant Opt_Object_Kind_Id :=
 26913:                     Ultimate_Overlaid_Entity (Ent);
 26914:                   Var   : constant W_Expr_Id :=
 26915:                     Reconstruct_Item
 26916:                       (E,
 26917:                        Domain,
 26918:                        Params.Ref_Allowed,
 26919:                        Alias =>
 26920:                          (if Present (Alias) and then Is_Mutable_In_Why (Ent)
 26921:                           then
 26922:                             Transform_Identifier (Params, Expr, Alias, Domain)
 26923:                           else Why_Empty));
 26924:                begin
 26925:                   T := Var;
 26926:
 26927:                   --  Introduce initialization check if the object has an
 26928:                   --  Init component or is ultimately a scalar. Check the
 26929:                   --  predicates on initialization wrappers if any.
 26930:
 26931:                   if Is_Object (Ent)
 26932:                     and then Domain = EW_Prog
 26933:                     and then not No_Init_Check
 26934:                   then
 26935:                      if E.Init.Present then
 26936:                         declare
 26937:                            Init_Flag : constant W_Expr_Id :=
 26938:                              (if Params.Ref_Allowed
 26939:                               then
 26940:                                 New_Deref
 26941:                                   (Right => E.Init.Id, Typ => EW_Bool_Type)
 26942:                               else +E.Init.Id);
 26943:                         begin
 26944:                            Prepend
 26945:                              (New_Assert
 26946:                                 (Pred        =>
 26947:                                    New_VC_Pred
 26948:                                      (Expr,
 26949:                                       Pred_Of_Boolean_Term (+Init_Flag),
 26950:                                       VC_Initialization_Check),
 26951:                                  Assert_Kind => EW_Assert),
 26952:                               T);
 26953:                         end;
 26954:
 26955:                      elsif Is_Init_Wrapper_Type (Get_Type (T)) then
 26956:
 26957:                         --  Skip the top level predicate for parameters of
 26958:                         --  predicate functions.
 26959:
 26960:                         declare
 26961:                            Top_Predicate : constant Boolean :=
 26962:                              Ekind (Ent) /= E_In_Parameter
 26963:                              or else
 26964:                                not Is_Predicate_Function
 26965:                                      (Enclosing_Unit (Ent));
 26966:                            Typ           : constant Entity_Id :=
 26967:                              Get_Ada_Type_From_Item (E);
 26968:                         begin
 26969:                            if Has_Scalar_Full_View (Typ) then
 26970:
 26971:                               --  Inputs of scalar types do not use the init
 26972:                               --  wrapper.
 26973:
 26974:                               pragma Assert (Top_Predicate);
 26975:
 26976:                               T :=
 26977:                                 Insert_Initialization_Check
 26978:                                   (Expr,
 26979:                                    Typ,
 26980:                                    T,
 26981:                                    Domain,
 26982:                                    Exclude_Components => Relaxed);
 26983:                            else
 26984:                               T :=
 26985:                                 +Insert_Predicate_Check
 26986:                                    (Expr, Typ, +T, Top_Predicate);
 26987:                            end if;
 26988:
 26989:                            --  The parameter of a "for of" quantification over
 26990:                            --  arrays is basically an indexed component.
 26991:                            --  Check initialization of access address or
 26992:                            --  mutable discriminants.
 26993:
 26994:                            if Is_Quantified_Param_Over_Array (Ent) then
 26995:                               T :=
 26996:                                 Insert_Top_Level_Init_Check
 26997:                                   (Expr, Typ, T, Domain);
 26998:                            end if;
 26999:                         end;
 27000:                      end if;
 27001:                   end if;
 27002:
 27003:                   --  Introduce a validity check if the object has a Valid flag
 27004:
 27005:                   if Object_Has_Valid_Id (Ent)
 27006:                     and then Domain = EW_Prog
 27007:                     and then not No_Validity_Check
 27008:                   then
 27009:                      declare
 27010:                         Tmp : constant W_Expr_Id := New_Temp_For_Expr (T);
 27011:                      begin
 27012:                         T :=
 27013:                           +Sequence
 27014:                              (New_Assert
 27015:                                 (Pred        =>
 27016:                                    New_VC_Pred
 27017:                                      (Expr,
 27018:                                       +New_Is_Valid_Call_For_Expr
 27019:                                          (Tree   =>
 27020:                                             +Get_Valid_Id_From_Object
 27021:                                                (Ent, Params.Ref_Allowed),
 27022:                                           Expr   => Tmp,
 27023:                                           Ty     => Etype (Ent),
 27024:                                           Domain => EW_Pred),
 27025:                                       VC_Validity_Check),
 27026:                                  Assert_Kind => EW_Assert),
 27027:                               +Tmp);
 27028:                         T :=
 27029:                           Binding_For_Temp
 27030:                             (Tmp => Tmp, Context => T, Domain => Domain);
 27031:                      end;
 27032:                   end if;
 27033:
 27034:                   --  If we have an object with Async_Writers, we must havoc it
 27035:                   --  before dereferencing it. Given a ref term t, this
 27036:                   --  produces the sequence:
 27037:                   --     (__havoc(t); !t)
 27038:                   --  It is sound (and necessary) to only do that in the
 27039:                   --  program domain. We can be sure that the relevant Ada code
 27040:                   --  will pass this point at least once in program domain.
 27041:                   --  No need to havoc anything for overlays, the alias is
 27042:                   --  havocked when it is translated as volatile parameter for
 27043:                   --  the function call.
 27044:
 27045:                   if Is_Object (Ent)
 27046:                     and then Has_Volatile (Ent)
 27047:                     and then Has_Volatile_Property (Ent, Pragma_Async_Writers)
 27048:                     and then Domain in EW_Prog | EW_Pterm
 27049:                     and then Params.Ref_Allowed
 27050:                     and then No (Alias)
 27051:                   then
 27052:                      pragma Assert (Is_Mutable_In_Why (Ent));
 27053:
 27054:                      --  Assume dynamic invariant of the object after havoc
 27055:
 27056:                      declare
 27057:                         Typ      : constant Entity_Id := Type_Of_Node (Ent);
 27058:                         Dyn_Prop : constant W_Pred_Id :=
 27059:                           Compute_Dynamic_Invariant
 27060:                             (Expr   => +Var,
 27061:                              Ty     => Typ,
 27062:                              Params => Params,
 27063:                              Valid  =>
 27064:                                Get_Valid_Id_From_Object
 27065:                                  (Ent, Params.Ref_Allowed));
 27066:                         Eff      : constant W_Effects_Id := New_Effects;
 27067:                         procedure Effects_Append_Binder_To_Writes is new
 27068:                           Effects_Append_Binder (Effects_Append_To_Writes);
 27069:                         Havoc    : W_Prog_Id := +Void;
 27070:
 27071:                      begin
 27072:                         Effects_Append_Binder_To_Writes (Eff, E);
 27073:                         Havoc := New_Havoc_Statement (Effects => Eff);
 27074:
 27075:                         if Dyn_Prop /= True_Pred then
 27076:                            Prepend
 27077:                              (New_Assume_Statement (Pred => Dyn_Prop), T);
 27078:                         end if;
 27079:
 27080:                         Prepend (Havoc, T);
 27081:                      end;
 27082:                   end if;
 27083:                end;
 27084:             end if;
 27085:          end;
 27086:
 27087:       --  Discriminals are not translated in Why3. Use their discriminal link
 27088:       --  instead.
```

## src/why/gnat2why-expr.adb:29520-29561

```ada
 29520:          --  Transform_Assignment_Statement.
 29521:
 29522:          when N_Assignment_Statement                              =>
 29523:             declare
 29524:                Lvalue : constant Entity_Id := Name (Stmt_Or_Decl);
 29525:                W_Ty   : constant W_Type_Id := Type_Of_Node (Lvalue);
 29526:                T      : W_Prog_Id;
 29527:
 29528:             begin
 29529:                --  Sanity checking, the global state should be clean
 29530:
 29531:                pragma Assert (Target_Name = Why_Empty);
 29532:
 29533:                --  Create an identifier for references to the target name in
 29534:                --  the assigned expression.
 29535:
 29536:                Target_Name :=
 29537:                  New_Temp_Identifier (Typ => W_Ty, Base_Name => "target");
 29538:
 29539:                T := Transform_Assignment_Statement (Stmt_Or_Decl, Params);
 29540:
 29541:                --  Only introduce a binding for Target_Name if it was actually
 29542:                --  used in the assignment.
 29543:
 29544:                if Has_Target_Names (Stmt_Or_Decl) then
 29545:                   T :=
 29546:                     New_Binding
 29547:                       (Ada_Node => Stmt_Or_Decl,
 29548:                        Name     => Target_Name,
 29549:                        Def      =>
 29550:                          Transform_Prog
 29551:                            (Expr          => Lvalue,
 29552:                             Expected_Type => W_Ty,
 29553:                             Params        => Params),
 29554:                        Context  => T,
 29555:                        Typ      => W_Ty);
 29556:                end if;
 29557:
 29558:                --  Clean up global state
 29559:
 29560:                Target_Name := Why_Empty;
 29561:
```

## src/why/gnat2why-expr.adb:29733-29862

```ada
 29733:          when N_If_Statement                                      =>
 29734:             declare
 29735:                Cond        : constant Node_Id := Condition (Stmt_Or_Decl);
 29736:                Then_Part   : constant List_Id :=
 29737:                  Then_Statements (Stmt_Or_Decl);
 29738:                Then_Stmt   : W_Prog_Id;
 29739:                Num_Elsif   : constant Natural :=
 29740:                  Natural (List_Length (Elsif_Parts (Stmt_Or_Decl)));
 29741:                Elsif_Stmts : W_Prog_Array (1 .. Num_Elsif);
 29742:                Elsif_Conds : W_Prog_Array (1 .. Num_Elsif);
 29743:                Else_Part   : constant List_Id :=
 29744:                  Else_Statements (Stmt_Or_Decl);
 29745:                Else_Stmt   : W_Prog_Id;
 29746:
 29747:                Do_Warn : Boolean := Params.Warn_On_Dead;
 29748:                --  Whether we should warn on dead branches. This may be set to
 29749:                --  False if we encounter a statically disabled branch.
 29750:
 29751:                Warn_Then : constant Boolean :=
 29752:                  Do_Warn
 29753:                  and then
 29754:                    not Exp_Util.Is_Statically_Disabled
 29755:                          (Cond, False, Include_Valid => True);
 29756:
 29757:             begin
 29758:                --  Possibly warn on dead code
 29759:
 29760:                Then_Stmt :=
 29761:                  Transform_Statements_And_Declarations
 29762:                    (Then_Part, (Params with delta Warn_On_Dead => Warn_Then));
 29763:
 29764:                Then_Stmt :=
 29765:                  +Warn_On_Dead_Code
 29766:                     (First (Then_Part), +Then_Stmt, Params.Phase, Warn_Then);
 29767:
 29768:                Do_Warn :=
 29769:                  Do_Warn
 29770:                  and then
 29771:                    not Exp_Util.Is_Statically_Disabled
 29772:                          (Cond, True, Include_Valid => True);
 29773:
 29774:                --  The elsif parts need to be traversed in order to propagate
 29775:                --  the Do_Warn flag. Compute the conditions and statements
 29776:                --  and store then in Elsif_Conds and Elsif_Stmts so the
 29777:                --  conditional can be reconstructed afterward.
 29778:
 29779:                if Present (Elsif_Parts (Stmt_Or_Decl)) then
 29780:                   declare
 29781:                      Cur       : Node_Id := First (Elsif_Parts (Stmt_Or_Decl));
 29782:                      Cond      : Node_Id;
 29783:                      Warn_Then : Boolean;
 29784:
 29785:                   begin
 29786:
 29787:                      for I in Elsif_Conds'Range loop
 29788:                         Cond := Condition (Cur);
 29789:                         Elsif_Conds (I) :=
 29790:                           New_Counterexample_Assign
 29791:                             (Cur,
 29792:                              +Transform_Expr_With_Actions
 29793:                                 (Cond,
 29794:                                  Condition_Actions (Cur),
 29795:                                  EW_Bool_Type,
 29796:                                  EW_Prog,
 29797:                                  Params =>
 29798:                                    (Params
 29799:                                     with delta Warn_On_Dead => Do_Warn)));
 29800:
 29801:                         --  Possibly warn on an unreachable case branch
 29802:
 29803:                         Warn_Then :=
 29804:                           Do_Warn
 29805:                           and then
 29806:                             not Exp_Util.Is_Statically_Disabled
 29807:                                   (Cond, False, Include_Valid => True);
 29808:
 29809:                         Elsif_Stmts (I) :=
 29810:                           Transform_Statements_And_Declarations
 29811:                             (Then_Statements (Cur),
 29812:                              (Params with delta Warn_On_Dead => Warn_Then));
 29813:
 29814:                         Elsif_Stmts (I) :=
 29815:                           +Warn_On_Dead_Code
 29816:                              (First (Then_Statements (Cur)),
 29817:                               +Elsif_Stmts (I),
 29818:                               Params.Phase,
 29819:                               Warn_Then);
 29820:
 29821:                         Do_Warn :=
 29822:                           Do_Warn
 29823:                           and then
 29824:                             not Exp_Util.Is_Statically_Disabled
 29825:                                   (Cond, True, Include_Valid => True);
 29826:
 29827:                         Next (Cur);
 29828:                      end loop;
 29829:                   end;
 29830:                end if;
 29831:
 29832:                Else_Stmt :=
 29833:                  Transform_Statements_And_Declarations
 29834:                    (Else_Part, (Params with delta Warn_On_Dead => Do_Warn));
 29835:
 29836:                if Is_Non_Empty_List (Else_Part) then
 29837:                   Else_Stmt :=
 29838:                     +Warn_On_Dead_Code
 29839:                        (First (Else_Part), +Else_Stmt, Params.Phase, Do_Warn);
 29840:                end if;
 29841:
 29842:                --  Go over the elsif branches to reconstruct the conditional
 29843:
 29844:                for I in reverse Elsif_Conds'Range loop
 29845:                   Else_Stmt :=
 29846:                     New_Simpl_Conditional
 29847:                       (Condition => Elsif_Conds (I),
 29848:                        Then_Part => Elsif_Stmts (I),
 29849:                        Else_Part => Else_Stmt);
 29850:                end loop;
 29851:
 29852:                --  Finish by putting the main if-then-else on top.
 29853:
 29854:                return
 29855:                  New_Simpl_Conditional
 29856:                    (Condition =>
 29857:                       New_Counterexample_Assign
 29858:                         (Stmt_Or_Decl,
 29859:                          Transform_Prog
 29860:                            (Cond, EW_Bool_Type, Params => Params)),
 29861:                     Then_Part => Then_Stmt,
 29862:                     Else_Part => Else_Stmt);
```

## src/why/gnat2why-expr.adb:30221-30666

```ada
 30221:    function Transform_String_Literal
 30222:      (N : Node_Id; Domain : EW_Domain; Params : Transformation_Params)
 30223:       return W_Expr_Id
 30224:    is
 30225:       Is_Static : constant Boolean := Nkind (N) = N_String_Literal;
 30226:       Expr      : constant N_String_Literal_Id :=
 30227:         (if Is_Static then N else Expression (N));
 30228:       Ty        : constant Entity_Id := Type_Of_Node (N);
 30229:       pragma Assert (Is_Constrained (Ty));
 30230:       pragma Assert (Is_Static = Is_Static_Array_Type (Ty));
 30231:
 30232:       Low       : constant Node_Id :=
 30233:         (if Is_Static then String_Literal_Low_Bound (Ty) else Empty);
 30234:       Why_Type  : constant W_Type_Id := New_Abstract_Base_Type (Ty);
 30235:       Args      : constant W_Expr_Array :=
 30236:         (1 =>
 30237:            (if Is_Static
 30238:             then +Void
 30239:             else
 30240:               +Get_Array_Attr
 30241:                  (Domain => Term_Domain (Domain),
 30242:                   Ty     => Ty,
 30243:                   Attr   => Attribute_First,
 30244:                   Dim    => 1,
 30245:                   Params => Params)));
 30246:       --  If the low bound is not static, give it as a parameter. Otherwise,
 30247:       --  use a function with a unit parameter instead of a constant so that
 30248:       --  the axiom is only instantiated when the literal is used.
 30249:       Str_Value : constant String_Id := Strval (Expr);
 30250:       Length    : constant Nat := String_Length (Str_Value);
 30251:       Idx       : constant Entity_Id := First_Index (Retysp (Etype (Ty)));
 30252:       Idx_Ty    : constant Entity_Id := Retysp (Etype (Idx));
 30253:       B_Ty      : constant W_Type_Id := Base_Why_Type_No_Bool (Idx_Ty);
 30254:
 30255:       M  : W_Module_Id := E_Module (Expr);
 30256:       Id : W_Identifier_Id;
 30257:       T  : W_Expr_Id;
 30258:
 30259:    begin
 30260:       if M = Why_Empty then
 30261:          declare
 30262:             Low_Id  : constant W_Identifier_Id :=
 30263:               New_Temp_Identifier
 30264:                 (Base_Name => "low",
 30265:                  Typ       => Nth_Index_Rep_Type_No_Bool (Ty, 1));
 30266:             Binders : constant Binder_Array :=
 30267:               (1 =>
 30268:                  (if Is_Static
 30269:                   then Unit_Param
 30270:                   else
 30271:                     Binder_Type'
 30272:                       (B_Name => Low_Id,
 30273:                        B_Ent  => Null_Entity_Name,
 30274:                        others => <>)));
 30275:             Name    : constant String :=
 30276:               New_Temp_Identifier ("String_Literal");
 30277:             Id      : constant W_Identifier_Id :=
 30278:               New_Identifier (Ada_Node => N, Name => Name, Typ => Why_Type);
 30279:             Th      : Theory_UC;
 30280:          begin
 30281:             Insert_Extra_Module
 30282:               (Expr, New_Module (File => No_Symbol, Name => Name));
 30283:
 30284:             M := E_Module (Expr);
 30285:
 30286:             Th :=
 30287:               Open_Theory
 30288:                 (WF_Context,
 30289:                  M,
 30290:                  Comment =>
 30291:                    "Module for defining a value for string literal "
 30292:                    & (if Sloc (N) > 0
 30293:                       then " defined at " & Build_Location_String (Sloc (N))
 30294:                       else "")
 30295:                    & ", created in "
 30296:                    & GNAT.Source_Info.Enclosing_Entity);
 30297:
 30298:             --  Generate an abstract logic function for the Why3 map of the
 30299:             --  literal.
 30300:
 30301:             Emit
 30302:               (Th,
 30303:                New_Function_Decl
 30304:                  (Domain      => EW_Pterm,
 30305:                   Name        => Id,
 30306:                   Location    => No_Location,
 30307:                   Labels      => Symbol_Sets.Empty_Set,
 30308:                   Binders     => Binders,
 30309:                   Return_Type => Why_Type));
 30310:
 30311:             --  We now generate an axiom which gives the values stored in Id,
 30312:             --  when the literal contains only plain Character as expected by
 30313:             --  String_To_Name_Buffer.
 30314:
 30315:             if not (Has_Wide_Character (Expr)
 30316:                     or else Has_Wide_Wide_Character (Expr))
 30317:             then
 30318:                declare
 30319:                   Call       : constant W_Term_Id :=
 30320:                     +New_Call
 30321:                        (Domain  => EW_Term,
 30322:                         Name    => Id,
 30323:                         Binders => Binders,
 30324:                         Typ     => Why_Type);
 30325:                   Axiom_Name : constant String := Name & "__" & Def_Axiom;
 30326:                   Expr_Ar    : W_Pred_Array (1 .. Natural (Length));
 30327:                   Def        : W_Pred_Id;
 30328:
 30329:                begin
 30330:                   --  For each index in the string, add an assumption
 30331:                   --  specifying the value stored in Id at this index.
 30332:
 30333:                   for I in 1 .. Length loop
 30334:                      declare
 30335:                         Offset  : constant Uint := UI_From_Int (I - 1);
 30336:                         Idx_Val : constant W_Term_Id :=
 30337:                           (if Is_Static
 30338:                            then
 30339:                              New_Discrete_Constant
 30340:                                (Value => Expr_Value (Low) + Offset,
 30341:                                 Typ   => B_Ty)
 30342:                            else
 30343:                              +New_Discrete_Add
 30344:                                 (Domain => EW_Term,
 30345:                                  Left   => +Low_Id,
 30346:                                  Right  =>
 30347:                                    New_Discrete_Constant
 30348:                                      (Value => Offset, Typ => B_Ty)));
 30349:                         Arr_Val : constant W_Term_Id :=
 30350:                           New_Array_Access
 30351:                             (Ar => Call, Index => (1 => +Idx_Val));
 30352:                         Char    : constant W_Term_Id :=
 30353:                           New_Integer_Constant
 30354:                             (Value =>
 30355:                                UI_From_CC (Get_String_Char (Str_Value, I)));
 30356:                      begin
 30357:                         Expr_Ar (Positive (I)) :=
 30358:                           New_Comparison
 30359:                             (Symbol => Why_Eq,
 30360:                              Left   =>
 30361:                                Insert_Simple_Conversion
 30362:                                  (Expr => Arr_Val, To => EW_Int_Type),
 30363:                              Right  => Char);
 30364:                      end;
 30365:                   end loop;
 30366:
 30367:                   if Length > 0 then
 30368:                      Def := New_And_Pred (Expr_Ar);
 30369:                   else
 30370:                      Def := True_Pred;
 30371:                   end if;
 30372:
 30373:                   --  Add the value of the bounds for string literals with a
 30374:                   --  non-static low bound.
 30375:
 30376:                   if not Is_Static then
 30377:                      declare
 30378:                         High_Term    : constant W_Term_Id :=
 30379:                           (if Length = 0
 30380:                            then
 30381:                              +New_Discrete_Substract
 30382:                                 (Domain => EW_Term,
 30383:                                  Left   => +Low_Id,
 30384:                                  Right  =>
 30385:                                    New_Discrete_Constant
 30386:                                      (Value => Uint_1, Typ => B_Ty),
 30387:                                  Typ    => B_Ty)
 30388:                            else
 30389:                              +New_Discrete_Add
 30390:                                 (Domain => EW_Term,
 30391:                                  Left   => +Low_Id,
 30392:                                  Right  =>
 30393:                                    New_Discrete_Constant
 30394:                                      (Value => UI_From_Int (Length - 1),
 30395:                                       Typ   => B_Ty),
 30396:                                  Typ    => B_Ty));
 30397:                         Bounds_Value : W_Pred_Id :=
 30398:                           New_And_Pred
 30399:                             (Left  =>
 30400:                                New_Comparison
 30401:                                  (Symbol => Why_Eq,
 30402:                                   Left   =>
 30403:                                     Get_Array_Attr
 30404:                                       (Expr => Call,
 30405:                                        Attr => Attribute_First,
 30406:                                        Dim  => 1),
 30407:                                   Right  => +Low_Id),
 30408:                              Right =>
 30409:                                New_Comparison
 30410:                                  (Symbol => Why_Eq,
 30411:                                   Left   =>
 30412:                                     +Get_Array_Attr
 30413:                                        (Expr => Call,
 30414:                                         Attr => Attribute_Last,
 30415:                                         Dim  => 1),
 30416:                                   Right  => High_Term));
 30417:
 30418:                      begin
 30419:                         --  If the computation of the high bound wrap-arounds,
 30420:                         --  do not assume the bounds value to avoid generating
 30421:                         --  an incorrect axiom.
 30422:
 30423:                         if Is_Modular_Integer_Type (Idx_Ty) then
 30424:                            if Length = 0 then
 30425:                               Bounds_Value :=
 30426:                                 New_Conditional
 30427:                                   (Condition =>
 30428:                                      New_Comparison
 30429:                                        (Symbol => MF_BVs (B_Ty).Ugt,
 30430:                                         Left   => +Low_Id,
 30431:                                         Right  => High_Term),
 30432:                                    Then_Part => Bounds_Value);
 30433:                            elsif Length >= 1 then
 30434:                               Bounds_Value :=
 30435:                                 New_Conditional
 30436:                                   (Condition =>
 30437:                                      New_Comparison
 30438:                                        (Symbol => MF_BVs (B_Ty).Ule,
 30439:                                         Left   => +Low_Id,
 30440:                                         Right  => High_Term),
 30441:                                    Then_Part => Bounds_Value);
 30442:                            end if;
 30443:                         end if;
 30444:
 30445:                         --  The low bound is taken as parameter, we should add
 30446:                         --  a guard to the axiom for the dynamic property of
 30447:                         --  the array to avoid generating an unsound axiom if
 30448:                         --  the bounds are not in their type.
 30449:
 30450:                         Bounds_Value :=
 30451:                           New_Conditional
 30452:                             (Condition =>
 30453:                                +New_Dynamic_Property
 30454:                                   (Domain => EW_Pred,
 30455:                                    Ty     => Base_Type (Ty),
 30456:                                    Args   => (+Low_Id, +High_Term),
 30457:                                    Params => Params),
 30458:                              Then_Part => Bounds_Value,
 30459:                              Typ       => EW_Bool_Type);
 30460:
 30461:                         Def :=
 30462:                           New_And_Pred (Left => Def, Right => Bounds_Value);
 30463:                      end;
 30464:                   end if;
 30465:
 30466:                   --  Emit an axiom containing all the assumptions
 30467:
 30468:                   Emit
 30469:                     (Th,
 30470:                      New_Axiom
 30471:                        (Ada_Node => N,
 30472:                         Name     => NID (Axiom_Name),
 30473:                         Def      =>
 30474:                           New_Universal_Quantif
 30475:                             (Binders  => Binders,
 30476:                              Triggers =>
 30477:                                New_Triggers
 30478:                                  (Triggers =>
 30479:                                     (1 =>
 30480:                                        New_Trigger (Terms => (1 => +Call)))),
 30481:                              Pred     => Def),
 30482:                         Dep      =>
 30483:                           New_Axiom_Dep (Name => Id, Kind => EW_Axdep_Func)));
 30484:
 30485:                   if Is_Static then
 30486:                      Def :=
 30487:                        New_Well_Formed_Pred
 30488:                          (New_Call
 30489:                             (Name => Id,
 30490:                              Args => (1 => +Void),
 30491:                              Typ  => Why_Type));
 30492:
 30493:                   else
 30494:                      Def :=
 30495:                        New_Universal_Quantif
 30496:                          (Binders  => Binders,
 30497:                           Triggers =>
 30498:                             New_Triggers
 30499:                               (Triggers =>
 30500:                                  (1 => New_Trigger (Terms => (1 => +Call)))),
 30501:                           Pred     => New_Well_Formed_Pred (Call));
 30502:                   end if;
 30503:
 30504:                   Emit
 30505:                     (Th,
 30506:                      New_Axiom
 30507:                        (Ada_Node => Expr,
 30508:                         Name     => NID (Axiom_Name & "__well_formed"),
 30509:                         Def      => Def,
 30510:                         Dep      =>
 30511:                           New_Axiom_Dep (Name => Id, Kind => EW_Axdep_Func)));
 30512:                end;
 30513:             end if;
 30514:
 30515:             Close_Theory
 30516:               (Th, Kind => Definition_Theory, Defined_Entity => Expr);
 30517:          end;
 30518:       end if;
 30519:
 30520:       Id :=
 30521:         New_Identifier
 30522:           (Ada_Node => Expr,
 30523:            Domain   => Domain,
 30524:            Module   => M,
 30525:            Symb     => NID (Lower_Case_First (Img (Get_Name (M)))),
 30526:            Typ      => Why_Type);
 30527:
 30528:       T :=
 30529:         New_Call
 30530:           (Ada_Node => Expr,
 30531:            Domain   => Domain,
 30532:            Name     => Id,
 30533:            Args     => Args,
 30534:            Typ      => Get_Typ (Id));
 30535:
 30536:       --  In the program domain, emit the necessary range checks. No need to
 30537:       --  emit them if everything is static. This case is rejected by the
 30538:       --  compiler.
 30539:
 30540:       if Domain = EW_Prog then
 30541:          declare
 30542:             Low_Expr : constant W_Term_Id :=
 30543:               (if Is_Static
 30544:                then
 30545:                  New_Discrete_Constant (Value => Expr_Value (Low), Typ => B_Ty)
 30546:                else
 30547:                  +New_Attribute_Expr
 30548:                     (Idx_Ty, EW_Term, Attribute_First, Params));
 30549:             Checks   : W_Pred_Id := True_Pred;
 30550:
 30551:          begin
 30552:             --  For empty strings, check that Low_Expr is not the
 30553:             --  first element of the base type.
 30554:
 30555:             if Length = 0 then
 30556:                if Is_Static
 30557:                  and then
 30558:                    Compile_Time_Known_Value
 30559:                      (Type_Low_Bound (Base_Type (Idx_Ty)))
 30560:                then
 30561:                   pragma
 30562:                     Assert
 30563:                       (Expr_Value (Low)
 30564:                        /= Expr_Value (Type_Low_Bound (Base_Type (Idx_Ty))));
 30565:                else
 30566:                   Checks :=
 30567:                     New_Comparison
 30568:                       (Symbol => Why_Neq,
 30569:                        Left   => Low_Expr,
 30570:                        Right  =>
 30571:                          +New_Attribute_Expr
 30572:                             (Base_Type (Idx_Ty),
 30573:                              EW_Term,
 30574:                              Attribute_First,
 30575:                              Params));
 30576:                end if;
 30577:
 30578:             else
 30579:                declare
 30580:                   Offset     : constant W_Term_Id :=
 30581:                     New_Discrete_Constant
 30582:                       (Value => UI_From_Int (Length - 1), Typ => B_Ty);
 30583:                   Last_Index : constant W_Term_Id :=
 30584:                     (if Why_Type_Is_BitVector (B_Ty)
 30585:                      then
 30586:                        +New_Binary_Op_Expr
 30587:                           (Op          => N_Op_Add,
 30588:                            Left        => +Low_Expr,
 30589:                            Right       => +Offset,
 30590:                            Left_Type   => Idx_Ty,
 30591:                            Right_Type  => Idx_Ty,
 30592:                            Return_Type => Idx_Ty,
 30593:                            Domain      => EW_Term)
 30594:                      else
 30595:                        +New_Discrete_Add
 30596:                           (Domain => EW_Term,
 30597:                            Left   => +Low_Expr,
 30598:                            Right  => +Offset));
 30599:
 30600:                begin
 30601:                   --  Check that the last index is at most the last
 30602:                   --  index of the subtype.
 30603:
 30604:                   if Is_Static
 30605:                     and then
 30606:                       Compile_Time_Known_Value (Type_High_Bound (Idx_Ty))
 30607:                   then
 30608:                      pragma
 30609:                        Assert
 30610:                          (Expr_Value (Low) + UI_From_Int (Length - 1)
 30611:                           <= Expr_Value (Type_High_Bound (Idx_Ty)));
 30612:                   else
 30613:                      Checks :=
 30614:                        New_Comparison
 30615:                          (Symbol =>
 30616:                             (if Why_Type_Is_BitVector (B_Ty)
 30617:                              then MF_BVs (B_Ty).Ule
 30618:                              else Int_Infix_Le),
 30619:                           Left   => Last_Index,
 30620:                           Right  =>
 30621:                             +New_Attribute_Expr
 30622:                                (Idx_Ty, EW_Term, Attribute_Last, Params));
 30623:                   end if;
 30624:
 30625:                   --  For bitvectors, add no-wraparound check
 30626:
 30627:                   if Why_Type_Is_BitVector (B_Ty) then
 30628:                      if Is_Static
 30629:                        and then
 30630:                          Compile_Time_Known_Value (Type_High_Bound (Idx_Ty))
 30631:                      then
 30632:                         pragma
 30633:                           Assert
 30634:                             (Expr_Value (Low) + UI_From_Int (Length - 1)
 30635:                              <= Expr_Value (Type_High_Bound (Idx_Ty)));
 30636:                      else
 30637:                         Checks :=
 30638:                           New_And_Pred
 30639:                             (New_Comparison
 30640:                                (Symbol => MF_BVs (B_Ty).Ule,
 30641:                                 Left   => Low_Expr,
 30642:                                 Right  => Last_Index),
 30643:                              Checks);
 30644:                      end if;
 30645:                   end if;
 30646:                end;
 30647:
 30648:             end if;
 30649:
 30650:             if not Is_True_Boolean (+Checks) then
 30651:                T :=
 30652:                  +Sequence
 30653:                     (New_Ignore
 30654:                        (Prog =>
 30655:                           New_Located_Assert
 30656:                             (Ada_Node => Expr,
 30657:                              Pred     => Checks,
 30658:                              Reason   => VC_Range_Check,
 30659:                              Kind     => EW_Assert)),
 30660:                      Right => +T);
 30661:             end if;
 30662:          end;
 30663:       end if;
 30664:
 30665:       return T;
 30666:    end Transform_String_Literal;
```

## src/why/gnat2why-expr.adb:30936-31120

```ada
 30936:    procedure Variables_In_Dynamic_Invariant
 30937:      (Ty : Type_Kind_Id; Variables : in out Flow_Id_Sets.Set; Scop : Entity_Id)
 30938:    is
 30939:
 30940:       procedure Variables_In_Dynamic_Invariant
 30941:         (Ty          : Entity_Id;
 30942:          Variables   : in out Flow_Id_Sets.Set;
 30943:          Incompl_Acc : in out Entity_Sets.Set);
 30944:       --  Auxiliary function with an additional parameter storing access
 30945:       --  types to incomplete types already encountered (to avoid looping
 30946:       --  on recursive data-structures).
 30947:
 30948:       ------------------------------------
 30949:       -- Variables_In_Dynamic_Invariant --
 30950:       ------------------------------------
 30951:
 30952:       procedure Variables_In_Dynamic_Invariant
 30953:         (Ty          : Entity_Id;
 30954:          Variables   : in out Flow_Id_Sets.Set;
 30955:          Incompl_Acc : in out Entity_Sets.Set)
 30956:       is
 30957:          Spec_Ty : constant Entity_Id :=
 30958:            (if Is_Class_Wide_Type (Ty)
 30959:             then Get_Specific_Type_From_Classwide (Ty)
 30960:             else Ty);
 30961:          Ty_Ext  : constant Entity_Id := Retysp (Spec_Ty);
 30962:
 30963:       begin
 30964:          --  Dynamic property of the type itself
 30965:
 30966:          if Type_Is_Modeled_As_Base (Ty_Ext) then
 30967:
 30968:             --  If a scalar type is not modeled as base, then its bounds are
 30969:             --  constants.
 30970:             --  Otherwise, variables may occur in their expressions.
 30971:
 30972:             declare
 30973:                Rng : constant Node_Id := Get_Range (Ty_Ext);
 30974:             begin
 30975:                Variables.Union
 30976:                  (Get_Variables_For_Proof (Low_Bound (Rng), Ty_Ext));
 30977:                Variables.Union
 30978:                  (Get_Variables_For_Proof (High_Bound (Rng), Ty_Ext));
 30979:             end;
 30980:          elsif Is_Array_Type (Ty_Ext)
 30981:            and then not Is_Static_Array_Type (Ty_Ext)
 30982:          then
 30983:
 30984:             --  Variables coming from the bounds of the index types
 30985:
 30986:             declare
 30987:                Index : Node_Id := First_Index (Ty_Ext);
 30988:             begin
 30989:                while Present (Index) loop
 30990:                   if Type_Is_Modeled_As_Base (Etype (Index)) then
 30991:                      declare
 30992:                         Rng : constant Node_Id := Get_Range (Etype (Index));
 30993:                      begin
 30994:                         Variables.Union
 30995:                           (Get_Variables_For_Proof (Low_Bound (Rng), Ty_Ext));
 30996:                         Variables.Union
 30997:                           (Get_Variables_For_Proof (High_Bound (Rng), Ty_Ext));
 30998:                      end;
 30999:                   end if;
 31000:                   Next_Index (Index);
 31001:                end loop;
 31002:             end;
 31003:
 31004:             --  If the array is constrained, also assume the value of its
 31005:             --  bounds.
 31006:
 31007:             if Is_Constrained (Ty_Ext) then
 31008:                declare
 31009:                   Index : Node_Id := First_Index (Ty_Ext);
 31010:                begin
 31011:                   while Present (Index) loop
 31012:                      declare
 31013:                         Rng : constant Node_Id := Get_Range (Index);
 31014:                      begin
 31015:                         Variables.Union
 31016:                           (Get_Variables_For_Proof (Low_Bound (Rng), Ty_Ext));
 31017:                         Variables.Union
 31018:                           (Get_Variables_For_Proof (High_Bound (Rng), Ty_Ext));
 31019:                      end;
 31020:                      Next_Index (Index);
 31021:                   end loop;
 31022:                end;
 31023:             end if;
 31024:
 31025:          elsif Has_Discriminants (Ty_Ext) then
 31026:
 31027:             --  Variables coming from the record's discriminants
 31028:
 31029:             declare
 31030:                Discr : Entity_Id := First_Discriminant (Ty_Ext);
 31031:                Elmt  : Elmt_Id :=
 31032:                  (if Is_Constrained (Ty_Ext)
 31033:                   then First_Elmt (Discriminant_Constraint (Ty_Ext))
 31034:                   else No_Elmt);
 31035:             begin
 31036:                while Present (Discr) loop
 31037:                   if Is_Constrained (Ty_Ext) then
 31038:                      Variables.Union
 31039:                        (Get_Variables_For_Proof (Node (Elmt), Ty_Ext));
 31040:                      Next_Elmt (Elmt);
 31041:                   end if;
 31042:
 31043:                   Variables_In_Dynamic_Invariant
 31044:                     (Etype (Discr), Variables, Incompl_Acc);
 31045:                   Next_Discriminant (Discr);
 31046:                end loop;
 31047:             end;
 31048:          end if;
 31049:
 31050:          --  Variables in the predicate of the type
 31051:
 31052:          if Has_Predicates (Ty_Ext) then
 31053:             Variables_In_Dynamic_Predicate (Ty_Ext, Variables);
 31054:          end if;
 31055:
 31056:          --  Dynamic Invariant of Ty_Ext's components
 31057:
 31058:          if Is_Array_Type (Ty_Ext)
 31059:            and then Ekind (Ty_Ext) /= E_String_Literal_Subtype
 31060:          then
 31061:
 31062:             Variables_In_Dynamic_Invariant
 31063:               (Component_Type (Ty_Ext), Variables, Incompl_Acc);
 31064:
 31065:          elsif Is_Record_Type (Ty_Ext)
 31066:            or else Is_Incomplete_Or_Private_Type (Ty_Ext)
 31067:          then
 31068:
 31069:             for Field of Get_Component_Set (Ty_Ext) loop
 31070:                if not Is_Type (Field) then
 31071:                   Variables_In_Dynamic_Invariant
 31072:                     (Etype (Field), Variables, Incompl_Acc);
 31073:                end if;
 31074:             end loop;
 31075:          elsif Is_Access_Type (Ty_Ext)
 31076:            and then not Is_Access_Subprogram_Type (Ty_Ext)
 31077:            and then
 31078:              (not Designates_Incomplete_Type (Repr_Pointer_Type (Ty_Ext))
 31079:               or else not Incompl_Acc.Contains (Repr_Pointer_Type (Ty_Ext)))
 31080:          then
 31081:             if Designates_Incomplete_Type (Repr_Pointer_Type (Ty_Ext)) then
 31082:                Incompl_Acc.Insert (Repr_Pointer_Type (Ty_Ext));
 31083:             end if;
 31084:
 31085:             Variables_In_Dynamic_Invariant
 31086:               (Directly_Designated_Type (Ty_Ext), Variables, Incompl_Acc);
 31087:          end if;
 31088:
 31089:          --  Assumed type invariant of Ty_Ext and its parents if any
 31090:
 31091:          declare
 31092:             Current : Entity_Id := Ty_Ext;
 31093:             Parent  : Entity_Id;
 31094:          begin
 31095:             loop
 31096:                if Has_Invariants_In_SPARK (Current)
 31097:                  and then
 31098:                    (Invariant_Assumed_In_Main (Current)
 31099:                     or else
 31100:                       (Present (Scop)
 31101:                        and then Invariant_Assumed_In_Scope (Current, Scop)))
 31102:                then
 31103:                   Variables_In_Type_Invariant (Current, Variables);
 31104:                end if;
 31105:
 31106:                Parent := Retysp (Etype (Current));
 31107:                exit when Current = Parent;
 31108:                Current := Parent;
 31109:             end loop;
 31110:          end;
 31111:       end Variables_In_Dynamic_Invariant;
 31112:
 31113:       --  Local variables
 31114:
 31115:       Incompl_Acc : Entity_Sets.Set;
 31116:
 31117:       --  Start of processing for Variables_In_Dynamic_Invariant
 31118:
 31119:    begin
 31120:       Variables_In_Dynamic_Invariant (Ty, Variables, Incompl_Acc);
```

## src/why/gnat2why-expr.adb:31162-31211

```ada
 31162:    function Warn_On_Dead_Branch_Or_Code
 31163:      (N       : Node_Id;
 31164:       W       : W_Prog_Id;
 31165:       Branch  : Boolean;
 31166:       Phase   : Transformation_Phase;
 31167:       Do_Warn : Boolean) return W_Prog_Id
 31168:    is
 31169:       Stmt : W_Prog_Id;
 31170:
 31171:    begin
 31172:       --  Only issue a check for unreachable branch if:
 31173:       --  - switch --proof-warnings is set
 31174:       --  - and warnings are not suppressed
 31175:       --  - and this specific warning is not suppressed
 31176:       --  - and a warning can be issued on that node
 31177:       --  - and the phase corresponds to generating VCs
 31178:       --  - and when the next statement if not an unconditional error, signaled
 31179:       --    typically as a raise statement or a pragma Assert (False).
 31180:       if Gnat2Why_Args.Proof_Warnings
 31181:         and then Opt.Warning_Mode /= Opt.Suppress
 31182:         and then Do_Warn
 31183:         and then May_Issue_Warning_On_Node (N)
 31184:         and then Phase in Generate_VCs
 31185:         and then not Is_Error_Signaling_Statement (N)
 31186:       then
 31187:          Stmt :=
 31188:            New_Located_Assert
 31189:              (Ada_Node => N,
 31190:               Pred     => False_Pred,
 31191:               Reason   =>
 31192:                 (if Branch then VC_Unreachable_Branch else VC_Dead_Code),
 31193:               Kind     => EW_Check);
 31194:
 31195:          return
 31196:            Sequence
 31197:              ((1 =>
 31198:                  New_Comment
 31199:                    (Comment =>
 31200:                       NID
 31201:                         ("Check dead branch "
 31202:                          & Build_Location_String (Sloc (N)))),
 31203:                2 => New_Ignore (Prog => Stmt),
 31204:                3 => W));
 31205:
 31206:       --  Otherwise return the argument unmodified
 31207:
 31208:       else
 31209:          return W;
 31210:       end if;
 31211:    end Warn_On_Dead_Branch_Or_Code;
```

## src/why/gnat2why-expr.adb:5465-5592

```ada
  5465:    function Compute_Default_Init
  5466:      (Expr             : W_Term_Id;
  5467:       Ty               : Type_Kind_Id;
  5468:       Params           : Transformation_Params := Body_Params;
  5469:       Skip_Last_Cond   : W_Term_Id := False_Term;
  5470:       Use_Pred         : Boolean := True;
  5471:       Include_Subtypes : Boolean := False) return W_Pred_Id
  5472:    is
  5473:
  5474:       Ty_Ext : constant Entity_Id := Retysp (Ty);
  5475:
  5476:       function Default_Init_For_Comp
  5477:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; Idx : W_Expr_Array)
  5478:          return W_Pred_Id
  5479:       with Pre => Is_Type (C_Ty);
  5480:       --  @param C_Expr expression for an array component
  5481:       --  @param C_Ty array component type
  5482:       --  @return predicate for individual array components
  5483:       --    <C_Expr> = <Default_Component_Value>  <if Ty has a default aspect>
  5484:       --    default_init (<C_Expr>), C_Ty)        <otherwise>
  5485:
  5486:       function Default_Init_For_Field
  5487:         (F_Expr : W_Term_Id; F_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id
  5488:       with
  5489:         Pre =>
  5490:           Is_Type (F_Ty)
  5491:           and then
  5492:             (Ekind (E) = E_Component
  5493:              or else Is_Type (E)
  5494:              or else Is_Part_Of_Protected_Object (E));
  5495:       --  @param F_Expr expression for the component
  5496:       --  @param F_Ty component type
  5497:       --  @param E node for a record component
  5498:       --  @return predicate for individual record components
  5499:       --   F_Expr = E.def               <if Field1 has a default>
  5500:       --   default_init (F_Expr, F_Ty)) <otherwise>
  5501:
  5502:       function Default_Init_Absent_Field
  5503:         (F_Expr : W_Term_Id; F_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id;
  5504:       --  Assume that components not present in discriminated records have a
  5505:       --  dummy value.
  5506:
  5507:       function Default_Init_For_Discr
  5508:         (D_Expr : W_Term_Id; D_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id
  5509:       with Pre => Is_Type (D_Ty) and then Ekind (E) = E_Discriminant;
  5510:       --  @param D_Expr expression for the discrimiant
  5511:       --  @param D_Ty discriminant type
  5512:       --  @param E node for a discriminant
  5513:       --  @return predicate for individual discrimiant
  5514:       --  D_Expr = E.default             <if Ty_Ext is unconstrained>
  5515:       --  D_Expr = stored_constraint (E) <otherwise>
  5516:
  5517:       -------------------------------
  5518:       -- Default_Init_Absent_Field --
  5519:       -------------------------------
  5520:
  5521:       function Default_Init_Absent_Field
  5522:         (F_Expr : W_Term_Id; F_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id
  5523:       is
  5524:          pragma Unreferenced (E);
  5525:          Dummy_Expr : W_Term_Id := +Why_Default_Value (EW_Term, F_Ty);
  5526:
  5527:       begin
  5528:          if Is_Init_Wrapper_Type (Get_Type (+F_Expr)) then
  5529:             Dummy_Expr :=
  5530:               Insert_Simple_Conversion
  5531:                 (Expr => Dummy_Expr, To => Get_Type (+F_Expr));
  5532:          end if;
  5533:
  5534:          return
  5535:            New_Comparison
  5536:              (Symbol => Why_Eq, Left => F_Expr, Right => Dummy_Expr);
  5537:       end Default_Init_Absent_Field;
  5538:
  5539:       ---------------------------
  5540:       -- Default_Init_For_Comp --
  5541:       ---------------------------
  5542:
  5543:       function Default_Init_For_Comp
  5544:         (C_Expr : W_Term_Id; C_Ty : Entity_Id; Idx : W_Expr_Array)
  5545:          return W_Pred_Id
  5546:       is
  5547:          pragma Unreferenced (Idx);
  5548:          P : W_Pred_Id;
  5549:       begin
  5550:          if Has_Default_Aspect (Ty_Ext) then
  5551:             pragma Assert (Is_Scalar_Type (C_Ty));
  5552:             P :=
  5553:               New_Comparison
  5554:                 (Symbol => Why_Eq,
  5555:                  Left   =>
  5556:                    Insert_Simple_Conversion
  5557:                      (Expr => C_Expr, To => Type_Of_Node (C_Ty)),
  5558:                  Right  =>
  5559:                    Transform_Term
  5560:                      (Expr          => Default_Aspect_Component_Value (Ty_Ext),
  5561:                       Expected_Type => Type_Of_Node (C_Ty),
  5562:                       Params        => Params));
  5563:
  5564:             --  Assume the value of the initialization flag for init wrappers
  5565:
  5566:             if Is_Init_Wrapper_Type (Get_Type (+C_Expr)) then
  5567:                P :=
  5568:                  New_And_Pred
  5569:                    (Left  => P,
  5570:                     Right =>
  5571:                       Pred_Of_Boolean_Term
  5572:                         (+New_Init_Attribute_Access (C_Ty, +C_Expr)));
  5573:             end if;
  5574:          else
  5575:             P :=
  5576:               Compute_Default_Init
  5577:                 (Expr     => C_Expr,
  5578:                  Ty       => C_Ty,
  5579:                  Params   => Params,
  5580:                  Use_Pred => Use_Pred);
  5581:          end if;
  5582:
  5583:          return P;
  5584:       end Default_Init_For_Comp;
  5585:
  5586:       ----------------------------
  5587:       -- Default_Init_For_Discr --
  5588:       ----------------------------
  5589:
  5590:       function Default_Init_For_Discr
  5591:         (D_Expr : W_Term_Id; D_Ty : Entity_Id; E : Entity_Id) return W_Pred_Id
  5592:       is
```

## src/why/gnat2why-expr.adb:5726-6011

```ada
  5726:             P :=
  5727:               Compute_Default_Init
  5728:                 (F_Expr, F_Ty, Params => Params, Use_Pred => Use_Pred);
  5729:          end if;
  5730:
  5731:          return P;
  5732:       end Default_Init_For_Field;
  5733:
  5734:       function Default_Init_For_Array is new
  5735:         Build_Predicate_For_Array (Default_Init_For_Comp);
  5736:
  5737:       function Default_Init_For_Record is new
  5738:         Build_Predicate_For_Record
  5739:           (Default_Init_For_Discr,
  5740:            Default_Init_For_Field,
  5741:            Default_Init_Absent_Field,
  5742:            Ignore_Private_State => False);
  5743:
  5744:       Tmp        : constant W_Term_Id := New_Temp_For_Expr (Expr);
  5745:       Assumption : W_Pred_Id := True_Pred;
  5746:       Variables  : Flow_Id_Sets.Set;
  5747:
  5748:       --  Start of processing for Compute_Default_Init
  5749:
  5750:    begin
  5751:       --  If Use_Precomputed_Func is true, then we already have generated a
  5752:       --  predicate for the default initial value of elements of type Ty_Ext,
  5753:       --  except if the type is an itype or if it is standard boolen.
  5754:
  5755:       if Use_Pred
  5756:         and then not Include_Subtypes
  5757:         and then not Is_Itype (Ty_Ext)
  5758:         and then not Is_Standard_Boolean_Type (Ty_Ext)
  5759:         and then not Is_Init_Wrapper_Type (Get_Type (+Expr))
  5760:       then
  5761:          Variables_In_Default_Init (Ty_Ext, Variables);
  5762:
  5763:          declare
  5764:             Vars : constant W_Expr_Array :=
  5765:               Get_Args_From_Variables (Variables, Params.Ref_Allowed);
  5766:
  5767:             Num_B : constant Positive := 2 + Vars'Length;
  5768:             Args  : W_Expr_Array (1 .. Num_B);
  5769:
  5770:          begin
  5771:             Args (1) :=
  5772:               Insert_Simple_Conversion
  5773:                 (Domain => EW_Term,
  5774:                  Expr   => +Expr,
  5775:                  To     => Type_Of_Node (Ty_Ext));
  5776:             Args (2) := +Skip_Last_Cond;
  5777:             Args (3 .. Num_B) := Vars;
  5778:
  5779:             return
  5780:               New_Call
  5781:                 (Name => E_Symb (Ty_Ext, WNE_Default_Init),
  5782:                  Args => Args,
  5783:                  Typ  => EW_Bool_Type);
  5784:          end;
  5785:       elsif Is_Scalar_Type (Ty_Ext) then
  5786:          if Has_Default_Aspect (Ty_Ext) then
  5787:             declare
  5788:                Default_Expr : constant W_Term_Id :=
  5789:                  Transform_Term
  5790:                    (Expr          => Default_Aspect_Value (Ty_Ext),
  5791:                     Expected_Type => Base_Why_Type (Ty_Ext),
  5792:                     Params        => Params);
  5793:             begin
  5794:                Assumption :=
  5795:                  New_Comparison
  5796:                    (Symbol => Why_Eq,
  5797:                     Left   =>
  5798:                       Insert_Simple_Conversion
  5799:                         (Ada_Node => Empty,
  5800:                          Expr     => Tmp,
  5801:                          To       => Base_Why_Type (Ty_Ext)),
  5802:                     Right  => Default_Expr);
  5803:             end;
  5804:
  5805:             --  If Tmp has a wrapper for initialization, set the init flag
  5806:             --  to True.
  5807:
  5808:             if Is_Init_Wrapper_Type (Get_Type (+Tmp)) then
  5809:                Assumption :=
  5810:                  New_And_Pred
  5811:                    (Left  => Assumption,
  5812:                     Right =>
  5813:                       Pred_Of_Boolean_Term
  5814:                         (New_Init_Attribute_Access (Ty_Ext, +Tmp)));
  5815:             end if;
  5816:          end if;
  5817:       elsif Is_Array_Type (Ty_Ext)
  5818:         and then Ekind (Ty_Ext) /= E_String_Literal_Subtype
  5819:       then
  5820:
  5821:          --  Generates:
  5822:          --  forall i1 : int ..
  5823:          --   in_range (i1) /\ .. ->
  5824:          --    get (<Expr>, i1, ...) = <Default_Component_Value>    <if any>
  5825:          --    default_init (get (<Expr>, i1, ...), Component_Type) <otherwise>
  5826:
  5827:          Assumption := Default_Init_For_Array (+Expr, Ty_Ext);
  5828:
  5829:          --  If Ty_Ext is constrained, also assume the array bounds
  5830:
  5831:          if Is_Constrained (Ty_Ext) and then not Is_Static_Array_Type (Ty_Ext)
  5832:          then
  5833:             Assumption :=
  5834:               New_And_Pred
  5835:                 (Left  => New_Bounds_Equality (Expr, Ty_Ext, Params => Params),
  5836:                  Right => Assumption);
  5837:          end if;
  5838:
  5839:       elsif Is_Access_Subprogram_Type (Ty_Ext) then
  5840:          Assumption :=
  5841:            Pred_Of_Boolean_Term
  5842:              (New_Record_Access
  5843:                 (Name  => Expr,
  5844:                  Field => M_Subprogram_Access.Rec_Is_Null,
  5845:                  Typ   => EW_Bool_Type));
  5846:
  5847:       elsif Is_Access_Type (Ty_Ext) then
  5848:          Assumption :=
  5849:            Pred_Of_Boolean_Term (New_Pointer_Is_Null_Access (Ty_Ext, Expr));
  5850:
  5851:          if Is_Init_Wrapper_Type (Get_Type (+Expr)) then
  5852:             Assumption :=
  5853:               New_And_Pred
  5854:                 (Left  =>
  5855:                    Pred_Of_Boolean_Term
  5856:                      (New_Init_Attribute_Access (Ty_Ext, Tmp)),
  5857:                  Right => Assumption);
  5858:          end if;
  5859:
  5860:       elsif Is_Simple_Private_Type (Ty_Ext) then
  5861:
  5862:          --  If Tmp has a wrapper for initialization, set the init flag to True
  5863:          --  if the type is fully initialized by default.
  5864:
  5865:          if Is_Init_Wrapper_Type (Get_Type (+Tmp))
  5866:            and then
  5867:              Default_Initialization (Ty_Ext) = Full_Default_Initialization
  5868:          then
  5869:             Assumption :=
  5870:               New_And_Pred
  5871:                 (Left  => Assumption,
  5872:                  Right =>
  5873:                    Pred_Of_Boolean_Term
  5874:                      (New_Init_Attribute_Access (Ty_Ext, +Tmp)));
  5875:          end if;
  5876:
  5877:       elsif Is_Record_Type_In_Why (Ty_Ext) then
  5878:
  5879:          --  Generates:
  5880:          --  let tmp1 = <Expr>.rec__disc1 in
  5881:          --   <if Ty_Ext as default discrs>
  5882:          --  <Expr>.rec__disc1 = Discr1.default  <if Ty_Ext is unconstrained>
  5883:          --  <Expr>.rec__disc1 = Discr1 /\ ..    <if Ty_Ext is constrained>
  5884:          --  (check_for_field1 expr ->
  5885:          --      <Expr>.rec__field1 = Field1.def      <if Field1 has a default>
  5886:          --      default_init (<Expr>.rec__field1, Etype (Field1))) <otherwise>
  5887:          --  /\ ..
  5888:
  5889:          --  if Ty_Ext is tagged, generate
  5890:          --     <Expr>.attr__tag = <Ty_Ext>.__tag
  5891:
  5892:          --  if Ty_Ext is has relaxed initialization and mutable discriminants,
  5893:          --  generate
  5894:          --     <Expr>.attr__init = true
  5895:
  5896:          if Is_Tagged_Type (Ty_Ext) then
  5897:             Assumption :=
  5898:               New_And_Pred
  5899:                 (Left  =>
  5900:                    New_Call
  5901:                      (Typ  => EW_Bool_Type,
  5902:                       Name => Why_Eq,
  5903:                       Args =>
  5904:                         (1 =>
  5905:                            New_Tag_Access
  5906:                              (Ada_Node => Ty,
  5907:                               Domain   => EW_Term,
  5908:                               Name     => +Tmp,
  5909:                               Ty       => Ty_Ext),
  5910:                          2 => +E_Symb (Ty_Ext, WNE_Tag))),
  5911:                  Right => Assumption);
  5912:          end if;
  5913:
  5914:          if Is_Init_Wrapper_Type (Get_Type (+Expr))
  5915:            and then Has_Mutable_Discriminants (Ty_Ext)
  5916:          then
  5917:             Assumption :=
  5918:               New_And_Pred
  5919:                 (Left  =>
  5920:                    Pred_Of_Boolean_Term
  5921:                      (New_Init_Attribute_Access (Ty_Ext, Tmp)),
  5922:                  Right => Assumption);
  5923:          end if;
  5924:
  5925:          Assumption :=
  5926:            New_And_Pred
  5927:              (Left  => Assumption,
  5928:               Right => Default_Init_For_Record (Expr, Ty_Ext));
  5929:       end if;
  5930:
  5931:       --  If Skip_Last_Cond is False, assume the default initial condition for
  5932:       --  Ty, when specified as a boolean expression.
  5933:
  5934:       if Has_DIC (Ty) then
  5935:          declare
  5936:             procedure Assume_DIC
  5937:               (Default_Init_Param : Formal_Kind_Id;
  5938:                Default_Init_Expr  : Node_Id)
  5939:             with
  5940:               Pre =>
  5941:                 Ekind (Default_Init_Param) = E_In_Parameter
  5942:                 and then Nkind (Default_Init_Expr) in N_Subexpr;
  5943:
  5944:             ----------------
  5945:             -- Assume_DIC --
  5946:             ----------------
  5947:
  5948:             procedure Assume_DIC
  5949:               (Default_Init_Param : Formal_Kind_Id;
  5950:                Default_Init_Expr  : Node_Id)
  5951:             is
  5952:                Init_Id : constant W_Identifier_Id :=
  5953:                  New_Temp_Identifier (Default_Init_Param, Get_Type (+Tmp));
  5954:                T       : W_Pred_Id;
  5955:
  5956:             begin
  5957:                Ada_Ent_To_Why.Push_Scope (Symbol_Table);
  5958:
  5959:                --  Register the temporary identifier Init_Id for
  5960:                --  parameter Init_Param in the symbol table. This ensures
  5961:                --  both that a distinct name is used each time
  5962:                --  (preventing name capture), and that the type of Tmp is
  5963:                --  used as the type used to represent Init_Param
  5964:                --  (avoiding type conversion).
  5965:
  5966:                Insert_Tmp_Item_For_Entity (Default_Init_Param, Init_Id);
  5967:
  5968:                --  Transform the default init expression into Why3
  5969:
  5970:                T :=
  5971:                  Transform_Pred (Expr => Default_Init_Expr, Params => Params);
  5972:
  5973:                --  Relate the name Init_Id used in the default init
  5974:                --  expression to the value Tmp for which the predicate is
  5975:                --  checked.
  5976:
  5977:                T :=
  5978:                  New_Binding
  5979:                    (Name    => Init_Id,
  5980:                     Def     => Tmp,
  5981:                     Context => T,
  5982:                     Typ     => Get_Type (+T));
  5983:
  5984:                --  Only take default init condition into account if
  5985:                --  Skip_Last_Cond is False.
  5986:
  5987:                T :=
  5988:                  New_Conditional
  5989:                    (Condition => +W_Expr_Id'(+Skip_Last_Cond),
  5990:                     Then_Part => True_Pred,
  5991:                     Else_Part => T,
  5992:                     Typ       => EW_Bool_Type);
  5993:
  5994:                Assumption := New_And_Pred (Left => Assumption, Right => T);
  5995:
  5996:                Ada_Ent_To_Why.Pop_Scope (Symbol_Table);
  5997:             end Assume_DIC;
  5998:
  5999:             procedure Assume_All_DIC is new
  6000:               Iterate_Applicable_DIC (Assume_DIC);
  6001:          begin
  6002:             Assume_All_DIC (Ty);
  6003:          end;
  6004:       end if;
  6005:
  6006:       if Assumption = True_Pred then
  6007:          return True_Pred;
  6008:       else
  6009:          return Binding_For_Temp (Tmp => Tmp, Context => Assumption);
  6010:       end if;
  6011:    end Compute_Default_Init;
```

## src/why/gnat2why-expr.adb:6820-7085

```ada
  6820:       if Type_Is_Modeled_As_Base (Ty_Ext)
  6821:         or else
  6822:           (Use_Split_Form_For_Type (Ty_Ext)
  6823:            and then Get_Type_Kind (Get_Type (+Expr)) /= EW_Abstract)
  6824:       then
  6825:          T :=
  6826:            +New_Dynamic_Property
  6827:               (Domain => EW_Pred,
  6828:                Ty     => Ty_Ext,
  6829:                Expr   => +Expr,
  6830:                Params => Params);
  6831:
  6832:          --  If a scalar variable is not initialized or invalid, then its
  6833:          --  dynamic property may be false. As initialization is checked
  6834:          --  separately by flow analysis, we can assume that the variable is in
  6835:          --  the type bounds as long as it does not introduce any unsoundness
  6836:          --  (the range is not empty). We can skip this if the range is
  6837:          --  statically non-empty.
  6838:
  6839:          if T /= True_Pred
  6840:            and then
  6841:              not (Has_Discrete_Type (Ty_Ext)
  6842:                   and then Has_OK_Static_Scalar_Subtype (Ty_Ext)
  6843:                   and then
  6844:                     UI_Le
  6845:                       (Expr_Value (Type_Low_Bound (Ty_Ext)),
  6846:                        Expr_Value (Type_High_Bound (Ty_Ext))))
  6847:          then
  6848:             declare
  6849:                Why_Rep_Type : constant W_Type_Id := Base_Why_Type (Ty_Ext);
  6850:                Le_Op        : constant W_Identifier_Id :=
  6851:                  (if Why_Type_Is_Float (Why_Rep_Type)
  6852:                   then MF_Floats (Why_Rep_Type).Le
  6853:                   elsif Why_Type_Is_BitVector (Why_Rep_Type)
  6854:                   then MF_BVs (Why_Rep_Type).Ule
  6855:                   else Int_Infix_Le);
  6856:                First        : constant W_Expr_Id :=
  6857:                  Insert_Simple_Conversion
  6858:                    (Domain => EW_Term,
  6859:                     Expr   =>
  6860:                       New_Attribute_Expr
  6861:                         (Ty     => Ty_Ext,
  6862:                          Domain => EW_Term,
  6863:                          Attr   => Attribute_First,
  6864:                          Params => Params),
  6865:                     To     => Why_Rep_Type);
  6866:                Last         : constant W_Expr_Id :=
  6867:                  Insert_Simple_Conversion
  6868:                    (Domain => EW_Term,
  6869:                     Expr   =>
  6870:                       New_Attribute_Expr
  6871:                         (Ty     => Ty_Ext,
  6872:                          Domain => EW_Term,
  6873:                          Attr   => Attribute_Last,
  6874:                          Params => Params),
  6875:                     To     => Why_Rep_Type);
  6876:                Fst_Le_Last  : constant W_Pred_Id :=
  6877:                  New_Call
  6878:                    (Name => Le_Op, Typ => EW_Bool_Type, Args => (First, Last));
  6879:                Init_Flag    : constant W_Pred_Id :=
  6880:                  New_And_Pred
  6881:                    (Left  =>
  6882:                       Pred_Of_Boolean_Term
  6883:                         (if Is_Init_Wrapper_Type (Get_Type (+Expr))
  6884:                          then New_Init_Attribute_Access (Ty_Ext, +Expr)
  6885:                          else Initialized),
  6886:                     Right =>
  6887:                       (if Present (Valid)
  6888:                        then Pred_Of_Boolean_Term (Valid)
  6889:                        else True_Pred));
  6890:                --  For scalars, the validity flag is a boolean, it can be used
  6891:                --  directly.
  6892:             begin
  6893:                T :=
  6894:                  New_Conditional
  6895:                    (Condition => New_Or_Pred (Init_Flag, Fst_Le_Last),
  6896:                     Then_Part => T,
  6897:                     Typ       => EW_Bool_Type);
  6898:             end;
  6899:          end if;
  6900:
  6901:       elsif Is_Access_Subprogram_Type (Ty_Ext) then
  6902:
  6903:          --  Assume the contract of the access-to-subprogram type if any
  6904:
  6905:          T :=
  6906:            New_Dynamic_Property_For_Subprogram
  6907:              (Ty => Ty_Ext, Expr => Expr, Params => Params);
  6908:
  6909:          --  Only assume that an object with null exclusion is not null if it
  6910:          --  is initialized. This is the case in most cases, since access types
  6911:          --  are initialized by default. However, out parameters might not be
  6912:          --  valid values of the type.
  6913:
  6914:          if Can_Never_Be_Null (Ty_Ext) then
  6915:             T :=
  6916:               New_And_Pred
  6917:                 (Left  =>
  6918:                    New_Conditional
  6919:                      (Condition => Pred_Of_Boolean_Term (Initialized),
  6920:                       Then_Part =>
  6921:                         New_Not
  6922:                           (Right =>
  6923:                              Pred_Of_Boolean_Term
  6924:                                (New_Record_Access
  6925:                                   (Name  => Expr,
  6926:                                    Field => M_Subprogram_Access.Rec_Is_Null,
  6927:                                    Typ   => EW_Bool_Type))),
  6928:                       Typ       => EW_Bool_Type),
  6929:                  Right => T);
  6930:          end if;
  6931:
  6932:       elsif Is_Access_Type (Ty_Ext) then
  6933:
  6934:          --  Only assume that an object with null exclusion is not null if it
  6935:          --  is initialized. This is the case in most cases, since access types
  6936:          --  are initialized by default. However, out parameters might not be
  6937:          --  valid values of the type.
  6938:
  6939:          if Can_Never_Be_Null (Ty_Ext) then
  6940:             T :=
  6941:               New_Conditional
  6942:                 (Condition => Pred_Of_Boolean_Term (Initialized),
  6943:                  Then_Part =>
  6944:                    New_Not
  6945:                      (Right =>
  6946:                         Pred_Of_Boolean_Term
  6947:                           (New_Pointer_Is_Null_Access
  6948:                              (E => Ty_Ext, Name => Expr))),
  6949:                  Typ       => EW_Bool_Type);
  6950:
  6951:          --  Access to object types have an invariant which fix the designated
  6952:          --  value when the pointer is null (so null pointers are logically
  6953:          --  equal). Assume it here.
  6954:
  6955:          else
  6956:             T :=
  6957:               New_Call
  6958:                 (Name =>
  6959:                    E_Symb
  6960:                      (Ty_Ext,
  6961:                       WNE_Dynamic_Property,
  6962:                       Relaxed_Init => Get_Relaxed_Init (Get_Type (+Expr))),
  6963:                  Args => (1 => +Expr));
  6964:          end if;
  6965:
  6966:       --  Do not assume bounds of arrays and discriminants if Only_Var is
  6967:       --  statically True.
  6968:
  6969:       elsif Is_True_Boolean (+Only_Var) then
  6970:          T := True_Pred;
  6971:
  6972:       elsif Is_Array_Type (Ty_Ext) and then not Is_Static_Array_Type (Ty_Ext)
  6973:       then
  6974:          T :=
  6975:            +New_Dynamic_Property
  6976:               (Domain => EW_Pred,
  6977:                Ty     => Ty_Ext,
  6978:                Expr   => +Expr,
  6979:                Params => Params);
  6980:
  6981:          --  For arrays, also assume the value of its bounds
  6982:
  6983:          if Is_Constrained (Ty_Ext)
  6984:            or else Is_Fixed_Lower_Bound_Array_Subtype (Ty_Ext)
  6985:          then
  6986:             declare
  6987:                Constrained : constant Boolean := Is_Constrained (Ty_Ext);
  6988:                Index       : Node_Id := First_Index (Ty_Ext);
  6989:                I           : Positive := 1;
  6990:             begin
  6991:                while Present (Index) loop
  6992:
  6993:                   --  If Ty is constrained or Index has a fixed lower bound,
  6994:                   --  assume the value of Ty'First.
  6995:
  6996:                   if Constrained
  6997:                     or else Is_Fixed_Lower_Bound_Index_Subtype (Etype (Index))
  6998:                   then
  6999:                      declare
  7000:                         Rng      : constant Node_Id := Get_Range (Index);
  7001:                         Rng_Ty   : constant W_Type_Id :=
  7002:                           Base_Why_Type_No_Bool (Etype (Index));
  7003:                         Low_Expr : constant W_Expr_Id :=
  7004:                           Transform_Expr
  7005:                             (Low_Bound (Rng), Rng_Ty, EW_Term, Params);
  7006:                         First_Eq : constant W_Pred_Id :=
  7007:                           New_Call
  7008:                             (Name => Why_Eq,
  7009:                              Typ  => EW_Bool_Type,
  7010:                              Args =>
  7011:                                (1 =>
  7012:                                   +Insert_Conversion_To_Rep_No_Bool
  7013:                                      (Get_Array_Attr
  7014:                                         (Expr => Expr,
  7015:                                          Attr => Attribute_First,
  7016:                                          Dim  => I)),
  7017:                                 2 => Low_Expr));
  7018:                      begin
  7019:
  7020:                         T := New_And_Pred (Left => T, Right => First_Eq);
  7021:
  7022:                         --  If Ty is constrained also assume the value of
  7023:                         --  Ty'Last.
  7024:
  7025:                         if Constrained then
  7026:                            declare
  7027:                               High_Expr : constant W_Expr_Id :=
  7028:                                 Transform_Expr
  7029:                                   (High_Bound (Rng), Rng_Ty, EW_Term, Params);
  7030:                               Last_Eq   : constant W_Pred_Id :=
  7031:                                 New_Call
  7032:                                   (Name => Why_Eq,
  7033:                                    Typ  => EW_Bool_Type,
  7034:                                    Args =>
  7035:                                      (1 =>
  7036:                                         +Insert_Conversion_To_Rep_No_Bool
  7037:                                            (Get_Array_Attr
  7038:                                               (Expr => Expr,
  7039:                                                Attr => Attribute_Last,
  7040:                                                Dim  => I)),
  7041:                                       2 => High_Expr));
  7042:                            begin
  7043:                               T := New_And_Pred (Left => T, Right => Last_Eq);
  7044:                            end;
  7045:                         end if;
  7046:                      end;
  7047:                   end if;
  7048:
  7049:                   Next_Index (Index);
  7050:                   I := I + 1;
  7051:                end loop;
  7052:             end;
  7053:          end if;
  7054:
  7055:          T :=
  7056:            New_Conditional
  7057:              (Condition => Pred_Of_Boolean_Term (Only_Var),
  7058:               Then_Part => True_Pred,
  7059:               Else_Part => T,
  7060:               Typ       => EW_Bool_Type);
  7061:
  7062:       elsif Has_Discriminants (Ty_Ext) and then Is_Constrained (Ty_Ext) then
  7063:          T :=
  7064:            New_Conditional
  7065:              (Condition => Pred_Of_Boolean_Term (Only_Var),
  7066:               Then_Part => True_Pred,
  7067:               Else_Part =>
  7068:                 +New_Dynamic_Property
  7069:                    (Domain => EW_Pred,
  7070:                     Ty     => Ty_Ext,
  7071:                     Expr   => +Expr,
  7072:                     Params => Params),
  7073:               Typ       => EW_Bool_Type);
  7074:       else
  7075:          T := True_Pred;
  7076:       end if;
  7077:
  7078:       --  Add possible dynamic predicate. If the type defines at least partial
  7079:       --  default initialization, the predicate is checked at default
  7080:       --  initialization so it can be assumed to always hold. Otherwise, the
  7081:       --  predicate is only valid for initialized data. In all cases, only
  7082:       --  assume the predicate of the type itself when the top predicate should
  7083:       --  be included. Otherwise, assume the predicate of the first ancestor
  7084:       --  only.
  7085:       --  Do not assume the predicate on composite initialization wrappers.
```

## src/why/gnat2why-expr.adb:946-954

```ada
   946:    function Transform_Expr_Or_Identifier
   947:      (N      : Node_Or_Entity_Id;
   948:       Domain : EW_Domain;
   949:       Params : Transformation_Params) return W_Expr_Id
   950:    is (if Nkind (N) = N_Defining_Identifier
   951:        then Transform_Identifier (Params, N, N, Domain)
   952:        else Transform_Expr (N, Domain, Params));
   953:    --  N may be an expression or an identifier. Call the appropriate
   954:    --  translation function.
```

## src/why/gnat2why-expr.adb:2707-2894

```ada
  2707:    -------------------------------
  2708:
  2709:    function Bind_From_Mapping_In_Expr
  2710:      (Params : Transformation_Params;
  2711:       Expr   : W_Expr_Id;
  2712:       N      : Node_Id;
  2713:       Name   : W_Identifier_Id;
  2714:       Domain : EW_Domain;
  2715:       As_Old : Boolean := False) return W_Expr_Id
  2716:    is
  2717:       Res : W_Expr_Id := Expr;
  2718:    begin
  2719:
  2720:       --  For potentially invalid expressions, also declare a binding for the
  2721:       --  validity flag.
  2722:
  2723:       if Nkind (N) = N_Defining_Identifier and then Object_Has_Valid_Id (N)
  2724:       then
  2725:          Res :=
  2726:            New_Typed_Binding
  2727:              (Name    => Name,
  2728:               Domain  => Domain,
  2729:               Def     =>
  2730:                 Insert_Simple_Conversion
  2731:                   (Domain => Prog_Or_Term_Domain (Domain),
  2732:                    Expr   =>
  2733:                      (if As_Old
  2734:                       then Transform_Attribute_Old (N, Domain, Params)
  2735:                       else
  2736:                         Transform_Identifier
  2737:                           (Params, N, N, Prog_Or_Term_Domain (Domain))),
  2738:                    To     => Get_Typ (Name)),
  2739:               Context => Res);
  2740:
  2741:          Res :=
  2742:            New_Typed_Binding
  2743:              (Name    => Get_Valid_Flag_For_Id (Name, Etype (N)),
  2744:               Domain  => Domain,
  2745:               Def     => +Get_Valid_Id_From_Object (N, Params.Ref_Allowed),
  2746:               Context => Res);
  2747:
  2748:       elsif Is_Potentially_Invalid_Expr (N)
  2749:         and then not Has_Scalar_Type (Etype (N))
  2750:       then
  2751:          declare
  2752:             Def        : W_Expr_Id;
  2753:             Valid_Flag : W_Expr_Id;
  2754:             Context    : Ref_Context;
  2755:          begin
  2756:             Transform_Potentially_Invalid_Expr
  2757:               (Expr       => N,
  2758:                Domain     => Prog_Or_Term_Domain (Domain),
  2759:                Params     => Params,
  2760:                Context    => Context,
  2761:                W_Expr     => Def,
  2762:                Valid_Flag => Valid_Flag,
  2763:                As_Old     => As_Old);
  2764:
  2765:             Res :=
  2766:               New_Typed_Binding
  2767:                 (Name    => Name,
  2768:                  Domain  => Domain,
  2769:                  Def     =>
  2770:                    Insert_Simple_Conversion
  2771:                      (Domain => Prog_Or_Term_Domain (Domain),
  2772:                       Expr   => Def,
  2773:                       To     => Get_Typ (Name)),
  2774:                  Context => Res);
  2775:
  2776:             Res :=
  2777:               New_Typed_Binding
  2778:                 (Name    => Get_Valid_Flag_For_Id (Name, Etype (N)),
  2779:                  Domain  => Domain,
  2780:                  Def     => +Valid_Flag,
  2781:                  Context => Res);
  2782:
  2783:             Res :=
  2784:               Bindings_For_Ref_Context
  2785:                 (Expr => Res, Context => Context, Domain => Domain);
  2786:          end;
  2787:       else
  2788:          Res :=
  2789:            New_Typed_Binding
  2790:              (Name    => Name,
  2791:               Domain  => Domain,
  2792:               Def     =>
  2793:                 Insert_Simple_Conversion
  2794:                   (Domain => Prog_Or_Term_Domain (Domain),
  2795:                    Expr   =>
  2796:                      (if As_Old
  2797:                       then Transform_Attribute_Old (N, Domain, Params)
  2798:                       else
  2799:                         Transform_Expr_Or_Identifier
  2800:                           (N, Prog_Or_Term_Domain (Domain), Params)),
  2801:                    To     => Get_Typ (Name)),
  2802:               Context => Res);
  2803:       end if;
  2804:
  2805:       return Res;
  2806:    end Bind_From_Mapping_In_Expr;
  2807:
  2808:    function Bind_From_Mapping_In_Expr
  2809:      (Params : Transformation_Params;
  2810:       Map    : Ada_To_Why_Ident.Map;
  2811:       Expr   : W_Expr_Id;
  2812:       Domain : EW_Domain;
  2813:       Subset : Node_Sets.Set;
  2814:       As_Old : Boolean := False) return W_Expr_Id
  2815:    is
  2816:       Result : W_Expr_Id := Expr;
  2817:       Cu     : Ada_To_Why_Ident.Cursor;
  2818:
  2819:    begin
  2820:       for N of Subset loop
  2821:          Cu := Map.Find (N);
  2822:
  2823:          if Ada_To_Why_Ident.Has_Element (Cu) then
  2824:             Result :=
  2825:               Bind_From_Mapping_In_Expr
  2826:                 (Params => Params,
  2827:                  Expr   => Result,
  2828:                  N      => N,
  2829:                  Name   => Ada_To_Why_Ident.Element (Cu),
  2830:                  Domain => Domain,
  2831:                  As_Old => As_Old);
  2832:          end if;
  2833:       end loop;
  2834:
  2835:       return Result;
  2836:    end Bind_From_Mapping_In_Expr;
  2837:
  2838:    -------------------------------
  2839:    -- Bind_From_Mapping_In_Prog --
  2840:    -------------------------------
  2841:
  2842:    function Bind_From_Mapping_In_Prog
  2843:      (Params : Transformation_Params;
  2844:       Map    : Ada_To_Why_Ident.Map;
  2845:       Expr   : W_Prog_Id) return W_Prog_Id
  2846:    is
  2847:       Result : W_Prog_Id := Expr;
  2848:
  2849:    begin
  2850:       for C in Map.Iterate loop
  2851:          Result :=
  2852:            +Bind_From_Mapping_In_Expr
  2853:               (Params => Params,
  2854:                Expr   => +Result,
  2855:                N      => Ada_To_Why_Ident.Key (C),
  2856:                Name   => Ada_To_Why_Ident.Element (C),
  2857:                Domain => EW_Prog,
  2858:                As_Old => False);
  2859:       end loop;
  2860:
  2861:       return Result;
  2862:    end Bind_From_Mapping_In_Prog;
  2863:
  2864:    function Bind_From_Mapping_In_Prog
  2865:      (Params : Transformation_Params;
  2866:       Map    : Loop_Entry_Values;
  2867:       Expr   : W_Prog_Id) return W_Prog_Id
  2868:    is
  2869:       Result : W_Prog_Id := Expr;
  2870:
  2871:    begin
  2872:       for C in Map.No_Checks.Iterate loop
  2873:          Result :=
  2874:            +Bind_From_Mapping_In_Expr
  2875:               (Params => Params,
  2876:                Expr   => +Result,
  2877:                N      => Ada_To_Why_Ident.Key (C),
  2878:                Name   => Ada_To_Why_Ident.Element (C),
  2879:                Domain => EW_Pterm,
  2880:                As_Old => False);
  2881:       end loop;
  2882:
  2883:       for C in Map.Regular.Iterate loop
  2884:          Result :=
  2885:            +Bind_From_Mapping_In_Expr
  2886:               (Params => Params,
  2887:                Expr   => +Result,
  2888:                N      => Ada_To_Why_Ident.Key (C),
  2889:                Name   => Ada_To_Why_Ident.Element (C),
  2890:                Domain => EW_Prog,
  2891:                As_Old => False);
  2892:       end loop;
  2893:
  2894:       return Result;
```

## src/why/gnat2why-expr.adb:3707-3834

```ada
  3707:    function Check_Scalar_Range
  3708:      (Params : Transformation_Params; N : Node_Id; Base : Type_Kind_Id)
  3709:       return W_Prog_Id
  3710:    is
  3711:       Rng  : constant Node_Id := Get_Range (N);
  3712:       Low  : constant Node_Id := Low_Bound (Rng);
  3713:       High : constant Node_Id := High_Bound (Rng);
  3714:
  3715:    begin
  3716:       --  If the range is static, raises no run-time errors by itself, and a
  3717:       --  base type is passed, we need to check that either the range is empty
  3718:       --  or the bounds fit in the base type. Do nothing when either of these
  3719:       --  conditions can be verified statically.
  3720:
  3721:       if Is_OK_Static_Range (Rng)
  3722:         and then Has_OK_Static_Scalar_Subtype (Base)
  3723:         and then
  3724:           ((if Is_Floating_Point_Type (Base)
  3725:             then Expr_Value_R (High) < Expr_Value_R (Low)
  3726:             else Expr_Value (High) < Expr_Value (Low))
  3727:            or else
  3728:              (Is_In_Range (N => Low, Typ => Base)
  3729:               and then Is_In_Range (N => High, Typ => Base)))
  3730:       then
  3731:          return +Void;
  3732:
  3733:       else
  3734:          declare
  3735:             Why_Base       : constant W_Type_Id :=
  3736:               Base_Why_Type_No_Bool (Base);
  3737:             Le             : constant W_Identifier_Id :=
  3738:               (if Why_Type_Is_Float (Why_Base)
  3739:                then MF_Floats (Why_Base).Le
  3740:                elsif Why_Type_Is_BitVector (Why_Base)
  3741:                then MF_BVs (Why_Base).Ule
  3742:                else Int_Infix_Le);
  3743:             Low_Expr       : constant W_Term_Id :=
  3744:               Transform_Term (Low, Why_Base, Params);
  3745:             High_Expr      : constant W_Term_Id :=
  3746:               Transform_Term (High, Why_Base, Params);
  3747:             First_In_Range : constant W_Pred_Id :=
  3748:               New_Call
  3749:                 (Name =>
  3750:                    (if Why_Type_Is_Float (Why_Base)
  3751:                     then MF_Floats (Why_Base).Ge
  3752:                     elsif Why_Type_Is_BitVector (Why_Base)
  3753:                     then MF_BVs (Why_Base).Uge
  3754:                     else Int_Infix_Ge),
  3755:                  Typ  => EW_Bool_Type,
  3756:                  Args =>
  3757:                    (+Low_Expr,
  3758:                     New_Attribute_Expr
  3759:                       (Base, EW_Term, Attribute_First, Params)));
  3760:             Last_In_Range  : constant W_Pred_Id :=
  3761:               New_Call
  3762:                 (Name => Le,
  3763:                  Typ  => EW_Bool_Type,
  3764:                  Args =>
  3765:                    (+High_Expr,
  3766:                     New_Attribute_Expr
  3767:                       (Base, EW_Term, Attribute_Last, Params)));
  3768:             First_Le_Last  : constant W_Pred_Id :=
  3769:               New_Call
  3770:                 (Name => Le,
  3771:                  Typ  => EW_Bool_Type,
  3772:                  Args => (+Low_Expr, +High_Expr));
  3773:             Precond        : constant W_Pred_Id :=
  3774:               New_Connection
  3775:                 (Op    => EW_Imply,
  3776:                  Left  => First_Le_Last,
  3777:                  Right =>
  3778:                    New_And_Pred
  3779:                      (Left => First_In_Range, Right => Last_In_Range));
  3780:
  3781:             Check_Range : W_Prog_Id;
  3782:          begin
  3783:
  3784:             --  We need to check both that the range is OK (either
  3785:             --  empty or contained in the range's type) and that there cannot
  3786:             --  be any runtime errors during the computation of the bounds.
  3787:             --  If the range bounds where computed by the frontend, we assume
  3788:             --  that they are correct.
  3789:
  3790:             Check_Range :=
  3791:               New_Any_Statement
  3792:                 (Ada_Node => N,
  3793:                  Pre      => Precond,
  3794:                  Reason   => VC_Range_Check,
  3795:                  Post     => True_Pred);
  3796:
  3797:             if Comes_From_Source (Original_Node (Low))
  3798:               and then not Is_OK_Static_Expression (Low)
  3799:             then
  3800:                Prepend
  3801:                  (New_Ignore
  3802:                     (Ada_Node => N,
  3803:                      Prog     => Transform_Prog (Low, Why_Base, Params)),
  3804:                   Check_Range);
  3805:             end if;
  3806:
  3807:             if Comes_From_Source (Original_Node (High))
  3808:               and then not Is_OK_Static_Expression (High)
  3809:             then
  3810:                Prepend
  3811:                  (New_Ignore
  3812:                     (Ada_Node => N,
  3813:                      Prog     => Transform_Prog (High, Why_Base, Params)),
  3814:                   Check_Range);
  3815:             end if;
  3816:
  3817:             return Check_Range;
  3818:          end;
  3819:       end if;
  3820:    end Check_Scalar_Range;
  3821:
  3822:    -------------------------------
  3823:    -- Check_Subprogram_Variants --
  3824:    -------------------------------
  3825:
  3826:    function Check_Subprogram_Variants
  3827:      (Call                  : Node_Id;
  3828:       Args                  : W_Expr_Array;
  3829:       Params                : Transformation_Params;
  3830:       Specialization_Module : Symbol := No_Symbol) return W_Prog_Id
  3831:    is
  3832:       Callee       : constant Entity_Id := Get_Called_Entity_For_Proof (Call);
  3833:       Call_Variant : constant Node_Id :=
  3834:         Get_Pragma (Callee, Pragma_Subprogram_Variant);
```

## src/why/gnat2why-expr.adb:3910-3927

```ada
  3910:    function Check_Subtype_Indication
  3911:      (Params : Transformation_Params; N : Node_Id; Sub_Type : Type_Kind_Id)
  3912:       return W_Prog_Id is
  3913:    begin
  3914:       if Is_Scalar_Type (Sub_Type) then
  3915:          return
  3916:            Check_Scalar_Range
  3917:              (Params => Params,
  3918:               N      => Sub_Type,
  3919:               Base   => Etype (Subtype_Mark (N)));
  3920:       else
  3921:          return +Void;
  3922:       end if;
  3923:    end Check_Subtype_Indication;
  3924:
  3925:    ---------------------------
  3926:    -- Check_UU_Restrictions --
  3927:    ---------------------------
```

## src/why/gnat2why-expr.adb:15420-15569

```ada
 15420:    function Transform_Actions
 15421:      (Actions : List_Id;
 15422:       Expr    : W_Expr_Id;
 15423:       Domain  : EW_Domain;
 15424:       Params  : Transformation_Params) return W_Expr_Id
 15425:    is
 15426:       T : W_Expr_Id;
 15427:       N : Node_Id;
 15428:
 15429:       Subdomain : constant EW_Domain :=
 15430:         (if Domain = EW_Pred then EW_Term else Domain);
 15431:
 15432:    begin
 15433:       T := Expr;
 15434:       N := Last (Actions);
 15435:       while Present (N) loop
 15436:          case Nkind (N) is
 15437:
 15438:             --  Currently ignore type declarations in actions. A more precise
 15439:             --  treatment would factor out the code of Transform_Declaration
 15440:             --  to possibly generate an assumption here.
 15441:
 15442:             when N_Subtype_Declaration | N_Full_Type_Declaration =>
 15443:                null;
 15444:
 15445:             when N_Object_Declaration                            =>
 15446:                declare
 15447:                   Name : constant Entity_Id := Defining_Identifier (N);
 15448:                   Item : constant Item_Type :=
 15449:                     Mk_Item_Of_Entity (Name, Local => True);
 15450:
 15451:                begin
 15452:                   pragma Assert (Ekind (Name) = E_Constant);
 15453:                   pragma Assert (Item.Kind = Regular);
 15454:
 15455:                   T :=
 15456:                     New_Typed_Binding
 15457:                       (Domain  => Subdomain,
 15458:                        Name    => Item.Main.B_Name,
 15459:                        Def     =>
 15460:                          Transform_Expr
 15461:                            (Expression (N),
 15462:                             Get_Typ (Item.Main.B_Name),
 15463:                             Subdomain,
 15464:                             Params),
 15465:                        Context => T);
 15466:                end;
 15467:
 15468:             when N_Ignored_In_SPARK                              =>
 15469:                null;
 15470:
 15471:             --  For an Itype reference, simply check for possible RTE in
 15472:             --  the program domain.
 15473:
 15474:             when N_Itype_Reference                               =>
 15475:                if Domain = EW_Prog then
 15476:                   declare
 15477:                      Cut_Assertion_Prag : Node_Id;
 15478:                      Cut_Assertion_Expr : Node_Id;
 15479:                      Cut_Assertion      : W_Pred_Id;
 15480:                   begin
 15481:                      Prepend
 15482:                        (Transform_Statement_Or_Declaration
 15483:                           (N,
 15484:                            Params,
 15485:                            Cut_Assertion_Prag,
 15486:                            Cut_Assertion_Expr,
 15487:                            Cut_Assertion),
 15488:                         T);
 15489:                   end;
 15490:                end if;
 15491:
 15492:             --  For an object renaming, simply check for possible RTE in
 15493:             --  the program domain.
 15494:
 15495:             when N_Object_Renaming_Declaration                   =>
 15496:                if Domain = EW_Prog then
 15497:                   Prepend (Transform_Declaration (N, Params), T);
 15498:                end if;
 15499:
 15500:             --  Introduce a check for assertions in the program domain
 15501:
 15502:             when N_Pragma                                        =>
 15503:                pragma Assert (Is_Pragma (N, Pragma_Check));
 15504:
 15505:                if not Is_Ignored_Pragma_Check (N) and then Domain = EW_Prog
 15506:                then
 15507:                   Prepend (Transform_Pragma (N, Params, Force => False), T);
 15508:                end if;
 15509:
 15510:             when others                                          =>
 15511:                raise Program_Error;
 15512:          end case;
 15513:
 15514:          Prev (N);
 15515:       end loop;
 15516:
 15517:       return T;
 15518:    end Transform_Actions;
 15519:
 15520:    -----------------------------------
 15521:    -- Transform_Actions_Preparation --
 15522:    -----------------------------------
 15523:
 15524:    procedure Transform_Actions_Preparation (Actions : List_Id) is
 15525:       N : Node_Id;
 15526:
 15527:    begin
 15528:       N := First (Actions);
 15529:       while Present (N) loop
 15530:          case Nkind (N) is
 15531:
 15532:             --  Currently ignore type declarations in actions. A more precise
 15533:             --  treatment would factor out the code of Transform_Declaration
 15534:             --  to possibly generate an assumption here.
 15535:
 15536:             when N_Subtype_Declaration | N_Full_Type_Declaration =>
 15537:                null;
 15538:
 15539:             --  Create an item for the declared object, bind it to the Ada
 15540:             --  entity in the Symbol_Table and store the definition in Values
 15541:             --  to create the binding afterward.
 15542:
 15543:             when N_Object_Declaration                            =>
 15544:                declare
 15545:                   Name : constant Entity_Id := Defining_Identifier (N);
 15546:                   Item : constant Item_Type :=
 15547:                     Mk_Item_Of_Entity (Name, Local => True);
 15548:                begin
 15549:                   pragma Assert (Ekind (Name) = E_Constant);
 15550:                   pragma Assert (Item.Kind = Regular);
 15551:
 15552:                   Ada_Ent_To_Why.Insert (Symbol_Table, Name, Item);
 15553:                end;
 15554:
 15555:             when N_Ignored_In_SPARK
 15556:                | N_Itype_Reference
 15557:                | N_Object_Renaming_Declaration                   =>
 15558:                null;
 15559:
 15560:             when N_Pragma                                        =>
 15561:                pragma Assert (Is_Pragma (N, Pragma_Check));
 15562:
 15563:             when others                                          =>
 15564:                raise Program_Error;
 15565:          end case;
 15566:
 15567:          Next (N);
 15568:       end loop;
 15569:    end Transform_Actions_Preparation;
```

## src/why/gnat2why-expr.adb:22840-23012

```ada
 22840:               New_Ignore
 22841:                 (Prog => Transform_Prog (Unqual_Conv (Name (Decl)), Params));
 22842:
 22843:          when N_Subtype_Declaration | N_Full_Type_Declaration =>
 22844:             declare
 22845:                Ent : constant Entity_Id :=
 22846:                  Retysp (Unique_Defining_Entity (Decl));
 22847:
 22848:                Base : Entity_Id;
 22849:                --  ??? this name is rather unfortunate, because we will assign
 22850:                --  "Base" with the "Parent_Type".
 22851:
 22852:             begin
 22853:                --  Check for absence of run-time errors when the type
 22854:                --  declaration is not simply a renaming of an existing type.
 22855:                --  This avoids duplicating checks for every such renaming. Do
 22856:                --  not generate checks for actual subtypes as they should be
 22857:                --  correct by construction.
 22858:
 22859:                pragma Assert (Entity_In_SPARK (Ent));
 22860:
 22861:                if not Is_Type_Renaming (Decl)
 22862:                  and then not Is_Actual_Subtype (Ent)
 22863:                then
 22864:                   Base := Get_Parent_Type_If_Check_Needed (Decl);
 22865:
 22866:                   if Present (Base) then
 22867:                      Base := Retysp (Base);
 22868:                   end if;
 22869:
 22870:                   case Ekind (Ent) is
 22871:                      when Scalar_Kind                =>
 22872:
 22873:                         --  Scalar type declarations can only require checks
 22874:                         --  when either their range is non-static, or their
 22875:                         --  Base type is not static.
 22876:
 22877:                         if (Present (Base)
 22878:                             and then
 22879:                               not SPARK_Atree.Is_OK_Static_Range
 22880:                                     (Get_Range (Base)))
 22881:                           or else
 22882:                             not SPARK_Atree.Is_OK_Static_Range
 22883:                                   (Get_Range (Ent))
 22884:                         then
 22885:                            R :=
 22886:                              Check_Scalar_Range
 22887:                                (Params => Params, N => Ent, Base => Base);
 22888:                         end if;
 22889:
 22890:                      when Array_Kind                 =>
 22891:                         declare
 22892:                            Index      : Node_Id;
 22893:                            Index_Base : Entity_Id;
 22894:                            Typ        : constant Node_Id :=
 22895:                              Component_Subtype_Indication (Decl);
 22896:                            Check_Idx  : constant Boolean :=
 22897:                              No (Base)
 22898:                              or else
 22899:                                (not Is_Constrained (Base)
 22900:                                 and then
 22901:                                   (Is_Constrained (Ent)
 22902:                                    or else
 22903:                                      Is_Fixed_Lower_Bound_Array_Subtype
 22904:                                        (Ent)));
 22905:                            --  We only need to check the index types of Ent if
 22906:                            --  either there is no Base or Base is unconstrained
 22907:                            --  and Ent has some constraints.
 22908:
 22909:                         begin
 22910:                            --  If the component type of the array has a
 22911:                            --  non-static subtype_indication, we generate a
 22912:                            --  check that the range_constraint is compatible
 22913:                            --  with the subtype.
 22914:
 22915:                            if Present (Typ)
 22916:                              and then No (Base)
 22917:                              and then Nkind (Typ) = N_Subtype_Indication
 22918:                              and then Comes_From_Source (Original_Node (Typ))
 22919:                            then
 22920:                               Prepend
 22921:                                 (Check_Subtype_Indication
 22922:                                    (Params   => Params,
 22923:                                     N        => Typ,
 22924:                                     Sub_Type => Component_Type (Ent)),
 22925:                                  R);
 22926:                            end if;
 22927:
 22928:                            --  For each discrete_subtype_definition that is a
 22929:                            --  non-static subtype_indication, we generate a
 22930:                            --  check that the range_constraint is compatible
 22931:                            --  with the subtype.
 22932:
 22933:                            if Check_Idx then
 22934:                               Index := First_Index (Ent);
 22935:                               while Present (Index) loop
 22936:                                  if Nkind (Index) = N_Subtype_Indication
 22937:                                    and then
 22938:                                      Comes_From_Source (Original_Node (Index))
 22939:                                  then
 22940:                                     Prepend
 22941:                                       (Check_Subtype_Indication
 22942:                                          (Params   => Params,
 22943:                                           N        => Index,
 22944:                                           Sub_Type => Etype (Index)),
 22945:                                        R);
 22946:                                  end if;
 22947:
 22948:                                  Next_Index (Index);
 22949:                               end loop;
 22950:                            end if;
 22951:
 22952:                            --  For each range_constraint of an array subtype,
 22953:                            --  we generate a check that it is compatible with
 22954:                            --  the subtype of the corresponding index in the
 22955:                            --  base array type.
 22956:
 22957:                            if Present (Base) and then Check_Idx then
 22958:                               Index := First_Index (Ent);
 22959:                               Index_Base := First_Index (Base);
 22960:                               while Present (Index) loop
 22961:                                  if Comes_From_Source (Original_Node (Index))
 22962:                                  then
 22963:                                     Prepend
 22964:                                       (Check_Scalar_Range
 22965:                                          (Params => Params,
 22966:                                           N      => Etype (Index),
 22967:                                           Base   => Etype (Index_Base)),
 22968:                                        R);
 22969:
 22970:                                     --  If the index type has a fixed first
 22971:                                     --  bound in Base, check that Ent has the
 22972:                                     --  same first bound.
 22973:
 22974:                                     if Is_Fixed_Lower_Bound_Index_Subtype
 22975:                                          (Etype (Index_Base))
 22976:                                     then
 22977:                                        Prepend
 22978:                                          (New_Located_Assert
 22979:                                             (Ada_Node => Etype (Index),
 22980:                                              Pred     =>
 22981:                                                +New_Comparison
 22982:                                                   (Symbol => Why_Eq,
 22983:                                                    Left   =>
 22984:                                                      New_Attribute_Expr
 22985:                                                        (Ty     =>
 22986:                                                           Etype (Index),
 22987:                                                         Domain => EW_Term,
 22988:                                                         Attr   =>
 22989:                                                           Attribute_First,
 22990:                                                         Params => Params),
 22991:                                                    Right  =>
 22992:                                                      New_Attribute_Expr
 22993:                                                        (Ty     =>
 22994:                                                           Etype (Index_Base),
 22995:                                                         Domain => EW_Term,
 22996:                                                         Attr   =>
 22997:                                                           Attribute_First,
 22998:                                                         Params => Params),
 22999:                                                    Domain => EW_Pred),
 23000:                                              Reason   => VC_Range_Check,
 23001:                                              Kind     => EW_Assert),
 23002:                                           R);
 23003:                                     end if;
 23004:                                  end if;
 23005:                                  Next_Index (Index);
 23006:                                  Next_Index (Index_Base);
 23007:                               end loop;
 23008:                            end if;
 23009:                         end;
 23010:
 23011:                      when E_Record_Type
 23012:                         | E_Record_Subtype
```

## src/why/gnat2why-expr.adb:23117-23232

```ada
 23117:                E : constant Entity_Id := Unique_Defining_Entity (Decl);
 23118:             begin
 23119:                if not Is_Generic_Unit (E) and then Entity_In_SPARK (E) then
 23120:                   Assume_For_Nested_Package
 23121:                     (E        => E,
 23122:                      Params   => Params,
 23123:                      Assumes  => R,
 23124:                      For_Decl => Nkind (Decl) = N_Package_Declaration,
 23125:                      For_Body =>
 23126:                        Nkind (Decl) = N_Package_Body
 23127:                        or else No (Package_Body (E)));
 23128:                end if;
 23129:             end;
 23130:
 23131:          when N_Itype_Reference                               =>
 23132:             declare
 23133:                Assoc : constant Node_Id :=
 23134:                  Associated_Node_For_Itype (Itype (Decl));
 23135:             begin
 23136:                if Nkind (Assoc) in N_Has_Etype then
 23137:                   return New_Ignore (Prog => Transform_Prog (Assoc, Params));
 23138:                else
 23139:                   return +Void;
 23140:                end if;
 23141:             end;
 23142:
 23143:          --  Block statements can occur for inlined function calls
 23144:
 23145:          when N_Block_Statement                               =>
 23146:             R := Transform_Block_Statement (Decl, Params);
 23147:
 23148:          when N_Ignored_In_SPARK
 23149:             | N_Task_Type_Declaration
 23150:             | N_Subprogram_Body
 23151:             | N_Protected_Body
 23152:             | N_Task_Body
 23153:             | N_Abstract_Subprogram_Declaration
 23154:             | N_Subprogram_Declaration
 23155:             | N_Entry_Declaration
 23156:             | N_Private_Extension_Declaration
 23157:             | N_Private_Type_Declaration
 23158:             | N_Component_Declaration                         =>
 23159:             null;
 23160:
 23161:          when N_Raise_xxx_Error                               =>
 23162:
 23163:             pragma Assert (No (Condition (Decl)));
 23164:             return Transform_Unhandled_Raise (Decl);
 23165:
 23166:          when others                                          =>
 23167:             Ada.Text_IO.Put_Line
 23168:               ("[Transform_Declaration] kind = "
 23169:                & Node_Kind'Image (Nkind (Decl)));
 23170:             raise Not_Implemented;
 23171:       end case;
 23172:
 23173:       --  Aspect or representation clause Address may involve computations
 23174:       --  that could lead to a RTE. Thus we need to check absence of RTE in
 23175:       --  the corresponding expression.
 23176:
 23177:       if Nkind (Decl) = N_Subprogram_Declaration then
 23178:          declare
 23179:             Expr : constant Node_Id := Get_Address_Expr (Decl);
 23180:          begin
 23181:             --  We generate the expression of the address for runtime checks
 23182:
 23183:             if Present (Expr) then
 23184:                declare
 23185:                   Why_Expr : constant W_Expr_Id :=
 23186:                     Transform_Expr (Expr, EW_Prog, Params);
 23187:                begin
 23188:                   R := +Sequence (New_Ignore (Prog => +Why_Expr), R);
 23189:                end;
 23190:             end if;
 23191:          end;
 23192:       end if;
 23193:
 23194:       return +Insert_Cnt_Loc_Label (Decl, +R);
 23195:    end Transform_Declaration;
 23196:
 23197:    ----------------------------
 23198:    -- Transform_Declarations --
 23199:    ----------------------------
 23200:
 23201:    function Transform_Declarations
 23202:      (L : List_Id; Params : Transformation_Params) return W_Prog_Id
 23203:    is
 23204:       Cur_Decl : Node_Id := First (L);
 23205:       Result   : W_Statement_Sequence_Id := Void_Sequence;
 23206:
 23207:    begin
 23208:       while Present (Cur_Decl) loop
 23209:          Append (Result, Transform_Declaration (Cur_Decl, Params));
 23210:          Next (Cur_Decl);
 23211:       end loop;
 23212:       return +Result;
 23213:    end Transform_Declarations;
 23214:
 23215:    ----------------------------------
 23216:    -- Transform_Declarations_Block --
 23217:    ----------------------------------
 23218:
 23219:    function Transform_Declarations_Block
 23220:      (L : List_Id; Core : W_Prog_Id; Params : Transformation_Params)
 23221:       return W_Prog_Id
 23222:    is
 23223:       Result : W_Statement_Sequence_Id := +Transform_Declarations (L, Params);
 23224:
 23225:    begin
 23226:       Append (Result, Core);
 23227:       return +Result;
 23228:    end Transform_Declarations_Block;
 23229:
 23230:    -------------------------------
 23231:    -- Transform_Delta_Aggregate --
 23232:    -------------------------------
```

## src/why/gnat2why-expr.adb:30068-30088

```ada
 30068:    procedure Transform_Statement_Or_Declaration_In_List
 30069:      (Stmt_Or_Decl : Node_Id;
 30070:       Params       : Transformation_Params;
 30071:       Seq          : in out W_Statement_Sequence_Id)
 30072:    is
 30073:       Cut_Assertion_Prag : Opt_N_Pragma_Id;
 30074:       Cut_Assertion_Expr : Opt_N_Subexpr_Id;
 30075:       Cut_Assertion      : W_Pred_Id;
 30076:       Prog               : constant W_Prog_Id :=
 30077:         +Insert_Cnt_Loc_Label
 30078:            (Stmt_Or_Decl,
 30079:             +Transform_Statement_Or_Declaration
 30080:                (Stmt_Or_Decl        => Stmt_Or_Decl,
 30081:                 Params              => Params,
 30082:                 Assert_And_Cut_Prag => Cut_Assertion_Prag,
 30083:                 Assert_And_Cut_Expr => Cut_Assertion_Expr,
 30084:                 Assert_And_Cut      => Cut_Assertion));
 30085:    begin
 30086:       Append (Seq, Prog);
 30087:
 30088:       --  If we are translating a label, catch the exception which may have
```

## src/why/gnat2why-subprograms.adb:4455-4483

```ada
  4455:    procedure Generate_VCs_For_Subprogram (E : Callable_Kind_Id) is
  4456:       Name : constant String := Full_Name (E);
  4457:       Th   : Theory_UC;
  4458:
  4459:       --  Start of processing for Generate_VCs_For_Subprogram
  4460:
  4461:    begin
  4462:       Th :=
  4463:         Open_Theory
  4464:           (WF_Main,
  4465:            New_Module (Name => Name & "__subprogram_def", File => No_Symbol),
  4466:            Comment =>
  4467:              "Module for checking contracts and absence of "
  4468:              & "run-time errors in subprogram "
  4469:              & """"
  4470:              & Get_Name_String (Chars (E))
  4471:              & """"
  4472:              & (if Sloc (E) > 0
  4473:                 then " defined at " & Build_Location_String (Sloc (E))
  4474:                 else "")
  4475:              & ", created in "
  4476:              & GNAT.Source_Info.Enclosing_Entity);
  4477:
  4478:       Register_VC_Entity (E);
  4479:
  4480:       Generate_VCs_For_Subprogram (E, Th, Def_Name);
  4481:
  4482:       Close_Theory (Th, Kind => VC_Generation_Theory, Defined_Entity => E);
  4483:    end Generate_VCs_For_Subprogram;
```

## src/why/gnat2why-subprograms.adb:5840-5872

```ada
  5840:       elsif Entity_Body_In_SPARK (E) then
  5841:          declare
  5842:             Body_N       : constant Node_Id := Get_Body (E);
  5843:             Exceptions   : constant Boolean := Has_Exceptional_Contract (E);
  5844:             Program_Exit : constant Boolean := Has_Program_Exit (E);
  5845:             Num_Handlers : constant Natural :=
  5846:               (if Exceptions then 1 else 0) + (if Program_Exit then 1 else 0);
  5847:             Handlers     : W_Handler_Array (1 .. Num_Handlers);
  5848:             Curr_Handler : Natural := 0;
  5849:
  5850:          begin
  5851:             Get_Pre_Post_Pragmas (Declarations (Body_N));
  5852:
  5853:             Why_Body :=
  5854:               Sequence
  5855:                 ((1 =>
  5856:                     Transform_All_Pragmas
  5857:                       (Pre_Prags, "checking of pragma precondition"),
  5858:                   2 => Check_Ceiling_Protocol (Body_Params, E),
  5859:                   3 =>
  5860:                     Transform_Declarations
  5861:                       (Declarations (Body_N), Body_Params),
  5862:                   4 =>
  5863:                     Transform_Handled_Statements
  5864:                       (Handled_Statement_Sequence (Body_N), Body_Params),
  5865:                   5 =>
  5866:                     New_Raise
  5867:                       (Ada_Node => Body_N, Name => M_Main.Return_Exc)));
  5868:
  5869:             --  Enclose the subprogram body in a try-block, so that return
  5870:             --  statements can be translated as raising exceptions.
  5871:
  5872:             Why_Body := Try_Block (Why_Body);
```

## src/why/gnat2why-subprograms.adb:6220-6260

```ada
  6220:               --  or if warnings are suppressed.
  6221:               or else Opt.Warning_Mode = Opt.Suppress
  6222:             then +Void
  6223:             else Warn_On_Inconsistent_Post);
  6224:
  6225:       begin
  6226:          --  Add declarations for 'Old variables
  6227:
  6228:          Prog := Sequence ((CC_Check, EC_Check, Warn_Post, Why_Body));
  6229:          Prog := Declare_Old_Variables (Prog);
  6230:          Prog := Wrap_Decls_For_CC_Guards (Prog);
  6231:          Prog := Wrap_Decls_For_EC_Guards (Prog);
  6232:          Prog := Insert_Bindings_For_Variants (E, Prog, EW_Prog, Body_Params);
  6233:          Prog := Declare_Termination_Condition (Prog);
  6234:
  6235:          Prog :=
  6236:            Sequence
  6237:              ((Assume_For_Input,
  6238:                Assume_For_Output,
  6239:                RTE_Of_Pre,
  6240:                Warn_Pre,
  6241:                Assume_Or_Assert_Of_Pre,
  6242:                Prog));
  6243:       end;
  6244:
  6245:       --  Assume values of constants
  6246:
  6247:       Assume_Value_Of_Constants (Prog, E, Contract_VC_Params);
  6248:
  6249:       --  Declare the toplevel exceptions for exit paths
  6250:
  6251:       Declare_Exceptions (Th);
  6252:
  6253:       Emit
  6254:         (Th,
  6255:          Why.Gen.Binders.New_Function_Decl
  6256:            (Domain   => EW_Prog,
  6257:             Name     => Prog_Name,
  6258:             Binders  => (1 => Unit_Param),
  6259:             Labels   => Symbol_Sets.Empty_Set,
  6260:             Location => Safe_First_Sloc (E),
```

## src/why/gnat2why-types.adb:201-575

```ada
   201:       end Complete_Initialization_Predicate;
   202:
   203:       -------------------------------------
   204:       -- Create_Axioms_For_Scalar_Bounds --
   205:       -------------------------------------
   206:
   207:       procedure Create_Axioms_For_Scalar_Bounds
   208:         (Th : Theory_UC; E : Type_Kind_Id)
   209:       is
   210:          procedure Create_Axiom_For_Expr
   211:            (Name : W_Identifier_Id; Bnd : Node_Id; Typ : W_Type_Id)
   212:          with Pre => Nkind (Bnd) in N_Subexpr;
   213:          --  Create a defining axiom for a logic function which can be used
   214:          --  instead of E.
   215:
   216:          ---------------------------
   217:          -- Create_Axiom_For_Expr --
   218:          ---------------------------
   219:
   220:          procedure Create_Axiom_For_Expr
   221:            (Name : W_Identifier_Id; Bnd : Node_Id; Typ : W_Type_Id)
   222:          is
   223:             Items : Item_Array := Get_Binders_From_Expression (Bnd);
   224:             Def   : W_Term_Id;
   225:
   226:          begin
   227:             --  Use local names for variables
   228:
   229:             Localize_Binders (Items, Only_Variables => False);
   230:
   231:             --  Push the names to Symbol_Table
   232:
   233:             Ada_Ent_To_Why.Push_Scope (Symbol_Table);
   234:             Push_Binders_To_Symbol_Table (Items);
   235:
   236:             Def :=
   237:               +Transform_Expr
   238:                  (Expr          => Bnd,
   239:                   Expected_Type => Typ,
   240:                   Domain        => EW_Term,
   241:                   Params        => Logic_Params);
   242:
   243:             Emit
   244:               (Th,
   245:                New_Defining_Axiom
   246:                  (Name    => Name,
   247:                   Def     => +Def,
   248:                   Binders => To_Binder_Array (Items)));
   249:
   250:             Ada_Ent_To_Why.Pop_Scope (Symbol_Table);
   251:          end Create_Axiom_For_Expr;
   252:
   253:          Rng  : constant Node_Id := Get_Range (E);
   254:          Low  : constant Node_Id := Low_Bound (Rng);
   255:          High : constant Node_Id := High_Bound (Rng);
   256:
   257:          --  Start of processing for Create_Axioms_For_Scalar_Bounds
   258:
   259:       begin
   260:          if not Compile_Time_Known_Value (Low) then
   261:             Create_Axiom_For_Expr
   262:               (Name => E_Symb (E, WNE_Attr_First),
   263:                Bnd  => Low,
   264:                Typ  => Base_Why_Type (E));
   265:          end if;
   266:          if not Compile_Time_Known_Value (High) then
   267:             Create_Axiom_For_Expr
   268:               (Name => E_Symb (E, WNE_Attr_Last),
   269:                Bnd  => High,
   270:                Typ  => Base_Why_Type (E));
   271:          end if;
   272:       end Create_Axioms_For_Scalar_Bounds;
   273:
   274:       ------------------------------------
   275:       -- Create_Default_Init_Assumption --
   276:       ------------------------------------
   277:
   278:       procedure Create_Default_Init_Assumption
   279:         (Th : Theory_UC; E : Type_Kind_Id)
   280:       is
   281:          Variables : Flow_Id_Sets.Set;
   282:
   283:       begin
   284:          --  Get the set of variables used in E's default initialization
   285:
   286:          Variables_In_Default_Init (E, Variables);
   287:
   288:          declare
   289:             Items : constant Item_Array :=
   290:               Get_Localized_Binders_From_Variables
   291:                 (Variables, Only_Variables => False);
   292:             --  Use local names for variables
   293:
   294:             Main_Arg : constant W_Identifier_Id :=
   295:               New_Temp_Identifier
   296:                 (Typ => Type_Of_Node (E), Base_Name => "expr");
   297:             --  Expression on which we want to assume the property
   298:
   299:             Slst_Arg : constant W_Identifier_Id :=
   300:               New_Temp_Identifier
   301:                 (Typ => EW_Bool_Type, Base_Name => "skip_top_level");
   302:             --  Only assume initial condition for the components
   303:
   304:             Def : W_Pred_Id;
   305:
   306:          begin
   307:             --  Push variable names to Symbol_Table
   308:
   309:             Ada_Ent_To_Why.Push_Scope (Symbol_Table);
   310:             Push_Binders_To_Symbol_Table (Items);
   311:
   312:             Def :=
   313:               Compute_Default_Init
   314:                 (Expr           => +Main_Arg,
   315:                  Ty             => E,
   316:                  Skip_Last_Cond => +Slst_Arg,
   317:                  Params         => Logic_Params,
   318:                  Use_Pred       => False);
   319:
   320:             Emit
   321:               (Th,
   322:                New_Function_Decl
   323:                  (Domain   => EW_Pred,
   324:                   Name     => To_Local (E_Symb (E, WNE_Default_Init)),
   325:                   Def      => +Def,
   326:                   Labels   => Symbol_Sets.Empty_Set,
   327:                   Location => No_Location,
   328:                   Binders  =>
   329:                     Binder_Array'
   330:                       (1 => Binder_Type'(B_Name => Main_Arg, others => <>),
   331:                        2 => Binder_Type'(B_Name => Slst_Arg, others => <>))
   332:                     & To_Binder_Array (Items)));
   333:
   334:             Ada_Ent_To_Why.Pop_Scope (Symbol_Table);
   335:          end;
   336:       end Create_Default_Init_Assumption;
   337:
   338:       ------------------------------
   339:       -- Create_Dynamic_Invariant --
   340:       ------------------------------
   341:
   342:       procedure Create_Dynamic_Invariant
   343:         (Th : Theory_UC; E : Type_Kind_Id; Module : W_Module_Id)
   344:       is
   345:          procedure Create_Dynamic_Invariant
   346:            (E            : Type_Kind_Id;
   347:             Name         : W_Identifier_Id;
   348:             Relaxed_Init : Boolean;
   349:             For_Acc      : Boolean);
   350:          --  Emit a declaration for the predicate symbol Name and define it to
   351:          --  be the dynamic invariant for E. If For_Acc is true, split the
   352:          --  definition into a declaration and a separate axiom to handle
   353:          --  circularity.
   354:
   355:          package Decl_Lists is new
   356:            Ada.Containers.Doubly_Linked_Lists (W_Declaration_Id);
   357:
   358:          Loc_Incompl_Acc : Ada_To_Why_Ident.Map;
   359:          --  Map of all local symbols introduced for predicates of access to
   360:          --  incomplete access types.
   361:
   362:          Loc_Incompl_Acc_R : Ada_To_Why_Ident.Map;
   363:          --  Same as above but for init wrappers
   364:
   365:          Axioms : Decl_Lists.List;
   366:          --  Axioms for predicates of access to incomplete access types
   367:
   368:          ------------------------------
   369:          -- Create_Dynamic_Invariant --
   370:          ------------------------------
   371:
   372:          procedure Create_Dynamic_Invariant
   373:            (E            : Type_Kind_Id;
   374:             Name         : W_Identifier_Id;
   375:             Relaxed_Init : Boolean;
   376:             For_Acc      : Boolean)
   377:          is
   378:             Variables : Flow_Id_Sets.Set;
   379:
   380:          begin
   381:             --  Get the set of variables used in E's dynamic property. Locally
   382:             --  assumed predicates are not included.
   383:
   384:             Variables_In_Dynamic_Invariant (E, Variables, Scop => Empty);
   385:
   386:             declare
   387:                Items : constant Item_Array :=
   388:                  Get_Localized_Binders_From_Variables
   389:                    (Variables, Only_Variables => False);
   390:                --  Use local names for variables
   391:
   392:                Init_Arg : constant W_Identifier_Id :=
   393:                  New_Temp_Identifier
   394:                    (Typ => EW_Bool_Type, Base_Name => "is_init");
   395:                --  Is the object known to be initialized
   396:
   397:                Ovar_Arg : constant W_Identifier_Id :=
   398:                  New_Temp_Identifier
   399:                    (Typ => EW_Bool_Type, Base_Name => "skip_constant");
   400:                --  Do we need to assume the properties on constant parts
   401:
   402:                Top_Arg : constant W_Identifier_Id :=
   403:                  New_Temp_Identifier
   404:                    (Typ => EW_Bool_Type, Base_Name => "do_toplevel");
   405:                --  Should we include the toplevel predicate
   406:
   407:                Inv_Arg : constant W_Identifier_Id :=
   408:                  New_Temp_Identifier
   409:                    (Typ => EW_Bool_Type, Base_Name => "do_typ_inv");
   410:                --  Should we include the non local type invariants
   411:
   412:                Main_Ty : constant W_Type_Id :=
   413:                  (if Relaxed_Init
   414:                   then EW_Abstract (E, Relaxed_Init => True)
   415:                   else Type_Of_Node (E));
   416:
   417:                Main_Arg : constant W_Identifier_Id :=
   418:                  New_Temp_Identifier (Typ => Main_Ty, Base_Name => "expr");
   419:                --  Expression on which we want to assume the property
   420:
   421:                Def               : W_Pred_Id;
   422:                New_Incompl_Acc   : Ada_To_Why_Ident.Map;
   423:                New_Incompl_Acc_R : Ada_To_Why_Ident.Map;
   424:
   425:             begin
   426:                --  Push variable names to Symbol_Table
   427:
   428:                Ada_Ent_To_Why.Push_Scope (Symbol_Table);
   429:                Push_Binders_To_Symbol_Table (Items);
   430:
   431:                --  Compute the predicate for E. Do not include any locally
   432:                --  assumed predicate, they will be added separately depending
   433:                --  on the scope when the dynamic invariant is used. Do not
   434:                --  handle validity flags. The dynamic invariant is expanded
   435:                --  if one is provided.
   436:
   437:                Compute_Dynamic_Invariant
   438:                  (Expr              => +Main_Arg,
   439:                   Ty                => E,
   440:                   Initialized       => +Init_Arg,
   441:                   Only_Var          => +Ovar_Arg,
   442:                   Top_Predicate     => +Top_Arg,
   443:                   All_Global_Inv    => +Inv_Arg,
   444:                   Valid             => Why_Empty,
   445:                   Inv_Scop          => Empty,
   446:                   Inv_Subp          => Empty,
   447:                   Params            => Logic_Params,
   448:                   Use_Pred          => False,
   449:                   New_Preds_Module  => Module,
   450:                   T                 => Def,
   451:                   Loc_Incompl_Acc   => Loc_Incompl_Acc,
   452:                   New_Incompl_Acc   => New_Incompl_Acc,
   453:                   Loc_Incompl_Acc_R => Loc_Incompl_Acc_R,
   454:                   New_Incompl_Acc_R => New_Incompl_Acc_R,
   455:                   Expand_Incompl    => False);
   456:
   457:                --  Copy new predicate symbols to the map of local symbols
   458:
   459:                for C in New_Incompl_Acc.Iterate loop
   460:                   Loc_Incompl_Acc.Insert
   461:                     (Ada_To_Why_Ident.Key (C), Ada_To_Why_Ident.Element (C));
   462:                end loop;
   463:
   464:                for C in New_Incompl_Acc_R.Iterate loop
   465:                   Loc_Incompl_Acc_R.Insert
   466:                     (Ada_To_Why_Ident.Key (C), Ada_To_Why_Ident.Element (C));
   467:                end loop;
   468:
   469:                --  Introduce function symbols (with no definitions) for
   470:                --  new predicate symbols. Store their axioms in Axioms.
   471:
   472:                for C in New_Incompl_Acc.Iterate loop
   473:                   Create_Dynamic_Invariant
   474:                     (E            => Ada_To_Why_Ident.Key (C),
   475:                      Name         => Ada_To_Why_Ident.Element (C),
   476:                      Relaxed_Init => False,
   477:                      For_Acc      => True);
   478:                end loop;
   479:
   480:                for C in New_Incompl_Acc_R.Iterate loop
   481:                   Create_Dynamic_Invariant
   482:                     (E            => Ada_To_Why_Ident.Key (C),
   483:                      Name         => Ada_To_Why_Ident.Element (C),
   484:                      Relaxed_Init => True,
   485:                      For_Acc      => True);
   486:                end loop;
   487:
   488:                declare
   489:                   Binders : constant Binder_Array :=
   490:                     Binder_Array'
   491:                       (1 => Binder_Type'(B_Name => Main_Arg, others => <>),
   492:                        2 => Binder_Type'(B_Name => Init_Arg, others => <>),
   493:                        3 => Binder_Type'(B_Name => Ovar_Arg, others => <>),
   494:                        4 => Binder_Type'(B_Name => Top_Arg, others => <>),
   495:                        5 => Binder_Type'(B_Name => Inv_Arg, others => <>))
   496:                     & To_Binder_Array (Items);
   497:                begin
   498:
   499:                   --  If we are defining a symbol for an access to an
   500:                   --  incomplete type, split the predicate into a declaration
   501:                   --  and a defining axiom to avoid circularity.
   502:
   503:                   if For_Acc then
   504:                      Emit
   505:                        (Th,
   506:                         New_Function_Decl
   507:                           (Domain   => EW_Pred,
   508:                            Name     => Name,
   509:                            Labels   => Symbol_Sets.Empty_Set,
   510:                            Binders  => Binders,
   511:                            Location => No_Location));
   512:                      Axioms.Append
   513:                        (New_Defining_Bool_Axiom
   514:                           (Fun_Name => Get (Get_Symb (Get_Name (Name))).all,
   515:                            Name     => Name,
   516:                            Binders  => Binders,
   517:                            Def      => Def,
   518:                            Dep_Kind => EW_Axdep_Pred));
   519:
   520:                   --  Otherwise, define the symbol at declaration
   521:
   522:                   else
   523:                      Emit
   524:                        (Th,
   525:                         New_Function_Decl
   526:                           (Domain   => EW_Pred,
   527:                            Name     => Name,
   528:                            Def      => +Def,
   529:                            Location => No_Location,
   530:                            Labels   => Symbol_Sets.Empty_Set,
   531:                            Binders  => Binders));
   532:                   end if;
   533:                end;
   534:
   535:                Ada_Ent_To_Why.Pop_Scope (Symbol_Table);
   536:             end;
   537:          end Create_Dynamic_Invariant;
   538:
   539:          --  Start of processing for Create_Dynamic_Invariant
   540:
   541:       begin
   542:          Create_Dynamic_Invariant
   543:            (E            => E,
   544:             Name         => To_Local (E_Symb (E, WNE_Dynamic_Invariant)),
   545:             Relaxed_Init => False,
   546:             For_Acc      => False);
   547:
   548:          if Has_Init_Wrapper (E) then
   549:             Create_Dynamic_Invariant
   550:               (E            => E,
   551:                Name         =>
   552:                  To_Local
   553:                    (E_Symb (E, WNE_Dynamic_Invariant, Relaxed_Init => True)),
   554:                Relaxed_Init => True,
   555:                For_Acc      => False);
   556:          end if;
   557:
   558:          --  Emit axioms for local predicate symbols
   559:
   560:          for Ax of Axioms loop
   561:             Emit (Th, Ax);
   562:          end loop;
   563:       end Create_Dynamic_Invariant;
   564:
   565:       ---------------------------
   566:       -- Create_Type_Invariant --
   567:       ---------------------------
   568:
   569:       procedure Create_Type_Invariant (Th : Theory_UC; E : Type_Kind_Id) is
   570:          Variables : Flow_Id_Sets.Set;
   571:
   572:       begin
   573:          --  Get the set of variables used in E's predicate
   574:
   575:          Variables_In_Type_Invariant (E, Variables);
```

## src/why/gnat2why-types.adb:895-1101

```ada
   895:       --  Start of processing for Generate_Type_Completion
   896:
   897:    begin
   898:       Th :=
   899:         Open_Theory
   900:           (WF_Context,
   901:            E_Module (E, Axiom),
   902:            Comment =>
   903:              "Module giving axioms for type "
   904:              & """"
   905:              & Get_Name_String (Chars (E))
   906:              & """"
   907:              & (if Sloc (E) > 0
   908:                 then " defined at " & Build_Location_String (Sloc (E))
   909:                 else "")
   910:              & ", created in "
   911:              & GNAT.Source_Info.Enclosing_Entity);
   912:
   913:       if Is_Access_Subprogram_Type (E) then
   914:
   915:          --  Generate program function for E
   916:
   917:          Complete_Access_To_Subprogram_Type (Th, E);
   918:
   919:       elsif Is_Tagged_Type (E) then
   920:
   921:          --  If E is a root of a tagged hierarchy, generate axioms for the
   922:          --  compatibility of the concrete tags of its visible descendants.
   923:
   924:          if E = Root_Retysp (E) and then not Is_Concurrent_Type (E) then
   925:             Create_Compatible_Tags_Theory (E);
   926:          end if;
   927:
   928:          Complete_Tagged_Record_Type (Th, E);
   929:       end if;
   930:
   931:       --  Generate a predicate for E's dynamic property. For provability, it is
   932:       --  inlined by Why3.
   933:       --  We do not generate the dynamic property for Itypes as they may
   934:       --  depend on locally defined constants such as 'Old.
   935:
   936:       if not Is_Itype (E)
   937:         and then not Is_Standard_Boolean_Type (E)
   938:         and then E /= Universal_Fixed
   939:       then
   940:          Create_Dynamic_Invariant (Th, E, E_Module (E, Axiom));
   941:       end if;
   942:
   943:       --  If E is a scalar type with dynamic bounds, we give axioms for the
   944:       --  values of its bounds.
   945:
   946:       if not Is_Itype (E) and then Is_Scalar_Type (E) then
   947:          Create_Axioms_For_Scalar_Bounds (Th, E);
   948:       end if;
   949:
   950:       if Has_Init_Wrapper (E)
   951:         and then not Is_Scalar_Type (E)
   952:         and then not Is_Itype (E)
   953:       then
   954:          if Has_Predeclared_Init_Predicate (E) then
   955:             Complete_Initialization_Predicate (Th, E);
   956:          else
   957:             Create_Initialization_Predicate (Th, E);
   958:          end if;
   959:       end if;
   960:
   961:       Close_Theory (Th, Kind => Axiom_Theory, Defined_Entity => E);
   962:
   963:       --  Generate a predicate for E's default initialization.
   964:       --  We do not generate default initialization for unconstrained types.
   965:
   966:       if not Is_Itype (E) and then Can_Be_Default_Initialized (E) then
   967:          Th :=
   968:            Open_Theory
   969:              (WF_Context,
   970:               E_Module (E, Default_Initialialization),
   971:               Comment =>
   972:                 "Module giving a predicate for the default initial assumption"
   973:                 & " of type """
   974:                 & Get_Name_String (Chars (E))
   975:                 & """"
   976:                 & (if Sloc (E) > 0
   977:                    then " defined at " & Build_Location_String (Sloc (E))
   978:                    else "")
   979:                 & ", created in "
   980:                 & GNAT.Source_Info.Enclosing_Entity);
   981:          Create_Default_Init_Assumption (Th, E);
   982:          Close_Theory (Th, Kind => Definition_Theory);
   983:       end if;
   984:
   985:       if Has_Invariants_In_SPARK (E) then
   986:          Th :=
   987:            Open_Theory
   988:              (WF_Context,
   989:               E_Module (E, Invariant),
   990:               Comment =>
   991:                 "Module giving a predicate for the type invariant of"
   992:                 & " type """
   993:                 & Get_Name_String (Chars (E))
   994:                 & """"
   995:                 & (if Sloc (E) > 0
   996:                    then " defined at " & Build_Location_String (Sloc (E))
   997:                    else "")
   998:                 & ", created in "
   999:                 & GNAT.Source_Info.Enclosing_Entity);
  1000:          Create_Type_Invariant (Th, E);
  1001:          Close_Theory (Th, Kind => Definition_Theory);
  1002:       end if;
  1003:
  1004:       --  For types which need reclamation, generate a move tree theory.
  1005:
  1006:       if Contains_Allocated_Parts (E) then
  1007:          Th :=
  1008:            Open_Theory
  1009:              (WF_Context,
  1010:               E_Module (E, Move_Tree),
  1011:               Comment =>
  1012:                 "Module for move trees for objects of type "
  1013:                 & """"
  1014:                 & Get_Name_String (Chars (E))
  1015:                 & """"
  1016:                 & (if Sloc (E) > 0
  1017:                    then " defined at " & Build_Location_String (Sloc (E))
  1018:                    else "")
  1019:                 & ", created in "
  1020:                 & GNAT.Source_Info.Enclosing_Entity);
  1021:
  1022:          if Is_Record_Type_In_Why (E) then
  1023:             Create_Move_Tree_Theory_For_Record (Th, E);
  1024:          elsif Has_Array_Type (E) then
  1025:             Create_Move_Tree_Theory_For_Array (Th, E);
  1026:
  1027:          --  No need to generate move tree theories for anonymous access types
  1028:          --  as objects of these types do not need to be reclaimed themselves.
  1029:          --  The tree of their designated type will be used instead if it
  1030:          --  contains allocated parts.
  1031:
  1032:          elsif not Is_Anonymous_Access_Type (E) then
  1033:             pragma Assert (Has_Access_Type (E));
  1034:             Create_Move_Tree_Theory_For_Pointer (Th, E);
  1035:          end if;
  1036:
  1037:          --  After generating the move tree theory of an incomplete
  1038:          --  type, complete its early declarations.
  1039:
  1040:          if Has_Incomplete_Access (E) then
  1041:             Complete_Move_Tree_For_Incomplete_Access (Th, E);
  1042:          end if;
  1043:
  1044:          --  Create a __moved_tree function returning a moved tree. Generate:
  1045:          --
  1046:          --    val moved_tree (obj : ty) : move_tree
  1047:          --      ensures { is_moved_or_reclaimed result obj }
  1048:
  1049:          if not Is_Anonymous_Access_Type (E)
  1050:            and then
  1051:              (not Is_Record_Type_In_Why (E)
  1052:               or else not Record_Type_Is_Clone (E))
  1053:          then
  1054:             declare
  1055:                Typ           : constant W_Type_Id :=
  1056:                  (if Has_Init_Wrapper (E)
  1057:                   then EW_Init_Wrapper (Type_Of_Node (E))
  1058:                   else Type_Of_Node (E));
  1059:                Obj_Binder    : constant Binder_Type :=
  1060:                  (B_Name => New_Identifier (Name => "obj", Typ => Typ),
  1061:                   others => <>);
  1062:                Moved_Tree_Id : constant W_Identifier_Id :=
  1063:                  New_Identifier
  1064:                    (Domain => EW_Term, --  factor out
  1065:                     Symb   => NID (To_String (WNE_Moved_Tree)),
  1066:                     Typ    => New_Named_Type (To_Name (WNE_Move_Tree)));
  1067:
  1068:             begin
  1069:                Emit
  1070:                  (Th,
  1071:                   New_Function_Decl
  1072:                     (Domain      => EW_Prog,
  1073:                      Name        => Moved_Tree_Id,
  1074:                      Binders     => Binder_Array'(1 => Obj_Binder),
  1075:                      Location    => No_Location,
  1076:                      Labels      => Symbol_Sets.Empty_Set,
  1077:                      Return_Type => Get_Typ (Moved_Tree_Id),
  1078:                      Post        =>
  1079:                        New_Call
  1080:                          (Name =>
  1081:                             To_Local (E_Symb (E, WNE_Is_Moved_Or_Reclaimed)),
  1082:                           Args =>
  1083:                             (1 => +New_Result_Ident (Get_Typ (Moved_Tree_Id)),
  1084:                              2 => +Obj_Binder.B_Name))));
  1085:             end;
  1086:          end if;
  1087:
  1088:          Close_Theory (Th, Kind => Definition_Theory);
  1089:
  1090:          if Has_Incomplete_Access (E) then
  1091:             Record_Extra_Dependency
  1092:               (Defining_Module => E_Module (E, Incomp_Move_Tree),
  1093:                Axiom_Module    => Th.Module);
  1094:          end if;
  1095:       end if;
  1096:
  1097:       if (Is_Tagged_Type (E) and then E = Root_Retysp (E))
  1098:         or else not Use_Predefined_Equality_For_Type (E)
  1099:       then
  1100:          Generate_Axioms_For_Equality (E);
  1101:       end if;
```

## src/why/gnat2why-types.adb:1108-1155

```ada
  1108:    procedure Generate_VCs_For_Type (E : Type_Kind_Id) is
  1109:       Priv_View       : constant Opt_Type_Kind_Id :=
  1110:         Find_View_For_Default_Checks (E);
  1111:       Check_Default   : constant Boolean := Present (Priv_View);
  1112:       Check_Subp      : constant Boolean :=
  1113:         Is_Access_Subprogram_Type (E) and then No (Parent_Retysp (E));
  1114:       Check_Iter      : constant Boolean := Declares_Iterable_Aspect (E);
  1115:       Check_Eq        : constant Boolean :=
  1116:         Is_Base_Type (E) and then not Use_Predefined_Equality_For_Type (E);
  1117:       Check_Aggr      : constant Boolean :=
  1118:         Needs_Check_For_Aggregate_Annotation (E);
  1119:       Check_Ownership : constant Boolean := Needs_Ownership_Check (E);
  1120:       Need_Check      : constant Boolean :=
  1121:         Check_Default
  1122:         or else Check_Iter
  1123:         or else Check_Subp
  1124:         or else Check_Eq
  1125:         or else Check_Aggr
  1126:         or else Check_Ownership;
  1127:       Name            : constant String := Full_Name (E);
  1128:       S_Ty            : constant Entity_Id :=
  1129:         (if Present (First_Subtype (E))
  1130:            and then Entity_In_SPARK (First_Subtype (E))
  1131:          then First_Subtype (E)
  1132:          else E);
  1133:       --  Use the first subtype if any, as it can be more
  1134:       --  constrained than the base type introduced by the
  1135:       --  compiler.
  1136:       Params          : constant Transformation_Params := Body_Params;
  1137:       Why_Body        : W_Prog_Id := +Void;
  1138:       Th              : Theory_UC;
  1139:    begin
  1140:       if not Need_Check then
  1141:          return;
  1142:       end if;
  1143:
  1144:       Th :=
  1145:         Open_Theory
  1146:           (WF_Main,
  1147:            New_Module (Name => Name & "__default_checks", File => No_Symbol),
  1148:            Comment =>
  1149:              "Module for checking DIC of default value and"
  1150:              & " absence of runtime errors in the private part of "
  1151:              & """"
  1152:              & Get_Name_String (Chars (E))
  1153:              & """"
  1154:              & (if Sloc (E) > 0
  1155:                 then " defined at " & Build_Location_String (Sloc (E))
```

## src/why/gnat2why-types.adb:1416-1423

```ada
  1416:    function Ident_Of_Ada_Type (E : Type_Kind_Id) return W_Name_Id is
  1417:    begin
  1418:       return
  1419:         (if Is_Standard_Boolean_Type (E)
  1420:          then Get_Name (EW_Bool_Type)
  1421:          else To_Why_Type (E));
  1422:    end Ident_Of_Ada_Type;
  1423:
```

## src/why/gnat2why-types.adb:1538-1739

```ada
  1538:       procedure Generate_Ref_Type_And_Havoc_Fun
  1539:         (Th : Theory_UC; E : Entity_Id; Relaxed_Init : Boolean) is
  1540:       begin
  1541:          --  We do not generate these declarations for array or record types
  1542:          --  which are clones of existing types with the same name and
  1543:          --  statically constrained array type as no new type is declared for
  1544:          --  them.
  1545:          --  Classwide types are a special case as they are clones of their
  1546:          --  specific types but do not have the same short name.
  1547:
  1548:          if (not (Has_Record_Type (E)
  1549:                   or else Has_Incomplete_Or_Private_Type (E))
  1550:              or else not Record_Type_Is_Clone (Retysp (E))
  1551:              or else
  1552:                Short_Name (Retysp (E))
  1553:                /= Short_Name (Record_Type_Cloned_Subtype (Retysp (E))))
  1554:            and then not Is_Class_Wide_Type (Retysp (E))
  1555:            and then
  1556:              (not Has_Array_Type (E)
  1557:               or else not Is_Static_Array_Type (Retysp (E)))
  1558:            and then
  1559:              (not Has_Array_Type (E)
  1560:               or else not Array_Type_Is_Clone (Retysp (E))
  1561:               or else
  1562:                 Short_Name (Retysp (E))
  1563:                 /= Short_Name (Array_Type_Cloned_Subtype (Retysp (E))))
  1564:          then
  1565:             Emit_Ref_Type_Definition
  1566:               (Th,
  1567:                To_Why_Type
  1568:                  (Retysp (E), Local => True, Relaxed_Init => Relaxed_Init));
  1569:             Emit
  1570:               (Th,
  1571:                New_Havoc_Declaration
  1572:                  (Name =>
  1573:                     To_Why_Type
  1574:                       (Retysp (E),
  1575:                        Local        => True,
  1576:                        Relaxed_Init => Relaxed_Init)));
  1577:          end if;
  1578:       end Generate_Ref_Type_And_Havoc_Fun;
  1579:
  1580:       -------------------------------
  1581:       -- Translate_Underlying_Type --
  1582:       -------------------------------
  1583:
  1584:       procedure Translate_Underlying_Type (Th : Theory_UC; E : Entity_Id) is
  1585:       begin
  1586:          case Ekind (E) is
  1587:             when Scalar_Kind                                        =>
  1588:                Declare_Scalar_Type (Th, E);
  1589:
  1590:             when Array_Kind                                         =>
  1591:                Declare_Ada_Array (Th, E);
  1592:
  1593:             when E_Record_Type | E_Record_Subtype | Concurrent_Kind =>
  1594:                Declare_Ada_Record (Th, E);
  1595:
  1596:             when Class_Wide_Kind                                    =>
  1597:                Add_Use_For_Entity
  1598:                  (Th,
  1599:                   Specific_Tagged (E),
  1600:                   EW_Export,
  1601:                   With_Completion => False);
  1602:
  1603:             when Incomplete_Or_Private_Kind                         =>
  1604:                pragma Assert (Full_View_Not_In_SPARK (E));
  1605:                Declare_Ada_Record (Th, E);
  1606:
  1607:             when Access_Kind                                        =>
  1608:                if Is_Access_Subprogram_Type (E) then
  1609:                   Declare_Access_To_Subprogram_Type (Th, E);
  1610:                else
  1611:                   Declare_Ada_Pointer (Th, E);
  1612:                end if;
  1613:
  1614:             when others                                             =>
  1615:                Ada.Text_IO.Put_Line
  1616:                  ("[Translate_Underlying_Type] ekind ="
  1617:                   & Entity_Kind'Image (Ekind (E)));
  1618:                raise Not_Implemented;
  1619:          end case;
  1620:       end Translate_Underlying_Type;
  1621:
  1622:       Th : Theory_UC;
  1623:
  1624:       --  Start of processing for Translate_Type
  1625:
  1626:    begin
  1627:       if Is_Standard_Boolean_Type (E) or else E = Universal_Fixed then
  1628:          return;
  1629:
  1630:       else
  1631:          if Has_Array_Type (E) then
  1632:             Create_Rep_Array_Theory_If_Needed (E);
  1633:          elsif Retysp_Kind (E)
  1634:                in Incomplete_Or_Private_Kind
  1635:                 | E_Record_Type
  1636:                 | E_Record_Subtype
  1637:                 | Concurrent_Kind
  1638:          then
  1639:             Create_Rep_Record_Theory_If_Needed (Retysp (E));
  1640:          elsif Is_Access_Subprogram_Type (Retysp (E)) then
  1641:
  1642:             --  Declare __call function for the designated profile if
  1643:             --  needed.
  1644:
  1645:             Create_Theory_For_Profile_If_Needed (Retysp (E));
  1646:          elsif Has_Access_Type (E) then
  1647:             Create_Rep_Pointer_Theory_If_Needed (Retysp (E));
  1648:          end if;
  1649:
  1650:          Th :=
  1651:            Open_Theory
  1652:              (WF_Context,
  1653:               E_Module (E),
  1654:               Comment =>
  1655:                 "Module for axiomatizing type "
  1656:                 & """"
  1657:                 & Get_Name_String (Chars (E))
  1658:                 & """"
  1659:                 & (if Sloc (E) > 0
  1660:                    then " defined at " & Build_Location_String (Sloc (E))
  1661:                    else "")
  1662:                 & ", created in "
  1663:                 & GNAT.Source_Info.Enclosing_Entity);
  1664:
  1665:          Translate_Underlying_Type (Th, Retysp (E));
  1666:
  1667:          --  We declare a default value for all types, in principle.
  1668:          --  Cloned subtypes are a special case, they do not need such a
  1669:          --  definition.
  1670:
  1671:          if (Has_Record_Type (E) or else Has_Incomplete_Or_Private_Type (E))
  1672:            and then not Record_Type_Is_Clone (Retysp (E))
  1673:          then
  1674:             Emit
  1675:               (Th,
  1676:                Why.Atree.Builders.New_Function_Decl
  1677:                  (Domain      => EW_Pterm,
  1678:                   Name        => To_Local (E_Symb (E, WNE_Dummy)),
  1679:                   Binders     => (1 .. 0 => <>),
  1680:                   Labels      => Symbol_Sets.Empty_Set,
  1681:                   Location    => No_Location,
  1682:                   Return_Type =>
  1683:                     +New_Named_Type (Name => To_Why_Type (E, Local => True))));
  1684:          end if;
  1685:
  1686:          Generate_Ref_Type_And_Havoc_Fun (Th, E, Relaxed_Init => False);
  1687:
  1688:          --  If E is the full view of a private type, use its partial view as
  1689:          --  the filtering entity, as it is the entity used everywhere in AST.
  1690:
  1691:          Close_Theory
  1692:            (Th,
  1693:             Kind           => Definition_Theory,
  1694:             Defined_Entity =>
  1695:               (if Is_Full_View (E) then Partial_View (E) else E));
  1696:
  1697:          --  For scalar types that are not modeled using their base types
  1698:          --  declare a Module where the functions to_rep/of_rep are defined.
  1699:          --  This let us separate the different axioms (inversion/range/coerce)
  1700:          --  to try and minimalize quantified axioms in the VCs' context.
  1701:
  1702:          if Is_Scalar_Type (E) and then not Type_Is_Modeled_As_Base (E) then
  1703:             Th :=
  1704:               Open_Theory
  1705:                 (WF_Context,
  1706:                  E_Module (E, Type_Representative),
  1707:                  Comment =>
  1708:                    "Module defining to_rep/of_rep for type "
  1709:                    & """"
  1710:                    & Get_Name_String (Chars (E))
  1711:                    & """"
  1712:                    & (if SPARK_Atree.Sloc (E) > 0
  1713:                       then " defined at " & Build_Location_String (Sloc (E))
  1714:                       else "")
  1715:                    & ", created in "
  1716:                    & GNAT.Source_Info.Enclosing_Entity);
  1717:
  1718:             Define_Scalar_Rep_Proj (Th, E);
  1719:
  1720:             Close_Theory (Th, Kind => Standalone_Theory);
  1721:          end if;
  1722:
  1723:          --  Declare to_string and of_string functions used for 'Image and
  1724:          --  'Value attributes.
  1725:
  1726:          if E = Standard_String then
  1727:             Th :=
  1728:               Open_Theory
  1729:                 (WF_Context,
  1730:                  String_Image_Module,
  1731:                  Comment =>
  1732:                    "Module defining to_string/of_string functions"
  1733:                    & ", created in "
  1734:                    & GNAT.Source_Info.Enclosing_Entity);
  1735:
  1736:             Declare_Additional_Symbols_For_String (Th);
  1737:
  1738:             Close_Theory (Th, Kind => Standalone_Theory);
  1739:          end if;
```

## src/why/gnat2why-util.adb:503-540

```ada
   503:    function Build_Printing_Plan return Why_Node_Lists.List is
   504:       Seen : Symbol_Set;
   505:       Plan : Why_Node_Lists.List;
   506:
   507:       procedure Recurse (Th : W_Theory_Declaration_Id);
   508:
   509:       -------------
   510:       -- Recurse --
   511:       -------------
   512:
   513:       procedure Recurse (Th : W_Theory_Declaration_Id) is
   514:          N : constant Symbol := Get_Name (Th);
   515:       begin
   516:          if Seen.Contains (N) then
   517:             return;
   518:          end if;
   519:          Seen.Insert (N);
   520:          for Incl of Get_List (+Get_Includes (Th)) loop
   521:             declare
   522:                M : constant W_Module_Id :=
   523:                  Get_Module (W_Include_Declaration_Id (Incl));
   524:             begin
   525:                if Get_File (M) = No_Symbol then
   526:                   Recurse (Find_Decl (Get_Name (M)));
   527:                end if;
   528:             end;
   529:          end loop;
   530:          Plan.Append (+Th);
   531:       end Recurse;
   532:
   533:       --  Start of processing for Build_Printing_Plan
   534:
   535:    begin
   536:       for Th of Why_Sections (WF_Main) loop
   537:          Recurse (+Th);
   538:       end loop;
   539:       return Plan;
   540:    end Build_Printing_Plan;
```

## src/why/gnat2why-util.adb:1126-1201

```ada
  1126:    function Is_Mutable_In_Why (E : Entity_Id) return Boolean is
  1127:    begin
  1128:       --  An object is translated as mutable in Why due to being read/write in
  1129:       --  SPARK/Ada or due to its represententation in Why.
  1130:
  1131:       case Ekind (E) is
  1132:          when E_Loop_Parameter                     =>
  1133:
  1134:             --  A loop parameter of an genuine loop (but not of a quantified
  1135:             --  expression) is mutable.
  1136:
  1137:             return not Is_Quantified_Loop_Param (E);
  1138:
  1139:          when E_Variable                           =>
  1140:
  1141:             --  Same for variables that are Part_Ofs protected objects; they
  1142:             --  are like components for proof.
  1143:
  1144:             return
  1145:               not Is_Quantified_Loop_Param (E)
  1146:               and then not Is_Part_Of_Protected_Object (E);
  1147:
  1148:          when E_Task_Type                          =>
  1149:
  1150:             --  Tasks are modeled as constants
  1151:
  1152:             return False;
  1153:
  1154:          when E_Component | E_Discriminant         =>
  1155:
  1156:             --  A component or discriminant is not separately considered
  1157:             --  as mutable, only the enclosing object is. This ensures that
  1158:             --  components used in the named notation of aggregates are
  1159:             --  not considered as references to mutable variables (e.g.
  1160:             --  in Expression_Depends_On_Variables).
  1161:
  1162:             return False;
  1163:
  1164:          when E_In_Out_Parameter | E_Out_Parameter =>
  1165:
  1166:             --  The first parameter of a borrowing traversal function might be
  1167:             --  an IN OUT parameter.
  1168:
  1169:             return not Is_Constant_In_SPARK (E);
  1170:
  1171:          when E_Protected_Type                     =>
  1172:             return True;
  1173:
  1174:          when E_Constant                           =>
  1175:
  1176:             --  Volatile constants with async writers are mutable
  1177:
  1178:             if Has_Volatile (E)
  1179:               and then Has_Volatile_Property (E, Pragma_Async_Writers)
  1180:             then
  1181:                return True;
  1182:
  1183:             --  Constants defined locally to a loop inside a subprogram (or
  1184:             --  any other dynamic scope) may end up having different values, so
  1185:             --  should be mutable in Why, except when they are defined inside
  1186:             --  "actions" (in which case they are defined as local "let" bound
  1187:             --  variables in Why) or when they have no variable inputs.
  1188:
  1189:             elsif SPARK_Definition.Is_Loop_Entity (E)
  1190:               and then not SPARK_Definition.Is_Actions_Entity (E)
  1191:             then
  1192:                return Flow_Utility.Has_Variable_Input (E);
  1193:
  1194:             --  An owning access type provides a read/write access to its
  1195:             --  designated object.
  1196:
  1197:             else
  1198:                return not Is_Constant_In_SPARK (E);
  1199:             end if;
  1200:
  1201:          when E_In_Parameter                       =>
```

## src/why/gnat2why-util.adb:1347-1454

```ada
  1347:    function Name_For_Loop_Entry
  1348:      (Expr      : Node_Or_Entity_Id;
  1349:       Loop_Id   : E_Loop_Id;
  1350:       No_Checks : Boolean := False) return W_Identifier_Id
  1351:    is
  1352:       Result : W_Identifier_Id;
  1353:
  1354:       procedure Get_Name
  1355:         (Loop_Id : Node_Id; Loop_Map : in out Ada_To_Why_Ident.Map);
  1356:       --  Update the mapping Loop_Map with an entry for Expr if not already
  1357:       --  present, and store the corresponding identifier in Result.
  1358:
  1359:       procedure Get_Name
  1360:         (Loop_Id : Node_Id; Loop_Maps : in out Loop_Entry_Values);
  1361:       --  Same as above but chooses the map to update depending on the value of
  1362:       --  No_Checks.
  1363:
  1364:       --------------
  1365:       -- Get_Name --
  1366:       --------------
  1367:
  1368:       procedure Get_Name
  1369:         (Loop_Id : Node_Id; Loop_Map : in out Ada_To_Why_Ident.Map)
  1370:       is
  1371:          Typ : W_Type_Id;
  1372:          Nd  : Node_Id;
  1373:
  1374:          Pos   : Ada_To_Why_Ident.Cursor := Loop_Map.Find (Expr);
  1375:          Dummy : Boolean;
  1376:
  1377:          use Ada_To_Why_Ident;
  1378:
  1379:          Attrs       : String_Utils.String_Sets.Set :=
  1380:            String_Utils.String_Sets.Empty_Set;
  1381:          Model_Trace : constant String :=
  1382:          --  Here we exclude Loop_Entry expressions and only consider
  1383:          --  Entities
  1384:            (if Nkind (Expr) in N_Has_Entity
  1385:             then
  1386:               "model_trace:"
  1387:               & Trim (Source => Entity (Expr)'Image, Side => Ada.Strings.Left)
  1388:               & "'Loop_Entry"
  1389:             else "");
  1390:
  1391:       begin
  1392:          pragma Unreferenced (Loop_Id);
  1393:
  1394:          if not Has_Element (Pos) then
  1395:
  1396:             if Nkind (Expr) in N_Defining_Identifier then
  1397:                Typ := Why_Type_Of_Entity (Expr);
  1398:                Nd := Expr;
  1399:             elsif Nkind (Expr) in N_Identifier | N_Expanded_Name then
  1400:                Typ := Why_Type_Of_Entity (Entity (Expr));
  1401:                Nd := Entity (Expr);
  1402:             else
  1403:                Typ := Type_Of_Node (Expr);
  1404:                Nd := Types.Empty;
  1405:             end if;
  1406:
  1407:             if Model_Trace /= "" then
  1408:                String_Utils.String_Sets.Insert (Attrs, Model_Trace);
  1409:             end if;
  1410:             Loop_Map.Insert
  1411:               (Key      => Expr,
  1412:                New_Item =>
  1413:                  New_Generated_Identifier
  1414:                    (Typ       => Typ,
  1415:                     Ada_Node  => Nd,
  1416:                     Base_Name => "loop_entry",
  1417:                     Attrs     => Attrs),
  1418:                Position => Pos,
  1419:                Inserted => Dummy);
  1420:          end if;
  1421:
  1422:          Result := Loop_Map (Pos);
  1423:       end Get_Name;
  1424:
  1425:       procedure Get_Name
  1426:         (Loop_Id : Node_Id; Loop_Maps : in out Loop_Entry_Values) is
  1427:       begin
  1428:          if No_Checks then
  1429:             Get_Name (Loop_Id, Loop_Maps.No_Checks);
  1430:          else
  1431:             Get_Name (Loop_Id, Loop_Maps.Regular);
  1432:          end if;
  1433:       end Get_Name;
  1434:
  1435:       Cur   : Loop_Entry_Nodes.Cursor;
  1436:       Dummy : Boolean;
  1437:
  1438:       --  Start of processing for Name_For_Loop_Entry
  1439:
  1440:    begin
  1441:       Loop_Entry_Map.Insert
  1442:         (Key => Loop_Id, Position => Cur, Inserted => Dummy);
  1443:
  1444:       Loop_Entry_Map.Update_Element
  1445:         (Position => Cur, Process => Get_Name'Access);
  1446:
  1447:       return Result;
  1448:    end Name_For_Loop_Entry;
  1449:
  1450:    ------------------
  1451:    -- Name_For_Old --
  1452:    ------------------
  1453:
  1454:    function Name_For_Old (N : Node_Id) return W_Identifier_Id is
```

## src/why/gnat2why-util.adb:1609-1615

```ada
  1609:    function Type_Is_Modeled_As_Base (T : Type_Kind_Id) return Boolean is
  1610:    begin
  1611:       return
  1612:         Is_Scalar_Type (T)
  1613:         and then
  1614:           (not Has_OK_Static_Scalar_Subtype (T) or else Is_Null_Range (T));
  1615:    end Type_Is_Modeled_As_Base;
```

## src/why/gnat2why-util.adb:1875-1909

```ada
  1875:    -- Use_Split_Form_For_Type --
  1876:    -----------------------------
  1877:
  1878:    function Use_Split_Form_For_Type (E : Type_Kind_Id) return Boolean is
  1879:    begin
  1880:       return
  1881:         Is_Scalar_Type (Retysp (E))
  1882:         and then not Is_Standard_Boolean_Type (Retysp (E));
  1883:    end Use_Split_Form_For_Type;
  1884:
  1885:    ------------------------
  1886:    -- Why_Type_Of_Entity --
  1887:    ------------------------
  1888:
  1889:    function Why_Type_Of_Entity (E : Entity_Id) return W_Type_Id is
  1890:    begin
  1891:       --  Entities for ASCII characters are not translated. Instead we use
  1892:       --  directly their integer translation.
  1893:
  1894:       if Sloc (E) = Standard_ASCII_Location then
  1895:          return EW_Int_Type;
  1896:       else
  1897:          declare
  1898:             Binder : constant Item_Type :=
  1899:               Ada_Ent_To_Why.Element (Symbol_Table, E);
  1900:          begin
  1901:             return Get_Why_Type_From_Item (Binder);
  1902:          end;
  1903:       end if;
  1904:    end Why_Type_Of_Entity;
  1905:
  1906:    ---------------------------
  1907:    -- Why_Type_Is_BitVector --
  1908:    ---------------------------
  1909:
```

## src/why/gnat2why-util.ads:570-582

```ada
   570:    function Get_Base_Of_Type (T : Type_Kind_Id) return Type_Kind_Id
   571:    with Post => not Type_Is_Modeled_As_Base (Get_Base_Of_Type'Result);
   572:    --  Returns the first type in the ancestors of T which is not modeled as
   573:    --  base. It is the type which we be used to model a type modeled as base.
   574:
   575:    function Is_Range_Type_In_Why (T : Type_Kind_Id) return Boolean;
   576:    --  Returns True if T is a scalar type that should be translated into Why
   577:    --  as a range type. This is currently done for static signed integer types.
   578:
   579:    function Has_Init_Wrapper (Typ : Type_Kind_Id) return Boolean
   580:    is (SPARK_Definition.Has_Relaxed_Init (Typ)
   581:        or else Might_Contain_Relaxed_Init (Typ));
   582:
```

## src/why/why-atree-modules.adb:297-324

```ada
   297:    function E_Symb
   298:      (E : Entity_Id; S : Why_Name_Enum; Relaxed_Init : Boolean := False)
   299:       return W_Identifier_Id
   300:    is
   301:       use Why_Symb_Maps;
   302:       E2  : constant Entity_Id := (if Is_Type (E) then Retysp (E) else E);
   303:       Key : constant Why_Symb := Why_Symb'(Entity => E2, Symb => S);
   304:       C   : constant Why_Symb_Maps.Cursor :=
   305:         (if Relaxed_Init
   306:          then Why_Relaxed_Symb_Map.Find (Key)
   307:          else Why_Symb_Map.Find (Key));
   308:    begin
   309:       return Id : W_Identifier_Id do
   310:          if Has_Element (C) then
   311:             Id := Element (C);
   312:          else
   313:             Insert_Why_Symbols (E2);
   314:
   315:             if Relaxed_Init then
   316:                Id := Why_Relaxed_Symb_Map.Element (Key);
   317:             else
   318:                Id := Why_Symb_Map.Element (Key);
   319:             end if;
   320:          end if;
   321:       end return;
   322:    end E_Symb;
   323:
   324:    ------------------------
```

## src/why/why-atree-modules.adb:465-504

```ada
   465:    function Hashconsed_Entity_Module
   466:      (E       : Entity_Id;
   467:       K       : Module_Kind;
   468:       Name    : String;
   469:       Modules : in out Ada_Node_To_Module.Map) return W_Module_Id
   470:    is
   471:       use Module_Kind_To_Module;
   472:       Normalized_E : constant Entity_Id :=
   473:         (if Nkind (E) in N_Entity
   474:            and then Ekind (E) = E_Constant
   475:            and then Is_Partial_View (E)
   476:            and then Entity_In_SPARK (Full_View (E))
   477:          then Full_View (E)
   478:          else E);
   479:       --  For constants, use the entity of the full view if it is in SPARK
   480:       Position     : Ada_Node_To_Module.Cursor;
   481:       Inserted     : Boolean;
   482:       C            : Module_Kind_To_Module.Cursor := No_Element;
   483:    begin
   484:       Modules.Insert (Normalized_E, Empty_Map, Position, Inserted);
   485:
   486:       if not Inserted then
   487:          C := Modules (Position).Find (K);
   488:       end if;
   489:
   490:       if Has_Element (C) then
   491:          return Element (C);
   492:       elsif Nkind (E) in N_Entity then
   493:          declare
   494:             M : constant W_Module_Id :=
   495:               New_Module
   496:                 (Ada_Node => Normalized_E, File => No_Symbol, Name => Name);
   497:          begin
   498:             Modules (Position).Insert (K, M);
   499:             return M;
   500:          end;
   501:       else
   502:          return Why_Empty;
   503:       end if;
   504:    end Hashconsed_Entity_Module;
```

## src/why/why-atree-modules.adb:703-781

```ada
   703:       --  Builtin unary minus and void
   704:
   705:       Int_Unary_Minus :=
   706:         New_Identifier
   707:           (Domain => EW_Term, Symb => NID ("-"), Typ => EW_Int_Type);
   708:       Fixed_Unary_Minus :=
   709:         New_Identifier
   710:           (Domain => EW_Term, Symb => NID ("-"), Typ => M_Main.Fixed_Type);
   711:       Real_Unary_Minus :=
   712:         New_Identifier
   713:           (Domain => EW_Term, Symb => NID ("-."), Typ => EW_Real_Type);
   714:
   715:       Void :=
   716:         New_Identifier
   717:           (Domain => EW_Term, Symb => NID ("()"), Typ => EW_Unit_Type);
   718:
   719:       --  Builtin infix operations
   720:
   721:       Why_Eq :=
   722:         New_Identifier
   723:           (Domain => EW_Term,
   724:            Symb   => NID ("="),
   725:            Typ    => EW_Bool_Type,
   726:            Infix  => True);
   727:       Why_Neq :=
   728:         New_Identifier
   729:           (Domain => EW_Term,
   730:            Symb   => NID ("<>"),
   731:            Typ    => EW_Bool_Type,
   732:            Infix  => True);
   733:
   734:       Int_Infix_Add :=
   735:         New_Identifier
   736:           (Module => Int_Module,
   737:            Domain => EW_Term,
   738:            Symb   => NID ("+"),
   739:            Typ    => EW_Int_Type,
   740:            Infix  => True);
   741:       Int_Infix_Subtr :=
   742:         New_Identifier
   743:           (Module => Int_Module,
   744:            Domain => EW_Term,
   745:            Symb   => NID ("-"),
   746:            Typ    => EW_Int_Type,
   747:            Infix  => True);
   748:       Int_Infix_Mult :=
   749:         New_Identifier
   750:           (Module => Int_Module,
   751:            Domain => EW_Term,
   752:            Symb   => NID ("*"),
   753:            Typ    => EW_Int_Type,
   754:            Infix  => True);
   755:       Int_Infix_Le :=
   756:         New_Identifier
   757:           (Module => Int_Module,
   758:            Domain => EW_Term,
   759:            Symb   => NID ("<="),
   760:            Typ    => EW_Bool_Type,
   761:            Infix  => True);
   762:       Int_Infix_Lt :=
   763:         New_Identifier
   764:           (Module => Int_Module,
   765:            Domain => EW_Term,
   766:            Symb   => NID ("<"),
   767:            Typ    => EW_Bool_Type,
   768:            Infix  => True);
   769:       Int_Infix_Ge :=
   770:         New_Identifier
   771:           (Module => Int_Module,
   772:            Domain => EW_Term,
   773:            Symb   => NID (">="),
   774:            Typ    => EW_Bool_Type,
   775:            Infix  => True);
   776:       Int_Infix_Gt :=
   777:         New_Identifier
   778:           (Module => Int_Module,
   779:            Domain => EW_Term,
   780:            Symb   => NID (">"),
   781:            Typ    => EW_Bool_Type,
```

## src/why/why-atree-modules.adb:870-893

```ada
   870:       --  String image module
   871:
   872:       String_Image_Module :=
   873:         New_Module
   874:           (Ada_Node => Empty,
   875:            File     => No_Symbol,
   876:            Name     => "Standard_String__Img");
   877:
   878:       To_String_Id :=
   879:         New_Identifier
   880:           (Ada_Node => Standard_String,
   881:            Domain   => EW_Term,
   882:            Module   => String_Image_Module,
   883:            Symb     => NID ("to_string"));
   884:
   885:       Of_String_Id :=
   886:         New_Identifier
   887:           (Ada_Node => Standard_String,
   888:            Domain   => EW_Term,
   889:            Module   => String_Image_Module,
   890:            Symb     => NID ("from_string"));
   891:
   892:       --  Other identifiers
   893:
```

## src/why/why-atree-modules.adb:918-1047

```ada
   918:    function Init_Array_Module (Module : W_Module_Id) return M_Array_Type is
   919:       M_Array : M_Array_Type;
   920:       Ty      : constant W_Type_Id :=
   921:         New_Type
   922:           (Type_Kind  => EW_Builtin,
   923:            Name       => New_Name (Symb => NID ("map"), Module => Module),
   924:            Is_Mutable => False);
   925:       Comp_Ty : constant W_Type_Id :=
   926:         New_Type
   927:           (Type_Kind  => EW_Builtin,
   928:            Name       =>
   929:              New_Name (Symb => NID ("component_type"), Module => Module),
   930:            Is_Mutable => False);
   931:    begin
   932:       M_Array.Module := Module;
   933:
   934:       M_Array.Ty := Ty;
   935:       M_Array.Comp_Ty := Comp_Ty;
   936:       M_Array.Get :=
   937:         New_Identifier
   938:           (Module => Module,
   939:            Domain => EW_Term,
   940:            Symb   => NID ("get"),
   941:            Typ    => Comp_Ty);
   942:       M_Array.Set :=
   943:         New_Identifier
   944:           (Module => Module,
   945:            Domain => EW_Term,
   946:            Symb   => NID ("set"),
   947:            Typ    => Ty);
   948:       M_Array.Bool_Eq :=
   949:         New_Identifier
   950:           (Module => Module,
   951:            Domain => EW_Term,
   952:            Symb   => NID ("bool_eq"),
   953:            Typ    => EW_Bool_Type);
   954:       M_Array.Slide :=
   955:         New_Identifier
   956:           (Module => Module,
   957:            Domain => EW_Term,
   958:            Symb   => NID ("slide"),
   959:            Typ    => Ty);
   960:       M_Array.Const :=
   961:         New_Identifier
   962:           (Module => Module,
   963:            Domain => EW_Term,
   964:            Symb   => NID ("const"),
   965:            Typ    => Ty);
   966:       M_Array.Slice :=
   967:         New_Identifier
   968:           (Module => Module,
   969:            Domain => EW_Term,
   970:            Symb   => NID ("slice"),
   971:            Typ    => Ty);
   972:
   973:       return M_Array;
   974:    end Init_Array_Module;
   975:
   976:    -------------------------
   977:    -- Init_Array_1_Module --
   978:    -------------------------
   979:
   980:    function Init_Array_1_Module (Module : W_Module_Id) return M_Array_1_Type is
   981:       M_Array_1 : M_Array_1_Type;
   982:       Ty        : constant W_Type_Id :=
   983:         New_Type
   984:           (Type_Kind  => EW_Builtin,
   985:            Name       => New_Name (Symb => NID ("map"), Module => Module),
   986:            Is_Mutable => False);
   987:    begin
   988:       M_Array_1.Module := Module;
   989:       M_Array_1.Concat :=
   990:         (False =>
   991:            (False =>
   992:               New_Identifier
   993:                 (Module => Module,
   994:                  Domain => EW_Term,
   995:                  Symb   => NID ("concat"),
   996:                  Typ    => Ty),
   997:             True  =>
   998:               New_Identifier
   999:                 (Module => Module,
  1000:                  Domain => EW_Term,
  1001:                  Symb   => NID ("concat_singleton_right"),
  1002:                  Typ    => Ty)),
  1003:          True  =>
  1004:            (False =>
  1005:               New_Identifier
  1006:                 (Module => Module,
  1007:                  Domain => EW_Term,
  1008:                  Symb   => NID ("concat_singleton_left"),
  1009:                  Typ    => Ty),
  1010:             True  =>
  1011:               New_Identifier
  1012:                 (Module => Module,
  1013:                  Domain => EW_Term,
  1014:                  Symb   => NID ("concat_singletons"),
  1015:                  Typ    => Ty)));
  1016:       M_Array_1.Singleton :=
  1017:         New_Identifier
  1018:           (Module => Module,
  1019:            Domain => EW_Term,
  1020:            Symb   => NID ("singleton"),
  1021:            Typ    => Ty);
  1022:
  1023:       return M_Array_1;
  1024:    end Init_Array_1_Module;
  1025:
  1026:    ------------------------------
  1027:    -- Init_Array_1_Comp_Module --
  1028:    ------------------------------
  1029:
  1030:    function Init_Array_1_Comp_Module
  1031:      (Module : W_Module_Id) return M_Array_1_Comp_Type
  1032:    is
  1033:       M_Array_1 : M_Array_1_Comp_Type;
  1034:
  1035:    begin
  1036:       M_Array_1.Module := Module;
  1037:       M_Array_1.Compare :=
  1038:         New_Identifier
  1039:           (Module => Module,
  1040:            Domain => EW_Term,
  1041:            Symb   => NID ("compare"),
  1042:            Typ    => EW_Int_Type);
  1043:
  1044:       return M_Array_1;
  1045:    end Init_Array_1_Comp_Module;
  1046:
  1047:    function Init_Array_1_Bool_Op_Module
```

## src/why/why-atree-modules.adb:1132-1150

```ada
  1132:       M_Boolean.Notb :=
  1133:         New_Identifier
  1134:           (Domain => EW_Term,
  1135:            Module => M,
  1136:            Symb   => NID ("notb"),
  1137:            Typ    => EW_Bool_Type);
  1138:       M_Boolean.Andb :=
  1139:         New_Identifier
  1140:           (Domain => EW_Term,
  1141:            Module => M,
  1142:            Symb   => NID ("andb"),
  1143:            Typ    => EW_Bool_Type);
  1144:       M_Boolean.Notb :=
  1145:         New_Identifier
  1146:           (Domain => EW_Term,
  1147:            Module => M,
  1148:            Symb   => NID ("notb"),
  1149:            Typ    => EW_Bool_Type);
  1150:       M_Boolean.Orb :=
```

## src/why/why-atree-modules.adb:2699-2747

```ada
  2699:
  2700:    procedure Init_Integer_Module is
  2701:       M : constant W_Module_Id :=
  2702:         New_Module (File => Gnatprove_Standard_File, Name => "Integer");
  2703:    begin
  2704:       M_Integer.Module := M;
  2705:       M_Integer.Bool_Eq :=
  2706:         New_Identifier
  2707:           (Module => M,
  2708:            Domain => EW_Term,
  2709:            Symb   => NID ("bool_eq"),
  2710:            Typ    => EW_Bool_Type);
  2711:       M_Integer.Bool_Ne :=
  2712:         New_Identifier
  2713:           (Module => M,
  2714:            Domain => EW_Term,
  2715:            Symb   => NID ("bool_ne"),
  2716:            Typ    => EW_Bool_Type);
  2717:       M_Integer.Bool_Le :=
  2718:         New_Identifier
  2719:           (Module => M,
  2720:            Domain => EW_Term,
  2721:            Symb   => NID ("bool_le"),
  2722:            Typ    => EW_Bool_Type);
  2723:       M_Integer.Bool_Lt :=
  2724:         New_Identifier
  2725:           (Module => M,
  2726:            Domain => EW_Term,
  2727:            Symb   => NID ("bool_lt"),
  2728:            Typ    => EW_Bool_Type);
  2729:       M_Integer.Bool_Ge :=
  2730:         New_Identifier
  2731:           (Module => M,
  2732:            Domain => EW_Term,
  2733:            Symb   => NID ("bool_ge"),
  2734:            Typ    => EW_Bool_Type);
  2735:       M_Integer.Bool_Gt :=
  2736:         New_Identifier
  2737:           (Module => M,
  2738:            Domain => EW_Term,
  2739:            Symb   => NID ("bool_gt"),
  2740:            Typ    => EW_Bool_Type);
  2741:       M_Integer.Length :=
  2742:         New_Identifier
  2743:           (Module => M,
  2744:            Domain => EW_Term,
  2745:            Symb   => NID ("length"),
  2746:            Typ    => EW_Int_Type);
  2747:    end Init_Integer_Module;
```

## src/why/why-atree-modules.adb:2765-2775

```ada
  2765:    procedure Init_Main_Module is
  2766:       M : constant W_Module_Id :=
  2767:         New_Module (File => Gnatprove_Standard_File, Name => "Main");
  2768:    begin
  2769:       M_Main.Module := M;
  2770:       M_Main.String_Image_Type :=
  2771:         New_Type
  2772:           (Type_Kind  => EW_Abstract,
  2773:            Name       => New_Name (Symb => NID ("__image"), Module => M),
  2774:            Is_Mutable => False);
  2775:
```

## src/why/why-atree-modules.adb:3297-3323

```ada
  3297:          --  Symbols for array types
  3298:
  3299:          elsif Has_Array_Type (E) then
  3300:             declare
  3301:                Ar_Dim : constant Positive := Positive (Number_Dimensions (E));
  3302:             begin
  3303:                Insert_Symbol
  3304:                  (E,
  3305:                   WNE_To_Array,
  3306:                   New_Identifier
  3307:                     (Symb   => NID ("to_array"),
  3308:                      Module => M,
  3309:                      Domain => EW_Term,
  3310:                      Typ    => Get_Array_Theory (E, Relaxed_Init).Ty),
  3311:                   Relaxed_Init);
  3312:                Insert_Symbol
  3313:                  (E,
  3314:                   WNE_Of_Array,
  3315:                   New_Identifier
  3316:                     (Symb   => NID ("of_array"),
  3317:                      Module => M,
  3318:                      Domain => EW_Term,
  3319:                      Typ    => Ty),
  3320:                   Relaxed_Init);
  3321:                Insert_Symbol
  3322:                  (E,
  3323:                   WNE_Array_Elts,
```

## src/why/why-atree-modules.adb:3693-3722

```ada
  3693:          --  Add symbol for the predicate used to assume the dynamic invariant
  3694:          --  of a type. This symbol is registered in the axiom module, so that
  3695:          --  the function can be directly defined there instead of being first
  3696:          --  declared in the entity module and then axiomatized in the axiom
  3697:          --  module (to have visibility over constants/functions in the
  3698:          --  definition).
  3699:
  3700:          if not Is_Itype (E) then
  3701:             Insert_Symbol
  3702:               (E,
  3703:                WNE_Dynamic_Invariant,
  3704:                New_Identifier
  3705:                  (Symb   => NID ("dynamic_invariant"),
  3706:                   Module => AM,
  3707:                   Domain => EW_Term,
  3708:                   Typ    => EW_Bool_Type));
  3709:
  3710:             if Has_Init_Wrapper (E) then
  3711:                Insert_Symbol
  3712:                  (E,
  3713:                   WNE_Dynamic_Invariant,
  3714:                   New_Identifier
  3715:                     (Symb   => NID ("dynamic_invariant_r"),
  3716:                      Module => AM,
  3717:                      Domain => EW_Term,
  3718:                      Typ    => EW_Bool_Type),
  3719:                   Relaxed_Init => True);
  3720:             end if;
  3721:          end if;
  3722:
```

## src/why/why-atree-modules.adb:3962-4006

```ada
  3962:                Base : constant W_Type_Id := Get_EW_Term_Type (E);
  3963:             begin
  3964:                Insert_Symbol
  3965:                  (E,
  3966:                   WNE_Attr_Image,
  3967:                   New_Identifier
  3968:                     (Symb   => NID ("attr__ATTRIBUTE_IMAGE"),
  3969:                      Module => M,
  3970:                      Domain => EW_Term,
  3971:                      Typ    => M_Main.String_Image_Type));
  3972:                Insert_Symbol
  3973:                  (E,
  3974:                   WNE_Attr_Value,
  3975:                   New_Identifier
  3976:                     (Symb   => NID ("attr__ATTRIBUTE_VALUE"),
  3977:                      Module => M,
  3978:                      Domain => EW_Term,
  3979:                      Typ    => Base));
  3980:                Insert_Symbol
  3981:                  (E,
  3982:                   WNE_Check_Not_First,
  3983:                   New_Identifier
  3984:                     (Symb   => NID ("check_not_first"),
  3985:                      Module => M,
  3986:                      Domain => EW_Term,
  3987:                      Typ    => Base));
  3988:                Insert_Symbol
  3989:                  (E,
  3990:                   WNE_Check_Not_Last,
  3991:                   New_Identifier
  3992:                     (Symb   => NID ("check_not_last"),
  3993:                      Module => M,
  3994:                      Domain => EW_Term,
  3995:                      Typ    => Base));
  3996:                Insert_Symbol
  3997:                  (E,
  3998:                   WNE_Range_Check_Fun,
  3999:                   New_Identifier
  4000:                     (Symb   => NID ("range_check_"),
  4001:                      Module => M,
  4002:                      Domain => EW_Term,
  4003:                      Typ    => Base));
  4004:                Insert_Symbol
  4005:                  (E,
  4006:                   WNE_Dynamic_Property,
```

## src/why/why-atree-modules.ads:819-857

```ada
   819:    type Module_Kind is
   820:      (Regular,
   821:       Axiom,                     --  Defining axiom of constants and aggregates
   822:       Expr_Fun_Axiom,            --  Defining axiom of expression functions
   823:       Fun_Post_Axiom,            --  Post axiom for functions
   824:       Logic_Function_Decl,       --  Declaration of the logic function
   825:       Program_Function_Decl,     --  Declaration of the program function
   826:       Dispatch,                  --  Dispatch function
   827:       Dispatch_Axiom,            --  Compatibility axioms and dispatch program
   828:       --  function.
   829:       Dispatch_Post_Axiom,       --  Post'Class axiom for dispatching functions
   830:       Refined_Post_Axiom,        --  Refined post axiom
   831:       Lemma_Axiom,               --  Post axiom of a lemma procedure annotated
   832:       --  with Automatic_Instantiation.
   833:       Validity_Wrapper,          --  Defining a wrapper for return types of
   834:       --  functions with potentially invalid results.
   835:       Type_Completion,           --  Type completion
   836:       Type_Representative,       --  Representative module for a type
   837:       Record_Rep_Completion,     --  Completion of representative module for a
   838:       --  record type.
   839:       Init_Wrapper,              --  Wrappers for relaxed initialization
   840:       Init_Wrapper_Completion,   --  Completion for init wrappers
   841:       Init_Wrapper_Pointer_Rep,  --  Representative module for init wrappers of
   842:       --  an access type.
   843:       Default_Initialialization, --  Default assumption for a type
   844:       Invariant,                 --  Type invariants
   845:       User_Equality,             --  Redefined primitive equality on records
   846:       User_Equality_Axiom,       --  Axiom for redefined primitive equality
   847:       Dispatch_Equality,         --  Dispatching equality
   848:       Dispatch_Equality_Axiom,   --  Axiom for dispatching equality
   849:       Move_Tree,                 --  Declarations for the move tree
   850:       Incomp_Move_Tree,          --  Same as above but uses an abstract type
   851:       Validity_Tree);            --  Declarations for the validity tree
   852:
   853:    function E_Module
   854:      (E : Entity_Id; K : Module_Kind := Regular) return W_Module_Id;
   855:    --  Return the module of kind K which should be used for E. Return Empty
   856:    --  when E is a node which is not an entity, and no module is known for this
   857:    --  entity. Use memoization.
```

## src/why/why-atree.adb:60-95

```ada
    60:       Empty_Node : constant Why_Node (W_Unused_At_Start) :=
    61:         (Kind     => W_Unused_At_Start,
    62:          Ada_Node => Empty,
    63:          Domain   => EW_Prog,
    64:          Checked  => True);
    65:    begin
    66:       Node_Table.Append (Empty_Node);
    67:       pragma Assert (Node_Table.Last_Index = Why_Empty);
    68:    end Initialize;
    69:
    70:    --------------
    71:    -- New_List --
    72:    --------------
    73:
    74:    function New_List return Why_Node_List is
    75:       New_Item : constant List_Info :=
    76:         (Checked => False, Content => Why_Node_Lists.Empty_List);
    77:    begin
    78:       List_Table.Append (New_Item);
    79:       return List_Table.Last_Index;
    80:    end New_List;
    81:
    82:    ---------------------
    83:    -- New_Why_Node_Id --
    84:    ---------------------
    85:
    86:    function New_Why_Node_Id (Node : Why_Node) return Why_Node_Id is
    87:    begin
    88:       Node_Table.Append (Node);
    89:       return Node_Table.Last_Index;
    90:    end New_Why_Node_Id;
    91:
    92:    function New_Why_Node_Id (Kind : W_Any_Node) return Why_Node_Id is
    93:       New_Node : Why_Node (Kind);
    94:    begin
    95:       New_Node.Ada_Node := Empty;
```

## src/why/why-gen-arrays.adb:223-448

```ada
   223:    procedure Add_Map_Arg
   224:      (Domain  : EW_Domain;
   225:       Args    : in out W_Expr_Array;
   226:       Expr    : W_Expr_Id;
   227:       Arg_Ind : in out Positive)
   228:    is
   229:       W_Ty : constant W_Type_Id := Get_Type (Expr);
   230:       Ty   : constant Entity_Id := Get_Ada_Node (+W_Ty);
   231:    begin
   232:       if Has_Static_Array_Type (Ty) then
   233:          Args (Arg_Ind) := Expr;
   234:       else
   235:          Args (Arg_Ind) :=
   236:            New_Call
   237:              (Domain => Domain,
   238:               Name   => E_Symb (Ty, WNE_To_Array, Is_Init_Wrapper_Type (W_Ty)),
   239:               Args   => (1 => Expr),
   240:               Typ    => EW_Split (Ty, Is_Init_Wrapper_Type (W_Ty)));
   241:       end if;
   242:       Arg_Ind := Arg_Ind + 1;
   243:    end Add_Map_Arg;
   244:
   245:    ------------------
   246:    -- Add_Attr_Arg --
   247:    ------------------
   248:
   249:    procedure Add_Attr_Arg
   250:      (Domain  : EW_Domain;
   251:       Args    : in out W_Expr_Array;
   252:       Expr    : W_Expr_Id;
   253:       Attr    : Attribute_Id;
   254:       Dim     : Positive;
   255:       Arg_Ind : in out Positive) is
   256:    begin
   257:       Args (Arg_Ind) :=
   258:         Insert_Conversion_To_Rep_No_Bool
   259:           (Domain, +Get_Array_Attr (+Expr, Attr, Dim));
   260:       Arg_Ind := Arg_Ind + 1;
   261:    end Add_Attr_Arg;
   262:
   263:    procedure Add_Attr_Arg
   264:      (Domain  : EW_Domain;
   265:       Args    : in out W_Expr_Array;
   266:       Ty      : Entity_Id;
   267:       Attr    : Attribute_Id;
   268:       Dim     : Positive;
   269:       Arg_Ind : in out Positive;
   270:       Params  : Transformation_Params := Body_Params) is
   271:    begin
   272:       Args (Arg_Ind) :=
   273:         Insert_Conversion_To_Rep_No_Bool
   274:           (Domain,
   275:            +Get_Array_Attr (Term_Domain (Domain), Ty, Attr, Dim, Params));
   276:       Arg_Ind := Arg_Ind + 1;
   277:    end Add_Attr_Arg;
   278:
   279:    -------------------
   280:    -- Add_Array_Arg --
   281:    -------------------
   282:
   283:    procedure Add_Array_Arg
   284:      (Domain  : EW_Domain;
   285:       Args    : in out W_Expr_Array;
   286:       Expr    : W_Expr_Id;
   287:       Arg_Ind : in out Positive)
   288:    is
   289:       W_Ty : constant W_Type_Id := Get_Type (Expr);
   290:       Ty   : constant Entity_Id := Get_Ada_Node (+W_Ty);
   291:       Dim  : constant Positive := Positive (Number_Dimensions (Ty));
   292:    begin
   293:       Add_Map_Arg (Domain, Args, Expr, Arg_Ind);
   294:       for I in 1 .. Dim loop
   295:          Add_Attr_Arg (Domain, Args, Expr, Attribute_First, I, Arg_Ind);
   296:          Add_Attr_Arg (Domain, Args, Expr, Attribute_Last, I, Arg_Ind);
   297:       end loop;
   298:    end Add_Array_Arg;
   299:
   300:    ----------------
   301:    -- Append_Num --
   302:    ----------------
   303:
   304:    function Append_Num (S : String; Count : Positive) return String
   305:    is (if Count = 1 then S else S & "_" & Image (Count, 1));
   306:
   307:    -----------------------------
   308:    -- Array_Convert_From_Base --
   309:    -----------------------------
   310:
   311:    function Array_Convert_From_Base
   312:      (Domain       : EW_Domain;
   313:       Args         : W_Expr_Array;
   314:       Ty           : Entity_Id;
   315:       Relaxed_Init : Boolean) return W_Expr_Id
   316:    is (New_Call
   317:          (Domain => Domain,
   318:           Name   => E_Symb (Ty, WNE_Of_Array, Relaxed_Init),
   319:           Args   => Args,
   320:           Typ    => EW_Abstract (Ty, Relaxed_Init => Relaxed_Init)));
   321:
   322:    function Array_Convert_From_Base
   323:      (Domain : EW_Domain;
   324:       Ty     : Entity_Id;
   325:       Ar     : W_Expr_Id;
   326:       First  : W_Expr_Id;
   327:       Last   : W_Expr_Id) return W_Expr_Id
   328:    is
   329:       First_Int    : constant W_Expr_Id :=
   330:         Insert_Conversion_To_Rep_No_Bool (Domain, Expr => First);
   331:       Last_Int     : constant W_Expr_Id :=
   332:         Insert_Conversion_To_Rep_No_Bool (Domain, Expr => Last);
   333:       Relaxed_Init : constant Boolean := Is_Init_Wrapper_Type (Get_Type (Ar));
   334:
   335:    begin
   336:       return
   337:         Array_Convert_From_Base
   338:           (Domain       => Domain,
   339:            Args         => (1 => Ar, 2 => First_Int, 3 => Last_Int),
   340:            Ty           => Ty,
   341:            Relaxed_Init => Relaxed_Init);
   342:    end Array_Convert_From_Base;
   343:
   344:    function Array_Convert_From_Base
   345:      (Domain : EW_Domain;
   346:       Ty     : Entity_Id;
   347:       Ar     : W_Expr_Id;
   348:       Bounds : W_Expr_Array) return W_Expr_Id
   349:    is
   350:       Relaxed_Init     : constant Boolean :=
   351:         Is_Init_Wrapper_Type (Get_Type (Ar));
   352:       Converted_Bounds : W_Expr_Array (Bounds'Range);
   353:    begin
   354:       for J in Bounds'Range loop
   355:          Converted_Bounds (J) :=
   356:            Insert_Conversion_To_Rep_No_Bool (Domain, Expr => Bounds (J));
   357:       end loop;
   358:
   359:       return
   360:         Array_Convert_From_Base
   361:           (Domain       => Domain,
   362:            Args         => Ar & Converted_Bounds,
   363:            Ty           => Ty,
   364:            Relaxed_Init => Relaxed_Init);
   365:    end Array_Convert_From_Base;
   366:
   367:    function Array_Convert_From_Base
   368:      (Domain : EW_Domain; Old_Ar : W_Expr_Id; New_Base : W_Expr_Id)
   369:       return W_Expr_Id
   370:    is
   371:       Ty           : constant W_Type_Id := Get_Type (New_Base);
   372:       Ty_Ent       : constant Entity_Id := Get_Ada_Node (+Ty);
   373:       Relaxed_Init : constant Boolean := Is_Init_Wrapper_Type (Ty);
   374:       Len          : constant Integer :=
   375:         1 + 2 * Integer (Number_Dimensions (Ty_Ent));
   376:       Args         : W_Expr_Array (1 .. Len);
   377:       Count        : Positive := 1;
   378:    begin
   379:       Add_Array_Arg (Domain, Args, Old_Ar, Count);
   380:       Args (1) := New_Base;
   381:       return
   382:         Array_Convert_From_Base
   383:           (Domain       => Domain,
   384:            Args         => Args,
   385:            Ty           => Ty_Ent,
   386:            Relaxed_Init => Relaxed_Init);
   387:    end Array_Convert_From_Base;
   388:
   389:    ---------------------------
   390:    -- Array_Convert_To_Base --
   391:    ---------------------------
   392:
   393:    function Array_Convert_To_Base
   394:      (Domain : EW_Domain; Ar : W_Expr_Id) return W_Expr_Id
   395:    is
   396:       Ty           : constant W_Type_Id := Get_Type (Ar);
   397:       Ty_Ent       : constant Entity_Id := Get_Ada_Node (+Ty);
   398:       Relaxed_Init : constant Boolean := Is_Init_Wrapper_Type (Ty);
   399:    begin
   400:       return
   401:         New_Call
   402:           (Domain => Domain,
   403:            Name   => E_Symb (Ty_Ent, WNE_To_Array, Relaxed_Init),
   404:            Args   => (1 => +Ar),
   405:            Typ    => EW_Split (Ty_Ent, Relaxed_Init => Relaxed_Init));
   406:    end Array_Convert_To_Base;
   407:
   408:    ---------------------------
   409:    -- Array_From_Split_Form --
   410:    ---------------------------
   411:
   412:    function Array_From_Split_Form
   413:      (I           : Item_Type;
   414:       Domain      : EW_Domain;
   415:       Ref_Allowed : Boolean := True;
   416:       Alias       : W_Expr_Id := Why_Empty) return W_Expr_Id
   417:    is
   418:       Ty           : constant W_Type_Id := Get_Typ (I.Content.B_Name);
   419:       Ty_Ent       : constant Entity_Id := Get_Ada_Node (+Ty);
   420:       Relaxed_Init : constant Boolean := Get_Relaxed_Init (Ty);
   421:       Len          : constant Integer :=
   422:         2 * Integer (Number_Dimensions (Ty_Ent));
   423:       Args         : W_Expr_Array (1 .. Len);
   424:       Arr          : W_Expr_Id;
   425:    begin
   426:       Arr :=
   427:         Reconstruct_Binder
   428:           (I.Content.B_Name, I.Content.Mutable, Domain, Ref_Allowed, Alias);
   429:
   430:       for Count in 1 .. Integer (Number_Dimensions (Ty_Ent)) loop
   431:          Args (Count * 2 - 1) :=
   432:            Insert_Conversion_To_Rep_No_Bool (EW_Term, +I.Bounds (Count).First);
   433:          Args (Count * 2) :=
   434:            Insert_Conversion_To_Rep_No_Bool (EW_Term, +I.Bounds (Count).Last);
   435:       end loop;
   436:
   437:       return
   438:         +Array_Convert_From_Base
   439:            (Domain       => EW_Term,
   440:             Args         => Arr & Args,
   441:             Ty           => Ty_Ent,
   442:             Relaxed_Init => Relaxed_Init);
   443:    end Array_From_Split_Form;
   444:
   445:    -------------------------------
   446:    -- Array_Type_Cloned_Subtype --
   447:    -------------------------------
   448:
```

## src/why/why-gen-arrays.adb:473-580

```ada
   473:    function Build_Binary_Predicate_For_Array
   474:      (Expr1, Expr2 : W_Term_Id; Ty : Entity_Id) return W_Pred_Id
   475:    is
   476:       Ty_Ext     : constant Entity_Id := Retysp (Ty);
   477:       Dim        : constant Positive := Positive (Number_Dimensions (Ty_Ext));
   478:       Vars       : Binder_Array (1 .. Dim);
   479:       Indexes    : W_Expr_Array (1 .. Dim);
   480:       Range_Expr : W_Pred_Id := True_Pred;
   481:       Index      : Node_Id := First_Index (Ty_Ext);
   482:       I          : Positive := 1;
   483:       T_Comp     : W_Expr_Id;
   484:       Tmp        : W_Identifier_Id;
   485:       Q_Expr     : W_Pred_Id;
   486:    begin
   487:       while Present (Index) loop
   488:          Tmp := New_Temp_Identifier (Typ => Base_Why_Type_No_Bool (Index));
   489:          Vars (I) :=
   490:            Binder_Type'
   491:              (Ada_Node => Empty,
   492:               B_Name   => Tmp,
   493:               B_Ent    => Null_Entity_Name,
   494:               Mutable  => False,
   495:               Labels   => <>);
   496:          Indexes (I) := +Tmp;
   497:          Range_Expr :=
   498:            +New_And_Expr
   499:               (Left   => +Range_Expr,
   500:                Right  => New_Array_Range_Expr (+Tmp, +Expr1, EW_Pred, I),
   501:                Domain => EW_Pred);
   502:          Next_Index (Index);
   503:          I := I + 1;
   504:       end loop;
   505:
   506:       pragma Assert (I = Indexes'Last + 1);
   507:
   508:       --  Call Build_Predicate_For_Comp on the array components.
   509:
   510:       T_Comp :=
   511:         +Build_Predicate_For_Comp
   512:            (C_Expr1 => +New_Array_Access (Empty, +Expr1, Indexes, EW_Term),
   513:             C_Expr2 => +New_Array_Access (Empty, +Expr2, Indexes, EW_Term),
   514:             C_Ty    => Component_Type (Ty_Ext),
   515:             Idx     => Indexes);
   516:
   517:       if T_Comp /= +True_Pred then
   518:          T_Comp :=
   519:            New_Conditional
   520:              (Domain    => EW_Pred,
   521:               Condition => +Range_Expr,
   522:               Then_Part => T_Comp,
   523:               Typ       => EW_Bool_Type);
   524:
   525:          Q_Expr := New_Universal_Quantif (Binders => Vars, Pred => +T_Comp);
   526:
   527:          return Q_Expr;
   528:       else
   529:          return True_Pred;
   530:       end if;
   531:    end Build_Binary_Predicate_For_Array;
   532:
   533:    -----------------------
   534:    -- Build_Length_Expr --
   535:    -----------------------
   536:
   537:    function Build_Length_Expr
   538:      (Domain      : EW_Domain;
   539:       First, Last : W_Expr_Id;
   540:       Typ         : W_Type_Id := EW_Int_Type) return W_Expr_Id
   541:    is
   542:       First_Rep : constant W_Expr_Id :=
   543:         Insert_Scalar_Conversion (Domain, Empty, First, Typ);
   544:       Last_Rep  : constant W_Expr_Id :=
   545:         Insert_Scalar_Conversion (Domain, Empty, Last, Typ);
   546:    begin
   547:       if Typ = EW_Int_Type then
   548:          return
   549:            New_Call
   550:              (Domain => Domain,
   551:               Name   => M_Integer.Length,
   552:               Typ    => EW_Int_Type,
   553:               Args   => (+First_Rep, +Last_Rep));
   554:       elsif Why_Type_Is_BitVector (Typ) then
   555:          declare
   556:             Cond : constant W_Expr_Id :=
   557:               New_Call
   558:                 (Domain => Domain,
   559:                  Name   => MF_BVs (Typ).Ule,
   560:                  Typ    => EW_Bool_Type,
   561:                  Args   => (+First_Rep, +Last_Rep));
   562:             Len  : constant W_Expr_Id :=
   563:               New_Discrete_Add
   564:                 (Domain,
   565:                  New_Discrete_Substract (Domain, Last_Rep, First_Rep),
   566:                  New_Discrete_Constant (Value => Uint_1, Typ => Typ));
   567:          begin
   568:             return
   569:               New_Conditional
   570:                 (Domain    => Domain,
   571:                  Condition => Cond,
   572:                  Then_Part => Len,
   573:                  Else_Part =>
   574:                    New_Discrete_Constant (Value => Uint_0, Typ => Typ),
   575:                  Typ       => Typ);
   576:          end;
   577:       else
   578:          raise Program_Error;
   579:       end if;
   580:    end Build_Length_Expr;
```

## src/why/why-gen-arrays.adb:614-630

```ada
   614:    function Build_Predicate_For_Array
   615:      (Expr : W_Term_Id; Ty : Entity_Id) return W_Pred_Id
   616:    is
   617:       function Build_Predicate_For_Comp
   618:         (C_Expr1, Dummy_Expr2 : W_Term_Id;
   619:          C_Ty                 : Entity_Id;
   620:          Idx                  : W_Expr_Array) return W_Pred_Id
   621:       is (Build_Predicate_For_Comp (C_Expr1, C_Ty, Idx));
   622:
   623:       function Build_Predicate is new
   624:         Build_Binary_Predicate_For_Array (Build_Predicate_For_Comp);
   625:
   626:    begin
   627:       return Build_Predicate (Expr, Expr, Ty);
   628:    end Build_Predicate_For_Array;
   629:
   630:    ----------------------------------------------
```

## src/why/why-gen-arrays.adb:981-1068

```ada
   981:    -----------------------------
   982:    -- Create_Rep_Array_Theory --
   983:    -----------------------------
   984:
   985:    procedure Create_Rep_Array_Theory
   986:      (E            : Entity_Id;
   987:       Module       : W_Module_Id;
   988:       Symbols      : M_Array_Type;
   989:       Relaxed_Init : Boolean)
   990:    is
   991:       Typ : constant Entity_Id := Retysp (Etype (E));
   992:
   993:       Dim : constant Positive := Positive (Number_Dimensions (Typ));
   994:
   995:       Subst : W_Clone_Substitution_Array (1 .. Dim * 7 + 1);
   996:       --  ??? why 7
   997:
   998:       Th : Theory_UC;
   999:    begin
  1000:       Th :=
  1001:         Open_Theory
  1002:           (WF_Context,
  1003:            Module,
  1004:            Comment =>
  1005:              "Module for axiomatizing the array theory associated to type "
  1006:              & """"
  1007:              & Get_Name_String (Chars (E))
  1008:              & """"
  1009:              & (if Sloc (E) > 0
  1010:                 then " defined at " & Build_Location_String (Sloc (E))
  1011:                 else "")
  1012:              & ", created in "
  1013:              & GNAT.Source_Info.Enclosing_Entity);
  1014:
  1015:       --  Start by generating all the substitutions for the theory(ies)
  1016:       --  Array__Index
  1017:
  1018:       declare
  1019:          Index : Node_Id := First_Index (Typ);
  1020:       begin
  1021:          for I in 0 .. Dim - 1 loop
  1022:
  1023:             Subst (I * 7 + 1 .. I * 7 + 7) :=
  1024:               Prepare_Indexes_Substitutions
  1025:                 (Th, Retysp (Etype (Index)), "I" & Image (I + 1, 1));
  1026:
  1027:             Next_Index (Index);
  1028:
  1029:          end loop;
  1030:       end;
  1031:
  1032:       --  Add the substitution for the component type
  1033:
  1034:       Subst (Subst'Last) :=
  1035:         New_Clone_Substitution
  1036:           (Kind      => EW_Type_Subst,
  1037:            Orig_Name => To_Name (WNE_Array_Component_Type),
  1038:            Image     => To_Name (WNE_Array_Component_Type));
  1039:
  1040:       --  Declare the component type and clone the appropriate array theory.
  1041:
  1042:       Emit
  1043:         (Th,
  1044:          New_Type_Decl
  1045:            (Name  => To_Name (WNE_Array_Component_Type),
  1046:             Alias =>
  1047:               EW_Abstract
  1048:                 (Component_Type (Typ),
  1049:                  Relaxed_Init =>
  1050:                    Has_Relaxed_Init (Component_Type (Typ))
  1051:                    or else Relaxed_Init)));
  1052:
  1053:       Emit
  1054:         (Th,
  1055:          New_Clone_Declaration
  1056:            (Theory_Kind   => EW_Theory,
  1057:             Clone_Kind    => EW_Export,
  1058:             Origin        => Array_Modules (Dim),
  1059:             As_Name       => No_Symbol,
  1060:             Substitutions => Subst));
  1061:
  1062:       --  Equality should never be called on partially initialized objects
  1063:
  1064:       if not Relaxed_Init then
  1065:          Declare_Equality_Function (Typ, Th, Symbols);
  1066:       end if;
  1067:
  1068:       Close_Theory (Th, Kind => Definition_Theory);
```

## src/why/why-gen-arrays.adb:1075-1161

```ada
  1075:    procedure Create_Rep_Array_Theory_If_Needed
  1076:      (E : Entity_Id; Relaxed_Init : Boolean)
  1077:    is
  1078:       Name    : constant Symbol := Get_Array_Theory_Name (E, Relaxed_Init);
  1079:       Module  : constant W_Module_Id :=
  1080:         New_Module (File => No_Symbol, Name => Img (Name));
  1081:       Symbols : constant M_Array_Type := Init_Array_Module (Module);
  1082:
  1083:    begin
  1084:       if M_Arrays.Contains (Key => Name) then
  1085:          return;
  1086:       end if;
  1087:
  1088:       --  If Name was inserted it means that the theory is not present:
  1089:       --  let's create it.
  1090:
  1091:       Create_Rep_Array_Theory (E, Module, Symbols, Relaxed_Init);
  1092:
  1093:       M_Arrays.Include (Key => Name, New_Item => Symbols);
  1094:
  1095:       --  For arrays of dimension 1, we may need to clone additional modules
  1096:       --  containing definition for the comparison function (if the component
  1097:       --  type is discrete) or of boolean operators (if the component type is
  1098:       --  boolean).
  1099:
  1100:       if Number_Dimensions (Retysp (Etype (E))) = 1 then
  1101:          M_Arrays_1.Include
  1102:            (Key => Name, New_Item => Init_Array_1_Module (Module));
  1103:
  1104:          --  For arrays of boolean types of dimension 1 we need to define the
  1105:          --  logical operators.
  1106:
  1107:          if not Relaxed_Init
  1108:            and then Has_Boolean_Type (Component_Type (Retysp (Etype (E))))
  1109:          then
  1110:             declare
  1111:                Bool_Op_Module : constant W_Module_Id :=
  1112:                  New_Module
  1113:                    (File => No_Symbol,
  1114:                     Name => Img (Get_Logical_Op_Theory_Name (Name)));
  1115:             begin
  1116:                Declare_Logical_Operation_Symbols (E, Bool_Op_Module, Symbols);
  1117:                M_Arrays_1_Bool_Op.Include
  1118:                  (Key      => Name,
  1119:                   New_Item => Init_Array_1_Bool_Op_Module (Bool_Op_Module));
  1120:             end;
  1121:          end if;
  1122:
  1123:          --  For arrays of discrete types of dimension 1 we need to define the
  1124:          --  comparison operators.
  1125:
  1126:          if not Relaxed_Init
  1127:            and then Has_Discrete_Type (Component_Type (Retysp (Etype (E))))
  1128:          then
  1129:             declare
  1130:                Comp_Module : constant W_Module_Id :=
  1131:                  New_Module
  1132:                    (File => No_Symbol,
  1133:                     Name => Img (Get_Comparison_Theory_Name (Name)));
  1134:             begin
  1135:                Declare_Comparison_Symbols (E, Comp_Module, Symbols);
  1136:                M_Arrays_1_Comp.Include
  1137:                  (Key      => Name,
  1138:                   New_Item => Init_Array_1_Comp_Module (Comp_Module));
  1139:             end;
  1140:          end if;
  1141:       end if;
  1142:    end Create_Rep_Array_Theory_If_Needed;
  1143:
  1144:    procedure Create_Rep_Array_Theory_If_Needed (E : Entity_Id) is
  1145:    begin
  1146:       Create_Rep_Array_Theory_If_Needed (E => E, Relaxed_Init => False);
  1147:
  1148:       --  Also create a theory for the wrapper type if we need one
  1149:
  1150:       if Has_Init_Wrapper (E) then
  1151:          Create_Rep_Array_Theory_If_Needed (E => E, Relaxed_Init => True);
  1152:
  1153:          --  Create conversion functions to and from the wrapper type
  1154:
  1155:          Create_Array_Conversion_Theory_If_Needed
  1156:            (From => E, To => E, From_Wrapper => True, To_Wrapper => False);
  1157:
  1158:          Create_Array_Conversion_Theory_If_Needed
  1159:            (From => E, To => E, From_Wrapper => False, To_Wrapper => True);
  1160:       end if;
  1161:    end Create_Rep_Array_Theory_If_Needed;
```

## src/why/why-gen-arrays.adb:1529-1623

```ada
  1529:    procedure Declare_Ada_Array (Th : Theory_UC; E : Entity_Id) is
  1530:    begin
  1531:       Declare_Ada_Array (Th => Th, E => E, Relaxed_Init => False);
  1532:    end Declare_Ada_Array;
  1533:
  1534:    procedure Declare_Ada_Array
  1535:      (Th : Theory_UC; E : Entity_Id; Relaxed_Init : Boolean)
  1536:    is
  1537:       Why_Name : constant W_Name_Id :=
  1538:         To_Why_Type (E, Local => True, Relaxed_Init => Relaxed_Init);
  1539:    begin
  1540:       if Array_Type_Is_Clone (E) then
  1541:
  1542:          --  This type is simply a copy of an existing type, we re-export the
  1543:          --  corresponding module and then return.
  1544:
  1545:          declare
  1546:             Clone_Entity : constant Entity_Id := Array_Type_Cloned_Subtype (E);
  1547:             Clone_Name   : constant W_Name_Id :=
  1548:               To_Why_Type
  1549:                 (Clone_Entity, Local => True, Relaxed_Init => Relaxed_Init);
  1550:             Clone_Module : constant W_Module_Id :=
  1551:               E_Module
  1552:                 (Clone_Entity,
  1553:                  (if Relaxed_Init then Init_Wrapper else Regular));
  1554:          begin
  1555:             Add_With_Clause (Th, Clone_Module, EW_Export);
  1556:
  1557:             --  If the copy has the same name as the original, do not redefine
  1558:             --  the type name.
  1559:
  1560:             if Get_Symb (Why_Name) /= Get_Symb (Clone_Name) then
  1561:                Emit
  1562:                  (Th,
  1563:                   New_Type_Decl
  1564:                     (Name  => Why_Name,
  1565:                      Alias => +New_Named_Type (Name => Clone_Name)));
  1566:             end if;
  1567:          end;
  1568:       else
  1569:          declare
  1570:             Array_Theory : constant W_Module_Id :=
  1571:               Get_Array_Theory (E, Relaxed_Init).Module;
  1572:             Nb_Subst     : constant Positive :=
  1573:               (if Relaxed_Init then 3 else 4);
  1574:             Subst        : W_Clone_Substitution_Array (1 .. Nb_Subst);
  1575:          begin
  1576:             Emit
  1577:               (Th,
  1578:                New_Type_Decl
  1579:                  (Name  => To_Name (WNE_Array_Component_Type),
  1580:                   Alias => EW_Abstract (Component_Type (E))));
  1581:
  1582:             Subst (1) :=
  1583:               New_Clone_Substitution
  1584:                 (Kind      => EW_Type_Subst,
  1585:                  Orig_Name => New_Name (Symb => NID ("map")),
  1586:                  Image     =>
  1587:                    New_Name (Symb => NID ("map"), Module => Array_Theory));
  1588:
  1589:             Subst (2) :=
  1590:               New_Clone_Substitution
  1591:                 (Kind      => EW_Predicate,
  1592:                  Orig_Name => New_Name (Symb => NID ("has_bounds")),
  1593:                  Image     =>
  1594:                    New_Name
  1595:                      (Symb => NID ("has_bounds"), Module => Array_Theory));
  1596:
  1597:             Subst (3) :=
  1598:               New_Clone_Substitution
  1599:                 (Kind      => EW_Predicate,
  1600:                  Orig_Name => New_Name (Symb => NID ("eq_ext")),
  1601:                  Image     =>
  1602:                    New_Name (Symb => NID ("eq_ext"), Module => Array_Theory));
  1603:
  1604:             --  We do not have an equality on wrapper types
  1605:
  1606:             if not Relaxed_Init then
  1607:                Subst (4) :=
  1608:                  New_Clone_Substitution
  1609:                    (Kind      => EW_Function,
  1610:                     Orig_Name => New_Name (Symb => NID ("array_bool_eq")),
  1611:                     Image     =>
  1612:                       New_Name
  1613:                         (Symb => NID ("bool_eq"), Module => Array_Theory));
  1614:             end if;
  1615:
  1616:             if Is_Static_Array_Type (E) then
  1617:                Declare_Constrained (Th, E, Subst);
  1618:             else
  1619:                Declare_Unconstrained (Th, Why_Name, E, Subst);
  1620:             end if;
  1621:          end;
  1622:       end if;
  1623:    end Declare_Ada_Array;
```

## src/why/why-gen-arrays.adb:1772-2222

```ada
  1772:    procedure Declare_Comparison_Symbols
  1773:      (E : Entity_Id; Module : W_Module_Id; Symbols : M_Array_Type)
  1774:    is
  1775:       Fst_Idx       : constant Node_Id :=
  1776:         First_Index
  1777:           (if Ekind (E) = E_String_Literal_Subtype
  1778:            then Retysp (Etype (E))
  1779:            else E);
  1780:       Component_Typ : constant Entity_Id := Component_Type (E);
  1781:       Base          : constant W_Type_Id :=
  1782:         Base_Why_Type_No_Bool (Component_Typ);
  1783:       To_Rep_Name   : W_Identifier_Id :=
  1784:         Conversion_Name (From => EW_Abstract (Component_Typ), To => Base);
  1785:       Th            : Theory_UC;
  1786:    begin
  1787:       Th :=
  1788:         Open_Theory
  1789:           (WF_Context,
  1790:            Module,
  1791:            Comment =>
  1792:              "Module for axiomatizing comparison for the array theory"
  1793:              & " associated to type "
  1794:              & """"
  1795:              & Get_Name_String (Chars (E))
  1796:              & """"
  1797:              & (if Sloc (E) > 0
  1798:                 then " defined at " & Build_Location_String (Sloc (E))
  1799:                 else "")
  1800:              & ", created in "
  1801:              & GNAT.Source_Info.Enclosing_Entity);
  1802:
  1803:       --  If components have wrappers, we cannot use To_Rep symbol as is.
  1804:       --  Generate a new To_Rep symbol for this case.
  1805:
  1806:       if Has_Relaxed_Init (Component_Typ) then
  1807:          declare
  1808:             A_Ident  : constant W_Identifier_Id :=
  1809:               New_Identifier
  1810:                 (Name => "a",
  1811:                  Typ  => EW_Abstract (Component_Typ, Relaxed_Init => True));
  1812:             A_Binder : constant Binder_Array :=
  1813:               (1 => (B_Name => A_Ident, others => <>));
  1814:          begin
  1815:             Emit
  1816:               (Th,
  1817:                New_Function_Decl
  1818:                  (Domain      => EW_Term,
  1819:                   Name        => To_Local (To_Rep_Name),
  1820:                   Binders     => A_Binder,
  1821:                   Labels      => Symbol_Sets.Empty_Set,
  1822:                   Location    => No_Location,
  1823:                   Return_Type => Base,
  1824:                   Def         =>
  1825:                     New_Call
  1826:                       (Domain => EW_Term,
  1827:                        Name   => To_Rep_Name,
  1828:                        Args   =>
  1829:                          (1 =>
  1830:                             Insert_Simple_Conversion
  1831:                               (Ada_Node => Empty,
  1832:                                Domain   => EW_Term,
  1833:                                Expr     => +A_Ident,
  1834:                                To       => EW_Abstract (Component_Typ))),
  1835:                        Typ    => Base)));
  1836:
  1837:             To_Rep_Name := To_Local (To_Rep_Name);
  1838:          end;
  1839:       end if;
  1840:
  1841:       declare
  1842:          Sbst : constant W_Clone_Substitution_Array :=
  1843:            (1 =>
  1844:               New_Clone_Substitution
  1845:                 (Kind      => EW_Type_Subst,
  1846:                  Orig_Name => To_Name (WNE_Array_Component_Type),
  1847:                  Image     => Get_Name (Symbols.Comp_Ty)),
  1848:             2 =>
  1849:               New_Clone_Substitution
  1850:                 (Kind      => EW_Function,
  1851:                  Orig_Name => New_Name (Symb => NID ("to_rep")),
  1852:                  Image     => Get_Name (To_Rep_Name)),
  1853:             3 =>
  1854:               New_Clone_Substitution
  1855:                 (Kind      => EW_Type_Subst,
  1856:                  Orig_Name => New_Name (Symb => NID ("map")),
  1857:                  Image     => Get_Name (Symbols.Ty)))
  1858:            & Prepare_Indexes_Substitutions
  1859:                (Th, Base_Type (Etype (Fst_Idx)), "Index")
  1860:            & (1 =>
  1861:                 New_Clone_Substitution
  1862:                   (Kind      => EW_Function,
  1863:                    Orig_Name => New_Name (Symb => NID ("get")),
  1864:                    Image     => Get_Name (Symbols.Get)),
  1865:               2 =>
  1866:                 New_Clone_Substitution
  1867:                   (Kind      => EW_Function,
  1868:                    Orig_Name => New_Name (Symb => NID ("bool_eq")),
  1869:                    Image     => Get_Name (Symbols.Bool_Eq)));
  1870:
  1871:       begin
  1872:          if Has_Modular_Integer_Type (Component_Typ)
  1873:            and then not Has_No_Bitwise_Operations_Annotation (Component_Typ)
  1874:          then
  1875:             Emit
  1876:               (Th,
  1877:                New_Clone_Declaration
  1878:                  (Theory_Kind   => EW_Module,
  1879:                   Clone_Kind    => EW_Export,
  1880:                   Origin        =>
  1881:                     (if Base = EW_BitVector_8_Type
  1882:                      then Array_BV8_Rep_Comparison_Ax
  1883:                      elsif Base = EW_BitVector_16_Type
  1884:                      then Array_BV16_Rep_Comparison_Ax
  1885:                      elsif Base = EW_BitVector_32_Type
  1886:                      then Array_BV32_Rep_Comparison_Ax
  1887:                      elsif Base = EW_BitVector_64_Type
  1888:                      then Array_BV64_Rep_Comparison_Ax
  1889:                      elsif Base = EW_BitVector_128_Type
  1890:                      then Array_BV128_Rep_Comparison_Ax
  1891:                      else raise Program_Error),
  1892:                   As_Name       => No_Symbol,
  1893:                   Substitutions => Sbst));
  1894:          else
  1895:             Emit
  1896:               (Th,
  1897:                New_Clone_Declaration
  1898:                  (Theory_Kind   => EW_Module,
  1899:                   Clone_Kind    => EW_Export,
  1900:                   Origin        => Array_Int_Rep_Comparison_Ax,
  1901:                   As_Name       => No_Symbol,
  1902:                   Substitutions => Sbst));
  1903:          end if;
  1904:       end;
  1905:
  1906:       Close_Theory (Th, Kind => Definition_Theory);
  1907:    end Declare_Comparison_Symbols;
  1908:
  1909:    -------------------------------
  1910:    -- Declare_Equality_Function --
  1911:    -------------------------------
  1912:
  1913:    procedure Declare_Equality_Function
  1914:      (E : Entity_Id; Th : Theory_UC; Symbols : M_Array_Type)
  1915:    is
  1916:       Map_Ty   : constant W_Type_Id :=
  1917:         New_Named_Type (Name => To_Local (Get_Name (Symbols.Ty)));
  1918:       A_Ident  : constant W_Identifier_Id :=
  1919:         New_Identifier (Name => "a", Typ => Map_Ty);
  1920:       B_Ident  : constant W_Identifier_Id :=
  1921:         New_Identifier (Name => "b", Typ => Map_Ty);
  1922:       Dim      : constant Positive := Positive (Number_Dimensions (E));
  1923:       Idx_Vars : Binder_Array (1 .. Dim);
  1924:       --  Binders for quantified index variables.
  1925:       --  idx1 idx2 ...
  1926:
  1927:       Args_Lgth : constant Natural := Dim * 2 + 1;
  1928:       Args      : Binder_Array (1 .. 2 * Args_Lgth);
  1929:       --  Binders for the parameters of the equality function.
  1930:       --  a a__first a__last a__first_2 ... b  b__first ...
  1931:
  1932:       A_Indexes : W_Expr_Array (1 .. Dim + 1);
  1933:       --  Expressions used to access an element in A.
  1934:       --  a idx1 idx2 ...
  1935:
  1936:       B_Indexes : W_Expr_Array (1 .. Dim + 1);
  1937:       --  Expressions used to access an element in B.
  1938:       --  b (b__first - a__first + idx1) ...
  1939:
  1940:       Range_Cond : W_Pred_Id := True_Pred;
  1941:       --  The index variables are in range.
  1942:       --  a__first <= idx1 <= a__last /\ ...
  1943:
  1944:       Length_Eq : W_Pred_Id := True_Pred;
  1945:       --  The arrays have the same length.
  1946:       --  (if a__first <= a__last then a__last - a__first = b__last - b__first
  1947:       --   else b__first > b__last) /\ ...
  1948:
  1949:       Index : Node_Id := First_Index (E);
  1950:       I     : Positive := 1;
  1951:
  1952:    begin
  1953:       --  Store a and b in Args
  1954:
  1955:       Args (1) :=
  1956:         Binder_Type'
  1957:           (Ada_Node => Empty,
  1958:            B_Name   => A_Ident,
  1959:            B_Ent    => Null_Entity_Name,
  1960:            Mutable  => False,
  1961:            Labels   => <>);
  1962:       Args (Args_Lgth + 1) :=
  1963:         Binder_Type'
  1964:           (Ada_Node => Empty,
  1965:            B_Name   => B_Ident,
  1966:            B_Ent    => Null_Entity_Name,
  1967:            Mutable  => False,
  1968:            Labels   => <>);
  1969:
  1970:       --  Store a and b in their expression array
  1971:
  1972:       A_Indexes (1) := +A_Ident;
  1973:       B_Indexes (1) := +B_Ident;
  1974:
  1975:       while Present (Index) loop
  1976:          declare
  1977:             Typ   : constant W_Type_Id := Base_Why_Type_No_Bool (Index);
  1978:             Idx   : constant W_Identifier_Id :=
  1979:               New_Temp_Identifier (Base_Name => "idx", Typ => Typ);
  1980:             A_Fst : constant W_Identifier_Id :=
  1981:               Attr_Append ("a", Attribute_First, I, Typ);
  1982:             A_Lst : constant W_Identifier_Id :=
  1983:               Attr_Append ("a", Attribute_Last, I, Typ);
  1984:             B_Fst : constant W_Identifier_Id :=
  1985:               Attr_Append ("b", Attribute_First, I, Typ);
  1986:             B_Lst : constant W_Identifier_Id :=
  1987:               Attr_Append ("b", Attribute_Last, I, Typ);
  1988:
  1989:          begin
  1990:             --  Store the new index in the quantified variables
  1991:
  1992:             Idx_Vars (I) :=
  1993:               Binder_Type'
  1994:                 (Ada_Node => Empty,
  1995:                  B_Name   => Idx,
  1996:                  B_Ent    => Null_Entity_Name,
  1997:                  Mutable  => False,
  1998:                  Labels   => <>);
  1999:
  2000:             --  Store the first and last bounds of a and b in Args
  2001:
  2002:             Args (2 * I) :=
  2003:               Binder_Type'
  2004:                 (Ada_Node => Empty,
  2005:                  B_Name   => A_Fst,
  2006:                  B_Ent    => Null_Entity_Name,
  2007:                  Mutable  => False,
  2008:                  Labels   => <>);
  2009:             Args (2 * I + 1) :=
  2010:               Binder_Type'
  2011:                 (Ada_Node => Empty,
  2012:                  B_Name   => A_Lst,
  2013:                  B_Ent    => Null_Entity_Name,
  2014:                  Mutable  => False,
  2015:                  Labels   => <>);
  2016:             Args (Args_Lgth + 2 * I) :=
  2017:               Binder_Type'
  2018:                 (Ada_Node => Empty,
  2019:                  B_Name   => B_Fst,
  2020:                  B_Ent    => Null_Entity_Name,
  2021:                  Mutable  => False,
  2022:                  Labels   => <>);
  2023:             Args (Args_Lgth + 2 * I + 1) :=
  2024:               Binder_Type'
  2025:                 (Ada_Node => Empty,
  2026:                  B_Name   => B_Lst,
  2027:                  B_Ent    => Null_Entity_Name,
  2028:                  Mutable  => False,
  2029:                  Labels   => <>);
  2030:
  2031:             --  Compute the expressions of the index accesses
  2032:
  2033:             A_Indexes (I + 1) := +Idx;
  2034:             B_Indexes (I + 1) :=
  2035:               New_Discrete_Add
  2036:                 (EW_Term,
  2037:                  New_Discrete_Substract (EW_Term, +B_Fst, +A_Fst),
  2038:                  +Idx);
  2039:
  2040:             --  Compute the range condition
  2041:
  2042:             Range_Cond :=
  2043:               +New_And_Expr
  2044:                  (Left   => +Range_Cond,
  2045:                   Right  =>
  2046:                     New_Range_Expr
  2047:                       (Domain => EW_Pred,
  2048:                        Low    => +A_Fst,
  2049:                        High   => +A_Lst,
  2050:                        Expr   => +Idx),
  2051:                   Domain => EW_Pred);
  2052:
  2053:             --  Compute the equality of lengths
  2054:
  2055:             Length_Eq :=
  2056:               +New_And_Expr
  2057:                  (Left   => +Length_Eq,
  2058:                   Right  =>
  2059:                     New_Conditional
  2060:                       (Domain    => EW_Pred,
  2061:                        Condition =>
  2062:                          New_Comparison
  2063:                            (Symbol =>
  2064:                               (if Typ = EW_Int_Type
  2065:                                then Int_Infix_Le
  2066:                                elsif Why_Type_Is_BitVector (Typ)
  2067:                                then MF_BVs (Typ).Ule
  2068:                                else raise Program_Error),
  2069:                             Left   => +A_Fst,
  2070:                             Right  => +A_Lst,
  2071:                             Domain => EW_Pred),
  2072:                        Then_Part =>
  2073:                          New_And_Expr
  2074:                            (Left   =>
  2075:                               New_Comparison
  2076:                                 (Symbol =>
  2077:                                    (if Typ = EW_Int_Type
  2078:                                     then Int_Infix_Le
  2079:                                     elsif Why_Type_Is_BitVector (Typ)
  2080:                                     then MF_BVs (Typ).Ule
  2081:                                     else raise Program_Error),
  2082:                                  Left   => +B_Fst,
  2083:                                  Right  => +B_Lst,
  2084:                                  Domain => EW_Pred),
  2085:                             Right  =>
  2086:                               New_Comparison
  2087:                                 (Symbol => Why_Eq,
  2088:                                  Left   =>
  2089:                                    New_Discrete_Substract
  2090:                                      (EW_Pred, +A_Lst, +A_Fst),
  2091:                                  Right  =>
  2092:                                    New_Discrete_Substract
  2093:                                      (EW_Pred, +B_Lst, +B_Fst),
  2094:                                  Domain => EW_Pred),
  2095:                             Domain => EW_Pred),
  2096:                        Else_Part =>
  2097:                          New_Comparison
  2098:                            (Symbol =>
  2099:                               (if Typ = EW_Int_Type
  2100:                                then Int_Infix_Gt
  2101:                                elsif Why_Type_Is_BitVector (Typ)
  2102:                                then MF_BVs (Typ).Ugt
  2103:                                else raise Program_Error),
  2104:                             Left   => +B_Fst,
  2105:                             Right  => +B_Lst,
  2106:                             Domain => EW_Pred),
  2107:                        Typ       => EW_Bool_Type),
  2108:                   Domain => EW_Pred);
  2109:
  2110:             Next_Index (Index);
  2111:             I := I + 1;
  2112:          end;
  2113:       end loop;
  2114:
  2115:       --  If the type is limited, still declare an abstract placeholder for
  2116:       --  the equality function which will be used to clone the array theory.
  2117:
  2118:       if Is_Inherently_Limited_Type (E) then
  2119:
  2120:          Emit
  2121:            (Th,
  2122:             New_Function_Decl
  2123:               (Domain      => EW_Pterm,
  2124:                Name        => To_Local (Symbols.Bool_Eq),
  2125:                Binders     => Args,
  2126:                Return_Type => +EW_Bool_Type,
  2127:                Location    => No_Location,
  2128:                Labels      => Symbol_Sets.Empty_Set));
  2129:
  2130:       --  Emit:
  2131:       --  function bool_eq (a : map) (a__first : t1) ... (b : map) ... : bool =
  2132:       --    if ((if a__first <= a__last
  2133:       --         then a__last - a__first = b__last - b__first
  2134:       --         else b__first > b__last) /\ ...) /\
  2135:       --        (forall idx1 : t1, idx2 : t2 ...
  2136:       --           (a__first <= idx1 <= a__last /\ ...) ->
  2137:       --            <ada_eq> (get a idx1 ...)
  2138:       --                     (get b (b__first - a__first + idx1) ...))
  2139:       --    then True else False
  2140:       --  where <ada_eq> is user_eq in the component type is a record type and
  2141:       --  bool_eq otherwise.
  2142:
  2143:       else
  2144:
  2145:          declare
  2146:             C_Type   : constant Entity_Id := Retysp (Component_Type (E));
  2147:             W_Ty     : constant W_Type_Id :=
  2148:               EW_Abstract (C_Type, Relaxed_Init => Has_Relaxed_Init (C_Type));
  2149:             Get_Name : constant W_Identifier_Id := To_Local (Symbols.Get);
  2150:             Eq_Name  : constant W_Identifier_Id := To_Local (Symbols.Bool_Eq);
  2151:             Def      : W_Pred_Id :=
  2152:               +New_Ada_Equality
  2153:                  (Typ    => C_Type,
  2154:                   Domain => EW_Pred,
  2155:                   Left   =>
  2156:                     Insert_Simple_Conversion
  2157:                       (Ada_Node => Empty,
  2158:                        Domain   => EW_Term,
  2159:                        Expr     =>
  2160:                          New_Call (Empty, EW_Term, Get_Name, A_Indexes, W_Ty),
  2161:                        To       => EW_Abstract (C_Type)),
  2162:                   Right  =>
  2163:                     Insert_Simple_Conversion
  2164:                       (Ada_Node => Empty,
  2165:                        Domain   => EW_Term,
  2166:                        Expr     =>
  2167:                          New_Call (Empty, EW_Term, Get_Name, B_Indexes, W_Ty),
  2168:                        To       => EW_Abstract (C_Type)));
  2169:          begin
  2170:
  2171:             Def :=
  2172:               New_Conditional
  2173:                 (Condition => +Range_Cond,
  2174:                  Then_Part => +Def,
  2175:                  Typ       => EW_Bool_Type);
  2176:
  2177:             Def := New_Universal_Quantif (Binders => Idx_Vars, Pred => +Def);
  2178:
  2179:             Def :=
  2180:               +New_And_Expr
  2181:                  (Left => +Length_Eq, Right => +Def, Domain => EW_Pred);
  2182:
  2183:             Emit
  2184:               (Th,
  2185:                New_Function_Decl
  2186:                  (Domain      => EW_Pterm,
  2187:                   Name        => Eq_Name,
  2188:                   Binders     => Args,
  2189:                   Return_Type => +EW_Bool_Type,
  2190:                   Location    => No_Location,
  2191:                   Labels      => Symbol_Sets.Empty_Set,
  2192:                   Def         => +Def));
  2193:
  2194:             --  This axiom is provable from the definition of bool_eq. We
  2195:             --  supply it to help E-matching when a_first is different from
  2196:             --  b_first.
  2197:
  2198:             declare
  2199:                Rev_Args : constant Binder_Array :=
  2200:                  Args (Args_Lgth + 1 .. 2 * Args_Lgth) & Args (1 .. Args_Lgth);
  2201:                Rev_Call : constant W_Expr_Id :=
  2202:                  New_Call (Empty, EW_Term, Eq_Name, Rev_Args, EW_Bool_Type);
  2203:             begin
  2204:                Emit
  2205:                  (Th,
  2206:                   New_Guarded_Axiom
  2207:                     (Name    => NID ("bool_eq_rev"),
  2208:                      Binders => Args,
  2209:                      Pre     =>
  2210:                        +New_Comparison
  2211:                           (Symbol => Why_Eq,
  2212:                            Left   => Rev_Call,
  2213:                            Right  => +True_Term,
  2214:                            Domain => EW_Pred),
  2215:                      Def     => Def,
  2216:                      Dep     =>
  2217:                        New_Axiom_Dep
  2218:                          (Name => Eq_Name, Kind => EW_Axdep_Func)));
  2219:             end;
  2220:          end;
  2221:       end if;
  2222:    end Declare_Equality_Function;
```

## src/why/why-gen-arrays.adb:2813-2892

```ada
  2813:    function Get_Array_Attr
  2814:      (Domain : EW_Terms;
  2815:       Ty     : Entity_Id;
  2816:       Attr   : Attribute_Id;
  2817:       Dim    : Positive;
  2818:       Params : Transformation_Params := Body_Params;
  2819:       Typ    : W_Type_Id := EW_Int_Type) return W_Term_Id is
  2820:    begin
  2821:       if Attr in Attribute_First | Attribute_Last then
  2822:          declare
  2823:             Index_Type : constant Entity_Id := Nth_Index_Type (Ty, Dim);
  2824:          begin
  2825:             return
  2826:               Insert_Simple_Conversion
  2827:                 (Expr =>
  2828:                    +New_Attribute_Expr
  2829:                       (Ty     => Index_Type,
  2830:                        Domain => Domain,
  2831:                        Attr   => Attr,
  2832:                        Params => Params),
  2833:                  To   => Nth_Index_Rep_Type_No_Bool (Ty, Dim));
  2834:          end;
  2835:
  2836:       elsif Is_Static_Array_Type (Ty) then
  2837:          pragma Assert (Is_Constrained (Ty));
  2838:          return
  2839:            New_Discrete_Constant
  2840:              (Value => Static_Array_Length (Ty, Dim), Typ => Typ);
  2841:
  2842:       else
  2843:          pragma Assert (Is_Constrained (Ty));
  2844:          return +Build_Length_Expr (Domain, Ty, Dim, Typ);
  2845:       end if;
  2846:    end Get_Array_Attr;
  2847:
  2848:    function Get_Array_Attr
  2849:      (Expr : W_Term_Id;
  2850:       Attr : Attribute_Id;
  2851:       Dim  : Positive;
  2852:       Typ  : W_Type_Id := EW_Int_Type) return W_Term_Id
  2853:    is
  2854:       W_Ty         : constant W_Type_Id := Get_Type (+Expr);
  2855:       Ty           : constant Entity_Id := Get_Ada_Node (+W_Ty);
  2856:       Relaxed_Init : constant Boolean := Is_Init_Wrapper_Type (W_Ty);
  2857:    begin
  2858:       --  If the type is constrained, just use the type information
  2859:
  2860:       if Is_Static_Array_Type (Ty) then
  2861:          return Get_Array_Attr (EW_Term, Ty, Attr, Dim, Typ => Typ);
  2862:
  2863:       else
  2864:          if Attr in Attribute_First | Attribute_Last then
  2865:             declare
  2866:                Enum : constant Why_Name_Enum :=
  2867:                  (case Attr is
  2868:                     when Attribute_First => WNE_Attr_First (Dim),
  2869:                     when Attribute_Last  => WNE_Attr_Last (Dim),
  2870:                     when others          => raise Program_Error);
  2871:             begin
  2872:                return
  2873:                  New_Call
  2874:                    (Name => E_Symb (Ty, Enum, Relaxed_Init),
  2875:                     Args => (1 => +Expr),
  2876:                     Typ  => Nth_Index_Rep_Type_No_Bool (Ty, Dim));
  2877:             end;
  2878:
  2879:          elsif Typ = EW_Int_Type then
  2880:             return
  2881:               New_Call
  2882:                 (Name => E_Symb (Ty, WNE_Attr_Length (Dim), Relaxed_Init),
  2883:                  Args => (1 => +Expr),
  2884:                  Typ  => EW_Int_Type);
  2885:
  2886:          else
  2887:             return
  2888:               +Build_Length_Expr
  2889:                  (Domain => EW_Term, Expr => +Expr, Dim => Dim, Typ => Typ);
  2890:          end if;
  2891:       end if;
  2892:    end Get_Array_Attr;
```

## src/why/why-gen-arrays.adb:2990-3036

```ada
  2990:    function Get_Array_Theory_Name
  2991:      (E : Entity_Id; Relaxed_Init : Boolean := False) return Symbol
  2992:    is
  2993:       Name      : Unbounded_String :=
  2994:         To_Unbounded_String (To_String (WNE_Array_Prefix));
  2995:       Ty        : constant Entity_Id := Retysp (E);
  2996:       Type_Name : Unbounded_String;
  2997:       Index     : Node_Id := First_Index (Ty);
  2998:       Dim       : constant Positive := Positive (Number_Dimensions (Ty));
  2999:    begin
  3000:       if Ekind (Ty) = E_String_Literal_Subtype then
  3001:          return Get_Array_Theory_Name (Etype (Ty), Relaxed_Init);
  3002:       end if;
  3003:
  3004:       for I in 1 .. Dim loop
  3005:          if Has_Modular_Integer_Type (Etype (Index))
  3006:            and then not Has_No_Bitwise_Operations_Annotation (Etype (Index))
  3007:          then
  3008:             Type_Name :=
  3009:               To_Unbounded_String
  3010:                 (To_String (WNE_Array_BV_Suffix)
  3011:                  & Image
  3012:                      (Integer
  3013:                         (UI_To_Int (Modular_Size (Retysp (Etype (Index))))),
  3014:                       1));
  3015:          else
  3016:             Type_Name :=
  3017:               To_Unbounded_String (To_String (WNE_Array_Int_Suffix));
  3018:          end if;
  3019:
  3020:          Name := Name & Type_Name;
  3021:
  3022:          Next_Index (Index);
  3023:       end loop;
  3024:
  3025:       Type_Name :=
  3026:         (To_Unbounded_String
  3027:            ("__"
  3028:             & Capitalize_First (Full_Name (Retysp (Component_Type (Ty))))));
  3029:       Name := Name & Type_Name;
  3030:
  3031:       if Relaxed_Init then
  3032:          Name := Name & To_String (WNE_Init_Wrapper_Suffix);
  3033:       end if;
  3034:
  3035:       return NID (To_String (Name));
  3036:    end Get_Array_Theory_Name;
```

## src/why/why-gen-arrays.adb:3042-3104

```ada
  3042:    function New_Array_Access
  3043:      (Ada_Node : Node_Id := Empty;
  3044:       Ar       : W_Expr_Id;
  3045:       Index    : W_Expr_Array;
  3046:       Domain   : EW_Domain) return W_Expr_Id
  3047:    is
  3048:       Why_Ty       : constant W_Type_Id := Get_Type (Ar);
  3049:       Ty_Entity    : constant Entity_Id := Get_Ada_Node (+Why_Ty);
  3050:       Relaxed_Init : constant Boolean := Is_Init_Wrapper_Type (Why_Ty);
  3051:       Name         : constant W_Identifier_Id :=
  3052:         Get_Array_Theory (Ty_Entity, Relaxed_Init).Get;
  3053:       Elts         : W_Expr_Id;
  3054:       Comp_Ty      : constant Entity_Id := Retysp (Component_Type (Ty_Entity));
  3055:
  3056:    begin
  3057:       if Is_Static_Array_Type (Ty_Entity) then
  3058:          Elts := Ar;
  3059:       else
  3060:          Elts := Array_Convert_To_Base (Domain, Ar);
  3061:       end if;
  3062:
  3063:       return
  3064:         New_Call
  3065:           (Ada_Node => Ada_Node,
  3066:            Name     => Name,
  3067:            Domain   => Domain,
  3068:            Args     => (1 => Elts) & Index,
  3069:            Typ      =>
  3070:              EW_Abstract
  3071:                (Comp_Ty,
  3072:                 Relaxed_Init =>
  3073:                   Has_Relaxed_Init (Comp_Ty) or else Relaxed_Init));
  3074:    end New_Array_Access;
  3075:
  3076:    --------------------------
  3077:    -- New_Array_Range_Expr --
  3078:    --------------------------
  3079:
  3080:    function New_Array_Range_Expr
  3081:      (Index_Expr : W_Term_Id;
  3082:       Array_Expr : W_Term_Id;
  3083:       Domain     : EW_Domain;
  3084:       Dim        : Positive) return W_Expr_Id is
  3085:    begin
  3086:       return
  3087:         New_Range_Expr
  3088:           (Domain => Domain,
  3089:            Low    =>
  3090:              Insert_Conversion_To_Rep_No_Bool
  3091:                (EW_Term,
  3092:                 +Get_Array_Attr
  3093:                    (Expr => Array_Expr, Attr => Attribute_First, Dim => Dim)),
  3094:            High   =>
  3095:              Insert_Conversion_To_Rep_No_Bool
  3096:                (EW_Term,
  3097:                 +Get_Array_Attr
  3098:                    (Expr => Array_Expr, Attr => Attribute_Last, Dim => Dim)),
  3099:            Expr   => Insert_Conversion_To_Rep_No_Bool (EW_Term, +Index_Expr));
  3100:    end New_Array_Range_Expr;
  3101:
  3102:    ----------------------
  3103:    -- New_Array_Update --
  3104:    ----------------------
```

## src/why/why-gen-arrays.adb:3261-3281

```ada
  3261:    function New_Concat_Call
  3262:      (Domain             : EW_Domain;
  3263:       Args               : W_Expr_Array;
  3264:       Typ                : W_Type_Id;
  3265:       Is_Component_Left  : Boolean;
  3266:       Is_Component_Right : Boolean) return W_Expr_Id
  3267:    is
  3268:       Relaxed_Init : constant Boolean := Is_Init_Wrapper_Type (Typ);
  3269:    begin
  3270:       return
  3271:         New_Call
  3272:           (Domain => Domain,
  3273:            Name   =>
  3274:              Get_Array_Theory_1 (Get_Ada_Node (+Typ), Relaxed_Init).Concat
  3275:                (Is_Component_Left, Is_Component_Right),
  3276:            Args   => Args,
  3277:            Typ    => Typ);
  3278:    end New_Concat_Call;
  3279:
  3280:    --------------------
  3281:    -- New_Const_Call --
```

## src/why/why-gen-arrays.adb:3305-3363

```ada
  3305:    function New_Dynamic_Property
  3306:      (Domain : EW_Domain;
  3307:       Ty     : Entity_Id;
  3308:       Args   : W_Expr_Array;
  3309:       Params : Transformation_Params := Body_Params) return W_Expr_Id
  3310:    is
  3311:       Rep_Ty    : constant Entity_Id := Retysp (Ty);
  3312:       Dim       : constant Positive := Positive (Number_Dimensions (Rep_Ty));
  3313:       Call_Args : W_Expr_Array (1 .. 4 * Dim);
  3314:
  3315:    begin
  3316:       pragma Assert (Args'Length = 2 * Dim);
  3317:       for Count in 0 .. Dim - 1 loop
  3318:          declare
  3319:             W_Typ      : constant W_Type_Id :=
  3320:               Nth_Index_Rep_Type_No_Bool (E => Rep_Ty, Dim => Count + 1);
  3321:             First_Expr : constant W_Term_Id :=
  3322:               Insert_Simple_Conversion
  3323:                 (Expr =>
  3324:                    Get_Array_Attr
  3325:                      (Domain => Term_Domain (Domain),
  3326:                       Ty     => Rep_Ty,
  3327:                       Attr   => Attribute_First,
  3328:                       Dim    => Count + 1,
  3329:                       Params => Params),
  3330:                  To   => W_Typ);
  3331:             Last_Expr  : constant W_Term_Id :=
  3332:               Insert_Simple_Conversion
  3333:                 (Expr =>
  3334:                    Get_Array_Attr
  3335:                      (Domain => Term_Domain (Domain),
  3336:                       Ty     => Rep_Ty,
  3337:                       Attr   => Attribute_Last,
  3338:                       Dim    => Count + 1,
  3339:                       Params => Params),
  3340:                  To   => W_Typ);
  3341:             F_Expr     : constant W_Expr_Id :=
  3342:               Insert_Simple_Conversion
  3343:                 (Domain => Domain, Expr => Args (2 * Count + 1), To => W_Typ);
  3344:             L_Expr     : constant W_Expr_Id :=
  3345:               Insert_Simple_Conversion
  3346:                 (Domain => Domain, Expr => Args (2 * Count + 2), To => W_Typ);
  3347:          begin
  3348:             Call_Args (4 * Count + 1) := +First_Expr;
  3349:             Call_Args (4 * Count + 2) := +Last_Expr;
  3350:             Call_Args (4 * Count + 3) := F_Expr;
  3351:             Call_Args (4 * Count + 4) := L_Expr;
  3352:          end;
  3353:       end loop;
  3354:
  3355:       return
  3356:         New_Call
  3357:           (Domain => Domain,
  3358:            Name   => Dynamic_Prop_Name (Rep_Ty),
  3359:            Args   => Call_Args,
  3360:            Typ    => EW_Bool_Type);
  3361:    end New_Dynamic_Property;
  3362:
  3363:    ---------------------------
```

## src/why/why-gen-arrays.adb:3396-3599

```ada
  3396:    function New_Length_Equality
  3397:      (L_First_E : W_Term_Id;
  3398:       L_Last_E  : W_Term_Id;
  3399:       R_First_E : W_Term_Id;
  3400:       R_Last_E  : W_Term_Id;
  3401:       Base_Ty   : W_Type_Id) return W_Pred_Id
  3402:    is
  3403:       Le_Op  : constant W_Identifier_Id :=
  3404:         (if Base_Ty = EW_Int_Type
  3405:          then Int_Infix_Le
  3406:          elsif Why_Type_Is_BitVector (Base_Ty)
  3407:          then MF_BVs (Base_Ty).Ule
  3408:          else raise Program_Error);
  3409:       Lt_Op  : constant W_Identifier_Id :=
  3410:         (if Base_Ty = EW_Int_Type
  3411:          then Int_Infix_Lt
  3412:          elsif Why_Type_Is_BitVector (Base_Ty)
  3413:          then MF_BVs (Base_Ty).Ult
  3414:          else raise Program_Error);
  3415:       Sub_Op : constant W_Identifier_Id :=
  3416:         (if Base_Ty = EW_Int_Type
  3417:          then Int_Infix_Subtr
  3418:          elsif Why_Type_Is_BitVector (Base_Ty)
  3419:          then MF_BVs (Base_Ty).Sub
  3420:          else raise Program_Error);
  3421:
  3422:    begin
  3423:       --  (if <left_arr>.first_I <= <left_arr>.last_I then
  3424:       --     <right_arr>.first_I <= <right_arr>.last_I
  3425:       --     /\ <left_arr>.last_I - <left_arr>.first_I =
  3426:       --        <right_arr>.last_I - <right_arr>.first_I
  3427:       --   else <right_arr>.last_I < <right_arr>.first_I)
  3428:
  3429:       return
  3430:         New_Conditional
  3431:           (Condition =>
  3432:              New_Call
  3433:                (Name => Le_Op,
  3434:                 Args => [+L_First_E, +L_Last_E],
  3435:                 Typ  => EW_Bool_Type),
  3436:            Then_Part =>
  3437:              New_And_Pred
  3438:                (Left  =>
  3439:                   New_Call
  3440:                     (Name => Le_Op,
  3441:                      Args => [+R_First_E, +R_Last_E],
  3442:                      Typ  => EW_Bool_Type),
  3443:                 Right =>
  3444:                   New_Comparison
  3445:                     (Symbol => Why_Eq,
  3446:                      Left   =>
  3447:                        New_Call
  3448:                          (Name => Sub_Op,
  3449:                           Args => [+L_Last_E, +L_First_E],
  3450:                           Typ  => Base_Ty),
  3451:                      Right  =>
  3452:                        New_Call
  3453:                          (Name => Sub_Op,
  3454:                           Args => [+R_Last_E, +R_First_E],
  3455:                           Typ  => Base_Ty))),
  3456:            Else_Part =>
  3457:              New_Call
  3458:                (Name => Lt_Op,
  3459:                 Args => [+R_Last_E, +R_First_E],
  3460:                 Typ  => Base_Ty),
  3461:            Typ       => EW_Bool_Type);
  3462:    end New_Length_Equality;
  3463:
  3464:    function New_Length_Equality
  3465:      (Left_Arr : W_Term_Id; Right_Arr : W_Term_Id; Dim : Positive)
  3466:       return W_Pred_Id
  3467:    is
  3468:       L_Ty      : constant Entity_Id := Get_Ada_Node (+Get_Type (+Left_Arr));
  3469:       R_Ty      : constant Entity_Id := Get_Ada_Node (+Get_Type (+Right_Arr));
  3470:       Is_Static : constant Boolean :=
  3471:         Has_Static_Array_Type (L_Ty) and then Has_Static_Array_Type (R_Ty);
  3472:       Result    : W_Pred_Id := True_Pred;
  3473:
  3474:    begin
  3475:       for I in 1 .. Dim loop
  3476:
  3477:          --  Do not issue checks for statically matching lengths
  3478:
  3479:          if not Is_Static
  3480:            or else
  3481:              Static_Array_Length (Retysp (L_Ty), I)
  3482:              /= Static_Array_Length (Retysp (R_Ty), I)
  3483:          then
  3484:             declare
  3485:                Base_Ty : constant W_Type_Id :=
  3486:                  Nth_Index_Rep_Type_No_Bool (L_Ty, Dim);
  3487:                pragma
  3488:                  Assert (Base_Ty = Nth_Index_Rep_Type_No_Bool (R_Ty, Dim));
  3489:
  3490:                L_First_E : constant W_Term_Id :=
  3491:                  Insert_Simple_Conversion
  3492:                    (Expr =>
  3493:                       Get_Array_Attr
  3494:                         (Expr => Left_Arr, Attr => Attribute_First, Dim => I),
  3495:                     To   => Base_Ty);
  3496:                L_Last_E  : constant W_Term_Id :=
  3497:                  Insert_Simple_Conversion
  3498:                    (Expr =>
  3499:                       Get_Array_Attr
  3500:                         (Expr => Left_Arr, Attr => Attribute_Last, Dim => I),
  3501:                     To   => Base_Ty);
  3502:                R_First_E : constant W_Term_Id :=
  3503:                  Insert_Simple_Conversion
  3504:                    (Expr =>
  3505:                       Get_Array_Attr
  3506:                         (Expr => Right_Arr, Attr => Attribute_First, Dim => I),
  3507:                     To   => Base_Ty);
  3508:                R_Last_E  : constant W_Term_Id :=
  3509:                  Insert_Simple_Conversion
  3510:                    (Expr =>
  3511:                       Get_Array_Attr
  3512:                         (Expr => Right_Arr, Attr => Attribute_Last, Dim => I),
  3513:                     To   => Base_Ty);
  3514:             begin
  3515:                Result :=
  3516:                  New_And_Pred
  3517:                    (Conjuncts =>
  3518:                       (1 => Result,
  3519:                        2 =>
  3520:                          New_Length_Equality
  3521:                            (L_First_E,
  3522:                             L_Last_E,
  3523:                             R_First_E,
  3524:                             R_Last_E,
  3525:                             Base_Ty)));
  3526:             end;
  3527:          end if;
  3528:       end loop;
  3529:
  3530:       return +Result;
  3531:    end New_Length_Equality;
  3532:
  3533:    function New_Length_Equality
  3534:      (Left_Arr : W_Term_Id; Right : Entity_Id; Dim : Positive) return W_Pred_Id
  3535:    is
  3536:       L_Ty      : constant Entity_Id := Get_Ada_Node (+Get_Type (+Left_Arr));
  3537:       Is_Static : constant Boolean :=
  3538:         Has_Static_Array_Type (L_Ty) and then Has_Static_Array_Type (Right);
  3539:       Result    : W_Pred_Id := True_Pred;
  3540:
  3541:    begin
  3542:       for I in 1 .. Dim loop
  3543:
  3544:          --  Do not issue checks for statically matching lengths
  3545:
  3546:          if not Is_Static
  3547:            or else
  3548:              Static_Array_Length (Retysp (L_Ty), I)
  3549:              /= Static_Array_Length (Retysp (Right), I)
  3550:          then
  3551:             declare
  3552:                Base_Ty : constant W_Type_Id :=
  3553:                  Nth_Index_Rep_Type_No_Bool (L_Ty, Dim);
  3554:                pragma
  3555:                  Assert (Base_Ty = Nth_Index_Rep_Type_No_Bool (Right, Dim));
  3556:
  3557:                L_First_E : constant W_Term_Id :=
  3558:                  Insert_Simple_Conversion
  3559:                    (Expr =>
  3560:                       Get_Array_Attr
  3561:                         (Expr => Left_Arr, Attr => Attribute_First, Dim => I),
  3562:                     To   => Base_Ty);
  3563:                L_Last_E  : constant W_Term_Id :=
  3564:                  Insert_Simple_Conversion
  3565:                    (Expr =>
  3566:                       Get_Array_Attr
  3567:                         (Expr => Left_Arr, Attr => Attribute_Last, Dim => I),
  3568:                     To   => Base_Ty);
  3569:                R_First_E : constant W_Term_Id :=
  3570:                  Insert_Simple_Conversion
  3571:                    (Expr =>
  3572:                       Get_Array_Attr
  3573:                         (Domain => EW_Term,
  3574:                          Ty     => Right,
  3575:                          Attr   => Attribute_First,
  3576:                          Dim    => I),
  3577:                     To   => Base_Ty);
  3578:                R_Last_E  : constant W_Term_Id :=
  3579:                  Insert_Simple_Conversion
  3580:                    (Expr =>
  3581:                       Get_Array_Attr
  3582:                         (Domain => EW_Term,
  3583:                          Ty     => Right,
  3584:                          Attr   => Attribute_Last,
  3585:                          Dim    => I),
  3586:                     To   => Base_Ty);
  3587:             begin
  3588:                Result :=
  3589:                  New_And_Pred
  3590:                    (Conjuncts =>
  3591:                       (1 => Result,
  3592:                        2 =>
  3593:                          New_Length_Equality
  3594:                            (L_First_E,
  3595:                             L_Last_E,
  3596:                             R_First_E,
  3597:                             R_Last_E,
  3598:                             Base_Ty)));
  3599:             end;
```

## src/why/why-gen-arrays.adb:3835-3969

```ada
  3835:    function New_Well_Formed_Pred (Arr : W_Term_Id) return W_Pred_Id is
  3836:       Typ          : constant W_Type_Id := Get_Type (+Arr);
  3837:       Relaxed_Init : constant Boolean := Is_Init_Wrapper_Type (Typ);
  3838:       E            : constant Entity_Id := Get_Ada_Node (+Typ);
  3839:    begin
  3840:       return
  3841:         New_Call
  3842:           (Name => E_Symb (E, WNE_Array_Well_Formed, Relaxed_Init),
  3843:            Args => (1 => +Arr));
  3844:    end New_Well_Formed_Pred;
  3845:
  3846:    -----------------------------------
  3847:    -- Prepare_Indexes_Substitutions --
  3848:    -----------------------------------
  3849:
  3850:    function Prepare_Indexes_Substitutions
  3851:      (Th : Theory_UC; Typ : Entity_Id; Prefix : String)
  3852:       return W_Clone_Substitution_Array
  3853:    is
  3854:       WTyp       : constant W_Type_Id :=
  3855:         Base_Why_Type_No_Bool (Base_Type (Typ));
  3856:       One_Id     : constant W_Identifier_Id :=
  3857:         New_Identifier (Name => "index_" & Prefix & "_one");
  3858:       Prefix_Mod : constant W_Module_Id :=
  3859:         New_Module (File => No_Symbol, Name => NID (Prefix));
  3860:    begin
  3861:       Emit
  3862:         (Th,
  3863:          Why.Gen.Binders.New_Function_Decl
  3864:            (Domain      => EW_Term,
  3865:             Name        => One_Id,
  3866:             Location    => No_Location,
  3867:             Labels      => Symbol_Sets.Empty_Set,
  3868:             Binders     => (1 .. 0 => <>),
  3869:             Def         =>
  3870:               (if Is_Modular_Integer_Type (Typ)
  3871:                  and then not Has_No_Bitwise_Operations_Annotation (Typ)
  3872:                then New_Modular_Constant (Value => Uint_1, Typ => WTyp)
  3873:                else New_Integer_Constant (Value => Uint_1)),
  3874:             Return_Type => WTyp));
  3875:
  3876:       --  ??? after Johannes refacto of names use this mecanism to print the
  3877:       --  new operators instead of NIDs.
  3878:
  3879:       return
  3880:         (1 =>
  3881:            New_Clone_Substitution
  3882:              (Kind      => EW_Type_Subst,
  3883:               Orig_Name => New_Name (Module => Prefix_Mod, Symb => NID ("t")),
  3884:               Image     => Get_Name (WTyp)),
  3885:          2 =>
  3886:            New_Clone_Substitution
  3887:              (Kind      => EW_Predicate,
  3888:               Orig_Name => New_Name (Module => Prefix_Mod, Symb => NID ("le")),
  3889:               Image     =>
  3890:                 Get_Name
  3891:                   (if Is_Modular_Integer_Type (Typ)
  3892:                      and then not Has_No_Bitwise_Operations_Annotation (Typ)
  3893:                    then MF_BVs (WTyp).Ule
  3894:                    else Int_Infix_Le)),
  3895:          3 =>
  3896:            New_Clone_Substitution
  3897:              (Kind      => EW_Predicate,
  3898:               Orig_Name => New_Name (Module => Prefix_Mod, Symb => NID ("lt")),
  3899:               Image     =>
  3900:                 Get_Name
  3901:                   (if Is_Modular_Integer_Type (Typ)
  3902:                      and then not Has_No_Bitwise_Operations_Annotation (Typ)
  3903:                    then MF_BVs (WTyp).Ult
  3904:                    else Int_Infix_Lt)),
  3905:          4 =>
  3906:            New_Clone_Substitution
  3907:              (Kind      => EW_Predicate,
  3908:               Orig_Name => New_Name (Module => Prefix_Mod, Symb => NID ("gt")),
  3909:               Image     =>
  3910:                 Get_Name
  3911:                   (if Is_Modular_Integer_Type (Typ)
  3912:                      and then not Has_No_Bitwise_Operations_Annotation (Typ)
  3913:                    then MF_BVs (WTyp).Ugt
  3914:                    else Int_Infix_Gt)),
  3915:          5 =>
  3916:            New_Clone_Substitution
  3917:              (Kind      => EW_Function,
  3918:               Orig_Name =>
  3919:                 New_Name (Module => Prefix_Mod, Symb => NID ("add")),
  3920:               Image     =>
  3921:                 Get_Name
  3922:                   (if Is_Modular_Integer_Type (Typ)
  3923:                      and then not Has_No_Bitwise_Operations_Annotation (Typ)
  3924:                    then MF_BVs (WTyp).Add
  3925:                    else Int_Infix_Add)),
  3926:          6 =>
  3927:            New_Clone_Substitution
  3928:              (Kind      => EW_Function,
  3929:               Orig_Name =>
  3930:                 New_Name (Module => Prefix_Mod, Symb => NID ("sub")),
  3931:               Image     =>
  3932:                 Get_Name
  3933:                   (if Is_Modular_Integer_Type (Typ)
  3934:                      and then not Has_No_Bitwise_Operations_Annotation (Typ)
  3935:                    then MF_BVs (WTyp).Sub
  3936:                    else Int_Infix_Subtr)),
  3937:          7 =>
  3938:            New_Clone_Substitution
  3939:              (Kind      => EW_Function,
  3940:               Orig_Name =>
  3941:                 New_Name (Module => Prefix_Mod, Symb => NID ("one")),
  3942:               Image     =>
  3943:                 Get_Name
  3944:                   (if Is_Modular_Integer_Type (Typ)
  3945:                      and then not Has_No_Bitwise_Operations_Annotation (Typ)
  3946:                    then MF_BVs (WTyp).One
  3947:                    else One_Id)));
  3948:    end Prepare_Indexes_Substitutions;
  3949:
  3950:    --------------------------------------------------
  3951:    -- Prepare_Standard_Array_Logical_Substitutions --
  3952:    --------------------------------------------------
  3953:
  3954:    function Prepare_Standard_Array_Logical_Substitutions
  3955:      (Th : Theory_UC; Und_Ent : Entity_Id; Symbols : M_Array_Type)
  3956:       return W_Clone_Substitution_Array
  3957:    is ((1 =>
  3958:           New_Clone_Substitution
  3959:             (Kind      => EW_Type_Subst,
  3960:              Orig_Name => New_Name (Symb => NID ("map")),
  3961:              Image     => Get_Name (Symbols.Ty)),
  3962:         2 =>
  3963:           New_Clone_Substitution
  3964:             (Kind      => EW_Function,
  3965:              Orig_Name => New_Name (Symb => NID ("get")),
  3966:              Image     => Get_Name (Symbols.Get)))
  3967:        & Prepare_Indexes_Substitutions
  3968:            (Th, Etype (First_Index (Und_Ent)), "Index"));
  3969:
```

## src/why/why-gen-arrays.adb:2526-2810

```ada
  2526:    procedure Declare_Constrained
  2527:      (Th         : Theory_UC;
  2528:       Und_Ent    : Entity_Id;
  2529:       Base_Subst : W_Clone_Substitution_Array)
  2530:    is
  2531:       Dimension       : constant Pos := Number_Dimensions (Und_Ent);
  2532:       Index           : Entity_Id := First_Index (Und_Ent);
  2533:       Subst_Per_Index : constant Int := 3;
  2534:       Subst           :
  2535:         W_Clone_Substitution_Array
  2536:           (1 .. Integer (Dimension * Subst_Per_Index));
  2537:       Cursor          : Integer := 1;
  2538:       Clone           : constant W_Module_Id :=
  2539:         Constr_Arrays (Positive (Dimension));
  2540:
  2541:       procedure Declare_Attribute
  2542:         (Kind : Why_Name_Enum; Value : Uint; Typ : W_Type_Id);
  2543:       --  Declare a constant for the first / last index of the array and
  2544:       --  add it to the clone substitution.
  2545:
  2546:       -----------------------
  2547:       -- Declare_Attribute --
  2548:       -----------------------
  2549:
  2550:       procedure Declare_Attribute
  2551:         (Kind : Why_Name_Enum; Value : Uint; Typ : W_Type_Id)
  2552:       is
  2553:          Attr_Name : constant W_Name_Id := To_Local (E_Symb (Und_Ent, Kind));
  2554:       begin
  2555:          Emit
  2556:            (Th,
  2557:             Why.Atree.Builders.New_Function_Decl
  2558:               (Domain      => EW_Pterm,
  2559:                Name        => New_Identifier (Attr_Name),
  2560:                Binders     => (1 .. 0 => <>),
  2561:                Labels      => Symbol_Sets.Empty_Set,
  2562:                Location    => No_Location,
  2563:                Return_Type => Typ,
  2564:                Def         =>
  2565:                  New_Discrete_Constant (Value => Value, Typ => Typ)));
  2566:          Subst (Cursor) :=
  2567:            New_Clone_Substitution
  2568:              (Kind => EW_Function, Orig_Name => Attr_Name, Image => Attr_Name);
  2569:          Cursor := Cursor + 1;
  2570:       end Declare_Attribute;
  2571:
  2572:       --  Start of processing for Declare_Constrained
  2573:
  2574:    begin
  2575:       if Ekind (Und_Ent) = E_String_Literal_Subtype then
  2576:          pragma
  2577:            Assert
  2578:              (Has_Array_Type (Etype (Und_Ent))
  2579:               and then Ekind (Etype (Und_Ent)) /= E_String_Literal_Subtype);
  2580:          declare
  2581:             Low  : constant Uint :=
  2582:               Expr_Value (String_Literal_Low_Bound (Und_Ent));
  2583:             R_Ty : constant W_Type_Id :=
  2584:               Base_Why_Type_No_Bool
  2585:                 (Base_Type
  2586:                    (Retysp (Etype (First_Index (Retysp (Etype (Und_Ent)))))));
  2587:          begin
  2588:             Declare_Attribute (WNE_Attr_First (1), Low, R_Ty);
  2589:             Declare_Attribute
  2590:               (WNE_Attr_Last (1),
  2591:                String_Literal_Length (Und_Ent) + Low - 1,
  2592:                R_Ty);
  2593:
  2594:             Subst (Cursor) :=
  2595:               New_Clone_Substitution
  2596:                 (Kind      => EW_Type_Subst,
  2597:                  Orig_Name =>
  2598:                    New_Name (Symb => NID (Append_Num ("index_rep_type", 1))),
  2599:                  Image     => Get_Name (R_Ty));
  2600:             Cursor := Cursor + 1;
  2601:          end;
  2602:       else
  2603:          declare
  2604:             Count : Positive := 1;
  2605:          begin
  2606:             while Present (Index) loop
  2607:                declare
  2608:                   Rng  : constant Node_Id := Get_Range (Index);
  2609:                   R_Ty : constant W_Type_Id :=
  2610:                     Base_Why_Type_No_Bool (Base_Type (Retysp (Etype (Index))));
  2611:                begin
  2612:                   Declare_Attribute
  2613:                     (WNE_Attr_First (Count),
  2614:                      Expr_Value (Low_Bound (Rng)),
  2615:                      R_Ty);
  2616:                   Declare_Attribute
  2617:                     (WNE_Attr_Last (Count),
  2618:                      Expr_Value (High_Bound (Rng)),
  2619:                      R_Ty);
  2620:
  2621:                   Subst (Cursor) :=
  2622:                     New_Clone_Substitution
  2623:                       (Kind      => EW_Type_Subst,
  2624:                        Orig_Name =>
  2625:                          New_Name
  2626:                            (Symb =>
  2627:                               NID (Append_Num ("index_rep_type", Count))),
  2628:                        Image     => Get_Name (R_Ty));
  2629:                   Cursor := Cursor + 1;
  2630:
  2631:                   Count := Count + 1;
  2632:                   Next_Index (Index);
  2633:                end;
  2634:             end loop;
  2635:          end;
  2636:       end if;
  2637:
  2638:       Emit
  2639:         (Th,
  2640:          New_Clone_Declaration
  2641:            (Theory_Kind   => EW_Module,
  2642:             Clone_Kind    => EW_Export,
  2643:             As_Name       => No_Symbol,
  2644:             Origin        => Clone,
  2645:             Substitutions => Base_Subst & Subst));
  2646:    end Declare_Constrained;
  2647:
  2648:    ---------------------------
  2649:    -- Declare_Unconstrained --
  2650:    ---------------------------
  2651:
  2652:    procedure Declare_Unconstrained
  2653:      (Th             : Theory_UC;
  2654:       Why3_Type_Name : W_Name_Id;
  2655:       Und_Ent        : Entity_Id;
  2656:       Base_Subst     : W_Clone_Substitution_Array)
  2657:    is
  2658:       Dimension       : constant Pos := Number_Dimensions (Und_Ent);
  2659:       Subst_Per_Index : constant Int := 7;
  2660:       Subst           :
  2661:         W_Clone_Substitution_Array
  2662:           (1 .. Integer (Dimension * Subst_Per_Index));
  2663:       Cursor          : Integer := 1;
  2664:       Index           : Node_Id := First_Index (Und_Ent);
  2665:       Dim_Count       : Integer := 1;
  2666:       Clone           : constant W_Module_Id :=
  2667:         Unconstr_Arrays (Positive (Dimension));
  2668:
  2669:    begin
  2670:       while Present (Index) loop
  2671:          declare
  2672:             Ind_Ty : constant Entity_Id := Etype (Index);
  2673:             B_Ty   : constant Entity_Id := Base_Type (Ind_Ty);
  2674:             B_Type : constant W_Type_Id := +EW_Abstract (B_Ty);
  2675:             R_Ty   : constant W_Type_Id := Base_Why_Type_No_Bool (B_Ty);
  2676:          begin
  2677:             Subst (Cursor) :=
  2678:               New_Clone_Substitution
  2679:                 (Kind      => EW_Type_Subst,
  2680:                  Orig_Name =>
  2681:                    New_Name
  2682:                      (Symb => NID (Append_Num ("index_base_type", Dim_Count))),
  2683:                  Image     => Ident_Of_Ada_Type (B_Ty));
  2684:             Cursor := Cursor + 1;
  2685:
  2686:             Subst (Cursor) :=
  2687:               New_Clone_Substitution
  2688:                 (Kind      => EW_Type_Subst,
  2689:                  Orig_Name =>
  2690:                    New_Name
  2691:                      (Symb => NID (Append_Num ("index_rep_type", Dim_Count))),
  2692:                  Image     => Get_Name (R_Ty));
  2693:             Cursor := Cursor + 1;
  2694:
  2695:             Subst (Cursor) :=
  2696:               New_Clone_Substitution
  2697:                 (Kind      => EW_Function,
  2698:                  Orig_Name =>
  2699:                    New_Name (Symb => NID (Append_Num ("to_rep", Dim_Count))),
  2700:                  Image     =>
  2701:                    Get_Name (Conversion_Name (From => +B_Type, To => R_Ty)));
  2702:             Cursor := Cursor + 1;
  2703:
  2704:             if R_Ty = EW_Int_Type then
  2705:                declare
  2706:                   Id_Id : constant W_Identifier_Id :=
  2707:                     New_Identifier
  2708:                       (Name => "index_" & Image (Dim_Count, 1) & "_id");
  2709:                   X_Id  : constant W_Identifier_Id :=
  2710:                     New_Identifier (Name => "x", Typ => R_Ty);
  2711:                begin
  2712:                   Emit
  2713:                     (Th,
  2714:                      Why.Gen.Binders.New_Function_Decl
  2715:                        (Domain      => EW_Term,
  2716:                         Name        => Id_Id,
  2717:                         Binders     => (1 => (B_Name => X_Id, others => <>)),
  2718:                         Labels      => Symbol_Sets.Empty_Set,
  2719:                         Location    => No_Location,
  2720:                         Def         => +X_Id,
  2721:                         Return_Type => R_Ty));
  2722:
  2723:                   Subst (Cursor) :=
  2724:                     New_Clone_Substitution
  2725:                       (Kind      => EW_Function,
  2726:                        Orig_Name =>
  2727:                          New_Name
  2728:                            (Symb =>
  2729:                               NID (Append_Num ("rep_to_int", Dim_Count))),
  2730:                        Image     => Get_Name (Id_Id));
  2731:                end;
  2732:             else
  2733:                Subst (Cursor) :=
  2734:                  New_Clone_Substitution
  2735:                    (Kind      => EW_Function,
  2736:                     Orig_Name =>
  2737:                       New_Name
  2738:                         (Symb => NID (Append_Num ("rep_to_int", Dim_Count))),
  2739:                     Image     =>
  2740:                       Get_Name
  2741:                         (Conversion_Name (From => R_Ty, To => EW_Int_Type)));
  2742:             end if;
  2743:             Cursor := Cursor + 1;
  2744:
  2745:             --  Range on base type only used for empty array (e.g. 12..7)
  2746:             Subst (Cursor) :=
  2747:               New_Clone_Substitution
  2748:                 (Kind      => EW_Predicate,
  2749:                  Orig_Name =>
  2750:                    To_Local
  2751:                      (E_Symb (Und_Ent, WNE_Array_Base_Range_Pred (Dim_Count))),
  2752:                  Image     => Get_Name (Range_Pred_Name (B_Ty)));
  2753:             Cursor := Cursor + 1;
  2754:
  2755:             Subst (Cursor) :=
  2756:               New_Clone_Substitution
  2757:                 (Kind      => EW_Predicate,
  2758:                  Orig_Name =>
  2759:                    To_Local
  2760:                      (E_Symb
  2761:                         (Und_Ent, WNE_Index_Dynamic_Property (Dim_Count))),
  2762:                  Image     => Get_Name (Dynamic_Prop_Name (Ind_Ty)));
  2763:             Cursor := Cursor + 1;
  2764:
  2765:             Subst (Cursor) :=
  2766:               New_Clone_Substitution
  2767:                 (Kind      => EW_Predicate,
  2768:                  Orig_Name =>
  2769:                    New_Name
  2770:                      (Symb => NID (Append_Num ("index_rep_le", Dim_Count))),
  2771:                  Image     =>
  2772:                    Get_Name
  2773:                      (if Has_Modular_Integer_Type (Ind_Ty)
  2774:                         and then
  2775:                           not Has_No_Bitwise_Operations_Annotation (Ind_Ty)
  2776:                       then MF_BVs (R_Ty).Ule
  2777:                       else Int_Infix_Le));
  2778:             Cursor := Cursor + 1;
  2779:          end;
  2780:          Dim_Count := Dim_Count + 1;
  2781:          Next_Index (Index);
  2782:       end loop;
  2783:
  2784:       Emit
  2785:         (Th,
  2786:          New_Clone_Declaration
  2787:            (Theory_Kind   => EW_Module,
  2788:             Clone_Kind    => EW_Export,
  2789:             As_Name       => No_Symbol,
  2790:             Origin        => Clone,
  2791:             Substitutions => Base_Subst & Subst));
  2792:       --  Declare the abstract type of the unconstrained array and mark
  2793:       --  function "to_array" as projection (from this type to why3 map type)
  2794:       Emit
  2795:         (Th,
  2796:          New_Type_Decl
  2797:            (Why3_Type_Name,
  2798:             Alias => New_Named_Type (To_String (WNE_Array_Type))));
  2799:       Emit_Projection_Metas (Th, "to_array");
  2800:       Emit_Projection_Metas (Th, "first");
  2801:       Emit_Projection_Metas (Th, "last");
  2802:       --  Dim_Count is actually nb of dimention + 1 here
  2803:       for I in 2 .. Dim_Count - 1 loop
  2804:          Emit_Projection_Metas (Th, "first_" & Image (I, 1));
  2805:          Emit_Projection_Metas (Th, "last_" & Image (I, 1));
  2806:       end loop;
  2807:    end Declare_Unconstrained;
  2808:
  2809:    --------------------
  2810:    -- Get_Array_Attr --
```

## src/why/why-gen-binders.adb:192-211

```ada
   192:    function Get_Args_From_Binders
   193:      (Binders : Binder_Array; Ref_Allowed : Boolean) return W_Expr_Array
   194:    is
   195:       Args : W_Expr_Array (1 .. Binders'Length);
   196:       I    : Positive := 1;
   197:    begin
   198:       for B of Binders loop
   199:          if Ref_Allowed and then B.Mutable then
   200:             Args (I) :=
   201:               New_Deref (Right => B.B_Name, Typ => Get_Typ (B.B_Name));
   202:          else
   203:             Args (I) := +B.B_Name;
   204:          end if;
   205:          I := I + 1;
   206:       end loop;
   207:       return Args;
   208:    end Get_Args_From_Binders;
   209:
   210:    -----------------------------
   211:    -- Get_Args_From_Variables --
```

## src/why/why-gen-binders.adb:268-280

```ada
   268:    function Get_Binders_From_Expression (Expr : Node_Id) return Item_Array is
   269:       Variables : constant Flow_Id_Sets.Set :=
   270:         Get_Variables_For_Proof (Expr, Expr);
   271:
   272:    begin
   273:       pragma Assert (if Is_Static_Expression (Expr) then Variables.Is_Empty);
   274:       return Get_Binders_From_Variables (Variables);
   275:    end Get_Binders_From_Expression;
   276:
   277:    --------------------------------
   278:    -- Get_Binders_From_Variables --
   279:    --------------------------------
   280:
```

## src/why/why-gen-binders.adb:448-481

```ada
   448:    function Get_Why_Type_From_Item (B : Item_Type) return W_Type_Id is
   449:    begin
   450:       case B.Kind is
   451:          when Regular | Concurrent_Self =>
   452:             return Get_Typ (B.Main.B_Name);
   453:
   454:          when DRecord                   =>
   455:
   456:             --  To know if we should use the wrapper type, see if the
   457:             --  fields component comes from the wrapper module.
   458:
   459:             declare
   460:                Relaxed_Init : constant Boolean :=
   461:                  (if B.Fields.Present and Has_Init_Wrapper (B.Typ)
   462:                   then
   463:                     Get_Module (Get_Name (Get_Typ (B.Fields.Binder.B_Name)))
   464:                     = E_Module (B.Typ, Init_Wrapper)
   465:                   else False);
   466:             begin
   467:                return EW_Abstract (B.Typ, Relaxed_Init => Relaxed_Init);
   468:             end;
   469:
   470:          when UCArray                   =>
   471:             declare
   472:                Typ : constant W_Type_Id := Get_Typ (B.Content.B_Name);
   473:             begin
   474:                pragma Assert (Get_Type_Kind (Typ) = EW_Split);
   475:                return
   476:                  EW_Abstract (Get_Ada_Node (+Typ), Get_Relaxed_Init (Typ));
   477:             end;
   478:
   479:          when Pointer                   =>
   480:
   481:             --  Use the wrapper type if either we have an init field or if the
```

## src/why/why-gen-binders.adb:745-786

```ada
   745:    function Mk_Item_Of_Entity
   746:      (E           : Entity_Id;
   747:       Local       : Boolean := False;
   748:       In_Fun_Decl : Boolean := False;
   749:       Hide_Info   : Boolean := False) return Item_Type
   750:    is
   751:       Use_Ty : constant Entity_Id :=
   752:         (if not In_Fun_Decl
   753:            --  test when it is safe to call Actual_Subtype
   754:            and then
   755:              (Ekind (E) in E_Constant | E_Variable or else Is_Formal (E))
   756:            and then Is_Mutable_In_Why (E)
   757:            and then Present (Actual_Subtype (E))
   758:            and then Entity_In_SPARK (Actual_Subtype (E))
   759:          then Actual_Subtype (E)
   760:          else Etype (E));
   761:       --  If we are not in a function declaration, we use the actual subtype
   762:       --  for the parameter if one is provided.
   763:
   764:       Spec_Ty          : constant Entity_Id :=
   765:         (if Is_Type (Use_Ty) and then Is_Class_Wide_Type (Use_Ty)
   766:          then Get_Specific_Type_From_Classwide (Use_Ty)
   767:          else Use_Ty);
   768:       Ty               : constant Entity_Id :=
   769:         (if Is_Type (Spec_Ty) then Retysp (Spec_Ty) else Spec_Ty);
   770:       Needs_Init_Flag  : constant Boolean :=
   771:         Is_Object (E)
   772:         and then Is_Mutable_In_Why (E)
   773:         and then Is_Elementary_Type (Ty)
   774:         and then Obj_Has_Relaxed_Init (E)
   775:         and then Ekind (E) in E_Variable | E_Out_Parameter;
   776:       --  We only need an initialization flag for variables and out parameters
   777:       --  of elementary types.
   778:       Needs_Valid_Flag : constant Boolean := Is_Potentially_Invalid (E);
   779:       --  We only need a validity flag for potentially invalid objects
   780:
   781:       function New_Init_Id (Name : W_Identifier_Id) return Opt_Id
   782:       is (if Needs_Init_Flag
   783:           then (Present => True, Id => Init_Append (Name))
   784:           else (Present => False));
   785:
   786:       function New_Is_Moved_Id (Name : W_Identifier_Id) return Opt_Id
```

## src/why/why-gen-binders.adb:888-947

```ada
   888:          end;
   889:
   890:       --  If E is in SPARK, decide whether it should be split into multiple
   891:       --  objects in Why3 or not.
   892:
   893:       elsif Entity_In_SPARK (Ty)
   894:         and then Is_Array_Type (Ty)
   895:         and then not Is_Static_Array_Type (Ty)
   896:         and then Is_Mutable_In_Why (E)
   897:         and then Ekind (E) /= E_Loop_Parameter
   898:       then
   899:
   900:          --  Binders for mutable unconstrained array parameters and objects are
   901:          --  declared in split form to preserve the bounds through loops and
   902:          --  procedure calls. That is:
   903:          --    A : UCArray (Index range <>);
   904:          --  should be translated as:
   905:          --    a : ref __split, a__first : Index'Base, a__last : Index'Base
   906:          --  and
   907:          --    procedure P (A : in out UCArray);
   908:          --  should be translated as:
   909:          --    val p (a : ref __split, a__first : rep, a__last : rep)
   910:
   911:          declare
   912:             Typ    : constant W_Type_Id :=
   913:               EW_Split (Ty, Relaxed_Init => Obj_Has_Relaxed_Init (E));
   914:             Name   : constant W_Identifier_Id :=
   915:               To_Why_Id (E => E, Typ => Typ, Local => Local);
   916:             Binder : constant Binder_Type :=
   917:               Binder_Type'
   918:                 (Ada_Node => E,
   919:                  B_Name   => Name,
   920:                  B_Ent    => Null_Entity_Name,
   921:                  Mutable  => Is_Mutable_In_Why (E),
   922:                  Labels   => <>);
   923:             Dim    : constant Positive := Positive (Number_Dimensions (Ty));
   924:             Bounds : Array_Bounds;
   925:             Index  : Node_Id := First_Index (Ty);
   926:          begin
   927:             for D in 1 .. Dim loop
   928:                declare
   929:                   Index_Typ : constant W_Type_Id :=
   930:                     EW_Abstract (Base_Type (Etype (Index)));
   931:                begin
   932:                   Bounds (D).First :=
   933:                     Attr_Append (Name, Attribute_First, D, Index_Typ);
   934:                   Bounds (D).Last :=
   935:                     Attr_Append (Name, Attribute_Last, D, Index_Typ);
   936:                   Next_Index (Index);
   937:                end;
   938:             end loop;
   939:
   940:             return
   941:               (Kind     => UCArray,
   942:                Local    => Local,
   943:                Init     => New_Init_Id (Name),
   944:                Is_Moved => New_Is_Moved_Id (Name),
   945:                Valid    => New_Valid_Id (Name),
   946:                Content  => Binder,
   947:                Dim      => Dim,
```

## src/why/why-gen-binders.adb:1082-1150

```ada
  1082:                  and then Is_Standard_Boolean_Type (Ty)
  1083:                then EW_Int_Type
  1084:
  1085:                --  Use an init wrapper type for objects with relaxed init
  1086:
  1087:                elsif Obj_Has_Relaxed_Init (E) and then not Is_Scalar_Type (Ty)
  1088:                then EW_Init_Wrapper (Type_Of_Node (Ty))
  1089:
  1090:                --  Otherwise we use Why3 representation for the type
  1091:
  1092:                else Type_Of_Node (Ty));
  1093:
  1094:             pragma
  1095:               Assert
  1096:                 (if Is_Scalar_Type (Ty) and then Obj_Has_Relaxed_Init (E)
  1097:                  then Needs_Init_Flag);
  1098:             --  Scalar types are translated as split types. If they have
  1099:             --  relaxed initialization, they should have a separate init
  1100:             --  flag.
  1101:
  1102:             Name   : constant W_Identifier_Id :=
  1103:               To_Why_Id (E => E, Typ => Typ, Local => Local, No_Comp => True);
  1104:             Binder : constant Binder_Type :=
  1105:               Binder_Type'
  1106:                 (Ada_Node => E,
  1107:                  B_Name   => Name,
  1108:                  B_Ent    => Null_Entity_Name,
  1109:                  Mutable  => Is_Mutable_In_Why (E),
  1110:                  Labels   => <>);
  1111:          begin
  1112:             return
  1113:               (Regular,
  1114:                Local,
  1115:                New_Init_Id (Name),
  1116:                New_Is_Moved_Id (Name),
  1117:                New_Valid_Id (Name),
  1118:                Binder);
  1119:          end;
  1120:       end if;
  1121:    end Mk_Item_Of_Entity;
  1122:
  1123:    ---------------------------------
  1124:    -- New_Constant_Record_Binders --
  1125:    ---------------------------------
  1126:
  1127:    function New_Constant_Record_Binders
  1128:      (Binders : Binder_Array) return W_Record_Binder_Array
  1129:    is
  1130:       Result : W_Record_Binder_Array (Binders'Range);
  1131:
  1132:    begin
  1133:       for B in Binders'Range loop
  1134:          Result (B) :=
  1135:            New_Record_Binder
  1136:              (Ada_Node   => Binders (B).Ada_Node,
  1137:               Domain     => EW_Term,
  1138:               Name       => Binders (B).B_Name,
  1139:               Labels     => Binders (B).Labels,
  1140:               Arg_Type   => Get_Type (+Binders (B).B_Name),
  1141:               Is_Mutable => Binders (B).Mutable);
  1142:       end loop;
  1143:
  1144:       return Result;
  1145:    end New_Constant_Record_Binders;
  1146:
  1147:    ------------------------
  1148:    -- New_Defining_Axiom --
  1149:    ------------------------
  1150:
```

## src/why/why-gen-binders.adb:1222-1338

```ada
  1222:    function New_Binders
  1223:      (Domain : EW_Domain; Binders : Binder_Array) return W_Binder_Array
  1224:    is
  1225:
  1226:       function New_Arg_Type (Binder : Binder_Type) return W_Type_Id;
  1227:
  1228:       ------------------
  1229:       -- New_Arg_Type --
  1230:       ------------------
  1231:
  1232:       function New_Arg_Type (Binder : Binder_Type) return W_Type_Id is
  1233:       begin
  1234:          if Domain = EW_Prog and then Binder.Mutable then
  1235:             return New_Ref_Type (Ty => Get_Type (+Binder.B_Name));
  1236:          else
  1237:             return Get_Type (+Binder.B_Name);
  1238:          end if;
  1239:       end New_Arg_Type;
  1240:
  1241:       Result : W_Binder_Array (Binders'Range);
  1242:
  1243:       --  Start of processing for New_Binders
  1244:
  1245:    begin
  1246:       for B in Binders'Range loop
  1247:          Result (B) :=
  1248:            New_Binder
  1249:              (Ada_Node => Binders (B).Ada_Node,
  1250:               Domain   => Domain,
  1251:               Name     => Binders (B).B_Name,
  1252:               Arg_Type => New_Arg_Type (Binders (B)));
  1253:       end loop;
  1254:
  1255:       return Result;
  1256:    end New_Binders;
  1257:
  1258:    --------------
  1259:    -- New_Call --
  1260:    --------------
  1261:
  1262:    function New_Call
  1263:      (Ada_Node : Node_Id := Empty;
  1264:       Domain   : EW_Domain;
  1265:       Name     : W_Identifier_Id;
  1266:       Binders  : Binder_Array;
  1267:       Typ      : W_Type_Id := Why_Empty) return W_Expr_Id is
  1268:    begin
  1269:       return
  1270:         New_Call
  1271:           (Ada_Node => Ada_Node,
  1272:            Domain   => Domain,
  1273:            Name     => Name,
  1274:            Args     => Get_Args_From_Binders (Binders, False),
  1275:            Typ      => Typ);
  1276:    end New_Call;
  1277:
  1278:    -----------------------
  1279:    -- New_Function_Decl --
  1280:    -----------------------
  1281:
  1282:    function New_Function_Decl
  1283:      (Ada_Node    : Node_Id := Empty;
  1284:       Domain      : EW_Domain;
  1285:       Name        : W_Identifier_Id;
  1286:       Binders     : Binder_Array;
  1287:       Return_Type : W_Type_Id := Why_Empty;
  1288:       Location    : Source_Ptr;
  1289:       Labels      : Symbol_Set;
  1290:       Effects     : W_Effects_Id := New_Effects;
  1291:       Def         : W_Expr_Id := Why_Empty;
  1292:       Pre         : W_Pred_Id := True_Pred;
  1293:       Post        : W_Pred_Id := True_Pred) return W_Declaration_Id is
  1294:    begin
  1295:       return
  1296:         New_Function_Decl
  1297:           (Ada_Node    => Ada_Node,
  1298:            Domain      => Domain,
  1299:            Name        => Name,
  1300:            Labels      => Labels,
  1301:            Location    => Location,
  1302:            Binders     => New_Binders (Domain, Binders),
  1303:            Return_Type => +Return_Type,
  1304:            Def         => Def,
  1305:            Effects     => Effects,
  1306:            Pre         => Pre,
  1307:            Post        => Post);
  1308:    end New_Function_Decl;
  1309:
  1310:    function New_Function_Decl
  1311:      (Ada_Node    : Node_Id := Empty;
  1312:       Domain      : EW_Domain;
  1313:       Name        : W_Identifier_Id;
  1314:       Items       : Item_Array;
  1315:       Return_Type : W_Type_Id := Why_Empty;
  1316:       Location    : Source_Ptr;
  1317:       Labels      : Symbol_Set;
  1318:       Effects     : W_Effects_Id := New_Effects;
  1319:       Def         : W_Expr_Id := Why_Empty;
  1320:       Pre         : W_Pred_Id := True_Pred;
  1321:       Post        : W_Pred_Id := True_Pred) return W_Declaration_Id
  1322:    is
  1323:       Loc_Items : Item_Array := Items;
  1324:    begin
  1325:       Localize_Binders (Loc_Items);
  1326:
  1327:       return
  1328:         New_Function_Decl
  1329:           (Ada_Node    => Ada_Node,
  1330:            Domain      => Domain,
  1331:            Name        => Name,
  1332:            Labels      => Labels,
  1333:            Location    => Location,
  1334:            Binders     => To_Binder_Array (Loc_Items),
  1335:            Return_Type => +Return_Type,
  1336:            Def         => Def,
  1337:            Effects     => Effects,
  1338:            Pre         => Pre,
```

## src/why/why-gen-binders.adb:1346-1415

```ada
  1346:    function New_Guarded_Axiom
  1347:      (Ada_Node : Node_Id := Empty;
  1348:       Name     : Symbol;
  1349:       Binders  : Binder_Array;
  1350:       Triggers : W_Triggers_OId := Why_Empty;
  1351:       Pre      : W_Pred_OId := Why_Empty;
  1352:       Def      : W_Pred_Id;
  1353:       Dep      : W_Axiom_Dep_OId := Why_Empty) return W_Declaration_Id
  1354:    is
  1355:       Ax_Body : constant W_Pred_Id :=
  1356:         (if Pre = Why_Empty or else Is_True_Boolean (+Pre)
  1357:          then Def
  1358:          else New_Connection (Op => EW_Imply, Left => +Pre, Right => +Def));
  1359:    begin
  1360:       return
  1361:         New_Axiom
  1362:           (Ada_Node => Ada_Node,
  1363:            Name     => Name,
  1364:            Def      =>
  1365:              New_Universal_Quantif
  1366:                (Binders => Binders, Triggers => Triggers, Pred => Ax_Body),
  1367:            Dep      => Dep);
  1368:    end New_Guarded_Axiom;
  1369:
  1370:    ---------------------------
  1371:    -- New_Record_Definition --
  1372:    ---------------------------
  1373:
  1374:    function New_Record_Definition
  1375:      (Ada_Node : Node_Id := Empty; Name : W_Name_Id; Binders : Binder_Array)
  1376:       return W_Declaration_Id is
  1377:    begin
  1378:       return
  1379:         New_Type_Decl
  1380:           (Ada_Node   => Ada_Node,
  1381:            Name       => Name,
  1382:            Labels     => Symbol_Sets.Empty_Set,
  1383:            Definition =>
  1384:              New_Record_Definition
  1385:                (Fields => New_Constant_Record_Binders (Binders)));
  1386:    end New_Record_Definition;
  1387:
  1388:    ---------------------------
  1389:    -- New_Universal_Quantif --
  1390:    ---------------------------
  1391:
  1392:    function New_Universal_Quantif
  1393:      (Ada_Node : Node_Id := Empty;
  1394:       Binders  : Binder_Array;
  1395:       Triggers : W_Triggers_OId := Why_Empty;
  1396:       Pred     : W_Pred_Id) return W_Pred_Id is
  1397:    begin
  1398:       if Binders'Length = 0 then
  1399:          return Pred;
  1400:
  1401:       else
  1402:          return
  1403:            New_Universal_Quantif
  1404:              (Ada_Node => Ada_Node,
  1405:               Binders  => New_Binders (EW_Pred, Binders),
  1406:               Labels   => Symbol_Sets.Empty_Set,
  1407:               Triggers => Triggers,
  1408:               Pred     => Pred);
  1409:       end if;
  1410:    end New_Universal_Quantif;
  1411:
  1412:    -------------------------
  1413:    -- Object_Has_Valid_Id --
  1414:    -------------------------
  1415:
```

## src/why/why-gen-binders.adb:1457-1524

```ada
  1457:    function Reconstruct_Binder
  1458:      (Id          : W_Identifier_Id;
  1459:       Mutable     : Boolean;
  1460:       Domain      : EW_Domain;
  1461:       Ref_Allowed : Boolean := True;
  1462:       Alias       : W_Expr_Id := Why_Empty) return W_Expr_Id is
  1463:    begin
  1464:       if not Mutable then
  1465:          return +Id;
  1466:       elsif Present (Alias) then
  1467:          return
  1468:            New_Call
  1469:              (Domain => Domain,
  1470:               Name   => Id,
  1471:               Args   => (1 => Alias),
  1472:               Typ    => Get_Typ (Id));
  1473:       elsif Ref_Allowed then
  1474:          return
  1475:            New_Deref
  1476:              (Ada_Node => Get_Ada_Node (+Id),
  1477:               Right    => Id,
  1478:               Typ      => Get_Typ (Id));
  1479:       else
  1480:          return +Id;
  1481:       end if;
  1482:    end Reconstruct_Binder;
  1483:
  1484:    ----------------------
  1485:    -- Reconstruct_Item --
  1486:    ----------------------
  1487:
  1488:    function Reconstruct_Item
  1489:      (E           : Item_Type;
  1490:       Domain      : EW_Domain;
  1491:       Ref_Allowed : Boolean := True;
  1492:       Alias       : W_Expr_Id := Why_Empty) return W_Expr_Id
  1493:    is
  1494:       T : W_Expr_Id;
  1495:    begin
  1496:       case E.Kind is
  1497:          when Subp                      =>
  1498:             raise Program_Error;
  1499:
  1500:          when Regular | Concurrent_Self =>
  1501:             T :=
  1502:               Reconstruct_Binder
  1503:                 (E.Main.B_Name, E.Main.Mutable, Domain, Ref_Allowed, Alias);
  1504:
  1505:          when UCArray                   =>
  1506:             T := Array_From_Split_Form (E, Domain, Ref_Allowed, Alias);
  1507:
  1508:          when DRecord                   =>
  1509:             T := Record_From_Split_Form (E, Domain, Ref_Allowed, Alias);
  1510:
  1511:          when Pointer                   =>
  1512:             pragma Assert (No (Alias));
  1513:
  1514:             T := +Pointer_From_Split_Form (E, Ref_Allowed);
  1515:
  1516:       end case;
  1517:
  1518:       return T;
  1519:    end Reconstruct_Item;
  1520:
  1521:    ---------------------
  1522:    -- To_Binder_Array --
  1523:    ---------------------
  1524:
```

## src/why/why-gen-binders.adb:1626-1640

```ada
  1626:    -- Unit_Param --
  1627:    ----------------
  1628:
  1629:    function Unit_Param
  1630:      (Prefix : String := ""; Ada_Node : Node_Id := Empty) return Binder_Type is
  1631:    begin
  1632:       return
  1633:         (B_Name   =>
  1634:            New_Identifier
  1635:              (Name => Prefix & "__void_param", Typ => EW_Unit_Type),
  1636:          B_Ent    => Null_Entity_Name,
  1637:          Mutable  => False,
  1638:          Ada_Node => Ada_Node,
  1639:          Labels   => <>);
  1640:    end Unit_Param;
```

## src/why/why-gen-decl.adb:90-295

```ada
    90:    ---------------------------
    91:    -- Emit_Projection_Metas --
    92:    ---------------------------
    93:
    94:    procedure Emit_Projection_Metas (Th : Theory_UC; Projection_Fun : String) is
    95:    begin
    96:       --  mark function as projection function
    97:       Emit
    98:         (Th,
    99:          New_Meta_Declaration
   100:            (Name      => NID (Model_Proj_Meta),
   101:             Parameter => NID ("function " & Projection_Fun)));
   102:
   103:       --  disable inlining of projection functions
   104:       Emit
   105:         (Th,
   106:          New_Meta_Declaration
   107:            (Name      => NID ("inline:no"),
   108:             Parameter => NID ("function " & Projection_Fun)));
   109:    end Emit_Projection_Metas;
   110:
   111:    -----------------------------
   112:    -- Emit_Record_Declaration --
   113:    -----------------------------
   114:
   115:    procedure Emit_Record_Declaration
   116:      (Th           : Theory_UC;
   117:       Name         : W_Name_Id;
   118:       Binders      : Why.Gen.Binders.Binder_Array;
   119:       SPARK_Record : Boolean := False) is
   120:    begin
   121:       --  Emit declaration of the record
   122:       Emit
   123:         (Th, Decl => New_Record_Definition (Name => Name, Binders => Binders));
   124:
   125:       --  For each record field, emit projection from the record to the field
   126:       for Binder in Binders'Range loop
   127:          Emit_Record_Projection_Declaration
   128:            (Th            => Th,
   129:             Param_Ty_Name => Name,
   130:             Field_Id      => Binders (Binder).B_Name,
   131:             Labels        =>
   132:               (if SPARK_Record
   133:                then Binders (Binder).Labels
   134:                else Symbol_Sets.Empty_Set));
   135:       end loop;
   136:    end Emit_Record_Declaration;
   137:
   138:    package Projection_Names is new
   139:      Ada.Containers.Indefinite_Ordered_Maps
   140:        (Key_Type     => String,
   141:         Element_Type => Positive,
   142:         "<"          => Standard."<",
   143:         "="          => Standard."=");
   144:
   145:    Projection_Names_Decls : Projection_Names.Map;
   146:    --  Map from the name of projection to the number of declarations of
   147:    --  projections with this name.
   148:    --  The name of the projection is composed from the name of the type that
   149:    --  is projected and if the projection projects SPARK record type to a field
   150:    --  of the record also from the spark field name. That is, the name of the
   151:    --  projection is not unique.
   152:    --  The name of the projection function must be unique and it is composed
   153:    --  of the name of the projection and if there are more declarations
   154:    --  of projections with the same name, the name of projection function is
   155:    --  also composed of the number of declarations of  projections with this
   156:    --  name.
   157:
   158:    ----------------------------------------
   159:    -- Emit_Record_Projection_Declaration --
   160:    ----------------------------------------
   161:
   162:    procedure Emit_Record_Projection_Declaration
   163:      (Th            : Theory_UC;
   164:       Param_Ty_Name : W_Name_Id;
   165:       Field_Id      : W_Identifier_Id;
   166:       Labels        : Symbol_Sets.Set)
   167:    is
   168:       use Projection_Names;
   169:
   170:       --  Projection function name
   171:       Param_Ty_Name_Str : constant String := Img (Get_Symb (Param_Ty_Name));
   172:
   173:       Proj_Name : constant String :=
   174:         Param_Ty_Name_Str & "_" & Img (Get_Symb (Get_Name (Field_Id)));
   175:
   176:       Proj_Name_Cursor : constant Cursor :=
   177:         Projection_Names_Decls.Find (Proj_Name);
   178:
   179:       Proj_Name_Decls_Num : constant Positive :=
   180:         (if Proj_Name_Cursor = No_Element
   181:          then 1
   182:          else Element (Proj_Name_Cursor));
   183:
   184:       Proj_Fun_Name : constant String :=
   185:         Proj_Name
   186:         & (if Proj_Name_Decls_Num = 1
   187:            then ""
   188:            else "__" & Image (Proj_Name_Decls_Num, 1))
   189:         & "__projection";
   190:
   191:       --  Parameter type and identifier
   192:       Param_Ty    : constant W_Type_Id :=
   193:         New_Named_Type (Name => Param_Ty_Name);
   194:       Param_Ident : constant W_Identifier_Id :=
   195:         Why.Gen.Names.New_Identifier (Name => "a", Typ => Param_Ty);
   196:
   197:       --  The access to the field to that the record is projected
   198:       Field_Access : constant W_Expr_Id :=
   199:         Why.Atree.Builders.New_Record_Access
   200:           (Name => +Param_Ident, Field => Field_Id);
   201:
   202:    begin
   203:       --  Update number of declarations of projection with name Proj_Name
   204:       if Proj_Name_Cursor = No_Element then
   205:          Projection_Names_Decls.Insert (Proj_Name, 2);
   206:       else
   207:          Projection_Names_Decls (Proj_Name) := Proj_Name_Decls_Num + 1;
   208:       end if;
   209:
   210:       Emit
   211:         (Th,
   212:          Why.Atree.Builders.New_Function_Decl
   213:            (Domain      => EW_Term,
   214:             Name        =>
   215:               Why.Gen.Names.New_Identifier (Name => Proj_Fun_Name),
   216:             Binders     =>
   217:               (1 =>
   218:                  New_Binder
   219:                    (Domain   => EW_Prog,
   220:                     Name     => Param_Ident,
   221:                     Arg_Type => Param_Ty)),
   222:             Return_Type => Get_Type (+Field_Id),
   223:             Labels      => Labels,
   224:             Location    => No_Location,
   225:             Def         => Field_Access));
   226:
   227:       Emit_Projection_Metas (Th, Proj_Fun_Name);
   228:    end Emit_Record_Projection_Declaration;
   229:
   230:    ------------------------------
   231:    -- Emit_Ref_Type_Definition --
   232:    ------------------------------
   233:
   234:    procedure Emit_Ref_Type_Definition (Th : Theory_UC; Name : W_Name_Id) is
   235:       Field_Typ : constant W_Type_Id :=
   236:         New_Type (Type_Kind => EW_Abstract, Name => Name);
   237:    begin
   238:       Emit_Record_Declaration
   239:         (Th      => Th,
   240:          Name    => Ref_Append (Name),
   241:          Binders =>
   242:            (1 =>
   243:               (B_Name  => Content_Append (Name, Field_Typ),
   244:                Mutable => True,
   245:                others  => <>)));
   246:    end Emit_Ref_Type_Definition;
   247:
   248:    ---------------------------
   249:    -- New_Havoc_Declaration --
   250:    ---------------------------
   251:
   252:    function New_Havoc_Declaration (Name : W_Name_Id) return W_Declaration_Id is
   253:       Typ       : constant W_Type_Id :=
   254:         New_Type (Type_Kind => EW_Abstract, Name => Ref_Append (Name));
   255:       Havoc_Fun : constant W_Identifier_Id := Havoc_Append (Name);
   256:       X         : constant W_Identifier_Id :=
   257:         New_Identifier (Domain => EW_Prog, Name => "x", Typ => Typ);
   258:    begin
   259:       return
   260:         Why.Atree.Builders.New_Function_Decl
   261:           (Domain      => EW_Prog,
   262:            Name        => Havoc_Fun,
   263:            Binders     =>
   264:              (1 => New_Binder (Domain => EW_Prog, Name => X, Arg_Type => Typ)),
   265:            Effects     => New_Effects (Writes => (1 => X)),
   266:            Return_Type => EW_Unit_Type,
   267:            Labels      => Symbol_Sets.Empty_Set,
   268:            Location    => No_Location);
   269:    end New_Havoc_Declaration;
   270:
   271:    -------------------
   272:    -- New_Type_Decl --
   273:    -------------------
   274:
   275:    function New_Type_Decl (Name : String) return W_Declaration_Id is
   276:    begin
   277:       return
   278:         New_Type_Decl
   279:           (Name   => New_Name (Symb => NID (Name)),
   280:            Labels => Symbol_Sets.Empty_Set);
   281:    end New_Type_Decl;
   282:
   283:    function New_Type_Decl
   284:      (Name : W_Name_Id; Alias : W_Type_Id) return W_Declaration_Id is
   285:    begin
   286:       return
   287:         New_Type_Decl
   288:           (Name       => Name,
   289:            Labels     => Symbol_Sets.Empty_Set,
   290:            Definition =>
   291:              New_Transparent_Type_Definition
   292:                (Domain => EW_Prog, Type_Definition => Alias));
   293:    end New_Type_Decl;
   294:
   295: end Why.Gen.Decl;
```

## src/why/why-gen-expr.adb:147-157

```ada
   147:    function Apply_Modulus
   148:      (Op : N_Op; E : Type_Kind_Id; T : W_Expr_Id; Domain : EW_Domain)
   149:       return W_Expr_Id
   150:    is
   151:       Ty          : constant Type_Kind_Id := Retysp (E);
   152:       Modulus_Val : Uint;
   153:       BV_Type     : W_Type_Id;
   154:    begin
   155:       if not Is_Modular_Integer_Type (Ty) then
   156:          return T;
   157:       end if;
```

## src/why/why-gen-expr.adb:311-381

```ada
   311:    function Binding_For_Temp
   312:      (Ada_Node : Node_Id := Empty;
   313:       Domain   : EW_Domain;
   314:       Tmp      : W_Expr_Id;
   315:       Context  : W_Expr_Id) return W_Expr_Id
   316:    is
   317:       use Why_Node_Maps;
   318:       C : Why_Node_Maps.Cursor := Temp_Names_Map.Find (+Tmp);
   319:
   320:    begin
   321:       --  if Tmp is in the map, we really introduced a temp variable and need
   322:       --  to build a binding now.
   323:
   324:       if Has_Element (C) then
   325:          declare
   326:             E : constant W_Expr_Id := +Element (C);
   327:          begin
   328:             --  we delete the entry, so that the map doesn't grow too much.
   329:
   330:             Temp_Names_Map.Delete (C);
   331:
   332:             return
   333:               New_Typed_Binding
   334:                 (Ada_Node => Ada_Node,
   335:                  Domain   => Domain,
   336:                  Name     => +Tmp,
   337:                  Def      => E,
   338:                  Context  => Context);
   339:          end;
   340:
   341:       else
   342:          --  Otherwise Tmp is not a temp associated with an expression.
   343:          --  Presumably, no temp variable was actually created for it during
   344:          --  a call of New_Temp_For_Expr. We just return the context.
   345:
   346:          return Context;
   347:       end if;
   348:    end Binding_For_Temp;
   349:
   350:    ------------------------------
   351:    -- Bindings_For_Ref_Context --
   352:    ------------------------------
   353:
   354:    function Bindings_For_Ref_Context
   355:      (Expr : W_Expr_Id; Context : Ref_Context; Domain : EW_Domain)
   356:       return W_Expr_Id
   357:    is
   358:       Res : W_Expr_Id := Expr;
   359:    begin
   360:       for J of reverse Context loop
   361:          if J.Mutable then
   362:             pragma Assert (Domain in EW_Prog | EW_Pterm);
   363:             Res :=
   364:               New_Binding_Ref
   365:                 (Name    => J.Name,
   366:                  Def     => +J.Value,
   367:                  Context => +Res,
   368:                  Typ     => Get_Type (+Res));
   369:          else
   370:             Res :=
   371:               New_Typed_Binding
   372:                 (Name    => J.Name,
   373:                  Def     => +J.Value,
   374:                  Context => Res,
   375:                  Domain  => Domain);
   376:          end if;
   377:       end loop;
   378:       return Res;
   379:    end Bindings_For_Ref_Context;
   380:
   381:    --------------------------
```

## src/why/why-gen-expr.adb:982-1512

```ada
   982:    function Insert_Array_Conversion
   983:      (Domain         : EW_Domain;
   984:       Ada_Node       : Node_Id := Empty;
   985:       Expr           : W_Expr_Id;
   986:       To             : W_Type_Id;
   987:       Need_Check     : Boolean := False;
   988:       Force_No_Slide : Boolean := False;
   989:       Is_Qualif      : Boolean := False;
   990:       No_Init        : Boolean := False) return W_Expr_Id
   991:    is
   992:       From     : constant W_Type_Id := Get_Type (Expr);
   993:       To_Ent   : constant Entity_Id := Get_Ada_Node (+To);
   994:       From_Ent : constant Entity_Id := Get_Ada_Node (+From);
   995:       Dim      : constant Positive := Positive (Number_Dimensions (To_Ent));
   996:
   997:       function Insert_Array_Index_Check
   998:         (Expr : W_Term_Id; To_Ent : Entity_Id) return W_Prog_Id;
   999:
  1000:       function Insert_Length_Check
  1001:         (Expr : W_Term_Id; To_Ent : Entity_Id) return W_Prog_Id;
  1002:
  1003:       function Insert_Array_Range_Check
  1004:         (Expr : W_Term_Id; To_Ent : Entity_Id) return W_Prog_Id;
  1005:
  1006:       ------------------------------
  1007:       -- Insert_Array_Range_Check --
  1008:       ------------------------------
  1009:
  1010:       function Insert_Array_Range_Check
  1011:         (Expr : W_Term_Id; To_Ent : Entity_Id) return W_Prog_Id
  1012:       is
  1013:          Check : W_Pred_Id;
  1014:
  1015:       begin
  1016:          pragma Assert (not Is_Static_Array_Type (To_Ent));
  1017:
  1018:          --  For dynamic types, use dynamic_property
  1019:
  1020:          Check :=
  1021:            +New_Dynamic_Property
  1022:               (Domain => EW_Pred, Ty => To_Ent, Expr => Expr);
  1023:
  1024:          return
  1025:            New_Located_Assert (Ada_Node, Check, VC_Range_Check, EW_Assert);
  1026:       end Insert_Array_Range_Check;
  1027:
  1028:       ------------------------------
  1029:       -- Insert_Array_Index_Check --
  1030:       ------------------------------
  1031:
  1032:       function Insert_Array_Index_Check
  1033:         (Expr : W_Term_Id; To_Ent : Entity_Id) return W_Prog_Id
  1034:       is
  1035:          Constrained : constant Boolean := Is_Constrained (To_Ent);
  1036:          Check       : W_Pred_Id;
  1037:          Dim         : constant Positive :=
  1038:            Positive (Number_Dimensions (To_Ent));
  1039:          Eqs         : W_Pred_Array (1 .. 2 * Dim);
  1040:          Count       : Natural := 0;
  1041:          Check_Info  : Check_Info_Type := New_Check_Info;
  1042:       begin
  1043:          for I in 1 .. Dim loop
  1044:
  1045:             --  If To_Ent is constrained or the current index has a fixed
  1046:             --  lower bound, add constraint on the first bound.
  1047:
  1048:             if Constrained
  1049:               or else
  1050:                 Is_Fixed_Lower_Bound_Index_Subtype (Nth_Index_Type (To_Ent, I))
  1051:             then
  1052:                Count := Count + 1;
  1053:                Eqs (Count) :=
  1054:                  New_Comparison
  1055:                    (Symbol => Why_Eq,
  1056:                     Left   =>
  1057:                       Get_Array_Attr
  1058:                         (Expr => Expr, Attr => Attribute_First, Dim => I),
  1059:                     Right  =>
  1060:                       Get_Array_Attr
  1061:                         (Domain => EW_Term,
  1062:                          Attr   => Attribute_First,
  1063:                          Dim    => I,
  1064:                          Ty     => To_Ent));
  1065:             end if;
  1066:
  1067:             --  If To_Ent is constrained add constraint on the last bound
  1068:
  1069:             if Constrained then
  1070:                Count := Count + 1;
  1071:                Eqs (Count) :=
  1072:                  New_Comparison
  1073:                    (Symbol => Why_Eq,
  1074:                     Left   =>
  1075:                       Get_Array_Attr
  1076:                         (Expr => Expr, Attr => Attribute_Last, Dim => I),
  1077:                     Right  =>
  1078:                       Get_Array_Attr
  1079:                         (Domain => EW_Term,
  1080:                          Attr   => Attribute_Last,
  1081:                          Dim    => I,
  1082:                          Ty     => To_Ent));
  1083:             end if;
  1084:          end loop;
  1085:
  1086:          Check := New_And_Pred (Eqs (1 .. Count));
  1087:
  1088:          --  For a simple one-dimensional array, record the index type used for
  1089:          --  the index check associated with the Ada node.
  1090:
  1091:          if Dim = 1 then
  1092:             Check_Info.Fix_Info.Range_Check_Ty := Nth_Index_Type (To_Ent, 1);
  1093:          end if;
  1094:
  1095:          return
  1096:            New_Located_Assert
  1097:              (Ada_Node, Check, VC_Index_Check, EW_Assert, Check_Info);
  1098:       end Insert_Array_Index_Check;
  1099:
  1100:       -------------------------
  1101:       -- Insert_Length_Check --
  1102:       -------------------------
  1103:
  1104:       function Insert_Length_Check
  1105:         (Expr : W_Term_Id; To_Ent : Entity_Id) return W_Prog_Id
  1106:       is
  1107:          Check : constant W_Pred_Id :=
  1108:            New_Length_Equality
  1109:              (Left_Arr => Expr,
  1110:               Right    => To_Ent,
  1111:               Dim      => Positive (Number_Dimensions (To_Ent)));
  1112:
  1113:       begin
  1114:          if Is_True_Boolean (+Check) then
  1115:             return +Void;
  1116:          else
  1117:             return
  1118:               New_Located_Assert (Ada_Node, Check, VC_Length_Check, EW_Assert);
  1119:          end if;
  1120:       end Insert_Length_Check;
  1121:
  1122:       Need_Slide : constant Boolean := Needs_Slide (From_Ent, To_Ent);
  1123:       Sliding    : constant Boolean :=
  1124:         not Force_No_Slide and then Need_Slide and then not Is_Qualif;
  1125:       Arr_Init   : W_Expr_Id := Expr;
  1126:       Arr_Expr   : W_Term_Id;
  1127:       T          : W_Expr_Id;
  1128:
  1129:       Pred_Check : constant Boolean :=
  1130:         Domain = EW_Prog
  1131:         and then not No_Init
  1132:         and then Need_Check
  1133:         and then Has_Predicates (Get_Ada_Node (+To))
  1134:         and then not Is_Call_Arg_To_Predicate_Function (Ada_Node);
  1135:       Init_Check : constant Boolean :=
  1136:         Domain = EW_Prog
  1137:         and then not No_Init
  1138:         and then Need_Check
  1139:         and then Is_Init_Wrapper_Type (From)
  1140:         and then not Is_Init_Wrapper_Type (To);
  1141:
  1142:       On_Wrapper : constant Boolean :=
  1143:         Is_Init_Wrapper_Type (From) and Is_Init_Wrapper_Type (To);
  1144:       From_Split : constant W_Type_Id :=
  1145:         (if Is_Static_Array_Type (From_Ent)
  1146:          then From
  1147:          else EW_Split (From_Ent, Relaxed_Init => On_Wrapper));
  1148:       To_Split   : constant W_Type_Id :=
  1149:         (if Is_Static_Array_Type (To_Ent)
  1150:          then To
  1151:          else EW_Split (To_Ent, Relaxed_Init => On_Wrapper));
  1152:
  1153:       --  Beginning of processing for Insert_Array_Conversion
  1154:
  1155:    begin
  1156:       if To_Ent = From_Ent
  1157:         and then Is_Init_Wrapper_Type (From) = Is_Init_Wrapper_Type (To)
  1158:       then
  1159:
  1160:          --  No range check needed
  1161:
  1162:          return Expr;
  1163:       end if;
  1164:
  1165:       --  Check for initialization if needed
  1166:
  1167:       if Init_Check then
  1168:          Arr_Init :=
  1169:            Insert_Initialization_Check
  1170:              (Ada_Node           => Ada_Node,
  1171:               E                  => From_Ent,
  1172:               Name               => Arr_Init,
  1173:               Domain             => Domain,
  1174:               Exclude_Components => Relaxed);
  1175:       end if;
  1176:
  1177:       Arr_Expr := New_Temp_For_Expr (Arr_Init);
  1178:
  1179:       --  1 - Put array in split form. If reconstruction is needed, also store
  1180:       --  appropriate bounds in Args.
  1181:
  1182:       declare
  1183:          Args    : W_Expr_Array (1 .. 1 + 2 * Dim);
  1184:          Arg_Ind : Positive := 1;
  1185:
  1186:          Split_T : W_Expr_Id;
  1187:          --  Placeholder to store the value of T before reconstruction. It is
  1188:          --  used to generate the predicate check.
  1189:
  1190:          Need_Elt_Conv : constant Boolean :=
  1191:            Retysp (Component_Type (To_Ent))
  1192:            /= Retysp (Component_Type (From_Ent));
  1193:          --  We need an element conversion if To and From do not have the
  1194:          --  same elements.
  1195:
  1196:       begin
  1197:          --  Insert sliding if needed
  1198:
  1199:          if Sliding then
  1200:             declare
  1201:                Args    : W_Expr_Array (1 .. 1 + 2 * Dim);
  1202:                Arg_Ind : Positive := 1;
  1203:                To_Idx  : Entity_Id := First_Index (To_Ent);
  1204:             begin
  1205:                Add_Map_Arg (Domain, Args, +Arr_Expr, Arg_Ind);
  1206:                for I in 1 .. Dim loop
  1207:                   Add_Attr_Arg
  1208:                     (Domain, Args, +Arr_Expr, Attribute_First, I, Arg_Ind);
  1209:
  1210:                   if Is_Constrained (To_Ent)
  1211:                     or else Is_Fixed_Lower_Bound_Index_Subtype (Etype (To_Idx))
  1212:                   then
  1213:                      Add_Attr_Arg
  1214:                        (Domain, Args, To_Ent, Attribute_First, I, Arg_Ind);
  1215:                   else
  1216:                      Add_Attr_Arg
  1217:                        (Domain, Args, +Arr_Expr, Attribute_First, I, Arg_Ind);
  1218:                   end if;
  1219:
  1220:                   Next_Index (To_Idx);
  1221:                end loop;
  1222:
  1223:                T :=
  1224:                  New_Call
  1225:                    (Domain => Domain,
  1226:                     Name   =>
  1227:                       Get_Array_Theory (From_Ent, Is_Init_Wrapper_Type (From))
  1228:                         .Slide,
  1229:                     Args   => Args,
  1230:                     Typ    => Get_Type (Args (1)));
  1231:             end;
  1232:
  1233:             --  If To isn't a statically constrained array type, fill the Args
  1234:             --  array to allow reconstruction.
  1235:             --  Here, we must get attributes from the type as the slided
  1236:             --  expression has no registered bounds.
  1237:
  1238:             if not Is_Static_Array_Type (To_Ent) then
  1239:                Arg_Ind := 1;
  1240:                Add_Map_Arg (Domain, Args, T, Arg_Ind);
  1241:
  1242:                for I in 1 .. Dim loop
  1243:
  1244:                   --  If To_Ent is constrained or its Ith index has a fixed
  1245:                   --  lower bound, the index has been slided. Compute the
  1246:                   --  bounds from the expected type.
  1247:
  1248:                   if Is_Constrained (To_Ent)
  1249:                     or else
  1250:                       Is_Fixed_Lower_Bound_Index_Subtype
  1251:                         (Nth_Index_Type (To_Ent, I))
  1252:                   then
  1253:
  1254:                      --  The first bound can be queried directly
  1255:
  1256:                      Add_Attr_Arg
  1257:                        (Domain, Args, To_Ent, Attribute_First, I, Arg_Ind);
  1258:
  1259:                      --  If To_Ent is constrained the last bound can be queried
  1260:                      --  directly.
  1261:
  1262:                      if Is_Constrained (To_Ent) then
  1263:                         Add_Attr_Arg
  1264:                           (Domain, Args, To_Ent, Attribute_Last, I, Arg_Ind);
  1265:
  1266:                      --  Otherwise, we recompute it from the first bound and
  1267:                      --  the length of the converted array. A range check might
  1268:                      --  be emitted if we are in the program domain.
  1269:
  1270:                      else
  1271:                         declare
  1272:                            Target      : constant Entity_Id :=
  1273:                              Nth_Index_Type (To_Ent, I);
  1274:                            Length_Expr : constant W_Expr_Id :=
  1275:                              Build_Length_Expr (Domain, +Arr_Expr, I);
  1276:                            First_Expr  : constant W_Expr_Id :=
  1277:                              Args (Arg_Ind - 1);
  1278:                            Last_Expr   : constant W_Expr_Id :=
  1279:                              New_Discrete_Add
  1280:                                (Domain => Domain,
  1281:                                 Left   =>
  1282:                                   New_Discrete_Substract
  1283:                                     (Domain => Domain,
  1284:                                      Left   => First_Expr,
  1285:                                      Right  =>
  1286:                                        New_Discrete_Constant
  1287:                                          (Value => Uint_1, Typ => EW_Int_Type),
  1288:                                      Typ    => EW_Int_Type),
  1289:                                 Right  => Length_Expr,
  1290:                                 Typ    => EW_Int_Type);
  1291:                            --  Expression of the last index. Computation is
  1292:                            --  done on mathematical integers to avoid overflows
  1293:                            --  and wrap-arounds.
  1294:
  1295:                         begin
  1296:                            --  Convert Last_Expr to the expected type
  1297:
  1298:                            Args (Arg_Ind) :=
  1299:                              Insert_Simple_Conversion
  1300:                                (Domain => Domain,
  1301:                                 Expr   => Last_Expr,
  1302:                                 To     => Get_Type (First_Expr));
  1303:
  1304:                            --  If we are in the EW_Prog domain, also introduce
  1305:                            --  a range check to make sure that Last_Expr is
  1306:                            --  in the expected type.
  1307:
  1308:                            if Domain = EW_Prog and then Need_Check then
  1309:                               Args (Arg_Ind) :=
  1310:                                 +Sequence
  1311:                                    (New_Ignore
  1312:                                       (Ada_Node => Ada_Node,
  1313:                                        Prog     =>
  1314:                                          New_Conditional
  1315:                                            (Ada_Node  => Ada_Node,
  1316:                                             Condition =>
  1317:                                               +New_Comparison
  1318:                                                  (Symbol => Int_Infix_Le,
  1319:                                                   Domain => Domain,
  1320:                                                   Left   =>
  1321:                                                     +Insert_Scalar_Conversion
  1322:                                                        (Domain => Domain,
  1323:                                                         Expr   => First_Expr,
  1324:                                                         To     => EW_Int_Type),
  1325:                                                   Right  => Last_Expr),
  1326:                                             Then_Part =>
  1327:                                               Do_Range_Check
  1328:                                                 (Ada_Node   => Ada_Node,
  1329:                                                  Ty         => Target,
  1330:                                                  W_Expr     => Last_Expr,
  1331:                                                  Check_Kind => RCK_Range),
  1332:                                             Else_Part =>
  1333:                                               Do_Range_Check
  1334:                                                 (Ada_Node   => Ada_Node,
  1335:                                                  Ty         =>
  1336:                                                    Base_Retysp (Target),
  1337:                                                  W_Expr     => Last_Expr,
  1338:                                                  Check_Kind => RCK_Range),
  1339:                                             Typ       =>
  1340:                                               Get_Type (First_Expr))),
  1341:                                     +Args (Arg_Ind));
  1342:                            end if;
  1343:
  1344:                            Arg_Ind := Arg_Ind + 1;
  1345:                         end;
  1346:                      end if;
  1347:
  1348:                   --  The index has not been slided, we keep the bounds of the
  1349:                   --  converted expression.
  1350:
  1351:                   else
  1352:                      Add_Attr_Arg
  1353:                        (Domain, Args, +Arr_Expr, Attribute_First, I, Arg_Ind);
  1354:                      Add_Attr_Arg
  1355:                        (Domain, Args, +Arr_Expr, Attribute_Last, I, Arg_Ind);
  1356:                   end if;
  1357:                end loop;
  1358:             end if;
  1359:
  1360:          --  If reconstruction is needed, fill the Args array. T is the
  1361:          --  first element of Args.
  1362:
  1363:          elsif not Is_Static_Array_Type (To_Ent) then
  1364:             Add_Array_Arg (Domain, Args, +Arr_Expr, Arg_Ind);
  1365:             T := Args (1);
  1366:
  1367:          --  Both are statically constrained, T is Arr_Expr
  1368:
  1369:          elsif Is_Static_Array_Type (From_Ent) then
  1370:             T := +Arr_Expr;
  1371:
  1372:          --  To is in constrained but not From. Convert From to base.
  1373:
  1374:          else
  1375:             T := Array_Convert_To_Base (Domain => Domain, Ar => +Arr_Expr);
  1376:          end if;
  1377:
  1378:          --  2. If From has relaxed initialization and we are not doing the
  1379:          --  conversion on init wrappers, add a conversion from the wrapper
  1380:          --  type.
  1381:
  1382:          if Is_Init_Wrapper_Type (From) and then not On_Wrapper then
  1383:             T :=
  1384:               New_Call
  1385:                 (Ada_Node => Ada_Node,
  1386:                  Domain   => Domain,
  1387:                  Name     => Get_Array_Of_Wrapper_Name (From_Ent),
  1388:                  Args     => (1 => T),
  1389:                  Typ      => From_Split);
  1390:          end if;
  1391:
  1392:          --  3. To_Ent and From_Ent do not have the same component type, apply
  1393:          --  the appropriate conversion.
  1394:
  1395:          if Need_Elt_Conv then
  1396:             T :=
  1397:               Insert_Single_Conversion
  1398:                 (Ada_Node => Empty,
  1399:                  Domain   => Domain,
  1400:                  To       => To_Split,
  1401:                  Expr     => T);
  1402:
  1403:          --  No actual why call or conversion may have been inserted, but we
  1404:          --  still need to change the type of the Why AST node. We do that by
  1405:          --  adding a dummy node.
  1406:
  1407:          else
  1408:             T :=
  1409:               New_Label
  1410:                 (Labels => Symbol_Sets.Empty_Set,
  1411:                  Def    => T,
  1412:                  Domain => Domain,
  1413:                  Typ    => To_Split);
  1414:          end if;
  1415:
  1416:          --  Store the split value of T before attempting reconstruction. To
  1417:          --  avoid introducing duplicated checks, use a temporary.
  1418:
  1419:          T := New_Temp_For_Expr (T);
  1420:          Split_T := T;
  1421:
  1422:          --  4. If To has relaxed initialization and the conversion is not done
  1423:          --  on wrapper types, go to the wrapper now.
  1424:
  1425:          if Is_Init_Wrapper_Type (To) and then not On_Wrapper then
  1426:             T :=
  1427:               New_Call
  1428:                 (Ada_Node => Ada_Node,
  1429:                  Domain   => Domain,
  1430:                  Name     => Get_Array_To_Wrapper_Name (To_Ent),
  1431:                  Args     => (1 => T),
  1432:                  Typ      => EW_Split (To_Ent, Relaxed_Init => True));
  1433:          end if;
  1434:
  1435:          --  5. Reconstruct the array if needed
  1436:
  1437:          if not Is_Static_Array_Type (To_Ent) then
  1438:             Args (1) := T;
  1439:             T :=
  1440:               New_Call
  1441:                 (Domain => Domain,
  1442:                  Name   =>
  1443:                    E_Symb (To_Ent, WNE_Of_Array, Is_Init_Wrapper_Type (To)),
  1444:                  Args   => Args,
  1445:                  Typ    => To);
  1446:          end if;
  1447:
  1448:          --  6. Insert length, range, index, and predicate check when necessary
  1449:
  1450:          if Domain = EW_Prog and then Need_Check then
  1451:             declare
  1452:                Check_Type : constant Entity_Id := To_Ent;
  1453:             begin
  1454:                if Is_Qualif and then Need_Slide then
  1455:                   T :=
  1456:                     +Sequence
  1457:                        (Insert_Array_Index_Check (Arr_Expr, Check_Type), +T);
  1458:                elsif Is_Constrained (Check_Type) then
  1459:                   T :=
  1460:                     +Sequence (Insert_Length_Check (Arr_Expr, Check_Type), +T);
  1461:                elsif not Sliding then
  1462:                   T :=
  1463:                     +Sequence
  1464:                        (Insert_Array_Range_Check (+Arr_Expr, Check_Type), +T);
  1465:                else
  1466:                   --  For FLB types, the check that the last bound is in the
  1467:                   --  index type is performed during the sliding.
  1468:
  1469:                   pragma
  1470:                     Assert (Is_Fixed_Lower_Bound_Array_Subtype (Check_Type));
  1471:                end if;
  1472:
  1473:                --  If the target type has a direct or inherited predicate,
  1474:                --  generate a corresponding check. Do not generate a predicate
  1475:                --  check for an internal call to a parent predicate function
  1476:                --  inside the definition of a predicate function.
  1477:
  1478:                if Pred_Check then
  1479:
  1480:                   Args (1) := Split_T;
  1481:
  1482:                   declare
  1483:                      Rec_Tmp : constant W_Expr_Id :=
  1484:                        (if not Is_Static_Array_Type (To_Ent)
  1485:                         then
  1486:                           New_Call
  1487:                             (Domain => Domain,
  1488:                              Name   =>
  1489:                                E_Symb (To_Ent, WNE_Of_Array, On_Wrapper),
  1490:                              Args   => Args,
  1491:                              Typ    => EW_Abstract (To_Ent, On_Wrapper))
  1492:                         else Args (1));
  1493:                      --  If it is in split form, the array should be
  1494:                      --  reconstructed.
  1495:                   begin
  1496:                      T :=
  1497:                        +Sequence
  1498:                           (New_Predicate_Check (Ada_Node, Check_Type, Rec_Tmp),
  1499:                            +T);
  1500:                   end;
  1501:                end if;
  1502:             end;
  1503:          end if;
  1504:
  1505:          T :=
  1506:            Binding_For_Temp (Domain => Domain, Tmp => Split_T, Context => T);
  1507:       end;
  1508:
  1509:       T := Binding_For_Temp (Domain => Domain, Tmp => +Arr_Expr, Context => T);
  1510:
  1511:       return T;
  1512:    end Insert_Array_Conversion;
```

## src/why/why-gen-expr.adb:1518-1648

```ada
  1518:    function Insert_Checked_Conversion
  1519:      (Ada_Node : Node_Id;
  1520:       Domain   : EW_Domain;
  1521:       Expr     : W_Expr_Id;
  1522:       To       : W_Type_Id;
  1523:       Lvalue   : Boolean := False;
  1524:       No_Init  : Boolean := False) return W_Expr_Id
  1525:    is
  1526:
  1527:       --  When converting between Ada types, detect cases where a check is not
  1528:       --  needed.
  1529:
  1530:       From         : constant W_Type_Id := Get_Type (Expr);
  1531:       Check_Needed : Boolean;
  1532:       T            : W_Expr_Id := Expr;
  1533:
  1534:    begin
  1535:       --  A string literal gets typed with a subtype of the expected type, even
  1536:       --  if it does not respect the associated predicate of the expected type.
  1537:       --  As a result, do not rely on the call to Check_Needed_On_Conversion in
  1538:       --  that case.
  1539:       --  If From has relaxed initialization and not To, we may need an
  1540:       --  initialization check.
  1541:
  1542:       Check_Needed :=
  1543:         (if Get_Type_Kind (From) in EW_Abstract | EW_Split
  1544:            and then Get_Type_Kind (To) in EW_Abstract | EW_Split
  1545:            and then
  1546:              not (Nkind (Ada_Node) = N_String_Literal
  1547:                   and then Has_Predicates (Get_Ada_Node (+To)))
  1548:          then
  1549:            Check_Needed_On_Conversion
  1550:              (From => Get_Ada_Node (+From), To => Get_Ada_Node (+To))
  1551:            or else Is_Choice_Of_Unconstrained_Array_Update (Ada_Node)
  1552:            or else
  1553:              (Is_Init_Wrapper_Type (From)
  1554:               and then not Is_Init_Wrapper_Type (To)
  1555:               and then not No_Init)
  1556:          else True);
  1557:
  1558:       if Is_Private_Conversion (From, To)
  1559:         or else Is_Record_Conversion (From, To)
  1560:       then
  1561:          --  Conversion between record types need to go through their common
  1562:          --  root record type. A discriminant check may be needed. Currently
  1563:          --  perform it on all discriminant record types, as the flag
  1564:          --  Do_Discriminant_Check is not set appropriately by the frontend on
  1565:          --  type conversions.
  1566:          --  A tag check may also be needed if we convert from a classwide type
  1567:          --  to a type which is not an ancestor. As for the discriminant check,
  1568:          --  we always perform it.
  1569:
  1570:          T :=
  1571:            Insert_Record_Conversion
  1572:              (Domain     => Domain,
  1573:               Ada_Node   => Ada_Node,
  1574:               Expr       => T,
  1575:               To         => To,
  1576:               Need_Check => Check_Needed,
  1577:               No_Init    => No_Init);
  1578:
  1579:       elsif Is_Array_Conversion (From, To) then
  1580:          --  The flag Do_Length_Check is not set consistently in the
  1581:          --  frontend, so check every array conversion.
  1582:
  1583:          T :=
  1584:            Insert_Array_Conversion
  1585:              (Domain     => Domain,
  1586:               Ada_Node   => Ada_Node,
  1587:               Expr       => T,
  1588:               To         => To,
  1589:               Need_Check => Check_Needed,
  1590:               No_Init    => No_Init);
  1591:
  1592:       elsif Is_Subp_Pointer_Conversion (From, To) then
  1593:          T :=
  1594:            Insert_Subp_Pointer_Conversion
  1595:              (Domain     => Domain,
  1596:               Ada_Node   => Ada_Node,
  1597:               Expr       => T,
  1598:               To         => To,
  1599:               Need_Check => Check_Needed,
  1600:               No_Init    => No_Init);
  1601:
  1602:       elsif Is_Pointer_Conversion (From, To) then
  1603:
  1604:          T :=
  1605:            Insert_Pointer_Conversion
  1606:              (Domain     => Domain,
  1607:               Ada_Node   => Ada_Node,
  1608:               Expr       => T,
  1609:               To         => To,
  1610:               Need_Check => Check_Needed,
  1611:               No_Init    => No_Init);
  1612:
  1613:       --  Conversion between scalar types
  1614:
  1615:       else
  1616:          declare
  1617:             --  Flag for a range check; set if the expression node has
  1618:             --  Do_Range_Check flag set, if it is a type conversion whose flag
  1619:             --  Do_Overflow_Check is set. (See description of these flags in
  1620:             --  sinfo.ads for details.)
  1621:
  1622:             --  Also, we special case a type conversion whose expression has a
  1623:             --  range check, when this appears as the actual of an out/in-out
  1624:             --  parameter of a call, because the current check machinery does
  1625:             --  not allow detecting the necessary check on the out copy.
  1626:             --  ??? It would be good if such special casing were closer to the
  1627:             --  code which handles the call
  1628:
  1629:             Do_Check : constant Boolean :=
  1630:               Domain = EW_Prog
  1631:               and then Check_Needed
  1632:               and then Do_Check_On_Scalar_Conversion (Ada_Node);
  1633:
  1634:          begin
  1635:             T :=
  1636:               Insert_Scalar_Conversion
  1637:                 (Domain   => Domain,
  1638:                  Ada_Node => Ada_Node,
  1639:                  Expr     => T,
  1640:                  To       => To,
  1641:                  Do_Check => Do_Check,
  1642:                  Lvalue   => Lvalue,
  1643:                  No_Init  => No_Init);
  1644:          end;
  1645:       end if;
  1646:
  1647:       return T;
  1648:    end Insert_Checked_Conversion;
```

## src/why/why-gen-expr.adb:1956-1996

```ada
  1956:    function Insert_Cnt_Loc_Label
  1957:      (Ada_Node : Node_Id; E : W_Expr_Id; Is_Loop_Head : Boolean := False)
  1958:       return W_Expr_Id is
  1959:    begin
  1960:       if Present (Ada_Node) and then Safe_First_Sloc (Ada_Node) > No_Location
  1961:       then
  1962:          declare
  1963:             --  This is intentionnally not generated in case of Implicit
  1964:             --  invariant (no explicit Loop_Invariant in the loop).
  1965:             Marker : constant Symbol :=
  1966:               (if Is_Loop_Head and then Nkind (Ada_Node) = N_Pragma
  1967:                then NID ("Loop" & Node_Id'Image (Ada_Node))
  1968:                else No_Symbol);
  1969:          begin
  1970:             return
  1971:               New_Loc_Label
  1972:                 (Ada_Node => Get_Ada_Node (+E),
  1973:                  Sloc     => Safe_First_Sloc (Ada_Node),
  1974:                  Domain   => Get_Domain (+E),
  1975:                  Def      => E,
  1976:                  Marker   => Marker);
  1977:          end;
  1978:       else
  1979:          return E;
  1980:       end if;
  1981:    end Insert_Cnt_Loc_Label;
  1982:
  1983:    --------------------------------------
  1984:    -- Insert_Conversion_To_Rep_No_Bool --
  1985:    --------------------------------------
  1986:
  1987:    function Insert_Conversion_To_Rep_No_Bool
  1988:      (Domain : EW_Domain; Expr : W_Expr_Id) return W_Expr_Id
  1989:    is
  1990:       Rep_Typ : constant W_Type_Id := Base_Why_Type_No_Bool (Expr);
  1991:    begin
  1992:       return
  1993:         Insert_Simple_Conversion
  1994:           (Domain => Domain, Expr => Expr, To => Rep_Typ);
  1995:    end Insert_Conversion_To_Rep_No_Bool;
  1996:
```

## src/why/why-gen-expr.adb:2349-2391

```ada
  2349:       --  Range check does not come from a modular type. Everything is done in
  2350:       --  the representation type, either int for scalar and fixed-point types
  2351:       --  or real for floating-point types.
  2352:
  2353:       else
  2354:          W_Fun := Range_Check_Name (Ty, Check_Kind);
  2355:
  2356:          --  If the bounds are dynamic, we need to retrieve them for the check,
  2357:          --  by calling Args_For_Scalar_Dynamic_Property.
  2358:
  2359:          if Type_Is_Modeled_As_Base (Ty) then
  2360:             declare
  2361:                W_Tmp  : constant W_Expr_Id := New_Temp_For_Expr (W_Expr);
  2362:                W_Args : constant W_Expr_Array :=
  2363:                  Args_For_Scalar_Dynamic_Property (Ty, W_Tmp, EW_Pterm);
  2364:             begin
  2365:                Result :=
  2366:                  New_VC_Call
  2367:                    (Ada_Node   => Ada_Node,
  2368:                     Name       => W_Fun,
  2369:                     Progs      => W_Args,
  2370:                     Reason     => Reason,
  2371:                     Check_Info => Check_Info,
  2372:                     Typ        => Get_Type (W_Expr));
  2373:                Result :=
  2374:                  +Binding_For_Temp
  2375:                     (Domain => EW_Prog, Tmp => W_Tmp, Context => +Result);
  2376:             end;
  2377:
  2378:          --  If the bounds are static, the range checking function knows them
  2379:
  2380:          else
  2381:             Result :=
  2382:               New_VC_Call
  2383:                 (Ada_Node   => Ada_Node,
  2384:                  Name       => W_Fun,
  2385:                  Progs      => (1 => +W_Expr),
  2386:                  Reason     => Reason,
  2387:                  Check_Info => Check_Info,
  2388:                  Typ        => Get_Type (W_Expr));
  2389:          end if;
  2390:       end if;
  2391:
```

## src/why/why-gen-expr.adb:2399-2910

```ada
  2399:    function Insert_Scalar_Conversion
  2400:      (Domain   : EW_Domain;
  2401:       Ada_Node : Node_Id := Empty;
  2402:       Expr     : W_Expr_Id;
  2403:       To       : W_Type_Id;
  2404:       Do_Check : Boolean := False;
  2405:       Lvalue   : Boolean := False;
  2406:       No_Init  : Boolean := False) return W_Expr_Id
  2407:    is
  2408:       From : constant W_Type_Id := Get_Type (Expr);
  2409:
  2410:       --  Do not generate a predicate check for an internal call to a parent
  2411:       --  predicate function inside the definition of a predicate function.
  2412:       Do_Predicate_Check : constant Boolean :=
  2413:         Present (Get_Ada_Node (+To))
  2414:         and then Has_Predicates (Get_Ada_Node (+To))
  2415:         and then Get_Ada_Node (+To) /= Get_Ada_Node (+From)
  2416:         and then not Is_Call_Arg_To_Predicate_Function (Ada_Node);
  2417:
  2418:       --  Type and kind for the range check
  2419:       Range_Type : Entity_Id := Empty;
  2420:       Check_Kind : Scalar_Check_Kind := RCK_Range;
  2421:
  2422:       --  Start of processing for Insert_Scalar_Conversion
  2423:
  2424:    begin
  2425:       --  Do nothing when
  2426:       --  1. From = To, and
  2427:       --  2. no rounding needed, and
  2428:       --  3. no predicate check needed, and
  2429:       --  4. a) no range check needed, _or_
  2430:       --     b) check is flagged but the base type is the one reserved for
  2431:       --        Standard.Boolean, so check does not need to be inserted.
  2432:       --        (Other boolean types in Ada have a base type of EW_Int.)
  2433:
  2434:       if Eq_Base (To, From)
  2435:         and then not Do_Predicate_Check
  2436:         and then (not Do_Check or else To = EW_Bool_Type)
  2437:       then
  2438:          return Expr;
  2439:       end if;
  2440:
  2441:       --  Retrieve range check information
  2442:
  2443:       if Do_Check then
  2444:          Check_Kind := Get_Range_Check_Info (Ada_Node);
  2445:
  2446:          Range_Type := Get_Ada_Node (+To);
  2447:
  2448:          --  Builtin scalar types might not have an Ada node. For standard
  2449:          --  booleans, we can use Standard_Boolean. Mathematical integers do
  2450:          --  not have a bound, so not having a range type is fine. For other
  2451:          --  types, check that no range checks are necessary.
  2452:
  2453:          if No (Range_Type) then
  2454:             if To = EW_Bool_Type then
  2455:                Range_Type := Standard_Boolean;
  2456:             elsif To = EW_Int_Type then
  2457:                null;
  2458:             else
  2459:                pragma Assert (Base_Why_Type (+From) = To);
  2460:             end if;
  2461:          end if;
  2462:       end if;
  2463:
  2464:       return
  2465:         Insert_Scalar_Conversion
  2466:           (Domain     => Domain,
  2467:            Ada_Node   => Ada_Node,
  2468:            Expr       => Expr,
  2469:            To         => To,
  2470:            Range_Type => Range_Type,
  2471:            Check_Kind => Check_Kind,
  2472:            Lvalue     => Lvalue,
  2473:            No_Init    => No_Init);
  2474:    end Insert_Scalar_Conversion;
  2475:
  2476:    function Insert_Scalar_Conversion
  2477:      (Domain     : EW_Domain;
  2478:       Ada_Node   : Node_Id := Empty;
  2479:       Expr       : W_Expr_Id;
  2480:       To         : W_Type_Id;
  2481:       Range_Type : Entity_Id;
  2482:       Check_Kind : Scalar_Check_Kind;
  2483:       Lvalue     : Boolean := False;
  2484:       No_Init    : Boolean := False;
  2485:       Skip_Pred  : Boolean := False) return W_Expr_Id
  2486:    is
  2487:       From    : constant W_Type_Id := Get_Type (Expr);
  2488:       To_Conc : constant W_Type_Id :=
  2489:         (if not Is_Init_Wrapper_Type (To)
  2490:          then To
  2491:          elsif Get_Type_Kind (To) = EW_Abstract
  2492:          then EW_Abstract (Get_Ada_Node (+To))
  2493:          elsif Get_Type_Kind (To) = EW_Builtin
  2494:          then EW_Bool_Type
  2495:          else EW_Split (Get_Ada_Node (+To)));
  2496:       --  Concrete type for To if To is a wrapper for initialization
  2497:
  2498:       --  Do not generate a predicate check for an internal call to a parent
  2499:       --  predicate function inside the definition of a predicate function.
  2500:       Do_Predicate_Check : constant Boolean :=
  2501:         Present (Ada_Node)
  2502:         and then not No_Init
  2503:         and then Present (Get_Ada_Node (+To))
  2504:         and then Has_Predicates (Get_Ada_Node (+To))
  2505:         and then Get_Ada_Node (+To) /= Get_Ada_Node (+From)
  2506:         and then not Skip_Pred
  2507:         and then not Is_Call_Arg_To_Predicate_Function (Ada_Node);
  2508:
  2509:       --  Current result expression
  2510:       Result : W_Expr_Id := Expr;
  2511:
  2512:       --  Current type of the result expression
  2513:       Cur : W_Type_Id := From;
  2514:
  2515:       --  Set to True after range check has been applied
  2516:       Range_Check_Applied : Boolean := False;
  2517:
  2518:       --  Start of processing for Insert_Scalar_Conversion
  2519:
  2520:    begin
  2521:       --  If the check is a range check on a floating-point type, and we can
  2522:       --  determine that the expression is always within bounds, then issue
  2523:       --  a check always true. Do not apply this optimization to actual
  2524:       --  parameters of calls, as Determine_Range_R does not work for out and
  2525:       --  in out parameters, as it will return the range of the actual based
  2526:       --  on its type rather than based on the type of the formal parameter.
  2527:       --  For the same reason, do not apply also this optimization on lvalues.
  2528:
  2529:       if Present (Range_Type)
  2530:         and then Is_Floating_Point_Type (Range_Type)
  2531:         and then
  2532:           not (Is_Converted_Actual_Output_Parameter (Ada_Node) or else Lvalue)
  2533:       then
  2534:          declare
  2535:             Tlo : constant Node_Id := Type_Low_Bound (Range_Type);
  2536:             Thi : constant Node_Id := Type_High_Bound (Range_Type);
  2537:             Lov : Ureal;
  2538:             Hiv : Ureal;
  2539:             Lo  : Ureal := No_Ureal;
  2540:             Hi  : Ureal := No_Ureal;
  2541:             OK  : Boolean;
  2542:
  2543:          begin
  2544:             --  The computation of the range assumes at worst that the type of
  2545:             --  the expression is respected, so it is not suitable for overflow
  2546:             --  checks, for example the overflow check on 'Pred and 'Succ,
  2547:             --  therefore test first that Check_Kind is a range check.
  2548:
  2549:             if Check_Kind = RCK_Range
  2550:
  2551:               --  We can only remove the check if we can compute the expected
  2552:               --  bounds of the Range_Type now.
  2553:
  2554:               and then Compile_Time_Known_Value (Tlo)
  2555:               and then Compile_Time_Known_Value (Thi)
  2556:             then
  2557:                Lov := Expr_Value_R (Tlo);
  2558:                Hiv := Expr_Value_R (Thi);
  2559:
  2560:                --  Call Determine_Range_R on floating-point values
  2561:
  2562:                if Is_Floating_Point_Type (Etype (Ada_Node)) then
  2563:                   Determine_Range_R
  2564:                     (Ada_Node, OK, Lo, Hi, Assume_Valid => True);
  2565:
  2566:                --  Call Determine_Range on integer values, which may happen
  2567:                --  when converting an integer to a floating-point type.
  2568:
  2569:                elsif Is_Discrete_Type (Etype (Ada_Node)) then
  2570:                   declare
  2571:                      use Eval_Fat;
  2572:
  2573:                      function Round_Machine (B : Ureal) return Ureal
  2574:                      is (Machine (Range_Type, B, Round_Even, Ada_Node));
  2575:                      --  This is similar to the homonym function in
  2576:                      --  Checks.Determine_Range_R. It rounds a real bound B
  2577:                      --  using mode Round_Even. The underlying floating-point
  2578:                      --  type used is Range_Type.
  2579:
  2580:                      Lo_Int, Hi_Int : Uint;
  2581:                   begin
  2582:                      Determine_Range
  2583:                        (Ada_Node, OK, Lo_Int, Hi_Int, Assume_Valid => True);
  2584:
  2585:                      if OK then
  2586:                         Lo := Round_Machine (UR_From_Uint (Lo_Int));
  2587:                         Hi := Round_Machine (UR_From_Uint (Hi_Int));
  2588:                      end if;
  2589:                   end;
  2590:
  2591:                --  Neither a floating-point nor an integer value, hence
  2592:                --  fixed-point value. Conversion between fixed point and
  2593:                --  floating point types is not yet supported.
  2594:
  2595:                else
  2596:                   raise Program_Error;
  2597:                end if;
  2598:
  2599:                if OK then
  2600:
  2601:                   --  If definitely in range, generate a check always true for
  2602:                   --  the range check. When gnat2why directly handles check
  2603:                   --  messages, a message could be generated instead here.
  2604:
  2605:                   if Lo >= Lov and then Hi <= Hiv then
  2606:                      Emit_Always_True_Range_Check (Ada_Node, Check_Kind);
  2607:                      Range_Check_Applied := True;
  2608:                   end if;
  2609:                end if;
  2610:             end if;
  2611:          end;
  2612:       end if;
  2613:
  2614:       --  The regular case, we take care to insert the range check at a
  2615:       --  valid place where the expression is of the appropriate Why base
  2616:       --  type (real for a range check of a floating point type, bitvector_?
  2617:       --  for a range check of a modular type, int for a range check of a
  2618:       --  discrete type).
  2619:
  2620:       --  0. If From is a wrapper type, access the value. This may introduce an
  2621:       --     initialization check.
  2622:
  2623:       if Is_Init_Wrapper_Type (From) then
  2624:          declare
  2625:             From_Node : constant Entity_Id := Get_Ada_Node (+From);
  2626:          begin
  2627:             if Domain = EW_Prog and then not No_Init then
  2628:                Result :=
  2629:                  Insert_Initialization_Check
  2630:                    (Ada_Node           => Ada_Node,
  2631:                     E                  => From_Node,
  2632:                     Name               => Result,
  2633:                     Domain             => Domain,
  2634:                     Exclude_Components => Relaxed);
  2635:             end if;
  2636:
  2637:             --  An initialization check should be inserted directly when
  2638:             --  translating a scalar variable - see Transform_Identifier.
  2639:
  2640:             pragma Assert (Get_Type_Kind (From) /= EW_Split);
  2641:
  2642:             if From = M_Boolean_Init_Wrapper.Wrapper_Ty then
  2643:                Result :=
  2644:                  New_Call
  2645:                    (Ada_Node => Ada_Node,
  2646:                     Domain   => Domain,
  2647:                     Name     => M_Boolean_Init_Wrapper.Of_Wrapper,
  2648:                     Args     => (1 => Result),
  2649:                     Typ      => EW_Bool_Type);
  2650:             else
  2651:                Result :=
  2652:                  New_Call
  2653:                    (Ada_Node => Ada_Node,
  2654:                     Domain   => Domain,
  2655:                     Name     => E_Symb (From_Node, WNE_Of_Wrapper),
  2656:                     Args     => (1 => Result),
  2657:                     Typ      => EW_Abstract (From_Node));
  2658:             end if;
  2659:          end;
  2660:          Cur := Get_Type (Result);
  2661:       end if;
  2662:
  2663:       --  1. If From is an abstract type, convert it to type int, __fixed,
  2664:       --     real, or bitvector_?.
  2665:
  2666:       if Get_Type_Kind (Cur) = EW_Abstract then
  2667:          Cur := Base_Why_Type (From);
  2668:          Result :=
  2669:            Insert_Single_Conversion
  2670:              (Ada_Node => Ada_Node,
  2671:               Domain   => Domain,
  2672:               To       => Cur,
  2673:               Expr     => Result);
  2674:       end if;
  2675:
  2676:       --  2. If From is a fixed-point type or a modular type, and To does not
  2677:       --     share the same base type (__fixed or bitvector_?), possibly
  2678:       --     convert to a suitable intermediate type.
  2679:
  2680:       if Base_Why_Type (From) /= Base_Why_Type (To) then
  2681:
  2682:          --  2.1. Possibly convert from one fixed-point small to another one
  2683:
  2684:          if Why_Type_Is_Fixed (Base_Why_Type (From))
  2685:            and then Why_Type_Is_Fixed (Base_Why_Type (To))
  2686:          then
  2687:             declare
  2688:                From_Type : constant Entity_Id := Get_Ada_Node (+From);
  2689:                To_Type   : constant Entity_Id := Get_Ada_Node (+To);
  2690:                To_Base   : constant W_Type_Id := Base_Why_Type (To);
  2691:
  2692:                --  Fixed point types always have an Ada node
  2693:
  2694:                pragma
  2695:                  Assert
  2696:                    (Present (From_Type)
  2697:                     and then Has_Fixed_Point_Type (From_Type)
  2698:                     and then Present (To_Type)
  2699:                     and then Has_Fixed_Point_Type (To_Type));
  2700:
  2701:                --  If From and To have the same small, they should have the
  2702:                --  same base type.
  2703:
  2704:                pragma
  2705:                  Assert (Small_Value (From_Type) /= Small_Value (To_Type));
  2706:
  2707:                --  Multiply by 1 to introduce the conversion
  2708:
  2709:                Module   : constant M_Fixed_Point_Mult_Div_Type :=
  2710:                  Get_Fixed_Point_Mult_Div_Theory
  2711:                    (Typ_Left   => From_Type,
  2712:                     Typ_Right  => Standard_Integer,
  2713:                     Typ_Result => To_Type);
  2714:                Name     : constant W_Identifier_Id := Module.Mult;
  2715:                One_Term : constant W_Expr_Id :=
  2716:                  New_Discrete_Constant (Value => Uint_1, Typ => EW_Int_Type);
  2717:             begin
  2718:                Result :=
  2719:                  New_Call
  2720:                    (Ada_Node => Ada_Node,
  2721:                     Domain   => Domain,
  2722:                     Name     => Name,
  2723:                     Args     => (1 => Result, 2 => One_Term),
  2724:                     Typ      => To_Base);
  2725:
  2726:                Cur := To_Base;
  2727:             end;
  2728:
  2729:          --  2.2. If From is a fixed-point type and To is an integer type,
  2730:
  2731:          elsif (Why_Type_Is_Fixed (Base_Why_Type (From))
  2732:                 and then not Why_Type_Is_Float (Base_Why_Type (To)))
  2733:
  2734:            --  or if From is a modular type and To is neither a modular nor
  2735:            --  a float, insert a conversion to int since we only support
  2736:            --  direct conversion from bitvector to int, float or another
  2737:            --  bitvector types.
  2738:
  2739:            or else
  2740:              (Why_Type_Is_BitVector (Base_Why_Type (From))
  2741:               and then not Why_Type_Is_BitVector (Base_Why_Type (To))
  2742:               and then not Why_Type_Is_Float (Base_Why_Type (To)))
  2743:          then
  2744:             Result :=
  2745:               Insert_Single_Conversion
  2746:                 (Ada_Node => Ada_Node,
  2747:                  Domain   => Domain,
  2748:                  To       => EW_Int_Type,
  2749:                  Expr     => Result);
  2750:             Cur := EW_Int_Type;
  2751:          end if;
  2752:       end if;
  2753:
  2754:       --  3. Possibly perform the range check, if applicable on Cur. A special
  2755:       --     case is that range checks on boolean variables are performed after
  2756:       --     their conversion to int. Another special case is that range checks
  2757:       --     on modular types are always performed at this point, as any
  2758:       --     necessary conversion to int has already occurred in 2.
  2759:
  2760:       if Present (Range_Type)
  2761:         and then not Range_Check_Applied
  2762:         and then From /= EW_Bool_Type
  2763:         and then
  2764:           (Base_Why_Type (Range_Type) = Cur
  2765:            or else
  2766:              (Has_Modular_Integer_Type (Range_Type)
  2767:               and then not Has_No_Bitwise_Operations_Annotation (Range_Type)))
  2768:       then
  2769:          Range_Check_Applied := True;
  2770:          Result :=
  2771:            +Do_Range_Check
  2772:               (Ada_Node   => Ada_Node,
  2773:                Ty         => Range_Type,
  2774:                W_Expr     => Result,
  2775:                Check_Kind => Check_Kind);
  2776:       end if;
  2777:
  2778:       --  4. If From and To do not share the same base type (bool, int, __fixed
  2779:       --     bitvector_? or real), convert from one to the other.
  2780:       --     Note that for checks, the base type of Boolean is "int".
  2781:
  2782:       declare
  2783:          To_Ty : W_Type_Id := Base_Why_Type (To);
  2784:       begin
  2785:          --  Avoid converting Booleans to integers when there is no check
  2786:
  2787:          if To_Ty = EW_Bool_Type
  2788:            and then
  2789:              (Cur /= EW_Bool_Type
  2790:               or else (Present (Range_Type) and then not Range_Check_Applied)
  2791:               or else (Domain = EW_Prog and then Do_Predicate_Check))
  2792:          then
  2793:             To_Ty := EW_Int_Type;
  2794:          end if;
  2795:
  2796:          if Cur /= To_Ty then
  2797:             Result :=
  2798:               Insert_Single_Conversion
  2799:                 (Ada_Node => Ada_Node,
  2800:                  Domain   => Domain,
  2801:                  From     => Cur,
  2802:                  To       => To_Ty,
  2803:                  Expr     => Result);
  2804:             Cur := To_Ty;
  2805:          end if;
  2806:       end;
  2807:
  2808:       --  5. Possibly perform the range check, if not already applied
  2809:
  2810:       if Present (Range_Type) and then not Range_Check_Applied then
  2811:          pragma
  2812:            Assert
  2813:              (Base_Why_Type (Range_Type) = Cur
  2814:               or else Base_Why_Type (Range_Type) = EW_Bool_Type
  2815:               or else
  2816:                 (Get_Type_Kind (Cur) = EW_Split
  2817:                  and then
  2818:                    Base_Why_Type (Get_Ada_Node (+Cur))
  2819:                    = Base_Why_Type (Range_Type)));
  2820:          Result :=
  2821:            +Do_Range_Check
  2822:               (Ada_Node   => Ada_Node,
  2823:                Ty         => Range_Type,
  2824:                W_Expr     => Result,
  2825:                Check_Kind => Check_Kind);
  2826:       end if;
  2827:
  2828:       --  6. Perform a predicate check if needed, before the final conversion
  2829:       --  to the target abstract type if any, if the predicate function takes
  2830:       --  a Why3 native type as input as detected by Use_Split_Form_For_Type.
  2831:
  2832:       if Domain = EW_Prog
  2833:         and then Do_Predicate_Check
  2834:         and then Use_Split_Form_For_Type (Get_Ada_Node (+To))
  2835:       then
  2836:          Result :=
  2837:            +Insert_Predicate_Check
  2838:               (Ada_Node => Ada_Node,
  2839:                Check_Ty => Get_Ada_Node (+To),
  2840:                W_Expr   => +Result);
  2841:       end if;
  2842:
  2843:       --  7. If To is an abstract type or bool, convert from int, __fixed or
  2844:       --     real to it.
  2845:
  2846:       if Get_Type_Kind (To_Conc) = EW_Abstract or else To_Conc = EW_Bool_Type
  2847:       then
  2848:          Result :=
  2849:            Insert_Single_Conversion
  2850:              (Ada_Node => Ada_Node,
  2851:               Domain   => Domain,
  2852:               From     => Cur,
  2853:               To       => To_Conc,
  2854:               Expr     => Result);
  2855:
  2856:       end if;
  2857:
  2858:       --  8. Perform a predicate check if needed, after the final conversion
  2859:       --  to the target abstract type if any, if the predicate function takes
  2860:       --  an abstract type as input as detected by Use_Split_Form_For_Type.
  2861:       --  This should never occur as all scalar types use a split form but
  2862:       --  standard boolean which cannot have a predicate.
  2863:
  2864:       if Domain = EW_Prog
  2865:         and then Do_Predicate_Check
  2866:         and then not Use_Split_Form_For_Type (Get_Ada_Node (+To))
  2867:       then
  2868:          raise Program_Error;
  2869:       end if;
  2870:
  2871:       --  9. Reconstruct the wrapper if necessary
  2872:
  2873:       if Is_Init_Wrapper_Type (To) then
  2874:          pragma Assert (Get_Type_Kind (To) /= EW_Split);
  2875:
  2876:          if To = M_Boolean_Init_Wrapper.Wrapper_Ty then
  2877:             Result :=
  2878:               New_Call
  2879:                 (Ada_Node => Ada_Node,
  2880:                  Domain   => Domain,
  2881:                  Name     => M_Boolean_Init_Wrapper.To_Wrapper,
  2882:                  Args     => (1 => Result),
  2883:                  Typ      => To);
  2884:          else
  2885:             Result :=
  2886:               New_Call
  2887:                 (Ada_Node => Ada_Node,
  2888:                  Domain   => Domain,
  2889:                  Name     => E_Symb (Get_Ada_Node (+To), WNE_To_Wrapper),
  2890:                  Args     => (1 => Result),
  2891:                  Typ      => To);
  2892:          end if;
  2893:       end if;
  2894:
  2895:       --  10. Change type to the expected one by adding a dummy node if needed.
  2896:       --  This may be required because some of the conversions are no-ops in
  2897:       --  Why.
  2898:
  2899:       if Get_Type (Result) /= To then
  2900:          Result :=
  2901:            New_Label
  2902:              (Ada_Node => Ada_Node,
  2903:               Labels   => Symbol_Sets.Empty_Set,
  2904:               Def      => Result,
  2905:               Domain   => Domain,
  2906:               Typ      => To);
  2907:       end if;
  2908:
  2909:       return Result;
  2910:    end Insert_Scalar_Conversion;
```

## src/why/why-gen-expr.adb:2916-3050

```ada
  2916:    function Insert_Simple_Conversion
  2917:      (Ada_Node       : Node_Id := Empty;
  2918:       Domain         : EW_Domain;
  2919:       Expr           : W_Expr_Id;
  2920:       To             : W_Type_Id;
  2921:       Force_No_Slide : Boolean := False) return W_Expr_Id
  2922:    is
  2923:       From : constant W_Type_Id := Get_Type (Expr);
  2924:
  2925:    begin
  2926:       --  Nothing to do if From = To
  2927:
  2928:       if Eq_Base (To, From) then
  2929:          return Expr;
  2930:       end if;
  2931:
  2932:       if Is_Private_Conversion (To, From)
  2933:         or else Is_Record_Conversion (To, From)
  2934:       then
  2935:          return
  2936:            Insert_Record_Conversion
  2937:              (Domain => Domain, Ada_Node => Ada_Node, Expr => Expr, To => To);
  2938:
  2939:       elsif Is_Array_Conversion (To, From) then
  2940:          return
  2941:            Insert_Array_Conversion
  2942:              (Domain         => Domain,
  2943:               Ada_Node       => Ada_Node,
  2944:               Expr           => Expr,
  2945:               To             => To,
  2946:               Force_No_Slide => Force_No_Slide);
  2947:
  2948:       elsif Is_Subp_Pointer_Conversion (From, To) then
  2949:          return
  2950:            Insert_Subp_Pointer_Conversion
  2951:              (Domain => Domain, Ada_Node => Ada_Node, Expr => Expr, To => To);
  2952:
  2953:       elsif Is_Pointer_Conversion (To, From) then
  2954:          return
  2955:            Insert_Pointer_Conversion
  2956:              (Domain => Domain, Ada_Node => Ada_Node, Expr => Expr, To => To);
  2957:
  2958:       else
  2959:          return
  2960:            Insert_Scalar_Conversion
  2961:              (Domain   => Domain,
  2962:               Ada_Node => Ada_Node,
  2963:               Expr     => Expr,
  2964:               To       => To,
  2965:               No_Init  => True);
  2966:       end if;
  2967:    end Insert_Simple_Conversion;
  2968:
  2969:    ------------------------------
  2970:    -- Insert_Single_Conversion --
  2971:    ------------------------------
  2972:
  2973:    function Insert_Single_Conversion
  2974:      (Ada_Node : Node_Id; Domain : EW_Domain; To : W_Type_Id; Expr : W_Expr_Id)
  2975:       return W_Expr_Id
  2976:    is
  2977:       From : constant W_Type_Id := Get_Type (Expr);
  2978:    begin
  2979:       return
  2980:         Insert_Single_Conversion
  2981:           (Ada_Node => Ada_Node,
  2982:            Domain   => Domain,
  2983:            From     => From,
  2984:            To       => To,
  2985:            Expr     => Expr);
  2986:    end Insert_Single_Conversion;
  2987:
  2988:    function Insert_Single_Conversion
  2989:      (Ada_Node : Node_Id;
  2990:       Domain   : EW_Domain;
  2991:       From     : W_Type_Id;
  2992:       To       : W_Type_Id;
  2993:       Expr     : W_Expr_Id) return W_Expr_Id
  2994:    is
  2995:       From_Base : constant W_Type_Id :=
  2996:         (if Get_Type_Kind (From) = EW_Split
  2997:            and then Has_Scalar_Type (Get_Ada_Node (+From))
  2998:          then Base_Why_Type (Get_Ada_Node (+From))
  2999:          else From);
  3000:       To_Base   : constant W_Type_Id :=
  3001:         (if Get_Type_Kind (To) = EW_Split
  3002:            and then Has_Scalar_Type (Get_Ada_Node (+To))
  3003:          then Base_Why_Type (Get_Ada_Node (+To))
  3004:          else To);
  3005:    begin
  3006:       if Eq_Base (From_Base, To_Base) then
  3007:          return Expr;
  3008:       end if;
  3009:
  3010:       --  Conversion of integer constants to Why range types are replaced by
  3011:       --  builtin range values.
  3012:
  3013:       declare
  3014:          Current : W_Expr_Id := Expr;
  3015:       begin
  3016:          while Get_Kind (+Current) = W_Label loop
  3017:             Current := Get_Def (W_Label_Id (Current));
  3018:          end loop;
  3019:
  3020:          if Get_Kind (+Current) = W_Integer_Constant
  3021:            and then Get_Type_Kind (To) = EW_Abstract
  3022:            and then Is_Range_Type_In_Why (Get_Ada_Node (+To))
  3023:          then
  3024:             return
  3025:               New_Range_Constant
  3026:                 (Ada_Node => Get_Ada_Node (+Expr),
  3027:                  Value    => Get_Value (W_Integer_Constant_Id (Current)),
  3028:                  Typ      => To);
  3029:          end if;
  3030:       end;
  3031:
  3032:       return
  3033:         New_Call
  3034:           (Domain   => Domain,
  3035:            Ada_Node => Ada_Node,
  3036:            Name     => Conversion_Name (From => From_Base, To => To_Base),
  3037:            Args     => (1 => +Expr),
  3038:            Typ      => To);
  3039:    end Insert_Single_Conversion;
  3040:
  3041:    ------------------------------------
  3042:    -- Insert_Subp_Pointer_Conversion --
  3043:    ------------------------------------
  3044:
  3045:    function Insert_Subp_Pointer_Conversion
  3046:      (Ada_Node   : Node_Id;
  3047:       Domain     : EW_Domain;
  3048:       Expr       : W_Expr_Id;
  3049:       To         : W_Type_Id;
  3050:       Need_Check : Boolean := False;
```

## src/why/why-gen-expr.adb:3219-3277

```ada
  3219:    function Needs_Slide (From_Ent, To_Ent : Entity_Id) return Boolean is
  3220:
  3221:       function First_Constrained_Parent (Ty : Entity_Id) return Entity_Id
  3222:       with Pre => Is_Constrained (Ty);
  3223:       --  Traverse the parents of Ty to find the first constrained type
  3224:
  3225:       ------------------------------
  3226:       -- First_Constrained_Parent --
  3227:       ------------------------------
  3228:
  3229:       function First_Constrained_Parent (Ty : Entity_Id) return Entity_Id is
  3230:          Parent : Entity_Id := Ty;
  3231:       begin
  3232:          loop
  3233:             declare
  3234:                New_Parent : constant Entity_Id := Parent_Retysp (Parent);
  3235:             begin
  3236:                if No (New_Parent) or else not Is_Constrained (New_Parent) then
  3237:                   return Parent;
  3238:                else
  3239:                   Parent := New_Parent;
  3240:                end if;
  3241:             end;
  3242:          end loop;
  3243:       end First_Constrained_Parent;
  3244:
  3245:       From_Rep         : constant Entity_Id := Retysp (From_Ent);
  3246:       To_Rep           : constant Entity_Id := Retysp (To_Ent);
  3247:       Dim              : constant Positive :=
  3248:         Positive (Number_Dimensions (To_Rep));
  3249:       To_Constrained   : constant Boolean := Is_Constrained (To_Rep);
  3250:       From_Constrained : constant Boolean := Is_Constrained (From_Rep);
  3251:    begin
  3252:       --  Sliding is needed when we convert to a constrained type and the
  3253:       --  'First of the From type is not known to be equal to the 'First
  3254:       --  of the "To" type.
  3255:
  3256:       --  Sliding is only necessary when converting to a constrained array or
  3257:       --  to a type with fixed lower bounds.
  3258:
  3259:       if not To_Constrained
  3260:         and then not Is_Fixed_Lower_Bound_Array_Subtype (To_Rep)
  3261:       then
  3262:          return False;
  3263:       end if;
  3264:
  3265:       --  When the "To" is constrained, sliding is always necessary when
  3266:       --  converting from an unconstrained array without fixed lower bounds
  3267:
  3268:       if not From_Constrained
  3269:         and then not Is_Fixed_Lower_Bound_Array_Subtype (From_Rep)
  3270:       then
  3271:          return True;
  3272:       end if;
  3273:
  3274:       --  If "To" and "From" are derived from the same constrained type, no
  3275:       --  sliding is needed.
  3276:
  3277:       if From_Constrained
```

## src/why/why-gen-expr.adb:3405-3997

```ada
  3405:    function New_Ada_Equality
  3406:      (Typ : Type_Kind_Id; Domain : EW_Domain; Left, Right : W_Expr_Id)
  3407:       return W_Expr_Id
  3408:    is
  3409:       Why_Type   : constant W_Type_Id := Type_Of_Node (Typ);
  3410:       Use_Predef : constant Boolean := Use_Predefined_Equality_For_Type (Typ);
  3411:       Eq_Id      : constant W_Identifier_Id :=
  3412:         (if Use_Predef
  3413:          then E_Symb (Typ, WNE_Bool_Eq)
  3414:          else E_Symb (Typ, WNE_User_Eq));
  3415:       T          : W_Expr_Id;
  3416:
  3417:    begin
  3418:       if Is_Class_Wide_Type (Typ) then
  3419:          T := New_Ada_Dispatching_Equality (Typ, Domain, Left, Right);
  3420:       elsif Is_Scalar_Type (Typ) then
  3421:          declare
  3422:             BT        : constant W_Type_Id := Base_Why_Type (Why_Type);
  3423:             Left_Int  : constant W_Expr_Id :=
  3424:               Insert_Simple_Conversion
  3425:                 (Domain => EW_Term, Expr => Left, To => BT);
  3426:             Right_Int : constant W_Expr_Id :=
  3427:               Insert_Simple_Conversion
  3428:                 (Domain => EW_Term, Expr => Right, To => BT);
  3429:
  3430:          begin
  3431:             pragma Assert (Use_Predef);
  3432:
  3433:             if Why_Type_Is_Float (BT) then
  3434:                T :=
  3435:                  New_Call
  3436:                    (Name   => MF_Floats (BT).Eq,
  3437:                     Domain => Domain,
  3438:                     Typ    => EW_Bool_Type,
  3439:                     Args   => (Left_Int, Right_Int));
  3440:             elsif Why_Type_Is_BitVector (BT) then
  3441:                T :=
  3442:                  New_Call
  3443:                    (Name   =>
  3444:                       (if Domain in EW_Prog | EW_Pterm
  3445:                        then MF_BVs (BT).Prog_Eq
  3446:                        else Why_Eq),
  3447:                     Domain => Domain,
  3448:                     Typ    => EW_Bool_Type,
  3449:                     Args   => (Left_Int, Right_Int));
  3450:             elsif BT = EW_Bool_Type then
  3451:                T :=
  3452:                  New_Call
  3453:                    (Name   =>
  3454:                       (if Domain in EW_Prog | EW_Pterm
  3455:                        then M_Boolean.Bool_Eq
  3456:                        else Why_Eq),
  3457:                     Domain => Domain,
  3458:                     Typ    => EW_Bool_Type,
  3459:                     Args   => (Left_Int, Right_Int));
  3460:             else
  3461:                T :=
  3462:                  New_Call
  3463:                    (Name   => Why_Eq,
  3464:                     Domain => Domain,
  3465:                     Typ    => EW_Bool_Type,
  3466:                     Args   => (Left_Int, Right_Int));
  3467:             end if;
  3468:          end;
  3469:       else
  3470:          T :=
  3471:            New_Call
  3472:              (Name   => Eq_Id,
  3473:               Domain => EW_Term,
  3474:               Args   => (1 => Left, 2 => Right),
  3475:               Typ    => EW_Bool_Type);
  3476:       end if;
  3477:
  3478:       return T;
  3479:    end New_Ada_Equality;
  3480:
  3481:    ------------------
  3482:    -- New_And_Expr --
  3483:    ------------------
  3484:
  3485:    function New_And_Expr
  3486:      (Left, Right : W_Expr_Id; Domain : EW_Domain) return W_Expr_Id is
  3487:    begin
  3488:       if Is_True_Boolean (+Left) then
  3489:          return Right;
  3490:       elsif Is_True_Boolean (+Right) then
  3491:          return Left;
  3492:       elsif Domain = EW_Pred then
  3493:          return
  3494:            New_Connection
  3495:              (Domain => Domain, Op => EW_And, Left => +Left, Right => +Right);
  3496:       else
  3497:          return
  3498:            New_Call
  3499:              (Domain => Domain,
  3500:               Name   => M_Boolean.Andb,
  3501:               Args   => (1 => +Left, 2 => +Right),
  3502:               Typ    => EW_Bool_Type);
  3503:       end if;
  3504:    end New_And_Expr;
  3505:
  3506:    function New_And_Expr
  3507:      (Left, Right : W_Expr_Id; Domain : EW_Domain; Base : W_Type_Id)
  3508:       return W_Expr_Id is
  3509:    begin
  3510:       if Base = EW_BitVector_8_Type
  3511:         or else Base = EW_BitVector_16_Type
  3512:         or else Base = EW_BitVector_32_Type
  3513:         or else Base = EW_BitVector_64_Type
  3514:         or else Base = EW_BitVector_128_Type
  3515:       then
  3516:          return
  3517:            New_Call
  3518:              (Domain => Domain,
  3519:               Name   => MF_BVs (Base).BW_And,
  3520:               Args   => (1 => +Left, 2 => +Right),
  3521:               Typ    => Base);
  3522:       elsif Base = EW_Bool_Type then
  3523:          return New_And_Expr (Left, Right, Domain);
  3524:       else
  3525:          raise Program_Error;
  3526:       end if;
  3527:    end New_And_Expr;
  3528:
  3529:    ------------------
  3530:    -- New_And_Pred --
  3531:    ------------------
  3532:
  3533:    function New_And_Pred (Conjuncts : W_Pred_Array) return W_Pred_Id is
  3534:       Filtered : W_Pred_Array (1 .. Conjuncts'Length);
  3535:       Count    : Natural := 0;
  3536:    begin
  3537:       for Conjunct of Conjuncts loop
  3538:          if Is_True_Boolean (+Conjunct) then
  3539:             null;
  3540:          elsif Is_False_Boolean (+Conjunct) then
  3541:             return False_Pred;
  3542:          else
  3543:             Count := Count + 1;
  3544:             Filtered (Count) := Conjunct;
  3545:          end if;
  3546:       end loop;
  3547:
  3548:       if Count = 0 then
  3549:          return True_Pred;
  3550:
  3551:       elsif Count = 1 then
  3552:          return Filtered (1);
  3553:
  3554:       else
  3555:          --  We use the array form with "More_Right" here for these reasons:
  3556:          --  - It avoids a deeply nested tree. Such deep nesting could lead
  3557:          --    to a stack overflow in code that traverses the whole tree;
  3558:          --  - The array form receives special handling in why3, creating a
  3559:          --    balanced tree of binary conjunctions, again to avoid deeply
  3560:          --    nested trees.
  3561:
  3562:          return
  3563:            New_Connection
  3564:              (Op         => EW_And,
  3565:               Left       => Filtered (1),
  3566:               Right      => Filtered (2),
  3567:               More_Right => Filtered (3 .. Count));
  3568:       end if;
  3569:    end New_And_Pred;
  3570:
  3571:    -----------------------
  3572:    -- New_And_Then_Expr --
  3573:    -----------------------
  3574:
  3575:    function New_And_Then_Expr
  3576:      (Left, Right : W_Expr_Id; Domain : EW_Domain) return W_Expr_Id is
  3577:    begin
  3578:       if Is_True_Boolean (+Left) then
  3579:          return Right;
  3580:       elsif Is_True_Boolean (+Right) then
  3581:          return Left;
  3582:       else
  3583:          if Domain = EW_Prog then
  3584:             return
  3585:               New_Connection
  3586:                 (Op     => EW_And_Then,
  3587:                  Left   => Left,
  3588:                  Right  => Right,
  3589:                  Domain => Domain);
  3590:          else
  3591:             return New_And_Expr (Left, Right, Domain);
  3592:          end if;
  3593:       end if;
  3594:    end New_And_Then_Expr;
  3595:
  3596:    ------------------------
  3597:    -- New_Attribute_Expr --
  3598:    ------------------------
  3599:
  3600:    function New_Attribute_Expr
  3601:      (Ty     : Entity_Id;
  3602:       Domain : EW_Domain;
  3603:       Attr   : Supported_Attribute_Id;
  3604:       Params : Transformation_Params := Body_Params) return W_Expr_Id
  3605:    is
  3606:       Subdomain : constant EW_Domain :=
  3607:         (if Domain in EW_Prog | EW_Pterm then EW_Pterm else EW_Term);
  3608:
  3609:    begin
  3610:       --  We do not generate axioms giving values to bounds of Itypes as they
  3611:       --  may contain locally defined entities that are not detected by
  3612:       --  Get_Variables ('Old, 'Loop_Entry, 'Return).
  3613:
  3614:       if Attr in Attribute_First | Attribute_Last
  3615:         and then Type_Is_Modeled_As_Base (Ty)
  3616:         and then Is_Itype (Ty)
  3617:       then
  3618:          --  Use expression for dynamic bounds
  3619:
  3620:          declare
  3621:             Rng : constant Node_Id := Get_Range (Ty);
  3622:             BT  : constant W_Type_Id :=
  3623:               (if Is_Standard_Boolean_Type (Ty)
  3624:                then EW_Int_Type
  3625:                else Base_Why_Type (Ty));
  3626:          begin
  3627:             return
  3628:               Transform_Expr
  3629:                 ((if Attr = Attribute_First
  3630:                   then Low_Bound (Rng)
  3631:                   else High_Bound (Rng)),
  3632:                  BT,
  3633:                  Subdomain,
  3634:                  Params);
  3635:          end;
  3636:
  3637:       elsif Attr in Attribute_First | Attribute_Last
  3638:         and then Type_Is_Modeled_As_Base (Ty)
  3639:       then
  3640:          --  Call predefind functions
  3641:
  3642:          declare
  3643:             Rng : constant Node_Id := Get_Range (Ty);
  3644:             BT  : constant W_Type_Id :=
  3645:               (if Is_Standard_Boolean_Type (Ty)
  3646:                then EW_Int_Type
  3647:                else Base_Why_Type (Ty));
  3648:             Bnd : constant Node_Id :=
  3649:               (if Attr = Attribute_First
  3650:                then Low_Bound (Rng)
  3651:                else High_Bound (Rng));
  3652:             Id  : constant W_Identifier_Id :=
  3653:               (if Attr = Attribute_First
  3654:                then E_Symb (Ty, WNE_Attr_First)
  3655:                else E_Symb (Ty, WNE_Attr_Last));
  3656:          begin
  3657:             return
  3658:               New_Call
  3659:                 (Domain => Subdomain,
  3660:                  Name   => Id,
  3661:                  Args   =>
  3662:                    Get_Args_From_Binders
  3663:                      (To_Binder_Array
  3664:                         (Get_Binders_From_Expression (Bnd),
  3665:                          Keep_Const => Keep),
  3666:                       Params.Ref_Allowed),
  3667:                  Typ    => BT);
  3668:          end;
  3669:
  3670:       elsif Attr in Attribute_First | Attribute_Last
  3671:         and then Ekind (Ty) = E_String_Literal_Subtype
  3672:       then
  3673:          declare
  3674:             BT : constant W_Type_Id := Nth_Index_Rep_Type_No_Bool (Ty, 1);
  3675:          begin
  3676:             case Attr is
  3677:                when Attribute_First =>
  3678:                   return
  3679:                     New_Discrete_Constant
  3680:                       (Value => Expr_Value (String_Literal_Low_Bound (Ty)),
  3681:                        Typ   => BT);
  3682:
  3683:                when Attribute_Last  =>
  3684:                   return
  3685:                     New_Discrete_Constant
  3686:                       (Value =>
  3687:                          Expr_Value (String_Literal_Low_Bound (Ty))
  3688:                          + String_Literal_Length (Ty)
  3689:                          - 1,
  3690:                        Typ   => BT);
  3691:
  3692:                when others          =>
  3693:                   raise Program_Error;
  3694:             end case;
  3695:          end;
  3696:
  3697:       elsif Is_Standard_Boolean_Type (Ty) then
  3698:          case Attr is
  3699:             when Attribute_First =>
  3700:                return +M_Boolean.First;
  3701:
  3702:             when Attribute_Last  =>
  3703:                return +M_Boolean.Last;
  3704:
  3705:             when Attribute_Image =>
  3706:                return +M_Boolean.Image;
  3707:
  3708:             when Attribute_Value =>
  3709:                return +M_Boolean.Value;
  3710:
  3711:             when others          =>
  3712:                raise Program_Error;
  3713:          end case;
  3714:
  3715:       else
  3716:          case Attr is
  3717:             when Attribute_First                       =>
  3718:                return +E_Symb (Ty, WNE_Attr_First);
  3719:
  3720:             when Attribute_Last                        =>
  3721:                return +E_Symb (Ty, WNE_Attr_Last);
  3722:
  3723:             when Attribute_Alignment                   =>
  3724:                return +E_Symb (Ty, WNE_Attr_Alignment);
  3725:
  3726:             when Attribute_Modulus                     =>
  3727:                return +E_Symb (Ty, WNE_Attr_Modulus);
  3728:
  3729:             when Attribute_Constrained                 =>
  3730:                return +E_Symb (Ty, WNE_Attr_Constrained);
  3731:
  3732:             when Attribute_Size | Attribute_Value_Size =>
  3733:                return +E_Symb (Ty, WNE_Attr_Value_Size);
  3734:
  3735:             when Attribute_Tag                         =>
  3736:                return +E_Symb (Ty, WNE_Attr_Tag);
  3737:
  3738:             when Attribute_Image                       =>
  3739:                return +E_Symb (Ty, WNE_Attr_Image);
  3740:
  3741:             when Attribute_Value                       =>
  3742:                return +E_Symb (Ty, WNE_Attr_Value);
  3743:
  3744:             when others                                =>
  3745:                raise Program_Error;
  3746:          end case;
  3747:       end if;
  3748:    end New_Attribute_Expr;
  3749:
  3750:    ------------------------
  3751:    -- New_Binary_Op_Expr --
  3752:    ------------------------
  3753:
  3754:    function New_Binary_Op_Expr
  3755:      (Op          : N_Binary_Op;
  3756:       Left        : W_Expr_Id;
  3757:       Right       : W_Expr_Id;
  3758:       Left_Type   : Type_Kind_Id;
  3759:       Right_Type  : Type_Kind_Id;
  3760:       Return_Type : Type_Kind_Id;
  3761:       Domain      : EW_Domain;
  3762:       Ada_Node    : Node_Id := Empty) return W_Expr_Id
  3763:    is
  3764:       Left_Rep  : W_Expr_Id := Left;
  3765:       Right_Rep : W_Expr_Id := Right;
  3766:       Base      : W_Type_Id := Why_Empty;
  3767:       T         : W_Expr_Id;
  3768:
  3769:       Check_No_Wrap_Around : constant Boolean :=
  3770:         Domain = EW_Prog
  3771:         and then Op in N_Op_Add | N_Op_Subtract | N_Op_Multiply | N_Op_Expon
  3772:         and then Has_No_Wrap_Around_Annotation (Return_Type);
  3773:
  3774:    begin
  3775:       case Op is
  3776:          when N_Op_Compare
  3777:             | N_Op_And
  3778:             | N_Op_Or
  3779:             | N_Op_Xor
  3780:             | N_Op_Concat
  3781:             | N_Op_Shift               =>
  3782:             raise Program_Error;
  3783:
  3784:          when N_Op_Add | N_Op_Subtract =>
  3785:             Base := Base_Why_Type (Left_Type, Right_Type);
  3786:
  3787:             declare
  3788:                Name : constant W_Identifier_Id :=
  3789:                  (if Op = N_Op_Add
  3790:                   then
  3791:                     (if Base = EW_Int_Type
  3792:                      then Int_Infix_Add
  3793:                      elsif Why_Type_Is_BitVector (Base)
  3794:                      then MF_BVs (Base).Add
  3795:                      elsif Why_Type_Is_Fixed (Base)
  3796:                      then Fixed_Infix_Add
  3797:                      else MF_Floats (Base).Add)
  3798:                   else
  3799:                     (if Base = EW_Int_Type
  3800:                      then Int_Infix_Subtr
  3801:                      elsif Why_Type_Is_BitVector (Base)
  3802:                      then MF_BVs (Base).Sub
  3803:                      elsif Why_Type_Is_Fixed (Base)
  3804:                      then Fixed_Infix_Subtr
  3805:                      else MF_Floats (Base).Subtr));
  3806:             begin
  3807:                Left_Rep :=
  3808:                  Insert_Simple_Conversion
  3809:                    (Ada_Node => Ada_Node,
  3810:                     Domain   => Domain,
  3811:                     Expr     => Left,
  3812:                     To       => Base);
  3813:                Right_Rep :=
  3814:                  Insert_Simple_Conversion
  3815:                    (Ada_Node => Ada_Node,
  3816:                     Domain   => Domain,
  3817:                     Expr     => Right,
  3818:                     To       => Base);
  3819:
  3820:                if Has_Modular_Integer_Type (Return_Type)
  3821:                  and then
  3822:                    not Has_No_Bitwise_Operations_Annotation (Return_Type)
  3823:                  and then Non_Binary_Modulus (Return_Type)
  3824:                then
  3825:                   T :=
  3826:                     Transform_Non_Binary_Modular_Operation
  3827:                       (Ada_Node   => Ada_Node,
  3828:                        Ada_Type   => Return_Type,
  3829:                        Domain     => Domain,
  3830:                        Op         => Op,
  3831:                        Left_Opnd  => Left_Rep,
  3832:                        Right_Opnd => Right_Rep,
  3833:                        Rep_Type   => Base,
  3834:                        Modulus    => Modulus (Return_Type));
  3835:
  3836:                else
  3837:                   T :=
  3838:                     New_Call
  3839:                       (Ada_Node => Ada_Node,
  3840:                        Domain   => Domain,
  3841:                        Name     => Name,
  3842:                        Args     => (1 => Left_Rep, 2 => Right_Rep),
  3843:                        Typ      => Base);
  3844:
  3845:                   if not Check_No_Wrap_Around then
  3846:                      T := Apply_Modulus (Op, Return_Type, T, Domain);
  3847:                   end if;
  3848:                end if;
  3849:             end;
  3850:
  3851:          when N_Op_Multiply            =>
  3852:             declare
  3853:                L_Type, R_Type : W_Type_Id;
  3854:                Oper           : Why_Name_Enum := WNE_Empty;
  3855:
  3856:             begin
  3857:                --  Look for the appropriate base scalar type
  3858:
  3859:                if Has_Fixed_Point_Type (Left_Type)
  3860:                  and then Has_Fixed_Point_Type (Right_Type)
  3861:                then
  3862:                   L_Type := Base_Why_Type (Left_Type);
  3863:                   R_Type := Base_Why_Type (Right_Type);
  3864:                   Oper := WNE_Fixed_Point_Mult;
  3865:
  3866:                   if Has_Fixed_Point_Type (Return_Type) then
  3867:                      Base := Base_Why_Type (Return_Type);
  3868:                   else
  3869:                      pragma Assert (Has_Integer_Type (Return_Type));
  3870:                      Base := EW_Int_Type;
  3871:                   end if;
  3872:
  3873:                elsif Has_Fixed_Point_Type (Left_Type) then
  3874:                   L_Type := Base_Why_Type (Left_Type);
  3875:                   R_Type := EW_Int_Type;
  3876:                   Base := Base_Why_Type (Return_Type);
  3877:                   Oper := WNE_Fixed_Point_Mult_Int;
  3878:                   pragma Assert (L_Type = Base);
  3879:
  3880:                --  If multiplying an integer and a fixed-point, swap
  3881:                --  arguments so that Left is the fixed-point one.
  3882:
  3883:                elsif Has_Fixed_Point_Type (Right_Type) then
  3884:                   L_Type := Base_Why_Type (Right_Type);
  3885:                   R_Type := EW_Int_Type;
  3886:                   Left_Rep := Right;
  3887:                   Right_Rep := Left;
  3888:                   Base := Base_Why_Type (Return_Type);
  3889:                   Oper := WNE_Fixed_Point_Mult_Int;
  3890:                   pragma Assert (L_Type = Base);
  3891:
  3892:                else
  3893:                   Base := Base_Why_Type (Left_Type, Right_Type);
  3894:                   L_Type := Base;
  3895:                   R_Type := Base;
  3896:                   pragma Assert (not Has_Fixed_Point_Type (Return_Type));
  3897:                end if;
  3898:
  3899:                Left_Rep :=
  3900:                  Insert_Simple_Conversion
  3901:                    (Ada_Node => Ada_Node,
  3902:                     Domain   => Domain,
  3903:                     Expr     => Left_Rep,
  3904:                     To       => L_Type);
  3905:                Right_Rep :=
  3906:                  Insert_Simple_Conversion
  3907:                    (Ada_Node => Ada_Node,
  3908:                     Domain   => Domain,
  3909:                     Expr     => Right_Rep,
  3910:                     To       => R_Type);
  3911:
  3912:                --  Construct the operation
  3913:
  3914:                if Has_Fixed_Point_Type (Left_Type)
  3915:                  or else Has_Fixed_Point_Type (Right_Type)
  3916:                then
  3917:                   declare
  3918:                      pragma Assert (Oper /= WNE_Empty);
  3919:                      Name : W_Identifier_Id;
  3920:                   begin
  3921:                      case Oper is
  3922:                         when WNE_Fixed_Point_Mult     =>
  3923:                            Name :=
  3924:                              Get_Fixed_Point_Mult_Div_Theory
  3925:                                (Typ_Left   => Left_Type,
  3926:                                 Typ_Right  => Right_Type,
  3927:                                 Typ_Result => Return_Type)
  3928:                                .Mult;
  3929:
  3930:                         when WNE_Fixed_Point_Mult_Int =>
  3931:                            Name :=
  3932:                              Get_Fixed_Point_Theory (Typ => Return_Type)
  3933:                                .Mult_Int;
  3934:
  3935:                         when others                   =>
  3936:                            raise Program_Error;
  3937:                      end case;
  3938:
  3939:                      T :=
  3940:                        New_Call
  3941:                          (Ada_Node => Ada_Node,
  3942:                           Domain   => Domain,
  3943:                           Name     => Name,
  3944:                           Args     => (1 => Left_Rep, 2 => Right_Rep),
  3945:                           Typ      => Base);
  3946:                   end;
  3947:
  3948:                elsif Has_Modular_Integer_Type (Return_Type)
  3949:                  and then
  3950:                    not Has_No_Bitwise_Operations_Annotation (Return_Type)
  3951:                  and then Non_Binary_Modulus (Return_Type)
  3952:                then
  3953:                   T :=
  3954:                     Transform_Non_Binary_Modular_Operation
  3955:                       (Ada_Node   => Ada_Node,
  3956:                        Ada_Type   => Return_Type,
  3957:                        Domain     => Domain,
  3958:                        Op         => Op,
  3959:                        Left_Opnd  => Left_Rep,
  3960:                        Right_Opnd => Right_Rep,
  3961:                        Rep_Type   => Base,
  3962:                        Modulus    => Modulus (Return_Type));
  3963:
  3964:                else
  3965:                   declare
  3966:                      Name : constant W_Identifier_Id :=
  3967:                        (if Base = EW_Int_Type
  3968:                         then Int_Infix_Mult
  3969:                         elsif Why_Type_Is_BitVector (Base)
  3970:                         then MF_BVs (Base).Mult
  3971:                         elsif Why_Type_Is_Fixed (Base)
  3972:                         then Fixed_Infix_Mult
  3973:                         else MF_Floats (Base).Mult);
  3974:                   begin
  3975:                      T :=
  3976:                        New_Call
  3977:                          (Ada_Node => Ada_Node,
  3978:                           Domain   => Domain,
  3979:                           Name     => Name,
  3980:                           Args     => (1 => Left_Rep, 2 => Right_Rep),
  3981:                           Typ      => Base);
  3982:                   end;
  3983:
  3984:                   if not Check_No_Wrap_Around then
  3985:                      T := Apply_Modulus (Op, Return_Type, T, Domain);
  3986:                   end if;
  3987:                end if;
  3988:
  3989:                if Base_Why_Type (Return_Type) /= Base then
  3990:                   T :=
  3991:                     Insert_Checked_Conversion
  3992:                       (Ada_Node => Ada_Node,
  3993:                        Domain   => Domain,
  3994:                        Expr     => T,
  3995:                        To       => Type_Of_Node (Base_Type (Return_Type)));
  3996:                end if;
  3997:             end;
```

## src/why/why-gen-expr.adb:4289-4385

```ada
  4289:    function New_Comparison
  4290:      (Symbol : W_Identifier_Id; Left, Right : W_Expr_Id; Domain : EW_Domain)
  4291:       return W_Expr_Id
  4292:    is
  4293:       Operator : W_Identifier_Id := Symbol;
  4294:       Left1    : W_Expr_Id := Left;
  4295:       Right1   : W_Expr_Id := Right;
  4296:       Arg_Type : constant W_Type_Id := Get_Type (Left);
  4297:    begin
  4298:       --  The only comparisons between Boolean operands that we translate in
  4299:       --  Why without going through integer are the equality and inequality.
  4300:       --  In a predicate context, those are translated as equivalence or
  4301:       --  inequivalence.
  4302:
  4303:       if Arg_Type = EW_Bool_Type then
  4304:          if Symbol /= Why_Eq and then Symbol /= Why_Neq then
  4305:             Left1 :=
  4306:               Insert_Simple_Conversion
  4307:                 (Domain => Domain, Expr => Left, To => EW_Int_Type);
  4308:             Right1 :=
  4309:               Insert_Simple_Conversion
  4310:                 (Domain => Domain, Expr => Right, To => EW_Int_Type);
  4311:
  4312:          --  Why3 equality operator do not apply to Booleans in program domain
  4313:          --  (only to integers). We call the Boolean's module equality operator
  4314:          --  instead.
  4315:
  4316:          elsif Domain in EW_Prog | EW_Pterm then
  4317:             if Symbol = Why_Eq then
  4318:                Operator := M_Boolean.Bool_Eq;
  4319:             else
  4320:                Operator := M_Boolean.Bool_Ne;
  4321:             end if;
  4322:          end if;
  4323:       end if;
  4324:
  4325:       return
  4326:         New_Call
  4327:           (Domain => Domain,
  4328:            Name   => Operator,
  4329:            Args   => (Left1, Right1),
  4330:            Typ    => EW_Bool_Type);
  4331:    end New_Comparison;
  4332:
  4333:    --------------------------
  4334:    -- New_Dynamic_Property --
  4335:    --------------------------
  4336:
  4337:    function New_Dynamic_Property
  4338:      (Domain : EW_Domain;
  4339:       Ty     : Entity_Id;
  4340:       Expr   : W_Term_Id;
  4341:       Params : Transformation_Params := Body_Params) return W_Expr_Id is
  4342:    begin
  4343:       --  For now, only supports dynamic scalar types, unconstrained array
  4344:       --  types and record or private types with discriminants.
  4345:
  4346:       if Is_Scalar_Type (Ty)
  4347:         and then
  4348:           (Type_Is_Modeled_As_Base (Ty) or else Use_Split_Form_For_Type (Ty))
  4349:       then
  4350:
  4351:          pragma Assert (not Depends_On_Discriminant (Get_Range (Ty)));
  4352:
  4353:          return
  4354:            New_Call
  4355:              (Domain => Domain,
  4356:               Name   => Dynamic_Prop_Name (Ty),
  4357:               Args   =>
  4358:                 Args_For_Scalar_Dynamic_Property
  4359:                   (Ty, +Expr, Term_Domain (Domain), Params),
  4360:               Typ    => EW_Bool_Type);
  4361:
  4362:       elsif Is_Array_Type (Ty) and then not Is_Static_Array_Type (Ty) then
  4363:          declare
  4364:             Dim  : constant Positive := Positive (Number_Dimensions (Ty));
  4365:             Args : W_Expr_Array (1 .. 2 * Dim);
  4366:          begin
  4367:             for Count in 0 .. Dim - 1 loop
  4368:                declare
  4369:                   F_Expr : constant W_Term_Id :=
  4370:                     Get_Array_Attr
  4371:                       (Expr => Expr,
  4372:                        Attr => Attribute_First,
  4373:                        Dim  => Count + 1);
  4374:                   L_Expr : constant W_Term_Id :=
  4375:                     Get_Array_Attr
  4376:                       (Expr => Expr, Attr => Attribute_Last, Dim => Count + 1);
  4377:                begin
  4378:                   Args (2 * Count + 1) := +F_Expr;
  4379:                   Args (2 * Count + 2) := +L_Expr;
  4380:                end;
  4381:             end loop;
  4382:
  4383:             return New_Dynamic_Property (Domain, Ty, Args, Params);
  4384:          end;
  4385:
```

## src/why/why-gen-expr.adb:4488-4535

```ada
  4488:    function New_Discrete_Constant
  4489:      (Ada_Node : Node_Id := Empty; Value : Uint; Typ : W_Type_Id)
  4490:       return W_Expr_Id
  4491:    is (if Typ = EW_Bool_Type
  4492:        then
  4493:          (if Value = Uint_0
  4494:           then Bool_False (EW_Term)
  4495:           elsif Value = Uint_1
  4496:           then Bool_True (EW_Term)
  4497:           else raise Program_Error)
  4498:        elsif Why_Type_Is_BitVector (Typ)
  4499:        then New_Modular_Constant (Ada_Node, Value, Typ)
  4500:        else New_Integer_Constant (Ada_Node, Value));
  4501:
  4502:    --------------------
  4503:    -- New_Havoc_Call --
  4504:    --------------------
  4505:
  4506:    function New_Havoc_Call (Id : W_Identifier_Id) return W_Prog_Id is
  4507:       Havoc_Fun : constant W_Identifier_Id :=
  4508:         Havoc_Append (Get_Name (Get_Typ (Id)));
  4509:    begin
  4510:       return New_Call (Name => Havoc_Fun, Args => (1 => +Id));
  4511:    end New_Havoc_Call;
  4512:
  4513:    ------------------------------------------
  4514:    -- New_Is_Valid_Call_For_Constrained_Ty --
  4515:    ------------------------------------------
  4516:
  4517:    function New_Is_Valid_Call_For_Constrained_Ty
  4518:      (Tree   : W_Term_Id;
  4519:       Ty     : Type_Kind_Id;
  4520:       Domain : EW_Domain;
  4521:       Params : Transformation_Params) return W_Expr_Id
  4522:    is
  4523:
  4524:       function Additional_Params_For_Is_Valid_Call return W_Expr_Array;
  4525:       --  Compute the parameters that should be supplied in addition to the
  4526:       --  validity tree in a call to Is_Valid for a constrained type Ty.
  4527:
  4528:       -----------------------------------------
  4529:       -- Additional_Params_For_Is_Valid_Call --
  4530:       -----------------------------------------
  4531:
  4532:       function Additional_Params_For_Is_Valid_Call return W_Expr_Array is
  4533:          Rep_Ty : constant Type_Kind_Id := Retysp (Ty);
  4534:       begin
  4535:          if Has_Discriminants (Ty) then
```

## src/why/why-gen-expr.adb:4816-4837

```ada
  4816:    function New_Or_Else_Expr
  4817:      (Left, Right : W_Expr_Id; Domain : EW_Domain) return W_Expr_Id is
  4818:    begin
  4819:       if Is_False_Boolean (Left) then
  4820:          return Right;
  4821:       elsif Is_False_Boolean (Right) then
  4822:          return Left;
  4823:       else
  4824:          if Domain = EW_Prog then
  4825:             return
  4826:               New_Connection
  4827:                 (Domain => Domain,
  4828:                  Op     => EW_Or_Else,
  4829:                  Left   => Left,
  4830:                  Right  => Right);
  4831:          else
  4832:             return New_Or_Expr (Left, Right, Domain);
  4833:          end if;
  4834:       end if;
  4835:    end New_Or_Else_Expr;
  4836:
  4837:    -----------------
```

## src/why/why-gen-expr.adb:4883-4956

```ada
  4883:    function New_Range_Expr
  4884:      (Domain    : EW_Domain;
  4885:       Low, High : W_Expr_Id;
  4886:       Expr      : W_Expr_Id;
  4887:       Pretty    : Boolean := False) return W_Expr_Id
  4888:    is
  4889:       Ty    : constant W_Type_Id :=
  4890:         (if Get_Type_Kind (Get_Type (Low)) = EW_Split
  4891:          then Base_Why_Type (Get_Ada_Node (+Get_Type (Low)))
  4892:          else Get_Type (Low));
  4893:       Le    : constant W_Identifier_Id :=
  4894:         (if Ty = EW_Int_Type or else Why_Type_Is_Fixed (Ty)
  4895:          then Int_Infix_Le
  4896:          elsif Why_Type_Is_BitVector (Ty)
  4897:          then MF_BVs (Ty).Ule
  4898:          else MF_Floats (Ty).Le);
  4899:       Left  : W_Expr_Id :=
  4900:         New_Comparison
  4901:           (Domain => Domain, Symbol => Le, Left => Low, Right => Expr);
  4902:       Right : W_Expr_Id :=
  4903:         New_Comparison
  4904:           (Domain => Domain, Symbol => Le, Left => Expr, Right => High);
  4905:    begin
  4906:       if Pretty then
  4907:          Left :=
  4908:            New_Label
  4909:              (Labels =>
  4910:                 Symbol_Sets.To_Set
  4911:                   (NID (GP_Pretty_Ada_Marker & Integer'Image (Low_Bound_Id))),
  4912:               Def    => Left,
  4913:               Domain => Domain);
  4914:          Right :=
  4915:            New_Label
  4916:              (Labels =>
  4917:                 Symbol_Sets.To_Set
  4918:                   (NID (GP_Pretty_Ada_Marker & Integer'Image (High_Bound_Id))),
  4919:               Def    => Right,
  4920:               Domain => Domain);
  4921:       end if;
  4922:       return New_And_Expr (Left, Right, Domain);
  4923:    end New_Range_Expr;
  4924:
  4925:    function New_Range_Expr
  4926:      (Low, High : W_Term_Id; Expr : W_Term_Id) return W_Pred_Id is
  4927:    begin
  4928:       --  ??? gnatcov complains if this is an expression function (V330-044);
  4929:       --  otherwise it could be declared in spec.
  4930:       return +W_Expr_Id'(New_Range_Expr (EW_Pred, +Low, +High, +Expr));
  4931:    end New_Range_Expr;
  4932:
  4933:    ---------------------------
  4934:    -- New_Simpl_Conditional --
  4935:    ---------------------------
  4936:
  4937:    function New_Simpl_Conditional
  4938:      (Condition : W_Expr_Id;
  4939:       Then_Part : W_Expr_Id;
  4940:       Else_Part : W_Expr_Id;
  4941:       Domain    : EW_Domain) return W_Expr_Id is
  4942:    begin
  4943:       if Is_True_Boolean (Condition) then
  4944:          return Then_Part;
  4945:       elsif Is_False_Boolean (Condition) then
  4946:          return Else_Part;
  4947:       else
  4948:          return
  4949:            New_Conditional
  4950:              (Condition => +Condition,
  4951:               Then_Part => Then_Part,
  4952:               Else_Part => Else_Part,
  4953:               Domain    => Domain,
  4954:               Typ       => Get_Type (Then_Part));
  4955:       end if;
  4956:    end New_Simpl_Conditional;
```

## src/why/why-gen-expr.adb:4962-5010

```ada
  4962:    function New_Temp_For_Expr
  4963:      (E : W_Expr_Id; Need_Temp : Boolean := True) return W_Expr_Id is
  4964:    begin
  4965:       --  Internally, we use a map to store the expression for which we
  4966:       --  introduce a temporary variable. The map holds entries:
  4967:       --    Identifier -> Expr
  4968:       --  It allows us (in Binding_For_Temp) to get the expression for the temp
  4969:       --
  4970:       --  When it is not actually necessary to generate a temp for Expr, we
  4971:       --  do not introduce any binding in the map. We used to generate a
  4972:       --  binding Expr => Empty to distinguish (in Binding_For_Temp)
  4973:       --  between incorrect usage of the API and a value for which no temp was
  4974:       --  necessary. We do not anymore as we could not know how many times
  4975:       --  New_Temp_For_Expr had been called for Expr and so how long we should
  4976:       --  keep Expr => Empty in the table.
  4977:       --
  4978:       --  We always generate a temp for an expression which itself is a
  4979:       --  temporary. Otherwise we would be missing the reference the second
  4980:       --  time we call Binding_For_Temp.
  4981:
  4982:       if (Need_Temp and then Get_Kind (+E) not in W_Identifier | W_Deref)
  4983:         or else Temp_Names_Map.Contains (+E)
  4984:       then
  4985:          declare
  4986:             Tmp : constant W_Expr_Id :=
  4987:               +New_Temp_Identifier
  4988:                  (Ada_Node => Get_Ada_Node (+E), Typ => Get_Type (E));
  4989:          begin
  4990:             Temp_Names_Map.Insert (+Tmp, +E);
  4991:             return Tmp;
  4992:          end;
  4993:       else
  4994:          return E;
  4995:       end if;
  4996:    end New_Temp_For_Expr;
  4997:
  4998:    -----------------------
  4999:    -- New_Typed_Binding --
  5000:    -----------------------
  5001:
  5002:    function New_Typed_Binding
  5003:      (Ada_Node : Node_Id := Empty;
  5004:       Domain   : EW_Domain;
  5005:       Name     : W_Identifier_Id;
  5006:       Def      : W_Expr_Id;
  5007:       Context  : W_Expr_Id) return W_Expr_Id is
  5008:    begin
  5009:       return
  5010:         New_Binding (Ada_Node, Domain, Name, Def, Context, Get_Type (Context));
```

## src/why/why-gen-expr.adb:5282-5323

```ada
  5282:    function New_VC_Call
  5283:      (Ada_Node   : Node_Id;
  5284:       Name       : W_Identifier_Id;
  5285:       Progs      : W_Expr_Array;
  5286:       Reason     : VC_Kind;
  5287:       Typ        : W_Type_Id;
  5288:       Check_Info : Check_Info_Type := New_Check_Info) return W_Prog_Id
  5289:    is
  5290:       Call : constant W_Prog_Id :=
  5291:         New_Call
  5292:           (Ada_Node => Ada_Node, Name => Name, Args => Progs, Typ => Typ);
  5293:    begin
  5294:       return
  5295:         New_VC_Prog
  5296:           (Ada_Node   => Ada_Node,
  5297:            Reason     => Reason,
  5298:            Check_Info => Check_Info,
  5299:            Expr       => Call);
  5300:    end New_VC_Call;
  5301:
  5302:    -----------------
  5303:    -- New_VC_Expr --
  5304:    -----------------
  5305:
  5306:    function New_VC_Expr
  5307:      (Ada_Node   : Node_Id;
  5308:       Expr       : W_Expr_Id;
  5309:       Reason     : VC_Kind;
  5310:       Domain     : EW_Domain;
  5311:       Check_Info : Check_Info_Type := New_Check_Info) return W_Expr_Id is
  5312:    begin
  5313:       return
  5314:         Insert_Cnt_Loc_Label
  5315:           (Ada_Node => Ada_Node,
  5316:            E        =>
  5317:              New_Label
  5318:                (Ada_Node => Ada_Node,
  5319:                 Labels   => New_VC_Labels (Ada_Node, Reason, Check_Info),
  5320:                 Def      => Expr,
  5321:                 Domain   => Domain,
  5322:                 Typ      => Get_Type (Expr)));
  5323:    end New_VC_Expr;
```

## src/why/why-gen-expr.adb:5436-5541

```ada
  5436:    function Pred_Of_Boolean_Term (W : W_Term_Id) return W_Pred_Id
  5437:    is (New_Call
  5438:          (Name => Why_Eq,
  5439:           Args => (1 => +W, 2 => +Bool_True (EW_Term)),
  5440:           Typ  => EW_Bool_Type));
  5441:
  5442:    --------------------------
  5443:    -- Transform_Compare_Op --
  5444:    --------------------------
  5445:
  5446:    function Transform_Compare_Op
  5447:      (Op : N_Op_Compare; Ty : W_Type_Id; Domain : EW_Domain)
  5448:       return W_Identifier_Id is
  5449:    begin
  5450:       if Domain = EW_Term then
  5451:          if Ty in EW_Int_Type | EW_Bool_Type or else Why_Type_Is_Fixed (Ty)
  5452:          then
  5453:             case Op is
  5454:                when N_Op_Gt =>
  5455:                   return M_Integer.Bool_Gt;
  5456:
  5457:                when N_Op_Lt =>
  5458:                   return M_Integer.Bool_Lt;
  5459:
  5460:                when N_Op_Eq =>
  5461:                   return M_Integer.Bool_Eq;
  5462:
  5463:                when N_Op_Ne =>
  5464:                   return M_Integer.Bool_Ne;
  5465:
  5466:                when N_Op_Ge =>
  5467:                   return M_Integer.Bool_Ge;
  5468:
  5469:                when N_Op_Le =>
  5470:                   return M_Integer.Bool_Le;
  5471:             end case;
  5472:          elsif Why_Type_Is_Float (Ty) then
  5473:             case Op is
  5474:                when N_Op_Gt =>
  5475:                   return MF_Floats (Ty).Bool_Gt;
  5476:
  5477:                when N_Op_Lt =>
  5478:                   return MF_Floats (Ty).Bool_Lt;
  5479:
  5480:                when N_Op_Eq =>
  5481:                   return MF_Floats (Ty).Bool_Eq;
  5482:
  5483:                when N_Op_Ne =>
  5484:                   return MF_Floats (Ty).Bool_Ne;
  5485:
  5486:                when N_Op_Ge =>
  5487:                   return MF_Floats (Ty).Bool_Ge;
  5488:
  5489:                when N_Op_Le =>
  5490:                   return MF_Floats (Ty).Bool_Le;
  5491:             end case;
  5492:          elsif Why_Type_Is_BitVector (Ty) then
  5493:             case Op is
  5494:                when N_Op_Gt =>
  5495:                   return MF_BVs (Ty).Bool_Gt;
  5496:
  5497:                when N_Op_Lt =>
  5498:                   return MF_BVs (Ty).Bool_Lt;
  5499:
  5500:                when N_Op_Eq =>
  5501:                   return MF_BVs (Ty).Bool_Eq;
  5502:
  5503:                when N_Op_Ne =>
  5504:                   return MF_BVs (Ty).Bool_Ne;
  5505:
  5506:                when N_Op_Ge =>
  5507:                   return MF_BVs (Ty).Bool_Ge;
  5508:
  5509:                when N_Op_Le =>
  5510:                   return MF_BVs (Ty).Bool_Le;
  5511:             end case;
  5512:          else
  5513:             raise Program_Error;
  5514:          end if;
  5515:       elsif Ty in EW_Int_Type | EW_Bool_Type or else Why_Type_Is_Fixed (Ty)
  5516:       then
  5517:          case Op is
  5518:             when N_Op_Gt =>
  5519:                return Int_Infix_Gt;
  5520:
  5521:             when N_Op_Lt =>
  5522:                return Int_Infix_Lt;
  5523:
  5524:             when N_Op_Eq =>
  5525:                return Why_Eq;
  5526:
  5527:             when N_Op_Ne =>
  5528:                return Why_Neq;
  5529:
  5530:             when N_Op_Ge =>
  5531:                return Int_Infix_Ge;
  5532:
  5533:             when N_Op_Le =>
  5534:                return Int_Infix_Le;
  5535:          end case;
  5536:       elsif Why_Type_Is_Float (Ty) then
  5537:          case Op is
  5538:             when N_Op_Gt =>
  5539:                return MF_Floats (Ty).Gt;
  5540:
  5541:             when N_Op_Lt =>
```

## src/why/why-gen-expr.adb:280-305

```ada
   280:    function Args_For_Scalar_Dynamic_Property
   281:      (Ty     : Entity_Id;
   282:       Expr   : W_Expr_Id;
   283:       Domain : EW_Terms;
   284:       Params : Transformation_Params := Body_Params) return W_Expr_Array is
   285:    begin
   286:       return
   287:         (1 =>
   288:            New_Attribute_Expr
   289:              (Ty     => Ty,
   290:               Domain => Domain,
   291:               Attr   => Attribute_First,
   292:               Params => Params),
   293:          2 =>
   294:            New_Attribute_Expr
   295:              (Ty     => Ty,
   296:               Domain => Domain,
   297:               Attr   => Attribute_Last,
   298:               Params => Params),
   299:          3 =>
   300:            Insert_Simple_Conversion
   301:              (Ada_Node => Ty,
   302:               Domain   => Domain,
   303:               Expr     => Expr,
   304:               To       => Base_Why_Type (Ty)));
   305:    end Args_For_Scalar_Dynamic_Property;
```

## src/why/why-gen-expr.adb:4337-4418

```ada
  4337:    function New_Dynamic_Property
  4338:      (Domain : EW_Domain;
  4339:       Ty     : Entity_Id;
  4340:       Expr   : W_Term_Id;
  4341:       Params : Transformation_Params := Body_Params) return W_Expr_Id is
  4342:    begin
  4343:       --  For now, only supports dynamic scalar types, unconstrained array
  4344:       --  types and record or private types with discriminants.
  4345:
  4346:       if Is_Scalar_Type (Ty)
  4347:         and then
  4348:           (Type_Is_Modeled_As_Base (Ty) or else Use_Split_Form_For_Type (Ty))
  4349:       then
  4350:
  4351:          pragma Assert (not Depends_On_Discriminant (Get_Range (Ty)));
  4352:
  4353:          return
  4354:            New_Call
  4355:              (Domain => Domain,
  4356:               Name   => Dynamic_Prop_Name (Ty),
  4357:               Args   =>
  4358:                 Args_For_Scalar_Dynamic_Property
  4359:                   (Ty, +Expr, Term_Domain (Domain), Params),
  4360:               Typ    => EW_Bool_Type);
  4361:
  4362:       elsif Is_Array_Type (Ty) and then not Is_Static_Array_Type (Ty) then
  4363:          declare
  4364:             Dim  : constant Positive := Positive (Number_Dimensions (Ty));
  4365:             Args : W_Expr_Array (1 .. 2 * Dim);
  4366:          begin
  4367:             for Count in 0 .. Dim - 1 loop
  4368:                declare
  4369:                   F_Expr : constant W_Term_Id :=
  4370:                     Get_Array_Attr
  4371:                       (Expr => Expr,
  4372:                        Attr => Attribute_First,
  4373:                        Dim  => Count + 1);
  4374:                   L_Expr : constant W_Term_Id :=
  4375:                     Get_Array_Attr
  4376:                       (Expr => Expr, Attr => Attribute_Last, Dim => Count + 1);
  4377:                begin
  4378:                   Args (2 * Count + 1) := +F_Expr;
  4379:                   Args (2 * Count + 2) := +L_Expr;
  4380:                end;
  4381:             end loop;
  4382:
  4383:             return New_Dynamic_Property (Domain, Ty, Args, Params);
  4384:          end;
  4385:
  4386:       elsif Has_Discriminants (Ty) and then Is_Constrained (Ty) then
  4387:          declare
  4388:             Base_Expr : constant W_Expr_Id :=
  4389:               Insert_Simple_Conversion
  4390:                 (Domain   => EW_Term,
  4391:                  Ada_Node => Ty,
  4392:                  To       => EW_Abstract (Root_Retysp (Ty)),
  4393:                  Expr     => +Expr);
  4394:          begin
  4395:             return
  4396:               New_Call
  4397:                 (Name   => Range_Pred_Name (Root_Retysp (Ty)),
  4398:                  Args   =>
  4399:                    Prepare_Args_For_Subtype_Check
  4400:                      (Ty, Base_Expr, Term_Domain (Domain), Params),
  4401:                  Domain => Domain,
  4402:                  Typ    => EW_Bool_Type);
  4403:          end;
  4404:
  4405:       else
  4406:          raise Program_Error;
  4407:       end if;
  4408:    end New_Dynamic_Property;
  4409:
  4410:    ----------------------
  4411:    -- New_Discrete_Add --
  4412:    ----------------------
  4413:
  4414:    function New_Discrete_Add
  4415:      (Domain : EW_Domain;
  4416:       Left   : W_Expr_Id;
  4417:       Right  : W_Expr_Id;
  4418:       Typ    : W_Type_Id := Why_Empty) return W_Expr_Id
```

## src/why/why-gen-expr.adb:3485-3572

```ada
  3485:    function New_And_Expr
  3486:      (Left, Right : W_Expr_Id; Domain : EW_Domain) return W_Expr_Id is
  3487:    begin
  3488:       if Is_True_Boolean (+Left) then
  3489:          return Right;
  3490:       elsif Is_True_Boolean (+Right) then
  3491:          return Left;
  3492:       elsif Domain = EW_Pred then
  3493:          return
  3494:            New_Connection
  3495:              (Domain => Domain, Op => EW_And, Left => +Left, Right => +Right);
  3496:       else
  3497:          return
  3498:            New_Call
  3499:              (Domain => Domain,
  3500:               Name   => M_Boolean.Andb,
  3501:               Args   => (1 => +Left, 2 => +Right),
  3502:               Typ    => EW_Bool_Type);
  3503:       end if;
  3504:    end New_And_Expr;
  3505:
  3506:    function New_And_Expr
  3507:      (Left, Right : W_Expr_Id; Domain : EW_Domain; Base : W_Type_Id)
  3508:       return W_Expr_Id is
  3509:    begin
  3510:       if Base = EW_BitVector_8_Type
  3511:         or else Base = EW_BitVector_16_Type
  3512:         or else Base = EW_BitVector_32_Type
  3513:         or else Base = EW_BitVector_64_Type
  3514:         or else Base = EW_BitVector_128_Type
  3515:       then
  3516:          return
  3517:            New_Call
  3518:              (Domain => Domain,
  3519:               Name   => MF_BVs (Base).BW_And,
  3520:               Args   => (1 => +Left, 2 => +Right),
  3521:               Typ    => Base);
  3522:       elsif Base = EW_Bool_Type then
  3523:          return New_And_Expr (Left, Right, Domain);
  3524:       else
  3525:          raise Program_Error;
  3526:       end if;
  3527:    end New_And_Expr;
  3528:
  3529:    ------------------
  3530:    -- New_And_Pred --
  3531:    ------------------
  3532:
  3533:    function New_And_Pred (Conjuncts : W_Pred_Array) return W_Pred_Id is
  3534:       Filtered : W_Pred_Array (1 .. Conjuncts'Length);
  3535:       Count    : Natural := 0;
  3536:    begin
  3537:       for Conjunct of Conjuncts loop
  3538:          if Is_True_Boolean (+Conjunct) then
  3539:             null;
  3540:          elsif Is_False_Boolean (+Conjunct) then
  3541:             return False_Pred;
  3542:          else
  3543:             Count := Count + 1;
  3544:             Filtered (Count) := Conjunct;
  3545:          end if;
  3546:       end loop;
  3547:
  3548:       if Count = 0 then
  3549:          return True_Pred;
  3550:
  3551:       elsif Count = 1 then
  3552:          return Filtered (1);
  3553:
  3554:       else
  3555:          --  We use the array form with "More_Right" here for these reasons:
  3556:          --  - It avoids a deeply nested tree. Such deep nesting could lead
  3557:          --    to a stack overflow in code that traverses the whole tree;
  3558:          --  - The array form receives special handling in why3, creating a
  3559:          --    balanced tree of binary conjunctions, again to avoid deeply
  3560:          --    nested trees.
  3561:
  3562:          return
  3563:            New_Connection
  3564:              (Op         => EW_And,
  3565:               Left       => Filtered (1),
  3566:               Right      => Filtered (2),
  3567:               More_Right => Filtered (3 .. Count));
  3568:       end if;
  3569:    end New_And_Pred;
  3570:
  3571:    -----------------------
  3572:    -- New_And_Then_Expr --
```

## src/why/why-gen-expr.ads:65-78

```ada
    65:    function Bool_True (D : EW_Domain) return W_Expr_Id
    66:    is (New_Literal (Value => EW_True, Domain => D));
    67:    function Bool_False (D : EW_Domain) return W_Expr_Id
    68:    is (New_Literal (Value => EW_False, Domain => D));
    69:
    70:    function Pred_Of_Boolean_Term (W : W_Term_Id) return W_Pred_Id;
    71:    --  @param W a Why3 term expression
    72:    --  @return the equivalent Why3 pred expression
    73:
    74:    function Boolean_Expr_Of_Pred
    75:      (W : W_Pred_Id; Domain : EW_Domain) return W_Expr_Id;
    76:    --  @param W a Why3 pred expression
    77:    --  @param Domain translation domain
    78:    --  @return the equivalent Why3 expression, depending on the [Domain]
```

## src/why/why-gen-expr.ads:96-105

```ada
    96:
    97:    function New_And_Term (Left, Right : W_Term_Id) return W_Term_Id
    98:    is (+New_And_Expr (+Left, +Right, EW_Term));
    99:
   100:    function New_And_Pred (Left, Right : W_Pred_Id) return W_Pred_Id
   101:    is (+New_And_Expr (+Left, +Right, EW_Pred));
   102:
   103:    function New_And_Expr
   104:      (Left, Right : W_Expr_Id; Domain : EW_Domain; Base : W_Type_Id)
   105:       return W_Expr_Id
```

## src/why/why-gen-expr.ads:305-311

```ada
   305:    function New_VC_Prog
   306:      (Ada_Node   : Node_Id;
   307:       Expr       : W_Prog_Id;
   308:       Reason     : VC_Kind;
   309:       Check_Info : Check_Info_Type := New_Check_Info) return W_Prog_Id
   310:    is (+New_VC_Expr (Ada_Node, +Expr, Reason, EW_Prog, Check_Info));
   311:
```

## src/why/why-gen-init.adb:502-554

```ada
   502:    function Insert_Initialization_Check
   503:      (Ada_Node           : Node_Id;
   504:       E                  : Entity_Id;
   505:       Name               : W_Expr_Id;
   506:       Domain             : EW_Domain;
   507:       Exclude_Components : Exclude_Components_Kind;
   508:       No_Predicate_Check : Boolean := False) return W_Expr_Id
   509:    is
   510:       Tmp : constant W_Expr_Id := New_Temp_For_Expr (Name);
   511:       T   : W_Expr_Id;
   512:    begin
   513:       --  We need initialization checking if either Name is an expression with
   514:       --  relaxed initialization or if it contains subcomponents with
   515:       --  relaxed initialization and checks should be introduced for
   516:       --  these subcomponents (Exclude_Components is not Relaxed).
   517:
   518:       if Domain = EW_Prog
   519:         and then
   520:           (Is_Init_Wrapper_Type (Get_Type (Name))
   521:            or else
   522:              (Exclude_Components /= Relaxed
   523:               and then Contains_Relaxed_Init_Parts (E, Ignore_Top => True)))
   524:       then
   525:          T :=
   526:            +Sequence
   527:               (Ada_Node => Get_Ada_Node (+Tmp),
   528:                Left     =>
   529:                  New_Located_Assert
   530:                    (Ada_Node => Ada_Node,
   531:                     Pred     =>
   532:                       +Compute_Is_Initialized
   533:                          (E,
   534:                           +Tmp,
   535:                           Params             => Body_Params,
   536:                           Exclude_Components => Exclude_Components,
   537:                           No_Predicate_Check => No_Predicate_Check,
   538:                           Domain             => EW_Pred),
   539:                     Reason   => VC_Initialization_Check,
   540:                     Kind     => EW_Assert),
   541:                Right    => +Tmp);
   542:          T :=
   543:            Binding_For_Temp
   544:              (Ada_Node => Get_Ada_Node (+Tmp),
   545:               Domain   => Domain,
   546:               Tmp      => Tmp,
   547:               Context  => T);
   548:          return T;
   549:       else
   550:          return Name;
   551:       end if;
   552:    end Insert_Initialization_Check;
   553:
   554:    --------------------------
```

## src/why/why-gen-names.adb:68-160

```ada
    68:    function Append_Num (S : String; Count : Positive) return String is
    69:    begin
    70:       return (if Count = 1 then S else S & "_" & Image (Count, 1));
    71:    end Append_Num;
    72:
    73:    function Append_Num
    74:      (S         : String;
    75:       Count     : Positive;
    76:       Namespace : Symbol := No_Symbol;
    77:       Module    : W_Module_Id := Why.Types.Why_Empty;
    78:       Typ       : W_Type_Id := Why.Types.Why_Empty;
    79:       Ada_Node  : Node_Id := Empty) return W_Identifier_Id is
    80:    begin
    81:       return
    82:         New_Identifier
    83:           (Domain    => EW_Term,
    84:            Name      => Append_Num (S, Count),
    85:            Module    => Module,
    86:            Namespace => Namespace,
    87:            Ada_Node  => Ada_Node,
    88:            Typ       => Typ);
    89:    end Append_Num;
    90:
    91:    -----------------
    92:    -- Attr_Append --
    93:    -----------------
    94:
    95:    function Attr_Append
    96:      (Base     : String;
    97:       A        : Attribute_Id;
    98:       Count    : Positive;
    99:       Typ      : W_Type_Id;
   100:       Module   : W_Module_Id := Why.Types.Why_Empty;
   101:       Ada_Node : Node_Id := Empty) return W_Identifier_Id is
   102:    begin
   103:       return
   104:         Append_Num
   105:           (S        => Base & "__" & To_String (Attr_To_Why_Name (A)),
   106:            Count    => Count,
   107:            Typ      => Typ,
   108:            Module   => Module,
   109:            Ada_Node => Ada_Node);
   110:    end Attr_Append;
   111:
   112:    function Attr_Append
   113:      (Base  : W_Identifier_Id;
   114:       A     : Attribute_Id;
   115:       Count : Positive;
   116:       Typ   : W_Type_Id) return W_Identifier_Id
   117:    is
   118:       Name : constant W_Name_Id := Get_Name (Base);
   119:    begin
   120:       return
   121:         Attr_Append
   122:           (Img (Get_Symb (Name)),
   123:            A,
   124:            Count,
   125:            Typ,
   126:            Get_Module (Name),
   127:            Get_Ada_Node (+Base));
   128:    end Attr_Append;
   129:
   130:    ----------------------
   131:    -- Attr_To_Why_Name --
   132:    ----------------------
   133:
   134:    function Attr_To_Why_Name (A : Attribute_Id) return Why_Name_Enum
   135:    is (case A is
   136:          when Attribute_Constrained => WNE_Attr_Constrained,
   137:          when Attribute_First       => WNE_Attr_First,
   138:          when Attribute_Last        => WNE_Attr_Last,
   139:          when Attribute_Tag         => WNE_Attr_Tag,
   140:          when others                => raise Program_Error);
   141:
   142:    --------------------
   143:    -- Content_Append --
   144:    --------------------
   145:
   146:    function Content_Append
   147:      (Base : W_Name_Id; Typ : W_Type_Id) return W_Identifier_Id is
   148:    begin
   149:       return
   150:         Append_Num
   151:           (S        => Img (Get_Symb (Base)) & To_String (WNE_Content),
   152:            Count    => 1,
   153:            Typ      => Typ,
   154:            Module   => Get_Module (Base),
   155:            Ada_Node => Get_Ada_Node (+Base));
   156:    end Content_Append;
   157:
   158:    ---------------------
   159:    -- Conversion_Name --
   160:    ---------------------
```

## src/why/why-gen-names.adb:162-392

```ada
   162:    function Conversion_Name
   163:      (From : W_Type_Id; To : W_Type_Id) return W_Identifier_Id
   164:    is
   165:       From_Kind : constant EW_Type := Get_Type_Kind (From);
   166:       To_Kind   : constant EW_Type := Get_Type_Kind (To);
   167:    begin
   168:       case From_Kind is
   169:          when EW_Builtin             =>
   170:             case To_Kind is
   171:                when EW_Builtin             =>
   172:
   173:                   --  Only certain conversions are OK
   174:
   175:                   if From = EW_Int_Type and then Why_Type_Is_Float (To) then
   176:                      return MF_Floats (To).Of_Int;
   177:
   178:                   --  Conversions from real to int in Ada round to the nearest
   179:                   --  integer, and away from zero in case of tie, exactly like
   180:                   --  'Rounding attribute.
   181:
   182:                   elsif Why_Type_Is_Float (From) then
   183:                      return
   184:                        (if To = EW_Int_Type
   185:                         then MF_Floats (From).To_Int
   186:                         elsif To = EW_BitVector_8_Type
   187:                         then MF_Floats (From).To_BV8
   188:                         elsif To = EW_BitVector_16_Type
   189:                         then MF_Floats (From).To_BV16
   190:                         elsif To = EW_BitVector_32_Type
   191:                         then MF_Floats (From).To_BV32
   192:                         elsif To = EW_BitVector_64_Type
   193:                         then MF_Floats (From).To_BV64
   194:                         --  Conversions between 32-bits and 64-bits floats
   195:                         elsif From = EW_Float_64_Type
   196:                           and then To = EW_Float_32_Type
   197:                         then M_Float32_64_Conv.To_Small
   198:                         elsif From = EW_Float_32_Type
   199:                           and then To = EW_Float_64_Type
   200:                         then M_Float32_64_Conv.To_Large
   201:                         --  Conversions between 32-bits and 80-bits floats
   202:                         elsif From = EW_Float_80_Type
   203:                           and then To = EW_Float_32_Type
   204:                         then M_Float32_80_Conv.To_Small
   205:                         elsif From = EW_Float_32_Type
   206:                           and then To = EW_Float_80_Type
   207:                         then M_Float32_80_Conv.To_Large
   208:                         --  Conversions between 64-bits and 80-bits floats
   209:                         elsif From = EW_Float_80_Type
   210:                           and then To = EW_Float_64_Type
   211:                         then M_Float64_80_Conv.To_Small
   212:                         elsif From = EW_Float_64_Type
   213:                           and then To = EW_Float_80_Type
   214:                         then M_Float64_80_Conv.To_Large
   215:                         else raise Program_Error);
   216:                   elsif From = EW_Bool_Type and then To = EW_Int_Type then
   217:                      return M_Boolean.To_Int;
   218:                   elsif From = EW_Int_Type and then To = EW_Bool_Type then
   219:                      return M_Boolean.Of_Int;
   220:                   elsif Why_Type_Is_BitVector (From) and then To = EW_Int_Type
   221:                   then
   222:                      return MF_BVs (From).To_Int;
   223:
   224:                   elsif Why_Type_Is_BitVector (From)
   225:                     and then Why_Type_Is_Float (To)
   226:                   then
   227:                      return
   228:                        (if From = EW_BitVector_8_Type
   229:                         then MF_Floats (To).Of_BV8
   230:                         elsif From = EW_BitVector_16_Type
   231:                         then MF_Floats (To).Of_BV16
   232:                         elsif From = EW_BitVector_32_Type
   233:                         then MF_Floats (To).Of_BV32
   234:                         elsif From = EW_BitVector_64_Type
   235:                         then MF_Floats (To).Of_BV64
   236:                         else raise Program_Error);
   237:
   238:                   elsif From = EW_Int_Type and then Why_Type_Is_BitVector (To)
   239:                   then
   240:                      return MF_BVs (To).Of_Int;
   241:                   elsif Why_Type_Is_BitVector (From)
   242:                     and then Why_Type_Is_BitVector (To)
   243:                   then
   244:                      return Get_Modular_Converter (From, To);
   245:                   --  Either the two objects are of the same type
   246:                   --  (in which case the conversion is useless) or
   247:                   --  they are of incompatible types
   248:                   --  In both cases, it is an error.
   249:
   250:                   --  For fixed point types, get the underlying fixed point
   251:                   --  theory.
   252:
   253:                   elsif Why_Type_Is_Fixed (From) and then To = EW_Int_Type then
   254:                      return
   255:                        Get_Fixed_Point_Theory (Get_Ada_Node (+From)).To_Int;
   256:                   elsif From = EW_Int_Type and then Why_Type_Is_Fixed (To) then
   257:                      return Get_Fixed_Point_Theory (Get_Ada_Node (+To)).Of_Int;
   258:                   elsif From = EW_Bool_Type
   259:                     and then To = M_Boolean_Init_Wrapper.Wrapper_Ty
   260:                   then
   261:                      return M_Boolean_Init_Wrapper.To_Wrapper;
   262:                   elsif From = M_Boolean_Init_Wrapper.Wrapper_Ty
   263:                     and then To = EW_Bool_Type
   264:                   then
   265:                      return M_Boolean_Init_Wrapper.Of_Wrapper;
   266:                   else
   267:                      raise Program_Error;
   268:                   end if;
   269:
   270:                when EW_Abstract | EW_Split =>
   271:                   declare
   272:                      A : constant Node_Id := Get_Ada_Node (+To);
   273:                   begin
   274:                      --  We're converting from the representation type
   275:                      --  of a scalar kind
   276:
   277:                      pragma
   278:                        Assert
   279:                          (Base_Why_Type (To) = From
   280:                           and then
   281:                             (From = EW_Int_Type
   282:                              or else Why_Type_Is_BitVector (From)
   283:                              or else Why_Type_Is_Float (From)
   284:                              or else Why_Type_Is_Fixed (From)));
   285:
   286:                      return E_Symb (A, WNE_Of_Rep);
   287:                   end;
   288:             end case;
   289:
   290:          when EW_Abstract | EW_Split =>
   291:             case To_Kind is
   292:                when EW_Builtin             =>
   293:                   declare
   294:                      A : constant Node_Id := Get_Ada_Node (+From);
   295:                   begin
   296:                      --  We're converting to the representation type
   297:                      --  of a discrete/float kind
   298:
   299:                      pragma
   300:                        Assert
   301:                          (Base_Why_Type (From) = To
   302:                           and then
   303:                             (To = EW_Int_Type
   304:                              or else Why_Type_Is_BitVector (To)
   305:                              or else Why_Type_Is_Float (To)
   306:                              or else Why_Type_Is_Fixed (To)));
   307:
   308:                      return E_Symb (A, WNE_To_Rep);
   309:                   end;
   310:
   311:                --  Case of a conversion between two record or array types
   312:
   313:                when EW_Abstract | EW_Split =>
   314:                   declare
   315:                      From_Node : constant Node_Id := Get_Ada_Node (+From);
   316:                      To_Node   : constant Node_Id := Get_Ada_Node (+To);
   317:
   318:                   begin
   319:                      --  Conversions on record types go through the root type
   320:
   321:                      if Is_Record_Type_In_Why (From_Node) then
   322:                         pragma Assert (Is_Record_Type_In_Why (To_Node));
   323:                         declare
   324:                            From_Base    : constant Node_Id :=
   325:                              Root_Retysp (From_Node);
   326:                            Relaxed_Init : constant Boolean :=
   327:                              Is_Init_Wrapper_Type (From);
   328:                            pragma
   329:                              Assert (Relaxed_Init = Is_Init_Wrapper_Type (To));
   330:                         begin
   331:                            if From_Base = From_Node then
   332:                               return
   333:                                 E_Symb (To_Node, WNE_Of_Base, Relaxed_Init);
   334:                            else
   335:                               return
   336:                                 E_Symb (From_Node, WNE_To_Base, Relaxed_Init);
   337:                            end if;
   338:                         end;
   339:
   340:                      --  Conversions on array types use predefined functions
   341:
   342:                      else
   343:                         pragma
   344:                           Assert
   345:                             (Has_Array_Type (From_Node)
   346:                              and Has_Array_Type (To_Node));
   347:                         return Get_Array_Conversion_Name (From_Node, To_Node);
   348:                      end if;
   349:                   end;
   350:             end case;
   351:       end case;
   352:    end Conversion_Name;
   353:
   354:    ------------------
   355:    -- Discr_Append --
   356:    ------------------
   357:
   358:    function Discr_Append
   359:      (Base : W_Identifier_Id; Typ : W_Type_Id) return W_Identifier_Id
   360:    is
   361:       Name : constant W_Name_Id := Get_Name (Base);
   362:    begin
   363:       return
   364:         Append_Num
   365:           (S        =>
   366:              Img (Get_Symb (Name)) & To_String (WNE_Rec_Split_Discrs),
   367:            Count    => 1,
   368:            Typ      => Typ,
   369:            Module   => Get_Module (Name),
   370:            Ada_Node => Get_Ada_Node (+Name));
   371:    end Discr_Append;
   372:
   373:    -----------------------
   374:    -- Dynamic_Prop_Name --
   375:    -----------------------
   376:
   377:    function Dynamic_Prop_Name (Ty : Entity_Id) return W_Identifier_Id is
   378:    begin
   379:       if Is_Standard_Boolean_Type (Ty) then
   380:          return M_Boolean.Dynamic_Prop;
   381:       else
   382:          return E_Symb (Ty, WNE_Dynamic_Property);
   383:       end if;
   384:    end Dynamic_Prop_Name;
   385:
   386:    ------------------
   387:    -- Field_Append --
   388:    ------------------
   389:
   390:    function Field_Append
   391:      (Base : W_Identifier_Id; Typ : W_Type_Id) return W_Identifier_Id
   392:    is
```

## src/why/why-gen-names.adb:560-570

```ada
   560:    function Havoc_Append (Base : W_Name_Id) return W_Identifier_Id is
   561:    begin
   562:       return
   563:         Append_Num
   564:           (S        => Img (Get_Symb (Base)) & To_String (WNE_Havoc),
   565:            Count    => 1,
   566:            Typ      => Why_Empty,
   567:            Module   => Get_Module (Base),
   568:            Ada_Node => Get_Ada_Node (+Base));
   569:    end Havoc_Append;
   570:
```

## src/why/why-gen-names.adb:734-910

```ada
   734:         New_Identifier
   735:           (Ada_Node, EW_Term, Name, Namespace, Module, Typ, Attrs);
   736:    end New_Identifier;
   737:
   738:    function New_Identifier
   739:      (Ada_Node : Node_Id := Empty;
   740:       Domain   : EW_Domain;
   741:       Name     : String;
   742:       Typ      : W_Type_Id := Why_Empty;
   743:       Attrs    : String_Utils.String_Sets.Set :=
   744:         String_Utils.String_Sets.Empty_Set) return W_Identifier_Id is
   745:    begin
   746:       return
   747:         New_Identifier
   748:           (Ada_Node => Ada_Node,
   749:            Domain   => Domain,
   750:            Symb     => NID (Name),
   751:            Typ      => Typ,
   752:            Attrs    => Attrs);
   753:    end New_Identifier;
   754:
   755:    function New_Identifier
   756:      (Ada_Node  : Node_Id := Empty;
   757:       Domain    : EW_Domain;
   758:       Name      : String;
   759:       Namespace : Symbol := No_Symbol;
   760:       Module    : W_Module_Id;
   761:       Typ       : W_Type_Id := Why_Empty;
   762:       Attrs     : String_Utils.String_Sets.Set :=
   763:         String_Utils.String_Sets.Empty_Set) return W_Identifier_Id is
   764:    begin
   765:       return
   766:         New_Identifier
   767:           (Ada_Node  => Ada_Node,
   768:            Domain    => Domain,
   769:            Symb      => NID (Name),
   770:            Namespace => Namespace,
   771:            Module    => Module,
   772:            Typ       => Typ,
   773:            Attrs     => Attrs);
   774:    end New_Identifier;
   775:
   776:    function New_Identifier (Name : W_Name_Id) return W_Identifier_Id is
   777:    begin
   778:       return
   779:         New_Identifier
   780:           (Ada_Node => Get_Ada_Node (+Name),
   781:            Domain   => EW_Term,
   782:            Symb     => Get_Symb (Name),
   783:            Module   => Get_Module (Name));
   784:    end New_Identifier;
   785:
   786:    function New_Identifier
   787:      (Ada_Node  : Node_Id := Empty;
   788:       Domain    : EW_Domain;
   789:       Symb      : Symbol;
   790:       Namespace : Symbol := No_Symbol;
   791:       Typ       : W_Type_Id := Why.Types.Why_Empty;
   792:       Module    : W_Module_Id := Why.Types.Why_Empty;
   793:       Infix     : Boolean := False;
   794:       Attrs     : String_Utils.String_Sets.Set :=
   795:         String_Utils.String_Sets.Empty_Set) return W_Identifier_Id is
   796:    begin
   797:       return
   798:         New_Identifier
   799:           (Ada_Node => Ada_Node,
   800:            Domain   => Domain,
   801:            Name     =>
   802:              New_Name
   803:                (Ada_Node  => Ada_Node,
   804:                 Symb      => Symb,
   805:                 Namespace => Namespace,
   806:                 Infix     => Infix,
   807:                 Module    => Module),
   808:            Typ      => Typ,
   809:            Labels   => Attrs);
   810:    end New_Identifier;
   811:
   812:    ---------
   813:    -- NID --
   814:    ---------
   815:
   816:    function NID (Name : String) return Symbol is
   817:    begin
   818:       return Find (Why3_Symbol_Alloc, Name);
   819:    end NID;
   820:
   821:    ----------------
   822:    -- New_Module --
   823:    ----------------
   824:
   825:    function New_Module
   826:      (Ada_Node : Node_Id := Empty; File : Symbol; Name : String)
   827:       return W_Module_Id
   828:    is
   829:       S : constant Symbol := NID (Capitalize_First (Name));
   830:    begin
   831:       return New_Module (Ada_Node, File, S);
   832:    end New_Module;
   833:
   834:    -------------------------
   835:    -- New_Temp_Identifier --
   836:    -------------------------
   837:
   838:    New_Temp_Identifier_Counter : Natural := 0;
   839:
   840:    function New_Temp_Identifier (Base_Name : String := "") return String is
   841:       Counter_Img   : constant String :=
   842:         Natural'Image (New_Temp_Identifier_Counter);
   843:       Use_Base_Name : constant String :=
   844:         (if Base_Name = "" then "" else Base_Name & "_");
   845:    begin
   846:       New_Temp_Identifier_Counter := New_Temp_Identifier_Counter + 1;
   847:       return "temp___" & Use_Base_Name & Trim (Counter_Img, Ada.Strings.Left);
   848:    end New_Temp_Identifier;
   849:
   850:    function New_Temp_Identifier
   851:      (Ada_Node  : Node_Id := Empty;
   852:       Typ       : W_Type_Id := Why_Empty;
   853:       Base_Name : String := "") return W_Identifier_Id
   854:    is
   855:
   856:       Temp_Labels : String_Utils.String_Sets.Set :=
   857:         String_Utils.String_Sets.Empty_Set;
   858:    begin
   859:       String_Utils.String_Sets.Insert
   860:         (Container => Temp_Labels, New_Item => "mlw:proxy_symbol");
   861:       String_Utils.String_Sets.Insert (Temp_Labels, "introduced");
   862:       return
   863:         New_Identifier
   864:           (Ada_Node => Ada_Node,
   865:            Name     => New_Temp_Identifier (Base_Name),
   866:            Typ      => Typ,
   867:            Attrs    => Temp_Labels);
   868:    end New_Temp_Identifier;
   869:
   870:    function New_Generated_Identifier
   871:      (Ada_Node  : Node_Id := Empty;
   872:       Typ       : W_Type_Id := Why_Empty;
   873:       Base_Name : String := "";
   874:       Attrs     : String_Utils.String_Sets.Set) return W_Identifier_Id is
   875:
   876:    begin
   877:       return
   878:         New_Identifier
   879:           (Ada_Node => Ada_Node,
   880:            Name     => New_Temp_Identifier (Base_Name),
   881:            Typ      => Typ,
   882:            Attrs    => Attrs);
   883:    end New_Generated_Identifier;
   884:
   885:    --------------------------
   886:    -- New_Temp_Identifiers --
   887:    --------------------------
   888:
   889:    function New_Temp_Identifiers
   890:      (Num : Positive; Typ : W_Type_Id) return W_Identifier_Array
   891:    is
   892:       Result : constant W_Identifier_Array (1 .. Num) :=
   893:         (others => +New_Temp_Identifier (Typ => Typ));
   894:    begin
   895:       return Result;
   896:    end New_Temp_Identifiers;
   897:
   898:    ----------------------
   899:    -- New_Result_Ident --
   900:    ----------------------
   901:
   902:    function New_Result_Ident (Typ : W_Type_Id) return W_Identifier_Id is
   903:    begin
   904:       return New_Identifier (Name => "result", Typ => Typ);
   905:    end New_Result_Ident;
   906:
   907:    ----------------
   908:    -- Ref_Append --
   909:    ----------------
   910:
```

## src/why/why-gen-names.adb:911-921

```ada
   911:    function Ref_Append (Base : W_Name_Id) return W_Name_Id is
   912:    begin
   913:       return
   914:         New_Name
   915:           (Ada_Node => Get_Ada_Node (+Base),
   916:            Symb     => NID (Img (Get_Symb (Base)) & To_String (WNE_Ref)),
   917:            Module   => Get_Module (Base));
   918:    end Ref_Append;
   919:
   920:    --------------
   921:    -- To_Exprs --
```

## src/why/why-gen-names.adb:1136-1246

```ada
  1136:    function To_Local (Name : W_Identifier_Id) return W_Name_Id is
  1137:       W_Name : constant W_Name_Id := Get_Name (Name);
  1138:    begin
  1139:       return
  1140:         New_Name
  1141:           (Ada_Node => Get_Ada_Node (+W_Name),
  1142:            Symb     => Get_Symb (W_Name),
  1143:            Module   => Why_Empty);
  1144:    end To_Local;
  1145:
  1146:    function To_Local (Name : W_Identifier_Id) return W_Identifier_Id is
  1147:       W_Name : constant W_Name_Id := Get_Name (Name);
  1148:    begin
  1149:       return
  1150:         New_Identifier
  1151:           (Ada_Node  => Get_Ada_Node (+W_Name),
  1152:            Symb      => Get_Symb (W_Name),
  1153:            Namespace => Get_Namespace (W_Name),
  1154:            Domain    => Get_Domain (+Name),
  1155:            Module    => Why_Empty,
  1156:            Typ       => Get_Typ (Name),
  1157:            Attrs     => Get_Labels (Name));
  1158:    end To_Local;
  1159:
  1160:    function To_Local (Name : W_Name_Id) return W_Name_Id is
  1161:    begin
  1162:       return
  1163:         New_Name
  1164:           (Ada_Node => Get_Ada_Node (+Name),
  1165:            Symb     => Get_Symb (Name),
  1166:            Module   => Why_Empty);
  1167:    end To_Local;
  1168:
  1169:    -------------
  1170:    -- To_Name --
  1171:    -------------
  1172:
  1173:    function To_Name (W : Why_Name_Enum) return W_Name_Id is
  1174:    begin
  1175:       return New_Name (Symb => NID (To_String (W)));
  1176:    end To_Name;
  1177:
  1178:    ----------------------
  1179:    -- Range_Check_Name --
  1180:    ----------------------
  1181:
  1182:    function Range_Check_Name
  1183:      (Ty : Entity_Id; R : Scalar_Check_Kind) return W_Identifier_Id is
  1184:    begin
  1185:       if Is_Standard_Boolean_Type (Ty) then
  1186:          case R is
  1187:             when RCK_Range_Not_First
  1188:                | RCK_Overflow_Not_First
  1189:                | RCK_FP_Overflow_Not_First =>
  1190:                return M_Boolean.Check_Not_First;
  1191:
  1192:             when RCK_Range_Not_Last
  1193:                | RCK_Overflow_Not_Last
  1194:                | RCK_FP_Overflow_Not_Last  =>
  1195:                return M_Boolean.Check_Not_Last;
  1196:
  1197:             when others                    =>
  1198:                return M_Boolean.Range_Check;
  1199:          end case;
  1200:       else
  1201:          declare
  1202:             Name : constant Why_Name_Enum :=
  1203:               (case R is
  1204:                  when RCK_Range_Not_First
  1205:                     | RCK_Overflow_Not_First
  1206:                     | RCK_FP_Overflow_Not_First => WNE_Check_Not_First,
  1207:                  when RCK_Range_Not_Last
  1208:                     | RCK_Overflow_Not_Last
  1209:                     | RCK_FP_Overflow_Not_Last  => WNE_Check_Not_Last,
  1210:                  when others                    => WNE_Range_Check_Fun);
  1211:
  1212:          begin
  1213:             return E_Symb (Ty, Name);
  1214:          end;
  1215:       end if;
  1216:    end Range_Check_Name;
  1217:
  1218:    ---------------------
  1219:    -- Range_Pred_Name --
  1220:    ---------------------
  1221:
  1222:    function Range_Pred_Name (Ty : Entity_Id) return W_Identifier_Id is
  1223:    begin
  1224:       if Is_Standard_Boolean_Type (Ty) then
  1225:          return M_Boolean.Range_Pred;
  1226:       else
  1227:          return E_Symb (Ty, WNE_Range_Pred);
  1228:       end if;
  1229:    end Range_Pred_Name;
  1230:
  1231:    ----------------------
  1232:    -- To_Program_Space --
  1233:    ----------------------
  1234:
  1235:    function To_Program_Space (Name : W_Identifier_Id) return W_Identifier_Id is
  1236:       Suffix : constant String := "_";
  1237:       N_Id   : constant Symbol := Get_Symb (Get_Name (Name));
  1238:       Img    : String renames Get (N_Id).all;
  1239:    begin
  1240:       return
  1241:         New_Identifier
  1242:           (Get_Ada_Node (+Name),
  1243:            EW_Prog,
  1244:            Img & Suffix,
  1245:            Module => Get_Module (Get_Name (Name)));
  1246:    end To_Program_Space;
```

## src/why/why-gen-progs.adb:38-58

```ada
    38:    ------------
    39:    -- Append --
    40:    ------------
    41:
    42:    procedure Append (Left : in out W_Prog_Id; Right : W_Prog_Id) is
    43:    begin
    44:       Left := Sequence (Left, Right);
    45:    end Append;
    46:
    47:    procedure Append (Left : in out W_Prog_Id; Right1, Right2 : W_Prog_Id) is
    48:    begin
    49:       Left := Sequence ((1 => Left, 2 => Right1, 3 => Right2));
    50:    end Append;
    51:
    52:    procedure Append (Left : in out W_Expr_Id; Right : W_Prog_Id) is
    53:    begin
    54:       Left := +Sequence (+Left, Right);
    55:    end Append;
    56:
    57:    procedure Append (Left : in out W_Expr_Id; Right1, Right2 : W_Prog_Id) is
    58:    begin
```

## src/why/why-gen-progs.adb:168-180

```ada
   168:    function New_Assume_Statement
   169:      (Ada_Node : Node_Id := Empty; Pred : W_Pred_Id) return W_Prog_Id is
   170:    begin
   171:       if Is_True_Boolean (+Pred) then
   172:          return +Void;
   173:       else
   174:          return
   175:            New_Assert
   176:              (Ada_Node => Ada_Node, Pred => Pred, Assert_Kind => EW_Assume);
   177:       end if;
   178:    end New_Assume_Statement;
   179:
   180:    -------------------------
```

## src/why/why-gen-progs.adb:199-215

```ada
   199:    function New_Ignore
   200:      (Ada_Node : Node_Id := Empty; Prog : W_Prog_Id) return W_Prog_Id
   201:    is
   202:       Call : constant W_Prog_Id :=
   203:         New_Binding
   204:           (Ada_Node => Ada_Node,
   205:            Name     =>
   206:              New_Identifier
   207:                (Domain => EW_Prog, Name => "_", Typ => Get_Type (+Prog)),
   208:            Def      => +Prog,
   209:            Context  => +Void,
   210:            Typ      => EW_Unit_Type);
   211:    begin
   212:       return New_Abstract_Expr (Expr => Call, Post => True_Pred);
   213:    end New_Ignore;
   214:
   215:    --------------------------
```

## src/why/why-gen-progs.adb:243-257

```ada
   243:    function New_Located_Assert
   244:      (Ada_Node   : Node_Id;
   245:       Pred       : W_Pred_Id;
   246:       Reason     : VC_Kind;
   247:       Kind       : EW_Assert_Kind;
   248:       Check_Info : Check_Info_Type := New_Check_Info) return W_Prog_Id
   249:    is (New_Assert
   250:          (Ada_Node    => Ada_Node,
   251:           Pred        =>
   252:             New_VC_Pred
   253:               (Ada_Node   => Ada_Node,
   254:                Expr       => Pred,
   255:                Reason     => Reason,
   256:                Check_Info => Check_Info),
   257:           Assert_Kind => Kind));
```

## src/why/why-gen-progs.adb:275-280

```ada
   275:    procedure Prepend (Left : W_Prog_Id; Right : in out W_Prog_Id) is
   276:    begin
   277:       Right := Sequence (Left, Right);
   278:    end Prepend;
   279:
   280:    procedure Prepend (Left : W_Prog_Id; Right : in out W_Expr_Id) is
```

## src/why/why-gen-progs.adb:329-364

```ada
   329:    function Sequence
   330:      (Ada_Node : Node_Id; Left, Right : W_Prog_Id) return W_Prog_Id is
   331:    begin
   332:       if Is_Void (Left) then
   333:          return Right;
   334:       elsif Is_Void (Right) then
   335:          return Left;
   336:       else
   337:          return
   338:            New_Statement_Sequence
   339:              (Ada_Node => Ada_Node, Statements => (1 => Left, 2 => Right));
   340:       end if;
   341:    end Sequence;
   342:
   343:    function Sequence (Progs : W_Prog_Array) return W_Prog_Id is
   344:       Non_Void_Progs : W_Prog_Array := Progs;
   345:       J              : Integer := Non_Void_Progs'First;
   346:    begin
   347:       for E of Progs loop
   348:          if not Is_Void (E) then
   349:             Non_Void_Progs (J) := E;
   350:             J := J + 1;
   351:          end if;
   352:       end loop;
   353:       if J <= Non_Void_Progs'First then
   354:          return +Void;
   355:       else
   356:          return
   357:            New_Statement_Sequence
   358:              (Statements => (Non_Void_Progs (Non_Void_Progs'First .. J - 1)));
   359:       end if;
   360:    end Sequence;
   361:
   362:    -------------------
   363:    -- Void_Sequence --
   364:    -------------------
```

## src/why/why-gen-progs.adb:52-102

```ada
    52:    procedure Append (Left : in out W_Expr_Id; Right : W_Prog_Id) is
    53:    begin
    54:       Left := +Sequence (+Left, Right);
    55:    end Append;
    56:
    57:    procedure Append (Left : in out W_Expr_Id; Right1, Right2 : W_Prog_Id) is
    58:    begin
    59:       Left := +Sequence ((1 => +Left, 2 => Right1, 3 => Right2));
    60:    end Append;
    61:
    62:    procedure Append
    63:      (Left : in out W_Statement_Sequence_Id; Right : W_Statement_Sequence_Id)
    64:    is
    65:       pragma Annotate (GNATSAS, Skip_Analysis);  --  for unmodified Left
    66:       pragma Unmodified (Left);
    67:
    68:       Stats : constant Why_Node_Lists.List :=
    69:         Get_List (+Get_Statements (Right));
    70:    begin
    71:       for Stat of Stats loop
    72:          Statement_Sequence_Append_To_Statements (Left, +Stat);
    73:       end loop;
    74:    end Append;
    75:
    76:    procedure Append (Left : in out W_Statement_Sequence_Id; Right : W_Prog_Id)
    77:    is
    78:    begin
    79:       if Is_Void (Right) then
    80:          null;
    81:
    82:       elsif Get_Kind (+Right) = W_Statement_Sequence then
    83:          Append (Left, W_Statement_Sequence_Id'(+Right));
    84:
    85:       else
    86:          Statement_Sequence_Append_To_Statements (Left, Right);
    87:       end if;
    88:    end Append;
    89:
    90:    ----------------------------------
    91:    -- Emit_Always_True_Range_Check --
    92:    ----------------------------------
    93:
    94:    procedure Emit_Always_True_Range_Check
    95:      (Ada_Node : Node_Id; Check_Kind : Scalar_Check_Kind) is
    96:    begin
    97:       Emit_Static_Proof_Result
    98:         (Ada_Node, To_VC_Kind (Check_Kind), True, Current_Subp);
    99:    end Emit_Always_True_Range_Check;
   100:
   101:    ----------------------
   102:    -- Is_Void_Sequence --
```

## src/why/why-gen-progs.adb:126-150

```ada
   126:
   127:    function New_Any_Statement
   128:      (Ada_Node    : Node_Id;
   129:       Pre         : W_Pred_Id;
   130:       Post        : W_Pred_Id;
   131:       Reason      : VC_Kind;
   132:       Return_Type : W_Type_Id := Why_Empty) return W_Prog_Id is
   133:    begin
   134:       return
   135:         +Insert_Cnt_Loc_Label
   136:            (Ada_Node,
   137:             New_Any_Expr
   138:               (Ada_Node    => Ada_Node,
   139:                Pre         => Pre,
   140:                Post        => Post,
   141:                Labels      =>
   142:                  New_VC_Labels
   143:                    (Ada_Node, Reason, Check_Info => New_Check_Info),
   144:                Return_Type =>
   145:                  (if Return_Type = Why_Empty
   146:                   then EW_Unit_Type
   147:                   else Return_Type)));
   148:    end New_Any_Statement;
   149:
   150:    function New_Any_Statement
```

## src/why/why-gen-progs.adb:329-370

```ada
   329:    function Sequence
   330:      (Ada_Node : Node_Id; Left, Right : W_Prog_Id) return W_Prog_Id is
   331:    begin
   332:       if Is_Void (Left) then
   333:          return Right;
   334:       elsif Is_Void (Right) then
   335:          return Left;
   336:       else
   337:          return
   338:            New_Statement_Sequence
   339:              (Ada_Node => Ada_Node, Statements => (1 => Left, 2 => Right));
   340:       end if;
   341:    end Sequence;
   342:
   343:    function Sequence (Progs : W_Prog_Array) return W_Prog_Id is
   344:       Non_Void_Progs : W_Prog_Array := Progs;
   345:       J              : Integer := Non_Void_Progs'First;
   346:    begin
   347:       for E of Progs loop
   348:          if not Is_Void (E) then
   349:             Non_Void_Progs (J) := E;
   350:             J := J + 1;
   351:          end if;
   352:       end loop;
   353:       if J <= Non_Void_Progs'First then
   354:          return +Void;
   355:       else
   356:          return
   357:            New_Statement_Sequence
   358:              (Statements => (Non_Void_Progs (Non_Void_Progs'First .. J - 1)));
   359:       end if;
   360:    end Sequence;
   361:
   362:    -------------------
   363:    -- Void_Sequence --
   364:    -------------------
   365:
   366:    function Void_Sequence return W_Statement_Sequence_Id
   367:    is (New_Statement_Sequence
   368:          (Ada_Node => Empty, Statements => (1 .. 1 => +Void)));
   369:
   370: end Why.Gen.Progs;
```

## src/why/why-gen-records.adb:5048-5125

```ada
  5048:    function New_Tag_And_Ext_Update
  5049:      (Ada_Node  : Node_Id := Empty;
  5050:       Domain    : EW_Domain;
  5051:       Name      : W_Expr_Id;
  5052:       From_Expr : W_Expr_Id := Why_Empty;
  5053:       Ty        : Entity_Id) return W_Expr_Id
  5054:    is
  5055:       Has_Tag : constant Boolean :=
  5056:         (Is_Tagged_Type (Retysp (Ty))
  5057:          and then
  5058:            (From_Expr /= Why_Empty or else not Is_Class_Wide_Type (Ty)));
  5059:       --  If Ty is tagged, its 'Tag attribute should be preserved except for
  5060:       --  defaults of classwide types.
  5061:
  5062:    begin
  5063:       if Has_Tag then
  5064:          declare
  5065:             Pre_Ty    : constant Node_Id :=
  5066:               Get_Ada_Node (+Get_Type (From_Expr));
  5067:             Tmp_Name  : constant W_Expr_Id := New_Temp_For_Expr (Name);
  5068:             Ext_Value : constant W_Expr_Id :=
  5069:               (if From_Expr = Why_Empty
  5070:                then +E_Symb (Ty, WNE_Null_Extension)
  5071:                else
  5072:                  New_Ext_Access
  5073:                    (Name =>
  5074:                       New_Fields_Access (Name => From_Expr, Ty => Pre_Ty),
  5075:                     Ty   => Pre_Ty));
  5076:             Tag_Value : constant W_Expr_Id :=
  5077:               (if From_Expr = Why_Empty
  5078:                then +E_Symb (E => Ty, S => WNE_Tag)
  5079:                else
  5080:                  New_Tag_Access
  5081:                    (Domain => Domain, Name => From_Expr, Ty => Pre_Ty));
  5082:          begin
  5083:             return
  5084:               Binding_For_Temp
  5085:                 (Domain  => Domain,
  5086:                  Tmp     => Tmp_Name,
  5087:                  Context =>
  5088:                    New_Record_Update
  5089:                      (Ada_Node => Ada_Node,
  5090:                       Name     => Tmp_Name,
  5091:                       Updates  =>
  5092:                         (1 =>
  5093:                            New_Field_Association
  5094:                              (Domain => Domain,
  5095:                               Field  =>
  5096:                                 +New_Attribute_Expr
  5097:                                    (Ty     => Ty,
  5098:                                     Domain => Domain,
  5099:                                     Attr   => Attribute_Tag),
  5100:                               Value  => Tag_Value),
  5101:                          2 =>
  5102:                            New_Field_Association
  5103:                              (Domain => Domain,
  5104:                               Field  => E_Symb (Ty, WNE_Rec_Split_Fields),
  5105:                               Value  =>
  5106:                                 New_Record_Update
  5107:                                   (Ada_Node => Ada_Node,
  5108:                                    Name     =>
  5109:                                      New_Fields_Access
  5110:                                        (Name => Tmp_Name, Ty => Ty),
  5111:                                    Updates  =>
  5112:                                      (1 =>
  5113:                                         New_Field_Association
  5114:                                           (Domain => Domain,
  5115:                                            Field  =>
  5116:                                              E_Symb (Ty, WNE_Rec_Extension),
  5117:                                            Value  => Ext_Value))))),
  5118:                       Typ      => Get_Type (Name)));
  5119:          end;
  5120:       else
  5121:          return Name;
  5122:       end if;
  5123:    end New_Tag_And_Ext_Update;
  5124:
  5125:    -------------------------------------
```

## src/why/why-gen-scalars.adb:410-927

```ada
   410:    procedure Declare_Scalar_Type (Th : Theory_UC; E : Entity_Id) is
   411:       Why_Name         : constant W_Name_Id := To_Why_Type (E, Local => True);
   412:       Is_Static        : constant Boolean := not Type_Is_Modeled_As_Base (E);
   413:       Base_Type_In_Why : constant W_Type_Id := EW_Abstract (Base_Type (E));
   414:
   415:       function Pick_Clone return W_Module_Id;
   416:       --  Choose the correct module to clone
   417:
   418:       function Compute_Clone_Subst return W_Clone_Substitution_Array;
   419:       --  generate the substitutions to be passed to the clone
   420:
   421:       procedure Generate_Range_Predicate
   422:         (Ty : W_Type_Id := Base_Why_Type (E); Name : Why_Name_Enum);
   423:       --  generate the range predicate for the type. In simple cases, this
   424:       --  predicate simply expresses "first < x < last"
   425:
   426:       -------------------------
   427:       -- Compute_Clone_Subst --
   428:       -------------------------
   429:
   430:       function Compute_Clone_Subst return W_Clone_Substitution_Array is
   431:          Default_Clone_Subst         : constant W_Clone_Substitution_Id :=
   432:            New_Clone_Substitution
   433:              (Kind      => EW_Type_Subst,
   434:               Orig_Name => New_Name (Symb => NID ("t")),
   435:               Image     => Why_Name);
   436:          Rep_Type_Clone_Substitution : constant W_Clone_Substitution_Array :=
   437:            (if not Is_Static
   438:               and then
   439:                 (Has_Discrete_Type (E) or else Has_Floating_Point_Type (E))
   440:             then
   441:               (1 =>
   442:                  New_Clone_Substitution
   443:                    (Kind      => EW_Type_Subst,
   444:                     Orig_Name => New_Name (Symb => NID ("rep_type")),
   445:                     Image     => Get_Name (Base_Why_Type (E))))
   446:             else (1 .. 0 => <>));
   447:          Static_Clone_Subst          : constant W_Clone_Substitution_Array :=
   448:            (if Is_Static
   449:             then
   450:               (1 =>
   451:                  New_Clone_Substitution
   452:                    (Kind      => EW_Function,
   453:                     Orig_Name => To_Local (E_Symb (E, WNE_Attr_First)),
   454:                     Image     => To_Local (E_Symb (E, WNE_Attr_First))),
   455:                2 =>
   456:                  New_Clone_Substitution
   457:                    (Kind      => EW_Function,
   458:                     Orig_Name => To_Local (E_Symb (E, WNE_Attr_Last)),
   459:                     Image     => To_Local (E_Symb (E, WNE_Attr_Last))),
   460:                3 =>
   461:                  New_Clone_Substitution
   462:                    (Kind      => EW_Predicate,
   463:                     Orig_Name => To_Local (E_Symb (E, WNE_Range_Pred)),
   464:                     Image     => To_Local (E_Symb (E, WNE_Range_Pred))))
   465:             else (1 .. 0 => <>));
   466:          Dynamic_Conv_Subst          : constant W_Clone_Substitution_Array :=
   467:            (if not Is_Static
   468:             then
   469:               (1 =>
   470:                  New_Clone_Substitution
   471:                    (Kind      => EW_Function,
   472:                     Orig_Name => New_Name (Symb => NID ("base_to_rep")),
   473:                     Image     =>
   474:                       Get_Name
   475:                         (Conversion_Name
   476:                            (From => Base_Type_In_Why,
   477:                             To   => Base_Why_Type (E)))),
   478:                2 =>
   479:                  New_Clone_Substitution
   480:                    (Kind      => EW_Function,
   481:                     Orig_Name => New_Name (Symb => NID ("base_of_rep")),
   482:                     Image     =>
   483:                       Get_Name
   484:                         (Conversion_Name
   485:                            (From => Base_Why_Type (E),
   486:                             To   => Base_Type_In_Why))),
   487:                3 =>
   488:                  New_Clone_Substitution
   489:                    (Kind      => EW_Predicate,
   490:                     Orig_Name => To_Local (E_Symb (E, WNE_Dynamic_Property)),
   491:                     Image     => To_Local (E_Symb (E, WNE_Dynamic_Property))))
   492:             else (1 .. 0 => <>));
   493:          Mod_Clone_Subst             : constant W_Clone_Substitution_Array :=
   494:            (if Is_Static
   495:               and then Has_Modular_Integer_Type (E)
   496:               and then not Has_No_Bitwise_Operations_Annotation (E)
   497:               and then Modulus (E) /= UI_Expon (Uint_2, Modular_Size (E))
   498:             then
   499:               (1 =>
   500:                  New_Clone_Substitution
   501:                    (Kind      => EW_Function,
   502:                     Orig_Name => To_Local (E_Symb (E, WNE_Attr_Modulus)),
   503:                     Image     => To_Local (E_Symb (E, WNE_Attr_Modulus))))
   504:             else (1 .. 0 => <>));
   505:          Range_Int_Clone_Subst       : constant W_Clone_Substitution_Array :=
   506:            (if Has_Modular_Integer_Type (E)
   507:               and then not Has_No_Bitwise_Operations_Annotation (E)
   508:             then
   509:               (if Is_Static
   510:                then
   511:                  (1 =>
   512:                     New_Clone_Substitution
   513:                       (Kind      => EW_Predicate,
   514:                        Orig_Name =>
   515:                          To_Local (E_Symb (E, WNE_Range_Pred_BV_Int)),
   516:                        Image     =>
   517:                          To_Local (E_Symb (E, WNE_Range_Pred_BV_Int))))
   518:                else
   519:                  (1 =>
   520:                     New_Clone_Substitution
   521:                       (Kind      => EW_Predicate,
   522:                        Orig_Name =>
   523:                          To_Local (E_Symb (E, WNE_Dynamic_Property_BV_Int)),
   524:                        Image     =>
   525:                          To_Local (E_Symb (E, WNE_Dynamic_Property_BV_Int)))))
   526:             else (1 .. 0 => <>));
   527:
   528:       begin
   529:          return
   530:            Default_Clone_Subst
   531:            & Rep_Type_Clone_Substitution
   532:            & Static_Clone_Subst
   533:            & Dynamic_Conv_Subst
   534:            & Mod_Clone_Subst
   535:            & Range_Int_Clone_Subst;
   536:       end Compute_Clone_Subst;
   537:
   538:       ------------------------------
   539:       -- Generate_Range_Predicate --
   540:       ------------------------------
   541:
   542:       procedure Generate_Range_Predicate
   543:         (Ty : W_Type_Id := Base_Why_Type (E); Name : Why_Name_Enum)
   544:       is
   545:          Var : constant W_Identifier_Id :=
   546:            New_Identifier (Name => "x", Typ => Ty);
   547:          Def : W_Pred_Id := True_Pred;
   548:
   549:          --  the names of fst and last must be "first_int/last_int" in the case
   550:          --  where we deal with a modular type and the base type is "int", and
   551:          --  should be simply "first/last" in the case of a static type. In
   552:          --  the dynamic case, we don't care about the name, because we bind
   553:          --  it directly above, so we pick "first_int/last_int" too.
   554:
   555:          Fst : constant W_Identifier_Id :=
   556:            (if not Is_Static
   557:               or else
   558:                 (Has_Modular_Integer_Type (E)
   559:                  and then not Has_No_Bitwise_Operations_Annotation (E)
   560:                  and then Ty = EW_Int_Type)
   561:             then
   562:               New_Identifier
   563:                 (Symb => NID ("first_int"), Domain => EW_Term, Typ => Ty)
   564:             else To_Local (E_Symb (E, WNE_Attr_First)));
   565:          Lst : constant W_Identifier_Id :=
   566:            (if not Is_Static
   567:               or else
   568:                 (Has_Modular_Integer_Type (E)
   569:                  and then not Has_No_Bitwise_Operations_Annotation (E)
   570:                  and then Ty = EW_Int_Type)
   571:             then
   572:               New_Identifier
   573:                 (Symb => NID ("last_int"), Domain => EW_Term, Typ => Ty)
   574:             else To_Local (E_Symb (E, WNE_Attr_Last)));
   575:
   576:       begin
   577:          --  Optimisation:
   578:          --  check if E is (equivalent to) Unsigned_8/16/..
   579:          if Is_Static
   580:            and then Has_Modular_Integer_Type (E)
   581:            and then not Has_No_Bitwise_Operations_Annotation (E)
   582:            and then
   583:              (if Ty = EW_BitVector_8_Type
   584:               then Modulus (E) = UI_Expon (Uint_2, Uint_8)
   585:               elsif Ty = EW_BitVector_16_Type
   586:               then Modulus (E) = UI_Expon (Uint_2, Uint_16)
   587:               elsif Ty = EW_BitVector_32_Type
   588:               then Modulus (E) = UI_Expon (Uint_2, Uint_32)
   589:               elsif Ty = EW_BitVector_64_Type
   590:               then Modulus (E) = UI_Expon (Uint_2, Uint_64)
   591:               elsif Ty = EW_BitVector_128_Type
   592:               then Modulus (E) = UI_Expon (Uint_2, Uint_128)
   593:               else False)
   594:            and then Nkind (Type_Low_Bound (E)) = N_Integer_Literal
   595:            and then Intval (Type_Low_Bound (E)) = Uint_0
   596:            and then Nkind (Type_High_Bound (E)) = N_Integer_Literal
   597:            and then Intval (Type_High_Bound (E)) = UI_Sub (Modulus (E), Uint_1)
   598:          then
   599:
   600:             --  In which case we know that all values are necessary in range,
   601:             --  So we define the range predicate as always true.
   602:             Emit
   603:               (Th,
   604:                Why.Gen.Binders.New_Function_Decl
   605:                  (Domain   => EW_Pred,
   606:                   Name     => To_Local (E_Symb (E, Name)),
   607:                   Def      => +True_Pred,
   608:                   Location => No_Location,
   609:                   Labels   => Symbol_Sets.Empty_Set,
   610:                   Binders  =>
   611:                     (1 => Binder_Type'(B_Name => Var, others => <>))));
   612:
   613:             --  And we directly use the function uint_in_range from the
   614:             --  underlying why3 theory for checking the range againts integers
   615:             --  instead of generating it.
   616:             Emit
   617:               (Th,
   618:                Why.Gen.Binders.New_Function_Decl
   619:                  (Domain   => EW_Pred,
   620:                   Name     => To_Local (E_Symb (E, WNE_Range_Pred_BV_Int)),
   621:                   Def      =>
   622:                     +New_Identifier
   623:                        (Name   => "uint_in_range x",
   624:                         Module => MF_BVs (Base_Why_Type (E)).Module),
   625:                   Location => No_Location,
   626:                   Labels   => Symbol_Sets.Empty_Set,
   627:                   Binders  =>
   628:                     (1 =>
   629:                        Binder_Type'
   630:                          (B_Name =>
   631:                             New_Identifier (Name => "x", Typ => EW_Int_Type),
   632:                           others => <>))));
   633:
   634:             return;
   635:          elsif Has_Floating_Point_Type (E) then
   636:             --  Optimisation for static floating point, check if we are dealing
   637:             --  with a Float32, Float64 or Float80, in which case reduce the
   638:             --  range predicate to "is_finite".
   639:
   640:             if Is_Static
   641:               and then
   642:                 (declare
   643:                    Float_Typ : constant Entity_Id :=
   644:                      (if Ty = EW_Float_32_Type
   645:                       then Standard_Float
   646:                       elsif Ty = EW_Float_64_Type
   647:                       then Standard_Long_Float
   648:                       elsif Ty = EW_Float_80_Type
   649:                       then Standard_Long_Long_Float
   650:                       else raise Program_Error);
   651:                  begin
   652:                    UR_Eq
   653:                      (Expr_Value_R (Type_Low_Bound (E)),
   654:                       Expr_Value_R (Type_Low_Bound (Float_Typ)))
   655:                    and then
   656:                      UR_Eq
   657:                        (Expr_Value_R (Type_High_Bound (E)),
   658:                         Expr_Value_R (Type_High_Bound (Float_Typ))))
   659:             then
   660:
   661:                --  In which case we know that all values are necessary in range
   662:                --  so we define the range predicate as "is_finite".
   663:                Emit
   664:                  (Th,
   665:                   Why.Gen.Binders.New_Function_Decl
   666:                     (Domain   => EW_Pred,
   667:                      Name     => To_Local (E_Symb (E, Name)),
   668:                      Def      =>
   669:                        New_Call
   670:                          (Domain => EW_Pred,
   671:                           Name   => MF_Floats (Ty).Is_Finite,
   672:                           Args   => (1 => +Var)),
   673:                      Location => No_Location,
   674:                      Labels   => Symbol_Sets.Empty_Set,
   675:                      Binders  =>
   676:                        (1 => Binder_Type'(B_Name => Var, others => <>))));
   677:
   678:                return;
   679:
   680:             --  In the other case, add "is_finite" to the predicate
   681:
   682:             else
   683:                Def :=
   684:                  +W_Connection_Id'
   685:                    (New_Connection
   686:                       (Op     => EW_And_Then,
   687:                        Left   =>
   688:                          New_Call
   689:                            (Domain => EW_Pred,
   690:                             Name   => MF_Floats (Ty).Is_Finite,
   691:                             Args   => (1 => +Var)),
   692:                        Right  =>
   693:                          +New_Range_Expr
   694:                             (Domain => EW_Pred,
   695:                              Low    => +Fst,
   696:                              High   => +Lst,
   697:                              Expr   => +Var),
   698:                        Domain => EW_Pred));
   699:             end if;
   700:          else
   701:
   702:             --  Else, express the range constraints
   703:             Def :=
   704:               +New_And_Expr
   705:                  (Domain => EW_Pred,
   706:                   Left   => +Def,
   707:                   Right  =>
   708:                     +New_Range_Expr
   709:                        (Domain => EW_Pred,
   710:                         Low    => +Fst,
   711:                         High   => +Lst,
   712:                         Expr   => +Var,
   713:                         Pretty => True));
   714:          end if;
   715:
   716:          --  Emit range predicate if the type is static, a dynamic_property
   717:          --  otherwise.
   718:
   719:          declare
   720:             Static_Binders : constant Binder_Array :=
   721:               Binder_Array'(1 => Binder_Type'(B_Name => Var, others => <>));
   722:             Binders        : constant Binder_Array :=
   723:               (if Is_Static
   724:                then Static_Binders
   725:                else
   726:                  Binder_Array'
   727:                    (1 => Binder_Type'(B_Name => Fst, others => <>),
   728:                     2 => Binder_Type'(B_Name => Lst, others => <>))
   729:                  & Static_Binders);
   730:          begin
   731:             Emit
   732:               (Th,
   733:                Why.Gen.Binders.New_Function_Decl
   734:                  (Domain   => EW_Pred,
   735:                   Name     => To_Local (E_Symb (E, Name)),
   736:                   Def      => +Def,
   737:                   Location => No_Location,
   738:                   Labels   => Symbol_Sets.To_Set (NID (GP_Inline_Marker)),
   739:                   Binders  => Binders));
   740:
   741:             --  in case we're dealing with bitvectors, we also need to generate
   742:             --  a range check from integers
   743:             if Why_Type_Is_BitVector (Ty) then
   744:                Generate_Range_Predicate
   745:                  (EW_Int_Type,
   746:                   (if Is_Static
   747:                    then WNE_Range_Pred_BV_Int
   748:                    else WNE_Dynamic_Property_BV_Int));
   749:             end if;
   750:          end;
   751:       end Generate_Range_Predicate;
   752:
   753:       ----------------
   754:       -- Pick_Clone --
   755:       ----------------
   756:
   757:       function Pick_Clone return W_Module_Id is
   758:          Typ : constant W_Type_Id := Base_Why_Type (E);
   759:       begin
   760:          if Is_Static then
   761:             if Has_Modular_Integer_Type (E)
   762:               and then not Has_No_Bitwise_Operations_Annotation (E)
   763:             then
   764:                declare
   765:                   Modulus_Val : constant Uint := Modulus (E);
   766:                begin
   767:                   return
   768:                     (if Typ = EW_BitVector_8_Type
   769:                      then
   770:                        (if UI_Lt (Modulus_Val, UI_Expon (2, 8))
   771:                         then Static_Modular_lt8
   772:                         else Static_Modular_8)
   773:                      elsif Typ = EW_BitVector_16_Type
   774:                      then
   775:                        (if UI_Lt (Modulus_Val, UI_Expon (2, 16))
   776:                         then Static_Modular_lt16
   777:                         else Static_Modular_16)
   778:                      elsif Typ = EW_BitVector_32_Type
   779:                      then
   780:                        (if UI_Lt (Modulus_Val, UI_Expon (2, 32))
   781:                         then Static_Modular_lt32
   782:                         else Static_Modular_32)
   783:                      elsif Typ = EW_BitVector_64_Type
   784:                      then
   785:                        (if UI_Lt (Modulus_Val, UI_Expon (2, 64))
   786:                         then Static_Modular_lt64
   787:                         else Static_Modular_64)
   788:                      elsif Typ = EW_BitVector_128_Type
   789:                      then
   790:                        (if UI_Lt (Modulus_Val, UI_Expon (2, 128))
   791:                         then Static_Modular_lt128
   792:                         else Static_Modular_128)
   793:                      else raise Program_Error);
   794:                end;
   795:             elsif Has_Discrete_Type (E) then
   796:                return Static_Discrete;
   797:             elsif Has_Fixed_Point_Type (E) then
   798:                return Static_Fixed_Point;
   799:             else
   800:                pragma Assert (Has_Floating_Point_Type (E));
   801:                return
   802:                  (if Typ = EW_Float_32_Type
   803:                   then Static_Float32
   804:                   elsif Typ = EW_Float_64_Type
   805:                   then Static_Float64
   806:                   elsif Typ = EW_Float_80_Type
   807:                   then Static_Float80
   808:                   else raise Program_Error);
   809:             end if;
   810:          else
   811:             if Has_Modular_Integer_Type (E)
   812:               and then not Has_No_Bitwise_Operations_Annotation (E)
   813:             then
   814:                return Dynamic_Modular;
   815:             elsif Has_Discrete_Type (E) then
   816:                return Dynamic_Discrete;
   817:             elsif Has_Fixed_Point_Type (E) then
   818:                return Dynamic_Fixed_Point;
   819:             else
   820:                pragma Assert (Has_Floating_Point_Type (E));
   821:                return Dynamic_Float;
   822:             end if;
   823:          end if;
   824:       end Pick_Clone;
   825:
   826:       --  Local variables
   827:
   828:       Rng : constant Node_Id := Get_Range (E);
   829:
   830:       --  Start of processing for Declare_Scalar_Type
   831:
   832:    begin
   833:       --  Create a theory for the underlying fixed point type if needed
   834:
   835:       if Has_Fixed_Point_Type (E) then
   836:          Create_Fixed_Point_Theory_If_Needed (E);
   837:       end if;
   838:
   839:       --  Declare the logic type:
   840:       --  If the type is dynamic, declare an alias of its base type.
   841:
   842:       if not Is_Static then
   843:          Emit
   844:            (Th, New_Type_Decl (Name => Why_Name, Alias => Base_Type_In_Why));
   845:
   846:       --  For static signed integer types, declare a range type
   847:
   848:       elsif Is_Range_Type_In_Why (E) then
   849:          Emit
   850:            (Th,
   851:             New_Type_Decl
   852:               (Name       => Why_Name,
   853:                Labels     => Symbol_Sets.Empty_Set,
   854:                Definition =>
   855:                  New_Range_Type_Definition
   856:                    (First => Expr_Value (Low_Bound (Rng)),
   857:                     Last  => Expr_Value (High_Bound (Rng)))));
   858:
   859:       --  For other static types, declare an abstract type
   860:
   861:       else
   862:          Emit
   863:            (Th,
   864:             New_Type_Decl (Name => Why_Name, Labels => Symbol_Sets.Empty_Set));
   865:       end if;
   866:
   867:       --  retrieve and declare the attributes first, last, small, and modulus
   868:
   869:       Define_Scalar_Attributes
   870:         (Th => Th, E => E, Base_Type => Base_Why_Type (E));
   871:
   872:       --  define first_int and last_int for static modular types
   873:
   874:       if Is_Static
   875:         and then Is_Modular_Integer_Type (E)
   876:         and then not Has_No_Bitwise_Operations_Annotation (E)
   877:       then
   878:          Emit
   879:            (Th,
   880:             Why.Atree.Builders.New_Function_Decl
   881:               (Domain      => EW_Term,
   882:                Name        =>
   883:                  New_Identifier (Name => "first_int", Typ => EW_Int_Type),
   884:                Binders     => (1 .. 0 => <>),
   885:                Return_Type => EW_Int_Type,
   886:                Labels      => Symbol_Sets.Empty_Set,
   887:                Location    => No_Location,
   888:                Def         =>
   889:                  New_Integer_Constant
   890:                    (Value => Expr_Value (Low_Bound (Rng)))));
   891:          Emit
   892:            (Th,
   893:             Why.Atree.Builders.New_Function_Decl
   894:               (Domain      => EW_Term,
   895:                Name        =>
   896:                  New_Identifier (Name => "last_int", Typ => EW_Int_Type),
   897:                Binders     => (1 .. 0 => <>),
   898:                Return_Type => EW_Int_Type,
   899:                Labels      => Symbol_Sets.Empty_Set,
   900:                Location    => No_Location,
   901:                Def         =>
   902:                  New_Integer_Constant
   903:                    (Value => Expr_Value (High_Bound (Rng)))));
   904:       end if;
   905:
   906:       Generate_Range_Predicate
   907:         (Name => (if Is_Static then WNE_Range_Pred else WNE_Dynamic_Property));
   908:
   909:       --  clone the appropriate module
   910:
   911:       Emit
   912:         (Th,
   913:          New_Clone_Declaration
   914:            (Theory_Kind   => EW_Module,
   915:             Clone_Kind    => EW_Export,
   916:             As_Name       => No_Symbol,
   917:             Origin        => Pick_Clone,
   918:             Substitutions => Compute_Clone_Subst));
   919:    end Declare_Scalar_Type;
   920:
   921:    ----------------------------------------
   922:    -- Define_Enumeration_Rep_Convertions --
   923:    ----------------------------------------
   924:
   925:    procedure Define_Enumeration_Rep_Convertions (Th : Theory_UC; E : Entity_Id)
   926:    is
   927:       --  For a type:
```

## src/why/why-gen-scalars.adb:1117-1470

```ada
  1117:    procedure Define_Scalar_Attributes
  1118:      (Th : Theory_UC; E : Entity_Id; Base_Type : W_Type_Id)
  1119:    is
  1120:       Rng  : constant Node_Id := Get_Range (E);
  1121:       Low  : constant Node_Id := Low_Bound (Rng);
  1122:       High : constant Node_Id := High_Bound (Rng);
  1123:
  1124:       First : constant W_Term_OId :=
  1125:         (if Compile_Time_Known_Value (Low)
  1126:          then +Num_Constant (E, Low)
  1127:          else Why_Empty);
  1128:
  1129:       Last : constant W_Term_OId :=
  1130:         (if Compile_Time_Known_Value (High)
  1131:          then +Num_Constant (E, High)
  1132:          else Why_Empty);
  1133:
  1134:    begin
  1135:       --  Compute and declare the modulus attribute of modular integer types
  1136:
  1137:       if Has_Modular_Integer_Type (E) then
  1138:          declare
  1139:             Modulus_Val : constant Uint := Modulus (E);
  1140:             Typ         : constant W_Type_Id := Base_Why_Type (E);
  1141:             Modul       : W_Term_OId;
  1142:          begin
  1143:             Modul :=
  1144:               (if Typ = EW_BitVector_8_Type
  1145:                then
  1146:                  (if UI_Lt (Modulus_Val, UI_Expon (2, 8))
  1147:                   then
  1148:                     New_Modular_Constant
  1149:                       (Value => Modulus_Val, Typ => EW_BitVector_8_Type)
  1150:                   else Why_Empty)
  1151:                elsif Typ = EW_BitVector_16_Type
  1152:                then
  1153:                  (if UI_Lt (Modulus_Val, UI_Expon (2, 16))
  1154:                   then
  1155:                     New_Modular_Constant
  1156:                       (Value => Modulus_Val, Typ => EW_BitVector_16_Type)
  1157:                   else Why_Empty)
  1158:                elsif Typ = EW_BitVector_32_Type
  1159:                then
  1160:                  (if UI_Lt (Modulus_Val, UI_Expon (2, 32))
  1161:                   then
  1162:                     New_Modular_Constant
  1163:                       (Value => Modulus_Val, Typ => EW_BitVector_32_Type)
  1164:                   else Why_Empty)
  1165:                elsif Typ = EW_BitVector_64_Type
  1166:                then
  1167:                  (if UI_Lt (Modulus_Val, UI_Expon (2, 64))
  1168:                   then
  1169:                     New_Modular_Constant
  1170:                       (Value => Modulus_Val, Typ => EW_BitVector_64_Type)
  1171:                   else Why_Empty)
  1172:                elsif Typ = EW_BitVector_128_Type
  1173:                then
  1174:                  (if UI_Lt (Modulus_Val, UI_Expon (2, 128))
  1175:                   then
  1176:                     New_Modular_Constant
  1177:                       (Value => Modulus_Val, Typ => EW_BitVector_128_Type)
  1178:                   else Why_Empty)
  1179:                elsif Typ = EW_Int_Type
  1180:                then New_Integer_Constant (Value => Modulus_Val)
  1181:                else raise Program_Error);
  1182:
  1183:             Emit
  1184:               (Th,
  1185:                Why.Atree.Builders.New_Function_Decl
  1186:                  (Domain      => EW_Pterm,
  1187:                   Name        => To_Local (E_Symb (E, WNE_Attr_Modulus)),
  1188:                   Binders     => (1 .. 0 => <>),
  1189:                   Return_Type => Base_Type,
  1190:                   Labels      => Symbol_Sets.Empty_Set,
  1191:                   Location    => No_Location,
  1192:                   Def         => +Modul));
  1193:          end;
  1194:
  1195:       --  Compute and declare the small attribute of fixed point types
  1196:
  1197:       elsif Has_Fixed_Point_Type (E) then
  1198:          declare
  1199:             Small     : constant Ureal := Small_Value (E);
  1200:             Num_Small : constant W_Term_OId :=
  1201:               New_Integer_Constant (Value => Norm_Num (Small));
  1202:             Den_Small : constant W_Term_OId :=
  1203:               New_Integer_Constant (Value => Norm_Den (Small));
  1204:          begin
  1205:             Emit
  1206:               (Th,
  1207:                Why.Atree.Builders.New_Function_Decl
  1208:                  (Domain      => EW_Pterm,
  1209:                   Name        => To_Local (E_Symb (E, WNE_Small_Num)),
  1210:                   Binders     => (1 .. 0 => <>),
  1211:                   Return_Type => Base_Type,
  1212:                   Labels      => Symbol_Sets.Empty_Set,
  1213:                   Location    => No_Location,
  1214:                   Def         => +Num_Small));
  1215:             Emit
  1216:               (Th,
  1217:                Why.Atree.Builders.New_Function_Decl
  1218:                  (Domain      => EW_Pterm,
  1219:                   Name        => To_Local (E_Symb (E, WNE_Small_Den)),
  1220:                   Binders     => (1 .. 0 => <>),
  1221:                   Return_Type => Base_Type,
  1222:                   Labels      => Symbol_Sets.Empty_Set,
  1223:                   Location    => No_Location,
  1224:                   Def         => +Den_Small));
  1225:          end;
  1226:
  1227:       --  For enumeration types with an enumeration representation clause, we
  1228:       --  need conversion functions to translate the Enum_Rep and Enum_Val
  1229:       --  attributes.
  1230:
  1231:       elsif Is_Enumeration_Type (Retysp (E))
  1232:         and then Has_Enumeration_Rep_Clause (Retysp (E))
  1233:       then
  1234:          Define_Enumeration_Rep_Convertions (Th, E);
  1235:       end if;
  1236:
  1237:       --  Compute and declare the first and last attributes of E
  1238:       --  If they are static, those are constants.
  1239:       --  Otherwise, we declare logic functions for them, with arguments for
  1240:       --  the variables they may read. These functions will be defined later
  1241:       --  in the axiom module of E.
  1242:       --  First and Last attributes of Itypes are never used, do not declare
  1243:       --  them.
  1244:
  1245:       if not (Type_Is_Modeled_As_Base (E) and then Is_Itype (E)) then
  1246:          declare
  1247:             Binders : Item_Array :=
  1248:               Get_Binders_From_Expression (Low_Bound (Rng));
  1249:          begin
  1250:             Localize_Binders (Binders, Only_Variables => False);
  1251:             Emit
  1252:               (Th,
  1253:                New_Function_Decl
  1254:                  (Domain      => EW_Pterm,
  1255:                   Name        => To_Local (E_Symb (E, WNE_Attr_First)),
  1256:                   Items       => Binders,
  1257:                   Return_Type => Base_Type,
  1258:                   Location    => No_Location,
  1259:                   Labels      => Symbol_Sets.Empty_Set,
  1260:                   Def         => +First));
  1261:          end;
  1262:          declare
  1263:             Binders : Item_Array :=
  1264:               Get_Binders_From_Expression (High_Bound (Rng));
  1265:          begin
  1266:             Localize_Binders (Binders, Only_Variables => False);
  1267:             Emit
  1268:               (Th,
  1269:                New_Function_Decl
  1270:                  (Domain      => EW_Pterm,
  1271:                   Name        => To_Local (E_Symb (E, WNE_Attr_Last)),
  1272:                   Items       => Binders,
  1273:                   Return_Type => Base_Type,
  1274:                   Location    => No_Location,
  1275:                   Labels      => Symbol_Sets.Empty_Set,
  1276:                   Def         => +Last));
  1277:          end;
  1278:       end if;
  1279:    end Define_Scalar_Attributes;
  1280:
  1281:    ----------------------------
  1282:    -- Define_Scalar_Rep_Proj --
  1283:    ----------------------------
  1284:
  1285:    procedure Define_Scalar_Rep_Proj (Th : Theory_UC; E : Entity_Id) is
  1286:       Rep_Type : constant W_Type_Id := Base_Why_Type (E);
  1287:
  1288:       function Pick_Clone return W_Module_Id;
  1289:       --  Pick the correct theory to clone depending on the scalar type.
  1290:
  1291:       function Pick_Clone return W_Module_Id is
  1292:       begin
  1293:          if Rep_Type = EW_Float_32_Type then
  1294:             return Rep_Proj_Float32;
  1295:          elsif Rep_Type = EW_Float_64_Type then
  1296:             return Rep_Proj_Float64;
  1297:          elsif Rep_Type = EW_Float_80_Type then
  1298:             return Rep_Proj_Float80;
  1299:          elsif Rep_Type = EW_Int_Type then
  1300:             return Rep_Proj_Int;
  1301:          elsif Why_Type_Is_Fixed (Rep_Type) then
  1302:             return Rep_Proj_Fixed;
  1303:          elsif Why_Type_Is_BitVector (Rep_Type) then
  1304:             declare
  1305:                Modulus_Val : constant Uint := Modulus (E);
  1306:             begin
  1307:                return
  1308:                  (if Rep_Type = EW_BitVector_8_Type
  1309:                   then
  1310:                     (if UI_Lt (Modulus_Val, UI_Expon (2, 8))
  1311:                      then Rep_Proj_Lt8
  1312:                      else Rep_Proj_8)
  1313:                   elsif Rep_Type = EW_BitVector_16_Type
  1314:                   then
  1315:                     (if UI_Lt (Modulus_Val, UI_Expon (2, 16))
  1316:                      then Rep_Proj_Lt16
  1317:                      else Rep_Proj_16)
  1318:                   elsif Rep_Type = EW_BitVector_32_Type
  1319:                   then
  1320:                     (if UI_Lt (Modulus_Val, UI_Expon (2, 32))
  1321:                      then Rep_Proj_Lt32
  1322:                      else Rep_Proj_32)
  1323:                   elsif Rep_Type = EW_BitVector_64_Type
  1324:                   then
  1325:                     (if UI_Lt (Modulus_Val, UI_Expon (2, 64))
  1326:                      then Rep_Proj_Lt64
  1327:                      else Rep_Proj_64)
  1328:                   elsif Rep_Type = EW_BitVector_128_Type
  1329:                   then
  1330:                     (if UI_Lt (Modulus_Val, UI_Expon (2, 128))
  1331:                      then Rep_Proj_Lt128
  1332:                      else Rep_Proj_128)
  1333:                   else raise Program_Error);
  1334:             end;
  1335:          else
  1336:             raise Program_Error;
  1337:          end if;
  1338:       end Pick_Clone;
  1339:
  1340:       Default_Clone_Subst : constant W_Clone_Substitution_Array :=
  1341:         (1 =>
  1342:            New_Clone_Substitution
  1343:              (Kind      => EW_Type_Subst,
  1344:               Orig_Name => New_Name (Symb => NID ("t")),
  1345:               Image     => To_Why_Type (E)));
  1346:
  1347:       In_Range_Substs : constant W_Clone_Substitution_Array :=
  1348:         (if Is_Modular_Integer_Type (E)
  1349:            and then not Has_No_Bitwise_Operations_Annotation (E)
  1350:          then
  1351:            (1 =>
  1352:               New_Clone_Substitution
  1353:                 (Kind      => EW_Predicate,
  1354:                  Orig_Name => New_Name (Symb => NID ("in_range")),
  1355:                  Image     => Get_Name (E_Symb (E, WNE_Range_Pred))),
  1356:             2 =>
  1357:               New_Clone_Substitution
  1358:                 (Kind      => EW_Predicate,
  1359:                  Orig_Name => New_Name (Symb => NID ("in_range_int")),
  1360:                  Image     => Get_Name (E_Symb (E, WNE_Range_Pred_BV_Int))))
  1361:          else
  1362:            (1 =>
  1363:               New_Clone_Substitution
  1364:                 (Kind      => EW_Predicate,
  1365:                  Orig_Name => New_Name (Symb => NID ("in_range")),
  1366:                  Image     => Get_Name (E_Symb (E, WNE_Range_Pred)))));
  1367:
  1368:       Mod_Clone_Subst : constant W_Clone_Substitution_Array :=
  1369:         (if Has_Modular_Integer_Type (E)
  1370:            and then not Has_No_Bitwise_Operations_Annotation (E)
  1371:            and then Modulus (E) /= UI_Expon (2, Modular_Size (E))
  1372:          then
  1373:            (1 =>
  1374:               New_Clone_Substitution
  1375:                 (Kind      => EW_Function,
  1376:                  Orig_Name => To_Local (E_Symb (E, WNE_Attr_Modulus)),
  1377:                  Image     => Get_Name (E_Symb (E, WNE_Attr_Modulus))))
  1378:          else (1 .. 0 => <>));
  1379:
  1380:       Range_Type_Subst : constant W_Clone_Substitution_Array :=
  1381:         (if Is_Range_Type_In_Why (E)
  1382:          then
  1383:            (1 =>
  1384:               New_Clone_Substitution
  1385:                 (Kind      => EW_Function,
  1386:                  Orig_Name => New_Name (Symb => NID ("to_rep")),
  1387:                  Image     => To_Local (E_Symb (E, WNE_To_Rep))))
  1388:          else (1 .. 0 => <>));
  1389:
  1390:       Substs : constant W_Clone_Substitution_Array :=
  1391:         Default_Clone_Subst
  1392:         & In_Range_Substs
  1393:         & Mod_Clone_Subst
  1394:         & Range_Type_Subst;
  1395:
  1396:       Clone : constant W_Module_Id := Pick_Clone;
  1397:
  1398:    begin
  1399:       Add_With_Clause (Th, E_Module (E), EW_Clone_Default);
  1400:
  1401:       if Is_Modular_Integer_Type (E)
  1402:         and then not Has_No_Bitwise_Operations_Annotation (E)
  1403:       then
  1404:          Add_With_Clause (Th, MF_BVs (Rep_Type).Module, EW_Clone_Default);
  1405:
  1406:       elsif Is_Floating_Point_Type (E) then
  1407:          Add_With_Clause (Th, MF_Floats (Rep_Type).Module, EW_Clone_Default);
  1408:       end if;
  1409:
  1410:       if Is_Range_Type_In_Why (E) then
  1411:
  1412:          --  For range types, declare a renaming of t'int which will be used
  1413:          --  to clone the representative theory.
  1414:
  1415:          declare
  1416:             Var     : constant W_Identifier_Id :=
  1417:               New_Identifier (Name => "x", Typ => EW_Abstract (E));
  1418:             Binders : constant Binder_Array :=
  1419:               Binder_Array'(1 => Binder_Type'(B_Name => Var, others => <>));
  1420:          begin
  1421:
  1422:             Emit
  1423:               (Th,
  1424:                New_Function_Decl
  1425:                  (Domain      => EW_Term,
  1426:                   Name        => To_Local (E_Symb (E, WNE_To_Rep)),
  1427:                   Binders     => Binders,
  1428:                   Return_Type => EW_Int_Type,
  1429:                   Def         =>
  1430:                     New_Call
  1431:                       (Domain => EW_Term,
  1432:                        Name   => E_Symb (E, WNE_Int_Proj),
  1433:                        Args   => (1 => +Var),
  1434:                        Typ    => EW_Int_Type),
  1435:                   Location    => No_Location,
  1436:                   Labels      => Symbol_Sets.Empty_Set));
  1437:          end;
  1438:       end if;
  1439:
  1440:       Emit
  1441:         (Th,
  1442:          New_Clone_Declaration
  1443:            (Theory_Kind   => EW_Module,
  1444:             Clone_Kind    => EW_Export,
  1445:             As_Name       => No_Symbol,
  1446:             Origin        => Clone,
  1447:             Substitutions => Substs));
  1448:
  1449:       --  Declare metas for functions projecting values of why abstract types
  1450:       --  to concrete values
  1451:       --    - the defined type is why abstract type. To see the concrete value
  1452:       --      in a counterexample, it is needed to project the value of this
  1453:       --      type using projection function
  1454:       --    - the function F is projection function for abstract type T if it
  1455:       --      is marked with the meta "model_projection" and has a single
  1456:       --      argument of type T.
  1457:       --    - the projection functions are cloned from projection functions
  1458:       --      defined in ada__model.mlw
  1459:       --    - Since for why3, the cloned function and the original function are
  1460:       --      two different functions, it is necessary to emit projection meta
  1461:       --      for cloned projection functions.
  1462:
  1463:       --  Note that if E is dynamic type, to_rep is not projection function
  1464:       Emit_Projection_Metas (Th, "to_rep");
  1465:
  1466:    end Define_Scalar_Rep_Proj;
  1467:
  1468:    -------------------------------------
  1469:    -- Get_Fixed_Point_Mult_Div_Theory --
  1470:    -------------------------------------
```

## src/why/why-gen-scalars.adb:1546-1575

```ada
  1546:    function Num_Constant (Ty : Entity_Id; N : Node_Id) return W_Term_Id is
  1547:    begin
  1548:       if Is_Modular_Integer_Type (Ty)
  1549:         and then not Has_No_Bitwise_Operations_Annotation (Ty)
  1550:       then
  1551:          return
  1552:            New_Modular_Constant
  1553:              (Value => Expr_Value (N), Typ => Base_Why_Type (Ty));
  1554:       elsif Is_Discrete_Type (Ty) then
  1555:          return New_Integer_Constant (Value => Expr_Value (N));
  1556:       elsif Is_Fixed_Point_Type (Ty) then
  1557:          return
  1558:            New_Fixed_Constant
  1559:              (Value => Expr_Value (N), Typ => Base_Why_Type (Ty));
  1560:       elsif Is_Floating_Point_Type (Ty) then
  1561:
  1562:          --  Real ranges can use fixed point values, but they have to be static
  1563:          --  and the compiler inlines them; see acats c35704a.
  1564:
  1565:          pragma Assert (not Is_Fixed_Point_Type (Etype (N)));
  1566:
  1567:          return
  1568:            New_Float_Constant
  1569:              (Value => Expr_Value_R (N), Typ => Base_Why_Type (Ty));
  1570:       else
  1571:          return New_Real_Constant (Value => Expr_Value_R (N));
  1572:       end if;
  1573:    end Num_Constant;
  1574:
  1575: end Why.Gen.Scalars;
```

## src/why/why-inter.adb:354-379

```ada
   354:       end if;
   355:    end Add_Use_For_Entity;
   356:
   357:    ---------------------
   358:    -- Add_With_Clause --
   359:    ---------------------
   360:
   361:    procedure Add_With_Clause
   362:      (T        : W_Theory_Declaration_Id;
   363:       Module   : W_Module_Id;
   364:       Use_Kind : EW_Clone_Type)
   365:    is
   366:       Use_Kind2 : constant EW_Clone_Type :=
   367:         (if Module in Int_Module | RealInfix then EW_Import else Use_Kind);
   368:       --  ??? override the Use_Kind given by the caller
   369:
   370:    begin
   371:       Theory_Declaration_Append_To_Includes
   372:         (T,
   373:          New_Include_Declaration
   374:            (Module => Module, Use_Kind => Use_Kind2, Kind => EW_Module));
   375:    end Add_With_Clause;
   376:
   377:    procedure Add_With_Clause
   378:      (T : Theory_UC; Module : W_Module_Id; Use_Kind : EW_Clone_Type) is
   379:    begin
```

## src/why/why-inter.adb:387-437

```ada
   387:    function Base_Why_Type (W : W_Type_Id) return W_Type_Id is
   388:       Kind : constant EW_Type := Get_Type_Kind (W);
   389:    begin
   390:       case Kind is
   391:          when EW_Abstract | EW_Split =>
   392:             return Base_Why_Type (Get_Ada_Node (+W));
   393:
   394:          when others                 =>
   395:             if W = M_Boolean_Init_Wrapper.Wrapper_Ty then
   396:                return EW_Bool_Type;
   397:             else
   398:                return W;
   399:             end if;
   400:       end case;
   401:    end Base_Why_Type;
   402:
   403:    function Base_Why_Type (N : Node_Id) return W_Type_Id is
   404:
   405:       E   : constant W_Type_Id := Get_EW_Term_Type (N);
   406:       Typ : Entity_Id :=
   407:         (if Nkind (N) in N_Entity and then Is_Type (N) then N else Etype (N));
   408:    begin
   409:       if E = Why_Empty then
   410:
   411:          --  For record or private types, go through subtypes to get the base
   412:          --  type.
   413:          --  For pointers, get the type of the root type (pointers may share
   414:          --  same representative theory while one is not the subtype of the
   415:          --  other, exp: named and anonymous types of the same designated
   416:          --  type).
   417:
   418:          loop
   419:             Typ := Retysp (Typ);
   420:
   421:             if (Is_Record_Type (Typ)
   422:                 or else Is_Incomplete_Or_Private_Type (Typ))
   423:               and then not Is_Base_Type (Typ)
   424:             then
   425:                Typ := Etype (Typ);
   426:             elsif Is_Access_Type (Typ)
   427:               and then not Is_Access_Subprogram_Type (Typ)
   428:             then
   429:                return EW_Abstract (Root_Retysp (Typ));
   430:             else
   431:                return EW_Abstract (Typ);
   432:             end if;
   433:          end loop;
   434:       else
   435:          return E;
   436:       end if;
   437:    end Base_Why_Type;
```

## src/why/why-inter.adb:550-746

```ada
   550:          Entry_Points.Include (Node_Graphs.Key (Cu));
   551:       end loop;
   552:
   553:       for Elt of Entry_Points loop
   554:          DFS (Elt);
   555:       end loop;
   556:    end Check_Safe_Guard_Cycles;
   557:
   558:    ------------------
   559:    -- Close_Theory --
   560:    ------------------
   561:
   562:    procedure Close_Theory
   563:      (Th             : in out Theory_UC;
   564:       Kind           : Theory_Kind;
   565:       Defined_Entity : Entity_Id := Empty)
   566:    is
   567:       S : constant Why_Node_Sets.Set := Compute_Module_Set (+(Th.Th));
   568:
   569:       procedure Add_Definition_Imports
   570:         (Filter_Module : W_Module_Id := Why_Empty);
   571:       --  Adds imports for the definitions of symbols in S.
   572:
   573:       procedure Add_Axiom_Imports;
   574:       --  Adds imports for the axioms of symbols in S. Filter the axiom
   575:       --  modules which are mutually recursive with the defined entity if any.
   576:
   577:       procedure Record_Dependencies (Filter_Module : W_Module_Id := Why_Empty);
   578:       --  Records the dependencies between the current module and the modules
   579:       --  in S.
   580:
   581:       -----------------------
   582:       -- Add_Axiom_Imports --
   583:       -----------------------
   584:
   585:       procedure Add_Axiom_Imports is
   586:          Filter : Why_Node_Sets.Set;
   587:          Mask   : constant Why_Node_Maps.Map :=
   588:            Get_Refinement_Mask (Defined_Entity);
   589:          --  Get a mask used to update the Module_Dependencies map in order to
   590:          --  take into account visibility of refined posts and expression
   591:          --  function definitions.
   592:
   593:          Closure : Why_Node_Sets.Set;
   594:       begin
   595:          pragma Assert (Present (Defined_Entity));
   596:
   597:          --  Filter out the axiom modules of mutually dependent entities
   598:
   599:          if Ekind (Defined_Entity)
   600:             in E_Function | E_Entry | E_Procedure | E_Package
   601:          then
   602:             Filter := Mutually_Recursive_Modules (Defined_Entity);
   603:          end if;
   604:
   605:          Closure :=
   606:            Get_Graph_Closure
   607:              (Map    => Module_Dependencies,
   608:               From   => S,
   609:               Filter => Filter,
   610:               Mask   => Mask);
   611:
   612:          if not Safe_Guard_Graph.Contains (Defined_Entity) then
   613:             Safe_Guard_Graph.Include (Defined_Entity, Node_Sets.Empty_Set);
   614:          end if;
   615:
   616:          for M of Closure loop
   617:             declare
   618:                Node : constant Node_Id := Get_Ada_Node (M);
   619:             begin
   620:                --  Special case for local constants. The closure contains the
   621:                --  axiom module for local constants, but we don't need these
   622:                --  axioms in the subprogram/package that directly contains the
   623:                --  constant, so we filter this here.
   624:
   625:                if Present (Node)
   626:                  and then Nkind (Node) in N_Entity
   627:                  and then Is_Constant_Object (Node)
   628:                  and then Is_Declared_In_Unit (Node, Defined_Entity)
   629:                then
   630:                   null;
   631:                else
   632:                   Add_With_Clause (Th, W_Module_Id (M), EW_Clone_Default);
   633:
   634:                   --  For each includes of axiom modules, we add an edge into
   635:                   --  the Safe_Guard_Graph.
   636:
   637:                   declare
   638:                      use Entity_For_Axiom_Module_Maps;
   639:                      C : constant Entity_For_Axiom_Module_Maps.Cursor :=
   640:                        Entity_For_Axiom_Module.Find (M);
   641:                   begin
   642:                      if Has_Element (C) and then Present (Defined_Entity) then
   643:                         Safe_Guard_Graph (Defined_Entity).Include
   644:                           (Element (C));
   645:                      end if;
   646:                   end;
   647:                end if;
   648:             end;
   649:          end loop;
   650:       end Add_Axiom_Imports;
   651:
   652:       ----------------------------
   653:       -- Add_Definition_Imports --
   654:       ----------------------------
   655:
   656:       procedure Add_Definition_Imports
   657:         (Filter_Module : W_Module_Id := Why_Empty) is
   658:       begin
   659:          for M of S loop
   660:             if +M /= Filter_Module and then +M /= Th.Module then
   661:                Add_With_Clause (Th, W_Module_Id (M), EW_Clone_Default);
   662:             end if;
   663:          end loop;
   664:       end Add_Definition_Imports;
   665:
   666:       -------------------------
   667:       -- Record_Dependencies --
   668:       -------------------------
   669:
   670:       procedure Record_Dependencies (Filter_Module : W_Module_Id := Why_Empty)
   671:       is
   672:       begin
   673:          for M of S loop
   674:             if +M /= Filter_Module and then +M /= Th.Module then
   675:                Add_To_Graph (Module_Dependencies, +Th.Module, M);
   676:             end if;
   677:          end loop;
   678:       end Record_Dependencies;
   679:
   680:       --  Start of processing for Close_Theory
   681:
   682:    begin
   683:       Add_With_Clause (Th.Th, M_Main.Module, EW_Import);
   684:       Add_With_Clause (Th.Th, Int_Module, EW_Import);
   685:
   686:       case Kind is
   687:          --  case 1: a standalone theory with no dependencies
   688:
   689:          when Standalone_Theory    =>
   690:             null;
   691:
   692:          --  case 2: a theory defining the symbols for Defined_Entity
   693:
   694:          --  Add dependencies between the current module and all other modules
   695:          --  used in the its definition. This will be used when importing the
   696:          --  axiom theories in case 4 below.
   697:
   698:          --  Add imports for other symbols used in the definition of
   699:          --  Defined_Entity. Make sure not to import the current theory
   700:          --  defining Defined_Entity itself. Add standard imports.
   701:
   702:          when Definition_Theory    =>
   703:             declare
   704:                Filter_Module : constant W_Module_Id :=
   705:                  (if No (Defined_Entity)
   706:                   then Why_Empty
   707:                   else E_Module (Defined_Entity));
   708:             begin
   709:                Record_Dependencies (Filter_Module);
   710:                Add_Definition_Imports (Filter_Module);
   711:             end;
   712:
   713:          --  case 3: a theory giving axioms for Defined_Entity
   714:
   715:          --  Add dependencies between the current module and all other modules
   716:          --  used in the its axioms. This will be used when importing the
   717:          --  axiom theories in case 4 below.
   718:          --  Also record the dependency between the definition module for
   719:          --  Defined_Entity and its axiom module.
   720:
   721:          --  Add imports for all symbols used in the axioms of Defined_Entity.
   722:          --  The definition theory for Defined_Entity will be one of those. Add
   723:          --  standard imports.
   724:
   725:          when Axiom_Theory         =>
   726:             pragma Assert (Present (Defined_Entity));
   727:             Record_Dependencies;
   728:             Record_Extra_Dependency (E_Module (Defined_Entity), Th.Module);
   729:             Add_Definition_Imports;
   730:
   731:          --  case 4: a theory for generating VCs
   732:
   733:          --  Add to S the set of all axioms used transitively to define symbols
   734:          --  in the current theory. Add imports for all symbols used and their
   735:          --  axioms. Add standard imports.
   736:
   737:          when VC_Generation_Theory =>
   738:             Add_Definition_Imports;
   739:             Add_Axiom_Imports;
   740:       end case;
   741:
   742:       declare
   743:          Th_Id : constant W_Theory_Declaration_Id := Th.Th;
   744:          N     : constant Symbol := Get_Name (Th_Id);
   745:       begin
   746:          Why_Sections (Th.Section).Append (+Th_Id);
```

## src/why/why-inter.adb:756-799

```ada
   756:    function Eq_Base (Left, Right : W_Type_Id) return Boolean is
   757:    begin
   758:       if Left = Right then
   759:          return True;
   760:
   761:       --  Builtin nodes can be compared directly
   762:
   763:       elsif Get_Type_Kind (Left) in EW_Builtin then
   764:          return False;
   765:
   766:       --  Two types with different kinds cannot be equal
   767:
   768:       elsif Get_Type_Kind (Left) /= Get_Type_Kind (Right) then
   769:          return False;
   770:
   771:       --  If one is a wrapper and not the other, they are not equal
   772:
   773:       elsif Get_Relaxed_Init (Left) /= Get_Relaxed_Init (Right) then
   774:          return False;
   775:
   776:       --  For EW_Abstract and EW_Split types, compare the Ada node
   777:
   778:       elsif Get_Type_Kind (Left) in EW_Abstract | EW_Split then
   779:
   780:          --  Dummy EW_Abstract types are introduced for record private parts.
   781:          --  Eq_Base should only be called on such types if they are equal.
   782:
   783:          pragma
   784:            Assert
   785:              ((No (Get_Ada_Node (+Left))
   786:                and then No (Get_Ada_Node (+Right))
   787:                and then Get_Name (+Left) = Get_Name (+Right))
   788:               or else
   789:                 (Present (Get_Ada_Node (+Left))
   790:                  and then Present (Get_Ada_Node (+Right))));
   791:
   792:          return Get_Ada_Node (+Left) = Get_Ada_Node (+Right);
   793:       else
   794:          raise Program_Error;
   795:       end if;
   796:    end Eq_Base;
   797:
   798:    ---------------
   799:    -- Eq_In_Why --
```

## src/why/why-inter.adb:836-872

```ada
   836:    function EW_Abstract
   837:      (N : Node_Id; Relaxed_Init : Boolean := False) return W_Type_Id is
   838:    begin
   839:       return EW_Abstract_Shared (N, EW_Abstract, Relaxed_Init);
   840:    end EW_Abstract;
   841:
   842:    ------------------------
   843:    -- EW_Abstract_Shared --
   844:    ------------------------
   845:
   846:    function EW_Abstract_Shared
   847:      (N : Node_Id; Kind : EW_Type; Relaxed_Init : Boolean := False)
   848:       return W_Type_Id is
   849:    begin
   850:       if Is_Standard_Boolean_Type (N) then
   851:          if Relaxed_Init then
   852:             return M_Boolean_Init_Wrapper.Wrapper_Ty;
   853:          else
   854:             return EW_Bool_Type;
   855:          end if;
   856:
   857:       elsif N = Universal_Fixed then
   858:          return EW_Real_Type;
   859:
   860:       --  Classwide types are translated as their corresponding specific tagged
   861:       --  types.
   862:
   863:       elsif Is_Class_Wide_Type (N) then
   864:          return EW_Abstract_Shared (Specific_Tagged (N), Kind, Relaxed_Init);
   865:
   866:       elsif Retysp (N) /= N then
   867:          return EW_Abstract_Shared (Retysp (N), Kind, Relaxed_Init);
   868:       else
   869:          pragma Assert (Entity_In_SPARK (N));
   870:          return New_Kind_Base_Type (N, Kind, Relaxed_Init);
   871:       end if;
   872:    end EW_Abstract_Shared;
```

## src/why/why-inter.adb:943-1017

```ada
   943:    function Get_EW_Term_Type (N : Node_Id) return W_Type_Id is
   944:       Ty : Node_Id := N;
   945:    begin
   946:       if Nkind (N) /= N_Defining_Identifier or else not Is_Type (N) then
   947:          Ty := Etype (N);
   948:       end if;
   949:
   950:       case Ekind (Ty) is
   951:          when Fixed_Point_Kind           =>
   952:             return EW_Fixed_Type (Ty);
   953:
   954:          when Float_Kind                 =>
   955:             if Is_Single_Precision_Floating_Point_Type (Etype (Ty)) then
   956:                return EW_Float_32_Type;
   957:             elsif Is_Double_Precision_Floating_Point_Type (Etype (Ty)) then
   958:                return EW_Float_64_Type;
   959:             elsif Is_Extended_Precision_Floating_Point_Type (Etype (Ty)) then
   960:                return EW_Float_80_Type;
   961:             else
   962:                raise Program_Error;
   963:             end if;
   964:
   965:          when Discrete_Kind              =>
   966:             --  In the case of Standard.Boolean, the base type 'bool' is
   967:             --  used directly. For its subtypes, however, an abstract type
   968:             --  representing a signed int is generated, just like for any
   969:             --  other enumeration subtype.
   970:             --  ??? It would make sense to use a bool-based abstract
   971:             --  subtype in this case, and it should be rather easy to
   972:             --  make this change as soon as theory cloning would work
   973:             --  in Why 3. No point in implementing this improvement
   974:             --  before that, as we have seen no cases where this was a
   975:             --  problem for the prover.
   976:
   977:             if Is_Standard_Boolean_Type (Ty) then
   978:                return EW_Bool_Type;
   979:             elsif Ty = Universal_Fixed then
   980:                return EW_Real_Type;
   981:             elsif Is_Modular_Integer_Type (Ty)
   982:               and then not Has_No_Bitwise_Operations_Annotation (Ty)
   983:             then
   984:                declare
   985:                   Size : Uintp.Uint;
   986:                begin
   987:                   Size := Modular_Size (Ty);
   988:
   989:                   if Uintp.UI_Le (Size, 8) then
   990:                      return EW_BitVector_8_Type;
   991:                   elsif Uintp.UI_Le (Size, 16) then
   992:                      return EW_BitVector_16_Type;
   993:                   elsif Uintp.UI_Le (Size, 32) then
   994:                      return EW_BitVector_32_Type;
   995:                   elsif Uintp.UI_Le (Size, 64) then
   996:                      return EW_BitVector_64_Type;
   997:                   elsif Uintp.UI_Le (Size, 128) then
   998:                      return EW_BitVector_128_Type;
   999:                   else
  1000:                      return EW_Int_Type;
  1001:                   end if;
  1002:                end;
  1003:             else
  1004:                return EW_Int_Type;
  1005:             end if;
  1006:
  1007:          when Incomplete_Or_Private_Kind =>
  1008:             if Full_View_Not_In_SPARK (Ty) then
  1009:                return Why_Empty;
  1010:             else
  1011:                return Get_EW_Term_Type (Retysp (Ty));
  1012:             end if;
  1013:
  1014:          when others                     =>
  1015:             return Why_Empty;
  1016:       end case;
  1017:    end Get_EW_Term_Type;
```

## src/why/why-inter.adb:1149-1242

```ada
  1149:    function New_Abstract_Base_Type (E : Entity_Id) return W_Type_Id is
  1150:    begin
  1151:       return New_Kind_Base_Type (E, EW_Abstract, False);
  1152:    end New_Abstract_Base_Type;
  1153:
  1154:    ------------------------
  1155:    -- New_Kind_Base_Type --
  1156:    ------------------------
  1157:
  1158:    function New_Kind_Base_Type
  1159:      (E : Entity_Id; Kind : EW_Type; Relaxed_Init : Boolean) return W_Type_Id
  1160:    is
  1161:    begin
  1162:       --  We avoid having renaming of types in Why to allow using the same
  1163:       --  reference type.
  1164:
  1165:       if Is_Static_Array_Type (Retysp (E))
  1166:         or else (Kind = EW_Split and then Has_Array_Type (E))
  1167:       then
  1168:
  1169:          --  Static array types and arrays split forms are in fact Why3 maps
  1170:
  1171:          return
  1172:            New_Type
  1173:              (Ada_Node     => E,
  1174:               Is_Mutable   => False,
  1175:               Type_Kind    =>
  1176:                 (if Is_Static_Array_Type (Retysp (E))
  1177:                  then EW_Abstract
  1178:                  else Kind),
  1179:               Relaxed_Init => Relaxed_Init,
  1180:               Name         =>
  1181:                 New_Name
  1182:                   (Ada_Node => E,
  1183:                    Symb     => NID ("map"),
  1184:                    Module   =>
  1185:                      New_Module
  1186:                        (File => No_Symbol,
  1187:                         Name =>
  1188:                           Img (Get_Array_Theory_Name (E, Relaxed_Init)))));
  1189:       elsif Kind = EW_Split and then Has_Fixed_Point_Type (E) then
  1190:
  1191:          --  The base type of a fixed point type is __fixed. Do not call
  1192:          --  Base_Why_Type which may fail if the theory for the small value of
  1193:          --  E has not been constructed yet.
  1194:
  1195:          return
  1196:            New_Type
  1197:              (Ada_Node     => E,
  1198:               Is_Mutable   => False,
  1199:               Type_Kind    => Kind,
  1200:               Relaxed_Init => Relaxed_Init,
  1201:               Name         => Get_Name (M_Main.Fixed_Type));
  1202:       elsif Kind = EW_Split then
  1203:
  1204:          --  Discrete types split forms are their base why type
  1205:
  1206:          pragma Assert (Use_Split_Form_For_Type (E));
  1207:          return
  1208:            New_Type
  1209:              (Ada_Node     => E,
  1210:               Is_Mutable   => False,
  1211:               Relaxed_Init => Relaxed_Init,
  1212:               Type_Kind    => EW_Split,
  1213:               Name         => Get_Name (Base_Why_Type (E)));
  1214:       else
  1215:          return
  1216:            New_Type
  1217:              (Ada_Node     => E,
  1218:               Is_Mutable   => False,
  1219:               Relaxed_Init => Relaxed_Init,
  1220:               Type_Kind    => EW_Abstract,
  1221:               Name         => To_Why_Type (E, Relaxed_Init => Relaxed_Init));
  1222:       end if;
  1223:    end New_Kind_Base_Type;
  1224:
  1225:    --------------------
  1226:    -- New_Named_Type --
  1227:    --------------------
  1228:
  1229:    function New_Named_Type
  1230:      (Name : W_Name_Id; Relaxed_Init : Boolean := False) return W_Type_Id is
  1231:    begin
  1232:       return
  1233:         New_Type
  1234:           (Ada_Node     => Empty,
  1235:            Is_Mutable   => False,
  1236:            Type_Kind    => EW_Abstract,
  1237:            Name         => Name,
  1238:            Relaxed_Init => Relaxed_Init);
  1239:    end New_Named_Type;
  1240:
  1241:    function New_Named_Type (S : String) return W_Type_Id is
  1242:    begin
```

## src/why/why-inter.adb:1260-1285

```ada
  1260:               Is_Mutable => True);
  1261:       end if;
  1262:    end New_Ref_Type;
  1263:
  1264:    -----------------
  1265:    -- Open_Theory --
  1266:    -----------------
  1267:
  1268:    function Open_Theory
  1269:      (P : W_Section_Id; Module : W_Module_Id; Comment : String)
  1270:       return Theory_UC is
  1271:    begin
  1272:       return
  1273:         Theory_UC'
  1274:           (Th       =>
  1275:              New_Theory_Declaration
  1276:                (Name    => Get_Name (Module),
  1277:                 Kind    => EW_Module,
  1278:                 Comment => NID (Comment)),
  1279:            Module   => Module,
  1280:            Section  => P,
  1281:            Finished => False);
  1282:    end Open_Theory;
  1283:
  1284:    ---------------------------------
  1285:    -- Process_Info_Hiding_For_VCs --
```

## src/why/why-inter.adb:1547-1632

```ada
  1547:    function To_Why_Type
  1548:      (E : Entity_Id; Local : Boolean := False; Relaxed_Init : Boolean := False)
  1549:       return W_Name_Id
  1550:    is
  1551:       Suffix : constant String :=
  1552:         Short_Name (E)
  1553:         & (if Relaxed_Init then To_String (WNE_Init_Wrapper_Suffix) else "");
  1554:    begin
  1555:       --  Classwide types are translated as their corresponding specific tagged
  1556:       --  types.
  1557:
  1558:       if Is_Class_Wide_Type (E) then
  1559:          return To_Why_Type (Specific_Tagged (E), Local, Relaxed_Init);
  1560:
  1561:       elsif Local then
  1562:          return New_Name (Ada_Node => E, Symb => NID (Suffix));
  1563:
  1564:       else
  1565:          return
  1566:            New_Name
  1567:              (Ada_Node => E,
  1568:               Symb     => NID (Suffix),
  1569:               Module   =>
  1570:                 E_Module
  1571:                   (E, (if Relaxed_Init then Init_Wrapper else Regular)));
  1572:       end if;
  1573:    end To_Why_Type;
  1574:
  1575:    ------------------
  1576:    -- Type_Of_Node --
  1577:    ------------------
  1578:
  1579:    function Type_Of_Node (N : Node_Id) return W_Type_Id is
  1580:    begin
  1581:       --  look through 'old and 'loop_entry
  1582:
  1583:       if Nkind (N) = N_Attribute_Reference
  1584:         and then Attribute_Name (N) in Name_Loop_Entry | Name_Old
  1585:       then
  1586:          return Type_Of_Node (Prefix (N));
  1587:
  1588:       --  for objects, we want to look at the Why type of the Why object
  1589:
  1590:       elsif Nkind (N) in N_Identifier | N_Expanded_Name
  1591:         and then Is_Object (Entity (N))
  1592:         and then Ekind (Entity (N)) not in E_Discriminant | E_Component
  1593:         and then not Is_Part_Of_Protected_Object (Entity (N))
  1594:       then
  1595:          return Why_Type_Of_Entity (Entity (N));
  1596:       else
  1597:          declare
  1598:             E            : constant Entity_Id := Type_Of_Node (N);
  1599:             Relaxed_Init : constant Boolean :=
  1600:               (case Nkind (N) is
  1601:                  when N_Entity                       =>
  1602:                    (if Is_Type (N)
  1603:                     then False
  1604:                     elsif Is_Object (N)
  1605:                     then Obj_Has_Relaxed_Init (N)
  1606:                     elsif Ekind (N) = E_Function
  1607:                     then Fun_Has_Relaxed_Init (N)
  1608:                     else Has_Relaxed_Init (Etype (N))),
  1609:                  when N_Identifier | N_Expanded_Name =>
  1610:                    Is_Object (Entity (N))
  1611:                    and then Obj_Has_Relaxed_Init (Entity (N)),
  1612:                  when others                         =>
  1613:                    Expr_Has_Relaxed_Init (N));
  1614:          begin
  1615:             --  If N might be partially initialized, use a wrapper type
  1616:
  1617:             if Relaxed_Init then
  1618:                return EW_Abstract (E, Relaxed_Init => True);
  1619:
  1620:             --  Handle special cases boolean/real
  1621:
  1622:             elsif Is_Standard_Boolean_Type (E) then
  1623:                return EW_Bool_Type;
  1624:             elsif E = Universal_Fixed then
  1625:                return EW_Real_Type;
  1626:             elsif Is_Type (E) and then Use_Split_Form_For_Type (E) then
  1627:                return EW_Split (E);
  1628:             else
  1629:                return EW_Abstract (E);
  1630:             end if;
  1631:          end;
  1632:       end if;
```

## src/why/why-types.ads:30-60

```ada
    30:
    31: package Why.Types is
    32:
    33:    --  This package hierarchy provides basic types for Why syntax trees
    34:
    35:    type Why_Int is range -2 ** 31 .. +2 ** 31 - 1;
    36:
    37:    type Why_Node_Set is new Why_Int range 0 .. Why_Int'Last;
    38:
    39:    type Why_Node_Id is new Why_Node_Set range 0 .. Why_Node_Set'Last / 2;
    40:
    41:    type Why_Node_List is
    42:      new Why_Node_Set
    43:           range Why_Node_Set (Why_Node_Id'Last + 1) .. Why_Node_Set'Last;
    44:
    45:    Why_Empty : constant := 0;
    46:
    47:    function No (N : Why_Node_Id) return Boolean
    48:    is (N = Why_Empty);
    49:    --  Returns True if N is the empty node, False otherwise
    50:
    51:    function Present (N : Why_Node_Id) return Boolean
    52:    is (N /= Why_Empty);
    53:    --  Returns True if N is not the empty node, False otherwise
    54:
    55:    subtype Symbol_Set is Symbol_Sets.Set;
    56:
    57:    function Why_Node_Hash (X : Why_Node_Id) return Ada.Containers.Hash_Type
    58:    is (Ada.Containers.Hash_Type (X));
    59:
    60:    package Why_Node_Maps is new
```

## src/why/xgen/why-atree-to_json.adb-tmpl:100-160

```ada
   100:       end loop;
   101:       P (O, ']');
   102:    end Symbol_Set_To_Json;
   103:
   104:    -----------------------------------------
   105:    --  Why nodes types with multiplicity  --
   106:    -----------------------------------------
   107:
   108:    procedure Why_Node_Id_To_Json (O : Output_Id; Id : Why_Node_Id);
   109:    procedure Why_Node_OId_To_Json (O : Output_Id; Id : Why_Node_Id);
   110:    procedure Why_Node_OList_To_Json (O : Output_Id; Id : Why_Node_List);
   111:    procedure Why_Node_List_To_Json (O : Output_Id; Id : Why_Node_List);
   112:
   113:    procedure Why_Node_Id_To_Json (O : Output_Id; Id : Why_Node_Id) is
   114:    begin
   115:       Why_Node_To_Json (O, Node_Table (Id));
   116:    end Why_Node_Id_To_Json;
   117:
   118:    procedure Why_Node_OId_To_Json (O : Output_Id; Id : Why_Node_Id) is
   119:    begin
   120:       if Id = Why_Empty then
   121:          P (O, "null");
   122:       else
   123:          Why_Node_Id_To_Json (O, Id);
   124:       end if;
   125:    end Why_Node_OId_To_Json;
   126:
   127:    procedure Why_Node_OList_To_Json (O : Output_Id; Id : Why_Node_List) is
   128:    begin
   129:       if Is_Empty (Id) then
   130:          P (O, "null");
   131:       else
   132:          Why_Node_List_To_Json (O, Id);
   133:       end if;
   134:    end Why_Node_OList_To_Json;
   135:
   136:    procedure Why_Node_List_To_Json (O : Output_Id; Id : Why_Node_List) is
   137:    begin
   138:       Why_Node_Lists_List_To_Json (O, List_Table (Id).Content);
   139:    end Why_Node_List_To_Json;
   140:
   141:    procedure Why_Node_Lists_List_To_Json
   142:      (O : Output_Id; L : Why_Node_Lists.List)
   143:    is
   144:       First : Boolean := True;
   145:    begin
   146:       P (O, '[');
   147:       for El of L loop
   148:          if First then
   149:             First := False;
   150:          else
   151:             P (O, ',');
   152:          end if;
   153:          Why_Node_Id_To_Json (O, El);
   154:       end loop;
   155:       P (O, ']');
   156:    end Why_Node_Lists_List_To_Json;
   157:
   158:    pragma Warnings (Off, "procedure * is not referenced");
   159:    _@Declare_Ada_To_Json@_
   160:    pragma Warnings (On, "procedure * is not referenced");
```

## src/why/xgen/why-atree.ads-tmpl:95-130

```ada
    95:    --  These tables are used as storage pools for nodes and lists.
    96:    --  They could ultimately be implemented using the containers
    97:    --  that will be defined in the context of SPARK 2014; for now,
    98:    --  use Standard Ada 05 containers, in the hope that SPARK 2014
    99:    --  containers will be similar enough.
   100:
   101:    package Node_Tables is
   102:      new Ada.Containers.Indefinite_Vectors (Index_Type   => Why_Node_Id,
   103:                                             Element_Type => Why_Node);
   104:
   105:    Node_Table : Node_Tables.Vector;
   106:
   107:    type List_Info is record
   108:       Checked : Boolean;
   109:       Content : Why_Node_Lists.List;
   110:    end record;
   111:
   112:    package Node_List_Tables is
   113:      new Ada.Containers.Indefinite_Vectors (Index_Type   => Why_Node_List,
   114:                                             Element_Type => List_Info);
   115:
   116:    List_Table : Node_List_Tables.Vector;
   117:
   118:    function Get_Kind (Node_Id : Why_Node_Id) return Why_Node_Kind is
   119:      (Node_Table (Node_Id).Kind);
   120:
   121:    function Get_List (List_Id : Why_Node_List) return Why_Node_Lists.List is
   122:      (List_Table (List_Id).Content);
   123:
   124:    function Is_Checked (Node_Id : Why_Node_Id) return Boolean is
   125:      (Node_Table (Node_Id).Checked);
   126:
   127:    function Is_Empty (List_Id : Why_Node_List) return Boolean is
   128:      (List_Table (List_Id).Content.Is_Empty);
   129:
   130:    function Is_Checked (List_Id : Why_Node_List) return Boolean is
```

## src/why/xgen/xtree_builders.adb:200-255

```ada
   200:          elsif Field_Kind (FI) = Field_Domain
   201:            and then Get_Domain (Kind) /= EW_Expr
   202:          then
   203:             PL (O, New_Node & "." & FN & " := "
   204:                 & Mixed_Case_Name (Get_Domain (Kind)) & ";");
   205:
   206:          else
   207:             if Is_List (FI) then
   208:                if not Maybe_Null (FI) then
   209:                   PL (O, "pragma Assert ("
   210:                       & Param_Name (FI) & "'Length > 0);");
   211:                end if;
   212:
   213:                PL (O, New_Node & "." & FN & " := New_List;");
   214:                PL (O, "for J in " & Param_Name (FI) & "'Range loop");
   215:                Relative_Indent (O, 3);
   216:                PL (O, "pragma Assert");
   217:                PL (O, "  (" & Kind_Check (Node_Kind (FI), Id_One));
   218:                PL (O, "   (" & K (Param_Name (FI)  & " (J)") & "));");
   219:                PL (O, "pragma Assert");
   220:                PL (O, "  (" & Tree_Check (Node_Kind (FI), Id_One));
   221:                PL (O, "   (" & K (Param_Name (FI)  & " (J)") & "));");
   222:                PL (O, List_Op_Name (Op_Append));
   223:                PL (O, "  (" & New_Node & "." & FN & ",");
   224:                PL (O, "   " & K (Param_Name (FI) & " (J)") & ");");
   225:                Relative_Indent (O, -3);
   226:                PL (O, "end loop;");
   227:             else
   228:                PL (O, New_Node & "." & FN & " :=");
   229:                P (O, "  " & K (Param_Name (FI)));
   230:                PL (O, ";");
   231:             end if;
   232:          end if;
   233:
   234:       end Print_Record_Initialization;
   235:
   236:    --  Start of processing for Print_Builder_Implementation
   237:
   238:    begin
   239:       PL (O, "Node_Table.Append (" &
   240:              Empty_Nodes & "." & Mixed_Case_Name (Kind) & "_Node);");
   241:       PL (O, "declare");
   242:       Relative_Indent (O, 3);
   243:       Print_Builder_Local_Declarations (O, IK);
   244:       Relative_Indent (O, -3);
   245:       PL (O, "begin");
   246:       Relative_Indent (O, 3);
   247:       Common_Fields.Fields.Iterate (Print_Record_Initialization'Access);
   248:       Variant_Part.Fields.Iterate (Print_Record_Initialization'Access);
   249:       PL (O, "return " & K (New_Node_Id) & ";");
   250:       Relative_Indent (O, -3);
   251:       PL (O, "end;");
   252:    end Print_Builder_Implementation;
   253:
   254:    --------------------------------------
   255:    -- Print_Builder_Local_Declarations --
```

## src/why/xgen/xtree_sinfo.adb:30-145

```ada
    30:
    31: package body Xtree_Sinfo is
    32:
    33:    --  See the Makefile for overall behavior information
    34:    procedure Build_AST is
    35:    begin
    36:       Register_Kinds;
    37:
    38:       --  Domains
    39:
    40:       New_Domain ("W_Expr",
    41:                   "W_Expr",
    42:                   W_Universal_Quantif,
    43:                   W_Try_Block);
    44:       New_Domain ("W_Pred",
    45:                   "W_Expr",
    46:                   W_Universal_Quantif,
    47:                   W_Conditional);
    48:       New_Domain ("W_Term",
    49:                   "W_Prog",
    50:                   W_Label,
    51:                   W_Record_Aggregate);
    52:       New_Domain ("W_Prog",
    53:                   "W_Expr",
    54:                   W_Not,
    55:                   W_Try_Block);
    56:       Init_Domains;
    57:
    58:       --  Classes
    59:
    60:       New_Class ("W_Type_Definition",
    61:                  W_Transparent_Type_Definition,
    62:                  W_Range_Type_Definition);
    63:       New_Class ("W_Declaration",
    64:                  W_Function_Decl,
    65:                  W_Clone_Declaration);
    66:       New_Class ("W_Any_Node",
    67:                  W_Type,
    68:                  W_Module);
    69:
    70:       --  AST
    71:
    72:       New_Common_Field ("Ada_Node", "Node_Id", "Empty");
    73:       New_Domain_Field ("Domain", "EW_Domain", "EW_Prog");
    74:       New_Special_Field ("Checked", "Boolean", Checked_Default_Value);
    75:
    76:       ------------
    77:       -- W_Name --
    78:       ------------
    79:
    80:       New_Field (W_Name, "Symb", "Symbol");
    81:       New_Field (W_Name, "Namespace", "Symbol", "No_Symbol");
    82:       New_Field (W_Name, "Module", "W_Module", Id_Lone);
    83:       New_Field (W_Name, "Infix", "Boolean", "False");
    84:       Set_Domain (W_Name, EW_Term);
    85:
    86:       ------------
    87:       -- W_Type --
    88:       ------------
    89:
    90:       New_Field (W_Type,
    91:                  "Type_Kind", "EW_Type");
    92:       New_Field (W_Type,
    93:                  "Name", "W_Name", Id_One);
    94:       New_Field (W_Type,
    95:                  "Is_Mutable", "Boolean", "False");
    96:       New_Field (W_Type,
    97:                  "Relaxed_Init", "Boolean", "False");
    98:       Set_Domain (W_Type, EW_Term);
    99:
   100:       --------------------
   101:       -- W_Raise_Effect --
   102:       --------------------
   103:
   104:       New_Field (W_Raise_Effect,
   105:                  "Name", "W_Name", Id_One);
   106:       New_Field (W_Raise_Effect,
   107:                  "Arg_Id", "W_Identifier", Id_Lone);
   108:       New_Field (W_Raise_Effect,
   109:                  "Post", "W_Pred", Id_Lone);
   110:
   111:       ---------------
   112:       -- W_Effects --
   113:       ---------------
   114:
   115:       Set_Mutable (W_Effects);
   116:       New_Field (W_Effects,
   117:                  "Reads", "W_Identifier", Id_Set);
   118:       New_Field (W_Effects,
   119:                  "Writes", "W_Identifier", Id_Set);
   120:       New_Field (W_Effects,
   121:                  "Raises", "W_Raise_Effect", Id_Set);
   122:       Set_Domain (W_Effects, EW_Prog);
   123:
   124:       --------------
   125:       -- W_Binder --
   126:       --------------
   127:
   128:       New_Field (W_Binder,
   129:                  "Name", "W_Identifier", Id_Lone);
   130:       New_Field (W_Binder,
   131:                  "Arg_Type", "W_Type", Id_One);
   132:
   133:       -----------------------------------
   134:       -- W_Transparent_Type_Definition --
   135:       -----------------------------------
   136:
   137:       New_Field (W_Transparent_Type_Definition,
   138:                  "Type_Definition", "W_Type", Id_One);
   139:       Set_Domain (W_Effects, EW_Term);
   140:
   141:       ----------------------
   142:       -- W_Record_Binder --
   143:       ----------------------
   144:
   145:       New_Field (W_Record_Binder,
```

## src/why/xgen/xtree_sinfo.adb:170-245

```ada
   170:       ----------------
   171:       -- W_Triggers --
   172:       ----------------
   173:
   174:       New_Field (W_Triggers,
   175:                  "Triggers", "W_Trigger", Id_Some);
   176:       Set_Domain (W_Triggers, EW_Term);
   177:
   178:       ---------------
   179:       -- W_Trigger --
   180:       ---------------
   181:
   182:       New_Field (W_Trigger,
   183:                  "Terms", "W_Expr", Id_Some);
   184:       Set_Domain (W_Trigger, EW_Term);
   185:
   186:       -----------------
   187:       -- W_Axiom_Dep --
   188:       -----------------
   189:
   190:       New_Field (W_Axiom_Dep,
   191:                  "Name", "W_Identifier", Id_One);
   192:       New_Field (W_Axiom_Dep,
   193:                  "Kind", "EW_Axiom_Dep_Kind");
   194:       Set_Domain (W_Axiom_Dep, EW_Term);
   195:
   196:       ---------------
   197:       -- W_Handler --
   198:       ---------------
   199:
   200:       New_Field (W_Handler,
   201:                  "Name", "W_Name", Id_One);
   202:       New_Field (W_Handler,
   203:                  "Arg_Id", "W_Identifier", Id_Lone);
   204:       New_Field (W_Handler,
   205:                  "Def", "W_Prog", Id_One);
   206:       Set_Domain (W_Handler, EW_Prog);
   207:
   208:       -------------------------
   209:       -- W_Field_Association --
   210:       -------------------------
   211:
   212:       New_Field (W_Field_Association,
   213:                  "Field", "W_Identifier", Id_One);
   214:       New_Field (W_Field_Association,
   215:                  "Value", "W_Expr", Id_One);
   216:       Set_Domain (W_Handler, EW_Term);
   217:
   218:       -------------------------
   219:       -- W_Universal_Quantif --
   220:       -------------------------
   221:
   222:       New_Field (W_Universal_Quantif,
   223:                  "Binders", "W_Binder", Id_Some);
   224:       New_Field (W_Universal_Quantif,
   225:                  "Labels", "Symbol_Set");
   226:       New_Field (W_Universal_Quantif,
   227:                  "Triggers", "W_Triggers", Id_Lone);
   228:       New_Field (W_Universal_Quantif,
   229:                  "Pred", "W_Pred", Id_One);
   230:
   231:       ---------------------------
   232:       -- W_Existential_Quantif --
   233:       ---------------------------
   234:
   235:       New_Field (W_Existential_Quantif,
   236:                  "Binders", "W_Binder", Id_Some);
   237:       New_Field (W_Existential_Quantif,
   238:                  "Labels", "Symbol_Set");
   239:       New_Field (W_Existential_Quantif,
   240:                  "Pred", "W_Pred", Id_One);
   241:
   242:       ---------------
   243:       -- W_Epsilon --
   244:       ---------------
   245:
```

## src/why/xgen/xtree_sinfo.adb:254-368

```ada
   254:       -- W_Not --
   255:       -----------
   256:
   257:       New_Field (W_Not,
   258:                  "Right", "W_Expr", Id_One);
   259:
   260:       ------------------
   261:       -- W_Connection --
   262:       ------------------
   263:
   264:       New_Field (W_Connection,
   265:                  "Left", "W_Expr", Id_One);
   266:       New_Field (W_Connection,
   267:                  "Op", "EW_Connector");
   268:       New_Field (W_Connection,
   269:                  "Right", "W_Expr", Id_One);
   270:       New_Field (W_Connection,
   271:                  "More_Right", "W_Expr", Id_Set);
   272:
   273:       -------------
   274:       -- W_Label --
   275:       -------------
   276:
   277:       New_Field (W_Label,
   278:                  "Labels", "Symbol_Set");
   279:       New_Field (W_Label,
   280:                  "Def", "W_Expr", Id_One);
   281:       New_Field (W_Label,
   282:                  "Typ", "W_Type", Id_Lone);
   283:
   284:       -----------------
   285:       -- W_Loc_Label --
   286:       -----------------
   287:
   288:       New_Field (W_Loc_Label, "Sloc", "Source_Ptr");
   289:       New_Field (W_Loc_Label, "Def", "W_Expr", Id_One);
   290:       New_Field (W_Loc_Label, "Marker", "Symbol", "No_Symbol");
   291:
   292:       --------------
   293:       -- W_Module --
   294:       --------------
   295:
   296:       New_Field (W_Module, "File", "Symbol");
   297:       New_Field (W_Module, "Name", "Symbol");
   298:       Set_Domain (W_Module, EW_Term);
   299:
   300:       ------------------
   301:       -- W_Identifier --
   302:       ------------------
   303:
   304:       New_Field (W_Identifier, "Name", "W_Name", Id_One);
   305:       New_Field (W_Identifier, "Typ", "W_Type", Id_Lone);
   306:       New_Field (W_Identifier,
   307:                  "Labels", "String_Sets.Set", "String_Sets.Empty_Set");
   308:
   309:       --------------
   310:       -- W_Tagged --
   311:       --------------
   312:
   313:       New_Field (W_Tagged, "Tag", "Symbol");
   314:       New_Field (W_Tagged, "Def", "W_Expr", Id_One);
   315:       New_Field (W_Tagged, "Typ", "W_Type", Id_Lone);
   316:
   317:       ------------
   318:       -- W_Call --
   319:       ------------
   320:
   321:       New_Field (W_Call,
   322:                  "Name", "W_Identifier", Id_One);
   323:       New_Field (W_Call, "Args", "W_Expr", Id_Set);
   324:       New_Field (W_Call, "Typ", "W_Type", Id_Lone);
   325:
   326:       ---------------
   327:       -- W_Literal --
   328:       ---------------
   329:
   330:       New_Field (W_Literal, "Value", "EW_Literal");
   331:       New_Field (W_Literal, "Typ", "W_Type", Id_Lone);
   332:
   333:       ---------------
   334:       -- W_Binding --
   335:       ---------------
   336:
   337:       New_Field (W_Binding,
   338:                  "Name", "W_Identifier", Id_One);
   339:       New_Field (W_Binding,
   340:                  "Def", "W_Expr", Id_One);
   341:       New_Field (W_Binding,
   342:                  "Context", "W_Expr", Id_One);
   343:       New_Field (W_Binding, "Typ", "W_Type", Id_Lone);
   344:
   345:       -------------
   346:       -- W_Elsif --
   347:       -------------
   348:
   349:       New_Field (W_Elsif,
   350:                  "Condition", "W_Expr", Id_One);
   351:       New_Field (W_Elsif,
   352:                  "Then_Part", "W_Expr", Id_One);
   353:       New_Field (W_Elsif,
   354:                  "Typ", "W_Type", Id_Lone);
   355:
   356:       -------------------
   357:       -- W_Conditional --
   358:       -------------------
   359:
   360:       New_Field (W_Conditional,
   361:                  "Condition", "W_Expr", Id_One);
   362:       New_Field (W_Conditional,
   363:                  "Then_Part", "W_Expr", Id_One);
   364:       New_Field (W_Conditional,
   365:                  "Elsif_Parts", "W_Expr", Id_Set);
   366:       New_Field (W_Conditional,
   367:                  "Else_Part", "W_Expr", Id_Lone);
   368:       New_Field (W_Conditional, "Typ", "W_Type", Id_Lone);
```

## src/why/xgen/xtree_sinfo.adb:371-440

```ada
   371:       -- W_Integer_Constant --
   372:       ------------------------
   373:
   374:       New_Field (W_Integer_Constant, "Value", "Uint");
   375:
   376:       ----------------------
   377:       -- W_Range_Constant --
   378:       ----------------------
   379:
   380:       New_Field (W_Range_Constant, "Value", "Uint");
   381:       New_Field (W_Range_Constant, "Typ", "W_Type", Id_One);
   382:
   383:       ------------------------
   384:       -- W_Modular_Constant --
   385:       ------------------------
   386:
   387:       New_Field (W_Modular_Constant, "Value", "Uint");
   388:       New_Field (W_Modular_Constant, "Typ", "W_Type", Id_One);
   389:
   390:       ----------------------
   391:       -- W_Fixed_Constant --
   392:       ----------------------
   393:
   394:       New_Field (W_Fixed_Constant, "Value", "Uint");
   395:       New_Field (W_Fixed_Constant, "Typ", "W_Type", Id_One);
   396:
   397:       ---------------------
   398:       -- W_Real_Constant --
   399:       ---------------------
   400:
   401:       New_Field (W_Real_Constant, "Value", "Ureal");
   402:
   403:       ----------------------
   404:       -- W_Float_Constant --
   405:       ----------------------
   406:
   407:       New_Field (W_Float_Constant, "Value", "Ureal");
   408:       New_Field (W_Float_Constant, "Typ", "W_Type", Id_One);
   409:
   410:       ---------------
   411:       -- W_Comment --
   412:       ---------------
   413:
   414:       New_Field (W_Comment,
   415:                  "Comment", "Symbol");
   416:
   417:       -------------
   418:       -- W_Deref --
   419:       -------------
   420:
   421:       New_Field (W_Deref,
   422:                  "Right", "W_Identifier", Id_One);
   423:       New_Field (W_Deref,
   424:                  "Typ", "W_Type", Id_One);
   425:
   426:       ---------------------
   427:       -- W_Record_Access --
   428:       ---------------------
   429:
   430:       New_Field (W_Record_Access,
   431:                  "Name", "W_Expr", Id_One);
   432:       New_Field (W_Record_Access,
   433:                  "Field", "W_Identifier", Id_One);
   434:       New_Field (W_Record_Access,
   435:                  "Typ", "W_Type", Id_Lone);
   436:
   437:       ---------------------
   438:       -- W_Record_Update --
   439:       ---------------------
   440:
```

## src/why/xgen/xtree_sinfo.adb:470-486

```ada
   470:                  "Labels", "Symbol_Set");
   471:
   472:       ------------------
   473:       -- W_Assignment --
   474:       ------------------
   475:
   476:       New_Field (W_Assignment,
   477:                  "Name", "W_Identifier", Id_One);
   478:       New_Field (W_Assignment,
   479:                  "Value", "W_Prog", Id_One);
   480:       New_Field (W_Assignment,
   481:                  "Typ", "W_Type", Id_One);
   482:       New_Field (W_Assignment,
   483:                  "Labels", "Symbol_Set");
   484:
   485:       -------------------
   486:       -- W_Binding_Ref --
```

## src/why/xgen/xtree_sinfo.adb:528-558

```ada
   528:       -- W_Statement_Sequence --
   529:       --------------------------
   530:
   531:       Set_Mutable (W_Statement_Sequence);
   532:       New_Field (W_Statement_Sequence,
   533:                  "Statements", "W_Prog", Id_Some);
   534:
   535:       ---------------------
   536:       -- W_Abstract_Expr --
   537:       ---------------------
   538:
   539:       Set_Domain (W_Abstract_Expr, EW_Prog);
   540:       New_Field (W_Abstract_Expr,
   541:                 "Expr", "W_Prog", Id_One);
   542:       New_Field (W_Abstract_Expr,
   543:                  "Post", "W_Pred", Id_One);
   544:       New_Field (W_Abstract_Expr,
   545:                  "Typ", "W_Type", Id_Lone);
   546:
   547:       --------------
   548:       -- W_Assert --
   549:       --------------
   550:
   551:       New_Field (W_Assert,
   552:                  "Pred", "W_Pred", Id_One);
   553:       New_Field (W_Assert,
   554:                  "Assert_Kind", "EW_Assert_Kind");
   555:
   556:       -------------
   557:       -- W_Raise --
   558:       -------------
```

## src/why/xgen/xtree_sinfo.adb:580-635

```ada
   580:       ---------------------
   581:
   582:       New_Field (W_Function_Decl,
   583:                  "Name", "W_Identifier", Id_One);
   584:       New_Field (W_Function_Decl,
   585:                  "Binders", "W_Binder", Id_Set);
   586:       New_Field (W_Function_Decl,
   587:                  "Effects", "W_Effects", Id_Lone);
   588:       New_Field (W_Function_Decl,
   589:                  "Pre", "W_Pred", Id_Lone);
   590:       New_Field (W_Function_Decl,
   591:                  "Post", "W_Pred", Id_Lone);
   592:       New_Field (W_Function_Decl,
   593:                  "Return_Type", "W_Type", Id_Lone);
   594:       New_Field (W_Function_Decl,
   595:                  "Def", "W_Expr", Id_Lone);
   596:       New_Field (W_Function_Decl,
   597:                  "Labels", "Symbol_Set");
   598:       New_Field (W_Function_Decl,
   599:                  "Location", "Source_Ptr");
   600:
   601:       -------------
   602:       -- W_Axiom --
   603:       -------------
   604:
   605:       New_Field (W_Axiom,
   606:                  "Name", "Symbol");
   607:       New_Field (W_Axiom,
   608:                  "Def", "W_Pred", Id_One);
   609:       New_Field (W_Axiom,
   610:                  "Dep", "W_Axiom_Dep", Id_Lone);
   611:       Set_Domain (W_Axiom, EW_Term);
   612:
   613:       ------------
   614:       -- W_Goal --
   615:       ------------
   616:
   617:       New_Field (W_Goal,
   618:                  "Name", "Symbol");
   619:       New_Field (W_Goal,
   620:                  "Def", "W_Pred", Id_One);
   621:       Set_Domain (W_Goal, EW_Term);
   622:
   623:       -----------------
   624:       -- W_Type_Decl --
   625:       -----------------
   626:
   627:       New_Field (W_Type_Decl,
   628:                  "Args", "W_Identifier", Id_Set);
   629:       New_Field (W_Type_Decl,
   630:                  "Name", "W_Name", Id_One);
   631:       New_Field (W_Type_Decl,
   632:                  "Labels", "Symbol_Set");
   633:       New_Field (W_Type_Decl,
   634:                  "Definition", "W_Type_Definition", Id_Lone);
   635:       Set_Domain (W_Type_Decl, EW_Term);
```

## src/why/xgen/xtree_sinfo.adb:682-738

```ada
   682:       -- W_Clone_Declaration --
   683:       -------------------------
   684:
   685:       New_Field (W_Clone_Declaration,
   686:                  "Origin", "W_Module", Id_One);
   687:       New_Field (W_Clone_Declaration,
   688:                  "As_Name", "Symbol");
   689:       New_Field (W_Clone_Declaration,
   690:                  "Clone_Kind", "EW_Clone_Type");
   691:       New_Field (W_Clone_Declaration,
   692:                  "Substitutions", "W_Clone_Substitution", Id_Set);
   693:       New_Field (W_Clone_Declaration,
   694:                  "Theory_Kind", "EW_Theory_Type");
   695:       Set_Domain (W_Clone_Declaration, EW_Term);
   696:
   697:       --------------------------
   698:       -- W_Clone_Substitution --
   699:       --------------------------
   700:
   701:       New_Field (W_Clone_Substitution, "Kind", "EW_Subst_Type");
   702:       New_Field (W_Clone_Substitution,
   703:                  "Orig_Name", "W_Name", Id_One);
   704:       New_Field (W_Clone_Substitution,
   705:                  "Image", "W_Name", Id_One);
   706:       Set_Domain (W_Clone_Substitution, EW_Term);
   707:
   708:       ---------------------------
   709:       -- W_Include_Declaration --
   710:       ---------------------------
   711:
   712:       New_Field (W_Include_Declaration,
   713:                  "Module", "W_Module", Id_One);
   714:       New_Field (W_Include_Declaration,
   715:                  "Kind", "EW_Theory_Type");
   716:       New_Field (W_Include_Declaration,
   717:                  "Use_Kind", "EW_Clone_Type");
   718:       Set_Domain (W_Include_Declaration, EW_Term);
   719:
   720:       --------------------------
   721:       -- W_Theory_Declaration --
   722:       --------------------------
   723:
   724:       Set_Mutable (W_Theory_Declaration);
   725:       New_Field (W_Theory_Declaration,
   726:                  "Declarations", "W_Declaration", Id_Set);
   727:       New_Field (W_Theory_Declaration,
   728:                  "Name", "Symbol");
   729:       New_Field (W_Theory_Declaration,
   730:                  "Kind", "EW_Theory_Type");
   731:       New_Field (W_Theory_Declaration,
   732:                  "Includes", "W_Include_Declaration", Id_Set);
   733:       New_Field (W_Theory_Declaration,
   734:                  "Comment", "Symbol");
   735:       Set_Domain (W_Theory_Declaration, EW_Prog);
   736:
   737:    end Build_AST;
   738:
```

## src/why/xgen/xtree_sinfo.adb:488-511

```ada
   488:
   489:       New_Field (W_Binding_Ref,
   490:                  "Name", "W_Identifier", Id_One);
   491:       New_Field (W_Binding_Ref,
   492:                  "Def", "W_Prog", Id_One);
   493:       New_Field (W_Binding_Ref,
   494:                  "Context", "W_Prog", Id_One);
   495:       New_Field (W_Binding_Ref,
   496:                  "Typ", "W_Type", Id_One);
   497:
   498:       ------------
   499:       -- W_Loop --
   500:       ------------
   501:
   502:       New_Field (W_Loop,
   503:                  "Code_Before", "W_Prog", Id_One);
   504:       New_Field (W_Loop,
   505:                  "Invariants", "W_Pred", Id_Set);
   506:       New_Field (W_Loop,
   507:                  "Variants", "W_Variants", Id_Set);
   508:       New_Field (W_Loop,
   509:                  "Code_After", "W_Prog", Id_One);
   510:
   511:       ---------------
```

## src/why/xgen/xtree_sinfo.adb:558-576

```ada
   558:       -------------
   559:
   560:       New_Field (W_Raise,
   561:                  "Name", "W_Name", Id_One);
   562:       New_Field (W_Raise,
   563:                  "Arg", "W_Expr", Id_Lone);
   564:       New_Field (W_Raise,
   565:                  "Typ", "W_Type", Id_Lone);
   566:
   567:       -----------------
   568:       -- W_Try_Block --
   569:       -----------------
   570:
   571:       New_Field (W_Try_Block,
   572:                  "Prog", "W_Prog", Id_One);
   573:       New_Field (W_Try_Block,
   574:                  "Handler", "W_Handler", Id_Some);
   575:       New_Field (W_Try_Block,
   576:                  "Typ", "W_Type", Id_Lone);
```

## src/why/xgen/xtree_why_ast.adb:160-245

```ada
   160:       Print_Ada_Enum_To_Json (O, "EW_Assert_Kind");
   161:       Print_Ada_Enum_To_Json (O, "EW_Axiom_Dep_Kind");
   162:
   163:    end Print_Ada_Why_Sinfo_Types_To_Json;
   164:
   165:    --------------------------------
   166:    -- Print_Ada_Why_Node_To_Json --
   167:    --------------------------------
   168:
   169:    procedure Print_Ada_Why_Node_To_Json (O : in out Output_Record) is
   170:    begin
   171:       PL (O, "Why_Node_Counter : Natural := 0;");
   172:       NL (O);
   173:       PL (O, "procedure Why_Node_To_Json (O : Output_Id; Node : Why_Node) is");
   174:       PL (O, "begin");
   175:       begin
   176:          Relative_Indent (O, 3);
   177:          PL (O, "P (O, '[');");
   178:          PL (O, "Why_Node_Counter := Why_Node_Counter + 1;");
   179:          PL (O, "P (O, '""' & Why_Node_Kind'Image (Node.Kind) & '""');");
   180:          PL (O, "P (O, ',');");
   181:          PL (O, "P (O, Integer'Image (Why_Node_Counter));");
   182:          for FI of Common_Fields.Fields loop
   183:             declare
   184:                FN : constant String := Field_Name (FI);
   185:             begin
   186:                if FN not in "Checked" | "Ada_Node" then
   187:                   declare
   188:                      Typ_Name : constant String :=
   189:                        Clean_Identifier (Type_Name (FI, Opaque));
   190:                   begin
   191:                      PL (O, "P (O, ',');");
   192:                      PL (O,
   193:                          Typ_Name & "_To_Json (O, Node." & FN & ");");
   194:                   end;
   195:                end if;
   196:             end;
   197:          end loop;
   198:          PL (O, "case Node.Kind is");
   199:          begin
   200:             Relative_Indent (O, 3);
   201:             for Kind in Why_Tree_Info'Range loop
   202:                PL (O, "when " & Mixed_Case_Name (Kind) & " =>");
   203:                Relative_Indent (O, 3);
   204:                if Why_Tree_Info (Kind).Fields.Is_Empty then
   205:                   PL (O, "null;");
   206:                else
   207:                   for FI of Why_Tree_Info (Kind).Fields loop
   208:                      declare
   209:                         Field_Type : constant String :=
   210:                           Clean_Identifier (Type_Name (FI, Opaque));
   211:                      begin
   212:                         PL (O, "P (O, ',');");
   213:                         PL (O, Field_Type & "_To_Json");
   214:                         Relative_Indent (O, 2);
   215:                         PL (O, "(O,");
   216:                         Relative_Indent (O, 1);
   217:                         PL (O, "Node." & Field_Name (FI) & ");");
   218:                         Relative_Indent (O, -3);
   219:                      end;
   220:                   end loop;
   221:                end if;
   222:                Relative_Indent (O, -3);
   223:             end loop;
   224:             Relative_Indent (O, -3);
   225:          end;
   226:          PL (O, "end case;");
   227:          PL (O, "P (O, ']');");
   228:          Relative_Indent (O, -3);
   229:       end;
   230:       PL (O, "end Why_Node_To_Json;");
   231:    end Print_Ada_Why_Node_To_Json;
   232:
   233:    ----------------------------------
   234:    -- Print_Ada_Opaque_Ids_To_Json --
   235:    ----------------------------------
   236:
   237:    procedure Print_Ada_Opaque_Ids_To_Json (O : in out Output_Record) is
   238:       use String_Lists;
   239:       use Class_Lists;
   240:
   241:       procedure Process_One_Node_Kind (Position : String_Lists.Cursor);
   242:       procedure Process_One_Class_Kind (Position : Class_Lists.Cursor);
   243:       procedure Print_Subtypes (Prefix : String);
   244:
   245:       ----------------------------
```
