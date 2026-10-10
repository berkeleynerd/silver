package body Silver_Library_Reports with SPARK_Mode => On is
   type Audit_Kind is (IO_Body, Libc_Interface, Argument_Body, Argv_Interface, Main_Body, Assignment_Main, Assignment_Effects);
   function Audit_Of (Kind : Report_Kind) return Audit_Kind is
     (case Kind is
        when Library_Body => IO_Body,
        when Imported_Interface => Libc_Interface,
        when Arguments_Body => Argument_Body,
        when Runtime_Interface => Argv_Interface);

   Atom_Empty : constant String := "";
   Atom_INEFFECTIVE : constant String := "INEFFECTIVE";
   Atom_warning : constant String := "warning";
   Atom_CLAIM_AORTE : constant String := "CLAIM_AORTE";
   Atom_CLAIM_EFFECTS : constant String := "CLAIM_EFFECTS";
   Atom_CLAIM_POST : constant String := "CLAIM_POST";
   Atom_PROGRESS_PROOF : constant String := "PROGRESS_PROOF";
   Atom_STOP_REASON_NONE : constant String := "STOP_REASON_NONE";
   Atom_Silver_Arguments : constant String := "Silver_Arguments";
   Atom_Silver_Arguments_First_Or_Default : constant String := "Silver_Arguments.First_Or_Default";
   Atom_Silver_Arguments_Input_Is_Valid : constant String := "Silver_Arguments.Input_Is_Valid";
   Atom_Silver_Arguments_Is_Message : constant String := "Silver_Arguments.Is_Message";
   Atom_Silver_Arguments_Reject : constant String := "Silver_Arguments.Reject";
   Atom_Silver_IO : constant String := "Silver_IO";
   Atom_Silver_IO_Put_Line : constant String := "Silver_IO.Put_Line";
   Atom_Silver_Output_Libc : constant String := "Silver_Output_Libc";
   Atom_Silver_Output_Libc_Flush : constant String := "Silver_Output_Libc.Flush";
   Atom_Silver_Output_Libc_Put_Byte : constant String := "Silver_Output_Libc.Put_Byte";
   Atom_Silver_Output_Libc_Set_Exit_Status : constant String := "Silver_Output_Libc.Set_Exit_Status";
   Atom_Silver_Runtime : constant String := "Silver_Runtime";
   Atom_Silver_Runtime_Argument : constant String := "Silver_Runtime.Argument";
   Atom_Silver_Runtime_Argument_Count : constant String := "Silver_Runtime.Argument_Count";
   Atom_Silver_Runtime_Set_Exit_Status : constant String := "Silver_Runtime.Set_Exit_Status";
   Atom_VC_POSTCONDITION : constant String := "VC_POSTCONDITION";
   Atom_VC_RANGE_CHECK : constant String := "VC_RANGE_CHECK";
   Atom_all : constant String := "all";
   Atom_info : constant String := "info";
   Atom_main_adb : constant String := "main.adb";
   Atom_prover : constant String := "prover";
   Atom_silver_arguments_adb : constant String := "silver_arguments.adb";
   Atom_silver_arguments_ads : constant String := "silver_arguments.ads";
   Atom_silver_io_adb : constant String := "silver_io.adb";
   Atom_silver_io_ads : constant String := "silver_io.ads";
   Atom_silver_output_libc_ads : constant String := "silver_output_libc.ads";
   Atom_silver_runtime_ads : constant String := "silver_runtime.ads";
   Atom_spec : constant String := "spec";
   Atom_trivial : constant String := "trivial";

   --  Named byte strings give the specification and executable calls identical
   --  immutable key values, avoiding fresh array representations in proofs.
   JSON_sloc : constant String := "sloc";
   JSON_file : constant String := "file";
   JSON_name : constant String := "name";
   JSON_predicate : constant String := "predicate";
   JSON_arg : constant String := "arg";
   JSON_rule : constant String := "rule";
   JSON_message : constant String := "message";
   JSON_text : constant String := "text";
   JSON_entity : constant String := "entity";
   JSON_how_proved : constant String := "how_proved";
   JSON_severity : constant String := "severity";
   JSON_line : constant String := "line";
   JSON_col : constant String := "col";
   JSON_justification : constant String := "justification";
   JSON_justified : constant String := "justified";
   JSON_suppressed : constant String := "suppressed";
   JSON_annot_kind : constant String := "annot_kind";
   JSON_justif_msg : constant String := "justif_msg";
   JSON_claim : constant String := "claim";
   JSON_assumptions : constant String := "assumptions";
   JSON_entities : constant String := "entities";
   JSON_progress : constant String := "progress";
   JSON_stop_reason : constant String := "stop_reason";
   JSON_skip_flow_proof : constant String := "skip_flow_proof";
   JSON_skip_proof : constant String := "skip_proof";
   JSON_pragma_assume : constant String := "pragma_assume";
   JSON_warn_error : constant String := "warn_error";
   JSON_spark : constant String := "spark";
   JSON_flow : constant String := "flow";
   JSON_proof : constant String := "proof";

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

   --  Mathematical byte traversal. Static ghost definitions are erased at
   --  run time. The executable loops below refine these terminating recursive
   --  equations; report policy is specified separately from loop state.
   function Space_End (Text : String; Position : Offset) return Offset
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Position in 1 .. Text'Length + 1,
       Post => Space_End'Result in Position .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Space_End (Text : String; Position : Offset) return Offset is
     (if Position > Text'Length or else not Space (Text (Position))
      then Position else Space_End (Text, Position + 1));

   type Nesting is array (Positive range 1 .. 64) of Character;
   Empty_Nesting : constant Nesting := (others => ' ');
   subtype Nesting_Level is Natural range 0 .. 64;
   --  A fixed-size stack update is a shared data constructor, with its exact
   --  component semantics proved independently of the scanner transition.
   function Pushed (Stack : Nesting; Level : Positive; C : Character) return Nesting
     with Global => null, Pre => Level <= 64,
       Post => (Static => (for all I in Stack'Range =>
         Pushed'Result (I) = (if I = Level then C else Stack (I))))
   is
   begin
      return (Stack with delta Level => C);
   end Pushed;

   function Value_From
     (Text : String; Start, Position : Offset; Openers : Nesting;
      Level : Nesting_Level; Quoted, Escaped, Container : Boolean) return Offset
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Start in 1 .. Text'Length + 1
         and then Position in Start .. Text'Length + 1,
       Post => Value_From'Result = 0 or else
         Value_From'Result in Start .. Text'Length,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Value_From
     (Text : String; Start, Position : Offset; Openers : Nesting;
      Level : Nesting_Level; Quoted, Escaped, Container : Boolean) return Offset is
     (if Position > Text'Length then 0
      elsif Quoted then
        (if Escaped then
           Value_From (Text, Start, Position + 1, Openers, Level, True, False, Container)
         elsif Text (Position) = '\' then
           Value_From (Text, Start, Position + 1, Openers, Level, True, True, Container)
         elsif Text (Position) = '"' then
           (if not Container then Position
            else Value_From (Text, Start, Position + 1, Openers, Level, False, False, Container))
         else Value_From (Text, Start, Position + 1, Openers, Level, True, False, Container))
      elsif Text (Position) = '"' then
        Value_From (Text, Start, Position + 1, Openers, Level, True, Escaped, Container)
      elsif Text (Position) = '{' or else Text (Position) = '[' then
        (if Level = 64 then 0
         else Value_From (Text, Start, Position + 1,
                          Pushed (Openers, Level + 1, Text (Position)),
                          Level + 1, False, Escaped, Container))
      elsif Text (Position) = '}' or else Text (Position) = ']' then
        (if Level = 0 then
           (if Position > Start and then not Container then Position - 1 else 0)
         elsif (Text (Position) = '}' and then Openers (Level) /= '{')
           or else (Text (Position) = ']' and then Openers (Level) /= '[')
         then 0
         elsif Level = 1 then Position
         else Value_From (Text, Start, Position + 1, Openers, Level - 1,
                          False, Escaped, Container))
      elsif not Container and then
        (Text (Position) = ',' or else Space (Text (Position)))
      then (if Position > Start then Position - 1 else 0)
      else Value_From (Text, Start, Position + 1, Openers, Level, False, Escaped, Container));

   function Value_Spec (Text : String; Start : Offset) return Offset
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Start in 1 .. Text'Length + 1,
       Post => Value_Spec'Result = 0 or else
         Value_Spec'Result in Start .. Text'Length;

   function Value_Spec (Text : String; Start : Offset) return Offset is
     (Value_From (Text, Start, Start, Empty_Nesting, 0, False, False,
       Start <= Text'Length and then (Text (Start) = '{' or else Text (Start) = '[')));

   procedure Skip_Space (Text : String; Position : in out Offset)
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
       and then Position in 1 .. Text'Length + 1,
          Post => (Static => Position = Space_End (Text, Position'Old))
   is
   begin
      while Position <= Text'Length and then Space (Text (Position)) loop
         pragma Loop_Invariant (Position in Position'Loop_Entry .. Text'Length + 1);
         pragma Loop_Invariant
           (Static => Space_End (Text, Position'Loop_Entry) = Space_End (Text, Position));
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
          Post => (Static => Value_End'Result = Value_Spec (Text, Start))
   is
      Stack : Nesting := Empty_Nesting;
      Depth : Nesting_Level := 0;
      Quoted : Boolean := False;
      Escaped : Boolean := False;
      Container : constant Boolean := Start <= Text'Length
        and then (Text (Start) = '{' or else Text (Start) = '[');
   begin
      if Start > Text'Length then
         return 0;
      end if;
      for I in Start .. Text'Length loop
         pragma Loop_Invariant
           (Static => Value_Spec (Text, Start) =
             Value_From (Text, Start, I, Stack, Depth, Quoted, Escaped, Container));
         if Quoted then
            if Escaped then
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Stack, Depth, True, False, Container));
               Escaped := False;
            elsif Text (I) = '\' then
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Stack, Depth, True, True, Container));
               Escaped := True;
            elsif Text (I) = '"' then
               Quoted := False;
               if not Container then
                  return I;
               end if;
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Stack, Depth, False, False, Container));
            else
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Stack, Depth, True, False, Container));
            end if;
         elsif Text (I) = '"' then
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Stack, Depth, True, Escaped, Container));
            Quoted := True;
         elsif Text (I) = '{' or else Text (I) = '[' then
            if Depth = 64 then
               return 0;
            end if;
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Pushed (Stack, Depth + 1, Text (I)),
                     Depth + 1, False, Escaped, Container));
            Depth := Depth + 1;
            Stack := Pushed (Stack, Depth, Text (I));
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
            if Depth > 1 then
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Stack, Depth - 1, False, Escaped, Container));
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
         else
               pragma Assert
                 (Static => Value_Spec (Text, Start) =
                   Value_From (Text, Start, I + 1, Stack, Depth, False, Escaped, Container));
         end if;
         pragma Assert
           (Static => Value_Spec (Text, Start) =
             Value_From (Text, Start, I + 1, Stack, Depth, Quoted, Escaped, Container));
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

   type Member_State is (Broken, Finished, Present);
   type Member is record
      State : Member_State := Broken;
      Key : Span := Missing;
      Value : Span := Missing;
      Next : Offset := 0;
   end record;
   Bad_Member : constant Member := (Broken, Missing, Missing, 0);
   End_Member : constant Member := (Finished, Missing, Missing, 0);

   --  One immediate object member, specified by byte positions. The suffix
   --  position is after its separating comma, or at the closing brace.
   function Member_Spec (Text : String; Object : Span; Position : Offset)
     return Member
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Object)
         and then Position in Object.First + 1 .. Text'Length + 1,
       Post => (if Member_Spec'Result.State = Present then
         Valid (Text, Member_Spec'Result.Key)
         and then Valid (Text, Member_Spec'Result.Value)
         and then Member_Spec'Result.Next in Position + 1 .. Object.Last);

   function Member_Spec (Text : String; Object : Span; Position : Offset)
     return Member is
     (declare P : constant Offset := Space_End (Text, Position);
      begin
        (if P = Object.Last then End_Member
         elsif P >= Object.Last or else Text (P) /= '"' then Bad_Member
         else
           (declare K : constant Offset := Value_Spec (Text, P);
            begin
              (if K = 0 or else K >= Object.Last then Bad_Member
               else
                 (declare C : constant Offset := Space_End (Text, K + 1);
                  begin
                    (if C >= Object.Last or else Text (C) /= ':' then Bad_Member
                     else
                       (declare V : constant Offset := Space_End (Text, C + 1);
                                L : constant Offset := Value_Spec (Text, V);
                        begin
                          (if L = 0 or else L >= Object.Last then Bad_Member
                           else
                             (declare T : constant Offset := Space_End (Text, L + 1);
                              begin
                                (if T = Object.Last then (Present, (P, K), (V, L), T)
                                 elsif T >= Object.Last or else Text (T) /= ',' then Bad_Member
                                 else
                                   (declare N : constant Offset := Space_End (Text, T + 1);
                                    begin
                                      (if N >= Object.Last then Bad_Member
                                       else (Present, (P, K), (V, L), N)))))))))))));

   function Read_Member (Text : String; Object : Span; Position : Offset)
     return Member
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
       and then Valid (Text, Object)
       and then Position in Object.First + 1 .. Text'Length + 1,
       Post => (Static => Read_Member'Result = Member_Spec (Text, Object, Position))
   is
      P : Offset := Position;
      K, V, L, T : Offset;
   begin
      Skip_Space (Text, P);
      if P = Object.Last then return End_Member; end if;
      if P >= Object.Last or else Text (P) /= '"' then return Bad_Member; end if;
      K := Value_End (Text, P);
      if K = 0 or else K >= Object.Last then return Bad_Member; end if;
      V := K + 1;
      Skip_Space (Text, V);
      if V >= Object.Last or else Text (V) /= ':' then return Bad_Member; end if;
      V := V + 1;
      Skip_Space (Text, V);
      L := Value_End (Text, V);
      if L = 0 or else L >= Object.Last then return Bad_Member; end if;
      T := L + 1;
      Skip_Space (Text, T);
      if T = Object.Last then return (Present, (P, K), (V, L), T); end if;
      if T >= Object.Last or else Text (T) /= ',' then return Bad_Member; end if;
      T := T + 1;
      Skip_Space (Text, T);
      if T >= Object.Last then return Bad_Member; end if;
      return (Present, (P, K), (V, L), T);
   end Read_Member;

   function Item_Spec (Text : String; Items : Span; Position : Offset)
     return Member
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Post => (if Item_Spec'Result.State = Present then
         Valid (Text, Item_Spec'Result.Value)
         and then Item_Spec'Result.Next in Position + 1 .. Items.Last);

   function Item_Spec (Text : String; Items : Span; Position : Offset)
     return Member is
     (declare P : constant Offset := Space_End (Text, Position);
      begin
        (if P = Items.Last then End_Member
         elsif P >= Items.Last or else Text (P) /= '{' then Bad_Member
         else
           (declare L : constant Offset := Value_Spec (Text, P);
            begin
              (if L = 0 or else L >= Items.Last then Bad_Member
               else
                 (declare T : constant Offset := Space_End (Text, L + 1);
                  begin
                    (if T = Items.Last then (Present, Missing, (P, L), T)
                     elsif T >= Items.Last or else Text (T) /= ',' then Bad_Member
                     else
                       (declare N : constant Offset := Space_End (Text, T + 1);
                        begin
                          (if N >= Items.Last then Bad_Member
                           else (Present, Missing, (P, L), N)))))))));

   function Read_Item (Text : String; Items : Span; Position : Offset)
     return Member
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
       and then Valid (Text, Items)
       and then Position in Items.First + 1 .. Text'Length + 1,
       Post => (Static => Read_Item'Result = Item_Spec (Text, Items, Position))
   is
      P : Offset := Position;
      L, T : Offset;
   begin
      Skip_Space (Text, P);
      if P = Items.Last then return End_Member; end if;
      if P >= Items.Last or else Text (P) /= '{' then return Bad_Member; end if;
      L := Value_End (Text, P);
      if L = 0 or else L >= Items.Last then return Bad_Member; end if;
      T := L + 1;
      Skip_Space (Text, T);
      if T = Items.Last then return (Present, Missing, (P, L), T); end if;
      if T >= Items.Last or else Text (T) /= ',' then return Bad_Member; end if;
      T := T + 1;
      Skip_Space (Text, T);
      if T >= Items.Last then return Bad_Member; end if;
      return (Present, Missing, (P, L), T);
   end Read_Item;

   function Merge_Field (Left, Right : Span) return Span is
     (if Left = Malformed or else Right = Malformed then Malformed
      elsif Left = Missing then Right
      elsif Right = Missing then Left else Malformed);

   function Field_From (Text : String; Object : Span; Name : String; Position : Offset)
     return Span
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Object)
         and then Position in Object.First + 1 .. Text'Length + 1,
       Post => Field_From'Result = Missing or else Field_From'Result = Malformed
         or else Valid (Text, Field_From'Result),
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Field_From (Text : String; Object : Span; Name : String; Position : Offset)
     return Span is
     (declare M : constant Member := Member_Spec (Text, Object, Position);
      begin
        (case M.State is
           when Broken => Malformed,
           when Finished => Missing,
           when Present => Merge_Field
             ((if String_Equal (Text, M.Key, Name) then M.Value else Missing),
              Field_From (Text, Object, Name, M.Next))));

   function Field_Spec (Text : String; Object : Span; Name : String) return Span
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => Field_Spec'Result = Missing or else Field_Spec'Result = Malformed
         or else Valid (Text, Field_Spec'Result);

   function Field_Spec (Text : String; Object : Span; Name : String) return Span is
     (if not Valid (Text, Object) or else Text (Object.First) /= '{'
        or else Text (Object.Last) /= '}' then Malformed
      else Field_From (Text, Object, Name, Object.First + 1));

   --  Unique immediate-member lookup refines the recursive byte relation.
   function Field (Text : String; Object : Span; Name : String) return Span
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Field'Result = Field_Spec (Text, Object, Name))
   is
      P : Offset;
      M : Member;
      Result : Span := Missing;
   begin
      if not Valid (Text, Object) or else Text (Object.First) /= '{'
        or else Text (Object.Last) /= '}'
      then return Malformed; end if;
      P := Object.First + 1;
      loop
         pragma Loop_Invariant (P in Object.First + 1 .. Text'Length + 1);
         pragma Loop_Invariant (Result = Missing or else Valid (Text, Result));
         pragma Loop_Invariant
           (Static => Field_Spec (Text, Object, Name) =
             Merge_Field (Result, Field_From (Text, Object, Name, P)));
         pragma Loop_Variant (Increases => P);
         M := Read_Member (Text, Object, P);
         case M.State is
            when Broken => return Malformed;
            when Finished => return Result;
            when Present =>
               if String_Equal (Text, M.Key, Name) then
                  if Result /= Missing then return Malformed; end if;
                  Result := M.Value;
               end if;
               P := M.Next;
         end case;
      end loop;
   end Field;

   function Empty_Array_Spec (Text : String; Item : Span) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Empty_Array_Spec (Text : String; Item : Span) return Boolean is
     (Valid (Text, Item) and then Text (Item.First) = '['
      and then Text (Item.Last) = ']'
      and then Space_End (Text, Item.First + 1) = Item.Last);

   function Empty_Array (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Empty_Array'Result = Empty_Array_Spec (Text, Item))
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
                       Runtime_Package, Argument_Count, Argument, Runtime_Exit_Status, Main_Entity);
   function Entity_File (Name : Entity_Kind) return String is
     (case Name is
        when IO_Package | Put_Line => Atom_silver_io_ads,
        when Libc_Package | Put_Byte | Flush | Set_Exit_Status => Atom_silver_output_libc_ads,
        when Arguments_Package | Input_Is_Valid | First_Or_Default | Reject => Atom_silver_arguments_ads,
        when Is_Message => Atom_silver_arguments_adb,
        when Runtime_Package | Argument_Count | Argument | Runtime_Exit_Status => Atom_silver_runtime_ads,
        when Main_Entity => Atom_main_adb,
        when Unknown => Atom_Empty);

   function Location_Policy (Text : String; Entity : Span; Name : Entity_Kind) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Location_Policy (Text : String; Entity : Span; Name : Entity_Kind) return Boolean is
     (Name /= Unknown and then
       (declare Locations : constant Span := Field_Spec (Text, Entity, JSON_sloc);
        begin
          Valid (Text, Locations) and then Text (Locations.First) = '['
            and then Text (Locations.Last) = ']'
            and then
              (declare P : constant Offset := Space_End (Text, Locations.First + 1);
                       L : constant Offset := Value_Spec (Text, P);
               begin L /= 0 and then L < Locations.Last
                 and then Space_End (Text, L + 1) = Locations.Last
                 and then String_Equal
                   (Text, Field_Spec (Text, (P, L), JSON_file), Entity_File (Name)))));

   function Location_OK (Text : String; Entity : Span; Name : Entity_Kind)
     return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Location_OK'Result = Location_Policy (Text, Entity, Name))
   is
      Locations : constant Span := Field (Text, Entity, JSON_sloc);
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
      File := Field (Text, (P, Last), JSON_file);
      P := Last + 1;
      Skip_Space (Text, P);
      if P /= Locations.Last then return False; end if;
      return Name /= Unknown
        and then String_Equal (Text, File, Entity_File (Name));
   end Location_OK;

   --  GNAT reports preserve the source spelling of the admitted entry-point
   --  identifier. Ada's ASCII case equivalence applies to exactly this name;
   --  selected runtime declarations retain their pinned source spellings.
   function Main_Spelling (Text : String; Name : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Main_Spelling (Text : String; Name : Span) return Boolean is
     (Valid (Text, Name) and then Name.Last - Name.First = 5
      and then Text (Name.First) = '"' and then Text (Name.Last) = '"'
      and then Text (Name.First + 1) in 'm' | 'M'
      and then Text (Name.First + 2) in 'a' | 'A'
      and then Text (Name.First + 3) in 'i' | 'I'
      and then Text (Name.First + 4) in 'n' | 'N');

   function Entity_Name_Spec (Text : String; Entity : Span) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Entity_Name_Spec (Text : String; Entity : Span) return Entity_Kind is
     (declare Name : constant Span := Field_Spec (Text, Entity, JSON_name);
              Kind : constant Entity_Kind := (
          if Main_Spelling (Text, Name) then Main_Entity
          elsif String_Equal (Text, Name, Atom_Silver_IO) then IO_Package
          elsif String_Equal (Text, Name, Atom_Silver_IO_Put_Line) then Put_Line
          elsif String_Equal (Text, Name, Atom_Silver_Output_Libc) then Libc_Package
          elsif String_Equal (Text, Name, Atom_Silver_Output_Libc_Put_Byte) then Put_Byte
          elsif String_Equal (Text, Name, Atom_Silver_Output_Libc_Flush) then Flush
          elsif String_Equal (Text, Name, Atom_Silver_Output_Libc_Set_Exit_Status) then Set_Exit_Status
          elsif String_Equal (Text, Name, Atom_Silver_Arguments) then Arguments_Package
          elsif String_Equal (Text, Name, Atom_Silver_Arguments_Input_Is_Valid) then Input_Is_Valid
          elsif String_Equal (Text, Name, Atom_Silver_Arguments_First_Or_Default) then First_Or_Default
          elsif String_Equal (Text, Name, Atom_Silver_Arguments_Reject) then Reject
          elsif String_Equal (Text, Name, Atom_Silver_Arguments_Is_Message) then Is_Message
          elsif String_Equal (Text, Name, Atom_Silver_Runtime) then Runtime_Package
          elsif String_Equal (Text, Name, Atom_Silver_Runtime_Argument_Count) then Argument_Count
          elsif String_Equal (Text, Name, Atom_Silver_Runtime_Argument) then Argument
          elsif String_Equal (Text, Name, Atom_Silver_Runtime_Set_Exit_Status) then Runtime_Exit_Status
          else Unknown);
      begin (if Location_Policy (Text, Entity, Kind) then Kind else Unknown));

   function Entity_Name (Text : String; Entity : Span) return Entity_Kind
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Entity_Name'Result = Entity_Name_Spec (Text, Entity))
   is
      Name : constant Span := Field (Text, Entity, JSON_name);
      Result : Entity_Kind := Unknown;
   begin
      if Main_Spelling (Text, Name) then Result := Main_Entity;
      elsif String_Equal (Text, Name, Atom_Silver_IO) then Result := IO_Package;
      elsif String_Equal (Text, Name, Atom_Silver_IO_Put_Line) then Result := Put_Line;
      elsif String_Equal (Text, Name, Atom_Silver_Output_Libc) then Result := Libc_Package;
      elsif String_Equal (Text, Name, Atom_Silver_Output_Libc_Put_Byte) then Result := Put_Byte;
      elsif String_Equal (Text, Name, Atom_Silver_Output_Libc_Flush) then Result := Flush;
      elsif String_Equal (Text, Name, Atom_Silver_Output_Libc_Set_Exit_Status) then Result := Set_Exit_Status;
      elsif String_Equal (Text, Name, Atom_Silver_Arguments) then Result := Arguments_Package;
      elsif String_Equal (Text, Name, Atom_Silver_Arguments_Input_Is_Valid) then Result := Input_Is_Valid;
      elsif String_Equal (Text, Name, Atom_Silver_Arguments_First_Or_Default) then Result := First_Or_Default;
      elsif String_Equal (Text, Name, Atom_Silver_Arguments_Reject) then Result := Reject;
      elsif String_Equal (Text, Name, Atom_Silver_Arguments_Is_Message) then Result := Is_Message;
      elsif String_Equal (Text, Name, Atom_Silver_Runtime) then Result := Runtime_Package;
      elsif String_Equal (Text, Name, Atom_Silver_Runtime_Argument_Count) then Result := Argument_Count;
      elsif String_Equal (Text, Name, Atom_Silver_Runtime_Argument) then Result := Argument;
      elsif String_Equal (Text, Name, Atom_Silver_Runtime_Set_Exit_Status) then Result := Runtime_Exit_Status;
      end if;
      if not Location_OK (Text, Entity, Result) then return Unknown; end if;
      return Result;
   end Entity_Name;

   function Positive_Number (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Positive_Number (Text : String; Item : Span) return Boolean is
     (Valid (Text, Item)
      and then (for all I in Item.First .. Item.Last => Text (I) in '0' .. '9')
      and then (for some I in Item.First .. Item.Last => Text (I) /= '0'));

   function Nonempty_String (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Nonempty_String (Text : String; Item : Span) return Boolean is
     (Valid (Text, Item) and then Item.Last - Item.First > 1
      and then Text (Item.First) = '"' and then Text (Item.Last) = '"');

   function Padded_Key (Text : String; Arg : Span) return String
     with Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Arg),
       Post => (Static => Padded_Key'Result'First = 1
         and then Padded_Key'Result'Length = (Arg.Last - Arg.First) + 2
         and then Padded_Key'Result (1) = ' '
         and then (for all I in Arg.First .. Arg.Last =>
           Padded_Key'Result ((I - Arg.First) + 2) = Text (I)))
   is
   begin
      return " " & Text (Arg.First .. Arg.Last);
   end Padded_Key;

   function Referenced_Entity_Spec (Text : String; Entities, Arg : Span) return Span
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Referenced_Entity_Spec (Text : String; Entities, Arg : Span) return Span is
     (if not Valid (Text, Arg)
        or else not (for all I in Arg.First .. Arg.Last => Text (I) in '0' .. '9')
      then Missing
      else
        (declare Number : constant String := Text (Arg.First .. Arg.Last);
                 Padded : constant Span := Field_Spec (Text, Entities, Padded_Key (Text, Arg));
         begin (if Padded = Missing then Field_Spec (Text, Entities, Number) else Padded)));

   function Referenced_Entity (Text : String; Entities, Arg : Span) return Span
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Referenced_Entity'Result = Referenced_Entity_Spec (Text, Entities, Arg))
   is
   begin
      if not Valid (Text, Arg) then return Missing; end if;
      if not (for all I in Arg.First .. Arg.Last => Text (I) in '0' .. '9')
      then return Missing; end if;
      declare
         Number : constant String := Text (Arg.First .. Arg.Last);
         Entity : constant Span := Field (Text, Entities, Padded_Key (Text, Arg));
      begin
         if Entity /= Missing then return Entity; end if;
         return Field (Text, Entities, Number);
      end;
   end Referenced_Entity;

   function Reference_Policy (Text : String; Entities, Reference : Span) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Reference_Policy (Text : String; Entities, Reference : Span) return Boolean is
     ((String_Equal (Text, Field_Spec (Text, Reference, JSON_predicate), Atom_CLAIM_POST)
       or else String_Equal (Text, Field_Spec (Text, Reference, JSON_predicate), Atom_CLAIM_AORTE)
       or else String_Equal (Text, Field_Spec (Text, Reference, JSON_predicate), Atom_CLAIM_EFFECTS))
      and then Entity_Name_Spec (Text, Referenced_Entity_Spec
        (Text, Entities, Field_Spec (Text, Reference, JSON_arg))) /= Unknown);

   function Reference_OK (Text : String; Entities, Reference : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Reference_OK'Result = Reference_Policy (Text, Entities, Reference))
   is
      Predicate : constant Span := Field (Text, Reference, JSON_predicate);
      Entity : constant Span := Referenced_Entity
        (Text, Entities, Field (Text, Reference, JSON_arg));
   begin
      return (String_Equal (Text, Predicate, Atom_CLAIM_POST)
              or else String_Equal (Text, Predicate, Atom_CLAIM_AORTE)
              or else String_Equal (Text, Predicate, Atom_CLAIM_EFFECTS))
        and then Entity_Name (Text, Entity) /= Unknown;
   end Reference_OK;

   --  This advisory describes a deliberately overwritten initializer, not a
   --  failed safety obligation. Its exact GNAT message contains one Ada name.
   function Initializer_Message (Text : String; Item : Span) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Initializer_Message (Text : String; Item : Span) return Boolean is
     (declare Prefix : constant String := """initialization of \""";
              Suffix : constant String := "\"" has no effect""";
      begin Valid (Text, Item)
        and then (Item.Last - Item.First) + 1 > Prefix'Length + Suffix'Length
        and then (Item.Last - Item.First) + 1 <= Prefix'Length + Suffix'Length + 4_096
        and then Text (Item.First .. (Item.First + Prefix'Length) - 1) = Prefix
        and then Text ((Item.Last - Suffix'Length) + 1 .. Item.Last) = Suffix
        and then Text (Item.First + Prefix'Length) in 'A' .. 'Z' | 'a' .. 'z'
        and then Text (Item.Last - Suffix'Length) /= '_'
        and then (for all I in Item.First + Prefix'Length .. Item.Last - Suffix'Length =>
          Text (I) in 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '_'
          and then (if Text (I) = '_' then Text (I - 1) /= '_')));

   type List_Kind is (Checks, Main_Checks, Assignment_Diagnostics, References, Postconditions, Argument_Postconditions);
   function Record_Policy (Text : String; Item, Entities : Span; Kind : List_Kind)
     return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Record_Policy (Text : String; Item, Entities : Span; Kind : List_Kind)
     return Boolean is
     (if Kind = References then Reference_Policy (Text, Entities, Item)
      elsif Kind = Assignment_Diagnostics then
        String_Equal (Text, Field_Spec (Text, Item, JSON_severity), Atom_warning)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_INEFFECTIVE)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_line))
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_col))
        and then Entity_Name_Spec (Text, Referenced_Entity_Spec
          (Text, Entities, Field_Spec (Text, Item, JSON_entity))) = Main_Entity
        and then Initializer_Message (Text, Field_Spec
          (Text, Field_Spec (Text, Item, JSON_message), JSON_text))
        and then Field_Spec (Text, Item, JSON_justification) = Missing
        and then Field_Spec (Text, Item, JSON_justified) = Missing
        and then Field_Spec (Text, Item, JSON_suppressed) = Missing
        and then Field_Spec (Text, Item, JSON_annot_kind) = Missing
        and then Field_Spec (Text, Item, JSON_justif_msg) = Missing
      elsif Kind in Postconditions | Argument_Postconditions then
        String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_POSTCONDITION)
        and then Entity_Name_Spec (Text, Referenced_Entity_Spec
          (Text, Entities, Field_Spec (Text, Item, JSON_entity))) =
            (if Kind = Postconditions then Put_Line else First_Or_Default)
      else
        String_Equal (Text, Field_Spec (Text, Item, JSON_severity), Atom_info)
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_line))
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_col))
        and then Field_Spec (Text, Item, JSON_justification) = Missing
        and then Field_Spec (Text, Item, JSON_justified) = Missing
        and then Field_Spec (Text, Item, JSON_suppressed) = Missing
        and then Field_Spec (Text, Item, JSON_annot_kind) = Missing
        and then Field_Spec (Text, Item, JSON_justif_msg) = Missing
        and then
          (if Kind = Main_Checks then
             String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), Atom_prover)
             and then String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_RANGE_CHECK)
             and then String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_main_adb)
             and then Entity_Name_Spec (Text, Referenced_Entity_Spec
               (Text, Entities, Field_Spec (Text, Item, JSON_entity))) = Main_Entity
           else
             (String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), JSON_flow)
              or else String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), Atom_prover)
              or else String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), Atom_trivial))
             and then Nonempty_String (Text, Field_Spec (Text, Item, JSON_rule))
             and then (String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_silver_io_ads)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_silver_io_adb)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_silver_output_libc_ads)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_silver_arguments_ads)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_silver_arguments_adb)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_silver_runtime_ads))
             and then Entity_Name_Spec (Text, Referenced_Entity_Spec
               (Text, Entities, Field_Spec (Text, Item, JSON_entity))) /= Unknown));

   function Record_OK
     (Text : String; Item, Entities : Span; Kind : List_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Record_OK'Result = Record_Policy (Text, Item, Entities, Kind))
   is
      How : Span;
   begin
      if Kind = References then return Reference_OK (Text, Entities, Item); end if;
      if Kind = Assignment_Diagnostics then
         return
        String_Equal (Text, Field (Text, Item, JSON_severity), Atom_warning)
        and then String_Equal (Text, Field (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field (Text, Item, JSON_rule), Atom_INEFFECTIVE)
        and then String_Equal (Text, Field (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field (Text, Item, JSON_line))
        and then Positive_Number (Text, Field (Text, Item, JSON_col))
        and then Entity_Name (Text, Referenced_Entity
          (Text, Entities, Field (Text, Item, JSON_entity))) = Main_Entity
        and then Initializer_Message (Text, Field
          (Text, Field (Text, Item, JSON_message), JSON_text))
        and then Field (Text, Item, JSON_justification) = Missing
        and then Field (Text, Item, JSON_justified) = Missing
        and then Field (Text, Item, JSON_suppressed) = Missing
        and then Field (Text, Item, JSON_annot_kind) = Missing
        and then Field (Text, Item, JSON_justif_msg) = Missing;
      end if;

      if Kind in Postconditions | Argument_Postconditions then
         return String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_POSTCONDITION)
           and then Entity_Name (Text, Referenced_Entity
             (Text, Entities, Field (Text, Item, JSON_entity)))
                = (if Kind = Postconditions then Put_Line else First_Or_Default);
      end if;
      How := Field (Text, Item, JSON_how_proved);
      if Kind = Main_Checks then
         return String_Equal (Text, Field (Text, Item, JSON_severity), Atom_info)
           and then String_Equal (Text, How, Atom_prover)
           and then String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_RANGE_CHECK)
           and then String_Equal (Text, Field (Text, Item, JSON_file), Atom_main_adb)
           and then Positive_Number (Text, Field (Text, Item, JSON_line))
           and then Positive_Number (Text, Field (Text, Item, JSON_col))
           and then Entity_Name (Text, Referenced_Entity
             (Text, Entities, Field (Text, Item, JSON_entity))) = Main_Entity
           and then Field (Text, Item, JSON_justification) = Missing
           and then Field (Text, Item, JSON_justified) = Missing
           and then Field (Text, Item, JSON_suppressed) = Missing
           and then Field (Text, Item, JSON_annot_kind) = Missing
           and then Field (Text, Item, JSON_justif_msg) = Missing;
      end if;
      return String_Equal (Text, Field (Text, Item, JSON_severity), Atom_info)
        and then (String_Equal (Text, How, JSON_flow)
          or else String_Equal (Text, How, Atom_prover)
          or else String_Equal (Text, How, Atom_trivial))
        and then Field (Text, Item, JSON_justification) = Missing
        and then Field (Text, Item, JSON_justified) = Missing
        and then Field (Text, Item, JSON_suppressed) = Missing
        and then Field (Text, Item, JSON_annot_kind) = Missing
        and then Field (Text, Item, JSON_justif_msg) = Missing
        and then Nonempty_String (Text, Field (Text, Item, JSON_rule))
        and then (String_Equal (Text, Field (Text, Item, JSON_file), Atom_silver_io_ads)
          or else String_Equal (Text, Field (Text, Item, JSON_file), Atom_silver_io_adb)
          or else String_Equal (Text, Field (Text, Item, JSON_file), Atom_silver_output_libc_ads)
          or else String_Equal (Text, Field (Text, Item, JSON_file), Atom_silver_arguments_ads)
          or else String_Equal (Text, Field (Text, Item, JSON_file), Atom_silver_arguments_adb)
          or else String_Equal (Text, Field (Text, Item, JSON_file), Atom_silver_runtime_ads))
        and then Positive_Number (Text, Field (Text, Item, JSON_line))
        and then Positive_Number (Text, Field (Text, Item, JSON_col))
        and then Entity_Name (Text, Referenced_Entity
          (Text, Entities, Field (Text, Item, JSON_entity))) /= Unknown;
   end Record_OK;

   function Assignment_Flow_Spec (Text : String; Items, Entities : Span) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Assignment_Flow_Spec (Text : String; Items, Entities : Span) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '[' and then Text (Items.Last) = ']'
      and then (declare M : constant Member := Item_Spec (Text, Items, Items.First + 1);
                begin M.State = Finished or else
                  (M.State = Present
                   and then Record_Policy (Text, M.Value, Entities, Assignment_Diagnostics)
                   and then Item_Spec (Text, Items, M.Next).State = Finished)));

   function Assignment_Flow_OK (Text : String; Items, Entities : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Assignment_Flow_OK'Result = Assignment_Flow_Spec (Text, Items, Entities))
   is
      M : Member;
   begin
      if not Valid (Text, Items) or else Text (Items.First) /= '[' or else Text (Items.Last) /= ']'
      then return False; end if;
      M := Read_Item (Text, Items, Items.First + 1);
      return M.State = Finished or else
        (M.State = Present
         and then Record_OK (Text, M.Value, Entities, Assignment_Diagnostics)
         and then Read_Item (Text, Items, M.Next).State = Finished);
   end Assignment_Flow_OK;

   type List_Summary is record
      Well_Formed : Boolean;
      Every_OK : Boolean;
      Has_OK : Boolean;
   end record;

   function List_From
     (Text : String; Items, Entities : Span; Kind : List_Kind; Position : Offset)
     return List_Summary
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function List_From
     (Text : String; Items, Entities : Span; Kind : List_Kind; Position : Offset)
     return List_Summary is
     (declare M : constant Member := Item_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Broken => (False, False, False),
           when Finished => (True, True, False),
           when Present =>
             (declare Rest : constant List_Summary :=
                 List_From (Text, Items, Entities, Kind, M.Next);
                      Good : constant Boolean := Record_Policy (Text, M.Value, Entities, Kind);
              begin (Rest.Well_Formed, Good and Rest.Every_OK, Good or Rest.Has_OK))));

   function List_Policy (Summary : List_Summary; Kind : List_Kind;
                         Found : Boolean := False) return Boolean
     with Ghost => Static, Global => null;

   function List_Policy (Summary : List_Summary; Kind : List_Kind;
                         Found : Boolean := False) return Boolean is
     (Summary.Well_Formed and then
        (if Kind in Postconditions | Argument_Postconditions
         then Found or Summary.Has_OK else Summary.Every_OK));

   function List_Spec
     (Text : String; Items, Entities : Span; Kind : List_Kind) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function List_Spec
     (Text : String; Items, Entities : Span; Kind : List_Kind) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '['
        and then Text (Items.Last) = ']'
        and then List_Policy (List_From (Text, Items, Entities, Kind, Items.First + 1), Kind));

   function List_OK
     (Text : String; Items, Entities : Span; Kind : List_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => List_OK'Result = List_Spec (Text, Items, Entities, Kind))
   is
      P : Offset;
      M : Member;
      Found : Boolean := False;
   begin
      if not Valid (Text, Items) or else Text (Items.First) /= '['
        or else Text (Items.Last) /= ']'
      then return False; end if;
      P := Items.First + 1;
      loop
         pragma Loop_Invariant (P in Items.First + 1 .. Text'Length + 1);
         pragma Loop_Invariant
           (Static => List_Spec (Text, Items, Entities, Kind) =
             List_Policy (List_From (Text, Items, Entities, Kind, P), Kind, Found));
         pragma Loop_Variant (Increases => P);
         M := Read_Item (Text, Items, P);
         case M.State is
            when Broken => return False;
            when Finished =>
               return Kind not in Postconditions | Argument_Postconditions or else Found;
            when Present =>
               if Kind in Postconditions | Argument_Postconditions then
                  Found := Found or else Record_OK (Text, M.Value, Entities, Kind);
               elsif not Record_OK (Text, M.Value, Entities, Kind) then
                  return False;
               end if;
               P := M.Next;
         end case;
      end loop;
   end List_OK;

   function Dependencies_From
     (Text : String; Items, Entities : Span; Position : Offset) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Dependencies_From
     (Text : String; Items, Entities : Span; Position : Offset) return Boolean is
     (declare M : constant Member := Item_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Broken => False,
           when Finished => True,
           when Present =>
             Reference_Policy (Text, Entities, Field_Spec (Text, M.Value, JSON_claim))
             and then List_Spec
               (Text, Field_Spec (Text, M.Value, JSON_assumptions), Entities, References)
             and then Dependencies_From (Text, Items, Entities, M.Next)));

   function Dependencies_Spec (Text : String; Items, Entities : Span) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Dependencies_Spec (Text : String; Items, Entities : Span) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '['
      and then Text (Items.Last) = ']'
      and then Dependencies_From (Text, Items, Entities, Items.First + 1));

   function Dependencies_OK
     (Text : String; Items, Entities : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Dependencies_OK'Result = Dependencies_Spec (Text, Items, Entities))
   is
      P : Offset;
      M : Member;
   begin
      if not Valid (Text, Items) or else Text (Items.First) /= '['
        or else Text (Items.Last) /= ']'
      then return False; end if;
      P := Items.First + 1;
      loop
         pragma Loop_Invariant (P in Items.First + 1 .. Text'Length + 1);
         pragma Loop_Invariant
           (Static => Dependencies_Spec (Text, Items, Entities) =
             Dependencies_From (Text, Items, Entities, P));
         pragma Loop_Variant (Increases => P);
         M := Read_Item (Text, Items, P);
         case M.State is
            when Broken => return False;
            when Finished => return True;
            when Present =>
               if not Reference_OK (Text, Entities, Field (Text, M.Value, JSON_claim))
                 or else not List_OK
                   (Text, Field (Text, M.Value, JSON_assumptions), Entities, References)
               then return False; end if;
               P := M.Next;
         end case;
      end loop;
   end Dependencies_OK;

   --  When the advisory is absent GNAT retains the ordinary call-effects
   --  dependency: Main relies only on the selected Put_Line effect contract.
   function Assignment_Effects_Spec (Text : String; Items, Entities : Span) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Assignment_Effects_Spec (Text : String; Items, Entities : Span) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '[' and then Text (Items.Last) = ']'
      and then (declare M : constant Member := Item_Spec (Text, Items, Items.First + 1);
                begin M.State = Present
                  and then Item_Spec (Text, Items, M.Next).State = Finished
                  and then String_Equal (Text, Field_Spec
                    (Text, Field_Spec (Text, M.Value, JSON_claim), JSON_predicate), Atom_CLAIM_EFFECTS)
                  and then Entity_Name_Spec (Text, Referenced_Entity_Spec
                    (Text, Entities, Field_Spec
                      (Text, Field_Spec (Text, M.Value, JSON_claim), JSON_arg))) = Main_Entity
                  and then (declare Assumptions : constant Span :=
                      Field_Spec (Text, M.Value, JSON_assumptions);
                    begin Valid (Text, Assumptions)
                      and then Text (Assumptions.First) = '[' and then Text (Assumptions.Last) = ']'
                      and then (declare A : constant Member :=
                          Item_Spec (Text, Assumptions, Assumptions.First + 1);
                        begin A.State = Present
                          and then Item_Spec (Text, Assumptions, A.Next).State = Finished
                          and then String_Equal
                            (Text, Field_Spec (Text, A.Value, JSON_predicate), Atom_CLAIM_EFFECTS)
                          and then Entity_Name_Spec (Text, Referenced_Entity_Spec
                            (Text, Entities, Field_Spec (Text, A.Value, JSON_arg))) = Put_Line))));

   function Assignment_Effects_OK (Text : String; Items, Entities : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Assignment_Effects_OK'Result = Assignment_Effects_Spec (Text, Items, Entities))
   is
      M, A : Member;
      Assumptions : Span;
   begin
      if not Valid (Text, Items) or else Text (Items.First) /= '[' or else Text (Items.Last) /= ']'
      then return False; end if;
      M := Read_Item (Text, Items, Items.First + 1);
      if M.State /= Present or else Read_Item (Text, Items, M.Next).State /= Finished
      then return False; end if;
      if not String_Equal (Text, Field
           (Text, Field (Text, M.Value, JSON_claim), JSON_predicate), Atom_CLAIM_EFFECTS)
        or else Entity_Name (Text, Referenced_Entity
          (Text, Entities, Field (Text, Field (Text, M.Value, JSON_claim), JSON_arg))) /= Main_Entity
      then return False; end if;
      Assumptions := Field (Text, M.Value, JSON_assumptions);
      if not Valid (Text, Assumptions)
        or else Text (Assumptions.First) /= '[' or else Text (Assumptions.Last) /= ']'
      then return False; end if;
      A := Read_Item (Text, Assumptions, Assumptions.First + 1);
      return A.State = Present
        and then Read_Item (Text, Assumptions, A.Next).State = Finished
        and then String_Equal (Text, Field (Text, A.Value, JSON_predicate), Atom_CLAIM_EFFECTS)
        and then Entity_Name (Text, Referenced_Entity
          (Text, Entities, Field (Text, A.Value, JSON_arg))) = Put_Line;
   end Assignment_Effects_OK;

   function Expected_Entity (Name : Entity_Kind; Kind : Audit_Kind)
     return Boolean is
     (case Kind is
        when IO_Body => Name in IO_Package | Put_Line | Put_Byte | Flush | Set_Exit_Status,
        when Libc_Interface => Name in Libc_Package | Put_Byte | Flush | Set_Exit_Status,
        when Argument_Body => Name in Arguments_Package | Input_Is_Valid | First_Or_Default
          | Reject | Is_Message | Set_Exit_Status | Argument_Count | Argument,
        when Argv_Interface => Name in Runtime_Package | Argument_Count | Argument | Runtime_Exit_Status,
        when Main_Body => Name in Main_Entity | First_Or_Default | Input_Is_Valid | Reject | Put_Line,
        when Assignment_Main => Name = Main_Entity,
        when Assignment_Effects => Name in Main_Entity | Put_Line);

   function Expected_Coverage (Name : Entity_Kind; Kind : Audit_Kind)
     return String is
     (case Kind is
        when IO_Body => (if Name in IO_Package | Put_Line then Atom_all else Atom_Empty),
        when Libc_Interface =>
          (if Name = Libc_Package then Atom_all
           elsif Name in Put_Byte | Flush | Set_Exit_Status then Atom_spec else Atom_Empty),
        when Argument_Body =>
          (if Name in Arguments_Package | Input_Is_Valid | First_Or_Default | Reject | Is_Message
           then Atom_all else Atom_Empty),
        when Argv_Interface =>
          (if Name = Runtime_Package then Atom_all
           elsif Name in Argument_Count | Argument | Runtime_Exit_Status then Atom_spec else Atom_Empty),
        when Main_Body | Assignment_Main | Assignment_Effects => (if Name = Main_Entity then Atom_all else Atom_Empty));

   type Entity_Set is array (Entity_Kind) of Boolean;
   function Remember (Seen : Entity_Set; Name : Entity_Kind) return Entity_Set
     with Global => null,
       Post => (Static => (for all N in Entity_Kind =>
         Remember'Result (N) = (N = Name or Seen (N))))
   is
   begin
      return (Seen with delta Name => True);
   end Remember;

   No_Entities : constant Entity_Set := (others => False);
   type Entity_Summary is record
      Well_Formed : Boolean;
      Unique : Boolean;
      Seen : Entity_Set;
   end record;

   function Map_Name (Text : String; Items, Entities : Span; M : Member;
                      Kind : Audit_Kind; Coverage : Boolean) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then M.State = Present and then Valid (Text, M.Key)
         and then Valid (Text, M.Value);

   function Map_Name (Text : String; Items, Entities : Span; M : Member;
                      Kind : Audit_Kind; Coverage : Boolean) return Entity_Kind is
     (if M.Key.Last - M.Key.First < 1 then Unknown
      elsif Coverage then
        (declare Name : constant Entity_Kind := Entity_Name_Spec
            (Text, Field_Spec (Text, Entities, Text (M.Key.First + 1 .. M.Key.Last - 1)));
         begin
           (if Expected_Coverage (Name, Kind)'Length = 0
              or else not String_Equal (Text, M.Value, Expected_Coverage (Name, Kind))
            then Unknown else Name))
      elsif Field_Spec (Text, Items, Text (M.Key.First + 1 .. M.Key.Last - 1)) /= M.Value
      then Unknown
      else Entity_Name_Spec (Text, M.Value));

   function Map_From (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean; Position : Offset)
     return Entity_Summary
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Map_From (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean; Position : Offset)
     return Entity_Summary is
     (declare M : constant Member := Member_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Broken => (False, False, No_Entities),
           when Finished => (True, True, No_Entities),
           when Present =>
             (declare Name : constant Entity_Kind := Map_Name (Text, Items, Entities, M, Kind, Coverage);
                      Rest : constant Entity_Summary := Map_From (Text, Items, Entities, Kind, Coverage, M.Next);
              begin
                (Rest.Well_Formed and Name /= Unknown,
                 Rest.Unique and not Rest.Seen (Name),
                 Remember (Rest.Seen, Name)))));

   function Map_Policy (Prefix : Entity_Set; Suffix : Entity_Summary;
                        Kind : Audit_Kind; Coverage : Boolean) return Boolean
     with Ghost => Static, Global => null;

   function Map_Policy (Prefix : Entity_Set; Suffix : Entity_Summary;
                        Kind : Audit_Kind; Coverage : Boolean) return Boolean is
     (Suffix.Well_Formed and then Suffix.Unique
      and then (for all Name in Entity_Kind =>
        not (Prefix (Name) and Suffix.Seen (Name))
        and ((Prefix (Name) or Suffix.Seen (Name)) =
          (if Coverage then Expected_Coverage (Name, Kind)'Length > 0
           else Expected_Entity (Name, Kind)))));

   --  A name can move from the recursively specified suffix to the
   --  imperative prefix without changing uniqueness or exact coverage.
   procedure Advance_Map
     (Prefix : Entity_Set; Rest : Entity_Summary; Name : Entity_Kind;
      Kind : Audit_Kind; Coverage : Boolean)
     with Ghost => Static, Global => null,
       Pre => Name /= Unknown and then not Prefix (Name),
       Post => Map_Policy
         (Prefix, (Rest.Well_Formed, Rest.Unique and not Rest.Seen (Name),
                   Remember (Rest.Seen, Name)), Kind, Coverage) =
         Map_Policy (Remember (Prefix, Name), Rest, Kind, Coverage)
   is
   begin
      null;
   end Advance_Map;

   function Map_Spec (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Map_Spec (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '{'
      and then Text (Items.Last) = '}'
      and then Map_Policy
        (No_Entities, Map_From (Text, Items, Entities, Kind, Coverage, Items.First + 1), Kind, Coverage));

   function Map_OK (Text : String; Items, Entities : Span;
                    Kind : Audit_Kind; Coverage : Boolean) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Map_OK'Result = Map_Spec (Text, Items, Entities, Kind, Coverage))
   is
      Seen : Entity_Set := No_Entities;
      P : Offset;
      M : Member;
      Name : Entity_Kind;
   begin
      if not Valid (Text, Items) or else Text (Items.First) /= '{'
        or else Text (Items.Last) /= '}'
      then return False; end if;
      P := Items.First + 1;
      loop
         pragma Loop_Invariant (P in Items.First + 1 .. Text'Length + 1);
         pragma Loop_Invariant
           (Static => Map_Spec (Text, Items, Entities, Kind, Coverage) =
             Map_Policy (Seen, Map_From (Text, Items, Entities, Kind, Coverage, P), Kind, Coverage));
         pragma Loop_Variant (Increases => P);
         M := Read_Member (Text, Items, P);
         case M.State is
            when Broken => return False;
            when Finished => exit;
            when Present =>
               if M.Key.Last - M.Key.First < 1 then return False; end if;
               if Coverage then
                  Name := Entity_Name (Text, Field
                    (Text, Entities, Text (M.Key.First + 1 .. M.Key.Last - 1)));
                  if Expected_Coverage (Name, Kind)'Length = 0
                    or else not String_Equal (Text, M.Value, Expected_Coverage (Name, Kind))
                  then return False; end if;
               else
                  if Field (Text, Items, Text (M.Key.First + 1 .. M.Key.Last - 1)) /= M.Value
                  then return False; end if;
                  Name := Entity_Name (Text, M.Value);
               end if;
               pragma Assert
                 (Static => Name = Map_Name (Text, Items, Entities, M, Kind, Coverage));
               if Name = Unknown or else Seen (Name) then
                  pragma Assert (Static => not Map_Spec (Text, Items, Entities, Kind, Coverage));
                  return False;
               end if;
               Advance_Map
                 (Seen, Map_From (Text, Items, Entities, Kind, Coverage, M.Next), Name, Kind, Coverage);
               Seen := Remember (Seen, Name);
               P := M.Next;
         end case;
      end loop;
      return (for all Name in Entity_Kind => Seen (Name) =
        (if Coverage then Expected_Coverage (Name, Kind)'Length > 0
         else Expected_Entity (Name, Kind)));
   end Map_OK;

   function Entities_OK (Text : String; Entities : Span; Kind : Audit_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Entities_OK'Result = Map_Spec (Text, Entities, Entities, Kind, False))
   is
   begin
      return Map_OK (Text, Entities, Entities, Kind, False);
   end Entities_OK;

   function Coverage_OK (Text : String; Coverage, Entities : Span; Kind : Audit_Kind) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Coverage_OK'Result = Map_Spec (Text, Coverage, Entities, Kind, True))
   is
   begin
      return Map_OK (Text, Coverage, Entities, Kind, True);
   end Coverage_OK;

   --  Policy over byte-derived fields. Array folds state universal discharge
   --  and an existential owned-postcondition witness; map folds establish
   --  uniqueness and exactly the required entity and coverage sets. None of
   --  these definitions invokes Audit_Report or its executable traversal loops.
   function Object_Policy (Text : String; Object : Span; Kind : Audit_Kind)
     return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Object_Policy (Text : String; Object : Span; Kind : Audit_Kind)
     return Boolean is
     (declare Entities : constant Span := Field_Spec (Text, Object, JSON_entities);
      begin
        String_Equal (Text, Field_Spec (Text, Object, JSON_progress), Atom_PROGRESS_PROOF)
        and then String_Equal (Text, Field_Spec (Text, Object, JSON_stop_reason), Atom_STOP_REASON_NONE)
        and then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_skip_flow_proof))
        and then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_skip_proof))
        and then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_pragma_assume))
        and then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_warn_error))
        and then Map_Spec (Text, Entities, Entities, Kind, False)
        and then Map_Spec (Text, Field_Spec (Text, Object, JSON_spark), Entities, Kind, True)
        and then (if Kind = Assignment_Main then
          Assignment_Flow_Spec (Text, Field_Spec (Text, Object, JSON_flow), Entities)
         elsif Kind = Assignment_Effects then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_flow))
         else List_Spec (Text, Field_Spec (Text, Object, JSON_flow), Entities,
                        (if Kind = Main_Body then Main_Checks else Checks)))
        and then (if Kind in Assignment_Main | Assignment_Effects then
          Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_proof))
         else List_Spec (Text, Field_Spec (Text, Object, JSON_proof), Entities,
                        (if Kind = Main_Body then Main_Checks else Checks)))
        and then (if Kind = Assignment_Main then
          Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_assumptions))
         elsif Kind = Assignment_Effects then
          Assignment_Effects_Spec (Text, Field_Spec (Text, Object, JSON_assumptions), Entities)
         else Dependencies_Spec (Text, Field_Spec (Text, Object, JSON_assumptions), Entities))
        and then (Kind in Libc_Interface | Argv_Interface | Main_Body | Assignment_Main | Assignment_Effects or else
          (not Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_flow))
           and then not Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_proof))
           and then List_Spec (Text, Field_Spec (Text, Object, JSON_proof), Entities,
             (if Kind = IO_Body then Postconditions else Argument_Postconditions)))));

   function Report_Policy (Report : String; Kind : Audit_Kind) return Boolean
     with Ghost => Static, Global => null;

   function Report_Policy (Report : String; Kind : Audit_Kind) return Boolean is
     (Report'Length in 1 .. Max_Report_Length and then
       (declare Text : constant String (1 .. Report'Length) := Report;
                Start : constant Offset := Space_End (Text, 1);
                Last : constant Offset := Value_Spec (Text, Start);
        begin
          Last /= 0 and then Space_End (Text, Last + 1) = Text'Length + 1
            and then Object_Policy (Text, (Start, Last), Kind)));

   function Runtime_Report_Policy (Report : String; Kind : Report_Kind)
     return Boolean is (Report_Policy (Report, Audit_Of (Kind)));

   function Application_Report_Policy (Report : String) return Boolean is
     (Report_Policy (Report, Main_Body));

   function Assignment_Report_Policy (Report : String) return Boolean is
     (Report_Policy (Report, Assignment_Main) or else Report_Policy (Report, Assignment_Effects));

   function Audit_Report (Report : String; Kind : Audit_Kind) return Boolean
     with Post => (Static => Audit_Report'Result = Report_Policy (Report, Kind))
   is
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
         Entities := Field (Text, Object, JSON_entities);
         return String_Equal (Text, Field (Text, Object, JSON_progress), Atom_PROGRESS_PROOF)
           and then String_Equal (Text, Field (Text, Object, JSON_stop_reason), Atom_STOP_REASON_NONE)
           and then Empty_Array (Text, Field (Text, Object, JSON_skip_flow_proof))
           and then Empty_Array (Text, Field (Text, Object, JSON_skip_proof))
           and then Empty_Array (Text, Field (Text, Object, JSON_pragma_assume))
           and then Empty_Array (Text, Field (Text, Object, JSON_warn_error))
           and then Entities_OK (Text, Entities, Kind)
           and then Coverage_OK (Text, Field (Text, Object, JSON_spark), Entities, Kind)
           and then (if Kind = Assignment_Main then
             Assignment_Flow_OK (Text, Field (Text, Object, JSON_flow), Entities)
            elsif Kind = Assignment_Effects then Empty_Array (Text, Field (Text, Object, JSON_flow))
            else List_OK (Text, Field (Text, Object, JSON_flow), Entities,
                          (if Kind = Main_Body then Main_Checks else Checks)))
           and then (if Kind in Assignment_Main | Assignment_Effects then
             Empty_Array (Text, Field (Text, Object, JSON_proof))
            else List_OK (Text, Field (Text, Object, JSON_proof), Entities,
                          (if Kind = Main_Body then Main_Checks else Checks)))
           and then (if Kind = Assignment_Main then
             Empty_Array (Text, Field (Text, Object, JSON_assumptions))
            elsif Kind = Assignment_Effects then
             Assignment_Effects_OK (Text, Field (Text, Object, JSON_assumptions), Entities)
            else Dependencies_OK (Text, Field (Text, Object, JSON_assumptions), Entities))
           and then (Kind in Libc_Interface | Argv_Interface | Main_Body | Assignment_Main | Assignment_Effects or else
             (not Empty_Array (Text, Field (Text, Object, JSON_flow))
              and then not Empty_Array (Text, Field (Text, Object, JSON_proof))
              and then List_OK (Text, Field (Text, Object, JSON_proof), Entities,
                (if Kind = IO_Body then Postconditions else Argument_Postconditions))));
      end;
   end Audit_Report;

   function Complete_Runtime_Proof
     (Report : String; Kind : Report_Kind) return Boolean is
   begin
      return Audit_Report (Report, Audit_Of (Kind));
   end Complete_Runtime_Proof;
   function Complete_Application_Proof (Report : String) return Boolean is
   begin
      return Audit_Report (Report, Main_Body);
   end Complete_Application_Proof;
   function Complete_Assignment_Proof (Report : String) return Boolean is
   begin
      return Audit_Report (Report, Assignment_Main) or else Audit_Report (Report, Assignment_Effects);
   end Complete_Assignment_Proof;
end Silver_Library_Reports;
