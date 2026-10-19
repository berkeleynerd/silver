# Selected source excerpts (literal LF coordinates)

GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Full-file pins in `inputs.json` are mandatory; excerpts are navigation evidence. Display trailing whitespace is trimmed.

## `bindo-builders.adb:100`

```ada
100:       function Build_Invocation_Graph
101:         (Lib_G : Library_Graph) return Invocation_Graph
102:       is
103:       begin
104:          pragma Assert (Present (Lib_G));
105:
106:          Start_Phase (Invocation_Graph_Construction);
107:
108:          --  Prepare the global data
109:
110:          Inv_Graph :=
111:            Create
112:              (Initial_Vertices => Number_Of_Elaborable_Units,
113:               Initial_Edges    => Number_Of_Elaborable_Units,
114:               Lib_Graph        => Lib_G);
115:          Lib_Graph := Lib_G;
116:
117:          For_Each_Elaborable_Unit (Create_Vertices'Access);
118:          For_Each_Elaborable_Unit (Create_Edges'Access);
119:
120:          Validate_Invocation_Graph (Inv_Graph);
121:          End_Phase (Invocation_Graph_Construction);
122:
123:          return Inv_Graph;
124:       end Build_Invocation_Graph;
```

## `bindo-builders.adb:130`

```ada
130:       procedure Create_Edge (IR_Id : Invocation_Relation_Id) is
131:          pragma Assert (Present (Inv_Graph));
132:          pragma Assert (Present (Lib_Graph));
133:          pragma Assert (Present (IR_Id));
134:
135:          Invoker_Sig : constant Invocation_Signature_Id := Invoker (IR_Id);
136:          Target_Sig  : constant Invocation_Signature_Id := Target  (IR_Id);
137:
138:          pragma Assert (Present (Invoker_Sig));
139:          pragma Assert (Present (Target_Sig));
140:
141:       begin
142:          --  Nothing to do when the target denotes an invocation construct that
143:          --  resides in a unit which will never be elaborated.
144:
145:          if not Needs_Elaboration (Target_Sig) then
146:             return;
147:          end if;
148:
149:          Add_Edge
150:            (G      => Inv_Graph,
151:             Source => Corresponding_Vertex (Inv_Graph, Invoker_Sig),
152:             Target => Corresponding_Vertex (Inv_Graph, Target_Sig),
153:             IR_Id  => IR_Id);
```

## `bindo-builders.adb:206`

```ada
206:       procedure Create_Vertices (U_Id : Unit_Id) is
207:          pragma Assert (Present (Inv_Graph));
208:          pragma Assert (Present (Lib_Graph));
209:          pragma Assert (Present (U_Id));
210:
211:          U_Rec  : Unit_Record renames ALI.Units.Table (U_Id);
212:          Vertex : constant Library_Graph_Vertex_Id :=
213:                     Corresponding_Vertex (Lib_Graph, U_Id);
214:
215:       begin
216:          for IC_Id in U_Rec.First_Invocation_Construct ..
217:                       U_Rec.Last_Invocation_Construct
218:          loop
219:             Create_Vertex (IC_Id, Vertex);
220:          end loop;
221:       end Create_Vertices;
222:
```

## `bindo-builders.adb:440`

```ada
440:       procedure Create_Forced_Edges is
441:          Current_Unit  : Unit_Id;
442:          Iter          : Forced_Units_Iterator;
443:          Previous_Unit : Unit_Id;
444:          Unit_Line     : Logical_Line_Number;
445:          Unit_Name     : Unit_Name_Type;
446:
447:       begin
448:          Previous_Unit := No_Unit_Id;
449:          Unit_To_Line  := Unit_Line_Tables.Create (20);
450:
451:          --  Inspect the contents of the forced-elaboration-order file supplied
452:          --  to the binder using switch -f, and diagnose each unit accordingly.
453:
454:          Iter := Iterate_Forced_Units;
455:          while Has_Next (Iter) loop
456:             Next (Iter, Unit_Name, Unit_Line);
457:
458:             Current_Unit := Corresponding_Unit (Unit_Name);
459:
460:             if not Present (Current_Unit) then
461:                Missing_Unit_Info (Unit_Name);
462:
463:             elsif Is_Internal_Unit (Current_Unit) then
464:                Internal_Unit_Info (Unit_Name);
465:
466:             elsif Is_Duplicate_Unit (Current_Unit) then
467:                Duplicate_Unit_Error (Current_Unit, Unit_Name, Unit_Line);
468:
469:             --  Otherwise the unit is a valid candidate for a vertex. Create a
470:             --  forced edge between each pair of units.
471:
472:             else
473:                Add_Unit (Current_Unit, Unit_Line);
474:
475:                if Present (Previous_Unit) then
476:                   Create_Forced_Edge
477:                     (Pred => Previous_Unit,
478:                      Succ => Current_Unit);
479:                end if;
480:
481:                Previous_Unit := Current_Unit;
482:             end if;
483:          end loop;
484:
485:          Unit_Line_Tables.Destroy (Unit_To_Line);
486:       end Create_Forced_Edges;
```

## `bindo-graphs.ads:1546`

```ada
1546:       type Invocation_Graph_Vertex_Attributes is record
1547:          Body_Vertex : Library_Graph_Vertex_Id := No_Library_Graph_Vertex;
1548:          --  Reference to the library graph vertex where the body of this
1549:          --  vertex resides.
1550:
1551:          Construct : Invocation_Construct_Id := No_Invocation_Construct;
1552:          --  Reference to the invocation construct this vertex represents
1553:
1554:          Spec_Vertex : Library_Graph_Vertex_Id := No_Library_Graph_Vertex;
1555:          --  Reference to the library graph vertex where the spec of this
1556:          --  vertex resides.
1557:       end record;
```

## `bindo-graphs.ads:1594`

```ada
1594:       type Invocation_Graph_Edge_Attributes is record
1595:          Relation : Invocation_Relation_Id := No_Invocation_Relation;
1596:          --  Reference to the invocation relation this edge represents
1597:       end record;
```

## `bindo-graphs.ads:1627`

```ada
1627:       type Source_Target_Relation is record
1628:          Source : Invocation_Graph_Vertex_Id := No_Invocation_Graph_Vertex;
1629:          --  The source vertex
1630:
1631:          Target : Invocation_Graph_Vertex_Id := No_Invocation_Graph_Vertex;
1632:          --  The destination vertex
1633:       end record;
```

## `bindo-graphs.ads:1654`

```ada
1654:       type Invocation_Graph_Edge_Counts is array (Invocation_Kind) of Natural;
```

## `bindo-graphs.ads:1702`

```ada
1702:       type Invocation_Graph_Attributes is record
1703:          Counts : Invocation_Graph_Edge_Counts := (others => 0);
1704:          --  Edge statistics
1705:
1706:          Edge_Attributes : IGE_Tables.Dynamic_Hash_Table := IGE_Tables.Nil;
1707:          --  The map of edge -> edge attributes for all edges in the graph
1708:
1709:          Graph : DG.Directed_Graph := DG.Nil;
1710:          --  The underlying graph describing the relations between edges and
1711:          --  vertices.
1712:
1713:          Relations : Relation_Sets.Membership_Set := Relation_Sets.Nil;
1714:          --  The set of relations between source and targets, used to prevent
1715:          --  duplicate edges in the graph.
1716:
1717:          Roots : IGV_Sets.Membership_Set := IGV_Sets.Nil;
1718:          --  The set of elaboration root vertices
1719:
1720:          Signature_To_Vertex : Signature_Tables.Dynamic_Hash_Table :=
1721:                                  Signature_Tables.Nil;
1722:          --  The map of signature -> vertex
1723:
1724:          Vertex_Attributes : IGV_Tables.Dynamic_Hash_Table := IGV_Tables.Nil;
1725:          --  The map of vertex -> vertex attributes for all vertices in the
1726:          --  graph.
1727:
1728:          Lib_Graph : Library_Graphs.Library_Graph;
1729:       end record;
```

## `bindo-graphs.adb:4930`

```ada
4930:       procedure Add_Edge
4931:         (G      : Invocation_Graph;
4932:          Source : Invocation_Graph_Vertex_Id;
4933:          Target : Invocation_Graph_Vertex_Id;
4934:          IR_Id  : Invocation_Relation_Id)
4935:       is
4936:          pragma Assert (Present (G));
4937:          pragma Assert (Present (Source));
4938:          pragma Assert (Present (Target));
4939:          pragma Assert (Present (IR_Id));
4940:
4941:          Rel : constant Source_Target_Relation :=
4942:                  (Source => Source,
4943:                   Target => Target);
4944:
4945:          Edge : Invocation_Graph_Edge_Id;
4946:
4947:       begin
4948:          --  Nothing to do when the source and target are already related by an
4949:          --  edge.
4950:
4951:          if Is_Existing_Source_Target_Relation (G, Rel) then
4952:             return;
4953:          end if;
4954:
4955:          Edge := Sequence_Next_Edge;
4956:
4957:          --  Add the edge to the underlying graph
4958:
4959:          DG.Add_Edge
4960:            (G           => G.Graph,
4961:             E           => Edge,
4962:             Source      => Source,
4963:             Destination => Target);
4964:
4965:          --  Build and save the attributes of the edge
4966:
4967:          Set_IGE_Attributes
4968:            (G    => G,
4969:             Edge => Edge,
4970:             Val  => (Relation => IR_Id));
4971:
4972:          --  Mark the source and target as related by the new edge. This
4973:          --  prevents all further attempts to link the same source and target.
4974:
4975:          Set_Is_Existing_Source_Target_Relation (G, Rel);
4976:
4977:          --  Update the edge statistics
4978:
4979:          Increment_Invocation_Graph_Edge_Count (G, Kind (IR_Id));
4980:       end Add_Edge;
4981:
4982:       ----------------
4983:       -- Add_Vertex --
4984:       ----------------
4985:
4986:       procedure Add_Vertex
4987:         (G           : Invocation_Graph;
4988:          IC_Id       : Invocation_Construct_Id;
4989:          Body_Vertex : Library_Graph_Vertex_Id;
4990:          Spec_Vertex : Library_Graph_Vertex_Id)
4991:       is
4992:          pragma Assert (Present (G));
4993:          pragma Assert (Present (IC_Id));
4994:          pragma Assert (Present (Body_Vertex));
4995:          pragma Assert (Present (Spec_Vertex));
4996:
4997:          Construct_Signature : constant Invocation_Signature_Id :=
4998:                                  Signature (IC_Id);
4999:          Vertex : Invocation_Graph_Vertex_Id;
5000:
5001:       begin
5002:          --  Nothing to do when the construct already has a vertex
5003:
5004:          if Present (Corresponding_Vertex (G, Construct_Signature)) then
5005:             return;
5006:          end if;
5007:
5008:          Vertex := Sequence_Next_Vertex;
5009:
5010:          --  Add the vertex to the underlying graph
5011:
5012:          DG.Add_Vertex (G.Graph, Vertex);
5013:
5014:          --  Build and save the attributes of the vertex
5015:
5016:          Set_IGV_Attributes
5017:            (G      => G,
5018:             Vertex => Vertex,
5019:             Val    => (Body_Vertex => Body_Vertex,
5020:                        Construct   => IC_Id,
5021:                        Spec_Vertex => Spec_Vertex));
5022:
5023:          --  Associate the construct with its corresponding vertex
5024:
5025:          Set_Corresponding_Vertex (G, Construct_Signature, Vertex);
5026:
5027:          --  Save the vertex for later processing when it denotes a spec or
5028:          --  body elaboration procedure.
5029:
5030:          if Is_Elaboration_Root (G, Vertex) then
5031:             Save_Elaboration_Root (G, Vertex);
5032:          end if;
5033:       end Add_Vertex;
```

## `bindo-graphs.adb:5099`

```ada
5099:       function Create
5100:         (Initial_Vertices : Positive;
5101:          Initial_Edges    : Positive;
5102:          Lib_Graph        : Library_Graphs.Library_Graph)
5103:         return Invocation_Graph
5104:       is
5105:          G : constant Invocation_Graph := new Invocation_Graph_Attributes'
5106:            (Counts              => <>,
5107:             Edge_Attributes     => IGE_Tables.Create       (Initial_Edges),
5108:             Graph               =>
5109:               DG.Create
5110:                 (Initial_Vertices => Initial_Vertices,
5111:                  Initial_Edges    => Initial_Edges),
5112:             Relations           => Relation_Sets.Create    (Initial_Edges),
5113:             Roots               => IGV_Sets.Create         (Initial_Vertices),
5114:             Signature_To_Vertex => Signature_Tables.Create (Initial_Vertices),
5115:             Vertex_Attributes   => IGV_Tables.Create       (Initial_Vertices),
5116:             Lib_Graph           => Lib_Graph);
5117:       begin
5118:          return G;
5119:       end Create;
```

## `bindo-graphs.adb:5274`

```ada
5274:       function Hash_Invocation_Signature
5275:         (IS_Id : Invocation_Signature_Id) return Bucket_Range_Type
5276:       is
5277:       begin
5278:          pragma Assert (Present (IS_Id));
5279:
5280:          return Bucket_Range_Type (IS_Id);
5281:       end Hash_Invocation_Signature;
5282:
5283:       ---------------------------------
5284:       -- Hash_Source_Target_Relation --
5285:       ---------------------------------
5286:
5287:       function Hash_Source_Target_Relation
5288:         (Rel : Source_Target_Relation) return Bucket_Range_Type
5289:       is
5290:       begin
5291:          pragma Assert (Present (Rel.Source));
5292:          pragma Assert (Present (Rel.Target));
5293:
5294:          return
5295:            Hash_Two_Keys
5296:              (Bucket_Range_Type (Rel.Source),
5297:               Bucket_Range_Type (Rel.Target));
5298:       end Hash_Source_Target_Relation;
5299:
5300:       -------------------------------------------
5301:       -- Increment_Invocation_Graph_Edge_Count --
5302:       -------------------------------------------
5303:
5304:       procedure Increment_Invocation_Graph_Edge_Count
5305:         (G    : Invocation_Graph;
5306:          Kind : Invocation_Kind)
5307:       is
5308:          pragma Assert (Present (G));
5309:
5310:          Count : Natural renames G.Counts (Kind);
5311:
5312:       begin
5313:          Count := Count + 1;
5314:       end Increment_Invocation_Graph_Edge_Count;
```

## `bindo-graphs.adb:5334`

```ada
5334:       function Is_Elaboration_Root
5335:         (G      : Invocation_Graph;
5336:          Vertex : Invocation_Graph_Vertex_Id) return Boolean
5337:       is
5338:          pragma Assert (Present (G));
5339:          pragma Assert (Present (Vertex));
5340:
5341:          Vertex_Kind : constant Invocation_Construct_Kind :=
5342:                          Kind (Construct (G, Vertex));
5343:
5344:       begin
5345:          return
5346:            Vertex_Kind = Elaborate_Body_Procedure
5347:              or else
5348:            Vertex_Kind = Elaborate_Spec_Procedure;
5349:       end Is_Elaboration_Root;
```

## `bindo-graphs.adb:5760`

```ada
5760:    IGE_Sequencer : Invocation_Graph_Edge_Id := First_Invocation_Graph_Edge;
5761:    --  The counter for invocation graph edges. Do not directly manipulate its
5762:    --  value.
5763:
5764:    function Sequence_Next_Edge return Invocation_Graph_Edge_Id is
5765:       Edge : constant Invocation_Graph_Edge_Id := IGE_Sequencer;
5766:
5767:    begin
5768:       IGE_Sequencer := IGE_Sequencer + 1;
5769:       return Edge;
5770:    end Sequence_Next_Edge;
5771:
5772:    --------------------------
5773:    -- Sequence_Next_Vertex --
5774:    --------------------------
5775:
5776:    IGV_Sequencer : Invocation_Graph_Vertex_Id := First_Invocation_Graph_Vertex;
5777:    --  The counter for invocation graph vertices. Do not directly manipulate
5778:    --  its value.
5779:
5780:    function Sequence_Next_Vertex return Invocation_Graph_Vertex_Id is
5781:       Vertex : constant Invocation_Graph_Vertex_Id := IGV_Sequencer;
5782:
5783:    begin
5784:       IGV_Sequencer := IGV_Sequencer + 1;
5785:       return Vertex;
5786:    end Sequence_Next_Vertex;
```

## `bindo-units.adb:255`

```ada
255:    procedure Initialize_Units is
256:    begin
257:       Elaborable_Constructs := Signature_Sets.Create (Number_Of_Units);
258:       Elaborable_Units      := Unit_Sets.Create      (Number_Of_Units);
259:    end Initialize_Units;
```

## `bindo-units.adb:391`

```ada
391:    function Number_Of_Elaborable_Units return Natural is
392:    begin
393:       return Unit_Sets.Size (Elaborable_Units);
394:    end Number_Of_Elaborable_Units;
395:
396:    ---------------------
397:    -- Number_Of_Units --
398:    ---------------------
399:
400:    function Number_Of_Units return Natural is
401:    begin
402:       return Natural (ALI.Units.Last) - Natural (ALI.Units.First) + 1;
403:    end Number_Of_Units;
404:
405:    ----------------------------------
406:    -- Process_Invocation_Construct --
407:    ----------------------------------
408:
409:    procedure Process_Invocation_Construct (IC_Id : Invocation_Construct_Id) is
410:       pragma Assert (Present (IC_Id));
411:
412:       IS_Id : constant Invocation_Signature_Id := Signature (IC_Id);
413:
414:       pragma Assert (Present (IS_Id));
415:
416:    begin
417:       Signature_Sets.Insert (Elaborable_Constructs, IS_Id);
418:    end Process_Invocation_Construct;
```

## `bindo-units.adb:441`

```ada
441:    procedure Process_Unit (U_Id : Unit_Id) is
442:    begin
443:       pragma Assert (Present (U_Id));
444:
445:       --  A stand-alone library unit must not be elaborated as part of the
446:       --  current compilation because the library already carries its own
447:       --  elaboration code.
448:
449:       if Is_Stand_Alone_Library_Unit (U_Id) then
450:          null;
451:
452:       --  Otherwise the unit needs to be elaborated. Add it to the set
453:       --  of units that require elaboration, as well as all invocation
454:       --  signatures of constructs it declares.
455:
456:       else
457:          Unit_Sets.Insert (Elaborable_Units, U_Id);
458:          Process_Invocation_Constructs (U_Id);
459:       end if;
460:    end Process_Unit;
```

## `bindo-units.ads:40`

```ada
40:    function Hash_Unit (U_Id : Unit_Id) return Bucket_Range_Type;
41:    pragma Inline (Hash_Unit);
42:    --  Obtain the hash value of key U_Id
43:
44:    package Unit_Sets is new Membership_Sets
45:      (Element_Type => Unit_Id,
46:       "="          => "=",
47:       Hash         => Hash_Unit);
48:
```

## `bindo-augmentors.adb:140`

```ada
140:       procedure Visit_Elaboration_Root
141:         (Inv_Graph : Invocation_Graph;
142:          Root      : Invocation_Graph_Vertex_Id)
143:       is
144:          Lib_Graph : constant Library_Graph := Get_Lib_Graph (Inv_Graph);
145:          pragma Assert (Present (Inv_Graph));
146:          pragma Assert (Present (Lib_Graph));
147:          pragma Assert (Present (Root));
148:
149:          Root_Vertex : constant Library_Graph_Vertex_Id :=
150:                          Body_Vertex (Inv_Graph, Root);
151:
152:          Visited : IGV_Sets.Membership_Set;
153:
154:       begin
155:          --  Nothing to do when the unit where the elaboration root resides
156:          --  lacks elaboration code. This implies that any invocation edges
157:          --  going out of the unit are unwanted. This behavior emulates the
158:          --  old elaboration order mechanism.
159:
160:          if Has_No_Elaboration_Code (Lib_Graph, Root_Vertex) then
161:             return;
162:          end if;
163:
164:          --  Prepare the global data
165:
166:          Visited := IGV_Sets.Create (Number_Of_Vertices (Inv_Graph));
167:
168:          Visit_Vertex
169:            (Inv_Graph                  => Inv_Graph,
170:             Invoker                    => Root,
171:             Last_Vertex                => Root_Vertex,
172:             Root_Vertex                => Root_Vertex,
173:             Visited_Invokers           => Visited,
174:             Activates_Task             => False,
175:             Internal_Controlled_Action => False,
176:             Path                       => 0);
177:
178:          IGV_Sets.Destroy (Visited);
179:       end Visit_Elaboration_Root;
180:
181:       -----------------------------
182:       -- Visit_Elaboration_Roots --
183:       -----------------------------
184:
185:       procedure Visit_Elaboration_Roots (Inv_Graph : Invocation_Graph) is
186:          Lib_Graph : constant Library_Graph := Get_Lib_Graph (Inv_Graph);
187:          pragma Assert (Present (Inv_Graph));
188:          pragma Assert (Present (Lib_Graph));
189:
190:          Iter : Elaboration_Root_Iterator;
191:          Root : Invocation_Graph_Vertex_Id;
192:
193:       begin
194:          Iter := Iterate_Elaboration_Roots (Inv_Graph);
195:          while Has_Next (Iter) loop
196:             Next (Iter, Root);
197:
198:             Visit_Elaboration_Root (Inv_Graph => Inv_Graph, Root => Root);
199:          end loop;
200:       end Visit_Elaboration_Roots;
```

## `bindo-elaborators.adb:704`

```ada
704:       procedure Elaborate_Units
705:         (Order         : out Unit_Id_Table;
706:          Main_Lib_File : File_Name_Type)
707:       is
708:          pragma Unreferenced (Main_Lib_File);
709:
710:          Inv_Graph : Invocation_Graph;
711:          Lib_Graph : Library_Graph;
712:          Status    : Elaboration_Order_Status;
713:
714:       begin
715:          Start_Phase (Unit_Elaboration);
716:
717:          --  Initialize all unit-related data structures and gather all units
718:          --  that need elaboration.
719:
720:          Initialize_Units;
721:          Collect_Elaborable_Units;
722:
723:          --  Create the library graph that captures the dependencies between
724:          --  library items.
725:
726:          Lib_Graph := Build_Library_Graph;
727:
728:          --  Create the invocation graph that represents the flow of execution
729:
730:          Inv_Graph := Build_Invocation_Graph (Lib_Graph);
731:
732:          --  Traverse the invocation graph starting from elaboration code in
733:          --  order to discover transitions of the execution flow from a unit
734:          --  to a unit that result in extra edges within the library graph.
735:
736:          Augment_Library_Graph (Inv_Graph);
737:
738:          --  Create the component graph by collapsing all library items into
739:          --  library units and traversing the library graph.
740:
741:          Find_Components (Lib_Graph);
742:
743:          --  Output the contents of the ALI tables and both graphs to standard
744:          --  output now that they have been fully decorated.
745:
746:          Write_ALI_Tables;
747:          Write_Invocation_Graph (Inv_Graph);
748:          Write_Library_Graph    (Lib_Graph);
749:
750:          --  Traverse the library graph to determine the elaboration order of
751:          --  units.
752:
753:          Elaborate_Library_Graph (Lib_Graph, Order, Status);
754:
755:          --  The elaboration order is satisfactory
756:
757:          if Status = Order_OK then
758:             Validate_Elaboration_Order (Order);
759:
760:             --  Set attribute Elab_Position of table ALI.Units for all units in
761:             --  the elaboration order.
762:
763:             Set_Unit_Elaboration_Positions (Order);
764:
765:             --  Output the dependencies among units when switch -e (output
766:             --  complete list of elaboration order dependencies) is active.
767:
768:             Write_Dependencies (Lib_Graph);
769:
770:             --  Output the elaboration order when switch -l (output chosen
771:             --  elaboration order) is in effect.
772:
773:             Write_Elaboration_Order (Order);
774:
775:             --  Output the sources referenced in the closure of the order when
776:             --  switch -R (list sources referenced in closure) is in effect.
777:
778:             Write_Unit_Closure (Order);
779:
780:          --  Otherwise the library graph contains at least one circularity
781:
782:          else
783:             Diagnose_Circularities (Inv_Graph);
784:          end if;
785:
786:          Destroy (Inv_Graph);
787:          Destroy (Lib_Graph);
788:
789:          --  Destroy all unit-related data structures
790:
791:          Finalize_Units;
792:          End_Phase (Unit_Elaboration);
793:
794:          --  Halt the bind when there is no satisfactory elaboration order
795:
796:          if Status /= Order_OK then
797:             raise Unrecoverable_Error;
798:          end if;
799:       end Elaborate_Units;
```

## `bindo-writers.adb:95`

```ada
95:       procedure Write_ALI_Tables is
96:       begin
97:          --  Nothing to do when switch -d_A (output invocation tables) is not
98:          --  in effect.
99:
100:          if not Debug_Flag_Underscore_AA then
101:             return;
102:          end if;
103:
104:          Write_Str ("ALI Tables");
105:          Write_Eol;
```

## `bindo-writers.adb:830`

```ada
830:       procedure Write_Invocation_Graph (G : Invocation_Graph) is
831:       begin
832:          pragma Assert (Present (G));
833:
834:          --  Nothing to do when switch -d_I (output invocation graph) is not in
835:          --  effect.
836:
837:          if not Debug_Flag_Underscore_II then
838:             return;
839:          end if;
840:
```

## `libgnat/g-dynhta.ads:296`

```ada
296:    subtype Factor_Type is Bucket_Range_Type range 2 .. 100;
297:
298:    --  The following type denotes the threshold range used in expansion and
299:    --  compression of the hash table.
300:
301:    subtype Threshold_Type is Long_Float range 0.0 .. Long_Float'Last;
```

## `libgnat/g-dynhta.ads:462`

```ada
462:       type Node is record
463:          Key   : Key_Type;
464:          Value : Value_Type := No_Value;
465:          --  Key-value pair stored in a bucket
466:
467:          Prev : Node_Ptr := null;
468:          Next : Node_Ptr := null;
469:       end record;
470:
471:       --  The following type represents a bucket table. Each bucket contains a
472:       --  circular doubly linked list of nodes with a dummy head. Initially,
473:       --  the head does not refer to itself. This is intentional because it
474:       --  improves the performance of creation, compression, and expansion by
475:       --  avoiding a separate pass to link a head to itself. Several routines
476:       --  ensure that the head is properly formed.
477:
478:       type Bucket_Table is array (Bucket_Range_Type range <>) of aliased Node;
479:       type Bucket_Table_Ptr is access Bucket_Table;
480:
481:       --  The following type represents a hash table
482:
483:       type Dynamic_Hash_Table_Attributes is record
484:          Buckets : Bucket_Table_Ptr := null;
485:          --  Reference to the compressing / expanding buckets
486:
487:          Initial_Size : Bucket_Range_Type := 0;
488:          --  The initial size of the buckets as specified at creation time
489:
490:          Iterators : Natural := 0;
491:          --  Number of outstanding iterators
492:
493:          Pairs : Natural := 0;
494:          --  Number of key-value pairs in the buckets
495:       end record;
```

## `libgnat/g-dynhta.adb:40`

```ada
40:    function Hash_Two_Keys
41:      (Left  : Bucket_Range_Type;
42:       Right : Bucket_Range_Type) return Bucket_Range_Type
43:    is
44:       Half : constant := 2 ** (Bucket_Range_Type'Size / 2);
45:       Mask : constant := Half - 1;
46:
47:    begin
48:       --  The hash is obtained in the following manner:
49:       --
50:       --    1) The low bits of Left are obtained, then shifted over to the high
51:       --       bits position.
52:       --
53:       --    2) The low bits of Right are obtained
54:       --
55:       --  The results from 1) and 2) are or-ed to produce a value within the
56:       --  range of Bucket_Range_Type.
57:
58:       return
59:         (Left  and Mask) * Half
60:             or
61:         (Right and Mask);
62:    end Hash_Two_Keys;
```

## `libgnat/g-dynhta.adb:546`

```ada
546:       function Create (Initial_Size : Positive) return Dynamic_Hash_Table is
547:          Size : constant Bucket_Range_Type :=
548:                            Bucket_Range_Type'Max
549:                              (Bucket_Range_Type (Initial_Size), Minimum_Size);
550:          --  Ensure that the buckets meet a minimum size
551:
552:          T : constant Dynamic_Hash_Table := new Dynamic_Hash_Table_Attributes;
553:
554:       begin
555:          T.Buckets      := new Bucket_Table (0 .. Size - 1);
556:          T.Initial_Size := Size;
557:
558:          return T;
559:       end Create;
```

## `libgnat/g-dynhta.adb:977`

```ada
977:       function Load_Factor (T : Dynamic_Hash_Table) return Threshold_Type is
978:          pragma Assert (Present (T));
979:          pragma Assert (Present (T.Buckets));
980:
981:       begin
982:          --  The load factor is the ratio of key-value pairs to buckets
983:
984:          return Threshold_Type (T.Pairs) / Threshold_Type (T.Buckets'Length);
985:       end Load_Factor;
986:
987:       ----------
988:       -- Lock --
989:       ----------
990:
991:       procedure Lock (T : Dynamic_Hash_Table) is
992:       begin
993:          --  The hash table may be locked multiple times if multiple iterators
994:          --  are operating over it.
995:
996:          T.Iterators := T.Iterators + 1;
997:       end Lock;
```

## `libgnat/g-dynhta.adb:1085`

```ada
1085:       begin
1086:          pragma Assert (Present (T));
1087:
1088:          Old_Bkts  := T.Buckets;
1089:          T.Buckets := new Bucket_Table (0 .. Size - 1);
1090:
1091:          --  Transfer and rehash all key-value pairs from the old buckets to
1092:          --  the new buckets.
1093:
1094:          Rehash (From => Old_Bkts, To => T.Buckets);
1095:          Free (Old_Bkts);
1096:       end Mutate_And_Rehash;
```

## `libgnat/g-dynhta.adb:1212`

```ada
1212:          procedure Expand is
1213:             pragma Assert (Present (T));
1214:             pragma Assert (Present (T.Buckets));
1215:
1216:             Old_Size : constant Bucket_Range_Type := T.Buckets'Length;
1217:
1218:          begin
1219:             --  The ratio of pairs to buckets is over the desited threshold.
1220:             --  Expand the hash table only when there is still room to do so.
1221:
1222:             if Load_Factor (T) > Expansion_Threshold
1223:               and then Old_Size <= Safe_Expansion_Size
1224:             then
1225:                Mutate_And_Rehash (T, Old_Size * Expansion_Factor);
1226:             end if;
1227:          end Expand;
```

## `libgnat/g-dynhta.adb:1233`

```ada
1233:          procedure Prepend_Or_Replace (Head : Node_Ptr) is
1234:             pragma Assert (Present (Head));
1235:
1236:             Nod : Node_Ptr;
1237:
1238:          begin
1239:             --  If the bucket containst at least one valid node, then there is
1240:             --  a chance that a node with the same key as Key exists. If this
1241:             --  is the case, the value of that node must be updated.
1242:
1243:             Nod := Head.Next;
1244:             while Is_Valid (Nod, Head) loop
1245:                if Nod.Key = Key then
1246:                   Nod.Value := Value;
1247:                   return;
1248:                end if;
1249:
1250:                Nod := Nod.Next;
1251:             end loop;
1252:
1253:             --  At this point the bucket is either empty, or none of the nodes
1254:             --  match key Key. Prepend a new key-value pair.
1255:
1256:             Nod := new Node'(Key, Value, null, null);
1257:
1258:             Prepend (Nod, Head);
1259:
1260:             --  The number of key-value pairs must be updated for a prepend,
1261:             --  never for a replace.
1262:
1263:             T.Pairs := T.Pairs + 1;
1264:          end Prepend_Or_Replace;
```

## `libgnat/g-graphs.ads:397`

```ada
397:       type Edge_Attributes is record
398:          Destination : Vertex_Id := No_Vertex;
399:          --  The target of a directed edge
400:
401:          Source : Vertex_Id := No_Vertex;
402:          --  The origin of a directed edge. The source vertex "owns" the edge.
403:       end record;
```

## `libgnat/g-graphs.ads:449`

```ada
449:       type Vertex_Attributes is record
450:          Component : Component_Id := No_Component;
451:          --  The component where a vertex lives
452:
453:          Outgoing_Edges : Edge_Set.Membership_Set := Edge_Set.Nil;
454:          --  The set of edges that extend out from a vertex
455:       end record;
```

## `libgnat/g-graphs.ads:480`

```ada
480:       type Component_Attributes is record
481:          Vertices : Vertex_List.Doubly_Linked_List := Vertex_List.Nil;
482:       end record;
```

## `libgnat/g-graphs.ads:507`

```ada
507:       type Directed_Graph_Attributes is record
508:          All_Edges : Edge_Map.Dynamic_Hash_Table := Edge_Map.Nil;
509:          --  The map of edge -> edge attributes for all edges in the graph
510:
511:          All_Vertices : Vertex_Map.Dynamic_Hash_Table := Vertex_Map.Nil;
512:          --  The map of vertex -> vertex attributes for all vertices in the
513:          --  graph.
514:
515:          Components : Component_Map.Dynamic_Hash_Table := Component_Map.Nil;
516:          --  The map of component -> component attributes for all components
517:          --  in the graph.
518:       end record;
```

## `libgnat/g-graphs.adb:181`

```ada
181:         (G           : Directed_Graph;
182:          E           : Edge_Id;
183:          Source      : Vertex_Id;
184:          Destination : Vertex_Id)
185:       is
186:       begin
187:          Ensure_Created (G);
188:          Ensure_Not_Present (G, E);
189:          Ensure_Present (G, Source);
190:          Ensure_Present (G, Destination);
191:
192:          --  Add the edge to the set of all edges in the graph
193:
194:          Edge_Map.Put
195:            (T     => G.All_Edges,
196:             Key   => E,
197:             Value =>
198:               (Destination => Destination,
199:                Source      => Source));
200:
201:          --  Associate the edge with its source vertex which effectively "owns"
202:          --  the edge.
203:
204:          Edge_Set.Insert
205:            (S    => Get_Outgoing_Edges (G, Source),
206:             Elem => E);
207:       end Add_Edge;
208:
209:       ----------------
210:       -- Add_Vertex --
211:       ----------------
212:
213:       procedure Add_Vertex
214:         (G : Directed_Graph;
215:          V : Vertex_Id)
216:       is
217:       begin
218:          Ensure_Created (G);
219:          Ensure_Not_Present (G, V);
220:
221:          --  Add the vertex to the set of all vertices in the graph
222:
223:          Vertex_Map.Put
224:            (T     => G.All_Vertices,
225:             Key   => V,
226:             Value =>
227:               (Component      => No_Component,
228:                Outgoing_Edges => Edge_Set.Nil));
229:
230:          --  It is assumed that the vertex will have at least one outgoing
231:          --  edge. It is important not to create the set of edges above as
232:          --  the call to Put may fail in case the vertices are iterated.
233:          --  This would lead to a memory leak because the set would not be
234:          --  reclaimed.
235:
236:          Set_Outgoing_Edges (G, V, Edge_Set.Create (1));
237:       end Add_Vertex;
```

## `libgnat/g-graphs.adb:300`

```ada
300:       function Create
301:         (Initial_Vertices : Positive;
302:          Initial_Edges    : Positive) return Directed_Graph
303:       is
304:          G : constant Directed_Graph := new Directed_Graph_Attributes;
305:
306:       begin
307:          G.All_Edges    := Edge_Map.Create      (Initial_Edges);
308:          G.All_Vertices := Vertex_Map.Create    (Initial_Vertices);
309:          G.Components   := Component_Map.Create (Initial_Vertices);
310:
311:          return G;
312:       end Create;
```

## `libgnat/g-sets.ads:162`

```ada
162:       package Hashed_Set is new Dynamic_Hash_Tables
163:         (Key_Type              => Element_Type,
164:          Value_Type            => Boolean,
165:          No_Value              => False,
166:          Expansion_Threshold   => 1.5,
167:          Expansion_Factor      => 2,
168:          Compression_Threshold => 0.3,
169:          Compression_Factor    => 2,
170:          "="                   => "=",
171:          Destroy_Value         => Destroy,
172:          Hash                  => Hash);
173:
174:       type Membership_Set is new Hashed_Set.Dynamic_Hash_Table;
```

## `libgnat/g-sets.adb:56`

```ada
56:       function Create (Initial_Size : Positive) return Membership_Set is
57:       begin
58:          return Membership_Set (Hashed_Set.Create (Initial_Size));
59:       end Create;
```

## `libgnat/g-lists.ads:217`

```ada
217:       type Node is record
218:          Elem : Element_Type;
219:
220:          Next : Node_Ptr := null;
221:          Prev : Node_Ptr := null;
222:       end record;
223:
224:       --  The following type represents a list
225:
226:       type Doubly_Linked_List_Attributes is record
227:          Elements : Natural := 0;
228:          --  The number of elements in the list
229:
230:          Iterators : Natural := 0;
231:          --  Number of outstanding iterators
232:
233:          Nodes : aliased Node;
234:          --  The dummy head of the list
235:       end record;
```

## `libgnat/g-lists.adb:141`

```ada
141:       function Create return Doubly_Linked_List is
142:       begin
143:          return new Doubly_Linked_List_Attributes;
144:       end Create;
```

## `libgnat/gnat.ads:43`

```ada
43:    --  The following type denotes the range of buckets for various hashed
44:    --  data structures in the GNAT unit hierarchy.
45:
46:    type Bucket_Range_Type is mod 2 ** 32;
```

## `namet.ads:186`

```ada
186:    type Name_Id is range Names_Low_Bound .. Names_High_Bound;
187:    for Name_Id'Size use 32;
188:    --  Type used to identify entries in the names table
189:
190:    No_Name : constant Name_Id := Names_Low_Bound;
191:    --  The special Name_Id value No_Name is used in the parser to indicate
192:    --  a situation where no name is present (e.g. on a loop or block).
193:
194:    Error_Name : constant Name_Id := Names_Low_Bound + 1;
195:    --  The special Name_Id value Error_Name is used in the parser to
196:    --  indicate that some kind of error was encountered in scanning out
197:    --  the relevant name, so it does not have a representable label.
198:
199:    First_Name_Id : constant Name_Id := Names_Low_Bound + 2;
200:    --  Subscript of first entry in names table
201:
202:    subtype Valid_Name_Id is Name_Id range First_Name_Id .. Name_Id'Last;
```

## `namet.ads:562`

```ada
562:    package Name_Chars is new Table.Table (
563:      Table_Component_Type => Character,
564:      Table_Index_Type     => Int,
565:      Table_Low_Bound      => 0,
566:      Table_Initial        => Alloc.Name_Chars_Initial,
567:      Table_Increment      => Alloc.Name_Chars_Increment,
568:      Table_Name           => "Name_Chars");
```

## `namet.ads:606`

```ada
606:    for Name_Entry use record
607:       Name_Chars_Index      at  0 range 0 .. 31;
608:       Name_Len              at  4 range 0 .. 15;
609:       Byte_Info             at  6 range 0 .. 7;
610:       Name_Has_No_Encodings at  7 range 0 .. 0;
611:       Boolean1_Info         at  7 range 1 .. 1;
612:       Boolean2_Info         at  7 range 2 .. 2;
613:       Boolean3_Info         at  7 range 3 .. 3;
614:       Spare                 at  7 range 4 .. 7;
615:       Hash_Link             at  8 range 0 .. 31;
616:       Int_Info              at 12 range 0 .. 31;
617:    end record;
618:    --  This ensures a matching layout between Ada and C
619:
620:    for Name_Entry'Size use 16 * 8;
621:    --  This ensures that record is reasonably small
622:
623:    --  This is the table that is referenced by Valid_Name_Id entries.
624:    --  It contains one entry for each unique name in the table.
625:
626:    package Name_Entries is new Table.Table (
627:      Table_Component_Type => Name_Entry,
628:      Table_Index_Type     => Valid_Name_Id'Base,
629:      Table_Low_Bound      => First_Name_Id,
630:      Table_Initial        => Alloc.Names_Initial,
631:      Table_Increment      => Alloc.Names_Increment,
632:      Table_Name           => "Name_Entries");
```

## `namet.adb:1138`

```ada
1138:    function Name_Enter
1139:      (Buf : Bounded_String := Global_Name_Buffer) return Valid_Name_Id
1140:    is
1141:    begin
1142:       Name_Entries.Append
1143:         ((Name_Chars_Index      => Name_Chars.Last,
1144:           Name_Len              => Short (Buf.Length),
1145:           Byte_Info             => 0,
1146:           Int_Info              => 0,
1147:           Hash_Link             => No_Name,
1148:           Name_Has_No_Encodings => False,
1149:           Boolean1_Info         => False,
1150:           Boolean2_Info         => False,
1151:           Boolean3_Info         => False,
1152:           Spare                 => False));
1153:
1154:       --  Set corresponding string entry in the Name_Chars table
1155:
1156:       for J in 1 .. Buf.Length loop
1157:          Name_Chars.Append (Buf.Chars (J));
1158:       end loop;
1159:
1160:       Name_Chars.Append (ASCII.NUL);
1161:
1162:       return Name_Entries.Last;
1163:    end Name_Enter;
```

## `namet.adb:1250`

```ada
1250:          Name_Entries.Append
1251:            ((Name_Chars_Index      => Name_Chars.Last,
1252:              Name_Len              => Short (Buf.Length),
1253:              Hash_Link             => No_Name,
1254:              Int_Info              => 0,
1255:              Byte_Info             => 0,
1256:              Name_Has_No_Encodings => False,
1257:              Boolean1_Info         => False,
1258:              Boolean2_Info         => False,
1259:              Boolean3_Info         => False,
1260:              Spare                 => False));
1261:
1262:          --  Set corresponding string entry in the Name_Chars table
1263:
1264:          for J in 1 .. Buf.Length loop
1265:             Name_Chars.Append (Buf.Chars (J));
1266:          end loop;
1267:
1268:          Name_Chars.Append (ASCII.NUL);
```

## `namet.adb:1309`

```ada
1309:    procedure Reinitialize is
1310:    begin
1311:       Name_Chars.Init;
1312:       Name_Entries.Init;
1313:
1314:       --  Initialize entries for one character names
1315:
1316:       for C in Character loop
1317:          Name_Entries.Append
1318:            ((Name_Chars_Index      => Name_Chars.Last,
1319:              Name_Len              => 1,
1320:              Byte_Info             => 0,
1321:              Int_Info              => 0,
1322:              Hash_Link             => No_Name,
1323:              Name_Has_No_Encodings => True,
1324:              Boolean1_Info         => False,
1325:              Boolean2_Info         => False,
1326:              Boolean3_Info         => False,
1327:              Spare                 => False));
1328:
1329:          Name_Chars.Append (C);
1330:          Name_Chars.Append (ASCII.NUL);
1331:       end loop;
1332:
1333:       --  Clear hash table
1334:
1335:       for J in Hash_Index_Type loop
1336:          Hash_Table (J) := No_Name;
1337:       end loop;
1338:    end Reinitialize;
```

## `snames.adb-tmpl:318`

```ada
318:    procedure Initialize is
319:       P_Index      : Natural;
320:       Discard_Name : Name_Id;
321:
322:    begin
323:       P_Index := Preset_Names'First;
324:       loop
325:          Name_Len := 0;
326:          while Preset_Names (P_Index) /= '#' loop
327:             Name_Len := Name_Len + 1;
328:             Name_Buffer (Name_Len) := Preset_Names (P_Index);
329:             P_Index := P_Index + 1;
330:          end loop;
331:
332:          --  We do the Name_Find call to enter the name into the table, but
333:          --  we don't need to do anything with the result, since we already
334:          --  initialized all the preset names to have the right value (we
335:          --  are depending on the order of the names and Preset_Names).
336:
337:          Discard_Name := Name_Find;
338:          P_Index := P_Index + 1;
339:          exit when Preset_Names (P_Index) = '#';
340:       end loop;
341:
342:       --  Make sure that number of names in standard table is correct. If this
343:       --  check fails, run utility program XSNAMES to construct a new properly
344:       --  matching version of the body.
345:
346:       pragma Assert (Discard_Name = Last_Predefined_Name);
347:
348:       --  Initialize the convention identifiers table with the standard set of
349:       --  synonyms that we recognize for conventions.
350:
351:       Convention_Identifiers.Init;
352:
353:       Convention_Identifiers.Append ((Name_Asm,         Convention_Assembler));
354:       Convention_Identifiers.Append ((Name_Assembly,    Convention_Assembler));
355:
356:       Convention_Identifiers.Append ((Name_Default,     Convention_C));
357:       Convention_Identifiers.Append ((Name_External,    Convention_C));
358:
359:       Convention_Identifiers.Append ((Name_C_Plus_Plus, Convention_CPP));
360:
361:       Convention_Identifiers.Append ((Name_DLL,         Convention_Stdcall));
362:       Convention_Identifiers.Append ((Name_Win32,       Convention_Stdcall));
363:    end Initialize;
```

## `xsnamest.adb:259`

```ada
259:          if Match (Name0, Get_Name) then
260:             Name0 := Name1;
261:             Val   := Val + 1;
262:
263:             if Match (Name0, Findu, M) then
264:                Replace (M, Translate (A, Xlate_U_Und));
265:                Translate (Name0, Lower_Case_Map);
266:
267:             elsif Match (Name0, "UP_", "") then
268:                Translate (Name0, Upper_Case_Map);
269:
270:             elsif Match (Name0, "Op_", "") then
271:                Name0 := 'O' & Translate (Name0, Lower_Case_Map);
272:
273:             else
274:                Translate (Name0, Lower_Case_Map);
275:             end if;
276:
277:             if not Match (Name0, Chk_Low) then
278:                Put_Line (OutB, "     """ & Name0 & "#"" &");
279:             end if;
280:
281:             Output_Header_Line (Name);
```

## `bcheck.adb:135`

```ada
135:       if Present (D.Unit_Name)
136:         and then Is_Spec_Name (D.Unit_Name)
137:         and then Get_Name_Table_Int (D.Unit_Name) = 0 -- no unit table entry?
138:         and then Get_Name_Table_Int (Get_Body_Name (D.Unit_Name)) /= 0
```

## `bcheck.adb:231`

```ada
231:       function Reified_Child_Spec (A : ALI_Id; D : Sdep_Id) return Boolean is
232:          use Uname;
233:       begin
234:          return Present (Sdep.Table (D).Unit_Name)
235:            and then Get_Name_Table_Int (Sdep.Table (D).Unit_Name) = 0
236:            and then D /= ALIs.Table (A).Last_Sdep
237:            and then Sdep.Table (D).Sfile = Sdep.Table (D + 1).Sfile
238:            and then Is_Spec_Name (Sdep.Table (D).Unit_Name)
239:            and then Get_Body_Name (Sdep.Table (D).Unit_Name) =
240:                     Sdep.Table (D + 1).Unit_Name;
```

## `bcheck.adb:1313`

```ada
1313:    procedure Check_Duplicated_Subunits is
1314:    begin
1315:       for J in Sdep.First .. Sdep.Last loop
1316:          if Sdep.Table (J).Subunit_Name /= No_Unit_Name then
1317:             Get_Decoded_Name_String (Sdep.Table (J).Subunit_Name);
1318:             Name_Len := Name_Len + 2;
1319:             Name_Buffer (Name_Len - 1) := '%';
1320:
1321:             --  See if there is a body or spec with the same name
1322:
1323:             for K in Boolean loop
1324:                if K then
1325:                   Name_Buffer (Name_Len) := 'b';
1326:                else
1327:                   Name_Buffer (Name_Len) := 's';
1328:                end if;
1329:
1330:                declare
1331:                   Unit : constant Unit_Name_Type := Name_Find;
1332:                   Info : constant Int := Get_Name_Table_Int (Unit);
```

## `uname.adb:56`

```ada
56:    function Get_Body_Name (N : Unit_Name_Type) return Unit_Name_Type is
57:       Buffer : Bounded_String;
58:    begin
59:       Append (Buffer, N);
60:       pragma Assert (Is_Spec_Name (N));
61:       Buffer.Chars (Buffer.Length) := 'b';
62:       return Name_Find (Buffer);
63:    end Get_Body_Name;
```

## `osint.adb:954`

```ada
954:    function Executable_Prefix return String_Ptr is
955:
956:       function Get_Install_Dir (Exec : String) return String_Ptr;
957:       --  S is the executable name preceded by the absolute or relative
958:       --  path, e.g. "c:\usr\bin\gcc.exe" or "..\bin\gcc".
959:
960:       ---------------------
961:       -- Get_Install_Dir --
962:       ---------------------
963:
964:       function Get_Install_Dir (Exec : String) return String_Ptr is
965:          Full_Path : constant String := Normalize_Pathname (Exec);
966:          --  Use the full path, so that we find "lib" or "bin", even when
967:          --  the tool has been invoked with a relative path, as in
968:          --  "./gnatls -v" invoked in the GNAT bin directory.
969:
970:       begin
971:          for J in reverse Full_Path'Range loop
972:             if Is_Directory_Separator (Full_Path (J)) then
973:                if J < Full_Path'Last - 5 then
974:                   if (To_Lower (Full_Path (J + 1)) = 'l'
975:                       and then To_Lower (Full_Path (J + 2)) = 'i'
976:                       and then To_Lower (Full_Path (J + 3)) = 'b')
977:                     or else
978:                       (To_Lower (Full_Path (J + 1)) = 'b'
979:                        and then To_Lower (Full_Path (J + 2)) = 'i'
980:                        and then To_Lower (Full_Path (J + 3)) = 'n')
981:                   then
982:                      return new String'(Full_Path (Full_Path'First .. J));
983:                   end if;
984:                end if;
985:             end if;
986:          end loop;
987:
988:          return new String'("");
989:       end Get_Install_Dir;
990:
991:    --  Start of processing for Executable_Prefix
992:
993:    begin
994:       if Exec_Name = null then
995:          Exec_Name := new String (1 .. Len_Arg (0));
996:          Osint.Fill_Arg (Exec_Name (1)'Address, 0);
997:       end if;
998:
999:       --  First determine if a path prefix was placed in front of the
1000:       --  executable name.
1001:
1002:       for J in reverse Exec_Name'Range loop
1003:          if Is_Directory_Separator (Exec_Name (J)) then
1004:             return Get_Install_Dir (Exec_Name.all);
1005:          end if;
1006:       end loop;
1007:
1008:       --  If we come here, the user has typed the executable name with no
1009:       --  directory prefix.
1010:
1011:       return Get_Install_Dir (Locate_Exec_On_Path (Exec_Name.all).all);
1012:    end Executable_Prefix;
```

## `osint.adb:1874`

```ada
1874:    procedure Locate_File
1875:      (N     : File_Name_Type;
1876:       T     : File_Type;
1877:       Dir   : Natural;
1878:       Name  : String;
1879:       Found : out File_Name_Type;
1880:       Attr  : access File_Attributes)
1881:    is
1882:       Dir_Name : String_Ptr;
1883:
1884:    begin
1885:       --  If Name is already an absolute path, do not look for a directory
1886:
1887:       if Is_Absolute_Path (Name) then
1888:          Dir_Name := No_Dir;
1889:
1890:       elsif T = Library then
1891:          Dir_Name := Lib_Search_Directories.Table (Dir);
1892:
1893:       else
1894:          pragma Assert (T /= Config);
1895:          Dir_Name := Src_Search_Directories.Table (Dir);
1896:       end if;
1897:
1898:       declare
1899:          Full_Name :
1900:            constant String (1 .. Dir_Name'Length + Name'Length + 1) :=
1901:            Dir_Name.all & Name & ASCII.NUL;
1902:          --  Use explicit bounds, because Dir_Name might be a substring whose
1903:          --  'First is not 1.
1904:
1905:       begin
1906:          Attr.all := Unknown_Attributes;
1907:
1908:          if not Is_Regular_File (Full_Name'Address, Attr) then
1909:             Found := No_File;
1910:
1911:          else
1912:             --  If the file is in the current directory then return N itself
1913:
1914:             if Dir_Name'Length = 0 then
1915:                Found := N;
1916:             else
1917:                Found :=
1918:                  Name_Find (Full_Name (Full_Name'First .. Full_Name'Last - 1));
1919:             end if;
1920:          end if;
1921:       end;
1922:    end Locate_File;
```

## `osint.adb:2186`

```ada
2186:    function Object_File_Name (N : File_Name_Type) return File_Name_Type is
2187:    begin
2188:       if N = No_File then
2189:          return No_File;
2190:       end if;
2191:
2192:       Get_Name_String (N);
2193:       Name_Len := Name_Len - ALI_Suffix'Length - 1;
2194:
2195:       Add_Str_To_Name_Buffer (Target_Object_Suffix);
2196:
2197:       return Name_Enter;
2198:    end Object_File_Name;
```

## `osint.adb:2833`

```ada
2833:    function Relocate_Path
2834:      (Prefix : String;
2835:       Path   : String) return String_Ptr
2836:    is
2837:       S : String_Ptr;
2838:
2839:       procedure set_std_prefix (S : String; Len : Integer);
2840:       pragma Import (C, set_std_prefix);
2841:
2842:    begin
2843:       if Std_Prefix = null then
2844:          Std_Prefix := String_Ptr (Getenv ("GNSA_ROOT"));
2845:
2846:          if Std_Prefix.all = "" then
2847:             Std_Prefix := Executable_Prefix;
2848:
2849:          elsif not Is_Directory_Separator (Std_Prefix (Std_Prefix'Last)) then
2850:
2851:             --  The remainder of this function assumes that Std_Prefix
2852:             --  terminates with a dir separator, so we force this here.
2853:
2854:             declare
2855:                Old_Prefix : String_Ptr := Std_Prefix;
2856:             begin
2857:                Std_Prefix := new String (1 .. Old_Prefix'Length + 1);
2858:                Std_Prefix (1 .. Old_Prefix'Length) := Old_Prefix.all;
2859:                Std_Prefix (Old_Prefix'Length + 1) := Directory_Separator;
2860:                Free (Old_Prefix);
2861:             end;
2862:          end if;
2863:
2864:          if Std_Prefix.all /= "" then
2865:
2866:             --  Remove trailing directory separator when calling set_std_prefix
2867:
2868:             set_std_prefix (Std_Prefix.all, Std_Prefix'Length - 1);
2869:          end if;
2870:       end if;
2871:
2872:       if Path'Last >= Prefix'Last and then Path (Prefix'Range) = Prefix then
2873:          if Std_Prefix.all /= "" then
2874:             S := new String
2875:               (1 .. Std_Prefix'Length + Path'Last - Prefix'Last);
2876:             S (1 .. Std_Prefix'Length) := Std_Prefix.all;
2877:             S (Std_Prefix'Length + 1 .. S'Last) :=
2878:               Path (Prefix'Last + 1 .. Path'Last);
2879:             return S;
2880:          end if;
2881:       end if;
2882:
2883:       return new String'(Path);
2884:    end Relocate_Path;
```

## `osint.adb:3228`

```ada
3228:    function Update_Path (Path : String_Ptr) return String_Ptr is
3229:
3230:       function C_Update_Path (Path, Component : Address) return Address;
3231:       pragma Import (C, C_Update_Path, "update_path");
3232:
3233:       In_Length      : constant Integer := Path'Length;
3234:       In_String      : String (1 .. In_Length + 1);
3235:       Component_Name : aliased String := "GCC" & ASCII.NUL;
3236:       Result_Ptr     : Address;
3237:       Result_Length  : CRTL.size_t;
3238:       Out_String     : String_Ptr;
3239:
3240:    begin
3241:       In_String (1 .. In_Length) := Path.all;
3242:       In_String (In_Length + 1) := ASCII.NUL;
3243:       Result_Ptr := C_Update_Path (In_String'Address, Component_Name'Address);
3244:       Result_Length := CRTL.strlen (Result_Ptr);
3245:
3246:       Out_String := new String (1 .. Integer (Result_Length));
3247:       CRTL.strncpy (Out_String.all'Address, Result_Ptr, Result_Length);
3248:       return Out_String;
3249:    end Update_Path;
```

## `osint-b.adb:67`

```ada
67:    procedure Create_Binder_Output
68:      (Output_File_Name : String;
69:       Typ              : Character;
70:       Bfile            : out Name_Id)
71:    is
72:       File_Name : String_Ptr;
73:       Findex1   : Natural;
74:       Findex2   : Natural;
75:       Flength   : Natural;
76:
77:       Bind_File_Prefix_Len : constant Natural := 2;
78:       --  Length of binder file prefix (2 for b~)
79:
80:    begin
81:       if Output_File_Name /= "" then
82:          Name_Buffer (1 .. Output_File_Name'Length) := Output_File_Name;
83:          Name_Buffer (Output_File_Name'Length + 1)  := ASCII.NUL;
84:
85:          if Typ = 's' then
86:             Name_Buffer (Output_File_Name'Last) := 's';
87:          end if;
88:
89:          Name_Len := Output_File_Name'Last;
```

## `osint-b.adb:145`

```ada
145:       end if;
146:
147:       Bfile := Name_Find;
148:
149:       Create_File_And_Check (Output_FD, Text);
150:    end Create_Binder_Output;
```

## `gnatbind.adb:908`

```ada
908:          Check_Duplicated_Subunits;
909:          Check_Versions;
910:          Check_Consistency;
911:          Check_Configuration_Consistency;
912:       end if;
913:
914:       --  List restrictions that could be applied to this partition
915:
916:       if List_Restrictions then
917:          List_Applicable_Restrictions;
918:       end if;
919:
920:       --  Complete bind if no errors
921:
922:       if Errors_Detected = 0 then
923:          declare
924:             use Unit_Id_Tables;
925:             Elab_Order : Unit_Id_Table;
926:
927:          begin
928:             Find_Elaboration_Order (Elab_Order, First_Main_Lib_File);
929:
930:             if Errors_Detected = 0 and then not Check_Only then
931:                Gen_Output_File
932:                  (Output_File_Name.all,
933:                   Elab_Order => Elab_Order.Table (First .. Last (Elab_Order)));
934:             end if;
935:          end;
```

## `targparm.adb:140`

```ada
140:    procedure Get_Target_Parameters
141:      (Make_Id : Make_Id_Type := null;
142:       Make_SC : Make_SC_Type := null;
143:       Set_NOD : Set_NOD_Type := null;
144:       Set_NSA : Set_NSA_Type := null;
145:       Set_NUA : Set_NUA_Type := null;
146:       Set_NUP : Set_NUP_Type := null)
147:    is
148:       FD   : File_Descriptor;
149:       Hi   : Source_Ptr;
150:       Text : Source_Buffer_Ptr;
151:
152:    begin
153:       if Parameters_Obtained then
154:          return;
155:       end if;
156:
157:       Read_Source_File (Name_Find ("system.ads"), 0, Hi, Text, FD);
```

## `ali.ads:1185`

```ada
1185:    type Invocation_Kind is
1186:      (Accept_Alternative,
1187:       Access_Taken,
1188:       Call,
1189:       Controlled_Adjustment,
1190:       Controlled_Finalization,
1191:       Controlled_Initialization,
1192:       Default_Initial_Condition_Verification,
1193:       Initial_Condition_Verification,
1194:       Instantiation,
1195:       Internal_Controlled_Adjustment,
1196:       Internal_Controlled_Finalization,
1197:       Internal_Controlled_Initialization,
1198:       Invariant_Verification,
1199:       Postcondition_Verification,
1200:       Protected_Entry_Call,
1201:       Protected_Subprogram_Call,
1202:       Task_Activation,
1203:       Task_Entry_Call,
1204:       Type_Initialization,
1205:       No_Invocation);
```

## `alloc.ads:88`

```ada
88:    Name_Chars_Initial               : constant := 50_000;     -- Namet
89:    Name_Chars_Increment             : constant := 100;
90:
91:    Name_Qualify_Units_Initial       : constant := 200;        -- Exp_Dbug
92:    Name_Qualify_Units_Increment     : constant := 300;
93:
94:    Names_Initial                    : constant := 6_000;      -- Namet
95:    Names_Increment                  : constant := 100;
```

## `table.adb:168`

```ada
168:          New_Size   : Memory.size_t;
169:          New_Length : Long_Long_Integer;
170:
171:       begin
172:          if Max < Last_Val then
173:             pragma Assert (not Locked);
174:
175:             --  Make sure that we have at least the initial allocation. This
176:             --  is needed in cases where a zero length table is written out.
177:
178:             Length := Int'Max (Length, Table_Initial);
179:
180:             --  Now increment table length until it is sufficiently large. Use
181:             --  the increment value or 10, which ever is larger (the reason
182:             --  for the use of 10 here is to ensure that the table does really
183:             --  increase in size (which would not be the case for a table of
184:             --  length 10 increased by 3% for instance). Do the intermediate
185:             --  calculation in Long_Long_Integer to avoid overflow.
186:
187:             while Max < Last_Val loop
188:                New_Length :=
189:                  Long_Long_Integer (Length) *
190:                     (100 + Long_Long_Integer (Table_Increment)) / 100;
191:                Length := Int'Max (Int (New_Length), Length + 10);
192:                Max := Min + Length - 1;
193:             end loop;
194:
195:             if Debug_Flag_D then
196:                Write_Str ("--> Allocating new ");
197:                Write_Str (Table_Name);
198:                Write_Str (" table, size = ");
199:                Write_Int (Max - Min + 1);
200:                Write_Eol;
201:             end if;
202:          end if;
203:
204:          --  Do the intermediate calculation in size_t to avoid signed overflow
205:
206:          New_Size :=
207:            Memory.size_t (Max - Min + 1) *
```

## `types.ads:344`

```ada
344:    Names_Low_Bound : constant := -399_999_999;
345:
346:    Names_High_Bound : constant := -300_000_000;
```

## `libgnat/s-os_lib.adb:2052`

```ada
2052:       function Get_File_Names_Case_Sensitive return Integer;
2053:       pragma Import
2054:         (C, Get_File_Names_Case_Sensitive,
2055:          "__gnat_get_file_names_case_sensitive");
2056:
2057:       Max_Path : Integer;
2058:       pragma Import (C, Max_Path, "__gnat_max_path_len");
2059:       --  Maximum length of a path name
2060:
2061:       function Readlink
2062:         (Path   : System.Address;
2063:          Buf    : System.Address;
2064:          Bufsiz : size_t) return Integer;
2065:       pragma Import (C, Readlink, "__gnat_readlink");
2066:
2067:       Fold_To_Lower_Case : constant Boolean :=
2068:                              not Case_Sensitive
2069:                                  and then Get_File_Names_Case_Sensitive = 0;
2070:
2071:       Cur_Dir_Len : Natural  := 0;
2072:       End_Path    : Natural  := Name'Length;
2073:       Last        : Positive := 1;
2074:       Path_Buffer : String (1 .. End_Path + 2 * Max_Path + 4);
2075:       --  We need to potentially store in this buffer the following elements:
2076:       --  the path itself, the current directory if the path is relative,
2077:       --  and additional fragments up to Max_Path in length in case
2078:       --  there are any symlinks.
2079:
2080:       function Final_Value (S : String) return String;
```

## `libgnat/s-os_lib.adb:2133`

```ada
2133:       function Final_Value (S : String) return String is
2134:          S1 : String := S;
2135:          --  We may need to fold S to lower case, so we need a variable
2136:
2137:          Last : Natural;
2138:
2139:       begin
2140:          if Fold_To_Lower_Case then
2141:             System.Case_Util.To_Lower (S1);
2142:          end if;
2143:
2144:          --  Remove trailing directory separator, if any
2145:
2146:          Last := S1'Last;
2147:
2148:          if Last > 1 and then Is_Dirsep (S1 (Last))
2149:            and then not
2150:              (On_Windows -- Special case for Windows: C:\
2151:               and then Last = 3
2152:               and then S1 (1) /= Directory_Separator
2153:               and then S1 (2) = ':')
2154:          then
2155:             Last := Last - 1;
2156:          end if;
2157:
2158:          --  And ensure that there is a trailing directory separator if the
2159:          --  path contains only a drive letter.
2160:
2161:          if On_Windows
2162:            and then Last = 2
2163:            and then S1 (1) /= Directory_Separator
2164:            and then S1 (2) = ':'
2165:          then
2166:             return S1 (1 .. Last) & Directory_Separator;
2167:          else
2168:             return S1 (1 .. Last);
2169:          end if;
2170:       end Final_Value;
```

## `libgnat/s-os_lib.adb:2245`

```ada
2245:       Link_Buffer : String (1 .. Max_Path + 2);
2246:
2247:       Finish : Positive;
2248:       Start  : Positive;
2249:       Status : Integer;
2250:
2251:    --  Start of processing for Normalize_Pathname
2252:
2253:    begin
2254:       --  Special case, return null if name is null
2255:
2256:       if End_Path = 0 then
2257:          return "";
2258:       end if;
2259:
2260:       if Is_Absolute_Path (Name) then
2261:          if Drive_Letter_Omitted (Name) then
2262:             Fill_Directory (Drive_Only => True);
2263:
2264:             --  Take only drive letter part with colon
2265:
2266:             End_Path := End_Path + 2;
2267:             Path_Buffer (3 .. End_Path) := Name;
2268:
2269:          else
2270:             Path_Buffer (1 .. End_Path) := Name;
2271:          end if;
2272:
2273:       else
2274:          --  If this is a relative pathname, prepend current directory
2275:          Fill_Directory;
2276:          Path_Buffer (Cur_Dir_Len + 1 .. Cur_Dir_Len + End_Path) := Name;
2277:          End_Path := Cur_Dir_Len + End_Path;
2278:       end if;
2279:
2280:       --  Special handling for Windows:
2281:       --    * Replace all '/' by '\'
2282:       --    * Check the drive letter
2283:       --    * Remove all double-quotes
```

## `adaint.c:340`

```ada
340:        as well. This is only a temporary work-around for 3.11b.  */
341:
342: #ifndef GNAT_LIBRARY_TEMPLATE
343: #define GNAT_LIBRARY_TEMPLATE "lib*.a"
344: #endif
345:
346: const char *__gnat_library_template = GNAT_LIBRARY_TEMPLATE;
347:
348: #if defined (__vxworks)
349: #define GNAT_MAX_PATH_LEN PATH_MAX
350:
351: #else
352:
353: #include <sys/param.h>
354:
355: #ifdef MAXPATHLEN
356: #define GNAT_MAX_PATH_LEN MAXPATHLEN
357: #else
358: #define GNAT_MAX_PATH_LEN 256
359: #endif
360:
361: #endif
362:
363: /* Used for runtime check that Ada constant File_Attributes_Size is no
364:    less than the actual size of struct file_attributes (see Osint
365:    initialization). */
366: int __gnat_size_of_file_attributes = sizeof (struct file_attributes);
367:
368: void __gnat_stat_to_attr (int fd, char* name, struct file_attributes* attr);
369:
370: /* The __gnat_max_path_len variable is used to export the maximum
371:    length of a path name to Ada code. max_path_len is also provided
372:    for compatibility with older GNAT versions, please do not use
373:    it. */
374:
375: int __gnat_max_path_len = GNAT_MAX_PATH_LEN;
376: int max_path_len = GNAT_MAX_PATH_LEN;
```

## `Make-generated.in:49`

```ada
49: 	$(ECHO) "pragma Style_Checks (Off);" >tmp-sdefault.adb
50: 	$(ECHO) "with Osint; use Osint;" >>tmp-sdefault.adb
51: 	$(ECHO) "package body Sdefault is" >>tmp-sdefault.adb
52: 	$(ECHO) "   S0 : constant String := \"$(prefix)/\";" >>tmp-sdefault.adb
53: 	$(ECHO) "   S1 : constant String := \"$(ADA_INCLUDE_DIR)/\";" >>tmp-sdefault.adb
54: 	$(ECHO) "   S2 : constant String := \"$(ADA_RTL_OBJ_DIR)/\";" >>tmp-sdefault.adb
55: 	$(ECHO) "   S3 : constant String := \"$(target_noncanonical)/\";" >>tmp-sdefault.adb
56: 	$(ECHO) "   S4 : constant String := \"$(libsubdir)/\";" >>tmp-sdefault.adb
57: 	$(ECHO) "   function Include_Dir_Default_Name return String_Ptr is" >>tmp-sdefault.adb
58: 	$(ECHO) "   begin" >>tmp-sdefault.adb
59: 	$(ECHO) "      return Relocate_Path (S0, S1);" >>tmp-sdefault.adb
60: 	$(ECHO) "   end Include_Dir_Default_Name;" >>tmp-sdefault.adb
61: 	$(ECHO) "   function Object_Dir_Default_Name return String_Ptr is" >>tmp-sdefault.adb
62: 	$(ECHO) "   begin" >>tmp-sdefault.adb
63: 	$(ECHO) "      return Relocate_Path (S0, S2);" >>tmp-sdefault.adb
64: 	$(ECHO) "   end Object_Dir_Default_Name;" >>tmp-sdefault.adb
65: 	$(ECHO) "   function Target_Name return String_Ptr is" >>tmp-sdefault.adb
66: 	$(ECHO) "   begin" >>tmp-sdefault.adb
67: 	$(ECHO) "      return new String'(S3);" >>tmp-sdefault.adb
68: 	$(ECHO) "   end Target_Name;" >>tmp-sdefault.adb
69: 	$(ECHO) "   function Search_Dir_Prefix return String_Ptr is" >>tmp-sdefault.adb
70: 	$(ECHO) "   begin" >>tmp-sdefault.adb
71: 	$(ECHO) "      return Relocate_Path (S0, S4);" >>tmp-sdefault.adb
72: 	$(ECHO) "   end Search_Dir_Prefix;" >>tmp-sdefault.adb
73: 	$(ECHO) "end Sdefault;" >> tmp-sdefault.adb
```

## `gcc/prefix.cc:94`

```cpp
94:   char *temp = 0;
95:
96: #if defined(_WIN32) && defined(ENABLE_WIN32_REGISTRY)
97:   prefix = lookup_key (key);
98: #endif
99:
100:   if (prefix == 0)
101:     prefix = getenv (temp = concat (key, "_ROOT", NULL));
102:
103:   if (prefix == 0)
104:     prefix = std_prefix;
105:
106:   free (temp);
107:
108:   return prefix;
109: }
110:
111: /* Return a copy of a string that has been placed in the heap.  */
112:
113: static char *
114: save_string (const char *s, int len)
115: {
116:   char *result = XNEWVEC (char, len + 1);
117:
118:   memcpy (result, s, len);
119:   result[len] = 0;
120:   return result;
121: }
122:
123: #if defined(_WIN32) && defined(ENABLE_WIN32_REGISTRY)
```

## `gcc/prefix.cc:185`

```cpp
185: {
186:   char code;
187:   char *key, *old_name;
188:   const char *prefix;
189:   int keylen;
190:
191:   for (;;)
192:     {
193:       code = name[0];
194:       if (code != '@' && code != '$')
195: 	break;
196:
197:       for (keylen = 0;
198: 	   (name[keylen + 1] != 0 && !IS_DIR_SEPARATOR (name[keylen + 1]));
199: 	   keylen++)
200: 	;
201:
202:       key = (char *) alloca (keylen + 1);
203:       memcpy (key, &name[1], keylen);
204:       key[keylen] = 0;
205:
206:       if (code == '@')
207: 	{
208: 	  prefix = get_key_value (key);
209: 	  if (prefix == 0)
210: 	    prefix = std_prefix;
211: 	}
212:       else
213: 	prefix = getenv (key);
214:
215:       if (prefix == 0)
216: 	prefix = PREFIX;
217:
218:       /* We used to strip trailing DIR_SEPARATORs here, but that can
219: 	 sometimes yield a result with no separator when one was coded
220: 	 and intended by the user, causing two path components to run
221: 	 together.  */
222:
223:       old_name = name;
224:       name = concat (prefix, &name[keylen + 1], NULL);
225:       free (old_name);
226:     }
227:
228:   return name;
229: }
230:
231: /* In a NUL-terminated STRING, replace character C1 with C2 in-place.  */
```

## `gcc/prefix.cc:248`

```cpp
248: update_path (const char *path, const char *key)
249: {
250:   char *result, *p;
251:   const int len = strlen (std_prefix);
252:
253:   if (! filename_ncmp (path, std_prefix, len)
254:       && (IS_DIR_SEPARATOR (path[len])
255:           || path[len] == '\0')
256:       && key != 0)
257:     {
258:       bool free_key = false;
259:
260:       if (key[0] != '$')
261: 	{
262: 	  key = concat ("@", key, NULL);
263: 	  free_key = true;
264: 	}
265:
266:       result = concat (key, &path[len], NULL);
267:       if (free_key)
268: 	free (const_cast<char *> (key));
269:       result = translate_name (result);
270:     }
271:   else
272:     result = xstrdup (path);
273:
274:   p = result;
```

## `gcc/prefix.cc:350`

```cpp
350: {
351:   std_prefix = save_string (prefix, len);
352: }
353:
```
