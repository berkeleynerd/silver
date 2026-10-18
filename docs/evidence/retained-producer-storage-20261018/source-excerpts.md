# Pinned producer storage sources

LF line numbering.

## uintp.ads:275–299

```text
275:    --  Used to determine whether UI_Image/UI_Write output is in hexadecimal
276:    --  or decimal format. Auto, the default setting, lets the routine make a
277:    --  decision based on the value.
278:
279:    UI_Image_Max    : constant := 1024;
280:    UI_Image_Buffer : String (1 .. UI_Image_Max);
281:    UI_Image_Length : Natural;
282:    --  Buffer used for UI_Image as described below
283:
284:    procedure UI_Image (Input : Uint; Format : UI_Format := Auto);
285:    --  Places a representation of Uint, consisting of a possible minus sign,
286:    --  followed by the value in UI_Image_Buffer. The form of the value is an
287:    --  integer literal in either decimal (no base) or hexadecimal (base 16)
288:    --  format. If Hex is True on entry, then hex mode is forced, otherwise
289:    --  UI_Image makes a guess at which output format is more convenient. The
290:    --  value must fit in UI_Image_Buffer. The actual length of the result is
291:    --  returned in UI_Image_Length. If necessary to meet this requirement, the
292:    --  result is an approximation of the proper value, using an exponential
293:    --  format. The image of No_Uint is output as a single question mark.
294:
295:    function UI_Image (Input : Uint; Format : UI_Format := Auto) return String;
296:    --  Functional form, in which the result is returned as a string. This call
297:    --  also leaves the result in UI_Image_Buffer/Length as described above.
298:
299:    procedure UI_Write (Input : Uint; Format : UI_Format := Auto);
```

## uintp.ads:464–475

```text
464:    Base_Bits : constant := 15;
465:    --  Number of bits in base value
466:
467:    Base : constant Int := 2**Base_Bits;
468:
469:    --  Values in the range -(Base-1) .. Max_Direct are encoded directly as
470:    --  Uint values by adding a bias value. The value of Max_Direct is chosen
471:    --  so that a directly represented number always fits in two digits when
472:    --  represented in base format.
473:
474:    Min_Direct : constant Int := -(Base - 1);
475:    Max_Direct : constant Int := (Base - 1) * (Base - 1);
```

## uintp.adb:257–455

```text
257:    -- Image_Out --
258:    ---------------
259:
260:    procedure Image_Out
261:      (Input     : Uint;
262:       To_Buffer : Boolean;
263:       Format    : UI_Format)
264:    is
265:       Marks  : constant Uintp.Save_Mark := Uintp.Mark;
266:       Base   : Valid_Uint;
267:       Ainput : Valid_Uint;
268:
269:       Digs_Output : Natural := 0;
270:       --  Counts digits output. In hex mode, but not in decimal mode, we
271:       --  put an underline after every four hex digits that are output.
272:
273:       Exponent : Natural := 0;
274:       --  If the number is too long to fit in the buffer, we switch to an
275:       --  approximate output format with an exponent. This variable records
276:       --  the exponent value.
277:
278:       function Better_In_Hex return Boolean;
279:       --  Determines if it is better to generate digits in base 16 (result
280:       --  is true) or base 10 (result is false). The choice is purely a
281:       --  matter of convenience and aesthetics, so it does not matter which
282:       --  value is returned from a correctness point of view.
283:
284:       procedure Image_Char (C : Character);
285:       --  Output one character
286:
287:       procedure Image_String (S : String);
288:       --  Output characters
289:
290:       procedure Image_Exponent (N : Natural);
291:       --  Output non-zero exponent. Note that we only use the exponent form in
292:       --  the buffer case, so we know that To_Buffer is true.
293:
294:       procedure Image_Uint (U : Valid_Uint);
295:       --  Internal procedure to output characters of non-negative Uint
296:
297:       -------------------
298:       -- Better_In_Hex --
299:       -------------------
300:
301:       function Better_In_Hex return Boolean is
302:          T16 : constant Valid_Uint := Uint_2**Int'(16);
303:          A   : Valid_Uint := UI_Abs (Input);
304:
305:       begin
306:          --  Small values up to 2**16 can always be in decimal
307:
308:          if A < T16 then
309:             return False;
310:          end if;
311:
312:          --  Otherwise, see if we are a power of 2 or one less than a power
313:          --  of 2. For the moment these are the only cases printed in hex.
314:
315:          if A mod Uint_2 = Uint_1 then
316:             A := A + Uint_1;
317:          end if;
318:
319:          loop
320:             if A mod T16 /= Uint_0 then
321:                return False;
322:
323:             else
324:                A := A / T16;
325:             end if;
326:
327:             exit when A < T16;
328:          end loop;
329:
330:          while A > Uint_2 loop
331:             if A mod Uint_2 /= Uint_0 then
332:                return False;
333:
334:             else
335:                A := A / Uint_2;
336:             end if;
337:          end loop;
338:
339:          return True;
340:       end Better_In_Hex;
341:
342:       ----------------
343:       -- Image_Char --
344:       ----------------
345:
346:       procedure Image_Char (C : Character) is
347:       begin
348:          if To_Buffer then
349:             if UI_Image_Length + 6 > UI_Image_Max then
350:                Exponent := Exponent + 1;
351:             else
352:                UI_Image_Length := UI_Image_Length + 1;
353:                UI_Image_Buffer (UI_Image_Length) := C;
354:             end if;
355:          else
356:             Write_Char (C);
357:          end if;
358:       end Image_Char;
359:
360:       --------------------
361:       -- Image_Exponent --
362:       --------------------
363:
364:       procedure Image_Exponent (N : Natural) is
365:       begin
366:          if N >= 10 then
367:             Image_Exponent (N / 10);
368:          end if;
369:
370:          UI_Image_Length := UI_Image_Length + 1;
371:          UI_Image_Buffer (UI_Image_Length) :=
372:            Character'Val (Character'Pos ('0') + N mod 10);
373:       end Image_Exponent;
374:
375:       ------------------
376:       -- Image_String --
377:       ------------------
378:
379:       procedure Image_String (S : String) is
380:       begin
381:          for X of S loop
382:             Image_Char (X);
383:          end loop;
384:       end Image_String;
385:
386:       ----------------
387:       -- Image_Uint --
388:       ----------------
389:
390:       procedure Image_Uint (U : Valid_Uint) is
391:          H : constant array (Int range 0 .. 15) of Character :=
392:                "0123456789ABCDEF";
393:
394:          Q, R : Valid_Uint;
395:       begin
396:          UI_Div_Rem (U, Base, Q, R);
397:
398:          if Q > Uint_0 then
399:             Image_Uint (Q);
400:          end if;
401:
402:          if Digs_Output = 4 and then Base = Uint_16 then
403:             Image_Char ('_');
404:             Digs_Output := 0;
405:          end if;
406:
407:          Image_Char (H (UI_To_Int (R)));
408:
409:          Digs_Output := Digs_Output + 1;
410:       end Image_Uint;
411:
412:    --  Start of processing for Image_Out
413:
414:    begin
415:       if No (Input) then
416:          Image_String ("No_Uint");
417:          return;
418:       end if;
419:
420:       UI_Image_Length := 0;
421:
422:       if Input < Uint_0 then
423:          Image_Char ('-');
424:          Ainput := -Input;
425:       else
426:          Ainput := Input;
427:       end if;
428:
429:       if Format = Hex
430:         or else (Format = Auto and then Better_In_Hex)
431:       then
432:          Base := Uint_16;
433:          Image_Char ('1');
434:          Image_Char ('6');
435:          Image_Char ('#');
436:          Image_Uint (Ainput);
437:          Image_Char ('#');
438:
439:       else
440:          Base := Uint_10;
441:          Image_Uint (Ainput);
442:       end if;
443:
444:       if Exponent /= 0 then
445:          UI_Image_Length := UI_Image_Length + 1;
446:          UI_Image_Buffer (UI_Image_Length) := 'E';
447:          Image_Exponent (Exponent);
448:       end if;
449:
450:       Uintp.Release (Marks);
451:    end Image_Out;
452:
453:    -------------------
454:    -- Init_Operand --
455:    -------------------
```

## uintp.adb:534–537

```text
534:    function Mark return Save_Mark is
535:    begin
536:       return (Save_Uint => Uints.Last, Save_Udigit => Udigits.Last);
537:    end Mark;
```

## uintp.adb:606–621

```text
606:    function N_Digits (Input : Valid_Uint) return Pos is
607:    begin
608:       if Direct (Input) then
609:          if Direct_Val (Input) >= Base then
610:             return 2;
611:          else
612:             return 1;
613:          end if;
614:
615:       else
616:          return Uints.Table (Input).Length;
617:       end if;
618:    end N_Digits;
619:
620:    --------------
621:    -- Num_Bits --
```

## uintp.adb:680–688

```text
680:    -- Release --
681:    -------------
682:
683:    procedure Release (M : Save_Mark) is
684:    begin
685:       Uints.Set_Last   (Valid_Uint'Max (M.Save_Uint, Uints_Min));
686:       Udigits.Set_Last (Int'Max  (M.Save_Udigit, Udigits_Min));
687:    end Release;
688:
```

## uintp.adb:1030–1155

```text
1030:    procedure UI_Div_Rem
1031:      (Left, Right       : Valid_Uint;
1032:       Quotient          : out Uint;
1033:       Remainder         : out Uint;
1034:       Discard_Quotient  : Boolean := False;
1035:       Discard_Remainder : Boolean := False)
1036:    is
1037:    begin
1038:       pragma Assert (Right /= Uint_0);
1039:
1040:       Quotient  := No_Uint;
1041:       Remainder := No_Uint;
1042:
1043:       --  Cases where both operands are represented directly
1044:
1045:       if Direct (Left) and then Direct (Right) then
1046:          declare
1047:             DV_Left  : constant Int := Direct_Val (Left);
1048:             DV_Right : constant Int := Direct_Val (Right);
1049:
1050:          begin
1051:             if not Discard_Quotient then
1052:                Quotient := UI_From_Int (DV_Left / DV_Right);
1053:             end if;
1054:
1055:             if not Discard_Remainder then
1056:                Remainder := UI_From_Int (DV_Left rem DV_Right);
1057:             end if;
1058:
1059:             return;
1060:          end;
1061:       end if;
1062:
1063:       declare
1064:          L_Length    : constant Int := N_Digits (Left);
1065:          R_Length    : constant Int := N_Digits (Right);
1066:          Q_Length    : constant Int := L_Length - R_Length + 1;
1067:          L_Vec       : UI_Vector (1 .. L_Length);
1068:          R_Vec       : UI_Vector (1 .. R_Length);
1069:          D           : Int;
1070:          Remainder_I : Int;
1071:          Tmp_Divisor : Int;
1072:          Carry       : Int;
1073:          Tmp_Int     : Int;
1074:          Tmp_Dig     : Int;
1075:
1076:          procedure UI_Div_Vector
1077:            (L_Vec     : UI_Vector;
1078:             R_Int     : Int;
1079:             Quotient  : out UI_Vector;
1080:             Remainder : out Int);
1081:          pragma Inline (UI_Div_Vector);
1082:          --  Specialised variant for case where the divisor is a single digit
1083:
1084:          procedure UI_Div_Vector
1085:            (L_Vec     : UI_Vector;
1086:             R_Int     : Int;
1087:             Quotient  : out UI_Vector;
1088:             Remainder : out Int)
1089:          is
1090:             Tmp_Int : Int;
1091:
1092:          begin
1093:             Remainder := 0;
1094:             for J in L_Vec'Range loop
1095:                Tmp_Int := Remainder * Base + abs L_Vec (J);
1096:                Quotient (Quotient'First + J - L_Vec'First) := Tmp_Int / R_Int;
1097:                Remainder := Tmp_Int rem R_Int;
1098:             end loop;
1099:
1100:             if L_Vec (L_Vec'First) < Int_0 then
1101:                Remainder := -Remainder;
1102:             end if;
1103:          end UI_Div_Vector;
1104:
1105:       --  Start of processing for UI_Div_Rem
1106:
1107:       begin
1108:          --  Result is zero if left operand is shorter than right
1109:
1110:          if L_Length < R_Length then
1111:             if not Discard_Quotient then
1112:                Quotient := Uint_0;
1113:             end if;
1114:
1115:             if not Discard_Remainder then
1116:                Remainder := Left;
1117:             end if;
1118:
1119:             return;
1120:          end if;
1121:
1122:          Init_Operand (Left, L_Vec);
1123:          Init_Operand (Right, R_Vec);
1124:
1125:          --  Case of right operand is single digit. Here we can simply divide
1126:          --  each digit of the left operand by the divisor, from most to least
1127:          --  significant, carrying the remainder to the next digit (just like
1128:          --  ordinary long division by hand).
1129:
1130:          if R_Length = Int_1 then
1131:             Tmp_Divisor := abs R_Vec (1);
1132:
1133:             declare
1134:                Quotient_V : UI_Vector (1 .. L_Length);
1135:
1136:             begin
1137:                UI_Div_Vector (L_Vec, Tmp_Divisor, Quotient_V, Remainder_I);
1138:
1139:                if not Discard_Quotient then
1140:                   Quotient :=
1141:                     Vector_To_Uint
1142:                       (Quotient_V, (L_Vec (1) < Int_0 xor R_Vec (1) < Int_0));
1143:                end if;
1144:
1145:                if not Discard_Remainder then
1146:                   Remainder := UI_From_Int (Remainder_I);
1147:                end if;
1148:
1149:                return;
1150:             end;
1151:          end if;
1152:
1153:          --  The possible simple cases have been exhausted. Now turn to the
1154:          --  algorithm D from the section of Knuth mentioned at the top of
1155:          --  this package.
```

## uintp.adb:1466–1507

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
1507:
```

## uintp.adb:1703–1716

```text
1703:    procedure UI_Image (Input : Uint; Format : UI_Format := Auto) is
1704:    begin
1705:       Image_Out (Input, True, Format);
1706:    end UI_Image;
1707:
1708:    function UI_Image
1709:      (Input  : Uint;
1710:       Format : UI_Format := Auto) return String
1711:    is
1712:    begin
1713:       Image_Out (Input, True, Format);
1714:       return UI_Image_Buffer (1 .. UI_Image_Length);
1715:    end UI_Image;
1716:
```

## uintp.adb:1770–1820

```text
1770:    function UI_Lt (Left : Valid_Uint; Right : Valid_Uint) return Boolean is
1771:    begin
1772:       pragma Assert (Present (Left));
1773:       pragma Assert (Present (Right));
1774:       --  Assertions are here in case we're called from C++ code, which does
1775:       --  not check the predicates.
1776:
1777:       --  Quick processing for identical arguments
1778:
1779:       if Int (Left) = Int (Right) then
1780:          return False;
1781:
1782:       --  Quick processing for both arguments directly represented
1783:
1784:       elsif Direct (Left) and then Direct (Right) then
1785:          return Int (Left) < Int (Right);
1786:
1787:       --  At least one argument is more than one digit long
1788:
1789:       else
1790:          declare
1791:             L_Length : constant Int := N_Digits (Left);
1792:             R_Length : constant Int := N_Digits (Right);
1793:
1794:             L_Vec : UI_Vector (1 .. L_Length);
1795:             R_Vec : UI_Vector (1 .. R_Length);
1796:
1797:          begin
1798:             Init_Operand (Left, L_Vec);
1799:             Init_Operand (Right, R_Vec);
1800:
1801:             if L_Vec (1) < Int_0 then
1802:
1803:                --  First argument negative, second argument non-negative
1804:
1805:                if R_Vec (1) >= Int_0 then
1806:                   return True;
1807:
1808:                --  Both arguments negative
1809:
1810:                else
1811:                   if L_Length /= R_Length then
1812:                      return L_Length > R_Length;
1813:
1814:                   elsif L_Vec (1) /= R_Vec (1) then
1815:                      return L_Vec (1) < R_Vec (1);
1816:
1817:                   else
1818:                      for J in 2 .. L_Vec'Last loop
1819:                         if L_Vec (J) /= R_Vec (J) then
1820:                            return L_Vec (J) > R_Vec (J);
```

## uintp.adb:2153–2185

```text
2153:    function UI_Negate (Right : Valid_Uint) return Valid_Uint is
2154:    begin
2155:       --  Case where input is directly represented. Note that since the range
2156:       --  of Direct values is non-symmetrical, the result may not be directly
2157:       --  represented, this is taken care of in UI_From_Int.
2158:
2159:       if Direct (Right) then
2160:          return UI_From_Int (-Direct_Val (Right));
2161:
2162:       --  Full processing for multi-digit case. Note that we cannot just copy
2163:       --  the value to the end of the table negating the first digit, since the
2164:       --  range of Direct values is non-symmetrical, so we can have a negative
2165:       --  value that is not Direct whose negation can be represented directly.
2166:
2167:       else
2168:          declare
2169:             R_Length : constant Int := N_Digits (Right);
2170:             R_Vec    : UI_Vector (1 .. R_Length);
2171:             Neg      : Boolean;
2172:
2173:          begin
2174:             Init_Operand (Right, R_Vec);
2175:             Neg := R_Vec (1) > Int_0;
2176:             R_Vec (1) := abs R_Vec (1);
2177:             return Vector_To_Uint (R_Vec, Neg);
2178:          end;
2179:       end if;
2180:    end UI_Negate;
2181:
2182:    -------------
2183:    -- UI_Rem --
2184:    -------------
2185:
```

## uintp.adb:2265–2272

```text
2265:    function UI_To_Int (Input : Valid_Uint) return Int is
2266:    begin
2267:       if Direct (Input) then
2268:          return Direct_Val (Input);
2269:
2270:       --  Case of input is more than one digit
2271:
2272:       else
```

## uintp.adb:2359–2424

```text
2359:    ---------------------
2360:
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
```

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

## libgnat/a-cohama.adb:628–644

```text
628:       HT : Hash_Table_Type renames Container.HT;
629:
630:    --  Start of processing for Insert
631:
632:    begin
633:       if HT_Ops.Capacity (HT) = 0 then
634:          HT_Ops.Reserve_Capacity (HT, 1);
635:       end if;
636:
637:       Local_Insert (HT, Key, Position.Node, Inserted);
638:
639:       if Inserted
640:         and then HT.Length > HT_Ops.Capacity (HT)
641:       then
642:          HT_Ops.Reserve_Capacity (HT, HT.Length);
643:       end if;
644:
```

## libgnat/a-chtgke.adb:148–199

```text
148:    procedure Generic_Conditional_Insert
149:      (HT       : in out Hash_Table_Type;
150:       Key      : Key_Type;
151:       Node     : out Node_Access;
152:       Inserted : out Boolean)
153:    is
154:       Indx : Hash_Type;
155:
156:    begin
157:       --  Per AI05-0022, the container implementation is required to detect
158:       --  element tampering by a generic actual subprogram.
159:
160:       TC_Check (HT.TC);
161:
162:       Indx := Checked_Index (HT, Key);
163:       Node := HT.Buckets (Indx);
164:
165:       if Node = null then
166:          if Checks and then HT.Length = Count_Type'Last then
167:             raise Constraint_Error;
168:          end if;
169:
170:          Node := New_Node (Next => null);
171:          Inserted := True;
172:
173:          HT.Buckets (Indx) := Node;
174:          HT.Length := HT.Length + 1;
175:
176:          return;
177:       end if;
178:
179:       loop
180:          if Checked_Equivalent_Keys (HT, Key, Node) then
181:             Inserted := False;
182:             return;
183:          end if;
184:
185:          Node := Next (Node);
186:
187:          exit when Node = null;
188:       end loop;
189:
190:       if Checks and then HT.Length = Count_Type'Last then
191:          raise Constraint_Error;
192:       end if;
193:
194:       Node := New_Node (Next => HT.Buckets (Indx));
195:       Inserted := True;
196:
197:       HT.Buckets (Indx) := Node;
198:       HT.Length := HT.Length + 1;
199:    end Generic_Conditional_Insert;
```

## libgnat/a-chtgop.adb:49–132

```text
49:    procedure Adjust (HT : in out Hash_Table_Type) is
50:       Src_Buckets : constant Buckets_Access := HT.Buckets;
51:       N           : constant Count_Type := HT.Length;
52:       Src_Node    : Node_Access;
53:       Dst_Prev    : Node_Access;
54:
55:    begin
56:       --  If the counts are nonzero, execution is technically erroneous, but
57:       --  it seems friendly to allow things like concurrent "=" on shared
58:       --  constants.
59:
60:       Zero_Counts (HT.TC);
61:
62:       HT.Buckets := null;
63:       HT.Length := 0;
64:
65:       if N = 0 then
66:          return;
67:       end if;
68:
69:       --  Technically it isn't necessary to allocate the exact same length
70:       --  buckets array, because our only requirement is that following
71:       --  assignment the source and target containers compare equal (that is,
72:       --  operator "=" returns True). We can satisfy this requirement with any
73:       --  hash table length, but we decide here to match the length of the
74:       --  source table. This has the benefit that when iterating, elements of
75:       --  the target are delivered in the exact same order as for the source.
76:
77:       HT.Buckets := New_Buckets (Length => Src_Buckets'Length);
78:
79:       for Src_Index in Src_Buckets'Range loop
80:          Src_Node := Src_Buckets (Src_Index);
81:
82:          if Src_Node /= null then
83:             declare
84:                Dst_Node : constant Node_Access := Copy_Node (Src_Node);
85:
86:                --  See note above
87:
88:                pragma Assert (Checked_Index (HT, Dst_Node) = Src_Index);
89:
90:             begin
91:                HT.Buckets (Src_Index) := Dst_Node;
92:                HT.Length := HT.Length + 1;
93:
94:                Dst_Prev := Dst_Node;
95:             end;
96:
97:             Src_Node := Next (Src_Node);
98:             while Src_Node /= null loop
99:                declare
100:                   Dst_Node : constant Node_Access := Copy_Node (Src_Node);
101:
102:                   --  See note above
103:
104:                   pragma Assert (Checked_Index (HT, Dst_Node) = Src_Index);
105:
106:                begin
107:                   Set_Next (Node => Dst_Prev, Next => Dst_Node);
108:                   HT.Length := HT.Length + 1;
109:
110:                   Dst_Prev := Dst_Node;
111:                end;
112:
113:                Src_Node := Next (Src_Node);
114:             end loop;
115:          end if;
116:       end loop;
117:
118:       pragma Assert (HT.Length = N);
119:    end Adjust;
120:
121:    --------------
122:    -- Capacity --
123:    --------------
124:
125:    function Capacity (HT : Hash_Table_Type) return Count_Type is
126:    begin
127:       if HT.Buckets = null then
128:          return 0;
129:       end if;
130:
131:       return HT.Buckets'Length;
132:    end Capacity;
```

## libgnat/a-chtgop.adb:613–623

```text
613:    function New_Buckets (Length : Hash_Type) return Buckets_Access is
614:       subtype Rng is Hash_Type range 0 .. Length - 1;
615:
616:    begin
617:       --  Allocate in Buckets_Allocation'Storage_Pool, then convert to
618:       --  Buckets_Access.
619:
620:       return Buckets_Access (Buckets_Allocation'(new Buckets_Type (Rng)));
621:    end New_Buckets;
622:
623:    ----------
```

## libgnat/a-chtgop.adb:677–836

```text
677:    procedure Reserve_Capacity
678:      (HT : in out Hash_Table_Type;
679:       N  : Count_Type)
680:    is
681:       NN : Hash_Type;
682:
683:    begin
684:       if HT.Buckets = null then
685:          if N > 0 then
686:             NN := Prime_Numbers.To_Prime (N);
687:             HT.Buckets := New_Buckets (Length => NN);
688:          end if;
689:
690:          return;
691:       end if;
692:
693:       if HT.Length = 0 then
694:
695:          --  This is the easy case. There are no nodes, so no rehashing is
696:          --  necessary. All we need to do is allocate a new buckets array
697:          --  having a length implied by the specified capacity. (We say
698:          --  "implied by" because bucket arrays are always allocated with a
699:          --  length that corresponds to a prime number.)
700:
701:          if N = 0 then
702:             Free_Buckets (HT.Buckets);
703:             return;
704:          end if;
705:
706:          if N = HT.Buckets'Length then
707:             return;
708:          end if;
709:
710:          NN := Prime_Numbers.To_Prime (N);
711:
712:          if NN = HT.Buckets'Length then
713:             return;
714:          end if;
715:
716:          declare
717:             X : Buckets_Access := HT.Buckets;
718:             pragma Warnings (Off, X);
719:          begin
720:             HT.Buckets := New_Buckets (Length => NN);
721:             Free_Buckets (X);
722:          end;
723:
724:          return;
725:       end if;
726:
727:       if N = HT.Buckets'Length then
728:          return;
729:       end if;
730:
731:       if N < HT.Buckets'Length then
732:
733:          --  This is a request to contract the buckets array. The amount of
734:          --  contraction is bounded in order to preserve the invariant that the
735:          --  buckets array length is never smaller than the number of elements
736:          --  (the load factor is 1).
737:
738:          if HT.Length >= HT.Buckets'Length then
739:             return;
740:          end if;
741:
742:          NN := Prime_Numbers.To_Prime (HT.Length);
743:
744:          if NN >= HT.Buckets'Length then
745:             return;
746:          end if;
747:
748:       else
749:          NN := Prime_Numbers.To_Prime (Count_Type'Max (N, HT.Length));
750:
751:          if NN = HT.Buckets'Length then -- can't expand any more
752:             return;
753:          end if;
754:       end if;
755:
756:       TC_Check (HT.TC);
757:
758:       Rehash : declare
759:          Dst_Buckets : Buckets_Access := New_Buckets (Length => NN);
760:          Src_Buckets : Buckets_Access := HT.Buckets;
761:          pragma Warnings (Off, Src_Buckets);
762:
763:          L : Count_Type renames HT.Length;
764:          LL : constant Count_Type := L;
765:
766:          Src_Index : Hash_Type := Src_Buckets'First;
767:
768:       begin
769:          while L > 0 loop
770:             declare
771:                Src_Bucket : Node_Access renames Src_Buckets (Src_Index);
772:
773:             begin
774:                while Src_Bucket /= null loop
775:                   declare
776:                      Src_Node : constant Node_Access := Src_Bucket;
777:
778:                      Dst_Index : constant Hash_Type :=
779:                        Checked_Index (HT, Dst_Buckets.all, Src_Node);
780:
781:                      Dst_Bucket : Node_Access renames Dst_Buckets (Dst_Index);
782:
783:                   begin
784:                      Src_Bucket := Next (Src_Node);
785:
786:                      Set_Next (Src_Node, Dst_Bucket);
787:
788:                      Dst_Bucket := Src_Node;
789:                   end;
790:
791:                   pragma Assert (L > 0);
792:                   L := L - 1;
793:                end loop;
794:
795:             exception
796:                when others =>
797:
798:                   --  If there's an error computing a hash value during a
799:                   --  rehash, then AI-302 says the nodes "become lost." The
800:                   --  issue is whether to actually deallocate these lost nodes,
801:                   --  since they might be designated by extant cursors. Here
802:                   --  we decide to deallocate the nodes, since it's better to
803:                   --  solve real problems (storage consumption) rather than
804:                   --  imaginary ones (the user might, or might not, dereference
805:                   --  a cursor designating a node that has been deallocated),
806:                   --  and because we have a way to vet a dangling cursor
807:                   --  reference anyway, and hence can actually detect the
808:                   --  problem.
809:
810:                   for Dst_Index in Dst_Buckets'Range loop
811:                      declare
812:                         B : Node_Access renames Dst_Buckets (Dst_Index);
813:                         X : Node_Access;
814:                      begin
815:                         while B /= null loop
816:                            X := B;
817:                            B := Next (X);
818:                            Free (X);
819:                         end loop;
820:                      end;
821:                   end loop;
822:
823:                   Free_Buckets (Dst_Buckets);
824:                   raise Program_Error with
825:                     "hash function raised exception during rehash";
826:             end;
827:
828:             Src_Index := Src_Index + 1;
829:          end loop;
830:
831:          HT.Buckets := Dst_Buckets;
832:          HT.Length := LL;
833:
834:          Free_Buckets (Src_Buckets);
835:       end Rehash;
836:    end Reserve_Capacity;
```

## libgnat/a-coprnu.ads:30–51

```text
30: --  This package declares the prime numbers array used to implement hashed
31: --  containers. Bucket arrays are always allocated with a prime-number
32: --  length (computed using To_Prime below), as this produces better scatter
33: --  when hash values are folded.
34:
35: package Ada.Containers.Prime_Numbers is
36:    pragma Pure;
37:
38:    type Primes_Type is array (Positive range <>) of Hash_Type;
39:
40:    Primes : constant Primes_Type :=
41:      [53,         97,         193,       389,       769,
42:       1543,       3079,       6151,      12289,     24593,
43:       49157,      98317,      196613,    393241,    786433,
44:       1572869,    3145739,    6291469,   12582917,  25165843,
45:       50331653,   100663319,  201326611, 402653189, 805306457,
46:       1610612741, 3221225473, 4294967291];
47:
48:    function To_Prime (Length : Count_Type) return Hash_Type;
49:    --  Returns the smallest value in Primes not less than Length
50:
51: end Ada.Containers.Prime_Numbers;
```

## libgnat/a-coprnu.adb:32–59

```text
32:    --------------
33:    -- To_Prime --
34:    --------------
35:
36:    function To_Prime (Length : Count_Type) return Hash_Type is
37:       I, J, K : Integer'Base;
38:       Index   : Integer'Base;
39:
40:    begin
41:       I := Primes'Last - Primes'First;
42:       Index := Primes'First;
43:       while I > 0 loop
44:          J := I / 2;
45:          K := Index + J;
46:
47:          if Primes (K) < Hash_Type (Length) then
48:             Index := K + 1;
49:             I := I - J - 1;
50:          else
51:             I := J;
52:          end if;
53:       end loop;
54:
55:       return Primes (Index);
56:    end To_Prime;
57:
58: end Ada.Containers.Prime_Numbers;
59:
```

## libgnat/a-textio.ads:80–84

```text
80:    type Count is range 0 .. Natural'Last;
81:    --  The value of Count'Last must be large enough so that the assumption that
82:    --  the Line, Column and Page counts can never exceed this value is valid.
83:
84:    subtype Positive_Count is Count range 1 .. Count'Last;
```

## libgnat/a-textio.ads:675–690

```text
675:    package FCB renames System.File_Control_Block;
676:
677:    type Text_AFCB;
678:    type File_Type is access all Text_AFCB;
679:
680:    type Text_AFCB is new FCB.AFCB with record
681:       Page        : Count := 1;
682:       Line        : Count := 1;
683:       Col         : Count := 1;
684:       Line_Length : Count := 0;
685:       Page_Length : Count := 0;
686:
687:       Self : aliased File_Type;
688:       --  Set to point to the containing Text_AFCB block. This is used to
689:       --  implement the Current_{Error,Input,Output} functions which return
690:       --  a File_Access, the file access value returned is a pointer to
```

## libgnat/a-textio.adb:170–207

```text
170:       --  If the file being closed is one of the current files, then close
171:       --  the corresponding current file. It is not clear that this action
172:       --  is required (RM A.10.3(23)) but it seems reasonable, and besides
173:       --  ACVC test CE3208A expects this behavior.
174:
175:       if File = Current_In then
176:          Current_In := null;
177:       elsif File = Current_Out then
178:          Current_Out := null;
179:       elsif File = Current_Err then
180:          Current_Err := null;
181:       end if;
182:
183:       Terminate_Line (File.all'Access);
184:    end AFCB_Close;
185:
186:    ---------------
187:    -- AFCB_Free --
188:    ---------------
189:
190:    procedure AFCB_Free (File : not null access Text_AFCB) is
191:       FT : File_Type := File.all'Access;
192:
193:       procedure Free is new Ada.Unchecked_Deallocation (Text_AFCB, File_Type);
194:
195:    begin
196:       Free (FT);
197:    end AFCB_Free;
198:
199:    -----------
200:    -- Close --
201:    -----------
202:
203:    procedure Close (File : in out File_Type) is
204:    begin
205:       FIO.Close (AP (File)'Unrestricted_Access);
206:    end Close;
207:
```

## libgnat/a-textio.adb:1109–1143

```text
1109:    procedure New_Line
1110:      (File    : File_Type;
1111:       Spacing : Positive_Count := 1)
1112:    is
1113:    begin
1114:       --  Raise Constraint_Error if out of range value. The reason for this
1115:       --  explicit test is that we don't want junk values around, even if
1116:       --  checks are off in the caller.
1117:
1118:       if not Spacing'Valid then
1119:          raise Constraint_Error;
1120:       end if;
1121:
1122:       FIO.Check_Write_Status (AP (File));
1123:
1124:       for K in 1 .. Spacing loop
1125:          Putc (LM, File);
1126:          File.Line := File.Line + 1;
1127:
1128:          if File.Page_Length /= 0
1129:            and then File.Line > File.Page_Length
1130:          then
1131:             Putc (PM, File);
1132:             File.Line := 1;
1133:             File.Page := File.Page + 1;
1134:          end if;
1135:       end loop;
1136:
1137:       File.Col := 1;
1138:    end New_Line;
1139:
1140:    procedure New_Line (Spacing : Positive_Count := 1) is
1141:    begin
1142:       New_Line (Current_Out, Spacing);
1143:    end New_Line;
```

## libgnat/a-textio.adb:1255–1330

```text
1255:    ---------
1256:    -- Put --
1257:    ---------
1258:
1259:    procedure Put
1260:      (File : File_Type;
1261:       Item : Character)
1262:    is
1263:    begin
1264:       FIO.Check_Write_Status (AP (File));
1265:
1266:       if File.Line_Length /= 0 and then File.Col > File.Line_Length then
1267:          New_Line (File);
1268:       end if;
1269:
1270:       --  If lower half character, or brackets encoding, output directly
1271:
1272:       if Character'Pos (Item) < 16#80#
1273:         or else File.WC_Method = WCEM_Brackets
1274:       then
1275:          if fputc (Character'Pos (Item), File.Stream) = EOF then
1276:             raise Device_Error;
1277:          end if;
1278:
1279:       --  Case of upper half character with non-brackets encoding
1280:
1281:       else
1282:          Put_Encoded (File, Item);
1283:       end if;
1284:
1285:       File.Col := File.Col + 1;
1286:    end Put;
1287:
1288:    procedure Put (Item : Character) is
1289:    begin
1290:       Put (Current_Out, Item);
1291:    end Put;
1292:
1293:    ---------
1294:    -- Put --
1295:    ---------
1296:
1297:    procedure Put
1298:      (File : File_Type;
1299:       Item : String)
1300:    is
1301:    begin
1302:       FIO.Check_Write_Status (AP (File));
1303:
1304:       --  Only have something to do if string is non-null
1305:
1306:       if Item'Length > 0 then
1307:
1308:          --  If we have bounded lines, or if the file encoding is other than
1309:          --  Brackets and the string has at least one upper half character,
1310:          --  then output the string character by character.
1311:
1312:          if File.Line_Length /= 0
1313:            or else (File.WC_Method /= WCEM_Brackets
1314:                       and then Has_Upper_Half_Character (Item))
1315:          then
1316:             for J in Item'Range loop
1317:                Put (File, Item (J));
1318:             end loop;
1319:
1320:          --  Otherwise we can output the entire string at once. Note that if
1321:          --  there are LF or FF characters in the string, we do not bother to
1322:          --  count them as line or page terminators.
1323:
1324:          else
1325:             FIO.Write_Buf (AP (File), Item'Address, Item'Length);
1326:             File.Col := File.Col + Item'Length;
1327:          end if;
1328:       end if;
1329:    end Put;
1330:
```

## libgnat/a-textio.adb:2048–2078

```text
2048:    procedure Terminate_Line (File : File_Type) is
2049:    begin
2050:       FIO.Check_File_Open (AP (File));
2051:
2052:       --  For file other than In_File, test for needing to terminate last line
2053:
2054:       if Mode (File) /= In_File then
2055:
2056:          --  If not at start of line definition need new line
2057:
2058:          if File.Col /= 1 then
2059:             New_Line (File);
2060:
2061:          --  For files other than standard error and standard output, we
2062:          --  make sure that an empty file has a single line feed, so that
2063:          --  it is properly formatted. We avoid this for the standard files
2064:          --  because it is too much of a nuisance to have these odd line
2065:          --  feeds when nothing has been written to the file.
2066:
2067:          --  We also avoid this for files opened in append mode, in
2068:          --  accordance with (RM A.8.2(10))
2069:
2070:          elsif (File /= Standard_Err and then File /= Standard_Out)
2071:            and then (File.Line = 1 and then File.Page = 1)
2072:            and then Mode (File) = Out_File
2073:          then
2074:             New_Line (File);
2075:          end if;
2076:       end if;
2077:    end Terminate_Line;
2078:
```

## spark/src/utils/outputs.adb:47–59

```text
47:
48:    procedure I (O : Output_Id) is
49:    begin
50:       if Output_States (O).New_Line then
51:          Put
52:            (Output_Handles (O), String'(1 .. Output_States (O).Indent => ' '));
53:          Output_States (O).New_Line := False;
54:       end if;
55:    end I;
56:
57:    --------
58:    -- NL --
59:    --------
```

## spark/src/utils/outputs.adb:73–119

```text
73:       pragma Assert (not Is_Open (Output_Handles (Current_File)));
74:       pragma Assert (Output_States (Current_File).Indent = 0);
75:       pragma Assert (Output_States (Current_File).New_Line = False);
76:       Create (Output_Handles (Current_File), Out_File, Filename);
77:    end Open_Current_File;
78:
79:    -------
80:    -- P --
81:    -------
82:
83:    procedure P (O : Output_Id; C : Character) is
84:    begin
85:       Put (Output_Handles (O), C);
86:    end P;
87:
88:    procedure P (O : Output_Id; S : String; As_String : Boolean := False) is
89:    begin
90:       I (O);
91:       if As_String then
92:
93:          --  Prepare buffer for escaping each quote with a backslash and
94:          --  enclosing the resulting string in quotes.
95:
96:          declare
97:             Buffer : String (1 .. S'Length * 2 + 2);
98:             Cursor : Positive := 1;
99:          begin
100:             Buffer (Cursor) := '"';
101:             Cursor := Cursor + 1;
102:
103:             for C of S loop
104:                if C = '"' then
105:                   Buffer (Cursor) := '\';
106:                   Cursor := Cursor + 1;
107:                end if;
108:                Buffer (Cursor) := C;
109:                Cursor := Cursor + 1;
110:             end loop;
111:
112:             Buffer (Cursor) := '"';
113:             --  No need to advance cursor for the last character
114:
115:             Put (Output_Handles (O), Buffer (1 .. Cursor));
116:          end;
117:       else
118:          Put (Output_Handles (O), S);
119:       end if;
```

## spark/src/utils/outputs.ads:31–68

```text
31:    type Output_Id is (Stderr, Stdout, Current_File);
32:    --  Handle on an output. An indentation level is associated to each
33:    --  output; this package offers ways to modify this level and to write
34:    --  into the corresponding stream.
35:
36:    procedure Open_Current_File (Filename : String)
37:    with Post => Indent_Level (Current_File) = 0;
38:    --  Open Filename and set current file's output to the corresponding file
39:    --  descriptor.
40:
41:    procedure Close_Current_File;
42:    --  Close current file
43:
44:    function Indent_Level (O : Output_Id) return Natural
45:    with Ghost;
46:    --  Returns the current indentation level of O
47:
48:    procedure Absolute_Indent (O : Output_Id; Level : Natural)
49:    with Post => Indent_Level (O) = Level;
50:    --  Set the indentation level of O to Level
51:
52:    procedure Relative_Indent (O : Output_Id; Diff : Integer)
53:    with Post => Indent_Level (O) = Indent_Level (O)'Old + Diff;
54:    --  Increase the indentation level of O by Level (or decrease it
55:    --  if Level is lesser than zero).
56:
57:    procedure P (O : Output_Id; C : Character)
58:    with Pre => Indent_Level (O) = 0;
59:    --  Put C to output O, but can only be used when indentation level is 0
60:
61:    procedure P (O : Output_Id; S : String; As_String : Boolean := False);
62:    --  Put S to output O, indenting it if need be. If As_String is true, the
63:    --  argument string is interpreted as a string literal.
64:
65:    procedure PL (O : Output_Id; S : String);
66:    --  Put_Line S to output O, indenting it if need be
67:
68:    procedure NL (O : Output_Id);
```

## spark/src/why/gnat2why-driver.adb:1204–1215

```text
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
```

## spark/src/why/xgen/why-atree-to_json.adb-tmpl:17–43

```text
17:
18:    procedure Boolean_To_Json (O : Output_Id; B : Boolean) is
19:    begin
20:       if B then
21:          P (O, "true");
22:       else
23:          P (O, "false");
24:       end if;
25:    end Boolean_To_Json;
26:
27:    procedure Uint_To_Json (O : Output_Id; I : Uint) is
28:    begin
29:       P (O, '"' & UI_Image (I, Decimal) & '"');
30:    end Uint_To_Json;
31:
32:    procedure Ureal_To_Json (O : Output_Id; I : Ureal) is
33:    begin
34:       P (O, '[');
35:       Uint_To_Json (O, Numerator (I));
36:       P (O, ',');
37:       Uint_To_Json (O, Denominator (I));
38:       P (O, ',');
39:       P (O, Nat'Image (Rbase (I)));
40:       P (O, ',');
41:       Boolean_To_Json (O, UR_Is_Negative (I));
42:       P (O, ']');
43:    end Ureal_To_Json;
```

## spark/src/why/xgen/why-atree-to_json.adb-tmpl:56–90

```text
56:          end loop;
57:       P (O, ']');
58:    end String_Sets_Set_To_Json;
59:
60:    ------------------
61:    --  Gnat types  --
62:    ------------------
63:
64:    procedure Source_Ptr_To_Json (O : Output_Id; X : Source_Ptr);
65:    procedure Symbol_To_Json (O : Output_Id; S : Symbols.Symbol);
66:    procedure Symbol_Set_To_Json (O : Output_Id; S : Symbol_Set);
67:
68:    procedure Source_Ptr_To_Json (O : Output_Id; X : Source_Ptr) is
69:       File : constant String               := SPARK_Util.File_Name (X);
70:       Line : constant Physical_Line_Number := Get_Physical_Line_Number (X);
71:    begin
72:       if X = No_Location then
73:          P (O, "null");
74:          return;
75:       end if;
76:       P (O, '[');
77:       P (O, File, As_String => True);
78:       P (O, ',');
79:       P (O, Physical_Line_Number'Image (Line));
80:       P (O, ']');
81:    end Source_Ptr_To_Json;
82:
83:    procedure Symbol_To_Json (O : Output_Id; S : Symbols.Symbol) is
84:       X : constant GNATCOLL.Utils.Cst_String_Access := Symbols.Get (S);
85:    begin
86:       P (O, X.all, As_String => True);
87:    end Symbol_To_Json;
88:
89:    procedure Symbol_Set_To_Json (O : Output_Id; S : Symbol_Set) is
90:       First : Boolean := True;
```

## spark/src/why/xgen/why-atree-to_json.adb-tmpl:113–157

```text
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
```

## spark/src/why/xgen/xtree_why_ast.adb:169–230

```text
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
```
