# Incoming source witnesses

Complete SPARK files remain in the hash-pinned archive; GCC files in gcc-sources.tar.gz are verified against the earlier complete-source manifest. These excerpts do not prove reachability.

## flow/flow_types.ads:97–184

```ada
97:    type Flow_Id_Kind is
98:      (Null_Value,
99:       --  No reference or any entity or node
100:
101:       Direct_Mapping,
102:       --  Direct reference to Entity or Node in the AST
103:
104:       Record_Field,
105:       --  Reference to list of record field(s) as well as
106:       --  whole variable entity in the AST.
107:
108:       Synthetic_Null_Export,
109:       --  The null export (to capture effects, such as
110:       --  timing, outside of SPARK).
111:
112:       Magic_String
113:       --  Entity not in AST, so referred to by a String
114:      );
115:
116:    type Flow_Id_Variant is
117:      (Normal_Use,
118:       --  Normal usage of the identifier
119:
120:       Initial_Value,
121:       Final_Value,
122:       --  For the 'initial and 'final vertices
123:
124:       Initial_Grouping,
125:       Final_Grouping,
126:       --  For the tree of record components
127:
128:       In_View,
129:       Out_View
130:       --  For the procedure call parameter vertices
131:      );
132:    pragma Ordered (Flow_Id_Variant);
133:
134:    type Variable_Facet_T is
135:      (Normal_Part,
136:       Private_Part,    --  for private types
137:       Extension_Part,  --  for tagged types
138:       The_Tag,         --  for tagged types
139:       The_Bounds       --  for unconstrained objects
140:      );
141:    --  Not all things can be represented by just X. For example a discriminated
142:    --  private type might need X'Private_Part and X.D. Most Flow_Id objects
143:    --  will describe the Normal_Part.
144:    --
145:    --  Flo's note on naming: I did want to use the name "aspect", but this is
146:    --  perhaps asking for confusion; hence I went for "facet".
147:
148:    subtype Initial_Or_Final_Variant is
149:      Flow_Id_Variant range Initial_Value .. Final_Value;
150:
151:    subtype Parameter_Variant is Flow_Id_Variant range In_View .. Out_View;
152:
153:    type Corresponding_Grouping_Map is
154:      array (Initial_Or_Final_Variant) of Flow_Id_Variant;
155:
156:    Corresponding_Grouping : constant Corresponding_Grouping_Map :=
157:      (Initial_Value => Initial_Grouping, Final_Value => Final_Grouping);
158:
159:    type Flow_Id (Kind : Flow_Id_Kind := Null_Value) is record
160:       Variant : Flow_Id_Variant;
161:       --  In theory this doesn't have to be part of a Null_Value id, but there
162:       --  are many checks for Foo.Variant throughout flow analysis and it will
163:       --  be quite tedious to prefix each of them with Present (Foo).
164:
165:       case Kind is
166:          when Direct_Mapping | Record_Field =>
167:             Node  : Node_Or_Entity_Id;
168:             Facet : Variable_Facet_T; --  only used for records and types
169:
170:             case Kind is
171:                when Record_Field =>
172:                   Component : Entity_Vectors.Vector;
173:
174:                when others =>
175:                   null;
176:             end case;
177:
178:          when Magic_String =>
179:             Name : Entity_Name;
180:
181:          when others =>
182:             null;
183:       end case;
184:    end record;
```

## flow/flow_types.ads:859–859

```ada
859:    type Reference_Kind is (Inputs, Proof_Ins, Null_Deps);
```

## flow/flow_utility.adb:1020–1106

```ada
1020:       if F.Kind in Direct_Mapping | Record_Field and then F.Facet = Normal_Part
1021:       then
1022:          pragma Annotate (Xcov, Exempt_On, "Debugging code");
1023:          if Debug_Trace_Flatten then
1024:             Write_Str ("Get components: ");
1025:             Print_Flow_Id (F);
1026:          end if;
1027:          pragma Annotate (Xcov, Exempt_Off);
1028:
1029:          --  Special-case abstract state, which lack's a type to branch on
1030:
1031:          if Ekind (Get_Direct_Mapping_Id (F)) = E_Abstract_State then
1032:             return Flow_Id_Sets.To_Set (F);
1033:          else
1034:             declare
1035:                T : Entity_Id := Get_Type (F, Scope);
1036:                --  Type of F
1037:
1038:                Classwide : constant Boolean := Is_Class_Wide_Type (T);
1039:                --  True iff F has a classwide type
1040:
1041:                Results : Flow_Id_Sets.Set;
1042:
1043:                Contains_Non_Visible : Boolean := False;
1044:
1045:                subtype Private_Nonrecord_Kind is Private_Kind
1046:                with
1047:                  Static_Predicate =>
1048:                    Private_Nonrecord_Kind
1049:                    not in E_Record_Type_With_Private
1050:                         | E_Record_Subtype_With_Private;
1051:                --  Non-record private types
1052:
1053:                procedure Debug (Msg : String);
1054:                --  Output debug message
1055:
1056:                -----------
1057:                -- Debug --
1058:                -----------
1059:
1060:                pragma Annotate (Xcov, Exempt_On, "Debugging code");
1061:                procedure Debug (Msg : String) is
1062:                begin
1063:                   if Debug_Trace_Flatten then
1064:                      Write_Line (Msg);
1065:                   end if;
1066:                end Debug;
1067:                pragma Annotate (Xcov, Exempt_Off);
1068:
1069:             begin
1070:                pragma Annotate (Xcov, Exempt_On, "Debugging code");
1071:                if Debug_Trace_Flatten then
1072:                   Indent;
1073:                end if;
1074:                pragma Annotate (Xcov, Exempt_Off);
1075:
1076:                if Is_Class_Wide_Type (T) then
1077:                   T := Get_Specific_Type_From_Classwide (T, Scope);
1078:                end if;
1079:
1080:                pragma Assert (Is_Type (T));
1081:
1082:                pragma Annotate (Xcov, Exempt_On, "Debugging code");
1083:                if Debug_Trace_Flatten then
1084:                   Write_Str ("Branching on type: ");
1085:                   Sprint_Node_Inline (T);
1086:                   Write_Line (" (" & Ekind (T)'Img & ")");
1087:                end if;
1088:                pragma Annotate (Xcov, Exempt_Off);
1089:
1090:                --  If the type is not in SPARK we return the variable itself
1091:
1092:                if not Entity_In_SPARK (T) then
1093:                   return Flow_Id_Sets.To_Set (F);
1094:                end if;
1095:
1096:                case Type_Kind'(Ekind (T)) is
1097:                   when Private_Nonrecord_Kind
1098:                   =>
1099:                      Debug ("processing private type");
1100:
1101:                      pragma Assert (not Is_Tagged_Type (T));
1102:
1103:                      if Has_Discriminants (T) then
1104:                         for C of Unique_Components (T) loop
1105:                            if Is_Visible (C, Scope) then
1106:                               Results.Insert (Add_Component (F, C));
```

## flow/flow_utility.adb:1233–1301

```ada
1233:                   when Access_Kind | Array_Kind | Scalar_Kind
1234:                   =>
1235:                      Debug ("processing access or array or scalar type");
1236:
1237:                      Results := Flow_Id_Sets.To_Set (F);
1238:
1239:                      --  For top-level unconstrained array objects the
1240:                      --  flattened view also includes their bounds.
1241:
1242:                      if F.Kind = Direct_Mapping
1243:                        and then Is_Array_Type (T)
1244:                        and then not Is_Constrained (T)
1245:                      then
1246:                         Results.Insert ((F with delta Facet => The_Bounds));
1247:                      end if;
1248:
1249:                   when E_Exception_Type | E_Subprogram_Type | Incomplete_Kind
1250:                   =>
1251:                      raise Program_Error;
1252:
1253:                end case;
1254:
1255:                pragma Annotate (Xcov, Exempt_On, "Debugging code");
1256:                if Debug_Trace_Flatten then
1257:                   Outdent;
1258:                end if;
1259:                pragma Annotate (Xcov, Exempt_Off);
1260:
1261:                return Results;
1262:             end;
1263:          end if;
1264:       else
1265:          pragma Annotate (Xcov, Exempt_On, "Debugging code");
1266:          if Debug_Trace_Flatten then
1267:             Write_Str ("Get components: ");
1268:             Print_Flow_Id (F);
1269:          end if;
1270:          pragma Annotate (Xcov, Exempt_Off);
1271:
1272:          return Flow_Id_Sets.To_Set (F);
1273:       end if;
1274:    end Get_Components;
1275:
1276:    ----------------------
1277:    -- Flatten_Variable --
1278:    ----------------------
1279:
1280:    function Flatten_Variable
1281:      (F : Flow_Id; Scope : Flow_Scope) return Flow_Id_Sets.Set
1282:    is
1283:       Subcomponents : Flow_Id_Sets.Set;
1284:       Components    : constant Flow_Id_Sets.Set := Get_Components (F, Scope);
1285:
1286:    begin
1287:       --  F is a leaf of the tree representing its type iff its components
1288:       --  contain the F itself. Checking membership instead of set equality
1289:       --  is important, for example because components could also contain
1290:       --  an extension part if F was classwide and didn't have any component.
1291:
1292:       if Components.Contains (F) then
1293:          return Components;
1294:       else
1295:          for Component of Components loop
1296:             Subcomponents.Union (Flatten_Variable (Component, Scope));
1297:          end loop;
1298:
1299:          return Subcomponents;
1300:       end if;
1301:    end Flatten_Variable;
```

## flow/flow-control_flow_graph.adb:1242–1290

```ada
1242:    procedure Add_Dummy_Vertex
1243:      (N  : Node_Id;
1244:       FA : in out Flow_Analysis_Graphs;
1245:       CM : in out Connection_Maps.Map)
1246:    is
1247:       V : Flow_Graphs.Vertex_Id;
1248:    begin
1249:       Add_Vertex (FA, Direct_Mapping_Id (N), Null_Node_Attributes, V);
1250:       CM.Insert (Union_Id (N), Trivial_Connection (V));
1251:    end Add_Dummy_Vertex;
1252:
1253:    ----------------
1254:    -- Add_Vertex --
1255:    ----------------
1256:
1257:    procedure Add_Vertex
1258:      (FA : in out Flow_Analysis_Graphs; F : Flow_Id; A : V_Attributes)
1259:    is
1260:       V : Flow_Graphs.Vertex_Id;
1261:    begin
1262:       if F.Kind in Direct_Mapping | Record_Field then
1263:          fndi (FA.Spec_Entity, F.Node);
1264:       end if;
1265:       FA.CFG.Add_Vertex (F, V);
1266:       FA.Atr.Insert (V, A);
1267:    end Add_Vertex;
1268:
1269:    procedure Add_Vertex
1270:      (FA    : in out Flow_Analysis_Graphs;
1271:       F     : Flow_Id;
1272:       A     : V_Attributes;
1273:       V     : out Flow_Graphs.Vertex_Id;
1274:       Keyed : Boolean := False) is
1275:    begin
1276:       if F.Kind in Direct_Mapping | Record_Field then
1277:          fndi (FA.Spec_Entity, F.Node);
1278:       end if;
1279:       FA.CFG.Add_Vertex (F, V, Keyed => Keyed);
1280:       FA.Atr.Insert (V, A);
1281:    end Add_Vertex;
1282:
1283:    procedure Add_Vertex
1284:      (FA : in out Flow_Analysis_Graphs;
1285:       A  : V_Attributes;
1286:       V  : out Flow_Graphs.Vertex_Id) is
1287:    begin
1288:       FA.CFG.Add_Vertex (V);
1289:       FA.Atr.Insert (V, A);
1290:    end Add_Vertex;
```

## flow/flow-control_flow_graph.adb:1357–1395

```ada
1357:    procedure Join
1358:      (FA    : in out Flow_Analysis_Graphs;
1359:       CM    : in out Connection_Maps.Map;
1360:       Nodes : Union_Lists.List;
1361:       Block : out Graph_Connections) is
1362:    begin
1363:       if Nodes.Is_Empty then
1364:          declare
1365:             V : Flow_Graphs.Vertex_Id;
1366:          begin
1367:             --  We had a null sequence so we need to produce a null node
1368:             Add_Vertex (FA, Null_Node_Attributes, V);
1369:             Block := Trivial_Connection (V);
1370:          end;
1371:       else
1372:          Block.Standard_Entry := CM (Nodes.First_Element).Standard_Entry;
1373:
1374:          declare
1375:             Prev : Union_Lists.Cursor := Nodes.First;
1376:             Curr : Union_Lists.Cursor := Union_Lists.Next (Prev);
1377:          begin
1378:             while Union_Lists.Has_Element (Curr) loop
1379:                --  Connect this statement to the previous one
1380:                Linkup
1381:                  (FA,
1382:                   CM (Nodes (Prev)).Standard_Exits,
1383:                   CM (Nodes (Curr)).Standard_Entry);
1384:
1385:                CM.Delete (Nodes (Prev));
1386:
1387:                Prev := Curr;
1388:                Curr := Union_Lists.Next (Curr);
1389:             end loop;
1390:          end;
1391:
1392:          Block.Standard_Exits := CM (Nodes.Last_Element).Standard_Exits;
1393:
1394:          CM.Delete (Nodes.Last_Element);
1395:       end if;
```

## flow/flow-control_flow_graph.adb:1506–1706

```ada
1506:    procedure Create_Initial_And_Final_Vertices
1507:      (E : Entity_Id; FA : in out Flow_Analysis_Graphs)
1508:    is
1509:       Current_Entity : Entity_To_Vertex_Maps.Cursor;
1510:       Inserted       : Boolean;
1511:
1512:       M : constant Param_Mode :=
1513:         (case Ekind (E) is
1514:
1515:            --  Formal parameters of mode IN with a visibly non-constant access
1516:            --  type can be assigned in subprograms with side-effects, so we
1517:            --  handle them very much like IN OUTs.
1518:
1519:            when E_In_Parameter
1520:            =>
1521:              (if Is_Access_Variable (Etype (E))
1522:                 and then
1523:                   (Ekind (FA.Spec_Entity) in E_Procedure | E_Entry
1524:                    or else Is_Function_With_Side_Effects (FA.Spec_Entity))
1525:               then Mode_In_Out
1526:               else Mode_In),
1527:
1528:            when E_In_Out_Parameter | E_Task_Type
1529:            => Mode_In_Out,
1530:
1531:            when E_Function | E_Out_Parameter
1532:            => Mode_Out,
1533:
1534:            when E_Protected_Type
1535:            =>
1536:              (if Ekind (FA.Spec_Entity) = E_Function
1537:               then Mode_In
1538:               else Mode_In_Out),
1539:
1540:            when E_Abstract_State | E_Constant | E_Loop_Parameter | E_Variable
1541:            => Mode_Invalid,
1542:
1543:            when others
1544:            => raise Program_Error);
1545:
1546:       Scop : constant Flow_Scope :=
1547:         (if FA.Generating_Globals or else Is_In_Analyzed_Files (E)
1548:          then Null_Flow_Scope
1549:          else FA.B_Scope);
1550:       --  In phase 2, when this routine is called on constituents declared in
1551:       --  private child packages, we need the scope of the parent package for
1552:       --  deciding whether the constituent is initialized at elaboration. In
1553:       --  phase 1 the initialization status of such constituents doesn't
1554:       --  matter.
1555:
1556:       procedure Process (F : Flow_Id)
1557:       with
1558:         Pre =>
1559:           F.Kind in Direct_Mapping | Record_Field
1560:           and then F.Variant = Normal_Use;
1561:
1562:       -------------
1563:       -- Process --
1564:       -------------
1565:
1566:       procedure Process (F : Flow_Id) is
1567:          Initial_V, Final_V : Flow_Graphs.Vertex_Id;
1568:
1569:          F_Initial : constant Flow_Id := Change_Variant (F, Initial_Value);
1570:          F_Final   : constant Flow_Id := Change_Variant (F, Final_Value);
1571:
1572:          Initial_Atr : constant V_Attributes :=
1573:            Make_Variable_Attributes
1574:              (F_Ent => F_Initial, Mode => M, E_Loc => E, S => Scop);
1575:
1576:          Final_Atr : constant V_Attributes :=
1577:            Make_Variable_Attributes (F_Ent => F_Final, Mode => M, E_Loc => E);
1578:
1579:       begin
1580:
1581:          --  Setup the n'initial vertex. Note that initialization for
1582:          --  variables is detected (and set) when building the flow graph
1583:          --  for declarative parts.
1584:          Add_Vertex (FA, F_Initial, Initial_Atr, Initial_V, Keyed => True);
1585:          Linkup (FA, Initial_V, FA.Start_Vertex);
1586:          FA.Initial_And_Final_Vertices (Current_Entity).Insert (Initial_V);
1587:
1588:          Create_Record_Tree (F_Initial, Initial_Atr, FA, Current_Entity);
1589:
1590:          --  Setup the n'final vertex
1591:          Add_Vertex (FA, F_Final, Final_Atr, Final_V, Keyed => True);
1592:          Linkup (FA, FA.End_Vertex, Final_V);
1593:          FA.Initial_And_Final_Vertices (Current_Entity).Insert (Final_V);
1594:
1595:          Create_Record_Tree (F_Final, Final_Atr, FA, Current_Entity);
1596:
1597:          FA.All_Vars.Insert (F);
1598:       end Process;
1599:
1600:       --  Start of processing for Create_Initial_And_Final_Vertices
1601:
1602:    begin
1603:       FA.Initial_And_Final_Vertices.Insert (E, Current_Entity, Inserted);
1604:
1605:       --  If we are creating the vertices, then create a path counter as well
1606:
1607:       if Inserted then
1608:          FA.Declaration_Paths.Insert (Key => E, New_Item => 1);
1609:
1610:       --  Otherwise just increment the existing path counter
1611:
1612:       else
1613:          declare
1614:             Declarations : Natural renames FA.Declaration_Paths (E);
1615:          begin
1616:             Declarations := Declarations + 1;
1617:          end;
1618:
1619:          return;
1620:       end if;
1621:
1622:       for Comp of Flatten_Variable (E, FA.B_Scope) loop
1623:          Process (Comp);
1624:       end loop;
1625:
1626:       if Extensions_Visible (E, FA.B_Scope) then
1627:          Process (Direct_Mapping_Id (E, Facet => Extension_Part));
1628:       end if;
1629:
1630:       if Ekind (E) in E_In_Out_Parameter | E_Out_Parameter
1631:         and then Has_Discriminants (Get_Type (E, FA.B_Scope))
1632:       then
1633:          Process (Direct_Mapping_Id (E, Facet => The_Bounds));
1634:       end if;
1635:    end Create_Initial_And_Final_Vertices;
1636:
1637:    procedure Create_Initial_And_Final_Vertices
1638:      (F : Flow_Id; Mode : Param_Mode; FA : in out Flow_Analysis_Graphs)
1639:    is
1640:       procedure Process (F : Flow_Id)
1641:       with
1642:         Pre =>
1643:           F.Kind in Direct_Mapping | Record_Field | Magic_String
1644:           and then F.Variant = Normal_Use;
1645:
1646:       -------------
1647:       -- Process --
1648:       -------------
1649:
1650:       procedure Process (F : Flow_Id) is
1651:          F_Initial : constant Flow_Id := Change_Variant (F, Initial_Value);
1652:          F_Final   : constant Flow_Id := Change_Variant (F, Final_Value);
1653:
1654:          Initial_Atr : constant V_Attributes :=
1655:            Make_Global_Variable_Attributes (F => F_Initial, Mode => Mode);
1656:
1657:          Final_Atr : constant V_Attributes :=
1658:            Make_Global_Variable_Attributes (F => F_Final, Mode => Mode);
1659:
1660:          Initial_V, Final_V : Flow_Graphs.Vertex_Id;
1661:       begin
1662:          --  Setup the F'initial vertex. Initialization is deduced from the
1663:          --  mode.
1664:          Add_Vertex (FA, F_Initial, Initial_Atr, Initial_V, Keyed => True);
1665:          Linkup (FA, Initial_V, FA.Start_Vertex);
1666:
1667:          Create_Record_Tree
1668:            (F_Initial,
1669:             Initial_Atr,
1670:             FA,
1671:             Current_Entity => Entity_To_Vertex_Maps.No_Element);
1672:
1673:          --  Setup the F'final vertex
1674:          Add_Vertex (FA, F_Final, Final_Atr, Final_V, Keyed => True);
1675:          Linkup (FA, FA.End_Vertex, Final_V);
1676:
1677:          Create_Record_Tree
1678:            (F_Final,
1679:             Final_Atr,
1680:             FA,
1681:             Current_Entity => Entity_To_Vertex_Maps.No_Element);
1682:
1683:          FA.All_Vars.Insert (F);
1684:       end Process;
1685:
1686:       --  Start of processing for Create_Initial_And_Final_Vertices
1687:
1688:    begin
1689:       for Comp of Flatten_Variable (F, FA.B_Scope) loop
1690:          Process (Comp);
1691:       end loop;
1692:
1693:       if Extensions_Visible (F, FA.B_Scope) then
1694:          Process ((F with delta Facet => Extension_Part));
1695:       end if;
1696:
1697:       if F.Kind = Direct_Mapping
1698:         and then
1699:           Ekind (Get_Direct_Mapping_Id (F))
1700:           in E_In_Out_Parameter | E_Out_Parameter
1701:         and then
1702:           Has_Discriminants (Get_Type (Get_Direct_Mapping_Id (F), FA.B_Scope))
1703:       then
1704:          Process ((F with delta Facet => The_Bounds));
1705:       end if;
1706:    end Create_Initial_And_Final_Vertices;
```

## flow/flow-control_flow_graph.adb:2009–2039

```ada
2009:          Ctx.Folded_Function_Checks.Append (Expression (N));
2010:          Ctx.Folded_Function_Checks.Append (Name (N));
2011:
2012:          declare
2013:             Var_Im_Use : Flow_Id_Sets.Set;
2014:          begin
2015:             if Partial then
2016:                Var_Im_Use := Vars_Defined;
2017:             else
2018:                if Partial_Ext then
2019:                   Var_Im_Use.Insert
2020:                     ((LHS_Root with delta Facet => Extension_Part));
2021:                end if;
2022:
2023:                if Partial_Priv then
2024:                   Var_Im_Use.Insert
2025:                     ((LHS_Root with delta Facet => Private_Part));
2026:                end if;
2027:             end if;
2028:
2029:             --  Produce the vertex
2030:             Add_Vertex
2031:               (FA,
2032:                Direct_Mapping_Id (N),
2033:                Make_Basic_Attributes
2034:                  (Var_Def    => Vars_Defined,
2035:                   Var_Ex_Use => Vars_Used,
2036:                   Var_Im_Use => Var_Im_Use,
2037:                   Subp_Calls => Funcalls,
2038:                   Indt_Calls => Indcalls,
2039:                   Vertex_Ctx => Ctx.Vertex_Ctx,
```

## flow/flow-control_flow_graph.adb:2440–2532

```ada
2440:       --  Store the extended return node in context, because it cannot be
2441:       --  retrieved from the AST when we see a simple_return_statement.
2442:       Ctx.Extended_Return := N;
2443:
2444:       --  Process return object declarations
2445:       Process_Statement_List (Ret_Object_L, FA, CM, Ctx);
2446:
2447:       --  Connections for the return object declarations become connections for
2448:       --  the extended return statements itself.
2449:
2450:       Move_Connections
2451:         (CM, Dst => Union_Id (N), Src => Union_Id (Ret_Object_L));
2452:
2453:       --  The declratations alone must return normally
2454:
2455:       pragma Assert (not CM (Union_Id (N)).Standard_Exits.Is_Empty);
2456:
2457:       if Present (HSS) then
2458:          --  We process the sequence of statements
2459:          Process_Statement (HSS, FA, CM, Ctx);
2460:
2461:          --  We link the standard exits of return object declarations to the
2462:          --  standard entry of the sequence of statements.
2463:
2464:          declare
2465:             HSS_Position : Connection_Maps.Cursor := CM.Find (Union_Id (HSS));
2466:          begin
2467:             declare
2468:                N_Connections   : Graph_Connections renames CM (Union_Id (N));
2469:                HSS_Connections : Graph_Connections renames CM (HSS_Position);
2470:             begin
2471:                Linkup
2472:                  (FA,
2473:                   N_Connections.Standard_Exits,
2474:                   HSS_Connections.Standard_Entry);
2475:
2476:                Vertex_Sets.Move
2477:                  (Target => N_Connections.Standard_Exits,
2478:                   Source => HSS_Connections.Standard_Exits);
2479:             end;
2480:
2481:             CM.Delete (HSS_Position);
2482:          end;
2483:       end if;
2484:
2485:       --  If what we have so far returns normally, then we need a vertex for
2486:       --  the implicit return, which defines the function's result using the
2487:       --  declared object.
2488:
2489:       if not CM (Union_Id (N)).Standard_Exits.Is_Empty then
2490:
2491:          --  Add dummy vertex which combines all the standard exits from
2492:          --  the Handled_Statement_Sequence and has just one exit, so that
2493:          --  the subsequent vertices with cleanup actions form a straight
2494:          --  single-entry -> single-exit sequence.
2495:
2496:          Add_Vertex (FA, Null_Node_Attributes, V);
2497:
2498:          --  Link the standard exits of declarations + statements to the
2499:          --  standard entry of this dummy vertex.
2500:
2501:          Linkup (FA, CM (Union_Id (N)).Standard_Exits, V);
2502:
2503:          --  Process all cleanup actions
2504:
2505:          Unwind_All (FA, Ctx, Last => V);
2506:
2507:          --  Add implicit return vertex and link it after cleanup actions
2508:
2509:          Add_Vertex
2510:            (FA,
2511:             Direct_Mapping_Id (Ret_Entity),
2512:             Make_Extended_Return_Attributes
2513:               (Var_Def         =>
2514:                  Flatten_Variable (FA.Spec_Entity, FA.B_Scope),
2515:                Var_Use         => Flatten_Variable (Ret_Object, FA.B_Scope),
2516:                Object_Returned => Ret_Object,
2517:                Vertex_Ctx      => Ctx.Vertex_Ctx,
2518:                E_Loc           => Ret_Entity),
2519:             Implicit_Ret);
2520:
2521:          Linkup (FA, V, Implicit_Ret);
2522:
2523:          --  We link the implicit return statement to the helper end vertex
2524:
2525:          Linkup (FA, Implicit_Ret, FA.Helper_End_Vertex);
2526:
2527:          --  The extended return statement as a whole doesn't return normally
2528:
2529:          CM (Union_Id (N)).Standard_Exits := Empty_Set;
2530:       end if;
2531:
2532:       Ctx.Extended_Return := Types.Empty;
```

## flow/flow-control_flow_graph.adb:2591–2705

```ada
2591:    procedure Do_Handled_Sequence_Of_Statements
2592:      (N   : Node_Id;
2593:       FA  : in out Flow_Analysis_Graphs;
2594:       CM  : in out Connection_Maps.Map;
2595:       Ctx : in out Context)
2596:    is
2597:       Handler : Node_Id;
2598:       HStmts  : List_Id;
2599:       Stmts   : constant List_Id := Statements (N);
2600:
2601:       Final_Stmts : constant List_Id := Finally_Statements (N);
2602:    begin
2603:       if Present (Final_Stmts) then
2604:          Ctx.Unwind_Actions.Append (N);
2605:          Ctx.Finally_Ctxs.Insert (N, Ctx.Vertex_Ctx);
2606:       end if;
2607:
2608:       --  Borrowers might be declared both in block statements and extended
2609:       --  return statements, but both these constructs include a handled
2610:       --  sequence of statements, so it is better to handle both of them here.
2611:
2612:       Ctx.Unwind_Lengths.Append (Ctx.Unwind_Actions.Length);
2613:
2614:       --  We first process exception handlers, so when a statement from the
2615:       --  handled sequence of statements raises an exception, it can be linked
2616:       --  straight to the exception handler. Otherwise, we would need to store
2617:       --  vertices where exceptions are raised and link them to vertices for
2618:       --  the handlers afterwards.
2619:
2620:       --  We don't expect any meaningful pragma at the beginning of exception
2621:       --  handlers.
2622:
2623:       Handler := First_Non_Pragma (Exception_Handlers (N));
2624:
2625:       while Present (Handler) loop
2626:          HStmts := Statements (Handler);
2627:
2628:          Process_Statement_List (HStmts, FA, CM, Ctx);
2629:
2630:          --  It is more convenient to connect a raise statement with the node
2631:          --  of the exception handler and not with the list of its statements,
2632:          --  so move the connections.
2633:
2634:          Move_Connections
2635:            (CM, Dst => Union_Id (Handler), Src => Union_Id (HStmts));
2636:
2637:          Next_Non_Pragma (Handler);
2638:       end loop;
2639:
2640:       --  Now process the handed statements themselves
2641:
2642:       Process_Statement_List (Stmts, FA, CM, Ctx);
2643:       Move_Connections (CM, Dst => Union_Id (N), Src => Union_Id (Stmts));
2644:
2645:       --  Finally, combine standard exits of the normal execution and
2646:       --  exception handlers and forget about the handlers, since they can't
2647:       --  be referenced anymore.
2648:
2649:       Handler := First_Non_Pragma (Exception_Handlers (N));
2650:       while Present (Handler) loop
2651:          declare
2652:             Handler_Connections : Connection_Maps.Cursor :=
2653:               CM.Find (Union_Id (Handler));
2654:          begin
2655:             CM (Union_Id (N)).Standard_Exits.Union
2656:               (CM (Handler_Connections).Standard_Exits);
2657:
2658:             CM.Delete (Handler_Connections);
2659:          end;
2660:
2661:          Next_Non_Pragma (Handler);
2662:       end loop;
2663:
2664:       if Present (Final_Stmts) then
2665:
2666:          --  Remove finally statements from the stack of cleanup actions
2667:
2668:          Ctx.Finally_Ctxs.Delete (N);
2669:          Ctx.Unwind_Actions.Delete_Last;
2670:
2671:          --  Since finally statements might occur in several copies on the
2672:          --  graph, we don't want to warn on some of their statements being
2673:          --  unreachable or ineffective in one copy, because they might be
2674:          --  reachable and effective in another copy.
2675:          --
2676:          --  Obviously, this should be improved...
2677:
2678:          declare
2679:             Save_Warnings_Off : constant Boolean :=
2680:               Ctx.Vertex_Ctx.Warnings_Off;
2681:          begin
2682:             Ctx.Vertex_Ctx.Warnings_Off := True;
2683:
2684:             Process_Statement_List (Final_Stmts, FA, CM, Ctx);
2685:
2686:             Ctx.Vertex_Ctx.Warnings_Off := Save_Warnings_Off;
2687:          end;
2688:
2689:          Linkup
2690:            (FA,
2691:             Froms => CM (Union_Id (N)).Standard_Exits,
2692:             To    => CM (Union_Id (Final_Stmts)).Standard_Entry);
2693:
2694:          Vertex_Sets.Move
2695:            (Target => CM (Union_Id (N)).Standard_Exits,
2696:             Source => CM (Union_Id (Final_Stmts)).Standard_Exits);
2697:
2698:          CM.Delete (Union_Id (Final_Stmts));
2699:       end if;
2700:
2701:       --  Local borrowers cease to exist when exiting the handled sequence of
2702:       --  statements.
2703:
2704:       Ctx.Unwind_Lengths.Delete_Last;
2705:    end Do_Handled_Sequence_Of_Statements;
```

## flow/flow-control_flow_graph.adb:3397–3454

```ada
3397:       procedure Do_For_Loop (Fully_Initialized : out Flow_Id_Sets.Set) is
3398:          LPS : constant Node_Id :=
3399:            Loop_Parameter_Specification (Iteration_Scheme (N));
3400:
3401:          LP : constant Entity_Id := Defining_Identifier (LPS);
3402:
3403:          DSD    : constant Node_Id := Discrete_Subtype_Definition (LPS);
3404:          R      : constant Node_Id := Get_Loop_Range (N);
3405:          LB     : constant Node_Id := Low_Bound (R);
3406:          HB     : constant Node_Id := High_Bound (R);
3407:          Filter : constant Node_Id := Iterator_Filter (LPS);
3408:          Vars   : constant Flow_Id_Sets.Set :=
3409:            Get_Variables
3410:              (N                    => LB,
3411:               Scope                => FA.B_Scope,
3412:               Target_Name          => Null_Flow_Id,
3413:               Fold_Functions       => Inputs,
3414:               Use_Computed_Globals => not FA.Generating_Globals)
3415:            or
3416:              Get_Variables
3417:                (N                    => HB,
3418:                 Scope                => FA.B_Scope,
3419:                 Target_Name          => Null_Flow_Id,
3420:                 Fold_Functions       => Inputs,
3421:                 Use_Computed_Globals => not FA.Generating_Globals)
3422:            or Get_Filter_Variables (Filter);
3423:
3424:          V        : Flow_Graphs.Vertex_Id;
3425:          Funcalls : Call_Sets.Set;
3426:          Indcalls : Node_Sets.Set;
3427:       begin
3428:          --  We have a new variable here which we have not picked up
3429:          --  in Create, so we should set it up.
3430:          Create_Initial_And_Final_Vertices (LP, FA);
3431:
3432:          Pick_Generated_Info
3433:            (DSD,
3434:             FA.B_Scope,
3435:             Function_Calls     => Funcalls,
3436:             Indirect_Calls     => Indcalls,
3437:             Proof_Dependencies => FA.Proof_Dependencies,
3438:             Locks              => FA.Locks,
3439:             Generating_Globals => FA.Generating_Globals);
3440:
3441:          Add_Vertex
3442:            (FA,
3443:             Direct_Mapping_Id (N),
3444:             Make_Basic_Attributes
3445:               (Var_Def    => Flatten_Variable (LP, FA.B_Scope),
3446:                Var_Ex_Use => Vars,
3447:                Subp_Calls => Funcalls,
3448:                Indt_Calls => Indcalls,
3449:                Obj_Decls  => Node_Sets.To_Set (LP),
3450:                Vertex_Ctx => Ctx.Vertex_Ctx,
3451:                E_Loc      => N),
3452:             V);
3453:          Ctx.Folded_Function_Checks.Append (LB);
3454:          Ctx.Folded_Function_Checks.Append (HB);
```

## flow/flow-control_flow_graph.adb:3609–3666

```ada
3609:          procedure Emit_Warning (T : Target; N : Node_Id);
3610:          --  Emit warning about T being written in node N
3611:
3612:          function Get_Array_Index (N : Node_Id) return Target
3613:          with
3614:            Pre  => Present (N),
3615:            Post =>
3616:              (if Get_Array_Index'Result.Kind = Precise
3617:               then
3618:                 Get_Array_Index'Result.Var.Kind
3619:                 in Direct_Mapping | Record_Field
3620:                 and then not Get_Array_Index'Result.D.Is_Empty
3621:                 and then
3622:                   (for all E of Get_Array_Index'Result.D =>
3623:                      Ekind (E) = E_Loop_Parameter));
3624:          --  Convert the target of an assignment to an array into a flow id
3625:          --  and a list of loop parameters.
3626:
3627:          function Fully_Defined_In_Original_Loop (T : Target) return Boolean
3628:          with Pre => T.Kind = Precise;
3629:          --  Performs a mini-flow analysis on the current loop statements to
3630:          --  see if T is defined on all paths (but not explicitly used).
3631:
3632:          procedure Potentially_Defined (N : Node_Id)
3633:          with Pre => Nkind (N) in N_Subexpr;
3634:          --  Examine if a subexpression N denotes an component of an array that
3635:          --  is fully initialized in the current loop.
3636:
3637:          function Proc_Search (N : Node_Id) return Traverse_Result;
3638:          --  In the traversal of the loop body, this finds suitable targets
3639:          --  and checks if they are fully initialized.
3640:
3641:          procedure Rec is new Traverse_More_Proc (Proc_Search);
3642:          --  Wrapper around the traversal, so that Proc_Search can call itself
3643:
3644:          ------------------
3645:          -- Emit_Warning --
3646:          ------------------
3647:
3648:          procedure Emit_Warning (T : Target; N : Node_Id) is
3649:             F   : Flow_Id renames T.Var;
3650:             Obj : constant Entity_Id :=
3651:               Get_Direct_Mapping_Id (Entire_Variable (F));
3652:          begin
3653:             if not Is_Default_Initialized (F)
3654:               and then
3655:                 not (Present (Obj) and then Ekind (Obj) = E_In_Out_Parameter)
3656:               and then
3657:                 not Has_Relaxed_Initialization (Get_Direct_Mapping_Id (F))
3658:               and then not FA.Generating_Globals
3659:             then
3660:                if T.D.Length = 1 then
3661:                   Warning_Msg_N (Warn_Init_Array, N);
3662:                else
3663:                   Warning_Msg_N (Warn_Init_Multidim_Array, N);
3664:                end if;
3665:             end if;
3666:          end Emit_Warning;
```

## flow/flow-control_flow_graph.adb:4007–4118

```ada
4007:
4008:             return Fully_Defined;
4009:          end Fully_Defined_In_Original_Loop;
4010:
4011:          -------------------------
4012:          -- Potentially_Defined --
4013:          -------------------------
4014:
4015:          procedure Potentially_Defined (N : Node_Id) is
4016:             T : constant Target := Get_Array_Index (N);
4017:          begin
4018:             case T.Kind is
4019:                when Precise   =>
4020:                   if Fully_Defined_In_Original_Loop (T) then
4021:                      Fully_Initialized.Include (T.Var);
4022:                   else
4023:                      Emit_Warning (T, N);
4024:                   end if;
4025:
4026:                when Imprecise =>
4027:                   Emit_Warning (T, N);
4028:
4029:                when Invalid   =>
4030:                   null;
4031:             end case;
4032:          end Potentially_Defined;
4033:
4034:          -----------------
4035:          -- Proc_Search --
4036:          -----------------
4037:
4038:          function Proc_Search (N : Node_Id) return Traverse_Result is
4039:          begin
4040:             case Nkind (N) is
4041:                when N_Loop_Statement                                    =>
4042:                   if N = Current_Loop then
4043:                      return OK;
4044:
4045:                   elsif Is_For_Loop (N) then
4046:                      declare
4047:                         Old_Loop      : constant Node_Id := Current_Loop;
4048:                         Loop_Variable : constant Entity_Id :=
4049:                           Get_Loop_Variable (N);
4050:
4051:                      begin
4052:                         Current_Loop := N;
4053:                         Active_Loops.Insert (Loop_Variable);
4054:
4055:                         Rec (N);
4056:
4057:                         Current_Loop := Old_Loop;
4058:                         Active_Loops.Delete (Loop_Variable);
4059:                      end;
4060:
4061:                      return Skip;
4062:                   end if;
4063:
4064:                when N_Assignment_Statement                              =>
4065:                   Potentially_Defined (Name (N));
4066:
4067:                when N_Procedure_Call_Statement | N_Entry_Call_Statement =>
4068:                   declare
4069:                      procedure Handle_Parameter
4070:                        (Formal : Entity_Id; Actual : Node_Id);
4071:
4072:                      ----------------------
4073:                      -- Handle_Parameter --
4074:                      ----------------------
4075:
4076:                      procedure Handle_Parameter
4077:                        (Formal : Entity_Id; Actual : Node_Id) is
4078:                      begin
4079:                         if Ekind (Formal) = E_Out_Parameter then
4080:                            Potentially_Defined (Actual);
4081:                         end if;
4082:                      end Handle_Parameter;
4083:
4084:                      procedure Handle_Parameters is new
4085:                        Iterate_Call_Parameters
4086:                          (Handle_Parameter => Handle_Parameter);
4087:
4088:                   begin
4089:                      Handle_Parameters (N);
4090:                   end;
4091:
4092:                --  Don't traverse into subprograms (because we don't check if
4093:                --  they are executed) and into packages (because they can only
4094:                --  modify their own objects anyway).
4095:
4096:                when N_Subprogram_Body
4097:                   | N_Subprogram_Declaration
4098:                   | N_Package_Declaration
4099:                   | N_Package_Body
4100:                   | N_Generic_Declaration                               =>
4101:                   return Skip;
4102:
4103:                when others                                              =>
4104:                   null;
4105:             end case;
4106:             return OK;
4107:          end Proc_Search;
4108:
4109:          --  Start of processing for Variables_Initialized_By_Loop
4110:
4111:       begin
4112:          if Loop_Might_Exit_Early (Loop_N) then
4113:             return Flow_Id_Sets.Empty_Set;
4114:          end if;
4115:
4116:          Rec (Loop_N);
4117:
4118:          return Fully_Initialized;
```

## flow/flow-control_flow_graph.adb:4205–4222

```ada
4205:       --  is here as well.
4206:       Ctx.Vertex_Ctx.Current_Loops.Insert (Loop_Id);
4207:       Ctx.Entry_References.Insert (Loop_Id, Node_Sets.Empty_Set);
4208:       Ctx.Termination_Proved := False;
4209:
4210:       declare
4211:          Outer_Loop : constant Entity_Id := Ctx.Active_Loop;
4212:       begin
4213:          --  We can't use 'Update here as we may modify Ctx
4214:          Ctx.Active_Loop := Loop_Id;
4215:          Process_Statement_List (Statements (N), FA, CM, Ctx);
4216:          Ctx.Active_Loop := Outer_Loop;
4217:       end;
4218:
4219:       --  Collect loop writes, this is needed to determine if the root object
4220:       --  of a path expression in the iteration scheme is modified during the
4221:       --  loop.
4222:
```

## flow/flow-control_flow_graph.adb:4306–4353

```ada
4306:
4307:       --  If we need an init vertex, we add it before the loop itself
4308:       if not Fully_Initialized.Is_Empty then
4309:          declare
4310:             V : Flow_Graphs.Vertex_Id;
4311:          begin
4312:             Add_Vertex
4313:               (FA,
4314:                (Make_Basic_Attributes
4315:                   (Var_Def    => Fully_Initialized,
4316:                    Vertex_Ctx => Ctx.Vertex_Ctx,
4317:                    E_Loc      => Loop_Id,
4318:                    Print_Hint => Pretty_Print_Loop_Init)
4319:                 with delta Is_Program_Node => False),
4320:                V);
4321:
4322:             Linkup (FA, V, CM (Union_Id (N)).Standard_Entry);
4323:             CM (Union_Id (N)).Standard_Entry := V;
4324:          end;
4325:       end if;
4326:
4327:       --  Now we need to glue the 'Loop_Entry checks to the front of the loop
4328:       declare
4329:          Augmented_Loop : Union_Lists.List := Union_Lists.Empty_List;
4330:          V              : Flow_Graphs.Vertex_Id;
4331:          Block          : Graph_Connections;
4332:       begin
4333:          --  We stick all loop entry references on a list of nodes
4334:          for Reference of Ctx.Entry_References (Loop_Id) loop
4335:             Add_Vertex
4336:               (FA,
4337:                Direct_Mapping_Id (Reference),
4338:                Make_Sink_Vertex_Attributes
4339:                  (Var_Use       =>
4340:                     Get_All_Variables
4341:                       (Prefix (Reference),
4342:                        Scope                => FA.B_Scope,
4343:                        Target_Name          => Null_Flow_Id,
4344:                        Use_Computed_Globals => not FA.Generating_Globals),
4345:                   Is_Assertion  => True,
4346:                   Is_Loop_Entry => True,
4347:                   Vertex_Ctx    => Ctx.Vertex_Ctx),
4348:                V);
4349:             Ctx.Folded_Function_Checks.Append (Prefix (Reference));
4350:
4351:             CM.Insert (Union_Id (Reference), Trivial_Connection (V));
4352:
4353:             Augmented_Loop.Append (Union_Id (Reference));
```

## flow/flow-control_flow_graph.adb:4878–4902

```ada
4878:       --  Declaration with a function that has side effects is handled like a
4879:       --  subprogram call: the function entity acts like a formal parameter of
4880:       --  mode OUT and the defining identifier acts like the corresponding
4881:       --  actual parameter.
4882:
4883:       if Present (Expr)
4884:         and then Nkind (Expr) = N_Function_Call
4885:         and then Is_Function_With_Side_Effects (Get_Called_Entity (Expr))
4886:       then
4887:          Do_Call_Statement (Expr, FA, CM, Ctx);
4888:          Move_Connections (CM, Dst => Union_Id (N), Src => Union_Id (Expr));
4889:          return;
4890:       end if;
4891:
4892:       --  We have a declaration with an explicit initialization
4893:
4894:       if Present (Expr) then
4895:          declare
4896:             Funcalls : Call_Sets.Set;
4897:             Indcalls : Node_Sets.Set;
4898:
4899:             To_CW : constant Boolean :=
4900:               Is_Class_Wide_Type (Get_Type (E, FA.B_Scope))
4901:               and then not Is_Class_Wide_Type (Get_Type (Expr, FA.B_Scope));
4902:
```

## flow/flow-control_flow_graph.adb:4993–5034

```ada
4993:                      end;
4994:                   end loop;
4995:                end;
4996:
4997:             else
4998:                Add_Vertex
4999:                  (FA,
5000:                   Direct_Mapping_Id (N),
5001:                   Make_Basic_Attributes
5002:                     (Var_Def    => Var_Def,
5003:                      Var_Ex_Use =>
5004:                        Get_Variables
5005:                          (Expr,
5006:                           Scope                => FA.B_Scope,
5007:                           Target_Name          => Null_Flow_Id,
5008:                           Fold_Functions       => Inputs,
5009:                           Use_Computed_Globals => not FA.Generating_Globals,
5010:                           Consider_Extensions  => To_CW),
5011:                      Subp_Calls => Funcalls,
5012:                      Indt_Calls => Indcalls,
5013:                      Vertex_Ctx => Ctx.Vertex_Ctx,
5014:                      E_Loc      => N),
5015:                   V);
5016:                Inits.Append (V);
5017:
5018:                --  If this object is a local borrower, then put its declaration
5019:                --  on the stack. We only need this for assignments whose RHS
5020:                --  doesn't need to be split, because local borrowers are always
5021:                --  of an access type and thus in flow they are represented as
5022:                --  single "blobs".
5023:
5024:                if Is_Anonymous_Access_Object_Type (Get_Type (E, FA.B_Scope))
5025:                  and then not Is_Access_Constant (Get_Type (E, FA.B_Scope))
5026:                then
5027:                   Ctx.Unwind_Actions.Append (N);
5028:                end if;
5029:
5030:             end if;
5031:
5032:             Ctx.Folded_Function_Checks.Append (Expr);
5033:          end;
5034:          pragma Assert (not Inits.Is_Empty);
```

## flow/flow-control_flow_graph.adb:5150–5208

```ada
5150:                end;
5151:             elsif Is_Default_Initialized (F) then
5152:                Add_Vertex
5153:                  (FA,
5154:                   Make_Default_Initialization_Attributes
5155:                     (FA         => FA,
5156:                      Scope      => FA.B_Scope,
5157:                      F          => F,
5158:                      Vertex_Ctx => Ctx.Vertex_Ctx),
5159:                   V);
5160:                Inits.Append (V);
5161:             end if;
5162:          end loop;
5163:
5164:          --  If this type has a Default_Initial_Condition (DIC) then we need to
5165:          --  create a vertex to check for uninitialized variables within
5166:          --  the Default_Initial_Condition's expression. For imported objects
5167:          --  the DIC expression is not evaluated.
5168:          --  ??? what about DIC evaluated for individual components?
5169:
5170:          if not Is_Imported (E) and then Has_DIC (Typ) then
5171:             declare
5172:                procedure Add_Vertex_For_All_DIC is new
5173:                  Iterate_Applicable_DIC (Add_Vertex_For_DIC);
5174:             begin
5175:                Add_Vertex_For_All_DIC (Typ);
5176:             end;
5177:          end if;
5178:
5179:       end if;
5180:
5181:       --  Add a single vertex that represents object declaration; it acts as a
5182:       --  link to the object entity when declaration turns out to be dead code.
5183:
5184:       if No (Alias) then
5185:          Add_Vertex
5186:            (FA,
5187:             (Null_Node_Attributes
5188:              with delta
5189:                Is_Null_Node        => False,
5190:                Is_Program_Node     => False,
5191:                Object_Declarations => Node_Sets.To_Set (E),
5192:                Pretty_Print_Kind   => Pretty_Print_Declaration,
5193:                Error_Location      => N),
5194:             V);
5195:          Inits.Prepend (V);
5196:       end if;
5197:
5198:       --  If nothing has been initialized by this object declaration, then add
5199:       --  a dummy vertex.
5200:
5201:       if Inits.Is_Empty then
5202:          Add_Dummy_Vertex (N, FA, CM);
5203:
5204:       --  Otherwise, link all initialization vertices
5205:
5206:       else
5207:          V := Flow_Graphs.Null_Vertex;
5208:          for W of Inits loop
```

## flow/flow-control_flow_graph.adb:6048–6052

```ada
6048:
6049:       Local_Handlers : constant Node_Lists.List :=
6050:         (if Nkind (N) in N_Subprogram_Call
6051:          then Reachable_Handlers (N)
6052:          else Node_Lists.Empty_List);
```

## flow/flow-control_flow_graph.adb:6102–6119

```ada
6102:       Add_Vertex
6103:         (FA,
6104:          Direct_Mapping_Id (N),
6105:          Make_Call_Attributes
6106:            (Callsite   => N,
6107:             Callee     => Called_Thing,
6108:             Var_Use    => Vars_Used,
6109:             Subp_Calls =>
6110:               Call_Sets.To_Set (Subprogram_Call'(N => N, E => Called_Thing))
6111:                 .Union (Funcalls),
6112:             Indt_Calls => Indcalls,
6113:             Vertex_Ctx => Ctx.Vertex_Ctx,
6114:             E_Loc      => N),
6115:          Call_V);
6116:       FA.CFG.Set_Cluster (Call_V, C);
6117:
6118:       --  Deal with the subprogram's parameters
6119:       Process_Call_Actuals
```

## flow/flow-control_flow_graph.adb:6238–6258

```ada
6238:          --  raising an exception, prunned and consequently the <raise>
6239:          --  vertex would be recognized as a branch preventing exception from
6240:          --  being raised. In turn, this would render all call statements as
6241:          --  effective, even those which have no effect at all.
6242:
6243:          if not Local_Handlers.Is_Empty then
6244:             Add_Vertex
6245:               (FA,
6246:                Make_Basic_Attributes
6247:                  (Vertex_Ctx => Ctx.Vertex_Ctx,
6248:                   E_Loc      => N,
6249:                   Print_Hint => Pretty_Print_Call_Exception),
6250:                Excp);
6251:             FA.Atr (Excp).Is_Call_Exception := True;
6252:             FA.Atr (Excp).Is_Program_Node := False;
6253:             FA.CFG.Set_Cluster (Excp, C);
6254:             FA.CFG.Add_Edge (Prev, Excp, EC_Default);
6255:
6256:             Prev := Excp;
6257:          end if;
6258:
```

## flow/flow-control_flow_graph.adb:6278–6294

```ada
6278:          if Might_Exit_Program (N) then
6279:             Add_Vertex
6280:               (FA,
6281:                Make_Sink_Vertex_Attributes
6282:                  (Var_Use      =>
6283:                     Get_Outputs_From_Program_Exit
6284:                       (FA.Spec_Entity, FA.B_Scope, not FA.Generating_Globals),
6285:                   Vertex_Ctx   => Ctx.Vertex_Ctx,
6286:                   E_Loc        => N,
6287:                   Is_Assertion => True),
6288:                Program_Exit);
6289:
6290:             FA.Atr (Program_Exit).Pretty_Print_Kind :=
6291:               Pretty_Print_Program_Exit;
6292:
6293:             FA.CFG.Set_Cluster (Program_Exit, C);
6294:             FA.CFG.Add_Edge (Prev, Program_Exit, EC_Default);
```

## flow/flow-control_flow_graph.adb:6318–6339

```ada
6318:                  (Standard_Entry => Call_V,
6319:                   Standard_Exits => Vertex_Sets.To_Set (Prev)));
6320:
6321:             if not Local_Handlers.Is_Empty then
6322:                --  Create the <havoc> vertex and populate it with variables
6323:                --  that are actually havoced.
6324:
6325:                Add_Vertex
6326:                  (FA,
6327:                   Make_Basic_Attributes
6328:                     (Vertex_Ctx => Ctx.Vertex_Ctx,
6329:                      E_Loc      => N,
6330:                      Print_Hint => Pretty_Print_Param_Havoc),
6331:                   Havoc);
6332:                FA.Atr (Havoc).Is_Param_Havoc := True;
6333:                FA.Atr (Havoc).Is_Program_Node := False;
6334:                FA.CFG.Set_Cluster (Havoc, C);
6335:                FA.CFG.Add_Edge (Excp, Havoc, EC_Default);
6336:
6337:                for Out_By_Unspecified of Outs_By_Unspecified loop
6338:                   pragma Assert (FA.Atr (Out_By_Unspecified).Is_Parameter);
6339:                   pragma
```

## flow/flow-control_flow_graph.adb:6393–6433

```ada
6393:    procedure Do_Contract_Expression
6394:      (N   : Node_Id;
6395:       FA  : in out Flow_Analysis_Graphs;
6396:       CM  : in out Connection_Maps.Map;
6397:       Ctx : in out Context)
6398:    is
6399:       pragma Unmodified (Ctx);
6400:
6401:       V        : Flow_Graphs.Vertex_Id;
6402:       Funcalls : Call_Sets.Set;
6403:       Indcalls : Node_Sets.Set;
6404:    begin
6405:       --  We just need to check for uninitialized variables
6406:       Pick_Generated_Info
6407:         (N,
6408:          FA.B_Scope,
6409:          Function_Calls     => Funcalls,
6410:          Indirect_Calls     => Indcalls,
6411:          Proof_Dependencies => FA.Proof_Dependencies,
6412:          Locks              => FA.Locks,
6413:          Generating_Globals => FA.Generating_Globals);
6414:
6415:       Add_Vertex
6416:         (FA,
6417:          Direct_Mapping_Id (N),
6418:          Make_Sink_Vertex_Attributes
6419:            (Var_Use      =>
6420:               Get_All_Variables
6421:                 (N,
6422:                  Scope                => FA.B_Scope,
6423:                  Target_Name          => Null_Flow_Id,
6424:                  Use_Computed_Globals => not FA.Generating_Globals),
6425:             Subp_Calls   => Funcalls,
6426:             Indt_Calls   => Indcalls,
6427:             Is_Assertion => True,
6428:             Vertex_Ctx   => Ctx.Vertex_Ctx,
6429:             E_Loc        => N),
6430:          V);
6431:
6432:       CM.Insert (Union_Id (N), Trivial_Connection (V));
6433:    end Do_Contract_Expression;
```

## flow/flow-control_flow_graph.adb:6442–6539

```ada
6442:       CM  : in out Connection_Maps.Map;
6443:       Ctx : in out Context)
6444:    is
6445:       V        : Flow_Graphs.Vertex_Id;
6446:       Funcalls : Call_Sets.Set;
6447:       Indcalls : Node_Sets.Set;
6448:
6449:       Expr : constant Node_Id := Expression (N);
6450:
6451:    begin
6452:       if No (Expr) then
6453:          --  We have a return for a procedure, entry, extended return or accept
6454:          --  statement (Ada RM 6.5), however accept statements are not allowed
6455:          --  in SPARK.
6456:
6457:          if No (Ctx.Extended_Return) then
6458:             Add_Vertex
6459:               (FA,
6460:                Direct_Mapping_Id (N),
6461:                Make_Aux_Vertex_Attributes (E_Loc => N),
6462:                V);
6463:
6464:          --  This is a simple return statement within an extended return
6465:          --  statement of a function.
6466:
6467:          else
6468:             pragma Assert (Ekind (FA.Spec_Entity) = E_Function);
6469:
6470:             --  Add dummy vertex as a start for a sequence of finally
6471:             --  statements and borrower reclamations.
6472:             Add_Vertex (FA, Null_Node_Attributes, V);
6473:          end if;
6474:       else
6475:          --  We have a function return
6476:          Pick_Generated_Info
6477:            (Expr,
6478:             FA.B_Scope,
6479:             Function_Calls     => Funcalls,
6480:             Indirect_Calls     => Indcalls,
6481:             Proof_Dependencies => FA.Proof_Dependencies,
6482:             Locks              => FA.Locks,
6483:             Generating_Globals => FA.Generating_Globals);
6484:
6485:          Add_Vertex
6486:            (FA,
6487:             Direct_Mapping_Id (N),
6488:             Make_Basic_Attributes
6489:               (Var_Def    => Flatten_Variable (FA.Spec_Entity, FA.B_Scope),
6490:                Var_Ex_Use =>
6491:                  Get_Variables
6492:                    (Expr,
6493:                     Scope                => FA.B_Scope,
6494:                     Target_Name          => Null_Flow_Id,
6495:                     Fold_Functions       => Inputs,
6496:                     Use_Computed_Globals => not FA.Generating_Globals),
6497:                Subp_Calls => Funcalls,
6498:                Indt_Calls => Indcalls,
6499:                Vertex_Ctx => Ctx.Vertex_Ctx,
6500:                E_Loc      => N),
6501:             V);
6502:          Ctx.Folded_Function_Checks.Append (Expr);
6503:       end if;
6504:
6505:       --  Control flows in, but we do not flow out again
6506:       CM.Insert
6507:         (Union_Id (N),
6508:          Graph_Connections'(Standard_Entry => V, Standard_Exits => Empty_Set));
6509:
6510:       --  Process all cleanup actions
6511:
6512:       Unwind_All (FA, Ctx, Last => V);
6513:
6514:       --  When cleanup actions are done, create an implicit return for a simple
6515:       --  return statement within an extended return statement.
6516:
6517:       if No (Expr) and then Present (Ctx.Extended_Return) then
6518:          declare
6519:             Implicit_Ret : Flow_Graphs.Vertex_Id;
6520:             Ret_Object   : constant Entity_Id :=
6521:               Get_Return_Object (Ctx.Extended_Return);
6522:          begin
6523:             Add_Vertex
6524:               (FA => FA,
6525:                F  => Direct_Mapping_Id (N),
6526:                A  =>
6527:                  Make_Extended_Return_Attributes
6528:                    (Var_Def         =>
6529:                       Flatten_Variable (FA.Spec_Entity, FA.B_Scope),
6530:                     Var_Use         =>
6531:                       Flatten_Variable (Ret_Object, FA.B_Scope),
6532:                     Object_Returned => Ret_Object,
6533:                     Vertex_Ctx      => Ctx.Vertex_Ctx,
6534:                     E_Loc           =>
6535:                       Return_Statement_Entity (Ctx.Extended_Return)),
6536:                V  => Implicit_Ret);
6537:
6538:             --  Implicit return must be executed at the very end
6539:
```

## flow/flow-control_flow_graph.adb:6556–6625

```ada
6556:    procedure Do_Subprogram_Or_Block
6557:      (N   : Node_Id;
6558:       FA  : in out Flow_Analysis_Graphs;
6559:       CM  : in out Connection_Maps.Map;
6560:       Ctx : in out Context)
6561:    is
6562:       L     : Union_Lists.List := Union_Lists.Empty_List;
6563:       Block : Graph_Connections;
6564:       Decls : constant List_Id := Declarations (N);
6565:       HSS   : constant Node_Id := Handled_Statement_Sequence (N);
6566:
6567:       Unwind_Marker : constant Ada.Containers.Count_Type :=
6568:         Ctx.Unwind_Actions.Length;
6569:       --  Record current position of the borrows stack
6570:
6571:    begin
6572:       if Nkind (Original_Node (N)) in N_Subprogram_Call then
6573:          Do_Null_Statement (N, FA, CM, Ctx);
6574:          L.Append (Union_Id (N));
6575:       end if;
6576:
6577:       if Present (Decls) then
6578:          Process_Statement_List (Decls, FA, CM, Ctx);
6579:          L.Append (Union_Id (Decls));
6580:       end if;
6581:
6582:       --  When processing a package body respect the optional SPARK_Mode => Off
6583:       --  on the package body statements.
6584:
6585:       if (if Nkind (N) = N_Package_Body
6586:           then Body_Statements_In_SPARK (Unique_Defining_Entity (N)))
6587:       then
6588:          Process_Statement (HSS, FA, CM, Ctx);
6589:          L.Append (Union_Id (HSS));
6590:       end if;
6591:
6592:       Join (FA, CM, L, Block);
6593:
6594:       --  When the subprogram or block exits early, e.g. with a RETURN or an
6595:       --  EXIT statement, then we just forget about the cleanup actions. They
6596:       --  have been already executed when processing the exiting statement.
6597:
6598:       if Block.Standard_Exits.Is_Empty then
6599:          while Ctx.Unwind_Actions.Length > Unwind_Marker loop
6600:             Ctx.Unwind_Actions.Delete_Last;
6601:          end loop;
6602:       else
6603:          declare
6604:             V : Flow_Graphs.Vertex_Id;
6605:             --  A dummy vertex which combines all the standard exits from
6606:             --  the Handled_Statement_Sequence and has just one exit, so that
6607:             --  the subsequent vertices with cleanup actions form a straight
6608:             --  single-entry -> single-exit sequence.
6609:
6610:          begin
6611:             Add_Vertex (FA, Null_Node_Attributes, V);
6612:
6613:             Linkup (FA, Block.Standard_Exits, V);
6614:
6615:             while Ctx.Unwind_Actions.Length > Unwind_Marker loop
6616:                Unwind
6617:                  (Ctx.Unwind_Actions.Last_Element,
6618:                   FA,
6619:                   Ctx.Finally_Ctxs,
6620:                   Last => V);
6621:                Ctx.Unwind_Actions.Delete_Last;
6622:             end loop;
6623:
6624:             Block.Standard_Exits := Vertex_Sets.To_Set (V);
6625:          end;
```

## flow/flow-control_flow_graph.adb:6688–6735

```ada
6688:
6689:    procedure Do_Type_Declaration
6690:      (N   : Node_Id;
6691:       FA  : in out Flow_Analysis_Graphs;
6692:       CM  : in out Connection_Maps.Map;
6693:       Ctx : in out Context)
6694:    is
6695:       Typ : constant Entity_Id := Defining_Identifier (N);
6696:    begin
6697:       if Is_Scalar_Type (Typ) then
6698:          declare
6699:             R : constant Node_Id := Scalar_Range (Typ);
6700:
6701:             Vars_Read : constant Flow_Id_Sets.Set :=
6702:               Get_All_Variables
6703:                 (N                    => Low_Bound (R),
6704:                  Scope                => FA.B_Scope,
6705:                  Target_Name          => Null_Flow_Id,
6706:                  Use_Computed_Globals => not FA.Generating_Globals)
6707:               or
6708:                 Get_All_Variables
6709:                   (N                    => High_Bound (R),
6710:                    Scope                => FA.B_Scope,
6711:                    Target_Name          => Null_Flow_Id,
6712:                    Use_Computed_Globals => not FA.Generating_Globals);
6713:
6714:             V : Flow_Graphs.Vertex_Id;
6715:          begin
6716:             Add_Vertex
6717:               (FA,
6718:                Direct_Mapping_Id (N),
6719:                Make_Sink_Vertex_Attributes
6720:                  (Vars_Read,
6721:                   Is_Type_Decl => True,
6722:                   Vertex_Ctx   => Ctx.Vertex_Ctx),
6723:                V);
6724:             CM.Insert (Union_Id (N), Trivial_Connection (V));
6725:          end;
6726:       else
6727:          Add_Dummy_Vertex (N, FA, CM);
6728:       end if;
6729:
6730:       --  In phase 1, pull predicates and invariants that apply to type Typ
6731:       --  into the proof dependencies of the unit.
6732:
6733:       if FA.Generating_Globals and then Entity_In_SPARK (Typ) then
6734:          Process_Type_Contracts (Typ, FA.B_Scope, True, FA.Proof_Dependencies);
6735:       end if;
```

## flow/flow-control_flow_graph.adb:6863–7087

```ada
6863:    procedure Process_Subprogram_Globals
6864:      (Call     : Node_Id;
6865:       Callee   : Entity_Id;
6866:       Callsite : Flow_Graphs.Vertex_Id;
6867:       Ins      : in out Vertex_Lists.List;
6868:       Outs     : in out Vertex_Lists.List;
6869:       FA       : in out Flow_Analysis_Graphs;
6870:       CM       : in out Connection_Maps.Map;
6871:       Ctx      : in out Context)
6872:    is
6873:       pragma Unreferenced (CM);
6874:       pragma Unmodified (Ctx);
6875:
6876:       Globals : Global_Flow_Ids;
6877:       V       : Flow_Graphs.Vertex_Id;
6878:    begin
6879:       --  Obtain globals (either from contracts or the computed stuff)
6880:       Get_Globals
6881:         (Subprogram          => Callee,
6882:          Scope               => FA.B_Scope,
6883:          Classwide           => Flow_Classwide.Is_Dispatching_Call (Call),
6884:          Globals             => Globals,
6885:          Use_Deduced_Globals => not FA.Generating_Globals);
6886:
6887:       --  User-written Inputs and Proof_Ins may include constants without
6888:       --  variable input and we will complain about this when analyzying such
6889:       --  contracts. Here we filter such constants to not propagate the user's
6890:       --  mistake.
6891:       Remove_Constants (Globals.Proof_Ins);
6892:       Remove_Constants (Globals.Inputs);
6893:
6894:       for R of Globals.Proof_Ins loop
6895:          Add_Vertex
6896:            (FA,
6897:             Make_Global_Attributes
6898:               (Callsite   => Callsite,
6899:                Global     => R,
6900:                Mode       => Mode_Proof,
6901:                Scope      => FA.B_Scope,
6902:                Vertex_Ctx => Ctx.Vertex_Ctx,
6903:                E_Loc      => Call),
6904:             V);
6905:          Ins.Append (V);
6906:       end loop;
6907:
6908:       for R of Globals.Inputs loop
6909:          Add_Vertex
6910:            (FA,
6911:             Make_Global_Attributes
6912:               (Callsite   => Callsite,
6913:                Global     => R,
6914:                Mode       => Mode_In,
6915:                Scope      => FA.B_Scope,
6916:                Vertex_Ctx => Ctx.Vertex_Ctx,
6917:                E_Loc      => Call),
6918:             V);
6919:          Ins.Append (V);
6920:       end loop;
6921:
6922:       for W of Globals.Outputs loop
6923:          if not Globals.Inputs.Contains (Change_Variant (W, In_View)) then
6924:             Add_Vertex
6925:               (FA,
6926:                Make_Global_Attributes
6927:                  (Callsite   => Callsite,
6928:                   Global     => Change_Variant (W, In_View),
6929:                   Mode       => Mode_Out,
6930:                   Scope      => FA.B_Scope,
6931:                   Vertex_Ctx => Ctx.Vertex_Ctx,
6932:                   E_Loc      => Call),
6933:                V);
6934:             Ins.Append (V);
6935:          end if;
6936:          Add_Vertex
6937:            (FA,
6938:             Make_Global_Attributes
6939:               (Callsite   => Callsite,
6940:                Global     => W,
6941:                Mode       => Mode_Out,
6942:                Scope      => FA.B_Scope,
6943:                Vertex_Ctx => Ctx.Vertex_Ctx,
6944:                E_Loc      => Call),
6945:             V);
6946:          Outs.Append (V);
6947:       end loop;
6948:    end Process_Subprogram_Globals;
6949:
6950:    --------------------------
6951:    -- Process_Call_Actuals --
6952:    --------------------------
6953:
6954:    procedure Process_Call_Actuals
6955:      (Call                : Node_Id;
6956:       Callsite            : Flow_Graphs.Vertex_Id;
6957:       Ins                 : in out Vertex_Lists.List;
6958:       Outs_By_Copy        : in out Vertex_Lists.List;
6959:       Outs_By_Reference   : in out Vertex_Lists.List;
6960:       Outs_By_Unspecified : in out Vertex_Lists.List;
6961:       FA                  : in out Flow_Analysis_Graphs;
6962:       CM                  : in out Connection_Maps.Map;
6963:       Ctx                 : in out Context)
6964:    is
6965:       pragma Unreferenced (CM);
6966:
6967:       Called_Thing : constant Entity_Id := Get_Called_Entity (Call);
6968:
6969:       procedure Handle_Parameter (Formal : Entity_Id; Actual : Node_Id)
6970:       with
6971:         Pre =>
6972:           (if Is_Formal (Formal)
6973:            then Nkind (Actual) in N_Subexpr
6974:            elsif Is_Function_With_Side_Effects (Formal)
6975:            then Nkind (Actual) in N_Subexpr | N_Defining_Identifier);
6976:
6977:       ----------------------
6978:       -- Handle_Parameter --
6979:       ----------------------
6980:
6981:       procedure Handle_Parameter (Formal : Entity_Id; Actual : Node_Id) is
6982:          Funcalls : Call_Sets.Set;
6983:          Indcalls : Node_Sets.Set;
6984:          V        : Flow_Graphs.Vertex_Id;
6985:
6986:       begin
6987:          --  Build an in vertex
6988:          Pick_Generated_Info
6989:            (Actual,
6990:             FA.B_Scope,
6991:             Function_Calls     => Funcalls,
6992:             Indirect_Calls     => Indcalls,
6993:             Proof_Dependencies => FA.Proof_Dependencies,
6994:             Locks              => FA.Locks,
6995:             Generating_Globals => FA.Generating_Globals);
6996:
6997:          Add_Vertex
6998:            (FA,
6999:             Direct_Mapping_Id (Actual, In_View),
7000:             Make_Parameter_Attributes
7001:               (FA         => FA,
7002:                Call       => Call,
7003:                Callsite   => Callsite,
7004:                Actual     => Actual,
7005:                Formal     => Formal,
7006:                In_Vertex  => True,
7007:                Subp_Calls => Funcalls,
7008:                Indt_Calls => Indcalls,
7009:                Vertex_Ctx => Ctx.Vertex_Ctx,
7010:                E_Loc      => Actual),
7011:             V);
7012:
7013:          if Nkind (Actual) in N_Subexpr then
7014:             Ctx.Folded_Function_Checks.Append (Actual);
7015:          else
7016:             pragma Assert (Is_Function_With_Side_Effects (Formal));
7017:          end if;
7018:          Ins.Append (V);
7019:
7020:          --  Build an out vertex
7021:          if Ekind (Formal) in E_In_Out_Parameter | E_Out_Parameter | E_Function
7022:            or else Is_Writable_Parameter (Formal)
7023:          then
7024:             Process_Reclamation_Functions
7025:               (Etype (Formal), FA.Proof_Dependencies);
7026:
7027:             Add_Vertex
7028:               (FA,
7029:                Direct_Mapping_Id (Actual, Out_View),
7030:                Make_Parameter_Attributes
7031:                  (FA         => FA,
7032:                   Call       => Call,
7033:                   Callsite   => Callsite,
7034:                   Actual     => Actual,
7035:                   Formal     => Formal,
7036:                   In_Vertex  => False,
7037:                   Vertex_Ctx => Ctx.Vertex_Ctx,
7038:                   E_Loc      => Actual),
7039:                V);
7040:
7041:             if Is_Aliased (Formal)
7042:               or else Is_By_Reference_Type (Etype (Formal))
7043:               or else
7044:                 (Ekind (Formal) = E_In_Parameter
7045:                  and then Is_Writable_Parameter (Formal))
7046:             then
7047:                Outs_By_Reference.Append (V);
7048:             elsif Is_By_Copy_Type (Etype (Formal)) then
7049:                Outs_By_Copy.Append (V);
7050:             else
7051:                Outs_By_Unspecified.Append (V);
7052:             end if;
7053:          end if;
7054:       end Handle_Parameter;
7055:
7056:       procedure Handle_Parameters is new
7057:         Iterate_Call_Parameters (Handle_Parameter => Handle_Parameter);
7058:
7059:       --  Start of processing for Process_Call_Actuals
7060:
7061:    begin
7062:       Handle_Parameters (Call);
7063:
7064:       --  Function call is only processed for assignment where the call
7065:       --  occurs immediately as the RHS and the function has side effects. The
7066:       --  function entity acts as a formal parameter and the LHS acts as the
7067:       --  actual parameter.
7068:
7069:       if Nkind (Call) = N_Function_Call then
7070:          declare
7071:             Context : constant Node_Id := Parent (Call);
7072:             Actual  : Node_Id;
7073:          begin
7074:             case Nkind (Context) is
7075:                when N_Assignment_Statement =>
7076:                   Actual := Name (Context);
7077:
7078:                when N_Object_Declaration   =>
7079:                   Actual := Defining_Identifier (Context);
7080:
7081:                when others                 =>
7082:                   raise Program_Error;
7083:             end case;
7084:             Handle_Parameter
7085:               (Formal => Get_Called_Entity (Call), Actual => Actual);
7086:          end;
7087:       end if;
```

## flow/flow-control_flow_graph.adb:7186–7215

```ada
7186:    procedure Process_Statement_List
7187:      (L   : List_Id;
7188:       FA  : in out Flow_Analysis_Graphs;
7189:       CM  : in out Connection_Maps.Map;
7190:       Ctx : in out Context)
7191:    is
7192:       P          : Node_Or_Entity_Id;
7193:       Statements : Union_Lists.List := Union_Lists.Empty_List;
7194:       Block      : Graph_Connections;
7195:    begin
7196:       --  Create initial nodes for the statements.
7197:       P := First (L);
7198:       while Present (P) loop
7199:          case Nkind (P) is
7200:             when Nodes_Ignored_By_Process_Statement =>
7201:                --  We completely skip these.
7202:                null;
7203:
7204:             when others                             =>
7205:                Process_Statement (P, FA, CM, Ctx);
7206:                Statements.Append (Union_Id (P));
7207:
7208:          end case;
7209:          Next (P);
7210:       end loop;
7211:
7212:       --  Produce the joined up list.
7213:       Join (FA => FA, CM => CM, Nodes => Statements, Block => Block);
7214:       CM.Insert (Union_Id (L), Block);
7215:
```

## flow/flow-control_flow_graph.adb:7339–7385

```ada
7339:
7340:       --  We chain the folded function checks in front of the actual vertex
7341:       --  for this statement, if necessary. First we create a vertex for
7342:       --  each expression we need to check.
7343:
7344:       while Ctx.Folded_Function_Checks.Length > Folded_Functions_Marker loop
7345:          declare
7346:             Expr        : constant Node_Id :=
7347:               Ctx.Folded_Function_Checks.Last_Element;
7348:             Target_Name : constant Flow_Id :=
7349:               (if Nkind (N) = N_Assignment_Statement
7350:                  and then Has_Target_Names (N)
7351:                then Path_To_Flow_Id (Name (N), FA.B_Scope)
7352:                else Null_Flow_Id);
7353:
7354:             Unchecked : Flow_Id_Sets.Set;
7355:
7356:             V : Flow_Graphs.Vertex_Id;
7357:          begin
7358:             for Ref_Kind in Proof_Ins .. Null_Deps loop
7359:                Unchecked :=
7360:                  Get_Variables
7361:                    (Expr,
7362:                     Scope                => FA.B_Scope,
7363:                     Target_Name          => Target_Name,
7364:                     Fold_Functions       => Ref_Kind,
7365:                     Use_Computed_Globals => not FA.Generating_Globals);
7366:
7367:                if not Unchecked.Is_Empty then
7368:                   Add_Vertex
7369:                     (FA,
7370:                      Make_Sink_Vertex_Attributes
7371:                        (Var_Use       => Unchecked,
7372:                         Is_Fold_Check => True,
7373:                         Is_Assertion  => Ref_Kind = Proof_Ins,
7374:                         Vertex_Ctx    => Ctx.Vertex_Ctx,
7375:                         E_Loc         => Expr),
7376:                      V);
7377:                   L.Append (V);
7378:                end if;
7379:             end loop;
7380:
7381:             Ctx.Folded_Function_Checks.Delete_Last;
7382:          end;
7383:       end loop;
7384:
7385:       --  Then, if we created any new vertices we need to link them in front of
```

## flow/flow-control_flow_graph.adb:7849–7874

```ada
7849:
7850:       --  Sometimes a subprogram is entirely exceptional. In this case we
7851:       --  need to make sure we can still reach the final vertex.
7852:       if not FA.CFG.Non_Trivial_Path_Exists (FA.Start_Vertex, FA.End_Vertex)
7853:       then
7854:          if not FA.Generating_Globals
7855:            and then FA.Kind = Kind_Subprogram
7856:            and then not No_Return (FA.Spec_Entity)
7857:          then
7858:             --  We warn about this, but only for subprograms not
7859:             --  annotated with No_Return.
7860:             Error_Msg_Flow
7861:               (FA       => FA,
7862:                Msg      =>
7863:                  "all paths in & raise exceptions "
7864:                  & "or do not terminate normally",
7865:                N        => FA.Spec_Entity,
7866:                Severity => High_Check_Kind,
7867:                Tag      => Missing_Return,
7868:                F1       => Direct_Mapping_Id (FA.Spec_Entity));
7869:             FA.Has_Only_Exceptional_Paths := True;
7870:          end if;
7871:          FA.CFG.Add_Edge (FA.Start_Vertex, FA.End_Vertex, EC_Default);
7872:       end if;
7873:    end Prune_Exceptional_Paths;
7874:
```

## flow/flow-control_flow_graph.adb:8441–8474

```ada
8441:       Add_Vertex
8442:         (FA,
8443:          (Null_Attributes with delta Error_Location => Body_N),
8444:          FA.Start_Vertex);
8445:       Add_Vertex (FA, Null_Attributes, FA.Helper_End_Vertex);
8446:       Add_Vertex (FA, Null_Attributes, FA.Exceptional_End_Vertex);
8447:       Add_Vertex (FA, Null_Attributes, FA.End_Vertex);
8448:
8449:       --  Create the magic null export vertices: initial and final, and
8450:       --  recognize it as a known variable.
8451:       for Variant in Initial_Value .. Final_Value loop
8452:          declare
8453:             F : constant Flow_Id :=
8454:               Change_Variant (Null_Export_Flow_Id, Variant);
8455:          begin
8456:             Add_Vertex (FA, F, Make_Null_Export_Attributes (F));
8457:          end;
8458:       end loop;
8459:
8460:       FA.All_Vars.Insert (Null_Export_Flow_Id);
8461:
8462:       --  Create initial and final vertices for the parameters of the analyzed
8463:       --  entity, and pull the proof dependencies from their types. Type
8464:       --  invariants from the enclosing unit are pulled only when the entity
8465:       --  is a boundary subprogram.
8466:       case FA.Kind is
8467:          when Kind_Subprogram =>
8468:             for Param of Get_Formals (FA.Spec_Entity) loop
8469:                Create_Initial_And_Final_Vertices (Param, FA);
8470:                Process_Type_Contracts
8471:                  (Etype (Param),
8472:                   FA.B_Scope,
8473:                   Is_Globally_Visible (FA.Spec_Entity),
8474:                   FA.Proof_Dependencies);
```

## flow/flow-control_flow_graph.adb:8490–8530

```ada
8490:       --  Collect globals for the analyzed entity and create initial and final
8491:       --  vertices.
8492:       if not FA.Generating_Globals then
8493:          case FA.Kind is
8494:             when Kind_Subprogram | Kind_Task =>
8495:                declare
8496:                   Globals : Global_Flow_Ids;
8497:
8498:                begin
8499:                   Get_Globals
8500:                     (Subprogram => FA.Spec_Entity,
8501:                      Scope      => FA.B_Scope,
8502:                      Classwide  => False,
8503:                      Globals    => Globals);
8504:
8505:                   --  Convert globals from the In_View/Out_View to Normal_Use
8506:                   --  variants to simplify splitting Inputs and Outputs into
8507:                   --  In/In_Out/Out globals.
8508:
8509:                   Globals :=
8510:                     (Proof_Ins =>
8511:                        Change_Variant (Globals.Proof_Ins, Normal_Use),
8512:                      Inputs    => Change_Variant (Globals.Inputs, Normal_Use),
8513:                      Outputs   =>
8514:                        Change_Variant (Globals.Outputs, Normal_Use));
8515:
8516:                   for G of Globals.Proof_Ins loop
8517:                      Create_Initial_And_Final_Vertices (G, Mode_Proof, FA);
8518:                   end loop;
8519:
8520:                   for G of Globals.Inputs.Difference (Globals.Outputs) loop
8521:                      Create_Initial_And_Final_Vertices (G, Mode_In, FA);
8522:                   end loop;
8523:
8524:                   for G of Globals.Outputs.Difference (Globals.Inputs) loop
8525:                      Create_Initial_And_Final_Vertices (G, Mode_Out, FA);
8526:                   end loop;
8527:
8528:                   for G of Globals.Inputs.Intersection (Globals.Outputs) loop
8529:                      Create_Initial_And_Final_Vertices (G, Mode_In_Out, FA);
8530:                   end loop;
```

## flow/flow-control_flow_graph.adb:8742–8843

```ada
8742:       else
8743:          declare
8744:             V : Flow_Graphs.Vertex_Id;
8745:          begin
8746:             --  We had a null sequence so we need to produce a null node
8747:             Add_Vertex (FA, Null_Node_Attributes, V);
8748:             Init_Block := Trivial_Connection (V);
8749:          end;
8750:       end if;
8751:
8752:       --  Produce flowgraph for the precondition and postcondition, if any
8753:       case FA.Kind is
8754:          when Kind_Subprogram =>
8755:             --  Flowgraph for preconditions and left hand sides of contract
8756:             --  cases.
8757:             declare
8758:                NL : Union_Lists.List;
8759:
8760:             begin
8761:                for Precondition of
8762:                  Get_Precondition_Expressions (FA.Spec_Entity)
8763:                loop
8764:                   Do_Contract_Expression
8765:                     (Precondition, FA, Connection_Map, The_Context);
8766:                   NL.Append (Union_Id (Precondition));
8767:                end loop;
8768:                Join
8769:                  (FA    => FA,
8770:                   CM    => Connection_Map,
8771:                   Nodes => NL,
8772:                   Block => Precon_Block);
8773:             end;
8774:
8775:             --  Flowgraph for postconditions and right hand sides of contract
8776:             --  cases.
8777:             declare
8778:                NL : Union_Lists.List;
8779:             begin
8780:                for Refined in Boolean loop
8781:                   for Postcondition of
8782:                     Get_Postcondition_Expressions (FA.Spec_Entity, Refined)
8783:                   loop
8784:                      Do_Contract_Expression
8785:                        (Postcondition, FA, Connection_Map, The_Context);
8786:                      NL.Append (Union_Id (Postcondition));
8787:                   end loop;
8788:                end loop;
8789:                Join
8790:                  (FA    => FA,
8791:                   CM    => Connection_Map,
8792:                   Nodes => NL,
8793:                   Block => Postcon_Block);
8794:             end;
8795:
8796:             --  Flowgraph for Exceptional_Cases. We pretend that clauses of the
8797:             --  Exceptional_Cases are executed sequentially, because this is a
8798:             --  good enough approximation. In general, we can't precisely tell
8799:             --  which clause will be executed anyway, e.g.:
8800:             --
8801:             --     procedure P
8802:             --       with Exceptional_Cases =>
8803:             --              (Constraint_Error => ...,
8804:             --              (Program_Error    => ...)
8805:             --     is
8806:             --        ...
8807:             --     exception
8808:             --        when others =>
8809:             --           raise;
8810:             --     end P;
8811:
8812:             declare
8813:                Prag  : constant Node_Id :=
8814:                  Get_Pragma (FA.Spec_Entity, Pragma_Exceptional_Cases);
8815:                Aggr  : Node_Id;
8816:                Assoc : Node_Id;
8817:                Expr  : Node_Id;
8818:                NL    : Union_Lists.List;
8819:             begin
8820:                if Present (Prag) then
8821:                   Aggr :=
8822:                     Get_Pragma_Arg
8823:                       (First (Pragma_Argument_Associations (Prag)));
8824:
8825:                   Assoc := First (Component_Associations (Aggr));
8826:                   while Present (Assoc) loop
8827:                      Expr := Expression (Assoc);
8828:                      Do_Contract_Expression
8829:                        (Expr, FA, Connection_Map, The_Context);
8830:                      NL.Append (Union_Id (Expr));
8831:                      Next (Assoc);
8832:                   end loop;
8833:                end if;
8834:
8835:                Join
8836:                  (FA    => FA,
8837:                   CM    => Connection_Map,
8838:                   Nodes => NL,
8839:                   Block => Excep_Cases_Block);
8840:
8841:                --  When an unhandled exception ocurrs, the values of actual
8842:                --  parameters passed by-reference will be transferred to the
8843:                --  caller; for other parameters it doesn't matter what values
```

## flow/flow-control_flow_graph.adb:9180–9258

```ada
9180:               To_Entire_Variables (FA.All_Vars);
9181:          begin
9182:             for V of FA.CFG.Get_Collection (Flow_Graphs.All_Vertices) loop
9183:                declare
9184:                   Atr  : V_Attributes renames FA.Atr (V);
9185:                   Vars : constant Flow_Id_Sets.Set :=
9186:                     To_Entire_Variables
9187:                       (Atr.Variables_Used or Atr.Variables_Defined);
9188:                begin
9189:                   for Var of Vars loop
9190:                      if not Known_Vars.Contains (Var) then
9191:                         FA.GG.Globals.Include (Get_Direct_Mapping_Id (Var));
9192:                      end if;
9193:                   end loop;
9194:                end;
9195:             end loop;
9196:          end;
9197:
9198:          for E of FA.GG.Globals loop
9199:             Create_Initial_And_Final_Vertices
9200:               (Direct_Mapping_Id (E),
9201:                (if Ekind (E) in E_In_Parameter | E_Constant
9202:                 then Mode_In
9203:                 else Mode_In_Out),
9204:                FA);
9205:
9206:             --  Collect accesses to not-synchronized library-level entities
9207:
9208:             if Is_Library_Level_Entity (E) and then not Is_Synchronized (E)
9209:             then
9210:                FA.Tasking (Unsynch_Accesses).Insert (E);
9211:             end if;
9212:          end loop;
9213:
9214:          --  For callees that might have outputs, i.e. procedures and entries,
9215:          --  and specifically those whose Global/Depends contract have not been
9216:          --  "inlined" when building the CFG, we need extra vertices to decide
9217:          --  which of them are called definitively (so that we know that their
9218:          --  outputs will be definitely written) as opposed to conditional (so
9219:          --  that we model such outputs as read-writes).
9220:
9221:          for E of Unresolved_Calls loop
9222:             if (Ekind (E) in E_Procedure | E_Entry
9223:                 or else Is_Function_With_Side_Effects (E))
9224:               and then
9225:                 (not Has_User_Supplied_Globals (E)
9226:                  or else Rely_On_Generated_Global (E, FA.B_Scope))
9227:             then
9228:                declare
9229:                   F_Initial : constant Flow_Id :=
9230:                     Direct_Mapping_Id (E, Initial_Value);
9231:                   F_Final   : constant Flow_Id :=
9232:                     Direct_Mapping_Id (E, Final_Value);
9233:
9234:                   V : Flow_Graphs.Vertex_Id;
9235:
9236:                begin
9237:                   --  Setup the n'initial vertex
9238:                   Add_Vertex
9239:                     (FA,
9240:                      F_Initial,
9241:                      Make_Variable_Attributes
9242:                        (F_Ent => F_Initial, Mode => Mode_In_Out, E_Loc => E),
9243:                      V,
9244:                      Keyed => True);
9245:                   Linkup (FA, V, FA.Start_Vertex);
9246:
9247:                   --  Setup the n'final vertex
9248:                   Add_Vertex
9249:                     (FA,
9250:                      F_Final,
9251:                      Make_Variable_Attributes
9252:                        (F_Ent => F_Final, Mode => Mode_In_Out, E_Loc => E),
9253:                      V,
9254:                      Keyed => True);
9255:                   Linkup (FA, FA.End_Vertex, V);
9256:                end;
9257:             end if;
9258:          end loop;
```

## flow/flow-analysis.adb:1831–1850

```ada
1831:    begin
1832:       if FA.Kind = Kind_Subprogram and then not Has_Effects (FA) then
1833:          Warn_On_Subprogram_With_No_Effect (FA);
1834:          return;
1835:       end if;
1836:
1837:       --  Discover live code
1838:       FA.CFG.DFS
1839:         (Start         => FA.Start_Vertex,
1840:          Include_Start => True,
1841:          Visitor       => Flag_Reachable'Access);
1842:
1843:       for V of FA.PDG.Get_Collection (Flow_Graphs.All_Vertices) loop
1844:          declare
1845:             Key : Flow_Id renames FA.PDG.Get_Key (V);
1846:             Atr : V_Attributes renames FA.Atr (V);
1847:
1848:          begin
1849:             if Atr.Is_Program_Node
1850:               or else (Atr.Is_Parameter and then Key.Variant = Out_View)
```

## flow/flow-analysis.adb:1960–2058

```ada
1960:                                  then Null_Flow_Id
1961:                                  else Direct_Mapping_Id (Called_Entity));
1962:
1963:                               By_What : constant String :=
1964:                                 (if Ekind (Called_Entity) = E_Subprogram_Type
1965:                                  then ""
1966:                                  else " by &");
1967:                               --  Do not print subprogram name if it is a call
1968:                               --  via access-to-subprogram.
1969:
1970:                            begin
1971:                               if Present (Target) then
1972:                                  Error_Msg_Flow
1973:                                    (FA       => FA,
1974:                                     Path     => Mask,
1975:                                     Msg      =>
1976:                                       "& is set"
1977:                                       & By_What
1978:                                       & " but not used after the call",
1979:                                     N        => N,
1980:                                     F1       => Target,
1981:                                     F2       => Callee,
1982:                                     Tag      => Ineffective,
1983:                                     Severity => Warning_Kind,
1984:                                     Vertex   => V);
1985:                               end if;
1986:                            end;
1987:                         end if;
1988:
1989:                      elsif Nkind (N) = N_Assignment_Statement then
1990:                         Error_Msg_Flow
1991:                           (FA       => FA,
1992:                            Path     => Mask,
1993:                            Msg      => "unused assignment",
1994:                            N        => N,
1995:                            Tag      => Ineffective,
1996:                            Severity => Warning_Kind,
1997:                            Vertex   => V);
1998:
1999:                      elsif Nkind (N) = N_Object_Declaration then
2000:
2001:                         --  This warning is ignored for local constants
2002:
2003:                         if not Constant_Present (N) then
2004:
2005:                            if FA.Kind = Kind_Package
2006:                              and then
2007:                                Scope (Defining_Identifier (N)) = FA.Spec_Entity
2008:                              and then
2009:                                No
2010:                                  (Find_In_Initializes
2011:                                     (Defining_Identifier (N)))
2012:                            then
2013:
2014:                               --  This is checked by Check_Initializes_Contract
2015:
2016:                               null;
2017:
2018:                            --  Ignore discriminants initialized at declarations
2019:                            --  of constrained objects.
2020:
2021:                            elsif (for all Def of Atr.Variables_Defined =>
2022:                                     Is_Discriminant (Def))
2023:                            then
2024:                               --  Actually, we handle such discriminants are
2025:                               --  initialized one-by-one and each in its own
2026:                               --  vertex.
2027:                               pragma Assert (Atr.Variables_Defined.Length = 1);
2028:
2029:                               null;
2030:
2031:                            else
2032:                               Error_Msg_Flow
2033:                                 (FA       => FA,
2034:                                  Path     => Mask,
2035:                                  Msg      =>
2036:                                    "initialization of & has no effect",
2037:                                  N        => N,
2038:                                  F1       =>
2039:                                    Direct_Mapping_Id (Defining_Entity (N)),
2040:                                  Tag      => Ineffective,
2041:                                  Severity => Warning_Kind,
2042:                                  Vertex   => V);
2043:                            end if;
2044:
2045:                         end if;
2046:
2047:                      else
2048:                         Error_Msg_Flow
2049:                           (FA       => FA,
2050:                            Path     => Mask,
2051:                            Msg      => "statement has no effect",
2052:                            Severity => Warning_Kind,
2053:                            N        => N,
2054:                            Tag      => Ineffective,
2055:                            Vertex   => V);
2056:                      end if;
2057:                   end;
2058:                end if;
```

## flow/flow-analysis.adb:2370–2402

```ada
2370:
2371:          --  Assemble appropriate message for failed initialization. We deal
2372:          --  with a bunch of special cases first, but if they don't trigger we
2373:          --  create the standard message.
2374:
2375:          if Is_Read_Global_Output then
2376:
2377:             --  In case of a subprogram with an output global which is actually
2378:             --  used as an input in its body, we emit dedicated messages.
2379:
2380:             declare
2381:                Msg : constant String :=
2382:                  "either make & an input in the Global contract or "
2383:                  & (if Has_Async_Readers (Var)
2384:                     then "write to it before use"
2385:                     else "initialize it before use");
2386:             begin
2387:                Error_Msg_Flow
2388:                  (FA            => FA,
2389:                   Msg           =>
2390:                     "& is not an input in the "
2391:                     & "Global contract of subprogram #",
2392:                   Severity      => High_Check_Kind,
2393:                   N             => N,
2394:                   F1            => Var,
2395:                   F2            => Direct_Mapping_Id (FA.Spec_Entity),
2396:                   Tag           => Uninitialized,
2397:                   Continuations =>
2398:                     [Create (Substitute_Message (Msg, N, Var))]);
2399:             end;
2400:
2401:          else
2402:             if Is_Function then
```

## flow/flow-analysis.adb:2550–2603

```ada
2550:                Path  : constant Vertex_Sets.Set :=
2551:                  Mark_Definition_Free_Path (To => V_Goal, Var => Var);
2552:                Conts : Message_Lists.List;
2553:             begin
2554:
2555:                --  ??? only when Is_Final_Use ?
2556:                if Is_Constituent (Var)
2557:                  and then FA.Kind = Kind_Package
2558:                  and then Present (FA.Initializes_N)
2559:                then
2560:                   Conts.Append
2561:                     (Create
2562:                        (Substitute_Message
2563:                           ("initialization of & is specified @",
2564:                            N  => N,
2565:                            F1 =>
2566:                              Direct_Mapping_Id
2567:                                (Encapsulating_State
2568:                                   (Get_Direct_Mapping_Id (Var))),
2569:                            F2 =>
2570:                              Direct_Mapping_Id
2571:                                (if From_Aspect_Specification (FA.Initializes_N)
2572:                                 then Corresponding_Aspect (FA.Initializes_N)
2573:                                 else FA.Initializes_N))));
2574:                end if;
2575:
2576:                Error_Msg_Flow
2577:                  (FA            => FA,
2578:                   Path          => Path,
2579:                   Msg           => To_String (Msg),
2580:                   Details       => To_String (Details),
2581:                   Explanation   => To_String (Explanation),
2582:                   Fix           => To_String (Fix),
2583:                   N             => N,
2584:                   F1            => Var,
2585:                   F2            => Direct_Mapping_Id (FA.Spec_Entity),
2586:                   EF1           => Explanation_F1,
2587:                   FF1           => Fix_F1,
2588:                   FF2           => Fix_F2,
2589:                   Tag           => Uninitialized,
2590:                   Severity      =>
2591:                     (case Kind is
2592:                        when Unknown =>
2593:                          (if Default_Init
2594:                           then Low_Check_Kind
2595:                           else Medium_Check_Kind),
2596:                        when Err     =>
2597:                          (if Default_Init
2598:                           then Medium_Check_Kind
2599:                           else High_Check_Kind)),
2600:                   Vertex        => V_Use,
2601:                   Continuations => Conts);
2602:             end;
2603:          end if;
```

## flow/flow-analysis.adb:2630–2737

```ada
2630:             Parts : in out Flow_Id_Sets.Set)
2631:          is
2632:             Components : Flow_Id_Sets.Set := Get_Components (Var, FA.B_Scope);
2633:          begin
2634:             --  Get_Components returns Var'Extension_Part if Var is classwide
2635:             --  but not if it is a tagged parameter of a subprogram annotated
2636:             --  with Extensions_Visible. In this case, we need to include
2637:             --  Var'Extension_Part in the components of Var because we want to
2638:             --  compress checks on extension parts as we do it for regular
2639:             --  components.
2640:
2641:             if Is_Entire_Variable (Var)
2642:               and then Var.Kind = Direct_Mapping
2643:               and then Var.Variant = Normal_Use
2644:               and then Extensions_Visible (Var, FA.B_Scope)
2645:             then
2646:                Components.Include ((Var with delta Facet => Extension_Part));
2647:             end if;
2648:
2649:             --  If Kind_Checks contains Var, Var is a leaf of the tree
2650:             --  representing the type of its entire variable. Else, we recurse
2651:             --  on the components of Var.
2652:
2653:             if Kind_Checks (Path).Contains (Var) then
2654:                Parts.Insert (Var);
2655:             else
2656:                --  The sets corresponding to Path in Kind_Checks and
2657:                --  Non_Kind_Checks are disjoint. This means that if a part is
2658:                --  in Non_Kind_Checks, then we won't be able to compress the
2659:                --  checks related to its subcomponents in Kind_Checks.
2660:
2661:                declare
2662:                   Path_Position : constant Path_To_Variables_Maps.Cursor :=
2663:                     Non_Kind_Checks.Find (Path);
2664:                begin
2665:                   if not Path_To_Variables_Maps.Has_Element (Path_Position)
2666:                     or else not Non_Kind_Checks (Path_Position).Contains (Var)
2667:                   then
2668:                      --  Var is excluded from Components to avoid infinite
2669:                      --  recursion.
2670:
2671:                      Components.Exclude (Var);
2672:
2673:                      --  Recursively populate Parts with all the uninitialized
2674:                      --  subcomponents of Var, by recursing on the (possibly
2675:                      --  empty) set of components of Var.
2676:
2677:                      for C of Components loop
2678:                         Compress_Checks
2679:                           (Path => Path, Var => C, Parts => Parts);
2680:                      end loop;
2681:
2682:                      --  If Var doesn't have any components, then, since Path
2683:                      --  isn't mapped to Var in either of the maps, it is not
2684:                      --  uninitialized at V_Use. Else, if Parts contains all
2685:                      --  the components of Var, then we can emit the check on
2686:                      --  Var only. Otherwise, we need to emit checks on all the
2687:                      --  uninitialized subcomponents.
2688:
2689:                      if not Components.Is_Empty
2690:                        and then Components.Is_Subset (Parts)
2691:                      then
2692:                         Parts.Difference (Components);
2693:                         Parts.Insert (Var);
2694:                      end if;
2695:                   end if;
2696:                end;
2697:             end if;
2698:          end Compress_Checks;
2699:
2700:          --  Start of processing for Emit_Check_Messages
2701:
2702:       begin
2703:          for P in Kind_Checks.Iterate loop
2704:             declare
2705:                Path      : Path_Vertices renames
2706:                  Path_To_Variables_Maps.Key (P);
2707:                Variables : Flow_Id_Sets.Set renames Kind_Checks (Path);
2708:             begin
2709:                for Var of To_Entire_Variables (Variables) loop
2710:                   declare
2711:                      Parts : Flow_Id_Sets.Set;
2712:                      --  Parts of Var on which we need to emit checks for
2713:                      --  uninitialization.
2714:                   begin
2715:                      Compress_Checks
2716:                        (Path => Path, Var => Var, Parts => Parts);
2717:
2718:                      --  Emit checks on every uninitialized part of Var
2719:
2720:                      for S of Parts loop
2721:                         Emit_Check_Message
2722:                           (Var   => S,
2723:                            Start => Path.Start,
2724:                            V_Use => Path.V_Use,
2725:                            Kind  => Kind);
2726:
2727:                         --  Path is mapped to the parts on which we need
2728:                         --  to emit Kind checks to avoid exploring their
2729:                         --  subcomponents again when emitting checks of
2730:                         --  another kind.
2731:
2732:                         Variables.Include (S);
2733:                      end loop;
2734:                   end;
2735:                end loop;
2736:             end;
2737:          end loop;
```

## flow/flow-analysis.adb:3107–3134

```ada
3107:       begin
3108:          for Child of
3109:            FA.PDG.Get_Collection (V_Initial, Flow_Graphs.Out_Neighbours)
3110:          loop
3111:             declare
3112:                Child_Key : Flow_Id renames FA.DDG.Get_Key (Child);
3113:                Child_Atr : V_Attributes renames FA.Atr (Child);
3114:
3115:             begin
3116:                --  Ignore final uses of non-exported objects
3117:
3118:                if Child_Key.Variant = Final_Value
3119:                  and then
3120:                    not (Child_Atr.Is_Export
3121:                         and then
3122:                           (if Ekind (FA.Spec_Entity) = E_Package
3123:                            then
3124:                              Child_Key.Kind in Direct_Mapping | Record_Field
3125:                              and then
3126:                                Scope (Get_Direct_Mapping_Id (Child_Key))
3127:                                = FA.Spec_Entity))
3128:                then
3129:                   null;
3130:                else
3131:                   if Is_Array (Var) then
3132:
3133:                      Visited.Insert
3134:                        (New_Item => Child,
```

## flow/flow-analysis.adb:3160–3228

```ada
3160:                               V_Use  => Child,
3161:                               Var    => Var);
3162:                         else
3163:                            Update
3164:                              (Checks => Unknown_Checks,
3165:                               Start  => Start,
3166:                               V_Use  => Child,
3167:                               Var    => Var);
3168:                         end if;
3169:
3170:                      --  Otherwise, it is a partial assignment, e.g.
3171:                      --     Arr (X) := Y;
3172:                      --  which is modellled as:
3173:                      --     Arr := (X => Y, others => Arr ("others"));
3174:                      --  and we keep looking for genuine reads of the array.
3175:
3176:                      else
3177:                         Scan_Children
3178:                           (Var,
3179:                            V_Initial            => Child,
3180:                            Possibly_Initialized => True,
3181:                            Visited              => Visited,
3182:                            OK                   => OK);
3183:                      end if;
3184:
3185:                   else
3186:                      if Child_Atr.Variables_Used.Contains (Var) then
3187:                         OK := False;
3188:                         Kind :=
3189:                           (if Might_Be_Initialized
3190:                                 (Var       => Var,
3191:                                  V_Initial => V_Initial,
3192:                                  V_Use     => Child)
3193:                            then Unknown
3194:                            else Err);
3195:
3196:                         if Kind = Err then
3197:                            Update
3198:                              (Checks => Err_Checks,
3199:                               Start  => Start,
3200:                               V_Use  => Child,
3201:                               Var    => Var);
3202:                         else
3203:                            Update
3204:                              (Checks => Unknown_Checks,
3205:                               Start  => Start,
3206:                               V_Use  => Child,
3207:                               Var    => Var);
3208:                         end if;
3209:                      end if;
3210:                   end if;
3211:                end if;
3212:             end;
3213:          end loop;
3214:       end Scan_Children;
3215:
3216:       --  Local variables
3217:
3218:       Used : Flow_Id_Sets.Set;
3219:       --  Objects that are genuinely used by the analysed routine; only for
3220:       --  those we want the "info: initialization proved" messages.
3221:
3222:       Global_OK  : Flow_Id_Sets.Set;
3223:       Global_NOK : Flow_Id_Sets.Set;
3224:       Local_OK   : Flow_Id_Sets.Set;
3225:       Local_NOK  : Flow_Id_Sets.Set;
3226:       --  If all accesses to a given component happen after it is initialized,
3227:       --  then its entire object will appear in the OK set; otherwise, its
3228:       --  entire object will appear in the NOK set.
```

## flow/flow-analysis.adb:3376–3399

```ada
3376:       Emit_Check_Messages
3377:         (Kind            => Err,
3378:          Kind_Checks     => Err_Checks,
3379:          Non_Kind_Checks => Unknown_Checks);
3380:       Emit_Check_Messages
3381:         (Kind            => Unknown,
3382:          Kind_Checks     => Unknown_Checks,
3383:          Non_Kind_Checks => Err_Checks);
3384:
3385:       for Var of Global_OK.Difference (Global_NOK) loop
3386:          Emit_Info_Message_Global (Var);
3387:       end loop;
3388:
3389:       --  We only want info messages about local objects that are actually used
3390:       --  by the analysed subprogram.
3391:
3392:       for Var of Local_OK.Difference (Local_NOK) loop
3393:          if Used.Contains (Var) then
3394:             Emit_Info_Message_Local (Var);
3395:          end if;
3396:       end loop;
3397:    end Find_Use_Of_Uninitialized_Variables;
3398:
3399:    ----------------------------
```

## flow/flow-analysis.adb:4125–4138

```ada
4125:
4126:    begin
4127:       --  If the user has not specified a dependency relation we have no work
4128:       --  to do.
4129:
4130:       if No (Contract_N) then
4131:          return;
4132:       end if;
4133:
4134:       Get_Globals (FA.Spec_Entity, FA.B_Scope, False, Globals);
4135:
4136:       --  Read the user-written Depends
4137:
4138:       User_Deps :=
```

## flow/flow-analysis.adb:4963–4975

```ada
4963:             end if;
4964:          end;
4965:       end if;
4966:
4967:       --  If we are dealing with a generated initializes aspect then we have no
4968:       --  more checks to do.
4969:
4970:       if No (FA.Initializes_N) then
4971:          return;
4972:       end if;
4973:
4974:       for C in DM.Iterate loop
4975:          declare
```

## flow/flow-analysis-antialiasing.adb:666–744

```ada
666:       while List_A.Length > 1 and then List_B.Length > 1 loop
667:
668:          --  Go up the tree one level. If we hit an unchecked conversion or
669:          --  type conversion we 'ignore' it. For example:
670:          --     * R.X  ->  R.X.Y
671:          --     * R    ->  Wibble (R).X
672:          --     * R    ->  Wibble (R)    (if Wibble (R) is the top)
673:
674:          Up_Ignoring_Conversions (List_A);
675:          Up_Ignoring_Conversions (List_B);
676:
677:          Head_A := List_A.First_Element;
678:          Head_B := List_B.First_Element;
679:          pragma Assert (not Is_Root (Nkind (Head_A)));
680:          pragma Assert (not Is_Root (Nkind (Head_B)));
681:
682:          --  Check if we are dealing with any type conversion *now*. If so, we
683:          --  have aliasing.
684:
685:          if Is_Conversion (Head_A) or else Is_Conversion (Head_B) then
686:             Trace_Line ("   -> identical tree followed by conversion");
687:             return Definite_Aliasing;
688:          end if;
689:
690:          --  We have now gone up one level on each side. We need to check the
691:          --  two fields.
692:
693:          if Nkind (Head_A) = Nkind (Head_B) then
694:
695:             --  We definitely need to check this. Some possibilities:
696:             --     R.X         <-->  R.X.Y
697:             --     R.X         <-->  R.Z
698:             --     A (5)       <-->  A (J).Wibble
699:             --     A (1 .. 3)  <-->  A (K .. L)
700:
701:             Trace_Two_Nodes
702:               (Text1 => "   -> checking same structure at ",
703:                Node1 => Head_A,
704:                Text2 => " <--> ",
705:                Node2 => Head_B);
706:
707:             case Nkind (Head_A) is
708:                when N_Selected_Component   =>
709:                   if Entity (Selector_Name (Head_A))
710:                     /= Entity (Selector_Name (Head_B))
711:                   then
712:                      Trace_Line ("   -> selectors differ");
713:                      return No_Aliasing;
714:                   end if;
715:
716:                when N_Indexed_Component    =>
717:                   declare
718:                      Index_A : Node_Id := First (Expressions (Head_A));
719:                      Index_B : Node_Id := First (Expressions (Head_B));
720:                   begin
721:                      while Present (Index_A) loop
722:                         pragma Assert (Present (Index_B));
723:
724:                         case Compile_Time_Compare (Index_A, Index_B, True) is
725:                            when LT | GT | NE      =>
726:                               Trace_Two_Nodes
727:                                 (Text1 => "   -> index ",
728:                                  Node1 => Index_A,
729:                                  Text2 => " and ",
730:                                  Node2 => Index_B,
731:                                  Text3 => " statically differ");
732:                               return No_Aliasing;
733:
734:                            when EQ                =>
735:                               null;
736:
737:                            when LE | GE | Unknown =>
738:                               Warning_Msg_N (Warn_Alias_Array, A);
739:                               Definitive_Result := False;
740:                         end case;
741:
742:                         Next (Index_A);
743:                         Next (Index_B);
744:                      end loop;
```

## flow/flow-analysis-antialiasing.adb:933–1197

```ada
933:    procedure Check_Procedure_Call
934:      (FA : in out Flow_Analysis_Graphs; N : Node_Id)
935:    is
936:       procedure Check_Parameter (Formal : Entity_Id; Actual : Node_Id);
937:       --  Check parameters against other parameters and globals.
938:
939:       procedure Check_Aliasing_In_Call is new
940:         Iterate_Call_Parameters (Check_Parameter);
941:       --  The general idea here is to make sure none of the globals and
942:       --  parameters overlap. If we have a procedure with parameters X, Y and
943:       --  Z and globals A and B, then we check the following:
944:       --
945:       --     X v.s. (Y, Z, A, B)
946:       --     Y v.s. (   Z, A, B)
947:       --     Z v.s. (      A, B)
948:       --
949:       --  In particular we do not check the globals against each other and we
950:       --  do not check combinations of parameters which we have already seen.
951:       --  This is implemented by this procedure having the same loop as
952:       --  Check_Parameter_Against_Parameters_And_Globals and by only checking
953:       --  parameters once we have seen our parameter we compare against.
954:
955:       function Visible_Globals (FS : Flow_Id_Sets.Set) return Node_Sets.Set
956:       with
957:         Post =>
958:           (for all E of Visible_Globals'Result =>
959:              Is_Global_Entity (E)
960:              or else
961:                (Ekind (E) = E_Constant and then not Has_Variable_Input (E)));
962:       --  Returns the subset of FS that is represented by Entity_Ids, which are
963:       --  globals except when a constant without variable input wrongly appears
964:       --  in a user-written contract.
965:
966:       Writes_Or_Reads : Node_Sets.Set;
967:       --  Global outputs and in_outs. For aliasing these behave as OUT and
968:       --  IN_OUT formal parameters, respectively.
969:
970:       Reads_Only : Node_Sets.Set;
971:       --  Global inputs and proof_ins (which for aliasing behave as immutable
972:       --  IN formal parameters). Note that global access types are never
973:       --  regarded as purely mode "in" (unlike the similar case for formal
974:       --  parameters) so are never members of this set.
975:
976:       LHS_Vars : constant Flow_Id_Sets.Set :=
977:         (if Nkind (N) = N_Function_Call
978:            and then Nkind (Parent (N)) = N_Assignment_Statement
979:          then
980:            To_Entire_Variables
981:              (Get_All_Variables
982:                 (N                       => Name (Parent (N)),
983:                  Scope                   => FA.B_Scope,
984:                  Target_Name             => Null_Flow_Id,
985:                  Use_Computed_Globals    => True,
986:                  Assume_In_Expression    => True,
987:                  Expand_Internal_Objects => False))
988:          else Flow_Id_Sets.Empty_Set);
989:       --  Objects referenced from the LHS of the assignment statement where the
990:       --  RHS is a call to function with side effects; when the call happens in
991:       --  an object declaration, there can be no aliasing, because the object
992:       --  can't be referenced on the RHS.
993:
994:       Status : Computed_Aliasing_Result := Impossible;
995:
996:       ---------------------
997:       -- Check_Parameter --
998:       ---------------------
999:
1000:       procedure Check_Parameter (Formal : Entity_Id; Actual : Node_Id) is
1001:          Formal_Is_Immutable : constant Boolean := Is_Immutable (Formal);
1002:
1003:          Other_Formal : Entity_Id := Next_Formal (Formal);
1004:          Other_Actual : Node_Id := Next_Actual (Actual);
1005:          --  Formal/Actual will be checked against formals/actuals that follow
1006:          --  them; this way we check each pair of them exactly once.
1007:
1008:       begin
1009:          while Present (Other_Formal) loop
1010:             pragma Assert (Present (Other_Actual));
1011:
1012:             Check_Node_Against_Node
1013:               (FA       => FA,
1014:                A        => Actual,
1015:                B        => Other_Actual,
1016:                A_Formal => Formal,
1017:                B_Formal => Other_Formal,
1018:                Error_N  => Actual,
1019:                Status   => Status);
1020:
1021:             Next_Formal (Other_Formal);
1022:             Next_Actual (Other_Actual);
1023:          end loop;
1024:
1025:          pragma Assert (No (Other_Actual));
1026:
1027:          --  The rules of SPARK RM 6.4.2(4) are such that we can split the
1028:          --  cases handling read-only globals separately from Output + In_Out
1029:          --  globals.
1030:          --  If a global item is read-only, there cannot be aliasing between it
1031:          --  and the corresponding formal parameter if the latter is either
1032:          --  * immutable; or
1033:          --  * of mode "in" and anonymous access-to-constant type.
1034:          if Formal_Is_Immutable
1035:            or else
1036:              (Ekind (Formal) = E_In_Parameter
1037:               and then Is_Anonymous_Access_To_Constant (Etype (Formal)))
1038:          then
1039:             if not Reads_Only.Is_Empty then
1040:                Trace_Line
1041:                  ("   -> A does not require aa checking against "
1042:                   & "read-only globals");
1043:             end if;
1044:          else
1045:             for G of Reads_Only loop
1046:                Check_Node_Against_Node
1047:                  (FA       => FA,
1048:                   A        => Actual,
1049:                   B        => G,
1050:                   A_Formal => Formal,
1051:                   B_Formal => Empty,
1052:                   Error_N  => Actual,
1053:                   Status   => Status);
1054:             end loop;
1055:          end if;
1056:
1057:          --  From SPARK RM 6.4.2(4):
1058:          --  * If the global item's mode is Output or In_Out, then the
1059:          --    corresponding formal parameter shall be immutable and of a
1060:          --    by-copy type.
1061:          if Formal_Is_Immutable
1062:            and then Is_Conservatively_By_Copy_Type (Formal)
1063:          then
1064:             if not Writes_Or_Reads.Is_Empty then
1065:                Trace_Line
1066:                  ("   -> A does not require aa checking against "
1067:                   & "OUT or IN_OUT globals");
1068:             end if;
1069:          else
1070:             for G of Writes_Or_Reads loop
1071:                Check_Node_Against_Node
1072:                  (FA       => FA,
1073:                   A        => Actual,
1074:                   B        => G,
1075:                   A_Formal => Formal,
1076:                   B_Formal => Empty,
1077:                   Error_N  => Actual,
1078:                   Status   => Status);
1079:             end loop;
1080:          end if;
1081:
1082:          --  For a call to function with side effects, check the parameter
1083:          --  against the function entity and all the objects referenced from
1084:          --  the LHS of the assignment statement which are known by Entity_Id
1085:          --  (because the actual parameter cannot alias with a global object
1086:          --  that is only known by Entity_Name).
1087:
1088:          for LHS_Var of LHS_Vars loop
1089:             if LHS_Var.Kind = Direct_Mapping then
1090:                Check_Node_Against_Node
1091:                  (FA       => FA,
1092:                   A        => Get_Direct_Mapping_Id (LHS_Var),
1093:                   B        => Actual,
1094:                   A_Formal => Get_Called_Entity (N),
1095:                   B_Formal => Formal,
1096:                   Error_N  => Name (Parent (N)),
1097:                   Status   => Status);
1098:             end if;
1099:          end loop;
1100:       end Check_Parameter;
1101:
1102:       ---------------------
1103:       -- Visible_Globals --
1104:       ---------------------
1105:
1106:       function Visible_Globals (FS : Flow_Id_Sets.Set) return Node_Sets.Set is
1107:          Results : Node_Sets.Set;
1108:       begin
1109:          for F of FS loop
1110:             case F.Kind is
1111:                when Direct_Mapping =>
1112:                   Results.Insert (Get_Direct_Mapping_Id (F));
1113:
1114:                --  If we don't have an Entity_Id for a global, then it can't be
1115:                --  referenced as a parameter.
1116:
1117:                when Magic_String   =>
1118:                   null;
1119:
1120:                when others         =>
1121:                   raise Program_Error;
1122:             end case;
1123:          end loop;
1124:
1125:          return Results;
1126:       end Visible_Globals;
1127:
1128:       --  Local variables
1129:
1130:       Called_Thing : constant Entity_Id := Get_Called_Entity (N);
1131:
1132:       Globals : Global_Flow_Ids;
1133:
1134:       use type Node_Sets.Set;
1135:
1136:       --  Start of processing for Check_Procedure_Call
1137:
1138:    begin
1139:       if Ekind (Called_Thing) /= E_Subprogram_Type then
1140:          Get_Globals
1141:            (Subprogram => Called_Thing,
1142:             Scope      => FA.B_Scope,
1143:             Classwide  => Flow_Classwide.Is_Dispatching_Call (N),
1144:             Globals    => Globals);
1145:       end if;
1146:
1147:       Writes_Or_Reads := Visible_Globals (Globals.Outputs);
1148:       Reads_Only :=
1149:         (Visible_Globals (Globals.Inputs) - Writes_Or_Reads)
1150:         or Visible_Globals (Globals.Proof_Ins);
1151:
1152:       --  Check formal parameters against other parameters and globals
1153:
1154:       Check_Aliasing_In_Call (N);
1155:
1156:       --  SPARK RM 6.4.2(6): A call to a function with side effects shall
1157:       --  not reference a ``global_item`` of mode Output or In_Out which
1158:       --  potentially introduces aliasing via parameter passing with an object
1159:       --  referenced from the [left-hand side] name of the enclosing assignment
1160:       --  statement.
1161:
1162:       for LHS_Var of LHS_Vars loop
1163:          for G of Globals.Outputs loop
1164:             if LHS_Var = Change_Variant (G, Normal_Use) then
1165:
1166:                --  For variables refernced by the LHS we might not have their
1167:                --  exact expressions, e.g. when they are referenced as globals
1168:                --  of a function call acting as an array index. We simply
1169:                --  complain that aliasing is possible, because we can't
1170:                --  determine when exactly the aliasing is definite.
1171:                --
1172:                --  We can't call the existing alias detection routine, because
1173:                --  it only works for globals known by Entity_Id and here the
1174:                --  aliasing might occur between globals known by Entity_Name.
1175:
1176:                Error_Msg_Flow
1177:                  (FA       => FA,
1178:                   Msg      => "result of & and global & might be aliased",
1179:                   Severity => Medium_Check_Kind,
1180:                   N        => Name (Parent (N)),
1181:                   F1       => Direct_Mapping_Id (Called_Thing),
1182:                   F2       => G,
1183:                   Tag      => Aliasing,
1184:                   SRM_Ref  => "6.4.2");
1185:
1186:                Status :=
1187:                  Computed_Aliasing_Result'Max (Status, Possible_Aliasing);
1188:             end if;
1189:          end loop;
1190:       end loop;
1191:
1192:       Aliasing_Status.Insert (N, Status);
1193:
1194:       --  ??? Need to check for aliasing between abstract state and computed
1195:       --  globals.
1196:
1197:    end Check_Procedure_Call;
```

## flow/flow_error_messages.adb:192–253

```ada
192:    function Compute_Message
193:      (Msg           : String;
194:       N             : Node_Id;
195:       F1            : Flow_Id := Null_Flow_Id;
196:       F2            : Flow_Id := Null_Flow_Id;
197:       F3            : Flow_Id := Null_Flow_Id;
198:       With_Location : Boolean := True) return String
199:    is
200:       M : Unbounded_String := To_Unbounded_String (Msg);
201:    begin
202:       if Present (F1) then
203:          M := Substitute (M, F1, Sloc (N));
204:          if Present (F2) then
205:             M := Substitute (M, F2, Sloc (N));
206:             if Present (F3) then
207:                M := Substitute (M, F3, Sloc (N));
208:             end if;
209:          end if;
210:       end if;
211:
212:       if With_Location then
213:
214:          --  If we are dealing with an instantiation of a generic we change the
215:          --  message to point at the implementation of the generic and we
216:          --  mention where the generic is instantiated.
217:
218:          declare
219:             Loc     : Source_Ptr := Sloc (Errout.First_Node (N));
220:             File    : Unbounded_String;
221:             Line    : Physical_Line_Number;
222:             Context : Unbounded_String;
223:          begin
224:             loop
225:                exit when Instantiation_Location (Loc) = No_Location;
226:
227:                --  Any change to the strings below should be reflected in GPS
228:                --  plugin spark2014.py, so that the unit for a given message is
229:                --  correctly computed.
230:
231:                Context :=
232:                  To_Unbounded_String
233:                    (if Comes_From_Inlined_Body (Loc)
234:                     then ", in call inlined at "
235:                     elsif Comes_From_Inherited_Pragma (Loc)
236:                     then ", in inherited contract at "
237:                     else ", in instantiation at ");
238:
239:                Loc := Instantiation_Location (Loc);
240:                File := To_Unbounded_String (File_Name (Loc));
241:                Line := Get_Physical_Line_Number (Loc);
242:                Append (M, Context & File & ":" & Image (Integer (Line), 1));
243:             end loop;
244:          end;
245:       end if;
246:       return To_String (M);
247:    end Compute_Message;
248:
249:    ------------------
250:    -- Compute_Sloc --
251:    ------------------
252:
253:    function Compute_Sloc
```

## flow/flow_error_messages.adb:303–499

```ada
303:    procedure Error_Msg_Flow
304:      (E             : Entity_Id;
305:       Msg           : String;
306:       Details       : String := "";
307:       Explanation   : String := "";
308:       Fix           : String := "";
309:       Severity      : Msg_Severity;
310:       N             : Node_Id;
311:       Suppressed    : out Boolean;
312:       F1            : Flow_Id := Null_Flow_Id;
313:       F2            : Flow_Id := Null_Flow_Id;
314:       F3            : Flow_Id := Null_Flow_Id;
315:       EF1           : Flow_Id := Null_Flow_Id;
316:       FF1           : Flow_Id := Null_Flow_Id;
317:       FF2           : Flow_Id := Null_Flow_Id;
318:       Tag           : Flow_Tag_Kind := Empty_Tag;
319:       Explain_Code  : Explain_Code_Kind := EC_None;
320:       SRM_Ref       : String := "";
321:       Tracefile     : String := "";
322:       Continuations : Message_Lists.List := Message_Lists.Empty)
323:    is
324:
325:       Msg2 : constant String :=
326:         Msg
327:         & (if CWE and Severity /= Info_Kind then CWE_Message (Tag) else "")
328:         & (if SRM_Ref'Length > 0 then " (SPARK RM " & SRM_Ref & ")" else "");
329:
330:       Attach_Node : constant Node_Id :=
331:         (if Instantiation_Location (Sloc (Original_Node (N))) = No_Location
332:          then N
333:          else Original_Node (N));
334:       --  Node where the message is attached. For nodes coming from inlining
335:       --  for proof and instantiations of generic units their Slocs is set to
336:       --  the point of inlining/instantiation. We detect such nodes and attach
337:       --  the message to the non-inlined/non-instantiated location, which is
338:       --  kept in Original_Node.
339:       --
340:       --  Note: we cannot blindly call Original_Node, because for aggregate
341:       --  notation (e.g. "Depends => ((Foo, Bar) => null)") it points to
342:       --  N_Aggregate whose Sloc is on the opening bracket (this is perhaps an
343:       --  artefact from parsing) and not to the component entity.
344:
345:       Msg3 : constant String :=
346:         Compute_Message (Msg2, Attach_Node, F1, F2, F3);
347:       Span : constant Source_Span := Compute_Sloc (Attach_Node);
348:       Slc  : constant Source_Ptr := Span.Ptr;
349:
350:       Msg_Str : constant String :=
351:         Msg3
352:         & Source_Ptr'Image (Slc)
353:         & Integer'Image (Msg_Severity'Pos (Severity));
354:
355:       Info : Annotated_Range;
356:
357:       Msg_Id, Ignore_Id : Message_Id;
358:
359:       Dummy    : String_Sets.Cursor;
360:       Inserted : Boolean;
361:
362:       Check_All_Mode : constant Boolean :=
363:         Gnat2Why_Args.Mode = GPM_Check_All
364:         or else Has_Skip_Flow_And_Proof_Annotation (E);
365:       --  True when we are only reporting legiality errors that require flow
366:       --  analysis.
367:
368:       Result : JSON_Result_Type :=
369:         JSON_Result_Type'
370:           (Tag           => To_Unbounded_String (Flow_Tag_Kind'Image (Tag)),
371:            How_Proved    => PC_Flow,
372:            Severity      => Severity,
373:            Span          => Span,
374:            E             => E,
375:            Tracefile     => To_Unbounded_String (Tracefile),
376:            Msg           => Create (Msg3, Explain_Code => Explain_Code),
377:            Details       => To_Unbounded_String (Details),
378:            Continuations => Continuations,
379:            others        => <>);
380:       --  Start of processing for Error_Msg_Flow
381:
382:    begin
383:       --  If the message we are about to emit has already been emitted in the
384:       --  past then do nothing.
385:
386:       Flow_Msgs_Set.Insert
387:         (New_Item => Msg_Str, Position => Dummy, Inserted => Inserted);
388:
389:       if Inserted then
390:
391:          --  If we are in mode check_all then we just report messages related
392:          --  to marking (filtered by Error_Kind severity) and that is why we
393:          --  suppress all the others.
394:
395:          if Check_All_Mode then
396:             case Severity is
397:                when Error_Kind =>
398:                   Suppressed := False;
399:
400:                when others     =>
401:                   Suppressed := True;
402:             end case;
403:          else
404:             case Severity is
405:                when Warning_Kind =>
406:                   Suppressed :=
407:                     Warning_Is_Suppressed (N, Msg3, F1, F2, F3) /= No_String;
408:
409:                   if Suppressed then
410:                      Result.Suppr := Suppressed_Warning;
411:                   end if;
412:
413:                when Info_Kind    =>
414:                   Suppressed := Report_Mode = GPR_Fail;
415:
416:                when Check_Kind   =>
417:                   Check_Is_Annotated (N, Msg3, True, Info);
418:
419:                   if Info.Present then
420:                      Suppressed := True;
421:                      Result.Suppr :=
422:                        Suppressed_Message'
423:                          (Suppression_Kind => Check,
424:                           Msg              => Info.Reason,
425:                           Annot_Kind       => Info.Kind,
426:                           Justification    =>
427:                             To_Unbounded_String (Justified_Message (Msg3)));
428:                      Result.Msg := Create (Justified_Message (Msg3));
429:                      Result.Severity := Info_Kind;
430:
431:                      if Report_Mode /= GPR_Fail then
432:                         Msg_Id := Print_Regular_Msg (Result);
433:                      end if;
434:                   else
435:                      Suppressed := False;
436:                   end if;
437:
438:                when Error_Kind   =>
439:
440:                   --  Set the error flag if we have an error message. Note that
441:                   --  warnings do not count as errors here, they should not
442:                   --  prevent us going to proof. The errout mechanism already
443:                   --  deals with the warnings-as-errors handling for the whole
444:                   --  unit.
445:
446:                   Suppressed := False;
447:                   Found_Flow_Error := True;
448:             end case;
449:          end if;
450:
451:          --  Print the message except when it's suppressed. If command line
452:          --  argument "--limit-line" was given, only issue the warning if it is
453:          --  to be emitted on the specified line (errors are emitted anyway).
454:          --  Additionally, if Details, Explanation and/or Fix are not empty,
455:          --  print them, either on the same line or as continuation messages.
456:
457:          if not Suppressed and then Is_Specified_Line (Slc) then
458:
459:             --  Only display message details when outputting on one line,
460:             --  either as part of automatic testing or inside an IDE, to
461:             --  avoid long unreadable messages for command-line use.
462:
463:             declare
464:                Fix_Msg : constant Message :=
465:                  (if Fix /= ""
466:                   then
467:                     Create
468:                       (Compute_Message
469:                          (Fix, Attach_Node, FF1, FF2, With_Location => False))
470:                   else No_Message);
471:
472:                Explanation_Msg : constant String :=
473:                  (if Explanation /= ""
474:                   then
475:                     Compute_Message
476:                       (Explanation, Attach_Node, EF1, With_Location => False)
477:                   else "");
478:             begin
479:                Result.Explanation := To_Unbounded_String (Explanation_Msg);
480:                Result.Fix := Fix_Msg;
481:                Msg_Id := Print_Regular_Msg (Result);
482:             end;
483:          else
484:             Msg_Id := No_Message_Id;
485:          end if;
486:
487:          --  In general, we want suppressed messages to still appear in
488:          --  statistics; in check_all mode suppressed messages will behave
489:          --  as if they were never emitted.
490:
491:          if not (Check_All_Mode and Suppressed) then
492:             Add_Json_Msg (Flow_Msgs, Result, Msg_Id);
493:          end if;
494:
495:       else
496:          Suppressed := True;
497:       end if;
498:
499:    end Error_Msg_Flow;
```

## flow/flow_error_messages.adb:501–608

```ada
501:    procedure Error_Msg_Flow
502:      (FA            : in out Flow_Analysis_Graphs;
503:       Msg           : String;
504:       Details       : String := "";
505:       Explanation   : String := "";
506:       Fix           : String := "";
507:       Severity      : Msg_Severity;
508:       N             : Node_Id;
509:       F1            : Flow_Id := Null_Flow_Id;
510:       F2            : Flow_Id := Null_Flow_Id;
511:       F3            : Flow_Id := Null_Flow_Id;
512:       EF1           : Flow_Id := Null_Flow_Id;
513:       FF1           : Flow_Id := Null_Flow_Id;
514:       FF2           : Flow_Id := Null_Flow_Id;
515:       Tag           : Flow_Tag_Kind := Empty_Tag;
516:       Explain_Code  : Explain_Code_Kind := EC_None;
517:       SRM_Ref       : String := "";
518:       Path          : Vertex_Sets.Set := Vertex_Sets.Empty_Set;
519:       Vertex        : Flow_Graphs.Vertex_Id := Flow_Graphs.Null_Vertex;
520:       Continuations : Message_Lists.List := Message_Lists.Empty)
521:    is
522:       Vertex_Img : constant String :=
523:         Image (FA.CFG.Vertex_To_Natural (Vertex), 1);
524:       Debug_Msg  : constant String :=
525:         (if Gnat2Why_Args.Flow_Advanced_Debug
526:            and then Vertex /= Flow_Graphs.Null_Vertex
527:          then Msg & " <" & Vertex_Img & ">"
528:          else Msg);
529:
530:       Suppressed : Boolean;
531:
532:       function Write_Tracefile (Set : Vertex_Sets.Set) return String;
533:       --  Writes the tracefile from the given Set and returns the filename
534:
535:       ---------------------
536:       -- Write_Tracefile --
537:       ---------------------
538:
539:       function Write_Tracefile (Set : Vertex_Sets.Set) return String is
540:          FD        : Ada.Text_IO.File_Type;
541:          Tracefile : constant String := Fresh_Trace_File;
542:       begin
543:          Ada.Text_IO.Create (FD, Ada.Text_IO.Out_File, Tracefile);
544:
545:          for V of Set loop
546:             declare
547:                F : Flow_Id renames FA.PDG.Get_Key (V);
548:
549:             begin
550:                --  ??? we should only print vertices whose Atr.Is_Program_Node
551:                --  is True (taking into account various special-cases).
552:                if F.Kind = Direct_Mapping or else FA.Atr (V).Is_Param_Havoc
553:                then
554:                   Ada.Text_IO.Put_Line
555:                     (FD, Vertex_Sloc_Location (FA.PDG, FA.Atr, V));
556:                end if;
557:             end;
558:          end loop;
559:
560:          Ada.Text_IO.Close (FD);
561:
562:          return Tracefile;
563:       end Write_Tracefile;
564:
565:       Tracefile : constant String :=
566:         (if Erroutc.Continuation or else Path.Is_Empty
567:          then ""
568:          else Write_Tracefile (Path));
569:
570:       --  Start of processing for Error_Msg_Flow
571:
572:    begin
573:       Error_Msg_Flow
574:         (E             => FA.Spec_Entity,
575:          Msg           => Debug_Msg,
576:          Details       => Details,
577:          Explanation   => Explanation,
578:          Fix           => Fix,
579:          Severity      => Severity,
580:          N             => N,
581:          Suppressed    => Suppressed,
582:          F1            => F1,
583:          F2            => F2,
584:          F3            => F3,
585:          EF1           => EF1,
586:          FF1           => FF1,
587:          FF2           => FF2,
588:          Tag           => Tag,
589:          SRM_Ref       => SRM_Ref,
590:          Explain_Code  => Explain_Code,
591:          Tracefile     => Tracefile,
592:          Continuations => Continuations);
593:
594:       --  Set the Errors_Or_Warnings flag to True for this entity if we are
595:       --  with anything but a suppressed warning.
596:
597:       if not Suppressed then
598:          FA.Errors_Or_Warnings := True;
599:
600:          if Tag in Data_Dependency_Tag then
601:             FA.Data_Dependency_Errors := True;
602:          end if;
603:
604:          if Tag in Flow_Dependency_Tag then
605:             FA.Flow_Dependency_Errors := True;
606:          end if;
607:       end if;
608:    end Error_Msg_Flow;
```

## flow/flow_error_messages.adb:1013–1018

```ada
1013:    function Fresh_Trace_File return String is
1014:       Result : constant String :=
1015:         Unit_Name & "__flow__" & Image (File_Counter, 1) & ".trace";
1016:    begin
1017:       File_Counter := File_Counter + 1;
1018:       return Result;
```

## flow/flow_error_messages.adb:3960–4116

```ada
3960:    function Print_Regular_Msg (Obj : JSON_Result_Type) return Message_Id is
3961:
3962:       Id            : constant Message_Id := Next_Message_Id;
3963:       My_Conts      : Message_Lists.List := Obj.Continuations;
3964:       Is_Suppressed : constant Boolean := Obj.Suppr /= No_Suppressed_Message;
3965:
3966:       procedure Wrap_Error_Msg (Msg : Message);
3967:
3968:       --------------------
3969:       -- Wrap_Error_Msg --
3970:       --------------------
3971:
3972:       procedure Wrap_Error_Msg (Msg : Message) is
3973:       begin
3974:          Error_Msg
3975:            (Msg
3976:             & (if Ide_Mode then "['#" & Image (Integer (Id), 1) & "]" else ""),
3977:             Obj.Span,
3978:             Obj.Severity,
3979:             (if Is_Suppressed then Message_Lists.Empty_List else My_Conts),
3980:             Error_Entry => False);
3981:       end Wrap_Error_Msg;
3982:
3983:       --  Beginning of processing for Print_Regular_Msg
3984:
3985:    begin
3986:       case Gnat2Why_Args.Output_Mode is
3987:          --  In brief mode, just print the check message
3988:
3989:          when GPO_Brief   =>
3990:             Wrap_Error_Msg (Obj.Msg);
3991:
3992:          --  In oneline mode, append all the extra information to the
3993:          --  main message and print it.
3994:
3995:          when GPO_Oneline =>
3996:             declare
3997:                User_Msg         : constant String :=
3998:                  (if Obj.User_Message /= Null_Unbounded_String
3999:                   then " [user message: " & To_String (Obj.User_Message) & "]"
4000:                   else "");
4001:                CE_Msg           : constant String :=
4002:                  (if Obj.CE /= Null_Unbounded_String
4003:                   then " (e.g. when " & To_String (Obj.CE) & ")"
4004:                   else "");
4005:                Details_Msg      : constant String :=
4006:                  (if not Is_Suppressed
4007:                     and then Obj.Details /= Null_Unbounded_String
4008:                   then " [reason for check: " & To_String (Obj.Details) & "]"
4009:                   else "");
4010:                Explanation_Msg  : constant String :=
4011:                  (if Obj.Explanation /= Null_Unbounded_String
4012:                   then
4013:                     " [possible explanation: "
4014:                     & To_String (Obj.Explanation)
4015:                     & "]"
4016:                   else "");
4017:                Fix_Msg          : constant String :=
4018:                  (if Obj.Fix /= No_Message
4019:                   then " [possible fix: " & To_String (Obj.Fix.Msg) & "]"
4020:                   else "");
4021:                Unproved_Msg_Raw : constant String :=
4022:                  (if not Is_Suppressed
4023:                   then To_User_Msg (Obj.Unproved_Stat)
4024:                   else "");
4025:                Unproved_Msg     : constant String :=
4026:                  (if Unproved_Msg_Raw /= ""
4027:                   then " [" & Unproved_Msg_Raw & "]"
4028:                   else "");
4029:                Msg4             : constant Message :=
4030:                  Obj.Msg
4031:                  & User_Msg
4032:                  & CE_Msg
4033:                  & Details_Msg
4034:                  & Explanation_Msg
4035:                  & Fix_Msg
4036:                  & Unproved_Msg;
4037:             begin
4038:                pragma Assert (Obj.Fix.Names.Is_Empty);
4039:                pragma Assert (Obj.Msg.Secondary_Loc = No_Location);
4040:                Wrap_Error_Msg
4041:                  ((Msg4 with delta Secondary_Loc => Obj.Fix.Secondary_Loc));
4042:             end;
4043:
4044:          --  In pretty mode, print the message, then print all the extra
4045:          --  information as continuation messages. The mechanism to
4046:          --  display messages in Errout is adapted in that case to
4047:          --  display continuation messages on newlines, with a suitable
4048:          --  indentation and no repetion of the  file:line:column: prefix
4049:          --  and info/warning/error information.
4050:
4051:          when GPO_Pretty  =>
4052:
4053:             if Obj.User_Message /= Null_Unbounded_String then
4054:                My_Conts.Append
4055:                  (Create
4056:                     (Erroutc.SGR_Note
4057:                      & "user message: "
4058:                      & Erroutc.SGR_Reset
4059:                      & To_String (Obj.User_Message)));
4060:             end if;
4061:
4062:             if Obj.CE /= "" then
4063:                My_Conts.Append
4064:                  (Create
4065:                     (Erroutc.SGR_Note
4066:                      & "e.g. when "
4067:                      & Erroutc.SGR_Reset
4068:                      & To_String (Obj.CE)));
4069:             end if;
4070:
4071:             if not Is_Suppressed and then Obj.Details /= "" then
4072:                My_Conts.Append
4073:                  (Create
4074:                     (Erroutc.SGR_Note
4075:                      & "reason for check: "
4076:                      & Erroutc.SGR_Reset
4077:                      & To_String (Obj.Details)));
4078:             end if;
4079:
4080:             if Obj.Explanation /= "" then
4081:                My_Conts.Append
4082:                  (Create
4083:                     (Erroutc.SGR_Note
4084:                      & "possible explanation: "
4085:                      & Erroutc.SGR_Reset
4086:                      & To_String (Obj.Explanation)));
4087:             end if;
4088:
4089:             if Obj.Fix /= No_Message then
4090:                My_Conts.Append
4091:                  (Create
4092:                     (Erroutc.SGR_Note
4093:                      & "possible fix: "
4094:                      & Erroutc.SGR_Reset
4095:                      & To_String (Obj.Fix.Msg),
4096:                      Secondary_Loc => Obj.Fix.Secondary_Loc));
4097:             end if;
4098:             if not Is_Suppressed then
4099:                declare
4100:                   Unproved_Msg_Raw : constant String :=
4101:                     To_User_Msg (Obj.Unproved_Stat);
4102:                begin
4103:                   if Unproved_Msg_Raw /= "" then
4104:                      My_Conts.Append
4105:                        (Create
4106:                           (Erroutc.SGR_Note
4107:                            & Unproved_Msg_Raw
4108:                            & Erroutc.SGR_Reset));
4109:                   end if;
4110:                end;
4111:             end if;
4112:             Wrap_Error_Msg (Obj.Msg);
4113:       end case;
4114:
4115:       return Id;
4116:    end Print_Regular_Msg;
```

## flow/flow_error_messages.adb:4446–4688

```ada
4446:    function Substitute
4447:      (S : Unbounded_String; F : Flow_Id; Flag : Source_Ptr)
4448:       return Unbounded_String
4449:    is
4450:       R      : Unbounded_String := Null_Unbounded_String;
4451:       Do_Sub : Boolean := True;
4452:       Quote  : Boolean;
4453:
4454:       procedure Append_Quote;
4455:       --  Append a quote on R if Quote is True
4456:
4457:       ------------------
4458:       -- Append_Quote --
4459:       ------------------
4460:
4461:       procedure Append_Quote is
4462:       begin
4463:          if Quote then
4464:             Append (R, '"');
4465:          end if;
4466:       end Append_Quote;
4467:
4468:       --  Start of processing for Substitute
4469:
4470:    begin
4471:       for Index in Positive range 1 .. Length (S) loop
4472:          if Do_Sub then
4473:             case Element (S, Index) is
4474:                when '&' | '#' | '%' =>
4475:                   Quote := Element (S, Index) in '&' | '#';
4476:
4477:                   case F.Kind is
4478:                      when Null_Value                    =>
4479:                         raise Program_Error;
4480:
4481:                      when Synthetic_Null_Export         =>
4482:                         Append_Quote;
4483:                         Append (R, "null");
4484:
4485:                      when Direct_Mapping | Record_Field =>
4486:                         if Is_Private_Part (F) then
4487:                            Append (R, "private part of ");
4488:                            Append_Quote;
4489:                            Append
4490:                              (R,
4491:                               Flow_Id_To_String
4492:                                 ((F with delta Facet => Normal_Part)));
4493:                         elsif Is_Extension (F) then
4494:                            Append (R, "extension of ");
4495:                            Append_Quote;
4496:                            Append
4497:                              (R,
4498:                               Flow_Id_To_String
4499:                                 ((F with delta Facet => Normal_Part)));
4500:                         elsif Nkind (Get_Direct_Mapping_Id (F)) in N_Entity
4501:                           and then
4502:                             Ekind (Get_Direct_Mapping_Id (F)) = E_Constant
4503:                           and then
4504:                             not Is_Access_Variable
4505:                                   (Etype (Get_Direct_Mapping_Id (F)))
4506:                         then
4507:                            declare
4508:                               Var : constant Entity_Id :=
4509:                                 Get_Direct_Mapping_Id (F);
4510:
4511:                            begin
4512:                               if Nkind (Original_Node (Parent (Var)))
4513:                                 = N_Object_Renaming_Declaration
4514:                               then
4515:                                  Append (R, "renaming of a function call ");
4516:                               else
4517:                                  if Has_Variable_Input (Var) then
4518:
4519:                                     --  Constant of an access-to-variable type
4520:                                     --  that has variable input can be
4521:                                     --  assigned, so it behaves like a
4522:                                     --  variable.
4523:
4524:                                     if Is_Access_Variable (Etype (Var)) then
4525:                                        null;
4526:                                     else
4527:                                        Append
4528:                                          (R, "constant with variable input ");
4529:                                     end if;
4530:                                  else
4531:                                     Append
4532:                                       (R, "constant without variable input ");
4533:                                  end if;
4534:                               end if;
4535:                            end;
4536:                            Append_Quote;
4537:                            Append (R, Flow_Id_To_String (F));
4538:                         elsif Nkind (Get_Direct_Mapping_Id (F))
4539:                           = N_Defining_Operator_Symbol
4540:                         then
4541:                            Append (R, "overriding operator ");
4542:                            Append_Quote;
4543:                            Append (R, Flow_Id_To_String (F));
4544:                         elsif Is_Constituent (F) then
4545:                            declare
4546:                               Buf : Bounded_String;
4547:
4548:                               Constituent_Id : constant Entity_Id :=
4549:                                 Get_Direct_Mapping_Id (F);
4550:
4551:                               State_Id : constant Entity_Id :=
4552:                                 Encapsulating_State (Constituent_Id);
4553:                               --  Encapsulating state of the constituent
4554:
4555:                               Constituent_Scope : constant Entity_Id :=
4556:                                 Scope (Constituent_Id);
4557:                               --  Immediate scope of the constituent
4558:
4559:                               State_Scope : constant Entity_Id :=
4560:                                 Scope (State_Id);
4561:                               --  Immediate scope of the abstract state
4562:
4563:                            begin
4564:                               Append_Quote;
4565:                               Append (R, Flow_Id_To_String (F));
4566:                               Append_Quote;
4567:                               Append (R, " constituent of ");
4568:                               Append_Quote;
4569:
4570:                               --  If the scope of the constituent is different
4571:                               --  from the scope of its abstract state then we
4572:                               --  want to prefix the name of the abstract state
4573:                               --  with its immediate scope.
4574:
4575:                               if State_Scope /= Constituent_Scope then
4576:                                  Append (Buf, Chars (State_Scope));
4577:                                  Errout.Adjust_Name_Case
4578:                                    (Buf, Sloc (State_Scope));
4579:                                  Append (R, To_String (Buf) & ".");
4580:                                  Buf.Length := 0;
4581:                               end if;
4582:
4583:                               --  We append the abstract state. Note that we
4584:                               --  are not using Flow_Id_To_String because of
4585:                               --  the special handling above. In fact, we only
4586:                               --  add a prefix when the immediate scope of the
4587:                               --  constituent is different than the immediate
4588:                               --  scope of the abstract state.
4589:
4590:                               Append (Buf, Chars (State_Id));
4591:                               Errout.Adjust_Name_Case (Buf, Sloc (State_Id));
4592:                               Append (R, To_String (Buf));
4593:                            end;
4594:                         else
4595:                            Append_Quote;
4596:                            Append (R, Flow_Id_To_String (F));
4597:                         end if;
4598:
4599:                      when Magic_String                  =>
4600:                         --  ??? we may want to use __gnat_decode() here instead
4601:                         Append_Quote;
4602:                         declare
4603:                            F_Name_String : constant String :=
4604:                              Strip_Child_Prefixes (To_String (F.Name));
4605:
4606:                         begin
4607:                            if F_Name_String = Name_Of_Heap_Variable then
4608:                               Append
4609:                                 (R,
4610:                                  "memory accessed through objects of "
4611:                                  & "access type");
4612:                            else
4613:                               declare
4614:                                  Index : Positive := F_Name_String'First;
4615:
4616:                               begin
4617:                                  --  Replace __ with . in the magic string
4618:                                  while Index <= F_Name_String'Last loop
4619:                                     case F_Name_String (Index) is
4620:                                        when '_'    =>
4621:                                           if Index < F_Name_String'Last
4622:                                             and then
4623:                                               F_Name_String (Index + 1) = '_'
4624:                                           then
4625:                                              Append (R, '.');
4626:                                              Index := Index + 2;
4627:                                           else
4628:                                              Append (R, '_');
4629:                                              Index := Index + 1;
4630:                                           end if;
4631:
4632:                                        when others =>
4633:                                           Append (R, F_Name_String (Index));
4634:                                           Index := Index + 1;
4635:                                     end case;
4636:                                  end loop;
4637:                               end;
4638:                            end if;
4639:                         end;
4640:                   end case;
4641:
4642:                   Append_Quote;
4643:
4644:                   if Element (S, Index) = '#' then
4645:                      case F.Kind is
4646:                         when Direct_Mapping | Record_Field =>
4647:                            declare
4648:                               N : constant Node_Id :=
4649:                                 Get_Direct_Mapping_Id (F);
4650:
4651:                            begin
4652:                               Erroutc.Msglen := 0;
4653:                               Erroutc.Set_Msg_Insertion_Line_Number
4654:                                 (Sloc (N), Flag);
4655:                               Append (R, ' ');
4656:                               Append
4657:                                 (R, Erroutc.Msg_Buffer (1 .. Erroutc.Msglen));
4658:                            end;
4659:
4660:                         when others                        =>
4661:                            --  Can't really add source information for stuff
4662:                            --  that doesn't come from the tree.
4663:                            null;
4664:                      end case;
4665:                   end if;
4666:
4667:                   Do_Sub := False;
4668:
4669:                when '@'             =>
4670:                   declare
4671:                      N : constant Node_Id := Get_Direct_Mapping_Id (F);
4672:
4673:                   begin
4674:                      Erroutc.Msglen := 0;
4675:                      Erroutc.Set_Msg_Insertion_Line_Number (Sloc (N), Flag);
4676:                      Append (R, Erroutc.Msg_Buffer (1 .. Erroutc.Msglen));
4677:                   end;
4678:
4679:                when others          =>
4680:                   Append (R, Element (S, Index));
4681:             end case;
4682:          else
4683:             Append (R, Element (S, Index));
4684:          end if;
4685:       end loop;
4686:
4687:       return R;
4688:    end Substitute;
```

## flow/flow_error_messages.adb:5013–5029

```ada
5013:    function Vertex_Sloc_Location
5014:      (G   : Flow_Graphs.Graph;
5015:       M   : Attribute_Maps.Map;
5016:       V   : Flow_Graphs.Vertex_Id;
5017:       Sep : Character := ':') return String
5018:    is
5019:       Loc : constant Source_Ptr := Sloc (Error_Location (G, M, V));
5020:       SFI : constant Source_File_Index := Get_Source_File_Index (Loc);
5021:
5022:       Line_Number : constant Logical_Line_Number :=
5023:         Get_Logical_Line_Number (Loc);
5024:    begin
5025:       return
5026:         Get_Name_String (File_Name (SFI))
5027:         & Sep
5028:         & Image (Natural (Line_Number), 1);
5029:    end Vertex_Sloc_Location;
```

## flow/flow.adb:1538–1593

```ada
1538:          end loop;
1539:
1540:          case Container_Scope'(Ekind (E)) is
1541:             when Entry_Kind | E_Function | E_Procedure | E_Task_Type =>
1542:
1543:                --  Only analyse if requested, body is in SPARK and is annotated
1544:                --  with SPARK_Mode => On.
1545:
1546:                Build :=
1547:                  Analysis_Requested (E, With_Inlined => True)
1548:                  and then Entity_In_SPARK (E)
1549:                  and then Entity_Body_In_SPARK (E);
1550:
1551:                --  The above test will be false for null procedures, but we
1552:                --  still need to mark them as skipped if they have the pragma
1553:                --  Skip_Flow_And_Proof.
1554:
1555:                if Entity_In_SPARK (E)
1556:                  and then Is_Null_Procedure (E)
1557:                  and then Has_Skip_Flow_And_Proof_Annotation (E)
1558:                then
1559:                   Skipped_Flow_And_Proof.Insert (E);
1560:                end if;
1561:
1562:             when E_Package                                           =>
1563:                --  Build graphs only when requested, the package is in SPARK
1564:                --  and it is annotated with SPARK_Mode => On.
1565:                --
1566:                --  Do not generate graphs for wrapper packages of subprogram
1567:                --  instantiations since messages emitted on them would be
1568:                --  confusing.
1569:
1570:                Build :=
1571:                  Analysis_Requested (E, With_Inlined => True)
1572:                  and then Entity_In_SPARK (E)
1573:                  and then Entity_Spec_In_SPARK (E)
1574:                  and then not Is_Ignored_Internal (E)
1575:                  and then not Is_Wrapper_Package (E);
1576:
1577:             when E_Protected_Type                                    =>
1578:                --   ??? perhaps we should do something, but now we don't
1579:                Build := False;
1580:          end case;
1581:
1582:          if Build then
1583:             FA_Graphs.Insert
1584:               (Key      => E,
1585:                New_Item =>
1586:                  Flow_Analyse_Entity (E, Generating_Globals => False));
1587:          end if;
1588:
1589:       end Build_Graphs_For_Entity;
1590:
1591:       --  Start of processing for Build_Graphs_For_Analysis
1592:
1593:    begin
```

## flow/flow.adb:1655–1778

```ada
1655:       procedure Check_Contracts (E : Entity_Id);
1656:       --  Check contracts for a given program unit and its nested units
1657:
1658:       ---------------------
1659:       -- Check_Contracts --
1660:       ---------------------
1661:
1662:       procedure Check_Contracts (E : Entity_Id) is
1663:       begin
1664:          for Child of Scope_Map (E) loop
1665:             Check_Contracts (Child);
1666:          end loop;
1667:
1668:          if Ekind (E) in Entry_Kind | E_Function | E_Procedure | E_Task_Type
1669:            and then
1670:              SPARK_Util.Subprograms.Analysis_Requested
1671:                (E, With_Inlined => True)
1672:            and then Entity_Spec_In_SPARK (E)
1673:          then
1674:             --  We emit similar check messages if we analyse a body, so to
1675:             --  avoid duplication don't emit them here.
1676:             --  ??? ideally we should emit all messages from one place
1677:             if not Entity_Body_In_SPARK (E) then
1678:                Analysis.Check_Constant_Global_Contracts (E);
1679:             end if;
1680:
1681:             if not Gnat2Why_Args.Flow_Generate_Contracts then
1682:                Analysis.Check_Required_Contracts (E);
1683:             end if;
1684:
1685:             if Is_Subprogram (E) then
1686:                Check_Classwide_Contracts (E);
1687:             end if;
1688:          end if;
1689:       end Check_Contracts;
1690:
1691:       --  Start of processing for Check_Specification_Contracts
1692:
1693:    begin
1694:       if Present (Root_Entity) then
1695:          Check_Contracts (Root_Entity);
1696:       end if;
1697:    end Check_Specification_Contracts;
1698:
1699:    ------------------------
1700:    -- Flow_Analyse_CUnit --
1701:    ------------------------
1702:
1703:    procedure Flow_Analyse_CUnit
1704:      (GNAT_Root : Node_Id; Found_Error : out Boolean)
1705:    is
1706:       FA_Graphs : Analysis_Maps.Map := Analysis_Maps.Empty_Map;
1707:       --  All analysis results are stashed here in case we need them later
1708:       --  (e.g. for inter-procedural flow analysis).
1709:
1710:       Success : Boolean;
1711:
1712:    begin
1713:       Found_Error := False;
1714:
1715:       Check_Handler_Accesses;
1716:       Check_Specification_Contracts;
1717:
1718:       --  Process entities and construct graphs if necessary
1719:       Build_Graphs_For_Analysis (FA_Graphs => FA_Graphs);
1720:
1721:       --  ??? Perform interprocedural analysis
1722:
1723:       --  Analyse graphs and produce error messages
1724:       for FA of FA_Graphs loop
1725:          pragma Annotate (Xcov, Exempt_On, "Debugging code");
1726:          if Gnat2Why_Args.Flow_Advanced_Debug then
1727:             Write_Line
1728:               (Character'Val (8#33#)
1729:                & "[32m"
1730:                & "Flow analysis (errors) for "
1731:                & FA.Kind'Img
1732:                & " "
1733:                & Character'Val (8#33#)
1734:                & "[1m"
1735:                & Get_Name_String (Chars (FA.Spec_Entity))
1736:                & Character'Val (8#33#)
1737:                & "[0m");
1738:          end if;
1739:          pragma Annotate (Xcov, Exempt_Off);
1740:
1741:          Analysis.Sanity_Check (FA, Success);
1742:
1743:          if Success then
1744:             FA.Dependency_Map := Compute_Dependency_Relation (FA);
1745:
1746:             case FA.Kind is
1747:                when Kind_Task | Kind_Subprogram =>
1748:                   --  In "Prove" mode we do not care about unwritten exports,
1749:                   --  ineffective statements, dead code and incorrect Depends
1750:                   --  aspects.
1751:                   if Gnat2Why_Args.Mode /= GPM_Prove then
1752:                      Analysis.Find_Unwritten_Exports (FA);
1753:                      Analysis.Find_Ineffective_Imports_And_Unused_Objects (FA);
1754:                      Analysis.Find_Ineffective_Statements (FA);
1755:                      Analysis.Find_Stable_Conditions (FA);
1756:                      Analysis.Find_Dead_Code (FA);
1757:                      Analysis.Check_Depends_Contract (FA);
1758:                   end if;
1759:                   Analysis.Check_Aliasing (FA);
1760:                   Analysis.Find_Use_Of_Uninitialized_Variables (FA);
1761:                   if FA.Kind /= Kind_Task then
1762:                      --  We exclude tasks from these checks since they do not
1763:                      --  have pre- and postconditions.
1764:                      Analysis.Check_Prefixes_Of_Attribute_Old (FA);
1765:                      Analysis.Check_CAE_In_Preconditions (FA);
1766:                      --  We exclude tasks from this check since it is only
1767:                      --  relevant for subprograms.
1768:                      Analysis.Check_Always_Terminates (FA);
1769:                      Analysis.Check_Ghost_Subprogram_Outputs (FA);
1770:                   end if;
1771:                   Analysis.Check_Ghost_Calls_Policy (FA);
1772:                   Analysis.Check_Ghost_Terminates (FA);
1773:                   Analysis.Find_Input_Only_Used_In_Assertions (FA);
1774:                   Analysis.Find_Illegal_Reads_Of_Proof_Ins (FA);
1775:                   Analysis.Check_Function_For_Volatile_Effects (FA);
1776:                   Analysis.Check_Output_Constant_After_Elaboration (FA);
1777:
1778:                   --  If no errors or warnings were found during flow
```

## flow/flow.adb:1869–1918

```ada
1869:          --  to the proved dependency; in summary table those messages will
1870:          --  appear as "proved" by flow.
1871:
1872:          case FA.Kind is
1873:             when Kind_Subprogram | Kind_Task =>
1874:                if Present (FA.Global_N) and then not FA.Data_Dependency_Errors
1875:                then
1876:                   Error_Msg_Flow
1877:                     (FA       => FA,
1878:                      Msg      => "data dependencies proved",
1879:                      N        => FA.Global_N,
1880:                      Tag      => Global_Wrong,
1881:                      Severity => Info_Kind);
1882:                end if;
1883:
1884:                if Present (FA.Depends_N) and then not FA.Flow_Dependency_Errors
1885:                then
1886:                   Error_Msg_Flow
1887:                     (FA       => FA,
1888:                      Msg      => "flow dependencies proved",
1889:                      N        => FA.Depends_N,
1890:                      Tag      => Depends_Wrong,
1891:                      Severity => Info_Kind);
1892:                end if;
1893:
1894:             when Kind_Package                =>
1895:                if Present (FA.Initializes_N)
1896:                  and then not FA.Flow_Dependency_Errors
1897:                then
1898:                   Error_Msg_Flow
1899:                     (FA       => FA,
1900:                      Msg      => "flow dependencies proved",
1901:                      N        => FA.Initializes_N,
1902:                      Tag      => Depends_Wrong,
1903:                      Severity => Info_Kind);
1904:                end if;
1905:          end case;
1906:
1907:          --  Keep track of entities whose flow analysis has been "skipped",
1908:          --  i.e. which actually have been analysed, but we only emitted
1909:          --  error and not info/warning/check messages.
1910:
1911:          if Has_Skip_Flow_And_Proof_Annotation (FA.Spec_Entity) then
1912:             Skipped_Flow_And_Proof.Insert (FA.Spec_Entity);
1913:          end if;
1914:       end loop;
1915:
1916:       --  Finally check concurrent accesses. This check is done for the whole
1917:       --  compilation unit.
1918:       Analysis.Check_Concurrent_Accesses (GNAT_Root);
```

## flow/flow_generated_globals-phase_2.adb:2402–2513

```ada
2402:                for Local of Phase_1_Info (Caller).Local_Packages loop
2403:                   --  Use contract from the current iteration of Do_Global;
2404:                   --  this is particularly important when picking writes, but
2405:                   --  for consistency we do this also when picking reads.
2406:
2407:                   --  ??? if Patches was a map, we could just pick what we need
2408:                   --  and not have to scan it.
2409:
2410:                   for Patch of Patches loop
2411:                      if Patch.Entity = Local then
2412:                         Result_Proof_Ins.Union
2413:                           (Patch.Contract.Proper.Proof_Ins);
2414:                         Result_Inputs.Union (Patch.Contract.Proper.Inputs);
2415:                         exit;
2416:                      end if;
2417:                   end loop;
2418:                end loop;
2419:
2420:                --  Similar for child packages
2421:
2422:                if Caller /= Standard_Standard
2423:                  and then Phase_1_Info (Caller).Kind = E_Package
2424:                then
2425:                   for Child of Child_Packages (Caller) loop
2426:                      --  Wrapper packages and generics have no generated
2427:                      --  contracts. ??? they should be filtered earlier
2428:                      pragma
2429:                        Assert
2430:                          (Contracts.Contains (Child)
2431:                           or else
2432:                             Match
2433:                               (Wrapper_Package,
2434:                                Strip_Child_Prefixes (To_String (Child)))
2435:                           or else True);  --  ??? generic package
2436:
2437:                      for Patch of Patches loop
2438:                         if Patch.Entity = Child then
2439:                            Result_Proof_Ins.Union
2440:                              (Patch.Contract.Proper.Proof_Ins);
2441:                            Result_Inputs.Union (Patch.Contract.Proper.Inputs);
2442:                            exit;
2443:                         end if;
2444:                      end loop;
2445:                   end loop;
2446:                end if;
2447:
2448:                --  Now determine genuine calls and collect their globals
2449:                Result.Calls := Categorize_Calls (Caller, Analyzed, Contracts);
2450:
2451:                for Callee of Result.Calls.Definite_Calls loop
2452:                   declare
2453:                      G : constant Global_Names :=
2454:                        Callee_Globals (Callee => Callee, Caller => Folded);
2455:
2456:                   begin
2457:                      Result_Proof_Ins.Union (G.Proof_Ins);
2458:                      Result_Inputs.Union (G.Inputs);
2459:                      Result_Outputs.Union (G.Outputs);
2460:                   end;
2461:                end loop;
2462:
2463:                for Callee of Result.Calls.Proof_Calls loop
2464:                   declare
2465:                      G : constant Global_Names :=
2466:                        Callee_Globals (Callee => Callee, Caller => Folded);
2467:
2468:                   begin
2469:                      Result_Proof_Ins.Union (G.Proof_Ins);
2470:                      Result_Proof_Ins.Union (G.Inputs);
2471:                      Result_Outputs.Union (G.Outputs);
2472:                   end;
2473:                end loop;
2474:
2475:                --  For conditional calls do as above, but also connect the
2476:                --  caller's Inputs vertices to the callee's Outputs vertices.
2477:                --  This models code like:
2478:                --
2479:                --     if Condition then
2480:                --        Output := ...;
2481:                --     end if;
2482:                --
2483:                --  as:
2484:                --
2485:                --     if Condition then
2486:                --        Output := ...;
2487:                --     else
2488:                --        Output := Output;  <<< artificial read of Output
2489:                --     end if;
2490:                --
2491:                --  which adds an dummy assignment.
2492:
2493:                for Callee of Result.Calls.Conditional_Calls loop
2494:                   declare
2495:                      G : constant Global_Names :=
2496:                        Callee_Globals (Callee => Callee, Caller => Folded);
2497:                   begin
2498:                      Result_Proof_Ins.Union (G.Proof_Ins);
2499:                      Result_Inputs.Union (G.Inputs);
2500:                      Result_Inputs.Union (G.Outputs);
2501:                      Result_Outputs.Union (G.Outputs);
2502:                   end;
2503:                end loop;
2504:
2505:                --  Post-processing
2506:                Result_Proof_Ins.Difference (Result_Inputs);
2507:
2508:                declare
2509:                   Proof_Ins_Outs : constant Name_Sets.Set :=
2510:                     Result_Proof_Ins and Result_Outputs;
2511:                begin
2512:                   Result_Proof_Ins.Difference (Proof_Ins_Outs);
2513:                   Result_Inputs.Union (Proof_Ins_Outs);
```

## flow/flow_generated_globals-phase_2.adb:2536–2633

```ada
2536:             for Child of Traversal.Scope_Map (Folded) loop
2537:                Fold (Child, Analyzed, Contracts, Patches);
2538:             end loop;
2539:
2540:             --  See comment above that explains why Original is not a renaming
2541:             if Contracts.Contains (Folded) then
2542:                Original := Contracts (Folded);
2543:             else
2544:                return;
2545:             end if;
2546:
2547:             --  First we resolve globals coming from the callees...
2548:             Update := Collect (Folded);
2549:
2550:             --  ... and then up-project them as necessary
2551:
2552:             Up_Project
2553:               (Update.Refined,
2554:                Update.Proper,
2555:                (Ent => Folded, Part => Visible_Part));
2556:
2557:             pragma Assert (Phase_1_Info.Contains (Folded));
2558:
2559:             --  Handle package Initializes aspect
2560:             if Folded /= Standard_Standard
2561:               and then Phase_1_Info (Folded).Kind = E_Package
2562:             then
2563:                declare
2564:                   P : Partial_Contract renames Phase_1_Info (Folded);
2565:
2566:                   Projected, Partial : Name_Sets.Set;
2567:
2568:                begin
2569:                   --  What has been initialized stays initialized
2570:
2571:                   Update.Refined_Initializes := Original.Refined_Initializes;
2572:
2573:                   --  Then it is extended by pure outputs of subprograms called
2574:                   --  when elaborating the current package.
2575:
2576:                   Update.Refined_Initializes.Union
2577:                     ((Update.Refined.Outputs - Update.Refined.Inputs)
2578:                      and States_And_Objects (Folded));
2579:
2580:                   --  Pull objects initialized in child packages into own
2581:                   --  refined outputs, so that Part_Of constituents declared
2582:                   --  in child units contribute to the initialization of
2583:                   --  Abstract_States declared in the parent.
2584:                   --  ??? generic child units should be filtered earlier
2585:
2586:                   for Child of Child_Packages (Folded) loop
2587:                      --  Pick the Initializes contract computed in the current
2588:                      --  iteration of Do_Global.
2589:                      --  ??? if Patches was a map, we could just pick what we
2590:                      --  need and not have to scan it.
2591:
2592:                      for Patch of Patches loop
2593:                         if Patch.Entity = Child then
2594:                            Update.Refined_Initializes.Union
2595:                              (Patch.Contract.Initializes);
2596:                            exit;
2597:                         end if;
2598:                      end loop;
2599:                   end loop;
2600:
2601:                   --  Similar for nested packages
2602:
2603:                   for Local of Phase_1_Info (Folded).Local_Packages loop
2604:                      --  Pick the Initializes contract computed in the current
2605:                      --  iteration of Do_Global.
2606:
2607:                      for Patch of Patches loop
2608:                         if Patch.Entity = Local then
2609:                            Update.Refined_Initializes.Union
2610:                              (Patch.Contract.Initializes);
2611:                            exit;
2612:                         end if;
2613:                      end loop;
2614:                   end loop;
2615:
2616:                   Up_Project
2617:                     (Update.Refined_Initializes,
2618:                      Folded_Scope,
2619:                      Projected,
2620:                      Partial);
2621:
2622:                   for State of Partial loop
2623:                      if Is_Fully_Contained
2624:                           (State, Update.Refined_Initializes, Folded_Scope)
2625:                      then
2626:                         Projected.Include (State);
2627:                      end if;
2628:                   end loop;
2629:
2630:                   Name_Sets.Move
2631:                     (Target => Update.Initializes, Source => Projected);
2632:
2633:                   Initialized_Vars_And_States.Union (Update.Initializes);
```

## flow/flow_generated_globals-phase_2.adb:2974–3015

```ada
2974:
2975:          procedure Strip_Constants
2976:            (From : in out Flow_Names; Constant_Graph : Constant_Graphs.Graph)
2977:          is
2978:
2979:             procedure Strip (From : in out Global_Names);
2980:             procedure Strip (From : in out Name_Sets.Set)
2981:             with Post => From.Is_Subset (From'Old);
2982:
2983:             -----------
2984:             -- Strip --
2985:             -----------
2986:
2987:             procedure Strip (From : in out Global_Names) is
2988:             begin
2989:                Strip (From.Proof_Ins);
2990:                Strip (From.Inputs);
2991:             end Strip;
2992:
2993:             procedure Strip (From : in out Name_Sets.Set) is
2994:                Filtered : Name_Sets.Set;
2995:             begin
2996:                for E of From loop
2997:                   if Constant_Calls.Contains (E) then
2998:                      if Resolved_To_Variable_Input (E, Constant_Graph) then
2999:                         Filtered.Insert (E);
3000:                      end if;
3001:                   else
3002:                      Filtered.Insert (E);
3003:                   end if;
3004:                end loop;
3005:
3006:                Name_Sets.Move (Target => From, Source => Filtered);
3007:             end Strip;
3008:
3009:             --  Start of processing for Strip_Constants
3010:
3011:          begin
3012:             Strip (From.Proper);
3013:             Strip (From.Refined);
3014:             Strip (From.Initializes);
3015:          end Strip_Constants;
```

## flow/flow_generated_globals-phase_2.adb:4134–4301

```ada
4134:          loop
4135:             if not Todo.Is_Empty then
4136:                declare
4137:                   Pick : constant Entity_Name :=
4138:                     Name_Sets.Element (Todo.First);
4139:
4140:                begin
4141:                   Done.Insert (Pick);
4142:
4143:                   if Contracts.Contains (Pick)
4144:                     and then Scope_Within_Or_Same (Pick, Analyzed)
4145:                   then
4146:                      Todo.Union (Contracts (Pick).Calls.Definite_Calls - Done);
4147:                   end if;
4148:
4149:                   Todo.Delete (Pick);
4150:                end;
4151:             else
4152:                exit;
4153:             end if;
4154:          end loop;
4155:
4156:          pragma Assert (Original.Definite_Calls.Is_Subset (Of_Set => Done));
4157:
4158:          Name_Sets.Move (Target => O_Definite, Source => Done);
4159:       end Find_Definitive_Calls;
4160:
4161:       Find_Conditional_Calls : declare
4162:          type Calls is record
4163:             Conditional, Definite : Name_Sets.Set;
4164:          end record;
4165:
4166:          Todo : Calls :=
4167:            (Conditional => Original.Conditional_Calls,
4168:             Definite    => Original.Definite_Calls);
4169:
4170:          Done : Calls;
4171:
4172:       begin
4173:          loop
4174:             if not Todo.Conditional.Is_Empty then
4175:                declare
4176:                   Pick : constant Entity_Name :=
4177:                     Name_Sets.Element (Todo.Conditional.First);
4178:
4179:                begin
4180:                   Done.Conditional.Insert (Pick);
4181:
4182:                   if Contracts.Contains (Pick)
4183:                     and then Scope_Within_Or_Same (Pick, Analyzed)
4184:                   then
4185:                      declare
4186:                         Picked : Call_Names renames Contracts (Pick).Calls;
4187:
4188:                      begin
4189:                         Todo.Conditional.Union
4190:                           ((Picked.Conditional_Calls or Picked.Definite_Calls)
4191:                            - Done.Conditional);
4192:                      end;
4193:                   end if;
4194:
4195:                   Todo.Conditional.Delete (Pick);
4196:                end;
4197:             elsif not Todo.Definite.Is_Empty then
4198:                declare
4199:                   Pick : constant Entity_Name :=
4200:                     Name_Sets.Element (Todo.Definite.First);
4201:
4202:                begin
4203:                   Done.Definite.Insert (Pick);
4204:
4205:                   if Contracts.Contains (Pick)
4206:                     and then Scope_Within_Or_Same (Pick, Analyzed)
4207:                   then
4208:                      declare
4209:                         Picked : Call_Names renames Contracts (Pick).Calls;
4210:
4211:                      begin
4212:                         Todo.Conditional.Union
4213:                           (Picked.Conditional_Calls - Done.Conditional);
4214:
4215:                         Todo.Definite.Union
4216:                           (Picked.Definite_Calls - Done.Definite);
4217:                      end;
4218:                   end if;
4219:
4220:                   Todo.Definite.Delete (Pick);
4221:                end;
4222:             else
4223:                exit;
4224:             end if;
4225:          end loop;
4226:
4227:          pragma
4228:            Assert
4229:              (Original.Conditional_Calls.Is_Subset
4230:                 (Of_Set => Done.Conditional));
4231:
4232:          Name_Sets.Move (Target => O_Conditional, Source => Done.Conditional);
4233:       end Find_Conditional_Calls;
4234:
4235:       Find_Proof_Calls : declare
4236:          type Calls is record
4237:             Proof, Other : Name_Sets.Set;
4238:          end record;
4239:
4240:          Todo : Calls :=
4241:            (Proof => Original.Proof_Calls,
4242:             Other => Original.Conditional_Calls or Original.Definite_Calls);
4243:
4244:          Done : Calls;
4245:
4246:       begin
4247:          loop
4248:             if not Todo.Proof.Is_Empty then
4249:                declare
4250:                   Pick : constant Entity_Name :=
4251:                     Name_Sets.Element (Todo.Proof.First);
4252:
4253:                begin
4254:                   Done.Proof.Insert (Pick);
4255:
4256:                   if Contracts.Contains (Pick)
4257:                     and then Scope_Within_Or_Same (Pick, Analyzed)
4258:                   then
4259:                      declare
4260:                         Picked : Call_Names renames Contracts (Pick).Calls;
4261:
4262:                      begin
4263:                         Todo.Proof.Union
4264:                           ((Picked.Proof_Calls
4265:                             or Picked.Conditional_Calls
4266:                             or Picked.Definite_Calls)
4267:                            - Done.Proof);
4268:                      end;
4269:                   end if;
4270:
4271:                   Todo.Proof.Delete (Pick);
4272:                end;
4273:             elsif not Todo.Other.Is_Empty then
4274:                declare
4275:                   Pick : constant Entity_Name :=
4276:                     Name_Sets.Element (Todo.Other.First);
4277:
4278:                begin
4279:                   Done.Other.Insert (Pick);
4280:
4281:                   if Contracts.Contains (Pick)
4282:                     and then Scope_Within_Or_Same (Pick, Analyzed)
4283:                   then
4284:                      declare
4285:                         Picked : Call_Names renames Contracts (Pick).Calls;
4286:
4287:                      begin
4288:                         Todo.Proof.Union (Picked.Proof_Calls - Done.Proof);
4289:
4290:                         Todo.Other.Union
4291:                           ((Picked.Conditional_Calls or Picked.Definite_Calls)
4292:                            - Done.Other);
4293:                      end;
4294:                   end if;
4295:
4296:                   Todo.Other.Delete (Pick);
4297:                end;
4298:             else
4299:                exit;
4300:             end if;
4301:          end loop;
```

## flow/flow_generated_globals-phase_2.adb:4535–4537

```ada
4535:       for Var of Vars loop
4536:          Projected.Union (Down_Project (Var, Caller));
4537:       end loop;
```

## utils/errout_wrapper.adb:17–17

```ada
17:    Message_Id_Counter : Message_Id := 0;
```

## utils/errout_wrapper.adb:76–190

```ada
76:    procedure Add_Json_Msg
77:      (Msg_List : in out GNATCOLL.JSON.JSON_Array;
78:       Obj      : JSON_Result_Type;
79:       Msg_Id   : Message_Id := No_Message_Id)
80:    is
81:       Value : constant JSON_Value := Create_Object;
82:       File  : constant String := File_Name (Obj.Span.Ptr);
83:       Line  : constant Natural :=
84:         Positive (Get_Logical_Line_Number (Obj.Span.Ptr));
85:       Col   : constant Natural := Positive (Get_Column_Number (Obj.Span.Ptr));
86:
87:    begin
88:       Set_Field (Value, "file", File);
89:       Set_Field (Value, "line", Line);
90:       Set_Field (Value, "col", Col);
91:       Set_Field (Value, "message", To_JSON (Obj.Msg));
92:
93:       if Obj.Msg.Secondary_Loc /= No_Location then
94:          declare
95:             Locations     : JSON_Array;
96:             Location      : constant JSON_Value := Create_Object;
97:             Phys_Location : constant JSON_Value := Create_Object;
98:             Region        : constant JSON_Value := Create_Object;
99:             File          : constant String :=
100:               File_Name (Obj.Msg.Secondary_Loc);
101:             Line          : constant Natural :=
102:               Positive (Get_Logical_Line_Number (Obj.Msg.Secondary_Loc));
103:             Col           : constant Natural :=
104:               Positive (Get_Column_Number (Obj.Msg.Secondary_Loc));
105:          begin
106:             Set_Field (Phys_Location, "uri", File);
107:             Set_Field (Region, "startLine", Line);
108:             Set_Field (Region, "startColumn", Col);
109:             Set_Field (Phys_Location, "region", Region);
110:             Set_Field (Location, "physicalLocation", Phys_Location);
111:             Set_Field (Location, "id", Integer'(0));
112:             Append (Locations, Location);
113:             Set_Field (Value, "relatedLocations", Locations);
114:          end;
115:       end if;
116:
117:       if Obj.Suppr.Suppression_Kind in Warning | Check then
118:          declare
119:             Suppr_Reason : constant String :=
120:               (if Obj.Suppr.Suppression_Kind = Check
121:                then To_String (Obj.Suppr.Msg)
122:                else "");
123:          begin
124:             Set_Field (Value, "suppressed", Suppr_Reason);
125:             if Obj.Suppr.Suppression_Kind = Check then
126:                Set_Field
127:                  (Value, "annot_kind", To_String (Obj.Suppr.Annot_Kind));
128:                Set_Field
129:                  (Value, "justif_msg", To_String (Obj.Suppr.Justification));
130:             end if;
131:          end;
132:       end if;
133:
134:       Set_Field (Value, "rule", Obj.Tag);
135:       Set_Field (Value, "severity", To_JSON (Obj.Severity));
136:       if Present (Obj.E) then
137:          Set_Field
138:            (Value, "entity", To_JSON (Entity_To_Subp_Assumption (Obj.E)));
139:       end if;
140:       Set_Field (Value, "check_tree", Obj.Check_Tree);
141:       Set_Field (Value, "unproved_status", To_JSON (Obj.Unproved_Stat));
142:
143:       if Obj.VC_Loc /= No_Location then
144:          declare
145:             VC_File : constant String := File_Name (Obj.VC_Loc);
146:             VC_Line : constant Natural :=
147:               Positive (Get_Logical_Line_Number (Obj.VC_Loc));
148:             VC_Col  : constant Natural :=
149:               Positive (Get_Column_Number (Obj.VC_Loc));
150:          begin
151:             --  Note that vc_file already exists
152:             Set_Field (Value, "check_file", VC_File);
153:             Set_Field (Value, "check_line", VC_Line);
154:             Set_Field (Value, "check_col", VC_Col);
155:          end;
156:       end if;
157:
158:       if Obj.Tracefile /= "" then
159:          Set_Field (Value, "tracefile", Obj.Tracefile);
160:       end if;
161:
162:       if not Obj.Cntexmp.Map.Is_Empty then
163:          Set_Field (Value, "cntexmp", To_JSON (Obj.Cntexmp.Map));
164:       end if;
165:
166:       if not Obj.Cntexmp.Input_As_JSON.Input_As_JSON.Is_Empty then
167:          Set_Field
168:            (Value, "cntexmp_value", To_JSON (Obj.Cntexmp.Input_As_JSON));
169:       end if;
170:
171:       if Obj.VC_File /= "" then
172:          Set_Field (Value, "vc_file", Obj.VC_File);
173:       end if;
174:
175:       if Obj.Editor_Cmd /= "" then
176:          Set_Field (Value, "editor_cmd", Obj.Editor_Cmd);
177:       end if;
178:
179:       if Msg_Id /= No_Message_Id then
180:          Set_Field (Value, "msg_id", Natural (Msg_Id));
181:       end if;
182:
183:       Set_Field (Value, "how_proved", To_JSON (Obj.How_Proved));
184:
185:       if not Obj.Stats.Is_Empty then
186:          Set_Field (Value, "stats", To_JSON (Obj.Stats));
187:       end if;
188:
189:       Append (Msg_List, Value);
190:    end Add_Json_Msg;
```

## utils/errout_wrapper.adb:399–530

```ada
399:    procedure Error_Msg
400:      (Msg           : Message;
401:       Span          : Source_Span;
402:       Kind          : Msg_Severity := Error_Kind;
403:       Continuations : Message_Lists.List := Message_Lists.Empty;
404:       Error_Entry   : Boolean := True)
405:    is
406:
407:       procedure Span_Locate (Msg : String; First_Node : Node_Id);
408:       --  Procedure that holds the call to the errout backend, to be used with
409:       --  the generic Print procedure. The Span is used to locate the error
410:       --  message. First_Node is ignored.
411:
412:       -----------------
413:       -- Span_Locate --
414:       -----------------
415:
416:       procedure Span_Locate (Msg : String; First_Node : Node_Id) is
417:          pragma Unreferenced (First_Node);
418:       begin
419:          --  ??? We force the message to appear even if not on the main unit.
420:          --  This is to not hide messages that come from generic instances,
421:          --  inherited contracts, or inlined subprograms.
422:          --  This should only be done for flow/proof messages, and currently
423:          --  the Error_Msg procedure is only called by the proof machinery.
424:
425:          Errout.Error_Msg (Msg & "!!", Span);
426:       end Span_Locate;
427:
428:       procedure Local_Print_Result is new Print (Span_Locate);
429:
430:       Result : constant JSON_Result_Type :=
431:         (Severity => Kind,
432:          Tag      => To_Unbounded_String ("error"),
433:          Span     => Span,
434:          Msg      => Msg,
435:          others   => <>);
436:
437:       --  Beginning of processing for Error_Msg
438:
439:    begin
440:       if Error_Entry then
441:          Add_Json_Msg (Warnings_Errors, Result);
442:       end if;
443:       Local_Print_Result (Msg, Kind, Continuations => Continuations);
444:    end Error_Msg;
445:
446:    -----------------
447:    -- Error_Msg_N --
448:    -----------------
449:
450:    procedure Error_Msg_N
451:      (Msg           : Message;
452:       N             : Node_Id;
453:       Kind          : Msg_Severity := Error_Kind;
454:       First         : Boolean := False;
455:       Continuations : Message_Lists.List := Message_Lists.Empty;
456:       Error_Entry   : Boolean := True)
457:    is
458:
459:       procedure Node_Locate (Msg : String; First_Node : Node_Id);
460:       --  Procedure that holds the call to the errout backend, to be used with
461:       --  the generic Print procedure. The node N is used to locate the
462:       --  message, but Error_Msg_FE is called if First is set to True.
463:
464:       -----------------
465:       -- Node_Locate --
466:       -----------------
467:
468:       procedure Node_Locate (Msg : String; First_Node : Node_Id) is
469:       begin
470:          if First then
471:             Errout.Error_Msg_FE (Msg, N, First_Node);
472:          else
473:             Errout.Error_Msg_NE (Msg, N, First_Node);
474:          end if;
475:       end Node_Locate;
476:
477:       procedure Local_Print_Result is new Print (Node_Locate);
478:
479:       My_Msg   : constant Message := Add_Default_Name (Msg, N);
480:       My_Conts : Message_Lists.List;
481:       Result   : JSON_Result_Type :=
482:         (Severity => Kind,
483:          Tag      => To_Unbounded_String ("error"),
484:          Span     => To_Span (Sloc (N)),
485:          Msg      => My_Msg,
486:          others   => <>);
487:    begin
488:       for Msg of Continuations loop
489:          My_Conts.Append (Add_Default_Name (Msg, N));
490:       end loop;
491:       Result.Continuations := My_Conts;
492:       if Error_Entry then
493:          Add_Json_Msg (Warnings_Errors, Result);
494:       end if;
495:       Local_Print_Result (My_Msg, Kind, Continuations => My_Conts);
496:    end Error_Msg_N;
497:
498:    -----------------
499:    -- Error_Msg_N --
500:    -----------------
501:
502:    procedure Error_Msg_N
503:      (Msg           : String;
504:       N             : Node_Id;
505:       Kind          : Msg_Severity := Error_Kind;
506:       Names         : Node_Lists.List := Node_Lists.Empty;
507:       Secondary_Loc : Source_Ptr := No_Location;
508:       Explain_Code  : Explain_Code_Kind := EC_None;
509:       First         : Boolean := False;
510:       Continuations : String_Lists.List := String_Lists.Empty)
511:    is
512:       Conts : Message_Lists.List := Message_Lists.Empty;
513:    begin
514:       for S of Continuations loop
515:          Conts.Append (Create (S));
516:       end loop;
517:       Error_Msg_N
518:         (Create (Msg, Names, Secondary_Loc, Explain_Code),
519:          N,
520:          Kind,
521:          First         => First,
522:          Continuations => Conts);
523:    end Error_Msg_N;
524:
525:    ------------
526:    -- Escape --
527:    ------------
528:
529:    function Escape (S : String) return String is
530:       R : Unbounded_String := Null_Unbounded_String;
```

## utils/errout_wrapper.adb:599–669

```ada
599:    function Next_Message_Id return Message_Id is
600:       Result : constant Message_Id := Message_Id_Counter;
601:    begin
602:       Message_Id_Counter := @ + 1;
603:       return Result;
604:    end Next_Message_Id;
605:
606:    ------------------
607:    -- Node_To_Name --
608:    ------------------
609:
610:    function Node_To_Name (N : Node_Id) return String is
611:    begin
612:       case Nkind (N) is
613:          when N_Pragma =>
614:             return Raw_Source_Name (Pragma_Identifier (N));
615:
616:          when others   =>
617:             return Raw_Source_Name (N);
618:       end case;
619:    end Node_To_Name;
620:
621:    ----------------
622:    -- Tag_Suffix --
623:    ----------------
624:
625:    function Tag_Suffix (Kind : Misc_Warning_Kind) return String is
626:    begin
627:       if Warning_Doc_Switch then
628:          return " [" & Kind_Name (Kind) & "]";
629:       else
630:          return "";
631:       end if;
632:    end Tag_Suffix;
633:
634:    -------------
635:    -- To_JSON --
636:    -------------
637:
638:    function To_JSON (Kind : Msg_Severity) return GNATCOLL.JSON.JSON_Value is
639:       S : constant String :=
640:         (case Kind is
641:            when Error_Kind        => "error",
642:            when Warning_Kind      => "warning",
643:            when Info_Kind         => "info",
644:            when High_Check_Kind   => "high",
645:            when Medium_Check_Kind => "medium",
646:            when Low_Check_Kind    => "low");
647:    begin
648:       return GNATCOLL.JSON.Create (S);
649:    end To_JSON;
650:
651:    function To_JSON (M : Message) return JSON_Value is
652:       Result               : constant JSON_Value := Create_Object;
653:       Contains_Placeholder : Boolean;
654:       Msg_Text             : constant String :=
655:         To_SARIF_Msg_Text (M.Msg, Contains_Placeholder);
656:    begin
657:       Set_Field (Result, "text", Msg_Text);
658:       if not M.Names.Is_Empty and then Contains_Placeholder then
659:          declare
660:             Args : JSON_Array;
661:          begin
662:             for Node of M.Names loop
663:                Append (Args, Create (Node_To_Name (Node)));
664:             end loop;
665:             Set_Field (Result, "arguments", Args);
666:          end;
667:       end if;
668:       return Result;
669:    end To_JSON;
```

## utils/errout_wrapper.adb:852–918

```ada
852:    procedure Warning_Msg_N
853:      (Kind          : Misc_Warning_Kind;
854:       N             : Node_Id;
855:       Extra_Message : String := "";
856:       Names         : Node_Lists.List := Node_Lists.Empty;
857:       Secondary_Loc : Source_Ptr := No_Location;
858:       Explain_Code  : Explain_Code_Kind := EC_None;
859:       First         : Boolean := False;
860:       Continuations : Message_Lists.List := Message_Lists.Empty) is
861:    begin
862:       Warning_Msg_N
863:         (Kind,
864:          N,
865:          Create
866:            (Warning_Message (Kind) & Extra_Message & Tag_Suffix (Kind),
867:             Names,
868:             Secondary_Loc,
869:             Explain_Code),
870:          First,
871:          Continuations);
872:    end Warning_Msg_N;
873:
874:    procedure Warning_Msg_N
875:      (Kind          : Misc_Warning_Kind;
876:       N             : Node_Id;
877:       Msg           : Message;
878:       First         : Boolean := False;
879:       Continuations : Message_Lists.List := Message_Lists.Empty)
880:    is
881:       Suppressed : constant Boolean :=
882:         Warning_Status (Kind) not in WS_Enabled | WS_Error;
883:       Severity   : constant Msg_Severity :=
884:         (if Warning_Status (Kind) = WS_Error
885:          then Error_Kind
886:          else Warning_Kind);
887:       My_Msg     : constant Message := Add_Default_Name (Msg, N);
888:       My_Conts   : Message_Lists.List;
889:    begin
890:       for Msg of Continuations loop
891:          My_Conts.Append (Add_Default_Name (Msg, N));
892:       end loop;
893:       if not Suppressed then
894:          Error_Msg_N (Msg, N, Severity, First, My_Conts, False);
895:       end if;
896:       declare
897:          --  The message can be suppressed via the warning tags, or via pragma
898:          --  Warnings (Off), check for the second way here.
899:          Was_Suppressed : constant Boolean :=
900:            Suppressed
901:            or else
902:              Warning_Is_Suppressed (N, To_String (My_Msg.Msg)) /= No_String;
903:          Result         : constant JSON_Result_Type :=
904:            JSON_Result_Type'
905:              (Msg           => My_Msg,
906:               Severity      => Severity,
907:               Tag           => To_Unbounded_String (Kind_Name (Kind)),
908:               Span          => To_Span (Sloc (N)),
909:               Suppr         =>
910:                 (if Was_Suppressed
911:                  then Suppressed_Warning
912:                  else No_Suppressed_Message),
913:               Continuations => My_Conts,
914:               others        => <>);
915:       begin
916:          Add_Json_Msg (Warnings_Errors, Result);
917:       end;
918:    end Warning_Msg_N;
```

## common/vc_kinds.ads:673–680

```ada
673:    function Warning_Message (Kind : Misc_Warning_Kind) return String
674:    is (case Kind is
675:          when Warn_Address_To_Access               =>
676:            "call to & is assumed to return a valid access"
677:            & " designating a valid value",
678:          when Warn_Alias_Atomic_Vol                =>
679:            "aliased objects must have the same volatility and atomic status",
680:          when Warn_Alias_Different_Volatility      =>
```

## common/vc_kinds.ads:770–784

```ada
770:          --  Flow limitations
771:          when Warn_Alias_Array                     =>
772:            "aliasing check on components of an array is handled imprecisely",
773:          when Warn_Imprecise_GG                    =>
774:            "global generation of & might be imprecise",
775:          when Warn_Init_Array                      =>
776:            "initialization of an array in FOR loop is handled imprecisely",
777:          when Warn_Init_Multidim_Array             =>
778:            "initialization of a multi-dimensional array in nested FOR loops "
779:            & "is handled imprecisely",
780:          when Warn_Tagged_Untangling               =>
781:            "flow of dependencies on & is handled imprecisely",
782:
783:          --  Proof limitations
784:          when Warn_Contracts_Recursive             =>
```

## common/vc_kinds.ads:810–814

```ada
810:          when Warn_Imprecise_Image                 =>
811:            "references to the & attribute are handled in an"
812:            & " imprecise way, so nothing will be known about the evaluation"
813:            & " of the attribute reference apart from a bound on its length",
814:          when Warn_Loop_Entity                     =>
```

## common/vc_kinds.adb:167–235

```ada
167:    function CWE_ID (Kind : Valid_Flow_Tag_Kind) return String is
168:    begin
169:       return
170:         (case Kind is
171:            --  CWE-561: Dead Code
172:
173:            when Dead_Code                                       => "561",
174:
175:            --  CWE-362: Concurrent Execution using Shared Resource with
176:            --  Improper Synchronization ('Race Condition')
177:
178:            when Concurrent_Access                               => "362",
179:
180:            --  CWE-457: Use of Uninitialized Variable
181:
182:            when Default_Initialization_Mismatch | Uninitialized => "457",
183:
184:            --  CWE-667: Improper Locking
185:
186:            when Potentially_Blocking_In_Protected               => "667",
187:
188:            --  CWE-563: Assignment to Variable without Use ('Unused Variable')
189:
190:            when Unused_Initial_Value | Unused_Variable          => "563",
191:
192:            --  CWE-1164: Irrelevant Code
193:
194:            when Ineffective                                     => "1164",
195:
196:            --  CWE-674: Uncontrolled Recursion
197:
198:            when Call_In_Type_Invariant | Subprogram_Termination => "674",
199:
200:            when Aliasing
201:               | Call_To_Current_Task
202:               | Critical_Global_Missing
203:               | Depends_Null
204:               | Depends_Missing
205:               | Depends_Missing_Clause
206:               | Depends_Wrong
207:               | Export_Depends_On_Proof_In
208:               | Ghost_Wrong
209:               | Global_Missing
210:               | Global_Wrong
211:               | Hidden_Unexposed_State
212:               | Illegal_Update
213:               | Impossible_To_Initialize_State
214:               | Initializes_Wrong
215:               | Inout_Only_Read
216:               | Missing_Return
217:               | Non_Volatile_Function_With_Volatile_Effects
218:               | Not_Constant_After_Elaboration
219:               | Reference_To_Non_CAE_Variable
220:               | Refined_State_Wrong
221:               | Side_Effects
222:               | Stable
223:               | Unused_Global
224:               | Volatile_Function_Without_Volatile_Effects      => "");
225:    end CWE_ID;
226:
227:    -----------------
228:    -- CWE_Message --
229:    -----------------
230:
231:    function CWE_Message (Kind : VC_Kind) return String
232:    is (Wrap_CWE (CWE_ID (Kind)));
233:
234:    function CWE_Message (Kind : Valid_Flow_Tag_Kind) return String
235:    is (Wrap_CWE (CWE_ID (Kind)));
```

## common/vc_kinds.adb:1889–1919

```ada
1889:          when Warn_Representation_Attribute_Value  =>
1890:            "representation-attribute-value",
1891:
1892:          --  Warnings enabled by --info switch
1893:          when Warn_Alias_Array                     => "alias-array",
1894:          when Warn_Comp_Relaxed_Init               => "component-relaxed-init",
1895:          when Warn_Contracts_Recursive             => "contracts-recursive",
1896:          when Warn_DIC_Ignored                     => "dic-ignored",
1897:          when Warn_Full_View_Visible               => "full-view-visible",
1898:          when Warn_Imprecise_Address               => "imprecise-address",
1899:          when Warn_Imprecise_Align                 => "imprecise-align",
1900:          when Warn_Imprecise_Call                  => "imprecise-call",
1901:          when Warn_Imprecise_GG                    =>
1902:            "imprecise-global-generation",
1903:          when Warn_Init_Array                      => "array-initialization",
1904:          when Warn_Init_Multidim_Array             =>
1905:            "multidimensional-array-init",
1906:          when Warn_Component_Size                  =>
1907:            "imprecise-component-size",
1908:          when Warn_Record_Component_Attr           =>
1909:            "imprecise-record-component-attribute",
1910:          when Warn_Imprecise_Size                  => "imprecise-size",
1911:          when Warn_Imprecise_Overlay               => "imprecise-overlay",
1912:          when Warn_Imprecise_UC                    =>
1913:            "imprecise-unchecked-conversion",
1914:          when Warn_Imprecise_Value                 => "imprecise-value",
1915:          when Warn_Imprecise_Image                 => "imprecise-image",
1916:          when Warn_Loop_Entity                     => "constants-in-loops",
1917:          when Warn_Init_Cond_Ignored               => "init-cond-ignored",
1918:          when Warn_No_Reclam_Func                  =>
1919:            "no-reclamation-function",
```

## common/vc_kinds.adb:2205–2212

```ada
2205:    function Wrap_CWE (S : String) return String is
2206:    begin
2207:       if S = "" then
2208:          return "";
2209:       else
2210:          return " [CWE " & S & "]";
2211:       end if;
2212:    end Wrap_CWE;
```

## why/gnat2why-driver.adb:348–384

```ada
348:    -- Create_JSON_File --
349:    ----------------------
350:
351:    procedure Create_JSON_File
352:      (Progress : Analysis_Progress; Stop_Reason : Stop_Reason_Type)
353:    is
354:       FD        : Ada.Text_IO.File_Type;
355:       File_Name : constant String :=
356:         Ada.Directories.Compose
357:           (Name => Unit_Name, Extension => VC_Kinds.SPARK_Suffix);
358:       Full      : constant JSON_Value := Create_Object;
359:    begin
360:       Set_Field (Full, "spark", Get_SPARK_JSON);
361:       Set_Field (Full, "skip_flow_proof", Get_Skip_Flow_And_Proof_JSON);
362:       Set_Field (Full, "skip_proof", Get_Skip_Proof_JSON);
363:       Set_Field
364:         (Full, "progress", Create (Analysis_Progress'Image (Progress)));
365:       Set_Field
366:         (Full, "stop_reason", Create (Stop_Reason_Type'Image (Stop_Reason)));
367:       Set_Field (Full, "warn_error", Create (Warnings_Errors));
368:       if Progress >= Progress_Flow then
369:          Set_Field (Full, "flow", Create (Flow_Msgs));
370:       end if;
371:       if Progress >= Progress_Proof then
372:          Set_Field (Full, "pragma_assume", Create (Get_Pragma_Assume_JSON));
373:          Set_Field (Full, "proof", Create (Proof_Msgs));
374:       end if;
375:       Set_Field (Full, "assumptions", Get_Assume_JSON);
376:
377:       Set_Field (Full, "timings", Timing_History (Timing));
378:       Set_Field (Full, "entities", Entity_Table);
379:
380:       Ada.Text_IO.Create (FD, Ada.Text_IO.Out_File, File_Name);
381:       Ada.Text_IO.Put (FD, GNATCOLL.JSON.Write (Full, Compact => False));
382:       Ada.Text_IO.Close (FD);
383:    end Create_JSON_File;
384:
```

## why/gnat2why-driver.adb:554–569

```ada
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
```

## why/gnat2why-driver.adb:790–831

```ada
790:
791:       --  The remaining steps depend on phase. In particular, in phase 1
792:       --  marking is done before flow, while in phase 2 it is done after flow.
793:       --  Common steps are intentionally duplicated to keep the sequence clear.
794:
795:       if Gnat2Why_Args.Global_Gen_Mode then
796:
797:          --  Mark the current compilation unit as "in SPARK / not in SPARK"
798:          Mark_Standard_Package;
799:          Mark_Current_Unit;
800:
801:          Timing_Phase_Completed (Timing, Null_Subp, "marking");
802:
803:          --  Finalize has to be called before we call Compilation_Errors
804:          Finalize (Last_Call => False);
805:
806:          if Compilation_Errors or else Gnat2Why_Args.Mode = GPM_Check then
807:             goto Leave;
808:          end if;
809:
810:          --  Store information for tagged types in phase 1, as we want to link
811:          --  all possible subprograms for a given dispatching call.
812:
813:          for E of Entities_To_Translate loop
814:             Store_Descendants_Information (E);
815:          end loop;
816:
817:          --  Build hierarchical representation of scopes in the current
818:          --  compilation unit.
819:          --
820:          --  Also, pick constants with variable inputs. This is affected by the
821:          --  SPARK status of expressions in their initial values, so must be
822:          --  done after marking.
823:
824:          Build_Flow_Tree;
825:
826:          Generate_Globals (GNAT_Root);
827:          Timing_Phase_Completed (Timing, Null_Subp, "globals (partial)");
828:
829:       else
830:          --  Issue warning if analyzing specific units with -u switch, but the
831:          --  main entity in the compilation unit is not marked in SPARK. It may
```

## why/gnat2why-driver.adb:1121–1145

```ada
1121:    function Get_Skip_Flow_And_Proof_JSON return JSON_Array is
1122:       Result : JSON_Array := GNATCOLL.JSON.Empty_Array;
1123:    begin
1124:       for Elt of Skipped_Flow_And_Proof loop
1125:          Append
1126:            (Result,
1127:             Assumption_Types.To_JSON (Entity_To_Subp_Assumption (Elt)));
1128:       end loop;
1129:       return Result;
1130:    end Get_Skip_Flow_And_Proof_JSON;
1131:
1132:    -------------------
1133:    -- Get_Skip_JSON --
1134:    -------------------
1135:
1136:    function Get_Skip_Proof_JSON return JSON_Array is
1137:       Result : JSON_Array := GNATCOLL.JSON.Empty_Array;
1138:    begin
1139:       for Elt of Skipped_Proof loop
1140:          Append
1141:            (Result,
1142:             Assumption_Types.To_JSON (Entity_To_Subp_Assumption (Elt)));
1143:       end loop;
1144:       return Result;
1145:    end Get_Skip_Proof_JSON;
```

## why/gnat2why-expr.adb:20258–20296

```ada
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
```

## spark/spark_definition.adb:2313–2389

```ada
2313:    function Get_SPARK_JSON return JSON_Value is
2314:       SPARK_Status_JSON : constant JSON_Value := Create_Object;
2315:
2316:    begin
2317:       --  ??? Iterating over all entities is not efficient, but we do it only
2318:       --  once. Perhaps iteration over hierarchical Entity_Tree would allow to
2319:       --  skip entities from non-main unit and those whose parent is not in
2320:       --  SPARK. However, Entity_Tree does not contain protected types (maybe
2321:       --  it should?) while we want to generate SPARK status for them (maybe
2322:       --  we should not?).
2323:
2324:       for E of Entity_List loop
2325:          --  Only add infomation for an entity if analysis is requested for it.
2326:          --  Then, absence of errors in flow and warnings in proof for it can
2327:          --  be interpreted as a correct flow analysis or proof for it.
2328:
2329:          if Ekind (E)
2330:             in Entry_Kind
2331:              | E_Function
2332:              | E_Procedure
2333:              | E_Package
2334:              | E_Protected_Type
2335:              | E_Task_Type
2336:            and then Analysis_Requested (E, With_Inlined => True)
2337:          then
2338:             declare
2339:                V : constant Subp_Type := Entity_To_Subp_Assumption (E);
2340:
2341:                SPARK_Status : constant SPARK_Mode_Status :=
2342:                  (if Entity_Body_In_SPARK (E)
2343:                   then All_In_SPARK
2344:                   elsif Entity_Spec_In_SPARK (E)
2345:                   then
2346:                     (if Ekind (E) = E_Package and then No (Package_Body (E))
2347:                      then All_In_SPARK
2348:                      elsif Ekind (E) = E_Procedure
2349:                        and then Null_Present (Subprogram_Specification (E))
2350:                      then All_In_SPARK
2351:                      else Spec_Only_In_SPARK)
2352:                   else Not_In_SPARK);
2353:             begin
2354:                Set_Field
2355:                  (SPARK_Status_JSON, To_Key (V), To_JSON (SPARK_Status));
2356:             end;
2357:
2358:          elsif Is_Type (E)
2359:            and then Entity_In_SPARK (E)
2360:            and then E = Retysp (E)
2361:            and then Analysis_Requested (E, With_Inlined => True)
2362:            and then
2363:              (Needs_Default_Checks_At_Decl (E)
2364:               or else
2365:                 (Is_Access_Subprogram_Type (E) and then No (Parent_Retysp (E)))
2366:               or else Declares_Iterable_Aspect (E)
2367:               or else
2368:                 (Is_Base_Type (E)
2369:                  and then not Use_Predefined_Equality_For_Type (E))
2370:               or else Needs_Check_For_Aggregate_Annotation (E)
2371:               or else Needs_Ownership_Check (E))
2372:          then
2373:
2374:             declare
2375:                V            : constant Subp_Type :=
2376:                  Entity_To_Subp_Assumption (E);
2377:                SPARK_Status : constant SPARK_Mode_Status :=
2378:                  (if Full_View_Not_In_SPARK (E)
2379:                   then Spec_Only_In_SPARK
2380:                   else All_In_SPARK);
2381:             begin
2382:                Set_Field
2383:                  (SPARK_Status_JSON, To_Key (V), To_JSON (SPARK_Status));
2384:             end;
2385:          end if;
2386:       end loop;
2387:
2388:       return SPARK_Status_JSON;
2389:    end Get_SPARK_JSON;
```

## spark/spark_definition.adb:4289–4308

```ada
4289:          when N_With_Clause                                          =>
4290:
4291:             --  Proof requires marking of initial conditions of all withed
4292:             --  units.
4293:
4294:             if not Limited_Present (N)
4295:               and then Nkind (Unit (Library_Unit (N))) = N_Package_Declaration
4296:             then
4297:                declare
4298:                   Package_E  : constant E_Package_Id :=
4299:                     Defining_Entity (Unit (Library_Unit (N)));
4300:                   Init_Conds : constant Node_Lists.List :=
4301:                     Find_Contracts (Package_E, Pragma_Initial_Condition);
4302:                begin
4303:                   for Expr of Init_Conds loop
4304:                      Mark (Expr);
4305:                   end loop;
4306:                end;
4307:             end if;
4308:
```

## spark/spark_definition.adb:6543–6582

```ada
6543:       elsif Emit_Warning_Info_Messages and then SPARK_Pragma_Is (Opt.On) then
6544:
6545:          --  Warn about calls to predefined and imported subprograms with no
6546:          --  manually-written Global or Depends contracts. Exempt calls to
6547:          --  pure subprograms (because Pure acts as "Global => null").
6548:
6549:          declare
6550:             Might_Have_Flow_Assumptions : constant Boolean :=
6551:               (Has_No_Body (E)
6552:                or else
6553:                  (Is_Ignored_Internal (E)
6554:                   and then not Is_Ignored_Internal (N)))
6555:               and then not Is_Unchecked_Conversion_Instance (E)
6556:               and then not Is_Unchecked_Deallocation_Instance (E)
6557:               and then not Is_Predicate_Function (E)
6558:               and then not Is_Abstract_Subprogram (E);
6559:
6560:          begin
6561:             if Might_Have_Flow_Assumptions then
6562:                if not Has_User_Supplied_Globals (E) then
6563:                   Warning_Msg_N
6564:                     (Warn_Assumed_Global_Null,
6565:                      N,
6566:                      Names         => [E],
6567:                      Continuations =>
6568:                        [Create
6569:                           ("assuming & has no effect on global items",
6570:                            Names => [E])]);
6571:                end if;
6572:
6573:                if Get_Termination_Condition (E).Kind = Unspecified
6574:                  and then not No_Return (E)
6575:                then
6576:                   Warning_Msg_N
6577:                     (Warn_Assumed_Always_Terminates,
6578:                      N,
6579:                      Names         => [E],
6580:                      Continuations =>
6581:                        [Create
6582:                           ("assuming & always terminates", Names => [E])]);
```

## spark/spark_definition.adb:11834–11852

```ada
11834:       --  Start of processing for Mark_Entity
11835:
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
```

## spark/spark_definition.adb:12208–12249

```ada
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
12249:
```

## spark/spark_definition.adb:12873–12892

```ada
12873:    procedure Mark_Package_Declaration (N : N_Package_Declaration_Id) is
12874:       Id         : constant E_Package_Id := Defining_Entity (N);
12875:       Spec       : constant N_Package_Specification_Id := Specification (N);
12876:       Vis_Decls  : constant List_Id := Visible_Declarations (Spec);
12877:       Priv_Decls : constant List_Id := Private_Declarations (Spec);
12878:
12879:       Save_SPARK_Pragma       : constant Opt_N_Pragma_Id :=
12880:         Current_SPARK_Pragma;
12881:       Save_Violation_Detected : constant Boolean := Violation_Detected;
12882:
12883:    begin
12884:       Current_SPARK_Pragma := SPARK_Pragma (Id);
12885:
12886:       --  Record the package as an entity to translate iff it is
12887:       --  explicitly marked with SPARK_Mode => On.
12888:
12889:       if SPARK_Pragma_Is (Opt.On) then
12890:          Entity_List.Append (Id);
12891:       end if;
12892:
```

## spark/spark_definition.adb:5667–5683

```ada
5667:                     and then Present (Par)
5668:                     and then Nkind (Par) = N_Function_Call
5669:                     and then
5670:                       Has_At_End_Borrow_Annotation (Get_Called_Entity (Par))
5671:                   then
5672:                      null;
5673:                   elsif Nkind (P) /= N_Function_Call then
5674:                      Mark_Violation
5675:                        ("prefix of """ & Astring & """ introducing aliasing",
5676:                         P,
5677:                         SRM_Reference => "SPARK RM 3.10(13)",
5678:                         Cont_Msg      =>
5679:                           "call a deep copy function for "
5680:                           & Pretty_Source_Name (Etype (P))
5681:                           & " as prefix of """
5682:                           & Astring
5683:                           & """ to avoid aliasing");
```

## spark/spark_definition.adb:8607–8618

```ada
8607:             if Ekind (E) = E_Procedure
8608:               and then No_Return (E)
8609:               and then not Has_Exceptional_Contract (E)
8610:               and then not Has_Program_Exit (E)
8611:               and then Get_Termination_Condition (E) = (Static, True)
8612:             then
8613:                if Emit_Warning_Info_Messages then
8614:                   Warning_Msg_N
8615:                     (Warn_No_Possible_Termination,
8616:                      E,
8617:                      Explain_Code => EC_Always_Terminates_Warn);
8618:                end if;
```

## spark/spark_definition.adb:13244–13259

```ada
13244:
13245:          when Pragma_Overflow_Mode           =>
13246:             if Nkind (Parent (N)) = N_Compilation_Unit then
13247:                Sem_Prag.Set_Overflow_Mode (N);
13248:
13249:             --  Emit warning on pragma Overflow_Mode being currently ignored,
13250:             --  even in code not marked SPARK_Mode On, as otherwise no warning
13251:             --  would be issued on configuration pragmas at the start of units
13252:             --  whose top level declaration is marked later SPARK_Mode On. Do
13253:             --  not emit a warning in code marked SPARK_Mode Off though.
13254:
13255:             elsif Emit_Warning_Info_Messages
13256:               and then not SPARK_Pragma_Is (Opt.Off)
13257:             then
13258:                Warning_Msg_N (Warn_Pragma_Overflow_Mode, N, First => True);
13259:             end if;
```

## spark/spark_definition.adb:14000–14025

```ada
14000:
14001:                --  Issue warning on unreferenced local subprograms, which are
14002:                --  analyzed anyway, unless the subprogram is marked with pragma
14003:                --  Unreferenced. Local subprograms are identified by calling
14004:                --  Is_Local_Subprogram_Always_Inlined, but this does not take
14005:                --  into account local subprograms which are not inlined. It
14006:                --  would be better to look at the scope of E. ???
14007:
14008:                if Is_Local_Subprogram_Always_Inlined (E)
14009:                  and then not Referenced (E)
14010:                  and then not Has_Unreferenced (E)
14011:                  and then Emit_Warning_Info_Messages
14012:                then
14013:                   case Ekind (E) is
14014:                      when E_Function  =>
14015:                         Warning_Msg_N
14016:                           (Warn_Unreferenced_Function, N, Names => [E]);
14017:
14018:                      when E_Procedure =>
14019:                         Warning_Msg_N
14020:                           (Warn_Unreferenced_Procedure, N, Names => [E]);
14021:
14022:                      when others      =>
14023:                         raise Program_Error;
14024:
14025:                   end case;
```

## spark/spark_util.adb:1917–1951

```ada
1917:    function Entity_To_Subp_Assumption (E : Entity_Id) return Subp_Type is
1918:       function Loc_To_Assume_Sloc (Loc : Source_Ptr) return My_Sloc
1919:       with Pre => Loc /= No_Location;
1920:
1921:       ------------------------
1922:       -- Loc_To_Assume_Sloc --
1923:       ------------------------
1924:
1925:       function Loc_To_Assume_Sloc (Loc : Source_Ptr) return My_Sloc is
1926:          Sloc : My_Sloc := Sloc_Lists.Empty_List;
1927:          Slc  : Source_Ptr := Loc;
1928:       begin
1929:          loop
1930:             declare
1931:                File   : constant String := File_Name (Slc);
1932:                Line   : constant Positive :=
1933:                  Positive (Get_Physical_Line_Number (Slc));
1934:                Column : constant Positive :=
1935:                  Positive (Get_Column_Number (Slc));
1936:             begin
1937:                Sloc.Append
1938:                  (Mk_Base_Sloc (File => File, Line => Line, Column => Column));
1939:             end;
1940:             Slc := Instantiation_Location (Slc);
1941:
1942:             exit when Slc = No_Location;
1943:          end loop;
1944:          return Sloc;
1945:       end Loc_To_Assume_Sloc;
1946:    begin
1947:       return
1948:         Mk_Subp
1949:           (Name => Full_Source_Name (E),
1950:            Sloc => Loc_To_Assume_Sloc (Sloc (E)));
1951:    end Entity_To_Subp_Assumption;
```

## spark/spark_util.adb:4817–4852

```ada
4817:    function To_String (N : Name_Id; Sloc : Source_Ptr) return String is
4818:       Buf      : Bounded_String;
4819:       Name_Len : Natural;
4820:    begin
4821:       Append_Unqualified_Decoded (Buf, N);
4822:       Name_Len := Buf.Length;
4823:       if Name_Len > 2
4824:         and then Buf.Chars (Name_Len - 1) = '%'
4825:         and then
4826:           (Buf.Chars (Name_Len) = 'b' or else Buf.Chars (Name_Len) = 's')
4827:       then
4828:          Name_Len := Name_Len - 2;
4829:       end if;
4830:
4831:       --  Remove upper case letter at end, again, we should not be getting
4832:       --  such names, and what we hope is that the remainder makes sense.
4833:
4834:       if Name_Len > 1 and then Buf.Chars (Name_Len) in 'A' .. 'Z' then
4835:          Name_Len := Name_Len - 1;
4836:       end if;
4837:
4838:       --  If operator name or character literal name, just print it as is.
4839:       --  Also print as is if it ends in a right paren (case of x'val(nnn)).
4840:
4841:       if Buf.Chars (1) in '"' | ''' or else Buf.Chars (Name_Len) = ')' then
4842:          return Buf.Chars (1 .. Name_Len);
4843:       else
4844:          if Sloc <= No_Location then
4845:             Set_Casing (Buf, Mixed_Case);
4846:          else
4847:             Set_Casing (Buf, Identifier_Casing (Get_Source_File_Index (Sloc)));
4848:          end if;
4849:          return '"' & Buf.Chars (1 .. Name_Len) & '"';
4850:       end if;
4851:    end To_String;
4852:
```

## spark/spark_util-subprograms.adb:786–861

```ada
786:    function Get_Termination_Condition
787:      (E : Entity_Id; Compute : Boolean := False) return Termination_Condition
788:    is
789:       Terminates_Pragma : constant Node_Id :=
790:         Get_Pragma (E, Pragma_Always_Terminates);
791:    begin
792:       pragma Assert (if Compute then GG_Has_Been_Generated);
793:
794:       --  Look for an Always_Terminates aspect on E
795:
796:       if Present (Terminates_Pragma) then
797:          declare
798:             Assocs : constant List_Id :=
799:               Pragma_Argument_Associations (Terminates_Pragma);
800:             Cond   : constant Node_Id :=
801:               (if No (Assocs) then Empty else Expression (First (Assocs)));
802:
803:          begin
804:             --  If Always_Terminates does not have a condition, the default is
805:             --  True.
806:
807:             if No (Cond) then
808:                return (Static, True);
809:
810:             --  If the condition is known at compile time, get its value
811:
812:             elsif Compile_Time_Known_Value (Cond) then
813:                return (Static, Is_True (Expr_Value (Cond)));
814:
815:             --  Otherwise, we keep the condition has is
816:
817:             else
818:                return (Dynamic, Cond);
819:             end if;
820:          end;
821:
822:       --  The Always_Terminates annotation is implicit on packages, functions,
823:       --  and lemmas.
824:
825:       elsif Has_Implicit_Always_Terminates (E) then
826:          return (Static, True);
827:
828:       --  If E is directly in a package specification, get the annotation from
829:       --  there.
830:
831:       else
832:          declare
833:             Scop : Entity_Id := Scope (E);
834:          begin
835:             while Present (Scop) and then Ekind (Scop) = E_Package loop
836:                if Present (Get_Pragma (Scop, Pragma_Always_Terminates)) then
837:                   return (Static, True);
838:                end if;
839:                Scop := Scope (Scop);
840:             end loop;
841:          end;
842:
843:          --  No applicable annotation was found, compute it or return
844:          --  unspecified.
845:
846:          if Compute then
847:             declare
848:                Value : constant Boolean :=
849:                  (if Ekind (E) in E_Subprogram_Type | E_Task_Type
850:                   then False
851:                   else not Is_Potentially_Nonreturning_Internal (E));
852:             begin
853:                return (Static, Value);
854:             end;
855:          else
856:             return (Kind => Unspecified);
857:          end if;
858:       end if;
859:    end Get_Termination_Condition;
860:
861:    -----------------------------------
```
