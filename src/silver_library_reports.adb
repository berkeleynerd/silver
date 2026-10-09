package body Silver_Library_Reports with SPARK_Mode => On is
   subtype Offset is Natural range 0 .. Max_Report_Length + 1;
   type Span is record
      First : Offset := 0;
      Last : Offset := 0;
   end record;
   Missing : constant Span := (0, 0);
   Malformed : constant Span := (0, 1);

   function Valid (Text : String; Item : Span) return Boolean is
     (Item.First >= 1 and then Item.First <= Item.Last
      and then Item.Last <= Text'Length);

   function Space (C : Character) return Boolean is
     (C = ' ' or else C = Character'Val (9)
      or else C = Character'Val (10) or else C = Character'Val (13));

   procedure Skip_Space (Text : String; Position : in out Offset)
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
       and then Position in 1 .. Text'Length + 1,
          Post => Position in Position'Old .. Text'Length + 1
   is
   begin
      while Position <= Text'Length and then Space (Text (Position)) loop
         pragma Loop_Invariant (Position in Position'Loop_Entry .. Text'Length + 1);
         pragma Loop_Variant (Increases => Position);
         Position := Position + 1;
      end loop;
   end Skip_Space;

   --  Locate one value without executable recursion. Quoted strings and their
   --  escapes do not affect container nesting. GNATprove's objects/arrays fit
   --  comfortably within this explicit bound; excess nesting is rejected.
   function Value_End (Text : String; Start : Offset) return Offset
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
       and then Start in 1 .. Text'Length + 1,
          Post => Value_End'Result = 0 or else
            Value_End'Result in Start .. Text'Length
   is
      Stack : String (1 .. 64) := (others => ' ');
      Depth : Natural range 0 .. 64 := 0;
      Quoted : Boolean := False;
      Escaped : Boolean := False;
      Container : constant Boolean := Start <= Text'Length
        and then (Text (Start) = '{' or else Text (Start) = '[');
   begin
      if Start > Text'Length then
         return 0;
      end if;
      for I in Start .. Text'Length loop
         if Quoted then
            if Escaped then
               Escaped := False;
            elsif Text (I) = '\' then
               Escaped := True;
            elsif Text (I) = '"' then
               Quoted := False;
               if not Container then
                  return I;
               end if;
            end if;
         elsif Text (I) = '"' then
            Quoted := True;
         elsif Text (I) = '{' or else Text (I) = '[' then
            if Depth = 64 then
               return 0;
            end if;
            Depth := Depth + 1;
            Stack (Depth) := Text (I);
         elsif Text (I) = '}' or else Text (I) = ']' then
            if Depth = 0 then
               if I > Start and then not Container then
                  return I - 1;
               end if;
               return 0;
            end if;
            if (Text (I) = '}' and then Stack (Depth) /= '{')
              or else (Text (I) = ']' and then Stack (Depth) /= '[')
            then
               return 0;
            end if;
            Depth := Depth - 1;
            if Depth = 0 then
               return I;
            end if;
         elsif not Container and then (Text (I) = ',' or else Space (Text (I))) then
            if I > Start then
               return I - 1;
            end if;
            return 0;
         end if;
      end loop;
      return 0;
   end Value_End;

   function String_Equal (Text : String; Item : Span; Expected : String)
     return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function String_Equal (Text : String; Item : Span; Expected : String)
     return Boolean is
     (Valid (Text, Item) and then Item.Last - Item.First >= 1
      and then Text (Item.First) = '"' and then Text (Item.Last) = '"'
      and then Text (Item.First + 1 .. Item.Last - 1) = Expected);

   --  Extract an immediate object member, rejecting repeated requested keys.
   --  Object traversal always validates delimiters and advances by whole values.
   function Field (Text : String; Object : Span; Name : String) return Span
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
          Post => Field'Result = Missing or else Field'Result = Malformed
            or else Valid (Text, Field'Result)
   is
      P : Offset;
      Key_End, Last : Offset;
      Key : Span;
      Result : Span := Missing;
   begin
      if not Valid (Text, Object) or else Text (Object.First) /= '{'
        or else Text (Object.Last) /= '}'
      then
         return Malformed;
      end if;
      P := Object.First + 1;
      loop
         pragma Loop_Invariant (P in Object.First + 1 .. Text'Length + 1);
         pragma Loop_Invariant (Result = Missing or else Valid (Text, Result));
         pragma Loop_Variant (Increases => P);
         Skip_Space (Text, P);
         if P = Object.Last then
            return Result;
         elsif P >= Object.Last or else Text (P) /= '"' then
            return Malformed;
         end if;
         Key_End := Value_End (Text, P);
         if Key_End = 0 or else Key_End >= Object.Last then
            return Malformed;
         end if;
         Key := (P, Key_End);
         P := Key_End + 1;
         Skip_Space (Text, P);
         if P >= Object.Last or else Text (P) /= ':' then
            return Malformed;
         end if;
         P := P + 1;
         Skip_Space (Text, P);
         Last := Value_End (Text, P);
         if Last = 0 or else Last >= Object.Last then
            return Malformed;
         end if;
         if String_Equal (Text, Key, Name) then
            if Result /= Missing then
               return Malformed;
            end if;
            Result := (P, Last);
         end if;
         P := Last + 1;
         Skip_Space (Text, P);
         if P = Object.Last then
            return Result;
         elsif P >= Object.Last or else Text (P) /= ',' then
            return Malformed;
         end if;
         P := P + 1;
         Skip_Space (Text, P);
         if P >= Object.Last then
            return Malformed;
         end if;
      end loop;
   end Field;

   function Empty_Array (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      P : Offset;
   begin
      if not Valid (Text, Item) or else Text (Item.First) /= '['
        or else Text (Item.Last) /= ']'
      then
         return False;
      end if;
      P := Item.First + 1;
      Skip_Space (Text, P);
      return P = Item.Last;
   end Empty_Array;

   type Entity_Kind is (Unknown, IO_Package, Put_Line, Libc_Package,
                       Put_Byte, Flush, Set_Exit_Status, Arguments_Package,
                       Input_Is_Valid, First_Or_Default, Reject, Is_Message,
                       Runtime_Package, Argument_Count, Argument, Runtime_Exit_Status);
   function Location_OK (Text : String; Entity : Span; Name : Entity_Kind)
     return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      Locations : constant Span := Field (Text, Entity, "sloc");
      P, Last : Offset;
      File : Span;
   begin
      if not Valid (Text, Locations) or else Text (Locations.First) /= '['
        or else Text (Locations.Last) /= ']'
      then return False; end if;
      P := Locations.First + 1;
      Skip_Space (Text, P);
      Last := Value_End (Text, P);
      if Last = 0 or else Last >= Locations.Last then return False; end if;
      File := Field (Text, (P, Last), "file");
      P := Last + 1;
      Skip_Space (Text, P);
      if P /= Locations.Last then return False; end if;
      if Name in IO_Package | Put_Line then
         return String_Equal (Text, File, "silver_io.ads");
      end if;
      case Name is
         when Libc_Package | Put_Byte | Flush | Set_Exit_Status =>
            return String_Equal (Text, File, "silver_output_libc.ads");
         when Arguments_Package | Input_Is_Valid | First_Or_Default | Reject =>
            return String_Equal (Text, File, "silver_arguments.ads");
         when Is_Message =>
            return String_Equal (Text, File, "silver_arguments.adb");
         when Runtime_Package | Argument_Count | Argument | Runtime_Exit_Status =>
            return String_Equal (Text, File, "silver_runtime.ads");
         when others => return False;
      end case;
   end Location_OK;

   function Entity_Name (Text : String; Entity : Span) return Entity_Kind
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      Name : constant Span := Field (Text, Entity, "name");
      Result : Entity_Kind := Unknown;
   begin
      if String_Equal (Text, Name, "Silver_IO") then Result := IO_Package;
      elsif String_Equal (Text, Name, "Silver_IO.Put_Line") then Result := Put_Line;
      elsif String_Equal (Text, Name, "Silver_Output_Libc") then Result := Libc_Package;
      elsif String_Equal (Text, Name, "Silver_Output_Libc.Put_Byte") then Result := Put_Byte;
      elsif String_Equal (Text, Name, "Silver_Output_Libc.Flush") then Result := Flush;
      elsif String_Equal (Text, Name, "Silver_Output_Libc.Set_Exit_Status") then Result := Set_Exit_Status;
      elsif String_Equal (Text, Name, "Silver_Arguments") then Result := Arguments_Package;
      elsif String_Equal (Text, Name, "Silver_Arguments.Input_Is_Valid") then Result := Input_Is_Valid;
      elsif String_Equal (Text, Name, "Silver_Arguments.First_Or_Default") then Result := First_Or_Default;
      elsif String_Equal (Text, Name, "Silver_Arguments.Reject") then Result := Reject;
      elsif String_Equal (Text, Name, "Silver_Arguments.Is_Message") then Result := Is_Message;
      elsif String_Equal (Text, Name, "Silver_Runtime") then Result := Runtime_Package;
      elsif String_Equal (Text, Name, "Silver_Runtime.Argument_Count") then Result := Argument_Count;
      elsif String_Equal (Text, Name, "Silver_Runtime.Argument") then Result := Argument;
      elsif String_Equal (Text, Name, "Silver_Runtime.Set_Exit_Status") then Result := Runtime_Exit_Status;
      end if;
      if not Location_OK (Text, Entity, Result) then return Unknown; end if;
      return Result;
   end Entity_Name;

   function Positive_Number (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      Nonzero : Boolean := False;
   begin
      if not Valid (Text, Item) then return False; end if;
      for I in Item.First .. Item.Last loop
         if Text (I) not in '0' .. '9' then return False; end if;
         Nonzero := Nonzero or else Text (I) /= '0';
      end loop;
      return Nonzero;
   end Positive_Number;

   function Nonempty_String (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Nonempty_String (Text : String; Item : Span) return Boolean is
     (Valid (Text, Item) and then Item.Last - Item.First > 1
      and then Text (Item.First) = '"' and then Text (Item.Last) = '"');

   function Referenced_Entity (Text : String; Entities, Arg : Span) return Span
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
   begin
      if not Valid (Text, Arg) then return Missing; end if;
      for I in Arg.First .. Arg.Last loop
         if Text (I) not in '0' .. '9' then return Missing; end if;
      end loop;
      declare
         Number : constant String := Text (Arg.First .. Arg.Last);
         Entity : constant Span := Field (Text, Entities, " " & Number);
      begin
         if Entity /= Missing then return Entity; end if;
         return Field (Text, Entities, Number);
      end;
   end Referenced_Entity;

   function Reference_OK (Text : String; Entities, Reference : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      Predicate : constant Span := Field (Text, Reference, "predicate");
      Entity : constant Span := Referenced_Entity
        (Text, Entities, Field (Text, Reference, "arg"));
   begin
      return (String_Equal (Text, Predicate, "CLAIM_POST")
              or else String_Equal (Text, Predicate, "CLAIM_AORTE")
              or else String_Equal (Text, Predicate, "CLAIM_EFFECTS"))
        and then Entity_Name (Text, Entity) /= Unknown;
   end Reference_OK;

   type List_Kind is (Checks, References, Postconditions, Argument_Postconditions);
   function List_OK
     (Text : String; Items, Entities : Span; Kind : List_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Record_OK
     (Text : String; Item, Entities : Span; Kind : List_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      How : Span;
   begin
      if Kind = References then return Reference_OK (Text, Entities, Item); end if;
      if Kind in Postconditions | Argument_Postconditions then
         return String_Equal (Text, Field (Text, Item, "rule"), "VC_POSTCONDITION")
           and then Entity_Name (Text, Referenced_Entity
             (Text, Entities, Field (Text, Item, "entity")))
                = (if Kind = Postconditions then Put_Line else First_Or_Default);
      end if;
      How := Field (Text, Item, "how_proved");
      return String_Equal (Text, Field (Text, Item, "severity"), "info")
        and then (String_Equal (Text, How, "flow")
          or else String_Equal (Text, How, "prover")
          or else String_Equal (Text, How, "trivial"))
        and then Field (Text, Item, "justification") = Missing
        and then Field (Text, Item, "justified") = Missing
        and then Field (Text, Item, "suppressed") = Missing
        and then Field (Text, Item, "annot_kind") = Missing
        and then Field (Text, Item, "justif_msg") = Missing
        and then Nonempty_String (Text, Field (Text, Item, "rule"))
        and then (String_Equal (Text, Field (Text, Item, "file"), "silver_io.ads")
          or else String_Equal (Text, Field (Text, Item, "file"), "silver_io.adb")
          or else String_Equal (Text, Field (Text, Item, "file"), "silver_output_libc.ads")
          or else String_Equal (Text, Field (Text, Item, "file"), "silver_arguments.ads")
          or else String_Equal (Text, Field (Text, Item, "file"), "silver_arguments.adb")
          or else String_Equal (Text, Field (Text, Item, "file"), "silver_runtime.ads"))
        and then Positive_Number (Text, Field (Text, Item, "line"))
        and then Positive_Number (Text, Field (Text, Item, "col"))
        and then Entity_Name (Text, Referenced_Entity
          (Text, Entities, Field (Text, Item, "entity"))) /= Unknown;
   end Record_OK;

   function List_OK
     (Text : String; Items, Entities : Span; Kind : List_Kind) return Boolean
   is
      P, Last : Offset;
      Found : Boolean := False;
   begin
      if not Valid (Text, Items) or else Text (Items.First) /= '['
        or else Text (Items.Last) /= ']'
      then return False; end if;
      P := Items.First + 1;
      loop
         pragma Loop_Invariant (P in Items.First + 1 .. Text'Length + 1);
         pragma Loop_Variant (Increases => P);
         Skip_Space (Text, P);
         if P = Items.Last then return Kind not in Postconditions | Argument_Postconditions or else Found; end if;
         if P >= Items.Last or else Text (P) /= '{' then return False; end if;
         Last := Value_End (Text, P);
         if Last = 0 or else Last >= Items.Last then return False; end if;
         if Kind in Postconditions | Argument_Postconditions then
            Found := Found or else Record_OK (Text, (P, Last), Entities, Kind);
         elsif not Record_OK (Text, (P, Last), Entities, Kind) then
            return False;
         end if;
         P := Last + 1;
         Skip_Space (Text, P);
         if P = Items.Last then return Kind not in Postconditions | Argument_Postconditions or else Found; end if;
         if P >= Items.Last or else Text (P) /= ',' then return False; end if;
         P := P + 1;
         Skip_Space (Text, P);
         if P >= Items.Last then return False; end if;
      end loop;
   end List_OK;

   function Dependencies_OK
     (Text : String; Items, Entities : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      P, Last : Offset;
   begin
      if not Valid (Text, Items) or else Text (Items.First) /= '['
        or else Text (Items.Last) /= ']'
      then return False; end if;
      P := Items.First + 1;
      loop
         pragma Loop_Invariant (P in Items.First + 1 .. Text'Length + 1);
         pragma Loop_Variant (Increases => P);
         Skip_Space (Text, P);
         if P = Items.Last then return True; end if;
         if P >= Items.Last or else Text (P) /= '{' then return False; end if;
         Last := Value_End (Text, P);
         if Last = 0 or else Last >= Items.Last
           or else not Reference_OK (Text, Entities, Field (Text, (P, Last), "claim"))
           or else not List_OK (Text, Field (Text, (P, Last), "assumptions"), Entities, References)
         then return False; end if;
         P := Last + 1;
         Skip_Space (Text, P);
         if P = Items.Last then return True; end if;
         if P >= Items.Last or else Text (P) /= ',' then return False; end if;
         P := P + 1;
         Skip_Space (Text, P);
         if P >= Items.Last then return False; end if;
      end loop;
   end Dependencies_OK;

   function Expected_Entity (Name : Entity_Kind; Kind : Report_Kind)
     return Boolean is
     (case Kind is
        when Library_Body => Name in IO_Package | Put_Line | Put_Byte | Flush | Set_Exit_Status,
        when Imported_Interface => Name in Libc_Package | Put_Byte | Flush | Set_Exit_Status,
        when Arguments_Body => Name in Arguments_Package | Input_Is_Valid | First_Or_Default
          | Reject | Is_Message | Set_Exit_Status | Argument_Count | Argument,
        when Runtime_Interface => Name in Runtime_Package | Argument_Count | Argument | Runtime_Exit_Status);

   function Expected_Coverage (Name : Entity_Kind; Kind : Report_Kind)
     return String is
     (case Kind is
        when Library_Body => (if Name in IO_Package | Put_Line then "all" else ""),
        when Imported_Interface =>
          (if Name = Libc_Package then "all"
           elsif Name in Put_Byte | Flush | Set_Exit_Status then "spec" else ""),
        when Arguments_Body =>
          (if Name in Arguments_Package | Input_Is_Valid | First_Or_Default | Reject | Is_Message
           then "all" else ""),
        when Runtime_Interface =>
          (if Name = Runtime_Package then "all"
           elsif Name in Argument_Count | Argument | Runtime_Exit_Status then "spec" else ""));

   --  Every entity belongs to the selected owned source or an approved import.
   --  An unexpected owned declaration cannot hide outside the coverage map.
   function Entities_OK
     (Text : String; Entities : Span; Kind : Report_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      Seen : array (Entity_Kind) of Boolean := (others => False);
      P, Key_End, Last : Offset;
      Key : Span;
      Name : Entity_Kind;
   begin
      if not Valid (Text, Entities) or else Text (Entities.First) /= '{'
        or else Text (Entities.Last) /= '}'
      then return False; end if;
      P := Entities.First + 1;
      loop
         pragma Loop_Invariant (P in Entities.First + 1 .. Text'Length + 1);
         pragma Loop_Variant (Increases => P);
         Skip_Space (Text, P);
         if P = Entities.Last then exit; end if;
         if P >= Entities.Last or else Text (P) /= '"' then return False; end if;
         Key_End := Value_End (Text, P);
         if Key_End = 0 or else Key_End >= Entities.Last
           or else Key_End - P < 1
         then return False; end if;
         Key := (P + 1, Key_End - 1);
         P := Key_End + 1;
         Skip_Space (Text, P);
         if P >= Entities.Last or else Text (P) /= ':' then return False; end if;
         P := P + 1;
         Skip_Space (Text, P);
         Last := Value_End (Text, P);
         if Last = 0 or else Last >= Entities.Last then return False; end if;
         if Field (Text, Entities, Text (Key.First .. Key.Last)) /= (P, Last)
         then return False; end if;
         Name := Entity_Name (Text, (P, Last));
         if Name = Unknown or else Seen (Name) then return False; end if;
         Seen (Name) := True;
         P := Last + 1;
         Skip_Space (Text, P);
         if P = Entities.Last then exit; end if;
         if P >= Entities.Last or else Text (P) /= ',' then return False; end if;
         P := P + 1;
         Skip_Space (Text, P);
         if P >= Entities.Last then return False; end if;
      end loop;
      return (for all Name in Entity_Kind => Seen (Name) = Expected_Entity (Name, Kind));
   end Entities_OK;

   function Coverage_OK
     (Text : String; Coverage, Entities : Span; Kind : Report_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
   is
      Seen : array (Entity_Kind) of Boolean := (others => False);
      P, Key_End, Last : Offset;
      Entity : Span;
      Name : Entity_Kind;
   begin
      if not Valid (Text, Coverage) or else Text (Coverage.First) /= '{'
        or else Text (Coverage.Last) /= '}'
      then return False; end if;
      P := Coverage.First + 1;
      loop
         pragma Loop_Invariant (P in Coverage.First + 1 .. Text'Length + 1);
         pragma Loop_Variant (Increases => P);
         Skip_Space (Text, P);
         if P = Coverage.Last then exit; end if;
         if P >= Coverage.Last or else Text (P) /= '"' then return False; end if;
         Key_End := Value_End (Text, P);
         if Key_End = 0 or else Key_End >= Coverage.Last
           or else Key_End - P < 1
         then return False; end if;
         Entity := Field (Text, Entities, Text (P + 1 .. Key_End - 1));
         Name := Entity_Name (Text, Entity);
         if Name = Unknown or else Seen (Name) then return False; end if;
         Seen (Name) := True;
         P := Key_End + 1;
         Skip_Space (Text, P);
         if P >= Coverage.Last or else Text (P) /= ':' then return False; end if;
         P := P + 1;
         Skip_Space (Text, P);
         Last := Value_End (Text, P);
         if Last = 0 or else Last >= Coverage.Last then return False; end if;
         if Expected_Coverage (Name, Kind)'Length = 0
           or else not String_Equal (Text, (P, Last), Expected_Coverage (Name, Kind))
         then return False; end if;
         P := Last + 1;
         Skip_Space (Text, P);
         if P = Coverage.Last then exit; end if;
         if P >= Coverage.Last or else Text (P) /= ',' then return False; end if;
         P := P + 1;
         Skip_Space (Text, P);
         if P >= Coverage.Last then return False; end if;
      end loop;
      return (for all Name in Entity_Kind =>
        Seen (Name) = (Expected_Coverage (Name, Kind)'Length > 0));
   end Coverage_OK;

   function Audit_Report (Report : String; Kind : Report_Kind) return Boolean is
   begin
      if Report'Length not in 1 .. Max_Report_Length then return False; end if;
      declare
         Text : constant String (1 .. Report'Length) := Report;
         Start : Offset := 1;
         Last : Offset;
         Tail : Offset;
         Object, Entities : Span;
      begin
         Skip_Space (Text, Start);
         Last := Value_End (Text, Start);
         if Last = 0 then return False; end if;
         Tail := Last + 1;
         Skip_Space (Text, Tail);
         if Tail /= Text'Length + 1 then return False; end if;
         Object := (Start, Last);
         Entities := Field (Text, Object, "entities");
         return String_Equal (Text, Field (Text, Object, "progress"), "PROGRESS_PROOF")
           and then String_Equal (Text, Field (Text, Object, "stop_reason"), "STOP_REASON_NONE")
           and then Empty_Array (Text, Field (Text, Object, "skip_flow_proof"))
           and then Empty_Array (Text, Field (Text, Object, "skip_proof"))
           and then Empty_Array (Text, Field (Text, Object, "pragma_assume"))
           and then Empty_Array (Text, Field (Text, Object, "warn_error"))
           and then Entities_OK (Text, Entities, Kind)
           and then Coverage_OK (Text, Field (Text, Object, "spark"), Entities, Kind)
           and then List_OK (Text, Field (Text, Object, "flow"), Entities, Checks)
           and then List_OK (Text, Field (Text, Object, "proof"), Entities, Checks)
           and then Dependencies_OK (Text, Field (Text, Object, "assumptions"), Entities)
           and then (Kind in Imported_Interface | Runtime_Interface or else
             (not Empty_Array (Text, Field (Text, Object, "flow"))
              and then not Empty_Array (Text, Field (Text, Object, "proof"))
              and then List_OK (Text, Field (Text, Object, "proof"), Entities,
                (if Kind = Library_Body then Postconditions else Argument_Postconditions))));
      end;
   end Audit_Report;

   function Complete_Runtime_Proof
     (Report : String; Kind : Report_Kind) return Boolean is
   begin
      return Audit_Report (Report, Kind);
   end Complete_Runtime_Proof;
end Silver_Library_Reports;
