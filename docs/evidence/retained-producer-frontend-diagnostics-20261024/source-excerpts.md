# Fixed proof-mode frontend witnesses


## gnat1drv.adb:517–529

```ada
517:
518:          --  Turn off style checks and compiler warnings in GNATprove except:
519:          --    - elaboration warnings, which turn into errors on SPARK code
520:          --    - suspicious contracts, which are useful for SPARK code
521:
522:          Reset_Style_Check_Options;
523:          Restore_Warnings
524:            ((Warnings_Package.Elab_Warnings => True,
525:              Warnings_Package.Warn_On_Suspicious_Contract => True,
526:              Warnings_Package.Warning_Doc_Switch =>
527:                Warnsw.Warning_Doc_Switch,
528:              others => False));
529:
```

## gnat1drv.adb:1197–1217

```ada
1197:       --  Exit if compilation errors detected
1198:
1199:       Errout.Finalize (Last_Call => False);
1200:
1201:       if Compilation_Errors then
1202:          Ecode := E_Errors;
1203:          Treepr.Tree_Dump;
1204:          Errout.Finalize (Last_Call => True);
1205:          Errout.Output_Messages (Ecode);
1206:          Namet.Finalize;
1207:
1208:          --  Generate ALI file if specially requested
1209:
1210:          if Opt.Force_ALI_File then
1211:             Write_ALI (Object => False);
1212:          end if;
1213:
1214:          Exit_Program (Ecode);
1215:       end if;
1216:
1217:       --  Case of no code required to be generated, exit indicating no error
```

## gnat1drv.adb:1530–1538

```ada
1530:       Stringt.Lock;
1531:
1532:       --  Here we call the back end to generate the output code
1533:
1534:       Generating_Code := True;
1535:       Back_End.Call_Back_End (Back_End_Mode);
1536:
1537:       --  Once the backend is complete, we unlock the names table. This call
1538:       --  allows a few extra entries, needed for example for the file name
```

## errout.adb:550–697

```ada
550:       Error_Msg (Msg, To_Span (Flag_Location), N);
551:    end Error_Msg;
552:
553:    procedure Error_Msg
554:      (Msg        : String;
555:       Flag_Span  : Source_Span;
556:       N          : Node_Id;
557:       Error_Code : Diagnostic_Id := No_Diagnostic_Id;
558:       Label      : String := "";
559:       Spans      : Labeled_Span_Array := No_Locations;
560:       Fixes      : Fix_Array := No_Fixes)
561:    is
562:       Flag_Location : constant Source_Ptr := Flag_Span.Ptr;
563:
564:       Sindex : Source_File_Index;
565:       --  Source index for flag location
566:
567:       Orig_Loc : Source_Ptr;
568:       --  Original location of Flag_Location (i.e. location in original
569:       --  template in instantiation case, otherwise unchanged).
570:
571:    begin
572:       --  Return if all errors are to be ignored
573:
574:       if Get_Ignore_Errors then
575:          return;
576:       end if;
577:
578:       --  If we already have messages, and we are trying to place a message at
579:       --  No_Location, then just ignore the attempt since we assume that what
580:       --  is happening is some cascaded junk. Note that this is safe in the
581:       --  sense that proceeding will surely bomb. We will also bomb if the flag
582:       --  location is No_Location and we don't have any messages so far, but
583:       --  that is a real bug and a legitimate bomb, so we go ahead.
584:
585:       if Flag_Location = No_Location
586:         and then Total_Errors_Detected > 0
587:       then
588:          return;
589:       end if;
590:
591:       --  Start of processing for new message
592:
593:       Sindex := Get_Source_File_Index (Flag_Location);
594:       Prescan_Message (Msg);
595:       Orig_Loc := Original_Location (Flag_Location);
596:
597:       --  If the current location is in an instantiation, the issue arises of
598:       --  whether to post the message on the template or the instantiation.
599:
600:       --  The way we decide is to see if we have posted the same message on
601:       --  the template when we compiled the template (the template is always
602:       --  compiled before any instantiations). For this purpose, we use a
603:       --  separate table of messages. The reason we do this is twofold:
604:
605:       --     First, the messages can get changed by various processing
606:       --     including the insertion of tokens etc, making it hard to
607:       --     do the comparison.
608:
609:       --     Second, we will suppress a warning on a template if it is not in
610:       --     the current extended source unit. That's reasonable and means we
611:       --     don't want the warning on the instantiation here either, but it
612:       --     does mean that the main error table would not in any case include
613:       --     the message.
614:
615:       if Flag_Location = Orig_Loc then
616:          Non_Instance_Msgs.Append ((new String'(Msg), Flag_Location));
617:          Warn_On_Instance := False;
618:
619:       --  Here we have an instance message
620:
621:       else
622:          --  Delete if debug flag off, and this message duplicates a message
623:          --  already posted on the corresponding template
624:
625:          if not Debug_Flag_GG then
626:             for J in Non_Instance_Msgs.First .. Non_Instance_Msgs.Last loop
627:                if Msg = Non_Instance_Msgs.Table (J).Msg.all
628:                  and then Non_Instance_Msgs.Table (J).Loc = Orig_Loc
629:                then
630:                   return;
631:                end if;
632:             end loop;
633:          end if;
634:
635:          --  No duplicate, so error/warning will be posted on instance
636:
637:          Warn_On_Instance := Error_Msg_Kind = Warning;
638:       end if;
639:
640:       --  Ignore warning message that is suppressed for this location. Note
641:       --  that style checks are not considered warning messages for this
642:       --  purpose.
643:
644:       if Error_Msg_Kind = Warning
645:         and then Warnings_Suppressed (Orig_Loc) /= No_String
646:       then
647:          return;
648:
649:       --  For style messages, check too many messages so far
650:
651:       elsif Error_Msg_Kind = Style
652:         and then Maximum_Messages /= 0
653:         and then Warnings_Detected >= Maximum_Messages
654:       then
655:          return;
656:
657:       --  Suppress warnings inside a loop that is known to be null or is
658:       --  probably null (i.e. when loop executes only if invalid values
659:       --  present). In either case warnings in the loop are likely to be junk.
660:
661:       elsif Error_Msg_Kind = Warning and then Present (N) then
662:
663:          declare
664:             P : Node_Id;
665:
666:          begin
667:             P := Parent (N);
668:             while Present (P) loop
669:                if Nkind (P) = N_Loop_Statement
670:                  and then Suppress_Loop_Warnings (P)
671:                then
672:                   return;
673:                end if;
674:
675:                P := Parent (P);
676:             end loop;
677:          end;
678:       end if;
679:
680:       --  The idea at this stage is that we have two kinds of messages
681:
682:       --  First, we have those messages that are to be placed as requested at
683:       --  Flag_Location. This includes messages that have nothing to do with
684:       --  generics, and also messages placed on generic templates that reflect
685:       --  an error in the template itself. For such messages we simply call
686:       --  Error_Msg_Internal to place the message in the requested location.
687:
688:       if Instantiation (Sindex) = No_Location then
689:          Error_Msg_Internal
690:            (Msg        => Msg,
691:             Span       => Flag_Span,
692:             Opan       => Flag_Span,
693:             Msg_Cont   => False,
694:             Error_Code => Error_Code,
695:             Label      => Label,
696:             Spans      => Spans,
697:             Fixes      => Fixes);
```

## errout.adb:1280–1379

```ada
1280:             return;
1281:          end if;
1282:
1283:          --  If the flag location is in the main extended source unit then for
1284:          --  sure we want the message since it definitely belongs.
1285:
1286:          if In_Extended_Main_Source_Unit (Sptr) then
1287:             null;
1288:
1289:          --  Keep info message if message text contains !!
1290:
1291:          elsif Has_Double_Exclam then
1292:             null;
1293:
1294:          --  Here is where we delete a message from a with'ed unit
1295:
1296:          else
1297:             Cur_Msg := No_Error_Msg;
1298:
1299:             if not Continuation then
1300:                Last_Killed := True;
1301:             end if;
1302:
1303:             return;
1304:          end if;
1305:
1306:       --  Special check for warning message to see if it should be output
1307:
1308:       elsif Error_Msg_Kind = Warning then
1309:
1310:          --  Immediate return if warning message and warnings are suppressed
1311:
1312:          if Warnings_Suppressed (Optr) /= No_String
1313:            or else Warnings_Suppressed (Sptr) /= No_String
1314:          then
1315:             Cur_Msg := No_Error_Msg;
1316:             return;
1317:          end if;
1318:
1319:          --  If the flag location is in the main extended source unit then for
1320:          --  sure we want the warning since it definitely belongs.
1321:
1322:          if In_Extended_Main_Source_Unit (Sptr) then
1323:             null;
1324:
1325:          --  If the main unit has not been read yet. The warning must be on
1326:          --  a configuration file: gnat.adc or user-defined. This means we
1327:          --  are not parsing the main unit yet, so skip following checks.
1328:
1329:          elsif No (Cunit (Main_Unit)) then
1330:             null;
1331:
1332:          --  If the flag location is not in the extended main source unit, then
1333:          --  we want to eliminate the warning, unless it is in the extended
1334:          --  main code unit and we want warnings on the instance.
1335:
1336:          elsif In_Extended_Main_Code_Unit (Sptr) and then Warn_On_Instance then
1337:             null;
1338:
1339:          --  Keep warning if debug flag G set
1340:
1341:          elsif Debug_Flag_GG then
1342:             null;
1343:
1344:          --  Keep warning if message text contains !!
1345:
1346:          elsif Has_Double_Exclam then
1347:             null;
1348:
1349:          --  Here is where we delete a warning from a with'ed unit
1350:
1351:          else
1352:             Cur_Msg := No_Error_Msg;
1353:
1354:             if not Continuation then
1355:                Last_Killed := True;
1356:             end if;
1357:
1358:             return;
1359:          end if;
1360:       end if;
1361:
1362:       --  If message is to be ignored in special ignore message mode, this is
1363:       --  where we do this special processing, bypassing message output.
1364:
1365:       if Ignore_Errors_Enable > 0 then
1366:          if Error_Msg_Kind = Erroutc.Error then
1367:             Handle_Serious_Error;
1368:          end if;
1369:
1370:          return;
1371:       end if;
1372:
1373:       --  If error message line length set, and this is a continuation message
1374:       --  then all we do is to append the text to the text of the last message
1375:       --  with a comma space separator (eliminating a possible (style) or
1376:       --  info prefix).
1377:
1378:       if Error_Msg_Line_Length /= 0 and then Continuation then
1379:          Cur_Msg := Errors.Last;
```

## errout.adb:1510–1545

```ada
1510:             (if Has_Insertion_Line then Error_Msg_Sloc else No_Location),
1511:           Sfile               => Get_Source_File_Index (Sptr),
1512:           Line                => Get_Physical_Line_Number (Sptr),
1513:           Col                 => Get_Column_Number (Sptr),
1514:           Compile_Time_Pragma => Is_Compile_Time_Msg,
1515:           Warn_Err            => None, -- reset below
1516:           Warn_Chr            => Warning_Msg_Char,
1517:           Uncond              => Is_Unconditional_Msg,
1518:           Msg_Cont            => Continuation,
1519:           Deleted             => False,
1520:           Kind                => Error_Msg_Kind,
1521:           Locations           => Primary_Loc,
1522:           Id                  => Error_Code,
1523:           Switch              =>
1524:             Get_Switch_Id (Error_Msg_Kind, Warning_Msg_Char),
1525:           Fixes               => First_Fix));
1526:       Cur_Msg := Errors.Last;
1527:
1528:       --  Test if a warning is to be treated as error:
1529:       --  * It is marked by a pragma Warning_As_Error
1530:       --  * Warning_Mode is Treat_Run_Time_Warnings_As_Errors and we are
1531:       --    dealing with a runtime warning.
1532:       --  * Warning_Mode is Warnings_As_Errors and it is not a compile time
1533:       --    message.
1534:
1535:       if Error_Msg_Kind in Warning | Style then
1536:          if Warning_Treated_As_Error (Errors.Table (Cur_Msg)) then
1537:             Errors.Table (Cur_Msg).Warn_Err := From_Pragma;
1538:          elsif Warning_Mode = Treat_Run_Time_Warnings_As_Errors
1539:            and then Is_Runtime_Raise_Msg
1540:          then
1541:             Errors.Table (Cur_Msg).Warn_Err := From_Run_Time_As_Err;
1542:          elsif Warning_Mode = Treat_As_Error and then not Is_Compile_Time_Msg
1543:          then
1544:             Errors.Table (Cur_Msg).Warn_Err := From_Warn_As_Err;
1545:          end if;
```

## errout.adb:3008–3025

```ada
3008:                    (Sarif_File_Name, Fmode => System.OS_Lib.Text);
3009:             begin
3010:                Set_Output (Output_FD);
3011:                Add_Unique_Diagnostics_And_Switches (Printer);
3012:                Print_SARIF_Report (Printer);
3013:                Free (Printer);
3014:                Set_Standard_Output;
3015:                System.OS_Lib.Close (Output_FD);
3016:             end;
3017:          elsif Debug_Flag_FF then
3018:             Erroutc.Pretty_Emitter.Print_Error_Messages;
3019:          else
3020:             Emit_Error_Msgs;
3021:          end if;
3022:       end if;
3023:
3024:       --  Full source listing case
3025:
```

## errout.adb:3216–3221

```ada
3216:       if Warning_Mode = Treat_As_Error then
3217:          pragma Assert (Warnings_Detected >= Warnings_Treated_As_Errors);
3218:          Total_Errors_Detected :=
3219:            Total_Errors_Detected + Warnings_Treated_As_Errors;
3220:          Warnings_Detected := Warnings_Detected - Warnings_Treated_As_Errors;
3221:       end if;
```

## erroutc.adb:228–232

```ada
228:    function Compilation_Errors return Boolean is
229:    begin
230:       return Total_Errors_Detected /= 0
231:         or else Warnings_Treated_As_Errors /= 0;
232:    end Compilation_Errors;
```

## erroutc.adb:990–1005

```ada
990:             (if E_Msg.Kind = Style then Style_Prefix else ""));
991:
992:       --  Print the message kind prefix
993:       --  * Info/Style/Warning messages
994:       --  * Check messages that are not continuations in the pretty printer
995:       --  * Error messages when error tags are allowed
996:
997:       elsif E_Msg.Kind in Info | Style | Warning
998:         or else
999:         (E_Msg.Kind in High_Check | Medium_Check | Low_Check
1000:          and then not (E_Msg.Msg_Cont and then Debug_Flag_FF))
1001:         or else
1002:         (E_Msg.Kind in Error | Non_Serious_Error
1003:          and then Opt.Unique_Error_Tag)
1004:       then
1005:          Append (Buf, SGR_Code & Kind_Prefix & SGR_Reset);
```

## erroutc.adb:1988–2005

```ada
1988:          return;
1989:       end if;
1990:
1991:       --  If all warnings are suppressed by command line switch, this can
1992:       --  be ignored, unless we are in GNATprove_Mode which requires pragma
1993:       --  Warnings to be stored for the formal verification backend.
1994:
1995:       if Warning_Mode = Suppress
1996:         and then not GNATprove_Mode
1997:       then
1998:          return;
1999:       end if;
2000:
2001:       --  If last entry in table already covers us, this is a redundant pragma
2002:       --  Warnings (Off) and can be ignored.
2003:
2004:       if Warnings.Last >= Warnings.First
2005:         and then Warnings.Table (Warnings.Last).Start <= Loc
```

## erroutc.adb:2033–2048

```ada
2033:       end if;
2034:
2035:       --  If all warnings are suppressed by command line switch, this can
2036:       --  be ignored, unless we are in GNATprove_Mode which requires pragma
2037:       --  Warnings to be stored for the formal verification backend.
2038:
2039:       if Warning_Mode = Suppress
2040:         and then not GNATprove_Mode
2041:       then
2042:          return;
2043:       end if;
2044:
2045:       --  If the last entry in the warnings table covers this pragma, then
2046:       --  we adjust the end point appropriately.
2047:
2048:       if Warnings.Last >= Warnings.First
```

## erroutc.adb:2140–2156

```ada
2140:
2141:       for J in Warnings.First .. Warnings.Last loop
2142:          if Sloc_In_Range (Loc, Warnings.Table (J).Start,
2143:                                 Warnings.Table (J).Stop)
2144:          then
2145:             return Warnings.Table (J).Reason;
2146:          end if;
2147:       end loop;
2148:
2149:       if Warning_Mode = Suppress then
2150:          return Null_String_Id;
2151:       else
2152:          return No_String;
2153:       end if;
2154:    end Warnings_Suppressed;
2155:
2156:    -------------------------
```

## opt.ads:530–540

```ada
530:
531:    Enable_CUDA_Device_Expansion : Boolean := False;
532:    --  GNATBIND
533:    --  Set to True to enable CUDA device (as opposed to host) expansion.
534:
535:    Error_Msg_Line_Length : Nat := 0;
536:    --  GNAT
537:    --  Records the error message line length limit. If this is set to zero,
538:    --  then we get the old style behavior, in which each call to the error
539:    --  message routines generates one line of output as a separate message.
540:    --  If it is set to a non-zero value, then continuation lines are folded
```

## switch-c.adb:995–1007

```ada
995:             when 'I' =>
996:                Ptr := Ptr + 1;
997:                Ignore_Rep_Clauses := True;
998:
999:             --  -gnatj (messages in limited length lines)
1000:
1001:             when 'j' =>
1002:                Ptr := Ptr + 1;
1003:                Scan_Nat (Switch_Chars, Max, Ptr, Error_Msg_Line_Length, C);
1004:
1005:             --  -gnatJ (relaxed elaboration checking mode enabled)
1006:
1007:             when 'J' =>
```

## sem_warn.adb:1241–1257

```ada
1241:
1242:    begin
1243:       --  No messages if warnings are suppressed, or if we have detected any
1244:       --  real errors so far (this last check avoids junk messages resulting
1245:       --  from errors, e.g. a subunit that is not loaded). No messages if
1246:       --  we are in preanalysis (warnings will be detected properly later,
1247:       --  during analysis).
1248:
1249:       if Warning_Mode = Suppress
1250:         or else Serious_Errors_Detected /= 0
1251:         or else not Full_Analysis
1252:       then
1253:          return;
1254:       end if;
1255:
1256:       --  We also skip the messages if any subunits were not loaded (see
1257:       --  comment in Sem_Ch10 to understand how this is set, and why it is
```

## sem_warn.adb:1930–1943

```ada
1930:       end Prefix_Has_Dereference;
1931:
1932:    --  Start of processing for Check_Unset_Reference
1933:
1934:    begin
1935:       --  Nothing to do if warnings suppressed
1936:
1937:       if Warning_Mode = Suppress then
1938:          return;
1939:       end if;
1940:
1941:       --  Ignore reference unless it comes from source. Almost always if we
1942:       --  have a reference from generated code, it is bogus (e.g. calls to init
1943:       --  procs to set default discriminant values).
```

## sem_ch4.adb:4744–4794

```ada
4744:          --  of the quantified expression. If Kind is Full, Expr is the full
4745:          --  expression. If Kind is Conjunct (resp. Disjunct), Expr is a
4746:          --  conjunct (resp. disjunct) of the full expression.
4747:
4748:          -------------------
4749:          -- Check_Subexpr --
4750:          -------------------
4751:
4752:          procedure Check_Subexpr (Expr : Node_Id; Kind : Subexpr_Kind) is
4753:          begin
4754:             if Nkind (Expr) in N_Op_And | N_And_Then
4755:               and then Kind /= Disjunct
4756:             then
4757:                Check_Subexpr (Left_Opnd (Expr), Conjunct);
4758:                Check_Subexpr (Right_Opnd (Expr), Conjunct);
4759:
4760:             elsif Nkind (Expr) in N_Op_Or | N_Or_Else
4761:               and then Kind /= Conjunct
4762:             then
4763:                Check_Subexpr (Left_Opnd (Expr), Disjunct);
4764:                Check_Subexpr (Right_Opnd (Expr), Disjunct);
4765:
4766:             elsif Kind /= Full
4767:               and then not Referenced (Loop_Id, Expr)
4768:             then
4769:                declare
4770:                   Sub : constant String :=
4771:                     (if Kind = Conjunct then "conjunct" else "disjunct");
4772:                begin
4773:                   Error_Msg_NE
4774:                     ("?.t?unused variable & in " & Sub, Expr, Loop_Id);
4775:                   Error_Msg_NE
4776:                     ("\consider extracting " & Sub & " from quantified "
4777:                      & "expression", Expr, Loop_Id);
4778:                end;
4779:             end if;
4780:          end Check_Subexpr;
4781:
4782:       begin
4783:          if Warn_On_Suspicious_Contract
4784:            and then not Is_Internal_Name (Chars (Loop_Id))
4785:          then
4786:             if not Referenced (Loop_Id, Cond) then
4787:                Error_Msg_N ("?.t?unused variable &", Loop_Id);
4788:             else
4789:                Check_Subexpr (Cond, Kind => Full);
4790:             end if;
4791:          end if;
4792:       end;
4793:
4794:       --  Diagnose a possible misuse of the SOME existential quantifier. When
```

## sem_ch6.adb:11310–11347

```ada
11310:
11311:    procedure List_Inherited_Pre_Post_Aspects (E : Entity_Id) is
11312:    begin
11313:       if List_Inherited_Aspects
11314:         and then Is_Subprogram_Or_Generic_Subprogram (E)
11315:       then
11316:          declare
11317:             Subps : constant Subprogram_List := Inherited_Subprograms (E);
11318:             Items : Node_Id;
11319:             Prag  : Node_Id;
11320:
11321:          begin
11322:             for Index in Subps'Range loop
11323:                Items := Contract (Subps (Index));
11324:
11325:                if Present (Items) then
11326:                   Prag := Pre_Post_Conditions (Items);
11327:                   while Present (Prag) loop
11328:                      Error_Msg_Sloc := Sloc (Prag);
11329:
11330:                      if Class_Present (Prag) then
11331:                         if Pragma_Name (Prag) = Name_Precondition then
11332:                            Error_Msg_N
11333:                              ("info: & inherits `Pre''Class` aspect from "
11334:                               & "#?.l?", E);
11335:                         else
11336:                            Error_Msg_N
11337:                              ("info: & inherits `Post''Class` aspect from "
11338:                               & "#?.l?", E);
11339:                         end if;
11340:                      end if;
11341:
11342:                      Prag := Next_Pragma (Prag);
11343:                   end loop;
11344:                end if;
11345:             end loop;
11346:          end;
11347:       end if;
```

## sem_ch7.adb:2044–2057

```ada
2044:       --  Output relevant information as to why the package requires a body.
2045:       --  Do not consider generated packages as this exposes internal symbols
2046:       --  and leads to confusing messages.
2047:
2048:       if List_Body_Required_Info
2049:         and then In_Extended_Main_Source_Unit (Id)
2050:         and then Unit_Requires_Body (Id)
2051:         and then Comes_From_Source (Id)
2052:       then
2053:          Unit_Requires_Body_Info (Id);
2054:       end if;
2055:
2056:       --  Nested package specs that do not require bodies are not checked for
2057:       --  ineffective use clauses due to the possibility of subunits. This is
```

## sem_prag.adb:8190–8267

```ada
8190:       function Fix_Error (Msg : String) return String is
8191:          Res      : String (Msg'Range) := Msg;
8192:          Res_Last : Natural            := Msg'Last;
8193:          J        : Natural;
8194:
8195:       begin
8196:          --  If we have a rewriting of another pragma, go to that pragma
8197:
8198:          if Is_Rewrite_Substitution (N)
8199:            and then Nkind (Original_Node (N)) = N_Pragma
8200:          then
8201:             Error_Msg_Name_1 := Pragma_Name (Original_Node (N));
8202:          end if;
8203:
8204:          --  Case where pragma comes from an aspect specification
8205:
8206:          if From_Aspect_Specification (N) then
8207:
8208:             --  Change appearance of "pragma" in message to "aspect"
8209:
8210:             J := Res'First;
8211:             while J <= Res_Last - 5 loop
8212:                if Res (J .. J + 5) = "pragma" then
8213:                   Res (J .. J + 5) := "aspect";
8214:                   J := J + 6;
8215:
8216:                else
8217:                   J := J + 1;
8218:                end if;
8219:             end loop;
8220:
8221:             --  Change "argument of" at start of message to "entity for"
8222:
8223:             if Res'Length > 11
8224:               and then Res (Res'First .. Res'First + 10) = "argument of"
8225:             then
8226:                Res (Res'First .. Res'First + 9) := "entity for";
8227:                Res (Res'First + 10 .. Res_Last - 1) :=
8228:                  Res (Res'First + 11 .. Res_Last);
8229:                Res_Last := Res_Last - 1;
8230:             end if;
8231:
8232:             --  Change "argument" at start of message to "entity"
8233:
8234:             if Res'Length > 8
8235:               and then Res (Res'First .. Res'First + 7) = "argument"
8236:             then
8237:                Res (Res'First .. Res'First + 5) := "entity";
8238:                Res (Res'First + 6 .. Res_Last - 2) :=
8239:                  Res (Res'First + 8 .. Res_Last);
8240:                Res_Last := Res_Last - 2;
8241:             end if;
8242:
8243:             --  Get name from corresponding aspect
8244:
8245:             Error_Msg_Name_1 := Original_Aspect_Pragma_Name (N);
8246:          end if;
8247:
8248:          --  Return possibly modified message
8249:
8250:          return Res (Res'First .. Res_Last);
8251:       end Fix_Error;
8252:
8253:       -------------------------
8254:       -- Gather_Associations --
8255:       -------------------------
8256:
8257:       procedure Gather_Associations
8258:         (Names : Name_List;
8259:          Args  : out Args_List)
8260:       is
8261:          Arg : Node_Id;
8262:
8263:       begin
8264:          --  Initialize all parameters to Empty
8265:
8266:          for J in Args'Range loop
8267:             Args (J) := Empty;
```

## sem_prag.adb:28775–28805

```ada
28775:
28776:                if Arg_Count = 1 then
28777:
28778:                   --  On/Off one argument case was processed by parser
28779:
28780:                   if Nkind (Argx) = N_Identifier
28781:                     and then Chars (Argx) in Name_On | Name_Off
28782:                   then
28783:                      null;
28784:
28785:                   --  One argument case must be ON/OFF or static string expr
28786:
28787:                   elsif not Is_Static_String_Expression (Arg1) then
28788:                      Error_Pragma_Arg
28789:                        ("argument of pragma% must be On/Off or static string "
28790:                         & "expression", Arg1);
28791:
28792:                   --  Use of pragma Warnings to set warning switches is
28793:                   --  ignored in GNATprove mode, as these switches apply to
28794:                   --  the compiler only.
28795:
28796:                   elsif GNATprove_Mode then
28797:                      null;
28798:
28799:                   --  One argument string expression case
28800:
28801:                   else
28802:                      declare
28803:                         Lit : constant Node_Id   := Expr_Value_S (Argx);
28804:                         Str : constant String_Id := Strval (Lit);
28805:                         Len : constant Nat       := String_Length (Str);
```

## sem_prag.adb:35220–35328

```ada
35220:
35221:    procedure Validate_Compile_Time_Warning_Or_Error
35222:      (N     : Node_Id;
35223:       Eloc  : Source_Ptr)
35224:    is
35225:       Arg1    : constant Node_Id := First (Pragma_Argument_Associations (N));
35226:       Arg1x   : constant Node_Id := Get_Pragma_Arg (Arg1);
35227:       Prag_Id : constant Pragma_Id := Get_Pragma_Id (N);
35228:
35229:       procedure Emit_Compile_Time_Message (Msg_Arg : Node_Id);
35230:       --  Emit the pragma a as diagnostic message. New_Line characters are
35231:       --  considered separators for those messages where the following lines
35232:       --  are considered as continuation messages for the same diagnostic.
35233:
35234:       -------------------------------
35235:       -- Emit_Compile_Time_Message --
35236:       -------------------------------
35237:
35238:       procedure Emit_Compile_Time_Message (Msg_Arg : Node_Id) is
35239:          --  We have already verified that the Msg_Arg is a static
35240:          --  string expression. Its string value must be retrieved
35241:          --  explicitly if it is a declared constant, otherwise it has
35242:          --  been constant-folded previously.
35243:
35244:          Cent    : constant Entity_Id := Cunit_Entity (Current_Sem_Unit);
35245:          Str     : constant String_Id :=
35246:            Strval (Expr_Value_S (Get_Pragma_Arg (Msg_Arg)));
35247:          Str_Len : constant Nat := String_Length (Str);
35248:
35249:          Force : constant Boolean :=
35250:            Prag_Id = Pragma_Compile_Time_Warning
35251:            and then Is_Spec_Name (Unit_Name (Current_Sem_Unit))
35252:            and then (Ekind (Cent) /= E_Package
35253:                      or else not In_Private_Part (Cent));
35254:          --  Set True if this is the warning case, and we are in the
35255:          --  visible part of a package spec, or in a subprogram spec,
35256:          --  in which case we want to force the client to see the
35257:          --  warning, even though it is not in the main unit.
35258:
35259:          Msg_Ctrl : Bounded_String (6);
35260:          --  Control characters for the message.
35261:          --  The longest value contains 6 characters: "\<<~!!"
35262:
35263:          C    : Character;
35264:          CC   : Char_Code;
35265:          Cont : Boolean;
35266:          Ptr  : Nat;
35267:
35268:       begin
35269:          --  Loop through segments of message separated by line feeds.
35270:          --  We output these segments as separate messages with
35271:          --  continuation marks for all but the first.
35272:
35273:          Cont := False;
35274:          Ptr := 1;
35275:          loop
35276:             Error_Msg_Strlen := 0;
35277:             Msg_Ctrl.Length := 0;
35278:
35279:             --  Loop to copy characters from argument to error message
35280:             --  string buffer.
35281:
35282:             loop
35283:                exit when Ptr > Str_Len;
35284:                CC := Get_String_Char (Str, Ptr);
35285:                Ptr := Ptr + 1;
35286:
35287:                --  Ignore wide chars ??? else store character
35288:
35289:                if In_Character_Range (CC) then
35290:                   C := Get_Character (CC);
35291:                   exit when C = ASCII.LF;
35292:                   Error_Msg_Strlen := Error_Msg_Strlen + 1;
35293:                   Error_Msg_String (Error_Msg_Strlen) := C;
35294:                end if;
35295:             end loop;
35296:
35297:             --  Here with one line ready to go
35298:
35299:             Error_Msg_Warn := Prag_Id = Pragma_Compile_Time_Warning;
35300:
35301:             if Cont then
35302:                Append (Msg_Ctrl, "\");
35303:             end if;
35304:
35305:             Append (Msg_Ctrl, "<<~");
35306:
35307:             --  If this is a warning in a spec, then we want clients
35308:             --  to see the warning, so mark the message with the
35309:             --  special sequence !! to force the warning. In the case
35310:             --  of a package spec, we do not force this if we are in
35311:             --  the private part of the spec.
35312:
35313:             if Force then
35314:                Append (Msg_Ctrl, "!!");
35315:             end if;
35316:
35317:             --  Error, rather than warning, or in a body, so we do not
35318:             --  need to force visibility for client (error will be
35319:             --  output in any case, and this is the situation in which
35320:             --  we do not want a client to get a warning, since the
35321:             --  warning is in the body or the spec private part).
35322:
35323:             Error_Msg
35324:               (To_String (Msg_Ctrl), Eloc, N, Is_Compile_Time_Pragma => True);
35325:
35326:             --  The next lines are considered continuation messages
35327:
35328:             Cont := True;
```

## sem_util.adb:4321–4350

```ada
4321:             function Adjust_Message (Msg : String) return String;
4322:             --  Prepend a prefix to the input message Msg denoting that the
4323:             --  message applies to a conjunct in the expression, when this
4324:             --  is the case.
4325:
4326:             function Applied_On_Conjunct return Boolean;
4327:             --  Returns True if the message applies to a conjunct in the
4328:             --  expression, instead of the whole expression.
4329:
4330:             function Has_Global_Output (Subp : Entity_Id) return Boolean;
4331:             --  Returns True if Subp has an output in its Global contract
4332:
4333:             function Has_No_Output (Subp : Entity_Id) return Boolean;
4334:             --  Returns True if Subp has no declared output: no function
4335:             --  result, no output parameter, and no output in its Global
4336:             --  contract.
4337:
4338:             --------------------
4339:             -- Adjust_Message --
4340:             --------------------
4341:
4342:             function Adjust_Message (Msg : String) return String is
4343:             begin
4344:                if Applied_On_Conjunct then
4345:                   return "conjunct in " & Msg;
4346:                else
4347:                   return Msg;
4348:                end if;
4349:             end Adjust_Message;
4350:
```

## sem_util.adb:6020–6131

```ada
6020:    -----------------------------------
6021:
6022:    function Compile_Time_Constraint_Error
6023:      (N         : Node_Id;
6024:       Msg       : String;
6025:       Ent       : Entity_Id  := Empty;
6026:       Loc       : Source_Ptr := No_Location;
6027:       Warn      : Boolean    := False;
6028:       Extra_Msg : String     := "") return Node_Id
6029:    is
6030:       Msgc : String (1 .. Msg'Length + 3);
6031:       --  Copy of message, with room for possible ?? or << and ! at end
6032:
6033:       Msgl : Natural;
6034:       Wmsg : Boolean;
6035:       Eloc : Source_Ptr;
6036:
6037:    begin
6038:       --  If this is a warning, convert it into an error if we are in code
6039:       --  subject to SPARK_Mode being set On, unless Warn is True to force a
6040:       --  warning. The rationale is that a compile-time constraint error should
6041:       --  lead to an error instead of a warning when SPARK_Mode is On, but in
6042:       --  a few cases we prefer to issue a warning and generate both a suitable
6043:       --  run-time error in GNAT and a suitable check message in GNATprove.
6044:       --  Those cases are those that likely correspond to deactivated SPARK
6045:       --  code, so that this kind of code can be compiled and analyzed instead
6046:       --  of being rejected.
6047:
6048:       Error_Msg_Warn := Warn or SPARK_Mode /= On;
6049:
6050:       --  A static constraint error in an instance body is not a fatal error.
6051:       --  We choose to inhibit the message altogether, because there is no
6052:       --  obvious node (for now) on which to post it. On the other hand the
6053:       --  offending node must be replaced with a constraint_error in any case.
6054:
6055:       --  No messages are generated if we already posted an error on this node
6056:
6057:       if not Error_Posted (N) then
6058:          if Loc /= No_Location then
6059:             Eloc := Loc;
6060:          else
6061:             Eloc := Sloc (N);
6062:          end if;
6063:
6064:          --  Copy message to Msgc, converting any ? in the message into <
6065:          --  instead, so that we have an error in GNATprove mode.
6066:
6067:          Msgl := Msg'Length;
6068:
6069:          for J in 1 .. Msgl loop
6070:             if Msg (J) = '?' and then (J = 1 or else Msg (J - 1) /= ''') then
6071:                Msgc (J) := '<';
6072:             else
6073:                Msgc (J) := Msg (J);
6074:             end if;
6075:          end loop;
6076:
6077:          --  Message is a warning, even in Ada 95 case
6078:
6079:          if Msg (Msg'Last) = '?' or else Msg (Msg'Last) = '<' then
6080:             Wmsg := True;
6081:
6082:          --  In Ada 83, all messages are warnings. In the private part and the
6083:          --  body of an instance, constraint_checks are only warnings. We also
6084:          --  make this a warning if the Warn parameter is set.
6085:
6086:          elsif Warn
6087:            or else (Ada_Version = Ada_83 and then Comes_From_Source (N))
6088:            or else In_Instance_Not_Visible
6089:          then
6090:             Msgl := Msgl + 1;
6091:             Msgc (Msgl) := '<';
6092:             Msgl := Msgl + 1;
6093:             Msgc (Msgl) := '<';
6094:             Wmsg := True;
6095:
6096:          --  Otherwise we have a real error message (Ada 95 static case) and we
6097:          --  make this an unconditional message. Note that in the warning case
6098:          --  we do not make the message unconditional, it seems reasonable to
6099:          --  delete messages like this (about exceptions that will be raised)
6100:          --  in dead code.
6101:
6102:          else
6103:             Wmsg := False;
6104:             Msgl := Msgl + 1;
6105:             Msgc (Msgl) := '!';
6106:          end if;
6107:
6108:          --  One more test, skip the warning if the related expression is
6109:          --  statically unevaluated, since we don't want to warn about what
6110:          --  will happen when something is evaluated if it never will be
6111:          --  evaluated.
6112:
6113:          --  Suppress error reporting when checking that the expression of a
6114:          --  static expression function is a potentially static expression,
6115:          --  because we don't want additional errors being reported during the
6116:          --  preanalysis of the expression (see Analyze_Expression_Function).
6117:
6118:          if not Is_Statically_Unevaluated (N)
6119:            and then not Checking_Potentially_Static_Expression
6120:          then
6121:             if Present (Ent) then
6122:                Error_Msg_NEL (Msgc (1 .. Msgl), N, Ent, Eloc);
6123:             else
6124:                Error_Msg_NEL (Msgc (1 .. Msgl), N, Etype (N), Eloc);
6125:             end if;
6126:
6127:             --  Emit any extra message as a continuation
6128:
6129:             if Extra_Msg /= "" then
6130:                Error_Msg_N ('\' & Extra_Msg, N);
6131:             end if;
```

## sem_elab.adb:2335–2378

```ada
2335:
2336:          -----------------
2337:          -- Output_Call --
2338:          -----------------
2339:
2340:          procedure Output_Call (Subp_Id : Entity_Id; Kind : String) is
2341:          begin
2342:             Error_Msg_NE ("\\  " & Kind & " & called #", Error_Nod, Subp_Id);
2343:          end Output_Call;
2344:
2345:          -------------------------
2346:          -- Output_Type_Actions --
2347:          -------------------------
2348:
2349:          procedure Output_Type_Actions
2350:            (Subp_Id : Entity_Id;
2351:             Action  : String)
2352:          is
2353:             Typ : constant Entity_Id := First_Formal_Type (Subp_Id);
2354:
2355:          begin
2356:             pragma Assert (Present (Typ));
2357:
2358:             Error_Msg_NE
2359:               ("\\  " & Action & " actions for type & #", Error_Nod, Typ);
2360:          end Output_Type_Actions;
2361:
2362:          ------------------------------
2363:          -- Output_Verification_Call --
2364:          ------------------------------
2365:
2366:          procedure Output_Verification_Call
2367:            (Pred    : String;
2368:             Id      : Entity_Id;
2369:             Id_Kind : String)
2370:          is
2371:          begin
2372:             pragma Assert (Present (Id));
2373:
2374:             Error_Msg_NE
2375:               ("\\  " & Pred & " of " & Id_Kind & " & verified #",
2376:                Error_Nod, Id);
2377:          end Output_Verification_Call;
2378:
```

## sem_elab.adb:6420–6457

```ada
6420:          --  Obtain the prefix of the message
6421:
6422:          function Suffix return String;
6423:          pragma Inline (Suffix);
6424:          --  Obtain the suffix of the message
6425:
6426:          ------------
6427:          -- Prefix --
6428:          ------------
6429:
6430:          function Prefix return String is
6431:          begin
6432:             if Info_Msg then
6433:                return "info: ";
6434:             else
6435:                return "";
6436:             end if;
6437:          end Prefix;
6438:
6439:          ------------
6440:          -- Suffix --
6441:          ------------
6442:
6443:          function Suffix return String is
6444:          begin
6445:             if In_SPARK then
6446:                return " in SPARK";
6447:             else
6448:                return "?$?";
6449:             end if;
6450:          end Suffix;
6451:
6452:       --  Start of processing for Elab_Msg_NE
6453:
6454:       begin
6455:          Error_Msg_NE (Prefix & Msg & Suffix, N, Id);
6456:       end Elab_Msg_NE;
6457:
```

## sem_elab.adb:17900–17920

```ada
17900:
17901:          Set_Elaborate_Body_Desirable (Pkg_Spec);
17902:
17903:          --  All OK in gnat mode (we know what we are doing)
17904:
17905:          if GNAT_Mode then
17906:             return;
17907:          end if;
17908:
17909:          --  All OK if all warnings suppressed
17910:
17911:          if Warning_Mode = Suppress then
17912:             return;
17913:          end if;
17914:
17915:          --  All OK if elaboration checks suppressed for entity
17916:
17917:          if Checks_May_Be_Suppressed (Ent)
17918:            and then Is_Check_Suppressed (Ent, Elaboration_Check)
17919:          then
17920:             return;
```

## inline.adb:1950–2030

```ada
1950:    --  Start of processing for Can_Be_Inlined_In_GNATprove_Mode
1951:
1952:    begin
1953:       pragma Assert (Present (Spec_Id) or else Present (Body_Id));
1954:
1955:       if Present (Spec_Id) then
1956:          Id := Spec_Id;
1957:       else
1958:          Id := Body_Id;
1959:       end if;
1960:
1961:       --  Only local subprograms without contracts are inlined in GNATprove
1962:       --  mode, as these are the subprograms which a user is not interested in
1963:       --  analyzing in isolation, but rather in the context of their call. This
1964:       --  is a convenient convention, that could be changed for an explicit
1965:       --  pragma/aspect one day.
1966:
1967:       --  In a number of special cases, inlining is not desirable or not
1968:       --  possible, see below.
1969:
1970:       --  Do not inline unit-level subprograms
1971:
1972:       if Is_Unit_Subprogram (Id) then
1973:          return False;
1974:
1975:       --  Do not inline subprograms declared in package specs, because they are
1976:       --  not local, i.e. can be called either from anywhere (if declared in
1977:       --  visible part) or from the child units (if declared in private part).
1978:
1979:       elsif In_Package_Spec (Id) then
1980:          return False;
1981:
1982:       --  Do not inline subprograms declared in other units. This is important
1983:       --  in particular for subprograms defined in the private part of a
1984:       --  package spec, when analyzing one of its child packages, as otherwise
1985:       --  we issue spurious messages about the impossibility to inline such
1986:       --  calls.
1987:
1988:       elsif not In_Extended_Main_Code_Unit (Id) then
1989:          return False;
1990:
1991:       --  Do not inline dispatching operations, as only their static calls
1992:       --  can be analyzed in context, and not their dispatching calls.
1993:
1994:       elsif Is_Dispatching_Operation (Id) then
1995:          return False;
1996:
1997:       --  Do not inline subprograms marked No_Return, possibly used for
1998:       --  signaling errors, which GNATprove handles specially.
1999:
2000:       elsif No_Return (Id) then
2001:          return False;
2002:
2003:       --  Do not inline subprograms that have a contract on the spec or the
2004:       --  body. Use the contract(s) instead in GNATprove. This also prevents
2005:       --  inlining of subprograms with Extensions_Visible or Volatile_Function.
2006:
2007:       elsif (Present (Spec_Id) and then Has_Some_Contract (Spec_Id))
2008:                or else
2009:             (Present (Body_Id) and then Has_Some_Contract (Body_Id))
2010:       then
2011:          return False;
2012:
2013:       --  Do not inline expression functions, which are directly inlined at the
2014:       --  prover level.
2015:
2016:       elsif (Present (Spec_Id) and then Is_Expression_Function (Spec_Id))
2017:               or else
2018:             (Present (Body_Id) and then Is_Expression_Function (Body_Id))
2019:       then
2020:          return False;
2021:
2022:       --  Do not inline generic subprogram instances. The visibility rules of
2023:       --  generic instances plays badly with inlining.
2024:
2025:       elsif Is_Generic_Instance (Spec_Id) then
2026:          return False;
2027:
2028:       --  Only inline subprograms whose spec is marked SPARK_Mode On. For
2029:       --  the subprogram body, a similar check is performed after the body
2030:       --  is analyzed, as this is where a pragma SPARK_Mode might be inserted.
```

## inline.adb:2114–2170

```ada
2114:    procedure Cannot_Inline
2115:      (Msg           : String;
2116:       N             : Node_Id;
2117:       Subp          : Entity_Id;
2118:       Is_Serious    : Boolean := False;
2119:       Suppress_Info : Boolean := False)
2120:    is
2121:       Inline_Prefix : constant String := "cannot inline";
2122:
2123:       function Starts_With (S, Prefix : String) return Boolean is
2124:         (S (S'First .. S'First + Prefix'Length - 1) = Prefix);
2125:
2126:    begin
2127:       --  In GNATprove mode, inlining is the technical means by which the
2128:       --  higher-level goal of contextual analysis is reached, so issue
2129:       --  messages about failure to apply contextual analysis to a
2130:       --  subprogram, rather than failure to inline it.
2131:
2132:       if GNATprove_Mode
2133:         and then Starts_With (Msg, Inline_Prefix)
2134:       then
2135:          declare
2136:             Msg_Txt : constant String :=
2137:               Msg (Msg'First + Inline_Prefix'Length .. Msg'Last);
2138:
2139:             New_Msg : constant String :=
2140:               "info: no contextual analysis of" & Msg_Txt;
2141:          begin
2142:             Cannot_Inline (New_Msg, N, Subp, Is_Serious, Suppress_Info);
2143:             return;
2144:          end;
2145:       end if;
2146:
2147:       --  Legacy front-end inlining model
2148:
2149:       if not Back_End_Inlining then
2150:
2151:          --  Do not emit warning if this is a predefined unit which is not
2152:          --  the main unit. With validity checks enabled, some predefined
2153:          --  subprograms may contain nested subprograms and become ineligible
2154:          --  for inlining.
2155:
2156:          if Is_Predefined_Unit (Get_Source_Unit (Subp))
2157:            and then not In_Extended_Main_Source_Unit (Subp)
2158:          then
2159:             null;
2160:
2161:          --  In GNATprove mode, issue an info message when -gnatd_f is set and
2162:          --  Suppress_Info is False, and indicate that the subprogram is not
2163:          --  always inlined by setting flag Is_Inlined_Always to False.
2164:
2165:          elsif GNATprove_Mode then
2166:             Set_Is_Inlined_Always (Subp, False);
2167:
2168:             if Debug_Flag_Underscore_F and not Suppress_Info then
2169:                Error_Msg_NE (Msg, N, Subp);
2170:             end if;
```

## SPARK why/back_end.adb:126–208

```ada
126:       --  We are in the gnat2why executable, so GNATprove_Mode is always true
127:       --  note that this flag needs to be set very early on, since e.g.
128:       --  Scan_Compiler_Arguments uses it.
129:
130:       Opt.GNATprove_Mode := True;
131:
132:       GNAT2Why_BE.Scan_Compiler_Arguments;
133:
134:       --  Read extra options for gnat2why
135:
136:       declare
137:          Args_File   : String renames Opt.SPARK_Switches_File_Name.all;
138:          Source_File : constant String :=
139:            Ada.Directories.Simple_Name (Osint.Get_First_Main_File_Name);
140:       begin
141:          Gnat2Why_Args.Load (Args_File, Source_File);
142:       end;
143:
144:       --  For the pretty output mode, we set -gnatdF to force alternative
145:       --  display of messages in Errout.
146:
147:       if Gnat2Why_Args.Output_Mode in Gnat2Why_Opts.GPO_Pretty then
148:          Debug_Flag_FF := True;
149:       end if;
150:
151:       --  For the colored output mode, we set the corresponding flag in
152:       --  Erroutc.
153:
154:       if Gnat2Why_Args.Output_Mode = Gnat2Why_Opts.GPO_Pretty_Color then
155:          Erroutc.Use_SGR_Control := True;
156:       end if;
157:
158:       --  gnat2why is run in two main modes:
159:       --    Global_Gen_Mode = True for generating ALI files with effects.
160:       --    Global_Gen_Mode = False for flow analysis and proof.
161:
162:       if Gnat2Why_Args.Global_Gen_Mode then
163:          --  In this mode, we should run the frontend with no warnings. They
164:          --  will be issued in the second run.
165:
166:          Opt.Warning_Mode := Opt.Suppress;
167:
168:          --  In this mode, we should avoid issuing errors in marking. They will
169:          --  be issued in the second run.
170:
171:          SPARK_Definition.Inhibit_Messages;
172:
173:       else
174:          --  In this mode, we should run the frontend and gnat2why with warning
175:          --  mode specified through --warnings switch.
176:
177:          Opt.Warning_Mode :=
178:            To_Front_End_Warning_Mode (Gnat2Why_Args.Warning_Mode);
179:
180:          --  An ALI file should be generated only when generating globals.
181:          --  Otherwise, when translating the program to Why, ALI file
182:          --  generation should be disabled.
183:
184:          Opt.Disable_ALI_File := True;
185:       end if;
186:
187:       Debug_Flag_M := Gnat2Why_Args.No_Inlining;
188:       --  Make this depend on the value for the unrolling warnings
189:       Debug_Flag_Underscore_F :=
190:         VC_Kinds.Warning_Status (VC_Kinds.Warn_Info_Unrolling_Inlining)
191:         /= VC_Kinds.WS_Disabled;
192:
193:    end Scan_Compiler_Arguments;
194:
195:    -------------------------------
196:    -- To_Front_End_Warning_Mode --
197:    -------------------------------
198:
199:    function To_Front_End_Warning_Mode
200:      (M : Gnat2Why_Opts.SPARK_Warning_Mode_Type) return Opt.Warning_Mode_Type
201:    is
202:    begin
203:       return
204:         (case M is
205:            when Gnat2Why_Opts.SW_Suppress       => Opt.Suppress,
206:            when Gnat2Why_Opts.SW_Normal         => Opt.Normal,
207:            when Gnat2Why_Opts.SW_Treat_As_Error => Opt.Treat_As_Error);
208:    end To_Front_End_Warning_Mode;
```
