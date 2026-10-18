# Pinned producer storage sources

LF line numbering.

## libgnat/a-contai.ads:16–28

```text
16: package Ada.Containers is
17:    pragma Pure;
18:
19:    type Hash_Type is mod 2**32;
20:    --  Represents the range of the result of a hash function
21:
22:    type Count_Type is range 0 .. 2**31 - 1;
23:    --  Represents the (potential or actual) number of elements of a container
24:
25:    Capacity_Error : exception;
26:    --  Raised when the capacity of a container is exceeded
27:
28: end Ada.Containers;
```

## libgnat/a-coinve.ads:409–432

```text
409:    use Implementation;
410:
411:    type Element_Access is access Element_Type;
412:
413:    type Elements_Array is array (Index_Type range <>) of Element_Access;
414:    function "=" (L, R : Elements_Array) return Boolean is abstract;
415:
416:    type Elements_Type (Last : Extended_Index) is limited record
417:       EA : Elements_Array (Index_Type'First .. Last);
418:    end record;
419:
420:    type Elements_Access is access all Elements_Type;
421:
422:    use Finalization;
423:    use Streams;
424:
425:    type Vector is new Controlled with record
426:       Elements : Elements_Access := null;
427:       Last     : Extended_Index := No_Index;
428:       TC       : aliased Tamper_Counts;
429:    end record with Put_Image => Put_Image;
430:
431:    procedure Put_Image
432:      (S : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class; V : Vector);
```

## libgnat/a-coinve.adb:214–248

```text
214:    procedure Append (Container : in out Vector;
215:                      New_Item  :        Element_Type)
216:    is
217:    begin
218:       --  For performance, check for the common special case where the
219:       --  container already has room for at least one more element.
220:       --  In the general case, pass the buck to Insert.
221:
222:       if Container.Elements /= null
223:         and then Container.Last /= Container.Elements.Last
224:       then
225:          TC_Check (Container.TC);
226:
227:          --  Increment Container.Last after assigning the New_Item, so we
228:          --  leave the Container unmodified in case Finalize/Adjust raises
229:          --  an exception.
230:
231:          declare
232:             New_Last : constant Index_Type := Container.Last + 1;
233:
234:             --  The element allocator may need an accessibility check in the
235:             --  case actual type is class-wide or has access discriminants
236:             --  (see RM 4.8(10.1) and AI12-0035).
237:
238:             pragma Unsuppress (Accessibility_Check);
239:          begin
240:             Container.Elements.EA (New_Last) := new Element_Type'(New_Item);
241:             Container.Last := New_Last;
242:          end;
243:       else
244:          Insert (Container, Last_Index (Container) + 1, New_Item, 1);
245:       end if;
246:    end Append;
247:
248:    ----------------------
```

## libgnat/a-coinve.adb:297–315

```text
297:
298:    procedure Clear (Container : in out Vector) is
299:    begin
300:       TC_Check (Container.TC);
301:
302:       while Container.Last >= Index_Type'First loop
303:          declare
304:             X : Element_Access := Container.Elements.EA (Container.Last);
305:          begin
306:             Container.Elements.EA (Container.Last) := null;
307:             Container.Last := Container.Last - 1;
308:             Free (X);
309:          end;
310:       end loop;
311:    end Clear;
312:
313:    ------------------------
314:    -- Constant_Reference --
315:    ------------------------
```

## libgnat/a-coinve.adb:1200–1283

```text
1200:          --  is treated as a proper error.)
1201:
1202:          if Before > Container.Last + 1 then
1203:             raise Constraint_Error with
1204:               "Before index is out of range (too large)";
1205:          end if;
1206:       end if;
1207:
1208:       --  We treat inserting 0 items into the container as a no-op, even when
1209:       --  the container is busy, so we simply return.
1210:
1211:       if Count = 0 then
1212:          return;
1213:       end if;
1214:
1215:       --  There are two constraints we need to satisfy. The first constraint is
1216:       --  that a container cannot have more than Count_Type'Last elements, so
1217:       --  we must check the sum of the current length and the insertion count.
1218:       --  Note: we cannot simply add these values, because of the possibility
1219:       --  of overflow.
1220:
1221:       if Checks and then Old_Length > Count_Type'Last - Count then
1222:          raise Constraint_Error with "Count is out of range";
1223:       end if;
1224:
1225:       --  It is now safe compute the length of the new vector, without fear of
1226:       --  overflow.
1227:
1228:       New_Length := Old_Length + Count;
1229:
1230:       --  The second constraint is that the new Last index value cannot exceed
1231:       --  Index_Type'Last. In each branch below, we calculate the maximum
1232:       --  length (computed from the range of values in Index_Type), and then
1233:       --  compare the new length to the maximum length. If the new length is
1234:       --  acceptable, then we compute the new last index from that.
1235:
1236:       if Index_Type'Base'Last >= Count_Type_Last then
1237:
1238:          --  We have to handle the case when there might be more values in the
1239:          --  range of Index_Type than in the range of Count_Type.
1240:
1241:          if Index_Type'First <= 0 then
1242:
1243:             --  We know that No_Index (the same as Index_Type'First - 1) is
1244:             --  less than 0, so it is safe to compute the following sum without
1245:             --  fear of overflow.
1246:
1247:             Index := No_Index + Index_Type'Base (Count_Type'Last);
1248:
1249:             if Index <= Index_Type'Last then
1250:
1251:                --  We have determined that range of Index_Type has at least as
1252:                --  many values as in Count_Type, so Count_Type'Last is the
1253:                --  maximum number of items that are allowed.
1254:
1255:                Max_Length := Count_Type'Last;
1256:
1257:             else
1258:                --  The range of Index_Type has fewer values than in Count_Type,
1259:                --  so the maximum number of items is computed from the range of
1260:                --  the Index_Type.
1261:
1262:                Max_Length := Count_Type'Base (Index_Type'Last - No_Index);
1263:             end if;
1264:
1265:          else
1266:             --  No_Index is equal or greater than 0, so we can safely compute
1267:             --  the difference without fear of overflow (which we would have to
1268:             --  worry about if No_Index were less than 0, but that case is
1269:             --  handled above).
1270:
1271:             if Index_Type'Last - No_Index >= Count_Type_Last then
1272:                --  We have determined that range of Index_Type has at least as
1273:                --  many values as in Count_Type, so Count_Type'Last is the
1274:                --  maximum number of items that are allowed.
1275:
1276:                Max_Length := Count_Type'Last;
1277:
1278:             else
1279:                --  The range of Index_Type has fewer values than in Count_Type,
1280:                --  so the maximum number of items is computed from the range of
1281:                --  the Index_Type.
1282:
1283:                Max_Length := Count_Type'Base (Index_Type'Last - No_Index);
```

## libgnat/a-coinve.adb:1330–1396

```text
1330:       end if;
1331:
1332:       --  New_Last is the last index value of the items in the container after
1333:       --  insertion.  Use the wider of Index_Type'Base and Count_Type'Base to
1334:       --  compute its value from the New_Length.
1335:
1336:       if Index_Type'Base'Last >= Count_Type_Last then
1337:          New_Last := No_Index + Index_Type'Base (New_Length);
1338:       else
1339:          New_Last := Index_Type'Base (Count_Type'Base (No_Index) + New_Length);
1340:       end if;
1341:
1342:       if Container.Elements = null then
1343:          pragma Assert (Container.Last = No_Index);
1344:
1345:          --  This is the simplest case, with which we must always begin: we're
1346:          --  inserting items into an empty vector that hasn't allocated an
1347:          --  internal array yet. Note that we don't need to check the busy bit
1348:          --  here, because an empty container cannot be busy.
1349:
1350:          --  In an indefinite vector, elements are allocated individually, and
1351:          --  stored as access values on the internal array (the length of which
1352:          --  represents the vector "capacity"), which is separately allocated.
1353:
1354:          Container.Elements := new Elements_Type (New_Last);
1355:
1356:          --  The element backbone has been successfully allocated, so now we
1357:          --  allocate the elements.
1358:
1359:          for Idx in Container.Elements.EA'Range loop
1360:
1361:             --  In order to preserve container invariants, we always attempt
1362:             --  the element allocation first, before setting the Last index
1363:             --  value, in case the allocation fails (either because there is no
1364:             --  storage available, or because element initialization fails).
1365:
1366:             declare
1367:                --  The element allocator may need an accessibility check in the
1368:                --  case actual type is class-wide or has access discriminants
1369:                --  (see RM 4.8(10.1) and AI12-0035).
1370:
1371:                pragma Unsuppress (Accessibility_Check);
1372:
1373:             begin
1374:                Container.Elements.EA (Idx) := new Element_Type'(New_Item);
1375:             end;
1376:
1377:             --  The allocation of the element succeeded, so it is now safe to
1378:             --  update the Last index, restoring container invariants.
1379:
1380:             Container.Last := Idx;
1381:          end loop;
1382:
1383:          return;
1384:       end if;
1385:
1386:       if New_Length <= Container.Elements.EA'Length then
1387:
1388:          --  In this case, we're inserting elements into a vector that has
1389:          --  already allocated an internal array, and the existing array has
1390:          --  enough unused storage for the new items.
1391:
1392:          declare
1393:             E : Elements_Array renames Container.Elements.EA;
1394:             K : Index_Type'Base;
1395:
1396:          begin
```

## libgnat/a-coinve.adb:1498–1591

```text
1498:       New_Capacity := Count_Type'Max (1, Container.Elements.EA'Length);
1499:       while New_Capacity < New_Length loop
1500:          if New_Capacity > Count_Type'Last / 2 then
1501:             New_Capacity := Count_Type'Last;
1502:             exit;
1503:          end if;
1504:
1505:          New_Capacity := 2 * New_Capacity;
1506:       end loop;
1507:
1508:       if New_Capacity > Max_Length then
1509:
1510:          --  We have reached the limit of capacity, so no further expansion
1511:          --  will occur. (This is not a problem, as there is never a need to
1512:          --  have more capacity than the maximum container length.)
1513:
1514:          New_Capacity := Max_Length;
1515:       end if;
1516:
1517:       --  We have computed the length of the new internal array (and this is
1518:       --  what "vector capacity" means), so use that to compute its last index.
1519:
1520:       if Index_Type'Base'Last >= Count_Type_Last then
1521:          Dst_Last := No_Index + Index_Type'Base (New_Capacity);
1522:       else
1523:          Dst_Last :=
1524:            Index_Type'Base (Count_Type'Base (No_Index) + New_Capacity);
1525:       end if;
1526:
1527:       --  Now we allocate the new, longer internal array. If the allocation
1528:       --  fails, we have not changed any container state, so no side-effect
1529:       --  will occur as a result of propagating the exception.
1530:
1531:       Dst := new Elements_Type (Dst_Last);
1532:
1533:       --  We have our new internal array. All that needs to be done now is to
1534:       --  copy the existing items (if any) from the old array (the "source"
1535:       --  array) to the new array (the "destination" array), and then
1536:       --  deallocate the old array.
1537:
1538:       declare
1539:          Src : Elements_Access := Container.Elements;
1540:
1541:       begin
1542:          Dst.EA (Index_Type'First .. Before - 1) :=
1543:            Src.EA (Index_Type'First .. Before - 1);
1544:
1545:          if Before > Container.Last then
1546:
1547:             --  The new items are being appended to the vector, so no
1548:             --  sliding of existing elements is required.
1549:
1550:             --  We have copied the elements from to the old source array to the
1551:             --  new destination array, so we can now deallocate the old array.
1552:
1553:             Container.Elements := Dst;
1554:             Free (Src);
1555:
1556:             --  Now we append the new items.
1557:
1558:             for Idx in Before .. New_Last loop
1559:
1560:                --  In order to preserve container invariants, we always attempt
1561:                --  the element allocation first, before setting the Last index
1562:                --  value, in case the allocation fails (either because there
1563:                --  is no storage available, or because element initialization
1564:                --  fails).
1565:
1566:                declare
1567:                   --  The element allocator may need an accessibility check in
1568:                   --  the case the actual type is class-wide or has access
1569:                   --  discriminants (see RM 4.8(10.1) and AI12-0035).
1570:
1571:                   pragma Unsuppress (Accessibility_Check);
1572:
1573:                begin
1574:                   Dst.EA (Idx) := new Element_Type'(New_Item);
1575:                end;
1576:
1577:                --  The allocation of the element succeeded, so it is now safe
1578:                --  to update the Last index, restoring container invariants.
1579:
1580:                Container.Last := Idx;
1581:             end loop;
1582:
1583:          else
1584:             --  The new items are being inserted before some existing elements,
1585:             --  so we must slide the existing elements up to their new home.
1586:
1587:             if Index_Type'Base'Last >= Count_Type_Last then
1588:                Index := Before + Index_Type'Base (Count);
1589:             else
1590:                Index := Index_Type'Base (Count_Type'Base (Before) + Count);
1591:             end if;
```

## libgnat/a-coinve.adb:2467–2494

```text
2467:    function Length (Container : Vector) return Count_Type is
2468:       L : constant Index_Type'Base := Container.Last;
2469:       F : constant Index_Type := Index_Type'First;
2470:
2471:    begin
2472:       --  The base range of the index type (Index_Type'Base) might not include
2473:       --  all values for length (Count_Type). Contrariwise, the index type
2474:       --  might include values outside the range of length.  Hence we use
2475:       --  whatever type is wider for intermediate values when calculating
2476:       --  length. Note that no matter what the index type is, the maximum
2477:       --  length to which a vector is allowed to grow is always the minimum
2478:       --  of Count_Type'Last and (IT'Last - IT'First + 1).
2479:
2480:       --  For example, an Index_Type with range -127 .. 127 is only guaranteed
2481:       --  to have a base range of -128 .. 127, but the corresponding vector
2482:       --  would have lengths in the range 0 .. 255. In this case we would need
2483:       --  to use Count_Type'Base for intermediate values.
2484:
2485:       --  Another case would be the index range -2**63 + 1 .. -2**63 + 10. The
2486:       --  vector would have a maximum length of 10, but the index values lie
2487:       --  outside the range of Count_Type (which is only 32 bits). In this
2488:       --  case we would need to use Index_Type'Base for intermediate values.
2489:
2490:       if Count_Type'Base'Last >= Index_Type'Pos (Index_Type'Base'Last) then
2491:          return Count_Type'Base (L) - Count_Type'Base (F) + 1;
2492:       else
2493:          return Count_Type (L - F + 1);
2494:       end if;
```

## libgnat/a-coinve.adb:2890–2935

```text
2890:
2891:    procedure Reserve_Capacity
2892:      (Container : in out Vector;
2893:       Capacity  : Count_Type)
2894:    is
2895:       N : constant Count_Type := Length (Container);
2896:
2897:       Index : Count_Type'Base;
2898:       Last  : Index_Type'Base;
2899:
2900:    begin
2901:       --  Reserve_Capacity can be used to either expand the storage available
2902:       --  for elements (this would be its typical use, in anticipation of
2903:       --  future insertion), or to trim back storage. In the latter case,
2904:       --  storage can only be trimmed back to the limit of the container
2905:       --  length. Note that Reserve_Capacity neither deletes (active) elements
2906:       --  nor inserts elements; it only affects container capacity, never
2907:       --  container length.
2908:
2909:       if Capacity = 0 then
2910:
2911:          --  This is a request to trim back storage, to the minimum amount
2912:          --  possible given the current state of the container.
2913:
2914:          if N = 0 then
2915:
2916:             --  The container is empty, so in this unique case we can
2917:             --  deallocate the entire internal array. Note that an empty
2918:             --  container can never be busy, so there's no need to check the
2919:             --  tampering bits.
2920:
2921:             declare
2922:                X : Elements_Access := Container.Elements;
2923:
2924:             begin
2925:                --  First we remove the internal array from the container, to
2926:                --  handle the case when the deallocation raises an exception
2927:                --  (although that's unlikely, since this is simply an array of
2928:                --  access values, all of which are null).
2929:
2930:                Container.Elements := null;
2931:
2932:                --  Container invariants have been restored, so it is now safe
2933:                --  to attempt to deallocate the internal array.
2934:
2935:                Free (X);
```

## libgnat/a-cdlili.ads:269–289

```text
269:    type Node_Type;
270:    type Node_Access is access Node_Type;
271:
272:    type Node_Type is
273:       limited record
274:          Element : aliased Element_Type;
275:          Next    : Node_Access;
276:          Prev    : Node_Access;
277:       end record;
278:
279:    use Ada.Finalization;
280:    use Ada.Streams;
281:
282:    type List is
283:      new Controlled with record
284:         First  : Node_Access := null;
285:         Last   : Node_Access := null;
286:         Length : Count_Type := 0;
287:         TC     : aliased Tamper_Counts;
288:      end record with Put_Image => Put_Image;
289:
```

## libgnat/a-cdlili.adb:114–171

```text
114:
115:    procedure Adjust (Container : in out List) is
116:       Src : Node_Access := Container.First;
117:
118:    begin
119:       --  If the counts are nonzero, execution is technically erroneous, but
120:       --  it seems friendly to allow things like concurrent "=" on shared
121:       --  constants.
122:
123:       Zero_Counts (Container.TC);
124:
125:       if Src = null then
126:          pragma Assert (Container.Last = null);
127:          pragma Assert (Container.Length = 0);
128:          return;
129:       end if;
130:
131:       pragma Assert (Container.First.Prev = null);
132:       pragma Assert (Container.Last.Next = null);
133:       pragma Assert (Container.Length > 0);
134:
135:       Container.First := new Node_Type'(Src.Element, null, null);
136:       Container.Last := Container.First;
137:       Container.Length := 1;
138:
139:       Src := Src.Next;
140:       while Src /= null loop
141:          Container.Last.Next := new Node_Type'(Element => Src.Element,
142:                                                Prev    => Container.Last,
143:                                                Next    => null);
144:          Container.Last := Container.Last.Next;
145:          Container.Length := Container.Length + 1;
146:
147:          Src := Src.Next;
148:       end loop;
149:    end Adjust;
150:
151:    ------------
152:    -- Append --
153:    ------------
154:
155:    procedure Append
156:      (Container : in out List;
157:       New_Item  : Element_Type;
158:       Count     : Count_Type)
159:    is
160:    begin
161:       Insert (Container, No_Element, New_Item, Count);
162:    end Append;
163:
164:    procedure Append
165:      (Container : in out List;
166:       New_Item  : Element_Type)
167:    is
168:    begin
169:       Insert (Container, No_Element, New_Item, 1);
170:    end Append;
171:
```

## libgnat/a-cdlili.adb:763–813

```text
763:      (Container : in out List;
764:       Before    : Cursor;
765:       New_Item  : Element_Type;
766:       Position  : out Cursor;
767:       Count     : Count_Type := 1)
768:    is
769:       First_Node : Node_Access;
770:       New_Node   : Node_Access;
771:
772:    begin
773:       TC_Check (Container.TC);
774:
775:       if Before.Container /= null then
776:          if Checks and then Before.Container /= Container'Unrestricted_Access
777:          then
778:             raise Program_Error with
779:               "Before cursor designates wrong list";
780:          end if;
781:
782:          pragma Assert (Vet (Before), "bad cursor in Insert");
783:       end if;
784:
785:       if Count = 0 then
786:          Position := Before;
787:          return;
788:       end if;
789:
790:       if Checks and then Container.Length > Count_Type'Last - Count then
791:          raise Constraint_Error with "new length exceeds maximum";
792:       end if;
793:
794:       New_Node   := new Node_Type'(New_Item, null, null);
795:       First_Node := New_Node;
796:       Insert_Internal (Container, Before.Node, New_Node);
797:
798:       for J in 2 .. Count loop
799:          New_Node := new Node_Type'(New_Item, null, null);
800:          Insert_Internal (Container, Before.Node, New_Node);
801:       end loop;
802:
803:       Position := Cursor'(Container'Unchecked_Access, First_Node);
804:    end Insert;
805:
806:    procedure Insert
807:      (Container : in out List;
808:       Before    : Cursor;
809:       New_Item  : Element_Type;
810:       Count     : Count_Type := 1)
811:    is
812:       Position : Cursor;
813:    begin
```

## libgnat/a-cdlili.adb:865–906

```text
865:      (Container : in out List;
866:       Before    : Node_Access;
867:       New_Node  : Node_Access)
868:    is
869:    begin
870:       if Container.Length = 0 then
871:          pragma Assert (Before = null);
872:          pragma Assert (Container.First = null);
873:          pragma Assert (Container.Last = null);
874:
875:          Container.First := New_Node;
876:          Container.Last := New_Node;
877:
878:       elsif Before = null then
879:          pragma Assert (Container.Last.Next = null);
880:
881:          Container.Last.Next := New_Node;
882:          New_Node.Prev := Container.Last;
883:
884:          Container.Last := New_Node;
885:
886:       elsif Before = Container.First then
887:          pragma Assert (Container.First.Prev = null);
888:
889:          Container.First.Prev := New_Node;
890:          New_Node.Next := Container.First;
891:
892:          Container.First := New_Node;
893:
894:       else
895:          pragma Assert (Container.First.Prev = null);
896:          pragma Assert (Container.Last.Next = null);
897:
898:          New_Node.Next := Before;
899:          New_Node.Prev := Before.Prev;
900:
901:          Before.Prev.Next := New_Node;
902:          Before.Prev := New_Node;
903:       end if;
904:
905:       Container.Length := Container.Length + 1;
906:    end Insert_Internal;
```
